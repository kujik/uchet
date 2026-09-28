unit uMotivationGridPanel;

{
Вспомогательный модуль отрисовки "разлинованных" панелей для формы отображения мотивации (28.09.2026,
см. uFrmWMotivationTest.pas, !алгоритмы.txt).

Идея (предложена пользователем): визуальное представление мотивации по должности/сотруднику собирается
из нескольких panel-блоков (по одному на критерий/раздел) - каждый блок это "сетка" с заданными
ширинами столбцов/высотами строк и текстом в ячейках, с поддержкой объединения ячеек (ColSpan/RowSpan).

DrawMotGridPanel - обычная процедура рисования на произвольном TCanvas (не метод какого-то конкретного
визуального компонента) - поэтому один и тот же вызов используется и для отрисовки на экране (в
OnPaint TPaintBox), и, в перспективе, при печати (Printer.Canvas / канвас предпросмотра) - WYSIWYG
печати получается "бесплатно", без отдельной печатной раскладки (сама печать в этой версии еще не
реализована - см. "Итого не проверено"/TODO в !алгоритмы.txt).

TMotGridData описывает один такой блок: массив ширин столбцов, массив высот строк, и двумерный массив
ячеек Rows[row][col]. У объединенной ячейки (ColSpan/RowSpan > 1) заполняется только "якорная" (левая
верхняя) позиция - остальные, покрытые её объединением, должны быть MotEmptyCell (ColSpan = 0) и
пропускаются при отрисовке (см. DrawMotGridPanel) - MotGridSetCell делает это автоматически.
}

interface

uses
  Windows, SysUtils, Classes, Graphics, Types, Math;

type
  TMotGridHAlign = (mghLeft, mghCenter, mghRight);

  TMotGridCell = record
    Text: string;
    ColSpan: Integer;         //сколько столбцов занимает ячейка (1 - обычная, 0 - "пусто", см. MotEmptyCell)
    RowSpan: Integer;         //сколько строк занимает ячейка
    Bold: Boolean;
    FontColor: TColor;
    FillColor: TColor;        //clNone - не закрашивать (оставить фон панели)
    HAlign: TMotGridHAlign;
    WordWrap: Boolean;
    FontSize: Integer;        //размер шрифта ячейки (в кеглях, как TFont.Size)
  end;

  TMotGridRow = array of TMotGridCell;

  TMotGridData = record
    ColWidths: array of Integer;
    RowHeights: array of Integer;
    Rows: array of TMotGridRow;
  end;

const
  //цвета по умолчанию для заголовков/подсветки - см. использование в uFrmWMotivationTest.pas
  cMotTitleFill: TColor    = $00D7D7D7; //серый - заголовок блока/критерия
  cMotHeaderFill: TColor   = $00F0F0F0; //светло-серый - шапка колонок
  cMotSelectedFill: TColor = $00CCFFCC; //светло-зеленый - выбранная/выделенная строка (как в образцах Excel)
  cMotYellowFill: TColor   = $0099FFFF; //светло-желтый - расчётные ячейки (как в образцах Excel, см.
                                        //"шапку" блока в uFrmWMotivationTest.pas - "Зарплата на руки" и т.п.)

function MotCell(const AText: string; AColSpan: Integer = 1; ARowSpan: Integer = 1;
  ABold: Boolean = False; AFillColor: TColor = clNone; AHAlign: TMotGridHAlign = mghLeft;
  AFontColor: TColor = clBlack; AWordWrap: Boolean = True; AFontSize: Integer = 8): TMotGridCell;
function MotEmptyCell: TMotGridCell;

procedure MotGridSetSize(var AData: TMotGridData; const AColWidths, ARowHeights: array of Integer);
//задаёт размеры (ширины столбцов/высоты строк), выделяет память под Rows нужного размера - все
//ячейки изначально MotEmptyCell (для не заданных явно через MotGridSetCell)

procedure MotGridSetCell(var AData: TMotGridData; ARow, ACol: Integer; const ACell: TMotGridCell);
//записывает ячейку в Rows[ARow, ACol]; если ColSpan/RowSpan > 1 - автоматически проставляет
//MotEmptyCell в остальные позиции, покрытые этим объединением

function MotGridWidth(const AData: TMotGridData): Integer;
function MotGridHeight(const AData: TMotGridData): Integer;

procedure DrawMotGridPanel(ACanvas: TCanvas; ALeft, ATop: Integer; const AData: TMotGridData);
//рисует панель на произвольном канвасе начиная с левого верхнего угла (ALeft, ATop) - см. описание
//модуля выше про WYSIWYG печать

implementation

function MotCell(const AText: string; AColSpan: Integer = 1; ARowSpan: Integer = 1;
  ABold: Boolean = False; AFillColor: TColor = clNone; AHAlign: TMotGridHAlign = mghLeft;
  AFontColor: TColor = clBlack; AWordWrap: Boolean = True; AFontSize: Integer = 8): TMotGridCell;
begin
  Result.Text := AText;
  Result.ColSpan := AColSpan;
  Result.RowSpan := ARowSpan;
  Result.Bold := ABold;
  Result.FillColor := AFillColor;
  Result.HAlign := AHAlign;
  Result.FontColor := AFontColor;
  Result.WordWrap := AWordWrap;
  Result.FontSize := AFontSize;
end;

function MotEmptyCell: TMotGridCell;
begin
  Result.Text := '';
  Result.ColSpan := 0;
  Result.RowSpan := 0;
  Result.Bold := False;
  Result.FillColor := clNone;
  Result.HAlign := mghLeft;
  Result.FontColor := clBlack;
  Result.WordWrap := True;
  Result.FontSize := 8;
end;

procedure MotGridSetSize(var AData: TMotGridData; const AColWidths, ARowHeights: array of Integer);
var
  r, c: Integer;
begin
  SetLength(AData.ColWidths, Length(AColWidths));
  for c := 0 to High(AColWidths) do
    AData.ColWidths[c] := AColWidths[c];

  SetLength(AData.RowHeights, Length(ARowHeights));
  for r := 0 to High(ARowHeights) do
    AData.RowHeights[r] := ARowHeights[r];

  SetLength(AData.Rows, Length(AData.RowHeights));
  for r := 0 to High(AData.Rows) do begin
    SetLength(AData.Rows[r], Length(AData.ColWidths));
    for c := 0 to High(AData.Rows[r]) do
      AData.Rows[r, c] := MotEmptyCell;
  end;
end;

procedure MotGridSetCell(var AData: TMotGridData; ARow, ACol: Integer; const ACell: TMotGridCell);
var
  r, c, rs, cs: Integer;
begin
  if (ARow < 0) or (ARow > High(AData.Rows)) then Exit;
  if (ACol < 0) or (ACol > High(AData.Rows[ARow])) then Exit;
  AData.Rows[ARow, ACol] := ACell;
  rs := Max(ACell.RowSpan, 1);
  cs := Max(ACell.ColSpan, 1);
  for r := ARow to Min(ARow + rs - 1, High(AData.Rows)) do
    for c := ACol to Min(ACol + cs - 1, High(AData.Rows[r])) do
      if (r <> ARow) or (c <> ACol) then
        AData.Rows[r, c] := MotEmptyCell;
end;

function MotGridWidth(const AData: TMotGridData): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to High(AData.ColWidths) do
    Result := Result + AData.ColWidths[i];
end;

function MotGridHeight(const AData: TMotGridData): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to High(AData.RowHeights) do
    Result := Result + AData.RowHeights[i];
end;

procedure DrawCellText(ACanvas: TCanvas; ARect: TRect; const AText: string; AHAlign: TMotGridHAlign; AWordWrap: Boolean);
//DT_VCENTER (вертикальное центрирование) в Windows API работает ТОЛЬКО вместе с DT_SINGLELINE -
//для переносимого (многострочного) текста центрирование по вертикали приходится делать вручную:
//сначала DT_CALCRECT считает, сколько реально займет текст при данной ширине, затем рисуем с
//отступом сверху, который центрирует эту посчитанную высоту в границах ячейки
var
  Flags: Cardinal;
  R, CalcR: TRect;
  TextHeight, OffsetY: Integer;
begin
  if AText = '' then Exit;
  R := ARect;
  InflateRect(R, -4, -2);
  if (R.Right <= R.Left) or (R.Bottom <= R.Top) then Exit;

  Flags := DT_NOPREFIX;
  case AHAlign of
    mghLeft:   Flags := Flags or DT_LEFT;
    mghCenter: Flags := Flags or DT_CENTER;
    mghRight:  Flags := Flags or DT_RIGHT;
  end;

  if AWordWrap then begin
    CalcR := Rect(R.Left, 0, R.Right, 0);
    Windows.DrawText(ACanvas.Handle, PChar(AText), Length(AText), CalcR, Flags or DT_WORDBREAK or DT_CALCRECT);
    TextHeight := CalcR.Bottom - CalcR.Top;
    OffsetY := Max(0, (R.Bottom - R.Top - TextHeight) div 2);
    R.Top := R.Top + OffsetY;
    Windows.DrawText(ACanvas.Handle, PChar(AText), Length(AText), R, Flags or DT_WORDBREAK);
  end else
    Windows.DrawText(ACanvas.Handle, PChar(AText), Length(AText), R, Flags or DT_SINGLELINE or DT_END_ELLIPSIS or DT_VCENTER);
end;

procedure DrawMotGridPanel(ACanvas: TCanvas; ALeft, ATop: Integer; const AData: TMotGridData);
var
  ColX, RowY: array of Integer;
  r, c: Integer;
  Cell: TMotGridCell;
  CellRect: TRect;
  ColEnd, RowEnd: Integer;
begin
  if (Length(AData.ColWidths) = 0) or (Length(AData.RowHeights) = 0) then Exit;

  SetLength(ColX, Length(AData.ColWidths) + 1);
  ColX[0] := ALeft;
  for c := 0 to High(AData.ColWidths) do
    ColX[c + 1] := ColX[c] + AData.ColWidths[c];

  SetLength(RowY, Length(AData.RowHeights) + 1);
  RowY[0] := ATop;
  for r := 0 to High(AData.RowHeights) do
    RowY[r + 1] := RowY[r] + AData.RowHeights[r];

  ACanvas.Font.Name := 'Tahoma';
  ACanvas.Pen.Color := clBlack;
  ACanvas.Pen.Style := psSolid;
  ACanvas.Pen.Width := 1;

  for r := 0 to High(AData.Rows) do
    for c := 0 to High(AData.Rows[r]) do begin
      Cell := AData.Rows[r, c];
      if Cell.ColSpan <= 0 then Continue; //ячейка, покрытая объединением другой - не рисуем повторно

      ColEnd := Min(c + Cell.ColSpan, High(ColX));
      RowEnd := Min(r + Max(Cell.RowSpan, 1), High(RowY));
      CellRect := Rect(ColX[c], RowY[r], ColX[ColEnd], RowY[RowEnd]);

      if Cell.FillColor <> clNone then begin
        ACanvas.Brush.Style := bsSolid;
        ACanvas.Brush.Color := Cell.FillColor;
        ACanvas.FillRect(CellRect);
      end;

      if Cell.Bold then
        ACanvas.Font.Style := ACanvas.Font.Style + [fsBold]
      else
        ACanvas.Font.Style := ACanvas.Font.Style - [fsBold];
      ACanvas.Font.Color := Cell.FontColor;
      if Cell.FontSize > 0 then
        ACanvas.Font.Size := Cell.FontSize
      else
        ACanvas.Font.Size := 8;
      ACanvas.Brush.Style := bsClear;
      DrawCellText(ACanvas, CellRect, Cell.Text, Cell.HAlign, Cell.WordWrap);

      ACanvas.Brush.Style := bsClear;
      ACanvas.Pen.Color := clBlack;
      ACanvas.Rectangle(CellRect);
    end;
end;

end.
