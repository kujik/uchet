{*******************************************************}
{                                                       }
{                       EhLib 12.1                      }
{       Utilities to sort, filter data in DataSet       }
{                                                       }
{      Copyright (c) 2024-2025 by Dmitry V. Bolshakov   }
{                                                       }
{*******************************************************}

unit DefaultDataSourcesEh;

{$I ..\Incl\EhLib.Inc}
{$SCOPEDENUMS ON}

interface

uses
  Variants, Contnrs,
  Db, SysUtils, Classes, TypInfo, Generics.Collections,
  EhLibUtils;

type

{ TDefaultDataSourceListEh }

  TDefaultDataSourceListEh = class(TComponent)
  private
    FSetToSourceDic: TDictionary<TDataSet, TDataSource>;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function GetDataSourceForDataSet(ADataSet: TDataSet): TDataSource;

    class function GetDefaultDataSourceForDataSet(ADataSet: TDataSet): TDataSource;
  end;

function GetDefaultDataSourceForDataSet(ADataSet: TDataSet): TDataSource;

implementation

var
  DefaultDataSourceList: TDefaultDataSourceListEh;

function GetDefaultDataSourceForDataSet(ADataSet: TDataSet): TDataSource;
begin
  Result := TDefaultDataSourceListEh.GetDefaultDataSourceForDataSet(ADataSet);
end;

{ TDefaultDataSourceListEh }

constructor TDefaultDataSourceListEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSetToSourceDic := TDictionary<TDataSet, TDataSource>.Create;
end;

destructor TDefaultDataSourceListEh.Destroy;
var
  SetSourcePair: TPair<TDataSet, TDataSource>;
begin
  for SetSourcePair in FSetToSourceDic do
  begin
    SetSourcePair.Value.Free;
  end;
  FreeAndNil(FSetToSourceDic);
  inherited Destroy;
end;

class function TDefaultDataSourceListEh.GetDefaultDataSourceForDataSet(ADataSet: TDataSet): TDataSource;
begin
  if DefaultDataSourceList = nil then
  begin
    DefaultDataSourceList := TDefaultDataSourceListEh.Create(nil);
  end;

  Result := DefaultDataSourceList.GetDataSourceForDataSet(ADataSet);
end;

function TDefaultDataSourceListEh.GetDataSourceForDataSet(ADataSet: TDataSet): TDataSource;
begin
  if FSetToSourceDic.TryGetValue(ADataSet, Result) = False then
  begin
    Result := TDataSource.Create(nil);
    Result.DataSet := ADataSet;
    FSetToSourceDic.Add(ADataSet, Result);
    ADataSet.FreeNotification(Self);
  end;
end;

procedure TDefaultDataSourceListEh.Notification(AComponent: TComponent; Operation: TOperation);
var
  Pair: TPair<TDataSet, TDataSource>;
begin
  inherited Notification(AComponent, Operation);
  if AComponent is TDataSet then
  begin
    Pair := FSetToSourceDic.ExtractPair(TDataSet(AComponent));
    if Pair.Value <> nil then
      Pair.Value.Free;
  end;
end;

procedure InitUnit;
begin

end;

procedure FinalUnit;
begin
  FreeAndNil(DefaultDataSourceList);
end;

initialization
  InitUnit;
finalization
  FinalUnit;
end.
