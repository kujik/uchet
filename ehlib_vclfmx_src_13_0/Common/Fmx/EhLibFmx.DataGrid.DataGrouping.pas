{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.2                     }
{            EhLibFmx.DataGrid.DataGrouping             }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataGrid.DataGrouping;

interface

{$SCOPEDENUMS ON}

{$REGION 'uses'}
uses
  System.SysUtils, System.Classes, System.Contnrs, System.Types,
  FMX.Types, FMX.Controls, Rtti, System.UIConsts,
  System.Generics.Collections, System.Generics.Defaults,
  System.UITypes,
  System.Variants,
  FMX.Forms, FMX.Objects, FMX.Graphics,

  EhLib.TableLinks,
  EhLib.GridTableViews,

  EhLibUtils, DBUtilsEh, DynVarsEh, MemTreeEh,
  EhLibFmx.Utils,
  EhLibFmx.ImageReses,
  EhLibFmx.ToolControls,
  EhLibFmx.LaControls,
  EhLibFmx.LaObjects,
  EhLibFmx.LaGridPanels,
  EhLibFmx.LaHostVirtualPanels,
  EhLibFmx.Grid.CellManagers,
  EhLibFmx.DataGrid.Columns,
  EhLibFmx.DataGrid.Footers,
  EhLibFmx.DataGrid.Rows,
  EhLibFmx.Types
  ;
{$ENDREGION 'uses'}

type
  TDataGridGroupHeaderRowEh = class;
  TDataGridGroupFooterRowEh = class;
  TDataGridGroupingTreeListEh = class;
  TDataGridDataGroupingEh = class;
  TDataGridGroupDescriptionEh = class;
  TDataGridGroupHeaderBandManagerEh = class;
  TDataGridGroupHeaderBandEh = class;
  TDataGridGroupFootersEh = class;

{ TDataGridGroupHeaderRowEh }

  TDataGridGroupHeaderRowEh = class(TDataGridRowEh)
  private
    FChildRowList: TList<TDataGridRowEh>;
    FChildRows: TReadonlyList<TDataGridRowEh>;
    FIsExpanded: Boolean;
    FDisplayText: String;
    FFooterList: TList<TDataGridGroupFooterRowEh>;
    FFooters: TDataGridGroupFootersEh;

    function GetParentRow: TDataGridGroupHeaderRowEh;

    procedure SetIsExpanded(const Value: Boolean);
    function GetLevel: Integer;

  protected
    FKeyValue: TValue;
    FGroupDescription: TDataGridGroupDescriptionEh;

    procedure ExpandedChanged(); virtual;
    procedure DeleteChildrenRows();
    procedure DeleteChildrenDataRows();
    procedure SetFooterColCount(AFooterColCount: Integer);
    procedure SetFooterRowCount(AFooterRowCount: Integer);

  public
    constructor Create(AGrid: TComponent);
    destructor Destroy; override;

    property ChildRows: TReadonlyList<TDataGridRowEh> read FChildRows; //(TDataGridGroupHeaderRowEh or TDataGridDataRowEh);
//    property FooterRows[Index: Integer]: TDataGridGroupFooterRowEh read GetFooterRows;
    property IsExpanded: Boolean read FIsExpanded write SetIsExpanded;
    property ParentRow: TDataGridGroupHeaderRowEh read GetParentRow;
    property Level: Integer read GetLevel;
    property DisplayText: String read FDisplayText;
    property GroupDescription: TDataGridGroupDescriptionEh read FGroupDescription;
    property KeyValue: TValue read FKeyValue;
    property Footers: TDataGridGroupFootersEh read FFooters;
  end;

{ TDataGridGroupFootersEh }

  TDataGridGroupFootersEh = class(TReadonlyList<TDataGridGroupFooterRowEh>)

  end;

{ TDataGridGroupFooterRowEh }

  TDataGridGroupFooterRowEh = class(TDataGridRowEh)
  private
    FInTotalFootersRowIndex: Integer;
    FFooterValues: TArray<TValue>;
    function GetColumnValue(AColIndex: Integer): TValue;
    function GetLevel: Integer;

  protected
    procedure SetFooterValuesSize(ANewSize: Integer);
  public
    constructor Create(AGrid: TComponent);
    destructor Destroy; override;

    function GetFooterValue(AColumn: TDataGridBaseColumnEh): TValue;
    property ColumnValue[AColIndex: Integer]: TValue read GetColumnValue;
    property InTotalFootersRowIndex: Integer read FInTotalFootersRowIndex;
    property Level: Integer read GetLevel;
  end;

  TDataGridRowProcedureEh = reference to procedure(Node: TDataGridRowEh);

{ TDataGridGroupingTreeListEh }

  TDataGridGroupingTreeListEh = class(TPersistent)
  private
    FChildRowList: TList<TDataGridRowEh>;
    FChildRows: TReadonlyList<TDataGridRowEh>;

//    FBaseFlatList: TList<TDataGridRowEh>;
//    FFlatList: TReadonlyList<TDataGridRowEh>;
  public
    constructor Create();
    destructor Destroy; override;

    procedure ForAllTreeChildRows(NodeMethod: TDataGridRowProcedureEh);

    property ChildRows: TReadonlyList<TDataGridRowEh> read FChildRows;
//    property FlatList: TReadonlyList<TDataGridRowEh> read FFlatList;
    //FooterRows[]: TDataGridGroupFooterRowEh;
  end;

{ TDataGridGroupDescriptionsEh }

  TDataGridGroupDescriptionsEh = class(TCollection)
  private
    FDataGrouping: TDataGridDataGroupingEh;
    function GetGrid: TComponent;
    function GetGroupDescription(Index: Integer): TDataGridGroupDescriptionEh;
    procedure SetGroupDescription(Index: Integer; const Value: TDataGridGroupDescriptionEh);

  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
    procedure RefreshDefaultFont;
  public
    constructor Create(ADataGrouping: TDataGridDataGroupingEh; AItemClass: TCollectionItemClass);

    function Add: TDataGridGroupDescriptionEh;
    function AddDescription(AColumnName: String): TDataGridGroupDescriptionEh; overload;
    function AddDescription(AColumn: TDataGridBaseColumnEh): TDataGridGroupDescriptionEh; overload;

    function DataGrouping: TDataGridDataGroupingEh;

    property Grid: TComponent read GetGrid;
    property Items[Index: Integer]: TDataGridGroupDescriptionEh read GetGroupDescription write SetGroupDescription; default;
  end;

{ TDataGridGroupDescriptionEh }

  TDataGridGroupDescriptionEh = class(TCollectionItem)
  private
    FColumnName: String;
    FColumn: TDataGridBaseColumnEh;
    FDefaultRowHeight: Integer;
    FHeightRecalcNeeded: Boolean;
    FSortOrder: TSortOrderEh;

    function GetActiveIndex: Integer;
    function GetCollection: TDataGridGroupDescriptionsEh;
    function GetDefaultRowHeight: Integer;
    function GetFill: TBrush;
    function GetFont: TFont;
    function GetFontColor: TAlphaColor;

    procedure SetColumn(const Value: TDataGridBaseColumnEh);
    procedure SetColumnName(const Value: String);
    procedure SetSortOrder(const Value: TSortOrderEh);

  protected
    function GetDisplayName: string; override;
    function GetKeyValueForTableRow(ATableRow: TDataGridTableRowEh): TValue;

    procedure ResortData();
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    procedure SetHeightRecalcNeeded();
    procedure CheckRecalcHeight();

    property HeightRecalcNeeded: Boolean read FHeightRecalcNeeded;

    property ColumnName: String read FColumnName write SetColumnName;
    property Collection: TDataGridGroupDescriptionsEh read GetCollection;

    property Font: TFont read GetFont;
    property FontColor: TAlphaColor read GetFontColor;
    property Fill: TBrush read GetFill;

    property DefaultRowHeight: Integer read GetDefaultRowHeight;
    property ActiveIndex: Integer read GetActiveIndex;

  published

    property Column: TDataGridBaseColumnEh read FColumn write SetColumn;
    property SortOrder: TSortOrderEh read FSortOrder write SetSortOrder default soAscEh;
  end;

{ TDataGridDataGroupingEh }

  TDataGridDataGroupingEh = class(TPersistent)
  private
    FGrid: TControl;
    FActiveGroupDescriptionList: TList<TDataGridGroupDescriptionEh>;
    FActiveGroupDescriptions: TReadonlyList<TDataGridGroupDescriptionEh>;
    FGroupDescriptions: TDataGridGroupDescriptionsEh;
    FTreeList: TDataGridGroupingTreeListEh;
    FFlatRowList: TList<TDataGridRowEh>;
    FIsRowsInTree: Boolean;
    FDefaultDataRowCellManager: TDataGridGroupHeaderBandManagerEh;
    FFillStored: Boolean;
    FFontColorStored: Boolean;
    FFont: TFont;
    FDefaultFill: TBrush;
    FFill: TBrush;
    FFontStored: Boolean;
    FFontColor: TAlphaColor;
    FIsGroupDefaultExpended: Boolean;
    FGroupingPanelVisible: Boolean;
    FGroupDescriptionControlManager: TVPBaseCellManagerEh;

    function GetGrid: TControl;
    procedure SetGroupDescriptions(const Value: TDataGridGroupDescriptionsEh);
    function GetActive: Boolean;
    procedure BuildTreeView;
    procedure ClearViewRows(IsDeleteGroupingHeaders: Boolean);
    procedure ClearTreeView;
    procedure ClearTreeViewDataRows;
    procedure ClearTableView;
    procedure DeleteChildrenRows(Row: TDataGridRowEh);
    procedure DeleteChildrenDataRows(Row: TDataGridRowEh);
    procedure RebuildFlatList;
    procedure AddTableRowView(ARowView: TDataGridTableRowEh; NewIndex: Integer);
    procedure DeleteTableRowView(ARowView: TDataGridTableRowEh; OldIndex: Integer);
    procedure AddTableRowViewToGroupingList(ARowView: TDataGridTableRowEh);
    procedure AddTableRowViewToTableList(ARowView: TDataGridTableRowEh; AIndex: Integer);
    procedure RebuildTableView;
    procedure DeleteTableRowViewFromTableList(ARowView: TDataGridTableRowEh; AIndex: Integer);
    procedure DeleteTableRowViewFromGroupingList(ARowView: TDataGridTableRowEh);
    function GetFontColor: TAlphaColor;
    function IsFillStored: Boolean;
    function IsFontColorStored: Boolean;
    function IsFontStored: Boolean;

    procedure SetFill(const Value: TBrush);
    procedure SetFillStored(const Value: Boolean);
    procedure SetFont(const Value: TFont);
    procedure SetFontColor(const Value: TAlphaColor);
    procedure SetFontColorStored(const Value: Boolean);
    procedure SetFontStored(const Value: Boolean);
    procedure FontChanged(Sender: TObject);
    procedure FillChanged(Sender: TObject);
    procedure RefreshDefaultFill;
    procedure SetIsGroupDefaultExpended(const Value: Boolean);
    procedure SetGroupingPanelVisible(const Value: Boolean);
    procedure DeleteEmptyGroupingHeaders;
    procedure BuildFooterRows;

  protected
    function GetOwner: TPersistent; override;

    function AddRecordNodeForKey(AKey: array of TValue; ATableRow: TDataGridTableRowEh): TDataGridDataRowEh;
    function GetNodeToInsertForKey1(ParentNode: TDataGridGroupHeaderRowEh; Key1: TValue; var InsertIndex: Integer): TDataGridRowEh;
    function DefaultFill(): TBrush; virtual;
    function DefaultFont(): TFont; virtual;
    function DefaultFontColor(): TAlphaColor; virtual;

    procedure ActiveChanged; virtual;
    procedure GroupDescriptionsChanged(Item: TDataGridGroupDescriptionEh); virtual;
    procedure TableViewDataChanged(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowView: TTableRowViewEh); virtual;
    procedure RebuildTreeView(IsDeleteGroupingHeaders: Boolean);
    procedure RowExpandedStateChanged(ARow: TDataGridGroupHeaderRowEh);
    procedure InvalidateVisual(CellLayoutAffects: Boolean = False); virtual;
    procedure InternalUpdateActiveGroupDescirtion();

    property IsRowsInTree: Boolean read FIsRowsInTree;
  public
    constructor Create(AGrid: TControl; AVisibleRowList: TList<TDataGridRowEh>);
    destructor Destroy; override;

    function GetGroupHeaderRowManagerForRow(ARow: TDataGridGroupHeaderRowEh): TVPBaseCellManagerEh;
    function InGridVertCaptureSize: Integer;

    procedure RefreshDefaultFont;
    procedure CheckRecalcGroupDescriptionsHeight();
    procedure ResortDataInLevel(AGroupDescription: TDataGridGroupDescriptionEh);
    procedure RecalcFooters;
    procedure ForAllRows(NodeMethod: TDataGridRowProcedureEh);
    procedure RebuildListView(IsDeleteGroupingHeaders: Boolean);

    property Grid: TControl read GetGrid;
    property Active: Boolean read GetActive;
    property GroupDescriptionControlManager: TVPBaseCellManagerEh read FGroupDescriptionControlManager;
//    property GroupingModeActive: Boolean read GetGroupingModeActive;
    property ActiveGroupDescriptions: TReadonlyList<TDataGridGroupDescriptionEh> read FActiveGroupDescriptions;
    property IsGroupDefaultExpended: Boolean read FIsGroupDefaultExpended write SetIsGroupDefaultExpended;

  published
    property GroupDescriptions: TDataGridGroupDescriptionsEh read FGroupDescriptions write SetGroupDescriptions;
    property GroupingPanelVisible: Boolean read FGroupingPanelVisible write SetGroupingPanelVisible default False;

    property Font: TFont read FFont write SetFont stored IsFontStored;
    property FontStored: Boolean read FFontStored write SetFontStored default False;

    property FontColor: TAlphaColor read GetFontColor write SetFontColor stored IsFontColorStored;
    property FontColorStored: Boolean read FFontColorStored write SetFontColorStored default False;

    property Fill: TBrush read FFill write SetFill stored IsFillStored;
    property FillStored: Boolean read FFillStored write SetFillStored default False;
  end;

{ TDataGridGroupHeaderBandManagerEh }

  TDataGridGroupHeaderBandManagerEh = class(TBaseGridCellManagerEh)
  protected
    function GetDataTreeViewAreaParams(ACell: TDataGridGroupHeaderBandEh): TGridCellTreeViewAreaParamsEh; virtual;

    procedure CellTreeSignMouseDown(Sender: TObject; Params: TControlMouseButtonParamsEh);
    procedure InitCellTreeViewArea(ACell: TDataGridGroupHeaderBandEh); virtual;
    procedure InitTreeViewArea(ACell: TDataGridGroupHeaderBandEh; TreeViewAreaParams: TGridCellTreeViewAreaParamsEh); virtual;
  public
    function CreateCellHolder(): TVPBaseCellHolderEh; override;
    function CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh; override;

    procedure DefaultInitCellProps(Params: TBaseGridInitCellParamsEh); override;
//    procedure DefaultInitCellContent(Params: TDataAxisInitCellContentParamsEh); override;
    procedure DefaultInitCellContent(Params: TBaseGridInitCellContentParamsEh); override;
    procedure InitCell(ACell: TGridBaseCellEh); override;
    procedure InitCellPositionProps(ACell: TGridBaseCellEh); override;
    procedure DefaultInitCell(Params: TBaseGridInitCellParamsEh); override;

    procedure ProcessDblClick(AGrid: TControl; ACell: TGridBaseCellEh; Params: TControlParamsEh); override;
  end;

{ TDataGridGroupHeaderBandEh }

  TDataGridGroupHeaderBandEh = class(TGridBaseCellEh)
  private
    FTreeViewArea: TGridCellTreeViewAreaControlEh;
    FCellContent: TLaObjectEh;
    FRow: TDataGridGroupHeaderRowEh;

    function GetRow: TDataGridGroupHeaderRowEh;

  protected
    function CreateCellClientControls(AParent: TLaObjectEh): TLaObjectEh; override;

    procedure TreeSignMouseDown(Sender: TObject; Params: TControlMouseButtonParamsEh);
  public
    constructor Create(ACellHolder: TGridBaseCellHolderEh);
    destructor Destroy; override;

    property Row: TDataGridGroupHeaderRowEh read GetRow;
    property TreeViewArea: TGridCellTreeViewAreaControlEh read FTreeViewArea;
  end;

implementation

{$REGION 'uses'}
uses EhLibFmx.CustomDataGrids,
     EhLibFmx.DataGrid.DataGroupingPanels;
{$ENDREGION 'uses'}

type
  TCustomDataGridEhCrack = class(TCustomDataGridEh);
  TDataGridRowEhCrack = class(TDataGridRowEh);

{$REGION 'TDataGridGroupHeaderRowEh'}

{ TDataGridGroupHeaderRowEh }

constructor TDataGridGroupHeaderRowEh.Create(AGrid: TComponent);
begin
  inherited Create(AGrid);

  FChildRowList := TList<TDataGridRowEh>.Create;
  FChildRows := TReadonlyList<TDataGridRowEh>.Create(FChildRowList);

  FFooterList := TList<TDataGridGroupFooterRowEh>.Create;
  FFooters := TDataGridGroupFootersEh.Create(FFooterList);
end;

destructor TDataGridGroupHeaderRowEh.Destroy;
begin
  FreeAndNil(FChildRows);
  FreeAndNil(FChildRowList);
  SetFooterRowCount(0);
  FreeAndNil(FFooters);
  FreeAndNil(FFooterList);
  inherited Destroy;
end;

procedure TDataGridGroupHeaderRowEh.DeleteChildrenRows;
var
  I: Integer;
  Row: TDataGridRowEh;
begin
  for I := FChildRowList.Count - 1 downto 0 do
  begin
    Row := FChildRowList[I];
    if Row is TDataGridGroupHeaderRowEh then
      TDataGridGroupHeaderRowEh(Row).DeleteChildrenRows();
    Row.Free;
    FChildRowList[I] := nil;
  end;
  FChildRowList.Clear();
end;

procedure TDataGridGroupHeaderRowEh.DeleteChildrenDataRows();
var
  I: Integer;
  Row: TDataGridRowEh;
  DataRowsDeleted: Boolean;
begin
  DataRowsDeleted := False;
  for I := FChildRowList.Count - 1 downto 0 do
  begin
    Row := FChildRowList[I];
    if Row is TDataGridGroupHeaderRowEh then
      TDataGridGroupHeaderRowEh(Row).DeleteChildrenRows();
    if Row is TDataGridDataRowEh then
    begin
      Row.Free;
      FChildRowList[I] := nil;
      DataRowsDeleted := True;
    end;
  end;
  if DataRowsDeleted = True then
    FChildRowList.Clear();
end;

function TDataGridGroupHeaderRowEh.GetLevel: Integer;
var
  Parent: TDataGridRowEh;
begin
  Parent := ParentRow;
  Result := 0;
  while Parent <> nil do
  begin
    Parent := Parent.ParentRow;
    Result := Result + 1;
  end;
end;

function TDataGridGroupHeaderRowEh.GetParentRow: TDataGridGroupHeaderRowEh;
begin
  Result := TDataGridGroupHeaderRowEh(inherited ParentRow);
end;

procedure TDataGridGroupHeaderRowEh.SetFooterRowCount(AFooterRowCount: Integer);
var
  I: Integer;
  VFooterRow: TDataGridGroupFooterRowEh;
begin
  if AFooterRowCount > FFooterList.Count then
  begin
    for I := FFooterList.Count to AFooterRowCount - 1 do
    begin
      VFooterRow := TDataGridGroupFooterRowEh.Create(FGrid);
      VFooterRow.FInTotalFootersRowIndex := I;
      VFooterRow.FParentRow := Self;
      FFooterList.Add(VFooterRow);
    end;
  end else
  begin
    for I := FFooterList.Count - 1 downto AFooterRowCount do
    begin
      FFooterList[I].Free;
      FFooterList[I] := nil;
      FFooterList.Delete(I);
    end;
  end;
end;

procedure TDataGridGroupHeaderRowEh.SetFooterColCount(AFooterColCount: Integer);
var
  I: Integer;
  VFooterRow: TDataGridGroupFooterRowEh;
begin
  for I := 0 to FFooterList.Count - 1 do
  begin
    VFooterRow := FFooterList[I];
    VFooterRow.SetFooterValuesSize(AFooterColCount);
  end;
end;

procedure TDataGridGroupHeaderRowEh.SetIsExpanded(const Value: Boolean);
begin
  if FIsExpanded <> Value then
  begin
    FIsExpanded := Value;
    ExpandedChanged();
  end;
end;

procedure TDataGridGroupHeaderRowEh.ExpandedChanged;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  Grid.DataGrouping.RowExpandedStateChanged(Self);
end;

{$ENDREGION 'TDataGridGroupHeaderRowEh'}

{$REGION 'TDataGridGroupFooterRowEh'}

{ TDataGridGroupFooterRowEh }

constructor TDataGridGroupFooterRowEh.Create(AGrid: TComponent);
begin
  inherited Create(AGrid);
end;

destructor TDataGridGroupFooterRowEh.Destroy;
begin
  inherited Destroy;
end;

function TDataGridGroupFooterRowEh.GetColumnValue(AColIndex: Integer): TValue;
begin
end;

function TDataGridGroupFooterRowEh.GetFooterValue(AColumn: TDataGridBaseColumnEh): TValue;
var
  VGrid: TCustomDataGridEhCrack;
  ColIndex: Integer;
begin
  VGrid := TCustomDataGridEhCrack(FGrid);
  ColIndex := VGrid.Columns.IndexOf(AColumn);
  Result := FFooterValues[ColIndex];
end;

function TDataGridGroupFooterRowEh.GetLevel: Integer;
begin
  if (ParentRow <> nil)
    then Result := TDataGridGroupHeaderRowEh(ParentRow).Level + 1
    else Result := -1;
end;

procedure TDataGridGroupFooterRowEh.SetFooterValuesSize(ANewSize: Integer);
begin
  SetLength(FFooterValues, ANewSize);
end;

{$ENDREGION 'TDataGridGroupFooterRowEh'}

{$REGION 'TDataGridGroupingTreeListEh'}

{ TDataGridGroupingTreeListEh }

constructor TDataGridGroupingTreeListEh.Create;
begin
  inherited Create;

  FChildRowList := TList<TDataGridRowEh>.Create;
  FChildRows := TReadonlyList<TDataGridRowEh>.Create(FChildRowList);

//  FBaseFlatList := TList<TDataGridRowEh>.Create;
//  FFlatList := TReadonlyList<TDataGridRowEh>.Create(FBaseFlatList);
end;

destructor TDataGridGroupingTreeListEh.Destroy;
begin
  FreeAndNil(FChildRows);
  FreeAndNil(FChildRowList);
//  FreeAndNil(FFlatList);
//  FreeAndNil(FBaseFlatList);

  inherited Destroy;
end;

procedure TDataGridGroupingTreeListEh.ForAllTreeChildRows(NodeMethod: TDataGridRowProcedureEh);

  procedure ForAllChildRows(AChildRowList: TList<TDataGridRowEh>);
  var
    I: Integer;
    Row: TDataGridRowEh;
  begin
    for I := 0 to AChildRowList.Count - 1 do
    begin
      Row := AChildRowList[I];
      NodeMethod(Row);
//       and (TDataGridGroupHeaderRowEh(Row).IsExpanded = True)
      if (Row is TDataGridGroupHeaderRowEh) then
        ForAllChildRows(TDataGridGroupHeaderRowEh(Row).FChildRowList);
    end;
  end;

begin
  ForAllChildRows(FChildRowList);
end;

{$ENDREGION 'TDataGridGroupingTreeListEh'}

{$REGION 'TDataGridGroupDescriptionEh'}

{ TDataGridGroupDescriptionEh }

constructor TDataGridGroupDescriptionEh.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  SetHeightRecalcNeeded();
end;

destructor TDataGridGroupDescriptionEh.Destroy;
begin
  inherited Destroy;
end;

function TDataGridGroupDescriptionEh.GetCollection: TDataGridGroupDescriptionsEh;
begin
  Result := TDataGridGroupDescriptionsEh(inherited Collection);
end;

function TDataGridGroupDescriptionEh.GetDisplayName: string;
begin
  Result := inherited GetDisplayName();
end;

function TDataGridGroupDescriptionEh.GetFill: TBrush;
begin
  if (Collection <> nil)
    then Result := Collection.DataGrouping.Fill
    else Result := nil;
end;

function TDataGridGroupDescriptionEh.GetFont: TFont;
begin
  if (Collection <> nil)
    then Result := Collection.DataGrouping.Font
    else Result := nil;
end;

function TDataGridGroupDescriptionEh.GetFontColor: TAlphaColor;
begin
  if (Collection <> nil)
    then Result := Collection.DataGrouping.FontColor
    else Result := TAlphaColorRec.Null;
end;

procedure TDataGridGroupDescriptionEh.SetColumn(const Value: TDataGridBaseColumnEh);
begin
  if FColumn <> Value then
  begin
    FColumn := Value;
    if FColumn <> nil
      then FColumnName := FColumn.Name
      else FColumnName := '';
    Changed(False);
  end;
end;

procedure TDataGridGroupDescriptionEh.SetColumnName(const Value: String);
begin
  if FColumnName <> Value then
  begin
    FColumnName := Value;
    if (Collection <> nil) and (TCustomDataGridEhCrack(Collection.Grid).IsLoading = False) then
    begin
      Column := TCustomDataGridEhCrack(Collection.Grid).Columns.FindColByName(Value);
    end else
    begin
      Column := nil;
    end;
  end;
end;

function TDataGridGroupDescriptionEh.GetKeyValueForTableRow(ATableRow: TDataGridTableRowEh): TValue;
begin
  if Column <> nil
    then Result := Column.GetListItemValue(ATableRow)
    else Result := TValue.Empty;
end;

procedure TDataGridGroupDescriptionEh.CheckRecalcHeight;
var
  Height: Single;
  Grid: TCustomDataGridEhCrack;
  CellLaObject: TVPBaseCellHolderEh;
  QrCellSize: TSizeF;
  ResCellSize: TSizeF;
  ACellManager: TVPBaseCellManagerEh;
begin
  if (FHeightRecalcNeeded = True) and (Collection <> nil) then
  begin

    Grid := TCustomDataGridEhCrack(Collection.DataGrouping.Grid);

    QrCellSize := TSizeF.Create(100, TLaControlEh.MaxSize.Height);
    ACellManager := Collection.DataGrouping.GetGroupHeaderRowManagerForRow(nil);
    CellLaObject := ACellManager.CreateCellHolder;
    try
      ResCellSize := ACellManager.InitAndCaclRenderCellHolder(
        Grid, QrCellSize, CellLaObject, -1, -1, Column.VisibleIndex, 0);

      Height := ResCellSize.Height;
    finally
      CellLaObject.Free;
    end;

    FDefaultRowHeight := Round(Height);
    FHeightRecalcNeeded := True;
  end;
end;

function TDataGridGroupDescriptionEh.GetDefaultRowHeight: Integer;
begin
  Result := FDefaultRowHeight;
end;

procedure TDataGridGroupDescriptionEh.SetHeightRecalcNeeded;
begin
  FHeightRecalcNeeded := True;
end;

procedure TDataGridGroupDescriptionEh.SetSortOrder(const Value: TSortOrderEh);
var
  Grid: TCustomDataGridEhCrack;
begin
  if FSortOrder <> Value then
  begin
    Grid := TCustomDataGridEhCrack(Collection.DataGrouping.Grid);
    FSortOrder := Value;
    ResortData();
    TCustomDataGridEhCrack(Grid).GroupingPanel.UpdateControlsState();
  end;
end;

procedure TDataGridGroupDescriptionEh.ResortData();
begin
  Collection.DataGrouping.ResortDataInLevel(Self);
end;

function TDataGridGroupDescriptionEh.GetActiveIndex: Integer;
begin
  if Collection <> nil
    then Result := Collection.DataGrouping.ActiveGroupDescriptions.IndexOf(Self)
    else Result := -1;
end;

{$ENDREGION 'TDataGridGroupDescriptionEh'}

{$REGION 'TDataGridGroupDescriptionsEh'}

{ TDataGridGroupDescriptionsEh }

function TDataGridGroupDescriptionsEh.AddDescription(AColumnName: String): TDataGridGroupDescriptionEh;
begin
  BeginUpdate;
  try
    Result := Add;
    Result.ColumnName := AColumnName;
  finally
    EndUpdate;
  end;
end;

function TDataGridGroupDescriptionsEh.AddDescription(AColumn: TDataGridBaseColumnEh): TDataGridGroupDescriptionEh;
begin
  BeginUpdate;
  try
    Result := Add;
    Result.Column := AColumn;
  finally
    EndUpdate;
  end;
end;

constructor TDataGridGroupDescriptionsEh.Create(ADataGrouping: TDataGridDataGroupingEh;
  AItemClass: TCollectionItemClass);
begin
  inherited Create(AItemClass);
  FDataGrouping := ADataGrouping;
end;

function TDataGridGroupDescriptionsEh.Add: TDataGridGroupDescriptionEh;
begin
  Result := TDataGridGroupDescriptionEh(inherited Add);
end;

function TDataGridGroupDescriptionsEh.GetOwner: TPersistent;
begin
  Result := FDataGrouping;
end;

function TDataGridGroupDescriptionsEh.DataGrouping: TDataGridDataGroupingEh;
begin
  Result := FDataGrouping;
end;

function TDataGridGroupDescriptionsEh.GetGrid: TComponent;
begin
  Result := FDataGrouping.Grid;
end;

function TDataGridGroupDescriptionsEh.GetGroupDescription(Index: Integer): TDataGridGroupDescriptionEh;
begin
  Result := TDataGridGroupDescriptionEh(inherited Items[Index]);
end;

procedure TDataGridGroupDescriptionsEh.SetGroupDescription(Index: Integer; const Value: TDataGridGroupDescriptionEh);
begin
end;

procedure TDataGridGroupDescriptionsEh.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  FDataGrouping.GroupDescriptionsChanged(TDataGridGroupDescriptionEh(Item));
end;

procedure TDataGridGroupDescriptionsEh.RefreshDefaultFont;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].SetHeightRecalcNeeded();
end;
{$ENDREGION 'TDataGridGroupDescriptionsEh'}

{$REGION 'TDataGridDataGroupingEh'}

{ TDataGridDataGroupingEh }

constructor TDataGridDataGroupingEh.Create(AGrid: TControl; AVisibleRowList: TList<TDataGridRowEh>);
begin
  inherited Create();
  FGrid := AGrid;
  FGroupDescriptions := TDataGridGroupDescriptionsEh.Create(Self, TDataGridGroupDescriptionEh);
  FActiveGroupDescriptionList := TList<TDataGridGroupDescriptionEh>.Create;
  FActiveGroupDescriptions := TReadonlyList<TDataGridGroupDescriptionEh>.Create(FActiveGroupDescriptionList);

  FTreeList := TDataGridGroupingTreeListEh.Create;
  FFlatRowList := AVisibleRowList;

  FFont := TFont.Create();
  FFont.Assign(DefaultFont());
  FFont.OnChanged := FontChanged;
  FFontStored := False;
  FFontColorStored := False;

  FDefaultFill := TBrush.Create(TBrushKind.None, TAlphaColorRec.Null);

  FFill := TBrush.Create(TBrushKind.None, TAlphaColorRec.Null);
  FFill.Assign(DefaultFill());
  FFill.OnChanged := FillChanged;
  FFillStored := False;

  FGroupDescriptionControlManager := TDataGridGroupDescriptionControlManagerEh.Create(nil);
end;

destructor TDataGridDataGroupingEh.Destroy;
begin
  FreeAndNil(FActiveGroupDescriptionList);
  FreeAndNil(FActiveGroupDescriptions);
  FreeAndNil(FGroupDescriptions);
  FreeAndNil(FTreeList);
  FreeAndNil(FDefaultDataRowCellManager);
  FreeAndNil(FFont);
  FreeAndNil(FFill);
  FreeAndNil(FDefaultFill);
  FreeAndNil(FGroupDescriptionControlManager);
  inherited Destroy;
end;

function TDataGridDataGroupingEh.GetGrid: TControl;
begin
  Result := FGrid;
end;

function TDataGridDataGroupingEh.GetActive: Boolean;
begin
  Result := (ActiveGroupDescriptions.Count > 0);
end;

function TDataGridDataGroupingEh.GetOwner: TPersistent;
begin
  Result := FGrid;
end;

procedure TDataGridDataGroupingEh.GroupDescriptionsChanged(Item: TDataGridGroupDescriptionEh);
var
  VGrid: TCustomDataGridEhCrack;
begin
  VGrid := TCustomDataGridEhCrack(FGrid);
  if csLoading in VGrid.ComponentState then Exit;

  InternalUpdateActiveGroupDescirtion();

  RebuildListView(True);
  if VGrid.GroupingPanel <> nil then
    VGrid.GroupingPanel.GroupDescriptionsChanged();
end;

procedure TDataGridDataGroupingEh.RebuildListView(IsDeleteGroupingHeaders: Boolean);
begin
  if Active
    then RebuildTreeView(IsDeleteGroupingHeaders)
    else RebuildTableView;
end;

procedure TDataGridDataGroupingEh.RowExpandedStateChanged(ARow: TDataGridGroupHeaderRowEh);
begin
  RebuildFlatList;
end;

procedure TDataGridDataGroupingEh.DeleteChildrenRows(Row: TDataGridRowEh);
begin
  if Row is TDataGridGroupHeaderRowEh then
    TDataGridGroupHeaderRowEh(Row).DeleteChildrenRows();
end;

procedure TDataGridDataGroupingEh.DeleteChildrenDataRows(Row: TDataGridRowEh);
begin
  if Row is TDataGridGroupHeaderRowEh then
    TDataGridGroupHeaderRowEh(Row).DeleteChildrenDataRows();
end;

procedure TDataGridDataGroupingEh.ClearViewRows(IsDeleteGroupingHeaders: Boolean);
begin
  if FIsRowsInTree = True then
  begin
    if IsDeleteGroupingHeaders
      then ClearTreeView
      else ClearTreeViewDataRows;
  end else
  begin
    ClearTableView;
  end;
end;

  {$REGION 'Grouping TreeView'}
procedure TDataGridDataGroupingEh.ClearTreeViewDataRows;
var
  I: Integer;
  Row: TDataGridRowEh;
  DataRowsDeleted: Boolean;
begin
  DataRowsDeleted := False;

  for I := FTreeList.FChildRowList.Count - 1 downto 0 do
  begin
    Row := FTreeList.FChildRowList[I];
    DeleteChildrenDataRows(Row);
    if Row is TDataGridDataRowEh then
    begin
      Row.Free;
      FTreeList.FChildRowList[I] := nil;
      DataRowsDeleted := True;
    end;
  end;

  if DataRowsDeleted = True then
    FTreeList.FChildRowList.Clear();
  FFlatRowList.Clear();
end;

procedure TDataGridDataGroupingEh.ClearTreeView;
var
  I: Integer;
  Row: TDataGridRowEh;
begin
  for I := FTreeList.FChildRowList.Count - 1 downto 0 do
  begin
    Row := FTreeList.FChildRowList[I];
    DeleteChildrenRows(Row);
    Row.Free;
    FTreeList.FChildRowList[I] := nil;
  end;

  FTreeList.FChildRowList.Clear();
  FFlatRowList.Clear();
end;

procedure TDataGridDataGroupingEh.RebuildTreeView(IsDeleteGroupingHeaders: Boolean);
begin
  ClearViewRows(IsDeleteGroupingHeaders);
  BuildTreeView();
  BuildFooterRows();
  RebuildFlatList();
end;

procedure TDataGridDataGroupingEh.BuildTreeView;
var
  I, J: Integer;
  TableRows: TDataGridTableRowsEh;
  TableRow: TDataGridTableRowEh;
  CurKeyValue: array of TValue;
begin
  TableRows := TCustomDataGridEhCrack(Grid).TableView.FilteredRowList as TDataGridTableRowsEh;

  SetLength(CurKeyValue, ActiveGroupDescriptions.Count + 1);

  for I := 0 to TableRows.Count - 1 do
  begin
    TableRow := TableRows[I];

    for J := 0 to ActiveGroupDescriptions.Count - 1 do
      CurKeyValue[J] := ActiveGroupDescriptions.Items[J].GetKeyValueForTableRow(TableRow);
    CurKeyValue[ActiveGroupDescriptions.Count] := I;

    AddRecordNodeForKey(CurKeyValue, TableRow);
  end;

  DeleteEmptyGroupingHeaders();

  FIsRowsInTree := True;
end;

function TDataGridDataGroupingEh.AddRecordNodeForKey(AKey: array of TValue; ATableRow: TDataGridTableRowEh): TDataGridDataRowEh;
var
  k: Integer;
  Key1: TValue;
  ParentNode, HeaderNode: TDataGridGroupHeaderRowEh;
  FoundHeaderNode: TDataGridGroupHeaderRowEh;
//  FoundDataNode: TDataGridDataRowEh;
  InsertIndex: Integer;
  GroupDescription: TDataGridGroupDescriptionEh;
begin
  ParentNode := nil;

  // Find and create Headers
  for k := 0 to ActiveGroupDescriptions.Count - 1 do
  begin
    Key1 := AKey[k];
    GroupDescription := ActiveGroupDescriptions[k];

    FoundHeaderNode := TDataGridGroupHeaderRowEh(GetNodeToInsertForKey1(ParentNode, Key1, InsertIndex));
    if FoundHeaderNode <> nil then
    begin
      ParentNode := FoundHeaderNode;
    end else
    begin
      HeaderNode := TDataGridGroupHeaderRowEh.Create(FGrid);
      if ParentNode = nil
        then FTreeList.FChildRowList.Insert(InsertIndex, HeaderNode)
        else ParentNode.FChildRowList.Insert(InsertIndex, HeaderNode);

      HeaderNode.FIsExpanded := IsGroupDefaultExpended;
      HeaderNode.FKeyValue := Key1;
      HeaderNode.FDisplayText := ValueToString(Key1);
      HeaderNode.FParentRow := ParentNode;
      HeaderNode.FGroupDescription := GroupDescription;

      ParentNode := HeaderNode;
    end;
  end;

  // Add data row
  Key1 := AKey[ActiveGroupDescriptions.Count];
  Result := TDataGridDataRowEh.Create(Grid, ATableRow);
  TDataGridRowEhCrack(Result).FParentRow := ParentNode;

  if ParentNode = nil then
  begin
    raise Exception.Create('TDataGridDataGroupingEh.AddRecordNodeForKey: If Grouping is Active then ParentNode can''t be = nil');
  end else
  begin
    ParentNode.FChildRowList.Add(Result);
  end;
end;

function TDataGridDataGroupingEh.GetNodeToInsertForKey1(ParentNode: TDataGridGroupHeaderRowEh; Key1: TValue; var InsertIndex: Integer): TDataGridRowEh;
var
  ChildRows: TReadonlyList<TDataGridRowEh>;
  I: Integer;
  CompareRel: TVariantRelationship;
begin
  Result := nil;
  if ParentNode = nil
    then ChildRows := FTreeList.ChildRows
    else ChildRows := ParentNode.ChildRows;

  InsertIndex := ChildRows.Count;
  if ChildRows.Count = 0 then
    Exit;
  if (ChildRows.Count > 0) and (ChildRows[0] is TDataGridDataRowEh) then
    raise Exception.Create('Call of TDataGridDataGroupingEh.GetNodeToInsertForKey1 for child TDataGridDataRowEh is not supported');

  for I := 0 to ChildRows.Count - 1 do
  begin
    CompareRel := CompareValue(Key1, TDataGridGroupHeaderRowEh(ChildRows[I]).FKeyValue);
    if CompareRel = vrEqual then
    begin
      Result := ChildRows[I];
      InsertIndex := -1;
      Break;
    end
    else if CompareRel = vrLessThan then
    begin
      Result := nil;
      InsertIndex := I;
      Break;
    end;
  end;
end;

procedure TDataGridDataGroupingEh.DeleteEmptyGroupingHeaders();

  function DeleteEmptyGroupingHeadersInList(AChildRowList: TList<TDataGridRowEh>): Integer;
  var
    I: Integer;
    Row: TDataGridRowEh;
    ChildCount: Integer;
  begin
    Result := 0;
    for I := AChildRowList.Count - 1 downto 0 do
    begin
      Row := AChildRowList[I];
      if Row is TDataGridDataRowEh then
      begin
        Result := Result + 1;
      end else
      begin
        if (Row is TDataGridGroupHeaderRowEh) then
        begin
          ChildCount := DeleteEmptyGroupingHeadersInList(TDataGridGroupHeaderRowEh(Row).FChildRowList);
          if ChildCount = 0 then
          begin
            AChildRowList.Delete(I);
            Row.Free;
          end else
          begin
            Result := Result + 1;
          end;
        end;
      end;
    end;
  end;

var
  RootItemsCount: Integer;
begin
  RootItemsCount := DeleteEmptyGroupingHeadersInList(FTreeList.FChildRowList);
  if RootItemsCount = 0 then
    DoNothing();
end;

procedure TDataGridDataGroupingEh.RebuildFlatList;

  procedure AddChildList(AChildRowList: TList<TDataGridRowEh>);
  var
    I, F: Integer;
    Row: TDataGridRowEh;
    HeaderRow: TDataGridGroupHeaderRowEh;
  begin
    for I := 0 to AChildRowList.Count - 1 do
    begin
      Row := AChildRowList[I];
      FFlatRowList.Add(Row);
      if (Row is TDataGridGroupHeaderRowEh) and
         (TDataGridGroupHeaderRowEh(Row).IsExpanded = True) then
      begin
        HeaderRow := TDataGridGroupHeaderRowEh(Row);
        AddChildList(HeaderRow.FChildRowList);

        for F := 0 to HeaderRow.Footers.Count - 1 do
        begin
          FFlatRowList.Add(HeaderRow.Footers[F]);
        end;
      end;
    end;
  end;

begin
  FFlatRowList.Clear;

  AddChildList(FTreeList.FChildRowList);

  TCustomDataGridEhCrack(FGrid).LayoutChanged(True);
end;

procedure TDataGridDataGroupingEh.AddTableRowViewToGroupingList(ARowView: TDataGridTableRowEh);
begin
end;

procedure TDataGridDataGroupingEh.DeleteTableRowViewFromGroupingList(ARowView: TDataGridTableRowEh);
begin
end;

procedure TDataGridDataGroupingEh.BuildFooterRows();
var
  VGrid: TCustomDataGridEhCrack;

  procedure BuildFooterRowsForList(AChildRowList: TList<TDataGridRowEh>);
  var
    I: Integer;
    VRow: TDataGridRowEh;
  begin
    for I := 0 to AChildRowList.Count - 1 do
    begin
      VRow := AChildRowList[I];
      if (VRow is TDataGridGroupHeaderRowEh) then
      begin
        TDataGridGroupHeaderRowEh(VRow).SetFooterRowCount(VGrid.FooterRowCount);
        TDataGridGroupHeaderRowEh(VRow).SetFooterColCount(VGrid.Columns.Count);
        BuildFooterRowsForList(TDataGridGroupHeaderRowEh(VRow).FChildRowList);
      end;
    end;
  end;

begin
  VGrid := TCustomDataGridEhCrack(FGrid);
  BuildFooterRowsForList(FTreeList.FChildRowList);
  RecalcFooters;
end;

procedure TDataGridDataGroupingEh.RecalcFooters;
var
  VGrid: TCustomDataGridEhCrack;

  procedure CalcFooterValuesForDataList(AGroupHeaderRow: TDataGridGroupHeaderRowEh; ADataRowsList: TList<TDataGridDataRowEh>);
  var
    VColumn: TDataGridBaseColumnEh;
    CI: Integer;
    FI: Integer;
    RI: Integer;
    VColFooter: TDataGridBaseColumnFooterEh;
    VGroupFooterRow: TDataGridGroupFooterRowEh;
    VDataRow: TDataGridDataRowEh;
    StepValue: TValue;
  begin
    for CI := 0 to VGrid.Columns.Count - 1 do
    begin
      VColumn := VGrid.Columns[CI];
      for FI := 0 to VGrid.Footer.Rows.Count - 1 do
      begin
        VColFooter := VColumn.Footers.FooterAtRow[FI];
        VGroupFooterRow := AGroupHeaderRow.Footers[FI];
        if (VColFooter <> nil) and (VColFooter.Aggregator <> nil) then
        begin
          VColFooter.ProcessCalcInitData(VGroupFooterRow.FFooterValues[CI], VGrid, VColumn, VColFooter, ADataRowsList.Count);
        end;
      end;
    end;

    for RI := 0 to ADataRowsList.Count - 1 do
    begin
      VDataRow := ADataRowsList[RI];
      for CI := 0 to VGrid.Columns.Count - 1 do
      begin
        VColumn := VGrid.Columns[CI];
        for FI := 0 to VGrid.Footer.Rows.Count - 1 do
        begin
          VColFooter := VColumn.Footers.FooterAtRow[FI];
          VGroupFooterRow := AGroupHeaderRow.Footers[FI];
          if (VColFooter <> nil) and (VColFooter.Aggregator <> nil) then
          begin
            StepValue := VColumn.GetRowValue(VDataRow);
            VColFooter.ProcessCalcStepData(VGroupFooterRow.FFooterValues[CI], StepValue, VGrid, VColumn, VColFooter, VDataRow);
          end;
        end;
      end;
    end;

    for CI := 0 to VGrid.Columns.Count - 1 do
    begin
      VColumn := VGrid.Columns[CI];
      for FI := 0 to VGrid.Footer.Rows.Count - 1 do
      begin
        VColFooter := VColumn.Footers.FooterAtRow[FI];
        VGroupFooterRow := AGroupHeaderRow.Footers[FI];
        if (VColFooter <> nil) and (VColFooter.Aggregator <> nil) then
        begin
          VColFooter.ProcessCalcFinalData(VGroupFooterRow.FFooterValues[CI], VGrid, VColumn, VColFooter);
        end;
      end;
    end;
  end;

  procedure GetAndCalcDataRowsForHeaderRow(AGroupHeaderRow: TDataGridGroupHeaderRowEh; ADataRowsList: TList<TDataGridDataRowEh>);
  var
    I: Integer;
    Row: TDataGridRowEh;
    VGroupHeaderRow: TDataGridGroupHeaderRowEh;
    VDataRowsList: TList<TDataGridDataRowEh>;
  begin
    for I := 0 to AGroupHeaderRow.FChildRowList.Count - 1 do
    begin
      Row := AGroupHeaderRow.FChildRowList[I];
      if Row is TDataGridGroupHeaderRowEh then
      begin
        VGroupHeaderRow := TDataGridGroupHeaderRowEh(Row);
        VDataRowsList := TList<TDataGridDataRowEh>.Create;
        try
          GetAndCalcDataRowsForHeaderRow(VGroupHeaderRow, VDataRowsList);
          ADataRowsList.AddRange(VDataRowsList);
        finally
          VDataRowsList.Free;
        end;
      end
      else if Row is TDataGridDataRowEh then
      begin
        ADataRowsList.Add(TDataGridDataRowEh(Row));
      end;
    end;
    CalcFooterValuesForDataList(AGroupHeaderRow, ADataRowsList);
  end;

  procedure CalcFooterValues(AChildRowList: TList<TDataGridRowEh>);
  var
    I: Integer;
    Row: TDataGridRowEh;
    VDataRowsList: TList<TDataGridDataRowEh>;
  begin
    for I := 0 to AChildRowList.Count - 1 do
    begin
      Row := AChildRowList[I];
      if (Row is TDataGridGroupHeaderRowEh) then
      begin
        VDataRowsList := TList<TDataGridDataRowEh>.Create;
        try
          GetAndCalcDataRowsForHeaderRow(TDataGridGroupHeaderRowEh(Row), VDataRowsList);
        finally
          VDataRowsList.Free;
        end;
      end;
    end;
  end;

begin
  VGrid := TCustomDataGridEhCrack(FGrid);
  CalcFooterValues(FTreeList.FChildRowList);
end;

procedure TDataGridDataGroupingEh.ForAllRows(NodeMethod: TDataGridRowProcedureEh);
begin
  FTreeList.ForAllTreeChildRows(NodeMethod);
end;

  {$ENDREGION 'Grouping TreeView'}

  {$REGION 'Table View'}
procedure TDataGridDataGroupingEh.ClearTableView;
var
  I: Integer;
  Row: TDataGridRowEh;
begin
  for I := FFlatRowList.Count - 1 downto 0 do
  begin
    Row := FFlatRowList[I];
    Row.Free;
    FFlatRowList[I] := nil;
  end;

  FFlatRowList.Clear();
end;

procedure TDataGridDataGroupingEh.RebuildTableView;
var
  I: Integer;
  BaseTableRows: TDataGridTableRowsEh;
  GridDataRow: TDataGridDataRowEh;
  TableRow: TDataGridTableRowEh;
begin
  ClearViewRows(True);

  BaseTableRows := TCustomDataGridEhCrack(Grid).TableView.FilteredRowList as TDataGridTableRowsEh;

  for I := 0 to BaseTableRows.Count - 1 do
  begin
    TableRow := BaseTableRows[I];
    GridDataRow := TDataGridDataRowEh.Create(Grid, TableRow);
    FFlatRowList.Add(GridDataRow);
  end;
  FIsRowsInTree := False;

  TCustomDataGridEhCrack(FGrid).LayoutChanged(True);
end;

procedure TDataGridDataGroupingEh.AddTableRowViewToTableList(ARowView: TDataGridTableRowEh; AIndex: Integer);
var
  GridDataRow: TDataGridDataRowEh;
begin
  GridDataRow := TDataGridDataRowEh.Create(Grid, ARowView);
  FFlatRowList.Insert(AIndex, GridDataRow);
end;

procedure TDataGridDataGroupingEh.DeleteTableRowViewFromTableList(ARowView: TDataGridTableRowEh; AIndex: Integer);
var
  GridDataRow: TDataGridDataRowEh;
begin
  GridDataRow := TDataGridDataRowEh(FFlatRowList.ExtractAt(AIndex));
  if GridDataRow.TableRow <> ARowView then
    raise Exception.Create('TDataGridDataGroupingEh.DeleteTableRowViewFromTableList: The deleted ARowView does not match the grid row');
  GridDataRow.Free;
end;
{$ENDREGION 'Table View'}

  {$REGION 'Font'}
procedure TDataGridDataGroupingEh.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

function TDataGridDataGroupingEh.IsFontStored: Boolean;
begin
  Result := FFontStored;
end;

function TDataGridDataGroupingEh.DefaultFont: TFont;
begin
  Result := TCustomDataGridEhCrack(Grid).Font;
end;

procedure TDataGridDataGroupingEh.FontChanged(Sender: TObject);
begin
  FFontStored := True;
  GroupDescriptions.RefreshDefaultFont;
  InvalidateVisual(True);
end;

procedure TDataGridDataGroupingEh.RefreshDefaultFont;
var
  Save: TNotifyEvent;
begin
  if FontStored then Exit;
  Save := FFont.OnChanged;
  FFont.OnChanged := nil;
  try
    FFont.Assign(DefaultFont);
    TCustomDataGridEhCrack(FGrid).FieldBars.RefreshDefaultFont;
  finally
    FFont.OnChanged := Save;
  end;
end;

procedure TDataGridDataGroupingEh.SetFontStored(const Value: Boolean);
begin
  if FFontStored <> Value then
  begin
    FFontStored := Value;
    InvalidateVisual(True);
  end;
end;
  {$ENDREGION 'Font'}

  {$REGION 'FontColor'}
function TDataGridDataGroupingEh.GetFontColor: TAlphaColor;
begin
  if FontColorStored
    then Result := FFontColor
    else Result := DefaultFontColor();
end;

function TDataGridDataGroupingEh.IsFontColorStored: Boolean;
begin
  Result := FFontColorStored;
end;

procedure TDataGridDataGroupingEh.SetFontColor(const Value: TAlphaColor);
begin
  if FFontColor <> Value then
  begin
    FFontColor := Value;
    FFontColorStored := True;
    InvalidateVisual(False);
  end;
end;

procedure TDataGridDataGroupingEh.SetFontColorStored(const Value: Boolean);
begin
  if FFontColorStored <> Value then
  begin
    FFontColorStored := Value;
    InvalidateVisual(False);
  end;
end;

function TDataGridDataGroupingEh.DefaultFontColor: TAlphaColor;
begin
  if FGrid <> nil
    then Result := TCustomDataGridEhCrack(FGrid).FInternalFontColor
    else Result := SystemFontColor();
end;
  {$ENDREGION 'FontColor'}

  {$REGION 'Fill'}
procedure TDataGridDataGroupingEh.SetFill(const Value: TBrush);
begin
  FFill.Assign(Value);
end;

procedure TDataGridDataGroupingEh.SetFillStored(const Value: Boolean);
begin
  if FFillStored <> Value then
  begin
    FFillStored := Value;
    RefreshDefaultFill;
  end;
end;

procedure TDataGridDataGroupingEh.RefreshDefaultFill;
var
  Save: TNotifyEvent;
begin
  if FFillStored then Exit;
  Save := FFill.OnChanged;
  FFill.OnChanged := nil;
  try
    FFill.Assign(DefaultFill);
  finally
    FFill.OnChanged := Save;
  end;
end;

function TDataGridDataGroupingEh.DefaultFill: TBrush;
begin
  if FGrid <> nil
    then Result := TCustomDataGridEhCrack(FGrid).StylePainter.BackgroundFill
    else Result := FDefaultFill;
end;

function TDataGridDataGroupingEh.IsFillStored: Boolean;
begin
  Result := FFillStored;
end;

procedure TDataGridDataGroupingEh.FillChanged(Sender: TObject);
begin
  FFillStored := True;
  TCustomDataGridEhCrack(FGrid).FieldBars.RefreshDefaultFill;
  InvalidateVisual(False);
end;
  {$ENDREGION 'Fill'}

  {$REGION 'Others'}

procedure TDataGridDataGroupingEh.SetGroupDescriptions(const Value: TDataGridGroupDescriptionsEh);
begin
  FGroupDescriptions.Assign(Value);
end;

procedure TDataGridDataGroupingEh.SetGroupingPanelVisible(const Value: Boolean);
begin
  if FGroupingPanelVisible <> Value then
  begin
    FGroupingPanelVisible := Value;
    TCustomDataGridEhCrack(Grid).LayoutChanged(True);
  end;
end;

procedure TDataGridDataGroupingEh.SetIsGroupDefaultExpended(const Value: Boolean);
begin
  if FIsGroupDefaultExpended <> Value then
  begin
    FIsGroupDefaultExpended := Value;
    RowExpandedStateChanged(nil);
  end;
end;

procedure TDataGridDataGroupingEh.TableViewDataChanged(AChangedType: TTableLinkEventTypeEh;
  NewIndex, OldIndex: Integer; ARowView: TTableRowViewEh);
begin
  if (AChangedType = TTableLinkEventTypeEh.Reset) then
  begin
    RebuildListView(False); //True???
  end
  else if (AChangedType = TTableLinkEventTypeEh.RowAdded) then
  begin
    AddTableRowView(TDataGridTableRowEh(ARowView), NewIndex);
  end
  else if (AChangedType = TTableLinkEventTypeEh.RowDeleted) then
  begin
    DeleteTableRowView(TDataGridTableRowEh(ARowView), OldIndex);
  end
  else if (AChangedType = TTableLinkEventTypeEh.RowChanged) or
          (AChangedType = TTableLinkEventTypeEh.RowStateChanged) then
  begin
  //TODO: If KeyValue of grouping is changed then DeleteTableRowView and AddTableRowView.
//    DeleteTableRowView(ARowView);
//    AddTableRowView(ARowView);
  end
  else if AChangedType = TTableLinkEventTypeEh.CurrentPosChanged then
  begin
  end;
end;

procedure TDataGridDataGroupingEh.AddTableRowView(ARowView: TDataGridTableRowEh; NewIndex: Integer);
begin
  if Active then
    AddTableRowViewToGroupingList(ARowView)
  else
    AddTableRowViewToTableList(ARowView, NewIndex);
end;

procedure TDataGridDataGroupingEh.DeleteTableRowView(ARowView: TDataGridTableRowEh; OldIndex: Integer);
begin
  if Active then
    DeleteTableRowViewFromGroupingList(ARowView)
  else
    DeleteTableRowViewFromTableList(ARowView, OldIndex);
end;

procedure TDataGridDataGroupingEh.ActiveChanged;
begin
end;

function TDataGridDataGroupingEh.GetGroupHeaderRowManagerForRow(
  ARow: TDataGridGroupHeaderRowEh): TVPBaseCellManagerEh;
begin
  if FDefaultDataRowCellManager = nil then
    FDefaultDataRowCellManager := TDataGridGroupHeaderBandManagerEh.Create(nil);
  Result := FDefaultDataRowCellManager;
end;

procedure TDataGridDataGroupingEh.CheckRecalcGroupDescriptionsHeight;
var
  I: Integer;
begin
  for I := 0 to ActiveGroupDescriptions.Count - 1 do
    ActiveGroupDescriptions[I].CheckRecalcHeight();
end;

function TDataGridDataGroupingEh.InGridVertCaptureSize: Integer;
begin
  if GroupingPanelVisible
    then Result := TCustomDataGridEhCrack(Grid).GroupingPanel.CalcAutoHeight
    else Result := 0;
end;

procedure TDataGridDataGroupingEh.InvalidateVisual(CellLayoutAffects: Boolean = False);
begin
  if (Grid <> nil) then
    TCustomDataGridEhCrack(Grid).LayoutChanged(CellLayoutAffects);
end;

procedure SortInList(AChildRowList: TList<TDataGridRowEh>; ASortOrder: TSortOrderEh);
begin
  AChildRowList.Sort(TComparer<TDataGridRowEh>.Construct(
    function(const ALeft, ARight: TDataGridRowEh): Integer
    var
      CompareRel: TVariantRelationship;
      ALeftValue, ARightValue: TValue;
    begin
      ALeftValue := TDataGridGroupHeaderRowEh(ALeft).KeyValue;
      ARightValue := TDataGridGroupHeaderRowEh(ARight).KeyValue;
      CompareRel := CompareValue(ALeftValue, ARightValue);
      if CompareRel = vrLessThan then
        Result := -1
      else if CompareRel = vrGreaterThan then
        Result := 1
      else
        Result := 0;
      if ASortOrder = TSortOrderEh.soDescEh then
        Result := Result * -1;
    end
  ));
end;

procedure TDataGridDataGroupingEh.ResortDataInLevel(AGroupDescription: TDataGridGroupDescriptionEh);

//var
//  ChildRowList: TList<TDataGridRowEh>;
var
  ParentGroupDescription: TDataGridGroupDescriptionEh;
begin
  if AGroupDescription.Index = 0 then
  begin
//    ChildRowList := FTreeList.FChildRowList
    SortInList(FTreeList.FChildRowList, AGroupDescription.SortOrder);
  end else
  begin
    ParentGroupDescription := ActiveGroupDescriptions[AGroupDescription.ActiveIndex - 1];
    FTreeList.ForAllTreeChildRows(
      procedure(Node: TDataGridRowEh)
      begin
        if (Node is TDataGridGroupHeaderRowEh) and
           (TDataGridGroupHeaderRowEh(Node).GroupDescription = ParentGroupDescription)
        then
          SortInList(TDataGridGroupHeaderRowEh(Node).FChildRowList, AGroupDescription.SortOrder);
      end
    )
  end;

  RebuildFlatList();
end;

  {$ENDREGION 'Others'}

{$ENDREGION 'TDataGridDataGroupingEh'}

{$REGION 'TDataGridGroupHeaderBandManagerEh'}

{ TDataGridGroupHeaderBandManagerEh }

function TDataGridGroupHeaderBandManagerEh.CreateCellHolder: TVPBaseCellHolderEh;
begin
  Result := inherited CreateCellHolder();
end;

function TDataGridGroupHeaderBandManagerEh.CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh;
begin
  Result := TDataGridGroupHeaderBandEh.Create(ACellHolder);
end;

procedure TDataGridGroupHeaderBandManagerEh.DefaultInitCellProps(Params: TBaseGridInitCellParamsEh);
begin
  inherited DefaultInitCellProps(Params);
end;

function TDataGridGroupHeaderBandManagerEh.GetDataTreeViewAreaParams(
  ACell: TDataGridGroupHeaderBandEh): TGridCellTreeViewAreaParamsEh;
var
  SignState: TTreeSignStateEh;
  Level: Integer;
begin
  if (ACell.Row <> nil) then
  begin
    if ACell.Row.IsExpanded = True
      then SignState := TTreeSignStateEh.Expanded
      else SignState := TTreeSignStateEh.Collapsed;
    Level := ACell.Row.Level;
  end else
  begin
    SignState := TTreeSignStateEh.Collapsed;
    Level := 0;
  end;

  Result := TGridCellTreeViewAreaParamsEh.Create;
  Result.Init(ACell.Grid, True, 16, Level, SignState, True);
end;

procedure TDataGridGroupHeaderBandManagerEh.InitCell(ACell: TGridBaseCellEh);
begin
  inherited InitCell(ACell);
  InitCellTreeViewArea(TDataGridGroupHeaderBandEh(ACell));
end;

procedure TDataGridGroupHeaderBandManagerEh.InitCellPositionProps(ACell: TGridBaseCellEh);
var
  VGrid: TCustomDataGridEhCrack;
  ARow: TDataGridRowEh;
  AGroupHeaderBand: TDataGridGroupHeaderBandEh;
begin
  inherited InitCellPositionProps(ACell);

  VGrid := TCustomDataGridEhCrack(ACell.Grid);
  AGroupHeaderBand := ACell as TDataGridGroupHeaderBandEh;
  AGroupHeaderBand.FRow := nil;

  if (ACell.AreaRowIndex >= 0) and
     (ACell.AreaRowIndex < VGrid.VisibleRows.Count) then
  begin
    ARow := VGrid.VisibleRows[ACell.AreaRowIndex];
    if ARow is TDataGridGroupHeaderRowEh then
      AGroupHeaderBand.FRow := TDataGridGroupHeaderRowEh(ARow);
  end;
end;

procedure TDataGridGroupHeaderBandManagerEh.DefaultInitCell(Params: TBaseGridInitCellParamsEh);
var
  Band: TDataGridGroupHeaderBandEh;
begin
  inherited DefaultInitCell(Params);
  Band := TDataGridGroupHeaderBandEh(Params.Cell);
  if Band.Row <> nil then
    Params.Cell.Fill := Band.Row.GroupDescription.Fill;
end;

procedure TDataGridGroupHeaderBandManagerEh.DefaultInitCellContent(
  Params: TBaseGridInitCellContentParamsEh);
var
  TextBlock: TLaTextBlockEh;
  Band: TDataGridGroupHeaderBandEh;
  VGrid: TCustomDataGridEhCrack;
begin
  if Params.CellContent is TLaTextBlockEh then
  begin
    VGrid := TCustomDataGridEhCrack(Params.Grid);
    TextBlock := TLaTextBlockEh(Params.CellContent);
    Band := TDataGridGroupHeaderBandEh(Params.Cell);
    if Band.Row <> nil
      then TextBlock.Text := Band.Row.DisplayText + ' (' + Band.Row.ChildRows.Count.ToString + ')'
      else TextBlock.Text := '?';

    if Band.Row <> nil then
    begin
      TextBlock.Font := Band.Row.GroupDescription.Font;
      TextBlock.FontColor := Band.Row.GroupDescription.FontColor;
    end else
    begin
      TextBlock.Font := VGrid.DataGrouping.Font;
      TextBlock.FontColor := VGrid.DataGrouping.FontColor;
    end;
    TextBlock.Margins.Rect := TRectF.Create(2, 4, 2, 4);
    TextBlock.VertAlignment := TLaVertAlignmentEh.Center;
  end;
end;

procedure TDataGridGroupHeaderBandManagerEh.CellTreeSignMouseDown(
  Sender: TObject; Params: TControlMouseButtonParamsEh);
var
  GroupHeaderBand: TDataGridGroupHeaderBandEh;
begin
  if Sender is TDataGridGroupHeaderBandEh then
  begin
    GroupHeaderBand := TDataGridGroupHeaderBandEh(Sender);
    if GroupHeaderBand.Row <> nil then
      GroupHeaderBand.Row.IsExpanded := not GroupHeaderBand.Row.IsExpanded;
  end;
end;

procedure TDataGridGroupHeaderBandManagerEh.InitCellTreeViewArea(
  ACell: TDataGridGroupHeaderBandEh);
var
  TreeViewAreaParams: TGridCellTreeViewAreaParamsEh;
begin
  TreeViewAreaParams := GetDataTreeViewAreaParams(ACell);
  if TreeViewAreaParams = nil then Exit;
  try
    InitTreeViewArea(ACell, TreeViewAreaParams);
  finally
    TreeViewAreaParams.Free;
  end;
end;

procedure TDataGridGroupHeaderBandManagerEh.InitTreeViewArea(
  ACell: TDataGridGroupHeaderBandEh;
  TreeViewAreaParams: TGridCellTreeViewAreaParamsEh);
begin
  if TreeViewAreaParams.TreeAreaVisible then
  begin
    ACell.TreeViewArea.Visible := True;
    ACell.TreeViewArea.CheckCreateControls;
    ACell.TreeViewArea.LevelWidth := TreeViewAreaParams.LevelWidth;
    ACell.TreeViewArea.Level := TreeViewAreaParams.Level;
    ACell.TreeViewArea.SignState := TreeViewAreaParams.SignState;
    ACell.TreeViewArea.SignVisible := TreeViewAreaParams.SignVisible;
  end else
  begin
    ACell.TreeViewArea.Visible := False;
  end;
end;
procedure TDataGridGroupHeaderBandManagerEh.ProcessDblClick(AGrid: TControl;
  ACell: TGridBaseCellEh; Params: TControlParamsEh);
var
  HeaderBand: TDataGridGroupHeaderBandEh;
begin
  inherited ProcessDblClick(AGrid, ACell, Params);
  HeaderBand := TDataGridGroupHeaderBandEh(ACell);
  if (HeaderBand <> nil) and (HeaderBand.Row <> nil) then
    HeaderBand.Row.IsExpanded := not HeaderBand.Row.IsExpanded;
end;

procedure TDataGridDataGroupingEh.InternalUpdateActiveGroupDescirtion;
var
  GroupDesc: TCollectionItem;
begin
  FActiveGroupDescriptionList.Clear;
  for GroupDesc in GroupDescriptions do
  begin
    if TDataGridGroupDescriptionEh(GroupDesc).Column <> nil then
      FActiveGroupDescriptionList.Add(GroupDesc as TDataGridGroupDescriptionEh);
  end;
end;

{$ENDREGION 'TDataGridGroupHeaderBandManagerEh'}

{$REGION 'TDataGridGroupHeaderBandEh'}

{ TDataGridGroupHeaderBandEh }

constructor TDataGridGroupHeaderBandEh.Create(ACellHolder: TGridBaseCellHolderEh);
begin
  inherited Create(ACellHolder);
end;

destructor TDataGridGroupHeaderBandEh.Destroy;
begin
  inherited Destroy;
end;

function TDataGridGroupHeaderBandEh.CreateCellClientControls(
  AParent: TLaObjectEh): TLaObjectEh;
begin
  with TLaGridPanelEh.CreateWith(AParent, AParent) do
  begin
    Result := RefSelf;
    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Auto;
      Value := 0;
    end;

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Weight;
      Value := 1;
    end;

    FTreeViewArea := TGridCellTreeViewAreaControlEh.CreateWith(RefSelf, RefSelf);
    FTreeViewArea.Name := 'TreeViewArea';
    FTreeViewArea.OnTreeSignMouseDown := TreeSignMouseDown;
    ControlCollection.AddControl(FTreeViewArea, 0, -1);

    FCellContent := CreateCellContent(RefSelf);
    if FCellContent <> nil then
    begin
      if CellContent.Name = '' then
        CellContent.Name := 'CellContent';
      ControlCollection.AddControl(FCellContent, 1, -1);
    end;
  end;
end;

function TDataGridGroupHeaderBandEh.GetRow: TDataGridGroupHeaderRowEh;
begin
  Result := FRow;
end;

procedure TDataGridGroupHeaderBandEh.TreeSignMouseDown(Sender: TObject;
  Params: TControlMouseButtonParamsEh);
begin
  if (FTreeViewArea.Visible = True) and (FTreeViewArea.SignVisible = True) then
    TDataGridGroupHeaderBandManagerEh(CellManager).CellTreeSignMouseDown(Self, Params);
end;
{$ENDREGION 'TDataGridGroupHeaderBandEh'}

end.

