{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{                  EhLibFmx.Platform                    }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.Platform;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes, System.SysUtils, System.Types, System.Rtti, System.UITypes,
  System.Generics.Collections, FMX.Platform,
  System.Devices, System.Messaging, FMX.Types, FMX.Forms, FMX.Dialogs, FMX.Text,
  FMX.Graphics;

type
  IGridSystemColorsService = interface(IInterface)
    ['{30F3DE8E-327C-4DF4-9744-B68CA445ED7D}']
    function GetGridBackgroundColor: TAlphaColor;
    function GetGridFixedBackgroundColor: TAlphaColor;
    function GetGridLineDarkColor: TAlphaColor;
    function GetGridLineBrightColor: TAlphaColor;
    function GetGridBorderColor: TAlphaColor;
    function Get3DDkShadowColor: TAlphaColor;
  end;

  IStyleResourceService = interface(IInterface)
    ['{6A064148-6C58-41D2-B280-7BB8B77A1C7A}']
    function GetStyleResource(): String;
  end;

  IPlatformDeviceStateServiceEh = interface(IInterface)
    ['{CD5DB604-5E44-4988-9FBE-65F7E9C6372F}']
    function InteractiveIsAnyKeyPressed(): Boolean;
    procedure RepaintInvalidatedFormRegion(AForm: TCommonCustomForm);
  end;

implementation

uses
{$IFDEF IOS}
  EhLibFmx.Platform.iOS,
{$ELSE}
  {$IFDEF MACOS}
  EhLibFmx.Platform.Mac,
  {$ENDIF MACOS}
{$ENDIF IOS}

{$IFDEF MSWINDOWS}
  Winapi.Windows,
  EhLibFmx.Platform.Win,
  EhLibFmx.Canvas.D2D,
{$ENDIF}

{$IFDEF ANDROID}
  EhLibFmx.Platform.Android,
{$ENDIF}

{$IFDEF LINUX}
  EhLibFmx.Platform.Linux,
{$ENDIF}
  System.TypInfo;

end.
