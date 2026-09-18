{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{          EhLibFmx.DataAxisGrid.ToolControls           }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataAxisGrid.ToolControls;

interface

{$SCOPEDENUMS ON}

uses
  System.Generics.Collections,
  System.UITypes,
  SysUtils, Classes,
  Contnrs, Variants, Types,
  FMX.Types,
  FMX.Controls,

  Db, EhLibUtils,
  DBUtilsEh,
  DefaultDataSourcesEh,
  EhLibFmx.ToolControls,
  EhLibFmx.DataAxisGrid.FieldBars;

type

{ TFieldBarsListEh }

  TFieldBarsListEh = class(TList<TFieldBarEh>)
  private
  public
    constructor Create; overload;

    procedure Assign(List: TFieldBarsListEh); overload;
    procedure Assign(List: TReadonlyList<TFieldBarEh>); overload;
  end;

implementation

uses EhLibFmx.DataAxisGrids;

type
  TCustomDataAxisGridEhCrack = class(TCustomDataAxisGridEh);

{ TFieldBarsListEh }

procedure TFieldBarsListEh.Assign(List: TFieldBarsListEh);
var
  i: Integer;
begin
  Clear;
  for i := 0 to List.Count-1 do
    Add(List[i]);
end;

procedure TFieldBarsListEh.Assign(List: TReadonlyList<TFieldBarEh>);
var
  i: Integer;
begin
  Clear;
  for i := 0 to List.Count-1 do
    Add(List[i]);
end;

constructor TFieldBarsListEh.Create;
begin
  inherited Create;
end;

end.
