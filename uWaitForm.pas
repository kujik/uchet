{
модуль для показа формы ожидания (например, при долгих операциях).
выводится отцкентрированная относительно текущего окна форма без заголовка с переданным текстом (может быть многострочный),
по размеру подогнанныая под размер текста. Если тект не передан или пустой, выводится фраза "Обработка данных..."

внимание! при выводе формы для отображения делается однократно ProcessMessages!

если все долгие вычисления производятся в одном потоке и без вывода форм (или дрйгих действий, когда освободится ресурс
и начнут проходить сообщения), то форму можно не закрывать явно, при параметрах по умолчанию она закроется сама при разблокировке сообщений.
для того, чтобя этого не произошло, вторым параметром передать 0. если передано число, то закроется после этого времени в секундах,
когда пойдут сообщения.

третьим парамтром можно передать процедуру, в этом случае форма закроется после ее выполнения.

может быть проблема, если прямо в коде вызывается стандартный моадльные диалог дельфи, в этом случае диалог не отобразится и программа заблокируется.
в базовых формах и uMessages сделано HideWaitForm и этой проблемы нет.

//обычное примеенение
ShowWaitForm;
Sleep(3000);
ShowWaitForm('Привет!'#13#10'Производится очень долгая операция!');
Sleep(3000);

//с процедурой
ShowWaitForm('Загрузка данных...', 0,
  procedure
  begin
    // Ваш длительный код
    Sleep(5000);
  end);

//явно закрыть
ShowWaitForm('', 0);
HideWaitForm;

}



unit uWaitForm;

interface

uses
  System.SysUtils, System.Classes, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
  Vcl.Graphics, Vcl.ExtCtrls, Math;

//показывает форму
procedure ShowWaitForm(const AMessage: string = ''; ATimeoutSec: Extended = 0.001; AProc: TProc = nil);
//Скрывает форму (для ручного управления).

procedure HideWaitForm;

implementation

type
  TWaitForm = class(TForm)
  private
    FMessageLabel: TLabel;
    FHideTimer: TTimer;
    procedure TimerHandler(Sender: TObject);
  public
    constructor CreateNew(AOwner: TComponent; AMessage: string);
  end;

var
  WaitFormInstance: TWaitForm = nil;

constructor TWaitForm.CreateNew(AOwner: TComponent; AMessage: string);
begin
  inherited CreateNew(AOwner);
  BorderStyle := bsNone;
  Color := clWhite;
  FormStyle := fsStayOnTop;
  Width := 500;
  Height := 400;

  FMessageLabel := TLabel.Create(Self);
  FMessageLabel.Parent := Self;
  FMessageLabel.Layout := tlCenter;
  FMessageLabel.Font.Size := 12;
  FMessageLabel.Font.Style := [fsBold];
  FMessageLabel.Transparent := True;
  FMessageLabel.AutoSize := True;
  if AMessage = '' then
    FMessageLabel.Caption := 'Обработка данных...'
  else
    FMessageLabel.Caption := AMessage;
  Width := FMessageLabel.Width + 20;
  Height := FMessageLabel.Height + 6;
  FMessageLabel.Left := 10;
  FMessageLabel.Top := 3;

  FHideTimer := TTimer.Create(Self);
  FHideTimer.Enabled := False;
  FHideTimer.OnTimer := TimerHandler;
end;

procedure TWaitForm.TimerHandler(Sender: TObject);
begin
  FHideTimer.Enabled := False;
  FHideTimer.Interval := 0;
  HideWaitForm;
end;

procedure PositionWaitForm;
var
  LActiveForm: TForm;
begin
  if WaitFormInstance = nil then
    Exit;
  LActiveForm := Screen.ActiveForm;
  if (LActiveForm = nil) or not (LActiveForm is TForm) then
    LActiveForm := Application.MainForm;
  WaitFormInstance.Position := poDesigned;
  WaitFormInstance.Left := Max(LActiveForm.Left + (LActiveForm.Width - WaitFormInstance.Width) div 2, 0);
  WaitFormInstance.Top := Max(LActiveForm.Top + (LActiveForm.Height - WaitFormInstance.Height) div 2, 0);
end;

procedure StartTimer(ASeconds: Extended);
begin
  if (WaitFormInstance <> nil) and (ASeconds > 0) then begin
    WaitFormInstance.FHideTimer.Interval := Round(ASeconds * 1000);
    WaitFormInstance.FHideTimer.Enabled := True;
  end;
end;

procedure StopTimer;
begin
  if WaitFormInstance <> nil then
    WaitFormInstance.FHideTimer.Enabled := False;
end;

procedure ShowWaitForm(const AMessage: string; ATimeoutSec: Extended; AProc: TProc);
begin
  HideWaitForm;
  if WaitFormInstance = nil then
    WaitFormInstance := TWaitForm.CreateNew(Application, AMessage);
  PositionWaitForm;
  WaitFormInstance.Show;
  WaitFormInstance.BringToFront;
  Application.ProcessMessages;
  if not Assigned(AProc) then
    StartTimer(ATimeoutSec);
  if Assigned(AProc) then begin
    try
      AProc();
    finally
      StopTimer;
      HideWaitForm;
    end;
  end;
end;

procedure HideWaitForm;
begin
  StopTimer;
  try
    if WaitFormInstance <> nil then
      FreeAndNil(WaitFormInstance);
  except
  end;
end;

initialization

finalization

end.

