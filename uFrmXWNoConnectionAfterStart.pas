unit uFrmXWNoConnectionAfterStart;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls, Vcl.Buttons, uData, uMessages, uDBOra;

type
  TFrmXWNoConnectionAfterStart = class(TForm)
    btnOk: TBitBtn;
    imgError: TImage;
    lblText: TLabel;
    lblMessage: TLabel;
  private
  public
    class function Execute: Boolean;
  end;

var
  FrmXWNoConnectionAfterStart: TFrmXWNoConnectionAfterStart;

implementation

uses
  uString;

{$R *.dfm}

class function TFrmXWNoConnectionAfterStart.Execute: Boolean;
begin
  Result:=Q.Connected;
  {$IFDEF SRV}
  Exit;
  {$ENDIF}
  if Result then exit;
  FrmXWNoConnectionAfterStart:=TFrmXWNoConnectionAfterStart.Create(nil);
  FrmXWNoConnectionAfterStart.Caption:=ModuleRecArr[cMainModule].Caption;
  FrmXWNoConnectionAfterStart.lblMessage.Caption:=S.IIFStr(Q.ConnectionFileFull = '',
    'В каталоге программы не найден файл настроек соединения "connect.udl"',
    'Запустите файл "connect.udl" в каталоге программы, настройте и проверьте подключение.'
  );
  FrmXWNoConnectionAfterStart.ShowModal;
end;

end.
