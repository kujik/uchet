unit uFields;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, Vcl.ExtCtrls, Vcl.ComCtrls,
  uData, uForms, uDBOra, uString, uMessages;

type
  TDefFiledcValueType = (
    fvtVName = 0,       //внутреннее имя свойства
    fvtFName = 1,       //полное имя поля (с суффиксом)
    fvtFNameL = 2,      //имя для загрузки
    fvtFNameS = 3,      //имя для сохранения
    fvtCType = 4,       //тип контрола
    fvtCtrl = 5,        //имя контрола
    fvtVBeg = 6,        //начальное значение
    fvtVCurr = 7,       //текущее значение
    fvtVer = 8,         //верификация
    fvtClr = 9,         //цвет (не используется)
    fvtDsbl = 10,       //доступность (Enabled)
    fvtIsChanged = 11,  //флаг изменения
    fvtErrMsg = 12,     //сообщение об ошибке
    fvtErr = 13,        //признак ошибки
    fvtCtrlType = 14,   //тип контрола (числовой код)
    fvtCtrlCaption = 15,//заголовок контрола
    fvtCtrlPanel = 16,  //панель для вставки
    fvtCtrlSizes = 17,  //размеры/положение
    fvtFlags = 18,      //флаги
    fvtTags = 19,       //теги (через запятую)
    fvtCustom = 20      //начало пользовательских индексов
  );

  TDefFiledcValueTypeSet = set of TDefFiledcValueType;

const
  fvpVer = 'V=';        //верификация
  fvpName = 'N=';       //заголовок контрола
  fvpPanel = 'P=';      //панель
  fvpFlags = 'F=';      //флаги
  fvpSizes = 'S=';      //размеры
  fvpTags = 'T=';       //теги

type
  TDefFiledcValue = (
    _D = -MaxInt + 1,
    fvvClearRep = -MaxInt + 2,
    fvvDsbl = -MaxInt + 3
  );

  TFields = class
  private
    FDefineFields: TVarDynArray2;
    FDefineFieldsAdd: TVarDynArray2;
    FSelf: TForm;
    FInPrepare: Boolean;
    FIsFieldsPrepared: Boolean;
    FIsPropControlsSet: Boolean;

    procedure SetFieldValue(AIndex: Integer; ACol: Integer; const AValue: Variant);
    function  GetFieldValue(AIndex, ACol: Integer): Variant;
    procedure PrepareProperty(ARowIndex: Integer);
    function  FindPropertyIndex(const APropName: string; out AIndex: Integer; const AErrorIfNotFound: Boolean = True): Boolean;
    function  FindAllProps(const APropName: string): TVarDynArray;
    function  GetAllPropIndices: TVarDynArray;
    function  CollectIndices(const PropNames: string): TVarDynArray;
  protected
  public
    property DefineFields: TVarDynArray2 read FDefineFields write FDefineFields;
    property IsFieldsPrepared: Boolean read FIsFieldsPrepared;
    property IsPropControlsSet: Boolean read FIsPropControlsSet;

    constructor Create(ASelf: TForm);
    //подготовка расширенного массива из DefineFields
    procedure PrepareDefineFieldsAdd;
    //поиск индекса свойства по имени или тегу (первое вхождение)
    function  FindProp(PropName: string; PropValueType: TDefFiledcValueType = fvtVName; ErrorInNotFouund: Boolean = True): Integer;
    //получение значения свойства
    function  GetProp(PropName: string; PropValueType: TDefFiledcValueType = fvtVCurr): Variant; overload;
    function  GetProp(PropPos: Integer; PropValueType: TDefFiledcValueType = fvtVCurr): Variant; overload;
    function  GetProp(PropName: string; PropValuePos: Integer): Variant; overload;
    function  GetPropB(PropName: string): Variant;
    //получение значений свойства для нескольких полей (поддерживаются теги – возвращает все совпадения)
    function  GetPropValues(PropNames: string; PropValueType: TDefFiledcValueType = fvtVCurr): TVarDynArray;
    //установка значения свойства
    procedure SetProp(PropName: string; Value: Variant; PropValueType: TDefFiledcValueType = fvtVCurr); overload;
    procedure SetProp(AIndex: Integer; Value: Variant; PropValueType: TDefFiledcValueType = fvtVCurr); overload;
    procedure SetProp(PropName: string; Value: Variant; PropValuePos: Integer); overload;
    procedure SetPropP(PropPos: Integer; Value: Variant; PropValueType: TDefFiledcValueType = fvtVCurr); overload;
    //массовые операции
    procedure SetProps(PropNames: string; ValuesAndTypes: TVarDynArray2); overload;
    //установка свойств полей из пользовательских значений (индексы 0,1,... после #0) или из начального значения (fvtVBeg)
    procedure SetPropsFromCustom(PropNames: string; SourceType: TDefFiledcValueType; TargetType: TDefFiledcValueType; const CustomIndex: Integer = 0; const IgnoreMissing: Boolean = True); overload;
    //перегрузка с неявным SourceType = fvtCustom
    procedure SetPropsFromCustom(PropNames: string; CustomIndex: Integer; TargetType: TDefFiledcValueType; const IgnoreMissing: Boolean = True); overload;
    //установка одного значения для нескольких свойств
    procedure SetProps(PropNames: string; Value: Variant; PropValueType: TDefFiledcValueType = fvtVCurr); overload;
    function  SetPropsFromSelect(Values: TVarDynArray2; PropValueType: TDefFiledcValueType = fvtVBeg): Boolean;
    function  SetPropsControls(PropNames: string = ''; PropValueTypes: TDefFiledcValueTypeSet = [fvtVBeg, fvtDsbl, fvtVer]): Integer;
    //служебные методы
    function  PropNameFromControl(C: TObject): string;
    function  Count: Integer;
    function  GetName(i: Integer): string;
  end;

implementation

uses
  uErrors;

{ TFields }

constructor TFields.Create(ASelf: TForm);
//создание экземпляра, сохранение ссылки на форму
begin
  inherited Create;
  FSelf := ASelf;
end;

procedure TFields.SetFieldValue(AIndex, ACol: Integer; const AValue: Variant);
//установка значения в расширенном массиве по индексу строки и колонки
begin
  if (AIndex >= 0) and (AIndex < Length(FDefineFieldsAdd)) then
    FDefineFieldsAdd[AIndex][ACol] := AValue;
end;

function TFields.GetFieldValue(AIndex, ACol: Integer): Variant;
//получение значения из расширенного массива по индексу строки и колонки
begin
  if (AIndex >= 0) and (AIndex < Length(FDefineFieldsAdd)) and
     (ACol >= 0) and (ACol < Length(FDefineFieldsAdd[AIndex])) then
    Result := FDefineFieldsAdd[AIndex][ACol]
  else
    Result := Null;
end;

procedure TFields.PrepareProperty(ARowIndex: Integer);
//подготовка одной строки конфигурации (разбор поля, флагов, значений)
var
  row: TVarDynArray;
  i: Integer;
  v: Variant;
  fieldDef: string;
  ctrlName: string;
  c: TControl;
  tagStr: string;
  userIndex: Integer;
  isUserMode: Boolean;
begin
  row := FDefineFields[ARowIndex];
  SetLength(FDefineFieldsAdd[ARowIndex], Integer(fvtCustom) + 10);
  for i := 0 to High(FDefineFieldsAdd[ARowIndex]) do
  begin
    if i = Integer(fvtCtrlType) then
      FDefineFieldsAdd[ARowIndex][i] := cntUndefined
    else if (i = Integer(fvtVBeg)) or (i = Integer(fvtVCurr)) or (i >= Integer(fvtCustom)) then
      FDefineFieldsAdd[ARowIndex][i] := Null
    else
      FDefineFieldsAdd[ARowIndex][i] := '';
  end;

  if Length(row) > 0 then
  begin
    fieldDef := VarToStr(row[0]);
    var parts := A.Explode(fieldDef + ';;', ';');
    var fullName := VarToStr(parts[0]);
    var saveName := VarToStr(parts[1]);
    var loadName := VarToStr(parts[2]);

    var cleanName := S.GetDBFieldNameFromSt(fullName);
    SetFieldValue(ARowIndex, Integer(fvtVName), cleanName);
    SetFieldValue(ARowIndex, Integer(fvtFName), S.IIfStr(Pos('_', fullName) <> 1, S.GetDBFieldNameFromSt(fullName, True)));
    SetFieldValue(ARowIndex, Integer(fvtFNameL), S.IIfStr(Pos('_', fullName) <> 1, S.GetDBFieldNameFromSt(fullName)));
    if (saveName = '') or (Pos('_', saveName) = 1) or (Pos('0', saveName) = 1) then
      saveName := cleanName;
    SetFieldValue(ARowIndex, Integer(fvtFNameS), saveName);
    if (loadName = '') or (Pos('_', loadName) = 1) or (Pos('0', loadName) = 1) then
      loadName := cleanName;
    SetFieldValue(ARowIndex, Integer(fvtFNameL), loadName);

    ctrlName := cleanName;
    c := Cth.FindControlByFieldName(FSelf, ctrlName);
    if c = nil then
      c := TControl(FSelf.FindComponent(ctrlName));
    if c <> nil then
      SetFieldValue(ARowIndex, Integer(fvtCtrl), c.Name);
  end;

  isUserMode := False;
  userIndex := 0;
  for i := 1 to High(row) do
  begin
    v := row[i];
    if (S.VarType(v) = varString) and (VarToStr(v) = #0) then
    begin
      isUserMode := True;
      userIndex := 0;
      Continue;
    end;

    if isUserMode then
    begin
      SetFieldValue(ARowIndex, Integer(fvtCustom) + userIndex, v);
      if userIndex = 0 then
      begin
        SetFieldValue(ARowIndex, Integer(fvtVBeg), v);
        SetFieldValue(ARowIndex, Integer(fvtVCurr), v);
      end;
      Inc(userIndex);
      Continue;
    end;

    if S.VarType(v) = varString then
    begin
      tagStr := UpperCase(VarToStr(v));
      if Pos(fvpVer, tagStr) = 1 then
        SetFieldValue(ARowIndex, Integer(fvtVer), Copy(tagStr, 3))
      else if Pos(fvpName, tagStr) = 1 then
        SetFieldValue(ARowIndex, Integer(fvtCtrlCaption), Copy(tagStr, 3))
      else if Pos(fvpPanel, tagStr) = 1 then
        SetFieldValue(ARowIndex, Integer(fvtCtrlPanel), Copy(tagStr, 3))
      else if Pos(fvpFlags, tagStr) = 1 then
        SetFieldValue(ARowIndex, Integer(fvtFlags), Copy(tagStr, 3))
      else if Pos(fvpSizes, tagStr) = 1 then
        SetFieldValue(ARowIndex, Integer(fvtCtrlSizes), Copy(tagStr, 3))
      else if Pos(fvpTags, tagStr) = 1 then
        SetFieldValue(ARowIndex, Integer(fvtTags), Copy(tagStr, 3))
      else
      begin
        SetFieldValue(ARowIndex, Integer(fvtVBeg), v);
        SetFieldValue(ARowIndex, Integer(fvtVCurr), v);
      end;
    end
    else if S.VarType(v) = varInteger then
      SetFieldValue(ARowIndex, Integer(fvtCtrlType), v)
    else if S.VarType(v) = varBoolean then
      SetFieldValue(ARowIndex, Integer(fvtDsbl), not v)
    else
    begin
      SetFieldValue(ARowIndex, Integer(fvtVBeg), v);
      SetFieldValue(ARowIndex, Integer(fvtVCurr), v);
    end;
  end;
end;

function TFields.FindPropertyIndex(const APropName: string; out AIndex: Integer; const AErrorIfNotFound: Boolean = True): Boolean;
//поиск первого индекса свойства по имени или тегу (возвращает true если найден)
var
  i: Integer;
  tags: string;
  tagList: TArray<string>;
  tag: string;
begin
  Result := False;
  AIndex := -1;

  for i := 0 to High(FDefineFieldsAdd) do
    if SameText(VarToStr(FDefineFieldsAdd[i][Integer(fvtVName)]), APropName) then
    begin
      AIndex := i;
      Result := True;
      Exit;
    end;

  for i := 0 to High(FDefineFieldsAdd) do
  begin
    tags := VarToStr(FDefineFieldsAdd[i][Integer(fvtTags)]);
    if tags <> '' then
    begin
      tagList := A.ExplodeS(tags, ',', True);
      for tag in tagList do
        if SameText(tag, APropName) then
        begin
          AIndex := i;
          Result := True;
          Exit;
        end;
    end;
  end;

  if AErrorIfNotFound and not Result then
    Errors.RaiseErr('FindProp', 'Не найден параметр ' + APropName);
end;

function TFields.FindAllProps(const APropName: string): TVarDynArray;
//поиск всех индексов свойств, у которых имя или тег совпадает с APropName
var
  i: Integer;
  tags: string;
  tagList: TArray<string>;
  tag: string;
  cleanName: string;
begin
  SetLength(Result, 0);
  cleanName := S.GetDBFieldNameFromSt(APropName);
  if cleanName = '' then
    cleanName := '*EMPTY*';

  // поиск по имени (очищенному)
  for i := 0 to High(FDefineFieldsAdd) do
    if SameText(VarToStr(FDefineFieldsAdd[i][Integer(fvtVName)]), cleanName) then
    begin
      SetLength(Result, Length(Result) + 1);
      Result[High(Result)] := i;
    end;

  // поиск по тегам (добавляем только те, что ещё не добавлены)
  for i := 0 to High(FDefineFieldsAdd) do
  begin
    tags := VarToStr(FDefineFieldsAdd[i][Integer(fvtTags)]);
    if tags <> '' then
    begin
      tagList := A.ExplodeS(tags, ',', True);
      for tag in tagList do
        if SameText(tag, APropName) then
        begin
          if A.PosInArray(i, Result) < 0 then
          begin
            SetLength(Result, Length(Result) + 1);
            Result[High(Result)] := i;
          end;
          Break;
        end;
    end;
  end;
end;

function TFields.GetAllPropIndices: TVarDynArray;
//возвращает массив индексов всех свойств
var
  i: Integer;
begin
  SetLength(Result, Count);
  for i := 0 to Count - 1 do
    Result[i] := i;
end;

function TFields.CollectIndices(const PropNames: string): TVarDynArray;
//собирает индексы свойств по строке имён/тегов (через ;). Пустая строка → все индексы.
//Если строка начинается с '-', то исключает перечисленные свойства (все остальные включаются).
var
  s: string;
  isExclude: Boolean;
  names: TVarDynArray;
  excludeIndices: TVarDynArray;
  i, j: Integer;
begin
  s := Trim(PropNames);
  // если строка пустая, возвращаем все индексы
  if s = '' then
  begin
    Result := GetAllPropIndices;
    Exit;
  end;

  isExclude := (s[1] = '-');
  if isExclude then
    s := Trim(Copy(s, 2));

  if s = '' then
  begin
    // если после '-' ничего нет, возвращаем все индексы (или все? обычно это означает все)
    Result := GetAllPropIndices;
    Exit;
  end;

  // разбиваем на имена/теги
  names := A.Explode(s, ';', True);
  if not isExclude then
  begin
    // обычный режим: собираем все совпадения
    Result := [];
    for i := 0 to High(names) do
    begin
      var indices := FindAllProps(VarToStr(names[i]));
      for j := 0 to High(indices) do
        if A.PosInArray(indices[j], Result) < 0 then
        begin
          SetLength(Result, Length(Result) + 1);
          Result[High(Result)] := indices[j];
        end;
    end;
  end
  else
  begin
    // режим исключения: начинаем со всех индексов, затем удаляем те, что соответствуют names
    Result := GetAllPropIndices;
    for i := 0 to High(names) do
    begin
      excludeIndices := FindAllProps(VarToStr(names[i]));
      for j := 0 to High(excludeIndices) do
      begin
        var idx := A.PosInArray(excludeIndices[j], Result);
        if idx >= 0 then
        begin
          // удаляем элемент по индексу idx
          var k: Integer;
          for k := idx to Length(Result) - 2 do
            Result[k] := Result[k + 1];
          SetLength(Result, Length(Result) - 1);
        end;
      end;
    end;
  end;
end;

procedure TFields.PrepareDefineFieldsAdd;
//подготовка расширенного массива на основе DefineFields
var
  i: Integer;
begin
  FIsFieldsPrepared := True;
  SetLength(FDefineFieldsAdd, Length(FDefineFields));
  for i := 0 to High(FDefineFields) do
    PrepareProperty(i);
end;

function TFields.FindProp(PropName: string; PropValueType: TDefFiledcValueType = fvtVName; ErrorInNotFouund: Boolean = True): Integer;
//поиск индекса свойства (обёртка над FindPropertyIndex)
begin
  PropName := S.GetDBFieldNameFromSt(PropName);
  if PropName = '' then
    PropName := '*EMPTY*';

  if not FindPropertyIndex(PropName, Result, ErrorInNotFouund) then
    Result := -1;
end;

function TFields.GetProp(PropName: string; PropValueType: TDefFiledcValueType = fvtVCurr): Variant;
//получение значения свойства (если есть контрол и запрошено текущее значение – берёт из контрола)
var
  idx: Integer;
  c: TComponent;
begin
  idx := FindProp(PropName);
  Result := GetFieldValue(idx, Integer(PropValueType));
  if (PropValueType = fvtVCurr) and not FInPrepare then
  begin
    c := FSelf.FindComponent(GetFieldValue(idx, Integer(fvtCtrl)));
    if c <> nil then
      Result := Cth.GetControlValue(TControl(c));
  end;
  if PropValueType = fvtVer then
  begin
    c := FSelf.FindComponent(GetFieldValue(idx, Integer(fvtCtrl)));
    if c <> nil then
      Result := Cth.GetDynProp(TControl(c), dpVerify);
  end;
  if PropValueType = fvtErr then
  begin
    c := FSelf.FindComponent(GetFieldValue(idx, Integer(fvtCtrl)));
    if c <> nil then
    begin
      if c is TCustomDbEditEh then
        Result := TCustomDbEditEh(c).DynProps.VarExists(dpError)
      else if c is TDbCheckboxEh then
        Result := TDbCheckboxEh(c).DynProps.VarExists(dpError);
    end;
  end;
  if PropValueType = fvtErrMsg then
  begin
    c := FSelf.FindComponent(GetFieldValue(idx, Integer(fvtCtrl)));
    if c <> nil then
      Result := Cth.GetDynProp(TControl(c), dpErrorMsg);
  end;
  if PropValueType = fvtIsChanged then
  begin
    c := FSelf.FindComponent(GetFieldValue(idx, Integer(fvtCtrl)));
    if c <> nil then
      Result := Cth.GetDynProp(TControl(c), dpIsChanged);
  end;
end;

function TFields.GetProp(PropPos: Integer; PropValueType: TDefFiledcValueType = fvtVCurr): Variant;
//получение значения свойства по его позиции
begin
  Result := GetProp(GetName(PropPos), PropValueType);
end;

function TFields.GetProp(PropName: string; PropValuePos: Integer): Variant;
//получение пользовательского значения по индексу (после #0)
var
  idx: Integer;
begin
  idx := FindProp(PropName);
  Result := GetFieldValue(idx, Integer(fvtCustom) + PropValuePos);
end;

function TFields.GetPropB(PropName: string): Variant;
//получение начального значения свойства
begin
  Result := GetProp(PropName, fvtVBeg);
end;

function TFields.GetPropValues(PropNames: string; PropValueType: TDefFiledcValueType = fvtVCurr): TVarDynArray;
//получение значений свойства для нескольких полей (поддерживаются теги – возвращает все совпадения)
var
  indices: TVarDynArray;
  i: Integer;
begin
  indices := CollectIndices(PropNames);
  SetLength(Result, Length(indices));
  for i := 0 to High(indices) do
    Result[i] := GetProp(Integer(indices[i]), PropValueType);
end;

procedure TFields.SetProp(PropName: string; Value: Variant; PropValueType: TDefFiledcValueType = fvtVCurr);
//установка значения свойства по имени (с обновлением контрола)
var
  idx: Integer;
begin
  idx := FindProp(PropName);
  SetProp(idx, Value, PropValueType);
end;

procedure TFields.SetProp(AIndex: Integer; Value: Variant; PropValueType: TDefFiledcValueType = fvtVCurr);
//установка значения свойства по индексу (без поиска по имени)
var
  c: TComponent;
  b: Boolean;
begin
  try
    SetFieldValue(AIndex, Integer(PropValueType), Value);
    c := FSelf.FindComponent(GetFieldValue(AIndex, Integer(fvtCtrl)));
    if c <> nil then
    begin
      if (PropValueType = fvtVBeg) and not FInPrepare then
        Cth.SetControlValue(TControl(c), Value);
      if PropValueType = fvtVCurr then
        Cth.SetControlValue(TControl(c), Value);
      if PropValueType = fvtVer then
        Cth.SetControlVerification(TControl(c), Value);
      if PropValueType = fvtErrMsg then
        Cth.SetDynProps(TControl(c), [[dpErrorMsg, Value]]);
      if PropValueType = fvtErr then
        Cth.SetErrorMarker(TControl(c), Value);
      if PropValueType = fvtDsbl then
      begin
        b := (S.VarType(Value) = varBoolean) and (Value = True) or
             (S.VarType(Value) = varString) and (Value = '') or
             (S.VarType(Value) = varInteger) and (Value = 1);
        Cth.SetControlNotEditable(TControl(c), not b, False, True);
        if c is TCustomDBEditEh then
          Cth.SetEhControlEditButtonState(TControl(c), b, b);
      end;
    end;
  except
    on E: Exception do
    begin
      Errors.SetParam('TFields.SetProp', 'Ошибка при установке свойства по индексу ' + IntToStr(AIndex) + ' в "' + VarToStr(Value) + '"');
      Application.ShowException(E);
      Errors.SetParam;
    end;
  end;
end;

procedure TFields.SetProp(PropName: string; Value: Variant; PropValuePos: Integer);
//установка пользовательского значения по индексу (после #0)
var
  idx: Integer;
begin
  idx := FindProp(PropName);
  SetFieldValue(idx, Integer(fvtCustom) + PropValuePos, Value);
end;

procedure TFields.SetPropP(PropPos: Integer; Value: Variant; PropValueType: TDefFiledcValueType = fvtVCurr);
//установка значения свойства по его позиции
begin
  SetProp(GetName(PropPos), Value, PropValueType);
end;

procedure TFields.SetProps(PropNames: string; ValuesAndTypes: TVarDynArray2);
//установка нескольких свойств из массива пар [значение, тип] для всех свойств, соответствующих именам/тегам
var
  indices: TVarDynArray;
  i, k: Integer;
begin
  indices := CollectIndices(PropNames);
  for i := 0 to High(indices) do
    for k := 0 to High(ValuesAndTypes) do
      SetProp(Integer(indices[i]), ValuesAndTypes[k][0], TDefFiledcValueType(ValuesAndTypes[k][1]));
end;

procedure TFields.SetProps(PropNames: string; Value: Variant; PropValueType: TDefFiledcValueType = fvtVCurr);
//установка одного значения для всех свойств, соответствующих именам/тегам
var
  indices: TVarDynArray;
  i: Integer;
begin
  indices := CollectIndices(PropNames);
  for i := 0 to High(indices) do
    SetProp(Integer(indices[i]), Value, PropValueType);
end;

procedure TFields.SetPropsFromCustom(PropNames: string; SourceType: TDefFiledcValueType;
  TargetType: TDefFiledcValueType; const CustomIndex: Integer = 0;
  const IgnoreMissing: Boolean = True);
//установка свойств из пользовательских индексов или начального значения
var
  indices: TVarDynArray;
  i: Integer;
  idx: Integer;
  val: Variant;
begin
  indices := CollectIndices(PropNames);
  for i := 0 to High(indices) do
  begin
    idx := Integer(indices[i]);
    if SourceType = fvtCustom then
      val := GetFieldValue(idx, Integer(fvtCustom) + CustomIndex)
    else
      val := GetFieldValue(idx, Integer(SourceType));

    //если значение не определено (Null) и игнорирование разрешено - пропускаем
    if VarIsNull(val) then
    begin
      if IgnoreMissing then
        Continue
      else
        Errors.RaiseErr('SetPropsFromCustom: поле "' + GetName(idx) + '" не имеет значения источника (индекс ' + IntToStr(CustomIndex) +')');
    end;

    SetProp(idx, val, TargetType);
  end;
end;

procedure TFields.SetPropsFromCustom(PropNames: string; CustomIndex: Integer;
  TargetType: TDefFiledcValueType; const IgnoreMissing: Boolean = True);
//перегрузка: устанавливаем из пользовательского индекса
begin
  SetPropsFromCustom(PropNames, fvtCustom, TargetType, CustomIndex, IgnoreMissing);
end;

function TFields.SetPropsFromSelect(Values: TVarDynArray2; PropValueType: TDefFiledcValueType = fvtVBeg): Boolean;
//загрузка данных из результата SELECT (по именам полей)
var
  i, idx: Integer;
begin
  Result := False;
  if Length(Values) = 0 then
    Exit;
  for i := 0 to High(Values[0]) do
  begin
    idx := FindProp(Q.LastReceivedFiedNames[i], fvtVName, False);
    if idx >= 0 then
    begin
      SetProp(VarToStr(Q.LastReceivedFiedNames[i]), Values[0][i], PropValueType);
      if (PropValueType = fvtVBeg) and (GetFieldValue(idx, Integer(fvtCtrl)) = '') then
        SetProp(VarToStr(Q.LastReceivedFiedNames[i]), Values[0][i], fvtVCurr);
    end;
  end;
  Result := True;
end;

function TFields.SetPropsControls(PropNames: string = ''; PropValueTypes: TDefFiledcValueTypeSet = [fvtVBeg, fvtDsbl, fvtVer]): Integer;
//установка свойств контролов из подготовленного массива
var
  i: Integer;
  names: TVarDynArray;
  PropValueType: TDefFiledcValueType;
  c: TComponent;
begin
  FIsPropControlsSet := True;
  Result := 0;
  names := A.Explode(PropNames, ';', True);

  for i := 0 to High(FDefineFieldsAdd) do
  begin
    if (Length(PropNames) > 0) and not A.InArray(FDefineFieldsAdd[i][Integer(fvtVName)], names) then
      Continue;

    if fvtVBeg in PropValueTypes then
      SetProp(i, FDefineFieldsAdd[i][Integer(fvtVBeg)], fvtVCurr);

    if VarIsNull(FDefineFieldsAdd[i][Integer(fvtCtrl)]) then
      Continue;

    c := FSelf.FindComponent(FDefineFieldsAdd[i][Integer(fvtCtrl)]);
    if c = nil then
      Continue;

    for PropValueType in PropValueTypes do
    begin
      if PropValueType = fvtVBeg then
        Cth.SetControlValue(TControl(c), FDefineFieldsAdd[i][Integer(fvtVBeg)])
      else
        SetProp(i, FDefineFieldsAdd[i][Integer(PropValueType)], PropValueType);
    end;
    Inc(Result);
  end;
end;

function TFields.PropNameFromControl(C: TObject): string;
//извлечение имени свойства из имени контрола (после последнего подчёркивания)
var
  i: Integer;
begin
  Result := '';
  if C = nil then
    Exit;
  i := Pos('_', TControl(C).Name);
  if i = 0 then
    Exit;
  Result := LowerCase(Copy(TControl(C).Name, i + 1));
end;

function TFields.Count: Integer;
//количество свойств
begin
  Result := Length(FDefineFieldsAdd);
end;

function TFields.GetName(i: Integer): string;
//внутреннее имя свойства по индексу
begin
  if (i >= 0) and (i < Length(FDefineFieldsAdd)) then
    Result := VarToStr(FDefineFieldsAdd[i][Integer(fvtVName)])
  else
    Result := '';
end;

end.
