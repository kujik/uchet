unit uBarcode128;

interface

uses
  Windows, Classes, Graphics, Controls, Forms, StdCtrls, ExtCtrls;

//построение штрихкода Code128, набор символов B (буквы/цифры/большая часть
//печатной ASCII, без переключения на наборы A/C - для наших целей достаточно,
//т.к. все штрихкоды системы имеют вид <2 заглавные буквы-префикс><число>,
//то есть используются только символы с кодами 32..95, все они есть в наборе B).
//таблица штрихов и алгоритм контрольной суммы проверены round-trip декодированием
//через библиотеку ZXing (тот же декодер, что использует scan.html) - см. Алгоритмы,
//раздел 5.

//пытается закодировать AText в штрихи Code128B; возвращает строку из символов
//'0'/'1' (1 = чёрный модуль, 0 = белый), уже включающую стартовый символ,
//контрольную сумму и стоп-символ (без тихих зон по краям - их добавляет
//DrawCode128Bars); False, если в тексте есть символ вне диапазона кодов 32..95
//или текст пустой
function TryEncodeCode128B(const AText: string; out ABars: string): Boolean;

//рисует готовую последовательность модулей (см. TryEncodeCode128B) на канве
//начиная с точки (ALeft, ATop); AQuietModules - ширина тихой зоны по краям
//в модулях (рекомендуется не менее 10, см. спецификацию Code128)
procedure DrawCode128Bars(ACanvas: TCanvas; const ABars: string; ALeft, ATop, AModulePx, ABarHeightPx, AQuietModules: Integer);

//показывает немодальное окно со штрихкодом ABarcodeText (например 'EM123') и
//подписью ASubCaption под ним; используется для отладки сканера - проверить
//сканирование телефоном без печати настоящего бейджика/этикетки
//(см. uFrmWGjrnEmployees, Ctrl+Shift+B)
procedure ShowBarcode128Popup(const APopupCaption, ABarcodeText, ASubCaption: string);

//печатает штрихкод ABarcodeText на физическом принтере (диалог выбора принтера,
//см. TPrintDialog) - подпись APrintCaption сверху, ASubCaption снизу; размер
//штрихов считается из реального DPI выбранного принтера, чтобы модуль был около
//0.4 мм независимо от разрешения принтера (см. uFrmWGjrnEmployees, Ctrl+Alt+Shift+B)
procedure PrintBarcode128(const APrintCaption, ABarcodeText, ASubCaption: string);

implementation

uses
  Printers, Dialogs;

const
  //таблица штрихов Code128 (значения символов 0..106) - взята из проверенной
  //round-trip декодированием через ZXing таблицы (питон-библиотека
  //python-barcode, модуль barcode.charsets.code128.CODES) - см. Алгоритмы, раздел 5
  CODES: array[0..105] of string = (
    '11011001100','11001101100','11001100110','10010011000','10010001100',
    '10001001100','10011001000','10011000100','10001100100','11001001000',
    '11001000100','11000100100','10110011100','10011011100','10011001110',
    '10111001100','10011101100','10011100110','11001110010','11001011100',
    '11001001110','11011100100','11001110100','11101101110','11101001100',
    '11100101100','11100100110','11101100100','11100110100','11100110010',
    '11011011000','11011000110','11000110110','10100011000','10001011000',
    '10001000110','10110001000','10001101000','10001100010','11010001000',
    '11000101000','11000100010','10110111000','10110001110','10001101110',
    '10111011000','10111000110','10001110110','11101110110','11010001110',
    '11000101110','11011101000','11011100010','11011101110','11101011000',
    '11101000110','11100010110','11101101000','11101100010','11100011010',
    '11101111010','11001000010','11110001010','10100110000','10100001100',
    '10010110000','10010000110','10000101100','10000100110','10110010000',
    '10110000100','10011010000','10011000010','10000110100','10000110010',
    '11000010010','11001010000','11110111010','11000010100','10001111010',
    '10100111100','10010111100','10010011110','10111100100','10011110100',
    '10011110010','11110100100','11110010100','11110010010','11011011110',
    '11011110110','11110110110','10101111000','10100011110','10001011110',
    '10111101000','10111100010','11110101000','11110100010','10111011110',
    '10111101110','11101011110','11110101110','11010000100','11010010000',
    '11010011100'
  );
  STOP_PATTERN = '11000111010';
  START_CODE_B = 104;
  MIN_CHAR_CODE = 32; //пробел, ' '
  MAX_CHAR_CODE = 95; //подчёркивание, '_'

function TryEncodeCode128B(const AText: string; out ABars: string): Boolean;
var
  i, CharCode, CheckSum: Integer;
  Values: array of Integer;
begin
  Result := False;
  ABars := '';
  if Length(AText) = 0 then
    Exit;
  SetLength(Values, Length(AText) + 1);
  Values[0] := START_CODE_B;
  for i := 1 to Length(AText) do begin
    CharCode := Ord(AText[i]);
    if (CharCode < MIN_CHAR_CODE) or (CharCode > MAX_CHAR_CODE) then
      Exit; //символ не входит в поддерживаемый упрощённый набор B
    Values[i] := CharCode - MIN_CHAR_CODE;
  end;
  //контрольная сумма Code128: (стартовый символ + сумма(позиция * значение)) mod 103,
  //позиции символов данных нумеруются с 1 (см. Алгоритмы, раздел 5)
  CheckSum := Values[0];
  for i := 1 to High(Values) do
    CheckSum := CheckSum + i * Values[i];
  CheckSum := CheckSum mod 103;

  ABars := '';
  for i := 0 to High(Values) do
    ABars := ABars + CODES[Values[i]];
  ABars := ABars + CODES[CheckSum] + STOP_PATTERN + '11';
  Result := True;
end;

//общая обёртка над TryEncodeCode128B для ShowBarcode128Popup и PrintBarcode128 -
//чтобы сообщение об ошибке для пользователя не расходилось между ними
function TryEncodeOrShowError(const AText: string; out ABars: string): Boolean;
begin
  Result := TryEncodeCode128B(AText, ABars);
  if not Result then
    MessageBox(0, PChar('Не удалось построить штрихкод для "' + AText + '" - ' +
      'символ вне поддерживаемого диапазона (заглавные латинские буквы, цифры и часть пунктуации)'),
      PChar('Штрихкод'), MB_ICONERROR);
end;

procedure DrawCode128Bars(ACanvas: TCanvas; const ABars: string; ALeft, ATop, AModulePx, ABarHeightPx, AQuietModules: Integer);
var
  i, x: Integer;
begin
  ACanvas.Brush.Color := clWhite;
  ACanvas.Pen.Color := clWhite;
  ACanvas.FillRect(Rect(ALeft, ATop,
    ALeft + (Length(ABars) + AQuietModules * 2) * AModulePx, ATop + ABarHeightPx));
  ACanvas.Brush.Color := clBlack;
  x := ALeft + AQuietModules * AModulePx;
  for i := 1 to Length(ABars) do begin
    if ABars[i] = '1' then
      ACanvas.FillRect(Rect(x, ATop, x + AModulePx, ATop + ABarHeightPx));
    Inc(x, AModulePx);
  end;
end;

type
  //служебный компонент-держатель состояния для обработчика OnPaint -
  //создаётся с владельцем Frm, поэтому освобождается автоматически вместе
  //с формой (без ручного OnDestroy)
  TBarcodePopupHolder = class(TComponent)
  public
    Bars: string;
    ModulePx: Integer;
    BarHeightPx: Integer;
    QuietModules: Integer;
    procedure PaintBoxPaint(Sender: TObject);
  end;

procedure TBarcodePopupHolder.PaintBoxPaint(Sender: TObject);
begin
  DrawCode128Bars(TPaintBox(Sender).Canvas, Bars, 0, 0, ModulePx, BarHeightPx, QuietModules);
end;

procedure ShowBarcode128Popup(const APopupCaption, ABarcodeText, ASubCaption: string);
const
  MODULE_PX = 3;
  BAR_HEIGHT_PX = 120;
  QUIET_MODULES = 10;
var
  Bars: string;
  Frm: TForm;
  PB: TPaintBox;
  LblCode, LblSub: TLabel;
  Holder: TBarcodePopupHolder;
  PaintWidth: Integer;
begin
  if not TryEncodeOrShowError(ABarcodeText, Bars) then
    Exit;
  PaintWidth := (Length(Bars) + QUIET_MODULES * 2) * MODULE_PX;

  Frm := TForm.CreateNew(Application);
  Frm.Caption := APopupCaption;
  Frm.Position := poScreenCenter;
  Frm.BorderStyle := bsSizeToolWin;
  Frm.Width := PaintWidth + 40;
  Frm.Height := BAR_HEIGHT_PX + 110;

  Holder := TBarcodePopupHolder.Create(Frm);
  Holder.Bars := Bars;
  Holder.ModulePx := MODULE_PX;
  Holder.BarHeightPx := BAR_HEIGHT_PX;
  Holder.QuietModules := QUIET_MODULES;

  LblCode := TLabel.Create(Frm);
  LblCode.Parent := Frm;
  LblCode.Font.Size := 14;
  LblCode.Font.Style := [fsBold];
  LblCode.Caption := ABarcodeText;
  LblCode.Left := 16;
  LblCode.Top := 12;

  PB := TPaintBox.Create(Frm);
  PB.Parent := Frm;
  PB.Left := 16;
  PB.Top := LblCode.Top + LblCode.Height + 8;
  PB.Width := PaintWidth;
  PB.Height := BAR_HEIGHT_PX;
  PB.OnPaint := Holder.PaintBoxPaint;

  if ASubCaption <> '' then begin
    LblSub := TLabel.Create(Frm);
    LblSub.Parent := Frm;
    LblSub.Caption := ASubCaption;
    LblSub.Left := 16;
    LblSub.Top := PB.Top + PB.Height + 8;
  end;

  Frm.Show;
end;

procedure PrintBarcode128(const APrintCaption, ABarcodeText, ASubCaption: string);
const
  QUIET_MODULES = 10;
  MODULE_MM = 0.4;      //физическая ширина одного модуля, мм
  BAR_HEIGHT_MM = 25;   //физическая высота штрихов, мм
  MARGIN_MM = 10;       //отступ от края листа, мм
var
  Bars: string;
  Dlg: TPrintDialog;
  DpiX, DpiY: Integer;
  ModulePx, BarHeightPx, MarginXPx, MarginYPx, TextTop: Integer;
begin
  if not TryEncodeOrShowError(ABarcodeText, Bars) then
    Exit;

  Dlg := TPrintDialog.Create(nil);
  try
    if not Dlg.Execute then
      Exit;
  finally
    Dlg.Free;
  end;

  Printer.Title := APrintCaption;
  Printer.BeginDoc;
  try
    //DPI принтера доступен только пока идёт печать (между BeginDoc и EndDoc) -
    //поэтому считаем размеры в пикселях именно здесь, а не заранее
    DpiX := GetDeviceCaps(Printer.Handle, LOGPIXELSX);
    DpiY := GetDeviceCaps(Printer.Handle, LOGPIXELSY);
    ModulePx := Round(MODULE_MM / 25.4 * DpiX);
    if ModulePx < 2 then
      ModulePx := 2;
    BarHeightPx := Round(BAR_HEIGHT_MM / 25.4 * DpiY);
    MarginXPx := Round(MARGIN_MM / 25.4 * DpiX);
    MarginYPx := Round(MARGIN_MM / 25.4 * DpiY);

    Printer.Canvas.Font.Name := 'Arial';
    Printer.Canvas.Font.Size := 16;
    Printer.Canvas.Font.Style := [fsBold];
    Printer.Canvas.TextOut(MarginXPx, MarginYPx, APrintCaption);
    TextTop := MarginYPx + Printer.Canvas.TextHeight(APrintCaption) + MarginYPx div 2;

    DrawCode128Bars(Printer.Canvas, Bars, MarginXPx, TextTop, ModulePx, BarHeightPx, QUIET_MODULES);
    TextTop := TextTop + BarHeightPx + MarginYPx div 2;

    Printer.Canvas.Font.Style := [];
    Printer.Canvas.Font.Size := 12;
    Printer.Canvas.TextOut(MarginXPx, TextTop, ABarcodeText);
    TextTop := TextTop + Printer.Canvas.TextHeight(ABarcodeText) + MarginYPx div 4;

    if ASubCaption <> '' then begin
      Printer.Canvas.Font.Size := 10;
      Printer.Canvas.TextOut(MarginXPx, TextTop, ASubCaption);
    end;
  finally
    Printer.EndDoc;
  end;
end;

end.
