{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{                EhLibFmx.DataGrid.Rows                 }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataGrid.Rows;

interface

{$SCOPEDENUMS ON}

{$REGION 'uses'}
uses
  System.SysUtils, System.Classes, Rtti,
  System.Generics.Collections, System.Generics.Defaults,
  FMX.Controls,

  DBUtilsEh,
  EhLib.TableLinks,
  EhLib.GridTableViews,
  EhLibFmx.Grids,
  EhLibFmx.DataAxisGrids,
  EhLibFmx.ToolControls,
  EhLibFmx.DataAxisGrid.FieldBars;
{$ENDREGION 'uses'}

type
  TDataGridRowEh = class;
  TDataGridDataRowEh = class;
  TDataGridTableRowEh = class;
  TDataGridRowsEh = class;

  TDataGridFindTableRowProc = reference to function (ARow: TDataGridTableRowEh): Boolean;
  TDataGridFindRowProc = reference to function (ARow: TDataGridRowEh): Boolean;

  TDataGridRowKindEh = (DataRow, GroupHeaderRow, GroupFooterRow);

{ TDataGridTableRowEh }

  TDataGridTableRowEh = class(TTableRowViewEh)
  private
    FGridDataRow: TDataGridDataRowEh;
  protected
  public
    property GridDataRow: TDataGridDataRowEh read FGridDataRow;
  end;

{ TDataGridTableRowsEh }

  TDataGridTableRowsEh = class(TTableRowViewFilteredListEh)
  private
    function GetRowView(Index: Integer): TDataGridTableRowEh;
  public
    constructor Create(ATableView: TBaseGridTableViewEh);
    destructor Destroy; override;

    function FindRow(FindRowProc: TDataGridFindTableRowProc): TDataGridTableRowEh;

    property ListItem[Index: Integer]: TDataGridTableRowEh read GetRowView; default;
  end;

{ TDataGridTableRowsViewEh }

  TDataGridTableRowsViewEh = class(TDataAxisGridTableViewEh)
  private
  protected
    function CreateAxisListItemBar(): TTableRowViewEh; override;
    function IsListItemMatchFilter(AListItem: TTableRowViewEh): Boolean; override;
    function CreateViewListItems(): TTableRowViewFilteredListEh; override;

  public
    constructor Create(AGrid: TCustomDataAxisGridEh);
    destructor Destroy; override;

    procedure UpdateFilteredRowList;
  end;

{ TDataGridRowsViewEh }

  TDataGridRowsViewEh = class(TComponent)
  private
    FGrid: TCustomDataAxisGridEh;
    FCurrentRowIndex: Integer;
    FInternalDataTableIndexUpdating: Boolean;
    function GetActive: Boolean;
    function GetCurrentRow: TDataGridRowEh;
    procedure SetCurrentRowIndex(const Value: Integer);
    function GetRows: TDataGridRowsEh;
    procedure InternalUpdateDataTableIndexFromGridRowIndex;
    procedure CurrentRowIndexChanged(OldCurrentRowIndex: Integer);
    function GetCanModify: Boolean;
    function GetAtEndOfRowsList: Boolean;
    function GetAtStartOfRowsList: Boolean;
  protected

  public
    constructor Create(AGrid: TCustomDataAxisGridEh); reintroduce;
    destructor Destroy; override;

    function MoveRowPosBy(Distance: Integer): Integer;

    procedure UpdateCurrentRowIndexFromDataTable();
    procedure GotoPriorRow();
    procedure GotoNextRow();
    procedure GotoFirstRow();
    procedure GotoLastRow();

    property Active: Boolean read GetActive;
    property CurrentRowIndex: Integer read FCurrentRowIndex write SetCurrentRowIndex;
    property CurrentRow: TDataGridRowEh read GetCurrentRow;
    property Rows: TDataGridRowsEh read GetRows;
    property CanModify: Boolean read GetCanModify;
    property AtEndOfRowsList: Boolean read GetAtEndOfRowsList;
    property AtStartOfRowsList: Boolean read GetAtStartOfRowsList;
  end;

{ TDataGridRowEh }

  TDataGridRowEh = class(TPersistent)
  private
    procedure SetSelected(const Value: Boolean);
    function GetCanModify: Boolean;

  protected
    FParentRow: TDataGridRowEh;
    FIsSelected: Boolean;
    FHeight: Integer;
    FGrid: TComponent;
//    FFullKey: array of TValue;
//    FKeyValue: TValue;

    function GetSourceItem: Pointer; virtual;
    function GetSourceObjectItem: TObject; virtual;
    function GetSourceRowLink: TTableRowLinkEh; virtual;

  public
    constructor Create(AGrid: TComponent);
    destructor Destroy; override;

    function CanModifyRow: Boolean; virtual;

    property Height: Integer read FHeight;
    property IsSelected: Boolean read FIsSelected write SetSelected;
    property ParentRow: TDataGridRowEh read FParentRow;
    property SourceItem: Pointer read GetSourceItem;
    property SourceObjectItem: TObject read GetSourceObjectItem;
    property SourceRowLink: TTableRowLinkEh read GetSourceRowLink;
    property CanModify: Boolean read GetCanModify;
  end;

{ TDataGridRowsEh }

  TDataGridRowsEh = class(TReadonlyList<TDataGridRowEh>)

  public
    function FindRow(FindRowProc: TDataGridFindRowProc): TDataGridRowEh;

  end;

{ TDataGridDataRowEh }

  TDataGridDataRowEh = class(TDataGridRowEh)
  private
    FTableRow: TDataGridTableRowEh;

  protected
    function GetSourceItem: Pointer; override;
    function GetSourceObjectItem: TObject; override;
    function GetSourceRowLink: TTableRowLinkEh; override;

  public
    constructor Create(AGrid: TComponent; ATableRow: TDataGridTableRowEh);
    destructor Destroy; override;

    function CanModifyRow: Boolean; override;

    property TableRow: TDataGridTableRowEh read FTableRow;
//    property ParentRow: TDataGridGroupHeaderRowEh read GetParentRow;
  end;

implementation

uses EhLibFmx.CustomDataGrids,
     EhLibFmx.DataGrid.DataGrouping,
     EhLibFmx.DataGrid.ToolControls;

type
  TDataGridEhCrack = class(TCustomDataGridEh);

{$REGION 'TDataGridTableRowsViewEh'}

{ TDataGridTableRowsViewEh }

constructor TDataGridTableRowsViewEh.Create(AGrid: TCustomDataAxisGridEh);
begin
  inherited Create(AGrid);
end;

destructor TDataGridTableRowsViewEh.Destroy;
begin
  inherited Destroy;
end;

function TDataGridTableRowsViewEh.IsListItemMatchFilter(AListItem: TTableRowViewEh): Boolean;
var
  AGrid: TDataGridEhCrack;
begin
  AGrid := TDataGridEhCrack(Grid);
  Result := AGrid.IsTableRowMatchFilter(TDataGridTableRowEh(AListItem));
end;

function TDataGridTableRowsViewEh.CreateAxisListItemBar(): TTableRowViewEh;
begin
  Result := TDataGridTableRowEh.Create(Self);
end;

type
  TFilteredItemListEhCrack = class(TTableRowViewFilteredListEh);

procedure TDataGridTableRowsViewEh.UpdateFilteredRowList;
begin
  TFilteredItemListEhCrack(FilteredRowList).UpdateList;
end;

function TDataGridTableRowsViewEh.CreateViewListItems: TTableRowViewFilteredListEh;
begin
  Result := TDataGridTableRowsEh.Create(Self);
end;

{$ENDREGION 'TDataGridTableRowsViewEh'}

{$REGION 'TDataGridTableRowsEh'}

{ TDataGridTableRowsEh }

constructor TDataGridTableRowsEh.Create(ATableView: TBaseGridTableViewEh);
begin
  inherited Create(ATableView);
end;

destructor TDataGridTableRowsEh.Destroy;
begin
  inherited Destroy;
end;

function TDataGridTableRowsEh.FindRow(FindRowProc: TDataGridFindTableRowProc): TDataGridTableRowEh;
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

function TDataGridTableRowsEh.GetRowView(Index: Integer): TDataGridTableRowEh;
begin
  Result := TDataGridTableRowEh(inherited ListItem[Index]);
end;

{$ENDREGION 'TDataGridTableRowsEh'}

{$REGION 'TDataGridRowEh'}

{ TDataGridRowEh }

constructor TDataGridRowEh.Create(AGrid: TComponent);
begin
  inherited Create;
  FGrid := AGrid;
end;

destructor TDataGridRowEh.Destroy;
begin
  inherited Destroy;
end;

procedure TDataGridRowEh.SetSelected(const Value: Boolean);
var
  VGrid: TDataGridEhCrack;
begin
  if (FIsSelected <> Value) then
  begin
    VGrid := TDataGridEhCrack(FGrid);
    VGrid.Selection.SetSelectedRow(Self, Value);
  end;
end;

function TDataGridRowEh.GetCanModify: Boolean;
var
  VGrid: TDataGridEhCrack;
begin
  VGrid := TDataGridEhCrack(FGrid);
  if VGrid.CanTableOperation(TDataGridAllowedOperationEh.Update) and CanModifyRow
    then Result := True
    else Result := False;
end;

function TDataGridRowEh.CanModifyRow: Boolean;
begin
  Result := False;
end;

function TDataGridRowEh.GetSourceItem: Pointer;
begin
  Result := nil;
end;

function TDataGridRowEh.GetSourceObjectItem: TObject;
begin
  Result := nil;
end;

function TDataGridRowEh.GetSourceRowLink: TTableRowLinkEh;
begin
  Result := nil;
end;

{$ENDREGION 'TDataGridRowEh'}

{$REGION 'TDataGridDataRowEh'}

{ TDataGridDataRowEh }

function TDataGridDataRowEh.CanModifyRow: Boolean;
begin
  Result := True;
end;

constructor TDataGridDataRowEh.Create(AGrid: TComponent; ATableRow: TDataGridTableRowEh);
begin
  inherited Create(AGrid);
  FTableRow := ATableRow;
  ATableRow.FGridDataRow := Self;
end;

destructor TDataGridDataRowEh.Destroy;
begin
  inherited Destroy;
end;

function TDataGridDataRowEh.GetSourceItem: Pointer;
begin
  Result := TableRow.SourceItem;
end;

function TDataGridDataRowEh.GetSourceObjectItem: TObject;
begin
  Result := TableRow.SourceObjectItem;
end;

function TDataGridDataRowEh.GetSourceRowLink: TTableRowLinkEh;
begin
  Result := TableRow.SourceRowLink;
end;

{$ENDREGION 'TDataGridDataRowEh'}

{$REGION 'TDataGridRowsEh'}

{ TDataGridRowsEh }

function TDataGridRowsEh.FindRow(FindRowProc: TDataGridFindRowProc): TDataGridRowEh;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    if FindRowProc(Items[I]) = True then
    begin
      Result := Items[I];
      Break;
    end;
  end;
end;

{$ENDREGION 'TDataGridRowsEh'}

{$REGION 'TDataGridRowsViewEh'}

{ TDataGridRowsViewEh }

constructor TDataGridRowsViewEh.Create(AGrid: TCustomDataAxisGridEh);
begin
  inherited Create(nil);
  FGrid := AGrid;
  FCurrentRowIndex := -1;
end;

destructor TDataGridRowsViewEh.Destroy;
begin
  inherited Destroy;
end;

function TDataGridRowsViewEh.GetActive: Boolean;
begin
  Result := FGrid.TableView.Active;
end;

function TDataGridRowsViewEh.GetAtEndOfRowsList: Boolean;
begin
  if Rows.Count = 0
    then Result := True
    else Result := CurrentRowIndex = Rows.Count - 1;
end;

function TDataGridRowsViewEh.GetAtStartOfRowsList: Boolean;
begin
  if Rows.Count = 0
    then Result := True
    else Result := CurrentRowIndex <= 0;
end;

function TDataGridRowsViewEh.GetCurrentRow: TDataGridRowEh;
begin
  if FCurrentRowIndex >= 0 then
    Result := TDataGridEhCrack(FGrid).VisibleRows[FCurrentRowIndex]
  else
    Result := nil;
end;

function TDataGridRowsViewEh.GetRows: TDataGridRowsEh;
begin
  Result := TDataGridEhCrack(FGrid).VisibleRows;
end;

procedure TDataGridRowsViewEh.GotoFirstRow;
begin
  if Rows.Count > 0
    then CurrentRowIndex := 0
    else CurrentRowIndex := -1;
end;

procedure TDataGridRowsViewEh.GotoLastRow;
begin
  if Rows.Count > 0
    then CurrentRowIndex := Rows.Count - 1
    else CurrentRowIndex := -1;
end;

procedure TDataGridRowsViewEh.GotoNextRow;
begin
  if CurrentRowIndex < Rows.Count - 1 then
    CurrentRowIndex := CurrentRowIndex + 1;
end;

procedure TDataGridRowsViewEh.GotoPriorRow;
begin
  if CurrentRowIndex > 0 then
  begin
    CurrentRowIndex := CurrentRowIndex - 1;
  end;
end;

procedure TDataGridRowsViewEh.SetCurrentRowIndex(const Value: Integer);
var
  OldCurrentRowIndex: Integer;
begin
  if FCurrentRowIndex <> Value then
  begin
    OldCurrentRowIndex := FCurrentRowIndex;
    FCurrentRowIndex := Value;
    InternalUpdateDataTableIndexFromGridRowIndex();
    CurrentRowIndexChanged(OldCurrentRowIndex);
  end;
end;

procedure TDataGridRowsViewEh.CurrentRowIndexChanged(OldCurrentRowIndex: Integer);
var
  Grid: TDataGridEhCrack;
begin
  Grid := TDataGridEhCrack(FGrid);
  if CurrentRowIndex <> OldCurrentRowIndex then
  begin
    Grid.UpdateBaseGridRowIndexFromGridView();
    Grid.DataOrPositionChanged();
    Grid.LayoutChanged(True);
  end;
end;

procedure TDataGridRowsViewEh.InternalUpdateDataTableIndexFromGridRowIndex();
var
  Row: TDataGridRowEh;
  DataRow: TDataGridDataRowEh;
  Grid: TDataGridEhCrack;
begin
  Grid := TDataGridEhCrack(FGrid);
  FInternalDataTableIndexUpdating := True;
  try
    if CurrentRowIndex = -1 then
      Grid.TableView.CurrentRowViewIndex := -1
    else
    begin
      Row := Rows[CurrentRowIndex];
      if Row is TDataGridDataRowEh then
      begin
        DataRow := TDataGridDataRowEh(Row)
      end
      else if Row is TDataGridGroupHeaderRowEh then
      begin
        while Row is TDataGridGroupHeaderRowEh do
        begin
          Row := TDataGridGroupHeaderRowEh(Row).ChildRows[0];
        end;
        DataRow := Row as TDataGridDataRowEh;
      end else
      begin
        DataRow := nil;
      end;
      if DataRow <> nil then
        Grid.TableView.CurrentRowViewIndex := Grid.TableView.Rows.IndexOf(DataRow.TableRow);
    end;
  finally
    FInternalDataTableIndexUpdating := False;
  end;
end;

function TDataGridRowsViewEh.MoveRowPosBy(Distance: Integer): Integer;
var
  NewPos: Integer;
  OldPos: Integer;
begin
  OldPos := CurrentRowIndex;
  NewPos := CurrentRowIndex + Distance;
  if NewPos < 0 then NewPos := 0;
  if NewPos > Rows.Count - 1 then NewPos := Rows.Count - 1;
  CurrentRowIndex := NewPos;
  Result := OldPos - CurrentRowIndex;
end;

procedure TDataGridRowsViewEh.UpdateCurrentRowIndexFromDataTable;
var
  OldCurrentRowIndex: Integer;
  NewCurrentRowViewIndex: Integer;
  Grid: TDataGridEhCrack;
  I: Integer;
begin
  if FInternalDataTableIndexUpdating then Exit;

  NewCurrentRowViewIndex := -1;
  Grid := TDataGridEhCrack(FGrid);

  if Active then
  begin
    for I := 0 to Rows.Count - 1 do
    begin
      if (Rows[I] is TDataGridDataRowEh) and
         (TDataGridDataRowEh(Rows[I]).TableRow = Grid.TableView.CurrentRowView) then
      begin
        NewCurrentRowViewIndex := I;
        Break;
      end;
    end;
  end;

  if NewCurrentRowViewIndex <> FCurrentRowIndex then
  begin
    OldCurrentRowIndex := FCurrentRowIndex;
    FCurrentRowIndex := NewCurrentRowViewIndex;
    CurrentRowIndexChanged(OldCurrentRowIndex);
  end;
end;

function TDataGridRowsViewEh.GetCanModify: Boolean;
begin
  Result := TDataGridEhCrack(FGrid).TableView.CanModify;
end;

{$ENDREGION 'TDataGridRowsViewEh'}

end.

