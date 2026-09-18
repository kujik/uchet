{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{              EhLibFmx.DataGrid.Columns                }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataGrid.Columns;

{$I ..\Incl\EhLib.Inc}
{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, System.Types,
  FMX.Graphics, System.UITypes, System.Math, FMX.Forms, System.Contnrs,
  FMX.Platform, Data.DB, System.Variants,
  System.Generics.Collections, System.Generics.Defaults, System.Rtti,
  EhLibUtils,
  DBUtilsEh,
  MemTreeEh,
  EhLib.TableLinks,
  EhLib.GridTableViews,
  EhLibFmx.Types,
  EhLibFmx.LaObjects,
  EhLibFmx.LaControls,
  EhLibFmx.LaHostVirtualPanels,
  EhLibFmx.ToolControls,
  EhLibFmx.Grid.ToolControls,
  EhLibFmx.Grid.CellManagers,

  EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.DataAxisGrid.ToolControls,
  EhLibFmx.DataAxisGrid.DataCells,
  EhLibFmx.DataAxisGrids,

  EhLibFmx.DataGrid.Footers,
  EhLibFmx.DataGrid.TitleFilters,
  EhLibFmx.DataGrid.Rows,
  EhLibFmx.DataGrid.ComplexTitles,

  EhLibFmx.Grid.Types,
  EhLibFmx.Grids;

type
  TStaticColumnsEh = class;
  TDataGridBaseColumnEh = class;

  TDataGridDataCellButtonMouseEventEventEh = procedure (Sender: TObject; Params: TControlMouseButtonParamsEh) of object;
  TCheckColumnValueAcceptEventEh = procedure (AColumn: TDataGridBaseColumnEh; ARow: TDataGridRowEh; var Accept: Boolean; SearchText: String) of object;
  TColumnSortCompareEh = reference to function (const Left, Right: TDataGridBaseColumnEh): Integer;

{ TColumnFieldBarEnumerator }

  TColumnFieldBarEnumerator = class(TEnumerator<TDataGridBaseColumnEh>)
  private
    FFieldBarEnumerator: TEnumerator<TFieldBarEh>;
  protected
    function DoGetCurrent: TDataGridBaseColumnEh; override;
    function DoMoveNext: Boolean; override;
  public
    constructor Create(AFieldBarEnumerator: TEnumerator<TFieldBarEh>);
    destructor Destroy; override;

    property Current: TDataGridBaseColumnEh read DoGetCurrent;
  end;

{ TDataGridDataCellParamsEh }

  TDataGridDataCellParamsEh = class(TPersistent)
  private
    FColumn: TDataGridBaseColumnEh;

  public
    property Column: TDataGridBaseColumnEh read FColumn;
  end;

{ TBaseDataGridDataCellParamsEh }

  TBaseDataGridGetDataCellManagerParamsEh = class(TPersistent)
  private
    FColumn: TDataGridBaseColumnEh;
    FRow: TDataGridRowEh;
    FGrid: TControl;
    FCellManager: TBaseGridCellManagerEh;

  public
    procedure Init(AGrid: TControl; AColumn: TDataGridBaseColumnEh; ARow: TDataGridRowEh; ADefaultCellManager: TBaseGridCellManagerEh); virtual;

    property Grid: TControl read FGrid;
    property Column: TDataGridBaseColumnEh read FColumn;
    property Row: TDataGridRowEh read FRow;
    property CellManager: TBaseGridCellManagerEh read FCellManager write FCellManager;
  end;

{ TDataGridGetCheckBoxStateParamsEh }

  TDataGridGetCheckBoxStateParamsEh = class(TDataGridDataCellParamsEh)
  private
    FState: TCheckBoxStateEh;
    FHandled: Boolean;
  public
    property State: TCheckBoxStateEh read FState write FState;
    property Handled: Boolean read FHandled write FHandled;
  end;

{ TColumnsListEh }

  TColumnsListEh = class(TFieldBarsListEh)
  private
    function GetColumn(Index: TListItemIndex): TDataGridBaseColumnEh;
    procedure SetColumn(Index: TListItemIndex; const Value: TDataGridBaseColumnEh);
  public
    constructor Create; overload;

    property Items[Index: TListItemIndex]: TDataGridBaseColumnEh read GetColumn write SetColumn; default;
  end;

{ TColumnTitleEh }

  TColumnTitleEh = class(TFieldBarTitleEh)
  private
    FFilterItem: TSTColumnFilterEh;

    function GetColumn: TDataGridBaseColumnEh;
    procedure SetFilterItem(const Value: TSTColumnFilterEh);

  protected
    FComplexTitleNode: TDataGridComplexTitleTreeNodeEh;
    FContentRect: TRect;
    FFilterButtonAreaRect: TRect;
    FFilterButtonRect: TRect;
    FFilterDropDownForm: TForm;
    FMouseInFilterButtonRect: Boolean;
    FSortMarkerRectArea: TRect;

    function CreateFilterItem: TSTColumnFilterEh; virtual;
    function GetComplexTitleNode: TDataGridComplexTitleTreeNodeEh;

    procedure HandleGetCellManager(Params: TPersistent); virtual;
    procedure HandleInitCellContent(Params: TPersistent); virtual;

  public
    constructor Create(FieldBar: TFieldBarEh);
    destructor Destroy; override;

    function CalcAutoWidth: Integer;
    function CalcCellHeight(ACanvas: TCanvas; ACellWidth: Integer): Integer;
    function CalcNeededCellWidth(ACanvas: TCanvas): Integer;
    function FilterButtonIsVisible: Boolean;
    function FilterFormIsVisible: Boolean;
    function GetCellManager: TBaseGridCellManagerEh; virtual;
    function GetSortMarkerParams(out SortOrder: TSortOrderEh; out SortIndex: Integer): Boolean;

    procedure PrepareToDestroy;
    procedure RecalcFilterButtonRect(ACanvas: TCanvas; ACellRect: TRect; out AFilterAreaWidth: Integer);
    procedure RecalcSortMarkerAreaRect(ACanvas: TCanvas; ACellRect: TRect; out ASortMarkerAreaWidth: Integer);
    procedure RecalcTitleCellMetrics(ACanvas: TCanvas; ACellRect: TRect);

    property Column: TDataGridBaseColumnEh read GetColumn;
    property ComplexTitleNode: TDataGridComplexTitleTreeNodeEh read GetComplexTitleNode;

  published
    property FilterItem: TSTColumnFilterEh read FFilterItem write SetFilterItem;
  end;

{ TDataGridBaseColumnEh }

  TDataGridBaseColumnEh = class(TFieldBarEh)
  private
    FColSizeUnit: TGridColSizeUnitEh;
    FColSizeUnitStored: Boolean;
    FFooters: TDataGridBaseColumnFootersEh;
    FWidth: Single;
    FWidthStored: Boolean;
    FFrozenPosition: TColumnFrozenPositionEh;

    function GetActualWidth: Integer;
    function GetColSizeUnit: TGridColSizeUnitEh;
    function GetIsSelected: Boolean;
    function GetTitle: TColumnTitleEh;
    function GetWidth: Single;
    function IsColSizeUnitStored: Boolean;
    function IsWidthStored: Boolean;

    procedure SetColSizeUnit(const Value: TGridColSizeUnitEh);
    procedure SetColSizeUnitStored(const Value: Boolean);
    procedure SetFooters(const Value: TDataGridBaseColumnFootersEh);
    procedure SetIsSelected(const Value: Boolean);
    procedure SetTitle(const Value: TColumnTitleEh);
    procedure SetWidth(const Value: Single);
    procedure WidthChanged;
    procedure SetFrozenPosition(const Value: TColumnFrozenPositionEh);

  protected
    FActualWidth: Integer;
    FDefCellManager: TBaseGridCellManagerEh;
    FIsInitWidthPerformed: Boolean;
    FIsSelectedInternal: Boolean;
    FSizeCalculatorCellObject: TVPBaseCellHolderEh;

    function CreateTitle: TFieldBarTitleEh; override;
    function GetCellManagerAtListItemBar(AListItemBar: TTableRowViewEh): TBaseGridCellManagerEh; override;
    function IsShowSelectionLayer(ACell: TGridBaseCellEh): Boolean; override;

    function CreateCellManager: TBaseGridCellManagerEh; virtual;
    function CreateFooters: TDataGridBaseColumnFootersEh; virtual;
    function CreateGetCellManagerParams(): TBaseDataGridGetDataCellManagerParamsEh; virtual;
    function DefaultColSizeUnit(): TGridColSizeUnitEh; virtual;

    procedure DoBeforeFirstDrawing; override;
    procedure FieldChanged; override;
    procedure FieldNameChanged; override;
    procedure LinkActiveChanged; override;
    procedure RefreshDefaultPadding(); override;
    procedure SetParentComponent(Value: TComponent); override;
    procedure UpdateDefaults; override;

    procedure CheckInitWidth;
    procedure HandleCreateCellContent(Params: TBaseGridCreateCellContentParamsEh); override;
    procedure HandleGetDataCellManager(Params: TBaseDataGridGetDataCellManagerParamsEh); virtual;
    procedure HandleInitDataCell(Params: TPersistent); virtual;
    procedure HandleDataCellInitContent(Params: TBaseGridInitCellContentParamsEh); override;
    procedure FrozenPositionChanged; virtual;

    procedure HeightAutoExpandChanged(); override;
    procedure InitWidth;
    procedure ProcessGetCellManager(Params: TBaseDataGridGetDataCellManagerParamsEh); virtual;

  public
    constructor Create(AOwner: TComponent); overload; override;
    constructor CreateWith(AOwner: TComponent; AParent: TComponent); overload;

    destructor Destroy; override;

    function HasParent: Boolean; override;
    function GetParentComponent: TComponent; override;

    function CalcDefaultRowHeight(Canvas: TCanvas): Integer;
    function CalcNeededDataCellWidth(ACanvas: TCanvas; ADataRowIndex: Integer): Integer;
    function CalcRowHeight(ACanvas: TCanvas; ADataRowIndex: Integer): Integer;
    function CellHeightIsRowDependent(): Boolean;
    function DefaultWidth: Single; virtual;
    function GetCellManager(): TBaseGridCellManagerEh; virtual;
    function GetCellManagerAt(ADataRowIndex: Integer): TBaseGridCellManagerEh; virtual;
    function GetCellManagerAtRow(ARow: TDataGridRowEh): TBaseGridCellManagerEh; virtual;

    function GetRowValue(ARow: TDataGridRowEh): TValue;
    function GetRowDisplayText(ARow: TDataGridRowEh): String;
    function CanModifyCellValue(ARow: TDataGridRowEh): Boolean; reintroduce;
    function GetRowEditText(ARow: TDataGridRowEh): String;

    procedure ClampInView;
    procedure InitCell(ACell: TGridBaseCellEh; AStyleParams: TDataAxisCellStyleParamsEh); override;
    procedure DefaultInitCellEditor(AParams: TBaseGridInitEditorParamsEh); virtual;
    procedure MTViewDataEvent(RowNum: Integer; Event: TMTViewEventTypeEh; OldRowNum: Integer);
    procedure OptimizeWidth; virtual;
    procedure RemoveColumn(); virtual;

    property IsSelected: Boolean read GetIsSelected write SetIsSelected;
    property ActualWidth: Integer read GetActualWidth;
    property FrozenPosition: TColumnFrozenPositionEh read FFrozenPosition write SetFrozenPosition default TColumnFrozenPositionEh.None;

  published

    property ColSizeUnit: TGridColSizeUnitEh read GetColSizeUnit write SetColSizeUnit stored IsColSizeUnitStored;
    property ColSizeUnitStored: Boolean read FColSizeUnitStored write SetColSizeUnitStored default False;
    property FieldName;
    property Fill;
    property FillStored;
    property Font;
    property FontColor;
    property FontColorStored;
    property FontStored;
    property Footers: TDataGridBaseColumnFootersEh read FFooters write SetFooters;
    property HeightAutoExpand;
    property HeightAutoExpandStored;
    property HorzAlign;
    property HorzAlignStored;
    property Padding;
    property PaddingStored;
    property PopupMenu;
    property ReadOnly;
    property Title: TColumnTitleEh read GetTitle write SetTitle;
    property Tooltips;
    property TooltipsStored;
    property VertAlign;
    property VertAlignStored;
    property Visible;
    property Width: Single read GetWidth write SetWidth stored IsWidthStored;
  end;

  TColumnEhClass = class of TDataGridBaseColumnEh;

{ TStaticColumnsEh }

  TStaticColumnsEh = class(TGridStaticFieldBarsEh)
  private
    function GetColumn(Index: Integer): TDataGridBaseColumnEh;
  protected
  public
    constructor Create(AGrid: TCustomGridEh); reintroduce; virtual;
    destructor Destroy; override;

    procedure RemoveColumn(Column: TDataGridBaseColumnEh);
    procedure SetOrder(Columns: TArray<TDataGridBaseColumnEh>);
    procedure CreateAllFromDynamic();

    procedure Add(Column: TDataGridBaseColumnEh);
    property Column[Index: Integer]: TDataGridBaseColumnEh read GetColumn; default;
  end;

{ TDataGridAllColumnsEh }

  TDataGridAllColumnsEh = class(TGridAllFieldBarListEh)
  private
    function GetItem(Index: Integer): TDataGridBaseColumnEh;

  protected

  public
    procedure RefreshTitleDefaultFont; override;
    procedure RefreshTitleDefaultPadding; override;
    procedure RefreshTitleDefaultFill; override;

    function ColByFieldName(FieldName: String): TDataGridBaseColumnEh;
    function ColByName(ColName: String): TDataGridBaseColumnEh;

    function FindColByFieldName(FieldName: String): TDataGridBaseColumnEh;
    function FindColByName(ColName: String): TDataGridBaseColumnEh;

    procedure RecalcFooterValues;

    procedure RefreshFooterDefaultFill; virtual;
    procedure RefreshFooterDefaultFont; virtual;

    property Items[Index: Integer]: TDataGridBaseColumnEh read GetItem; default;
  end;

{ TDataGridDisplayColumnsEh }

  TDataGridDisplayColumnsEh = class(TGridDisplayFieldBarsEh)
  private
    function GetItem(Index: Integer): TDataGridBaseColumnEh;

  protected
    function CompareFieldBarOrder(const ALeft, ARight: TFieldBarEh): Integer; override;
    procedure ReorderList(NewOrderList: TList<TFieldBarEh>); override;

  public
    constructor Create(AGrid: TControl; AList: TList<TFieldBarEh>);
    destructor Destroy; override;
    procedure SetColumnsOrder(AOrderedList: TList<TDataGridBaseColumnEh>); overload;

    property Items[Index: Integer]: TDataGridBaseColumnEh read GetItem; default;
  end;

{ TDataGridVisibleColumnsEh }

  TDataGridVisibleColumnsEh = class(TGridVisibleFieldBarsEh)
  private
    function GetItem(Index: Integer): TDataGridBaseColumnEh;
  public
    constructor Create(AGrid: TControl; AList: TList<TFieldBarEh>);
    destructor Destroy; override;

    function GetFirstTabColumn: TDataGridBaseColumnEh;
    function GetLastTabColumn: TDataGridBaseColumnEh;
    function GetNextTabColumn(ForColumn: TDataGridBaseColumnEh; GoForward: Boolean): TDataGridBaseColumnEh;
    function GetEnumerator: TColumnFieldBarEnumerator;

    procedure MoveColumn(Column: TDataGridBaseColumnEh; NewVisibleIndex: Integer);
    procedure MoveColumns(ColumnList: TColumnsListEh; NewVisibleIndex: Integer);
    procedure UpdateActualWidths();
    procedure UpdateTitleMetrics();

    property Items[Index: Integer]: TDataGridBaseColumnEh read GetItem; default;
  end;

{ TDataGridDynamicColumnsEh }

  TDataGridDynamicColumnsEh = class(TGridDynamicFieldBarsEh)
  protected
  public
    constructor Create(AGrid: TControl; AList: TList<TFieldBarEh>);
    destructor Destroy; override;

    function GetColumnClassByField(AField: TTableFieldLinkEh): TFieldBarEhClass; override;
  end;

implementation

uses
  EhLibFmx.CustomDataGrids,
  EhLibFmx.DataGrid.ToolControls,
  EhLibFmx.DataGrid.DataCells,
  EhLibFmx.DataGrid.Titles,
  EhLibFmx.DataGrid.FilterForm;

type
  TCustomDataGridEhCrack = class(TCustomDataGridEh);
  TColumnFootersEhCrack = class(TDataGridBaseColumnFootersEh);
  TDataGridSuperTitleEhCrack = class(TDataGridSuperTitleEh);
  TDataGridComplexTitleTreeListEhCrack = class(TDataGridComplexTitleTreeListEh);
  TColumnTitleEhCrack = class(TColumnTitleEh);

{$REGION 'TColumnsListEh'}

{ TColumnsListEh }

constructor TColumnsListEh.Create;
begin
  inherited Create;
end;

function TColumnsListEh.GetColumn(Index: TListItemIndex): TDataGridBaseColumnEh;
begin
  Result := TDataGridBaseColumnEh(inherited Items[Index]);
end;

procedure TColumnsListEh.SetColumn(Index: TListItemIndex; const Value: TDataGridBaseColumnEh);
begin
  inherited Items[Index] := Value;
end;

{$ENDREGION 'TColumnsListEh'}

{$REGION 'TStaticColumnsEh'}

{ TStaticColumnsEh }

constructor TStaticColumnsEh.Create(AGrid: TCustomGridEh);
begin
  inherited Create(AGrid);
end;

destructor TStaticColumnsEh.Destroy;
begin
  inherited Destroy;
end;

procedure TStaticColumnsEh.Add(Column: TDataGridBaseColumnEh);
begin
  inherited Add(Column);
end;

function TStaticColumnsEh.GetColumn(Index: Integer): TDataGridBaseColumnEh;
begin
  Result := TDataGridBaseColumnEh(FieldBar[Index]);
end;

procedure TStaticColumnsEh.RemoveColumn(Column: TDataGridBaseColumnEh);
begin
  InternalRemove(Column);
end;

procedure TStaticColumnsEh.SetOrder(Columns: TArray<TDataGridBaseColumnEh>);
var
  I: Integer;
  FieldBars: TArray<TFieldBarEh>;
begin
  SetLength(FieldBars, Length(Columns));
  for I := 0 to Length(Columns) - 1 do
    FieldBars[I] := Columns[I];
  inherited SetOrder(FieldBars);
end;

procedure TStaticColumnsEh.CreateAllFromDynamic;
var
  NewFieldList: TList<TTableFieldLinkEh>;
  Field: TTableFieldLinkEh;
  I: Integer;
  FieldBar: TDataGridBaseColumnEh;
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Self.Grid);
  NewFieldList := TList<TTableFieldLinkEh>.Create;

  if (Grid.TableView.Active = True) then
  begin
    for I := 0 to Grid.TableView.Fields.Count - 1 do
    begin
      Field := Grid.TableView.Fields[I];
      if (IndexOfByFieldName(Field.FieldName) = -1) then
        NewFieldList.Add(Field);
    end;
  end;

  for I := 0 to NewFieldList.Count - 1 do
  begin
    FieldBar := Grid.CreateFieldBarByField(NewFieldList[I]) as TDataGridBaseColumnEh;
    FieldBar.FieldName := NewFieldList[I].FieldName;
    Self.Add(FieldBar);
  end;

  NewFieldList.Free;
end;

{$ENDREGION 'TStaticColumnsEh'}

{$REGION 'TDataGridAllColumnsEh'}

{ TDataGridAllColumnsEh }

function TDataGridAllColumnsEh.FindColByFieldName(FieldName: String): TDataGridBaseColumnEh;
var
  I: Integer;
  Column: TDataGridBaseColumnEh;
begin
  Result := nil;

  for I := 0 to Count - 1 do
  begin
    Column := Items[I];
    if Column.FieldName = FieldName then
    begin
      Result := Column;
      Exit;
    end;
  end;
end;

function TDataGridAllColumnsEh.ColByFieldName(FieldName: String): TDataGridBaseColumnEh;
begin
  Result := FindColByFieldName(FieldName);

  if Result = nil then
    raise Exception.Create('TDataGridAllColumnsEh.ColByFieldName: FieldName "' + FieldName + '" does not exists.');
end;

function TDataGridAllColumnsEh.FindColByName(ColName: String): TDataGridBaseColumnEh;
var
  I: Integer;
  Column: TDataGridBaseColumnEh;
begin
  Result := nil;

  for I := 0 to Count - 1 do
  begin
    Column := Items[I];
    if Column.Name = ColName then
    begin
      Result := Column;
      Exit;
    end;
  end;
end;

function TDataGridAllColumnsEh.ColByName(ColName: String): TDataGridBaseColumnEh;
begin
  Result := FindColByName(ColName);

  if Result = nil then
    raise Exception.Create('TDataGridAllColumnsEh.ColByName: ColName "' + ColName + '" does not exists.');
end;

function TDataGridAllColumnsEh.GetItem(Index: Integer): TDataGridBaseColumnEh;
begin
  Result := TDataGridBaseColumnEh(inherited Items[Index]);
end;

procedure TDataGridAllColumnsEh.RecalcFooterValues;
var
  I: Integer;
begin
  if (csDestroying in FGrid.ComponentState) then Exit;
  for I := 0 to Count -1 do
  begin
    Items[I].Footers.RecalcFooterValues;
  end;
end;

procedure TDataGridAllColumnsEh.RefreshFooterDefaultFill;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    TColumnFootersEhCrack(Items[I].Footers).RefreshDefaultFill;
end;

procedure TDataGridAllColumnsEh.RefreshFooterDefaultFont;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    TColumnFootersEhCrack(Items[I].Footers).RefreshDefaultFont;
end;

procedure TDataGridAllColumnsEh.RefreshTitleDefaultFill;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if Grid.Title.IsComplexTitle then
  begin
    Grid.Title.ComplexTitleTree.ForAllNodes(
      procedure(Node: TDataGridComplexTitleTreeNodeEh)
      begin
        if Node.NodeType = TDataGridCompoundTitleTreeNodeTypeEh.ColumnNode then
          TColumnTitleEhCrack(TDataGridBaseColumnEh(Node.Column).Title).RefreshDefaultFill()
        else if Node.NodeType = TDataGridCompoundTitleTreeNodeTypeEh.SuperTitleNode then
          TDataGridSuperTitleEhCrack(Node.SuperTitle).RefreshDefaultFill();
      end
    )
  end else
  begin
    inherited RefreshDefaultFill;
  end;
end;

procedure TDataGridAllColumnsEh.RefreshTitleDefaultFont;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if Grid.Title.IsComplexTitle then
  begin
    Grid.Title.ComplexTitleTree.ForAllNodes(
      procedure(Node: TDataGridComplexTitleTreeNodeEh)
      begin
        if Node.NodeType = TDataGridCompoundTitleTreeNodeTypeEh.ColumnNode then
          TColumnTitleEhCrack(TDataGridBaseColumnEh(Node.Column).Title).RefreshDefaultFont()
        else if Node.NodeType = TDataGridCompoundTitleTreeNodeTypeEh.SuperTitleNode then
          TDataGridSuperTitleEhCrack(Node.SuperTitle).RefreshDefaultFont();
      end
    )
  end else
  begin
    inherited RefreshTitleDefaultFont;
  end;
end;

procedure TDataGridAllColumnsEh.RefreshTitleDefaultPadding;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if Grid.Title.IsComplexTitle then
  begin
    Grid.Title.ComplexTitleTree.ForAllNodes(
      procedure(Node: TDataGridComplexTitleTreeNodeEh)
      begin
        if Node.NodeType = TDataGridCompoundTitleTreeNodeTypeEh.ColumnNode then
          TColumnTitleEhCrack(TDataGridBaseColumnEh(Node.Column).Title).RefreshDefaultPadding()
        else if Node.NodeType = TDataGridCompoundTitleTreeNodeTypeEh.SuperTitleNode then
          TDataGridSuperTitleEhCrack(Node.SuperTitle).RefreshDefaultPadding();
      end
    )
  end else
  begin
    inherited RefreshTitleDefaultPadding;
  end;
end;

{$ENDREGION 'TDataGridAllColumnsEh'}

{$REGION 'TColumnTitleEh'}

{ TColumnTitleEh }

constructor TColumnTitleEh.Create(FieldBar: TFieldBarEh);
begin
  inherited Create(FieldBar);
  FFilterItem := CreateFilterItem;
end;

destructor TColumnTitleEh.Destroy;
begin
  PrepareToDestroy;
  FreeAndNil(FFilterItem);
  FreeAndNil(FComplexTitleNode);
  inherited Destroy;
end;

procedure TColumnTitleEh.PrepareToDestroy;
begin
  if FFilterDropDownForm <> nil then
  begin
    ReleaseLockDataGridFilterDropDownForm(True);
  end;
end;

function TColumnTitleEh.GetCellManager: TBaseGridCellManagerEh;
var
  AGrid: TCustomDataGridEhCrack;
begin
  AGrid :=  TCustomDataGridEhCrack(Column.Grid);

  if AGrid <> nil
    then Result := AGrid.Title.DefaultCellManager
    else Result := nil;
end;

function TColumnTitleEh.CalcCellHeight(ACanvas: TCanvas; ACellWidth: Integer): Integer;
var
  Height: Single;
  Grid: TCustomDataGridEhCrack;
  CellLaObject: TVPBaseCellHolderEh;
  QrCellSize: TSizeF;
  ResCellSize: TSizeF;
  ACellManager: TVPBaseCellManagerEh;
begin
  Grid := TCustomDataGridEhCrack(Column.GetGrid);
  if Grid.HDataVFixedPanel = nil then Exit(0);


  QrCellSize := TSizeF.Create(Column.ActualWidth, TLaControlEh.MaxSize.Height);
  ACellManager := Grid.HDataVFixedPanel.GetCellManagerAt(Column.VisibleIndex, 0);
  CellLaObject := ACellManager.CreateCellHolder;
  try
//    Grid.HDataVFixedPanel.InitCellHolderPositionProps(CellLaObject, Column.VisibleIndex, 0);
//    Grid.HDataVFixedPanel.InitCellHolder(CellLaObject);
//    ResCellSize := CellLaObject.QueryLayout(QrCellSize, ACanvas);
    ResCellSize := ACellManager.InitAndCaclRenderCellHolder(
      Grid, QrCellSize, CellLaObject, -1, -1, Column.VisibleIndex, 0);
    Height := ResCellSize.Height;
  finally
    CellLaObject.Free;
  end;

  Result := Round(Height);
end;

function TColumnTitleEh.CalcNeededCellWidth(ACanvas: TCanvas): Integer;
var
  Width: Single;
  Grid: TCustomDataGridEhCrack;
  CellLaObject: TVPBaseCellHolderEh;
  QrCellSize: TSizeF;
  ResCellSize: TSizeF;
  ACellManager: TVPBaseCellManagerEh;
begin
  Grid := TCustomDataGridEhCrack(Column.GetGrid);
  if Grid.HDataVFixedPanel = nil then Exit(0);

  QrCellSize := TSizeF.Create(TLaControlEh.MaxSize.Width, TLaControlEh.MaxSize.Height);
  ACellManager := Grid.HDataVFixedPanel.GetCellManagerAt(Column.VisibleIndex, 0);
  CellLaObject := ACellManager.CreateCellHolder;
  try
    ResCellSize := ACellManager.InitAndCaclRenderCellHolder(
      Grid, QrCellSize, CellLaObject, -1, -1, Column.VisibleIndex, 0);
    Width := ResCellSize.Width;
  finally
    CellLaObject.Free;
  end;

  Result := Round(Width);
end;

function TColumnTitleEh.CalcAutoWidth: Integer;
var
  Width: Single;
  Grid: TCustomDataGridEhCrack;
  CellLaObject: TVPBaseCellHolderEh;
  QrCellSize: TSizeF;
  ResCellSize: TSizeF;
  ACellManager: TVPBaseCellManagerEh;
begin
  Grid := TCustomDataGridEhCrack(Column.GetGrid);
  if Grid.HDataVFixedPanel = nil then Exit(0);

  QrCellSize := TSizeF.Create(TLaControlEh.MaxSize.Width, 0);
  if Column.VisibleIndex < 0 then Exit(64);

  ACellManager := Grid.HDataVFixedPanel.GetCellManagerAt(Column.VisibleIndex, 0);
  CellLaObject := ACellManager.CreateCellHolder;
  try
    ResCellSize := ACellManager.InitAndCaclRenderCellHolder(
      Grid, QrCellSize, CellLaObject, -1, -1, Column.VisibleIndex, 0);
    Width := ResCellSize.Width;
  finally
    CellLaObject.Free;
  end;

  Result := Round(Width);
end;

function TColumnTitleEh.FilterButtonIsVisible: Boolean;
begin
  Result := True;
end;

function TColumnTitleEh.GetColumn: TDataGridBaseColumnEh;
begin
  Result := TDataGridBaseColumnEh(FieldBar);
end;

function TColumnTitleEh.FilterFormIsVisible: Boolean;
begin
  Result := FFilterDropDownForm <> nil;
end;

function TColumnTitleEh.GetSortMarkerParams(out SortOrder: TSortOrderEh; out SortIndex: Integer): Boolean;
var
  Grid: TCustomDataGridEhCrack;
  SortItemIndex: Integer;
begin
  Grid := TCustomDataGridEhCrack(Column.GetGrid);
  SortItemIndex := Grid.Title.SortMarking.IndexOfSortMarkerByColumn(Column);
  if SortItemIndex >= 0 then
  begin
    Result := True;
    SortOrder := Grid.Title.SortMarking.SortMarkers[SortItemIndex].SortDirection;
    if Grid.Title.SortMarking.SortMarkers.Count > 1
      then SortIndex := SortItemIndex + 1
      else SortIndex := 0;
  end else
  begin
    Result := False;
    SortOrder := TSortOrderEh.soAscEh;
    SortIndex := -1;
  end;
end;

procedure TColumnTitleEh.RecalcFilterButtonRect(ACanvas: TCanvas; ACellRect: TRect; out AFilterAreaWidth: Integer);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Column.GetGrid);
  if (Grid <> nil) and (Grid.Title.Filter.Enabled = True) then
  begin
    FFilterButtonRect := Rect(0, 0, 15, 18);
    FFilterButtonAreaRect := FFilterButtonRect;
    FFilterButtonAreaRect.Inflate(2, 2);
    if FFilterButtonAreaRect.Height > ACellRect.Height then
      FFilterButtonAreaRect.Height := ACellRect.Height;
    if FFilterButtonAreaRect.Width * 2 > ACellRect.Width then
      FFilterButtonAreaRect.Width := ACellRect.Width div 2;
    FFilterButtonAreaRect.SetLocation(
      ACellRect.Right - FFilterButtonAreaRect.Width,
      ACellRect.Top + ACellRect.Height div 2 - FFilterButtonAreaRect.Height div 2
    );
    FFilterButtonRect := FFilterButtonAreaRect;
    FFilterButtonRect.Inflate(-2, -2);
    AFilterAreaWidth := FFilterButtonAreaRect.Width;
  end else
  begin
    FFilterButtonRect := TRect.Empty;
    FFilterButtonAreaRect := TRect.Empty;
    AFilterAreaWidth := 0;
  end;
end;

procedure TColumnTitleEh.RecalcSortMarkerAreaRect(ACanvas: TCanvas; ACellRect: TRect; out ASortMarkerAreaWidth: Integer);
var
  SmSize: TSize;
  SortOrder: TSortOrderEh;
  SortIndex: Integer;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Column.GetGrid);
  GetSortMarkerParams(SortOrder, SortIndex);
  SmSize := Grid.StylePainter.GetSortMarkerAreaSize(ACanvas, SortOrder, SortIndex);
  if (SortIndex = -1) or
     (ACellRect.Height < SmSize.Height) or
     (ACellRect.Width < SmSize.Width) then
  begin
    ASortMarkerAreaWidth := 0;
    FSortMarkerRectArea := TRect.Empty;
  end else
  begin
    ASortMarkerAreaWidth := SmSize.Width;
    FSortMarkerRectArea := Rect(0, 0, ASortMarkerAreaWidth, ACellRect.Height);
    FSortMarkerRectArea.SetLocation(ACellRect.Right - SmSize.Width, 0);
  end;
end;

procedure TColumnTitleEh.RecalcTitleCellMetrics(ACanvas: TCanvas; ACellRect: TRect);
var
  ASortMarkerAreaWidth: Integer;
  AFilterAreaWidth: Integer;
begin
  RecalcFilterButtonRect(ACanvas, ACellRect, AFilterAreaWidth);
  ACellRect.Right := ACellRect.Right - AFilterAreaWidth;
  RecalcSortMarkerAreaRect(ACanvas, ACellRect, ASortMarkerAreaWidth);
  ACellRect.Right := ACellRect.Right - ASortMarkerAreaWidth;
  FContentRect := ACellRect;
end;

procedure TColumnTitleEh.SetFilterItem(const Value: TSTColumnFilterEh);
begin
  FFilterItem.Assign(Value);
end;

function TColumnTitleEh.CreateFilterItem: TSTColumnFilterEh;
begin
  Result := TSTColumnFilterEh.Create(Self);
end;

function TColumnTitleEh.GetComplexTitleNode: TDataGridComplexTitleTreeNodeEh;
var
  Grid: TCustomDataGridEhCrack;
begin
  if FComplexTitleNode = nil then
  begin
    Grid := TCustomDataGridEhCrack(Column.GetGrid);
    FComplexTitleNode := Grid.Title.ComplexTitleTree.CreateColumnTitleNode(Column);
  end;
  Result := FComplexTitleNode;
end;

procedure TColumnTitleEh.HandleGetCellManager(Params: TPersistent);
begin
end;

procedure TColumnTitleEh.HandleInitCellContent(Params: TPersistent);
begin
end;

{$ENDREGION 'TColumnTitleEh'}

{$REGION 'TDataGridBaseColumnEh'}

{ TDataGridBaseColumnEh }

constructor TDataGridBaseColumnEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FColSizeUnitStored := False;
  FFooters := CreateFooters;
  FDefCellManager := CreateCellManager;
  FFrozenPosition := TColumnFrozenPositionEh.None;
end;

constructor TDataGridBaseColumnEh.CreateWith(AOwner: TComponent; AParent: TComponent);
var
  Grid: TCustomDataGridEhCrack;
begin
  Create(AOwner);

  if AParent is TDataGridSuperTitleEh then
  begin
    Grid := TCustomDataGridEhCrack(TDataGridSuperTitleEh(AParent).Grid);
    Grid.StaticColumns.Add(Self);
    TDataGridSuperTitleEh(AParent).MoveChild(Self);
  end else if AParent is TDataGridTitleBarEh then
  begin
    Grid := TCustomDataGridEhCrack(TDataGridTitleBarEh(AParent).Grid);
    Grid.StaticColumns.Add(Self);
    Grid.Title.ComplexTitleTree.RootNode.MoveChild(Self);
  end else
    raise Exception.Create('AParent of "' + AParent.ClassName + '" type is not supported.');
end;

destructor TDataGridBaseColumnEh.Destroy;
begin
  Destroying;
  RemoveColumn();
  Title.PrepareToDestroy;
  FreeAndNil(FFooters);
  FreeAndNil(FDefCellManager);
  FreeAndNil(FSizeCalculatorCellObject);
  inherited Destroy;
end;

procedure TDataGridBaseColumnEh.RemoveColumn;
var
  Grid: TCustomDataGridEhCrack;
  TreeList: TDataGridComplexTitleTreeListEhCrack;
begin
  Grid := TCustomDataGridEhCrack(GetGrid);
  if (Title.FComplexTitleNode <> nil) and (Title.FComplexTitleNode.TreeList <> nil) then
  begin
    TreeList := TDataGridComplexTitleTreeListEhCrack(Title.FComplexTitleNode.TreeList);
    TreeList.ExtractNode(Title.FComplexTitleNode);
  end;

  if Grid <> nil then
    Grid.StaticColumns.RemoveColumn(Self);
end;

procedure TDataGridBaseColumnEh.FieldNameChanged;
var
  I: Integer;
begin
  for I := 0 to Footers.Count - 1 do
  begin
  end;
end;

procedure TDataGridBaseColumnEh.FieldChanged;
begin
  inherited FieldChanged;
  Title.FilterItem.UpdateExpressionType;
end;

function TDataGridBaseColumnEh.CreateTitle: TFieldBarTitleEh;
begin
  Result := TColumnTitleEh.Create(Self);
end;

function TDataGridBaseColumnEh.GetTitle: TColumnTitleEh;
begin
  Result := TColumnTitleEh(inherited Title);
end;

procedure TDataGridBaseColumnEh.OptimizeWidth;
var
  List: TColumnsListEh;
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(GetGrid);

  if Assigned(Grid) then
  begin
    List := TColumnsListEh.Create;
    try
      List.Add(Self);
      Grid.OptimizeColsWidth(List);
    finally
      List.Free;
    end;
  end;
end;

function TDataGridBaseColumnEh.GetWidth: Single;
begin
  if FWidthStored
    then Result := FWidth
    else Result := DefaultWidth;
end;

procedure TDataGridBaseColumnEh.HandleCreateCellContent(Params: TBaseGridCreateCellContentParamsEh);
begin
end;

procedure TDataGridBaseColumnEh.HandleInitDataCell(Params: TPersistent);
begin
end;

procedure TDataGridBaseColumnEh.HandleDataCellInitContent(Params: TBaseGridInitCellContentParamsEh);
begin
  inherited HandleDataCellInitContent(Params);
end;

procedure TDataGridBaseColumnEh.RefreshDefaultPadding;
begin
  inherited RefreshDefaultPadding;
  TColumnFootersEhCrack(Footers).RefreshDefaultPadding;
end;

function TDataGridBaseColumnEh.GetIsSelected: Boolean;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(GetGrid);
  if ((Grid <> nil) and
      (Grid.Selection.SelectionType = TDataGridSelectionTypeEh.All))
  then
    Result := True
  else
    Result := FIsSelectedInternal;
end;

procedure TDataGridBaseColumnEh.SetIsSelected(const Value: Boolean);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(GetGrid);
  if (Value <> FIsSelectedInternal) then
  begin
    if (Grid = nil) then
      FIsSelectedInternal := Value
    else
      Grid.Selection.Columns.Select(Self, Value);
  end;
end;

procedure TDataGridBaseColumnEh.SetTitle(const Value: TColumnTitleEh);
begin
  inherited Title := Value;
end;

procedure TDataGridBaseColumnEh.SetWidth(const Value: Single);
begin
  if (FWidthStored = False) or (Value <> FWidth) then
  begin
    FIsInitWidthPerformed := True;
    FWidth := Value;
    FWidthStored := True;
    WidthChanged();
  end;
end;

function TDataGridBaseColumnEh.DefaultColSizeUnit: TGridColSizeUnitEh;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(GetGrid);
  if (Grid <> nil) then
    Result := Grid.ColumnOptions.ColSizeUnit
  else
    Result := TGridColSizeUnitEh.Pixels;
end;

function TDataGridBaseColumnEh.DefaultWidth: Single;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(GetGrid);

  if Assigned(Grid) and
     Assigned(Field) and
     Assigned(Grid.Canvas) then
  begin
    Grid.Canvas.Font.Assign(Self.Font);
    Result := 64;
  end else
  begin
    Result := 64;
  end;
end;

function TDataGridBaseColumnEh.IsWidthStored: Boolean;
begin
  Result := FWidthStored;
end;

procedure TDataGridBaseColumnEh.LinkActiveChanged;
begin
  inherited LinkActiveChanged;
  CheckInitWidth;
end;

procedure TDataGridBaseColumnEh.DoBeforeFirstDrawing;
begin
  CheckInitWidth;
end;

procedure TDataGridBaseColumnEh.CheckInitWidth;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(GetGrid);
  if (Grid <> nil) and
     (Grid.TableView.Active = True) and
     (InListState = TInListFieldBarStateEh.DynamicState) and
     (Grid.IsCanvasEnabled) and
     (FIsInitWidthPerformed = False) and
     (Visible = True) then
  begin
    InitWidth;
  end;
end;

procedure TDataGridBaseColumnEh.InitWidth;
var
  Grid: TCustomDataGridEhCrack;
  DynaColumnOptions: TDynaColumnOptionsEh;
  NewWidth, NextWidth: Integer;
  I: Integer;
begin
  if FIsInitWidthPerformed = True then Exit;

  Grid := TCustomDataGridEhCrack(GetGrid);
  DynaColumnOptions := Grid.ColumnOptions.DynaColumnOptions;
  NewWidth := DynaColumnOptions.MinInitWidth;

  if DynaColumnOptions.UseTitleToInitWidth then
  begin
    NextWidth := Title.CalcAutoWidth;
    if NextWidth > NewWidth then
      NewWidth := NextWidth;
  end;

  if DynaColumnOptions.UseDataRowsToInitWidth then
  begin
    for i := 0 to Grid.TableView.FilteredRowList.Count - 1 do
    begin
      if i >= 100 then Break;
      NextWidth := CalcNeededDataCellWidth(TCanvasManager.MeasureCanvas, i);
      if NextWidth > NewWidth then
        NewWidth := NextWidth;
    end;
  end;

  if NewWidth > DynaColumnOptions.MaxInitWidth then
    NewWidth := DynaColumnOptions.MaxInitWidth;

  Width := NewWidth;

  FIsInitWidthPerformed := True;
end;

procedure TDataGridBaseColumnEh.WidthChanged();
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(GetGrid);
  if (Grid <> nil) then
    Grid.ColumnWidthChanged(Self);
end;

function TDataGridBaseColumnEh.GetActualWidth: Integer;
begin
  Result := FActualWidth;
end;

procedure TDataGridBaseColumnEh.UpdateDefaults;
begin
  inherited UpdateDefaults;
  Footers.UpdateDefaults;
end;

function TDataGridBaseColumnEh.GetCellManager: TBaseGridCellManagerEh;
begin
  Result := FDefCellManager;
end;

function TDataGridBaseColumnEh.GetCellManagerAt(ADataRowIndex: Integer): TBaseGridCellManagerEh;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(GetGrid);

  if (Grid <> nil) and (ADataRowIndex >= 0) and (ADataRowIndex < Grid.VisibleRows.Count) then
  begin
    Result := GetCellManagerAtRow(Grid.VisibleRows[ADataRowIndex]);
  end
  else
  begin
    Result := GetCellManagerAtRow(nil);
  end;
end;

function TDataGridBaseColumnEh.GetCellManagerAtListItemBar(AListItemBar: TTableRowViewEh): TBaseGridCellManagerEh;
var
  ARow: TDataGridRowEh;
begin
  if AListItemBar = nil
    then ARow := nil
    else ARow := TDataGridTableRowEh(AListItemBar).GridDataRow;
  Result := GetCellManagerAtRow(ARow);
end;

function TDataGridBaseColumnEh.GetCellManagerAtRow(ARow: TDataGridRowEh): TBaseGridCellManagerEh;
var
  GetCellManagerParams: TBaseDataGridGetDataCellManagerParamsEh;
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(GetGrid);
  GetCellManagerParams := CreateGetCellManagerParams();
  GetCellManagerParams.Init(Grid, Self, ARow, GetCellManager());
  ProcessGetCellManager(GetCellManagerParams);
  Result := GetCellManagerParams.CellManager;
  GetCellManagerParams.Free;
end;

function TDataGridBaseColumnEh.CreateGetCellManagerParams(): TBaseDataGridGetDataCellManagerParamsEh;
begin
  Result := TBaseDataGridGetDataCellManagerParamsEh.Create;
end;

procedure TDataGridBaseColumnEh.ProcessGetCellManager(Params: TBaseDataGridGetDataCellManagerParamsEh);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(GetGrid);
  HandleGetDataCellManager(Params);
  if (Grid <> nil) then
    Grid.HandleGetDataCellManager(Params);
end;

procedure TDataGridBaseColumnEh.HandleGetDataCellManager(Params: TBaseDataGridGetDataCellManagerParamsEh);
begin
end;

 function TDataGridBaseColumnEh.IsShowSelectionLayer(ACell: TGridBaseCellEh): Boolean;
 var
   VGrid: TCustomDataGridEhCrack;
   VDataCell: TDataAxisCellEh;
 begin
  VGrid := TCustomDataGridEhCrack(GetGrid);
  VDataCell := (ACell as TDataAxisCellEh);
  if (VDataCell.ListItemBar <> nil) then
  begin
    if VGrid.Selection.SelectionType = TDataGridSelectionTypeEh.Non then
    begin
      if (ACell is TDataGridDataRowBandEh) then
      begin
        Result := False;
      end
      else if (VGrid.SelectionOptions.RowHighlight = True) and
              (VGrid.SelectionOptions.RowSelect <> True)
      then
        Result := (VGrid.CurrentDataRow <> nil) and
                  (VGrid.CurrentDataRow.TableRow = VDataCell.ListItemBar) and
                  (VGrid.CurColIndex <> ACell.ColIndex)
      else
        Result := False;
    end
    else if (ACell.AreaColIndex >= 0) and
                (ACell.AreaRowIndex >= 0) then
    begin
      Result := VGrid.Selection.DataCellSelected(
                                        ACell.AreaColIndex,
                                        ACell.AreaRowIndex
                                     );
    end else
    begin
      Result := False;
    end
  end else
  begin
    Result := False;
  end;
 end;

procedure TDataGridBaseColumnEh.InitCell(ACell: TGridBaseCellEh; AStyleParams: TDataAxisCellStyleParamsEh);
var
  VGrid: TCustomDataGridEhCrack;

  function CalcUpMargin(): Integer;
  var
    CurCellHolder: TDataAxisCellHolderEh;
    RolRowIndex: Integer;
    CellVisibleHeight: Integer;
  begin
    Result := 0;
    CurCellHolder := TDataAxisCellHolderEh(ACell.CellHolder);
    RolRowIndex := CurCellHolder.RowIndex - VGrid.VertAxis.FixedCelCount;

    if (CurCellHolder.IsNextRecordValueSame = True) and (VGrid.VertAxis.RollStartVisCel = RolRowIndex) then
    begin
      if VGrid.VertAxis.RollStartVisPos > VGrid.VertAxis.RollLocCelPosArr[RolRowIndex] then
        Result := - (VGrid.VertAxis.RollStartVisPos - VGrid.VertAxis.RollLocCelPosArr[RolRowIndex]);
      Exit;
    end;

    while (CurCellHolder.IsPriorRecordValueSame) and (CurCellHolder.PrevRowCellHolder <> nil) do
    begin
      CurCellHolder := CurCellHolder.PrevRowCellHolder as TDataAxisCellHolderEh;
      RolRowIndex := CurCellHolder.RowIndex - VGrid.VertAxis.FixedCelCount;
      if VGrid.VertAxis.RollStartVisPos > VGrid.VertAxis.RollLocCelPosArr[RolRowIndex] then
      begin
        CellVisibleHeight := VGrid.VertAxis.CelLens[CurCellHolder.RowIndex] -
                              (VGrid.VertAxis.RollStartVisPos - VGrid.VertAxis.RollLocCelPosArr[RolRowIndex]);
        Result := Result + CellVisibleHeight;
        Exit;
      end else
      begin
        Result := Result + VGrid.VertAxis.CelLens[CurCellHolder.RowIndex];
      end;

    end;
  end;

  function CalcDownMargin(): Integer;
  var
    CurCellHolder: TDataAxisCellHolderEh;
    RolRowIndex: Integer;
    CellVisibleHeight: Integer;
  begin
    Result := 0;
    CurCellHolder := TDataAxisCellHolderEh(ACell.CellHolder);
    RolRowIndex := CurCellHolder.RowIndex - VGrid.VertAxis.FixedCelCount;

    if (CurCellHolder.IsPriorRecordValueSame = True) and (VGrid.VertAxis.RollStopVisPos = RolRowIndex) then
    begin
      if VGrid.VertAxis.RollStopVisPos > VGrid.VertAxis.RollLocCelPosArr[RolRowIndex] + VGrid.VertAxis.CelLens[RolRowIndex] then
        Result := - (VGrid.VertAxis.RollStartVisPos - (VGrid.VertAxis.RollLocCelPosArr[RolRowIndex] + VGrid.VertAxis.CelLens[RolRowIndex]));
      Exit;
    end;

    while (CurCellHolder.IsNextRecordValueSame) and (CurCellHolder.NextRowCellHolder <> nil) do
    begin
      CurCellHolder := CurCellHolder.NextRowCellHolder as TDataAxisCellHolderEh;
      RolRowIndex := CurCellHolder.RowIndex - VGrid.VertAxis.FixedCelCount;
      if VGrid.VertAxis.RollStopVisPos < VGrid.VertAxis.RollLocCelPosArr[RolRowIndex] + VGrid.VertAxis.CelLens[CurCellHolder.RowIndex] then
      begin
        CellVisibleHeight := VGrid.VertAxis.RollStartVisPos - (VGrid.VertAxis.RollLocCelPosArr[RolRowIndex] + VGrid.VertAxis.CelLens[CurCellHolder.RowIndex]);
        Result := Result + CellVisibleHeight;
        Exit;
      end else
      begin
        Result := Result + VGrid.VertAxis.CelLens[CurCellHolder.RowIndex];
      end;
    end;
  end;

var
  DataCell: TDataAxisCellEh;
  DataCellTopMargin: Integer;
  DataCellBottomMargin: Integer;
//const
//  LaHorzAlignments: array [TTextAlign] of TLaHorzAlignmentEh =
//    (TLaHorzAlignmentEh.Center, TLaHorzAlignmentEh.Left, TLaHorzAlignmentEh.Right);
begin
  VGrid := TCustomDataGridEhCrack(GetGrid);
  DataCell := TDataAxisCellEh(ACell);
  DataCell.Fill := AStyleParams.Fill;
  DataCell.FontColor := AStyleParams.FontColor;
  DataCell.Font := AStyleParams.Font;
  DataCell.ReadOnly := not inherited CanModifyCellValue(DataCell.ListItemBar);
  DataCellTopMargin := 0;
  DataCellBottomMargin := 0;

  if MergeDuplicates then
  begin
    DataCellTopMargin := - CalcUpMargin();
    DataCellBottomMargin := - CalcDownMargin();
  end;

  DataCell.Margins.Top := DataCellTopMargin;
  DataCell.Margins.Bottom := DataCellBottomMargin;
end;

function TDataGridBaseColumnEh.GetColSizeUnit: TGridColSizeUnitEh;
begin
  if IsColSizeUnitStored then
    Result := FColSizeUnit
  else
    Result := DefaultColSizeUnit();
end;

procedure TDataGridBaseColumnEh.SetColSizeUnit(const Value: TGridColSizeUnitEh);
begin
  if (FColSizeUnitStored = False) or (FColSizeUnit <> Value) then
  begin
    FColSizeUnit := Value;
    FColSizeUnitStored := True;
    Changed;
  end;
end;

procedure TDataGridBaseColumnEh.SetColSizeUnitStored(const Value: Boolean);
begin
  if FColSizeUnitStored <> Value then
  begin
    FColSizeUnitStored := Value;
    FColSizeUnit := DefaultColSizeUnit();
    Changed;
  end;
end;

function TDataGridBaseColumnEh.IsColSizeUnitStored(): Boolean;
begin
  Result := FColSizeUnitStored;
end;

procedure TDataGridBaseColumnEh.SetFooters(const Value: TDataGridBaseColumnFootersEh);
begin
  FFooters.Assign(Value);
end;

function TDataGridBaseColumnEh.CreateFooters: TDataGridBaseColumnFootersEh;
begin
  Result := TDataGridBaseColumnFootersEh.Create(Self, TDataGridBaseColumnFooterEh);
end;

function TDataGridBaseColumnEh.CalcDefaultRowHeight(Canvas: TCanvas): Integer;
begin
  Result := CalcRowHeight(Canvas, -1);
end;

function TDataGridBaseColumnEh.CellHeightIsRowDependent(): Boolean;
begin
  Result := HeightAutoExpand = True;
end;

function TDataGridBaseColumnEh.CalcRowHeight(ACanvas: TCanvas; ADataRowIndex: Integer): Integer;
var
  Height: Single;
  Grid: TCustomDataGridEhCrack;
  QrCellSize: TSizeF;
  ResCellSize: TSizeF;
  ACellManager: TVPBaseCellManagerEh;
  AGridColIndex, AGridRowIndex: Integer;
begin
  Grid := TCustomDataGridEhCrack(GetGrid);

  QrCellSize := TSizeF.Create(ActualWidth, TLaControlEh.MaxSize.Height);
  ACellManager := GetCellManagerAt(ADataRowIndex);
  if FSizeCalculatorCellObject = nil then
  begin
    FSizeCalculatorCellObject := ACellManager.CreateCellHolder;
  end else if FSizeCalculatorCellObject.CellManager <> ACellManager then
  begin
    FSizeCalculatorCellObject.Free;
    FSizeCalculatorCellObject := ACellManager.CreateCellHolder;
  end;
  try
    AGridColIndex := VisibleIndex + Grid.StartDataColIndex;
    AGridRowIndex := ADataRowIndex + Grid.StartDataRowIndex;

    ResCellSize := ACellManager.InitAndCaclRenderCellHolder(
      Grid, QrCellSize, FSizeCalculatorCellObject, AGridColIndex, AGridRowIndex, VisibleIndex, ADataRowIndex);
    Height := ResCellSize.Height;
  finally
  end;

  Result := Round(Height);
end;

function TDataGridBaseColumnEh.CalcNeededDataCellWidth(ACanvas: TCanvas; ADataRowIndex: Integer): Integer;
var
  AWidth: Single;
  Grid: TCustomDataGridEhCrack;
  QrCellSize: TSizeF;
  ResCellSize: TSizeF;
  ACellManager: TVPBaseCellManagerEh;
  AGridColIndex, AGridRowIndex: Integer;
begin
  Grid := TCustomDataGridEhCrack(GetGrid);

  QrCellSize := TSizeF.Create(TLaControlEh.MaxSize.Width, 0);
  ACellManager := GetCellManagerAt(ADataRowIndex);
  if FSizeCalculatorCellObject = nil then
    FSizeCalculatorCellObject := ACellManager.CreateCellHolder;
  try
    AGridColIndex := VisibleIndex + Grid.StartDataColIndex;
    AGridRowIndex := ADataRowIndex + Grid.StartDataRowIndex;

    ResCellSize := ACellManager.InitAndCaclRenderCellHolder(
      Grid, QrCellSize, FSizeCalculatorCellObject, AGridColIndex, AGridRowIndex, VisibleIndex, ADataRowIndex);

    AWidth := ResCellSize.Width;
  finally
  end;

  Result := Round(AWidth);
end;

procedure TDataGridBaseColumnEh.MTViewDataEvent(RowNum: Integer; Event: TMTViewEventTypeEh; OldRowNum: Integer);
begin

end;

function TDataGridBaseColumnEh.CreateCellManager: TBaseGridCellManagerEh;
begin
  Result := TDataAxisTextCellManagerEh.Create(nil, Self);
end;

function TDataGridBaseColumnEh.GetRowValue(ARow: TDataGridRowEh): TValue;
begin
  if ARow is TDataGridDataRowEh
    then Result := GetListItemValue(TDataGridDataRowEh(ARow).TableRow)
    else Result := TValue.Empty;
end;

procedure TDataGridBaseColumnEh.ClampInView;
var
  Grid: TCustomDataGridEhCrack;
  GridCoord: TGridCoord;
begin
  Grid := TCustomDataGridEhCrack(GetGrid);

  if VisibleIndex >= 0 then
  begin
    GridCoord.X := VisibleIndex + Grid.StartDataColIndex;
    GridCoord.Y := 0;
    Grid.ClampInView(GridCoord, True, False);
  end;
end;

procedure TDataGridBaseColumnEh.HeightAutoExpandChanged;
var
  Grid: TCustomDataGridEhCrack;
begin
  inherited HeightAutoExpandChanged;
  Grid := TCustomDataGridEhCrack(GetGrid);
  if Grid <> nil then
    Grid.RecalcRowHeightsNeeded();
end;

procedure TDataGridBaseColumnEh.SetParentComponent(Value: TComponent);
begin
  if Value is TCustomDataGridEh then
    TCustomDataGridEhCrack(Value).AddChildComponent(Self)
  else if Value is TDataGridSuperTitleEh then
    TDataGridSuperTitleEhCrack(Value).AddChildComponent(Self);
end;

function TDataGridBaseColumnEh.GetParentComponent: TComponent;
begin
  if (Title.ComplexTitleNode.Parent = nil) or (Title.ComplexTitleNode.TreeList = nil) then
    Result := nil
  else if Title.ComplexTitleNode.Parent = TDataGridComplexTitleTreeListEh(Title.ComplexTitleNode.TreeList).RootNode then
    Result := GetGrid
  else if Title.ComplexTitleNode.Parent.NodeType = TDataGridCompoundTitleTreeNodeTypeEh.SuperTitleNode then
    Result := Title.ComplexTitleNode.Parent.SuperTitle
  else
    raise Exception.Create('TDataGridBaseColumnEh.GetParentComponent: Unable to determine parent component. Title: "' + Title.Text + '"');
end;

function TDataGridBaseColumnEh.HasParent: Boolean;
begin
  Result := True;
end;

procedure TDataGridBaseColumnEh.DefaultInitCellEditor(AParams: TBaseGridInitEditorParamsEh);
begin

end;

procedure TDataGridBaseColumnEh.FrozenPositionChanged();
var
  Grid: TCustomDataGridEhCrack;
  NewList: TList<TFieldBarEh>;
begin
  Grid := TCustomDataGridEhCrack(GetGrid);
  if Grid <> nil then
  begin
    NewList := TList<TFieldBarEh>.Create(Grid.DisplayColumns.BaseList);
    Grid.DisplayColumns.ResetList(NewList, True);
    NewList.Free;
  end;
end;

function TDataGridBaseColumnEh.CanModifyCellValue(ARow: TDataGridRowEh): Boolean;
begin
  if ARow is TDataGridDataRowEh
    then Result := inherited CanModifyCellValue(TDataGridDataRowEh(ARow).TableRow)
    else Result := False;
end;

function TDataGridBaseColumnEh.GetRowEditText(ARow: TDataGridRowEh): String;
begin
  if ARow is TDataGridDataRowEh
    then Result := GetListItemEditText(TDataGridDataRowEh(ARow).TableRow)
    else Result := '';
end;

function TDataGridBaseColumnEh.GetRowDisplayText(ARow: TDataGridRowEh): String;
begin
  if ARow is TDataGridDataRowEh
    then Result := GetListItemDisplayText(TDataGridDataRowEh(ARow).TableRow)
    else Result := '';
end;

procedure TDataGridBaseColumnEh.SetFrozenPosition(const Value: TColumnFrozenPositionEh);
begin
  if FFrozenPosition <> Value then
  begin
    FFrozenPosition := Value;
    FrozenPositionChanged();
  end;
end;

{$ENDREGION 'TDataGridBaseColumnEh'}

{$REGION 'TDataGridDisplayColumnsEh'}

{ TDataGridDisplayColumnsEh }

constructor TDataGridDisplayColumnsEh.Create(AGrid: TControl; AList: TList<TFieldBarEh>);
begin
  inherited Create(AGrid, AList);
end;

destructor TDataGridDisplayColumnsEh.Destroy;
begin
  inherited Destroy;
end;

function TDataGridDisplayColumnsEh.GetItem(Index: Integer): TDataGridBaseColumnEh;
begin
  Result := TDataGridBaseColumnEh(inherited Items[Index]);
end;

function TDataGridDisplayColumnsEh.CompareFieldBarOrder(const ALeft, ARight: TFieldBarEh): Integer;
var
  LeftCol, RightCol: TDataGridBaseColumnEh;
begin
  LeftCol := TDataGridBaseColumnEh(ALeft);
  RightCol := TDataGridBaseColumnEh(ARight);
  if LeftCol.FrozenPosition = RightCol.FrozenPosition then
    Result := ALeft.DisplayIndex - ARight.DisplayIndex
  else
    Result := Ord(LeftCol.FrozenPosition) - Ord(RightCol.FrozenPosition);
end;

procedure TDataGridDisplayColumnsEh.ReorderList(NewOrderList: TList<TFieldBarEh>);
var
  I: Integer;
begin
  for I := 0 to NewOrderList.Count - 1 do
    TDataGridBaseColumnEh(NewOrderList[I]).FDisplayIndex := I;

  NewOrderList.Sort(
    TComparer<TFieldBarEh>.Construct(
      function(const ALeft, ARight: TFieldBarEh): Integer
      var
        LeftCol, RightCol: TDataGridBaseColumnEh;
      begin
        LeftCol := TDataGridBaseColumnEh(ALeft);
        RightCol := TDataGridBaseColumnEh(ARight);
        if LeftCol.FrozenPosition = RightCol.FrozenPosition then
          Result := ALeft.DisplayIndex - ARight.DisplayIndex
        else
          Result := Ord(LeftCol.FrozenPosition) - Ord(RightCol.FrozenPosition);
      end
    )
  );
end;

procedure TDataGridDisplayColumnsEh.SetColumnsOrder(AOrderedList: TList<TDataGridBaseColumnEh>);
var
  I: Integer;
  ColIndex: Integer;
  Grid: TCustomDataGridEhCrack;
begin
  if (Count <> AOrderedList.Count) then
    raise Exception.Create('TDataGridDisplayColumnsEh.SetDisplayOrder: AOrderedList.Count <> SelfList.Count');

  Grid := TCustomDataGridEhCrack(FGrid);
  Grid.Columns.BeginUpdate;
  for I := 0 to AOrderedList.Count - 1 do
  begin
    ColIndex := IndexOf(AOrderedList[I]);
    if ColIndex < 0 then
      raise Exception.Create('TDataGridDisplayColumnsEh.SetDisplayOrder: ColIndex ' + IntToStr(I) + ' is not found');
    Items[ColIndex].DisplayIndex := I;
  end;
  Grid.Columns.EndUpdate;
end;

{$ENDREGION 'TDataGridDisplayColumnsEh'}

{$REGION 'TDataGridVisibleColumnsEh'}

{ TDataGridVisibleColumnsEh }

constructor TDataGridVisibleColumnsEh.Create(AGrid: TControl; AList: TList<TFieldBarEh>);
begin
  inherited Create(AGrid, AList);
end;

destructor TDataGridVisibleColumnsEh.Destroy;
begin
  inherited Destroy;
end;

function TDataGridVisibleColumnsEh.GetItem(Index: Integer): TDataGridBaseColumnEh;
begin
  Result := TDataGridBaseColumnEh(inherited Items[Index]);
end;

procedure TDataGridVisibleColumnsEh.MoveColumn(Column: TDataGridBaseColumnEh;
  NewVisibleIndex: Integer);
begin
  MoveFieldBar(Column, NewVisibleIndex);
end;

procedure TDataGridVisibleColumnsEh.MoveColumns(ColumnList: TColumnsListEh;
  NewVisibleIndex: Integer);
begin
  MoveFieldBars(ColumnList, NewVisibleIndex);
end;

function TDataGridVisibleColumnsEh.GetFirstTabColumn: TDataGridBaseColumnEh;
begin
  Result := Items[0];
end;

function TDataGridVisibleColumnsEh.GetLastTabColumn: TDataGridBaseColumnEh;
begin
  Result := Items[Count - 1];
end;

function TDataGridVisibleColumnsEh.GetNextTabColumn(ForColumn: TDataGridBaseColumnEh;
  GoForward: Boolean): TDataGridBaseColumnEh;
var
  AColIndex, Original: Integer;
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  AColIndex := ForColumn.VisibleIndex;
  Result := ForColumn;
  Original := AColIndex;

  while True do
  begin
    if GoForward
      then Inc(AColIndex)
      else Dec(AColIndex);
    if AColIndex >= Count - Grid.ContraColCount then
      Exit
    else if AColIndex < 0 then
      Exit;
    if AColIndex = Original then Exit;
    if True then
    begin
      Result := Items[AColIndex];
      Exit;
    end;
  end;
end;

procedure TDataGridVisibleColumnsEh.UpdateActualWidths;
var
  c: Integer;
  WeightViewWidth: Integer;
  PixelColsWidth: Integer;

  WeightColsFull: Single;
  WeightedColsWidth: Integer;
  ViewWidthRest: Integer;
  Column: TDataGridBaseColumnEh;
  Grid: TCustomDataGridEhCrack;
  ActualColumnWidthChanged: Boolean;
  NewColWidths: TArray<Integer>;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  PixelColsWidth := 0;
  SetLength(NewColWidths, Count);

  for c := 0 to Count - 1 do
    NewColWidths[c] := Items[c].ActualWidth;

  for c := 0 to Count - 1 do
  begin
    if Items[c].ColSizeUnit = TGridColSizeUnitEh.Pixels  then
    begin
      Column := Items[c];
      NewColWidths[c] := Round(Column.Width);
      PixelColsWidth := PixelColsWidth + NewColWidths[c];
    end;
  end;

  WeightViewWidth := Grid.HorzAxis.RollClientLen - PixelColsWidth;
  if WeightViewWidth < 0 then WeightViewWidth := 0;

  WeightColsFull := 0;
  for c := 0 to Count - 1 do
  begin
    Column := Items[c];
    if Column.ColSizeUnit = TGridColSizeUnitEh.Weight then
    begin
      WeightColsFull := WeightColsFull + Column.Width;
    end;
  end;

  WeightedColsWidth := 0;
  for c := 0 to Count - 1 do
  begin
    Column := Items[c];
    if Column.ColSizeUnit = TGridColSizeUnitEh.Weight then
    begin
      NewColWidths[c] := Trunc(WeightViewWidth * Column.Width / WeightColsFull);
      WeightedColsWidth := WeightedColsWidth + NewColWidths[c];
    end;
  end;

  if WeightedColsWidth > 0 then
  begin
    ViewWidthRest := WeightViewWidth - WeightedColsWidth;
    for c := 0 to ViewWidthRest - 1 do
    begin
      Column := Items[c];
      if Column.ColSizeUnit = TGridColSizeUnitEh.Weight then
        NewColWidths[c] := NewColWidths[c] + 1;
    end;
  end;

  ActualColumnWidthChanged := False;
  for c := 0 to Count - 1 do
  begin
    Column := Items[c];
    if Column.ActualWidth <> NewColWidths[c] then
    begin
      Column.FActualWidth := NewColWidths[c];
      ActualColumnWidthChanged := True;
    end;
  end;

  if ActualColumnWidthChanged then
    Grid.ActualColumnWidthChanged();
end;

procedure TDataGridVisibleColumnsEh.UpdateTitleMetrics;
var
  c: Integer;
  Column: TDataGridBaseColumnEh;
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);

  for c := 0 to Count - 1 do
  begin
    Column := Items[c];
    Column.Title.RecalcTitleCellMetrics(Grid.Canvas, Rect(0, 0, Column.ActualWidth, Grid.FTitleRowHeight));
  end;
end;

function TDataGridVisibleColumnsEh.GetEnumerator: TColumnFieldBarEnumerator;
begin
  Result := TColumnFieldBarEnumerator.Create(inherited GetEnumerator);
end;

{$ENDREGION 'TDataGridVisibleColumnsEh'}

{$REGION 'TDataGridDynamicColumnsEh'}

{ TDataGridDynamicColumnsEh }

constructor TDataGridDynamicColumnsEh.Create(AGrid: TControl;
  AList: TList<TFieldBarEh>);
begin
  inherited Create(AGrid, AList);
end;

destructor TDataGridDynamicColumnsEh.Destroy;
begin
  inherited Destroy;
end;

function TDataGridDynamicColumnsEh.GetColumnClassByField(AField: TTableFieldLinkEh): TFieldBarEhClass;
begin
  Result := inherited GetColumnClassByField(AField);
end;

{$ENDREGION 'TDataGridDynamicColumnsEh'}

{$REGION 'TColumnFieldBarEnumerator'}

{ TColumnFieldBarEnumerator }

constructor TColumnFieldBarEnumerator.Create(AFieldBarEnumerator: TEnumerator<TFieldBarEh>);
begin
  inherited Create;
  FFieldBarEnumerator := AFieldBarEnumerator;
end;

destructor TColumnFieldBarEnumerator.Destroy;
begin
  FreeAndNil(FFieldBarEnumerator);
  inherited Destroy;
end;

function TColumnFieldBarEnumerator.DoGetCurrent: TDataGridBaseColumnEh;
begin
  Result := TDataGridBaseColumnEh(FFieldBarEnumerator.Current);
end;

function TColumnFieldBarEnumerator.DoMoveNext: Boolean;
begin
  Result := FFieldBarEnumerator.MoveNext;
end;

{$ENDREGION 'TColumnFieldBarEnumerator'}

{$REGION 'TBaseDataGridGetDataCellManagerParamsEh'}

{ TBaseDataGridGetDataCellManagerParamsEh }

procedure TBaseDataGridGetDataCellManagerParamsEh.Init(AGrid: TControl;
  AColumn: TDataGridBaseColumnEh; ARow: TDataGridRowEh;
  ADefaultCellManager: TBaseGridCellManagerEh);
begin
  FGrid := AGrid;
  FColumn := AColumn;
  FRow := ARow;
  FCellManager := ADefaultCellManager;
end;

{$ENDREGION 'TBaseDataGridGetDataCellManagerParamsEh'}

end.
