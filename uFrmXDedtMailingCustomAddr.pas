unit uFrmXDedtMailingCustomAddr;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_Normal, Vcl.StdCtrls, Vcl.Mask,
  DBCtrlsEh, Vcl.Buttons, Vcl.ExtCtrls, Types, uFrmBasicMdi;

type
  TFrmXDedtMailingCustomAddr = class(TFrmBasicMdi)
    edtAddr: TDBEditEh;
  private
    FOldMailAddr, FNewMailAddr: string;
    procedure VerifyBeforeSave; override;
  public
    function ShowDialog(var MailAddr: string): Boolean;
  end;

var
  FrmXDedtMailingCustomAddr: TFrmXDedtMailingCustomAddr;

implementation

uses
  uForms,
  uData,
  uString,
  uMessages
  ;


{$R *.dfm}

procedure TFrmXDedtMailingCustomAddr.VerifyBeforeSave;
var
  i:Integer;
  v: TStringDynArray;
  st: string;
  b: Boolean;
begin
  v := A.ExplodeS(edtAddr.Text, ',');
  st := '';
  b := True;
  for i := 0 to High(v) do begin
    if (Trim(v[i]) <> '') and not (S.IsValidEmail(Trim(v[i]))) then begin
      b := False;
    end;
    if Trim(v[i]) <> '' then
      st := S.ConcatSt(st, Trim(v[i]), ',');
  end;
  edtAddr.Text := st;
  if not (b) and (st <> '') then
    FErrorMessage := '������ �������� ������������ ������ ����������� �����!';
end;

function TFrmXDedtMailingCustomAddr.ShowDialog(var MailAddr: string): Boolean;
begin
  PrepareCreatedForm(Application, '', '~�������������� ������ ����������� �����', fEdit, null, [myfoModal, myfoDialog, myfoDialogButtonsB, myfoSizeable]);
  edtAddr.Text := MailAddr;
  FOpt.InfoArray :=[['��������� ����� ������� ������������ ������ �����, ������� ����� ����� �������������� ��� ��������, ������������� � ������� ��������� �������������.']];
  Result := ShowModal = mrOk;
  if not Result then
    Exit;
  MailAddr := edtAddr.Text;
end;


end.
