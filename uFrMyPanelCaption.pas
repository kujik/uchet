unit uFrMyPanelCaption;

{
  Фрейм с заголовком и информационными иконками.
  Размещается в верхней панели формы, содержит:
  - разделительную полосу (Bevel),
  - панель с заголовком,
  - иконку информации (с подсказкой/окном),
  - иконку ошибки (индикатор).
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage,
  uString;

const
  DEFAULT_ERROR_MSG = 'Ошибка в данных!';

type
  TFrMyPanelCaption = class(TFrame)
    bvl1: TBevel;
    pnlCaption: TPanel;
    lblCaption: TLabel;
    pnlInfo: TPanel;
    imgInfo: TImage;
    pnlError: TPanel;
    imgError: TImage;
    procedure imgErrorClick(Sender: TObject);
  private
    FHasError: Boolean;
    FAutoErrorMode: Boolean;          // автоматически обновлять ошибку по дочерним контролам
    FDefErrorMessage: string;          // сообщение об ошибке по умолчанию
    FManualMessage: string;            // сообщение, установленное вручную (если не пусто, не сбрасываем автоматически)
    FAutoClearError: Boolean;          // автоматически сбрасывать ошибку при её отсутствии
  public
    // установка параметров фрейма: видимость, заголовок, информация, дефолтное сообщение ошибки, авторежим
    procedure SetParameters(AVisible: Boolean; ACaption: Variant; AInfo: TVarDynArray2; ADefErrorMessage: string = ''; AAutoError: Boolean = False);
    // установка состояния ошибки и сообщения (если сообщение пустое, используется дефолтное)
    procedure SetError(AHasError: Boolean; AAutoClearError: Boolean; AErrorMessage: string = ''); overload;
    procedure SetError(AHasError: Boolean; AErrorMessage: string = ''); overload;
    // включение режима автообновления ошибки
    procedure SetAutoError(AAuto: Boolean);
    // обновление статуса ошибки на основе дочерних контролов в родительской панели (вызывается из базовой формы)
    procedure UpdateErrorFromChildren;
    // свойства
    property HasError: Boolean read FHasError;
    property AutoErrorMode: Boolean read FAutoErrorMode;
    property AutoClearError: Boolean read FAutoClearError;
  end;

implementation

uses
  uForms,
  uMessages,
  uData; // для Cth

{$R *.dfm}

procedure TFrMyPanelCaption.SetParameters(AVisible: Boolean; ACaption: Variant; AInfo: TVarDynArray2; ADefErrorMessage: string = ''; AAutoError: Boolean = False);
// установка видимости, заголовка, иконки информации и ошибки
begin
  lblCaption.Caption := ' ' + ACaption + ' ';
  pnlCaption.Width := lblCaption.Width;
  pnlInfo.Visible := Length(AInfo) > 0;
  pnlInfo.Left := pnlCaption.Left + pnlCaption.Width + 8;
  Cth.SetInfoIcon(TImage(imgInfo), Cth.SetInfoIconText(TForm(Self), AInfo), 18);

  // сохранение дефолтного сообщения ошибки
  if ADefErrorMessage = '' then
    FDefErrorMessage := DEFAULT_ERROR_MSG
  else
    FDefErrorMessage := ADefErrorMessage;

  // начальное состояние – без ошибки
  SetError(False);

  FAutoClearError := True;

  pnlError.Left := pnlInfo.Left + S.IIf(pnlInfo.Visible, pnlInfo.Width + 8, 0);

  // включение авторежима, если указан
  if AAutoError then
    SetAutoError(True);
end;

procedure TFrMyPanelCaption.SetError(AHasError: Boolean; AErrorMessage: string = '');
begin
  FHasError := AHasError;

  if AHasError then
  begin
    if AErrorMessage = '' then
      pnlError.Hint := FDefErrorMessage
    else
      pnlError.Hint := AErrorMessage;
    // запоминаем, если сообщение нестандартное (отличается от дефолтного)
    if (AErrorMessage <> '') and (AErrorMessage <> FDefErrorMessage) then
      FManualMessage := AErrorMessage
    else
      FManualMessage := '';
    pnlError.Visible := True;
  end
  else
  begin
    pnlError.Hint := '';
    FManualMessage := '';
    pnlError.Visible := False;
  end;
  // принудительное обновление панели и фрейма
  pnlError.Invalidate;
  if Parent <> nil then
    Parent.Invalidate;
  Invalidate;
end;

procedure TFrMyPanelCaption.SetError(AHasError: Boolean; AAutoClearError: Boolean; AErrorMessage: string = '');
// установка индикатора ошибки и подсказки
begin
  FAutoClearError := AAutoClearError;
  SetError(AHasError, AErrorMessage);
end;


procedure TFrMyPanelCaption.SetAutoError(AAuto: Boolean);
// включение/выключение автообновления ошибки по дочерним контролам
begin
  FAutoErrorMode := AAuto;
  if AAuto then
    UpdateErrorFromChildren;
end;

procedure TFrMyPanelCaption.UpdateErrorFromChildren;
// обновление статуса ошибки на основе дочерних контролов в родительской панели
begin
  // Этот метод вызывается из TFrmBasicMdi после проверки формы.
  // Здесь мы не реализуем проверку, а только устанавливаем ошибку, если родительская форма вызовет SetError.
  // Сама проверка выполняется в TFrmBasicMdi.
end;

procedure TFrMyPanelCaption.imgErrorClick(Sender: TObject);
// показ сообщения об ошибке по клику на иконку
begin
  if pnlError.Hint <> '' then
    MyWarningMessage(pnlError.Hint, 1);
end;

end.unit uFrMyPanelCaption;

{
  Фрейм с заголовком и информационными иконками.
  Размещается в верхней панели формы, содержит:
  - разделительную полосу (Bevel),
  - панель с заголовком,
  - иконку информации (с подсказкой/окном),
  - иконку ошибки (индикатор).
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage,
  uString;

const
  DEFAULT_ERROR_MSG = 'Ошибка в данных!';

type
  TFrMyPanelCaption = class(TFrame)
    bvl1: TBevel;
    pnlCaption: TPanel;
    lblCaption: TLabel;
    pnlInfo: TPanel;
    imgInfo: TImage;
    pnlError: TPanel;
    imgError: TImage;
    procedure imgErrorClick(Sender: TObject);
  private
    FHasError: Boolean;
    FAutoErrorMode: Boolean;           // автоматически обновлять ошибку по дочерним контролам
    FDefErrorMessage: string;          // сообщение об ошибке по умолчанию
    FManualMessage: string;            // сообщение, установленное вручную (если не пусто, не сбрасываем автоматически)
    FAutoClearError: Boolean;          // автоматически сбрасывать ошибку при её отсутствии
  public
    // установка параметров фрейма: видимость, заголовок, информация, дефолтное сообщение ошибки, авторежим
    procedure SetParameters(AVisible: Boolean; ACaption: Variant; AInfo: TVarDynArray2; ADefErrorMessage: string = ''; AAutoError: Boolean = False);
    // установка состояния ошибки и сообщения (если сообщение пустое, используется дефолтное)
    procedure SetError(AHasError: Boolean; AErrorMessage: string = ''; AAutoClearError: Boolean = False);
    // включение режима автообновления ошибки
    procedure SetAutoError(AAuto: Boolean);
    // обновление статуса ошибки на основе дочерних контролов в родительской панели (вызывается из базовой формы)
    procedure UpdateErrorFromChildren;
    // свойства
    property HasError: Boolean read FHasError;
    property AutoErrorMode: Boolean read FAutoErrorMode;
    property AutoClearError: Boolean read FAutoClearError;
  end;

implementation

uses
  uForms,
  uMessages,
  uData; // для Cth

{$R *.dfm}

procedure TFrMyPanelCaption.SetParameters(AVisible: Boolean; ACaption: Variant; AInfo: TVarDynArray2; ADefErrorMessage: string = ''; AAutoError: Boolean = False);
// установка видимости, заголовка, иконки информации и ошибки
begin
  lblCaption.Caption := ' ' + ACaption + ' ';
  pnlCaption.Width := lblCaption.Width;
  pnlInfo.Visible := Length(AInfo) > 0;
  pnlInfo.Left := pnlCaption.Left + pnlCaption.Width + 8;
  Cth.SetInfoIcon(TImage(imgInfo), Cth.SetInfoIconText(TForm(Self), AInfo), 18);

  // сохранение дефолтного сообщения ошибки
  if ADefErrorMessage = '' then
    FDefErrorMessage := DEFAULT_ERROR_MSG
  else
    FDefErrorMessage := ADefErrorMessage;

  // начальное состояние – без ошибки
  SetError(False);

  pnlError.Left := pnlInfo.Left + S.IIf(pnlInfo.Visible, pnlInfo.Width + 8, 0);

  FAutoClearError := True;

  // включение авторежима, если указан
  if AAutoError then
    SetAutoError(True);
end;

procedure TFrMyPanelCaption.SetError(AHasError: Boolean; AErrorMessage: string = ''; AAutoClearError: Boolean);
begin
  FAutoClearError := AAutoClearError;
  SetError(AHasError:, AErrorMessage);
end;

procedure TFrMyPanelCaption.SetError(AHasError: Boolean; AErrorMessage: string = '');
// установка индикатора ошибки и подсказки
begin
  FHasError := AHasError;

  if AHasError then
  begin
    if AErrorMessage = '' then
      pnlError.Hint := FDefErrorMessage
    else
      pnlError.Hint := AErrorMessage;
    // запоминаем, если сообщение нестандартное (отличается от дефолтного)
    if (AErrorMessage <> '') and (AErrorMessage <> FDefErrorMessage) then
      FManualMessage := AErrorMessage
    else
      FManualMessage := '';
    pnlError.Visible := True;
  end
  else
  begin
    pnlError.Hint := '';
    FManualMessage := '';
    pnlError.Visible := False;
  end;
  // принудительное обновление панели и фрейма
  pnlError.Invalidate;
  if Parent <> nil then
    Parent.Invalidate;
  Invalidate;
end;



procedure TFrMyPanelCaption.SetAutoError(AAuto: Boolean);
// включение/выключение автообновления ошибки по дочерним контролам
begin
  FAutoErrorMode := AAuto;
  if AAuto then
    UpdateErrorFromChildren;
end;

procedure TFrMyPanelCaption.UpdateErrorFromChildren;
// обновление статуса ошибки на основе дочерних контролов в родительской панели
begin
  // Этот метод вызывается из TFrmBasicMdi после проверки формы.
  // Здесь мы не реализуем проверку, а только устанавливаем ошибку, если родительская форма вызовет SetError.
  // Сама проверка выполняется в TFrmBasicMdi.
end;

procedure TFrMyPanelCaption.imgErrorClick(Sender: TObject);
// показ сообщения об ошибке по клику на иконку
begin
  if pnlError.Hint <> '' then
    MyWarningMessage(pnlError.Hint, 1);
end;

end.
