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

unit uFrmWGedtPayroll2N;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls,
  ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls, MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd,
  MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils, Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uTurv
  ;

type
  TFrmWGedtPayroll2N = class(TFrmBasicGrid2)
    PrintDBGridEh1: TPrintDBGridEh;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FPayrollParams: TNamedArr;
    FIsEditable: Boolean;
    FDeletedWorkers: TVarDynArray;
    FColWidth: Integer;
    FIsWorkingHoursDefined: Boolean;
    FTurv: TTurvData;
    FIdTurv: Variant;
    FIsChanged: Boolean;
    FIsListChanged: Boolean;
    FIsEditableAdd, FIsEditableAll: Boolean;
    FIsSecondPeriod: Boolean;
    FNoData: Boolean;
    function  PrepareForm: Boolean; override;
    function  GetDataFromDb: Integer;
    function  GetDataFromDbFirst: Integer;
    function  GetDataFromTurv: Integer;
    procedure GetDataFromExcel;
    procedure LoadPrevCalcMethods;
    procedure SetButtons;
    procedure SetColumns;
    function  GetCaption(Colored: Boolean = False): string;
    procedure CalculateAll;
    procedure CalculateRow(Row:Integer);
    procedure CommitPayroll;
    procedure PrintGrid;
    procedure ExportToXlsxA7;
    procedure SetPayrollMethod;
    procedure SavePayroll;
    procedure SetEditableAll;

    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string); override;
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
  public
  end;

var
  FrmWGedtPayroll2N: TFrmWGedtPayroll2N;

implementation

{$R *.dfm}

uses
  uFrmBasicInput,
  uExcel,
  uPrintReport,
  XlsMemFilesEh,
  Printers,
  PrViewEH,
  uModule,
  uSys,
  uFrmMain,
  uFrmWDedtPayrollCalcMethod
  ;

const
  cmbtDeduction = 1001;
  cmbtCard = 1002;
  cmbRecalculate = 1005;
  cmbSetEditable = 1006;

  cMOffice = 1;
  cMWorkshop = 2;
  cMMotivation = 3;

  cO00 = 1;
  cO10 = 2;
  cO15 = 3;


  cFieldsS =
    'id$i;id_employee$i;id_job$i;id_schedule$i;id_organization$i;personnel_number$s;' +
    'monthly_hours_norm$f;period_hours_norm$f;hours_worked$f;overtime$f;planned_pay$f;fixed_pay$f;variable_pay$f;ors$f;ors_pay$f;base_pay$f;ext_pay$f;overtime_pay$f;' +
    'personal_pay$f;daily_bonus$f;extra_bonus$f;night_pay$f;milk_compensation$f;non_work_pay$f;penalty$f;correction$f;total_pay$f' +
    'from_first_perion$i;period_hours_norm1$f;hours_worked1$f;overtime1$f;ors1$f;ors_pay1$f;base_pay1$f;base_pay2$f;ext_pay1$f;total_pay1$f';
  cFieldsL =
    'employee$s;organization$s;job$s;schedulecode$s;changed$i;temp$i'
    ;

function TFrmWGedtPayroll2N.PrepareForm: Boolean;
var
  i, j, w1: Integer;
  v: Variant;
  wcol, fcol: string;
begin
  Result:=False;

  Caption:='Расчетная ведомость';
  FOpt.RefreshParent := True;

  if FormDbLock = fNone then Exit;

  Q.QLoadFromQuery('select id, id_departament, id_employee, id_organization, personnel_number, dt1, dt2, departament, employee, is_office, calc_method, overtime_method, is_finalized from v_w_payroll_calc where id = :id$i', [ID], FPayrollParams);
  if FPayrollParams.Count = 0 then begin
    MsgRecordIsDeleted;
    Exit;
  end;
  //айди ТУРВ за данный период по данному подразделению
  FIdTurv := Q.QSelectOneRow('select id from w_turv_period where id_departament = :idd$i and dt1 = :dr1$d' ,[FPayrollParams.G('id_departament'), FPayrollParams.G('dt1')])[0];
  FIsSecondPeriod := DayOf(FPayrollParams.G('dt1')) = 16;

  FDeletedWorkers := [];
  Frg1.Options := FrDBGridOptionDef + [myogPanelFind, myogColumnResize] - [myogColumnFilter];

  //определим поля
  //теги (1-редактирования кроме расчета по мотивации, 2-дополнительное редактирование,3-редактировать всегда)
  FColWidth := 45;
  wcol := IntToStr(FColWidth) + ';r';
  fcol := 'f=###,###,###:';
  Frg1.Opt.SetFields([
    ['id$i', '_id','40'],
    ['id_employee$i', '_id_employee', wcol],
    ['id_job$i', '_id_job', wcol],
    ['id_schedule$i', '_id_schedule', wcol, fcol],
    ['id_organization$i', '_id_org', wcol],
    ['changed$i', '_changed', wcol],
    ['from_first_period$i', '_p1', wcol],
    ['temp$i', '_temp', wcol],

    ['employee$s', 'Работник|ФИО', '200;h'],
    ['organization$s', '!Органиазция', '100'],
    ['personnel_number$s', '!Табельный номер', '60'],
    ['job$s', '!Должность', '150;h'],
    ['schedulecode$s', '!График', '70'],

    ['monthly_hours_norm$f', 'ТУРВ|Норма отработанных часов за месяц', 90],
    ['period_hours_norm1$f', '!Норма отработанных часов за 1й период', 90, 't=p1'],
    ['hours_worked1$f', '!Отработано за 1й период', 90, 't=p1'],
    ['overtime1$f', '!Из них переработка', 90, 't=p1'],
    ['period_hours_norm$f', '!Норма отработанных часов за 2й период', 90],
    ['hours_worked$f', '!Отработано за 2й период', 90],
    ['overtime$f', '!Из них переработка', 90],

    ['planned_pay$f', '~Плановое' + sLineBreak + 'начисление', wcol, fcol, 't=1,i1'],
    ['fixed_pay$f', '~Постоянная' + sLineBreak + ' часть', wcol, fcol, 't=1,i1'],
    ['variable_pay$f', '~Стимулирующая', wcol, fcol, 't=1,i1'],
    ['ors1$f', '~ОРС 1', wcol, 't=1,i1,p1'],
    ['ors_pay1$f', '~ОРС 1 сумма', wcol, fcol, 't=1,i1,p1'],
    ['ors$f', '~ОРС 2', wcol, 't=1,i1'],
    ['ors_pay$f', '~ОРС 2 сумма', wcol, fcol, 't=1,i1'],
    ['base_pay1$f', '~Итого' + sLineBreak + ' рассчитано 1', wcol, fcol, 't=p1'],
    ['base_pay2$f', '~Итого' + sLineBreak + ' рассчитано 2', wcol, fcol],
    ['base_pay$f', '~Итого' + sLineBreak + ' рассчитано', wcol, fcol],
    ['ext_pay1$f', '~Мотивация' + sLineBreak + ' 1й период', wcol, fcol, 't=2,p1'],
    ['ext_pay$f', '~Мотивация' + sLineBreak + ' 2й период', wcol, fcol, 't=2'],
    ['total_pay1$f', '~Итого' + sLineBreak + ' начислено ' + sLineBreak + ' за 1й период', wcol, fcol, 't=p1'],
    ['overtime_pay$f', '~Переработка', wcol, fcol],
    ['personal_pay$f', '~Персональная' + sLineBreak + ' надбавка', wcol, fcol, 't=2'],
    ['daily_bonus$f', '~Премия ТУРВ', wcol, fcol],
    ['extra_bonus$f', '~Премия' + sLineBreak + ' дополнительная', wcol, fcol, 't=3'],
    ['night_pay$f', '~Ночные' + sLineBreak + ' часы', wcol, fcol, 't=3'],
    ['milk_compensation$f', '~Надбавка' + sLineBreak + ' за молоко', wcol, fcol, 't=2'],
    ['non_work_pay$f', '~ОТ/БЛ', wcol, fcol, 't=1'],
    ['penalty$f', '~Депремирование', wcol, fcol, 't=2'],
    ['correction$f', '~Корректировка', wcol, fcol, 't=3'],
    ['total_pay$f', '~Итого' + sLineBreak + ' начислено', wcol, fcol]
//    ['$f', '', wcol, fcol],
  ]);
  Frg1.Opt.SetGridOperations('u');
  Frg1.Opt.SetButtons(1, [
    [mbtSettings],[],[mbtCustom_Turv],[mbtCustom_Payroll],
    //[mbtDividorM],[mbtPrint],[mbtPrintGrid],[mbtDividorM],
    [],[mbtLock],
    [], [-mbtExcel, True],
    [],[-cmbSetEditable, True, 'Разрешить редактирование всех полей'],
    [],[-cmbRecalculate, True, 'Пересчитать все'],
    [],[mbtCtlPanel]
  ]);
  Frg1.Opt.ButtonsNoAutoState := [0];

  Frg1.CreateAddControls('1', cntLabelClr, GetCaption(True), 'lblDivision', '', 4, yrefT, 800);
  Frg1.CreateAddControls('1', cntLabelClr, '', 'lblInfo', '', 4, yrefB, 800);
  Frg1.SetInitData([], '');

  Frg1.InfoArray := [[
    'Расчетная ведомость.'#13#10#13#10+
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


  //ширина окна по ширине грида
  Self.Width := Frg1.GetTableWidth + 75;

  //прочитаем из БД ведомость
  GetDataFromDb;
  //если ведомость пуста- выполним первоначальную загрузка по данным турв
  if Frg1.GetCount(False) = 0 then begin
    FNoData := True;
    GetDataFromDbFirst;
    GetDataFromTurv;
    LoadPrevCalcMethods;
    FNoData := False;
  end;
  SetButtons;
  CalculateAll;

  Result:=True;
end;

procedure TFrmWGedtPayroll2N.FormClose(Sender: TObject; var Action: TCloseAction);
var
  rn, i, res: Integer;
  changed: Boolean;
begin
  //выйдем, если закрытие происходит при подготовке данных, например, из-за нарушения блокировки
  if FInPrepare then
   Exit;
  if FIsChanged then begin
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
  inherited;
end;

function TFrmWGedtPayroll2N.GetDataFromDb: Integer;
//прочитаем ведомость (все данные) из БД и заполним ими сетку
var
  na : TNamedArr;
begin
  Q.QLoadFromQuery(Q.QSIUDSql('a', 'v_w_payroll_calc_item', cFieldsS + ';' + cFieldsL) + ' where id_payroll_calc = :id$i order by job, employee, schedulecode, organization, personnel_number',
    [ID], na
  );
  Frg1.LoadData(na);
end;

function  TFrmWGedtPayroll2N.GetDataFromDbFirst: Integer;
var
  na, nadel: TNamedArr;
  flds: string;
  i, j: Integer;
begin
  if Frg1.GetCount(False) <> 0 then
    Exit;
  Q.QLoadFromQuery('select ' +
   'id_employee, id_job, id_schedule, id_organization, personnel_number, monthly_hours_norm, period_hours_norm as period_hours_norm1, ' +
   'employee, organization, job, schedulecode, ' +
   'hours_worked as hours_worked1, overtime as overtime1, ors as ors1, ors_pay as ors_pay1, base_pay as base_pay1, ext_pay as ext_pay1, total_pay as total_pay1, ' +
   'planned_pay, fixed_pay, ' +
   '1 as from_first_period '+
   'from v_w_payroll_calc_item where id_target_departament = :id_target_departament$i and dt1 = :dt1$d',
    [FPayrollParams.G('id_departament'), EncodeDate(YearOf(FPayrollParams.G('dt1')), MonthOf(FPayrollParams.G('dt1')), 1)], na
  );
  Q.QLoadFromQuery(
    'select '+
    '  c.id_employee, c.id_organization, c.personnel_number '+
    'from '+
    '  w_payroll_calc c, '+
    '  v_w_employee_properties p '+
    'where '+
    '  c.id_employee = p.id_employee '+
    '  and c.id_organization = p.id_organization '+
    '  and c.personnel_number = p.personnel_number '+
    '  and (c.dt1 = :dt1$d or c.dt1 = :dt2$d)',
    [FPayrollParams.G('dt1'), EncodeDate(YearOf(FPayrollParams.G('dt1')), MonthOf(FPayrollParams.G('dt1')), 1)] ,
    nadel
  );
  for i := na.High downto 0 do
    for j := 0 to nadel.High do
      if (na.G(i, 'id_employee') = nadel.G(j, 'id_employee')) and (na.G(i, 'id_organization') = nadel.G(j, 'id_organization')) and (na.G(i, 'personnel_number') = nadel.G(j, 'personnel_number')) then begin
        Delete(na.V, i ,1);
        Break;
      end;
  Frg1.LoadData(na);
  if na.Count > 0 then
    FIsChanged := True;
end;

procedure TFrmWGedtPayroll2N.LoadPrevCalcMethods;
var
  na: TNamedArr;
begin
  if (FPayrollParams.G('calc_method') <> null) and (FPayrollParams.G('overtime_method') <> null) then
    Exit;
  Q.QLoadFromQuery('select calc_method, overtime_method from v_w_payroll_calc where id_departament = :id_departament$i and dt1 = :dt1$d',
    [FPayrollParams.G('id_departament'), EncodeDate(YearOf(FPayrollParams.G('dt1')), MonthOf(FPayrollParams.G('dt1')), 1)], na);
  if na.Count = 0 then
    Exit;
  FPayrollParams.SetValue('calc_method', na.G('calc_method'));
  FPayrollParams.SetValue('overtime_method', na.G('overtime_method'));
end;



function TFrmWGedtPayroll2N.GetDataFromTurv: Integer;
//читаем данные из ТУРВ по нажатию соотв кнопки
var
  i, j, k, r: Integer;
  st1, st2, st3: string;
  v1, v2: Variant;
  b: Boolean;
  na, na2, POld: TNamedArr;
  MsgDel, MsgIns, MsgChg: string;
  flds: TVarDynArray2;
  flds1, flds2: TVarDynArray;
  va: TVarDynArray;
  va2: TVarDynArray2;
  WhereSt: string;
begin
  //загружаем данные только в режиме редактирования
  if Mode <> fEdit then
    Exit;

  //поля, по кторым сравниваем для сопоставления данных в турв и гшриде
  flds1 := ['id_employee', 'id_job', 'id_schedule', 'id_organization', 'personnel_number'];
  //поля для заголовка сообщания об изменениях
  flds2 := ['employee', 'job', 'schedulecode', 'organization', 'personnel_number'];
  //поля
  //поле в турв; поле в ведомости; загрузка (1 - FTurv.List.G, 2 - CalculateTotals); сравнивать и выдвать отчеты; если 1, то 0 = null
  flds:=[
    ['job', '', 1, 0, 0],
    ['employee', '', 1, 0, 0],
    ['schedulecode', '', 1, 0, 0],
    ['organization', '', 1, 0, 0],
    ['personnel_number', '', 1, 0, 0],
    ['monthly_hours_norm', '', 1, 1, 0],
    ['period_hours_norm', '', 1, 1, 0],
    ['milk_compensation', '', 2, 1, 1],
    ['worktime', 'hours_worked', 2, 1, 0],
    ['premium', 'daily_bonus', 2, 1, 1],
    ['personal_pay', '', 2, 1, 1],
    ['penalty', '', 2, 1, 1],
    ['overtime', '', 2, 1, 0]
  ];

  //загрузим данные из турв
  //строки в ведомости сгруппированы по f1
  var GroupingSt := 'job;employee;schedulecode;organization;personnel_number';
  if FPayrollParams.G('id_employee') = null then begin
//    va2 := Q.QSelectOneCol(('select id_employee, id_organization, personnel_number from w_payroll_calc where id_employee is not null and dt1 = :dt1$d group by id_employee, id_organization, personnel_number', [dt1]);
    //статусы работников, по которым есть ведомости увольнения (за первый период для ведомости1 и за любой для вендомости2)
    va := Q.QLoadToVarDynArrayOneCol(
      'select '+
      '  p.id '+
      'from '+
      '  w_payroll_calc c, '+
      '  v_w_employee_properties p '+
      'where '+
      '  c.id_employee = p.id_employee '+
      '  and c.id_organization = p.id_organization '+
      '  and c.personnel_number = p.personnel_number '+
      '  and (c.dt1 = :dt1$d or c.dt1 = :dt2$d)',
      [FPayrollParams.G('dt1'), EncodeDate(YearOf(FPayrollParams.G('dt1')), MonthOf(FPayrollParams.G('dt1')), 1)]
    );
    WhereSt := '';
    if Length(va) <> 0 then
      WhereSt := 'and not id in (' + A.Implode(va, ',') + ')';
      FTurv.Create(FIdTurv, GroupingSt, GroupingSt, 0, 0, -1, -1, WhereSt, True, 1);
{    Q.QLoadFromQuery(Q.QSIUDSql('a', 'v_w_payroll_calc_item', cFieldsS + ';' + cFieldsL) + ' where id_departament = :id_departament$i and dt1 := dt1$d',
      [FPayrollParams.G('id_departament'), FPayrollParams.G('dt1')], POld
    );}

  end
  else begin
    WhereSt := 'and id_employee = ' + FPayrollParams.G('id_employee').AsString + ' and nvl(id_organization, -100) = nvl(''' + FPayrollParams.G('id_organization').AsString + ''', -100) ' +
    'and nvl(personnel_number, -100) = nvl(''' + FPayrollParams.G('personnel_number').AsString + ''', -100)';
    FTurv.Create(FIdTurv, GroupingSt, GroupingSt, 0, 0, -1, -1, WhereSt, True, 0);               //по всем, я не только уволенным
  end;

  //заполним то что загружается из турв, остальные данные ранее загруженными из бд, удалим строки из ведомости, которых в турв теперь нет

  //получим для удобства работы данные из грида - они там сейчас те, что загрузились из БД
  na := Frg1.ExportToNa('', False);
  MsgDel := '';
  MsgIns := '';
  MsgChg := '';
  //найдем те строки в гриде, которых более нет в турв
  for i := 0 to na.Count - 1 do begin
    //установим флаг, True если это данные из первого периода
    b := na.G(i, 'from_first_period').AsInteger = 1;
    na.SetValue(i, 'temp', S.IIf(b, -2, -1));
    //na.SetValue(i, 'temp', -1);
    st1 := '';
    for k := 0 to High(flds1) do
      S.ConcatStP(st1, na.G(i, flds1[k]).AsString, '|');
    //пройдем по массиву турв. флаг будет уже True если данные из 1го периода, но надо сопоставить строки турв и данных для возможного изменения
    for j := 0 to FTurv.Count - 1 do begin
      //нужно для доступа в FTurv.FList
      r := FTurv.R(j)[0];
      st2 := '';
      for k := 0 to High(flds1) do
        S.ConcatStP(st2, FTurv.List.G(r, flds1[k]).AsString, '|');
      if st1 = st2 then begin
        b := True;
        //сохраним во временной поле массива турв позицию из грида (из загруженной расчетной ведомости)
        FTurv.List.SetValue(r, 'temp', i);
        na.SetValue(i, 'temp', j);
        Break;
      end;
    end;
    //если не нашли в гриде - айди в массив, и данные в сообщение
    if not b then begin
      //данные строки для сообщения
      st1 := '';
      for k := 0 to High(flds2) do
        S.ConcatStP(st1, na.G(i, flds2[k]).AsString, ' | ');
      S.ConcatStP(MsgDel, st1, #13#10);
      //в массив удаленных - только те, которые загружены из БД
      if na.G(i, 'id') <> null then
        FDeletedWorkers := FDeletedWorkers + [na.G(i, 'id')];
      FIsChanged := True;
    end;
  end;

  //пройдем по данным, загруженным из турв
  for i := 0 to FTurv.Count - 1 do begin
    r := FTurv.R(i)[0];
    //если строки, которая есть в турв, нет в ведомости - добавим строку
    if FTurv.List.G(r, 'temp').AsIntegerM = -1 then begin
      //данные строки для сообщения
      st1 := '';
      for k := 0 to High(flds2) do
        S.ConcatStP(st1, FTurv.List.G(r, flds2[k]).AsString, ' | ');
      S.ConcatStP(MsgIns, st1, #13#10);
      //добавим строку
      na.IncLength;
      na.SetNull(na.High);
      //установим поля и итоговые данные из турв
      na2 := FTurv.CalculateTotals(i);
      //айдишники
      for k := 0 to High(flds1) do
        na.SetValue(na.High, flds1[k], FTurv.List.G(r, flds1[k]));
      //остальные поля
      for k := 0 to High(flds) do
        if flds[k][2] = 1 then
          na.SetValue(na.High, S.IfEmptyStr(flds[k][1], flds[k][0]), FTurv.List.G(r, flds[k][0]))
        else
          na.SetValue(na.High, S.IfEmptyStr(flds[k][1], flds[k][0]), na2.G(flds[k][0]));
      //здесь в null преобразовывать необязательно, так как это будет сделано в CalculateAll для того что правее Итого начислено при значениях 0
    end;
  end;

  //удалим позиции в ведомости, которые пропали из турв
  for i := na.High downto 0 do
    if na.G(i, 'temp') = -1 then begin
      Delete(na.V, i ,1);
    end;

  //пройдем по массиву ведомости, по тем строкам, для которых есть данные турв (а значит могли быть изменения)
  for i := na.High downto 0 do begin
    j := na.G(i, 'temp').AsIntegerM;
    if j > -1 then begin
      st2 := '';
      for k := 0 to High(flds) do
        //если надо сравнивать и выдавать отчет (сюда включены сейчас все обновляемые)
        if flds[k][3] = 1 then begin
          var fld := S.IfEmptyStr(flds[k][1], flds[k][0]);
          //значение в  ведомости (старое)
          v1 := na.G(i, fld);
          //значение из турв (новое)
          na2 := FTurv.CalculateTotals(j);
          if flds[k][2] = 1 then
            v2 := FTurv.List.G(FTurv.R(j)[0], flds[k][0])
          else
            v2 := na2.G(flds[k][0]);
          if flds[k][4] = 1 then
            v2 := v2.NullIf0;
          if v1 <> v2 then begin
            na.SetValue(i, fld, v2);
            S.ConcatStP(st2, '   ' + Frg1.GetColumnCaption(fld) + ':   ' + '"' + v1.AsString + '" -> "' + v2.AsString + '"', #13#10);
          end;
        end;
      if st2 <> '' then begin
        st1 := '';
        for k := 0 to High(flds2) do
          S.ConcatStP(st1, na.G(i, flds2[k]).AsString, ' | ');
        S.ConcatStP(MsgChg, st1 + #13#10 + st2, #13#10);
      end;
    end;
  end;


  //загрузим данные в грид
  Frg1.LoadData(na);
  CalculateAll;

  if MsgIns + MsgDel + MsgChg = '' then begin
    if not FNoData then
      MyInfoMessage('ТУРВ загружен, изменений в ведомости не было.');
  end
  else begin
    FIsChanged := True;
    if not FNoData then
      MyInfoMessage(
        'ТУРВ загружен.'#13#10#13#10 +
        S.IIFStr(MsgIns <> '', 'Внесены записи:'#13#10 + MsgIns + #13#10#13#10) +
        S.IIFStr(MsgDel <> '', 'Удалены записи:'#13#10 + MsgDel + #13#10#13#10) +
        S.IIFStr(MsgChg <> '', 'Изменены записи:'#13#10 + MsgChg),
        1
      );
  end;
end;

procedure TFrmWGedtPayroll2N.GetDataFromExcel;
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
  repeat
    sl := TStringList.Create;
    //получим список всех файлов в каталоге из настроек
    Sys.GetFilesInDirectoryRecursive(Module.GetCfgVar(mycfgWpath_to_payrolls), sl);
    //найдем те, вкоторых есть файл типа "Март 1/Сборка 1.xlsx"
    for i := 0 to sl.Count - 1 do begin
      if pos(MonthsRu[MonthOf(FPayrollParams.G('dt1'))] + ' ' + S.IIFStr(DayOf(FPayrollParams.G('dt1')) = 1, '1', '2') + '\' + FPayrollParams.G('departament') + '.xlsm', sl[i]) > 0 then
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
        fio := Frg1.MemTableEh1.FieldByName('employee').AsString;
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
          if Frg1.MemTableEh1.FieldByName('ext_pay').AsVariant <> e then begin
            if Frg1.MemTableEh1.FieldByName('ext_pay').AsVariant <> null then
              st := st + fio + ': Изменен столбец Баллы с ' + Frg1.MemTableEh1.FieldByName('ext_pay').AsString + ' на ' + VarToStr(e) + #13#10;
            Frg1.MemTableEh1.Edit;
            Frg1.MemTableEh1.FieldByName('ext_pay').Value := e;
            FIsChanged := True;
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
end;


procedure TFrmWGedtPayroll2N.SetButtons;
var
  i: Integer;
  NoNorms: Boolean;
begin
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtSettings, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtCustom_Turv, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtCustom_Payroll, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtLock, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbRecalculate, null, False);
  Frg1.DbGridEh1.ReadOnly := True;
{  NoNorms:= False;
  for i := 0 to Frg1.GetCount(False) - 1 do
    if (Frg1.GetValueF('norm', i, False) <= 0) or (Frg1.GetValueF('norm_m', i, False) <= 0) then
      NoNorms:= True;    }
  if Mode = fView then begin
    Frg1.SetControlValue('lblInfo', '$000000Только просмотр.');
  end
  else if FPayrollParams.G('is_finalized') = 1 then begin
    Frg1.SetControlValue('lblInfo', '$00FF00Ведомость закрыта, только просмотр.');
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtLock, null, True);
  end
  else if (FPayrollParams.G('calc_method') = null) or (FPayrollParams.G('overtime_method') = null) then begin
    Frg1.SetControlValue('lblInfo', '$0000FFЗадайте метод расчета!');
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtSettings, null, True);
  end
{  else if NoNorms then begin
    Frg1.SetControlValue('lblInfo', '$0000FFНе заданы нормы рабочего времени, выполните загрузку ТУРВ!');
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtCustom_Turv, null, True);
  end}
  else begin
    Frg1.SetControlValue('lblInfo', '$FF00FFВвод данных.');
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtSettings, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtCustom_Turv, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtCustom_Payroll, null, Integer(FPayrollParams.G('calc_method')) in [cMMotivation]);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtLock, null, True);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbRecalculate, null, True);
    Frg1.DbGridEh1.ReadOnly := False;
  end;
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtLock, S.IIf(FPayrollParams.G('is_finalized') = 1, 'Отменить закрытие ведомости', 'Закрыть ведомость'), null);
  SetColumns;
  Frg1.DbGridEh1.Invalidate;
end;

procedure TFrmWGedtPayroll2N.SetColumns;
begin
  //теги (1-редактирования кроме расчета по мотивации, 2-дополнительное редактирование,3-редактировать всегда)
  Frg1.Opt.SetColFeature('*', 'e', False, False);
  Frg1.Opt.SetColFeature('i1', 'i', FPayrollParams.G('calc_method').AsInteger = cMMotivation, False);
  Frg1.Opt.SetColFeature('ext_pay', 'i', FPayrollParams.G('calc_method').AsInteger <> cMMotivation, False);
  Frg1.Opt.SetColFeature('1', 'e', (FPayrollParams.G('calc_method').AsInteger <> cMMotivation) or FIsEditableAll, False);
  Frg1.Opt.SetColFeature('2', 'e', FIsEditableAdd or FIsEditableAll, False);
  Frg1.Opt.SetColFeature('3', 'e', True, False);
  if FIsEditableAll then
    Frg1.Opt.SetColFeature('*', 'e', True, False);
  Frg1.SetColumnsVisible;
end;

function TFrmWGedtPayroll2N.GetCaption(Colored: Boolean = False): string;
begin
  Result := S.IIFStr(Colored, '$FF0000') + S.IIf(FPayrollParams.G('employee') <> null, FPayrollParams.G('employee') + ' (' + FPayrollParams.G('departament') + ')', FPayrollParams.G('departament')) +
    S.IIFStr(Colored, '$000000') + ' с' + S.IIFStr(Colored, '$FF00FF') +' ' + DateToStr(FPayrollParams.G('dt1')) +
    S.IIFStr(Colored, '$000000') + ' по ' + S.IIFStr(Colored,  '$FF00FF') + DateToStr(FPayrollParams.G('dt2'));
end;

procedure TFrmWGedtPayroll2N.CommitPayroll;
begin
  if MyQuestionMessage(S.IIf(S.NInt(FPayrollParams.G('is_finalized')) = 1, 'Снять статус "Закрыта" для ведомости?', 'Поставить статус "Закрыта" для ведомости?')) <> mrYes then
    Exit;
  FPayrollParams.SetValue(0, 'is_finalized', IIf(S.NInt(FPayrollParams.G('is_finalized')) = 1, 0, 1));
  FIsChanged := True;
  SetButtons;
end;


procedure TFrmWGedtPayroll2N.PrintGrid;
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

procedure TFrmWGedtPayroll2N.ExportToXlsxA7;     //!!! not work
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
  Gh.GetGridColumn(Frg1.DBGridEh1, 'performance_bonus').Visible := S.NInt(FPayrollParams.G('id_method')) in [16];
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
  Gh.GetGridColumn(Frg1.DBGridEh1, 'performance_bonus').Visible := False;
  Gh.GetGridColumn(Frg1.DBGridEh1, 'sign').Visible := False;
end;

procedure TFrmWGedtPayroll2N.SetPayrollMethod;
var
  va, va1, va2, va3: TVarDynArray;
  n: Variant;
  rn, i: Integer;
  st: string;
begin
  if not FrmWDedtPayrollCalcMethod.ShowDialog(FPayrollParams) then Exit;
  FIsChanged := True;
  //пересчитаем ведомость
  CalculateAll;
  SetButtons;
end;

procedure TFrmWGedtPayroll2N.SavePayroll;
var
  i, j: Integer;
  f, fn, va: TVarDynArray;
begin
  //запишем метод расчета
  Q.QBeginTrans(True);
  Q.QExecSql('update w_payroll_calc set calc_method = :p1$i, overtime_method = :p2$i, is_finalized = :p3$i where id = :id$i', [FPayrollParams.G('calc_method'), FPayrollParams.G('overtime_method'), FPayrollParams.G('is_finalized'), ID]);
  //удалим из БД всех, кого удаляли из списка при нажатии кнопки ТУРВ
  if Length(FDeletedWorkers) > 0 then
    Q.QExecSql('delete from w_payroll_calc_item where id in (' + A.Implode(FDeletedWorkers, ',') + ')', []);
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    if Frg1.GetValueI('id', i, False) = 0 then begin
      var idn := Q.QIUD('i', 'w_payroll_calc_item', '', 'id$i;id_payroll_calc$i', [-1, ID]);
      Frg1.SetValue('id', i, False, idn);
    end;
    f := A.Explode(cFieldsS, ';');
    va := [];
    for j := 0 to High(f) do
    fn := A.Explode(f[j],'$') ;
    for j := 0 to High(f) do begin
      va := va + [Frg1.GetValue(A.Explode(f[j],'$')[0], i, False)];
    end;
    Q.QIUD('u', 'w_payroll_calc_item', '', cFieldsS, va);
  end;
  Q.QCommitOrRollback(True);
end;

procedure TFrmWGedtPayroll2N.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if A.InArray(FieldName, ['employee', 'job', 'organization', 'personnel_number', 'schedulecode']) then
    Params.Background := clmyGray;
  if A.InArray(FieldName, ['total_pay', 'base_pay']) then
    Params.Background := RGB(220, 255, 190);
  if A.InArray(FieldName, ['total_pay', 'base_pay']) and (Frg1.GetValueF(FieldName) < 0) then
    Params.Background := clRed;
  if A.InArray(FieldName, ['total_pay1', 'base_pay1', 'period_hours_norm1', 'hours_worked1', 'overtime1', 'ors_pay1', 'base_pay1', 'ext_pay1', 'total_pay1']) then
    Params.Background := RGB(220, 220, 255);
end;

procedure TFrmWGedtPayroll2N.Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
//при ручном вводе в ячейке - проставим признак изменения строки
begin
  FIsChanged := True;
  Frg1.SetValue('changed', 1);
end;

procedure TFrmWGedtPayroll2N.Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string);
begin
  if Mode <> dbgvCell then
    Exit;
  CalculateRow(Row - 1);
end;

procedure TFrmWGedtPayroll2N.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
end;

procedure TFrmWGedtPayroll2N.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  Handled := True;
  case Tag of
    cmbSetEditable:
      SetEditableAll;
    cmbRecalculate: begin
      CalculateAll;
      FIsChanged := True;
      Frg1.InvalidateGrid;
    end;
    mbtCustom_Turv:
      if MyQuestionMessage('Загрузить данные из ТУРВ?') = mrYes then
        GetDataFromTurv;
    mbtCustom_Payroll:
      if MyQuestionMessage('Загрузить мотивацию') = mrYes then
        GetDataFromExcel;
    mbtSettings:
      SetPayrollMethod;
//    mbtExcel:
//      ExportToXlsxA7;
    mbtPrintGrid:
      PrintGrid;
    mbtLock:
      CommitPayroll;
  else
    Handled := False;
  end;
  if Handled then
    SetButtons;
end;

procedure TFrmWGedtPayroll2N.SetEditableAll;
begin
  if Frg1.DbGridEh1.ReadOnly then
    Exit;
  if User.IsDeveloper then
    FIsEditableAll := not FIsEditableAll
  else
    FIsEditableAdd := not FIsEditableAdd;
  SetColumns;
end;

procedure TFrmWGedtPayroll2N.CalculateAll;
var
  i: Integer;
begin
  for i := 0 to Frg1.GetCount(False) - 1 do
    CalculateRow(i);
end;

procedure TFrmWGedtPayroll2N.CalculateRow(Row: Integer);
var
  i: Integer;
  v1, v2, v3: Variant;
  CalcMode: Integer;
  M, O: Integer;
  VBase, VTotal: Variant;
  ENormM, ENormP, EHours, EOvertime, EOrs: Extended;

begin
  if Row = -1 then
    Row := Frg1.MemTableEh1.RecNo - 1;

  M := FPayrollParams.G('calc_method').AsIntegerM;
  O := FPayrollParams.G('overtime_method').AsIntegerM;

  if (M = -1) or (O = -1) then
    Exit;

  ENormM := Frg1.GetValueF('monthly_hours_norm', Row, False);
  ENormP := Frg1.GetValueF('period_hours_norm', Row, False);
  EHours := Frg1.GetValueF('hours_worked', Row, False);
  EOvertime := Frg1.GetValueF('overtime', Row, False);

  if M <> cMMotivation then
    Frg1.SetValue('ext_pay', Row, False, null);

  if Frg1.GetValue('employee', Row, False) = 'Кобзя Алексей Анатольевич' then
    var Test := True;

  if M = cMMotivation then begin
    Frg1.SetValue('planned_pay', Row, False, null);
    Frg1.SetValue('fixed_pay', Row, False, null);
    Frg1.SetValue('variable_pay', Row, False, null);
    Frg1.SetValue('ors', Row, False, null);
    Frg1.SetValue('base_pay', Row, False, null);
    Frg1.SetValue('base_pay2', Row, False, null);
    Frg1.SetValue('ors_pay', Row, False,  null);
    VBase := Frg1.GetValue('ext_pay', Row, False);
  end
  else begin
    EOrs := Frg1.GetValueF('ors', Row, False);
    EOrs := S.IIf(EOrs = 0, 100, EOrs);
    if M = cMWorkshop then begin
      if (EOrs < 95) then
        EOrs := EOrs
      else if (EOrs >= 95) and (EOrs <= 100) then
        EOrs := 100
      else if (EOrs >= 100) and (EOrs <= 105) then
        EOrs := 105
      else if (EOrs >= 105) and (EOrs <= 110) then
        EOrs := 110
      else if (EOrs > 110) then
        EOrs := 120;
    end;
    EOrs := EOrs / 100;
//var st := Frg1.GetValue('planned_pay', Row, False);
    if (Frg1.GetValue('planned_pay', Row, False).AsFloat <> 0) and (Frg1.GetValue('fixed_pay', Row, False) <> null) then begin
      Frg1.SetValue('variable_pay', Row, False, S.NullIf0(Frg1.GetValueF('planned_pay', Row, False) - Frg1.GetValueF('fixed_pay', Row, False)));
      //Итого начислено: Расчет = (постоянная часть / норма рабочих часов за месяц * отработанные часы ) + (стимулирующая выплата * ОРС  / норма рабочих часов за месяц * отработанные часы)
      VBase := (Frg1.GetValueF('fixed_pay', Row, False) / ENormM * Min(EHours, ENormP)) + (Frg1.GetValueF('variable_pay', Row, False) * EOrs / ENormM * Min(EHours, ENormP));
    end
    else begin
      VBase := null;
      Frg1.SetValue('variable_pay', Row, False, null);
    end;
    Frg1.SetValue('base_pay2', Row, False, VBase);
    Frg1.SetValue('base_pay', Row, False, S.NullIf0(VBase.AsFloat + Frg1.GetValueF('base_pay1', Row, False)));
    Frg1.SetValue('ors_pay', Row, False, Round(Frg1.GetValueF('variable_pay', Row, False) * EOrs / ENormM * Min(ENormP, EHours)));
  end;
  //Переработки: Расчет = (постоянная часть  + (стимулирующая выплата * ОРС ) / норма рабочих часов за месяц * часы переработки  * коэффициент
  if O = cO00 then
    Frg1.SetValue('overtime_pay', Row, False, null)
  else begin
    Frg1.SetValue('overtime_pay', Row, False, (Frg1.GetValueF('fixed_pay', Row, False) + Frg1.GetValueF('variable_pay', Row, False) * EOrs) / ENormM * EOvertime * S.IIf(O = cO10, 1, 1.5));
  end;

  var flds := ['base_pay', 'overtime_pay', 'personal_pay', 'daily_bonus', 'extra_bonus', 'night_pay', 'milk_compensation', 'non_work_pay', 'penalty', 'correction'];
  VTotal := 0;
  for i := 0 to High(flds) do begin
    v1 := Frg1.GetValue(flds[i], Row, False);
    if v1 <> null then begin
      v1 := S.NullIf0(Round(v1.AsFloat));
      Frg1.SetValue(flds[i], Row, False, v1)
    end;
    VTotal := VTotal + v1.AsFloat;
  end;
  //VTotal := RoundTo(VTotal, 2);
  VTotal := VTotal + Frg1.GetValue('ext_pay', Row, False).AsFloat + Frg1.GetValue('ext_pay1', Row, False).AsFloat - Frg1.GetValueF('total_pay1', Row, False);
  Frg1.SetValue('total_pay', Row, False, VTotal);
end;




end.

