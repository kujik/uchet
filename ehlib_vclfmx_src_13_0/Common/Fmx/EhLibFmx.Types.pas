{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{                    EhLibFmx.Types                     }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.Types;

interface

{$SCOPEDENUMS ON}

uses System.Types, System.TypInfo, System.Variants, System.Classes,
  System.UITypes,
  System.SysUtils, FMX.Controls, FMX.Forms;

type
  TScrollStepTypeEh = (ByPixel, ByCell);

  TCheckBoxStateEh = (Unchecked, Checked, Undetermined);

  TTreeSignStateEh = (Expanded, Collapsed);

  TRectangleEdgeEh = (Left, Top, Right, Bottom);
  TRectangleEdgesEh = set of TRectangleEdgeEh;

  TGridCellFillStyleEh = (Default, Themed, Solid, Gradient);

  TDrawButtonControlStyleEh = (DropDown, Ellipsis, UpDown,
    Checkbox, Plus, Minus, AltDropDown, AltUpDown);

  TEditButtonStyleEh = (DropDown, Ellipsis, Glyph, UpDown,
    Plus, Minus, AltDropDown, AltUpDown);

  TImagePlacementEh = (TopLeft, TopCenter, TopRight,
                       CenterLeft, CenterCenter, CenterRight,
                       BottomLeft, BottomCenter, BottomRight,
                       Fill, ReduceFit, Fit, Stretch, Tile);

  TBorderStyle = (None, Single);
  TScrollCode = (LineUp, LineDown, PageUp, PageDown, Position,
    Track, Top, Bottom, EndScroll);

  TTreeElementEh = (MinusUpDown, MinusUp, MinusDown, MinusHLine, Minus,
                   PlusUpDown, PlusUp, PlusDown, PlusHLine, Plus,
                   CrossUpDown, CrossUp, CrossDown,
                   VLine, HLine);

  TInteractiveActionSourceEh = (Mouse, Keyboard, Other);

  TPropListArray = array of PPropInfo;

  TWinControl = TControl;

  TPopupMenuBuildingMode = (
    PropertyDefined,
    LocalAndGlobalMenuCompound,
    LocalMenuCompound
  );

  TFormClass = class of TForm;

  TPlatformWindowSizeTypeEh = (Sizable, FullScreen);

  TListSourceOriginEh = (ListSource, ListItems);

  TColumnFrozenPositionEh = (Left, None, Right);

  TStyleColorModeEh = (Light, Dark);

  TStyleOriginEh = (BuiltIn, Composed);

{ TEhLibFmxSettings }

  TEhLibFmxSettings = class(TPersistent)
  private
    FPlatformWindowSizeType: TPlatformWindowSizeTypeEh;
    FPlatformWindowSizeTypeStored: Boolean;
    FTouchTracking: Boolean;
    FTouchTrackingStored: Boolean;
//    FStyleOrigin: TStyleOriginEh;

    function GetPlatformWindowSizeType: TPlatformWindowSizeTypeEh;
    function GetTouchTracking: Boolean;
    procedure SetPlatformWindowSizeType(const Value: TPlatformWindowSizeTypeEh);
    procedure SetTouchTracking(const Value: Boolean);
  protected

  public
    constructor Create;

    class function Default: TEhLibFmxSettings;

    property PlatformWindowSizeType: TPlatformWindowSizeTypeEh read GetPlatformWindowSizeType write SetPlatformWindowSizeType;
    property PlatformWindowSizeTypeStored: Boolean read FPlatformWindowSizeTypeStored write FPlatformWindowSizeTypeStored;

    property TouchTracking: Boolean read GetTouchTracking write SetTouchTracking;
    property TouchTrackingStored: Boolean read FTouchTrackingStored write FTouchTrackingStored;
  end;

implementation

uses FMX.Platform, EhLibFmx.ImageReses;

var
  FEhLibFmxSettings: TEhLibFmxSettings;

{ TEhLibFmxSettings }

constructor TEhLibFmxSettings.Create;
begin
  inherited Create;
  FTouchTrackingStored := False;
end;

class function TEhLibFmxSettings.Default: TEhLibFmxSettings;
begin
  if FEhLibFmxSettings = nil then
    FEhLibFmxSettings := TEhLibFmxSettings.Create;
  Result := FEhLibFmxSettings;
end;

function TEhLibFmxSettings.GetPlatformWindowSizeType: TPlatformWindowSizeTypeEh;
begin
  if PlatformWindowSizeTypeStored then
  begin
    Result := FPlatformWindowSizeType;
  end
  else
  begin
{$IF Defined(ANDROID) OR Defined(IOS)}
    Result := TPlatformWindowSizeTypeEh.FullScreen;
{$ELSE}
    Result := TPlatformWindowSizeTypeEh.Sizable;
{$ENDIF}
  end;
end;

procedure TEhLibFmxSettings.SetPlatformWindowSizeType(const Value: TPlatformWindowSizeTypeEh);
begin
  FPlatformWindowSizeType := Value;
  FPlatformWindowSizeTypeStored := True;
end;

function TEhLibFmxSettings.GetTouchTracking: Boolean;
var
  ASystemInformationService: IFMXSystemInformationService;
begin
  if FTouchTrackingStored then
  begin
    Result := FTouchTracking;
  end
  else
  begin
    TPlatformServices.Current.SupportsPlatformService(IFMXSystemInformationService, ASystemInformationService);
    Result := ((ASystemInformationService <> nil) and
               (TScrollingBehaviour.TouchTracking in ASystemInformationService.GetScrollingBehaviour));
  end;
end;

procedure TEhLibFmxSettings.SetTouchTracking(const Value: Boolean);
begin
  FTouchTracking := Value;
  FTouchTrackingStored := True;
end;

initialization
finalization
  FreeAndNil(FEhLibFmxSettings);
end.
