unit D_WorkerStatus;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, Mask, uData, uForms, uDBOra, uString, uMessages, F_MDIDlg1,
  DateUtils
  ;

type
  TDlg_WorkerStatus = class(TForm_MDIDlg1)
    Cb_Worker: TDBComboBoxEh;
    De_Date: TDBDateTimeEditEh;
    Cb_Status: TDBComboBoxEh;
    Cb_Division: TDBComboBoxEh;
    Cb_Job: TDBComboBoxEh;
    procedure Cb_StatusChange(Sender: TObject);
  private
    { Private declarations }
    a: TVarDynArray2;
    dts : array [1..4] of TDateTime;
    dt1, dt2, dt3, dt4: TDateTime;
    dep: TVarDynArray2;
    function Load: Boolean; override;
    function Save: Boolean; override;
    function VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean; override;
    function AfterPrepare: Boolean; override;
    procedure BtOKClick; override;
    function  VerifyWorker: Boolean;
    procedure CreateDep(dt: TDateTime; id: Integer);
    function  VerifyTurvPeriods: string;
    function  VerifyTurvDays(id_worker: Integer; dt: TDateTime): string;
    function  DeleteTurvDays(id_worker: Integer; dt: TDateTime): string;
  public
    { Public declarations }
  end;

var
  Dlg_WorkerStatus: TDlg_WorkerStatus;

implementation

uses
  uTurv,
  uWindows,
  D_CandidatesFromWorkerStatus
  ;

{$R *.dfm}

function TDlg_WorkerStatus.VerifyWorker: Boolean;
//при добавлении записи
//статус для ранее не бывших или уволенных моржет быть только Принят
//статус для ранее принятых или переведенных не может быть Принят
//дата не может быть меньшей ли равной чем дата в предыдущей записи
//не могут совпадать с предыдущей записью одновременно подразделение и должность
var
  st, msg, msg2: string;
  d: TVarDynArray2;
  idw: Integer;
  v: Variant;
begin
  Result:=False;
  if not Ok then Exit;
  st:='';
  idw:=Cth.GetControlValue(Cb_Worker);
  a:=Turv.GetWorkerStatusArr(idw);
  d:=[];
  if Mode = fAdd then begin
    //добавление записи
    if (Length(a) = 0) and (Cb_Status.Value <> '1') then st:='Для этого работника допустим только статус "Принят"';
    if (st = '') and (high(a) >= 0) then begin
      //по работнику есть уже записи в журнале статусов
      if a[0][0] >= De_Date.Value
        then st:='Изменить статус этого работника можно только на дату позднее ' + DateToStr(a[0][0])
        else if (a[0][1] = 3) and (Cb_Status.Value <> '1')
          then st:='Для этого работника допустим только статус "Принят"'
          else if ((a[0][1] = 1) or (a[0][1] = 2)) and (Cb_Status.Value = '1') then st:='Для этого работника не допустим статус "Принят"'
            else if (Cb_Status.Value <> '3') and (Trunc(S.NNum(a[0][2]))= Cth.GetControlValue(Cb_Division)) and (Trunc(S.NNum(a[0][3])) = Cth.GetControlValue(Cb_Job))
              then st:='Работник уже числится в этом подразделении и в этой же должности!';
    end;
    if st = '' then begin
      if (Abs(DaysBetween(Cth.GetControlValue(De_Date), Date)) > 31)and(MyQuestionMessage('Дата изменения статуса сильно отличается от текущей! Все равно продолжить?') <> mrYes) then Exit;
      Result:=Turv.ChangeWorkerInTURV(
        Cth.GetControlValue(Cb_Worker), Cth.GetControlValue(Cb_Division), Cth.GetControlValue(Cb_Job), Cth.GetControlValue(De_Date), ID, Cth.GetControlValue(Cb_Status)
      );
      if not Result then Exit;
    end
    else begin
      //если была строка ошибки контроля данных
      Result:= False;
      MyWarningMessage(st);
    end;
    //Exit;
 {   if st = '' then begin
      //если изменение допустимо, соберем затрагиваемые периоды
      //для приема и перевода это отдел из создаваемой записи, для удаления и переовда отдел из последней записи перед создаваемой, дата везда из создаваемой
      if (Cb_Status.Value = '1')or(Cb_Status.Value = '2')
        then CreateDep(De_Date.Value, Cth.GetControlValue(Cb_Division));
      if (Length(a) > 0)and((Cb_Status.Value = '2')or(Cb_Status.Value = '3'))
        then CreateDep(De_Date.Value, Integer(a[0][2]));
    end;}
  end
  else if Mode = fDelete then begin
    //удаление записи
    //проверим на всякий случай последняя ли запись, вдруг не сразу нажали кнопку удаления и была создана еще одна
    v:=Q.QSelectOneRow('select nvl(max(id), -1) from j_worker_status where id_worker = :id$i', [idw])[0];
    if not((v = -1)or(v = id))
      then st:='Эта запись не является последней для данного работника, поэтому не может быть удалена!';
    if st = '' then begin
      //v:=QSelectOneRow('select nvl(max(id), -1) from j_worker_status where id_worker = :id$i', idw)[0];
      if (Abs(DaysBetween(Cth.GetControlValue(De_Date), Date)) > 31)and(MyQuestionMessage('Дата изменения статуса сильно отличается от текущей! Все равно продолжить?') <> mrYes) then Exit;
      v:=Q.QSelectOneRow(
        'select id, id_worker, id_division, id_job, status, dt from v_j_worker_status '+
        'where id_worker = :idw$i and id < :id and rownum = 1',
        [Cth.GetControlValue(Cb_Worker), ID]
      );
      Result:=Turv.ChangeWorkerInTURV(
        Cth.GetControlValue(Cb_Worker), v[2], v[3], Cth.GetControlValue(De_Date), ID, -1
      );
      if not Result then Exit;
    end
    else begin
      //если была строка ошибки контроля данных
      Result:= False;
      MyWarningMessage(st);
    end;
{      else if De_Date.Value < dts[1]
        then st:='Нельзя удалить такую старую запись!';
    if st = '' then begin
      //затрагиваемые периоды, для удаления записи о приеме и переводе это отдел из записи, и для переволда и удаления предыждущий отдел, все с даты в удаляемом документе
      if (Cb_Status.Value = '1')or(Cb_Status.Value = '2')
        then CreateDep(De_Date.Value, Cth.GetControlValue(Cb_Division));
      if (Length(a) > 1)and((Cb_Status.Value = '2')or(Cb_Status.Value = '3'))
        then CreateDep(De_Date.Value, Integer(a[1][2]));
    end;}
  end;
//exit;
{  if st = '' then begin

    //проход по всем турвам для подразделения, которое было перед добавлением строки, и которые начаты позже даты,
    //проверка на закрытие периода и проверка на данные турв
    //проход по всем турвам для нового подразделения, начиная с даты, проверка на закрытие периода и проверка на данные турв
    Msg:=VerifyTurvPeriods;
    Msg2:=VerifyTurvDays(idw, De_Date.Value);
    //были в периоде завершенные турв, или заблокированные пользователями
    if msg<>'' then begin
      MyWarningMessage(msg + #13#10#13#10 + msg2);
      Result := False;
      Exit;
    end;
    //если есть дни со временем, то выведим сообщение, если не Yes то ничего не делаем, окно не закрываем
    if (msg2<>'') and (MyQuestionMessage(msg2 + ' Продолжить?') <> mrYes) then begin
      Result := False;
      Exit;
    end;
    //удаляем turv_day для пользователя старше даты изменения
    msg:=DeleteTurvDays(idw, De_Date.Value);
    if msg<>'' then begin
      //сообщение если не удалось при этом взять блокировку на все турв, в этом случае удалены не будут, и окно не закрываем
      MyWarningMessage(msg);
      Result := False;
    end;
    //вернем тру, что значит закрыть окно и выполнить скл-запрос на применение изменений
    Result:=True;
//    result := False; exit;

    Result:= True;
  end
  else begin
    //если была строка ошибки контроля данных
    Result:= False;
    MyWarningMessage(st);
  end;}
end;

//вернет сообщение, на какие из затрагиваемых периодов установлена блокировка, и какие закрыты
//если сообщение не пустое, то продолжать действие нельзя
function TDlg_WorkerStatus.VerifyTurvPeriods: string;
var
  i, j: Integer;
  id, st: string;
  dt01, dt02: TDatetime;
  b: Boolean;
  v, v1: Variant;
begin
  Result:='';
  for i:= 0 to High(Dep) do begin
    id:=VarToStr(Dep[i][0]) + ' ' + FormatDateTime('yyyymmdd', TDateTime(Dep[i][1])) + ' ' + FormatDateTime('yyyymmdd', TDateTime(Dep[i][2]));
    v:=Q.QSelectOneRow('select login, username from adm_locks where lock_docum = :docum$s and lock_docum_add = :documadd$s', [myfrm_Dlg_Turv, id]);
    if v[0]<> null Then begin
      v1:=Q.QSelectOneRow('select name from ref_divisions where id = :id$i', [Dep[i][0]]);
      Result:=Result + #13#10 + 'ТУРВ по отделу ' + VarToStr(v1[0]) +
      ' за период с ' + DateToStr(TDateTime(Dep[i][1])) + ' по ' + DateToStr(TDateTime(Dep[i][2])) +
      ' заблокирован ' + VarToStr(v[1]) + '.';
    end;
    v:=Q.QSelectOneRow('select id_division, name from v_turv_period where id = :id$s and commit = :commit$i', [id, 1]);
    if v[0]<> null Then
      Result:=Result + #13#10 + 'ТУРВ по отделу ' + VarToStr(v[1]) +
      ' за период с ' + DateToStr(TDateTime(Dep[i][1])) + ' по ' + DateToStr(TDateTime(Dep[i][2])) +
      ' завершен и не может быть изменен!'
  end;
end;

//вернет сообщение, сколько дней из тех, что должны быть удалены, имеют числовое значение
//дни, у которых установлено не рабочее время, а коды турв, не принимаются в расчет
function TDlg_WorkerStatus.VerifyTurvDays(id_worker: Integer; dt: TDateTime): string;
var
  v: Variant;
begin
  Result:='';
  v:=Q.QSelectOneRow(
    'select count(*) from turv_day where (worktime1 is not null or worktime2 is not null or worktime3 is not null) and id_worker = :id_worker$i and dt >= :dt$d',
     [id_worker, dt]);
  if v[0] > 0 then
    Result:='В ТУРВ есть ' + VarToStr(v[0]) + ' дней, по которым проставлено время работы, и которые будут удалены.';
end;

//удалим все дневные турвы работника старше даты
function TDlg_WorkerStatus.DeleteTurvDays(id_worker: Integer; dt: TDateTime): string;
var
  v: Variant;
  b: array of Boolean;
  b1: Boolean;
  i: Integer;
  id: string;
begin
  Result:='';
  SetLength(b, Length(dep));
  b1:=True;
  //попытаемся заблокировать все используемые турвы
  for i:= 0 to High(Dep) do begin
    id:=VarToStr(Dep[i][0]) + ' ' + FormatDateTime('yyyymmdd', TDateTime(Dep[i][1])) + ' ' + FormatDateTime('yyyymmdd', TDateTime(Dep[i][2]));
    b[i]:=Q.DBLock(True, myfrm_Dlg_Turv, id, '')[0];
    b1:=b1 and b[i];
  end;
  if b1 then begin
    Q.QExecSql('delete from turv_day where id_worker = :id_worker$i and dt >= :dt$d', [id_worker, dt], False);
  end
  else Result:='Не удалось заблокировать затрагиваемые ТУРВ для выполнения изменений!';
  //разблокируем, те что были заблокированы
  for i:= 0 to High(Dep) do begin
    id:=VarToStr(Dep[i][0]) + ' ' + FormatDateTime('yyyymmdd', TDateTime(Dep[i][1])) + ' ' + FormatDateTime('yyyymmdd', TDateTime(Dep[i][2]));
    if b[i] then Q.DBLock(False, myfrm_Dlg_Turv, id, '');
  end;
end;



//добавим затрагиваемые ТУРВ
//в массиве [[идб дт1б дт2],[...]]
//так как период допустимых дат определяется тремя турвами, то
//берем турв, в который попадает дата и все последующие до предельной даты
procedure TDlg_WorkerStatus.CreateDep(dt: TDateTime; id: Integer);
var
  i, j, id0: Integer;
  dt01, dt02: TDatetime;
  b: Boolean;
begin
  for i:= 1 to High(dts)-1 do begin
    dt01:=dts[i+1];
    //помещаем в массив, если период закончился позже даты
    if dt01 > dt then begin
      b:=True;
      for j:=0 to High(dep) do
        if (dep[j][0] = id)and(dep[j][1]=dts[i])
          then begin b:=False; Break; end;
      if b then begin
        SetLength(dep, Length(dep)+1);
        dep[High(dep)]:=[id, dts[i], IncDay(dts[i+1], -1)];
      end;
    end;
  end;
end;


procedure TDlg_WorkerStatus.BtOKClick;
begin
  if (Mode = fView) then begin Close; Exit; end;
  Verify(nil);
  if not Bt_Ok.Enabled then Exit;
  if not VerifyWorker then Exit;
//  exit;
//  if not Save then Exit;
  RefreshParentForm;
  Close;
end;

function TDlg_WorkerStatus.VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean;
begin
  Result:=True;
//  if (TControl(Sender).Name = 'Cb_Division')
  Cth.SetErrorMarker(Cb_Division, not((Cb_Division.Value<>'') or (Cb_Status.Value = '3')));
  Cth.SetErrorMarker(Cb_Job, not((Cb_Job.Value<>'') or (Cb_Status.Value = '3')));
  //нельзя задать дату раньше начала предыдущего турв и позже окончания следующего
//  Cth.SetErrorMarker(De_Date, not(Cth.DteValueIsDate(De_Date)) or (De_Date.Value < dts[1]) or (De_Date.Value >= dts[High(dts)]));
end;


procedure TDlg_WorkerStatus.Cb_StatusChange(Sender: TObject);
begin
  if Cb_Status.Value = 3 then begin
    Cb_Division.Value:='';
    Cb_Job.Value:='';
    Cb_Division.Enabled:=False;
    Cb_Job.Enabled:=False;
  end
  else
  begin
    Cb_Division.Enabled:=True;
    Cb_Job.Enabled:=True;
  end;
  inherited;
  ControlOnChange(Sender);
end;

function TDlg_WorkerStatus.Load: Boolean;
var
  v,v1: Variant;
  st: string;
begin
  Result:=False;
  Q.QLoadToDBComboBoxEh('select w.f || '' '' || w.i || '' '' || w.o as name, id from ref_workers w order by name', [], Cb_Worker, cntComboLK);
  Q.QLoadToDBComboBoxEh('select name, id from ref_divisions order by name', [], Cb_Division, cntComboLK);
  Q.QLoadToDBComboBoxEh('select name, id from ref_jobs order by name', [], Cb_Job, cntComboLK);
  Cth.AddToComboBoxEh(Cb_Status, [['Принят', '1'], ['Переведен', '2'], ['Уволен', '3']]);
  if Mode = fAdd
    then v:=VarArrayOf([-1,'','','','',''])
    else v:=Q.QSelectOneRow('select id, id_worker, id_division, id_job, status, dt from v_j_worker_status where id = :id', [ID]);
  if v[0] = null then begin MsgRecordIsDeleted;  Exit; end;
  Cth.SetControlValue(Cb_Worker, v[1]);
  Cth.SetControlValue(Cb_Division, v[2]);
  Cth.SetControlValue(Cb_Job, v[3]);
  Cth.SetControlValue(Cb_Status, v[4]);
  Cth.SetControlValue(De_Date, v[5]);
  if Mode = fDelete then begin
    v1:=Q.QSelectOneRow('select nvl(max(id), -1) from j_worker_status where id_worker = :id$i', [v[1]])[0];
    if not((v1 = -1)or(v1 = id)) then begin
      MyWarningMessage('Эта запись не является последней для данного работника, поэтому не может быть удалена!');
      Exit;
    end;
  end;
  //параметры проверки контролов - все обязательны
  Cth.SetControlsVerification(
    [Cb_Worker, Cb_Division, Cb_Job, Cb_Status, De_Date],
    ['1:400', '1:400', '1:400', '1:400', '1']
  );
  Cth.DlgSetControlsEnabled(Self, Mode, [], []);
  Cb_Division.Enabled:=(Cb_Status.Value <> '3') and (Mode = fAdd);
  Cb_Job.Enabled:=Cb_Division.Enabled;
  //даты затрагиваемых турв (начала периодов)
  dts[2]:=TURV.GetTurvBegDate(Date);
  dts[1]:=TURV.GetTurvBegDate(IncDay(dts[2], -1));
  dts[3]:=TURV.GetTurvBegDate(IncDay(dts[2], 17));
  dts[4]:=TURV.GetTurvBegDate(IncDay(dts[3], 17));
  //если передан массив параметров, то зададим поля
  //(если присваиваем свойство текст, которого нет в комбобоксе, то он останется пустым)
  if VarIsArray(AddParam) then begin
    Cb_Worker.Text:=AddParam[0];
    if AddParam[1] <> '' then Cb_Division.Text:=AddParam[1];
    if AddParam[2] <> '' then Cb_Job.Text:=AddParam[2];
    if AddParam[3] <> null then  De_Date.Value:=AddParam[3];
  end;
  Result:=True;
end;

function TDlg_WorkerStatus.AfterPrepare: Boolean;
begin
  Cb_Status.OnChange:=Cb_StatusChange;
  Result:=True;
end;

function TDlg_WorkerStatus.Save: Boolean;
var
  v: TVarDynArray;
  i, j: Integer;
begin
  Result:=False;
  Exit;
  if Mode = fDelete
    then begin
      v:=[ID];
      Result:= (Q.QIUD('d', 'j_worker_status', 'sq_j_worker_status', 'id;name;office;id_head;editusers', v) >= 0);
    end
    else begin
      v:= [ID, Cth.GetControlValue(Cb_Worker), Cth.GetControlValue(Cb_Division), Cth.GetControlValue(Cb_Job), Cth.GetControlValue(Cb_Status), Cth.GetControlValue(De_Date)];
      Result:= (Q.QIUD('i', 'j_worker_status', 'sq_j_worker_status', 'id;id_worker;id_division;id_job;status;dt', v) >= 0);
      if Result then
        Dlg_CandidatesFromWorkerStatus.ShowDialog(v[1], v[4], v[5]);
  end;
end;


end.
