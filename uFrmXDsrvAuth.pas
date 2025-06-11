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
    CbUser: TDBComboBoxEh;
    EPwd: TDBEditEh;
    BtOk: TBitBtn;
    BtCancel: TBitBtn;
    ImgUchet: TImage;
    procedure BtOkClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure ImgUchetDblClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    ShowNoActiveUsers: Boolean;
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

procedure TFrmXDsrvAuth.BtCancelClick(Sender: TObject);
begin
  if Not(User.IsLogged) then
    begin
      Hide;
    end;
end;

procedure TFrmXDsrvAuth.BtOkClick(Sender: TObject);
var
  v: TVarDynArray;
  b: Boolean;
begin
  if User.LoginManual(CbUser.text, EPwd.text)
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
  EPwd.Text:='';
  CbUser.Text:='';
  ShowNoActiveUsers:=False;
  User.SetUsersComboBox(CbUser);
  Result:=ShowModal;
end;

procedure TFrmXDsrvAuth.ImgUchetDblClick(Sender: TObject);
begin
  if CbUser.Text <> '�������������' then Exit;
  ShowNoActiveUsers:=True;
  User.SetUsersComboBox(CbUser, ShowNoActiveUsers);
end;

procedure TFrmXDsrvAuth.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then BtOkClick(nil);
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
