        //!!!предусмотреть вариант, если норма не задана в справочнике графиков работы



{
зарплатная ведомость

  первоначально создается запись в таблице ведомостей по данному подразделений (и, возможно, одному работнику) за данный период
(создается в Dlg_CreatePayroll)
  при первом открытии заполняется строками на основе ТУРВ, строки с одинаковым работником объединяются, должность пишется первая,
работники, по которым есть индивидуальные ведомости не вносятся. расчетные данные заполняются пустыми. но бланка и оклад берутся
из предыдущей ведомости (за прошлый период) по данному подразделению (по всему подразделению). метод расчета берется также из
этой ведомости.
  при нажатии кнопки турв - корректируется список (добавляются записи, которых еще не было, если по ним нет индивидуальных ведомостей,
удаляются из сетки, но не из БД, записи, для которых больше нет строки в турв). загружаются данные по рабочим часам, премиям, штрафам,
и пересчитывается сетка.
  данные в сетке (все) - целые, втч турв, а итог округляется до 10р
  данные сохраняются при закрытии ведомости, включая и изменение настроек, и изменение списка работников в ведомости


ID	NAME	COMM
14	Сборка/станки/реклама/покраска	оклада нет, баллы выгрузка, премии за период нет
13	Конструктора/технологи	оклада нет, баллы выгрузка, премии за период нет
12	Офис, мастер, ОТК	оклад, баллы до нормы, премия за период вручную
11	Наладчик/электрик	оклад, баллы полностью, премия за период вручную
10	Грузчик/упаковщик	оклад, баллы до нормы, премия за отчетный период (формула), премия за переработку (формула)
}

unit uFrmWGedtPayroll;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls,
  DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls, DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd,
  ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils, Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh
  ;

type
  TFrmWGedtPayroll = class(TFrmBasicGrid2)
    PrintDBGridEh1: TPrintDBGridEh;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FPayrollParams: TNamedArr;
    FIsEditable: Boolean;
    FDeletedWorkers: TVarDynArray;
    FColWidth: Integer;
    FIsWorkingHoursDefined: Boolean;
    function  PrepareForm: Boolean; override;
    function  CreatePayroll: Integer;
    function  GetDataFromDb: Integer;
    function  GetDataFromTurv: Integer;
    procedure GetDataFromExcel;
    procedure GetNdflFromExcel;
    procedure SetButtons;
    procedure SetColumns;
    procedure CalculateAll;
    procedure CalculateRow(row:Integer);
    procedure ClearFilter;
    procedure CommitPayroll;
    procedure PrintLabels;
    procedure PrintGrid;
    procedure ExportToXlsxA7;
    procedure CheckEmpty;
    procedure SetPayrollMethod;
    function  IsChanged: Boolean;
    procedure SavePayroll;

    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string); override;
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
  public
  end;

var
  FrmWGedtPayroll: TFrmWGedtPayroll;

implementation

uses
  uTurv,
  uLabelColors2,
  uFrmBasicInput,
  uExcel,
  uPrintReport,
  XlsMemFilesEh,
  D_PayrollSettings,
  Printers,
  PrViewEH,
  uModule,
  uSys
  , uFrmMain;


{$R *.dfm}

function TFrmWGedtPayroll.PrepareForm: Boolean;
var
  i, j, w1: Integer;
  v: Variant;
  wcol, fcol: string;
begin
  Result:=False;

  Caption:='Зарплатная ведомость';
  FOpt.RefreshParent := True;

  if FormDbLock = fNone then Exit;

  Q.QLoadFromQuery('select id, id_division, id_worker, dt1, dt2, divisionname, workername, office, id_method, commit from v_payroll where id = :id$i', [ID], FPayrollParams);
  if FPayrollParams.Count = 0 then begin
    MsgRecordIsDeleted;
    Exit;
  end;

  FDeletedWorkers := [];
  FColWidth := 45;
  wcol := IntToStr(FColWidth) + ';r';
  fcol := 'f=###,###,###:';
  Frg1.Options := FrDBGridOptionDef + [myogPanelFind];
  Frg1.Opt.SetFields([
    ['id$i', '_id','40'],
    ['id_worker$i', '_id_worker', wcol],
    ['id_job$i', '_id_job', wcol],
    ['changed$i', '_changed', wcol],
    ['workername$s', 'ФИО', '200;h'],
    ['job$s', 'Должность', '150;h'],
    ['blank$i', '~  № бланка', wcol , 'e'],
    ['ball_m$i', '~  Оклад', wcol, 'e'],          //!!!видимость
    ['turv$f', '~  ТУРВ', wcol, fcol],
    ['id_schedule$i', '_id_schedule', wcol, fcol],
    ['schedule$s', '~  График', '55'],
    ['norm$f', '_norm', wcol, fcol],
    ['norm_m$f', '_norm_m', wcol, fcol],
    ['ball$i', '~  Расчет' + sLineBreak + '  оклада', wcol, fcol, 'e', FPayrollParams.G('id_method') <> 15],
    ['premium_m_src$i', '~  Премия ' + sLineBreak + '  (грузчики)', wcol, fcol],            //премия за отчетный период, взятая из ТУРВ
    ['premium$i', '~  Премия' + sLineBreak + '  текущая', wcol, fcol],                      //премия, сумма дневных премий из турв
    ['premium_p$i', '~  Премия за' + sLineBreak + '  переработки', wcol, fcol],             //премия, за переработку, по формуле
    ['premium_m$i', '~  Премия' + sLineBreak + '', wcol, fcol],                             //премия за отчетный период, вычисляется по формуле или вводится вручную в зарплатной ведомости
    ['otpusk$i', '~  ОТ', wcol, fcol, 'e'],
    ['bl$i', '~  БЛ', wcol, fcol, 'e'],
    ['penalty$i', '~  Штрафы', wcol, fcol],
    ['itog1$i', '~  Итого' + sLineBreak + '  начислено', wcol, fcol],
    ['ud$i', '~  Удержано', wcol, fcol, 'e'],
    ['ndfl$i', '~  НДФЛ', wcol, fcol, 'e'],
    ['fss$i', '~  Выплачено' + sLineBreak + '  ФСС', wcol, fcol, 'e'],
    ['pvkarta$i', '~  Промежуточная' + sLineBreak + '  выплата - карта', wcol, fcol, 'e'],
    ['karta$i', '~  Карта', wcol, fcol, 'e'],
    ['itog$i', '~  Итого к' + sLineBreak + '  получению', wcol, fcol],
    ['sign$i', '~  Подпись', '55', 'i']
  ]);
  Frg1.Opt.SetGridOperations('u');
  Frg1.DbGridEh1.ReadOnly := (Mode = fView) or (FPayrollParams.G('id_method') = null) or (FPayrollParams.G('commit') = 1);
  Frg1.Opt.SetButtons(1, [
    [mbtSettings],[],[mbtCustom_Turv],[mbtCustom_Payroll],
    [mbtCard, True, True, 'Загрузить НДФЛ и карты'],[],[mbtExcel],
    [mbtDividorM],[mbtPrint],[mbtPrintGrid],[mbtPrintLabels],[mbtDividorM],[],[mbtLock],
    [],
    [mbtCtlPanel]
  ]);
  Frg1.Opt.ButtonsNoAutoState := [0];

//  if (Mode = fView) or (FPayrollParams.G('id_method') = null) or (FPayrollParams.G('commit') = 1) or (A.InArray(TColumnEh(Sender).FieldName,
//['pos', 'workername', 'job', 'itog1', 'itog', 'turv', S.IIf(FPayrollParams.G('id_method') <> 15, 'ball', ''), 'premium', 'premium_m_src', 'premium_p', 'penalty'])) or (not FIsEditable) then begin

  Frg1.CreateAddControls('1', cntLabelClr,
    '$FF0000' + S.IIf(FPayrollParams.G('workername') <> null, FPayrollParams.G('workername') + ' (' + FPayrollParams.G('divisionname') + ')', FPayrollParams.G('divisionname')) +
    '$000000 с$FF00FF ' + DateToStr(FPayrollParams.G('dt1')) + ' $000000 по $FF00FF' + DateToStr(FPayrollParams.G('dt2')),
    'lblDivision', '', 4, yrefT, 800
  );
  Frg1.CreateAddControls('1', cntLabelClr, '', 'lblInfo', '', 4, yrefB, 800);
  Frg1.SetInitData([], '');

  Result := inherited;
  if not Result then
    Exit;
  //Frg1.DBGridEh1.TitleParams.RowHeight := 90;
{  DBGridEh1.STFilter.Visible:=True;
  DBGridEh1.STFilter.Location:=stflInTitleFilterEh;
  for i:=0 to DbGridEh1.Columns.Count - 1 do
    DBGridEh1.Columns[i].STFilter.Visible:=False;
  Gh.GetGridColumn(DBGridEh1, 'blank').STFilter.Visible:=True;}
  //ширина окна по ширине грида
  Self.Width := Frg1.GetTableWidth + 75;

  //если в данной ведомости нет ни одной записи, попробуем их создать
  CreatePayroll;
  //прочитаем из БД ведомость
  GetDataFromDb;
  SetButtons;
  CheckEmpty;

  Result:=True;
end;

function TFrmWGedtPayroll.CreatePayroll: Integer;
//формируем ведомость (список пользователей) на основе ТУРВ по данному отделу (Первоначальное создание)
//вызывается только в случае, если в ведомости нет ни одной строки, при открытии ведомости
//даже если это первое открытие, то список будет перечитан вызовом GetDataFromDb
var
  i, j, k: Integer;
  va, va1, vadel: TVarDynArray2;
  st, st1, st2, w: string;
  v, v1, v2: Variant;
  buf: Variant;
  changed: Boolean;
  size: Integer;
begin
  if Q.QSelectOneRow('select count(*) from payroll_item where id_payroll = :id$i', [id])[0] > 0 then
    Exit;
  //0-дата1, 1-дата2, 2-айди работника, 3-имя работника, 4-фйди профессии, 5-назавание профессии, 6-после периода: 1=переведен 2=уволен
  va := uTurv.Turv.GetTurvArray(FPayrollParams.G('id_division'), FPayrollParams.G('dt1'), False);
  vadel := [[]];
  //уберем повторяющиеся по фио строки
  i := 0;
  j := 0;
  st := '';
  while i < High(va) do begin
    if va[i][3] = st then begin
      delete(va, i, 1);
    end
    else begin
      st := va[i][3];
      inc(i);
    end;
  end;
  if FPayrollParams.G('id_worker') = null then begin
    //если ведомость по подразделению
    // сортировка массива
    repeat
      changed := False;
      for k := 0 to High(va) - 1 do
        if va[k][5] > va[k + 1][5] then begin // обменяем k-й и k+1-й элементы
          for j := 0 to High(va[k]) do begin
            buf := va[k][j];
            va[k][j] := va[k + 1][j];
            va[k + 1][j] := buf;
          end;
          changed := True;
        end;
    until not changed;
    //загрузим айди работников, по которым созданя за этот период отдельные ведомости
    vadel := Q.QLoadToVarDynArray2('select id_worker from v_payroll where id_worker is not null and dt1 = :dt1$d', [FPayrollParams.G('dt1')]);
  end
  else begin
    //удалим все строки, кроме работника по которому ведомость
    for i := High(va) downto 0 do begin
      if va[i][2] <> FPayrollParams.G('id_worker') then
        Delete(va, i, 1);
    end;
  end;
  //загрузим работников из прошлой ведомости по этому же подразделению (по всему подразделению)
  va1:=Q.QLoadToVarDynArray2(
    'select id_worker, blank, ball_m from payroll_item where id_division = :id_division$i and dt = :dt1$d',
    [FPayrollParams.G('id_division'), Turv.GetTurvBegDate(IncDay(FPayrollParams.G('dt1'), -1))]
  );
  //заполним но бланка и баллы за период (оклад) из прошлого периода
  for i := 0 to High(va) do begin
    j := A.PosInArray(va[i][2], va1, 0);
    if j >= 0 then begin
      va[i][5] := va1[j][1];
      va[i][6] := va1[j][2];
    end
    else begin
      va[i][5] := null;
      va[i][6] := null;
    end;
  end;

  //создадим данные по пользователям для данной ведомости в БД (без всех числовых значений)
  //если вдруг в процессе выполнения этой процедуры элементы ведомости в бд будут созданы такие же другим пользователем,
  //то будет ошибка уникальности, здесь ее не выводим
  //после создания, ведомость все равно будет перечитана из БД
  //убрал - но все-таки сделал проверку чтобы не создавались те по которым индивидуальные ведомости, хотя это и не обязательно
  Q.QBeginTrans(True);
  for i := 0 to High(va) do begin
    if not A.PosInArray(va[i][2], vadel, 0) >=0 then
      Q.QIUD('i', 'payroll_item', 'sq_payroll_item', 'id$i;id_payroll$i;id_division$i;id_worker$i;id_job$i;dt$d;blank$f;ball_m$f',
        [-1, ID, Integer(FPayrollParams.G('id_division')), Integer(va[i][2]), Integer(va[i][4]), FPayrollParams.G('dt1'), va[i][5], va[i][6]],
        False
      );
  end;
  if Length(va) > 0 then begin
    Q.QExecSql('update payroll set id_method = (select id_method from payroll where id_division = :id_division$i and dt1 = :dt1$d and id_worker is null) where id = :id$i',
      [FPayrollParams.G('id_division'), Turv.GetTurvBegDate(IncDay(FPayrollParams.G('dt1'), -1)), ID]
    );
  end;
  Q.QCommitOrRollback(True);
end;

function TFrmWGedtPayroll.GetDataFromDb: Integer;
//прочитаем ведомость (все данные) из БД и заполним ими сетку
var
  na : TNamedArr;
begin
  Q.QLoadFromQuery(
    'select workername, job, id, id_worker, id_job, blank, ball_m, turv, ball, premium_m_src, premium, premium_p, premium_m, '+
    'otpusk, bl, penalty, itog1, ud, ndfl, fss, pvkarta, karta, itog, id_schedule, schedule, norm, norm_m '+
    'from v_payroll_item where id_payroll = :id$i order by job, workername',
    [ID], na
  );
  Frg1.LoadData(na);
end;

function TFrmWGedtPayroll.GetDataFromTurv: Integer;
//читаем данные из ТУРВ по нажатию соотв кнопки
var
  i, j, k: Integer;
  va, va1, vadel, norms: TVarDynArray2;
  st, st1, st2, w: string;
  v, v1, v2: Variant;
  buf: Variant;
  changed: Boolean;
  size: Integer;
  e, e1, e2, e3: extended;
  rn : Integer;
  b, b2: Boolean;
begin
  ClearFilter;
  //загрузим айди работников, по которым созданя за этот период отдельные ведомости
  vadel := Q.QLoadToVarDynArray2(
    'select id_worker from v_payroll where id_worker is not null and dt1 = :dt1$d',
    [FPayrollParams.G('dt1')]
  );
  //получим массив ТУРВ по отделу, отсортированную по фио, затем по дате
  //0-дата1, 1-дата2, 2-айди работника, 3-имя работника, 4-фйди профессии, 5-назавание профессии, 6-после периода: 1=переведен 2=уволен
  va := uTurv.Turv.GetTurvArray(FPayrollParams.G('id_division'), FPayrollParams.G('dt1'), False);
  for i := 0 to High(va) do begin
    SetLength(va[i], 15);
    //по каждому работнику (точнее, по каждой строке, тк при разных должностях несколько строк на одного работника)
    //читаем данные из таблицы турв за период, указанный для данной строки
    va1:=Q.QLoadToVarDynArray2(
      'select worktime1, worktime2, worktime3, id_turvcode2, id_turvcode3, premium, penalty from turv_day '+
      'where id_division = :id_division$i and id_worker = :id_worker$i and dt >= :dt1$d  and dt <= :dt2$d',
      [FPayrollParams.G('id_division'), va[i][2], va[i][0], va[i][1]]
    );
    e:=0; e1:=0; e2:=0;
    //проходим по всем датам для доенной строки
    for j := 0 to High(va1) do begin
      //если есть согласованной время или согласованный код, то берем согласованной время (если там согласованный код, то время = нулл, ннум = 0)
      //если же его нет, то берем время по парсеку, оно обязательно должно быть (или код), и принимается в расчет если нет проверенного
      //время руководителя никак не учитываем
      //++для отладки, учитываем время руководителя, иначе трудно отследить
      if (va1[j][2] <> null) or (va1[j][4] <> null) then
        e := e + S.NNum(va1[j][2])
      else if (va1[j][1] <> null) or (va1[j][3] <> null) then
        e := e + S.NNum(va1[j][1])
      else
        e := e + S.NNum(va1[j][0]);
      //премии и штрафы за день
      e1 := e1 + S.NNum(va1[j][5]);
      e2 := e2 + S.NNum(va1[j][6]);
    end;
    //сохраним время в массиве
    va[i][6] := e;
    va[i][7] := e1;
    va[i][8] := e2;
  end;
  //уберем повторяющиеся по фио строки, при этом должность окажется как и нужно - первая по времени
  i := 0;
  j := 0;
  st := '';
  while i < High(va) do begin
    if va[i][3] = st then begin
      //просуммируем время
      va[i - 1][6] := va[i - 1][6] + va[i][6];
      delete(va, i, 1);
    end
    else begin
      st := va[i][3];
      inc(i);
    end;
  end;
  //сортировка массива
  repeat
    changed := False;
    for k := 0 to High(va) - 1 do
      if va[k][5] > va[k + 1][5] then begin
        // обменяем k-й и k+1-й элементы
        for j := 0 to High(va[k]) do begin
          buf := va[k][j];
          va[k][j] := va[k + 1][j];
          va[k + 1][j] := buf;
        end;
        changed := True;
      end;
  until not changed;

  //если ведомость по одному работнику, то удалим из массива всех работников кроме этого
  if FPayrollParams.G('id_worker') <> null then begin
    for i:=High(va) downto 0 do begin
      if va[i][2] <> FPayrollParams.G('id_worker') then Delete(va, i, 1);
    end;
  end;

  //получим из ТУРВ премии за текущий период (для работника за весь турв, но в турве могут быть несколько строк на одного работника, тут получим суммарную)
  //айди графика получит случайно из всех тех что были у работника в периоде//!!!
  va1 := Q.QLoadToVarDynArray2(
    'select id_worker, nvl(sum(premium),0), max(id_schedule_active), max(schedule) from v_turv_workers where id_division = :id_division$i and dt1 = :dt1$d group by id_worker',
    [FPayrollParams.G('id_division'), FPayrollParams.G('dt1')]
  );
  //загрузим нормы по всенм графикам за оба периода месяца к данной ведомости
  norms := Q.QLoadToVarDynArray2(
    'select id_work_schedule, dt, hours from ref_working_hours where dt = :dt1$d or dt = :dt2$d order by id_work_schedule, dt',
    [EncodeDate(YearOf(FPayrollParams.G('dt1')), MonthOf(FPayrollParams.G('dt1')), 1), EncodeDate(YearOf(FPayrollParams.G('dt1')), MonthOf(FPayrollParams.G('dt1')), 16)]
  );
  //заполним премии и нормы по работнику
  for i := 0 to High(va1) do begin
    for j := 0 to High(va) do begin
      if va[j][2] = va1[i][0] then begin
        //премия
        va[j][9] := va1[i][1];
        //график работы  (id_shedule)
        va[j][11] := va1[i][2];
        //норма на данный период
        va[j][12] := -1;
        for k := 0 to High(norms) do
          if (norms[k][0] = va[j][11]) and (norms[k][1] = FPayrollParams.G('dt1')) then
            va[j][12] := norms[k][2];
        //норма на данный календарный месяц
        //!!!предусмотреть вариант, если норма не задана в справочнике графиков работы
        va[j][13] := -1;
        e1 := -1;
        e2 := -1;
        for k := 0 to High(norms) do
          if (norms[k][0] = va[j][11]) and (norms[k][1] = EncodeDate(YearOf(FPayrollParams.G('dt1')), MonthOf(FPayrollParams.G('dt1')), 1)) then
            e1 :=  S.NNum(norms[k][2]);
        for k := 0 to High(norms) do
          if (norms[k][0] = va[j][11]) and (norms[k][1] = EncodeDate(YearOf(FPayrollParams.G('dt1')), MonthOf(FPayrollParams.G('dt1')), 16)) then
            e2 :=  S.NNum(norms[k][2]);
        if (e1 > 0) and (e2 > 0) then
           va[j][13] := e1 + e2
        else begin
          //если хотя бы одна из норма часов за месяц к используемому графику не установлена, сообщим и прекратим расчет!
          MyWarningMessage('Норма рабочего времени не установлена! Заполните справочник "Графики работы".');
          Exit;
        end;
        //график работы, текст
        va[j][14] := '';
        if S.NSt(va1[i][3]) <> '' then
          va[j][14] := va1[i][3] + ' (' + FloatToStr(S.NNum(va[j][12])) + ')';
        Break;
      end;
    end;
  end;

  //заполним таблицу

  st := '';   //строка сообщения
  b := False; //признак изменения таблицы
  rn := Frg1.MemTableEh1.RecNo;
  //проход по мемтейбл
  i := 1;
  Mth.Post(Frg1.MemTableEh1);
  Frg1.MemTableEh1.Edit;
  //номер записи с единицы!!!
  while i <= Frg1.MemTableEh1.RecordCount do begin
    Frg1.MemTableEh1.RecNo := i;
    //проход по массиву турв
    b2 := False;
    for j := 0 to High(va) do begin
      if Frg1.MemTableEh1.FieldByName('workername').AsString = va[j][3] then begin
        Frg1.MemTableEh1.Edit;
        if Frg1.MemTableEh1.FieldByName('job').AsString <> va[j][5] then begin
          Frg1.MemTableEh1.FieldByName('job').Value := va[j][5];
          Frg1.MemTableEh1.FieldByName('changed').Value := 1;
          st := st + va[j][3] + ': Изменена должность.'#13#10;
          b := True;
        end;
        if Frg1.MemTableEh1.FieldByName('turv').AsVariant <> Round(va[j][6]) then begin
          if Frg1.MemTableEh1.FieldByName('turv').AsVariant <> null then
            st := st + va[j][3] + ': Изменен столбец ТУРВ с ' + Frg1.MemTableEh1.FieldByName('turv').AsString + ' на ' + VarToStr(Round(va[j][6])) + #13#10;
          Frg1.MemTableEh1.FieldByName('turv').Value := Round(va[j][6]);
          Frg1.MemTableEh1.FieldByName('changed').Value := 1;
          b := True;
        end;
        if Frg1.MemTableEh1.FieldByName('premium').AsVariant <> S.NullIf0(va[j][7] + va[j][9]) then begin
          if Frg1.MemTableEh1.FieldByName('premium').AsVariant <> null then
            st := st + va[j][3] + ': Изменен столбец Текущая премия с ' + Frg1.MemTableEh1.FieldByName('premium').AsString + ' на ' + VarToStr(S.NullIf0(va[j][7] + va[j][9])) + #13#10;
          Frg1.MemTableEh1.FieldByName('premium').Value := S.NullIf0(va[j][7] + va[j][9]); //!!! +va[j][9]
          Frg1.MemTableEh1.FieldByName('changed').Value := 1;
          b := True;
        end;
        if (FPayrollParams.G('id_method') = 10) then begin
          v2:=Round(S.NNum(va[j][9]) / S.NNum(va[j][12]) * Min(S.NNum(va[j][6]), S.NNum(va[j][12])));  //S.NNum(va[j][12] - норма за текущий период //!!!
          if (Frg1.MemTableEh1.FieldByName('premium_m_src').AsVariant <> S.NullIf0(v2)) then begin
            if Frg1.MemTableEh1.FieldByName('premium_m_src').AsVariant <> null
              then st:=st + va[j][3] + ': Изменен столбец Премия*  с ' + Frg1.MemTableEh1.FieldByName('premium_m_src').AsString + ' на ' + VarToStr(v2) + #13#10;
            Frg1.MemTableEh1.FieldByName('premium_m_src').Value:=S.NullIf0(v2);
            Frg1.MemTableEh1.FieldByName('changed').Value:=1;
            b:=True;
          end;
        end;
        if Frg1.MemTableEh1.FieldByName('penalty').AsVariant <> S.NullIf0(va[j][8]) then begin
          if Frg1.MemTableEh1.FieldByName('penalty').AsVariant <> null then
            st := st + va[j][3] + ': Изменен столбец Штрафы с ' + Frg1.MemTableEh1.FieldByName('penalty').AsString + ' на ' + VarToStr(va[j][8]) + #13#10;
          Frg1.MemTableEh1.FieldByName('penalty').Value := S.NullIf0(va[j][8]);
          Frg1.MemTableEh1.FieldByName('changed').Value := 1;
          b := True;
        end;
        if (Frg1.MemTableEh1.FieldByName('id_schedule').AsInteger <> va[j][11]) or (Frg1.MemTableEh1.FieldByName('schedule').Value <> va[j][14]) then begin
          Frg1.MemTableEh1.FieldByName('id_schedule').Value := va[j][11];
          Frg1.MemTableEh1.FieldByName('schedule').Value := va[j][14];
          Frg1.MemTableEh1.FieldByName('changed').Value := 1;
          st := st + va[j][3] + ': Изменен график работы.'#13#10;
          b := True;
        end;
        if Frg1.MemTableEh1.FieldByName('norm').AsFloat <> va[j][12] then begin
          Frg1.MemTableEh1.FieldByName('norm').Value := va[j][12];
          Frg1.MemTableEh1.FieldByName('changed').Value := 1;
          st := st + va[j][3] + ': Изменена норма.'#13#10;
          b := True;
        end;
        if Frg1.MemTableEh1.FieldByName('norm_m').AsFloat <> va[j][13] then begin
          Frg1.MemTableEh1.FieldByName('norm_m').Value := va[j][13];
          Frg1.MemTableEh1.FieldByName('changed').Value := 1;
          st := st + va[j][3] + ': Изменена норма за месяц.'#13#10;
          b := True;
        end;
        Frg1.MemTableEh1.Post;
        Frg1.MemTableEh1.Edit;
        //признак что эта строка была загружена в грид
        va[j][0] := -1;
        b2 := True;
        Break;
      end;
    end;
    if b2 then
      inc(i)
    else begin
        //в список удаленных работников
      st := st + Frg1.MemTableEh1.FieldByName('workername').AsString + ': Работник удален из ведомости.'#13#10;
      FDeletedWorkers := FDeletedWorkers + [Frg1.MemTableEh1.FieldByName('id_worker').AsInteger];
      Frg1.MemTableEh1.Edit;
      Frg1.MemTableEh1.Delete;
      Frg1.MemTableEh1.Post;
      Frg1.MemTableEh1.Edit;
      b := True;
    end;
  end;
  //пройдем и добавим тех работников, которые не были найдены в ведомости
  for j := 0 to High(va) do
    if va[j][0] <> -1 then begin
      //посмотрим, не создан ли для данного работника индивидуальная ведомость за данный период
      b2 := False;
      for k := 0 to High(vadel) do
        if vadel[k][0] = va[j][2] then begin
          b2 := True;
          Break;
        end;
      //создана, продолжим цикл
      if b2 then
        continue;
      //иначе добавим в конец турв
      Frg1.MemTableEh1.Edit;
      Frg1.MemTableEh1.Append;
      Frg1.MemTableEh1.FieldByName('id_worker').AsString := va[j][2];
      Frg1.MemTableEh1.FieldByName('workername').AsString := va[j][3];
      Frg1.MemTableEh1.FieldByName('turv').Value := va[j][6];
      Frg1.MemTableEh1.FieldByName('id_job').AsString := va[j][4];
      Frg1.MemTableEh1.FieldByName('job').Value := va[j][5];
      Frg1.MemTableEh1.FieldByName('changed').Value := 1;
      Frg1.MemTableEh1.Post;
      Frg1.MemTableEh1.Edit;
      st := st + va[j][3] + ': Работник добавлен в ведомость.'#13#10;
      b := True;
    end;
  //вернем позицию в гридеFrg1.MemTableEh1.RecNo:=rn;
  //пересчитаем таблицу
  CalculateAll;
  Frg1.DBGridEh1.SetFocus;
  //выведем сообщение
  MyInfoMessage('ТУРВ загружен.'#13#10#13#10 + S.IIFStr(b = False, 'Изменений не было.', st));
  Frg1.DbGridEh1.Invalidate;
  CheckEmpty;
end;

procedure TFrmWGedtPayroll.GetDataFromExcel;
var
  i, j, k, emp: Integer;
  va, va1, vadel: TVarDynArray2;
  st, st1, st2, w, FileName, err, fio: string;
  v, v1, v2: Variant;
  buf: Variant;
  changed: Boolean;
  size: Integer;
  e, e1, e2, e3: extended;
  rn: Integer;
  b, b2, res: Boolean;
  XlsFile: TXlsMemFileEh;
  cr: IXlsFileCellsRangeEh;
  sh, sh1: TXlsWorksheetEh;
  cStart, cFIO, cSum: Integer;
  Files: TStringDynArray;
  SR: TSearchRec;
  FindRes: Integer;
  sl: TStrings;
const
  ccStart = 2;
  crSheet = 6;
  crFIO = 7;
  crSum = 9;
  cstMarker = 'Лист итогов';
begin
  res := False;
  st := '';   //строка сообщения
  b := False; //признак изменения таблицы
  b2 := False; //признак наличия незагруженных записей
  err := 'Файл расчета баллов не найден!';
  FileName := '';
  ClearFilter;
  repeat
    sl := TStringList.Create;
    //получим список всех файлов в каталоге из настроек
    Sys.GetFilesInDirectoryRecursive(Module.GetCfgVar(mycfgWpath_to_payrolls), sl);
    //найдем те, вкоторых есть файл типа "Март 1/Сборка 1.xlsx"
    for i := 0 to sl.Count - 1 do begin
      if pos(MonthsRu[MonthOf(FPayrollParams.G('dt1'))] + ' ' + S.IIFStr(DayOf(FPayrollParams.G('dt1')) = 1, '1', '2') + '\' + FPayrollParams.G('divisionname') + '.xlsm', sl[i]) > 0 then
        FileName := sl[i];
    end;
    sl.Free;
    if FileName = '' then
      Break;
    err := 'Файл "' + FileName + '" не является файлом расчета баллов';
    if not CreateTXlsMemFileEhFromExists(FileName, True, '$2', XlsFile, st) then
      Exit;
    try
      sh1 := XlsFile.Workbook.Worksheets['=']; //регистр имеет значение!
      if sh1.Cells[ccStart - 1, crSheet - 1].Value <> cstMarker then
        Break;
      cFIO := sh1.Cells[ccStart, crFio - 1].Value;
      cSum := sh1.Cells[ccStart, crSum - 1].Value;
      st1 := sh1.Cells[ccStart, crSheet - 1].Value;
      for i := 0 to 100 do begin
        if Trim(UpperCase(XlsFile.Workbook.Worksheets[i].Name)) = Trim(UpperCase(st1)) then begin
          sh := XlsFile.Workbook.Worksheets[i];
          Break;
        end;
      end;
      err := 'При загрузке были ошибки!';
      //заполним таблицу
      rn := Frg1.MemTableEh1.RecNo;
      //проход по мемтейбл
      i := 1;
      Mth.Post(Frg1.MemTableEh1);
      Frg1.MemTableEh1.Edit;
      //номер записи с единицы!!!
      while i <= Frg1.MemTableEh1.RecordCount do begin
        Frg1.MemTableEh1.RecNo := i;
        fio := Frg1.MemTableEh1.FieldByName('workername').AsString;
        emp := 0;
        j := 0;
        st1 := '';
        while emp < 300 do begin
          st1 := S.NSt(sh.Cells[cFIO - 1, j].Value);
          if st1 = '' then
            inc(emp)
          else if st1 = fio then
            Break
          else
            emp := 0;
          inc(j);
        end;
        if st1 = fio then begin
          e := Round(sh.Cells[cSum - 1, j].Value);
          if Frg1.MemTableEh1.FieldByName('ball').AsVariant <> e then begin
            if Frg1.MemTableEh1.FieldByName('ball').AsVariant <> null then
              st := st + fio + ': Изменен столбец Баллы с ' + Frg1.MemTableEh1.FieldByName('ball').AsString + ' на ' + VarToStr(e) + #13#10;
            Frg1.MemTableEh1.FieldByName('ball').Value := e;
            Frg1.MemTableEh1.FieldByName('changed').Value := 1;
            Frg1.MemTableEh1.Post;
            Frg1.MemTableEh1.Edit;
            b := True;
          end;
        end
        else begin
          st := st + fio + ': Не найден в файле расчета баллов!' + #13#10;
          b2 := True;
          //!надо ли обнулять баллы?
        end;
        inc(i);
      end;
    except
      Break;
    end;
    sh.Free;
    sh1.Free;
    res := True;
    err := '';
  until True;
  if XlsFile <> nil then
    XlsFile.Free;
  if (err <> '') and (not res) then
    MyWarningMessage(err);
  //вернем позицию в гридеFrg1.MemTableEh1.RecNo:=rn;
  //пересчитаем таблицу
  CalculateAll;
  Frg1.DBGridEh1.SetFocus;
  //выведем сообщение
  if b or b2 then
    MyInfoMessage('Баллы загружены' + S.IIf(b2, ', однако не все работники найдены!', '.') + #13#10#13#10 + S.IIFStr(not b and not b2, 'Изменений не было.', st));
  CheckEmpty;
end;

procedure TFrmWGedtPayroll.GetNdflFromExcel;
//загрузка из файлов данных по ндфл и карте
//в файле данные начинаются со второй строки, 1й столбец - фио, 2й - ндфл, терий - карта
var
  i, j, k, emp: Integer;
  st, st1, st2, w, FileName, err, fio: string;
  v, v1, v2: Variant;
  e, e1, e2, e3: extended;
  rn: Integer;
  b, b2, res: Boolean;
  XlsFile: TXlsMemFileEh;
  cr: IXlsFileCellsRangeEh;
  sh, sh1: TXlsWorksheetEh;
  Files: TStringDynArray;
  sl: TStrings;
  ar: TVarDynArray2;
begin
  MyData.FileOpenDialog1.Options := MyData.FileOpenDialog1.Options + [fdoPickFolders];
  if not MyData.FileOpenDialog1.Execute then
    Exit;
  Files := TDirectory.GetFiles(MyData.FileOpenDialog1.FileName, '*.xlsx');

  ClearFilter;

  Frg1.MemTableEh1.DisableControls;
  SetLength(ar, Frg1.MemTableEh1.RecordCount + 1);
  rn := Frg1.MemTableEh1.RecNo;
  for i := 1 to Frg1.MemTableEh1.RecordCount do begin
    Frg1.MemTableEh1.RecNo := i;
    ar[i] := [Frg1.MemTableEh1.FieldByName('workername').AsString, 0, 0, 0];
  end;

  for k := 0 to High(Files) do begin
    if not CreateTXlsMemFileEhFromExists(Files[k], True, '$2', XlsFile, st) then
      Continue;
    sh := XlsFile.Workbook.Worksheets[0];
    for i := 1 to 2000 do begin
      st := sh.Cells[1 - 1, i].Value;
      if st = '' then
        Break;
      for j := 1 to High(ar) do begin
        if ar[j][0] = st then begin
          ar[j][1] := 1;
          ar[j][2] := ar[j][2] + sh.Cells[2 - 1, i].Value;
          ar[j][3] := ar[j][3] + sh.Cells[3 - 1, i].Value;
        end;
      end;
    end;
    sh.Free;
    XlsFile.Free;
  end;

  st := '';
  b := False;
  b2 := False;
  for i := 1 to Frg1.MemTableEh1.RecordCount do begin
    Frg1.MemTableEh1.RecNo := i;
    Frg1.MemTableEh1.Edit;
    if ar[i][1] = 1 then begin
      if Frg1.MemTableEh1.FieldByName('ndfl').AsVariant <> S.NullIf0(ar[i][2]) then begin
        if Frg1.MemTableEh1.FieldByName('ndfl').AsVariant <> null then
          st := st + ar[i][0] + ': Изменен столбец НДФЛ с ' + Frg1.MemTableEh1.FieldByName('ndfl').AsString + ' на ' + VarToStr(S.NullIf0(ar[i][2])) + #13#10;
        Frg1.MemTableEh1.FieldByName('ndfl').Value := S.NullIf0(ar[i][2]);
        Frg1.MemTableEh1.FieldByName('changed').Value := 1;
        b := True;
      end;
      if Frg1.MemTableEh1.FieldByName('karta').AsVariant <> S.NullIf0(ar[i][3]) then begin
        if Frg1.MemTableEh1.FieldByName('karta').AsVariant <> null then
          st := st + ar[i][0] + ': Изменен столбец Карта с ' + Frg1.MemTableEh1.FieldByName('karta').AsString + ' на ' + VarToStr(S.NullIf0(ar[i][3])) + #13#10;
        Frg1.MemTableEh1.FieldByName('karta').Value := S.NullIf0(ar[i][3]);
        Frg1.MemTableEh1.FieldByName('changed').Value := 1;
        b := True;
      end;
      Frg1.MemTableEh1.Post;
      Frg1.MemTableEh1.Edit;
    end
    else begin
      st := st + ar[i][0] + ': Не найден в файлах выгрузки!' + #13#10;
      b2 := True;
    end;
  end;

  Frg1.MemTableEh1.EnableControls;
  Frg1.MemTableEh1.RecNo := rn;
  //пересчитаем таблицу
  CalculateAll;
  Frg1.DBGridEh1.SetFocus;
  //выведем сообщение
  if b or b2 then
    MyInfoMessage('Данные загружены' + S.IIf(b2, ', однако не все работники найдены!', '.') + #13#10#13#10 + S.IIFStr(not b and not b2, 'Изменений не было.', st));
  CheckEmpty;
end;

procedure TFrmWGedtPayroll.SetButtons;
var
  i: Integer;
  NoNorms: Boolean;
begin
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtSettings, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtCustom_Turv, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtCustom_Payroll, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtCard, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtLock, null, False);
  Frg1.DbGridEh1.ReadOnly := True;
  NoNorms:= False;
  for i := 0 to Frg1.GetCount(False) - 1 do
    if (Frg1.GetValueF('norm', i, False) <= 0) or (Frg1.GetValueF('norm_m', i, False) <= 0) then
      NoNorms:= True;
  if Mode = fView then begin
    Frg1.SetControlValue('lblInfo', '$000000Только просмотр.');
  end
  else if NoNorms then begin
    Frg1.SetControlValue('lblInfo', '$0000FFНе заданы нормы рабочего времени!');
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtCustom_Turv, null, True);
  end
  else if FPayrollParams.G('id_method') = null then begin
    Frg1.SetControlValue('lblInfo', '$0000FFЗадайте метод расчета!');
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtSettings, null, True);
  end
  else if FPayrollParams.G('commit') = 1 then begin
    Frg1.SetControlValue('lblInfo', '$00FF00Ведомость закрыта, только просмотр.');
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtLock, null, True);
  end
  else begin
    Frg1.SetControlValue('lblInfo', '$FF00FFВвод данных.');
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtSettings, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtCustom_Turv, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtCustom_Payroll, null, Integer(FPayrollParams.G('id_method')) in [13, 14]);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtCard, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtLock, null, True);
    Frg1.DbGridEh1.ReadOnly := False;
  end;
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtLock, S.IIf(FPayrollParams.G('commit') = 1, 'Отменить закрытие ведомости', 'Закрыть ведомость'), null);
  SetColumns;
  Frg1.DbGridEh1.Invalidate;
end;

procedure TFrmWGedtPayroll.SetColumns;
//покажем/скроем столбцы в зависимости от метода расчета
begin
  Frg1.Opt.SetColFeature('ball_m', 'i', (S.NInt(FPayrollParams.G('id_method')) in [13, 14]), False);
  Frg1.Opt.SetColFeature('premium_m_src', 'i', not (S.NInt(FPayrollParams.G('id_method')) in [10]), False);
  Frg1.Opt.SetColFeature('premium_p', 'i', not (S.NInt(FPayrollParams.G('id_method')) in [10]), False);
  Frg1.SetColumnsVisible;
end;

procedure TFrmWGedtPayroll.CalculateAll;
var
  i: Integer;
begin
  for i := 0 to Frg1.GetCount(False) - 1 do
    CalculateRow(i);
end;

procedure TFrmWGedtPayroll.CalculateRow(row: Integer);
var
  e1, e2, e3: extended;
  v1, v2, v3: Variant;
  r, CalcMode: Integer;
begin
{
14	Сборка/станки/реклама/покраска	оклада нет, баллы выгрузка, премии за период нет
13	Конструктора/технологи	оклада нет, баллы выгрузка, премии за период нет
12	Офис, мастер, ОТК	оклад, баллы до нормы, премия за период вручную
11	Наладчик/электрик	оклад, баллы полностью, премия за период вручную
10	Грузчик/упаковщик	оклад, баллы до нормы, премия за отчетный период (формула), премия за переработку (формула)

premium - текущая премия, из турв - сумма дневных премий
premium_m - премия за период, вводится вруччную
premium_m_src - премия грузчиков
premium_p - премия за переработку
(премия за период из турв не грузится, точнее только для грузчиков, и так из нее получается расчетная)

}
  if r = -1 then
    r := Frg1.MemTableEh1.RecNo - 1;
  CalcMode := FPayrollParams.G('id_method');
  e1 := Frg1.GetValueF('ball_m', r, False);
  e2 := Frg1.GetValueF('turv', r, False);
  //посчитаем поле Расчет оклада, как месячный_оклад / месячную_норму_ч * норму_периода_ч
  //если нормы не загружены (грузятся при чтении из турв, обязательно обе), то приведем к 0
  if (CalcMode = 10) or (CalcMode = 12) then begin
    //не больше нормы
    e3 := S.IIf(Frg1.GetValueF('norm_m', r, False) = null, 0, e1 / Frg1.GetValueF('norm_m', r, False) * Min(Frg1.GetValueF('norm', r, False) ,e2));
  end;
  if (CalcMode = 11) then begin
    //полностью
    e3 := S.IIf(Frg1.GetValueF('norm_m', r, False) = null, 0, e1 / Min(Frg1.GetValueF('norm_m', r, False), MaxInt) * Frg1.GetValueF('norm', r, False));
  end;
  if (CalcMode = 13) or (CalcMode = 14) or (CalcMode = 15) then begin
    //выгрузка из эксель
    e3 := Frg1.GetValueF('ball', r, False);
  end;
  //установим баллы (Рапсчет оклада)
  v3 := S.IIf(e3 = 0, null, round(e3));
  Frg1.SetValue('ball', r, False, v3);
  //пермия за переработку
  if (CalcMode = 10) then begin
     // Расчет должен быть такой:   Оклад (55000/2 + 27500) + переработки ( 96-80 + 16 часов)  55000/168*16*1,5 + 7857
     Frg1.SetValue('premium_p', r, False, Round(Max(0, (e1) / S.NNum(Frg1.GetValueF('norm_m', r, False) / 2) * (Frg1.GetValueF('turv', r, False) - Frg1.GetValueF('norm', r, False)) * 1.5)));
  end;
  //расчитаем левую часть, до итого начислено
  e3 := Frg1.GetValueF('ball', r, False) + Frg1.GetValueF('premium_m_src', r, False) + Frg1.GetValueF('premium_p', r, False) + Frg1.GetValueF('premium_m', r, False) + Frg1.GetValueF('premium', r, False) + Frg1.GetValueF('otpusk', r, False) + Frg1.GetValueF('bl', r, False) + Frg1.GetValueF('penalty', r, False);
  Frg1.SetValue('itog1', r, False, S.IIf(e3 = 0, null, round(e3)));
  //расчитаем итог
  e3 := Frg1.GetValueF('itog1', r, False) - Frg1.GetValueF('ud', r, False) - Frg1.GetValueF('ndfl', r, False) - Frg1.GetValueF('fss', r, False) - Frg1.GetValueF('pvkarta', r, False) - Frg1.GetValueF('karta', r, False);
  //итог - округлим до сотен
  Frg1.SetValue('itog', r, False, S.IIf(e3 = 0, null, roundto(e3, 2)));
  Frg1.DbGridEh1.Invalidate;
  Mth.PostAndEdit(Frg1.MemTableEh1);
end;


procedure TFrmWGedtPayroll.ClearFilter;
begin
  Gh.GetGridColumn(Frg1.DBGridEh1, 'blank').STFilter.ExpressionStr := '';
  Frg1.DBGridEh1.DefaultApplyFilter;
  Frg1.MemTableEh1.Edit;
end;


procedure TFrmWGedtPayroll.CommitPayroll;
begin
  if MyQuestionMessage(S.IIf(FPayrollParams.G('commit'), 'Снять статус "Закрыта" для ведомости?', 'Поставить статус "Закрыта" для ведомости?')) <> mrYes then
    Exit;
  FPayrollParams.SetValue(0, 'commit', not FPayrollParams.G('commit'));
  SetButtons;
  //установим, как метку что ведомость была изменена, чтобы изменения при выходе записались в бд
  Frg1.SetValue('changed', 0, False, 1);
end;

procedure TFrmWGedtPayroll.PrintLabels;
//печать этикеток на конверты  //пока по F7
begin
  if MyQuestionMessage('Напечатать этикетки?') <> mrYes then
    Exit;
  PrintReport.pnl_PayrollLabels(Frg1.MemTableEh1);
end;

procedure TFrmWGedtPayroll.PrintGrid;
//печать грида
var
  BeforeGridText: TStringsEh;
  i, j, rn: Integer;
  ar: TVarDynArray;
begin
  Gh.GetGridColumn(Frg1.DBGridEh1, 'blank').Visible := False;
  Gh.GetGridColumn(Frg1.DBGridEh1, 'sign').Visible := True;
  rn := Frg1.MemTableEh1.RecNo;
  ar := [];
  SetLength(ar, Frg1.MemTableEh1.Fields.Count + 2);
  //так мы можем скрыть столбцы, которые не имеют данных ни в одной строке
  {
  MemTableEh1.DisableControls;
  for i:=1 to MemTableEh1.RecordCount do begin
    MemTableEh1.RecNo:=i;
    for j:=6 to MemTableEh1.Fields.Count - 1 do
      if MemTableEh1.Fields[j].Value <> null
        then ar[j+1]:=1;
  end;
  MemTableEh1.RecNo:=rn;
  MemTableEh1.EnableControls;
  for i:=DbGridEh1.Columns.count - 3 downto 8 do begin
    if (DbGridEh1.Columns[i].Visible) and (ar[i] <> 1) then begin
      DbGridEh1.Columns[i].Visible:=False;
      ar[i] := 2;
    end;
  end;
  }
  Gh.SetGridOptionsTitleAppearance(Frg1.DBGridEh1, False);
  //Title отображается вторая строка, вместо первой просто полоска, но вторая строка обрезается по высоте, так нечитаемо.
//  PrintDBGridEh1.Title.Clear;  PrintDBGridEh1.Title[0]:=lbl_Caption1.Caption;
  //используем BeforeGridText - форматированная строка
  //получилось только задать текст в редакторе, одну форматированную строку, и здесь ее заменять
//  PrintDBGridEh1.BeforeGridText.Clear; PrintDBGridEh1.BeforeGridText.Delete(0);
//  DBGridEh1.Repaint;
//  i:=Gh.GetGridColumn(DBGridEh1, 'name').Width;
//  Gh.GetGridColumn(DBGridEh1, 'name').Width:=1800;
//  PrintDBGridEh1.Options:=PrintDBGridEh1.Options - [pghFitGridToPageWidth];
   Frg1.PrintDBGridEh1.BeforeGridText[0] :=
     S.IIf(FPayrollParams.G('workername') <> null, FPayrollParams.G('workername') + ' (' + FPayrollParams.G('divisionname') + ')', FPayrollParams.G('divisionname')) +
     ' ' + DateToStr(FPayrollParams.G('dt1')) + ' по ' + DateToStr(FPayrollParams.G('dt2'));
  //альбомная ориентация
  PrinterPreview.Orientation := poLandscape;
  //масштабируем всю таблицу для умещения на стронице
  //но если таблица меньше ширины страницы, то она не реасширится!!!
  PrintDBGridEh1.Options := Frg1.PrintDBGridEh1.Options + [pghFitGridToPageWidth];
//  Gh.GetGridColumn(DBGridEh1, 'name').Width:=i;
  //откроет окно предпросмотра (в нормал)
  //так как здесь не останавливается, а внешний вид таблицы приводится сразу после к прежнему, то при манипуляциях со свойствами через диалог,
  //вид таблицы будет приведен к тому что на экране, те опять скроется подпись, появится бланк (и если другие были изменения для печати)!!!
  //правильнее создавать таблицу на скрытой форме именно для печати, копированием данных
  PrintDBGridEh1.Preview;
//  Timer_Print.Enabled:=True;

//  PrintDBGridEh1.Options:=PrintDBGridEh1.Options + [pghFitGridToPageWidth];
  //покажем скрытые столбцы
//exit;
  for i := Frg1.DbGridEh1.Columns.Count - 3 downto 80 do
    if ar[i] = 2 then
      Frg1.DbGridEh1.Columns[i].Visible := True;
//exit;
  Gh.GetGridColumn(Frg1.DBGridEh1, 'blank').Visible := True;
  Gh.GetGridColumn(Frg1.DBGridEh1, 'sign').Visible := False;
  Gh.SetGridOptionsTitleAppearance(Frg1.DBGridEh1, True);
end;

procedure TFrmWGedtPayroll.ExportToXlsxA7;     //!!! not work
var
  i, j, rn, x, y, y1, y2: Integer;
  Rep: TA7Rep;
  FileName: string;
begin
  FileName := 'Зарплатная ведомость';
  FileName := Module.GetReportFileXlsx(FileName);
  if FileName = '' then
    Exit;
  Rep := TA7Rep.Create;
  try
    Rep.OpenTemplate(FileName);
  except
    Rep.Free;
    Exit;
  end;
  Rep.PasteBand('HEADER');
//!!!  Rep.SetValue('#TITLE#',lbl_Caption1.Caption);
  rn := Frg1.MemTableEh1.RecNo;
  for j := 0 to Frg1.MemTableEh1.Fields.Count - 1 do begin
    Rep.ExcelFind('#d' + IntToStr(j) + '#', x, y, xlValues);
    if x >= 0 then
      Rep.TemplateSheet.Columns[x].Hidden := not Frg1.DBGridEh1.FindFieldColumn(Frg1.MemTableEh1.Fields[j].FieldName).Visible;
    Rep.SetValue('#d' + IntToStr(j) + '#', Frg1.DBGridEh1.FindFieldColumn(Frg1.MemTableEh1.Fields[j].FieldName).Title.Caption);
  end;
  Rep.ExcelFind('  № бланка', x, y, xlValues);
  if x > -1 then
    Rep.TemplateSheet.Columns[x].Hidden := True;
  y1 := -1;
  for i := 1 to Frg1.MemTableEh1.RecordCount do begin
    Frg1.MemTableEh1.RecNo := i;
    Rep.PasteBand('TABLE');
    Rep.ExcelFind('#N#', x, y2, xlValues);
    if y1 = -1 then
      y1 := y2;
    Rep.SetValue('#N#', IntToStr(i));
    for j := 0 to Frg1.MemTableEh1.Fields.Count - 1 do
      Rep.SetValue('#d' + IntToStr(j) + '#', Frg1.MemTableEh1.Fields[j].AsString);
  end;
  Frg1.MemTableEh1.RecNo := rn;
  Rep.PasteBand('FOOTER');
  if (y1 > -1) and (y2 > -1) then
    for j := 0 to Frg1.MemTableEh1.Fields.Count - 1 do
      Rep.SetSumFormula('#d' + IntToStr(j) + '#', y1, y2);
  Rep.DeleteCol1;
  Rep.Show;
  Rep.Free;
end;

function TFrmWGedtPayroll.IsChanged: Boolean;
var
  i: Integer;
begin
  Result := (Length(FDeletedWorkers) > 0);
  if Result then
    Exit;
  for i := 0 to Frg1.GetCount - 1 do begin
    if Frg1.GetValueI('changed', i, False) = 1 then
      Result := True;
  end;
end;

procedure TFrmWGedtPayroll.CheckEmpty;
//проверяем, не пустой ли список
//если пустой, то запрещаем любое редактирование, в том числе нельзя и подгрузить турв, чем обновить список
//ситуация может возникнуть именно после подгрузки турв
//в этом случае ведомость сохранена не будет, и ее можно будет только удалить
begin
  if Frg1.GetCount <> 0 then
    Exit;
  Mode := fView;
  Frg1.DbGridEh1.ReadOnly := True;
  MyInfoMessage('Для этой ведомости не найдена ни одна запись! Вы не можете редактировать эту ведомость, а только удалить ее!');
  SetButtons;
end;

procedure TFrmWGedtPayroll.SetPayrollMethod;
var
  va, va1, va2: TVarDynArray;
  n: Variant;
  rn, i: Integer;
begin
  va1 := Q.QLoadToVarDynArrayOneCol('select name from payroll_method order by name', []);
  va2 := Q.QLoadToVarDynArrayOneCol('select id from payroll_method order by name', []);
  if TFrmBasicInput.ShowDialog(FrmMain, '', [], fEdit, '~Метод расчета з/п', 300, 60,
    [[cntComboLK,'Метод','1:400:0']],
    [VarArrayOf([FPayrollParams.G('id_method'), VarArrayOf(va1), VarArrayOf(va2)])] , va, [['']], nil
  ) < 0 then
    Exit;
  //метод расчета сохраняется при сохранении ведомости
  FPayrollParams.SetValue(0, 'id_method', va[0]);
  //отметим изменённой первую строку, чтобы ведомость запросила сохранение
  Frg1.SetValue('changed', 0, False, 1);
  //пересчитаем ведомость
  CalculateAll;
  SetButtons;
end;

procedure TFrmWGedtPayroll.SavePayroll;
var
  i, j, k, rn: Integer;
  va, vadel: TVarDynArray2;
  st, st1, st2, w: string;
  v, v1, v2: Variant;
  buf: Variant;
  changed: Boolean;
  id1: extended;
begin
  ClearFilter;
  //запишем метод расчета
  Q.QBeginTrans(True);
  Q.QExecSql('update payroll set id_method = :id_method$i, commit = :commit$i where id = :id$i', [FPayrollParams.G('id_method'), S.IIf(FPayrollParams.G('commit') = 1, 1, null), ID]);
  //удалим из БД всех, кого удаляли из списка при нажатии кнопки ТУРВ
  //может удалить лишних, если вперемешку формировались ведомости, включая по отдельным работникам, и менялись турв
  for i:=0 to High(FDeletedWorkers) do begin
    Q.QExecSql('delete from payroll_item where id_payroll = :id$i and id_worker = :id_worker$i', [id, FDeletedWorkers[i]], False);
  end;
  rn:=Frg1.MemTableEh1.RecNo;
  for i:=1 to Frg1.MemTableEh1.RecordCount do begin
    Frg1.MemTableEh1.RecNo:=i;
    id1:=S.NNum(Frg1.MemTableEh1.FieldByName('id').AsVariant);
    if id1 = 0 then begin
      Q.QIUD('i', 'payroll_item', 'sq_payroll_item', 'id;id_payroll;id_division;id_worker;id_job;dt',
        [-1, ID, FPayrollParams.G('id_division'), Frg1.MemTableEh1.FieldByName('id_worker').AsInteger, Frg1.MemTableEh1.FieldByName('id_job').AsInteger, FPayrollParams.G('dt1')],
        False
      );
      Frg1.MemTableEh1.Edit;
      Frg1.MemTableEh1.FieldByName('id').Value:=Q.LastSequenceId;
      Frg1.MemTableEh1.Post;
      Frg1.MemTableEh1.Edit;
    end;
    //lastgeneraateid
    Q.QIUD('u', 'payroll_item', 'sq_payroll_item',
      'id;blank$f;ball_m$f;turv$f;ball$f;premium_m_src$f;premium_m$f;premium$f;premium_p$f;otpusk$f;bl$f;penalty$f;itog1$f;ud$f;ndfl$f;fss$f;pvkarta$f;karta$f;itog$f;id_schedule$i;norm$f;norm_m$f',
      [
        Frg1.MemTableEh1.FieldByName('id').AsInteger,
        Frg1.MemTableEh1.FieldByName('blank').AsVariant,
        Frg1.MemTableEh1.FieldByName('ball_m').AsVariant,
        Frg1.MemTableEh1.FieldByName('turv').AsVariant,
        Frg1.MemTableEh1.FieldByName('ball').AsVariant,
        Frg1.MemTableEh1.FieldByName('premium_m_src').AsVariant,
        Frg1.MemTableEh1.FieldByName('premium_m').AsVariant,
        Frg1.MemTableEh1.FieldByName('premium').AsVariant,
        Frg1.MemTableEh1.FieldByName('premium_p').AsVariant,
        Frg1.MemTableEh1.FieldByName('otpusk').AsVariant,
        Frg1.MemTableEh1.FieldByName('bl').AsVariant,
        Frg1.MemTableEh1.FieldByName('penalty').AsVariant,
        Frg1.MemTableEh1.FieldByName('itog1').AsVariant,
        Frg1.MemTableEh1.FieldByName('ud').AsVariant,
        Frg1.MemTableEh1.FieldByName('ndfl').AsVariant,
        Frg1.MemTableEh1.FieldByName('fss').AsVariant,
        Frg1.MemTableEh1.FieldByName('pvkarta').AsVariant,
        Frg1.MemTableEh1.FieldByName('karta').AsVariant,
        Frg1.MemTableEh1.FieldByName('itog').AsVariant,
        Frg1.MemTableEh1.FieldByName('id_schedule').AsVariant,
        Frg1.MemTableEh1.FieldByName('norm').AsVariant,
        Frg1.MemTableEh1.FieldByName('norm_m').AsVariant
      ], True
    );
  end;
  Q.QCommitOrRollback(True);
  Frg1.MemTableEh1.RecNo:=rn;
end;







{==============================================================================}

procedure TFrmWGedtPayroll.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if A.InArray(FieldName, ['pos', 'workername', 'job']) then
      Params.Background := clmyGray;
  //подсветим отрицательные итоги
  if FieldName = 'itog' then
    if Frg2.GetValueF('itog') < 0 then
      Params.Background := clRed;
end;

procedure TFrmWGedtPayroll.Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
  Frg1.SetValue('changed', 1);
end;

procedure TFrmWGedtPayroll.Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string);
begin
  if Mode <> dbgvCell then
    Exit;
  CalculateRow(Row - 1);
end;


procedure TFrmWGedtPayroll.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
end;

procedure TFrmWGedtPayroll.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  Handled := True;
  case Tag of
    mbtCustom_Turv:
      if MyQuestionMessage('Загрузить данные из ТУРВ?') = mrYes then GetDataFromTurv;
    mbtCustom_Payroll:
      if MyQuestionMessage('Загрузить расчет баллов?') = mrYes then GetDataFromExcel;
    mbtCard:
      if MyQuestionMessage('Загрузить НДФЛ и карты?') = mrYes then GetNdflFromExcel;
    mbtSettings:
      SetPayrollMethod;
    mbtExcel:
      ExportToXlsxA7;
    mbtPrintGrid:
      PrintGrid;
    mbtPrintLabels:
      PrintLabels;
    mbtLock:
      CommitPayroll;
    else Handled := False;
  end;
  if Handled then
    SetButtons;
end;

procedure TFrmWGedtPayroll.FormClose(Sender: TObject; var Action: TCloseAction);
var
  rn, i, res: Integer;
  changed: Boolean;
begin
  inherited;
  //выйдем, если закрытие происходит при подготовке данных, например, из-за нарушения блокировки
  if FInPrepare then Exit;
  ClearFilter;
  if IsChanged then begin
    res:=myMessageDlg('Зарплатная ведомость была изменена!'#13#10'Сохранить данные?', mtConfirmation, mbYesNoCancel);
    if res = mrYes then begin
      SavePayroll;
      RefreshParentForm;
    end
    else if res = mrCancel then begin
      Action:=caNone;
      Exit;
    end;
  end;
end;



end.
