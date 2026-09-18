{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{            EhLibFmx.DataGrid.ToolControls             }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataGrid.ToolControls;

interface

{$SCOPEDENUMS ON}

uses System.SysUtils, System.Classes, System.Types, FMX.Controls, FMX.Graphics,
  FMX.Controls.Presentation, FMX.StdCtrls, System.UITypes, FMX.Forms, System.Contnrs,
  FMX.Layouts, FMX.Objects, FMX.Types, FMX.Platform, Data.DB,
  System.TypInfo, System.Variants, Data.FmtBcd,
  DBSumLst, EhLibUtils, DBUtilsEh,
  System.Generics.Collections, System.Generics.Defaults, System.Rtti,
  EhLib.TableLinks,
  EhLib.GridTableViews,
  FMX.DialogService,
  MemTreeEh,
  EhLibFmx.ImageReses,

  EhLibFmx.Utils,
  EhLibFmx.Grid.CellManagers,
  EhLibFmx.Grid.ToolControls,
  EhLibFmx.Grids,
  EhLibFmx.Grid.Types,

  EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.DataAxisGrid.ToolControls,
  EhLibFmx.DataAxisGrids,

  EhLibFmx.DataGrid.Rows,
//  EhLibFmx.DataGrid.DataGrouping,

  EhLibFmx.Platform,
  EhLibFmx.ToolControls,
  EhLibFmx.LaHostVirtualPanels,
  EhLibFmx.Types;

type
  TDataGridNavigatorPanelEh = class;
  TDataGridSelectionEh = class;
  TDataGridColumnOptionsEh = class;
  TDataGridSelectionInfoPanelEh = class;

  THorzCellAreaTypeEh = (Indicator, Data);
  TVertCellAreaTypeEh = (Title, SubTitle, Data, AboveFooter, Footer);

  TDataGridRowSplitWayEh = (SplitByCell, NoSplit);

  TCellAreaTypeEh = record
    HorzType: THorzCellAreaTypeEh;
    VertType: TVertCellAreaTypeEh;
  end;

  TDataGridSelectionTypeEh = (RecordBookmarks, Rectangle, Columns, All, Non);
  TDataGridAllowedSelectionEh = TDataGridSelectionTypeEh.RecordBookmarks..TDataGridSelectionTypeEh.All;
  TDataGridAllowedSelectionsEh = set of TDataGridAllowedSelectionEh;

  TDataCellSelectionTimeEh = (OnMouseMove, OnMouseDown);

  TGridSBItemEh = (RecordsInfo, Navigator, {gsbFindEditorEh, }SelAggregationInfo);
  TGridSBItemsEh = set of TGridSBItemEh;

  TNavigateBtnEh = (First, Prior, Next, Last,
                  Insert, Delete, Edit, Post, Cancel, Refresh);
  TNavButtonSetEh = set of TNavigateBtnEh;

  TNavClickEh = procedure (Sender: TObject; Button: TNavigateBtnEh) of object;

  TSelectionInfoPanelDataItemEh = record
    Text: String;
    Start: Integer;
    Finish: Integer;
  end;

  TDataGridLineOptionsEh = class(TGridLineOptionsEh)
  published
    property BrightColor;
    property BrightColorStored;
    property DarkColor;
    property DarkColorStored;

    property HorzLinesVisible;
    property VertLinesVisible;
  end;

{ TDataGridVirtualPanelEh }

  TDataGridVirtualPanelEh = class(TGridLaHostVirtualPanelEh)
  protected
  end;

{ TDataGridSelectionColsEh }

  TDataGridSelectionColsEh = class(TFieldBarsListEh)
  private
    FAnchorCol: TFieldBarEh;
    FGrid: TControl;
    FShiftCol: TFieldBarEh;
    FShiftSelectedCols: TFieldBarsListEh;
    procedure Add(AFieldBar: TFieldBarEh);
    function Remove(const Value: TFieldBarEh): Integer;
  public
    constructor Create(AGrid: TControl);
    destructor Destroy; override;

    function SelectionToGridRect: TGridRect;

    procedure Clear; reintroduce;
    procedure InvertSelect(AFieldBar: TFieldBarEh);
    procedure Refresh;
    procedure Select(AFieldBar: TFieldBarEh; AddSel: Boolean);
    procedure  SelectShift(AFieldBar: TFieldBarEh {; Clear:Boolean});
  end;

{ TDataGridSelectedRowsEh }

  TDataGridSelectedRowsEh = class(TPersistent)
  private
    FList: TList<TDataGridRowEh>;
    FGridSelection: TDataGridSelectionEh;
    function GetItem(Index: Integer): TDataGridRowEh;
    function GetCount: Integer;
  protected
    FIsObsolete: Boolean;
    procedure UpdateList;
  public
    constructor Create(AGridSelection: TDataGridSelectionEh);
    destructor Destroy; override;

    property Item[Index: Integer]: TDataGridRowEh read GetItem; default;
    property Count: Integer read GetCount;
  end;

{ TDataGridSelectionEh }

  TDataGridSelectionEh = class(TPersistent)
  private
    FColumns: TDataGridSelectionColsEh;
    FGrid: TControl;
    FSelectionType: TDataGridSelectionTypeEh;
    FRowSelect: Boolean;
    FKeepSelection: Boolean;
    FRows: TDataGridSelectedRowsEh;

    FFreeEndDataRowIndex: Integer;
    FAnchorDataRowIndex: Integer;
    FSelectedStateIsSelected: Boolean;
    FAnchorCell: TGridCoord;
    FFreeEndCell: TGridCoord;

    procedure SetSelectionType(ASelType: TDataGridSelectionTypeEh);
    function GetSelectedRowCount: Integer;
  protected
    FUpdateCount: Integer;
    FSelectionChanged: Boolean;
    procedure SelectionChanged; virtual;
  public
    constructor Create(AGrid: TControl);
    destructor Destroy; override;

    function DataCellSelected(DataColIdx: Integer; DataRow: Integer): Boolean;
    function Updating: Boolean;
    function CellsRectContains(AreaColIndex, AreaRowIndex: Integer): Boolean;
    function IsRowInSelection(ARow: TDataGridRowEh): Boolean;
    function GetSelectedRect: TRect;

    procedure BeginUpdate;
    procedure EndUpdate(AForceChangeSelection: Boolean);

    procedure SetFreeEndRow(NewFreeEndRow: Integer);
    procedure SetSelectedRow(ARow: TDataGridRowEh; SetToSelected: Boolean);
    procedure InitAnchorRow(AAnchorDataRowIndex: Integer; ASelectedStateIsSelected: Boolean);
    procedure CheckClear();
    procedure GetSelectedRows(ARows: TList<TDataGridRowEh>);

    procedure StartCellsRectSelection(AAnchorCell: TGridCoord; AFreeEndCell: TGridCoord);
    procedure SetFreeEndCell(NewFreeEndCell: TGridCoord);
    procedure CheckFixCellCoord(var CellCoord: TGridCoord);

    procedure Clear;
    procedure Refresh;
    procedure SelectAll;
    procedure SelectAllRows;
    procedure UpdateState;
    procedure Assign(Source: TPersistent); overload; override;
    procedure Assign(Selection: TDataGridSelectionEh); reintroduce; overload;
    procedure AssignAsBaseRef(Selection: TDataGridSelectionEh);
    procedure TableViewDataChanged(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowView: TTableRowViewEh);

    property Columns: TDataGridSelectionColsEh read FColumns;
    property Rows: TDataGridSelectedRowsEh read FRows;
    property SelectionType: TDataGridSelectionTypeEh read FSelectionType;
    property SelectedRowCount: Integer read GetSelectedRowCount;

    property FreeEndDataRowIndex: Integer read FFreeEndDataRowIndex;
    property AnchorDataRowIndex: Integer read FAnchorDataRowIndex;
    property AnchorCell: TGridCoord read FAnchorCell;
    property FreeEndCell: TGridCoord read FFreeEndCell;
  end;

  TMoveAndScrollServiceEventEh = procedure(Sender: TObject; MouseParams: TControlMouseParamsEh) of object;

{ TDataGridMoveAndScrollServiceEh }

  TDataGridMoveAndScrollServiceEh = class(TPersistent)
  private
    FGrid: TStyledControlEh;
    FClientRect: TRectF;
    FActive: Boolean;
    FScreenForClientRect: TRectF;

    FtoLeftScreenBound: Single;
    FtoRightScreenBound: Single;
    FtoTopScreenBound: Single;
    FtoBottomScreenBound: Single;
    FHorzOutMove: Boolean;
    FVertOutMove: Boolean;

    lastMouseEvArg: TControlMouseParamsEh;
    FTimer: TTimer;
    ticks: UInt64;
    FMoveAndScrollEvent: TMoveAndScrollServiceEventEh;
    procedure Timer_Elapsed(Sender: TObject);
    procedure MoveAndScrollServiceEvent(MouseParams: TControlMouseParamsEh);
    function GetClientRect: TRect;
  public
    constructor Create(AGrid: TStyledControlEh);
    destructor Destroy; override;

    procedure Capture(clientRect: TRectF; AMoveAndScrollEvent: TMoveAndScrollServiceEventEh; horzOutMove, vertOutMove: Boolean);
    procedure Release;
    procedure MouseMove(MouseParams: TControlMouseParamsEh);

    property Active: Boolean read FActive;
    property ClientRect: TRect read GetClientRect;
  end;

{ TDataGridSelectionOptionsEh }

  TDataGridSelectionOptionsEh = class(TPersistent)
  private
    FGrid: TControl;
    FAllowedSelections: TDataGridAllowedSelectionsEh;
    FRowSelect: Boolean;
    FKeepSelection: Boolean;
    FDataCellSelectionTime: TDataCellSelectionTimeEh;
    FRowHighlight: Boolean;
    FAlwaysShow: Boolean;
    procedure SetAllowedSelections(const Value: TDataGridAllowedSelectionsEh);
    procedure SetRowSelect(const Value: Boolean);
    procedure SetRowHighlight(const Value: Boolean);
    procedure SetAlwaysShow(const Value: Boolean);
  public
    constructor Create(AGrid: TControl);
    destructor Destroy; override;

  published
    property AllowedSelections: TDataGridAllowedSelectionsEh read FAllowedSelections write SetAllowedSelections default [TDataGridSelectionTypeEh.RecordBookmarks..TDataGridSelectionTypeEh.All];
    property RowSelect: Boolean read FRowSelect write SetRowSelect default False;
    property KeepSelection: Boolean read FKeepSelection write FKeepSelection default False;
    property DataCellSelectionTime: TDataCellSelectionTimeEh read FDataCellSelectionTime write FDataCellSelectionTime default TDataCellSelectionTimeEh.OnMouseMove;
    property RowHighlight: Boolean read FRowHighlight write SetRowHighlight default True;
    property AlwaysShow: Boolean read FAlwaysShow write SetAlwaysShow default True;
  end;
  
{ TGridEditActionsEh }

  TGridEditActionsEh = class(TPersistent)
  private
    FGrid: TControl;
    FCopyEnabled: Boolean;
    FCutEnabled: Boolean;
    FPasteEnabled: Boolean;
    FConfirmDelete: Boolean;
    FSelectAllEnabled: Boolean;
    FDeleteEnabled: Boolean;
    FUseTabs: Boolean;
    FEnterAsTab: Boolean;
    procedure SetUseTabs(const Value: Boolean);
  public
    function CanCopy(): Boolean;
    function CanPaste(): Boolean;
    function CanCut(): Boolean;
    function ShowConfirmDeleteDialog(): Boolean;
    function CanSelectAll(): Boolean;
    function CanDelete(): Boolean;
    function CanFillFromFirstRow(): Boolean;
    function ShowCustomizeColumnsDialog: Boolean;

    procedure Copy();
    procedure Paste();
    procedure Cut();
    procedure Delete();
    procedure SelectAll();
    procedure FillFromFirstRow();

    constructor Create(AGrid: TControl);
    destructor Destroy; override;
  published
    property ConfirmDelete: Boolean read FConfirmDelete write FConfirmDelete default True;
    property CopyEnabled: Boolean read FCopyEnabled write FCopyEnabled default True;
    property CutEnabled: Boolean read FCutEnabled write FCutEnabled default True;
    property DeleteEnabled: Boolean read FDeleteEnabled write FDeleteEnabled default True;
    property EnterAsTab: Boolean read FEnterAsTab write FEnterAsTab default False;
    property PasteEnabled: Boolean read FPasteEnabled write FPasteEnabled default True;
    property SelectAllEnabled: Boolean read FSelectAllEnabled write FSelectAllEnabled default True;
    property UseTabs: Boolean read FUseTabs write SetUseTabs default True;
  end;

{ TDynaColumnOptionsEh }

  TDynaColumnOptionsEh = class(TPersistent)
  private
    FColumnOptions: TDataGridColumnOptionsEh;
    FMaxInitWidth: Integer;
    FMinInitWidth: Integer;
    FUseDataRowsToInitWidth: Boolean;
    FUseTitleToInitWidth: Boolean;
  public
    constructor Create(AColumnOptions: TDataGridColumnOptionsEh);
    destructor Destroy; override;
  published
    property MinInitWidth: Integer read FMinInitWidth write FMinInitWidth default 40;
    property MaxInitWidth: Integer read FMaxInitWidth write FMaxInitWidth default 400;
    property UseTitleToInitWidth: Boolean read FUseTitleToInitWidth write FUseTitleToInitWidth default True;
    property UseDataRowsToInitWidth: Boolean read FUseDataRowsToInitWidth write FUseDataRowsToInitWidth default True;
  end;

{ TDataGridColumnOptionsEh }

  TDataGridColumnOptionsEh = class(TFieldBarOptionsEh)
  private
    FColSizeUnit: TGridColSizeUnitEh;
    FDynaColumnOptions: TDynaColumnOptionsEh;
    FAllowMove: Boolean;
    FAllowResize: Boolean;
    FAllowFreezeLeft: Boolean;
    FAllowFreezeRight: Boolean;
    procedure SetColSizeUnit(const Value: TGridColSizeUnitEh);
    procedure SetDynaColumnOptions(const Value: TDynaColumnOptionsEh);
    procedure SetAllowResize(const Value: Boolean);
  protected
    procedure HeightAutoExpandChanged; override;

  public
    constructor Create(AGrid: TControl);
    destructor Destroy; override;

  published

    property DynaColumnOptions: TDynaColumnOptionsEh read FDynaColumnOptions write SetDynaColumnOptions;
    property ColSizeUnit: TGridColSizeUnitEh read FColSizeUnit write SetColSizeUnit default TGridColSizeUnitEh.Pixels;
    property AllowResize: Boolean read FAllowResize write SetAllowResize default True;
    property AllowMove: Boolean read FAllowMove write FAllowMove default True;
    property AllowFreezeLeft: Boolean read FAllowFreezeLeft write FAllowFreezeLeft default False;
    property AllowFreezeRight: Boolean read FAllowFreezeRight write FAllowFreezeRight default False;

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

{ TDataGridScrollBarPanelEh }

  TDataGridScrollBarPanelEh = class(TPersistent)
  private
    FScrollBar: TGridScrollBarEh;
    FVisible: Boolean;
    FNavigatorButtons: TNavButtonSetEh;
    FVisibleItems: TGridSBItemsEh;

    function GetNavigatorButtons: TNavButtonSetEh;
    function GetVisible: Boolean;
    function GetVisibleItems: TGridSBItemsEh;

    procedure SetNavigatorButtons(const Value: TNavButtonSetEh);
    procedure SetVisible(const Value: Boolean);
    procedure SetVisibleItems(const Value: TGridSBItemsEh);

  public
    constructor Create(ScrollBar: TGridScrollBarEh);
    function Grid: TCustomGridEh;

  published
    property NavigatorButtons: TNavButtonSetEh read GetNavigatorButtons write SetNavigatorButtons default [TNavigateBtnEh.First, TNavigateBtnEh.Prior, TNavigateBtnEh.Next, TNavigateBtnEh.Last, TNavigateBtnEh.Insert, TNavigateBtnEh.Delete, TNavigateBtnEh.Edit, TNavigateBtnEh.Post, TNavigateBtnEh.Cancel, TNavigateBtnEh.Refresh];
    property Visible: Boolean read GetVisible write SetVisible default False;
    property VisibleItems: TGridSBItemsEh read GetVisibleItems write SetVisibleItems default [TGridSBItemEh.RecordsInfo, TGridSBItemEh.Navigator, TGridSBItemEh.SelAggregationInfo];
  end;

{ TDataGridHorzScrollBarEh }

  TDataGridHorzScrollBarEh = class(TGridScrollBarEh)
  private
    FExtraPanel: TDataGridScrollBarPanelEh;

    function GetHeight: Integer;
    procedure SetExtraPanel(const Value: TDataGridScrollBarPanelEh);
    procedure SetHeight(const Value: Integer);
  protected
    procedure SmoothStepChanged; override;
    function CheckScrollBarMustBeShown: Boolean;  override;

  public
    constructor Create(AGrid: TCustomGridEh; AKind: TOrientation);
    destructor Destroy; override;

    function ActualScrollBarBoxSize: Integer; override;
    function IsKeepMaxSizeInDefault: Boolean; override;
    function ScrollBarPanel: Boolean; override;

  published
    property ExtraPanel: TDataGridScrollBarPanelEh read FExtraPanel write SetExtraPanel;
    property Height: Integer read GetHeight write SetHeight default 0;
    property SmoothStep default True;
    property Visible stored False;
    property VisibleMode;
  end;

{ TDataGridVertScrollBarEh }

  TDataGridVertScrollBarEh = class(TGridScrollBarEh)
  private
    function GetWidth: Integer;
    procedure SetWidth(const Value: Integer);
  protected
    FVertScrollBarVisibleMode: TScrollBarVisibleModeEh;
    FSysScrollBar: Boolean;
    procedure SmoothStepChanged; override;
    procedure SetParams(APosition, AMin, AMax, APageSize: Integer);
  public
    constructor Create(AGrid: TCustomGridEh; AKind: TOrientation);

  published
    property SmoothStep;
    property Visible stored False;
    property VisibleMode;
    property Width: Integer read GetWidth write SetWidth default 0;
  end;

{ TNavButtonEh }

  TNavButtonEh = class(TCustomSpeedButtonEh)
  private
    FIndex: TNavigateBtnEh;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
  public
    constructor Create(AOwner: TComponent); reintroduce;
    destructor Destroy; override;

    property Index: TNavigateBtnEh read FIndex write FIndex;
  end;

{ TDataGridNavigatorPanelEh }

  TDataGridNavigatorPanelEh = class(TStyledControlEh)
  private
    ButtonWidth: Integer;
    FBeforeAction: TNavClickEh;
    FBorderColor: TAlphaColor;
    FDefHints: TStrings;
    FHints: TStrings;
    FocusedButton: TNavigateBtnEh;
    FOnNavClick: TNavClickEh;
    FSearchPanelControl: TControl;
    FVisibleButtons: TNavButtonSetEh;
    FVisibleItems: TGridSBItemsEh;
    MinBtnSize: TPoint;

    function GetCancelImageItem: TResourceImageItemEh;
    function GetDeleteImageItem: TResourceImageItemEh;
    function GetEditImageItem: TResourceImageItemEh;
    function GetFirstImageItem: TResourceImageItemEh;
    function GetHints: TStrings;
    function GetInsertImageItem: TResourceImageItemEh;
    function GetLastImageItem: TResourceImageItemEh;
    function GetNextImageItem: TResourceImageItemEh;
    function GetPostImageItem: TResourceImageItemEh;
    function GetPriorImageItem: TResourceImageItemEh;
    function GetRefreshImageItem: TResourceImageItemEh;
    function GetTableView: TDataGridTableRowsViewEh;

    procedure SetCancelImageItem(const Value: TResourceImageItemEh);
    procedure SetDeleteImageItem(const Value: TResourceImageItemEh);
    procedure SetEditImageItem(const Value: TResourceImageItemEh);
    procedure SetFirstImageItem(const Value: TResourceImageItemEh);
    procedure SetInsertImageItem(const Value: TResourceImageItemEh);
    procedure SetLastImageItem(const Value: TResourceImageItemEh);
    procedure SetNextImageItem(const Value: TResourceImageItemEh);
    procedure SetPostImageItem(const Value: TResourceImageItemEh);
    procedure SetPriorImageItem(const Value: TResourceImageItemEh);
    procedure SetRefreshImageItem(const Value: TResourceImageItemEh);

    procedure BtnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure ClickHandler(Sender: TObject; var AutoRepeat: Boolean; var Handled: Boolean);
    procedure HintsChanged(Sender: TObject);
    procedure InitHints;
    procedure InitItems;
    procedure SetBorderColor(const Value: TAlphaColor);
    procedure SetHints(Value: TStrings);
    procedure SetSearchPanelControl(const Value: TControl);
    procedure SetSize(var W: Integer; var H: Integer);
    procedure SetVisibleButtons(Value: TNavButtonSetEh);
    procedure SetVisibleItems(const Value: TGridSBItemsEh);
    function GetGrid: TControl;
    procedure GridSelectionChangedAsync;
    procedure PostGridSelectionChanged;
    procedure DoAsyncTimer(Sender: TObject);
    function GetGridView: TDataGridRowsViewEh;

  protected
    FindEditDivider: TNavButtonEh;
    NavButtons: array[TNavigateBtnEh] of TNavButtonEh;
    NavButtonsDivider: TNavButtonEh;
    RecordsInfoPanel: TNavButtonEh;
    SelectionInfoDivider: TNavButtonEh;
    SelectionInfoPanel: TDataGridSelectionInfoPanelEh;
    SelectionInfoPanelDataEh: array of TSelectionInfoPanelDataItemEh;
    FAsyncTimer: TTimer;

    function CalcWidthForRecordsInfoPanel: Integer;
    function CalcWidthSelectionInfoPanel: Single;
    function GetClientRect: TRect;
    function GetDefaultStyleLookupName: string; override;

    procedure CalcMinSize(var W, H: Integer);
    procedure DataChanged;
    procedure GridSelectionChanged;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Paint; override;
    procedure PaintDivider(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure PaintRecordsInfo(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure ResetVisibleControls;
    procedure Resize; override;
    procedure SelectionInfoPanelMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure TableViewDataChanged(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowView: TTableRowViewEh); virtual;
    procedure VisibleChanged; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function CheckConfirmDelete: Boolean;
    function DataSetActive: Boolean;
    function DividerWidth: Integer; virtual;
    function GetSelectionInfoPanelText: String;
    function OptimalWidth: Integer;

    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    procedure NavBtnClick(Index: TNavigateBtnEh); virtual;
    procedure ResetWidth;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Single); override;

    property Grid: TControl read GetGrid;
    property BeforeAction: TNavClickEh read FBeforeAction write FBeforeAction;
    property BorderColor: TAlphaColor read FBorderColor write SetBorderColor;
    property TableView: TDataGridTableRowsViewEh read GetTableView;
    property GridView: TDataGridRowsViewEh read GetGridView;
    property Hints: TStrings read GetHints write SetHints;
    property SearchPanelControl: TControl read FSearchPanelControl write SetSearchPanelControl;
    property VisibleButtons: TNavButtonSetEh read FVisibleButtons write SetVisibleButtons;
    property VisibleItems: TGridSBItemsEh read FVisibleItems write SetVisibleItems;

    property FirstImageItem: TResourceImageItemEh read GetFirstImageItem write SetFirstImageItem;
    property PriorImageItem: TResourceImageItemEh read GetPriorImageItem write SetPriorImageItem;
    property NextImageItem: TResourceImageItemEh read GetNextImageItem write SetNextImageItem;
    property LastImageItem: TResourceImageItemEh read GetLastImageItem write SetLastImageItem;
    property InsertImageItem: TResourceImageItemEh read GetInsertImageItem write SetInsertImageItem;
    property DeleteImageItem: TResourceImageItemEh read GetDeleteImageItem write SetDeleteImageItem;
    property EditImageItem: TResourceImageItemEh read GetEditImageItem write SetEditImageItem;
    property PostImageItem: TResourceImageItemEh read GetPostImageItem write SetPostImageItem;
    property CancelImageItem: TResourceImageItemEh read GetCancelImageItem write SetCancelImageItem;
    property RefreshImageItem: TResourceImageItemEh read GetRefreshImageItem write SetRefreshImageItem;
  end;

{ TDataGridSelectionInfoPanelEh }

  TDataGridSelectionInfoPanelEh = class(TLayout)
  private
    FAggrTexts: array[TAggrFunctionEh] of TText;
    FResultArr: TAggrResultArr;

    function CreateInitTextControl(AggrFunc: TAggrFunctionEh): TText;
    function GetGridNavigatorPanel: TDataGridNavigatorPanelEh;

    procedure GetGridAggrInfo(var ResultArr: TAggrResultArr);
    function GetHasAggrData: Boolean;
  protected

  public
    function CalcLayoutWidth: Single;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure RecalcAggrInfo();
    procedure PrepareForPaint; override;

    property GridNavigatorPanel: TDataGridNavigatorPanelEh read GetGridNavigatorPanel;
    property HasAggrData: Boolean read GetHasAggrData;
  end;

{ TDataGridScrollBarPanelControlEh }

  TDataGridScrollBarPanelControlEh = class(TGridScrollBarPanelControlEh)
  private
    FExtraPanel: TDataGridNavigatorPanelEh;
    function GetOnScroll: TNotifyEvent;
    procedure SetOnScroll(const Value: TNotifyEvent);

  protected
    function ScrollBatCode: Integer;
    procedure Resize; override;
    procedure DoRealign; override;
    procedure SetPaintColors; override;

    procedure OnScrollEvent(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);

  public
    constructor Create(AOwner: TComponent; AKind: TOrientation); reintroduce;
    destructor Destroy; override;

    function MaxSizeForExtraPanel: Integer;

    procedure Invalidate;
    procedure GridSelectionChanged;
    procedure DataSetChanged; virtual;
    procedure SetParams(APosition, AMin, AMax, APageSize: Integer);

    property OnScroll: TNotifyEvent read GetOnScroll write SetOnScroll;
    property ExtraPanel: TDataGridNavigatorPanelEh read FExtraPanel;
  end;

{ TCustomDataGridCanSelectRowParamsEh }

  TCustomDataGridCanSelectRowParamsEh = class(TPersistent)
  private
    FGrid: TControl;
    FCanSelectRow: Boolean;
    FHandled: Boolean;
    FRow: TDataGridRowEh;

  protected
    procedure Reset(AGrid: TControl; ARow: TDataGridRowEh); virtual;

  public
    constructor Create; overload;
    constructor Create(AGrid: TControl; ARow: TDataGridRowEh); overload;
    procedure DefaultCanSelectRow(Params: TCustomDataGridCanSelectRowParamsEh);

    property Grid: TControl read FGrid;

    property Row: TDataGridRowEh read FRow;
    property CanSelectRow: Boolean read FCanSelectRow write FCanSelectRow;
    property Handled: Boolean read FHandled write FHandled;
  end;

{ TDataGridGetDataRowSplitWayParamsEh }

  TBaseDataGridGetDataRowSplitWayParamsEh = class(TPersistent)
  private
    FGrid: TControl;
    FRowSplitWay: TDataGridRowSplitWayEh;
    FHandled: Boolean;
    FRow: TDataGridDataRowEh;

  protected
  public
    procedure Reset(AGrid: TControl; ARow: TDataGridDataRowEh; ARowSplitWay: TDataGridRowSplitWayEh); virtual;

    function DefaultGetRowSplitWay(): TDataGridRowSplitWayEh;

    property Grid: TControl read FGrid;
    property Row: TDataGridDataRowEh read FRow;
    property RowSplitWay: TDataGridRowSplitWayEh read FRowSplitWay write FRowSplitWay;
    property Handled: Boolean read FHandled write FHandled;
  end;

{ TBaseDataGridGetDataRowManagerParamsEh }

  TBaseDataGridGetDataRowManagerParamsEh = class(TPersistent)
  private
    FRow: TDataGridRowEh;
    FGrid: TControl;
    FCellManager: TVPBaseCellManagerEh;

  public
    procedure Init(AGrid: TControl; ARow: TDataGridRowEh; ADefaultCellManager: TVPBaseCellManagerEh); virtual;

    property Grid: TControl read FGrid;
    property Row: TDataGridRowEh read FRow;
    property CellManager: TVPBaseCellManagerEh read FCellManager write FCellManager;
  end;

{ TDataGridCalcDataRowHeightParamsEh }

  TDataGridCalcDataRowHeightParamsEh = class(TPersistent)
  private
    FGrid: TControl;
    FDataAreaRowIndex: Integer;
    FRowHeight: Integer;
    FHandled: Boolean;

  public
    constructor Create; overload;
    constructor Create(AGrid: TControl; ADataAreaRowIndex: Integer); overload;

    procedure Reset(AGrid: TControl; ADataAreaRowIndex: Integer); virtual;
    function DefaultCalcRowHeight(Params: TDataGridCalcDataRowHeightParamsEh): Integer;

    property Grid: TControl read FGrid;

    property DataAreaRowIndex: Integer read FDataAreaRowIndex;
    property RowHeight: Integer read FRowHeight write FRowHeight;
    property Handled: Boolean read FHandled write FHandled;
  end;

{ TDataGridMouseComplexTitleMovingStateEh }

  TDataGridMouseComplexTitleMovingStateEh = class(TBaseGridMouseStateEh)
  private
    FParentNode: TBaseTreeNodeEh;
    FMoveToNodeIndex: Integer;
    FMovingNodeIndex: Integer;
    FLineTopPos: Integer;
    FLineLength: Integer;
    FMovePosRightSite: Boolean;
  public
    property ParentNode: TBaseTreeNodeEh read FParentNode write FParentNode;
    property MovingNodeIndex: Integer read FMovingNodeIndex write FMovingNodeIndex;
    property MoveToNodeIndex: Integer read FMoveToNodeIndex write FMoveToNodeIndex;
    property LineTopPos: Integer read FLineTopPos write FLineTopPos;
    property LineLength: Integer read FLineLength write FLineLength;
    property MovePosRightSite: Boolean read FMovePosRightSite write FMovePosRightSite;
  end;

{ TDataGridOptimizeColWidthsMouseStateEh }

  TDataGridOptimizeColWidthsMouseStateEh = class(TBaseGridMouseStateEh)

  end;

{ TDataGridGroupDescriptionMovingStateEh }

  TDataGridGroupDescriptionMovingStateEh = class(TBaseGridMouseStateEh)
  private
    FGroupDescriptionFrom: TPersistent;
    FGroupDescriptionToIndex: Integer;
    FToIndexLineHeight: Single;
    FToIndexScreenLinePos: TPointF;
  protected
    procedure Release; override;
  public
    procedure UpdateStateForMousePos(AScreenMousePost: TPointF);
    property GroupDescriptionFrom: TPersistent read FGroupDescriptionFrom write FGroupDescriptionFrom;
    property GroupDescriptionToIndex: Integer read FGroupDescriptionToIndex write FGroupDescriptionToIndex;
    property ToIndexScreenLinePos: TPointF read FToIndexScreenLinePos write FToIndexScreenLinePos;
    property ToIndexLineHeight: Single read FToIndexLineHeight write FToIndexLineHeight;
  end;

{ TDataGridMouseStateManageEh }

  TDataGridMouseStateManagerEh = class(TGridMouseStateManagerEh)
  private
    FComplexTitleMovingState: TDataGridMouseComplexTitleMovingStateEh;
    FOptimizeColWidths: TDataGridOptimizeColWidthsMouseStateEh;
    FGroupDescriptionMovingState: TDataGridGroupDescriptionMovingStateEh;

  public
    constructor Create(AGrid: TControl);
    destructor Destroy; override;

    property ComplexTitleMovingState: TDataGridMouseComplexTitleMovingStateEh read FComplexTitleMovingState;
    property OptimizeColWidths: TDataGridOptimizeColWidthsMouseStateEh read FOptimizeColWidths;
    property GroupDescriptionMovingState: TDataGridGroupDescriptionMovingStateEh read FGroupDescriptionMovingState;
  end;

{ TDataGridStaticColumnsContainerEh }

  TDataGridStaticColumnsContainerEh = class(TPersistent)
  private
    FGrid: TCustomDataAxisGridEh;
    function GetChildrenCount: Integer;
    function GetChildren(Index: Integer): TComponent;
  protected
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;

    procedure SetChildrenIndex(AChildren: TComponent; NewIndex: Integer);
    function GetChildrenIndex(AChildren: TComponent): Integer;
    function GetParentItemCount(AParent: TComponent): Integer;
    function GetChildItem(AParent: TComponent; ItemIndex: Integer): TComponent;
    function GetParentForChild(AChild: TComponent): TComponent;
    procedure AddChildren(AParent: TComponent; AChildren: TComponent);

    property ChildrenCount: Integer read GetChildrenCount;
    property Children[Index: Integer]: TComponent read GetChildren;

    property Grid: TCustomDataAxisGridEh read FGrid;
  end;

implementation

uses
  Math,
  Data.DBConsts,
  EhLibLangConsts,
  EhLibFmx.CustomizeColumnsDialog,

  EhLibFmx.DataGrid.SearchPanels,
  EhLibFmx.CustomDataGrids,
  EhLibFmx.DataGrid.Columns,
  EhLibFmx.DataGrid.ComplexTitles,
  EhLibFmx.DataGrid.ImpExp
  ;

type
//  TCustomGridEhCrack = class(TCustomGridEh);
  TColumnEhCrack = class(TDataGridBaseColumnEh);
  TCustomDataGridEhCrack = class(TCustomDataGridEh);
  TDataGridSearchPanelControlEhCrack = class(TDataGridSearchPanelControlEh);
  TControlCrack = class(TControl);
  TDataGridRowEhCrack = class(TDataGridRowEh);

{$REGION 'TDataGridSelectionEh'}

{ TDataGridSelectionEh }

constructor TDataGridSelectionEh.Create(AGrid: TControl);
begin
  inherited Create;
  FGrid := AGrid;
  FColumns := TDataGridSelectionColsEh.Create(AGrid);
  FRows := TDataGridSelectedRowsEh.Create(Self);
  FSelectionType := TDataGridSelectionTypeEh.Non;
  FRowSelect := False;
  FKeepSelection := False;
end;

destructor TDataGridSelectionEh.Destroy;
begin
  FreeAndNil(FRows);
  FreeAndNil(FColumns);

  inherited Destroy;
end;

function TDataGridSelectionEh.DataCellSelected(DataColIdx: Integer; DataRow: Integer): Boolean;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);

  if (Grid.Selection.SelectionType = TDataGridSelectionTypeEh.Columns) then
    Result := Grid.VisibleColumns[DataColIdx].IsSelected
  else if (Grid.Selection.SelectionType = TDataGridSelectionTypeEh.RecordBookmarks) and (DataRow < Grid.VisibleRows.Count)  then
    Result := Grid.VisibleRows[DataRow].IsSelected
  else if (Grid.Selection.SelectionType = TDataGridSelectionTypeEh.Rectangle)  then
    Result := Grid.Selection.CellsRectContains(DataColIdx, DataRow)
  else if (Grid.Selection.SelectionType = TDataGridSelectionTypeEh.All)  then
    Result := True
  else
    Result := False;
end;

procedure TDataGridSelectionEh.Clear;
var
  ASelectionType: TDataGridSelectionTypeEh;
  Grid: TCustomDataGridEhCrack;
  I: Integer;
begin
  Grid := TCustomDataGridEhCrack(FGrid);

  try
    ASelectionType := FSelectionType;
    FSelectionType := TDataGridSelectionTypeEh.Non;
    case ASelectionType of
      TDataGridSelectionTypeEh.RecordBookmarks:
      begin
        for I := 0 to Grid.VisibleRows.Count - 1 do
          TDataGridRowEhCrack(Grid.VisibleRows[I]).FIsSelected := False;
        SelectionChanged;
      end;
      TDataGridSelectionTypeEh.Rectangle:
        SelectionChanged;
      TDataGridSelectionTypeEh.Columns:
        Columns.Clear;
      TDataGridSelectionTypeEh.All:
        begin
          SelectionChanged;
          Grid.Invalidate;
        end;
    end;
  finally
  end;
end;

function TDataGridSelectionEh.GetSelectedRowCount: Integer;
var
  Grid: TCustomDataGridEhCrack;
  I: Integer;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  Result := 0;
  for I := 0 to Grid.VisibleRows.Count - 1 do
  begin
    if Grid.VisibleRows[I].IsSelected then
      Result := Result + 1;
  end;
end;

procedure TDataGridSelectionEh.Refresh;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);

  case SelectionType of
    TDataGridSelectionTypeEh.RecordBookmarks:
      ;
    TDataGridSelectionTypeEh.Rectangle:
      begin
      end;
    TDataGridSelectionTypeEh.Columns:
      if Columns.Count = 0 then begin
        FSelectionType := TDataGridSelectionTypeEh.Non;
        Grid.Invalidate;
      end;
  end;
end;

procedure TDataGridSelectionEh.SelectAll;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);

  if SelectionType = TDataGridSelectionTypeEh.All then Exit;
  if SelectionType <> TDataGridSelectionTypeEh.Non then Clear;
  FSelectionType := TDataGridSelectionTypeEh.All;
  Grid.Invalidate;
  SelectionChanged;
end;

procedure TDataGridSelectionEh.SetSelectionType(ASelType: TDataGridSelectionTypeEh);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);

  if FSelectionType = ASelType then Exit;
  FSelectionType := ASelType;
  SelectionChanged;
  Grid.InvalidateEditor;
end;

procedure TDataGridSelectionEh.UpdateState;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);

  case SelectionType of
    TDataGridSelectionTypeEh.RecordBookmarks:
      if Grid.SelectedRows.Count = 0 then
      begin
        FSelectionType := TDataGridSelectionTypeEh.Non;
        Grid.Invalidate;
      end;
    TDataGridSelectionTypeEh.Rectangle:
      begin
      end;
    TDataGridSelectionTypeEh.Columns:
      if Columns.Count = 0 then
      begin
        FSelectionType := TDataGridSelectionTypeEh.Non;
        Grid.Invalidate;
      end;
  end;
end;

procedure TDataGridSelectionEh.SelectionChanged;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);

  FRows.FIsObsolete := True;

  if (Grid <> nil) and not Updating then
  begin
    Grid.SelectionChanged;
    FSelectionChanged := False;
  end else
    FSelectionChanged := True;
end;

procedure TDataGridSelectionEh.Assign(Selection: TDataGridSelectionEh);
begin
end;

procedure TDataGridSelectionEh.Assign(Source: TPersistent);
begin
  if Source is TDataGridSelectionEh then
    Assign(Source as TDataGridSelectionEh)
  else
    inherited Assign(Source);
end;

procedure TDataGridSelectionEh.AssignAsBaseRef(Selection: TDataGridSelectionEh);
begin
end;

procedure TDataGridSelectionEh.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TDataGridSelectionEh.EndUpdate(AForceChangeSelection: Boolean);
begin
  Dec(FUpdateCount);
  if AForceChangeSelection then
    SelectionChanged
  else if (FUpdateCount = 0) and FSelectionChanged then
    SelectionChanged;
end;

function TDataGridSelectionEh.Updating: Boolean;
begin
  Result := (FUpdateCount > 0);
end;

procedure TDataGridSelectionEh.InitAnchorRow(AAnchorDataRowIndex: Integer; ASelectedStateIsSelected: Boolean);
begin
  FAnchorDataRowIndex := AAnchorDataRowIndex;
  FFreeEndDataRowIndex := AAnchorDataRowIndex;
  FSelectedStateIsSelected := ASelectedStateIsSelected;
end;

function TDataGridSelectionEh.IsRowInSelection(ARow: TDataGridRowEh): Boolean;
begin
  if SelectionType = TDataGridSelectionTypeEh.All then
    Result := True
  else
    Result := ARow.IsSelected;
end;

procedure TDataGridSelectionEh.SetFreeEndRow(NewFreeEndRow: Integer);
var
  StepIndex: Integer;
  ARow: TDataGridRowEh;
  OldSelState: Boolean;
  Grid: TCustomDataGridEhCrack;
  I: Integer;
begin
  Grid := TCustomDataGridEhCrack(FGrid);

  if (NewFreeEndRow > FreeEndDataRowIndex) then
  begin
    BeginUpdate();
    try
      StepIndex := Math.Min(AnchorDataRowIndex, newFreeEndRow);

      for I := FreeEndDataRowIndex to StepIndex - 1 do
      begin
        OldSelState := not FSelectedStateIsSelected;
        ARow := Grid.VisibleRows[i];
        if (Grid.CanSelectRow(ARow)) then
          SetSelectedRow(ARow, OldSelState);
      end;

      StepIndex := Math.Max(AnchorDataRowIndex + 1, FreeEndDataRowIndex + 1);

      for I := StepIndex to newFreeEndRow do
      begin
        ARow := Grid.VisibleRows[I];
        if (Grid.CanSelectRow(ARow)) then
          SetSelectedRow(ARow, FSelectedStateIsSelected);
      end;
    finally
      EndUpdate(True);
    end
  end
  else if (newFreeEndRow < FreeEndDataRowIndex) then
  begin
    BeginUpdate();
    try
      StepIndex := Math.Max(AnchorDataRowIndex, newFreeEndRow);

      for i := FreeEndDataRowIndex downto StepIndex + 1 do
      begin
        OldSelState := not FSelectedStateIsSelected;
        ARow := Grid.VisibleRows[i];
        if (Grid.CanSelectRow(ARow)) then
          SetSelectedRow(Grid.VisibleRows[i], OldSelState);
      end;

      StepIndex := Math.Min(AnchorDataRowIndex - 1, FreeEndDataRowIndex - 1);

      for I := stepIndex downto newFreeEndRow do
      begin
        ARow := Grid.VisibleRows[i];
        if (Grid.CanSelectRow(ARow) = True) then
          SetSelectedRow(ARow, FSelectedStateIsSelected);
      end;
    finally
      EndUpdate(True);
    end

  end;

  FFreeEndDataRowIndex := newFreeEndRow;
end;

procedure TDataGridSelectionEh.SetSelectedRow(ARow: TDataGridRowEh; SetToSelected: Boolean);
begin
  if TDataGridRowEhCrack(ARow).FIsSelected = SetToSelected then Exit;

  if (SelectionType <> TDataGridSelectionTypeEh.RecordBookmarks) and
     (SelectionType <> TDataGridSelectionTypeEh.Non)
  then
    Clear();

  TDataGridRowEhCrack(ARow).FIsSelected := SetToSelected;

  if SetToSelected and (SelectionType <> TDataGridSelectionTypeEh.RecordBookmarks) then
    SetSelectionType(TDataGridSelectionTypeEh.RecordBookmarks)
  else
    SelectionChanged;
end;

procedure TDataGridSelectionEh.CheckClear();
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if (Grid.SelectionOptions.KeepSelection = False) then
    Clear();
end;

procedure TDataGridSelectionEh.GetSelectedRows(ARows: TList<TDataGridRowEh>);
var
  Grid: TCustomDataGridEhCrack;
  I: Integer;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  for I := 0 to Grid.VisibleRows.Count - 1 do
  begin
    if (Grid.VisibleRows[I].IsSelected) or (SelectionType = TDataGridSelectionTypeEh.All) then
      ARows.Add(Grid.VisibleRows[I]);
  end;
end;

function TDataGridSelectionEh.GetSelectedRect: TRect;
begin
  if FAnchorCell.X < FFreeEndCell.X then
  begin
    Result.Left := FAnchorCell.X;
    Result.Right := FFreeEndCell.X;
  end else
  begin
    Result.Left := FFreeEndCell.X;
    Result.Right := FAnchorCell.X;
  end;

  if FAnchorCell.Y < FFreeEndCell.Y then
  begin
    Result.Top := FAnchorCell.Y;
    Result.Bottom := FFreeEndCell.Y;
  end else
  begin
    Result.Top := FFreeEndCell.Y;
    Result.Bottom := FAnchorCell.Y;
  end;
end;

procedure TDataGridSelectionEh.TableViewDataChanged(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer;
  ARowView: TTableRowViewEh);
begin
  if AChangedType = TTableLinkEventTypeEh.Reset then
  begin
    if (Rows.Count > 0) then
      Clear;
  end;
end;

procedure TDataGridSelectionEh.StartCellsRectSelection(AAnchorCell, AFreeEndCell: TGridCoord);
var
  Grid: TCustomDataGridEhCrack;
  AFreeEndGridCell: TGridCoord;
begin
  Grid := TCustomDataGridEhCrack(FGrid);

  if (SelectionType <> TDataGridSelectionTypeEh.Rectangle) then
    Clear();

  if (Grid.VisibleColumns.Count = 0) or (Grid.VisibleRows.Count = 0) then Exit;

  FAnchorCell := AAnchorCell;
  CheckFixCellCoord(AFreeEndCell);
  FFreeEndCell := AFreeEndCell;

  AFreeEndGridCell.X := FFreeEndCell.X + Grid.StartDataColIndex;
  AFreeEndGridCell.Y := FFreeEndCell.Y + Grid.StartDataRowIndex;
  Grid.ClampInView(AFreeEndGridCell, True, True);

  SetSelectionType(TDataGridSelectionTypeEh.Rectangle);
  Grid.InvalidateGrid();
end;

procedure TDataGridSelectionEh.SetFreeEndCell(NewFreeEndCell: TGridCoord);
var
  Grid: TCustomDataGridEhCrack;
  AFreeEndGridCell: TGridCoord;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if (NewFreeEndCell <> FreeEndCell) then
  begin
    CheckFixCellCoord(NewFreeEndCell);
    FFreeEndCell := NewFreeEndCell;

    AFreeEndGridCell.X := FFreeEndCell.X + Grid.StartDataColIndex;
    AFreeEndGridCell.Y := FFreeEndCell.Y + Grid.StartDataRowIndex;
    Grid.ClampInView(AFreeEndGridCell, True, True);

    SelectionChanged();
  end;
end;

procedure TDataGridSelectionEh.CheckFixCellCoord(var CellCoord: TGridCoord);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);

  if (CellCoord.X < 0) then
    CellCoord.X := 0;
  if (CellCoord.Y < 0) then
    CellCoord.Y := 0;

  if (CellCoord.X >= Grid.VisibleColumns.Count) then
    CellCoord.X := Grid.VisibleColumns.Count - 1;
  if (CellCoord.Y >= Grid.DataRowCount) then
    CellCoord.Y := Grid.DataRowCount - 1;
end;

procedure TDataGridSelectionEh.SelectAllRows();
var
  Grid: TCustomDataGridEhCrack;
  I: Integer;
  ARow: TDataGridRowEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  SetSelectionType(TDataGridSelectionTypeEh.RecordBookmarks);
  for I := 0 to Grid.VisibleRows.Count - 1 do
  begin
    ARow := TDataGridRowEhCrack(Grid.VisibleRows[I]);
    TDataGridRowEhCrack(ARow).FIsSelected := True;
  end;
  SelectionChanged;
end;

function TDataGridSelectionEh.CellsRectContains(AreaColIndex, AreaRowIndex: Integer): Boolean;
var
  ContainsAreaCol: Boolean;
  ContainsAreaRow: Boolean;
begin

  if (FAnchorCell.X < FFreeEndCell.X) then
    ContainsAreaCol := (FAnchorCell.X <= AreaColIndex) and (AreaColIndex <= FFreeEndCell.X)
  else
    ContainsAreaCol := (FAnchorCell.X >= AreaColIndex) and (AreaColIndex >= FFreeEndCell.X);

  if (FAnchorCell.Y < FFreeEndCell.Y) then
    ContainsAreaRow := (FAnchorCell.Y <= AreaRowIndex) and (AreaRowIndex <= FFreeEndCell.Y)
  else
    ContainsAreaRow := (FAnchorCell.Y >= AreaRowIndex) and (AreaRowIndex >= FFreeEndCell.Y);

  Result :=  ContainsAreaCol and ContainsAreaRow;
end;

{$ENDREGION 'TDataGridSelectionEh'}

{$REGION 'TDataGridSelectionColsEh'}

{ TDataGridSelectionColsEh }

constructor TDataGridSelectionColsEh.Create(AGrid: TControl);
begin
  inherited Create;
  FAnchorCol := nil;
  FGrid := AGrid;
  FShiftSelectedCols := TColumnsListEh.Create;
end;

destructor TDataGridSelectionColsEh.Destroy;
begin
  FreeAndNil(FShiftSelectedCols);
  inherited Destroy;
end;

procedure TDataGridSelectionColsEh.Add(AFieldBar: TFieldBarEh);
var
  i: Integer;
  Grid: TCustomDataGridEhCrack;
  Added: Boolean;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  Added := False;

  for i := 0 to Count - 1 do
  begin
    if AFieldBar.VisibleIndex < Items[i].VisibleIndex then
    begin
      Insert(i, AFieldBar);
      Added := True;
      Break;
    end;
  end;

  if not Added then
    inherited Add(AFieldBar);

  if Grid <> nil then
    Grid.Selection.SelectionChanged;
  TColumnEhCrack(AFieldBar).FIsSelectedInternal := True;
end;

function TDataGridSelectionColsEh.Remove(const Value: TFieldBarEh): Integer;
begin
  Result := inherited Remove(Value);
  TColumnEhCrack(Value).FIsSelectedInternal := False;
end;

procedure TDataGridSelectionColsEh.Clear;
var
  i: Integer;
  OldCount: Integer;
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);

  for i := 0 to Count - 1 do
    TColumnEhCrack(Items[i]).FIsSelectedInternal := False;

  if (Grid = nil) or (csDestroying in Grid.ComponentState) then
    inherited Clear
  else
  begin
    if Grid <> nil then
    begin
      for i := 0 to Count - 1 do
        Grid.InvalidateCol(Grid.DataToRawColumn(Items[i].VisibleIndex));
    end;
    OldCount := Count;
    inherited Clear;
    FAnchorCol := nil;
    if (Grid <> nil) and (Grid.Selection.SelectionType <> TDataGridSelectionTypeEh.Non) then
      Grid.Selection.SetSelectionType(TDataGridSelectionTypeEh.Non)
    else if (Grid <> nil) and (OldCount > 0) then
      Grid.Selection.SelectionChanged;
  end;
end;

procedure TDataGridSelectionColsEh.InvertSelect(AFieldBar: TFieldBarEh);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);

  if Grid.Selection.SelectionType <> TDataGridSelectionTypeEh.Columns then
    Grid.Selection.Clear;

  if IndexOf(AFieldBar) = -1 then
  begin
    Add(AFieldBar);
    FAnchorCol := AFieldBar;
    FShiftCol := AFieldBar;
  end else
  begin
    Remove(AFieldBar);
    FAnchorCol := AFieldBar;
    FShiftCol := AFieldBar;
  end;

  if Count = 0
    then Grid.Selection.SetSelectionType(TDataGridSelectionTypeEh.Non)
    else Grid.Selection.SetSelectionType(TDataGridSelectionTypeEh.Columns);

  FShiftSelectedCols.Clear;
end;

function CompareColumns(const Item1, Item2: TFieldBarEh): Integer;
begin
  if TDataGridBaseColumnEh(Item1).VisibleIndex > TDataGridBaseColumnEh(Item2).VisibleIndex then
    Result := 1
  else if TDataGridBaseColumnEh(Item1).VisibleIndex < TDataGridBaseColumnEh(Item2).VisibleIndex then
    Result := -1
  else
    Result := 0;
end;

procedure TDataGridSelectionColsEh.Refresh;
var
  i, j: Integer;
  Found: Boolean;
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);

  for i := Count - 1 downto 0 do
  begin
    Found := False;
    for j := 0 to Grid.Columns.Count - 1 do
      if Grid.Columns[j] = Items[i] then
      begin
        Found := True;
        Break;
      end;
    if not Found then Delete(i);
  end;

  Sort(TComparer<TFieldBarEh>.Construct(CompareColumns));
end;

procedure TDataGridSelectionColsEh.Select(AFieldBar: TFieldBarEh; AddSel: Boolean);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);

  if Grid.Selection.SelectionType <> TDataGridSelectionTypeEh.Columns then Grid.Selection.Clear;
  if not AddSel then Clear;
  if IndexOf(AFieldBar) = -1 then Add(AFieldBar);
  FAnchorCol := AFieldBar;
  FShiftCol := AFieldBar;
  Grid.Selection.SetSelectionType(TDataGridSelectionTypeEh.Columns);
  FShiftSelectedCols.Clear;
end;

function TDataGridSelectionColsEh.SelectionToGridRect: TGridRect;
var
  LeftCol, RightCol: Integer;
  i: Integer;
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);

  LeftCol := -1;
  RightCol := -1;
  if Count > 0 then
  begin
    LeftCol := Items[0].VisibleIndex;
    RightCol := Items[0].VisibleIndex;
    for i := 1 to Count-1 do
    begin
      if Items[i].VisibleIndex < LeftCol then
        LeftCol := Items[i].VisibleIndex;
      if Items[i].VisibleIndex > RightCol then
        RightCol := Items[i].VisibleIndex;
    end;
  end;
  Result := GridRect(Grid.DataToRawColumn(LeftCol), 0, Grid.DataToRawColumn(RightCol), Grid.FullRowCount-1);
end;

procedure TDataGridSelectionColsEh.SelectShift(AFieldBar: TFieldBarEh {; Clear:Boolean});
var
  i: Integer;
  Step: Integer;
  FromIndex, ToIndex, RemoveIndex: Integer;
  NeedAdd: Boolean;
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);

  if Grid.Selection.SelectionType <> TDataGridSelectionTypeEh.Columns then Grid.Selection.Clear;
  RemoveIndex := -1;
  Step := 1;
  NeedAdd := True;
  FromIndex := AFieldBar.VisibleIndex;
  ToIndex := AFieldBar.VisibleIndex;
  if FAnchorCol = nil then
  begin
    Select(AFieldBar, True);
    FAnchorCol := AFieldBar;
  end else
  begin
    if (FAnchorCol.VisibleIndex < FShiftCol.VisibleIndex) then
    begin
      if (FShiftCol.VisibleIndex < AFieldBar.VisibleIndex) then
      begin
        FromIndex := FShiftCol.VisibleIndex;
        ToIndex := AFieldBar.VisibleIndex;
        NeedAdd := True;
      end else if (FShiftCol.VisibleIndex > AFieldBar.VisibleIndex) then
      begin
        FromIndex := FShiftCol.VisibleIndex;
        if FAnchorCol.VisibleIndex > AFieldBar.VisibleIndex then
          RemoveIndex := FAnchorCol.VisibleIndex;
        ToIndex := AFieldBar.VisibleIndex + IfThen(RemoveIndex <> -1, 0, 1);
        Step := -1;
        NeedAdd := False;
      end
    end
    else if (FAnchorCol.VisibleIndex > FShiftCol.VisibleIndex) then
    begin
      if (FShiftCol.VisibleIndex > AFieldBar.VisibleIndex) then
      begin
        FromIndex := FShiftCol.VisibleIndex;
        ToIndex := AFieldBar.VisibleIndex;
        Step := -1;
        NeedAdd := True;
      end else if (FShiftCol.VisibleIndex < AFieldBar.VisibleIndex) then
      begin
        FromIndex := FShiftCol.VisibleIndex;
        if FAnchorCol.VisibleIndex < AFieldBar.VisibleIndex then
          RemoveIndex := FAnchorCol.VisibleIndex;
        ToIndex := AFieldBar.VisibleIndex - IfThen(RemoveIndex <> -1, 0, 1);
        NeedAdd := False;
      end;
    end else
    begin
      FromIndex := FAnchorCol.VisibleIndex;
      if FAnchorCol.VisibleIndex > AFieldBar.VisibleIndex then
        Step := -1;
    end;
    i := FromIndex;
    while True do
    begin
      if i = RemoveIndex then NeedAdd := not NeedAdd;
      if NeedAdd then
      begin
        if IndexOf(Grid.VisibleColumns[FAnchorCol.VisibleIndex]) <> -1 then
        begin
          if (IndexOf(Grid.VisibleColumns[i]) = -1) and Grid.VisibleColumns[i].Visible then
          begin
            Add(Grid.VisibleColumns[i]);
            Grid.InvalidateCol(Grid.DataToRawColumn(Grid.VisibleColumns[i].VisibleIndex));
            FShiftSelectedCols.Add(Grid.VisibleColumns[i]);
            Grid.Selection.SelectionChanged;
          end;
        end else
        begin
          if (IndexOf(Grid.VisibleColumns[i]) <> -1) and (i <> FAnchorCol.VisibleIndex) then
          begin
            Remove(Grid.VisibleColumns[i]);
            Grid.InvalidateCol(Grid.DataToRawColumn(Grid.VisibleColumns[i].VisibleIndex));
            FShiftSelectedCols.Add(Grid.VisibleColumns[i]);
            Grid.Selection.SelectionChanged;
          end;
        end
      end else
      begin
        if IndexOf(Grid.VisibleColumns[FAnchorCol.VisibleIndex]) <> -1 then
        begin
          if (IndexOf(Grid.VisibleColumns[i]) <> -1) and (i <> FAnchorCol.VisibleIndex) then
          begin
            if FShiftSelectedCols.IndexOf(Grid.VisibleColumns[i]) <> -1 then
            begin
              Remove(Grid.VisibleColumns[i]);
              FShiftSelectedCols.Remove(Grid.VisibleColumns[i]);
            end;
            Grid.InvalidateCol(Grid.DataToRawColumn(Grid.VisibleColumns[i].VisibleIndex));
            Grid.Selection.SelectionChanged;
          end;
        end else
        begin
          if (IndexOf(Grid.VisibleColumns[i]) = -1) and Grid.VisibleColumns[i].Visible then
          begin
            if FShiftSelectedCols.IndexOf(Grid.VisibleColumns[i]) <> -1 then
            begin
              Add(Grid.VisibleColumns[i]);
              FShiftSelectedCols.Remove(Grid.VisibleColumns[i]);
            end;
            Grid.InvalidateCol(Grid.DataToRawColumn(Grid.VisibleColumns[i].VisibleIndex));
            Grid.Selection.SelectionChanged;
          end;
        end
      end;
      if i = ToIndex then Break;
      Inc(i, Step);
    end;
  end;
  FShiftCol := AFieldBar;
  if Count = 0
    then Grid.Selection.SetSelectionType(TDataGridSelectionTypeEh.Non)
    else Grid.Selection.SetSelectionType(TDataGridSelectionTypeEh.Columns);
end;

{$ENDREGION 'TDataGridSelectionColsEh'}

{$REGION 'TDataGridMoveAndScrollServiceEh'}

{ TDataGridMoveAndScrollServiceEh }

constructor TDataGridMoveAndScrollServiceEh.Create(AGrid: TStyledControlEh);
begin
  inherited Create();
  FGrid := AGrid;
  lastMouseEvArg := TControlMouseParamsEh.Create;

  FTimer := TTimer.Create(nil);
  FTimer.Interval := 100;
  FTimer.OnTimer := Timer_Elapsed;
  FTimer.Enabled := False;
end;

destructor TDataGridMoveAndScrollServiceEh.Destroy;
begin
  lastMouseEvArg.Free;
  FTimer.Free;
  inherited Destroy;
end;

function TDataGridMoveAndScrollServiceEh.GetClientRect: TRect;
begin
  Result := FClientRect.Round;
end;

procedure TDataGridMoveAndScrollServiceEh.Capture(clientRect: TRectF;
  AMoveAndScrollEvent: TMoveAndScrollServiceEventEh; horzOutMove, vertOutMove: Boolean);
var
  pointsPerInch: Integer;
  controlClientBounds: TRectF;

begin
  Assert(Active = False, 'MoveAndScrollHelpService already Active');
  pointsPerInch := 96;

  FGrid.Capture();
  FMoveAndScrollEvent := AMoveAndScrollEvent;

  FClientRect := clientRect;
  FActive := True;
  FScreenForClientRect := Screen.DesktopRect;
  FHorzOutMove := horzOutMove;
  FVertOutMove := vertOutMove;

  controlClientBounds.TopLeft := TCustomDataGridEhCrack(FGrid).LocalToScreen(clientRect.TopLeft);

  if clientRect.Width = 0 then
  begin
    controlClientBounds.Left := Screen.DesktopRect.Left;
    controlClientBounds.Right := Screen.DesktopRect.Right;
  end else
  begin
    controlClientBounds.Width := clientRect.Width;
  end;

  if clientRect.Height = 0 then
  begin
    controlClientBounds.Top := Screen.DesktopRect.Top;
    controlClientBounds.Bottom := Screen.DesktopRect.Bottom;
  end else
  begin
    controlClientBounds.Height := clientRect.Height;
  end;

  if (controlClientBounds.Left - pointsPerInch > FScreenForClientRect.Left) then
    FtoLeftScreenBound := pointsPerInch
  else
    FtoLeftScreenBound := controlClientBounds.Left;

  if (controlClientBounds.Right + pointsPerInch < FScreenForClientRect.Right) then
    FtoRightScreenBound := pointsPerInch
  else
    FtoRightScreenBound := FScreenForClientRect.Right - controlClientBounds.Right;

  if (controlClientBounds.Top - pointsPerInch > FScreenForClientRect.Top) then
    FtoTopScreenBound := pointsPerInch
  else
    FtoTopScreenBound := controlClientBounds.Top;

  if (controlClientBounds.Bottom + pointsPerInch < FScreenForClientRect.Bottom) then
    FtoBottomScreenBound := pointsPerInch
  else
    FtoBottomScreenBound := FScreenForClientRect.Bottom - controlClientBounds.Bottom;
end;

procedure TDataGridMoveAndScrollServiceEh.Release();
begin
  FTimer.Enabled := false;
  FMoveAndScrollEvent := nil;
  FClientRect := TRect.Empty;
  FActive := False;
end;

procedure TDataGridMoveAndScrollServiceEh.MouseMove(MouseParams: TControlMouseParamsEh);
var
  outbound: Boolean;
  newHorzInterval: Single;
  newVertInterval: Single;
  dividend: Single;
begin
  outbound := False;
  newHorzInterval := 200;
  newVertInterval := 200;

  if ((FHorzOutMove = True) and
     ((MouseParams.X > FClientRect.Right) or (MouseParams.X < FClientRect.Left))) then
  begin
    lastMouseEvArg.Init(MouseParams.X, MouseParams.Y, MouseParams.Shift, MouseParams.OriginalObject);
    if (MouseParams.X > FClientRect.Right) then
    begin
      dividend := MouseParams.X - FClientRect.Right;
      if (dividend > FtoRightScreenBound) then
        dividend := FtoRightScreenBound;
      newHorzInterval := 200 - (dividend / FtoRightScreenBound * 198);
    end
    else if (MouseParams.X < FClientRect.Left) then
    begin
      dividend := -MouseParams.X + FClientRect.Left;
      if (dividend > FtoLeftScreenBound) then
        dividend := FtoLeftScreenBound;
      newHorzInterval := 200 - (dividend / FtoLeftScreenBound * 198);
    end
    else
      newHorzInterval := 200;

    outbound := true;
  end;

  if (FVertOutMove = True) and
     ((MouseParams.Y > FClientRect.Bottom) or (MouseParams.Y < FClientRect.Top)) then
  begin
    lastMouseEvArg.Init(MouseParams.X, MouseParams.Y, MouseParams.Shift, MouseParams.OriginalObject);
    if (MouseParams.Y > FClientRect.Bottom) then
    begin
      dividend := MouseParams.Y - FClientRect.Bottom;
      if (dividend > FtoBottomScreenBound) then
        dividend := FtoBottomScreenBound;
      newVertInterval := 200 - (dividend / FtoBottomScreenBound * 198);
    end
    else if (MouseParams.Y < FClientRect.Top) then
    begin
      dividend := -MouseParams.Y + FClientRect.Top;
      if (dividend > FtoTopScreenBound) then
        dividend := FtoTopScreenBound;
      newVertInterval := 200 - (dividend / FtoTopScreenBound * 198);
    end
    else
      newVertInterval := 200;

    outbound := true;
  end;

  MoveAndScrollServiceEvent(MouseParams);

  if (outbound) then
  begin

    FTimer.Interval := Round(Math.Min(newHorzInterval, newVertInterval));
    FTimer.Enabled := True;

    if ((GetTickCountEh - ticks) > FTimer.Interval) then
    begin
      Timer_Elapsed(nil);
    end
  end
  else
  begin
    FTimer.Enabled := False;
    ticks := GetTickCountEh;
  end;
end;

procedure TDataGridMoveAndScrollServiceEh.Timer_Elapsed(Sender: TObject);
begin
  FMoveAndScrollEvent(Self, lastMouseEvArg);
  ticks := GetTickCountEh;
end;

procedure TDataGridMoveAndScrollServiceEh.MoveAndScrollServiceEvent(MouseParams: TControlMouseParamsEh);
begin
  FMoveAndScrollEvent(Self, MouseParams);
end;

{$ENDREGION 'TDataGridMoveAndScrollServiceEh'}

{$REGION 'TGridEditActionsEh'}

{ TGridEditActionsEh }

constructor TGridEditActionsEh.Create(AGrid: TControl);
begin
  inherited Create;
  FGrid := AGrid;
  FCopyEnabled := True;
  FCutEnabled := True;
  FPasteEnabled := True;
  FConfirmDelete := True;
  FSelectAllEnabled := True;
  FDeleteEnabled := True;
  FUseTabs := True;
  FEnterAsTab := False;
end;

destructor TGridEditActionsEh.Destroy;
begin

  inherited Destroy;
end;

function TGridEditActionsEh.ShowCustomizeColumnsDialog(): Boolean;
var
  AGrid: TCustomDataGridEhCrack;
begin
  AGrid := TCustomDataGridEhCrack(FGrid);
  Result := AGrid.Center.ShowCustomizeColumnsDialog(AGrid);
end;

function TGridEditActionsEh.CanCopy: Boolean;
begin
  Result := CopyEnabled;
end;

function TGridEditActionsEh.CanCut: Boolean;
begin
  Result := TCustomDataGridEhCrack(FGrid).CheckCutAction;
end;

function TGridEditActionsEh.CanDelete: Boolean;
begin
  Result := TCustomDataGridEhCrack(FGrid).CheckDeleteAction;
end;

function TGridEditActionsEh.CanPaste: Boolean;
begin
  Result := TCustomDataGridEhCrack(FGrid).CheckPasteAction();
end;

function TGridEditActionsEh.CanSelectAll: Boolean;
begin
  Result := TCustomDataGridEhCrack(FGrid).CheckSelectAllAction();
end;

procedure TGridEditActionsEh.Copy;
begin
  DataGridEh_DoCopyAction(TCustomDataGridEhCrack(FGrid), False);
end;

procedure TGridEditActionsEh.Cut;
begin
  DataGridEh_DoCutAction(TCustomDataGridEhCrack(FGrid), False);
end;

procedure TGridEditActionsEh.Delete;
begin
  DataGridEh_DoDeleteAction(TCustomDataGridEhCrack(FGrid), False);
end;

procedure TGridEditActionsEh.Paste;
begin
  DataGridEh_DoPasteAction(TCustomDataGridEhCrack(FGrid), False);
end;

procedure TGridEditActionsEh.SelectAll;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if CanSelectAll then
    Grid.Selection.SelectAll
  else if (TDataGridSelectionTypeEh.RecordBookmarks in Grid.SelectionOptions.AllowedSelections) then
    Grid.Selection.SelectAllRows;
end;

procedure TGridEditActionsEh.SetUseTabs(const Value: Boolean);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if FUseTabs <> Value then
  begin
    FUseTabs := Value;
    Grid.UpdateBaseOptions();
  end;
end;

function TGridEditActionsEh.ShowConfirmDeleteDialog: Boolean;
begin
  Result := True;
end;

function TGridEditActionsEh.CanFillFromFirstRow: Boolean;
begin
  Result := True;
end;

procedure TGridEditActionsEh.FillFromFirstRow();
var
  Grid: TCustomDataGridEhCrack;
  ASelectedRect: TRect;
  Values: TArray<TValue>;
  I, R: Integer;
  SourceRow: TDataGridRowEh;
  SourceRowIndex: Integer;
  FillRowCount: Integer;
  FromColIndex, ToColIndex: Integer;
  Column: TDataGridBaseColumnEh;
begin
  Grid := TCustomDataGridEhCrack(FGrid);

  if Grid.Selection.SelectionType = TDataGridSelectionTypeEh.Rectangle then
  begin
    ASelectedRect := Grid.Selection.GetSelectedRect;

    FromColIndex := ASelectedRect.Left;
    ToColIndex := ASelectedRect.Right;

    if ASelectedRect.Top = ASelectedRect.Bottom then
    begin
      if ASelectedRect.Top > 0 then
      begin
        SourceRowIndex := ASelectedRect.Top - 1;
        FillRowCount := 1;
      end else
      begin
        Exit;
      end;
    end else
    begin
      SourceRowIndex := ASelectedRect.Top;
      FillRowCount := ASelectedRect.Bottom - ASelectedRect.Top;
    end;
  end else if (Grid.Selection.SelectionType = TDataGridSelectionTypeEh.Non) and
              (Grid.CurrentRowIndex > 0) then
  begin
    SourceRowIndex := Grid.CurrentRowIndex - 1;
    FillRowCount := 1;
    FromColIndex := Grid.CurrentColIndex;
    ToColIndex := Grid.CurrentColIndex;
  end else
  begin
    Exit;
  end;

  SetLength(Values, ToColIndex - FromColIndex + 1);
  SourceRow := Grid.VisibleRows[SourceRowIndex];
  for I := 0 to ToColIndex - FromColIndex do
    Values[I] := Grid.VisibleColumns[I + FromColIndex].GetRowValue(SourceRow);

  for R := SourceRowIndex + 1 to SourceRowIndex + FillRowCount do
  begin
    Grid.CurrentRowIndex := R;
    if Grid.GridView.CurrentRow.CanModify and
       (Grid.GridView.CurrentRow is TDataGridDataRowEh) then
    begin
      Grid.TableView.EditCurrentRow();
      for I := 0 to ToColIndex - FromColIndex do
      begin
        Column := Grid.VisibleColumns[I + FromColIndex];
        if Column.CanModifyCellValue(Grid.CurrentRow) then
          Column.SetCurrentListItemValue(Values[I]);
      end;
      Grid.TableView.PostCurrentRow();
    end;
  end;
end;
{$ENDREGION 'TGridEditActionsEh'}

{$REGION 'TDataGridScrollBarPanelEh'}

{ TDataGridScrollBarPanelEh }

constructor TDataGridScrollBarPanelEh.Create(ScrollBar: TGridScrollBarEh);
begin
  inherited Create;
  FScrollBar := ScrollBar;
  FVisible := False;
  FNavigatorButtons := [TNavigateBtnEh.First,
                        TNavigateBtnEh.Prior,
                        TNavigateBtnEh.Next,
                        TNavigateBtnEh.Last,
                        TNavigateBtnEh.Insert,
                        TNavigateBtnEh.Delete,
                        TNavigateBtnEh.Edit,
                        TNavigateBtnEh.Post,
                        TNavigateBtnEh.Cancel,
                        TNavigateBtnEh.Refresh];
  FVisibleItems := [TGridSBItemEh.RecordsInfo,
                    TGridSBItemEh.Navigator,
                    TGridSBItemEh.SelAggregationInfo];
end;

function TDataGridScrollBarPanelEh.GetVisible: Boolean;
begin
  Result := FVisible;
end;

procedure TDataGridScrollBarPanelEh.SetVisible(const Value: Boolean);
var
  AGrid: TCustomDataGridEhCrack;
begin
  AGrid := TCustomDataGridEhCrack(Grid);
  if Value <> FVisible then
  begin
    FVisible := Value;
    AGrid.UpdateBoundaries;
  end;
end;

function TDataGridScrollBarPanelEh.Grid: TCustomGridEh;
begin
  Result := TCustomGridEh(FScrollBar.Grid);
end;

function TDataGridScrollBarPanelEh.GetNavigatorButtons: TNavButtonSetEh;
begin
  Result := FNavigatorButtons;
end;

procedure TDataGridScrollBarPanelEh.SetNavigatorButtons(const Value: TNavButtonSetEh);
var
  AGrid: TCustomDataGridEhCrack;
begin
  if Value <> FNavigatorButtons then
  begin
    FNavigatorButtons := Value;
    AGrid := TCustomDataGridEhCrack(Grid);
    if (AGrid.HorzScrollBarPanelControl <> nil) and
       (AGrid.HorzScrollBarPanelControl.ExtraPanel <> nil)
    then
      AGrid.HorzScrollBarPanelControl.ExtraPanel.VisibleButtons := Value;
  end;
end;

function TDataGridScrollBarPanelEh.GetVisibleItems: TGridSBItemsEh;
begin
  Result := FVisibleItems;
end;

procedure TDataGridScrollBarPanelEh.SetVisibleItems(const Value: TGridSBItemsEh);
var
  AGrid: TCustomDataGridEhCrack;
begin
  if Value <> FVisibleItems then
  begin
    FVisibleItems := Value;
    AGrid := TCustomDataGridEhCrack(Grid);
    if (AGrid.HorzScrollBarPanelControl <> nil) and
       (AGrid.HorzScrollBarPanelControl.ExtraPanel <> nil)
    then
      AGrid.HorzScrollBarPanelControl.ExtraPanel.VisibleItems := Value;
  end;
end;

{$ENDREGION 'TDataGridScrollBarPanelEh'}

{$REGION 'TDataGridHorzScrollBarEh'}

{ TDataGridHorzScrollBarEh  }

function TDataGridHorzScrollBarEh.CheckScrollBarMustBeShown: Boolean;
begin
  if ExtraPanel.Visible
    then Result := True
    else Result := inherited CheckScrollBarMustBeShown;
end;

constructor TDataGridHorzScrollBarEh.Create(AGrid: TCustomGridEh; AKind: TOrientation);
begin
  inherited Create(AGrid, AKind);
  SmoothStep := True;
  FExtraPanel := TDataGridScrollBarPanelEh.Create(Self);
end;

destructor TDataGridHorzScrollBarEh.Destroy;
begin
  FreeAndNil(FExtraPanel);
  inherited Destroy;
end;

function TDataGridHorzScrollBarEh.IsKeepMaxSizeInDefault: Boolean;
var
  AGrid: TCustomDataGridEhCrack;
begin
  AGrid := TCustomDataGridEhCrack(Grid);
  Result := (Kind = TOrientation.Horizontal) and
            (AGrid.HorzScrollBar.ExtraPanel.Visible) and
            (AGrid.VertScrollBar.Size = 0);
end;

function TDataGridHorzScrollBarEh.ActualScrollBarBoxSize: Integer;
var
  AGrid: TCustomDataGridEhCrack;
begin
  AGrid := TCustomDataGridEhCrack(Grid);
  if IsKeepMaxSizeInDefault then
    Result := inherited ActualScrollBarBoxSize
  else if (AGrid.VertScrollBar.Size <> 0) and
          (AGrid.VertScrollBar.Size < ActualSize)
  then
    Result := AGrid.VertScrollBar.Size
  else
    Result := inherited ActualScrollBarBoxSize;
end;

procedure TDataGridHorzScrollBarEh.SmoothStepChanged;
begin
end;

function TDataGridHorzScrollBarEh.ScrollBarPanel: Boolean;
begin
  Result := ExtraPanel.Visible;
end;

procedure TDataGridHorzScrollBarEh.SetExtraPanel(
  const Value: TDataGridScrollBarPanelEh);
begin
  FExtraPanel.Assign(Value);
end;

function TDataGridHorzScrollBarEh.GetHeight: Integer;
begin
  Result := Size;
end;

procedure TDataGridHorzScrollBarEh.SetHeight(const Value: Integer);
begin
  Size := Value;
end;

{$ENDREGION 'TDataGridHorzScrollBarEh'}

{$REGION 'TDataGridVertScrollBarEh'}

{ TDataGridVertScrollBarEh  }

constructor TDataGridVertScrollBarEh.Create(AGrid: TCustomGridEh; AKind: TOrientation);
begin
  inherited Create(AGrid, AKind);
  FSysScrollBar := True;
end;

procedure TDataGridVertScrollBarEh.SetParams(APosition, AMin, AMax, APageSize: Integer);
begin
end;

procedure TDataGridVertScrollBarEh.SmoothStepChanged;
begin
end;

function TDataGridVertScrollBarEh.GetWidth: Integer;
begin
  Result := Size;
end;

procedure TDataGridVertScrollBarEh.SetWidth(const Value: Integer);
begin
  Size := Value;
end;

{$ENDREGION 'TDataGridVertScrollBarEh'}

{$REGION 'TDataGridScrollBarPanelControlEh'}

{ TDataGridScrollBarPanelControlEh }

procedure TDataGridScrollBarPanelControlEh.Resize;
begin
  inherited Resize;
end;

procedure TDataGridScrollBarPanelControlEh.DoRealign;
begin
  inherited DoRealign;
  if ExtraPanel.Visible then
  begin
    begin
      ExtraPanel.SetBounds(0, 0, ExtraPanel.Width, Height);
      ExtraPanel.ResetWidth;
      ScrollBar.SetBounds(ExtraPanel.Width, ScrollBar.Position.Y, ScrollBar.Width - ExtraPanel.Width, ScrollBar.Height);
    end;
  end;
end;

constructor TDataGridScrollBarPanelControlEh.Create(AOwner: TComponent; AKind: TOrientation);
begin
  inherited Create(AOwner, AKind);

  FExtraPanel := TDataGridNavigatorPanelEh.Create(Self);
  FExtraPanel.Parent := Self;
  FExtraPanel.Visible := (AKind = TOrientation.Horizontal);
end;

destructor TDataGridScrollBarPanelControlEh.Destroy;
begin
  inherited Destroy;
end;

function TDataGridScrollBarPanelControlEh.GetOnScroll: TNotifyEvent;
begin
  Result := ScrollBar.OnChange;
end;

procedure TDataGridScrollBarPanelControlEh.GridSelectionChanged;
begin
  if FKind = TOrientation.Horizontal then
    ExtraPanel.GridSelectionChanged;
  Realign;
end;

procedure TDataGridScrollBarPanelControlEh.DataSetChanged;
begin
  ExtraPanel.DataChanged;
end;

procedure TDataGridScrollBarPanelControlEh.Invalidate;
begin
  ControlInvalidate(Self);
end;

function TDataGridScrollBarPanelControlEh.MaxSizeForExtraPanel: Integer;
begin
  Result := Round(Width - 18 * 2);
end;

procedure TDataGridScrollBarPanelControlEh.OnScrollEvent(Sender: TObject;
  ScrollCode: TScrollCode; var ScrollPos: Integer);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Owner);
  Grid.ScrollBarMessage(ScrollBatCode, Cardinal(ScrollCode), ScrollPos, True);
  ScrollPos := Round(ScrollBar.Value);
end;

function TDataGridScrollBarPanelControlEh.ScrollBatCode: Integer;
begin
  if FKind = TOrientation.Horizontal
    then Result := SB_HORZ_EH
    else Result := SB_VERT_EH;
end;

procedure TDataGridScrollBarPanelControlEh.SetOnScroll(const Value: TNotifyEvent);
begin
  ScrollBar.OnChange := Value;
end;

procedure TDataGridScrollBarPanelControlEh.SetPaintColors;
begin
  inherited SetPaintColors;

end;

procedure TDataGridScrollBarPanelControlEh.SetParams(APosition, AMin, AMax, APageSize: Integer);
begin
  if (AMax <= AMin) or (AMax - AMin < APageSize) then
  begin
    ScrollBar.Enabled := False;
  end else
  begin
    ScrollBar.Enabled := True;
    ScrollBar.Min := AMin;
    ScrollBar.Max := AMax;
    ScrollBar.Value := APosition;
    ScrollBar.SmallChange := APageSize div 5;
    ScrollBar.ViewportSize := APageSize;
  end;
end;

{$ENDREGION 'TDataGridScrollBarPanelControlEh'}

{$REGION 'TDataGridNavigatorPanelEh'}

{ TDataGridNavigatorPanelEh }

constructor TDataGridNavigatorPanelEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FVisibleButtons := [TNavigateBtnEh.First,
                      TNavigateBtnEh.Prior,
                      TNavigateBtnEh.Next,
                      TNavigateBtnEh.Last,
                      TNavigateBtnEh.Insert,
                      TNavigateBtnEh.Delete,
                      TNavigateBtnEh.Edit,
                      TNavigateBtnEh.Post,
                      TNavigateBtnEh.Cancel,
                      TNavigateBtnEh.Refresh];
  FHints := TStringList.Create;
  TStringList(FHints).OnChange := HintsChanged;
  InitItems;
  InitHints;
  ButtonWidth := 0;
  FocusedButton := TNavigateBtnEh.First;
  FVisibleItems := [TGridSBItemEh.RecordsInfo,
                    TGridSBItemEh.Navigator,
                    TGridSBItemEh.SelAggregationInfo];
  Locked := True;
end;

destructor TDataGridNavigatorPanelEh.Destroy;
begin
  FDefHints.Free;
  FHints.Free;
  inherited Destroy;
end;

procedure TDataGridNavigatorPanelEh.InitItems;
var
  I: TNavigateBtnEh;
  Btn: TNavButtonEh;
  X: Integer;
begin
  MinBtnSize := Point(10, 10);
  X := 0;

  RecordsInfoPanel := TNavButtonEh.Create(Self);
  RecordsInfoPanel.Enabled := True;
  RecordsInfoPanel.SetBounds (X, 0, 0, 0);
  RecordsInfoPanel.Parent := Self;
  RecordsInfoPanel.OnPaint := PaintRecordsInfo;
  X := X + 24;

  NavButtonsDivider := TNavButtonEh.Create(Self);
  NavButtonsDivider.Enabled := True;
  NavButtonsDivider.SetBounds (X, 0, 0, 0);
  NavButtonsDivider.Parent := Self;
  NavButtonsDivider.OnPaint := PaintDivider;
  X := X + 7;

  for I := Low(NavButtons) to High(NavButtons) do
  begin
    Btn := TNavButtonEh.Create(Self);
    Btn.Index := I;
    Btn.Visible := I in FVisibleButtons;
    Btn.Enabled := True;
    Btn.SetBounds(X, 0, 0, 0);
    Btn.Enabled := False;
    Btn.Enabled := True;
    Btn.OnDown := ClickHandler;
    Btn.OnMouseDown := BtnMouseDown;
    Btn.Parent := Self;
    NavButtons[I] := Btn;
    X := X + MinBtnSize.X;
  end;
  NavButtons[TNavigateBtnEh.Prior].AutoRepeat := True;
  NavButtons[TNavigateBtnEh.Next].AutoRepeat := True;

  FindEditDivider := TNavButtonEh.Create(Self);
  FindEditDivider.Enabled := True;
  FindEditDivider.SetBounds(X, 0, 0, 0);
  FindEditDivider.Parent := Self;
  FindEditDivider.OnPaint := PaintDivider;
  X := X + 7;

  SelectionInfoDivider := TNavButtonEh.Create(Self);
  SelectionInfoDivider.Enabled := True;
  SelectionInfoDivider.SetBounds (X, 0, 0, 0);
  SelectionInfoDivider.Parent := Self;
  SelectionInfoDivider.OnPaint := PaintDivider;
  X := X + 7;

  SelectionInfoPanel := TDataGridSelectionInfoPanelEh.Create(Self);
  SelectionInfoPanel.Enabled := True;
  SelectionInfoPanel.SetBounds (X, 0, 0, 0);
  SelectionInfoPanel.Parent := Self;

  FirstImageItem := nil;
  PriorImageItem := nil;
  NextImageItem := nil;
  LastImageItem := nil;
  InsertImageItem := nil;
  DeleteImageItem := nil;
  EditImageItem := nil;
  PostImageItem := nil;
  CancelImageItem := nil;
  RefreshImageItem := nil;
end;


procedure TDataGridNavigatorPanelEh.PostGridSelectionChanged;
begin
  if FAsyncTimer = nil then
  begin
    FAsyncTimer := TTimer.Create(Self);
    FAsyncTimer.Interval := 100;
  end;
  FAsyncTimer.OnTimer := DoAsyncTimer;
  FAsyncTimer.Enabled := True;
end;

procedure TDataGridNavigatorPanelEh.DoAsyncTimer(Sender: TObject);
begin
  GridSelectionChangedAsync();
  FAsyncTimer.Enabled := False;
end;

procedure TDataGridNavigatorPanelEh.GridSelectionChangedAsync;
begin
  if TGridSBItemEh.SelAggregationInfo in VisibleItems then
  begin
    SelectionInfoPanel.RecalcAggrInfo();
    if SelectionInfoPanel.HasAggrData
      then SelectionInfoPanel.Visible := True
      else SelectionInfoPanel.Visible := False;
    SelectionInfoDivider.Visible := SelectionInfoPanel.Visible;

    SelectionInfoPanel.Width := CalcWidthSelectionInfoPanel;
    ControlInvalidate(SelectionInfoPanel);

    ResetWidth;
    TControlCrack(Parent).Realign;
  end;
end;

procedure TDataGridNavigatorPanelEh.GridSelectionChanged;
var
  OldWidth: Single;
begin
  if RecordsInfoPanel.Visible {and HandleAllocated} then
  begin
    OldWidth := RecordsInfoPanel.Width;
    RecordsInfoPanel.Width := CalcWidthForRecordsInfoPanel;
    ControlInvalidate(RecordsInfoPanel);
    if OldWidth <> RecordsInfoPanel.Width then
      TDataGridScrollBarPanelControlEh(Parent).Resize;
  end;

  if (TGridSBItemEh.SelAggregationInfo in VisibleItems) {and HandleAllocated} then
  begin
    PostGridSelectionChanged;
  end else
  begin
    SelectionInfoPanel.Visible := False;
    SelectionInfoDivider.Visible := SelectionInfoPanel.Visible;
    ControlInvalidate(SelectionInfoPanel);
  end;
end;

function TDataGridNavigatorPanelEh.GetSelectionInfoPanelText: String;
begin
  Result := '?';
end;

procedure TDataGridNavigatorPanelEh.InitHints;
var
  I: Integer;
  J: TNavigateBtnEh;
  BtnHintId: array[TNavigateBtnEh] of String;
begin
  BtnHintId[TNavigateBtnEh.First] := EhLibLanguageConsts.FirstRecordEh;
  BtnHintId[TNavigateBtnEh.Prior] := EhLibLanguageConsts.PriorRecordEh;
  BtnHintId[TNavigateBtnEh.Next] := EhLibLanguageConsts.NextRecordEh;
  BtnHintId[TNavigateBtnEh.Last] := EhLibLanguageConsts.LastRecordEh;
  BtnHintId[TNavigateBtnEh.Insert] := EhLibLanguageConsts.InsertRecordEh;
  BtnHintId[TNavigateBtnEh.Delete] := EhLibLanguageConsts.DeleteRecordEh;
  BtnHintId[TNavigateBtnEh.Edit] := EhLibLanguageConsts.EditRecordEh;
  BtnHintId[TNavigateBtnEh.Post] := EhLibLanguageConsts.PostEditEh;
  BtnHintId[TNavigateBtnEh.Cancel] := EhLibLanguageConsts.CancelEditEh;
  BtnHintId[TNavigateBtnEh.Refresh] := EhLibLanguageConsts.RefreshRecordEh;

  if not Assigned(FDefHints) then
    FDefHints := TStringList.Create;
  FDefHints.Clear;
  for J := Low(NavButtons) to High(NavButtons) do
    FDefHints.Add(BtnHintId[J]);
  for J := Low(NavButtons) to High(NavButtons) do
    NavButtons[J].Hint := FDefHints[Ord(J)];
  J := Low(NavButtons);
  for I := 0 to (FHints.Count - 1) do
  begin
    if FHints.Strings[I] <> '' then NavButtons[J].Hint := FHints.Strings[I];
    if J = High(NavButtons) then Exit;
    Inc(J);
  end;
end;

procedure TDataGridNavigatorPanelEh.HintsChanged(Sender: TObject);
begin
  InitHints;
end;

procedure TDataGridNavigatorPanelEh.SetHints(Value: TStrings);
begin
  if Value.Text = FDefHints.Text then
    FHints.Clear else
    FHints.Assign(Value);
end;

function TDataGridNavigatorPanelEh.GetHints: TStrings;
begin
  if (csDesigning in ComponentState) and not (csWriting in ComponentState) and
     not (csReading in ComponentState) and (FHints.Count = 0) then
    Result := FDefHints else
    Result := FHints;
end;

procedure TDataGridNavigatorPanelEh.GetChildren(Proc: TGetChildProc; Root: TComponent);
begin
end;

procedure TDataGridNavigatorPanelEh.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
end;

procedure TDataGridNavigatorPanelEh.CalcMinSize(var W, H: Integer);
var
  Count: Integer;
  I: TNavigateBtnEh;
begin
  if (csLoading in ComponentState) then Exit;
  if NavButtons[TNavigateBtnEh.First] = nil then Exit;

  Count := 0;
  for I := Low(NavButtons) to High(NavButtons) do
    if NavButtons[I].Visible then
      Inc(Count);
  if Count = 0 then Inc(Count);

  W := Max(W, Count * MinBtnSize.X);
  H := Max(H, MinBtnSize.Y);

  if Align = TAlignLayout.None then
    W := (W div Count) * Count;
end;

function TDataGridNavigatorPanelEh.OptimalWidth: Integer;
var
  I: TNavigateBtnEh;
  SPanW, SPanH: Single;
  ASearchPanelControl: TDataGridSearchPanelControlEhCrack;
begin
  ASearchPanelControl := TDataGridSearchPanelControlEhCrack(FSearchPanelControl);
  Result := 0;

  if RecordsInfoPanel.Visible then
    Inc(Result, Round(RecordsInfoPanel.Width));
  if NavButtonsDivider.Visible then
    Inc(Result, Round(NavButtonsDivider.Width));

  for I := Low(NavButtons) to High(NavButtons) do
  begin
    if NavButtons[I].Visible then
      Inc(Result, Round(Height));
  end;

  if SelectionInfoPanel.Visible then
  begin
    Inc(Result, Round(SelectionInfoDivider.Width));
    Inc(Result, Round(SelectionInfoPanel.Width));
  end;

  if (FSearchPanelControl <> nil) and FSearchPanelControl.Visible then
  begin
    SPanW := ASearchPanelControl.CalcAutoWidthForHeight(Round(Height));
    SPanH := ASearchPanelControl.Height;
    ASearchPanelControl.SetSize(SPanW, SPanH);
    Inc(Result, Round(SPanW));
  end;
end;

procedure TDataGridNavigatorPanelEh.ResetWidth;
var
  NewWidth: Integer;
begin
  NewWidth := OptimalWidth;
  if Parent is TDataGridScrollBarPanelControlEh  then
  begin
    if NewWidth > TDataGridScrollBarPanelControlEh(Parent).MaxSizeForExtraPanel then
      NewWidth := TDataGridScrollBarPanelControlEh(Parent).MaxSizeForExtraPanel;
  end;
  if NewWidth < 0 then NewWidth := 0;
  Width := NewWidth;
end;

procedure TDataGridNavigatorPanelEh.SetSearchPanelControl(const Value: TControl);
begin
  if FSearchPanelControl <> Value then
  begin
    if FSearchPanelControl <> nil then
      FSearchPanelControl.Parent := nil;
    FSearchPanelControl := Value;
    if FSearchPanelControl <> nil then
      FSearchPanelControl.Parent := Self;
  end;
end;

procedure TDataGridNavigatorPanelEh.Resize;
var
  NewWidth, NewHeight: Integer;
begin
  NewWidth := Round(Width) - 1;
  NewHeight := Round(Height) - 1;
  SetSize(NewWidth, NewHeight);
end;

procedure TDataGridNavigatorPanelEh.SetSize(var W: Integer; var H: Integer);
var
  I: TNavigateBtnEh;
  Space{, Temp, Remain}: Integer;
  X: Single;
  ASearchPanelControl: TDataGridSearchPanelControlEhCrack;

  procedure SetNavButton(NavB: TNavButtonEh);
  begin
    if NavB.Visible then
    begin
      Space := 0;
      NavB.SetBounds(X, 0, ButtonWidth + Space, H);
      X := X + ButtonWidth + Space;
    end
    else
      NavB.SetBounds(Width + 1, 0, ButtonWidth, Height);
  end;

begin
  ASearchPanelControl := TDataGridSearchPanelControlEhCrack(FSearchPanelControl);

  if (csLoading in ComponentState) then Exit;
  if NavButtons[TNavigateBtnEh.First] = nil then Exit;

  ButtonWidth := H;

  X := 0;

  if RecordsInfoPanel.Visible then
  begin
    RecordsInfoPanel.SetBounds(X, 0, RecordsInfoPanel.Width, H);
    X := X + RecordsInfoPanel.Width;
  end else
    RecordsInfoPanel.SetBounds(0, 0, 0, 0);

  if NavButtonsDivider.Visible then
  begin
    NavButtonsDivider.SetBounds(X, 0, DividerWidth, H);
    X := X + NavButtonsDivider.Width;
  end else
    NavButtonsDivider.SetBounds(0, 0, 0, 0);

  for I := TNavigateBtnEh.First to TNavigateBtnEh.Last do
    SetNavButton(NavButtons[I]);

  for I := TNavigateBtnEh.Insert to High(NavButtons) do
    SetNavButton(NavButtons[I]);

  if (ASearchPanelControl <> nil) then
    if ASearchPanelControl.Visible then
    begin
      ASearchPanelControl.SetBounds(X, 0, ASearchPanelControl.CalcAutoWidthForHeight(H), H);
      X := X + FSearchPanelControl.Width;
    end else
      ASearchPanelControl.SetBounds(0, 0, 0, 0);

  if SelectionInfoDivider.Visible then
  begin
    SelectionInfoDivider.SetBounds(X, 0, SelectionInfoDivider.Width, H);
    X := X + SelectionInfoDivider.Width;
  end else
    SelectionInfoDivider.SetBounds(0, 0, 0, 0);

  if SelectionInfoDivider.Visible then
  begin
    SelectionInfoPanel.SetBounds(X, 0, SelectionInfoPanel.Width, H);
    X := X + SelectionInfoPanel.Width;
  end else
    SelectionInfoPanel.SetBounds(0, 0, 0, 0);

  W := Round(X);
end;

procedure TDataGridNavigatorPanelEh.SetBounds(ALeft, ATop, AWidth, AHeight: Single);
var
  W, H: Single;
begin
  W := AWidth;
  H := AHeight;

  inherited SetBounds(ALeft, ATop, W, H);
end;

procedure TDataGridNavigatorPanelEh.ClickHandler(Sender: TObject;
  var AutoRepeat: Boolean; var Handled: Boolean);
begin
  NavBtnClick(TNavButtonEh(Sender).Index);
end;

procedure TDataGridNavigatorPanelEh.BtnMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  OldFocus: TNavigateBtnEh;
  VGrid: TCustomDataGridEhCrack;
begin
  OldFocus := FocusedButton;
  VGrid := TCustomDataGridEhCrack(Grid);
  VGrid.AcquireFocus;
  FocusedButton := TNavButtonEh(Sender).Index;

  if TabStop and {(GetFocus <> Handle) and} CanFocus then
  begin
  end
  else if TabStop and {(GetFocus = Handle) and} (OldFocus <> FocusedButton) then
  begin
    NavButtons[OldFocus].Invalidate;
    NavButtons[FocusedButton].Invalidate;
  end;
end;

procedure TDataGridNavigatorPanelEh.NavBtnClick(Index: TNavigateBtnEh);
var
  VGrid: TCustomDataGridEhCrack;
  Processed: Boolean;
begin
  VGrid := TCustomDataGridEhCrack(Grid);
  if (GridView <> nil) and (GridView.Active = True) then
  begin
    if not (csDesigning in ComponentState) and Assigned(FBeforeAction) then
      FBeforeAction(Self, Index);
    Processed := False;
    VGrid.NavigatorPanelButtonClick(Index, Processed);
    if not Processed then
    begin
      begin
        case Index of
          TNavigateBtnEh.Prior: GridView.GotoPriorRow;
          TNavigateBtnEh.Next: GridView.GotoNextRow;
          TNavigateBtnEh.First: GridView.GotoFirstRow;
          TNavigateBtnEh.Last: GridView.GotoLastRow;
          TNavigateBtnEh.Insert:
            if TDataGridAllowedOperationEh.Insert in VGrid.AllowedOperations
              then VGrid.DataInsert
              else VGrid.DataAppend;
          TNavigateBtnEh.Edit: TableView.EditCurrentRow;
          TNavigateBtnEh.Cancel: TableView.CancelCurrentRow;
          TNavigateBtnEh.Post: TableView.PostCurrentRow;
          TNavigateBtnEh.Delete:
            if VGrid.IsConfirmDelete then
              VGrid.ConfirmAndDeleteRows()
            else
              VGrid.DeleteCurrentRowOrRows();
        end;
      end;
    end;
  end;
  if not (csDesigning in ComponentState) and Assigned(FOnNavClick) then
    FOnNavClick(Self, Index);
end;

procedure TDataGridNavigatorPanelEh.TableViewDataChanged(AChangedType: TTableLinkEventTypeEh; NewIndex,
  OldIndex: Integer; ARowView: TTableRowViewEh);
begin
  DataChanged;
end;

procedure TDataGridNavigatorPanelEh.DataChanged;
var
  UpEnable, DnEnable: Boolean;
  VGrid: TCustomDataGridEhCrack;
  CanModify: Boolean;
  CurrentRowCanModify: Boolean;
begin
  if csDestroying in ComponentState then Exit;
  VGrid := TCustomDataGridEhCrack(Grid);
  UpEnable := Enabled and DataSetActive and not GridView.AtStartOfRowsList;
  DnEnable := Enabled and DataSetActive and not GridView.AtEndOfRowsList;
  CanModify := Enabled and DataSetActive and GridView.CanModify and not VGrid.ReadOnly;

  CurrentRowCanModify := (GridView.CurrentRow <> nil) and (GridView.CurrentRow.CanModify = True);

  NavButtons[TNavigateBtnEh.First].Enabled := UpEnable;
  NavButtons[TNavigateBtnEh.Prior].Enabled := UpEnable;
  NavButtons[TNavigateBtnEh.Next].Enabled := DnEnable;
  NavButtons[TNavigateBtnEh.Last].Enabled := DnEnable;

  NavButtons[TNavigateBtnEh.Delete].Enabled := VGrid.CanTableOperation(TDataGridAllowedOperationEh.Delete) and
                                               (GridView.CurrentRow is TDataGridDataRowEh);

  if (CurrentRowCanModify = True) and (TableView.CurrentRowView.Editing = True) then
    NavButtons[TNavigateBtnEh.Edit].Enabled := False
  else if (CurrentRowCanModify = True) and (TableView.CurrentRowView.Editing = False) then
    NavButtons[TNavigateBtnEh.Edit].Enabled := True
  else
    NavButtons[TNavigateBtnEh.Edit].Enabled := False;

  NavButtons[TNavigateBtnEh.Insert].Enabled :=
    CanModify and
    (VGrid.CanTableOperation(TDataGridAllowedOperationEh.Insert) or VGrid.CanTableOperation(TDataGridAllowedOperationEh.Append));

//  if not NavButtons[TNavigateBtnEh.Insert].Enabled and (GridView.Rows.Count > 0) then
//    NavButtons[TNavigateBtnEh.Edit].Enabled := False;

  NavButtons[TNavigateBtnEh.Post].Enabled := (CurrentRowCanModify = True) and (TableView.CurrentRowView.Editing = True);
  NavButtons[TNavigateBtnEh.Cancel].Enabled := (CurrentRowCanModify = True) and (TableView.CurrentRowView.Editing = True);
  NavButtons[TNavigateBtnEh.Refresh].Enabled := True;

  GridSelectionChanged;
end;

function TDataGridNavigatorPanelEh.DataSetActive: Boolean;
begin
  Result := GridView.Active;
end;

function TDataGridNavigatorPanelEh.GetTableView: TDataGridTableRowsViewEh;
var
  VGrid: TCustomDataGridEhCrack;
begin
  VGrid := TCustomDataGridEhCrack(Grid);
  Result := VGrid.TableView;
end;

function TDataGridNavigatorPanelEh.GetGridView: TDataGridRowsViewEh;
var
  VGrid: TCustomDataGridEhCrack;
begin
  VGrid := TCustomDataGridEhCrack(Grid);
  Result := VGrid.GridView;
end;

procedure TDataGridNavigatorPanelEh.Loaded;
var
  W, H: Integer;
begin
  inherited Loaded;
  W := Round(Width - 1);
  H := Round(Height - 1);
  SetSize(W, H);
  if (W <> Width) or (H <> Height) then
    inherited SetBounds (Left, Top, W, H);
  InitHints;
  DataChanged;
end;

procedure TDataGridNavigatorPanelEh.SelectionInfoPanelMouseUp(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
  Y: Single);
var
  i: Integer;
begin
  for i := 0 to Length(SelectionInfoPanelDataEh)-1 do
  begin
    if (X >= SelectionInfoPanelDataEh[i].Start) and (X <= SelectionInfoPanelDataEh[i].Finish) then
    begin
      Exit;
    end;
  end;
end;

procedure TDataGridNavigatorPanelEh.PaintDivider(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
begin
end;

procedure TDataGridNavigatorPanelEh.PaintRecordsInfo(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
var
  VGrid: TCustomDataGridEhCrack;
  PaintControl: TNavButtonEh;
  R: TRectF;
  Text: String;
begin
  VGrid := TCustomDataGridEhCrack(Grid);
  if VGrid.GridView.Active then
  begin
    PaintControl := TNavButtonEh(Sender);
    if PaintControl = RecordsInfoPanel then
    begin
      Canvas.Font.Family := VGrid.Font.Family;
      Canvas.Font.Size := GetFontSize(VGrid.Font) - 1;
      Canvas.Fill.Color := VGrid.FInternalFontColor;
      if VGrid.GridView.Active then
        Text := IntToStr(VGrid.GridView.Rows.Count);
      if VGrid.SelectedRows.Count > 0 then
        Text := Text + ' (' + IntToStr(VGrid.SelectedRows.Count) + ')';
      R := RectF(0, 0, PaintControl.Width, PaintControl.Height);
      Canvas.FillText(ARect, Text, False, 1, [], TTextAlign.Center, TTextAlign.Center);
    end;
  end;
end;

function TDataGridNavigatorPanelEh.CalcWidthForRecordsInfoPanel: Integer;
var
  VGrid: TCustomDataGridEhCrack;
  PaintControl: TNavButtonEh;
  Text: String;
begin
  Result := 0;
  VGrid := TCustomDataGridEhCrack(Grid);
  if VGrid.GridView.Active then
  begin
    PaintControl := RecordsInfoPanel;
    if (PaintControl.Canvas = nil) then Exit;

    PaintControl.Canvas.Font.Assign(VGrid.Font);
    PaintControl.Canvas.Font.Size := GetFontSize(PaintControl.Canvas.Font) - 1;
    Text := IntToStr(VGrid.GridView.Rows.Count);
    if VGrid.SelectedRows.Count > 0 then
      Text := Text + ' (' + IntToStr(VGrid.SelectedRows.Count) + ')';
    Result := Round(PaintControl.Canvas.TextWidth(' ' + Text + ' '));
  end;
end;

function TDataGridNavigatorPanelEh.CalcWidthSelectionInfoPanel: Single;
var
  VGrid: TCustomDataGridEhCrack;
begin
  Result := 0;
  VGrid := TCustomDataGridEhCrack(Grid);
  if VGrid.GridView.Active then
  begin
    Result := SelectionInfoPanel.CalcLayoutWidth();
  end;
end;

procedure TDataGridNavigatorPanelEh.Paint;
begin
  inherited Paint;
end;

procedure TDataGridNavigatorPanelEh.SetVisibleItems(const Value: TGridSBItemsEh);
var
  VGrid: TCustomDataGridEhCrack;
begin
  if FVisibleItems <> Value then
  begin
    FVisibleItems := Value;
    ResetVisibleControls;
    if (Grid <> nil) then
    begin
      VGrid := TCustomDataGridEhCrack(Grid);
      VGrid.Invalidate;
    end;
  end;
end;

procedure TDataGridNavigatorPanelEh.SetVisibleButtons(Value: TNavButtonSetEh);
begin
  if FVisibleButtons <> Value then
  begin
    FVisibleButtons := Value;
    ResetVisibleControls;
  end;
end;

procedure TDataGridNavigatorPanelEh.ResetVisibleControls;
var
  I: TNavigateBtnEh;
  NeedSeparator, NeedSeparator1: Boolean;
  Btn: TNavButtonEh;
begin
  NeedSeparator1 := False;
  RecordsInfoPanel.Visible := TGridSBItemEh.RecordsInfo in VisibleItems;
  NeedSeparator := RecordsInfoPanel.Visible;
  NavButtonsDivider.Visible := False;

  for I := Low(NavButtons) to High(NavButtons) do
  begin
    Btn := NavButtons[I];
    Btn.Visible := (I in FVisibleButtons) and (TGridSBItemEh.Navigator in VisibleItems);
    if Btn.Visible then
      NeedSeparator1 := True;
    if NeedSeparator and Btn.Visible then
      NavButtonsDivider.Visible := True;
  end;

  if NeedSeparator1 then NeedSeparator := True;

  if (SearchPanelControl <> nil) and NeedSeparator
    then FindEditDivider.Visible := True
    else FindEditDivider.Visible := False;

  GridSelectionChanged;

  TDataGridScrollBarPanelControlEh(Owner).Resize;
  Invalidate;
end;

function TDataGridNavigatorPanelEh.DividerWidth: Integer;
begin
  Result := 7;
end;

procedure TDataGridNavigatorPanelEh.SetBorderColor(const Value: TAlphaColor);
begin
  if Value <> FBorderColor then
  begin
    FBorderColor := Value;
    Invalidate;
  end;
end;

function TDataGridNavigatorPanelEh.CheckConfirmDelete: Boolean;
var
  VGrid: TCustomDataGridEhCrack;
begin
  VGrid := TCustomDataGridEhCrack(Grid);
  Result := VGrid.EditActions.ConfirmDelete;
end;

procedure TDataGridNavigatorPanelEh.VisibleChanged;
begin
  inherited VisibleChanged;
  TDataGridScrollBarPanelControlEh(Owner).Resize;
  TDataGridScrollBarPanelControlEh(Owner).Realign;
end;

function TDataGridNavigatorPanelEh.GetFirstImageItem: TResourceImageItemEh;
begin
  Result := NavButtons[TNavigateBtnEh.First].ResourceImageItem;
end;

procedure TDataGridNavigatorPanelEh.SetFirstImageItem(const Value: TResourceImageItemEh);
begin
  if Value = nil
    then NavButtons[TNavigateBtnEh.First].ResourceImageItem := EhLibImageResources.GridScrollBarNavFirstImageItem
    else NavButtons[TNavigateBtnEh.First].ResourceImageItem := Value;
end;

function TDataGridNavigatorPanelEh.GetPriorImageItem: TResourceImageItemEh;
begin
  Result := NavButtons[TNavigateBtnEh.Prior].ResourceImageItem;
end;

procedure TDataGridNavigatorPanelEh.SetPriorImageItem(const Value: TResourceImageItemEh);
begin
  if Value = nil
    then NavButtons[TNavigateBtnEh.Prior].ResourceImageItem := EhLibImageResources.GridScrollBarNavPriorImageItem
    else NavButtons[TNavigateBtnEh.Prior].ResourceImageItem := Value;
end;

function TDataGridNavigatorPanelEh.GetNextImageItem: TResourceImageItemEh;
begin
  Result := NavButtons[TNavigateBtnEh.Next].ResourceImageItem;
end;

procedure TDataGridNavigatorPanelEh.SetNextImageItem(
  const Value: TResourceImageItemEh);
begin
  if Value = nil
    then NavButtons[TNavigateBtnEh.Next].ResourceImageItem := EhLibImageResources.GridScrollBarNavNextImageItem
    else NavButtons[TNavigateBtnEh.Next].ResourceImageItem := Value;
end;

function TDataGridNavigatorPanelEh.GetLastImageItem: TResourceImageItemEh;
begin
  Result := NavButtons[TNavigateBtnEh.Last].ResourceImageItem;
end;

procedure TDataGridNavigatorPanelEh.SetLastImageItem(
  const Value: TResourceImageItemEh);
begin
  if Value = nil
    then NavButtons[TNavigateBtnEh.Last].ResourceImageItem := EhLibImageResources.GridScrollBarNavLastImageItem
    else NavButtons[TNavigateBtnEh.Last].ResourceImageItem := Value;
end;

function TDataGridNavigatorPanelEh.GetInsertImageItem: TResourceImageItemEh;
begin
  Result := NavButtons[TNavigateBtnEh.Insert].ResourceImageItem;
end;

procedure TDataGridNavigatorPanelEh.SetInsertImageItem(const Value: TResourceImageItemEh);
begin
  if Value = nil
    then NavButtons[TNavigateBtnEh.Insert].ResourceImageItem := EhLibImageResources.GridScrollBarNavInsertImageItem
    else NavButtons[TNavigateBtnEh.Insert].ResourceImageItem := Value;
end;

function TDataGridNavigatorPanelEh.GetDeleteImageItem: TResourceImageItemEh;
begin
  Result := NavButtons[TNavigateBtnEh.Delete].ResourceImageItem;
end;

procedure TDataGridNavigatorPanelEh.SetDeleteImageItem(const Value: TResourceImageItemEh);
begin
  if Value = nil
    then NavButtons[TNavigateBtnEh.Delete].ResourceImageItem := EhLibImageResources.GridScrollBarNavDeleteImageItem
    else NavButtons[TNavigateBtnEh.Delete].ResourceImageItem := Value;
end;

function TDataGridNavigatorPanelEh.GetEditImageItem: TResourceImageItemEh;
begin
  Result := NavButtons[TNavigateBtnEh.Edit].ResourceImageItem;
end;

procedure TDataGridNavigatorPanelEh.SetEditImageItem(const Value: TResourceImageItemEh);
begin
  if Value = nil
    then NavButtons[TNavigateBtnEh.Edit].ResourceImageItem := EhLibImageResources.GridScrollBarNavEditImageItem
    else NavButtons[TNavigateBtnEh.Edit].ResourceImageItem := Value;
end;

function TDataGridNavigatorPanelEh.GetPostImageItem: TResourceImageItemEh;
begin
  Result := NavButtons[TNavigateBtnEh.Post].ResourceImageItem;
end;

procedure TDataGridNavigatorPanelEh.SetPostImageItem(const Value: TResourceImageItemEh);
begin
  if Value = nil
    then NavButtons[TNavigateBtnEh.Post].ResourceImageItem := EhLibImageResources.GridScrollBarNavPostImageItem
    else NavButtons[TNavigateBtnEh.Post].ResourceImageItem := Value;
end;

function TDataGridNavigatorPanelEh.GetCancelImageItem: TResourceImageItemEh;
begin
  Result := NavButtons[TNavigateBtnEh.Cancel].ResourceImageItem;
end;

procedure TDataGridNavigatorPanelEh.SetCancelImageItem(const Value: TResourceImageItemEh);
begin
  if Value = nil
    then NavButtons[TNavigateBtnEh.Cancel].ResourceImageItem := EhLibImageResources.GridScrollBarNavCancelImageItem
    else NavButtons[TNavigateBtnEh.Cancel].ResourceImageItem := Value;
end;

function TDataGridNavigatorPanelEh.GetRefreshImageItem: TResourceImageItemEh;
begin
  Result := NavButtons[TNavigateBtnEh.Refresh].ResourceImageItem;
end;

procedure TDataGridNavigatorPanelEh.SetRefreshImageItem(const Value: TResourceImageItemEh);
begin
  if Value = nil
    then NavButtons[TNavigateBtnEh.Refresh].ResourceImageItem := EhLibImageResources.GridScrollBarNavRefreshImageItem
    else NavButtons[TNavigateBtnEh.Refresh].ResourceImageItem := Value;
end;

function TDataGridNavigatorPanelEh.GetClientRect: TRect;
begin
  Result := Rect(0, 0, Round(Width), Round(Height));
end;

function TDataGridNavigatorPanelEh.GetDefaultStyleLookupName: string;
begin
  Result := 'PushPanel';
end;

function TDataGridNavigatorPanelEh.GetGrid: TControl;
begin
  Result := TCustomDataGridEhCrack((Owner as TDataGridScrollBarPanelControlEh).Grid);
end;

{$ENDREGION 'TDataGridNavigatorPanelEh'}

{$REGION 'TDataGridSelectionInfoPanelEh'}

{ TDataGridSelectionInfoPanelEh }

constructor TDataGridSelectionInfoPanelEh.Create(AOwner: TComponent);
var
  FI: TAggrFunctionEh;
begin
  inherited Create(AOwner);

  for FI := Low(TAggrFunctionEh) to High(TAggrFunctionEh) do
  begin
    FAggrTexts[FI] := CreateInitTextControl(FI);
  end;
end;

destructor TDataGridSelectionInfoPanelEh.Destroy;
begin

  inherited Destroy;
end;

function TDataGridSelectionInfoPanelEh.GetGridNavigatorPanel: TDataGridNavigatorPanelEh;
begin
  Result := TDataGridNavigatorPanelEh(Owner);
end;

function TDataGridSelectionInfoPanelEh.GetHasAggrData: Boolean;
begin
  if FResultArr[TAggrFunctionEh.Count].AsType<TBcd>() > 1
    then Result := True
    else Result := False;
end;

function TDataGridSelectionInfoPanelEh.CreateInitTextControl(AggrFunc: TAggrFunctionEh): TText;
begin
  Result := TText.Create(Self);
  Result.Parent := Self;
  Result.Text := GetEnumName(TypeInfo(TAggrFunctionEh), Ord(AggrFunc));
  Result.AutoSize := True;
  Result.WordWrap := False;
  Result.Align := TAlignLayout.Left;
  Result.VertTextAlign := TTextAlign.Center;
  Result.Margins.Right := 4;
end;

procedure TDataGridSelectionInfoPanelEh.PrepareForPaint;
var
  FI: TAggrFunctionEh;
  VGrid: TCustomDataGridEhCrack;
begin
  VGrid := TCustomDataGridEhCrack(GridNavigatorPanel.Grid);
  inherited PrepareForPaint;

  for FI := Low(TAggrFunctionEh) to High(TAggrFunctionEh) do
  begin
    FAggrTexts[FI].TextSettings.FontColor := VGrid.FInternalFontColor;
  end;
end;

function TDataGridSelectionInfoPanelEh.CalcLayoutWidth: Single;
var
  I: Integer;
  TotalWidth: Single;
  Child: TControl;
begin
  TotalWidth := 0;

  for I := 0 to ChildrenCount - 1 do
  begin
    if (Children[I] is TControl) and (TControl(Children[I]).Align = TAlignLayout.Left)  then
    begin
      Child := TControl(Children[I]);
      if Child.Visible then
        TotalWidth := TotalWidth + Child.Width + Child.Margins.Left + Child.Margins.Right;
    end;
  end;

  Result := TotalWidth;
  if Result > 0 then
    Result := Result + 4;
end;

procedure TDataGridSelectionInfoPanelEh.RecalcAggrInfo;
var
  FI: TAggrFunctionEh;
  StrValue: String;
begin
  GetGridAggrInfo(FResultArr);

  for FI := Low(TAggrFunctionEh) to High(TAggrFunctionEh) do
  begin
    if FResultArr[FI].IsEmpty = False then
    begin
      StrValue := ValueToString(FResultArr[FI]);
      FAggrTexts[FI].Text := GetEnumName(TypeInfo(TAggrFunctionEh), Ord(FI)) + ': ' + StrValue;
      FAggrTexts[FI].Visible := True;
    end else
    begin
      FAggrTexts[FI].Text := '';
      FAggrTexts[FI].Visible := False;
    end;
  end;
end;

procedure TDataGridSelectionInfoPanelEh.GetGridAggrInfo(var ResultArr: TAggrResultArr);
var
  FromColIdx: Integer;
  ToColIdx: Integer;
  FromRowIdx: Integer;
  ToRowIdx: Integer;
  CurColIdx: Integer;
  CurRowIdx: Integer;
  Grid: TCustomDataGridEhCrack;
  NumCount: Integer;
  ARow: TDataGridRowEh;
  AColumn: TDataGridBaseColumnEh;
  BcdValue: TValue;

  procedure InitVars;
  begin
    if Grid.Selection.SelectionType = TDataGridSelectionTypeEh.Rectangle then
    begin
      FromRowIdx := Grid.Selection.GetSelectedRect.Top;
      ToRowIdx := Grid.Selection.GetSelectedRect.Bottom;
      FromColIdx := Grid.Selection.GetSelectedRect.Left;
      ToColIdx := Grid.Selection.GetSelectedRect.Right;
    end else if Grid.Selection.SelectionType = TDataGridSelectionTypeEh.Columns then
    begin
      FromRowIdx := 0;
      ToRowIdx := Grid.VisibleRows.Count - 1;
      FromColIdx := 0;
      ToColIdx := Grid.Selection.Columns.Count - 1;
    end else if Grid.Selection.SelectionType = TDataGridSelectionTypeEh.All then
    begin
      FromRowIdx := 0;
      ToRowIdx := Grid.VisibleRows.Count - 1;
      FromColIdx := 0;
      ToColIdx := Grid.VisibleColumns.Count - 1;
    end else if Grid.Selection.SelectionType = TDataGridSelectionTypeEh.RecordBookmarks then
    begin
      FromRowIdx := 0;
      ToRowIdx := Grid.Selection.Rows.Count - 1;
      FromColIdx := 0;
      ToColIdx := Grid.VisibleColumns.Count - 1;
    end else
    begin
      FromRowIdx := 0;
      ToRowIdx := -1;
      FromColIdx := 0;
      ToColIdx := -1;
    end;
  end;

  procedure ResetCol;
  begin
    CurColIdx := FromColIdx;
    if Grid.Selection.SelectionType = TDataGridSelectionTypeEh.Columns
      then AColumn := TDataGridBaseColumnEh(Grid.Selection.Columns[CurColIdx])
      else AColumn := Grid.VisibleColumns[CurColIdx];
  end;

  function NextCol: Boolean;
  begin
    CurColIdx := CurColIdx + 1;
    Result := (CurColIdx <= ToColIdx);
    if Result then
    begin
      if Grid.Selection.SelectionType = TDataGridSelectionTypeEh.Columns
        then AColumn := TDataGridBaseColumnEh(Grid.Selection.Columns[CurColIdx])
        else AColumn := Grid.VisibleColumns[CurColIdx];
    end else
    begin
      AColumn := nil;
    end;
  end;

  function ResetRow: Boolean;
  begin
    Result := False;
    CurRowIdx := FromRowIdx;
    if Grid.Selection.SelectionType = TDataGridSelectionTypeEh.RecordBookmarks
      then ARow := Grid.Selection.Rows[CurRowIdx]
      else ARow := Grid.VisibleRows[CurRowIdx];
  end;

  function NextRow: Boolean;
  begin
    CurRowIdx := CurRowIdx + 1;
    Result := (CurRowIdx <= ToRowIdx);
    if Result then
    begin
      if Grid.Selection.SelectionType = TDataGridSelectionTypeEh.RecordBookmarks
        then ARow := Grid.Selection.Rows[CurRowIdx]
        else ARow := Grid.VisibleRows[CurRowIdx];
    end else
    begin
      ARow := nil;
    end;
  end;

  procedure CalcStep;
  var
    v: TValue;
  begin
    if (AColumn <> nil) and (ARow <> nil) then
      v := AColumn.GetRowValue(ARow)
    else
      v := TValue.Empty;

    if not ValueIsNullOrEmpty(v) and
       not EhLibUtils.SameValue(v, '')
    then
      ResultArr[TAggrFunctionEh.Count] := TValue.From<TBcd>(ResultArr[TAggrFunctionEh.Count].AsType<TBcd>() + 1);

    if ValueIsNumeric(v) then
    begin
      NumCount := NumCount + 1;
      BcdValue := CastValueToBcdValue(v);

      if ValueIsNullOrEmpty(ResultArr[TAggrFunctionEh.Sum])
        then ResultArr[TAggrFunctionEh.Sum] := BcdValue
        else ResultArr[TAggrFunctionEh.Sum] := TValue.From<TBcd>(ResultArr[TAggrFunctionEh.Sum].AsType<TBcd>() + BcdValue.AsType<TBcd>());

      if ValueIsNullOrEmpty(ResultArr[TAggrFunctionEh.Min]) then
        ResultArr[TAggrFunctionEh.Min] := BcdValue
      else if EhLibUtils.CompareValue(ResultArr[TAggrFunctionEh.Min], v) = vrGreaterThan then
        ResultArr[TAggrFunctionEh.Min] := BcdValue;

      if ValueIsNullOrEmpty(ResultArr[TAggrFunctionEh.Max]) then
        ResultArr[TAggrFunctionEh.Max] := BcdValue
      else if EhLibUtils.CompareValue(ResultArr[TAggrFunctionEh.Max], BcdValue) = vrLessThan then
        ResultArr[TAggrFunctionEh.Max] := BcdValue;
    end;
  end;

begin
  ResultArr[TAggrFunctionEh.Sum] := TValue.Empty;
  ResultArr[TAggrFunctionEh.Count] := TValue.From<TBcd>(0);
  ResultArr[TAggrFunctionEh.Avg] := TValue.Empty;
  ResultArr[TAggrFunctionEh.Min] := TValue.Empty;
  ResultArr[TAggrFunctionEh.Max] := TValue.Empty;
  NumCount := 0;

  Grid := TCustomDataGridEhCrack(GridNavigatorPanel.Grid);

  InitVars();
  if FromRowIdx > ToRowIdx then Exit;

  ResetRow;
  while True do
  begin
    ResetCol;
    while True do
    begin
      CalcStep;
      if NextCol = False then
        Break;
    end;
    if NextRow = False then
      Break;
  end;

  if not ValueIsNullOrEmpty(ResultArr[TAggrFunctionEh.Sum]) then
    ResultArr[TAggrFunctionEh.Avg] := TValue.From<TBcd>(ResultArr[TAggrFunctionEh.Sum].AsType<TBcd>() / NumCount);
end;

{$ENDREGION 'TDataGridSelectionInfoPanelEh'}

{$REGION 'TNavButtonEh'}

{TNavButtonEh}

constructor TNavButtonEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Locked := True;
end;

destructor TNavButtonEh.Destroy;
begin
  inherited Destroy;
end;

procedure TNavButtonEh.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TNavButtonEh.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited MouseUp (Button, Shift, X, Y);
end;

{$ENDREGION 'TNavButtonEh'}

{$REGION 'TDataGridColumnOptionsEh'}

{ TDataGridColumnOptionsEh }

constructor TDataGridColumnOptionsEh.Create(AGrid: TControl);
begin
  inherited Create(AGrid);
  FDynaColumnOptions := TDynaColumnOptionsEh.Create(Self);
  FAllowMove := True;
  FAllowResize := True;
  FAllowFreezeLeft := False;
  FAllowFreezeRight := False;
  TCustomDataGridEhCrack(Self.FGrid).Options := TCustomDataGridEhCrack(Self.FGrid).Options + [TGridOptionEh.ColSizing];
end;

destructor TDataGridColumnOptionsEh.Destroy;
begin
  FreeAndNil(FDynaColumnOptions);
  inherited Destroy;
end;

procedure TDataGridColumnOptionsEh.HeightAutoExpandChanged;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Self.FGrid);
  Grid.FUpdatingDataRowHeightsNeeded := True;
  inherited HeightAutoExpandChanged;
end;

procedure TDataGridColumnOptionsEh.SetAllowResize(const Value: Boolean);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Self.FGrid);
  if FAllowResize <> Value then
  begin
    FAllowResize := Value;
    if FAllowResize then
      Grid.Options := Grid.Options + [TGridOptionEh.ColSizing]
    else
      Grid.Options := Grid.Options - [TGridOptionEh.ColSizing];
  end;
end;

procedure TDataGridColumnOptionsEh.SetColSizeUnit(const Value: TGridColSizeUnitEh);
begin
  if (FColSizeUnit <> Value) then
  begin
    FColSizeUnit := Value;
    Changed();
  end;
end;

procedure TDataGridColumnOptionsEh.SetDynaColumnOptions(const Value: TDynaColumnOptionsEh);
begin
  FDynaColumnOptions.Assign(Value);
end;

{$ENDREGION 'TDataGridColumnOptionsEh'}

{$REGION 'TCustomDataGridCanSelectRowParamsEh'}

{ TCustomDataGridCanSelectRowParamsEh }

constructor TCustomDataGridCanSelectRowParamsEh.Create;
begin

end;

constructor TCustomDataGridCanSelectRowParamsEh.Create(AGrid: TControl; ARow: TDataGridRowEh);
begin
  Create;
  Reset(AGrid, ARow);
end;

procedure TCustomDataGridCanSelectRowParamsEh.DefaultCanSelectRow(Params: TCustomDataGridCanSelectRowParamsEh);
var
  VGrid: TCustomDataGridEhCrack;
begin
  VGrid := TCustomDataGridEhCrack(FGrid);
  VGrid.DefaultCanSelectCurrentRow(Params);
end;

procedure TCustomDataGridCanSelectRowParamsEh.Reset(AGrid: TControl; ARow: TDataGridRowEh);
begin
  FGrid := AGrid;
  FRow := ARow;
  FCanSelectRow := False;
  FHandled := False;
end;

{$ENDREGION 'TCustomDataGridCanSelectRowParamsEh'}

{$REGION 'TDataGridSelectionOptionsEh'}

{ TDataGridSelectionOptionsEh }

constructor TDataGridSelectionOptionsEh.Create(AGrid: TControl);
begin
  inherited Create();
  FGrid := AGrid;
  FAllowedSelections := [TDataGridSelectionTypeEh.RecordBookmarks..TDataGridSelectionTypeEh.All];
  FRowSelect := False;
  FKeepSelection := False;
  FDataCellSelectionTime := TDataCellSelectionTimeEh.OnMouseMove;
  FRowHighlight := True;
  FAlwaysShow := True
end;

destructor TDataGridSelectionOptionsEh.Destroy;
begin
  inherited Destroy;
end;

procedure TDataGridSelectionOptionsEh.SetAllowedSelections(
  const Value: TDataGridAllowedSelectionsEh);
var
  AGrid: TCustomDataGridEhCrack;
begin
  AGrid := TCustomDataGridEhCrack(FGrid);
  if FAllowedSelections <> Value then
  begin
    FAllowedSelections := Value;
    if (AGrid.Selection.SelectionType <> TDataGridSelectionTypeEh.Non) and
      not (AGrid.Selection.SelectionType in FAllowedSelections)
    then
      AGrid.Selection.Clear;
  end;
end;

procedure TDataGridSelectionOptionsEh.SetAlwaysShow(const Value: Boolean);
var
  AGrid: TCustomDataGridEhCrack;
begin
  AGrid := TCustomDataGridEhCrack(FGrid);
  if FAlwaysShow <> Value then
  begin
    FAlwaysShow := Value;
    AGrid.Invalidate;
  end;
end;

procedure TDataGridSelectionOptionsEh.SetRowHighlight(const Value: Boolean);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if FRowHighlight <> Value then
  begin
    FRowHighlight := Value;
    Grid.UpdateBaseOptions();
  end;
end;

procedure TDataGridSelectionOptionsEh.SetRowSelect(const Value: Boolean);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if FRowSelect <> Value then
  begin
    FRowSelect := Value;
    Grid.UpdateBaseOptions();
  end;
end;

{$ENDREGION 'TDataGridSelectionOptionsEh'}

{$REGION 'TDataGridMouseStateManageEh'}

{ TDataGridMouseStateManageEh }

constructor TDataGridMouseStateManagerEh.Create(AGrid: TControl);
begin
  inherited Create(AGrid);

  FComplexTitleMovingState := TDataGridMouseComplexTitleMovingStateEh.Create(AGrid);
  FOptimizeColWidths := TDataGridOptimizeColWidthsMouseStateEh.Create(AGrid);
  FGroupDescriptionMovingState := TDataGridGroupDescriptionMovingStateEh.Create(AGrid);
end;

destructor TDataGridMouseStateManagerEh.Destroy;
begin
  FreeAndNil(FComplexTitleMovingState);
  FreeAndNil(FOptimizeColWidths);
  FreeAndNil(FGroupDescriptionMovingState);
  inherited Destroy;
end;

{$ENDREGION 'TDataGridMouseStateManageEh'}

{$REGION 'TDataGridSelectedRowsEh'}

{ TDataGridSelectedRowsEh }

constructor TDataGridSelectedRowsEh.Create(AGridSelection: TDataGridSelectionEh);
begin
  inherited Create();
  FGridSelection := AGridSelection;
  FList := TList<TDataGridRowEh>.Create;
end;

destructor TDataGridSelectedRowsEh.Destroy;
begin
  FreeAndNil(FList);
  inherited Destroy;
end;

function TDataGridSelectedRowsEh.GetItem(Index: Integer): TDataGridRowEh;
begin
  if FIsObsolete then
    UpdateList;
  Result := FList[Index];
end;

function TDataGridSelectedRowsEh.GetCount: Integer;
begin
  if FIsObsolete then
    UpdateList;
  Result := FList.Count;
end;

procedure TDataGridSelectedRowsEh.UpdateList;
var
  I: Integer;
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGridSelection.FGrid);

  FList.Clear;
  for I := 0 to Grid.VisibleRows.Count - 1 do
  begin
    if Grid.VisibleRows[I].IsSelected then
      FList.Add(Grid.VisibleRows[I]);
  end;

  FIsObsolete := False;
end;

{$ENDREGION 'TDataGridSelectedRowsEh'}

{$REGION 'TDataGridCalcDataRowHeightParamsEh'}

{ TDataGridCalcDataRowHeightParamsEh }

constructor TDataGridCalcDataRowHeightParamsEh.Create;
begin
  inherited Create;
end;

constructor TDataGridCalcDataRowHeightParamsEh.Create(AGrid: TControl; ADataAreaRowIndex: Integer);
begin
  Create;
  FGrid := AGrid;
  FDataAreaRowIndex := ADataAreaRowIndex;
end;

function TDataGridCalcDataRowHeightParamsEh.DefaultCalcRowHeight(Params: TDataGridCalcDataRowHeightParamsEh): Integer;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Params.Grid);
  Result := Grid.DefaultCalcDataRowHeight(Params);
end;

procedure TDataGridCalcDataRowHeightParamsEh.Reset(AGrid: TControl; ADataAreaRowIndex: Integer);
begin
  FGrid := AGrid;
  FDataAreaRowIndex := ADataAreaRowIndex;
end;

{$ENDREGION 'TDataGridCalcDataRowHeightParamsEh'}

{$REGION 'TDynaColumnOptionsEh'}

{ TDynaColumnOptionsEh }

constructor TDynaColumnOptionsEh.Create(AColumnOptions: TDataGridColumnOptionsEh);
begin
  inherited Create;
  FColumnOptions := AColumnOptions;
  FMinInitWidth := 40;
  FMaxInitWidth := 400;
  FUseTitleToInitWidth := True;
  FUseDataRowsToInitWidth := True;
end;

destructor TDynaColumnOptionsEh.Destroy;
begin

  inherited Destroy;
end;

{$ENDREGION 'TDynaColumnOptionsEh'}

{$REGION 'TDataGridStaticColumnsContainerEh'}

{ TDataGridStaticColumnsContainerEh }

constructor TDataGridStaticColumnsContainerEh.Create(AOwner: TComponent);
begin
  inherited Create;
  FGrid := AOwner as TCustomDataAxisGridEh;
end;

destructor TDataGridStaticColumnsContainerEh.Destroy;
begin
  inherited Destroy;
end;

procedure TDataGridStaticColumnsContainerEh.AddChildren(AParent: TComponent; AChildren: TComponent);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if Grid.Title.IsComplexTitle then
  begin
    if AChildren is TDataGridBaseColumnEh then
      Grid.Title.ComplexTitleTree.AddColumn(nil, TDataGridBaseColumnEh(AChildren))
    else if AChildren is TDataGridSuperTitleEh then
      Grid.Title.ComplexTitleTree.AddSuperTitle(nil, TDataGridSuperTitleEh(AChildren))
  end else
  begin
    Grid.StaticColumns.Add(AChildren as TDataGridBaseColumnEh)
  end;
end;

function TDataGridStaticColumnsContainerEh.GetChildren(Index: Integer): TComponent;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if Grid.Title.IsComplexTitle then
    Result := Grid.Title.ComplexTitleTree.RootNode.Items[Index].NodeObject
  else
    Result := Grid.StaticColumns[Index];
end;

function TDataGridStaticColumnsContainerEh.GetChildrenCount: Integer;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if Grid.Title.IsComplexTitle then
    Result := Grid.Title.ComplexTitleTree.RootNode.Count
  else
    Result := Grid.StaticColumns.Count;
end;

function TDataGridStaticColumnsContainerEh.GetChildrenIndex(AChildren: TComponent): Integer;
var
  Grid: TCustomDataGridEhCrack;
  Column: TDataGridBaseColumnEh;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if Grid.Title.IsComplexTitle then
  begin
    if AChildren is TDataGridSuperTitleEh then
      Result := TDataGridSuperTitleEh(AChildren).ComplexTitleNode.Index
    else
      Result := (AChildren as TDataGridBaseColumnEh).Title.ComplexTitleNode.Index;
  end else
  begin
    Column := AChildren as TDataGridBaseColumnEh;
    Result := Column.StaticIndex;
  end;
end;

function TDataGridStaticColumnsContainerEh.GetParentItemCount(AParent: TComponent): Integer;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if Grid.Title.IsComplexTitle then
  begin
    if AParent is TCustomDataGridEh then
      Result := ChildrenCount
    else if AParent is TDataGridSuperTitleEh then
      Result := TDataGridSuperTitleEh(AParent).ComplexTitleNode.Count
    else
      Result := 0;
  end else
  begin
    if AParent is TCustomDataGridEh then
      Result := ChildrenCount
    else
      Result := 0;
  end;
end;

function TDataGridStaticColumnsContainerEh.GetChildItem(AParent: TComponent; ItemIndex: Integer): TComponent;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if Grid.Title.IsComplexTitle then
  begin
    if AParent is TCustomDataGridEh then
      Result := Children[ItemIndex]
    else if AParent is TDataGridSuperTitleEh then
      Result := TDataGridSuperTitleEh(AParent).ComplexTitleNode.Items[ItemIndex].NodeObject
    else
      raise Exception.Create('TDataGridStaticColumnsContainerEh.GetParentItemCount: Unexpected type of parameter Parent "' + AParent.ClassName + '"');
  end else
  begin
    if AParent is TCustomDataGridEh then
      Result := Children[ItemIndex]
    else
      raise Exception.Create('TDataGridStaticColumnsContainerEh.GetParentItemCount: Unexpected type of parameter Parent "' + AParent.ClassName + '"');
  end;
end;

function TDataGridStaticColumnsContainerEh.GetParentForChild(AChild: TComponent): TComponent;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if Grid.Title.IsComplexTitle then
  begin
    if AChild is TCustomDataGridEh then
      Result := nil
    else if AChild is TDataGridSuperTitleEh then
    begin
      Result := TDataGridSuperTitleEh(AChild).ComplexTitleNode.Parent.NodeObject;
      if Result = nil then
        Result := Grid;
    end else if AChild is TDataGridBaseColumnEh then
    begin
      Result := TDataGridBaseColumnEh(AChild).Title.ComplexTitleNode.Parent.NodeObject;
      if Result = nil then
        Result := Grid;
    end
    else
      raise Exception.Create('TDataGridStaticColumnsContainerEh.GetParentForChildren: Unexpected type of parameter AChildren "' + AChild.ClassName + '"');
  end else
  begin
    if AChild is TCustomDataGridEh then
      Result := nil
    else if AChild is TDataGridBaseColumnEh then
      Result := Grid
    else
      raise Exception.Create('TDataGridStaticColumnsContainerEh.GetParentForChildren: Unexpected type of parameter AChildren "' + AChild.ClassName + '"');
  end;
end;

procedure TDataGridStaticColumnsContainerEh.SetChildrenIndex(AChildren: TComponent; NewIndex: Integer);
var
  Grid: TCustomDataGridEhCrack;
  Column: TDataGridBaseColumnEh;
  Node: TDataGridComplexTitleTreeNodeEh;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if Grid.Title.IsComplexTitle then
  begin
    if AChildren is TDataGridSuperTitleEh then
      Node := TDataGridSuperTitleEh(AChildren).ComplexTitleNode
    else
      Node := (AChildren as TDataGridBaseColumnEh).Title.ComplexTitleNode;

    if NewIndex < 0 then NewIndex := 0;
    if NewIndex > Node.Parent.Count then NewIndex := Node.Parent.Count;

    Grid.Title.ComplexTitleTree.MoveColumnObject(GetParentForChild(AChildren), AChildren, NewIndex);
  end else
  begin
    Column := AChildren as TDataGridBaseColumnEh;
    Column.StaticIndex := NewIndex;
  end;
end;

{$ENDREGION 'TDataGridStaticColumnsContainerEh'}

{$REGION 'TDataGridGetDataRowSplitWayParamsEh'}

{ TDataGridGetDataRowSplitWayParamsEh }

function TBaseDataGridGetDataRowSplitWayParamsEh.DefaultGetRowSplitWay(): TDataGridRowSplitWayEh;
var
  AGrid: TCustomDataGridEhCrack;
begin
  AGrid := TCustomDataGridEhCrack(FGrid);
  Result := AGrid.DefaultGetDataRowSplitWay(Self);
end;

procedure TBaseDataGridGetDataRowSplitWayParamsEh.Reset(AGrid: TControl; ARow: TDataGridDataRowEh; ARowSplitWay: TDataGridRowSplitWayEh);
begin
  FGrid := AGrid;
  FRow := ARow;
  FRowSplitWay := ARowSplitWay;
end;

{$ENDREGION 'TDataGridGetDataRowSplitWayParamsEh'}

{$REGION 'TBaseDataGridGetDataRowManagerParamsEh'}

{ TBaseDataGridGetDataRowManagerParamsEh }

procedure TBaseDataGridGetDataRowManagerParamsEh.Init(AGrid: TControl; ARow: TDataGridRowEh; ADefaultCellManager: TVPBaseCellManagerEh);
begin
  FGrid := AGrid;
  FRow := ARow;
  FCellManager := ADefaultCellManager;
end;

{$ENDREGION 'TBaseDataGridGetDataRowManagerParamsEh'}

{$REGION 'TDataGridGroupDescriptionMovingStateEh'}

{ TDataGridGroupDescriptionMovingStateEh }

procedure TDataGridGroupDescriptionMovingStateEh.Release;
begin
  inherited Release;
  FGroupDescriptionFrom := nil;
  FGroupDescriptionToIndex := -1;
end;

procedure TDataGridGroupDescriptionMovingStateEh.UpdateStateForMousePos(AScreenMousePost: TPointF);
var
  VGrid: TCustomDataGridEhCrack;
begin
  VGrid := TCustomDataGridEhCrack(Grid);
  GroupDescriptionToIndex := VGrid.GroupingPanel.GetDescriptionControlBoundIndex(AScreenMousePost);
  VGrid.GroupingPanel.GetDescriptionControlBoundLineBounds(GroupDescriptionToIndex, FToIndexScreenLinePos, FToIndexLineHeight);
  VGrid.DrawMove();
end;

{$ENDREGION 'TDataGridGroupDescriptionMovingStateEh'}

end.
