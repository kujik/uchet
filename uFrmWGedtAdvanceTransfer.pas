unit uFrmWGedtAdvanceTransfer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls,
  ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls, MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd,
  MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils, Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uFrmBasicGrid2, uFrDBGridEh, uFrmBasicMdi, uNamedArr
  ;

type
  TFrmWGedtAdvanceTransfer = class(TFrmBasicGrid2)
  private
    FPayrollParams: TNamedArr;
    FDeletedWorkers: TVarDynArray;
    FIsEditableAdd, FIsEditableAll: Boolean;
    function  PrepareForm: Boolean; override;
    function  Save: Boolean; override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;
    function  GetDataFromDb: Integer;
    function  GetDataFromCalc: Integer;
    function  GetCaption(Colored: Boolean = False): string;
    procedure SetButtons;
    procedure SetColumns;
    procedure SetEditableAll;
    procedure FinalizePayroll;
    procedure CalculateAll;
    procedure CalculateRow(Row:Integer);
  public
  end;

var
  FrmWGedtAdvanceTransfer: TFrmWGedtAdvanceTransfer;

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
    'id$i;id_employee$i;personnel_number$s;total_pay$f;correction$f;pay_cash$f';
  cFieldsL =
    'employee$s;temp$i';

  cmbtEditAll = 1004;
  cmbRecalculate = 1005;

  cColWidth = 45;

function TFrmWGedtAdvanceTransfer.PrepareForm: Boolean;
var
  i, j, w1: Integer;
  v: Variant;
  wcol, fcol: string;
begin
  Result:=False;

  Caption:='Авансовая ведомость к перечислению';
  FOpt.RefreshParent := True;

  if FormDbLock = fNone then Exit;

  Q.QLoad('select id, id_employee, personnel_number, dt, employee, is_finalized from v_w_advance_transfer where id = :id$i', [ID], FPayrollParams);
  if FPayrollParams.Count = 0 then begin
    MsgRecordIsDeleted;
    Exit;
  end;

  FDeletedWorkers := [];
  Frg1.Options := FrDBGridOptionDef + [myogPanelFind, myogColumnResize, myogPanelfind, myogSorting, myogHasStatusBar] - [myogColumnFilter];
  //определим поля
  //теги (1-редактирования всегда)
  wcol := IntToStr(cColWidth) + ';r';
  fcol := 'f=###,###,###:';
  Frg1.Opt.SetFields([
    ['id$i', '_id','40'],
    ['id_employee$i', '_id_employee', wcol],
//    ['id_organization$i', '_id_org', wcol],
    ['temp$i', '_temp', wcol],
    ['employee$s', 'Работник|ФИО', '200;h'],
    ['personnel_number$s', '!Табельный номер', '60'],
    ['total_pay$f', '~Итого' + sLineBreak + ' начислено', wcol, fcol],
    ['correction$f', '~Корректировка', wcol, fcol, 't=1'],
    ['pay_cash$f', '~Итого к'#13#10' получению', wcol, fcol]
  ]);
  Frg1.Opt.SetGridOperations('u');
  Frg1.Opt.SetButtons(1, [
    [mbtRefresh, True, 'Обновить данные из расчетных ведомостей'],[],
    [-cmbRecalculate, True, 'Пересчитать все'],
    [-cmbtEditAll, True, 'Разрешить редактирование всех полей'],
    [-mbtExcel, AddParam = null],
    [],[mbtLock],
    [],[mbtCtlPanel]
  ]);
  Frg1.Opt.ButtonsNoAutoState := [0];

  Frg1.CreateAddControls('1', cntLabelClr, GetCaption(True), 'lblDivision', '', 4, yrefT, 800);
  Frg1.CreateAddControls('1', cntLabelClr, '', 'lblInfo', '', 4, yrefB, 800);
  Frg1.SetInitData([], '');

  Frg1.InfoArray := [[
    Caption + '.'#13#10#13#10
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
end;

function TFrmWGedtAdvanceTransfer.Save: Boolean;
//сохраним ведомость
var
  i, j: Integer;
  f, fn, va: TVarDynArray;
begin
  Result := False;
  Q.QBeginTrans(True);
  //запишем признак закрытия ведомости
  Q.QExecSql('update w_advance_transfer set is_finalized = :p3$i where id = :id$i', [FPayrollParams.G('is_finalized'), ID]);
  //удалим из БД всех, кого удаляли из списка при нажатии кнопки ТУРВ
  if Length(FDeletedWorkers) > 0 then
    Q.QExecSql('delete from w_advance_transfer_item where id in (' + A.Implode(FDeletedWorkers, ',') + ')', []);
  //обновим в бд все строки таблицы
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    if Frg1.GetValueI('id', i, False) = 0 then begin
      var idn := Q.QSave('i', 'w_advance_transfer_item', '', 'id$i;id_advance_transfer$i', [-1, ID]);
      Frg1.SetValue('id', i, False, idn);
    end;
    f := A.Explode(cFieldsS, ';');
    va := [];
    for j := 0 to High(f) do
      fn := A.Explode(f[j], '$');
    for j := 0 to High(f) do begin
      va := va + [Frg1.GetValue(A.Explode(f[j], '$')[0], i, False)];
    end;
    Q.QSave('u', 'w_advance_transfer_item', '', cFieldsS, va);
  end;
  Q.QCommitOrRollback(True);
  Result := Q.CommitSuccess;
end;

procedure TFrmWGedtAdvanceTransfer.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if A.InArray(FieldName, ['employee', 'personnel_number', 'is_concurrent']) then
      Params.Background := clmyGray;
  if A.InArray(FieldName, ['total_pay', 'pay_cash']) then
      Params.Background := RGB(220, 255, 190);
  if A.InArray(FieldName, ['total_pay', 'pay_cash']) and (Frg2.GetValueF(FieldName) < 0) then
      Params.Background := clRed;
end;

procedure TFrmWGedtAdvanceTransfer.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  Handled := True;
  case Tag of
    mbtRefresh:
      if MyQuestionMessage('Загрузить данные из расчетных ведомостей?') = mrYes then
        GetDataFromCalc;
    cmbRecalculate:
      begin
        CalculateAll;
        Frg1.SetState(True, null, null);
        Frg1.InvalidateGrid;
      end;
    mbtLock:
      FinalizePayroll;
  else
    Handled := False;
  end;
  if Handled then
    SetButtons;
end;

procedure TFrmWGedtAdvanceTransfer.Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
//вызывается после ручного изменения ячейки. установим статус изменения грида и пересчитаем строку
begin
  Fr.SetState(True, null, null);
  CalculateRow(-1);
end;

function TFrmWGedtAdvanceTransfer.GetDataFromDb: Integer;
//прочитаем ведомость (все данные) из БД и заполним ими сетку
var
  na : TNamedArr;
begin
  Q.QLoad(Q.QGetSql('a', 'v_w_advance_transfer_item',
    cFieldsS + ';' + cFieldsL) + ' where id_advance_transfer = :id$i' + S.IIFStr(AddParam <> null, ' and id_employee = ' + AddParam.AsString) + ' order by employee, personnel_number',
    [ID], na
  );
  Frg1.LoadData(na);
end;

function TFrmWGedtAdvanceTransfer.GetDataFromCalc: Integer;
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
  flds1 := ['id_employee', 'personnel_number'];
  //поля для заголовка сообщания об изменениях
  flds2 := ['employee', 'personnel_number'];

  if FPayrollParams.G('id_employee') <> null then
    Q.QLoad(
      'select id_employee, personnel_number, max(employee) as employee, sum(total_pay) as total_pay, null as temp ' +
      'from v_w_advance_calc_item where id_employee = :p1$i and personnel_number = :p3$s and dt = :dt$d and id_target_employee is not null ' +
      'group by id_employee, personnel_number order by employee',
      [FPayrollParams.G('id_employee'), FPayrollParams.G('personnel_number'),  FPayrollParams.G('dt')],
      na1
    )
  else
    Q.QLoad(
      'select id_employee, personnel_number, ' +
      'max(employee) as employee, sum(total_pay) as total_pay, null as temp ' +
      'from v_w_advance_calc_item where dt = :dt$d and id_target_employee is null ' +
      'group by id_employee, personnel_number order by employee',
      [FPayrollParams.G('dt')],
      na1
    );

  NoData := Frg1.GetCount = 0;

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

function TFrmWGedtAdvanceTransfer.GetCaption(Colored: Boolean = False): string;
//вернем текст для лейбла заголовка
begin
  var dt := FPayrollParams.G('dt');
  Result := S.IIFStr(Colored, '$FF0000') + S.IIf(FPayrollParams.G('employee') <> null, FPayrollParams.G('employee'), 'Все работники') +
    S.IIFStr(Colored, '$000000') + ' с' + S.IIFStr(Colored, '$FF00FF') +' ' + DateToStr(dt) +
    S.IIFStr(Colored, '$000000') + ' по ' + S.IIFStr(Colored,  '$FF00FF') + DateToStr(EncodeDate(YearOf(dt), MonthOf(dt), 15));
end;

procedure TFrmWGedtAdvanceTransfer.SetButtons;
//установим доступность кнопок и пунктов меню, а также подсказу в заголовке
begin
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtRefresh, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtLock, null, False);
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
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtLock, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtEditAll, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbRecalculate, null, True);
    Frg1.DbGridEh1.ReadOnly := False;
  end;
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtLock, S.IIf(FPayrollParams.G('is_finalized') = 1, 'Отменить закрытие ведомости', 'Закрыть ведомость'), null);
  SetColumns;
  Frg1.DbGridEh1.Invalidate;
end;

procedure TFrmWGedtAdvanceTransfer.SetColumns;
begin
  Frg1.Opt.SetColFeature('*', 'e', False, False);
  Frg1.Opt.SetColFeature('1', 'e', True, False);
  if FIsEditableAll then
    Frg1.Opt.SetColFeature('*', 'e', True, False);
  Frg1.SetColumnsVisible;
end;

procedure TFrmWGedtAdvanceTransfer.SetEditableAll;
begin
  if Frg1.DbGridEh1.ReadOnly then
    Exit;
  if User.IsDeveloper then
    FIsEditableAll := not FIsEditableAll;
  SetColumns;
end;

procedure TFrmWGedtAdvanceTransfer.FinalizePayroll;
begin
  if MyQuestionMessage(S.IIf(S.NInt(FPayrollParams.G('is_finalized')) = 1, 'Снять статус "Закрыта" для ведомости?', 'Поставить статус "Закрыта" для ведомости?')) <> mrYes then
    Exit;
  FPayrollParams.SetValue(0, 'is_finalized', IIf(S.NInt(FPayrollParams.G('is_finalized')) = 1, 0, 1));
  Frg1.SetState(True, null, null);
  SetButtons;
end;

procedure TFrmWGedtAdvanceTransfer.CalculateAll;
var
  i: Integer;
begin
  for i := 0 to Frg1.GetCount(False) - 1 do
    CalculateRow(i);
end;

procedure TFrmWGedtAdvanceTransfer.CalculateRow(Row: Integer);
begin
  if Row = -1 then
    Row := Frg1.MemTableEh1.RecNo - 1;
  Frg1.SetValue('pay_cash', Row, False, RoundTo(Frg1.GetValueF('total_pay', Row, False) + Frg1.GetValueF('correction', Row, False), 2));
end;

end.
