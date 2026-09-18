{*******************************************************}
{                                                       }
{                       EhLib 12.1                      }
{            Specific routines for Vcl.Win32            }
{                                                       }
{    Copyright (c) 2004-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

{$I ..\Incl\EhLib.Inc}
{$WARN SYMBOL_DEPRECATED OFF}

unit EhLibVclUtils;

interface

uses
  Forms, SysUtils, DB, TypInfo, Controls, Messages,
  Generics.Defaults, Generics.Collections, Classes,
  RTLConsts, Windows, StdCtrls, UxTheme,
  {$IFDEF EH_LIB_17} System.UITypes, {$ENDIF} 
  EhLibUtils, DBUtilsEh,
  ImgList, Graphics, Themes, Variants, Contnrs, StrUtils, Math, Types;

type
  {$IFNDEF EH_LIB_16} 
  IntPtr = NativeInt;
  {$ENDIF}

  TUniBookmarkEh = TBookmark;
  TLoadMode = DBUtilsEh.TLoadMode;
  TBMListEh = DBUtilsEh.TBMListEh;

{$IFNDEF EH_LIB_12}
  TRecordBuffer = PChar;
{$ENDIF}

{$IFNDEF EH_LIB_17}
  TValueBuffer = Pointer;
{$ENDIF}

  TPointArrayEh = EhLibUtils.TPointArrayEh;
  TDWORDArrayEh = EhLibUtils.TDWORDArrayEh;
  TVariantDynArray = EhLibUtils.TVariantDynArray;
  TRectDynArray = EhLibUtils.TRectDynArray;

{$IFDEF EH_LIB_9}
{$ELSE}
  TStringDynArray  = array of String;
{$ENDIF}

{$IFNDEF EH_LIB_16}
  {$IFDEF WINDOWS}
  TLocaleID = LCID;
  {$ELSE}
  TLocaleID = LongWord;
  {$ENDIF}
{$ENDIF}

type

{$IFNDEF EH_LIB_13} 
  TArray<T> = array of T;
{$ENDIF} 

  TFieldListEh = DBUtilsEh.TFieldListEh;
  TObjectListEh = EhLibUtils.TObjectListEh;

const
{$IFDEF TBookMarkAsTBytes}
  NilBookmarkEh = nil;
{$ELSE}
  NilBookmarkEh = '';
{$ENDIF}

  LAYOUT_RTL_EH = $00000001;

{$IFDEF EH_LIB_16} 

{$ELSE}

type

  TElementSize = (esMinimum, esActual, esStretch);

{ TElementColor }

  TElementColor = (
    ecBorderColor,
    ecFillColor,
    ecTextColor,
    ecEdgeLightColor,
    ecEdgeHighLightColor,
    ecEdgeShadowColor,
    ecEdgeDkShadowColor,
    ecEdgeFillColor,
    ecTransparentColor,
    ecGradientColor1,
    ecGradientColor2,
    ecGradientColor3,
    ecGradientColor4,
    ecGradientColor5,
    ecShadowColor,
    ecGlowColor,
    ecTextBorderColor,
    ecTextShadowColor,
    ecGlyphTextColor,
    ecGlyphTransparentColor,
    ecFillColorHint,
    ecBorderColorHint,
    ecAccentColorHint,
    ecTextColorHint,
    ecHeading1TextColor,
    ecHeading2TextColor,
    ecBodyTextColor
  );

{ TCustomStyleServices }

  TCustomStyleServices = class(TObject)
  private
    function GetThemesEnabled: Boolean;
  public
    function GetSystemColor(Color: TColor): TColor;
    {$IFDEF FPC}
    {$ELSE}
    function GetElementSize(DC: HDC; Details: TThemedElementDetails; ElementSize: TElementSize; out Size: TSize): Boolean;
    {$ENDIF}
    function GetElementColor(Details: TThemedElementDetails; ElementColor: TElementColor; out Color: TColor): Boolean;

    procedure DrawElement(DC: HDC; Details: TThemedElementDetails; const R: TRect); overload;
    procedure DrawElement(DC: HDC; Details: TThemedElementDetails; const R: TRect; ClipRect: TRect); overload;

    function GetElementDetails(Detail: TThemedButton): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedClock): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedComboBox): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedEdit): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedExplorerBar): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedHeader): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedListView): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedMenu): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedPage): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedProgress): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedRebar): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedScrollBar): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedSpin): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedStartPanel): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedStatus): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedTab): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedTaskBand): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedTaskBar): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedToolBar): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedToolTip): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedTrackBar): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedTrayNotify): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedTreeView): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedWindow): TThemedElementDetails; overload;

    property ThemesEnabled: Boolean read GetThemesEnabled;
  end;

function StyleServices: TCustomStyleServices;

{$ENDIF} 

type

{ TWinControlEh }

  TWinControlEh = class(TWinControl)
  private
  protected
  {$IFDEF FPC}
    function Ctl3D;
  {$ELSE}
  {$ENDIF}
    procedure RecreateWndHandle;
  public
    constructor Create(AOwner: TComponent); override;
  end;

type

{ TCustomControlEh }

  TCustomControlEh = class(TCustomControl)
  private
    FDefaultFlatButtonWidth: Integer;
    FDefaultCheckBoxHeight: Integer;
    FDefaultFlatCheckBoxWidth: Integer;
    FDefaultCheckBoxWidth: Integer;
    FDefaultFlatCheckBoxHeight: Integer;
    function GetStyleServices: TCustomStyleServices;
    function GetDefaultFlatButtonWidth: Integer;

    procedure GetCheckSize;
  protected
  {$IFDEF EH_LIB_26} 
  {$ELSE}
    FScaleFactor: Single;
  {$ENDIF}

    procedure RecreateWndHandle;
    procedure ChangeScale(M, D: Integer {$IFDEF EH_LIB_24}; isDpiChange: Boolean {$ENDIF}); override;
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent); override;

  {$IFDEF EH_LIB_26} 
  {$ELSE}
    function GetSystemMetrics(nIndex: Integer): Integer;
    property ScaleFactor: Single read FScaleFactor;
  {$ENDIF}

  {$IFDEF EH_LIB_27} 
  {$ELSE}
    function ScaleValue(const Value: Integer): Integer;
    function IsCustomStyleActive: Boolean; virtual;
  {$ENDIF}

    property StyleServices: TCustomStyleServices read GetStyleServices;
    property DefaultFlatButtonWidth: Integer read FDefaultFlatButtonWidth;
    property DefaultCheckBoxWidth: Integer read FDefaultCheckBoxWidth;
    property DefaultCheckBoxHeight: Integer read FDefaultCheckBoxHeight;
    property DefaultFlatCheckBoxWidth: Integer read FDefaultFlatCheckBoxWidth;
    property DefaultFlatCheckBoxHeight: Integer read FDefaultFlatCheckBoxHeight;
  end;

function WindowsScrollWindowEx(hWnd: HWND; dx, dy: Integer;
  var prcScroll,  prcClip: TRect;
  hrgnUpdate: HRGN; flags: UINT): Boolean;


function CharInSetEh(C: Char; const CharSet: TSysCharSet): Boolean;
function VarToAnsiStr(const V: Variant): AnsiString;
function IsLeadCharEh(C: Char): Boolean;

function DataSetCompareBookmarks(DataSet: TDataSet; Bookmark1, Bookmark2: TUniBookmarkEh): Integer;
function DataSetBookmarkValid(DataSet: TDataSet; Bookmark: TUniBookmarkEh): Boolean;

function IsObjectAndIntegerRefSame(AObject: TObject; IntRef: IntPtr): Boolean;
function IntPtrToObject(AIntPtr: IntPtr): TObject;
function ObjectToIntPtr(AObject: TObject): IntPtr;
function IntPtrToString(AIntPtr: IntPtr): String;

function MiddleDotChar: Char;

function NlsUpperCase(const S: String): String;
function NlsLowerCase(const S: String): String;
function NlsCompareStr(const S1, S2: String): Integer;
function NlsCompareText(const S1, S2: String): Integer;

function GetTickCountEh: UInt64;

procedure BinToHexEh(Buffer: TBytes; out Text: String; Count: Integer);

procedure StreamWriteBytes(Stream: TStream; Buffer: TBytes);
procedure StreamReadBytes(Stream: TStream; var Buffer: TBytes; Count: Integer);

function PropInfo_getPropType(APropInfo: PPropInfo): PTypeInfo;
function PropInfo_getName(APropInfo: PPropInfo): String;
function PropType_getKind(APropType: PTypeInfo): TTypeKind;

function GetEnumPropValueAsString(Instance: TObject; const PropName: string): String;
procedure SetEnumPropValueAsString(Instance: TObject; const PropName: string; AValue: String);

procedure VarArrayRedimEh(var A : Variant; HighBound: Integer);

procedure VarSetNull(var V: Variant); {$IFDEF EH_LIB_8} inline;{$ENDIF}
function VarIsNullEh(const V: Variant): Boolean; {$IFDEF EH_LIB_8} inline;{$ENDIF}
procedure FreeObjectEh(obj: TObject);
procedure DoNothing();
function SysStrToFloat(const S: string): Extended;
function SysFloatToStr(const Val: Extended): string;



type
  TTextWrapStyleEh = (twsNoWrapEh, twsWordWrapEh, twsSingleLineEh);

{ TDrawTextOptionsEh }

  TDrawTextOptionsEh = record
    HorzAlignment: TAlignment;
    VertAlignment: TVerticalAlignment;
    WrapStyle: TTextWrapStyleEh;
    FillBack: Boolean;
    BiDiMode: TBiDiMode;
    EndEllipsis: Boolean;
    RotationAngle: Single;

    procedure Clear;
  end;

function DrawTextEh(hDC: HDC; const Text: String; nCount: Integer; var lpRect: TRect; uFormat: UINT): Integer; overload;

procedure DrawTextEh(Canvas: TCanvas; Text: String; ARect: TRect; ClipRect: TRect; var Options: TDrawTextOptionsEh); overload;
procedure DrawTextEh(Canvas: TCanvas; Text: String; ARect: TRect; ClipRect: TRect; Alignment: TAlignment; Layout: TTextLayout; WrapStyle: TTextWrapStyleEh; FillBack: Boolean = False); overload;
procedure DrawTextEh(Canvas: TCanvas; Text: String; ARect: TRect; Alignment: TAlignment; Layout: TTextLayout; WrapStyle: TTextWrapStyleEh; FillBack: Boolean = False); overload;
procedure DrawTextEh(Canvas: TCanvas; Text: String; ARect: TRect; FillBack: Boolean = False); overload;

function GetTextExtentPointEh(Canvas: TCanvas; Text: String; out StringSize: TSize): TIntegerDynArray; overload;

function EditorGetCaretPosEh(Control: TWinControl): Integer;
function GetMessageTimeEh: Integer;

procedure SetWindowDropShadowStyle(Control: TWinControl; var Params: TCreateParams; SetState: Boolean);
procedure SetWindowDropDownNoActivateStyle(Control: TWinControl; var Params: TCreateParams; SetState: Boolean);
function GetAdjustedClientRect(Control: TWinControl): TRect;
function GetDesktopWindowEh: HWnd;
function GetScreenCanvas: TCanvas;

{$IFDEF WINDOWS}
function WindowsDrawTextEx(DC: HDC; const lpchText: String; var p4: TRect;  dwDTFormat: UINT; DTParams: TDrawTextParams): Integer; overload;
function WindowsDrawTextEx(DC: HDC; const lpchText: String; var p4: TRect;  dwDTFormat: UINT): Integer; overload;

function WindowsExtTextOut(DC: HDC; X, Y: Integer; Options: Integer; var Rect: TRect; const Str: String; Count: Integer{; Dx: PInteger}): BOOL;

function WindowsGetOutlineTextMetrics(DC: HDC; p2: UINT; var OTMetricStructs: TOutlineTextMetric): UINT;
{$ELSE}
{$ENDIF}


function StringNextCharPos(S: String; APos: Integer): Integer;

{$IFDEF FPC_CROSSP}
function GetNearestColor(hDC: HDC; Color: TColor): TColor;
{$ENDIF}

function SendStructMessage(hWnd: HWND; Msg: UINT; wParam: WPARAM; var lParam): LRESULT;
function SendTextMessage(hWnd: HWND; Msg: UINT; wParam: WPARAM; const lParam: string): LRESULT;
function SendGetTextMessage(hWnd: HWND; Msg: UINT; wParam: WPARAM; var lParam: string; BufferSize: Integer): LRESULT;

function SystemParametersInfoEh(uiAction, uiParam: UINT; var pvParam; fWinIni: UINT): BOOL;
function WindowsInvalidateRect(hWnd: HWND; var Rect: TRect; bErase: BOOL): BOOL;
function WindowsValidateRect(hWnd: HWND; var Rect: TRect): BOOL;
function WindowsScrollWindow(hWnd: HWND; dx, dy: Integer; var prcScroll, prcClip: TRect): BOOL;
procedure WinServiceSetFocus(hWnd: HWND);
function WinServiceIsChild(hWndParent, hWnd: HWND): Boolean;

function WindowsLPtoDP(DC: HDC; var ARect: TRect): BOOL;
function WindowsCreatePolygonRgn(Points: array of TPoint; Count, FillMode: Integer): HRGN;
function GetFontSize(Font: TFont): Integer;
function GetFontHeight(Font: TFont): Integer;
function GetFontTextHeight(Canvas: TCanvas; Font: TFont; IncludeExternalLeading: Boolean = True): Integer;
procedure GetTextMetricsEh(Canvas: TCanvas; out tm: TTextMetric); overload;
procedure GetTextMetricsEh(AFontName: String; AFontSize: Integer; AFontStyle: TFontStyles; out tm: TTextMetric); overload;
procedure PolyPolyLineEh(Canvas: TCanvas; const PointsList: TPointArrayEh; const StrokeList: TDWORDArrayEh; VCount: Integer);

procedure VarToMessage(var VarMessage; var Message: TMessage);
function MessageToTMessage(var Message): TMessage;
function MessageToTWMMouse(var Message): TWMMouse;
function MessageToTWMKey(var Message): TWMKey;
function UnwrapMessageEh(var Message): TMessage;
procedure PostQuitMessageEh(nExitCode: Integer);

function SmallPointToInteger(SmallPoint: TSmallPoint): Integer;
function LongintToSmallPoint(Value: Longint): TSmallPoint;

procedure MessageSendGetSel(hWnd: HWND; var SelStart, SelEnd: Integer);
procedure EditControlSetSel(Control: TCustomEdit; SelStart, SelEnd: Integer);

{$IFNDEF EH_LIB_9}
function ReplaceStr(const AText, AFromText, AToText: string): string;
{$ENDIF}

procedure BitmapLoadFromResourceName(Bmp: TBitmap; Instance: THandle; const ResName: String);
function LoadBitmapEh(hInstance: HINST; lpBitmapID: Integer): HBITMAP;

type
  TPropListArray = array of PPropInfo;

function GetPropListAsArray(ATypeInfo: PTypeInfo; TypeKinds: TTypeKinds): TPropListArray;

{$IFNDEF EH_LIB_12}
function BytesOf(S: String): TBytes; overload;
{$ENDIF}

{$IFNDEF EH_LIB_17}
function BytesOf(const Val: Pointer; const Len: integer): TBytes; overload;
{$ENDIF}

function EmptyRect: TRect;
function IsRectEmptyEh(const Rect: TRect): Boolean;

function VariantToRefObject(VarValue: Variant): TObject;
function RefObjectToVariant(ARefObject: TObject): Variant;
procedure DataVarCastAsObject(var Dest: Variant; const Source: Variant);
function VarTypeName(varValue: Variant): String;
function RemoveLineBreaksFromText(Text: String): String;

type

{ TFilerAccess }

  TFilerAccess = class(TInterfacedObject) 
  private
    FPersistent: TPersistent;
  public
    constructor Create(APersistent: TPersistent);
    procedure DefineProperties(AFiler: TFiler);
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent);
    function GetChildOwner: TComponent;
    function GetChildParent: TComponent;
    procedure SetAncestor(Value: Boolean);
    procedure SetChildOrder(Child: TComponent; Order: Integer);
    procedure Updated;
    procedure Updating;
  end;

{ TMemoryStreamEh }

  TMemoryStreamEh = class(TMemoryStream)
  private
    FHalfMemoryDelta: Integer;
  protected
    {$IFDEF FPC}
    function Realloc(var NewCapacity: PtrInt): Pointer; override;
    {$ELSE}
      {$IFDEF EH_LIB_28}
    function Realloc(var NewCapacity: NativeInt): Pointer; override;
      {$ELSE}
    function Realloc(var NewCapacity: System.Longint): Pointer; override;
    {$ENDIF}
    {$ENDIF}
  public
    constructor Create;
    property HalfMemoryDelta: Integer read FHalfMemoryDelta write FHalfMemoryDelta;
  end;

function SafeGetMouseCursorPos: TPoint;

{$IFNDEF EH_LIB_14}
function PointToLParam(P: TPoint): LPARAM;
{$ENDIF}

function StringToLParam(s: String): LPARAM;

function FirstDayOfWeekEh(): Integer; 

function SetLayoutEh(hdc: HDC; dwLayout: DWORD): DWORD;

procedure KillMessage(Wnd: HWnd; Msg: Integer);
function SmallPointToPointEh(const P: TSmallPoint): TPoint;

{$IFNDEF EH_LIB_12} 
function RectWidth(const Rect: TRect): Integer;
function RectHeight(const Rect: TRect): Integer;
{$ENDIF}

function RectSize(const Rect: TRect): TSize;
function RectContains(const Rect: TRect; const P: TPoint): Boolean;
function CreateRect(Left, Top, Right, Bottom: Integer): TRect;

function RectF(ALeft, ATop, ARight, ABottom: Single): TRectF;
function RectFWidth(const Rect: TRectF): Single;
function RectFHeight(const Rect: TRectF): Single;
function PointF(x: Single; y: Single): TPointF;

function CreatePoint(x, y: Integer): TPoint;
function CreateSize(cx, cy: Integer): TSize;

{$IFNDEF EH_LIB_13}
function CenteredRect(const SourceRect: TRect; const ACenteredRect: TRect): TRect;
{$ENDIF}

function ChangeRect(const Rect: TRect; ChangeLeft, ChangeTop, ChangeRight, ChangeBottom: Integer): TRect;
procedure MoveRect(var Rect: TRect; Left, Top: Integer); overload;
procedure MoveRect(var Rect: TRect; Pos: TPoint); overload;
function RightToLeftReflectPoint(const BaseRect: TRect; const APoint: TPoint): TPoint;
function RightToLeftReflectRect(const BaseRect: TRect; const ARect: TRect): TRect;

function LoadCursorEh(hInstance: HINST; lpCursorName: PChar): HCURSOR;
function LoadRegisterCursorEh(CursorName: String): TCursor;

procedure OutputDebugStringEh(str: String);
function GetCanvasScaleForStandardDpi(Canvas: TCanvas): Double;
procedure FillRectEh(ACanvas: TCanvas; ARect: TRect; AColor: TColor; ATransparencyLevel: Integer);
function ImListImageToBitmap(ImageList: TCustomImageList; ImageIndex: Integer): TBitmap;

function GetEhLibGUISysInfoAsString: String;
function GetEhLibFullSysInfoAsString: String;

implementation

uses
  LanguageResManEh
{$IFDEF EH_LIB_27} 
  ,GraphUtil
{$ELSE}
{$ENDIF}
  ;

var
  BackBitmap: TBitmap;

{$IFDEF FPC}
{$ELSE}
const
  PixelsQuad = MaxInt div SizeOf(TRGBQuad) - 1;
type
  TRGBAArray = Array [0..PixelsQuad - 1] of TRGBQuad;
  PRGBAArray = ^TRGBAArray;
{$ENDIF}

function ImListImageToBitmap(ImageList: TCustomImageList; ImageIndex: Integer): TBitmap;
var
  {$IFDEF ImageListGetBitmap}
  {$ELSE}
  ARGBVal: TRGBQuad;
  pscanLine32, pscanLine32_src: PRGBAArray;
  il, ip: Integer;
  SrcBitmap: TBitmap;
  SrcStartLine: Integer;
  PicsPreLine: Integer;
  StartInLine: Integer;
  TmpBitmap: TBitmap;
  PixelFormat: TPixelFormat;
  {$ENDIF}

  ResultBitmap: TBitmap;
begin
{$IFDEF ImageListGetBitmap}
  if (ImageIndex >= ImageList.Count) then
  begin
    Result := nil;
    Exit;
  end else
  begin
    ResultBitmap := TBitmap.Create();
    ImageList.GetBitmap(ImageIndex, ResultBitmap);
    Result := ResultBitmap;
  end;
{$ELSE} 

  TmpBitmap := TBitmap.Create;
  TmpBitmap.Handle := ImageList.GetImageBitmap;
  PixelFormat := TmpBitmap.PixelFormat;
  TmpBitmap.Free;

  if (PixelFormat <> pf32bit) then
  begin
    Result := TBitmap.Create();
    ImageList.GetBitmap(ImageIndex, Result);
    Exit;
  end;

{$IFDEF EH_LIB_12} 
  ResultBitmap := TBitmap.Create();
{$ELSE}
  ResultBitmap := TBitmapEh32bit.Create();
{$ENDIF}

  SrcBitmap := TBitmap.Create;
  SrcBitmap.Handle := ImageList.GetImageBitmap;

  ResultBitmap.Width := ImageList.Width;
  ResultBitmap.Height := ImageList.Height;
  ResultBitmap.PixelFormat := pf32bit;

{$IFDEF EH_LIB_12} 
  ResultBitmap.AlphaFormat := afDefined; 
{$ENDIF}

  PicsPreLine := SrcBitmap.Width div ImageList.Width;
  StartInLine := ImageIndex mod PicsPreLine * ImageList.Width;
  SrcStartLine := ImageIndex div PicsPreLine * ImageList.Height;
  for il := 0 to ImageList.Height - 1 do
  begin
    pscanLine32_src := SrcBitmap.ScanLine[il + SrcStartLine];
    pscanLine32 := ResultBitmap.Scanline[il];
    for ip := 0 to ImageList.Width - 1 do
      begin
        ARGBVal.rgbReserved := pscanLine32_src[ip + StartInLine].rgbReserved;
        ARGBVal.rgbBlue := pscanLine32_src[ip + StartInLine].rgbBlue;
        ARGBVal.rgbRed := pscanLine32_src[ip + StartInLine].rgbRed;
        ARGBVal.rgbGreen := pscanLine32_src[ip + StartInLine].rgbGreen;
        pscanLine32[ip] := ARGBVal;
      end;
  end;

  SrcBitmap.Free;

  Result := ResultBitmap;
  
{$ENDIF} 
end;

procedure FillRectEh(ACanvas: TCanvas; ARect: TRect; AColor: TColor; ATransparencyLevel: Integer);
var
  rw, rh: Integer;
  {$IFDEF FPC}
    {$IFDEF FPC_WINDOWS}
  bf: TBlendFunction;
    {$ELSE}
    {$ENDIF}
  {$ELSE}
  bf : BLENDFUNCTION;
  {$ENDIF}
begin

  rw := RectWidth(ARect);
  rh := RectHeight(ARect);

  if (rw <= 0) or (rh <= 0) then Exit;

  if (BackBitmap = nil) then
  begin
    BackBitmap := TBitmap.Create;
    BackBitmap.Width := rw;
    BackBitmap.Height := rh;
  end;

  if (BackBitmap.Width < rw) or (BackBitmap.Height < rh) then
  begin
    BackBitmap.Width := rw;
    BackBitmap.Height := rh;
  end;

  BackBitmap.Canvas.Brush.Color := AColor;
  BackBitmap.Canvas.FillRect(Rect(0, 0, rw, rh));

  {$IFDEF FPC}
    {$IFDEF FPC_WINDOWS}
  bf.BlendOp := AC_SRC_OVER;
  bf.BlendFlags := 0;
  bf.SourceConstantAlpha := ATransparencyLevel; 
  bf.AlphaFormat := 0;

  Win32Extra.AlphaBlend(ACanvas.Handle,
    ARect.Left, ARect.Top, rw, rh,
    BackBitmap.Canvas.Handle,
    0, 0, rw, rh,
    bf);
    {$ELSE}
  ACanvas.Brush.Color := AColor;
  ACanvas.FillRect(ARect);
    {$ENDIF}
  {$ELSE}
  bf.BlendOp := AC_SRC_OVER;
  bf.BlendFlags := 0;
  bf.SourceConstantAlpha := ATransparencyLevel; 
  bf.AlphaFormat := 0;

  AlphaBlend(ACanvas.Handle,
    ARect.Left, ARect.Top, rw, rh,
    BackBitmap.Canvas.Handle,
    0, 0, rw, rh,
    bf);
  {$ENDIF}
end;

function GetWindowPPIScreen(wnd: HWND): Integer;
{$IFDEF EH_LIB_26}  
var
  LMonitor: TMonitor;
begin
  if CheckWin32Version(6,3) then
  begin
    if wnd > 0 then
      LMonitor := Screen.MonitorFromWindow(wnd)
    else
      LMonitor := Screen.MonitorFromWindow(Application.Handle);
    if LMonitor <> nil then
      Result := LMonitor.PixelsPerInch
    else
      Result := Screen.PixelsPerInch;
  end
  else
    Result := Screen.PixelsPerInch;
end;
{$ELSE}
begin
  Result := Screen.PixelsPerInch;
end;
{$ENDIF}

function GetCanvasScaleForStandardDpi(Canvas: TCanvas): Double;
var
{$IFDEF EH_LIB_26}  
  wnd: HWND;
{$ELSE}
{$ENDIF}
  PixelsPerInch: Integer;
begin
  {$IFDEF EH_LIB_26}  
  wnd := WindowFromDC(Canvas.Handle);
  PixelsPerInch := GetWindowPPIScreen(wnd);
  {$ELSE}
  PixelsPerInch := GetDeviceCaps(Canvas.Handle, LOGPIXELSY);
  {$ENDIF}
  Result := PixelsPerInch / 96;
end;

function SysStrToFloat(const S: string): Extended;
var
  ASep: Char;
begin
  ASep := FormatSettings.DecimalSeparator;
  FormatSettings.DecimalSeparator := '.';
  try
    Result := StrToFloat(S);
  finally
    FormatSettings.DecimalSeparator := ASep;
  end;
end;

function SysFloatToStr(const Val: Extended): string;
var
  ASep: Char;
begin
  ASep := FormatSettings.DecimalSeparator;
  FormatSettings.DecimalSeparator := '.';
  try
    Result := FloatToStr(Val);
  finally
    FormatSettings.DecimalSeparator := ASep;
  end;
end;

procedure DoNothing();
begin
end;

procedure FreeObjectEh(obj: TObject);
begin
{$IFDEF NEXTGEN}
{$ELSE}
  obj.Free;
{$ENDIF}
end;

{$IFDEF MSWINDOWS}
function SetLayout(hdc: HDC; dwLayout: DWORD): DWORD; stdcall;
  external gdi32 name 'SetLayout';
{$ENDIF}

function SetLayoutEh(hdc: HDC; dwLayout: DWORD): DWORD;
begin
{$IFDEF MSWINDOWS}
  Result := SetLayout(hdc, dwLayout);
{$ELSE}
{ TODO : Make an implementation for MacOS and Linux. }
 
  Result := 0;
{$ENDIF}
end;

procedure OutputDebugStringEh(str: String);
begin
  {$IFDEF MSWINDOWS}
  Windows.OutputDebugString(PChar(str));
  {$ELSE}
  WriteLn(str);
  {$ENDIF}
end;

function LoadCursorEh(hInstance: HINST; lpCursorName: PChar): HCURSOR;
begin
  Result := LoadCursor(hInstance, lpCursorName);
  {$IFDEF MSWINDOWS}
  if Result = 0 then
    raise EOutOfResources.Create('Cannot load cursor resource');
  {$ELSE}
  {$ENDIF}
end;

function LoadRegisterCursorEh(CursorName: String): TCursor;
{$IFDEF LCLQT5}
begin
  Result  := 0;
end;
{$ELSE}
var
  i: TCursor;
  FreeCursor: HCURSOR;
begin

  {$IFDEF FPC}
  FreeCursor := 0;
  {$ELSE}
  FreeCursor := Screen.Cursors[0];
  {$ENDIF}

  for i := 1 to 32767 do
  begin
    if Screen.Cursors[i] = FreeCursor then
    begin
      Screen.Cursors[i] := LoadCursorEh(hInstance, PChar(CursorName));
      Result := i;
      Exit;
    end;
  end;

  
  raise Exception.Create('LoadRegisterCursorEh could not register cursor - "' + CursorName + '"');
end;
{$ENDIF}

function ChangeRect(const Rect: TRect; ChangeLeft, ChangeTop, ChangeRight, ChangeBottom: Integer): TRect;
begin
  Result.Left := Rect.Left + ChangeLeft;
  Result.Top := Rect.Top + ChangeTop;
  Result.Right := Rect.Right + ChangeRight;
  Result.Bottom := Rect.Bottom + ChangeBottom;
end;

procedure MoveRect(var Rect: TRect; Left, Top: Integer);
var
  Width, Height: Integer;
begin
  Width := RectWidth(Rect);
  Height := RectHeight(Rect);
  Rect.Left := Left;
  Rect.Top := Top;
  Rect.Right := Rect.Left + Width;
  Rect.Bottom := Rect.Top + Height;
end;

procedure MoveRect(var Rect: TRect; Pos: TPoint);
begin
  MoveRect(Rect, Pos.X, Pos.Y);
end;

procedure SwapInt(var a, b: Integer);
var
  c: Integer;
begin
  c := a;
  a := b;
  b := c;
end;

function RightToLeftReflectRect(const BaseRect: TRect; const ARect: TRect): TRect;
var
  p: TPoint;
  rw: Integer;
begin
  Result := ARect;
  p := RightToLeftReflectPoint(BaseRect, ARect.TopLeft);
  rw := RectWidth(ARect);
  Result.Right := p.X;
  Result.Left := Result.Right - rw;
end;

function RightToLeftReflectPoint(const BaseRect: TRect; const APoint: TPoint): TPoint;
var
  Centr: Integer;
begin
  Result.Y := APoint.Y;
  Centr := (BaseRect.Right + BaseRect.Left) div 2;
  if APoint.X < Centr then
    Result.X := BaseRect.Right - (APoint.X - BaseRect.Left)
  else
    Result.X := BaseRect.Left + (BaseRect.Right - APoint.X);
end;

{$IFNDEF EH_LIB_12}
function RectWidth(const Rect: TRect): Integer;
begin
  Result := Rect.Right - Rect.Left;
end;

function RectHeight(const Rect: TRect): Integer;
begin
  Result := Rect.Bottom - Rect.Top;
end;

function RectCenter(var R: TRect; const Bounds: TRect): TRect;
begin
  OffsetRect(R, -R.Left, -R.Top);
  OffsetRect(R, (RectWidth(Bounds) - RectWidth(R)) div 2, (RectHeight(Bounds) - RectHeight(R)) div 2);
  OffsetRect(R, Bounds.Left, Bounds.Top);
  Result := R;
end;
{$ENDIF}

function RectSize(const Rect: TRect): TSize;
begin
  Result.cx := RectWidth(Rect);
  Result.cy := RectHeight(Rect);
end;

function RectContains(const Rect: TRect; const P: TPoint): Boolean;
begin
  Result := PtInRect(Rect, P);
end;

function CreateRect(Left, Top, Right, Bottom: Integer): TRect;
begin
  Result := Rect(Left, Top, Right, Bottom);
end;

function RectF(ALeft, ATop, ARight, ABottom: Single): TRectF;
begin
  Result.Left := ALeft;
  Result.Top := ATop;
  Result.Right := ARight;
  Result.Bottom := ABottom;
end;

function PointF(x: Single; y: Single): TPointF;
begin
  Result.x := x;
  Result.y := y;
end;

function RectFWidth(const Rect: TRectF): Single;
begin
  Result := Rect.Right - Rect.Left;
end;

function RectFHeight(const Rect: TRectF): Single;
begin
  Result := Rect.Bottom - Rect.Top;
end;

function CreatePoint(x, y: Integer): TPoint;
begin
  Result.X := x;
  Result.Y := y;
end;

function CreateSize(cx, cy: Integer): TSize;
begin
  Result.cx := cx;
  Result.cy := cy;
end;

function GetTickCountEh: UInt64;
begin
  Result := EhLibUtils.GetTickCountEh;
end;

function SmallPointToPointEh(const P: TSmallPoint): TPoint;
begin
  Result.X := P.X;
  Result.Y := P.Y;
end;

procedure KillMessage(Wnd: HWnd; Msg: Integer);
var
  M: TMsg;
begin
  M.Message := 0;
  if PeekMessage(M, Wnd, UINT(Msg), UINT(Msg), pm_Remove) and (M.Message = WM_QUIT) then
    PostQuitMessageEh(M.wparam);
end;

function FirstDayOfWeekEh(): Integer; 
{$IFDEF WINDOWS}
var
  A: array[0..1] of char;
begin
  GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_IFIRSTDAYOFWEEK, A, SizeOf(A));
{$IFDEF MSWINDOWS}
  Result := Ord(A[0]) - Ord('0');
{$ELSE}
  { TODO : Make an implementation for NEXTGEN. }
  Result := 0;
{$ENDIF}
end;

{$ELSE} 
begin
  Result := -1;
end;
{$ENDIF} 

{ Functions }

{$IFDEF EH_LIB_16} 
{$ELSE}

var
  FStyleServices: TCustomStyleServices;

function StyleServices: TCustomStyleServices;
begin
  if FStyleServices = nil then
    FStyleServices := TCustomStyleServices.Create;
  Result := FStyleServices;
end;

{$ENDIF} 

{$IFNDEF EH_LIB_13}
function CenteredRect(const SourceRect: TRect; const ACenteredRect: TRect): TRect;
var
  Width, Height: Integer;
  X, Y: Integer;
begin
  Width := ACenteredRect.Right - ACenteredRect.Left;
  Height := ACenteredRect.Bottom - ACenteredRect.Top;
  X := (SourceRect.Right + SourceRect.Left) div 2;
  Y := (SourceRect.Top + SourceRect.Bottom) div 2;
  Result := Rect(X - Width div 2, Y - Height div 2, X + (Width + 1) div 2, Y + (Height + 1) div 2);
end;
{$ENDIF}

{$IFNDEF EH_LIB_14}
function PointToLParam(P: TPoint): LPARAM;
begin
  Result := LPARAM((P.X and $0000ffff) or (P.Y shl 16));
end;
{$ENDIF}

function StringToLParam(s: String): LPARAM;
begin
{$IFDEF FPC}
  Result := {%H-}LPARAM(PWideChar(UTF8ToUTF16(s)));
{$ELSE}
  Result := LPARAM(PChar(s));
{$ENDIF}
end;

function VarIsNullEh(const V: Variant): Boolean;
begin
  Result := TVarData(V).VType = varNull;
end;

procedure VarSetNull(var V: Variant);
const
  varDeepData = $BFE8;
begin
  if (TVarData(V).VType and varDeepData) = 0 then
    TVarData(V).VType := varNull
  else
  begin
    VarClear(V);
    TVarData(V).VType := varNull;
  end;
end;

function CharInSetEh(C: Char; const CharSet: TSysCharSet): Boolean;
begin
{$IFDEF EH_LIB_12}
  Result := CharInSet(C, CharSet);
{$ELSE}
  Result := C in CharSet;
{$ENDIF}
end;

function IsLeadCharEh(C: Char): Boolean;
begin
{$IFDEF NEXTGEN}
  Result := IsLeadChar(C);
{$ELSE}
  Result := CharInSetEh(C, LeadBytes);
{$ENDIF}
end;

function VarToAnsiStr(const V: Variant): AnsiString;
begin
  if not VarIsNull(V)
    then Result := AnsiString(V)
    else Result := AnsiString('');
end;

function IsObjectAndIntegerRefSame(AObject: TObject; IntRef: IntPtr): Boolean;
begin
  Result := (IntPtr(AObject) = IntRef);
end;

function IntPtrToObject(AIntPtr: IntPtr): TObject;
begin
  Result := TObject(AIntPtr);
end;

function ObjectToIntPtr(AObject: TObject): IntPtr;
begin
  Result := IntPtr(AObject);
end;

function IntPtrToString(AIntPtr: IntPtr): String;
begin
{$WARNINGS OFF}
{$HINTS OFF}
  Result := String(PChar(AIntPtr));
{$HINTS ON}
{$WARNINGS ON}
end;

function DataSetCompareBookmarks(DataSet: TDataSet; Bookmark1, Bookmark2: TUniBookmarkEh): Integer;
begin
  Result := DataSet.CompareBookmarks(TBookmark(Bookmark1), TBookmark(Bookmark2));
end;

function DataSetBookmarkValid(DataSet: TDataSet; Bookmark: TUniBookmarkEh): Boolean;
begin
  Result := (Bookmark <> NilBookmarkEh) and DataSet.BookmarkValid(TBookmark(Bookmark));
end;

type
  TWinControlCrack = class(TWinControl);

function GetAdjustedClientRect(Control: TWinControl): TRect;
begin
  if (Control.HandleAllocated) then
    Result := Control.ClientRect
  else
    Result := Rect(0, 0, Control.Width, Control.Height);

  TWinControlCrack(Control).AdjustClientRect(Result);
end;

var
  ScreenCanvas: TCanvas;

function GetScreenCanvas: TCanvas;
begin
  if (ScreenCanvas = nil) then
  begin
    ScreenCanvas := TCanvas.Create;
    ScreenCanvas.Handle := GetDC(0);
  end;
  Result := ScreenCanvas;
end;

procedure FreeScreenCanvas;
begin
  if (ScreenCanvas <> nil) then
  begin
    ReleaseDC(0, ScreenCanvas.Handle);
    ScreenCanvas.Handle := 0;
  end;
  FreeAndNil(ScreenCanvas);
end;

const
  LayoutToVertAlignment: array [TTextLayout] of TVerticalAlignment = (taAlignTop, taVerticalCenter, taAlignBottom);
                               

procedure DrawTextEh(Canvas: TCanvas; Text: String; ARect: TRect; ClipRect: TRect;
  Alignment: TAlignment; Layout: TTextLayout; WrapStyle: TTextWrapStyleEh; FillBack: Boolean = False); overload;
var
  Options: TDrawTextOptionsEh;
begin
  Options.HorzAlignment := Alignment;
  Options.VertAlignment := LayoutToVertAlignment[Layout];
  Options.WrapStyle := WrapStyle;
  Options.FillBack := FillBack;
  Options.BiDiMode := Application.BiDiMode;
  Options.EndEllipsis := False;

  DrawTextEh(Canvas, Text, ARect, ClipRect, Options);
end;

procedure DrawTextEh(Canvas: TCanvas; Text: String; ARect: TRect;
  Alignment: TAlignment; Layout: TTextLayout; WrapStyle: TTextWrapStyleEh; FillBack: Boolean = False); overload;
var
  Options: TDrawTextOptionsEh;
begin
  Options.HorzAlignment := Alignment;
  Options.VertAlignment := LayoutToVertAlignment[Layout];
  Options.WrapStyle := WrapStyle;
  Options.FillBack := FillBack;
  Options.BiDiMode := Application.BiDiMode;
  Options.EndEllipsis := False;

  DrawTextEh(Canvas, Text, ARect, EmptyRect, Options);
end;

procedure DrawTextEh(Canvas: TCanvas; Text: String; ARect: TRect; FillBack: Boolean = False); overload;
var
  Options: TDrawTextOptionsEh;
begin
  Options.HorzAlignment := taLeftJustify;
  Options.VertAlignment := TVerticalAlignment.taAlignTop;
  Options.WrapStyle := twsNoWrapEh;
  Options.FillBack := FillBack;
  Options.BiDiMode := Application.BiDiMode;
  Options.EndEllipsis := False;

  DrawTextEh(Canvas, Text, ARect, EmptyRect, Options);
end;

function GetTextExtentPointEh(Canvas: TCanvas; Text: String; out StringSize: TSize): TIntegerDynArray;
var
  MaxChars: Integer;
begin
  Result := nil;
  StringSize.cx := 0;
  StringSize.cy := 0;
  SetLength(Result, Length(Text));
  GetTextExtentExPoint(Canvas.Handle, PChar(Text), Length(Text),
   10000, 
   @MaxChars, @Result[0], StringSize);
end;

function StringNextCharPos(S: String; APos: Integer): Integer;
begin
  Result := APos;
  {$IFDEF FPC}
  Result := Result + UTF8CodePointSize(@S[APos]);
  {$ELSE}
  Result := Result + 1;
  {$ENDIF}
end;

{ TDrawTextOptionsEh }

procedure TDrawTextOptionsEh.Clear;
begin
  HorzAlignment := TAlignment.taLeftJustify;
  VertAlignment := TVerticalAlignment.taAlignTop;
  WrapStyle := twsNoWrapEh;
  BiDiMode := bdLeftToRight;
  EndEllipsis := False;
  RotationAngle := 0;
end;

procedure DrawTextEh(Canvas: TCanvas; Text: String; ARect: TRect; ClipRect: TRect;
  var Options: TDrawTextOptionsEh);
const
  AlignFlags: array[TAlignment] of UINT =
  (DT_LEFT or DT_EXPANDTABS or DT_NOPREFIX,
    DT_RIGHT or DT_EXPANDTABS or DT_NOPREFIX,
    DT_CENTER or DT_EXPANDTABS or DT_NOPREFIX);
  RTL: array[Boolean] of UINT = (0, DT_RTLREADING);
var
  DrawFlag: UINT;
  TextRect: TRect;
  TextHeight: Integer;
  {$IFDEF FPC}
  RestRgn: HRgn;
  DrawRect: TRect;
  {$ELSE}
  {$ENDIF}
  OldBrushStyle: TBrushStyle;
begin

  {$IFDEF FPC}
  DrawRect := ARect;
  {$ELSE}
  {$ENDIF}
  DrawFlag := 0;

  if Options.WrapStyle = twsWordWrapEh then
    DrawFlag := DrawFlag or DT_WORDBREAK
  else if Options.WrapStyle = twsSingleLineEh then
    DrawFlag := DrawFlag or DT_SINGLELINE;

  if (Options.EndEllipsis = True) then
    DrawFlag := DrawFlag or DT_END_ELLIPSIS;

  DrawFlag := DrawFlag or
              AlignFlags[Options.HorzAlignment] or
              RTL[(Options.BiDiMode <> bdLeftToRight)];

  OldBrushStyle := Canvas.Brush.Style;
  if Options.FillBack
    then Canvas.Brush.Style := bsSolid
    else Canvas.Brush.Style := bsClear;

  TextRect := ARect;

  if Options.VertAlignment <> taAlignTop then
  begin
    TextHeight := WindowsDrawTextEx(Canvas.Handle, Text, ARect, DrawFlag or DT_CALCRECT);
    case Options.VertAlignment of
      taAlignBottom: TextRect.Top := TextRect.Bottom - TextHeight;
      taVerticalCenter: TextRect.Top := (TextRect.Bottom + TextRect.Top - TextHeight) div 2;
    end;
  end;

  {$IFDEF FPC}
  {$ELSE}
  WindowsDrawTextEx(Canvas.Handle, Text, TextRect, DrawFlag);
  {$ENDIF}

  if (OldBrushStyle <> Canvas.Brush.Style) then
    Canvas.Brush.Style := OldBrushStyle;
end;

function GetMessageTimeEh: Integer;
begin
  Result := Windows.GetMessageTime;
end;

function EditorGetCaretPosEh(Control: TWinControl): Integer;
var
  P: TPoint;
  IntPos: Integer;
begin
  P := Point(0, 0);
  Windows.GetCaretPos(P);
  IntPos := SendMessage(Control.Handle, EM_CHARFROMPOS, 0, MakeLong(P.X, P.Y));
  Result := TSmallPoint(IntPos).x;
end;

function DrawTextEh(hDC: HDC; const Text: String; nCount: Integer;
  var lpRect: TRect; uFormat: UINT): Integer;
{$IFDEF FPC}
var
  w: WideString;
{$ELSE}
{$ENDIF}
begin
{$IFDEF FPC}
  w := LazUTF8.UTF8ToUTF16(Text);
  Result := Windows.DrawTextW(hDC, PWideChar(w), Length(w), lpRect, uFormat);
{$ELSE}
  Result := DrawText(hDC, PChar(Text), nCount, lpRect, uFormat);
{$ENDIF}
end;

function WindowsDrawTextEx(DC: HDC; const lpchText: String;
  var p4: TRect;  dwDTFormat: UINT; DTParams: TDrawTextParams): Integer;
var
{$IFDEF FPC}
  w: WideString;
{$ELSE}
{$ENDIF}
  cchText: Integer;
begin
{$IFDEF FPC}
  w := LazUTF8.UTF8ToUTF16(lpchText);
  cchText := Length(w);
  Result := Windows.DrawTextExW(DC, PWideChar(w), cchText, p4, dwDTFormat, @DTParams);
{$ELSE}
  cchText := Length(lpchText);
  Result := DrawTextEx(DC, PChar(lpchText), cchText, p4, dwDTFormat, @DTParams);
{$ENDIF}
end;

function WindowsDrawTextEx(DC: HDC; const lpchText: String;
  var p4: TRect;  dwDTFormat: UINT): Integer; overload;
var
{$IFDEF FPC}
  w: WideString;
{$ELSE}
{$ENDIF}
  cchText: Integer;
begin
{$IFDEF FPC}
  w := LazUTF8.UTF8ToUTF16(lpchText);
  cchText := Length(w);
  Result := Windows.DrawTextExW(DC, PWideChar(w), cchText, p4, dwDTFormat, nil);
{$ELSE}
  cchText := Length(lpchText);
  Result := DrawTextEx(DC, PChar(lpchText), cchText, p4, dwDTFormat, nil);
{$ENDIF}
end;

function WindowsExtTextOut(DC: HDC; X, Y: Integer; Options: Integer;
  var Rect: TRect; const Str: String; Count: Integer{; Dx: PInteger}): BOOL;
begin
  Result := ExtTextOut(DC, X, Y, Options,
    @Rect, PChar(Str), Count, nil);
end;

function WindowsGetOutlineTextMetrics(DC: HDC; p2: UINT; var OTMetricStructs: TOutlineTextMetric): UINT;
begin
  Result := GetOutlineTextMetrics(DC, p2, @OTMetricStructs);
end;

function GetNearestColor(hDC: HDC; Color: TColor): TColor;
begin
  Result := Windows.GetNearestColor(hDC, Color);
end;

procedure SetWindowDropShadowStyle(Control: TWinControl; var Params: TCreateParams; SetState: Boolean);
begin
  if CheckWin32Version(5, 1) and SetState then
    Params.WindowClass.Style := Params.WindowClass.Style or CS_DROPSHADOW
  else
    Params.WindowClass.Style := Params.WindowClass.Style and not CS_DROPSHADOW;
end;

procedure SetWindowDropDownNoactivateStyle(Control: TWinControl; var Params: TCreateParams; SetState: Boolean);
begin
  if SetState then
    Params.ExStyle := Params.ExStyle or WS_EX_NOACTIVATE
  else
    Params.WindowClass.Style := Params.WindowClass.Style and not WS_EX_NOACTIVATE;
end;

function GetDesktopWindowEh: HWND;
begin
  Result := GetDesktopWindow;
end;

function MiddleDotChar: Char;
begin
  {$IFDEF FPC}
  Result := '.';
  {$ELSE}
  Result := Char($B7);
  {$ENDIF}
end;

function SendStructMessage(hWnd: HWND; Msg: UINT; wParam: WPARAM; var lParam): LRESULT;
begin
  Result := SendMessage(hWnd, Msg, wParam, NativeInt(@lParam));
end;

function SendTextMessage(hWnd: HWND; Msg: UINT; wParam: WPARAM; const lParam: string): LRESULT;
begin
  Result := SendMessage(hWnd, Msg, wParam, NativeInt(PChar(lParam)));
end;

function SendGetTextMessage(hWnd: HWND; Msg: UINT; wParam: WPARAM; var lParam: String; BufferSize: Integer): LRESULT;
var
  Text: array[0..4095] of Char;
begin
  Word((@Text)^) := SizeOf(Text);
  Result := SendMessage(hWnd, HWND, wParam, NativeInt(@Text));
  System.SetString(lParam, Text, Result);
end;

function SystemParametersInfoEh(uiAction, uiParam: UINT; var pvParam; fWinIni: UINT): BOOL;
begin
  Result := SystemParametersInfo(uiAction, uiParam, @pvParam, fWinIni);
end;

function WindowsInvalidateRect(hWnd: HWND; var Rect: TRect; bErase: BOOL): BOOL;
begin
  Result := InvalidateRect(hWnd, @Rect, bErase);
end;

function WindowsValidateRect(hWnd: HWND; var Rect: TRect): BOOL;
begin
  {$IFDEF FPC}
  Result := False;
  {$ELSE}
  Result := ValidateRect(hWnd, @Rect);
  {$ENDIF}
end;

function WindowsScrollWindowEx(hWnd: HWND; dx, dy: Integer;
  var prcScroll,  prcClip: TRect;
  hrgnUpdate: HRGN; flags: UINT): Boolean;
begin
  Result := ScrollWindowEx(hWnd, dx, dy, @prcScroll, @prcClip,
    hrgnUpdate, nil, flags);
end;

function WindowsScrollWindow(hWnd: HWND; dx, dy: Integer; var prcScroll, prcClip: TRect): BOOL;
begin
  Result := ScrollWindow(hWnd, dx, dy, @prcScroll, @prcClip);
end;

procedure WinServiceSetFocus(hWnd: HWND);
begin
  {$IFDEF FPC_CROSSP}
  LCLIntf.SetFocus(hWnd);
  {$ELSE}
  Windows.SetFocus(hWnd);
  {$ENDIF}
end;

{$IFDEF FPC_CROSSP}
function  WinServiceIsChild(hWndParent, hWnd: HWND): Boolean;
var
  pWnd: hWnd;
begin
  pWnd := hWnd;
  Result := False;
  while True do
  begin
    pWnd := GetParent(pWnd);
    if (pWnd = 0) then Exit;
    if (pWnd = hWndParent) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;
{$ELSE}
function  WinServiceIsChild(hWndParent, hWnd: HWND): Boolean;
begin
  Result := Windows.IsChild(hWndParent, hWnd);
end;
{$ENDIF}

procedure VarToMessage(var VarMessage; var Message: TMessage);
begin
  Message := TMessage(VarMessage);
end;

function MessageToTMessage(var Message): TMessage;
begin
  Result := TMessage(Message);
end;

function MessageToTWMMouse(var Message): TWMMouse;
begin
  Result := TWMMouse(Message);
end;

function MessageToTWMKey(var Message): TWMKey;
begin
  Result := TWMKey(Message);
end;

function UnwrapMessageEh(var Message): TMessage;
begin
  Result := TMessage(Message);
end;

function SmallPointToInteger(SmallPoint: TSmallPoint): Integer;
begin
  Result := Integer(SmallPoint);
end;

function LongintToSmallPoint(Value: Longint): TSmallPoint;
begin
  Result := TSmallPoint(Value);
end;

function WindowsLPtoDP(DC: HDC; var ARect: TRect): BOOL;
begin
  Result := LPtoDP(DC, ARect, 2);
end;

function WindowsCreatePolygonRgn(Points: array of TPoint; Count, FillMode: Integer): HRGN;
begin
  Result := CreatePolygonRgn(Points, Count, FillMode);
end;

function GetFontSize(Font: TFont): Integer;
{$IFDEF FPC}
var
  FDat: TFontData;
begin
  if (Font.Size <> 0) then
  begin
    Result := Font.Size;
  end else
  begin
    FDat := GetFontData(Font.Handle);
    Result := Round(FDat.Height * 72 / Font.PixelsPerInch);
    if (Result < 0) then
       Result := -Result;
  end;
{$ELSE}
begin
  Result := Font.Size;
{$ENDIF}
end;

function GetFontHeight(Font: TFont): Integer;
{$IFDEF FPC}
begin
  Result := Abs(GetFontData(Font.Reference.Handle).Height);
end;
{$ELSE}
begin
  Result := -Font.Height;
end;
{$ENDIF}

function GetFontTextHeight(Canvas: TCanvas; Font: TFont; IncludeExternalLeading: Boolean = True): Integer;
var
  ACanvas: TCanvas;
  tm: TTextMetric;
begin
  if (Canvas = nil) or (not Canvas.HandleAllocated) then
  begin
    ACanvas := GetScreenCanvas;
  end else
  begin
    ACanvas := Canvas;
  end;

  ACanvas.Font := Font;
  GetTextMetrics(ACanvas.Handle, tm);
  Result := tm.tmHeight;
  if (IncludeExternalLeading) then
     Result := Result + tm.tmExternalLeading;
end;

procedure GetTextMetricsEh(Canvas: TCanvas; out tm: TTextMetric);
var
  ACanvas: TCanvas;
begin
  if (Canvas = nil) or (not Canvas.HandleAllocated) then
  begin
    ACanvas := GetScreenCanvas;
    ACanvas.Font := Canvas.Font;
  end else
  begin
    ACanvas := Canvas;
  end;

  GetTextMetrics(ACanvas.Handle, {%H-}tm);
end;

procedure GetTextMetricsEh(AFontName: String; AFontSize: Integer;
  AFontStyle: TFontStyles; out tm: TTextMetric);
var
  ACanvas: TCanvas;
begin
  ACanvas := GetScreenCanvas;
  ACanvas.Font.Name := AFontName;
  ACanvas.Font.Size := AFontSize;
  ACanvas.Font.Style := AFontStyle;

  GetTextMetrics(ACanvas.Handle, {%H-}tm);
end;

procedure PolyPolyLineEh(Canvas: TCanvas; const PointsList: TPointArrayEh; const StrokeList: TDWORDArrayEh; VCount: Integer);
{$IFDEF FPC_CROSSP}
var
  i: Integer;
  pos: Integer;
begin
  pos := 0;
  for i := 0 to VCount-1 do
  begin
    Canvas.PolyLine(PointsList, pos, StrokeList[i]);
    pos := pos + Integer(StrokeList[i]);
  end;
end;
{$ELSE}
begin
  PolyPolyLine(Canvas.Handle, Pointer(PointsList)^, Pointer(StrokeList)^, VCount);
end;
{$ENDIF}

procedure MessageSendGetSel(hWnd: HWND; var SelStart, SelEnd: Integer);
{$IFDEF WINDOWS}
begin
  {$HINTS OFF}
  SendMessage(hWnd, EM_GETSEL, WPARAM(@SelStart), LPARAM(@SelEnd));
  {$HINTS ON}
end;
{$ELSE} 
begin
  SelStart := 0;
  SelEnd := 0;
end;
{$ENDIF} 

procedure EditControlSetSel(Control: TCustomEdit; SelStart, SelEnd: Integer);
{$IFDEF WINDOWS}
begin
  SendMessage(Control.Handle, EM_SETSEL, WPARAM(SelStart), LPARAM(SelEnd));
end;
{$ELSE}
begin
  if (SelStart > SelEnd) then
    SwapInt(SelStart, SelEnd);
  Control.SelStart := SelStart;
  Control.SelLength := SelEnd - SelStart;
end;
{$ENDIF}

procedure PostQuitMessageEh(nExitCode: Integer);
{$IFDEF WINDOWS}
begin
  PostQuitMessage(nExitCode);
end;
{$ELSE}
begin
  PostMessage(Application.MainFormHandle, WM_QUIT, nExitCode, 0);
end;
{$ENDIF}

function NlsUpperCase(const S: String): String;
begin
  Result := AnsiUpperCase(S);
end;

function NlsLowerCase(const S: String): String;
begin
  Result := AnsiLowerCase(S);
end;

function NlsCompareStr(const S1, S2: String): Integer;
begin
  Result := AnsiCompareStr(S1, S2);
end;

function NlsCompareText(const S1, S2: String): Integer;
begin
  Result := AnsiCompareText(S1, S2);
end;

{$IFNDEF EH_LIB_9}
function ReplaceStr(const AText, AFromText, AToText: string): string;
begin
  Result := AnsiReplaceStr(AText, AFromText, AToText);
end;
{$ENDIF}

procedure BitmapLoadFromResourceName(Bmp: TBitmap; Instance: THandle; const ResName: String);
begin
{$IFDEF NEXTGEN}
{ TODO : Make an implementation for MacOS and Linux. LoadBitmap(OBM_CHECK)}
 
  Bmp.LoadFromResourceName(Instance, ResName);
{$ELSE}
  Bmp.LoadFromResourceName(Instance, ResName);
{$ENDIF}
end;

function LoadBitmapEh(hInstance: HINST; lpBitmapID: Integer): HBITMAP;
begin
{$IFDEF NEXTGEN}
  Result := LoadBitmap(hInstance, PChar(lpBitmapID));
{$ELSE}
  {$HINTS OFF}
  {$WARNINGS OFF}
  Result := LoadBitmap(hInstance, PChar(lpBitmapID));
  {$WARNINGS ON}
  {$HINTS ON}
{$ENDIF}
end;

function GetPropListAsArray(ATypeInfo: PTypeInfo; TypeKinds: TTypeKinds): TPropListArray;
var
  PropCount: Integer;
begin
  PropCount := GetPropList(ATypeInfo, tkProperties, nil);
  Result := nil;
  SetLength(Result, PropCount);
  GetPropList(ATypeInfo, tkProperties, PPropList(Result));
end;

procedure BinToHexEh(Buffer: TBytes; out Text: String; Count: Integer);
{$IFDEF EH_LIB_22}
var
  aData, aBuff: TBytes;
begin
    SetLength(aBuff, Count * 2);
    BinToHex(aData, 0, aBuff, 0, Count);
    Text := StringOf(aBuff);
end;
{$ELSE}
var
  AnsiText: AnsiString;
begin
  System.SetString(AnsiText, nil, Count*2);
  BinToHex(PAnsiChar(Buffer), PAnsiChar(AnsiText), Count);
  Text := String(AnsiText);
end;
{$ENDIF}

procedure StreamWriteBytes(Stream: TStream; Buffer: TBytes);
begin
  Stream.Write(Pointer(Buffer)^, Length(Buffer));
end;

procedure StreamReadBytes(Stream: TStream; var Buffer: TBytes; Count: Integer);
var
  bs: AnsiString;
  i: Integer;
begin
  SetLength(Buffer, Count);
  System.SetString(bs, nil, Count);
  Stream.Read(Pointer(bs)^, Count);
  for i := 0 to Length(bs)-1 do
    Buffer[i] := Byte(bs[i+1]);
end;

{$IFNDEF EH_LIB_13}
function BytesOf(S: String): TBytes; overload;
var
  i: Integer;
begin
  Result := nil;
  SetLength(Result, Length(S));
  for i := 0 to Length(S)-1 do
    Result[i] := Byte(AnsiChar(S[i+1]));
end;
{$ENDIF}

{$IFNDEF EH_LIB_17}
function BytesOf(const Val: Pointer; const Len: integer): TBytes; overload;
begin
  Result := nil;
  SetLength(Result, Len);
  System.Move(PByte(Val)^, Result[0], Len);
end;
{$ENDIF}

function PropInfo_getPropType(APropInfo: PPropInfo): PTypeInfo;
begin
  {$IFDEF FPC}
  Result := APropInfo^.PropType;
  {$ELSE}
  Result := APropInfo^.PropType^;
  {$ENDIF}
end;

function PropInfo_getName(APropInfo: PPropInfo): String;
begin
{$IFDEF NEXTGEN}
  Result := GetPropName(APropInfo);
{$ELSE}
  Result := String(APropInfo^.Name);
{$ENDIF}
end;

function PropType_getKind(APropType: PTypeInfo): TTypeKind;
begin
  Result := APropType^.Kind;
end;

function GetEnumPropValueAsString(Instance: TObject; const PropName: string): String;
var
  PropInfo: PPropInfo;
  PropType: PTypeInfo;
  Value: Integer;
begin
  PropInfo := GetPropInfo(Instance, PropName);
  Value := GetOrdProp(Instance, PropInfo);
  PropType := PropInfo_getPropType(PropInfo);
  Result := GetEnumName(PropType, Value);
end;

procedure SetEnumPropValueAsString(Instance: TObject; const PropName: string; AValue: String);
var
  PropInfo: PPropInfo;
  PropType: PTypeInfo;
  Value: Integer;
begin
  PropInfo := GetPropInfo(Instance, PropName);
  PropType := PropInfo_getPropType(PropInfo);
  Value := GetEnumValue(PropType, AValue);
  SetOrdProp(Instance, PropInfo, Value);
end;

procedure VarArrayRedimEh(var A : Variant; HighBound: Integer);
begin
  VarArrayRedim(A, HighBound);
end;

function EmptyRect: TRect;
begin
  Result := Rect(0, 0, 0, 0);
end;

function IsRectEmptyEh(const Rect: TRect): Boolean;
begin
  Result := (Rect.Right <= Rect.Left) or (Rect.Bottom <= Rect.Top);
end;

type
  TPersistentCracker = class(TPersistent);
  TComponentCracker = class(TComponent);

{ TFilerAccess }

constructor TFilerAccess.Create(APersistent: TPersistent);
begin
  inherited Create;
  FPersistent := APersistent;
end;

procedure TFilerAccess.DefineProperties(AFiler: TFiler);
begin
  TPersistentCracker(FPersistent).DefineProperties(AFiler);
end;

function TFilerAccess.GetChildOwner: TComponent;
begin
  Result := TComponentCracker(FPersistent).GetChildOwner;
end;

function TFilerAccess.GetChildParent: TComponent;
begin
  Result := TComponentCracker(FPersistent).GetChildParent;
end;

procedure TFilerAccess.GetChildren(Proc: TGetChildProc; Root: TComponent);
begin
  TComponentCracker(FPersistent).GetChildren(Proc, Root);
end;

procedure TFilerAccess.SetAncestor(Value: Boolean);
begin
  TComponentCracker(FPersistent).SetAncestor(Value);
end;

procedure TFilerAccess.SetChildOrder(Child: TComponent; Order: Integer);
begin
  TComponentCracker(FPersistent).SetChildOrder(Child, Order);
end;

procedure TFilerAccess.Updated;
begin
  TComponentCracker(FPersistent).Updated;
end;

procedure TFilerAccess.Updating;
begin
  TComponentCracker(FPersistent).Updating;
end;

{ TMemoryStream }

constructor TMemoryStreamEh.Create;
begin
  inherited Create;
  HalfMemoryDelta := $1000;
end;

{$IFDEF FPC}
function TMemoryStreamEh.Realloc(var NewCapacity: PtrInt): Pointer;
begin
  Result := inherited Realloc(NewCapacity);
end;
{$ELSE}
  {$IFDEF EH_LIB_28}
function TMemoryStreamEh.Realloc(var NewCapacity: NativeInt): Pointer;
  {$ELSE}
function TMemoryStreamEh.Realloc(var NewCapacity: System.Longint): Pointer;
  {$ENDIF}
var
  MemoryDelta: Integer;
begin
  MemoryDelta := HalfMemoryDelta * 2;
  if (NewCapacity > 0) and (NewCapacity <> Size) then
    NewCapacity := (NewCapacity + (MemoryDelta - 1)) and not (MemoryDelta - 1);
  Result := Memory;
  if NewCapacity <> Capacity then
  begin
    if NewCapacity = 0 then
    begin
  {$IFDEF MSWINDOWS}
      GlobalFreePtr(Memory);
  {$ELSE}
      FreeMem(Memory);
  {$ENDIF}
      Result := nil;
    end else
    begin
  {$IFDEF MSWINDOWS}
{$WARNINGS OFF}
      if Capacity = 0 then
        Result := GlobalAllocPtr(HeapAllocFlags, NewCapacity)
      else
        Result := GlobalReallocPtr(Memory, NewCapacity, HeapAllocFlags);
{$WARNINGS ON}
  {$ELSE}
      if Capacity = 0 then
        GetMem(Result, NewCapacity)
      else
        ReallocMem(Result, NewCapacity);
  {$ENDIF}
      if Result = nil then raise EStreamError.CreateRes(@SMemoryStreamError);
    end;
  end;
end;
{$ENDIF}

procedure DataVarCast(var Dest: Variant; const Source: Variant; AVarType: Integer);
begin
  if VarIsNull(Source) then
    Dest := Null
  else if AVarType = varVariant then
    Dest := Source
  else
    VarCast(Dest, Source, AVarType);
end;

function VarTypeName(varValue: Variant): String;
var
  basicType  : Integer;
begin
  basicType := VarType(varValue) and VarTypeMask;

  case basicType of
    varEmpty     : Result := 'varEmpty';
    varNull      : Result := 'varNull';
    varSmallInt  : Result := 'varSmallInt';
    varInteger   : Result := 'varInteger';
    varSingle    : Result := 'varSingle';
    varDouble    : Result := 'varDouble';
    varCurrency  : Result := 'varCurrency';
    varDate      : Result := 'varDate';
    varOleStr    : Result := 'varOleStr';
    varDispatch  : Result := 'varDispatch';
    varError     : Result := 'varError';
    varBoolean   : Result := 'varBoolean';
    varVariant   : Result := 'varVariant';
    varUnknown   : Result := 'varUnknown';
    varByte      : Result := 'varByte';
    varWord      : Result := 'varWord';
    varLongWord  : Result := 'varLongWord';
    varInt64     : Result := 'varInt64';
    varStrArg    : Result := 'varStrArg';
    varString    : Result := 'varString';
    varAny       : Result := 'varAny';
    varTypeMask  : Result := 'varTypeMask';
    else
      Result := '(Unknown type)';
  end;
end;

function RemoveLineBreaksFromText(Text: String): String;
var
  i, k: Integer;
begin
  k := 0;
  for i := Length(Text) downto 1 do
  begin
    if (Text[i] = #13) or (Text[i] = #10) then
      k := i
    else
      Break;
  end;
  if k > 0 then
    Result := Copy(Text, 1, k-1)
  else
    Result := Text;

  Result := StringReplace(Result, #13#10, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #10#13, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #10, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #13, ' ', [rfReplaceAll]);
end;

procedure DataVarCastAsObject(var Dest: Variant; const Source: Variant);
begin
  DataVarCast(Dest, Source, varVariant);
end;

function VarToWideStr(const V: Variant): WideString;
begin
  if not VarIsNull(V) then
    Result := V
  else
    Result := '';
end;

function RefObjectToVariant(ARefObject: TObject): Variant;
begin
  Result := EhLibUtils.RefObjectToVariant(ARefObject);
end;

function VariantToRefObject(VarValue: Variant): TObject;
begin
  Result := EhLibUtils.VariantToRefObject(VarValue);
end;

function SafeGetMouseCursorPos: TPoint;
begin
  {$IFDEF FPC_LINUX}
  Result := Point(0, 0);
  {$ELSE}
  if not GetCursorPos(Result) then
    Result := Point(0, 0);
  {$ENDIF}
end;

{$IFDEF EH_LIB_16} 
{$ELSE}

{ TCustomStyleServices }

function TCustomStyleServices.GetSystemColor(Color: TColor): TColor;
begin
  Result := Color;
end;

function TCustomStyleServices.GetElementColor(Details: TThemedElementDetails;
  ElementColor: TElementColor; out Color: TColor): Boolean;
begin
  {$IFDEF FPC}
  Color := $B8C7CB;
  Result := True;
  {$ELSE}
  Result := GetThemeColor(ThemeServices.Theme[Details.Element], Details.Part, Details.State,
    Integer(ElementColor) + TMT_BORDERCOLOR, TColorRef(Color)) = S_OK;
  {$ENDIF}
end;

procedure TCustomStyleServices.DrawElement(DC: HDC;
  Details: TThemedElementDetails; const R: TRect);
begin
  ThemeServices.DrawElement(DC, Details, R);
end;

procedure TCustomStyleServices.DrawElement(DC: HDC;
  Details: TThemedElementDetails; const R: TRect; ClipRect: TRect);
begin
  {$IFDEF FPC}
  ThemeServices.DrawElement(DC, Details, R, @ClipRect);
  {$ELSE}
  ThemeServices.DrawElement(DC, Details, R, ClipRect);
  {$ENDIF}
end;

function TCustomStyleServices.GetThemesEnabled: Boolean;
begin
  Result := ThemeServices.ThemesEnabled;
end;

function TCustomStyleServices.GetElementDetails(Detail: TThemedButton): TThemedElementDetails;
begin
  Result := ThemeServices.GetElementDetails(Detail);
end;

function TCustomStyleServices.GetElementDetails(Detail: TThemedClock): TThemedElementDetails;
begin
  Result := ThemeServices.GetElementDetails(Detail);
end;

function TCustomStyleServices.GetElementDetails(Detail: TThemedComboBox): TThemedElementDetails;
begin
  Result := ThemeServices.GetElementDetails(Detail);
end;

function TCustomStyleServices.GetElementDetails(Detail: TThemedEdit): TThemedElementDetails;
begin
  Result := ThemeServices.GetElementDetails(Detail);
end;

function TCustomStyleServices.GetElementDetails(Detail: TThemedExplorerBar): TThemedElementDetails;
begin
  Result := ThemeServices.GetElementDetails(Detail);
end;

function TCustomStyleServices.GetElementDetails(Detail: TThemedHeader): TThemedElementDetails;
begin
  Result := ThemeServices.GetElementDetails(Detail);
end;

function TCustomStyleServices.GetElementDetails(Detail: TThemedListView): TThemedElementDetails;
begin
  Result := ThemeServices.GetElementDetails(Detail);
end;

function TCustomStyleServices.GetElementDetails(Detail: TThemedMenu): TThemedElementDetails;
begin
  Result := ThemeServices.GetElementDetails(Detail);
end;

function TCustomStyleServices.GetElementDetails(Detail: TThemedPage): TThemedElementDetails;
begin
  Result := ThemeServices.GetElementDetails(Detail);
end;

function TCustomStyleServices.GetElementDetails(Detail: TThemedProgress): TThemedElementDetails;
begin
  Result := ThemeServices.GetElementDetails(Detail);
end;

function TCustomStyleServices.GetElementDetails(Detail: TThemedRebar): TThemedElementDetails;
begin
  Result := ThemeServices.GetElementDetails(Detail);
end;

function TCustomStyleServices.GetElementDetails(Detail: TThemedScrollBar): TThemedElementDetails;
begin
  Result := ThemeServices.GetElementDetails(Detail);
end;

function TCustomStyleServices.GetElementDetails(Detail: TThemedSpin): TThemedElementDetails;
begin
  Result := ThemeServices.GetElementDetails(Detail);
end;

function TCustomStyleServices.GetElementDetails(Detail: TThemedStartPanel): TThemedElementDetails;
begin
  Result := ThemeServices.GetElementDetails(Detail);
end;

function TCustomStyleServices.GetElementDetails(Detail: TThemedStatus): TThemedElementDetails;
begin
  Result := ThemeServices.GetElementDetails(Detail);
end;

function TCustomStyleServices.GetElementDetails(Detail: TThemedTab): TThemedElementDetails;
begin
  Result := ThemeServices.GetElementDetails(Detail);
end;

function TCustomStyleServices.GetElementDetails(Detail: TThemedTaskBand): TThemedElementDetails;
begin
  Result := ThemeServices.GetElementDetails(Detail);
end;

function TCustomStyleServices.GetElementDetails(Detail: TThemedTaskBar): TThemedElementDetails;
begin
  Result := ThemeServices.GetElementDetails(Detail);
end;

function TCustomStyleServices.GetElementDetails(Detail: TThemedToolBar): TThemedElementDetails;
begin
  Result := ThemeServices.GetElementDetails(Detail);
end;

function TCustomStyleServices.GetElementDetails(Detail: TThemedToolTip): TThemedElementDetails;
begin
  Result := ThemeServices.GetElementDetails(Detail);
end;

function TCustomStyleServices.GetElementDetails(Detail: TThemedTrackBar): TThemedElementDetails;
begin
  Result := ThemeServices.GetElementDetails(Detail);
end;

function TCustomStyleServices.GetElementDetails(Detail: TThemedTrayNotify): TThemedElementDetails;
begin
  Result := ThemeServices.GetElementDetails(Detail);
end;

function TCustomStyleServices.GetElementDetails(Detail: TThemedTreeView): TThemedElementDetails;
begin
  Result := ThemeServices.GetElementDetails(Detail);
end;

function TCustomStyleServices.GetElementDetails(Detail: TThemedWindow): TThemedElementDetails;
begin
  Result := ThemeServices.GetElementDetails(Detail);
end;

{$IFDEF FPC}
{$ELSE}
function TCustomStyleServices.GetElementSize(DC: HDC; Details: TThemedElementDetails;
  ElementSize: TElementSize; out Size: TSize): Boolean;
const
  CSizes: array[TElementSize] of TThemeSize = (TS_MIN, TS_TRUE, TS_DRAW);
begin
  Result := GetThemePartSize(ThemeServices.Theme[Details.Element], DC,
    Details.Part, Details.State,
    nil, CSizes[ElementSize], Size) = S_OK;
end;
{$ENDIF} 

{$ENDIF} 

{ TWinControlEh }

constructor TWinControlEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

procedure TWinControlEh.RecreateWndHandle;
begin
  RecreateWnd;
end;

{$IFDEF FPC}
procedure TWinControlEh.Ctrl3D;
begin
  Return := True;
end;
{$ELSE}
{$ENDIF}

{ TCustomControlEh }

constructor TCustomControlEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FScaleFactor := 1;
  FDefaultFlatButtonWidth := GetDefaultFlatButtonWidth();
end;

procedure TCustomControlEh.RecreateWndHandle;
begin
  RecreateWnd;
end;

procedure TCustomControlEh.ChangeScale(M, D: Integer {$IFDEF EH_LIB_24}; isDpiChange: Boolean {$ENDIF});
begin
  if M <> D then
  begin
  {$IFNDEF EH_LIB_26} 
    FScaleFactor := FScaleFactor * M / D;
  {$ENDIF}
    FDefaultFlatButtonWidth := GetDefaultFlatButtonWidth();
  end;
  inherited ChangeScale(M, D {$IFDEF EH_LIB_24}, isDpiChange{$ENDIF});
end;

{$IFDEF EH_LIB_26} 
{$ELSE}
function TCustomControlEh.GetSystemMetrics(nIndex: Integer): Integer;
begin
  Result := Windows.GetSystemMetrics(nIndex);
end;
{$ENDIF}

{$IFDEF EH_LIB_27} 
{$ELSE}
function TCustomControlEh.ScaleValue(const Value: Integer): Integer;
begin
  Result := MulDiv(Value, Round(FScaleFactor * 100), 100);
end;

function TCustomControlEh.IsCustomStyleActive: Boolean;
begin
{$IFDEF EH_LIB_16} 
  Result := TStyleManager.IsCustomStyleActive;
{$ELSE}
  Result := False;
{$ENDIF}
end;

{$ENDIF} 

function TCustomControlEh.GetStyleServices: TCustomStyleServices;
begin
{$IFDEF EH_LIB_27} 
  Result := Themes.StyleServices(Self);
{$ELSE}
  {$IFDEF EH_LIB_16} 
    Result := Themes.StyleServices;
  {$ELSE}
    {$IFDEF FPC}
    Result := EhLibVclUtils.StyleServices;
    {$ELSE}
    Result := EhLibVclUtils.StyleServices;
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
end;

function TCustomControlEh.GetDefaultFlatButtonWidth: Integer;
{$IFDEF FPC_CROSSP}
var
  VertScrollWidth: Integer;
begin
  VertScrollWidth := GetSystemMetrics(SM_CXVSCROLL) + 1;
  Result := Round(VertScrollWidth / 3 * 2);
  if (Result < 12) then
    Result := 12;
end;
{$ELSE}
var
  VertScrollWidth: Integer;
begin
  VertScrollWidth := GetSystemMetrics(SM_CXVSCROLL) + 1;
  Result := Round(VertScrollWidth / 3 * 2);
end;
{$ENDIF} 

procedure TCustomControlEh.CreateWnd;
begin
  inherited CreateWnd;
  GetCheckSize;
end;

procedure TCustomControlEh.GetCheckSize;
var
  b: TBitmap;
{$IFDEF FPC_CROSSP}

{$ELSE}
  {$IFDEF MSWINDOWS}
  ElementDetails: TThemedElementDetails;
  Size: TSize;
//  DC: HDC;
  {$ELSE}
  {$ENDIF} 

{$ENDIF} 
begin
  b := TBitmap.Create;
  try
{$IFDEF FPC_CROSSP}
    FDefaultCheckBoxWidth := GetSystemMetrics(SM_CXMENUCHECK);
    FDefaultCheckBoxHeight := GetSystemMetrics(SM_CYMENUCHECK);
    FDefaultFlatCheckBoxWidth := FDefaultCheckBoxWidth - 1;
    FDefaultFlatCheckBoxHeight := FDefaultCheckBoxHeight - 1;
{$ELSE}

  {$IFDEF MSWINDOWS}
    if ThemeServices.ThemesEnabled then
    begin
//      DC := CreateCompatibleDC(0);
      try
        ElementDetails := ThemeServices.GetElementDetails(tbCheckBoxCheckedNormal);
        StyleServices.GetElementSize(Canvas.Handle, ElementDetails, esActual, Size);
        FDefaultCheckBoxWidth := Size.cx;
        FDefaultCheckBoxHeight := Size.cy;
    finally
//      DeleteDC(DC);
    end;
  end else
    begin
      b.Handle := LoadBitmapEh(0, OBM_CHECKBOXES);
      FDefaultCheckBoxWidth := b.Width div 4;
      FDefaultCheckBoxHeight := b.Height div 3;
    end;
    FDefaultFlatCheckBoxWidth := FDefaultCheckBoxWidth - 1;
    FDefaultFlatCheckBoxHeight := FDefaultCheckBoxHeight - 1;
  {$ELSE}
    FDefaultCheckBoxWidth := GetSystemMetrics(SM_CXMENUCHECK);
    FDefaultCheckBoxHeight := GetSystemMetrics(SM_CYMENUCHECK);
    FDefaultFlatCheckBoxWidth := FDefaultCheckBoxWidth - 1;
    FDefaultFlatCheckBoxHeight := FDefaultCheckBoxHeight - 1;
  {$ENDIF} 

{$ENDIF} 
  finally
    b.Free;
  end;

end;

{$IFDEF NEXTGEN}
type
  TRefMethodComparer = class(TInterfacedObject, IComparer<TObject>)
    FCompare: TListSortCompare;

    constructor Create(ACompare: TListSortCompare);
    function Compare(const Left, Right: TObject): Integer;
  end;

constructor TRefMethodComparer.Create(ACompare: TListSortCompare);
begin
  FCompare := ACompare;
end;

function TRefMethodComparer.Compare(const Left, Right: TObject): Integer;
begin
  Result := FCompare(Left, Right);
end;
{$ENDIF} 

procedure BroadcastPerformMessageFor(Owner: TComponent; ForClass: TControlClass;
  Msg: Cardinal; WParam: WPARAM; LParam: LPARAM);
var
  i: Integer;
begin
  for i := 0 to Owner.ComponentCount-1 do
  begin
    if Owner.Components[i] is ForClass then
    begin
      TControl(Owner.Components[i]).Perform(Msg, WParam, LParam);
    end;
    BroadcastPerformMessageFor(Owner.Components[i], ForClass, Msg, WParam, LParam);
  end;
end;

procedure BroadcastPerformMessage(Msg: Cardinal; WParam: WPARAM; LParam: LPARAM);
var
  i: Integer;
begin
  for I := 0 to Screen.FormCount - 1 do
  begin
    Screen.Forms[I].Perform(Msg, WParam, LParam);
    BroadcastPerformMessageFor(Screen.Forms[I], TControl, Msg, WParam, LParam);
  end;
end;

type
  TLangResNotifyComponent = class(TComponent, ILanguageResourceLoadNotificationConsumer)
  public
    procedure ResourceLanguageChanged();
  end;

procedure TLangResNotifyComponent.ResourceLanguageChanged();
begin
  BroadcastPerformMessage(WM_SETTINGCHANGE, 0, 0);
end;

var
  LangResNotifyComponent: TLangResNotifyComponent;

{ initialization/finalization }
procedure InitUnit;
begin
  NewStyleControls := True; 

  LangResNotifyComponent := TLangResNotifyComponent.Create(nil);
  LanguageResourceManagerEh.AddChangeNotifyConsumer(LangResNotifyComponent, 'ENU');
  EhLibUtils.ColorToRGBProc := Graphics.ColorToRGB;
end;

procedure FinalUnit;
begin
  {$IFNDEF EH_LIB_16}
    FreeAndNil(FStyleServices);
  {$ENDIF}

  FreeScreenCanvas;
  FreeAndNil(BackBitmap);

  LanguageResourceManagerEh.DeleteChangeNotifyConsumer(LangResNotifyComponent);
  LangResNotifyComponent.Free;
end;

function GetEhLibSysDelphiCompilerInfo(): String;
begin
{$IFDEF FPC}
  Result := 'Lazarus: ' + laz_version;
{$ELSE}
  {$IFDEF EH_LIB_29} 
  if RTLVersion = 36 then
  begin
    Result := 'RADStudio 12.0, RTLVersion = ' + GetRTLVersion.ToString +
      ', CompilerVersion = ' + GetCompilerVersion.ToString;
  end;
  {$ENDIF}
  if RTLVersion = 35 then
  begin
    Result := 'RADStudio 11.0';
    {$IF Declared(RTLVersion111)}
    Result := 'RADStudio 11.1';
    {$IFEND}
    {$IF Declared(RTLVersion112)}
    Result := 'RADStudio 11.2';
    {$IFEND}
    {$IF Declared(RTLVersion113)}
    Result := 'RADStudio 11.3';
    {$IFEND}
  end;
  if RTLVersion = 34 then
  begin
    Result := 'RADStudio 10.4 Sydney';
  end;
  if RTLVersion = 33 then
  begin
    Result := 'RADStudio 10.3 Rio';
  end;
  if RTLVersion = 32 then
  begin
    Result := 'RADStudio 10.2 Tokyo';
  end;
  if RTLVersion = 31 then
  begin
    Result := 'RADStudio 10.1 Berlin';
  end;
  if RTLVersion = 30 then
  begin
    Result := 'Delphi 10 Seattle';
  end;
  if RTLVersion = 29 then
  begin
    Result := 'Delphi XE8';
  end;
  if RTLVersion = 28 then
  begin
    Result := 'Delphi XE7';
  end;
  if RTLVersion = 27 then
  begin
    Result := 'Delphi XE6';
  end;
  if RTLVersion = 26 then
  begin
    Result := 'Delphi XE5';
  end;
  if RTLVersion = 25 then
  begin
    Result := 'Delphi XE4';
  end;
  if RTLVersion = 24 then
  begin
    Result := 'Delphi XE3';
  end;
  if RTLVersion = 23 then
  begin
    Result := 'Delphi XE2';
  end;
  if RTLVersion = 22 then
  begin
    Result := 'Delphi XE';
  end;
  if RTLVersion = 21 then
  begin
    Result := 'Delphi 2010';
  end;
  if RTLVersion = 20 then
  begin
    Result := 'Delphi 2009';
  end;
  {$ENDIF}
end;

function GetEhLibSysRTLVersionInfo(): String;
begin
  {$IFDEF FPC}
  Result := '';
  {$ELSE}
  Result := FormatFloat('#.00', RTLVersion);
  {$ENDIF}
end;

function GetEhLibSysCompilerVersion: String;
begin
  {$IFDEF FPC}
  Result := '';
  {$ELSE}
  Result := FormatFloat('#.00', CompilerVersion);
  {$ENDIF}
end;

{$IFDEF FPC}
function GetCompiledTargetCPU: string;
begin
  Result := LowerCase({$I %FPCTARGETCPU%});
end;

function GetCompiledTargetOS: string;
begin
  Result := LowerCase({$I %FPCTARGETOS%});
end;
{$ENDIF}

function GetEhLibSysDelphiPlatformInfo(): String;
begin
Result := '';
{$IFDEF IOS32} Result := 'IOS32'; {$ENDIF}
{$IFDEF IOS64} Result := 'IOS64'; {$ENDIF}
{$IFDEF WIN32} Result := 'WIN32'; {$ENDIF}
{$IFDEF WIN64} Result := 'WIN64'; {$ENDIF}
{$IFDEF MACOS32} Result := 'MACOS32'; {$ENDIF}
{$IFDEF MACOS64} Result := 'MACOS64'; {$ENDIF}
{$IFDEF LINUX32} Result := 'LINUX32'; {$ENDIF}
{$IFDEF LINUX64} Result := 'LINUX64'; {$ENDIF}
{$IFDEF ANDROID32} Result := 'ANDROID32'; {$ENDIF}

{$IFDEF FPC}
Result := Result + ' - ' +
  GetCompiledTargetCPU + '-' +
  GetCompiledTargetOS + '-' +
  LCLPlatformDisplayNames[GetDefaultLCLWidgetType];
{$ENDIF}
end;

type
  TOSInfo = record
    Kernel: String;
    OSName: String;
    OSVersion: String;
    Architecture: String;
  end;

function GetOSInfo: TOSInfo;
{$IFDEF CROSSVCL}
begin
  Result.Kernel := '';
  {$IFDEF EH_LIB_16} 
  Result.OSName := TOSVersion.ToString;
  {$ELSE}
  Result.OSName := 'Windows';
  {$ENDIF}
  Result.OSVersion := '';
  Result.Architecture := '';
end;
{$ELSE}
{$IFDEF LINUX} 
var
  P: TProcess;

  function ExecParam(Param: String): String;
  begin
    P.Parameters[0] := '-' + Param;
    P.Execute;
    SetLength(Result, 1000);
    SetLength(Result, P.Output.Read(Result[1], Length(Result)));
    while (Length(Result) > 0) and
          (Result[Length(Result)] in [#8..#13,#32]) do
    begin
      SetLength(Result, Length(Result) - 1);
    end;
  end;
begin
  P:= TProcess.Create(Nil);
  P.Options:= [poWaitOnExit, poUsePipes];
  P.Executable:= 'uname';
  P.Parameters.Add('');

  Result.Kernel := ExecParam('s') + ' ' + ExecParam('r');
  Result.OSName := ExecParam('o');
  Result.OSVersion := ExecParam('v');
  Result.Architecture := ExecParam('m');
  P.Free;
end;
{$ELSE}
begin
  Result.Kernel := '';
  {$IFDEF EH_LIB_16} 
  Result.OSName := TOSVersion.ToString;
  {$ELSE}
  Result.OSName := 'Windows';
  {$ENDIF}
  Result.OSVersion := '';
  Result.Architecture := '';
end;
{$ENDIF} 
{$ENDIF} 

function GetEhLibGUISysInfoAsString: String;
var
  I: Integer;
begin
  Result := '';

  Result := Result + 'Monitor Count: ' + IntToStr(Screen.MonitorCount) + sLineBreak;

  for I := 0 to Screen.MonitorCount - 1 do
  begin
   Result := Result + 'Monitor-' + IntToStr(I) + ': ' +
    'W: ' + IntToStr(Screen.Monitors[I].Width) +
    '  H: ' + IntToStr(Screen.Monitors[I].Height) +
    {$IFDEF EH_LIB_23} 
    '  PPI: ' + IntToStr(Screen.Monitors[I].PixelsPerInch) +
    '  Scale: ' + IntToStr(Trunc(Screen.Monitors[I].PixelsPerInch / 96 * 100)) + '%' +
    {$ELSE}
    {$ENDIF}
    sLineBreak;
  end;

  if StyleServices.ThemesEnabled
    then Result := Result + 'Enable Runtime Themes: True' + sLineBreak
    else Result := Result + 'Enable Runtime Themes: False' + sLineBreak;
end;

function GetEhLibFullSysInfoAsString: String;
begin
  Result := GetEhLibSysInfoAsString + sLineBreak + GetEhLibGUISysInfoAsString;
end;


initialization
  InitUnit;
finalization
  FinalUnit;
end.

