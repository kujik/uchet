{*******************************************************}
{                                                       }
{                      EhLib.Fmx 12.1                   }
{                   EhLibFmx.LaControls                 }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.LaControls;

interface

{$I ..\Incl\EhLib.Inc}
{$SCOPEDENUMS ON}

{$REGION 'uses'}
uses
  Types, Classes,
  SysUtils, Variants,
  {$IFDEF EH_LIB_17} System.UITypes, {$ENDIF}
  Generics.Collections, System.RTTI,
  FMX.Objects, FMX.MultiResBitmap,
  EhLibUtils,
  DBUtilsEh,
  EhLib.TableLinks,
  EhLibFmx.LaObjects,
  EhLibFmx.ToolControls,
  FMX.TextLayout, FMX.ImgList, FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics;
{$ENDREGION 'uses'}

type
  TLaControlEh = class;
  TLaTextBlockEh = class;
  TLaImageEh = class;
  TLaControlBordersEh = class;
  TLaButtonBackEh = class;
  TLaButtonEh = class;

  TLaFormattedTextRangesEh = class;

{ TInTextLinkClickParamsEh }

  TInTextLinkClickParamsEh = class(TPersistent)
  private
    FTextRangeIndex: Integer;
    FControl: TLaControlEh;
    FLinkText: String;
    FOriginalEventParams: TControlMouseButtonParamsEh;
    FHandled: Boolean;
  public
    procedure Init(AControl: TLaControlEh; ATextRangeIndex: Integer; ALinkText: String; AOriginalEventParams: TControlMouseButtonParamsEh);

    property Control: TLaControlEh read FControl;
    property TextRangeIndex: Integer read FTextRangeIndex;
    property LinkText: String read FLinkText;
    property OriginalEventParams: TControlMouseButtonParamsEh read FOriginalEventParams;
    property Handled: Boolean read FHandled write FHandled;
  end;

  TInTextLinkClickEventEh = procedure(Sender: TObject; Params: TInTextLinkClickParamsEh) of object;

{ TLaControlBorderEh }

  TLaControlBorderEh = class(TPersistent)
  private
    FThickness: Single;
    FColor: TAlphaColor;
    FOwner: TLaControlBordersEh;
    procedure SetColor(const Value: TAlphaColor);
    procedure SetThickness(const Value: Single);
  protected
  public
    constructor Create(AOwner: TLaControlBordersEh); virtual;
    procedure Assign(Source: TPersistent); override;
    property Owner: TLaControlBordersEh read FOwner;
  published
    property Color: TAlphaColor read FColor write SetColor;
    property Thickness: Single read FThickness write SetThickness;
  end;

{ TLaControlBorderEh }

  TLaControlBordersEh = class(TPersistent)
  private
    FRight: TLaControlBorderEh;
    FBottom: TLaControlBorderEh;
    FTop: TLaControlBorderEh;
    FLeft: TLaControlBorderEh;
    FControl: TLaControlEh;
    FCorners: TCorners;
    FRoundCornerRadius: Single;

    procedure SetBottom(const Value: TLaControlBorderEh);
    procedure SetLeft(const Value: TLaControlBorderEh);
    procedure SetRight(const Value: TLaControlBorderEh);
    procedure SetTop(const Value: TLaControlBorderEh);
  protected
    procedure BoundChanged(ABound: TLaControlBorderEh; AffectsLayout: Boolean);

  public
    constructor Create(AControl: TLaControlEh); virtual;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

    procedure SetThicknesses(ALeft, ATop, ARight, ABottom: Integer);
    procedure SetColors(ALeft, ATop, ARight, ABottom: TAlphaColor);

  published
    property Left: TLaControlBorderEh read FLeft write SetLeft;
    property Top: TLaControlBorderEh read FTop write SetTop;
    property Right: TLaControlBorderEh read FRight write SetRight;
    property Bottom: TLaControlBorderEh read FBottom write SetBottom;
    property RoundCorners: TCorners read FCorners write FCorners;
    property RoundCornerRadius: Single read FRoundCornerRadius write FRoundCornerRadius;
  end;

{ TLaControlEh }

  TLaControlEh = class(TLaObjectEh)
  private
    FBorders: TLaControlBordersEh;
    FFont: TFont;
    FParentFont: Boolean;
    FFontColor: TAlphaColor;
    FParentFontColor: Boolean;
    FFill: TBrush;

    function IsFontStored: Boolean;
    procedure SetFont(const Value: TFont);
    procedure SetParentFont(const Value: Boolean);
    procedure FontChanged(Sender: TObject);

    procedure SetBorders(const Value: TLaControlBordersEh);
    procedure SetFontColor(const Value: TAlphaColor);
    procedure UpdateFontColor;
    procedure SetParentFontColor(const Value: Boolean);
    procedure SetFill(const Value: TBrush);
  protected
    procedure ParentChanged; override;

    procedure FillChanged(Sender: TObject); virtual;
    procedure BorderThicknessChanged;
    procedure UpdateFont;
    procedure ParentDependenciesChanged; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure Draw(const ARect: TRectF; ACanvas: TCanvas); override;

    procedure DrawClientBackground(const AClientRect: TRectF; ACanvas: TCanvas); overload; virtual;
    procedure DrawClientForeground(const AClientRect: TRectF; ACanvas: TCanvas); overload; virtual;
    procedure DrawBorder(const ABorderRect: TRectF; ACanvas: TCanvas); overload; virtual;

    function DoQueryLayout(const AQuerySize: TSizeF; ACanvas: TCanvas): TSizeF; overload; override;
    function DoQueryLayoutClientArea(const QuerySize: TSizeF; ACanvas: TCanvas): TSizeF; overload; virtual;

    function DoPerformLayout(const PerfSize: TSizeF; ACanvas: TCanvas): TSizeF; overload; override;
    function DoPerformLayoutClientArea(const ClientRect: TRectF; ACanvas: TCanvas): TSizeF; overload; virtual;

    property Borders: TLaControlBordersEh read FBorders write SetBorders;

    property Font: TFont read FFont write SetFont stored IsFontStored;
    property FontColor: TAlphaColor read FFontColor write SetFontColor;
    property ParentFont: Boolean read FParentFont write SetParentFont default True;
    property ParentFontColor: Boolean read FParentFontColor write SetParentFontColor default True;

    property Fill: TBrush read FFill write SetFill;
  end;

{ THighlightTextRegion }

  THighlightTextRegion = record
    Range: TTextRange;
    Color: TAlphaColor;
  end;

{ TLaFormattedTextRangeEh }

  TLaFormattedTextRangeEh = class(TPersistent)
  private
    FFont: TFont;
    FParentFont: Boolean;
    FIsHyperLink: Boolean;
    FTag: NativeInt;
    FOwner: TLaTextBlockEh;
    FTextPos: Integer;
    FTextLength: Integer;
    FFontColor: TAlphaColor;
    FHyperlinkFont: TFont;
    FHyperlinkHotFont: TFont;

    function IsFontStored: Boolean;

    procedure SetFont(Value: TFont);
    procedure SetParentFont(Value: Boolean);
    procedure FontChanged(Sender: TObject);
    procedure UpdateFont;

  protected
    function GetHyperlinkFont: TFont;
    function GetHyperlinkHotFont: TFont;
    procedure ParentChanged(); virtual;
    procedure NotifyPropChanged; virtual;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    function Equals(Obj: TObject): Boolean; override;

  published
    property Font: TFont read FFont write SetFont stored IsFontStored;
    property ParentFont: Boolean read FParentFont write SetParentFont default True;
    property TextPos: Integer read FTextPos write FTextPos;
    property TextLength: Integer read FTextLength write FTextLength;
    property FontColor: TAlphaColor read FFontColor write FFontColor;
    property IsHyperLink: Boolean read FIsHyperLink write FIsHyperLink;
    property Tag: NativeInt read FTag write FTag default 0;
  end;

{ TLaFormattedTextRangesEh }

  TLaFormattedTextRangesEh = class(TPersistent)
  private
    FTextBlock: TLaTextBlockEh;
    FRangeList: TObjectList<TLaFormattedTextRangeEh>;
    function GetItem(Index: Integer): TLaFormattedTextRangeEh;
    function GetCount: Integer;
  public
    constructor Create(ATextBlock: TLaTextBlockEh);
    destructor Destroy; override;

    procedure AddTextRange(ATextPos, ATextLength: Integer; AFont: TFont; AFontColor: TAlphaColor; AIsHyperLink: Boolean); overload;
    procedure AddTextRange(ATextPos, ATextLength: Integer; AIsHyperLink: Boolean); overload;
    procedure Add(ARange: TLaFormattedTextRangeEh);
    procedure AddRange(const Collection: IEnumerable<TLaFormattedTextRangeEh>); overload;
    procedure AddRange(const Collection: TEnumerable<TLaFormattedTextRangeEh>); overload;
    procedure Clear;

    property Item[Index: Integer]: TLaFormattedTextRangeEh read GetItem; default;
    property Count: Integer read GetCount;
  end;

{ TLaTextBlockEh }

  TLaTextBlockEh = class(TLaControlEh)
  private
    class var FLinkTextColor: TAlphaColor;
    class var FLinkTextStyle: TFontStyles;
    class var FLinkHotTextColor: TAlphaColor;
    class var FLinkHotTextStyle: TFontStyles;

  private
    FCalcSizeTextLayout: TTextLayout;
    FFieldName: String;
    FHighlightRegions: TList<THighlightTextRegion>;
    FLinkIsActive: Boolean;
    FText: String;
    FTextAlign: TTextAlign;
    FTrimming: TTextTrimming;
    FWordWrap: Boolean;
    FFormattedTextRanges: TLaFormattedTextRangesEh;
    FLinkRegionMouseOverIndex: Integer;
    FLinkRegions: TList<TRegion>;
    FOnInTextLinkClick: TInTextLinkClickEventEh;

    function CalcTextSize(AreaWidth: Single; ACanvas: TCanvas): TSizeF; overload;

    procedure HighlightRegionsChanged(Sender: TObject; const Item: THighlightTextRegion; Action: TCollectionNotification);
    procedure SetFieldName(const Value: String);
    procedure SetLinkIsActive(const Value: Boolean);
    procedure SetText(const Value: String);
    procedure SetTextAlign(const Value: TTextAlign);
    procedure SetTrimming(const Value: TTextTrimming);
    procedure SetWordWrap(const Value: Boolean);
    procedure InitTextLayout(ATextLayout: TTextLayout; AMaxSize: TPointF; ACanvas: TCanvas);

  protected
    function GetCursorAtMousePos(Shift: TShiftState; X, Y: Single): TCursor; override;

    procedure MouseEnter(Params: TControlParamsEh); override;
    procedure MouseLeave(Params: TControlParamsEh); override;
    procedure ProcessMouseMove(Params: TControlMouseParamsEh); override;
    procedure ProcessMouseDown(Params: TControlMouseButtonParamsEh); override;

    function FormatDisplayValue(const AValue: TValue): String; virtual;

    procedure UpdateText; virtual;
    procedure TextLinkClick(AFormattedTextRange: TLaFormattedTextRangeEh; AFormattedTextRangeIndex: Integer; AOriginalEventParams: TControlMouseButtonParamsEh); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    class constructor Create;
    class destructor Destroy;

    procedure Assign(Source: TPersistent); override;
    procedure DrawClientForeground(const AClientRect: TRectF; ACanvas: TCanvas); overload; override;
    procedure DrawHighlightRegions(const AClientRect: TRectF; ATextLayout: TTextLayout); virtual;

    function DoQueryLayoutClientArea(const QuerySize: TSizeF; ACanvas: TCanvas): TSizeF; override;
    function DoPerformLayoutClientArea(const ClientRect: TRectF; ACanvas: TCanvas): TSizeF; override;

    function GetLinkRegionIndexInPos(APos: TPointF): Integer;

    class function GetCustomURLDetectedRanges(AText: String; UrlStartTexts: array of String): TArray<TTextRange>;
    class function GetURLDetectedRanges(AText: String): TArray<TTextRange>;
    
    property LinkIsActive: Boolean read FLinkIsActive write SetLinkIsActive;

    class property HyperlinkTextColor: TAlphaColor read FLinkTextColor;
    class property HyperlinkTextStyle: TFontStyles read FLinkTextStyle;
    class property HyperlinkHotTextColor: TAlphaColor read FLinkHotTextColor;
    class property HyperlinkHotTextStyle: TFontStyles read FLinkHotTextStyle;

  published
    property FieldName: String read FFieldName write SetFieldName;
    property HighlightRegions: TList<THighlightTextRegion> read FHighlightRegions;
    property Text: String read FText write SetText;
    property TextAlign: TTextAlign read FTextAlign write SetTextAlign default TTextAlign.Leading;
    property Trimming: TTextTrimming read FTrimming write SetTrimming default TTextTrimming.None;
    property WordWrap: Boolean read FWordWrap write SetWordWrap;
    property FormattedTextRanges: TLaFormattedTextRangesEh read FFormattedTextRanges;

    property OnInTextLinkClick: TInTextLinkClickEventEh read FOnInTextLinkClick write FOnInTextLinkClick;
  end;

{ TLaButtonEh }

  TLaButtonEh = class(TLaControlEh)
  private
    FButtonBack: TLaButtonBackEh;
    FLayoutPanel: TLaControlEh;
    FContent: TFmxObject;

    function GetButtonBackVisible: Boolean;
    function GetContent: TFmxObject;
    function GetIsPressed: Boolean;
    function GetStaysPressed: Boolean;

    procedure SetButtonBackVisible(const Value: Boolean);
    procedure SetContent(const Value: TFmxObject);
    procedure SetIsPressed(const Value: Boolean);
    procedure SetStaysPressed(const Value: Boolean);

  protected
    procedure ButtonBackMouseDown(ButtonBack: TLaButtonBackEh; Button: TMouseButton; Shift: TShiftState; X, Y: Single); virtual;
    procedure ProcessMouseClick(Params: TControlMouseButtonParamsEh); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function DoQueryLayoutClientArea(const QuerySize: TSizeF; ACanvas: TCanvas): TSizeF; override;
    function DoPerformLayoutClientArea(const ClientRect: TRectF; ACanvas: TCanvas): TSizeF; override;

    property Content: TFmxObject read GetContent write SetContent;
    property IsButtonBackVisible: Boolean read GetButtonBackVisible write SetButtonBackVisible default True;

    property StaysPressed: Boolean read GetStaysPressed write SetStaysPressed;
    property IsPressed: Boolean read GetIsPressed write SetIsPressed;
  published
  end;

{ TLaButtonBackEh }

  TLaButtonBackEh = class(TLaControlEh)
  private
    FPressing: Boolean;
    FIsPressed: Boolean;
    FStaysPressed: Boolean;
    FRepeat: Boolean;
    FRepeatTimer: TTimer;
    FLaButton: TLaButtonEh;
    procedure SetIsPressed(const Value: Boolean);
    function IsPressedStored: Boolean;
    procedure SetStaysPressed(const Value: Boolean);

  protected
    function GetDefaultStyleLookupName: string; override;
    function GetStyleResourceName(): String; override;
//    function GetDefaultStyleLookupName: string;
//    function GetStyleResourceName(): String;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;

    procedure ApplyTriggers; virtual;
    procedure ToggleStaysPressed; virtual;
    procedure DoRepeatDelayTimer(Sender: TObject);
    procedure DoRepeatTimer(Sender: TObject);
    procedure RestoreButtonState; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property StaysPressed: Boolean read FStaysPressed write SetStaysPressed stored IsPressedStored default False;
    property IsPressed: Boolean read FIsPressed write SetIsPressed default False;
  published
  end;

{ TLaImageEh }

  TLaImageEh = class(TLaControlEh)
  private
    FImageList: TCustomImageList;
    FImageIndex: Integer;
    FFieldName: String;
    FImage: TImage;

    procedure SetImageList(const Value: TCustomImageList);
    procedure SetImageIndex(const Value: Integer);
    procedure SetFieldName(const Value: String);
    function GetFitSize(ImageSize: TSizeF; const RenderSize: TSizeF): TSizeF;
    procedure SetBitmap(const Value: TBitmap);
    function GetPictureActualSize: TSizeF;
    function GetBitmap: TBitmap;
    procedure SetWrapMode(const Value: TImageWrapMode);
    function GetWrapMode: TImageWrapMode;

  protected
    procedure DoUpdateDataContent; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    function DoQueryLayoutClientArea(const QuerySize: TSizeF; ACanvas: TCanvas): TSizeF; override;
    function DoPerformLayoutClientArea(const ClientRect: TRectF; ACanvas: TCanvas): TSizeF; override;

    procedure UpdateImage;

    function GetPictureForField(AFieldName: String): TBitmap;

  published
    property ImageList: TCustomImageList read FImageList write SetImageList;
    property ImageIndex: Integer read FImageIndex write SetImageIndex;
    property FieldName: String read FFieldName write SetFieldName;
    property Bitmap: TBitmap read GetBitmap write SetBitmap;
    property WrapMode: TImageWrapMode read GetWrapMode write SetWrapMode default TImageWrapMode.Place;
  end;

implementation

{$REGION 'uses'}
uses System.Math, EhLibFmx.LaPanels;
{$ENDREGION 'uses'}

procedure CanvasFillRect(Canvas: TCanvas; const ARect: TRectF; const AOpacity: Single); overload;
begin
  Canvas.FillRect(ARect, 0, 0, [], AOpacity);
end;

procedure CanvasFillRect(Canvas: TCanvas; const ARect: TRectF; const AOpacity: Single; const ABrush: TBrush); overload;
begin
  Canvas.FillRect(ARect, 0, 0, [], AOpacity, ABrush);
end;

{$REGION 'TLaControlBorderEh'}

constructor TLaControlBorderEh.Create(AOwner: TLaControlBordersEh);
begin
  FOwner := AOwner;
end;

procedure TLaControlBorderEh.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
end;

procedure TLaControlBorderEh.SetColor(const Value: TAlphaColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    FOwner.BoundChanged(Self, False);
  end;
end;

procedure TLaControlBorderEh.SetThickness(const Value: Single);
begin
  if FThickness <> Value then
  begin
    FThickness := Value;
    FOwner.BoundChanged(Self, True);
  end;
end;

{$ENDREGION 'TLaControlBorderEh'}

{$REGION 'TLaControlBordersEh'}

constructor TLaControlBordersEh.Create(AControl: TLaControlEh);
begin
  inherited Create;
  FControl := AControl;
  FRight := TLaControlBorderEh.Create(Self);
  FBottom := TLaControlBorderEh.Create(Self);
  FTop := TLaControlBorderEh.Create(Self);
  FLeft := TLaControlBorderEh.Create(Self);
  FCorners := [TCorner.TopLeft, TCorner.TopRight, TCorner.BottomLeft, TCorner.BottomRight];
  FRoundCornerRadius := 0;
end;

destructor TLaControlBordersEh.Destroy;
begin
  FreeAndNil(FRight);
  FreeAndNil(FBottom);
  FreeAndNil(FTop);
  FreeAndNil(FLeft);

  inherited Destroy;
end;

procedure TLaControlBordersEh.BoundChanged(ABound: TLaControlBorderEh; AffectsLayout: Boolean);
begin
  if AffectsLayout = True then
    FControl.LayoutChanged
  else
    FControl.Invalidate;
end;

procedure TLaControlBordersEh.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
end;

procedure TLaControlBordersEh.SetBottom(const Value: TLaControlBorderEh);
begin
  FBottom.Assign(Value);
end;

procedure TLaControlBordersEh.SetLeft(const Value: TLaControlBorderEh);
begin
  FLeft.Assign(Value);
end;

procedure TLaControlBordersEh.SetRight(const Value: TLaControlBorderEh);
begin
  FRight.Assign(Value);
end;

procedure TLaControlBordersEh.SetTop(const Value: TLaControlBorderEh);
begin
  FTop.Assign(Value);
end;

procedure TLaControlBordersEh.SetThicknesses(ALeft, ATop, ARight, ABottom: Integer);
begin
  Left.Thickness := ALeft;
  Top.Thickness := ATop;
  Right.Thickness := ARight;
  Bottom.Thickness := ABottom;
end;

procedure TLaControlBordersEh.SetColors(ALeft, ATop, ARight, ABottom: TAlphaColor);
begin
  Left.Color := ALeft;
  Top.Color := ATop;
  Right.Color := ARight;
  Bottom.Color := ABottom;
end;

{$ENDREGION 'TLaControlBordersEh'}

{$REGION 'TLaControlEh'}

constructor TLaControlEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FFont := TFont.Create;
  FFont.OnChanged := FontChanged;
  FParentFont := True;

  FFill := TBrush.Create(TBrushKind.None, TAlphaColorRec.Null);
  FFill.OnChanged := FillChanged;

  FFontColor := TAlphaColorRec.Black;
  FParentFontColor := True;

  FBorders := TLaControlBordersEh.Create(Self);
end;

destructor TLaControlEh.Destroy;
begin
  FreeAndNil(FBorders);
  FreeAndNil(FFont);
  FreeAndNil(FFill);
  inherited Destroy;
end;

procedure TLaControlEh.Draw(const ARect: TRectF; ACanvas: TCanvas);
var
  ABorderRect: TRectF;
  AClientRect: TRectF;
begin
  ABorderRect := ARect;

  AClientRect := TRectF.Create(ABorderRect.Left + Borders.Left.Thickness,
                      ABorderRect.Top + Borders.Top.Thickness,
                      ABorderRect.Right - Borders.Right.Thickness,
                      ABorderRect.Bottom - Borders.Bottom.Thickness);
  DrawClientBackground(AClientRect, ACanvas);

  DrawBorder(ABorderRect, ACanvas);

  AClientRect := TRectF.Create(ABorderRect.Left + Padding.Left,
                      ABorderRect.Top + Padding.Top,
                      ABorderRect.Right - Padding.Right,
                      ABorderRect.Bottom - Padding.Bottom);
  DrawClientForeground(AClientRect, ACanvas);
end;

procedure TLaControlEh.DrawBorder(const ABorderRect: TRectF; ACanvas: TCanvas);
var
  Br: TRectF;
  Br1: TRectF;
  BrdRc: TRectF;
  Thickness: Single;

  function GetDrawingShapeRect(const SrcRect: TRectF; AStroke: TStrokeBrush): TRectF;
  const
    MinRectAreaSize = 0.01;
  begin
    Result := SrcRect;

    if Result.Width < AStroke.Thickness then
    begin
      AStroke.Thickness := Min(Result.Width, Result.Height);
      Result.Left := (Result.Right + Result.Left) * 0.5;
      Result.Right := Result.Left + MinRectAreaSize;
    end
    else
      Result.Inflate(-AStroke.Thickness * 0.5, 0);

    if Result.Height < AStroke.Thickness then
    begin
      AStroke.Thickness := Min(Result.Width, Result.Height);
      Result.Top := (Result.Bottom + Result.Top) * 0.5;
      Result.Bottom := Result.Top + MinRectAreaSize;
    end
    else
      Result.Inflate(0, -AStroke.Thickness * 0.5);
  end;

  procedure DrawQuadrant(const ABorderRect: TRectF; ACorner: TCorner; AColor: TAlphaColor; AThickness: Single);
  var
    Path: TPathData;
    X1, X2, Y1, Y2: Single;
    R: TRectF;
    CornerRadius: Single;
  begin
    ACanvas.Stroke.Kind := TBrushKind.Solid;
    ACanvas.Stroke.Color := AColor;
    ACanvas.Stroke.Thickness := AThickness;
    CornerRadius := Borders.RoundCornerRadius;

    R := GetDrawingShapeRect(ABorderRect, ACanvas.Stroke);
    X1 := CornerRadius;
    if RectWidth(R) - (X1 * 2) < 0 then
      X1 := RectWidth(R) / 2;
    X2 := CornerRadius * CurveKappaInv;
    Y1 := CornerRadius;
    if RectHeight(R) - (Y1 * 2) < 0 then
      Y1 := RectHeight(R) / 2;
    Y2 := CornerRadius * CurveKappaInv;
    Path := TPathData.Create;
    if ACorner = TCorner.TopLeft then
    begin
      Path.MoveTo(PointF(R.Left, R.Top + Y1));
      Path.CurveTo(PointF(R.Left, R.Top + (Y2)), PointF(R.Left + X2, R.Top), PointF(R.Left + X1, R.Top));
    end;
    if ACorner = TCorner.TopRight then
    begin
      Path.MoveTo(PointF(R.Right - X1, R.Top));
      Path.CurveTo(PointF(R.Right - X2, R.Top), PointF(R.Right, R.Top + (Y2)), PointF(R.Right, R.Top + Y1));
    end;
    if ACorner = TCorner.BottomRight then
    begin
      Path.MoveTo(PointF(R.Right, R.Bottom - Y1));
      Path.CurveTo(PointF(R.Right, R.Bottom - (Y2)), PointF(R.Right - X2, R.Bottom), PointF(R.Right - X1, R.Bottom));
    end;
    if ACorner = TCorner.BottomLeft then
    begin
      Path.MoveTo(PointF(R.Left + X1, R.Bottom));
      Path.CurveTo(PointF(R.Left + X2, R.Bottom), PointF(R.Left, R.Bottom - (Y2)), PointF(R.Left, R.Bottom - Y1));
    end;

    ACanvas.DrawPath(Path, AbsoluteOpacity);
    Path.Free;
  end;

begin
  Br := ABorderRect;
  if Borders.Top.Thickness > 0 then
  begin
    Br1 := Br;
    if (Borders.RoundCornerRadius > 0) and (TCorner.TopLeft in Borders.RoundCorners) then
      Br1.Left := Br1.Left + Borders.RoundCornerRadius;
    if (Borders.RoundCornerRadius > 0) and (TCorner.TopRight in Borders.RoundCorners) then
      Br1.Right:= Br1.Right - Borders.RoundCornerRadius;
    ACanvas.Fill.Color := Borders.Top.Color;
    BrdRc := RectF(Br1.Left, Br1.Top, Br1.Right, Br1.Top + Borders.Top.Thickness);
    CanvasFillRect(ACanvas, BrdRc, AbsoluteOpacity);
  end;

  if Borders.Right.Thickness > 0 then
  begin
    Br1 := Br;
    if (Borders.RoundCornerRadius > 0) and (TCorner.TopRight in Borders.RoundCorners) then
      Br1.Top := Br1.Top + Borders.RoundCornerRadius;
    if (Borders.RoundCornerRadius > 0) and (TCorner.BottomRight in Borders.RoundCorners) then
      Br1.Bottom := Br1.Bottom - Borders.RoundCornerRadius;
    ACanvas.Fill.Color := Borders.Right.Color;
    BrdRc := RectF(Br1.Right - Borders.Right.Thickness, Br1.Top, Br1.Right, Br1.Bottom);
    CanvasFillRect(ACanvas, BrdRc, AbsoluteOpacity);
  end;

  if Borders.Bottom.Thickness > 0 then
  begin
    Br1 := Br;
    if (Borders.RoundCornerRadius > 0) and (TCorner.BottomLeft in Borders.RoundCorners) then
      Br1.Left := Br1.Left + Borders.RoundCornerRadius;
    if (Borders.RoundCornerRadius > 0) and (TCorner.BottomRight in Borders.RoundCorners) then
      Br1.Right:= Br1.Right - Borders.RoundCornerRadius;
    ACanvas.Fill.Color := Borders.Bottom.Color;
    BrdRc := RectF(Br1.Left, Br1.Bottom - Borders.Bottom.Thickness, Br1.Right, Br1.Bottom);
    CanvasFillRect(ACanvas, BrdRc, AbsoluteOpacity);
  end;

  if Borders.Left.Thickness > 0 then
  begin
    Br1 := Br;
    if (Borders.RoundCornerRadius > 0) and (TCorner.TopLeft in Borders.RoundCorners) then
      Br1.Top := Br1.Top + Borders.RoundCornerRadius;
    if (Borders.RoundCornerRadius > 0) and (TCorner.BottomLeft in Borders.RoundCorners) then
      Br1.Bottom := Br1.Bottom - Borders.RoundCornerRadius;
    ACanvas.Fill.Color := Borders.Left.Color;
    BrdRc := RectF(Br1.Left, Br1.Top, Br1.Left + Borders.Left.Thickness, Br1.Bottom);
    CanvasFillRect(ACanvas, BrdRc, AbsoluteOpacity);
  end;

  if (Borders.RoundCornerRadius > 0) then
  begin
    if (TCorner.TopLeft in Borders.RoundCorners) then
    begin
      Thickness := Max(Borders.Top.Thickness, Borders.Left.Thickness);
      DrawQuadrant(ABorderRect, TCorner.TopLeft, Borders.Top.Color, Thickness);
    end;
    if (TCorner.TopRight in Borders.RoundCorners) then
    begin
      Thickness := Max(Borders.Top.Thickness, Borders.Right.Thickness);
      DrawQuadrant(ABorderRect, TCorner.TopRight, Borders.Top.Color, Thickness);
    end;
    if (TCorner.BottomRight in Borders.RoundCorners) then
    begin
      Thickness := Max(Borders.Bottom.Thickness, Borders.Right.Thickness);
      DrawQuadrant(ABorderRect, TCorner.BottomRight, Borders.Top.Color, Thickness);
    end;
    if (TCorner.BottomLeft in Borders.RoundCorners) then
    begin
      Thickness := Max(Borders.Bottom.Thickness, Borders.Left.Thickness);
      DrawQuadrant(ABorderRect, TCorner.BottomLeft, Borders.Top.Color, Thickness);
    end;
  end;
end;

procedure TLaControlEh.DrawClientBackground(const AClientRect: TRectF; ACanvas: TCanvas);
var
  Radius: Single;
begin
  if (Fill.Kind <> TBrushKind.None) then
  begin
    if Borders.RoundCornerRadius <> 0 then
    begin
      if Fill.Kind <> TBrushKind.None then
      begin
        Radius := Borders.RoundCornerRadius;
        ACanvas.FillRect(AClientRect, Radius, Radius, Borders.RoundCorners, Opacity, Fill);
      end;
    end else
    begin
      CanvasFillRect(ACanvas, AClientRect, Opacity, Fill);
    end;
  end;
end;

procedure TLaControlEh.DrawClientForeground(const AClientRect: TRectF; ACanvas: TCanvas);
begin

end;

procedure TLaControlEh.SetBorders(const Value: TLaControlBordersEh);
begin
  FBorders.Assign(Value);
end;

procedure TLaControlEh.ParentChanged;
begin
  inherited ParentChanged;
  UpdateFont;
  UpdateFontColor;
end;

procedure TLaControlEh.ParentDependenciesChanged;
begin
  UpdateFont;
  UpdateFontColor;
end;

procedure TLaControlEh.BorderThicknessChanged;
begin
end;

function TLaControlEh.DoQueryLayout(const AQuerySize: TSizeF; ACanvas: TCanvas): TSizeF;
var
  CurrQuerySize: TSizeF;
begin
  CurrQuerySize.cx := AQuerySize.cx - Padding.Left - Padding.Right - Borders.Left.Thickness - Borders.Right.Thickness;
  CurrQuerySize.cy := AQuerySize.cy - Margins.Top - Margins.Bottom - Borders.Top.Thickness - Borders.Bottom.Thickness;

  Result := DoQueryLayoutClientArea(CurrQuerySize, ACanvas);

  Result.cx := Result.cx + Padding.Left + Padding.Right + Borders.Left.Thickness + Borders.Right.Thickness;
  Result.cy := Result.cy + Padding.Top + Padding.Bottom + Borders.Top.Thickness + Borders.Bottom.Thickness;
end;

function TLaControlEh.DoQueryLayoutClientArea(const QuerySize: TSizeF; ACanvas: TCanvas): TSizeF;
begin
  Result := TSizeF.Create(0, 0);
end;

function TLaControlEh.DoPerformLayout(const PerfSize: TSizeF; ACanvas: TCanvas): TSizeF;
var
  ClientRect: TRectF;
begin
  ClientRect := TRectF.Create(0, 0, PerfSize.cx, PerfSize.cy);
  ClientRect.Left := ClientRect.Left + Padding.Left + Borders.Left.Thickness;
  ClientRect.Right := ClientRect.Right - Padding.Right - Borders.Right.Thickness;
  ClientRect.Top := ClientRect.Top + Padding.Top + Borders.Top.Thickness;
  ClientRect.Bottom := ClientRect.Bottom - Padding.Bottom - Borders.Bottom.Thickness;

  Result := DoPerformLayoutClientArea(ClientRect, ACanvas);

  Result.cx := Result.cx + Padding.Left + Padding.Right + Borders.Left.Thickness + Borders.Right.Thickness;
  Result.cy := Result.cy + Padding.Top + Padding.Bottom + Borders.Top.Thickness + Borders.Bottom.Thickness;
end;

function TLaControlEh.DoPerformLayoutClientArea(const ClientRect: TRectF; ACanvas: TCanvas): TSizeF;
begin
  Result := ClientRect.Size;
end;

function TLaControlEh.IsFontStored: Boolean;
begin
  Result := not ParentFont;
end;

procedure TLaControlEh.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TLaControlEh.SetParentFont(const Value: Boolean);
begin
  if FParentFont <> Value then
  begin
    FParentFont := Value;
  end;
end;

procedure TLaControlEh.FontChanged(Sender: TObject);
begin
  FParentFont := False;
  UpdateChildDependencies;
end;

procedure TLaControlEh.UpdateFont;
begin
  if ParentFont and
    (Parent <> nil) and
    (Parent is TLaControlEh)  then
  begin
    FFont.OnChanged := nil;
    FFont.Assign(TLaControlEh(Parent).Font);
    FFont.OnChanged := FontChanged;
  end;
end;

function GradientsEqual(G1, G2: TGradient): Boolean;
var
  i: Integer;
begin
  Result :=
    (G1.Style = G2.Style) and
    (G1.Points.Count = G2.Points.Count);

  if Result then
    for i := 0 to G1.Points.Count - 1 do
      if (G1.Points[i].Offset <> G2.Points[i].Offset) or
         (G1.Points[i].Color <> G2.Points[i].Color) then
        Exit(False);
end;

procedure TLaControlEh.SetFill(const Value: TBrush);
var
  Changed: Boolean;
begin
  if FFill.Kind <> Value.Kind then
  begin
    Changed := True;
  end
  else if FFill.Kind = TBrushKind.Solid then
  begin
    Changed := FFill.Color <> Value.Color;
  end
  else if FFill.Kind = TBrushKind.Gradient then
  begin
    Changed := GradientsEqual(FFill.Gradient, Value.Gradient) = False;
  end
  else if FFill.Kind = TBrushKind.Bitmap then
  begin
    Changed := FFill.Bitmap <> Value.Bitmap;
  end
  else if FFill.Kind = TBrushKind.Resource then
  begin
    Changed := (FFill.Resource.StyleResource <> Value.Resource.StyleResource) or
               (FFill.Resource.StyleLookup <> Value.Resource.StyleLookup);
  end else
    Changed := False;

  if Changed then
    FFill.Assign(Value);
end;

procedure TLaControlEh.FillChanged(Sender: TObject);
begin
  Invalidate;
end;

{$REGION 'TLaControlEh.FontColor'}

procedure TLaControlEh.UpdateFontColor;
begin
  if (ParentFontColor = True) and
    (Parent <> nil) and
    (Parent is TLaControlEh) then
  begin
    FFontColor := TLaControlEh(Parent).FontColor;
  end;
end;

procedure TLaControlEh.SetFontColor(const Value: TAlphaColor);
begin
  if FFontColor <> Value then
  begin
    FFontColor := Value;
    FParentFontColor := False;
    UpdateChildDependencies;
  end;
end;

procedure TLaControlEh.SetParentFontColor(const Value: Boolean);
begin
  if FParentFontColor <> Value then
  begin
    FParentFontColor := Value;
    UpdateChildDependencies;
  end;
end;
{$ENDREGION FontColor}

procedure TLaControlEh.Assign(Source: TPersistent);
begin
  inherited Assign(Source);

  if (Source is TLaControlEh) then
  begin
    Padding := TLaControlEh(Source).Padding;
    Borders := TLaControlEh(Source).Borders;
    Fill := TLaControlEh(Source).Fill;

    if (TLaControlEh(Source).ParentFont = False) then
    begin
      Font := TLaControlEh(Source).Font;
    end;

    if (TLaControlEh(Source).ParentFontColor = False) then
    begin
      FontColor := TLaControlEh(Source).FontColor;
    end;
  end;
end;

{$ENDREGION 'TLaControlEh'}

{$REGION 'TLaTextBlockEh'}

constructor TLaTextBlockEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCalcSizeTextLayout := TTextLayoutManager.DefaultTextLayout.Create;
  FHighlightRegions := TList<THighlightTextRegion>.Create;
  FHighlightRegions.OnNotify := HighlightRegionsChanged;
  FTextAlign := TTextAlign.Leading;
  FTrimming := TTextTrimming.None;

  FFormattedTextRanges := TLaFormattedTextRangesEh.Create(Self);
  FLinkRegionMouseOverIndex := -1;
  FLinkRegions := TList<TRegion>.Create;
  HitTest := True;
end;

destructor TLaTextBlockEh.Destroy;
begin
  FCalcSizeTextLayout.Free;
  FHighlightRegions.Free;
  FreeAndNil(FFormattedTextRanges);
  FreeAndNil(FLinkRegions);
  inherited Destroy;
end;

class constructor TLaTextBlockEh.Create;
begin
  FLinkTextColor := TAlphaColorRec.Darkblue;
  FLinkTextStyle := [];

  FLinkHotTextColor := TAlphaColorRec.Darkblue;
  FLinkHotTextStyle := [TFontStyle.fsUnderline];
end;

class destructor TLaTextBlockEh.Destroy;
begin

end;

function TLaTextBlockEh.CalcTextSize(AreaWidth: Single; ACanvas: TCanvas): TSizeF;
var
  TextLyt: TTextLayout;
  AMaxSize: TSizeF;
  I: Integer;
  FmtTextRange: TLaFormattedTextRangeEh;
  Range: TTextRange;
  LinkRegion: TRegion;
begin
  UpdateText;

  TextLyt := FCalcSizeTextLayout;
  TextLyt.ClearAttributes;
  TextLyt.BeginUpdate;
  try
   
    if WordWrap
      then AMaxSize := TSizeF.Create(AreaWidth, MaxSingle)
      else AMaxSize := TSizeF.Create(MaxSingle, MaxSingle);

    InitTextLayout(TextLyt, AMaxSize, ACanvas);
    TextLyt.HorizontalAlign := TTextAlign.Leading; //Fix FMX Bug

  finally
    TextLyt.EndUpdate;
  end;

  FLinkRegions.Clear;
  for I := 0 to FormattedTextRanges.Count - 1 do
  begin
    FmtTextRange := FormattedTextRanges[I];
    Range.Pos := FmtTextRange.TextPos;
    Range.Length := FmtTextRange.TextLength;
    if FmtTextRange.IsHyperLink then
    begin
      LinkRegion := TextLyt.RegionForRange(Range);
      FLinkRegions.Add(LinkRegion);
    end;
  end;

  Result.Width := Ceil(TextLyt.TextRect.Size.Width);
  Result.Height := Ceil(TextLyt.TextRect.Size.Height);
end;

function TLaTextBlockEh.DoQueryLayoutClientArea(const QuerySize: TSizeF; ACanvas: TCanvas): TSizeF;
begin
  Result := CalcTextSize(QuerySize.cx, ACanvas);
end;

function TLaTextBlockEh.DoPerformLayoutClientArea(const ClientRect: TRectF; ACanvas: TCanvas): TSizeF;
begin
  Result := CalcTextSize(ClientRect.Size.cx, ACanvas);
  if (HorzAlignment = TLaHorzAlignmentEh.Stretch) and (Result.Width > ClientRect.Size.Width) then
    Result.Width := ClientRect.Size.Width;
end;

procedure TLaTextBlockEh.DrawClientForeground(const AClientRect: TRectF; ACanvas: TCanvas);
var
  Dl: TTextLayout;
  AMaxSize: TSizeF;
begin
  UpdateText;

  Dl := TTextLayoutManager.DefaultTextLayout.Create;
  Dl.BeginUpdate;
  try
    AMaxSize := PointF(AClientRect.Width, AClientRect.Height);
    
    InitTextLayout(Dl, AMaxSize, ACanvas);
    Dl.TopLeft := AClientRect.TopLeft;
    
  finally
    Dl.EndUpdate;
  end;

  DrawHighlightRegions(AClientRect, Dl);
  Dl.RenderLayout(ACanvas);
  Dl.Free;
end;

procedure TLaTextBlockEh.DrawHighlightRegions(const AClientRect: TRectF; ATextLayout: TTextLayout);
var
  Ti: Integer;
  DrawRegion: TRegion;
  DrawRect: TRectF;
begin
  for Ti := 0 to HighlightRegions.Count - 1 do
  begin
    DrawRegion := ATextLayout.RegionForRange(HighlightRegions[Ti].Range, False);
    if Length(DrawRegion) = 1 then
    begin
      DrawRect := DrawRegion[0];

      ATextLayout.LayoutCanvas.Fill.Color := HighlightRegions[Ti].Color;
      CanvasFillRect(ATextLayout.LayoutCanvas, DrawRect, 1);
    end;
  end;
end;

procedure TLaTextBlockEh.MouseEnter(Params: TControlParamsEh);
begin
  inherited MouseEnter(Params);
end;

procedure TLaTextBlockEh.MouseLeave(Params: TControlParamsEh);
begin
  inherited MouseLeave(Params);
  FLinkRegionMouseOverIndex := -1;
  Invalidate;
end;

function TLaTextBlockEh.GetLinkRegionIndexInPos(APos: TPointF): Integer;
var
  I: Integer;
  RegionRect: TRectF;
begin
  Result := -1;
  for I := 0 to FLinkRegions.Count - 1 do
  begin
    for RegionRect in FLinkRegions[I] do
    begin
      if RegionRect.Contains(APos) then
      begin
        Result := I;
        Exit;
      end;
    end;
  end;
end;

procedure TLaTextBlockEh.ProcessMouseMove(Params: TControlMouseParamsEh);
var
  NewLinkRegionMouseOverIndex: Integer;
begin
  NewLinkRegionMouseOverIndex := GetLinkRegionIndexInPos(TPointF.Create(Params.X, Params.Y));
  if NewLinkRegionMouseOverIndex <> FLinkRegionMouseOverIndex then
  begin
    FLinkRegionMouseOverIndex := NewLinkRegionMouseOverIndex;
    Repaint();
  end;

  inherited ProcessMouseMove(Params);
end;

procedure TLaTextBlockEh.ProcessMouseDown(Params: TControlMouseButtonParamsEh);
begin
  if FLinkRegionMouseOverIndex >= 0 then
    TextLinkClick(FormattedTextRanges[FLinkRegionMouseOverIndex], FLinkRegionMouseOverIndex, Params);

  inherited ProcessMouseDown(Params);
end;

procedure TLaTextBlockEh.TextLinkClick(AFormattedTextRange: TLaFormattedTextRangeEh; AFormattedTextRangeIndex: Integer;
  AOriginalEventParams: TControlMouseButtonParamsEh);
var
  ALinkText: String;
  Params: TInTextLinkClickParamsEh;
begin
  ALinkText := Copy(Text, AFormattedTextRange.TextPos + 1, AFormattedTextRange.TextLength);

  Params := TInTextLinkClickParamsEh.Create;
  try
    Params.Init(Self, AFormattedTextRangeIndex, ALinkText, AOriginalEventParams);

    if Assigned(OnInTextLinkClick) then
      OnInTextLinkClick(Self, Params);

    if AOriginalEventParams.Handled = False then
      AOriginalEventParams.Handled := Params.Handled;

  finally
    Params.Free;
  end;
end;

function TLaTextBlockEh.GetCursorAtMousePos(Shift: TShiftState; X, Y: Single): TCursor;
begin
  if FLinkRegionMouseOverIndex >= 0
    then Result := crHandPoint
    else Result := inherited GetCursorAtMousePos(Shift, X, Y);
end;

procedure TLaTextBlockEh.SetText(const Value: String);
begin
  if (FText <> Value) then
  begin
    if FieldName <> '' then
       raise EInvalidOperation.Create('TLaFlowTextBlock can''t SetText when FieldName is not Empty.');
    FText := Value;
    LayoutChanged;
  end;
end;

procedure TLaTextBlockEh.SetWordWrap(const Value: Boolean);
begin
  if FWordWrap <> Value then
  begin
    FWordWrap := Value;
    LayoutChanged;
  end;
end;

procedure TLaTextBlockEh.SetFieldName(const Value: String);
begin
  if (FFieldName <> Value) then
  begin
    FFieldName := Value;
    FText := '';
    LayoutChanged;
  end;
end;

procedure TLaTextBlockEh.SetLinkIsActive(const Value: Boolean);
begin
  if (FLinkIsActive <> Value) then
  begin
    FLinkIsActive := Value;
    LayoutChanged;
  end;
end;

procedure TLaTextBlockEh.UpdateText;
var
  DataContext: IDataContextEh;
  FieldValue: TValue;
begin
  if (FieldName <> '') then
  begin
    DataContext := GetDataContext;
    if (DataContext = nil) then Exit;

    FieldValue := DataContext.GetFieldValue(FieldName);
    FText := FormatDisplayValue(FieldValue);
  end;
end;

function TLaTextBlockEh.FormatDisplayValue(const AValue: TValue): String;
begin
  Result := ValueToString(AValue);
end;

procedure TLaTextBlockEh.Assign(Source: TPersistent);
var
  SrcTextBlock: TLaTextBlockEh;
begin
  inherited Assign(Source);

  if (Source is TLaTextBlockEh) then
  begin
    SrcTextBlock := TLaTextBlockEh(Source);
    WordWrap := SrcTextBlock.WordWrap;
    Text := SrcTextBlock.Text;
    FieldName := SrcTextBlock.FieldName;
  end;
end;

procedure TLaTextBlockEh.HighlightRegionsChanged(Sender: TObject; const Item: THighlightTextRegion; Action: TCollectionNotification);
begin
  Invalidate;
end;

procedure TLaTextBlockEh.SetTextAlign(const Value: TTextAlign);
begin
  if FTextAlign <> Value then
  begin
    FTextAlign := Value;
    LayoutChanged;
  end;
end;

procedure TLaTextBlockEh.SetTrimming(const Value: TTextTrimming);
begin
  if FTrimming <> Value then
  begin
    FTrimming := Value;
    LayoutChanged;
  end;
end;

procedure TLaTextBlockEh.InitTextLayout(ATextLayout: TTextLayout; AMaxSize: TPointF; ACanvas: TCanvas);
var
  Range: TTextRange;
  I: Integer;
  FmtRange: TLaFormattedTextRangeEh;
  AFont: TFont;
  AFontColor: TAlphaColor;
begin
  ATextLayout.WordWrap := WordWrap;
  ATextLayout.HorizontalAlign := TextAlign;
  ATextLayout.VerticalAlign := TTextAlign.Leading;
  ATextLayout.Color := FontColor;
  ATextLayout.Font := Font;
  ATextLayout.Opacity := AbsoluteOpacity;
  ATextLayout.RightToLeft := False;
  ATextLayout.Trimming := Trimming;

  ATextLayout.LayoutCanvas := ACanvas;
  ATextLayout.TopLeft := TPointF.Create(0, 0);

  ATextLayout.Text := Text;
  ATextLayout.MaxSize := AMaxSize;

  for I := 0 to FormattedTextRanges.Count - 1 do
  begin
    FmtRange := FormattedTextRanges[I];
    Range.Pos := FmtRange.TextPos;
    Range.Length := FmtRange.TextLength;
    if FmtRange.IsHyperLink then
    begin

      if FmtRange.ParentFont then
        if FLinkRegionMouseOverIndex = I then
          AFont := FmtRange.GetHyperlinkHotFont
        else
          AFont := FmtRange.GetHyperlinkFont
      else
        AFont := FmtRange.Font;

      if FmtRange.FontColor = TAlphaColorRec.Null then
        if FLinkRegionMouseOverIndex = I then
          AFontColor := HyperlinkHotTextColor
        else
          AFontColor := HyperlinkTextColor
      else
        AFontColor := FmtRange.FontColor;

      ATextLayout.AddAttribute(Range, TTextAttribute.Create(AFont, AFontColor));
    end
    else
    begin
      ATextLayout.AddAttribute(Range, TTextAttribute.Create(FmtRange.Font, FmtRange.FontColor));
    end;
  end;
end;

class function TLaTextBlockEh.GetCustomURLDetectedRanges(AText: String;
  UrlStartTexts: array of String): TArray<TTextRange>;
  
  function CheckWordStart(AText: String; APos: Integer): Boolean;
  var
    Ch: Char;
  begin
    Result := False;
    if APos = 1 then
      Exit(True)
    else
    begin
      Ch := AText[APos - 1];
      if (Ch = ' ') or (Ch = #13) or (Ch = #10) then
        Exit(True);
    end;
  end;

  function CheckWordFinish(const AText: String; APos: Integer): Boolean;
  var
    Ch: Char;
  begin
    Result := False;
    if APos >= Length(AText) - 1 then
      Exit(True)
    else
    begin
      Ch := AText[APos + 1];
      if (Ch = ' ') or (Ch = #13) or (Ch = #10) then
        Exit(True);
    end;
  end;

  function StartsText(const ASubText, AText: string; ATextStartIndex: Integer): Boolean;
  var
    ATextStart: PChar;
  begin
    if ASubText = '' then
      Result := True
    else
    begin
      if (Length(AText) - ATextStartIndex >= Length(ASubText)) then
      begin
        ATextStart := PChar(AText);
        ATextStart := ATextStart + ATextStartIndex - 1;
        Result := AnsiStrLIComp(PChar(ASubText), ATextStart, Length(ASubText)) = 0;
      end
      else
        Result := False;
    end;
  end;

  procedure CreateRefLink(TextRanges: TList<TTextRange>; const AText: String; APos, ALen: Integer; var LastCheckedPos: Integer);
  var
    SimpleTextItem: TTextRange;
  begin
    if ALen = 0 then Exit;

    SimpleTextItem.Pos := APos - 1;
    SimpleTextItem.Length := ALen;
    TextRanges.Add(SimpleTextItem);
    LastCheckedPos := APos + ALen;
  end;

  procedure CreateLastText(TextRanges: TList<TTextRange>; var LastCheckedPos: Integer);
  begin
    CreateRefLink(TextRanges, AText, Length(AText), 0, LastCheckedPos);
  end;

  function TextStartAtPos(AText: String; AStartPos: Integer; FindText: String): Boolean;
  var
    ATextLen: Integer;
    AFindTextLen: Integer;
    I: Integer;
    Chk: Boolean;
  begin
    ATextLen := Length(AText);
    AFindTextLen := Length(FindText);
    if AFindTextLen > ATextLen - AStartPos + 1 then
      Exit(False);

    for I := 0 to AFindTextLen - 1 do
    begin
      Chk := AText[AStartPos + I] = FindText[1 + I];
      if Chk = False then
        Exit(False);
    end;

    Result := True;
  end;

var
  I, J: Integer;
  LastPos: Integer;
  Chj: Char;
  ContainsDot: Boolean;
  LastChar: Char;
  LastCheckedPos: Integer;
  KI: Integer;
  StartText: String;
  StartTextIdx: Integer;
  StartRefPos: Integer;
  ResultList: TList<TTextRange>;
begin
  Result := nil;

  ResultList := TList<TTextRange>.Create;
  ContainsDot := False;
  LastCheckedPos := 1;
  I := 1;
  while I <= Length(AText) do
  begin
    StartTextIdx := -1;
    for KI := 0 to Length(UrlStartTexts) - 1 do
    begin
      StartText := UrlStartTexts[KI];
      if (TextStartAtPos(AText, I, StartText) = True) then
      begin
        StartTextIdx := KI;
        Break;
      end;
    end;

    if (StartTextIdx >= 0) and
       CheckWordStart(AText, I) then
    begin
      LastChar := #0;
      LastPos := I;
      StartRefPos := I;
      I := I + Length(UrlStartTexts[StartTextIdx]) - 1;
      for J := I + 1 to Length(AText) do
      begin
        Chj := AText[J];
        if (CharInSetEh(Chj, ['a'..'z', 'A'..'Z', '0'..'9', '-', '.', '_', '~', '/']) = True) then
        begin
          LastPos := J;
          LastChar := Chj;
          if Chj = '.' then
            ContainsDot := True;
        end else
        begin
          Break;
        end;
      end;

      if ContainsDot and
         (LastChar <> '.') and
         CheckWordFinish(AText, LastPos) then
      begin
        CreateRefLink(ResultList, AText, StartRefPos, LastPos - StartRefPos + 1, LastCheckedPos);
        I := LastPos + 1;
      end;
    end;
    Inc(I);
  end;

  if (LastCheckedPos > 1) then
  begin
    CreateLastText(ResultList, LastCheckedPos);
  end;

  Result := ResultList.ToArray();
  ResultList.Free;
end;

class function TLaTextBlockEh.GetURLDetectedRanges(AText: String): TArray<TTextRange>;
begin
  Result := GetCustomURLDetectedRanges(AText, ['www.', 'WWW.', 'http://', 'HTTP://', 'https://', 'HTTPS://']);
end;

{$ENDREGION 'TLaTextBlockEh'}

{$REGION 'TLaFormattedTextRangesEh'}

constructor TLaFormattedTextRangesEh.Create(ATextBlock: TLaTextBlockEh);
begin
  inherited Create;
  FTextBlock := ATextBlock;
  FRangeList := TObjectList<TLaFormattedTextRangeEh>.Create(True);
end;

destructor TLaFormattedTextRangesEh.Destroy;
begin
  FreeAndNil(FRangeList);
  inherited Destroy;
end;

function TLaFormattedTextRangesEh.GetCount: Integer;
begin
  Result := FRangeList.Count;
end;

function TLaFormattedTextRangesEh.GetItem(Index: Integer): TLaFormattedTextRangeEh;
begin
  Result := FRangeList[Index];
end;

procedure TLaFormattedTextRangesEh.Clear;
begin
  FRangeList.Clear;
end;

procedure TLaFormattedTextRangesEh.Add(ARange: TLaFormattedTextRangeEh);
begin
  if (ARange.FOwner <> nil) then
    raise Exception.Create('TLaFormattedTextRangesEh.Add: ARange.FOwner <> nil');

  ARange.FOwner := FTextBlock;
  FRangeList.Add(ARange);
end;

procedure TLaFormattedTextRangesEh.AddRange(const Collection: IEnumerable<TLaFormattedTextRangeEh>);
var
  Item: TLaFormattedTextRangeEh;
begin
  for Item in Collection do
  begin
    Add(Item);
  end;
end;

procedure TLaFormattedTextRangesEh.AddRange(const Collection: TEnumerable<TLaFormattedTextRangeEh>);
var
  Item: TLaFormattedTextRangeEh;
begin
  for Item in Collection do
  begin
    Add(Item);
  end;
end;

procedure TLaFormattedTextRangesEh.AddTextRange(ATextPos, ATextLength: Integer; AIsHyperLink: Boolean);
var
  Range: TLaFormattedTextRangeEh;
begin
  Range := TLaFormattedTextRangeEh.Create;
  Range.TextPos := ATextPos;
  Range.TextLength := ATextLength;
  Range.IsHyperLink := AIsHyperLink;
  Add(Range);
end;

procedure TLaFormattedTextRangesEh.AddTextRange(ATextPos, ATextLength: Integer; AFont: TFont;
  AFontColor: TAlphaColor; AIsHyperLink: Boolean);
var
  Range: TLaFormattedTextRangeEh;
begin
  Range := TLaFormattedTextRangeEh.Create;
  Range.TextPos := ATextPos;
  Range.TextLength := ATextLength;
  Range.Font := AFont;
  Range.FontColor := AFontColor;
  Range.IsHyperLink := AIsHyperLink;
  Add(Range);
end;

{$ENDREGION 'TLaFormattedTextRangesEh'}

{$REGION 'TLaFormattedTextRangeEh'}

constructor TLaFormattedTextRangeEh.Create;
begin
  inherited Create;
  FFont := TFont.Create;
  FFont.OnChanged := FontChanged;
  FParentFont := True;
  FFontColor := TAlphaColorRec.Null;
end;

destructor TLaFormattedTextRangeEh.Destroy;
begin
  FreeAndNil(FFont);
  FreeAndNil(FHyperlinkFont);
  FreeAndNil(FHyperlinkHotFont);
  inherited Destroy;
end;

function TLaFormattedTextRangeEh.Equals(Obj: TObject): Boolean;
var
  TypedObj: TLaFormattedTextRangeEh;
begin
  if Obj = Self then
  begin
    Result := True
  end
  else if Obj is TLaFormattedTextRangeEh then
  begin
    TypedObj := TLaFormattedTextRangeEh(Obj);
    Result := (Font.Equals(TypedObj.Font) = True) and
              (ParentFont = TypedObj.ParentFont) and
              (TextPos = TypedObj.TextPos) and
              (TextLength = TypedObj.TextLength) and
              (FontColor = TypedObj.FontColor) and
              (IsHyperLink = TypedObj.IsHyperLink) and
              (Tag = TypedObj.Tag);
  end else
  begin
    Result := inherited Equals(Obj);
  end;
end;

procedure TLaFormattedTextRangeEh.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
end;

procedure TLaFormattedTextRangeEh.FontChanged(Sender: TObject);
begin
  FParentFont := False;
  NotifyPropChanged;
end;

function TLaFormattedTextRangeEh.GetHyperlinkFont: TFont;
begin
  if FHyperlinkFont = nil then
  begin
    FHyperlinkFont := TFont.Create;
    FHyperlinkFont.Assign(Font);
    FHyperlinkFont.Style := TLaTextBlockEh.HyperlinkTextStyle;
  end;
  Result := FHyperlinkFont;
end;

function TLaFormattedTextRangeEh.GetHyperlinkHotFont: TFont;
begin
  if FHyperlinkHotFont = nil then
  begin
    FHyperlinkHotFont := TFont.Create;
    FHyperlinkHotFont.Assign(Font);
    FHyperlinkHotFont.Style := TLaTextBlockEh.HyperlinkHotTextStyle;
  end;
  Result := FHyperlinkHotFont;
end;

function TLaFormattedTextRangeEh.IsFontStored: Boolean;
begin
  Result := not ParentFont;
end;

procedure TLaFormattedTextRangeEh.NotifyPropChanged;
begin
  if FOwner <> nil then
    FOwner.LayoutChanged;
end;

procedure TLaFormattedTextRangeEh.ParentChanged;
begin
  UpdateFont;
end;

procedure TLaFormattedTextRangeEh.SetFont(Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TLaFormattedTextRangeEh.SetParentFont(Value: Boolean);
begin
  if FParentFont <> Value then
  begin
    FParentFont := Value;
    NotifyPropChanged;
  end;
end;

procedure TLaFormattedTextRangeEh.UpdateFont;
begin
  if ParentFont and
    (FOwner <> nil) then
  begin
    FFont.OnChanged := nil;
    FFont.Assign(FOwner.Font);
    FFont.OnChanged := FontChanged;
  end;
end;

{$ENDREGION 'TLaFormattedTextRangeEh'}

{$REGION 'TInTextLinkClickParamsEh'}

procedure TInTextLinkClickParamsEh.Init(AControl: TLaControlEh; ATextRangeIndex: Integer; ALinkText: String;
  AOriginalEventParams: TControlMouseButtonParamsEh);
begin
  FControl := AControl;
  FTextRangeIndex := ATextRangeIndex;
  FLinkText := ALinkText;
  FOriginalEventParams := AOriginalEventParams;
  FHandled := False;
end;

{$ENDREGION 'TInTextLinkClickParamsEh'}

{$REGION 'TLaImageEh'}

constructor TLaImageEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FImage := TImage.Create(nil);
  FImage.Locked := True;
  FImage.HitTest := False;
  FImage.Parent := Self;
  FImage.WrapMode := TImageWrapMode.Place;
end;

destructor TLaImageEh.Destroy;
begin
  FreeAndNil(FImage);
  inherited Destroy;
end;

function TLaImageEh.GetPictureActualSize: TSizeF;
var
  APic: TBitmap;
  BitmapItem: TCustomBitmapItem;
begin
  if (Bitmap <> nil) and (Bitmap.IsEmpty = False) then
  begin
    Result := TSizeF.Create(Bitmap.Width, Bitmap.Height);
  end
  else if (ImageList <> nil) and
          (ImageIndex >= 0) and
          (ImageIndex < ImageList.Destination.Count) then
  begin
    BitmapItem := ImageList.Destination[ImageIndex].Layers[0].MultiResBitmap.Items[0].Bitmap.BitmapItem;
    Result := TSizeF.Create(BitmapItem.Width, BitmapItem.Height);
  end
  else if (FieldName <> '') then
  begin
    APic := GetPictureForField(FieldName);
    Result := TSizeF.Create(APic.Width, APic.Height);
    APic.Free;
  end
  else
  begin
    Result := TSizeF.Create(0, 0);
  end;
end;

function TLaImageEh.DoQueryLayoutClientArea(const QuerySize: TSizeF; ACanvas: TCanvas): TSizeF;
var
  APicSize: TSizeF;
begin
  APicSize := GetPictureActualSize();

  if (APicSize.cx >= 0) or (APicSize.cy >= 0) then
    Result := GetFitSize(APicSize, QuerySize)
  else
    Result := TSizeF.Create(0, 0);
end;

function TLaImageEh.DoPerformLayoutClientArea(const ClientRect: TRectF; ACanvas: TCanvas): TSizeF;
begin
  FImage.SetBounds(ClientRect.Left, ClientRect.Top, ClientRect.Width, ClientRect.Height);
  Result := ClientRect.Size;
end;

function TLaImageEh.GetFitSize(ImageSize: TSizeF; const RenderSize: TSizeF): TSizeF;
var
  iw, ih, dw, dh, rw, rh: Single;
  xyAspect: Double;
begin
  iw := ImageSize.Width;
  ih := ImageSize.Height;
  dw := RenderSize.Width;
  dh := RenderSize.Height;
  if (dw >= iw) and (dh >= ih) then
  begin
    Result := ImageSize
  end else
  begin
    if (iw = 0) or (ih = 0) then
    begin
      Result := TSizeF.Create(0, 0);
      Exit;
    end;

    xyAspect := iw / ih;
    rw := dw;
    rh := Trunc(dw / xyAspect);
    if rh > dh then
    begin
      rh := dh;
      rw := Trunc(dh * xyAspect);
    end;
    Result := TSizeF.Create(rw, rh);
  end;
end;

function TLaImageEh.GetBitmap: TBitmap;
begin
  Result := FImage.Bitmap;
end;

procedure TLaImageEh.SetBitmap(const Value: TBitmap);
begin
  FImage.Bitmap := Value;
end;

procedure TLaImageEh.SetFieldName(const Value: String);
begin
  if (FFieldName <> Value) then
  begin
    FFieldName := Value;
    UpdateImage;
  end;
end;

procedure TLaImageEh.SetImageIndex(const Value: Integer);
begin
  if FImageIndex <> Value then
  begin
    FImageIndex := Value;
    UpdateImage;
  end;
end;

procedure TLaImageEh.SetImageList(const Value: TCustomImageList);
begin
  if FImageList <> Value then
  begin
    FImageList := Value;
    UpdateImage;
  end;
end;

function TLaImageEh.GetPictureForField(AFieldName: String): TBitmap;
var
  DataContext: IDataContextEh;
  FieldValue: TValue;
  ImgStream: IImageStream;
begin
  Result := TBitmap.Create;
  Result.SetSize(0, 0);
  if (FieldName <> '') then
  begin
    DataContext := GetDataContext;
    if (DataContext = nil) then Exit;

    FieldValue := DataContext.GetFieldValue(FieldName);
    if FieldValue.IsType<Variant> then
    begin
      if Supports(FieldValue.AsVariant, IImageStream, ImgStream) then
        Result.Assign(ImgStream.GetObject);
    end;
  end;
end;

procedure TLaImageEh.UpdateImage;
var
  DataContext: IDataContextEh;
  FieldValue: TValue;
  ImgStream: IImageStream;
  MultiResBitmap: TMultiResBitmap;
begin
  if (FieldName <> '') then
  begin
    DataContext := GetDataContext;
    if (DataContext = nil) then Exit;

    FieldValue := DataContext.GetFieldValue(FieldName);
    if FieldValue.IsType<Variant> then
    begin
      if Supports(FieldValue.AsVariant, IImageStream, ImgStream) then
        FImage.Bitmap.Assign(ImgStream.GetObject)
      else
        FImage.Bitmap.Assign(nil);
    end else
    begin
      FImage.Bitmap.Assign(nil);
    end;
  end else
  begin
    if (ImageList <> nil) then
    begin
      if (ImageIndex >= 0) and
         (ImageIndex < ImageList.Destination.Count) then
      begin
        MultiResBitmap := ImageList.Destination[ImageIndex].Layers[0].MultiResBitmap;
        FImage.MultiResBitmap.Assign(MultiResBitmap);
      end else
      begin
        FImage.MultiResBitmap.Assign(nil);
      end;
    end;
  end;
end;

procedure TLaImageEh.Assign(Source: TPersistent);
begin
  inherited Assign(Source);

  if (Source is TLaImageEh) then
  begin
    ImageList := TLaImageEh(Source).ImageList;
    ImageIndex := TLaImageEh(Source).ImageIndex;
    FieldName := TLaImageEh(Source).FieldName;
    Bitmap := TLaImageEh(Source).Bitmap;
  end;
end;

function TLaImageEh.GetWrapMode: TImageWrapMode;
begin
  Result := FImage.WrapMode;
end;

procedure TLaImageEh.SetWrapMode(const Value: TImageWrapMode);
begin
  FImage.WrapMode := Value;
end;

procedure TLaImageEh.DoUpdateDataContent;
begin
  inherited DoUpdateDataContent;
  UpdateImage;
end;

{$ENDREGION 'TLaImageEh'}

{$REGION 'TLaButtonBackEh'}

constructor TLaButtonBackEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TLaButtonBackEh.Destroy;
begin
  inherited Destroy;
end;

procedure TLaButtonBackEh.DoRepeatDelayTimer(Sender: TObject);
begin
  FRepeatTimer.OnTimer := DoRepeatTimer;
  FRepeatTimer.Interval := 100;
end;

procedure TLaButtonBackEh.DoRepeatTimer(Sender: TObject);
begin
  if (Root <> nil) and (Root.Captured <> nil) and (Root.Captured.GetObject = Self) then
    Click
  else
    FRepeatTimer.Enabled := False;
end;

function TLaButtonBackEh.GetDefaultStyleLookupName: string;
begin
  Result := 'ButtonStyle';
end;

function TLaButtonBackEh.GetStyleResourceName(): String;
begin
  Result := ''; 
end;

procedure TLaButtonBackEh.SetIsPressed(const Value: Boolean);
begin
  if FStaysPressed then
  begin
    if Value <> FIsPressed then
    begin
      FIsPressed := Value;
      ApplyTriggers;
    end;
  end;
end;

function TLaButtonBackEh.IsPressedStored: Boolean;
begin
  Result := True;
end;

procedure TLaButtonBackEh.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if FLaButton <> nil then
    FLaButton.ButtonBackMouseDown(Self, Button, Shift, X, Y);

  inherited MouseDown(Button, Shift, X, Y);

  if Button = TMouseButton.mbLeft then
  begin
    FPressing := True;
    if FStaysPressed then
      ToggleStaysPressed
    else begin
      FIsPressed := True;
      if FRepeat then
      begin
        if FRepeatTimer = nil then
        begin
          FRepeatTimer := TTimer.Create(Self);
          FRepeatTimer.Interval := 500;
        end;
        FRepeatTimer.OnTimer := DoRepeatDelayTimer;
        FRepeatTimer.Enabled := True;
      end;
      ApplyTriggers;
    end;
  end;
end;

procedure TLaButtonBackEh.MouseMove(Shift: TShiftState; X, Y: Single);
var
  Inside: Boolean;
begin
  inherited MouseMove(Shift, X, Y);

  if (ssLeft in Shift) and FPressing then
  begin
    Inside := LocalRect.Contains(TPointF.Create(X, Y));
    if FIsPressed <> Inside then
    begin
      if not FStaysPressed then
      begin
        FIsPressed := Inside;
        ApplyTriggers;
      end;
    end;
  end;
end;

procedure TLaButtonBackEh.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if FPressing then
  begin
    if FRepeatTimer <> nil then
      FRepeatTimer.Enabled := False;
    FPressing := False;
    if not FStaysPressed or not LocalRect.Contains(TPointF.Create(X, Y)) then
      RestoreButtonState;
  end;
  inherited MouseUp(Button, Shift, X, Y);
end;

procedure TLaButtonBackEh.RestoreButtonState;
begin
  FIsPressed := False;
  ApplyTriggers;
end;

procedure TLaButtonBackEh.SetStaysPressed(const Value: Boolean);
begin
  if not Value and FIsPressed then
    SetIsPressed(False);
  if FStaysPressed <> Value then
    FStaysPressed := Value;
end;

procedure TLaButtonBackEh.ToggleStaysPressed;
begin
  IsPressed := not FIsPressed;
end;

procedure TLaButtonBackEh.ApplyTriggers;
var
  SaveIsMouseOver: Boolean;
begin
  SaveIsMouseOver := IsMouseOver;
  if IsPressed and StaysPressed then
    FIsMouseOver := True;
  StartTriggerAnimation(Self, 'IsPressed');
  ApplyTriggerEffect(Self, 'IsPressed');
  FIsMouseOver := SaveIsMouseOver;
end;

{$ENDREGION 'TLaButtonBackEh'}

{$REGION 'TLaButtonEh'}

constructor TLaButtonEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  HitTest := True;
  AutoCapture := True;

  with TLaLayoutPanelEh.CreateWith(Self, RefSelf) do
  begin
    FLayoutPanel := RefSelf as TLaControlEh;

    with TLaButtonBackEh.CreateWith(Self, RefSelf) do
    begin
      FButtonBack := TLaButtonBackEh(RefSelf);
      FButtonBack.FLaButton := Self;
    end;
  end;
end;

destructor TLaButtonEh.Destroy;
begin
  inherited Destroy;
end;

function TLaButtonEh.DoQueryLayoutClientArea(const QuerySize: TSizeF; ACanvas: TCanvas): TSizeF;
begin
  Result := FLayoutPanel.QueryLayout(QuerySize, ACanvas);
end;

function TLaButtonEh.DoPerformLayoutClientArea(const ClientRect: TRectF; ACanvas: TCanvas): TSizeF;
begin
  Result := FLayoutPanel.PerformLayout(ClientRect, ACanvas, UnlimitedRect);
end;

function TLaButtonEh.GetContent: TFmxObject;
begin
  Result := FContent;
end;

function TLaButtonEh.GetButtonBackVisible: Boolean;
begin
  Result := FButtonBack.Visible;
end;

procedure TLaButtonEh.SetButtonBackVisible(const Value: Boolean);
begin
  FButtonBack.Visible := Value;
end;

procedure TLaButtonEh.SetContent(const Value: TFmxObject);
begin
  if FContent <> Value then
  begin
    if FContent <> nil then
      FContent.Parent := nil;
    FContent := Value;
    if FContent <> nil then
      FContent.Parent := FLayoutPanel;
  end;
end;

function TLaButtonEh.GetIsPressed: Boolean;
begin
  Result := FButtonBack.IsPressed;
end;

procedure TLaButtonEh.SetIsPressed(const Value: Boolean);
begin
  FButtonBack.IsPressed := Value;
end;

function TLaButtonEh.GetStaysPressed: Boolean;
begin
  Result := FButtonBack.StaysPressed;
end;

procedure TLaButtonEh.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TLaButtonEh.ProcessMouseClick(Params: TControlMouseButtonParamsEh);
begin
  inherited ProcessMouseClick(Params);
  Params.Handled := True;
end;

procedure TLaButtonEh.SetStaysPressed(const Value: Boolean);
begin
  FButtonBack.StaysPressed := Value;
end;

procedure TLaButtonEh.ButtonBackMouseDown(ButtonBack: TLaButtonBackEh; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
end;

{$ENDREGION 'TLaButtonEh'}

end.
