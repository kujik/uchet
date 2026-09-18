{*******************************************************}
{                                                       }
{                       EhLib 12.1                      }
{      Register object that sort data in TQuery         }
{                                                       }
{    Copyright (c) 2002-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

{*******************************************************}
{ Add this unit to 'uses' clause of any unit of your    }
{ project to allow TDBGridEh to sort data in            }
{ TQuery automatically after sorting markers            }
{ will be changed.                                      }
{ TSQLDatasetFeaturesEh will try to find line in        }
{ TQuery.SQL string that begin from 'ORDER BY' phrase   }
{ and replace line by 'ORDER BY FieldNo1 [DESC],....'   }
{ using SortMarkedColumns.                              }
{*******************************************************}

unit EhLibVclBDE;

{$I ..\Incl\EhLib.Inc}

interface

uses
  Variants, DBGridEh.DBUtils,
  DBUtilsEh, DBGridEh, DBTables, Db, BDE, SysUtils;

implementation

uses Classes;

type
  TBDEDataSetCrack = class(TBDEDataSet);

function BDEDataSetDriverName(DataSet: TBDEDataSet): String;
var
  hCur: hDBICur;
  rslt: DBIResult;
{$IFDEF CIL}
{$ELSE}
  Descs: STMTBaseDesc;
{$ENDIF}
  dbDes: DBDesc;
begin
  hCur := nil;
  try
{$IFDEF CIL}
    if DataSet is TQuery then
      Check(DbiQGetBaseDescs(TQuery(DataSet).STMTHandle, hCur))
    else
    begin
      Result := '';
      Exit;
    end;
{ TODO : How to get DriverName under Delphi8? }
    Exit;
{$ELSE}
    Check(DbiQGetBaseDescs(TBDEDataSetCrack(DataSet).STMTHandle, hCur));
    rslt := DbiGetNextRecord(hCur, dbiNOLOCK, @Descs, nil);
    Check(DbiGetDatabaseDesc(Descs.szDatabase, @dbDes));
{$ENDIF}
     if (rslt = DBIERR_NONE) then
       Result := String(dbDes.szDbType);
  finally
    if (hCur <> nil) then
      check(DbiCloseCursor(hCur));
  end;
end;

function DateValueToBDESQLStringProc(DataSet: TDataSet; Value: Variant): String;
begin
  Result := DateValueToDataBaseSQLString(BDEDataSetDriverName(TBDEDataSet(DataSet)), Value)
end;

type
  TBDEDatasetFeaturesEh = class(TDBGridSQLDatasetFeaturesEh)
  public
    procedure ApplyFilter(Sender: TObject; DataSet: TDataSet; IsReopen: Boolean); override;
  end;

{ TBDEDatasetFeaturesEh }

procedure TBDEDatasetFeaturesEh.ApplyFilter(Sender: TObject; DataSet: TDataSet; IsReopen: Boolean);
begin
  if TDBGridEh(Sender).STFilter.Local then
  begin
    TDBGridEh(Sender).DataSet.Filter :=
      GetExpressionAsFilterString(TDBGridEh(Sender),
        GetOneExpressionAsLocalFilterString, nil);
    TDBGridEh(Sender).DataSet.Filtered := True;
  end else
    ApplyFilterSQLBasedDataSet(TDBGridEh(Sender), DataSet, DateValueToBDESQLStringProc, IsReopen, 'SQL');
end;

initialization
  RegisterDBGridDatasetFeaturesEh(TBDEDatasetFeaturesEh, TQuery);
  RegisterDBGridDatasetFeaturesEh(TBDEDatasetFeaturesEh, TTable);
end.
