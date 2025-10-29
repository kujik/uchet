unit uFrmOGjrnOrders;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uData, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2
  ;

type
  TFrmOGjrnOrders = class(TFrmBasicGrid2)
  private
    function  OpenFromTemplate: Integer;
    procedure ViewInfo1;
  protected
    function  PrepareForm: Boolean; override;
    //������� ������� (���������) ������ �����
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    function  Frg1OnFilterExecute(var Fr: TFrDBGridEh; const No: Integer; var Handled: Boolean): string; override;
    procedure Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); override;
    //������� ������� (����������) ������ �����
    procedure Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure Frg2ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
  public
  end;

var
  FrmOGjrnOrders: TFrmOGjrnOrders;

implementation

uses
  uSettings,
  uSys,
  uForms,
  uDBOra,
  uString,
  uMessages,
  uWindows,
  uOrders,
  uFrmOWOrder,
  D_Order_UPD,
  uPrintReport,
  D_OrderPrintLabels,
  uFrmOGrefOrStdItems,
  uFrmXDedtGridFilter,
  uFrmBasicInput
  ;


{$R *.dfm}

function TFrmOGjrnOrders.PrepareForm: Boolean;
var
  c : TComponent;
begin
  Caption:='������ �������';
  Frg1.Options := Frg1.Options {- [myogsaveoptions]} + [myogIndicatorCheckBoxes, myogMultiSelect, myogGridLabels, myogRowDetailPanel, myogLoadAfterVisible];
  Frg1.Opt.SetFields([
    ['id$i','_id','d=40'],
    ['id_itm$i','_id_itm','40'],
    ['has_itm_est$i','_has_itm_est','40'],
    ['path$s','_path','40'],
    ['in_archive$i','_in_archive','20','pic='],
    ['dt_beg$d','���� ��������',''],
    ['ornum$s','� ������','80','bt=������� ����� ������:4'],
    ['area_short$s','��������','20'],
    ['typename$s','��� ������','80'],
    ['organization$s','�����������','100'],
    ['customer$s','��������','150'],
    ['project$s','������','150'],
    ['address$s','����� ��������','250'],
    ['dt_otgr$d','�������� (����)',''],
    ['to_kns$i','�����������',''],
    ['to_thn$i','��������',''],
    ['dt_kns_max','��������� ���',''],
    ['dt_thn_max','��������� ���',''],
    ['estimates$i','�����','20', 'pic=-;+:6;7', True],
    ['dt_estimate_max$d','��������� �����',''],
    ['dt_reserve$d','���� ��������������'],
    ['dt_aggr_estimate$d','����� �����',''],
    ['status_itm$s', '������ ������','80'],
    ['qnt_slashes$i', '���-�� ������', '80','f=:'],
    ['qnt_items$f', '���-�� �������', '80','f=:'],
    ['qnt_in_prod$f', '���-�� ������� � ������������', '80','f=:'],
    ['dt_to_prod$d','������� � ������������',''],
    ['qnt_to_sgp$f', '���-�� �������, �������� �� ���', '80','f=:'],
    ['dt_to_sgp$d','������ �� ���',''],
    ['dt_from_sgp$d','��������',''],
    ['dt_end_manager$d','���������� ����������','','chbt=+', 'e',User.Roles([], [rOr_D_Order_SetCompletedM, rOr_D_Order_SetCompletedMA])],
    ['cancel$i','����� �������','80','chb=6;0','f=#:#0','e', User.Role(rOr_D_Order_SetCanceled)],
    ['dt_end$d','����� ������','','chbt=+','e', User.Role(rOr_D_Order_SetCompleted) or User.Role(rOr_D_Order_SetUnCompleted)],
    ['early_or_late$i','���������� / ���������','70'],
    ['qnt_boards_m2$f','�������, �2','80', 'f=f:'],
    ['qnt_edges_m$f','������, �.�.','80', 'f=f:'],
    ['dt_upd_reg','����������� ���','', 'bt=���� ���', User.Role(rOr_D_Order_EnteringUPD), 'bt=�������� ���', not User.Role(rOr_D_Order_EnteringUPD)],
    ['dt_upd','���� ���',''],
    ['upd','����� ���','80'],
    ['pay$f','��������','f=r:','null',not User.Role(rOr_J_Orders_Payments_V)],
    ['pay_n$f','������������� ������','f=r:','null',not User.Role(rOr_J_Orders_PaymentsN_V)],
    ['account$s','����','100'],
    ['cost_i_wo_nds$f','��������� �������','80','f=r:','t=1'],
    ['cost_i_nosgp_wo_nds$f','��������� � ������������','f=r:','80','t=1'],
    ['cost_a_wo_nds$f','��������� ���. �����','80','f=r:','t=1'],
    ['cost_d_wo_nds$f','��������� ��������','80','f=r:','t=1'],
    ['cost_m_wo_nds$f','��������� �������','80','f=r:','t=1'],
    ['cost_wo_nds$f','����� ������','80','f=r:','t=1'],
    ['cost$f','����� ������ � ���','80','f=r:','t=1'],
    ['sum0$f','�������������','80','f=r:','t=2','null'],
    ['comm$s','����������','200']
//    ['','',''],
  ]);
  Frg1.Opt.SetTable('v_orders_list');
  Frg1.Opt.SetWhere('where id > 0');
  Frg1.CreateAddControls('1', cntCheck, '������ ����������', 'ChbNoClosed', '', 4, yrefT, 200);
  Frg1.CreateAddControls('1', cntCheck, '� ������������', 'ChbInProd', '', 4, yrefB, 200);
  //������������ ������ - �������� ��� ������������ �� ������� (-11)
  Frg1.CreateAddControls('1', cntCheck, '������������ ������', 'ChbFilter1', '', 4 + 130 + 4, yrefT, 200, -11);
  Frg1.CreateAddControls('1', cntCheck, '������������ ������ + 7�', 'ChbFilter2', '', 4 + 130 + 4, yrefB, 200, -11);
  Frg1.CreateAddControls('1', cntCheck, '�������� �����', 'ChbViewSum', '', 310, yrefC, 200);

  Frg1.Opt.SetButtons(1, [
   [mbtRefresh], [],
   [mbtView], [mbtEdit, User.Role(rOr_D_Order_Ch)], [mbtAdd, 1], [mbtCopy, 1], [mbtCustom_OrderFromTemplate, 1], [mbtDelete, User.Role(rOr_D_Order_Del)], [],
   [mbtViewEstimate], [mbtLoadEstimate, User.Role(rOr_D_Order_Estimate)], [-mbtCustom_CreateAggregateEstimate, 1], [],
   [-mbtCustom_SendSnDocuments, User.Role(rOr_D_Order_AttachSnDocuments)], [], [-mbtCustom_OrToDevel, User.Role(rOr_J_Orders_ToDevel)], [],
   [mbtTest, User.IsDeveloper],
   [mbtDividorM], [mbtPrint], [mbtPrintPassport], [mbtPrintLabels], [mbtDividorM], [],
   [mbtGridFilter], [], [mbtGridSettings], [], [mbtCtlPanel]
  ]);
  Frg1.Opt.SetButtonsIfEmpty([mbtCustom_OrderFromTemplate]);

//  Frg1.Opt.FilterRules := [[], ['dt_beg;dt_end'], ['������ ����������������', 'prod'], ['����', '', True], ['����2'], ['��������', False]];
  Frg1.Opt.FilterRules := [[], ['dt_beg;dt_otgr;dt_end'], ['�������� �������������', 'Sum0', User.Role(rOr_J_Orders_Sum)]];

  Frg2.Options := Frg2.Options + [myogIndicatorCheckBoxes, myogMultiSelect];
  Frg2.Opt.SetFields([
    ['id$i','_id','40'],
    ['id_std_item$i','_id_std_item','40'],
    ['id_itm$i','_id_itm','40'],
    ['has_itm_est$i','_has_itm_est','40'],
    ['slash','�','100'],
    ['fullitemname','�������','200'],
    ['qnt','����������','80'],
    ['qnt_in_prod$f', '���-�� ������� � ������������', '80','f=:'],
    ['qnt_to_sgp$f', '���-�� �������, �������� �� ���', '80','f=:'],
    ['route2','�������','120'],
    ['kns','�����������','120'],
    ['thn','��������','120'],
    ['dt_estimate','�����','80'],
    ['sgp','� ���','40','pic'],
    ['nstd','����������','40','pic'],
    ['disassembled','� �������','40','pic'],
    ['control_assembly','�����. ������','40','pic'],
    ['dt_kns','��������� ���','80'],
    ['dt_thn','��������� ���','80'],
    ['qnt_boards_m2$f','�������, �2','80', 'f=f:'],
    ['qnt_edges_m$f','������, �.�.','80', 'f=f:'],
    ['cost_wo_nds$f','�����','80','f=r:','t=1'],
    ['sum0$f','�������������','80','f=r:','t=2','null'],
    ['comm$s','����������','200']
  ]);
  Frg2.Opt.SetTable('v_order_items');
  Frg2.Opt.SetWhere('where id_order = :id_order$i and qnt > 0 order by slash');
  Frg2.Opt.SetButtons(1, [
    [mbtRefresh], [], [mbtViewEstimate], [mbtLoadEstimate, User.Role(rOr_D_Order_Estimate)], [-mbtCopyEstimate, True, '����������� ����� � �����'],
    [],[-1002, (User.GetJobID = 2) or (User.GetJobID = 3) or User.IsDeveloper, '���������� ��������� ���'],
    [],[-mbtCustom_Order_AttachThnDoc, User.Role(rOr_D_Order_AttachThnDocuments)],
     {[-mbtCustom_OrderSetAllSN, User.Role(rOr_D_Order_SetSn)], }
    [],[-mbtCustom_OrToDevel, User.Role(rOr_J_Orders_ToDevel)],[],[-1001, True, '������� � ������������ �������'],
    [], [mbtGridSettings], [-mbtTest, User.IsDeveloper]
  ]);

  Frg1.ReadControlValues;
  if not (User.Role(rOr_J_Orders_Sum)or(User.Role(rOr_J_Orders_PrimeCost))) then begin
    Cth.SetControlValue(TDBCheckBoxEh(Frg1.FindComponent('ChbViewSum')), 0);
    TDBCheckBoxEh(Frg1.FindComponent('ChbViewSum')).Enabled := False;
    Frg1.Opt.SetColFeature('1', 'null', True, False);
    Frg2.Opt.SetColFeature('1', 'null', True, False);
  end;
  Frg1.Opt.SetColFeature('1', 'i', Cth.GetControlValue(Frg1, 'ChbViewSum') = 0, False);
  Frg2.Opt.SetColFeature('1', 'i', Cth.GetControlValue(Frg1, 'ChbViewSum') = 0, False);

  Frg1.InfoArray:=[
    [Caption + '.'#13#10]
  ];

  Result := inherited;
end;


{�������� ����}

procedure TFrmOGjrnOrders.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
var
  va1: TVarDynArray;
  va2: TVarDynArray2;
  st, st1: string;
  i, j: Integer;
begin
  if Tag = mbtTest then begin
    TFrmOWOrder.Show( Self, '_order', [myfodialog, myfoSizeable, myfoEnableMaximize], fEdit, Fr.ID, null);
{    Fr.setstate(null, True, 'wqdwqsdfwefsdfsdfgsdgsdfgdfsgdfsgsdfgdfgdfgfd');exit;
//    Fr.MemTableEh1.Close;
    Fr.Opt.SetColFeature('estimates', 'pic=+;1', True, True);
    Fr.Opt.SetColFeature('upd', 'bt', False, False);
    Fr.Opt.SetColFeature('dt_end_manager', 'chbt', False, False);
    Fr.Opt.SetColFeature('pay', 'f=#.000:', True, True);}
  end
{ else if (Tag = mbtRefresh) then begin
    //���� ���� ���� ����������, �� ��� �������� �������������� ������, �� � �����
    //��� ���������� ���� ������� ��� �������� ���. ������ ���������� ���������
    InRowPanelDataChanged:=False;
    inherited;
//    SetColumnsVisible;
    Exit;
  end}
  else if Tag = mbtCustom_OrToDevel then begin
    Orders.OrderItemsToDevel(Fr.ID, null);
  end
  else if Tag = mbtViewEstimate then begin
    //�������� ����� ����� �� ������ ��� ���������� (���������� ���������� � ����������) �������
    va1:=A.VarDynArray2ColToVD1(Gh.GetGridArrayOfChecked(Fr.DBGridEh1, -1), 0);
    if (Length(va1) = 0)
      then Wh.ExecReference(myfrm_R_AggEstimate, Self, [myfoDialog, myfoMultiCopyWoId, myfoSizeable, myfoEnableMaximize], VarArrayOf([Fr.ID]))
      else Wh.ExecReference(myfrm_R_AggEstimate, Self, [myfoDialog, myfoMultiCopyWoId, myfoSizeable, myfoEnableMaximize], va1);
  end
  else if Tag = mbtPrintPassport then begin
    PrintReport.pnl_Order(Fr.ID);
  end
  else if (Tag = mbtCustom_OrderFromTemplate) then begin
    //����� �� �������
    OpenFromTemplate;
  end
  else if (Tag = mbtLoadEstimate) then begin
    //���������� ���� �� ���� ��������, ����������� �� ����������� ������� �� ������ �����������, �� �������������,
    //���� ����� ��� ���� �� ��������������� ����������
    if Orders.IsOrderFinalized(Fr.ID) > 0 then
      Exit;
    if MyQuestionMessage('���������/�������� ����� �� ���� �������� ������ ' + Fr.GetValue('ornum') + '?') <> mrYes then
      Exit;
    Fr.BeginOperation;
    Orders.RefreshEstimatesAndSyncWithITM(Fr.ID, [], True);
    Fr.EndOperation;
    Fr.RefreshRecord;
  end
  else if (Tag = mbtCustom_SendSnDocuments) then begin
    //��������� ��������� �� ���������
    if Orders.IsOrderFinalized(Fr.ID) > 0 then
      Exit;
    Orders.TaskForSendSnDocuments(Fr.ID, null);
    Fr.RefreshRecord;
  end
  else if (Tag = mbtPrintLabels) then begin
    Dlg_OrderPrinTLabels.ShowDialog(Fr.ID);
  end
  else if (Tag = mbtCustom_CreateAggregateEstimate) then begin
    Orders.CreateAggregateEstimate(Fr.ID, 0);
  end
  else if (Tag = mbtCustom_CreateCompleteEstimate) then begin
    Orders.CreateAggregateEstimate(Fr.ID, 1);
  end
  else if Fmode <> fNone then begin
    //������ ����� ������
    Wh.ExecDialog(myfrm_Dlg_Order, Self, [], fMode, Fr.ID, null);
  end
  else Inherited;
end;

procedure TFrmOGjrnOrders.Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
  if not Fr.RefreshRecord then
    Exit;
  if Fr.CurrField = 'dt_end' then begin
    if Orders.FinalizeOrder(Fr.id, myOrFinalizeManual, 2, False) = 1
      then Fr.RefreshRecord;
  end
  else if Fr.CurrField = 'dt_end_manager' then begin
    if Orders.FinalizeOrderM(Fr.id) = 1
      then Fr.RefreshRecord;
  end
  else if Fr.CurrField = 'dt_upd_reg' then begin
    if Dlg_Order_UPD.ShowDialog(Fr.id)
      then Fr.RefreshRecord;
  end
  else if Fr.CurrField = 'ornum' then begin
    //������� ����� ������
    Sys.ExecFile(Module.GetPath_Order(IntToStr(YearOf(Fr.GetValue('dt_beg'))), Fr.GetValue('in_archive')) + '\' + Fr.GetValue('path'));
  end
  else inherited;
end;

procedure TFrmOGjrnOrders.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
end;

function  TFrmOGjrnOrders.Frg1OnFilterExecute(var Fr: TFrDBGridEh; const No: Integer; var Handled: Boolean): string;
begin
end;

procedure TFrmOGjrnOrders.Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  if (Cth.GetControlValue(Fr, 'ChbFilter1') = 1) or (Cth.GetControlValue(Fr, 'ChbFilter2') = 1) then begin
    //������ ������������ ������� - �� ��������� ��������� ��������� ����������!
    SqlWhere := 'dt_end is null and dt_to_sgp is null and dt_from_sgp is null and to_thn is not null and dt_otgr >= :dt1$d and dt_otgr <= :dt2$d';
    Fr.SetSqlParameters('dt1$d;dt2$d', [IncMonth(Date, -2), IncDay(Date, S.IIf(Cth.GetControlValue(Fr, 'ChbFilter2') = 1, +7, +0))]);
  end;
  //������ ���������� ������
  //���������� ������ �� ����� ���������� ������, � �� ��������� ��� ���� ����������
  SqlWhere := A.ImplodeNotEmpty([
    S.IIfStr(Cth.GetControlValue(Fr, 'ChbNoClosed') = 1, 'dt_end is null'),
    S.IIfStr(Cth.GetControlValue(Fr, 'ChbInProd') = 1, 'qnt_in_prod <> 0'),
    SqlWhere
    ]
    , ' and '
  );
  Frg1.Opt.SetColFeature('1', 'i', Cth.GetControlValue(Frg1, 'ChbViewSum') = 0, False);
end;

procedure TFrmOGjrnOrders.Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
//��������� ������ � ������ ����� ��� �����
var
  i: Integer;
  NewValue: Variant;
begin
  if UseText then NewValue:=Text else NewValue:=Value;
  //������ ������ (���� �� ��������)
  if (Fr.CurrField = 'cancel') then begin
    //������� ����������, ���� ���� �� ��������� ���� �� �������� �������� ��������� ����� �� ��� ����
    Handled := True;
    //Fr.MemTableEh1.Cancel; //�� �����������
    //���������� ������
    if not Fr.RefreshRecord then Exit;
    //������ �������� �����������
    if Fr.GetValue('dt_end') <> null then Exit;
    //����� ������������� �� ����������� �������� ���� �������, ����������� ���
    i:=S.NInt(Fr.GetValue);
//    i:=S.NInt(Value);
    if i = 0 then
      if MyQuestionMessage('�������� �����'#10#13'('+Fr.GetValue('ornum')+') ?') <> mrYes then Exit;
    if i = 1 then
      if MyQuestionMessage('������� � ������ �����'#10#13'('+Fr.GetValue('ornum')+') ?') <> mrYes then Exit;
    Q.QExecSql(
      'update orders set dt_cancel=:dt_cancel$d where id=:id$i',
      [S.IIf(i = 1, null, Date), Fr.ID], False
    );
    if i = 0 then Orders.FinalizeOrder(Fr.ID, myOrFinalizeManual);
    Fr.RefreshRecord;
  end;
end;

procedure TFrmOGjrnOrders.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
  if not Fr.IsPrepared then
    Exit;
  if TControl(Sender).Name = 'ChbViewSum' then begin
    Frg1.Opt.SetColFeature('1', 'i', Cth.GetControlValue(Fr, 'ChbViewSum') = 0, False);
    Frg1.SetColumnsVisible;
    Frg2.Opt.SetColFeature('1', 'i', Cth.GetControlValue(Fr, 'ChbViewSum') = 0, False);
    Frg2.SetColumnsVisible;
  end
  else if A.InArray(TControl(Sender).Name, ['ChbFilter1', 'ChbFilter2']) then begin
    //��� ������� ������������� ������� ������ ��� ������� � ��������
    Gh.GridFilterClear(Fr.DbGridEh1, true, False);
    Frg1.RefreshGrid;
  end
  else Frg1.RefreshGrid;
end;

procedure TFrmOGjrnOrders.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if (FieldName = 'ornum') and (Fr.GetValue('dt_end') = null)
    then Params.Background:=clSkyBlue;
  if (FieldName = 'ornum') and (Fr.GetValue('id_itm') = null) then begin
    Params.Font.Color:=clBlue;
    Params.Font.Style := [fsUnderline];
  end;
  if (FieldName = 'pay') and
     (Fr.GetValue('pay') <> null)and(Fr.GetValue('cost') <> null) and
     (S.NNum(Fr.GetValue('pay')) = S.NNum(Fr.GetValue('cost'))) and
     (S.NNum(Fr.GetValue('cost')) <> 0)
    then Params.Background:=clMoneyGreen;
  //��������� ������, �� ������� ���� ��� ����� � �����, �� �� ��� ���� � ���
  //(���� ��������� ������� �� ������ �������� � ���, �� ��� ������ ��������� �������������� � ��������� ��-�� ���� �� �����)
  if (FieldName = 'estimates') and (Fr.GetValue('estimates') = '+') and (VarToDateTime(Fr.GetValue('dt_beg')) >= EncodeDate(2025, 01, 01)) and (Fr.GetValue('has_itm_est') = 0)
    then Params.Background:=clmyPink;
  //��������� ���������� ���������������� ������� �������, � ��������� �������.
  if (FieldName = 'early_or_late') then
    if (Fr.GetValueI('early_or_late') > 0)
      then Params.Background:=clmyPink
      else if (Fr.GetValueI('early_or_late') < 0)
        then Params.Background:=clmyGreen
          else if (Fr.GetValue('early_or_late') = 0)
          then Params.Background:=clmyBlue;
end;

procedure TFrmOGjrnOrders.Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
end;

procedure TFrmOGjrnOrders.Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
end;


{��������� ����}

procedure TFrmOGjrnOrders.Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  //� ��� ��� �����, ������� ����� ��� ������ ������
//  if MemTableEh2.RecordCount = 0 then Exit;
  case Tag of
    mbtTest:
      begin
        Fr.SetState(True, True, null);
//        Fr.SetState(True, True, '������!');
      end;
    mbtCustom_OrToDevel:
      begin
//        Fr.SetState(False, False, null);
        Orders.OrderItemsToDevel(null, Fr.ID);
      end;
    mbtViewEstimate: //�������� �����
      begin
        Wh.ExecReference(myfrm_R_Estimate, Self, [myfoDialog, myfoMultiCopyWoId, myfoSizeable, myfoEnableMaximize], VarArrayOf([Fr.ID, null]));
      end;
    mbtLoadEstimate: //�������� ����� �� �������
      begin
        Orders.LoadBcadGroups(True);
        Orders.LoadEstimate(null, Fr.ID, null);
        Fr.RefreshRecord;
        Fr.SetState(True, null, null);
      end;
    mbtCopyEstimate:
      begin
        Orders.CopyEstimateToBuffer(null, fr.ID);
      end;
    mbtCustom_Order_AttachThnDoc:
      begin
        if Orders.IsOrderFinalized(Frg1.ID, True, cOrItmStatus_Completed) >= cOrItmStatus_Completed then
          Exit;
        if Orders.TaskForSendThnDocuments(Fr.ID) then begin
          Fr.RefreshRecord;
          Fr.SetState(True, null, null);
        end;
      end;
    1002:
      begin
        if Orders.IsOrderFinalized(Frg1.ID, True, cOrItmStatus_Completed) >= cOrItmStatus_Completed then
          Exit;
        if Orders.TaskForSendThnDocuments(Fr.ID, False) then begin
          Fr.RefreshRecord;
          Fr.SetState(True, null, null);
        end;
      end;
    1001:
      begin
        TFrmOGrefOrStdItems.GoToItem(Fr.GetValue('id_std_item'));
      end
    else inherited;
  end;
end;

procedure TFrmOGjrnOrders.Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  Fr.SetSqlParameters('id_order$i', [Frg1.ID]);
  Fr.Opt.Caption := '����� ' + Frg1.GetValueS('ornum');
  Frg2.Opt.SetColFeature('sum0', 'null', not TFrmXDedtGridFilter.GetChb(Frg1, 'Sum0') , False);
end;

procedure TFrmOGjrnOrders.Frg2ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  //��������� ������ � ����� �����
  if (FieldName = 'dt_estimate') and (Fr.GetValue('qnt') <> 0) then begin
    if (Fr.GetValue('dt_estimate') = null)
      //�� ��������� - ������
      then Params.Background := clmyYelow
      else if (Fr.GetValue('id_itm') <> null) and (Fr.GetValue('has_itm_est') = null)
        //��������� � ����� �� �� ������� � ���, ��� ��� ��� ������� � ����� � ��� �������� - �������
        then Params.Background := clmyPink;
  end;
end;
{
�������������� �������
}

function TFrmOGjrnOrders.OpenFromTemplate: Integer;
var
  va: TvarDynArray;
  van, vaid: TvarDynArray;
  va2: TVarDynArray2;
  i: Integer;
begin
  va2:= Q.QLoadToVarDynArray2('select templatename from v_orders where id <= -1 order by templatename asc', []);
  if Length(va2) = 0
    then begin MyInfoMessage('�� ������� �� ������ �������!'); Exit; end;
  van:=A.VarDynArray2ColToVD1(va2, 0);
  vaid:=A.VarDynArray2ColToVD1(Q.QLoadToVarDynArray2('select id from v_orders where id <= -1 order by templatename asc', []), 0);
  if TFrmBasicInput.ShowDialog(Self, '', [], fAdd, '~������ ������', 820, 85, [
//  if Dlg_BasicInput.ShowDialog(Self, '������� ����� �� �������', 820, 85, fAdd, [
    [cntComboLK, '������ ������','1:500:0']
   ],
   [
     VarArrayOf(['0', VarArrayOf(van), VarArrayOf(vaid)])
   ],
   va,
   [['']],
   nil
  ) < 0
  then Exit;
  Wh.ExecDialog(myfrm_Dlg_Order, Self, [], fCopy, va[0], null);
end;

procedure TFrmOGjrnOrders.ViewInfo1;
begin
  var Ids: TVarDynArray2 := Gh.GetGridArrayOfChecked(Frg1.DBGridEh1, Frg1.DBGridEh1.FindFieldColumn(Frg1.Opt.Sql.IdField).Index);
end;



end.
