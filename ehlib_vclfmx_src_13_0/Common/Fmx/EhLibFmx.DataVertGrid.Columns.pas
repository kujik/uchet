{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{             EhLibFmx.DataVertGrid.Columns             }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataVertGrid.Columns;

interface

{$SCOPEDENUMS ON}

uses
  System.SysUtils, System.Classes,
  System.Generics.Collections, System.Generics.Defaults,
  FMX.Controls,

  DBUtilsEh,
  EhLib.GridTableViews,
  EhLibFmx.DataAxisGrids,
  EhLibFmx.ToolControls,
  EhLibFmx.DataAxisGrid.FieldBars;

type
  TDataVertGridColumnEh = class;

  TDataVertGridFindColumnProc = reference to function (AColumn: TDataVertGridColumnEh): Boolean;

{ TDataVertGridColumnEh }

  TDataVertGridColumnEh = class(TTableRowViewEh)
  private
    procedure SetSelected(const Value: Boolean);
  protected
    FIsSelected: Boolean;
    FHeight: Integer;
  public
    property Height: Integer read FHeight;
    property IsSelected: Boolean read FIsSelected write SetSelected;
  end;

{ TDataVertGridColumnsEh }

  TDataVertGridColumnsEh = class(TTableRowViewFilteredListEh)
  private
    function GetRowView(Index: Integer): TDataVertGridColumnEh;
  public
    function FindRow(FindRowProc: TDataVertGridFindColumnProc): TDataVertGridColumnEh;

    property ListItem[Index: Integer]: TDataVertGridColumnEh read GetRowView; default;
  end;

{ TDataGridRowsViewEh }

  TDataVertGridColumnsViewEh = class(TDataAxisGridTableViewEh)
  private
  protected
    function CreateAxisListItemBar(): TTableRowViewEh; override;
    function IsListItemMatchFilter(AListItem: TTableRowViewEh): Boolean; override;

  public
    constructor Create(AGrid: TCustomDataAxisGridEh);
    destructor Destroy; override;

    procedure UpdateFilteredRowList;
  end;

implementation

uses EhLibFmx.CustomDataVertGrids,
     EhLibFmx.DataVertGrid.ToolControls;

type
  TDataVertGridEhCrack = class(TCustomDataVertGridEh);

{ TDataVertGridColumnsViewEh }

constructor TDataVertGridColumnsViewEh.Create(AGrid: TCustomDataAxisGridEh);
begin
  inherited Create(AGrid);
end;

destructor TDataVertGridColumnsViewEh.Destroy;
begin
  inherited Destroy;
end;

function TDataVertGridColumnsViewEh.IsListItemMatchFilter(AListItem: TTableRowViewEh): Boolean;
begin
  Result := True;
end;

function TDataVertGridColumnsViewEh.CreateAxisListItemBar(): TTableRowViewEh;
begin
  Result := TDataVertGridColumnEh.Create(Self);
end;

type
  TFilteredItemListEhCrack = class(TTableRowViewFilteredListEh);

procedure TDataVertGridColumnsViewEh.UpdateFilteredRowList;
begin
  TFilteredItemListEhCrack(FilteredRowList).UpdateList;
end;

{ TDataVertGridColumnsEh }

function TDataVertGridColumnsEh.FindRow(FindRowProc: TDataVertGridFindColumnProc): TDataVertGridColumnEh;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    if FindRowProc(ListItem[I]) = True then
    begin
      Result := ListItem[I];
      Break;
    end;
  end;
end;

function TDataVertGridColumnsEh.GetRowView(Index: Integer): TDataVertGridColumnEh;
begin
  Result := TDataVertGridColumnEh(inherited ListItem[Index]);
end;

{ TDataVertGridColumnEh }

procedure TDataVertGridColumnEh.SetSelected(const Value: Boolean);
begin
end;

end.
