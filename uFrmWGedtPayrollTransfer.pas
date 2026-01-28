unit uFrmWGedtPayrollTransfer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls,
  ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls, MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd,
  MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils, Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uFrmBasicGrid2, uFrDBGridEh, uFrmBasicMdi
  ;

type
  TFrmWGedtPayrollTransfer = class(TFrmBasicGrid2)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FPayrollParams: TNamedArr;
    FIsEditable: Boolean;
    FDeletedWorkers: TVarDynArray;
    FColWidth: Integer;
    FIsChanged: Boolean;
    FIsEditableAdd, FIsEditableAll: Boolean;
    function  PrepareForm: Boolean; override;
    function  GetDataFromDb: Integer;
    function  GetCaption(Colored: Boolean = False): string;
    procedure SetButtons;
    procedure SetColumns;
    procedure SavePayroll;
    function  GetDataFromCalc: Integer;
    procedure CommitPayroll;
    procedure GetNdflFromExcel;
    procedure GetNdflFromExcelZup;
    procedure GetDeductionsFromExcel;
    procedure CalculateAll;
    procedure CalculateRow(Row:Integer);
//    procedure PrintGrid;
//    procedure ExportToXlsxA7;
    procedure SetEditableAll;

    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string); override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
  public
  end;

var
  FrmWGedtPayrollTransfer: TFrmWGedtPayrollTransfer;

implementation

{$R *.dfm}

uses
  Winapi.ShlObj,
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
//    'hours_worked$f;overtime$f;'+
    'total_pay$f;ors_pay$f;is_concurrent$f;deduct_enf$f;deduct_ndfl$f;pay_fss$f;pay_adv$f;pay_card$f;correction$f;pay_cash$f';
  cFieldsL =
    'employee$s;organization$s;changed$i;temp$i';

  cmbtDeduction = 1001;
  cmbtCard = 1002;
  cmbt1C = 1003;
  cmbtEditAll = 1004;
  cmbRecalculate = 1005;


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

  Q.QLoadFromQuery('select id, id_employee, id_organization, personnel_number, dt1, dt2,  employee, is_finalized from v_w_payroll_transfer where id = :id$i', [ID], FPayrollParams);
  if FPayrollParams.Count = 0 then begin
    MsgRecordIsDeleted;
    Exit;
  end;

  FDeletedWorkers := [];
  Frg1.Options := FrDBGridOptionDef + [myogPanelFind, myogColumnResize, myogPanelfind] - [myogColumnFilter];

  //определим поля
  //теги (1-редактирования кроме расчета по мотивации, 2-дополнительное редактирование,3-редактировать всегда)
  FColWidth := 65;
  wcol := IntToStr(FColWidth) + ';r';
  fcol := 'f=###,###,###:';
  Frg1.Opt.SetFields([
    ['id$i', '_id','40'],
    ['id_employee$i', '_id_employee', wcol],
    ['id_organization$i', '_id_org', wcol],
    ['changed$i', '_changed', wcol],
    ['temp$i', '_temp', wcol],

    ['employee$s', 'Работник|ФИО', '200;h'],
    ['organization$s', '!Органиазция', '100'],
    ['personnel_number$s', '!Табельный номер', '60'],
    ['is_concurrent$i', '!Совмес-'#13#10'титель', '60', 'pic' ,'i'],

//    ['hours_worked$f', '!Отработано за период', 90],
//    ['overtime$f', '!Из них переработка', 90],

    ['total_pay$f', '~Итого' + sLineBreak + ' начислено', wcol, fcol],
    ['ors_pay$f', '~ОРС '#13#10'сумма', wcol, fcol, 'i', Mode <> fEdit],
    ['deduct_enf$f', '~Удержано/ '#13#10'Исп. лист', wcol, fcol, 't=1'],
    ['deduct_ndfl$f', '~НДФЛ', wcol, fcol, 't=1'],
    ['pay_fss$f', '~Выплачено'#13#10' ФСС', wcol, fcol, 't=1'],
    ['pay_adv$f', '~Промежуточная'#13#10' выплата', wcol, fcol, 't=1'],
    ['pay_card$f', '~Карта', wcol, fcol, 't=1'],
    ['correction$f', '~Корректировка', wcol, fcol, 't=1'],
    ['pay_cash$f', '~Итого к'#13#10' получению', wcol, fcol]
//    ['$f', '', wcol, fcol],
  ]);
  Frg1.Opt.SetGridOperations('u');
  Frg1.Opt.SetButtons(1, [
    [mbtRefresh, True, 'Обновить данные из расчетных ведомостей'],[],
    [mbtDividorM],
    [cmbt1C, True, True, 'Загрузка данных из 1С', '1c'],
    [cmbtCard, True, True, 'Загрузить НДФЛ и карты', 'card'],
    //[cmbtDeduction, True, True, 'Загрузить удержания', 'r_minus'],
    [mbtDividorM],
    //[mbtDividorM],[mbtPrint],[mbtPrintGrid],[mbtDividorM],
    [],[mbtLock],
    [], [-mbtExcel, True],
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

procedure TFrmWGedtPayrollTransfer.FormClose(Sender: TObject; var Action: TCloseAction);
var
  rn, i, res: Integer;
  changed: Boolean;
begin
  inherited;
  //выйдем, если закрытие происходит при подготовке данных, например, из-за нарушения блокировки
  if FInPrepare then
   Exit;
  if FIsChanged then begin
    res:=myMessageDlg('Ведомость была изменена!'#13#10'Сохранить данные?', mtConfirmation, mbYesNoCancel);
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



function TFrmWGedtPayrollTransfer.GetDataFromDb: Integer;
//прочитаем ведомость (все данные) из БД и заполним ими сетку
var
  na : TNamedArr;
begin
  Q.QLoadFromQuery(Q.QSIUDSql('a', 'v_w_payroll_transfer_item', cFieldsS + ';' + cFieldsL) + ' where id_payroll_transfer = :id$i order by employee, organization, personnel_number',
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

procedure TFrmWGedtPayrollTransfer.SavePayroll;
var
  i, j: Integer;
  f, fn, va: TVarDynArray;
begin
  //запишем метод расчета
  Q.QBeginTrans(True);
  Q.QExecSql('update w_payroll_transfer set is_finalized = :p3$i where id = :id$i', [FPayrollParams.G('is_finalized'), ID]);
  //удалим из БД всех, кого удаляли из списка при нажатии кнопки ТУРВ
  if Length(FDeletedWorkers) > 0 then
    Q.QExecSql('delete from w_payroll_transfer_item where id in (' + A.Implode(FDeletedWorkers, ',') + ')', []);
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    if Frg1.GetValueI('id', i, False) = 0 then begin
      var idn := Q.QIUD('i', 'w_payroll_transfer_item', '', 'id$i;id_payroll_transfer$i', [-1, ID]);
      Frg1.SetValue('id', i, False, idn);
    end;
    f := A.Explode(cFieldsS, ';');
    va := [];
    for j := 0 to High(f) do
    fn := A.Explode(f[j],'$') ;
    for j := 0 to High(f) do begin
      va := va + [Frg1.GetValue(A.Explode(f[j],'$')[0], i, False)];
    end;
    Q.QIUD('u', 'w_payroll_transfer_item', '', cFieldsS, va);
  end;
  Q.QCommitOrRollback(True);
end;

procedure TFrmWGedtPayrollTransfer.SetButtons;
var
  i: Integer;
  NoNorms: Boolean;
begin
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtRefresh, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtDeduction, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtCard, null, False);
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
  FIsChanged := True;
  SetButtons;
end;


procedure TFrmWGedtPayrollTransfer.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if A.InArray(FieldName, ['employee', 'organization', 'personnel_number', 'is_concurrent']) then
      Params.Background := clmyGray;
  if A.InArray(FieldName, ['total_pay', 'pay_cash']) then
      Params.Background := RGB(220, 255, 190);
  if A.InArray(FieldName, ['total_pay', 'pay_cash']) and (Frg2.GetValueF(FieldName) < 0) then
      Params.Background := clRed;
end;

procedure TFrmWGedtPayrollTransfer.Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
  FIsChanged := True;
  Frg1.SetValue('changed', 1);
end;

procedure TFrmWGedtPayrollTransfer.Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string);
begin
  if Mode <> dbgvCell then
    Exit;
  CalculateRow(Row - 1);
end;


procedure TFrmWGedtPayrollTransfer.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  Handled := True;
  case Tag of
    mbtRefresh:
      if MyQuestionMessage('Загрузить данные из расчетных ведомостей?') = mrYes then
        GetDataFromCalc;
    cmbtCard:
      if MyQuestionMessage('Загрузить НДФЛ и карты?') = mrYes then
//        GetNdflFromExcel;
        GetNdflFromExcelZup;
    cmbtDeduction:
      if MyQuestionMessage('Загрузить удержания?') = mrYes then
        GetDeductionsFromExcel;
    cmbRecalculate: begin
      CalculateAll;
      FIsChanged := True;
      Frg1.InvalidateGrid;
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
  na, na1, na2: TNamedArr;
  MsgDel, MsgIns, MsgChg: string;
  flds: TVarDynArray2;
  flds1, flds2: TVarDynArray;
  cash : Extended;
begin
  //загружаем данные только в режиме редактирования
  if Mode <> fEdit then
    Exit;

  //поля, по кторым сравниваем для сопоставления данных в турв и гшриде
  flds1 := ['id_employee', 'id_organization', 'personnel_number'];
  //поля для заголовка сообщания об изменениях
  flds2 := ['employee', 'organization', 'personnel_number'];

  if FPayrollParams.G('id_employee') <> null then
    Q.QLoadFromQuery(
      'select id_employee, id_organization, personnel_number, max(employee) as employee, max(organization) as organization, sum(total_pay) as total_pay, sum(ors_pay) as ors_pay, null as temp ' +
      'from v_w_payroll_calc_item where id_employee = :p1$i and nvl(id_organization, -100) = nvl(:p2$i, -100) and nvl(personnel_number, -100) = nvl(:p3$s, -100) and dt1 = :dt1$d and id_target_employee is not null ' +
      'group by id_employee, id_organization, personnel_number order by employee',
      [FPayrollParams.G('id_employee'), FPayrollParams.G('id_organization'), FPayrollParams.G('personnel_number'),  FPayrollParams.G('dt1')],
      na1
    )
  else
    Q.QLoadFromQuery(
      'select id_employee, id_organization, personnel_number, ' +
      'max(employee) as employee, max(organization) as organization, sum(total_pay) as total_pay, sum(ors_pay) as ors_pay, null as temp ' +
      'from v_w_payroll_calc_item where dt1 = :dt1$d and id_target_employee is null ' +
      'group by id_employee, id_organization, personnel_number order by employee',
      [FPayrollParams.G('dt1')],
      na1
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
      FIsChanged := True;
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
    FIsChanged := True;
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
end;

procedure TFrmWGedtPayrollTransfer.CalculateRow(Row: Integer);
begin
  if Row = -1 then
    Row := Frg1.MemTableEh1.RecNo - 1;
  Frg1.SetValue('pay_cash', Row, False, RoundTo(
    Frg1.GetValueF('total_pay', Row, False) - Frg1.GetValueF('deduct_enf', Row, False) - Frg1.GetValueF('deduct_ndfl', Row, False) - Frg1.GetValueF('pay_fss', Row, False) -
    Frg1.GetValueF('pay_adv', Row, False) - Frg1.GetValueF('pay_card', Row, False) + Frg1.GetValueF('correction', Row, False), 2
  ));
end;

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
begin
  //выберем файл
  MyData.OpenDialog1.Filter := 'файлы Excel (*.xlsx)|*.xlsx';
  if not MyData.OpenDialog1.Execute then
    Exit;
  if not CreateTXlsMemFileEhFromExists(MyData.OpenDialog1.FileName, True, '$2', XlsFile, st) then
    Exit;
  //получим список совместителей
  EmplCn := Q.QLoadToVarDynArrayOneCol('select id from w_employees where is_concurrent = 1', []);
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
  EmplCn := Q.QLoadToVarDynArrayOneCol('select id from w_employees where is_concurrent = 1', []);
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
            FIsChanged := True;
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
  EmplCn := Q.QLoadToVarDynArrayOneCol('select id from w_employees where is_concurrent = 1', []);
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
end;



end.
