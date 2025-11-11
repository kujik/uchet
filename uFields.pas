unit uFields;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, Vcl.ExtCtrls, Vcl.ComCtrls,
  uData, uForms, uDBOra, uString, uMessages
  ;



type TDefFiledcValueType = (
  fvtVName = 0,
  fvtFName = 1,
  fvtFNameL = 2,
  fvtFNameS = 3,
  fvtCType = 4,
  fvtCtrl = 5,
  fvtVBeg = 6,
  fvtVCurr = 7,
  fvtVer = 8,
  fvtClr = 9,
  fvtDsbl = 10,
  fvtIsChanged = 11,
  fvtErrMsg = 12,
  fvtErr = 13,

  fvtCtrlType = 14,
  fvtCtrlCaption = 15,
  fvtCtrlPanel = 16,
  fvtCtrlSizes = 17,
  fvtFlags = 18,
  fvtTags = 19,

  fvtCustom = 20
);

type TDefFiledcValueTypeSet = set of TDefFiledcValueType;

const
  fvpVer = 'V=';         //верификация
  fvpName = 'N=';        //заголовок контрола
  fvpPanel = 'P=';       //панель, в которую вставляется контрол
  fvpFlags = 'F=';       //флаги
  fvpSizes = 'S=';       //определение размеров и положения при создании контрола
  fvpTags = 'T=';        //теги, через запятую

type TDefFiledcValue = (
  _D = -MaxInt + 1,
  fvvClearRep = -MaxInt + 2,
  fvvDsbl = -MaxInt + 3
);

type
  TFields = class
  private
    FDefineFields: TVarDynArray2;
    FDefineFieldsAdd: TVarDynArray2;
    FSelf: TForm;
    FInPrepare: Boolean;
    FIsFieldsPrepared: Boolean;
    FIsPropControlsSet: Boolean;
  protected
  public
    property DefineFields: TVarDynArray2 read FDefineFields write FDefineFields;
    property IsFieldsPrepared: Boolean read FIsFieldsPrepared;
    property IsPropControlsSet: Boolean read FIsPropcontrolsSet;
    constructor Create(ASelf: TForm); Overload;
    procedure PrepareDefineFieldsAdd;
    function  FindProp(PropName: string; PropValueType: TDefFiledcValueType = fvtVName; ErrorInNotFouund: Boolean = True): Integer;
    function  GetProp(PropName: string; PropValueType: TDefFiledcValueType = fvtVCurr): Variant; overload;
    function  GetProp(PropPos: Integer; PropValueType: TDefFiledcValueType = fvtVCurr): Variant; overload;
    function  GetProp(PropName: string; PropValuePos: Integer): Variant; overload;
    function  GetPropB(PropName: string): Variant;
    procedure SetProp(PropName: string; Value: Variant; PropValueType: TDefFiledcValueType = fvtVCurr); overload;
    procedure SetProp(PropName: string; Value: Variant; PropValuePos: Integer); overload;
    procedure SetPropP(PropPos: Integer; Value: Variant; PropValueType: TDefFiledcValueType = fvtVCurr); overload;
    procedure SetProps(PropNames: string; ValuesAndTypes: TVarDynArray2);
    function  SetPropsFromSelect(Values: TVarDynArray2; PropValueType: TDefFiledcValueType = fvtVBeg): Boolean;
    function  SetPropsControls(PropNames: string = ''; PropValueTypes: TDefFiledcValueTypeSet = [fvtVBeg, fvtDsbl, fvtVer]): Integer;
    function  PropNameFromControl(C: TObject): string;
    function  Count: Integer;
    function  GetName(i: Integer): string;
  end;

implementation

uses
  uErrors
  ;


constructor TFields.Create(ASelf: TForm);
begin
  inherited Create();
  FSelf := ASelf;
end;



procedure TFields.PrepareDefineFieldsAdd;
var
  c: TControl;
  va: TVarDynArray;
  va2: TVarDynArray2;
  i, j, k, h, h1, r: Integer;
  st: string;
  b: Boolean;
  v: Variant;
procedure SetF(t: TDefFiledcValueType; v: Variant);
begin
  FDefineFieldsAdd[i][Integer(t)] := v;
end;
procedure GetF;
begin
end;
begin
  SetLength(FDefineFieldsAdd, Length(DefineFields));
  b := False;
  FIsFieldsPrepared := True;
  for i := 0 to High(DefineFields) do begin
    k := 0;
    SetLength(FDefineFieldsAdd[i], Integer(fvtCustom) + 10);
    for j := 0 to High(FDefineFieldsAdd[i]) do begin
      if j = Integer(fvtCtrlType)
        then FDefineFieldsAdd[i][j] := cntUndefined
        else if (j = Integer(fvtVBeg))or(j = Integer(fvtVCurr))or(j >= Integer(fvtCustom))
          then FDefineFieldsAdd[i][j] := null
          else FDefineFieldsAdd[i][j] := '';
    end;
    for j := 0 to High(DefineFields[i]) do begin
      v := DefineFields[i][j];
      if j = 0 then begin
        //поле видя "{_}fieldname{;nameforsave|;0}{;nameforlod|;0}"
        va := a.Explode(v + ';;', ';');
        SetF(fvtVName, S.GetDBFieldNameFromSt(va[0]));
        SetF(fvtFName, S.IIFStr(Pos('_', va[0]) <> 1, S.GetDBFieldNameFromSt(va[0], True)));
        SetF(fvtFNameL, S.IIFStr(Pos('_', va[0]) <> 1, S.GetDBFieldNameFromSt(va[0])));
        SetF(fvtFNameS, S.IIFStr((Pos('_', va[1]) <> 1)and(Pos('0', va[1]) <> 1), S.IIFStr(va[1] = '', va[0], va[1])));
        SetF(fvtFNameL, S.IIFStr((Pos('_', va[2]) <> 1)and(Pos('0', va[2]) <> 1), S.IIFStr(va[2] = '', va[0], va[2])));
        st := FDefineFieldsAdd[i][Integer(fvtVName)];
        if Pos('_', st) = 1 then
          St := Copy(st, 2);
        c := Cth.FindControlByFieldName(FSelf, st);
        if c = nil then
          c := TControl(FSelf.FindComponent(st));
        if c <> nil then
          FDefineFieldsAdd[i][Integer(fvtCtrl)] := c.Name;
        Continue;
      end;
      if (S.VarType(DefineFields[i][j]) = varString) and (DefineFields[i][j] = #0) then begin
        k := Integer(fvtCustom);
        Continue;
      end;
      if (j = 1) and (S.VarType(v) = varInteger) then
        SetF(fvtCtrlType, v);
      if (j in [1,2]) and (S.VarType(v) = varBoolean) then  //!!!
        SetF(fvtDsbl, not v);
      if k = 0 then begin
        if S.VarType(v) = varString then begin
          if Pos(fvpVer, UpperCase(v)) = 1 then
            SetF(fvtVer, Copy(v, 3));
          if Pos(fvpName, UpperCase(v)) = 1 then
            SetF(fvtCtrlCaption, Copy(v, 3));
          if Pos(fvpPanel, UpperCase(v)) = 1 then
            SetF(fvtCtrlPanel, Copy(v, 3));
          if Pos(fvpFlags, UpperCase(v)) = 1 then
            SetF(fvtFlags, Copy(v, 3));
          if Pos(fvpSizes, UpperCase(v)) = 1 then
            SetF(fvtCtrlSizes, Copy(v, 3));
          if Pos(fvpTags, UpperCase(v)) = 1 then
            SetF(fvtTags, Copy(v, 3));
        end;
      end
      else begin
        if k = Integer(fvtCustom) then begin
          //начальное значение
          //текущее присвоим ему же
          SetF(fvtVBeg, v);
          SetF(fvtVCurr, v);
        end;
   //     else
   //       FDefineFieldsAdd[i][k] := v;
        inc(k);
      end;
    end;
    {
    Ctrls[i] := Cth.FindControlByFieldName(FSelf, FDefineFieldsAdd[i][Integer(fvtVName)]);
    if Ctrls[i] <> nil then
      FDefineFieldsAdd[i][Integer(fvtCtrl)] := Ctrls[i].Name;}
  end;
end;

function TFields.FindProp(PropName: string; PropValueType: TDefFiledcValueType = fvtVName; ErrorInNotFouund: Boolean = True): Integer;
begin
  PropName := S.GetDBFieldNameFromSt(PropName);
  if PropName = '' then
    PropName := '*EMPTY*';
  Result := A.PosInArray(PropName, FDefineFieldsAdd, Integer(fvtVName), True);
  if (Result < 0) and ErrorInNotFouund then
    Errors.RaiseErr('FindProp', 'Не найден параметр ' + PropName);
end;


function TFields.GetProp(PropName: string; PropValueType: TDefFiledcValueType = fvtVCurr): Variant;
//получимм данные из массива, а если есть - из контрола
var
  c: TComponent;
  b: Boolean;
begin
  Result := FDefineFieldsAdd[FindProp(PropName)][Integer(PropValueType)];
  c := FSelf.FindComponent(FDefineFieldsAdd[FindProp(PropName)][Integer(fvtCtrl)]);
  if c <> nil then begin
    if (PropValueType = fvtVCurr) and not FInPrepare then
      Result := Cth.GetControlValue(TControl(c));
    if (PropValueType = fvtVer) then
      Result := Cth.GetDynProp(TControl(c), dpVerify);
    if (PropValueType = fvtErr) then begin
      if c is TCustomDbEditEh then
        TCustomDbEditEh(c).DynProps.VarExists(dpError);
      if c is TDbCheckboxEh then
        TDbCheckboxEh(c).DynProps.VarExists(dpError);
    end;
    if (PropValueType = fvtErrMsg) then
      Result := Cth.GetDynProp(TControl(c), dpErrorMsg);
    if (PropValueType = fvtIsChanged) then
      Result := Cth.GetDynProp(TControl(c), dpIsChanged);
  end;
end;

function TFields.GetProp(PropPos: Integer; PropValueType: TDefFiledcValueType = fvtVCurr): Variant;
begin
  Result := GetProp(GetName(PropPos), PropValueType);
end;

function TFields.GetProp(PropName: string; PropValuePos: Integer): Variant;
begin
  Result := FDefineFieldsAdd[FindProp(PropName)][Integer(fvtCustom) + PropValuePos];
end;

function TFields.GetPropB(PropName: string): Variant;
begin
  Result := GetProp(PropName, fvtVBeg);
end;


procedure TFields.SetProp(PropName: string; Value: Variant; PropValueType: TDefFiledcValueType = fvtVCurr);
var
  c: TComponent;
  b: Boolean;
begin
  try
  FDefineFieldsAdd[FindProp(PropName)][Integer(PropValueType)] := Value;
  c := FSelf.FindComponent(FDefineFieldsAdd[FindProp(PropName)][Integer(fvtCtrl)]);
  if c <> nil then begin
  // c.Name = 'cmb_id_or_format_estimates' then
  //b := True;

    if (PropValueType = fvtVBeg) and not FInPrepare then
      Cth.SetControlValue(TControl(c), Value);
    if (PropValueType = fvtVCurr) then
      Cth.SetControlValue(TControl(c), Value);
    if (PropValueType = fvtVer) then
      Cth.SetControlVerification(TControl(c), Value);
    if (PropValueType = fvtErrMsg) then
      Cth.SetDynProps(TControl(c), [[dpErrorMsg, Value]]);
    if (PropValueType = fvtErr) then
      Cth.SetErrorMarker(TControl(c), Value);
    if PropValueType = fvtDsbl then begin
      //статус доступности (True - Enabled!)
      b := (S.VarType(Value) = varBoolean) and (Value = True) or (S.VarType(Value) = varString) and (Value = '') or (S.VarType(Value) = varInteger) and (Value = 1);
//if b = true then
//  b:=true;
      Cth.SetControlNotEditable(TControl(c), not b, False, True);
      if c is TCustomDBEditEh then
        Cth.SetEhControlEditButtonState(TControl(c), b, b);
    end;
  end
  else if True then begin
//    Verify()
  end;
  except on E: Exception do begin
    Errors.SetParam('TFields.SetProp', 'Ошибка при установке свойства "' + PropName + '" в "' + VarToStr(Value) + '"');
    Application.ShowException(E);
    Errors.SetParam;
  end;
  end;
end;

procedure TFields.SetPropP(PropPos: Integer; Value: Variant; PropValueType: TDefFiledcValueType = fvtVCurr);
begin
  SetProp(string(FDefineFieldsAdd[PropPos][Integer(fvtVName)]), Value, PropValueType);
end;


procedure TFields.SetProp(PropName: string; Value: Variant; PropValuePos: Integer);
begin
  FDefineFieldsAdd[FindProp(PropName)][Integer(fvtCustom) + PropValuePos] := Value;
end;

procedure TFields.SetProps(PropNames: string; ValuesAndTypes: TVarDynArray2);
var
  i, j: Integer;
  va: TVarDynArray;
  cmp: TComponent;
  c: TControl;
  v: Variant;
  b: Boolean;
  PropValueType: TDefFiledcValueType;
begin
  va := A.Explode(PropNames, ';', True);
  for i := 0 to High(va) do
    for j := 0 to High(ValuesAndTypes) do
      SetProp(va[i], ValuesAndTypes[j][0], TDefFiledcValueType(ValuesAndTypes[j][1]));
end;


function TFields.SetPropsFromSelect(Values: TVarDynArray2; PropValueType: TDefFiledcValueType = fvtVBeg): Boolean;
//загружается данные из TVarDynArray2, полученных запросом типа селект, на основании наименований полей
//(наименования соотвтетствуют последнему select-запросу)
//fvtVBeg загружается только в массив начальных значений (так как могут быть зависимости контролов), а иначе загружаеются прямо в контрол
//если установлена загрузха fvtVBeg, то устанавливается м fvtVCurr для сыойств без контролов
var
  i, j: Integer;
begin
  if Length(Values) = 0 then Exit;
  for i := 0 to High(Values[0]) do begin
    j := FindProp(Q.LastReceivedFiedNames[i], fvtVName, False);
    if j >= 0 then begin
      SetProp(Q.LastReceivedFiedNames[i], Values[0][i], PropValueType);
      if (PropValueType = fvtVBeg) and (GetProp(VarToStr(Q.LastReceivedFiedNames[i]), fvtCtrl) = '') then
        SetProp(Q.LastReceivedFiedNames[i], Values[0][i], fvtVCurr);
{      if PropValueType = fvtVBeg
        then FDefineFieldsAdd[j][Integer(PropValueType)] := Values[0][i]
        else SetProp(Q.LastReceivedFiedNames[i], Values[0][i], PropValueType);}
    end;
  end;
end;

function TFields.SetPropsControls(PropNames: string = '';  PropValueTypes: TDefFiledcValueTypeSet = [fvtVBeg, fvtDsbl, fvtVer]): Integer;
//установим параметры компонентов с первоначально заданного массива
//также, если устанавливается fvtVBeg, то установим для всех свойств fvtVCurr := fvtVBeg, и установим Control.Value := VBeg
var
  i, j: Integer;
  va: TVarDynArray;
  cmp: TComponent;
  c: TControl;
  v: Variant;
  b: Boolean;
  PropValueType: TDefFiledcValueType;
begin
  FIsPropControlsSet := True;
  va := A.Explode(PropNames, ';');
  for i := 0 to High(FDefineFieldsAdd) do begin
    if fvtVBeg in PropValueTypes then
      SetProp(FDefineFieldsAdd[i][Integer(fvtVName)], FDefineFieldsAdd[i][Integer(fvtVBeg)], fvtVCurr);     //!!!
    if FDefineFieldsAdd[i][Integer(fvtCtrl)] = null then begin
      Continue;
    end;
    if (Length(PropNames) > 0) and not A.InArray(FDefineFieldsAdd[i][Integer(fvtVName)], va) then
      Continue;
//    c :=Cth.FindControlByFieldName(FSelf, FDefineFieldsAdd[i][Integer(fvtVName)]);
    cmp := FSelf.FindComponent(FDefineFieldsAdd[i][Integer(fvtCtrl)]);
    if cmp = nil then
      Continue;
    for PropValueType in PropValueTypes do begin
     if (PropValueType = fvtVBeg)
        then  Cth.SetControlValue(TControl(cmp), FDefineFieldsAdd[i][Integer(PropValueType)])
        else SetProp(FDefineFieldsAdd[i][Integer(fvtVName)], FDefineFieldsAdd[i][Integer(PropValueType)], PropValueType);
    end;
  end;
end;

function TFields.PropNameFromControl(C: TObject): string;
var
  i: Integer;
begin
  Result := '';
  if c = nil then
    Exit;
  i := Pos('_', TControl(C).Name);
  if i = 0 then
    Exit;
  Result := LowerCase(Copy(TControl(C).Name, i + 1));
end;

function TFields.Count: Integer;
begin
  Result := Length(FDefineFieldsAdd);
end;

function TFields.GetName(i: Integer): string;
begin
  Result := FDefineFieldsAdd[i][Integer(fvtVName)];
end;




var
f: TFields;
va2: TVarDynArray2;
begin
{  f:=TFields.Create(;
  f.DefineFields:=[
    ['id$i', cntNEdit, '', 'V=1:100', #0, 200]
  ];
  f.PrepareFDefineFieldsAdd;
  va2:=f.FDefineFieldsAdd; }
 // halt;
end.


      if j = 0 then Continue;
      if S.CompareStI(Copy(TControl(AFSelf.Components[i]).Name, j + 1), FieldName) then begin
        Result := TControl(AFSelf.Components[i]);
        Exit;
      end;}
'$name$s', cntEdit, 'N=Реквизиты','V=0:100:0:N', 'P=Frg1.1', 'D=100,20,T', 'F=DILSEHC', BegValues, AddValues

    procedure CreateAddControls(Parent: TWinControl; CType: TMyControlType; CLabel: string = ''; CName: string = ''; CVerify: string = ''; x: Integer = 1; y: Integer = yrefC; Width: Integer = 0; Tag: Integer = 0);
