{
 ¬ызываетс€ при любой ошибке, если при этом соедиенение с Ѕƒ Orace разорвано.
 Ќе вызываетс€, если соедиенени€ нет при старте программы, там свой диалог!

 ¬ыводим сообщение об ошибке подключени€ к базе данных
 ѕопыток преконнектитьс€ не делаем - это порушит все блокировки
 ѕри закрытии формы завершаем приложение немедленно, использу€ Halt -
 чтобы не было ошибок или запросов при закрытии.
 ≈сли даже форму не закрывать, приложение автоматически завершитс€
 через 10 секунд (иногда возможна ситуаци€, что коно оказываетс€ на заднем
 плане и недоступно)

}

unit uFrmXDmsgNoConnection;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Vcl.Imaging.pngimage;

type
  TFrmXDmsgNoConnection = class(TForm)
    imgError: TImage;
    lblMessage: TLabel;
    btnClose: TBitBtn;
    tmr1: TTimer;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmXDmsgNoConnection: TFrmXDmsgNoConnection;

implementation

uses
  uFrmMain, uData, uErrors;

{$R *.dfm}

procedure TFrmXDmsgNoConnection.FormActivate(Sender: TObject);
begin
  Caption:=ModuleRecArr[cMainModule].Caption;
  tmr1.Enabled:= True;
end;

procedure TFrmXDmsgNoConnection.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Halt;
end;

procedure TFrmXDmsgNoConnection.tmr1Timer(Sender: TObject);
begin
  Halt;
end;

end.
