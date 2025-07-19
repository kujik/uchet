unit uTurv;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DBCtrlsEh, Buttons, DBGridEh, DBAxisGridsEh, GridsEh,
  DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  MemTableDataEh, Db, MemTableEh, Math, ExtCtrls,
  Registry, IniFiles, GridToolCtrlsEh, SearchPanelsEh, DBLookupUtilsEh,
  PropFilerEh, MemTreeEh, ImgList, StdActns, ActnList, Jpeg, uString, PngImage, DateUtils,
  uData, uForms;

type
  TTurv = class(TObject)
  private
  public
    constructor Create;
    function GetWorkerStatusArr(id: Integer): TVarDynArray2;
    //возвращаем начало периода турв, в колтором находится дата
    function GetTurvBegDate(dt: TDateTime): TDateTime;
    //возвращаем конец периода турв, в колтором находится дата
    function GetTurvEndDate(dt: TDateTime): TDateTime;
    function GetTurvArray(DivisionId: Integer; dt: TDateTime; SortByJob: Boolean = True): TVarDynArray2;
    function GetTurvArrayFromDB(DivisionId: Integer; dt: TDateTime; SortByJob: Boolean = True): TNamedArr;
    function GetcodeUV: Integer;
    function GetcodePER: Integer;
    function CreateTURV(DivisionId: Variant; AllDivisions: Integer; ActiveOnly: Boolean; dt: TDateTime; Silent: Boolean = True): Integer;
    function Synchronize(ID_Division: Integer; dt: TDateTime): Boolean;
    function ChangeWorkerInTURV(Id_Worker:Variant; ID_Division: Variant; ID_Job: Variant; Dt: TDateTime; ID_JStatus: Integer; Mode: Variant): Boolean;
    function DeleteTURV(ID: Integer; Silent: Boolean = False): Boolean;
    function GetWorkersNotInParsec(Mailing: Boolean=False): TVarDynArray2;
    function GetActiveWorkers: TVarDynArray2;
    function GetStatus(ID_Division: Integer; dt: TDateTime): Integer;
    function LoadParsecData: Boolean;
    function GetDaysFromCalendar(DtBeg, DtEnd: TDateTime): TVarDynArray2;
    function GetDaysFromCalendar_Next(DtBeg: TDateTime; CntOfWork: Integer): TDateTime;
    //диалог ввода графика работы и норм рабочего времени по нему
    function ExecureWorkCheduledialog(AOwner: TComponent; AId: Variant; AMode: TDialogType): Boolean;
  end;

var
  Turv: TTurv;

implementation

uses
  uDBOra,
  uMessages,
  uTasks,
  uSys,
  uDBParsec,
  uFrmBasicInput
  ;

constructor TTurv.Create;
begin
  inherited;
end;

function TTurv.GetWorkerStatusArr(id: Integer): TVarDynArray2;
begin
  Result:=Q.QLoadToVarDynArray2('select dt, status, id_division, id_job from j_worker_status where id_worker = :id$i order by dt desc, id_division, id_job', [id]);
end;

//возвращаем начало периода турв, в колтором находится дата
function TTurv.GetTurvBegDate(dt: TDateTime): TDateTime;
begin
  Result:=EncodeDate(YearOf(dt), MonthOf(dt), S.IIf(DayOf(dt)<=15, 1, 16));
end;

//возвращаем конец периода турв, в колтором находится дата
function TTurv.GetTurvEndDate(dt: TDateTime): TDateTime;
begin
  if DayOf(dt) <= 15
    then Result:=EncodeDate(YearOf(dt), MonthOf(dt), 15)
    else Result:=IncDay(IncMonth(EncodeDate(YearOf(dt), MonthOf(dt), 1), 1), -1);
end;

function TTurv.GetTurvArrayFromDB(DivisionId: Integer; dt: TDateTime; SortByJob: Boolean = True): TNamedArr;
//загрузим массив работников для турв в том же виде что и GetTurvArray, но напрямую из бд
//0-дата1, 1-дата2, 2-айди работника, 3-имя работника, 4-фйди профессии, 5-назавание профессии,
begin
  dt:=Turv.GetTurvBegDate(dt);
  //запрос. сортировка принципиальна
  Q.QLoadFromQuery(
    'select dt1p, dt2p, id_worker, workername, id_job, job, worker_has_schedule, id_schedule, schedule, id_schedule_active, premium, comm, id_division '+
    'from v_turv_workers where id_division = :id_division$i and dt1 = :dt1$d '+
    'order by ' + S.IIf(SortByJob, 'job', 'workername'),
    [DivisionId, dt],
    Result
  );
end;


//вернем массив работников, которые числятся в данном турв, на основании журнала статусо работников
//по строчке на каждого работника за подпериод в турв
//(если работник преходил между разными должностями, увольнялся и опять принимался в пределах турв, даже если возврат на ту же должность,
//для каждого периода работы отдельная строка в массиве)
//0-дата1, 1-дата2, 2-айди работника, 3-имя работника, 4-фйди профессии, 5-назавание профессии, 6-после периода: 1=переведен 2=уволен, 7-айди графика, 8- название графика
function TTurv.GetTurvArray(DivisionId: Integer; dt: TDateTime; SortByJob: Boolean = True): TVarDynArray2;
var
  i, j, k: Integer;
  dt1, dt2: TDateTime;
  st, st1, st2, w: string;
  v, v1, v2: TVarDynArray2;
  buf: Variant;
  changed: Boolean;
  size: Integer;
begin
  Result:=[];
  dt1:=Turv.GetTurvBegDate(dt);
  dt2:=Turv.GetTurvEndDate(dt);
  //запрос. сортировка принципиальна
  v:=Q.QLoadToVarDynArray2('select id_division, id_worker, workername, id_job, job, status, dt, id_schedule from v_j_worker_status order by workername, dt, job, id_division',[]);
  if Length(v) = 0 then Exit;
  w:=v[0][2];
  //v1 - массив по одному работнику
  //0-дата1, 1-дата2, 2-айди работника, 3-имя работника, 4-фйди профессии, 5-назавание профессии, 6-после периода: 1=переведен 2=уволен
  v1:=[];
  j:=High(v);
  for i:=0 to High(v)+1 do begin
    if (i = High(v)+1) or (v[i][2]<> w) then begin
      //изменился работник или кончились данные
      //скопируем в общий массив
      for j:=0 to High(v1) do begin
        SetLength(Result, Length(Result)+1);
        Result[High(Result)]:=[v1[j][0], v1[j][1], v1[j][2], v1[j][3], v1[j][4], v1[j][5], v1[j][6], v1[j][7]]
      end;
      if (i = High(v)+1) then Break;
      //очистим массив работника
      SetLength(v1, 0);
      w:=v[i][2];
    end;
    if  v[i][6] <= dt1 then begin
      //дата меньше илиравна начала периода
      if (v[i][0] = DivisionId)and(Integer(v[i][5]) in [1, 2]) then begin
        //работник принял или переведен в это подразделение
        if Length(v1) = 0 Then SetLength(v1, 1);
        v1[0]:=[dt1, dt2, v[i][1], v[i][2], v[i][3], v[i][4], 0, v[i][7]];
      end
      else begin
        //уволен или переведен в другое подразделение
        SetLength(v1, 0);
      end;
    end
    else if v[i][6] <= dt2 then begin
      //дата в пределах от второго дня периода до конца периода турв
      if (v[i][0] = DivisionId)and(Integer(v[i][5]) in [1, 2]) then begin
        //работник принял или переведен в это подразделение
        if (Length(v1) > 0)and(v1[High(v1)][1] >= v[i][6]) Then begin
          //для прошлой записи работника поставим конечной датой предыдущую из этой записи
          v1[High(v1)][1]:=IncDay(v[i][6], -1);
          //и поставим статус перевод
          v1[High(v1)][6]:=1;
        end;
        SetLength(v1, Length(v1)+1);
        v1[High(v1)]:=[v[i][6], dt2, v[i][1], v[i][2], v[i][3], v[i][4], 0, v[i][7]];
      end
      else if Integer(v[i][5]) in [1, 2] then begin
        //переведен в другое подраздление
        if (Length(v1) > 0)and(v1[High(v1)][1] >= v[i][6]) Then begin
          v1[High(v1)][1]:=IncDay(v[i][6], -1);
          v1[High(v1)][6]:=1;
        end;
      end
      else begin
        //уволен
        if (Length(v1) > 0)and(v1[High(v1)][1] >= v[i][6]) Then begin
          v1[High(v1)][1]:=IncDay(v[i][6], -1);
          v1[High(v1)][6]:=2;
        end;
      end;
    end;
  end;

  if not SortByJob then Exit;
// сортировка массива
  repeat
    changed := False; // пусть в текущем цикле нет обменов
    for k := 0 to High(Result) - 1 do
      if Result[k][5] > Result[k + 1][5] then
      begin // обменяем k-й и k+1-й элементы
        for j:=0 to High(Result[k]) do begin
          buf := Result[k][j];
          Result[k][j] := Result[k + 1][j];
          Result[k + 1][j] := buf;
        end;
        changed := True;
      end;
  until not changed; // если не было обменов, значит

end;


function TTurv.GetcodeUV: Integer;
begin
  Result:=16;
end;


function TTurv.GetcodePER: Integer;
begin
  Result:=15;
end;

function TTurv.DeleteTURV(ID: Integer; Silent: Boolean = False): Boolean;
begin
  Result:=False;
  if not Silent then
    if not ((MyQuestionMessage('Удалить ТУРВ?') = mrYes) and (MyQuestionMessage('Вы Уверены?') = mrYes))
      then Exit;
  Q.QExecSql('delete from turv_period where id = :id$i', [ID]);
  Result:=True;
end;



function TTurv.CreateTURV(DivisionId: Variant; AllDivisions: Integer; ActiveOnly: Boolean; dt: TDateTime; Silent: Boolean = True): Integer;
//создаем ТУРВы для указанных подразделений за указанный период
//передается строка через запятую или айди или массив айди подразделений
//AllDivisions = 0 - создает по перечисленным подразделениям, 1 - создает все, 2- создает по своим турв
//если ActiveOnly то не создает по неактивным
//если Silent то молча
//возвращает количество созданных
var
  i, j, k, res, res2: Integer;
  st, st1, st2, w: string;
  v0, v1, v2: TVarDynArray2;
  v: Variant;
  v3: TVarDynArray;
begin
  Result:=-1;
  dt:=GetTurvBegDate(dt);
  st:=S.IIFStr(ActiveOnly, ' and active = 1', '');
  case AllDivisions of
    1: begin
        v0:=Q.QLoadToVarDynArray2('select id, name, active, editusers, id_schedule from v_ref_divisions where 1 = 1' + st, []);
       end;
    2: begin
        v0:=Q.QLoadToVarDynArray2('select id, name, active, editusers, id_schedule from v_ref_divisions where IsStInCommaSt(:u$i, editusers) = 1' + st, [User.GetId]);
       end;
    else
      begin
        v0:=Q.QLoadToVarDynArray2(
          'select id, name, active, editusers, id_schedule from v_ref_divisions where id in (:st$i)' + st, [A.Implode(A.VarIntToArray(DivisionId), ',')]
        );
      end;
  end;
  Result:=0;
  for i:= 0 to High(v0) do begin
    v1:=Q.QLoadToVarDynArray2(
      'select id, id_division, dt1 from turv_period where id_division =:id_division$i and dt1 = :dt1$d',
      [v0[i][0], dt]
    );
    if Length(v1) = 1 then begin
      if not Silent then MyWarningMessage('ТУРВ для подразделения "' + v0[i][1] + '" уже создан!');
      continue;
    end;
    //0-дата1, 1-дата2, 2-айди работника, 3-имя работника, 4-фйди профессии, 5-назавание профессии, 6-после периода: 1=переведен 2=уволен
    v2:=GetTurvArray(v0[i][0], dt);
    if Length(v2) = 0 then begin
      if not Silent then MyWarningMessage('К подразделению "' + v0[i][1] + '" в заданный период не привязан ни один работник! ТУРВ не может быть создан!');
      continue;
    end;
    Q.QBeginTrans;
    res:=Q.QIUD('i', 'turv_period', '', 'id$i;id_division$i;dt1$d;dt2$d;commit$i;id_schedule$i', [0, v0[i][0], dt, GetTurvEndDate(dt), 0, v0[i][4]]);
    if Q.QRowsAffected = 0 then Result:=-1;
    if res = -1 then Result:=-1;
    if Result =- 1 then Break;
    for j:=0 to High(v2) do begin
      res2:=Q.QIUD('i', 'turv_worker', '', 'id$i;id_turv$i;id_worker$i;id_division$i;id_job$i;dt1$d;dt2$d;dt1p$d;dt2p$d;id_schedule',
        [
          0,
          res,            //айди турв период
          v2[j][2],       //работник
          v0[i][0],       //подразделение
          v2[j][4],       //должность
          dt,             //начало периода
          GetTurvEndDate(dt),      //конец
          v2[j][0],                //начало данных строки
          v2[j][1],                 //конец
          v2[j][7]       //график работы
        ]
      );
      if res2 = -1 then
        begin Result:=-1; Break; end;
    end;
    if Result <> -1
      then inc(Result)
      else begin
        Q.QRollbackTrans;
        Break;
      end;
    Q.QCommitTrans;
  end;
end;


function TTurv.ChangeWorkerInTURV(Id_Worker:Variant; ID_Division: Variant; ID_Job: Variant; Dt: TDateTime; ID_JStatus: Integer; Mode: Variant): Boolean;
//правит данные в таблицах для указанного работника, в соответствии с новыми параметрами начиная с указанной даты
//проверяются все турв, передаются новые значения для работника, указание старых параметров не требуется
//так как проверка согласованности выполняется еще по журналу статусов, то может быть изменена
//либо удалена и добавлена только одна запись turv_worker в периоде
//эта же функция изменяет и статус работника в таблице статусов
//добавляет запись для моде ин 1,2,3 и удаляем для -1
//все выполняется в транзакции, при ошибке скл откат
var
  i, j, k, d, res, res2: Integer;
  st, st1, st2, w, dn: string;
  v0, v1, v2, days: TVarDynArray2;
  v: Variant;
  v3: TVarDynArray;
  b, Result1: Boolean;
  m: Integer;
  dt1: TDateTime;
  dayfields: string;
begin
  Result:= False;
  //найдем затрагиваемые периоды
  //это будут все периоды с конечной датой большей даты изменения статуса, содержащие любую запись для данного работника и
  //все периоды с ID_Division и также большей конечно датой, это независимо от режима изменения статуса
  //!!! изм 2023-11-17
  //ОШИБКА синхронизация подразделений с воркерстатус происходила по порядку, и если сначала идет подразделение в которой поступает работник,
  //то оно обрабатывалось первым и была попытка вставить запись работника, но это вызывает ошибку так как этот работник и с этой датой мог быть в другом подразделении
  //надо это подразделение обрабатывать последним
  M:=Mode;
  v0:=Q.QLoadToVarDynArray2(
    'select distinct d.name, tp.commit, tp.dt1, tp.dt2, d.id from ref_divisions d, turv_period tp, turv_worker tw ' +
    'where d.id = tp.id_division and tp.id = tw.id_turv and tp.dt2 >= :dt$d ' +
    'and (tw.id_worker = :id_worker$i or d.id = :id_division$i) ' +
    'order by tp.dt1, d.name',
    [dt, Id_Worker, S.IIf(S.NSt(ID_Division) = '', -1, ID_Division)]
    );
  st:='';
  dn:='';
//  v0:=v0 + v1;
  j:=0; k:=0;
  for i:=0 to High(v0) do
    if dn <> v0[i][0] then begin
      if S.NNum(v0[i][1]) = 1 then inc(k);
      if i < 10
        then S.ConcatStP(st, v0[i][0] +
          ' (с ' + VarToStr(v0[i][2]) + ' по ' + VarToStr(v0[i][3]) +  S.IIf(S.NNum(v0[i][1]) = 1, ' - Закрыт!', '') + ')', #13#10);
      dn:= v0[i][1];
    end;
  if (st <> '')and
    (MyQuestionMessage(
      'Будут внесены изменения в следующие ТУРВ:'#13#10#13#10 +
      st +
      S.IIf(High(v0) >= 10, #13#10'и еще ' + IntToStr(High(v0) - 10) + ' ТУРВ.'#13#10, '') +
      S.IIf(k > 0, S.IIf(k = Length(v0), #13#10#13#10'Все ТУРВ закрыты!', #13#10#13#10'Часть ТУРВ закрыты!'),''))
    <> mrYes)
    then Exit;
  //делаем изменения в таблицах турв
  days:=[];
  dayfields:=
    'dt$d;dt1$d;worktime1$f;worktime2$f;worktime3$f;id_turvcode1$i;id_turvcode2$i;id_turvcode3$i;'+
    'premium$i;premium_comm$s;penalty$i;penalty_comm$s;production$i;'+
    'comm1$s;comm2$s;comm3$s;begtime$f;endtime$f;settime3$i';
  //получим данные по временам, если у нас будет изменение и при этом работник останется, то данные восстановим
  if ID_Division <> null then begin
    st:=Q.QSIUDSql('A', 'turv_day', dayfields) + ' where id_worker = :id_worker$i and dt >= :dt$d order by dt';
    days:=Q.QLoadToVarDynArray2(st, [Id_Worker, dt]);
  end;
  Result:=True;
  Result1:=False;
  //начнем транзакцию
  Q.QBeginTrans;
  try
  repeat
    //изменим таблицу статусов, тк она понадобится для коррекции периодов
    if Mode = -1
      then begin
        v3:=[ID_JStatus];
//        Result:= (Q.QIUD('d', 'j_worker_status', 'sq_j_worker_status', 'id$i;name;office;id_head;editusers', v3) >= 0);
        Result:= (Q.QIUD('d', 'j_worker_status', 'sq_j_worker_status', 'id$i', v3) >= 0);
      end
      else begin
        v3:= [ID_JStatus, ID_Worker, ID_Division, ID_Job, Mode, dt];
        Result:= (Q.QIUD('i', 'j_worker_status', 'sq_j_worker_status', 'id$i;id_worker$i;id_division$i;id_job$i;status$i;dt$d', v3) >= 0);
      end;
    if not Result then Break;
    //синхронизируем с журналом статусов все задействованные периоды
    //изм 2023-11-17
    //сначала синхронизируем старые для работника подразделения
    for i:=0 to High(v0) do begin
      if v0[i][4] <> S.NNum(ID_Division)
        then Result:=Synchronize(v0[i][4], v0[i][2]);
      if not Result then Break;
    end;
    if not Result then Break;
    //а потом новое подразделение
    for i:=0 to High(v0) do begin
      if v0[i][4] = S.NNum(ID_Division)
        then Result:=Synchronize(v0[i][4], v0[i][2]);
      if not Result then Break;
    end;
    if not Result then Break;
    //снова проставим данные по дням работника, для нового айди и тех же дат
    for i:=0 to High(days) do begin
      v3:=[];
      for j:=0 to High(days[i])
        do v3:=v3 + [days[i, j]];
      v:=VarArrayOf(v3 + [Id_Worker, days[i][0]]);
      st:=Q.QSIUDSql('Q', 'turv_day', dayfields) + ' where id_worker = :id_worker$i and dt = :dt_day$d';
      Result:=Q.QExecSQL(st, [v]) >= 0;
      if not Result then Break;
    end;
    if not Result then Break;
  until True;
  Result1:=True;
  finally
  //фиксируем или отктываем транзакцию
  //для проверки можно вообще убрать и смотреть изменения до выхода из программы, завершить ее по стрл-ф2
  Q.QCommitOrRollback(Result and Result1);
  end;
  if not Result
    then MyWarningMessage('При сохранении данных возникла ошибка! Данные не изменены!');
end;


function TTurv.Synchronize(ID_Division: Integer; dt: TDateTime): Boolean;
var
  i, j, k, res, res2: Integer;
  st, st1, st2, w: string;
  v0, v1, v2: TVarDynArray2;
  v: Variant;
  v3: TVarDynArray;
  b: Boolean;
begin
  Result:=True;
  dt:=GetTurvBegDate(dt);
  v0:=Q.QLoadToVarDynArray2(
    'select id, id_division, dt1 from turv_period where id_division =:id_division$i and dt1 = :dt1$d',
    [id_Division, dt]
  );
  if Length(v0) <> 1 then Exit;
  //массив по работникам для данного турв из базы
  v1:=Q.QLoadToVarDynArray2(
    'select id,id_turv,id_worker,id_division,id_job,dt1,dt2,dt1p,dt2p,0 '+
    'from turv_worker ' +
    'where id_division =:id_division$i and dt1 = :dt1$d',
    [id_Division, dt]
  );
  //массив тутв вычисленный
  //0-дата1, 1-дата2, 2-айди работника, 3-имя работника, 4-фйди профессии, 5-назавание профессии, 6-после периода: 1=переведен 2=уволен
  v2:=GetTurvArray(ID_Division, dt);
  if (Length(v1) = 0) and (Length(v2) = 0) then Exit;
//  QBeginTrans;
  Result:=True;
  repeat
  //удалим записи по работникам, которых нет в вычисленном, сравнивая по айди работника и айди профессии
  for i:=0 to high(v1) do begin
    b:= False;
    for j:=0 to high(v2) do
      if (v1[i][2] = v2[j][2])and(v1[i][4] = v2[j][4]) then
        begin b:=True; Break; end;
    if not b then begin
      Result:=Q.QExecSql('delete from turv_worker where id = :id$i', [v1[i][0]]) >=0;
      v1[i][9]:=1;
      if not Result then Break;
    end;
  end;
  if not Result then Break;
  //теперь скорректируем те у которых не совпадают даты
  for i:=0 to high(v1) do begin
    b:= False;
    for j:=0 to high(v2) do
      //если совпадают по работнику и профессии
      if (v1[i][2] = v2[j][2])and(v1[i][4] = v2[j][4]) then
        //совпадает начальная дата данных по работнику в турв
        if (v1[i][7] = v2[j][0]) then
          if (v1[i][8] = v2[j][1])
            then begin
              //совпадает и конечная, оставим как есть
              v1[i][9]:= 2;
              Break;
            end
            else begin
              //конечная не совпадает, поправим
              Result:=Q.QExecSql('update turv_worker set dt2p = :dt$d where id = :id$i', [v2[j][1], v1[i][0]]) >=0;
              v1[i][9]:=3;
              Break;
            end;
    if not Result then Break;
  end;
  if not Result then Break;
  //удалим из бд те ззаписи, которые не были обработаны (т.е. ране не удалены, не совпадают полностью или не поправлена дата
  for i:=0 to high(v1) do begin
    if (v1[i][9] = 0) then begin
      Result:=Q.QExecSql('delete from turv_worker where id = :id$i', [v1[i][0]]) >=0;
      v1[i][9] := 1;
      if not Result then Break;
    end;
  end;
  if not Result then Break;
  v1:=Q.QLoadToVarDynArray2(
    'select id,id_turv,id_worker,id_division,id_job,dt1,dt2,dt1p,dt2p,0 '+
    'from turv_worker ' +
    'where id_division =:id_division$i and dt1 = :dt1$d',
    [id_Division, dt]
  );
  //добавим в таблицу записи, которых в ней еще нет
  for j:=0 to high(v2) do begin
    b:= False;
    //флаг, если среди обработанных есть с такими же работником, профессией и начальной датой
    for i:=0 to high(v1) do begin
//      if (v1[i][9] >= 2)and(v1[i][2] = v2[j][2])and(v1[i][4] = v2[j][4])and(v1[i][7] = v2[j][0]) then begin
      if (v1[i][2] = v2[j][2])and(v1[i][7] = v2[j][0]) then begin
        b:=True;
        Break;
      end;
    end;
    if not b then begin
      Result:=Q.QIUD('i', 'turv_worker', '', 'id$i;id_turv$i;id_worker$i;id_division$i;id_job$i;dt1$d;dt2$d;dt1p$d;dt2p$d',
        [
          0,
          v0[0][0],       //айди турв период
          v2[j][2],       //работник
          Id_Division,    //подразделение
          v2[j][4],       //должность
          dt,             //начало периода
          GetTurvEndDate(dt),      //конец
          v2[j][0],                //начало данных строки
          v2[j][1]                 //конец
        ]
      ) >=0;
    end;
    if not Result then Break;
  end;
  if not Result then Break;
  until True;
//        QRollbackTrans; exit;
end;

function TTurv.GetActiveWorkers: TVarDynArray2;
//получим массив работников, работающих на данный момент
begin
  Result:=Q.QLoadToVarDynArray2('select id, workername, dt, divisionname, job from v_ref_workers where job is not null', []);
end;

function TTurv.GetWorkersNotInParsec(Mailing: Boolean=False): TVarDynArray2;
//получим массив работников, которые сейчас работают по данным учета, но не найдены в Парсек
var
  vr, vp: TVarDynArray2;
  i, j: Integer;
  st, st1: string;
begin
  Result:=[];
  vr:=GetActiveWorkers;
  vp:=[];
  try
    MyData.QParsec.Close;
    MyData.QParsec.SQL.Text:=
      'select concat(p.last_name, '' '', p.first_name, '' '', p.middle_name) as name from parsec3.dbo.person as p'
    ;
    try
    MyData.QParsec.Open;
    except
    end;
    if not MyData.QParsec.Connection.Connected then Exit;
    while not MyData.QParsec.EOF do begin
      SetLength(vp, Length(vp) + 1);
      SetLength(vp[High(vp)], MyData.QParsec.FieldCount);
      for i:=0 to MyData.QParsec.FieldCount-1
        do vp[High(vp)][i]:=MyData.QParsec.Fields[i].AsVariant;
      MyData.QParsec.Next;
    end;
  except
  end;
  if MyData.QParsec.Active
    then MyData.QParsec.Close
    else Exit;
  for i:=0 to High(vr) do begin
    if A.PosInArray(vr[i][1], vp, 0) < 0
      then Result:=Result + [vr[i]];
  end;
  if High(Result) > 0 then begin
    st:=S.NSt(Q.QSelectOneRow('select emailaddr from v_users where id = :id$i', [33])[0]);
    if st = '' then Exit;
    st1:='';
    for i:=0 to High(Result) do
      st1:=st1+S.NSt(Result[i][1]) + '  [' + S.NSt(Result[i][3]) + ',  ' + S.NSt(Result[i][4])  +']' + #13#10;
    st1:='Следующие работники (которые сейчас работают в компании) отсутствуют в базе Parsec:'#13#10#13#10 + st1;
    Tasks.CreateTaskRoot(mytskopmail, [
//      ['to', 'sprokopenko@fr-mix.ru'],
    ['to', st],
    ['subject', 'Не все работники есть в Parsec!'],
    ['body', st1],
    ['user-name', 'Учёт']]
  );
  end;
end;

function TTurv.GetStatus(ID_Division: Integer; dt: TDateTime): Integer;
//проверим, можго ли закрыть турв, если можно вернем 0
//в будущем хотел сделать остальные статусы, введено все, не введен парсек и тп,
var
  i, j, k, res, res2: Integer;
  st, st1, st2, w: string;
  v0, v1, v2: TVarDynArray2;
  v: Variant;
  v3: TVarDynArray;
  b: Boolean;
begin
  Result:=0;
  v0:=Q.QLoadToVarDynArray2(
    'select id_turvcode1, worktime1, id_turvcode2, worktime2, id_turvcode3, worktime3 from turv_day where id_division = :id$i and dt1 = :dt1$d',
    [ID_Division, dt]
  );
  b:=True;
  //проверим, можно ли закрыть турв
  for i:=0 to High(v0) do begin
    //не введены данные от руководителя
    if (v0[i][0] = null) and (v0[i][1] = null)
      then begin b:=False; Break end;
    //не введены данные по парсек
    if (v0[i][2] = null) and (v0[i][3] = null)
      then begin b:=False; Break end;
    //есть время или код согласованный
    if (v0[i][4] <> null) or (v0[i][5] <> null)
      then Continue;
    //у руководителя время, а по парсек код, или наоборот
    if (v0[i][0] <> null)and(v0[i][2] = null)or(v0[i][0] = null)and(v0[i][2] <> null)or
       (v0[i][1] <> null)and(v0[i][3] = null)or(v0[i][1] = null)and(v0[i][3] <> null)
      then begin b:=False; Break end;
    //и по парсеку и от руководителя время, но различаются больше допустимого
    if (v0[i][1] <> null)and(v0[i][3] <> null)and
      (abs(S.VarToFloat(v0[i][1]) - S.VarToFloat(v0[i][3])) > Module.GetCfgVar(mycfgWtime_autoagreed))
      then begin b:=False; Break end;
  end;
  if not b then Result:=-1;
end;

(*
procedure TDlg_TURV.ImporFromParsec(FileeName: string);
//импорт данных из парсек
//в парсек выгружается отчет приход/уход за месяц, снимается ОБЯЗАТЕЛЬНО выгрузка по одному подразделению на лист
//экспорт отчета осуществляется в формат эксель2007, ставится галка data only
//файл нужно открыть в эксель, будет ошибка и восстановление, и пресохранить
var
  XlsFile:TXlsMemFileEh;
  cr: IXlsFileCellsRangeEh;
  sh: TXlsWorksheetEh;
  v: Variant;
  st: string;
  dt, dt1, dt2, dt3, dt4: TDateTime;
  res: Boolean;
  d1, d2, d1p, cnt, i, j, k, m, cemp: Integer;
  va, va31: TVarDynArray;
  t1, t2, t3, t4, tp: extended;
  vt: TStringDynArray;
const
  rTitle = 8;
  cDtSost = 29;
  cDt1 = 33;
  cDt2 = 36;
  cFio = 1;
  cT = 3;
begin
  if not CreateTXlsMemFileEhFromExists(FileeName, False, '', XlsFile, st) then Exit;
  sh:=xlsFile.Workbook.Worksheets[0]; //регистр имеет значение!
  res:= False;
  repeat
//  st1:=sh.name;
  //читает значение, втч результат формулы
  //col, row с нуля
  v:=sh.cells[0, rTitle].Value;
  if VarToStr(v)<>'ТАБЕЛЬ'#13#10'учета рабочего времени'
    then begin
      MyWarningMessage('Этот файл не является выгрузкой из Parsec!');
      Break;
    end;
  //период за который выбираем данные
  dt1:=Dlg_Turv_FromParsec.dedt_1.Value;
  dt2:=Dlg_Turv_FromParsec.dedt_2.Value;
  //начало и конец месяца
  dt3:=EncodeDate(YearOf(PeriodStartDate), MonthOf(PeriodStartDate), 1);
  dt4:=IncDay(IncMonth(dt3, 1), -1);
  //в файле первая дата должна быть на начало месяца, а вторая не ранее введенной в форме импорта
  if (dt3 <> sh.Cells[cDt1, rTitle].value)or(dt2 > sh.Cells[cDt2, rTitle].value)
    then begin
      MyWarningMessage('Этот файл не является выгрузкой данных за нужный период!');
      Break;
    end;
//  v:=sh.cells[cDtSost, rTitle].Value;
  if MyQuestionMessage('Это выгрузка из Parsec от ' + VartoStr(sh.Cells[cDtSost, rTitle].Value) + #13#10'Продолжить?') <> mrYes
    then Break;
  DBGridEh1.RowDetailPanel.Visible:=False;
  //номер начального столбца в таблице парсек, с единицы, не учитывая смещения
  d1p:=trunc(dt1 - dt3 + 1);
  //номер начального столбца в турв
  d1:= trunc(dt1 - PeriodStartDate + 1);
  //количество затрагиваемых столбцов
  cnt:=trunc(dt2 - dt1 + 1);
  //время начала рабочего дня, из настроек модуля, там оно в часах и минутах - целые это часы, а дробная часть вминута, напр 8.30!
//  t3:=trunc(S.VarToFloat(S.IIf(IsOffice, 0, Module.W_Dinner_Time_Beg_2))) + frac(S.VarToFloat(S.IIf(IsOffice, 0, Module.W_Dinner_Time_Beg_Diff_2)))/60*100;
  t3:=trunc(Module.GetCfgVar(mycfgWtime_beg_2)) + frac(Module.GetCfgVar(mycfgWtime_beg_2))/60*100;
  //время, если раньше него началась работа, подсветим  ..то учитываем весь период и подсветим
  t4:=Max(t3 - S.VarToFloat(Module.GetCfgVar(mycfgWtime_beg_diff_2)), 0);

  SetLength(va31, 32);
  //проходим по турв
  for i:= 0 to High(ArrTurv) do begin
    cemp:=0;
    k:=0;
    //пока не накопилось двадцать пустых клеток по вертикали подряд, ищем данные
    while (cemp < 20) do begin
      v:=Sh.Cells[cFio, k].Value;
      if S.NSt(v) = ''
        then inc(cemp)
        else begin
          if UpperCase(S.NSt(v)) = UpperCase(ArrTitle[i, 2])
            then begin
              //совпадают ФИО в турв и отчете парсек
              m:=ct;
              //выгрузим всю строку по дням подряд
              //тк нет возможности получить заголовок с числами, а есть пустые столбцы, то делаем так
              for j:=1 to 31 do begin
                while S.NSt(Sh.Cells[m, k].Value) = '' do inc(m);
                va31[j]:=S.NSt(Sh.Cells[m, k].Value);
                m:=m + 1;
              end;
              //проходим начиная с первого требуемого дня требуемое количество дней
              for j:=d1 to d1 + cnt - 1 do begin
                //проставляем только для не серых, при времени порасеку либо коду еще не проставленному, но переписываем, если код по парсеку В
                //так как выходные могут быть проставлены заранее из производственного календаря
                if (ArrTurv[i][j][atExists] <> -1) and((ArrTurv[i][j][atTPar] = null)and((ArrTurv[i][j][atCPar] = null)or(ArrTurv[i][j][atCPar] = TurvCodeVyh))) then begin
                  //в ячейке временя прихода и ухода, разделенные переводом строки, часы и минуты через двоеточие
                  vt:=Ah..ExplodeV(StringReplace(va31[j + DayOf(PeriodStartDate) - 1], ':', FormatSettings.DecimalSeparator, [rfReplaceAll]) , #13#10);
                  //сохраним времена
                  if S.IsNumber(vt[0],0,23.59)
                    then ArrTurv[i][j][atBegTime]:=StrToFloat(vt[0])
                    else ArrTurv[i][j][atBegTime]:=-1;
                  if S.IsNumber(vt[1],0,23.59)
                    then ArrTurv[i][j][atEndTime]:=StrToFloat(vt[1])
                    else ArrTurv[i][j][atEndTime]:=-1;
                  t1:=ArrTurv[i][j][atBegTime];
                  t2:=ArrTurv[i][j][atEndTime];
                  if (t1 = -1)and(t2 = -1) then begin
                    //нет ни прихода ни ухода - поставим выходной
                    ArrTurv[i][j][atTPar]:=null;
                    ArrTurv[i][j][atCPar]:=TurvCodeVyh;
                  end
                  else if (t1 = -1)or(t2 = -1) then begin
                    //нет одного времени - поставим 8.00
                    ArrTurv[i][j][atTPar]:=8;
                    ArrTurv[i][j][atCPar]:=null;
                    ArrTurv[i][j][atSetTime]:=1;
                  end
                  else begin
                    //есть оба времени - посчитаем интервал
                    //17:42 = 17.7    7:12 = 7.2    10.5 - 0/5 = 10             8.80 * 4 = 35.2 = 36 / 4 = 9
                    //7.14 - 17.07    7.23 -  17.12 - 0.5 = 9.39 * 4 =  37.56 = 38 = 38/4 = 9.5
                    t1:=trunc(t1) + frac(t1)/60*100;
                    t2:=trunc(t2) + frac(t2)/60*100;
                    {//учтем начало рабочего дня
                    //берем после 8ч, но если начало ранее чем 8ч - 1ч, то берем по парсеку
                    if not IsOffice then
                      if t1 < t4 then begin
                        t1:=Max(t1, t3);
                        ArrTurv[i][j][atSetTime]:=1;
                      end;}
                    //для всех, начало работы принимаем в 8ч (из настроек)
                    t1:=Max(t1, t3);
                    tp:=abs(t2-t1);
                    tp:=Max(0, tp - S.VarToFloat(S.IIf(IsOffice, Module.GetCfgVar(mycfgWtime_dinner_1), Module.GetCfgVar(mycfgWtime_dinner_2))));
                    //округляем до сотых
//                    tp:=RoundTo(tp, -2);
                    if frac(tp) <= 0.33
                      then tp:=trunc(tp)
                      else if frac(tp) <= 0.83
                      then tp:=trunc(tp) + 0.5
                        else tp:=trunc(tp) + 1;
                    //так было бы округление до 15мин всегда в большую сторону
                    //tp:=SimpleRoundTo(tp * 4, 0);
                    //tp:=tp / 4;
                    ArrTurv[i][j][atTPar]:=tp;
                    ArrTurv[i][j][atCPar]:=null;
                    //подсветим (по цеху) кто вышел на час раньше начала рабочего дня
                    ArrTurv[i][j][atSetTime]:=S.IIf((t1<t4) and not IsOffice, 1, null);
                  end;
                  //запишем в датасет для грида
                  SetTurvAllDay(i, j);
                  //запишем в бд
                  SaveDayToDB(i, j, atTPar);
                end;
              end;
              Break;
            end;
          cemp:=0;
        end;
      inc(k);
    end;
  end;
  //обновим грид
  Timer_AfterUpdate.Enabled:=True;
  res:=True;
  until True;
  sh.Free;
  xlsfile.free;
end;
*)


function TTurv.LoadParsecData: Boolean;
//переделан запрос данных из парсека, по новым кодам данных, и с использованием объекта БД myDBParsec
var
  vt, vr, vp, vpb, vpe, vw, vdiv, vpops: TVarDynArray2;
  vtp: TVarDynArray;
  i, j, k, m, idd: Integer;
  st, st1: string;
  dt1, dt2, dt: TDateTime;
  f1, f2: Extended;
  v: Variant;
  t1, t2, t3, t4, tp, tn, tob1, tob2: extended;
  id_vyh, id_otp: Variant;
  b, isoffice: Boolean;
  setprev: Boolean;

  f: TIniFile;
  ParsecConnectionString : string;
begin
//  QExecSql('update turv_day set begtime = null, endtime = null where id_division = 4 and dt >= :dt$d', incday(Date, -1));
  //берем с начала прошлого периода турв
//  dt1:=GetTurvBegDate(IncDay(GetTurvBegDate(Date), -1));
  //первая дата - за 3 дня до начала текущего периода ТУРВ (можно бы за 3 дня до последнего успешного выполнения этой задачи)
  dt1:=IncDay(GetTurvBegDate(Date), -3);
  //вторая дата - конец текущих суток
  dt2:=IncMilliSecond(IncDay(Date, 1), -1);
  vdiv:=Q.QLoadToVarDynArray2('select id from ref_divisions where office = 1', []);
  id_vyh:=Q.QSelectOneRow('select id from ref_turvcodes where code = ''В''', [])[0];
  if id_vyh = null then id_vyh:=-1;
  id_otp:=Q.QSelectOneRow('select id from ref_turvcodes where code = ''ОТ''', [])[0];
  if id_otp = null then id_vyh:=-1;
  //бухгалтерия=4, кпп=27, станки = 16
  vt:=Q.QLoadToVarDynArray2(
    'select dt, id_worker, begtime, endtime, id_turvcode2, worktime2, nighttime, 0, null, settime3, id_division, 0, null from turv_day '+
    'where '+
//    '(begtime is null or endtime is null) and '+
    'id_division >= 0 and dt >= :dt1$d and dt <= :dt2$d '+
    'order by id_worker, dt',
    [dt1, Date]
  );
  vw:=Q.QLoadToVarDynArray2('select id, workername from v_ref_workers order by id', []);
  //массивы данных по входу и уходу работников
  vpb:=[];
  vpe:=[];

  {
  Такие коды транзакций в БД Парсека

  на проходной ПЩ:
  590152 Фактический вход
  590153 Фактический выход

  в остальных случаях
  590144 Нормальный вход по ключу
  590145 Нормальный выход по ключу
  }

  //айди операций входа и выхода (есть по два события)
  vpops := [[590144, 590152], [590145, 590153]];

  //пытаемся подключиться к парсеку, выходим если не удалось (без диалога ошибки)
  //!!!на 2025-02-27 выдается окно ошибки, через минуту закроется
  if not myDBParsec.Connect(False) then Exit;;

  //два запроса к БД, по событиям входа и выхода
  //время в БД UTC, приводим к Московскому!
  for i:=0 to 1 do begin
    vp:=[];
    vp := myDBParsec.QLoadToVarDynArray2(
    'select '+
    'format(dateadd(hour, 3, t.tran_date), ''dd.MM.yyyy HH:mm'') as dt, '+
    'case '+
    'when tt.trantype_desc = ''Нормальный вход по ключу'' then ''Приход'' '+
    'when tt.trantype_desc = ''Фактический вход'' then ''Приход'' '+
    'when tt.trantype_desc = ''Нормальный выход по ключу'' then ''Уход'' '+
    'when tt.trantype_desc = ''Фактический выход'' then ''Уход'' '+
    'end as event, '+
    'concat(p.last_name, '' '', p.first_name, '' '', p.middle_name) as name '+
    'from '+
    '  parsec3trans.dbo.translog as t '+
    '  left outer join '+
    '  parsec3.dbo.person as p '+
    '  on t.usr_id = p.pers_id '+
    '  left outer join '+
    '  parsec3.dbo.trantypes_desc tt '+
    '  on t.trantype_id = tt.trantype_id '+
    'where '+
    '  ((t.trantype_id = :trantype1$i)or '+
    '  (t.trantype_id = :trantype2$i)) '+
    '  and '+
    '  (tt.locale = ''RU'') '+
    '  and '+
    '  t.tran_date >= :dt1$d ' +
    '  and '+
    '  t.tran_date <= :dt2$d ' +
    'order by tran_date asc '
    ,
    [vpops[i][0], vpops[i][1], IncHour(dt1, -3), IncHour(dt2, -3)]
    );
    if i=0 then vpb:=copy(vp) else vpe:=copy(vp)
  end;
//Sys.SaveArray2ToFile(vpb, 'r:\vpb', False); Sys.SaveArray2ToFile(vpe, 'r:\vpe'); exit;

(*
  //получим данные по приходу и уходу (590144 - приход)

  //!!!ПАРАМЕТРЫ СОЕДИНЕНИЯ С ПАРСЕК ПОКА УСТАНОВИМ ЗДЕСЬ!!!
    if FileExists(ExtractFilePath(ParamStr(0)) + '\parsec.udl') then begin
    f:=TIniFile.Create(ExtractFilePath(ParamStr(0)) + '\parsec.udl');
    ParsecConnectionString:='Provider=' + f.ReadString('oledb', 'Provider', '');
    MyData.CnParsec.ConnectionString:= ParsecConnectionString;
    MyData.CnParsec.LoginPrompt:= False;
    MyData.CnParsecEh.InlineConnection.ConnectionString:= ParsecConnectionString;
    MyData.CnParsecEh.InlineConnection.LoginPrompt:= False;
    f.Free;
  end;

{
на проходной ПЩ:
590152 Фактический вход
590153 Фактический выход

в остальных случаях
590144 Нормальный вход по ключу
590145 Нормальный выход по ключу
}

  //айди операций входа и выхода
  vpops := [[590144, 590152], [590145, 590153]];

  for i:=0 to 1 do begin
  vp:=[];
  MyData.QParsec.Close;
  MyData.QParsec.SQL.Text:=
  'select '+
  'format(dateadd(hour, 3, t.tran_date), ''dd.MM.yyyy HH:mm'') as dt, '+
  'case '+
  'when tt.trantype_desc = ''Нормальный вход по ключу'' then ''Приход'' '+
  'when tt.trantype_desc = ''Нормальный выход по ключу'' then ''Уход'' '+
  'end as event, '+
  'concat(p.last_name, '' '', p.first_name, '' '', p.middle_name) as name '+
  'from '+
  '  parsec3trans.dbo.translog as t '+
  '  left outer join '+
  '  parsec3.dbo.person as p '+
  '  on t.usr_id = p.pers_id '+
  '  left outer join '+
  '  parsec3.dbo.trantypes_desc tt '+
  '  on t.trantype_id = tt.trantype_id '+
  'where '+
  '  ((t.trantype_id = :trantype1)or '+
  '  (t.trantype_id = :trantype2)) '+
  '  and '+
  '  (tt.locale = ''RU'') '+
  '  and '+
  '  t.tran_date >= :dt1 ' +
  '  and '+
  '  t.tran_date <= :dt2 ' +
   'order by tran_date asc '
  ;
    MyData.QParsec.Parameters[0].DataType:=ftInteger;
    MyData.QParsec.Parameters[0].Value:=vpops[i][0];
    MyData.QParsec.Parameters[1].DataType:=ftInteger;
    MyData.QParsec.Parameters[1].Value:=vpops[i][1];
    MyData.QParsec.Parameters[2].DataType:=ftDateTime;
    MyData.QParsec.Parameters[2].Value:=IncHour(dt1, -3);
    MyData.QParsec.Parameters[3].DataType:=ftDateTime;
    MyData.QParsec.Parameters[3].Value:=IncHour(dt2, -3);
    try
    MyData.QParsec.Open;
    except
    end;
    if not MyData.QParsec.Connection.Connected then Exit;
    while not MyData.QParsec.EOF do begin
      SetLength(vp, Length(vp) + 1);
      SetLength(vp[High(vp)], MyData.QParsec.FieldCount);
      for j:=0 to MyData.QParsec.FieldCount-1
        do vp[High(vp)][j]:=MyData.QParsec.Fields[j].AsVariant;
      MyData.QParsec.Next;
    end;
    if i=0 then vpb:=copy(vp) else vpe:=copy(vp)
  end;
  except
  end;
  if MyData.QParsec.Active
    then MyData.QParsec.Close
    else Exit;

Sys.SaveArray2ToFile(vpb, 'r:\vpb');
Sys.SaveArray2ToFile(vpe, 'r:\vpe');


exit;


*)

















  //найдем времена прихода и ухода работников по данным парсек
//    'select dt, id_worker, begtime, endtime, id_turvcode3, worktime3, nighttime, 0, null from turv_day where begtime is null or endtime is null and id_division = 4 and dt >= :dt1$d and dt <= :dt2$d order by id_worker',
  j:=-1; st:='';
  for i:=0 to High(vt) do begin
//vt[i][2] := null;vt[i][3] := null; //!!! test
      if vt[i][1] <> j then begin
        //если айди работника изменился, то найдем фио этого работника
        st:='';
        for k:=0 to High(vw) do begin
          if vw[k][0] = vt[i][1] then begin
            st:=vw[k][1];
            j:=vw[k][0];
            Break;
          end;
        end;
      end;
      vt[i][8]:=st;
    //для текущего дня не проставляем
    //надо проставлять, тк бывает требууются данные ужде за предыдущий или текущий день!!!
    //if vt[i][0] = Date then Continue;
    //если нет еще данных по времени прихода или ухода
    if (vt[i][2] = null)or(vt[i][3] = null) then begin
      vtp:=[];
      //время прихода
      if (vt[i][2] = null) then begin
        m:=0;
        //найдем время по данным парсек
        for k:=0 to High(vpb) do begin
          if (vpb[k][2] = st)and(Trunc(StrToDateTime(vpb[k][0])) = StrToDate(vt[i][0])) then begin
            inc(m);
            if m = 1 then begin
              //это первое найденное время, его сохраним для турв
              vt[i][2]:=HourOf(StrToDateTime(vpb[k][0]))+(MinuteOf(StrToDateTime(vpb[k][0])) / 100);
              vt[i][7]:=1;
            end;
            //времен больше чем одно, нас интересует только этот факт, выйдем
            //if m > 1 then Break;
            vtp:=vtp + [Copy(vpb[k][0], 12, 5) + 'П'];
          end;
        end;
        //не найдено времени, и это не текущий день, проставим для времени -1
        if (m = 0)and(vt[i][0] < Date) then begin
          vt[i][2]:=-1;
          vt[i][7]:=1;
        end;
        //найдено времен больше 1, и это не тукущий день, проставим зеттиме, чтобы была подсветка
        if (m > 1)and(vt[i][0] < Date) then begin
          vt[i][9]:=1;    //settime3
          vt[i][7]:=1;    //признак изменения ячейки
        end;
      end;
      if (vt[i][3] = null) then begin
        m:=0;
        for k:=0 to High(vpe) do begin
          if (vpe[k][2] = st)and(Trunc(StrToDateTime(vpe[k][0])) = StrToDate(vt[i][0])) then begin
            inc(m);
            if m = 1 then begin
              vt[i][3]:=HourOf(StrToDateTime(vpe[k][0]))+(MinuteOf(StrToDateTime(vpe[k][0])) / 100);
              vt[i][7]:=1;
            end;
//            if m > 1 then Break;
            vtp:=vtp + [Copy(vpb[k][0], 12, 5) + 'У'];
          end;
        end;
        if (m = 0)and(vt[i][0] < Date) then begin
          vt[i][3]:=-1;
          vt[i][7]:=1;
        end;
        if (m > 1)and(vt[i][0] < Date) then begin
          vt[i][9]:=1;
          vt[i][7]:=1;
        end;
      end;
{     if Length(vtp) > 0 then begin
        A.VarDynArraySort(vtp, True);
        vt[i][12]:=A.Implode(vtp, #13#10);
        vt[i][7]:=1;
      end;}
    end;
  end;


  SetLength(vp, 0);
  for i:=0 to High(vt) do begin
    if vt[i][7] = 1 then begin
      SetLength(vp, Length(vp) + 1);
      SetLength(vp[Length(vp)-1], High(vt[i]) + 1);
      for k:=0 to High(vt[i]) do
        vp[Length(vp)-1][k]:=vt[i][k];
    end;
  end;
//  Sys.SaveArray2ToFile(vp, 'r:\1');
//  exit;



  //время прихода и ухода в БД в часах и минутах (они в дробной части)
  //время работы в бд в часах и десятых часа!!!
  //времена t_xx в часах ()и десятых часа!
  //время начала рабочего дня, из настроек модуля, там оно в часах и минутах - целые это часы, а дробная часть минута, напр 8.30!
//  t3:=trunc(S.VarToFloat(S.IIf(IsOffice, 0, Module.W_Dinner_Time_Beg_2))) + frac(S.VarToFloat(S.IIf(IsOffice, 0, Module.W_Dinner_Time_Beg_Diff_2)))/60*100;
  t3:=trunc(Module.GetCfgVar(mycfgWtime_beg_2)) + frac(Module.GetCfgVar(mycfgWtime_beg_2))/60*100;
  //время, если раньше него началась работа, подсветим  ..то учитываем весь период и подсветим
  t4:=Max(t3 - S.VarToFloat(Module.GetCfgVar(mycfgWtime_beg_diff_2)), 0);
//    'select dt, id_worker, begtime, endtime, id_turvcode3, worktime3, nighttime, 0, null, settime3, id_division from turv_day where begtime is null or endtime is null and id_division = 4 and dt >= :dt1$d and dt <= :dt2$d order by id_worker',
  //время окончания обеда по офису, 12ч + время перерыва, в часах и десятых часа
  tob1:=12 + S.VarToFloat(Module.GetCfgVar(mycfgWtime_dinner_1));
  //время окончания обеда по цеху, 12ч + время перерыва, в часах и десятых часа
  tob1:=12 + S.VarToFloat(Module.GetCfgVar(mycfgWtime_dinner_2));
  idd:=-1;
  for i:=0 to High(vt) do begin
    //обрабатываем только те ячейки, где нет ни кода ни времени парсек или же код = В
    //если ранее было изменено время, или если это не последняя в выгрузке, и следующая запись на того же работника, и при этом это следующий день, и при этом было изменено время
    b:=(vt[i][7] = 1) or ((i < High(vt)) and (vt[i][1] = vt[i+1][1]) and
      (DaysBetween(vt[i+1][0], vt[i][0]) = 1) and (vt[i+1][7] = 1));
    //если время и код по парсеку еще не заданы, или же задан выходной но при этом в этот или следующий день были изменения времени прихода/ухода
    if ((vt[i][4] = null)and(vt[i][5] = null))or(((vt[i][4] = id_vyh)or(vt[i][4] = id_otp)) and b) then begin
      //если сменился айди подразделения, узнаем офис ли это
      if vt[i][10]<> idd then begin
        idd:=vt[i][10];
        isoffice:=A.PosInArray(idd, vdiv, 0) >= 0;
      end;
      //если хотя бы одно время из парсек не получено, то не считаем по данной ячеке
      //это значит что ЕЩЕ не получено, если прото не будет времени за данный день но оно уже опрашивалось, то будет -1 в данном времени!!!
      if (vt[i][2] = null)or(vt[i][3] = null) then continue;
      //здесь ранее внесенные в базу, в часах и минутах
      //переведем в часы и десятые часа
      t1:=-1;
      if vt[i][2]<>null then t1:=trunc(vt[i][2]) + frac(vt[i][2])/60*100;
      t2:=-1;
      if vt[i][3]<>null then t2:=trunc(vt[i][3]) + frac(vt[i][3])/60*100;
      //обработка для офиса, попроще
      if isoffice then begin
        if (t1 = -1)and(t2 = -1) then begin
          //нет ни прихода ни ухода - поставим выходной
          //если не было никакого кода, тк может быть еще отпуск
          if vt[i][4] = null then vt[i][4]:=id_vyh;
          vt[i][7]:=1;
        end
        else if (t1 = -1)or(t2 = -1) then begin
          //нет одного времени - поставим 8.00 и подсветим
          vt[i][4]:=null;
          vt[i][5]:=8;
          vt[i][9]:=1;
          vt[i][7]:=1;
        end
        else if (t1 > -1)and(t2 > -1) then begin
          //время начала рабочего дня возьмем максимальное от фактического или 8:00
          t1:=Max(t1, t3);
          //вычтем обед, если время ухода ранее окончания обеда
          tp:=abs(t2-t1);
//tp:=tp - S.IIf(t2 < tob1, 0, S.VarToFloat(Module.GetCfgVar(mycfgWtime_dinner_1)));
          tp:=Max(0.01, tp - S.IIf(t2 < tob1, 0, S.VarToFloat(Module.GetCfgVar(mycfgWtime_dinner_1))));
          //округляем
          if frac(tp) <= 0.33
            then tp:=trunc(tp)
            else if frac(tp) <= 0.83
            then tp:=trunc(tp) + 0.5
              else tp:=trunc(tp) + 1;
          vt[i][4]:=null;
          vt[i][5]:=tp;
          vt[i][7]:=1;
        end;
      end
      //для цеха
      else begin
        tp:=0;
        //предыдущая запись это прошлый день того же работника, и это ночная или суточная смена, пометим, так как это используется для вычисления времени
        if (i > 0) and (vt[i][1] = vt[i-1][1]) and (DaysBetween(vt[i-1][0], vt[i][0]) = 1) and ((vt[i-1][6] <> null) or (vt[i-1][5] >=20))
          then vt[i-1][11] := 1;
        //setprev:=False;
        if (t1 = -1)and(t2 = -1) then begin
          //нет ни прихода ни ухода - поставим выходной, или оставим код, там мог быть отпуск
          if vt[i][4] = null then vt[i][4]:=id_vyh;
          vt[i][7]:=1;
        end
        //есть приход, но нет ухода с работы, или уход раньше прихоода
        //(это будет если каждые сутки работает в ночную смену)
        else if (t1 > -1)and((t2 = -1)or(t2 < t1)) then begin
          //если это не последняя в выгрузке, и следующая запись на того же работника, и при этом это следующий день
          if (i < High(vt)) and (vt[i][1] = vt[i+1][1]) and (DaysBetween(vt[i+1][0], vt[i][0]) = 1) then begin
            if (vt[i+1][3]<>null)and(vt[i+1][3]<>-1) then begin
              t2:=trunc(vt[i+1][3]) + frac(vt[i+1][3])/60*100;
              t2:=t2 + 24;
              //суточная смена, обед не учитываем, не ставим больше 24 часов
              if (t2 - t1 >= 20)and(t2 - t1 <= 26) then begin
                tp:=Min(24, t2 - t1);
                vt[i][11]:=1;
              end
              //ночная смена, обед учитываем
              else if (t2 - t1 <= 14) then begin
                tp:=max(0.01, t2 - t1 - S.VarToFloat(Module.GetCfgVar(mycfgWtime_dinner_2)));
                t1:=max(t1, 22);
                //посчитаем время работы ночью (с 22ч до 6ч), обед в нее не ставится
                tn:=max(t2 - t1, 0);
                //не может быть больше продолжительности всей смены
                tn:=min(tn, tp);
                //округлим
                if frac(tn) <= 0.33
                  then tn:=trunc(tn)
                  else if frac(tn) <= 0.83
                  then tn:=trunc(tn) + 0.5
                    else tn:=trunc(tn) + 1;
                vt[i][6]:=tn;
                vt[i][11]:=1;
              end
              //не вложились по временам - поставим 8 с выделением
              else tp:=-8;
            end
            else if (vt[i+1][3] = -1) then begin
              //на следующий день ухода не было
              tp:=-8;
            end;
          end  //енд тот же работник завтра
          else tp:= -8;
        end  //енд есть приход а уход раньше или нет ухода
        else if (t1 = -1)and(t2 > -1) then begin
          if not((i > 0)and(vt[i-1][11] = 1))
            then tp:=-8
            else begin
              vt[i][4]:=id_vyh;
              vt[i][7]:=1;
            end;
        end
        else if (t1 > -1)and(t2 > -1) then begin
          //есть и приход и уход
          //время начала рабочего дня возьмем максимальное от фактического или 8:00
          t1:=Max(t1, t3);
          //вычтем обед
          tp:=abs(t2-t1);
          tp:=Max(0.01, tp - S.IIf(t2 < tob2, 0, S.VarToFloat(Module.GetCfgVar(mycfgWtime_dinner_2))));
        end;
        if tp > 0 then begin
          if frac(tp) <= 0.33
            then tp:=trunc(tp)
            else if frac(tp) <= 0.83
            then tp:=trunc(tp) + 0.5
              else tp:=trunc(tp) + 1;
          vt[i][4]:=null;
          vt[i][5]:=tp;
          vt[i][7]:=1;
        end
        else if tp = -8 then begin
          vt[i][4]:=null;
          vt[i][5]:=8;
          vt[i][9]:=1;
          vt[i][7]:=1;
        end;
      end;  //енд цех
    end;
  end;
//ночный и суточный только цеха
//есть сегодня приход, завтра уход
//смены по суткам и ночные только по цеху
//если разница 20-26ч то суточная смена 24ч или меньше, обед не вычитаем (меня за первый день)
//если разница до 14 часов, то смена, ночью у 22 до 6, вычитаем обед
//если не вписывается вэти промежутки то ставим 8ч
//с 8утра (макс 8ч - по парсеку) все, независимо от схемы  Не будет
//округление рабочего времени, и ночной смены до 0.5ч
//подсвечивать несколько входов или выходов, или отсутствие входа и выхода

  //создадим массив, где только измененные данные
  SetLength(vp, 0);
  for i:=0 to High(vt) do begin
    if vt[i][7] = 1 then begin
      SetLength(vp, Length(vp) + 1);
      SetLength(vp[Length(vp)-1], High(vt[i]) + 1);
      for k:=0 to High(vt[i]) do
        vp[Length(vp)-1][k]:=vt[i][k];
    end;
  end;

//  Sys.SaveArray2ToFile(vp, 'r:\111');
//exit;

  //запишем в бд
  Q.QBeginTrans;
  b:=False;
  try
  for i:=0 to High(vp) do begin
//    'select dt, id_worker, begtime, endtime, id_turvcode3, worktime3, nighttime, 0, null, settime3, id_division, 0 from turv_day '+
    Q.QExecSql(
    'update turv_day set begtime = :begtime$f, endtime = :endtime$f, '+
    'id_turvcode2 = :id_turvcode2$i, worktime2 = :worktime2$f, nighttime = :nighttime$f, settime3 = :settime3$i '+
    'where id_worker = :id_worker$i and dt = :dt$d',
    [
      vp[i][2], vp[i][3], vp[i][4], vp[i][5], vp[i][6], vp[i][9],
      vp[i][1], vp[i][0]
    ]
    );
  end;
  b:=True;
  finally
  Q.QCommitOrRollback(b);
  end;
end;


function TTurv.GetDaysFromCalendar(DtBeg, DtEnd: TDateTime): TVarDynArray2;
//вернет двумерный массив последовательныйх дат (за каждый день) и типа рабочий/выходной (0 - выходной, 1 - рабочий) с
//учетом производственного календаря
//[[1.1.23,1], [2.1.23,1],[3.1.23,0]....
var
  i, j: Integer;
  va2: TVarDynArray2;
  dt: TDateTime;
begin
  Result:=[];
  va2:=Q.QLoadToVarDynArray2('select dt, type from ref_holidays where dt >=:dt1$d and dt <=:dt2$d', [DtBeg, DtEnd]);
  dt:=DtBeg;
  while dt <= DtEnd do begin
    Result:=Result + [[dt, 1]];
    if DayOfTheWeek(dt) in [6,7] then Result[High(Result)][1]:=0;
    //1, 'в', 2, 'с', 3, 'р'
    j:= A.PosInArray(dt, va2, 0);
    if (j>=0)and(va2[j][1] = 1) then Result[High(Result)][1]:=0;
    if (j>=0)and(va2[j][1] > 1) then Result[High(Result)][1]:=1;
    dt:=IncDay(dt, 1);
  end;
end;

function TTurv.GetDaysFromCalendar_Next(DtBeg: TDateTime; CntOfWork: Integer): TDateTime;
//вернет ближайший рабочий день, отстоящий от переданной даты на CntOfWork  (+ - вперед, - назад)
//!!НЕТ т.е. CntOfWork = количество рабочих дней, считая текущий
//!!НЕТ напр сегодня вт, -1 и +1 будет вт -2 будет пн, -3 будет пт, но если сегодня сб, то -1 будет пт
//0 всегда возвращает текущий день, неважно рабочий он или нет
//-1 вернет вчерашний, если он был рабочий, а если вчера была суббота, то вернет пятницу.
//то есть CntOfWork количество рабочих дней, не считая текущий (не важно рабочий он или нет), которые надо прибавить/отнять к текущей дате
var
  i, j: Integer;
  va2: TVarDynArray2;
  dt: TDateTime;
begin
  Result:=DtBeg;
  if CntOfWork = 0 then Exit;
  j:=0;
  if CntOfWork > 0
    then begin
      va2:=GetDaysFromCalendar(DtBeg, IncDay(DtBeg, CntOfWork + (CntOfWork div 7) * 2 + 20));
      for i:=0 to High(va2) do begin
        if va2[i][1] = 1 then inc(j);
        if j = CntOfWork then Break;
      end;
    end
    else begin
      va2:=GetDaysFromCalendar(IncDay(DtBeg, -(CntOfWork + (CntOfWork div 7) * 2 + 20)), DtBeg);
      for i:=High(va2)-1 downto 0 do begin
        if va2[i][1] = 1 then inc(j);
        if j = -CntOfWork then Break;
      end;
    end;
  Result:=va2[i][0];
end;

function TTurv.ExecureWorkCheduledialog(AOwner: TComponent; AId: Variant; AMode: TDialogType): Boolean;
//диалог ввода графика работы и норм рабочего времени по нему
var
  i, j: Integer;
  va11, va12, va13: TVarDynArray;
  va2: TVarDynArray2;
  Id, IdH: Variant;
begin
  Result := False;
  va11 := Q.QSelectOneRow('select dt1, dt2, dt3, dt4 from v_ref_work_schedules where rownum = 1', []);
  va12 := Q.QSelectOneRow('select code, name, hours1, hours2, hours3, hours4, active from v_ref_work_schedules where id = :id$i', [AId]);
  if va12[0] = null then
    va12 := ['', '', null, null, null, null, 1];
  for i := 0 to 3 do
    va2 := va2 + [[cntNEdit, 'С ' + DateToStr(va11[i]), '0:1000:2']];
    if TFrmBasicInput.ShowDialog(AOwner, '', [], AMode, 'График работы', 350, 60,
      [[cntEdit, 'Код', '0:50::T'], [cntEdit, 'Наименование', '0:400::T']] + va2 +  [[cntCheckX, 'Используется', '']],
      va12,
      va13, [['Добавьте или отредактируйте параметра графика работы'#13#10'Задайте нормы рабочего времени по ближайшим периодам для данного графика']], nil
    ) < 0 then Exit;
  Id := Q.QIUD(Q.QFModeToIUD(AMode), 'ref_work_schedules', '', 'id$i;code$s;name$s;active$i', [AId, va13[0], va13[1], va13[6]]);
  if Id = -1 then
    Exit;
  if AMode = fAdd then
    AId := Id;
  for i := 0 to 3 do begin
    IdH := Q.QSelectOneRow('select id from ref_working_hours where id_work_schedule = :id$i and dt = :dt$d', [AId, va11[i]])[0];
    Id := Q.QIUD(S.IIf(IdH = null, 'i', 'u'), 'ref_working_hours', '', 'id$i;id_work_schedule$i;dt$d;hours$f', [IdH, AId, va11[i], va13[2 + i]]);
  end;
  Result := True;
end;




begin
  Turv:=TTurv.Create;
end.
