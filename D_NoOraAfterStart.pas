unit D_NoOraAfterStart;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls, Vcl.Buttons, uData, uMessages, uDBOra;

type
  TDlg_NoOraAfterStart = class(TForm)
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
  Dlg_NoOraAfterStart: TDlg_NoOraAfterStart;

implementation

uses
  uString;

{$R *.dfm}

class function TDlg_NoOraAfterStart.Execute: Boolean;
begin
  Result:=Q.Connected;
  {$IFDEF SRV}
  Exit;
  {$ENDIF}
  if Result then exit;
  Dlg_NoOraAfterStart:=TDlg_NoOraAfterStart.Create(nil);
  Dlg_NoOraAfterStart.Caption:=ModuleRecArr[cMainModule].Caption;
  Dlg_NoOraAfterStart.Lb_Message.Caption:=S.IIFStr(Q.ConnectionFileFull = '',
    'В каталоге программы не найден файл настроек соединения "connect.udl"',
    'Запустите файл "connect.udl" в каталоге программы, настройте и проверьте подключение.'
  );
  Dlg_NoOraAfterStart.ShowModal;
end;

end.
