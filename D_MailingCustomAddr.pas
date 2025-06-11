unit D_MailingCustomAddr;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_Normal, Vcl.StdCtrls, Vcl.Mask,
  DBCtrlsEh, Vcl.Buttons, Vcl.ExtCtrls, Types;

type
  TDlg_MailingCustomAddr = class(TForm_Normal)
    Bt_Ok: TBitBtn;
    Bt_Cancel: TBitBtn;
    E_Addr: TDBEditEh;
    Img_Info: TImage;
    procedure Bt_OkClick(Sender: TObject);
  private
    { Private declarations }
    OldMailAddr, NewMailAddr: string;
  public
    { Public declarations }
    function ShowDialog(var MailAddr: string): Boolean;
  end;

var
  Dlg_MailingCustomAddr: TDlg_MailingCustomAddr;

implementation

uses
  uForms,
  uData,
  uString,
  uMessages
  ;

{$R *.dfm}

procedure TDlg_MailingCustomAddr.Bt_OkClick(Sender: TObject);
var
  i:Integer;
  v: TStringDynArray;
  st: string;
  b: Boolean;
begin
  inherited;
  v:=A.ExplodeS(E_Addr.Text, ',');
  st:='';
  b:=True;
  for i:=0 to High(v) do begin
    if (Trim(v[i]) <> '') and not(S.IsValidEmail(Trim(v[i])))
      then begin b:=False; end;
    if Trim(v[i]) <> '' then st:=S.ConcatSt(st, Trim(v[i]), ',');
  end;
  E_Addr.Text:=st;
  if not(b) and (st<>'') then begin
    MyWarningMessage('Строка содержит недопустимые адреса электронной почты!');
    Exit;
  end;
  NewMailAddr:=E_Addr.Text;
  ModalResult:=mrOk;
end;

function TDlg_MailingCustomAddr.ShowDialog(var MailAddr: string): Boolean;
begin
  BorderStyle:=bsDialog;
  Cth.SetBtn(Bt_Ok, mybtOk, False);
  Cth.SetBtn(Bt_Cancel, mybtCancel, False);
  Cth.SetInfoIcon(Img_Info,
    'Введитете через запятую произвольные адреса почты, которые также будут использоваться для рассылки, дополнительно к адресам выбранных пользователей.',
    20);
  E_Addr.Text:= MailAddr;
  Result:=
    (ShowModal = mrOk) and (OldMailAddr <> NewMailAddr);
  if Result
    then MailAddr:=NewMailAddr;
end;

end.
