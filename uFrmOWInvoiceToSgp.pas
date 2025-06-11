(*
������ ��������� ����������� �� ���
*)

unit uFrmOWInvoiceToSgp;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, EhLibVCL,
  GridsEh, DBAxisGridsEh, DBGridEh, PropFilerEh, PropStorageEh, Math,
  Mask, Types, DBCtrlsEh, ExtCtrls, DateUtils,
  uLabelColors, uFrmBasicMdi, uFrDBGridEh
  ;

type
  TFrmOWInvoiceToSgp = class(TFrmBasicMdi)
    PSelectOrder: TPanel;
    PTitle: TPanel;
    PGrid: TPanel;
    LbInvoice: TLabel;
    LbOrder: TLabel;
    LbM: TLabel;
    Bevel1: TBevel;
    CbOrder: TDBComboBoxEh;
    BtFill: TBitBtn;
    Frg1: TFrDBGridEh;
    LbS: TLabel;
    procedure BtFillClick(Sender: TObject);
  private
    { Private declarations }
    Num: Integer;
    State: Integer;
    IdOrder: Integer;
    DtM: TDateTime;
    UserM: string;
    DtS: TDateTime;
    UserS: string;
    OrNum: string;
    Project: string;
    DtBeg: TDateTime;
    DtOtgr: TDateTime;
    UpdR: Integer;
    function  Prepare: Boolean; override;
    procedure AfterPrepare; override;
    function  Save: Boolean; override;
    procedure Verify(Sender: TObject; onInput: Boolean = False); override;
    procedure VerifyTable(IsChanded: Boolean = False);
    procedure BtClick(Sender: TObject); override;
    function  LoadData: Boolean;
    procedure LoadOrderList;
    function  Fill: Boolean;
    procedure Settitle;
    procedure Print;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
    procedure Frg1ChangeSelectedData(var Fr: TFrDBGridEh; const No: Integer);
  public
    { Public declarations }
  end;

var
  FrmOWInvoiceToSgp: TFrmOWInvoiceToSgp;

implementation

uses
  uWindows,
  uString,
  uForms,
  uDBOra,
  uMessages,
  uData,
  uErrors,
  uPrintReport,
  uOrders
  ;

{$R *.dfm}

procedure TFrmOWInvoiceToSgp.BtFillClick(Sender: TObject);
begin
  Fill;
end;

procedure VarToP(v: Variant; p: Pointer);
begin
  if v = null
    then string(p^) := v;
  if S.VarType(v) = varInteger
    then Integer(p^) := v;
  if S.VarType(v) = varString
    then string(p^) := v;
  if S.VarType(v) = varDate
    then TDateTime(p^) := v;
  if S.VarType(v) = varDouble
    then Extended(p^) := v;
end;

procedure VarArrayToPList(V: TVarDynArray; P: TPointerList);
var
  i: Integer;
begin
  for i:= 0 to High(V) do begin
    VarToP(V[i], P[i]);
  end;
end;

procedure TFrmOWInvoiceToSgp.BtClick(Sender: TObject);
//��������� ������� ������ (����� �������� ������ �������)
var
  i: Integer;
begin
  if TControl(Sender).Tag = btnPrint then Print;
  if TControl(Sender).Tag = btnGo then begin
    for i := 0 to Frg1.GetCount - 1 do
      Frg1.SetValue('qnt_s', i, True, Frg1.GetValue('qnt_m', i));
    Frg1.DbGridEh1.SetFocus;
    VerifyTable(True);
    Verify(nil);
  end;
end;

procedure TFrmOWInvoiceToSgp.LoadOrderList;
//�������� ������ �������, �������� ��� �������� ���������
begin
  //��������� ������ ������� �� �������� �, � ������� ���� ���� �� ���� ����, �� �������� �� ��� � ������ ����������
  Q.QLoadToDBComboBoxEh(
    'select distinct(ornum) from (select ornum from v_invoice_to_sgp_getitems where qnt > qnt_sgp and area = :area$i) order by ornum',
    [AddParam[1]], CbOrder, cntComboL
  );
  Cth.SetControlValue(CbOrder, null);
end;

function TFrmOWInvoiceToSgp.Fill: Boolean;
//����������� ��������� �� ���������� ������
//���� ������ ��� ���������, �� ��� ����� �������� ��� �������
var
  va: TVarDynArray2;
  num: string;
begin
  num:= Cth.GetControlValue(CbOrder);
  if num = '' then Exit;
  //���� ��������� �����
  va:=Q.QLoadToVarDynArray2('select id, ornum, project, dt_beg, dt_otgr from orders where ornum = :id$s', [num]);
  if Length(va) = 0 then
    Exit;
  IdOrder:=va[0][0];
  OrNum:=va[0][1];
  Project:=va[0][2];
  DtBeg:=va[0][3];
  DtOtgr:=va[0][4];
  //�������� ���������
  SetTitle;
  //�������� - ������ ������, � �� ���� ��������� ����������� ������
  Verify(nil);
  //��������� ��������� ����� �� ������ ���� ������
  va:=Q.QLoadToVarDynArray2(
    'select id, id, slash, fullitemname, qnt, qnt_max, null, null from v_invoice_to_sgp_getitems where id_order = :id$i and qnt > qnt_sgp order by slash',
    [IdOrder]
  );
  //�������� � ��������
  Frg1.LoadSourceDataFromArray(va);
end;

procedure TFrmOWInvoiceToSgp.Settitle;
//��������� ������� ������� � ����������� �����
begin
  //����� ��������� ����� ������ ����� ������ ��� ��� ����� ����������
  LbInvoice.SetCaption2('���������:'+S.IIfStr(Num > 0, ' $FF0000 '+IntToStr(Num)+'$000000')+' �� $FF0000 '+DateToStr(DtM));
  //���������� �� ������-��������� ������ ���� �� ��� ��������
  LbOrder.SetCaption2('�����:');
  if IdOrder <> 0 then
    LbOrder.SetCaption2('�����:$FF0000 '+OrNum+'$000000 ��$FF0000 '+DateToStr(DtBeg)+'$000000 [$FF0000'+Project+'$000000], ��������$FF0000 '+DateToStr(DtOtgr));
  //���������� � ��������� ��������� (������)
  LbM.SetCaption2('������:$FF0000 '+UserM+S.IIfStr(True, '$000000 �$FF0000 '+FormatDateTime('hh:nn', DtM)+'$000000'));
  //���� ���� ����� ��� ���� �� �������, �������� (�� ���� ��� � ����� ����� ������ �����������)
  if LbS <> nil then
    LbS.SetCaption2('������ �� ���:$FF0000 '+UserS+S.IIfStr(True, '$000000 ,$FF0000 '+FormatDateTime('dd.mm.yyyy hh:nn', DtS)+'$000000'));
end;

function TFrmOWInvoiceToSgp.LoadData: Boolean;
//�������� ������ �� ��
var
  va: TVarDynArray2;
  st: string;
begin
  if Mode = fAdd then begin
    //��� �������� ����� - ������ �������� ����������� ����
    IdOrder:= 0;
    DtM:=Now;
    UserM:=User.GetName;
    LoadOrderList;
  end
  else begin
    //��� ��������� � �������������� �������� �� ������
    //������������ �����
    va:=Q.QLoadToVarDynArray2(
      'select num, id_order, ornum, project, dt_beg, dt_otgr, dt_m, user_m, dt_s, user_s from v_invoice_to_sgp where id = :id$i',
      [ID]
    );
    Num := va[0][0];
    IdOrder := va[0][1];
    OrNum := va[0][2];
    Project := va[0][3];
    DtBeg := va[0][4];
    DtOtgr := va[0][5];
    DtM := va[0][6];
    UserM := va[0][7];
    if va[0][8] <> null then DtS := va[0][8];  //��������� ���� ������� �� ����, �� ��� ��� ���������
    UserS := S.NSt(va[0][9]);
    //��� ������ �������������� - ������� ����-����� ������� �� ��� � ��� ����������
    if Mode = fEdit then begin
      DtS := Now;
      UserS := User.GetName;
    end;
    //�������� ���� �������
    va:=Q.QLoadToVarDynArray2(
      'select id, id_order_item, slash, fullitemname, qnt, null, qnt_m, qnt_s from v_invoice_to_sgp_items where id_invoice = :id$i order by slash',
      [ID]
    );
    Frg1.LoadSourceDataFromArray(va);
  end;
  VerifyTable;
end;


function TFrmOWInvoiceToSgp.Save: Boolean;
//���������� ������ � ��. ���������� �� ������ �� ��������-�������
var
  i, j: Integer;
  IdInvoice: Integer;
  items: string;
begin
  //�� ������ ������ �������� (�� ���� ����� �� ������ ������� ��� ������)
  Result := False;
  Verify(nil);
  items := '';
  if HasError then Exit;
  //��� ����� � �����������
  //����� �������� (���������� ��������)
  if Mode = fAdd then begin
    if Num = 0 then
      Num := Q.QCallStoredProc('P_GetDocumNum', 'd$s;y$i;n$io', ['InvoiceToSgp', YearOf(Date), -1])[2];
    for i := 0 to Frg1.GetCount - 1 do
      if S.NSt(Frg1.GetValue('qnt_m', i)) <> '' then
        S.ConcatStP(items, Frg1.GetValue('slash', i), ', ');
    Q.QBeginTrans(True);
    IdInvoice := Q.QIUD(
      'i', 'invoice_to_sgp', '',
      'id$i;num$i;id_order$i;dt_m$d;id_user_m$s;state$i;items$s',
      [-1, Num, IdOrder, DtM, User.GetId, 0, Copy(items, 1, 4000)]
    );
    for i := 0 to Frg1.GetCount - 1 do
      if S.NSt(Frg1.GetValue('qnt_m', i)) <> '' then
        if Q.QIUD(
          'i', 'invoice_to_sgp_items', '', 'id$i;id_invoice$i;id_order_item$i;qnt_m$f',
          [-1, IdInvoice, Frg1.GetValue('id_order_item', i), Frg1.GetValue('qnt_m', i)]
        ) < 0 then
          Break;
    Result:=Q.QCommitOrRollback;
    Exit;
  end;
  //����� ����� ������ ������������
  Q.QBeginTrans(True);
  State := 2;
  for i := 0 to Frg1.GetCount - 1 do begin
    if Frg1.GetValue('qnt_s', i) <> Frg1.GetValue('qnt_m', i) then begin
      State := 1;
      S.ConcatStP(items, Frg1.GetValue('slash', i) + S.IIfStr(S.NNum(Frg1.GetValue('qnt_s', i)) > 0,  '(�)'), ', ');
    end
    else S.ConcatStP(items, Frg1.GetValue('slash', i) + '(�)', ', ');
  end;
  Q.QIUD(
    'u', 'invoice_to_sgp', '', 'id$i;dt_s$d;id_user_s$s;state$i;items$s',
    [ID, DtS, User.GetId, State, Copy(items, 1, 4000)]
  );
  for i := 0 to Frg1.GetCount - 1 do begin
   if Q.QIUD(
        'u', 'invoice_to_sgp_items', '', 'id$i;qnt_s$f',
        [Frg1.GetValue('id', i), Frg1.GetValue('qnt_s', i)]
      ) < 0 then
        Break;
    //������� ��������� ��������� �������������� ������� � ������� order_stages �� stage = 2 (������ �� ���), � ������ ���������� � ��� �������������� �� ������� ����
    if S.NNum(Frg1.GetValue('qnt_s', i)) <> 0 then
      Q.QCallStoredProc('p_OrderStage_SetItem', 'IdOrderItem$i;IdStage$i;NewDt$d;NewQnt$f;UpdateOrder$i;ResQnt$fo;AddQnt$i',
        VarArrayOf([Frg1.GetValue('id_order_item', i), 2, Date, Frg1.GetValue('qnt_s', i), 1, -1, 1])
      );
  end;
  Result:=Q.QCommitOrRollback;
  //�������� ��������� ����� (��������� ��� �)
  Orders.FinalizeOrder(IdOrder, myOrFinalizeToSgp);
end;

procedure TFrmOWInvoiceToSgp.VerifyTable(IsChanded: Boolean = False);
var
  i ,j: Integer;
begin
  j := 0;
  if (Mode = fAdd) then begin
    //� ������ ��������������� ���������� - ������ ���� ������� ���������� ������������ ���� �� �� ����� �������
    j := Frg1.GetCount;
    for i := 0 to Frg1.GetCount - 1 do
      if S.NSt(Frg1.GetValue('qnt_m', i)) <> ''
        then Break;
    Frg1.SetState(IsChanded, i = Frg1.GetCount, S.IIfStr(i = Frg1.GetCount,
      '������ ���� ��������� ���������� ������������ ������� ���� �� �� ����� �������!'
    ));
  end;
  if (Mode = fEdit) then begin
    //� ������ �������������� ������������ - ������ ���� ��������� ���������� ����������� �� ���� ��������
    State := 2;
    for i := 0 to Frg1.GetCount - 1 do begin
      if S.NSt(Frg1.GetValue('qnt_s', i)) <> S.NSt(Frg1.GetValue('qnt_m', i))
        then State := 1;
      if S.NSt(Frg1.GetValue('qnt_s', i)) = ''
        then Break;
    end;
    Frg1.SetState(IsChanded, i < Frg1.GetCount, S.IIfStr(i < Frg1.GetCount,
      '������ ���� ��������� ���������� �������� ������� ���� �� �� ���� ��������!'
    ));
  end;
end;


procedure TFrmOWInvoiceToSgp.Verify(Sender: TObject; onInput: Boolean = False);
//�������� ������������ ������
//�������� ��� �������� ������ ������ ���������� � ������
var
  i: Integer;
  v: Variant;
begin
  //������, ���� ������� ������� � �������� ��������� ������ ��������/������ ������
  //if Sender <> nil then Exit;
  inherited;
  //����� ������ ���� ��������
  HasError:=HasError or (IdOrder = 0);
{  if not HasError and (Mode = fAdd) then begin
    //� ������ ��������������� ���������� - ������ ���� ������� ���������� ������������ ���� �� �� ����� �������
    for i := 0 to Frg1.GetCount - 1 do
      if S.NSt(Frg1.GetValue('qnt_m', i)) <> ''
        then Break;
    HasError := i = Frg1.GetCount;
  end;
  if not HasError and (Mode = fEdit) then begin
    //� ������ �������������� ������������ - ������ ���� ��������� ���������� ����������� �� ���� ��������
    State := 2;
    for i := 0 to Frg1.GetCount - 1 do begin
      if S.NSt(Frg1.GetValue('qnt_s', i)) <> S.NSt(Frg1.GetValue('qnt_m', i))
        then State := 1;
      if S.NSt(Frg1.GetValue('qnt_s', i)) = ''
        then Break;
    end;
    HasError := i < Frg1.GetCount;
  end;  }
  //��������� ����������� ������ ������
  Cth.SetButtonsAndPopupMenuCaptionEnabled([PDlgBtnR], btnPrint, True, not HasError, '');
end;

procedure TFrmOWInvoiceToSgp.Print;
//������ ���������
begin
  if Frg1.RecordCount = 0 then
    Exit;
  //���� ��� �� �������� ����� - ������� ��� �������� ��
  if Num = 0 then
    Num := Q.QCallStoredProc('P_GetDocumNum', 'd$s;y$i;n$io', ['InvoiceToSgp', YearOf(Date), -1])[2];
  //���������� ������������ �����
  SetTitle;
  Frg1.MemTableEh1.DisableControls;
  //����������� ������ - ������ �� �� ������� ���������� �� �������� �������� � ������ 0
  Gh.GetGridColumn(Frg1.DBGridEh1, 'qnt_m').STFilter.ExpressionStr := '>0';
  Frg1.DBGridEh1.DefaultApplyFilter;
  //�������� � ������� ������ ��������� ���������
  PrintReport.SetReportDataset(
    'c1$s;c2$s;c3$s',
    ['��������� �'+IntToStr(Num)+' �� '+DateToStr(DtM),
     '�����: '+OrNum+' �� '+DateToStr(DtBeg)+' ['+Project+'], �������� '+DateToStr(DtOtgr),
     '������: '+UserM+' � '+FormatDateTime('hh:nn', DtM)]
  );
  //����� ��������� ������
  PrintReport.P_InvoiceToSgp(Frg1.MemTableEh1);
  //������� ����� ��� ������
  Gh.GetGridColumn(Frg1.DBGridEh1, 'qnt_m').STFilter.ExpressionStr := '';
  Frg1.DBGridEh1.DefaultApplyFilter;
  Frg1.MemTableEh1.EnableControls;
end;


procedure TFrmOWInvoiceToSgp.AfterPrepare;
//��������� ����� ���������� ���������
begin
  inherited;
  SetTitle;
end;

procedure TFrmOWInvoiceToSgp.Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
//������� ��������� ������ � ������������� �������� �������
var
  v : Variant;
  i : Integer;
begin
{
  Value := S.NNum(Value);
  UseText := False;
  if Mode = fAdd then begin
    if Value = 0 then begin
      Value := null;
    end
    else begin
      if Value > Frg1.GetValue('qnt_max') then
        Value := Frg1.GetValue('qnt_max');
    end;
  end
  else begin
    if Value > Frg1.GetValue('qnt_m') then
      Value := Frg1.GetValue('qnt_m');
  end;
//  Frg1.SetValue('', Value);
//  Frg1.MemTableEh1.Post;
//  Verify(nil);
//  Handled := True;
}
  if not S.IsInt(Value) then Value := 0;
  if Mode = fAdd
    then Frg1.SetValue('', S.NullIf0(Max(0, Min(S.NNum(Value), Frg1.GetValue('qnt_max')))))
    else Frg1.SetValue('', Max(0, Min(S.NNum(Value), Frg1.GetValue('qnt_m'))));
//Frg1.setvalue('name',0,False,Frg1.GetValue);
  VerifyTable(True);
//  Verify(nil);
  Handled := True;
  UpdR := Fr.RecNo;
end;

procedure TFrmOWInvoiceToSgp.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
end;

procedure TFrmOWInvoiceToSgp.Frg1ChangeSelectedData(var Fr: TFrDBGridEh; const No: Integer);
var
  r: Integer;
begin
  //Verify(nil);
  if (UpdR > 0)and(Fr.DbGridEh1.Col in [3]) then begin
    r := UpdR;
    UpdR := 0;
    if Fr.RecordCount < r
      then Fr.MemTableEh1.RecNo := r + 1;
    Fr.DbGridEh1.Col:=IIf(Mode = fAdd, Fr.DbGridEh1.FindFieldColumn('qnt_m').Index, Fr.DbGridEh1.FindFieldColumn('qnt_s').Index) + 1;
  end;
end;

function TFrmOWInvoiceToSgp.Prepare: Boolean;
//���������� � �������� �����
//� AddParam:
//[������, area, ornum�
var
  i, j: Integer;
  c: TControl;
  va: TVarDynArray2;
begin
  Result := False;
  if (Mode = fEdit) and (AddParam[0] <> 0)
    //��� �������� 2 � 3 ������ ��������
    then Mode := fView;
  if not ((Mode = fEdit) or (AddParam[0] > 0)) then begin
    //������ ����� ���� �� ������������� �� ���
    FreeAndNil(LbS);
  end;
//    if FormDbLock = fNone then Exit;
  FOpt.DlgPanelStyle := dpsBottomRight;
  Cth.MakePanelsFlat(PMDIClient, []);
  Cth.SetBtn(BtFill, mybtGo, False, '���������');
//  FWHCorrected.X:=0;
  //Cth.AlignControls(PSelectOrder, [], True);
  PSelectOrder.Height := 0;
  Cth.AlignControls(PTitle, [], True, 2);
  FOpt.DlgButtonsR:=[[btnPrint, Mode <> FEdit], [btnGo, (Mode = FEdit), '���������'], [btnDividor], [btnSpace, 4]];
  FOpt.StatusBarMode := stbmNone; //stbmDialog;
  FOpt.RefreshParent := True;
  if Mode <> fAdd then begin
    CbOrder.Visible := False;
    BtFill.Visible := False;
  end;
  //�������� ����� ����
  Frg1.Options := [myogIndicatorColumn, myogColoredTitle, myogHiglightEditableCells, myogHiglightEditableColumns, myogHasStatusBar];
  Frg1.Opt.SetDataMode(myogdmFromArray);
  Frg1.Opt.SetFields([
    ['id$s', '_id', '40'], ['id_order_item$s', '_id_oi', '40'], ['slash$s', '����', '80'], ['name$s', '������������', '300;W'],
    ['qnt$i', '���-�� � ������', '60'],
    ['qnt_max$i', S.IIfStr(Mode in [fView, fEdit], '_') + '���-�� ����������', '60'],
    ['qnt_m$i', '���-�� ��������', '60', 'e', Mode = fAdd],
    ['qnt_s$i', S.IIfStr(not((Mode = fEdit) or (AddParam[0] > 0)), '_') + '���-�� �������', '60', 'e', Mode = fEdit]
    ]
  );
{  if Mode = fAdd then
    Frg1.Opt.S(gotColEditable, [['qnt_m']]);
  if Mode = fEdit then
    Frg1.Opt.S(gotColEditable, [['qnt_s']]);}
  Frg1.Opt.Caption := '�������';
  Frg1.Opt.SetGridOperations('u');
  Frg1.OnColumnsUpdateData := Frg1ColumnsUpdateData;
  Frg1.OnColumnsGetCellParams := Frg1ColumnsGetCellParams;
  Frg1.OnSelectedDataChange := Frg1ChangeSelectedData;
  //���������� ����� �����
  Frg1.Prepare;
  //����������� ������� �����
  FWHBounds.Y := 300;
  FWHBounds.X := 300;
  Caption := '��������� ����������� �� ���';
  //�������� ������
  LoadData;
    //���������
  FOpt.InfoArray:=[
    ['���������� ��������� �������� �� ��� (��������)'#13#10+
     '�������� ������ ����� � ���������� ������ ����� ���� � ������� ������ "���������",'#13#10+
     '��������� ����� ��������� ����� ��������� ��������� �� ����� ������ (����, ������� ��� �� ������� �� ��� � ������ �������).'#13#10+
     '�� ������ ���������� ���������� ���������� �������, ������ �� ����������� ��������.'#13#10+
     '����� ������� ��������� ��������, ����� ��������� 0.'#13#10+
     '����� �����, ����������� �������-������� ��� �������� � ��������� ������.'#13#10+
     '����� ������, ��� ������������� ������������ ���������.'#13#10+
     '�� �������� ������ ������ �� ��� �� ���������� � �������.'#13#10+
     '������� ���������� ������, ����� ���������� ���������, �� �������������� ����� ����������!'#13#10, Mode = fAdd],

    ['���������� ��������� �������� �� ��� (�����������)'#13#10+
     '�� ������ ���������� �� ������ ������� ���������� �������, ����������� �� ���.'#13#10+
     '��� ���������� �� ����� ���� ������ ���������� ���������� ��������.'#13#10+
     '������ ������ �� �����������, ���� � �� ������� �� �����-���� ������� �� ������ �������, ��������� 0.'#13#10+
     '���� ��� ������� ����������� �� ��������� � ������ �������, ����� ������ ��������� ��, ����� ������ "���������"'#13#10+
     '����� ��� ������, ������� ������ "��", �� ��� ��������� ����� ���������, � �������� ������� ����� ��������� �� ��� (������� �����).'#13#10+
     '������� ���������� ������, ����� ���������� ���������, �� �������������� ����� ����������!'#13#10, Mode = fEdit],

    ['�������� � ������ ��������� �������� �� ���', Mode = fView]
  ];
  Result := True;
end;


end.


(*
�������� ���������
OnColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
1. �������� ����� �� Text ��� Value (����� � ��� � ���.
����������, ���������� UseText = trus/False, � ������� ��������� � ����������� � ���� ����������� � Text ��� �����.
Handled �� �������������
�������� �������� ����� ��� ���������, ����������� � ���� �������, �������������� � MemTable (� �����-�� ������� ��������, ����� �������� �������)
���������� - ������ ����� ����������� ����� ��������� �������
2. Handled ������������� � True, �������� ������ ����� �� Value, ��� ��� �������������� ����� ������� RefreshRecord � ����� �� ������.
������ ����� �������������� � MemTable, ��� � ������� ������ fieldByName.Value :=, ����� ���� ������� Post, �� Edit �� �����
����� �������� ������ Frg1.SetValue('', Value, True) - ������� � ������� ������� � ������� ����.
����� �� ���������� ������, �� ����������� ����� � ��� ������ � ������  Frg1.setvalue('name', 0, False, Frg1.GetValue)
(������������ ������� ����� ������ ��� ���������� � ������ ����������������� ������ � ���� name. ��������� ��� �� �����������)
*)


(*
//type
//  TPVarDynArray = array of pointer

var
  pa: TPointerList;
  pa:=[@project, @DtEnd];
//  Variant(pa[0]^):='qwerty';
  string(pa[0]^):=VarToStr(Date);
  v:=PVariant(pa[0]^)
*)
