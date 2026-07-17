{
 Вызывается при любой ошибке, если при этом соедиенение с БД Orace разорвано.
 Не вызывается, если соедиенения нет при старте программы, там свой диалог!

 Выводим сообщение об ошибке подключения к базе данных
 Попыток преконнектиться не делаем - это порушит все блокировки
 При закрытии формы завершаем приложение немедленно, используя Halt -
 чтобы не было ошибок или запросов при закрытии.
 Если даже форму не закрывать, приложение автоматически завершится
 через 10 секунд (иногда возможна ситуация, что коно оказывается на заднем
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
  uData;

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
