{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{               EhLibFmx.CustomDataGrids                }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.CustomDataGrids;

interface

{$SCOPEDENUMS ON}

{$REGION 'uses'}
uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, System.Types,
  FMX.Graphics, System.UITypes, System.Math, FMX.Forms, System.Contnrs,
  FMX.Grid, FMX.Platform, Data.DB, System.Variants, System.StrUtils,
  FMX.Objects, FMX.Menus, System.Generics.Collections, FMX.Dialogs,
  EhLibUtils, DBUtilsEh,
  EhLib.TableLinks,
  EhLib.GridTableViews,
  EhLibFmx.Utils,
  EhLibFmx.GridAxisData,
  EhLibFmx.Grids,
  EhLibFmx.Grid.Types,
  EhLibFmx.DataAxisGrids,
  EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.Grid.CellManagers,
  EhLibFmx.SearchPanels,

  EhLibFmx.DataAxisGrid.DataCells,

  EhLibFmx.DataGrid.Titles,
  EhLibFmx.DataGrid.DataCells,
  EhLibFmx.DataGrid.IndicatorColumns,
  EhLibFmx.DataGrid.IndicatorTitles,
  EhLibFmx.DataGrid.Columns,
  EhLibFmx.DataGrid.Footers,
  EhLibFmx.DataGrid.ToolControls,
  EhLibFmx.DataGrid.GridManagers,
  EhLibFmx.DataGrid.ComplexTitles,
  EhLibFmx.DataGrid.SearchPanels,
  EhLibFmx.DataGrid.Rows,
  EhLibFmx.DataGrid.DataGrouping,
  EhLibFmx.DataGrid.DataGroupingPanels,

  EhLibFmx.ToolControls,
  EhLibFmx.Grid.InplaceEditors,
  EhLibFmx.Platform,
  EhLibFmx.Types,
  EhLibFmx.LaHostVirtualPanels,
  EhLibFmx.Grid.ToolControls,
  EhLibFmx.LaObjects,
  EhLibFmx.LaControls
  ;
{$ENDREGION 'uses'}

type
  TCustomDataGridEh = class;
  TDataGridStylePainterEh = class;

  TDataGridMouseStateEh = (Normal,
                           RowSelecting,
                           ColSelecting,
                           RectSelecting
                          );

  TDataGridCalcDataRowHeightEventEh = procedure(Sender: TObject; Params: TDataGridCalcDataRowHeightParamsEh) of object;
  TDataGridLocateFunction = reference to function(ADataRow: TDataGridRowEh): Boolean;

{ TBaseDataGridFilterRowParamsEh }

  TBaseDataGridFilterRowParamsEh = class(TPersistent)
  private
    FAccept: Boolean;
    FGrid: TControl;
    FRow: TDataGridRowEh;

  protected

  public
    procedure Init(AGrid: TControl; ARow: TDataGridRowEh; AAccept: Boolean);

    property Accept: Boolean read FAccept write FAccept;
    property Grid: TControl read FGrid;
    property Row: TDataGridRowEh read FRow;
  end;

{ TBaseDataGridDataCellStyleParamsEh }

  TBaseDataGridDataCellStyleParamsEh = class(TFieldBarDataCellStyleParamsEh)
  private
    function GetColumn: TDataGridBaseColumnEh;
    function GetRow: TDataGridRowEh;
    function GetGrid: TCustomDataGridEh;
  public
    property Column: TDataGridBaseColumnEh read GetColumn;
    property Row: TDataGridRowEh read GetRow;
    property Grid: TCustomDataGridEh read GetGrid;
  end;

{ TCustomDataGridEh }

  TCustomDataGridEh = class(TCustomDataAxisGridEh)
  private
    FCenter: TDataGridCenterEh;
    FColumnsContainer: TDataGridStaticColumnsContainerEh;
    FEditActions: TGridEditActionsEh;
    FFooter: TDataGridFooterEh;
    FInColExit: Boolean;
    FIndicatorColumn: TDataGridIndicatorColumnEh;
    FIndicatorTitle: TDataGridIndicatorTitleEh;
    FOnCalcDataRowHeight: TDataGridCalcDataRowHeightEventEh;
    FSearchPanel: TDataGridSearchPanelEh;
    FSearchPanelControl: TDataGridSearchPanelControlEh;
    FGroupingPanel: TDataGridGroupingPanelEh;
    FSearchPanelMode: Boolean;
    FSelection: TDataGridSelectionEh;
    FSelectionOptions: TDataGridSelectionOptionsEh;
    FStartDataColIndex: Integer;
    FStartDataRowIndex: Integer;
    FStdDefaultRowHeight: Integer;
//    FCurrentRowViewIndex: Integer;
    FVisibleRows: TDataGridRowsEh;
    FVisibleRowList: TList<TDataGridRowEh>;
    FDataGrouping: TDataGridDataGroupingEh;
    FGridView: TDataGridRowsViewEh;

    function CalcTitleRowHeight: Integer;
    function GetAutoFitColWidths: Boolean;
    function GetAutoGenerateColumns: Boolean;
    function GetBof: Boolean;
    function GetCellRowHeights(Index: Longint): Integer;
    function GetColumnOptions: TDataGridColumnOptionsEh;
    function GetColumns: TDataGridAllColumnsEh;
    function GetCurrentColIndex: Integer;
    function GetCurrentColumn: TDataGridBaseColumnEh;
    function GetCurrentDataRow: TDataGridDataRowEh;
    function GetCurrentRow: TDataGridRowEh;
    function GetCurrentRowIndex: Integer;
    function GetDataRowCount: Integer;
    function GetDisplayColumns: TDataGridDisplayColumnsEh;
    function GetDynamicColumns: TDataGridDynamicColumnsEh;
    function GetEof: Boolean;
    function GetFooterRowCount: Integer;
    function GetFullFooterRowCount: Integer;
    function GetGridLineOptions: TDataGridLineOptionsEh;
    function GetGridMouseStateManage: TDataGridMouseStateManagerEh;
    function GetHorzScrollBar: TDataGridHorzScrollBarEh;
    function GetHorzScrollBarPanelControl: TDataGridScrollBarPanelControlEh;
    function GetSelectedRows: TDataGridSelectedRowsEh;
    function GetStaticColumns: TStaticColumnsEh;
    function GetTableView: TDataGridTableRowsViewEh;
    function GetTitle: TDataGridTitleBarEh;
    function GetTopDataOffset: Byte;
    function GetVertScrollBar: TDataGridVertScrollBarEh;
    function GetVertScrollBarPanelControl: TDataGridScrollBarPanelControlEh;
    function GetVisibleColumns: TDataGridVisibleColumnsEh;
    function GetVisibleRows: TDataGridRowsEh;
    function GetGridView: TDataGridRowsViewEh;

    procedure BeginLayout;
    procedure MoveCol(DataCol, Direction: Integer; Select: Boolean; ShowInView: Boolean);
    procedure SetAutoGenerateColumns(const Value: Boolean);
    procedure SetCellRowHeights(Index: Longint; const Value: Integer);
    procedure SetCenter(const Value: TDataGridCenterEh);
    procedure SetColumnOptions(const Value: TDataGridColumnOptionsEh);
    procedure SetCurrentColIndex(const Value: Integer);
    procedure SetCurrentRow(const Value: TDataGridRowEh);
    procedure SetCurrentRowIndex(const Value: Integer);
    procedure SetEditActions(const Value: TGridEditActionsEh);
    procedure SetFooter(const Value: TDataGridFooterEh);
    procedure SetGridLineOptions(const Value: TDataGridLineOptionsEh);
    procedure SetHorzScrollBar(const Value: TDataGridHorzScrollBarEh);
    procedure SetIndicatorColumn(const Value: TDataGridIndicatorColumnEh);
    procedure SetIndicatorTitle(const Value: TDataGridIndicatorTitleEh);
    procedure SetSearchPanel(const Value: TDataGridSearchPanelEh);
    procedure SetSearchPanelMode(const Value: Boolean);
    procedure SetSelection(const Value: TDataGridSelectionEh);
    procedure SetSelectionOptions(const Value: TDataGridSelectionOptionsEh);
    procedure SetTitle(const Value: TDataGridTitleBarEh);
    procedure SetVertScrollBar(const Value: TDataGridVertScrollBarEh);
    procedure UpdateDefaultRowHeight;
    procedure UpdateGridMTRowCount;
    procedure UpdateGridRowCount;
    procedure SetStaticColumns(const Value: TStaticColumnsEh);
    procedure SetDataGrouping(const Value: TDataGridDataGroupingEh);
    function GetStylePainter: TDataGridStylePainterEh;

  protected
    FDataAdding: Boolean;
    FDataRowHeights: TList<Integer>;
    FDataGridMouseState: TDataGridMouseStateEh;
    FDataGridPotentialMouseState: TDataGridMouseStateEh;
    FGridHasAutoRowHeightColumns: Boolean;
    FHighlightingTexts: TList<String>;
    FInterlinear: Integer;
    FInTitleFilterListboxColumn: TDataGridBaseColumnEh;
    FLayoutLock: Byte;
    FMoveAndScrollService: TDataGridMoveAndScrollServiceEh;
    FTitleRowHeight: Integer;
    FUpdatingDataRowHeightsNeeded: Boolean;
    FRowSizeCalculatorCellObject: TVPBaseCellHolderEh;
    FDefaultDataRowCellManager: TDataGridDataRowBandManagerEh;
    FFrozenLeftColCount: Integer;
    FFrozenRightColCount: Integer;

    function CanEditModify: Boolean; override;
    function CanShowEditor: Boolean; override;
    function CheckBeginColumnDrag(var Origin, Destination: Integer; const MousePt: TPoint): Boolean; override;
    function CreateAllFieldBarList(ABaseList: TList<TFieldBarEh>): TGridAllFieldBarListEh; override;
    function CreateDisplayFieldBars(ABaseList: TList<TFieldBarEh>): TGridDisplayFieldBarsEh; override;
    function CreateDynamicFieldBars(ABaseList: TList<TFieldBarEh>): TGridDynamicFieldBarsEh; override;
    function CreateFieldBarOptions: TFieldBarOptionsEh; override;
    function CreateGridLineOptions: TGridLineOptionsEh; override;
    function CreateGridMouseStateManager: TGridMouseStateManagerEh; override;
    function CreateGridTableView: TDataAxisGridTableViewEh; override;
    function CreateHDataVDataPanel: TLaHostVirtualPanelEh; override;
    function CreateHDataVFixedPanel: TLaHostVirtualPanelEh; override;
    function CreateHDataVFooterPanel: TLaHostVirtualPanelEh; override;
    function CreateHFixedVDataPanel: TLaHostVirtualPanelEh; override;
    function CreateHFixedVFixedPanel: TLaHostVirtualPanelEh; override;
    function CreateHFixedVFooterPanel: TLaHostVirtualPanelEh; override;
    function CreateHorzScrollBarPanelControl: TGridScrollBarPanelControlEh; override;
    function CreateScrollBar(AKind: TOrientation): TGridScrollBarEh; override;
    function CreateStaticFieldBars: TGridStaticFieldBarsEh; override;
    function CreateTitle: TAxisGridTitleBarEh; override;
    function CreateVertScrollBarPanelControl: TGridScrollBarPanelControlEh; override;
    function CreateVisibleFieldBars(ABaseList: TList<TFieldBarEh>): TGridVisibleFieldBarsEh; override;
    function CreateStylePainter(): TBaseGridStylePainterEh; override;

    function GetCurrentFieldBar: TFieldBarEh; override;
    function GetCurrentListItemBar: TTableRowViewEh; override;
    function GetCursorAtMousePos(Params: TGridCellMouseParamsEh): TCursor; override;
    function GetDefaultStyleLookupName: string; override;
    function GetDynaFieldBarClassByField(AField: TTableFieldLinkEh): TFieldBarEhClass; override;
    function GetAxisDataTreeViewAreaParams(AFieldBar: TFieldBarEh; ARecordBar: TTableRowViewEh): TDataAxisCellTreeViewAreaParamsEh; override;

    function InternalGetCellManagerAt(VirtPanel: TLaHostVirtualPanelEh; AColIndex, ARowIndex: Integer): TVPBaseCellManagerEh; override;
    function ShowContextMenu(const ScreenPosition: TPointF): Boolean; override;
    function GetDataCellHighlightingText(): String; override;
    function IsShowFocusLayerForCell(ACell: TGridBaseCellEh): Boolean; override;

    function AcquireLayoutLock: Boolean;
    function CalcHeightForDataRow(ADataRowIndex: Integer): Integer; virtual;
    function CalcRowDataRowHeight(DataRowNum: Integer): Integer; virtual;
    function CanSelectType(const Value: TDataGridSelectionTypeEh): Boolean;
    function CreateDataGridCanSelectRowParams(AGrid: TControl; ARow: TDataGridRowEh): TCustomDataGridCanSelectRowParamsEh; virtual;
    function CreateDataGridFilterRowParams: TBaseDataGridFilterRowParamsEh; virtual;
    function CreateGetDataRowManagerParams(): TBaseDataGridGetDataRowManagerParamsEh; virtual;
    function CreateGetDataRowSplitWayParams(): TBaseDataGridGetDataRowSplitWayParamsEh; virtual;
    function CreateDataCellTreeViewAreaParams(): TDataAxisCellTreeViewAreaParamsEh; virtual;
    function CreateFooter(): TDataGridFooterEh; virtual;
    function CreateSearchPanel: TDataGridSearchPanelEh; virtual;
    function DataBox: TGridRect;
    function DataToRawColumn(ADataCol: Integer): Integer;
    function DataToRawRowIndex(ARowIndex: Integer): Integer;
    function DefaultCalcDataRowHeight(Params: TDataGridCalcDataRowHeightParamsEh): Integer; virtual;
    function DefaultGetDataRowSplitWay(Params: TBaseDataGridGetDataRowSplitWayParamsEh): TDataGridRowSplitWayEh; virtual;
    function GetBuildIndicatorTitleCellPopupMenu(AColumnTitle: TColumnTitleEh): TPopupMenu; virtual;
    function GetCellAreaType(AColIndex, ARowIndex: Integer; var AreaCol, AreaRow: Integer): TCellAreaTypeEh;
    function GetCellContextMenu(MousePos: TPoint; ColIndex, RowIndex: Integer): TCustomPopupMenu; virtual;
    function GetCursorForMouseState(MouseState: TDataGridMouseStateEh): TCursor; virtual;
    function GetSubTitleRows: Integer; virtual;
    function GetTitleRows: Integer; virtual;
    function IsRowMatchFilter(ADataRow: TDataGridRowEh): Boolean; virtual;
    function IsTableRowMatchFilter(ATableRow: TDataGridTableRowEh): Boolean; virtual;
    function UpdateOutBoundaryIndents: Boolean; override;
    function VisibleDataRowCount: Integer;
    function CreateGridView: TDataGridRowsViewEh; virtual;
    function CreateGroupingPanelControl: TDataGridGroupingPanelEh; virtual;

    procedure AddChildComponent(const Element: TComponent);
    procedure ApplyStyle; override;
    procedure BarListChanged; override;
    procedure CellMouseMove(ACellMan: TBaseGridCellManagerEh; CellParams: TGridCellMouseParamsEh); override;
    procedure CheckDrawCellBorder(AColIndex, ARowIndex: Integer; BorderType: TGridCellBorderTypeEh; var IsDraw: Boolean; var BorderColor: TAlphaColor; var IsExtent: Boolean); override;
    procedure CheckPropertiesConsistent(); override;
    procedure DataOrPositionChanged(); override;
    procedure DoBeforeFirstDrawing; override;
    procedure DoEnter; override;
    procedure DoMouseLeave; override;
    procedure DoPaint; override;
    procedure DoTabAction(GoForward: Boolean; Shift: TShiftState); override;
//    procedure DrawBordersForCellArea(AColIndex, ARowIndex: Integer; var ARect: TRect; State: TGridDrawState; CellBorderTypes: TGridCellBorderTypesEh = [TGridCellBorderTypeEh.Bottom, TGridCellBorderTypeEh.Right]); override;
    procedure DrawMove; override;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    procedure GetDataForVertScrollBar(var APosition, AMin, AMax, APageSize: Integer); override;
    procedure GetDataForVertScrollBarForDataSet(var APosition, AMin, AMax, APageSize: Integer);
    procedure GetFieldBarListItemBarAtPos(AGridColIndex, AGridRowIndex: Integer; out AFieldBar: TFieldBarEh; out AListItemBar: TTableRowViewEh); override;
    procedure GridTimerEvent(Sender: TObject); override;
    procedure InteractiveMoveColumn(AColMovingState: TGridMouseColMovingStateEh); override;
    procedure InteractiveSetColWidth(ColIndex: Integer; Value: Integer); override;
    procedure InternalLayout; override;
    procedure KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure LinkActive(Value: Boolean); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure Paint; override;
    procedure ProcessVirtPanelMouseDown(APanel: TLaHostVirtualPanelEh; MouseParams: TControlMouseButtonParamsEh); override;
    procedure ProcessVirtPanelMouseMove(APanel: TLaHostVirtualPanelEh; MouseParams: TControlMouseParamsEh); override;
    procedure ProcessPreviewVirtPanelMouseDown(APanel: TLaHostVirtualPanelEh; MouseParams: TControlMouseButtonParamsEh); override;
    procedure ProcessPreviewVirtPanelMouseMove(APanel: TLaHostVirtualPanelEh; MouseParams: TControlMouseParamsEh); override;
    procedure Resize; override;
    procedure Scroll(Distance: Integer);
    procedure SetCellLayoutAffects(); override;
    procedure SetParentComponent(Value: TComponent); override;
    procedure SetPotentialMouseState(ACellParams:  TGridCellMouseParamsEh); override;
    procedure StartColMoving(ColIndex, RowIndex: Integer; AScreenPos: TPointF); override;

    procedure TableViewDataChanged(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowView: TTableRowViewEh); override;
    procedure UpdateActive; override;
    procedure UpdateDisplayFieldBarList(); override;
    procedure UpdateScrollBarPanels; override;
    procedure UpdateScrollBars; override;
    procedure UpdateViewLayout; override;
    procedure UpdateVisibleFieldBarList(); override;
    procedure VertScrollBarMessage(ScrollCode, Pos: Integer); override;
    procedure DisplayFieldBarListChanged; override;
    procedure GridLinesVisibilityChanged; override;
    procedure FontChanged; override;
    procedure RecreateContentControls; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure StyleApplied; override;

    procedure ActualColumnWidthChanged(); virtual;
    procedure BuildTitleCellPopupMenu(Params: TDataGridTitleCellContextMenuParamsEh); virtual;
    procedure ChangeKeySelection(var Key: Word); virtual;
    procedure CheckCellHitSearchPanelData(AColumn: TDataGridBaseColumnEh; ARow: TDataGridRowEh; var Accept: Boolean; SearchText: String); virtual;
    procedure CheckClearSelection;
    procedure ColEnter; virtual;
    procedure ColExit; virtual;
    procedure ColSelectServiceEventHandler(Sender: TObject; MouseParams: TControlMouseParamsEh);
    procedure ColumnWidthChanged(Column: TDataGridBaseColumnEh); virtual;
    procedure ComplexTitleColMovingEventHandler(Sender: TObject; MouseParams: TControlMouseParamsEh);
    procedure ComposeDataCellMenu(ACellParams: TDataAxisCellComposeContextMenuParamsEh); override;
    procedure ComposeTitleCellMenu(Params: TDataGridTitleCellComposeContextMenuParamsEh); virtual;
    procedure DataCellsSelectionServiceEventHandler(Sender: TObject; MouseParams: TControlMouseParamsEh);
    procedure DefaultApplySorting; virtual;
    procedure DrawColumnDesignBorder(AColumn: TDataGridBaseColumnEh); virtual;
    procedure EndLayout;
    procedure GetDataGridMouseState(AMouseX, AMouseY: Single; AColIndex, ARowIndex: Integer; const ACellRect: TRect; AInCellX, AInCellY: Integer; out ADataGridMouseState: TDataGridMouseStateEh; out ACellAreaWantMouseDown: Boolean); virtual;
    procedure HandleCanUserSelectCurrentRow(Params: TCustomDataGridCanSelectRowParamsEh); virtual;
    procedure HandleColumnWidthChanged(Column: TDataGridBaseColumnEh); virtual;
    procedure HandleGetDataCellManager(Params: TBaseDataGridGetDataCellManagerParamsEh); virtual;
    procedure HandleGetDataRowManager(Params: TBaseDataGridGetDataRowManagerParamsEh); virtual;
    procedure HandleGetDataRowSplitWay(Params: TBaseDataGridGetDataRowSplitWayParamsEh); virtual;
    procedure HandleIsRowMatchFilter(Params: TBaseDataGridFilterRowParamsEh); virtual;
    procedure HandleSelectionChanged; virtual;
    procedure HandleGetDataTreeViewAreaParams(Params: TDataAxisCellTreeViewAreaParamsEh); virtual;
    procedure HandleSetDataTreeSignState(Params: TDataAxisCellTreeSignStateParamsEh); virtual;
//    procedure MoveComplexTitleIndexAndScroll(Mouse, CellHit: Integer; Axis: TGridAxisDataEh; Scrollbar: Integer; const MousePt: TPoint);
    procedure NavigatorPanelButtonClick(AButton: TNavigateBtnEh; var Processed: Boolean); virtual;
    procedure NextRow(Select: Boolean; Shift: TShiftState);
    procedure PriorRow(Select: Boolean; Shift: TShiftState);
    procedure ProcessCanUserSelectCurrentRow(Params: TCustomDataGridCanSelectRowParamsEh); virtual;
    procedure ProcessGetDataRowManager(Params: TBaseDataGridGetDataRowManagerParamsEh); virtual;
    procedure ProcessGetDefaultDataRowManager(Params: TBaseDataGridGetDataRowManagerParamsEh); virtual;
    procedure ProcessGetDataRowSplitWay(Params: TBaseDataGridGetDataRowSplitWayParamsEh); virtual;

    procedure ProcessGetDataTreeViewAreaParams(Params: TDataAxisCellTreeViewAreaParamsEh); override;
    procedure DefaultProcessGetTreeViewAreaParams(Params: TDataAxisCellTreeViewAreaParamsEh); virtual;

    procedure ProcessSetDataTreeSignState(Params: TDataAxisCellTreeSignStateParamsEh); override;
    procedure RecalcRowHeightsNeeded;
    procedure RefreshFilteredRows;
    procedure RowSelectServiceEventHandler(Sender: TObject; MouseParams: TControlMouseParamsEh);
    procedure SelectionChanged; reintroduce; virtual;
    procedure SetDataRowCount(NewDataRowCount: Integer);
    procedure SetRowCount(NewRowCount: Integer);
    procedure StartColumnSelection(Column: TDataGridBaseColumnEh; Shift: TShiftState);
    procedure StartComplexTitleColMoving(ATitleNode: TDataGridComplexTitleTreeNodeEh; AScreenPos: TPointF); virtual;
    procedure StartDataCellsSelection(AColIndex, ARowIndex: Integer);
    procedure StartRowSelection(ARowIndex: Integer; Shift: TShiftState);
    procedure StartGroupDescriptionControlMoving(AGroupDescription: TDataGridGroupDescriptionEh; AScreenMousePost: TPointF); virtual;
    procedure RecreateGroupingPanelControl;

    procedure UpdateAllDataRowHeights(); virtual;
    procedure UpdateAllGridDataRowHeights(); virtual;
    procedure UpdateBaseOptions;
    procedure UpdateColumnWidths;
    procedure UpdateDataRowHeight(DataRowNum: Integer); virtual;
    procedure UpdateEditorMode;
    procedure UpdateHighlightingTexts();
    procedure UpdateSearchPanel;
    procedure UpdateGroupingPanel;
    procedure UpdateBaseGridRowIndexFromGridView();
//    procedure UpdateCurrentRowViewIndex();

    property CellRowHeights[Index: Longint]: Integer read GetCellRowHeights write SetCellRowHeights;
    property ColumnsContainer: TDataGridStaticColumnsContainerEh read FColumnsContainer;
    property FullFooterRowCount: Integer read GetFullFooterRowCount;
    property HorzScrollBarPanelControl: TDataGridScrollBarPanelControlEh read GetHorzScrollBarPanelControl;
    property SearchPanelControl: TDataGridSearchPanelControlEh read FSearchPanelControl;
    property GroupingPanel: TDataGridGroupingPanelEh read FGroupingPanel;
    property TopDataOffset: Byte read GetTopDataOffset;
    property VertScrollBarPanelControl: TDataGridScrollBarPanelControlEh read GetVertScrollBarPanelControl;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function RawToDataColumn(AColIndex: Integer): Integer;
    function RawToDataRowIndex(ARowIndex: Integer): Integer;
    function CanSelectRow(ARow: TDataGridRowEh): Boolean;
    function CanTableOperation(AOperation: TDataGridAllowedOperationEh): Boolean; virtual;
    function CalcRowHeightByRowCell(ARow: TDataGridDataRowEh; ADataAreaRowIndex: Integer): Integer;
    function CheckCopyAction: Boolean;
    function CheckCutAction: Boolean;
    function CheckDeleteAction: Boolean;
    function CheckSelectAllAction: Boolean;
    function CheckPasteAction: Boolean;
    function GetRowSplitWay(ARow: TDataGridRowEh): TDataGridRowSplitWayEh;
    function GetDataRowSplitWay(ARow: TDataGridDataRowEh): TDataGridRowSplitWayEh;
    function GetDataRowManagerForRow(ARow: TDataGridRowEh): TVPBaseCellManagerEh;
    function MoveBy(Distance: Integer): Integer;
    function LocateText(AGrid: TCustomDataGridEh; const FieldName: string; const Text: String; Options: TLocateTextOptionsEh; Direction: TLocateTextDirectionEh; Matching: TLocateTextMatchingEh; TreeFindRange: TLocateTextTreeFindRangeEh; TimeOut: LongWord = 0; CheckValueEvent: TCheckColumnValueAcceptEventEh = nil): Boolean; virtual;
    function IsConfirmDelete: Boolean;
    function LocateRow(const ALocateProc: TDataGridLocateFunction): Boolean;
    function FindRow(const ALocateProc: TDataGridLocateFunction): TDataGridRowEh;
    function GetDataTreeViewAreaParams(AColumn: TDataGridBaseColumnEh; ARow: TDataGridDataRowEh): TDataAxisCellTreeViewAreaParamsEh; overload;
    function GetDataTreeViewAreaParams(ARow: TDataGridDataRowEh): TDataAxisCellTreeViewAreaParamsEh; overload;

    procedure DataFirst;
    procedure DataLast;
    procedure DataAppend;
    procedure DataInsert;
    procedure OptimizeAllColsWidth(const CheckRowCount : Integer = -1; const MaxWaitingTime: Integer = 0);
    procedure OptimizeColsWidth(ColumnsList: TColumnsListEh; const CheckRowCount : Integer = -1; const MaxWaitingTime: Integer = 0);
    procedure SaveBookmark;
    procedure RestoreBookmark;
    procedure ApplySorting();
    procedure InteractiveFocusCell(AColIndex, ARowIndex: Integer; ActionSource: TInteractiveActionSourceEh); override;
    procedure ClearSelection;
    procedure DefaultCanSelectCurrentRow(Params: TCustomDataGridCanSelectRowParamsEh); virtual;
    procedure GridColRowToLocalColRowIndex(AColIndex, ARowIndex: Integer; out ALocalColIndex, ALocalRowIndex: Integer); override;
    procedure SafeScrollData(DX, DY: Integer);
    procedure ConfirmAndDeleteRows;
    procedure DeleteCurrentRowOrRows;
    procedure SafeSetTopRollPos(ATopRollPos: Integer);
    procedure SafeSetLeftRollPos(ALeftRollPos: Integer);
    procedure SetDataTreeViewSignState(ARow: TDataGridDataRowEh; ATreeSignState: TTreeSignStateEh; AShift: TShiftState);
    procedure ReloadData;

    property AutoFitColWidths: Boolean read GetAutoFitColWidths;
    property AutoGenerateColumns: Boolean read GetAutoGenerateColumns write SetAutoGenerateColumns default True;
    property Bof: Boolean read GetBof;
    property Center: TDataGridCenterEh read FCenter write SetCenter;
    property ColumnOptions: TDataGridColumnOptionsEh read GetColumnOptions write SetColumnOptions;
    property Columns: TDataGridAllColumnsEh read GetColumns;
    property CurrentColIndex: Integer read GetCurrentColIndex write SetCurrentColIndex;
    property CurrentColumn: TDataGridBaseColumnEh read GetCurrentColumn;
    property CurrentRow: TDataGridRowEh read GetCurrentRow write SetCurrentRow;
    property CurrentDataRow: TDataGridDataRowEh read GetCurrentDataRow;
    property CurrentRowIndex: Integer read GetCurrentRowIndex write SetCurrentRowIndex;
    property DataRowCount: Integer read GetDataRowCount;
    property DisplayColumns: TDataGridDisplayColumnsEh read GetDisplayColumns;
    property DynamicColumns: TDataGridDynamicColumnsEh read GetDynamicColumns;
    property EditActions: TGridEditActionsEh read FEditActions write SetEditActions;
    property Eof: Boolean read GetEof;
    property Footer: TDataGridFooterEh read FFooter write SetFooter;
    property FooterRowCount: Integer read GetFooterRowCount;
    property GridHasAutoRowHeightColumns: Boolean read FGridHasAutoRowHeightColumns;
    property GridLineOptions: TDataGridLineOptionsEh read GetGridLineOptions write SetGridLineOptions;
    property GridMouseStateManage: TDataGridMouseStateManagerEh read GetGridMouseStateManage;
    property HorzAxis;
    property HorzScrollBar: TDataGridHorzScrollBarEh read GetHorzScrollBar write SetHorzScrollBar;
    property IndicatorColumn: TDataGridIndicatorColumnEh read FIndicatorColumn write SetIndicatorColumn;
    property IndicatorTitle: TDataGridIndicatorTitleEh read FIndicatorTitle write SetIndicatorTitle;
    property SearchPanel: TDataGridSearchPanelEh read FSearchPanel write SetSearchPanel;
    property SearchPanelMode: Boolean read FSearchPanelMode write SetSearchPanelMode;
    property SelectedRows: TDataGridSelectedRowsEh read GetSelectedRows;
    property Selection: TDataGridSelectionEh read FSelection write SetSelection;
    property SelectionOptions: TDataGridSelectionOptionsEh read FSelectionOptions write SetSelectionOptions;
    property StartDataColIndex: Integer read FStartDataColIndex;
    property StartDataRowIndex: Integer read FStartDataRowIndex;
    property StaticColumns: TStaticColumnsEh read GetStaticColumns write SetStaticColumns;
    property StylePainter: TDataGridStylePainterEh read GetStylePainter;
    property TableView: TDataGridTableRowsViewEh read GetTableView;
    property GridView: TDataGridRowsViewEh read GetGridView;
    property Title: TDataGridTitleBarEh read GetTitle write SetTitle;
    property VertAxis;
    property VertScrollBar: TDataGridVertScrollBarEh read GetVertScrollBar write SetVertScrollBar;
    property VisibleColumns: TDataGridVisibleColumnsEh read GetVisibleColumns;
    property VisibleRows: TDataGridRowsEh read GetVisibleRows;
    property FrozenLeftColCount: Integer read FFrozenLeftColCount;
    property FrozenRightColCount: Integer read FFrozenRightColCount;
    property DataGrouping: TDataGridDataGroupingEh read FDataGrouping write SetDataGrouping;

    property OnCalcDataRowHeight: TDataGridCalcDataRowHeightEventEh read FOnCalcDataRowHeight write FOnCalcDataRowHeight;
  end;

{ TDataGridEhPainter }

  TDataGridStylePainterEh = class(TBaseGridStylePainterEh)
  private
    FDownTriangle: TControl;
//    FFilterDropDownButton: TBackstageButtonEh;
//    FFilterDropDownButtonSign: TControl;
    FGridCurrentRow: TControl;
    FGridEditRow: TControl;
    FGridNewRow: TControl;
    FLeftTriangle: TControl;
    FReady: Boolean;
    FRightTriangle: TControl;
    FSortMarker: TControl;

    FTitleFill: TBrush;
    FIndicatorFill: TBrush;

    function GetDownTriangle: TControl;
//    function GetFilterDropDownButton: TBackstageButtonEh;
    function GetGridCurrentRow: TControl;
    function GetGridEditRow: TControl;
    function GetGridNewRow: TControl;
    function GetLeftTriangle: TControl;
    function GetRightTriangle: TControl;
    function GetSortMarker: TControl;
    procedure SetTitleFill(const Value: TBrush);
    procedure SetIndicatorFill(const Value: TBrush);

  protected
    procedure LoadStyleItems; override;
    procedure FreeStyleItems; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function GetFilterDropDownButtonDefaultSize(Canvas: TCanvas): TSize; virtual;
    function GetSortMarkerAreaSize(Canvas: TCanvas; SortOrder: TSortOrderEh; SortIndex: Integer): TSize; virtual;

    property DownTriangle: TControl read GetDownTriangle;
//    property FilterDropDownButton: TBackstageButtonEh read GetFilterDropDownButton;
    property GridCurrentRow: TControl read GetGridCurrentRow;
    property GridEditRow: TControl read GetGridEditRow;
    property GridNewRow: TControl read GetGridNewRow;
    property LeftTriangle: TControl read GetLeftTriangle;
    property RightTriangle: TControl read GetRightTriangle;
    property SortMarker: TControl read GetSortMarker;

    property TitleFill: TBrush read FTitleFill write SetTitleFill;
    property IndicatorFill: TBrush read FIndicatorFill write SetIndicatorFill;

    property Ready: Boolean read FReady;
  end;

//function SetDataGridStylePainterEh(NewStylePainter: TDataGridStylePainterEh): TDataGridStylePainterEh;
//function DataGridStylePainterEh: TDataGridStylePainterEh;

implementation

uses
  Data.DBConsts,
  FMX.DialogService,
  EhLibLangConsts,
  EhLibFmx.DataGrids,
  EhLibFmx.CustomizeColumnsDialog,
  EhLibFmx.DataGrid.ImpExp,
  EhLibFmx.ImageReses;

type
  TDataGridTitleBarEhCrack = class(TDataGridTitleBarEh);
  TDataGridEhIndicatorColumnCrack = class(TDataGridIndicatorColumnEh);
  TControlCrack = class(TControl);
  TDataGridEhSelectionCrack = class(TDataGridSelectionEh);
  TDataGridSearchPanelEhCrack = class(TDataGridSearchPanelEh);
  TDataGridEhNavigatorPanelCrack = class(TDataGridNavigatorPanelEh);
  TDataGridComplexTitleTreeListEhCrack = class(TDataGridComplexTitleTreeListEh);
  TDataGridDataGroupingEhCrack = class(TDataGridDataGroupingEh);

function MiddleDotChar: Char;
begin
  Result := Char($B7);
end;

//var
//  FDataGridStylePainterEh: TDataGridStylePainterEh = nil;
//
procedure InitModule;
begin
//  FDataGridStylePainterEh := TDataGridStylePainterEh.Create(nil);
end;

procedure FinalizeModule;
begin
//  FreeAndNil(FDataGridStylePainterEh);
end;

{$REGION 'TCustomDataGridEh'}

{ TCustomDataGridEh }

constructor TCustomDataGridEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FColumnsContainer := TDataGridStaticColumnsContainerEh.Create(Self);
  FDesignInteractive := True;

  FGridView := CreateGridView;

  Center := DataGridCenterEh;
  FInterlinear := 4;

//  FStylePainter := CreateStylePainter();
//  FStylePainter := TDataGridStylePainterEh.Create(nil);
//  FStylePainter.Visible := False;
//  FStylePainter.Parent := Self;

  FEditActions := TGridEditActionsEh.Create(Self);

  FMoveAndScrollService := TDataGridMoveAndScrollServiceEh.Create(Self);

  FIndicatorColumn := TDataGridIndicatorColumnEh.Create(Self);
  FIndicatorTitle := TDataGridIndicatorTitleEh.Create(Self);
  FFooter := CreateFooter();
  FFooter.Name := 'Footer';

  FVisibleRowList := TList<TDataGridRowEh>.Create;
  FVisibleRows := TDataGridRowsEh.Create(FVisibleRowList);
  FDataGrouping := TDataGridDataGroupingEh.Create(Self, FVisibleRowList);

  FDataRowHeights := TList<Integer>.Create;

  FSelection := TDataGridSelectionEh.Create(Self);
  FSelectionOptions := TDataGridSelectionOptionsEh.Create(Self);

  UpdateBaseOptions();

  FSearchPanel := CreateSearchPanel;
  FSearchPanel.Name := 'SearchPanel';

  FSearchPanelControl := TDataGridSearchPanelControlEh.Create(Self);
  FSearchPanelControl.Parent := Self;
  FSearchPanelControl.Name := 'FSearchPanelControl';
  FSearchPanelControl.Visible := False;
  FSearchPanelControl.SetBounds(0,0,0,0);

  FHighlightingTexts := TList<String>.Create;

  LayoutChanged;
  ResetData;
end;

destructor TCustomDataGridEh.Destroy;
begin
  Destroying;
  DataSource := nil;

  Center := nil;
  Selection.Clear;
  Title.IsComplexTitle := False;

  FreeAndNil(FColumnsContainer);
  FreeAndNil(FEditActions);
  FreeAndNil(FDataRowHeights);

  FreeAndNil(FIndicatorColumn);
  FreeAndNil(FIndicatorTitle);
  FreeAndNil(FFooter);
  FreeAndNil(FSelectionOptions);
  FreeAndNil(FSelection);
  FreeAndNil(FMoveAndScrollService);

  FreeAndNil(FSearchPanelControl);
  FreeAndNil(FSearchPanel);
  FreeAndNil(FGroupingPanel);
  FreeAndNil(FHighlightingTexts);
  FreeAndNil(FRowSizeCalculatorCellObject);

  FreeAndNil(FDataGrouping);
  FreeAndNil(FVisibleRows);
  FreeAndNil(FVisibleRowList);
  FreeAndNil(FGridView);

  inherited Destroy;
end;

procedure TCustomDataGridEh.SetCenter(const Value: TDataGridCenterEh);
begin
  if FCenter = Value then Exit;
  if FCenter <> nil then
    FCenter.RemoveChangeNotification(Self);
  FCenter := Value;
  if Value <> nil then
    FCenter.AddChangeNotification(Self);
end;

procedure TCustomDataGridEh.SetEditActions(const Value: TGridEditActionsEh);
begin
  FEditActions.Assign(Value);
end;

procedure TCustomDataGridEh.SetFooter(const Value: TDataGridFooterEh);
begin
  FFooter.Assign(Value);
end;

function TCustomDataGridEh.GetStaticColumns: TStaticColumnsEh;
begin
  Result := TStaticColumnsEh(StaticFieldBars);
end;

function TCustomDataGridEh.GetStylePainter: TDataGridStylePainterEh;
begin
  Result := TDataGridStylePainterEh(inherited StylePainter);
end;

procedure TCustomDataGridEh.SetStaticColumns(const Value: TStaticColumnsEh);
begin
  StaticColumns.Assign(Value);
end;

function TCustomDataGridEh.GetDynamicColumns: TDataGridDynamicColumnsEh;
begin
  Result := TDataGridDynamicColumnsEh(DynamicFieldBars);
end;

function TCustomDataGridEh.CreateStaticFieldBars: TGridStaticFieldBarsEh;
begin
  Result := TStaticColumnsEh.Create(Self);
end;

function TCustomDataGridEh.CreateStylePainter: TBaseGridStylePainterEh;
begin
  Result := TDataGridStylePainterEh.Create(Self);
end;

function TCustomDataGridEh.CreateAllFieldBarList(ABaseList: TList<TFieldBarEh>): TGridAllFieldBarListEh;
begin
  Result := TDataGridAllColumnsEh.Create(Self, ABaseList);
end;

function TCustomDataGridEh.CreateDisplayFieldBars(ABaseList: TList<TFieldBarEh>): TGridDisplayFieldBarsEh;
begin
  Result := TDataGridDisplayColumnsEh.Create(Self, ABaseList);
end;

function TCustomDataGridEh.CreateGridTableView: TDataAxisGridTableViewEh;
begin
  Result := TDataGridTableRowsViewEh.Create(Self);
end;

function TCustomDataGridEh.CreateGridView: TDataGridRowsViewEh;
begin
  Result := TDataGridRowsViewEh.Create(Self);
end;

function TCustomDataGridEh.CreateFooter: TDataGridFooterEh;
begin
  Result := TDataGridFooterEh.Create(Self);
end;

function TCustomDataGridEh.CreateVisibleFieldBars(ABaseList: TList<TFieldBarEh>): TGridVisibleFieldBarsEh;
begin
  Result := TDataGridVisibleColumnsEh.Create(Self, ABaseList);
end;

function TCustomDataGridEh.CreateDynamicFieldBars(ABaseList: TList<TFieldBarEh>): TGridDynamicFieldBarsEh;
begin
  Result := TDataGridDynamicColumnsEh.Create(Self, ABaseList);
end;

function TCustomDataGridEh.CreateFieldBarOptions: TFieldBarOptionsEh;
begin
  Result := TDataGridColumnOptionsEh.Create(Self);
end;

procedure TCustomDataGridEh.GridColRowToLocalColRowIndex(AColIndex, ARowIndex: Integer;
  out ALocalColIndex, ALocalRowIndex: Integer);
var
  ADataRect: TGridRect;
begin
  ADataRect := DataBox;

  if (AColIndex < 0) then
    ALocalColIndex := AColIndex
  else if (AColIndex < ADataRect.Left) then
    
    ALocalColIndex := AColIndex
  else
    
    ALocalColIndex := AColIndex - StartDataColIndex;

  if (ARowIndex < 0) then
    ALocalRowIndex := ARowIndex
  else if (ARowIndex < GetTitleRows) then
    
    ALocalRowIndex := ARowIndex
  else if (ARowIndex >= GetTitleRows) and (ARowIndex <= ADataRect.Bottom) then
    
    ALocalRowIndex := ARowIndex - StartDataRowIndex
  else if (ARowIndex > ADataRect.Bottom) then
    
    ALocalRowIndex := ARowIndex - ADataRect.Bottom - 1;
end;

procedure TCustomDataGridEh.BarListChanged;
begin
  TDataGridTitleBarEhCrack(Title).FHeightRecalcNeeded := True;
  RecalcRowHeightsNeeded;
  inherited BarListChanged;
  Footer.RecalcValues();
end;

procedure TCustomDataGridEh.ColumnWidthChanged(Column: TDataGridBaseColumnEh);
begin
  if IsLoading = False then
    HandleColumnWidthChanged(Column);

  TDataGridTitleBarEhCrack(Title).FHeightRecalcNeeded := True;
  RecalcRowHeightsNeeded;
  LayoutChanged;
end;

procedure TCustomDataGridEh.HandleColumnWidthChanged(Column: TDataGridBaseColumnEh);
begin

end;

procedure TCustomDataGridEh.ActualColumnWidthChanged();
begin
  TDataGridTitleBarEhCrack(Title).FHeightRecalcNeeded := True;
  RecalcRowHeightsNeeded;
  LayoutChanged;
end;

procedure TCustomDataGridEh.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  Col: TDataGridBaseColumnEh;
  I: Integer;
  TitleNode: TDataGridComplexTitleTreeNodeEh;
begin
  if Title.IsComplexTitle = True then
  begin
    for I := 0 to Title.ComplexTitleTree.RootNode.Count - 1 do
    begin
      TitleNode := Title.ComplexTitleTree.RootNode.Items[I];
      if TitleNode.NodeType = TDataGridCompoundTitleTreeNodeTypeEh.SuperTitleNode then
      begin
        Proc(TitleNode.SuperTitle);
      end else
      begin
        Proc(TitleNode.Column);
      end;
    end;
  end else
  begin
    for I := 0 to StaticColumns.Count - 1 do
    begin
      Col := StaticColumns[I];
      Proc(Col);
    end;
  end;
end;

procedure TCustomDataGridEh.AddChildComponent(const Element: TComponent);
begin
  ColumnsContainer.AddChildren(nil, Element);
end;

procedure TCustomDataGridEh.SetParentComponent(Value: TComponent);
begin
  inherited SetParentComponent(Value);
end;

function TCustomDataGridEh.AcquireLayoutLock: Boolean;
begin
  Result := (FLayoutLock = 0);
  if Result then BeginLayout;
end;

procedure TCustomDataGridEh.BeginLayout;
begin
  BeginUpdate;
  Inc(FLayoutLock);
end;

procedure TCustomDataGridEh.EndLayout;
begin
  if FLayoutLock > 0 then
  begin
    try
      try
        if FLayoutLock = 1 then
          InternalLayout;
      finally
      end;
    finally
      if FLayoutLock > 0 then
        Dec(FLayoutLock);
      EndUpdate;
      if not (csDestroying in ComponentState) then
        UpdateBoundaries;
    end;
  end;
end;

procedure TCustomDataGridEh.InteractiveFocusCell(AColIndex, ARowIndex: Integer;
  ActionSource: TInteractiveActionSourceEh);
var
  NewDataRowIndex: Integer;
begin
  if not GridView.Active then Exit;

  CheckClearSelection;

  if (AColIndex <> CurColIndex) and
     (SelectionOptions.RowSelect = False) then
  begin
    CheckWritePendingData;
    MoveCol(RawToDataColumn(AColIndex), 0, False, False);
  end;

  NewDataRowIndex := RawToDataRowIndex(ARowIndex);
  MoveBy(NewDataRowIndex - CurrentRowIndex);
end;

procedure TCustomDataGridEh.InteractiveSetColWidth(ColIndex, Value: Integer);

  procedure SetWeightColumnWidth(Column: TDataGridBaseColumnEh; Value: Integer);
  var
    WeightRestViewWidth: Single;
    WeightRestColsFull: Single;
    PixelColsWidth: Single;
    c: Integer;
    NewColWeight: Single;
  begin
    PixelColsWidth := 0;
    for c := 0 to VisibleColumns.Count - 1 do
    begin
      if VisibleColumns[c].ColSizeUnit = TGridColSizeUnitEh.Pixels  then
      begin
        PixelColsWidth := PixelColsWidth + VisibleColumns[c].Width;
      end;
    end;

    WeightRestViewWidth := HorzAxis.RollClientLen - PixelColsWidth - Value;
    if WeightRestViewWidth < 0 then Exit;

    WeightRestColsFull := 0;
    for c := 0 to VisibleColumns.Count - 1 do
    begin
      if (VisibleColumns[c].ColSizeUnit = TGridColSizeUnitEh.Weight) and
         (VisibleColumns[c] <> Column) then
      begin
        WeightRestColsFull := WeightRestColsFull + VisibleColumns[c].Width;
      end;
    end;

    NewColWeight := Value * WeightRestColsFull / WeightRestViewWidth;
    Column.Width := NewColWeight;
  end;

var
  Column: TDataGridBaseColumnEh;
  I: Integer;
begin
  if (ColIndex >= StartDataColIndex) and
     ((ColIndex - StartDataColIndex) < VisibleColumns.Count)  then
  begin
    Column := VisibleColumns[ColIndex - StartDataColIndex];

    if (Selection.SelectionType = TDataGridSelectionTypeEh.Columns) and
       (Column.IsSelected = True) and
       (Column.ColSizeUnit = TGridColSizeUnitEh.Pixels) then
    begin
      for I := 0 to VisibleColumns.Count - 1 do
      begin
        if (VisibleColumns[I].IsSelected) then
          VisibleColumns[I].Width := Value;
      end;
    end
    else
    begin
      if (Column.ColSizeUnit = TGridColSizeUnitEh.Pixels) then
        Column.Width := Value
      else
        SetWeightColumnWidth(Column, Value);
    end;
  end
  else
  begin
    inherited InteractiveSetColWidth(ColIndex, Value);
  end;
end;

procedure TCustomDataGridEh.InteractiveMoveColumn(AColMovingState: TGridMouseColMovingStateEh);
var
  Column: TDataGridBaseColumnEh;
  DataFromIndex, DataToIndex: Integer;
  GroupDescription: TDataGridGroupDescriptionEh;
begin
  if (AColMovingState.MoveFromIndex = -1) and (AColMovingState.ExtraData is TDataGridGroupDescriptionEh) then
  begin
    GroupDescription := TDataGridGroupDescriptionEh(AColMovingState.ExtraData);
    AColMovingState.ExtraData := nil;
    Column := GroupDescription.Column;
    GroupDescription.Free;
    if Column <> nil then
    begin
      DataToIndex := RawToDataColumn(AColMovingState.MoveToIndex);
      Column.Visible := True;
      VisibleColumns.MoveColumn(Column, DataToIndex);
    end;
  end
  else
  begin
    DataFromIndex := RawToDataColumn(AColMovingState.MoveFromIndex);
    DataToIndex := RawToDataColumn(AColMovingState.MoveToIndex);
    if Selection.SelectionType = TDataGridSelectionTypeEh.Columns then
    begin
      VisibleColumns.MoveColumns(TColumnsListEh(Selection.Columns), DataToIndex);
    end else
    begin
      Column := VisibleColumns[DataFromIndex];
      VisibleColumns.MoveColumn(Column, DataToIndex);
    end;
  end
end;

procedure TCustomDataGridEh.InternalLayout;
begin
  inherited InternalLayout;

  if (csLoading in ComponentState) or
     (csDestroying in ComponentState) or
     (Canvas = nil)
  then
    Exit;

  UpdateActive;
end;

procedure TCustomDataGridEh.UpdateVisibleFieldBarList();
begin
  inherited UpdateVisibleFieldBarList();
  if Title.IsComplexTitle then
    TDataGridComplexTitleTreeListEhCrack(Title.ComplexTitleTree).UpdateVisibleNodes();
end;


procedure TCustomDataGridEh.UpdateViewLayout;
var
  NewColCount: Integer;

  procedure SetColsCount(AColCount, AFixedColCount, AFrozenColCount, AContraColCount: Integer);
  begin
    if AColCount <= FixedColCount then
      FixedColCount := AColCount - 1;
    if FixedColCount <> AFixedColCount then
    begin
      if AFixedColCount < FrozenColCount then
        FrozenColCount := 0;
      FixedColCount := AFixedColCount;
    end;
    FrozenColCount := AFrozenColCount;
    ColCount := AColCount;
    ContraColCount := AContraColCount;
  end;

begin
  if IndicatorColumn.Visible then
  begin
    TDataGridEhIndicatorColumnCrack(IndicatorColumn).FBaseColIndex := 0;
    if FStartDataColIndex <> 1 then
    begin
      FStartDataColIndex := 1;
      RaiseCurrentChangedEvent();
    end;
  end else
  begin
    TDataGridEhIndicatorColumnCrack(IndicatorColumn).FBaseColIndex := -1;
    if FStartDataColIndex <> 0 then
    begin
      FStartDataColIndex := 0;
      RaiseCurrentChangedEvent();
    end;
  end;

  if Title.Visible then
  begin
    if FStartDataRowIndex <> 1 then
    begin
      FStartDataRowIndex := 1;
      TDataGridTitleBarEhCrack(Title).FTitleRowIndex := 0;
//      RaiseCurrentChangedEvent();
    end;
  end else
  begin
    if FStartDataRowIndex <> 0 then
    begin
      FStartDataRowIndex := 0;
      TDataGridTitleBarEhCrack(Title).FTitleRowIndex := -1;
//      RaiseCurrentChangedEvent();
    end;
  end;

  if (VisibleColumns.Count > 0)
    then NewColCount := VisibleColumns.Count
    else NewColCount := 1;

  SetColsCount(NewColCount - FFrozenRightColCount + FStartDataColIndex,
               FStartDataColIndex + FFrozenLeftColCount,
               FFrozenLeftColCount,
               FFrozenRightColCount);

  UpdateDefaultRowHeight;
  if (Title.Visible) then
    FTitleRowHeight := CalcTitleRowHeight;

  Footer.RecalcFooterHeights();

  UpdateGridRowCount;
  UpdateColumnWidths;

  inherited UpdateViewLayout;
end;

procedure TCustomDataGridEh.SetRowCount(NewRowCount: Integer);
begin
  if NewRowCount <> RowCount then
  begin
    if NewRowCount <= CurRowIndex then
      MoveColRow(CurColIndex, NewRowCount - 1, False, False);
    RowCount := NewRowCount;
    AdjustMaxTopLeft(True, True, not IsSmoothHorzScroll, not IsSmoothVertScroll);
  end;
end;

procedure TCustomDataGridEh.SetDataRowCount(NewDataRowCount: Integer);
var
  I: Integer;
begin
  SetRowCount(NewDataRowCount + TopDataOffset);

  if FDataRowHeights.Count > NewDataRowCount then
  begin
    while FDataRowHeights.Count > NewDataRowCount do
    begin
      FDataRowHeights.Delete(FDataRowHeights.Count - 1);
    end;
  end
  else if FDataRowHeights.Count < NewDataRowCount then
  begin
    for I := 0 to NewDataRowCount - FDataRowHeights.Count - 1 do
    begin
      FDataRowHeights.Add(FStdDefaultRowHeight);
    end;
  end;
end;

procedure TCustomDataGridEh.UpdateGridRowCount;
begin
  if Parent = nil then Exit;
  UpdateGridMTRowCount();
end;

procedure TCustomDataGridEh.SetCellLayoutAffects();
begin
  inherited SetCellLayoutAffects();
  RecalcRowHeightsNeeded();
end;

procedure TCustomDataGridEh.RecalcRowHeightsNeeded();
begin
  FUpdatingDataRowHeightsNeeded := True;
end;

procedure TCustomDataGridEh.UpdateGridMTRowCount;

  procedure ResetFixedRows;
  begin
    FrozenRowCount := 0;
    FixedRowCount := TopDataOffset;
    FrozenRowCount := GetSubTitleRows;
  end;

  procedure UpdateFooterRowHeights;
  var
    i: Integer;
    RowHeight: Integer;
  begin
    for i := 0 to FooterRowCount - 1 do
    begin
      RowHeight := Footer.Rows[i].RowHeight;
      if RowHeight = 0 then
        RowHeight := FStdDefaultRowHeight;
      RowHeights[RowCount + i] := RowHeight;
    end;
  end;

  procedure UpdateBaseDataRowHeights();
  var
    i: Integer;
  begin
    for i := 0 to DataRowCount - 1 do
    begin
      if i < VisibleRows.Count then
        CellRowHeights[i + StartDataRowIndex] := FDataRowHeights[i]
      else
        CellRowHeights[i + StartDataRowIndex] := FStdDefaultRowHeight;
    end;
  end;

var
  NewDataRowCount: Integer;
  NewCol, NewRow: Integer;
  t: Integer;
  ShowCol: Boolean;
  I: Integer;
  TitleAreaHeight: Integer;
begin
  if GridView = nil then Exit;

  ResetFixedRows;
  if Title.Visible then
  begin
    TitleAreaHeight := FTitleRowHeight;
    if (Title.IsComplexTitle = False) and
       (GridLineOptions.HorzLinesVisible = True)
    then
      TitleAreaHeight := TitleAreaHeight + GridLineWidth;
    RowHeights[0] := TitleAreaHeight;
    VisibleColumns.UpdateTitleMetrics;
  end;

  ContraRowCount := FullFooterRowCount;
  if FullFooterRowCount > 0 then
    UpdateFooterRowHeights;

  t := RowHeights[0];
  DefaultRowHeight := FStdDefaultRowHeight;
  if Title.Visible then
    RowHeights[0] := t;
  NewDataRowCount := VisibleRows.Count;
  if NewDataRowCount <= 0 then NewDataRowCount := 1;
  SetDataRowCount(NewDataRowCount);
  if FullFooterRowCount > 0 then
    UpdateFooterRowHeights;

  if not IsCanvasEnabled then Exit;

  FGridHasAutoRowHeightColumns := False;
  for I := 0 to VisibleColumns.Count - 1 do
  begin
    if VisibleColumns[I].HeightAutoExpand then
    begin
      FGridHasAutoRowHeightColumns := True;
      Break;
    end;
  end;

  if (FUpdatingDataRowHeightsNeeded = True)
  then
  begin
    UpdateAllDataRowHeights();
    FUpdatingDataRowHeightsNeeded := False;
  end;
  UpdateBaseDataRowHeights();

  if (GridView.Active = True) then
  begin
    InvalidateRow(CurRowIndex);

    if GridView.CurrentRowIndex = -1
      then NewRow := FixedRowCount
      else NewRow := GridView.CurrentRowIndex + TopDataOffset;
    if NewRow >= RowCount then
      NewRow := FixedRowCount;

    ShowCol := not (SelectionOptions.RowSelect);
    if CurColIndex < FixedColCount then
    begin
      NewCol := CurColIndex;
      MoveColRow(FixedColCount, NewRow, ShowCol, True);
      MoveColRow(NewCol, NewRow, False, False);
    end else
      MoveColRow(CurColIndex, NewRow, ShowCol, True);

    InvalidateRow(CurRowIndex);
  end;

  Invalidate;
end;

function TCustomDataGridEh.CalcTitleRowHeight: Integer;
var
  I: Integer;
  Height: Integer;
  ColumnTitle: TColumnTitleEh;
begin
  Result := 0;
  if Scene = nil then Exit;
  if TDataGridTitleBarEhCrack(Title).HeightRecalcNeeded = False then
  begin
    Result := TDataGridTitleBarEhCrack(Title).FTitleHeight;
    Exit;
  end;

  if Title.IsComplexTitle then
  begin
    Title.ComplexTitleTree.CalcTitleSize;
    Result := Title.ComplexTitleTree.TitleSize.Height;
  end else
  begin
    for I := 0 to VisibleColumns.Count - 1 do
    begin
      ColumnTitle := VisibleColumns[I].Title;
      Height := ColumnTitle.CalcCellHeight(Canvas, Round(ColumnTitle.Column.Width));
      if Height > Result then
        Result := Height;
    end;

    if Result = 0 then
    begin
      Canvas.Font.Assign(Title.Font);
      Height := Round(Canvas.TextHeight('Wg') + Title.Padding.Top + Title.Padding.Bottom);
      Result := Height;
    end;
  end;

  TDataGridTitleBarEhCrack(Title).FTitleHeight := Result;
  TDataGridTitleBarEhCrack(Title).FHeightRecalcNeeded := False;
end;

procedure TCustomDataGridEh.UpdateDefaultRowHeight();
var
  I: Integer;
  Column: TDataGridBaseColumnEh;
  ColHeight: Integer;
begin
  FStdDefaultRowHeight := 0;

  if Canvas = nil then Exit;

  for I := 0 to VisibleColumns.Count - 1 do
  begin
    Column := VisibleColumns[I];
    ColHeight := Column.CalcDefaultRowHeight(Canvas);
    if ColHeight > FStdDefaultRowHeight then
      FStdDefaultRowHeight := ColHeight;
  end;

  if FStdDefaultRowHeight = 0 then
  begin
    Canvas.Font.Assign(Font);
    FStdDefaultRowHeight := Round(Canvas.TextHeight('Wg') +
                                  ColumnOptions.Padding.Top +
                                  ColumnOptions.Padding.Bottom);
  end;

  DataGrouping.CheckRecalcGroupDescriptionsHeight();
end;

procedure TCustomDataGridEh.UpdateDataRowHeight(DataRowNum: Integer);
var
  NewHeight: Integer;
begin
  if DataRowNum < FDataRowHeights.Count then
  begin
    NewHeight := CalcRowDataRowHeight(DataRowNum);
    FDataRowHeights[DataRowNum] := NewHeight;
  end;
end;

function TCustomDataGridEh.CalcRowDataRowHeight(DataRowNum: Integer): Integer;
var
  NewHeight: Integer;
begin
  Result := FStdDefaultRowHeight;
  NewHeight := CalcHeightForDataRow(DataRowNum);
  if NewHeight > Result then
    Result := NewHeight;
end;

function TCustomDataGridEh.CalcRowHeightByRowCell(ARow: TDataGridDataRowEh; ADataAreaRowIndex: Integer): Integer;
var
  RowCellManager: TVPBaseCellManagerEh;
  QrCellSize: TSizeF;
  ResCellSize: TSizeF;
  AGridRowIndex: Integer;
begin
  RowCellManager := GetDataRowManagerForRow(ARow);

  if FRowSizeCalculatorCellObject = nil then
  begin
    FRowSizeCalculatorCellObject := RowCellManager.CreateCellHolder;
  end else if FRowSizeCalculatorCellObject.CellManager <> RowCellManager then
  begin
    FRowSizeCalculatorCellObject.Free;
    FRowSizeCalculatorCellObject := RowCellManager.CreateCellHolder;
  end;

  QrCellSize := TSizeF.Create(HorzAxis.RollLen, TLaControlEh.MaxSize.Height);
  AGridRowIndex := ADataAreaRowIndex + StartDataRowIndex;

//  RowCellManager.InternalInitCellHolderPositionProps(FRowSizeCalculatorCellObject, Self, -1, AGridRowIndex, -1, ADataAreaRowIndex);
//  RowCellManager.InternalInitCellHolder(FRowSizeCalculatorCellObject);
//  FRowSizeCalculatorCellObject.SetLayoutChangedForAll();
//  ResCellSize := FRowSizeCalculatorCellObject.QueryLayout(QrCellSize, Canvas);
  ResCellSize := RowCellManager.InitAndCaclRenderCellHolder(
    Self, QrCellSize, FRowSizeCalculatorCellObject, -1, AGridRowIndex, -1, ADataAreaRowIndex);
  Result := Round(ResCellSize.Height);
end;

function TCustomDataGridEh.DefaultCalcDataRowHeight(Params: TDataGridCalcDataRowHeightParamsEh): Integer;
var
  i: Integer;
  ColHeight: Integer;
  Column: TDataGridBaseColumnEh;
  Row: TDataGridRowEh;
  DataRow: TDataGridDataRowEh;
  RowSplitWay: TDataGridRowSplitWayEh;
  GroupHeaderRow: TDataGridGroupHeaderRowEh;
begin
  if (Params.DataAreaRowIndex >= 0) and (Params.DataAreaRowIndex < VisibleRows.Count)
    then Row := VisibleRows[Params.DataAreaRowIndex]
    else Row := nil;
  if Row is TDataGridDataRowEh then
  begin
    Result := FStdDefaultRowHeight;
    if (GridHasAutoRowHeightColumns = True) then
    begin

      DataRow := TDataGridDataRowEh(Row);

      if Row <> nil
        then RowSplitWay := GetDataRowSplitWay(DataRow)
        else RowSplitWay := TDataGridRowSplitWayEh.SplitByCell;

      if RowSplitWay = TDataGridRowSplitWayEh.NoSplit then
      begin
        Result := CalcRowHeightByRowCell(DataRow, Params.DataAreaRowIndex);
      end else
      begin
        for i := 0 to Columns.Count-1 do
        begin
          Column := Columns[i];
          if (Column.Visible = True) and
             (Column.CellHeightIsRowDependent = True) then
          begin
             ColHeight := Column.CalcRowHeight(Canvas, Params.DataAreaRowIndex);
             if ColHeight > Result then
               Result := ColHeight;
          end;
        end;
      end;
    end;
  end
  else if Row is TDataGridGroupHeaderRowEh then
  begin
    GroupHeaderRow := TDataGridGroupHeaderRowEh(Row);
    Result := GroupHeaderRow.GroupDescription.DefaultRowHeight;
  end else
  begin
    Result := DefaultRowHeight;
  end;
end;

function TCustomDataGridEh.CalcHeightForDataRow(ADataRowIndex: Integer): Integer;
var
  RowHeightParams: TDataGridCalcDataRowHeightParamsEh;
begin
  Result := FStdDefaultRowHeight;

  RowHeightParams := TDataGridCalcDataRowHeightParamsEh.Create(Self, ADataRowIndex);
  RowHeightParams.RowHeight := Result;
  try
    if Assigned(OnCalcDataRowHeight) then
      OnCalcDataRowHeight(Self, RowHeightParams);
    if RowHeightParams.Handled then
      Result := RowHeightParams.RowHeight
    else
      Result := RowHeightParams.DefaultCalcRowHeight(RowHeightParams);
  finally
    RowHeightParams.Free;
  end;

end;

procedure TCustomDataGridEh.UpdateAllDataRowHeights();
begin
  if csLoading in ComponentState then Exit;
  UpdateAllGridDataRowHeights();
end;

procedure TCustomDataGridEh.UpdateAllGridDataRowHeights();
var
  i: Integer;
begin
  if GridView.Active and
     (VisibleRows.Count > 0)
  then
  begin
    try
      BeginLayout;

      for i := 0 to VisibleRows.Count - 1 do
        UpdateDataRowHeight(i);
    finally
      EndLayout;
    end;
  end else
  begin
    CellRowHeights[TopDataOffset] := FStdDefaultRowHeight;
  end;
end;

function TCustomDataGridEh.CreateGetDataRowSplitWayParams(): TBaseDataGridGetDataRowSplitWayParamsEh;
begin
  Result := TBaseDataGridGetDataRowSplitWayParamsEh.Create;
end;

function TCustomDataGridEh.GetRowSplitWay(ARow: TDataGridRowEh): TDataGridRowSplitWayEh;
begin
  if (ARow is TDataGridDataRowEh) then
    Result := GetDataRowSplitWay(TDataGridDataRowEh(ARow))
  else if ARow is TDataGridGroupHeaderRowEh then
    Result := TDataGridRowSplitWayEh.NoSplit
  else
    Result := TDataGridRowSplitWayEh.SplitByCell;
end;

function TCustomDataGridEh.GetDataRowSplitWay(ARow: TDataGridDataRowEh): TDataGridRowSplitWayEh;
var
  RowSplitWayParams: TBaseDataGridGetDataRowSplitWayParamsEh;
begin
  RowSplitWayParams := CreateGetDataRowSplitWayParams();
  try
    RowSplitWayParams.Reset(Self, ARow, TDataGridRowSplitWayEh.SplitByCell);
    ProcessGetDataRowSplitWay(RowSplitWayParams);
    Result := RowSplitWayParams.RowSplitWay;
  finally
    RowSplitWayParams.Free;
  end;
end;

procedure TCustomDataGridEh.ProcessGetDataRowSplitWay(Params: TBaseDataGridGetDataRowSplitWayParamsEh);
begin
  HandleGetDataRowSplitWay(Params);
end;

procedure TCustomDataGridEh.HandleGetDataRowSplitWay(Params: TBaseDataGridGetDataRowSplitWayParamsEh);
begin
end;

function TCustomDataGridEh.DefaultGetDataRowSplitWay(Params: TBaseDataGridGetDataRowSplitWayParamsEh): TDataGridRowSplitWayEh;
begin
  Result := TDataGridRowSplitWayEh.SplitByCell;
end;

function TCustomDataGridEh.CreateGetDataRowManagerParams(): TBaseDataGridGetDataRowManagerParamsEh;
begin
  Result := TBaseDataGridGetDataRowManagerParamsEh.Create;
end;

function TCustomDataGridEh.GetDataRowManagerForRow(ARow: TDataGridRowEh): TVPBaseCellManagerEh;
var
  GetRowManagerParams: TBaseDataGridGetDataRowManagerParamsEh;
begin
  GetRowManagerParams := CreateGetDataRowManagerParams();
  try
    GetRowManagerParams.Init(Self, ARow, nil);
    ProcessGetDataRowManager(GetRowManagerParams);
    Result := GetRowManagerParams.CellManager;
  finally
    GetRowManagerParams.Free;
  end;
end;

procedure TCustomDataGridEh.ProcessGetDataRowManager(Params: TBaseDataGridGetDataRowManagerParamsEh);
begin
  HandleGetDataRowManager(Params);
  if Params.CellManager = nil then
    ProcessGetDefaultDataRowManager(Params);
end;

procedure TCustomDataGridEh.ProcessGetDefaultDataRowManager(Params: TBaseDataGridGetDataRowManagerParamsEh);
begin
  if FDefaultDataRowCellManager = nil then
    FDefaultDataRowCellManager := TDataGridDataRowBandManagerEh.Create(Self);
  Params.CellManager := FDefaultDataRowCellManager;
end;

function TCustomDataGridEh.GetDataTreeViewAreaParams(ARow: TDataGridDataRowEh): TDataAxisCellTreeViewAreaParamsEh;
var
  RowSplitWay: TDataGridRowSplitWayEh;
begin
  RowSplitWay := GetDataRowSplitWay(ARow);
  if (RowSplitWay = TDataGridRowSplitWayEh.NoSplit) or (VisibleColumns.Count = 0) then
    Result := GetDataTreeViewAreaParams(nil, ARow)
  else if (VisibleColumns.Count > 0) then
    Result := GetDataTreeViewAreaParams(VisibleColumns[0], ARow)
  else
    Result := nil;
end;

function TCustomDataGridEh.CreateDataCellTreeViewAreaParams(): TDataAxisCellTreeViewAreaParamsEh;
begin
  Result := TDataAxisCellTreeViewAreaParamsEh.Create();
end;

function TCustomDataGridEh.GetAxisDataTreeViewAreaParams(AFieldBar: TFieldBarEh; ARecordBar: TTableRowViewEh): TDataAxisCellTreeViewAreaParamsEh;
var
  ARow: TDataGridDataRowEh;
begin
  //TODO ARecordBar is not TDataGridDataRowEh
  if ARecordBar = nil
    then ARow := nil
    else ARow := TDataGridTableRowEh(ARecordBar).GridDataRow;

  Result := GetDataTreeViewAreaParams(TDataGridBaseColumnEh(AFieldBar), ARow);
end;

function TCustomDataGridEh.GetDataTreeViewAreaParams(AColumn: TDataGridBaseColumnEh; ARow: TDataGridDataRowEh): TDataAxisCellTreeViewAreaParamsEh;
var
  RowSplitWay: TDataGridRowSplitWayEh;
  TreeViewAreaParams: TDataAxisCellTreeViewAreaParamsEh;
  TableRow: TDataGridTableRowEh;
begin
  RowSplitWay := GetDataRowSplitWay(ARow);

  if (AColumn = nil) and (ARow = nil) then
    DoNothing
  else if RowSplitWay = TDataGridRowSplitWayEh.NoSplit then
    AColumn := nil
  else if (AColumn = nil) and (VisibleColumns.Count > 0) then
    raise Exception.Create('Can''t TreeViewAreaParams for TDataGridRowSplitWayEh.SplitByCell when AColumn = nil');

  if ARow <> nil
    then TableRow := ARow.TableRow
    else TableRow := nil;

  TreeViewAreaParams := TDataAxisCellTreeViewAreaParamsEh.Create;
  TreeViewAreaParams.Init(Self, AColumn, TableRow, False, 16, 0, TTreeSignStateEh.Expanded, True);
  try
    ProcessGetDataTreeViewAreaParams(TreeViewAreaParams);
    Result := TreeViewAreaParams;
  finally
  end;
end;

procedure TCustomDataGridEh.ProcessGetDataTreeViewAreaParams(Params: TDataAxisCellTreeViewAreaParamsEh);
begin
  HandleGetDataTreeViewAreaParams(Params);
  if Params.Handled = False then
    DefaultProcessGetTreeViewAreaParams(Params);
end;

procedure TCustomDataGridEh.DefaultProcessGetTreeViewAreaParams(Params: TDataAxisCellTreeViewAreaParamsEh);
var
  GridRow: TDataGridDataRowEh;
  RowLevel: Integer;

  function GetLevel(AGridRow: TDataGridDataRowEh): Integer;
  var
    ParentRow: TDataGridRowEh;
  begin
    Result := 0;
    ParentRow := AGridRow.ParentRow;
    while ParentRow <> nil do
    begin
      Result := Result + 1;
      ParentRow := ParentRow.ParentRow;
    end;
  end;

begin
  if DataGrouping.Active then
  begin
    if (Params.ListItemBar <> nil) and
       (Params.ListItemBar is TDataGridTableRowEh) and
       (VisibleColumns.Count > 0) and
       (Params.FieldBar = VisibleColumns[0]) then
    begin
      GridRow := TDataGridTableRowEh(Params.ListItemBar).GridDataRow;
      RowLevel := GetLevel(GridRow);
      Params.TreeAreaVisible := True;
      Params.Level := RowLevel;
      Params.SignVisible := False;
    end;
  end;
end;

procedure TCustomDataGridEh.HandleGetDataTreeViewAreaParams(Params: TDataAxisCellTreeViewAreaParamsEh);
begin
end;

procedure TCustomDataGridEh.ProcessSetDataTreeSignState(Params: TDataAxisCellTreeSignStateParamsEh);
begin
  HandleSetDataTreeSignState(Params);
end;

procedure TCustomDataGridEh.HandleSetDataTreeSignState(Params: TDataAxisCellTreeSignStateParamsEh);
begin
end;

procedure TCustomDataGridEh.SetDataTreeViewSignState(ARow: TDataGridDataRowEh; ATreeSignState: TTreeSignStateEh; AShift: TShiftState);
var
  TreeSignStateSetParams: TDataAxisCellTreeSignStateParamsEh;
begin
  TreeSignStateSetParams := TDataAxisCellTreeSignStateParamsEh.Create;
  TreeSignStateSetParams.Init(Self, CurrentColumn, ARow.TableRow, ATreeSignState, AShift);
  try
    ProcessSetDataTreeSignState(TreeSignStateSetParams);
  finally
    TreeSignStateSetParams.Free;
  end;
end;

procedure TCustomDataGridEh.HandleGetDataRowManager(Params: TBaseDataGridGetDataRowManagerParamsEh);
begin
end;

/// <summary>
/// Convert Base Grid Column Index to DatGrid Data ColumnIndex
/// </summary>
/// <returns>
/// Index of the column which can be used to access columns via the VisibleColumns property.
/// </returns>
function TCustomDataGridEh.RawToDataColumn(AColIndex: Integer): Integer;
begin
  Result := AColIndex - FStartDataColIndex;
end;

function TCustomDataGridEh.DataToRawColumn(ADataCol: Integer): Integer;
begin
  Result := ADataCol + FStartDataColIndex;
end;

function TCustomDataGridEh.RawToDataRowIndex(ARowIndex: Integer): Integer;
begin
  Result := ARowIndex - FStartDataRowIndex;
end;

function TCustomDataGridEh.DataToRawRowIndex(ARowIndex: Integer): Integer;
begin
  Result := ARowIndex + FStartDataRowIndex;
end;

procedure TCustomDataGridEh.Resize;
begin
  inherited Resize;
end;

procedure TCustomDataGridEh.UpdateColumnWidths;
var
  c: Integer;
  IndColWidth: Integer;
begin
  if (not IsCanvasEnabled) then Exit;
  if (not IsLoaded) then Exit;

  if (StartDataColIndex > 0) then
  begin
    IndColWidth := IndicatorColumn.CalcColumnWidth();
    ColWidths[0] := IndColWidth;
  end;

  VisibleColumns.UpdateActualWidths;
  if (Title.IsComplexTitle = True) then
    Title.ComplexTitleTree.CalcTitleSize;

  for c := 0 to VisibleColumns.Count - 1 do
  begin
    ColWidths[c + StartDataColIndex] := VisibleColumns[c].ActualWidth;
  end;
end;

procedure TCustomDataGridEh.UpdateActive;
begin
  UpdateBaseGridRowIndexFromGridView();
end;

procedure TCustomDataGridEh.Scroll(Distance: Integer);
begin
  GridView.UpdateCurrentRowIndexFromDataTable();
end;

procedure TCustomDataGridEh.UpdateBaseGridRowIndexFromGridView();
var
  NewGridRow, NewCol: Integer;
  ShowCol: Boolean;
  NewCurrentRowViewIndex: Integer;
begin
  if GridView = nil then Exit;
//  NewCurrentRowViewIndex := -1;

  if GridView.Active then
  begin
    InvalidateRow(CurRowIndex);
    if GridView.Active and IsCanvasEnabled and not (csLoading in ComponentState) then
    begin
      NewCurrentRowViewIndex := GridView.CurrentRowIndex;
      if NewCurrentRowViewIndex < 0 then NewCurrentRowViewIndex := -1;

      NewGridRow := NewCurrentRowViewIndex + TopDataOffset;
      if (NewGridRow < RowCount) and (NewGridRow >= FixedRowCount) then
      begin
        NewCol := CurColIndex;
        if (CurRowIndex <> NewGridRow) or (CurColIndex <> NewCol) then
        begin
          CheckHideEditor;
          ShowCol := SelectionOptions.RowSelect = False;
          if {(not FLockAutoShowCurCell) and} (CurColIndex < FixedColCount) then
          begin
            MoveColRow(NewCol, NewGridRow, False, True);
          end else
          begin
            MoveColRow(NewCol, NewGridRow, ShowCol, True);
          end;
          InvalidateEditor;
          InvalidateRow(NewGridRow);
        end
        else if {not FFetchingRecords and} {not PaintLocked} True then
        begin
          ClampInView(GridCoord(CurColIndex, CurRowIndex), False, True);
        end;

        if InplaceEditorVisible then
        begin
        end;
      end;
    end;
  end;
end;

procedure TCustomDataGridEh.SafeScrollData(DX, DY: Integer);
begin
  inherited SafeScrollData(DX, DY);
end;

function TCustomDataGridEh.GetDataRowCount: Integer;
begin
  Result := RowCount - TopDataOffset;
end;

procedure TCustomDataGridEh.SetIndicatorColumn(const Value: TDataGridIndicatorColumnEh);
begin
  FIndicatorColumn.Assign(Value);
end;

procedure TCustomDataGridEh.SetIndicatorTitle(
  const Value: TDataGridIndicatorTitleEh);
begin
  FIndicatorTitle.Assign(Value);
end;

function TCustomDataGridEh.VisibleDataRowCount: Integer;
begin
  Result := VisibleRowCount;
end;

function TCustomDataGridEh.GetTitleRows: Integer;
begin
  if Title.Visible
    then Result := 1
    else Result := 0;
end;

function TCustomDataGridEh.GetTopDataOffset: Byte;
begin
  Result := GetTitleRows + GetSubTitleRows;
end;

function TCustomDataGridEh.GetSubTitleRows: Integer;
begin
  Result := 0;
end;

function TCustomDataGridEh.DataBox: TGridRect;
begin
  Result.Left := StartDataColIndex;
  Result.Top := TopDataOffset;
  Result.Right := FullColCount - 1;
  Result.Bottom := RowCount-1;
end;

procedure TCustomDataGridEh.Paint;
begin
  inherited Paint;
end;

procedure TCustomDataGridEh.DoPaint;
{$IFDEF MSWINDOWS}
var
  Column: TDataGridBaseColumnEh;
{$ENDIF}
begin
  inherited DoPaint;
  if (csDesigning in ComponentState) and not Locked and not FInPaintTo then
  begin
{$IFDEF MSWINDOWS}
    if (Owner is TCommonCustomForm) and (TCommonCustomForm(Owner).Designer <> nil) then
    begin
      for Column in VisibleColumns do
      begin
        if TCommonCustomForm(Root.GetObject).Designer.IsSelected(Column) then
          DrawColumnDesignBorder(Column);
      end;
    end;
{$ENDIF}
  end;
end;

procedure TCustomDataGridEh.DrawColumnDesignBorder(AColumn: TDataGridBaseColumnEh);
var
  ACellPos: TGridCoord;
  VCellRect: TRect;
begin
  ACellPos.X := AColumn.VisibleIndex + FStartDataColIndex;
  ACellPos.Y := 0;

  if (ACellPos.X >= 0) and (ACellPos.X < ColCount) then
  begin
    VCellRect := CellRect(ACellPos.X, ACellPos.Y);
    VCellRect.Top := VertAxis.GridClientStart;
    VCellRect.Bottom := VertAxis.GridClientStop;

    InflateRect(VCellRect, -2, -2);
    Canvas.Stroke.Kind := TBrushKind.Solid;
    Canvas.Stroke.Dash := TStrokeDash.Dash;
    Canvas.Stroke.Color := DesignBorderColor;
    Canvas.Stroke.Thickness := 1;
    Canvas.DrawRect(VCellRect, 0, 0, AllCorners, AbsoluteOpacity)
  end;
end;

//procedure TCustomDataGridEh.DrawBordersForCellArea(AColIndex, ARowIndex: Integer; var ARect: TRect; State: TGridDrawState;
//  CellBorderTypes: TGridCellBorderTypesEh = [TGridCellBorderTypeEh.Bottom, TGridCellBorderTypeEh.Right]);
//begin
//end;

function TCustomDataGridEh.GetColumns: TDataGridAllColumnsEh;
begin
  Result := TDataGridAllColumnsEh(FieldBars);
end;

function TCustomDataGridEh.GetDisplayColumns: TDataGridDisplayColumnsEh;
begin
  Result := TDataGridDisplayColumnsEh(DisplayFieldBars);
end;

function TCustomDataGridEh.GetVisibleColumns: TDataGridVisibleColumnsEh;
begin
  Result := TDataGridVisibleColumnsEh(VisibleFieldBars);
end;

function TCustomDataGridEh.GetVisibleRows: TDataGridRowsEh;
begin
  Result := FVisibleRows;
end;

function TCustomDataGridEh.GetTableView: TDataGridTableRowsViewEh;
begin
  Result := TDataGridTableRowsViewEh(inherited TableView);
end;

function TCustomDataGridEh.GetGridView: TDataGridRowsViewEh;
begin
  Result := FGridView;
end;

function TCustomDataGridEh.GetCellAreaType(AColIndex, ARowIndex: Integer; var AreaCol,
  AreaRow: Integer): TCellAreaTypeEh;
var
  ADataRect: TGridRect;
begin
  ADataRect := DataBox;
  AreaCol := AColIndex;
  AreaRow := ARowIndex;
  if AColIndex < ADataRect.Left then
    Result.HorzType := THorzCellAreaTypeEh.Indicator
  else
  begin
    Dec(AreaCol, StartDataColIndex);
    Result.HorzType := THorzCellAreaTypeEh.Data;
  end;

  if (ARowIndex < GetTitleRows) then
    Result.VertType := TVertCellAreaTypeEh.Title
  else if (ARowIndex < GetTitleRows + GetSubTitleRows) then
  begin
    Result.VertType := TVertCellAreaTypeEh.SubTitle;
    Dec(AreaRow, GetTitleRows);
  end else if (ARowIndex >= ADataRect.Top) and (ARowIndex <= ADataRect.Bottom) then
  begin
    Result.VertType := TVertCellAreaTypeEh.Data;
    Dec(AreaRow, TopDataOffset);
  end else if (ARowIndex = ADataRect.Bottom + 1) then 
  begin
    Result.VertType := TVertCellAreaTypeEh.Footer; 
    AreaRow := 0;
  end else if (ARowIndex > ADataRect.Bottom + 1) then 
  begin
    Result.VertType := TVertCellAreaTypeEh.Footer;
    Dec(AreaRow, ADataRect.Bottom + 1);
  end else
    raise Exception.Create('Algorithm error in TCustomDataGridEh.GetCellType');
end;

function TCustomDataGridEh.GetCellRowHeights(Index: Longint): Integer;
begin
  if GridLineOptions.HorzLinesVisible = True
    then Result := RowHeights[Index] - GridLineWidth
    else Result := RowHeights[Index];
end;

procedure TCustomDataGridEh.SetCellRowHeights(Index: Longint;
  const Value: Integer);
begin
  if GridLineOptions.HorzLinesVisible = True
    then RowHeights[Index] := Value + GridLineWidth
    else RowHeights[Index] := Value;
end;

function TCustomDataGridEh.GetFooterRowCount: Integer;
begin
  Result := Footer.Rows.Count;
end;

function TCustomDataGridEh.GetFullFooterRowCount: Integer;
begin
  Result := FooterRowCount;
end;

procedure TCustomDataGridEh.GetDataForVertScrollBar(var APosition, AMin, AMax,
  APageSize: Integer);
begin
  inherited GetDataForVertScrollBar(APosition, AMin, AMax, APageSize);
end;

procedure TCustomDataGridEh.GetDataForVertScrollBarForDataSet(var APosition, AMin, AMax, APageSize: Integer);
begin
  if GridView = nil then Exit;

  if GridView.Active then
  begin
    AMin := 1;
    APageSize := VisibleRowCount;
    AMax := Integer(VisibleRows.Count + APageSize);
    APosition := GridView.CurrentRowIndex;
  end else
  begin
    AMin := 0;
    APageSize := 2;
    AMax := 1;
    APosition := 0;
  end;
end;

procedure TCustomDataGridEh.VertScrollBarMessage(ScrollCode, Pos: Integer);
begin
  inherited VertScrollBarMessage(ScrollCode, Pos)
end;

function TCustomDataGridEh.GetHorzScrollBarPanelControl: TDataGridScrollBarPanelControlEh;
begin
  Result := TDataGridScrollBarPanelControlEh(inherited HorzScrollBarPanelControl);
end;

function TCustomDataGridEh.GetVertScrollBarPanelControl: TDataGridScrollBarPanelControlEh;
begin
  Result := TDataGridScrollBarPanelControlEh(inherited VertScrollBarPanelControl);
end;

function TCustomDataGridEh.GetHorzScrollBar: TDataGridHorzScrollBarEh;
begin
  Result := TDataGridHorzScrollBarEh(inherited HorzScrollBar);
end;

function TCustomDataGridEh.GetVertScrollBar: TDataGridVertScrollBarEh;
begin
  Result := TDataGridVertScrollBarEh(inherited VertScrollBar);
end;

procedure TCustomDataGridEh.SetHorzScrollBar(const Value: TDataGridHorzScrollBarEh);
begin
  inherited HorzScrollBar := Value;
end;

procedure TCustomDataGridEh.SetVertScrollBar(const Value: TDataGridVertScrollBarEh);
begin
  inherited VertScrollBar := Value;
end;

function TCustomDataGridEh.CreateScrollBar(
  AKind: TOrientation): TGridScrollBarEh;
begin
  if AKind = TOrientation.Vertical
    then Result := TDataGridVertScrollBarEh.Create(Self, AKind)
    else Result := TDataGridHorzScrollBarEh.Create(Self, AKind);
end;

function TCustomDataGridEh.CreateHorzScrollBarPanelControl: TGridScrollBarPanelControlEh;
begin
  Result := TDataGridScrollBarPanelControlEh.Create(Self, TOrientation.Horizontal);
end;

function TCustomDataGridEh.CreateVertScrollBarPanelControl: TGridScrollBarPanelControlEh;
begin
  Result := TDataGridScrollBarPanelControlEh.Create(Self, TOrientation.Vertical);
end;

procedure TCustomDataGridEh.PriorRow(Select: Boolean; Shift: TShiftState);
begin
  GridView.GotoPriorRow;
end;

procedure TCustomDataGridEh.NextRow(Select: Boolean; Shift: TShiftState);
var
  CurrentTableRow: TDataGridTableRowEh;
begin
  if CanTableOperation(TDataGridAllowedOperationEh.Append) and Self.Eof then
  begin
    if (GridView.CurrentRow is TDataGridDataRowEh)
      then CurrentTableRow := TDataGridDataRowEh(GridView.CurrentRow).TableRow
      else CurrentTableRow := nil;

    if (GridView.CurrentRow = nil) then
    begin
      TableView.AppendNewRow;
    end
    else if (CurrentTableRow.EditState in [TRowLinkEditStateEh.Browse, TRowLinkEditStateEh.Edit]) then
    begin
      TableView.AppendNewRow;
    end else if (CurrentTableRow.EditState = TRowLinkEditStateEh.Insert) and
                (TableView.CurrentRowIsEditModified = True) then
    begin
      TableView.AppendNewRow;
    end;
  end else
  begin
    GridView.GotoNextRow;
  end;
end;

procedure TCustomDataGridEh.DoTabAction(GoForward: Boolean; Shift: TShiftState);
var
  NextCol: TDataGridBaseColumnEh;
begin
  CheckClearSelection;
  BeginUpdate;
  try
    NextCol := VisibleColumns.GetNextTabColumn(VisibleColumns[CurrentColIndex], GoForward);
    if NextCol = VisibleColumns[CurrentColIndex] then
    begin
      if GoForward then
      begin
        NextRow(False, Shift);
        NextCol := VisibleColumns.GetFirstTabColumn;
      end else
      begin
        PriorRow(False, Shift);
      end;
      if NextCol <> nil then
        CurrentColIndex := NextCol.VisibleIndex;
    end
    else if NextCol <> nil then
    begin
      CurrentColIndex := NextCol.VisibleIndex;
    end;
  finally
    EndUpdate;
  end;
  if EditorMode then
    UpdateEdit;
end;

procedure TCustomDataGridEh.ChangeKeySelection(var Key: Word);
var
  DataCellPos: TGridCoord;
  FreeCellPos: TGridCoord;
  Step: Integer;
begin
  DataCellPos.X := CurColIndex - StartDataColIndex;
  DataCellPos.Y := CurRowIndex - StartDataRowIndex;
  case Key of
    vkUP, vkPRIOR:
    begin
      if TDataGridSelectionTypeEh.Rectangle in SelectionOptions.AllowedSelections then
      begin
        if Key = vkUP
          then Step := 1
          else Step := VisibleDataRowCount;
        if Selection.SelectionType <> TDataGridSelectionTypeEh.Rectangle then
        begin
          FreeCellPos.X := CurColIndex - StartDataColIndex;
          FreeCellPos.Y := CurRowIndex - StartDataRowIndex - Step;
          Selection.StartCellsRectSelection(DataCellPos, FreeCellPos);
        end else
        begin
          Selection.SetFreeEndCell(GridCoord(Selection.FreeEndCell.X, Selection.FreeEndCell.Y - Step));
        end;
        Key := 0;
      end;
    end;

    vkDOWN, vkNEXT:
    begin
      if TDataGridSelectionTypeEh.Rectangle in SelectionOptions.AllowedSelections then
      begin
        if Key = vkDOWN
          then Step := 1
          else Step := VisibleDataRowCount;
        if Selection.SelectionType <> TDataGridSelectionTypeEh.Rectangle then
        begin
          FreeCellPos.X := CurColIndex - StartDataColIndex;
          FreeCellPos.Y := CurRowIndex - StartDataRowIndex + Step;
          Selection.StartCellsRectSelection(DataCellPos, FreeCellPos);
        end else
        begin
          Selection.SetFreeEndCell(GridCoord(Selection.FreeEndCell.X, Selection.FreeEndCell.Y + Step));
        end;
        Key := 0;
      end;
    end;


    vkLeft:
    begin
      if TDataGridSelectionTypeEh.Rectangle in SelectionOptions.AllowedSelections then
      begin
        if Selection.SelectionType <> TDataGridSelectionTypeEh.Rectangle then
        begin
          FreeCellPos.X := CurColIndex - StartDataColIndex - 1;
          FreeCellPos.Y := CurRowIndex - StartDataRowIndex;
          Selection.StartCellsRectSelection(DataCellPos, FreeCellPos);
        end else
        begin
          Selection.SetFreeEndCell(GridCoord(Selection.FreeEndCell.X - 1, Selection.FreeEndCell.Y));
        end;
        Key := 0;
      end;
    end;

    vkRight:
    begin
      if TDataGridSelectionTypeEh.Rectangle in SelectionOptions.AllowedSelections then
      begin
        if Selection.SelectionType <> TDataGridSelectionTypeEh.Rectangle then
        begin
          FreeCellPos.X := CurColIndex - StartDataColIndex + 1;
          FreeCellPos.Y := CurRowIndex - StartDataRowIndex;
          Selection.StartCellsRectSelection(DataCellPos, FreeCellPos);
        end else
        begin
          Selection.SetFreeEndCell(GridCoord(Selection.FreeEndCell.X + 1, Selection.FreeEndCell.Y));
        end;
        Key := 0;
      end;
    end;

    vkHOME:
    begin
      if TDataGridSelectionTypeEh.Rectangle in SelectionOptions.AllowedSelections then
      begin
        if Selection.SelectionType <> TDataGridSelectionTypeEh.Rectangle then
        begin
          FreeCellPos.X := 0;
          FreeCellPos.Y := CurRowIndex - StartDataRowIndex;
          Selection.StartCellsRectSelection(DataCellPos, FreeCellPos);
        end else
        begin
          Selection.SetFreeEndCell(GridCoord(0, Selection.FreeEndCell.Y));
        end;
        Key := 0;
      end;
    end;

    vkEND:
    begin
      if TDataGridSelectionTypeEh.Rectangle in SelectionOptions.AllowedSelections then
      begin
        if Selection.SelectionType <> TDataGridSelectionTypeEh.Rectangle then
        begin
          FreeCellPos.X := VisibleColumns.Count - 1;
          FreeCellPos.Y := CurRowIndex - StartDataRowIndex;
          Selection.StartCellsRectSelection(DataCellPos, FreeCellPos);
        end else
        begin
          Selection.SetFreeEndCell(GridCoord(VisibleColumns.Count - 1, Selection.FreeEndCell.Y));
        end;
        Key := 0;
      end;
    end;

  end; 
end;


procedure TCustomDataGridEh.KeyDown(var Key: Word; var KeyChar: WideChar;
  Shift: TShiftState);
var
  KeyDownEvent: TKeyEvent;
  OldCurrentColIndex: Integer;
  TreeViewAreaParams: TDataAxisCellTreeViewAreaParamsEh;

  function CheckIsFilterKey: Boolean;
  begin
    Result := False;
  end;

const
  RowMovementKeys = [vkUp, vkPrior, vkDown, vkNext, vkHome, vkEnd];

begin
  KeyDownEvent := OnKeyDown;
  CheckIsFilterKey;

  if not GridView.Active or not CanGridAcceptKey(Key, Shift) then
    Exit;

  if ssCtrl in Shift then
  begin
    if (Key in RowMovementKeys) and not (ssShift in Shift) then CheckClearSelection;
    case Key of

      vkUp, vkPrior:
      begin
        GridView.GotoPriorRow;
        Key := 0;
      end;

      vkNext:
      begin
        GridView.GotoNextRow;
        Key := 0;
      end;

      vkDown:
      begin
        begin
          GridView.GotoNextRow;
        end;
        Key := 0;
      end;

      vkLeft:
      begin
        MoveCol(0, 1, False, True);
        Key := 0;
      end;

      vkRight:
      begin
        MoveCol(Columns.Count - 1, -1, False, True);
        Key := 0;
      end;

      vkHome:
      begin
        DataFirst;
        Key := 0;
      end;

      vkEnd:
      begin
        DataLast;
        Key := 0;
      end;

      vkDelete:
      begin
        if (not Self.ReadOnly) and
                (not ReadOnly) and
                 (GridView.Rows.Count > 0) and
                 CanTableOperation(TDataGridAllowedOperationEh.Delete)
        then
        begin
          if IsConfirmDelete then
            ConfirmAndDeleteRows()
          else
            DeleteCurrentRowOrRows();
        end;
        Key := 0;
      end;

      vkInsert, Word('C'): //Ctrl+X
      begin
        if EditActions.CanCopy() then
          EditActions.Copy;
        Key := 0;
      end;

      Word('X'): //Ctrl+X
      begin
        if EditActions.CanCut() then
          EditActions.Cut();
        Key := 0;
      end;

      Word('V'): //Ctrl+V
      begin
        if EditActions.CanPaste() then
          EditActions.Paste();
        Key := 0;
      end;

      Word('A'): //Ctrl+A
      begin
        if EditActions.CanSelectAll() then
          EditActions.SelectAll();
        Key := 0;
      end;

      Word('D'): //Ctrl+D
      begin
        if EditActions.CanFillFromFirstRow() then
          EditActions.FillFromFirstRow();
        Key := 0;
      end;
    end
  end
  else 
  begin
    case Key of
      vkUp:
      begin
        if ssShift in Shift then
        begin
          ChangeKeySelection(Key);
        end else
        begin
          PriorRow(True, Shift);
          Key := 0;
        end;
      end;
      vkDown:
      begin
        if ssShift in Shift then
        begin
          ChangeKeySelection(Key);
        end else
        begin
          NextRow(True, Shift);
          Key := 0;
        end;
      end;

      vkLeft:
      begin
        OldCurrentColIndex := CurrentColIndex;
        if (CurrentDataRow <> nil) and
           ((GetDataRowSplitWay(CurrentDataRow) = TDataGridRowSplitWayEh.NoSplit) or (VisibleColumns.Count = 1)) then
        begin
          TreeViewAreaParams := GetDataTreeViewAreaParams(CurrentDataRow);
          if (TreeViewAreaParams.TreeAreaVisible = True) and
             (TreeViewAreaParams.SignVisible = True) and
             (TreeViewAreaParams.SignState = TTreeSignStateEh.Expanded) then
          begin
            SetDataTreeViewSignState(CurrentDataRow, TTreeSignStateEh.Collapsed, []);
            Key := 0;
          end else
          begin
            HorzScrollBarMessage(SB_LINEUP_EH, 0);
            Key := 0;
          end;
          TreeViewAreaParams.Free;
        end
        else if ssShift in Shift then
        begin
          ChangeKeySelection(Key);
        end
        else if SelectionOptions.RowSelect then
        begin
          inherited KeyDown(Key, KeyChar, Shift);
        end
        else if (ssShift in Shift) and (TDataGridSelectionTypeEh.Rectangle in SelectionOptions.AllowedSelections) then
        begin
          MoveCol(CurrentColIndex - 1, -1, True, True);
        end else
        begin
          CheckClearSelection;
          MoveCol(CurrentColIndex - 1, -1, False, True);
        end;
        if OldCurrentColIndex <> CurrentColIndex then
          Key := 0;
      end;

      vkRight:
      begin
        OldCurrentColIndex := CurrentColIndex;
        if (CurrentDataRow <> nil) and
           ((GetDataRowSplitWay(CurrentDataRow) = TDataGridRowSplitWayEh.NoSplit) or (VisibleColumns.Count = 1)) then
        begin
          TreeViewAreaParams := GetDataTreeViewAreaParams(CurrentDataRow);
          if (TreeViewAreaParams.TreeAreaVisible = True) and
             (TreeViewAreaParams.SignVisible = True) and
             (TreeViewAreaParams.SignState = TTreeSignStateEh.Collapsed) then
          begin
            SetDataTreeViewSignState(CurrentDataRow, TTreeSignStateEh.Expanded, []);
            Key := 0;
          end else
          begin
            HorzScrollBarMessage(SB_LINEDOWN_EH, 0);
            Key := 0;
          end;
          TreeViewAreaParams.Free;
        end
        else if ssShift in Shift then
        begin
          ChangeKeySelection(Key);
        end
        else if SelectionOptions.RowSelect then
        begin
          inherited KeyDown(Key, KeyChar, Shift);
        end
        else if (ssShift in Shift) and (TDataGridSelectionTypeEh.Rectangle in SelectionOptions.AllowedSelections) then
        begin
          MoveCol(CurrentColIndex + 1, 1, True, True);
//        end
//        else if GetDataRowSplitWay(CurrentRow) = TDataGridRowSplitWayEh.NoSplit then
//        begin
//          HorzScrollBarMessage(SB_LINEUP_EH, 0);
        end else
        begin
          CheckClearSelection;
          MoveCol(CurrentColIndex + 1, 1, False, True);
        end;
        if OldCurrentColIndex <> CurrentColIndex then
        begin
          //
          Key := 0;
        end;
      end;

      vkHome:
      begin
        if ssShift in Shift then
        begin
          ChangeKeySelection(Key);
        end
        else if SelectionOptions.RowSelect then
          GridView.GotoFirstRow
        else if ColCount = StartDataColIndex + 1 then
        begin
          begin
            CheckClearSelection;
            GridView.GotoFirstRow;
          end;
        end else if (ssShift in Shift) and (TDataGridSelectionTypeEh.Rectangle in SelectionOptions.AllowedSelections) then
        begin
          MoveCol(0, 1, True, True);
        end else
        begin
          MoveCol(0, 1, False, True);
        end;
        Key := 0;
      end;

      vkEnd:
      begin
        if ssShift in Shift then
        begin
          ChangeKeySelection(Key);
        end
        else if SelectionOptions.RowSelect then
          GridView.GotoLastRow
        else if (ColCount = StartDataColIndex + 1) then
        begin
          begin
            CheckClearSelection;
            GridView.GotoLastRow;
          end;
        end else if (ssShift in Shift) and (TDataGridSelectionTypeEh.Rectangle in SelectionOptions.AllowedSelections) then
        begin
          MoveCol(Columns.Count - 1, -1, True, True);
        end else
        begin
          MoveCol(Columns.Count - 1, -1, False, True);
        end;
        Key := 0;
      end;

      vkNext:
      begin
        if ssShift in Shift then
        begin
          ChangeKeySelection(Key);
        end
        else
        begin
          CheckClearSelection;
          Self.MoveBy(VisibleDataRowCount);
        end;
        Key := 0;
      end;

      vkPrior:
      begin
        if ssShift in Shift then
        begin
          ChangeKeySelection(Key);
        end
        else
        begin
          CheckClearSelection;
          Self.MoveBy(-VisibleDataRowCount);
        end;
        Key := 0;
      end;

      vkInsert:
      begin
        if (ssShift in Shift) then
        begin
          if CheckPasteAction and (EditActions.CopyEnabled = True) then
            DataGridEh_DoPasteAction(Self, False)
        end
        else if (GridView.CanModify = True) and
                (ReadOnly = False) then
        begin
          CheckClearSelection;
          if CanTableOperation(TDataGridAllowedOperationEh.Insert) then
            DataInsert
          else if CanTableOperation(TDataGridAllowedOperationEh.Append) then
            DataAppend;
        end;
        Key := 0;
      end;

      vkTab:
      begin
        if not (ssAlt in Shift) then
        begin
          DoTabAction(not (ssShift in Shift), Shift);
          Key := 0;
        end;
      end;

      vkReturn:
      begin
        if EditActions.EnterAsTab then
        begin
          DoTabAction(not (ssShift in Shift), Shift);
          Key := 0;
        end;
      end;

      vkEscape:
      begin
        TableView.CancelCurrentRow();
        CheckHideEditor();
        Key := 0;
      end;

      vkF2:
      begin
        EditorMode := True;
        Key := 0;
      end;

      vkDelete:
      begin
        if (ssShift in Shift) and EditActions.CanCut() then
          EditActions.Cut();
        Key := 0;
      end;

      vkAdd, vkSubtract, vkMultiply:
      begin
        Key := 0;
      end;
    end; 
  end; 

  inherited KeyDown(Key, KeyChar, Shift);
end;

procedure TCustomDataGridEh.KeyUp(var Key: Word; var KeyChar: WideChar;
  Shift: TShiftState);
begin
  inherited KeyUp(Key, KeyChar, Shift);

  case Key of
    vkControl:
    begin
      if (Title.SortMarking.MultiSortMarkable = True) and
         (Title.SortMarking.SortMarkersChanged = True) then
      begin
        Title.SortMarking.ApplySortMarkers();
      end;
    end;
 end;
end;

function TCustomDataGridEh.GetAutoFitColWidths: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to VisibleColumns.Count - 1 do
  begin
    if VisibleColumns[I].ColSizeUnit = TGridColSizeUnitEh.Weight then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TCustomDataGridEh.GetAutoGenerateColumns: Boolean;
begin
  Result := AutoGeneratePropBars;
end;

procedure TCustomDataGridEh.SetAutoGenerateColumns(const Value: Boolean);
begin
  AutoGeneratePropBars := Value;
end;

procedure TCustomDataGridEh.UpdateBaseOptions();
var
  NewBaseOptions: TGridOptionsEh;
begin
  NewBaseOptions := [TGridOptionEh.ThumbTracking];
  if EditActions.UseTabs then
    Include(NewBaseOptions, TGridOptionEh.Tabs);
  if ColumnOptions.AllowResize = True then
    Include(NewBaseOptions, TGridOptionEh.ColSizing);
  if SelectionOptions.RowSelect then
  begin
    Include(NewBaseOptions, TGridOptionEh.RowSelect);
  end;
    Include(NewBaseOptions, TGridOptionEh.Editing);

  inherited Options := NewBaseOptions;

  if EditorMode then InvalidateEditor;
end;

function TCustomDataGridEh.CanSelectType(const Value: TDataGridSelectionTypeEh): Boolean;
begin
  Result := (Value = TDataGridSelectionTypeEh.Non) or
    ((Value in SelectionOptions.AllowedSelections)
    and
    (((Value in [TDataGridSelectionTypeEh.Rectangle, TDataGridSelectionTypeEh.Columns]) and not (SelectionOptions.RowSelect))
    or
    (Value in [TDataGridSelectionTypeEh.RecordBookmarks, TDataGridSelectionTypeEh.All])
    ));
end;

function TCustomDataGridEh.CanSelectRow(ARow: TDataGridRowEh): Boolean;
var
  VParams: TCustomDataGridCanSelectRowParamsEh;
begin
  VParams := CreateDataGridCanSelectRowParams(Self, ARow);
  ProcessCanUserSelectCurrentRow(VParams);
  Result := VParams.CanSelectRow;
  VParams.Free;
end;

function TCustomDataGridEh.CreateDataGridCanSelectRowParams(AGrid: TControl; ARow: TDataGridRowEh): TCustomDataGridCanSelectRowParamsEh;
begin
  Result := TCustomDataGridCanSelectRowParamsEh.Create(Self, ARow);
end;

procedure TCustomDataGridEh.ProcessCanUserSelectCurrentRow(Params: TCustomDataGridCanSelectRowParamsEh);
begin
  HandleCanUserSelectCurrentRow(Params);
  if not Params.Handled then
    DefaultCanSelectCurrentRow(Params);
end;

procedure TCustomDataGridEh.HandleCanUserSelectCurrentRow(Params: TCustomDataGridCanSelectRowParamsEh);
begin
end;

procedure TCustomDataGridEh.DefaultCanSelectCurrentRow(Params: TCustomDataGridCanSelectRowParamsEh);
begin
  Params.CanSelectRow := True;
end;

procedure TCustomDataGridEh.CheckClearSelection;
begin
  if (SelectionOptions.KeepSelection = False) then
    ClearSelection;
end;

function TCustomDataGridEh.GetEof: Boolean;
begin
  Result := GridView.AtEndOfRowsList;
end;

function TCustomDataGridEh.GetBof: Boolean;
begin
  Result := GridView.AtStartOfRowsList;
end;

procedure TCustomDataGridEh.MoveCol(DataCol, Direction: Integer; Select: Boolean; ShowInView: Boolean);
var
  OldCol: Integer;
begin
  if Select and not (SelectionOptions.RowSelect) and CanSelectType(TDataGridSelectionTypeEh.Rectangle) then
  begin
    if Selection.SelectionType <> TDataGridSelectionTypeEh.Rectangle then
    begin
    end;
  end;

  if DataCol >= VisibleColumns.Count - ContraColCount then
    DataCol := VisibleColumns.Count - 1 - ContraColCount;
  if DataCol < 0 then
    DataCol := 0;

  if Direction <> 0 then
  begin
    while (DataCol < VisibleColumns.Count - ContraColCount) and
          (DataCol >= 0) and
          (not VisibleColumns[DataCol].Visible) do
    begin
      Inc(DataCol, Direction);
    end;

    if (DataCol >= VisibleColumns.Count - ContraColCount) or (DataCol < 0) then
      Exit;
  end;
  OldCol := CurrentColIndex;

  if DataCol <> OldCol then
  begin

    if not FInColExit then
    begin
      FInColExit := True;
      try
        ColExit;
      finally
        FInColExit := False;
      end;
      if CurrentColIndex <> OldCol then Exit;
    end;

    begin
      if (SelectionOptions.RowSelect = False) then
      begin
        MoveColRow(DataToRawColumn(DataCol), CurRowIndex, ShowInView, False);
      end;
    end;

    ColEnter;
  end;
end;

procedure TCustomDataGridEh.DataFirst;
begin
  GridView.GotoFirstRow;
end;

procedure TCustomDataGridEh.DataLast;
begin
  GridView.GotoLastRow;
end;

procedure TCustomDataGridEh.DataInsert;
begin
  FDataAdding := True;
  try
    TableView.InsertNewRow;
  finally
    FDataAdding := False;
  end;
end;

procedure TCustomDataGridEh.DataAppend;
begin
  FDataAdding := True;
  try
    TableView.AppendNewRow();
  finally
    FDataAdding := False;
  end;
end;

function TCustomDataGridEh.CheckCopyAction: Boolean;
begin
  Result := GridView.Active {and (Selection.SelectionType <> gstNon)};
end;

function TCustomDataGridEh.CheckPasteAction: Boolean;
begin
  Result := GridView.Active and not ReadOnly and
    GridView.CanModify;
  if Result then
  begin
    if (GridView.CurrentRow <> nil) and
       (GridView.CurrentRow is TDataGridDataRowEh) and
       (TDataGridDataRowEh(GridView.CurrentRow).TableRow.EditState <> TRowLinkEditStateEh.Insert) and
       (CanTableOperation(TDataGridAllowedOperationEh.Update) = False)
    then
      Result := False;
  end;
end;

procedure TCustomDataGridEh.CheckPropertiesConsistent;
begin
  inherited CheckPropertiesConsistent;
  TDataGridDataGroupingEhCrack(DataGrouping).InternalUpdateActiveGroupDescirtion();
  if (Title.IsComplexTitle = True) and (AutoGenerateColumns = True) then
  begin
    raise Exception.Create('ComplexTitle mode cannot operate simultaneously with AutoGenerateColumns = True');
  end;
end;

function TCustomDataGridEh.CheckCutAction: Boolean;
begin
  Result := CheckCopyAction and CheckDeleteAction;
end;

function TCustomDataGridEh.CheckSelectAllAction: Boolean;
begin
  Result := GridView.Active and
            (GridView.Rows.Count > 0) and
            (TDataGridSelectionTypeEh.All in SelectionOptions.AllowedSelections);
end;

function TCustomDataGridEh.CheckDeleteAction: Boolean;
begin
  Result := GridView.Active and
            not ReadOnly and
            (GridView.Rows.Count > 0) and
            GridView.CanModify and
            (
              ((Selection.SelectionType in [TDataGridSelectionTypeEh.RecordBookmarks, TDataGridSelectionTypeEh.All]) and
               CanTableOperation(TDataGridAllowedOperationEh.Delete))
            or
              ((Selection.SelectionType in [TDataGridSelectionTypeEh.Rectangle, TDataGridSelectionTypeEh.Columns]) and
               CanTableOperation(TDataGridAllowedOperationEh.Update))
            );
end;

procedure TCustomDataGridEh.CheckDrawCellBorder(AColIndex, ARowIndex: Integer;
  BorderType: TGridCellBorderTypeEh; var IsDraw: Boolean;
  var BorderColor: TAlphaColor; var IsExtent: Boolean);
var
  CellAreaType: TCellAreaTypeEh;
  AreaCol, AreaRow: Integer;
  VisibleVertBorderType: TGridCellBorderTypeEh;

  procedure CheckDrawTitleCellBorder;
  begin
    if BorderType in [TGridCellBorderTypeEh.Bottom] then
    begin
      BorderColor := Title.HorzLinesColor;
      IsDraw := Title.HorzLinesVisible;
    end
    else if BorderType in [VisibleVertBorderType] then
    begin
      BorderColor := Title.VertLinesColor;
      IsDraw := Title.VertLinesVisible;
    end else
    begin
      BorderColor := TAlphaColorRec.Null;
      IsDraw := False;
    end;
  end;

begin
  CellAreaType := GetCellAreaType(AColIndex, ARowIndex, AreaCol, AreaRow);

  if AColIndex < ColCount
    then VisibleVertBorderType := TGridCellBorderTypeEh.Right
    else VisibleVertBorderType := TGridCellBorderTypeEh.Left;

  if (CellAreaType.VertType = TVertCellAreaTypeEh.Title) and
     (CellAreaType.HorzType = THorzCellAreaTypeEh.Data)
  then
  begin
    CheckDrawTitleCellBorder();
  end else
  begin
    if (CellAreaType.VertType = TVertCellAreaTypeEh.Data) and
       (CellAreaType.HorzType = THorzCellAreaTypeEh.Data) then
    begin
      if BorderType in [TGridCellBorderTypeEh.Bottom] then
      begin
        BorderColor := ColumnOptions.HorzLinesColor;
        IsDraw := ColumnOptions.HorzLinesVisible;
      end
      else if BorderType in [VisibleVertBorderType] then
      begin
        if AColIndex = FixedColCount - 1 then
        begin
          BorderColor := GridLineParams.DarkColor;
          IsDraw := True;
        end else
        begin
          BorderColor := ColumnOptions.VertLinesColor;
          IsDraw := ColumnOptions.VertLinesVisible;
        end;
      end else
      begin
        inherited CheckDrawCellBorder(AColIndex, ARowIndex, BorderType, IsDraw, BorderColor, IsExtent);
      end;
    end
    else if (CellAreaType.VertType = TVertCellAreaTypeEh.Data) and
            (CellAreaType.HorzType = THorzCellAreaTypeEh.Indicator) then
    begin
      if BorderType in [TGridCellBorderTypeEh.Bottom] then
      begin
        BorderColor := IndicatorColumn.HorzLinesColor;
        IsDraw := IndicatorColumn.HorzLinesVisible;
      end
      else if BorderType in [TGridCellBorderTypeEh.Right] then
      begin
        BorderColor := IndicatorColumn.VertLinesColor;
        IsDraw := IndicatorColumn.VertLinesVisible;
      end else
      begin
        inherited CheckDrawCellBorder(AColIndex, ARowIndex, BorderType, IsDraw, BorderColor, IsExtent);
      end;
    end else
    begin
      inherited CheckDrawCellBorder(AColIndex, ARowIndex, BorderType, IsDraw, BorderColor, IsExtent);
    end;
  end;
end;

function TCustomDataGridEh.IsConfirmDelete: Boolean;
begin
  Result := EditActions.ConfirmDelete;
end;

procedure TCustomDataGridEh.ConfirmAndDeleteRows;
var
  DelRecQuestion: String;
begin
  if Selection.SelectionType in [TDataGridSelectionTypeEh.RecordBookmarks,
                                 TDataGridSelectionTypeEh.All]
  then
    DelRecQuestion := SDeleteMultipleRecordsQuestion
  else
    DelRecQuestion := SDeleteRecordQuestion;

  TDialogService.MessageDialog(DelRecQuestion,
                               TMsgDlgType.mtConfirmation,
                               [TMsgDlgBtn.mbOK, TMsgDlgBtn.mbCancel],
                               TMsgDlgBtn.mbOK,
                               -1,
    procedure(const AResult: TModalResult)
    begin
      if AResult = mrOk then
        DeleteCurrentRowOrRows;
    end
  );
end;

procedure TCustomDataGridEh.DeleteCurrentRowOrRows;
var
  i: Integer;
  ASelectedRows: TList<TDataGridRowEh>;
begin
  if Selection.SelectionType in [TDataGridSelectionTypeEh.RecordBookmarks,
                                 TDataGridSelectionTypeEh.All] then
  begin
    ASelectedRows := TList<TDataGridRowEh>.Create;
    try
      Selection.GetSelectedRows(ASelectedRows);

      for i := ASelectedRows.Count - 1 downto 0 do
      begin
        CurrentRow := ASelectedRows[I];
        TableView.DeleteCurrentRow;
      end;
    finally
      ASelectedRows.Free;
    end;
    Selection.Clear;
  end
  else if TableView.CurrentRowView <> nil then
  begin
      TableView.DeleteCurrentRow;
  end;
end;

procedure TCustomDataGridEh.ClearSelection;
begin
  if Selection.SelectionType <> TDataGridSelectionTypeEh.Non then
  begin
    Selection.Clear;
    Invalidate;
    InvalidateEditor;
  end;
end;

procedure TCustomDataGridEh.StartColumnSelection(Column: TDataGridBaseColumnEh; Shift: TShiftState);
var
  noScrollRect: TRect;
begin
  FDataGridMouseState := TDataGridMouseStateEh.ColSelecting;

  if ssShift in Shift then
    Selection.Columns.SelectShift(Column {,False})
  else if ssCtrl in Shift then
    Selection.Columns.InvertSelect(Column)
  else
  begin
    Invalidate;
    Selection.Columns.Select(Column, False);
  end;

  noScrollRect.Left := HorzAxis.FixedBoundary;
  noScrollRect.Width := HorzAxis.RollClientLen;
  noScrollRect.Top := VertAxis.GridClientStart;
  noScrollRect.Height := VertAxis.GridClientStop - VertAxis.GridClientStart;

  FMoveAndScrollService.Capture(noScrollRect, ColSelectServiceEventHandler, true, false);
end;

procedure TCustomDataGridEh.ColEnter;
begin
end;

procedure TCustomDataGridEh.ColExit;
begin
end;

procedure TCustomDataGridEh.ColSelectServiceEventHandler(Sender: TObject; MouseParams: TControlMouseParamsEh);
var
  CellHit: TGridCoord;
  Column: TDataGridBaseColumnEh;
begin
  if (MouseParams.X > FMoveAndScrollService.ClientRect.Right) then
  begin
    SafeScrollData(HorzAxis.GetScrollStep(), 0);
    Column := VisibleColumns[RawToDataColumn(LastFullVisibleCol)];

    if  (HorzAxis.RollLastFullVisCel < ColCount-1) and
        (HorzAxis.RollLastFullVisCel <> LeftCol) then
    begin
      if LastFullVisibleCol < ColCount
        then Selection.Columns.SelectShift(Column {,True})
        else Selection.Columns.SelectShift(Column {,True});
    end
    else
      Selection.Columns.SelectShift(Column {,True});
  end
  else if (MouseParams.X < FMoveAndScrollService.ClientRect.Left) then
  begin
    SafeScrollData(-HorzAxis.GetScrollStep(), 0);

    if LeftCol > FixedColCount then
    begin
      SafeSetLeftCol(LeftCol - 1);
      if LeftCol > FixedColCount
        then Column := VisibleColumns[RawToDataColumn(LeftCol - 1)]
        else Column := VisibleColumns[RawToDataColumn(LeftCol)];
    end
    else
      Column := VisibleColumns[RawToDataColumn(LeftCol)];

    Selection.Columns.SelectShift(Column);
  end
  else
  begin
    CellHit := MouseCoord(MouseParams.X, MouseParams.Y);
    if (CellHit.X >= 0) then
    begin
      Column := VisibleColumns[RawToDataColumn(CellHit.X)];
      Selection.Columns.SelectShift(Column);
    end
  end;
end;

procedure TCustomDataGridEh.StartRowSelection(ARowIndex: Integer; Shift: TShiftState);
var
  noScrollRect: TRect;
  ARow: TDataGridRowEh;
  ADataRowIndex: Integer;
  ACanSelectRow: Boolean;
  ShiftMode: Boolean;
  ClearSelection: Boolean;
  StartSelectionState: Boolean;
begin
  if not IsMouseCaptured then Exit;

  ADataRowIndex := ARowIndex - StartDataRowIndex;
  ARow := VisibleRows[ADataRowIndex];

  FDataGridMouseState := TDataGridMouseStateEh.RowSelecting;

  noScrollRect.Left := HorzAxis.GridClientStart;
  noScrollRect.Width := HorzAxis.GridClientStop - HorzAxis.GridClientStart;
  noScrollRect.Top := VertAxis.FixedBoundary;
  noScrollRect.Height := VertAxis.RollClientLen;

  ShiftMode := ssShift in Shift;
  if (ssCtrl in Shift) or (SelectionOptions.KeepSelection = True) then
    ClearSelection := False
  else
    ClearSelection := True;

  if ClearSelection then
    StartSelectionState := True
  else
    StartSelectionState := not ARow.IsSelected;

  if (StartSelectionState = True) then
    ACanSelectRow := CanSelectRow(ARow)
  else
    ACanSelectRow := true;

  if (ACanSelectRow) then
  begin
    FMoveAndScrollService.Capture(noScrollRect, RowSelectServiceEventHandler, False, True);

    if (ShiftMode) then
    begin
      Selection.SetFreeEndRow(ADataRowIndex);
    end else
    begin
      if (ClearSelection = True) then
        Selection.Clear;
      Selection.SetSelectedRow(ARow, StartSelectionState);
      Selection.InitAnchorRow(ADataRowIndex, StartSelectionState);
    end;
  end;
end;

procedure TCustomDataGridEh.RowSelectServiceEventHandler(Sender: TObject; MouseParams: TControlMouseParamsEh);
var
 FreeEndDataRowIndex: Integer;
 CellHit: TGridCoord;
begin
  FreeEndDataRowIndex := Selection.FreeEndDataRowIndex;
  if (MouseParams.Y > FMoveAndScrollService.ClientRect.Bottom) then
  begin
    SafeScrollData(0, HorzAxis.GetScrollStep());
    FreeEndDataRowIndex := VertAxis.RollLastVisCel + VertAxis.FixedCelCount;
    FreeEndDataRowIndex := FreeEndDataRowIndex - StartDataRowIndex;
  end
  else if (MouseParams.Y < FMoveAndScrollService.ClientRect.Top) then
  begin
    SafeScrollData(0, -HorzAxis.GetScrollStep());
    FreeEndDataRowIndex := VertAxis.RollStartVisCel + VertAxis.FixedCelCount;
    FreeEndDataRowIndex := FreeEndDataRowIndex - StartDataRowIndex;
  end
  else
  begin
    CellHit := MouseCoord(MouseParams.X, MouseParams.Y);
    if (cellHit.Y >= 0) then
    begin
      FreeEndDataRowIndex := CellHit.Y - StartDataRowIndex;
    end
  end;

  if (FreeEndDataRowIndex >= VisibleRows.Count) then
    FreeEndDataRowIndex := VisibleRows.Count - 1;
  Selection.SetFreeEndRow(FreeEndDataRowIndex);

end;

procedure TCustomDataGridEh.StartDataCellsSelection(AColIndex, ARowIndex: Integer);
var
  NoScrollRect: TRect;
  DataCellHit: TGridCoord;
begin
  if not IsMouseCaptured then Exit;

  FDataGridMouseState := TDataGridMouseStateEh.RectSelecting;
  DataCellHit.X := AColIndex - StartDataColIndex;
  DataCellHit.Y := ARowIndex - StartDataRowIndex;

  if (DataCellHit.X >= 0) and (DataCellHit.Y >= 0) then
    Selection.StartCellsRectSelection(GridCoord(CurColIndex - StartDataColIndex, CurRowIndex - StartDataRowIndex), DataCellHit);

  NoScrollRect.Left := HorzAxis.FixedBoundary;
  NoScrollRect.Width := HorzAxis.RollClientLen;
  NoScrollRect.Top := VertAxis.FixedBoundary;
  NoScrollRect.Height := VertAxis.RollClientLen;

  FMoveAndScrollService.Capture(NoScrollRect, DataCellsSelectionServiceEventHandler, True, True);
end;

procedure TCustomDataGridEh.ComposeDataCellMenu(ACellParams: TDataAxisCellComposeContextMenuParamsEh);
begin
  DataGridCenterEh.BuildDataCellContextMenu(ACellParams);
end;

function TCustomDataGridEh.GetBuildIndicatorTitleCellPopupMenu(AColumnTitle: TColumnTitleEh): TPopupMenu;
begin
  Result := DataGridCenterEh.GetBuildIndicatorTitleCellPopupMenu(Self, AColumnTitle);
end;

procedure TCustomDataGridEh.BuildTitleCellPopupMenu(Params: TDataGridTitleCellContextMenuParamsEh);
begin
end;

procedure TCustomDataGridEh.ComposeTitleCellMenu(Params: TDataGridTitleCellComposeContextMenuParamsEh);
begin
  if Params.Column <> nil then
    DataGridCenterEh.BuildTitleCellPopupMenu(Params);
end;

procedure TCustomDataGridEh.DataCellsSelectionServiceEventHandler(Sender: TObject; MouseParams: TControlMouseParamsEh);
var
  CellHit: TGridCoord;
  newFreeEndCell: TGridCoord;
  newColIndex: Integer;
  newRowIndex: Integer;
  MSrv: TDataGridMoveAndScrollServiceEh;
begin
  newFreeEndCell := Selection.FreeEndCell;
  MSrv := FMoveAndScrollService;

  CellHit := MouseCoord(MouseParams.X, MouseParams.Y);
  if (MSrv.ClientRect.Contains(TPointF.Create(MouseParams.X, MouseParams.Y).Round)) then
  begin
    if ((cellHit.Y >= 0) and (cellHit.X >= 0)) then
    begin
      newFreeEndCell := GridCoord(cellHit.X - StartDataColIndex, cellHit.Y - StartDataRowIndex);
    end
  end;

  if (MouseParams.X > MSrv.ClientRect.Right) then
  begin
    SafeScrollData(HorzAxis.GetScrollStep(), 0);

    newColIndex := -1;

    if (HorzAxis.RollLastFullVisCel = ColCount - FixedColCount - 1) then
    begin
      if (cellHit.X >= 0) then
        newColIndex := cellHit.X
      else
        newColIndex := -1;
    end;

    if (newColIndex = -1) then
    begin
      if (HorzAxis.RollLastFullVisCel = ColCount - FixedColCount - 1) then
        newColIndex := HorzAxis.FullCelCount - 1
      else
        newColIndex := HorzAxis.RollLastVisCel + HorzAxis.FixedCelCount;
    end;

    newFreeEndCell.X := newColIndex - StartDataColIndex;
  end
  else if (MouseParams.X < MSrv.ClientRect.Left) then
  begin
    SafeScrollData(-HorzAxis.GetScrollStep(), 0);

    newColIndex := -1;

    if (HorzAxis.RollStartVisPos = 0) then
    begin
      if (cellHit.X >= 0) then
        newColIndex := cellHit.X
      else
        newColIndex := -1;
    end;

    if (newColIndex = -1) then
    begin
      if (HorzAxis.RollStartVisPos = 0) then
        newColIndex := HorzAxis.FixedCelCount - HorzAxis.FrozenCelCount
      else
        newColIndex := HorzAxis.RollStartVisCel + HorzAxis.FixedCelCount;
    end;

    newFreeEndCell.X := newColIndex - StartDataColIndex;
  end
  else if (cellHit.X >= 0) then
  begin
    newFreeEndCell.X := cellHit.X - StartDataColIndex;
  end;

  if (MouseParams.Y > MSrv.ClientRect.Bottom) then
  begin
    SafeScrollData(0, HorzAxis.GetScrollStep());
    newRowIndex := VertAxis.RollLastVisCel + VertAxis.FixedCelCount;
    newFreeEndCell.Y := newRowIndex - StartDataRowIndex;
  end
  else if (MouseParams.Y < MSrv.ClientRect.Top) then
  begin
    SafeScrollData(0, -HorzAxis.GetScrollStep());
    newRowIndex := VertAxis.RollStartVisCel + VertAxis.FixedCelCount;
    newFreeEndCell.Y := newRowIndex - StartDataRowIndex;
  end
  else if (cellHit.Y >= 0) then
  begin
    newFreeEndCell.Y := cellHit.Y - StartDataRowIndex;
  end;

  if (newFreeEndCell.Y >= VisibleRows.Count) then
    newFreeEndCell.Y := VisibleRows.Count - 1;
  if (newFreeEndCell.X < 0) then
    newFreeEndCell.X := 0;
  Selection.SetFreeEndCell(newFreeEndCell);
end;

procedure TCustomDataGridEh.SelectionChanged;
begin
  if not (csDestroying in ComponentState) then
  begin
    if (VertScrollBarPanelControl <> nil) and VertScrollBarPanelControl.Visible then
      VertScrollBarPanelControl.GridSelectionChanged;
    if (HorzScrollBarPanelControl <> nil) and HorzScrollBarPanelControl.Visible then
      HorzScrollBarPanelControl.GridSelectionChanged;

    HandleSelectionChanged;
  end;
  Invalidate;
end;

procedure TCustomDataGridEh.HandleSelectionChanged;
begin

end;

procedure TCustomDataGridEh.SetSelection(const Value: TDataGridSelectionEh);
begin
  FSelection.Assign(Value);
end;

procedure TCustomDataGridEh.SetSelectionOptions(const Value: TDataGridSelectionOptionsEh);
begin
  FSelectionOptions.Assign(Value);
end;

procedure TCustomDataGridEh.OptimizeAllColsWidth(const CheckRowCount : Integer = -1;
  const MaxWaitingTime: Integer = 0);
var
  I: Integer;
  ColumnsList: TColumnsListEh;
begin
  ColumnsList := TColumnsListEh.Create;
  try
    for I := 0 to VisibleColumns.Count-1 do
      ColumnsList.Add(VisibleColumns[I]);
    OptimizeColsWidth(ColumnsList, CheckRowCount, MaxWaitingTime);
  finally
    ColumnsList.Free;
  end;
end;

procedure TCustomDataGridEh.OptimizeColsWidth(ColumnsList: TColumnsListEh;
  const CheckRowCount : Integer = -1; const MaxWaitingTime: Integer = 0);

  procedure CalcTitleWidth(Column: TDataGridBaseColumnEh; var MaxColWidth: Integer);
  begin
    MaxColWidth := Column.Title.CalcNeededCellWidth(Canvas);
  end;

  procedure CalcDataWidth(Column: TDataGridBaseColumnEh; ADataRowIndex: Integer; Row: TDataGridRowEh; var MaxColWidth: Integer);
  var
    CurColWidth: Integer;
  begin
    CurColWidth := Column.CalcNeededDataCellWidth(Canvas, ADataRowIndex);

    if CurColWidth > MaxColWidth then
      MaxColWidth := CurColWidth;
  end;

var
  Rn, RCount: Integer;
  ColWidths: array of Integer;
  WaitingTime: UInt64;
  I: Integer;
  Row: TDataGridRowEh;
begin
  SetLength(ColWidths, ColumnsList.Count);

  for I := 0 to ColumnsList.Count-1 do
    begin
      CalcTitleWidth(ColumnsList[i], ColWidths[i]);
    end;

  if not GridView.Active then Exit;

  RCount := GridView.Rows.Count;
  if MaxWaitingTime > 0
    then WaitingTime := GetTickCountEh
    else WaitingTime := 0;
  try
    for Rn := 0 to VisibleRows.Count - 1 do
    begin
      Row := VisibleRows[Rn];

      for I := 0 to ColumnsList.Count-1 do
      begin
        CalcDataWidth(ColumnsList[i], Rn, Row, ColWidths[i]);
      end;

      if (CheckRowCount > -1) and
         (Rn >= CheckRowCount)
      then
        Break;

      if (Rn >= RCount)then
        Break;

      if (MaxWaitingTime > 0) and
         (GetTickCountEh - WaitingTime > UInt64(MaxWaitingTime)) then
      begin
        Break;
      end;
    end;
  finally
  end;

  if not AutoFitColWidths then BeginLayout;
  try
    for I := 0 to ColumnsList.Count-1 do
    begin
      if ColWidths[i] < 10 then
        ColumnsList[i].Width := 10
      else
        ColumnsList[i].Width := ColWidths[i];
    end;
  finally
    if not AutoFitColWidths then EndLayout;
  end;
end;

procedure TCustomDataGridEh.SaveBookmark;
begin
end;

procedure TCustomDataGridEh.RestoreBookmark;
begin
end;

procedure TCustomDataGridEh.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Xi, Yi: Integer;
  AGridState: TBaseGridMouseStateEh;
  ASizingIndex, ASizingPos, ASizingOfs: Integer;
  Column: TDataGridBaseColumnEh;
  DataColIdx: Integer;
begin
  if (ssDouble in Shift) and (Button = TMouseButton.mbLeft) then
  begin
    Xi := Trunc(X);
    Yi := Trunc(Y);
    CalcSizingState(Xi, Yi, AGridState, ASizingIndex, ASizingPos, ASizingOfs);
    if (AGridState = GridMouseStateManage.ColSizingState) then
    begin
      if (Title.DblClickOptimizeColWidth = True) then
      begin
        DataColIdx := RawToDataColumn(ASizingIndex);
        Column := Columns[DataColIdx];
        Column.OptimizeWidth;
      end;
      Exit;
    end;
  end;

  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TCustomDataGridEh.ProcessPreviewVirtPanelMouseDown(APanel: TLaHostVirtualPanelEh; MouseParams: TControlMouseButtonParamsEh);
var
  Xi, Yi: Integer;
  AGridState: TBaseGridMouseStateEh;
  ASizingIndex, ASizingPos, ASizingOfs: Integer;
  Column: TDataGridBaseColumnEh;
  DataColIdx: Integer;
  LocalMousePos: TPointF;
  ColsList: TColumnsListEh;
  Col: TFieldBarEh;
begin
  if (ssDouble in MouseParams.Shift) and
     (MouseParams.Button = TMouseButton.mbLeft) then
  begin
    LocalMousePos := MouseParams.GetPositionRelativeTo(Self);

    Xi := Trunc(LocalMousePos.X);
    Yi := Trunc(LocalMousePos.Y);
    CalcSizingState(Xi, Yi, AGridState, ASizingIndex, ASizingPos, ASizingOfs);
    if (AGridState = GridMouseStateManage.ColSizingState) then
    begin
      if (Title.DblClickOptimizeColWidth = True) then
      begin
        Capture;
        DataColIdx := RawToDataColumn(ASizingIndex);
        Column := VisibleColumns[DataColIdx];
        if Selection.SelectionType = TDataGridSelectionTypeEh.All then
        begin
          ColsList := TColumnsListEh.Create;
          for Col in VisibleColumns do
            ColsList.Add(Col);
          OptimizeColsWidth(ColsList);
          ColsList.Free;
        end else if (Selection.SelectionType = TDataGridSelectionTypeEh.Columns) and
                    (Selection.Columns.IndexOf(Column) >= 0) then
        begin
          ColsList := TColumnsListEh.Create;
          for Col in Selection.Columns do
            ColsList.Add(Col);
          OptimizeColsWidth(ColsList);
          ColsList.Free;
        end else
        begin
          Column.OptimizeWidth;
        end;
        Capture;
        SetGridMouseState(GridMouseStateManage.OptimizeColWidths);
      end;
      Exit;
    end;
  end;

  inherited ProcessPreviewVirtPanelMouseDown(APanel, MouseParams);
end;

procedure TCustomDataGridEh.ProcessVirtPanelMouseDown(APanel: TLaHostVirtualPanelEh;
  MouseParams: TControlMouseButtonParamsEh);
begin
  inherited ProcessVirtPanelMouseDown(APanel, MouseParams);

  if (APanel = HDataVDataPanel) and (MouseParams.OriginalObject is TGridBaseCellEh) then
  begin
    if (SelectionOptions.DataCellSelectionTime = TDataCellSelectionTimeEh.OnMouseDown) then
    begin
      if (FDataGridMouseState = TDataGridMouseStateEh.Normal) and
              (SelectionOptions.RowSelect = True) and
              CanSelectType(TDataGridSelectionTypeEh.RecordBookmarks) and
              (MouseParams.Button = TMouseButton.mbLeft) then
      begin
        Capture;
        StartRowSelection(TGridBaseCellEh(MouseParams.OriginalObject).RowIndex, MouseParams.Shift);
      end;
    end;
  end;
end;

procedure TCustomDataGridEh.MouseMove(Shift: TShiftState; X, Y: Single);

  function CheckTitlePanel(ScreenMousePos: TPointF): Boolean;
  var
    ControlAtPos: IControl;
    ParentObject: TFmxObject;
    MouseData: TGridMouseColMovingStateEh;
    GroupDescription: TDataGridGroupDescriptionEh;
    ExtraData: TObject;
    ColumnIndex: Integer;
  begin
    Result := False;
    ControlAtPos := ObjectAtPoint(ScreenMousePos);
    if ControlAtPos <> nil then
    begin
      ParentObject := ControlAtPos.GetObject;
      while ParentObject <> nil do
      begin
//        if ParentObject is TDataGridGroupingPanelEh then
        if (ParentObject is TLaHostVirtualPanelEh) and
           (TLaHostVirtualPanelEh(ParentObject) = HDataVFixedPanel) then
        begin
          Result := True;
          Break;
        end;
        ParentObject := ParentObject.Parent;
      end;
    end;

    if Result = True then
    begin
      GroupDescription := GridMouseStateManage.GroupDescriptionMovingState.GroupDescriptionFrom as TDataGridGroupDescriptionEh;
      ExtraData := GridMouseStateManage.GroupDescriptionMovingState.ExtraData;
      if ExtraData is TDataGridBaseColumnEh then
      begin
        ColumnIndex := VisibleColumns.IndexOf(TDataGridBaseColumnEh(ExtraData));
        ColumnIndex := DataToRawColumn(ColumnIndex);
      end else
      begin
        ColumnIndex := -1;
      end;

      GridMouseStateManage.GroupDescriptionMovingState.ExtraData := nil;
      SetGridMouseState(GridMouseStateManage.NormalState);
      HideMove;

      MouseData := InitGridMouseColMovingState(ColumnIndex, -1, ScreenMousePos, GroupDescription);
      SetGridMouseState(MouseData);
      DrawMove;
      SetGridTimer(True, 60);
    end;
  end;

  function CheckGroupingPanel(ScreenMousePos: TPointF): Boolean;
  var
    ControlAtPos: IControl;
    ParentObject: TFmxObject;
    MouseData: TDataGridGroupDescriptionMovingStateEh;
    ExtraData: TObject;
    MoveFromIndex: Integer;
    DataColIndex: Integer;
    //GroupDescription: TDataGridGroupDescriptionEh;
  begin
    Result := False;
    if GroupingPanel.Visible = False then Exit;

    ControlAtPos := ObjectAtPoint(ScreenMousePos);
    if ControlAtPos <> nil then
    begin
      ParentObject := ControlAtPos.GetObject;
      while ParentObject <> nil do
      begin
        if (ParentObject is TDataGridGroupingPanelEh) and
           (TDataGridGroupingPanelEh(ParentObject) = GroupingPanel) then
        begin
          Result := True;
          Break;
        end;
        ParentObject := ParentObject.Parent;
      end;
    end;

    if Result = True then
    begin
      ExtraData := GridMouseStateManage.ColMovingState.ExtraData;
      MoveFromIndex := GridMouseStateManage.ColMovingState.MoveFromIndex;
      GridMouseStateManage.ColMovingState.ExtraData := nil;

      SetGridMouseState(GridMouseStateManage.NormalState);
      HideMove;
      SetGridTimer(False, 0);

      if (MoveFromIndex = -1) and
         (ExtraData is TDataGridGroupDescriptionEh) then
      begin
        MouseData := GridMouseStateManage.GroupDescriptionMovingState;
        MouseData.GroupDescriptionFrom := TDataGridGroupDescriptionEh(ExtraData);
        MouseData.UpdateStateForMousePos(ScreenMousePos);
        SetGridMouseState(MouseData);
        DrawMove;
      end else
      begin
        MouseData := GridMouseStateManage.GroupDescriptionMovingState;
        MouseData.GroupDescriptionFrom := nil;
        DataColIndex := RawToDataColumn(MoveFromIndex);
        MouseData.ExtraData := VisibleColumns[DataColIndex];
        MouseData.UpdateStateForMousePos(ScreenMousePos);
        SetGridMouseState(MouseData);
        DrawMove;
      end;
    end;
  end;

var
  ScreenMousePos: TPointF;
  MousePos: TPointF;
begin
  if GridMouseState = GridMouseStateManage.ColMovingState then
  begin
    MousePos := TPointF.Create(X, Y);
    ScreenMousePos := LocalToScreen(MousePos);
    if CheckGroupingPanel(ScreenMousePos) = True then
      Exit;
  end;

  inherited MouseMove(Shift, X, Y);

  if GridMouseState = GridMouseStateManage.GroupDescriptionMovingState then
  begin
    MousePos := TPointF.Create(X, Y);
    ScreenMousePos := LocalToScreen(MousePos);
    if CheckTitlePanel(ScreenMousePos) = True then
      Exit;

    GridMouseStateManage.GroupDescriptionMovingState.UpdateStateForMousePos(ScreenMousePos);
  end;
end;

procedure TCustomDataGridEh.CellMouseMove(ACellMan: TBaseGridCellManagerEh; CellParams: TGridCellMouseParamsEh);
begin
  inherited CellMouseMove(ACellMan, CellParams);

  if FMoveAndScrollService.Active then
  begin
    FMoveAndScrollService.MouseMove(CellParams.BaseParams);
  end
  else if (ssLeft in CellParams.BaseParams.Shift) and
          (Root.Captured <> nil) and
          (Root.Captured.GetObject is TGridBaseCellEh) and
          ((FMouseDownCell.X <> CellParams.ColIndex) or (FMouseDownCell.Y <> CellParams.RowIndex)) and
          (GridMouseState = GridMouseStateManage.NormalState) and
          (CellParams.ColIndex >= StartDataColIndex) and
          (CellParams.RowIndex >= StartDataRowIndex) then
  begin
    if SelectionOptions.DataCellSelectionTime = TDataCellSelectionTimeEh.OnMouseDown then
    begin
      if CanSelectType(TDataGridSelectionTypeEh.Rectangle) then
      begin
        Capture;
        StartDataCellsSelection(CellParams.ColIndex, CellParams.RowIndex);
      end;
//      else if (FDataGridMouseState = TDataGridEhMouseState.Normal) and
//              (SelectionOptions.RowSelect = True) and
//              CanSelectType(TDataGridEhSelectionType.RecordBookmarks) then
//      begin
//        Capture;
//        StartRowSelection(FMouseDownCell.Y, CellParams.BaseParams.Shift);
//      end;
    end;
  end;
end;

procedure TCustomDataGridEh.ProcessVirtPanelMouseMove(APanel: TLaHostVirtualPanelEh; MouseParams: TControlMouseParamsEh);
var
  GridCell: TGridBaseCellEh;
begin
  inherited ProcessVirtPanelMouseMove(APanel, MouseParams);

  if (APanel = HDataVDataPanel) and (MouseParams.OriginalObject is TGridBaseCellEh) then
  begin
    GridCell := TGridBaseCellEh(MouseParams.OriginalObject);
    if (SelectionOptions.DataCellSelectionTime = TDataCellSelectionTimeEh.OnMouseMove) and
       (FMoveAndScrollService.Active = False) and
       (GridCell.IsMouseCaptured = True) and
       (GridCell.LocalRect.Contains(TPointF.Create(MouseParams.X, MouseParams.Y)) = False) then
    begin
      if CanSelectType(TDataGridSelectionTypeEh.Rectangle) and
         (ssLeft in MouseParams.Shift) then
      begin
        Capture();
        StartDataCellsSelection(GridCell.ColIndex, GridCell.RowIndex);
      end
      else if (FDataGridMouseState = TDataGridMouseStateEh.Normal) and
              (SelectionOptions.RowSelect = True) and
              (CanSelectType(TDataGridSelectionTypeEh.RecordBookmarks) = True) and
              (ssLeft in MouseParams.Shift) then
      begin
        Capture();
        StartRowSelection(GridCell.RowIndex, MouseParams.Shift);
      end;
    end;
  end;
end;

procedure TCustomDataGridEh.GetDataGridMouseState(AMouseX, AMouseY: Single;
  AColIndex, ARowIndex: Integer; const ACellRect: TRect;
  AInCellX, AInCellY: Integer;
  out ADataGridMouseState: TDataGridMouseStateEh; out ACellAreaWantMouseDown: Boolean);
var
  CellBottomRect: TRect;
begin
  ADataGridMouseState := TDataGridMouseStateEh.Normal;
  ACellAreaWantMouseDown := False;
  if (Title.Visible = True) and
     (ARowIndex = 0) and
     (AColIndex >= StartDataColIndex) and
     (TDataGridSelectionTypeEh.Columns in SelectionOptions.AllowedSelections) then
  begin
    CellBottomRect := ACellRect;
    CellBottomRect.Offset(-CellBottomRect.Left, -CellBottomRect.Top);
    CellBottomRect.Top := CellBottomRect.Bottom - 7;
    ACellAreaWantMouseDown := False;

    if (ACellAreaWantMouseDown = False) and
       (AInCellY >= CellBottomRect.Top) and
       (AInCellY <= CellBottomRect.Bottom)
    then
      ADataGridMouseState := TDataGridMouseStateEh.ColSelecting;
  end
  else if IndicatorColumn.Visible and
          (AColIndex = IndicatorColumn.BaseColIndex) and
          (ARowIndex >= StartDataRowIndex) and
          (ARowIndex < RowCount) and
          GridView.Active and
          (GridView.Rows.Count > 0) and
          (TDataGridSelectionTypeEh.RecordBookmarks in SelectionOptions.AllowedSelections)
  then
  begin
    ADataGridMouseState := TDataGridMouseStateEh.RowSelecting;
  end;
end;

procedure TCustomDataGridEh.ProcessPreviewVirtPanelMouseMove(APanel: TLaHostVirtualPanelEh; MouseParams: TControlMouseParamsEh);
begin
  inherited ProcessPreviewVirtPanelMouseMove(APanel, MouseParams);
end;

procedure TCustomDataGridEh.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  AMovingNode: TDataGridComplexTitleTreeNodeEh;
  AParentNode: TDataGridComplexTitleTreeNodeEh;
  AMovingState: TDataGridMouseComplexTitleMovingStateEh;
  FTreeOrderedList: TList<TFieldBarEh>;
  Description: TDataGridGroupDescriptionEh;
  DescriptionToIndex: Integer;
  ExtraData: TObject;
begin
  try
    if GridMouseState = GridMouseStateManage.GroupDescriptionMovingState then
    begin
      ExtraData := GridMouseStateManage.GroupDescriptionMovingState.ExtraData;
      GridMouseStateManage.GroupDescriptionMovingState.ExtraData := nil;
      Description := GridMouseStateManage.GroupDescriptionMovingState.GroupDescriptionFrom as TDataGridGroupDescriptionEh;
      DescriptionToIndex := GridMouseStateManage.GroupDescriptionMovingState.GroupDescriptionToIndex;

      SetGridMouseState(GridMouseStateManage.NormalState);
      HideMove;

      if (GridMouseStateManage.GroupDescriptionMovingState.GroupDescriptionFrom = nil) and
         (ExtraData is TDataGridBaseColumnEh) then
      begin
        DataGrouping.GroupDescriptions.BeginUpdate;
        try
          Description := DataGrouping.GroupDescriptions.Insert(DescriptionToIndex) as TDataGridGroupDescriptionEh;
          Description.Column := TDataGridBaseColumnEh(ExtraData);
          Description.Column.Visible := False;
        finally
          DataGrouping.GroupDescriptions.EndUpdate;
        end;
      end else
      begin
        if Description.Index < DescriptionToIndex then
          DescriptionToIndex := DescriptionToIndex - 1;
        Description.Index := DescriptionToIndex;
      end;
    end
    else if GridMouseState = GridMouseStateManage.ComplexTitleMovingState then
    begin
      SetGridMouseState(GridMouseStateManage.NormalState);
      HideMove;
      FMoveAndScrollService.Release;
      AMovingState := GridMouseStateManage.ComplexTitleMovingState;
      AParentNode := TDataGridComplexTitleTreeNodeEh(AMovingState.ParentNode);
      AMovingNode :=  AParentNode.VisibleItem[AMovingState.MovingNodeIndex];
      Title.ComplexTitleTree.MoveVisibleNode(AMovingNode, AParentNode, AMovingState.MoveToNodeIndex);
      LayoutChanged;
      FTreeOrderedList := TList<TFieldBarEh>.Create;
      Title.ComplexTitleTree.GetColumnsList(FTreeOrderedList);
      DisplayColumns.SetFieldBarsOrder(FTreeOrderedList);
      FTreeOrderedList.Free;
      UpdateEdit;
    end;

    inherited MouseUp(Button, Shift, X, Y);

  finally
    if FDataGridMouseState <> TDataGridMouseStateEh.Normal then
    begin
      if (FMoveAndScrollService.Active) then
        FMoveAndScrollService.Release();
      FDataGridMouseState := TDataGridMouseStateEh.Normal;
      Invalidate;
    end;
  end;
end;

procedure TCustomDataGridEh.DoMouseLeave;
begin
  inherited DoMouseLeave;
end;

procedure TCustomDataGridEh.SetPotentialMouseState(ACellParams: TGridCellMouseParamsEh);
var
  ACellAreaWantMouseDown: Boolean;
  ADataGridMouseState: TDataGridMouseStateEh;
begin
  inherited SetPotentialMouseState(ACellParams);

  if (FGridPotentialMouseState = GridMouseStateManage.NormalState) then
  begin
    if (FDataGridMouseState = TDataGridMouseStateEh.Normal) then
    begin
      GetDataGridMouseState(ACellParams.BaseParams.X, ACellParams.BaseParams.Y,
        ACellParams.ColIndex, ACellParams.RowIndex, ACellParams.CellRect,
        ACellParams.InCellX, ACellParams.InCellY, ADataGridMouseState, ACellAreaWantMouseDown);

      if ACellAreaWantMouseDown = True then
        FDataGridPotentialMouseState := TDataGridMouseStateEh.Normal
      else if (ACellParams.BaseParams.OriginalObject <> nil) and
              (ACellParams.BaseParams.OriginalObject is TGridBaseCellEh)
      then
        FDataGridPotentialMouseState := ADataGridMouseState
      else
        FDataGridPotentialMouseState := TDataGridMouseStateEh.Normal;
    end else
      FDataGridPotentialMouseState := FDataGridMouseState;
  end else
  begin
    FDataGridPotentialMouseState := TDataGridMouseStateEh.Normal;
  end;
end;

function TCustomDataGridEh.GetCursorForMouseState(MouseState: TDataGridMouseStateEh): TCursor;
begin
  if (MouseState = TDataGridMouseStateEh.ColSelecting) then
  begin
    Result := crCross;
  end
  else if (MouseState = TDataGridMouseStateEh.RowSelecting) and
          ((IsMouseCaptured = False) or
           ((IsMouseCaptured = True) and (FMouseDownCell.X = IndicatorColumn.BaseColIndex))
          )  then
  begin
    Result := crCross;
  end
  else
  begin
    Result := crDefault;
  end;
end;

function TCustomDataGridEh.GetCursorAtMousePos(Params: TGridCellMouseParamsEh): TCursor;
begin
  if FDataGridMouseState <> TDataGridMouseStateEh.Normal then
  begin
    Result := GetCursorForMouseState(FDataGridMouseState);
  end else
  begin
    Result := inherited GetCursorAtMousePos(Params);

    if (Result <> crDefault) then Exit;

    if not ((Params.BaseParams <> nil) and
            (Params.BaseParams.OriginalObject is TGridBaseCellEh))
    then
      Exit;

    Result := GetCursorForMouseState(FDataGridPotentialMouseState);
  end;
end;

function TCustomDataGridEh.CheckBeginColumnDrag(var Origin, Destination: Integer;
  const MousePt: TPoint): Boolean;
var
  ADataGridMouseState: TDataGridMouseStateEh;
  VCellRect: TRect;
  CellMousePos: TPoint;
  ACellAreaWantMouseDown: Boolean;
begin
  if FDataGridMouseState <> TDataGridMouseStateEh.Normal then
    Exit(False);

  VCellRect := CellRectAbs(Origin, 0);
  CellMousePos := Point(MousePt.X - VCellRect.Left, MousePt.Y - VCellRect.Top);

  GetDataGridMouseState(MousePt.X, MousePt.Y, Origin, 0, VCellRect,
    CellMousePos.X, CellMousePos.Y, ADataGridMouseState, ACellAreaWantMouseDown);

  if ColumnOptions.AllowMove = False then
    Result := False
  else if ACellAreaWantMouseDown = True then
    Result := False
  else if (ADataGridMouseState = TDataGridMouseStateEh.ColSelecting) then
    Result := False
  else if True then
    Result := inherited CheckBeginColumnDrag(Origin, Destination, MousePt);
end;

function TCustomDataGridEh.CreateTitle: TAxisGridTitleBarEh;
begin
  Result := TDataGridTitleBarEh.Create(Self);
end;

function TCustomDataGridEh.GetTitle: TDataGridTitleBarEh;
begin
  Result := TDataGridTitleBarEh(inherited Title);
end;

procedure TCustomDataGridEh.SetTitle(const Value: TDataGridTitleBarEh);
begin
  inherited Title := Value;
end;

function TCustomDataGridEh.ShowContextMenu(const ScreenPosition: TPointF): Boolean;
var
  UseMousePos: Boolean;
  APopupMenu: TCustomPopupMenu;
  LocalPosition: TPoint;
  CellCoord: TGridCoord;
begin
  Result := inherited ShowContextMenu(ScreenPosition);
  if Result then Exit;

  UseMousePos := True;
  APopupMenu := nil;

  if (UseMousePos = True) then
  begin
    LocalPosition := ScreenToLocal(ScreenPosition).Round;
    cellCoord := MouseCoord(LocalPosition.X, LocalPosition.Y);
    if ((cellCoord.X >= 0) and (cellCoord.Y >= 0)) then
      APopupMenu := GetCellContextMenu(LocalPosition, cellCoord.X, cellCoord.Y);
  end
  else
  begin
  end;

  if APopupMenu <> nil then
  begin
    ReleaseCapture;
    APopupMenu.PopupComponent := Self;
    APopupMenu.Popup(Round(ScreenPosition.X), Round(ScreenPosition.Y));
    Result := True;
  end;
end;

function TCustomDataGridEh.GetCellContextMenu(MousePos: TPoint; ColIndex, RowIndex: Integer): TCustomPopupMenu;
begin
  Result := nil;
end;

procedure TCustomDataGridEh.ApplySorting;
begin
  DefaultApplySorting;
end;

procedure TCustomDataGridEh.DefaultApplySorting;
begin
  Center.ApplySorting(Self);
end;

function TCustomDataGridEh.GetDefaultStyleLookupName: string;
begin
  Result := 'DataGridEhStyle';
end;

procedure TCustomDataGridEh.ApplyStyle;
var
  BrushObject: TBrushObject;
begin

  inherited ApplyStyle;

  if FindStyleResource<TBrushObject>('TitleFill', BrushObject)
    then StylePainter.TitleFill.Assign(BrushObject.Brush)
    else StylePainter.TitleFill.Kind := TBrushKind.None;

  if FindStyleResource<TBrushObject>('IndicatorFill', BrushObject)
    then StylePainter.IndicatorFill.Assign(BrushObject.Brush)
    else StylePainter.IndicatorFill.Kind := TBrushKind.None;

//  if SearchPanelControl.Visible then
//    SearchPanelControl.FindEditor.ApplyStyleLookup();

  LayoutChanged(True);
//  UpdateScrollBars();
end;

procedure TCustomDataGridEh.StyleApplied;
begin
  inherited StyleApplied;
  Footer.RefreshDefaultFont;
  Footer.RefreshDefaultFill;
//  Footer.RefreshDefaultFontColor;
end;

procedure TCustomDataGridEh.DoBeforeFirstDrawing;
begin
  inherited DoBeforeFirstDrawing;

end;

procedure TCustomDataGridEh.DoEnter;
begin
  inherited DoEnter;
end;

function TCustomDataGridEh.MoveBy(Distance: Integer): Integer;
begin
  Result := 0;
  if (Distance = 0) then Exit;
  Result := GridView.MoveRowPosBy(Distance);
end;

function TCustomDataGridEh.CanEditModify: Boolean;
var
  Column: TDataGridBaseColumnEh;
begin
  Column := VisibleColumns[CurrentColIndex];
  Result := Column.CanEditModify;
end;

function TCustomDataGridEh.GetCurrentFieldBar: TFieldBarEh;
begin
  Result := GetCurrentColumn;
end;

function TCustomDataGridEh.GetCurrentColumn: TDataGridBaseColumnEh;
begin
  if (CurrentColIndex >= 0) and (CurrentColIndex < VisibleColumns.Count) then
    Result := VisibleColumns[CurrentColIndex]
  else
    Result := nil;
end;

function TCustomDataGridEh.GetCurrentRow: TDataGridRowEh;
begin
  if (CurrentRowIndex >= 0) and (CurrentRowIndex < GridView.Rows.Count)
    then Result := GridView.Rows[CurrentRowIndex]
    else Result := nil;
end;

function TCustomDataGridEh.GetCurrentDataRow: TDataGridDataRowEh;
begin
  if CurrentRow is TDataGridDataRowEh
    then Result := TDataGridDataRowEh(CurrentRow)
    else Result := nil;
end;

function TCustomDataGridEh.GetCurrentColIndex: Integer;
begin
  Result := RawToDataColumn(CurColIndex);
end;

procedure TCustomDataGridEh.SetCurrentColIndex(const Value: Integer);
begin
  InteractiveFocusCell(DataToRawColumn(Value), CurRowIndex, TInteractiveActionSourceEh.Other);
end;

function TCustomDataGridEh.GetCurrentRowIndex: Integer;
begin
  Result := GridView.CurrentRowIndex;
end;

procedure TCustomDataGridEh.SetCurrentRowIndex(const Value: Integer);
begin
  if Value = -1 then
    CurrentRow := nil
  else
    InteractiveFocusCell(CurColIndex, DataToRawRowIndex(Value), TInteractiveActionSourceEh.Other);
end;

procedure TCustomDataGridEh.SetCurrentRow(const Value: TDataGridRowEh);
var
  RowIndex: Integer;
begin
  if Value = nil then
  begin
    GridView.CurrentRowIndex := -1;
  end else
  begin
    RowIndex := GridView.Rows.IndexOf(Value);
    if RowIndex >= 0 then
      GridView.CurrentRowIndex := RowIndex
    else
      raise Exception.Create('TCustomDataGridEh.SetCurrentRow: DataGridRow is not in the list of Rows');
  end;
end;

function TCustomDataGridEh.GetCurrentListItemBar: TTableRowViewEh;
begin
  Result := TableView.CurrentRowView;
end;

function TCustomDataGridEh.GetColumnOptions: TDataGridColumnOptionsEh;
begin
  Result := TDataGridColumnOptionsEh(FieldBarOptions);
end;

procedure TCustomDataGridEh.SetColumnOptions(const Value: TDataGridColumnOptionsEh);
begin
  FieldBarOptions := Value;
end;

procedure TCustomDataGridEh.SetSearchPanel(const Value: TDataGridSearchPanelEh);
begin
  FSearchPanel.Assign(Value);
end;

procedure TCustomDataGridEh.SetSearchPanelMode(const Value: Boolean);
var
  VSearchPanel: TDataGridSearchPanelEhCrack;
begin
  VSearchPanel := TDataGridSearchPanelEhCrack(SearchPanel);
  if Value <> FSearchPanelMode then
  begin
    FSearchPanelMode := Value;
    if not FSearchPanelMode and VSearchPanel.InternalGetActive then
      VSearchPanel.InternalSetActive(False)
    else if FSearchPanelMode and not VSearchPanel.InternalGetActive then
      VSearchPanel.InternalSetActive(True);
    if VSearchPanel.InternalGetActive then
      VSearchPanel.FFoundColumnIndex := CurrentColIndex;
    Invalidate;
  end;
end;

function TCustomDataGridEh.GetDataCellHighlightingText: String;
begin
  if SearchPanel.Enabled and
     (SearchPanel.SearchingText <> '')
  then
    Result := SearchPanel.SearchingText
  else
    Result := '';
end;

function TCustomDataGridEh.LocateText(AGrid: TCustomDataGridEh; const FieldName: string;
  const Text: String; Options: TLocateTextOptionsEh; Direction: TLocateTextDirectionEh;
  Matching: TLocateTextMatchingEh; TreeFindRange: TLocateTextTreeFindRangeEh;
  TimeOut: LongWord = 0; CheckValueEvent: TCheckColumnValueAcceptEventEh = nil): Boolean;
begin
  StartWait;
  try
    Result := Center.LocateText(Self, FieldName, Text,
      Options, Direction, Matching, TreeFindRange, TimeOut, CheckValueEvent);
  finally
    StopWait;
  end;
end;

procedure TCustomDataGridEh.CheckCellHitSearchPanelData(AColumn: TDataGridBaseColumnEh; ARow: TDataGridRowEh;
  var Accept: Boolean; SearchText: String);
var
  ValueAcceptParams: TDataGridSearchPanelCheckColumnValueAcceptParamsEh;
begin
  ValueAcceptParams := TDataGridSearchPanelCheckColumnValueAcceptParamsEh.Create;
  ValueAcceptParams.Reset(Self, AColumn, ARow, SearchText);
  try
    if Assigned(SearchPanel.OnCheckCellHitSearch)
      then SearchPanel.OnCheckCellHitSearch(SearchPanel, ValueAcceptParams)
      else ValueAcceptParams.DefaultCheckColumnValueAccept();

    Accept := ValueAcceptParams.Accept;
  finally
    ValueAcceptParams.Free;
  end;
end;

function TCustomDataGridEh.CreateSearchPanel: TDataGridSearchPanelEh;
begin
  Result := TDataGridSearchPanelEh.Create(Self);
end;

procedure TCustomDataGridEh.UpdateScrollBarPanels;
begin
  inherited UpdateScrollBarPanels;
  if (GridView <> nil) and (HorzScrollBarPanelControl <> nil) then
  begin
    HorzScrollBarPanelControl.ExtraPanel.Visible := HorzScrollBar.ExtraPanel.Visible;
    HorzScrollBarPanelControl.ExtraPanel.VisibleButtons := HorzScrollBar.ExtraPanel.NavigatorButtons;
    HorzScrollBarPanelControl.ExtraPanel.VisibleItems := HorzScrollBar.ExtraPanel.VisibleItems;
    HorzScrollBarPanelControl.ExtraPanel.BorderColor := GridLineParams.BrightColor;
  end;
end;

procedure TCustomDataGridEh.UpdateScrollBars;
begin
  if LayoutLock = 0  then
  begin
    inherited UpdateScrollBars;
    if IsCanvasEnabled then
    begin
      UpdateSearchPanel;
      UpdateGroupingPanel;
    end;
  end;
end;

procedure TCustomDataGridEh.UpdateGroupingPanel;
var
  SPRect: TRectF;
begin
  if GroupingPanel = nil then Exit;

  if DataGrouping.GroupingPanelVisible then
  begin
    GroupingPanel.Visible := True;
    SPRect.Left := WinClientBoundary.Left;
    SPRect.Top := WinClientBoundary.Top + FSearchPanelControl.Height;
    SPRect.Width := ClientWidth - OutBoundaryData.RightIndent - VertScrollBarPanelControl.Width;
    SPRect.Height := GroupingPanel.CalcAutoHeight;

    if not EqualRect(GroupingPanel.BoundsRect, SPRect) then
    begin
      GroupingPanel.SetBounds(SPRect.Left, SPRect.Top, RectWidth(SPRect), RectHeight(SPRect));
//      DoLayoutChanged := True;
    end;
  end else
  begin
    GroupingPanel.SetBounds(0, 0, 0, 0);
    GroupingPanel.Visible := False;
  end;
end;

procedure TCustomDataGridEh.UpdateSearchPanel;
var
  DoLayoutChanged: Boolean;
  SPRect: TRectF;
begin
  if SearchPanel = nil then Exit;
  if HorzScrollBarPanelControl = nil then Exit;

  if SearchPanel.Visible then
  begin

    FSearchPanelControl.Location := SearchPanel.Location;

    if SearchPanel.Location = TSearchPanelLocationEh.GridTop then
    begin
      if HorzScrollBarPanelControl.ExtraPanel.SearchPanelControl <> nil then
      begin
        HorzScrollBarPanelControl.ExtraPanel.SearchPanelControl := nil;
        FSearchPanelControl.Parent := Self;
      end;
      if not IsCanvasEnabled then Exit;
      FSearchPanelControl.ResetVisibleControls;

      DoLayoutChanged := False;
      if UseRightToLeftAlignment then
        SPRect := RectF(ClientWidth - HorzAxis.GridClientStop,
                        0,
                        ClientWidth - OutBoundaryData.RightIndent{-VertScrollBarPanelControl.Width},
                        FSearchPanelControl.CalcAutoHeight)
      else
      begin
        SPRect.Left := WinClientBoundary.Left;
        SPRect.Top := WinClientBoundary.Top;
        SPRect.Width := ClientWidth - OutBoundaryData.RightIndent - VertScrollBarPanelControl.Width;
        SPRect.Height := FSearchPanelControl.CalcAutoHeight;
      end;

      if not EqualRect(FSearchPanelControl.BoundsRect, SPRect) then
      begin
        FSearchPanelControl.SetBounds(SPRect.Left, SPRect.Top, RectWidth(SPRect), RectHeight(SPRect));
        DoLayoutChanged := True;
      end;
      if not FSearchPanelControl.Visible then
      begin
        FSearchPanelControl.Visible := True;
        DoLayoutChanged := True;
      end;
      if UpdateOutBoundaryIndents then
        DoLayoutChanged := True;
      if DoLayoutChanged then
        LayoutChanged;
    end else if SearchPanel.Location = TSearchPanelLocationEh.HorzScrollBarExtraPanel then
    begin
      if HorzScrollBarPanelControl.ExtraPanel.SearchPanelControl = nil then
      begin
        FSearchPanelControl.Parent := nil;
        HorzScrollBarPanelControl.ExtraPanel.SearchPanelControl := FSearchPanelControl;
      end;
      if not IsCanvasEnabled then Exit;
      FSearchPanelControl.ResetVisibleControls;
      FSearchPanelControl.Visible := True;
      HorzScrollBarPanelControl.ExtraPanel.ResetWidth;
      UpdateOutBoundaryIndents;
    end else
    begin
      if not IsCanvasEnabled then Exit;
      DoLayoutChanged := False;
      if not EqualRect(FSearchPanelControl.BoundsRect, Rect(0,0,0,0)) then
      begin
        FSearchPanelControl.SetBounds(0, 0, 0, 0);
        DoLayoutChanged := True;
      end;
      if FSearchPanelControl.Visible then
      begin
        FSearchPanelControl.Visible := False;
        DoLayoutChanged := True;
      end;
      if UpdateOutBoundaryIndents then
        DoLayoutChanged := True;
      if DoLayoutChanged then
        LayoutChanged;
    end;

  end else
  begin
    DoLayoutChanged := False;
    if not EqualRect(FSearchPanelControl.BoundsRect, Rect(0,0,0,0)) then
    begin
      FSearchPanelControl.SetBounds(0, 0, 0, 0);
      DoLayoutChanged := True;
    end;
    if FSearchPanelControl.Visible then
    begin
      FSearchPanelControl.Visible := False;
      DoLayoutChanged := True;
    end;
    if UpdateOutBoundaryIndents then
    begin
      DoLayoutChanged := True;
      UpdateBoundaries;
    end;
    if DoLayoutChanged then
      LayoutChanged;
  end;
end;

procedure TCustomDataGridEh.UpdateEditorMode;
begin
end;

function TCustomDataGridEh.CanShowEditor: Boolean;
begin
  if SearchPanelMode then
    Result := False
  else
    Result := inherited CanShowEditor;
end;

procedure TCustomDataGridEh.RefreshFilteredRows;
begin
  TableView.UpdateFilteredRowList;
end;

function TCustomDataGridEh.UpdateOutBoundaryIndents: Boolean;
var
  TopIndent: Integer;

  function CalcDefTopOutBoundaryHeight: Integer;
  var
    OSize: TSize;
  begin
    Canvas.Font.Assign(Self.Font);
    OSize.cx := Round(Canvas.TextWidth('o'));
    OSize.cy := OSize.cx * 2 div 3;
    Result := Round(OSize.cy + Canvas.TextHeight('Wg') + FInterlinear + 2 + 1 + 5);
  end;

begin
  Result := False;
  if not IsCanvasEnabled then Exit;
  TopIndent := SearchPanel.InGridVertCaptureSize + DataGrouping.InGridVertCaptureSize;

  if OutBoundaryData.TopIndent <> TopIndent then
  begin
    OutBoundaryData.TopIndent := TopIndent;
    Result := True;
  end;
end;

procedure TCustomDataGridEh.NavigatorPanelButtonClick(AButton: TNavigateBtnEh; var Processed: Boolean);
begin

end;

procedure TCustomDataGridEh.UpdateHighlightingTexts;
begin
  FHighlightingTexts.Clear;
  if SearchPanel.Enabled and
     (SearchPanel.SearchingText <> '') then
  begin
    FHighlightingTexts.Add(SearchPanel.SearchingText);
  end;
  Invalidate;
end;

procedure TCustomDataGridEh.UpdateDisplayFieldBarList;

  procedure AddDisplayFieldBarListFromNode(Node: TDataGridComplexTitleTreeNodeEh);
  var
    ChildNode: TDataGridComplexTitleTreeNodeEh;
    I: Integer;
  begin
    if Node.NodeType = TDataGridCompoundTitleTreeNodeTypeEh.ColumnNode then
    begin
      DisplayFieldBarList.Add(Node.Column);
    end else
    begin
      for I := 0 to Node.Count - 1 do
      begin
        ChildNode := TDataGridComplexTitleTreeNodeEh(Node.Items[I]);
        AddDisplayFieldBarListFromNode(ChildNode);
      end;
    end;
  end;

  procedure UpdateDisplayBarListFromTitleTree;
  begin
    DisplayFieldBarList.Clear;
    AddDisplayFieldBarListFromNode(Title.ComplexTitleTree.RootNode);
  end;

begin
  if (Title.IsComplexTitle) then
  begin
    UpdateDisplayBarListFromTitleTree;
  end else
  begin
    inherited UpdateDisplayFieldBarList;
  end;
end;

procedure TCustomDataGridEh.LinkActive(Value: Boolean);
begin
  inherited LinkActive(Value);
  if csDestroying in ComponentState then
    Exit;
  UpdateScrollBars;
end;

procedure TCustomDataGridEh.TableViewDataChanged(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowView: TTableRowViewEh);
begin
  TDataGridDataGroupingEhCrack(FDataGrouping).TableViewDataChanged(AChangedType, NewIndex, OldIndex, ARowView);

  inherited TableViewDataChanged(AChangedType, NewIndex, OldIndex, ARowView);

  CheckClearSelection();

  if AChangedType = TTableLinkEventTypeEh.Reset then
  begin
    Scroll(0);
    RecalcRowHeightsNeeded;
    LayoutChanged;
    DataOrPositionChanged();
  end;

  if (AChangedType = TTableLinkEventTypeEh.Reset) or
     (AChangedType = TTableLinkEventTypeEh.RowAdded) or
     (AChangedType = TTableLinkEventTypeEh.RowDeleted) then
  begin
    Footer.RecalcValues();
    IndicatorColumn.SetWidthRecalcNeeded();
    Selection.TableViewDataChanged(AChangedType, NewIndex, OldIndex, ARowView);
    Scroll(0);
    DataOrPositionChanged();
  end
  else if (AChangedType = TTableLinkEventTypeEh.RowChanged) or
          (AChangedType = TTableLinkEventTypeEh.RowStateChanged) then
  begin
    Footer.RecalcValues();
    if (CurrentDataRow <> nil) and (CurrentDataRow.TableRow = ARowView) then
      DataOrPositionChanged();

    if (GridView.CurrentRow is TDataGridDataRowEh) and
       (ARowView = TDataGridDataRowEh(GridView.CurrentRow).TableRow) and
       (TableView.CurrentRowView.Editing = False) then
    begin
      UpdateDataRowHeight(NewIndex);
      LayoutChanged;
    end;
  end
  else if AChangedType = TTableLinkEventTypeEh.CurrentPosChanged then
  begin
    Scroll(0);
  end;

  if HorzScrollBarPanelControl <> nil then
    TDataGridEhNavigatorPanelCrack(HorzScrollBarPanelControl.ExtraPanel).TableViewDataChanged(AChangedType, NewIndex, OldIndex, ARowView);
  Invalidate;
end;

procedure TCustomDataGridEh.DataOrPositionChanged;
begin
  inherited DataOrPositionChanged;
  if HorzScrollBarPanelControl <> nil then
    TDataGridEhNavigatorPanelCrack(HorzScrollBarPanelControl.ExtraPanel).DataChanged();
end;

function TCustomDataGridEh.CreateHDataVFixedPanel: TLaHostVirtualPanelEh;
begin
  Result := TDataGridTitleVirtualPanelEh.Create(Self);
end;

function TCustomDataGridEh.CreateHFixedVFooterPanel: TLaHostVirtualPanelEh;
begin
  Result := TDataGridFixedFooterCellVirtualPanelEh.Create(Self);
end;

function TCustomDataGridEh.CreateHDataVFooterPanel: TLaHostVirtualPanelEh;
begin
  Result := inherited CreateHDataVFooterPanel();
end;

function TCustomDataGridEh.CreateHFixedVFixedPanel: TLaHostVirtualPanelEh;
begin
  Result := inherited CreateHFixedVFixedPanel;
end;

function TCustomDataGridEh.CreateHFixedVDataPanel: TLaHostVirtualPanelEh;
begin
  Result := inherited CreateHFixedVDataPanel;
end;

function TCustomDataGridEh.CreateHDataVDataPanel: TLaHostVirtualPanelEh;
begin
  Result := TDataGridDataVirtualPanelEh.Create(Self);
end;

//function TCustomDataGridEh.StartColMoving(ColIndex, RowIndex: Integer; InCellX, InCellY: Integer): TGridMouseColMovingDataEh;
procedure TCustomDataGridEh.StartColMoving(ColIndex, RowIndex: Integer; AScreenPos: TPointF);
var
  DataColIndex: Integer;
  Column: TDataGridBaseColumnEh;
  TitleNode: TDataGridComplexTitleTreeNodeEh;
begin
  if Title.IsComplexTitle then
  begin
    DataColIndex := ColIndex - FStartDataColIndex;
    Column := VisibleColumns[DataColIndex];
    TitleNode := Column.Title.ComplexTitleNode;
    StartComplexTitleColMoving(TitleNode, AScreenPos);
  end else
  begin
    inherited StartColMoving(ColIndex, RowIndex, AScreenPos);
  end;
end;

procedure TCustomDataGridEh.StartGroupDescriptionControlMoving(
  AGroupDescription: TDataGridGroupDescriptionEh; AScreenMousePost: TPointF);
var
  MouseState:  TDataGridGroupDescriptionMovingStateEh;
begin
  MouseState := GridMouseStateManage.GroupDescriptionMovingState;
  MouseState.GroupDescriptionFrom := AGroupDescription;
  SetGridMouseState(MouseState);

  MouseState.UpdateStateForMousePos(AScreenMousePost);
end;

procedure TCustomDataGridEh.StartComplexTitleColMoving(ATitleNode: TDataGridComplexTitleTreeNodeEh; AScreenPos: TPointF);
var
  MouseState:  TDataGridMouseComplexTitleMovingStateEh;
  noScrollRect: TRect;
  LocalPos: TPointF;
begin
  LocalPos := ScreenToLocal(AScreenPos);

  MouseState := GridMouseStateManage.ComplexTitleMovingState;
  MouseState.ParentNode := ATitleNode.Parent;

  MouseState.MovingNodeIndex := ATitleNode.VisibleIndex;

  if (LocalPos.X < (ATitleNode.DisplayRect.Left + ATitleNode.DisplayRect.Right) / 2) then
    MouseState.MoveToNodeIndex := MouseState.MovingNodeIndex
  else
    MouseState.MoveToNodeIndex := MouseState.MovingNodeIndex + 1;

  SetGridMouseState(GridMouseStateManage.ComplexTitleMovingState);
  DrawMove;

  noScrollRect.Left := HorzAxis.FixedBoundary;
  noScrollRect.Width := HorzAxis.RollClientLen;
  noScrollRect.Top := VertAxis.GridClientStart;
  noScrollRect.Height := VertAxis.GridClientStop - VertAxis.GridClientStart;

  FMoveAndScrollService.Capture(noScrollRect, ComplexTitleColMovingEventHandler, True, False);
end;

procedure TCustomDataGridEh.ComplexTitleColMovingEventHandler(Sender: TObject; MouseParams: TControlMouseParamsEh);
var
  MouseState:  TDataGridMouseComplexTitleMovingStateEh;
  AParentNode: TDataGridComplexTitleTreeNodeEh;
  ADisplayRect: TRect;
  MousePos: TPoint;
  AMoveToNodeIndex: Integer;
  I: Integer;
begin
  MouseState := GridMouseStateManage.ComplexTitleMovingState;
  AParentNode := TDataGridComplexTitleTreeNodeEh(MouseState.ParentNode);

  if (MouseParams.X > FMoveAndScrollService.ClientRect.Right) then
  begin
    SafeScrollData(HorzAxis.GetScrollStep(), 0);
    DrawMove;
  end
  else if (MouseParams.X < FMoveAndScrollService.ClientRect.Left) then
  begin
    SafeScrollData(-HorzAxis.GetScrollStep(), 0);
    DrawMove;
  end;

  MousePos := TPointF.Create(MouseParams.X, MouseParams.Y).Round;
  ADisplayRect := AParentNode.DisplayRect;
  ADisplayRect.Offset(-HorzAxis.RollStartVisPos + HorzAxis.FixedBoundary, 0);
  if (MousePos.X < ADisplayRect.Left) then
  begin
    MouseState.MoveToNodeIndex := 0;
    DrawMove;
  end
  else if (MousePos.X > ADisplayRect.Right) then
  begin
    MouseState.MoveToNodeIndex := AParentNode.VisibleCount;
    DrawMove;
  end else
  begin
    for I := 0 to AParentNode.VisibleCount - 1 do
    begin
      ADisplayRect := AParentNode.VisibleItem[I].DisplayRect;
      ADisplayRect.Offset(-HorzAxis.RollStartVisPos + HorzAxis.FixedBoundary, 0);
      if (ADisplayRect.Left <= MousePos.X) and (ADisplayRect.Right >= MousePos.X) then
      begin
        AMoveToNodeIndex := I;
        if (MousePos.X > (ADisplayRect.Left + ADisplayRect.Right) div 2) then
          AMoveToNodeIndex := AMoveToNodeIndex + 1;
        if MouseState.MoveToNodeIndex <> AMoveToNodeIndex then
        begin
          MouseState.MoveToNodeIndex := AMoveToNodeIndex;
          DrawMove;
        end;
        Break;
      end;
    end;
  end;
end;

function TCustomDataGridEh.CreateGridMouseStateManager: TGridMouseStateManagerEh;
begin
  Result := TDataGridMouseStateManagerEh.Create(Self);
end;

function TCustomDataGridEh.GetGridMouseStateManage: TDataGridMouseStateManagerEh;
begin
  Result := TDataGridMouseStateManagerEh(inherited GridMouseStateManage)
end;

procedure TCustomDataGridEh.GridTimerEvent(Sender: TObject);
begin
  if (GridMouseState = GridMouseStateManage.ComplexTitleMovingState) then
  begin
  end else
  begin
    inherited GridTimerEvent(Sender);
  end;
end;

procedure TCustomDataGridEh.DrawMove;
var
  Pos: Integer;
  R: TRect;
  MoveSize: Integer;
  ScreenPos: TPoint;
  UseMovePosRightSite: Boolean;
  MouseState:  TDataGridMouseComplexTitleMovingStateEh;
  ParentNode: TDataGridComplexTitleTreeNodeEh;
  ChildNode: TDataGridComplexTitleTreeNodeEh;
begin
  if (GridMouseState = GridMouseStateManage.GroupDescriptionMovingState) then
  begin
    MoveSize :=  Round(GridMouseStateManage.GroupDescriptionMovingState.ToIndexLineHeight);
    ScreenPos := GridMouseStateManage.GroupDescriptionMovingState.ToIndexScreenLinePos.Round;

    if GetMoveLineEh.Visible then
      GetMoveLineEh.MoveToFor(ScreenPos)
    else
      GetMoveLineEh.StartShow(ScreenPos, True, MoveSize, Self);
  end
  else if (GridMouseState = GridMouseStateManage.ComplexTitleMovingState) then
  begin
    MouseState := GridMouseStateManage.ComplexTitleMovingState;
    ParentNode := TDataGridComplexTitleTreeNodeEh(MouseState.ParentNode);
    UseMovePosRightSite := GridMouseStateManage.ComplexTitleMovingState.MovePosRightSite;
    if MouseState.MoveToNodeIndex = ParentNode.VisibleCount then
    begin
      ChildNode := ParentNode.VisibleItem[MouseState.MoveToNodeIndex - 1];
      R := ChildNode.DisplayRect;
      UseMovePosRightSite := True;
    end else
    begin
      ChildNode := ParentNode.VisibleItem[MouseState.MoveToNodeIndex];
      R := ChildNode.DisplayRect;
    end;

    R.Offset(-HorzAxis.RollStartVisPos + HorzAxis.FixedBoundary, 0);

    if UseMovePosRightSite then
    begin
      if not UseRightToLeftAlignment then
        Pos := R.Right
      else
        Pos := R.Left
    end else
    begin
      if not UseRightToLeftAlignment then
        Pos := R.Left-1
      else
        Pos := R.Right;
    end;

    if TGridOptionEh.ExtendVertLines in inherited Options
      then MoveSize := VertAxis.RollInClientBoundary - VertAxis.GridClientStart - R.Top
      else MoveSize := VertAxis.GridClientLen - R.Top;

    ScreenPos.X := Pos;
    ScreenPos.Y := VertAxis.GridClientStart + R.Top;

    ScreenPos := LocalToScreen(ScreenPos).Round;

    if GetMoveLineEh.Visible then
      GetMoveLineEh.MoveToFor(ScreenPos)
    else
      GetMoveLineEh.StartShow(ScreenPos, True, MoveSize, Self);
  end else
  begin
    inherited DrawMove;
  end;
end;

function TCustomDataGridEh.GetSelectedRows: TDataGridSelectedRowsEh;
begin
  Result := Selection.Rows;
end;

function TCustomDataGridEh.IsRowMatchFilter(ADataRow: TDataGridRowEh): Boolean;
var
  FilterParams: TBaseDataGridFilterRowParamsEh;
begin
  if SearchPanel.FilterActive then
    Result := SearchPanel.IsRowMatchFilter(ADataRow)
  else
    Result := True;

  FilterParams := CreateDataGridFilterRowParams;
  try
    FilterParams.Init(Self, ADataRow, Result);
    HandleIsRowMatchFilter(FilterParams);
    Result := FilterParams.Accept;
  finally
    FilterParams.Free;
  end;
end;

function TCustomDataGridEh.IsTableRowMatchFilter(ATableRow: TDataGridTableRowEh): Boolean;
begin
  Result := True;
end;

function TCustomDataGridEh.CreateDataGridFilterRowParams: TBaseDataGridFilterRowParamsEh;
begin
  Result := TBaseDataGridFilterRowParamsEh.Create;
end;

procedure TCustomDataGridEh.HandleIsRowMatchFilter(Params: TBaseDataGridFilterRowParamsEh);
begin

end;

procedure TCustomDataGridEh.SafeSetTopRollPos(ATopRollPos: Integer);
begin
  inherited SafeSetTopRollPos(ATopRollPos);
end;

procedure TCustomDataGridEh.SafeSetLeftRollPos(ALeftRollPos: Integer);
begin
  inherited SafeSetLeftRollPos(ALeftRollPos);
end;

function TCustomDataGridEh.InternalGetCellManagerAt(VirtPanel: TLaHostVirtualPanelEh;
  AColIndex, ARowIndex: Integer): TVPBaseCellManagerEh;
var
  ALocalColIndex, ALocalRowIndex: Integer;

  function GetCellDataManagerAt(VirtPanel: TLaHostVirtualPanelEh; ADataColIndex, ADataAreaRowIndex: Integer): TVPBaseCellManagerEh;
  var
    Column: TDataGridBaseColumnEh;
    Row: TDataGridRowEh;
    DataRow: TDataGridDataRowEh;
    RowSplitWay: TDataGridRowSplitWayEh;
    CellAreaContainerManager: TRowBandContainerManagerEh;
  begin
    if ADataColIndex < VisibleColumns.Count
      then Column := VisibleColumns[ADataColIndex]
      else Column := nil;

    if ADataAreaRowIndex < VisibleRows.Count
      then Row := VisibleRows[ADataAreaRowIndex]
      else Row := nil;

    Result := nil;

    if Row is TDataGridDataRowEh then
    begin
      DataRow := TDataGridDataRowEh(Row);

      if DataRow <> nil
        then RowSplitWay := GetDataRowSplitWay(DataRow)
        else RowSplitWay := TDataGridRowSplitWayEh.SplitByCell;

      if RowSplitWay = TDataGridRowSplitWayEh.NoSplit then
      begin
        if ADataColIndex = HDataVDataPanel.StartVisColIndex then
        begin
          CellAreaContainerManager := TDataGridDataVirtualPanelEh(HDataVDataPanel).GetContainerManager();
          CellAreaContainerManager.ContentCellManager := GetDataRowManagerForRow(Row);
          Result := CellAreaContainerManager;
        end;
      end else
      begin
        if Column <> nil
          then Result := Column.GetCellManagerAt(ADataAreaRowIndex)
          else Result := inherited InternalGetCellManagerAt(VirtPanel, ADataColIndex, ADataAreaRowIndex);
      end;
    end
    else if Row is TDataGridGroupHeaderRowEh then
    begin
      if ADataColIndex = HDataVDataPanel.StartVisColIndex then
      begin
        CellAreaContainerManager := TDataGridDataVirtualPanelEh(HDataVDataPanel).GetContainerManager();
        CellAreaContainerManager.ContentCellManager :=
          DataGrouping.GetGroupHeaderRowManagerForRow(TDataGridGroupHeaderRowEh(Row));
        Result := CellAreaContainerManager;
      end;
    end
    else if Row is TDataGridGroupFooterRowEh then
    begin
      ALocalColIndex := AColIndex - VirtPanel.InGridStartCol;
      ALocalRowIndex := ARowIndex - VirtPanel.InGridStartRow;
      Result := Footer.GetCellManagerAt(ALocalColIndex, ALocalRowIndex);
    end else
    begin
      if Column <> nil
        then Result := Column.GetCellManagerAt(ADataAreaRowIndex)
        else Result := inherited InternalGetCellManagerAt(VirtPanel, AColIndex, ARowIndex);
    end;
  end;

begin
  if VirtPanel = HFixedVDataPanel then 
  begin
    if AColIndex < StartDataColIndex then
    begin
      ALocalColIndex := AColIndex - VirtPanel.InGridStartCol;
      ALocalRowIndex := ARowIndex - VirtPanel.InGridStartRow;
      Result := IndicatorColumn.GetCellManagerAt(ALocalColIndex, ALocalRowIndex);
    end else
    begin
      ALocalColIndex := AColIndex - VirtPanel.InGridStartCol - StartDataColIndex;
      ALocalRowIndex := ARowIndex - VirtPanel.InGridStartRow;
      Result := GetCellDataManagerAt(VirtPanel, ALocalColIndex, ALocalRowIndex);
    end;
  end
  else if VirtPanel = HFixedVFixedPanel then 
  begin
    if AColIndex < StartDataColIndex then
    begin
      ALocalColIndex := AColIndex - VirtPanel.InGridStartCol;
      ALocalRowIndex := ARowIndex - VirtPanel.InGridStartRow;
      Result := IndicatorTitle.GetCellManagerAt(ALocalColIndex, ALocalRowIndex)
    end else
    begin
      ALocalColIndex := AColIndex - VirtPanel.InGridStartCol - StartDataColIndex;
      ALocalRowIndex := ARowIndex - VirtPanel.InGridStartRow;
      Result := Title.GetCellManagerAt(ALocalColIndex, ALocalRowIndex);
    end;
  end
  else if VirtPanel = HDataVFooterPanel then 
  begin
    ALocalColIndex := AColIndex - VirtPanel.InGridStartCol;
    ALocalRowIndex := ARowIndex - VirtPanel.InGridStartRow;
    Result := Footer.GetCellManagerAt(ALocalColIndex, ALocalRowIndex);
  end
  else if VirtPanel = HDataVFixedPanel then 
  begin
    ALocalColIndex := AColIndex - VirtPanel.InGridStartCol;
    ALocalRowIndex := ARowIndex - VirtPanel.InGridStartRow;
    Result := Title.GetCellManagerAt(ALocalColIndex, ALocalRowIndex);
  end
  else if VirtPanel = HDataVDataPanel then 
  begin
    if (GridView.Active = True) then
    begin
      ALocalColIndex := AColIndex - VirtPanel.InGridStartCol;
      ALocalRowIndex := ARowIndex - VirtPanel.InGridStartRow;
      Result := GetCellDataManagerAt(VirtPanel, ALocalColIndex, ALocalRowIndex);
    end else
    begin
      Result := inherited InternalGetCellManagerAt(VirtPanel, AColIndex, ARowIndex);
    end;
  end
  else if VirtPanel = HContraVDataPanel then 
  begin
    if (GridView.Active = True) then
    begin
      ALocalColIndex := AColIndex - StartDataColIndex;
      ALocalRowIndex := ARowIndex - VirtPanel.InGridStartRow;
      Result := GetCellDataManagerAt(VirtPanel, ALocalColIndex, ALocalRowIndex);
    end else
    begin
      Result := inherited InternalGetCellManagerAt(VirtPanel, AColIndex, ARowIndex);
    end;
  end
  else if VirtPanel = HFixedVFooterPanel then 
  begin
    if AColIndex < StartDataColIndex then
    begin
      Result := inherited InternalGetCellManagerAt(VirtPanel, AColIndex, ARowIndex);
    end else
    begin
      ALocalColIndex := AColIndex - VirtPanel.InGridStartCol - StartDataColIndex;
      ALocalRowIndex := ARowIndex - VirtPanel.InGridStartRow;
      Result := Footer.GetCellManagerAt(ALocalColIndex, ALocalRowIndex);
    end;
  end
  else if VirtPanel = HContraVFixedPanel then 
  begin
    ALocalColIndex := AColIndex - StartDataColIndex;
    ALocalRowIndex := ARowIndex - VirtPanel.InGridStartRow;
    Result := Title.GetCellManagerAt(ALocalColIndex, ALocalRowIndex);
  end
  else if VirtPanel = HContraVFooterPanel then 
  begin
    ALocalColIndex := AColIndex - StartDataColIndex;
    ALocalRowIndex := ARowIndex - VirtPanel.InGridStartRow;
    Result := Footer.GetCellManagerAt(ALocalColIndex, ALocalRowIndex);
  end else
  begin
    Result := inherited InternalGetCellManagerAt(VirtPanel, AColIndex, ARowIndex);
  end;
end;

procedure TCustomDataGridEh.HandleGetDataCellManager(Params: TBaseDataGridGetDataCellManagerParamsEh);
begin
end;

function TCustomDataGridEh.CreateGridLineOptions: TGridLineOptionsEh;
begin
  Result := TDataGridLineOptionsEh.Create(Self);
end;

procedure TCustomDataGridEh.SetGridLineOptions(const Value: TDataGridLineOptionsEh);
begin
  inherited GridLineOptions := Value;
end;

function TCustomDataGridEh.GetGridLineOptions: TDataGridLineOptionsEh;
begin
  Result := TDataGridLineOptionsEh(inherited GridLineOptions);
end;

function TCustomDataGridEh.LocateRow(const ALocateProc: TDataGridLocateFunction): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to VisibleRows.Count - 1 do
  begin
    if ALocateProc(VisibleRows[I]) = True then
    begin
      CurrentRow := VisibleRows[I];
      Result := True;
      Break;
    end;
  end;
end;

function TCustomDataGridEh.FindRow(const ALocateProc: TDataGridLocateFunction): TDataGridRowEh;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to VisibleRows.Count - 1 do
  begin
    if ALocateProc(VisibleRows[I]) = True then
    begin
      Result := VisibleRows[I];
      Break;
    end;
  end;
end;

procedure TCustomDataGridEh.ReloadData;
begin
  TableView.UpdateFilteredList;
end;

function TCustomDataGridEh.GetDynaFieldBarClassByField(AField: TTableFieldLinkEh): TFieldBarEhClass;
begin
  if (AField.DataTypeInfo = TypeInfo(Boolean)) or
     ((AField.DataTypeInfo = TypeInfo(Variant)) and (AField.DataVarSubtype = varBoolean)) then
    Result := TDataGridCheckboxColumnEh
  else if (AField.DataTypeInfo = TypeInfo(TInterfacedImageStreamEh)) then
    Result := TDataGridGraphicColumnEh
  else
    Result := TDataGridStringColumnEh;
end;

procedure TCustomDataGridEh.GetFieldBarListItemBarAtPos(AGridColIndex, AGridRowIndex: Integer;
  out AFieldBar: TFieldBarEh; out AListItemBar: TTableRowViewEh);
var
  ADataColIndex, ADataAreaRowIndex: Integer;
  AGridRow: TDataGridRowEh;
begin
  ADataColIndex := AGridColIndex - StartDataColIndex;
  ADataAreaRowIndex := AGridRowIndex - StartDataRowIndex;

  if (ADataColIndex >= 0) and (ADataColIndex < VisibleColumns.Count)
    then AFieldBar := VisibleColumns[ADataColIndex]
    else AFieldBar := nil;

  if (ADataAreaRowIndex >= 0) and (ADataAreaRowIndex < VisibleRows.Count) then
  begin
    AGridRow := VisibleRows[ADataAreaRowIndex];
    if AGridRow is TDataGridDataRowEh
      then AListItemBar := TDataGridDataRowEh(AGridRow).TableRow
      else AListItemBar := nil;
  end else
  begin
    AListItemBar := nil;
  end;
end;

procedure TCustomDataGridEh.DisplayFieldBarListChanged;
var
  I: Integer;
begin
  inherited DisplayFieldBarListChanged;

  FFrozenLeftColCount := 0;
  FFrozenRightColCount := 0;

  for I := 0 to DisplayColumns.Count - 1 do
  begin
    if DisplayColumns[I].Visible then
    begin
      if DisplayColumns[I].FrozenPosition = TColumnFrozenPositionEh.Left then
        FFrozenLeftColCount := FFrozenLeftColCount + 1;
      if DisplayColumns[I].FrozenPosition = TColumnFrozenPositionEh.Right then
        FFrozenRightColCount := FFrozenRightColCount + 1;
    end;
  end;
end;

function TCustomDataGridEh.IsShowFocusLayerForCell(ACell: TGridBaseCellEh): Boolean;
begin
  if (ACell is TDataGridDataRowBandEh) and
     (TDataGridDataRowBandEh(ACell).Row = CurrentRow) then
  begin
    Result := True;
  end else if (ACell is TDataGridGroupHeaderBandEh) and
     (TDataGridGroupHeaderBandEh(ACell).Row = CurrentRow) then
  begin
    Result := True;
  end else
  begin
    Result := inherited IsShowFocusLayerForCell(ACell);
  end;
end;

procedure TCustomDataGridEh.SetDataGrouping(const Value: TDataGridDataGroupingEh);
begin
  FDataGrouping.Assign(Value);
end;

function TCustomDataGridEh.CanTableOperation(AOperation: TDataGridAllowedOperationEh): Boolean;
begin
  if DataGrouping.Active and
    ((AOperation = TDataGridAllowedOperationEh.Insert) or
     (AOperation = TDataGridAllowedOperationEh.Append))
  then
    Result := False
  else
    Result := (GridView.CanModify = True) and
              (not ReadOnly) and
              (AOperation in AllowedOperations);
end;

procedure TCustomDataGridEh.GridLinesVisibilityChanged;
begin
  inherited GridLinesVisibilityChanged;
  RecalcRowHeightsNeeded();
  LayoutChanged(True);
end;

procedure TCustomDataGridEh.FontChanged();
begin
  inherited FontChanged();
  DataGrouping.RefreshDefaultFont();
end;

procedure TCustomDataGridEh.RecreateContentControls;
begin
  inherited RecreateContentControls;
  RecreateGroupingPanelControl;
end;

procedure TCustomDataGridEh.RecreateGroupingPanelControl;
begin
  if FGroupingPanel <> nil then
    FGroupingPanel.Free;
  FGroupingPanel := CreateGroupingPanelControl;
  FGroupingPanel.Parent := Client;
  FGroupingPanel.Name := 'FGroupingPanel';
  FGroupingPanel.Visible := False;
  FGroupingPanel.SetBounds(0,0,0,0);
  FGroupingPanel.RealignControls;
  AddFreeNotify(FGroupingPanel);
end;

function TCustomDataGridEh.CreateGroupingPanelControl: TDataGridGroupingPanelEh;
begin
  Result := TDataGridGroupingPanelEh.Create(Self, FDataGrouping);
end;

procedure TCustomDataGridEh.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
  begin
    if AComponent = FGroupingPanel then
    begin
      RemoveFreeNotify(FGroupingPanel);
      FGroupingPanel := nil;
    end;
  end;
end;

{$ENDREGION 'TCustomDataGridEh'}

{$REGION 'TDataGridEhStylePainter'}

{ TDataGridEhStylePainter }

const
  
  StrFocus = 'focus';
  StrFocusInactive = 'focusInactive';
  StrSelection = 'selection';
  StrSortMarker = 'SortMarker';
//  StrFilterDropDownButton = 'FilterDropDownButton';
//  StrFilterDropDownButtonSign = 'FilterDropDownButtonSign';

  StrDownTriangleRes = 'ehlib_fmx_down_triangle';
  StrLeftTriangleRes = 'ehlib_fmx_left_triangle';
  StrRightTriangleRes = 'ehlib_fmx_right_triangle';

  StrGridCurrentRow = 'ehlib_fmx_grid_current_row';
  StrGridEditRow = 'ehlib_fmx_grid_edit_row';
  StrGridNewRow = 'ehlib_fmx_grid_new_row';

constructor TDataGridStylePainterEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FTitleFill := TBrush.Create(TBrushKind.None, TAlphaColorRec.Null);
  FIndicatorFill := TBrush.Create(TBrushKind.None, TAlphaColorRec.Null);
end;

destructor TDataGridStylePainterEh.Destroy;
begin
  FreeAndNil(FTitleFill);
  FreeAndNil(FIndicatorFill);
  inherited Destroy;
end;

procedure TDataGridStylePainterEh.LoadStyleItems;
var
  InStyleSortMarker: TControl;
begin
  inherited LoadStyleItems;

  FDownTriangle := DataGridCenterEh.BitmapResource['ehlib_fmx_down_triangle'];
  FLeftTriangle := DataGridCenterEh.BitmapResource['ehlib_fmx_left_triangle'];
  FRightTriangle := DataGridCenterEh.BitmapResource['ehlib_fmx_right_triangle'];

  FGridCurrentRow := DataGridCenterEh.BitmapResource['ehlib_fmx_grid_current_row'];
  FGridEditRow := DataGridCenterEh.BitmapResource['ehlib_fmx_grid_edit_row'];
  FGridNewRow := DataGridCenterEh.BitmapResource['ehlib_fmx_grid_new_row'];

  InStyleSortMarker := LookupGlobalStyleElement('EhLib.SortMarker') as TControl;
  if InStyleSortMarker <> nil then
    FSortMarker := InStyleSortMarker.Clone(Self) as TControl
  else
    FSortMarker := nil;

  FReady := True;
end;

procedure TDataGridStylePainterEh.FreeStyleItems;
begin
  inherited FreeStyleItems;
  FreeAndNil(FSortMarker);

  FReady := False;
end;


function TDataGridStylePainterEh.GetSortMarkerAreaSize(Canvas: TCanvas;
  SortOrder: TSortOrderEh; SortIndex: Integer): TSize;
begin
  Result := TSize.Create(0, 0);
  if (FReady = False) or (FSortMarker = nil) then Exit;

  Result := FSortMarker.Size.Size.Round;
  Result.cx := Result.cx + 10;
end;

function TDataGridStylePainterEh.GetFilterDropDownButtonDefaultSize(Canvas: TCanvas): TSize;
begin
  Result := TSize.Create(15, 18);
end;

function TDataGridStylePainterEh.GetSortMarker: TControl;
begin
  Result := FSortMarker;
end;

function TDataGridStylePainterEh.GetDownTriangle: TControl;
begin
  Result := FDownTriangle;
end;

function TDataGridStylePainterEh.GetGridCurrentRow: TControl;
begin
  Result := FGridCurrentRow;
end;

function TDataGridStylePainterEh.GetGridEditRow: TControl;
begin
  Result := FGridEditRow;
end;

function TDataGridStylePainterEh.GetGridNewRow: TControl;
begin
  Result := FGridNewRow;
end;

function TDataGridStylePainterEh.GetLeftTriangle: TControl;
begin
  Result := FLeftTriangle;
end;

function TDataGridStylePainterEh.GetRightTriangle: TControl;
begin
  Result := FRightTriangle;
end;

procedure TDataGridStylePainterEh.SetIndicatorFill(const Value: TBrush);
begin
  FIndicatorFill.Assign(Value);
end;

procedure TDataGridStylePainterEh.SetTitleFill(const Value: TBrush);
begin
  FTitleFill.Assign(Value);
end;

{$ENDREGION 'TDataGridEhStylePainter'}

{$REGION 'TBaseDataGridFilterRowParamsEh'}

{ TBaseDataGridFilterRowParamsEh }

procedure TBaseDataGridFilterRowParamsEh.Init(AGrid: TControl; ARow: TDataGridRowEh; AAccept: Boolean);
begin
  FGrid := AGrid;
  FRow := ARow;
  FAccept := AAccept;
end;

{$ENDREGION 'TBaseDataGridFilterRowParamsEh'}

{$REGION 'TBaseDataGridDataCellStyleParamsEh'}

{ TBaseDataGridDataCellStyleParamsEh }

function TBaseDataGridDataCellStyleParamsEh.GetGrid: TCustomDataGridEh;
begin
  Result := TCustomDataGridEh(inherited Grid);
end;

function TBaseDataGridDataCellStyleParamsEh.GetColumn: TDataGridBaseColumnEh;
begin
  Result := TDataGridBaseColumnEh(DataAxisCellParams.FieldBar);
end;

function TBaseDataGridDataCellStyleParamsEh.GetRow: TDataGridRowEh;
begin
  if DataAxisCellParams.ListItemBar = nil
    then Result := nil
    else Result := TDataGridTableRowEh(DataAxisCellParams.ListItemBar).GridDataRow;
end;

{$ENDREGION 'TBaseDataGridDataCellStyleParamsEh'}

initialization
  InitModule;
finalization
  FinalizeModule;
end.

