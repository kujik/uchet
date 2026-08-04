
unit uFrmOWOrder;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls,
  DBGridEhToolCtrls, MemTableDataEh, Db, ADODB, DataDriverEh,
  Clipbrd, GridsEh, DBAxisGridsEh, IOUtils,
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
    cmb_area: TDBComboBoxEh;
    cmb_id_type2: TDBComboBoxEh;
    PHFin: TPanel;
    PHTotalSum: TPanel;
    nedt_cost: TDBNumberEditEh;
    nedt_cost_wo_nds: TDBNumberEditEh;
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
    edt_customerinn: TDBEditEh;
    procedure cmb_cashtype_accountKeyPress(Sender: TObject; var Key: Char);
    procedure edt_ComplaintsOpenDropDownForm(EditControl: TControl; Button: TEditButtonEh; var DropDownForm: TCustomForm; DynParams: TDynVarsEh);
    procedure edt_ComplaintsCloseDropDownForm(EditControl: TControl; Button: TEditButtonEh; Accept: Boolean; DropDownForm: TCustomForm; DynParams: TDynVarsEh);
    procedure FormResize(Sender: TObject);
    procedure AfterFormActivate; override;
    procedure FrgItemsDbGridEh1ApplyFilter(Sender: TObject);
    procedure FrgItemsDbGridEh1Enter(Sender: TObject);
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
    //производственные площадки
    FProdAreas: TNamedArr;
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
    FOrganizationIndex: Integer;
    FOrderTypeIndes: Integer;
    //список изделий в заказе на момент его загрузки
    FOrderItemsOld: TNamedArr;
    function  Prepare: Boolean; override;
    function  SetControlsLayout: Boolean;
    procedure SetAreasCaptions;
    procedure SetVisCheckboxes;
    procedure SetVisPanels(Sender: TObject = nil);
    function PrepareFrgItems: Boolean;
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
    procedure AfterLoadOrder;
    procedure GetComplaintsString;
    procedure ChooseReglamernt;
    procedure ChooseReference;
    procedure SetOrderTypeOrOrganization(Sender: TObject);
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
    procedure AfterLoadTables;
    procedure CheckDates;
    function  GetAddFiles(AMode: Integer): TNamedArr;
    procedure ViewAddFile(AFrg: TFrDBGridEh);
    procedure AddAddFile(AFrg: TFrDBGridEh; ATag: Integer);
    function  GetPathToOrders: string;
    procedure GetOrderNumber;
    procedure GetOrderPath;
    procedure RecalculateItemsPrices;
    procedure RecalculateSum;
    procedure CalculateFrgItemsRow(const AFieldName: string = '');
    function  Save: Boolean; override;
    function  SaveOrderItems: Boolean;
    procedure SaveCustomer;
    procedure Verify(Sender: TObject; onInput: Boolean = False); override;
    function  SetTaskForServer: Boolean;
    procedure GetFrgItemsRowChanges;


//    procedure VerifyBeforeSave; virtual;
//    function  Save: Boolean; virtual;
    procedure ControlOnChange(Sender: TObject); override;
    procedure EditButtonsClick(Sender: TObject; var Handled: Boolean); override;
    procedure btnClick(Sender: TObject); override;
//    procedure ControlOnEnter(Sender: TObject); virtual;
//    procedure ControlOnExit(Sender: TObject); virtual;
//    procedure ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean); virtual;
//    procedure btnOkClick(Sender: TObject); virtual;
//    procedure btnCancelClick(Sender: TObject); virtual;
//    procedure btnClick(Sender: TObject); virtual;



    //события грида изделий
    procedure FrgItemsButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); virtual;
    procedure FrgItemsCellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); virtual;
    procedure FrgItemsSelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); virtual;
    procedure FrgItemsOnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); virtual;
    procedure FrgItemsColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); virtual;
    procedure FrgItemsAddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); virtual;
    procedure FrgItemsColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); virtual;
    procedure FrgItemsCellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); virtual;
    //двойной клик в таблице
    //по умолчанию вызывает редактирование или просмотр записи
//    procedure FrgItemsOnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); virtual;
    procedure FrgItemsGetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); virtual;
    procedure FrgItemsVeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string); virtual;
    procedure FrgItemsRowVerify(Row: Integer);
    //события грида внешних документов и грида файлов основания заказа
    procedure FrgFilesButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); virtual;
    procedure FrgFilesCellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); virtual;
  public
  end;

var
  FrmOWOrder: TFrmOWOrder;

implementation

uses
  uOrders,
  uWindows,
  uSys,
  uTasks,
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
  FOpt.RefreshParent := True;

  SetControlsLayout;
  DefineFields;
  CreateButtons;

  if not inherited Prepare then
    Exit;

  LoadOrder;
  AfterLoadOrder;
  if not LoadOrderComboBoxes then
    Exit;

  F.SetPropsControls;

  AfterLoadData;

  PrepareWorkCells;
  PrepareFrgItems;
  PrepareFrgRelatedOrders;
  PrepareFrgBasis;
  PrepareFrgFiles;

  AfterLoadTables;

  edt_templatename.Visible := FIsTemplate;
  if Mode in [fView, fDelete] then begin
    edt_templatename.Enabled := False;
    SetControlsEditable([], False);
  end;


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
    False //!
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
//параметры грида изделдий заказа
var
  i, j: integer;
  va2: TVarDynArray2;
  na: TNamedArr;
  o: TFrDBGridEditOptions;
begin
  Result := False;
  FrgItems.Options := FrDBGridOptionDef + [myogPanelFind, myogMultiSelect, myogIndicatorCheckBoxes, myogHasStatusBar];
  //переменная часть, производственные участки
  va2 := [];
  for i := 0 to High(RouteFields) do begin
    va2 := va2 + [['r' + IntToStr(i + 1) + '$i', 'Производственный маршрут|' + RouteFields[i], '25', 'chb', 'e', 't=s,ch']]
//    va2 := va2 + [['nvl(r' + IntToStr(i + 1) + ',0) as ' + 'r' + IntToStr(i + 1) + '$i', 'Производственный маршрут|' + RouteFields[i], '25', 'chb', 'e=0:1:0', 't=s,ch']]
  end;
  //теги: s - сохранение в бд, ch - отслеживание изменений поля
  var LFields: TVarDynArray2 := [
    ['id$i', '_id', '40', 't=s'],
    ['id_std_item$i', '_id_std', '40', 't=s'],
    ['id_itm$i', '_id_itm', '40', 't=s'],
    ['ch$s', '_ch', '40', 't=s'],
    ['pos$i', '_pos', '20', 't=s'],
    ['std$i', '_std', '20', 't=s'],
    ['attention$i', '_attention', '40', 't=s'],
    ['null as status$s', '*', '20', 'pic=e;0:16;12'],
    ['slash$s', 'Паспорт', '90'],
    ['prefix$s', 'Префикс', '60;h'],
    ['name$s', 'Изделие', '400;w;h', 'e=1:400::T', 't-ch'],
    ['nstd$i', 'Н/стд', '40', 'pic=0;1:0;2', 't=s,ch'],
    ['price_base$f', 'Цена без НДС', '70', 'f=0.00', 'e=0:999999:2:N', 't=s,ch'],
    ['0 as price_base_with_nds$f', 'Цена с НДС', '70', 'f=0.00', 'e=0:999999:2:N'],
    ['price_adjusted$f', 'Цена без НДС? со скидками', '70', 'f=0.00' , 't=s'],
    ['price$f', 'Цена с НДС и скидками', '70', 'f=0.00', 't=s'],
    ['nds_rate$f', 'Ставка НДС', '70', 'f=0', 't=s'],
    ['qnt$f', 'Кол-во', '40', 'e=0:5:0:N', 't=s,ch'],
    ['sgp$f', 'С СГП', '40', 'e', 'chb', 't=s,ch'],
    ['disassembled$i', 'В раз'#13#10'боре', '40', 'e', 'chb', 't=s,ch'],
    ['control_assembly$i', 'Контр. сборка', '40', 'e', 'chb', 't=s,ch']
  ];

  LFields := LFields + va2;
  LFields := LFields +
  [
    ['wo_estimate$i', 'Без'#13#10'сметы', '40', 'chb', 'e', 't=s,ch'],
    ['id_kns$i', 'Конструктор', '100;L', 'e=-99999999:99999999', 't=s,ch'],
    ['id_thn$i', 'Технолог', '100;L', 'e=-99999999:99999999', 't=s,ch'],
    ['comm$s', 'Дополнение', '200;w;h', 'e=0:400::N', 't=s,ch'],
    ['0 as sum$f', 'Сумма', '90', 'f=0.00:']
  ];
  FrgItems.Opt.Caption := S.IIf(FIsTemplate, 'Состав шаблона', 'Состав заказа');
  FrgItems.Opt.SetFields(LFields);
  FrgItems.Opt.SetButtons(1, [
    [mbtRefresh, True, 1, 'Обновить данные из справочника изделий'],
    [mbtInsert, True, 1],
    [mbtAdd, True, 1],
    [mbtDelete, True, 1],
    [],
    [mbtCtlPanel],
    [],
    [mbtCtlPanel ,4000],
    []
  ]);
  FrgItems.CreateAddControls('1', cntCheck, 'Показать с нулевым количеством', 'ChbView0', '', 4, yrefC, 190);
  FrgItems.Opt.SetGridOperations('uaid');
  FrgItems.Opt.SetTable('v_order_items');
  o.AlwaysVerifyAllTable:= True;
  O.FieldsNoRepaeted:=['name'];
  FrgItems.EditOptions := o;
  FrgItems.SetInitData([]);
  FrgItems.Prepare;
  pnlOrderInfo.Parent := TWinControl(FrgItems.FindComponent('pnlTopBtnsCtl2'));
  pnlOrderInfo.Color := RGB(255, 255, 220);
  pnlOrderInfo.BevelOuter := bvRaised;
  pnlOrderInfo.BorderWidth := 2;
  pnlOrderInfo.BorderStyle:=bsSingle;
  pnlOrderInfo.Align:=alClient;
  var LFieldsSt := '';
  for i:= 0 to High(LFields) do
    S.ConcatStP(LFieldsSt, Copy(LFields[i][0].AsString, 1, Pos('$', LFields[i][0].AsString) - 1), ', ');
  Q.QLoad('select ' + LFieldsSt + ' from v_order_items where id_order = :id_order$i order by pos', [ID], FOrderItemsOld);
  FrgItems.SetInitData(FOrderItemsOld);
  //установим события грида
  FrgItems.OnButtonClick := FrgItemsButtonClick;
  FrgItems.OnCellButtonClick := FrgItemsCellButtonClick;
  FrgItems.OnGetCellReadOnly := FrgItemsGetCellReadOnly;
  FrgItems.OnSelectedDataChange := FrgItemsSelectedDataChange;
  FrgItems.OnSetSqlParams := FrgItemsOnSetSqlParams;
  FrgItems.OnColumnsUpdateData := FrgItemsColumnsUpdateData;
  FrgItems.OnAddControlChange := FrgItemsAddControlChange;
  FrgItems.OnColumnsGetCellParams := FrgItemsColumnsGetCellParams;
//  FrgItems.OnDbClick := FrgItemsOnDbClick;
  FrgItems.OnVeryfyAndCorrectValues := FrgItemsVeryfyAndCorrect;
  FrgItems.OnCellValueSave := FrgItemsCellValueSave;
  FrgItems.RefreshGrid;
  FrgItems.IsTableCorrect;
  FrgItems.SetControlValue('ChbView0', S.IIf(Mode in [fView, fDelete], 0, 1));
  RecalculateItemsPrices;
  FrgItems.DbGridEh1.DefaultApplyFilter;
  Result := True;
end;

function TFrmOWOrder.PrepareFrgRelatedOrders: Boolean;
begin
  FrgRelatedOrders.Width := 130;
  FrgRelatedOrders.Options := [];
  FrgRelatedOrders.Opt.SetFields([['id$i', '_id', '100'], ['ornum$s', 'Рекламации', '30;w', 'bt=показать паспорт']]);
  FrgRelatedOrders.SetInitData('select ornum from orders where rownum <= 1', []);
  FrgRelatedOrders.DbGridEh1.Options := FrgFiles.DbGridEh1.Options - [dgTitles];
  FrgRelatedOrders.Prepare;
  //FrgRelatedOrders.DbGridEh1.Options := FrgRelatedOrders.DbGridEh1.Options - [dgTitles];
  FrgRelatedOrders.RefreshGrid;
end;

function TFrmOWOrder.PrepareFrgBasis: Boolean;
begin
  FrgBasis.Width := 130;
  FrgBasis.Options := [];
  FrgBasis.Opt.SetFields([
    ['id$i', '_id', '100'],
    ['mode$i', '*', '20', 'pic=1;3;2:1;6;7'],  //изменен - 1, добавлен - 2, удален - 3
    ['name$s', 'Файл', '300;w', 'bt=Просмотреть'],
    ['namenew$s', '_namenew', '100'],
    ['onserver$i', '_onserver', '20']
  ]);
  FrgBasis.DbGridEh1.ReadOnly := True;
  FrgBasis.DbGridEh1.Options := FrgBasis.DbGridEh1.Options - [dgTitles];
  FrgBasis.OnButtonClick := FrgFilesButtonClick;
  FrgBasis.OnCellButtonClick := FrgFilesCellButtonClick;
  FrgBasis.Opt.SetGridOperations('uad');
  FrgBasis.Opt.SetButtons(-3, [[mbtAdd, True], [mbtDelete, True]], 2, nil, 0, True);
  FrgBasis.SetInitData([]);
  FrgBasis.Prepare;
  FrgBasis.SetInitData(GetAddFiles(2));
  FrgBasis.RefreshGrid;
end;

function TFrmOWOrder.PrepareFrgFiles: Boolean;
begin
  FrgFiles.Options := [];
  FrgFiles.Opt.SetFields([
    ['id$i', '_id', '100'],
    ['mode$i', '*', '20', 'pic=1;3;2:1;6;7'],  //изменен - 1, добавлен - 2, удален - 3
    ['name$s', 'Файл', '300;w', 'bt=Просмотреть'],
    ['namenew$s', '_namenew', '100'],
    ['onserver$i', '_onserver', '20']
  ]);
  FrgFiles.DbGridEh1.ReadOnly := True;
  FrgFiles.DbGridEh1.Options := FrgFiles.DbGridEh1.Options - [dgTitles];
  FrgFiles.OnButtonClick := FrgFilesButtonClick;
  FrgFiles.OnCellButtonClick := FrgFilesCellButtonClick;
  FrgFiles.Opt.SetGridOperations('uad');
  FrgFiles.Opt.SetButtons(-3, [[mbtAdd, True], [mbtDelete, True]], 2, nil, 0, True);
  FrgFiles.SetInitData([]);
  FrgFiles.Prepare;
  FrgFiles.SetInitData(GetAddFiles(1));
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
  //ch - отслеживаются изменения

  F.DefineFields := [
    ['id$i'],
    ['id_itm;0'],
    ['sync_with_itm$i'],
    ['year$i'],
    ['prefix$s'],
    ['num$i'],
    ['path$s'],
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
    ['nds_rate$f'],
    ['wholesale$i'],


    ['templatename$s', S.IIFStr(FIsTemplate, 'V=1:400::N')],

    ['id_type2$i', 'V=1:400', 't=ch'],
    ['ornum$s', 't=d,ch'],
    ['or_reference$s','t=td,ch'],
    ['id_reglament$i'],
    ['reglament$s;0', 'V=1:400', 't=t,ch'],
    ['id_organization$i', 'V=1:400', 't=t,ch'],
    ['area$i', 'V=1:100', 't=t,ch'],
    ['project$s', 'V=1:500::td', 't=t,ch'],
    ['id_format$i'],
    ['id_or_format_estimates$i', 'V=1:400', 't=ch'],
    ['managername$s;0', 't=d', #0, User.GetName],
    ['launched_by_name$s;0', 't=d', #0, User.GetName],
    ['id_manager$i', #0, User.GetId],
    ['id_launched_by$i', #0, User.GetId],
    ['complaints$s;0', 't=td,ch'],
    ['comm$s', 'v=0:4000::N', 't=t,ch'],
    ['basis_text$s', 'v=0:4000::N', 't=t,ch'],

    ['id_customer$i'],
    ['id_customer_contact$i'],
    ['id_customer_org$i'],
    ['customer$s;0', 'V=0:400', 't=c,t,ch'],
    ['customerman$s;0', 'V=0:400', 't=c,t,ch'],
    ['customercontact$s;0', 'V=0:400', 't=c,t,ch'],
    ['customerlegal$s;0', 'V=0:400', 't=c,t,ch'],
    ['customerinn$s;0', 'V=0:400::N', 't=c,t,ch'],
    ['cashtype_account$s;0','V=1:400::N', 't=c,t,ch'],
    ['address$s', 'V=1:400', 't=c,t,ch'],
    ['order_number_customer$s', 'V=1:400::N', 't=c,t,ch'],

    ['dt_end$d;0', 't=t'],
    ['dt_beg$d', 't=d,t'],
    ['dt_change$d', 't=d,t'],
    ['dt_start$d', 'v==dedt_dt_beg:=dedt_dt_beg+1000000', 't=t,ch'],
    ['dt_otgr$d', 'v==dedt_dt_start:=dedt_dt_start+1000000', 't=t,ch'],
    ['dt_montage_beg$d', 't=p,t,ch'],
    ['dt_montage_end$d', 't=p,t,ch'],

    ['cost_i$f','V=', 't=d,td',#0],
    ['cost_i_0$f','V=', 't=d,td',#0],
    ['cost_i_wo_nds$f;0;0'],
    ['m_i$f','V=0:100:2', 't=p,td,ch',#0],
    ['d_i$f','V=0:100:2', 't=p,td,ch',#0],
    ['cost_m$f','V=', 't=p,td,d',#0],
    ['cost_m_0$f', 't=p,td,ch','V=0:9999999:2', #0],
    ['m_m$f','V=0:100:2', 't=p,td,ch',#0],
    ['d_m$f','V=0:100:2', 't=p,td,ch',#0],
    ['cost_d$f','V=', 't=d,td',#0],
    ['cost_d_0$f','V=0:9999999:2', 't=td,ch' ,#0],
    ['m_d$f', 'V=0:100:2', 't=p,td,ch',#0],
    ['d_d$f',' V=0:100:2','t=p,td,ch',#0],
    ['cost$f','V=', 't=d,td', #0],
    ['cost_wo_nds$f','V=', 't=d,td' ,#0],
    ['cost_av$f','V=0:9999999:2', 't=td,ch' ,#0]




    {['','V=',#0],
    ['','V=',#0],
    ['','V=',#0],
    ['','V=',#0],
    ['','V=',#0],
    ['','V=',#0],}
      ];
  F.PrepareDefineFieldsAdd;
  (*
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
  Q.QLoad('select * from order_types where posstd is null and (active = 1 or id = :id$i) order by pos', [cmb_id_type2.Value], FOrderTypes);
  Cth.AddToComboBoxEh(cmb_id_type2, FOrderTypes.GetCol('name'), FOrderTypes.GetCol('id'));

  //вид оплаты
  Cth.AddToComboBoxEh(cmb_cashtype_account, ['наличные', 'безнал (нет счета)', 'безнал'], []);

  //организации (производство и активные, являющиесы продавцами)
  Q.QLoad(
    'select name, id, prefix, is_wholesaler, nds_rate, or_cashless, or_cash from ref_sn_organizations where id = -1 ' +
    'union all ' +
    'select name, id, prefix, is_wholesaler, nds_rate, or_cashless, or_cash from ' +
    '(select * from ref_sn_organizations ' +
    'where id > 0 and prefix is not null and is_seller = 1 and (active = 1 or id = :id$i) order by name)',
    [F.GetPropB('id_organization')],
    FOrganizations
  );

  //производственные площадки
  Q.QLoad('select shortname, id, order_prefix from ref_production_areas where active = 1 or id = :id$i order by id', [F.GetPropB('area')], FProdAreas);
  Cth.AddToComboBoxEh(cmb_area, FProdAreas.GetCol('shortname'), FProdAreas.GetCol('id'));

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
  var i := FEstimateFormats.FindFirst('id', 0);
  FEstimateFormats.SetValue(i, 'name', '[Нестандартные изделия]');
  FEstimateFormats.Sort('name');


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

  Result := True;
end;

function TFrmOWOrder.LoadOrder: Boolean;
var
  FieldsSt: string;
  CtrlValues: TVarDynArray;
  i, j: Integer;
begin
  Result := False;
  if Mode <> fAdd then begin
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

procedure TFrmOWOrder.SetOrderTypeOrOrganization(Sender: TObject);
//установим поля, зависящие от типа заказа и от организации
var
  i, ot, org, est: Integer;
  va2: TVarDynArray2;
begin
  if cmb_id_type2.Text = '' then
    cmb_id_type2.ItemIndex := 0;
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
        ((FOrganizations.G(i, 'id') = -1) and ((FOrderTypes.G(ot, 'is_production_order') = 1) or (FOrderTypes.G(ot, 'is_semiproduct_order') = 1)))
        or
        //допустима Ника (есть оплата нал. и отгрузочные)
        ((FOrganizations.G(i, 'or_cash').AsInteger = 1) and ((FOrderTypes.G(ot, 'is_cash_payment') = 1) and (FOrderTypes.G(ot, 'is_shipment_order') = 1)))
        or
        //допустиммы остальные (есть отгруузочные)
        ((FOrganizations.G(i, 'or_cash').AsInteger <> 1) and (FOrganizations.G(i, 'id') <> -1) and (FOrderTypes.G(ot, 'is_shipment_order') = 1))
      then
        va2 := va2 + [[FOrganizations.G(i, 'name'), FOrganizations.G(i, 'id')]];
    end;
    //установим параметры для ссылки на другой заказ
    if (FOrderTypes.G(ot, 'is_reference_required') = 1) then begin
      //ссылка обязательна
      F.SetProps('or_reference', '1:400:T', fvtVer);
      F.SetProps('or_reference', True, fvtDsbl);
    end
    else if (FOrderTypes.G(ot, 'is_reference_allowed') = 1) then begin
      //ссылка допустима
      F.SetProps('or_reference', '0:400:T', fvtVer);
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
  if (Sender = cmb_id_organization) or (LOrganization <> F.GetProp('id_organization').AsInteger) then begin
    GetOrderNumber;
  end;
  LOrganization := F.GetProp('id_organization').AsInteger;
  org := FOrganizations.FindFirst('id', LOrganization);
  //установим список доступных форматов стандартных изделий (они же форматы смет)
  va2 := [];
  if (LOrderType = 0) or ((LOrganization = 0) and not FIsTemplate) then begin

  end;
  var LUsedEstimateFormatFound := False;
  for i := 0 to FEstimateFormats.High do begin
    if
      (LOrganization <> 0)
      and
      ((
      //отгрузочные
      ((LOrganization <> -1) and (FEstimateFormats.G(i, 'type') = STDITEM_TYPE_SHIPMENT))
      or
      //нестандарт
      ((LOrganization <> -1) and (FEstimateFormats.G(i, 'id') = 0) and (FOrderTypes.G(ot, 'is_nonstandard') = 1))
      or
      //производственные
      ((FEstimateFormats.G(i, 'type') = STDITEM_TYPE_PRODUCTION) and (FOrderTypes.G(ot, 'is_production_order') = 1))
      or
      //отгрузочные
      ((FEstimateFormats.G(i, 'type') = STDITEM_TYPE_SEMIPRODUCT) and (FOrderTypes.G(ot, 'is_semiproduct_order') = 1))
      )
      //только нестандартные изделия
      and
      (
      (FOrderTypes.G(ot, 'is_nonstandard_only') <> 1) or (FEstimateFormats.G(i, 'id') = 0)
      )
      )
    then begin
      va2 := va2 + [[FEstimateFormats.G(i, 'name'), FEstimateFormats.G(i, 'id')]];
      if FUsedEstimateFormat = FEstimateFormats.G(i, 'id').AsInteger then
        LUsedEstimateFormatFound := True;
    end;
  end;
  if (not LUsedEstimateFormatFound) and (FrgItems.GetRawCount > 0) and (FUsedEstimateFormat > -1) then begin
    //если формат, по кторому заполнена таблица, не найден в списке доступныых, то добавим его последней позицией, и сделаем ошибочным
    va2 := va2 + [[FEstimateFormats.G(FEstimateFormats.FindFirst('id', FUsedEstimateFormat), 'name'), FUsedEstimateFormat]];
    F.SetProp('id_or_format_estimates', '1000:1001', fvtVer);
  end
  else
    F.SetProp('id_or_format_estimates', '1:400', fvtVer);
  //загрузим список
  Cth.AddToComboBoxEh(cmb_id_or_format_estimates, va2);
  //если таблица заполнена, то установим формат равным формату в талице и заблокируем поле выбора формата сметы
  if (FrgItems.GetRawCount > 0) and (FUsedEstimateFormat > -1) then begin
    //F.SetProp('id_or_format_estimates', False, fvtDsbl);
    LEstimate := FUsedEstimateFormat;
  end;
  //позиция в массиве форматов смет
  est := A.PosInArray(LEstimate, va2, 1);
  //восстановим старое значение, если найдено
  if est = - 1 then begin
    F.SetProp('id_or_format_estimates', null);
    FStdItems.Clear;
  end
  else begin
    F.SetProp('id_or_format_estimates', LEstimate);
  end;
  var LNdsRate := F.GetProp('nds_rate').Asfloat;
  var LMargin := F.GetProp('m_i').Asfloat;
  var LDiscount := F.GetProp('d_i').Asfloat;
  //установми проверку и доступность полей ввода клиента в зависимости от организации
  if (LOrganization = -1) or (org = -1) then begin
    F.SetProps('c', '', fvtVer);
    F.SetProps('c', False, fvtDsbl);
    F.SetProps('p', null, fvtVCurr);
    F.SetProps('p', False, fvtDsbl);
    F.SetProps('cost_m_0;cost_d_0;m_i;d_i;m_m;d_m;m_d;d_d', null, fvtVCurr);
    F.SetProps('cost_m_0;cost_d_0;m_i;d_i;m_m;d_m;m_d;d_d', False, fvtDsbl);
{    F.SetProps('dt_start', True, fvtDsbl);
    F.SetProps('dt_montage_beg;dt_montage_end', '', fvtVer);
    F.SetProps('dt_montage_beg;dt_montage_end;cost_m_0;cost_d_0;m_i;d_i;m_m;d_m;m_d;d_d', null, fvtVCurr);
    F.SetProps('dt_montage_beg;dt_montage_end;cost_m_0;cost_d_0;m_i;d_i;m_m;d_m;m_d;d_d', False, fvtDsbl);}
  end
  else begin
    F.SetProps('c', '1:400::N', fvtVer);
    F.SetProps('customerlegal;customerinn', '0:400::N', fvtVer);
    F.SetProps('c', True, fvtDsbl);
    F.SetPropsFromCustom('p', PROP_NUM_VER_BEG, fvtVer);
    F.SetProps('p', True, fvtDsbl);    F.SetProps('p', True, fvtDsbl);
    F.SetProps('cost_m_0;cost_d_0', True, fvtDsbl);
{    F.SetProps('dt_start', False, fvtDsbl);   //!!!
    F.SetProps('dt_start', F.GetProp('dt_beg'), fvtVCurr);
    F.SetProps('dt_montage_beg', '=dt_otgr:=dt_otgr+1000000', fvtVer);
    F.SetProps('dt_montage_end', '=dt_montage_beg:=dt_montage_beg+1000000', fvtVer);
    F.SetProps('dt_montage_beg;dt_montage_end;cost_m_0;cost_d_0', True, fvtDsbl);
    F.SetProps('dt_montage_beg;dt_montage_end', '', fvtVer); //!!!}
    //все скидки/наценки допускаем только для розничных продавцов
    if FOrganizations.G(org, 'is_wholesaler') = 1 then begin
      F.SetProps('m_i;d_i;m_m;d_m;m_d;d_d', null, fvtVCurr);
      F.SetProps('m_i;d_i;m_m;d_m;m_d;d_d', False, fvtDsbl);
    end
    else begin
      F.SetProps('m_i;d_i;m_m;d_m;m_d;d_d', True, fvtDsbl);
    end;
    //возможные варианты оплаты в зависимости от организаций
    var LPaymentType: TvarDynArray := [];
    if FOrganizations.G(org, 'or_cash') = 1 then
      LPaymentType := LPaymentType + ['наличные'];
    if FOrganizations.G(org, 'or_cashless') = 1 then
      LPaymentType := LPaymentType + ['безнал (нет счета)', 'безнал'];
    //установим список вариантов
    Cth.AddToComboBoxEh(cmb_cashtype_account, LPaymentType, []);
    //очистим, если старый вариант не подходит
    if (cmb_cashtype_account.Text = 'наличные') and not A.InArray(cmb_cashtype_account.Text, LPaymentType) then
      cmb_cashtype_account.Text := '';
    if (cmb_cashtype_account.Text <> 'наличные') and not A.InArray('безнал', LPaymentType) then
      cmb_cashtype_account.Text := '';
  end;
  //установим из организации ставку НДС и признак оптовой продажи
  if org >= 0 then begin
    F.SetProps('wholesale', FOrganizations.G(org, 'is_wholesaler'));
    F.SetProps('nds_rate', FOrganizations.G(org, 'nds_rate'));
  end
  else begin
    F.SetProps('wholesale', 0);
    F.SetProps('nds_rate', 0);
  end;

  SetPermanetFieldProps;

  //сохраним в свойтвах позиции в массивах организации и типа заказа
  FOrderTypeIndes := ot;
  FOrganizationIndex := org;

  if (LNdsRate <> F.GetProp('nds_rate').Asfloat) or (LMargin <> F.GetProp('m_i').Asfloat) or (LDiscount <> F.GetProp('d_i').Asfloat) then
    RecalculateItemsPrices;

  Verify(nil);
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
  IdCustomer := FCustomers[IdCustomer][1];
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
    edt_customerinn.Text := '';
    if cmb_customerlegal.ItemIndex >= 0 then
      edt_customerinn.Text := cmb_customerlegal.DynProps[IntToStr(cmb_customerlegal.ItemIndex)].Value;
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
    SetOrderTypeOrOrganization(Sender);
  end;
  if Sender = cmb_cashtype_account then
    OnCashTypeAccountChange;

  if TControl(Sender).Parent = PHSum then begin
    RecalculateItemsPrices;
    RecalculateSum;
  end;

  OnCustomerControlsChange(Sender);

  CheckDates;
end;

procedure TFrmOWOrder.EditButtonsClick(Sender: TObject; var Handled: Boolean);
begin
//  if (TEditButtonControlEh(Sender).Owner = edt_reglament) then //and (TEditButtonControlEh(Sender).ButtonImages.NormalIndex = 39) then
  if (TEditButtonControlEh(Sender).Owner = cmb_or_reference) then
    ChooseReference;
  if (TEditButtonControlEh(Sender).Owner = edt_reglament) then
    ChooseReglamernt;
end;

procedure TFrmOWOrder.ChooseReference;
//выбор заказа, к которому привязан этот заказ, в диалоге
begin
  Wh.ExecReference(myfrm_J_Orders_SEL, Self, [myfoDialog, myfoModal], 0);
  if Length(Wh.SelectDialogResult) > 0 then
    cmb_or_reference.Text := Wh.SelectDialogResult[1];
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
{  if Fr.GetValue = null then begin
    if Fr.DbGridEh1.FindFieldColumn(Fr.CurrField).KeyList.Count = 0 then
      Fr.SetValue(Fr.CurrField, ' ')
    else
      Fr.SetValue(Fr.CurrField, Fr.DbGridEh1.FindFieldColumn(Fr.CurrField).KeyList[0]);
  end
  else
    Fr.SetValue(Fr.CurrField, null);}
end;

procedure TFrmOWOrder.FrgItemsGetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
  var LFieldName := Fr.GetFieldNameForSender(Sender);
  var LIsStdItem := FrgItems.GetValue('nstd').AsInteger <> 1;
  var LFromSgp := FrgItems.GetValue('sgp').AsInteger = 1;
  var LWoEstimate := FrgItems.GetValue('wo_estimate').AsInteger = 1;
  if LFieldName = 'wo_estimate' then
    ReadOnly := LIsStdItem;
  if (LFieldName[1] = 'r') and (LFieldName[2] in  ['0'..'9']) then
    ReadOnly := LIsStdItem or LFromSgp or LWoEstimate;
  if A.InArray(LFieldName, ['id_kns', 'id_thn']) then
    ReadOnly := LFromSgp or LWoEstimate;
  if A.InArray(LFieldName, ['price_base', 'price_base_with_nds']) then
    ReadOnly := LIsStdItem;
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
    SetButtonsVisibilityAndArrange([], ['edt_templatename1', 'chbIsVerifyed', mbtSave, mbtDelete, mbtApprove, mbtUnApprove, mbtGo])
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
//вызывается в препаре после загрузки данных и родительского метода
begin
  FUsedEstimateFormat := F.GetPropB('id_or_format_estimates').AsIntegerM;
  SetAreasCaptions;
  SetEditButtons;
  F.CopyPropToCustom('', fvtVer, PROP_NUM_VER_BEG);
  SetControlsEditable([], Mode in [fEdit, fCopy, fAdd]);
  SetOrderTypeOrOrganization(nil);
  SetCustomer(True);

  //сгенерируем номер заказа, если это не редактирование (просмотр и удаление отсеиваются в методе)
  if Mode <> fEdit then
    GetOrderNumber;

  //if not (Mode in [fAdd, fDelete, fView]) then
  //  LoadStdItems;

  if FIsTemplate then begin
    chbVisDates.Enabled := False;
    chbVisFinance.Enabled := False;
    chbVisAddInfo.Enabled := False;
  end;

  //буферизация, иначе тормозит ресайз, тк много контролов меняют размер

  SwitchBasisPanel(True);
  Verify(nil);
  SetPermanetFieldProps;
end;

procedure TFrmOWOrder.AfterLoadTables;
//вызывается при инициализации после загрузки данных в таблицы
begin
  SetOrderTypeOrOrganization(nil);
  RecalculateItemsPrices;
  RecalculateSum;
end;

procedure TFrmOWOrder.btnClick(Sender: TObject);
begin
  if TControl(Sender).Tag = mbtSave then begin
    btnOkClick(Sender);
  end
  else if TControl(Sender).Tag = mbtClose then begin
    btnCancelClick(Sender);
  end;
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
  Cth.SetEditButtons(cmb_or_reference, [[-Integer(myebsEllipsisEh), 'Выбрать из списка']]);
  Cth.SetEditButtons(edt_reglament, [[-Integer(myebsEllipsisEh), 'Задать регламент']]);
  Cth.SetEditButtons(edt_order_number_customer, [[-Integer(myebsEllipsisEh), 'Параметры заказа клиента']]);
end;

procedure TFrmOWOrder.ChooseReglamernt;
var
  ReglamentData: TMDIResult;
begin
  if FNewOrderType <> 1 then
    Exit;
  ReglamentData := TFrmOGselOrReglament.Show(
    Self, '', MyFormOptions + [myfoDialog, myfoSizeable, myfoModal], S.IIf(not (Mode in [fView, fDelete]), fEdit, fView), F.GetProp('id_type2'), F.GetProp('ids_order_properties')
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

procedure TFrmOWOrder.FrgItemsAddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
  if TControl(Sender).Name = 'ChbView0' then begin
    FrgItemsDbGridEh1ApplyFilter(Fr.DbGridEh1);
  end;
end;

procedure TFrmOWOrder.FrgItemsColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if FieldName = 'slash' then
    Params.Text := edt_ornum.Text + '_' + S.Right('000' + IntToStr(Fr.GetRawRowCurrent + 1), 3);
  if Fr.GetValueF('qnt') > 0 then
    Params.Background := RGB(220, 255, 220);
  if S.InCommaStr(FieldName, Fr.GetValue('ch').AsString) then
    Params.Background := RGB(255, 255, 100);


{  if FieldName = 'price' then
    Params.Text := Fr.GetValue('price_wo_nds').AsFloat * (1 + F.GetProp('nds_rate').AsFloat / 100);
  if FieldName = 'sum' then
    Params.Text := Fr.GetValue('price_wo_nds').AsFloat * (1 + F.GetProp('nds_rate').AsFloat / 100)  * (1 + F.GetProp('m_i').AsFloat / 100) * (1 - F.GetProp('m_i').AsFloat / 100);}
end;

procedure TFrmOWOrder.FrgItemsColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
//вызывается при ручном вводе данных в грид
begin
  Handled := False;
Exit;
  var LFieldName := Fr.GetFieldNameForSender(Sender);
  var LOldValue: Variant := Fr.GetValue(LFieldName);
  if LOldValue = Value then
    Exit;
  Fr.SetValue(LFieldName, Value);
  if (LFieldName = 'price_base_with_nds') then begin
    Fr.SetValue('price_base', RoundTo(FrgItems.GetValue('price_base_with_nds').AsFloat / (1 + FrgItems.GetValue('nds_rate').AsFloat / 100), -2));
  end;
  if (LFieldName = 'name') or (LFieldName = 'sgp') or (LFieldName = 'wo_estimate') then begin
    CalculateFrgItemsRow(LFieldName);
    RecalculateItemsPrices;
  end;
  if (LFieldName = 'price_base') or (LFieldName = 'price_base_with_nds') or (LFieldName = 'qnt') then begin
    RecalculateItemsPrices;
  end;
  GetFrgItemsRowChanges;
end;

procedure TFrmOWOrder.FrgItemsDbGridEh1ApplyFilter(Sender: TObject);
//фильтрация грида
var
  st: string;
begin
  if FrgItems.GetControlValue('ChbView0') = 0 then
    st := '>0'
  else
    st := '';
  Gh.GetGridColumn(FrgItems.DBGridEh1, 'qnt').STFilter.ExpressionStr := st;
  FrgItems.DBGridEh1.DefaultApplyFilter;
end;

procedure TFrmOWOrder.FrgItemsDbGridEh1Enter(Sender: TObject);
begin
  inherited;
  if Mode in [fAdd, fCopy, fEdit] then
    if FStdItems.Count = 0 then
      LoadStdItems;
end;

procedure TFrmOWOrder.FrgItemsOnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin

end;

procedure TFrmOWOrder.FrgItemsSelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
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
  var LFormat := F.GetProp('id_or_format_estimates').AsIntegerM;
  //если нестандарт, то не нужно устанавливать список
  if LFormat <= 0 then begin
    FrgItems.UpdatePickKeyList('name', [], [], False, False);
    Exit;
  end;
  st := '';
  //поля маршщрутов
  for i := 1 to High(RouteFields) + 1 do
    S.ConcatStP(st, 'nvl(r' + IntToStr(i) + ', 0) as r' + IntToStr(i), ', ');
  //стандартные изделия по данному типу сметы
  Q.QLoad(
    'select id, name, price_wo_nds, wo_estimate, ' + st + ' ' +
    'from v_or_std_items ' +
    'where ' + '(id_or_format_estimates = :id$i) and (id_or_format_estimates <> 0) ' +
    'order by name asc',
    [LFormat],
    FStdItems
  );
  //установим список в гриде
//  FrgItems.Opt.SetPick('itemname', FStdItems.GetCol('name'), FStdItems.GetCol('id'), False, True);
  FrgItems.UpdatePickKeyList('name', FStdItems.GetCol('name'), [], False, True);
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

procedure TFrmOWOrder.RecalculateItemsPrices;
//пересчитаем цены в табличной части и обновим суммы
//сначала применяем к цене без ндс скидку, потом наценку, потом ндс.
begin
  var LTableChanged := False;
  var SumWithNdsWoMarginsOld := F.GetProp('cost_i_0').Asfloat;
  var SumWithNdsWithMarginsOld := F.GetProp('cost_i').Asfloat;
  var SumWoNdsWithMarginsOld := F.GetProp('cost_i_wo_nds').Asfloat;
  var SumWithNdsWoMargins := 0.0;
  var SumWithNdsWithMargins := 0.0;
  var SumWoNdsWithMargins := 0.0;
  var SumWoNdsWoMargins := 0.0;
  for var i := 0 to FrgItems.GetRawCount - 1 do begin
    var LPriceWithNds := RoundTo(FrgItems.GetRawValue('price_base', i).AsFloat * (1 + F.GetProp('nds_rate').AsFloat / 100), -2);
    var LPriceWoNdsWithMargins := RoundTo(FrgItems.GetRawValue('price_base', i).AsFloat  * (1 - F.GetProp('d_i').AsFloat / 100) * (1 + F.GetProp('m_i').AsFloat / 100), -2);
    var LPriceWithNdsWithMargins := RoundTo(LPriceWoNdsWithMargins * (1 + F.GetProp('nds_rate').AsFloat / 100), -2);
    var Sum := LPriceWithNdsWithMargins * FrgItems.GetRawValue('qnt', i).AsFloat;
    SumWoNdsWoMargins := SumWoNdsWoMargins + FrgItems.GetRawValue('price_base', i).AsFloat * FrgItems.GetRawValue('qnt', i).AsFloat;
    SumWithNdsWithMargins := SumWithNdsWithMargins + Sum;
    SumWithNdsWoMargins := SumWithNdsWoMargins + LPriceWithNds * FrgItems.GetRawValue('qnt', i).AsFloat;
    SumWoNdsWithMargins := SumWoNdsWithMargins + LPriceWoNdsWithMargins * FrgItems.GetRawValue('qnt', i).AsFloat;
    if (FrgItems.GetRawValue('nds_rate', i) <> F.GetProp('nds_rate').AsFloat) or (FrgItems.GetRawValue('price_base_with_nds', i) <> LPriceWithNds) or
       (FrgItems.GetRawValue('price', i) <> LPriceWithNdsWithMargins) or (FrgItems.GetRawValue('sum', i) <> Sum) then
    begin
      LTableChanged := True;
      FrgItems.SetRawValue('nds_rate', i, F.GetProp('nds_rate').AsFloat);
      FrgItems.SetRawValue('price_base_with_nds', i, LPriceWithNds);
      FrgItems.SetRawValue('price', i, LPriceWithNdsWithMargins);
      FrgItems.SetRawValue('price_adjusted', i, LPriceWoNdsWithMargins);
      FrgItems.SetRawValue('sum', i, Sum);
    end;
  end;
  if (SumWithNdsWoMarginsOld <> SumWithNdsWoMargins) or (SumWithNdsWithMarginsOld <> SumWithNdsWithMargins) then begin
    F.SetProp('cost_i_0', SumWoNdsWoMargins);
    F.SetProp('cost_i', SumWithNdsWithMargins);
    F.SetProp('cost_i_wo_nds', SumWoNdsWithMargins);
    RecalculateSum;
  end;
  if LTableChanged then begin
    FrgItems.InvalidateGrid;
  end;
end;

procedure TFrmOWOrder.RecalculateSum;
//итоговые суммы в шапке
begin
  //в левой колонке без ндс и без учета наценок/скидок
  //в правой с ндс и наценками/скидками
  F.SetProp('cost_m', RoundTo(F.GetProp('cost_m_0').AsFloat * (1 + F.GetProp('d_m').AsFloat/ 100) * (1 - F.GetProp('m_m').AsFloat / 100), -2));
  F.SetProp('cost_d', RoundTo(F.GetProp('cost_d_0').AsFloat * (1 + F.GetProp('d_d').AsFloat/ 100) * (1 - F.GetProp('m_d').AsFloat / 100), -2));
  var LSumTotal := F.GetProp('cost_i_wo_nds').AsFloat + F.GetProp('cost_m').AsFloat + F.GetProp('cost_d').AsFloat;
  //итоговая без ндс но со скидками
  F.SetProp('cost_wo_nds', LSumTotal);
  F.SetProp('cost_d', RoundTo(F.GetProp('cost_d').AsFloat * (1 + F.GetProp('nds_rate').AsFloat / 100), -2));
  F.SetProp('cost_m', RoundTo(F.GetProp('cost_m').AsFloat * (1 + F.GetProp('nds_rate').AsFloat / 100), -2));
  LSumTotal := F.GetProp('cost_i').AsFloat + F.GetProp('cost_m').AsFloat + F.GetProp('cost_d').AsFloat;
  //итоговая с ндс и учетом всех скидок
  F.SetProp('cost', LSumTotal);
end;

procedure TFrmOWOrder.CalculateFrgItemsRow(const AFieldName: string = '');
var
  i: Integer;
begin
  var LItemNamePos :=  -1;
  LItemNamePos := FStdItems.FindFirst('name', FrgItems.GetValue('name'));
  var LIsStdItem := LItemNamePos >= 0;
  var LFromSgp := FrgItems.GetValue('sgp').AsInteger = 1;
  var LWoEstimate:= FrgItems.GetValue('wo_estimate').AsInteger = 1;

  FrgItems.SetValue('nstd', S.IIf(LIsStdItem, 0, 1));
  if AFieldName = 'name' then
  if LIsStdItem then begin
    FrgItems.SetValue('id_std_item', FStdItems.G(LItemNamePos, 'id'));
    FrgItems.SetValue('wo_estimate', FStdItems.G(LItemNamePos, 'wo_estimate'));
    FrgItems.SetValue('price_base', FStdItems.G(LItemNamePos, 'price_wo_nds'));
  end
  else begin
    FrgItems.SetValue('id_std_item', null);
    FrgItems.SetValue('wo_estimate', null);
    FrgItems.SetValue('price_base', null);
  end;
  if LFromSgp or LWoEstimate then begin
    FrgItems.SetValue('id_kns', -100);
    FrgItems.SetValue('id_thn', -100);
    for i := 1 to  High(RouteFields) + 1 do  begin
      FrgItems.SetValue('r' + IntToStr(i), 0);
    end;
  end
  else if LIsStdItem then begin
    for i := 1 to  High(RouteFields) + 1 do begin
      FrgItems.SetValue('r' + IntToStr(i), FStdItems.G(LItemNamePos, 'r' + IntToStr(i)));
    end;
    if FrgItems.GetValue('id_thn').AsInteger <= 0 then
      FrgItems.SetValue('id_thn', -102);
  end
  else begin
    if FrgItems.GetValue('id_kns').AsInteger <= 0 then
      FrgItems.SetValue('id_kns', -101);
    if FrgItems.GetValue('id_thn').AsInteger <= 0 then
      FrgItems.SetValue('id_thn', -102);
  end;
  FrgItems.InvalidateGrid;
end;

procedure TFrmOWOrder.CheckDates;
//проверка и установка доступности контролорв в блоке дат заказа
//не получается автоматически управлять ошибкой полей, статусы сбрасываются,
//поэтому вручную устанавливаем если нужно статус ошибки для блока!
begin
  //сбросим флаги ошибок
  Cth.SetErrorMarker(dedt_dt_start, False);
  Cth.SetErrorMarker(dedt_dt_otgr, False);
  Cth.SetErrorMarker(dedt_dt_montage_beg, False);
  Cth.SetErrorMarker(dedt_dt_montage_end, False);
  var LOrganization := F.GetProp('id_organization').AsInteger;
  //для шаблона или пустой организации выходим без проверки
  if LOrganization = 0 then
    Exit;
  if FIsTemplate then
    Exit;
  if LOrganization = -1 then begin
    //для производства монтаж недоступен (сбросим значения и зблокируем)
    F.SetProps('dt_start', True, fvtDsbl);
    F.SetProps('dt_montage_beg;dt_montage_end', False, fvtDsbl);
    F.SetProps('dt_montage_beg;dt_montage_end', null, fvtVCurr);
  end
  else begin
    F.SetProps('dt_start', True, fvtDsbl);   //!!!
    F.SetProps('dt_start', F.GetProp('dt_beg'), fvtVCurr);
    F.SetProps('dt_montage_beg;dt_montage_end', True, fvtDsbl);
  end;
  F.SetProps('dt_start;dt_montage_beg;dt_montage_end', '', fvtVer);
  frmpcDates.SetError(False);
  //каждая дата ниже в блоке должна быть не ранее той что идет выше.
  //при этом даты монтажа могту быть не введены обе, а если введены то подчиняются общему правилук
  if (not Cth.DteValueIsDate(dedt_dt_start)) or (dedt_dt_start.Value < dedt_dt_beg.Value) then begin
    Cth.SetErrorMarker(dedt_dt_start, True);
    frmpcDates.SetError(True);
  end
  else if (not Cth.DteValueIsDate(dedt_dt_otgr)) or (dedt_dt_otgr.Value < dedt_dt_start.Value) then begin
    Cth.SetErrorMarker(dedt_dt_otgr, True);
    frmpcDates.SetError(True);
  end
  else if Cth.DteValueIsDate(dedt_dt_montage_beg) and (dedt_dt_montage_beg.Value < dedt_dt_otgr.Value) then begin
    Cth.SetErrorMarker(dedt_dt_montage_beg, True);
    frmpcDates.SetError(True);
  end
  else if Cth.DteValueIsDate(dedt_dt_montage_beg) and (not Cth.DteValueIsDate(dedt_dt_montage_end) or (dedt_dt_montage_end.Value < dedt_dt_montage_beg.Value)) then begin
    Cth.SetErrorMarker(dedt_dt_montage_end, True);
    frmpcDates.SetError(True);
  end
  else if not Cth.DteValueIsDate(dedt_dt_montage_beg) and Cth.DteValueIsDate(dedt_dt_montage_end) then begin
    Cth.SetErrorMarker(dedt_dt_montage_end, True);
    frmpcDates.SetError(True);
  end;
end;

procedure TFrmOWOrder.FrgFilesButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  AddAddFile(Fr, Tag);
end;

procedure TFrmOWOrder.FrgFilesCellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
  ViewAddFile(Fr);
end;

procedure TFrmOWOrder.FrgItemsVeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string);
//проверка ячеек таблицы
//по настрокам - проверяем при каждом вводе всмю таблицу
begin
  Msg := '';
  //не корректируеми ввод! если это вызов при вводе данных для возможной коррекции - выходим.
  //иначе некорректно будут выдаваться сообщения, так как мы проверяем не обязательно текущую ячейку!
  if Mode = dbgvBefore then begin
    Exit;
  end;
  Row := Row - 1;
  var LFieldName := FieldName;
  var LIsStdItem := FrgItems.GetValue('nstd', Row).AsInteger <> 1;
  var LFromSgp := FrgItems.GetValue('sgp', Row).AsInteger = 1;
  var LWoEstimate := FrgItems.GetValue('wo_estimate', Row).AsInteger = 1;
  var LRouteDefined := False;
  Msg := '';
  for var i := 1 to  High(RouteFields) + 1 do
    if FrgItems.GetValueI('r' + IntToStr(i), Row) = 1 then begin
      LRouteDefined := True;
      Break;
    end;
  if (LFieldName[1] = 'r') and (LFieldName[2] in  ['0'..'9']) and not LWoEstimate and not LFromSgp then begin
    Msg := S.IIFStr(not LRouteDefined, 'Не задан маршрут');
  end
  else if (LFieldName[1] = 'r') and (LFieldName[2] in ['0'..'9']) and (LWoEstimate or LFromSgp) then begin
    Msg := S.IIFStr(LRouteDefined, 'Маршрут недопустим при пометке "С СГП" или "Без сметы"');
  end;
  {if (LFieldName = 'id_thn') and LIsStdItem then begin
    if FrgItems.GetValue('id_thn').AsInteger <> - 100 then
      Msg := 'Технолдог для стандартного изделия не может быть задан';
  end;}
  if (LFieldName = 'id_kns') and (LFromSgp or LWoEstimate) then begin
    if FrgItems.GetValue('id_kns', Row).AsInteger <> - 100 then
      Msg := 'Конструктор не может быть задан, если установлена пометка "С СГП" или "Без сметы"';
  end;
  if (LFieldName = 'id_thn') and  (LFromSgp or LWoEstimate) then begin
    if FrgItems.GetValue('id_thn', Row).AsInteger <> - 100 then
      Msg := 'Технолог не может быть задан, если установлена пометка "С СГП" или "Без сметы"';
  end;
  if (LFieldName = 'id_kns') and  not LIsStdItem then begin
    if (FrgItems.GetValue('id_kns', Row).AsIntegerM = -1 ) or (FrgItems.GetValue('id_kns', Row).AsIntegerM = -100) then
      Msg := 'Конструктор должен быть задан для нестандартного изделия';
  end;
  if (LFieldName = 'id_thn') and not LIsStdItem then begin
    if (FrgItems.GetValue('id_thn', Row).AsIntegerM = -1 ) or (FrgItems.GetValue('id_thn', Row).AsIntegerM = -100) then
      Msg := 'Технолог должен быть задан для нестандартного изделия';
  end;
//  FrgItems.SetValue('status', Row, True, S.IIf(Msg <> '', 'e', S.IIf(FrgItems.GetValue('qnt', Row).AsInteger = 0, '0', '')));
end;


procedure TFrmOWOrder.FrgItemsRowVerify(Row: Integer);
begin
  var LErrMsgs: TVarDynArray := [];
  for var LFld := 0 to FrgItems.MemTableEh1.FieldCount - 1 do begin
  var LFieldName := FrgItems.MemTableEh1.Fields[LFld].FieldName;
  //Row := Row - 1;
  //if Row = -1 then
  //  Row := FrgItems.GetRawRowById() - 1;
  var LIsStdItem := FrgItems.GetValue('nstd', Row).AsInteger <> 1;
  var LFromSgp := FrgItems.GetValue('sgp', Row).AsInteger = 1;
  var LWoEstimate := FrgItems.GetValue('wo_estimate', Row).AsInteger = 1;
  var LRouteDefined := False;
  for var i := 1 to  High(RouteFields) + 1 do
    if FrgItems.GetValue('r' + IntToStr(i), Row) = 1 then begin
      LRouteDefined := True;
      Break;
    end;
  var Msg :=  '';
  if (LFieldName[1] = 'r') and (LFieldName[2] in  ['0'..'9']) and not LWoEstimate and not LFromSgp then begin
    Msg := S.IIFStr(not LRouteDefined, 'Не задан маршрут');
  end
  else if (LFieldName[1] = 'r') and (LFieldName[2] in ['0'..'9']) and (LWoEstimate or LFromSgp) then begin
    Msg := S.IIFStr(LRouteDefined, 'Маршрут недопустим при пометке "С СГП" или "Без сметы"');
  end;
  {if (LFieldName = 'id_thn') and LIsStdItem then begin
    if FrgItems.GetValue('id_thn').AsInteger <> - 100 then
      Msg := 'Технолдог для стандартного изделия не может быть задан';
  end;}
  if (LFieldName = 'id_thn') and  (LFromSgp or LWoEstimate) then begin
    if FrgItems.GetValue('id_thn', Row).AsInteger <> - 100 then
      Msg := 'Технолог не может быть задан, если установлена пометка "С СГП" или "Без сметы"';
  end;
  if (LFieldName = 'id_thn') and (LFromSgp or LWoEstimate) then begin
    if FrgItems.GetValue('id_kns', Row).AsInteger <> - 100 then
      Msg := 'Конструктор не может быть задан, если установлена пометка "С СГП" или "Без сметы"';
  end;
  if (LFieldName = 'должен') and  not LIsStdItem then begin
    if (FrgItems.GetValue('id_kns', Row).AsIntegerM = -1 ) or (FrgItems.GetValue('id_kns', Row).AsIntegerM = -100) then
      Msg := 'Конструктор должен быть задан для нестандартного изделия';
  end;
  if (LFieldName = 'id_thn') and not LIsStdItem then begin
    if (FrgItems.GetValue('id_thn', Row).AsIntegerM = -1 ) or (FrgItems.GetValue('id_thn', Row).AsIntegerM = -100) then
      Msg := 'Технолог должен быть задан для нестандартного изделия';
  end;
    if not A.InArray(Msg, LErrMsgs) then
      LErrMsgs := LErrMsgs + [Msg];
  end;
  FrgItems.SetValue('status', Row, True, S.IIf(LErrMsgs.Count <> 0, 'e', S.IIf(FrgItems.GetValue('qnt', Row).AsInteger = 0, '0', '')));
end;

function TFrmOWOrder.GetAddFiles(AMode: Integer): TNamedArr;
//получим список файлов - внешних документов, уже загруженныых в папку заказа
var
  PathTofioles: string;
  sa: TStringDynArray;
begin
  Result.Create(['id', 'name', 'mode', 'namenew', 'onserver']);
  if FIsTemplate or not (Mode in [fEdit, fDelete, fView]) then
    Exit;
  PathTofioles := GetPathToOrders + '\' + F.GetProp('path').AsString + '\' + S.IIf(AMode = 1, 'Внешние документы', 'Основание');
  if not DirectoryExists(PathTofioles) then
    Exit;
  sa := TDirectory.GetFiles(PathTofioles, '*.*', TSearchOption.soTopDirectoryOnly);
  for var FileName in sa do begin
    Result.AddRow([1, ExtractFileName(FileName), 0, '', 1]);
  end;
end;

function TFrmOWOrder.GetPathToOrders: string;
//получим путь к файлам заказа на диске
begin
  Result := Module.GetPath_Order(IntToStr(YearOf(F.GetProp('dt_beg'))), F.GetProp('in_archive'));
end;

function TFrmOWOrder.Save: Boolean;
//сохранение данных
var
  ChildHandled: Boolean;
  i, res: Integer;
  CtrlValues2: TVarDynArray;
  FieldsSave2: string;
  UseTransaction: Boolean;
begin
  if MyQuestionMessage('Сохранить заказ?') <> mrYes then begin
    Result := true;
    Exit;//!!!
  end;
  Result := False;
  //сгенерируем номер заказа
  var LOrNum := F.GetProp('ornum').AsString;
  GetOrderNumber;
  //получим наименование папки заказа
  GetOrderPath;
  //прочие поля
  F.SetProp('id_format', FEstimateFormats.G(FEstimateFormats.FindFirst('id', F.GetProp('id_or_format_estimates')), 'id_format'));
  FieldsSave2 := '';
  CtrlValues2 := [];
  //получим поля и их значения, по тем для которых указано сохранение
  for i := 0 to F.Count - 1 do
    if F.GetProp(i, fvtFNameS) <> '' then begin
      S.ConcatStP(FieldsSave2, F.GetProp(i, fvtFNameS), ';');
      CtrlValues2 := CtrlValues2 + [S.NullIfEmpty(F.GetProp(i, fvtVCurr))];
    end;
  //сохраняем заголовочную часть
  Q.QBeginTrans(True);
  SaveCustomer;
  res := Q.QSave(Q.QFModeToIUD(Mode), 'orders', '', FieldsSave2, CtrlValues2);
  //получим айди заказа в случае его создания
  if not (Mode in [fEdit, fDelete]) then
    ID := res;
  //сохраним табличную часть
  SaveOrderItems;
  //фиксиоруем транзакцию
  Result := Q.QCommitTrans;
  //предупреждение об изменении номера заказа
  if Result and not FIsTemplate and (Mode in [fAdd, fCopy]) and (LOrNum <> F.GetProp('ornum')) then
    MyInfoMessage('Внимание!'#13#10'Номер заказа был изменен с ' + LOrNum + ' на ' + F.GetProp('ornum'), 1);
end;

procedure TFrmOWOrder.SaveCustomer;
//сохраним данные покупателя
//установим поля для сохранения в основной таблице из результатов хранимой процедуры
var
  LCustomer: TVarDynArray;
begin
  if Mode = fDelete then
    Exit;
  if Trim(cmb_customer.Text)  = '' then begin
    LCustomer := [null, null, null, null, null, null, null, null];
    F.SetProps('id_customer;id_customer_contact;id_customer_org', null, fvtVCurr);
  end
  else begin
    LCustomer := Q.QCallStoredProc('p_add_customer', '1;2;3;4;5;id1$io;id2$io;id3$io', [cmb_customer.Text, cmb_customerman.Text, edt_customercontact.Text, cmb_customerlegal.Text, edt_customerinn.Text, -1, -1, -1]);
    if Length(LCustomer) = 0 then
      Exit;
    F.SetProp('id_customer', LCustomer[5], fvtVCurr);
    F.SetProp('id_customer_contact', LCustomer[6], fvtVCurr);
    F.SetProp('id_customer_org', LCustomer[7], fvtVCurr);
  end;
end;

procedure TFrmOWOrder.GetOrderNumber;
//получим номер для создаваемого заказа, исходя из выбранной организации и текущей даты
begin
  if FIsTemplate or (Mode in [fView, fDelete]) then
    Exit;
  if F.GetProp('id_organization').AsInteger = 0 then begin
    F.SetProp('ornum', '');
    Exit;
  end;
  var LOrNum := F.GetPropB('ornum').AsString;
  //получим следующий доступный для заказа по этой организации номер, если только это не редактирование и организация не изменилась
  if not ((Mode = fEdit) and (F.GetProp('id_organization').AsInteger = F.GetPropB('id_organization').AsInteger)) then
    LOrNum := Q.QLoadValue('select f_order_getnewnum(:dt$d, :id_org$i) from dual', [Date, Cth.GetControlValue(cmb_id_organization)]).AsString;
  F.SetProp('ornum', LOrNum);
  F.SetProp('year', YearOf(Date));
  F.SetProp('prefix', Copy(LOrNum, 1, Length(LOrNum) - 6));
  F.SetProp('num', Copy(LOrNum, Length(LOrNum) - 3, 4));
end;

procedure TFrmOWOrder.Verify(Sender: TObject; onInput: Boolean = False);
begin
  inherited;
//  Cth.SetButtonsAndPopupMenuCaptionEnabled(FPanelsBtn, mbtOk, AName, not HasError, '');
  Cth.SetButtonState(Self, mbtSave, null, not HasError, True);
  Cth.SetButtonState(Self, mbtApprove, null, not HasError, True);
end;

function TFrmOWOrder.SaveOrderItems: Boolean;
//сохранение в бд табличной части заказа
var
  Frg: TFrDBGridEh;
  i, j: Integer;
  LId: Variant;
  IsRowChanged: Boolean;
  ExcludedFields: TVarDynArray;
  Fields, FieldNames, NewValues: TVarDynArray;
  OrderItems: TNamedArr;
  PosOld: Integer;
  IsNameChanged: Boolean;
begin
  if Mode in [fView, fDelete] then
    Exit;
  //удалим строки, которые были удалены из таблицы с помощью пользовательского интерфейса
  if Length(FrgItems.EditData.IdsDeleted) > 0 then
    Q.QExecSql('delete from order_items where id in (' + A.Implode(FrgItems.EditData.IdsDeleted, ',') + ')', []);
  //посля для сохранения (с иден тификатором типа), они же используются для проверки изменений (только наименование проверяется дополнительно, сюдла не входит)
  Fields := FrgItems.GetFieldNamesEx('s', True);
  //поля доля сохранения, только наименования
  FieldNames := FrgItems.GetFieldNamesEx('s', False);
  //получим во временную структуру данные из таблицы (не отфильтрованные)
  OrderItems := FrgItems.ExportToNa('', False);
  //прохорд по данным
  for i := 0 to OrderItems.High do begin
    LId := OrderItems.G(i, 'id');
    //установим позицию (при отображении она показывается динамически)
    OrderItems.SetValue(i, 'pos', i + 1);
    //установим приззнак стандарта
    OrderItems.SetValue(i, 'std', S.IIf(FrgItems.GetRawValueI('nstd', i) = 1, 0, 1));
    NewValues := [];
    //признак изменения строки (если добавлена - автоматом ставим как измененную)
    IsRowChanged := LId >= MY_IDS_INSERTED_MIN;
    //признак изменения наименования в этой строке (важно для нестандартных)
    IsNameChanged := False;
    if not IsRowChanged then begin
      PosOld := FOrderItemsOld.FindFirst('id', LId);
      //пройдем по всем поолям, сравним нцужные
      for j := 0 to OrderItems.FieldsCount - 1 do begin
        var FieldName := OrderItems.F[j];
        if not A.InArray(FieldName, FieldNames) then
          Continue;
        if OrderItems.GetValueI(i, j) <> FOrderItemsOld.GetValueI(PosOld, j) then begin
          IsRowChanged := True;
        end;
        //значения для смохранения
        NewValues := NewValues + [OrderItems.GetValueI(i, j)];
      end;
    end;
    //признак, что надо создавать запись для нестандартного изделия (или получать айди если такое ужен существует)
    IsNameChanged := (OrderItems.GetValue(i, 'name') <> FOrderItemsOld.GetValue(PosOld, 'name')) and (OrderItems.GetValue(i, 'nstd') = 1);
    if not (IsRowChanged or IsNameChanged) then
      Continue;
    if IsNameChanged then begin
      //сорздадим (или получим существующую) запись для нестандратного изделия в or_std_items
      var LNewOrStdItem: TVarDynArray := Q.QCallStoredProc('p_CreateOrStdItem_Nstd', 'name$s;newid$io', [OrderItems.GetValue(i, 'name'), -1]);
      OrderItems.SetValue(i, 'id_std_item', LNewOrStdItem[1]);
    end;
    //сохраним строку в бд
    Q.QSave(S.IIf(LId >= MY_IDS_INSERTED_MIN, 'i', 'u'), 'order_items', '', Fields.Implode(';') + ';id_order$i', NewValues + [ID]);
  end;
end;

procedure TFrmOWOrder.ViewAddFile(AFrg: TFrDBGridEh);
//просмотр файла из внешних документов
begin
  //просмотр
  if AFrg.GetRawCount = 0 then
    Exit;
  //ищем по новому пути файла (он будет задан если файл был добавлен в этот раз), если он пут то ищем в папке заказа
  var st := AFrg.GetValueS('namenew');
  if st = '' then
    st := GetPathToOrders + '\' + F.GetProp('path') + S.IIf(AFrg = Frgfiles, '\Внешние документы\', 'Основание\') + AFrg.GetValueS('name');
  Sys.OpenFileOrDirectory(ExtractFilePath(st), 'Файл не найден!', ExtractFileName(st));
end;

procedure TFrmOWOrder.AddAddFile(AFrg: TFrDBGridEh; ATag: Integer);
//добавить/обновить/удалить файл из внешних документов
begin
  if Tag = mbtView then begin
    ViewAddFile(AFrg);
  end
  else if ATag = mbtDelete then begin
    //удаление
    if AFrg.GetCount = 0 then
      Exit;
    //если файл уже на сервере, то спросим, и пометим как удаленный
    if AFrg.GetValueI('onserver') = 1 then begin
      if MyQuestionMessage('Удалить этот файл?') <> mrYes then
        Exit;
      AFrg.SetValue('mode', 3);
    end
    //если файл еще не на сервере, то просто удалим строку
    else
      AFrg.DeleteRow;
  end
  else if ATag = mbtAdd then begin
    //добавление файла
    //диалог выбора, можно несколько
    MyData.OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist];
    MyData.OpenDialog1.Filter := '';
    //вышли по отмене в диалге
    if not MyData.OpenDialog1.Execute then
      Exit;
    //пройдем по выбранным файлам
    for var FileName in MyData.OpenDialog1.Files do begin
      var FileNamefound := False;
      //пройдем по строкам грида
      for var i := 0 to AFrg.GetRawCount - 1 do begin
        if AFrg.GetRawValueS('name', i) = ExtractFileName(FileName) then begin
          //если найден в гриде по имени только файла
          AFrg.SetRawValue('namenew', i, FileName);
          //если был на сервере то проставим что обновлен
          //а если не был и был добавлен ранее, то останется Добавлен, но будет заменен полный путь
          if AFrg.GetRawValueI('onserver', i) = 1 then
            AFrg.SetRawValue('mode', i, 1);
          FileNamefound := True;
          Break;
        end;
      end;
      if not FileNamefound then begin
        //не найден по короткому имени файла в гриде - добавим
        AFrg.AddRow(True);
        AFrg.SetRawValue('name', AFrg.GetCount -1, ExtractFileName(FileName));
        AFrg.SetRawValue('namenew', AFrg.GetCount -1, FileName);
        AFrg.SetRawValue('mode', AFrg.GetCount -1, 2);
      end;
    end;
  end;
end;

procedure TFrmOWOrder.AfterLoadOrder;
//вызывается после загрузки полей из основной таблицы, но перед загрузкой комбобоксов и родительским prepare
begin
  //при копировании установим поля в начальное значение, так как они были загружены из исходдного паспорта
  //достаточно установить fvtVBeg
  if Mode in [fCopy, fAdd] then begin
    F.SetProp('id_manager', User.GetId, fvtVBeg);
    //F.SetProp('id_manager', User.GetId);
    F.SetProp('managername', User.GetName, fvtVBeg);
    //F.SetProp('managername', User.GetName);
    F.SetProp('id_launched_by', User.GetId, fvtVBeg);
    //F.SetProp('id_launched_by', User.GetId);
    F.SetProp('launched_by_name', User.GetName, fvtVBeg);
    //F.SetProp('launched_by', User.GetName);
    F.SetProp('launched_by_name', User.GetName, fvtVBeg);
    F.SetProps('dt_end;dt_otgr;dt_montage_beg;dt_montage_end;dt_start;dt_change', null, fvtVBeg);
    F.SetProp('dt_beg', Date, fvtVBeg);
  end;
end;

procedure TFrmOWOrder.FrgItemsCellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
begin
  var LFieldName := FieldName;
  var LOldValue: Variant := Fr.GetValue(LFieldName);
  Fr.SetValue(LFieldName, Value);
  if (LFieldName = 'price_base_with_nds') then begin
    Fr.SetValue('price_base', RoundTo(FrgItems.GetValue('price_base_with_nds').AsFloat / (1 + FrgItems.GetValue('nds_rate').AsFloat / 100), -2));
  end;
  if (LFieldName = 'name') or (LFieldName = 'sgp') or (LFieldName = 'wo_estimate') then begin
    CalculateFrgItemsRow(LFieldName);
    RecalculateItemsPrices;
  end;
  if (LFieldName = 'price_base') or (LFieldName = 'price_base_with_nds') or (LFieldName = 'qnt') then begin
    RecalculateItemsPrices;
  end;
  GetFrgItemsRowChanges;
  Fr.IsTableCorrect;
end;

procedure TFrmOWOrder.GetOrderPath;
//получим наименование каталога заказа
begin
  var LArea := FProdAreas.FindFirst('id', F.GetProp('area'));
  F.SetProp('path',
    FProdAreas.G(LArea, 'order_prefix') +
    F.GetProp('ornum') + ' ' +
    S.CorrectFileName(Trim(S.IIfV(cmb_customer.Text = '', 'Производство', cmb_customer.Text)) + ' ' + Trim(cmb_project.Text))
  );
end;

function TFrmOWOrder.SetTaskForServer: Boolean;
//создадим задачу для серверного процесса
var
  st, FilesToCopy, FilesToDelete, BasisToCopy, BasisToDelete, TaskDir, Slashes, Addr, Subj, PspName, PspNameOld: string;
  i: Integer;
begin
  //SetOrderSaveStatusText('Передача данных на сервер');
  Result := True;
  if FIsTemplate then
    Exit;
  Result := False;
  try
    Slashes := '';
    FilesToCopy := '';
    FilesToDelete := '';
    if Mode <> fDelete then begin
      //список слешей для создания каталогов, в формате 001, 005...
      //создаем только если колво не 0 и не с СГП,
      for i := 0 to FrgItems.GetRawCount - 1 do
        if (FrgItems.GetRawValueF('qnt', i) <> 0) and (FrgItems.GetRawValueI('sgp', i) <> 1) then
          S.ConcatStP(Slashes, S.Right('0000' + IntToStr(i + 1), 3) + ' ' + S.CorrectFileName(S.IIFStr(FrgItems.GetRawValueS('prefix', i) <> '', FrgItems.GetRawValueS('prefix', i) + '_', '') + Trim(FrgItems.GetRawValueS('name', i))), #13#10);
      //получим поля файлов внешних документов для копипрования на сервер
      for i := 0 to FrgFiles.GetRawCount - 1 do begin
        if FrgItems.GetRawValueI('mode', i) = 3 then
          S.ConcatStP(FilesToDelete, FrgItems.GetRawValueS('name', i), #13#10)
        else if FrgItems.GetRawValueI('mode', i) <> 0 then
          S.ConcatStP(FilesToCopy, FrgItems.GetRawValueS('name', i), #13#10);
      end;
      //получим поля файлов основания для копипрования на сервер
      for i := 0 to FrgBasis.GetRawCount - 1 do begin
        if FrgBasis.GetRawValueI('mode', i) = 3 then
          S.ConcatStP(BasisToDelete, FrgBasis.GetRawValueS('name', i), #13#10)
        else if FrgBasis.GetRawValueI('mode', i) <> 0 then
          S.ConcatStP(BasisToCopy, FrgBasis.GetRawValueS('name', i), #13#10);
      end;
    end;
    Addr := Tasks.GetMailingAddr(TASK_MAILING_ORDERS);
    var LOrderPath := F.GetProp('poath').AsString;
    if Mode = fDelete then begin
      Subj := 'Удален заказ ' + LOrderPath;
      if MyQuestionMessage('Удалить папку заказа на диске со всем содержимым?') = mrYes then
        TaskDir := Tasks.CreateTaskRoot(mytskopDeleteFromArchive, [['directory', LOrderPath], ['in_archive', F.GetProp('in_archive')], ['year', F.GetProp('year')], ['to', Addr], ['subject', Subj], ['body', Subj]], False, False)
      else
        TaskDir := Tasks.CreateTaskRoot(mytskopmail, [['to', Addr], ['subject', Subj], ['body', Subj]], False, False);
    end
    else begin
      if Mode = fEdit then
        Subj := 'Изменен заказ'
      else
        Subj := 'Создан заказ';
      Subj := Orders.GetSubject(Subj, '', ID, null);
      if Mode = fEdit then begin
        st := S.NSt(Q.QLoadValue('select order_prefix from ref_production_areas where id = :id$i', [F.GetPropB('area')]));
        PspNameOld := F.GetPropB('path') + '.xlsx';
        Delete(PspNameOld, 1, length(st));
      end
      else
        PspNameOld := '';
      st := S.NSt(Q.QLoadValue('select order_prefix from ref_production_areas where id = :id$i', [F.GetProp('area')]));
      PspName := LOrderPath + '.xlsx';
      Delete(PspName, 1, length(st));
      //создадим таскдир
      TaskDir := Tasks.CreateTaskRoot(mytskopToPassportChange, [
        ['directory', LOrderPath],
        ['old-directory', F.GetPropB('path').AsString],
        ['in_archive', F.GetPropB('in_archive').AsString],
        ['year', YearOf(dedt_dt_beg.Value)],
        ['passport', PspName],
        ['old-passport', PspNameOld],
        ['subject', Subj],
        ['to', Addr],
        ['body', ''],//DifferencesText],
        ['files-to-send', PspName],
        ['files-to-copy', FilesToCopy],
        ['files-to-delete', FilesToDelete],
        ['slashes', Slashes]
        ],
        False, False
      );
      //скопируем паспорт заказа из временного файла в каталог задачи
      CopyFile(pWideChar(Sys.GetWinTemp + '\' + LOrderPath + '.xlsx'), pWideChar(Module.GetPath_Tasks + '\' + TaskDir + '\Files\' + PspName), True);
      //удалим временный файл паспорта
      DeleteFile(Sys.GetWinTemp + '\' + LOrderPath + '.xlsx');
      //скопируем в каталог задачи файлы, которые были прикреплены в качестве внешних документов
      for i := 0 to FrgFiles.GetRawCount - 1 do begin
        if FrgItems.GetRawValueI('mode',i) in [1, 2] then
          if FileExists(FrgItems.GetRawValueS('namenew', i)) then
            CopyFile(pWideChar(FrgItems.GetRawValueS('namenew', i)), pWideChar(Module.GetPath_Tasks + '\' + TaskDir + '\Files\' + FrgItems.GetRawValueS('name',i)), True);
      end;
      for i := 0 to FrgFiles.GetRawCount - 1 do begin
        if FrgItems.GetRawValueI('mode',i) in [1, 2] then
          if FileExists(FrgItems.GetRawValueS('namenew', i)) then
            CopyFile(pWideChar(FrgItems.GetRawValueS('namenew', i)), pWideChar(Module.GetPath_Tasks + '\' + TaskDir + '\Files\' + FrgItems.GetRawValueS('name',i)), True);
      end;
    end;
    //отправим задачу на выполнение
    Tasks.FinalizeTaskDir(Module.GetPath_Tasks + '\' + TaskDir);
    Result := True;
  except
  end;
end;

procedure TFrmOWOrder.GetFrgItemsRowChanges;
//получим список измененных полей (только те что были загружены, а не расчетных), и сохраним его в поле 'chg' через запятую
//вызывается при изменении значения вручную, потому только при ручном редактировании таблице, притом если было изменение значения
begin
  //проставлять изменения нам нужно только в режиме редактирования
  var LRecNo := FrgItems.RecNo;
  var LChgSt := '';
  if not (Mode in [fEdit]) then
    Exit;
  if FrgItems.GetValue('id') >= MY_IDS_INSERTED_MIN then begin
    //для добавленных строк будет поле Slash признаком добавления
    LChgSt := 'slash';
  end
  else begin
    var LFields: TVarDynArray := FrgItems.GetFieldNamesEx('ch', False);
    var r := FOrderItemsOld.FindFirst('id', FrgItems.GetValue('id'));
    for var i := 0 to High(LFields) do
      if FOrderItemsOld.G(r, LFields[i]).AsString <> FrgItems.GetValueS(LFields[i]) then
        S.ConcatStP(LChgSt, LFields[i], ',');
  end;
  FrgItems.SetValue('ch', LChgSt);
end;


end.







procedure TDlg_Order.CorrectRowIfNameChanged(DisableOnly: Boolean = False);
//проверяем, является ли изделие в поле наименование стандартным - есть ли в списке, и также дествия зависят от галки СГП
//в зависимости от этого или только блокирем изменение зависимых ячеек (это при переходе по записям в мемтейбл),
//либо корректируем еще и их значения (при вызове при изменении значения вручную, и при загрузке таблицы в режиме копирования заказа)
var
  NoErr: Boolean;
  val: Variant;
  fn: string;
  dt1: TDateTime;
  st, fst: string;
  rn: Integer;
  i, j: Integer;
  b, IsStd, FromSgp, WoEstimate: Boolean;
  RecNo: Integer;
begin
  //для названия, проверим есть ли в списке стандартных
  for i := 0 to High(StdItems) do
    if MemTableEh1.FieldByName('name').AsString = StdItems[i][1] then
      Break;
  IsStd := i <= High(StdItems);
  FromSgp := MemTableEh1.FieldByName('sgp').Value = 1;
  WoEstimate := MemTableEh1.FieldByName('wo_estimate').Value = 1;
  //IsStd and (StdItems[i][2] = 1);
{  if IsStd then begin
    LockStdFormat;
  end;}
  //заблокирем изменение зависимых
//  Gh.GetGridColumn(DBGridEh1, 'kns').ReadOnly := IsStd;
//ch 2024-08-26 - конструктор допустим для стандартных изделий, но по-прежнему недопустим при получении с сгп
  Gh.GetGridColumn(DBGridEh1, 'kns').ReadOnly := FromSgp or WoEstimate;
  Gh.GetGridColumn(DBGridEh1, 'thn').ReadOnly := FromSgp or WoEstimate;
  Gh.GetGridColumn(DBGridEh1, 'resale').ReadOnly := True; //IsStd;
  Gh.GetGridColumn(DBGridEh1, 'price_pp').ReadOnly := MemTableEh1.FieldByName('resale').Value = 1;
  Gh.GetGridColumn(DBGridEh1, 'wo_estimate').ReadOnly := IsStd or NoChangeItems;
  for j := 1 to High(RouteFields) + 1 do begin
    Gh.GetGridColumn(DBGridEh1, 'r' + IntToStr(j)).ReadOnly := IsStd or FromSgp or WoEstimate;
  end;
  //выход, если не надо менть значения
  if DisableOnly then Exit;
  //коррекция зависимых значений
  //StdItems  адйи, имя, null, 9 участков производства, доп.компл, цена, цена перепродажи
  if not IsStd then MemTableEh1.FieldByName('id_std').Value := null;
  MemTableEh1.FieldByName('std').Value := S.IIf(IsStd, 1, 0);
  MemTableEh1.FieldByName('nstd').Value := S.IIf(IsStd, 0, 1);
  //MemTableEh1.FieldByName('sgp').Value:= S.IIf(FromSgp, 1, 0);
  if IsStd then begin
    MemTableEh1.FieldByName('id_std').Value := StdItems[i][0];
    for j := 1 to  High(RouteFields) + 1 do begin
      MemTableEh1.FieldByName('r' + IntToStr(j)).Value := S.IIf(StdItems[i][2 + j] = 1, 1, 0);
    end;
    MemTableEh1.FieldByName('resale').Value := S.IIf(StdItems[i][2 + 9 + 1] = 1, 1, 0);
    MemTableEh1.FieldByName('price').Value := StdItems[i][2 + 9 + 1 + 1];
    MemTableEh1.FieldByName('price_pp').Value := StdItems[i][2 + 9 + 1 + 2];
    MemTableEh1.FieldByName('wo_estimate').Value := StdItems[i][2 + 9 + 1 + 2 + 1];
  end;
  //дублируем здесь зависимости от галки Без сметы
  WoEstimate := MemTableEh1.FieldByName('wo_estimate').Value = 1;
  Gh.GetGridColumn(DBGridEh1, 'kns').ReadOnly := FromSgp or WoEstimate;
  Gh.GetGridColumn(DBGridEh1, 'thn').ReadOnly := FromSgp or WoEstimate;
  if (FromSgp) or WoEstimate or (MemTableEh1.FieldByName('resale').Value = 1) then begin
    MemTableEh1.FieldByName('kns').Value := -100;
    MemTableEh1.FieldByName('thn').Value := -100;
    for j := 1 to  High(RouteFields) + 1 do begin
      MemTableEh1.FieldByName('r' + IntToStr(j)).Value := 0;
    end;
  end
  else if IsStd then begin
    //MemTableEh1.FieldByName('kns').Value := -100;   //2024-08-26 убираем проверку - для стандартного изделия может быть выбран конструктор
    if S.NNum(MemTableEh1.FieldByName('thn').AsVariant) <= 0 then
      MemTableEh1.FieldByName('thn').Value := -102;
  end
  else begin
    if S.NNum(MemTableEh1.FieldByName('kns').AsVariant) <= 0 then
      MemTableEh1.FieldByName('kns').Value := -101;
    if S.NNum(MemTableEh1.FieldByName('thn').AsVariant) <= 0 then
      MemTableEh1.FieldByName('thn').Value := -102;
  end;
  if MemTableEh1.FieldByName('resale').Value = 1 then begin
    MemTableEh1.FieldByName('price_pp').Value := MemTableEh1.FieldByName('price').Value;
  end;

end;

function TDlg_Order.SetTask: Boolean;
//создадим задачу для серверного процесса
//в случае удаления делаем сейчас просто рассылку, не затрагивая диск Z
var
  st, st1, filesadd, filesdelete, TaskDir, Slashes, Addr, Subj, PspName, PspNameOld: string;
  i, j, RecNo: Integer;
begin
  SetOrderSaveStatusText('Передача данных на сервер');
  if IsTemplate then begin
    Result := True;
    Exit;
  end;
  Result := False;
  try
    Slashes := '';
    filesadd := '';
    filesdelete := '';
    if Mode <> fDelete then begin
    //список слешей для создания каталогов, в формате 001, 005...
    //создаем только если колво не 0, не с СГП, и не д/к
      RecNo := MemTableEh1.RecNo;
      for i := 1 to MemTableEh1.RecordCount do begin
        MemTableEh1.RecNo := i;
        if (S.NNum(MemTableEh1.FieldByName('qnt').Value) <> 0) and (S.NNum(MemTableEh1.FieldByName('sgp').Value) <> 1) and (S.NNum(MemTableEh1.FieldByName('resale').Value) <> 1) then
          S.ConcatStP(Slashes, RightStr('0000' + IntToStr(i), 3) + ' ' + S.CorrectFileName(S.IIFStr(MemTableEh1.FieldByName('prefix').AsString <> '', MemTableEh1.FieldByName('prefix').AsString + '_', '') + Trim(MemTableEh1.FieldByName('name').AsString)), #13#10);
      end;
      MemTableEh1.RecNo := RecNo;
    //получим поля файлов для удаления и копирования на сервер
      RecNo := MemTableEh2.RecNo;
      for i := 1 to MemTableEh2.RecordCount do begin
        MemTableEh2.RecNo := i;
        if MemTableEh2.FieldByName('mode').AsString = 'Удален' then
          S.ConcatStP(filesdelete, MemTableEh2.FieldByName('name').AsString, #13#10)
        else if MemTableEh2.FieldByName('mode').AsString <> '' then
          S.ConcatStP(filesadd, MemTableEh2.FieldByName('name').AsString, #13#10);
      end;
      MemTableEh2.RecNo := RecNo;
    end;
    Addr := S.NSt(Q.QLoadValue('select addresses from adm_mailing where id = :i$i', [1]));
    if Mode = fDelete then begin
      Subj := 'Удален заказ ' + OrderPath;
      if MyQuestionMessage('Удалить папку заказа на диске со всем содержимым?') = mrYes then
        TaskDir := Tasks.CreateTaskRoot(mytskopDeleteFromArchive, [['directory', OrderPath], ['in_archive', S.NSt(FieldsArr[GetFieldsArrPos('in_archive'), cBegValue])], ['year', YearOf(dedt_Beg.Value)], ['to', Addr], ['subject', Subj], ['body', Subj]], False, False)
      else
        TaskDir := Tasks.CreateTaskRoot(mytskopmail, [['to', Addr], ['subject', Subj], ['body', Subj]], False, False);
    end
    else begin
      if Mode = fEdit then
        Subj := 'Изменен заказ'
      else
        Subj := 'Создан заказ';
      Subj := Orders.GetSubject(Subj, '', ID, null);
      if Mode = fEdit then begin
        st:= S.NSt(Q.QLoadValue('select order_prefix from ref_production_areas where id = :id$i', [FieldsArr[GetFieldsArrPos('area'), cBegValue]]));
        PspNameOld:= FieldsArr[GetFieldsArrPos('path'), cBegValue] + '.xlsx';
        Delete(PspNameOld, 1, length(st));
      end
      else PspNameOld:= '';
      st:= S.NSt(Q.QLoadValue('select order_prefix from ref_production_areas where id = :id$i', [FieldsArr[GetFieldsArrPos('area'), cNewValue]]));
      PspName:= OrderPath + '.xlsx';
      Delete(PspName, 1, length(st));
//exit;
    //создадим таскдир
      TaskDir := Tasks.CreateTaskRoot(mytskopToPassportChange, [
        ['directory', OrderPath],
        ['old-directory', S.NSt(FieldsArr[GetFieldsArrPos('path')][cBegValue])],
        ['in_archive', S.NSt(FieldsArr[GetFieldsArrPos('in_archive'), cBegValue])],
        ['year', YearOf(dedt_Beg.Value)],
        ['passport', PspName],
        ['old-passport', PspNameOld],
        ['subject', Subj],
        ['to', Addr],
        ['body', DifferencesText],
        ['files-to-send', PspName],
        ['files-to-copy', filesadd],
        ['files-to-delete', filesdelete],
        ['slashes', Slashes]  //    ['', ],
        ],
        False, False
      );
    //скопируем паспорт заказа из временного файла в каталог задачи
      CopyFile(pWideChar(Sys.GetWinTemp + '\' + OrderPath + '.xlsx'), pWideChar(Module.GetPath_Tasks + '\' + TaskDir + '\Files\' + PspName), True);
    //удалим временный файл паспорта
      DeleteFile(Sys.GetWinTemp + '\' + OrderPath + '.xlsx');
    //скопируем в каталог задачи файлы, которые были прикреплены в качестве внешних документов
      for i := 1 to MemTableEh2.RecordCount do begin
        MemTableEh2.RecNo := i;
        if (MemTableEh2.FieldByName('mode').AsString = 'Добавлен') or (MemTableEh2.FieldByName('mode').AsString = 'Обновлен') then
          if FileExists(MemTableEh2.FieldByName('namenew').AsString) then
            CopyFile(pWideChar(MemTableEh2.FieldByName('namenew').AsString), pWideChar(Module.GetPath_Tasks + '\' + TaskDir + '\Files\' + MemTableEh2.FieldByName('name').AsString), True);
      end;
    end;
  //отправим задачу на выполнение
    Tasks.FinalizeTaskDir(Module.GetPath_Tasks + '\' + TaskDir);
    Result := True;
  except
  end;
end;





+++проверку дат, не рабюооает автомат
ндс при наличке?
++какие суммы нужны в шапки, без скидок они без ндс?
сейчас в шаблоне нужно выбирать организацию обязательно, иначе не будет списка форамтов. может выдвать весь список форматов в шаблоне?
  также в старых шаблонах мог быть не выбран тип заказа, сейчас здесь в результате встанет плановый заказ.

блокировка действий в гридах в зависимости от статуса и при просмотре/удалении

FrgItemsButtonClick - ненльзя удалять.вставлять строки в пределах того что уже было при редактироывании???
