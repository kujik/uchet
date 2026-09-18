{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{                    EhLibFmx.Grids                     }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.Grids;

interface

{$I ..\Incl\EhLib.Inc}
{$SCOPEDENUMS ON}

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, System.Types,
  FMX.Graphics, System.UITypes, System.Math, FMX.Forms, System.Contnrs,
  FMX.Grid, FMX.Platform, FMX.Styles, FMX.Layouts,
  FMX.InertialMovement, FMX.BehaviorManager, Rtti,
  EhLibUtils,
  EhLibFmx.Platform,
  EhLibFmx.Utils,
  EhLibFmx.ToolControls,
  EhLibFmx.Grid.InplaceEditors,
  EhLibFmx.Grid.CellManagers,
  EhLibFmx.GridAxisData,
  EhLibFmx.Types,
  EhLibFmx.Grid.Types,
  EhLibFmx.LaHostVirtualPanels,
  EhLibFmx.LaObjects,
  EhLibFmx.Grid.ToolControls
  ;

type
  TCustomGridEh = class;
  TBaseGridStylePainterEh = class;

  EInvalidGridOperationEh = class(Exception);
  TCustomGridAxisDataEh = class(TGridAxisDataEh);

{ TGridNavigationEh }

  TGridNavigationEh = class(TPersistent)
  private
    FGrid: TCustomGridEh;
    FNextPageRow: Integer;
    FPrevPageRow: Integer;

    procedure CalcPageExtents; virtual;
    procedure RestrictPos(var Coord: TGridCoord);
  public
    constructor Create(AGrid: TCustomGridEh);
    destructor Destroy; override;

    function IsAtFirstRow: Boolean; virtual;
    function IsAtLastRow: Boolean; virtual;

    procedure ToFirstRow; virtual;
    procedure ToLastRow; virtual;
    procedure ToNextPage; virtual;
    procedure ToNextRow; virtual;
    procedure ToPriorPage; virtual;
    procedure ToPriorRow; virtual;

    property Grid: TCustomGridEh read FGrid;
    property NextPageRow: Integer read FNextPageRow;
    property PrevPageRow: Integer read FPrevPageRow;
  end;

{ TGridOutBoundaryDataEh }

  TCornerDrawPriorityEh = (HorizontalDataPriority, VerticalDataPriority);

  TGridOutBoundaryDataEh = class(TPersistent)
  private
    FBottomIndent: Integer;
    FGrid: TCustomGridEh;
    FLeftBottomDrawPriority: TCornerDrawPriorityEh;
    FLeftIndent: Integer;
    FLeftTopDrawPriority: TCornerDrawPriorityEh;
    FRightBottomDrawPriority: TCornerDrawPriorityEh;
    FRightIndent: Integer;
    FRightTopDrawPriority: TCornerDrawPriorityEh;
    FTopIndent: Integer;

    procedure SetBottomIndent(const Value: Integer);
    procedure SetLeftBottomDrawPriority(const Value: TCornerDrawPriorityEh);
    procedure SetLeftIndent(const Value: Integer);
    procedure SetLeftTopDrawPriority(const Value: TCornerDrawPriorityEh);
    procedure SetRightBottomDrawPriority(const Value: TCornerDrawPriorityEh);
    procedure SetRightIndent(const Value: Integer);
    procedure SetRightTopDrawPriority(const Value: TCornerDrawPriorityEh);
    procedure SetTopIndent(const Value: Integer);
  protected
    property Grid: TCustomGridEh read FGrid;
  public
    constructor Create(AGrid: TCustomGridEh);

    function GetOutBoundaryRect(var ARect: TRect; OutBoundaryType: TGridCellBorderTypeEh): Boolean;
    procedure InvalidateOutBoundary(OutBoundaryType: TGridCellBorderTypeEh);

    property BottomIndent: Integer read FBottomIndent write SetBottomIndent;
    property LeftBottomDrawPriority: TCornerDrawPriorityEh read FLeftBottomDrawPriority write SetLeftBottomDrawPriority;
    property LeftIndent: Integer read FLeftIndent write SetLeftIndent;
    property LeftTopDrawPriority: TCornerDrawPriorityEh read FLeftTopDrawPriority write SetLeftTopDrawPriority;
    property RightBottomDrawPriority: TCornerDrawPriorityEh read FRightBottomDrawPriority write SetRightBottomDrawPriority;
    property RightIndent: Integer read FRightIndent write SetRightIndent;
    property RightTopDrawPriority: TCornerDrawPriorityEh read FRightTopDrawPriority write SetRightTopDrawPriority;
    property TopIndent: Integer read FTopIndent write SetTopIndent;
  end;

{ TGridLaHostVirtualPanelEh }

  TGridLaHostVirtualPanelEh = class(TLaHostVirtualPanelEh)
  private
    function GetGrid: TCustomGridEh;

  protected
    function CreateBaseCellManager: TVPBaseCellManagerEh; override;

    procedure LayoutChanged(LaObject: TLaObjectEh); override;

  public
    function GetCellManagerAt(AColIndex, ARowIndex: Integer): TVPBaseCellManagerEh; override;

    property Grid: TCustomGridEh read GetGrid;
  end;

{ TCustomGridEh }

  TCustomGridEh = class(TStyledControlEh)
  private
    FAniCalcPosChanged: Boolean;
    FAniCalculations: TAniCalculations;
    FBackgroundData: TGridBackgroundDataEh;
    FBorder: TControlBorderEh;
    FCanEditModify: Boolean;
    FCanvasRightToLeftReflected: Boolean;
    FCellEditor: TLaInplaceTextEdit;
    FColor: TAlphaColor;
    FCornerScrollBarPanelControl: TSizeGripPanelEh;
    FCurCellPos: TGridCoord;
    FEditorMode: Boolean;
    FExtraSizeGripControl: TSizeGripPanelEh;
    FFixedColor: TAlphaColor;
    FFont: TFont;
    FFontStored: Boolean;
    FGridLineOptions: TGridLineOptionsEh;
    FGridLineWidth: Integer;
    FGridMouseState: TBaseGridMouseStateEh;
    FGridMouseStateManage: TGridMouseStateManagerEh;
    FHitTest: TPoint;
    FHorzAxis: TCustomGridAxisDataEh;
    FHorzScrollingLockCount: Integer;
    FHorzScrollBar: TGridScrollBarEh;
    FHorzScrollBarIsShowing: Boolean;
    FHorzScrollBarPanelControl: TGridScrollBarPanelControlEh;
    FIsCreated: Boolean;
    FLaTimer: TTimer;
    FNavigation: TGridNavigationEh;
    FOptions: TGridOptionsEh;
    FOutBoundaryData: TGridOutBoundaryDataEh;
    FPopupMenuBuildingMode: TPopupMenuBuildingMode;
    FScrollAnimation: TBehaviorBoolean;
    FScrollBarSize: Integer;
    FSizeGripAlwaysShow: Boolean;
    FSizeGripPosition: TSizeGripPosition;
    FTouchTracking: TBehaviorBoolean;
    FUseRightToLeftAlignment: Boolean;
    FVertAxis: TCustomGridAxisDataEh;
    FVertScrollBar: TGridScrollBarEh;
    FVertScrollBarIsShowing: Boolean;
    FVertScrollBarPanelControl: TGridScrollBarPanelControlEh;
    FWinClientBoundary: TRect;
    FStylePainter: TBaseGridStylePainterEh;
    FClient: TControl;
    FBackground: TControl;

    function GetClientHeight: Integer;
    function GetClientWidth: Integer;
    function GetColCount: Integer;
    function GetColWidths(Index: Integer): Integer;
    function GetContraColCount: Integer;
    function GetContraRowCount: Integer;
    function GetDefaultColWidth: Integer;
    function GetDefaultRowHeight: Integer;
    function GetFixedColCount: Integer;
    function GetFixedRowCount: Integer;
    function GetFrozenColCount: Integer;
    function GetFrozenRowCount: Integer;
    function GetFullColCount: Integer;
    function GetFullRowCount: Integer;
    function GetGridClientHeight: Integer;
    function GetGridClientWidth: Integer;
    function GetIsCanvasEnabled: Boolean;
    function GetLastFullVisibleCol: Integer;
    function GetLastFullVisibleRow: Integer;
    function GetLastVisibleCol: Integer;
    function GetLastVisibleRow: Integer;
    function GetLeftCol: Integer;
    function GetLeftColOffset: Integer;
    function GetRolColCount: Integer;
    function GetRolRowCount: Integer;
    function GetRolStartVisPosX: Int64;
    function GetRolStartVisPosY: Int64;
    function GetRowCount: Integer;
    function GetRowHeights(Index: Integer): Integer;
    function GetSelection: TGridRect;
    function GetTopRow: Integer;
    function GetTopRowOffset: Integer;
    function GetVisibleColCount: Integer;
    function GetVisibleRowCount: Integer;
    function GetWinClientBoundary: TRect;
    function IsFontStored: Boolean;

    procedure GridRectToScreenRect(GridRect: TGridRect; var ScreenRect: TRect; CutOutBounds: Boolean = True; UseRTL: Boolean = True);
    procedure GridRectToScreenRectAbs(GridRect: TGridRect; var ScreenRect: TRect; IncludeLine: Boolean);
    procedure Initialize;
    procedure MoveAndScroll(Mouse, CellHit: Integer; Axis: TGridAxisDataEh; Scrollbar: Integer; const MousePt: TPoint);
    procedure MoveCurrent(AColIndex, ARowIndex: Integer; ShowX, ShowY: Boolean);
    procedure ProcessKeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    procedure ReadColWidths(Reader: TReader);
    procedure ReadRowHeights(Reader: TReader);
    procedure RefreshDefaultFont;
    procedure SetBorder(Value: TControlBorderEh);
    procedure SetColCount(const Value: Integer);
    procedure SetColWidths(Index: Integer; const Value: Integer);
    procedure SetContraColCount(const Value: Integer);
    procedure SetContraRowCount(const Value: Integer);
    procedure SetCurColIndex(const Value: Integer);
    procedure SetCurRowIndex(const Value: Integer);
    procedure SetDefaultColWidth(const Value: Integer);
    procedure SetDefaultRowHeight(const Value: Integer);
    procedure SetEditorMode(Value: Boolean);
    procedure SetFixedColCount(const Value: Integer);
    procedure SetFixedColor(Value: TAlphaColor);
    procedure SetFixedRowCount(const Value: Integer);
    procedure SetFont(const Value: TFont);
    procedure SetFontStored(const Value: Boolean);
    procedure SetFrozenColCount(const Value: Integer);
    procedure SetFrozenRowCount(const Value: Integer);
    procedure SetGridLineOptions(const Value: TGridLineOptionsEh);
    procedure SetGridLineWidth(Value: Integer);
    procedure SetHorzScrollBar(const Value: TGridScrollBarEh);
    procedure SetOptions(Value: TGridOptionsEh);
    procedure SetRolColCount(const Value: Integer);
    procedure SetRolRowCount(const Value: Integer);
    procedure SetRolStartVisPosX(const Value: Int64);
    procedure SetRolStartVisPosY(const Value: Int64);
    procedure SetRowCount(const Value: Integer);
    procedure SetRowHeights(Index: Integer; const Value: Integer);
    procedure SetScrollAnimation(const Value: TBehaviorBoolean);
    procedure SetScrollBarSize(const Value: Integer);
    procedure SetSelection(const Value: TGridRect);
    procedure SetSizeGripAlwaysShow(const Value: Boolean);
    procedure SetSizeGripPosition(const Value: TSizeGripPosition);
    procedure SetTouchTracking(const Value: TBehaviorBoolean);
    procedure SetVertScrollBar(const Value: TGridScrollBarEh);
    procedure UpdateScrollAnimation;
    procedure UpdateTouchTracking;
    procedure WriteColWidths(Writer: TWriter);
    procedure WriteRowHeights(Writer: TWriter);
    procedure SetClient(const Value: TControl);
    procedure SetBackground(const Value: TControl);

  protected
    FAnchorCell: TGridCoord;
    FBoundariesUpdateCount: Integer;
    FDesignOptionsBoost: TGridOptionsEh;
    FDrawnSizingPos1: Integer;
    FDrawnSizingPos2: Integer;
    FGridPotentialMouseState: TBaseGridMouseStateEh;
    FGridTimer: TTimer;
    FHotTrackCell: TGridCoord;
    FInternalColor: TAlphaColor;
    FInternalFixedColor: TAlphaColor;
    FInternalFocusResetting: Boolean;
    FInternalFontColor: TAlphaColor;
    FInterruptLayoutIsNeeded: Boolean;
    FIsViewLayoutUpdateNeeded: Boolean;
    FIsVirtPanelsUpdateNeeded: Boolean;
    FMouseDownCell: TGridCoord;
    FMouseDownPos: TPoint;
    FMouseInControl: Boolean;
    FMouseMovePos: TPoint;
    FSaveCellExtents: Boolean;
    FSizingIndex: Integer;
    FSizingOfs: Integer;
    FSizingPos: Integer;
    FScrollBarDataRecalculated: Boolean;
    FScrollBarDataChanged: Boolean;
    FHitCellFocused: Boolean;
    FPaintTime: UInt64;

    HFixedVFixedPanel: TLaHostVirtualPanelEh; 
    HDataVFixedPanel: TLaHostVirtualPanelEh; 
    HContraVFixedPanel: TLaHostVirtualPanelEh; 

    HFixedVDataPanel: TLaHostVirtualPanelEh; 
    HDataVDataPanel: TLaHostVirtualPanelEh; 
    HContraVDataPanel: TLaHostVirtualPanelEh; 

    HFixedVFooterPanel: TLaHostVirtualPanelEh; 
    HDataVFooterPanel: TLaHostVirtualPanelEh; 
    HContraVFooterPanel: TLaHostVirtualPanelEh; 

    function GetDefaultStyleLookupName: string; override;

    function BoundariesUpdating: Boolean;
    function BoxRect(ALeft, ATop, ARight, ABottom: Integer; IncludeLine: Boolean = False; UseRTL: Boolean = True): TRect;
    function BoxRectAbs(ALeft, ATop, ARight, ABottom: Integer; IncludeLine: Boolean = False): TRect;
    function CalcColRangeWidth(FromCol, RangeColCount: Integer): Int64;
    function CalcCoordFromPoint(X, Y: Integer): TGridCoord;
    function CalcRowRangeHeight(FromRow, RangeRowCount: Integer): Int64;
    function CanCharShowEditor(Ch: Char): Boolean; virtual;
    function CanEditAcceptKey(Key: Char): Boolean; virtual;
    function CanEditModify: Boolean; virtual;
    function CanFillSelectionByTheme: Boolean;
    function CanGridAcceptKey(Key: Word; Shift: TShiftState): Boolean; virtual;
    function CanShowEditor: Boolean; virtual;
    function CellRect(AColIndex, ARowIndex: Integer; IncludeLine: Boolean = False; UseRTL: Boolean = True): TRect;
    function CellRectAbs(AColIndex, ARowIndex: Integer; IncludeLine: Boolean = False): TRect;
    function CheckBeginColumnDrag(var Origin, Destination: Integer; const MousePt: TPoint): Boolean; virtual;
    function CheckBeginRowDrag(var Origin, Destination: Integer; const MousePt: TPoint): Boolean; virtual;
    function CheckCellCanSendDoubleClicks(CellHit: TGridCoord; Button: TMouseButton; ShiftState: TShiftState; MousePos, InCellMousePos: TPoint): Boolean; virtual;
    function CheckCellLine(AColIndex, ARowIndex: Integer; BorderType: TGridCellBorderTypeEh): Boolean;
    function CheckColumnDrag(AColMovingState: TGridMouseColMovingStateEh; var ADestination: Integer; const MousePt: TPoint): Boolean; virtual;
    function CheckPersistentContraLine(LineType: TGridCellBorderTypeEh): Boolean; virtual;
    function CheckRowDrag(ARowMovingState: TGridMouseRowMovingStateEh; var ADestination: Integer; const MousePt: TPoint): Boolean; virtual;
    function CheckSizingState(X, Y: Integer): TBaseGridMouseStateEh; virtual;
    function CheckStartTmpCancelCanvasRTLReflecting(var ADrawRect: TRect): Boolean;
    function IsLayoutInterrupted: Boolean;
    function CheckAndSetLayoutInterrupting: Boolean;
    function ChildControlCanMouseDown(AControl: TControl): Boolean; virtual;
    function CreateBackgroundData: TGridBackgroundDataEh; virtual;
//    function CreateDataCellsFill(): TBrush; virtual;
//    function CreateFixedCellsFill(): TBrush; virtual;
    function CreateGridLineOptions: TGridLineOptionsEh; virtual;
    function CreateGridMouseStateManager: TGridMouseStateManagerEh; virtual;
    function CreateGridNavigation(): TGridNavigationEh; virtual;
    function CreateHDataVDataPanel: TLaHostVirtualPanelEh; virtual;
    function CreateHDataVFixedPanel: TLaHostVirtualPanelEh; virtual;
    function CreateHDataVFooterPanel: TLaHostVirtualPanelEh; virtual;
    function CreateHFixedVDataPanel: TLaHostVirtualPanelEh; virtual;
    function CreateHFixedVFixedPanel: TLaHostVirtualPanelEh; virtual;
    function CreateHFixedVFooterPanel: TLaHostVirtualPanelEh; virtual;
    function CreateHContraVFixedPanel: TLaHostVirtualPanelEh; virtual;
    function CreateHContraVDataPanel: TLaHostVirtualPanelEh; virtual;
    function CreateHContraVFooterPanel: TLaHostVirtualPanelEh; virtual;
    function CreateHorzScrollBarPanelControl: TGridScrollBarPanelControlEh; virtual;
    function CreateScrollBar(AKind: TOrientation): TGridScrollBarEh; virtual;
    function CreateSizeGripPanel: TSizeGripPanelEh; virtual;
    function CreateVertScrollBarPanelControl: TGridScrollBarPanelControlEh; virtual;
    function DefaultFont: TFont; virtual;
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean;
    function DoMouseWheelDownEvent(Shift: TShiftState; MousePos: TPoint): Boolean;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean;
    function DoMouseWheelUpEvent(Shift: TShiftState; MousePos: TPoint): Boolean;
    function EmptyColWidth: Integer;
    function EmptyRowHeight: Integer;
    function EndColumnDrag(AColMovingState: TGridMouseColMovingStateEh; const MousePt: TPoint): Boolean; virtual;
    function EndRowDrag(ARowMovingState: TGridMouseRowMovingStateEh; const MousePt: TPoint): Boolean; virtual;
    function FixedColsSizingAllowed: Boolean; virtual;
    function FixedRowsSizingAllowed: Boolean; virtual;
    function FullRedrawOnScroll: Boolean; virtual;
    function GetCellManagerAt(AColIndex, ARowIndex: Integer): TVPBaseCellManagerEh; overload; virtual;
    function GetCellManagerAt(AColIndex, ARowIndex: Integer; out ALocalCol, ALocalRow: Integer): TVPBaseCellManagerEh; overload; virtual;
    function GetCursorAtMousePos(Params: TGridCellMouseParamsEh): TCursor; virtual;
    function GetEditLimit: Integer; virtual;
    function GetEditMask(AColIndex, ARowIndex: Integer): string; virtual;
    function GetEditorValue(InplaceEditor: TLaInplaceTextEdit): TValue; virtual;
    function GetEditStyle(AColIndex, ARowIndex: Integer): TEditStyle; virtual;
    function GetEditText(AColIndex, ARowIndex: Integer): string; virtual;
    function GetHorzScrollStep: Integer; virtual;
    function GetIsEditorModified: Boolean; virtual;
    function GetParentCell(AObj: TFmxObject): TGridBaseCellEh;
    function GetTabStops(Index: Integer): Boolean; virtual;
    function GetVertScrollStep: Integer; virtual;
    function GetVirtPanelAt(AColIndex, ARowIndex: Integer): TLaHostVirtualPanelEh; virtual;
    function GridBackgroundFilled: Boolean; virtual;
    function HasFocus: Boolean; virtual;
    function HorzLineWidth: Integer; virtual;
    function HorzScrollingLockCount: Integer;
    function InternalGetCellManagerAt(VirtPanel: TLaHostVirtualPanelEh; AColIndex, ARowIndex: Integer): TVPBaseCellManagerEh; virtual;
    function IsActiveControl: Boolean;
    function IsMultiSelected: Boolean; virtual;
    function IsSmoothHorzScroll: Boolean; virtual;
    function IsSmoothVertScroll: Boolean; virtual;
    function NextSelectableCellFor(AColIndex, ARowIndex, ANextCol, ANextRow: Integer): TGridCoord; virtual;
    function ResizeLine(Axis: TGridAxisDataEh): Integer;
    function RolSizeValid: Boolean;
    function SelectCell(AColIndex, ARowIndex: Integer): Boolean; virtual;
    function Sizing(X, Y: Integer): Boolean; virtual;
    function VertLineWidth: Integer; virtual;
    function WantInplaceEditorKey(Key: Word; Shift: TShiftState): Boolean; virtual;
    function GetCellContentTextValue(Params: TBaseGridInitCellContentParamsEh): String; virtual;
    function IsShowFocusLayerForCell(ACell: TGridBaseCellEh): Boolean; virtual;
    function IsShowSelectionLayerForCell(ACell: TGridBaseCellEh): Boolean; virtual;
    function CreateStylePainter(): TBaseGridStylePainterEh; virtual;
    function UpdateOutBoundaryIndents: Boolean; virtual;

    procedure ApplyStyle; override;
    procedure FreeStyle; override;
    procedure DoApplyStyleLookup; override;

    procedure DefineProperties(Filer: TFiler); override;
    procedure DialogKey(var Key: Word; Shift: TShiftState); override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure DoMouseLeave; override;
    procedure DoPaint; override;
    procedure DoRealign; override;
    procedure KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean); override;
    procedure Paint; override;
    procedure Resize; override;
    procedure DoBeforeFirstDrawing; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    procedure AdjustMaxTopLeft(AdjustLeft, AdjustTop, LeftBindToCell, TopBindToCell: Boolean); virtual;
    procedure AniCalcChange(Sender: TObject);
    procedure AniCalcStart(Sender: TObject);
    procedure AniCalcStop(Sender: TObject);
    procedure AniMouseDown(const Touch: Boolean; const X, Y: Single);
    procedure AniMouseMove(const Touch: Boolean; const X, Y: Single);
    procedure AniMouseUp(const Touch: Boolean; const X, Y: Single);
    procedure AxisMoved(Axis: TGridAxisDataEh; FromIndex, ToIndex: Integer); virtual;
    procedure AxisSetRollPos(XRolPos, YRolPos: Integer);
    procedure BeginUpdateBoundaries;
    procedure BorderChanged(); virtual;
    procedure CalcMaxRolTopLeft(var AMaxLeftPos, AMaxTopPos: Integer; LeftBindToCell, TopBindToCell: Boolean); virtual;
    procedure CalcSizingState(X, Y: Integer; var State: TBaseGridMouseStateEh; var Index: Integer; var SizingPos, SizingOfs: Integer); virtual;
    procedure CancelMode; virtual;
    procedure CancelEditor;
    procedure CellCountChanged; virtual;
    procedure CelLenChanged(Axis: TGridAxisDataEh; Index, OldLen: Integer); virtual;
    procedure CellMouseClick(const Cell: TGridCoord; Button: TMouseButton; Shift: TShiftState; const ACellRect: TRect; const GridMousePos, CellMousePos: TPoint); virtual;
    procedure CellMouseDown(ACellMan: TBaseGridCellManagerEh; ACellMouseParams:  TGridCellMouseButtonParamsEh); virtual;
    procedure CellMouseMove(ACellMan: TBaseGridCellManagerEh; ACellMouseParams:  TGridCellMouseParamsEh); virtual;
    procedure CellMouseUp(ACellMan: TBaseGridCellManagerEh; ACellMouseParams: TGridCellMouseButtonParamsEh); virtual;
    procedure CellShowContextMenu(ACellManager: TBaseGridCellManagerEh; ACellParams:  TBaseGridCellShowContextMenuParamsEh); virtual;
    procedure ChangeGridOrientation(Canvas: TCanvas; RightToLeftOrientation: Boolean);
    procedure CheckCreateVirtPanels;
    procedure CheckDrawCellBorder(AColIndex, ARowIndex: Integer; BorderType: TGridCellBorderTypeEh; var IsDraw: Boolean; var BorderColor: TAlphaColor; var IsExtent: Boolean); virtual;
    procedure CheckHideEditor(); virtual;
    procedure CheckUpdateAxises; virtual;
    procedure CheckUpdateVirtPanels;
    procedure CheckForceLastRenderOperation;
    procedure ClampInView(const Coord: TGridCoord; CheckX, CheckY: Boolean); virtual;
    procedure ColumnMoved(FromIndex, ToIndex: Integer); virtual;
    procedure ColWidthsChanged; virtual;
    procedure CurrentCellMoved(OldCurrent: TGridCoord); virtual;
    procedure DeleteColumn(AColIndex: Integer); virtual;
    procedure DeleteRow(ARowIndex: Integer); virtual;
    procedure DoHitCell(CellHitCoord: TGridCoord; AParentCell: TGridBaseCellEh; MouseParams: TControlMouseButtonParamsEh);
    procedure DoMousePreviewHitCell(CellHitCoord: TGridCoord; AParentCell: TGridBaseCellEh; MouseParams: TControlMouseButtonParamsEh);
//    procedure DrawBordersForCellArea(AColIndex, ARowIndex: Integer; var ARect: TRect; State: TGridDrawState; CellBorderTypes: TGridCellBorderTypesEh = [TGridCellBorderTypeEh.Bottom, TGridCellBorderTypeEh.Right]); virtual;
    procedure DrawBottomOutBoundaryData(ARect: TRect); virtual;
    procedure DrawLeftOutBoundaryData(ARect: TRect); virtual;
    procedure DrawMove; virtual;
    procedure DrawOutBoundaryData; virtual;
    procedure DrawPolyline(Canvas: TCanvas; Points: TPointArrayEh);
    procedure DrawRightOutBoundaryData(ARect: TRect); virtual;
    procedure DrawSizingLine; virtual;
    procedure DrawSizingLines; virtual;
    procedure DrawText(ACanvas: TCanvas; ARect: TRect; FillRect: Boolean; DX, DY: Integer; const Text: string; Alignment: TAlignment; Layout: TTextAlign; MultiL: Boolean; EndEllipsis: Boolean; LeftMarg, RightMarg: Integer; ForceSingleLine: Boolean; UseRightToLeftAlignment: Boolean);
    procedure DrawTopOutBoundaryData(ARect: TRect); virtual;
    procedure DrawWideLine(X1, Y1, X2, Y2, Width: Integer);
    procedure EndUpdateBoundaries;
    procedure FastInvalidate;
    procedure FixCoordToBound(var X, Y: Integer); virtual;
    procedure FlatChanged; virtual;
    procedure FocusCell(AColIndex, ARowIndex: Integer; MoveAnchor: Boolean); virtual;
    procedure FontPropChanged(Sender: TObject);
    procedure FontChanged(); virtual;
    procedure ForceRepaintForm;
    procedure GetDataForHorzScrollBar(var APosition, AMin, AMax, APageSize: Integer); virtual;
    procedure GetDataForVertScrollBar(var APosition, AMin, AMax, APageSize: Integer); virtual;
    procedure GetDrawSizingLineBound(var StartPos, FinishPos: Integer); virtual;
    procedure GridLinesVisibilityChanged; virtual;
    procedure GridTimerEvent(Sender: TObject); virtual;
    procedure HideEdit;
    procedure HideEditor(const Accept: Boolean); virtual;
    procedure HideMove; virtual;
    procedure HideSizingLine; virtual;
    procedure HorzScrollBarMessage(ScrollCode, Pos: Integer); virtual;
    procedure HotTrackCellPosChanged(); virtual;
    procedure InitCellForRender(ACellManager: TVPBaseCellManagerEh; ACell: TVPBaseCellHolderEh); virtual;
    procedure InitSizingLines; virtual;
    procedure InteractiveMoveColumn(AColMovingState: TGridMouseColMovingStateEh); virtual;
    procedure InteractiveSetColWidth(ColIndex: Integer; Value: Integer); virtual;
    procedure InteractiveSetRowHeight(RowIndex: Integer; Value: Integer); virtual;
    procedure InternalSetFocusedControl(Control: TControl);
    procedure InvalidateCell(AColIndex, ARowIndex: Integer);
    procedure InvalidateCol(AColIndex: Integer);
    procedure InvalidateEditor; virtual;
    procedure InvalidateGrid;
    procedure InvalidateGridRect(const ARect: TGridRect); virtual;
    procedure InvalidateRow(ARowIndex: Integer);
    procedure LockGridHorzScrolling;
    procedure MasterSetRollPos(XRolPos, YRolPos: Integer);
    procedure MoveAnchorCell(AColIndex, ARowIndex: Integer; Show: Boolean); virtual;
    procedure MoveColRow(AColIndex, ARowIndex: Integer; ShowX, ShowY: Boolean); virtual;
    procedure MoveColumn(FromIndex, ToIndex: Integer);
    procedure MoveRow(FromIndex, ToIndex: Integer);
    procedure OnLaTimer(Sender: TObject);
    procedure OutBoundaryDataChanged; virtual;
    procedure ProcessCellMouseDown(AColIndex, ARowIndex, InCellX, InCellY: Integer; const ACellRect: TRect; GridMouseParams: TControlMouseButtonParamsEh); virtual;
    procedure ProcessCellMouseMove(AColIndex, ARowIndex, AInCellX, AInCellY: Integer; const ACellRect: TRect; AGridMouseParams: TControlMouseParamsEh; ALaObjectMouseParams: TControlMouseParamsEh); virtual;
    procedure ProcessCellMouseUp(AColIndex, ARowIndex, InCellX, InCellY: Integer; const ACellRect: TRect; GridMouseParams: TControlMouseButtonParamsEh); virtual;

    procedure ProcessVirtPanelMouseDown(APanel: TLaHostVirtualPanelEh; MouseParams: TControlMouseButtonParamsEh); virtual;
    procedure ProcessVirtPanelMouseMove(APanel: TLaHostVirtualPanelEh; MouseParams: TControlMouseParamsEh); virtual;
    procedure ProcessVirtPanelMouseUp(APanel: TLaHostVirtualPanelEh; MouseParams: TControlMouseButtonParamsEh); virtual;
    procedure ProcessVirtPanelMouseClick(APanel: TLaHostVirtualPanelEh; MouseParams: TControlMouseButtonParamsEh); virtual;

    procedure ProcessPreviewVirtPanelKeyDown(APanel: TLaHostVirtualPanelEh; KeyParams: TLaObjectKeyEventParamsEh); virtual;
    procedure ProcessPreviewVirtPanelMouseClick(APanel: TLaHostVirtualPanelEh; MouseParams: TControlMouseButtonParamsEh); virtual;
    procedure ProcessPreviewVirtPanelMouseDown(APanel: TLaHostVirtualPanelEh; MouseParams: TControlMouseButtonParamsEh); virtual;
    procedure ProcessPreviewVirtPanelMouseEnter(APanel: TLaHostVirtualPanelEh; Params: TControlParamsEh); virtual;
    procedure ProcessPreviewVirtPanelMouseLeave(APanel: TLaHostVirtualPanelEh; Params: TControlParamsEh);
    procedure ProcessPreviewVirtPanelMouseMove(APanel: TLaHostVirtualPanelEh; ControlMouseParams: TControlMouseParamsEh); virtual;
    procedure ProcessPreviewVirtPanelMouseUp(APanel: TLaHostVirtualPanelEh; MouseParams: TControlMouseButtonParamsEh); virtual;
    procedure ProcessPreviewVirtPanelDblClick(APanel: TLaHostVirtualPanelEh; MouseParams: TControlParamsEh); virtual;
    procedure ProcessShowVirtPanelContextMenu(APanel: TLaHostVirtualPanelEh; Params: TControlShowContextMenuParamsEh); virtual;
    procedure ResetVirtPanels; virtual;
    procedure RolPosAxisChanged(Axis: TGridAxisDataEh; OldRowPos: Integer);
    procedure RolPosChanged(OldRowPosX, OldRowPosY: Integer); virtual;
    procedure RolSizeUpdated; virtual;
    procedure RowHeightsChanged; virtual;
    procedure RowMoved(FromIndex, ToIndex: Integer); virtual;
    procedure SafeScrollData(DX, DY: Integer);
    procedure SafeScrollDataTo(XRolPos, YRolPos: Integer);
    procedure SafeSetLeftCol(ANewLeftCol: Integer);
    procedure SafeSetLeftRollPos(ALeftRollPos: Integer);
    procedure SafeSetTopRollPos(ATopRollPos: Integer);
    procedure SafeSetTopRow(ANewTopRow: Integer);
    procedure SaveEditorData; virtual;
    procedure SaveEditorValue(EditorValue: TValue); virtual;
    procedure ScrollBarMessage(ScrollBar, ScrollCode, Pos: Integer; UseRightToLeft: Boolean); virtual;
    procedure ScrollBarShowingChanged; virtual;
    procedure ScrollBarSizeChanged(ScrollBar: TGridScrollBarEh); virtual;
    procedure SelectionChanged(const OldSel: TGridRect); virtual;
    procedure SetCellEditor(ATextEdit: TLaInplaceTextEdit);
    procedure SetEditorModified(FIsModified: Boolean); virtual;
    procedure SetGridMouseState(AGridMouseState: TBaseGridMouseStateEh);
    procedure SetGridTimer(AEnabled: Boolean; Interval: Cardinal); virtual;
    procedure SetPaintColors; virtual;
    procedure SetPotentialMouseState(ACellMouseParams:  TGridCellMouseParamsEh); virtual;
    procedure ShowEditor; virtual;
    procedure ShowEditorChar(Ch: Char);
    procedure StartAniMove(const Touch: Boolean; MouseDownPos, MouseMovePos: TPoint);
    procedure ClientChanged; virtual;
    procedure ClientResized(Sender: TObject); virtual;
    procedure RecreateContentControls; virtual;
    procedure CreateScrollBarPanels(); virtual;
    procedure CreateClientExtraPanels(); virtual;
    procedure RefreshDefaultProps; virtual;
    procedure StyleApplied; virtual;

    function InitGridMouseColMovingState(AColIndex, ARowIndex: Integer; AScreenPos: TPointF; AExtraData: TObject): TGridMouseColMovingStateEh; virtual;
    //function StartColMoving(ColIndex, RowIndex: Integer; InCellX, InCellY: Integer): TGridMouseColMovingDataEh; virtual;
    procedure StartColMoving(ColIndex, RowIndex: Integer; AScreenPos: TPointF); virtual;

    procedure StartRowDrag(StartRow: Integer; const MousePos: TPoint); virtual;
    function InitRowMovingState(AStartRow: Integer; const AMousePos: TPoint; AExtraData: TObject): TGridMouseRowMovingStateEh; virtual;

    procedure StopTmpCancelCanvasRTLReflecting;
    procedure StrictEvaluateCoord(var Coord: TGridCoord); virtual;
    procedure TimedScroll(Direction: TGridScrollDirections); virtual;
    procedure TopLeftChanged; virtual;
    procedure UnLockGridHorzScrolling;
    procedure UpdateAniCalculations();
    procedure UpdateBoundaries; virtual;
    procedure UpdateDesigner;
    procedure UpdateEdit; virtual;
    procedure UpdateHotTrackCellPos(ATrackColIndex, ATrackRowIndex: Integer);
    procedure UpdateScrollBarPanels; virtual;
    procedure UpdateScrollBars; virtual;
    procedure UpdateSizingLines; virtual;
    procedure UpdateText(EditorChanged: Boolean); virtual;
    procedure UpdateViewLayout; virtual;
    procedure UpdateVirtPanels; virtual;
    procedure ValidateRolSize;
    procedure VertScrollBarMessage(ScrollCode, Pos: Integer); virtual;
    procedure GridLayoutChanged();
    procedure VirtPanelsUpdateNeeded();
    procedure WriteEditorValue; virtual;
    procedure CallAsync(const AThreadProc: TThreadProcedure);
//    procedure AsyncTimerHandler(Sender: TObject);

    property BackgroundData: TGridBackgroundDataEh read FBackgroundData write FBackgroundData;
    property CellEditor: TLaInplaceTextEdit read FCellEditor;
    property ColCount: Integer read GetColCount write SetColCount;
    property ColWidths[Index: Integer]: Integer read GetColWidths write SetColWidths;
    property ContraColCount: Integer read GetContraColCount write SetContraColCount;
    property ContraRowCount: Integer read GetContraRowCount write SetContraRowCount;
    property CornerScrollBarPanelControl: TSizeGripPanelEh read FCornerScrollBarPanelControl;
    property CurColIndex: Integer read FCurCellPos.X write SetCurColIndex;
    property CurRowIndex: Integer read FCurCellPos.Y write SetCurRowIndex;
    property DefaultColWidth: Integer read GetDefaultColWidth write SetDefaultColWidth;
    property DefaultRowHeight: Integer read GetDefaultRowHeight write SetDefaultRowHeight;
    property EditorMode: Boolean read FEditorMode write SetEditorMode;
    property FixedColCount: Integer read GetFixedColCount write SetFixedColCount;
    property FixedColor: TAlphaColor read FFixedColor write SetFixedColor default TAlphaColorRec.Gray;
    property FixedRowCount: Integer read GetFixedRowCount write SetFixedRowCount;
    property FrozenColCount: Integer read GetFrozenColCount write SetFrozenColCount;
    property FrozenRowCount: Integer read GetFrozenRowCount write SetFrozenRowCount;
    property FullColCount: Integer read GetFullColCount;
    property FullRowCount: Integer read GetFullRowCount;
    property GridLineOptions: TGridLineOptionsEh read FGridLineOptions write SetGridLineOptions;
    property GridLineWidth: Integer read FGridLineWidth write SetGridLineWidth default 1;
    property HitTest: TPoint read FHitTest;
    property HorzAxis: TCustomGridAxisDataEh read FHorzAxis;
    property HorzScrollBar: TGridScrollBarEh read FHorzScrollBar write SetHorzScrollBar;
    property HorzScrollBarPanelControl: TGridScrollBarPanelControlEh read FHorzScrollBarPanelControl;
    property IsCreated: Boolean read FIsCreated;
    property IsEditorModified: Boolean read GetIsEditorModified;
    property LastFullVisibleCol: Integer read GetLastFullVisibleCol;
    property LastFullVisibleRow: Integer read GetLastFullVisibleRow;
    property LastVisibleCol: Integer read GetLastVisibleCol;
    property LastVisibleRow: Integer read GetLastVisibleRow;
    property LeftCol: Integer read GetLeftCol;
    property LeftColOffset: Integer read GetLeftColOffset;
    property Navigation: TGridNavigationEh read FNavigation;
    property Options: TGridOptionsEh read FOptions write SetOptions default [];
    property OutBoundaryData: TGridOutBoundaryDataEh read FOutBoundaryData;
    property RolColCount: Integer read GetRolColCount write SetRolColCount;
    property RolRowCount: Integer read GetRolRowCount write SetRolRowCount;
    property RolStartVisPosX: Int64 read GetRolStartVisPosX write SetRolStartVisPosX;
    property RolStartVisPosY: Int64 read GetRolStartVisPosY write SetRolStartVisPosY;
    property RowCount: Integer read GetRowCount write SetRowCount;
    property RowHeights[Index: Integer]: Integer read GetRowHeights write SetRowHeights;
    property ScrollBarSize: Integer read FScrollBarSize write SetScrollBarSize;
    property Selection: TGridRect read GetSelection write SetSelection;
    property SizeGripAlwaysShow: Boolean read FSizeGripAlwaysShow write SetSizeGripAlwaysShow;
    property SizeGripPosition: TSizeGripPosition read FSizeGripPosition write SetSizeGripPosition default TSizeGripPosition.BottomRight;
    property TabStops[Index: Integer]: Boolean read GetTabStops;
    property TopRow: Integer read GetTopRow;
    property TopRowOffset: Integer read GetTopRowOffset;
    property VertAxis: TCustomGridAxisDataEh read FVertAxis;
    property VertScrollBar: TGridScrollBarEh read FVertScrollBar write SetVertScrollBar;
    property VertScrollBarPanelControl: TGridScrollBarPanelControlEh read FVertScrollBarPanelControl;
    property VisibleColCount: Integer read GetVisibleColCount;
    property VisibleRowCount: Integer read GetVisibleRowCount;
    property WinClientBoundary: TRect read GetWinClientBoundary;
    property StylePainter: TBaseGridStylePainterEh read FStylePainter;
    property Client: TControl read FClient write SetClient;
    property Background: TControl read FBackground write SetBackground;

  public
    constructor Create(AOwner: TComponent); override;
    procedure AfterConstruction; override;
    destructor Destroy; override;

    function ContainsFocus: Boolean;
    function MouseCoord(X, Y: Single): TGridCoord; virtual;
    function HasTouchTracking: Boolean;

    procedure CheckUpdateViewLayout;
    procedure DefaultCellMouseClick(const Cell: TGridCoord; Button: TMouseButton; Shift: TShiftState; const ACellRect: TRect; const GridMousePos, CellMousePos: TPoint); virtual;
    procedure GridColRowToLocalColRowIndex(AColIndex, ARowIndex: Integer; out ALocalColIndex, ALocalRowIndex: Integer); virtual;
    procedure InteractiveFocusCell(AColIndex, ARowIndex: Integer; ActionSource: TInteractiveActionSourceEh); virtual;
    procedure Invalidate();
    procedure InvalidateClean();
    procedure PrepareForPaint; override;
    procedure SetNewScene(AScene: IScene); override;

    property Border: TControlBorderEh read FBorder write SetBorder;
    property CanvasRightToLeftReflected: Boolean read FCanvasRightToLeftReflected;
    property ClientHeight: Integer read GetClientHeight;
    property ClientWidth: Integer read GetClientWidth;
    property Color: TAlphaColor read FColor;
    property Font: TFont read FFont write SetFont stored IsFontStored;
    property FontStored: Boolean read FFontStored write SetFontStored default False;
    property GridClientHeight: Integer read GetGridClientHeight; 
    property GridClientWidth: Integer read GetGridClientWidth; 
    property GridMouseState: TBaseGridMouseStateEh read FGridMouseState;
    property GridMouseStateManage: TGridMouseStateManagerEh read FGridMouseStateManage;
    property IsCanvasEnabled: Boolean read GetIsCanvasEnabled;
    property PopupMenuBuildingMode: TPopupMenuBuildingMode read FPopupMenuBuildingMode write FPopupMenuBuildingMode default TPopupMenuBuildingMode.LocalAndGlobalMenuCompound;
    property ScrollAnimation: TBehaviorBoolean read FScrollAnimation write SetScrollAnimation default TBehaviorBoolean.PlatformDefault;
    property TouchTracking: TBehaviorBoolean read FTouchTracking write SetTouchTracking default TBehaviorBoolean.PlatformDefault;
    property UseRightToLeftAlignment: Boolean read FUseRightToLeftAlignment;

  published
    property TabStop default True;
    property CanFocus default True;
  end;

  TComboBoxPopupListboxEh = TCustomGridEh;

{ TBaseGridStylePainterEh }

  TBaseGridStylePainterEh = class(TComponent)
  private
    FForegroundColor: TAlphaColor;
    FCellBorderLineBrightColor: TAlphaColor;
    FCellBorderLineDarkColor: TAlphaColor;

    FBackgroundFill: TBrush;
    FBackgroundMiddleFill: TBrush;
    FCellFocusFill: TBrush;
    FCellInactiveFocusFill: TBrush;
    FCellSelectionFill: TBrush;
    FCellInactiveSelectionFill: TBrush;
    FTitleForeColor: TAlphaColor;
    FTopFixedCellBackground: TControl;
    FTopFixedCellForegroundColor: TAlphaColor;
    FFont: TFont;
    function GetGrid: TCustomGridEh;

  protected
//    procedure ApplyStyle; override;
    procedure LoadStyleItems; virtual;
    procedure FreeStyleItems; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function LookupGlobalStyleElement(AStyleElementName: String): TFmxObject;

    property Grid: TCustomGridEh read GetGrid;
    property ForegroundColor: TAlphaColor read FForegroundColor;
    property BackgroundFill: TBrush read FBackgroundFill;
    property BackgroundMiddleFill: TBrush read FBackgroundMiddleFill;
    property CellBorderLineBrightColor: TAlphaColor read FCellBorderLineBrightColor;
    property CellBorderLineDarkColor: TAlphaColor read FCellBorderLineDarkColor;
    property TitleForeColor: TAlphaColor read FTitleForeColor;
    property CellFocusFill: TBrush read FCellFocusFill;
    property CellInactiveFocusFill: TBrush read FCellInactiveFocusFill;
    property CellSelectionFill: TBrush read FCellSelectionFill;
    property CellInactiveSelectionFill: TBrush read FCellInactiveSelectionFill;

    property TopFixedCellBackground: TControl read FTopFixedCellBackground;
    property TopFixedCellForegroundColor: TAlphaColor read FTopFixedCellForegroundColor;
    property Font: TFont read FFont;
  end;

procedure Register;

var
  GridEhDebugDraw: Boolean;

function GridCoord(X, Y: Integer): TGridCoord;
function GridRect(ALeft, ATop, ARight, ABottom: Integer): TGridRect;

implementation

procedure Register;
begin
end;

type
  TGridScrollBarEhCrack = class(TGridScrollBarEh);
  TGridAxisDataEhCrack = class(TGridAxisDataEh);
  TBaseGridMouseStateEhCrack = class(TBaseGridMouseStateEh);

function GridCoord(X, Y: Integer): TGridCoord;
begin
  Result.X := X;
  Result.Y := Y;
end;

function GridRect(ALeft, ATop, ARight, ABottom: Integer): TGridRect; overload;
begin
  Result.Left := ALeft;
  Result.Top := ATop;
  Result.Bottom := ABottom;
  Result.Right := ARight;
end;

function GridRect(Coord1, Coord2: TGridCoord): TGridRect; overload;
begin
  if Coord1.X < Coord2.X then
  begin
    Result.Left := Coord1.X;
    Result.Right := Coord2.X;
  end else
  begin
    Result.Left := Coord2.X;
    Result.Right := Coord1.X;
  end;
  if Coord1.Y < Coord2.Y then
  begin
    Result.Top := Coord1.Y;
    Result.Bottom := Coord2.Y;
  end else
  begin
    Result.Top := Coord2.Y;
    Result.Bottom := Coord1.Y;
  end
end;

function PointInGridRect(AColIndex, ARowIndex: Integer; const Rect: TGridRect): Boolean;
begin
  Result := (AColIndex >= Rect.Left) and (AColIndex <= Rect.Right) and (ARowIndex >= Rect.Top)
    and (ARowIndex <= Rect.Bottom);
end;

procedure CanvasFillRect(Canvas: TCanvas; const ARect: TRectF; const AOpacity: Single);
begin
  Canvas.FillRect(ARect, 0, 0, [], AOpacity);
end;

function CompareAxisSize(Ax1, Ax2: TGridAxisDataEh): Boolean;
var
  I: Integer;
begin
  Result := False;
  if Ax1.FullCelCount = Ax2.FullCelCount then
  begin
    for I := 0 to Ax1.FullCelCount do
      if Ax1.CelLens[I] <> Ax2.CelLens[I] then Exit;
    Result := True;
  end;
end;

{$REGION 'TGridOutBoundaryDataEh'}

{ TGridOutBoundaryDataEh }

constructor TGridOutBoundaryDataEh.Create(AGrid: TCustomGridEh);
begin
  inherited Create;
  FGrid := AGrid;
end;

procedure TGridOutBoundaryDataEh.SetBottomIndent(const Value: Integer);
begin
  if FBottomIndent <> Value then
  begin
    FBottomIndent := Value;
    Grid.OutBoundaryDataChanged;
  end;
end;

procedure TGridOutBoundaryDataEh.SetLeftBottomDrawPriority(
  const Value: TCornerDrawPriorityEh);
begin
  FLeftBottomDrawPriority := Value;
end;

procedure TGridOutBoundaryDataEh.SetLeftIndent(const Value: Integer);
begin
  if FLeftIndent <> Value then
  begin
    FLeftIndent := Value;
    Grid.OutBoundaryDataChanged;
  end;
end;

procedure TGridOutBoundaryDataEh.SetLeftTopDrawPriority(
  const Value: TCornerDrawPriorityEh);
begin
  if FLeftTopDrawPriority <> Value then
  begin
    FLeftTopDrawPriority := Value;
    Grid.OutBoundaryDataChanged;
  end;
end;

procedure TGridOutBoundaryDataEh.SetRightBottomDrawPriority(
  const Value: TCornerDrawPriorityEh);
begin
  if FRightBottomDrawPriority <> Value then
  begin
    FRightBottomDrawPriority := Value;
    Grid.OutBoundaryDataChanged;
  end;
end;

procedure TGridOutBoundaryDataEh.SetRightIndent(const Value: Integer);
begin
  if FRightIndent <> Value then
  begin
    FRightIndent := Value;
    Grid.OutBoundaryDataChanged;
  end;
end;

procedure TGridOutBoundaryDataEh.SetRightTopDrawPriority(
  const Value: TCornerDrawPriorityEh);
begin
  if FRightTopDrawPriority <> Value then
  begin
    FRightTopDrawPriority := Value;
    Grid.OutBoundaryDataChanged;
  end;
end;

procedure TGridOutBoundaryDataEh.SetTopIndent(const Value: Integer);
begin
  if FTopIndent <> Value then
  begin
    FTopIndent := Value;
    Grid.OutBoundaryDataChanged;
  end;
end;

function TGridOutBoundaryDataEh.GetOutBoundaryRect(
  var ARect: TRect; OutBoundaryType: TGridCellBorderTypeEh): Boolean;
begin
  Result := False;
  if (OutBoundaryType = TGridCellBorderTypeEh.Top) and (TopIndent > 0) then
  begin
    ARect.Top := Grid.WinClientBoundary.Top;
    ARect.Bottom := TopIndent;
    if LeftTopDrawPriority = TCornerDrawPriorityEh.HorizontalDataPriority
      then ARect.Left := Grid.WinClientBoundary.Left
      else ARect.Left := LeftIndent;
    if RightTopDrawPriority = TCornerDrawPriorityEh.HorizontalDataPriority
      then ARect.Right := Grid.ClientWidth
      else ARect.Right := Grid.ClientWidth - RightIndent;
    Result := True;
  end;
  if (OutBoundaryType = TGridCellBorderTypeEh.Bottom) and (BottomIndent > 0) then
  begin
    ARect.Top := Grid.ClientHeight - BottomIndent;
    ARect.Bottom := Grid.ClientHeight;
    if LeftBottomDrawPriority = TCornerDrawPriorityEh.HorizontalDataPriority
      then ARect.Left := 0
      else ARect.Left := LeftIndent;
    if RightBottomDrawPriority = TCornerDrawPriorityEh.HorizontalDataPriority
      then ARect.Right := Grid.ClientWidth
      else ARect.Right := Grid.ClientWidth - RightIndent;
    Result := True;
  end;
  if (OutBoundaryType = TGridCellBorderTypeEh.Left) and (LeftIndent > 0) then
  begin
    ARect.Left := 0;
    ARect.Right := LeftIndent;
    if LeftTopDrawPriority = TCornerDrawPriorityEh.HorizontalDataPriority
      then ARect.Top := TopIndent
      else ARect.Top := 0;
    if LeftBottomDrawPriority = TCornerDrawPriorityEh.HorizontalDataPriority
      then ARect.Bottom := Grid.ClientHeight - BottomIndent
      else ARect.Bottom := Grid.ClientHeight;
    Result := True;
  end;
  if (OutBoundaryType = TGridCellBorderTypeEh.Right) and (RightIndent > 0) then
  begin
    ARect.Left := Grid.ClientWidth - RightIndent;
    ARect.Right := Grid.ClientWidth;
    if RightTopDrawPriority = TCornerDrawPriorityEh.HorizontalDataPriority
      then ARect.Top := TopIndent
      else ARect.Top := 0;
    if RightBottomDrawPriority = TCornerDrawPriorityEh.HorizontalDataPriority
      then ARect.Bottom := Grid.ClientHeight - BottomIndent
      else ARect.Bottom := Grid.ClientHeight;
    Result := True;
  end;
end;

procedure TGridOutBoundaryDataEh.InvalidateOutBoundary(
  OutBoundaryType: TGridCellBorderTypeEh);
var
  BoundaryRect: TRect;
begin
  if GetOutBoundaryRect(BoundaryRect, OutBoundaryType) then
    Grid.Invalidate();
end;

{$ENDREGION 'TGridOutBoundaryDataEh'}

{$REGION 'TCustomGridEh'}

constructor TCustomGridEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FStylePainter := CreateStylePainter();

  FPopupMenuBuildingMode := TPopupMenuBuildingMode.LocalAndGlobalMenuCompound;
  FTouchTracking := TBehaviorBoolean.PlatformDefault;
  FScrollAnimation := TBehaviorBoolean.PlatformDefault;
  FNavigation := CreateGridNavigation;

  FHorzAxis := TCustomGridAxisDataEh.Create(Self);
  FVertAxis := TCustomGridAxisDataEh.Create(Self);
  FHorzScrollBar := CreateScrollBar(TOrientation.Horizontal);
  FVertScrollBar := CreateScrollBar(TOrientation.Vertical);

  FBorder := TControlBorderEh.Create(Self);

  FMouseDownPos := TPoint.Create(-1, -1);
  FScrollBarSize := 18;

  DefaultColWidth := 50;
  DefaultRowHeight := 20;
  FCanEditModify := True;

  FOptions := [
    {goFixedVertLineEh, goFixedHorzLineEh, }
    TGridOptionEh.DrawFocusSelected,
    TGridOptionEh.Editing,
    TGridOptionEh.RowSizing,
    TGridOptionEh.ColSizing,
    TGridOptionEh.RowMoving,
    TGridOptionEh.ColMoving];

  FDesignOptionsBoost := [TGridOptionEh.ColSizing,
                          TGridOptionEh.RowSizing,
                          TGridOptionEh.ColMoving];

  FGridLineWidth := 1;

  FAniCalculations := TAniCalculations.Create(Self);
  FAniCalculations.OnChanged := AniCalcChange;
  FAniCalculations.OnStart := AniCalcStart;
  FAniCalculations.OnStop := AniCalcStop;
  FAniCalculations.TouchTracking := [];

  FFont := TFont.Create();
  FFont.Assign(DefaultFont());
  FFont.OnChanged := FontPropChanged;
  FFontStored := False;

  FEditorMode := False;
  TabStop := True;

  Initialize;
  FGridLineOptions := CreateGridLineOptions;
  FOutBoundaryData := TGridOutBoundaryDataEh.Create(Self);
  FMouseDownCell := MouseCoord(-1, -1);
  FGridTimer := TTimer.Create(Self);
  FGridTimer.Enabled := False;
  FGridTimer.OnTimer := GridTimerEvent;

  FHotTrackCell.X := -1;
  FHotTrackCell.Y := -1;
  FBackgroundData :=  CreateBackgroundData;
  FSizeGripPosition := TSizeGripPosition.BottomRight;

  RolColCount := 5;
  RolRowCount := 5;
  FixedColCount := 1;
  FixedRowCount := 1;

  SetBounds(Left, Top, ColCount * DefaultColWidth, RowCount * DefaultRowHeight);

  FColor := TAlphaColorRec.White;
  FFixedColor := TAlphaColorRec.Whitesmoke;
  AutoCapture := True;
  CanFocus := True;

  FLaTimer := TTimer.Create(Self);
  FLaTimer.OnTimer := OnLaTimer;
  FLaTimer.Interval := 1;
  FLaTimer.Enabled := False;

  FGridMouseStateManage := CreateGridMouseStateManager;
  SetGridMouseState(FGridMouseStateManage.NormalState);
  UpdateTouchTracking;
  UpdateScrollAnimation;
end;

procedure TCustomGridEh.AfterConstruction;
begin
  inherited AfterConstruction;
  FIsCreated := True;
end;

destructor TCustomGridEh.Destroy;
begin
  Destroying;

  SetGridMouseState(nil);
  FreeAndNil(FGridMouseStateManage);
  FreeAndNil(FGridTimer);
  FreeAndNil(FFont);
  FreeAndNil(FStylePainter);

  FreeAndNil(FHorzAxis);
  FreeAndNil(FVertAxis);
  FreeAndNil(FOutBoundaryData);
  FreeAndNil(FHorzScrollBar);
  FreeAndNil(FVertScrollBar);
  FreeAndNil(FGridLineOptions);

  FreeAndNil(FHorzScrollBarPanelControl);
  FreeAndNil(FVertScrollBarPanelControl);
  FreeAndNil(FCornerScrollBarPanelControl);
  FreeAndNil(FExtraSizeGripControl);

  FreeAndNil(FBorder);
  FreeAndNil(FAniCalculations);
  FreeAndNil(FNavigation);

  inherited Destroy;
  FreeAndNil(FBackgroundData);
end;

function TCustomGridEh.CreateBackgroundData: TGridBackgroundDataEh;
begin
  Result := TGridBackgroundDataEh.Create(Self);
end;

function TCustomGridEh.BoxRect(ALeft, ATop, ARight, ABottom: Integer;
  IncludeLine: Boolean = False; UseRTL: Boolean = True): TRect;
var
  GridRect: TGridRect;
begin
  GridRect.Left := ALeft;
  GridRect.Right := ARight;
  GridRect.Top := ATop;
  GridRect.Bottom := ABottom;
  GridRectToScreenRect(GridRect, Result, True, UseRTL);
end;

function TCustomGridEh.BoxRectAbs(ALeft, ATop, ARight, ABottom: Integer;
  IncludeLine: Boolean): TRect;
var
  GridRect: TGridRect;
begin
  GridRect.Left := ALeft;
  GridRect.Right := ARight;
  GridRect.Top := ATop;
  GridRect.Bottom := ABottom;
  GridRectToScreenRectAbs(GridRect, Result, IncludeLine);
end;

procedure TCustomGridEh.DoEnter;
begin
  inherited DoEnter;
  Invalidate;
end;

procedure TCustomGridEh.DoExit;
begin
  inherited DoExit;
  Invalidate;
end;

function TCustomGridEh.CellRect(AColIndex, ARowIndex: Integer;
  IncludeLine: Boolean = False; UseRTL: Boolean = True): TRect;
begin
  Result := BoxRect(AColIndex, ARowIndex, AColIndex, ARowIndex, IncludeLine, UseRTL);
end;

function TCustomGridEh.CellRectAbs(AColIndex, ARowIndex: Integer;
  IncludeLine: Boolean): TRect;
begin
  Result := BoxRectAbs(AColIndex, ARowIndex, AColIndex, ARowIndex, IncludeLine);
end;

function TCustomGridEh.CanEditAcceptKey(Key: Char): Boolean;
begin
  Result := True;
end;

function TCustomGridEh.CanGridAcceptKey(Key: Word; Shift: TShiftState): Boolean;
begin
  Result := True;
end;

function TCustomGridEh.CanEditModify: Boolean;
begin
  Result := FCanEditModify;
end;

function TCustomGridEh.CanFillSelectionByTheme: Boolean;
begin
  Result := False;
end;

function TCustomGridEh.IsActiveControl: Boolean;
var
  ParentForm: TCommonCustomForm;

  function IsParentOf(AControl: TFmxObject): Boolean;
  begin
    Result := False;
    while Assigned(AControl) do
    begin
      AControl := AControl.Parent;
      if Self = AControl then
        Exit(True);
    end;
  end;

begin
  Result := HasFocus;
  ParentForm := GetParentForm(Self);
  if Assigned(ParentForm) and (ParentForm.Focused <> nil) then
  begin
    if (ParentForm.Focused.GetObject = Self) or (IsParentOf(ParentForm.Focused.GetObject)) then
      Result := True;
  end;
end;

function TCustomGridEh.HasFocus: Boolean;
begin
  Result := IsFocused;
end;

procedure TCustomGridEh.InternalSetFocusedControl(Control: TControl);
begin
  FInternalFocusResetting := True;
  try
    Control.SetFocus;
  finally
    FInternalFocusResetting := False;
  end;
end;

function TCustomGridEh.GetEditMask(AColIndex, ARowIndex: Integer): string;
begin
  Result := '';
end;

function TCustomGridEh.GetEditText(AColIndex, ARowIndex: Integer): string;
begin
  Result := '';
end;

function TCustomGridEh.GetEditLimit: Integer;
begin
  Result := 0;
end;

function TCustomGridEh.GetEditStyle(AColIndex, ARowIndex: Integer): TEditStyle;
begin
  Result := TEditStyle.Simple;
end;

function TCustomGridEh.GetEditorValue(InplaceEditor: TLaInplaceTextEdit): TValue;
begin
  Result := TValue.From<String>(CellEditor.Text);
end;

procedure TCustomGridEh.SaveEditorValue(EditorValue: TValue);
begin
  raise Exception.Create('TCustomGridEh.SaveEditorValue must be implemented');
end;
procedure TCustomGridEh.SaveEditorData;
var
  EditorValue: TValue;
begin
  if (CellEditor <> nil) and
     (CellEditor.Visible = True) then
  begin
    EditorValue := GetEditorValue(CellEditor);
    SaveEditorValue(EditorValue);
  end;
end;

procedure TCustomGridEh.WriteEditorValue;
var
  EditorValue: TValue;
begin
  if CellEditor <> nil then
  begin
    EditorValue := GetEditorValue(CellEditor);
    SaveEditorValue(EditorValue);
  end;
end;

procedure TCustomGridEh.CheckHideEditor();
begin
  if EditorMode then
    HideEditor(IsEditorModified);
end;

procedure TCustomGridEh.HideEditor(const Accept: Boolean);
begin
  if FEditorMode = False then
    raise Exception.Create('procedure TCustomGridEh.HideEditor: EditorMode = False');

  if Accept then
  begin
    WriteEditorValue;
  end;

  FEditorMode := False;
  HideEdit;
end;

procedure TCustomGridEh.ShowEditor;
begin
  if CanShowEditor then
  begin
    FEditorMode := True;
    UpdateEdit;
  end;
end;

procedure TCustomGridEh.ShowEditorChar(Ch: Char);
begin
  ShowEditor;
end;

function TCustomGridEh.CanShowEditor: Boolean;
begin
  Result :=
    ([TGridOptionEh.RowSelect, TGridOptionEh.Editing] * Options = [TGridOptionEh.Editing]) and
    not (csDesigning in ComponentState) and
    IsCanvasEnabled;

  if Result then
  begin
    Result := True;
  end;
end;

function TCustomGridEh.CanCharShowEditor(Ch: Char): Boolean;
begin
  if Ch >= #32
    then Result := True
    else Result := False;
end;

procedure TCustomGridEh.HideEdit;
begin
  GridLayoutChanged;
  CheckUpdateViewLayout;
end;

procedure TCustomGridEh.CancelEditor;
begin
  if EditorMode = True then
  begin
    FEditorMode := False;
    GridLayoutChanged;
  end;
end;

procedure TCustomGridEh.UpdateEdit;
begin
  Invalidate;
  CheckUpdateVirtPanels;
end;

procedure TCustomGridEh.SetCellEditor(ATextEdit: TLaInplaceTextEdit);
begin
  FCellEditor := ATextEdit;
  if FCellEditor <> nil then
    FCellEditor.SetGrid(Self);
end;

function TCustomGridEh.GetIsCanvasEnabled: Boolean;
begin
  Result := (Canvas <> nil);
end;

function TCustomGridEh.GetIsEditorModified(): Boolean;
begin
  Result := False;
end;

procedure TCustomGridEh.SetEditorModified(FIsModified: Boolean);
begin
  raise Exception.Create('TCustomGridEh.SetEditorModified() should be implemented');
end;

procedure TCustomGridEh.InvalidateEditor;
begin
  if FCellEditor <> nil then
    FCellEditor.LayoutChanged;
//    UpdateEdit;
end;

procedure TCustomGridEh.ReadColWidths(Reader: TReader);
var
  I: Integer;
begin
  Reader.ReadListBegin;
  for I := 0 to ColCount - 1 do
    ColWidths[I] := Reader.ReadInteger;
  Reader.ReadListEnd;
end;

procedure TCustomGridEh.ReadRowHeights(Reader: TReader);
var
  I: Integer;
begin
  Reader.ReadListBegin;
  for I := 0 to RowCount - 1 do
    RowHeights[I] := Reader.ReadInteger;
  Reader.ReadListEnd;
end;

procedure TCustomGridEh.WriteColWidths(Writer: TWriter);
var
  I: Integer;
begin
  Writer.WriteListBegin;
  for I := 0 to ColCount - 1 do
    Writer.WriteInteger(ColWidths[I]);
  Writer.WriteListEnd;
end;

procedure TCustomGridEh.WriteRowHeights(Writer: TWriter);
var
  I: Integer;
begin
  Writer.WriteListBegin;
  for I := 0 to RowCount - 1 do
    Writer.WriteInteger(RowHeights[I]);
  Writer.WriteListEnd;
end;

procedure TCustomGridEh.DefineProperties(Filer: TFiler);

  function DoColWidths: Boolean;
  begin
    if Filer.Ancestor <> nil then
      Result := not CompareAxisSize(TCustomGridEh(Filer.Ancestor).HorzAxis, HorzAxis)
    else
      Result := HorzAxis.FullCelCount <> 0;
  end;

  function DoRowHeights: Boolean;
  begin
    if Filer.Ancestor <> nil then
      Result := not CompareAxisSize(TCustomGridEh(Filer.Ancestor).VertAxis, VertAxis)
    else
      Result := HorzAxis.FullCelCount <> 0;
  end;

begin
  inherited DefineProperties(Filer);
  if FSaveCellExtents then
  begin
    Filer.DefineProperty('ColWidths', ReadColWidths, WriteColWidths, DoColWidths);
    Filer.DefineProperty('RowHeights', ReadRowHeights, WriteRowHeights, DoRowHeights);
  end;
end;

procedure TCustomGridEh.AxisMoved(Axis: TGridAxisDataEh; FromIndex, ToIndex: Integer);
begin
  Invalidate;
  if Axis = HorzAxis
    then ColumnMoved(FromIndex, ToIndex)
    else RowMoved(FromIndex, ToIndex);
end;

procedure TCustomGridEh.ColumnMoved(FromIndex, ToIndex: Integer);
var
  AOldCell: TGridCoord;
begin
  AOldCell := FCurCellPos;
  if FCurCellPos.X = FromIndex then
    FCurCellPos.X := ToIndex
  else if (FromIndex < FCurCellPos.X) and (ToIndex >= FCurCellPos.X) then
    FCurCellPos.X := FCurCellPos.X - 1
  else if (FromIndex > FCurCellPos.X) and (ToIndex <= FCurCellPos.X) then
    FCurCellPos.X := FCurCellPos.X + 1;
  if (AOldCell.X = FAnchorCell.X) and (AOldCell.Y = FAnchorCell.Y) then
    FAnchorCell := FCurCellPos;
end;

procedure TCustomGridEh.RowMoved(FromIndex, ToIndex: Integer);
begin
end;

function TCustomGridEh.MouseCoord(X, Y: Single): TGridCoord;
begin
  Result := CalcCoordFromPoint(Round(X), Round(Y));
  if (Result.X < 0) or (Result.X >= FullColCount) then
    Result.X := -1;
  if (Result.Y < 0) or (Result.Y >= FullRowCount) then
    Result.Y := -1;
end;

procedure TCustomGridEh.FixCoordToBound(var X, Y: Integer);
begin
  if X < 0  then
    X := 0
  else if X >= FullColCount then
    X := FullColCount-1;
  if Y < 0  then
    Y := 0
  else if Y >= FullRowCount then
    Y := FullRowCount-1;
end;

procedure TCustomGridEh.StrictEvaluateCoord(var Coord: TGridCoord);
begin
  if (Coord.X < 0) or
     (Coord.X >= FullColCount) or
     (Coord.Y < 0) or
     (Coord.Y >= FullRowCount)
  then
  begin
    Coord.Y := -1;
    Coord.X := -1;
  end;
end;

procedure TCustomGridEh.MoveColRow(AColIndex, ARowIndex: Integer; ShowX, ShowY: Boolean);
begin
  MoveCurrent(AColIndex, ARowIndex, ShowX, ShowY);
end;

function TCustomGridEh.SelectCell(AColIndex, ARowIndex: Integer): Boolean;
begin
  Result := True;
end;

function TCustomGridEh.NextSelectableCellFor(AColIndex, ARowIndex, ANextCol, ANextRow: Integer): TGridCoord;
var
  i: Integer;
begin
  Result := GridCoord(ANextCol, ANextRow);
  if ANextCol > AColIndex then
    for i := ANextCol to ColCount-1 do
    begin
      if SelectCell(i, ANextRow) then
      begin
        Result.X := i;
        Break;
      end;
    end
  else if ANextCol < AColIndex then
    for i := ANextCol downto 0 do
    begin
      if SelectCell(i, ANextRow) then
      begin
        Result.X := i;
        Break;
      end;
    end;

  if ANextRow > ARowIndex then
    for i := ANextRow to RowCount-1 do
    begin
      if SelectCell(ANextCol, i) then
      begin
        Result.Y := i;
        Break;
      end;
    end
  else if ANextRow < ARowIndex then
    for i := ANextRow downto 0 do
    begin
      if SelectCell(ANextCol, i) then
      begin
        Result.Y := i;
        Break;
      end;
    end;
end;

function TCustomGridEh.Sizing(X, Y: Integer): Boolean;
begin
  Result := CheckSizingState(X, Y) <> GridMouseStateManage.NormalState;
end;

function TCustomGridEh.CheckSizingState(X, Y: Integer): TBaseGridMouseStateEh;
var
  State: TBaseGridMouseStateEh;
  Index: Integer;
  Pos, Ofs: Integer;
begin
  State := FGridMouseState;
  if State = GridMouseStateManage.NormalState then
  begin
    CalcSizingState(X, Y, State, Index, Pos, Ofs);
  end;
  Result := State;
end;

function TCustomGridEh.ChildControlCanMouseDown(AControl: TControl): Boolean;
begin
  Result := True;
  if CanFocus and
     not (csDesigning in ComponentState)
  then
    SetFocus;
end;

procedure TCustomGridEh.TopLeftChanged;
begin
end;

function TCustomGridEh.GridBackgroundFilled: Boolean;
begin
  Result := BackgroundData.Showing;
end;

function TCustomGridEh.IsMultiSelected: Boolean;
begin
  Result := (FAnchorCell.X <> FCurCellPos.X) or (FAnchorCell.Y <> FCurCellPos.Y);
end;

procedure TCustomGridEh.CheckDrawCellBorder(AColIndex, ARowIndex: Integer;
  BorderType: TGridCellBorderTypeEh; var IsDraw: Boolean;
  var BorderColor: TAlphaColor; var IsExtent: Boolean);
begin
  if (BorderType in [TGridCellBorderTypeEh.Right]) then
  begin
    if (AColIndex < ColCount) then
    begin
      if (AColIndex < FixedColCount) or (ARowIndex < FixedRowCount)
        then IsDraw := GridLineOptions.VertLinesVisible
        else IsDraw := GridLineOptions.VertLinesVisible;
      IsExtent := True;
    end else
    begin
      IsDraw := False;
    end;
  end
  else if (BorderType in [TGridCellBorderTypeEh.Left]) then
  begin
    if (AColIndex >= ColCount) then
    begin
      if (AColIndex < FixedColCount) or (ARowIndex < FixedRowCount)
        then IsDraw := GridLineOptions.VertLinesVisible
        else IsDraw := GridLineOptions.VertLinesVisible;
      IsExtent := True;
    end else
    begin
      IsDraw := False;
    end;
  end
  else if BorderType in [TGridCellBorderTypeEh.Bottom] then
  begin
    if (AColIndex < FixedColCount) or (ARowIndex < FixedRowCount)
      then IsDraw := GridLineOptions.HorzLinesVisible
      else IsDraw := GridLineOptions.HorzLinesVisible;
    IsExtent := True;
  end
  else if BorderType in [TGridCellBorderTypeEh.Top] then
  begin
    if ARowIndex = RowCount then
    begin
      if (AColIndex < FixedColCount) or (ARowIndex < FixedRowCount)
        then IsDraw := GridLineOptions.HorzLinesVisible
        else IsDraw := GridLineOptions.HorzLinesVisible;
      IsExtent := True;
    end else
    begin
      IsDraw := False;
    end;
  end;

  if (BorderType in [TGridCellBorderTypeEh.Top, TGridCellBorderTypeEh.Left]) and
     ((AColIndex = ColCount) or (ARowIndex = RowCount))
  then
    BorderColor := GridLineOptions.DarkColor
  else if (AColIndex < FixedColCount-FrozenColCount) or (ARowIndex < FixedRowCount-FrozenRowCount) then
    BorderColor := GridLineOptions.DarkColor
  else if (AColIndex = FixedColCount-1) and (BorderType = TGridCellBorderTypeEh.Right) then
    BorderColor := GridLineOptions.DarkColor
  else if (ARowIndex = FixedRowCount-1) and (BorderType = TGridCellBorderTypeEh.Bottom) then
    BorderColor := GridLineOptions.DarkColor
  else
    BorderColor := GridLineOptions.BrightColor;
end;

procedure TCustomGridEh.PrepareForPaint;
begin
  inherited PrepareForPaint;
  SetPaintColors;
end;

procedure TCustomGridEh.Paint;
var
  Sel: TGridRect;

begin

  if UseRightToLeftAlignment then ChangeGridOrientation(Canvas, True);

  if not IsCanvasEnabled then Exit;

  Sel := Selection;
  if not RolSizeValid then
    ValidateRolSize;

  if FBackgroundData.Showing then
    FBackgroundData.PaintBackgroundData;

  DrawOutBoundaryData;

  if UseRightToLeftAlignment then ChangeGridOrientation(Canvas, False);
end;

procedure TCustomGridEh.DoPaint;

  procedure CheckPaintEvalInfo;
  {$IFDEF eval}
  var
    ARect: TRect;
    AText: String;
  begin
    Canvas.Font.Style := [TFontStyle.fsBold];
    Canvas.Font.Size := 14;
    Canvas.Fill.Color := TAlphaColorRec.Silver;
    ARect := TRect.Create(HorzAxis.GridClientStart, VertAxis.GridClientStart, HorzAxis.GridClientStop - 4, VertAxis.ContraStart - 4);
    AText := EhLibVerInfo + ' ' + EhLibBuildInfo + '. ' + EhLibEditionInfo;
    WriteTextEh(Canvas, ARect, False, 4, 4, AText,
      taRightJustify, TTextAlign.Trailing, False, False, 0, 0, UseRightToLeftAlignment, True);
  end;
  {$ELSE}
  begin
  end;
  {$ENDIF}

begin
  FPaintTime := GetTickCountEh;
  inherited DoPaint;
  CheckPaintEvalInfo;
end;

procedure TCustomGridEh.SetNewScene(AScene: IScene);
begin
  inherited SetNewScene(AScene);
  if AScene <> nil then
    Invalidate();
end;

procedure TCustomGridEh.DoBeforeFirstDrawing;
begin
  inherited DoBeforeFirstDrawing;
  GridLayoutChanged();
end;

function TCustomGridEh.CheckCellLine(AColIndex, ARowIndex: Integer; BorderType: TGridCellBorderTypeEh): Boolean;
var
  IsDraw: Boolean;
  BorderColor: TAlphaColor;
  IsExtent: Boolean;
begin
  BorderColor := 0;
  IsExtent := False;
  CheckDrawCellBorder(AColIndex, ARowIndex, BorderType, IsDraw, BorderColor, IsExtent);
  Result := IsDraw;
end;

procedure TCustomGridEh.GridLinesVisibilityChanged;
begin
  Invalidate();
end;

procedure TCustomGridEh.DrawOutBoundaryData;
var
  DrawRect: TRect;
begin
  if OutBoundaryData.GetOutBoundaryRect(DrawRect, TGridCellBorderTypeEh.Top) then
    DrawTopOutBoundaryData(DrawRect);
  if OutBoundaryData.GetOutBoundaryRect(DrawRect, TGridCellBorderTypeEh.Left) then
    DrawLeftOutBoundaryData(DrawRect);
  if OutBoundaryData.GetOutBoundaryRect(DrawRect, TGridCellBorderTypeEh.Bottom) then
    DrawBottomOutBoundaryData(DrawRect);
  if OutBoundaryData.GetOutBoundaryRect(DrawRect, TGridCellBorderTypeEh.Right) then
    DrawRightOutBoundaryData(DrawRect);
end;

procedure TCustomGridEh.DrawTopOutBoundaryData(ARect: TRect);
begin
end;

procedure TCustomGridEh.DrawLeftOutBoundaryData(ARect: TRect);
begin
end;

procedure TCustomGridEh.DrawBottomOutBoundaryData(ARect: TRect);
begin
end;

procedure TCustomGridEh.DrawRightOutBoundaryData(ARect: TRect);
begin
end;

function TCustomGridEh.CalcCoordFromPoint(X, Y: Integer): TGridCoord;

  procedure CalcXAxis;
  var
    i: Integer;
    Pos: Integer;
  begin
    begin
      if X < HorzAxis.GridClientStart then
        Result.X := -1
      else if X < HorzAxis.FixedBoundary then
      begin
        Pos := HorzAxis.GridClientStart;
        for i := 0 to FixedColCount-1 do
          if Pos + ColWidths[i] > X then
          begin
            Result.X := i;
            Exit;
          end else
            Pos := Pos + ColWidths[i];
      end else if X <= HorzAxis.ContraStart then
      begin
        Pos := HorzAxis.FixedBoundary - HorzAxis.RollStartVisibleCellOffset;
        for i := HorzAxis.RollStartVisCel + FixedColCount to ColCount-1 do
          if Pos + ColWidths[i] > X then
          begin
            Result.X := i;
            Exit;
          end else
            Pos := Pos + ColWidths[i];
        Result.X := FullColCount;
      end else if X < HorzAxis.GridClientStop then
      begin
        Pos := HorzAxis.ContraStart;
        for i := ColCount to FullColCount-1 do
          if Pos + ColWidths[i] > X then
          begin
            Result.X := i;
            Exit;
          end else
            Pos := Pos + ColWidths[i];
      end else
       Result.X := HorzAxis.FullCelCount;
    end;
  end;

  procedure CalcYAxis;
  var
    i: Integer;
    Pos: Integer;
  begin
    if Y < VertAxis.GridClientStart then
      Result.Y := -1
    else if Y < VertAxis.FixedBoundary then
    begin
      Pos := VertAxis.GridClientStart;
      for i := 0 to FixedRowCount-1 do
        if Pos + RowHeights[i] > Y then
        begin
          Result.Y := i;
          Exit;
        end else
          Pos := Pos + RowHeights[i];
    end else if Y < VertAxis.ContraStart then
    begin
      Pos := VertAxis.FixedBoundary - VertAxis.RollStartVisibleCellOffset;
      for i := VertAxis.RollStartVisCel + FixedRowCount to RowCount-1 do
        if Pos + RowHeights[i] > Y then
        begin
          Result.Y := i;
          Exit;
        end else
          Pos := Pos + RowHeights[i];
      Result.Y := FullRowCount;
    end else if Y < VertAxis.GridClientStop  then
    begin
      Pos := VertAxis.ContraStart;
      for i := RowCount to FullRowCount-1 do
        if Pos + RowHeights[i] > Y then
        begin
          Result.Y := i;
          Exit;
        end else
          Pos := Pos + RowHeights[i];
    end else
      Result.Y := VertAxis.FullCelCount;
  end;

begin
  Result.X := -1;
  Result.Y := -1;
  if UseRightToLeftAlignment then
    X := HorzAxis.RightToLeftReflect(X);
  CalcXAxis;
  CalcYAxis;
end;

procedure TCustomGridEh.CalcSizingState(X, Y: Integer;
  var State: TBaseGridMouseStateEh; var Index: Integer; var SizingPos, SizingOfs: Integer);

  procedure CalcAxisState(Axis: TGridAxisDataEh; Pos: Integer;
    NewState: TBaseGridMouseStateEh; SizingAreaSize: Integer; FixedCellSizingAllowed: Boolean);
  var
    I, Line, Back, Range: Integer;
    LeftSizingBound: Integer;
    LeftSizingCell: Integer;
  begin
    if (NewState = GridMouseStateManage.ColSizingState) and UseRightToLeftAlignment then
      Pos := ClientWidth - Pos;

    Range := 0;
    Back := 0;
    if Range < SizingAreaSize then
    begin
      Range := SizingAreaSize;
      Back := Range shr 1;
    end;

    if FixedCellSizingAllowed then
    begin
      LeftSizingBound := Axis.GridClientStart;
      LeftSizingCell := 0;
    end else
    begin
      LeftSizingBound := Axis.FixedBoundary - Axis.FrozenLen;
      LeftSizingCell := Axis.FixedCelCount - Axis.FrozenCelCount;
    end;

    Line := LeftSizingBound;
    for I := LeftSizingCell to Axis.FixedCelCount - 1 do
    begin
      Inc(Line, Axis.CelLens[I]);
      if Line >= Axis.GridClientStop then Break;
      if (Pos >= Line - Back) and (Pos <= Line - Back + Range) then
      begin
        State := NewState;
        SizingPos := Line;
        SizingOfs := Line - Pos;
        Index := I;
        Exit;
      end;
    end;

    Line := Axis.FixedBoundary - Axis.RollStartVisibleCellOffset;
    for I := Axis.RollStartVisCel + Axis.FixedCelCount to Axis.CelCount - 1 do
    begin
      Inc(Line, Axis.CelLens[I]);
      if Line >= Axis.ContraStart then Break;
      if (Pos >= Line - Back) and (Pos <= Line - Back + Range) then
      begin
        State := NewState;
        SizingPos := Line;
        SizingOfs := Line - Pos;
        Index := I;
        Exit;
      end;
    end;
    if (Axis.ContraStart = Axis.RollInClientBoundary) and
       (Pos >= Axis.RollInClientBoundary - Back * 2) and
       (Pos <= Axis.RollInClientBoundary) then
    begin
      State := NewState;
      SizingPos := Axis.RollInClientBoundary;
      SizingOfs := Axis.RollInClientBoundary - Pos;
      if Axis.FixedBoundary > Axis.ContraStart
        then Index := Axis.RollLastVisCel + Axis.FixedCelCount
        else Index := Axis.RollLastVisCel + Axis.FixedCelCount;
      Exit;
    end;

    if (Axis.ContraCelCount > 0) and (Pos >= Axis.ContraStart)
      and (Pos <= Axis.ContraStart + Back) then
    begin
      State := NewState;
      SizingPos := Axis.ContraStart;
      SizingOfs := Axis.ContraStart - Pos;
      Index := Axis.CelCount;
      Exit;
    end;

    Line := Axis.ContraStart;
    for I := Axis.CelCount to Axis.CelCount + Axis.ContraCelCount - 2 do
    begin
      Inc(Line, Axis.CelLens[I]);
      if Line >= Axis.GridClientStop then Break;
      if (Pos >= Line - Back) and (Pos <= Line - Back + Range) then
      begin
        State := NewState;
        SizingPos := Line;
        SizingOfs := Line - Pos;
        Index := I + 1;
        Exit;
      end;
    end;
  end;

  function XOutsideHorzFixedBoundary(): Boolean;
  var
    LeftSizingBound: Integer;
  begin
    if FixedColsSizingAllowed
      then LeftSizingBound := HorzAxis.GridClientStart
      else LeftSizingBound := HorzAxis.FixedBoundary - HorzAxis.FrozenLen;
    if not UseRightToLeftAlignment then
      Result := X > LeftSizingBound
    else
      Result := X < ClientWidth - LeftSizingBound; 
  end;

  function XOutsideOrEqualHorzFixedBoundary: Boolean;
  begin
    if not UseRightToLeftAlignment then
      Result := X >= HorzAxis.FixedBoundary - HorzAxis.FrozenLen 
    else
      Result := X <= ClientWidth - (HorzAxis.FixedBoundary - HorzAxis.FrozenLen); 
  end;

var
  EffectiveOptions: TGridOptionsEh;
begin
  State := GridMouseStateManage.NormalState;
  Index := -1;
  EffectiveOptions := Options;
  if csDesigning in ComponentState then
    EffectiveOptions := EffectiveOptions + FDesignOptionsBoost;
  if [TGridOptionEh.ColSizing, TGridOptionEh.RowSizing] * EffectiveOptions <> [] then
  begin
    if (XOutsideHorzFixedBoundary()) and (TGridOptionEh.ColSizing in EffectiveOptions) then
    begin
      if (Y >= VertAxis.FixedBoundary - VertAxis.FrozenLen) or
         (Y < VertAxis.GridClientStart)
      then
        Exit;
      CalcAxisState(HorzAxis, X, GridMouseStateManage.ColSizingState, 7, FixedColsSizingAllowed);
    end
    else if (Y > VertAxis.FixedBoundary - VertAxis.FrozenLen) and (TGridOptionEh.RowSizing in EffectiveOptions) then
    begin
      if XOutsideOrEqualHorzFixedBoundary() then
        Exit;
      CalcAxisState(VertAxis, Y, GridMouseStateManage.RowSizingState, 5, FixedRowsSizingAllowed);
    end;
  end;
end;

function TCustomGridEh.FixedColsSizingAllowed: Boolean;
begin
  Result := False;
end;

function TCustomGridEh.FixedRowsSizingAllowed: Boolean;
begin
  Result := False;
end;

procedure TCustomGridEh.ChangeGridOrientation(Canvas: TCanvas; RightToLeftOrientation: Boolean);
begin
end;

function TCustomGridEh.CheckStartTmpCancelCanvasRTLReflecting(var ADrawRect: TRect): Boolean;
var
  OldRight: Integer;
begin
  if CanvasRightToLeftReflected then
  begin
    OldRight := ADrawRect.Right;
    ADrawRect.Right := ClientWidth - ADrawRect.Left;
    ADrawRect.Left := ClientWidth - OldRight;

    ChangeGridOrientation(Canvas, False);
    Result := True;
  end else
    Result := False;
end;

procedure TCustomGridEh.StopTmpCancelCanvasRTLReflecting;
begin
  ChangeGridOrientation(Canvas, True);
end;

procedure TCustomGridEh.DrawText(ACanvas: TCanvas; ARect: TRect;
  FillRect: Boolean; DX, DY: Integer; const Text: string; Alignment: TAlignment;
  Layout: TTextAlign; MultiL: Boolean;
  EndEllipsis: Boolean; LeftMarg, RightMarg: Integer; ForceSingleLine: Boolean;
  UseRightToLeftAlignment: Boolean);
var
  CancelReflectingStarted: Boolean;
begin
  CancelReflectingStarted := CheckStartTmpCancelCanvasRTLReflecting(ARect);
  WriteTextEh(Canvas, ARect, FillRect, DX, DY, Text, Alignment, Layout,
    MultiL, EndEllipsis, LeftMarg, RightMarg, UseRightToLeftAlignment, ForceSingleLine);
  if CancelReflectingStarted then
    ChangeGridOrientation(Canvas, True);
end;

procedure TCustomGridEh.ClampInView(const Coord: TGridCoord; CheckX, CheckY: Boolean);
var
  NewRolStartPos: TPoint;
  LocCol, LocRow: Integer;
  RolBoundWidth, RolBoundHeight: Integer;
  NewCel, NewPosInCell: Integer;
begin
  if not IsCanvasEnabled then Exit;
  NewRolStartPos := Point(RolStartVisPosX, RolStartVisPosY);

  if CheckX and (Coord.X >= FixedColCount) and (Coord.X < ColCount) then
  begin
    LocCol := Coord.X - FixedColCount;
    RolBoundWidth := HorzAxis.ContraStart - HorzAxis.FixedBoundary;
    if HorzAxis.RollLocCelPosArr[LocCol] < RolStartVisPosX then
      NewRolStartPos.X := HorzAxis.RollLocCelPosArr[LocCol]
    else if HorzAxis.RollLocCelPosArr[LocCol] + HorzAxis.RollCelLens[LocCol] > RolStartVisPosX + RolBoundWidth then
    begin
      NewRolStartPos.X := (HorzAxis.RollLocCelPosArr[LocCol] + HorzAxis.RollCelLens[LocCol]) - RolBoundWidth;
      if HorzAxis.RollLocCelPosArr[LocCol] < NewRolStartPos.X then
        NewRolStartPos.X := HorzAxis.RollLocCelPosArr[LocCol];
    end;
  end;

  if CheckY and (Coord.Y >= FixedRowCount) and (Coord.Y < RowCount) then
  begin
    LocRow := Coord.Y - FixedRowCount;
    RolBoundHeight := VertAxis.ContraStart - VertAxis.FixedBoundary;
    if VertAxis.RollLocCelPosArr[LocRow] < RolStartVisPosY then
      NewRolStartPos.Y := VertAxis.RollLocCelPosArr[LocRow]
    else if VertAxis.RollLocCelPosArr[LocRow] + VertAxis.RollCelLens[LocRow] > RolStartVisPosY + RolBoundHeight then
    begin
      NewRolStartPos.Y := (VertAxis.RollLocCelPosArr[LocRow] + VertAxis.RollCelLens[LocRow]) - RolBoundHeight;
      if VertAxis.RollLocCelPosArr[LocRow] < NewRolStartPos.Y then
        NewRolStartPos.Y := VertAxis.RollLocCelPosArr[LocRow];
    end;
  end;

  if IsSmoothHorzScroll then
    RolStartVisPosX := NewRolStartPos.X
  else
  begin
    HorzAxis.RollCellAtPos(NewRolStartPos.X, NewCel, NewPosInCell);
    RolStartVisPosX := NewRolStartPos.X - NewPosInCell;
  end;

  if IsSmoothVertScroll then
    RolStartVisPosY := NewRolStartPos.Y
  else
  begin
    VertAxis.RollCellAtPos(NewRolStartPos.Y, NewCel, NewPosInCell);
    if NewPosInCell = 0 then
      RolStartVisPosY := NewRolStartPos.Y
    else
      RolStartVisPosY := NewRolStartPos.Y - NewPosInCell + VertAxis.RollCelLens[NewCel];
  end;

end;

procedure TCustomGridEh.GetDrawSizingLineBound(var StartPos, FinishPos: Integer);
begin
  if FGridMouseState = GridMouseStateManage.RowSizingState then
    if UseRightToLeftAlignment then
    begin
      StartPos := HorzAxis.GridClientStop;
      FinishPos := HorzAxis.GridClientStop - HorzAxis.GridClientStart;
    end else
    begin
      StartPos := HorzAxis.GridClientStart;
      FinishPos := HorzAxis.GridClientStop;
    end
  else
  begin
    StartPos := VertAxis.GridClientStart;
    if TGridOptionEh.ExtendVertLines in Options
      then FinishPos := VertAxis.GridClientStop
      else FinishPos := VertAxis.GridClientStop;
  end;
end;

procedure TCustomGridEh.DrawSizingLine;
begin
  UpdateSizingLines;
end;

procedure TCustomGridEh.HideSizingLine;
var
  SizingForm: TGridSizingRectFormEh;
begin
  SizingForm := TGridSizingRectFormEh.GetForm;
  SizingForm.Hide;
end;

procedure TCustomGridEh.DrawSizingLines;
var
  SizingForm: TGridSizingRectFormEh;
  StartPos, FinishPos: Integer;
  StartScPos: TPoint;
  ScaledBounds: TRect;
begin
  SizingForm := TGridSizingRectFormEh.GetForm;
  GetDrawSizingLineBound(StartPos, FinishPos);
  StartScPos := LocalToScreen(Point(FDrawnSizingPos1, StartPos)).Round;
  ScaledBounds.Left := StartScPos.X;
  ScaledBounds.Top := StartScPos.Y;
  ScaledBounds.Width := Round((FDrawnSizingPos2 - FDrawnSizingPos1) * AbsoluteScale.X);
  ScaledBounds.Height := Round((FinishPos - StartPos) * AbsoluteScale.Y);

  if (not SizingForm.Visible) then
  begin
    SizingForm.Left := ScaledBounds.Left;
    SizingForm.Top := ScaledBounds.Top;
    SizingForm.Width := ScaledBounds.Width;
    SizingForm.Height := ScaledBounds.Height;
    SizingForm.Show;
    SetFocus;
  end else
  begin
    SizingForm.SetBounds(ScaledBounds.Left, ScaledBounds.Top, ScaledBounds.Width, ScaledBounds.Height);
  end;
end;

procedure TCustomGridEh.UpdateSizingLines;
begin
  FDrawnSizingPos2 := FSizingPos;
  DrawSizingLines;
end;

procedure TCustomGridEh.InitSizingLines;
var
  i: Integer;
  CelStartPos: Integer;
begin
  FDrawnSizingPos2 := FSizingPos;
  if GridMouseState = GridMouseStateManage.ColSizingState then
  begin
    if FSizingIndex >= ColCount then
    begin
      CelStartPos := HorzAxis.ContraStart;
      for i := ColCount to FSizingIndex do
        CelStartPos := CelStartPos + HorzAxis.CelLens[i];
      FDrawnSizingPos1 := CelStartPos;
    end else if FSizingIndex - FixedColCount >= 0 then
      FDrawnSizingPos1 := HorzAxis.FixedBoundary + HorzAxis.RollLocCelPosArr[FSizingIndex-FixedColCount] - HorzAxis.RollStartVisPos
    else
      FDrawnSizingPos1 := -1;

    if FDrawnSizingPos1 < HorzAxis.FixedBoundary then
      FDrawnSizingPos1 := -1;
  end else
  begin
    if FSizingIndex - FixedRowCount >= 0 then
      FDrawnSizingPos1 := VertAxis.FixedBoundary + VertAxis.RollLocCelPosArr[FSizingIndex-FixedRowCount] - VertAxis.RollStartVisPos
    else
      FDrawnSizingPos1 := -1;

    if FDrawnSizingPos1 < VertAxis.FixedBoundary then
      FDrawnSizingPos1 := -1;
  end;

  InvalidateGrid;
end;

procedure TCustomGridEh.DrawMove;
var
  Pos: Integer;
  R: TRect;
  MoveSize: Integer;
  ScreenPos: TPoint;
  UseMovePosRightSite: Boolean;
begin
  if (FGridMouseState <> GridMouseStateManage.RowMovingState) and
     (FGridMouseState <> GridMouseStateManage.ColMovingState) then Exit;

  if GridMouseState = GridMouseStateManage.RowMovingState then
  begin
    R := CellRect(0, GridMouseStateManage.RowMovingState.MoveToIndex);
    if GridMouseStateManage.RowMovingState.MoveToIndex > GridMouseStateManage.RowMovingState.MoveFromIndex then
      Pos := R.Bottom else
      Pos := R.Top;
    MoveSize := HorzAxis.GridClientLen;

    ScreenPos := LocalToScreen(PointF(HorzAxis.GridClientStart, Pos)).Round;

    if GetMoveLineEh.Visible then
      GetMoveLineEh.MoveToFor(ScreenPos)
    else
      GetMoveLineEh.StartShow(ScreenPos, False, MoveSize, Self);
  end
  else if GridMouseState = GridMouseStateManage.ColMovingState then
  begin
    UseMovePosRightSite := GridMouseStateManage.ColMovingState.MovePosRightSite;
    if GridMouseStateManage.ColMovingState.MoveToIndex = ColCount then
    begin
      R := CellRect(GridMouseStateManage.ColMovingState.MoveToIndex - 1, 0);
      UseMovePosRightSite := True;
    end else
    begin
      R := CellRect(GridMouseStateManage.ColMovingState.MoveToIndex, 0);
    end;

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
    if TGridOptionEh.ExtendVertLines in Options
      then MoveSize := VertAxis.RollInClientBoundary - VertAxis.GridClientStart
      else MoveSize := VertAxis.GridClientLen;

    ScreenPos := LocalToScreen(PointF(Pos, VertAxis.GridClientStart)).Round;

    if GetMoveLineEh.Visible then
      GetMoveLineEh.MoveToFor(ScreenPos)
    else
      GetMoveLineEh.StartShow(ScreenPos, True, MoveSize, Self);
  end;
end;

procedure TCustomGridEh.HideMove;
begin
  GetMoveLineEh.Hide;
end;

procedure TCustomGridEh.FocusCell(AColIndex, ARowIndex: Integer; MoveAnchor: Boolean);
begin
  MoveColRow(AColIndex, ARowIndex, True, True);
  UpdateEdit;
end;

procedure TCustomGridEh.GridRectToScreenRect(GridRect: TGridRect;
 var ScreenRect: TRect; CutOutBounds: Boolean = True; UseRTL: Boolean = True);
var
  LocCol, LocRow: Integer;
begin
  ScreenRect := EmptyRect;
  if (GridRect.Left > GridRect.Right) or (GridRect.Top > GridRect.Bottom) then
    Exit;

  if GridRect.Left < FixedColCount then
    ScreenRect.Left := HorzAxis.GridClientStart + CalcColRangeWidth(0, GridRect.Left)
  else if GridRect.Left < ColCount then
  begin
    LocCol := GridRect.Left - FixedColCount;
    ScreenRect.Left := HorzAxis.RollLocCelPosArr[LocCol] - RolStartVisPosX;
    if CutOutBounds and (ScreenRect.Left < 0)
      then ScreenRect.Left := HorzAxis.FixedBoundary
      else ScreenRect.Left := ScreenRect.Left + HorzAxis.FixedBoundary;
  end else
    ScreenRect.Left := HorzAxis.ContraStart + CalcColRangeWidth(ColCount, GridRect.Left - ColCount);

  if GridRect.Top < FixedRowCount then
    ScreenRect.Top := VertAxis.GridClientStart + CalcRowRangeHeight(0, GridRect.Top)
  else if GridRect.Top < RowCount then
  begin
    LocRow := GridRect.Top - FixedRowCount;
    ScreenRect.Top := VertAxis.RollLocCelPosArr[LocRow] - RolStartVisPosY;
    if CutOutBounds  and (ScreenRect.Top < 0)
      then ScreenRect.Top := VertAxis.FixedBoundary
      else ScreenRect.Top := ScreenRect.Top + VertAxis.FixedBoundary;
  end else
    ScreenRect.Top := VertAxis.ContraStart + CalcRowRangeHeight(RowCount, GridRect.Top - RowCount);

  if GridRect.Right < FixedColCount then
  begin
    ScreenRect.Right := HorzAxis.GridClientStart + CalcColRangeWidth(0, GridRect.Right + 1);
    if ScreenRect.Right > HorzAxis.ContraStart then
      ScreenRect.Right := HorzAxis.ContraStart;
  end else if GridRect.Right < ColCount then
  begin
    LocCol := GridRect.Right - FixedColCount;
    ScreenRect.Right :=
      HorzAxis.RollLocCelPosArr[LocCol] + HorzAxis.RollCelLens[LocCol] - RolStartVisPosX;
    if CutOutBounds and (ScreenRect.Right < 0)
      then ScreenRect.Right := HorzAxis.FixedBoundary - 1
      else ScreenRect.Right := ScreenRect.Right + HorzAxis.FixedBoundary;
    if CutOutBounds and (ScreenRect.Right > HorzAxis.ContraStart) then
      ScreenRect.Right := HorzAxis.ContraStart;
  end else
    ScreenRect.Right := HorzAxis.ContraStart + CalcColRangeWidth(ColCount, GridRect.Right - ColCount + 1);

  if GridRect.Bottom < FixedRowCount then
  begin
    ScreenRect.Bottom := VertAxis.GridClientStart + CalcRowRangeHeight(0, GridRect.Bottom + 1);
    if ScreenRect.Bottom > VertAxis.ContraStart then
      ScreenRect.Bottom := VertAxis.ContraStart;
  end else if GridRect.Bottom < RowCount then
  begin
    LocRow := GridRect.Bottom - FixedRowCount;
    ScreenRect.Bottom :=
      VertAxis.RollLocCelPosArr[LocRow] + VertAxis.RollCelLens[LocRow] - RolStartVisPosY;
    if CutOutBounds and (ScreenRect.Bottom < 0)
      then ScreenRect.Bottom := VertAxis.FixedBoundary - 1
      else ScreenRect.Bottom := ScreenRect.Bottom + VertAxis.FixedBoundary;
    if CutOutBounds and (ScreenRect.Bottom > VertAxis.ContraStart) then
      ScreenRect.Bottom := VertAxis.ContraStart;
  end else
    ScreenRect.Bottom := VertAxis.ContraStart + CalcRowRangeHeight(RowCount, GridRect.Bottom - RowCount + 1);

  if (ScreenRect.Left > ScreenRect.Right) or (ScreenRect.Top > ScreenRect.Bottom) then
    ScreenRect := EmptyRect;
end;

procedure TCustomGridEh.GridRectToScreenRectAbs(GridRect: TGridRect;
  var ScreenRect: TRect; IncludeLine: Boolean);
begin
  GridRectToScreenRect(GridRect, ScreenRect, False);
end;

procedure TCustomGridEh.Initialize;
begin
end;

procedure TCustomGridEh.Invalidate;
begin
  VirtPanelsUpdateNeeded;
end;

procedure TCustomGridEh.InvalidateClean();
begin
  if HFixedVFixedPanel <> nil then HFixedVFixedPanel.DestroyCells;
  if HFixedVDataPanel <> nil then HFixedVDataPanel.DestroyCells;
  if HDataVDataPanel <> nil then HDataVDataPanel.DestroyCells;
  if HFixedVFooterPanel <> nil then HFixedVFooterPanel.DestroyCells;
  if HDataVFooterPanel <> nil then HDataVFooterPanel.DestroyCells;
end;

procedure TCustomGridEh.InvalidateCell(AColIndex, ARowIndex: Integer);
var
  Rect: TGridRect;
begin
  Rect.Top := ARowIndex;
  Rect.Left := AColIndex;
  Rect.Bottom := ARowIndex;
  Rect.Right := AColIndex;
  InvalidateGridRect(Rect);
end;

procedure TCustomGridEh.InvalidateCol(AColIndex: Integer);
var
  Rect: TGridRect;
begin
  if not IsCanvasEnabled then Exit;
  Rect.Top := 0;
  Rect.Left := AColIndex;
  Rect.Bottom := VertAxis.FixedCelCount + VertAxis.RollLastVisCel;
  Rect.Right := AColIndex;
  InvalidateGridRect(Rect);
  if ContraRowCount > 0 then
  begin
    Rect.Top := RowCount;
    Rect.Left := AColIndex;
    Rect.Bottom := FullRowCount-1;
    Rect.Right := AColIndex;
    InvalidateGridRect(Rect);
  end;
end;

procedure TCustomGridEh.InvalidateRow(ARowIndex: Integer);
var
  Rect: TGridRect;
begin
  if not IsCanvasEnabled then Exit;
  Rect.Top := ARowIndex;
  Rect.Left := 0;
  Rect.Bottom := ARowIndex;
  Rect.Right := HorzAxis.FixedCelCount + HorzAxis.RollLastVisCel;
  if Rect.Right > HorzAxis.FullCelCount-1  then
    Rect.Right := HorzAxis.FullCelCount-1;
  InvalidateGridRect(Rect);
  if ContraColCount > 0 then
  begin
    Rect.Top := ARowIndex;
    Rect.Left := ColCount;
    Rect.Bottom := ARowIndex;
    Rect.Right := FullColCount-1;
    InvalidateGridRect(Rect);
  end;
end;

procedure TCustomGridEh.InvalidateGrid;
begin
  Invalidate;
end;

procedure TCustomGridEh.InvalidateGridRect(const ARect: TGridRect);
begin
  VirtPanelsUpdateNeeded;
end;

procedure TCustomGridEh.ScrollBarMessage(ScrollBar, ScrollCode, Pos: Integer;
  UseRightToLeft: Boolean);
var
  APosition, AMin, AMax, APageSize: Integer;
begin
  if ScrollBar = SB_HORZ_EH then
  begin
    if (not UseRightToLeftAlignment) or (not UseRightToLeft) then
    else
    begin
      case ScrollCode of
        SB_LINEUP_EH: ScrollCode := SB_LINEDOWN_EH;
        SB_LINEDOWN_EH: ScrollCode := SB_LINEUP_EH;
        SB_PAGEUP_EH: ScrollCode := SB_PAGEDOWN_EH;
        SB_PAGEDOWN_EH: ScrollCode := SB_PAGEUP_EH;
        SB_THUMBPOSITION_EH,
        SB_THUMBTRACK_EH:
          begin
            if UseRightToLeftAlignment then
            begin
              GetDataForHorzScrollBar(APosition, AMin, AMax, APageSize);
              Pos := AMax - Integer(Pos) - APageSize + 1;
            end else
              Pos := Integer(Pos) - 1;
          end;
        SB_BOTTOM_EH: ScrollCode := SB_TOP_EH;
        SB_TOP_EH: ScrollCode := SB_BOTTOM_EH;
      end;
    end;

    HorzScrollBarMessage(ScrollCode, Pos);
  end else
    VertScrollBarMessage(ScrollCode, Pos);
end;

procedure TCustomGridEh.ScrollBarShowingChanged;
begin
end;

procedure ModifySmoothScrollBar(Grid: TCustomGridEh; Code, Pos: Cardinal; Axis: TGridAxisDataEh;
  ScrollBar: TGridScrollBarEh);
var
  NewOffset: Integer;
begin
  NewOffset := 0;

  case Code of
    SB_LINEUP_EH: NewOffset := -Axis.GetScrollStep;
    SB_LINEDOWN_EH: NewOffset := Axis.GetScrollStep;
    SB_PAGEUP_EH: NewOffset := -Axis.RollClientLen;
    SB_PAGEDOWN_EH: NewOffset := Axis.RollClientLen;
    SB_THUMBPOSITION_EH,
    SB_THUMBTRACK_EH:
      if ScrollBar.Tracking  or (Code = SB_THUMBPOSITION_EH) then
      begin
        NewOffset := Integer(Pos) - Axis.RollStartVisPos;
      end;
    SB_BOTTOM_EH: NewOffset := Axis.RollStopVisPos - Axis.RollStartVisPos;
    SB_TOP_EH: NewOffset := -Axis.RollStartVisPos;
  end;

  if Axis = Grid.HorzAxis then
    Grid.MasterSetRollPos(Axis.RollStartVisPos + NewOffset, Grid.VertAxis.RollStartVisPos)
  else if Axis = Grid.VertAxis then
    Grid.MasterSetRollPos(Grid.HorzAxis.RollStartVisPos, Axis.RollStartVisPos + NewOffset);
end;

procedure ModifyDiscreteScrollBar(Grid: TCustomGridEh; Code, Pos: Cardinal; Axis: TGridAxisDataEh;
  ScrollBar: TGridScrollBarEh);
var
  NewCelOffset, NewCell: Integer;
begin
  NewCell := -1;
  case Code of
    SB_LINEUP_EH:
      if Axis.RollStartVisibleCellOffset > 0
        then NewCell := Axis.RollStartVisCel
        else NewCell := Axis.RollStartVisCel-1;
    SB_LINEDOWN_EH:
      NewCell := Axis.RollStartVisCel+1;
    SB_PAGEUP_EH:
      begin
        Axis.RollCellAtPos(Integer(Pos)-Axis.RollClientLen, NewCell, NewCelOffset);
        if NewCelOffset > 0 then
          Inc(NewCell);
      end;
    SB_PAGEDOWN_EH:
      if Axis.RollLastFullVisCel = Axis.RollLastVisCel
        then NewCell := Axis.RollLastVisCel + 1
        else NewCell := Axis.RollLastVisCel;
    SB_THUMBPOSITION_EH,
    SB_THUMBTRACK_EH:
      if ScrollBar.Tracking or (Code = SB_THUMBPOSITION_EH) then
      begin
        if Pos = Axis.RollLen-Axis.RollClientLen then
          NewCell := Axis.RollCelCount-1
        else
        begin
          Axis.RollCellAtPos(Pos, NewCell, NewCelOffset);
          if NewCelOffset > Axis.RollCelLens[NewCell] div 2 then
            Inc(NewCell);
        end;
      end;
    SB_BOTTOM_EH:
      NewCell := Axis.RollCelCount;
    SB_TOP_EH:
      NewCell := 0;
  end;

  if NewCell <> -1 then
  begin
    if Axis = Grid.HorzAxis then
      Grid.SafeSetLeftCol(NewCell)
    else if Axis = Grid.VertAxis then
      Grid.SafeSetTopRow(NewCell);
  end;
end;

procedure TCustomGridEh.HorzScrollBarMessage(ScrollCode, Pos: Integer);
begin
  if HorzScrollBar.SmoothStep then
    ModifySmoothScrollBar(Self, ScrollCode, Pos, HorzAxis, HorzScrollBar)
  else
    ModifyDiscreteScrollBar(Self, ScrollCode, Pos, HorzAxis, HorzScrollBar);
end;

procedure TCustomGridEh.VertScrollBarMessage(ScrollCode, Pos: Integer);
begin
  if VertScrollBar.SmoothStep then
    ModifySmoothScrollBar(Self, ScrollCode, Pos, VertAxis, VertScrollBar)
  else
    ModifyDiscreteScrollBar(Self, ScrollCode, Pos, VertAxis, VertScrollBar);
end;

procedure TCustomGridEh.MoveCurrent(AColIndex, ARowIndex: Integer; ShowX, ShowY: Boolean);
var
  OldCurCell: TGridCoord;
  OldMultiSelected: Boolean;
  OldSel: TGridRect;
begin
  if (AColIndex < 0) or (ARowIndex < 0) or (AColIndex >= ColCount) or (ARowIndex >= RowCount) then
    raise EInvalidGridOperationEh.Create('Grid index out of range');

  if (AColIndex = FCurCellPos.X) and (ARowIndex = FCurCellPos.Y) then
    Exit;

  if SelectCell(AColIndex, ARowIndex) then
  begin
    OldSel := Selection;
    OldCurCell := FCurCellPos;
    OldMultiSelected := IsMultiSelected;
    if not (TGridOptionEh.AlwaysShowEditor in Options) then
      CheckHideEditor;
    FCurCellPos.X := AColIndex;
    FCurCellPos.Y := ARowIndex;
    FAnchorCell := FCurCellPos;
    if ShowX or ShowY then
      ClampInView(FCurCellPos, ShowX, ShowY);
    if OldMultiSelected <> IsMultiSelected then
    begin
      InvalidateGrid;
    end else
    begin
      InvalidateCell(OldCurCell.X, OldCurCell.Y);
      InvalidateCell(AColIndex, ARowIndex);
    end;
    SelectionChanged(OldSel);
    CurrentCellMoved(OldCurCell);
  end;
end;

procedure TCustomGridEh.CurrentCellMoved(OldCurrent: TGridCoord);
begin
end;

function TCustomGridEh.IsSmoothHorzScroll: Boolean;
begin
  Result := HorzScrollBar.SmoothStep;
end;

function TCustomGridEh.IsSmoothVertScroll: Boolean;
begin
  Result := VertScrollBar.SmoothStep;
end;

function TCustomGridEh.GetHorzScrollStep: Integer;
begin
  Result := (VertAxis.ContraStart - VertAxis.FixedBoundary) div 20;
  if Result = 0 then
    Result := 1;
end;

function TCustomGridEh.GetVertScrollStep: Integer;
begin
  Result := (VertAxis.ContraStart - VertAxis.FixedBoundary) div 20;
  if Result = 0 then
    Result := 1;
end;

procedure TCustomGridEh.SetPaintColors;
var
  ColorsService: IGridSystemColorsService;
begin
  TPlatformServices.Current.SupportsPlatformService(IGridSystemColorsService, ColorsService);

//  FInternalColor := ColorsService.GetGridBackgroundColor;
  FInternalColor := StylePainter.BackgroundFill.Color;
  FInternalFontColor := StylePainter.ForegroundColor;
  FInternalFixedColor := ColorsService.GetGridFixedBackgroundColor;
end;

function TCustomGridEh.WantInplaceEditorKey(Key: Word; Shift: TShiftState): Boolean;
begin
  Result := False;
end;

procedure TCustomGridEh.AdjustMaxTopLeft(AdjustLeft, AdjustTop,
  LeftBindToCell, TopBindToCell: Boolean);
var
  AMaxLeftPos, AMaxTopPos: Integer;
begin
  AMaxLeftPos := HorzAxis.RollLen;
  AMaxTopPos := VertAxis.RollLen;
  CalcMaxRolTopLeft(AMaxLeftPos, AMaxTopPos, LeftBindToCell, TopBindToCell);

  if AMaxLeftPos < HorzAxis.RollStartVisPos then
    RolStartVisPosX := AMaxLeftPos;
  if AMaxTopPos < RolStartVisPosY then
    RolStartVisPosY := AMaxTopPos;
end;

procedure TCustomGridEh.CalcMaxRolTopLeft(var AMaxLeftPos, AMaxTopPos: Integer;
  LeftBindToCell, TopBindToCell: Boolean);
var
  ACel, ACelOffset: Integer;
begin
  AMaxLeftPos := AMaxLeftPos - HorzAxis.RollClientLen;
  if AMaxLeftPos < 0 then
    AMaxLeftPos := 0;

  if LeftBindToCell then
  begin
    HorzAxis.RollCellAtPos(AMaxLeftPos, ACel, ACelOffset);
    if (ACelOffset > 0) and (ACel < HorzAxis.RollCelCount-1) then
      Inc(ACel);
    AMaxLeftPos := HorzAxis.RollLocCelPosArr[ACel];
  end;

  AMaxTopPos := AMaxTopPos - VertAxis.RollClientLen;
  if AMaxTopPos < 0 then
    AMaxTopPos := 0;

  if TopBindToCell then
  begin
    VertAxis.RollCellAtPos(AMaxTopPos, ACel, ACelOffset);
    if (ACelOffset > 0) and (ACel < VertAxis.RollCelCount-1) then
      Inc(ACel);
    AMaxTopPos := VertAxis.RollLocCelPosArr[ACel];
  end;

end;

procedure TCustomGridEh.FastInvalidate;
begin
  Invalidate;
end;

procedure TCustomGridEh.Resize;
begin
  inherited Resize;
  FScrollBarDataChanged := True;
  FScrollBarDataRecalculated := False;
  UpdateBoundaries;
  GridLayoutChanged();
end;

function TCustomGridEh.GetFullColCount: Integer;
begin
  Result := ColCount + ContraColCount;
end;

function TCustomGridEh.GetFullRowCount: Integer;
begin
  Result := RowCount + ContraRowCount;
end;

function TCustomGridEh.GetWinClientBoundary: TRect;
begin
  Result := FWinClientBoundary;
end;

function TCustomGridEh.GetGridClientHeight: Integer;
begin
  Result := VertAxis.GridClientStop - VertAxis.GridClientStart;
end;

function TCustomGridEh.GetGridClientWidth: Integer;
begin
  Result := HorzAxis.GridClientStop - HorzAxis.GridClientStart;
end;

function TCustomGridEh.GetContraColCount: Integer;
begin
  Result := HorzAxis.ContraCelCount;
end;

procedure TCustomGridEh.SetContraColCount(const Value: Integer);
begin
  HorzAxis.ContraCelCount := Value;
end;

function TCustomGridEh.GetContraRowCount: Integer;
begin
  Result := VertAxis.ContraCelCount;
end;

procedure TCustomGridEh.SetContraRowCount(const Value: Integer);
begin
  VertAxis.ContraCelCount := Value;
end;

function TCustomGridEh.GetFixedColCount: Integer;
begin
  Result := HorzAxis.FixedCelCount;
end;

procedure TCustomGridEh.SetFixedColCount(const Value: Integer);
begin
  HorzAxis.FixedCelCount := Value;
end;

function TCustomGridEh.GetFixedRowCount: Integer;
begin
  Result := VertAxis.FixedCelCount;
end;

procedure TCustomGridEh.SetFixedRowCount(const Value: Integer);
begin
  VertAxis.FixedCelCount := Value;
end;

function TCustomGridEh.GetRolColCount: Integer;
begin
  Result := HorzAxis.RollCelCount;
end;

procedure TCustomGridEh.SetRolColCount(const Value: Integer);
begin
  HorzAxis.RollCelCount := Value;
end;

function TCustomGridEh.GetRolRowCount: Integer;
begin
  Result :=  VertAxis.RollCelCount;
end;

procedure TCustomGridEh.SetRolRowCount(const Value: Integer);
begin
  VertAxis.RollCelCount := Value;
end;

function TCustomGridEh.GetRolStartVisPosX: Int64;
begin
  Result := HorzAxis.RollStartVisPos;
end;

function TCustomGridEh.GetRolStartVisPosY: Int64;
begin
  Result := VertAxis.RollStartVisPos;
end;

function TCustomGridEh.GetLeftCol: Integer;
begin
  Result := HorzAxis.RollStartVisCel + HorzAxis.FixedCelCount;
end;

function TCustomGridEh.GetTopRow: Integer;
begin
  Result := VertAxis.RollStartVisCel + VertAxis.FixedCelCount;
end;

function TCustomGridEh.GetTopRowOffset: Integer;
begin
  Result := VertAxis.RollStartVisibleCellOffset;
end;

function TCustomGridEh.GetLeftColOffset: Integer;
begin
  Result := HorzAxis.RollStartVisibleCellOffset;
end;

function TCustomGridEh.GetLastFullVisibleCol: Integer;
begin
  Result := HorzAxis.RollLastFullVisCel + HorzAxis.FixedCelCount;
end;

function TCustomGridEh.GetLastFullVisibleRow: Integer;
begin
  Result := VertAxis.RollLastFullVisCel + VertAxis.FixedCelCount;
end;

function TCustomGridEh.GetLastVisibleCol: Integer;
begin
  Result := HorzAxis.RollLastVisCel + HorzAxis.FixedCelCount;
end;

function TCustomGridEh.GetLastVisibleRow: Integer;
begin
  Result := VertAxis.RollLastVisCel + VertAxis.FixedCelCount;
end;

function TCustomGridEh.GetVisibleColCount: Integer;
begin
  Result := HorzAxis.RollLastFullVisCel - HorzAxis.RollStartVisCel + 1;
end;

function TCustomGridEh.GetVisibleRowCount: Integer;
begin
  Result := VertAxis.RollLastFullVisCel - VertAxis.RollStartVisCel + 1;
end;

procedure TCustomGridEh.SetDefaultColWidth(const Value: Integer);
begin
  HorzAxis.DefaultCelLen := Value;
end;

function TCustomGridEh.GetDefaultColWidth: Integer;
begin
  Result := HorzAxis.DefaultCelLen;
end;

procedure TCustomGridEh.SetDefaultRowHeight(const Value: Integer);
begin
  VertAxis.DefaultCelLen := Value;
end;

function TCustomGridEh.GetDefaultRowHeight: Integer;
begin
  Result := VertAxis.DefaultCelLen;
end;

procedure TCustomGridEh.SetColWidths(Index: Integer; const Value: Integer);
begin
  HorzAxis.CelLens[Index] := Value;
end;

procedure TCustomGridEh.InteractiveSetColWidth(ColIndex: Integer; Value: Integer);
begin
  ColWidths[ColIndex] := Value;
end;

procedure TCustomGridEh.SetRowHeights(Index: Integer; const Value: Integer);
begin
  VertAxis.CelLens[Index] := Value;
end;

procedure TCustomGridEh.InteractiveSetRowHeight(RowIndex: Integer; Value: Integer);
begin
  RowHeights[RowIndex] := Value;
end;

procedure TCustomGridEh.SetScrollBarSize(const Value: Integer);
begin
  if FScrollBarSize <> Value then
  begin
    FScrollBarSize := Value;
    UpdateBoundaries;
  end;
end;

procedure TCustomGridEh.SetSizeGripAlwaysShow(const Value: Boolean);
begin
  if FSizeGripAlwaysShow <> Value then
  begin
    FSizeGripAlwaysShow := Value;
    UpdateScrollBarPanels;
  end;
end;

procedure TCustomGridEh.SetSizeGripPosition(const Value: TSizeGripPosition);
begin
  if FSizeGripPosition <> Value then
  begin
    FSizeGripPosition := Value;
    UpdateScrollBarPanels;
  end;
end;

procedure TCustomGridEh.SetTouchTracking(const Value: TBehaviorBoolean);
begin
  if FTouchTracking <> Value then
  begin
    FTouchTracking := Value;
    UpdateTouchTracking;
  end;
end;

procedure TCustomGridEh.SetScrollAnimation(const Value: TBehaviorBoolean);
begin
  if FScrollAnimation <> Value then
  begin
    FScrollAnimation := Value;
    UpdateScrollAnimation;
  end;
end;

function TCustomGridEh.HasTouchTracking: Boolean;
begin
  Result := FAniCalculations.TouchTracking <> [];
end;

procedure TCustomGridEh.UpdateTouchTracking;

  function BoolToTouchTracking(const AValue: Boolean): TTouchTracking;
  begin
    if AValue then
      Result := [ttVertical, ttHorizontal]
    else
      Result := [];
  end;

var
  ATouchTracking: TTouchTracking;
begin
  ATouchTracking := [];
  case TouchTracking of
    TBehaviorBoolean.True:
      ATouchTracking := [ttVertical, ttHorizontal];
    TBehaviorBoolean.PlatformDefault:
      ATouchTracking := BoolToTouchTracking(TEhLibFmxSettings.Default.TouchTracking)
  end;
  FAniCalculations.TouchTracking := ATouchTracking;
end;

procedure TCustomGridEh.UpdateScrollAnimation;
begin
  case ScrollAnimation of
    TBehaviorBoolean.True:
      FAniCalculations.Animation := True;
    TBehaviorBoolean.False:
      FAniCalculations.Animation := False;
    TBehaviorBoolean.PlatformDefault:
      FAniCalculations.Animation := True;
  end;
end;

function TCustomGridEh.GetColCount: Integer;
begin
  Result := FixedColCount + RolColCount;
end;

procedure TCustomGridEh.SetColCount(const Value: Integer);
begin
  RolColCount := Value - FixedColCount;
end;

function TCustomGridEh.GetRowCount: Integer;
begin
  Result := FixedRowCount + RolRowCount;
end;

procedure TCustomGridEh.SetRowCount(const Value: Integer);
begin
  RolRowCount := Value - FixedRowCount;
end;

procedure TCustomGridEh.SetRolStartVisPosX(const Value: Int64);
begin
  HorzAxis.RollStartVisPos := Value;
end;

procedure TCustomGridEh.SetRolStartVisPosY(const Value: Int64);
begin
  VertAxis.RollStartVisPos := Value;
end;

procedure TCustomGridEh.SafeSetTopRollPos(ATopRollPos: Integer);
begin
  SafeScrollDataTo(HorzAxis.RollStartVisPos, ATopRollPos);
end;

procedure TCustomGridEh.SafeSetLeftRollPos(ALeftRollPos: Integer);
begin
  SafeScrollDataTo(ALeftRollPos, VertAxis.RollStartVisPos);
end;

procedure TCustomGridEh.SafeScrollData(DX, DY: Integer);
var
  XRolPos, YRolPos: Integer;
begin
  XRolPos := HorzAxis.RollStartVisPos + DX;
  YRolPos := VertAxis.RollStartVisPos + DY;
  MasterSetRollPos(XRolPos, YRolPos);
end;

procedure TCustomGridEh.SafeScrollDataTo(XRolPos, YRolPos: Integer);
begin
  MasterSetRollPos(XRolPos, YRolPos);
end;

procedure TCustomGridEh.SafeSetLeftCol(ANewLeftCol: Integer);
var
  ANewRollRow: Integer;
  ANewRollPos: Integer;
begin
  ANewRollRow := ANewLeftCol - HorzAxis.FixedCelCount;
  ANewRollPos := HorzAxis.GetRollStartVisCel(ANewRollRow);
  MasterSetRollPos(ANewRollPos, VertAxis.RollStartVisPos);
end;

procedure TCustomGridEh.SafeSetTopRow(ANewTopRow: Integer);
var
  ANewRollRow: Integer;
  ANewRollPos: Integer;
begin
  ANewRollRow := ANewTopRow - VertAxis.FixedCelCount;
  ANewRollPos := VertAxis.GetRollStartVisCel(ANewRollRow);
  MasterSetRollPos(HorzAxis.RollStartVisPos, ANewRollPos);
end;

procedure TCustomGridEh.MasterSetRollPos(XRolPos, YRolPos: Integer);
begin
  AxisSetRollPos(XRolPos, YRolPos);
end;

procedure TCustomGridEh.AxisSetRollPos(XRolPos, YRolPos: Integer);
begin
  HorzAxis.RollStartVisPos := HorzAxis.CheckRollStartVisPos(XRolPos);
  VertAxis.RollStartVisPos := VertAxis.CheckRollStartVisPos(YRolPos);
end;

procedure TCustomGridEh.KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
var
  NewCurrent: TGridCoord;
  PageWidth: Integer;
  NextPageRow, PrevPageRow: Integer;
  RTLFactor: Integer;
  NeedsInvalidating: Boolean;
  NewAnchor: TGridCoord;

  procedure CalcPageExtents;
  var
    NewPos, NewCel, NewCelOff, i: Integer;
  begin
    NewPos := VertAxis.RollStartVisPos + VertAxis.RollClientLen;
    NextPageRow := RolRowCount - 1;
    if NewPos < VertAxis.RollLen then
    begin
      BinarySearch(TGridAxisDataEhCrack(VertAxis).FRollLocCelPosArr, NewPos, NewCel, NewCelOff);
      if NewCel < RolRowCount then
      begin
        for i := NewCel to RolRowCount-1 do
        begin
          NextPageRow := i-1;
          if VertAxis.RollLocCelPosArr[i] + VertAxis.RollCelLens[i] > NewPos + VertAxis.RollClientLen then
            Break;
        end;
      end;
    end;
    NextPageRow := NextPageRow + FixedRowCount;
    if (NextPageRow <= CurRowIndex) and (NextPageRow < RowCount) then
      NextPageRow := CurRowIndex + 1;

    NewPos := VertAxis.RollStartVisPos - VertAxis.RollClientLen;
    BinarySearch(TGridAxisDataEhCrack(VertAxis).FRollLocCelPosArr, NewPos, NewCel, NewCelOff);
    if NewCelOff > 0 then
      Inc(NewCel);
    PrevPageRow := NewCel + FixedRowCount;
    if (PrevPageRow >= CurRowIndex) and (PrevPageRow > 0) then
      PrevPageRow := CurRowIndex - 1;
  end;

  procedure Restrict(var Coord: TGridCoord; MinX, MinY, MaxX, MaxY: Integer);
  begin
    if Coord.X > MaxX then
      Coord.X := MaxX
    else if Coord.X < MinX then
      Coord.X := MinX;

    if Coord.Y > MaxY then
      Coord.Y := MaxY
    else if Coord.Y < MinY then
      Coord.Y := MinY;
  end;

begin
  ProcessKeyDown(Key, KeyChar, Shift);
  inherited KeyDown(Key, KeyChar, Shift);
  NeedsInvalidating := False;
  if not UseRightToLeftAlignment then
    RTLFactor := 1
  else
    RTLFactor := -1;
  NewCurrent := FCurCellPos;
  PageWidth := 0;
  CalcPageExtents;
  if (ssShift in Shift) and (TGridOptionEh.RangeSelect in Options) then
  begin
    NewAnchor := FAnchorCell;
    case Key of
      vkUp: Dec(NewAnchor.Y);
      vkDown: Inc(NewAnchor.Y);
      vkLeft: Dec(NewAnchor.X);
      vkRight: Inc(NewAnchor.X);
    end;
    Restrict(NewAnchor,
      FixedColCount-FrozenColCount, FixedRowCount-FrozenRowCount,
      FullColCount - 1, FullRowCount - 1);
    MoveAnchorCell(NewAnchor.X, NewAnchor.Y, True);
  end else
  begin
    if ssCtrl in Shift then
      case Key of
        vkUp: {Dec(NewTopLeft.Y)};
        vkDown: {Inc(NewTopLeft.Y)};
        vkLeft:
          begin
            Dec(NewCurrent.X, PageWidth * RTLFactor);
          end;
        vkRight:
          begin
            Inc(NewCurrent.X, PageWidth * RTLFactor);
          end;
        vkPrior: NewCurrent.Y := TopRow;
        vkHome:
          begin
            NewCurrent.X := FixedColCount;
            NewCurrent.Y := FixedRowCount;
            NeedsInvalidating := UseRightToLeftAlignment;
          end;
        vkEnd:
          begin
            NewCurrent.X := ColCount - 1;
            NewCurrent.Y := RowCount - 1;
            NeedsInvalidating := UseRightToLeftAlignment;
          end;
      end
    else
    begin
      case Key of
        vkUp:
          NewCurrent.Y := NextSelectableCellFor(CurColIndex, CurRowIndex, NewCurrent.X, NewCurrent.Y-1).Y;
        vkDown:
          NewCurrent.Y := NextSelectableCellFor(CurColIndex, CurRowIndex, NewCurrent.X, NewCurrent.Y+1).Y;
        vkLeft:
          if TGridOptionEh.RowSelect in Options then
            HorzScrollBarMessage(SB_LINEUP_EH, 0)
          else
            NewCurrent.X := NextSelectableCellFor(CurColIndex, CurRowIndex, NewCurrent.X-RTLFactor, NewCurrent.Y).X;
        vkRight:
          if TGridOptionEh.RowSelect in Options then
            HorzScrollBarMessage(SB_LINEDOWN_EH, 0)
          else
            NewCurrent.X := NextSelectableCellFor(CurColIndex, CurRowIndex, NewCurrent.X+RTLFactor, NewCurrent.Y).X;
        vkNext:
          begin
            NewCurrent.Y := NextPageRow;
          end;
        vkPrior:
          begin
            NewCurrent.Y := PrevPageRow;
          end;
        vkHome:
            NewCurrent.X := FixedColCount;
        vkEnd:
            NewCurrent.X := ColCount - 1;
        vkTab:
          if not (ssAlt in Shift) then
          repeat
            if ssShift in Shift then
            begin
              Dec(NewCurrent.X);
              if NewCurrent.X < FixedColCount then
              begin
                NewCurrent.X := ColCount - 1;
                Dec(NewCurrent.Y);
                if NewCurrent.Y < FixedRowCount then NewCurrent.Y := RowCount - 1;
              end;
              Shift := [];
            end
            else
            begin
              Inc(NewCurrent.X);
              if NewCurrent.X >= ColCount then
              begin
                NewCurrent.X := FixedColCount;
                Inc(NewCurrent.Y);
                if NewCurrent.Y >= RowCount then NewCurrent.Y := FixedRowCount;
              end;
            end;
          until TabStops[NewCurrent.X] or (NewCurrent.X = FCurCellPos.X);
        vkF2: EditorMode := True;
      end;
    end;
    Restrict(NewCurrent,
      FixedColCount-FrozenColCount, FixedRowCount-FrozenRowCount,
      ColCount - 1, RowCount - 1);
    if (NewCurrent.X <> CurColIndex) or (NewCurrent.Y <> CurRowIndex) then
    begin
      InteractiveFocusCell(NewCurrent.X, NewCurrent.Y, TInteractiveActionSourceEh.Keyboard);
    end;

    if NeedsInvalidating then Invalidate;
  end;
end;

procedure TCustomGridEh.ProcessKeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
var
  AreaColIndex: Integer;
  AreaRowIndex: Integer;
  BaseCellMan: TVPBaseCellManagerEh;
  ACellMan: TBaseGridCellManagerEh;
  KeyDownParams: TBaseGridCellKeyDownParamsEh;
begin
  BaseCellMan := GetCellManagerAt(CurColIndex, CurRowIndex, AreaColIndex, AreaRowIndex);

  if BaseCellMan is TBaseGridCellManagerEh then
    ACellMan := GetCellManagerAt(CurColIndex, CurRowIndex, AreaColIndex, AreaRowIndex) as TBaseGridCellManagerEh
  else
    Exit;

  KeyDownParams := ACellMan.GetCellKeyDownParams(Self, CurColIndex, CurRowIndex, AreaColIndex, AreaRowIndex, Key, KeyChar, Shift);
  ACellMan.ProcessKeyDown(KeyDownParams);
  Key := KeyDownParams.Key;
  KeyChar := KeyDownParams.KeyChar;
  KeyDownParams.Free;
end;

procedure TCustomGridEh.ProcessPreviewVirtPanelKeyDown(APanel: TLaHostVirtualPanelEh; KeyParams: TLaObjectKeyEventParamsEh);
begin

end;

procedure TCustomGridEh.DialogKey(var Key: Word; Shift: TShiftState);
begin
  inherited DialogKey(Key, Shift);
  if not (TGridOptionEh.AlwaysShowEditor in Options) and
         (Key = vkReturn) and
         (TGridOptionEh.Editing in Options) then
  begin
  end;
end;

procedure TCustomGridEh.UpdateHotTrackCellPos(ATrackColIndex, ATrackRowIndex: Integer);
begin
  if (FHotTrackCell.X <> ATrackColIndex) or (FHotTrackCell.Y <> ATrackRowIndex) then
  begin
    FHotTrackCell.X := ATrackColIndex;
    FHotTrackCell.Y := ATrackRowIndex;
    HotTrackCellPosChanged();
  end;
end;

function TCustomGridEh.UpdateOutBoundaryIndents: Boolean;
begin
  Result := False;
end;

procedure TCustomGridEh.HotTrackCellPosChanged();
begin
  Invalidate();
end;

{$REGION 'Mouse Staff'}

function TCustomGridEh.GetParentCell(AObj: TFmxObject): TGridBaseCellEh;
var
  ParentObj: TFmxObject;
begin
  ParentObj := AObj;
  Result := nil;
  while (ParentObj <> nil) do
  begin
    if ParentObj is TGridBaseCellEh then
    begin
      Result := TGridBaseCellEh(ParentObj);
      Break;
    end;
    ParentObj := ParentObj.Parent;
  end;
end;

procedure TCustomGridEh.ProcessPreviewVirtPanelMouseEnter(APanel: TLaHostVirtualPanelEh; Params: TControlParamsEh);
begin
end;

procedure TCustomGridEh.ProcessPreviewVirtPanelMouseLeave(APanel: TLaHostVirtualPanelEh; Params: TControlParamsEh);
var
  MousePosInPanel: TPointF;
begin
  MousePosInPanel := APanel.ScreenToLocal(Screen.MousePos);
  if TRectF.Create(0, 0, APanel.Width, APanel.Height).Contains(MousePosInPanel) = False then
//  if Params.OriginalObject = Self then
    Cursor := crDefault;
end;

procedure TCustomGridEh.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  CellHit: TGridCoord;
  AMoveIndex: Integer;
  VCellRect: TRect;
  Xi, Yi: Integer;
  GridMousePos, CellMousePos: TPoint;
  AScreenPos: TPointF;

  GridMouseParams: TControlMouseButtonParamsEh;
begin
  FMouseDownPos := PointF(X, Y).Round;

  Xi := Trunc(X);
  Yi := Trunc(Y);
  inherited MouseDown(Button, Shift, X, Y);

  HideEdit;
  if not (csDesigning in ComponentState) and
    (CanFocus {or (GetParentForm(Self) = nil)}) then
  begin
    SetFocus;
    if {not Focused}not IsActiveControl then
    begin
      Exit;
    end;
  end;
  if (Button = TMouseButton.mbLeft) and (ssDouble in Shift) then
  begin
    DblClick;
  end else if Button = TMouseButton.mbLeft then
  begin
    { Check grid sizing }
    CalcSizingState(Xi, Yi, FGridMouseState, FSizingIndex, FSizingPos, FSizingOfs);
    if FGridMouseState <> GridMouseStateManage.NormalState then
    begin
      if (FGridMouseState = GridMouseStateManage.ColSizingState) and UseRightToLeftAlignment then
        FSizingPos := ClientWidth - FSizingPos;
      InitSizingLines;
      DrawSizingLine;
      Exit;
    end;
    CellHit := MouseCoord(Xi, Yi);
    if (CellHit.X >= FixedColCount-FrozenColCount) and
       (CellHit.Y >= FixedRowCount-FrozenRowCount) and
       (CellHit.X < ColCount) and
       (CellHit.Y < RowCount) then
    begin
      if TGridOptionEh.Editing in Options then
      begin
        if (CellHit.X = FCurCellPos.X) and (CellHit.Y = FCurCellPos.Y) then
          ShowEditor
        else
        begin
          if TGridOptionEh.RangeSelect in Options then
          begin
            SetGridMouseState(GridMouseStateManage.SelectingState);
            SetGridTimer(True, 60);
            if ssShift in Shift then
              MoveAnchorCell(CellHit.X, CellHit.Y, True)
            else
              InteractiveFocusCell(CellHit.X, CellHit.Y, TInteractiveActionSourceEh.Mouse);
          end else
            InteractiveFocusCell(CellHit.X, CellHit.Y, TInteractiveActionSourceEh.Mouse);
          UpdateEdit;
        end;
        Click;
      end
      else
      begin
        if TGridOptionEh.RangeSelect in Options then
          SetGridMouseState(GridMouseStateManage.SelectingState);
        SetGridTimer(True, 60);
        if ssShift in Shift then
          MoveAnchorCell(CellHit.X, CellHit.Y, True)
        else
          InteractiveFocusCell(CellHit.X, CellHit.Y, TInteractiveActionSourceEh.Mouse);
      end;
    end
    else if (TGridOptionEh.RowMoving in Options) and
            (CellHit.X >= 0) and
            (CellHit.X < FixedColCount) and
            (CellHit.Y >= FixedRowCount) and
            (CellHit.Y < RowCount) then
    begin
      AMoveIndex := CellHit.Y;
      if CheckBeginRowDrag(AMoveIndex, AMoveIndex, Point(Xi,Yi)) then
      begin
        StartRowDrag(AMoveIndex, Point(Xi,Yi));
      end;
    end
    else if (TGridOptionEh.ColMoving in Options) and
            (CellHit.Y >= 0) and
            (CellHit.Y < FixedRowCount) and
            (CellHit.X >= FixedColCount) and
            (CellHit.X < ColCount) then
    begin
      VCellRect := CellRectAbs(CellHit.X, CellHit.Y);
      AMoveIndex := CellHit.X;
      AScreenPos := LocalToScreen(TPointF.Create(X, Y));
      if CheckBeginColumnDrag(AMoveIndex, AMoveIndex, Point(Xi,Yi)) then
        StartColMoving(AMoveIndex, CellHit.Y, AScreenPos);
    end;
  end;

  FMouseDownCell := MouseCoord(Xi, Yi);
  if (FMouseDownCell.X < 0) and (FMouseDownCell.Y < 0) then
  begin
    FMouseDownCell := MouseCoord(-1, -1);
  end else
  begin
    GridMouseParams := TControlMouseButtonParamsEh.Create;
    GridMouseParams.Init(Button, Xi, Yi, Shift, Self);

    VCellRect := CellRectAbs(FMouseDownCell.X, FMouseDownCell.Y);
    GridMousePos := Point(Xi, Yi);
    CellMousePos := Point(Xi - VCellRect.Left, Yi - VCellRect.Top);

    ProcessCellMouseDown(FMouseDownCell.X, FMouseDownCell.Y, CellMousePos.X, CellMousePos.Y, VCellRect, GridMouseParams);

    GridMouseParams.Free;
  end;

end;

procedure TCustomGridEh.ProcessCellMouseDown(AColIndex, ARowIndex,
  InCellX, InCellY: Integer; const ACellRect: TRect;  GridMouseParams: TControlMouseButtonParamsEh);
begin
end;

procedure TCustomGridEh.CellMouseDown(ACellMan: TBaseGridCellManagerEh; ACellMouseParams:  TGridCellMouseButtonParamsEh);
begin
end;

procedure TCustomGridEh.ProcessVirtPanelMouseMove(APanel: TLaHostVirtualPanelEh; MouseParams: TControlMouseParamsEh);
begin
end;

procedure TCustomGridEh.ProcessVirtPanelMouseUp(APanel: TLaHostVirtualPanelEh; MouseParams: TControlMouseButtonParamsEh);
begin
end;

procedure TCustomGridEh.ProcessPreviewVirtPanelMouseDown(APanel: TLaHostVirtualPanelEh; MouseParams: TControlMouseButtonParamsEh);
var
  LocalMousePos: TPointF;
  Xi, Yi: Integer;
  PanelPos: TPointF;
  NewGridMouseState: TBaseGridMouseStateEh;
  ParentCell: TGridBaseCellEh;
begin
  LocalMousePos := MouseParams.GetPositionRelativeTo(Self);
  FMouseDownPos := LocalMousePos.Round;
  FAniCalcPosChanged := False;

  ParentCell := GetParentCell(MouseParams.OriginalObject);

  if not (csDesigning in ComponentState) and
    (CanFocus {or (GetParentForm(Self) = nil)}) and
    (ContainsFocus = False) then
  begin
    SetFocus;
    if {not Focused}not IsActiveControl then
    begin
      Exit;
    end;
  end;

  Xi := Round(LocalMousePos.X);
  Yi := Round(LocalMousePos.Y);
  if MouseParams.Button = TMouseButton.mbLeft then
  begin
    if (FAniCalculations.CurrentVelocity.X <> 0) or
       (FAniCalculations.CurrentVelocity.Y <> 0) then
    begin
      PanelPos := MouseParams.GetPositionRelativeTo(HDataVDataPanel);
      AniMouseDown(ssTouch in MouseParams.Shift, PanelPos.X, PanelPos.Y);
    end;

    { Check grid sizing }
    NewGridMouseState := GridMouseStateManage.NormalState;
    CalcSizingState(Xi, Yi, NewGridMouseState, FSizingIndex, FSizingPos, FSizingOfs);
    if NewGridMouseState <> GridMouseStateManage.NormalState then
    begin
      SetGridMouseState(NewGridMouseState);
      if (FGridMouseState = GridMouseStateManage.ColSizingState) and UseRightToLeftAlignment then
        FSizingPos := ClientWidth - FSizingPos;
      Capture;
      InitSizingLines;
      DrawSizingLine;
      MouseParams.Handled := True;
      Exit;
    end;

    FMouseDownCell := MouseCoord(Xi, Yi);

    if (FAniCalculations.TouchTracking = []) then
      DoMousePreviewHitCell(FMouseDownCell, ParentCell, MouseParams);
  end;
end;

procedure TCustomGridEh.DoMousePreviewHitCell(CellHitCoord: TGridCoord; AParentCell: TGridBaseCellEh; MouseParams: TControlMouseButtonParamsEh);
begin
  FHitCellFocused := False;
  if (CellHitCoord.X >= FixedColCount-FrozenColCount) and
     (CellHitCoord.Y >= FixedRowCount-FrozenRowCount) and
     (CellHitCoord.X < ColCount) and
     (CellHitCoord.Y < RowCount) then
  begin
    if (CellHitCoord.X = FCurCellPos.X) and
       (CellHitCoord.Y = FCurCellPos.Y) then
    begin
      DoNothing();
//      ShowEditor;
    end else
    begin
      if TGridOptionEh.RangeSelect in Options then
      begin
        SetGridMouseState(GridMouseStateManage.SelectingState);
        SetGridTimer(True, 60);
        if ssShift in MouseParams.Shift then
          MoveAnchorCell(CellHitCoord.X, CellHitCoord.Y, True)
        else
          InteractiveFocusCell(CellHitCoord.X, CellHitCoord.Y, TInteractiveActionSourceEh.Mouse);
      end else
        InteractiveFocusCell(CellHitCoord.X, CellHitCoord.Y, TInteractiveActionSourceEh.Mouse);
      FHitCellFocused := True;
      UpdateEdit;
    end;
  end;
end;

procedure TCustomGridEh.ProcessVirtPanelMouseDown(APanel: TLaHostVirtualPanelEh; MouseParams: TControlMouseButtonParamsEh);
var
  ParentCell: TGridBaseCellEh;
begin
  ParentCell := GetParentCell(MouseParams.OriginalObject);
  if MouseParams.Button = TMouseButton.mbLeft then
  begin
    if (FAniCalculations.TouchTracking = []) then
      DoHitCell(FMouseDownCell, ParentCell, MouseParams);
  end;
end;

procedure TCustomGridEh.DoHitCell(CellHitCoord: TGridCoord; AParentCell: TGridBaseCellEh; MouseParams: TControlMouseButtonParamsEh);
var
  CanMouseShowEditor: Boolean;
begin
  if (CellHitCoord.X >= FixedColCount-FrozenColCount) and
     (CellHitCoord.Y >= FixedRowCount-FrozenRowCount) and
     (CellHitCoord.X < ColCount) and
     (CellHitCoord.Y < RowCount) then
  begin
    if AParentCell <> nil then
      CanMouseShowEditor := AParentCell.CanMouseDownShowEditor(CellHitCoord, AParentCell, MouseParams)
    else
      CanMouseShowEditor := False;

    if (CellHitCoord.X = FCurCellPos.X) and
       (CellHitCoord.Y = FCurCellPos.Y) and
       (FHitCellFocused = False) and
       (CanMouseShowEditor = True) then
    begin
      ShowEditor;
    end;
  end;
end;

procedure TCustomGridEh.MouseMove(Shift: TShiftState; X, Y: Single);
var
  CellHit: TGridCoord;
  CheckMoveAndScroll: Boolean;
  MinCell, MaxCell: TGridCoord;
  Xi, Yi: Integer;

  GridMouseParams: TControlMouseParamsEh;
  VCellRect: TRect;
  AInCellX, AInCellY: Integer;
begin
  Xi := Trunc(X);
  Yi := Trunc(Y);
  FMouseMovePos := Point(Xi, Yi);
  CellHit := MouseCoord(Xi, Yi);
  if (FGridMouseState = GridMouseStateManage.SelectingState) or
     (FGridMouseState = GridMouseStateManage.ColMovingState) or
     (FGridMouseState = GridMouseStateManage.RowMovingState) then
  begin
    if csDesigning in ComponentState then
      CheckMoveAndScroll := True
    else
    begin
      CheckMoveAndScroll := False;

      MinCell.X := FixedColCount-FrozenColCount;
      MaxCell.X := Min(HorzAxis.RollLastFullVisCel+HorzAxis.FixedCelCount, HorzAxis.CelCount-1);

      MinCell.Y := FixedRowCount-FrozenRowCount;
      MaxCell.Y := Min(VertAxis.RollLastFullVisCel+VertAxis.FixedCelCount, VertAxis.CelCount-1);

      if FGridMouseState = GridMouseStateManage.SelectingState then
      begin
        if (CellHit.X >= MinCell.X) and (CellHit.X <= MaxCell.X) then
        begin
          CheckMoveAndScroll := True;
          if (CellHit.Y < MinCell.Y) or (CellHit.Y > MaxCell.Y) then
            CellHit.Y := FAnchorCell.Y;
        end else
        begin
          if (CellHit.Y >= MinCell.Y) and (CellHit.Y <= MaxCell.Y) then
          begin
            CheckMoveAndScroll := True;
            if (CellHit.X < MinCell.X) or (CellHit.X > MaxCell.X) then
              CellHit.X := FAnchorCell.X;
          end;
        end;
      end;
    end;

    if CheckMoveAndScroll then
    begin
      if (FGridMouseState = GridMouseStateManage.SelectingState) then
      begin
        if ((CellHit.X <> FAnchorCell.X) or (CellHit.Y <> FAnchorCell.Y)) then
          MoveAnchorCell(CellHit.X, CellHit.Y, True);
      end
      else if (FGridMouseState = GridMouseStateManage.ColMovingState) then
      begin
        MoveAndScroll(Xi, CellHit.X, HorzAxis, SB_HORZ_EH, Point(Xi,Yi))
      end
      else if (FGridMouseState = GridMouseStateManage.RowMovingState) then
      begin
        MoveAndScroll(Yi, CellHit.Y, VertAxis, SB_VERT_EH, Point(Xi,Yi));
      end;
    end;
  end
  else if (FGridMouseState = GridMouseStateManage.RowSizingState) or
          (FGridMouseState = GridMouseStateManage.ColSizingState) then
  begin
    DrawSizingLine; { XOR it out }
    if GridMouseState = GridMouseStateManage.RowSizingState then
      FSizingPos := Yi + FSizingOfs else
      FSizingPos := Xi + FSizingOfs;
    DrawSizingLine; { XOR it back in }
  end else
  begin
    
  end;
  inherited MouseMove(Shift, X, Y);

  if FAniCalculations.Down then
  begin
    AniMouseMove(ssTouch in Shift, X, Y);
  end
  else
  begin
    GridMouseParams := TControlMouseParamsEh.Create;
    GridMouseParams.Init(Xi, Yi, Shift, Self);

    begin
      if (CellHit.X >= 0) and (CellHit.Y >= 0) then
      begin
        VCellRect := CellRectAbs(CellHit.X, CellHit.Y, True);
        AInCellX := Xi - VCellRect.Left;
        AInCellY := Yi - VCellRect.Top;
      end else
      begin
        VCellRect := EmptyRect;
        AInCellX := -1;
        AInCellY := -1;
      end;

      ProcessCellMouseMove(CellHit.X, CellHit.Y, AInCellX, AInCellY, VCellRect, GridMouseParams, GridMouseParams);
    end;

    GridMouseParams.Free;
  end;
end;

procedure TCustomGridEh.ProcessCellMouseMove(AColIndex, ARowIndex,
  AInCellX, AInCellY: Integer; const ACellRect: TRect;
  AGridMouseParams: TControlMouseParamsEh; ALaObjectMouseParams: TControlMouseParamsEh);
var
  ACellMouseParams: TGridCellMouseParamsEh;
  LocalMousePos: TPoint;
  MouseDelta: TPoint;
  NewRollPosX: Int64;
  NewRollPosY: Int64;
  NewCursor: TCursor;
begin
  if (FMouseDownPos.X >= 0) and
     (FMouseDownPos.Y >= 0) and
     (FAniCalculations.Down = False) then
  begin
    LocalMousePos := AGridMouseParams.GetPositionRelativeTo(Self).Round;
    MouseDelta.X := LocalMousePos.X - FMouseDownPos.X;
    MouseDelta.Y := LocalMousePos.Y - FMouseDownPos.Y;
    NewRollPosX := HorzAxis.CheckRollStartVisPos(HorzAxis.RollStartVisPos - MouseDelta.X);
    NewRollPosY := VertAxis.CheckRollStartVisPos(VertAxis.RollStartVisPos - MouseDelta.Y);
    if ( ((NewRollPosX <> HorzAxis.RollStartVisPos) and
         (ttHorizontal in FAniCalculations.TouchTracking))
        or
        ((NewRollPosY <> VertAxis.RollStartVisPos) and
         (ttVertical in FAniCalculations.TouchTracking)) )
    then
    begin
      StartAniMove(ssTouch in ALaObjectMouseParams.Shift, FMouseDownPos, LocalMousePos);
    end;
  end;

  UpdateHotTrackCellPos(AColIndex, ARowIndex);
  ACellMouseParams := TGridCellMouseParamsEh.Create;
  ACellMouseParams.Init(Self, AColIndex, ARowIndex, AColIndex, ARowIndex, ACellRect, AInCellX, AInCellY, ALaObjectMouseParams);
  SetPotentialMouseState(ACellMouseParams);

  NewCursor := GetCursorAtMousePos(ACellMouseParams);
//  if NewCursor <> crDefault then
  Cursor := NewCursor;

  CellMouseMove(nil, ACellMouseParams);
  ACellMouseParams.Free;
end;

procedure TCustomGridEh.ProcessPreviewVirtPanelMouseMove(APanel: TLaHostVirtualPanelEh; ControlMouseParams: TControlMouseParamsEh);
var
  LocalMousePos: TPointF;
  CellHit: TGridCoord;
  GridMouseParams: TControlMouseParamsEh;
  VCellRect: TRect;
  AInCellX, AInCellY: Integer;
  Xi, Yi: Integer;
begin

  LocalMousePos := ControlMouseParams.GetPositionRelativeTo(Self);
  Xi := Round(LocalMousePos.X);
  Yi := Round(LocalMousePos.Y);

  CellHit := MouseCoord(Xi, Yi);

  GridMouseParams := TControlMouseParamsEh.Create;
  GridMouseParams.Init(Xi, Yi, ControlMouseParams.Shift, Self);

  if (CellHit.X >= 0) and (CellHit.Y >= 0) then
  begin
    VCellRect := CellRectAbs(CellHit.X, CellHit.Y, True);
    AInCellX := Xi - VCellRect.Left;
    AInCellY := Yi - VCellRect.Top;
  end else
  begin
    VCellRect := EmptyRect;
    AInCellX := -1;
    AInCellY := -1;
  end;

  ProcessCellMouseMove(CellHit.X, CellHit.Y, AInCellX, AInCellY, VCellRect, GridMouseParams, ControlMouseParams);

  GridMouseParams.Free;
end;

procedure TCustomGridEh.SetPotentialMouseState(ACellMouseParams: TGridCellMouseParamsEh);
var
  Index: Integer;
  SizingPos, SizingOfs: Integer;
  InGridPos: TPoint;
begin
  InGridPos := ACellMouseParams.BaseParams.GetPositionRelativeTo(Self).Round;
  if FGridMouseState = GridMouseStateManage.NormalState then
  begin
    CalcSizingState(InGridPos.X, InGridPos.Y, FGridPotentialMouseState, Index, SizingPos, SizingOfs);
  end else
  begin
    FGridPotentialMouseState := FGridMouseState;
  end;
end;

procedure TCustomGridEh.SetGridMouseState(AGridMouseState: TBaseGridMouseStateEh);
begin
  if FGridMouseState <> nil then
    TBaseGridMouseStateEhCrack(FGridMouseState).Release;
  FGridMouseState := AGridMouseState;
//  if FGridMouseState <> nil then
//    TBaseGridMouseStateEhCrack(FGridMouseState).Init();
end;

procedure TCustomGridEh.CellMouseMove(ACellMan: TBaseGridCellManagerEh; ACellMouseParams:  TGridCellMouseParamsEh);
begin
  if ACellMan <> nil then
    ACellMan.ProcessMouseMove(ACellMouseParams);
end;

procedure TCustomGridEh.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  NewSize: Integer;
  Xi, Yi: Integer;
  CellCoord: TGridCoord;
  GridMouseParams: TControlMouseButtonParamsEh;
  VCellRect: TRect;
  CellMousePos: TPoint;
//  AMoveFromIndex, AMoveToIndex: Integer;
begin
  Xi := Trunc(X);
  Yi := Trunc(Y);
  CellCoord := MouseCoord(Xi, Yi);
  GridMouseParams := TControlMouseButtonParamsEh.Create;
  GridMouseParams.Init(Button, Xi, Yi, Shift, Self);

  try
    if (FGridMouseState = GridMouseStateManage.SelectingState) then
    begin
      MouseMove(Shift, X, Y);
      SetGridTimer(False, 0);
      UpdateEdit;
      Click;
    end
    else if (FGridMouseState = GridMouseStateManage.RowSizingState) or
            (FGridMouseState = GridMouseStateManage.ColSizingState) then
    begin
      DrawSizingLine;
      if (FGridMouseState = GridMouseStateManage.ColSizingState) and UseRightToLeftAlignment then
        FSizingPos := ClientWidth - FSizingPos;
      if FGridMouseState = GridMouseStateManage.ColSizingState then
      begin
        NewSize := ResizeLine(HorzAxis);
        if (NewSize > 1) and (ColWidths[FSizingIndex] <> NewSize) then
        begin
          InteractiveSetColWidth(FSizingIndex, NewSize);
          UpdateDesigner;
        end;
      end
      else
      begin
        NewSize := ResizeLine(VertAxis);
        if NewSize > 1 then
        begin
          InteractiveSetRowHeight(FSizingIndex, NewSize);
          UpdateDesigner;
        end;
      end;
      HideSizingLine;
    end
    else if (GridMouseState = GridMouseStateManage.ColMovingState) then
    begin
      HideMove;
      SetGridTimer(False, 0);
      if EndColumnDrag(GridMouseStateManage.ColMovingState, Point(Xi,Yi))
        and (GridMouseStateManage.ColMovingState.MoveFromIndex <> GridMouseStateManage.ColMovingState.MoveToIndex) then
      begin
        InteractiveMoveColumn(GridMouseStateManage.ColMovingState);
        UpdateDesigner;
      end;
      UpdateEdit;
    end
    else if (GridMouseState = GridMouseStateManage.RowMovingState) then
    begin
      HideMove;
      SetGridTimer(False, 0);
      if EndRowDrag(GridMouseStateManage.RowMovingState, Point(Xi,Yi))
        and (GridMouseStateManage.RowMovingState.MoveFromIndex <> GridMouseStateManage.RowMovingState.MoveToIndex) then
      begin
        MoveRow(GridMouseStateManage.RowMovingState.MoveFromIndex, GridMouseStateManage.RowMovingState.MoveToIndex);
        UpdateDesigner;
      end;
      UpdateEdit;
    end else
    begin
      if (FAniCalculations.TouchTracking <> []) and
         (FAniCalcPosChanged = False)
      then
        DoHitCell(FMouseDownCell, nil, GridMouseParams);
      UpdateEdit;
    end;

    inherited MouseUp(Button, Shift, X, Y);

    if (CellCoord.X >= 0) and (CellCoord.Y >= 0) then
    begin
      VCellRect := CellRectAbs(CellCoord.X, CellCoord.Y);
      CellMousePos := Point(Xi - VCellRect.Left, Yi - VCellRect.Top);
    end else
    begin
      VCellRect := TRect.Empty;
      CellMousePos := TPoint.Zero;
    end;

    ProcessCellMouseUp(CellCoord.X, CellCoord.Y, CellMousePos.X, CellMousePos.Y, VCellRect, GridMouseParams);

  finally
    GridMouseParams.Free;
    if FGridMouseState <> GridMouseStateManage.NormalState then
    begin
      SetGridMouseState(GridMouseStateManage.NormalState);
      Invalidate;
    end else
    begin
    end;
  end;

  FMouseDownCell := GridCoord(-1, -1);
  FAniCalcPosChanged := False;
end;

procedure TCustomGridEh.ProcessPreviewVirtPanelMouseUp(APanel: TLaHostVirtualPanelEh; MouseParams: TControlMouseButtonParamsEh);
var
  PanelPos: TPointF;
begin
  if FAniCalculations.Down then
  begin
    PanelPos := MouseParams.GetPositionRelativeTo(HDataVDataPanel);
    AniMouseUp(ssTouch in MouseParams.Shift, PanelPos.X, PanelPos.Y);
  end;
  FMouseDownPos := TPoint.Create(-1, -1);
end;

procedure TCustomGridEh.ProcessPreviewVirtPanelMouseClick(APanel: TLaHostVirtualPanelEh; MouseParams: TControlMouseButtonParamsEh);
var
  PanelPos: TPointF;
begin
  if FAniCalculations.Down then
  begin
    PanelPos := MouseParams.GetPositionRelativeTo(HDataVDataPanel);
    AniMouseUp(ssTouch in MouseParams.Shift, PanelPos.X, PanelPos.Y);
  end;

  if (FGridMouseState = GridMouseStateManage.NormalState) then
  begin
    if (FAniCalculations.TouchTracking <> []) and
       (FAniCalcPosChanged = False)
    then
      DoMousePreviewHitCell(FMouseDownCell, nil, MouseParams);
  end;
end;

procedure TCustomGridEh.ProcessVirtPanelMouseClick(APanel: TLaHostVirtualPanelEh;
  MouseParams: TControlMouseButtonParamsEh);
begin
end;

procedure TCustomGridEh.ProcessCellMouseUp(AColIndex, ARowIndex,
  InCellX, InCellY: Integer; const ACellRect: TRect;  GridMouseParams: TControlMouseButtonParamsEh);
var
  GridPos: TPointF;
begin
  if FAniCalculations.Down then
  begin
    GridPos := GridMouseParams.GetPositionRelativeTo(Self);
    AniMouseUp(ssTouch in GridMouseParams.Shift, GridPos.X, GridPos.Y);
  end;
   FMouseDownPos := TPoint.Create(-1, -1);
end;

procedure TCustomGridEh.CellMouseUp(ACellMan: TBaseGridCellManagerEh; ACellMouseParams:  TGridCellMouseButtonParamsEh);
begin
  ACellMan.ProcessControlMouseUp(ACellMouseParams);
end;

procedure TCustomGridEh.ProcessShowVirtPanelContextMenu(APanel: TLaHostVirtualPanelEh; Params: TControlShowContextMenuParamsEh);
var
  BaseCell: TGridBaseCellHolderEh;
  ACellParams: TBaseGridCellShowContextMenuParamsEh;
begin
  if Params.OriginalObject is TLaObjectEh then
  begin
    BaseCell := TGridBaseCellHolderEh(TVPBaseCellHolderEh.GetParentCell(TLaObjectEh(Params.OriginalObject)));
    ACellParams := TBaseGridCellShowContextMenuParamsEh.Create;
    try
      ACellParams.Init(Self, BaseCell.CellClient, Params);
      CellShowContextMenu(BaseCell.CellManager, ACellParams);
      if ACellParams.Handled = True then
        Params.Handled := True;
    finally
      ACellParams.Free;
    end;
  end;
end;

procedure TCustomGridEh.ProcessPreviewVirtPanelDblClick(
  APanel: TLaHostVirtualPanelEh; MouseParams: TControlParamsEh);
begin

end;

procedure TCustomGridEh.CellShowContextMenu(ACellManager: TBaseGridCellManagerEh; ACellParams:  TBaseGridCellShowContextMenuParamsEh);
begin
  ACellManager.ShowContextMenu(ACellParams);
end;

procedure TCustomGridEh.MouseWheel(Shift: TShiftState; WheelDelta: Integer;
  var Handled: Boolean);
begin
  inherited MouseWheel(Shift, WheelDelta, Handled);
  if (WheelDelta < 0) then
    Handled := DoMouseWheelDown(Shift, ScreenToLocal(Screen.MousePos).Round)
  else
    Handled := DoMouseWheelUp(Shift, ScreenToLocal(Screen.MousePos).Round);
end;

procedure TCustomGridEh.CellMouseClick(const Cell: TGridCoord;
  Button: TMouseButton; Shift: TShiftState; const ACellRect: TRect;
  const GridMousePos, CellMousePos: TPoint);
begin
end;

procedure TCustomGridEh.DefaultCellMouseClick(const Cell: TGridCoord;
  Button: TMouseButton; Shift: TShiftState; const ACellRect: TRect;
  const GridMousePos, CellMousePos: TPoint);
begin
end;

function TCustomGridEh.CheckCellCanSendDoubleClicks(CellHit: TGridCoord;
  Button: TMouseButton; ShiftState: TShiftState;
  MousePos, InCellMousePos: TPoint): Boolean;
begin
  Result := True;
end;

procedure TCustomGridEh.MoveAndScroll(Mouse, CellHit: Integer;
  Axis: TGridAxisDataEh; Scrollbar: Integer; const MousePt: TPoint);
var
  VCellRect: TRect;

  function SkipHiddenCells(AIndex: Integer): Integer;
  var
    i: Integer;
  begin
    Result := 0;
    for i := AIndex to ColCount-1  do
    begin
      if ColWidths[i] > 0 then Exit;
      Inc(Result);
    end;
  end;

begin
  if UseRightToLeftAlignment and (ScrollBar = SB_HORZ_EH) then
    Mouse := ClientWidth - Mouse;

  if Axis = HorzAxis
    then VCellRect := CellRect(CellHit, 0)
    else VCellRect := CellRect(0, CellHit);

  if (FGridMouseState = GridMouseStateManage.ColMovingState) then
  begin
    if GridMouseStateManage.ColMovingState.MoveFromIndex >= 0 then
    begin
      if (ColWidths[GridMouseStateManage.ColMovingState.MoveFromIndex] <= 0) and
         (CellHit = GridMouseStateManage.ColMovingState.MoveFromIndex + 1 + SkipHiddenCells(GridMouseStateManage.ColMovingState.MoveFromIndex + 1)) and
         (VCellRect.Left + (ColWidths[CellHit] div 2) > Mouse)
      then
        GridMouseStateManage.ColMovingState.MovePosRightSite := False
      else if GridMouseStateManage.ColMovingState.MoveToIndex > GridMouseStateManage.ColMovingState.MoveFromIndex then
        GridMouseStateManage.ColMovingState.MovePosRightSite := True
      else
        GridMouseStateManage.ColMovingState.MovePosRightSite := False;
    end;

    if not ( (Axis.RollStartVisibleCellOffset = 0) and
               (GridMouseStateManage.ColMovingState.MoveToIndex = Axis.FixedCelCount) and
               (Mouse < Axis.FixedBoundary)
             )
    then
    begin
      if (Mouse < Axis.FixedBoundary) then
      begin
        if (GridMouseStateManage.ColMovingState.MoveToIndex > Axis.FixedCelCount) or
           (Axis.RollStartVisibleCellOffset > 0) then
        begin
          ScrollBarMessage(ScrollBar, SB_LINEUP_EH, 0, False);
        end;
        CellHit := Axis.StartVisCel;
      end
      else if (Mouse >= Axis.GridClientStop) then
      begin
        if not Axis.InEndOfRol then
        begin
          ScrollBarMessage(Scrollbar, SB_LINEDOWN_EH, 0, False);
        end;
        CellHit := Axis.RollLastFullVisCel + Axis.FixedCelCount;
      end
      else if (CellHit = -1) and (Mouse >= HorzAxis.RollInClientBoundary) then
        CellHit := HorzAxis.CelCount - 1
      else if CellHit < 0 then
        CellHit := GridMouseStateManage.ColMovingState.MoveToIndex;

      if ((FGridMouseState = GridMouseStateManage.ColMovingState) and
          CheckColumnDrag(GridMouseStateManage.ColMovingState, CellHit, MousePt)) then
      begin
//        GridMouseStateManage.ColMovingState.MoveFromIndex := NewMoveFromIndex;
        VCellRect := CellRect(CellHit, 0);
        if UseRightToLeftAlignment and (MousePt.X > VCellRect.Left + RectWidth(VCellRect) / 2) then
          GridMouseStateManage.ColMovingState.MoveToIndex := CellHit
        else if not UseRightToLeftAlignment and (MousePt.X < VCellRect.Left + RectWidth(VCellRect) / 2) then
          GridMouseStateManage.ColMovingState.MoveToIndex := CellHit
        else
          GridMouseStateManage.ColMovingState.MoveToIndex := CellHit + 1;

        GridMouseStateManage.ColMovingState.MovePosRightSite := False;
      end;
    end
    else if ((FGridMouseState = GridMouseStateManage.RowMovingState) and
             CheckRowDrag(GridMouseStateManage.RowMovingState, CellHit, MousePt)) then
    begin
      GridMouseStateManage.RowMovingState.MoveToIndex := CellHit;
      //GridMouseStateManage.RowMovingState.MovePosRightSite := AMovePosRightSite;
    end;
    DrawMove;
  end;
end;

procedure TCustomGridEh.UpdateAniCalculations();
var
  I, J: Integer;
  LTargets: array of TAniCalculations.TTarget;
  NewTargets: array of TAniCalculations.TTarget;
begin
  SetLength(LTargets, FAniCalculations.TargetCount);
  FAniCalculations.GetTargets(LTargets);
  SetLength(NewTargets, 2);

  NewTargets[0].TargetType := TAniCalculations.TTargetType.Min;
  NewTargets[0].Point := TPointF.Create(0, 0);
  NewTargets[1].TargetType := TAniCalculations.TTargetType.Max;
  NewTargets[1].Point := TPointD.Create(
                          System.Math.Max(0, HorzAxis.RollLen - HorzAxis.RollClientLen),
                          System.Math.Max(0, VertAxis.RollLen - VertAxis.RollClientLen));

  for I := 0 to Length(LTargets) - 1 do
  begin
    if not (LTargets[I].TargetType in
              [TAniCalculations.TTargetType.Min,
              TAniCalculations.TTargetType.Max]) then
    begin
      J := Length(NewTargets);
      SetLength(NewTargets, J + 1);
      NewTargets[J].TargetType := LTargets[I].TargetType;
      NewTargets[J].Point := LTargets[I].Point;
    end;
  end;
  FAniCalculations.SetTargets(NewTargets);
end;

procedure TCustomGridEh.AniCalcChange(Sender: TObject);
var
  XRolPos, YRolPos: Integer;
begin
  XRolPos := HorzAxis.CheckRollStartVisPos(Round(FAniCalculations.ViewportPosition.X));
  YRolPos := VertAxis.CheckRollStartVisPos(Round(FAniCalculations.ViewportPosition.Y));
  if (XRolPos <> HorzAxis.RollStartVisPos) or
     (YRolPos <> VertAxis.RollStartVisPos) then
  begin
    FAniCalcPosChanged := True;
    HorzAxis.RollStartVisPos := XRolPos;
    VertAxis.RollStartVisPos := YRolPos;
  end;
end;

procedure TCustomGridEh.AniCalcStart(Sender: TObject);
begin

end;

procedure TCustomGridEh.AniCalcStop(Sender: TObject);
begin

end;

procedure TCustomGridEh.AniMouseDown(const Touch: Boolean; const X, Y: Single);
var
  ScreenPos, PanelPos: TPointF;
begin
  ScreenPos := LocalToScreen(TPointF.Create(X, Y));
  PanelPos := HDataVDataPanel.ScreenToLocal(ScreenPos);
  FAniCalculations.Averaging := Touch;
  FAniCalculations.MouseDown(PanelPos.X, PanelPos.Y);
end;

procedure TCustomGridEh.AniMouseMove(const Touch: Boolean; const X, Y: Single);
var
  ScreenPos, PanelPos: TPointF;
begin
  ScreenPos := LocalToScreen(TPointF.Create(X, Y));
  PanelPos := HDataVDataPanel.ScreenToLocal(ScreenPos);
  FAniCalculations.MouseMove(PanelPos.X, PanelPos.Y);
end;

procedure TCustomGridEh.AniMouseUp(const Touch: Boolean; const X, Y: Single);
var
  ScreenPos, PanelPos: TPointF;
begin
  ScreenPos := LocalToScreen(TPointF.Create(X, Y));
  PanelPos := HDataVDataPanel.ScreenToLocal(ScreenPos);
  FAniCalculations.MouseUp(PanelPos.X, PanelPos.Y);
end;

procedure TCustomGridEh.StartAniMove(const Touch: Boolean; MouseDownPos, MouseMovePos: TPoint);
begin
  AniMouseDown(Touch, MouseDownPos.X, MouseDownPos.Y);
  AniMouseMove(Touch, MouseMovePos.X, MouseMovePos.Y);
  Capture;
end;

{$ENDREGION 'Mouse Staff'}

function TCustomGridEh.GetColWidths(Index: Integer): Integer;
begin
  Result := HorzAxis.CelLens[Index];
end;

function TCustomGridEh.GetRowHeights(Index: Integer): Integer;
begin
  Result := VertAxis.CelLens[Index];
end;

procedure TCustomGridEh.SetCurColIndex(const Value: Integer);
begin
  if CurColIndex <> Value then
    FocusCell(Value, CurRowIndex, True);
end;

procedure TCustomGridEh.SetCurRowIndex(const Value: Integer);
begin
  if CurRowIndex <> Value then
    FocusCell(CurColIndex, Value, True);
end;

procedure TCustomGridEh.SetVertScrollBar(const Value: TGridScrollBarEh);
begin
  FVertScrollBar.Assign(Value);
end;

procedure TCustomGridEh.SetHorzScrollBar(const Value: TGridScrollBarEh);
begin
  FHorzScrollBar.Assign(Value);
end;

function TCustomGridEh.GetTabStops(Index: Integer): Boolean;
begin
  Result := True;
end;

procedure TCustomGridEh.SetFixedColor(Value: TAlphaColor);
begin
  if FFixedColor <> Value then
  begin
    FFixedColor := Value;
    InvalidateGrid;
  end;
end;

procedure TCustomGridEh.SetEditorMode(Value: Boolean);
begin
  if not Value then
  begin
    CheckHideEditor;
  end else
  begin
    ShowEditor;
  end;
end;

procedure TCustomGridEh.SetGridLineWidth(Value: Integer);
begin
  if FGridLineWidth <> Value then
  begin
    FGridLineWidth := Value;
    InvalidateGrid;
  end;
end;

function TCustomGridEh.VertLineWidth: Integer;
begin
  if GridLineOptions.VertLinesVisible
    then Result := 0
    else Result := GridLineWidth;
end;

function TCustomGridEh.HorzLineWidth: Integer;
begin
  if GridLineOptions.HorzLinesVisible
    then Result := 0
    else Result := GridLineWidth;
end;

function TCustomGridEh.CalcColRangeWidth(FromCol, RangeColCount: Integer): Int64;
var
  i: Integer;
  InFixedToCol, InRolToCol, InContraFormCol: Integer;
  InRolStart: Integer;
begin
  Result := 0;
  if RangeColCount <= 0 then Exit;

  if FromCol < FixedColCount then
  begin
    if FromCol + RangeColCount <= FixedColCount
      then InFixedToCol := FromCol + RangeColCount
      else InFixedToCol := FixedColCount;

    for i := FromCol to InFixedToCol-1 do
      Inc(Result, ColWidths[i]);
  end;

  if (FromCol < ColCount) and (FromCol + RangeColCount > FixedColCount) then
  begin
    if (FromCol > FixedColCount - 1)
      then InRolStart := HorzAxis.RollLocCelPosArr[FromCol]
      else InRolStart := 0;

    if FromCol + RangeColCount <= ColCount
      then InRolToCol := FromCol + RangeColCount - 1
      else InRolToCol := ColCount - FixedColCount - 1;

    Inc(Result, HorzAxis.RollLocCelPosArr[InRolToCol] - InRolStart);
  end;

  if FromCol + RangeColCount > ColCount then
  begin
    if FromCol > ColCount
      then InContraFormCol := FromCol
      else InContraFormCol := ColCount;

    for i := InContraFormCol to FromCol + RangeColCount - 1 do
      Inc(Result, ColWidths[i]);
  end;
end;

function TCustomGridEh.CalcRowRangeHeight(FromRow, RangeRowCount: Integer): Int64;
var
  i: Integer;
  InFixedToRow, InRolToRow, InContraFormRow: Integer;
  InRolStart: Integer;
begin
  Result := 0;
  if RangeRowCount = 0 then Exit;

  if FromRow < FixedRowCount then
  begin
    if FromRow + RangeRowCount <= FixedRowCount
      then InFixedToRow := FromRow + RangeRowCount
      else InFixedToRow := FixedRowCount;

    for i := FromRow to InFixedToRow-1 do
      Inc(Result, RowHeights[i]);
  end;

  if (FromRow < RowCount) and (FromRow + RangeRowCount > FixedRowCount) then
  begin
    if (FromRow > FixedRowCount - 1)
      then InRolStart := VertAxis.RollLocCelPosArr[FromRow]
      else InRolStart := 0;

    if FromRow + RangeRowCount <= RowCount
      then InRolToRow := FromRow + RangeRowCount - 1
      else InRolToRow := RowCount - FixedRowCount - 1;

    Inc(Result, VertAxis.RollLocCelPosArr[InRolToRow] - InRolStart);
  end;

  if FromRow + RangeRowCount > RowCount then
  begin
    if FromRow > RowCount
      then InContraFormRow := FromRow
      else InContraFormRow := RowCount;

    for i := InContraFormRow to FromRow + RangeRowCount - 1 do
      Inc(Result, RowHeights[i]);
  end;
end;

procedure TCustomGridEh.SetOptions(Value: TGridOptionsEh);
begin
  if FOptions <> Value then
  begin
    if TGridOptionEh.RowSelect in Value then
      Exclude(Value, TGridOptionEh.AlwaysShowEditor);
    FOptions := Value;
    if not FEditorMode then
    begin
      if TGridOptionEh.AlwaysShowEditor in Value then
      begin
        ShowEditor;
      end else
      begin
        if EditorMode then
          HideEditor(False);
      end;
    end;
    if TGridOptionEh.RowSelect in Value then
    begin
      MoveColRow(CurColIndex, CurRowIndex,  True, False);
    end;
    if IsCanvasEnabled then
      UpdateBoundaries;
    InvalidateGrid;
  end;
end;

procedure TCustomGridEh.UpdateText(EditorChanged: Boolean);
begin
end;

function TCustomGridEh.GetCursorAtMousePos(Params: TGridCellMouseParamsEh): TCursor;
begin
  if FGridPotentialMouseState = GridMouseStateManage.RowSizingState then
    Result := crVSplit
  else if FGridPotentialMouseState = GridMouseStateManage.ColSizingState then
    Result := crHSplit
  else
    Result := crDefault;
end;

procedure TCustomGridEh.CancelMode;
begin
  try
    if (FGridMouseState = GridMouseStateManage.SelectingState) then
    begin
      SetGridTimer(False, 0);
    end
    else if (FGridMouseState = GridMouseStateManage.RowSizingState) or
            (FGridMouseState = GridMouseStateManage.ColSizingState) then
    begin
      DrawSizingLine;
    end
    else if (FGridMouseState = GridMouseStateManage.ColMovingState) or
                (FGridMouseState = GridMouseStateManage.RowMovingState) then
    begin
      HideMove;
      SetGridTimer(False, 0);
    end;
  finally
    if FGridMouseState <> GridMouseStateManage.NormalState then
    begin
      SetGridMouseState(GridMouseStateManage.NormalState);
      Invalidate;
    end;
  end;
end;

procedure TCustomGridEh.TimedScroll(Direction: TGridScrollDirections);
var
  MaxAnchor, NewAnchor: TGridCoord;
begin
  NewAnchor := FAnchorCell;
  MaxAnchor.X := ColCount - 1;
  MaxAnchor.Y := RowCount - 1;
  if (TGridScrollDirection.Left in Direction) and (FAnchorCell.X > FixedColCount) then Dec(NewAnchor.X);
  if (TGridScrollDirection.Right in Direction) and (FAnchorCell.X < MaxAnchor.X) then Inc(NewAnchor.X);
  if (TGridScrollDirection.Up in Direction) and (FAnchorCell.Y > FixedRowCount) then Dec(NewAnchor.Y);
  if (TGridScrollDirection.Down in Direction) and (FAnchorCell.Y < MaxAnchor.Y) then Inc(NewAnchor.Y);
  if (FAnchorCell.X <> NewAnchor.X) or (FAnchorCell.Y <> NewAnchor.Y) then
    MoveAnchorCell(NewAnchor.X, NewAnchor.Y, True);
end;

procedure TCustomGridEh.SetGridTimer(AEnabled: Boolean; Interval: Cardinal);
begin
  if AEnabled = False then
  begin
    FGridTimer.Enabled := AEnabled;
  end else
  begin
    if Interval = 0
      then FGridTimer.Interval := 1
      else FGridTimer.Interval := Interval;
    FGridTimer.Enabled := AEnabled;
  end;
end;

procedure TCustomGridEh.GridTimerEvent(Sender: TObject);
var
  APoint: TPoint;
  ScrollDirection: TGridScrollDirections;
  CellHit: TGridCoord;
  LeftSide: Integer;
  RightSide: Integer;
  OldLeftCol, OldHorzSmoothPos: Integer;
  AMoveToIndex: Integer;

  procedure ResetScrollTimer(Mouse, CellHit: Integer;
    Axis: TGridAxisDataEh; ScrollBar: Integer; const MousePt: TPoint);
  var
    Distance, MaxSize: Single;
    Delay: Integer;
    ScreenPt, ScreenBrd: TPointF;
  begin
    if AMoveToIndex >= Axis.FixedCelCount then
    begin
      if Mouse < Axis.FixedBoundary then
      begin
        ScreenPt := LocalToScreen(PointF(MousePt.X, MousePt.Y)).Round;
        ScreenBrd := LocalToScreen(PointF(Axis.FixedBoundary, MousePt.Y)).Round;
        MaxSize := ScreenBrd.X;
        if MaxSize > 200 then
          MaxSize := 200;
        Distance := ScreenBrd.X - ScreenPt.X;
        if Distance > MaxSize then
          Distance := MaxSize;
        if (Distance <= 10)
          then Distance := 1
          else Distance := Distance - 10;
        Delay := 60 + Trunc( MaxSize / Distance * 1.5);
        SetGridTimer(True, Delay);
        Exit;
      end else if (Mouse < Axis.ContraStart) and
         ( (OldLeftCol < LeftCol) or (OldHorzSmoothPos < HorzAxis.RollStartVisPos) ) then
      begin
        Delay := 60 + Trunc(200 * 1.5);
        SetGridTimer(True, Delay);
        Exit;
      end else if Mouse > Axis.ContraStart then
      begin
        ScreenPt := LocalToScreen(MousePt).Round;
        ScreenBrd := LocalToScreen(Point(Axis.ContraStart, MousePt.Y)).Round;
        MaxSize := Screen.DesktopWidth - ScreenBrd.X;
        if MaxSize > 200 then
          MaxSize := 200;
        Distance := ScreenPt.X - ScreenBrd.X;
        if Distance > MaxSize then
          Distance := MaxSize;
        if (Distance <= 10)
          then Distance := 1
          else Distance := Distance - 10;
        Delay := 60 + Trunc( MaxSize / Distance * 1.5);
        SetGridTimer(True, Delay);
        Exit;
      end
    end;
    SetGridTimer(True, 60);
  end;

begin
  if (FGridMouseState <> GridMouseStateManage.SelectingState) and
     (FGridMouseState <> GridMouseStateManage.RowMovingState) and
     (FGridMouseState <> GridMouseStateManage.ColMovingState)
  then
    Exit;

  APoint := Screen.MousePos.Round;
  APoint := ScreenToLocal(APoint).Round;
  ScrollDirection := [];

  CellHit := MouseCoord(APoint.X, APoint.Y);
  if (FGridMouseState = GridMouseStateManage.ColMovingState) then
  begin
    AMoveToIndex := GridMouseStateManage.ColMovingState.MoveToIndex;
    OldLeftCol := LeftCol;
    OldHorzSmoothPos := HorzAxis.RollStartVisPos;
    MoveAndScroll(APoint.X, CellHit.X, HorzAxis, SB_HORZ_EH, APoint);
    ResetScrollTimer(APoint.X, CellHit.X, HorzAxis, SB_HORZ_EH, APoint);
  end
  else if (FGridMouseState = GridMouseStateManage.RowMovingState) then
  begin
    AMoveToIndex := GridMouseStateManage.RowMovingState.MoveToIndex;
    MoveAndScroll(APoint.Y, CellHit.Y, VertAxis, SB_VERT_EH, APoint);
  end
  else if (FGridMouseState = GridMouseStateManage.SelectingState) then
  begin
    if not UseRightToLeftAlignment then
    begin
      if APoint.X < HorzAxis.FixedBoundary then
        Include(ScrollDirection, TGridScrollDirection.Left)
      else if APoint.X > HorzAxis.ContraStart then
        Include(ScrollDirection, TGridScrollDirection.Right);
    end else
    begin
      LeftSide := ClientWidth - HorzAxis.ContraStart;
      RightSide := ClientWidth - HorzAxis.FixedBoundary;
      if APoint.X < LeftSide then Include(ScrollDirection, TGridScrollDirection.Right)
      else if APoint.X > RightSide then Include(ScrollDirection, TGridScrollDirection.Left);
    end;
    if APoint.Y < VertAxis.FixedBoundary then
      Include(ScrollDirection, TGridScrollDirection.Up)
    else if APoint.Y > VertAxis.ContraStart then
      Include(ScrollDirection, TGridScrollDirection.Down);
    if ScrollDirection <> [] then  TimedScroll(ScrollDirection);
  end;
end;

procedure TCustomGridEh.ColWidthsChanged;
begin
//  if RolSizeValid then
//    UpdateEdit;
end;

function TCustomGridEh.ContainsFocus: Boolean;
var
  ItfsControl: IControl;
  FocusObject: TFmxObject;
begin
  FocusObject := nil;
  Result := HasFocus;
  if not Result then
  begin
    ItfsControl := Screen.FocusControl;
    if ItfsControl <> nil then
      FocusObject := ItfsControl.GetObject;
    while FocusObject <> nil do
    begin
      if FocusObject = Self then
      begin
        Result := True;
        Exit;
      end;
      FocusObject := FocusObject.Parent;
    end;
  end;
end;

procedure TCustomGridEh.RowHeightsChanged;
begin
  if RolSizeValid then
    UpdateEdit;
end;

procedure TCustomGridEh.DeleteColumn(AColIndex: Integer);
begin
  MoveColumn(AColIndex, FullColCount-1);
  ColCount := ColCount - 1;
end;

procedure TCustomGridEh.DeleteRow(ARowIndex: Integer);
begin
  try
    VertAxis.DeleteRollCells(ARowIndex-VertAxis.FixedCelCount, 1);
  finally
  end;
end;

procedure TCustomGridEh.UpdateDesigner;
begin
end;

function TCustomGridEh.DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
  Result := DoMouseWheelDownEvent(Shift, MousePos);
  if not Result then
  begin
    if IsSmoothVertScroll then
    begin
      if ssCtrl in Shift then
        SafeSetTopRollPos(RolStartVisPosY + VertAxis.RollClientLen)
      else
        SafeSetTopRollPos(RolStartVisPosY + GetVertScrollStep);
    end else
    begin
      if ssCtrl in Shift then
      begin
        if VertAxis.RollLastFullVisCel = VertAxis.RollLastVisCel
          then SafeSetTopRow(VertAxis.RollLastVisCel + 1 + FixedRowCount)
          else SafeSetTopRow(VertAxis.RollLastVisCel + FixedRowCount);
      end else
      begin
        SafeSetTopRow(TopRow + 1);
      end;
    end;
    Result := True;
  end;
end;

function TCustomGridEh.DoMouseWheelDownEvent(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
  Result := False;
end;

function TCustomGridEh.DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean;
var
  NewCell, NewCelOffset: Integer;
begin
  Result := DoMouseWheelUpEvent(Shift, MousePos);
  if not Result then
  begin
    if IsSmoothVertScroll then
    begin
      if ssCtrl in Shift then
        SafeSetTopRollPos(RolStartVisPosY - VertAxis.RollClientLen)
      else
        SafeSetTopRollPos(RolStartVisPosY - GetVertScrollStep);
    end else
    begin
      if ssCtrl in Shift then
      begin
        VertAxis.RollCellAtPos(VertAxis.RollStartVisPos-VertAxis.RollClientLen, NewCell, NewCelOffset);
        if NewCelOffset > 0 then
          Inc(NewCell);
        SafeSetTopRow(NewCell + FixedRowCount);
      end else
      begin
        if VertAxis.RollStartVisibleCellOffset > 0
          then SafeSetTopRow(VertAxis.RollStartVisCel + FixedRowCount)
          else SafeSetTopRow( VertAxis.RollStartVisCel - 1 + FixedRowCount);
      end;
    end;
    Result := True;
  end;
end;

function TCustomGridEh.DoMouseWheelUpEvent(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
  Result := False;
end;

procedure TCustomGridEh.DoMouseLeave;
begin
  inherited DoMouseLeave;
  Cursor := crDefault;
end;

function TCustomGridEh.CheckColumnDrag(AColMovingState: TGridMouseColMovingStateEh; var ADestination: Integer; const MousePt: TPoint): Boolean;
begin
  Result := True;
end;

function TCustomGridEh.CheckRowDrag(ARowMovingState: TGridMouseRowMovingStateEh;
  var ADestination: Integer; const MousePt: TPoint): Boolean;
begin
  Result := True;
end;

function TCustomGridEh.CheckBeginColumnDrag(var Origin, Destination: Integer; const MousePt: TPoint): Boolean;
begin
  Result := True;
end;

function TCustomGridEh.CheckBeginRowDrag(var Origin, Destination: Integer; const MousePt: TPoint): Boolean;
begin
  Result := True;
end;

function TCustomGridEh.InitGridMouseColMovingState(AColIndex, ARowIndex: Integer; AScreenPos: TPointF; AExtraData: TObject): TGridMouseColMovingStateEh;
begin
  Result := GridMouseStateManage.ColMovingState;
  Result.Init(Self, AColIndex, ARowIndex, AScreenPos, AExtraData);
end;

procedure TCustomGridEh.StartColMoving(ColIndex, RowIndex: Integer; AScreenPos: TPointF);
var
  MouseData: TGridMouseColMovingStateEh;
begin
  MouseData := InitGridMouseColMovingState(ColIndex, RowIndex, AScreenPos, nil);

  SetGridMouseState(MouseData);
  DrawMove;
  SetGridTimer(True, 60);
end;

function TCustomGridEh.InitRowMovingState(AStartRow: Integer; const AMousePos: TPoint; AExtraData: TObject): TGridMouseRowMovingStateEh;
begin
  Result := GridMouseStateManage.RowMovingState;
  Result.Init(Self, AStartRow, AStartRow, AMousePos, AExtraData);
end;

procedure TCustomGridEh.StartRowDrag(StartRow: Integer; const MousePos: TPoint);
var
  MouseState: TGridMouseRowMovingStateEh;
begin
  MouseState := InitRowMovingState(StartRow, MousePos, nil);
  SetGridMouseState(MouseState);
  DrawMove;
  SetGridTimer(True, 60);
end;

function TCustomGridEh.EmptyColWidth: Integer;
begin
  if GridLineOptions.VertLinesVisible
    then Result := -1
    else Result := 0;
end;

function TCustomGridEh.EmptyRowHeight: Integer;
begin
  if GridLineOptions.HorzLinesVisible
    then Result := -1
    else Result := 0;
end;

function TCustomGridEh.EndColumnDrag(AColMovingState: TGridMouseColMovingStateEh; const MousePt: TPoint): Boolean;
begin
  Result := True;
  if (AColMovingState.MoveFromIndex >= 0) and
     (AColMovingState.MoveToIndex > AColMovingState.MoveFromIndex) and
     not AColMovingState.MovePosRightSite
  then
    AColMovingState.MoveToIndex := AColMovingState.MoveToIndex - 1;
end;

function TCustomGridEh.EndRowDrag(ARowMovingState: TGridMouseRowMovingStateEh; const MousePt: TPoint): Boolean;
begin
  Result := True;
end;

function TCustomGridEh.GetFrozenColCount: Integer;
begin
  Result := HorzAxis.FrozenCelCount;
end;

procedure TCustomGridEh.SetFrozenColCount(const Value: Integer);
begin
  HorzAxis.FrozenCelCount := Value;
end;

procedure TCustomGridEh.SetFrozenRowCount(const Value: Integer);
begin
  VertAxis.FrozenCelCount := Value;
end;

function TCustomGridEh.GetFrozenRowCount: Integer;
begin
  Result := VertAxis.FrozenCelCount;
end;

function TCustomGridEh.CreateGridLineOptions: TGridLineOptionsEh;
begin
  Result := TGridLineOptionsEh.Create(Self);
end;

procedure TCustomGridEh.FlatChanged;
begin

end;

function TCustomGridEh.ResizeLine(Axis: TGridAxisDataEh): Integer;
var
  I: Integer;
begin
  if FSizingIndex >= Axis.CelCount then
  begin
    Result := Axis.ContraStart;
    for I := Axis.CelCount to FSizingIndex do
      Inc(Result, Axis.CelLens[I]);
    Result := Result - FSizingPos;
  end else
  begin
    if FSizingIndex < Axis.FixedCelCount then
    begin
      Result := Axis.GridClientStart;
      for I := 0 to FSizingIndex - 1 do
        Inc(Result, Axis.CelLens[I]);
    end else
    begin
      Result := Axis.FixedBoundary - Axis.RollStartVisibleCellOffset;
      for I := Axis.StartVisCel to FSizingIndex - 1 do
        Inc(Result, Axis.CelLens[I]);
    end;
    Result := FSizingPos - Result;
  end;
end;

procedure TCustomGridEh.DrawPolyline(Canvas: TCanvas; Points: TPointArrayEh);
var
  i: Integer;
  AFillRect: TRect;
begin
  if UseRightToLeftAlignment then
  begin
    for i := 0 to Length(Points)-1 do
    begin
      Points[i].X := Points[i].X + 1;
    end;
  end;
  if (Length(Points) = 2) then
  begin
    Canvas.Fill.Color := Canvas.Stroke.Color;

    if (Points[0].Y = Points[1].Y) then
      AFillRect := Rect(Points[0].X, Points[0].Y, Points[1].X, Points[0].Y + 1)
    else
      AFillRect := Rect(Points[0].X, Points[0].Y, Points[0].X + 1, Points[1].Y);

    CanvasFillRect(Canvas, AFillRect, 1);
  end else
  begin
    PolylineEh(Canvas, Points, 0, Length(Points) div 2);
  end;
end;

procedure TCustomGridEh.DrawWideLine(X1, Y1, X2, Y2, Width: Integer);
var
  AFillRect: TRect;
begin
  Canvas.Fill.Color := Canvas.Stroke.Color;
  if X1 <> X2 then
  begin
    AFillRect := Rect(X1, Y1, X2, Y1 + Width);
    CanvasFillRect(Canvas, AFillRect, 1);
  end
  else if Y1 <> Y2 then
  begin
    AFillRect := Rect(X1, Y1, X2 + Width, Y2);
    CanvasFillRect(Canvas, AFillRect, 1);
  end;
end;

procedure TCustomGridEh.UpdateScrollBars;
var
  APosition, AMin, AMax, APageSize: Integer;
begin
  if (HorzScrollBarPanelControl = nil) then Exit;

  HorzScrollBar.GetScrollBarParams(APosition, AMin, AMax, APageSize);
  GetDataForHorzScrollBar(APosition, AMin, AMax, APageSize);
  TGridScrollBarEhCrack(HorzScrollBar).SetParams(APosition, AMin, AMax, APageSize);

  VertScrollBar.GetScrollBarParams(APosition, AMin, AMax, APageSize);
  GetDataForVertScrollBar(APosition, AMin, AMax, APageSize);
  TGridScrollBarEhCrack(VertScrollBar).SetParams(APosition, AMin, AMax, APageSize);

  UpdateScrollBarPanels;
end;

procedure TCustomGridEh.GetDataForHorzScrollBar(var APosition, AMin, AMax, APageSize: Integer);
begin
  APosition := HorzAxis.RollStartVisPos;
  AMin := 0;
  if HorzAxis.RollLen > 0
    then AMax := HorzAxis.RollLen-1
    else AMax := 0;
  APageSize := HorzAxis.RollClientLen;
  if UseRightToLeftAlignment then
    APosition := APosition + APageSize;
end;

procedure TCustomGridEh.GetDataForVertScrollBar(var APosition, AMin, AMax, APageSize: Integer);
begin
  APosition := VertAxis.RollStartVisPos;
  AMin := 0;
  AMax := VertAxis.RollLen-1;
  APageSize := VertAxis.RollClientLen;
end;

function TCustomGridEh.CreateHorzScrollBarPanelControl: TGridScrollBarPanelControlEh;
begin
  Result := TGridScrollBarPanelControlEh.Create(Self, TOrientation.Horizontal);
end;

function TCustomGridEh.CreateVertScrollBarPanelControl: TGridScrollBarPanelControlEh;
begin
  Result := TGridScrollBarPanelControlEh.Create(Self, TOrientation.Vertical);
end;

function TCustomGridEh.CreateSizeGripPanel: TSizeGripPanelEh;
begin
  Result := TSizeGripPanelEh.Create(Self);
end;

function TCustomGridEh.CreateStylePainter: TBaseGridStylePainterEh;
begin
  Result := TBaseGridStylePainterEh.Create(Self);
end;

procedure TCustomGridEh.UpdateScrollBarPanels;
var
  SHeight, SWidth, SizeGripWidth, SizeGripHeight: Integer;
  SBLeftStartOffset: Integer;
  SBTopStartOffset: Integer;
  AScrollBarShowingChanged: Boolean;
  ASizeGripPosition: TSizeGripPosition;
  CliBnd: TRect;
begin
  if not IsCanvasEnabled then Exit;
  if FExtraSizeGripControl = nil then Exit;

  CliBnd.Left := HorzAxis.WinClientBoundSta;
  CliBnd.Right := HorzAxis.WinClientBoundSto;
  CliBnd.Top := VertAxis.WinClientBoundSta;
  CliBnd.Bottom := VertAxis.WinClientBoundSto;

  if VertScrollBar.IsScrollBarShowing
    then SWidth := VertScrollBar.ActualSize
    else SWidth := 0;

  if HorzScrollBar.IsScrollBarShowing
    then SHeight := HorzScrollBar.ActualSize
    else SHeight := 0;

  SBLeftStartOffset := CliBnd.Left;
  SBTopStartOffset := CliBnd.Top;
  if SizeGripPosition = TSizeGripPosition.BottomRight then
  begin
    FExtraSizeGripControl.Visible := False;
    if SizeGripAlwaysShow
      then FCornerScrollBarPanelControl.GripActiveStatus := TGripActiveStatusEh.Always
      else FCornerScrollBarPanelControl.GripActiveStatus := TGripActiveStatusEh.Auto;
    if {not UseRightToLeftAlignment and}
       (((SHeight > 0) and (SWidth > 0)) or SizeGripAlwaysShow) then
    begin
      SizeGripWidth := VertScrollBar.ActualSize;
      SizeGripHeight := HorzScrollBar.ActualScrollBarBoxSize;
    end else
    begin
      SizeGripWidth := 0;
      SizeGripHeight := 0;
    end;

    ASizeGripPosition := TSizeGripPosition.BottomRight;
    FCornerScrollBarPanelControl.Position := ASizeGripPosition;
  end else
  begin
    SizeGripWidth := 0;
    SizeGripHeight := 0;
    FCornerScrollBarPanelControl.GripActiveStatus := TGripActiveStatusEh.Never;
    if SizeGripPosition = TSizeGripPosition.TopLeft then
    begin
      FExtraSizeGripControl.SetBounds(0, 0, HorzScrollBar.ActualSize, VertScrollBar.ActualSize);
      FExtraSizeGripControl.TriangleWindow := True;
    end else if SizeGripPosition = TSizeGripPosition.TopRight then
    begin
      SBTopStartOffset := VertScrollBar.ActualSize;
      FExtraSizeGripControl.SetBounds(ClientWidth - HorzScrollBar.ActualSize, 0, HorzScrollBar.ActualSize, VertScrollBar.ActualSize);
      FExtraSizeGripControl.TriangleWindow := (SWidth = 0);
    end else 
    begin
      SBLeftStartOffset := VertScrollBar.ActualSize;
      FExtraSizeGripControl.SetBounds(0, ClientHeight - VertScrollBar.ActualSize, HorzScrollBar.ActualSize, VertScrollBar.ActualSize);
      FExtraSizeGripControl.TriangleWindow := (SHeight = 0);
      if UseRightToLeftAlignment and
         (((SHeight > 0) and (SWidth > 0)) or SizeGripAlwaysShow) then
      begin
        SizeGripWidth := VertScrollBar.ActualSize;
        SizeGripHeight := HorzScrollBar.ActualScrollBarBoxSize;
        FExtraSizeGripControl.TriangleWindow := (SWidth = 0);
      end;
    end;
    FExtraSizeGripControl.GripActiveStatus := TGripActiveStatusEh.Always;
    ASizeGripPosition := SizeGripPosition;
    FExtraSizeGripControl.Position := ASizeGripPosition;
    FExtraSizeGripControl.Visible := True;
  end;

  if UseRightToLeftAlignment then
  begin
    FVertScrollBarPanelControl.SetBounds(0, 0, SWidth, ClientHeight - SizeGripHeight - SBTopStartOffset);
    FHorzScrollBarPanelControl.SetBounds(SWidth, ClientHeight - SHeight,
      ClientWidth - SWidth, SHeight);
    FCornerScrollBarPanelControl.SetBounds(0, ClientHeight - SizeGripHeight, SizeGripWidth, SizeGripHeight);
  end else
  begin
    FVertScrollBarPanelControl.SetBounds(CliBnd.Right - SWidth, SBTopStartOffset, SWidth, CliBnd.Height - SizeGripHeight - SBTopStartOffset);
    FHorzScrollBarPanelControl.SetBounds(SBLeftStartOffset, CliBnd.Bottom - SHeight, CliBnd.Width - SizeGripWidth - SBTopStartOffset, SHeight);
    FCornerScrollBarPanelControl.SetBounds(CliBnd.Right - SizeGripWidth, CliBnd.Bottom - SizeGripHeight, SizeGripWidth, SizeGripHeight);
  end;

  FVertScrollBarPanelControl.Visible := True;
  FVertScrollBarPanelControl.KeepMaxSizeInDefault := VertScrollBar.IsKeepMaxSizeInDefault;

  FHorzScrollBarPanelControl.Visible := True;
  FHorzScrollBarPanelControl.KeepMaxSizeInDefault := HorzScrollBar.IsKeepMaxSizeInDefault;

  FCornerScrollBarPanelControl.Visible := True;
  FCornerScrollBarPanelControl.TriangleWindow := (SHeight = 0) and (SWidth = 0) and SizeGripAlwaysShow;

  AScrollBarShowingChanged := False;
  if FVertScrollBarIsShowing <> VertScrollBar.IsScrollBarShowing then
  begin
    FVertScrollBarIsShowing := VertScrollBar.IsScrollBarShowing;
    AScrollBarShowingChanged := True;
  end;

  if FHorzScrollBarIsShowing <> HorzScrollBar.IsScrollBarShowing then
  begin
    FHorzScrollBarIsShowing := HorzScrollBar.IsScrollBarShowing;
    AScrollBarShowingChanged := True;
  end;
  if AScrollBarShowingChanged then
    ScrollBarShowingChanged;
end;

function TCustomGridEh.CreateScrollBar(AKind: TOrientation): TGridScrollBarEh;
begin
  Result := TGridScrollBarEh.Create(Self, AKind)
end;

procedure TCustomGridEh.Loaded;
begin
  inherited Loaded;
  UpdateBoundaries;
end;

procedure TCustomGridEh.OutBoundaryDataChanged;
begin
  UpdateBoundaries;
end;

procedure TCustomGridEh.SetGridLineOptions(const Value: TGridLineOptionsEh);
begin
  FGridLineOptions.Assign(Value);
end;

function TCustomGridEh.HorzScrollingLockCount: Integer;
begin
  Result := FHorzScrollingLockCount;
end;

procedure TCustomGridEh.LockGridHorzScrolling;
begin
  Inc(FHorzScrollingLockCount);
end;

procedure TCustomGridEh.UnLockGridHorzScrolling;
begin
  Dec(FHorzScrollingLockCount);
end;

procedure TCustomGridEh.RolSizeUpdated;
begin
  UpdateBoundaries;
end;

procedure TCustomGridEh.CheckUpdateAxises;
begin
  HorzAxis.CheckUpdateRollCelPosArr;
  VertAxis.CheckUpdateRollCelPosArr;
end;

procedure TCustomGridEh.RolPosAxisChanged(Axis: TGridAxisDataEh; OldRowPos: Integer);
begin
  if Axis = HorzAxis then
    RolPosChanged(OldRowPos, VertAxis.RollStartVisPos)
  else
    RolPosChanged(HorzAxis.RollStartVisPos, OldRowPos);
end;

function TCustomGridEh.FullRedrawOnScroll: Boolean;
begin
{$IFDEF eval}
  Result := True;
{$ELSE}
  Result := FBackgroundData.Showing;
{$ENDIF}
end;

procedure TCustomGridEh.RolPosChanged(OldRowPosX, OldRowPosY: Integer);
var
  MousePos: TPoint;
begin
  UpdateScrollBars;
  if not IsCanvasEnabled then
    Exit;

  MousePos := ScreenToLocal(Screen.MousePos).Round;

  if FullRedrawOnScroll then
  begin
    InvalidateGrid;
    Exit;
  end;

  InvalidateGrid;
end;

function TCustomGridEh.RolSizeValid: Boolean;
begin
  Result := not HorzAxis.FRollLocCelPosArrObsolete and not VertAxis.FRollLocCelPosArrObsolete
end;

procedure TCustomGridEh.CelLenChanged(Axis: TGridAxisDataEh; Index, OldLen: Integer);
begin
  if (Index < Axis.FixedCelCount) or (Index >= Axis.CelCount) then
    UpdateBoundaries;
  if Axis = HorzAxis
    then ColWidthsChanged
    else RowHeightsChanged;
end;

procedure TCustomGridEh.ValidateRolSize;
begin
  HorzAxis.CheckUpdateRollCelPosArr;
  VertAxis.CheckUpdateRollCelPosArr;
end;

procedure TCustomGridEh.InteractiveMoveColumn(AColMovingState: TGridMouseColMovingStateEh);
begin
  MoveColumn(AColMovingState.MoveFromIndex, AColMovingState.MoveToIndex);
end;

procedure TCustomGridEh.MoveColumn(FromIndex, ToIndex: Integer);
begin
  HorzAxis.MoveCel(FromIndex, ToIndex);
end;

procedure TCustomGridEh.MoveRow(FromIndex, ToIndex: Integer);
begin
  VertAxis.MoveCel(FromIndex, ToIndex);
end;

procedure TCustomGridEh.BeginUpdateBoundaries;
begin
  Inc(FBoundariesUpdateCount);
end;

procedure TCustomGridEh.EndUpdateBoundaries;
begin
  Dec(FBoundariesUpdateCount);
end;

function TCustomGridEh.BoundariesUpdating: Boolean;
begin
  Result := (FBoundariesUpdateCount > 0);
end;

procedure TCustomGridEh.UpdateBoundaries;
var
  i: Integer;
//  EdgeBorders: TControlEdgeBorders;
begin

  if (BoundariesUpdating = True) or
     (csLoading in ComponentState) or
     (Client = nil)
  then
    Exit;

  UpdateOutBoundaryIndents();
  BeginUpdateBoundaries;
  try

  FWinClientBoundary.Left := 0;
  FWinClientBoundary.Top := 0;
  FWinClientBoundary.Right := Trunc(Client.Width);
  FWinClientBoundary.Bottom := Trunc(Client.Height);

  FHorzAxis.FWinClientBoundSta := FWinClientBoundary.Left;
  FHorzAxis.FWinClientBoundSto := FWinClientBoundary.Right;
  FVertAxis.FWinClientBoundSta := FWinClientBoundary.Top;
  FVertAxis.FWinClientBoundSto := FWinClientBoundary.Bottom;

  FHorzAxis.FGridClientStart := FHorzAxis.FWinClientBoundSta + OutBoundaryData.LeftIndent;
  FHorzAxis.FGridClientStop := FHorzAxis.FWinClientBoundSto - OutBoundaryData.RightIndent;
  FVertAxis.FGridClientStart := FVertAxis.FWinClientBoundSta + OutBoundaryData.TopIndent;
  FVertAxis.FGridClientStop := FVertAxis.FWinClientBoundSto - OutBoundaryData.BottomIndent;

  FHorzAxis.FContraLen := 0;
  for i := 0 to ContraColCount-1 do
    Inc(FHorzAxis.FContraLen, HorzAxis.ContraCelLens[i]);
  if (ContraColCount > 0) and (TGridOptionEh.ContraVertBoundaryLine in Options) then
    Inc(FHorzAxis.FContraLen, GridLineWidth);
  FHorzAxis.FContraStart := FHorzAxis.FGridClientStop - FHorzAxis.ContraLen;

  FVertAxis.FContraLen := 0;
  for i := 0 to ContraRowCount-1 do
    Inc(FVertAxis.FContraLen, FVertAxis.ContraCelLens[i]);
  if (ContraRowCount > 0) and (TGridOptionEh.ContraHorzBoundaryLine in Options) then
    Inc(FVertAxis.FContraLen, GridLineWidth);
  FVertAxis.FContraStart := FVertAxis.FGridClientStop - FVertAxis.ContraLen;

  FHorzAxis.FFixedBoundary := FHorzAxis.FGridClientStart;
  FVertAxis.FFixedBoundary := FVertAxis.FGridClientStart;

  for i := 0 to FixedColCount-1 do
    Inc(FHorzAxis.FFixedBoundary, HorzAxis.FixedCelLens[i]);

  for i := 0 to FixedRowCount-1 do
    Inc(FVertAxis.FFixedBoundary, VertAxis.FixedCelLens[i]);

  FHorzAxis.FFrozenLen := 0;
  for i := FixedColCount-FrozenColCount to FixedColCount-1 do
    Inc(FHorzAxis.FFrozenLen, HorzAxis.FixedCelLens[i]);

  FVertAxis.FFrozenLen := 0;
  for i := FixedRowCount-FrozenRowCount to FixedRowCount-1 do
    Inc(FVertAxis.FFrozenLen, VertAxis.FixedCelLens[i]);

  if HorzScrollBar.IsScrollBarShowing {FHorzAxis.RolLen > FHorzAxis.RolClientLen} then
  begin
    Dec(FVertAxis.FGridClientStop, HorzScrollBar.ActualSize);
    Dec(FVertAxis.FContraStart, HorzScrollBar.ActualSize);
    if VertScrollBar.IsScrollBarShowing {FVertAxis.RolLen > FVertAxis.RolClientLen} then
    begin
      Dec(FHorzAxis.FGridClientStop, VertScrollBar.ActualSize);
      Dec(FHorzAxis.FContraStart, VertScrollBar.ActualSize);
    end;
  end else if VertScrollBar.IsScrollBarShowing {FVertAxis.RolLen > FVertAxis.RolClientLen} then
  begin
    Dec(FHorzAxis.FGridClientStop, VertScrollBar.ActualSize);
    Dec(FHorzAxis.FContraStart, VertScrollBar.ActualSize);
    if HorzScrollBar.IsScrollBarShowing {FHorzAxis.RolLen > FHorzAxis.RolClientLen} then
    begin
      Dec(FVertAxis.FGridClientStop, HorzScrollBar.ActualSize);
      Dec(FVertAxis.FContraStart, HorzScrollBar.ActualSize);
    end;
  end;

  AdjustMaxTopLeft(True, True, not IsSmoothHorzScroll, not IsSmoothVertScroll);

  FHorzAxis.GetLastVisibleCell(FHorzAxis.FRollLastVisCel, FHorzAxis.FRollLastFullVisCel);
  FVertAxis.GetLastVisibleCell(FVertAxis.FRollLastVisCel, FVertAxis.FRollLastFullVisCel);
  if FScrollBarDataRecalculated = True then
    UpdateScrollBars;
  UpdateAniCalculations();

  finally
    EndUpdateBoundaries;
  end;
  Invalidate;
end;

procedure TCustomGridEh.CellCountChanged;
begin
  Invalidate;
  if FCurCellPos.X >= ColCount then
    FCurCellPos.X := ColCount-1;

  if FCurCellPos.X < FixedColCount-FrozenColCount then
    FCurCellPos.X := FixedColCount-FrozenColCount;

  if FCurCellPos.Y >= RowCount then
    FCurCellPos.Y := RowCount-1;

  if FCurCellPos.Y < FixedRowCount-FrozenRowCount then
    FCurCellPos.Y := FixedRowCount-FrozenRowCount;

  FAnchorCell := FCurCellPos;
end;

function TCustomGridEh.CheckPersistentContraLine(LineType: TGridCellBorderTypeEh): Boolean;
begin
  if LineType = TGridCellBorderTypeEh.Top
    then Result := GridLineOptions.VertLinesVisible
    else Result := GridLineOptions.HorzLinesVisible;
end;

procedure TCustomGridEh.ScrollBarSizeChanged(ScrollBar: TGridScrollBarEh);
begin
  UpdateBoundaries;
end;

function TCustomGridEh.GetSelection: TGridRect;
begin
  Result := GridRect(FCurCellPos, FAnchorCell);
end;

procedure TCustomGridEh.SetSelection(const Value: TGridRect);
var
  OldSel: TGridRect;
begin
  OldSel := Selection;
  FAnchorCell.X := Value.Left;
  FAnchorCell.Y := Value.Top;
  FCurCellPos.X := Value.Right;
  FCurCellPos.Y := Value.Bottom;
  SelectionChanged(OldSel);
end;

procedure TCustomGridEh.MoveAnchorCell(AColIndex, ARowIndex: Integer; Show: Boolean);
var
  OldSel: TGridRect;
begin
  if (FAnchorCell.X = AColIndex) and
     (FAnchorCell.Y = ARowIndex)
  then
    Exit;

  if (AColIndex < 0) or
     (ARowIndex < 0) or
     (AColIndex >= FullColCount) or
     (ARowIndex >= FullRowCount)
  then
    raise EInvalidGridOperationEh.Create('TCustomGridEh.SetAnchorCell: Grid index out of range');

  OldSel := Selection;
  FAnchorCell.X := AColIndex;
  FAnchorCell.Y := ARowIndex;
  ClampInView(FAnchorCell, True, True);
  SelectionChanged(OldSel);
end;

procedure TCustomGridEh.SelectionChanged(const OldSel: TGridRect);
begin
  InvalidateGridRect(OldSel);
  InvalidateGridRect(Selection);
end;

function TCustomGridEh.GetClientWidth: Integer;
begin
  Result := Trunc(WinClientBoundary.Width);
end;

function TCustomGridEh.GetClientHeight: Integer;
begin
  Result := Trunc(WinClientBoundary.Height);
end;

procedure TCustomGridEh.SetBorder(Value: TControlBorderEh);
begin
  FBorder.Assign(Value);
end;

procedure TCustomGridEh.GridColRowToLocalColRowIndex(AColIndex, ARowIndex: Integer; out ALocalColIndex, ALocalRowIndex: Integer);
begin
  ALocalColIndex := AColIndex;
  ALocalRowIndex := ARowIndex;
end;

procedure TCustomGridEh.InteractiveFocusCell(AColIndex, ARowIndex: Integer;
  ActionSource: TInteractiveActionSourceEh);
begin
  FocusCell(AColIndex, ARowIndex, True);
end;

procedure TCustomGridEh.RefreshDefaultProps;
begin
  RefreshDefaultFont;
end;

{$REGION 'Font'}

procedure TCustomGridEh.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TCustomGridEh.RefreshDefaultFont;
var
  Save: TNotifyEvent;
begin
  if FontStored then Exit;
  Save := FFont.OnChanged;
  FFont.OnChanged := nil;
  try
    FFont.Assign(DefaultFont);
  finally
    FFont.OnChanged := Save;
  end;
end;

function TCustomGridEh.DefaultFont: TFont;
begin
  Result := StylePainter.Font;
end;

procedure TCustomGridEh.FontPropChanged(Sender: TObject);
begin
  FontChanged();
  FFontStored := True;
end;

procedure  TCustomGridEh.FontChanged();
begin
  Invalidate();
end;

function TCustomGridEh.IsFontStored: Boolean;
begin
  Result := FFontStored;
end;

procedure TCustomGridEh.SetFontStored(const Value: Boolean);
begin
  if FFontStored <> Value then
  begin
    FFontStored := Value;
    RefreshDefaultFont;
  end;
end;

{$ENDREGION 'Font'}

procedure TCustomGridEh.DoRealign;
begin
  inherited DoRealign;
end;

procedure TCustomGridEh.CheckCreateVirtPanels;
begin
  if Client = nil then Exit;

  if HFixedVFixedPanel <> nil then Exit;

  HFixedVFixedPanel := CreateHFixedVFixedPanel();
  HFixedVFixedPanel.Parent := Client;
  HFixedVFixedPanel.Name := 'HFixedVFixedPanel';

  HDataVFixedPanel := CreateHDataVFixedPanel();
  HDataVFixedPanel.Parent := Client;
  HDataVFixedPanel.Name := 'HDataVFixedPanel';

  HContraVFixedPanel := CreateHContraVFixedPanel();
  HContraVFixedPanel.Parent := Client;
  HContraVFixedPanel.Name := 'HContraVFixedPanel';

  HFixedVDataPanel := CreateHFixedVDataPanel();
  HFixedVDataPanel.Parent := Client;
  HFixedVDataPanel.Name := 'HFixedVDataPanel';

  HDataVDataPanel := CreateHDataVDataPanel();
  HDataVDataPanel.Parent := Client;
  HDataVDataPanel.Name := 'HDataVDataPanel';

  HContraVDataPanel := CreateHContraVDataPanel();
  HContraVDataPanel.Parent := Client;
  HContraVDataPanel.Name := 'HContraVDataPanel';

  HFixedVFooterPanel := CreateHFixedVFooterPanel();
  HFixedVFooterPanel.Parent := Client;
  HFixedVFooterPanel.Name := 'HFixedVFooterPanel';

  HDataVFooterPanel := CreateHDataVFooterPanel();
  HDataVFooterPanel.Parent := Client;
  HDataVFooterPanel.Name := 'HDataVFooterPanel';

  HContraVFooterPanel := CreateHContraVFooterPanel();
  HContraVFooterPanel.Parent := Client;
  HContraVFooterPanel.Name := 'HContraVFooterPanel';
end;

procedure TCustomGridEh.ResetVirtPanels;
begin
  HFixedVFixedPanel.DestroyCells();
  HDataVFixedPanel.DestroyCells();
  HContraVFixedPanel.DestroyCells();

  HFixedVDataPanel.DestroyCells();
  HDataVDataPanel.DestroyCells();
  HContraVDataPanel.DestroyCells();

  HFixedVFooterPanel.DestroyCells();
  HDataVFooterPanel.DestroyCells();
  HContraVFooterPanel.DestroyCells();
end;

procedure TCustomGridEh.UpdateVirtPanels;
var
  RestRect: TRect;
begin
  if Canvas = nil then Exit;
  if Client = nil then Exit;

  FInterruptLayoutIsNeeded := False;
  try
    CheckCreateVirtPanels;

  
    HFixedVDataPanel.SetInGridCellRange(0, FixedColCount - 1, FixedRowCount, RowCount - 1);
    HFixedVDataPanel.StartVisColIndex := 0;
    HFixedVDataPanel.StartVisColOffset := 0;
    HFixedVDataPanel.StartVisRowIndex := VertAxis.RollStartVisCel;
    HFixedVDataPanel.StartVisRowOffset := -VertAxis.RollStartVisibleCellOffset;

    RestRect := Rect(HorzAxis.GridClientStart, VertAxis.FixedBoundary,
                     HorzAxis.FixedBoundary, VertAxis.ContraStart);
    HFixedVDataPanel.SetBounds(RestRect.Left, RestRect.Top, RestRect.Width, RestRect.Height);
    HFixedVDataPanel.UpdateLayout;
    if IsLayoutInterrupted() then Exit;

  
    HFixedVFixedPanel.SetInGridCellRange(0, FixedColCount - 1, 0, FixedRowCount - 1);
    HFixedVFixedPanel.StartVisColIndex := 0;
    HFixedVFixedPanel.StartVisColOffset := 0;
    HFixedVFixedPanel.StartVisRowIndex := 0;
    HFixedVFixedPanel.StartVisRowOffset := 0;

    RestRect := Rect(HorzAxis.GridClientStart, VertAxis.GridClientStart,
                     HorzAxis.FixedBoundary, VertAxis.FixedBoundary);
    HFixedVFixedPanel.SetBounds(RestRect.Left, RestRect.Top, RestRect.Width, RestRect.Height);
    HFixedVFixedPanel.UpdateLayout;
    if IsLayoutInterrupted() then Exit;

  
    HDataVFixedPanel.SetInGridCellRange(FixedColCount, ColCount - 1, 0, FixedRowCount - 1);
    HDataVFixedPanel.StartVisColIndex := HorzAxis.RollStartVisCel;
    HDataVFixedPanel.StartVisColOffset := -HorzAxis.RollStartVisibleCellOffset;
    HDataVFixedPanel.StartVisRowIndex := 0;
    HDataVFixedPanel.StartVisRowOffset := 0;

    RestRect := Rect(HorzAxis.FixedBoundary, VertAxis.GridClientStart,
                     HorzAxis.ContraStart, VertAxis.FixedBoundary);
    HDataVFixedPanel.SetBounds(RestRect.Left, RestRect.Top, RestRect.Width, RestRect.Height);
    HDataVFixedPanel.UpdateLayout;
    if IsLayoutInterrupted() then Exit;

  
    HContraVFixedPanel.SetInGridCellRange(ColCount, FullColCount - 1, 0, FixedRowCount - 1);
    HContraVFixedPanel.StartVisColIndex := 0;
    HContraVFixedPanel.StartVisColOffset := 0;
    HContraVFixedPanel.StartVisRowIndex := 0;
    HContraVFixedPanel.StartVisRowOffset := 0;

    RestRect := Rect(HorzAxis.ContraStart, VertAxis.GridClientStart,
                     HorzAxis.GridClientStop, VertAxis.FixedBoundary);
    HContraVFixedPanel.SetBounds(RestRect.Left, RestRect.Top, RestRect.Width, RestRect.Height);
    HContraVFixedPanel.UpdateLayout;
    if IsLayoutInterrupted() then Exit;

  
    HDataVDataPanel.SetInGridCellRange(FixedColCount, ColCount - 1, FixedRowCount, RowCount - 1);
    HDataVDataPanel.StartVisColIndex := HorzAxis.RollStartVisCel;
    HDataVDataPanel.StartVisColOffset := -HorzAxis.RollStartVisibleCellOffset;
    HDataVDataPanel.StartVisRowIndex := VertAxis.RollStartVisCel;
    HDataVDataPanel.StartVisRowOffset := -VertAxis.RollStartVisibleCellOffset;

    RestRect := Rect(HorzAxis.FixedBoundary, VertAxis.FixedBoundary,
                     HorzAxis.ContraStart, VertAxis.ContraStart);
    HDataVDataPanel.SetBounds(RestRect.Left, RestRect.Top, RestRect.Width, RestRect.Height);
    HDataVDataPanel.UpdateLayout;
    if IsLayoutInterrupted() then Exit;

  
    HContraVDataPanel.SetInGridCellRange(ColCount, FullColCount - 1, FixedRowCount, RowCount - 1);
    HContraVDataPanel.StartVisColIndex := 0;
    HContraVDataPanel.StartVisColOffset := 0;
    HContraVDataPanel.StartVisRowIndex := VertAxis.RollStartVisCel;
    HContraVDataPanel.StartVisRowOffset := -VertAxis.RollStartVisibleCellOffset;

    RestRect := Rect(HorzAxis.ContraStart, VertAxis.FixedBoundary,
                     HorzAxis.GridClientStop, VertAxis.ContraStart);
    HContraVDataPanel.SetBounds(RestRect.Left, RestRect.Top, RestRect.Width, RestRect.Height);
    HContraVDataPanel.UpdateLayout;
    if IsLayoutInterrupted() then Exit;

  
    HFixedVFooterPanel.SetInGridCellRange(0, FixedColCount - 1, RowCount, FullRowCount - 1);
    HFixedVFooterPanel.StartVisColIndex := 0;
    HFixedVFooterPanel.StartVisColOffset := 0;
    HFixedVFooterPanel.StartVisRowIndex := 0;
    HFixedVFooterPanel.StartVisRowOffset := 0;

    RestRect := Rect(HorzAxis.GridClientStart, VertAxis.ContraStart,
                     HorzAxis.FixedBoundary, VertAxis.GridClientStop);
    HFixedVFooterPanel.SetBounds(RestRect.Left, RestRect.Top, RestRect.Width, RestRect.Height);
    HFixedVFooterPanel.UpdateLayout;

  
    HDataVFooterPanel.SetInGridCellRange(FixedColCount, ColCount - 1, RowCount, FullRowCount - 1);
    HDataVFooterPanel.StartVisColIndex := HorzAxis.RollStartVisCel;
    HDataVFooterPanel.StartVisColOffset := -HorzAxis.RollStartVisibleCellOffset;
    HDataVFooterPanel.StartVisRowIndex := 0;
    HDataVFooterPanel.StartVisRowOffset := 0;

    RestRect := Rect(HorzAxis.FixedBoundary, VertAxis.ContraStart,
                     HorzAxis.ContraStart, VertAxis.GridClientStop);
    HDataVFooterPanel.SetBounds(RestRect.Left, RestRect.Top, RestRect.Width, RestRect.Height);
    HDataVFooterPanel.UpdateLayout;

  
    HContraVFooterPanel.SetInGridCellRange(ColCount, FullColCount - 1, RowCount, FullRowCount - 1);
    HContraVFooterPanel.StartVisColIndex := 0;
    HContraVFooterPanel.StartVisColOffset := 0;
    HContraVFooterPanel.StartVisRowIndex := 0;
    HContraVFooterPanel.StartVisRowOffset := 0;

    RestRect := Rect(HorzAxis.ContraStart, VertAxis.ContraStart,
                     HorzAxis.GridClientStop, VertAxis.GridClientStop);
    HContraVFooterPanel.SetBounds(RestRect.Left, RestRect.Top, RestRect.Width, RestRect.Height);
    HContraVFooterPanel.UpdateLayout;

//    if IsLayoutInterrupted() then Exit;

  finally
    if IsLayoutInterrupted() then
      GridLayoutChanged;
  end;
end;

function TCustomGridEh.IsLayoutInterrupted(): Boolean;
begin
  if FInterruptLayoutIsNeeded = True
    then Result := True
    else Result := False;
end;

function TCustomGridEh.CheckAndSetLayoutInterrupting;
var
  PlatformDeviceState: IPlatformDeviceStateServiceEh;
  NextPaintTime: UInt64;
begin
//  Exit(False);

  if (FInterruptLayoutIsNeeded = False) then
  begin
    NextPaintTime := GetTickCountEh;
    if NextPaintTime - FPaintTime < 20  then
      Exit(False);

    if (TPlatformServices.Current.SupportsPlatformService(IPlatformDeviceStateServiceEh, PlatformDeviceState)) then
    begin
      if PlatformDeviceState.InteractiveIsAnyKeyPressed() then
        FInterruptLayoutIsNeeded := True;
    end;
    if (VertScrollBarPanelControl <> nil) and (VertScrollBarPanelControl.ScrollBar.IsTrackMouseDown) then
        FInterruptLayoutIsNeeded := True;
  end;

  Result := FInterruptLayoutIsNeeded;
end;

procedure TCustomGridEh.CheckForceLastRenderOperation;
begin
  if (FInterruptLayoutIsNeeded = True) then
  begin
    ForceRepaintForm;
  end;
//  ForceRepaintForm;
end;

function TCustomGridEh.CreateHFixedVFixedPanel: TLaHostVirtualPanelEh;
begin
  Result := TGridLaHostVirtualPanelEh.Create(Self);
end;

function TCustomGridEh.CreateHDataVFixedPanel: TLaHostVirtualPanelEh;
begin
  Result := TGridLaHostVirtualPanelEh.Create(Self);
end;

function TCustomGridEh.CreateHContraVFixedPanel: TLaHostVirtualPanelEh;
begin
  Result := TGridLaHostVirtualPanelEh.Create(Self);
end;

function TCustomGridEh.CreateHFixedVDataPanel: TLaHostVirtualPanelEh;
begin
  Result := TGridLaHostVirtualPanelEh.Create(Self);
end;

function TCustomGridEh.CreateHDataVDataPanel: TLaHostVirtualPanelEh;
begin
  Result := TGridLaHostVirtualPanelEh.Create(Self);
end;

function TCustomGridEh.CreateHContraVDataPanel: TLaHostVirtualPanelEh;
begin
  Result := TGridLaHostVirtualPanelEh.Create(Self);
end;

function TCustomGridEh.CreateHFixedVFooterPanel: TLaHostVirtualPanelEh;
begin
  Result := TGridLaHostVirtualPanelEh.Create(Self);
end;

function TCustomGridEh.CreateHDataVFooterPanel: TLaHostVirtualPanelEh;
begin
  Result := TGridLaHostVirtualPanelEh.Create(Self);
end;

function TCustomGridEh.CreateHContraVFooterPanel: TLaHostVirtualPanelEh;
begin
  Result := TGridLaHostVirtualPanelEh.Create(Self);
end;

function TCustomGridEh.InternalGetCellManagerAt(VirtPanel: TLaHostVirtualPanelEh; AColIndex, ARowIndex: Integer): TVPBaseCellManagerEh;
begin
  Result := VirtPanel.DefaultCellManager;
end;

function TCustomGridEh.GetCellManagerAt(AColIndex, ARowIndex: Integer): TVPBaseCellManagerEh;
var
  ALocalCol, ALocalRow: Integer;
begin
  Result := GetCellManagerAt(AColIndex, ARowIndex, ALocalCol, ALocalRow);
end;

function TCustomGridEh.GetCellManagerAt(AColIndex, ARowIndex: Integer; out ALocalCol, ALocalRow: Integer): TVPBaseCellManagerEh;
var
  HitPanel: TLaHostVirtualPanelEh;
  PanelColIndex, PanelRowIndex: Integer;
begin
  HitPanel := GetVirtPanelAt(AColIndex, ARowIndex);
  if HitPanel <> nil then
  begin
    PanelColIndex := AColIndex - HitPanel.InGridStartCol;
    PanelRowIndex := ARowIndex - HitPanel.InGridStartRow;
    Result := HitPanel.GetCellManagerAt(PanelColIndex, PanelRowIndex);

    ALocalCol := PanelColIndex;
    ALocalRow := PanelRowIndex;
  end else
  begin
    Result := nil;
    ALocalCol := -1;
    ALocalRow := -1;
  end;
end;

function TCustomGridEh.GetVirtPanelAt(AColIndex, ARowIndex: Integer): TLaHostVirtualPanelEh;

  function IsCellPosInPanel(Panel: TLaHostVirtualPanelEh; AColIndex, ARowIndex: Integer): Boolean;
  begin
    if (Panel <> nil) and
       (AColIndex >= Panel.InGridStartCol) and
       (AColIndex <= Panel.InGridStopCol) and
       (ARowIndex >= Panel.InGridStartRow) and
       (ARowIndex <= Panel.InGridStopRow)
    then
      Result := True
    else
      Result := False;
  end;
begin
  if IsCellPosInPanel(HFixedVFixedPanel, AColIndex, ARowIndex) then
    Result := HFixedVFixedPanel
  else if IsCellPosInPanel(HDataVFixedPanel, AColIndex, ARowIndex) then
    Result := HDataVFixedPanel
  else if IsCellPosInPanel(HFixedVDataPanel, AColIndex, ARowIndex) then
    Result := HFixedVDataPanel
  else if IsCellPosInPanel(HDataVDataPanel, AColIndex, ARowIndex) then
    Result := HDataVDataPanel
  else if IsCellPosInPanel(HDataVFooterPanel, AColIndex, ARowIndex) then
    Result := HDataVFooterPanel
  else
    Result := nil;
end;

procedure TCustomGridEh.InitCellForRender(ACellManager: TVPBaseCellManagerEh; ACell: TVPBaseCellHolderEh);
begin
end;

procedure TCustomGridEh.CheckUpdateViewLayout;
begin
  if FIsViewLayoutUpdateNeeded = True then
  begin
    FIsViewLayoutUpdateNeeded := False;
    SetPaintColors;
    UpdateViewLayout;
    UpdateVirtPanels;
  end;
end;

procedure TCustomGridEh.CheckUpdateVirtPanels;
begin
  if FIsVirtPanelsUpdateNeeded = True then
  begin
    FIsVirtPanelsUpdateNeeded := False;
    UpdateVirtPanels;
  end;
end;

procedure TCustomGridEh.UpdateViewLayout;
begin
  if FScrollBarDataChanged = True then
  begin
    FScrollBarDataRecalculated := True;
    FScrollBarDataChanged := False;
    UpdateScrollBars();
  end;
end;

procedure TCustomGridEh.GridLayoutChanged();
begin
  if csDestroying in ComponentState then Exit;
  if Scene = nil then Exit;
  if IsCanvasEnabled = False then Exit;


//  InvalidateRect(UpdateRect); //Do not Call Full Invaliate. It makes drawing too slow
  if FIsViewLayoutUpdateNeeded = False then
  begin
    FIsViewLayoutUpdateNeeded := True;
    CallAsync(
    //TThread.ForceQueue(nil,
      procedure
      begin
        if (FIsViewLayoutUpdateNeeded = True) then
        begin
          FIsViewLayoutUpdateNeeded := False;
          if (IsCanvasEnabled = True) and
             (StyleState = TStyleState.Applied) then
          begin
            CheckForceLastRenderOperation;
            SetPaintColors;
            UpdateViewLayout;
            UpdateVirtPanels;
          end;
        end;
      end
    );
  end;
end;

procedure TCustomGridEh.CallAsync(const AThreadProc: TThreadProcedure);
var
 AsyncTimer: TOneShotTimer;
begin
  AsyncTimer := TOneShotTimer.Create(1, AThreadProc);
  AsyncTimer.Start;
end;
//begin
//  TThread.ForceQueue(nil, AThreadProc);
//end;

procedure TCustomGridEh.ForceRepaintForm;
var
  PlatformDeviceState: IPlatformDeviceStateServiceEh;
  Form: TCommonCustomForm;
begin
  TPlatformServices.Current.SupportsPlatformService(IPlatformDeviceStateServiceEh, PlatformDeviceState);
  Form := GetParentForm(Self);
  if Form <> nil then
    PlatformDeviceState.RepaintInvalidatedFormRegion(Form);
end;

procedure TCustomGridEh.VirtPanelsUpdateNeeded();
begin
  if csDestroying in ComponentState then Exit;

  if FIsVirtPanelsUpdateNeeded = False then
  begin
    FIsVirtPanelsUpdateNeeded := True;

    TThread.ForceQueue(TThread(nil),
      procedure
      begin
        if csDestroying in ComponentState then Exit;
        if FIsVirtPanelsUpdateNeeded then
        begin
          FIsVirtPanelsUpdateNeeded := False;
          if FIsViewLayoutUpdateNeeded = False then
            UpdateVirtPanels;
        end;
      end
    );

  end else
  begin
    DoNothing;
  end;
end;

procedure TCustomGridEh.OnLaTimer(Sender: TObject);
begin
  FLaTimer.Enabled := False;
end;

function TCustomGridEh.CreateGridMouseStateManager: TGridMouseStateManagerEh;
begin
  Result := TGridMouseStateManagerEh.Create(Self);
end;

function TCustomGridEh.CreateGridNavigation: TGridNavigationEh;
begin
  Result := TGridNavigationEh.Create(Self);
end;

function TCustomGridEh.GetCellContentTextValue(Params: TBaseGridInitCellContentParamsEh): String;
begin
  Result := Params.Cell.ColIndex.ToString + ':' + Params.Cell.RowIndex.ToString;
end;

function TCustomGridEh.IsShowFocusLayerForCell(ACell: TGridBaseCellEh): Boolean;
begin
  if TGridOptionEh.RowSelect in Options then
  begin
    if ACell.RowIndex = CurRowIndex
      then Result := True
      else Result := False;
  end else
  begin
    if (ACell.ColIndex = CurColIndex) and
       (ACell.RowIndex = CurRowIndex)
    then
      Result := True
    else
      Result := False;
  end;
end;

function TCustomGridEh.IsShowSelectionLayerForCell(ACell: TGridBaseCellEh): Boolean;
begin
  Result := False;
end;

procedure TCustomGridEh.BorderChanged;
begin
  UpdateBoundaries();
  GridLayoutChanged();
end;

procedure TCustomGridEh.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) then
  begin
    if (AComponent = Client) then
    begin
      FClient := nil;
      ClientChanged();
    end
    else if (AComponent = FBackground) then
    begin
      FBackground := nil;
    end;
  end;
end;

function TCustomGridEh.GetDefaultStyleLookupName: string;
begin
  Result := 'EhLib.BaseGridStyle';
end;

procedure TCustomGridEh.ApplyStyle;
var
  AClient: TControl;
  ParentStyle: TStyledControl;
  ABackgroundInStyle: TControl;
//  ABackground: TControl;
begin
  inherited ApplyStyle;

  Background := nil;

  FStylePainter.LoadStyleItems;

  if FindStyleResource<TControl>('client', AClient) then
  begin
    Client := AClient as TControl;
    if FindStyleResource<TControl>('background', ABackgroundInStyle) then
      Background := ABackgroundInStyle;
  end
  else if FindStyleResource<TStyledControl>('ParentStyle', ParentStyle) then
  begin
    ParentStyle.ApplyStyleLookup;
    if ParentStyle.FindStyleResource<TControl>('background', ABackgroundInStyle) then
    begin
      Background := ABackgroundInStyle.CloneWithChildren(Self) as TControl;
      InsertObject(Children.IndexOf(ResourceLink) + 1, Background);
      AClient := Background.FindStyleResource('client') as TControl;
      if (AClient <> nil) and (AClient is TControl) then
        Client := AClient as TControl;
    end;
  end;
end;

procedure TCustomGridEh.FreeStyle;
begin
  inherited FreeStyle;
  FStylePainter.FreeStyleItems;
  Background := nil;
end;

procedure TCustomGridEh.DoApplyStyleLookup;
begin
  inherited DoApplyStyleLookup;
  StyleApplied;
end;

procedure TCustomGridEh.StyleApplied;
begin

end;

procedure TCustomGridEh.SetClient(const Value: TControl);
begin
  if FClient <> Value then
  begin
    if FClient <> nil then
      FClient.OnResized := nil;

    FClient := Value;

    if FClient <> nil then
    begin
      FClient.AddFreeNotify(Self);
      FClient.OnResized := ClientResized;
    end;
    ClientChanged();
  end;
end;

procedure TCustomGridEh.SetBackground(const Value: TControl);
begin
  if FClient <> Value then
  begin
    if FBackground <> nil then
      FBackground.Free;
    FBackground := Value;
    if FBackground <> nil then
      FBackground.AddFreeNotify(Self);
  end;
end;

procedure TCustomGridEh.ClientChanged();
begin
  HFixedVFixedPanel := nil;
  HDataVFixedPanel := nil;
  HContraVFixedPanel := nil;

  HFixedVDataPanel := nil;
  HDataVDataPanel := nil;
  HContraVDataPanel := nil;

  HFixedVFooterPanel := nil;
  HDataVFooterPanel := nil;
  HContraVFooterPanel := nil;

  FHorzScrollBarPanelControl := nil;
  FVertScrollBarPanelControl := nil;
  FCornerScrollBarPanelControl := nil;
  FExtraSizeGripControl := nil;

  if FClient <> nil then
    RecreateContentControls();
end;

procedure TCustomGridEh.ClientResized(Sender: TObject);
begin
  UpdateBoundaries;
  GridLayoutChanged;
end;

procedure TCustomGridEh.RecreateContentControls();
begin
  CheckCreateVirtPanels();
  CreateScrollBarPanels();
  CreateClientExtraPanels();
end;

procedure TCustomGridEh.CreateScrollBarPanels();
begin
  FHorzScrollBarPanelControl := CreateHorzScrollBarPanelControl;
  FHorzScrollBarPanelControl.Name := 'HorzScrollBarPanelControl';
  FHorzScrollBarPanelControl.Parent := Client;
  FHorzScrollBarPanelControl.Visible := False;
  FHorzScrollBarPanelControl.SetBounds(0,0,0,0);

  FVertScrollBarPanelControl := CreateVertScrollBarPanelControl;
  FVertScrollBarPanelControl.Name := 'VertScrollBarPanelControl';
  FVertScrollBarPanelControl.Parent := Client;
  FVertScrollBarPanelControl.Visible := False;
  FVertScrollBarPanelControl.SetBounds(0,0,0,0);

  FCornerScrollBarPanelControl := CreateSizeGripPanel;
  FCornerScrollBarPanelControl.Name := 'CornerScrollBarPanelControl';
  FCornerScrollBarPanelControl.Parent := Client;
  FCornerScrollBarPanelControl.Visible := False;
  FCornerScrollBarPanelControl.SetBounds(0,0,0,0);

  FExtraSizeGripControl := TSizeGripPanelEh.Create(Self);
  FExtraSizeGripControl.Parent := Client;
  FExtraSizeGripControl.Visible := False;
  FExtraSizeGripControl.SetBounds(0,0,0,0);
  FExtraSizeGripControl.GripActiveStatus := TGripActiveStatusEh.Never;
end;

procedure TCustomGridEh.CreateClientExtraPanels();
begin

end;

{$ENDREGION 'TCustomGridEh'}

{$REGION 'TGridLaHostVirtualPanelEh'}

{ TGridLaHostVirtualPanelEh }

function TGridLaHostVirtualPanelEh.CreateBaseCellManager: TVPBaseCellManagerEh;
begin
  Result := TBaseGridCellManagerEh.Create(Self);
end;

function TGridLaHostVirtualPanelEh.GetCellManagerAt(AColIndex, ARowIndex: Integer): TVPBaseCellManagerEh;
begin
  Result := Grid.InternalGetCellManagerAt(Self, AColIndex + InGridStartCol, ARowIndex + InGridStartRow);
end;

function TGridLaHostVirtualPanelEh.GetGrid: TCustomGridEh;
begin
  Result := TCustomGridEh(Owner);
end;

procedure TGridLaHostVirtualPanelEh.LayoutChanged(LaObject: TLaObjectEh);
begin
  inherited LayoutChanged(LaObject);

  if FUpdateCellsProps = False then
    Grid.VirtPanelsUpdateNeeded;
end;

{$ENDREGION 'TGridLaHostVirtualPanelEh'}

{$REGION 'TGridNavigationEh'}

{ TGridNavigationEh }

constructor TGridNavigationEh.Create(AGrid: TCustomGridEh);
begin
  inherited Create();
  FGrid := AGrid;
end;

destructor TGridNavigationEh.Destroy;
begin
  inherited Destroy;
end;

function TGridNavigationEh.IsAtFirstRow: Boolean;
begin
  if Grid.CurRowIndex = Grid.FixedRowCount
    then Result := True
    else Result := False;
end;

function TGridNavigationEh.IsAtLastRow: Boolean;
begin
  if Grid.CurRowIndex = Grid.RowCount - 1
    then Result := True
    else Result := False;
end;

procedure TGridNavigationEh.ToFirstRow;
begin

end;

procedure TGridNavigationEh.ToLastRow;
begin

end;

procedure TGridNavigationEh.ToPriorRow;
var
  NewCurrent: TGridCoord;
begin
  NewCurrent := Grid.FCurCellPos;
  NewCurrent.Y := Grid.NextSelectableCellFor(Grid.CurColIndex, Grid.CurRowIndex, NewCurrent.X, NewCurrent.Y - 1).Y;

  RestrictPos(NewCurrent);

  if (NewCurrent.X <> Grid.CurColIndex) or (NewCurrent.Y <> Grid.CurRowIndex) then
    Grid.InteractiveFocusCell(NewCurrent.X, NewCurrent.Y, TInteractiveActionSourceEh.Keyboard);
end;
procedure TGridNavigationEh.ToNextRow;
var
  NewCurrent: TGridCoord;
begin
  NewCurrent := Grid.FCurCellPos;
  NewCurrent.Y := Grid.NextSelectableCellFor(Grid.CurColIndex, Grid.CurRowIndex, NewCurrent.X, NewCurrent.Y + 1).Y;
  RestrictPos(NewCurrent);
  if (NewCurrent.X <> Grid.CurColIndex) or (NewCurrent.Y <> Grid.CurRowIndex) then
    Grid.InteractiveFocusCell(NewCurrent.X, NewCurrent.Y, TInteractiveActionSourceEh.Keyboard);
end;

procedure TGridNavigationEh.ToPriorPage;
var
  NewCurrent: TGridCoord;
begin
  CalcPageExtents;
  NewCurrent.Y := PrevPageRow;
  RestrictPos(NewCurrent);
  if (NewCurrent.X <> Grid.CurColIndex) or (NewCurrent.Y <> Grid.CurRowIndex) then
    Grid.InteractiveFocusCell(NewCurrent.X, NewCurrent.Y, TInteractiveActionSourceEh.Keyboard);
end;

procedure TGridNavigationEh.ToNextPage;
var
  NewCurrent: TGridCoord;
begin
  CalcPageExtents;
  NewCurrent.Y := NextPageRow;
  RestrictPos(NewCurrent);
  if (NewCurrent.X <> Grid.CurColIndex) or (NewCurrent.Y <> Grid.CurRowIndex) then
    Grid.InteractiveFocusCell(NewCurrent.X, NewCurrent.Y, TInteractiveActionSourceEh.Keyboard);
end;

procedure TGridNavigationEh.RestrictPos(var Coord: TGridCoord);
var
  MinX, MinY, MaxX, MaxY: Integer;
begin
  MinX := Grid.FixedColCount - Grid.FrozenColCount;
  MinY := Grid.FixedRowCount - Grid.FrozenRowCount;
  MaxX := Grid.ColCount - 1;
  MaxY := Grid.RowCount - 1;
  if Coord.X > MaxX then
    Coord.X := MaxX
  else if Coord.X < MinX then
    Coord.X := MinX;

  if Coord.Y > MaxY then
    Coord.Y := MaxY
  else if Coord.Y < MinY then
    Coord.Y := MinY;
end;

procedure TGridNavigationEh.CalcPageExtents;
var
  NewPos, NewCel, NewCelOff, i: Integer;
begin
  NewPos := Grid.VertAxis.RollStartVisPos + Grid.VertAxis.RollClientLen;
  FNextPageRow := Grid.RolRowCount - 1;
  if NewPos < Grid.VertAxis.RollLen then
  begin
    BinarySearch(TGridAxisDataEhCrack(Grid.VertAxis).FRollLocCelPosArr, NewPos, NewCel, NewCelOff);
    if NewCel < Grid.RolRowCount then
    begin
      for i := NewCel to Grid.RolRowCount-1 do
      begin
        FNextPageRow := i-1;
        if Grid.VertAxis.RollLocCelPosArr[i] + Grid.VertAxis.RollCelLens[i] > NewPos + Grid.VertAxis.RollClientLen then
          Break;
      end;
    end;
  end;
  FNextPageRow := FNextPageRow + Grid.FixedRowCount;
  if (FNextPageRow <= Grid.CurRowIndex) and (FNextPageRow < Grid.RowCount) then
    FNextPageRow := Grid.CurRowIndex + 1;

  NewPos := Grid.VertAxis.RollStartVisPos - Grid.VertAxis.RollClientLen;
  BinarySearch(TGridAxisDataEhCrack(Grid.VertAxis).FRollLocCelPosArr, NewPos, NewCel, NewCelOff);
  if NewCelOff > 0 then
    Inc(NewCel);
  FPrevPageRow := NewCel + Grid.FixedRowCount;
  if (FPrevPageRow >= Grid.CurRowIndex) and (PrevPageRow > 0) then
    FPrevPageRow := Grid.CurRowIndex - 1;
end;

{$ENDREGION 'TGridNavigationEh'}

{$REGION 'TBaseGridStylePainterEh'}

{ TBaseGridStylePainterEh }

constructor TBaseGridStylePainterEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FBackgroundFill := TBrush.Create(TBrushKind.None, TAlphaColorRec.Null);
  FBackgroundMiddleFill := TBrush.Create(TBrushKind.None, TAlphaColorRec.Null);
  FCellFocusFill := TBrush.Create(TBrushKind.None, TAlphaColorRec.Null);
  FCellInactiveFocusFill := TBrush.Create(TBrushKind.None, TAlphaColorRec.Null);
  FCellSelectionFill := TBrush.Create(TBrushKind.None, TAlphaColorRec.Null);
  FCellInactiveSelectionFill := TBrush.Create(TBrushKind.None, TAlphaColorRec.Null);
  FFont := TFont.Create;
end;

destructor TBaseGridStylePainterEh.Destroy;
begin
  FreeAndNil(FBackgroundFill);
  FreeAndNil(FBackgroundMiddleFill);
  FreeAndNil(FCellFocusFill);
  FreeAndNil(FCellInactiveFocusFill);
  FreeAndNil(FCellSelectionFill);
  FreeAndNil(FCellInactiveSelectionFill);
  FreeAndNil(FFont);
  inherited Destroy;
end;

function TBaseGridStylePainterEh.GetGrid: TCustomGridEh;
begin
  Result := Owner as TCustomGridEh;
end;

procedure TBaseGridStylePainterEh.LoadStyleItems;

  function FindWithParentStyleResource(const AStyleLookup: string; var AResource: TFmxObject): Boolean;
  var
    ParentStyle: TStyledControl;
  begin
    AResource := nil;
    Result := False;
    if Grid.FindStyleResource<TFmxObject>(AStyleLookup, AResource) then
    begin
      Result := True
    end
    else if Grid.FindStyleResource<TStyledControl>('ParentStyle', ParentStyle) then
    begin
      ParentStyle.ApplyStyleLookup();
      if ParentStyle.FindStyleResource<TFmxObject>(AStyleLookup, AResource) then
        Result := True;
    end;
  end;

var
  StyleObj: TFmxObject;
begin
//  inherited ApplyStyle;

  if FindWithParentStyleResource('ForegroundColor', StyleObj) and (StyleObj is TColorObject) then
    FForegroundColor := TColorObject(StyleObj).Color
  else
    FForegroundColor := TAlphaColorRec.Black;

  if FindWithParentStyleResource('Font', StyleObj) and (StyleObj is TFontObject) then
    FFont.Assign(TFontObject(StyleObj).Font)
  else
    FFont.Assign(SystemFont);
  Grid.RefreshDefaultFont();
  Grid.FontChanged();

  FBackgroundFill.Kind := TBrushKind.None;
  FBackgroundFill.Color := TAlphaColorRec.Null;


  // FBackgroundMiddleFill - ParentStyle.FBackgroundMiddleFill
  if FindWithParentStyleResource('BackgroundMiddleColor', StyleObj) and (StyleObj is TColorObject) then
  begin
    FBackgroundMiddleFill.Color := TColorObject(StyleObj).Color;
    FBackgroundMiddleFill.Kind := TBrushKind.Solid;
  end else
  begin
    FBackgroundMiddleFill.Color := TAlphaColorRec.Null;
    FBackgroundMiddleFill.Kind := TBrushKind.None;
  end;

  // FixedCellForeColor  Global
  if FindWithParentStyleResource('FixedCellForeColor', StyleObj) and (StyleObj is TColorObject) then
    FTitleForeColor := TColorObject(StyleObj).Color
  else
    FTitleForeColor := TAlphaColorRec.Black;

  //BrightLineColor - ParentStyle.BrightLineColor
  if FindWithParentStyleResource('BrightLineColor', StyleObj) and (StyleObj is TColorObject) then
    FCellBorderLineBrightColor := TColorObject(StyleObj).Color
  else
    FCellBorderLineBrightColor := TAlphaColorRec.Silver;

  //DarkLineColor - ParentStyle.DarkLineColor
  if FindWithParentStyleResource('DarkLineColor', StyleObj) and (StyleObj is TColorObject) then
    FCellBorderLineDarkColor :=  TColorObject(StyleObj).Color
  else
    FCellBorderLineDarkColor := TAlphaColorRec.Gray;

  //TopFixedCellBackground - ParentStyle.TopFixedCellBackground
  if FindWithParentStyleResource('TopFixedCellBackground', StyleObj) and (StyleObj is TControl) then
    FTopFixedCellBackground := TControl(StyleObj)
  else
    FTopFixedCellBackground := nil;

  //TopFixedCellForegroundColor - ParentStyle.TopFixedCellForegroundColor
  if FindWithParentStyleResource('TopFixedCellForegroundColor', StyleObj) and (StyleObj is TColorObject) then
    FTopFixedCellForegroundColor :=  TColorObject(StyleObj).Color
  else
    FTopFixedCellForegroundColor := TAlphaColorRec.Black;

  //CellFocusFill - ParentStyle.CellFocusFill
  if FindWithParentStyleResource('CellFocusFill', StyleObj) and (StyleObj is TBrushObject) then
    FCellFocusFill.Assign(TBrushObject(StyleObj).Brush)
  else
    FCellFocusFill.Assign(nil);

  //CellInactiveFocusFill - ParentStyle.CellInactiveFocusFill
  if FindWithParentStyleResource('CellInactiveFocusFill', StyleObj) and (StyleObj is TBrushObject) then
    FCellInactiveFocusFill.Assign(TBrushObject(StyleObj).Brush)
  else
  begin
    FCellInactiveFocusFill.Assign(FCellFocusFill);
    FCellInactiveFocusFill.Color := ColorToGray(FCellFocusFill.Color);
  end;

  //CellSelectionFill - ParentStyle.CellSelectionFill
  if FindWithParentStyleResource('CellSelectionFill', StyleObj) and (StyleObj is TBrushObject) then
    FCellSelectionFill.Assign(TBrushObject(StyleObj).Brush)
  else
    FCellSelectionFill.Assign(nil);

  //CellInactiveSelectionFill - ParentStyle.CellInactiveSelectionFill
  if FindWithParentStyleResource('CellInactiveSelectionFill', StyleObj) and (StyleObj is TBrushObject) then
    FCellInactiveFocusFill.Assign(TBrushObject(StyleObj).Brush)
  else
  begin
    FCellInactiveSelectionFill.Assign(FCellSelectionFill);
    FCellInactiveSelectionFill.Color := ColorToGray(FCellSelectionFill.Color);
  end;
end;

procedure TBaseGridStylePainterEh.FreeStyleItems;
begin
  FTopFixedCellBackground := nil;
end;

function TBaseGridStylePainterEh.LookupGlobalStyleElement(
  AStyleElementName: String): TFmxObject;
begin
  Result := Grid.LookupStyleObject(Grid, Grid.GetStyleContext,
    Grid.Scene, AStyleElementName, AStyleElementName, '', False);
end;

{$ENDREGION 'TBaseGridStylePainterEh'}

end.

