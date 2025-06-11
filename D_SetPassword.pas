{
������������� ����� ������ �������������� ��� ������������� ������
����������� �� ������ �����������������, ������ ��� ����� ��� ������������� �������������
}
unit D_SetPassword;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.Mask, DBCtrlsEh,
  v_Normal, uData;


type
  TDlg_SetPassword = class(TForm_Normal)
    Bt_Ok: TBitBtn;
    Bt_Cancel: TBitBtn;
    E_Pwd1: TDBEditEh;
    E_Pwd2: TDBEditEh;
    Lb_MinLen: TLabel;
    procedure Bt_OkClick(Sender: TObject);
  private
    { Private declarations }
    Mode1: Integer;
  public
    { Public declarations }
    function ShowDialog(aMode: Integer): Integer;
  end;

var
  Dlg_SetPassword: TDlg_SetPassword;

implementation

uses
  uForms,
  uString,
  uMessages,
  uDBOra
  ;

{$R *.dfm}

procedure TDlg_SetPassword.Bt_OkClick(Sender: TObject);
begin
  if E_Pwd1.Text <> E_Pwd2.Text
    then begin MyWarningMessage('������ �� ���������!'); Exit; end;
  if length(E_Pwd1.Text) < 5
    then begin MyWarningMessage('������ ������� ��������!'); Exit; end;
  if MyQuestionMessage('���������� ����� ' + Self.Caption + '?') <> mrYes then Exit;
  if Mode1 = 1 then begin
    Q.QExecSql('update adm_users set pwd = get_hash_val(:pwd) where id = 0', [E_Pwd1.text]);
  end
  else begin
    Q.QExecSql('update adm_password set password = get_hash_val(:pwd)', [E_Pwd1.text]);
  end;
  Self.Close;
end;

function TDlg_SetPassword.ShowDialog(aMode: Integer): Integer;
begin
  Cth.SetDialogForm(Self, fNone, '' + S.IIf(aMode = 1, '������ ��������������', '������������� ������'));
  Mode1 := aMode;
  Cth.SetBtn(Bt_Ok, mybtOk);
  Cth.SetBtn(Bt_Cancel, mybtCancel);
  ShowModal;
end;


end.
