{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{                EhLibFmx.ToolControls                  }
{                                                       }
{      Copyright (c) 2024-2025 by Dmitry V. Bolshakov   }
{                                                       }
{*******************************************************}

{$I ..\Incl\EhLib.Inc}
{$SCOPEDENUMS ON}

unit EhLibFmx.ToolControls;

interface

{$REGION 'uses'}
uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, System.Types,
  System.TypInfo, System.Messaging, System.UIConsts,
  Data.DB, Variants, System.Rtti,
  Data.DBConsts, System.RTLConsts, System.UITypes, System.Contnrs,
  System.Generics.Collections, DynVarsEh, FMX.Layouts,
  FMX.Objects,
  FMX.Graphics,
  FMX.StdCtrls,
  FMX.Menus,
  FMX.Forms, FMX.Styles,
  FMX.Controls.Presentation,
  FMX.Platform,
  EhLibUtils, DBUtilsEh,
  EhLibFmx.Utils,
  EhLibFmx.Platform,
  EhLibFmx.ImageReses,
  EhLibFmx.Types;
{$ENDREGION 'uses'}

const
  { Scroll Bar Constants }
  SB_HORZ_EH = 0;
  SB_VERT_EH = 1;

  { Scroll Bar Commands }
  SB_LINEUP_EH = 0;
  SB_LINEDOWN_EH = 1;
  SB_PAGEUP_EH = 2;
  SB_PAGEDOWN_EH = 3;
  SB_THUMBPOSITION_EH = 4;
  SB_THUMBTRACK_EH = 5;
  SB_TOP_EH = 6;
  SB_BOTTOM_EH = 7;

  InitRepeatPause = 400;  { pause before repeat timer (ms) }
  RepeatPause     = 100;  { pause before hint window displays (ms)}

type

  TDropDownFormSysParams = class;
  TControlMouseParamsEh = class;
  TControlMouseButtonParamsEh = class;
  TStyledControlEh = class;

  TAggrFunctionEh = (Sum, Count, Avg, Min, Max);
  TAggrFunctionsEh = set of TAggrFunctionEh;
  TAggrResultArr = array [TAggrFunctionEh] of TValue;

  TDropDownAlign = (Left, Right, Center);
  TDropLayoutEh = (AboveControl, UnderControl);
  TGrayAlgorithm = (AlgNone, AlgLuminosity, AlgAverage, AlgLightness);

  TDropDownFormCallbackProcEh = procedure(DropDownForm: TCustomForm;
    Accept: Boolean; DynParams: TDynVarsEh; SysParams: TDropDownFormSysParams) of object;

  TFmxObjectActionProcedure = reference to procedure(FmxObject: TFmxObject);

  TControlMouseEventEh = procedure(Sender: TObject; Params: TControlMouseParamsEh) of object;
  TControlMouseButtonEventEh = procedure(Sender: TObject; Params: TControlMouseButtonParamsEh) of object;

{ IDropDownFormEh }

  IDropDownFormEh = interface
    ['{A665F4AE-003C-465E-95E9-B1061E9EAEF4}']
    function Execute(RelativePosControl: TControl; DownStateControl: TControl; Align: TDropDownAlign; DynParams: TDynVarsEh): Boolean;
    function GetReadOnly: Boolean;
    procedure ExecuteNoModal(ParentControl: TControl; RelativePosRect: TRect; DownStateControl: TControl; Align: TDropDownAlign; DynParams: TDynVarsEh; SysParams: TDropDownFormSysParams; CallbackProc: TDropDownFormCallbackProcEh);
    procedure Close;
    procedure SetReadOnly(const Value: Boolean);

    property ReadOnly: Boolean read GetReadOnly write SetReadOnly;
  end;

{ TInterfacedBitmapEh }

  TInterfacedBitmapEh = class(TInterfacedObject, IBitmapObject)
  private
    FBitmap: TBitmap;
  protected
    function GetBitmap: TBitmap;
    procedure AddFreeNotify(const AObject: IFreeNotification);
    procedure RemoveFreeNotify(const AObject: IFreeNotification);
  public
    constructor Create();
    destructor Destroy(); override;

    property Bitmap: TBitmap read GetBitmap;
  end;

{ TFormEh }

  TFormEh = class(TForm)
  private
    FDesignBacklightObject: TFmxObject;

    procedure PaintDesignBacklightObject(const Canvas: TCanvas);
    procedure SetDesignBacklightObject(const Value: TFmxObject);
    procedure SetFormViewer(const Value: TForm);

  protected
    FFormViewer: TForm;

    procedure DoPaint(const Canvas: TCanvas; const ARect: TRectF); override;
    procedure PaintRects(const UpdateRects: array of TRectF); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure KeyDown(var Key: Word; var KeyChar: System.WideChar; Shift: TShiftState); override;

    property DesignBacklightObject: TFmxObject read FDesignBacklightObject write SetDesignBacklightObject;
    property FormViewer: TForm read FFormViewer write SetFormViewer;
  end;

{ TControlParamsEh }

  TControlParamsEh = class(TPersistent)
  private
    FOriginalObject: TControl;
    FHandled: Boolean;
  public
    procedure Init(AOriginalObject: TControl);

    property OriginalObject: TControl read FOriginalObject write FOriginalObject;
    property Handled: Boolean read FHandled write FHandled;
  end;

{ TControlMouseParamsEh }

  TControlMouseParamsEh = class(TPersistent)
  private
    FShift: TShiftState;
    FX: Single;
    FY: Single;
    FOriginalObject: TControl;
    FHandled: Boolean;
  public
    procedure Init(AX, AY: Single; AShift: TShiftState; AOriginalObject: TControl);

    property X: Single read FX;
    property Y: Single read FY;
    property Shift: TShiftState read FShift;

    property OriginalObject: TControl read FOriginalObject write FOriginalObject;
    property Handled: Boolean read FHandled write FHandled;

    function GetPositionRelativeTo(AObject: TControl): TPointF;
  end;

{ TControlMouseButtonParamsEh }

  TControlMouseButtonParamsEh = class(TControlMouseParamsEh)
  private
    FButton: TMouseButton;
  public
    procedure Init(AButton: TMouseButton; AX, AY: Single; AShift: TShiftState; AOriginalObject: TControl);

    property Button: TMouseButton read FButton;
  end;

{ TControlShowContextMenuParamsEh }

  TControlShowContextMenuParamsEh = class(TPersistent)
  private
    FScreenPosition: TPoint;
    FOriginalObject: TControl;
    FHandled: Boolean;
  public
    procedure Init(const AScreenPosition: TPointF; AOriginalObject: TControl);

    property ScreenPosition: TPoint read FScreenPosition;
    property OriginalObject: TControl read FOriginalObject write FOriginalObject;
    property Handled: Boolean read FHandled write FHandled;
  end;

{ TTestComponent }

  TTestComponent = class(TComponent)
  private
    FCheckedValue: Variant;
    function GetCheckedValue: Variant;
    function IsCheckedValueStored: Boolean;
    procedure SetCheckedValue(const Value: Variant);
    procedure CheckedValueChanged();
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;


  published
    property CheckedValue: Variant read GetCheckedValue write SetCheckedValue stored IsCheckedValueStored;
  end;

{ TStyledControlEh }

  TStyledControlEh = class(TStyledControl)
  private
    FBeforeFirstDrawingDone: Boolean;
    function GetIsLoading: Boolean;
  protected
    function GetStyleObject(const Clone: Boolean): TFmxObject; override;

    procedure ApplyStyle; override;

    function GetStyleResourceName(): String; virtual;

    procedure DoBeforeFirstDrawing; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Capture;
    procedure ReleaseCapture;
    procedure ApplyStyleLookup; override;

    function IsMouseCaptured: Boolean;
    function GetStyleResource<T: TFmxObject>(const AStyleLookup: string): T;
    function FindNestedStyleResource(const AStyleLookupPath: string; const Clone: Boolean = False): TFmxObject;

    procedure PrepareForPaint; override;

    property IsLoading: Boolean read GetIsLoading;

    procedure Invalidate;
  published
    property StyleLookup;
    property Align;
    property Visible;
  end;

{ TMyTestGridControl }

  TMyTestGridControl = class(TStyledControlEh)
  private
  protected
    procedure Paint; override;
    procedure ApplyStyle; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ApplyStyleLookup; override;
  published
    property Position;
    property Size;
    property StyleLookup;
  end;

{ TObjectListEh }

  TObjectListEh = class(TObjectList)
  public
    constructor Create; overload;
    constructor Create(AOwnsObjects: Boolean); overload;

    procedure Sort(Compare: TListSortCompare);
  end;

{ TReadonlyList }

  TListItemProcedure<T> = reference to procedure(const Value: T);

  TReadonlyList<T> = class(TEnumerable<T>)
  private
    FList: TList<T>;
    function GetCount: Integer;
    function GetItem(Index: Integer): T;

  protected
    function DoGetEnumerator: TEnumerator<T>; override;

    property BaseList: TList<T> read FList;
  public
    constructor Create(AList: TList<T>);

    function IndexOf(const Value: T): Integer;

    procedure ForAll(ItemMethod: TListItemProcedure<T>);

    property Count: Integer read GetCount;
    property Items[Index: Integer]: T read GetItem; default;
  end;

{ TSizeGripEh }

  TSizeGripPosition = (TopLeft, TopRight, BottomRight, BottomLeft);
  TSizeGripChangePosition = (ToLeft, ToRight, ToTop, ToBottom);

  TSizeGripEh = class(TControl)
  private
    FInitScreenMousePos: TPointF;
    FInternalMove: Boolean;
    FOldMouseMovePos: TPointF;
    FParentRect: TRectF;
    FParentResized: TNotifyEvent;
    FPosition: TSizeGripPosition;
    FTriangleWindow: Boolean;
    FSizeGripPainter: TSizeGrip;

    function GetHostControl: TCommonCustomForm;
    procedure SetPosition(const Value: TSizeGripPosition);
    procedure SetTriangleWindow(const Value: Boolean);
    function GetMouseCaptured: Boolean;

    {$IFDEF FPC}
    procedure SetVisible(const Value: Boolean); reintroduce;
    {$ELSE}
    {$ENDIF}

  protected
    function CheckHitTest(const AHitTest: Boolean): Boolean; override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure Paint; override;
    procedure ParentResized; virtual;

    procedure UpdateCursor; virtual;

  public
    constructor Create(AOwner: TComponent); override;

    function PointInObjectLocal(X, Y: Single): Boolean; override;

    procedure ChangePosition(NewPosition: TSizeGripChangePosition);
    procedure UpdatePosition;
    procedure UpdateWindowRegion;

    property HostControl: TCommonCustomForm read GetHostControl;
    property Position: TSizeGripPosition read FPosition write SetPosition default TSizeGripPosition.BottomRight;
    property TriangleWindow: Boolean read FTriangleWindow write SetTriangleWindow default True;
    property MouseCaptured: Boolean read GetMouseCaptured;

    property OnParentResized: TNotifyEvent read FParentResized write FParentResized;
  end;

  TButtonDownEventEh = procedure(Sender: TObject;
    var AutoRepeat: Boolean; var Handled: Boolean) of object;

{ TCustomSpeedButtonEh }

  TCustomSpeedButtonEh = class(TSpeedButton)
  private
    FAutoRepeat: Boolean;
    FRepeatTimer: TTimer;
    FOnDown: TButtonDownEventEh;
    FResourceImageItem: TResourceImageItemEh;
    FImage: TImage;

    procedure TimerExpired(Sender: TObject);
    procedure ResetTimer(Interval: Cardinal);
    function GetImage: TImage;
    procedure SetResourceImageItem(const Value: TResourceImageItemEh);
  protected
    function GetDefaultStyleLookupName: string; override;
    procedure ApplyStyle; override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure ButtonDown(var AutoRepeat: Boolean); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Invalidate;

    property ResourceImageItem: TResourceImageItemEh read FResourceImageItem write SetResourceImageItem;
    property Image: TImage read GetImage;
    property AutoRepeat: Boolean read FAutoRepeat write FAutoRepeat;
    property OnDown: TButtonDownEventEh read FOnDown write FOnDown;
  end;

{ TBackstageButtonEh }

  TBackstageButtonEh = class(TButton)
  protected
    FIsMouseOver: Boolean;
  private
  protected
    function GetStyleObject(const Clone: Boolean): TFmxObject; override;
    procedure ReadState(Reader: TReader); override;
    procedure ApplyStyle; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetMouseOver(AIsMouseOver: Boolean);
  end;

{ TMenuFaceButtonEh }

  TMenuFaceButtonEh = class(TButton, IItemsContainer)
  private
    FMenuItemFace: TMenuItem;
    procedure SetText(const Value: String); reintroduce;
    function GetText: String;
  protected
    procedure DoRealign; override;
    procedure ApplyStyle; override;
    procedure DoMouseEnter; override;
    procedure DoMouseLeave; override;
    procedure DoEnter; override;
    procedure DoExit; override;

    { IItemsContainer }
    function GetItemsCount: Integer;
    function GetItem(const AIndex: Integer): TFmxObject;
    { }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ApplyStyleLookup; override;

  published
    property Text: String read GetText write SetText;
  end;

{ TDropDownFormSysParams }

  TDropDownFormSysParams = class(TPersistent)
  private
    FFreeFormOnClose: Boolean;
  public
    property FreeFormOnClose: Boolean read FFreeFormOnClose write FFreeFormOnClose;
  end;

{ TEditControlDropDownFormSysParams }

  TEditControlDropDownFormSysParams = class(TDropDownFormSysParams)
  public
    FEditControl: TControl;
    FEditButton: TControl;
    FEditButtonObj: TObject;
  end;

{ TSeparatorMenuItem }

  TSeparatorMenuItem = class(TMenuItem)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

{ TComposedPopupMenu }

  TComposedPopupMenu = class(TPopupMenu)
  private
    FComposedMenuClients: TDictionary<TCustomPopupMenu, TList<TMenuItem>>;
    FPrepared: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddItem(AMenuItem: TMenuItem);
    procedure AddItemsFromMenu(APopupMenu: TCustomPopupMenu);
    procedure PrepareComposedMenu;
    procedure ReleaseComposedMenu;
    procedure ClearItems;

    function GetSeparator: TMenuItem;
    function IsReleased: Boolean;
  end;

{ TContextMenuManage }

  TContextMenuManageEh = class(TPersistent)
  private
    class var FGlobalContextMenu: TComposedPopupMenu;
  public
    class function GetGlobalContextMenu(): TComposedPopupMenu;
    class procedure ReleaseGlobalContextMenu(AGlobalContextMenu: TComposedPopupMenu);
  end;

{ TFmxObjectHelper }

  TFmxObjectHelper = class helper for TFmxObject
  private
    function GetRefSelf: TFmxObject;
  public
    procedure ForAllChildren(ChildActionProcedure: TFmxObjectActionProcedure);
    function CloneWithChildren(const AOwner: TComponent): TFmxObject;
  public
    property RefSelf: TFmxObject read GetRefSelf;
  end;

  TFmxObjectFactory<T: TFmxObject> = class
  public
    class function CreateWithParent(AParent: TFmxObject): T; static;
  end;

{ TOneShotTimer }

  TOneShotTimer = class(TTimer)
  protected
    FThreadProc: TThreadProcedure;

    procedure OnTimerHandler(Sender: TObject);
  public
    constructor Create(AInterval: Cardinal; const AThreadProc: TThreadProcedure); reintroduce;
    procedure Start;
  end;

implementation

{$REGION 'uses'}
uses System.Math.Vectors,
     FMX.Utils,
     EhLibFmx.FormElementsViewer,
     EhLibFmx.ObjectInspectors,
     EhLibFmx.Styles,
     System.Math;
{$ENDREGION 'uses'}

type
  TControlCrack = class(TControl);
  TFmxObjectCrack = class(TFmxObject);

{$REGION 'InitFinalUnit'}

procedure InitModule;
begin
  RegisterClass(TBackstageButtonEh);
  RegisterClass(TMenuFaceButtonEh);
  RegisterClass(TStyledControlEh);
end;

procedure FinalizeModule;
begin
  FreeAndNil(TContextMenuManageEh.FGlobalContextMenu);
end;

{$ENDREGION 'InitFinalUnit'}

{$REGION 'TInterfacedBitmapEh'}

{ TInterfacedBitmapEh }

constructor TInterfacedBitmapEh.Create;
begin
  FBitmap := TBitmap.Create;
end;

destructor TInterfacedBitmapEh.Destroy;
begin
  FreeAndNil(FBitmap);
  inherited Destroy;
end;

function TInterfacedBitmapEh.GetBitmap: TBitmap;
begin
  Result := FBitmap;
end;

procedure TInterfacedBitmapEh.RemoveFreeNotify(const AObject: IFreeNotification);
begin

end;

procedure TInterfacedBitmapEh.AddFreeNotify(const AObject: IFreeNotification);
begin

end;

{$ENDREGION 'TInterfacedBitmapEh'}

{$REGION 'TObjectListEh'}

{ TObjectListEh }

constructor TObjectListEh.Create;
begin
  inherited Create(False);
end;

constructor TObjectListEh.Create(AOwnsObjects: Boolean);
begin
  inherited Create(AOwnsObjects);
end;

procedure TObjectListEh.Sort(Compare: TListSortCompare);
begin
  inherited Sort(Compare);
end;

{$ENDREGION 'TObjectListEh'}

{$REGION 'TReadonlyList<T>'}

{ TReadonlyList<T> }

constructor TReadonlyList<T>.Create(AList: TList<T>);
begin
  inherited Create;
  FList := AList;
end;

function TReadonlyList<T>.DoGetEnumerator: TEnumerator<T>;
begin
  Result := FList.GetEnumerator();
end;

function TReadonlyList<T>.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TReadonlyList<T>.GetItem(Index: Integer): T;
begin
  Result := FList[Index];
end;

function TReadonlyList<T>.IndexOf(const Value: T): Integer;
begin
  Result := FList.IndexOf(Value);
end;

procedure TReadonlyList<T>.ForAll(ItemMethod: TListItemProcedure<T>);
begin
  for var Item in FList do
    ItemMethod(Item);
end;

{$ENDREGION 'TReadonlyList<T>'}

{$REGION 'TSizeGripEh'}

{ TSizeGripEh }

constructor TSizeGripEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 16;
  Height := 16;
  Cursor := crSizeNWSE;
  FTriangleWindow := True;
  FPosition := TSizeGripPosition.BottomRight;
  AutoCapture := True;

  FSizeGripPainter := TSizeGrip.Create(Self);
  FSizeGripPainter.Parent := Self;
//  FSizeGripPainter.Visible := False;
  FSizeGripPainter.HitTest := False;
//  FSizeGripPainter.Size.Size := TSizeF.Create(16, 16);
  FSizeGripPainter.Align := TAlignLayout.Client;
end;

function TSizeGripEh.CheckHitTest(const AHitTest: Boolean): Boolean;
begin
  Result := inherited CheckHitTest(AHitTest);
end;

procedure TSizeGripEh.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited MouseDown(Button, Shift, X, Y);
  FInitScreenMousePos := ControlClientToScreen(Self, PointF(X, Y));
  FParentRect.Right := HostControl.Width;
  FParentRect.Bottom := HostControl.Height;
  FParentRect.Left := HostControl.Width;
  FParentRect.Top := HostControl.Height;
end;

procedure TSizeGripEh.MouseMove(Shift: TShiftState; X, Y: Single);
var
  NewMousePos, ParentWidthHeight: TPointF;
  OldPos, NewClientAmount, OutDelta: Single;
  WorkArea: TRectF;
  MasterAbsRect: TRectF;
begin
  inherited MouseMove(Shift, X, Y);

  if (ssLeft in Shift) and
     (MouseCaptured = True) and
     (FInternalMove = False) then
  begin
    NewMousePos := ControlClientToScreen(Self, PointF(X, Y));
    ParentWidthHeight.x := HostControl.Width;
    ParentWidthHeight.y := HostControl.Height;

    if (FOldMouseMovePos.x = NewMousePos.x) and
      (FOldMouseMovePos.y = NewMousePos.y) then
      Exit;

    MasterAbsRect.TopLeft := HostControl.ClientToScreen(PointF(0, 0));
    MasterAbsRect.Bottom := MasterAbsRect.Top + HostControl.Height;
    MasterAbsRect.Right := MasterAbsRect.Left + HostControl.Width;

    WorkArea := TRectF.Create(Screen.DisplayFromRect(MasterAbsRect).Workarea);

    if Position in [TSizeGripPosition.BottomRight, TSizeGripPosition.TopRight] then
    begin
      NewClientAmount := FParentRect.Left + NewMousePos.x - FInitScreenMousePos.x;
      OutDelta := HostControl.Width + NewClientAmount - HostControl.Width;
      OutDelta := HostControl.ClientToScreen(PointF(OutDelta, 0)).x - WorkArea.Right;
      if OutDelta <= 0
        then HostControl.Width := Round(NewClientAmount)
        else HostControl.Width := Round(NewClientAmount - OutDelta)
    end else
    begin
      OldPos := HostControl.Width;

      NewClientAmount := FParentRect.Right + FInitScreenMousePos.x - NewMousePos.x;
      OutDelta := NewClientAmount - HostControl.Width;
      OutDelta := HostControl.ClientToScreen(Point(0, 0)).x - WorkArea.Left - OutDelta;
      if OutDelta >= 0
        then HostControl.Width := Round(NewClientAmount)
        else HostControl.Width := Round(NewClientAmount + OutDelta);
      HostControl.Left := Round(HostControl.Left + OldPos - HostControl.Width);
    end;

    if Position in [TSizeGripPosition.BottomRight, TSizeGripPosition.BottomLeft] then
    begin
      NewClientAmount := FParentRect.Top + NewMousePos.y - FInitScreenMousePos.y;
      OutDelta := HostControl.Height + NewClientAmount - HostControl.Height;
      OutDelta := HostControl.ClientToScreen(PointF(0, OutDelta)).y - WorkArea.Bottom;
      if OutDelta <= 0
        then HostControl.Height := Round(NewClientAmount)
        else HostControl.Height := Round(NewClientAmount - OutDelta);
    end else
    begin
      OldPos := HostControl.Height;
      NewClientAmount := FParentRect.Bottom + FInitScreenMousePos.y - NewMousePos.y;
      OutDelta := NewClientAmount - HostControl.Height;
      OutDelta := HostControl.ClientToScreen(Point(0, 0)).y - WorkArea.Top - OutDelta;
      if OutDelta >= 0
        then HostControl.Height := Round(NewClientAmount)
        else HostControl.Height := Round(NewClientAmount + OutDelta);
      HostControl.Top := Round(HostControl.Top + OldPos - HostControl.Height);
    end;

    FOldMouseMovePos := NewMousePos;
    if (ParentWidthHeight.x <> HostControl.Width) or
      (ParentWidthHeight.y <> HostControl.Height) then
      ParentResized;
    UpdatePosition;
  end;
end;

procedure TSizeGripEh.Paint;
begin
//  ControlPaintTo(FSizeGripPainter, Canvas, TRectF.Create(0, 0, 15, 15), Self);
end;

procedure TSizeGripEh.ParentResized;
begin
  if Assigned(FParentResized) then FParentResized(Self);
end;

function TSizeGripEh.PointInObjectLocal(X, Y: Single): Boolean;
begin
  Result := inherited PointInObjectLocal(X, Y);
  if (Result = True) and
     (TriangleWindow = True) then
  begin
    if Width - X > Y then
      Result := False;
  end;
end;

procedure TSizeGripEh.SetPosition(const Value: TSizeGripPosition);
begin
  if FPosition = Value then Exit;
  FPosition := Value;
  UpdateCursor;
  UpdatePosition;
end;

procedure TSizeGripEh.SetTriangleWindow(const Value: Boolean);
begin
  if FTriangleWindow = Value then Exit;
  FTriangleWindow := Value;
  UpdateWindowRegion;
end;

function GetAdjustedClientRect(AForm: TCommonCustomForm): TRectF;
begin
  Result := RectF(0, 0, AForm.Width, AForm.Height);
end;

procedure TSizeGripEh.UpdatePosition;
var
  HostCliRect: TRectF;
begin
  FInternalMove := True;
  HostCliRect := GetAdjustedClientRect(HostControl);
  case Position of
    TSizeGripPosition.BottomRight:
      begin
        SetBounds(HostCliRect.Right - Width, HostCliRect.Bottom - Height, Width, Height);
        RotationAngle := 0;
      end;
    TSizeGripPosition.BottomLeft:
      begin
        SetBounds(HostCliRect.Left, HostCliRect.Bottom - Height, Width, Height);
        RotationAngle := 90;
      end;
    TSizeGripPosition.TopLeft:
      begin
        SetBounds(HostCliRect.Left, HostCliRect.Top, Width, Height);
        RotationAngle := 180;
      end;
    TSizeGripPosition.TopRight:
      begin
        SetBounds(HostCliRect.Right - Width, HostCliRect.Top, Width, Height);
        RotationAngle := -90;
      end;
  end;
  FInternalMove := False;
end;

procedure TSizeGripEh.ChangePosition(NewPosition: TSizeGripChangePosition);
begin
  if NewPosition = TSizeGripChangePosition.ToLeft then
  begin
    if Position = TSizeGripPosition.TopRight then Position := TSizeGripPosition.TopLeft
    else if Position = TSizeGripPosition.BottomRight then Position := TSizeGripPosition.BottomLeft;
  end else if NewPosition = TSizeGripChangePosition.ToRight then
  begin
    if Position = TSizeGripPosition.TopLeft then Position := TSizeGripPosition.TopRight
    else if Position = TSizeGripPosition.BottomLeft then Position := TSizeGripPosition.BottomRight
  end else if NewPosition = TSizeGripChangePosition.ToTop then
  begin
    if Position = TSizeGripPosition.BottomRight then Position := TSizeGripPosition.TopRight
    else if Position = TSizeGripPosition.BottomLeft then Position := TSizeGripPosition.TopLeft
  end else if NewPosition = TSizeGripChangePosition.ToBottom then
  begin
    if Position = TSizeGripPosition.TopRight then Position := TSizeGripPosition.BottomRight
    else if Position = TSizeGripPosition.TopLeft then Position := TSizeGripPosition.BottomLeft
  end
end;

procedure TSizeGripEh.UpdateCursor;
const
  PositionArr: array[TSizeGripPosition] of TCursor = (crSizeNWSE, crSizeNESW, crSizeNWSE, crSizeNESW);
begin
  Cursor := PositionArr[Position];
end;

procedure TSizeGripEh.UpdateWindowRegion;
begin
end;

function TSizeGripEh.GetHostControl: TCommonCustomForm;
begin
  Result := GetParentForm(Self);
end;

function TSizeGripEh.GetMouseCaptured: Boolean;
begin
  if (Root <> nil) and (Root.Captured <> nil) and (Root.Captured.GetObject = Self) then
    Result := True
  else
    Result := False;
end;

{$ENDREGION 'TSizeGripEh'}

{$REGION 'TCustomSpeedButtonEh'}

{TCustomSpeedButtonEh}

constructor TCustomSpeedButtonEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FImage := TImage.Create(nil);
  FImage.Align := TAlignLayout.Client;
  FImage.HitTest := False;
  FImage.Locked := True;
  FImage.WrapMode := TImageWrapMode.Center;
  AddObject(FImage);
end;

destructor TCustomSpeedButtonEh.Destroy;
begin
  FreeAndNil(FRepeatTimer);
  FreeAndNil(FImage);
  inherited Destroy;
end;

function TCustomSpeedButtonEh.GetDefaultStyleLookupName: string;
begin
  Result := 'SpeedButtonStyle';
end;

procedure TCustomSpeedButtonEh.ApplyStyle;
var
  OldHeight: Single;
begin
  OldHeight := Height;
  inherited ApplyStyle;
  SetAdjustType(TAdjustType.None);
  Height := OldHeight;
end;

procedure TCustomSpeedButtonEh.Invalidate;
begin
  ControlInvalidate(Self);
end;

procedure TCustomSpeedButtonEh.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  AAutoRepeat: Boolean;
begin
  inherited MouseDown (Button, Shift, X, Y);

  if (Button = TMouseButton.mbLeft) and Enabled then
  begin
    AAutoRepeat := AutoRepeat;
    ButtonDown(AAutoRepeat);
    if AAutoRepeat then
      ResetTimer(InitRepeatPause);
  end;

  if AutoRepeat then
  begin
  end;
end;

procedure TCustomSpeedButtonEh.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited MouseUp(Button, Shift, X, Y);

  if FRepeatTimer <> nil then
    FRepeatTimer.Enabled  := False;
end;

procedure TCustomSpeedButtonEh.ButtonDown(var AutoRepeat: Boolean);
var
  Handled: Boolean;
begin
  if Assigned(FOnDown) {and (FButtonNum > 0)} then
    FOnDown(Self, AutoRepeat, Handled);
end;

procedure TCustomSpeedButtonEh.ResetTimer(Interval: Cardinal);
begin
  if FRepeatTimer = nil then
  begin
    FRepeatTimer := TTimer.Create(Self);
    FRepeatTimer.OnTimer := TimerExpired;
  end;

  if FRepeatTimer.Enabled = False then
  begin
    FRepeatTimer.Interval := Interval;
    FRepeatTimer.Enabled := True;
  end
  else if Interval <> FRepeatTimer.Interval then
  begin
    FRepeatTimer.Enabled := False;
    FRepeatTimer.Interval := Interval;
    FRepeatTimer.Enabled := True;
  end;
end;

procedure TCustomSpeedButtonEh.TimerExpired(Sender: TObject);
var
  AAutoRepeat: Boolean;
begin
  FRepeatTimer.Interval := RepeatPause;
  if (IsPressed =	True) then
  begin
    try
      AAutoRepeat := AutoRepeat;
      ButtonDown(AAutoRepeat);
      if not AutoRepeat then
        FRepeatTimer.Enabled := False;
    except
      FRepeatTimer.Enabled := False;
      raise;
    end;
  end;
end;

function TCustomSpeedButtonEh.GetImage: TImage;
begin
  Result := FImage;
end;

procedure TCustomSpeedButtonEh.SetResourceImageItem(
  const Value: TResourceImageItemEh);
begin
  FResourceImageItem := Value;
  if FResourceImageItem <> nil then
    FImage.Bitmap := FResourceImageItem.GetGraphic(TSize.Create(0, 0), 1, False, False)
  else
    FImage.Bitmap := nil;
end;

{$ENDREGION 'TCustomSpeedButtonEh'}

{$REGION 'TStyledControlEh'}

{ TStyledControlEh }

constructor TStyledControlEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TStyledControlEh.Destroy;
begin
  inherited Destroy;
end;

procedure TStyledControlEh.PrepareForPaint;
begin
  inherited PrepareForPaint;
end;

procedure TStyledControlEh.Invalidate;
begin
  ControlInvalidate(Self);
end;

function TStyledControlEh.GetIsLoading: Boolean;
begin
  Result := csLoading in ComponentState;
end;

function TStyledControlEh.GetStyleResourceName(): String;
var
  StyleResourceService: IStyleResourceService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IStyleResourceService, StyleResourceService) then
  begin
    Result := StyleResourceService.GetStyleResource();
  end else
  begin
    Result := '';
  end;
end;

function TStyledControlEh.IsMouseCaptured: Boolean;
begin
  if (Root <> nil) and
     (Root.Captured <> nil) and
     (Root.Captured.GetObject = Self)
  then
    Result := True
  else
    Result := False;
end;

procedure TStyledControlEh.DoBeforeFirstDrawing;
begin
end;

function TStyledControlEh.GetStyleObject(const Clone: Boolean): TFmxObject;
begin
  TStyleManagerEh.CheckApplyEhLibStyles();
  Result := inherited GetStyleObject(Clone);
end;

procedure TStyledControlEh.ApplyStyle;
begin
  inherited ApplyStyle;
  if FBeforeFirstDrawingDone = False then
  begin
    DoBeforeFirstDrawing;
    FBeforeFirstDrawingDone := True;
  end;
end;

procedure TStyledControlEh.ApplyStyleLookup;
begin
  inherited ApplyStyleLookup;
end;

procedure TStyledControlEh.Capture;
begin
  inherited Capture;
end;

procedure TStyledControlEh.ReleaseCapture;
begin
  inherited ReleaseCapture;
end;

function TStyledControlEh.GetStyleResource<T>(const AStyleLookup: string): T;
begin
  if FindStyleResource<T>(AStyleLookup, Result) = False then
    raise EResNotFound.Create('TStyledControlEh.GetStyleResource<T>: Style <' + AStyleLookup + ' > is not found.');
end;

function TStyledControlEh.FindNestedStyleResource(
  const AStyleLookupPath: string; const Clone: Boolean): TFmxObject;
var
  ChildObj: TFmxObject;
begin
  Result := FindStyleResource(AStyleLookupPath, Clone);
  if (Result = nil) and
     (ResourceLink <> nil) and
     (ResourceLink.ChildrenCount > 0) then
  begin
    for ChildObj in ResourceLink.Children do
    begin
      if ChildObj is TStyledControl then
      begin
        TStyledControl(ChildObj).ApplyStyleLookup;
        Result := ChildObj.FindStyleResource(AStyleLookupPath, Clone);
        if Result <> nil then Exit;
      end;
    end;
  end;
end;

{$ENDREGION 'TStyledControlEh'}

{$REGION 'TBackstageButtonEh'}

{ TBackstageButtonEh }

constructor TBackstageButtonEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TBackstageButtonEh.Destroy;
begin
  inherited Destroy;
end;

procedure TBackstageButtonEh.ApplyStyle;
begin
  inherited ApplyStyle;
end;

function TBackstageButtonEh.GetStyleObject(const Clone: Boolean): TFmxObject;
begin
  Result := inherited GetStyleObject(Clone);
end;

procedure TBackstageButtonEh.ReadState(Reader: TReader);
begin
  inherited ReadState(Reader);
end;

procedure TBackstageButtonEh.SetMouseOver(AIsMouseOver: Boolean);
begin
  if FIsMouseOver <> AIsMouseOver then
  begin
    FIsMouseOver := AIsMouseOver;
    if FIsMouseOver
      then DoMouseEnter
      else DoMouseLeave;
  end;
end;

{$ENDREGION 'TBackstageButtonEh'}

{$REGION 'TMenuFaceButtonEh'}

{ TMenuFaceButtonEh }

constructor TMenuFaceButtonEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  StyleName := '-';
  StyleLookup := '-';

  FMenuItemFace := TMenuItem.Create(Self);
  FMenuItemFace.Align := TAlignLayout.Client;
  FMenuItemFace.HitTest := False;
  FMenuItemFace.Stored := False;
  FMenuItemFace.Parent := Self;
end;

destructor TMenuFaceButtonEh.Destroy;
begin
  inherited Destroy;
end;

procedure TMenuFaceButtonEh.DoEnter;
begin
  inherited DoEnter;
  FMenuItemFace.IsSelected := True;
end;

procedure TMenuFaceButtonEh.DoExit;
begin
  inherited DoExit;
  FMenuItemFace.IsSelected := False;
end;

procedure TMenuFaceButtonEh.DoMouseEnter;
begin
  inherited DoMouseEnter;
  TControlCrack(FMenuItemFace).DoMouseEnter;
end;

procedure TMenuFaceButtonEh.DoMouseLeave;
begin
  inherited DoMouseLeave;
  TControlCrack(FMenuItemFace).DoMouseLeave;
end;

procedure TMenuFaceButtonEh.DoRealign;
begin
  inherited DoRealign;
  FMenuItemFace.CalcSize;
end;

procedure TMenuFaceButtonEh.ApplyStyle;
begin
  inherited ApplyStyle;
  FMenuItemFace.CalcSize;
end;

procedure TMenuFaceButtonEh.ApplyStyleLookup;
begin
  if IsNeedStyleLookup then
    FMenuItemFace.CalcSize;
  inherited ApplyStyleLookup;
end;

function TMenuFaceButtonEh.GetItem(const AIndex: Integer): TFmxObject;
begin
  Result := FMenuItemFace;
end;

function TMenuFaceButtonEh.GetItemsCount: Integer;
begin
  Result := 0;
end;

function TMenuFaceButtonEh.GetText: String;
begin
  Result := FMenuItemFace.Text;
end;

procedure TMenuFaceButtonEh.SetText(const Value: String);
begin
  FMenuItemFace.Text := Value;
end;

{$ENDREGION 'TMenuFaceButtonEh'}

{$REGION 'TFormEh'}

{ TFormEh }

constructor TFormEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TFormEh.Destroy;
begin
  if FormViewer <> nil then
    TLaObjectTreeViewForm(FormViewer).Form := nil;
  inherited Destroy;
end;

procedure TFormEh.PaintDesignBacklightObject(const Canvas: TCanvas);
var
  DrawRect: TRectF;
  DrawPos: TPointF;
  DrawControl: TControl;
begin
  if (DesignBacklightObject <> nil) and
     (DesignBacklightObject is TControl) then
  begin
    DrawControl := TControl(DesignBacklightObject);

    DrawPos := DrawControl.LocalToAbsolute(TPointF.Create(0, 0));
    DrawRect := TRectF.Create(DrawPos, DrawControl.Width, DrawControl.Height);

    Canvas.Fill.Color := TAlphaColorRec.Salmon;
    Canvas.FillRect(DrawRect, 0, 0, AllCorners, 0.2);
  end;
end;

procedure TFormEh.KeyDown(var Key: Word; var KeyChar: System.WideChar; Shift: TShiftState);
begin
  inherited KeyDown(Key, KeyChar, Shift);

  if Key = vkF10 then
    TDataGridObjectInspectorEh.ShowInspectorForm(ActiveControl, Rect(100, 100, 500, 1000), False)
  else if Key = vkF11 then
    TLaObjectTreeViewForm.ShowDefaultForm(Self, Rect(100, 100, 800, 1000));
end;

procedure TFormEh.DoPaint(const Canvas: TCanvas; const ARect: TRectF);
begin
  inherited DoPaint(Canvas, ARect);
end;

procedure TFormEh.PaintRects(const UpdateRects: array of TRectF);
begin
  inherited PaintRects(UpdateRects);

  if Canvas = nil then
    Exit;

  if Canvas.BeginScene(nil, ContextHandle) then
  begin
    PaintDesignBacklightObject(Canvas);
    Canvas.EndScene;
  end;
end;

procedure TFormEh.SetDesignBacklightObject(const Value: TFmxObject);
begin
  if FDesignBacklightObject <> Value then
  begin
    FDesignBacklightObject := Value;
    Invalidate;
  end;
end;

procedure TFormEh.SetFormViewer(const Value: TForm);
begin
  if FFormViewer <> Value then
  begin
    FFormViewer := Value;
    DesignBacklightObject := nil;
  end;
end;

{$ENDREGION 'TFormEh'}

{$REGION 'TControlMouseParamsEh'}

{ TControlMouseParamsEh }

procedure TControlMouseParamsEh.Init(AX, AY: Single; AShift: TShiftState; AOriginalObject: TControl);
begin
  FX := AX;
  FY := AY;
  FShift := AShift;
  FOriginalObject := AOriginalObject;
end;

function TControlMouseParamsEh.GetPositionRelativeTo(AObject: TControl): TPointF;
var
  ScrPos: TPointF;
  LocPos: TPointF;
begin
  if AObject = OriginalObject then
  begin
    Result := TPointF.Create(X, Y);
  end else
  begin
    ScrPos := OriginalObject.Scene.LocalToScreen(OriginalObject.LocalToAbsolute(TPointF.Create(X, Y)));
    LocPos := AObject.AbsoluteToLocal(AObject.Scene.ScreenToLocal(ScrPos));
    Result := LocPos;
  end;
end;

{$ENDREGION 'TControlMouseParamsEh'}

{$REGION 'TControlMouseButtonParamsEh'}

{ TControlMouseButtonParamsEh }

procedure TControlMouseButtonParamsEh.Init(AButton: TMouseButton; AX, AY: Single;
  AShift: TShiftState; AOriginalObject: TControl);
begin
  inherited Init(AX, AY, AShift, AOriginalObject);
  FButton := AButton;
end;

{$ENDREGION 'TControlMouseButtonParamsEh'}

{$REGION 'TControlShowContextMenuParamsEh'}

{ TControlShowContextMenuParamsEh }

procedure TControlShowContextMenuParamsEh.Init(const AScreenPosition: TPointF;
  AOriginalObject: TControl);
begin
  FScreenPosition := AScreenPosition.Round;
  FOriginalObject := AOriginalObject;
end;

{$ENDREGION 'TControlShowContextMenuParamsEh'}

{$REGION 'TContextMenuManageEh'}

{ TContextMenuManageEh }

class function TContextMenuManageEh.GetGlobalContextMenu: TComposedPopupMenu;
begin
  if FGlobalContextMenu = nil then
  begin
    FGlobalContextMenu := TComposedPopupMenu.Create(nil);
  end;

  Result := FGlobalContextMenu;
end;

class procedure TContextMenuManageEh.ReleaseGlobalContextMenu(AGlobalContextMenu: TComposedPopupMenu);
begin
  while AGlobalContextMenu.ChildrenCount > 0 do
  begin
    AGlobalContextMenu.RemoveObject(AGlobalContextMenu.Children[AGlobalContextMenu.ChildrenCount - 1]);
  end;
end;

{$ENDREGION 'TContextMenuManageEh'}

{$REGION 'TComposedPopupMenu'}

{ TComposedPopupMenu }

constructor TComposedPopupMenu.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FComposedMenuClients := TDictionary<TCustomPopupMenu, TList<TMenuItem>>.Create;
end;

destructor TComposedPopupMenu.Destroy;
begin
  if (FComposedMenuClients.Count > 0) then
    raise Exception.Create('TComposeMenuParamsEh.Destroy: FComposedMenuClients.Count > 0');
  FreeAndNil(FComposedMenuClients);
  inherited Destroy;
end;

procedure TComposedPopupMenu.ClearItems;
begin

end;

function TComposedPopupMenu.GetSeparator: TMenuItem;
begin
  Result := TSeparatorMenuItem.Create(Self);
  Result.Text := '-';
end;

procedure TComposedPopupMenu.AddItem(AMenuItem: TMenuItem);
var
  APopupMenu: TPopupMenu;
  ComposedItems: TList<TMenuItem>;
begin
  if (AMenuItem.Parent <> nil) and
     (AMenuItem.Parent is TPopupMenu) then
  begin
    APopupMenu := TPopupMenu(AMenuItem.Parent);
    if FComposedMenuClients.TryGetValue(APopupMenu, ComposedItems) = False then
    begin
      ComposedItems := TList<TMenuItem>.Create;
      FComposedMenuClients.Add(APopupMenu, ComposedItems);
    end;
    ComposedItems.Add(AMenuItem);
  end;

  AMenuItem.Parent := Self;
end;

procedure TComposedPopupMenu.AddItemsFromMenu(APopupMenu: TCustomPopupMenu);
var
  ComposedItems: TList<TMenuItem>;
  MenuItem: TMenuItem;
  I: Integer;
begin
  if FComposedMenuClients.TryGetValue(APopupMenu, ComposedItems) = False then
  begin
    ComposedItems := TList<TMenuItem>.Create;
    FComposedMenuClients.Add(APopupMenu, ComposedItems);
  end;

  if APopupMenu is TPopupMenu then
  begin
    for I := 0 to TPopupMenu(APopupMenu).ItemsCount - 1 do
    begin
      MenuItem := TPopupMenu(APopupMenu).Items[I];
      ComposedItems.Add(MenuItem);
      MenuItem.Parent := Self;
    end;
  end;
end;

procedure TComposedPopupMenu.PrepareComposedMenu;
begin
  if FPrepared then raise Exception.Create('TComposedPopupMenu.PrepareComposedMenu: Menu already prepared');
  FPrepared := True;

  while ItemsCount > 0 do
    RemoveObject(Items[ItemsCount - 1]);
end;

procedure TComposedPopupMenu.ReleaseComposedMenu;
var
  Mi: TMenuItem;
  MenuAndList: TPair<TCustomPopupMenu, TList<TMenuItem>>;
  MenuItem: TMenuItem;
begin
  for MenuAndList in FComposedMenuClients do
  begin
    for MenuItem in MenuAndList.Value do
    begin
      MenuItem.Parent := MenuAndList.Key;
    end;
    MenuAndList.Value.Free;
  end;

  FComposedMenuClients.Clear;

  while ItemsCount > 0 do
  begin
    Mi := Items[ItemsCount - 1];
    RemoveObject(Mi);
    if Mi.Owner = Self then
      Mi.Free;
  end;

  FPrepared := False;
end;

function TComposedPopupMenu.IsReleased: Boolean;
begin
  Result := not FPrepared;
end;

{$ENDREGION 'TComposedPopupMenu'}

{$REGION 'TSeparatorMenuItem'}

{ TSeparatorMenuItem }

constructor TSeparatorMenuItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TSeparatorMenuItem.Destroy;
begin
  inherited Destroy;
end;

{$ENDREGION 'TSeparatorMenuItem'}

{$REGION 'TControlParamsEh'}

{ TControlParamsEh }

procedure TControlParamsEh.Init(AOriginalObject: TControl);
begin
  FOriginalObject := AOriginalObject;
end;

{$ENDREGION 'TControlParamsEh'}

{$REGION 'TFmxObjectHelper'}

{ TFmxObjectHelper }

function TFmxObjectHelper.CloneWithChildren(const AOwner: TComponent): TFmxObject;
var
  Child: TFmxObject;
  ChildClone: TFmxObject;
begin
  Result := Clone(AOwner);
  if ChildrenCount > 0 then
  begin
    for Child in Children do
    begin
      ChildClone := Child.CloneWithChildren(AOwner);
      Result.AddObject(ChildClone);
    end;
  end;
end;

procedure TFmxObjectHelper.ForAllChildren(ChildActionProcedure: TFmxObjectActionProcedure);
var
  Child: TFmxObject;
  Parent: TFmxObject; 
begin
  Parent := Self;
  if Parent.ChildrenCount = 0 then Exit;

  for Child in Parent.Children do
  begin
    ChildActionProcedure(Child);
    Child.ForAllChildren(ChildActionProcedure);
  end;
end;

function TFmxObjectHelper.GetRefSelf: TFmxObject;
begin
  Result := Self;
end;

{$ENDREGION 'TFmxObjectHelper'}

{$REGION 'TFmxObjectFactory<T>'}

{ TFmxObjectFactory<T: TFmxObject, constructor> }

class function TFmxObjectFactory<T>.CreateWithParent(AParent: TFmxObject): T;
begin
  Result := T.Create(AParent);
  Result.Parent := AParent;
end;

{$ENDREGION 'TFmxObjectFactory<T>'}

{$REGION 'TTestComponent'}

{ TTestComponent }

function VarStrictEquals(const A, B: Variant): Boolean;
begin
  if VarType(A) <> VarType(B) then
    Result := False
  else
    Result := VarSameValue(A, B);
end;

constructor TTestComponent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCheckedValue := True;
end;

destructor TTestComponent.Destroy;
begin
  inherited Destroy;
end;

function TTestComponent.GetCheckedValue: Variant;
begin
  Result := FCheckedValue;
end;

procedure TTestComponent.SetCheckedValue(const Value: Variant);
begin
  if VarStrictEquals(FCheckedValue, Value) = False then
  begin
    FCheckedValue := Value;
    if VarType(FCheckedValue) = varString then
      FCheckedValue := VarToStr(Value); 
    CheckedValueChanged();
  end;
end;

function TTestComponent.IsCheckedValueStored: Boolean;
begin
  if VarStrictEquals(FCheckedValue, True) then
    Result := False
  else
    Result := True;
end;

procedure TTestComponent.CheckedValueChanged;
begin
end;

{$ENDREGION 'TTestComponent'}

{$REGION 'TMyTestGridControl'}

{ TMyTestGridControl }

procedure TMyTestGridControl.ApplyStyle;
var
  RowBackground: TFmxObject;
begin
  inherited ApplyStyle;

  if FindStyleResource<TFmxObject>('AlternatingRowBackground', RowBackground) then
  begin
    DoNothing; //Ok
  end else
  begin
    DoNothing;
  end;
end;

procedure TMyTestGridControl.ApplyStyleLookup;
begin
  inherited ApplyStyleLookup;
end;

constructor TMyTestGridControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TMyTestGridControl.Destroy;
begin
  inherited Destroy;
end;

procedure TMyTestGridControl.Paint;
begin
  Canvas.Fill.Color := TAlphaColorRec.Brown;

  Canvas.FillText(
    TRectF.Create(0, 0, Width, Height),
    'TMyTestGridControl.Paint',
    False,
    1,
    [],
    TTextAlign.Center,
    TTextAlign.Center);
end;

{$ENDREGION 'TMyTestGridControl'}

{ TOneShotTimer }

constructor TOneShotTimer.Create(AInterval: Cardinal; const AThreadProc: TThreadProcedure);
begin
  inherited Create(nil);
  Interval := AInterval;
  FThreadProc := AThreadProc;
  Enabled := False;
  OnTimer := OnTimerHandler;
end;

procedure TOneShotTimer.OnTimerHandler(Sender: TObject);
begin
  FThreadProc();
  Free;
end;

procedure TOneShotTimer.Start;
begin
  Enabled := True;
end;

initialization
  InitModule;
finalization
  FinalizeModule;
end.

