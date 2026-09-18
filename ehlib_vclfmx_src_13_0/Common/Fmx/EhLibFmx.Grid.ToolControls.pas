{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{              EhLibFmx.Grid.ToolControls               }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.Grid.ToolControls;

interface

{$SCOPEDENUMS ON}

uses
  System.SysUtils, System.Classes, System.Types, FMX.Controls, FMX.Graphics,
  System.Variants,
  FMX.Controls.Presentation, FMX.StdCtrls, System.UITypes, FMX.Forms,
  FMX.Objects, FMX.Types, FMX.Platform, FMX.Menus,
  FMX.Layouts,
  EhLibFmx.Utils,
  EhLibFmx.Platform,
  EhLibFmx.ToolControls,
  EhLibFmx.Grid.CellManagers,
  EhLibFmx.Grid.Types,
  EhLibFmx.Types;

type
  EInvalidGridOperationEh = class(Exception);

{ TSimpleCheckBoxEh }

  TSimpleCheckBoxEh = class(TCheckBox)
  protected
    procedure ApplyStyle; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

{ TGridEhScrollBar }

  TScrollBarVisibleModeEh = (AlwaysShow, NeverShow, AutoShow);

  TGridScrollBarEh = class(TPersistent)
  private
    FGrid: TControl;
    FKind: TOrientation;
    FSize: Integer;
    FSmoothStep: Boolean;
    FTracking: Boolean;
    FVisibleMode: TScrollBarVisibleModeEh;

    function GetSize: Integer;
    function GetSmoothStep: Boolean;
    function GetVisible: Boolean;

    procedure SetSize(const Value: Integer);
    procedure SetSmoothStep(Value: Boolean);
    procedure SetVisible(const Value: Boolean);
    procedure SetVisibleMode(const Value: TScrollBarVisibleModeEh);
  protected
    function CheckScrollBarMustBeShown: Boolean;  virtual;

    procedure ScrollBarPanelChanged; virtual;
    procedure SetParams(APosition, AMin, AMax, APageSize: Integer);
    procedure SmoothStepChanged; virtual;
  public
    constructor Create(AGrid: TControl; AKind: TOrientation);
    destructor Destroy; override;

    function ActualScrollBarBoxSize: Integer; virtual;
    function ActualSize: Integer; virtual;
    function CheckHideScrollBar: Boolean;
    function Grid: TControl;
    function IsKeepMaxSizeInDefault: Boolean; virtual;
    function IsScrollBarShowing: Boolean; virtual;
    function ScrollBarPanel: Boolean; virtual;

    procedure Assign(Source: TPersistent); override;
    procedure GetScrollBarParams(var APosition, AMin, AMax, APageSize: Integer);

    property Kind: TOrientation read FKind;
    property Size: Integer read GetSize write SetSize default 0;
    property SmoothStep: Boolean read GetSmoothStep write SetSmoothStep default True;
    property VisibleMode: TScrollBarVisibleModeEh read FVisibleMode write SetVisibleMode default TScrollBarVisibleModeEh.AutoShow;

  published
    property Tracking: Boolean read FTracking write FTracking default True;
    property Visible: Boolean read GetVisible write SetVisible default True;
  end;

{ TGridLineOptionsEh }

  TGridLineOptionsEh = class(TPersistent)
  private
    FBrightColor: TAlphaColor;
    FDarkColor: TAlphaColor;
    FDataHorzColor: TAlphaColor;
    FDataVertColor: TAlphaColor;
    FFixedHorzColor: TAlphaColor;
    FFixedVertColor: TAlphaColor;
    FGrid: TControl;
    FHorzAreaContraBorderColor: TAlphaColor;
    FHorzAreaContraHorzColor: TAlphaColor;
    FHorzAreaContraVertColor: TAlphaColor;
    FHorzAreaFrozenBorderColor: TAlphaColor;
    FHorzAreaFrozenHorzColor: TAlphaColor;
    FHorzAreaFrozenVertColor: TAlphaColor;
    FVertAreaContraBorderColor: TAlphaColor;
    FVertAreaContraHorzColor: TAlphaColor;
    FVertAreaContraVertColor: TAlphaColor;
    FVertAreaFrozenBorderColor: TAlphaColor;
    FVertAreaFrozenHorzColor: TAlphaColor;
    FVertAreaFrozenVertColor: TAlphaColor;
    FHorzLinesVisible: Boolean;
    FVertLinesVisible: Boolean;
    FDarkColorStored: Boolean;
    FBrightColorStored: Boolean;

    function IsDarkColorStored: Boolean;
    function IsBrightColorStored: Boolean;
    function GetDarkColor: TAlphaColor;
    function GetBrightColor: TAlphaColor;

    procedure SetBrightColor(const Value: TAlphaColor);
    procedure SetDarkColor(const Value: TAlphaColor);
    procedure SetDataHorzColor(const Value: TAlphaColor);
    procedure SetDataVertColor(const Value: TAlphaColor);
    procedure SetHorzLinesVisible(const Value: Boolean);
    procedure SetVertLinesVisible(const Value: Boolean);
    procedure SetDarkColorStored(const Value: Boolean);
    procedure SetBrightColorStored(const Value: Boolean);
  protected
    property Grid: TControl read FGrid;

    function GetCellColor(AColIndex, ARowIndex: Integer): TAlphaColor; virtual;
    function GetDataHorzColor: TAlphaColor; virtual;
    function GetDataVertColor: TAlphaColor; virtual;
    function GetDownBorderCellColor(AColIndex, ARowIndex: Integer): TAlphaColor; virtual;
    function GetHorzAreaFrozenBorderColor: TAlphaColor; virtual;
    function GetHorzAreaFrozenHorzColor: TAlphaColor; virtual;
    function GetHorzAreaFrozenVertColor: TAlphaColor; virtual;
    function GetLeftBorderCellColor(AColIndex, ARowIndex: Integer): TAlphaColor; virtual;
    function GetRightBorderCellColor(AColIndex, ARowIndex: Integer): TAlphaColor; virtual;
    function GetTopBorderCellColor(AColIndex, ARowIndex: Integer): TAlphaColor; virtual;
    function GetVertAreaFrozenBorderColor: TAlphaColor; virtual;
    function GetVertAreaFrozenHorzColor: TAlphaColor; virtual;
    function GetVertAreaFrozenVertColor: TAlphaColor; virtual;
    function DefaultDarkColor(): TAlphaColor; virtual;
    function DefaultBrightColor(): TAlphaColor; virtual;

    property FixedVertColor: TAlphaColor read FFixedVertColor write FFixedVertColor default TAlphaColorRec.Null;
    property FixedHorzColor: TAlphaColor read FFixedHorzColor write FFixedHorzColor default TAlphaColorRec.Null;
    property VertAreaFrozenVertColor: TAlphaColor read FVertAreaFrozenVertColor write FVertAreaFrozenVertColor default TAlphaColorRec.Null;
    property VertAreaFrozenHorzColor: TAlphaColor read FVertAreaFrozenHorzColor write FVertAreaFrozenHorzColor default TAlphaColorRec.Null;
    property HorzAreaFrozenVertColor: TAlphaColor read FHorzAreaFrozenVertColor write FHorzAreaFrozenVertColor default TAlphaColorRec.Null;
    property HorzAreaFrozenHorzColor: TAlphaColor read FHorzAreaFrozenHorzColor write FHorzAreaFrozenHorzColor default TAlphaColorRec.Null;
    property VertAreaFrozenBorderColor: TAlphaColor read FVertAreaFrozenBorderColor write FVertAreaFrozenBorderColor default TAlphaColorRec.Null;
    property HorzAreaFrozenBorderColor: TAlphaColor read FHorzAreaFrozenBorderColor write FHorzAreaFrozenBorderColor default TAlphaColorRec.Null;
    property DataVertColor: TAlphaColor read FDataVertColor write SetDataVertColor default TAlphaColorRec.Null;
    property DataHorzColor: TAlphaColor read FDataHorzColor write SetDataHorzColor default TAlphaColorRec.Null;
    property VertAreaContraVertColor: TAlphaColor read FVertAreaContraVertColor write FVertAreaContraVertColor default TAlphaColorRec.Null;
    property VertAreaContraHorzColor: TAlphaColor read FVertAreaContraHorzColor write FVertAreaContraHorzColor default TAlphaColorRec.Null;
    property HorzAreaContraVertColor: TAlphaColor read FHorzAreaContraVertColor write FHorzAreaContraVertColor default TAlphaColorRec.Null;
    property HorzAreaContraHorzColor: TAlphaColor read FHorzAreaContraHorzColor write FHorzAreaContraHorzColor default TAlphaColorRec.Null;
    property VertAreaContraBorderColor: TAlphaColor read FVertAreaContraBorderColor write FVertAreaContraBorderColor default TAlphaColorRec.Null;
    property HorzAreaContraBorderColor: TAlphaColor read FHorzAreaContraBorderColor write FHorzAreaContraBorderColor default TAlphaColorRec.Null;
  public
    constructor Create(AGrid: TControl);

    function GetFixedVertColor: TAlphaColor; virtual;
    function GetFixedHorzColor: TAlphaColor; virtual;
    function GetVertAreaContraVertColor: TAlphaColor; virtual;
    function GetVertAreaContraHorzColor: TAlphaColor; virtual;
    function GetHorzAreaContraVertColor: TAlphaColor; virtual;
    function GetHorzAreaContraHorzColor: TAlphaColor; virtual;
    function GetVertAreaContraBorderColor: TAlphaColor; virtual;
    function GetHorzAreaContraBorderColor: TAlphaColor; virtual;

    property BrightColor: TAlphaColor read GetBrightColor write SetBrightColor stored IsBrightColorStored;
    property BrightColorStored: Boolean read FBrightColorStored write SetBrightColorStored default False;

    property DarkColor: TAlphaColor read GetDarkColor write SetDarkColor stored IsDarkColorStored;
    property DarkColorStored: Boolean read FDarkColorStored write SetDarkColorStored default False;

    property HorzLinesVisible: Boolean read FHorzLinesVisible write SetHorzLinesVisible default True;
    property VertLinesVisible: Boolean read FVertLinesVisible write SetVertLinesVisible default True;

  end;

{ TGridBackgroundDataEh }

  TGridBackgroundDataEh = class(TPersistent)
  private
    FGrid: TComponent;
    FImageHorzMargin: Integer;
    FImagePlacement: TImagePlacementEh;
    FImageVertMargin: Integer;
    FPicture: TBitmap;
    FVisible: Boolean;

    procedure SetPicture(Value: TBitmap);
    procedure SetImagePlacement(Value: TImagePlacementEh);
    procedure SetImageHorzMargin(const Value: Integer);
    procedure SetImageVertMargin(const Value: Integer);
    procedure SetVisible(const Value: Boolean);

  protected
    function DestRect: TRect;
    procedure PictureChanged(Sender: TObject);
  public
    constructor Create(AGrid: TComponent);
    destructor Destroy; override;

    function Showing: Boolean; virtual;
    function BoundRect: TRect; virtual;

    procedure PaintBackgroundData; virtual;
    property Grid: TComponent read FGrid;
  published
    property HorzMargin: Integer read FImageHorzMargin write SetImageHorzMargin default 0;
    property Picture: TBitmap read FPicture write SetPicture;
    property Placement: TImagePlacementEh read FImagePlacement write SetImagePlacement default TImagePlacementEh.CenterCenter;
    property VertMargin: Integer read FImageVertMargin write SetImageVertMargin default 0;
    property Visible: Boolean read FVisible write SetVisible default False;
  end;

{ TScrollBarControlEh }

  TScrollBarControlEh = class(TScrollBar)
  private
    FIsTrackMouseDown: Boolean;
  protected
    procedure ApplyStyle; override;
    procedure TrackMouseDownHandler(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single); virtual;
    procedure TrackMouseUpHandler(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetBounds(X, Y, AWidth, AHeight: Single); override;

    property IsTrackMouseDown: Boolean read FIsTrackMouseDown;
  end;

{ TGridScrollBarPanelControlEh }

  TGridScrollBarPanelControlEh = class(TPresentedControl)
  private
    FIgnoreCancelMode: Boolean;
    FScrollBar: TScrollBarControlEh;
    FKeepMaxSizeInDefault: Boolean;
    FGrid: TControl;
    function GetOnScroll: TNotifyEvent;
    procedure SetOnScroll(const Value: TNotifyEvent);
    procedure SetKeepMaxSizeInDefault(const Value: Boolean);

  protected
    FKind: TOrientation;

    function ScrollBatCode: Integer;
    function ChildControlCanMouseDown(AControl: TControl): Boolean; virtual;
    procedure SetPaintColors; virtual;

    procedure Resize; override;
    procedure DoRealign; override;
    procedure VisibleChanged; override;
    procedure OnScrollEvent(Sender: TObject);

    property IgnoreCancelMode: Boolean read FIgnoreCancelMode write FIgnoreCancelMode;
  public
    constructor Create(AOwner: TComponent; AKind: TOrientation); reintroduce;
    destructor Destroy; override;

    function MaxSizeForExtraPanel: Integer;
    procedure AdjustSize; override;
    procedure Invalidate;
    procedure SetParams(APosition, AMin, AMax, APageSize: Integer);
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Single); override;

    property OnScroll: TNotifyEvent read GetOnScroll write SetOnScroll;
    property ScrollBar: TScrollBarControlEh read FScrollBar;
    property KeepMaxSizeInDefault: Boolean read FKeepMaxSizeInDefault write SetKeepMaxSizeInDefault;
    property Grid: TControl read FGrid;
  end;

  TGripActiveStatusEh = (Never, Auto, Always);

  { TSizeGripPanelEh }

  TSizeGripPanelEh = class(TPresentedControl)
  private
    FTriangleWindow: Boolean;
    FGripActiveStatus: TGripActiveStatusEh;
    FPosition: TSizeGripPosition;

    procedure SetTriangleWindow(const Value: Boolean);
    procedure SetPosition(const Value: TSizeGripPosition);

  protected
    FInitFormSize: TPoint;
    FInitFormPos: TPoint;
    FMouseMousePos: TPoint;
    FSizeGrip: TSizeGripEh;

    function CheckInCorner: Boolean;
    function CheckGripActive: Boolean;
    function GetFormSize: TPoint;
    function GetSizableForm: TCommonCustomForm;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure Paint; override;
    procedure Resize; override;

    procedure UpdateWindowRegion;

  public
    constructor Create(AOwner: TComponent); override;

    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Single); override;
    procedure UpdateSizeGrip;

    property TriangleWindow: Boolean read FTriangleWindow write SetTriangleWindow default True;
    property GripActiveStatus: TGripActiveStatusEh read FGripActiveStatus write FGripActiveStatus;
    property Position: TSizeGripPosition read FPosition write SetPosition;
  end;

{ TGridDragWinEh }

  TGridDragWinEh = class(TControl)
  private
    FAlphaBlendValue: Byte;
    FTransparentColorValue: TAlphaColor;

  protected
    procedure SetLayeredAttribs;

  public
    constructor Create(AOwner: TComponent); override;

    procedure MoveToFor(NewPos: TPoint); overload; virtual;
    procedure MoveToFor(NewPos: TPoint; NewWidth, NewHeight: Integer); overload; virtual;
    procedure StartShow(Pos: TPoint; Width, Height: Integer); overload; virtual;
    procedure StartShow(Pos: TPoint; Height: Integer); overload; virtual;
    procedure TemporaryHide;

    property AlphaBlendValue: Byte read FAlphaBlendValue write FAlphaBlendValue;
    property TransparentColorValue: TAlphaColor read FTransparentColorValue write FTransparentColorValue;
  end;

  { TGridDragFormEh }

  TGridDragFormEh = class(TForm)
  private
  protected
    procedure InitControls(); virtual;
  public
    constructor Create(AOwner: TComponent); override;

    procedure Show;
    procedure MoveToFor(NewPos: TPoint); overload; virtual;
    procedure MoveToFor(NewPos: TPoint; NewWidth, NewHeight: Integer); overload; virtual;
    procedure StartShow(Pos: TPoint; Width, Height: Integer); overload; virtual;
    procedure StartShow(Pos: TPoint; Height: Integer); overload; virtual;
    procedure TemporaryHide;
  end;

{ TGridMoveLineEh }

  TGridMoveLineEh = class(TGridDragFormEh)
  private
    FLineColor: TAlphaColor;
    FLine: TLine;
    FStartPointer: array [0..4] of TLine;
    FEndPointer: array [0..4] of TLine;
  protected
    FIsVert: Boolean;

    procedure DoPaint(const Canvas: TCanvas; const ARect: TRectF); override;
    procedure InitControls(); override;
    procedure Realign; override;
  public
    constructor Create(AOwner: TComponent); override;

    procedure StartShow(Pos: TPoint; AIsVert: Boolean; Size: Integer; ACaptureControl: TObject); virtual;
    procedure MoveToFor(NewPos: TPoint); override;

    property IsVert: Boolean read FIsVert;
    property LineColor: TAlphaColor read FLineColor write FLineColor;
  end;

{ TGridSizingRectFormEh }

  TGridSizingRectFormEh = class(TGridDragFormEh)
  private
    class var
      FForm: TGridSizingRectFormEh;
  private
    FLineColor: TAlphaColor;
    FRectBorder: TRectangle;

  protected
    procedure InitControls(); override;

  public
    constructor Create(AOwner: TComponent); override;

    class function GetForm: TGridSizingRectFormEh;

    property LineColor: TAlphaColor read FLineColor write FLineColor;
  end;

{ TControlBorderEh }

  TControlEdgeBorder = (Left, Top, Right, Bottom);
  TControlEdgeBorders = set of TControlEdgeBorder;

  TControlBorderEh = class(TPersistent)
  private
    FColor: TAlphaColor;
    FEdgeBorders: TControlEdgeBorders;
    FGrid: TControl;
    FBorderStyle: TBorderStyle;

    function GetStyle: TBorderStyle;

    procedure SetColor(const Value: TAlphaColor);
    procedure SetEdgeBorders(const Value: TControlEdgeBorders);
    procedure SetStyle(const Value: TBorderStyle);

  public

    constructor Create(AGrid: TControl);
    destructor Destroy; override;

    procedure Paint(Canvas: TCanvas; BoundRect: TRect);
    procedure BorderChanged();

    function GetActualEdgeBorders: TControlEdgeBorders;
  published

    property Color: TAlphaColor read FColor write SetColor default TAlphaColorRec.Null;
    property EdgeBorders: TControlEdgeBorders read FEdgeBorders write SetEdgeBorders default [TControlEdgeBorder.Left, TControlEdgeBorder.Top, TControlEdgeBorder.Right, TControlEdgeBorder.Bottom];
    property Style: TBorderStyle read GetStyle write SetStyle stored False;
  end;


{ TBaseGridMouseStateEh }

  TBaseGridMouseStateEh = class(TPersistent)
  private
    FExtraData: TObject;
    FGrid: TControl;
  protected
    procedure Release; virtual;
    procedure Init(AExtraData: TObject);
  public
    constructor Create(AGrid: TControl);

    property ExtraData: TObject read FExtraData write FExtraData;
    property Grid: TControl read FGrid;
  end;

{ TGridMouseNormalStateEh }

  TGridMouseNormalStateEh = class(TBaseGridMouseStateEh)
  public
  end;

{ TGridMouseColSizingStateEh }

  TGridMouseColSizingStateEh = class(TBaseGridMouseStateEh)
  end;

{ TGridMouseRowSizingStateEh }

  TGridMouseRowSizingStateEh = class(TBaseGridMouseStateEh)
  end;

{ TGridMouseColMovingStateEh }

  TGridMouseColMovingStateEh = class(TBaseGridMouseStateEh)
  private
    FGrid: TControl;
    FColIndex: Integer;
    FRowIndex: Integer;
//    FInCellX: Integer;
//    FInCellY: Integer;
    FMoveFromIndex: Integer;
    FMoveToIndex: Integer;
    FMoveFromCellOriginDistance: Integer;
    FMovePosRightSite: Boolean;
    procedure SetMoveToIndex(const Value: Integer);

  public
    constructor Init(AGrid: TControl; AColIndex, ARowIndex: Integer; AScreenPos: TPointF; AExtraData: TObject); reintroduce; virtual;
    destructor Destroy; override;

    property Grid: TControl read FGrid;
    property ColIndex: Integer read FColIndex;
    property RowIndex: Integer read FRowIndex;
//    property InCellX: Integer read FInCellX;
//    property InCellY: Integer read FInCellY;
    property MoveFromIndex: Integer read FMoveFromIndex write FMoveFromIndex;
    property MoveToIndex: Integer read FMoveToIndex write SetMoveToIndex;
    property MoveFromCellOriginDistance: Integer read FMoveFromCellOriginDistance write FMoveFromCellOriginDistance;
    property MovePosRightSite: Boolean read FMovePosRightSite write FMovePosRightSite;
  end;

{ TGridMouseRowMovingStateEh }

  TGridMouseRowMovingStateEh = class(TBaseGridMouseStateEh)
  private
    FGrid: TControl;

    FMoveFromIndex: Integer;
    FMoveToIndex: Integer;
    FInitMousePos: TPoint;

  public
    procedure Init(AGrid: TControl; AMoveFromIndex: Integer; AMoveToIndex: Integer; AMousePos: TPoint; AExtraData: TObject); reintroduce; virtual;
    destructor Destroy; override;

    property Grid: TControl read FGrid;
    property MoveFromIndex: Integer read FMoveFromIndex write FMoveFromIndex;
    property MoveToIndex: Integer read FMoveToIndex write FMoveToIndex;
    property InitMousePos: TPoint read FInitMousePos;
  end;

{ TGridMouseSelectingStateEh }

  TGridMouseSelectingStateEh = class(TBaseGridMouseStateEh)
  end;

{ TGridMouseStateManageEh }

  TGridMouseStateManagerEh = class(TPersistent)
  private
    FGrid: TControl;
    FNormalState: TGridMouseNormalStateEh;
    FColSizingState: TGridMouseColSizingStateEh;
    FRowSizingState: TGridMouseRowSizingStateEh;
    FColMovingState: TGridMouseColMovingStateEh;
    FRowMovingState: TGridMouseRowMovingStateEh;
    FSelectingState: TGridMouseSelectingStateEh;

  public
    constructor Create(AGrid: TControl);
    destructor Destroy; override;

    property NormalState: TGridMouseNormalStateEh read FNormalState;
    property ColSizingState: TGridMouseColSizingStateEh read FColSizingState;
    property RowSizingState: TGridMouseRowSizingStateEh read FRowSizingState;
    property RowMovingState: TGridMouseRowMovingStateEh read FRowMovingState;
    property ColMovingState: TGridMouseColMovingStateEh read FColMovingState;
    property SelectingState: TGridMouseSelectingStateEh read FSelectingState;
  end;

  function GetMoveLineEh: TGridMoveLineEh;

procedure RaiseGridError(const S: string);
procedure TGridSizingRectFormEhDestroy;

implementation

uses EhLibFmx.Grids;

type
  TCustomGridEhCrack = class(TCustomGridEh);
  TControlCrack = class(TControl);

  TCustomGridEhHelper = class helper for TCustomGridEh
  private
    function GetGrid: TCustomGridEhCrack;
  public
    property Grid: TCustomGridEhCrack read GetGrid;
  end;

  function TCustomGridEhHelper.GetGrid: TCustomGridEhCrack;
  begin
    Result := TCustomGridEhCrack(Self);
  end;

type
  TGridScrollBarEhHelper = class helper for TGridScrollBarEh
  private
    function GetGrid: TCustomGridEhCrack;
  public
    property Grid: TCustomGridEhCrack read GetGrid;
  end;

  function TGridScrollBarEhHelper.GetGrid: TCustomGridEhCrack;
  begin
    Result := TCustomGridEhCrack(FGrid);
  end;

type
  TGridLineColorsEhHelper = class helper for TGridLineOptionsEh
  private
    function GetGrid: TCustomGridEhCrack;
  public
    property Grid: TCustomGridEhCrack read GetGrid;
  end;

  function TGridLineColorsEhHelper.GetGrid: TCustomGridEhCrack;
  begin
    Result := TCustomGridEhCrack(FGrid);
  end;

type
  TGridBackgroundDataEhHelper = class helper for TGridBackgroundDataEh
  private
    function GetGrid: TCustomGridEhCrack;
  public
    property Grid: TCustomGridEhCrack read GetGrid;
  end;

  function TGridBackgroundDataEhHelper.GetGrid: TCustomGridEhCrack;
  begin
    Result := TCustomGridEhCrack(FGrid);
  end;

procedure RaiseGridError(const S: string);
begin
  raise EInvalidGridOperationEh.Create(S);
end;

procedure CanvasFillRect(Canvas: TCanvas; const ARect: TRectF; const AOpacity: Single);
begin
  Canvas.FillRect(ARect, 0, 0, [], AOpacity);
end;

{ TGridScrollBarEh }

constructor TGridScrollBarEh.Create(AGrid: TControl; AKind: TOrientation);
begin
  inherited Create;
  FGrid := AGrid;
  FKind := AKind;
  FVisibleMode := TScrollBarVisibleModeEh.AutoShow;
  FTracking := True;
  FSmoothStep := True;
end;

destructor TGridScrollBarEh.Destroy;
begin
  inherited Destroy;
end;

procedure TGridScrollBarEh.Assign(Source: TPersistent);
begin
  if Source is TGridScrollBarEh then
    Tracking := TGridScrollBarEh(Source).Tracking
  else
    inherited Assign(Source);
end;

function TGridScrollBarEh.IsKeepMaxSizeInDefault: Boolean;
begin
  Result := False;
end;

function TGridScrollBarEh.IsScrollBarShowing: Boolean;
begin
  Result := CheckScrollBarMustBeShown;
end;

function TGridScrollBarEh.CheckScrollBarMustBeShown: Boolean;
var
  APosition, AMin, AMax, APageSize: Integer;
begin
  if VisibleMode = TScrollBarVisibleModeEh.AlwaysShow then
    Result := True
  else if VisibleMode = TScrollBarVisibleModeEh.NeverShow then
    Result := False
  else 
  begin
    if Kind = TOrientation.Horizontal
      then Grid.GetDataForHorzScrollBar(APosition, AMin, AMax, APageSize)
      else Grid.GetDataForVertScrollBar(APosition, AMin, AMax, APageSize);
    if (AMax <= AMin) or (AMax - AMin < APageSize)
    then
      Result := False
    else
      Result := True;
  end;
end;

function TGridScrollBarEh.CheckHideScrollBar: Boolean;
begin
  Result := not IsScrollBarShowing;
end;

procedure TGridScrollBarEh.SetVisibleMode(const Value: TScrollBarVisibleModeEh);
begin
  if FVisibleMode <> Value then
  begin
    FVisibleMode := Value;
    Grid.UpdateBoundaries;
  end;
end;

procedure TGridScrollBarEh.ScrollBarPanelChanged;
begin
  if Assigned(FGrid) then
    Grid.UpdateScrollBars;
end;

procedure TGridScrollBarEh.GetScrollBarParams(var APosition, AMin, AMax, APageSize: Integer);
var
  sb: TScrollBar;
begin
  if Grid.HorzScrollBarPanelControl = nil then
  begin
    APosition := 0;
    AMin := 0;
    AMax := 0;
    APageSize := 0;
    Exit;
  end;

  if Kind = TOrientation.Horizontal
    then sb := Grid.HorzScrollBarPanelControl.ScrollBar
    else sb := Grid.VertScrollBarPanelControl.ScrollBar;

  APosition := Round(sb.Value);
  AMin := Round(sb.Min);
  AMax := Round(sb.Max);
  APageSize := Round(sb.ViewportSize);
end;

procedure TGridScrollBarEh.SetParams(APosition, AMin, AMax, APageSize: Integer);
begin
  if Kind = TOrientation.Horizontal
    then Grid.HorzScrollBarPanelControl.SetParams(APosition, AMin, AMax, APageSize)
    else Grid.VertScrollBarPanelControl.SetParams(APosition, AMin, AMax, APageSize);
end;

function TGridScrollBarEh.GetSmoothStep: Boolean;
begin
  Result := FSmoothStep;
end;

function TGridScrollBarEh.GetVisible: Boolean;
begin
  if FVisibleMode = TScrollBarVisibleModeEh.NeverShow
    then Result := False
    else Result := True;
end;

procedure TGridScrollBarEh.SetVisible(const Value: Boolean);
begin
  if Value
    then SetVisibleMode(TScrollBarVisibleModeEh.AutoShow)
    else SetVisibleMode(TScrollBarVisibleModeEh.NeverShow);
end;

procedure TGridScrollBarEh.SetSmoothStep(Value: Boolean);
begin
  if FSmoothStep <> Value then
  begin
    FSmoothStep := Value;
    SmoothStepChanged;
  end;
end;

procedure TGridScrollBarEh.SmoothStepChanged;
begin
end;

function TGridScrollBarEh.Grid: TControl;
begin
  Result := FGrid;
end;

function TGridScrollBarEh.ScrollBarPanel: Boolean;
begin
  Result := True;
end;

function TGridScrollBarEh.GetSize: Integer;
begin
  Result := FSize;
end;

procedure TGridScrollBarEh.SetSize(const Value: Integer);
begin
  if FSize <> Value then
  begin
    FSize := Value;
    Grid.ScrollBarSizeChanged(Self);
  end;
end;

function TGridScrollBarEh.ActualSize: Integer;
begin
  if Size > 0
    then Result := Size
    else Result := Grid.ScrollBarSize;
end;

function TGridScrollBarEh.ActualScrollBarBoxSize: Integer;
begin
  Result := ActualSize;
  if IsKeepMaxSizeInDefault then
  begin
    if Result > 18 then
      Result := 18;
  end;
end;

{ TGridLineColorsEh }

constructor TGridLineOptionsEh.Create(AGrid: TControl);
begin
  inherited Create;
  FGrid := AGrid;
  FBrightColor := TAlphaColorRec.Null;
  FDarkColor := TAlphaColorRec.Null;

  FDataHorzColor := TAlphaColorRec.Null;
  FDataVertColor := TAlphaColorRec.Null;
  FFixedHorzColor := TAlphaColorRec.Null;
  FFixedVertColor := TAlphaColorRec.Null;

  FHorzAreaContraBorderColor := TAlphaColorRec.Null;
  FHorzAreaContraHorzColor := TAlphaColorRec.Null;
  FHorzAreaContraVertColor := TAlphaColorRec.Null;
  FHorzAreaFrozenBorderColor := TAlphaColorRec.Null;
  FHorzAreaFrozenHorzColor := TAlphaColorRec.Null;
  FHorzAreaFrozenVertColor := TAlphaColorRec.Null;
  FVertAreaContraBorderColor := TAlphaColorRec.Null;
  FVertAreaContraHorzColor := TAlphaColorRec.Null;
  FVertAreaContraVertColor := TAlphaColorRec.Null;
  FVertAreaFrozenBorderColor := TAlphaColorRec.Null;
  FVertAreaFrozenHorzColor := TAlphaColorRec.Null;
  FVertAreaFrozenVertColor := TAlphaColorRec.Null;

  FHorzLinesVisible := True;
  FVertLinesVisible := True;
end;

function TGridLineOptionsEh.GetCellColor(AColIndex, ARowIndex: Integer): TAlphaColor;
begin
  if (AColIndex < Grid.FixedColCount - Grid.FrozenColCount) or (ARowIndex < Grid.FixedRowCount - Grid.FrozenRowCount) then
    Result := DarkColor
  else if (AColIndex < Grid.ColCount) and (ARowIndex < Grid.RowCount) then
    Result := BrightColor
  else if (AColIndex < Grid.ColCount) and (ARowIndex >= Grid.RowCount) then
    Result := GetVertAreaContraVertColor
  else if (AColIndex >= Grid.ColCount) and (ARowIndex < Grid.RowCount) then
    Result := GetHorzAreaContraHorzColor
  else
    Result := GetVertAreaContraVertColor;
end;

function TGridLineOptionsEh.GetLeftBorderCellColor(AColIndex, ARowIndex: Integer): TAlphaColor;
begin
  if (AColIndex = Grid.ColCount)
    then Result := GetVertAreaContraBorderColor
    else Result := BrightColor;
end;

function TGridLineOptionsEh.GetRightBorderCellColor(AColIndex, ARowIndex: Integer): TAlphaColor;
begin
  if (Grid.FrozenColCount > 0) and (AColIndex = Grid.FixedColCount-1)
    then Result := GetVertAreaFrozenBorderColor
    else Result := BrightColor;
end;

function TGridLineOptionsEh.GetTopBorderCellColor(AColIndex, ARowIndex: Integer): TAlphaColor;
begin
  if (ARowIndex = Grid.RowCount)
    then Result := GetHorzAreaContraBorderColor
    else Result := BrightColor;
end;

function TGridLineOptionsEh.GetDownBorderCellColor(AColIndex, ARowIndex: Integer): TAlphaColor;
begin
  if (Grid.FrozenRowCount > 0) and (ARowIndex = Grid.FixedRowCount-1)
    then Result := GetDarkColor
    else Result := BrightColor;
end;

function TGridLineOptionsEh.GetDataHorzColor: TAlphaColor;
begin
  if DataHorzColor = TAlphaColorRec.Null
    then Result := BrightColor
    else Result := DataHorzColor;
end;

function TGridLineOptionsEh.GetDataVertColor: TAlphaColor;
begin
  if DataVertColor = TAlphaColorRec.Null
    then Result := BrightColor
    else Result := DataVertColor;
end;

function TGridLineOptionsEh.GetFixedHorzColor: TAlphaColor;
begin
  if FixedHorzColor = TAlphaColorRec.Null
    then Result := GetDarkColor
    else Result := FixedHorzColor;
end;

function TGridLineOptionsEh.GetFixedVertColor: TAlphaColor;
begin
  if FixedVertColor = TAlphaColorRec.Null
    then Result := GetDarkColor
    else Result := FixedVertColor;
end;

function TGridLineOptionsEh.GetHorzAreaContraBorderColor: TAlphaColor;
begin
  if HorzAreaContraBorderColor = TAlphaColorRec.Null
    then Result := GetDarkColor
    else Result := HorzAreaContraBorderColor;
end;

function TGridLineOptionsEh.GetHorzAreaContraHorzColor: TAlphaColor;
begin
  if HorzAreaContraHorzColor = TAlphaColorRec.Null
    then Result := BrightColor
    else Result := HorzAreaContraHorzColor;
end;

function TGridLineOptionsEh.GetHorzAreaContraVertColor: TAlphaColor;
begin
  if HorzAreaContraVertColor = TAlphaColorRec.Null
    then Result := BrightColor
    else Result := HorzAreaContraVertColor;
end;

function TGridLineOptionsEh.GetHorzAreaFrozenBorderColor: TAlphaColor;
begin
  if HorzAreaFrozenBorderColor = TAlphaColorRec.Null
    then Result := GetDarkColor
    else Result := HorzAreaFrozenBorderColor;
end;

function TGridLineOptionsEh.GetHorzAreaFrozenHorzColor: TAlphaColor;
begin
  if HorzAreaFrozenHorzColor = TAlphaColorRec.Null
    then Result := BrightColor
    else Result := HorzAreaFrozenHorzColor;
end;

function TGridLineOptionsEh.GetHorzAreaFrozenVertColor: TAlphaColor;
begin
  if HorzAreaFrozenVertColor = TAlphaColorRec.Null
    then Result := BrightColor
    else Result := HorzAreaFrozenVertColor;
end;

function TGridLineOptionsEh.GetVertAreaContraBorderColor: TAlphaColor;
begin
  if VertAreaContraBorderColor = TAlphaColorRec.Null
    then Result := GetDarkColor
    else Result := VertAreaContraBorderColor;
end;

function TGridLineOptionsEh.GetVertAreaContraHorzColor: TAlphaColor;
begin
  if VertAreaContraHorzColor = TAlphaColorRec.Null
    then Result := BrightColor
    else Result := VertAreaContraHorzColor;
end;

function TGridLineOptionsEh.GetVertAreaContraVertColor: TAlphaColor;
begin
  if VertAreaContraVertColor = TAlphaColorRec.Null
    then Result := BrightColor
    else Result := VertAreaContraVertColor;
end;

function TGridLineOptionsEh.GetVertAreaFrozenBorderColor: TAlphaColor;
begin
  if VertAreaFrozenBorderColor = TAlphaColorRec.Null
    then Result := GetDarkColor
    else Result := VertAreaFrozenBorderColor;
end;

function TGridLineOptionsEh.GetVertAreaFrozenHorzColor: TAlphaColor;
begin
  if VertAreaFrozenHorzColor = TAlphaColorRec.Null
    then Result := BrightColor
    else Result := VertAreaFrozenHorzColor;
end;

function TGridLineOptionsEh.GetVertAreaFrozenVertColor: TAlphaColor;
begin
  if VertAreaFrozenVertColor = TAlphaColorRec.Null
    then Result := BrightColor
    else Result := VertAreaFrozenVertColor;
end;

procedure TGridLineOptionsEh.SetDataHorzColor(const Value: TAlphaColor);
begin
  if FDataHorzColor <> Value then
  begin
    FDataHorzColor := Value;
    Grid.Invalidate;
  end;
end;

procedure TGridLineOptionsEh.SetDataVertColor(const Value: TAlphaColor);
begin
  if FDataVertColor <> Value then
  begin
    FDataVertColor := Value;
    Grid.GridLinesVisibilityChanged;
  end;
end;

procedure TGridLineOptionsEh.SetHorzLinesVisible(const Value: Boolean);
begin
  if FHorzLinesVisible <> Value then
  begin
    FHorzLinesVisible := Value;
    Grid.GridLinesVisibilityChanged;
  end;
end;

procedure TGridLineOptionsEh.SetVertLinesVisible(const Value: Boolean);
begin
  if FVertLinesVisible<> Value then
  begin
    FVertLinesVisible := Value;
    Grid.GridLinesVisibilityChanged;
  end;
end;

{$REGION DarkColor}
function TGridLineOptionsEh.GetDarkColor: TAlphaColor;
begin
  if DarkColorStored
    then Result := FDarkColor
    else Result := DefaultDarkColor();
end;

procedure TGridLineOptionsEh.SetDarkColor(const Value: TAlphaColor);
begin
  if FDarkColor <> Value then
  begin
    FDarkColor := Value;
    FDarkColorStored := True;
    Grid.Invalidate;
  end;
end;

function TGridLineOptionsEh.DefaultDarkColor(): TAlphaColor;
begin
  Result := Grid.StylePainter.CellBorderLineDarkColor;
end;

function TGridLineOptionsEh.IsDarkColorStored: Boolean;
begin
  Result := FDarkColorStored;
end;

procedure TGridLineOptionsEh.SetDarkColorStored(const Value: Boolean);
begin
  if FDarkColorStored <> Value then
  begin
    FDarkColorStored := Value;
    Grid.Invalidate;
  end;
end;
{$ENDREGION DarkColor}

{$REGION BrightColor}
function TGridLineOptionsEh.GetBrightColor: TAlphaColor;
begin
  if BrightColorStored
    then Result := FBrightColor
    else Result := DefaultBrightColor();
end;

procedure TGridLineOptionsEh.SetBrightColor(const Value: TAlphaColor);
begin
  if FBrightColor <> Value then
  begin
    FBrightColor := Value;
    FBrightColorStored := True;
    Grid.Invalidate;
  end;
end;

function TGridLineOptionsEh.DefaultBrightColor(): TAlphaColor;
begin
  Result := Grid.StylePainter.CellBorderLineBrightColor;
end;

function TGridLineOptionsEh.IsBrightColorStored: Boolean;
begin
  Result := FBrightColorStored;
end;

procedure TGridLineOptionsEh.SetBrightColorStored(const Value: Boolean);
begin
  if FBrightColorStored <> Value then
  begin
    FBrightColorStored := Value;
    Grid.Invalidate;
  end;
end;
{$ENDREGION BrightColor}

{ TGridBackgroundDataEh }

constructor TGridBackgroundDataEh.Create(AGrid: TComponent);
begin
  inherited Create;
  FGrid := AGrid;
  Visible := False;
  Placement := TImagePlacementEh.CenterCenter;
  HorzMargin := 0;
  VertMargin := 0;

  FPicture := TBitmap.Create;
  FPicture.OnChange := PictureChanged;
end;

destructor TGridBackgroundDataEh.Destroy;
begin
  FreeAndNil(FPicture);
  inherited Destroy;
end;

procedure TGridBackgroundDataEh.SetPicture(Value: TBitmap);
begin
  FPicture.Assign(Value);
end;

procedure TGridBackgroundDataEh.SetImagePlacement(Value: TImagePlacementEh);
begin
  if FImagePlacement <> Value then
  begin
    FImagePlacement := Value;
    PictureChanged(Self);
  end;
end;

procedure TGridBackgroundDataEh.SetImageHorzMargin(const Value: Integer);
begin
  if FImageHorzMargin <> Value then
  begin
    FImageHorzMargin := Value;
    PictureChanged(Self);
  end;
end;

procedure TGridBackgroundDataEh.SetImageVertMargin(const Value: Integer);
begin
  if FImageVertMargin <> Value then
  begin
    FImageVertMargin := Value;
    PictureChanged(Self);
  end;
end;

procedure TGridBackgroundDataEh.PictureChanged(Sender: TObject);
begin
  Grid.Invalidate;
end;

function TGridBackgroundDataEh.Showing: Boolean;
begin
  Result := Visible;
end;

function TGridBackgroundDataEh.BoundRect: TRect;
begin
  Result.Left := Grid.HorzAxis.GridClientStart;
  Result.Top := Grid.VertAxis.GridClientStart;
  Result.Right := Grid.HorzAxis.GridClientStop;
  Result.Bottom := Grid.VertAxis.GridClientStop;
end;

function TGridBackgroundDataEh.DestRect: TRect;
var
  w, h, cw, ch: Integer;
  xyAspect: Double;
begin
  w := Picture.Width;
  h := Picture.Height;
  Result := BoundRect;
  cw := Result.Right - Result.Left;
  ch := Result.Bottom - Result.Top;

  Inc(Result.Left, FImageHorzMargin);
  Inc(Result.Top, FImageVertMargin);

  case FImagePlacement of
    TImagePlacementEh.Stretch :
      begin
        w := cw;
        h := ch;
      end;

    TImagePlacementEh.Fill :
      begin
        if (w > 0) and (h > 0) then
        begin
          xyAspect := w / h;
          h := ch;
          w := Trunc(ch / xyAspect);
          if w < cw then
          begin
            w := cw;
            h := Trunc(cw * xyAspect);
          end;
        end
        else
        begin
          w := cw;
          h := ch;
        end;
      end;

    TImagePlacementEh.Fit :
      begin
        if (w > 0) and (h > 0) then
        begin
          xyAspect := w / h;
          w := cw;
          h := Trunc(cw / xyAspect);
          if h > ch then
          begin
            h := ch;
            w := Trunc(ch * xyAspect);
          end;
        end
        else
        begin
          w := cw;
          h := ch;
        end;
      end;
  end;

  Result.Right := Result.Left + w;
  Result.Bottom := Result.Top + h;

  case FImagePlacement of
    TImagePlacementEh.TopLeft :
      OffsetRect(Result, 0, 0);
    TImagePlacementEh.TopCenter :
      OffsetRect(Result, (cw - w) div 2, 0);
    TImagePlacementEh.TopRight :
      OffsetRect(Result, (cw - w), 0);

    TImagePlacementEh.CenterLeft :
      OffsetRect(Result, 0, (ch - h) div 2);
    TImagePlacementEh.CenterCenter :
      OffsetRect(Result, (cw - w) div 2, (ch - h) div 2);
    TImagePlacementEh.CenterRight :
      OffsetRect(Result, (cw - w), (ch - h) div 2);

    TImagePlacementEh.BottomLeft :
      OffsetRect(Result, 0, (ch - h));
    TImagePlacementEh.BottomCenter :
      OffsetRect(Result, (cw - w) div 2, (ch - h));
    TImagePlacementEh.BottomRight :
      OffsetRect(Result, (cw - w), (ch - h));

    TImagePlacementEh.Fill :
      begin
        if h = ch then
        begin
          Inc(Result.Left, (cw - w) div 2);
          Inc(Result.Right, (cw - w) div 2);
        end else
        begin
          Inc(Result.Top, (ch - h) div 2);
          Inc(Result.Bottom, (ch - h) div 2);
        end;
      end;

    TImagePlacementEh.Fit :
      begin
        if w = cw then
        begin
          Inc(Result.Top, (ch - h) div 2);
          Inc(Result.Bottom, (ch - h) div 2);
        end else
        begin
          Inc(Result.Left, (cw - w) div 2);
          Inc(Result.Right, (cw - w) div 2);
        end;
      end;
  end;

end;

procedure TGridBackgroundDataEh.PaintBackgroundData;
var
  Rect: TRect;
  MLeft : Integer;
  PictureRect: TRectF;
begin
  Grid.Canvas.Fill.Color := Grid.Color;
  CanvasFillRect(Grid.Canvas, RectF(0, 0, Grid.Width, Grid.Height), 1);

  try
    Rect := DestRect;
    PictureRect := RectF(0, 0, Picture.Width, Picture.Height);

    if (FImagePlacement = TImagePlacementEh.Tile) and
       (Picture.Width > 0) and
       (Picture.Height > 0) then
    begin
      MLeft := Rect.Left;
      while Rect.Top < Grid.ClientHeight do
        begin
          while Rect.Left < Grid.ClientWidth do
            begin
              Grid.Canvas.DrawBitmap(Picture, PictureRect, Rect, 1);
              OffsetRect(Rect, Picture.Width, 0);
            end;
          Rect.Left := MLeft;
          Rect.Right := Rect.Left + Picture.Width;
          OffsetRect(Rect, 0, Picture.Height);
        end;
    end
    else
      Grid.Canvas.DrawBitmap(Picture, PictureRect, Rect, 1);
  finally
  end;
end;

procedure TGridBackgroundDataEh.SetVisible(const Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    PictureChanged(Self);
  end;
end;

{ TGridDragFormEh }

constructor TGridDragFormEh.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  Transparency := True;
  FormStyle := TFormStyle.Popup;
  BorderStyle := TFmxFormBorderStyle.None;
  InitControls();
end;

procedure TGridDragFormEh.Show;
begin
  inherited Show;
end;

procedure TGridDragFormEh.MoveToFor(NewPos: TPoint);
begin
  SetBounds(NewPos.X, NewPos.Y, Width, Height);
end;

procedure TGridDragFormEh.InitControls;
begin

end;

procedure TGridDragFormEh.MoveToFor(NewPos: TPoint; NewWidth, NewHeight: Integer);
begin
  SetBounds(NewPos.X, NewPos.Y, NewWidth, NewHeight);
end;

procedure TGridDragFormEh.StartShow(Pos: TPoint; Width, Height: Integer);
begin
  SetBounds(Pos.X, Pos.Y, Width, Height);
  Show;
end;

procedure TGridDragFormEh.StartShow(Pos: TPoint; Height: Integer);
begin
  SetBounds(Pos.X, Pos.Y, Width, Height);
  Show;
end;

procedure TGridDragFormEh.TemporaryHide;
begin

end;

{$REGION 'TGridScrollBarPanelControlEh'}

{ TGridScrollBarPanelControlEh }

constructor TGridScrollBarPanelControlEh.Create(AOwner: TComponent; AKind: TOrientation);
begin
  inherited Create(AOwner);
  FKind := AKind;
  FGrid := AOwner as TCustomGridEh;

  FScrollBar := TScrollBarControlEh.Create(Self);
  FScrollBar.Parent := Self;
  FScrollBar.Orientation := FKind;
  FScrollBar.OnChange := OnScrollEvent;
  FScrollBar.TabStop := False;
{$IFDEF EH_LIB_12}
  FScrollBar.ParentDoubleBuffered := False;
{$ENDIF}

  FKeepMaxSizeInDefault := True;
  Locked := True;
end;

destructor TGridScrollBarPanelControlEh.Destroy;
begin
  inherited Destroy;
end;

function TGridScrollBarPanelControlEh.ChildControlCanMouseDown(
  AControl: TControl): Boolean;
var
  Grid: TCustomGridEhCrack;
begin
  Grid := TCustomGridEhCrack(Owner);
  Result := Grid.ChildControlCanMouseDown(AControl);
end;

function TGridScrollBarPanelControlEh.GetOnScroll: TNotifyEvent;
begin
  Result := FScrollBar.OnChange;
end;

procedure TGridScrollBarPanelControlEh.Invalidate;
var
  i: Integer;
begin
  inherited InvalidateRect(LocalRect);
  for i := 0 to Controls.Count - 1 do
    Controls[i].InvalidateRect(LocalRect);
end;

function TGridScrollBarPanelControlEh.MaxSizeForExtraPanel: Integer;
begin
  Result := Round(Width - 18 * 2);
end;

procedure TGridScrollBarPanelControlEh.OnScrollEvent(Sender: TObject);
var
  Grid: TCustomGridEhCrack;
  ScrollCode: Cardinal;
  ScrollPos: Integer;
begin
  Grid := TCustomGridEhCrack(Owner);
  ScrollCode := SB_THUMBPOSITION_EH;
  ScrollPos := Round(ScrollBar.Value);
  Grid.ScrollBarMessage(ScrollBatCode, Cardinal(ScrollCode), ScrollPos, True);
end;

function TGridScrollBarPanelControlEh.ScrollBatCode: Integer;
begin
  if FKind = TOrientation.Horizontal
    then Result := SB_HORZ_EH
    else Result := SB_VERT_EH;
end;

procedure TGridScrollBarPanelControlEh.SetKeepMaxSizeInDefault(
  const Value: Boolean);
begin
  if FKeepMaxSizeInDefault <> Value then
  begin
    FKeepMaxSizeInDefault := Value;
    Realign;
  end;
end;

procedure TGridScrollBarPanelControlEh.SetOnScroll(const Value: TNotifyEvent);
begin
  FScrollBar.OnChange := Value;
end;

procedure TGridScrollBarPanelControlEh.SetPaintColors;
begin

end;

procedure TGridScrollBarPanelControlEh.SetParams(APosition, AMin, AMax, APageSize: Integer);
begin
  FScrollBar.Enabled := True;
  if FScrollBar.ViewportSize > AMax then
    FScrollBar.ViewportSize := 0;
  if AMin > AMax then
    AMax := AMin;
  FScrollBar.Min := AMin;
  FScrollBar.Max := AMax;
  FScrollBar.Value := APosition;
  FScrollBar.SmallChange := APageSize div 5;
  FScrollBar.ViewportSize := APageSize;
  if (AMax <= AMin) or (AMax - AMin < APageSize) then
  begin
    IgnoreCancelMode := True;
    try
      FScrollBar.Enabled := False;
    finally
      IgnoreCancelMode := False;
    end;
  end;
end;

procedure TGridScrollBarPanelControlEh.VisibleChanged;
begin
  inherited VisibleChanged;
end;

procedure TGridScrollBarPanelControlEh.Resize;
begin
  inherited Resize;
end;

procedure TGridScrollBarPanelControlEh.DoRealign;
var
  NewWidth, NewHeight: Integer;
begin
  inherited DoRealign;
  if FKind = TOrientation.Horizontal then
  begin
    NewWidth := Round(Width);
    NewHeight := TCustomGridEhCrack(Owner).HorzScrollBar.ActualScrollBarBoxSize;
  end else
  begin
    NewWidth := TCustomGridEhCrack(Owner).VertScrollBar.ActualScrollBarBoxSize;
    NewHeight := Round(Height);
  end;
  FScrollBar.SetBounds(Width - NewWidth, Height - NewHeight, NewWidth, NewHeight);
end;

procedure TGridScrollBarPanelControlEh.AdjustSize;
begin
  inherited AdjustSize;
end;

procedure TGridScrollBarPanelControlEh.SetBounds(ALeft, ATop, AWidth, AHeight: Single);
begin
  if (AWidth < 0) then AWidth := 0;
  if (AHeight < 0) then AHeight := 0;
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
end;

{$ENDREGION  'TGridScrollBarPanelControlEh'}

{ TSizeGripPanelEh }

const
  PositionArr: array[TSizeGripPosition] of TCursor = (crSizeNWSE, crSizeNESW, crSizeNWSE, crSizeNESW);

constructor TSizeGripPanelEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Position := TSizeGripPosition.BottomRight;
  FMouseMousePos := Point(-1, -1);

  FSizeGrip := TSizeGripEh.Create(Self);
  FSizeGrip.Parent := Self;
  FSizeGrip.TriangleWindow := True;
  FSizeGrip.Visible := True;
  FSizeGrip.Align := TAlignLayout.Client;
end;

function TSizeGripPanelEh.CheckInCorner: Boolean;
var
  Point1, Point2: TPoint;
  NextParent: TCommonCustomForm;
begin
  Result := False;
  Point1 := LocalToScreen(PointF(Width, Height)).Round;
  NextParent := GetSizableForm;
  if NextParent <> nil then
  begin
    if (Abs(Point2.X - Point1.X) < 4) and (Abs(Point2.Y - Point1.Y) < 4) then
      Result := True;
  end;
end;

function TSizeGripPanelEh.CheckGripActive: Boolean;
begin
  if GripActiveStatus = TGripActiveStatusEh.Never then
    Result := False
  else if GripActiveStatus = TGripActiveStatusEh.Auto then
    Result := CheckInCorner
  else
    Result := True;
end;

procedure TSizeGripPanelEh.Resize;
begin
  inherited Resize;
  if CheckGripActive
    then Cursor := PositionArr[Position]
    else Cursor := crDefault;
end;

function TSizeGripPanelEh.GetSizableForm: TCommonCustomForm;
var
  Form: TCommonCustomForm;
begin
  Form := GetParentForm(Self);
  if (Form <> nil) and (Form.WindowState = TWindowState.wsNormal) then
    Result := Form
  else
    Result := nil;
end;

function TSizeGripPanelEh.GetFormSize: TPoint;
var
  NextParent: TCommonCustomForm;
begin
  Result := Point(-1, -1);
  NextParent := GetSizableForm;
  if NextParent <> nil then
    Result := NextParent.ClientToScreen(PointF(NextParent.Width, NextParent.Height)).Round;
end;

procedure TSizeGripPanelEh.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Single);
var
  NextParent: TCommonCustomForm;
  Captured: Boolean;
begin
  inherited MouseDown(Button, Shift, X, Y);

  if (Root <> nil) and (Root.Captured <> nil) and (Root.Captured.GetObject = Self) then
    Captured := True
  else
    Captured := False;

  if Captured and CheckGripActive then
  begin
    NextParent := GetSizableForm;
    if NextParent = nil then Exit;

    FInitFormSize := Point(NextParent.Width, NextParent.Height);
    FInitFormPos := Point(NextParent.Left, NextParent.Top);
    FMouseMousePos := LocalToScreen(PointF(X,Y)).Round;
  end;
end;

procedure TSizeGripPanelEh.MouseMove(Shift: TShiftState; X, Y: Single);
var
  NewMousePos: TPoint;
  NextParent: TCommonCustomForm;
  NewLeft, NewTop, NewWidth, NewHeight: Integer;
  Captured: Boolean;
begin
  inherited MouseMove(Shift, X, Y);

  if (Root <> nil) and (Root.Captured <> nil) and (Root.Captured.GetObject = Self) then
    Captured := True
  else
    Captured := False;

  if Captured and not ((FMouseMousePos.X = -1) and (FMouseMousePos.X = -1)) then
  begin
    NewMousePos := LocalToScreen(PointF(X,Y)).Round;
    if (NewMousePos.X <> FMouseMousePos.X) or (NewMousePos.Y <> FMouseMousePos.Y) then
    begin
      NextParent := GetSizableForm;
      if Position = TSizeGripPosition.TopLeft then
      begin
        NewWidth := FInitFormSize.X - (NewMousePos.X - FMouseMousePos.X);
        NewHeight := FInitFormSize.Y - (NewMousePos.Y - FMouseMousePos.Y);
        NewLeft := FInitFormPos.X + FInitFormSize.X - NewWidth;
        NewTop := FInitFormPos.Y + FInitFormSize.Y - NewHeight;
      end else if Position = TSizeGripPosition.TopRight then
      begin
        NewWidth := FInitFormSize.X + (NewMousePos.X - FMouseMousePos.X);
        NewHeight := FInitFormSize.Y - (NewMousePos.Y - FMouseMousePos.Y);
        NewLeft := FInitFormPos.X;
        NewTop := FInitFormPos.Y + FInitFormSize.Y - NewHeight;
      end else if Position = TSizeGripPosition.BottomRight then
      begin
        NewWidth := FInitFormSize.X + (NewMousePos.X - FMouseMousePos.X);
        NewHeight := FInitFormSize.Y + (NewMousePos.Y - FMouseMousePos.Y);
        NewLeft := FInitFormPos.X;
        NewTop := FInitFormPos.Y;
      end else
      begin 
        NewWidth := FInitFormSize.X - (NewMousePos.X - FMouseMousePos.X);
        NewHeight := FInitFormSize.Y + (NewMousePos.Y - FMouseMousePos.Y);
        NewLeft := FInitFormPos.X + FInitFormSize.X - NewWidth;
        NewTop := FInitFormPos.Y;
      end;

      NextParent.SetBounds(
        NewLeft,
        NewTop,
        NewWidth,
        NewHeight
      );
    end;
  end;
end;

procedure TSizeGripPanelEh.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Single);
begin
  inherited MouseUp(Button, Shift, X, Y);
  FMouseMousePos := Point(-1, -1);
end;

procedure TSizeGripPanelEh.Paint;
begin
end;

procedure TSizeGripPanelEh.SetTriangleWindow(const Value: Boolean);
begin
  if FTriangleWindow = Value then Exit;
  FTriangleWindow := Value;
  UpdateWindowRegion;
end;

procedure TSizeGripPanelEh.UpdateSizeGrip;
begin

end;

procedure TSizeGripPanelEh.UpdateWindowRegion;
begin
end;

procedure TSizeGripPanelEh.SetPosition(const Value: TSizeGripPosition);
begin
  if FPosition <> Value then
  begin
    FPosition := Value;
    UpdateWindowRegion;
  end;
end;

procedure TSizeGripPanelEh.SetBounds(ALeft, ATop, AWidth, AHeight: Single);
begin
  if (AWidth < 0) then AWidth := 0;
  if (AHeight < 0) then AHeight := 0;
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
end;

{$REGION 'TScrollBarControlEh'}

{ TScrollBarControlEh }

constructor TScrollBarControlEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDesignInteractive := True;
end;

destructor TScrollBarControlEh.Destroy;
begin
  inherited Destroy;
end;

procedure TScrollBarControlEh.SetBounds(X, Y, AWidth, AHeight: Single);
begin
  inherited SetBounds(X, Y, AWidth, AHeight);
end;

procedure TScrollBarControlEh.ApplyStyle;
begin
  inherited ApplyStyle;

  if Track <> nil then
  begin
    Track.OnMouseDown := TrackMouseDownHandler;
    Track.OnMouseUp := TrackMouseUpHandler;
    Track.ApplyStyleLookup;
    if Track.Thumb <> nil then
    begin
      Track.Thumb.OnMouseDown := TrackMouseDownHandler;
      Track.Thumb.OnMouseUp := TrackMouseUpHandler;
    end;
  end;

  ForAllChildren(
    procedure (FmxObject: TFmxObject)
    begin
      if FmxObject is TControl then
        TControlCrack(FmxObject).FDesignInteractive := True;
      if FmxObject is TStyledControl then
        TStyledControl(FmxObject).ApplyStyleLookup;
    end
  );
end;

procedure TScrollBarControlEh.TrackMouseDownHandler(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  FIsTrackMouseDown := True;
end;

procedure TScrollBarControlEh.TrackMouseUpHandler(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  FIsTrackMouseDown := False;
end;

{$ENDREGION 'TScrollBarControlEh'}

{ TGridDragWinEh }

constructor TGridDragWinEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAlphaBlendValue := 200;
  inherited Visible := False;
end;

procedure TGridDragWinEh.SetLayeredAttribs;
begin
end;

procedure TGridDragWinEh.MoveToFor(NewPos: TPoint);
begin
  SetBounds(NewPos.X, NewPos.Y, Width, Height);
end;

procedure TGridDragWinEh.MoveToFor(NewPos: TPoint; NewWidth, NewHeight: Integer);
begin
  SetBounds(NewPos.X, NewPos.Y, NewWidth, NewHeight);
end;

procedure TGridDragWinEh.StartShow(Pos: TPoint; Width, Height: Integer);
begin
  SetBounds(Pos.X, Pos.Y, Width, Height);
  inherited Visible := True;
end;

procedure TGridDragWinEh.StartShow(Pos: TPoint; Height: Integer);
begin
  StartShow(Pos, Round(Width), Round(Height));
end;

procedure TGridDragWinEh.TemporaryHide;
begin
  SetBounds(Left, Top, 0, 0);
end;

{ TGridMoveLineEh }

constructor TGridMoveLineEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 7;
  Height := 7;
  FLineColor := TAlphaColorRec.Red;
  FIsVert := True;
end;

procedure TGridMoveLineEh.StartShow(Pos: TPoint; AIsVert: Boolean; Size: Integer; ACaptureControl: TObject);
begin
  FIsVert := AIsVert;
  Pos.X := Pos.X - 4;
  Pos.Y := Pos.Y - 5;
  Size := Size + 10;
  if IsVert
    then inherited StartShow(Pos, 9, Size)
    else inherited StartShow(Pos, Size, 9)
end;

procedure TGridMoveLineEh.MoveToFor(NewPos: TPoint);
begin
  NewPos.X := NewPos.X - 4;
  NewPos.Y := NewPos.Y - 5;
  inherited MoveToFor(NewPos);
end;

procedure TGridMoveLineEh.DoPaint(const Canvas: TCanvas; const ARect: TRectF);
begin
  inherited DoPaint(Canvas, ARect);
end;

procedure TGridMoveLineEh.Realign;
begin
  inherited Realign;
  if IsVert then
  begin
    FLine.Position.Point := TPointF.Create(Width div 2, 0);
    FLine.Size.Size := TSizeF.Create(1, Height);

    FStartPointer[0].Position.Point := TPointF.Create(Width div 2 - 4, 0);
    FStartPointer[0].Size.Size := TSizeF.Create(9, 1);
    FStartPointer[1].Position.Point := TPointF.Create(Width div 2 - 3, 1);
    FStartPointer[1].Size.Size := TSizeF.Create(7, 1);
    FStartPointer[2].Position.Point := TPointF.Create(Width div 2 - 2, 2);
    FStartPointer[2].Size.Size := TSizeF.Create(5, 1);
    FStartPointer[3].Position.Point := TPointF.Create(Width div 2 - 1, 3);
    FStartPointer[3].Size.Size := TSizeF.Create(3, 1);
    FStartPointer[4].Position.Point := TPointF.Create(Width div 2, 4);
    FStartPointer[4].Size.Size := TSizeF.Create(1, 1);

    FEndPointer[0].Position.Point := TPointF.Create(Width div 2 - 4, Height - 0);
    FEndPointer[0].Size.Size := TSizeF.Create(9, 1);
    FEndPointer[1].Position.Point := TPointF.Create(Width div 2 - 3, Height - 1);
    FEndPointer[1].Size.Size := TSizeF.Create(7, 1);
    FEndPointer[2].Position.Point := TPointF.Create(Width div 2 - 2, Height - 2);
    FEndPointer[2].Size.Size := TSizeF.Create(5, 1);
    FEndPointer[3].Position.Point := TPointF.Create(Width div 2 - 1, Height - 3);
    FEndPointer[3].Size.Size := TSizeF.Create(3, 1);
    FEndPointer[4].Position.Point := TPointF.Create(Width div 2, Height - 4);
    FEndPointer[4].Size.Size := TSizeF.Create(1, 1);
  end else
  begin
    FLine.Position.Point := TPointF.Create(0, Height div 2);
    FLine.Size.Size := TSizeF.Create(Width, 1);
  end;
end;

procedure TGridMoveLineEh.InitControls;

  function CreateLine(LineColor: TAlphaColor): TLine;
  begin
    Result := TLine.Create(Self);
    Result.LineType := TLineType.Diagonal;
    Result.Stroke.Color := LineColor;
    Result.Parent := Self;
  end;

var
  I: Integer;
  ColorsService: IGridSystemColorsService;
  LineColor: TAlphaColor;
begin
  TPlatformServices.Current.SupportsPlatformService(IGridSystemColorsService, ColorsService);
  LineColor := ColorsService.GetGridBorderColor;

  FLine := CreateLine(LineColor);
  for I := 0 to Length(FStartPointer) - 1 do
    FStartPointer[I] := CreateLine(LineColor);
  for I := 0 to Length(FEndPointer) - 1 do
    FEndPointer[I] := CreateLine(LineColor);
end;

var
  FMoveLine: TGridMoveLineEh;

function GetMoveLineEh: TGridMoveLineEh;
begin
  if FMoveLine = nil then
  begin
    FMoveLine := TGridMoveLineEh.Create(Application);
  end;
  Result := FMoveLine;
end;

{ TGridSizingRectFormEh class }

class function TGridSizingRectFormEh.GetForm: TGridSizingRectFormEh;
begin
  if (FForm = nil) then
    FForm := TGridSizingRectFormEh.Create(nil);
  Result := FForm;
end;

procedure TGridSizingRectFormEhDestroy;
begin
  if (TGridSizingRectFormEh.FForm <> nil) then
    FreeAndNil(TGridSizingRectFormEh.FForm);
end;

{ TGridSizingRectFormEh }

constructor TGridSizingRectFormEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

procedure TGridSizingRectFormEh.InitControls;
var
  ColorsService: IGridSystemColorsService;
begin
  FRectBorder := TRectangle.Create(Self);
  FRectBorder.Align := TAlignLayout.Client;
  FRectBorder.Fill.Kind := TBrushKind.None;

  TPlatformServices.Current.SupportsPlatformService(IGridSystemColorsService, ColorsService);
  FRectBorder.Stroke.Color := ColorsService.GetGridBorderColor;

  FRectBorder.Parent := Self;
end;

{$REGION 'TControlBorderEh'}

constructor TControlBorderEh.Create(AGrid: TControl);
begin
  inherited Create;
  FGrid := AGrid;
  FEdgeBorders := [TControlEdgeBorder.Left, TControlEdgeBorder.Top, TControlEdgeBorder.Right, TControlEdgeBorder.Bottom];
  FColor := TAlphaColorRec.Null;
  FBorderStyle := TBorderStyle.Single;
end;

destructor TControlBorderEh.Destroy;
begin
  inherited Destroy;
end;

function TControlBorderEh.GetActualEdgeBorders: TControlEdgeBorders;
begin
  if Style = TBorderStyle.None then
    Result := []
  else
  begin
    Result := EdgeBorders;
  end;
end;

function TControlBorderEh.GetStyle: TBorderStyle;
begin
  Result := FBorderStyle;
end;

procedure TControlBorderEh.Paint(Canvas: TCanvas; BoundRect: TRect);
var
  R1: TRectF;
  ColorsService: IGridSystemColorsService;
  BorderColor: TAlphaColor;
  EdgeBorders: TControlEdgeBorders;
begin
  TPlatformServices.Current.SupportsPlatformService(IGridSystemColorsService, ColorsService);

  BorderColor := ColorsService.GetGridBorderColor;

  Canvas.Stroke.Color := BorderColor;
  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Thickness := 1;

  EdgeBorders := GetActualEdgeBorders();

  R1 := BoundRect;
  R1.Left := R1.Left + 0.5;
  R1.Right := R1.Right - 0.5;
  R1.Top := R1.Top + 0.5;
  R1.Bottom := R1.Bottom - 0.5;

  if EdgeBorders <> [] then
  begin
    if TControlEdgeBorder.Left in EdgeBorders then
      Canvas.DrawLine(R1.TopLeft, TPointF.Create(R1.Left, R1.Bottom), 1);
    if TControlEdgeBorder.Top in EdgeBorders then
      Canvas.DrawLine(R1.TopLeft, TPointF.Create(R1.Right, R1.Top), 1);
    if TControlEdgeBorder.Right in EdgeBorders then
      Canvas.DrawLine(TPointF.Create(R1.Right, R1.Top), TPointF.Create(R1.Right, R1.Bottom), 1);
    if TControlEdgeBorder.Bottom in EdgeBorders then
      Canvas.DrawLine(TPointF.Create(R1.Left, R1.Bottom), TPointF.Create(R1.Right, R1.Bottom), 1);
  end;
end;

procedure TControlBorderEh.SetStyle(const Value: TBorderStyle);
begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
    BorderChanged();
  end;
end;

procedure TControlBorderEh.SetColor(const Value: TAlphaColor);
begin
  FColor := Value;
end;

procedure TControlBorderEh.SetEdgeBorders(const Value: TControlEdgeBorders);
begin
  if FEdgeBorders <> Value then
  begin
    FEdgeBorders := Value;
    BorderChanged();
  end;
end;

procedure TControlBorderEh.BorderChanged;
begin
  TCustomGridEhCrack(FGrid).BorderChanged();
end;

{$ENDREGION 'TControlBorderEh'}

{ TGridMouseStateManageEh }

constructor TGridMouseStateManagerEh.Create(AGrid: TControl);
begin
  inherited Create();
  FGrid := AGrid;
  FNormalState := TGridMouseNormalStateEh.Create(AGrid);
  FColSizingState := TGridMouseColSizingStateEh.Create(AGrid);
  FRowSizingState := TGridMouseRowSizingStateEh.Create(AGrid);
  FColMovingState := TGridMouseColMovingStateEh.Create(AGrid);
  FRowMovingState := TGridMouseRowMovingStateEh.Create(AGrid);
  FSelectingState := TGridMouseSelectingStateEh.Create(AGrid);
end;

destructor TGridMouseStateManagerEh.Destroy;
begin
  FreeAndNil(FNormalState);
  FreeAndNil(FColSizingState);
  FreeAndNil(FRowSizingState);
  FreeAndNil(FColMovingState);
  FreeAndNil(FRowMovingState);
  FreeAndNil(FSelectingState);
  inherited Destroy;
end;

{ TBaseGridMouseStateEh }

constructor TBaseGridMouseStateEh.Create(AGrid: TControl);
begin
  FGrid := AGrid;
end;

procedure TBaseGridMouseStateEh.Init(AExtraData: TObject);
begin
  FExtraData := AExtraData;
end;

procedure TBaseGridMouseStateEh.Release;
begin
  FreeAndNil(FExtraData);
end;

{ TGridMouseNormalStateEh }

{ TSimpleCheckBoxEh }

procedure TSimpleCheckBoxEh.ApplyStyle;
var
  TextControl: TControl;
  RootStyleControl: TControl;
  FirstLayout: TLayout;
begin
  inherited ApplyStyle;

  if FindStyleResource<TControl>('text', TextControl) then 
  begin
    TextControl.Visible := False;
  end;

  RootStyleControl := GetResourceLink as TControl;
  if (RootStyleControl <> nil) and (RootStyleControl.ChildrenCount > 0) then
  begin
    FirstLayout := RootStyleControl.Children[0] as TLayout;
    if FirstLayout <> nil then
      FirstLayout.Align := TAlignLayout.Center;
  end;

//  Size.DefaultValue := Size.Size;
end;

constructor TSimpleCheckBoxEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TSimpleCheckBoxEh.Destroy;
begin
  inherited Destroy;
end;

procedure TSimpleCheckBoxEh.Resize;
begin
  inherited Resize;
end;

{ TGridMouseColMovingStateEh }

destructor TGridMouseColMovingStateEh.Destroy;
begin
  inherited Destroy;
end;

constructor TGridMouseColMovingStateEh.Init(AGrid: TControl; AColIndex,
  ARowIndex: Integer; AScreenPos: TPointF; AExtraData: TObject);
var
  VGrid: TCustomGridEhCrack;
  CellHit: TGridCoord;
  R: TRect;
  InGridPos: TPointF;
  InCellX: Integer;

  function SkipHiddenCells(AIndex: Integer): Integer;
  var
    i: Integer;
  begin
    Result := 0;
    for i := AIndex to VGrid.ColCount-1  do
    begin
      if VGrid.ColWidths[i] > 0 then Exit;
      Inc(Result);
    end;
  end;

begin
  FGrid := AGrid;
  VGrid := TCustomGridEhCrack(Grid);

  FMoveFromIndex := AColIndex;

  InGridPos := VGrid.ScreenToLocal(AScreenPos);

  CellHit := VGrid.MouseCoord(InGridPos.X, InGridPos.Y);
  R := VGrid.CellRect(CellHit.X, 0);
  InCellX := Round(InGridPos.X) - R.Left;
  R.Offset(-R.Left, -R.Top);

  if (VGrid.UseRightToLeftAlignment) then
  begin
    if (InCellX > R.Left + RectWidth(R) / 2) then
      FMoveToIndex := CellHit.X
    else
      FMoveToIndex := CellHit.X + 1;
  end
  else
  begin
    if (InCellX < R.Left + RectWidth(R) / 2) then
      FMoveToIndex := CellHit.X
    else
      FMoveToIndex := CellHit.X + 1;
  end;

  FMoveFromCellOriginDistance := InCellX - R.Left;
  FMovePosRightSite := False;

  inherited Init(AExtraData);
end;

procedure TGridMouseColMovingStateEh.SetMoveToIndex(const Value: Integer);
begin
  if FMoveToIndex <> Value then
    FMoveToIndex := Value;
end;

{ TGridMouseRowMovingStateEh }

destructor TGridMouseRowMovingStateEh.Destroy;
begin
  inherited Destroy;
end;

procedure TGridMouseRowMovingStateEh.Init(AGrid: TControl; AMoveFromIndex: Integer;
  AMoveToIndex: Integer; AMousePos: TPoint; AExtraData: TObject);
begin
  FGrid := AGrid;
  FMoveFromIndex := AMoveFromIndex;
  FMoveToIndex := AMoveToIndex;
  FInitMousePos := AMousePos;
  inherited Init(AExtraData);
end;

initialization
finalization
  TGridSizingRectFormEhDestroy;
end.
