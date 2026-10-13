unit uFrmWGedtPayrollTransfer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls,
  ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls, MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd,
  MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils, Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uFrmBasicGrid2, uFrDBGridEh, uFrmBasicMdi, uNamedArr
  ;

type
  TFrmWGedtPayrollTransfer = class(TFrmBasicGrid2)
  private
    FPayrollParams: TNamedArr;
    FDeletedWorkers: TVarDynArray;
    FIsEditableAdd, FIsEditableAll: Boolean;
    function  PrepareForm: Boolean; override;
    function  Save: Boolean; override;
    //события грида
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    //методы класса
    function  GetDataFromDb: Integer;
    function  GetCaption(Colored: Boolean = False): string;
    procedure SetButtons;
    procedure SetColumns;
    function  GetDataFromCalc: Integer;
    procedure CommitPayroll;
    procedure GetNdflFromExcel;
    procedure GetNdflFromExcelZup;
    procedure GetAdvanceFromExcelZup;
    procedure GetAdvPayFromExcel(AdvNo: Integer);
    procedure GetDeductionsFromExcel;
    procedure CalculateAll;
    procedure CalculateRow(Row:Integer);
//    procedure PrintGrid;
//    procedure ExportToXlsxA7;
    procedure SetEditableAll;

  public
  end;

var
  FrmWGedtPayrollTransfer: TFrmWGedtPayrollTransfer;

implementation

{$R *.dfm}

uses
  System.Win.ComObj, Winapi.ActiveX, Winapi.ShlObj, System.IOUtils,
  uMessages,
  uForms,
  uDBOra,
  uTurv,
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

  cFieldsS =
    'id$i;id_employee$i;id_organization$i;personnel_number$s;' +
    'total_pay$f;ors_pay$f;is_concurrent$f;deduct_enf$f;deduct_ndfl$f;pay_fss$f;pay_adv$f;pay_adv2$f;pay_adv3$f;pay_adv4$f;pay_adv5$f;pay_card$f;correction$f;advance$f;advance_official$f;pay_cash$f';
  cFieldsL =
    'employee$s;organization$s;changed$i;departament$s;temp$i';

  cmbtDeduction = 1001;
  cmbtCard = 1002;
  cmbt1C = 1003;
  cmbtEditAll = 1004;
  cmbRecalculate = 1005;
  cmbDeleteRow = 1007;
  cmbtAdvance = 1008;
  cmbtAdvaPay1 = 1011;
  cmbtAdvaPay2 = 1012;
  cmbtAdvaPay3 = 1013;
  cmbtAdvaPay4 = 1014;
  cmbtAdvaPay5 = 1015;

  cColWidth = 65;


function TFrmWGedtPayrollTransfer.PrepareForm: Boolean;
var
  i, j, w1: Integer;
  v: Variant;
  wcol, fcol: string;
begin
  Result:=False;

  Caption:='Ведомость к перечислению';
  FOpt.RefreshParent := True;

  if FormDbLock = fNone then Exit;

  Q.QLoad('select id, id_employee, id_organization, personnel_number, dt, dt1, dt2,  employee, is_finalized from v_w_payroll_transfer where id = :id$i', [ID], FPayrollParams);
  if FPayrollParams.Count = 0 then begin
    MsgRecordIsDeleted;
    Exit;
  end;

  FDeletedWorkers := [];
  Frg1.Options := FrDBGridOptionDef + [myogPanelFind, myogColumnResize, myogPanelfind, myogSorting, myogHasStatusBar] - [myogColumnFilter];

  //определим поля
  //теги (1-редактирования кроме расчета по мотивации, 2-дополнительное редактирование,3-редактировать всегда)
  wcol := IntToStr(cColWidth) + ';r';
  fcol := 'f=###,###,###:';
  Frg1.Opt.SetFields([
    ['id$i', '_id','40'],
    ['id_employee$i', '_id_employee', wcol],
    ['id_organization$i', '_id_org', wcol],
    ['changed$i', '_changed', wcol],
    ['temp$i', '_temp', wcol],

    ['employee$s', 'Работник|ФИО', '200;h'],
    ['organization$s', '!Организация', '100'],
    ['departament$s', '!Подразделение', '200'],
    ['personnel_number$s', '!Табельный номер', '60'],
    ['is_concurrent$i', '!Совмес-'#13#10'титель', '60', 'pic' ,'i'],

    ['total_pay$f', '~Итого' + sLineBreak + ' начислено', wcol, fcol],
    ['ors_pay$f', '~ОРС '#13#10'сумма', wcol, fcol, 'i', (Mode <> fEdit) or True],
    ['deduct_enf$f', '~Удержано/ '#13#10'Исп. лист', wcol, fcol, 't=1'],
    ['deduct_ndfl$f', '~НДФЛ', wcol, fcol, 't=1', 'i'],
    ['pay_fss$f', '~Выплачено'#13#10' ФСС', wcol, fcol, 't=1'],
    ['pay_adv$f', '~Промежуточная'#13#10' выплата', wcol, fcol, 't=1'],
    ['pay_adv2$f', '~Промежуточная'#13#10' выплата 2', wcol, fcol, 't=1'],
    ['pay_adv3$f', '~Промежуточная'#13#10' выплата 3', wcol, fcol, 't=1'],
    ['pay_adv4$f', '~Промежуточная'#13#10' выплата 4', wcol, fcol, 't=1'],
    ['pay_adv5$f', '~Промежуточная'#13#10' выплата 5', wcol, fcol, 't=1'],
    ['pay_card$f', '~Карта', wcol, fcol, 't=1'],
    ['advance$f', '~Аванс н/о', wcol, fcol, 't=1'],
    ['advance_official$f', '~Аванс офф.', wcol, fcol, 't=1'],
    ['correction$f', '~Корректировка', wcol, fcol, 't=1'],
    ['pay_cash$f', '~Итого к'#13#10' получению', wcol, fcol]
//    ['$f', '', wcol, fcol],
  ]);
  Frg1.Opt.SetGridOperations('ud');
  Frg1.Opt.SetButtons(1, [
    [mbtRefresh, True, 'Обновить данные из расчетных ведомостей'],[],
    [mbtDividorM],
    [cmbt1C, True, True, 'Загрузка данных из 1С', '1c'],
    [cmbtCard, True, True, 'Загрузить карты', ''],
    [cmbtAdvance, True, True, 'Загрузить аванс', ''],
    [cmbtAdvaPay1, True, True, 'Загрузить промежуточные выплаты 1', ''],
    [cmbtAdvaPay2, True, True, 'Загрузить промежуточные выплаты 2', ''],
    [cmbtAdvaPay3, True, True, 'Загрузить промежуточные выплаты 3', ''],
    [cmbtAdvaPay4, True, True, 'Загрузить промежуточные выплаты 4', ''],
    [cmbtAdvaPay5, True, True, 'Загрузить промежуточные выплаты 5', ''],
    [mbtDividorM],
    //[mbtDividorM],[mbtPrint],[mbtPrintGrid],[mbtDividorM],
    [],[mbtLock],
    [], [-mbtExcel, AddParam = null],
    [],[-cmbtEditAll, True, 'Разрешить редактирование всех полей'],
    [],[-cmbRecalculate, True, 'Пересчитать все'],
    [],[mbtCtlPanel]
  ]);
  Frg1.Opt.ButtonsNoAutoState := [0];

  Frg1.CreateAddControls('1', cntLabelClr, GetCaption(True), 'lblDivision', '', 4, yrefT, 800);
  Frg1.CreateAddControls('1', cntLabelClr, '', 'lblInfo', '', 4, yrefB, 800);
  Frg1.SetInitData([], '');

  Frg1.InfoArray := [[
    'Ведомость к перечислению.'#13#10#13#10
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
    GetDataFromCalc;
  SetButtons;

  Result:=True;
//mode := fEdit;
end;

function TFrmWGedtPayrollTransfer.GetDataFromDb: Integer;
//прочитаем ведомость (все данные) из БД и заполним ими сетку
var
  na : TNamedArr;
begin
  Q.QLoad(Q.QGetSql('a', 'v_w_payroll_transfer_item', cFieldsS + ';' + cFieldsL) +
    ' where id_payroll_transfer = :id$i' + S.IIFStr(AddParam <> null,
    ' and id_employee = ' + AddParam.AsString) + ' order by employee, organization, personnel_number',
    [ID], na
  );
  Frg1.LoadData(na);
end;

function TFrmWGedtPayrollTransfer.GetCaption(Colored: Boolean = False): string;
begin
  Result := S.IIFStr(Colored, '$FF0000') + S.IIf(FPayrollParams.G('employee') <> null, FPayrollParams.G('employee'), 'Все работники') +
    S.IIFStr(Colored, '$000000') + ' с' + S.IIFStr(Colored, '$FF00FF') +' ' + DateToStr(FPayrollParams.G('dt1')) +
    S.IIFStr(Colored, '$000000') + ' по ' + S.IIFStr(Colored,  '$FF00FF') + DateToStr(FPayrollParams.G('dt2'));
end;

function TFrmWGedtPayrollTransfer.Save: Boolean;
//сохраним ведомость
var
  i, j: Integer;
  f, fn, va: TVarDynArray;
begin
  Result := False;
  Q.QBeginTrans(True);
  Q.QExecSql('update w_payroll_transfer set is_finalized = :p3$i where id = :id$i', [FPayrollParams.G('is_finalized'), ID]);
  //удалим из БД всех, кого удаляли из списка при нажатии кнопки ТУРВ
  if Length(FDeletedWorkers) > 0 then
    Q.QExecSql('delete from w_payroll_transfer_item where id in (' + A.Implode(FDeletedWorkers, ',') + ')', []);
  //обновим в бд все строки таблицы
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    //если строка не была прочитана ранее из бд - вставим
    if Frg1.GetValueI('id', i, False) = 0 then begin
      var idn := Q.QSave('i', 'w_payroll_transfer_item', '', 'id$i;id_payroll_transfer$i', [-1, ID]);
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
    Q.QSave('u', 'w_payroll_transfer_item', '', cFieldsS, va);
  end;
  Q.QCommitTrans;
  Result := Q.CommitSuccess;
end;


procedure TFrmWGedtPayrollTransfer.SetButtons;
var
  i: Integer;
  NoNorms: Boolean;
begin
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtRefresh, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtDeduction, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtCard, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtAdvance, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtAdvaPay1, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtAdvaPay2, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtAdvaPay3, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtAdvaPay4, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtAdvaPay5, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtLock, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbt1C, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtEditAll, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbRecalculate, null, False);
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
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtRefresh, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtDeduction, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtCard, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtAdvance, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtAdvaPay1, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtAdvaPay2, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtAdvaPay3, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtAdvaPay4, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtAdvaPay5, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtLock, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbt1C, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtEditAll, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbRecalculate, null, True);
    Frg1.DbGridEh1.ReadOnly := False;
  end;
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtLock, S.IIf(FPayrollParams.G('is_finalized') = 1, 'Отменить закрытие ведомости', 'Закрыть ведомость'), null);
  SetColumns;
  Frg1.DbGridEh1.Invalidate;
//Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtCard, null, True); //!!!
end;


procedure TFrmWGedtPayrollTransfer.SetColumns;
begin
  Frg1.Opt.SetColFeature('*', 'e', False, False);
  Frg1.Opt.SetColFeature('1', 'e', True, False);
  if FIsEditableAll then
    Frg1.Opt.SetColFeature('*', 'e', True, False);
  Frg1.SetColumnsVisible;
end;

procedure TFrmWGedtPayrollTransfer.CommitPayroll;
begin
  if MyQuestionMessage(S.IIf(S.NInt(FPayrollParams.G('is_finalized')) = 1, 'Снять статус "Закрыта" для ведомости?', 'Поставить статус "Закрыта" для ведомости?')) <> mrYes then
    Exit;
  FPayrollParams.SetValue(0, 'is_finalized', IIf(S.NInt(FPayrollParams.G('is_finalized')) = 1, 0, 1));
  Frg1.SetState(True, null, null);
  SetButtons;
end;


procedure TFrmWGedtPayrollTransfer.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if A.InArray(FieldName, ['employee', 'organization', 'personnel_number', 'is_concurrent', 'departament']) then
      Params.Background := clmyGray;
  if A.InArray(FieldName, ['total_pay', 'pay_cash']) then
      Params.Background := RGB(220, 255, 190);
  if A.InArray(FieldName, ['total_pay', 'pay_cash']) and (Frg2.GetValueF(FieldName) < 0) then
      Params.Background := clRed;
end;

procedure TFrmWGedtPayrollTransfer.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  Handled := True;
  case Tag of
    mbtRefresh:
      if MyQuestionMessage('Загрузить данные из расчетных ведомостей?') = mrYes then
        GetDataFromCalc;
    cmbtCard:
      if MyQuestionMessage('Загрузить карты?') = mrYes then
        GetNdflFromExcelZup;
    cmbtAdvance:
      if MyQuestionMessage('Загрузить авансовые выплаты?') = mrYes then
        GetAdvanceFromExcelZup;
    cmbtDeduction:
      if MyQuestionMessage('Загрузить удержания?') = mrYes then
        GetDeductionsFromExcel;
    cmbRecalculate:
      begin
        CalculateAll;
        Frg1.SetState(True, null, null);
        Frg1.InvalidateGrid;
      end;
    cmbtAdvaPay1, cmbtAdvaPay2, cmbtAdvaPay3, cmbtAdvaPay4, cmbtAdvaPay5:
      if MyQuestionMessage('Загрузить промежуточные выплаты ' + IntToStr(Tag - cmbtAdvaPay1 + 1) + '?') = mrYes then
        GetAdvPayFromExcel(Tag - cmbtAdvaPay1 + 1);
    cmbDeleteRow:
      if MyQuestionMessage('Удалить строку?') = mrYes then begin
        FDeletedWorkers := FDeletedWorkers + [Frg1.GetValue('id')];
        Frg1.DeleteRow;
        Frg1.InvalidateGrid;
        Frg1.SetState(True, null, null);
      end;
//    mbtExcel:
//      ExportToXlsxA7;
//    mbtPrintGrid:
//      PrintGrid;
    mbtLock:
      CommitPayroll;
  else
    Handled := False;
  end;
  if Handled then
    SetButtons;
end;


function TFrmWGedtPayrollTransfer.GetDataFromCalc: Integer;
//читаем данные из по нажатию соотв кнопки
var
  i, j, k: Integer;
  st1, st2, st3: string;
  v1, v2: Variant;
  b: Boolean;
  NoData: Boolean;
  na, na1, na2, advance: TNamedArr;
  MsgDel, MsgIns, MsgChg: string;
  flds: TVarDynArray2;
  flds1, flds2: TVarDynArray;
  va2: TVarDynArray2;
  cash : Extended;
begin
  //загружаем данные только в режиме редактирования
  if Mode <> fEdit then
    Exit;

  //поля, по кторым сравниваем для сопоставления данных в турв и гшриде
  flds1 := ['id_employee', 'id_organization', 'personnel_number'];
  //поля для заголовка сообщания об изменениях
  flds2 := ['employee', 'organization', 'personnel_number'];
  //загрузим сгруппированные данные из зарплатных расчетных ведомостей, те поля которые есть в в ведомости к перечислению
  if FPayrollParams.G('id_employee') <> null then
    Q.QLoad(
      'select id_employee, id_organization, personnel_number, max(employee) as employee, max(organization) as organization, sum(total_pay) as total_pay, sum(ors_pay) as ors_pay, null as advance, null as temp ' +
      'from v_w_payroll_calc_item where id_employee = :p1$i and nvl(id_organization, -100) = nvl(:p2$i, -100) and nvl(personnel_number, -100) = nvl(:p3$s, -100) and dt = :dt$d and id_target_employee is not null ' +
      'group by id_employee, id_organization, personnel_number order by employee',
      [FPayrollParams.G('id_employee'), FPayrollParams.G('id_organization'), FPayrollParams.G('personnel_number'),  FPayrollParams.G('dt')],
      na1
    )
  else
    Q.QLoad(
      'select id_employee, id_organization, personnel_number, ' +
      'max(employee) as employee, max(organization) as organization, sum(total_pay) as total_pay, sum(ors_pay) as ors_pay, null as advance, null as temp ' +
      'from v_w_payroll_calc_item where dt = :dt$d and id_target_employee is null ' +
      'group by id_employee, id_organization, personnel_number order by employee',
      [FPayrollParams.G('dt')],
      na1
    );
  //для неоформленных, или при ведомости по всем - загрузим аванс
  if FPayrollParams.G('id_organization') = null then begin
    Q.QLoad(
      'select id_employee, null as id_organization, personnel_number, pay_cash from v_w_advance_transfer_item where dt = :dt$d',
      [FPayrollParams.G('dt')],
      advance
    );
    va2 := na1.CompareWith(advance, 'id_employee;id_organization;personnel_number', '');
    for i := 0 to High(va2) do
      if (va2[i][0] >= 0) and (va2[i][1] >= 0) then
        na1.SetValue(va2[i][0], 'advance', advance.G(va2[i][1], 'pay_cash'));
  end;

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
    for j := 0 to na1.Count - 1 do begin
      st2 := '';
      for k := 0 to High(flds1) do
        S.ConcatStP(st2, na1.G(j, flds1[k]).AsString, '|');
      if st1 = st2 then begin
        b := True;
        //сохраним во временной поле массива турв позицию из грида (из загруженной расчетной ведомости)
        na1.SetValue(j, 'temp', i);
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
  for i := 0 to na1.Count - 1 do begin
    //если строки, которая есть в турв, нет в ведомости
    if na1.G(i, 'temp').AsIntegerM = -1 then begin
      //данные строки для сообщения
      st1 := '';
      for k := 0 to High(flds2) do
        S.ConcatStP(st1, na1.G(i, flds2[k]).AsString, ' | ');
      S.ConcatStP(MsgIns, st1, #13#10);
      //добавим строку
      na.IncLength;
      na.SetNull(na.High);
      //установим поля и итоговые данные из турв
      for k := 0 to High(na1.F) do
        na.SetValue(na.High, na1.F[k], na1.G(i, na1.F[k]));
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
      if na.G(i, 'total_pay') <> na1.G(j, 'total_pay') then begin
        st2 := st2 + ' Сумма:   "' + na.G(i, 'total_pay').AsString  + '" -> "' + na1.G(j, 'total_pay').AsString + '""';
        na.SetValue(i, 'total_pay', na1.G(j, 'total_pay'));
      end;
      if na.G(i, 'ors_pay') <> na1.G(j, 'ors_pay') then begin
        st2 := st2 + ' ОРС:   "' + na.G(i, 'ors_pay').AsString  + '" -> "' + na1.G(j, 'ors_pay').AsString + '""';
        na.SetValue(i, 'ors_pay', na1.G(j, 'ors_pay'));
      end;
      //аванс заполняем только для неоформленных
      if (na.G(i, 'id_organization') = null) and (na.G(i, 'advance') <> na1.G(j, 'advance')) then begin
        st2 := st2 + ' Аванс:   "' + na.G(i, 'advance').AsString  + '" -> "' + na1.G(j, 'advance').AsString + '""';
        na.SetValue(i, 'advance', na1.G(j, 'advance'));
      end;
      if st2 <> '' then begin
        st1 := '';
        for k := 0 to High(flds2) do
          S.ConcatStP(st1, na.G(i, flds2[k]).AsString, ' | ');
        S.ConcatStP(MsgChg, st1 + ': ' + st2, #13#10);
      end;
    end;
  end;

  //загрузим данные в грид
  Frg1.LoadData(na);
  CalculateAll;

  if MsgIns + MsgDel + MsgChg = '' then begin
    MyInfoMessage('Изменений в ведомости не было.');
  end
  else begin
    Frg1.SetState(True, null, null);
    MyInfoMessage(
      'Данные обновлены.'#13#10#13#10 +
      S.IIFStr(MsgIns <> '', 'Внесены записи:'#13#10 + MsgIns + #13#10#13#10) +
      S.IIFStr(MsgDel <> '', 'Удалены записи:'#13#10 + MsgDel + #13#10#13#10) +
      S.IIFStr(MsgChg <> '', 'Изменены записи:'#13#10 + MsgChg),
      1
    );
  end;

end;

procedure TFrmWGedtPayrollTransfer.SetEditableAll;
begin
  if Frg1.DbGridEh1.ReadOnly then
    Exit;
  if User.IsDeveloper then
    FIsEditableAll := not FIsEditableAll;
  SetColumns;
end;

procedure TFrmWGedtPayrollTransfer.CalculateAll;
var
  i: Integer;
begin
  for i := 0 to Frg1.GetCount(False) - 1 do
    CalculateRow(i);
  Frg1.InvalidateGrid;
end;

procedure TFrmWGedtPayrollTransfer.CalculateRow(Row: Integer);
begin
  if Row = -1 then
    Row := Frg1.MemTableEh1.RecNo - 1;
  Frg1.SetValue('pay_cash', Row, False, RoundTo(
    Frg1.GetValueF('total_pay', Row, False) - Frg1.GetValueF('deduct_enf', Row, False){ - Frg1.GetValueF('deduct_ndfl', Row, False)} - Frg1.GetValueF('pay_fss', Row, False) -
    Frg1.GetValueF('advance', Row, False) - Frg1.GetValueF('advance_official', Row, False) -
    Frg1.GetValueF('pay_adv', Row, False) - Frg1.GetValueF('pay_adv2', Row, False) - Frg1.GetValueF('pay_adv3', Row, False) - Frg1.GetValueF('pay_adv4', Row, False) - Frg1.GetValueF('pay_adv5', Row, False) -
    Frg1.GetValueF('pay_card', Row, False) + Frg1.GetValueF('correction', Row, False), 2
  ));
end;

(*
procedure TFrmWGedtPayrollTransfer.GetNdflFromExcel;
//старый вариант
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
  EmplCn := Q.QLoadCol('select id from w_employees where is_concurrent = 1', []);
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
  //стобцы 1-фило, 3-ндфл, 4-карты
  //пройдем по списку работников в ведомости
  b1 := False;
  b2 := False;
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    //проверим, не совместитель ли
    b := A.InArray(Frg1.GetValueF('id_employee', i, False), EmplCn);
    //пройдем по загруженным из файла даннм
    j := 0;
    while j <= High(ArXls) do begin
      //проверим по свопадению имени и табельного номера, или же только по имени, если совместитель, организацию не учитываем
      if (Frg1.GetValueS('employee', i, False) = ArXls[j][0]) and (b or (Frg1.GetValueS('personnel_number', i, False) = ArXls[j][1])) then begin
        e1 := ArXls[j][2].AsFloat;
        e2 := ArXls[j][3].AsFloat;
        //и если совместитель то просуммируем все строки с таким фио
        if b then
          for k := j + 1 to High(ArXls) do
            if Frg1.GetValueS('employee', i, False) = ArXls[k][0] then begin
              e1 := e1+ ArXls[k][2].AsFloat;
              e2 := e2 + ArXls[k][3].AsFloat;
            end;
        //проверим что полученные данные численно отличаются от того что уже в ведомости
        if Frg1.GetValueF('deduct_ndfl', i, False) <> Round(e1) then begin
          //если отличаются - заполним ведомсть, статус из менения, и выдадим сообщение
          st := st + Frg1.GetValueS('employee', i, False) + ': Изменен столбец НДФЛ с ' + Frg1.GetValueS('deduct_ndfl', i, False) + ' на ' + VarToStr(S.NullIf0(Round(e1))) + #13#10;
          Frg1.SetValue('deduct_ndfl', i, False, S.NullIf0(e1));
          FIsChanged := True;
          b1 := True;
        end;
        if Frg1.GetValueF('pay_card', i, False) <> Round(e2) then begin
          //если отличаются - заполним ведомсть, статус из менения, и выдадим сообщение
          st := st + Frg1.GetValueS('employee', i, False) + ': Изменен столбец Карта с ' + Frg1.GetValueS('pay_card', i, False) + ' на ' + VarToStr(S.NullIf0(Round(e2))) + #13#10;
          Frg1.SetValue('pay_card', i, False, S.NullIf0(e2));
          FIsChanged := True;
          b1 := True;
        end;
      Break;
      end;
      inc(j);
    end;
    //проверим, что работник в списке выгрузки не найден
    if j > High(ArXls) then begin
      st := st + Frg1.GetValueS('employee', i, False) + ': Не найден в файлах выгрузки!' + #13#10;
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
end;
*)

procedure TFrmWGedtPayrollTransfer.GetNdflFromExcel;
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
  org: string;
begin
  //выберем файл
  MyData.OpenDialog1.Filter := 'файлы Excel (*.xlsx)|*.xlsx';
  if not MyData.OpenDialog1.Execute then
    Exit;
  if not CreateTXlsMemFileEhFromExists(MyData.OpenDialog1.FileName, True, '$2', XlsFile, st) then
    Exit;
  //получим список совместителей
  EmplCn := Q.QLoadCol('select id from w_employees where is_concurrent = 1', []);
  //загрузим в массив данные из эксель со второй строки до первой пустой
  ArXls := [];
  sh := XlsFile.Workbook.Worksheets[0];
  org := sh.Cells[4 - 1, 1].Value.AsString;
  for i := 4 to 2000 do begin
    if (sh.Cells[2 - 1, i].Value.AsString = '') then
      Break;
    if (sh.Cells[2 - 1, i].Value.AsString = '') then
      Continue;
    //фио, таб.номер, ндфл, карта, организация(из заголовка)
    ArXls := ArXls + [[sh.Cells[7 - 1, i].Value.AsString, sh.Cells[5 - 1, i].Value.AsString, 0 {sh.Cells[8 - 1, i].Value.AsFloat}, sh.Cells[6 - 1, i].Value.AsFloat, org]];
  end;
  sh.Free;
  XlsFile.Free;
  //стобцы 1-фило, 3-ндфл, 4-карты
  //пройдем по списку работников в ведомости
  b1 := False;
  b2 := False;
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    //проверим, не совместитель ли
    b := A.InArray(Frg1.GetValueF('id_employee', i, False), EmplCn);
    //пройдем по загруженным из файла даннм
    j := 0;
    while j <= High(ArXls) do begin
      //проверим по свопадению имени и табельного номера, или же только по имени, если совместитель, организацию не учитываем
      //!!!пока не проверяем по табельному номеру
      if (Frg1.GetValueS('employee', i, False) = ArXls[j][0]) {and (b or (Frg1.GetValueS('personnel_number', i, False) = ArXls[j][1]))} then begin
        e1 := ArXls[j][2].AsFloat;
        e2 := ArXls[j][3].AsFloat;
        //и если совместитель то просуммируем все строки с таким фио
        if b then
          for k := j + 1 to High(ArXls) do
            if Frg1.GetValueS('employee', i, False) = ArXls[k][0] then begin
              e1 := e1+ ArXls[k][2].AsFloat;
              e2 := e2 + ArXls[k][3].AsFloat;
            end;
        //проверим что полученные данные численно отличаются от того что уже в ведомости
  {      if Frg1.GetValueF('deduct_ndfl', i, False) <> Round(e1) then begin
          //если отличаются - заполним ведомсть, статус из менения, и выдадим сообщение
          st := st + Frg1.GetValueS('employee', i, False) + ': Изменен столбец НДФЛ с ' + Frg1.GetValueS('deduct_ndfl', i, False) + ' на ' + VarToStr(S.NullIf0(Round(e1))) + #13#10;
          Frg1.SetValue('deduct_ndfl', i, False, S.NullIf0(e1));
          Frg1.SetState(True, null, null);
          b1 := True;
        end;       }
        if Frg1.GetValueF('pay_card', i, False) <> Round(e2) then begin
          //если отличаются - заполним ведомсть, статус из менения, и выдадим сообщение
          st := st + Frg1.GetValueS('employee', i, False) + ': Изменен столбец Карта с ' + Frg1.GetValueS('pay_card', i, False) + ' на ' + VarToStr(S.NullIf0(Round(e2))) + #13#10;
          Frg1.SetValue('pay_card', i, False, S.NullIf0(e2));
          Frg1.SetState(True, null, null);
          b1 := True;
        end;
      Break;
      end;
      inc(j);
    end;
    //проверим, что работник в списке выгрузки не найден
    if j > High(ArXls) then begin
      st := st + Frg1.GetValueS('employee', i, False) + ': Не найден в файлах выгрузки!' + #13#10;
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
end;

procedure TFrmWGedtPayrollTransfer.GetDeductionsFromExcel;
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
  EmplCn := Q.QLoadCol('select id from w_employees where is_concurrent = 1', []);
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
    b := A.InArray(Frg1.GetValueF('id_employee', i, False), EmplCn);
    //пройдем по загруженным из файла даннм
    j := 0;
    while j <= High(ArXls) do begin
      //проверим по свопадению имени и табельного номера, или же только по имени, если совместитель, организацию не учитываем
      if (Frg1.GetValueS('employee', i, False) = ArXls[j][0]) and (b or (Frg1.GetValueS('personnel_number', i, False) = ArXls[j][1])) then begin
{        //посмотрим, нет ли заполненного значения для этого работника в других ведомостях за этот же период
        if Q.QSelectOneRow(
            'select count(*) from v_payroll_item where id_worker = :id_worker$i and id_division <> :id_division$i and dt1 = :dt1$d and ud is not null',
            [Frg1.GetValueF('id_worker', i, False), FPayrollParams.G('id_division'), FPayrollParams.G('dt1')]
          )[0] > 0
        then begin
          //сообщение если есть, и тогда данные не заполняем
          st := st + Frg1.GetValueS('workername', i, False) + ': Найден в другом подпразделении, данные не внесены!' + #13#10;
          b2 := True;
        end
        else }begin
          //если нет в других ведомостям, берем данные из файла
          e := ArXls[j][2].AsFloat;
          //и если совместитель то просуммируем все строки с таким фио
          if b then
            for k := j + 1 to High(ArXls) do
              if Frg1.GetValueS('employee', i, False) = ArXls[k][0] then
                e := e + ArXls[k][2].AsFloat;
          //проверим что полученные данные численно отличаются от того что уже в ведомости
          if Frg1.GetValueF('deduct_enf', i, False) <> Round(e) then begin
            //если отличаются - заполним ведомсть удержание, статус из менения, и выдадим сообщение
            st := st + Frg1.GetValueS('employee', i, False) + ': Изменен столбец Удержано с ' + Frg1.GetValueS('deduct_enf', i, False) + ' на ' + VarToStr(S.NullIf0(e)) + #13#10;
            Frg1.SetValue('deduct_enf', i, False, S.NullIf0(e));
//            Frg1.SetValue('changed', i, False, 1);
            Frg1.SetState(True, null, null);
            b1 := True;
          end;
        end;
        Break;
      end;
      inc(j);
    end;
    //проверим, что работник в списке выгрузки не найден
    if j > High(ArXls) then begin
      st := st + Frg1.GetValueS('employee', i, False) + ': Не найден в файлах выгрузки!' + #13#10;
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
end;

procedure TFrmWGedtPayrollTransfer.Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
//вызывается после ручного изменения ячейки. установим статус изменения грида и пересчитаем строку
begin
  Fr.SetState(True, null, null);
  CalculateRow(-1);
end;


(*
procedure TFrmWGedtPayrollTransfer.GetNdflFromExcelZup;
var
  i, j, k: Integer;
  st, st1: string;
  v, v1, v2: Variant;
  b, b1, b2: Boolean;
  XlsFile: TXlsMemFileEh;
  sh, sh1: TXlsWorksheetEh;
  ArXls: TVarDynArray2;
  EmplCn: TVarDynArray;
  e1, e2, e3: Extended;
begin
  //выберем файл
  MyData.FileOpenDialog1.Options := MyData.FileOpenDialog1.Options + [fdoAllowMultiSelect];
  MyData.FileOpenDialog1.FileTypes.Clear;
  with MyData.FileOpenDialog1.FileTypes.Add do begin DisplayName := 'файлы Excel (*.xlsx)'; FileMask := '*.xlsx'; end;
  if not MyData.FileOpenDialog1.Execute then
    Exit;
//      for i := 0 to MyData.FileOpenDialog1.Files.Count - 1 do
  //получим список совместителей
  EmplCn := Q.QLoadCol('select id from w_employees where is_concurrent = 1', []);
  //загрузим в массив данные из эксель со второй строки до первой пустой
  ArXls := [];

  for var fn := 0 to MyData.FileOpenDialog1.Files.Count - 1 do begin
    if not CreateTXlsMemFileEhFromExists(MyData.FileOpenDialog1.Files[fn], True, '$2', XlsFile, st) then
      Exit;
    sh := XlsFile.Workbook.Worksheets[0];
    for i := 9 to 2000 do begin
      if (sh.Cells[1 - 1, i].Value.AsString = '') and (sh.Cells[2 - 1, i].Value.AsString = '') then
        Break;
      if (sh.Cells[4 - 1, i].Value.AsString = '') then
        Continue;
   {   if (High(ArXls) > 0) and (sh.Cells[2 - 1, i].Value.AsString = ArXls[High(ArXls) - 1][0]) and ((sh.Cells[3 - 1, i].Value.AsString = '') or (ArXls[High(ArXls) - 1][1] = '')) then begin
        if sh.Cells[3 - 1, i].Value.AsString <> '' then
          ArXls[High(ArXls) - 1][1] := sh.Cells[3 - 1, i].Value.AsString;
        if sh.Cells[5- 1, i].Value.AsString <> '' then
          ArXls[High(ArXls) - 1][2] := sh.Cells[5- 1, i].Value.AsString;
        if sh.Cells[6- 1, i].Value.AsString <> '' then
          ArXls[High(ArXls) - 1][3] := sh.Cells[6- 1, i].Value.AsString;
      end
      else  }
        ArXls := ArXls + [[sh.Cells[1 - 1, i].Value.AsString, {sh.Cells[3 - 1, i].Value.AsString} 0, sh.Cells[8 - 1, i].Value.AsFloat, sh.Cells[10 - 1, i].Value.AsFloat, sh.Cells[9 - 1, i].Value.AsFloat]];
    end;
    sh.Free;
    XlsFile.Free;
  end;
  //стобцы 1-фило, 3-ндфл, 4-карты
  //пройдем по списку работников в ведомости
  b1 := False;
  b2 := False;
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    //проверим, не совместитель ли
    b := A.InArray(Frg1.GetValueF('id_employee', i, False), EmplCn);
    //пройдем по загруженным из файла даннм
    j := 0;
    while j <= High(ArXls) do begin
      //проверим по свопадению имени и табельного номера, или же только по имени, если совместитель, организацию не учитываем
      if (Frg1.GetValueS('employee', i, False) = ArXls[j][0]) {and (b or (Frg1.GetValueS('personnel_number', i, False) = ArXls[j][1]))} then begin
        e1 := ArXls[j][2].AsFloat;
        e2 := ArXls[j][3].AsFloat;
        e3 := ArXls[j][4].AsFloat;
        //и если совместитель то просуммируем все строки с таким фио
        if b then
          for k := j + 1 to High(ArXls) do
            if Frg1.GetValueS('employee', i, False) = ArXls[k][0] then begin
              e1 := e1+ ArXls[k][2].AsFloat;
              e2 := e2 + ArXls[k][3].AsFloat;
              e3 := e3 + ArXls[k][4].AsFloat;
            end;
        e1 := Round(e1); e2 := Round(e2); e3 := Round(e3);
        //проверим что полученные данные численно отличаются от того что уже в ведомости
        if Frg1.GetValueF('deduct_ndfl', i, False) <> Round(e1) then begin
          //если отличаются - заполним ведомсть, статус из менения, и выдадим сообщение
          st := st + Frg1.GetValueS('employee', i, False) + ': Изменен столбец НДФЛ с ' + Frg1.GetValueS('deduct_ndfl', i, False) + ' на ' + VarToStr(S.NullIf0(Round(e1))) + #13#10;
          Frg1.SetValue('deduct_ndfl', i, False, S.NullIf0(e1));
          FIsChanged := True;
          b1 := True;
        end;
        if Frg1.GetValueF('pay_card', i, False) <> Round(e2) then begin
          //если отличаются - заполним ведомсть, статус из менения, и выдадим сообщение
          st := st + Frg1.GetValueS('employee', i, False) + ': Изменен столбец Карта с ' + Frg1.GetValueS('pay_card', i, False) + ' на ' + VarToStr(S.NullIf0(Round(e2))) + #13#10;
          Frg1.SetValue('pay_card', i, False, S.NullIf0(e2));
          FIsChanged := True;
          b1 := True;
        end;
        if Frg1.GetValueF('deduct_enf', i, False) <> Round(e3) then begin
          //если отличаются - заполним ведомсть, статус из менения, и выдадим сообщение
          st := st + Frg1.GetValueS('employee', i, False) + ': Изменен столбец Удержано с ' + Frg1.GetValueS('deduct_enf', i, False) + ' на ' + VarToStr(S.NullIf0(Round(e3))) + #13#10;
          Frg1.SetValue('deduct_enf', i, False, S.NullIf0(e3));
          FIsChanged := True;
          b1 := True;
        end;
Break;
      end;
      inc(j);
    end;
    //проверим, что работник в списке выгрузки не найден
    if j > High(ArXls) then begin
      st := st + Frg1.GetValueS('employee', i, False) + ': Не найден в файлах выгрузки!' + #13#10;
      b2 := True;
    end;
  end;
  //пересчитаем таблицу
  CalculateAll;
  //выведем сообщение
  if b1 or b2 then
    MyInfoMessage('Данные загружены' + S.IIf(b2, ', однако не по всем работникам!', '.') + #13#10#13#10 + S.IIFStr(not b1 and not b2, 'Изменений не было.', st), 1)
  else
    MyInfoMessage('Данные загружены.');
end;*)

{$IFDEF NDFL_LOAD_OLD}
(* СТАРАЯ ВЕРСИЯ (до переработки, 08.10.2026) - не компилируется, оставлена для справки.
   проблемы: сопоставление только по ФИО (табельный номер и организация не учитывались), первая найденная строка
   файла брала на себя всю сумму, для совместителей суммировались ВСЕ строки с таким ФИО и ставились в КАЖДУЮ строку
   ведомости этого работника (при нескольких организациях - дублирование сумм); строки файлов, которых нет в
   ведомости, не выводились вообще; в сообщении не было сумм. включить обратно - определить NDFL_LOAD_OLD, при этом
   нужно переименовать одну из процедур *)
procedure TFrmWGedtPayrollTransfer.GetNdflFromExcelZup;
//файлы выгружаются из ЗУП в формате, нечитаемом в этой программе.
//необходимо перед загрузкой открыть в экселе и пересохранить
//например, в пустой части верха документа ввести что-то в ячейку и сохранить. этого достаточно!!!
var
  i, j, k: Integer;
  st, st1: string;
  v, v1, v2: Variant;
  b, b1, b2: Boolean;
  XlsFile: TXlsMemFileEh;
  sh, sh1: TXlsWorksheetEh;
  ArXls: TVarDynArray2;
  EmplCn: TVarDynArray;
  e1, e2, e3: Extended;
  org, dir: string;

function GetSelectedFiles(OpenDialog: TFileOpenDialog): TArray<string>;
var
  i: Integer;
  ShellItemArray: IShellItemArray;
  ShellItem: IShellItem;
  pszPath: PWideChar;
  Count: DWORD;
begin
  SetLength(Result, 0);

  ShellItemArray := OpenDialog.ShellItems;

  if ShellItemArray = nil then
    Exit;

  if Failed(ShellItemArray.GetCount(Count)) then
    Exit;

  SetLength(Result, Count);

  for i := 0 to Count - 1 do
  begin
    if Failed(ShellItemArray.GetItemAt(i, ShellItem)) then
      Continue;

    if Succeeded(ShellItem.GetDisplayName(SIGDN_FILESYSPATH, pszPath)) then
    begin
      Result[i] := pszPath;
      CoTaskMemFree(pszPath);
    end;
  end;
end;

begin

  //выберем файл
  MyData.FileOpenDialog1.Options := MyData.FileOpenDialog1.Options + [fdoAllowMultiSelect];
  MyData.FileOpenDialog1.FileTypes.Clear;
  with MyData.FileOpenDialog1.FileTypes.Add do begin DisplayName := 'файлы Excel (*.xlsx)'; FileMask := '*.xlsx'; end;
  if not MyData.FileOpenDialog1.Execute then
    Exit;
  //загрузим в массив данные из эксель со второй строки до первой пустой
  ArXls := [];
  var files := GetSelectedFiles(MyData.FileOpenDialog1);
(*  with TFileOpenDialog.Create(nil) do
    try
      Title := 'Выберите папку';
      Options := [fdoPickFolders, fdoPathMustExist, fdoForceFileSystem]; // YMMV
      OkButtonLabel := 'Выбрать';
      if Execute then begin
        Dir := FileName;
      end;
    finally
      Free;
    end;
  if Dir = '' then
    Exit;
  if Dir = TDirectory.GetDirectoryRoot(Dir) then begin
    MyWarningMessage('Нельзя выбрать корневую папку!');
    Exit;
  end;
  var files := TDirectory.GetFiles(Dir, '*.*', TSearchOption.soTopDirectoryOnly); *)
  for var fn := 0 to High(files) do begin
    if not CreateTXlsMemFileEhFromExists(Files[fn], True, '$2', XlsFile, st) then
      Exit;
    sh := XlsFile.Workbook.Worksheets[0];
    org := sh.Cells[4 - 1, 1].Value.AsString;
    for i := 4 to 2000 do begin
      if (sh.Cells[2 - 1, i].Value.AsString = '') then
        Break;
      //фио, таб.номер, ндфл, карта, удержания, организация(из заголовка)
      //!!удержаний пока нет!
      ArXls := ArXls + [[sh.Cells[4 - 1, i].Value.AsString, sh.Cells[5 - 1, i].Value.AsString, sh.Cells[8 - 1, i].Value.AsFloat, sh.Cells[6 - 1, i].Value.AsFloat, 0, org]];
    end;
    sh.Free;
    XlsFile.Free;
  end;
  //получим список совместителей
  EmplCn := Q.QLoadCol('select id from w_employees where is_concurrent = 1', []);
  //пройдем по списку работников в ведомости
  b1 := False;
  b2 := False;
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    //проверим, не совместитель ли
    b := A.InArray(Frg1.GetValueF('id_employee', i, False), EmplCn);
    //пройдем по загруженным из файла даннм
    j := 0;
    while j <= High(ArXls) do begin
      //проверим по свопадению имени и табельного номера, или же только по имени, если совместитель, организацию не учитываем
      if (Frg1.GetValueS('employee', i, False) = ArXls[j][0]) {and (b or (Frg1.GetValueS('personnel_number', i, False) = ArXls[j][1]))} then begin
        e1 := ArXls[j][2].AsFloat;
        e2 := ArXls[j][3].AsFloat;
        e3 := ArXls[j][4].AsFloat;
        //и если совместитель то просуммируем все строки с таким фио
        if b then
          for k := j + 1 to High(ArXls) do
            if Frg1.GetValueS('employee', i, False) = ArXls[k][0] then begin
              e1 := e1+ ArXls[k][2].AsFloat;
              e2 := e2 + ArXls[k][3].AsFloat;
              e3 := e3 + ArXls[k][4].AsFloat;
            end;
        e1 := Round(e1); e2 := Round(e2); e3 := Round(e3);
        //проверим что полученные данные численно отличаются от того что уже в ведомости
{        if Frg1.GetValueF('deduct_ndfl', i, False) <> Round(e1) then begin
          //если отличаются - заполним ведомсть, статус из менения, и выдадим сообщение
          st := st + Frg1.GetValueS('employee', i, False) + ': Изменен столбец НДФЛ с ' + Frg1.GetValueS('deduct_ndfl', i, False) + ' на ' + VarToStr(S.NullIf0(Round(e1))) + #13#10;
          Frg1.SetValue('deduct_ndfl', i, False, S.NullIf0(e1));
          Frg1.SetState(True, null, null);
          b1 := True;
        end;}
        if Frg1.GetValueF('pay_card', i, False) <> Round(e2) then begin
          //если отличаются - заполним ведомсть, статус из менения, и выдадим сообщение
          st := st + Frg1.GetValueS('employee', i, False) + ': Изменен столбец Карта с ' + Frg1.GetValueS('pay_card', i, False) + ' на ' + VarToStr(S.NullIf0(Round(e2))) + #13#10;
          Frg1.SetValue('pay_card', i, False, S.NullIf0(e2));
          Frg1.SetState(True, null, null);
          b1 := True;
        end;
        {if Frg1.GetValueF('deduct_enf', i, False) <> Round(e3) then begin
          //если отличаются - заполним ведомсть, статус из менения, и выдадим сообщение
          st := st + Frg1.GetValueS('employee', i, False) + ': Изменен столбец Удержано с ' + Frg1.GetValueS('deduct_enf', i, False) + ' на ' + VarToStr(S.NullIf0(Round(e3))) + #13#10;
          Frg1.SetValue('deduct_enf', i, False, S.NullIf0(e3));
          FIsChanged := True;
          b1 := True;
        end;}
        Break;
      end;
      inc(j);
    end;
    //проверим, что работник в списке выгрузки не найден
    if j > High(ArXls) then begin
      st := st + Frg1.GetValueS('employee', i, False) + ': Не найден в файлах выгрузки!' + #13#10;
      b2 := True;
    end;
  end;
  //пересчитаем таблицу
  CalculateAll;
  //выведем сообщение
  if b1 or b2 then
    MyInfoMessage('Данные загружены' + S.IIf(b2, ', однако не по всем работникам!', '.') + #13#10#13#10 + S.IIFStr(not b1 and not b2, 'Изменений не было.', st), 1)
  else
    MyInfoMessage('Данные загружены.');
end;
{$ENDIF}

type
  //одна строка из файла выгрузки ЗУП (карты)
  TNdflXlsRow = record
    FileName: string;   //имя файла (без расширения) - обычно название организации
    OrgKey: string;     //нормализованное имя файла, для сравнения с организацией в ведомости
    Doc: string;        //номер ведомости в банк (столбец "Ссылка")
    Fio: string;
    FioKey: string;     //нормализованное ФИО
    Tab: string;
    TabKey: string;     //нормализованный табельный номер
    XlsRow: Integer;    //номер строки в файле
    Card: Extended;     //к выплате (на карту)
    Ndfl: Extended;
    IsConc: Boolean;    //работник - совместитель (по справочнику работников)
    Used: Boolean;      //строка уже отнесена к какой-либо строке ведомости
  end;

function NdflNormStr(const AStr: string): string;
//нормализация для сравнения ФИО/названий: без пробелов по краям и двойных, в верхнем регистре, Ё=Е
begin
  Result := StringReplace(AStr, #160, ' ', [rfReplaceAll]);
  Result := AnsiUpperCase(Trim(Result));
  Result := StringReplace(Result, 'Ё', 'Е', [rfReplaceAll]);
  while Pos('  ', Result) > 0 do
    Result := StringReplace(Result, '  ', ' ', [rfReplaceAll]);
end;

function NdflNormTab(const ATab: string): string;
//нормализация табельного номера: чисто цифровые - без ведущих нулей ("00001" = "1"), остальные - как строка в верхнем регистре
var
  i: Integer;
  IsDigits: Boolean;
begin
  Result := NdflNormStr(ATab);
  IsDigits := Result <> '';
  for i := 1 to Length(Result) do
    if not CharInSet(Result[i], ['0'..'9']) then
      IsDigits := False;
  if IsDigits then begin
    while (Length(Result) > 1) and (Result[1] = '0') do
      Delete(Result, 1, 1);
  end;
end;

procedure TFrmWGedtPayrollTransfer.GetNdflFromExcelZup;
//загрузка карт (столбец "Карта", pay_card) из файлов выгрузки ЗУП - по одному файлу на организацию.
//файлы выгружаются из ЗУП в формате, нечитаемом в этой программе.
//необходимо перед загрузкой открыть в экселе и пересохранить
//например, в пустой части верха документа ввести что-то в ячейку и сохранить. этого достаточно!!!
//
//сопоставление строк файлов со строками ведомости. у обычного работника строка ведомости = работник + организация +
//табельный номер (человек может быть и дважды в одной организации). совместитель (w_employees.is_concurrent = 1)
//представлен в ведомости ОДНОЙ строкой (организация и табельный номер в ней могут быть любыми), а в файлах может быть
//в нескольких организациях - для него суммируются ВСЕ строки всех файлов с его ФИО (проход 0). для остальных
//сопоставление выполняется в три прохода, строка файла может быть отнесена только к одной строке ведомости:
// 1) ФИО + табельный номер (нормализованные: регистр, Ё/Е, пробелы, ведущие нули у цифровых номеров);
// 2) ФИО + организация (название файла содержится в названии организации ведомости);
// 3) только ФИО - если в ведомости у этого работника ровно одна строка, ей достаются все оставшиеся строки файлов с этим ФИО.
//строки файлов, не попавшие в ведомость, и строки ведомости, для которых ничего не найдено, выводятся в подробный
//лог (в нём отдельно перечислены совместители, и их строки помечены "(совместитель)"; он сохраняется в текстовый файл во временной папке и открывается, а краткие итоги показываются в сообщении).
//значения у не найденных строк ведомости не изменяются.
//до переработки (08.10.2026) см. старую версию выше (NDFL_LOAD_OLD)
var
  i, j, k, n, cnt: Integer;
  st, CopyName, FileTitle, LogFileName: string;
  XlsFile: TXlsMemFileEh;
  sh: TXlsWorksheetEh;
  Xls: array of TNdflXlsRow;
  files: TArray<string>;
  FileRows: array of Integer;     //число строк, прочитанных из каждого файла
  FileCard: array of Extended;    //сумма карт по каждому файлу (точно)
  FileNdfl: array of Extended;
  VCard: array of Extended;       //набранная для строки ведомости сумма (точно)
  VNdfl: array of Extended;
  VCnt: array of Integer;         //число строк файлов, отнесённых к строке ведомости
  VTier: array of Integer;        //0 - не найдена, 1/2/3 - номер прохода, 4 - совместитель (проход 0)
  VConc: array of Boolean;        //работник строки ведомости - совместитель
  EmplCn: TVarDynArray;           //id совместителей
  ConcFio: TVarDynArray;          //нормализованные ФИО совместителей
  VFioKey, VTabKey, VOrgKey: array of string;
  VOld: array of Extended;        //значение pay_card в ведомости до загрузки
  e: Extended;
  b: Boolean;
  Lg, LgNotFound, LgNotInVed, LgChanged: string;
  SumXls, SumNdflXls, SumLoaded, SumRound, SumNotInVed, SumVedAfter, SumVedBefore, SumVedNotFound, SumVedMatchedOld: Extended;
  CntNotFoundNonZero: Integer;
  CntChanged, CntSame, CntNotFound, CntNotInVed, CntT1, CntT2, CntT3, CntT4: Integer;
  TierTxt: array[1..4] of string;
  LgConc, LgConcRows: string;
  CntConc: Integer;

function Fmt(AValue: Extended): string;
//сумма для лога, два знака после запятой
begin
  Result := FormatFloat('0.00', AValue);
end;

function RowTxt(AIdx: Integer): string;
//описание строки ведомости для лога
begin
  Result := Frg1.GetValueS('employee', AIdx, False) + #9 + Frg1.GetValueS('organization', AIdx, False) + #9 +
    'таб.№ ' + Frg1.GetValueS('personnel_number', AIdx, False) + S.IIFStr(VConc[AIdx], #9 + '(совместитель)', '');
end;

function GetSelectedFiles(OpenDialog: TFileOpenDialog): TArray<string>;
var
  i: Integer;
  ShellItemArray: IShellItemArray;
  ShellItem: IShellItem;
  pszPath: PWideChar;
  Count: DWORD;
begin
  SetLength(Result, 0);

  ShellItemArray := OpenDialog.ShellItems;

  if ShellItemArray = nil then
    Exit;

  if Failed(ShellItemArray.GetCount(Count)) then
    Exit;

  SetLength(Result, Count);

  for i := 0 to Count - 1 do
  begin
    if Failed(ShellItemArray.GetItemAt(i, ShellItem)) then
      Continue;

    if Succeeded(ShellItem.GetDisplayName(SIGDN_FILESYSPATH, pszPath)) then
    begin
      Result[i] := pszPath;
      CoTaskMemFree(pszPath);
    end;
  end;
end;

begin
  TierTxt[1] := 'ФИО + таб.№';
  TierTxt[2] := 'ФИО + организация';
  TierTxt[3] := 'только ФИО';
  TierTxt[4] := 'совместитель: сумма всех строк файлов по ФИО';
  //выберем файлы
  MyData.FileOpenDialog1.Options := MyData.FileOpenDialog1.Options + [fdoAllowMultiSelect];
  MyData.FileOpenDialog1.FileTypes.Clear;
  with MyData.FileOpenDialog1.FileTypes.Add do begin DisplayName := 'файлы Excel (*.xlsx)'; FileMask := '*.xlsx'; end;
  if not MyData.FileOpenDialog1.Execute then
    Exit;
  files := GetSelectedFiles(MyData.FileOpenDialog1);
  if Length(files) = 0 then
    Exit;

  //список совместителей (id и ФИО)
  EmplCn := Q.QLoadCol('select id from w_employees where is_concurrent = 1', []);
  ConcFio := Q.QLoadCol('select f || '' '' || i || nvl2(o, '' '' || o, '''') from w_employees where is_concurrent = 1', []);
  for i := 0 to High(ConcFio) do
    ConcFio[i] := NdflNormStr(VarToStr(ConcFio[i]));

  //загрузим в массив данные из эксель, со строки 5 до первой пустой (ссылка и ФИО пусты)
  SetLength(Xls, 0);
  SetLength(FileRows, Length(files));
  SetLength(FileCard, Length(files));
  SetLength(FileNdfl, Length(files));
  Lg := 'Загрузка карт из файлов выгрузки ЗУП, ' + DateTimeToStr(Now) + #13#10 + 'Ведомость: ' + Caption + #13#10#13#10;
  for k := 0 to High(files) do begin
    if not CreateTXlsMemFileEhFromExists(files[k], True, '$2', XlsFile, CopyName) then begin
      MyWarningMessage('Не удалось прочитать файл:' + #13#10 + files[k] + #13#10#13#10 + 'Загрузка прервана, ничего не изменено.');
      Exit;
    end;
    FileTitle := ChangeFileExt(ExtractFileName(files[k]), '');
    FileRows[k] := 0;
    FileCard[k] := 0;
    FileNdfl[k] := 0;
    sh := XlsFile.Workbook.Worksheets[0];
    for i := 4 to 2000 do begin
      if (sh.Cells[2 - 1, i].Value.AsString = '') and (sh.Cells[4 - 1, i].Value.AsString = '') then
        Break;
      if sh.Cells[4 - 1, i].Value.AsString = '' then
        Continue;
      n := Length(Xls);
      SetLength(Xls, n + 1);
      Xls[n].FileName := FileTitle;
      Xls[n].OrgKey := NdflNormStr(FileTitle);
      Xls[n].Doc := sh.Cells[2 - 1, i].Value.AsString;
      Xls[n].Fio := sh.Cells[4 - 1, i].Value.AsString;
      Xls[n].FioKey := NdflNormStr(Xls[n].Fio);
      Xls[n].Tab := sh.Cells[5 - 1, i].Value.AsString;
      Xls[n].TabKey := NdflNormTab(Xls[n].Tab);
      Xls[n].XlsRow := i + 1;
      Xls[n].Card := sh.Cells[6 - 1, i].Value.AsFloat;
      Xls[n].Ndfl := sh.Cells[8 - 1, i].Value.AsFloat;
      Xls[n].IsConc := A.InArray(Xls[n].FioKey, ConcFio);
      Xls[n].Used := False;
      Inc(FileRows[k]);
      FileCard[k] := FileCard[k] + Xls[n].Card;
      FileNdfl[k] := FileNdfl[k] + Xls[n].Ndfl;
    end;
    sh.Free;
    XlsFile.Free;
    Lg := Lg + 'Файл ' + files[k] + ': строк ' + IntToStr(FileRows[k]) + ', сумма "К выплате" (карта) ' + Fmt(FileCard[k]) +
      ', НДФЛ ' + Fmt(FileNdfl[k]) + #13#10;
  end;

  //данные строк ведомости
  n := Frg1.GetCount(False);
  SetLength(VCard, n);
  SetLength(VNdfl, n);
  SetLength(VCnt, n);
  SetLength(VTier, n);
  SetLength(VConc, n);
  SetLength(VFioKey, n);
  SetLength(VTabKey, n);
  SetLength(VOrgKey, n);
  SetLength(VOld, n);
  SumVedBefore := 0;
  for i := 0 to n - 1 do begin
    VCard[i] := 0;
    VNdfl[i] := 0;
    VCnt[i] := 0;
    VTier[i] := 0;
    VConc[i] := A.InArray(Frg1.GetValueF('id_employee', i, False), EmplCn);
    VFioKey[i] := NdflNormStr(Frg1.GetValueS('employee', i, False));
    VTabKey[i] := NdflNormTab(Frg1.GetValueS('personnel_number', i, False));
    VOrgKey[i] := NdflNormStr(Frg1.GetValueS('organization', i, False));
    VOld[i] := Frg1.GetValueF('pay_card', i, False);
    SumVedBefore := SumVedBefore + VOld[i];
  end;

  //проход 0: совместители - одна строка ведомости на человека, берутся все строки всех файлов с этим ФИО
  //(организация и табельный номер не важны). если строк ведомости у совместителя несколько - данные получает первая
  for i := 0 to n - 1 do begin
    if (not VConc[i]) or (VFioKey[i] = '') then
      Continue;
    b := False;
    for k := 0 to i - 1 do
      if VConc[k] and (VFioKey[k] = VFioKey[i]) then
        b := True;
    if b then
      Continue;
    for j := 0 to High(Xls) do
      if (not Xls[j].Used) and (Xls[j].FioKey = VFioKey[i]) then begin
        Xls[j].Used := True;
        VCard[i] := VCard[i] + Xls[j].Card;
        VNdfl[i] := VNdfl[i] + Xls[j].Ndfl;
        Inc(VCnt[i]);
        VTier[i] := 4;
      end;
  end;
  //проход 1: ФИО + табельный номер
  for i := 0 to n - 1 do begin
    if VConc[i] or (VFioKey[i] = '') or (VTabKey[i] = '') then
      Continue;
    for j := 0 to High(Xls) do
      if (not Xls[j].Used) and (Xls[j].FioKey = VFioKey[i]) and (Xls[j].TabKey = VTabKey[i]) then begin
        Xls[j].Used := True;
        VCard[i] := VCard[i] + Xls[j].Card;
        VNdfl[i] := VNdfl[i] + Xls[j].Ndfl;
        Inc(VCnt[i]);
        VTier[i] := 1;
      end;
  end;
  //проход 2: ФИО + организация (название файла входит в название организации)
  for i := 0 to n - 1 do begin
    if VConc[i] or (VTier[i] <> 0) or (VFioKey[i] = '') or (VOrgKey[i] = '') then
      Continue;
    for j := 0 to High(Xls) do
      if (not Xls[j].Used) and (Xls[j].FioKey = VFioKey[i]) and (Xls[j].OrgKey <> '') and (Pos(Xls[j].OrgKey, VOrgKey[i]) > 0) then begin
        Xls[j].Used := True;
        VCard[i] := VCard[i] + Xls[j].Card;
        VNdfl[i] := VNdfl[i] + Xls[j].Ndfl;
        Inc(VCnt[i]);
        VTier[i] := 2;
      end;
  end;
  //проход 3: только ФИО, если в ведомости у работника ровно одна строка - ей достаётся всё оставшееся
  for i := 0 to n - 1 do begin
    if VConc[i] or (VTier[i] <> 0) or (VFioKey[i] = '') then
      Continue;
    cnt := 0;
    for k := 0 to n - 1 do
      if VFioKey[k] = VFioKey[i] then
        Inc(cnt);
    if cnt <> 1 then
      Continue;
    for j := 0 to High(Xls) do
      if (not Xls[j].Used) and (Xls[j].FioKey = VFioKey[i]) then begin
        Xls[j].Used := True;
        VCard[i] := VCard[i] + Xls[j].Card;
        VNdfl[i] := VNdfl[i] + Xls[j].Ndfl;
        Inc(VCnt[i]);
        VTier[i] := 3;
      end;
  end;

  //применим к ведомости, и сформируем лог
  CntChanged := 0; CntSame := 0; CntNotFound := 0; CntNotInVed := 0; CntT1 := 0; CntT2 := 0; CntT3 := 0; CntT4 := 0; CntConc := 0;
  SumLoaded := 0; SumRound := 0; SumNotInVed := 0; SumVedAfter := 0; SumVedNotFound := 0; SumVedMatchedOld := 0; CntNotFoundNonZero := 0;
  LgNotFound := ''; LgNotInVed := ''; LgChanged := ''; LgConc := '';
  b := False;
  for i := 0 to n - 1 do begin
    if VConc[i] then
      Inc(CntConc);
    if VTier[i] = 0 then begin
      Inc(CntNotFound);
      SumVedNotFound := SumVedNotFound + VOld[i];
      if VOld[i] <> 0 then
        Inc(CntNotFoundNonZero);
      LgNotFound := LgNotFound + RowTxt(i) + #9 + 'К выплате ' + Fmt(Frg1.GetValueF('total_pay', i, False)) +
        #9 + 'Карта ' + Fmt(VOld[i]) + #9 + 'Наличные ' + Fmt(Frg1.GetValueF('pay_cash', i, False)) +
        #9 + 'НДФЛ ' + Fmt(Frg1.GetValueF('deduct_ndfl', i, False)) + #9 + 'Удержано ' + Fmt(Frg1.GetValueF('deduct_enf', i, False));
      //подсказка: есть ли в файлах строки с таким ФИО, не попавшие ни к кому (скорее всего, расхождение табельного номера/организации)
      for j := 0 to High(Xls) do
        if (not Xls[j].Used) and (Xls[j].FioKey = VFioKey[i]) then
          LgNotFound := LgNotFound + #13#10 + #9 + '  возможно, это: ' + Xls[j].FileName + ', таб.№ ' + Xls[j].Tab + ', карта ' + Fmt(Xls[j].Card);
      //если карта в ведомости уже не нулевая - ищем среди неиспользованных строк файлов близкую по сумме (разница не более рубля)
      if VOld[i] <> 0 then begin
        LgNotFound := LgNotFound + #13#10 + #9 + '  !!! карта в ведомости не нулевая (' + Fmt(VOld[i]) + '), но в файлах эта строка не найдена - эта сумма входит в итог ведомости, но не в итог по файлам';
        for j := 0 to High(Xls) do
          if (not Xls[j].Used) and (Abs(Xls[j].Card - VOld[i]) <= 1) then
            LgNotFound := LgNotFound + #13#10 + #9 + '  по сумме похоже на строку файла: ' + Xls[j].Fio + ', ' + Xls[j].FileName + ', таб.№ ' + Xls[j].Tab + ', карта ' + Fmt(Xls[j].Card);
      end;
      if VConc[i] then begin
        b := False;
        for k := 0 to i - 1 do
          if VConc[k] and (VFioKey[k] = VFioKey[i]) then
            b := True;
        if b then
          LgNotFound := LgNotFound + #13#10 + #9 + '  у совместителя в ведомости должна быть одна строка - это повторная, данные из файлов получила первая строка этого работника'
        else
          LgNotFound := LgNotFound + #13#10 + #9 + '  совместитель: в файлах загрузки строк с таким ФИО нет';
      end;
      LgNotFound := LgNotFound + #13#10;
      SumVedAfter := SumVedAfter + VOld[i];
      Continue;
    end;
    case VTier[i] of
      1: Inc(CntT1);
      2: Inc(CntT2);
      3: Inc(CntT3);
      4: Inc(CntT4);
    end;
    e := Round(VCard[i]);
    SumLoaded := SumLoaded + VCard[i];
    SumVedMatchedOld := SumVedMatchedOld + VOld[i];
    SumRound := SumRound + e;
    SumVedAfter := SumVedAfter + e;
    if VOld[i] <> e then begin
      Inc(CntChanged);
      LgChanged := LgChanged + RowTxt(i) + #9 + 'Карта: было ' + Fmt(VOld[i]) + ', стало ' + Fmt(e) + ' (в файлах ' + Fmt(VCard[i]) +
        ', строк файлов ' + IntToStr(VCnt[i]) + ', сопоставление: ' + TierTxt[VTier[i]] + ')' + #13#10;
      Frg1.SetValue('pay_card', i, False, S.NullIf0(e));
      Frg1.SetState(True, null, null);
      b := True;
    end
    else
      Inc(CntSame);
  end;
  for j := 0 to High(Xls) do
    if not Xls[j].Used then begin
      Inc(CntNotInVed);
      SumNotInVed := SumNotInVed + Xls[j].Card;
      LgNotInVed := LgNotInVed + Xls[j].Fio + S.IIFStr(Xls[j].IsConc, ' (совместитель)', '') + #9 + Xls[j].FileName + #9 + 'таб.№ ' + Xls[j].Tab + #9 + 'карта ' + Fmt(Xls[j].Card) +
        #9 + 'НДФЛ ' + Fmt(Xls[j].Ndfl) + #9 + '(' + Xls[j].Doc + ', строка файла ' + IntToStr(Xls[j].XlsRow) + ')' + #13#10;
      //по сумме ищем среди не найденных строк ведомости с ненулевой картой (скорее всего, это она же, но с другим ФИО/таб.№/организацией)
      for i := 0 to n - 1 do
        if (VTier[i] = 0) and (VOld[i] <> 0) and (Abs(Xls[j].Card - VOld[i]) <= 1) then
          LgNotInVed := LgNotInVed + #9 + '  по сумме похоже на строку ведомости: ' + RowTxt(i) + ', карта ' + Fmt(VOld[i]) + #13#10;
    end;
  //список совместителей ведомости: что набрано по файлам
  for i := 0 to n - 1 do
    if VConc[i] then begin
      LgConc := LgConc + RowTxt(i) + #9 + 'в ведомости было ' + Fmt(VOld[i]) + ', по файлам ' + Fmt(VCard[i]) + ' (строк файлов ' + IntToStr(VCnt[i]) + ')' + #13#10;
      if VTier[i] = 4 then begin
        for j := 0 to High(Xls) do
          if Xls[j].Used and (Xls[j].FioKey = VFioKey[i]) then
            LgConc := LgConc + #9 + '  ' + Xls[j].FileName + ', таб.№ ' + Xls[j].Tab + ', карта ' + Fmt(Xls[j].Card) + ' (' + Xls[j].Doc + ', строка файла ' + IntToStr(Xls[j].XlsRow) + ')' + #13#10;
      end
      else
        LgConc := LgConc + #9 + '  в файлах загрузки не найден (или повторная строка ведомости)' + #13#10;
    end;
  SumXls := 0;
  SumNdflXls := 0;
  for k := 0 to High(files) do begin
    SumXls := SumXls + FileCard[k];
    SumNdflXls := SumNdflXls + FileNdfl[k];
  end;

  //пересчитаем таблицу
  CalculateAll;

  //итоговый лог
  Lg := Lg + #13#10 + '=== СВЕРКА СУММ (столбец "Карта") ===' + #13#10 +
    'Всего в файлах: ' + IntToStr(Length(Xls)) + ' строк, ' + Fmt(SumXls) + #13#10 +
    'отнесено к строкам ведомости: ' + Fmt(SumLoaded) + ' (после округления каждой строки до рубля: ' + Fmt(SumRound) + ', разница округления ' + Fmt(SumRound - SumLoaded) + ')' + #13#10 +
    'не найдено в ведомости: ' + IntToStr(CntNotInVed) + ' строк, ' + Fmt(SumNotInVed) + #13#10 +
    'проверка: отнесено + не найдено = ' + Fmt(SumLoaded + SumNotInVed) + ' (должно совпасть с суммой по файлам ' + Fmt(SumXls) + ')' + #13#10 +
    'Из суммы карт в ведомости: у сопоставленных строк (до загрузки) ' + Fmt(SumVedMatchedOld) + ', у строк, не найденных в файлах, ' + Fmt(SumVedNotFound) + ' (строк с ненулевой картой: ' + IntToStr(CntNotFoundNonZero) + ')' + #13#10 +
    'Сумма карт в ведомости: до загрузки ' + Fmt(SumVedBefore) + ', после загрузки ' + Fmt(SumVedAfter) + #13#10 +
    'Разница "ведомость после загрузки" - "файлы" = ' + Fmt(SumVedAfter - SumXls) + ' (складывается из округления, значений в ведомости у строк, не найденных в файлах, и сумм из файлов, не попавших в ведомость)' + #13#10 +
    'Строк ведомости: ' + IntToStr(n) + ', сопоставлено ' + IntToStr(n - CntNotFound) + ' (по ФИО+таб.№ ' + IntToStr(CntT1) + ', по ФИО+организации ' + IntToStr(CntT2) + ', по одному ФИО ' + IntToStr(CntT3) + ', совместители ' + IntToStr(CntT4) + '), изменено ' + IntToStr(CntChanged) + ', без изменений ' + IntToStr(CntSame) + #13#10;
  Lg := Lg + #13#10 + '=== СОВМЕСТИТЕЛИ В ВЕДОМОСТИ: ' + IntToStr(CntConc) + ' (одна строка на человека, суммируются все строки всех файлов с его ФИО) ===' + #13#10 + LgConc;
  Lg := Lg + #13#10 + '=== НЕ НАЙДЕНЫ В ФАЙЛАХ ЗАГРУЗКИ (есть в ведомости): ' + IntToStr(CntNotFound) + ' ===' + #13#10 +
    '(значения в ведомости оставлены как были)' + #13#10 + LgNotFound;
  Lg := Lg + #13#10 + '=== НАЙДЕНЫ В ФАЙЛАХ, НО НЕ НАЙДЕНЫ В ВЕДОМОСТИ: ' + IntToStr(CntNotInVed) + ', на сумму карт ' + Fmt(SumNotInVed) + ' ===' + #13#10 + LgNotInVed;
  Lg := Lg + #13#10 + '=== ИЗМЕНЕНИЯ В ВЕДОМОСТИ: ' + IntToStr(CntChanged) + ' ===' + #13#10 + LgChanged;

  //сохраним лог в файл и откроем
  LogFileName := Sys.GetWinTemp + '\' + 'Загрузка карт ' + FormatDateTime('yyyy-mm-dd_hh-nn-ss', Now) + '.txt';
  if Sys.SaveTextToFile(LogFileName, Lg) then
    Sys.ExecFile(LogFileName);

  //краткое сообщение
  st := 'Загрузка карт завершена.' + #13#10#13#10 +
    'В файлах: ' + IntToStr(Length(Xls)) + ' строк, ' + Fmt(SumXls) + #13#10 +
    'Изменено строк ведомости: ' + IntToStr(CntChanged) + ' (без изменений ' + IntToStr(CntSame) + ')' + #13#10 +
    'Карты в ведомости: было ' + Fmt(SumVedBefore) + ', стало ' + Fmt(SumVedAfter) + #13#10#13#10 +
    'НЕ НАЙДЕНЫ В ФАЙЛАХ (есть в ведомости): ' + IntToStr(CntNotFound) + #13#10 +
    'НАЙДЕНЫ В ФАЙЛАХ, НО НЕТ В ВЕДОМОСТИ: ' + IntToStr(CntNotInVed) + ', на сумму ' + Fmt(SumNotInVed) + #13#10#13#10 +
    'Подробный лог сохранён в файл:' + #13#10 + LogFileName;
  MyInfoMessage(st, 1);
end;

procedure TFrmWGedtPayrollTransfer.GetAdvanceFromExcelZup;
//файлы выгружаются из ЗУП в формате, нечитаемом в этой программе.
//необходимо перед загрузкой открыть в экселе и пересохранить
//например, в пустой части верха документа ввести что-то в ячейку и сохранить. этого достаточно!!!
var
  i, j, k: Integer;
  st, st1: string;
  v, v1, v2: Variant;
  b, b1, b2: Boolean;
  XlsFile: TXlsMemFileEh;
  sh, sh1: TXlsWorksheetEh;
  ArXls: TVarDynArray2;
  EmplCn: TVarDynArray;
  e1, e2, e3: Extended;
  org, dir: string;

function GetSelectedFiles(OpenDialog: TFileOpenDialog): TArray<string>;
var
  i: Integer;
  ShellItemArray: IShellItemArray;
  ShellItem: IShellItem;
  pszPath: PWideChar;
  Count: DWORD;
begin
  SetLength(Result, 0);

  ShellItemArray := OpenDialog.ShellItems;

  if ShellItemArray = nil then
    Exit;

  if Failed(ShellItemArray.GetCount(Count)) then
    Exit;

  SetLength(Result, Count);

  for i := 0 to Count - 1 do
  begin
    if Failed(ShellItemArray.GetItemAt(i, ShellItem)) then
      Continue;

    if Succeeded(ShellItem.GetDisplayName(SIGDN_FILESYSPATH, pszPath)) then
    begin
      Result[i] := pszPath;
      CoTaskMemFree(pszPath);
    end;
  end;
end;

begin

  //выберем файл
  MyData.FileOpenDialog1.Options := MyData.FileOpenDialog1.Options + [fdoAllowMultiSelect];
  MyData.FileOpenDialog1.FileTypes.Clear;
  with MyData.FileOpenDialog1.FileTypes.Add do begin DisplayName := 'файлы Excel (*.xlsx)'; FileMask := '*.xlsx'; end;
  if not MyData.FileOpenDialog1.Execute then
    Exit;
  //загрузим в массив данные из эксель со второй строки до первой пустой
  ArXls := [];
  var files := GetSelectedFiles(MyData.FileOpenDialog1);
  for var fn := 0 to High(files) do begin
    if not CreateTXlsMemFileEhFromExists(Files[fn], True, '$2', XlsFile, st) then
      Exit;
    sh := XlsFile.Workbook.Worksheets[0];
    org := sh.Cells[4 - 1, 1].Value.AsString;
    for i := 4 to 2000 do begin
      if (sh.Cells[4 - 1, i].Value.AsString = '') then
        Break;
      //фио, таб.номер, ндфл, карта, удержания, организация(из заголовка)
      //!!удержаний пока нет!
      ArXls := ArXls + [[sh.Cells[4 - 1, i].Value.AsString, sh.Cells[6 - 1, i].Value.AsString, 0, org]];
    end;
    sh.Free;
    XlsFile.Free;
  end;
  //получим список совместителей
  EmplCn := Q.QLoadCol('select id from w_employees where is_concurrent = 1', []);
  //пройдем по списку работников в ведомости
  b1 := False;
  b2 := False;
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    //проверим, не совместитель ли
    b := A.InArray(Frg1.GetValueF('id_employee', i, False), EmplCn);
    //пройдем по загруженным из файла даннм
    j := 0;
    while j <= High(ArXls) do begin
      //проверим по свопадению имени и табельного номера, или же только по имени, если совместитель, организацию не учитываем
      if (Frg1.GetValueS('employee', i, False) = ArXls[j][0]) {and (b or (Frg1.GetValueS('personnel_number', i, False) = ArXls[j][1]))} then begin
        e1 := ArXls[j][1].AsFloat;
        //и если совместитель то просуммируем все строки с таким фио
        if Frg1.GetValueS('employee', i, False) = 'Анисимов Сергей Витальевич' then
          var bbb := true;
        if b then
          for k := j + 1 to High(ArXls) do
            if Frg1.GetValueS('employee', i, False) = ArXls[k][0] then begin
              e1 := e1+ ArXls[k][1].AsFloat;
            end;
        e1 := Round(e1);
        //проверим что полученные данные численно отличаются от того что уже в ведомости
        if Frg1.GetValueF('advance_official', i, False) <> Round(e1) then begin
          //если отличаются - заполним ведомсть, статус из менения, и выдадим сообщение
          st := st + Frg1.GetValueS('employee', i, False) + ': Изменен столбец Аванс с ' + Frg1.GetValueS('advance_official', i, False) + ' на ' + VarToStr(S.NullIf0(Round(e1))) + #13#10;
          Frg1.SetValue('advance_official', i, False, S.NullIf0(e1));
          Frg1.SetState(True, null, null);
          b1 := True;
        end;
        Break;
      end;
      inc(j);
    end;
    //проверим, что работник в списке выгрузки не найден
    if j > High(ArXls) then begin
      st := st + Frg1.GetValueS('employee', i, False) + ': Не найден в файлах выгрузки!' + #13#10;
      b2 := True;
    end;
  end;
  //пересчитаем таблицу
  CalculateAll;
  //выведем сообщение
  if b1 or b2 then
    MyInfoMessage('Данные загружены' + S.IIf(b2, ', однако не по всем работникам!', '.') + #13#10#13#10 + S.IIFStr(not b1 and not b2, 'Изменений не было.', st), 1)
  else
    MyInfoMessage('Данные загружены.');
end;


procedure TFrmWGedtPayrollTransfer.GetAdvPayFromExcel(AdvNo: Integer);
var
  i, j, k: Integer;
  st, st1: string;
  v, v1, v2: Variant;
  b, b1, b2: Boolean;
  XlsFile: TXlsMemFileEh;
  sh, sh1: TXlsWorksheetEh;
  ArXls: TVarDynArray2;
  EmplCn: TVarDynArray;
  e1, e2, e3: Extended;
  Fld: string;
begin
  //выберем файл
  MyData.FileOpenDialog1.Options := MyData.FileOpenDialog1.Options;// + [fdoAllowMultiSelect];
  MyData.FileOpenDialog1.FileTypes.Clear;
  with MyData.FileOpenDialog1.FileTypes.Add do begin DisplayName := 'файлы Excel (*.xlsx)'; FileMask := '*.xlsx'; end;
  if not MyData.FileOpenDialog1.Execute then
    Exit;
//      for i := 0 to MyData.FileOpenDialog1.Files.Count - 1 do
  //получим список совместителей
  EmplCn := Q.QLoadCol('select id from w_employees where is_concurrent = 1', []);
  //загрузим в массив данные из эксель со второй строки до первой пустой
  ArXls := [];

  for var fn := 0 to MyData.FileOpenDialog1.Files.Count - 1 do begin
    if not CreateTXlsMemFileEhFromExists(MyData.FileOpenDialog1.Files[fn], True, '$2', XlsFile, st) then
      Exit;
    sh := XlsFile.Workbook.Worksheets[0];
    for i := 1 to 2000 do begin
      if (sh.Cells[1 - 1, i].Value.AsString = '') or (S.ToLower(sh.Cells[1 - 1, i].Value.AsString) = 'итого:') then
        Break;
   //   if (sh.Cells[4 - 1, i].Value.AsString = '') then
   //     Continue;
   {   if (High(ArXls) > 0) and (sh.Cells[2 - 1, i].Value.AsString = ArXls[High(ArXls) - 1][0]) and ((sh.Cells[3 - 1, i].Value.AsString = '') or (ArXls[High(ArXls) - 1][1] = '')) then begin
        if sh.Cells[3 - 1, i].Value.AsString <> '' then
          ArXls[High(ArXls) - 1][1] := sh.Cells[3 - 1, i].Value.AsString;
        if sh.Cells[5- 1, i].Value.AsString <> '' then
          ArXls[High(ArXls) - 1][2] := sh.Cells[5- 1, i].Value.AsString;
        if sh.Cells[6- 1, i].Value.AsString <> '' then
          ArXls[High(ArXls) - 1][3] := sh.Cells[6- 1, i].Value.AsString;
      end
      else  }
        //фио, табельный номер, выплата
        ArXls := ArXls + [[sh.Cells[1 - 1, i].Value.AsString, sh.Cells[3 - 1, i].Value.AsString, sh.Cells[5 - 1, i].Value.AsFloat]];
    end;
    sh.Free;
    XlsFile.Free;
  end;
//Exit;
  //пройдем по списку работников в ведомости
  b1 := False;
  b2 := False;
  Fld := 'pay_adv' + S.IIFStr(AdvNo > 1, IntToStr(AdvNo));
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    //проверим, не совместитель ли
    b := A.InArray(Frg1.GetValueF('id_employee', i, False), EmplCn);
    //пройдем по загруженным из файла даннм
    j := 0;
    while j <= High(ArXls) do begin
      //проверим по свопадению имени и табельного номера, или же только по имени, если совместитель, организацию не учитываем
      if (Frg1.GetValueS('employee', i, False) = ArXls[j][0]) and (b or (Frg1.GetValueS('personnel_number', i, False) = ArXls[j][1])) then begin
        e1 := ArXls[j][2].AsFloat;
        //и если совместитель то просуммируем все строки с таким фио
        if b then
          for k := j + 1 to High(ArXls) do
            if Frg1.GetValueS('employee', i, False) = ArXls[k][0] then begin
              e1 := e1+ ArXls[k][2].AsFloat;
            end;
        e1 := Round(e1); e2 := Round(e2); e3 := Round(e3);
        //проверим что полученные данные численно отличаются от того что уже в ведомости
        if Frg1.GetValueF(Fld, i, False) <> Round(e1) then begin
          //если отличаются - заполним ведомсть, статус из менения, и выдадим сообщение
          st := st + Frg1.GetValueS('employee', i, False) + ': Изменен столбец НДФЛ с ' + Frg1.GetValueS(Fld, i, False) + ' на ' + VarToStr(S.NullIf0(Round(e1))) + #13#10;
          Frg1.SetValue(Fld, i, False, S.NullIf0(e1));
          Frg1.SetState(True, null, null);
          b1 := True;
        end;
        Break;
      end;
      inc(j);
    end;
    //проверим, что работник в списке выгрузки не найден
    if j > High(ArXls) then begin
      st := st + Frg1.GetValueS('employee', i, False) + ': Не найден в файлах выгрузки!' + #13#10;
      b2 := True;
    end;
  end;
  //пересчитаем таблицу
  CalculateAll;
  //выведем сообщение
  if b1 or b2 then
    MyInfoMessage('Данные загружены' + S.IIf(b2, ', однако не по всем работникам!', '.') + #13#10#13#10 + S.IIFStr(not b1 and not b2, 'Изменений не было.', st), 1)
  else
    MyInfoMessage('Данные загружены.');

end;




end.
