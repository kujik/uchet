{*******************************************************}
{                                                       }
{                       EhLib 12.1                      }
{                  EhLibRegister Unit                   }
{                                                       }
{   Copyright (c) 2023-2025 by Dmitry V. Bolshakov      }
{                                                       }
{*******************************************************}


{$I ..\Incl\EhLib.Inc}

unit EhLibRegister;

interface

uses Classes,
  {$IFDEF FPC}
  {$ELSE}
  StorablePropsDesignIntfEh, CompoMansDesignEh,
  {$ENDIF}
  DBSumLst, MemTableDesignEh, DataSetImpExpDesignEh;

procedure Register;

implementation

procedure Register;
begin
  {$IFDEF FPC}
  {$ELSE}
  RegisterCompoMan;
  {$ENDIF}

  RegisterComponents('EhLib Components', [TDBSumList]);

  RegisterMemTable;
  RegisterDataSetImpExp;
end;

end.
