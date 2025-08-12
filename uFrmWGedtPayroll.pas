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
графику работы и нормам за месц и текущий период для работника и пересчитывается сетка.
  данные в сетке (все) - целые, втч турв, а итог округляется до 100р
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
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, Winapi.ShlObj,
  DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls, DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd,
  ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils, Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh
  ;

type
  TFrmWGedtPayroll = class(TFrmBasicGrid2)
    PrintDBGridEh1: TPrintDBGridEh;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Frg1DbGridEh1ApplyFilter(Sender: TObject);
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
    procedure GetDeductionsFromExcel;
    procedure SetButtons;
    procedure SetColumns;
    function  GetCaption(Colored: Boolean = False): string;
    procedure CalculateAll;
    procedure CalculateRow(Row:Integer);
    procedure CalculateBanknotes;
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
  Printers,
  PrViewEH,
  uModule,
  uSys,
  uFrmMain
  ;

const
  cmbtDeduction = 1001;
  cmbtCard = 1002;


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
  Frg1.Options := FrDBGridOptionDef + [myogPanelFind, myogColumnFilter];
  Frg1.Opt.SetFields([
    ['id$i', '_id','40'],
    ['id_worker$i', '_id_worker', wcol],
    ['id_job$i', '_id_job', wcol],
    ['changed$i', '_changed', wcol],
    ['workername$s', 'ФИО', '200;h'],
    ['org_name$s', 'Органиазция', '100'],
    ['personnel_number$s', 'Табельный номер', '60'],
    ['job$s', 'Должность', '150;h'],
    ['blank$i', '~  № бланка', wcol , 'e'],
    ['ball_m$i', '~  Оклад', wcol, 'e'],          //!!!видимость
    ['turv$f', '~  ТУРВ', wcol],
    ['id_schedule$i', '_id_schedule', wcol, fcol],
    ['schedule$s', '~  График', '55'],
    ['norm$f', '_norm', wcol, fcol],
    ['norm_m$f', '_norm_m', wcol, fcol],
    ['ball$i', '~  Расчет' + sLineBreak + '  оклада', wcol, fcol, 'e', FPayrollParams.G('id_method') = 15],
    ['premium_m_src$i', '~  Премия ' + sLineBreak + '  фиксированная', wcol, fcol, 'e'],            //премия за отчетный период, взятая из ТУРВ
    ['premium$i', '~  Премия' + sLineBreak + '  текущая', wcol, fcol, 'e'],                      //премия, сумма дневных премий из турв
    ['premium_p$i', '~  Премия за' + sLineBreak + '  переработки', wcol, fcol],             //премия, за переработку, по формуле
    ['premium_m$i', '~  Премия' + sLineBreak + '   дополнительная', wcol, fcol],                             //премия за отчетный период, вычисляется по формуле или вводится вручную в зарплатной ведомости
    ['otpusk$i', '~  ОТ', wcol, fcol, 'e'],
    ['bl$i', '~  БЛ', wcol, fcol, 'e'],
    ['penalty$i', '~  Штрафы', wcol, fcol],
    ['itog1$i', '~  Итого' + sLineBreak + '  начислено', wcol, fcol],
    ['ud$i', '~  Удержано/' + sLineBreak + '   Исп. лист', wcol, fcol, 'e'],
    ['ndfl$i', '~  НДФЛ', wcol, fcol, 'e'],
    ['fss$i', '~  Выплачено' + sLineBreak + '  ФСС', wcol, fcol, 'e'],
    ['pvkarta$i', '~  Промежуточная' + sLineBreak + '  выплата - карта', wcol, fcol, 'e'],
    ['karta$i', '~  Карта', wcol, fcol, 'e'],
    ['itog$i', '~  Итого к' + sLineBreak + '  получению', wcol, fcol],
    ['banknotes$s', '~  Купюры', '65', 'f=t:t'],
    ['sign$i', '~  Подпись', '55', 'i']
  ]);
  Frg1.Opt.SetGridOperations('u');
  Frg1.DbGridEh1.ReadOnly := (Mode = fView) or (FPayrollParams.G('id_method') = null) or (FPayrollParams.G('commit') = 1);
  Frg1.Opt.SetButtons(1, [
    [mbtSettings],[],[mbtCustom_Turv],[mbtCustom_Payroll],
    [mbtDividorM],
    [2000, True, True, 'Загрузка данных из 1С', '1c'],
    [cmbtCard, True, True, 'Загрузить НДФЛ и карты', 'card'],
    [cmbtDeduction, True, True, 'Загрузить удержания', 'r_minus'],
    [mbtDividorM],
    [],[mbtExcel],
    [mbtDividorM],[mbtPrint],[mbtPrintGrid],[mbtPrintLabels],[mbtDividorM],[],[mbtLock],
    [],
    [mbtCtlPanel]
  ]);
  Frg1.Opt.ButtonsNoAutoState := [0];

  Frg1.CreateAddControls('1', cntLabelClr, GetCaption(True), 'lblDivision', '', 4, yrefT, 800);
  Frg1.CreateAddControls('1', cntLabelClr, '', 'lblInfo', '', 4, yrefB, 800);
  Frg1.SetInitData([], '');

  Frg1.InfoArray := [[
    'Зарплатная ведомость.'#13#10#13#10+
    'Просмотр и редактирование данных для расчета зарплаты работников подразделения.'#13#10+
    'Набор полей может отличаться в зависимости от метода расчета, вводить данные можно в те из них, которые отмечены зеленой полосой.'#13#10+
    'Для расчета заработной платы обязательно нужно выбрать метод расчета для подразделения, если он не был выбран ранее.'#13#10+
    'После этого также в обязательном порядке необходимо загрузить данные из ТУРВ, при этом будут проставлены '#13#10+
    'количества отработанных часов, графики работы, суммы премий. Если с момента редактирования ведомости ТУРВ был '#13#10+
    'изменен, необходимо загрузить данные повторно (если изменения были, то при загрузке будет выдан список этих изменений).'#13#10+
    'В части случаев, надо также загрузить расчет баллов из внешних файлов, что делается по нажатию соответствующей кнопки.'#13#10+
    'Подобным же образом загружаются из файла данные по НДФЛ.'#13#10+
    'После загрузки данные будут пересчитаны.'#13#10+
    'Все поля ведомости сохраняются при закрытии окна (будет выдан запрос на сохранение).'#13#10+
    'Ведомость можно распечатать или сохранить в формате эксель, при этом можно отфильтровать строки для печати по '#13#10+
    'полям "ФИО" или "Бланк".'#13#10+
    ''#13#10
  ]];
  Result := inherited;
  if not Result then
    Exit;

  for i:=0 to Frg1.DbGridEh1.Columns.Count - 1 do
    if not A.InArray(Frg1.DbGridEh1.Columns[i].FieldName, ['blank', 'workername']) then
      Frg1.DBGridEh1.Columns[i].STFilter.Visible:=False;

  //ширина окна по ширине грида
  Self.Width := Frg1.GetTableWidth + 75;

  //если в данной ведомости нет ни одной записи, попробуем их создать
  CreatePayroll;
  //прочитаем из БД ведомость
  GetDataFromDb;
  CalculateBanknotes;
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
    'otpusk, bl, penalty, itog1, ud, ndfl, fss, pvkarta, karta, itog, id_schedule, schedule, norm, norm_m, banknotes, org_name, personnel_number '+
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
        //премия за отчетный период
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
        if Frg1.MemTableEh1.FieldByName('premium').AsVariant <> S.NullIf0(va[j][7]) then begin  //премия текущая, сумма дневных премий из турв
          if Frg1.MemTableEh1.FieldByName('premium').AsVariant <> null then
            st := st + va[j][3] + ': Изменен столбец Премия текущая с ' + Frg1.MemTableEh1.FieldByName('premium').AsString + ' на ' + VarToStr(S.NullIf0(va[j][7])) + #13#10;
          Frg1.MemTableEh1.FieldByName('premium').Value := S.NullIf0(va[j][7]);
          Frg1.MemTableEh1.FieldByName('changed').Value := 1;
          b := True;
        end;
        if True {(FPayrollParams.G('id_method') = 10)} then begin //премия за отчетный период (премия фиксированная), взятая из ТУРВ  (va[9] = премия за отчетный период)
          v2:=Round(S.NNum(va[j][9]) / S.NNum(va[j][12]) * Min(S.NNum(va[j][6]), S.NNum(va[j][12])));  //va[j][12] - норма за текущий период, va[j][6] - часы по турв
          if (Frg1.MemTableEh1.FieldByName('premium_m_src').AsVariant <> S.NullIf0(v2)) then begin
            if Frg1.MemTableEh1.FieldByName('premium_m_src').AsVariant <> null
              then st:=st + va[j][3] + ': Изменен столбец Премия фиксированная с ' + Frg1.MemTableEh1.FieldByName('premium_m_src').AsString + ' на ' + VarToStr(v2) + #13#10;
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
      Mth.PostAndEdit(Frg1.MemTableEh1);
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
            Frg1.MemTableEh1.Edit;
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
    except on E: Exception do begin
        Application.ShowException(E);
        Break;
      end;
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

(*procedure TFrmWGedtPayroll.GetNdflFromExcel;
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
      Frg1.MemTableEh1.Edit;
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
*)

procedure TFrmWGedtPayroll.GetNdflFromExcel;
var
  i, j, k: Integer;
  st, st1: string;
  v, v1, v2: Variant;
  b, b1, b2: Boolean;
  XlsFile: TXlsMemFileEh;
  sh, sh1: TXlsWorksheetEh;
  ArXls: TVarDynArray2;
  EmplCn: TVarDynArray;
  e1, e2: Extended;
begin
  //выберем файл
  MyData.OpenDialog1.Filter := 'файлы Excel (*.xlsx)|*.xlsx';
  if not MyData.OpenDialog1.Execute then
    Exit;
  if not CreateTXlsMemFileEhFromExists(MyData.OpenDialog1.FileName, True, '$2', XlsFile, st) then
    Exit;
  //получим список совместителей
  EmplCn := Q.QLoadToVarDynArrayOneCol('select id from ref_workers where concurrent_employee = 1', []);
  //загрузим в массив данные из эксель со второй строки до первой пустой
  ArXls := [];
  sh := XlsFile.Workbook.Worksheets[0];
  for i := 3 to 2000 do begin
    if (sh.Cells[1 - 1, i].Value.AsString = '') and (sh.Cells[2 - 1, i].Value.AsString = '') then
      Break;
    if (sh.Cells[2 - 1, i].Value.AsString = '') then
      Continue;
    if (High(ArXls) > 0) and (sh.Cells[2 - 1, i].Value.AsString = ArXls[High(ArXls) - 1][0]) and ((sh.Cells[3 - 1, i].Value.AsString = '') or (ArXls[High(ArXls) - 1][1] = '')) then begin
      if sh.Cells[3 - 1, i].Value.AsString <> '' then
        ArXls[High(ArXls) - 1][1] := sh.Cells[3 - 1, i].Value.AsString;
      if sh.Cells[5- 1, i].Value.AsString <> '' then
        ArXls[High(ArXls) - 1][2] := sh.Cells[5- 1, i].Value.AsString;
      if sh.Cells[6- 1, i].Value.AsString <> '' then
        ArXls[High(ArXls) - 1][3] := sh.Cells[6- 1, i].Value.AsString;
    end
    else
      ArXls := ArXls + [[sh.Cells[2 - 1, i].Value.AsString, sh.Cells[3 - 1, i].Value.AsString, sh.Cells[5 - 1, i].Value.AsFloat, sh.Cells[6 - 1, i].Value.AsFloat]];
  end;
  sh.Free;
  XlsFile.Free;
  //пройдем по списку работников в ведомости
  b1 := False;
  b2 := False;
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    //проверим, не совместитель ли
    b := A.InArray(Frg1.GetValueF('id_worker', i, False), EmplCn);
    //пройдем по загруженным из файла даннм
    j := 0;
    while j <= High(ArXls) do begin
      //проверим по свопадению имени и табельного номера, или же только по имени, если совместитель, организацию не учитываем
      if (Frg1.GetValueS('workername', i, False) = ArXls[j][0]) and (b or (Frg1.GetValueS('personnel_number', i, False) = ArXls[j][1])) then begin
        //посмотрим, нет ли заполненного значения для этого работника в других ведомостях за этот же период
        if Q.QSelectOneRow(
            'select count(*) from v_payroll_item where id_worker = :id_worker$i and id_division <> :id_division$i and dt1 = :dt1$d and (ndfl is not null or karta is not null)',
            [Frg1.GetValueF('id_worker', i, False), FPayrollParams.G('id_division'), FPayrollParams.G('dt1')]
          )[0] > 0
        then begin
          //сообщение если есть, и тогда данные не заполняем
          st := st + Frg1.GetValueS('workername', i, False) + ': Найден в другом подпразделении, данные не внесены!' + #13#10;
          b2 := True;
        end
        else begin
          //если нет в других ведомостям, берем данные из файла
          e1 := ArXls[j][2].AsFloat;
          e2 := ArXls[j][3].AsFloat;
          //и если совместитель то просуммируем все строки с таким фио
          if b then
            for k := j + 1 to High(ArXls) do
              if Frg1.GetValueS('workername', i, False) = ArXls[k][0] then begin
                e1 := e1+ ArXls[k][2].AsFloat;
                e2 := e2 + ArXls[k][3].AsFloat;
              end;
          //проверим что полученные данные численно отличаются от того что уже в ведомости
          if Frg1.GetValueF('ndfl', i, False) <> Round(e1) then begin
            //если отличаются - заполним ведомсть, статус из менения, и выдадим сообщение
            st := st + Frg1.GetValueS('workername', i, False) + ': Изменен столбец НДФЛ с ' + Frg1.GetValueS('ndfl', i, False) + ' на ' + VarToStr(S.NullIf0(Round(e1))) + #13#10;
            Frg1.SetValue('ndfl', i, False, S.NullIf0(e1));
            Frg1.SetValue('changed', i, False, 1);
            b1 := True;
          end;
          if Frg1.GetValueF('karta', i, False) <> Round(e2) then begin
            //если отличаются - заполним ведомсть, статус из менения, и выдадим сообщение
            st := st + Frg1.GetValueS('workername', i, False) + ': Изменен столбец Карта с ' + Frg1.GetValueS('karta', i, False) + ' на ' + VarToStr(S.NullIf0(Round(e2))) + #13#10;
            Frg1.SetValue('karta', i, False, S.NullIf0(e2));
            Frg1.SetValue('changed', i, False, 1);
            b1 := True;
          end;
        end;
        Break;
      end;
      inc(j);
    end;
    //проверим, что работник в списке выгрузки не найден
    if j > High(ArXls) then begin
      st := st + Frg1.GetValueS('workername', i, False) + ': Не найден в файлах выгрузки!' + #13#10;
      b2 := True;
    end;
  end;
  //пересчитаем таблицу
  CalculateAll;
  //выведем сообщение
  if b1 or b2 then
    MyInfoMessage('Данные загружены' + S.IIf(b2, ', однако не по всем работникам!', '.') + #13#10#13#10 + S.IIFStr(not b1 and not b2, 'Изменений не было.', st))
  else
    MyInfoMessage('Данные загружены.');
  CheckEmpty;                                                                     cHECKeMPTY;
end;

procedure TFrmWGedtPayroll.GetDeductionsFromExcel;
var
  i, j, k: Integer;
  st, st1: string;
  v, v1, v2: Variant;
  b, b1, b2: Boolean;
  XlsFile: TXlsMemFileEh;
  sh, sh1: TXlsWorksheetEh;
  ArXls: TVarDynArray2;
  EmplCn: TVarDynArray;
  e: Extended;
begin
  //выберем файл
  MyData.OpenDialog1.Filter := 'файлы Excel (*.xlsx)|*.xlsx';
  if not MyData.OpenDialog1.Execute then
    Exit;
  if not CreateTXlsMemFileEhFromExists(MyData.OpenDialog1.FileName, True, '$2', XlsFile, st) then
    Exit;
  //получим список совместителей
  EmplCn := Q.QLoadToVarDynArrayOneCol('select id from ref_workers where concurrent_employee = 1', []);
  //загрузим в массив данные из эксель со второй строки до первой пустой
  ArXls := [];
  sh := XlsFile.Workbook.Worksheets[0];
  for i := 1 to 2000 do begin
    if sh.Cells[1 - 1, i].Value.AsString = '' then
      Break;
    ArXls := ArXls + [[sh.Cells[1 - 1, i].Value.AsString, sh.Cells[2 - 1, i].Value.AsString, sh.Cells[4 - 1, i].Value.AsFloat]];
  end;
  sh.Free;
  XlsFile.Free;
  //пройдем по списку работников в ведомости
  b1 := False;
  b2 := False;
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    //проверим, не совместитель ли
    b := A.InArray(Frg1.GetValueF('id_worker', i, False), EmplCn);
    //пройдем по загруженным из файла даннм
    j := 0;
    while j <= High(ArXls) do begin
      //проверим по свопадению имени и табельного номера, или же только по имени, если совместитель, организацию не учитываем
      if (Frg1.GetValueS('workername', i, False) = ArXls[j][0]) and (b or (Frg1.GetValueS('personnel_number', i, False) = ArXls[j][1])) then begin
        //посмотрим, нет ли заполненного значения для этого работника в других ведомостях за этот же период
        if Q.QSelectOneRow(
            'select count(*) from v_payroll_item where id_worker = :id_worker$i and id_division <> :id_division$i and dt1 = :dt1$d and ud is not null',
            [Frg1.GetValueF('id_worker', i, False), FPayrollParams.G('id_division'), FPayrollParams.G('dt1')]
          )[0] > 0
        then begin
          //сообщение если есть, и тогда данные не заполняем
          st := st + Frg1.GetValueS('workername', i, False) + ': Найден в другом подпразделении, данные не внесены!' + #13#10;
          b2 := True;
        end
        else begin
          //если нет в других ведомостям, берем данные из файла
          e := ArXls[j][2].AsFloat;
          //и если совместитель то просуммируем все строки с таким фио
          if b then
            for k := j + 1 to High(ArXls) do
              if Frg1.GetValueS('workername', i, False) = ArXls[k][0] then
                e := e + ArXls[k][2].AsFloat;
          //проверим что полученные данные численно отличаются от того что уже в ведомости
          if Frg1.GetValueF('ud', i, False) <> Round(e) then begin
            //если отличаются - заполним ведомсть удержание, статус из менения, и выдадим сообщение
            st := st + Frg1.GetValueS('workername', i, False) + ': Изменен столбец Удержано с ' + Frg1.GetValueS('ud', i, False) + ' на ' + VarToStr(S.NullIf0(e)) + #13#10;
            Frg1.SetValue('ud', i, False, S.NullIf0(e));
            Frg1.SetValue('changed', i, False, 1);
            b1 := True;
          end;
        end;
        Break;
      end;
      inc(j);
    end;
    //проверим, что работник в списке выгрузки не найден
    if j > High(ArXls) then begin
      st := st + Frg1.GetValueS('workername', i, False) + ': Не найден в файлах выгрузки!' + #13#10;
      b2 := True;
    end;
  end;
  //пересчитаем таблицу
  CalculateAll;
  //выведем сообщение
  if b1 or b2 then
    MyInfoMessage('Данные загружены' + S.IIf(b2, ', однако не по всем работникам!', '.') + #13#10#13#10 + S.IIFStr(not b1 and not b2, 'Изменений не было.', st))
  else
    MyInfoMessage('Данные загружены.');
  CheckEmpty;                                                                     cHECKeMPTY;
end;


procedure TFrmWGedtPayroll.SetButtons;
var
  i: Integer;
  NoNorms: Boolean;
begin
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtSettings, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtCustom_Turv, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtCustom_Payroll, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtCard, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtDeduction, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtLock, null, False);
  Frg1.DbGridEh1.ReadOnly := True;
  NoNorms:= False;
  for i := 0 to Frg1.GetCount(False) - 1 do
    if (Frg1.GetValueF('norm', i, False) <= 0) or (Frg1.GetValueF('norm_m', i, False) <= 0) then
      NoNorms:= True;
  if Mode = fView then begin
    Frg1.SetControlValue('lblInfo', '$000000Только просмотр.');
  end
  else if FPayrollParams.G('commit') = 1 then begin
    Frg1.SetControlValue('lblInfo', '$00FF00Ведомость закрыта, только просмотр.');
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtLock, null, True);
  end
  else if FPayrollParams.G('id_method') = null then begin
    Frg1.SetControlValue('lblInfo', '$0000FFЗадайте метод расчета!');
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtSettings, null, True);
  end
  else if NoNorms then begin
    Frg1.SetControlValue('lblInfo', '$0000FFНе заданы нормы рабочего времени, выполните загрузку ТУРВ!');
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtCustom_Turv, null, True);
  end
  else begin
    Frg1.SetControlValue('lblInfo', '$FF00FFВвод данных.');
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtSettings, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtCustom_Turv, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtCustom_Payroll, null, Integer(FPayrollParams.G('id_method')) in [13, 14]);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtCard, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtDeduction, null, True);
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
  //!!!Frg1.Opt.SetColFeature('premium_m_src', 'i', not (S.NInt(FPayrollParams.G('id_method')) in [10]), False);
  Frg1.Opt.SetColFeature('ball', 'e', S.NInt(FPayrollParams.G('id_method')) in [15], False);
  Frg1.Opt.SetColFeature('premium_p', 'i', not (S.NInt(FPayrollParams.G('id_method')) in [10]), False);
  Frg1.SetColumnsVisible;
end;

function TFrmWGedtPayroll.GetCaption(Colored: Boolean = False): string;
begin
  Result := S.IIFStr(Colored, '$FF0000') + S.IIf(FPayrollParams.G('workername') <> null, FPayrollParams.G('workername') + ' (' + FPayrollParams.G('divisionname') + ')', FPayrollParams.G('divisionname')) +
    S.IIFStr(Colored, '$000000') + ' с' + S.IIFStr(Colored, '$FF00FF') +' ' + DateToStr(FPayrollParams.G('dt1')) +
    S.IIFStr(Colored, '$000000') + ' по ' + S.IIFStr(Colored,  '$FF00FF') + DateToStr(FPayrollParams.G('dt2'));
end;

procedure TFrmWGedtPayroll.CalculateAll;
var
  i: Integer;
begin
  for i := 0 to Frg1.GetCount(False) - 1 do
    CalculateRow(i);
  CalculateBanknotes;
end;

procedure TFrmWGedtPayroll.CalculateRow(Row: Integer);
var
  e1, e2, e3: extended;
  v1, v2, v3: Variant;
  CalcMode: Integer;
function GetBanknotes: string;
var
  s, i, i1, i2, i3, i4 : Integer;
begin
  Result := '';
  s := Frg1.GetValueI('itog', Row, False);
  if s <= 0 then
    Exit;
  i1 := s div 5000;
  i := s - i1 * 5000;
  i2 := i div 1000;
  i := i - i2 * 1000;
  i3 := i div 500;
  i := i - i3 * 500;
  i4 :=  i div 100;
  Result := IntToStr(i1) + ',' + IntToStr(i2) + ',' + IntToStr(i3) + ',' + IntToStr(i4);
end;
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
  if Row = -1 then
    Row := Frg1.MemTableEh1.RecNo - 1;
  CalcMode := FPayrollParams.G('id_method');
  if (Frg1.GetValueF('norm', Row, False) = 0) or (Frg1.GetValueF('norm_m', Row, False) = 0) or (CalcMode = null) then
    Exit;
  e1 := Frg1.GetValueF('ball_m', Row, False);
  e2 := Frg1.GetValueF('turv', Row, False);
  //посчитаем поле Расчет оклада, как месячный_оклад / месячную_норму_ч * норму_периода_ч
  //если нормы не загружены (грузятся при чтении из турв, обязательно обе), то приведем к 0
  e3 := 0;
  if (CalcMode = 10) or (CalcMode = 12) then begin
    //не больше нормы
    if Frg1.GetValueF('norm_m', Row, False) > 0 then
      e3 := e1 / Frg1.GetValueF('norm_m', Row, False) * Min(Frg1.GetValueF('norm', Row, False), e2);
  end;
  if (CalcMode = 11) then begin
    //полностью
    if Frg1.GetValueF('norm_m', Row, False) > 0 then
      e3 := e1 / Frg1.GetValueF('norm_m', Row, False) * e2;
  end;
  if (CalcMode = 13) or (CalcMode = 14) or (CalcMode = 15) then begin
    //выгрузка из эксель
    e3 := Frg1.GetValueF('ball', Row, False);
  end;
  //установим баллы (Рапсчет оклада)
  v3 := s.IIf(e3 = 0, null, round(e3));
  Frg1.SetValue('ball', Row, False, v3);
  //пермия за переработку
  if (CalcMode = 10) then begin
     // Расчет должен быть такой:   Оклад (55000/2 + 27500) + переработки ( 96-80 + 16 часов)  55000/168*16*1,5 + 7857
    Frg1.SetValue('premium_p', Row, False, Round(Max(0, (e1) / Frg1.GetValueF('norm_m', Row, False) * Max(Frg1.GetValueF('turv', Row, False) - Frg1.GetValueF('norm', Row, False), 0) * 1.5)));
  end
  else
    Frg1.SetValue('premium_p', Row, False, null);
  //расчитаем левую часть, до итого начислено
  e3 := Frg1.GetValueF('ball', Row, False) + Frg1.GetValueF('premium_m_src', Row, False) + Frg1.GetValueF('premium_p', Row, False) + Frg1.GetValueF('premium_m', Row, False) + Frg1.GetValueF('premium', Row, False) + Frg1.GetValueF('otpusk', Row, False) + Frg1.GetValueF('bl', Row, False) - Frg1.GetValueF('penalty', Row, False);
  Frg1.SetValue('itog1', Row, False, s.IIf(e3 = 0, null, round(e3)));
  //расчитаем итог
  e3 := Frg1.GetValueF('itog1', Row, False) - Frg1.GetValueF('ud', Row, False) - Frg1.GetValueF('ndfl', Row, False) - Frg1.GetValueF('fss', Row, False) - Frg1.GetValueF('pvkarta', Row, False) - Frg1.GetValueF('karta', Row, False);
  //итог - округлим до сотен
  Frg1.SetValue('itog', Row, False, s.IIf(e3 = 0, null, roundto(e3, 2)));
  Frg1.SetValue('banknotes', Row, False, GetBanknotes);
  Frg1.DbGridEh1.Invalidate;
  Mth.PostAndEdit(Frg1.MemTableEh1);
end;

procedure TFrmWGedtPayroll.CalculateBanknotes;
//подсчет итогового количества банкнот (только по отфильтрованным строкам!)
var
  i: Integer;
  va1, va2: TVarDynArray;
begin
  va2 := [0, 0, 0, 0];
  for i := 0 to Frg1.GetCount(True) - 1 do begin
    va1 := A.Explode(Frg1.GetValueS('banknotes', i, True), ',');
    if Length(va1) <> 4 then
      Continue;
    va2[0] := va2[0] + Max(StrToInt(va1[0]), 0);
    va2[1] := va2[1] + Max(StrToInt(va1[1]), 0);
    va2[2] := va2[2] + Max(StrToInt(va1[2]), 0);
    va2[3] := va2[3] + Max(StrToInt(va1[3]), 0);
  end;
  Frg1.DBGridEh1.FieldColumns['banknotes'].Footer.Value := A.Implode(va2, ',');
end;

procedure TFrmWGedtPayroll.ClearFilter;
begin
  Gh.GetGridColumn(Frg1.DBGridEh1, 'blank').STFilter.ExpressionStr := '';
  Frg1.DBGridEh1.DefaultApplyFilter;
  Frg1.MemTableEh1.Edit;
end;

procedure TFrmWGedtPayroll.CommitPayroll;
begin
  if MyQuestionMessage(S.IIf(S.NInt(FPayrollParams.G('commit')) = 1, 'Снять статус "Закрыта" для ведомости?', 'Поставить статус "Закрыта" для ведомости?')) <> mrYes then
    Exit;
  FPayrollParams.SetValue(0, 'commit', IIf(S.NInt(FPayrollParams.G('commit')) = 1, 0, 1));
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
  Gh.GetGridColumn(Frg1.DBGridEh1, 'org_name').Visible := False;
  Gh.GetGridColumn(Frg1.DBGridEh1, 'personnel_number').Visible := False;
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
  PrintDBGridEh1.BeforeGridText[0] :=  GetCaption;
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
  Gh.GetGridColumn(Frg1.DBGridEh1, 'org_name').Visible := True;
  Gh.GetGridColumn(Frg1.DBGridEh1, 'personnel_number').Visible := True;
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
  Gh.GetGridColumn(Frg1.DBGridEh1, 'blank').Visible := False;
  Gh.GetGridColumn(Frg1.DBGridEh1, 'org_name').Visible := False;
  Gh.GetGridColumn(Frg1.DBGridEh1, 'personnel_number').Visible := False;
  Gh.GetGridColumn(Frg1.DBGridEh1, 'sign').Visible := True;
  Rep.PasteBand('HEADER');
  Rep.SetValue('#TITLE#', GetCaption);
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
  Rep.SetValue('#banknotes#', Frg1.DBGridEh1.FieldColumns['banknotes'].Footer.Value);
  Rep.DeleteCol1;
  Rep.Show;
  Rep.Free;
  Gh.GetGridColumn(Frg1.DBGridEh1, 'blank').Visible := True;
  Gh.GetGridColumn(Frg1.DBGridEh1, 'org_name').Visible := True;
  Gh.GetGridColumn(Frg1.DBGridEh1, 'personnel_number').Visible := True;
  Gh.GetGridColumn(Frg1.DBGridEh1, 'sign').Visible := False;
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
  va, va1, va2, va3: TVarDynArray;
  n: Variant;
  rn, i: Integer;
  st: string;
begin
  va1 := Q.QLoadToVarDynArrayOneCol('select name from payroll_method order by name', []);
  va2 := Q.QLoadToVarDynArrayOneCol('select id from payroll_method order by name', []);
  va3 := Q.QLoadToVarDynArrayOneCol('select comm from payroll_method order by name', []);
  st := 'Выберите метод расчета заработной платы'#13#10'(выбранный метод сохранится и будет использоваться и в будущих ведомостях):'#13#10#13#10;
  for i := 0 to High(va1) do
    st := st + va1[i] + #13#10'  ' + va3[i] + #13#10#13#10;
  if TFrmBasicInput.ShowDialog(FrmMain, '', [], fEdit, '~Метод расчета з/п', 300, 60,
    [[cntComboLK,'Метод','1:400:0']],
    [VarArrayOf([FPayrollParams.G('id_method'), VarArrayOf(va1), VarArrayOf(va2)])] , va, [[st]], nil
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
  Q.QExecSql('update payroll set id_method = :id_method$i, commit = :commit$i where id = :id$i', [FPayrollParams.G('id_method'), s.IIf(FPayrollParams.G('commit') = 1, 1, null), ID]);
  //удалим из БД всех, кого удаляли из списка при нажатии кнопки ТУРВ
  //может удалить лишних, если вперемешку формировались ведомости, включая по отдельным работникам, и менялись турв
  for i := 0 to High(FDeletedWorkers) do begin
    Q.QExecSql('delete from payroll_item where id_payroll = :id$i and id_worker = :id_worker$i', [id, FDeletedWorkers[i]], False);
  end;
  rn := Frg1.MemTableEh1.RecNo;
  for i := 1 to Frg1.MemTableEh1.RecordCount do begin
    Frg1.MemTableEh1.RecNo := i;
    id1 := s.NNum(Frg1.MemTableEh1.FieldByName('id').AsVariant);
    if id1 = 0 then begin
      Q.QIUD('i', 'payroll_item', 'sq_payroll_item', 'id$i;id_payroll$i;id_division$i;id_worker$i;id_job$i;dt$d',
        [-1, ID, FPayrollParams.G('id_division'), Frg1.MemTableEh1.FieldByName('id_worker').AsInteger, Frg1.MemTableEh1.FieldByName('id_job').AsInteger, FPayrollParams.G('dt1')]
      );
      Frg1.MemTableEh1.Edit;
      Frg1.MemTableEh1.FieldByName('id').Value := Q.LastSequenceId;
      Frg1.MemTableEh1.Post;
      Frg1.MemTableEh1.Edit;
    end;
        //lastgeneraateid
    Q.QIUD('u', 'payroll_item', 'sq_payroll_item',
      'id;blank$f;ball_m$f;turv$f;ball$f;premium_m_src$f;premium_m$f;premium$f;premium_p$f;otpusk$f;bl$f;penalty$f;itog1$f;ud$f;ndfl$f;fss$f;pvkarta$f;karta$f;itog$f;id_schedule$i;norm$f;norm_m$f;banknotes$s',
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
        Frg1.MemTableEh1.FieldByName('norm_m').AsVariant,
        Frg1.MemTableEh1.FieldByName('banknotes').AsVariant
      ], True
    );
  end;
  Q.QCommitOrRollback(True);
  Frg1.MemTableEh1.RecNo:=rn;
end;







{==============================================================================}

procedure TFrmWGedtPayroll.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if A.InArray(FieldName, ['pos', 'workername', 'job', 'org_name', 'personnel_number']) then
      Params.Background := clmyGray;
  //подсветим отрицательные итоги
  if FieldName = 'itog' then
    if Frg2.GetValueF('itog') < 0 then
      Params.Background := clRed;
end;

procedure TFrmWGedtPayroll.Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
//при ручном вводе в ячейке - проставим признак изменения строки
begin
  Frg1.SetValue('changed', 1);
end;

procedure TFrmWGedtPayroll.Frg1DbGridEh1ApplyFilter(Sender: TObject);
//применим фильтр в столбце и пересчитаем итог по банкнотам
begin
  Frg1.DbGridEh1.DefaultApplyFilter;
  CalculateBanknotes;
end;

procedure TFrmWGedtPayroll.Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string);
begin
  if Mode <> dbgvCell then
    Exit;
  CalculateRow(Row - 1);
  CalculateBanknotes;
end;


procedure TFrmWGedtPayroll.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
end;

procedure TFrmWGedtPayroll.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  Handled := True;
  case Tag of
    mbtCustom_Turv:
      if MyQuestionMessage('Загрузить данные из ТУРВ?') = mrYes then
        GetDataFromTurv;
    mbtCustom_Payroll:
      if MyQuestionMessage('Загрузить расчет баллов?') = mrYes then
        GetDataFromExcel;
    cmbtCard:
      if MyQuestionMessage('Загрузить НДФЛ и карты?') = mrYes then
        GetNdflFromExcel;
    cmbtDeduction:
      if MyQuestionMessage('Загрузить удержания?') = mrYes then
        GetDeductionsFromExcel;
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
  else
    Handled := False;
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
