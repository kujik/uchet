{*******************************************************}
{                                                       }
{                       EhLib v3.0                      }
{     Register object that sort data in TOracleDataset  }
{     from Direct Oracle Access (DOA) library by        }
{     Allround Automations.                             }
{     See detail info about DOA at                      }
{     http://www.allroundautomations.nl                 }
{                                                       }
{      Copyright (c) 2003 by Dmitry V. Bolshakov        }
{                                                       }
{*******************************************************}

{*******************************************************}
{ Add this unit to 'uses' clause of any unit of your    }
{ project to allow TDBGridEh to sort data in            }
{ TOracleDataset automatically after sorting markers    }
{ will be changed.                                      }
{ TDBGridSQLDatasetFeaturesEh will try to find line in        }
{ TOracleDataset.SQL string that begin from 'ORDER BY'  } 
{ phrase and replace line by 'ORDER BY FieldNo1 [DESC],'}
{ using SortMarkedColumns.                              }
{*******************************************************}

unit EhLibVclDOA;

{$I EhLib.Inc}

interface

uses
  DbUtilsEh, DBGridEh.DBUtils, OracleData;

implementation

uses Classes;

initialization
  RegisterDBGridDatasetFeaturesEh(TDBGridSQLDatasetFeaturesEh, TOracleDataset);
end.
