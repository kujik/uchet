{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{                EhLibFmx.Platform.Win                  }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.Platform.Win;

interface

{$IFDEF MSWINDOWS}

{$SCOPEDENUMS ON}

uses
  Winapi.CommCtrl, Winapi.Windows, Winapi.Messages, Winapi.ActiveX,
  System.Types, System.Classes, Winapi.UxTheme,
  System.UITypes, System.UIConsts, FMX.Styles, System.SysUtils,
  EhLibUtils,
  System.Generics.Collections, FMX.Forms, FMX.Platform, FMX.Types, FMX.Graphics,
  FMX.ZOrder.Win, EhLibFmx.Platform, FMX.Platform.Win;

type

  TEhLibPlatformWin = class(TInterfacedObject,
    IGridSystemColorsService,
    IStyleResourceService,
    IPlatformDeviceStateServiceEh)
  private
    FInteractiveIsAnyKeyPressedCallTime: Cardinal;
  public
    constructor Create;

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

{$IFDEF MSWINDOWS}

var
  EhLibPlatformWin: TEhLibPlatformWin;

{$R EhLibFmx.Platform.Win.res}


type
  COLORREF = LongWord;

function WindowsStyleSelection(const APlatform: TOSPlatform): string;
begin
  if TOSVersion.Check(10) then
    Result := 'ehlib_win10style'
  else if TOSVersion.Check(6, 2) then
    Result := 'ehlib_win8style'
  else
    Result := 'ehlib_win7style';
end;

procedure RegisterPlatformServices;
begin
  EhLibPlatformWin := TEhLibPlatformWin.Create;
  TPlatformServices.Current.AddPlatformService(IGridSystemColorsService, EhLibPlatformWin);
  TPlatformServices.Current.AddPlatformService(IStyleResourceService, EhLibPlatformWin);
  TPlatformServices.Current.AddPlatformService(IPlatformDeviceStateServiceEh, EhLibPlatformWin);

  TStyleManager.RegisterPlatformStyleResource(TOSPlatform.Windows, 'ehlib_win7style');
  TStyleManager.RegisterPlatformStyleResource(TOSPlatform.Windows, 'ehlib_win8style');
  TStyleManager.RegisterPlatformStyleResource(TOSPlatform.Windows, 'ehlib_win10style');
  TStyleManager.RegisterPlatformStyleSelection(TOSPlatform.Windows, WindowsStyleSelection);
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
    Result := GetSysColor(Color and $000000FF) else
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

constructor TEhLibPlatformWin.Create;
begin
  inherited Create;
end;

function TEhLibPlatformWin.Get3DDkShadowColor: TAlphaColor;
begin
  Result := ColorToAlphaColor(TColorRec.Sys3DDkShadow);
end;

function TEhLibPlatformWin.GetGridBackgroundColor: TAlphaColor;
begin
  Result := ColorToAlphaColor(TColorRec.SysWindow);
end;

function TEhLibPlatformWin.GetGridBorderColor: TAlphaColor;
begin
  Result := ColorToAlphaColor(TColorRec.SysWindowFrame);
end;

function TEhLibPlatformWin.GetGridFixedBackgroundColor: TAlphaColor;
begin
  Result := ColorToAlphaColor(TColorRec.SysBtnFace);
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

function IsKeyPressed(VKey: Word): Boolean;
begin
  Result := (GetAsyncKeyState(VKey) and $8000) <> 0;
end;

function TEhLibPlatformWin.InteractiveIsAnyKeyPressed: Boolean;
var
  TickDelta:  Cardinal;
  CharMsg: TMsg;
begin
  Result := False;
  TickDelta := TThread.GetTickCount - FInteractiveIsAnyKeyPressedCallTime;
  if TickDelta > Cardinal(100) then
  begin
    FInteractiveIsAnyKeyPressedCallTime := TThread.GetTickCount;
//    if IsKeyPressed(VK_DOWN) then
//      Result := True
//    else
//      Result := False;
    if PeekMessage(CharMsg, 0, WM_KEYDOWN, WM_KEYDOWN, PM_NOREMOVE) then
      Result := True
    else
      Result := False;
  end else
  begin
    DoNothing;
  end;
end;

function HasInvalidArea(hWnd: HWND): Boolean;
var
  R: TRect;
begin
  Result := GetUpdateRect(hWnd, R, False);
end;

procedure TEhLibPlatformWin.RepaintInvalidatedFormRegion(AForm: TCommonCustomForm);
begin
  if HasInvalidArea(TWinWindowHandle(AForm.Handle).Wnd) then
    Winapi.Windows.UpdateWindow(TWinWindowHandle(AForm.Handle).Wnd);
end;

initialization
  RegisterPlatformServices;
finalization
  UnregisterPlatformServices;

{$ENDIF}

end.
