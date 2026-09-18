{*******************************************************}
{                                                       }
{                      EhLib 12.1                       }
{                EhLib.MathAggregators                  }
{                                                       }
{     Copyright (c) 2024-2025 by Dmitry V. Bolshakov    }
{                                                       }
{*******************************************************}

unit EhLib.MathAggregators;

{$I ..\Incl\EhLib.Inc}
{$SCOPEDENUMS ON}

interface

uses
  SysUtils, Classes, TypInfo, Generics.Collections,
  Variants, FmtBcd, Rtti,
  DBUtilsEh, EhLibUtils;

type

{ TMathBaseAggregatorEh }

  TMathBaseAggregatorEh = class(TComponent)
  private
  protected

  public
    class procedure CalcInitData(var InitData: TValue; StepsCount: Integer); virtual;
    class procedure CalcStepData(const StepValue: TValue; var AggrData: TValue); virtual;
    class function CalcFinalData(const AggrData: TValue): TValue; virtual;
  end;

  TMathBaseAggregatorEhClass = class of TMathBaseAggregatorEh;

{ TMathSumAggregatorEh }

  TMathSumAggregatorEh = class(TMathBaseAggregatorEh)
  private
  protected
  public
    class procedure CalcInitData(var InitData: TValue; StepsCount: Integer); override;
    class procedure CalcStepData(const StepValue: TValue; var AggrData: TValue); override;
    class function CalcFinalData(const AggrData: TValue): TValue; override;
  end;

{ TMathAverageAggregatorEh }

  TMathAverageAggregatorEh = class(TMathBaseAggregatorEh)
  private
  protected
  public
    class procedure CalcInitData(var InitData: TValue; StepsCount: Integer); override;
    class procedure CalcStepData(const StepValue: TValue; var AggrData: TValue); override;
    class function CalcFinalData(const AggrData: TValue): TValue; override;
  end;

{ TMathMinimumAggregatorEh }

  TMathMinimumAggregatorEh = class(TMathBaseAggregatorEh)
  private
  protected
  public
    class procedure CalcInitData(var InitData: TValue; StepsCount: Integer); override;
    class procedure CalcStepData(const StepValue: TValue; var AggrData: TValue); override;
    class function CalcFinalData(const AggrData: TValue): TValue; override;
  end;

{ TMathMaximumAggregatorEh }

  TMathMaximumAggregatorEh = class(TMathBaseAggregatorEh)
  private
  protected
  public
    class procedure CalcInitData(var InitData: TValue; StepsCount: Integer); override;
    class procedure CalcStepData(const StepValue: TValue; var AggrData: TValue); override;
    class function CalcFinalData(const AggrData: TValue): TValue; override;
  end;

{ TMathCountAggregatorEh }

  TMathCountAggregatorEh = class(TMathBaseAggregatorEh)
  private
  protected
  public
    class procedure CalcInitData(var InitData: TValue; StepsCount: Integer); override;
    class procedure CalcStepData(const StepValue: TValue; var AggrData: TValue); override;
    class function CalcFinalData(const AggrData: TValue): TValue; override;
  end;

{ TMathCountAllAggregatorEh }

  TMathCountAllAggregatorEh = class(TMathBaseAggregatorEh)
  private
  protected
  public
    class procedure CalcInitData(var InitData: TValue; StepsCount: Integer); override;
    class procedure CalcStepData(const StepValue: TValue; var AggrData: TValue); override;
    class function CalcFinalData(const AggrData: TValue): TValue; override;
  end;

{ TMathCountDistinctAggregatorEh }

  TMathCountDistinctAggregatorEh = class(TMathBaseAggregatorEh)
  private
  protected
  public
    class procedure CalcInitData(var InitData: TValue; StepsCount: Integer); override;
    class procedure CalcStepData(const StepValue: TValue; var AggrData: TValue); override;
    class function CalcFinalData(const AggrData: TValue): TValue; override;
  end;

implementation

{ TMathBaseAggregatorEh }

class procedure TMathBaseAggregatorEh.CalcInitData(var InitData: TValue; StepsCount: Integer);
begin
  raise Exception.Create('TMathBaseAggregatorEh.CalcInitData is not implemented');
end;

class procedure TMathBaseAggregatorEh.CalcStepData(const StepValue: TValue; var AggrData: TValue);
begin
  raise Exception.Create('TMathBaseAggregatorEh.CalcStepData is not implemented');
end;

class function TMathBaseAggregatorEh.CalcFinalData(const AggrData: TValue): TValue;
begin
  raise Exception.Create('TMathBaseAggregatorEh.CalcFinalData is not implemented');
end;

{ TMathSumAggregatorEh }

class procedure TMathSumAggregatorEh.CalcInitData(var InitData: TValue; StepsCount: Integer);
begin
  InitData := TValue.Empty;
end;

class procedure TMathSumAggregatorEh.CalcStepData(const StepValue: TValue; var AggrData: TValue);
{$IFDEF FPC}
begin
  AggrData := StepValue; 
end;
{$ELSE}
var
  BcdStep: TBcd;
  AggrValue: TBcd;
begin
  if StepValue.IsEmpty = False then
  begin
    if AggrData.IsEmpty = True then
    begin
      AggrData := CastValueToBcdValue(StepValue);
    end else
    begin
      BcdStep := CastValueToBcd(StepValue);
      AggrValue := AggrData.AsType<TBcd>();
      BcdAdd(AggrValue, BcdStep, AggrValue); 
      AggrData := TValue.From<TBcd>(AggrValue);
    end;
  end;
end;
{$ENDIF}

class function TMathSumAggregatorEh.CalcFinalData(const AggrData: TValue): TValue;
begin
  Result := AggrData;
end;

{ TMathAverageAggregatorEh }

class procedure TMathAverageAggregatorEh.CalcInitData(var InitData: TValue; StepsCount: Integer);
{$IFDEF FPC}
begin
end;
{$ELSE}
begin
  InitData := TValue.FromArray(TypeInfo(TValue), [TValue.Empty, TValue.Empty]);
end;
{$ENDIF}

class procedure TMathAverageAggregatorEh.CalcStepData(const StepValue: TValue; var AggrData: TValue);
{$IFDEF FPC}
begin
end;
{$ELSE}
var
  BcdStep, BcdAggrData: TBcd;
begin
  if (StepValue.IsEmpty = False) then
  begin
    if (AggrData.AsType<TArray<TValue>>[1].IsEmpty = True) then
    begin
      AggrData.SetArrayElement(0, 1);
      BcdStep := CastValueToBcd(StepValue);
      AggrData.SetArrayElement(1, TValue.From<TBcd>(BcdStep));
    end else
    begin
      AggrData.SetArrayElement(0, AggrData.AsType<TArray<TValue>>[0].AsInteger + 1);
      BcdStep := CastValueToBcd(StepValue);
      BcdAdd(AggrData.AsType<TBcd>(), BcdStep, BcdAggrData);
      AggrData.SetArrayElement(0, TValue.From<TBcd>(BcdAggrData));
    end;
  end;
end;
{$ENDIF}

class function TMathAverageAggregatorEh.CalcFinalData(const AggrData: TValue): TValue;
{$IFDEF FPC}
begin
end;
{$ELSE}
var
  Bcd1, Bcd2, Bcd3: TBcd;
begin
  if (AggrData.AsType<TArray<TValue>>[0].IsEmpty = False) and
     (SameValue(AggrData.AsType<TArray<TValue>>[0], 0) = False)
  then
  begin
    Bcd1 := CastValueToBcd(AggrData.AsType<TArray<TValue>>[1]);
    Bcd2 := CastValueToBcd(AggrData.AsType<TArray<TValue>>[0]);
    BcdDivide(Bcd1, Bcd2, Bcd3);
    Result := TValue.From<TBcd>(Bcd3);
  end else
    Result := TValue.Empty;
end;
{$ENDIF}

{ TMathMinimumAggregatorEh }

class procedure TMathMinimumAggregatorEh.CalcInitData(var InitData: TValue; StepsCount: Integer);
begin
  InitData := TValue.Empty;
end;

class procedure TMathMinimumAggregatorEh.CalcStepData(const StepValue: TValue; var AggrData: TValue);
begin
  if AggrData.IsEmpty = True then
    AggrData := StepValue
  else if StepValue.IsEmpty = False then
  begin
    if CompareValue(StepValue, AggrData) = TVariantRelationship.vrLessThan then
      AggrData := StepValue;
  end;
end;

class function TMathMinimumAggregatorEh.CalcFinalData(const AggrData: TValue): TValue;
begin
  Result := AggrData;
end;

{ TMathMaximumAggregatorEh }

class procedure TMathMaximumAggregatorEh.CalcInitData(var InitData: TValue; StepsCount: Integer);
begin
  InitData := TValue.Empty;
end;

class procedure TMathMaximumAggregatorEh.CalcStepData(const StepValue: TValue; var AggrData: TValue);
begin
  if AggrData.IsEmpty = True then
    AggrData := StepValue
  else if StepValue.IsEmpty = False then
  begin
    if CompareValue(StepValue, AggrData) = TVariantRelationship.vrGreaterThan then
      AggrData := StepValue;
  end;
end;

class function TMathMaximumAggregatorEh.CalcFinalData(const AggrData: TValue): TValue;
begin
  Result := AggrData;
end;

{ TMathCountAggregatorEh }

class procedure TMathCountAggregatorEh.CalcInitData(var InitData: TValue; StepsCount: Integer);
begin
  InitData := 0;
end;

class procedure TMathCountAggregatorEh.CalcStepData(const StepValue: TValue; var AggrData: TValue);
begin
  if ValueIsStringType(StepValue) and (StepValue.AsString = '') then
    EhLibUtils.DoNothing()
  else if ValueIsNullOrEmpty(StepValue) = True then
    EhLibUtils.DoNothing()
  else
    AggrData := TValue.From<Int64>(AggrData.AsInt64 + 1);
end;

class function TMathCountAggregatorEh.CalcFinalData(const AggrData: TValue): TValue;
begin
  Result := AggrData;
end;

{ TMathCountAllAggregatorEh }

class procedure TMathCountAllAggregatorEh.CalcInitData(var InitData: TValue; StepsCount: Integer);
begin
  InitData := TValue.From<Int64>(0);
end;

class procedure TMathCountAllAggregatorEh.CalcStepData(const StepValue: TValue;
  var AggrData: TValue);
begin
  AggrData := TValue.From<Int64>(AggrData.AsInt64 + 1);
end;

class function TMathCountAllAggregatorEh.CalcFinalData(const AggrData: TValue): TValue;
begin
  Result := AggrData;
end;

{ TMathCountDistinctAggregatorEh }

class procedure TMathCountDistinctAggregatorEh.CalcInitData(
  var InitData: TValue; StepsCount: Integer);
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  InitData := sl;
end;

class procedure TMathCountDistinctAggregatorEh.CalcStepData(
  const StepValue: TValue; var AggrData: TValue);
begin
{$IFDEF FPC}
{$ELSE}
  AggrData.AsType<TStringList>().Add(ValueToString(StepValue));
{$ENDIF}
end;

class function TMathCountDistinctAggregatorEh.CalcFinalData(
  const AggrData: TValue): TValue;
{$IFDEF FPC}
begin
  Result := 0;
end;
{$ELSE}
var
  I: Integer;
  sl: TStringList;
  curStr: String;
  ResultAsInt: Integer;
begin
  sl := AggrData.AsType<TStringList>();
  sl.Sort;
  ResultAsInt := 0;
  if sl.Count > 0 then
  begin
    ResultAsInt := 1;
    curStr := sl[0];
    for I := 1 to sl.Count - 1 do
    begin
      if SameStr(curStr, sl[I]) = False then
      begin
        curStr := sl[I];
        ResultAsInt := ResultAsInt + 1;
      end;
    end;
  end;
  sl.Free;

  Result := ResultAsInt;
end;
{$ENDIF}

end.
