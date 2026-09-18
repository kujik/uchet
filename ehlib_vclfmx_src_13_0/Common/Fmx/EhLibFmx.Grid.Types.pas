{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{                 EhLibFmx.Grid.Types                   }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.Grid.Types;

interface

{$SCOPEDENUMS ON}

type
  TGridDrawState = set of (gdSelected, gdFocused, gdCurrent, gdFixed, gdRowSelected, gdHotTrack, gdPressed);

  TGridOptionEh = (
    {goFixedVertLineEh, goFixedHorzLineEh, VertLine, HorzLine,}
    DrawFocusSelected, RowSizing, ColSizing, RowMoving,
    ColMoving, Editing, Tabs, RowSelect,
    AlwaysShowEditor, ThumbTracking, ExtendVertLines,
    ContraVertBoundaryLine, ContraHorzBoundaryLine, RangeSelect
   );
  TGridOptionsEh = set of TGridOptionEh;

  TGridScrollDirection = (Left, Right, Up, Down);

  TGridScrollDirections = set of TGridScrollDirection;

  TEditStyle =  (Simple, Ellipsis, PickList);

  TGridColSizeUnitEh = (Pixels, Weight);

  TGridCellBorderTypeEh = (Top, Left, Bottom, Right);
  TGridCellBorderTypesEh = set of TGridCellBorderTypeEh;

{ TGridCoord }

  TGridCoord = record
    X: Integer;
    Y: Integer;
  public
    class operator Equal(const Lhs, Rhs : TGridCoord) : Boolean;
    class operator NotEqual(const Lhs, Rhs : TGridCoord): Boolean;
  end;

  TGridRect = record
    case Integer of
      0: (Left, Top, Right, Bottom: Integer);
      1: (TopLeft, BottomRight: TGridCoord);
  end;

implementation

{ TGridCoord }

class operator TGridCoord.Equal(const Lhs, Rhs: TGridCoord): Boolean;
begin
  Result := (Lhs.X = Rhs.X) and (Lhs.Y = Rhs.Y);
end;

class operator TGridCoord.NotEqual(const Lhs, Rhs: TGridCoord): Boolean;
begin
  Result := (Lhs.X <> Rhs.X) or (Lhs.Y <> Rhs.Y);
end;

end.
