{*******************************************************}
{                                                       }
{                    EhLib.Fmx 13.0                     }
{                   EhLibFmx.Styles                     }
{                                                       }
{      Copyright (c) 2024-2025 by Dmitry V. Bolshakov   }
{                                                       }
{*******************************************************}

{$I ..\Incl\EhLib.Inc}
{$SCOPEDENUMS ON}

unit EhLibFmx.Styles;

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
  EhLibFmx.ToolControls,
  EhLibFmx.Types;
{$ENDREGION 'uses'}


type
  TEhLibComposedStyleBuilder = class;
  TStyleManagerEh = class;

{ TEhLibComposedStyleBuilder }

  TEhLibComposedStyleBuilder = class(TPersistent)
  private
    FStyleManager: TStyleManagerEh;
  protected
    function CreateStyleDescription(AParent: TFmxObject): TFmxObject; virtual;

    function FindStyleResource(AStyleElement: String; AStyleResource: String): TFmxObject; virtual;
  public
    constructor Create(AStyleManager: TStyleManagerEh); virtual;
    destructor Destroy; override;

    function CreateStyleContainer: TFmxObject; virtual;
  end;

  TEhLibComposedStyleBuilderClass = class of TEhLibComposedStyleBuilder;

{ TStyleManagerEh }

  TStyleManagerEh = class(TPersistent)
  private
    class var FCurrentManager: TStyleManagerEh;
    class var FEhLibStylesMerged: Boolean;

    class function GetCurrentManager: TStyleManagerEh; static;
    class procedure SubscribeToStyleChangedMessage();
  public
    class procedure CheckApplyEhLibStyles();
    class function SetCurrentManager(ANewStyleManager: TStyleManagerEh): TStyleManagerEh;

    class property Current: TStyleManagerEh read GetCurrentManager;

  private
    FDefaultEhLibStyles: TFmxObject;
    FComposedEhLibStyles: TFmxObject;
    FStyleOrigin: TStyleOriginEh;
    FComposedStyleBuilderClass: TEhLibComposedStyleBuilderClass;
    FStyleColorMode: TStyleColorModeEh;
    FOnStyleColorModeChange: TNotifyEvent;

    procedure SetStyleOrigin(const Value: TStyleOriginEh);
    function GetStyleColorMode: TStyleColorModeEh;
    procedure ResetStyleColorModeFromForegroundColor(ABackColor, AForeColor: TAlphaColor);
    procedure StyleColorModeChanged();
  public
    constructor Create(); virtual;
    destructor Destroy; override;

    function GetDefaultEhLibStyles(): TFmxObject; virtual;

    procedure MergeWithActiveStyle(AStyleResource: TFmxObject); virtual;
//    procedure ApplyEhLibStyle(AStyleResource: TFmxObject); virtual;
    procedure EhLibStylesApplied; virtual;

    function GetBuiltInStyleResource(): TFmxObject; virtual;
    function CreateComposedStyle(): TFmxObject; virtual;

    function FindStyleResource(AStyleElement: String; AStyleResource: String): TFmxObject; virtual;
    function FindStyleElement(AStyleElement: String): TFmxObject; virtual;

    property StyleOrigin: TStyleOriginEh read FStyleOrigin write SetStyleOrigin;
    property ComposedStyleBuilderClass: TEhLibComposedStyleBuilderClass read FComposedStyleBuilderClass write FComposedStyleBuilderClass;
    property StyleColorMode: TStyleColorModeEh read GetStyleColorMode;
    property OnStyleColorModeChange: TNotifyEvent read FOnStyleColorModeChange write FOnStyleColorModeChange;
  end;


implementation

uses EhLibFmx.ImageReses;

function GetAverageColor(const Bitmap: TBitmap): TAlphaColor;
var
  Data: TBitmapData;
  X, Y: Integer;
  Pixel: PAlphaColorRec;
  RSum, GSum, BSum, ASum: UInt64;
  Count: UInt64;
  R, G, B, A: Byte;
begin
  Result := TAlphaColorRec.Null;

  if (Bitmap = nil) or Bitmap.IsEmpty then
    Exit;

  if not Bitmap.Map(TMapAccess.Read, Data) then
    Exit;

  try
    RSum := 0;
    GSum := 0;
    BSum := 0;
    ASum := 0;
    Count := 0;

    for Y := 0 to Bitmap.Height - 1 do
    begin
      Pixel := Data.GetScanline(Y);
      for X := 0 to Bitmap.Width - 1 do
      begin
        Inc(RSum, Pixel.R);
        Inc(GSum, Pixel.G);
        Inc(BSum, Pixel.B);
        Inc(ASum, Pixel.A);
        Inc(Count);
        Inc(Pixel);
      end;
    end;

    if Count > 0 then
    begin
      R := RSum div Count;
      G := GSum div Count;
      B := BSum div Count;
      A := ASum div Count;
      Result := MakeColor(R, G, B, A);
    end;
  finally
    Bitmap.Unmap(Data);
  end;
end;

function RenderControlToBitmap(const Control: TControl): TBitmap;
begin
  Result := nil;

  if (Control = nil) or (Control.Width <= 0) or (Control.Height <= 0) then
    Exit;

  Result := TBitmap.Create(Round(Control.Width), Round(Control.Height));
  try
    Result.Clear(TAlphaColorRec.Null);

    if Result.Canvas.BeginScene then
    try
      Control.PaintTo(Result.Canvas, RectF(0, 0, Control.Width, Control.Height));
    finally
      Result.Canvas.EndScene;
    end;
  except
    Result.Free;
    raise;
  end;
end;

function GetAverageColorFromControl(const Control: TControl): TAlphaColor;
var
  Bmp: TBitmap;
begin
  Result := TAlphaColorRec.Null;
  if Control = nil then
    Exit;

  Bmp := RenderControlToBitmap(Control);
  try
    if Bmp <> nil then
      Result := GetAverageColor(Bmp);
  finally
    Bmp.Free;
  end;
end;

{$REGION 'InitFinalUnit'}

procedure InitModule;
begin
  TStyleManagerEh.SubscribeToStyleChangedMessage();
end;

procedure FinalizeModule;
begin
  FreeAndNil(TStyleManagerEh.Current);
end;

{$ENDREGION 'InitFinalUnit'}

{$REGION 'TStyleManagerEh'}

{ TStyleManagerEh }

class procedure TStyleManagerEh.SubscribeToStyleChangedMessage;
begin
  TMessageManager.DefaultManager.SubscribeToMessage(TStyleChangedMessage,
    procedure(const Sender: TObject; const M: TMessage)
    begin
      TStyleManagerEh.FEhLibStylesMerged := False;
      if TStyleManagerEh.Current.FComposedEhLibStyles <> nil then
      begin
        TStyleManagerEh.Current.FComposedEhLibStyles.Free;
        if TStyleManagerEh.Current.FComposedEhLibStyles = TStyleManagerEh.Current.FDefaultEhLibStyles then
          TStyleManagerEh.Current.FDefaultEhLibStyles := nil;
        TStyleManagerEh.Current.FComposedEhLibStyles := nil;
      end;
    end
  );
end;

class function TStyleManagerEh.SetCurrentManager(ANewStyleManager: TStyleManagerEh): TStyleManagerEh;
begin
  Result := FCurrentManager;
  FCurrentManager := ANewStyleManager;
end;

class procedure TStyleManagerEh.CheckApplyEhLibStyles;
var
  EhLibStyleContainer: TFmxObject;
begin
  if FEhLibStylesMerged = False then
  begin
    EhLibStyleContainer := Current.GetDefaultEhLibStyles;
    Current.MergeWithActiveStyle(EhLibStyleContainer);
    Current.EhLibStylesApplied();
    FEhLibStylesMerged := True;
  end;
end;

class function TStyleManagerEh.GetCurrentManager: TStyleManagerEh;
begin
  if FCurrentManager = nil then
    FCurrentManager := TStyleManagerEh.Create;
  Result := FCurrentManager;
end;

constructor TStyleManagerEh.Create;
begin
  inherited Create;
  FComposedStyleBuilderClass := TEhLibComposedStyleBuilder;
end;

destructor TStyleManagerEh.Destroy;
//var
//  StylesOwner: TObject;
begin
//  StylesOwner := FDefaultEhLibStyles.Owner;
  FreeAndNil(FComposedEhLibStyles);
  inherited Destroy;
end;

procedure TStyleManagerEh.SetStyleOrigin(const Value: TStyleOriginEh);
begin
  if FStyleOrigin <> Value then
  begin
    FStyleOrigin := Value;
    if FComposedEhLibStyles <> nil then
      FreeAndNil(FComposedEhLibStyles);
    FDefaultEhLibStyles := nil;
  end;
end;

function TStyleManagerEh.GetStyleColorMode: TStyleColorModeEh;
begin
  Result := FStyleColorMode;
end;

function TStyleManagerEh.GetDefaultEhLibStyles(): TFmxObject;
begin
  if FDefaultEhLibStyles = nil then
  begin
    if StyleOrigin = TStyleOriginEh.BuiltIn then
    begin
      FDefaultEhLibStyles := GetBuiltInStyleResource();
    end else
    begin
      FDefaultEhLibStyles := CreateComposedStyle();
      FComposedEhLibStyles := FDefaultEhLibStyles;
    end;
  end;
  Result := FDefaultEhLibStyles;
end;

function TStyleManagerEh.GetBuiltInStyleResource(): TFmxObject;
var
  StyleResourceService: IStyleResourceService;
  StyleResourceName: String;
begin
  if TPlatformServices.Current.SupportsPlatformService(IStyleResourceService, StyleResourceService) then
    StyleResourceName := StyleResourceService.GetStyleResource()
  else
    StyleResourceName := '';

  Result := TStyleManager.GetStyleResource(StyleResourceName);
  if Result = nil then
    raise Exception.Create('RegisterCustomControlsStyle(): TStyleManager.GetStyleResource('''+StyleResourceName+''') returns nil');
end;

function TStyleManagerEh.CreateComposedStyle(): TFmxObject;
var
  ComposedStyleBuilder: TEhLibComposedStyleBuilder;
begin
  ComposedStyleBuilder := ComposedStyleBuilderClass.Create(Self);
  Result := ComposedStyleBuilder.CreateStyleContainer();
  ComposedStyleBuilder.Free;
end;

procedure TStyleManagerEh.MergeWithActiveStyle(AStyleResource: TFmxObject);
var
  ActiveStyle: TFmxObject;
  StyleResourceItem: TFmxObject;
  I: Integer;
begin
  ActiveStyle := TStyleManager.ActiveStyle(nil);
  for I := 0 to AStyleResource.ChildrenCount - 1 do
  begin
    StyleResourceItem := AStyleResource.Children[I];
    if StyleResourceItem is TStyleDescription then
      DoNothing()
    else
      ActiveStyle.AddObject(StyleResourceItem.Clone(nil));
  end;
end;

procedure TStyleManagerEh.EhLibStylesApplied;
var
  BaseBackColor, BaseForeColor: TAlphaColor;
  StyleResourceItem: TFmxObject;
begin
  BaseBackColor := TAlphaColorRec.Null;
  BaseForeColor := TAlphaColorRec.Null;

  StyleResourceItem := FindStyleResource('EhLib.BaseGridStyle', 'BackgroundColor');
  if (StyleResourceItem <> nil) and (StyleResourceItem is TColorObject) then
    BaseBackColor := TColorObject(StyleResourceItem).Color;

  StyleResourceItem := FindStyleResource('EhLib.BaseGridStyle', 'ForegroundColor');
  if (StyleResourceItem <> nil) and (StyleResourceItem is TColorObject) then
    BaseForeColor := TColorObject(StyleResourceItem).Color;

  ResetStyleColorModeFromForegroundColor(BaseBackColor, BaseForeColor);
end;

function TStyleManagerEh.FindStyleResource(AStyleElement: String; AStyleResource: String): TFmxObject;
var
  StyleElement: TFmxObject;
begin
  StyleElement := FindStyleElement(AStyleElement);
  if StyleElement <> nil then
    Result := StyleElement.FindStyleResource(AStyleResource, False)
  else
    Result := nil;
end;

function TStyleManagerEh.FindStyleElement(AStyleElement: String): TFmxObject;
var
  ActiveStyle: TFmxObject;
  StyleResourceItem: TFmxObject;
  I: Integer;
begin
  Result := nil;
  ActiveStyle := TStyleManager.ActiveStyle(nil);

  for I := 0 to ActiveStyle.ChildrenCount - 1 do
  begin
    StyleResourceItem := ActiveStyle.Children[I];
    if SameText(StyleResourceItem.StyleName, AStyleElement) then
      Exit(StyleResourceItem);
  end;
end;

procedure TStyleManagerEh.ResetStyleColorModeFromForegroundColor(ABackColor, AForeColor: TAlphaColor);

  function Brightness(Color: TAlphaColor): Single;
  var
    R, G, B: Byte;
  begin
    R := (Color shr 16) and $FF;
    G := (Color shr 8) and $FF;
    B := Color and $FF;

    Result := (0.299 * R + 0.587 * G + 0.114 * B) / 255;
  end;

var
  VBackBrightnessLevel: Single;
  VForeBrightnessLevel: Single;
begin

  VBackBrightnessLevel := Brightness(ABackColor);
  VForeBrightnessLevel := Brightness(AForeColor);

  if (VBackBrightnessLevel >= VForeBrightnessLevel) and
     (FStyleColorMode = TStyleColorModeEh.Dark) then
  begin
    FStyleColorMode := TStyleColorModeEh.Light;
    EhLibImageResources.ResetResources();
    StyleColorModeChanged();
  end
  else if (VBackBrightnessLevel < VForeBrightnessLevel) and
          (FStyleColorMode = TStyleColorModeEh.Light) then
  begin
    FStyleColorMode := TStyleColorModeEh.Dark;
    EhLibImageResources.ResetResources();
    StyleColorModeChanged();
  end;
end;

procedure TStyleManagerEh.StyleColorModeChanged;
begin
  if Assigned(FOnStyleColorModeChange) then
    FOnStyleColorModeChange(Self);
end;

//procedure TStyleManagerEh.ApplyEhLibStyle(AStyleResource: TFmxObject);
//var
//  BaseBackColor, BaseForeColor: TAlphaColor;
//begin
//  BaseBackColor := TAlphaColorRec.Null;
//  BaseForeColor := TAlphaColorRec.Null;
//
//  TEhLibFmxSettings.Default.ResetStyleColorModeFromForegroundColor(BaseBackColor, BaseForeColor);
////  FEhLibStylesApplied := True;
//end;

{$ENDREGION 'TStyleManagerEh'}


{$REGION 'TEhLibComposedStyleBuilder'}

{ TEhLibComposedStyleBuilder }

constructor TEhLibComposedStyleBuilder.Create(AStyleManager: TStyleManagerEh);
begin
  inherited Create;
  FStyleManager := AStyleManager;
end;

destructor TEhLibComposedStyleBuilder.Destroy;
begin

  inherited Destroy;
end;

function TEhLibComposedStyleBuilder.FindStyleResource(AStyleElement, AStyleResource: String): TFmxObject;
begin
  Result := FStyleManager.FindStyleResource(AStyleElement, AStyleResource);
end;

function TEhLibComposedStyleBuilder.CreateStyleContainer: TFmxObject;
var
  GridBackground: TControl;
  FmxObj: TFmxObject;
  AColor: TAlphaColor;
  VControl: TControl;
  VOpacity: Single;
  SelectionColor: TAlphaColor;
  FocusColor: TAlphaColor;
  BackgroundColor: TAlphaColor;
begin
  Result := TStyleContainer.Create(nil);

  CreateStyleDescription(Result);

//  //EhLib.Grid.BackgroundStyle
//  BackgroundColor := TAlphaColorRec.Null;
//  FmxObj  := Self.FindStyleResource('GridStyle', 'background');
//  if FmxObj is TControl then
//  begin
//    GridBackground := TControl(FmxObj.Clone(nil));
//    GridBackground.DeleteChildren;
//    GridBackground.StyleName := 'EhLib.Grid.BackgroundStyle';
//
//    with TFmxObjectFactory<TLayout>.CreateWithParent(GridBackground) do
//    begin
//      StyleName := 'client';
//      Align := TAlignLayout.Client;
//      Size.Width := 100;
//      Size.Height := 100;
//      Size.PlatformDefault := False;
//    end;
//
//    Result.AddObject(GridBackground);
//
//    BackgroundColor := GetAverageColorFromControl(GridBackground);
//    with TFmxObjectFactory<TColorObject>.CreateWithParent(Result) do
//    begin
//      StyleName := 'EhLib.Control.BackgroundColorStyle';
//      Color := BackgroundColor;
//    end;
//  end;

  //EhLib.BaseGridStyle
  with TFmxObjectFactory<TLayout>.CreateWithParent(Result) do
  begin
    StyleName := 'EhLib.BaseGridStyle';
    Align := TAlignLayout.Contents;

    //'background'
    BackgroundColor := TAlphaColorRec.Null;
    FmxObj  := Self.FindStyleResource('GridStyle', 'background');
    if FmxObj is TControl then
    begin
      GridBackground := FmxObj.Clone(RefSelf) as TControl;
      GridBackground.DeleteChildren;
      GridBackground.StyleName := 'background';

      with TFmxObjectFactory<TLayout>.CreateWithParent(GridBackground) do
      begin
        StyleName := 'client';
        Align := TAlignLayout.Client;
        Size.Width := 100;
        Size.Height := 100;
        Size.PlatformDefault := False;
      end;
      RefSelf.AddObject(GridBackground);

      BackgroundColor := GetAverageColorFromControl(GridBackground);
    end;

    //'EhLib.BaseGridStyle'-'Elements'
    with TFmxObjectFactory<TLayout>.CreateWithParent(RefSelf) do
    begin
      Visible := False;
      StyleName := 'Elements';

      //BackgroundColor
      with TFmxObjectFactory<TColorObject>.CreateWithParent(RefSelf) do
      begin
        StyleName := 'BackgroundColor';
        Color := BackgroundColor;
      end;

      //ForegroundColor
      FmxObj  := Self.FindStyleResource('TextCellStyle', 'foreground');
      if FmxObj is TBrushObject then
      begin
        with TFmxObjectFactory<TColorObject>.CreateWithParent(RefSelf) do
        begin
          StyleName := 'ForegroundColor';
          Color := TBrushObject(FmxObj).Brush.Color;
        end;
      end;

      //Font
      FmxObj  := Self.FindStyleResource('TextCellStyle', 'font');
      if FmxObj is TFontObject then
      begin
        with TFmxObjectFactory<TFontObject>.CreateWithParent(RefSelf) do
        begin
          StyleName := 'Font';
          Font.Assign(TFontObject(FmxObj).Font);
        end;
      end else
      begin
        with TFmxObjectFactory<TFontObject>.CreateWithParent(RefSelf) do
        begin
          StyleName := 'Font';
          Font.Assign(SystemFont);
        end;
      end;

      //TopFixedCellBackground
      FmxObj  := Self.FindStyleResource('HeaderItemStyle', 'background');
      if FmxObj is TControl then
      begin
        VControl := FmxObj.Clone(RefSelf) as TControl;
  //      VControl.Align := TAlignLayout.Client;
        VControl.StyleName := 'TopFixedCellBackground';
        VControl.Align := TAlignLayout.None;
        VControl.Margins.Rect := TRectF.Create(-4, -4, -4, -4);
        RefSelf.AddObject(VControl);
      end;

      //FixedCellForeColor
      FmxObj  := Self.FindStyleResource('HeaderItemStyle', 'text');
      if FmxObj is TText then
      begin
        with TFmxObjectFactory<TColorObject>.CreateWithParent(RefSelf) do
        begin
          StyleName := 'FixedCellForeColor';
          Color := TText(FmxObj).TextSettings.FontColor;
        end;
      end;

      //EhLib.Grid.CellBorderLine.BrightColor
      FmxObj  := Self.FindStyleResource('GridStyle', 'LineFill');
      if FmxObj is TBrushObject then
      begin
        with TFmxObjectFactory<TColorObject>.CreateWithParent(RefSelf) do
        begin
          StyleName := 'BrightLineColor';
          Color := TBrushObject(FmxObj).Brush.Color;
        end;
      end;

      //EhLib.Grid.CellBorderLine.DarkColor
      FmxObj  := Self.FindStyleResource('GridStyle', 'LineFill');
      if FmxObj is TBrushObject then
      begin
        with TFmxObjectFactory<TColorObject>.CreateWithParent(RefSelf) do
        begin
          StyleName := 'DarkLineColor';
          Color := TBrushObject(FmxObj).Brush.Color;
        end;
      end;

      //CellSelectionFill  'GridStyle' 'selection'
      FmxObj  := Self.FindStyleResource('GridStyle', 'selection');
      if FmxObj is TBrushObject then
        SelectionColor := TBrushObject(FmxObj).Brush.Color
      else if FmxObj is TRectangle then
      begin
        if TRectangle(FmxObj).Fill.Kind = TBrushKind.Gradient
          then SelectionColor := TRectangle(FmxObj).Fill.Gradient.Points[0].Color
          else SelectionColor := TRectangle(FmxObj).Fill.Color;
        if TAlphaColorRec(SelectionColor).A = $FF then
        begin
          VOpacity := 0.8;
          SelectionColor := (Round(VOpacity * 255) shl 24) or (SelectionColor and $00FFFFFF);
        end;
      end
      else
        SelectionColor := TAlphaColorRec.Null;

      with TFmxObjectFactory<TBrushObject>.CreateWithParent(RefSelf) do
      begin
        StyleName := 'CellSelectionFill';
        Brush.Color := SelectionColor;
        Brush.Kind := TBrushKind.Solid;
      end;

      //CellFocusFill  'GridStyle' 'focus'
      FmxObj  := Self.FindStyleResource('GridStyle', 'focus');
      if FmxObj is TBrushObject then
        FocusColor := TBrushObject(FmxObj).Brush.Color
      else if FmxObj is TRectangle then
      begin
        FocusColor := TRectangle(FmxObj).Fill.Color;
        if TAlphaColorRec(FocusColor).A = $FF then
        begin
          VOpacity := 0.4;
          FocusColor := (Round(VOpacity * 255) shl 24) or (FocusColor and $00FFFFFF);
        end;
      end
      else
        FocusColor := TAlphaColorRec.Null;

      AColor := AlphaBlend(FocusColor, SelectionColor);
      with TFmxObjectFactory<TBrushObject>.CreateWithParent(RefSelf) do
      begin
        StyleName := 'CellFocusFill';
        Brush.Color := AColor;
        Brush.Kind := TBrushKind.Solid;
      end;

    end;
  end;

  //DataGridEhStyle
  with TFmxObjectFactory<TLayout>.CreateWithParent(Result) do
  begin
    StyleName := 'DataGridEhStyle';

    with TFmxObjectFactory<TStyledControlEh>.CreateWithParent(RefSelf) do
    begin
      Align := TAlignLayout.Contents;
      Visible := False;
      StyleName := 'ParentStyle';
      StyleLookUp := 'EhLib.BaseGridStyle'
    end;
  end;
end;

function TEhLibComposedStyleBuilder.CreateStyleDescription(AParent: TFmxObject): TFmxObject;
begin
  with TFmxObjectFactory<TStyleDescription>.CreateWithParent(AParent) do
  begin
    StyleName := 'EhLib.Fmx composed style';
    Author := 'EhLib Team';
    AuthorURL := 'https://www.ehlib.com';
    PlatformTarget := '[MSWINDOWS][MODERN][DEFINEFONTSTYLES][MACOS][IOS7][ANDROID][LINUX]';
    MobilePlatform := False;
    Title := 'EhLib.Fmx composed style';
    Version := '1.0';

    Result := RefSelf;
  end;
end;

{$ENDREGION 'TEhLibComposedStyleBuilder'}

initialization
  InitModule;
finalization
  FinalizeModule;
end.

