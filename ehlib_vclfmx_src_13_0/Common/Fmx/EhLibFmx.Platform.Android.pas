{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{              EhLibFmx.Platform.Android                }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.Platform.Android;

interface

{$IFDEF ANDROID}

{$SCOPEDENUMS ON}

uses
  System.Types, System.Classes,
  System.UITypes, System.UIConsts, FMX.Styles,
  System.Generics.Collections, FMX.Forms, FMX.Platform, FMX.Types, FMX.Graphics,
  EhLibFmx.Platform, FMX.Platform.Android;

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

{$ENDIF}

implementation

{$IFDEF ANDROID}

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
end;

function ColorToAlphaColor(Value: TColor): TAlphaColor;
var
  CRec: TColorRec;
  ARec: TAlphaColorRec;
begin
  CRec.Color := TColorRec.ColorToRGB(Value);
  ARec.A := 255;
  ARec.B := CRec.B;
  ARec.G := CRec.G;
  ARec.R := CRec.R;
  Result := ARec.Color;
end;

{ TEhLibPlatformWin }

function TEhLibPlatformWin.Get3DDkShadowColor: TAlphaColor;
begin
  Result := ColorToAlphaColor(TColorRec.Sys3DDkShadow);
end;

function TEhLibPlatformWin.GetGridBackgroundColor: TAlphaColor;
begin
  Result := TAlphaColorRec.White;
end;

function TEhLibPlatformWin.GetGridBorderColor: TAlphaColor;
begin
  Result := TAlphaColorRec.Black;
end;

function TEhLibPlatformWin.GetGridFixedBackgroundColor: TAlphaColor;
begin
  Result := TAlphaColorRec.Whitesmoke;
end;

function TEhLibPlatformWin.GetGridLineBrightColor: TAlphaColor;
begin
  Result := ColorToAlphaColor(TColorRec.Gray);
end;

function TEhLibPlatformWin.GetGridLineDarkColor: TAlphaColor;
begin
  Result := ColorToAlphaColor(TColorRec.Silver);
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

{$ENDIF}

end.
