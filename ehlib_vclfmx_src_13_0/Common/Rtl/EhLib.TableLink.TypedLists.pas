{*******************************************************}
{                                                       }
{                      EhLib 12.1                       }
{             EhLib.TableLink.TypedLists                }
{                                                       }
{     Copyright (c) 2024-2025 by Dmitry V. Bolshakov    }
{                                                       }
{*******************************************************}

unit EhLib.TableLink.TypedLists;

{$I ..\Incl\EhLib.Inc}
{$SCOPEDENUMS ON}

interface

{$IFDEF EH_LIB_17} 

uses EhLib.TableLinks, TypInfo, Types,
  Classes, SysUtils, StrUtils,
  Variants, Contnrs,
  Generics.Collections, Rtti,
  DBUtilsEh, EhLibUtils;

type
  TTypedListFieldLinkEh = class;
  TListFieldLinkListEh = class;
  TTypedListItemLinkEh = class;
  TListRecLinkListEh = class;
  TListTableLinkEh = class;

  TListFieldLinkListEh<T: class, constructor> = class;
  TTypedListItemLinkEh<T: class, constructor> = class;
  TListRecLinkListEh<T: class, constructor> = class;
  TListTableLinkEh<T: class, constructor> = class;

  TTypedObjectListItemLinkEh = class;
  TObjectListRecLinkListEh = class;
  TObjectListTableLinkEh = class;

  TListTableLinkPropInfoEh = record
    PropName: String;
    DisplayCaption: String;
  end;

  TListTableLinkDeepPropInfoEh = record
    Props: TArray<TRttiProperty>;
    DisplayCaption: String;
  end;
  
{ TTypedListFieldLinkEh }

  TTypedListFieldLinkEh = class(TTableFieldLinkEh)
  private
  protected
    FFields: TArray<TRttiProperty>;
    FDisplayName: String;

    function GetFieldName: String; override;
    function GetDisplayName: String; override;

    function GetDataTypeInfo: PTypeInfo; override;
    function GetDataVarSubtype: TVarType; override;

  public
    constructor Create(AFieldLinkList: TTableFieldLinkListEh);
    destructor Destroy; override;

    property Fields: TArray<TRttiProperty> read FFields;
  end;

{ TListFieldLinkListEh }

  TListFieldLinkListEh = class(TTableFieldLinkListEh)
  private
    function GetFieldLink(Index: Integer): TTypedListFieldLinkEh;
    function GetTableDataLink: TListTableLinkEh;
    function GetRttiPropListAsArray(ATypeInfo: Pointer): TArray<TRttiProperty>;

  protected
    procedure FillList(APropInfoArr: TArray<TListTableLinkPropInfoEh>); reintroduce;
    procedure Clear;

  public
    constructor Create(ATableDataLink: TBaseTableDataLinkEh);
    destructor Destroy; override;

    function IndexOf(AField: TRttiProperty): Integer;

    property FieldLink[Index: Integer]: TTypedListFieldLinkEh read GetFieldLink; default;
    property TableDataLink: TListTableLinkEh read GetTableDataLink;
  end;

{ TTypedListItemLinkEh }

  TTypedListItemLinkEh = class(TTableRowLinkEh)
  private
    FSourceItem: Pointer;
    function GetRowLinkList: TListRecLinkListEh;
  protected
    function GetEditModified: Boolean; override;
    function GetEditState: TRowLinkEditStateEh; override;
    function GetValue(ValueIndex: Integer): TValue; override;
    function GetSourceItem: Pointer; override;
    function GetSourceObjectItem: TObject; override;

    procedure InitNewRow(ARowLinkList: TTableRowLinkListEh; ARowPos: Integer); override;

  public
    constructor Create(ARowLinkList: TTableRowLinkListEh);
    destructor Destroy; override;

    property RowLinkList: TListRecLinkListEh read GetRowLinkList;
  end;

{ TListRecLinkListEh }

  TListRecLinkListEh = class(TTableRowLinkListEh)
  private
    function GetRowLink(Index: Integer): TTypedListItemLinkEh;
    function GetListTableLink: TListTableLinkEh;
  protected
    function InternalCreateRowLink: TTableRowLinkEh; override;
    procedure FetchListItem(ListItem: Pointer);
  public
    constructor Create(ATableDataLink: TBaseTableDataLinkEh);
    destructor Destroy; override;

    function IndexOf(ASourceListItem: Pointer): Integer; overload;

    property RowLink[Index: Integer]: TTypedListItemLinkEh read GetRowLink; default;
    property ListTableLink: TListTableLinkEh read GetListTableLink;
  end;

{ TListTableLinkEh }

  TListTableLinkEh = class(TBaseTableDataLinkEh)
  private
    RttiContext: TRttiContext;
    FItemTypeInfo: Pointer;
    FItemType: TRttiType;
    FSourceList: TList;
    FInternalList: TList;
    FActive: Boolean;

    function GetCurrentRow: TTypedListItemLinkEh;
    function GetFieldLinkList: TListFieldLinkListEh;
    function GetRows: TListRecLinkListEh;

  protected
    function GetCanModify: Boolean; override;
    function GetActive: Boolean; override;
    function CheckUpdateFieldLinkList: Boolean; override;
    function CreateFieldLinkList: TTableFieldLinkListEh; override;
    function CreateRowLinkList: TTableRowLinkListEh; override;

    procedure RaiseInactiveError; override;
    procedure FillRowLinkList; override;
    procedure UpdateCurrentRowIndex(IsSendNotification: Boolean); override;
    procedure SetCurrentRowIndex(const Value: Integer); override;
    procedure SetCurrentRowValue(AFieldValueIndex: Integer; const AValue: TValue); override;
    procedure UpdateActive;
    procedure ActiveChanged;

    procedure SetItemTypeInfo(AItemTypeInfo: Pointer); virtual;

  public
    constructor Create(AOwner: TComponent); reintroduce; overload; virtual;
    destructor Destroy; override;

    procedure SetList(AList: TList; AItemTypeInfo: Pointer); overload;
    procedure SetList(AList: TList; AItemTypeInfo: Pointer; APropNameList: array of String); overload;
    procedure SetList(AList: TList; AItemTypeInfo: Pointer; APropInfoList: TArray<TListTableLinkPropInfoEh>); overload;

    procedure SetList<T: class>(AArray: TArray<T>); overload;
    procedure SetList<T: class>(AArray: TArray<T>; APropNameList: array of String); overload;
    procedure SetList<T: class>(AArray: TArray<T>; APropInfoList: TArray<TListTableLinkPropInfoEh>); overload;

    procedure SetList<T: class>(AList: TList<T>); overload;
    procedure SetList<T: class>(AList: TList<T>; APropNameList: array of String); overload;
    procedure SetList<T: class>(AList: TList<T>; APropInfoList: TArray<TListTableLinkPropInfoEh>); overload;

    property SourceList: TList read FSourceList;
    property InternalList: TList read FInternalList;

    function AppendNewRow(): Integer; override;
    function InsertNewRow(): Integer; override;

    procedure EditCurrentRow(); override;
    procedure CancelCurrentRow(); override;
    procedure PostCurrentRow(); override;
    procedure DeleteCurrentRow(); override;

    function ListItemIsObject: Boolean;
    function ItemClassType: TClass;

    property ItemTypeInfo: Pointer read FItemTypeInfo;
    property Fields: TListFieldLinkListEh read GetFieldLinkList;
    property Rows: TListRecLinkListEh read GetRows;
    property CurrentRow: TTypedListItemLinkEh read GetCurrentRow;
  end;

{ TListFieldLinkListEh<T> }

  TListFieldLinkListEh<T: class, constructor> = class(TTableFieldLinkListEh)
  private
    function GetFieldLink(Index: Integer): TTypedListFieldLinkEh;
    function GetTableDataLink: TListTableLinkEh<T>;
    function GetRttiPropListAsArray(ATypeInfo: Pointer): TArray<TRttiProperty>;

  protected
    procedure FillList; override;
    procedure Clear;

  public
    constructor Create(ATableDataLink: TBaseTableDataLinkEh);
    destructor Destroy; override;

    function IndexOf(AField: TRttiProperty): Integer;

    property FieldLink[Index: Integer]: TTypedListFieldLinkEh read GetFieldLink; default;
    property TableDataLink: TListTableLinkEh<T> read GetTableDataLink;
  end;

{ TTypedListItemLinkEh<T> }

  TTypedListItemLinkEh<T: class, constructor> = class(TTableRowLinkEh)
  private
    FSourceItem: T;
    function GetRowLinkList: TListRecLinkListEh<T>;
  protected
    function GetEditModified: Boolean; override;
    function GetEditState: TRowLinkEditStateEh; override;
    function GetValue(ValueIndex: Integer): TValue; override;
    function GetSourceItem: Pointer; override;
    function GetSourceObjectItem: TObject; override;

    procedure InitNewRow(ARowLinkList: TTableRowLinkListEh; ARowPos: Integer); override;

  public
    constructor Create(ARowLinkList: TTableRowLinkListEh);
    destructor Destroy; override;

    property RowLinkList: TListRecLinkListEh<T> read GetRowLinkList;
    property SourceItem: T read FSourceItem;
  end;

{ TListRecLinkListEh<T> }

  TListRecLinkListEh<T: class, constructor> = class(TTableRowLinkListEh)
  private
    function GetRowLink(Index: Integer): TTypedListItemLinkEh<T>;
    function GetListTableLink: TListTableLinkEh<T>;
  protected
    function InternalCreateRowLink: TTableRowLinkEh; override;
    procedure FetchListItem(ListItem: T);
  public
    constructor Create(ATableDataLink: TBaseTableDataLinkEh);
    destructor Destroy; override;

    function IndexOf(ASourceListItem: T): Integer; overload;

    property RowLink[Index: Integer]: TTypedListItemLinkEh<T> read GetRowLink; default;
    property ListTableLink: TListTableLinkEh<T> read GetListTableLink;
  end;

{ TListTableLinkEh<T> }

  TListTableLinkEh<T: class, constructor> = class(TBaseTableDataLinkEh)
  private
    FSourceList: TList<T>;
    FArrayList: TList<T>;
    RttiContext: TRttiContext;
    FActive: Boolean;

    function GetCurrentRow: TTypedListItemLinkEh<T>;
    function GetFieldLinkList: TListFieldLinkListEh<T>;
    function GetRows: TListRecLinkListEh<T>;

  protected
    function GetCanModify: Boolean; override;
    function GetActive: Boolean; override;
    function CheckUpdateFieldLinkList: Boolean; override;
    function CreateFieldLinkList: TTableFieldLinkListEh; override;
    function CreateRowLinkList: TTableRowLinkListEh; override;

    procedure RaiseInactiveError; override;
    procedure FillRowLinkList; override;
    procedure UpdateCurrentRowIndex(IsSendNotification: Boolean); override;
    procedure SetCurrentRowIndex(const Value: Integer); override;
    procedure SetCurrentRowValue(AFieldValueIndex: Integer; const AValue: TValue); override;
    procedure UpdateActive;
    procedure ActiveChanged;

  public
    constructor Create(AOwner: TComponent); reintroduce; overload; virtual;
    destructor Destroy; override;

    procedure SetList(AList: TList<T>); overload;
    procedure SetList(AArray: TArray<T>); overload;

    property SourceList: TList<T> read FSourceList;

    function AppendNewRow(): Integer; override;
    function InsertNewRow(): Integer; override;
    procedure EditCurrentRow(); override;
    procedure CancelCurrentRow(); override;
    procedure PostCurrentRow(); override;
    procedure DeleteCurrentRow(); override;

    function ListItemIsObject: Boolean;

    property Fields: TListFieldLinkListEh<T> read GetFieldLinkList;
    property Rows: TListRecLinkListEh<T> read GetRows;
    property CurrentRow: TTypedListItemLinkEh<T> read GetCurrentRow;
  end;

{ TTypedObjectListItemLinkEh }

  TTypedObjectListItemLinkEh = class(TTypedListItemLinkEh)
  private
    function GetSourceItem: TObject; reintroduce;
    function GetRowLinkList: TObjectListRecLinkListEh;
  protected
    function GetValue(ValueIndex: Integer): TValue; override;

    procedure InitNewRow(ARowLinkList: TTableRowLinkListEh; ARowPos: Integer); override;

  public
    constructor Create(ARowLinkList: TTableRowLinkListEh);
    destructor Destroy; override;

    property RowLinkList: TObjectListRecLinkListEh read GetRowLinkList;
    property SourceItem: TObject read GetSourceItem;
  end;

{ TObjectListRecLinkListEh }

  TObjectListRecLinkListEh = class(TListRecLinkListEh)
  private
    function GetRowLink(Index: Integer): TTypedObjectListItemLinkEh;
    function GetListTableLink: TObjectListTableLinkEh;
  protected
    function InternalCreateRowLink: TTableRowLinkEh; override;
  public
    constructor Create(ATableDataLink: TBaseTableDataLinkEh);
    destructor Destroy; override;

    function IndexOf(ASourceListItem: TObject): Integer; overload;

    property RowLink[Index: Integer]: TTypedObjectListItemLinkEh read GetRowLink; default;
    property ListTableLink: TObjectListTableLinkEh read GetListTableLink;
  end;

{ TObjectListTableLinkEh }

  TObjectListTableLinkEh = class(TListTableLinkEh)
  private
    FItemType: TRttiInstanceType;

    function GetRows: TObjectListRecLinkListEh;

  protected
    function CreateRowLinkList: TTableRowLinkListEh; override;

    procedure SetItemTypeInfo(AItemTypeInfo: Pointer); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Rows: TObjectListRecLinkListEh read GetRows;
  end;

function ListTableLinkPropInfoEh(PropName: String; DisplayCaption: String): TListTableLinkPropInfoEh;

{$ENDIF} 

implementation

{$IFDEF EH_LIB_17} 

function ListTableLinkPropInfoEh(PropName: String; DisplayCaption: String): TListTableLinkPropInfoEh;
begin
  Result.PropName := PropName;
  Result.DisplayCaption := DisplayCaption;
end;

{ TTypedListFieldLinkEh }

constructor TTypedListFieldLinkEh.Create(AFieldLinkList: TTableFieldLinkListEh);
begin
  inherited Create(AFieldLinkList);
end;

destructor TTypedListFieldLinkEh.Destroy;
begin
  inherited Destroy;
end;

function TTypedListFieldLinkEh.GetDataTypeInfo: PTypeInfo;
begin
  if FFields <> nil then
  begin
    Result := FFields[Length(FFields) - 1].PropertyType.Handle;
  end else
    Result := nil;
end;

function TTypedListFieldLinkEh.GetDataVarSubtype: TVarType;
begin
  if DataTypeInfo = TypeInfo(Variant) then
    Result := varVariant
  else
    Result := varError;
end;

function TTypedListFieldLinkEh.GetDisplayName: String;
begin
  Result := FDisplayName;
  if Result = '' then
    Result := FieldName;
end;

function TTypedListFieldLinkEh.GetFieldName: String;
var
  I: Integer;
begin
  Result := '';
  if FFields <> nil then
  begin
    for I := 0 to Length(FFields) - 1 do
    begin
      if I > 0 then
        Result := Result + '.';      
      Result := Result + FFields[I].Name;
    end;  
  end;
end;

{ TListFieldLinkListEh }

constructor TListFieldLinkListEh.Create(ATableDataLink: TBaseTableDataLinkEh);
begin
  inherited Create(ATableDataLink);
end;

destructor TListFieldLinkListEh.Destroy;
begin

  inherited Destroy;
end;

procedure TListFieldLinkListEh.Clear;
begin
  inherited Clear;
end;

function TListFieldLinkListEh.GetRttiPropListAsArray(ATypeInfo: Pointer): TArray<TRttiProperty>;
var
  LType: TRttiType;
  I: Integer;
  AllProps: TArray<TRttiProperty>;
  ResultList: TList<TRttiProperty>;
  Prop: TRttiProperty;
begin
  LType := TableDataLink.RttiContext.GetType(ATypeInfo);
  AllProps := LType.GetProperties();
  ResultList := TList<TRttiProperty>.Create;
  for Prop in AllProps do
  begin
    if Prop.PropertyType.TypeKind in
     [
      tkInteger,
      tkChar,
      tkEnumeration,
      tkFloat,
      tkString,
      tkSet,
      tkClass,
      
      tkWChar,
      tkLString,
      tkWString,
      tkVariant,
      tkArray,
      tkRecord,
      
      tkInt64,
      tkDynArray,
      tkUString,
      tkClassRef
      
      
      
     ]
    then
      ResultList.Add(Prop);
  end;
  SetLength(Result, ResultList.Count);
  for i := 0 to ResultList.Count - 1 do
    Result[i] := ResultList[i];

  ResultList.Free;
end;

procedure TListFieldLinkListEh.FillList(APropInfoArr: TArray<TListTableLinkPropInfoEh>);

  function GetRttiProp(PropArr: TArray<TRttiProperty>; SubPropName: String): TRttiProperty;
  var
    Prop: TRttiProperty;
  begin
    Result := nil;
    for Prop in PropArr do
    begin
      if SameText(Prop.Name, SubPropName) = True then
        Exit(Prop);
    end;
  end;

  function GetDeepProp(PropArr: TArray<TRttiProperty>; DeepPropNames: TStringDynArray): TArray<TRttiProperty>;
  var
    I: Integer;
    DeepPropList: TList<TRttiProperty>;
    SubPropName: String;
    RttiProp: TRttiProperty;    
  begin
    DeepPropList := TList<TRttiProperty>.Create;
    
    for I := 0 to Length(DeepPropNames) - 1 do
    begin
      SubPropName := DeepPropNames[I];
      RttiProp := GetRttiProp(PropArr, SubPropName);
      if RttiProp = nil then
        raise Exception.Create('TListFieldLinkListEh.FillList: Property "' + SubPropName + '" not found');
      
      DeepPropList.Add(RttiProp);

      PropArr := GetRttiPropListAsArray(RttiProp.PropertyType.Handle);
    end;

    Result := DeepPropList.ToArray;
    DeepPropList.Free;
  end;

var
  PropArr: TArray<TRttiProperty>;
  FinalPropList: TList<TListTableLinkDeepPropInfoEh>;
  Prop: TRttiProperty;
  AFieldLink: TTypedListFieldLinkEh;
  PropInfo: TListTableLinkPropInfoEh;
  DeepPropNames: TStringDynArray;
  DeepPropInfo: TListTableLinkDeepPropInfoEh;
begin
  PropArr := GetRttiPropListAsArray(TableDataLink.ItemTypeInfo);
  FinalPropList := TList<TListTableLinkDeepPropInfoEh>.Create();

  if Length(APropInfoArr) = 0 then
  begin
    for Prop in PropArr do
    begin
      SetLength(DeepPropInfo.Props, 1);
      DeepPropInfo.Props[0] := Prop;
      DeepPropInfo.DisplayCaption := '';
      FinalPropList.Add(DeepPropInfo);
    end;
  end else
  begin
    for PropInfo in APropInfoArr do
    begin
      for Prop in PropArr do
      begin
        DeepPropNames := SplitString(PropInfo.PropName, '.');
        if SameText(DeepPropNames[0], Prop.Name) = True then
        begin
          if Length(DeepPropNames) > 1 then
          begin
            DeepPropInfo.Props := GetDeepProp(PropArr, DeepPropNames);
          end else
          begin
            SetLength(DeepPropInfo.Props, 1);
            DeepPropInfo.Props[0] := Prop;
          end;  
          DeepPropInfo.DisplayCaption := PropInfo.DisplayCaption;
          FinalPropList.Add(DeepPropInfo);
          Break;
        end;
      end;
    end;
  end;

  for DeepPropInfo in FinalPropList do
  begin
    AFieldLink := TTypedListFieldLinkEh.Create(Self);
    AFieldLink.FFields := DeepPropInfo.Props;
    AFieldLink.FDisplayName := DeepPropInfo.DisplayCaption; 
    InternalAddField(AFieldLink);
  end;

  FinalPropList.Free;
end;

function TListFieldLinkListEh.GetFieldLink(Index: Integer): TTypedListFieldLinkEh;
begin
  Result := TTypedListFieldLinkEh(inherited Item[Index]);
end;

function TListFieldLinkListEh.GetTableDataLink: TListTableLinkEh;
begin
  Result := TListTableLinkEh(inherited TableDataLink);
end;

function TListFieldLinkListEh.IndexOf(AField: TRttiProperty): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if FieldLink[I].Fields[0] = AField then
    begin
      Result := I;
      Break;
    end;
  end;
end;

{ TTypedListItemLinkEh }

constructor TTypedListItemLinkEh.Create(ARowLinkList: TTableRowLinkListEh);
begin
  inherited Create(ARowLinkList);
end;

destructor TTypedListItemLinkEh.Destroy;
begin
  inherited Destroy;
end;

function TTypedListItemLinkEh.GetEditModified: Boolean;
begin
  Result := False;
end;

function TTypedListItemLinkEh.GetRowLinkList: TListRecLinkListEh;
begin
  Result := TListRecLinkListEh(inherited RowLinkList);
end;

function TTypedListItemLinkEh.GetValue(ValueIndex: Integer): TValue;
var
  FieldLink: TTypedListFieldLinkEh;
  RttiValue: TValue;
  I: Integer;
  ValuePointer: Pointer;
  ValueObject: TObject;
  ClassType: TClass;
  ValueTypeCompatible: Boolean;
begin
  FieldLink := RowLinkList.ListTableLink.Fields[ValueIndex];

  ValueObject := SourceObjectItem;
  if (ValueObject <> nil) then
  begin
    ClassType := RowLinkList.ListTableLink.ItemClassType;
    if (ClassType <> nil) and (ValueObject.InheritsFrom(ClassType) = True) then
      ValueTypeCompatible := True
    else
      ValueTypeCompatible := False;
  end else
  begin
    ValueTypeCompatible := True;
  end;

  RttiValue := TValue.Empty;

  if ValueTypeCompatible = True then
  begin
    ValuePointer := Pointer(SourceItem);
    for I := 0 to Length(FieldLink.Fields) - 1 do
    begin
      RttiValue := FieldLink.Fields[I].GetValue(ValuePointer);
      if I < Length(FieldLink.Fields) - 1 then
        
        ValuePointer := Pointer(RttiValue.AsObject);
    end;
  end;

  Result := RttiValue;
end;

procedure TTypedListItemLinkEh.InitNewRow(ARowLinkList: TTableRowLinkListEh; ARowPos: Integer);
begin
  inherited InitNewRow(ARowLinkList, ARowPos);
end;

function TTypedListItemLinkEh.GetEditState: TRowLinkEditStateEh;
begin
  Result := TRowLinkEditStateEh.Browse;
end;

function TTypedListItemLinkEh.GetSourceItem: Pointer;
begin
  Result := FSourceItem;
end;

function TTypedListItemLinkEh.GetSourceObjectItem: TObject;
begin
  if (RowLinkList <> nil) and
     (RowLinkList.ListTableLink <> nil) and
     (RowLinkList.ListTableLink.ListItemIsObject = True)
  then
    Result := TObject(FSourceItem)
  else
    Result := nil;
end;

{ TListRecLinkListEh }

constructor TListRecLinkListEh.Create(ATableDataLink: TBaseTableDataLinkEh);
begin
  inherited Create(ATableDataLink);
end;

destructor TListRecLinkListEh.Destroy;
begin
  inherited Destroy;
end;

function TListRecLinkListEh.InternalCreateRowLink: TTableRowLinkEh;
begin
  Result := TTypedListItemLinkEh.Create(Self);
end;

procedure TListRecLinkListEh.FetchListItem(ListItem: Pointer);
var
  ARowLink: TTypedListItemLinkEh;
begin
  ARowLink := TTypedListItemLinkEh(InternalCreateRowLink);
  ARowLink.InitNewRow(Self, -1);
  ARowLink.FSourceItem := ListItem;
  InternalAddRowLink(ARowLink);
end;

function TListRecLinkListEh.IndexOf(ASourceListItem: Pointer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if RowLink[I].SourceItem = ASourceListItem then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

function TListRecLinkListEh.GetRowLink(Index: Integer): TTypedListItemLinkEh;
begin
  Result := TTypedListItemLinkEh(inherited Item[Index]);
end;

function TListRecLinkListEh.GetListTableLink: TListTableLinkEh;
begin
  Result := TListTableLinkEh(inherited TableDataLink);
end;

{ TListTableLinkEh }

constructor TListTableLinkEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RttiContext := TRttiContext.Create;
end;

destructor TListTableLinkEh.Destroy;
begin
  FreeAndNil(FInternalList);
  inherited Destroy;
end;

procedure TListTableLinkEh.SetList(AList: TList; AItemTypeInfo: Pointer; APropNameList: array of String);
var
  APropInfoList: TList<TListTableLinkPropInfoEh>;
  s: String;
  PropInfo: TListTableLinkPropInfoEh;
begin
  APropInfoList := TList<TListTableLinkPropInfoEh>.Create;

  for s in APropNameList do
  begin
    PropInfo.PropName := s;
    PropInfo.DisplayCaption := '';
    APropInfoList.Add(PropInfo);
  end;

  SetList(AList, AItemTypeInfo, APropInfoList.ToArray);
  
  APropInfoList.Free;
end;

procedure TListTableLinkEh.SetList(AList: TList; AItemTypeInfo: Pointer; APropInfoList: TArray<TListTableLinkPropInfoEh>);
begin
  if FSourceList <> nil then
  begin
    Fields.Clear;
    Rows.Clear;
  end;

  FSourceList := AList;
  SetItemTypeInfo(AItemTypeInfo);
  if FSourceList <> nil then
  begin
    Fields.FillList(APropInfoList);
    FActive := True;
  end else
  begin
    FActive := False;
  end;
  ActiveChanged;
end;

procedure TListTableLinkEh.SetList(AList: TList; AItemTypeInfo: Pointer);
begin
  SetList(AList, AItemTypeInfo, TArray<TListTableLinkPropInfoEh>(nil));
end;

procedure TListTableLinkEh.SetList<T>(AArray: TArray<T>);
begin
  SetList<T>(AArray, TArray<TListTableLinkPropInfoEh>(nil));
end;

procedure TListTableLinkEh.SetList<T>(AArray: TArray<T>; APropNameList: array of String);
var
  APropInfoList: TList<TListTableLinkPropInfoEh>;
  s: String;
  PropInfo: TListTableLinkPropInfoEh;
begin
  APropInfoList := TList<TListTableLinkPropInfoEh>.Create;

  for s in APropNameList do
  begin
    PropInfo.PropName := s;
    PropInfo.DisplayCaption := '';
    APropInfoList.Add(PropInfo);
  end;

  SetList<T>(AArray, TArray<TListTableLinkPropInfoEh>(nil));

  APropInfoList.Free;
end;

procedure TListTableLinkEh.SetList<T>(AArray: TArray<T>; APropInfoList: TArray<TListTableLinkPropInfoEh>);
var
  I: Integer;
begin
  if FInternalList = nil  then
    FInternalList := TList.Create;

  FInternalList.Clear;
  for I := 0 to Length(AArray) - 1 do
    FInternalList.Add(Pointer(AArray[I]));

  SetList(FInternalList, TypeInfo(T));
end;

procedure TListTableLinkEh.SetList<T>(AList: TList<T>);
begin
  SetList<T>(AList.ToArray());
end;

procedure TListTableLinkEh.SetList<T>(AList: TList<T>; APropNameList: array of String);
begin
  SetList<T>(AList.ToArray(), APropNameList);
end;

procedure TListTableLinkEh.SetList<T>(AList: TList<T>; APropInfoList: TArray<TListTableLinkPropInfoEh>);
begin
  SetList<T>(AList.ToArray(), APropInfoList);
end;

procedure TListTableLinkEh.UpdateActive;
begin
end;

procedure TListTableLinkEh.ActiveChanged;
begin
  if Active then
  begin
    FillRowLinkList;
    if Rows.Count > 0
      then FCurrentRowIndex := 0
      else FCurrentRowIndex := -1;
    SendChangeNotification(TTableLinkEventTypeEh.Reset, -1, -1, nil);
  end else
  begin
    ClearRowLinkList;
  end;
end;

procedure TListTableLinkEh.CancelCurrentRow;
begin
end;

function TListTableLinkEh.CheckUpdateFieldLinkList: Boolean;
begin
  Result := False;
end;

function TListTableLinkEh.CreateFieldLinkList: TTableFieldLinkListEh;
begin
  Result := TListFieldLinkListEh.Create(Self);
end;

function TListTableLinkEh.CreateRowLinkList: TTableRowLinkListEh;
begin
  Result := TListRecLinkListEh.Create(Self);
end;

procedure TListTableLinkEh.DeleteCurrentRow;
begin
  raise Exception.Create('TListTableLinkEh.DeleteCurrentRow is not supported');
end;

procedure TListTableLinkEh.EditCurrentRow;
begin
end;

procedure TListTableLinkEh.FillRowLinkList;
var
  I: Integer;
begin
  for I := 0 to SourceList.Count - 1 do
  begin
    Rows.FetchListItem(SourceList[I]);
  end;
end;

function TListTableLinkEh.GetActive: Boolean;
begin
  Result := True;
end;

function TListTableLinkEh.GetCanModify: Boolean;
begin
  Result := False;
end;

function TListTableLinkEh.GetCurrentRow: TTypedListItemLinkEh;
begin
  Result := TTypedListItemLinkEh(inherited CurrentRow);
end;

function TListTableLinkEh.GetFieldLinkList: TListFieldLinkListEh;
begin
  Result := TListFieldLinkListEh(inherited Fields);
end;

function TListTableLinkEh.GetRows: TListRecLinkListEh;
begin
  Result := TListRecLinkListEh(inherited Rows);
end;

function TListTableLinkEh.AppendNewRow: Integer;
begin
  raise Exception.Create('TListTableLinkEh.AppendNewRow is not supported');
end;

function TListTableLinkEh.InsertNewRow: Integer;
begin
  raise Exception.Create('TListTableLinkEh.InsertNewRow is not supported');
end;

procedure TListTableLinkEh.PostCurrentRow;
begin
end;

procedure TListTableLinkEh.RaiseInactiveError;
begin
  raise Exception.Create('Table is Inactive');
end;

procedure TListTableLinkEh.SetCurrentRowIndex(const Value: Integer);
var
  OldCurrentRowIndex: Integer;
begin
  CheckActive;
  if FCurrentRowIndex <> Value then
  begin
    CheckBrowseMode;
    OldCurrentRowIndex := FCurrentRowIndex;
    FCurrentRowIndex := Value;
    SendChangeNotification(TTableLinkEventTypeEh.CurrentPosChanged, FCurrentRowIndex, OldCurrentRowIndex, CurrentRow);
  end;
end;

procedure TListTableLinkEh.SetCurrentRowValue(AFieldValueIndex: Integer; const AValue: TValue);
var
  SourceItem: Pointer;
  FieldLink: TTypedListFieldLinkEh;
  Prop: TRttiProperty;
begin
  SourceItem := CurrentRow.SourceItem;
  FieldLink := Fields[AFieldValueIndex];
  Prop := FieldLink.Fields[0];
  Prop.SetValue(Pointer(SourceItem), AValue);
end;

procedure TListTableLinkEh.SetItemTypeInfo(AItemTypeInfo: Pointer);
begin
  FItemTypeInfo := AItemTypeInfo;
  FItemType := RttiContext.GetType(AItemTypeInfo);
end;

procedure TListTableLinkEh.UpdateCurrentRowIndex(IsSendNotification: Boolean);
begin
end;

function TListTableLinkEh.ListItemIsObject: Boolean;
begin
  if PTypeInfo(FItemTypeInfo).Kind = tkClass
    then Result := True
    else Result := False;
end;

function TListTableLinkEh.ItemClassType: TClass;
begin
  if FItemType is TRttiInstanceType
    then Result := TRttiInstanceType(FItemType).MetaclassType
    else Result := nil;
end;

{ TListTableLinkEh<T> }

constructor TListTableLinkEh<T>.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RttiContext := TRttiContext.Create;
end;

destructor TListTableLinkEh<T>.Destroy;
begin
  FreeAndNil(FArrayList);
  inherited Destroy;
end;

procedure TListTableLinkEh<T>.SetList(AList: TList<T>);
begin
  if FSourceList <> nil then
  begin
    Fields.Clear;
  end;
  FSourceList := AList;
  if FSourceList <> nil then
  begin
    Fields.FillList;
    FActive := True;
  end else
  begin
    FActive := False;
  end;
  ActiveChanged;
end;

procedure TListTableLinkEh<T>.SetList(AArray: TArray<T>);
var
  Item: T;
begin
  if FArrayList = nil then
    FArrayList := TList<T>.Create;

  FArrayList.Clear;
  for Item in AArray do
    FArrayList.Add(Item);

  SetList(FArrayList);
end;

procedure TListTableLinkEh<T>.UpdateActive;
begin
end;

procedure TListTableLinkEh<T>.ActiveChanged;
begin
  if Active then
  begin
    FillRowLinkList;
    if Rows.Count > 0
      then FCurrentRowIndex := 0
      else FCurrentRowIndex := -1;
    SendChangeNotification(TTableLinkEventTypeEh.Reset, -1, -1, nil);
  end else
  begin
    ClearRowLinkList;
  end;
end;

procedure TListTableLinkEh<T>.CancelCurrentRow;
begin
end;

function TListTableLinkEh<T>.CheckUpdateFieldLinkList: Boolean;
begin
  Result := False;
end;

function TListTableLinkEh<T>.CreateFieldLinkList: TTableFieldLinkListEh;
begin
  Result := TListFieldLinkListEh<T>.Create(Self);
end;

function TListTableLinkEh<T>.CreateRowLinkList: TTableRowLinkListEh;
begin
  Result := TListRecLinkListEh<T>.Create(Self);
end;

procedure TListTableLinkEh<T>.DeleteCurrentRow;
var
  ListItem: T;
begin
  if CurrentRowIndex >= 0 then
  begin
    ListItem := SourceList[CurrentRowIndex];
    SourceList.Delete(CurrentRowIndex);
    ListItem.Free;
  end;
end;

procedure TListTableLinkEh<T>.EditCurrentRow;
begin
end;

procedure TListTableLinkEh<T>.FillRowLinkList;
var
  I: Integer;
begin
  Rows.Clear();
  for I := 0 to SourceList.Count - 1 do
  begin
    Rows.FetchListItem(SourceList[I]);
  end;
end;

function TListTableLinkEh<T>.GetActive: Boolean;
begin
  Result := True;
end;

function TListTableLinkEh<T>.GetCanModify: Boolean;
begin
  Result := False;
end;

function TListTableLinkEh<T>.GetCurrentRow: TTypedListItemLinkEh<T>;
begin
  Result := TTypedListItemLinkEh<T>(inherited CurrentRow);
end;

function TListTableLinkEh<T>.GetFieldLinkList: TListFieldLinkListEh<T>;
begin
  Result := TListFieldLinkListEh<T>(inherited Fields);
end;

function TListTableLinkEh<T>.GetRows: TListRecLinkListEh<T>;
begin
  Result := TListRecLinkListEh<T>(inherited Rows);
end;

function TListTableLinkEh<T>.AppendNewRow: Integer;
var
  ListItem: T;
begin
  ListItem := T.Create;
  SourceList.Add(ListItem);
  Result := SourceList.Count - 1;
end;

function TListTableLinkEh<T>.InsertNewRow: Integer;
var
  ListItem: T;
begin
  ListItem := T.Create;
  SourceList.Insert(CurrentRowIndex, ListItem);
  Result := CurrentRowIndex;
end;

procedure TListTableLinkEh<T>.PostCurrentRow;
begin
end;

procedure TListTableLinkEh<T>.RaiseInactiveError;
begin
  raise Exception.Create('Table is Inactive');
end;

procedure TListTableLinkEh<T>.SetCurrentRowIndex(const Value: Integer);
var
  OldCurrentRowIndex: Integer;
begin
  CheckActive;
  if FCurrentRowIndex <> Value then
  begin
    CheckBrowseMode;
    OldCurrentRowIndex := FCurrentRowIndex;
    FCurrentRowIndex := Value;
    SendChangeNotification(TTableLinkEventTypeEh.CurrentPosChanged, FCurrentRowIndex, OldCurrentRowIndex, CurrentRow);
  end;
end;

procedure TListTableLinkEh<T>.SetCurrentRowValue(AFieldValueIndex: Integer; const AValue: TValue);
var
  SourceItem: T;
  FieldLink: TTypedListFieldLinkEh;
begin
  SourceItem := CurrentRow.SourceItem;
  FieldLink := Fields[AFieldValueIndex];
  FieldLink.Fields[0].SetValue(Pointer(SourceItem), AValue);
end;

procedure TListTableLinkEh<T>.UpdateCurrentRowIndex(IsSendNotification: Boolean);
begin
end;

function TListTableLinkEh<T>.ListItemIsObject: Boolean;
begin
  if PTypeInfo(TypeInfo(T)).Kind = tkClass
    then Result := True
    else Result := False;
end;

{ TListFieldLinkListEh<T> }

constructor TListFieldLinkListEh<T>.Create(ATableDataLink: TBaseTableDataLinkEh);
begin
  inherited Create(ATableDataLink);
end;

destructor TListFieldLinkListEh<T>.Destroy;
begin

  inherited Destroy;
end;

procedure TListFieldLinkListEh<T>.Clear;
begin
  inherited Clear;
end;

function TListFieldLinkListEh<T>.GetRttiPropListAsArray(ATypeInfo: Pointer): TArray<TRttiProperty>;
var
  LType: TRttiType;
  I: Integer;
  AllProps: TArray<TRttiProperty>;
  ResultList: TList<TRttiProperty>;
  Prop: TRttiProperty;
begin
  LType := TableDataLink.RttiContext.GetType(ATypeInfo);
  AllProps := LType.GetProperties();
  ResultList := TList<TRttiProperty>.Create;
  for Prop in AllProps do
  begin
    if Prop.PropertyType.TypeKind in
     [
      tkInteger,
      tkChar,
      tkEnumeration,
      tkFloat,
      tkString,
      tkSet,
      tkClass,
      
      tkWChar,
      tkLString,
      tkWString,
      tkVariant,
      tkArray,
      tkRecord,
      
      tkInt64,
      tkDynArray,
      tkUString,
      tkClassRef
      
      
      
     ]
    then
      ResultList.Add(Prop);
  end;
  SetLength(Result, ResultList.Count);
  for i := 0 to ResultList.Count - 1 do
    Result[i] := ResultList[i];

  ResultList.Free;
end;

procedure TListFieldLinkListEh<T>.FillList;
var
  PropList: TArray<TRttiProperty>;
  Prop: TRttiProperty;
  AFieldLink: TTypedListFieldLinkEh;
begin
  PropList := GetRttiPropListAsArray(TypeInfo(T));

  for Prop in PropList do
  begin
    AFieldLink:= TTypedListFieldLinkEh.Create(Self);
    SetLength(AFieldLink.FFields, 1);
    AFieldLink.FFields[0] := Prop;
    InternalAddField(AFieldLink);
  end;
end;

function TListFieldLinkListEh<T>.GetFieldLink(Index: Integer): TTypedListFieldLinkEh;
begin
  Result := TTypedListFieldLinkEh(inherited Item[Index]);
end;

function TListFieldLinkListEh<T>.GetTableDataLink: TListTableLinkEh<T>;
begin
  Result := TListTableLinkEh<T>(inherited TableDataLink);
end;

function TListFieldLinkListEh<T>.IndexOf(AField: TRttiProperty): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if FieldLink[I].Fields[0] = AField then
    begin
      Result := I;
      Break;
    end;
  end;
end;

{ TTypedListItemLinkEh<T> }

constructor TTypedListItemLinkEh<T>.Create(ARowLinkList: TTableRowLinkListEh);
begin
  inherited Create(ARowLinkList);
end;

destructor TTypedListItemLinkEh<T>.Destroy;
begin
  inherited Destroy;
end;

function TTypedListItemLinkEh<T>.GetEditModified: Boolean;
begin
  Result := False;
end;

function TTypedListItemLinkEh<T>.GetRowLinkList: TListRecLinkListEh<T>;
begin
  Result := TListRecLinkListEh<T>(inherited RowLinkList);
end;

function TTypedListItemLinkEh<T>.GetValue(ValueIndex: Integer): TValue;
var
  FieldLink: TTypedListFieldLinkEh;
  RttiValue: TValue;
begin
  FieldLink := RowLinkList.ListTableLink.Fields[ValueIndex];
  RttiValue := FieldLink.Fields[0].GetValue(Pointer(SourceItem));
  Result := RttiValue;
end;

procedure TTypedListItemLinkEh<T>.InitNewRow(ARowLinkList: TTableRowLinkListEh; ARowPos: Integer);
begin
  inherited InitNewRow(ARowLinkList, ARowPos);
end;

function TTypedListItemLinkEh<T>.GetEditState: TRowLinkEditStateEh;
begin
  Result := TRowLinkEditStateEh.Browse;
end;

function TTypedListItemLinkEh<T>.GetSourceItem: Pointer;
begin
  Result := Pointer(FSourceItem);
end;

function TTypedListItemLinkEh<T>.GetSourceObjectItem: TObject;
begin
  if (RowLinkList <> nil) and
     (RowLinkList.ListTableLink <> nil) and
     (RowLinkList.ListTableLink.ListItemIsObject = True)
  then
    Result := TObject(FSourceItem)
  else
    Result := nil;
end;

{ TListRecLinkListEh<T> }

constructor TListRecLinkListEh<T>.Create(ATableDataLink: TBaseTableDataLinkEh);
begin
  inherited Create(ATableDataLink);
end;

destructor TListRecLinkListEh<T>.Destroy;
begin
  inherited Destroy;
end;

function TListRecLinkListEh<T>.InternalCreateRowLink: TTableRowLinkEh;
begin
  Result := TTypedListItemLinkEh<T>.Create(Self);
end;

procedure TListRecLinkListEh<T>.FetchListItem(ListItem: T);
var
  ARowLink: TTypedListItemLinkEh<T>;
begin
  ARowLink := TTypedListItemLinkEh<T>(InternalCreateRowLink);
  ARowLink.InitNewRow(Self, -1);
  ARowLink.FSourceItem := ListItem;
  InternalAddRowLink(ARowLink);
end;

function TListRecLinkListEh<T>.IndexOf(ASourceListItem: T): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if RowLink[I].SourceItem = ASourceListItem then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

function TListRecLinkListEh<T>.GetRowLink(Index: Integer): TTypedListItemLinkEh<T>;
begin
  Result := TTypedListItemLinkEh<T>(inherited Item[Index]);
end;

function TListRecLinkListEh<T>.GetListTableLink: TListTableLinkEh<T>;
begin
  Result := TListTableLinkEh<T>(inherited TableDataLink);
end;

{ TTypedObjectListItemLinkEh }

constructor TTypedObjectListItemLinkEh.Create(ARowLinkList: TTableRowLinkListEh);
begin
  inherited Create(ARowLinkList);
end;

destructor TTypedObjectListItemLinkEh.Destroy;
begin
  inherited Destroy;
end;

function TTypedObjectListItemLinkEh.GetRowLinkList: TObjectListRecLinkListEh;
begin
  Result := TObjectListRecLinkListEh(inherited RowLinkList);
end;

function TTypedObjectListItemLinkEh.GetSourceItem: TObject;
begin
  Result := TObject(inherited SourceItem);
end;

function TTypedObjectListItemLinkEh.GetValue(ValueIndex: Integer): TValue;
var
  FieldLink: TTypedListFieldLinkEh;
  RttiValue: TValue;
  I: Integer;
  ValueObject: TObject;
  ItemTypeClass: TClass;
begin
  FieldLink := RowLinkList.ListTableLink.Fields[ValueIndex];

  ValueObject := SourceItem;
  RttiValue := TValue.Empty;

  ItemTypeClass := RowLinkList.ListTableLink.FItemType.MetaclassType;

  if ValueObject.InheritsFrom(ItemTypeClass) = True then
  begin
    for I := 0 to Length(FieldLink.Fields) - 1 do
    begin
      RttiValue := FieldLink.Fields[I].GetValue(ValueObject);
      if I < Length(FieldLink.Fields) - 1 then
        
        ValueObject := RttiValue.AsObject;
    end;
  end;

  Result := RttiValue;
end;

procedure TTypedObjectListItemLinkEh.InitNewRow(ARowLinkList: TTableRowLinkListEh; ARowPos: Integer);
begin
  inherited InitNewRow(ARowLinkList, ARowPos);
end;

{ TObjectListRecLinkListEh }

constructor TObjectListRecLinkListEh.Create(ATableDataLink: TBaseTableDataLinkEh);
begin
  inherited Create(ATableDataLink);
end;

destructor TObjectListRecLinkListEh.Destroy;
begin
  inherited Destroy;
end;

function TObjectListRecLinkListEh.GetListTableLink: TObjectListTableLinkEh;
begin
  Result := TObjectListTableLinkEh(inherited TableDataLink);
end;

function TObjectListRecLinkListEh.GetRowLink(Index: Integer): TTypedObjectListItemLinkEh;
begin
  Result := TTypedObjectListItemLinkEh(inherited RowLink[Index]);
end;

function TObjectListRecLinkListEh.IndexOf(ASourceListItem: TObject): Integer;
begin
  Result := inherited IndexOf(ASourceListItem);
end;

function TObjectListRecLinkListEh.InternalCreateRowLink: TTableRowLinkEh;
begin
  Result := TTypedObjectListItemLinkEh.Create(Self);
end;

{ TObjectListTableLinkEh }

constructor TObjectListTableLinkEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TObjectListTableLinkEh.Destroy;
begin
  inherited Destroy;
end;

function TObjectListTableLinkEh.CreateRowLinkList: TTableRowLinkListEh;
begin
  Result := TObjectListRecLinkListEh.Create(Self);
end;

function TObjectListTableLinkEh.GetRows: TObjectListRecLinkListEh;
begin
  Result := TObjectListRecLinkListEh(inherited Rows);
end;

procedure TObjectListTableLinkEh.SetItemTypeInfo(AItemTypeInfo: Pointer);
var
  LType: TRttiType;
begin
  inherited SetItemTypeInfo(AItemTypeInfo);
  LType := RttiContext.GetType(AItemTypeInfo);
  if LType.IsInstance = False then
    raise Exception.Create('TObjectListTableLinkEh supports only Instance types of ItemTypeInfo');
  FItemType := LType.AsInstance;
end;

{$ENDIF} 

initialization
end.
