unit uFrmOWOrder;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls,
  DBGridEhToolCtrls, MemTableDataEh, Db, ADODB, DataDriverEh,
  Clipbrd, GridsEh, DBAxisGridsEh,
  DBGridEh, Menus, Math, Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms,
  uDBOra, uFrmBasicMdi, uFrDBGridEh, uLabelColors, ufields, Vcl.Mask;

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
    DBComboBoxEh1: TDBComboBoxEh;
    DBComboBoxEh2: TDBComboBoxEh;
    DBEditEh2: TDBEditEh;
    cmb_legalname: TDBComboBoxEh;
    edt_account: TDBEditEh;
    DBEditEh4: TDBEditEh;
    cmb_CashType: TDBComboBoxEh;
    edt_address: TDBEditEh;
    PHOrder: TPanel;
    cmb_id_organization: TDBComboBoxEh;
    edt_ornum: TDBEditEh;
    cmb_id_or_format_estimates: TDBComboBoxEh;
    cmb_project: TDBComboBoxEh;
    edt_managername: TDBEditEh;
    cmb_main: TDBComboBoxEh;
    cmb_Area: TDBComboBoxEh;
    cmb_id_ordertype: TDBComboBoxEh;
    edt_planningname: TDBEditEh;
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
    PHFinCaptions: TPanel;
    lbl10: TLabel;
    lbl11: TLabel;
    lbl12: TLabel;
    lbl13: TLabel;
    pnlGrid: TPanel;
    FrgItems: TFrDBGridEh;
    PHRelatedDocs: TPanel;
    PHRelatedDocsCaption: TPanel;
    lbl1: TLabel;
    FrgReclamations: TFrDBGridEh;
    FrgSemiproducts: TFrDBGridEh;
    PHCommentsLeft: TPanel;
    DBEditEh1: TDBEditEh;
    DBMemoEh1: TDBMemoEh;
    procedure FormResize(Sender: TObject);
  private
    WorkCellTypes: TNamedArr;
    WorkCellAreas: TVarDynArray2;
    function  Prepare: Boolean; override;
    function  SetControlsLayout: Boolean;
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

procedure TFrmOWOrder.FormResize(Sender: TObject);
var
  i: integer;
begin
  inherited;
  PHOrder.Width := (PHOrder.Width + PHCustomer.Width) div 2;
  edt_managername.Width := (PHOrder.Width div 2 - edt_managername.Left);
  edt_planningname.Width := edt_managername.Width;
  edt_planningname.Left := cmb_project.Left + cmb_project.Width - edt_planningname.Width;
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
  pnlTop.Hide;
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
  SetControlsEditable([], Mode in [fEdit, fCopy, fAdd]);

  FWHBounds.X := 1000;
  FWHBounds.Y := 700;

  Result := True;
end;

function TFrmOWOrder.SetControlsLayout: Boolean;
begin
  Cth.MakePanelsFlat(pnlFrmClient, [], True);
  Cth.AlignControls(PHOrder, [], True);
  Cth.AlignControls(PHCustomer, [], True);
  Cth.AlignControls(PHDates, [], True);
  Cth.AlignControls(PHSum, [], True);
  Cth.AlignControls(PHTotalSum, [], True);
  PHFinCaptions.Height := dedt_dt.Top + dedt_dt.Height;
  PHFin.Height := PHSum.Height + PHTotalSum.Height;
  PHeaderTop.Height := S.MaxOf([PHOrder.Height, PHCustomer.Height, PHDates.Height, PHFin.Height]);
  PHFin.Align := alRight;
  PHDates.Align := alRight;
  PHOrder.Align := alLeft;
  PHCustomer.Align := alClient;
  Cth.AlignControls(PDividor1, [], True);
  bvl1.Left := 0;
  bvl1.Width := 4000;
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
//  cmb_project.ControlLabel.Left := 5;
end;

procedure TFrmOWOrder.DefineFields;
begin
  F.DefineFields := [
    ['id$i'],
    ['ornum$i;0'],
    ['_id_ordertype$i;0', 'V=1:400'],
    ['id_organization$s;id_organization$i', 'V=1:400'],
    ['area$i', 'V=1:100'], ['project$s', 'V=1:500::T'],
    ['id_or_format_estimates$i', 'V=1:400'],
    ['address$s', 'V=0:400'],
    ['account$s', 'V=0:400'],
    ['managername$s'],
    ['dt_beg$d'],
    ['dt_end$d'],
    ['dt_otgr$d'],
    ['dt_montage_beg$d'],
    ['dt_montage_end$d'],
    ['dt_change$d'],
    ['cashtype$i', 'V=', #0]
    {['','V=',#0],
    ['','V=',#0],
    ['','V=',#0],
    ['','V=',#0],
    ['','V=',#0],
    ['','V=',#0],
    ['','V=',#0],}
      ];
  F.PrepareDefineFieldsAdd;
end;

function TFrmOWOrder.LoadOrderComboBoxes: Boolean;
begin
  //Cth.AddToComboBoxEh(cmb_OrderType, [['новый', '1'], ['рекламация', '2'], ['эксперимент', '3']]);
  Q.QLoadToDBComboBoxEh('select name, id from order_types where posstd is not null order by posstd', [], cmb_id_ordertype, cntComboLK);
  Q.QLoadToDBComboBoxEh('select name, id from order_types where posstd is null and (active = 1 or id = :id$i) order by pos', [F.GetPropB('_id_ordertype')], cmb_id_ordertype, cntComboLK, 1);
  Cth.AddToComboBoxEh(cmb_CashType, [['наличные', '2'], ['безнал (нет счета)', '0'], ['безнал', '1']]);


  //  Q.QLoadToDBComboBoxEh('select name, id from or_formats where id = 0', [], cmb_Format, cntComboLK);
  //Q.QLoadToDBComboBoxEh('select name, id from or_formats where id > 1 and (active = 1 or id = :id$i) order by name', [FieldsArr[GetFieldsArrPos('id_format'), cBegValue]], cmb_Format, cntComboLK, 1);
  Q.QLoadToDBComboBoxEh('select name, id from ref_sn_organizations where id = -1', [], cmb_id_organization, cntComboLK);
  Q.QLoadToDBComboBoxEh('select name, id from ref_sn_organizations where id >= 0 and prefix is not null and (active = 1 or id = :id$i) order by name', [0{//!!!}], cmb_id_organization, cntComboLK, 1);
  //Organizations := Q.QLoadToVarDynArray2('select id, prefix, or_cashless, nds from ref_sn_organizations where id >= 0 and prefix is not null and (active = 1 or id = :id$i) order by name', [Id_Org_Old]);
  Q.QLoadToDBComboBoxEh('select shortname, id from ref_production_areas where active = 1 or id = :id$i order by id', [F.GetPropB('area')], cmb_Area, cntComboLK);
  Q.QLoadToDBComboBoxEh('select name from or_projects where (active = 1 or name = :name$s) order by name', [F.GetPropB('project')], cmb_Project, cntComboE);
  Q.QLoadToDBComboBoxEh('select f.name || '' ['' || e.name || '']'' as estimate, e.id as id ' + 'from or_formats f, or_format_estimates e ' + 'where e.id_format = f.id and e.active = 1 and f.active = 1 and ((e.id_format > 1)or(e.id_format = 0))' + 'order by 1 asc', [], cmb_id_or_format_estimates, cntComboLK);


{  Customers := Q.QLoadToVarDynArray2('select name, id from ref_customers where active = 1 or name = :name$s order by name', [FieldsArr[GetFieldsArrPos('customer'), cBegValue]]);
  cmb_CustomerName.Images := Il_Columns;
  cmb_CustomerMan.Images := Il_Columns;
  cmb_CustomerLegalName.Images := Il_Columns;
  for i := 0 to High(Customers) do
    cmb_CustomerName.Items.Add(Customers[i][0]);
  CustomerContacts := Q.QLoadToVarDynArray2('select name, contact, id_customer, id from ref_customer_contact where active = 1 or name = :name$s order by name', [FieldsArr[GetFieldsArrPos('customerman'), cBegValue]]);
  CustomerLegal := Q.QLoadToVarDynArray2('select legalname, inn, id_customer, id from ref_customer_legal where active = 1 or legalname = :name$s order by legalname', [FieldsArr[GetFieldsArrPos('customerlegal'), cBegValue]]);

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
  for i := 0 to F.Count do
    if F.GetProp(i, fvtFNameL) <> '' then begin
      S.ConcatStP(FieldsSt, F.GetProp(i, fvtFNameL), ';');
    end;
  CtrlValues := Q.QLoadToVarDynArrayOneRow(Q.QSIUDSql('s', 'v_orders', FieldsSt), [id]);
  j := 0;
  for i := 0 to F.Count do
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
begin
  Result := False;
  FrgItems.Options := FrDBGridOptionDef + [myogPanelFind, myogMultiSelect, myogIndicatorCheckBoxes, myogHasStatusBar];
  va2 := [];
  for i := 0 to WorkCellTypes.Count - 1 do
    if WorkCellTypes.G(i, 'refers_to_prod_area') = 1 then
      va2 := va2 + [['null as r_' + VarToStr(WorkCellTypes.G(i, 'id')) + '$s', 'Производственный маршрут|' + WorkCellTypes.G(i, 'code'), '50;L', 'chbt', 'e']]
    else
      va2 := va2 + [['null as r_' + VarToStr(WorkCellTypes.G(i, 'id')) + '$s', 'Производственный маршрут|' + WorkCellTypes.G(i, 'code'), '30', 'chbt', 'e']];
  FrgItems.Opt.Caption := 'Состав заказа';
  FrgItems.Opt.SetFields([['id$i', '_id', '40'], ['id_std_item$i', '_id_std', '40'], ['id_itm$i', '_id_itm', '40'], ['ch$s', '_ch', '40'], ['attention$i', '_attention', '40'], ['0 as status$s', '*', '20'], ['slash$s', 'Паспорт', '90'], ['prefix$s', 'Префикс', '60;h'], ['itemname$s', 'Изделие', '400;w;h', 'e=1:400::T'], ['price$f', 'Цена', '50', 'e=0:999999:2:N'], ['price_pp$f', 'Втч'#13#10'Д/К', '50', 'e=0:999999:2:N'], ['qnt$f', 'Кол-во', '40', 'e=0:999999:0:N'], ['0 as qnt_sgp$f', 'Кол-во с СГП', '40', 'e=0:999999:0:N'], ['decode(nstd, 1, '' '') as nstd$s', 'Н/стд', '30', 'chbt', 'e']] + va2 + [['comm$f', 'Дополнение', '200;w;h', 'e=0:400::T'], ['0 as sum$f', 'Сумма', '50']]);
  for i := 0 to WorkCellTypes.Count - 1 do
    if WorkCellTypes.G(i, 'refers_to_prod_area') = 1 then
      FrgItems.Opt.SetPick('r_' + VarToStr(WorkCellTypes.G(i, 'id')), ['ПЩ', 'И', 'ДМ'], ['0', '1', '2'], True, False);
  FrgItems.Opt.SetButtons(1, [[mbtInsert, True, 1], [mbtAdd, True, 1], [mbtDelete, True, 1]]);
  FrgItems.Opt.SetGridOperations('uaid');
  FrgItems.Opt.SetTable('v_order_items');
  FrgItems.Opt.SetWhere('where id_order = 8482');
  FrgItems.SetInitData('*', []);
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
  FrgItems.Prepare;
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
  Q.QLoadFromQuery('select id, code, posstd, refers_to_prod_area from v_work_cell_types order by posall asc', [], WorkCellTypes);
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
  SenderName: string;
  SenderValue : Variant;
begin
  SenderName := TControl(Sender).Name;
  SenderValue := Cth.GetControlValue(Sender);
  if Sender = cmb_id_ordertype then begin
    if (S.NNum(SenderValue) = 1) and (S.NNum(F.GetProp('id_organization')) <> -1) then
      F.SetProp('id_organization', -1);
    if (S.NNum(SenderValue) <> 1) and (S.NNum(F.GetProp('id_organization')) = -1) then
      F.SetProp('id_organization', null);
  end;
  if Sender = cmb_id_organization then begin
  end;
  if F.GetProp('_id_ordertype') = null then
    F.SetProp('id_organization', null)
  else if (F.GetProp('_id_ordertype') = 1) and (S.NNum(F.GetProp('id_organization')) <> -1) then
    F.SetProp('id_organization', -1)
  else if (F.GetProp('_id_ordertype') <> 1) and (S.NNum(F.GetProp('id_organization')) = -1) then
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

end.

