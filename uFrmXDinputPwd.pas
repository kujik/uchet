{
диалог запроса пароля
передается массив допустимых паролей, диалог возвращает номер введенного, при ошибке выдает сообщение, при отмене вернет -1
если вызван ShowDialogP, то по Ок всегда выйдет с результатом, равным введенному тексту
}

unit uFrmXDinputPwd;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,Vcl.StdCtrls,
  DBCtrlsEh, Vcl.ExtCtrls, Vcl.Mask,
  uFrmBasicMdi, uData, uString
  ;

type
  TFrmXDinputPwd = class(TFrmBasicMdi)
    edtPwd: TDBEditEh;
    procedure edtPwdKeyPress(Sender: TObject; var Key: Char);
  private
    FPwds: TVarDynArray;
    procedure VerifyBeforeSave; override;
  public
    function ShowDialog(AOwner: TObject; APwds: TVarDynArray): Integer;
    function ShowDialogP(AOwner: TObject): string;
  end;

var
  FrmXDinputPwd: TFrmXDinputPwd;

implementation

{$R *.dfm}

procedure TFrmXDinputPwd.edtPwdKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if Key = #13 then btnOk.Click;
end;

function TFrmXDinputPwd.ShowDialog(AOwner: TObject; APwds: TVarDynArray): Integer;
begin
  Result := -1;
  PrepareCreatedForm(AOwner, Self.Name, '~*', fEdit, null, [], [myfoModal, myfoDialog, myfoDialogButtonsB]);
  FPwds := APwds;
  edtPwd.Text := '';
  if ShowModal = mrOk then
    if (Length(FPwds) > 0) then
      Result := A.PosInArray(edtPwd.Text, APwds)
    else
      Result := 0;
end;

function TFrmXDinputPwd.ShowDialogP(AOwner: TObject): string;
begin
  Result := '';
  PrepareCreatedForm(AOwner, Self.Name, '~*', fEdit, null, [], [myfoModal, myfoDialog, myfoDialogButtonsB]);
  FPwds := [];
  edtPwd.Text := '';
  if ShowModal = mrOk then
    Result := edtPwd.Text
  else
    Result := '';
end;


procedure TFrmXDinputPwd.VerifyBeforeSave;
begin
  if (Length(FPwds) > 0) and not A.InArray(edtPwd.Text, FPwds) then
    FErrorMessage := 'Ошибка!';
end;


end.
