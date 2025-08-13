unit uFrmOGjrnSemiproducts;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uData, uFrmBasicMdi, uString, uFrDBGridEh, uFrmBasicGrid2
  ;

type
  TFrmOGjrnSemiproducts = class(TFrmBasicGrid2)
    procedure Frg1DbGridEh1DrawDataCell(Sender: TObject; const Rect: TRect; Field: TField; State: TGridDrawState);
    procedure Frg1DbGridEh1DataGroupGetRowText(Sender: TCustomDBGridEh; GroupDataTreeNode: TGroupDataTreeNodeEh; var GroupRowText: string);
    procedure Frg1DbGridEh1DataGroupGetRowParams(Sender: TCustomDBGridEh; GroupDataTreeNode: TGroupDataTreeNodeEh; Params: TGroupRowParamsEh);
    procedure Frg1DbGridEh1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Frg1DbGridEh1ApplyFilter(Sender: TObject);
  private
    //���������� ������� � ��������� (��������� ����������)
    FQntOrdersToDemand: Integer;
    //������ ������� � ��������� (��� ���� �� ���� ������� ���������)
    FOrdersToDemand: TVarDynArray;
    //������, ����� ������������ (���� ���������� � ������� ������������ ������� �� ����� ������)
    FOrdersProcessed: TVarDynArray;
    //������, ������� ���� ����������, � � ��� ��� ���������� ��� ������ ������� � ������ ���������
    //(�� ������� ����, ���� ������� �� ������ ���� �������!))
    FOrdersModifyed: TVarDynArray;
    //�� ��, �� ������ � ������
    FOrderItemsModifyed: TVarDynArray;
    //������, �� ������� ������ ������� ��, �.�. �� ������� ��������� ��� �� ����������� ������ �� ���. ��������, �������������� ��������������
    FOrdersWithErrors: TVarDynArray;
    //�������� ������, ������� ������������ �� ������� ������ ������� � Save
    FOrdersTreated: TVarDynArray;
    //���������������� ������, ������� ���� ������� �� �������� � Save
    FOrdersCreated: TVarDynArray;
    FInSaveData: Boolean;
    function  PrepareForm: Boolean; override;
    procedure LoadData;
    procedure VerifyTable(RecNo: Integer = MaxInt);
    procedure SetQntForChecked;
    function  GetDataForSemiproducts: Boolean;
    procedure TreatOrder(OrNum : string);
    function  Save: Boolean;
  protected
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    procedure Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string); override;
  public
  end;

var
  FrmOGjrnSemiproducts: TFrmOGjrnSemiproducts;

implementation

uses
  uSettings,
  uSys,
  uForms,
  uDBOra,
  uMessages,
  uWindows,
  uOrders,
  uPrintReport,
  uFrmXDedtGridFilter,
  uFrmBasicInput,
  uFrmODedtNomenclFiles
  ;


{$R *.dfm}

function TFrmOGjrnSemiproducts.PrepareForm: Boolean;
var
  c : TComponent;
  va2: TVarDynArray2;
  st: string;
begin
  Caption:='~������ �� �������������';
  //��������� ����� ����������, ���� ����� fEdit (�������� ��� ������ ����������� ������ �� ���� �������)
  //���� ����� �� ��������������, � ������ ������ �������������, �� fMode := fView
  FormDbLock;
  //��� ������� ������� �����, ���� ������� ������, ����� ������
  FOpt.RequestWhereClose := cqYN;

  Frg1.Options := Frg1.Options + [myogIndicatorCheckBoxes, myogMultiSelect, myogLoadAfterVisible];
  Frg1.Opt.SetFields([
    ['id$i','_id','d=40'],
    ['id_order$i','_id_order_item','d=40'],
    ['id_order_item$i','_id_order_item','d=40'],
    ['id_nomencl$i','_id_nomencl','d=40'],
    ['id_unit$i','_id_unitl','d=40'],
    ['dt_beg$d','_dt_otgr','d=40'],
    ['dt_otgr$d','_dt_otgr','d=40'],
    ['filter$i','_filter','d=40'],
    ['ornum$s','_� ������','80','bt=������� ����� ������:4',False],
    ['project$s','_������','150'],
    ['slash$s','_����','150'],
    ['itemname$s','_�������','200'],
    ['ordercaption$s','�����','d=200;h'],
    ['itemcaption$s','�������','d=200;h'],
    ['name$s','������������','d=200;h'],
    ['qnt_in_order$f','���-�� � ������','80'],
    ['qnt_in_order_diff$f','���������','80'],
    ['qnt_in_demand$i','���-�� � �������','80', 'e=0:999999:0', 'i', Mode = FView],
    ['qnt_in_demand_old$i','�������� �����','80'],
    ['need_curr$f','����������� � ������ �����','80', 'i', Mode = FView],
    ['need$f','����������� �� ��� ������','80'],
    ['qnt_onway$f','� ����','80'],
    ['qnt_on_stock$f','������� �������','80'],
    ['qnt_nin$f','���. �������','80'],
    ['has_files$i','�����','40','pic'],
    ['id_std_item$i','_id_std_item','d=40'],
    ['id_template$i','_id_template','d=40'],
    ['has_estimate$i','_has_estimate','d=40']
  ]);
  Frg1.Opt.SetTable('v_semiproducts_srcorders');

  Frg1.CreateAddControls('1', cntComboLK, '�������������', 'CbType', '', 90, yrefC, 150);
  Cth.AddToComboBoxEh(TDBComboBoxEh(Frg1.FindComponent('CbType')),
    [['������', '6212'], ['������', '2770999']],
    False
  );

  Frg1.CreateAddControls('1', cntCheck, '���', 'ChbViewAll', '', 90 + 150 + 10, yrefC, 40);
  Frg1.CreateAddControls('1', cntCheck, '�����', 'ChbViewNew', '', -1, yrefC, 55);
  Frg1.CreateAddControls('1', cntCheck, '����������', 'ChbViewChanged', '', -1, yrefC, 85);
  Frg1.CreateAddControls('1', cntCheck, '�����������', 'ChbViewCompleted', '', -1, yrefC, 90);
  Frg1.CreateAddControls('1', cntCheck, '������ � ������������', 'ChbViewNeededOnly', '', -1, yrefC, 150);
  Frg1.ReadControlValues;
  TDBCheckBoxEh(Frg1.FindComponent('ChbViewAll')).Checked := True;
  TDBCheckBoxEh(Frg1.FindComponent('ChbViewNew')).Checked := True;
  TDBCheckBoxEh(Frg1.FindComponent('ChbViewChanged')).Checked := True;
  TDBCheckBoxEh(Frg1.FindComponent('ChbViewCompleted')).Checked := True;
  TDBCheckBoxEh(Frg1.FindComponent('ChbViewNeededOnly')).Checked := False;


  Frg1.Opt.SetButtons(1, [
   [1000, True, -90, '�����������', 'grouping'], [1001, True, '�������� ���', 'expand'], [1002, True, '��������� ���', 'collapse'], [],
   [1003, Mode = FEdit, '��������� ���������', 'ok_double'], [],
   [mbtGo, Mode = FEdit, '������������ ��������'], [], [mbtCtlPanel]
  ]);

  //������ ����������� (������� �����, ������ ������������ ����� ����������, ������� � ������ ���� - ����� ���� �������), � ���������� �����������.
  Frg1.Opt.SetGrouping(['ordercaption', 'itemcaption'], [], [clGradientActiveCaption, clGradientInactiveCaption], True{Cth.GetControlValue(Frg1, 'ChbGrouping') = 1});

  Frg1.InfoArray:=[
    [Caption + '.'#13#10]
  ];
  Frg1.Opt.SetDataMode(myogdmFromArray);
  Frg1.Prepare;

  Frg1.Opt.SetColFeature('qnt_in_demand', 'e', Frg1.DbGridEh1.DataGrouping.Active, True);
  TSpeedButton(TPanel(Frg1.FindComponent('pnlTopBtns')).Controls[0]).Down := Frg1.DbGridEh1.DataGrouping.Active;
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, 1001, null, Frg1.DbGridEh1.DataGrouping.Active);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, 1002, null, Frg1.DbGridEh1.DataGrouping.Active);

  LoadData;

  //st:=Frg1.pmgrid.Items[0].Owner.Name;

  Result := True;
end;

procedure TFrmOGjrnSemiproducts.Frg1DbGridEh1ApplyFilter(Sender: TObject);
//���������� �����
//������ ��������� �� �������� ������� � ����������� �� ���������, ��������,
//������ � ����� ������� ���� ����������.
//������ � ����� ������������� �� ������� � ������ �������� � � ������
var
  st: string;
  i, j: Integer;
  va: TVarDynArray;
begin
  va := [9];
  st := 'in (9';
  If Cth.GetControlValue(Frg1, 'ChbViewNew') = 1 then
    va := va + [0];
  If Cth.GetControlValue(Frg1, 'ChbViewChanged') = 1 then
    va := va + [2];
  If Cth.GetControlValue(Frg1, 'ChbViewCompleted') = 1 then
    va := va + [1];
  If Cth.GetControlValue(Frg1, 'ChbViewNeededOnly') <> 1 then begin
    for i := High(va) downto 0 do
      va := va + [va[i] + 10];
  end;
  st := 'in ( ' + A.Implode(va, ',') + ')';
  Gh.GetGridColumn(Frg1.DBGridEh1, 'filter').STFilter.ExpressionStr := st;
  Frg1.DBGridEh1.DefaultApplyFilter;
end;

procedure TFrmOGjrnSemiproducts.Frg1DbGridEh1DataGroupGetRowParams(
  Sender: TCustomDBGridEh; GroupDataTreeNode: TGroupDataTreeNodeEh;
  Params: TGroupRowParamsEh);
//��������� ������ ����������� �����
var
  st, ornum: string;
  va: TVarDynArray;
begin
  inherited;
  //��������� ������ � ����������� �� ������� ������ ���� �����
  va := A.Explode(Params.GroupRowText, ' ');
  if (High(va) >= 1) and A.InArray(va[1], FOrdersModifyed)
    then Params.Font.Color := clBlue
    else if (High(va) >= 1) and A.InArray(va[1], FOrdersProcessed)
      then Params.Font.Color := clGreen;
  if (High(va) >= 1) and A.InArray(va[1], FOrderItemsModifyed)
    then Params.Font.Color := clBlue;
end;

procedure TFrmOGjrnSemiproducts.Frg1DbGridEh1DataGroupGetRowText(
  Sender: TCustomDBGridEh; GroupDataTreeNode: TGroupDataTreeNodeEh;
  var GroupRowText: string);
//��������� ����� ���������� �����
var
  va: TVarDynArray;
begin
  inherited;
//  GroupRowText := GroupRowText + ' [' + DateToStr(VarToDateTime(Frg1.GetValue('dt_otgr')))+ ']';
  //������� ��������� ������� � ����� ������ ��� ���������� ������� -
  //�������� ������ ��� ������� ��������� �� ������� ������
  va := A.Explode(GroupRowText, ' ');
  if (High(va) >= 1) and A.InArray(va[1], FOrdersToDemand) then
    if Pos(va[1], Frg1.ErrorMessage) > 0
      then GroupRowText := GroupRowText + '     (����)'
      else GroupRowText := GroupRowText + '     (������ �������)';
end;

procedure TFrmOGjrnSemiproducts.Frg1DbGridEh1DrawDataCell(Sender: TObject;
  const Rect: TRect; Field: TField; State: TGridDrawState);
begin
  inherited;
  //
end;

procedure TFrmOGjrnSemiproducts.Frg1DbGridEh1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
//������� �������
var
  st: string;
begin
  if FInSaveData then
    Exit;
  Frg1.DbGridEh1KeyDown(Sender, Key, Shift);
  if Frg1.DbGridEh1.DataGrouping.Active and (Frg1.CurrField = 'qnt_in_demand') and (Key = 16{VK_LSHIFT}) then begin
    //� ������� � ������� �� ������ ����� - ������ ����������, ������� � ������, � ��������� �� ������ ����
    Frg1.MemTableEh1.Edit;
    Frg1.SetValue('qnt_in_demand', Frg1.GetValue('qnt_in_order'));
    //���� ��� ������� ������
    st := Frg1.GetValue('slash');
    //�����������/�������� ������ � �������
    VerifyTable(Frg1.RecNo);
    //�������� ����
    Frg1.MemTableEh1.Next;
    //���� ���� ���������, �������� ����� - �� ���� ����� ������� ����� (����� - �����������) - �� ���������!
    if st <> Frg1.GetValue('slash') then
      Frg1.MemTableEh1.Prior;
  end;
  if Frg1.DbGridEh1.DataGrouping.Active and (Key = VK_F4) then begin
    Gh.RootGroupExpandCollapse(Frg1.DbGridEh1, 0);
  end;
end;

procedure TFrmOGjrnSemiproducts.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
//��������� ������� ������/����
begin
  if FInSaveData then
    Exit;
  if Tag = mbtGo then
    //�������� ������, �������� ������ � ������ (���� ��� ��������)
    Save;
  if Tag = 1000 then begin
    //������ ����������, �� �������� ������/������ (�������� �������������, �� �� ���������)
    //����������� ������ �����������
    Fr.DbGridEh1.DataGrouping.Active := not Fr.DbGridEh1.DataGrouping.Active;
    //��������� �������������� ������ � ������ �����������
    Fr.Opt.SetColFeature('qnt_in_demand', 'e', Fr.DbGridEh1.DataGrouping.Active, True);
    Fr.ChangeSelectedData;
  end;
  if Tag = 1001 then begin
    //�������� ��� ������ �� ���� �������
    Gh.AllGroupsExpandCollapse(Fr.DbGridEh1, 1, True);
  end;
  if Tag = 1002 then begin
    //�������� ��� ������ �� ���� �������
    Gh.AllGroupsExpandCollapse(Fr.DbGridEh1, 1, False);
  end;
  if Tag = 1003 then
    //��������� ��������� � �������, ������ ����, ��� � ������, ��� ���� ���������� �������
    SetQntForChecked;
end;

procedure TFrmOGjrnSemiproducts.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
//��������� ������ � ������ ���� ������ � ������� ������
begin
  inherited;
  //����������� ������� ��������/����������� - ������ � ������ ����������
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, 1001, null, Fr.DbGridEh1.DataGrouping.Active);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, 1002, null, Fr.DbGridEh1.DataGrouping.Active);
  //����������� ������ ���� ��� ���������� - ��� ����������� � ���� ���� ���������� �������� � ����������
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, 1003, null, Fr.DbGridEh1.DataGrouping.Active and (Frg1.DbGridEh1.SelectedRows.Count > 0));
  //����������� ������ ������������
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtGo, null, Fr.DbGridEh1.DataGrouping.Active);
end;


procedure TFrmOGjrnSemiproducts.Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
//������ ���� � ������
begin
exit;
  if not S.IsInt(Value) then Value := null;
  Frg1.SetValue('', Value);
//Frg1.setvalue('name',0,False,Frg1.GetValue);
  VerifyTable(Frg1.RecNo);
  Handled := True;
end;

procedure TFrmOGjrnSemiproducts.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if (FieldName = 'need') and (S.NNum(Fr.GetValue(FieldName)) < 0) then
    Params.Background := clmyGreen;
end;

procedure TFrmOGjrnSemiproducts.Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
  if (Fr.CurrField = 'has_files')and(Fr.GetValue = 1) then
    TFrmODedtNomenclFiles.ShowDialog(Self, Fr.GetValue('id_nomencl'));
end;

procedure TFrmOGjrnSemiproducts.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
//��������� ��������� ��������� � ������� ������
var
  st: string;
begin
  //������ �� ����� ��������
  if not Fr.IsPrepared then
    Exit;
  //������ ���� ��� � ���� �������
  if Fr.InAddControlChange then
    Exit;
  if FInSaveData then
    Exit;
  Fr.InAddControlChange := True;
  if TControl(Sender).Name = 'CbType' then begin
    //����� ���� ������������� - �������� ������
    LoadData;
    Fr.ChangeSelectedData;
  end;
  if TControl(Sender).Name = 'ChbViewAll' then begin
    //����� ��� - ��������� ��� ����� ����������� �� �������� �������
    Cth.SetControlValue(Frg1, 'ChbViewNew', 1);
    Cth.SetControlValue(Frg1, 'ChbViewChanged', 1);
    Cth.SetControlValue(Frg1, 'ChbViewCompleted', 1);
  end;
  if A.InArray(TControl(Sender).Name, ['ChbViewNew', 'ChbViewChanged', 'ChbViewCompleted']) then
    //����� �� �������� ������� - ���� ��� �����������, �� ��� ������ �����
    TDBCheckBoxEh(Fr.FindComponent('ChbViewAll')).Checked :=
      (Cth.GetControlValue(Frg1, 'ChbViewNew') + Cth.GetControlValue(Frg1, 'ChbViewChanged') + Cth.GetControlValue(Frg1, 'ChbViewCompleted')) = 3;
  if A.InArray(TControl(Sender).Name, ['ChbViewAll', 'ChbViewNew', 'ChbViewChanged', 'ChbViewCompleted', 'ChbViewNeededOnly']) then
    //��� ����� ����� ��������� ������� �� �������� - ������� ������� ������� (�� DefaulApplyFilter !)
    Frg1DbGridEh1ApplyFilter(Fr.DbGridEh1);
  Fr.InAddControlChange := False;
end;

procedure TFrmOGjrnSemiproducts.Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string);
begin
  if Mode = dbgvBefore then
    Exit;
  VerifyTable(Row);
end;


procedure TFrmOGjrnSemiproducts.SetQntForChecked;
//��������� ���������� � ������� ��� ���������� � ���������� ������� (���� ���� � ����� �������)
var
  i, j: Integer;
  va2: TVarDynArray2;
begin
  if not Frg1.DbGridEh1.DataGrouping.Active then
    Exit;
  if Frg1.DbGridEh1.SelectedRows.Count = 0 then
    Exit;
  //������ ����� ����������� �� ����� � ���������������� �������, �� ���������������� ������� ����������!
  j := MyMessageDlg('���������� ���������� ��� ��������� �������?', mtConfirmation, [mbYesToAll, mbAbort, mbNo, mbOk, mbCancel], '�����;�����������;����;������;������');
  //7,1,2,3 myinfomessage(inttostr(j)); exit;
  if j = 14 then
    Exit;
  va2 := Gh.GetGridArrayOfChecked(Frg1.DbGridEh1, 0);
  for i := 0 to Frg1.GetCount(False) - 1 do
    if A.PosInArray(Frg1.GetValue('id', i, False), va2, 0) >= 0 then begin
      if j = 7
        then Frg1.SetValue('qnt_in_demand', i, False, Frg1.GetValue('qnt_in_order', i, False))
        else if j = 2 then Frg1.SetValue('qnt_in_demand', i, False, 0)
          else if j = 3 then Frg1.SetValue('qnt_in_demand', i, False, null)
          else begin
            if S.NNum(Frg1.GetValue('need', i, False)) < 0
              then Frg1.SetValue('qnt_in_demand', i, False, Frg1.GetValue('qnt_in_order', i, False))
              else Frg1.SetValue('qnt_in_demand', i, False, 0);
          end;
      VerifyTable(-i);
    end;
end;

procedure TFrmOGjrnSemiproducts.VerifyTable(RecNo: Integer = MaxInt);
//�������� �������
//����� �� �������� ������ �������, �� ������� ������� ������, � ������ ��������� �����
//���� �������� RecNo, �� ������������ ������� ����������� ��� ������� � ������������� � ������ ������,
//� ������ ���������� �� ���� �������� � ������ ������������� ���������� � ������
//���� RecNo ������������, �� ��� MemTableEh1.RecNo, ����� ��� ������ � ��������������� �������
var
  i ,j, k, m, n: Integer;
  st, err: string;
  b1, b2: Boolean;
  e: Extended;
begin
  //� ������ ��� ����������� ���� ��������, � �������� � ��������� ����� �� ������
  //(�������� �������� �� ��� ��� ������ �������������� �� ������ ������, ��� ��� ����� ��� �����������)
  if not Frg1.DbGridEh1.DataGrouping.Active then
    Exit;
  st := '';
  err := '';
  m := 0;
  FQntOrdersToDemand := 0;  //������� ������� � ������
  FOrdersToDemand := [];
  for i := 0 to Frg1.GetCount(False) do begin
    if (i = Frg1.GetCount(False)) or (st <> Frg1.GetValue('ornum', i, False)) then begin
      if st <> '' then begin
        //��� �������� �� ������ �����
        if (j <> 0) then
          //������ � ��������� (��� ����-�� ���-�� �������)
          FOrdersToDemand := FOrdersToDemand + [st];
        if (j <> 0) and (j <> k) then
          //���� ������� ���������� ���� �� ����, �� �� �� ���� �������� - ����� ������ � ����� ������
          S.ConcatStP(err, st, ', ');
        if j = k then
          //���� ������� �� ���� - �������� ���������� ������� � ������������
          inc(FQntOrdersToDemand);
      end;
      if i = Frg1.GetCount(False) then
        Break;
      st := Frg1.GetValue('ornum', i, False);
      j := 0;
      k := 0;
    end;
    if Frg1.GetValue('qnt_in_demand' ,i, False) <> null then
      inc(j);
    inc(k);
  end;
  //��������� ������
  //���������� ��������� ������� ������� ��� ������, ������ � �� ��������� ��������� - ����������� ����������� ������
  Frg1.SetState(Length(FOrdersToDemand) > 0, err <> '', S.IIfStr(err <> '', '������ �� ��������� ������� ��������� �� ���������:'#13#10 + err));

  //��������� ����������� - ������� � ������������� ����������� �� ������ ������������ ��������� ����������
  //(�� ����������� ������������)
  if RecNo <> MaxInt then begin
    //�� ������� ������ (��� �����) ��� �� ����������� �������
    if RecNo > 0
      then st := Frg1.GetValue('name')
      else st := Frg1.GetValue('name', -RecNo, False);
    if RecNo > 0
      then e := Frg1.GetValue('need')
      else e := Frg1.GetValue('need', -RecNo, False);
    for i := 0 to Frg1.GetCount(False) - 1 do
      if Frg1.GetValue('name' ,i, False) = st then
        e := e + S.NNum(Frg1.GetValue('qnt_in_demand' ,i, False));
    for i := 0 to Frg1.GetCount(False) - 1 do
      if Frg1.GetValue('name' ,i, False) = st then
        Frg1.SetValue('need_curr', i, False, e);
  end;
  //����� ���� ������������� ��������, ���� ������ ��� ��������� ������ � ����� � ������
  TDBComboBoxEh(Frg1.FindComponent('CbType')).Enabled := Length(FOrdersToDemand) = 0;
end;


procedure TFrmOGjrnSemiproducts.LoadData;
//�������� ������
//�������� ��������� ������� - ������ �� �������, � ������� ���� �� �� ������� � ������� ��������� � ������� ���
var
  va: TVarDynArray;
  va2: TVarDynArray2;
  i, j: Integer;
  b: Boolean;
  st: string;
begin
  Frg1.BeginOperation('�������� ������');
  //���� ���������� - � ���������� ���������
  Q.QSetContextValue('semiproduct_supplier', Cth.GetControlValue(Frg1, 'CbType'));
  //������ �������� ������
  va2 := Q.QLoadToVarDynArray2(
    'select id, id_order, id_order_item, id_nomencl, id_unit, dt_beg, dt_otgr, null as filter, '+
    'ornum, project, slash, itemname, ordercaption, itemcaption, name, '+
    'qnt_in_order, qnt_in_order_diff, null as qnt_in_demand, qnt_in_demand_old, '+
    'need as need_curr, need, qnt_on_stock, qnt_nin, has_files '+
    'from v_semiproducts_srcorders '+
    S.IIFStr(S.NSt(Cth.GetControlValue(Frg1, 'CbType')) = '', 'where 1 = 2 ', '')+
    'order by ornum, slash',
    []
  );
//  Frg1.DbGridEh1.DataGrouping.Active := False;
  //����� ��������� ������� ������� � ������� �������� � ����������
  //����� ����� �������� ���������� ������ ���������
  //(�������� ���������� �� �����������)
  if Frg1.GetCount(False) > 0 then begin
    b := True;
    Gh.GridFilterClear(Frg1.DbGridEh1);
    //������-�� ��������� ��������� ���������, ���� ������ �������� DisableControls;
    //��� ������ �� ����� �������� ��������/������ ����� ��������� �� ��������
    //������������� ��� ��� ��-�� BeginOperation �� ��������������!
    if Frg1.DbGridEh1.SelectedRows.Count > 0 then
      Gh.SetGridIndicatorSelection(Frg1.DbGridEh1, -1);
  end;
  //�������� ������ � ��������
  Frg1.LoadSourceDataFromArray(va2, '', '', True);
  //������� ������ ������� - ��� ������������, ������� ���� ��������, � �����, ������� ���� ��������
  FOrdersProcessed := [];
  FOrdersModifyed := [];
  FOrderItemsModifyed := [];
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    if S.Nst(Frg1.GetValue('qnt_in_demand_old', i, False)) <> '' then
      FOrdersProcessed := FOrdersProcessed + [Frg1.GetValue('ornum', i, False)];
    if S.Nst(Frg1.GetValue('qnt_in_order_diff', i, False)) <> '' then begin
      FOrdersModifyed := FOrdersModifyed + [Frg1.GetValue('ornum', i, False)];
      FOrderItemsModifyed := FOrderItemsModifyed + [Frg1.GetValue('slash', i, False)];
    end;
  end;
  //������� ������ � ������������.
  va := [];
  for i := 0 to Frg1.GetCount(False) - 1 do
    if S.NNum(Frg1.GetValue('need', i, False)) < 0 then
      va := va + [Frg1.GetValue('ornum', i, False)];
  //��������� �������� � ��������� ������� ��� ���������� ������� �� ���� ������
  //(�����, ���������, �������), � ���� ��� ���� �� ������ �� ����� ������� ���� �����������
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    if A.InArray(Frg1.GetValue('ornum', i, False), FOrdersModifyed)
      then j := 2
      else if A.InArray(Frg1.GetValue('ornum', i, False), FOrdersProcessed)
        then j := 1
        else j := 0;
    if not A.InArray(Frg1.GetValue('ornum', i, False), va) then
      j := 10 + j;
    Frg1.SetValue('filter', i, False, j)
  end;
  VerifyTable;
  //�������� ���������� ������� �� ���� ������
  //���� ����� ������� ��� ������, �� �� �����-�� �������, ���� ������ ����������� ������ � ������� �����������,
  //�� ��� ������ ����������� ������ �������� � ������� �����!
  if b then
    Frg1DbGridEh1ApplyFilter(Frg1.DbGridEh1);
  //���������� �����������
//  Frg1.MemTableEh1.DisableControls;
  Frg1.DbGridEh1.DataGrouping.Active := True;
//  Frg1.MemTableEh1.EnableControls;
  //������� ����� ���
  Frg1.EndOperation;
  //���������� ����, ����� �� ����� ��������� �������, ���� � ���� �� �������� �����
  Frg1.DbGridEh1.Repaint;
end;

function TFrmOGjrnSemiproducts.Save: Boolean;
var
  i, j: Integer;
  v: Variant;
  b: Boolean;
begin
  if Frg1.ErrorMessage <> '' then begin
    MyWarningMessage(Frg1.ErrorMessage);
    Exit;
  end;
  if FQntOrdersToDemand = 0 then begin
    MyWarningMessage('��� ������� ��� ���������!');
    Exit;
  end;
  if MyQuestionMessage('������������ ������ � �������� �� ' + S.GetEndingFull(FQntOrdersToDemand, '�����', '�', '��', '��') + '?') <> mrYes then
    Exit;

  FInSaveData := True;

  FOrdersTreated := [];
  FOrdersCreated := [];

  FDisableClose := True;
  Enabled := False;
  Frg1.BeginOperation;
  try
    b := GetDataForSemiproducts;
    if b then
      for i := 0 to High(FOrdersToDemand) do begin
        if not A.InArray(FOrdersToDemand[i], FOrdersWithErrors) then
          TreatOrder(FOrdersToDemand[i]);
      end;
  except on E: Exception do
    begin
      FDisableClose := False;
      Application.ShowException(E);
    end;
  end;
  Frg1.EndOperation;
  FDisableClose := False;
  Enabled := True;
  if b then
    MyInfoMessage('������!');

  FInSaveData := False;
  if b then
    LoadData;
end;

procedure TFrmOGjrnSemiproducts.TreatOrder(OrNum : string);
//���������� ����� � ���������� �������
//(�������� ������ �� ���� � ������� ��������� �� ��������������, �������� ������ ��, �������� ���������������� ��)
var
  rb, re, o, i, j: Integer;
  PfArr: TVarDynArray2;
  IdO: Integer;
  DtO: TDateTime;
  StO: string;
  Err: Boolean;
  Lock: TVarDynArray;

  function GetPfArr: Boolean;
  var
    i, j: Integer;
  begin
    Result := False;
    PfArr := [];
    for i := rb to re do begin
      if S.NNum(Frg1.GetValue('qnt_in_demand', i, False)) = 0 then
        Continue;
      for j := 0 to High(PfArr) do
        if PfArr[j][0] = Frg1.GetValue('id_nomencl', i, False) then begin
          PfArr[j][1] := PfArr[j][1] + Frg1.GetValue('qnt_in_demand', i, False);
          Break;
        end;
      if (j <= High(PfArr)) and (High(PfArr) >= 0) then
        Continue;
      PfArr := PfArr + [[Frg1.GetValue('id_nomencl', i, False), Frg1.GetValue('qnt_in_demand', i, False), Frg1.GetValue('id_unit', i, False), 0]];
    end;
    Result := True;
  end;


  function SaveMtTable: Boolean;
  var
    i: Integer;
  begin
    Result := False;
    for i := rb to re do begin
      if Frg1.GetValue('qnt_in_demand' ,i, False) <> null then begin
        Q.QExecSql(
          'delete from j_semiproducts_src where '+
          'id_supplier = :id_supplier$i and id_order = :id_order$i and id_order_item = :id_order_item$i and id_nomencl = :id_nomencl$i',
          [Cth.GetControlValue(Frg1, 'CbType'), Frg1.GetValue('id_order', i, False), Frg1.GetValue('id_order_item', i, False), Frg1.GetValue('id_nomencl', i, False)]
        );
        Q.QExecSql(
          'insert into j_semiproducts_src (id_supplier, id_order, id_order_item, id_nomencl, qnt_in_order, qnt_in_demand) '+
          'values (:id_supplier$i, :id_order$i, :id_order_item$i, :id_nomencl$i, :qnt_in_order$f, :qnt_in_demand$f)',
          [Cth.GetControlValue(Frg1, 'CbType'), Frg1.GetValue('id_order', i, False), Frg1.GetValue('id_order_item', i, False), Frg1.GetValue('id_nomencl', i, False),
          Frg1.GetValue('qnt_in_order', i, False), Frg1.GetValue('qnt_in_demand', i, False) + S.NNum(Frg1.GetValue('qnt_in_demand_old', i, False))]
        );
      end;
    end;
    Result := Q.PackageMode = 1;
  end;

  function SaveOrder: Boolean;
  var
    i, j, k, IdT: Integer;
    StI, StC: string;
    va: TVarDynArray;
    v: Variant;
  begin
    Result := False;
    StI := '';
    for i := rb to re do begin
      if Frg1.GetValue('qnt_in_demand' ,i, False) <> null then
        for j := 0 to High(PfArr) do
          if (Frg1.GetValue('id_nomencl', i, False) = PfArr[j][0]) and (PfArr[j][3] = 0) then begin
            S.ConcatStP(StI, VarToStr(Frg1.GetValue('id_std_item', i, False)) + '=' + VarToStr(PfArr[j][1]), ',');
            PfArr[j][3] := 1;
          end;
      v := Frg1.GetValue('id_template', i, False);
      if v <> null then
        IdT := S.NInt(v);
    end;
    if IdT = 0 then
      Exit;
    k := Trunc(Frg1.GetValue('dt_otgr', rb, False)) - Trunc(Frg1.GetValue('dt_beg', rb, False));
    k := Round(k * 24 / 30);
    DtO := IncDay(Frg1.GetValue('dt_beg', rb, False), k);
    if Frg1.GetValue('dt_otgr', rb, False) < DtO then
      DtO := Frg1.GetValue('dt_otgr', rb, False);
    StC := '� ������ ' + Frg1.GetValue('ornum', rb, False);
    //pnl_CreatePspForSemiproducts(-99, '4063=12,4064=123', 33, '� ������ 1234', trunc(sysdate), i, v);
    va := Q.QCallStoredProc(
      'p_CreatePspForSemiproducts',
      'id_t$i;items$s;id_u$i;comm$s;dt_otgr$d;id$io;ornum$so',
       [IdT, StI, User.GetId, StC, DtO, -1, -1]
    );
    if Length(va) = 0 then
      Exit;
    IdO := va[5];
    StO := va[6];
    Result := True;
  end;


  function SaveSnDemand: Boolean;
  var
    IdDemand: Integer;
    i, j: Integer;
  begin
    Result := False;
    IdDemand := Q.QIUD('i', 'dv.demand', '', 'id_demand$i;id_category$i;id_docstate$i;comments$s;control_date$d',
      [-1, 3, 1, TDBComboBoxEh(Frg1.FindComponent('CbType')).Text + ' � ' + StO + ' (����. ' + DateToStr(DtO)+ ')', Date]
    );
    if IdDemand < 0 then
      Exit;
    for i := 0 to High(PfArr) do begin
      Q.QExecSql(
        'insert into dv.demand_spec (id_demand, quantity, id_nomencl, id_unit) '+
        'values (:IdDemand$i, :qnt_order$f, :id_nomencl$i, :id_unit$i)',
        [IdDemand, PfArr[i][1], PfArr[i][0], PfArr[i][2]]
      );
    end;
    Result := Q.PackageMode = 1;
  end;


begin
  //Frg1.BeginOperation('��������� ������ ' + OrNum);
  //������� �������� ��� ������� ������ � ��������
  //(������ ���������� ������ ��� �����������, � ���� ������ ������ ������������� �� ������ ������)
  rb := -1;
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    if (rb = -1) and (Frg1.GetValue('ornum', i, False) = OrNum) then
      rb := i;
    if (rb <> -1) and (Frg1.GetValue('ornum', i, False) = OrNum) then
      re := i;
  end;

  repeat
    Lock := Q.DBLock(True, 'ordercreate', '-1', '');
    if Lock[0] = True then Break;
    if MyQuestionMessage(
      '������ ���������� ����� ������������� ' + Lock[1] + #13#10+
      '��������� ������� � ������� "��", ����� ����������, '#13#10+
      '��� ������� "���" � �������� ��������.'
    ) <> mrYes then
      Exit;
  until False;

  //�������� ������ � ������� ��, ��������  �� � ������ �� � ����������.
  //���� ���� ���� �������� ��������, �� ���������� ����������.
  Err := True;
  Q.QBeginTrans(True);
  try
  repeat
    //����� ������ � ������� ��
    if not SaveMtTable then
      Break;
    //������� ������ �������������� ��� ������ (����� ���� ����, ���� ����� ���������� 0)
    if not GetPfArr then
      Break;
    //���������� ����, ���� ���� �������������� � ������
    if Length(PfArr) <> 0 then begin
      //�������� �����
      if not SaveOrder then
        Break;
      //�������� ������ �� ������, ��� � ��� �� � excel
      if not Orders.SetTaskForCreateOrder(IdO) then
        Break;
      //������ �� ���������
      if not SaveSnDemand then
        Break;
    end;
    Err := False;
  until True;
  except on E: Exception do begin
    Q.QRollbackTrans;
    Q.DBLock(False, 'ordercreate', '-1', '');
    Application.ShowException(E);
    end;
  end;
  Q.QCommitOrRollback(not Err);
  Q.DBLock(False, 'ordercreate', '-1', '');
  //Frg1.EndOperation;
end;

function TFrmOGjrnSemiproducts.GetDataForSemiproducts: Boolean;
//�������� ��� ���� �������������� ������� �� ���� �������, ����������� � ���������,
//������ �� ������������ - ���� ���������������� ��� �������, ���� �������, ���� �� �����
var
  i, j, k, tmpl: Integer;
  va2: TVarDynArray2;
  nm, msg, msg1: string;
  b: Boolean;
begin
  Result := False;
  Frg1.SetStatusBarCaption('��������� ���������� �� ������������ ��������������...', True);
  FOrdersWithErrors := [];
  tmpl := 2;
  //�������� �� ����� �������
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    if not A.InArray(Frg1.GetValue('ornum', i, False), FOrdersToDemand) then
      Continue;
    nm := Frg1.GetValue('name', i, False);
    //��������� �������, ������� �� ���� � ������
    if S.NNum(Frg1.GetValue('qnt_in_demand', i, False)) = 0 then
      Continue;
    //���������� ����� ����� �� ������������ � ����� ���������� � ��� �� ������� �������� ����������
    for k := 0 to i - 1 do
      if (nm = Frg1.GetValue('name', k, False)) and (S.NSt(Frg1.GetValue('id_std_item', k, False)) <> '') then begin
        //���� �����, ������� ������ �� ����
        Frg1.SetValue('id_std_item', i, False, Frg1.GetValue('id_std_item', k, False));
        Frg1.SetValue('id_template', i, False, Frg1.GetValue('id_template', k, False));
        Frg1.SetValue('has_estimate', i, False, Frg1.GetValue('has_estimate', k, False));
        Break;
      end;
    if (i = 0) or (k = i) then begin
      //���� �� �����, ������ ������ ��� ��������
      va2 := Q.QLoadToVarDynArray2(
        'select id_std_item, id_template, dt_estimate from v_semiproducts_get_std_item where name = :name$s',
        [Frg1.GetValue('name', k, False)]
      );
      if Length(va2) = 0
        then va2 := [[0, null, null]]
        else if Length(va2) > 1
          then va2 := [[{-1} 0, null, null]];
      //��������� ������ ������� � �������
      Frg1.SetValue('id_std_item', i, False, va2[0][0]);
      Frg1.SetValue('id_template', i, False, va2[0][1]);
      Frg1.SetValue('has_estimate', i, False, va2[0][2]);
      //��������
      if Frg1.GetValue('id_std_item', i, False) = 0
        then S.ConcatStP(msg1, nm + '     : ' + '�� ������ � ����������� ����������� �������.', #13#10)
        else if Frg1.GetValue('id_template', i, False) = null
          then S.ConcatStP(msg1, nm + '     : ' + '�� ������ � ��������.', #13#10)
        else if Frg1.GetValue('has_estimate', i, False) = null
          then S.ConcatStP(msg1, nm + '     : ' + '��� �����.', #13#10)
    end;
    //�������� � ��������� �������, ��� ���� �������� ��� ������������ ������� ��������� ������
    if tmpl = 2
      then tmpl := S.NInt(Frg1.GetValue('id_template', k, False))
      else if tmpl <> S.NInt(Frg1.GetValue('id_template', k, False))
        then tmpl := 1;
    //���� ������� �� ������ �����, ��� ��� ��������� ������
    if (i = Frg1.GetCount(False) - 1) or (Frg1.GetValue('ornum', i, False) <> Frg1.GetValue('ornum', i + 1, False)) then begin
      if (msg1 = '') and (tmpl = 1) then
        msg := Frg1.GetValue('ornum', i, False) + '     : ' + '������ ������� ��� �������.';
      //�������, ��� ���� ������ � ������
      if msg1 <> ''
        then FOrdersWithErrors := FOrdersWithErrors + [Frg1.GetValue('ornum', i, False)];
      //����� ���������
      S.ConcatStP(msg, msg1, #13#10, True);
      msg1 := '';
      tmpl := 2;
    end;
  end;
  //���� ���� ������, ������� ���������� ��
  if msg <> '' then begin
    MyWarningMessage(msg, 1);
    if Length(FOrdersWithErrors) <> Length(FOrdersToDemand)
      then Result := MyQuestionMessage('�������� �� ��������� ������� �� ����� ���� ������������!'#13#10 + A.Implode(FOrdersWithErrors, ', ') + #13#10'������������ �� ��������� �������?', 1) = mrYes
      else MyWarningMessage('�� ����� ���� ������ �� ���� ������� ������!');
  end
  else Result := True;
  Frg1.SetStatusBarCaption('', True)
end;



end.
