{
форма авторизации
вызывается перед созданием главной формы, и при повторной авторизации
вызывается в объекте User додуля uData

авторизация проходит по паролю пользователя, если он не путой, или
по универсальному паролю, кроме администратора, который только под своим

будут показаны только пользователи, которые активны, и которые могут работать с данным модулем,
в том числе и те кто не смогут тут авторизоваться из-за пустого пароля
(им доступен только автовход), но не будут показаны неактивные

чтобы показать неактивных, надо вабрать администратора в комбобоксе и сделать двойной клик на картинке

войти по универсальному паролю можно в том числе и под неактивным пользователем, если он есть в списке
}

unit uFrmXDsrvAuth;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, uData, uForms, uString, uMessages,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls, Vcl.Mask;


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
      MessageDlg('Ошибка авторизации!', mtError, [mbOk], 0);
    end;
end;

function TFrmXDsrvAuth.ShowDialog: Integer;
begin
  Cth.SetDialogForm(Self, fNone, 'Авторизация');
  edtPwd.Text:='';
  cmbUser.Text:='';
  FShowNoActiveUsers:=False;
  User.SetUsersComboBox(cmbUser);
  Result:=ShowModal;
end;

procedure TFrmXDsrvAuth.ImgUchetDblClick(Sender: TObject);
begin
  if cmbUser.Text <> 'Администратор' then Exit;
  FShowNoActiveUsers:=True;
  User.SetUsersComboBox(cmbUser, FShowNoActiveUsers);
end;

procedure TFrmXDsrvAuth.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then btnOkClick(nil);
end;

//основной диалог авторизации
//если ExitIfLogged, то если юзер уже залогитнен - выходим без диалога   (фолс - для повторного входа, тру - для первого)
//функция класса
class function TFrmXDsrvAuth.Execute(ExitIfLogged: Boolean = True): Integer;
begin
  //если не залогинен, пытаемся войти автоматически
  if not User.IsLogged then User.LoginAuto;
  //если удалось и параметр установлен то выход
  if ExitIfLogged and User.IsLogged then Exit;
  //создаем форму и вызываем диалог
  if FrmXDsrvAuth = nil then FrmXDsrvAuth:=TFrmXDsrvAuth.Create(nil);
  FrmXDsrvAuth.ShowDialog;
end;


end.
