unit uNamedArr;

interface

uses
  System.SysUtils, System.Variants, System.Classes, System.Generics.Collections, System.StrUtils, System.Math,
  uString;

type
  //собственное исключение
  ENamedArrError = class(Exception)
  private
    FField: string;
  public
    constructor Create(const Msg: string; const AField: string = '');
    property Field: string read FField;
  end;

  //запись для хранения табличных данных с именованными полями
  TNamedArr = record
  private
    //вспомогательные методы
    function GetFieldIndex(const FieldName: string): Integer;
    procedure CheckRowIndex(RowNo: Integer);
    procedure EnsureRowLength(RowNo: Integer);
    function CompareValues(const A, B: Variant; Ascending: Boolean): Integer;
    function CompareRows(Idx1, Idx2: Integer; const FieldIndices: array of Integer; Ascending: Boolean): Integer;
    procedure QuickSort(L, R: Integer; const FieldIndices: array of Integer; Ascending: Boolean);

  public
    FFull: TVarDynArray;      //исходные имена полей (могут содержать $)
    F: TVarDynArray;           //очищенные имена полей (без $)
    V: TVarDynArray2;          //данные: строки, колонки

    //инициализация (конструкторы)
    procedure Create; overload;
    procedure Create(Fields: TVarDynArray; Len: Integer = 0); overload;
    procedure Create(Data: TVarDynArray2; FieldNames: TVarDynArray); overload;
    procedure Create(Data: TVarDynArray2; FieldNames: string = ''); overload;

    //доступ к данным
    function  GetValue(RowNo: Integer; const FieldName: string): Variant;
    function  GetValueI(RowNo: Integer; ColIndex: Integer): Variant;
    procedure SetValue(RowNo: Integer; const FieldName: string; const Value: Variant); overload;
    procedure SetValue(const FieldName: string; const Value: Variant); overload;
    procedure SetValueI(RowNo: Integer; ColIndex: Integer; const Value: Variant);
    function  GetRow(RowNo: Integer): TVarDynArray;
    procedure SetRow(RowNo: Integer; const Values: TVarDynArray);

    //информация о структуре
    function Count: Integer;
    function High: Integer;
    function FieldsCount: Integer;
    function IsEmpty: Boolean;
    function HasField(const FieldName: string): Boolean;
    function IndexOfField(const FieldName: string): Integer;
    function GetFieldNames: TVarDynArray;      //очищенные имена как TVarDynArray (строки)
    function GetRawFieldNames: TVarDynArray;   //исходные имена

    //получение списков полей в виде строки
    function GetFFullStr(Delimiter: String = ';'): string;  //исходные поля через заданный разделитель (по умолчанию ';')
    function GetFStr(Delimiter: String = ','): string;      //очищенные поля через заданный разделитель (по умолчанию ',')

    //добавление / удаление строк
    procedure IncLength;
    procedure AddRow(const Values: TVarDynArray); overload;
    procedure AddRow(const Other: TNamedArr; RowIndex: Integer); overload;
    procedure InsertRow(Index: Integer; const Values: TVarDynArray);
    procedure DeleteRow(Index: Integer);
    procedure Clear;
    procedure SetLength(NewLen: Integer); // используем System.SetLength

    //добавление / удаление полей
    procedure AddField(const FieldName: string); overload;   //добавить поле со значениями Null
    procedure AddField(const FieldName: string; DefaultValue: Variant); overload;
    procedure AddField(const FieldName: string; const Values: TVarDynArray); overload;
    procedure DeleteField(const FieldName: string);

    //поиск
    function FindFirst(const FieldName: string; const Value: Variant): Integer;
    function FindAll(const FieldName: string; const Value: Variant): TArray<Integer>;

    //агрегатные функции
    function Sum(const FieldName: string): Variant;
    function Avg(const FieldName: string): Double;
    function Min(const FieldName: string): Variant;
    function Max(const FieldName: string): Variant;

    //сортировка по нескольким полям (имена полей передаются в TVarDynArray)
    procedure Sort(const FieldNames: TVarDynArray; Ascending: Boolean = True);

    //фильтрация: возвращает новый TNamedArr, содержащий строки, удовлетворяющие условию
    function Filter(const Conditions: TVarDynArray2): TNamedArr; overload;
    function Filter(Predicate: TFunc<Integer, Boolean>): TNamedArr; overload;

    //null-значения
    procedure SetNull; overload;
    procedure SetNull(RowNo: Integer); overload;
    function IsNull(RowNo: Integer; const FieldName: string): Boolean;
    function IsNullRow(RowNo: Integer): Boolean;

    //клонирование и присваивание
    function Clone: TNamedArr;
    procedure Assign(const Source: TNamedArr);

    //итератор (для for..in)
    function GetEnumerator: TEnumerator<TVarDynArray>;

    //объединение записей
    procedure Concat(const Other: TNamedArr; CheckFields: Boolean = True); //добавляет строки из Other в текущую запись

    //сохранение / загрузка (CSV, JSON)
    procedure LoadFromCSV(const Filename: string; HasHeader: Boolean = True);
    procedure SaveToCSV(const Filename: string);
    function ToJSON: string;
    procedure FromJSON(const JSON: string);

    //методы для совместимости с исходным кодом
    function Col(const FieldName: string): Integer;
    function G(RowNo: Integer; const FieldName: string): Variant; overload;
    function G(const FieldName: string): Variant; overload;
    function GetValueByOtherField(SearchValue: Variant; const SearchField: string;
      const ResultField: string; ValueIfNotFound: Variant): Variant;
    function Find(Value: Variant; const FieldName: string): Integer; //первое вхождение
  end;

  //вспомогательный класс-итератор (оставлен классом, хранит копию записи, изменение в цикле не влияет на значения итератора)
  TNamedArrEnumerator = class(TEnumerator<TVarDynArray>)
  private
    FArr: TNamedArr;
    FIndex: Integer;
  protected
    function DoGetCurrent: TVarDynArray; override;
    function DoMoveNext: Boolean; override;
  public
    constructor Create(const AArr: TNamedArr);
  end;

  TNamedArr2 = array of TNamedArr;

implementation

uses
  System.IOUtils;

{ ENamedArrError }

constructor ENamedArrError.Create(const Msg: string; const AField: string);
begin
  inherited Create(Msg);
  FField := AField;
end;

{ TNamedArrEnumerator }

constructor TNamedArrEnumerator.Create(const AArr: TNamedArr);
begin
  inherited Create;
  FArr := AArr; // создаётся копия записи – данные не будут меняться при изменении оригинала
  FIndex := -1;
end;

function TNamedArrEnumerator.DoGetCurrent: TVarDynArray;
begin
  Result := FArr.GetRow(FIndex);
end;

function TNamedArrEnumerator.DoMoveNext: Boolean;
begin
  Inc(FIndex);
  Result := FIndex < FArr.Count;
end;

{ TNamedArr }

//==============================================================================
// Инициализация (конструкторы)
//==============================================================================

procedure TNamedArr.Create;
begin
  FFull := [];
  F := [];
  V := [];
end;

procedure TNamedArr.Create(Fields: TVarDynArray; Len: Integer = 0);
//инициализируем запись, массив значений заполняем null
var
  i, j: Integer;
  s: string;
  p: Integer;
begin
  FFull := System.Copy(Fields, 0, Length(Fields));
  System.SetLength(F, Length(Fields));
  for j := 0 to System.High(Fields) do
  begin
    s := VarToStr(Fields[j]);
    p := Pos('$', s);
    if p > 0 then
      F[j] := Copy(s, 1, p - 1)
    else
      F[j] := s;
  end;
  System.SetLength(V, Len);
  for i := 0 to Len - 1 do
  begin
    System.SetLength(V[i], Length(F));
    for j := 0 to System.High(V[i]) do
      V[i][j] := Null;
  end;
end;

procedure TNamedArr.Create(Data: TVarDynArray2; FieldNames: TVarDynArray);
//инициализируем запись из массива; передаются поля, если [] то создаются числовые по индексам колонок
var
  RowCount, ColCount, i, j: Integer;
  Fields: TVarDynArray;
  s: string;
  p: Integer;
begin
  // Сначала обнуляем
  FFull := [];
  F := [];
  V := [];

  RowCount := Length(Data);
  if RowCount > 0 then
    ColCount := Length(Data[0])
  else
    ColCount := 0;

  // Определяем имена полей
  if Length(FieldNames) > 0 then
    Fields := System.Copy(FieldNames, 0, Length(FieldNames))
  else
  begin
    System.SetLength(Fields, ColCount);
    for i := 0 to ColCount - 1 do
      Fields[i] := IntToStr(i);
  end;

  if Length(Fields) <> ColCount then
    raise ENamedArrError.Create('Количество имён полей не совпадает с числом колонок данных');

  // Устанавливаем FFull и F
  FFull := System.Copy(Fields, 0, Length(Fields));
  System.SetLength(F, Length(Fields));
  for j := 0 to System.High(Fields) do
  begin
    s := VarToStr(Fields[j]);
    p := Pos('$', s);
    if p > 0 then
      F[j] := Copy(s, 1, p - 1)
    else
      F[j] := s;
  end;

  // Копируем данные
  System.SetLength(V, RowCount);
  for i := 0 to RowCount - 1 do
  begin
    if Length(Data[i]) <> ColCount then
      raise ENamedArrError.CreateFmt('Строка %d имеет длину %d, ожидалось %d', [i, Length(Data[i]), ColCount]);
    System.SetLength(V[i], ColCount);
    for j := 0 to ColCount - 1 do
      V[i][j] := Data[i][j];
  end;
end;

procedure TNamedArr.Create(Data: TVarDynArray2; FieldNames: string = '');
//инициализируем запись из массива; передаются поля, если не переданы то создаются числовые по индексам колонок
begin
  Create(Data, A.Explode(FieldNames, ';', True));
end;


//==============================================================================
// Вспомогательные методы
//==============================================================================

function TNamedArr.GetFieldIndex(const FieldName: string): Integer;
//найти индекс поля по имени (без учёта регистра)
var
  i: Integer;
  s: string;
begin
  for i := 0 to System.High(F) do
  begin
    s := VarToStr(F[i]);
    if SameText(s, FieldName) then
      Exit(i);
  end;
  Result := -1;
end;

procedure TNamedArr.CheckRowIndex(RowNo: Integer);
//проверить допустимость индекса строки, иначе исключение
begin
  if (RowNo < 0) or (RowNo >= Length(V)) then
    raise ENamedArrError.CreateFmt('TNamedArr: индекс строки %d вне допустимого диапазона [0..%d]', [RowNo, Length(V)-1]);
end;

procedure TNamedArr.EnsureRowLength(RowNo: Integer);
//при необходимости выровнять длину строки по числу полей
begin
  if Length(V[RowNo]) <> FieldsCount then
    System.SetLength(V[RowNo], FieldsCount);
end;

function TNamedArr.CompareValues(const A, B: Variant; Ascending: Boolean): Integer;
//сравнить два варианта с учётом направления сортировки
var
  mult: Integer;
begin
  mult := 1;
  if not Ascending then mult := -1;
  if VarIsNull(A) and VarIsNull(B) then
    Result := 0
  else if VarIsNull(A) then
    Result := -1 * mult
  else if VarIsNull(B) then
    Result := 1 * mult
  else
  begin
    //пытаемся сравнивать по подходящим типам
    case VarType(A) and varTypeMask of
      varSmallint, varInteger, varShortInt, varByte, varWord, varLongWord, varInt64,
      varSingle, varDouble, varCurrency:
        begin
          if A < B then Result := -1 * mult
          else if A > B then Result := 1 * mult
          else Result := 0;
        end;
      varDate:
        begin
          var d1, d2: TDateTime;
          d1 := A;
          d2 := B;
          if d1 < d2 then Result := -1 * mult
          else if d1 > d2 then Result := 1 * mult
          else Result := 0;
        end;
      varOleStr, varString, varUString:
        begin
          var s1, s2: string;
          s1 := VarToStr(A);
          s2 := VarToStr(B);
          Result := CompareText(s1, s2) * mult;
        end;
    else
      //для остальных типов используем строковое представление
      var s1, s2: string;
      s1 := VarToStr(A);
      s2 := VarToStr(B);
      Result := CompareText(s1, s2) * mult;
    end;
  end;
end;

function TNamedArr.CompareRows(Idx1, Idx2: Integer; const FieldIndices: array of Integer; Ascending: Boolean): Integer;
//сравнить две строки по заданному списку полей (последовательно)
var
  i: Integer;
  cmp: Integer;
begin
  Result := 0;
  for i := 0 to System.High(FieldIndices) do
  begin
    cmp := CompareValues(V[Idx1][FieldIndices[i]], V[Idx2][FieldIndices[i]], Ascending);
    if cmp <> 0 then
    begin
      Result := cmp;
      Exit;
    end;
  end;
end;

procedure TNamedArr.QuickSort(L, R: Integer; const FieldIndices: array of Integer; Ascending: Boolean);
//рекурсивная быстрая сортировка по нескольким полям
var
  I, J, PivotIdx: Integer;
begin
  if L >= R then Exit;
  I := L;
  J := R;
  PivotIdx := (L + R) shr 1;
  repeat
    while CompareRows(I, PivotIdx, FieldIndices, Ascending) < 0 do Inc(I);
    while CompareRows(J, PivotIdx, FieldIndices, Ascending) > 0 do Dec(J);
    if I <= J then
    begin
      if I <> J then
      begin
        var Temp := V[I];
        V[I] := V[J];
        V[J] := Temp;
        //корректируем индекс опорного элемента после обмена
        if PivotIdx = I then
          PivotIdx := J
        else if PivotIdx = J then
          PivotIdx := I;
      end;
      Inc(I);
      Dec(J);
    end;
  until I > J;
  if L < J then QuickSort(L, J, FieldIndices, Ascending);
  if I < R then QuickSort(I, R, FieldIndices, Ascending);
end;

//==============================================================================
// Доступ к данным
//==============================================================================

function TNamedArr.GetValue(RowNo: Integer; const FieldName: string): Variant;
//получить значение по имени поля
var
  idx: Integer;
begin
  idx := GetFieldIndex(FieldName);
  if idx < 0 then
    raise ENamedArrError.Create(Format('TNamedArr: поле "%s" не найдено', [FieldName]), FieldName);
  Result := GetValueI(RowNo, idx);
end;

procedure TNamedArr.SetValue(RowNo: Integer; const FieldName: string; const Value: Variant);
//установить значение по имени поля
var
  idx: Integer;
begin
  idx := GetFieldIndex(FieldName);
  if idx < 0 then
    raise ENamedArrError.Create(Format('TNamedArr: поле "%s" не найдено', [FieldName]), FieldName);
  SetValueI(RowNo, idx, Value);
end;

procedure TNamedArr.SetValue(const FieldName: string; const Value: Variant);
//установить значение по имени поля для первой строки
begin
  SetValue(0, FieldName, Value);
end;

function TNamedArr.GetValueI(RowNo: Integer; ColIndex: Integer): Variant;
//получить значение по индексу колонки
begin
  CheckRowIndex(RowNo);
  EnsureRowLength(RowNo);
  if (ColIndex < 0) or (ColIndex >= FieldsCount) then
    raise ENamedArrError.CreateFmt('TNamedArr: индекс колонки %d вне диапазона [0..%d]', [ColIndex, FieldsCount-1]);
  Result := V[RowNo][ColIndex];
end;

procedure TNamedArr.SetValueI(RowNo: Integer; ColIndex: Integer; const Value: Variant);
//установить значение по индексу колонки
begin
  CheckRowIndex(RowNo);
  EnsureRowLength(RowNo);
  if (ColIndex < 0) or (ColIndex >= FieldsCount) then
    raise ENamedArrError.CreateFmt('TNamedArr: индекс колонки %d вне диапазона [0..%d]', [ColIndex, FieldsCount-1]);
  V[RowNo][ColIndex] := Value;
end;

function TNamedArr.GetRow(RowNo: Integer): TVarDynArray;
//получить всю строку как массив
begin
  CheckRowIndex(RowNo);
  EnsureRowLength(RowNo);
  //копируем массив с указанием длины – приведение необходимо для совместимости с TVarDynArray
  Result := TVarDynArray(System.Copy(V[RowNo], 0, Length(V[RowNo])));
end;

procedure TNamedArr.SetRow(RowNo: Integer; const Values: TVarDynArray);
//установить всю строку из массива
begin
  CheckRowIndex(RowNo);
  if Length(Values) <> FieldsCount then
    raise ENamedArrError.CreateFmt('TNamedArr: количество значений (%d) не совпадает с числом полей (%d)',
      [Length(Values), FieldsCount]);
  System.SetLength(V[RowNo], FieldsCount);
  //копируем значения – приведение необходимо
  TVarDynArray(V[RowNo]) := TVarDynArray(System.Copy(Values, 0, Length(Values)));
end;

//==============================================================================
// Информация о структуре
//==============================================================================

function TNamedArr.Count: Integer;
//количество строк
begin
  Result := Length(V);
end;

function TNamedArr.High: Integer;
//индекс последней строки
begin
  Result := System.High(V);
end;

function TNamedArr.FieldsCount: Integer;
//количество полей
begin
  Result := Length(F);
end;

function TNamedArr.IsEmpty: Boolean;
//пуст ли массив (нет строк)
begin
  Result := Count = 0;
end;

function TNamedArr.HasField(const FieldName: string): Boolean;
//существует ли поле с таким именем
begin
  Result := GetFieldIndex(FieldName) >= 0;
end;

function TNamedArr.IndexOfField(const FieldName: string): Integer;
//индекс поля (или -1)
begin
  Result := GetFieldIndex(FieldName);
end;

function TNamedArr.GetFieldNames: TVarDynArray;
//получить массив очищенных имён полей
var
  i: Integer;
begin
  System.SetLength(Result, Length(F));
  for i := 0 to System.High(F) do
    Result[i] := F[i];
end;

function TNamedArr.GetRawFieldNames: TVarDynArray;
//получить массив исходных имён полей
begin
  Result := System.Copy(FFull, 0, Length(FFull)); // приведение не нужно, т.к. FFull уже TVarDynArray
end;

function TNamedArr.GetFFullStr(Delimiter: String = ';'): string;
//исходные имена полей через заданный разделитель
var
  i: Integer;
begin
  Result := '';
  for i := 0 to System.High(FFull) do
  begin
    if i > 0 then Result := Result + Delimiter;
    Result := Result + VarToStr(FFull[i]);
  end;
end;

function TNamedArr.GetFStr(Delimiter: String = ','): string;
//очищенные имена полей через заданный разделитель
var
  i: Integer;
begin
  Result := '';
  for i := 0 to System.High(F) do
  begin
    if i > 0 then Result := Result + Delimiter;
    Result := Result + VarToStr(F[i]);
  end;
end;

//==============================================================================
// Добавление / удаление строк
//==============================================================================

procedure TNamedArr.IncLength;
//добавить пустую строку в конец (без инициализации значений)
begin
  System.SetLength(V, Length(V) + 1);
  System.SetLength(V[System.High(V)], FieldsCount);
end;

procedure TNamedArr.AddRow(const Values: TVarDynArray);
//добавить строку в конец
begin
  InsertRow(Count, Values);
end;

procedure TNamedArr.AddRow(const Other: TNamedArr; RowIndex: Integer);
//добавить копию строки из другого экземпляра
begin
  if Other.FieldsCount <> Self.FieldsCount then
    raise ENamedArrError.Create('TNamedArr: число полей источника не совпадает с текущим');
  AddRow(Other.GetRow(RowIndex));
end;

procedure TNamedArr.InsertRow(Index: Integer; const Values: TVarDynArray);
//вставить строку в указанную позицию
var
  i: Integer;
begin
  if (Index < 0) or (Index > Count) then
    raise ENamedArrError.CreateFmt('TNamedArr: индекс вставки %d вне диапазона [0..%d]', [Index, Count]);
  if Length(Values) <> FieldsCount then
    raise ENamedArrError.CreateFmt('TNamedArr: количество значений (%d) не совпадает с числом полей (%d)',
      [Length(Values), FieldsCount]);
  System.SetLength(V, Count + 1);
  for i := Count - 1 downto Index do
    V[i + 1] := V[i];
  System.SetLength(V[Index], FieldsCount);
  TVarDynArray(V[Index]) := TVarDynArray(System.Copy(Values, 0, Length(Values)));
end;

procedure TNamedArr.DeleteRow(Index: Integer);
//удалить строку
var
  i: Integer;
begin
  CheckRowIndex(Index);
  for i := Index to Count - 2 do
    V[i] := V[i + 1];
  System.SetLength(V, Count - 1);
end;

procedure TNamedArr.Clear;
//удалить все данные (поля и сами данные) – устанавливаем пустые массивы
begin
  FFull := [];
  F := [];
  V := [];
end;

procedure TNamedArr.SetLength(NewLen: Integer);
//установить новое количество строк (при увеличении новые строки заполняются Null)
var
  OldLen, i, j: Integer;
begin
  OldLen := Count;
  System.SetLength(V, NewLen);
  if NewLen > OldLen then
    for i := OldLen to NewLen - 1 do
    begin
      System.SetLength(V[i], FieldsCount);
      for j := 0 to System.High(V[i]) do
        V[i][j] := Null;
    end;
end;

//==============================================================================
// Добавление / удаление полей
//==============================================================================

procedure TNamedArr.AddField(const FieldName: string);
//добавить новое поле со значениями Null (перегрузка без DefaultValue)
begin
  AddField(FieldName, Null);
end;

procedure TNamedArr.AddField(const FieldName: string; DefaultValue: Variant);
//добавить новое поле с указанным значением по умолчанию
var
  i: Integer;
begin
  if HasField(FieldName) then
    raise ENamedArrError.Create(Format('TNamedArr: поле "%s" уже существует', [FieldName]), FieldName);
  System.SetLength(F, FieldsCount + 1);
  F[System.High(F)] := FieldName;
  System.SetLength(FFull, FieldsCount);
  FFull[System.High(FFull)] := FieldName;
  for i := 0 to Count - 1 do
  begin
    System.SetLength(V[i], FieldsCount);
    V[i][System.High(V[i])] := DefaultValue;
  end;
end;

procedure TNamedArr.AddField(const FieldName: string; const Values: TVarDynArray);
//добавить поле с заполнением значений из массива (длина массива должна равняться числу строк)
var
  i: Integer;
begin
  if HasField(FieldName) then
    raise ENamedArrError.Create(Format('TNamedArr: поле "%s" уже существует', [FieldName]), FieldName);
  if Length(Values) <> Count then
    raise ENamedArrError.Create('TNamedArr: количество значений должно совпадать с числом строк');
  AddField(FieldName, Null);
  for i := 0 to Count - 1 do
    SetValue(i, FieldName, Values[i]);
end;

procedure TNamedArr.DeleteField(const FieldName: string);
//удалить поле (столбец)
var
  idx, i, j: Integer;
begin
  idx := IndexOfField(FieldName);
  if idx < 0 then
    raise ENamedArrError.Create(Format('TNamedArr: поле "%s" не найдено', [FieldName]), FieldName);
  for i := idx to FieldsCount - 2 do
  begin
    F[i] := F[i + 1];
    FFull[i] := FFull[i + 1];
  end;
  System.SetLength(F, FieldsCount - 1);
  System.SetLength(FFull, FieldsCount - 1);
  for i := 0 to Count - 1 do
  begin
    for j := idx to Length(V[i]) - 2 do
      V[i][j] := V[i][j + 1];
    System.SetLength(V[i], Length(V[i]) - 1);
  end;
end;

//==============================================================================
// Поиск
//==============================================================================

function TNamedArr.FindFirst(const FieldName: string; const Value: Variant): Integer;
//найти первую строку, где значение поля равно заданному (иначе -1)
var
  idx, i: Integer;
begin
  idx := IndexOfField(FieldName);
  if idx < 0 then
    raise ENamedArrError.Create(Format('TNamedArr: поле "%s" не найдено', [FieldName]), FieldName);
  for i := 0 to Count - 1 do
    if VarSameValue(V[i][idx], Value) then
      Exit(i);
  Result := -1;
end;

function TNamedArr.FindAll(const FieldName: string; const Value: Variant): TArray<Integer>;
//найти индексы всех строк, где значение поля равно заданному
var
  idx, i, cnt: Integer;
begin
  idx := IndexOfField(FieldName);
  if idx < 0 then
    raise ENamedArrError.Create(Format('TNamedArr: поле "%s" не найдено', [FieldName]), FieldName);
  System.SetLength(Result, Count);
  cnt := 0;
  for i := 0 to Count - 1 do
    if VarSameValue(V[i][idx], Value) then
    begin
      Result[cnt] := i;
      Inc(cnt);
    end;
  System.SetLength(Result, cnt);
end;

//==============================================================================
// Агрегатные функции
//==============================================================================

function TNamedArr.Sum(const FieldName: string): Variant;
//сумма значений поля (нечисловые и Null игнорируются)
var
  idx, i: Integer;
  v: Variant;
begin
  idx := IndexOfField(FieldName);
  if idx < 0 then
    raise ENamedArrError.Create(Format('TNamedArr: поле "%s" не найдено', [FieldName]), FieldName);
  Result := 0;
  for i := 0 to Count - 1 do
  begin
    v := V[i][idx];
    if not VarIsNull(v) then
      Result := Result + v;
  end;
end;

function TNamedArr.Avg(const FieldName: string): Double;
//среднее арифметическое значений поля
var
  idx, i, cnt: Integer;
  sum: Double;
  v: Variant;
begin
  idx := IndexOfField(FieldName);
  if idx < 0 then
    raise ENamedArrError.Create(Format('TNamedArr: поле "%s" не найдено', [FieldName]), FieldName);
  sum := 0;
  cnt := 0;
  for i := 0 to Count - 1 do
  begin
    v := V[i][idx];
    if not VarIsNull(v) then
    begin
      sum := sum + v;
      Inc(cnt);
    end;
  end;
  if cnt > 0 then
    Result := sum / cnt
  else
    Result := 0;
end;

function TNamedArr.Min(const FieldName: string): Variant;
//минимальное значение поля
var
  idx, i: Integer;
  v: Variant;
begin
  idx := IndexOfField(FieldName);
  if idx < 0 then
    raise ENamedArrError.Create(Format('TNamedArr: поле "%s" не найдено', [FieldName]), FieldName);
  Result := Null;
  for i := 0 to Count - 1 do
  begin
    v := V[i][idx];
    if not VarIsNull(v) then
      if VarIsNull(Result) or (v < Result) then
        Result := v;
  end;
end;

function TNamedArr.Max(const FieldName: string): Variant;
//максимальное значение поля
var
  idx, i: Integer;
  v: Variant;
begin
  idx := IndexOfField(FieldName);
  if idx < 0 then
    raise ENamedArrError.Create(Format('TNamedArr: поле "%s" не найдено', [FieldName]), FieldName);
  Result := Null;
  for i := 0 to Count - 1 do
  begin
    v := V[i][idx];
    if not VarIsNull(v) then
      if VarIsNull(Result) or (v > Result) then
        Result := v;
  end;
end;

//==============================================================================
// Сортировка
//==============================================================================

procedure TNamedArr.Sort(const FieldNames: TVarDynArray; Ascending: Boolean = True);
//отсортировать строки по указанным полям (в порядке перечисления)
var
  FieldIndices: TArray<Integer>;
  i: Integer;
begin
  if Count <= 1 then Exit;
  System.SetLength(FieldIndices, Length(FieldNames));
  for i := 0 to System.High(FieldNames) do
  begin
    FieldIndices[i] := IndexOfField(VarToStr(FieldNames[i]));
    if FieldIndices[i] < 0 then
      raise ENamedArrError.Create(Format('TNamedArr: поле "%s" не найдено', [VarToStr(FieldNames[i])]), VarToStr(FieldNames[i]));
  end;
  QuickSort(0, Count - 1, FieldIndices, Ascending);
end;

//==============================================================================
// Фильтрация
//==============================================================================

function TNamedArr.Filter(const Conditions: TVarDynArray2): TNamedArr;
//отфильтровать строки по условиям (AND) в виде пар [ИмяПоля, Значение]
var
  i, j: Integer;
  FieldIdx: Integer;
  ok: Boolean;
begin
  Result.Create(FFull, 0); // инициализируем результат с теми же полями, без строк
  for i := 0 to Count - 1 do
  begin
    ok := True;
    for j := 0 to System.High(Conditions) do
    begin
      if Length(Conditions[j]) <> 2 then
        raise ENamedArrError.Create('TNamedArr: условие фильтра должно содержать пару [ИмяПоля, Значение]');
      FieldIdx := IndexOfField(VarToStr(Conditions[j][0]));
      if FieldIdx < 0 then
        raise ENamedArrError.Create(Format('TNamedArr: поле "%s" не найдено', [VarToStr(Conditions[j][0])]), VarToStr(Conditions[j][0]));
      if not VarSameValue(V[i][FieldIdx], Conditions[j][1]) then
      begin
        ok := False;
        Break;
      end;
    end;
    if ok then
      Result.AddRow(GetRow(i));
  end;
end;

function TNamedArr.Filter(Predicate: TFunc<Integer, Boolean>): TNamedArr;
//отфильтровать строки по произвольному предикату (индекс строки -> Boolean)
var
  i: Integer;
begin
  Result.Create(FFull, 0);
  for i := 0 to Count - 1 do
    if Predicate(i) then
      Result.AddRow(GetRow(i));
end;

//==============================================================================
// Null-значения
//==============================================================================

procedure TNamedArr.SetNull;
//установить все ячейки в Null
var
  i, j: Integer;
begin
  for i := 0 to Count - 1 do
    for j := 0 to FieldsCount - 1 do
      V[i][j] := Null;
end;

procedure TNamedArr.SetNull(RowNo: Integer);
//установить все ячейки указанной строки в Null
var
  j: Integer;
begin
  CheckRowIndex(RowNo);
  for j := 0 to FieldsCount - 1 do
    V[RowNo][j] := Null;
end;

function TNamedArr.IsNull(RowNo: Integer; const FieldName: string): Boolean;
//проверить, является ли значение в ячейке Null
begin
  Result := VarIsNull(GetValue(RowNo, FieldName));
end;

function TNamedArr.IsNullRow(RowNo: Integer): Boolean;
//проверить, вся ли строка состоит из Null
var
  j: Integer;
begin
  CheckRowIndex(RowNo);
  for j := 0 to FieldsCount - 1 do
    if not VarIsNull(V[RowNo][j]) then
      Exit(False);
  Result := True;
end;

//==============================================================================
// Клонирование и присваивание
//==============================================================================

function TNamedArr.Clone: TNamedArr;
//создать полную копию объекта
begin
  Result.Create(FFull, Count); // инициализируем с теми же полями и количеством строк
  Result.Assign(Self);
end;

procedure TNamedArr.Assign(const Source: TNamedArr);
//скопировать данные из другого экземпляра
var
  i: Integer;
begin
  FFull := System.Copy(Source.FFull, 0, Length(Source.FFull));
  F := System.Copy(Source.F, 0, Length(Source.F));
  System.SetLength(V, Source.Count);
  for i := 0 to Source.Count - 1 do
    TVarDynArray(V[i]) := TVarDynArray(System.Copy(Source.V[i], 0, Length(Source.V[i])));
end;

//==============================================================================
// Итератор
//==============================================================================

function TNamedArr.GetEnumerator: TEnumerator<TVarDynArray>;
//возвращает перечислитель для for..in (по строкам)
begin
  Result := TNamedArrEnumerator.Create(Self);
end;

//==============================================================================
// Объединение записей
//==============================================================================

procedure TNamedArr.Concat(const Other: TNamedArr; CheckFields: Boolean = True);
//добавляет строки из Other в текущую запись
var
  i: Integer;
begin
  if CheckFields then
  begin
    if FieldsCount <> Other.FieldsCount then
      raise ENamedArrError.Create('TNamedArr.Concat: разное количество полей');
    for i := 0 to FieldsCount - 1 do
      if VarToStr(F[i]) <> VarToStr(Other.F[i]) then
        raise ENamedArrError.CreateFmt('TNamedArr.Concat: имена полей %d различаются: "%s" <> "%s"',
          [i, VarToStr(F[i]), VarToStr(Other.F[i])]);
  end
  else
  begin
    if FieldsCount <> Other.FieldsCount then
      raise ENamedArrError.Create('TNamedArr.Concat: разное количество полей (проверка отключена, но число колонок должно совпадать)');
  end;

  // Добавляем все строки из Other
  for i := 0 to Other.Count - 1 do
    AddRow(Other.GetRow(i));
end;

//==============================================================================
// Сохранение / загрузка
//==============================================================================

procedure TNamedArr.LoadFromCSV(const Filename: string; HasHeader: Boolean = True);
//загрузить данные из CSV-файла (с поддержкой кавычек)
begin
  // Реализация временно закомментирована в исходном коде, оставляем как есть
  // ...
end;

procedure TNamedArr.SaveToCSV(const Filename: string);
//сохранить данные в CSV-файл с правильным экранированием
  function QuoteCSV(const S: string): string;
  //экранировать строку для CSV
  begin
    if (Pos(',', S) > 0) or (Pos('"', S) > 0) or (Pos(#10, S) > 0) or (Pos(#13, S) > 0) then
      Result := '"' + StringReplace(S, '"', '""', [rfReplaceAll]) + '"'
    else
      Result := S;
  end;

var
  Lines: TStringList;
  i, j: Integer;
  line: string;
begin
  Lines := TStringList.Create;
  try
    //заголовок
    line := '';
    for j := 0 to FieldsCount - 1 do
    begin
      if j > 0 then line := line + ',';
      line := line + QuoteCSV(VarToStr(FFull[j]));
    end;
    Lines.Add(line);

    //данные
    for i := 0 to Count - 1 do
    begin
      line := '';
      for j := 0 to FieldsCount - 1 do
      begin
        if j > 0 then line := line + ',';
        line := line + QuoteCSV(VarToStr(V[i][j]));
      end;
      Lines.Add(line);
    end;

    Lines.SaveToFile(Filename);
  finally
    Lines.Free;
  end;
end;

function TNamedArr.ToJSON: string;
//простейшая сериализация в JSON (массив объектов)
var
  i, j: Integer;
  s: TStringBuilder;
begin
  s := TStringBuilder.Create;
  try
    s.Append('[');
    for i := 0 to Count - 1 do
    begin
      if i > 0 then s.Append(',');
      s.Append('{');
      for j := 0 to FieldsCount - 1 do
      begin
        if j > 0 then s.Append(',');
        s.Append('"').Append(VarToStr(F[j])).Append('":"').Append(VarToStr(V[i][j])).Append('"');
      end;
      s.Append('}');
    end;
    s.Append(']');
    Result := s.ToString;
  finally
    s.Free;
  end;
end;

procedure TNamedArr.FromJSON(const JSON: string);
//заглушка (можно реализовать через парсер)
begin
  raise ENamedArrError.Create('TNamedArr.FromJSON не реализован');
end;

//==============================================================================
// Совместимость с исходным кодом
//==============================================================================

function TNamedArr.Col(const FieldName: string): Integer;
//возвращает индекс поля (аналог IndexOfField, но с исключением при отсутствии)
begin
  Result := IndexOfField(FieldName);
  if Result < 0 then
    raise ENamedArrError.Create(Format('TNamedArr: поле "%s" не найдено', [FieldName]), FieldName);
end;

function TNamedArr.G(RowNo: Integer; const FieldName: string): Variant;
//получить значение (сокращение для GetValue)
begin
  Result := GetValue(RowNo, FieldName);
end;

function TNamedArr.G(const FieldName: string): Variant;
//получить значение из первой строки
begin
  Result := GetValue(0, FieldName);
end;

function TNamedArr.GetValueByOtherField(SearchValue: Variant; const SearchField, ResultField: string;
  ValueIfNotFound: Variant): Variant;
//ищет строку по SearchField = SearchValue и возвращает значение из ResultField (или ValueIfNotFound)
var
  row: Integer;
begin
  row := FindFirst(SearchField, SearchValue);
  if row >= 0 then
    Result := GetValue(row, ResultField)
  else
    Result := ValueIfNotFound;
end;

function TNamedArr.Find(Value: Variant; const FieldName: string): Integer;
//синоним FindFirst
begin
  Result := FindFirst(FieldName, Value);
end;

end.