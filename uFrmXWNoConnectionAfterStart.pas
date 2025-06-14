unit uFrmXWNoConnectionAfterStart;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls, Vcl.Buttons, uData, uMessages, uDBOra;

type
  TFrmXWNoConnectionAfterStart = class(TForm)
    BitBtn2: TBitBtn;
    Image1: TImage;
    Label1: TLabel;
    Lb_Message: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
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
  FrmXWNoConnectionAfterStart.Lb_Message.Caption:=S.IIFStr(Q.ConnectionFileFull = '',
    'В каталоге программы не найден файл настроек соединения "connect.udl"',
    'Запустите файл "connect.udl" в каталоге программы, настройте и проверьте подключение.'
  );
  FrmXWNoConnectionAfterStart.ShowModal;
end;

end.
