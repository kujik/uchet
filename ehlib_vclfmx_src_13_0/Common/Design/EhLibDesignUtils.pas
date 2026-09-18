{*******************************************************}
{                                                       }
{                       EhLib 12.1                      }
{                EhLibDesignUtils unit                  }
{                                                       }
{   Copyright (c) 2023-2025 by Dmitry V. Bolshakov      }
{                                                       }
{*******************************************************}

{$I ..\Incl\EhLib.Inc}

unit EhLibDesignUtils;

interface

uses
  SysUtils,
  {$IFDEF FPC}
  LCLType,
  PropEdits, ComponentEditors,
  {$ELSE}
  ColnEdit,
  DesignIntf, DesignEditors, VCLEditors, Variants, ToolsAPI,
  {$ENDIF}
  ToolCtrlsEh,
  EhLibUtils,
  TypInfo, Contnrs, DB, Classes;

type

{ TUniDataSourceProperty }

  TUniDataSourceProperty = class(TComponentProperty)
  public
    procedure GetValues(Proc: TGetStrProc); override;
  end;

{ TListFieldProperty }

  TListFieldProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValueList(List: TStrings); virtual;
    procedure GetValues(Proc: TGetStrProc); override;
    function GetDataSourcePropName: string; virtual;
    function GetDataSet: TDataSet; virtual;
  end;

{$IFDEF FPC}
{$ELSE}
procedure GetComponentNamesEh(lst: TStrings; TargetClass:
  TClass; DividePackages: Boolean; TargetComponent: TComponent = nil;
  TargetPropName: String = '');


{$ENDIF}

implementation

var
  NiClasses: TClassList;

procedure InitUnit;
begin
  NiClasses := TClassList.Create;
  {$IFDEF FPC}
  {$ELSE}
  {$ENDIF}
end;

procedure FinalizeUnit;
begin
  FreeAndNil(NiClasses);
end;


{$IFDEF FPC}
{$ELSE}

procedure GetNvfComponentNamesEh(lst: TStrings;
  TargetClass: TClass; AddSeparator: Boolean;
  TargetComponent: TComponent = nil; TargetPropName: String = '');
var
  i: Integer;
  CRef: TClass;
  TheNewOne: Boolean;
  INiComponentSideParentItfs: ISideOwnerEh;
  Approved: Boolean;
begin
  TheNewOne := False;
  Approved := False;
  if TargetComponent = nil then
    Approved := True
  else if Supports(TargetComponent, ISideOwnerEh, INiComponentSideParentItfs) and
          INiComponentSideParentItfs.IsSideParentableForProperty(TargetPropName)
  then
    Approved := True;

  if not Approved then Exit;

  for I := 0 to NiClasses.Count-1 do
  begin
    if AddSeparator and TheNewOne and (lst.Count > 0) then
      lst.AddObject('-', nil);
    CRef := TClass(NiClasses[i]);
    if (CRef <> nil) and CRef.InheritsFrom(TargetClass) then
    begin
      lst.AddObject(CRef.ClassName, TObject(CRef));
      TheNewOne := False;
    end;
 end;
end;

procedure GetComponentNamesEh(lst: TStrings;
  TargetClass: TClass; DividePackages: Boolean; TargetComponent: TComponent = nil;
  TargetPropName: String = '');
var
  i, k: Integer;
  CRef: TClass;
  LServices: IOTAPackageServices;
  TheNewOne: Boolean;
begin
  lst.Clear;
  LServices := BorlandIDEServices as IOTAPackageServices;
  TheNewOne := False;
  for i := 0 to LServices.PackageCount-1 do
  begin
    for k := 0 to LServices.ComponentCount[i]-1 do
    begin
      CRef := TClass(GetClass(LServices.GetComponentName(i, k)));
      if (CRef <> nil) and CRef.InheritsFrom(TargetClass) then
      begin
        if DividePackages and TheNewOne then
          lst.AddObject('-', nil);
        lst.AddObject(CRef.ClassName, TObject(CRef));
        TheNewOne := False;
      end;
    end;
    TheNewOne := True;
  end;

  GetNvfComponentNamesEh(lst, TargetClass, DividePackages, TargetComponent, TargetPropName);
end;
{$ENDIF}

{ TListFieldProperty }

function TListFieldProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList, paMultiSelect];
end;

function GetPropertyValue(Instance: TPersistent; const PropName: string): TPersistent;
var
  PropInfo: PPropInfo;
begin
  Result := nil;
  PropInfo := TypInfo.GetPropInfo(Instance.ClassInfo, PropName);
  if (PropInfo <> nil) and (PropType_GetKind(PropInfo_getPropType(PropInfo)) = tkClass) then
    Result := TObject(GetObjectProp(Instance, PropInfo)) as TPersistent;
end;

procedure TListFieldProperty.GetValueList(List: TStrings);
var
  DataSource: TDataSource;
  ADataSet: TDataSet;
begin
  ADataSet := GetDataSet;
  if ADataSet = nil then
  begin
    DataSource := GetPropertyValue(GetComponent(0), GetDataSourcePropName) as TDataSource;
    if DataSource <> nil then
      ADataSet := DataSource.DataSet;
  end;
  if ADataSet <> nil then
    ADataSet.GetFieldNames(List);
end;

procedure TListFieldProperty.GetValues(Proc: TGetStrProc);
var
  I: Integer;
  Values: TStringList;
begin
  Values := TStringList.Create;
  try
    GetValueList(Values);
    for I := 0 to Values.Count - 1 do Proc(Values[I]);
  finally
    Values.Free;
  end;
end;

function TListFieldProperty.GetDataSourcePropName: string;
begin
  Result := 'ListSource';
end;

function TListFieldProperty.GetDataSet: TDataSet;
begin
  Result := nil;
end;

{ TUniDataSourceProperty }

procedure TUniDataSourceProperty.GetValues(Proc: TGetStrProc);
begin
{$IFDEF FPC}
  PropertyHook.GetComponentNames(GetTypeData(TDataSource.ClassInfo), Proc);
  PropertyHook.GetComponentNames(GetTypeData(TDataSet.ClassInfo), Proc);
{$ELSE}
  Designer.GetComponentNames(GetTypeData(TDataSource.ClassInfo), Proc);
  Designer.GetComponentNames(GetTypeData(TDataSet.ClassInfo), Proc);
{$ENDIF}
end;

initialization
  InitUnit;
finalization
  FinalizeUnit;
end.

