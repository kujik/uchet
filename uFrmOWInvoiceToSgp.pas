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
    pnlSelectOrder: TPanel;
    pnlTitle: TPanel;
    pnlGrid: TPanel;
    lblInvoice: TLabel;
    lblOrder: TLabel;
    lblM: TLabel;
    bvl1: TBevel;
    cmbOrder: TDBComboBoxEh;
    btnFill: TBitBtn;
    Frg1: TFrDBGridEh;
    lblS: TLabel;
    procedure BtFillClick(Sender: TObject);
  private
    { Private declarations }
    FNum: Integer;
    FState: Integer;
    FIdOrder: Integer;
    FDtM: TDateTime;
    FUserM: string;
    FDtS: TDateTime;
    FUserS: string;
    FOrNum: string;
    FProject: string;
    FDtBeg: TDateTime;
    FDtOtgr: TDateTime;
    FUpdR: Integer;
    function  Prepare: Boolean; override;
    procedure AfterPrepare; override;
    function  Save: Boolean; override;
    procedure Verify(Sender: TObject; onInput: Boolean = False); override;
    procedure VerifyTable(IsChanded: Boolean = False);
    procedure btnClick(Sender: TObject); override;
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

procedure TFrmOWInvoiceToSgp.btnClick(Sender: TObject);
//��������� ������� ������ (����� �������� ������ �������)
var
  i: Integer;
begin
  if TControl(Sender).Tag = mbtPrint then Print;
  if TControl(Sender).Tag = mbtGo then begin
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
    'select distinct(FOrNum) from (select FOrNum from v_invoice_to_sgp_getitems where qnt > qnt_sgp and area = :area$i) order by FOrNum',
    [AddParam[1]], cmbOrder, cntComboL
  );
  Cth.SetControlValue(cmbOrder, null);
end;

function TFrmOWInvoiceToSgp.Fill: Boolean;
//����������� ��������� �� ���������� ������
//���� ������ ��� ���������, �� ��� ����� �������� ��� �������
var
  va: TVarDynArray2;
  FNum: string;
begin
  FNum:= Cth.GetControlValue(cmbOrder);
  if FNum = '' then Exit;
  //���� ��������� �����
  va:=Q.QLoadToVarDynArray2('select id, FOrNum, FProject, dt_beg, dt_otgr from orders where FOrNum = :id$s', [FNum]);
  if Length(va) = 0 then
    Exit;
  FIdOrder:=va[0][0];
  FOrNum:=va[0][1];
  FProject:=va[0][2];
  FDtBeg:=va[0][3];
  FDtOtgr:=va[0][4];
  //�������� ���������
  SetTitle;
  //�������� - ������ ������, � �� ���� ��������� ����������� ������
  Verify(nil);
  //��������� ��������� ����� �� ������ ���� ������
  va:=Q.QLoadToVarDynArray2(
    'select id, id, slash, fullitemname, qnt, qnt_max, null, null from v_invoice_to_sgp_getitems where id_order = :id$i and qnt > qnt_sgp order by slash',
    [FIdOrder]
  );
  //�������� � ��������
  Frg1.LoadSourceDataFromArray(va);
end;

procedure TFrmOWInvoiceToSgp.Settitle;
//��������� ������� ������� � ����������� �����
begin
  //����� ��������� ����� ������ ����� ������ ��� ��� ����� ����������
  lblInvoice.SetCaption2('���������:'+S.IIfStr(FNum > 0, ' $FF0000 '+IntToStr(FNum)+'$000000')+' �� $FF0000 '+DateToStr(FDtM));
  //���������� �� ������-��������� ������ ���� �� ��� ��������
  lblOrder.SetCaption2('�����:');
  if FIdOrder <> 0 then
    lblOrder.SetCaption2('�����:$FF0000 '+FOrNum+'$000000 ��$FF0000 '+DateToStr(FDtBeg)+'$000000 [$FF0000'+FProject+'$000000], ��������$FF0000 '+DateToStr(FDtOtgr));
  //���������� � ��������� ��������� (������)
  lblM.SetCaption2('������:$FF0000 '+FUserM+S.IIfStr(True, '$000000 �$FF0000 '+FormatDateTime('hh:nn', FDtM)+'$000000'));
  //���� ���� ����� ��� ���� �� �������, �������� (�� ���� ��� � ����� ����� ������ �����������)
  if lblS <> nil then
    lblS.SetCaption2('������ �� ���:$FF0000 '+FUserS+S.IIfStr(True, '$000000 ,$FF0000 '+FormatDateTime('dd.mm.yyyy hh:nn', FDtS)+'$000000'));
end;

function TFrmOWInvoiceToSgp.LoadData: Boolean;
//�������� ������ �� ��
var
  va: TVarDynArray2;
  st: string;
begin
  if Mode = fAdd then begin
    //��� �������� ����� - ������ �������� ����������� ����
    FIdOrder:= 0;
    FDtM:=Now;
    FUserM:=User.GetName;
    LoadOrderList;
  end
  else begin
    //��� ��������� � �������������� �������� �� ������
    //������������ �����
    va:=Q.QLoadToVarDynArray2(
      'select FNum, id_order, FOrNum, FProject, dt_beg, dt_otgr, dt_m, user_m, dt_s, user_s from v_invoice_to_sgp where id = :id$i',
      [ID]
    );
    FNum := va[0][0];
    FIdOrder := va[0][1];
    FOrNum := va[0][2];
    FProject := va[0][3];
    FDtBeg := va[0][4];
    FDtOtgr := va[0][5];
    FDtM := va[0][6];
    FUserM := va[0][7];
    if va[0][8] <> null then FDtS := va[0][8];  //��������� ���� ������� �� ����, �� ��� ��� ���������
    FUserS := S.NSt(va[0][9]);
    //��� ������ �������������� - ������� ����-����� ������� �� ��� � ��� ����������
    if Mode = fEdit then begin
      FDtS := Now;
      FUserS := User.GetName;
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
    if FNum = 0 then
      FNum := Q.QCallStoredProc('p_GetDocumNum', 'd$s;y$i;n$io', ['InvoiceToSgp', YearOf(Date), -1])[2];
    for i := 0 to Frg1.GetCount - 1 do
      if S.NSt(Frg1.GetValue('qnt_m', i)) <> '' then
        S.ConcatStP(items, Frg1.GetValue('slash', i), ', ');
    Q.QBeginTrans(True);
    IdInvoice := Q.QIUD(
      'i', 'invoice_to_sgp', '',
      'id$i;FNum$i;id_order$i;dt_m$d;id_user_m$s;FState$i;items$s',
      [-1, FNum, FIdOrder, FDtM, User.GetId, 0, Copy(items, 1, 4000)]
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
  FState := 2;
  for i := 0 to Frg1.GetCount - 1 do begin
    if Frg1.GetValue('qnt_s', i) <> Frg1.GetValue('qnt_m', i) then begin
      FState := 1;
      S.ConcatStP(items, Frg1.GetValue('slash', i) + S.IIfStr(S.NNum(Frg1.GetValue('qnt_s', i)) > 0,  '(�)'), ', ');
    end
    else S.ConcatStP(items, Frg1.GetValue('slash', i) + '(�)', ', ');
  end;
  Q.QIUD(
    'u', 'invoice_to_sgp', '', 'id$i;dt_s$d;id_user_s$s;FState$i;items$s',
    [ID, FDtS, User.GetId, FState, Copy(items, 1, 4000)]
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
  Orders.FinalizeOrder(FIdOrder, myOrFinalizeToSgp);
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
    FState := 2;
    for i := 0 to Frg1.GetCount - 1 do begin
      if S.NSt(Frg1.GetValue('qnt_s', i)) <> S.NSt(Frg1.GetValue('qnt_m', i))
        then FState := 1;
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
  HasError:=HasError or (FIdOrder = 0);
{  if not HasError and (Mode = fAdd) then begin
    //� ������ ��������������� ���������� - ������ ���� ������� ���������� ������������ ���� �� �� ����� �������
    for i := 0 to Frg1.GetCount - 1 do
      if S.NSt(Frg1.GetValue('qnt_m', i)) <> ''
        then Break;
    HasError := i = Frg1.GetCount;
  end;
  if not HasError and (Mode = fEdit) then begin
    //� ������ �������������� ������������ - ������ ���� ��������� ���������� ����������� �� ���� ��������
    FState := 2;
    for i := 0 to Frg1.GetCount - 1 do begin
      if S.NSt(Frg1.GetValue('qnt_s', i)) <> S.NSt(Frg1.GetValue('qnt_m', i))
        then FState := 1;
      if S.NSt(Frg1.GetValue('qnt_s', i)) = ''
        then Break;
    end;
    HasError := i < Frg1.GetCount;
  end;  }
  //��������� ����������� ������ ������
  Cth.SetButtonsAndPopupMenuCaptionEnabled([pnlFrmBtnsR], mbtPrint, True, not HasError, '');
end;

procedure TFrmOWInvoiceToSgp.Print;
//������ ���������
begin
  if Frg1.RecordCount = 0 then
    Exit;
  //���� ��� �� �������� ����� - ������� ��� �������� ��
  if FNum = 0 then
    FNum := Q.QCallStoredProc('p_GetDocumNum', 'd$s;y$i;n$io', ['InvoiceToSgp', YearOf(Date), -1])[2];
  //���������� ������������ �����
  SetTitle;
  Frg1.MemTableEh1.DisableControls;
  //����������� ������ - ������ �� �� ������� ���������� �� �������� �������� � ������ 0
  Gh.GetGridColumn(Frg1.DBGridEh1, 'qnt_m').STFilter.ExpressionStr := '>0';
  Frg1.DBGridEh1.DefaultApplyFilter;
  //�������� � ������� ������ ��������� ���������
  PrintReport.SetReportDataset(
    'c1$s;c2$s;c3$s',
    ['��������� �'+IntToStr(FNum)+' �� '+DateToStr(FDtM),
     '�����: '+FOrNum+' �� '+DateToStr(FDtBeg)+' ['+FProject+'], �������� '+DateToStr(FDtOtgr),
     '������: '+FUserM+' � '+FormatDateTime('hh:nn', FDtM)]
  );
  //����� ��������� ������
  PrintReport.pnl_InvoiceToSgp(Frg1.MemTableEh1);
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
  FUpdR := Fr.RecNo;
end;

procedure TFrmOWInvoiceToSgp.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
end;

procedure TFrmOWInvoiceToSgp.Frg1ChangeSelectedData(var Fr: TFrDBGridEh; const No: Integer);
var
  r: Integer;
begin
  //Verify(nil);
  if (FUpdR > 0)and(Fr.DbGridEh1.Col in [3]) then begin
    r := FUpdR;
    FUpdR := 0;
    if Fr.RecordCount < r
      then Fr.MemTableEh1.RecNo := r + 1;
    Fr.DbGridEh1.Col:=IIf(Mode = fAdd, Fr.DbGridEh1.FindFieldColumn('qnt_m').Index, Fr.DbGridEh1.FindFieldColumn('qnt_s').Index) + 1;
  end;
end;

function TFrmOWInvoiceToSgp.Prepare: Boolean;
//���������� � �������� �����
//� AddParam:
//[������, area, FOrNum�
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
    FreeAndNil(lblS);
  end;
//    if FormDbLock = fNone then Exit;
  FOpt.DlgPanelStyle := dpsBottomRight;
  Cth.MakePanelsFlat(pnlFrmClient, []);
  Cth.SetBtn(btnFill, mybtGo, False, '���������');
//  FWHCorrected.X:=0;
  //Cth.AlignControls(pnlSelectOrder, [], True);
  pnlSelectOrder.Height := 0;
  Cth.AlignControls(pnlTitle, [], True, 2);
  FOpt.DlgButtonsR:=[[mbtPrint, Mode <> FEdit], [mbtGo, (Mode = FEdit), '���������'], [mbtDividor], [mbtSpace, 4]];
  FOpt.StatusBarMode := stbmNone; //stbmDialog;
  FOpt.RefreshParent := True;
  if Mode <> fAdd then begin
    cmbOrder.Visible := False;
    btnFill.Visible := False;
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
  pa:=[@FProject, @DtEnd];
//  Variant(pa[0]^):='qwerty';
  string(pa[0]^):=VarToStr(Date);
  v:=PVariant(pa[0]^)
*)
