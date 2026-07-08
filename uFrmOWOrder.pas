unit uFrmOWOrder;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls,
  DBGridEhToolCtrls, MemTableDataEh, Db, ADODB, DataDriverEh,
  Clipbrd, GridsEh, DBAxisGridsEh,
  DBGridEh, Menus, Math, Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms,
  uDBOra, uFrmBasicMdi, uFrDBGridEh, uLabelColors, ufields, Vcl.Mask, uNamedArr,
  uFrMyPanelCaption;

type
  TFrmOWOrder = class(TFrmBasicMdi)
    PDividor1: TPanel;
    PHeader2: TPanel;
    PHAddDocs: TPanel;
    PHAddDocsCaption: TPanel;
    lbl5: TLabel;
    pnlBottom: TPanel;
    PHFilesButtons: TPanel;
    FrgFiles: TFrDBGridEh;
    pnlTop: TPanel;
    bvl1: TBevel;
    PHeaderTop: TPanel;
    PHDates: TPanel;
    dedt_dt: TDBDateTimeEditEh;
    dedt_dt_otgr: TDBDateTimeEditEh;
    dedt_dt_change: TDBDateTimeEditEh;
    dedt_dt_montage_beg: TDBDateTimeEditEh;
    dedt_dt_montage_end: TDBDateTimeEditEh;
    dedt_dt_beg: TDBDateTimeEditEh;
    PHCustomer: TPanel;
    cmb_customer: TDBComboBoxEh;
    cmb_customerman: TDBComboBoxEh;
    edt_customercontact: TDBEditEh;
    cmb_customerlegal: TDBComboBoxEh;
    edt_customerinn: TDBEditEh;
    cmb_cashtype: TDBComboBoxEh;
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
    PHSum: TPanel;
    DBNumberEditEh26: TDBNumberEditEh;
    DBNumberEditEh27: TDBNumberEditEh;
    DBNumberEditEh28: TDBNumberEditEh;
    nedt_sum_i: TDBNumberEditEh;
    DBNumberEditEh30: TDBNumberEditEh;
    DBNumberEditEh31: TDBNumberEditEh;
    DBNumberEditEh32: TDBNumberEditEh;
    DBNumberEditEh33: TDBNumberEditEh;
    DBNumberEditEh34: TDBNumberEditEh;
    DBNumberEditEh35: TDBNumberEditEh;
    DBNumberEditEh36: TDBNumberEditEh;
    DBNumberEditEh37: TDBNumberEditEh;
    DBNumberEditEh38: TDBNumberEditEh;
    DBNumberEditEh39: TDBNumberEditEh;
    DBNumberEditEh40: TDBNumberEditEh;
    DBNumberEditEh41: TDBNumberEditEh;
    PHTotalSum: TPanel;
    DBNumberEditEh42: TDBNumberEditEh;
    DBNumberEditEh43: TDBNumberEditEh;
    DBNumberEditEh44: TDBNumberEditEh;
    pnlGrid: TPanel;
    FrgItems: TFrDBGridEh;
    PHRelatedDocs: TPanel;
    PHRelatedDocsCaption: TPanel;
    lbl1: TLabel;
    FrgSemiproducts: TFrDBGridEh;
    PHCommentsLeft: TPanel;
    edt_complaints: TDBEditEh;
    m_comm: TDBMemoEh;
    frmpcItems: TFrMyPanelCaption;
    edt_reglament: TDBEditEh;
    frmpcOrder: TFrMyPanelCaption;
    frmpcCustomer: TFrMyPanelCaption;
    frmpcDates: TFrMyPanelCaption;
    PHFinCaptions: TPanel;
    lbl10: TLabel;
    lbl11: TLabel;
    lbl12: TLabel;
    lbl13: TLabel;
    frmpcFinance: TFrMyPanelCaption;
    pnlSelectAreas: TPanel;
    chbVisCustomer: TDBCheckBoxEh;
    chbVisDates: TDBCheckBoxEh;
    chbVisFinance: TDBCheckBoxEh;
    chbVisAddInfo: TDBCheckBoxEh;
    frmpcComments: TFrMyPanelCaption;
    frmpcAddDocs: TFrMyPanelCaption;
    frmpcRelatedDocs: TFrMyPanelCaption;
    FrgReclamations: TFrDBGridEh;
    pnlInvisible: TPanel;
    procedure FormResize(Sender: TObject);
  private
    WorkCellTypes: TNamedArr;
    WorkCellAreas: TVarDynArray2;
    FPDatesWidth, FPFinWidth: Integer;
    function  Prepare: Boolean; override;
    function  SetControlsLayout: Boolean;
    procedure SetAreasCaptions;
    procedure SetVisCheckboxes;
    procedure SetVisPanels(Sender: TObject = nil);
    function  PrepareFrgItems: Boolean;
    function  PrepareFrgReclamations: Boolean;
    function  PrepareFrgSemiproducts: Boolean;
    function  PrepareFrgFiles: Boolean;
    function  PrepareWorkCells: Boolean;
    procedure DefineFields;
    function  LoadOrderComboBoxes: Boolean;
    function  LoadOrder: Boolean;

//    procedure VerifyBeforeSave; virtual;
//    function  Save: Boolean; virtual;
    procedure ControlOnChange(Sender: TObject); override;
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

{$R *.dfm}

const
  WMIN_ORDERS = 425;
  WMIN_CUSTOMER = 250;

procedure TFrmOWOrder.FormResize(Sender: TObject);
var
  i: integer;
begin
  inherited;
  SetVisPanels;
  PHFinCaptions.Height := 26;
  PHSum.Top := PHFinCaptions.Bottom;
  edt_managername.Width := (PHOrder.Width div 2 - edt_managername.Left);
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
// pnlTop.Hide;
  pnlBottom.Hide;
  Caption := 'Заказ';
  Mode := fEdit;
  FOpt.DlgPanelStyle := dpsTopLeft;

  PrepareWorkCells;
  PrepareFrgItems;
  PrepareFrgReclamations;
  PrepareFrgSemiproducts;
  PrepareFrgFiles;

  SetControlsLayout;

  DefineFields;
  LoadOrder;
  if not LoadOrderComboBoxes then
    Exit;
  F.SetPropsControls;
  SetAreasCaptions;
  SetControlsEditable([], Mode in [fEdit, fCopy, fAdd]);

  //буферизация, иначе тормозит ресайз, тк много контролов меняют размер
  Self.DoubleBuffered := True;

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
  PHFinCaptions.Height := dedt_dt.Top + dedt_dt.Height;
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
  PHRelatedDocs.Width := PHRelatedDocsCaption.Width + FrgReclamations.Width + FrgSemiproducts.Width;
//  PHAddDocs.Width := Max(PHDates.Width + PHFin.Width, 250);
  PHAddDocs.Width := PHRelatedDocs.Width;
//  PHCommentsLeft.Width := ClientWidth - PHRelatedDocs.Width - PHAddDocs.Width;
//PHCommentsLeft.Align := alclient;
  Width := Width - 1;
  FormResize(Self);
  SetVisCheckboxes;
//  cmb_project.ControlLabel.Left := 5;
end;

procedure TFrmOWOrder.DefineFields;
begin
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
    ['status_itm'],

    ['ornum$i;0'],
    ['or_reference$s'],
    ['id_type2$i;0', 'V=1:400'],
    ['id_reglament$i'],
    ['reglament$s;0', 'V=1:400'],
    ['id_organization$s;id_organization$i', 'V=1:400'],
    ['area$i', 'V=1:100'], ['project$s', 'V=1:500::T'],
    ['id_or_format_estimates$i', 'V=1:400'],
    ['managername$s'],
    ['complaints$s'],

    ['customer$s', 'V=0:400'],
    ['customerman$s', 'V=0:400'],
    ['customercontact$s', 'V=0:400'],
    ['customerlegal$s', 'V=0:400'],
    ['customerinn$s', 'V=0:400'],
    ['address$s', 'V=1:400'],
    ['cashtype_add;cashtype$i','V=1:400'],
    ['account$s', 'V=0:400'],

    ['dt_beg$d'],
    ['dt_end$d'],
    ['dt_otgr$d'],
    ['dt_montage_beg$d'],
    ['dt_montage_end$d'],
    ['dt_change$d']
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
end;

function TFrmOWOrder.LoadOrderComboBoxes: Boolean;
begin
  //Cth.AddToComboBoxEh(cmb_OrderType, [['новый', '1'], ['рекламация', '2'], ['эксперимент', '3']]);
  Q.QLoadToDBComboBoxEh('select name, id from order_types where posstd is not null order by posstd', [], cmb_id_type2, cntComboLK);
  Q.QLoadToDBComboBoxEh('select name, id from order_types where posstd is null and (active = 1 or id = :id$i) order by pos', [F.GetPropB('id_type2')], cmb_id_type2, cntComboLK, 1);
  Cth.AddToComboBoxEh(cmb_CashType, [['наличные', '2'], ['безнал (нет счета)', '0'], ['безнал', '1']]);


  //  Q.QLoadToDBComboBoxEh('select name, id from or_formats where id = 0', [], cmb_Format, cntComboLK);
  //Q.QLoadToDBComboBoxEh('select name, id from or_formats where id > 1 and (active = 1 or id = :id$i) order by name', [FieldsArr[GetFieldsArrPos('id_format'), cBegValue]], cmb_Format, cntComboLK, 1);
  Q.QLoadToDBComboBoxEh('select name, id from ref_sn_organizations where id = -1', [], cmb_id_organization, cntComboLK);
  Q.QLoadToDBComboBoxEh('select name, id from ref_sn_organizations where id >= 0 and prefix is not null and (active = 1 or id = :id$i) order by name', [0{//!!!}], cmb_id_organization, cntComboLK, 1);
  //Organizations := Q.QLoad('select id, prefix, or_cashless, nds from ref_sn_organizations where id >= 0 and prefix is not null and (active = 1 or id = :id$i) order by name', [Id_Org_Old]);
  Q.QLoadToDBComboBoxEh('select shortname, id from ref_production_areas where active = 1 or id = :id$i order by id', [F.GetPropB('area')], cmb_Area, cntComboLK);
  Q.QLoadToDBComboBoxEh('select name from or_projects where (active = 1 or name = :name$s) order by name', [F.GetPropB('project')], cmb_Project, cntComboE);
  Q.QLoadToDBComboBoxEh('select f.name || '' ['' || e.name || '']'' as estimate, e.id as id ' + 'from or_formats f, or_format_estimates e ' + 'where e.id_format = f.id and e.active = 1 and f.active = 1 and ((e.id_format > 1)or(e.id_format = 0))' + 'order by 1 asc', [], cmb_id_or_format_estimates, cntComboLK);


{  Customers := Q.QLoad('select name, id from ref_customers where active = 1 or name = :name$s order by name', [FieldsArr[GetFieldsArrPos('customer'), cBegValue]]);
  cmb_CustomerName.Images := Il_Columns;
  cmb_CustomerMan.Images := Il_Columns;
  cmb_CustomerLegalName.Images := Il_Columns;
  for i := 0 to High(Customers) do
    cmb_CustomerName.Items.Add(Customers[i][0]);
  CustomerContacts := Q.QLoad('select name, contact, id_customer, id from ref_customer_contact where active = 1 or name = :name$s order by name', [FieldsArr[GetFieldsArrPos('customerman'), cBegValue]]);
  CustomerLegal := Q.QLoad('select legalname, inn, id_customer, id from ref_customer_legal where active = 1 or legalname = :name$s order by legalname', [FieldsArr[GetFieldsArrPos('customerlegal'), cBegValue]]);

  //if not(Mode in [fDelete, fView]) then
  GetEstimateList;
  LoadComplaints;}
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
    ['price$f', 'Цена', '50', 'f=0.00', 'e=0:999999:2:N'],
    ['qnt$f', 'Кол-во', '40', 'e=0:999999:0:N'],
    ['0 as qnt_sgp$f', 'Кол-во с СГП', '40', 'e=0:999999:0:N'],
    ['disassembled$i', 'В раз'#13#10'боре', '40', 'chb'],
    ['control_assembly$i', 'Контр сборка', '40', 'chb'],
    ['decode(nstd, 1, '' '') as nstd$s', 'Н/стд', '30', 'chbt', 'e']
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
  FrgItems.Opt.SetButtons(1, [[mbtInsert, True, 1], [mbtAdd, True, 1], [mbtDelete, True, 1], [], [mbtCtlPanel]]);
  FrgItems.CreateAddControls('1', cntCheck, 'Показать с нулевым количеством', 'ChbView0', '', 4, yrefC, 250);
  FrgItems.Opt.SetGridOperations('uaid');
  FrgItems.Opt.SetTable('v_order_items');
  FrgItems.SetInitData([]);
  FrgItems.Prepare;
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

function TFrmOWOrder.PrepareFrgReclamations: Boolean;
begin
  FrgReclamations.Width := 130;
  FrgReclamations.Options := [];
  FrgReclamations.Opt.SetFields([['id$i', '_id', '100'], ['ornum$s', 'Рекламации', '30;w', 'bt=показать паспорт']]);
  FrgReclamations.SetInitData('select ornum from orders where rownum <= 1', []);
  FrgReclamations.Prepare;
  //FrgReclamations.DbGridEh1.Options := FrgReclamations.DbGridEh1.Options - [dgTitles];
  FrgReclamations.RefreshGrid;
end;

function TFrmOWOrder.PrepareFrgSemiproducts: Boolean;
begin
  FrgSemiproducts.Width := 130;
  FrgSemiproducts.Options := [];
  FrgSemiproducts.Opt.SetFields([['id$i', '_id', '100'], ['ornum$s', 'Полуфабрикаты', '30;w', 'bt=показать паспорт']]);
  FrgSemiproducts.SetInitData('select ornum from orders where rownum <= 5', []);
  FrgSemiproducts.Prepare;
  FrgSemiproducts.RefreshGrid;
end;

function TFrmOWOrder.PrepareFrgFiles: Boolean;
begin
  FrgFiles.Options := [];
  FrgFiles.Opt.SetFields([['id$i', '_id', '100'], ['name$s', 'Файл', '300;w', 'bt']]);
  FrgFiles.Opt.SetGridOperations('uaid');
  FrgFiles.Opt.SetTable('bcad_groups');
  FrgFiles.SetInitData('*', []);
  FrgFiles.Opt.SetButtons(1, [[mbtAdd, True], [mbtDelete, True]], 2, PHFilesButtons, 0, True);
  FrgFiles.Prepare;
  FrgFiles.DbGridEh1.Options := FrgFiles.DbGridEh1.Options - [dgTitles];
  FrgFiles.RefreshGrid;
end;

function TFrmOWOrder.PrepareWorkCells: Boolean;
var
  i: Integer;
begin
  Result := False;
  Result := True;
  WorkCellAreas := [];
  Q.QLoad('select id, code, posstd, refers_to_prod_area from v_work_cell_types order by posall asc', [], WorkCellTypes);
  for i := 0 to WorkCellTypes.Count - 1 do begin
    if WorkCellTypes.G(i, 'refers_to_prod_area') = 1 then
      WorkCellAreas := WorkCellAreas + [[]]
    else
      WorkCellAreas := WorkCellAreas + [['ПЩ', 'И', 'ДМ']];
//      FrgItems.Opt.SetPick('id_category', A.VarDynArray2ColToVD1(WorkCellAreas, 0), A.VarDynArray2RowToVD1(WorkCellAreas, i), True);
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

  if Sender = cmb_id_type2 then begin
    if (S.NNum(SenderValue) = 1) and (S.NNum(F.GetProp('id_organization')) <> -1) then
      F.SetProp('id_organization', -1);
    if (S.NNum(SenderValue) <> 1) and (S.NNum(F.GetProp('id_organization')) = -1) then
      F.SetProp('id_organization', null);
  end;
  if Sender = cmb_id_organization then begin
  end;
  if F.GetProp('id_type2') = null then
    F.SetProp('id_organization', null)
  else if (F.GetProp('id_type2') = 1) and (S.NNum(F.GetProp('id_organization')) <> -1) then
    F.SetProp('id_organization', -1)
  else if (F.GetProp('id_type2') <> 1) and (S.NNum(F.GetProp('id_organization')) = -1) then
    F.SetProp('id_organization', null);
  inherited;
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

procedure TFrmOWOrder.SetAreasCaptions;
begin
  frmpcOrder.SetParameters(True, 'Основное', [[
    ''#13#10
    ]],
    False
  );
  frmpcCustomer.SetParameters(True, 'Покупатель', [[
    ''#13#10
    ]],
    False
  );
  frmpcDates.SetParameters(True, 'Даты', [[
    ''#13#10
    ]],
    False
  );
  frmpcFinance.SetParameters(True, 'Финансы', [[
    ''#13#10
    ]],
    False
  );
  frmpcComments.SetParameters(True, 'Дополнение', [[
    ''#13#10
    ]],
    False
  );
  frmpcRelatedDocs.SetParameters(True, 'Связанные заказы', [[
    ''#13#10
    ]],
    False
  );
  frmpcAddDocs.SetParameters(True, 'Внешние документы', [[
    ''#13#10
    ]],
    False
  );
  frmpcItems.SetParameters(True, 'Состав заказа', [[
    ''#13#10
    ]],
    False
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
  if Sender = chbVisAddInfo then begin
    PHeader2.Visible := chbVisAddInfo.Checked;
    SetVisCheckboxes;
    Exit;
  end;
  //параметры
  var LCheckBoxes := [chbVisCustomer, chbVisDates, chbVisFinance];
  var LPanels := [PHOrder, PHCustomer, PHDates, PHFin];
  var LPanelsSizeable := [True, True, False, False];
  var LWMin := [WMIN_ORDERS, WMIN_CUSTOMER, FPDatesWidth, FPFinWidth];
  var LWCurr := [0, 0, 0, 0];
  //делаем количество итераций подгонки по количеству чекбоксов управления видимостью
  for i := 0 to High(LCheckBoxes) do begin
    //посчитаем минимально необходимую ширину
    w := 0;
    for j := 0 to High(LPanels) do
//      w := w + S.IIf(LPanels[j].Width > 0, LWMin[j], 0);
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
{      if not LCheckBoxes[j - 1].Checked then
        LPanels[j].Width := 0
      else
        LPanels[j].Width := LWMin[j];}
    end;
    //установим ширину в массиве по минимуму и посчитаем общую ширину
    w := 0;
    for j := 0 to High(LPanels) do begin
//      LWCurr[j] := S.IIf(LPanels[j].Width > 0, LWMin[j], 0);
      LWCurr[j] := S.IIf(LPanels[j].Visible, LWMin[j], 0);
      w := w + LWCurr[j];
    end;
    //количество видимых панелей с изменяемой шириной
    var LCntSizeable := 0;
    for j := 0 to High(LPanelsSizeable) do
//      if (LPanelsSizeable[j]) and (LPanels[j].Width > 0) then
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

end.
