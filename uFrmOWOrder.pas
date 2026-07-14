unit uFrmOWOrder;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls,
  DBGridEhToolCtrls, MemTableDataEh, Db, ADODB, DataDriverEh,
  Clipbrd, GridsEh, DBAxisGridsEh,
  DBGridEh, Menus, Math, Buttons, PrnDbgEh, DBCtrlsEh, Types, DynVarsEh,
  uString, uData, uMessages, uForms, System.DateUtils,
  uDBOra, uFrmBasicMdi, uFrDBGridEh, uLabelColors, ufields, Vcl.Mask, uNamedArr,
  uFrMyPanelCaption;

type
  TFrmOWOrder = class(TFrmBasicMdi)
    PDividor1: TPanel;
    PHeader2: TPanel;
    PHAddDocs: TPanel;
    pnlBottom: TPanel;
    FrgFiles: TFrDBGridEh;
    pnlTop: TPanel;
    bvl1: TBevel;
    PHeaderTop: TPanel;
    PHDates: TPanel;
    dedt_dt_beg: TDBDateTimeEditEh;
    dedt_dt_otgr: TDBDateTimeEditEh;
    dedt_dt_change: TDBDateTimeEditEh;
    dedt_dt_montage_beg: TDBDateTimeEditEh;
    dedt_dt_montage_end: TDBDateTimeEditEh;
    dedt_dt_start: TDBDateTimeEditEh;
    PHCustomer: TPanel;
    cmb_customer: TDBComboBoxEh;
    cmb_customerman: TDBComboBoxEh;
    edt_customercontact: TDBEditEh;
    cmb_customerlegal: TDBComboBoxEh;
    edt_order_number_customer: TDBEditEh;
    cmb_cashtype_account: TDBComboBoxEh;
    edt_address: TDBEditEh;
    PHOrder: TPanel;
    cmb_id_organization: TDBComboBoxEh;
    edt_ornum: TDBEditEh;
    cmb_id_or_format_estimates: TDBComboBoxEh;
    cmb_project: TDBComboBoxEh;
    edt_managername: TDBEditEh;
    cmb_or_reference: TDBComboBoxEh;
    cmb_Area: TDBComboBoxEh;
    cmb_id_type2: TDBComboBoxEh;
    PHFin: TPanel;
    PHTotalSum: TPanel;
    DBNumberEditEh42: TDBNumberEditEh;
    DBNumberEditEh43: TDBNumberEditEh;
    DBNumberEditEh44: TDBNumberEditEh;
    pnlGrid: TPanel;
    FrgItems: TFrDBGridEh;
    PHRelatedDocs: TPanel;
    PHCommentsLeft: TPanel;
    m_comm: TDBMemoEh;
    frmpcItems: TFrMyPanelCaption;
    edt_reglament: TDBEditEh;
    frmpcOrder: TFrMyPanelCaption;
    frmpcCustomer: TFrMyPanelCaption;
    frmpcDates: TFrMyPanelCaption;
    frmpcFinance: TFrMyPanelCaption;
    pnlSelectAreas: TPanel;
    frmpcComments: TFrMyPanelCaption;
    frmpcAddDocs: TFrMyPanelCaption;
    frmpcRelatedDocs: TFrMyPanelCaption;
    FrgRelatedOrders: TFrDBGridEh;
    pnlInvisible: TPanel;
    chbVisCustomer: TDBCheckBoxEh;
    chbVisDates: TDBCheckBoxEh;
    chbVisFinance: TDBCheckBoxEh;
    chbVisAddInfo: TDBCheckBoxEh;
    pnlOrderInfo: TPanel;
    lbl_ITM: TLabel;
    lbl_status_itm: TLabel;
    PHlBasis: TPanel;
    pnlBasisComm: TPanel;
    m_basis_text: TDBMemoEh;
    FrgBasis: TFrDBGridEh;
    frmpcBasis: TFrMyPanelCaption;
    PHSum: TPanel;
    nedt_cost_d_0: TDBNumberEditEh;
    nedt_cost_m_0: TDBNumberEditEh;
    nedt_cost_i_0: TDBNumberEditEh;
    nedt_m_i: TDBNumberEditEh;
    nedt_d_i: TDBNumberEditEh;
    nedt_cost_i: TDBNumberEditEh;
    nedt_m_m: TDBNumberEditEh;
    nedt_d_m: TDBNumberEditEh;
    nedt_cost_m: TDBNumberEditEh;
    nedt_m_d: TDBNumberEditEh;
    nedt_d_d: TDBNumberEditEh;
    nedt_cost_d: TDBNumberEditEh;
    PHFinCaptions: TPanel;
    lbl10: TLabel;
    lbl11: TLabel;
    lbl12: TLabel;
    lbl13: TLabel;
    pnlReclamation: TPanel;
    ed_reclamation_caption: TDBEditEh;
    edt_Complaints: TDBEditEh;
    pnlBasisInfo: TPanel;
    lblBasisInfo: TLabel;
    edt_launched_by_name: TDBEditEh;
    bvlVt1: TBevel;
    chbIsVerifyed: TDBCheckBoxEh;
    bvlVt2: TBevel;
    edt_templatename: TDBEditEh;
    procedure cmb_cashtype_accountKeyPress(Sender: TObject; var Key: Char);
    procedure edt_ComplaintsOpenDropDownForm(EditControl: TControl; Button: TEditButtonEh; var DropDownForm: TCustomForm; DynParams: TDynVarsEh);
    procedure edt_ComplaintsCloseDropDownForm(EditControl: TControl; Button: TEditButtonEh; Accept: Boolean; DropDownForm: TCustomForm; DynParams: TDynVarsEh);
    procedure FormResize(Sender: TObject);
    procedure AfterFormActivate; override;
    procedure lblBasisInfoClick(Sender: TObject);
  private
    //заказ является шаблоном
    FIsTemplate: Boolean;
    //признак для типа обработки заказа, так как менялась логика
    FNewOrderType: Integer;       //1 - новый формат заказа (использует список типов заказа, выбор своййств для расчета даты отгрузки)
    FIdStatus : Integer;               //-
    FOnVerification: Boolean;
    //типы заказов
    FOrderTypes: TNamedArr;
    //наши организации
    FOrganizations: TNamedArr;
    //форматы стандартных изделий (смет)
    FEstimateFormats: TNamedArr;
    //данные по стандартным изделиям для выбранного формата
    FStdItems: TNamedArr;
    //данные по покупателям
    FCustomers: TVarDynArray2;
    FCustomerContacts: TVarDynArray2;
    FCustomerLegal: TVarDynArray2;
    //причины рекламаций
    FComplaints: TVarDynArray2;
    FPDatesWidth, FPFinWidth: Integer;
    //используемый в заказе формат изделий (фиксируется при начале заполнения таблицы)
    FUsedEstimateFormat: Integer;
    function  Prepare: Boolean; override;
    function  SetControlsLayout: Boolean;
    procedure SetAreasCaptions;
    procedure SetVisCheckboxes;
    procedure SetVisPanels(Sender: TObject = nil);
    function  PrepareFrgItems: Boolean;
    function  PrepareFrgRelatedOrders: Boolean;
    function  PrepareFrgBasis: Boolean;
    function  PrepareFrgFiles: Boolean;
    function  PrepareWorkCells: Boolean;
    procedure DefineFields;
    function  LoadOrderComboBoxes: Boolean;
    function  LoadOrder: Boolean;
    procedure LoadComplaints;
    procedure LoadStdItems;
    procedure LoadKnsThn;
    procedure GetComplaintsString;
    procedure ChooseReglamernt;
    procedure ChooseREference;
    procedure SetOrderTypeOrOrganization;
    procedure SetCustomer(ALoadFirst: Boolean);
    procedure OnCustomerControlsChange(Sender: TObject);
    procedure OnCashTypeAccountChange;
    procedure SwitchBasisPanel(ALoadFirst: Boolean);
    procedure SetControlEnabledState;
    procedure SetPermanetFieldProps;
    procedure CreateButtons;
    procedure SetButtons;
    procedure SetEditButtons;
    procedure AfterLoadData;

//    procedure VerifyBeforeSave; virtual;
//    function  Save: Boolean; virtual;
    procedure ControlOnChange(Sender: TObject); override;
    procedure EditButtonsClick(Sender: TObject; var Handled: Boolean); override;
//    procedure ControlOnEnter(Sender: TObject); virtual;
//    procedure ControlOnExit(Sender: TObject); virtual;
//    procedure ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean); virtual;
//    procedure btnOkClick(Sender: TObject); virtual;
//    procedure btnCancelClick(Sender: TObject); virtual;
//    procedure btnClick(Sender: TObject); virtual;



    //события грида изделий
    procedure FrgItemsButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); virtual;
    procedure FrgItemsCellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); virtual;
//    procedure FrgItemsSelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); virtual;
//    procedure FrgItemsOnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); virtual;
//    procedure FrgItemsColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); virtual;
//    procedure FrgItemsAddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); virtual;
    //здесь мождем устанавливать параметры ячейки (номер картинки, readonly) в зависимости от данных в текущей записи
//    procedure FrgItemsColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); virtual;
    //двойной клик в таблице
    //по умолчанию вызывает редактирование или просмотр записи
//    procedure FrgItemsOnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); virtual;
    procedure FrgItemsGetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); virtual;
//    procedure FrgItemsVeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string); virtual;
  public
  end;

var
  FrmOWOrder: TFrmOWOrder;

implementation

uses
  uOrders,
  uWindows,
  D_Order_Complaints,
  uExcel2,
  uFrmOGselOrReglament
  ;

{$R *.dfm}

const
  WMIN_ORDERS = 425;
  WMIN_CUSTOMER = 250;
  PROP_NUM_VER_BEG = 2;


procedure TFrmOWOrder.AfterFormActivate;
//вызывается непосредственно перед показов формы, когда все данные уже загружены и поля формы установлены
begin
  inherited;
  //скорректируем размеры чекбоксов
  Cth.AutoSizeCheckBoxes(Self);
  //установим видимость кнопок
  SetButtons;
end;


procedure TFrmOWOrder.cmb_cashtype_accountKeyPress(Sender: TObject; var Key: Char);
//обработка нажатия клавиши в поле ввода формы оплаты/счета
begin
  //если выбраня наличные илди Без счета, то заблокируем редактирование
  if A.InArray(cmb_cashtype_account.Text, ['наличные', 'безнал (нет счета)']) then
    Key := #0;
end;

procedure TFrmOWOrder.FormResize(Sender: TObject);
var
  i: integer;
begin
  inherited;
  SetVisPanels;
  PHFinCaptions.Height := 26 - 8;
  PHFinCaptions.Top := 12;
  PHSum.Top := PHFinCaptions.Bottom;
  PHRelatedDocs.Width := 140;
  var w := (ClientWidth - PHRelatedDocs.Width) div 3 - 6;
  PHCommentsLeft.Width := w;
  PHlBasis.Align := alNone;
  PHlBasis.Width := w;
  PHlBasis.Left := PHCommentsLeft.Right + 1 + 6;
  PHAddDocs.Align := alNone;
  PHAddDocs.Width := w;
  PHAddDocs.Left := PHlBasis.Right + 1 + 6;
  PHRelatedDocs.Left := PHAddDocs.Right + 1;
  edt_managername.Width := (cmb_project.Width  -  100) div 2;
  edt_launched_by_name.Width := edt_managername.Width;
  edt_launched_by_name.Right := cmb_project.Right;
  edt_templatename.SetRightKeepLeft(pnlFrmBtnsC.Parent.Right - 4);
end;

function TFrmOWOrder.Prepare: Boolean;
var
  crd: TCoord;
  v: Variant;
  va2: TVarDynArray2;
  va: TVarDynArray;
  ca: TControlArray;
  st, st2: string;
  i: Integer;
begin
  Result := False;

  Self.DoubleBuffered := True;
  pnlBottom.Hide;

  //это шаблон заказа
  FIsTemplate := AddParam = 1;

  Caption := S.IIf(FIsTemplate, 'Шаблон заказа', 'Заказ');

  FOpt.DlgPanelStyle := dpsTopLeft;
  FOpt.StatusBarMode := stbmDialog;

  SetControlsLayout;
  DefineFields;
  CreateButtons;

  if not inherited then
    Exit;

  LoadOrder;
  if not LoadOrderComboBoxes then
    Exit;
  F.SetPropsControls;
  PrepareWorkCells;
  PrepareFrgItems;
  PrepareFrgRelatedOrders;
  PrepareFrgBasis;
  PrepareFrgFiles;

  AfterLoadData;

  FWHBounds.X := 1000;
  FWHBounds.Y := 700;

  Result := True;
end;

function TFrmOWOrder.SetControlsLayout: Boolean;
begin
  SetVisCheckboxes;
  Cth.MakePanelsFlat(pnlFrmClient, [], True);
  Cth.AlignControls(pnlSelectAreas, [], True);
  pnlTop.Height := pnlSelectAreas.Height;
  Cth.AlignControls(PHOrder, [], True);
  Cth.AlignControls(PHCustomer, [], True);
  Cth.AlignControls(PHDates, [], True);
  Cth.AlignControls(PHSum, [], True);
  Cth.AlignControls(PHTotalSum, [], True);
  FPDatesWidth := PHDates.Width;
  FPFinWidth := PHFin.Width;
  PHFinCaptions.Height := dedt_dt_beg.Top + dedt_dt_beg.Height;
  PHFin.Height := PHSum.Height + PHTotalSum.Height;
  PHeaderTop.Height := S.MaxOf([PHOrder.Height, PHCustomer.Height, PHDates.Height, PHFin.Height]);
{  PHFin.Align := alNone;
  PHDates.Align := alNone;
  PHOrder.Align := alNone;
  PHCustomer.Align := alNone;}
  Cth.AlignControls(PDividor1, [], True);
  bvl1.Left := 0;
  bvl1.Width := 4000;
  PDividor1.Visible := False;
//  Cth.AlignControls(PHCommentsLeft, [], True);
//  Cth.AlignControls(PHAddDocs, [], True);
  PHeader2.Height := PHCommentsLeft.Height;
//  PHRelatedDocs.Width := PHRelatedDocsCaption.Width + FrgReclamations.Width + FrgSemiproducts.Width;
//  PHAddDocs.Width := Max(PHDates.Width + PHFin.Width, 250);
  PHAddDocs.Width := PHRelatedDocs.Width;
//  PHCommentsLeft.Width := ClientWidth - PHRelatedDocs.Width - PHAddDocs.Width;
//PHCommentsLeft.Align := alclient;
  Width := Width - 1;
  FormResize(Self);
  SetVisCheckboxes;
//  cmb_project.ControlLabel.Left := 5;
end;

procedure TFrmOWOrder.SetAreasCaptions;
begin
  frmpcOrder.SetParameters(True, 'Основное', [[
    ''#13#10
    ]],
    '',
    True
  );
  frmpcCustomer.SetParameters(True, 'Покупатель', [[
    ''#13#10
    ]],
    '',
    True
  );
  frmpcDates.SetParameters(True, 'Даты', [[
    ''#13#10
    ]],
    '',
    True
  );
  frmpcFinance.SetParameters(True, 'Финансы', [[
    ''#13#10
    ]],
    '',
    True
  );
  frmpcComments.SetParameters(True, 'Дополнение', [[
    ''#13#10
    ]],
    '',
    True
  );
  frmpcBasis.SetParameters(True, 'Основание заказа', [[
    ''#13#10
    ]],
    '',
    True
  );
  frmpcAddDocs.SetParameters(True, 'Внешние документы', [[
    ''#13#10
    ]],
    '',
    True
  );
  frmpcRelatedDocs.SetParameters(True, 'Связанные заказы', [[
    ''#13#10
    ]],
    '',
    True
  );
  frmpcItems.SetParameters(True, 'Состав заказа', [[
    ''#13#10
    ]],
    '',
    True
  );

end;

procedure TFrmOWOrder.SetVisCheckboxes;
//установим отметку чекбоксов видимости панелей по их состоянию visible
begin
  chbVisAddInfo.Checked := PHeader2.Visible;
  chbVisCustomer.Checked := PHCustomer.Visible;
  chbVisDates.Checked := PHDates.Visible;
  chbVisFinance.Checked := PHFin.Visible;
{  chbVisAddInfo.Checked := PHeader2.Width > 0;
  chbVisCustomer.Checked := PHCustomer.Width > 0;
  chbVisDates.Checked := PHDates.Width > 0;
  chbVisFinance.Checked := PHFin.Width > 0;}
end;

procedure TFrmOWOrder.SetVisPanels(Sender: TObject = nil);
//установим видимость панелей
var
  i, j, w: Integer;
const
  cIndent = 10;
begin
  if FIsTemplate then
    PHeader2.Visible := False;
  if Sender = chbVisAddInfo then begin
    PHeader2.Visible := chbVisAddInfo.Checked and not FIsTemplate;
    SetVisCheckboxes;
    Exit;
  end;
  //параметры
  var LCheckBoxes := [chbVisCustomer, chbVisDates, chbVisFinance];
  var LPanels := [PHOrder, PHCustomer, PHDates, PHFin];
  var LPanelsSizeable := [True, True, False, False];
  var LWMin := [WMIN_ORDERS, WMIN_CUSTOMER, S.IIf(FIsTemplate, 0, FPDatesWidth).AsInteger, S.IIf(FIsTemplate, 0, FPFinWidth).AsInteger];
  var LWCurr := [0, 0, 0, 0];
  //делаем количество итераций подгонки по количеству чекбоксов управления видимостью
  for i := 0 to High(LCheckBoxes) do begin
    //посчитаем минимально необходимую ширину
    w := 0;
    for j := 0 to High(LPanels) do
      w := w + S.IIf(LPanels[j].Visible, LWMin[j], 0);
    //если панели с учетом видимости и минимальных размеров не умещаются на форме
    if Self.ClientWidth - cIndent < w then
      //пройдем по чекбоксам видимости справа налево
      for j := High(LCheckBoxes) downto 0 do
        //и снимем видимость крайнего правого (но не того по которому кликнули)
        if LCheckBoxes[j] <> Sender then
          if LCheckBoxes[j].Checked then begin
            LCheckBoxes[j].Checked := False;
            Break;
          end;
    //установим видимость панелей
    for j := 1 to High(LPanels) do begin
      LPanels[j].Enabled := LCheckBoxes[j - 1].Checked;
      LPanels[j].Visible := LCheckBoxes[j - 1].Checked;
    end;
    //установим ширину в массиве по минимуму и посчитаем общую ширину
    w := 0;
    for j := 0 to High(LPanels) do begin
      LWCurr[j] := S.IIf(LPanels[j].Visible, LWMin[j], 0);
      w := w + LWCurr[j];
    end;
    //количество видимых панелей с изменяемой шириной
    var LCntSizeable := 0;
    for j := 0 to High(LPanelsSizeable) do
      if (LPanelsSizeable[j]) and (LPanels[j].Visible) then
        Inc(LCntSizeable);
    //расширим пропорционально все видимые растягиваемые панели, если ширина формы больше минимально необходимой для видимых
    for j := 0 to High(LPanels) do
      if (LPanels[j].Visible) and (Self.ClientWidth - cIndent > w) then
        if LPanelsSizeable[j] then
          LPanels[j].Width := LWCurr[j] + (Self.ClientWidth - cIndent - w) div LCntSizeable
        else
          LPanels[j].Width := LWCurr[j];
    //расставим в нужном порядке, так как он при скрытии может сбиваться
    for j := 1 to High(LPanels) do
      LPanels[j].Left := LPanels[j - 1].Right + 1;
    //обновим состояние чекбоксов
    SetVisCheckboxes;
  end;
end;

function TFrmOWOrder.PrepareFrgItems: Boolean;
var
  i, j: integer;
  va2: TVarDynArray2;
  na: TNamedArr;
begin
  Result := False;
  FrgItems.Options := FrDBGridOptionDef + [myogPanelFind, myogMultiSelect, myogIndicatorCheckBoxes, myogHasStatusBar];
  va2 := [];
  for i := 0 to High(RouteFields) do begin
    va2 := va2 + [['r' + IntToStr(i + 1) + '$i', 'Производственный маршрут|' + RouteFields[i], '30', 'chb', 'e']]
  end;
  var LFields: TVarDynArray2 := [
    ['id$i', '_id', '40'],
    ['id_std_item$i', '_id_std', '40'],
    ['id_itm$i', '_id_itm', '40'],
    ['ch$s', '_ch', '40'],
    ['attention$i', '_attention', '40'],
    ['0 as status$s', '*', '20'],
    ['slash$s', 'Паспорт', '90'],
    ['prefix$s', 'Префикс', '60;h'],
    ['itemname$s', 'Изделие', '400;L;w;h', 'e=1:400::T'],
    ['price$f', 'Цена без НДС', '50', 'f=0.00', 'e=0:999999:2:N'],
    ['qnt$f', 'Кол-во', '40', 'e=0:999999:0:N'],
    ['0 as qnt_sgp$f', 'Кол-во с СГП', '40', 'e=0:999999:0:N'],
    ['disassembled$i', 'В раз'#13#10'боре', '40', 'chb'],
    ['control_assembly$i', 'Контр сборка', '40', 'chb'],
    ['decode(nstd, 1, '' '') as nstd$s', 'Н/стд', '30', 'chb', 'e']
  ];
  LFields := LFields + va2;
  LFields := LFields +
  [
    ['wo_estimate$i', 'Без'#13#10'сметы', '40', 'chb'],
    ['id_kns$i', 'Конструктор', '100;L'],
    ['id_thn$i', 'Технолог', '100;L'],
    ['comm$s', 'Дополнение', '200;w;h', 'e=0:400::T'],
    ['0 as sum$f', 'Сумма', '50', 'f=0.00:']
  ];
  FrgItems.Opt.Caption := 'Состав заказа';
  FrgItems.Opt.SetFields(LFields);
  FrgItems.Opt.SetButtons(1, [[mbtInsert, True, 1], [mbtAdd, True, 1], [mbtDelete, True, 1], [], [mbtCtlPanel], [], [mbtCtlPanel ,4000], []]);
  FrgItems.CreateAddControls('1', cntCheck, 'Показать с нулевым количеством', 'ChbView0', '', 4, yrefC, 190);
  FrgItems.Opt.SetGridOperations('uaid');
  FrgItems.Opt.SetTable('v_order_items');
  FrgItems.SetInitData([]);
  FrgItems. Prepare;
  pnlOrderInfo.Parent := TWinControl(FrgItems.FindComponent('pnlTopBtnsCtl2'));
  pnlOrderInfo.Color := RGB(255, 255, 220);
  pnlOrderInfo.BevelOuter := bvRaised;
  pnlOrderInfo.BorderWidth := 2;
  pnlOrderInfo.BorderStyle:=bsSingle;
  pnlOrderInfo.Align:=alClient;

//  FrgItems.Opt.SetPick('id_bcad_nomencl', FEstimateBoardsNomencl, True, True);
  var LFieldsSt := '';
  for i:= 0 to High(LFields) do
    S.ConcatStP(LFieldsSt, Copy(LFields[i][0].AsString, 1, Pos('$', LFields[i][0].AsString) - 1), ', ');
  Q.QLoad('select ' + LFieldsSt + ' from v_order_items where id_order = :id_order$i order by pos', [ID], na);
  FrgItems.SetInitData(na);
  //установим события грида
  FrgItems.OnButtonClick := FrgItemsButtonClick;
  FrgItems.OnCellButtonClick := FrgItemsCellButtonClick;
  FrgItems.OnGetCellReadOnly := FrgItemsGetCellReadOnly;
{    FrgItems.OnSelectedDataChange := FrgItemsSelectedDataChange;
    FrgItems.OnSetSqlParams := FrgItemsOnSetSqlParams;
    FrgItems.OnColumnsUpdateData := FrgItemsColumnsUpdateData;
    FrgItems.OnAddControlChange := FrgItemsAddControlChange;
    FrgItems.OnColumnsGetCellParams := FrgItemsColumnsGetCellParams;
    FrgItems.OnDbClick := FrgItemsOnDbClick;
    FrgItems.OnVeryfyAndCorrectValues := FrgItemsVeryfyAndCorrect;
    FrgItems.OnCellValueSave := FrgItemsCellValueSave;}
  FrgItems.RefreshGrid;
//  FrgItems.MemTableEh1.Active := true;
  FrgItems.IsTableCorrect;
  Result := True;
end;

function TFrmOWOrder.PrepareFrgRelatedOrders: Boolean;
begin
  FrgRelatedOrders.Width := 130;
  FrgRelatedOrders.Options := [];
  FrgRelatedOrders.Opt.SetFields([['id$i', '_id', '100'], ['ornum$s', 'Рекламации', '30;w', 'bt=показать паспорт']]);
  FrgRelatedOrders.SetInitData('select ornum from orders where rownum <= 1', []);
  FrgRelatedOrders.Prepare;
  //FrgRelatedOrders.DbGridEh1.Options := FrgRelatedOrders.DbGridEh1.Options - [dgTitles];
  FrgRelatedOrders.RefreshGrid;
end;

function TFrmOWOrder.PrepareFrgBasis: Boolean;
begin
  FrgBasis.Width := 130;
  FrgBasis.Options := [];
  FrgBasis.Opt.SetFields([['id$i', '_id', '100'], ['name$s', 'Файл', '300;w', 'bt']]);
  FrgBasis.Opt.SetTable('bcad_groups');
//  FrgBasis.Opt.SetButtons(1, [[1001, True, 'Добавить', 'add'], [1002, True, 'Удалить', 'delete'], [1003, True, 'Переключить вид', 'view']], 2, pnlBasisButtons, 0, True);
  FrgBasis.Opt.SetButtons(-3, [[mbtAdd, True], [mbtDelete, True]], 2, nil, 0, True);
  FrgBasis.Prepare;
  FrgBasis.RefreshGrid;
end;

function TFrmOWOrder.PrepareFrgFiles: Boolean;
begin
  FrgFiles.Options := [];
  FrgFiles.Opt.SetFields([['id$i', '_id', '100'], ['name$s', 'Файл', '300;w', 'bt']]);
  FrgFiles.Opt.SetGridOperations('uaid');
  FrgFiles.Opt.SetTable('bcad_groups');
  FrgFiles.SetInitData('*', []);
//  FrgFiles.Opt.SetButtons(1, [[mbtAdd, True], [mbtDelete, True]], 2, pnlFilesButtons, 0, True);
  FrgFiles.Opt.SetButtons(-3, [[mbtAdd, True], [mbtDelete, True]], 2, nil, 0, True);
  FrgFiles.Prepare;
  FrgFiles.DbGridEh1.Options := FrgFiles.DbGridEh1.Options - [dgTitles];
  FrgFiles.RefreshGrid;
end;

function TFrmOWOrder.PrepareWorkCells: Boolean;
var
  i: Integer;
begin
{  Result := False;
  Result := True;
  WorkCellAreas := [];
  Q.QLoad('select id, code, posstd, refers_to_prod_area from v_work_cell_types order by posall asc', [], WorkCellTypes);
  for i := 0 to WorkCellTypes.Count - 1 do begin
    if WorkCellTypes.G(i, 'refers_to_prod_area') = 1 then
      WorkCellAreas := WorkCellAreas + [[]]
    else
      WorkCellAreas := WorkCellAreas + [['ПЩ', 'И', 'ДМ']];
//      FrgItems.Opt.SetPick('id_category', A.VarDynArray2ColToVD1(WorkCellAreas, 0), A.VarDynArray2RowToVD1(WorkCellAreas, i), True);
  end;}
end;

procedure TFrmOWOrder.DefineFields;
begin
  //теги:
  //d - всегда дисейблед
  //c - свойства для покупателя
  //p - свойства, нужные только для отгрузочных заказов
  //t - не обязательны в шаблонах
  //td - в шаблонах недоступны и очищены

  F.DefineFields := [
    ['id$i'],
    ['id_itm;0'],
    ['sync_with_itm$i'],
    ['year;0'],
    ['num;0'],
    ['path;0'],
    ['in_archive;0'],
    ['ch$s'],
    ['dt_end;0'],
    ['dt_to_sgp;0'],
    ['dt_from_sgp;0'],
    ['ndsd$f', 'ndsd$f'],
    ['id_status_itm;0'],
    ['status_itm;0'],
    ['ids_order_properties$s'],
    ['id_status$i'],
    ['status;0'],

    ['templatename$s', S.IIFStr(FIsTemplate, 'V=1:400::N')],

    ['id_type2$i;0', 'V=1:400'],
    ['ornum$i;0'],
    ['or_reference$s','t=td'],
    ['id_reglament$i'],
    ['reglament$s', 'V=1:400', 't=t'],
    ['id_organization$i', 'V=1:400'],
    ['area$i', 'V=1:100', 't=t'],
    ['project$s', 'V=1:500::td', 't=t'],
    ['id_or_format_estimates$i', 'V=1:400'],
    ['managername$s;0', 't=d'],
    ['launched_by_name$s;0', 't=d', #0, User.GetName],
    ['complaints$s;0', 't=td'],
    ['comm$s', 'v=0:4000::N', 't=t'],
    ['basis_text$s', 'v=0:4000::N', 't=t'],

    ['customer$s', 'V=0:400', 't=c'],
    ['customerman$s', 'V=0:400', 't=c'],
    ['customercontact$s', 'V=0:400', 't=c'],
    ['customerlegal$s', 'V=0:400', 't=c'],
    ['customerinn$s', 'V=0:400::N', 't=c'],
    ['address$s', 'V=1:400', 't=c'],
    ['cashtype_account$s;0','V=1:400::N', 't=c'],
    ['address$s', 'V=1:400', 't=c'],
    ['order_number_customer$s', 'V=1:400::N', 't=c'],

    ['dt_end$d;0', 't=t'],
    ['dt_beg$d', 't=d,t'],
    ['dt_change$d', 't=d,t'],
    ['dt_otgr$d', 'v==dedt_dt_beg:=dedt_dt_beg+1000000', 't=t'],
    ['dt_montage_beg$d', 'v==dt_otgr:=dt_otgr+1000000', 't=p,t'],
    ['dt_montage_end$d', 'v==dt_montage_beg:=dt_montage_beg+1000000', 't=p,t'],

    ['cost_i$f','V=', 't=d,td',#0],
    ['cost_i_0$f','V=', 't=d,td',#0],
    ['m_i$f','V=', 't=p,td',#0],
    ['d_i$f','V=', 't=p,td',#0],
    ['cost_m$f','V=', 't=p,td', 't=d',#0],
    ['cost_m_0$f', 't=p,td','V=',#0],
    ['m_m$f','V=', 't=p,td',#0],
    ['d_m$f','V=', 't=p,td',#0],
    ['cost_d$f','V=', 't=td',#0],
    ['cost_d_0$f','V=', 't=d,td' ,#0],
    ['m_d$f','V=', 't=p,td',#0],
    ['d_d$f','V=', 't=p,td',#0],
    ['cost$f','V=', 't=d,td', #0],
    ['cost_wo_nds$f','V=', 't=d,td' ,#0],
    ['cost_av$f','V=0:9999999:2', 't=td' ,#0]


    {['','V=',#0],
    ['','V=',#0],
    ['','V=',#0],
    ['','V=',#0],
    ['','V=',#0],
    ['','V=',#0],}
      ];
  F.PrepareDefineFieldsAdd;
  (*
    ['', null, 'id', '', -1, null, -1],
    ['', null, 'id_itm', '', -1, null, -1],
    ['', null, 'sync_with_itm', 'sync_with_itm$i', -1, null, -1],
    ['', null, 'year', '', -1, null, -1],
    ['', null, 'num', '', -1, null, -1],
    ['', null, 'ornum', '', -1, null, -1],
    ['', null, 'path', '', -1, null, -1],
    ['', null, 'in_archive', '', -1, null, -1],
    ['', null, 'ch', 'ch$s', -1, null, -1],
    ['', null, 'dt_end', '', -1, null, -1],
    ['', null, 'dt_to_sgp', '', -1, null, -1],
    ['', null, 'dt_from_sgp', '', -1, null, -1],
    ['', null, 'ndsd', 'ndsd$f', -1, null, -1],
    ['', null, 'id_status_itm', '', -1, null, -1],
    ['', null, 'status_itm', '', -1, null, -1],
    ['edt_ids_order_properties', null, 'ids_order_properties', 'ids_order_properties$s', 0, null, -1],
    ['edt_id_reglament', null, 'id_reglament', 'id_reglament$i', 0, null, -1],
    ['cmb_Organization', null, 'id_organization', 'id_organization$i', 1, null, 0],
    ['cmb_Area', null, 'area', 'area$i', 1, null, 0],
    ['edt_OrderNum', null, 'ornum', '', 1, null, 0],
    ['cmb_OrderReference', null, 'or_reference', 'or_reference$s', 0, null, 0],
    ['edt_Complaints', null, 'complaints', '', 1, null, 1],
    ['cmb_Format', null, 'id_format', 'id_format$i', 1, null, 0],
    ['cmb_EstimatePath', null, 'id_or_format_estimates', 'id_or_format_estimates$i', 1, null, 0],
    ['cmb_CustomerName', null, 'customer', '', 2, null, 1],
    ['cmb_CustomerMan', null, 'customerman', '', 2, null, 1],
    ['edt_CustomerContacts',  null, 'customercontact', '', 2, null, 1],
    ['cmb_CustomerLegalName', null, 'customerlegal', '', 0, null, 1],
    ['edt_CustomerINN', null, 'customerinn', '', 0, null, 1],
    ['edt_Account', null, 'account', 'account$s', 2, null, 1],
    ['cmb_OrderType', null, 'id_type', 'id_type$i', 1, null, 0],
    ['edt_Address', null, 'address', 'address$s', 2, null, 1],
    ['dedt_Beg', Date, 'dt_beg', 'dt_beg$d', 1, null, -1],
    ['dedt_Otgr', null, 'dt_otgr', 'dt_otgr$d', S.IIf(User.Role(rOr_D_Order_EditDtOtgr) or (FNewOrderType = 0), 1, -1), null, 0],
    ['dedt_MontageBeg', null, 'dt_montage_beg', 'dt_montage_beg$d', 2, null, 1],
    ['dedt_MontageEnd', null, 'dt_montage_end', 'dt_montage_end$d', 2, null, 1],
    ['dedt_Change', null, 'dt_change', 'dt_change$d', 0, null, -1],
    ['cmb_Project', null, 'project', 'project$s', 1, null, 0],
    ['nedt_Items_0', null, 'cost_i_0', 'cost_i_0$f', 0, null, -1],
    ['nedt_Items_M', null, 'm_i', 'm_i$f', 0, null, 1],
    ['nedt_Items_D', null, 'd_i', 'd_i$f', 0, null, 1],
    ['nedt_Items', null, 'cost_i', 'cost_i$f', 0, null, -1],
    ['nedt_Items_NoSgp', null, 'cost_i_nosgp', 'cost_i_nosgp$f', 0, null, -1],
    ['nedt_AC_0', null, 'cost_a_0', 'cost_a_0$f', 0, null, -1],
    ['nedt_AC_M', null, 'm_a', 'm_a$f', 0, null, 1],
    ['nedt_AC_D', null, 'd_a', 'd_a$f', 0, null, 1],
    ['nedt_AC', null, 'cost_a', 'cost_a$f', 0, null, -1],
    ['nedt_Montage_0', null, 'cost_m_0', 'cost_m_0$f', 0, null, 1],
    ['nedt_Montage_M', null, 'm_m', 'm_m$f', 0, null, 1],
    ['nedt_Montage_D', null, 'd_m', 'd_m$f', 0, null, 1],
    ['nedt_Montage', null, 'cost_m', 'cost_m$f', 0, null, -1],
    ['nedt_Trans_0', null, 'cost_d_0', 'cost_d_0$f', 0, null, 1],
    ['nedt_Trans_M', null, 'm_d', 'm_d$f', 0, null, 1],
    ['nedt_Trans_D', null, 'd_d', 'd_d$f', 0, null, 1],
    ['nedt_Trans', null, 'cost_d', 'cost_d$f', 0, null, -1],
    ['nedt_Sum', null, 'cost', 'cost$f', 0, null, -1],
    ['nedt_SumWoNds', null, 'cost_wo_nds', 'cost_wo_nds$f', 0, null, -1],
    ['nedt_Sum_Av', null, 'cost_av', 'cost_av$f', 0, null, 1],
    ['cmb_CashType', null, 'cashtype_add', 'cashtype$i', 2, null, 1],
    ['edt_Manager', User.GetName, 'managername', '', 0, null, -1],
    ['mem_Comment', null, 'comm', 'comm$s', 0, null, 0],
    ['nedt_Attention', 0, 'attention', 'attention$i', 0, null, -1],
    ['', User.GetID, 'id_manager', 'id_manager$i', 0, null, -1]

  *)
  var va := F.GetPropValues('c',fvtCtrl);
end;

function TFrmOWOrder.LoadOrderComboBoxes: Boolean;
//загрузим влияющие данные, которые потребуются для оформления заказа, и установим их в комболбоксы и поля класса
begin
  //новывй формат данных заказа №1
  FNewOrderType := 0;
  if (cOrderNewTypeID > 0) then begin
    if (Mode in [fAdd, fCopy]) or FIsTemplate or (ID >= cOrderNewTypeID) then
      FNewOrderType := 1;
  end;

  //типы паспортов
  Q.QLoad('select * from order_types where posstd is null and (active = 1 or id = :id$i) order by pos', [F.GetPropB('id_type2')], FOrderTypes);
  Cth.AddToComboBoxEh(cmb_id_type2, FOrderTypes.GetCol('name'), FOrderTypes.GetCol('id'));

  //вид оплаты
  Cth.AddToComboBoxEh(cmb_cashtype_account, ['наличные', 'безнал (нет счета)', 'безнал'], []);

  //организации
  Q.QLoad(
    'select name, id, prefix from ref_sn_organizations where id = -1 ' +
    'union all ' +
    'select name, id, prefix from ' +
    '(select * from ref_sn_organizations ' +
    'where id > 0 and prefix is not null and (active = 1 or id = :id$i) order by name)',
    [F.GetPropB('id_organization')],
    FOrganizations
  );

  //производственные площадки
  Q.QLoadToDBComboBoxEh('select shortname, id from ref_production_areas where active = 1 or id = :id$i order by id', [F.GetPropB('area')], cmb_Area, cntComboLK);

  //проекты
  Q.QLoadToDBComboBoxEh('select name from or_projects where (active = 1 or name = :name$s) order by name', [F.GetPropB('project')], cmb_Project, cntComboE);

  //форматы стандартных изделий
  Q.QLoad(
    'select f.name || '' ['' || e.name || '']'' as name, e.id as id, e.id_format, e.type ' +
    'from or_formats f, or_format_estimates e ' +
    'where e.id_format = f.id and ((e.active = 1 and f.active = 1) or e.id = :id$i) and ' +
    '((e.id_format > 1) or (e.id_format = 0)) ' +
    'order by 1 asc',
    [F.GetPropB('id_or_format_estimates')],
    FEstimateFormats
  );

  //данные покупателей
  FCustomers := Q.QLoad('select name, id from ref_customers where active = 1 or name = :name$s order by name', [F.GetPropB('customer')]);
  Cth.AddToComboBoxEh(cmb_customer, FCustomers.Col(0), []);
  FCustomerContacts := Q.QLoad('select name, contact, id_customer, id from ref_customer_contact where active = 1 or name = :name$s order by name', [F.GetPropB('customerman')]);
  FCustomerLegal := Q.QLoad('select legalname, inn, id_customer, id from ref_customer_legal where active = 1 or legalname = :name$s order by legalname', [F.GetPropB('customerlegal')]);
  cmb_customer.Images := MyData.Il_VertLines;
  cmb_customerman.Images := MyData.Il_VertLines;
  cmb_customerlegal.Images := MyData.Il_VertLines;

  LoadComplaints;

  LoadKnsThn;

  if not (Mode in [fAdd, fDelete, fView]) then
    LoadStdItems;

  Result := True;
end;

function TFrmOWOrder.LoadOrder: Boolean;
var
  FieldsSt: string;
  CtrlValues: TVarDynArray;
  i, j: Integer;
begin
  for i := 0 to F.Count - 1 do
    if F.GetProp(i, fvtFNameL) <> '' then begin
      S.ConcatStP(FieldsSt, F.GetProp(i, fvtFNameL), ';');
    end;
  CtrlValues := Q.QLoadRow0(Q.QGetSql('s', 'v_orders', FieldsSt), [id]);
  j := 0;
  for i := 0 to F.Count - 1 do
    if F.GetProp(i, fvtFNameL) <> '' then begin
      F.SetPropP(i, CtrlValues[j], fvtVBeg);
      inc(j);
    end;
  Result := True;
end;

procedure TFrmOWOrder.LoadComplaints;
//загрузим в массив справочник причин рекламации, и данные по статьям рекламациии по заказу
var
  i, j: Integer;
  va2: TVarDynArray2;
  st: string;
begin
  //причины рекламаций  по данному заказу
  va2 := Q.QLoad('select id, id_complaint_reason from order_complaints where id_order = :id$i', [ID]);
  st := '';
  //строка айди комплайнтов, которые есть по заказу, чтобы загрузить их в случае, если они уже не активны в справочнике
  for i := 0 to High(va2) do
    S.ConcatStP(st, S.NSt(va2[i][1]), ',');
  if st <> '' then
    st := ' or id in (' + st + ')';
  //справочник причин рекламаций
  FComplaints := Q.QLoad('select id, name, null, null from ref_complaint_reasons where active = 1' + st + 'order by name', []);
  for i := 0 to High(FComplaints) do begin
    j := A.PosInArray(FComplaints[i][0], va2, 1);
    if j > -1 then begin
      //если есть в таблице рекламаций по данному заказу, то проставим начальные айди (№3 - на момент начала заказа)
      FComplaints[i][2] := va2[j][0];
      //и на момент сохранения, он пока такой же
      FComplaints[i][3] := va2[j][0];
    end;
  end;
  GetComplaintsString;
end;

procedure TFrmOWOrder.GetComplaintsString;
//строковое представление причин рекламаций по заказу
var
  i: Integer;
  Result, st: string;
begin
  Result := '';
  for i := 0 to High(FComplaints) do
    if S.NNum(FComplaints[i][3]) <> 0 then
      S.ConcatStP(Result, FComplaints[i][1], '; ');
  edt_complaints.Text := Result;
  edt_complaints.ReadOnly := True;
  edt_complaints.Hint := edt_complaints.Text;
  edt_complaints.ShowHint := True;
  edt_complaints.EditButtons[0].DropDownFormParams.DropDownForm := Dlg_Order_Complaints;
end;

procedure TFrmOWOrder.edt_ComplaintsCloseDropDownForm(EditControl: TControl; Button: TEditButtonEh; Accept: Boolean; DropDownForm: TCustomForm; DynParams: TDynVarsEh);
//закрытие выпадающей формы причин рекламаций
var
  va: TVarDynArray;
  i: Integer;
begin
  inherited;
  //получим из формы список айди рекламаций, которые отмечены
  va := A.ExplodeV(DynParams['ids_ch'].AsString, #1);
  //проставим в третьей колонки признак что тмечена - 1, а иначе нулл
  for i := 0 to High(FComplaints) do begin
    FComplaints[i][3] := S.IIfV(A.InArray(S.NSt(FComplaints[i][0]), va), 1, null);
  end;
  GetComplaintsString;
end;

procedure TFrmOWOrder.edt_ComplaintsOpenDropDownForm(EditControl: TControl; Button: TEditButtonEh; var DropDownForm: TCustomForm; DynParams: TDynVarsEh);
//открытие выпадающей формы причин рекламаций
//передаем в выпадающую форму рекламаций произвольные параметры
var
  st1, st2, st3: string;
  i: Integer;
begin
  inherited;
  st1 := '';
  st2 := '';
  st3 := '';
  for i := 0 to High(FComplaints) do begin
    S.ConcatStP(st1, FComplaints[i][1], #1);
    S.ConcatStP(st2, FComplaints[i][0], #1);
    if S.NNum(FComplaints[i][3]) > 0 then
      S.ConcatStP(st3, FComplaints[i][0], #1);
  end;
  //весь список рекламаций
  DynParams['names'].AsString := st1;
  //все айди причин рекламаций (айди справочника рекламаций а не записей к заказу)
  DynParams['ids'].AsString := st2;
  //они же, но только те которые для которых колонка [3] не пустая - т.е. текущие выбранные
  DynParams['ids_ch'].AsString := st3;
  //режим ридонли для формы, при просмотре и удалении заказа
  DynParams['readonly'].AsString := S.IIfV(Mode in [fDelete, fView], '1', '0');
end;

procedure TFrmOWOrder.SetOrderTypeOrOrganization;
//установим поля, зависящие от типа заказа и от организации
var
  i, ot, org, est: Integer;
  va2: TVarDynArray2;
begin
  var LOrderType := F.GetProp('id_type2').AsInteger;
  var LOrganization := F.GetProp('id_organization').AsInteger;
  var LEstimate := F.GetProp('id_or_format_estimates').AsInteger;
  ot := FOrderTypes.FindFirst('id', F.GetProp('id_type2'));
  va2 := [];
  //покажем/скроем информацию по рекламачии
  pnlReclamation.Visible := (LOrderType > 0) and (FOrderTypes.G(ot, 'is_complaint') = 1);
  if LOrderType = 0 then begin
    //при пустом значении очистим поля
    F.SetProp('id_organization', null);
    F.SetProp('id_reglament', null);
  end
  else begin
    //создадим список организации, которые доступны для данного типа заказа
    for i := 0 to FOrganizations.High do begin
      if
        //допустимо Прозводство (есть прозводственные или пф)
        ((FOrganizations.G(i, 'id') = -1) and ((FOrderTypes.G(ot, 'is_production_order') = 1) or FOrderTypes.G(ot, 'is_semiproduct_order') = 1))
         or
        //допустима Ника (есть оплата нал. и отгрузочные)
        ((FOrganizations.G(i, 'prefix') = 'Н') and ((FOrderTypes.G(ot, 'is_cash_payment') = 1) and FOrderTypes.G(ot, 'is_shipment_order') = 1))
        or
        //допустиммы остальные (есть отгруузочные)
        ((FOrganizations.G(i, 'prefix') <> 'Н') and (FOrganizations.G(i, 'id') <> -1) and (FOrderTypes.G(ot, 'is_shipment_order') = 1))
      then
        va2 := va2 + [[FOrganizations.G(i, 'name'), FOrganizations.G(i, 'id')]];
    end;
    //установим параметры для ссылки на другой заказ
    if (FOrderTypes.G(ot, 'need_ref') = 1) then begin
      //ссылка обязательна
      F.SetProps('or_reference', '1:400:T', fvtVer);
      F.SetProps('or_reference', True, fvtDsbl);
    end
    else begin
      //ссылка недоступна
      F.SetProps('or_reference', '0:400:T', fvtVer);
      F.SetProps('or_reference', False, fvtDsbl);
      F.SetProp('or_reference', null)
    end;
  end;
  //загрузим список
  Cth.AddToComboBoxEh(cmb_id_organization, va2);
  //восстановим старое значение, если найдено
  org := A.PosInArray(LOrganization, va2, 1);
  if org = - 1 then
    F.SetProp('id_organization', null)
  else
    F.SetProp('id_organization', LOrganization);
  LOrganization := F.GetProp('id_organization').AsInteger;

  //установим список доступных форматов стандартных изделий (они же форматы смет)
  va2 := [];
  if (LOrderType = 0) or (LOrganization = 0) then begin

  end;
  for i := 0 to FEstimateFormats.High do
    if
      (LOrganization <> 0)
      and
      (
      //отгрузочные
      ((LOrganization <> -1) and (FEstimateFormats.G(i, 'type') = STDITEM_TYPE_SHIPMENT))
      or
      //нестандарт
      ((LOrganization <> -1) and (FEstimateFormats.G(i, 'id') = 0) and (FOrderTypes.G(ot, 'is_nonstandard') = 1))
      or
      ((FEstimateFormats.G(i, 'type') = STDITEM_TYPE_PRODUCTION) and (FOrderTypes.G(ot, 'is_production_order') = 1))
      or
      ((FEstimateFormats.G(i, 'type') = STDITEM_TYPE_SEMIPRODUCT) and (FOrderTypes.G(ot, 'is_semiproduct_order') = 1))
      )
    then
      va2 := va2 + [[FEstimateFormats.G(i, 'name'), FEstimateFormats.G(i, 'id')]];
  //загрузим список
  Cth.AddToComboBoxEh(cmb_id_or_format_estimates, va2);
  //восстановим старое значение, если найдено
  est := A.PosInArray(LEstimate, va2, 1);
  if est = - 1 then begin
    F.SetProp('id_or_format_estimates', null);
  end
  else
    F.SetProp('id_or_format_estimates', LEstimate);

  //установми проверку и доступность полей ввода клиента в зависимости от организации
  if F.GetProp('id_organization').AsInteger = -1 then begin
    F.SetProps('c', '', fvtVer);
    F.SetProps('c', False, fvtDsbl);
    F.SetProps('p', null, fvtVCurr);
    F.SetProps('p', False, fvtDsbl);
  end
  else begin
    F.SetProps('c', '1:400:T', fvtVer);
    F.SetProps('c', True, fvtDsbl);
    F.SetPropsFromCustom('p', PROP_NUM_VER_BEG, fvtVer);
    F.SetProps('p', True, fvtDsbl);
  end;

  SetPermanetFieldProps;

end;

procedure TFrmOWOrder.SetCustomer(ALoadFirst: Boolean);
//установим поля, связанные с покупателем
//вызывает события изменения рекурсивно
var
  IdCustomer, i, j: Integer;
begin
  //не обрабатыываем если это Производство или организация не задана
  if F.GetProp('id_organization').AsInteger <= 0 then
    Exit;
  IdCustomer := A.PosInArray(cmb_customer.Text, FCustomers, 0, False);
  IdCustomer := FCustomers[IdCustomer][1];
  cmb_customerman.Items.Clear;
  cmb_customerman.DynProps.Clear;
  cmb_customerlegal.Items.Clear;
  cmb_customerlegal.DynProps.Clear;
  if not ALoadFirst then begin
    cmb_customerman.Text := '';
    edt_customercontact.Text := '';
    cmb_customerlegal.Text := '';
    cmb_cashtype_account.Text := '';
  end;
  OnCashTypeAccountChange;
  if IdCustomer = -1 then
    Exit;
  j := -1;
  //добавим в динпропс значения контактных данных, соответствующие данному человеку
  for i := 0 to High(FCustomerContacts) do begin
    if FCustomerContacts[i][2] = IdCustomer then begin
      cmb_customerman.Items.Add(FCustomerContacts[i][0]);
      cmb_customerman.DynProps[IntToStr(cmb_customerman.Items.Count - 1)].Value := FCustomerContacts[i][1].AsString;
      j := i;
    end;
  end;
  if not ALoadFirst then begin
    if (cmb_customerman.Items.Count = 1) then
      cmb_customerman.ItemIndex := 0;
    ControlOnChange(cmb_customerman);
  end;
  j := -1;
  for i := 0 to High(FCustomerLegal) do begin
    if FCustomerLegal[i][2] = IdCustomer then begin
      cmb_customerlegal.Items.Add(FCustomerLegal[i][0]);
      cmb_customerlegal.DynProps[IntToStr(cmb_customerlegal.Items.Count - 1)].Value := FCustomerLegal[i][1].AsString;
      j := i;
    end;
  end;
  if not ALoadFirst then begin
    if (cmb_customerlegal.Items.Count = 1) then
      cmb_customerlegal.ItemIndex := 0;
    ControlOnChange(cmb_customerlegal);
  end;
end;

procedure TFrmOWOrder.OnCustomerControlsChange(Sender: TObject);
//обработка изменений контролов, связанных с покупателем
var
  st: string;
  Canvas: TControlCanvas;
  i, j: Integer;
  b: Boolean;
begin
  //не обрабатыываем если это Производство или организация не задана
  if F.GetProp('id_organization').AsInteger <= 0 then
    Exit;
  if Sender = cmb_customer then
    SetCustomer(False)
  else if Sender = cmb_customerman then begin
    edt_customercontact.Text := '';
    if cmb_customerman.ItemIndex >= 0 then
      edt_customercontact.Text := cmb_customerman.DynProps[IntToStr(cmb_customerman.ItemIndex)].Value;
  end
  else if Sender = cmb_customerlegal then begin
    cmb_cashtype_account.Text := '';
    if cmb_customerlegal.ItemIndex >= 0 then
      cmb_cashtype_account.Text := cmb_customerlegal.DynProps[IntToStr(cmb_customerlegal.ItemIndex)].Value;
    OnCashTypeAccountChange;
  end;
end;

procedure TFrmOWOrder.SwitchBasisPanel(ALoadFirst: Boolean);
var
  LVisFiles: Boolean;
begin
  LVisFiles := FrgBasis.Visible;
  if ALoadFirst then begin
    LVisFiles := False;
  end
  else begin
    LVisFiles := not LVisFiles;
  end;
  if LVisFiles then begin
    pnlBasisComm.Visible := False;
    pnlBasisComm.Align := alNone;
    FrgBasis.Align := alClient;
    FrgBasis.Visible := True;
    if StringReplace(Trim(m_basis_text.Text) , #13#10, '', [rfReplaceAll]) = '' then
      lblBasisInfo.Caption := '   Основание не задано.'
    else
      lblBasisInfo.Caption := '   ' + StringReplace(Trim(m_basis_text.Text) , #13#10, ' ', [rfReplaceAll]);
  end
  else begin
    FrgBasis.Visible := False;
    FrgBasis.Align := alNone;
    pnlBasisComm.Align := alClient;
    pnlBasisComm.Visible := True;
    if FrgBasis.GetCount = 0 then
      lblBasisInfo.Caption := '   Файлы не загружены.'
    else
      lblBasisInfo.Caption := '   Загружено ' + S.GetEndingFull(FrgBasis.GetCount, 'файл', '', 'а', 'ов') + '.';
  end;
end;

procedure TFrmOWOrder.ControlOnChange(Sender: TObject);
var
  SenderName, SenderNameL: string;
  SenderValue : Variant;
begin
  SenderName := TControl(Sender).Name;
  SenderNameL := S.ToLower(TControl(Sender).Name);
  SenderValue := Cth.GetControlValue(Sender);

  //чекбоксы видимости панелей
  if A.InArray(SenderNameL, ['chbvisaddinfo', 'chbviscustomer', 'chbvisdates', 'chbvisfinance']) then
    SetVisPanels(Sender);

  if (Sender = cmb_id_type2) or (Sender = cmb_id_organization) then begin
    SetOrderTypeOrOrganization;
  end;
  if Sender = cmb_cashtype_account then
    OnCashTypeAccountChange;
  OnCustomerControlsChange(Sender);
end;

procedure TFrmOWOrder.EditButtonsClick(Sender: TObject; var Handled: Boolean);
begin
//  if (TEditButtonControlEh(Sender).Owner = edt_reglament) then //and (TEditButtonControlEh(Sender).ButtonImages.NormalIndex = 39) then
  if (TEditButtonControlEh(Sender).Owner = cmb_or_reference) then
    ChooseREference;
  if (TEditButtonControlEh(Sender).Owner = edt_reglament) then
    ChooseReglamernt;
end;

procedure TFrmOWOrder.ChooseREference;
begin
    Wh.ExecReference(myfrm_J_Orders_SEL_1, Self, [myfoDialog, myfoModal], VarArrayOf([]));
    if Length(Wh.SelectDialogResult) > 0 then
      cmb_or_reference.Text := Wh.SelectDialogResult2[0][2];
end;


procedure TFrmOWOrder.FrgItemsButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  case Tag of
    mbtInsert:
      FrgItems.InsertRow;
    mbtAdd:
      FrgItems.AddRow;
    mbtDelete:
      FrgItems.DeleteRow;
  end;
end;

procedure TFrmOWOrder.FrgItemsCellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
  if Fr.GetValue = null then begin
    if Fr.DbGridEh1.FindFieldColumn(Fr.CurrField).KeyList.Count = 0 then
      Fr.SetValue(Fr.CurrField, ' ')
    else
      Fr.SetValue(Fr.CurrField, Fr.DbGridEh1.FindFieldColumn(Fr.CurrField).KeyList[0]);
  end
  else
    Fr.SetValue(Fr.CurrField, null);
end;

procedure TFrmOWOrder.FrgItemsGetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
  if TColumnEh(Sender).KeyList.Count > 0 then
    ReadOnly := False;
end;

procedure TFrmOWOrder.lblBasisInfoClick(Sender: TObject);
begin
  SwitchBasisPanel(False);
end;

procedure TFrmOWOrder.OnCashTypeAccountChange;
//при изменении на Безнал очистим поле для ввода счета
begin
  cmb_cashtype_account.LimitTextToListValues := False;
  if cmb_cashtype_account.Text = 'безнал' then
    cmb_cashtype_account.Text := '';
end;

procedure TFrmOWOrder.SetControlEnabledState;
//установим возможность редактирования полей ввода
begin
  if Mode in [fView, fDelete] then
    Exit;
  //заблокируем те, которые никогда нельзя редактировать
  F.SetProps('d', False, fvtDsbl);
end;

procedure TFrmOWOrder.CreateButtons;
begin
   FOpt.DlgButtonsM :=
    [
    [mbtSave],
    [mbtApprove],
    [mbtUnApprove, True, 150],
    [mbtGo],
    [mbtDelete],
    [mbtClose, True, 'Закрыть', 'cancel']
    ];
end;

procedure TFrmOWOrder.SetButtons;
begin
  if (Mode = fView) and (not FIsTemplate) then
    SetButtonsVisibilityAndArrange([], ['edt_templatename', 'chbIsVerifyed', mbtSave, mbtDelete, mbtApprove, mbtUnApprove, mbtGo])
  else if (Mode = fView) and (FIsTemplate) then
    SetButtonsVisibilityAndArrange([], ['chbIsVerifyed', 'chbVisDates', 'chbVisFinance', 'chbVisAddInfo', mbtSave, mbtDelete, mbtApprove, mbtUnApprove, mbtGo])
  else if (Mode = fDelete) and (not FIsTemplate) then
    SetButtonsVisibilityAndArrange([], ['edt_templatename', 'chbIsVerifyed', mbtSave, mbtApprove, mbtUnApprove, mbtGo])
  else if (Mode = fDelete) and (FIsTemplate) then
    SetButtonsVisibilityAndArrange([], ['chbIsVerifyed', 'chbVisDates', 'chbVisFinance', 'chbVisAddInfo', mbtSave, mbtApprove, mbtUnApprove, mbtGo])
  else if FIsTemplate then
    SetButtonsVisibilityAndArrange([], ['chbIsVerifyed', 'chbVisDates', 'chbVisFinance', 'chbVisAddInfo', mbtDelete, mbtApprove, mbtUnApprove, mbtGo])
  else if F.GetProp('id_status') = ORDER_ID_STATUS_DRAFT then
    SetButtonsVisibilityAndArrange([], ['edt_templatename', S.IIf(FOnVerification, '-' , 'chbIsVerifyed'), mbtDelete, mbtUnApprove, mbtGo])
  else if F.GetProp('id_status') = ORDER_ID_STATUS_APPROVED then
    SetButtonsVisibilityAndArrange([], ['edt_templatename', 'chbIsVerifyed', mbtDelete, mbtApprove, mbtSave])
  else if F.GetProp('id_status') = ORDER_ID_STATUS_STARTED then
    SetButtonsVisibilityAndArrange([], ['edt_templatename', 'chbIsVerifyed', mbtDelete, mbtApprove, mbtUnApprove, mbtGo])
//    chbVisDates,    chbVisCustomer,chbVisFinance chbVisAddInfo

end;


procedure TFrmOWOrder.AfterLoadData;
//вызывается в препаре после загрузки данных и родительского метожда
begin
  FUsedEstimateFormat := F.GetPropB('id_or_format_estimates').AsIntegerM;
  SetAreasCaptions;
  SetEditButtons;
  F.CopyPropToCustom('', fvtVer, PROP_NUM_VER_BEG);
  SetControlsEditable([], Mode in [fEdit, fCopy, fAdd]);
  SetOrderTypeOrOrganization;
  SetCustomer(True);

  if FIsTemplate then begin
    {chbVisDates.Checked := False;
    chbVisFinance.Checked := False;
    chbVisAddInfo.Checked := False;}
    chbVisDates.Enabled := False;
    chbVisFinance.Enabled := False;
    chbVisAddInfo.Enabled := False;
  end;

  //буферизация, иначе тормозит ресайз, тк много контролов меняют размер

  SwitchBasisPanel(True);
  Verify(nil);
  SetPermanetFieldProps;
end;

procedure TFrmOWOrder.SetPermanetFieldProps;
//установить доступность/значения контролов глобально
begin
  //всегда нередактируемые поля
  F.SetProps('d', False, fvtDsbl);
  //для шаблонов: t необязательные, td недоступные
  if FIsTemplate then begin
    F.SetProps('td', null, fvtVCurr);
    F.SetProps('td', False, fvtDsbl);
    F.SetProps('t;td', '', fvtVer);
  end;
end;

procedure TFrmOWOrder.SetEditButtons;
begin
//  Cth.SetEditButtons(cmb_or_reference, [[37, 'Обновить'], [39, 'Выбрать из справочника']]);
  Cth.SetEditButtons(cmb_or_reference, [[0, 'Выбрать из списка']]);
  Cth.SetEditButtons(edt_reglament, [[0, 'Задать регламент']]);
end;

procedure TFrmOWOrder.ChooseReglamernt;
var
  ReglamentData: TMDIResult;
begin
  if FNewOrderType <> 1 then
    Exit;
  ReglamentData := TFrmOGselOrReglament.Show(
    Self, '', MyFormOptions + [myfoDialog, myfoSizeable, myfoModal], S.IIf(not (Mode in [fView, fDelete]), fEdit, fView), F.GetProp('cmb_type2'), F.GetProp('ids_order_properties')
  );
  if ReglamentData.ModalResult <> mrOk then
    Exit;
  if ReglamentData.DataA[0][0] = -1 then begin
    F.SetProp('id_reglament', null);
    F.SetProp('reglament', '');
    F.SetProp('ids_order_properties', '');
    F.SetProp('dt_otgr', null);
  end
  else begin
    F.SetProp('id_reglament', ReglamentData.DataA[0][0]);
    F.SetProp('reglament', ReglamentData.DataA[0][3]);
    F.SetProp('ids_order_properties', ReglamentData.DataA[0][1]);
    F.SetProp('dt_otgr', IncDay(dedt_dt_beg.Value, ReglamentData.DataA[0][2] - 1));
  end;
end;

procedure TFrmOWOrder.LoadStdItems;
//загрузим стандартнуую номенклатуру в свойство и в список грида
var
  i, j: Integer;
  st : string;
  v: Variant;
  bmp: TBitmap;
begin
  FStdItems.Clear;
  if Mode in [fDelete, fView] then
    Exit;
  var LFormat := F.GetProp('id_or_format_estimates').AsInteger;
  //если нестандарт, то не нужно устанавливать список
  if LFormat = 0 then
    Exit;
  st := '';
  //поля маршщрутов
  for i := 0 to High(RouteFields) do
    S.ConcatStP(st, 'r' + IntToStr(i), ', ');
  //стандартные изделия по данному типу сметы
  Q.QLoad(
    'select id, name, price, wo_estimate, ' + st + ' ' +
    'from or_std_items ' +
    'where ' + '(id_or_format_estimates = :id$i) and (id_or_format_estimates <> 0) ' +
    'order by name asc',
    [LFormat],
    FStdItems
  );
  //установим список в гриде
  FrgItems.Opt.SetPick('name', FStdItems.GetCol('name'), FStdItems.GetCol('id'), False, True);
end;

procedure TFrmOWOrder.LoadKnsThn;
//загрузим и создадиим в таблице списки конструкторов и технологов
//добавим в список кроме действующих еще тех, кто есть в данном заказе (или шаблоне идли заказе, который копируется)
var
  IdsKns, IdsThn: string;
  Kns, Thn: TNamedArr;
begin
  //получим айди уже проставленнных в заказе конструкторов и технологов
  if Mode <> fAdd then begin
    IdsKns := Q.QLoadCol('select distinct id_kns from order_items where id_kns is not null and id_kns >= 0 and id_order = :id$i', [ID]).Implode(', ');
    IdsThn := Q.QLoadCol('select distinct id_thn from order_items where id_thn is not null and id_thn >= 0 and id_order = :id$i', [ID]).Implode(', ');
  end;
  S.ConcatStP(IdsKns, '-9999999', ', ');
  S.ConcatStP(IdsThn, '-9999999', ', ');
  //загрузим активных и используемых конструкторв и технологов
  Q.QLoad('select name, id from adm_users where (job = :id_job$i and active = 1) or id in (' + IdsKns + ') order by name asc', [myjobKNS], Kns);
  Q.QLoad('select name, id from adm_users where (job = :id_job$i and active = 1) or id in (' + IdsThn + ') order by name asc', [myjobTHN], Thn);
  //установим листы
  FrgItems.Opt.SetPick('id_kns', ['[нет]', '[конструктор]'] + Kns.GetCol('name'), ['-100', '-101'] + Kns.GetCol('id'), False, True);
  FrgItems.Opt.SetPick('id_thn', ['[нет]', '[технолог]'] + Thn.GetCol('name'), ['-100', '-102'] + Thn.GetCol('id'), False, True);
end;


end.


