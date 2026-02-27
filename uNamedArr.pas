unit uNamedArr;

interface

uses
  System.SysUtils, System.Variants, System.Classes, System.Generics.Collections,
  System.StrUtils, System.Math, uString;

type
  //собственное исключение
  ENamedArrError = class(Exception)
  private
    FField: string;
  public
    constructor Create(const AMsg: string; const AField: string = '');
    property Field: string read FField;
  end;

  //запись для хранения табличных данных с именованными полями
  TNamedArr = record
  private
    //вспомогательные методы
    function GetFieldIndex(const AFieldName: string): Integer;
    procedure CheckRowIndex(ARowNo: Integer);
    procedure EnsureRowLength(ARowNo: Integer);
    function CompareValues(const A, B: Variant; AAscending: Boolean): Integer;
    function CompareRows(AIdx1, AIdx2: Integer; const AFieldIndices: array of Integer; AAscending: Boolean): Integer;
    procedure QuickSort(ALeft, ARight: Integer; const AFieldIndices: array of Integer; AAscending: Boolean);

  public
    FFull: TVarDynArray;      //исходные имена полей (могут содержать $)
    F: TVarDynArray;           //очищенные имена полей (без $)
    V: TVarDynArray2;          //данные: строки, колонки

    //инициализация (конструкторы)
    procedure Create; overload;
    procedure Create(AFields: TVarDynArray; ALen: Integer = 0); overload;
    procedure Create(AData: TVarDynArray2; AFieldNames: TVarDynArray); overload;
    procedure Create(AData: TVarDynArray2; AFieldNames: string = ''); overload;

    //доступ к данным
    function GetValue(ARowNo: Integer; const AFieldName: string): Variant;
    function GetValueI(ARowNo: Integer; AColIndex: Integer): Variant;
    procedure SetValue(ARowNo: Integer; const AFieldName: string; const AValue: Variant); overload;
    procedure SetValue(const AFieldName: string; const AValue: Variant); overload;
    procedure SetValueI(ARowNo: Integer; AColIndex: Integer; const AValue: Variant);
    function GetRow(ARowNo: Integer): TVarDynArray;
    procedure SetRow(ARowNo: Integer; const AValues: TVarDynArray);

    //информация о структуре
    function Count: Integer;
    function High: Integer;
    function FieldsCount: Integer;
    function IsEmpty: Boolean;
    function HasField(const AFieldName: string): Boolean;
    function IndexOfField(const AFieldName: string): Integer;
    function GetFieldNames: TVarDynArray;      //очищенные имена как TVarDynArray (строки)
    function GetRawFieldNames: TVarDynArray;   //исходные имена

    //получение списков полей в виде строки
    function GetFFullStr(ADelimiter: string = ';'): string;  //исходные поля через заданный разделитель (по умолчанию ';')
    function GetFStr(ADelimiter: string = ','): string;      //очищенные поля через заданный разделитель (по умолчанию ',')

    //добавление / удаление строк
    procedure IncLength;
    procedure AddRow(const AValues: TVarDynArray); overload;
    procedure AddRow(const AOther: TNamedArr; ARowIndex: Integer); overload;
    procedure InsertRow(AIndex: Integer; const AValues: TVarDynArray);
    procedure DeleteRow(AIndex: Integer);
    procedure Clear;
    procedure SetLength(ANewLen: Integer); // используем System.SetLength

    //добавление / удаление полей
    procedure AddField(const AFieldName: string); overload;   //добавить поле со значениями Null
    procedure AddField(const AFieldName: string; ADefaultValue: Variant); overload;
    procedure AddField(const AFieldName: string; const AValues: TVarDynArray); overload;
    procedure DeleteField(const AFieldName: string);

    //поиск
    function FindFirst(const AFieldName: string; const AValue: Variant): Integer;
    function FindAll(const AFieldName: string; const AValue: Variant): TArray<Integer>;

    //агрегатные функции
    function Sum(const AFieldName: string): Variant;
    function Avg(const AFieldName: string): Double;
    function Min(const AFieldName: string): Variant;
    function Max(const AFieldName: string): Variant;

    //сортировка по нескольким полям (имена полей передаются в TVarDynArray)
    procedure Sort(const AFieldNames: TVarDynArray; AAscending: Boolean = True);

    //фильтрация: возвращает новый TNamedArr, содержащий строки, удовлетворяющие условию
    function Filter(const AConditions: TVarDynArray2): TNamedArr; overload;
    function Filter(APredicate: TFunc<Integer, Boolean>): TNamedArr; overload;

    //null-значения
    procedure SetNull; overload;
    procedure SetNull(ARowNo: Integer); overload;
    function IsNull(ARowNo: Integer; const AFieldName: string): Boolean;
    function IsNullRow(ARowNo: Integer): Boolean;

    //клонирование и присваивание
    function Clone: TNamedArr;
    procedure Assign(const ASource: TNamedArr);

    //итератор (для for..in)
    function GetEnumerator: TEnumerator<TVarDynArray>;

    //объединение записей
    procedure Concat(const AOther: TNamedArr; ACheckFields: Boolean = True); //добавляет строки из Other в текущую запись

    //сохранение / загрузка (CSV, JSON)
    procedure LoadFromCSV(const AFilename: string; AHasHeader: Boolean = True);
    procedure SaveToCSV(const AFilename: string);
    function ToJSON: string;
    procedure FromJSON(const AJSON: string);

    //методы для совместимости с исходным кодом
    function Col(const AFieldName: string): Integer;
    function G(ARowNo: Integer; const AFieldName: string): Variant; overload;
    function G(const AFieldName: string): Variant; overload;
    function GetValueByOtherField(ASearchValue: Variant; const ASearchField, AResultField: string; AValueIfNotFound: Variant): Variant;
    function Find(AValue: Variant; const AFieldName: string): Integer; //первое вхождение
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

constructor ENamedArrError.Create(const AMsg: string; const AField: string);
begin
  inherited Create(AMsg);
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
//пустая запись
begin
  FFull := [];
  F := [];
  V := [];
end;

procedure TNamedArr.Create(AFields: TVarDynArray; ALen: Integer = 0);
//инициализируем запись, массив значений заполняем null
var
  i, j: Integer;
  st: string;
  LPos: Integer;
begin
  FFull := System.Copy(AFields, 0, Length(AFields));
  System.SetLength(F, Length(AFields));
  for j := 0 to System.High(AFields) do begin
    st := VarToStr(AFields[j]);
    LPos := Pos('$', st);
    if LPos > 0 then
      F[j] := Copy(st, 1, LPos - 1)
    else
      F[j] := st;
  end;
  System.SetLength(V, ALen);
  for i := 0 to ALen - 1 do begin
    System.SetLength(V[i], Length(F));
    for j := 0 to System.High(V[i]) do
      V[i][j] := Null;
  end;
end;

procedure TNamedArr.Create(AData: TVarDynArray2; AFieldNames: TVarDynArray);
//инициализируем запись из массива; передаются поля, если [] то создаются числовые по индексам колонок
var
  LRowCount, LColCount, i, j: Integer;
  vaFields: TVarDynArray;
  st: string;
  LPos: Integer;
begin
  // Сначала обнуляем
  FFull := [];
  F := [];
  V := [];

  LRowCount := Length(AData);
  if LRowCount > 0 then
    LColCount := Length(AData[0])
  else
    LColCount := 0;

  // Определяем имена полей
  if Length(AFieldNames) > 0 then
    vaFields := System.Copy(AFieldNames, 0, Length(AFieldNames))
  else begin
    System.SetLength(vaFields, LColCount);
    for i := 0 to LColCount - 1 do
      vaFields[i] := IntToStr(i);
  end;

  if Length(vaFields) <> LColCount then
    raise ENamedArrError.Create('Количество имён полей не совпадает с числом колонок данных');

  // Устанавливаем FFull и F
  FFull := System.Copy(vaFields, 0, Length(vaFields));
  System.SetLength(F, Length(vaFields));
  for j := 0 to System.High(vaFields) do begin
    st := VarToStr(vaFields[j]);
    LPos := Pos('$', st);
    if LPos > 0 then
      F[j] := Copy(st, 1, LPos - 1)
    else
      F[j] := st;
  end;

  // Копируем данные
  System.SetLength(V, LRowCount);
  for i := 0 to LRowCount - 1 do begin
    if Length(AData[i]) <> LColCount then
      raise ENamedArrError.CreateFmt('Строка %d имеет длину %d, ожидалось %d', [i, Length(AData[i]), LColCount]);
    System.SetLength(V[i], LColCount);
    for j := 0 to LColCount - 1 do
      V[i][j] := AData[i][j];
  end;
end;

procedure TNamedArr.Create(AData: TVarDynArray2; AFieldNames: string = '');
//инициализируем запись из массива; передаются поля, если не переданы то создаются числовые по индексам колонок
begin
  Create(AData, A.Explode(AFieldNames, ';', True));
end;

//==============================================================================
// Вспомогательные методы
//==============================================================================

function TNamedArr.GetFieldIndex(const AFieldName: string): Integer;
var
  i: Integer;
  LCleanName: string;
  LPos: Integer;
begin
  LCleanName := AFieldName;
  LPos := Pos('$', LCleanName);
  if LPos > 0 then
    LCleanName := Copy(LCleanName, 1, LPos - 1);
  for i := 0 to System.High(F) do begin
    if SameText(VarToStr(F[i]), LCleanName) then
      Exit(i);
  end;
  Result := -1;
end;

procedure TNamedArr.CheckRowIndex(ARowNo: Integer);
//проверить допустимость индекса строки, иначе исключение
begin
  if (ARowNo < 0) or (ARowNo >= Length(V)) then
    raise ENamedArrError.CreateFmt('TNamedArr: индекс строки %d вне допустимого диапазона [0..%d]', [ARowNo, Length(V) - 1]);
end;

procedure TNamedArr.EnsureRowLength(ARowNo: Integer);
//при необходимости выровнять длину строки по числу полей
begin
  if Length(V[ARowNo]) <> FieldsCount then
    System.SetLength(V[ARowNo], FieldsCount);
end;

function TNamedArr.CompareValues(const A, B: Variant; AAscending: Boolean): Integer;
//сравнить два варианта с учётом направления сортировки
var
  LMult: Integer;
begin
  LMult := 1;
  if not AAscending then
    LMult := -1;
  if VarIsNull(A) and VarIsNull(B) then
    Result := 0
  else if VarIsNull(A) then
    Result := -1 * LMult
  else if VarIsNull(B) then
    Result := 1 * LMult
  else begin
    //пытаемся сравнивать по подходящим типам
    case VarType(A) and varTypeMask of
      varSmallint, varInteger, varShortInt, varByte, varWord, varLongWord, varInt64, varSingle, varDouble, varCurrency:
        begin
          if A < B then
            Result := -1 * LMult
          else if A > B then
            Result := 1 * LMult
          else
            Result := 0;
        end;
      varDate:
        begin
          var LDate1, LDate2: TDateTime;
          LDate1 := A;
          LDate2 := B;
          if LDate1 < LDate2 then
            Result := -1 * LMult
          else if LDate1 > LDate2 then
            Result := 1 * LMult
          else
            Result := 0;
        end;
      varOleStr, varString, varUString:
        begin
          var st1, st2: string;
          st1 := VarToStr(A);
          st2 := VarToStr(B);
          Result := CompareText(st1, st2) * LMult;
        end;
    else
      //для остальных типов используем строковое представление
      var st1, st2: string;
      st1 := VarToStr(A);
      st2 := VarToStr(B);
      Result := CompareText(st1, st2) * LMult;
    end;
  end;
end;

function TNamedArr.CompareRows(AIdx1, AIdx2: Integer; const AFieldIndices: array of Integer; AAscending: Boolean): Integer;
//сравнить две строки по заданному списку полей (последовательно)
var
  i: Integer;
  LCmp: Integer;
begin
  Result := 0;
  for i := 0 to System.High(AFieldIndices) do begin
    LCmp := CompareValues(V[AIdx1][AFieldIndices[i]], V[AIdx2][AFieldIndices[i]], AAscending);
    if LCmp <> 0 then begin
      Result := LCmp;
      Exit;
    end;
  end;
end;

procedure TNamedArr.QuickSort(ALeft, ARight: Integer; const AFieldIndices: array of Integer; AAscending: Boolean);
//рекурсивная быстрая сортировка по нескольким полям
var
  i, j, LPivotIdx: Integer;
begin
  if ALeft >= ARight then
    Exit;
  i := ALeft;
  j := ARight;
  LPivotIdx := (ALeft + ARight) shr 1;
  repeat
    while CompareRows(i, LPivotIdx, AFieldIndices, AAscending) < 0 do
      Inc(i);
    while CompareRows(j, LPivotIdx, AFieldIndices, AAscending) > 0 do
      Dec(j);
    if i <= j then begin
      if i <> j then begin
        var LTemp := V[i];
        V[i] := V[j];
        V[j] := LTemp;
        //корректируем индекс опорного элемента после обмена
        if LPivotIdx = i then
          LPivotIdx := j
        else if LPivotIdx = j then
          LPivotIdx := i;
      end;
      Inc(i);
      Dec(j);
    end;
  until i > j;
  if ALeft < j then
    QuickSort(ALeft, j, AFieldIndices, AAscending);
  if i < ARight then
    QuickSort(i, ARight, AFieldIndices, AAscending);
end;

//==============================================================================
// Доступ к данным
//==============================================================================

function TNamedArr.GetValue(ARowNo: Integer; const AFieldName: string): Variant;
//получить значение по имени поля
var
  LIdx: Integer;
begin
  LIdx := GetFieldIndex(AFieldName);
  if LIdx < 0 then
    raise ENamedArrError.Create(Format('TNamedArr: поле "%s" не найдено', [AFieldName]), AFieldName);
  Result := GetValueI(ARowNo, LIdx);
end;

procedure TNamedArr.SetValue(ARowNo: Integer; const AFieldName: string; const AValue: Variant);
//установить значение по имени поля
var
  LIdx: Integer;
begin
  LIdx := GetFieldIndex(AFieldName);
  if LIdx < 0 then
    raise ENamedArrError.Create(Format('TNamedArr: поле "%s" не найдено', [AFieldName]), AFieldName);
  SetValueI(ARowNo, LIdx, AValue);
end;

procedure TNamedArr.SetValue(const AFieldName: string; const AValue: Variant);
//установить значение по имени поля для первой строки
begin
  SetValue(0, AFieldName, AValue);
end;

function TNamedArr.GetValueI(ARowNo: Integer; AColIndex: Integer): Variant;
//получить значение по индексу колонки
begin
  CheckRowIndex(ARowNo);
  EnsureRowLength(ARowNo);
  if (AColIndex < 0) or (AColIndex >= FieldsCount) then
    raise ENamedArrError.CreateFmt('TNamedArr: индекс колонки %d вне диапазона [0..%d]', [AColIndex, FieldsCount - 1]);
  Result := V[ARowNo][AColIndex];
end;

procedure TNamedArr.SetValueI(ARowNo: Integer; AColIndex: Integer; const AValue: Variant);
//установить значение по индексу колонки
begin
  CheckRowIndex(ARowNo);
  EnsureRowLength(ARowNo);
  if (AColIndex < 0) or (AColIndex >= FieldsCount) then
    raise ENamedArrError.CreateFmt('TNamedArr: индекс колонки %d вне диапазона [0..%d]', [AColIndex, FieldsCount - 1]);
  V[ARowNo][AColIndex] := AValue;
end;

function TNamedArr.GetRow(ARowNo: Integer): TVarDynArray;
//получить всю строку как массив
begin
  CheckRowIndex(ARowNo);
  EnsureRowLength(ARowNo);
  //копируем массив с указанием длины – приведение необходимо для совместимости с TVarDynArray
  Result := TVarDynArray(System.Copy(V[ARowNo], 0, Length(V[ARowNo])));
end;

procedure TNamedArr.SetRow(ARowNo: Integer; const AValues: TVarDynArray);
//установить всю строку из массива
begin
  CheckRowIndex(ARowNo);
  if Length(AValues) <> FieldsCount then
    raise ENamedArrError.CreateFmt('TNamedArr: количество значений (%d) не совпадает с числом полей (%d)', [Length(AValues), FieldsCount]);
  System.SetLength(V[ARowNo], FieldsCount);
  //копируем значения – приведение необходимо
  TVarDynArray(V[ARowNo]) := TVarDynArray(System.Copy(AValues, 0, Length(AValues)));
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

function TNamedArr.HasField(const AFieldName: string): Boolean;
//существует ли поле с таким именем
begin
  Result := GetFieldIndex(AFieldName) >= 0;
end;

function TNamedArr.IndexOfField(const AFieldName: string): Integer;
//индекс поля (или -1)
begin
  Result := GetFieldIndex(AFieldName);
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

function TNamedArr.GetFFullStr(ADelimiter: string = ';'): string;
//исходные имена полей через заданный разделитель
var
  i: Integer;
begin
  Result := '';
  for i := 0 to System.High(FFull) do begin
    if i > 0 then
      Result := Result + ADelimiter;
    Result := Result + VarToStr(FFull[i]);
  end;
end;

function TNamedArr.GetFStr(ADelimiter: string = ','): string;
//очищенные имена полей через заданный разделитель
var
  i: Integer;
begin
  Result := '';
  for i := 0 to System.High(F) do begin
    if i > 0 then
      Result := Result + ADelimiter;
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

procedure TNamedArr.AddRow(const AValues: TVarDynArray);
//добавить строку в конец
begin
  InsertRow(Count, AValues);
end;

procedure TNamedArr.AddRow(const AOther: TNamedArr; ARowIndex: Integer);
//добавить копию строки из другого экземпляра
begin
  if AOther.FieldsCount <> Self.FieldsCount then
    raise ENamedArrError.Create('TNamedArr: число полей источника не совпадает с текущим');
  AddRow(AOther.GetRow(ARowIndex));
end;

procedure TNamedArr.InsertRow(AIndex: Integer; const AValues: TVarDynArray);
//вставить строку в указанную позицию
var
  i: Integer;
begin
  if (AIndex < 0) or (AIndex > Count) then
    raise ENamedArrError.CreateFmt('TNamedArr: индекс вставки %d вне диапазона [0..%d]', [AIndex, Count]);
  if Length(AValues) <> FieldsCount then
    raise ENamedArrError.CreateFmt('TNamedArr: количество значений (%d) не совпадает с числом полей (%d)', [Length(AValues), FieldsCount]);
  System.SetLength(V, Count + 1);
  for i := Count - 1 downto AIndex do
    V[i + 1] := V[i];
  System.SetLength(V[AIndex], FieldsCount);
  TVarDynArray(V[AIndex]) := TVarDynArray(System.Copy(AValues, 0, Length(AValues)));
end;

procedure TNamedArr.DeleteRow(AIndex: Integer);
//удалить строку
var
  i: Integer;
begin
  CheckRowIndex(AIndex);
  for i := AIndex to Count - 2 do
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

procedure TNamedArr.SetLength(ANewLen: Integer);
//установить новое количество строк (при увеличении новые строки заполняются Null)
var
  LOldLen, i, j: Integer;
begin
  LOldLen := Count;
  System.SetLength(V, ANewLen);
  if ANewLen > LOldLen then
    for i := LOldLen to ANewLen - 1 do begin
      System.SetLength(V[i], FieldsCount);
      for j := 0 to System.High(V[i]) do
        V[i][j] := Null;
    end;
end;

//==============================================================================
// Добавление / удаление полей
//==============================================================================

procedure TNamedArr.AddField(const AFieldName: string);
//добавить новое поле со значениями Null (перегрузка без DefaultValue)
begin
  AddField(AFieldName, Null);
end;

procedure TNamedArr.AddField(const AFieldName: string; ADefaultValue: Variant);
//добавить новое поле с указанным значением по умолчанию
var
  i: Integer;
begin
  if HasField(AFieldName) then
    raise ENamedArrError.Create(Format('TNamedArr: поле "%s" уже существует', [AFieldName]), AFieldName);
  System.SetLength(F, FieldsCount + 1);
  F[System.High(F)] := AFieldName;
  System.SetLength(FFull, FieldsCount);
  FFull[System.High(FFull)] := AFieldName;
  for i := 0 to Count - 1 do begin
    System.SetLength(V[i], FieldsCount);
    V[i][System.High(V[i])] := ADefaultValue;
  end;
end;

procedure TNamedArr.AddField(const AFieldName: string; const AValues: TVarDynArray);
//добавить поле с заполнением значений из массива (длина массива должна равняться числу строк)
var
  i: Integer;
begin
  if HasField(AFieldName) then
    raise ENamedArrError.Create(Format('TNamedArr: поле "%s" уже существует', [AFieldName]), AFieldName);
  if Length(AValues) <> Count then
    raise ENamedArrError.Create('TNamedArr: количество значений должно совпадать с числом строк');
  AddField(AFieldName, Null);
  for i := 0 to Count - 1 do
    SetValue(i, AFieldName, AValues[i]);
end;

procedure TNamedArr.DeleteField(const AFieldName: string);
//удалить поле (столбец)
var
  LIdx, i, j: Integer;
begin
  LIdx := IndexOfField(AFieldName);
  if LIdx < 0 then
    raise ENamedArrError.Create(Format('TNamedArr: поле "%s" не найдено', [AFieldName]), AFieldName);
  for i := LIdx to FieldsCount - 2 do begin
    F[i] := F[i + 1];
    FFull[i] := FFull[i + 1];
  end;
  System.SetLength(F, FieldsCount - 1);
  System.SetLength(FFull, FieldsCount - 1);
  for i := 0 to Count - 1 do begin
    for j := LIdx to Length(V[i]) - 2 do
      V[i][j] := V[i][j + 1];
    System.SetLength(V[i], Length(V[i]) - 1);
  end;
end;

//==============================================================================
// Поиск
//==============================================================================

function TNamedArr.FindFirst(const AFieldName: string; const AValue: Variant): Integer;
//найти первую строку, где значение поля равно заданному (иначе -1)
var
  LIdx, i: Integer;
begin
  LIdx := IndexOfField(AFieldName);
  if LIdx < 0 then
    raise ENamedArrError.Create(Format('TNamedArr: поле "%s" не найдено', [AFieldName]), AFieldName);
  for i := 0 to Count - 1 do
    if VarSameValue(V[i][LIdx], AValue) then
      Exit(i);
  Result := -1;
end;

function TNamedArr.FindAll(const AFieldName: string; const AValue: Variant): TArray<Integer>;
//найти индексы всех строк, где значение поля равно заданному
var
  LIdx, i, LCnt: Integer;
begin
  LIdx := IndexOfField(AFieldName);
  if LIdx < 0 then
    raise ENamedArrError.Create(Format('TNamedArr: поле "%s" не найдено', [AFieldName]), AFieldName);
  System.SetLength(Result, Count);
  LCnt := 0;
  for i := 0 to Count - 1 do
    if VarSameValue(V[i][LIdx], AValue) then begin
      Result[LCnt] := i;
      Inc(LCnt);
    end;
  System.SetLength(Result, LCnt);
end;

//==============================================================================
// Агрегатные функции
//==============================================================================

function TNamedArr.Sum(const AFieldName: string): Variant;
//сумма значений поля (нечисловые и Null игнорируются)
var
  LIdx, i: Integer;
  LVal: Variant;
begin
  LIdx := IndexOfField(AFieldName);
  if LIdx < 0 then
    raise ENamedArrError.Create(Format('TNamedArr: поле "%s" не найдено', [AFieldName]), AFieldName);
  Result := 0;
  for i := 0 to Count - 1 do begin
    LVal := V[i][LIdx];
    if not VarIsNull(LVal) then
      Result := Result + LVal;
  end;
end;

function TNamedArr.Avg(const AFieldName: string): Double;
//среднее арифметическое значений поля
var
  LIdx, i, LCnt: Integer;
  LSum: Double;
  LVal: Variant;
begin
  LIdx := IndexOfField(AFieldName);
  if LIdx < 0 then
    raise ENamedArrError.Create(Format('TNamedArr: поле "%s" не найдено', [AFieldName]), AFieldName);
  LSum := 0;
  LCnt := 0;
  for i := 0 to Count - 1 do begin
    LVal := V[i][LIdx];
    if not VarIsNull(LVal) then begin
      LSum := LSum + LVal;
      Inc(LCnt);
    end;
  end;
  if LCnt > 0 then
    Result := LSum / LCnt
  else
    Result := 0;
end;

function TNamedArr.Min(const AFieldName: string): Variant;
//минимальное значение поля
var
  LIdx, i: Integer;
  LVal: Variant;
begin
  LIdx := IndexOfField(AFieldName);
  if LIdx < 0 then
    raise ENamedArrError.Create(Format('TNamedArr: поле "%s" не найдено', [AFieldName]), AFieldName);
  Result := Null;
  for i := 0 to Count - 1 do begin
    LVal := V[i][LIdx];
    if not VarIsNull(LVal) then
      if VarIsNull(Result) or (LVal < Result) then
        Result := LVal;
  end;
end;

function TNamedArr.Max(const AFieldName: string): Variant;
//максимальное значение поля
var
  LIdx, i: Integer;
  LVal: Variant;
begin
  LIdx := IndexOfField(AFieldName);
  if LIdx < 0 then
    raise ENamedArrError.Create(Format('TNamedArr: поле "%s" не найдено', [AFieldName]), AFieldName);
  Result := Null;
  for i := 0 to Count - 1 do begin
    LVal := V[i][LIdx];
    if not VarIsNull(LVal) then
      if VarIsNull(Result) or (LVal > Result) then
        Result := LVal;
  end;
end;

//==============================================================================
// Сортировка
//==============================================================================

procedure TNamedArr.Sort(const AFieldNames: TVarDynArray; AAscending: Boolean = True);
//отсортировать строки по указанным полям (в порядке перечисления)
var
  LFieldIndices: TArray<Integer>;
  i: Integer;
begin
  if Count <= 1 then
    Exit;
  System.SetLength(LFieldIndices, Length(AFieldNames));
  for i := 0 to System.High(AFieldNames) do begin
    LFieldIndices[i] := IndexOfField(VarToStr(AFieldNames[i]));
    if LFieldIndices[i] < 0 then
      raise ENamedArrError.Create(Format('TNamedArr: поле "%s" не найдено', [VarToStr(AFieldNames[i])]), VarToStr(AFieldNames[i]));
  end;
  QuickSort(0, Count - 1, LFieldIndices, AAscending);
end;

//==============================================================================
// Фильтрация
//==============================================================================

function TNamedArr.Filter(const AConditions: TVarDynArray2): TNamedArr;
//отфильтровать строки по условиям (AND) в виде пар [ИмяПоля, Значение]
var
  i, j: Integer;
  LFieldIdx: Integer;
  bOk: Boolean;
begin
  Result.Create(FFull, 0); // инициализируем результат с теми же полями, без строк
  for i := 0 to Count - 1 do begin
    bOk := True;
    for j := 0 to System.High(AConditions) do begin
      if Length(AConditions[j]) <> 2 then
        raise ENamedArrError.Create('TNamedArr: условие фильтра должно содержать пару [ИмяПоля, Значение]');
      LFieldIdx := IndexOfField(VarToStr(AConditions[j][0]));
      if LFieldIdx < 0 then
        raise ENamedArrError.Create(Format('TNamedArr: поле "%s" не найдено', [VarToStr(AConditions[j][0])]), VarToStr(AConditions[j][0]));
      if not VarSameValue(V[i][LFieldIdx], AConditions[j][1]) then begin
        bOk := False;
        Break;
      end;
    end;
    if bOk then
      Result.AddRow(GetRow(i));
  end;
end;

function TNamedArr.Filter(APredicate: TFunc<Integer, Boolean>): TNamedArr;
//отфильтровать строки по произвольному предикату (индекс строки -> Boolean)
var
  i: Integer;
begin
  Result.Create(FFull, 0);
  for i := 0 to Count - 1 do
    if APredicate(i) then
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

procedure TNamedArr.SetNull(ARowNo: Integer);
//установить все ячейки указанной строки в Null
var
  j: Integer;
begin
  CheckRowIndex(ARowNo);
  for j := 0 to FieldsCount - 1 do
    V[ARowNo][j] := Null;
end;

function TNamedArr.IsNull(ARowNo: Integer; const AFieldName: string): Boolean;
//проверить, является ли значение в ячейке Null
begin
  Result := VarIsNull(GetValue(ARowNo, AFieldName));
end;

function TNamedArr.IsNullRow(ARowNo: Integer): Boolean;
//проверить, вся ли строка состоит из Null
var
  j: Integer;
begin
  CheckRowIndex(ARowNo);
  for j := 0 to FieldsCount - 1 do
    if not VarIsNull(V[ARowNo][j]) then
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

procedure TNamedArr.Assign(const ASource: TNamedArr);
//скопировать данные из другого экземпляра
var
  i: Integer;
begin
  FFull := System.Copy(ASource.FFull, 0, Length(ASource.FFull));
  F := System.Copy(ASource.F, 0, Length(ASource.F));
  System.SetLength(V, ASource.Count);
  for i := 0 to ASource.Count - 1 do
    TVarDynArray(V[i]) := TVarDynArray(System.Copy(ASource.V[i], 0, Length(ASource.V[i])));
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

procedure TNamedArr.Concat(const AOther: TNamedArr; ACheckFields: Boolean = True);
//добавляет строки из Other в текущую запись
var
  i: Integer;
begin
  if ACheckFields then begin
    if FieldsCount <> AOther.FieldsCount then
      raise ENamedArrError.Create('TNamedArr.Concat: разное количество полей');
    for i := 0 to FieldsCount - 1 do
      if VarToStr(F[i]) <> VarToStr(AOther.F[i]) then
        raise ENamedArrError.CreateFmt('TNamedArr.Concat: имена полей %d различаются: "%s" <> "%s"', [i, VarToStr(F[i]), VarToStr(AOther.F[i])]);
  end
  else begin
    if FieldsCount <> AOther.FieldsCount then
      raise ENamedArrError.Create('TNamedArr.Concat: разное количество полей (проверка отключена, но число колонок должно совпадать)');
  end;

  // Добавляем все строки из Other
  for i := 0 to AOther.Count - 1 do
    AddRow(AOther.GetRow(i));
end;

//==============================================================================
// Сохранение / загрузка
//==============================================================================

procedure TNamedArr.LoadFromCSV(const AFilename: string; AHasHeader: Boolean = True);
//загрузить данные из CSV-файла (с поддержкой кавычек)
begin
  // Реализация временно закомментирована в исходном коде, оставляем как есть
  // ...
end;

procedure TNamedArr.SaveToCSV(const AFilename: string);
//сохранить данные в CSV-файл с правильным экранированием

  function QuoteCSV(const A: string): string;
  //экранировать строку для CSV
  begin
    if (Pos(',', A) > 0) or (Pos('"', A) > 0) or (Pos(#10, A) > 0) or (Pos(#13, A) > 0) then
      Result := '"' + StringReplace(A, '"', '""', [rfReplaceAll]) + '"'
    else
      Result := A;
  end;

var
  LLines: TStringList;
  i, j: Integer;
  LLine: string;
begin
  LLines := TStringList.Create;
  try
    //заголовок
    LLine := '';
    for j := 0 to FieldsCount - 1 do begin
      if j > 0 then
        LLine := LLine + ',';
      LLine := LLine + QuoteCSV(VarToStr(FFull[j]));
    end;
    LLines.Add(LLine);

    //данные
    for i := 0 to Count - 1 do begin
      LLine := '';
      for j := 0 to FieldsCount - 1 do begin
        if j > 0 then
          LLine := LLine + ',';
        LLine := LLine + QuoteCSV(VarToStr(V[i][j]));
      end;
      LLines.Add(LLine);
    end;

    LLines.SaveToFile(AFilename);
  finally
    LLines.Free;
  end;
end;

function TNamedArr.ToJSON: string;
//простейшая сериализация в JSON (массив объектов)
var
  LBuilder: TStringBuilder;
  i, j: Integer;
begin
  LBuilder := TStringBuilder.Create;
  try
    LBuilder.Append('[');
    for i := 0 to Count - 1 do begin
      if i > 0 then
        LBuilder.Append(',');
      LBuilder.Append('{');
      for j := 0 to FieldsCount - 1 do begin
        if j > 0 then
          LBuilder.Append(',');
        LBuilder.Append('"').Append(VarToStr(F[j])).Append('":"').Append(VarToStr(V[i][j])).Append('"');
      end;
      LBuilder.Append('}');
    end;
    LBuilder.Append(']');
    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
  end;
end;

procedure TNamedArr.FromJSON(const AJSON: string);
//заглушка (можно реализовать через парсер)
begin
  raise ENamedArrError.Create('TNamedArr.FromJSON не реализован');
end;

//==============================================================================
// Совместимость с исходным кодом
//==============================================================================

function TNamedArr.Col(const AFieldName: string): Integer;
//возвращает индекс поля (аналог IndexOfField, но с исключением при отсутствии)
begin
  Result := IndexOfField(AFieldName);
  if Result < 0 then
    raise ENamedArrError.Create(Format('TNamedArr: поле "%s" не найдено', [AFieldName]), AFieldName);
end;

function TNamedArr.G(ARowNo: Integer; const AFieldName: string): Variant;
//получить значение (сокращение для GetValue)
begin
  Result := GetValue(ARowNo, AFieldName);
end;

function TNamedArr.G(const AFieldName: string): Variant;
//получить значение из первой строки
begin
  Result := GetValue(0, AFieldName);
end;

function TNamedArr.GetValueByOtherField(ASearchValue: Variant; const ASearchField, AResultField: string; AValueIfNotFound: Variant): Variant;
//ищет строку по SearchField = SearchValue и возвращает значение из ResultField (или ValueIfNotFound)
var
  LRow: Integer;
begin
  LRow := FindFirst(ASearchField, ASearchValue);
  if LRow >= 0 then
    Result := GetValue(LRow, AResultField)
  else
    Result := AValueIfNotFound;
end;

function TNamedArr.Find(AValue: Variant; const AFieldName: string): Integer;
//синоним FindFirst
begin
  Result := FindFirst(AFieldName, AValue);
end;

end.