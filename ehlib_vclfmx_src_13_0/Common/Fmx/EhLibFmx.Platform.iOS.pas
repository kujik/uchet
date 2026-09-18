{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{                EhLibFmx.Platform.iOS                  }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.Platform.iOS;

interface

{$IFDEF IOS}

{$SCOPEDENUMS ON}

uses
  System.Types, System.Classes,
  System.UITypes, System.UIConsts, FMX.Styles,
  System.Generics.Collections, FMX.Forms, FMX.Platform, FMX.Types, FMX.Graphics,
  EhLibFmx.Platform,
  FMX.Platform.iOS, FMX.Helpers.iOS, iOSapi.UIKit;

type

  TEhLibPlatformWin = class(TInterfacedObject,
    IGridSystemColorsService,
    IStyleResourceService,
    IPlatformDeviceStateServiceEh)
  public
    function GetGridBackgroundColor: TAlphaColor;
    function GetGridFixedBackgroundColor: TAlphaColor;
    function GetGridLineDarkColor: TAlphaColor;
    function GetGridLineBrightColor: TAlphaColor;
    function GetGridBorderColor: TAlphaColor;
    function Get3DDkShadowColor: TAlphaColor;

    function GetStyleResource(): String;
    function InteractiveIsAnyKeyPressed(): Boolean;
    procedure RepaintInvalidatedFormRegion(AForm: TCommonCustomForm);
  end;

{$ENDIF IOS}

implementation

{$IFDEF IOS}

{$R EhLibFmx.Platform.Win.res}

var
  EhLibPlatformWin: TEhLibPlatformWin;

procedure RegisterPlatformServices;
begin
  EhLibPlatformWin := TEhLibPlatformWin.Create;
  TPlatformServices.Current.AddPlatformService(IGridSystemColorsService, EhLibPlatformWin);
  TPlatformServices.Current.AddPlatformService(IStyleResourceService, EhLibPlatformWin);
  TPlatformServices.Current.AddPlatformService(IPlatformDeviceStateServiceEh, EhLibPlatformWin);

  TStyleManager.RegisterPlatformStyleResource(TOSPlatform.Android, 'ehlib_win10style');
end;

procedure UnregisterPlatformServices;
begin
  TPlatformServices.Current.RemovePlatformService(IGridSystemColorsService);
  TPlatformServices.Current.RemovePlatformService(IStyleResourceService);
  TPlatformServices.Current.RemovePlatformService(IPlatformDeviceStateServiceEh);
end;

function ColorToRGB(Color: TColor): Longint;
begin
  if Color < 0 then
    Result := Color and $000000FF else
    Result := Color;
end;

function ColorToAlphaColor(Value: TColor): TAlphaColor;
var
  CRec: TColorRec;
  ARec: TAlphaColorRec;
begin
  CRec.Color := ColorToRGB(Value);
  ARec.A := 255;
  ARec.B := CRec.B;
  ARec.G := CRec.G;
  ARec.R := CRec.R;
  Result := ARec.Color;
end;

{ TEhLibPlatformWin }

function TEhLibPlatformWin.Get3DDkShadowColor: TAlphaColor;
begin
  Result := UIColorToAlphaColor(TUIColor.Wrap(TUIColor.OCClass.darkGrayColor));
end;

function TEhLibPlatformWin.GetGridBackgroundColor: TAlphaColor;
begin
  Result := UIColorToAlphaColor(TUIColor.Wrap(TUIColor.OCClass.whiteColor));
end;

function TEhLibPlatformWin.GetGridFixedBackgroundColor: TAlphaColor;
begin
  Result := UIColorToAlphaColor(TUIColor.Wrap(TUIColor.OCClass.systemGrayColor));
end;

function TEhLibPlatformWin.GetGridLineBrightColor: TAlphaColor;
begin
  Result := UIColorToAlphaColor(TUIColor.Wrap(TUIColor.OCClass.systemGrayColor));
end;

function TEhLibPlatformWin.GetGridLineDarkColor: TAlphaColor;
begin
  Result := UIColorToAlphaColor(TUIColor.Wrap(TUIColor.OCClass.darkGrayColor));
end;

function TEhLibPlatformWin.GetGridBorderColor: TAlphaColor;
begin
  Result := UIColorToAlphaColor(TUIColor.Wrap(TUIColor.OCClass.grayColor));
end;

function TEhLibPlatformWin.GetStyleResource: String;
begin
  Result := 'EHLIB_WIN10STYLE';
end;

function TEhLibPlatformWin.InteractiveIsAnyKeyPressed: Boolean;
begin
  Result := False;
end;

procedure TEhLibPlatformWin.RepaintInvalidatedFormRegion(AForm: TCommonCustomForm);
begin
end;

initialization
  RegisterPlatformServices;
finalization
  UnregisterPlatformServices;
{$ENDIF IOS}
end.
