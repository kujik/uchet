{*******************************************************}
{                                                       }
{                     EhLibFmx 12.1                     }
{                   EhLibFmx.LaObjects                  }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

{$I ..\Incl\EhLib.Inc}
{$SCOPEDENUMS ON}

unit EhLibFmx.LaObjects;

interface

{$REGION 'uses'}
uses
  Types, Classes, SysUtils, Variants,
  Generics.Collections,
  Math,
  System.UITypes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics,
  EhLibUtils,
  EhLibFmx.ToolControls,
  EhLibFmx.Utils
  ;
{$ENDREGION 'uses'}

type
  TLaObjectEh = class;
  TLaHostWinControl = class;
  TLaHintInfoEventParamsEh = class;

  TLaHorzAlignmentEh = (Left, Center, Right, Stretch);
  TLaVertAlignmentEh = (Top, Center, Bottom, Stretch);
  TLaOrientationEh = (Vertical, Horizontal);

  IRefObjectInterface = interface
    ['{29465A0A-BB57-49C2-9443-DEA693BABD84}']
    function GetObject: TObject;
  end;

  TLaObjectGetHintInfoEvent = procedure(Sender: TLaObjectEh; Params: TLaHintInfoEventParamsEh) of object;
  TLaObjectStopFunction = reference to function(AObject: TFmxObject): Boolean;

{ TInterfacedRefObject }

  TInterfacedRefObject = class(TInterfacedObject, IRefObjectInterface)
  private
    FRefObject: TObject;
    FOwnsObject: Boolean;
  public
    constructor Create(ARefObject: TObject; AOwnsObject: Boolean);
    destructor Destroy; override;

    function GetObject: TObject;
  end;

  TLaObjectList = TList<TLaObjectEh>;

{ TLaChildrenEnumerable }

  TLaChildrenEnumerable = class(TEnumerable<TLaObjectEh>)
  private
    FChildren: TLaObjectList;
  protected
    function DoGetEnumerator: TEnumerator<TLaObjectEh>; override;
    function GetChildCount: Integer; virtual;
    function GetChild(AIndex: Integer): TLaObjectEh; virtual;
  public
    constructor Create(const AChildren: TLaObjectList);
    destructor Destroy; override;
    property Count: Integer read GetChildCount;
    function IndexOf(const Obj: TLaObjectEh): Integer; virtual;
    property Items[Index: Integer]: TLaObjectEh read GetChild; default;
  end;

{ TLaObjectKeyEventParamsEh }

  TLaObjectKeyEventParamsEh = class(TPersistent)
  private
    FShift: TShiftState;
    FKey: Word;
    FKeyChar: WideChar;
    FSrcObject: TObject;
  public
    procedure Init(AKey: Word; AKeyChar: WideChar; AShift: TShiftState; ASrcObject: TObject);

    property Shift: TShiftState read FShift;
    property Key: Word read FKey write FKey;
    property KeyChar: WideChar read FKeyChar write FKeyChar;

    property SrcObject: TObject read FSrcObject write FSrcObject;
  end;

  ILaHostWinControl = interface
    ['{D0533ACB-1810-4438-AE07-12D05677BC74}']
    procedure Invalidate();
    procedure ProcessMouseDown(Params: TControlMouseButtonParamsEh);
    procedure ProcessMouseMove(Params: TControlMouseParamsEh);
    procedure ProcessMouseClick(Params: TControlMouseButtonParamsEh);
    procedure ProcessMouseUp(Params: TControlMouseButtonParamsEh);
    procedure ProcessDblClick(Params: TControlParamsEh);

    procedure ProcessPreviewMouseMove(Params: TControlMouseParamsEh);
    procedure ProcessPreviewMouseDown(Params: TControlMouseButtonParamsEh);
    procedure ProcessPreviewMouseUp(Params: TControlMouseButtonParamsEh);
    procedure ProcessPreviewMouseClick(Params: TControlMouseButtonParamsEh);
    procedure ProcessPreviewKeyDown(Params: TLaObjectKeyEventParamsEh);
    procedure ProcessPreviewMouseEnter(Params: TControlParamsEh);
    procedure ProcessPreviewMouseLeave(Params: TControlParamsEh);
    procedure ProcessShowContextMenu(Params: TControlShowContextMenuParamsEh);
    procedure ProcessPreviewDblClick(Params: TControlParamsEh);

    procedure LayoutChanged(LaObject: TLaObjectEh);
    function GetObject: TFmxObject;
  end;

{ TLaObject }

  TLaObjectEh = class(TStyledControlEh)
//  TLaObjectEh = class(TControl)
  private
    FLocation: TPointF;
    FPerformedSize: TSizeF;
    FSize: TSizeF;

    FNeededSize: TSizeF;
    FLayoutRect: TRectF;

    FLastQuerySize: TSizeF;
    FLastPerfSize: TSizeF;
    FLastPerfRect: TRectF;

    FVertAlignment: TLaVertAlignmentEh;
    FHorzAlignment: TLaHorzAlignmentEh;
    FHint: String;
    FOnGetHintInfo: TLaObjectGetHintInfoEvent;
    FOnMouseClick: TControlMouseButtonEventEh;
    FIsInQueryLayout: Boolean;
    FIsInPerformLayout: Boolean;
    FClipRect: TRectF;
    FMaxWidth: Single;
    FMaxHeight: Single;
    FIsQueryLayoutNeeded: Boolean;
    FIsPerformLayoutNeeded: Boolean;
    FLaHost: ILaHostWinControl;
    FMatrixChangeIsNeeded: Boolean;
    FDataContext: IDataContextEh;
    FOnMouseDown: TControlMouseButtonEventEh;
    FPressedOrChildPressed: Boolean;

    function GetRefSelf: TLaObjectEh;
    function GetText: String;
    function GetHeight: Single; reintroduce;
    function GetWidth: Single; reintroduce;
    function GetActualHeight: Single;
    function GetActualWidth: Single;
    function GetLaHost: ILaHostWinControl;

    procedure CalcHozAlignment(OfferedSize, PreferredSize: TSizeF; out AlignedPos: Single; out AlignedSize: Single);
    procedure CalcVertAlignment(OfferedSize, PreferredSize: TSizeF; out AlignedPos: Single; out AlignedSize: Single);
    procedure SetMaxHeight(const Value: Single);
    procedure SetMaxWidth(const Value: Single);

    procedure InternalProcessMouseMove(MouseParams: TControlMouseParamsEh);
    procedure InternalProcessMouseDown(MouseParams: TControlMouseButtonParamsEh);
    procedure InternalProcessMouseUp(MouseParams: TControlMouseButtonParamsEh);
    procedure InternalProcessMouseClick(MouseParams: TControlMouseButtonParamsEh);
    procedure InternalProcessMouseEnter(Params: TControlParamsEh);
    procedure InternalProcessMouseLeave(Params: TControlParamsEh);
    procedure InternalProcessShowContextMenu(Params: TControlShowContextMenuParamsEh);
    procedure InternalProcessDblClick(DblClickParams: TControlParamsEh);

    procedure SetHeight(const Value: Single); reintroduce;
    procedure SetWidth(const Value: Single); reintroduce;
    function GetActualLeft: Single;
    function GetActualTop: Single;
    procedure SetDataContext(const Value: IDataContextEh);
    procedure SetHorzAlignment(const Value: TLaHorzAlignmentEh);
    procedure SetVertAlignment(const Value: TLaVertAlignmentEh);

  protected

    function GetDataContext: IDataContextEh;
    function GetCursorAtMousePos(Shift: TShiftState; X, Y: Single): TCursor; virtual;

    procedure DoMouseEnter; override;
    procedure DoMouseLeave; override;

    function ShowContextMenu(const ScreenPosition: TPointF): Boolean; override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseClick(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure DblClick; override;

    {$IFDEF EH_LIB_25} 
    procedure DoResized; override;
    {$ENDIF}
    procedure DoAddObject(const AObject: TFmxObject); override;
    procedure VisibleChanged; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    {$IFDEF EH_LIB_37} // { RAD Studio 13 }
    procedure MarginsChanged(); override;
    {$ENDIF}
    procedure PaddingChanged(); override;

    procedure ProcessMouseDown(Params: TControlMouseButtonParamsEh); virtual;
    procedure ProcessMouseMove(Params: TControlMouseParamsEh); virtual;
    procedure ProcessMouseUp(Params: TControlMouseButtonParamsEh); virtual;
    procedure ProcessMouseClick(Params: TControlMouseButtonParamsEh); virtual;
    procedure ProcessDblClick(Params: TControlParamsEh); virtual;
    procedure ProcessShowContextMenu(Params: TControlShowContextMenuParamsEh); virtual;
    procedure ProcessParentsMouseDown(Params: TControlMouseButtonParamsEh);
    procedure ProcessParentsMouseMove(Params: TControlMouseParamsEh);
    procedure ProcessParentsMouseUp(Params: TControlMouseButtonParamsEh);
    procedure ProcessParentsMouseClick(Params: TControlMouseButtonParamsEh);
    procedure ProcessParentsDblClick(Params: TControlParamsEh);
    procedure MouseEnter(Params: TControlParamsEh); virtual;
    procedure MouseLeave(Params: TControlParamsEh); virtual;

    procedure InternalProcessKeyDown(Params: TLaObjectKeyEventParamsEh);
    procedure ProcessKeyDown(Params: TLaObjectKeyEventParamsEh); virtual;

    procedure ParentDependenciesChanged; virtual;
    procedure UpdateChildDependencies;
    procedure DoEndUpdate; override;
    procedure DoUpdateDataContent; virtual;
    procedure ParentChanged; override;

  public
    const MaxSize: TSizeF = (cx: 1048576; cy: 1048576);
    const UnlimitedRect: TRectF = (Left: 0.0 / 0.0; Top: 0.0 / 0.0; Right: 0.0 / 0.0; Bottom: 0.0 / 0.0);

    constructor Create(AOwner: TComponent); override;
    constructor CreateWith(AOwner: TComponent; ALaHost: TLaHostWinControl); overload;
    constructor CreateWith(AOwner: TComponent; AParentObject: TLaObjectEh); overload;
    constructor CreateWith(AOwnerAndParent: TLaObjectEh); overload;

    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    function CreateCopy(Owner: TComponent): TLaObjectEh;
    function ContainsFocus: Boolean;

    procedure Paint; override;
    procedure Draw(const ARect: TRectF; ACanvas: TCanvas); overload; virtual;
    procedure LayoutChanged;
    procedure InternalLayoutChanged;
    procedure SetLayoutChangedForAll;
    procedure UpdateDataContent;

    function QueryLayout(const AQuerySize: TSizeF; ACanvas: TCanvas): TSizeF; overload;
    function PerformLayout(const PerfRect: TRectF; ACanvas: TCanvas; const StrictRect: TRectF): TSizeF; overload;

    function DoQueryLayout(const QuerySize: TSizeF; ACanvas: TCanvas): TSizeF; overload; virtual;
    function DoPerformLayout(const PerfSize: TSizeF; ACanvas: TCanvas): TSizeF; overload; virtual;

    procedure RemoveObject(const AObject: TLaObjectEh); overload;
    procedure DeleteChildren;
    procedure FillHintInfo(HintInfo: TLaHintInfoEventParamsEh);
    procedure Invalidate;

    procedure InternalSetSize(const Value: TSizeF);
    procedure InternalSetPosition(const Value: TSizeF);

    function GetElementByName(ElementName: String): TControl;
    function GetAncestor(const AStopProc: TLaObjectStopFunction): TFmxObject;

    property RefSelf: TLaObjectEh read GetRefSelf; 
    property IsInQueryLayout: Boolean read FIsInQueryLayout;
    property IsInPerformLayout: Boolean read FIsInPerformLayout;

  public
    function IsMouseCaptured: Boolean;

    property NeededSize: TSizeF read FNeededSize;
    property LayoutRect: TRectF read FLayoutRect;
    property ClipRect: TRectF read FClipRect;
    property LaHost: ILaHostWinControl read GetLaHost;
    property DataContext: IDataContextEh read GetDataContext write SetDataContext;

    property IsQueryLayoutNeeded: Boolean read FIsQueryLayoutNeeded;
    property IsPerformLayoutNeeded: Boolean read FIsPerformLayoutNeeded;

    property OnGetHintInfo: TLaObjectGetHintInfoEvent read FOnGetHintInfo write FOnGetHintInfo;
    property OnMouseClick: TControlMouseButtonEventEh read FOnMouseClick write FOnMouseClick;
    property OnMouseDown: TControlMouseButtonEventEh read FOnMouseDown write FOnMouseDown;

  published
    property Width: Single read GetWidth write SetWidth;
    property Height: Single read GetHeight write SetHeight;
    property Location: TPointF read FLocation;
    property Size: TSizeF read FSize;
    property Text: String read GetText;
    property ActualTop: Single read GetActualTop;
    property ActualLeft: Single read GetActualLeft;
    property ActualWidth: Single read GetActualWidth;
    property ActualHeight: Single read GetActualHeight;
    property Margins;
    property Padding;
    property HorzAlignment: TLaHorzAlignmentEh read FHorzAlignment write SetHorzAlignment default TLaHorzAlignmentEh.Stretch;
    property VertAlignment: TLaVertAlignmentEh read FVertAlignment write SetVertAlignment default TLaVertAlignmentEh.Stretch;
    property Hint: String read FHint write FHint;
    property MaxWidth: Single read FMaxWidth write SetMaxWidth;
    property MaxHeight: Single read FMaxHeight write SetMaxHeight;
    property PressedOrChildPressed: Boolean read FPressedOrChildPressed;
  end;

  TLaObjectClass = class of TLaObjectEh;

{ TLaHostWinControl }

  TLaHostWinControl = class(TControl, ILaHostWinControl)
  private
    function GetLaObject: TLaObjectEh;

    procedure SetLaObjectProp(const Value: TLaObjectEh);
  protected
    procedure Paint; override;
    procedure DoRealign; override;

    procedure Invalidate();
    procedure ProcessMouseDown(Params: TControlMouseButtonParamsEh); virtual;
    procedure ProcessMouseMove(Params: TControlMouseParamsEh); virtual;
    procedure ProcessMouseClick(Params: TControlMouseButtonParamsEh); virtual;
    procedure ProcessMouseUp(Params: TControlMouseButtonParamsEh); virtual;
    procedure ProcessDblClick(Params: TControlParamsEh); virtual;

    procedure ProcessPreviewMouseMove(Params: TControlMouseParamsEh); virtual;
    procedure ProcessPreviewMouseDown(Params: TControlMouseButtonParamsEh); virtual;
    procedure ProcessPreviewMouseUp(Params: TControlMouseButtonParamsEh); virtual;
    procedure ProcessPreviewMouseClick(Params: TControlMouseButtonParamsEh); virtual;
    procedure ProcessPreviewKeyDown(Params: TLaObjectKeyEventParamsEh); virtual;
    procedure ProcessPreviewMouseLeave(Params: TControlParamsEh); virtual;
    procedure ProcessPreviewMouseEnter(Params: TControlParamsEh); virtual;
    procedure ProcessPreviewDblClick(Params: TControlParamsEh); virtual;

    procedure ProcessShowContextMenu(Params: TControlShowContextMenuParamsEh);
    procedure LayoutChanged(LaObject: TLaObjectEh);
    procedure LayoutUpdated(); virtual;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure UpdateLayout();
    function QueryPerformLayout(QuerySize: TSizeF): TSizeF;

  published
    property LaObject: TLaObjectEh read GetLaObject write SetLaObjectProp;
  end;

{ TLaHintInfoEventParamsEh }

  TLaHintInfoEventParamsEh = class(TPersistent)
  private
    FHandled: Boolean;
    FLaObject: TLaObjectEh;
    FHintText: String;
    FHintObject: TLaObjectEh;
    FHideTimeout: Integer;

  public
    procedure InitParams(ALaObject: TLaObjectEh);

    property LaObject: TLaObjectEh read FLaObject;
    property HintText: String read FHintText write FHintText;
    property HintObject: TLaObjectEh read FHintObject write FHintObject;
    property HideTimeout: Integer read FHideTimeout write FHideTimeout;
    property Handled: Boolean read FHandled write FHandled;
  end;

implementation


{$REGION 'Unit Functions' }

function RectSize(const Rect: TRectF): TSizeF;
begin
  Result := Rect.Size;
end;

function CreateSize(cx, cy: Integer): TSizeF;
begin
  Result := TSizeF.Create(cx, cy);
end;

procedure CanvasFillRect(Canvas: TCanvas; const ARect: TRectF; const AOpacity: Single);
begin
  Canvas.FillRect(ARect, 0, 0, [], AOpacity);
end;

{$ENDREGION 'Unit Functions' }

{$REGION 'TInterfacedRefObject'}

{ TInterfacedRefObject }

constructor TInterfacedRefObject.Create(ARefObject: TObject;
  AOwnsObject: Boolean);
begin
  FRefObject := ARefObject;
  FOwnsObject := AOwnsObject;
end;

destructor TInterfacedRefObject.Destroy;
begin
  if (FOwnsObject) then
    FreeAndNil(FRefObject);
end;

function TInterfacedRefObject.GetObject: TObject;
begin
  Result := FRefObject;
end;

{$ENDREGION 'TInterfacedRefObject'}

{$REGION 'TLaChildrenEnumerable'}

{ TLaChildrenEnumerable }

constructor TLaChildrenEnumerable.Create(const AChildren: TLaObjectList);
begin
  inherited Create;
  FChildren := AChildren;
end;

destructor TLaChildrenEnumerable.Destroy;
begin
  FChildren := nil;
  inherited;
end;

function TLaChildrenEnumerable.DoGetEnumerator: TEnumerator<TLaObjectEh>;
begin
  Result := FChildren.GetEnumerator;
end;

function TLaChildrenEnumerable.GetChild(AIndex: Integer): TLaObjectEh;
begin
  Result := FChildren[AIndex];
end;

function TLaChildrenEnumerable.GetChildCount: Integer;
begin
  if FChildren <> nil
    then Result := FChildren.Count
    else Result := 0;
end;

function TLaChildrenEnumerable.IndexOf(const Obj: TLaObjectEh): Integer;
begin
  if FChildren <> nil
    then Result := FChildren.IndexOf(Obj)
    else Result := -1;
end;

{$ENDREGION 'TLaChildrenEnumerable'}

{$REGION 'TLaObjectEh'}

{ TLaObject }

constructor TLaObjectEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHorzAlignment := TLaHorzAlignmentEh.Stretch;
  FVertAlignment := TLaVertAlignmentEh.Stretch;
  FMaxWidth := -1;
  FMaxHeight := -1;
  HitTest := False;
  FSize := TSizeF.Create(Single.NaN, Single.NaN);
  ClipChildren := True;
  Locked := True;
end;

constructor TLaObjectEh.CreateWith(AOwner: TComponent; ALaHost: TLaHostWinControl);
begin
  Create(AOwner);
  ALaHost.LaObject := Self;
end;

constructor TLaObjectEh.CreateWith(AOwner: TComponent; AParentObject: TLaObjectEh);
begin
  Create(AOwner);
  Parent := AParentObject;
end;

constructor TLaObjectEh.CreateWith(AOwnerAndParent: TLaObjectEh);
begin
  CreateWith(AOwnerAndParent, AOwnerAndParent);
end;

destructor TLaObjectEh.Destroy;
begin
  DataContext := nil;
  inherited Destroy;
end;

function TLaObjectEh.GetRefSelf: TLaObjectEh;
begin
  Result := Self;
end;

procedure TLaObjectEh.RemoveObject(const AObject: TLaObjectEh);
begin
  if AObject <> nil then
    DoRemoveObject(AObject);
end;

function TLaObjectEh.GetText: String;
begin
  Result := ClassName;
end;

procedure TLaObjectEh.Invalidate;
begin
  Repaint;
end;

procedure TLaObjectEh.DeleteChildren;
begin
  DoDeleteChildren;
end;

procedure TLaObjectEh.Paint;
begin
  Draw(TRectF.Create(0, 0, ActualWidth, ActualHeight), Canvas);
end;

procedure TLaObjectEh.Draw(const ARect: TRectF; ACanvas: TCanvas);
begin
end;

procedure TLaObjectEh.FillHintInfo(HintInfo: TLaHintInfoEventParamsEh);
begin
  if (not HintInfo.Handled) then
  begin
    if (Hint <> '') then
    begin
      HintInfo.HintText := Hint;
      HintInfo.Handled := True;
    end;
  end;

  if (Assigned(OnGetHintInfo)) then
    OnGetHintInfo(Self, HintInfo);
end;

function TLaObjectEh.GetDataContext: IDataContextEh;
begin
  if (FDataContext <> nil) then
    Result := FDataContext
  else if (Parent <> nil) and (Parent is TLaObjectEh) then
    Result := TLaObjectEh(Parent).GetDataContext
  else
    Result := nil;
end;

procedure TLaObjectEh.ParentChanged;
begin
  inherited ParentChanged;
  LayoutChanged;
end;

procedure TLaObjectEh.ParentDependenciesChanged;
begin

end;

procedure TLaObjectEh.UpdateChildDependencies;
var
  I: Integer;
  LaChild: TLaObjectEh;
  FmxChild: TFmxObject;
begin
  for I := 0 to ChildrenCount - 1 do
  begin
    FmxChild := Children[I];
    if FmxChild is TLaObjectEh then
    begin
      LaChild := TLaObjectEh(Children[I]);
      LaChild.ParentDependenciesChanged;
      LaChild.UpdateChildDependencies;
    end;
  end;
end;

procedure TLaObjectEh.VisibleChanged;
begin
  inherited VisibleChanged;
  LayoutChanged;
end;

{$IFDEF EH_LIB_25} 
procedure TLaObjectEh.DoResized;
begin
  LayoutChanged;
end;
{$ENDIF}

procedure TLaObjectEh.InternalLayoutChanged;
begin
  FIsQueryLayoutNeeded := True;
  FIsPerformLayoutNeeded := True;
  Invalidate;
end;

procedure TLaObjectEh.LayoutChanged;
begin
  InternalLayoutChanged;
  if (LaHost <> nil) then
    LaHost.LayoutChanged(Self);
end;

procedure TLaObjectEh.SetLayoutChangedForAll;

  procedure SetLayoutChangedAllForParent(LaParent: TLaObjectEh);
  var
    I: Integer;
    FmxObject: TFmxObject;
    LaObject: TLaObjectEh;
  begin
    for I := 0 to LaParent.ChildrenCount - 1 do
    begin
      FmxObject := LaParent.Children[I];
      if FmxObject is TLaObjectEh then
      begin
        LaObject := TLaObjectEh(FmxObject);
        LaObject.InternalLayoutChanged;
        SetLayoutChangedAllForParent(LaObject);
      end;
    end;
  end;

begin
  LayoutChanged;
  SetLayoutChangedAllForParent(Self);
end;

function TLaObjectEh.QueryLayout(const AQuerySize: TSizeF; ACanvas: TCanvas): TSizeF;
var
  CurrSize: TSizeF;
begin
  UpdateDataContent;
  FIsInQueryLayout := True;
  CurrSize := AQuerySize;

  if (MaxWidth >= 0) and (CurrSize.cx > MaxWidth) then
    CurrSize.cx := MaxWidth;
  if (MaxHeight >= 0) and (CurrSize.cy > MaxHeight) then
    CurrSize.cy := MaxHeight;

  CurrSize.cx := CurrSize.cx - Margins.Left - Margins.Right;
  CurrSize.cy := CurrSize.cy + Margins.Top + Margins.Bottom;
  if (CurrSize.cx < 0) then CurrSize.cx := 0;
  if (CurrSize.cy < 0) then CurrSize.cy := 0;

  if (FIsQueryLayoutNeeded = True) or (FLastQuerySize <> CurrSize) then
  begin
    FNeededSize := DoQueryLayout(CurrSize, ACanvas);

    if Single.IsNan(Width) = False then
      FNeededSize.Width := Width;

    if Single.IsNan(Height) = False then
      FNeededSize.Height := Height;

    FIsQueryLayoutNeeded := False;
    FLastQuerySize := CurrSize;
  end;

  Result.cx := FNeededSize.cx + Margins.Left + Margins.Right;
  Result.cy := FNeededSize.cy + Margins.Top + Margins.Bottom;

  FIsInQueryLayout := False;
end;

function TLaObjectEh.PerformLayout(const PerfRect: TRectF; ACanvas: TCanvas; const StrictRect: TRectF): TSizeF;
var
  LayoutRect: TRectF;
  AlignedPos: TPointF;
  LayoutSize: TSizeF;
  PreferredSize: TSizeF;
  PreferredResultSize: TSizeF;
  PerformLayoutSize: TSizeF;
  CurrPerfRect: TRectF;
begin
  UpdateDataContent;
  FIsInPerformLayout := True;
  CurrPerfRect := PerfRect;

  if (MaxWidth >= 0) and (RectWidth(CurrPerfRect) > MaxWidth) then
    CurrPerfRect.Right := CurrPerfRect.Left + MaxWidth;
  if (MaxHeight >= 0) and (RectHeight(CurrPerfRect) > MaxHeight) then
    CurrPerfRect.Bottom := CurrPerfRect.Top + MaxHeight;

  FClipRect := CurrPerfRect;
  LayoutRect := CurrPerfRect;

  LayoutRect.Left := LayoutRect.Left + Margins.Left;
  LayoutRect.Top := LayoutRect.Top + Margins.Top;
  LayoutRect.Right := LayoutRect.Right - Margins.Right;
  LayoutRect.Bottom := LayoutRect.Bottom - Margins.Bottom;
  LayoutSize := RectSize(LayoutRect);

  if Single.IsNan(Width) = False then
    PerformLayoutSize.Width := Width
  else if (HorzAlignment <> TLaHorzAlignmentEh.Stretch) and
          (LayoutSize.Width > FNeededSize.Width) then
    PerformLayoutSize.Width := FNeededSize.Width
  else
    PerformLayoutSize.Width := LayoutSize.Width;

  if Single.IsNan(Height) = False then
    PerformLayoutSize.Height := Height
  else if (VertAlignment <> TLaVertAlignmentEh.Stretch) and
          (LayoutSize.Height > FNeededSize.Height) then
    PerformLayoutSize.Height := FNeededSize.Height
  else
    PerformLayoutSize.Height := LayoutSize.Height;

  if (FIsPerformLayoutNeeded = True) or
     (FLastPerfSize <> PerformLayoutSize) or
     (FLastPerfRect <> CurrPerfRect) then
  begin
    PreferredSize := DoPerformLayout(PerformLayoutSize, ACanvas);

    if Single.IsNan(Width) = False then
      PreferredSize.Width := Width;
    if Single.IsNan(Height) = False then
      PreferredSize.Height := Height;

    CalcHozAlignment(LayoutSize, PreferredSize, AlignedPos.X, PreferredResultSize.cx);
    CalcVertAlignment(LayoutSize, PreferredSize, AlignedPos.Y, PreferredResultSize.cy);

    FLocation.X := LayoutRect.Left + AlignedPos.X;
    FLocation.Y := LayoutRect.Top + AlignedPos.Y;
    FPerformedSize := PreferredResultSize;

    FIsPerformLayoutNeeded := False;
    FLastPerfSize := PerformLayoutSize;
    FLastPerfRect := CurrPerfRect;
  end;

  InternalSetPosition(FLocation);

  FLayoutRect.Left := FLocation.X - Margins.Left;
  FLayoutRect.Top := FLocation.Y - Margins.Top;
  FLayoutRect.Right := FLayoutRect.Left + LayoutSize.cx + Margins.Left + Margins.Right;
  FLayoutRect.Bottom := FLayoutRect.Top + LayoutSize.cy + Margins.Top + Margins.Bottom;

  InternalSetSize(FPerformedSize);

  Result := FPerformedSize;
  Result.cx := Result.cx + Margins.Left + Margins.Right;
  Result.cy := Result.cy + Margins.Top + Margins.Bottom;
  FIsInPerformLayout := False;
end;

procedure TLaObjectEh.DoAddObject(const AObject: TFmxObject);
begin
  inherited DoAddObject(AObject);
end;

function TLaObjectEh.DoPerformLayout(const PerfSize: TSizeF; ACanvas: TCanvas): TSizeF;
begin
  Result := PerfSize;
end;

function TLaObjectEh.DoQueryLayout(const QuerySize: TSizeF; ACanvas: TCanvas): TSizeF;
begin
  Result := CreateSize(0, 0);
end;

procedure TLaObjectEh.CalcVertAlignment(OfferedSize, PreferredSize: TSizeF;
  out AlignedPos: Single; out AlignedSize: Single);
begin
  AlignedPos := 0;

  case VertAlignment of
    TLaVertAlignmentEh.Top:
      begin
        AlignedPos := 0;
        AlignedSize := PreferredSize.cy;
      end;
    TLaVertAlignmentEh.Center:
      begin
        AlignedPos := Round((OfferedSize.cy - PreferredSize.cy) / 2);
        AlignedSize := PreferredSize.cy;
      end;

    TLaVertAlignmentEh.Bottom:
      begin
        AlignedPos := OfferedSize.cy - PreferredSize.cy;
        AlignedSize := PreferredSize.cy;
      end;

    TLaVertAlignmentEh.Stretch:
      begin
        AlignedPos := 0;
        if OfferedSize.cy > PreferredSize.cy
          then AlignedSize := OfferedSize.cy
          else AlignedSize := PreferredSize.cy;
      end;
  end;
end;

procedure TLaObjectEh.CalcHozAlignment(OfferedSize, PreferredSize: TSizeF;
  out AlignedPos: Single; out AlignedSize: Single);
begin
  case HorzAlignment of
    TLaHorzAlignmentEh.Left:
      begin
        AlignedPos := 0;
        AlignedSize := PreferredSize.cx;
      end;
    TLaHorzAlignmentEh.Center:
      begin
        AlignedPos := Round((OfferedSize.cx - PreferredSize.cx) / 2);
        AlignedSize := PreferredSize.cx;
      end;

    TLaHorzAlignmentEh.Right:
      begin
        AlignedPos := OfferedSize.cx - PreferredSize.cx;
        AlignedSize := PreferredSize.cx;
      end;

    TLaHorzAlignmentEh.Stretch:
      begin
        AlignedPos := 0;
        if OfferedSize.cx > PreferredSize.cx
          then AlignedSize := OfferedSize.cx
          else AlignedSize := PreferredSize.cx;
      end;
  end;
end;

function TLaObjectEh.CreateCopy(Owner: TComponent): TLaObjectEh;
begin
  Result := TLaObjectClass(Self.ClassType).Create(Owner);
  Result.Assign(Self);
end;

function TLaObjectEh.ContainsFocus: Boolean;
var
  ItfsControl: IControl;
  FocusObject: TFmxObject;
begin
  FocusObject := nil;
  Result := IsFocused;
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

procedure TLaObjectEh.Assign(Source: TPersistent);
var
  I: Integer;
  Child: TLaObjectEh;
  SrcObject: TLaObjectEh;
begin
  if (Source is TLaObjectEh) then
  begin
    SrcObject := TLaObjectEh(Source);

    Name := SrcObject.Name;
    Margins := SrcObject.Margins;
    HorzAlignment := SrcObject.HorzAlignment;
    VertAlignment := SrcObject.VertAlignment;
    Hint := SrcObject.Hint;

    OnGetHintInfo := SrcObject.OnGetHintInfo;

    for I := 0 to SrcObject.ChildrenCount - 1 do
    begin
      Child := TLaObjectEh(SrcObject.Children[I]);
      AddObject(Child.CreateCopy(Owner));
    end;
  end;
end;

function TLaObjectEh.GetElementByName(ElementName: String): TControl;

  function GetTreeChildElementByName(Parent: TControl; ElementName: String): TControl;
  var
    I: Integer;
    Child: TFmxObject;
    ChildControl: TControl;
  begin
    Result := nil;
    for I := 0 to Parent.ChildrenCount - 1 do
    begin
      Child := Parent.Children[I];
      if Child is TControl then
      begin
        ChildControl := TControl(Parent.Children[I]);
        if (ChildControl.Name = ElementName) then
        begin
          Result := ChildControl;
          Exit;
        end;
        Result := GetTreeChildElementByName(ChildControl, ElementName);
        if Result <> nil then
          Exit;
      end;
    end;
  end;

begin
  Result := GetTreeChildElementByName(Self, ElementName);
end;

function TLaObjectEh.GetAncestor(const AStopProc: TLaObjectStopFunction): TFmxObject;
var
  AParent: TFmxObject;
begin
  Result := nil;
  AParent := Self.Parent;
  while AParent <> nil do
  begin
    if AStopProc(AParent) then
    begin
      Result := AParent;
      Exit;
    end;
    AParent := AParent.Parent;
  end;
end;

{$REGION Mouse procedures }

procedure TLaObjectEh.DoMouseEnter;
var
  EnterParams: TControlParamsEh;
  MousePosInPanel1: TPointF;
  MousePosInPanel2: TPointF;
begin
  MousePosInPanel1 := ScreenToLocal(Screen.MousePos);
  MousePosInPanel2 := GetControlMessageMousePos(Self);

  inherited DoMouseEnter;

  EnterParams := TControlParamsEh.Create;
  EnterParams.Init(Self);
  try
    InternalProcessMouseEnter(EnterParams);
  finally
    EnterParams.Free;
  end;
end;

procedure TLaObjectEh.InternalProcessMouseEnter(Params: TControlParamsEh);
begin
  if LaHost <> nil then
    LaHost.ProcessPreviewMouseEnter(Params);
end;

procedure TLaObjectEh.MouseEnter(Params: TControlParamsEh);
begin
end;

procedure TLaObjectEh.DoMouseLeave;
var
  LeaveParams: TControlParamsEh;
  MousePosInPanel1: TPointF;
  MousePosInPanel2: TPointF;
begin
  MousePosInPanel1 := ScreenToLocal(Screen.MousePos);
  MousePosInPanel2 := GetControlMessageMousePos(Self);

  inherited DoMouseLeave;

  LeaveParams := TControlParamsEh.Create;
  LeaveParams.Init(Self);
  try
    InternalProcessMouseLeave(LeaveParams);
  finally
    LeaveParams.Free;
  end;
end;

procedure TLaObjectEh.InternalProcessMouseLeave(Params: TControlParamsEh);
begin
  if LaHost <> nil then
    LaHost.ProcessPreviewMouseLeave(Params);
end;

procedure TLaObjectEh.MouseLeave(Params: TControlParamsEh);
begin
end;

procedure TLaObjectEh.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  MouseParams: TControlMouseButtonParamsEh;
begin
  inherited MouseDown(Button, Shift, X, Y);

  MouseParams := TControlMouseButtonParamsEh.Create;
  MouseParams.Init(Button, X, Y, Shift, Self);
  try
    if LaHost <> nil then
      LaHost.ProcessPreviewMouseDown(MouseParams);

    if MouseParams.Handled = False then
      InternalProcessMouseDown(MouseParams);
  finally
    MouseParams.Free;
  end;
end;

procedure TLaObjectEh.InternalProcessMouseDown(MouseParams: TControlMouseButtonParamsEh);
begin
  ProcessMouseDown(MouseParams);
  ProcessParentsMouseDown(MouseParams);
end;

procedure TLaObjectEh.ProcessMouseDown(Params: TControlMouseButtonParamsEh);
begin
  if (Params.Button = TMouseButton.mbLeft) and not (ssDouble in Params.Shift)
    then FPressedOrChildPressed := True
    else FPressedOrChildPressed := False;
  if Assigned(OnMouseDown) then
    OnMouseDown(Self, Params);
end;

procedure TLaObjectEh.ProcessParentsMouseDown(Params: TControlMouseButtonParamsEh);
var
  LaHostWinControl: ILaHostWinControl;
  AParent: TFmxObject;
  AParentControl: TControl;
  ParentPos: TPointF;
begin
  LaHostWinControl := LaHost;

  if Params.Handled = True then Exit;

  AParent := Parent;
  ParentPos := TPointF.Create(Params.X, Params.Y);
  ParentPos.X := Position.X + Params.X;
  ParentPos.Y := Position.Y + Params.Y;
  while (AParent <> nil) and (AParent is TControl) do
  begin
    AParentControl := TControl(AParent);
    if (AParentControl is TLaObjectEh) and TLaObjectEh(AParentControl).HitTest then
    begin
      TLaObjectEh(AParentControl).ProcessMouseDown(Params);
      if Params.Handled = True then Break;
    end;

    ParentPos.X := AParentControl.Position.X + ParentPos.X;
    ParentPos.Y := AParentControl.Position.Y + ParentPos.Y;
    AParent := AParent.Parent;

    if AParent = LaHostWinControl.GetObject then
    begin
      LaHostWinControl.ProcessMouseDown(Params);
      Break;
    end;
  end;
end;

procedure TLaObjectEh.MouseMove(Shift: TShiftState; X, Y: Single);
var
  MouseParams: TControlMouseParamsEh;
begin
  inherited MouseMove(Shift, X, Y);

  MouseParams := TControlMouseParamsEh.Create;
  MouseParams.Init(X, Y, Shift, Self);
  try
    if LaHost <> nil then
      LaHost.ProcessPreviewMouseMove(MouseParams);

    if MouseParams.Handled = False then
      InternalProcessMouseMove(MouseParams);
    Cursor := GetCursorAtMousePos(Shift, X, Y);
  finally
    MouseParams.Free;
  end;
end;

procedure TLaObjectEh.InternalProcessMouseMove(MouseParams: TControlMouseParamsEh);
begin
  ProcessMouseMove(MouseParams);
  ProcessParentsMouseMove(MouseParams);
end;

procedure TLaObjectEh.ProcessMouseMove(Params: TControlMouseParamsEh);
begin
end;

procedure TLaObjectEh.ProcessParentsMouseMove(Params: TControlMouseParamsEh);
var
  LaHostWinControl: ILaHostWinControl;
  AParent: TFmxObject;
  AParentControl: TControl;
  ParentPos: TPointF;
begin
  LaHostWinControl := LaHost;

  if Params.Handled = True then Exit;

  AParent := Parent;
  ParentPos := TPointF.Create(Params.X, Params.Y);
  ParentPos.X := Position.X + Params.X;
  ParentPos.Y := Position.Y + Params.Y;
  while (AParent <> nil) and (AParent is TControl) do
  begin
    AParentControl := TControl(AParent);
    if (AParentControl is TLaObjectEh) and TLaObjectEh(AParentControl).HitTest then
    begin
      TLaObjectEh(AParentControl).ProcessMouseMove(Params);
      if Params.Handled = True then Break;
    end;

    ParentPos.X := AParentControl.Position.X + ParentPos.X;
    ParentPos.Y := AParentControl.Position.Y + ParentPos.Y;
    AParent := AParent.Parent;

    if AParent = LaHostWinControl.GetObject then
    begin
      LaHostWinControl.ProcessMouseMove(Params);
      Break;
    end;
  end;
end;

procedure TLaObjectEh.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  MouseParams: TControlMouseButtonParamsEh;
begin
  inherited MouseUp(Button, Shift, X, Y);

  MouseParams := TControlMouseButtonParamsEh.Create;
  MouseParams.Init(Button, X, Y, Shift, Self);
  try
    if LaHost <> nil then
      LaHost.ProcessPreviewMouseUp(MouseParams);

    if MouseParams.Handled = False then
      InternalProcessMouseUp(MouseParams);
  finally
    MouseParams.Free;
  end;
end;

procedure TLaObjectEh.InternalProcessMouseUp(MouseParams: TControlMouseButtonParamsEh);
begin
  ProcessMouseUp(MouseParams);
  ProcessParentsMouseUp(MouseParams);
end;

procedure TLaObjectEh.ProcessParentsMouseUp(Params: TControlMouseButtonParamsEh);
var
  LaHostWinControl: ILaHostWinControl;
  AParent: TFmxObject;
  AParentControl: TControl;
  ParentPos: TPointF;
begin
  LaHostWinControl := LaHost;

  if Params.Handled = True then Exit;

  AParent := Parent;
  ParentPos := TPointF.Create(Params.X, Params.Y);
  ParentPos.X := Position.X + Params.X;
  ParentPos.Y := Position.Y + Params.Y;
  while (AParent <> nil) and (AParent is TControl) do
  begin
    AParentControl := TControl(AParent);
    if (AParentControl is TLaObjectEh) and TLaObjectEh(AParentControl).HitTest then
    begin
      TLaObjectEh(AParentControl).ProcessMouseUp(Params);
      if Params.Handled = True then Break;
    end;

    ParentPos.X := AParentControl.Position.X + ParentPos.X;
    ParentPos.Y := AParentControl.Position.Y + ParentPos.Y;
    AParent := AParent.Parent;

    if AParent = LaHostWinControl.GetObject then
    begin
      LaHostWinControl.ProcessMouseUp(Params);
      Break;
    end;
  end;
end;

procedure TLaObjectEh.ProcessMouseUp(Params: TControlMouseButtonParamsEh);
begin
  FPressedOrChildPressed := False;
end;

procedure TLaObjectEh.MouseClick(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  MouseParams: TControlMouseButtonParamsEh;
  IsClickOk: Boolean;
begin
  IsClickOk := AbsoluteEnabled and PressedOrChildPressed and not DoubleClick and PointInObjectLocal(X, Y);

  inherited MouseClick(Button, Shift, X, Y);

  if IsClickOk then
  begin
    MouseParams := TControlMouseButtonParamsEh.Create;
    MouseParams.Init(Button, X, Y, Shift, Self);
    try
      InternalProcessMouseClick(MouseParams);
    finally
      MouseParams.Free;
    end;
  end;
end;

procedure TLaObjectEh.InternalProcessMouseClick(MouseParams: TControlMouseButtonParamsEh);
begin
  if LaHost <> nil then
    LaHost.ProcessPreviewMouseClick(MouseParams);
  if not (csDestroying in ComponentState) then
    ProcessMouseClick(MouseParams);
  if not (csDestroying in ComponentState) then
    ProcessParentsMouseClick(MouseParams);
end;

procedure TLaObjectEh.ProcessMouseClick(Params: TControlMouseButtonParamsEh);
begin
  FPressedOrChildPressed := False;
  if (Params.Handled = False) and Assigned(OnMouseClick) then
    OnMouseClick(Self, Params);
end;

procedure TLaObjectEh.ProcessParentsMouseClick(Params: TControlMouseButtonParamsEh);
var
  LaHostWinControl: ILaHostWinControl;
  AParent: TFmxObject;
  AParentControl: TControl;
  ParentPos: TPointF;
begin
  LaHostWinControl := LaHost;

  if Params.Handled = True then Exit;

  AParent := Parent;
  ParentPos := TPointF.Create(Params.X, Params.Y);
  ParentPos.X := Position.X + Params.X;
  ParentPos.Y := Position.Y + Params.Y;
  while (AParent <> nil) and (AParent is TControl) do
  begin
    AParentControl := TControl(AParent);

    if (AParentControl is TLaObjectEh) {and TLaObjectEh(AParentControl).HitTestAt(ParentPos)} then
    begin
      TLaObjectEh(AParentControl).ProcessMouseClick(Params);
      if Params.Handled = True then Break;
    end;

    ParentPos.X := AParentControl.Position.X + ParentPos.X;
    ParentPos.Y := AParentControl.Position.Y + ParentPos.Y;
    AParent := AParent.Parent;

    if AParent = LaHostWinControl.GetObject then
    begin
      LaHostWinControl.ProcessMouseClick(Params);
      Break;
    end;
  end;
end;

procedure TLaObjectEh.DblClick;
var
  DblClickParams: TControlParamsEh;
begin
  inherited DblClick;

  DblClickParams := TControlParamsEh.Create;
  DblClickParams.Init(Self);
  try
    InternalProcessDblClick(DblClickParams);
  finally
    DblClickParams.Free;
  end;
end;

procedure TLaObjectEh.InternalProcessDblClick(DblClickParams: TControlParamsEh);
begin
  if LaHost <> nil then
    LaHost.ProcessPreviewDblClick(DblClickParams);
  ProcessDblClick(DblClickParams);
  ProcessParentsDblClick(DblClickParams);
end;

procedure TLaObjectEh.ProcessDblClick(Params: TControlParamsEh);
begin
end;

procedure TLaObjectEh.ProcessParentsDblClick(Params: TControlParamsEh);
var
  LaHostWinControl: ILaHostWinControl;
  AParent: TFmxObject;
  AParentControl: TControl;
begin
  LaHostWinControl := LaHost;

  if Params.Handled = True then Exit;

  AParent := Parent;
  while (AParent <> nil) and (AParent is TControl) do
  begin
    AParentControl := TControl(AParent);

    if (AParentControl is TLaObjectEh) {and TLaObjectEh(AParentControl).HitTestAt(ParentPos)} then
    begin
      TLaObjectEh(AParentControl).ProcessDblClick(Params);
      if Params.Handled = True then Break;
    end;

    AParent := AParent.Parent;

    if AParent = LaHostWinControl.GetObject then
    begin
      LaHostWinControl.ProcessDblClick(Params);
      Break;
    end;
  end;
end;

{$ENDREGION Mouse procedures }

function TLaObjectEh.ShowContextMenu(const ScreenPosition: TPointF): Boolean;
var
  ContextMenuParams:  TControlShowContextMenuParamsEh;
begin
  Result := inherited ShowContextMenu(ScreenPosition);

  if Result = False then
  begin
    ContextMenuParams := TControlShowContextMenuParamsEh.Create;
    ContextMenuParams.Init(ScreenPosition, Self);
    try
      InternalProcessShowContextMenu(ContextMenuParams);
      Result := ContextMenuParams.Handled;
    finally
      ContextMenuParams.Free;
    end;
  end;
end;

procedure TLaObjectEh.InternalProcessShowContextMenu(Params: TControlShowContextMenuParamsEh);
begin
  if LaHost <> nil then
    LaHost.ProcessShowContextMenu(Params);
  if Params.Handled = False then
    ProcessShowContextMenu(Params);
end;

procedure TLaObjectEh.ProcessShowContextMenu(Params: TControlShowContextMenuParamsEh);
begin
end;

function TLaObjectEh.GetCursorAtMousePos(Shift: TShiftState; X, Y: Single): TCursor;
begin
  Result := crDefault;
end;

procedure TLaObjectEh.InternalProcessKeyDown(Params: TLaObjectKeyEventParamsEh);
begin
  if LaHost <> nil then
    LaHost.ProcessPreviewKeyDown(Params);

  ProcessKeyDown(Params);
end;

procedure TLaObjectEh.ProcessKeyDown(Params: TLaObjectKeyEventParamsEh);
begin
end;

procedure TLaObjectEh.SetMaxHeight(const Value: Single);
begin
  if (FMaxHeight <> Value) then
  begin
    FMaxHeight := Value;
  end;
end;

procedure TLaObjectEh.SetMaxWidth(const Value: Single);
begin
  if (FMaxWidth <> Value) then
  begin
    FMaxWidth := Value;
  end;
end;

function TLaObjectEh.GetWidth: Single;
begin
  Result := FSize.Width;
end;

procedure TLaObjectEh.SetWidth(const Value: Single);
begin
  if FSize.Width <> Value then
  begin
    FSize.Width := Value;
    LayoutChanged();
  end;
end;

function TLaObjectEh.GetHeight: Single;
begin
  Result := FSize.Height;
end;

procedure TLaObjectEh.SetHeight(const Value: Single);
begin
  if FSize.Height <> Value then
  begin
    FSize.Height  := Value;
    LayoutChanged();
  end;
end;

function TLaObjectEh.GetLaHost: ILaHostWinControl;
var
  LaHostWinControl: ILaHostWinControl;
  AParent: TFmxObject;
begin
  if (FLaHost <> nil) then
  begin
    Result := FLaHost;
    Exit;
  end;

  AParent := Parent;
  while AParent <> nil do
  begin
    if (Supports(AParent, ILaHostWinControl, LaHostWinControl)) then
    begin
      Result := LaHostWinControl;
      FLaHost := Result;
      Break;
    end;
    AParent := AParent.Parent;
  end;
end;

procedure TLaObjectEh.SetDataContext(const Value: IDataContextEh);

  procedure ResetChildDataContent(AParent: TLaObjectEh);
  var
    I: Integer;
    Child: TLaObjectEh;
  begin
    for I := 0 to AParent.ChildrenCount - 1 do
    begin
      if AParent.Children[I] is TLaObjectEh then
      begin
        Child := TLaObjectEh(AParent.Children[I]);
        if (Child.FDataContext = nil) then
        begin
          Child.InternalLayoutChanged;
          ResetChildDataContent(Child);
        end;
      end;
    end;
  end;

begin
  if FDataContext <> Value then
  begin
    if FDataContext <> nil then
      FDataContext.GetComponent.RemoveFreeNotification(Self);
    FDataContext := Value;
    if FDataContext <> nil then
      FDataContext.GetComponent.FreeNotification(Self);
    ResetChildDataContent(Self);
    LayoutChanged;
  end;
end;

procedure TLaObjectEh.UpdateDataContent;
begin
  if FIsQueryLayoutNeeded = True then
    DoUpdateDataContent;
end;

procedure TLaObjectEh.DoUpdateDataContent;
begin

end;

procedure TLaObjectEh.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = TOperation.opRemove) and
     (FDataContext <> nil) and
     (FDataContext.GetComponent() = AComponent) then
  begin
    FDataContext := nil;
  end;
end;

procedure TLaObjectEh.SetVertAlignment(const Value: TLaVertAlignmentEh);
begin
  if FVertAlignment <> Value then
  begin
    FVertAlignment := Value;
    LayoutChanged;
  end;
end;

procedure TLaObjectEh.SetHorzAlignment(const Value: TLaHorzAlignmentEh);
begin
  if FHorzAlignment <> Value then
  begin
    FHorzAlignment := Value;
    LayoutChanged;
  end;
end;

function TLaObjectEh.GetActualHeight: Single;
begin
  Result := inherited Height;
end;

function TLaObjectEh.GetActualLeft: Single;
begin
  Result := inherited Position.X;
end;

function TLaObjectEh.GetActualTop: Single;
begin
  Result := inherited Position.Y;
end;

function TLaObjectEh.GetActualWidth: Single;
begin
  Result := inherited Width;
end;

procedure TLaObjectEh.InternalSetPosition(const Value: TSizeF);
begin
  if inherited Position.Point <> Value then
  begin
    inherited Position.SetPointNoChange(Value);
    if IsUpdating then
      FMatrixChangeIsNeeded := True
    else
      DoMatrixChanged(Self);
  end;
end;

procedure TLaObjectEh.InternalSetSize(const Value: TSizeF);
begin
  if inherited Size.Size <> Value then
  begin
    inherited Size.SetSizeWithoutNotification(Value);
    if IsUpdating then
      FMatrixChangeIsNeeded := True
    else
      DoMatrixChanged(Self);
  end;
end;

procedure TLaObjectEh.DoEndUpdate;
begin
  if FMatrixChangeIsNeeded = True then
  begin
    DoMatrixChanged(Self);
    FMatrixChangeIsNeeded := False;
  end;
end;

function TLaObjectEh.IsMouseCaptured: Boolean;
begin
  if (Root <> nil) and
     (Root.Captured <> nil) and
     (Root.Captured.GetObject = Self)
  then
    Result := True
  else
    Result := False;
end;

procedure TLaObjectEh.PaddingChanged();
begin
  LayoutChanged;
end;

{$IFDEF EH_LIB_37} // { RAD Studio 13 }
procedure TLaObjectEh.MarginsChanged();
begin
  LayoutChanged;
end;
{$ENDIF}

{$ENDREGION 'TLaObjectEh'}

{$REGION 'TLaHostWinControl'}

{ TLaHostWinControl }

constructor TLaHostWinControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ClipChildren := True;
end;

destructor TLaHostWinControl.Destroy;
begin
  inherited Destroy;
end;

procedure TLaHostWinControl.UpdateLayout;
begin
  QueryPerformLayout(Size.Size);
end;

procedure TLaHostWinControl.DoRealign;
begin
  inherited DoRealign;
end;

function TLaHostWinControl.QueryPerformLayout(QuerySize: TSizeF): TSizeF;
var
  ARectSize: TSizeF;
begin
  ARectSize := Size.Size;
  LaObject.SetLayoutChangedForAll;
  LaObject.QueryLayout(ARectSize, Canvas);
  Result := LaObject.PerformLayout(TRectF.Create(0, 0, ARectSize.Width, ARectSize.Height),
                                   Canvas,
                                   TRectF.Create(Single.Nan, Single.Nan, Single.Nan, Single.Nan));
  LayoutUpdated();
end;

procedure TLaHostWinControl.LayoutUpdated();
begin

end;

procedure TLaHostWinControl.Paint;
begin
//  CanvasFillRect(Canvas, TRectF.Create(0, 0, Width, Height), 0.8);
end;

function TLaHostWinControl.GetLaObject: TLaObjectEh;
begin
  Result := TLaObjectEh(Children[0]);
end;

procedure TLaHostWinControl.SetLaObjectProp(const Value: TLaObjectEh);
begin
  Value.Parent := Self;
end;

procedure TLaHostWinControl.ProcessPreviewMouseMove(Params: TControlMouseParamsEh);
begin
end;

procedure TLaHostWinControl.ProcessPreviewMouseUp(Params: TControlMouseButtonParamsEh);
begin
end;

procedure TLaHostWinControl.ProcessPreviewMouseClick(Params: TControlMouseButtonParamsEh);
begin
end;

procedure TLaHostWinControl.ProcessMouseClick(Params: TControlMouseButtonParamsEh);
begin
end;

procedure TLaHostWinControl.ProcessDblClick(Params: TControlParamsEh);
begin
end;

procedure TLaHostWinControl.ProcessShowContextMenu(Params: TControlShowContextMenuParamsEh);
begin
end;

procedure TLaHostWinControl.ProcessMouseDown(Params: TControlMouseButtonParamsEh);
begin
end;

procedure TLaHostWinControl.ProcessMouseMove(Params: TControlMouseParamsEh);
begin
end;

procedure TLaHostWinControl.ProcessMouseUp(Params: TControlMouseButtonParamsEh);
begin
end;

procedure TLaHostWinControl.ProcessPreviewDblClick(Params: TControlParamsEh);
begin

end;

procedure TLaHostWinControl.ProcessPreviewKeyDown(Params: TLaObjectKeyEventParamsEh);
begin
end;

procedure TLaHostWinControl.ProcessPreviewMouseDown(Params: TControlMouseButtonParamsEh);
begin
end;

procedure TLaHostWinControl.ProcessPreviewMouseEnter(Params: TControlParamsEh);
begin
end;

procedure TLaHostWinControl.ProcessPreviewMouseLeave(Params: TControlParamsEh);
begin
end;

procedure TLaHostWinControl.Invalidate();
begin
  Repaint;
end;

procedure TLaHostWinControl.LayoutChanged(LaObject: TLaObjectEh);
begin
end;

{$ENDREGION 'TLaHostWinControl'}

{$REGION 'TLaHintInfoEventParamsEh'}

{ TLaHintInfoEventParamsEh }

procedure TLaHintInfoEventParamsEh.InitParams(ALaObject: TLaObjectEh);
begin
  FHandled := False;
  FLaObject := ALaObject;
  FHintText := '';
  FHintObject := nil;
  FHideTimeout := 0;
end;

{ TLaObjectKeyEventParamsEh }

procedure TLaObjectKeyEventParamsEh.Init(AKey: Word; AKeyChar: WideChar;
  AShift: TShiftState; ASrcObject: TObject);
begin
  FKey := AKey;
  FKeyChar := AKeyChar;
  FShift := AShift;
  FSrcObject := ASrcObject;
end;

{$ENDREGION 'TLaHintInfoEventParamsEh'}

end.
