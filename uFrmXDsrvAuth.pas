{
����� �����������
���������� ����� ��������� ������� �����, � ��� ��������� �����������
���������� � ������� User ������ uData

����������� �������� �� ������ ������������, ���� �� �� �����, ���
�� �������������� ������, ����� ��������������, ������� ������ ��� �����

����� �������� ������ ������������, ������� �������, � ������� ����� �������� � ������ �������,
� ��� ����� � �� ��� �� ������ ��� �������������� ��-�� ������� ������
(�� �������� ������ ��������), �� �� ����� �������� ����������

����� �������� ����������, ���� ������� �������������� � ���������� � ������� ������� ���� �� ��������

����� �� �������������� ������ ����� � ��� ����� � ��� ���������� �������������, ���� �� ���� � ������
}

unit uFrmXDsrvAuth;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, Mask, uData, uForms, uDBOra, uString, uMessages,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls;


type
  TFrmXDsrvAuth = class(TForm)
    cmbUser: TDBComboBoxEh;
    edtPwd: TDBEditEh;
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    imgUchet: TImage;
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure ImgUchetDblClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FShowNoActiveUsers: Boolean;
  public
    { Public declarations }
    function ShowDialog: Integer;
    class function Execute(ExitIfLogged: Boolean = True): Integer;
  end;

var
  FrmXDsrvAuth: TFrmXDsrvAuth;

implementation


{$R *.dfm}

uses uFrmMain;

//uses uFrmMain;

procedure TFrmXDsrvAuth.btnCancelClick(Sender: TObject);
begin
  if Not(User.IsLogged) then
    begin
      Hide;
    end;
end;

procedure TFrmXDsrvAuth.btnOkClick(Sender: TObject);
var
  v: TVarDynArray;
  b: Boolean;
begin
  if User.LoginManual(cmbUser.text, edtPwd.text)
    then begin
      ModalResult:=mrOk;
      Hide;
    end
    else begin
      MessageDlg('������ �����������!', mtError, [mbOk], 0);
    end;
end;

function TFrmXDsrvAuth.ShowDialog: Integer;
begin
  Cth.SetDialogForm(Self, fNone, '�����������');
  edtPwd.Text:='';
  cmbUser.Text:='';
  FShowNoActiveUsers:=False;
  User.SetUsersComboBox(cmbUser);
  Result:=ShowModal;
end;

procedure TFrmXDsrvAuth.ImgUchetDblClick(Sender: TObject);
begin
  if cmbUser.Text <> '�������������' then Exit;
  FShowNoActiveUsers:=True;
  User.SetUsersComboBox(cmbUser, FShowNoActiveUsers);
end;

procedure TFrmXDsrvAuth.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then btnOkClick(nil);
end;

//�������� ������ �����������
//���� ExitIfLogged, �� ���� ���� ��� ���������� - ������� ��� �������   (���� - ��� ���������� �����, ��� - ��� �������)
//������� ������
class function TFrmXDsrvAuth.Execute(ExitIfLogged: Boolean = True): Integer;
begin
  //���� �� ���������, �������� ����� �������������
  if not User.IsLogged then User.LoginAuto;
  //���� ������� � �������� ���������� �� �����
  if ExitIfLogged and User.IsLogged then Exit;
  //������� ����� � �������� ������
  if FrmXDsrvAuth = nil then FrmXDsrvAuth:=TFrmXDsrvAuth.Create(nil);
  FrmXDsrvAuth.ShowDialog;
end;


end.
