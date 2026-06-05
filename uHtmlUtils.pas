{
  Назначение:
    Генерация HTML-таблицы из данных TNamedArr на основе гибкой конфигурации,
    задаваемой в виде TVarDynArray2. Позволяет управлять отображением колонок,
    форматированием, агрегацией в футере и стилями.

  Использование:
    1. Создайте экземпляр THTMLTable.
    2. При необходимости настройте опции через InitDefaults и SetOptions.
    3. Подготовьте конфигурацию колонок (TVarDynArray2) в формате, описанном ниже.
    4. Вызовите метод Generate(Data, Config), где Data – данные в TNamedArr.
    5. Полученную HTML-строку можно сохранить в файл, показать в WebBrowser и т.д.

  Пример:
    var
      Tbl: THTMLTable;
      Data: TNamedArr;
      Config: TVarDynArray2;
      HTML: string;
    begin
      // ... заполнение Data из БД ...

      Config := [
        ['id', 'ID', 'c'],
        ['name', 'Наименование', 'l', 'b'],
        ['price', 'Цена', 'r', 'f=0.00', 's'],
        ['quantity', 'Кол-во', 'r', 'f=0', 's'],
        ['total', 'Сумма', 'r', 'b', 's', 'f=0.00', 'class=total-col']
      ];

      Tbl.InitDefaults;
      Tbl.SetOptions('report-table', '—', True, '0.00', 'dd.mm.yyyy', 'dd.mm.yyyy hh:nn:ss', True, True);
      HTML := Tbl.Generate(Data, Config);
    end;

  Формат конфигурации (TVarDynArray2):
    Каждая строка (TVarDynArray) описывает одну колонку таблицы.
    Обязательные элементы:
      [0] – имя поля в TNamedArr (FieldName)
      [1] – заголовок колонки (Title)
    Дополнительные элементы (начиная с индекса 2) – строковые флаги,
    которые могут идти в любом порядке.

  Поддерживаемые флаги:
    Выравнивание:
      'l'  – выравнивание по левому краю (left)
      'c'  – выравнивание по центру (center)
      'r'  – выравнивание по правому краю (right)

    Стиль шрифта:
      'b'  – жирный шрифт (bold)
      'i'  – курсив (italic)

    Агрегация в футере:
      's'  – выводить сумму значений колонки в футере (только для числовых полей)

    Форматирование даты/времени:
      'd'  – формат даты (без времени). Используется глобальный формат из DateFormat
             или собственный, заданный через 'f=...' (например, 'dd.mm.yyyy')
      'dt' – формат даты и времени. Используется DateTimeFormat или свой через 'f='

    Проценты:
      'p'  – значение умножается на 100 и добавляется знак '%'. Работает с числами.

    Пользовательский формат:
      'f=...' – задаёт формат для FormatFloat или FormatDateTime.
                Примеры: 'f=0.00', 'f=0', 'f=dd/mm/yyyy', 'f=hh:nn'.
                Переопределяет глобальные форматы.

    CSS класс колонки:
      'class=имя_класса' – добавляет атрибут class="имя_класса" в тег <th>.
                           Можно использовать для стилизации через внешний CSS.

  Примечания:
    - Если для колонки не указан флаг выравнивания, используется левое (taLeftJustify).
    - Для суммирования в футере (флаг 's') значение должно быть числовым; Null и нечисла игнорируются.
    - Если значение в ячейке Null, вместо него выводится строка, заданная в NullDisplay (по умолчанию '—').
    - Для чередования цвета строк используется класс 'odd' (если AlternateRowColor = True).
    - Все текстовые значения проходят HTML-эскейпинг.


}

unit uHtmlUtils;

interface

uses
  System.SysUtils, System.Variants, System.Classes, System.StrUtils, System.UITypes, Vcl.Graphics,
  System.Math, uString, uNamedArr;

type
  THTMLTableOptions = record
    TableClass: string;
    NullDisplay: string;
    AlternateRowColor: Boolean;
    NumberFormat: string;
    DateFormat: string;
    DateTimeFormat: string;
    UseHeader: Boolean;
    UseFooter: Boolean;
  end;

  TColumnInfo = record
    FieldName: string;
    Title: string;
    Align: TAlignment;
    FontStyle: TFontStyles;
    SumInFooter: Boolean;
    FormatStr: string;
    CssClass: string;
    IsPercent: Boolean;
    IsDate: Boolean;
    IsDateTime: Boolean;
  end;

  THTMLTable = record
  private
    FOptions: THTMLTableOptions;
    function HtmlEncode(const S: string): string;
    function ParseColumnConfig(const Row: TVarDynArray): TColumnInfo;
    function FormatCellValue(const Value: Variant; const Col: TColumnInfo): string;
    function GetCellStyle(const Col: TColumnInfo): string;
    // Вспомогательная для email-генерации
    function FormatCellValueEmail(const Value: Variant; const Col: TColumnInfo): string;
  public
    procedure InitDefaults;
    procedure SetOptions(const AOptions: THTMLTableOptions); overload;
    procedure SetOptions(const TableClass: string = '';
      const NullDisplay: string = '—';
      const AlternateRowColor: Boolean = True;
      const NumberFormat: string = '0.00';
      const DateFormat: string = 'dd.mm.yyyy';
      const DateTimeFormat: string = 'dd.mm.yyyy hh:nn:ss';
      const UseHeader: Boolean = True;
      const UseFooter: Boolean = True); overload;
    // Обычная генерация (с поддержкой CSS)
    function Generate(const Data: TNamedArr; const Config: TVarDynArray2): string;
    // Генерация для почтовых клиентов (без CSS, только атрибуты)
    function GenerateEmail(const Data: TNamedArr; const Config: TVarDynArray2;
      const Border: Integer = 1; const CellPadding: Integer = 2; const CellSpacing: Integer = 0): string;
  end;

implementation

{ THTMLTable }

procedure THTMLTable.InitDefaults;
begin
  FOptions.TableClass := '';
  FOptions.NullDisplay := '—';
  FOptions.AlternateRowColor := True;
  FOptions.NumberFormat := '0.00';
  FOptions.DateFormat := 'dd.mm.yyyy';
  FOptions.DateTimeFormat := 'dd.mm.yyyy hh:nn:ss';
  FOptions.UseHeader := True;
  FOptions.UseFooter := True;
end;

procedure THTMLTable.SetOptions(const AOptions: THTMLTableOptions);
begin
  FOptions := AOptions;
end;

procedure THTMLTable.SetOptions(const TableClass, NullDisplay: string;
  const AlternateRowColor: Boolean; const NumberFormat, DateFormat, DateTimeFormat: string;
  const UseHeader, UseFooter: Boolean);
begin
  FOptions.TableClass := TableClass;
  FOptions.NullDisplay := NullDisplay;
  FOptions.AlternateRowColor := AlternateRowColor;
  FOptions.NumberFormat := NumberFormat;
  FOptions.DateFormat := DateFormat;
  FOptions.DateTimeFormat := DateTimeFormat;
  FOptions.UseHeader := UseHeader;
  FOptions.UseFooter := UseFooter;
end;

function THTMLTable.HtmlEncode(const S: string): string;
var
  i: Integer;
  ch: Char;
begin
  Result := '';
  for i := 1 to Length(S) do
  begin
    ch := S[i];
    case ch of
      '&': Result := Result + '&amp;';
      '<': Result := Result + '&lt;';
      '>': Result := Result + '&gt;';
      '"': Result := Result + '&quot;';
      '''': Result := Result + '&#39;';
    else
      Result := Result + ch;
    end;
  end;
end;

function THTMLTable.ParseColumnConfig(const Row: TVarDynArray): TColumnInfo;
var
  i: Integer;
  v: Variant;
  FlagStr: string;
begin
  Result.FieldName := '';
  Result.Title := '';
  Result.Align := taLeftJustify;
  Result.FontStyle := [];
  Result.SumInFooter := False;
  Result.FormatStr := '';
  Result.CssClass := '';
  Result.IsPercent := False;
  Result.IsDate := False;
  Result.IsDateTime := False;

  if Length(Row) < 2 then
    Exit;
  Result.FieldName := VarToStr(Row[0]);
  Result.Title := VarToStr(Row[1]);

  for i := 2 to High(Row) do
  begin
    v := Row[i];
    if not VarIsStr(v) then
      Continue;
    FlagStr := VarToStr(v);
    if FlagStr = '' then
      Continue;

    if FlagStr = 'b' then
      Result.FontStyle := Result.FontStyle + [fsBold]
    else if FlagStr = 'i' then
      Result.FontStyle := Result.FontStyle + [fsItalic]
    else if FlagStr = 'c' then
      Result.Align := taCenter
    else if FlagStr = 'r' then
      Result.Align := taRightJustify
    else if FlagStr = 'l' then
      Result.Align := taLeftJustify
    else if FlagStr = 's' then
      Result.SumInFooter := True
    else if FlagStr = 'd' then
      Result.IsDate := True
    else if FlagStr = 'dt' then
      Result.IsDateTime := True
    else if FlagStr = 'p' then
      Result.IsPercent := True
    else if (Pos('f=', FlagStr) = 1) then
      Result.FormatStr := Copy(FlagStr, 3, MaxInt)
    else if (Pos('class=', FlagStr) = 1) then
      Result.CssClass := Copy(FlagStr, 7, MaxInt);
  end;
end;

function THTMLTable.FormatCellValue(const Value: Variant; const Col: TColumnInfo): string;
var
  numVal: Extended;
  dtVal: TDateTime;
  fmt: string;
begin
  if VarIsNull(Value) then
    Exit(FOptions.NullDisplay);

  if Col.IsPercent and VarIsNumeric(Value) then
  begin
    numVal := Value;
    numVal := numVal * 100;
    if Col.FormatStr <> '' then
      fmt := Col.FormatStr
    else
      fmt := FOptions.NumberFormat;
    Result := FormatFloat(fmt, numVal) + '%';
    Exit;
  end;

  if Col.IsDate and VarIsType(Value, varDate) then
  begin
    dtVal := Value;
    if Col.FormatStr <> '' then
      Result := FormatDateTime(Col.FormatStr, dtVal)
    else
      Result := FormatDateTime(FOptions.DateFormat, dtVal);
    Exit;
  end;

  if Col.IsDateTime and VarIsType(Value, varDate) then
  begin
    dtVal := Value;
    if Col.FormatStr <> '' then
      Result := FormatDateTime(Col.FormatStr, dtVal)
    else
      Result := FormatDateTime(FOptions.DateTimeFormat, dtVal);
    Exit;
  end;

  if VarIsNumeric(Value) then
  begin
    numVal := Value;
    if Col.FormatStr <> '' then
      fmt := Col.FormatStr
    else
      fmt := FOptions.NumberFormat;
    Result := FormatFloat(fmt, numVal);
    Exit;
  end;

  Result := VarToStr(Value);
end;

function THTMLTable.GetCellStyle(const Col: TColumnInfo): string;
var
  alignStr: string;
  styleArr: TArray<string>;
begin
  styleArr := [];
  case Col.Align of
    taLeftJustify: alignStr := 'text-align: left;';
    taRightJustify: alignStr := 'text-align: right;';
    taCenter: alignStr := 'text-align: center;';
  else
    alignStr := '';
  end;
  if alignStr <> '' then
    styleArr := styleArr + [alignStr];
  if fsBold in Col.FontStyle then
    styleArr := styleArr + ['font-weight: bold;'];
  if fsItalic in Col.FontStyle then
    styleArr := styleArr + ['font-style: italic;'];
  Result := string.Join(' ', styleArr);
end;

// Форматирование значения для email (без CSS, но с учётом жирности через <b>)
function THTMLTable.FormatCellValueEmail(const Value: Variant; const Col: TColumnInfo): string;
var
  rawValue: string;
begin
  rawValue := FormatCellValue(Value, Col); // получаем уже отформатированную строку
  if fsBold in Col.FontStyle then
    Result := '<b>' + rawValue + '</b>'
  else
    Result := rawValue;
end;

// Обычная генерация (с CSS)
function THTMLTable.Generate(const Data: TNamedArr; const Config: TVarDynArray2): string;
var
  Cols: TArray<TColumnInfo>;
  i, j, rowCount, colCount: Integer;
  value: Variant;
  cellValue: string;
  styleAttr, classAttr: string;
  sumValues: TArray<Extended>;
  hasSum: Boolean;
  rowStart: string;
  headerHtml, bodyHtml, footerHtml: TStringBuilder;
begin
  colCount := Length(Config);
  SetLength(Cols, colCount);
  for i := 0 to colCount - 1 do
    Cols[i] := ParseColumnConfig(Config[i]);

  for i := 0 to colCount - 1 do
    if not Data.HasField(Cols[i].FieldName) then
      raise ENamedArrError.CreateFmt('HTMLUtils: поле "%s" не найдено в данных', [Cols[i].FieldName]);

  SetLength(sumValues, colCount);
  hasSum := False;
  for i := 0 to colCount - 1 do
    if Cols[i].SumInFooter then
    begin
      sumValues[i] := 0;
      hasSum := True;
    end;

  headerHtml := TStringBuilder.Create;
  bodyHtml := TStringBuilder.Create;
  footerHtml := TStringBuilder.Create;
  try
    if FOptions.UseHeader then
    begin
      headerHtml.Append('<thead>').Append(sLineBreak);
      headerHtml.Append('<tr>').Append(sLineBreak);
      for i := 0 to colCount - 1 do
      begin
        classAttr := '';
        if Cols[i].CssClass <> '' then
          classAttr := ' class="' + Cols[i].CssClass + '"';
        headerHtml.Append('  <th' + classAttr + '>')
                 .Append(HtmlEncode(Cols[i].Title))
                 .Append('</th>').Append(sLineBreak);
      end;
      headerHtml.Append('</tr>').Append(sLineBreak);
      headerHtml.Append('</thead>').Append(sLineBreak);
    end;

    bodyHtml.Append('<tbody>').Append(sLineBreak);
    rowCount := Data.Count;
    for i := 0 to rowCount - 1 do
    begin
      if FOptions.AlternateRowColor and (i mod 2 = 1) then
        rowStart := '<tr class="odd">' + sLineBreak
      else
        rowStart := '</tr>' + sLineBreak;

      for j := 0 to colCount - 1 do
      begin
        value := Data.GetValue(i, Cols[j].FieldName);
        cellValue := FormatCellValue(value, Cols[j]);
        cellValue := HtmlEncode(cellValue);

        styleAttr := GetCellStyle(Cols[j]);
        if styleAttr <> '' then
          rowStart := rowStart + Format('  <td style="%s">%s</td>' + sLineBreak, [styleAttr, cellValue])
        else
          rowStart := rowStart + '  <td>' + cellValue + '</td>' + sLineBreak;

        if Cols[j].SumInFooter and not VarIsNull(value) and VarIsNumeric(value) then
          sumValues[j] := sumValues[j] + value;
      end;
      rowStart := rowStart + '</tr>' + sLineBreak;
      bodyHtml.Append(rowStart);
    end;
    bodyHtml.Append('</tbody>').Append(sLineBreak);

    if FOptions.UseFooter and hasSum then
    begin
      footerHtml.Append('<tfoot>').Append(sLineBreak);
      footerHtml.Append('<tr>').Append(sLineBreak);
      for j := 0 to colCount - 1 do
      begin
        if Cols[j].SumInFooter then
        begin
          var fmt := Cols[j].FormatStr;
          if fmt = '' then
            fmt := FOptions.NumberFormat;
          cellValue := FormatFloat(fmt, sumValues[j]);
          if Cols[j].IsPercent then
            cellValue := cellValue + '%';
        end
        else
          cellValue := '';
        footerHtml.Append('  <td>' + HtmlEncode(cellValue) + '</td>').Append(sLineBreak);
      end;
      footerHtml.Append('</tr>').Append(sLineBreak);
      footerHtml.Append('</tfoot>').Append(sLineBreak);
    end;

    Result := '<table';
    if FOptions.TableClass <> '' then
      Result := Result + ' class="' + FOptions.TableClass + '"';
    Result := Result + '>' + sLineBreak;
    Result := Result + headerHtml.ToString;
    Result := Result + bodyHtml.ToString;
    Result := Result + footerHtml.ToString;
    Result := Result + '</table>';
  finally
    headerHtml.Free;
    bodyHtml.Free;
    footerHtml.Free;
  end;
end;

// Генерация HTML-таблицы для отправки по электронной почте
// Особенности: не использует CSS, теги THEAD/TBODY/TFOOT – только TABLE, TR, TD.
// Жирный шрифт реализуется через <b>, выравнивание через атрибут align.
// Цвета не задаются, чтобы избежать артефактов в почтовых клиентах (например, Outlook).
// Суммы считаются для колонок с флагом 's' и выводятся в отдельной строке внизу.
//
// Параметры:
//   Data      - данные в формате TNamedArr
//   Config    - конфигурация колонок (TVarDynArray2) с флагами форматирования
//   Border    - толщина рамки таблицы (по умолч. 1)
//   CellPadding - отступ внутри ячеек (по умолч. 2)
//   CellSpacing - расстояние между ячейками (по умолч. 0)
//
// Возвращает: строка с HTML-кодом таблицы.
function THTMLTable.GenerateEmail(const Data: TNamedArr; const Config: TVarDynArray2;
  const Border, CellPadding, CellSpacing: Integer): string;
var
  Cols: TArray<TColumnInfo>;     // массив с информацией о колонках
  i, j, rowCount, colCount: Integer;
  value: Variant;                // значение текущей ячейки
  cellValue: string;             // отформатированное значение для вывода
  alignAttr: string;             // атрибут align для ячейки
  sumValues: TArray<Extended>;   // накопленные суммы по колонкам
  hasSum: Boolean;               // есть ли хотя бы одна колонка с суммой
  sb: TStringBuilder;            // построитель строк (эффективная конкатенация)
begin
  // 1. Парсим конфигурацию: преобразуем каждую строку Config в TColumnInfo
  colCount := Length(Config);
  SetLength(Cols, colCount);
  for i := 0 to colCount - 1 do
    Cols[i] := ParseColumnConfig(Config[i]);

  // 2. Проверяем, что все поля из конфигурации реально существуют в Data
  for i := 0 to colCount - 1 do
    if not Data.HasField(Cols[i].FieldName) then
      raise ENamedArrError.CreateFmt('HTMLUtils: поле "%s" не найдено в данных', [Cols[i].FieldName]);

  // 3. Инициализируем накопители сумм для колонок с флагом 's'
  SetLength(sumValues, colCount);
  hasSum := False;
  for i := 0 to colCount - 1 do
    if Cols[i].SumInFooter then
    begin
      sumValues[i] := 0;
      hasSum := True;
    end;

  // 4. Формируем HTML-код с помощью TStringBuilder
  sb := TStringBuilder.Create;
  try
    // Открываем тег TABLE с атрибутами, понятными почтовым клиентам
    sb.AppendFormat('<table border="%d" cellpadding="%d" cellspacing="%d">', [Border, CellPadding, CellSpacing]);
    sb.Append(sLineBreak);

    // ----- ЗАГОЛОВОК (первая строка) -----
    sb.Append('<tr>').Append(sLineBreak);
    for i := 0 to colCount - 1 do
    begin
      // Определяем выравнивание для заголовка
      case Cols[i].Align of
        taLeftJustify: alignAttr := ' align="left"';
        taRightJustify: alignAttr := ' align="right"';
        taCenter: alignAttr := ' align="center"';
      else
        alignAttr := '';
      end;
      // Заголовок делаем жирным через <b>, содержимое экранируем
      sb.AppendFormat('  <td%s><b>%s</b></td>', [alignAttr, HtmlEncode(Cols[i].Title)]);
      sb.Append(sLineBreak);
    end;
    sb.Append('</tr>').Append(sLineBreak);

    // ----- ТЕЛО ТАБЛИЦЫ (строки данных) -----
    rowCount := Data.Count;
    for i := 0 to rowCount - 1 do
    begin
      sb.Append('<tr>').Append(sLineBreak);
      for j := 0 to colCount - 1 do
      begin
        // Получаем значение из данных
        value := Data.GetValue(i, Cols[j].FieldName);
        // Форматируем значение как строку (числа, даты, проценты, Null)
        cellValue := FormatCellValue(value, Cols[j]);
        cellValue := HtmlEncode(cellValue);

        // Если для колонки установлен флаг 'b' (жирный), оборачиваем в <b>
        if fsBold in Cols[j].FontStyle then
          cellValue := '<b>' + cellValue + '</b>';

        // Определяем выравнивание для ячейки
        case Cols[j].Align of
          taLeftJustify: alignAttr := ' align="left"';
          taRightJustify: alignAttr := ' align="right"';
          taCenter: alignAttr := ' align="center"';
        else
          alignAttr := '';
        end;
        sb.AppendFormat('  <td%s>%s</td>', [alignAttr, cellValue]);
        sb.Append(sLineBreak);

        // Накопление суммы, если колонка требует суммирования и значение числовое
        if Cols[j].SumInFooter then //and value.IsNumeric then  //not VarIsNull(value) and VarIsNumeric(value) then
          sumValues[j] := sumValues[j] + value.AsFloat;
      end;
      sb.Append('</tr>').Append(sLineBreak);
    end;

    // ----- ФУТЕР (строка с суммами, если есть) -----
    if FOptions.UseFooter and hasSum then
    begin
      sb.Append('<tr>').Append(sLineBreak);
      for j := 0 to colCount - 1 do
      begin
        // Выравнивание для ячейки футера
        case Cols[j].Align of
          taLeftJustify: alignAttr := ' align="left"';
          taRightJustify: alignAttr := ' align="right"';
          taCenter: alignAttr := ' align="center"';
        else
          alignAttr := '';
        end;
        if Cols[j].SumInFooter then
        begin
          // Форматируем сумму (с учётом формата колонки или глобального)
          var fmt := Cols[j].FormatStr;
          if fmt = '' then
            fmt := FOptions.NumberFormat;
          cellValue := FormatFloat(fmt, sumValues[j]);
          // Если колонка процентная, добавляем знак %
          if Cols[j].IsPercent then
            cellValue := cellValue + '%';
        end
        else
          cellValue := '';
        sb.AppendFormat('  <td>%s</td>', [HtmlEncode(cellValue)]);
        sb.Append(sLineBreak);
      end;
      sb.Append('<tr>').Append(sLineBreak);
    end;

    // Закрываем таблицу
    sb.Append('</table>');
    Result := sb.ToString;
  finally
    sb.Free;
  end;
end;

end.
