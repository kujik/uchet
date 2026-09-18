{*******************************************************}
{                                                       }
{                     EhLib.Fmx 13                      }
{                    EhLibFmx.Utils                     }
{                                                       }
{     Copyright (c) 2024-2025 by Dmitry V. Bolshakov    }
{                                                       }
{*******************************************************}

{$I ..\Incl\EhLib.Inc}
{$SCOPEDENUMS ON}

unit EhLibFmx.Utils;

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
  EhLibFmx.Platform,
  EhLibFmx.Types;
{$ENDREGION 'uses'}

procedure WriteTextEh(ACanvas: TCanvas;      
                      ARect: TRect;          
                      FillRect:Boolean;      
                      DX, DY: Integer;       
                      Text: string;          
                      Alignment: TAlignment; 
                      VertAlign: TTextAlign;   
                      MultiL: Boolean;       
                      EndEllipsis: Boolean;  
                      LeftMarg,              
                      RightMarg: Integer;    
                      RightToLeftReading: Boolean;
                      ForceSingleLine: Boolean 
                      );


function EmptyRect: TRect;
function DeflateRect(const ARect: TRect; Bounds: TBounds): TRect; overload;
function DeflateRect(const ARect: TRectF; Bounds: TBounds): TRectF; overload;
function GetParentForm(Control: TControl): TCommonCustomForm;

procedure PolyPolyLineEh(Canvas: TCanvas; const PointsList: TPointArrayEh; const StrokeList: TDWORDArrayEh; VCount: Integer);
procedure PolyLineEh(Canvas: TCanvas; const PointsList: TPointArrayEh; VPos: Integer; VCount: Integer);
procedure FillGradientEh(Canvas: TCanvas; ARect: TRect; FromColor, ToColor: TAlphaColor);

procedure DrawTreeElement(Canvas: TCanvas; ARect: TRect;
  TreeElement: TTreeElementEh; BackDot: Boolean; ScaleX, ScaleY: Double;
  RightToLeft: Boolean; Coloured: Boolean);

function SystemFont: TFont;
function SystemFontColor: TAlphaColor;
function SystemFill: TBrush;
function EmptyBounds: TBounds;
function GetFontSize(Font: TFont): Integer;

procedure ControlPaintTo(AControlPaint: TControl; const ACanvas: TCanvas; const ARect: TRectF; const AParent: TFmxObject = nil);
procedure ControlInvalidate(AControl: TControl);

procedure StartWait;
procedure StopWait;

function ControlClientToScreen(AControl: TFmxObject; const APoint: TPointF): TPointF; overload;
function ControlClientToScreen(AControl: TFmxObject; const APoint: TPoint): TPoint; overload;
function ControlRectClientToScreen(AControl: TControl): TRect;

function AdjustColorForDarkTheme(Color: TAlphaColor): TAlphaColor;
function ColorToGray(AColor : TAlphaColor) : TAlphaColor;
function AlphaBlend(Color1, Color2: TAlphaColor): TAlphaColor;

function GetControlMessageMousePos(AControl: TControl): TPointF;

implementation

{$REGION 'Global procedures and functions'}

{ InitModule, FinalizeModule }

var
  WaitCount: Integer = 0;
  SaveCursor: TCursor = crDefault;

 const
  WaitCursor: TCursor = crHourGlass;

procedure StartWait;
var
  C: IFMXCursorService;
begin
  if WaitCount = 0 then
  begin
    if TPlatformServices.Current.SupportsPlatformService(IFMXCursorService, C) then
      C.SetCursor(crHourGlass);
  end;
  Inc(WaitCount);
end;

procedure StopWait;
var
  C: IFMXCursorService;
begin
  if WaitCount > 0 then
  begin
    Dec(WaitCount);
    if WaitCount = 0 then
      if TPlatformServices.Current.SupportsPlatformService(IFMXCursorService, C) then
        C.SetCursor(crDefault);
  end;
end;

function GetFormMessageMousePos(AForm: TCommonCustomForm): TPointF;
var
  ctx: TRttiContext;
  typ: TRttiType;
  fld: TRttiField;
begin
  ctx := TRttiContext.Create;
  typ := ctx.GetType(AForm.ClassType);
  fld := typ.GetField('FMousePos');
  if Assigned(fld) then
    Result := fld.GetValue(AForm).AsType<TPointF>()
  else
    Result := TPointF.Zero;
end;

function GetControlMessageMousePos(AControl: TControl): TPointF;
begin
  Result := GetFormMessageMousePos(GetParentForm(AControl));
  Result := AControl.AbsoluteToLocal(Result);
end;


function ControlClientToScreen(AControl: TFmxObject; const APoint: TPointF): TPointF;
begin
  Result := ControlClientToScreen(AControl, APoint.Round);
end;

function ControlClientToScreen(AControl: TFmxObject; const APoint: TPoint): TPoint;
var
  FResult: TPointF;
begin
  if AControl is TControl then
  begin
    FResult := TControl(AControl).LocalToScreen(TPointF.Create(APoint));
  end else if AControl is TCommonCustomForm then
  begin
    FResult := TCommonCustomForm(AControl).ClientToScreen(TPointF.Create(APoint));
  end else
    raise Exception.Create('ControlLocalToAbsolute: Class "' + AControl.ClassName + '" is not supported');

  Result := FResult.Round;
end;

function ControlRectClientToScreen(AControl: TControl): TRect;
begin
  Result.TopLeft := ControlClientToScreen(AControl, TPoint.Create(0, 0));
  Result.Height := Round(AControl.Height);
  Result.Width := Round(AControl.Width);
end;

var
  FSystemFont: TFont;
  FSystemFontColor: TAlphaColor;
  FSystemFill: TBrush;
  FEmptyBounds: TBounds;

function SystemFontColor: TAlphaColor;
begin
  Result := FSystemFontColor;
end;

function SystemFont: TFont;
begin
  if (FSystemFont = nil) then
    FSystemFont := TFont.Create;
  Result := FSystemFont;
end;

function SystemFill: TBrush;
begin
  if (FSystemFill = nil) then
    FSystemFill := TBrush.Create(TBrushKind.Solid, TAlphaColors.White);
  Result := FSystemFill;
end;

function EmptyBounds: TBounds;
begin
  if (FEmptyBounds = nil) then
    FEmptyBounds := TBounds.Create(TRectF.Empty);
  Result := FEmptyBounds;
end;

function GetFontSize(Font: TFont): Integer;
begin
  Result := Round(Font.Size);
end;

procedure DrawTreeElement(Canvas: TCanvas; ARect: TRect;
  TreeElement: TTreeElementEh; BackDot: Boolean; ScaleX, ScaleY: Double;
  RightToLeft: Boolean; Coloured: Boolean);
var
  ABoxRect: TRect;
  ACenter: TPoint;
  Square: TRect;
  X2, X4, Y2, Y4: Integer;
  FrameRect: TRectF;
begin
  ACenter.X := (ARect.Right + ARect.Left) div 2;
  ACenter.Y := (ARect.Bottom + ARect.Top) div 2;
  X2 := Trunc(ScaleX*2);
  X4 := Trunc(ScaleX*4);
  Y2 := Trunc(ScaleY*2);
  Y4 := Trunc(ScaleY*4);
  Square := ARect;
  if ARect.Bottom - ARect.Top < ARect.Right - ARect.Left then
  begin
    Square.Left := (ARect.Right + ARect.Left) div 2 - (ARect.Bottom - ARect.Top) div 2;
    Square.Right := Square.Left + (ARect.Bottom - ARect.Top);
  end else
  begin
    Square.Top := (ARect.Bottom + ARect.Top) div 2 - (ARect.Right - ARect.Left) div 2;
    Square.Bottom := Square.Top + (ARect.Bottom - ARect.Top);
  end;

  ABoxRect := Rect(ACenter.X-X4, ACenter.Y-Y4, ACenter.X+X4+1, ACenter.Y+Y4+1);
  if TreeElement in [TTreeElementEh.MinusUpDown .. TTreeElementEh.Plus] then
  begin
    if Coloured then
    begin
      Canvas.Fill.Color := TAlphaColorRec.White;
      Canvas.Stroke.Color := TAlphaColorRec.Gray;
    end;
    FrameRect := RectF(ABoxRect.Left - 0.5, ABoxRect.Top - 0.5, ABoxRect.Right + 0.5, ABoxRect.Bottom + 0.5);
    Canvas.DrawRect(FrameRect, 0, 0, AllCorners, 1);
    if Coloured then
      Canvas.Stroke.Color := TAlphaColorRec.Black;
    begin
      Canvas.DrawLine(PointF(ABoxRect.Left + X2 - 0.5, ACenter.Y + 0.5), PointF(ABoxRect.Right - X2 + 0.5, ACenter.Y + 0.5), 1);

      if TreeElement in [TTreeElementEh.PlusUpDown,
                         TTreeElementEh.PlusUp,
                         TTreeElementEh.PlusDown,
                         TTreeElementEh.Plus,
                         TTreeElementEh.PlusHLine] then
      begin
        Canvas.DrawLine(PointF(ACenter.X + 0.5, ABoxRect.Top + Y2 - 0.5), PointF(ACenter.X + 0.5, ABoxRect.Bottom - Y2 + 0.5), 1);
      end;
    end;

    if Coloured then
      Canvas.Stroke.Color := TAlphaColorRec.Gray;
    if not (TreeElement in [TTreeElementEh.Minus, TTreeElementEh.Plus]) then
    begin
    end;

    if TreeElement in [TTreeElementEh.MinusUpDown,
                       TTreeElementEh.MinusUp,
                       TTreeElementEh.PlusUpDown,
                       TTreeElementEh.PlusUp] then
    begin
    end;

    if TreeElement in [TTreeElementEh.MinusUpDown,
                       TTreeElementEh.MinusDown,
                       TTreeElementEh.PlusUpDown,
                       TTreeElementEh.PlusDown] then
    begin
    end;

  end else
  begin
    if Coloured then
    begin
      Canvas.Stroke.Dash := TStrokeDash.Solid;
      Canvas.Stroke.Color := TAlphaColorRec.Gray;
    end;
  end;
end;

function GetParentForm(Control: TControl): TCommonCustomForm;
var
  RootObj: TFmxObject;
begin
  Result := nil;
  if (Control.Root <> nil) and
     (Control.Root.GetObject <> nil) then
  begin
    RootObj := Control.Root.GetObject;
    if (RootObj is TCommonCustomForm) then
      Result := TCommonCustomForm(RootObj);
  end;
end;

procedure FillGradientEh(Canvas: TCanvas; ARect: TRect; FromColor, ToColor: TAlphaColor);
var
  StrokeBrush: TBrush;
  ARectF: TRectF;
begin
  StrokeBrush := TBrush.Create(TBrushKind.Gradient, FromColor);
  try
    StrokeBrush.Kind := TBrushKind.Solid;
    ARectF := TRectF.Create(ARect);
    Canvas.FillRect(ARectF, 0, 0, [], 1, StrokeBrush);
  finally
    StrokeBrush.Free;
  end;
end;

procedure PolyLineEh(Canvas: TCanvas; const PointsList: TPointArrayEh; VPos: Integer; VCount: Integer);
var
  i: Integer;
  p1: TPointF;
  p2: TPointF;
begin
  for i := VPos to VPos + VCount - 1 do
  begin
    p1 := PointsList[i];
    p2 := PointsList[i + 1];
    Canvas.DrawLine(p1, p2, 1);
  end;
end;

procedure PolyPolyLineEh(Canvas: TCanvas; const PointsList: TPointArrayEh; const StrokeList: TDWORDArrayEh; VCount: Integer);
var
  i: Integer;
  pos: Integer;
begin
  pos := 0;
  for i := 0 to VCount-1 do
  begin
    PolyLineEh(Canvas, PointsList, pos, StrokeList[i]);
    pos := pos + Integer(StrokeList[i]);
  end;
end;

function EmptyRect: TRect;
begin
  Result := Rect(0, 0, 0, 0);
end;

function DeflateRect(const ARect: TRect; Bounds: TBounds): TRect;
begin
  Result := ARect;
  Result.Left := ARect.Left + Round(Bounds.Left);
  Result.Right := ARect.Right - Round(Bounds.Right);
  Result.Top := ARect.Top + Round(Bounds.Top);
  Result.Bottom := ARect.Bottom - Round(Bounds.Bottom);
end;

function DeflateRect(const ARect: TRectF; Bounds: TBounds): TRectF;
begin
  Result := ARect;
  Result.Left := ARect.Left + Bounds.Left;
  Result.Right := ARect.Right - Bounds.Right;
  Result.Top := ARect.Top + Bounds.Top;
  Result.Bottom := ARect.Bottom - Bounds.Bottom;
end;

procedure WriteTextEh(ACanvas: TCanvas;      
                      ARect: TRect;          
                      FillRect:Boolean;      
                      DX, DY: Integer;       
                      Text: string;          
                      Alignment: TAlignment; 
                      VertAlign: TTextAlign;   
                      MultiL: Boolean;       
                      EndEllipsis: Boolean;  
                      LeftMarg,              
                      RightMarg: Integer;    
                      RightToLeftReading: Boolean;
                      ForceSingleLine: Boolean 
                      );
const
  HorzAlign: array[TAlignment] of TTextAlign = (TTextAlign.Leading, TTextAlign.Trailing, TTextAlign.Center);
begin
  ACanvas.FillText(TRectF.Create(ARect), Text, MultiL, 1, [], HorzAlign[Alignment], VertAlign);
end;

procedure ControlPaintTo(AControlPaint: TControl;
  const ACanvas: TCanvas; const ARect: TRectF; const AParent: TFmxObject = nil);
var
  DestRect: TRectF;
  CvsState: TCanvasSaveState;
begin
  DestRect := TRectF.Create(0, 0, AControlPaint.Width, AControlPaint.Height);
  RectCenter(DestRect, ARect);

  CvsState := ACanvas.SaveState;
  try
    AControlPaint.PaintTo(ACanvas,  DestRect, AParent);
  finally
    ACanvas.RestoreState(CvsState);
  end;
end;

procedure ControlInvalidate(AControl: TControl);
begin
  AControl.InvalidateRect(RectF(0, 0, AControl.Width, AControl.Height));
end;

function ColorToGray(AColor: TAlphaColor) : TAlphaColor;
var
  Rec: TAlphaColorRec;
  Gray: Byte;
begin
  Rec.Color := AColor;
  Gray := Round(Rec.R * 0.3 + Rec.G * 0.59 + Rec.B * 0.11);
  Result := MakeColor(Gray, Gray, Gray, Rec.A);
end;

function AdjustColorForDarkTheme(Color: TAlphaColor): TAlphaColor;
var
  H, S, L: Single;
  A: Byte;
begin
  A := TAlphaColorRec(Color).A;
  RGBtoHSL(Color, H, S, L);

  L := 1 - L;
//  if L > 0.60 then
//    L := L * 0.50   // very light > darker
//  else if L < 0.30 then
//    L := 1 - L      // very dark > invert brightness
//  else
//    L := L * 0.85;   // medium > slightly darker

  Result := HSLtoRGB(H, S, L);
  TAlphaColorRec(Result).A := A;
end;

function AlphaBlend(Color1, Color2: TAlphaColor): TAlphaColor;
var
  Cf, Cb, Cr: TAlphaColorRec;
  af, ab, a: Single;
begin
  Cf := TAlphaColorRec(Color1);
  Cb := TAlphaColorRec(Color2);

  af := Cf.A / 255;
  ab := Cb.A / 255;

  a := af + ab * (1 - af);
  if a = 0 then
    Exit(0);

  Cr.A := Round(a * 255);

  Cr.R := Round((Cf.R * af + Cb.R * ab * (1 - af)) / a);
  Cr.G := Round((Cf.G * af + Cb.G * ab * (1 - af)) / a);
  Cr.B := Round((Cf.B * af + Cb.B * ab * (1 - af)) / a);

  Result := Cr.Color;
end;

{$REGION 'InitFinalUnit'}

procedure InitUnit;
begin
  FSystemFontColor := TAlphaColorRec.Black;
end;

procedure FinalizeUnit;
begin
  FreeAndNil(FSystemFont);
  FreeAndNil(FSystemFill);
  FreeAndNil(FEmptyBounds);
end;

{$ENDREGION 'Global procedures and functions'}

initialization
  InitUnit;
finalization
  FinalizeUnit;
end.

