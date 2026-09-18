{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{          EhLibFmx.DataVertGrid.ToolControls           }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataVertGrid.ToolControls;

interface

{$SCOPEDENUMS ON}

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, System.Types,
  FMX.Graphics, System.UITypes, System.Math, FMX.Forms, System.Contnrs,

  EhLibFmx.Grids,
  EhLibFmx.Grid.Types,
  EhLibFmx.Grid.ToolControls,

  EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.DataAxisGrid.ToolControls,
  EhLibFmx.DataAxisGrids,

  EhLibFmx.DataVertGrid.Columns
  ;

type

{ TDataGridColumnOptionsEh }

  TDataVertGridRowOptionsEh = class(TFieldBarOptionsEh)
  private
    FColSizeUnit: TGridColSizeUnitEh;
    FAllowMove: Boolean;
    FAllowResize: Boolean;
    procedure SetColSizeUnit(const Value: TGridColSizeUnitEh);
    procedure SetAllowResize(const Value: Boolean);
  protected
    procedure HeightAutoExpandChanged; override;

  public
    constructor Create(AGrid: TControl);
    destructor Destroy; override;

  published

    property ColSizeUnit: TGridColSizeUnitEh read FColSizeUnit write SetColSizeUnit default TGridColSizeUnitEh.Pixels;
    property AllowResize: Boolean read FAllowResize write SetAllowResize default True;
    property AllowMove: Boolean read FAllowMove write FAllowMove default True;

    property AllowShowEditor;
    property Fill;
    property FillStored;
    property Font;
    property FontColor;
    property FontColorStored;
    property FontStored;
    property HeightAutoExpand;
    property HorzAlign;
    property HorzLinesColor;
    property HorzLinesColorStored;
    property HorzLinesVisible;
    property HorzLinesVisibleStored;
    property Padding;
    property PaddingStored;
    property Tooltips;
    property Trimming;
    property VertAlign;
    property VertLinesColor;
    property VertLinesColorStored;
    property VertLinesVisible;
    property VertLinesVisibleStored;
    property WordWrap;
  end;


{ TDataVertGridLineOptionsEh }

  TDataVertGridLineOptionsEh = class(TGridLineOptionsEh)
  published
    property BrightColor;
    property BrightColorStored;
    property DarkColor;
    property DarkColorStored;

    property HorzLinesVisible;
    property VertLinesVisible;
  end;

implementation

uses
  Data.DBConsts,
  EhLibLangConsts,
  EhLibFmx.CustomizeColumnsDialog,

  EhLibFmx.CustomDataVertGrids,
  EhLibFmx.DataVertGrid.Rows
  ;

type
  TCustomGridEhCrack = class(TCustomGridEh);
  TCustomDataVertGridEhCrack = class(TCustomDataVertGridEh);

{ TDataGridColumnOptionsEh }

constructor TDataVertGridRowOptionsEh.Create(AGrid: TControl);
begin
  inherited Create(AGrid);
  FAllowMove := True;
  FAllowResize := True;
  TCustomGridEhCrack(Self.FGrid).Options := TCustomGridEhCrack(Self.FGrid).Options + [TGridOptionEh.ColSizing];
end;

destructor TDataVertGridRowOptionsEh.Destroy;
begin
  inherited Destroy;
end;

procedure TDataVertGridRowOptionsEh.HeightAutoExpandChanged;
begin
  inherited HeightAutoExpandChanged;
end;

procedure TDataVertGridRowOptionsEh.SetAllowResize(const Value: Boolean);
var
  Grid: TCustomGridEhCrack;
begin
  Grid := TCustomGridEhCrack(Self.FGrid);
  if FAllowResize <> Value then
  begin
    FAllowResize := Value;
    if FAllowResize then
      Grid.Options := Grid.Options + [TGridOptionEh.ColSizing]
    else
      Grid.Options := Grid.Options - [TGridOptionEh.ColSizing];
  end;
end;

procedure TDataVertGridRowOptionsEh.SetColSizeUnit(const Value: TGridColSizeUnitEh);
begin
  if (FColSizeUnit <> Value) then
  begin
    FColSizeUnit := Value;
    Changed();
  end;
end;

end.
