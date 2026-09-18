{*******************************************************}
{                                                       }
{                       EhLib 12.1                      }
{                    EhLibSplash form                   }
{                                                       }
{    Copyright (c) 2013-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibSplash;

{$I ..\Incl\EhLib.Inc}

interface

implementation

{$R EhLibSplash.res}

uses Classes, DesignIntf, ToolsAPI, Windows, EhLibUtils, TypInfo;

procedure Init;
begin
{$IFDEF EH_LIB_9}

  SplashScreenServices.AddPluginBitmap(EhLibVerInfo + ' ' + EhLibBuildInfo,
    LoadBitmap(FindResourceHInstance(HInstance), 'EHLIB_SPLASH_ICON_24'),
{$IFDEF eval}
   True, EhLibEditionInfo
{$ELSE}
   False, EhLibEditionInfo
{$ENDIF}
);

{$ENDIF}
end;

initialization
  Init;
finalization
end.
