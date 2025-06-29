unit D_ExpenseItems;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, Mask, uData, uForms, uDBOra, uString, uMessages, V_MDI,
  Vcl.ExtCtrls;

type
  TDlg_ExpenseItems = class(TForm_MDI)
    edt_name: TDBEditEh;
    cmb_Active: TDBCheckBoxEh;
    Bt_OK: TBitBtn;
    Bt_Cancel: TBitBtn;
    edt_users: TDBEditEh;
    edt_Agreed: TDBEditEh;
    cmb_Group: TDBComboBoxEh;
    chb_RecvReceipt: TDBCheckBoxEh;
    chb_AccountTO: TDBCheckBoxEh;
    chb_AccountTS: TDBCheckBoxEh;
    Img_Info: TImage;
    chb_AccountM: TDBCheckBoxEh;
    procedure edt_NameChange(Sender: TObject);
    procedure Bt_OKClick(Sender: TObject);
    procedure cmb_ActiveClick(Sender: TObject);
    procedure edt_usersEditButtons0Click(Sender: TObject; var Handled: Boolean);
    procedure Bt_CancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edt_AgreedEditButtons0Click(Sender: TObject; var Handled: Boolean);
    procedure ControlOnChange(Sender: TObject);
    procedure ControlOnExit(Sender: TObject);
    procedure ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean);
    procedure chb_AccountTOClick(Sender: TObject);
    procedure chb_AccountTSClick(Sender: TObject);
    procedure chb_AccountMClick(Sender: TObject);
  private
    { Private declarations }
    Agreed: string;
    UserIds: string;
    Ok: Boolean;
    procedure Verify(Sender: TObject; onInput: Boolean = False);
  public
    { Public declarations }
    function  Prepare: Boolean; override;
  end;

var
  Dlg_ExpenseItems: TDlg_ExpenseItems;

implementation

{$R *.dfm}

uses
//  F_R_ExpenseItems,
  uWindows,
  uFrmXGsesUsersChoice
  ;

//������� ��������� ������ ��������
procedure TDlg_ExpenseItems.ControlOnChange(Sender: TObject);
begin
  //����� ���� � ��������� ��������
  if InPrepare then Exit;
  //��������, ������� ��� � ���� ������� ��������
  Verify(Sender, True);
end;

//���� ������ � ��������
procedure TDlg_ExpenseItems.ControlOnExit(Sender: TObject);
begin
  //����� ���� � ��������� ��������
  if InPrepare then Exit;
  //��������
  Verify(Sender);
end;

procedure TDlg_ExpenseItems.ControlCheckDrawRequiredState(Sender: TObject;
  var DrawState: Boolean);
begin
  Cth.VerifyVisualise(Self);
//  verify(Sender, False);
end;

//�������� ���������6���� ������
//���������� ������� ��� ��������, ��� ��� - ��������� ���
//� ������� ��� �������� ��� ����� ������ � �������� (� ������� onChange)
procedure TDlg_ExpenseItems.Verify(Sender: TObject; onInput: Boolean = False);
var
  i,j,s:Integer;
  c: TControl;
begin
  //� ��������� � �������� ������ ��
  if (Mode = fView) or (Mode = fDelete)
    then begin
      Ok:=True;
      Bt_Ok.enabled := Ok;
      Exit;
    end;
  if Sender = nil
    //�������� ��� DbEh
    then Cth.VerifyAllDbEhControls(Self)
    //�������� �������
    else Cth.VerifyControl(TControl(Sender), onInput);
  //������� ������ �������� � �������������
  Ok:=Cth.VerifyVisualise(Self);
  //������ ������ ��
  Bt_Ok.Enabled := Ok;
end;

function TDlg_ExpenseItems.Prepare: Boolean;
var
  v: TVarDynArray;
  Info: string;
begin
  Result:= False;
  BorderStyle:=bsDialog;
  if (Mode=fEdit)or(Mode=fDelete) then
    if Q.DBLock(True, FormDoc, VarToStr(id))[0] <> True
      then Exit;
  Q.QLoadToDBComboBoxEh('select name, id from ref_grexpenseitems order by name', [], cmb_Group, cntComboLK);
  if Mode = fAdd
    then v:=VarArrayOf([1,'',1,'','','','','',1,0])
    else v:=Q.QSelectOneRow('select id, name, active, usernames, agreednames, useravail, agreed, id_group, recvreceipt, accounttype from v_ref_expenseitems where id = :id', [ID]);
  if v[0] = null then begin MsgRecordIsDeleted; Exit; end;
  edt_name.Value:=v[1];
  Cth.SetControlValue(cmb_Active, v[2]);
  Cth.SetControlValue(edt_Users, v[3]);
  Cth.SetControlValue(edt_Agreed, v[4]);
  Cth.SetControlValue(cmb_Group, v[7]);
  Cth.SetControlValue(chb_RecvReceipt, v[8]);
  Cth.SetControlValue(chb_AccountTO, S.IIf(v[9] = 1, 1, 0));  //��� ����� ��������� ��
  Cth.SetControlValue(chb_AccountTS, S.IIf(v[9] = 2, 1, 0));  //��� ����� ��������� ��
  Cth.SetControlValue(chb_AccountM, S.IIf(v[9] = 3, 1, 0));  //��� ����� ��������� ��
  UserIds:=S.NSt(v[5]);
  Agreed:=S.NSt(v[6]);
   //������� onCahange �  onExit ��� ���� dbeh ���������
  Cth.SetControlsOnChange(Self, ControlOnChange);
  Cth.SetControlsOnExit(Self, ControlOnExit);
  Cth.SetControlsOnCheckDrawRequired(Self, ControlCheckDrawRequiredState);
  //��������� �������� ���������
  Cth.SetControlsVerification(
    [edt_name, cmb_Group],
    ['1:400:0:T','1:400']
  );
  Cth.SetDialogForm(Self, Mode, '������ ��������');
  Cth.DlgSetControlsEnabled(Self, Mode, [], []);
  Verify(nil);
  Info:=
  '�������������� ������ ��������.'#13#10+
  '�������� ������ �� ������ ������������, ������������ ������ ��������.'#13#10+
  '�������� � ������������� ���� �������������, ������� ����� ��������� ����� �� ������ ������ ��������'#13#10+
  '(������������� ����� ���� ���������).'#13#10+
  '����� �������� �����������, ������� ������ ������������ ��� ������ �� ������ ������.'#13#10+
  '�������� ��� ������������� ��� ����� ��� ������ ������'#13#10+
  '(����� ���� ������� ����, ��������� ���������, ��������� ��������, ���� ���� ���������� �� �������).'#13#10+
  '��������� �������, ���� �� ���� ������ ��������� ��������� ������ �� ���������'#13#10+
  '(������ �� �����������, ���� ����� ����� �� ��������� ��������, �������������� � ���������� ���������).'#13#10
  ;
  if Mode in [fView, fDelete] then Info:='';
  Cth.SetInfoIcon(Img_Info, Info, 20);
  PreventResize:=True;
  Result:= True;
end;

procedure TDlg_ExpenseItems.cmb_ActiveClick(Sender: TObject);
var
  Canvas: TControlCanvas;
begin
 Exit;
 Canvas := TControlCanvas.Create;
 try
 Canvas.Control := cmb_Active;
 with Canvas, ClipRect do
 begin
//   Pen.Width:=3;
   Pen.Color:=RGB(224,0,0);
   Pen.Style:=psDot;
   MoveTo(Left, Bottom-2);
   LineTo(Right, Bottom-2);
   MoveTo(Left, Bottom-1);
   LineTo(Right, Bottom-1);
   MoveTo(Left, Bottom-0);
   LineTo(Right, top-0);
 end;
 Canvas.Control := edt_name;
 with Canvas, ClipRect do
 begin
   Pen.Color:=RGB(224,0,0);
   Pen.Style:=psDot;
   MoveTo(Left, Bottom-2);
   LineTo(Right, Bottom-2);
   MoveTo(Left, Bottom-1);
   LineTo(Right, Bottom-1);
 end;
finally
  Canvas.Free;
end;
end;


procedure TDlg_ExpenseItems.chb_AccountMClick(Sender: TObject);
begin
  if chb_AccountM.Checked then begin
    chb_AccountTS.Checked:=False;
    chb_AccountTO.Checked:=False;
  end;
end;

procedure TDlg_ExpenseItems.chb_AccountTOClick(Sender: TObject);
begin
  if chb_AccountTO.Checked then begin
    chb_AccountTS.Checked:=False;
    chb_AccountM.Checked:=False;
  end;
end;

procedure TDlg_ExpenseItems.chb_AccountTSClick(Sender: TObject);
begin
  if chb_AccountTS.Checked then begin
    chb_AccountTO.Checked:=False;
    chb_AccountM.Checked:=False;
  end;
end;

procedure TDlg_ExpenseItems.edt_AgreedEditButtons0Click(Sender: TObject; var Handled: Boolean);
var
  NewIds, NewNames: string;
begin
//!!!
//  if Dlg_SelectUsers.ShowDialog(FormDoc + '_2',  Agreed, False, NewIds, NewNames) <> mrOk then exit;
  if TFrmXGsesUsersChoice.ShowDialog(Application, False, NewIDs, NewNames) <> mrOk then
    exit;
//  if Dlg_SelectUsers.ShowDialog(FormDoc + '_2',  Agreed, True, NewIds, NewNames) <> mrOk then exit;
  edt_Agreed.Value:=NewNames;
  Agreed:=NewIds;
end;

procedure TDlg_ExpenseItems.edt_NameChange(Sender: TObject);
begin
//  edt_name.Text:=TComponent(Sender).Name;
end;

procedure TDlg_ExpenseItems.edt_usersEditButtons0Click(Sender: TObject;  var Handled: Boolean);
var
  NewIds, NewNames: string;
begin
//!!!
//  if Dlg_SelectUsers.ShowDialog(FormDoc + '_1',  UserIds, True, NewIds, NewNames) <> mrOk then exit;
  if TFrmXGsesUsersChoice.ShowDialog(Application, True, NewIDs, NewNames) <> mrOk then
  edt_users.Value:=NewNames;
  UserIds:=NewIds;
end;

procedure TDlg_ExpenseItems.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Q.DBLock(False, FormDoc, VarToStr(id));
  Action := caFree;
  try
    //Wh.CloseMDIForm(Self);
  except
  end;
end;

procedure TDlg_ExpenseItems.Bt_CancelClick(Sender: TObject);
begin
  Close;
end;

procedure TDlg_ExpenseItems.Bt_OKClick(Sender: TObject);
var
  NewID: Integer;
  b: Integer;
begin
  if (Mode = fView) then begin Close; Exit; end;
  if edt_name.Text = '' then Exit;
  if cmb_Group.Text = '' then Exit;
  b:= Q.QIUD(Q.QFModeToIUD(Mode), 'ref_expenseitems', 'sq_ref_expenseitems', 'id;name;active;useravail;agreed;id_group;recvreceipt;accounttype',
    [ID, Cth.GetControlValue(edt_name), Cth.GetControlValue(cmb_Active), UserIds, Agreed, Cth.GetControlValue(cmb_Group), Cth.GetControlValue(chb_RecvReceipt), S.IIf(Cth.GetControlValue(chb_AccountTO), 1, S.IIf(Cth.GetControlValue(chb_AccountTS), 2, S.IIf(Cth.GetControlValue(chb_AccountM), 3, 0)))]
  );
  if b = -1 then Exit;
  RefreshParentForm;
  Close;
end;

end.
