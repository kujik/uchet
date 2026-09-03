{
Установливает новый пароль администратора или универсальный пароль
Вызыввается из модуля Администрирование, только при входе под пользователем Администратор
}
unit uFrmADEdtSetPassword;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, DBCtrlsEh,
  uFrmBasicMdi, uData, Vcl.Mask;


type
  TFrmADEdtSetPassword = class(TFrmBasicMdi)
    edt_Pwd1: TDBEditEh;
    edt_Pwd2: TDBEditEh;
    lbl_MinLen: TLabel;
  private
    { Private declarations }
    Mode1: Integer;
    FTitle: string;
    procedure VerifyBeforeSave; override;
    function Save: Boolean; override;
  public
    { Public declarations }
    function ShowDialog(AOwner: TObject; aMode: Integer): Boolean;
  end;

var
  FrmADEdtSetPassword: TFrmADEdtSetPassword;

implementation

uses
  uString,
  uDBOra
  ;

{$R *.dfm}

function TFrmADEdtSetPassword.ShowDialog(AOwner: TObject; aMode: Integer): Boolean;
begin
  Mode1 := aMode;
  FTitle := S.IIfStr(aMode = 1, 'Пароль администратора', 'Универсальный пароль');
  PrepareCreatedForm(AOwner, Self.Name, '~' + FTitle, fEdit, null, [], [myfoModal, myfoDialog, myfoDialogButtonsB, myfoSizeable]);
  edt_Pwd1.Text := '';
  edt_Pwd2.Text := '';
  Result := ShowModal = mrOk;
end;

procedure TFrmADEdtSetPassword.VerifyBeforeSave;
//проверка перед сохранением (см. TFrmBasicMdi.btnOkClick): если FErrorMessage начинается с '?' - показывается
//вопрос (Да - сохраняем), иначе - предупреждение (сохранение блокируется). см. также аналогичный пример в
//TFrmADedtMainSettings.VerifyBeforeSave
begin
  if edt_Pwd1.Text <> edt_Pwd2.Text then begin
    FErrorMessage := 'Пароли не совпадают!';
    Exit;
  end;
  if Length(edt_Pwd1.Text) < 5 then begin
    FErrorMessage := 'Пароль слишком короткий!';
    Exit;
  end;
  FErrorMessage := '?Установить новый ' + FTitle + '?';
end;

function TFrmADEdtSetPassword.Save: Boolean;
begin
  if Mode1 = 1 then
    Q.QExecSql('update adm_users set pwd = get_hash_val(:pwd) where id = 0', [edt_Pwd1.text])
  else
    Q.QExecSql('update adm_password set password = get_hash_val(:pwd)', [edt_Pwd1.text]);
  Result := True;
end;

end.
