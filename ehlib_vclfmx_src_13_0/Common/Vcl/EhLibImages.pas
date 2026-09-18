{*******************************************************}
{                                                       }
{                        EhLib 12.1                     }
{      Classes for detection Images stream format       }
{                                                       }
{   Copyright (c) 2011-2025 by Dmitry V. Bolshakov      }
{                                                       }
{*******************************************************}

unit EhLibImages;

{$I ..\Incl\EhLib.Inc}

interface

uses
{$IFDEF EH_LIB_11} EhLibGIFImage,  {$ENDIF} { Borland Developer Studio 2007 }
{$IFDEF EH_LIB_12} EhLibPNGImage, {$ENDIF} { CodeGear RAD Studio 2009 }
  EhLibUtils, ToolCtrlsEh, EhLibJPegImage;

implementation

initialization
  DoNothing();
end.
