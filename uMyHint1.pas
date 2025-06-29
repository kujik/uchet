unit uMyHint1;

interface

uses
Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
Dialogs, ExtCtrls;

type
TForm2 = class(TForm)
tmr1: TTimer;
procedure tmr1Timer(Sender: TObject);
{ Private declarations }

{ Public declarations }
end;

TMyHint = Class ( THintWindow)
public
constructor Create(AOwner: TComponent); override;
procedure Paint ; Override;
procedure ActivateHint(Rect: TRect; const AHint: string); Override;
end;
var
Form2: TForm2;

implementation

{$R *.dfm}

constructor TMyHint.Create(AOwner: TComponent);
begin
inherited;
Form2 := TForm2.Create(self);
Form2.Show;
end;

procedure TMyHint.Paint;
var Cp : TPoint;
begin
GetCursorPos(Cp);
Form2.Top := Cp.Y + 2;
Form2.Left := Cp.X + 2;
Form2.Caption := Caption;
Form2.tmr1.Enabled := False;
Form2.tmr1.Enabled := True;
Form2.Show;
end;

procedure TMyHint.ActivateHint(Rect: TRect; const AHint: string);
begin
Caption := AHint;
Paint;
end;

procedure TForm2.tmr1Timer(Sender: TObject);
begin
Close;
end;

end.

