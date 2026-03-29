{
авансовая расчетная ведомость

  первоначально создается запись в таблице ведомостей по данному подразделений (и, возможно, одному работнику) за данный период.
  при первом открытии заполняется строками на основе ТУРВ, строки

  с одинаковым работником объединяются, должность пишется первая,
работники, по которым есть индивидуальные ведомости не вносятся. расчетные данные заполняются пустыми. но бланка и оклад берутся
из предыдущей ведомости (за прошлый период) по данному подразделению (по всему подразделению). метод расчета берется также из
этой ведомости.
  при нажатии кнопки турв - корректируется список (добавляются записи, которых еще не было, если по ним нет индивидуальных ведомостей,
удаляются из сетки, но не из БД, записи, для которых больше нет строки в турв). загружаются данные по рабочим часам, премиям, штрафам,
графику работы и нормам за месц и текущий период для работника и пересчитывается сетка.
  данные в сетке (все) - целые, втч турв, а итог округляется до 100р
  данные сохраняются при закрытии ведомости, включая и изменение настроек, и изменение списка работников в ведомости
}

unit uFrmWGedtAdvance;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls,
  ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls, MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd,
  MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils, Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uTurv, uNamedArr
  ;

type
  TFrmWGedtAdvance = class(TFrmBasicGrid2)
    PrintDBGridEh1: TPrintDBGridEh;
  private
    FPayrollParams: TNamedArr;
    FDeletedWorkers: TVarDynArray;
    FTurv: TTurvData;
    FIdTurv: Variant;
    FIsEditableAdd, FIsEditableAll: Boolean;
    function  PrepareForm: Boolean; override;
    function  Save: Boolean; override;
    //события грида
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    //методы класса
    function  GetDataFromDb: Integer;
    function  GetDataFromTurv: Integer;
    function  GetCaption(Colored: Boolean = False): string;
    procedure SetButtons;
    procedure SetColumns;
    procedure SetEditableAll;
    procedure FinalizePayroll;
    procedure PrintGrid;
    procedure CalculateAll;
    procedure CalculateRow(Row:Integer);
  public
  end;

var
  FrmWGedtAdvance: TFrmWGedtAdvance;

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
  //позиции меню
  cmbRecalculate = 1005;
  cmbSetEditable = 1006;
  cmbDeleteRow = 1007;
  //поля в бд ()
  cFieldsS =
    'id$i;id_employee$i;id_job$i;id_schedule$i;personnel_number$s;monthly_hours_norm$f;period_hours_norm$f;hours_worked$f;planned_pay$f;fixed_pay$f;base_pay$f;correction$f;total_pay$f';
  cFieldsL =
    'employee$s;job$s;schedulecode$s;id_organization$i;temp$i';  //id_organization$i;organization$s;changed$i;
  cColWidth = 45;

function TFrmWGedtAdvance.PrepareForm: Boolean;
var
  i, j, w1: Integer;
  v: Variant;
  wcol, fcol: string;
begin
  Result:=False;

  Caption:='Авансовая расчетная ведомость';
  FOpt.RefreshParent := True;
  //возьмем блокировку
  if FormDbLock = fNone then Exit;
  //поля смой записи ведомости
  Q.QLoadFromQuery('select id, id_departament, id_employee, personnel_number, dt, departament, employee, is_office, is_finalized from v_w_advance_calc where id = :id$i', [ID], FPayrollParams);
  if FPayrollParams.Count = 0 then begin
    MsgRecordIsDeleted;
    Exit;
  end;
  //айди ТУРВ за данный период по данному подразделению
  FIdTurv := Q.QLoadValue('select id from w_turv_period where id_departament = :idd$i and dt1 = :dr1$d' ,[FPayrollParams.G('id_departament'), FPayrollParams.G('dt')]);

  FDeletedWorkers := [];
  Frg1.Options := FrDBGridOptionDef + [myogPanelFind, myogColumnResize, myogHasStatusBar] - [myogColumnFilter];

  //определим поля
  //теги (2-дополнительное редактирование,3-редактировать всегда)
  wcol := IntToStr(CColWidth) + ';r';
  fcol := 'f=###,###,###:';
  Frg1.Opt.SetFields([
    ['id$i', '_id','40'],
    ['id_organization$s', '_org', '10'],
    ['id_employee$i', '_id_employee', wcol],
    ['id_job$i', '_id_job', wcol],
    ['id_schedule$i', '_id_schedule', wcol, fcol],
    ['temp$i', '_temp', wcol],

    ['employee$s', 'Работник|ФИО', '200;h'],
    ['personnel_number$s', '!Табельный номер', '60'],
    ['job$s', '!Должность', '150;h'],
    ['schedulecode$s', '!График', '70'],

    ['monthly_hours_norm$f', 'ТУРВ|Норма отработанных часов за месяц', 90],
    ['period_hours_norm$f', '!Норма отработанных часов за период', 90],
    ['hours_worked$f', '!Отработано за период', 90],
//    ['overtime$f', '!Из них переработка', 90],

    ['planned_pay$f', '~Плановое' + sLineBreak + 'начисление', wcol, fcol, 't=3'],
    ['fixed_pay$f', '~Постоянная' + sLineBreak + ' часть', wcol, fcol, 't=3'],
    ['base_pay$f', '~Итого' + sLineBreak + ' рассчитано', wcol, fcol],
    ['correction$f', '~Корректировка', wcol, fcol, 't=3'],
    ['total_pay$f', '~Итого' + sLineBreak + ' начислено', wcol, fcol]
  ]);
  Frg1.Opt.SetGridOperations('u');
  Frg1.Opt.SetButtons(1, [
    [mbtCustom_Turv],
    [-cmbDeleteRow, True, 'Удалить строку'],
    [-cmbRecalculate, True, 'Пересчитать все'],
    [-cmbSetEditable, True, 'Разрешить редактирование всех полей'],
    [-mbtExcel, AddParam = null],
    [],[mbtLock],
    [],[mbtCtlPanel]
  ]);
  Frg1.Opt.ButtonsNoAutoState := [0];
  Frg1.Opt.SetGridOperations('ud');

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

  FQueryCloseMessage := 'Ведомость была изменена!'#13#10'Сохранить данные?';
  FOpt.RequestWhereClose := cqYNC;

  Result := inherited;
  if not Result then
    Exit;


  //ширина окна по ширине грида
  Self.Width := Frg1.GetTableWidth + 75;

  //прочитаем из БД ведомость
  GetDataFromDb;
  //если ведомость пуста- выполним первоначальную загрузка по данным турв
  if Frg1.GetCount(False) = 0 then
    GetDataFromTurv;
  SetButtons;

  Result:=True;
end;

function TFrmWGedtAdvance.Save: Boolean;
//сохраним ведомость
var
  i, j: Integer;
  f, fn, va: TVarDynArray;
begin
  Result := False;
  Q.QBeginTrans(True);
  Q.QExecSql('update w_advance_calc set is_finalized = :p$i where id = :id$i', [FPayrollParams.G('is_finalized'), ID]);
  //удалим из БД всех, кого удаляли из списка при нажатии кнопки ТУРВ
  if Length(FDeletedWorkers) > 0 then
    Q.QExecSql('delete from w_advance_calc_item where id in (' + A.Implode(FDeletedWorkers, ',') + ')', []);
  //обновим в бд все строки таблицы
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    //если строка не была прочитана ранее из бд - вставим
    if Frg1.GetValueI('id', i, False) = 0 then begin
      var idn := Q.QIUD('i', 'w_advance_calc_item', '', 'id$i;id_advance_calc$i', [-1, ID]);
      Frg1.SetValue('id', i, False, idn);
    end;
    //обновим все сохраняемые поля грида для строки
    f := A.Explode(cFieldsS, ';');
    va := [];
    for j := 0 to High(f) do
      fn := A.Explode(f[j], '$');
    for j := 0 to High(f) do begin
      va := va + [Frg1.GetValue(A.Explode(f[j], '$')[0], i, False)];
    end;
    Q.QIUD('u', 'w_advance_calc_item', '', cFieldsS, va);
  end;
  Q.QCommitTrans;
  Result := Q.CommitSuccess;
end;

procedure TFrmWGedtAdvance.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
//установим визуальные параметры ячеек (подсветим)
begin
  if A.InArray(FieldName, ['employee', 'job', 'personnel_number', 'schedulecode']) then
    Params.Background := clmyGray;
  if A.InArray(FieldName, ['total_pay', 'base_pay']) then
    Params.Background := RGB(220, 255, 190);
  if A.InArray(FieldName, ['total_pay', 'base_pay']) and (Frg1.GetValueF(FieldName) < 0) then
    Params.Background := clRed;
end;

procedure TFrmWGedtAdvance.Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
//вызывается после ручного изменения ячейки. установим статус изменения грида и пересчитаем строку
begin
  Fr.SetState(True, null, null);
  CalculateRow(-1);
end;

procedure TFrmWGedtAdvance.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
//нажатие кнопки/пункта меню в гриде
begin
  Handled := True;
  case Tag of
    cmbSetEditable:
      SetEditableAll;
    cmbDeleteRow:
      if MyQuestionMessage('Удалить строку?') = mrYes then begin
        FDeletedWorkers := FDeletedWorkers + [Frg1.GetValue('id')];
        Frg1.DeleteRow;
        Frg1.SetState(True, null, null);
      end;
    cmbRecalculate:
      begin
        CalculateAll;
        Frg1.SetState(True, null, null);
        Frg1.InvalidateGrid;
      end;
    mbtCustom_Turv:
      if MyQuestionMessage('Загрузить данные из ТУРВ?') = mrYes then
        GetDataFromTurv;
    mbtPrintGrid:
      PrintGrid;
    mbtLock:
      FinalizePayroll;
  else
    Handled := False;
  end;
  if Handled then
    SetButtons;
end;

function TFrmWGedtAdvance.GetDataFromDb: Integer;
//прочитаем ведомость (все данные) из БД и заполним ими сетку
var
  na : TNamedArr;
begin
  Q.QLoadFromQuery(Q.QSIUDSql('a', 'v_w_advance_calc_item', cFieldsS + ';' + cFieldsL) + ' where id_advance_calc = :id$i' + S.IIFStr(AddParam <> null, ' and id_employee = ' + AddParam.AsString) + ' order by job, employee, schedulecode, personnel_number',
    [ID], na
  );
  Frg1.LoadData(na);
end;

function TFrmWGedtAdvance.GetDataFromTurv: Integer;
//читаем данные из ТУРВ по нажатию соотв кнопки
var
  i, j, k, r: Integer;
  st1, st2, st3: string;
  v1, v2: Variant;
  b: Boolean;
  NoData: Boolean;
  na, na2, naprev: TNamedArr;
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
  flds2 := ['employee', 'job', 'schedulecode', 'personnel_number'];
  //поля
  //поле в турв; поле в ведомости; загрузка (1 - FTurv.List.G, 2 - CalculateTotals); сравнивать и выдвать отчеты; если 1, то 0 = null
  flds:=[
    ['job', '', 1, 0, 0],
    ['employee', '', 1, 0, 0],
    ['schedulecode', '', 1, 0, 0],
    //['organization', '', 1, 0, 0],
    ['personnel_number', '', 1, 0, 0],
    ['monthly_hours_norm', '', 1, 1, 0],
    ['period_hours_norm', '', 1, 1, 0],
    ['worktime', 'hours_worked', 2, 1, 0]
  ];

  //загрузим данные из турв
  //строки в ведомости сгруппированы по f1
  var GroupingSt := 'job;employee;schedulecode;personnel_number';
  if FPayrollParams.G('id_employee') = null then begin
    //статусы работников, по которым есть ведомости увольнения
    va := [];
    va := Q.QLoadToVarDynArrayOneCol(
      'select '+
      '  p.id '+
      'from '+
      '  w_advance_calc c, '+
      '  v_w_employee_properties p '+
      'where '+
      '  c.id_employee = p.id_employee '+
      '  and p.id_organization is null '+
      '  and c.personnel_number = p.personnel_number '+
      '  and c.dt = :dt$d',
      [FPayrollParams.G('dt')]
    );
    //только для статусов неоформленных
    WhereSt := 'and id_organization is null';
    if Length(va) <> 0 then
      WhereSt := WhereSt + ' and not id in (' + A.Implode(va, ',') + ')';
    //получаем турв, с учкетом выборки, с загрузкой данных по дням, кроме уволенных
    FTurv.Create(FIdTurv, GroupingSt, GroupingSt, 0, 0, -1, -1, WhereSt, True, 1)
  end
  else begin
    //если ведомость по работнику - только для данного работника
    WhereSt := 'and id_employee = ' + FPayrollParams.G('id_employee').AsString + ' and id_organization is null ' +
    'and personnel_number = ''' + FPayrollParams.G('personnel_number').AsString + '''';
    //получаем турв, с учкетом выборки, с загрузкой данных по дням, включая уволенных
    FTurv.Create(FIdTurv, GroupingSt, GroupingSt, 0, 0, -1, -1, WhereSt, True, 0);
  end;
  //загрузим дванные по зарплате из предыдущей ведомости по этому подраздделению
  //!!!
  Q.QLoadFromQuery(
    'select id_employee, id_job, planned_pay, fixed_pay from v_w_payroll_calc_item where id_target_employee is null and nvl(id_target_departament, -100) = :idd$i and dt1 = :dt1$d',
    [FPayrollParams.G('id_departament'), Turv.GetTurvBegDate(IncDay(FPayrollParams.G('dt'), -1))],
    naprev
  );

  NoData := Frg1.GetCount = 0;

  //заполним то что загружается из турв, остальные данные ранее загруженными из бд, удалим строки из ведомости, которых в турв теперь нет

  //получим для удобства работы данные из грида - они там сейчас те, что загрузились из БД
  na := Frg1.ExportToNa('', False);
  MsgDel := '';
  MsgIns := '';
  MsgChg := '';
  //найдем те строки в гриде, которых более нет в турв
  for i := 0 to na.Count - 1 do begin
    na.SetValue(i, 'temp', -1);
    st1 := '';
    for k := 0 to High(flds1) do
      S.ConcatStP(st1, na.G(i, flds1[k]).AsString, '|');
    b := False;
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
      Frg1.SetState(True, null, null);
    end;
  end;

  //пройдем по данным, загруженным из турв
  for i := 0 to FTurv.Count - 1 do begin
    r := FTurv.R(i)[0];
    //если строки, которая есть в турв, нет в ведомости
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
    if j <> -1 then begin
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

  for i := 0 to na.High do
    for j := 0 to naprev.High do begin
      if (na.G(i, 'id_employee') = naprev.G(j, 'id_employee')) and (na.G(i, 'id_job') = naprev.G(j, 'id_job')) then begin
        if na.G(i, 'planned_pay') = null then
          na.SetValue(i, 'planned_pay', naprev.G(j, 'planned_pay'));
        if na.G(i, 'fixed_pay') = null then
          na.SetValue(i, 'fixed_pay', naprev.G(j, 'fixed_pay'));
        Break;
      end;
    end;

  //загрузим данные в грид
  Frg1.LoadData(na);
  CalculateAll;

  if MsgIns + MsgDel + MsgChg = '' then begin
    MyInfoMessage('ТУРВ загружен, изменений в ведомости не было.');
  end
  else begin
    Frg1.SetState(True, null, null);
    MyInfoMessage(
      'ТУРВ загружен.'#13#10#13#10 +
      S.IIFStr(MsgIns <> '', 'Внесены записи:'#13#10 + MsgIns + #13#10#13#10) +
      S.IIFStr(MsgDel <> '', 'Удалены записи:'#13#10 + MsgDel + #13#10#13#10) +
      S.IIFStr(MsgChg <> '', 'Изменены записи:'#13#10 + MsgChg),
      1
    );
  end;
end;

function TFrmWGedtAdvance.GetCaption(Colored: Boolean = False): string;
//вернем текст для лейбла заголовка
begin
  var dt := FPayrollParams.G('dt');
  Result := S.IIFStr(Colored, '$FF0000') + S.IIf(FPayrollParams.G('employee') <> null, FPayrollParams.G('employee') + ' (' + FPayrollParams.G('departament') + ')', FPayrollParams.G('departament')) +
    S.IIFStr(Colored, '$000000') + ' с' + S.IIFStr(Colored, '$FF00FF') +' ' + DateToStr(dt) +
    S.IIFStr(Colored, '$000000') + ' по ' + S.IIFStr(Colored,  '$FF00FF') + DateToStr(encodedate(yearof(dt), monthof(dt), 15));
end;

procedure TFrmWGedtAdvance.SetButtons;
//установим доступность кнопок и пунктов меню, а также подсказу в заголовке
begin
  //заблокируем все
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtCustom_Turv, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtCustom_Payroll, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtLock, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbRecalculate, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbSetEditable, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbDeleteRow, null, False);
  //грид ридонли
  Frg1.DbGridEh1.ReadOnly := True;
  if Mode = fView then begin
    Frg1.SetControlValue('lblInfo', '$000000Только просмотр.');
  end
  else if FPayrollParams.G('is_finalized') = 1 then begin
    Frg1.SetControlValue('lblInfo', '$00FF00Ведомость закрыта, только просмотр.');
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtLock, null, True);
  end
  else begin
    Frg1.SetControlValue('lblInfo', '$FF00FFВвод данных.');
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtSettings, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtCustom_Turv, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtLock, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbRecalculate, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbSetEditable, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbDeleteRow, null, True);
    Frg1.DbGridEh1.ReadOnly := False;
  end;
  //кнопка закрытия ведомости
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtLock, S.IIf(FPayrollParams.G('is_finalized') = 1, 'Отменить закрытие ведомости', 'Закрыть ведомость'), null);
  //параметры столбцов
  SetColumns;
  Frg1.DbGridEh1.Invalidate;
end;

procedure TFrmWGedtAdvance.SetColumns;
//установим параметры столбцов грида (здесь только возможность редактирования)
begin
  Frg1.Opt.SetColFeature('*', 'e', False, False);
  Frg1.Opt.SetColFeature('2', 'e', FIsEditableAdd or FIsEditableAll, False);
  Frg1.Opt.SetColFeature('3', 'e', True, False);
  if FIsEditableAll then
    Frg1.Opt.SetColFeature('*', 'e', True, False);
  Frg1.SetColumnsVisible;
end;

procedure TFrmWGedtAdvance.SetEditableAll;
//включи/выключим режим расширенного редактирования полей
begin
  if Frg1.DbGridEh1.ReadOnly then
    Exit;
  //для разработчика вообще все, для того кто редактирует - допустимые
  if User.IsDeveloper then
    FIsEditableAll := not FIsEditableAll
  else
    FIsEditableAdd := not FIsEditableAdd;
  SetColumns;
end;

procedure TFrmWGedtAdvance.FinalizePayroll;
//закрыть ведомость (станет заблокирована для изменений, и доступна для просмотра руководителям)
begin
  if MyQuestionMessage(S.IIf(S.NInt(FPayrollParams.G('is_finalized')) = 1, 'Снять статус "Закрыта" для ведомости?', 'Поставить статус "Закрыта" для ведомости?')) <> mrYes then
    Exit;
  FPayrollParams.SetValue(0, 'is_finalized', IIf(S.NInt(FPayrollParams.G('is_finalized')) = 1, 0, 1));
  Frg1.SetState(True, null, null);
  SetButtons;
end;

procedure TFrmWGedtAdvance.PrintGrid;
//печать грида
begin
  Gh.SetGridOptionsTitleAppearance(Frg1.DBGridEh1, False);
  PrintDBGridEh1.BeforeGridText[0] :=  GetCaption;
  //альбомная ориентация
  PrinterPreview.Orientation := poLandscape;
  //масштабируем всю таблицу для умещения на стронице
  //но если таблица меньше ширины страницы, то она не реасширится!!!
  PrintDBGridEh1.Options := Frg1.PrintDBGridEh1.Options + [pghFitGridToPageWidth];
  //откроет окно предпросмотра (в нормал)
  //так как здесь не останавливается, а внешний вид таблицы приводится сразу после к прежнему, то при манипуляциях со свойствами через диалог,
  //вид таблицы будет приведен к тому что на экране, те опять скроется подпись, появится бланк (и если другие были изменения для печати)!!!
  //правильнее создавать таблицу на скрытой форме именно для печати, копированием данных
  PrintDBGridEh1.Preview;
  Gh.SetGridOptionsTitleAppearance(Frg1.DBGridEh1, True);
end;

procedure TFrmWGedtAdvance.CalculateAll;
//пересчитаем всю таблицу
var
  i: Integer;
begin
  for i := 0 to Frg1.GetCount(False) - 1 do
    CalculateRow(i);
end;

procedure TFrmWGedtAdvance.CalculateRow(Row: Integer);
//посчитем значени в строке
var
  ENormM, ENormP, EHours: Extended;
begin
  if Row = -1 then
    Row := Frg1.MemTableEh1.RecNo - 1;
  ENormM := Frg1.GetValue('monthly_hours_norm', Row, False);
  ENormP := Frg1.GetValue('period_hours_norm', Row, False);
  EHours := Frg1.GetValue('hours_worked', Row, False);
  //Итого начислено: Расчет = (постоянная часть / норма рабочих часов за месяц * отработанные часы )
  if (Frg1.GetValue('planned_pay', Row, False).AsFloat <> 0) and (Frg1.GetValue('fixed_pay', Row, False) <> null) then
    Frg1.SetValue('base_pay', Row, False, Round(Frg1.GetValueF('fixed_pay', Row, False) / ENormM * EHours))
  else
    Frg1.SetValue('base_pay', Row, False, null);
  Frg1.SetValue('total_pay', Row, False, Round(Frg1.GetValue('base_pay', Row, False).AsFloat + Frg1.GetValue('correction', Row, False).AsFloat));
end;

end.
