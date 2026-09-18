{*******************************************************}
{                                                       }
{                      EhLib 12.1                       }
{                   EhLib.TableLinks                    }
{                                                       }
{     Copyright (c) 2024-2025 by Dmitry V. Bolshakov    }
{                                                       }
{*******************************************************}

unit EhLib.TableLinks;

{$I ..\Incl\EhLib.Inc}
{$SCOPEDENUMS ON}

interface

uses
  SysUtils, Classes, TypInfo,
  Rtti, Generics.Collections,
  Variants, DBUtilsEh, EhLibUtils;

type
  TBaseTableDataLinkEh = class;

  TTableRowLinkEh = class;
  TTableRowLinkListEh = class;

  TTableFieldLinkEh = class;
  TTableFieldLinkListEh = class;

  TTableLinkEventTypeEh =
    (Reset,
     RowAdded, RowDeleted, RowMoved, RowChanged, RowStateChanged,
     FieldAdded, FieldDeleted, FieldChanged,
     CurrentPosChanged, WritePendingData
    );

  TRowLinkEditStateEh = (Browse, Insert, Edit);

  TTableDataChangedEventEh = procedure (AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowLink: TTableRowLinkEh) of object;

{ TTableFieldLinkListEh }

  TTableFieldLinkListEh = class(TEnumerable<TTableFieldLinkEh>)
  private
    FList: TList<TTableFieldLinkEh>;
    FTableDataLink: TBaseTableDataLinkEh;

    function GetCount: Integer;
    function GetFieldLink(Index: Integer): TTableFieldLinkEh;
  protected
    procedure InternalAddField(FieldLink: TTableFieldLinkEh);
    procedure Clear;
    procedure FillList; virtual;
    function DoGetEnumerator: TEnumerator<TTableFieldLinkEh>; override;

  public
    constructor Create(ATableDataLink: TBaseTableDataLinkEh);
    destructor Destroy; override;

    function IndexOf(AFieldLink: TTableFieldLinkEh): Integer; overload;
    function IndexOf(AFieldLinkName: String): Integer; overload;
    function FindField(AFieldLinkName: String): TTableFieldLinkEh;
    function GetEnumerator: TEnumerator<TTableFieldLinkEh>;

    procedure GetFieldLinkList(AFieldLinkNames: String; AFieldLinkList: TList<TTableFieldLinkEh>);
    procedure GetFieldLinkNames(AFieldLinkNames: TStrings);

    property Item[Index: Integer]: TTableFieldLinkEh read GetFieldLink; default;
    property Count: Integer read GetCount;
    property TableDataLink: TBaseTableDataLinkEh read FTableDataLink;
  end;

{ TTableFieldLinkEh }

  TTableFieldLinkEh = class(TComponent)
  private
    FFieldLinkList: TTableFieldLinkListEh;

    function GetIndex: Integer;
  protected
    function GetCanModify: Boolean; virtual;
    function GetFieldName: String; virtual;
    function GetDisplayName: String; virtual;
    function GetDisplayFormat: String; virtual;

    function GetDataTypeInfo: PTypeInfo; virtual;
    function GetDataVarSubtype: TVarType; virtual;

  public
    constructor Create(AFieldLinkList: TTableFieldLinkListEh); reintroduce;
    destructor Destroy; override;

    property FieldName: String read GetFieldName;
    property DisplayName: String read GetDisplayName;
    property Index: Integer read GetIndex;
    property CanModify: Boolean read GetCanModify;
    property DisplayFormat: String read GetDisplayFormat;

    property DataTypeInfo: PTypeInfo read GetDataTypeInfo;
    property DataVarSubtype: TVarType read GetDataVarSubtype;
  end;

{ TTableRowLinkListEh }

  TTableRowLinkListEh = class(TPersistent)
  private
    FList: TList<TTableRowLinkEh>;
    FTableDataLink: TBaseTableDataLinkEh;

    function GetCount: Integer;
    function GetRowLink(Index: Integer): TTableRowLinkEh;
  protected
    procedure Clear;
    function InternalNewEditRowLink(ARowPos: Integer): Integer;
    function InternalDelete(ARowIndex: Integer): TTableRowLinkEh;

    function InternalCreateRowLink: TTableRowLinkEh; virtual;
    function InternalAddRowLink(ARowLink: TTableRowLinkEh): Integer;

  public
    constructor Create(ATableDataLink: TBaseTableDataLinkEh);
    destructor Destroy; override;

    function IndexOf(ARowLink: TTableRowLinkEh): Integer; overload;
    function GetEnumerator: TEnumerator<TTableRowLinkEh>;

    property Item[Index: Integer]: TTableRowLinkEh read GetRowLink; default;
    property Count: Integer read GetCount;
    property TableDataLink: TBaseTableDataLinkEh read FTableDataLink;
  end;

{ TTableRowLinkEh }

  TTableRowLinkEh = class(TComponent, IDataContextEh)
  private
    FRowLinkList: TTableRowLinkListEh;

    function GetEditing: Boolean;
    procedure SetValue(ValueIndex: Integer; const Value: TValue);
    function GetFieldLinkValue(FieldLink: TTableFieldLinkEh): TValue;
    procedure SetFieldLinkValue(FieldLink: TTableFieldLinkEh; const Value: TValue);
  protected
    function GetEditModified: Boolean; virtual;
    function GetEditState: TRowLinkEditStateEh; virtual;

    function GetValue(ValueIndex: Integer): TValue; virtual;
    function GetSourceItem: Pointer; virtual;
    function GetSourceObjectItem: TObject; virtual;

    procedure InitNewRow(ARowLinkList: TTableRowLinkListEh; ARowPos: Integer); virtual;

    { IDataContextEh }
    function GetFieldValue(AFieldName: String): TValue; overload;
    function GetComponent: TComponent;

  public
    constructor Create(ARowLinkList: TTableRowLinkListEh); reintroduce;
    destructor Destroy; override;

    property RowLinkList: TTableRowLinkListEh read FRowLinkList;
    property Value[ValueIndex: Integer]: TValue read GetValue write SetValue; default;
    property FieldValue[FieldLink: TTableFieldLinkEh]: TValue read GetFieldLinkValue write SetFieldLinkValue; 
    property EditState: TRowLinkEditStateEh read GetEditState;
    property Editing: Boolean read GetEditing;
    property EditModified: Boolean read GetEditModified;
    property SourceItem: Pointer read GetSourceItem;
    property SourceObjectItem: TObject read GetSourceObjectItem;
  end;

{ TChangeClientDataEh }

  TChangeClientDataEh = record
    Component: TComponent;
    EventHandler: TTableDataChangedEventEh;
  end;

{ TBaseTableDataLinkEh }

  TBaseTableDataLinkEh = class(TComponent)
  private
    FFieldLinkList: TTableFieldLinkListEh;
    FRowLinkList: TTableRowLinkListEh;
    FChangeClients: TList<TChangeClientDataEh>;
    FLockTableDataLinkChanges: Integer;
    FHasPendingData: Boolean;

    procedure ClearFieldLinks;
    procedure RowLinkListList;
    function GetCurrentRow: TTableRowLinkEh;
  protected
    FCurrentRowIndex: Integer;

  protected
    procedure UpdateAll;

    function GetCanModify: Boolean; virtual;
    function GetActive: Boolean; virtual;
    function CreateFieldLinkList: TTableFieldLinkListEh; virtual;
    function CreateRowLinkList: TTableRowLinkListEh; virtual;

    procedure FillRowLinkList; virtual;
    procedure FillFieldLinkList;
    procedure ClearRowLinkList;

    procedure CheckActive; virtual;
    procedure RaiseInactiveError; virtual;

    procedure UpdateCurrentRowIndex(IsSendNotification: Boolean); virtual;
    procedure SetCurrentRowIndex(const Value: Integer); virtual;
    procedure SetCurrentRowValue(AValueIndex: Integer; const AValue: TValue); virtual;

    procedure LockTableDataLinkChanges;
    procedure UnlockTableDataLinkChanges;
    function IsTableDataLinkChangesLocked: Boolean;

    function CheckUpdateFieldLinkList: Boolean; virtual;
    procedure ClearAll;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SendChangeNotification(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowLink: TTableRowLinkEh);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure RemoveChangeNotification(Client: TComponent);
    procedure AddChangeNotification(Client: TComponent; EventHandler: TTableDataChangedEventEh); overload;

    function AppendNewRow(): Integer; virtual;
    function InsertNewRow(): Integer; virtual;

    procedure EditCurrentRow(); virtual;
    procedure CancelCurrentRow(); virtual;
    procedure PostCurrentRow(); virtual;
    procedure DeleteCurrentRow(); virtual;
    procedure MarkPendingData;
    procedure ResetPendingData;

    procedure CheckBrowseMode;
    procedure CheckWritePendingData();

    procedure MoveRowPosBy(Distance: Integer);

    property Fields: TTableFieldLinkListEh read FFieldLinkList;
    property Rows: TTableRowLinkListEh read FRowLinkList;
    property CurrentRowIndex: Integer read FCurrentRowIndex write SetCurrentRowIndex;
    property CurrentRow: TTableRowLinkEh read GetCurrentRow;
    property Active: Boolean read GetActive;
    property CanModify: Boolean read GetCanModify;
    property HasPendingData: Boolean read FHasPendingData;

  end;

  function CreateChangeClientDataEh(AComponent: TComponent; AEventHandler: TTableDataChangedEventEh): TChangeClientDataEh;

implementation

{ TTableFieldLinkEh }

constructor TTableFieldLinkEh.Create(AFieldLinkList: TTableFieldLinkListEh);
begin
  inherited Create(nil);
  FFieldLinkList := AFieldLinkList;
end;

destructor TTableFieldLinkEh.Destroy;
begin
  inherited Destroy;
end;

function TTableFieldLinkEh.GetCanModify: Boolean;
begin
  Result := True;
end;

function TTableFieldLinkEh.GetDataTypeInfo: PTypeInfo;
begin
  Result := nil;
end;

function TTableFieldLinkEh.GetDataVarSubtype: TVarType;
begin
  Result := varError;
end;

function TTableFieldLinkEh.GetDisplayFormat: String;
begin
  Result := '';
end;

function TTableFieldLinkEh.GetDisplayName: String;
begin
  Result := '';
end;

function TTableFieldLinkEh.GetFieldName: String;
begin
  Result := '';
end;

function TTableFieldLinkEh.GetIndex: Integer;
begin
  Result := FFieldLinkList.IndexOf(Self);
end;

{ TTableFieldLinkListEh }

constructor TTableFieldLinkListEh.Create(ATableDataLink: TBaseTableDataLinkEh);
begin
  inherited Create;
  FTableDataLink := ATableDataLink;
  FList := TList<TTableFieldLinkEh>.Create;
end;

destructor TTableFieldLinkListEh.Destroy;
begin
  Clear;
  FreeAndNil(FList);
  inherited Destroy;
end;

function TTableFieldLinkListEh.DoGetEnumerator: TEnumerator<TTableFieldLinkEh>;
begin
  Result := FList.GetEnumerator;
end;

procedure TTableFieldLinkListEh.InternalAddField(FieldLink: TTableFieldLinkEh);
begin
  FList.Add(FieldLink);
end;

procedure TTableFieldLinkListEh.Clear;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
  begin
    FList[I].Free;
    FList[I] := nil;
  end;
  FList.Clear;
end;

procedure TTableFieldLinkListEh.FillList;
begin
end;

function ExtractFieldName(const Fields: string; var Pos: Integer): string;
var
  I: Integer;
begin
  I := Pos;
  while (I <= Length(Fields)) and (Fields[I] <> ';') do Inc(I);
  Result := Trim(Copy(Fields, Pos, I - Pos));
  if (I <= Length(Fields)) and (Fields[I] = ';') then Inc(I);
  Pos := I;
end;

procedure TTableFieldLinkListEh.GetFieldLinkList(AFieldLinkNames: String; AFieldLinkList: TList<TTableFieldLinkEh>);
var
  Pos: Integer;
  Field: TTableFieldLinkEh;
begin
  Pos := 1;
  while Pos <= Length(AFieldLinkNames) do
  begin
    Field := FindField(ExtractFieldName(AFieldLinkNames, Pos));
    if Assigned(AFieldLinkList) then AFieldLinkList.Add(Field);
  end;
end;

procedure TTableFieldLinkListEh.GetFieldLinkNames(AFieldLinkNames: TStrings);
var
  Field: TTableFieldLinkEh;
begin
  AFieldLinkNames.BeginUpdate;
  for Field in FList do
    AFieldLinkNames.Add(Field.FieldName);
  AFieldLinkNames.EndUpdate;
end;


function TTableFieldLinkListEh.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TTableFieldLinkListEh.GetEnumerator: TEnumerator<TTableFieldLinkEh>;
begin
  Result := FList.GetEnumerator;
end;

function TTableFieldLinkListEh.GetFieldLink(Index: Integer): TTableFieldLinkEh;
begin
  Result := FList[Index];
end;

function TTableFieldLinkListEh.IndexOf(AFieldLink: TTableFieldLinkEh): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if Item[I] = AFieldLink then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TTableFieldLinkListEh.IndexOf(AFieldLinkName: String): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if Item[I].GetFieldName = AFieldLinkName then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TTableFieldLinkListEh.FindField(AFieldLinkName: String): TTableFieldLinkEh;
var
  Index: Integer;
begin
  Index := IndexOf(AFieldLinkName);
  if Index >= 0
    then Result := Item[Index]
    else Result := nil;
end;

{ TTableRowLinkEh }

constructor TTableRowLinkEh.Create(ARowLinkList: TTableRowLinkListEh);
begin
  inherited Create(nil);
  FRowLinkList := ARowLinkList;
end;

destructor TTableRowLinkEh.Destroy;
begin
  inherited Destroy;
end;

function TTableRowLinkEh.GetEditState: TRowLinkEditStateEh;
begin
  Result := TRowLinkEditStateEh.Browse;
end;

function TTableRowLinkEh.GetEditModified: Boolean;
begin
  raise Exception.Create('TTableRowLinkEh.GetEditModified is not implemented');
end;

function TTableRowLinkEh.GetValue(ValueIndex: Integer): TValue;
begin
  raise Exception.Create('TTableRowLinkEh.GetValue is not implemented');
end;

function TTableRowLinkEh.GetFieldLinkValue(FieldLink: TTableFieldLinkEh): TValue;
begin
  Result := Value[RowLinkList.TableDataLink.Fields.IndexOf(FieldLink)];
end;

procedure TTableRowLinkEh.SetFieldLinkValue(FieldLink: TTableFieldLinkEh; const Value: TValue);
begin
  SetValue(RowLinkList.TableDataLink.Fields.IndexOf(FieldLink), Value);
end;

procedure TTableRowLinkEh.SetValue(ValueIndex: Integer; const Value: TValue);
begin
  if RowLinkList.TableDataLink.CurrentRow <> Self then
    raise Exception.Create('TTableRowLinkEh.SetValue Can''t set value if RowLink is not Current');

  RowLinkList.TableDataLink.SetCurrentRowValue(ValueIndex, Value);
end;

function TTableRowLinkEh.GetEditing: Boolean;
begin
  Result := EditState in [TRowLinkEditStateEh.Insert, TRowLinkEditStateEh.Edit];
end;

procedure TTableRowLinkEh.InitNewRow(ARowLinkList: TTableRowLinkListEh; ARowPos: Integer);
begin
  FRowLinkList := ARowLinkList;
end;

function TTableRowLinkEh.GetFieldValue(AFieldName: String): TValue;
var
  FieldLink: TTableFieldLinkEh;
begin
  FieldLink := RowLinkList.TableDataLink.Fields.FindField(AFieldName);
  Result := FieldValue[FieldLink];
end;

function TTableRowLinkEh.GetComponent: TComponent;
begin
  Result := Self;
end;

function TTableRowLinkEh.GetSourceItem: Pointer;
begin
  Result := nil;
end;

function TTableRowLinkEh.GetSourceObjectItem: TObject;
begin
  Result := nil;
end;

{ TBaseTableDataLinkEh }

constructor TBaseTableDataLinkEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FFieldLinkList := CreateFieldLinkList;
  FRowLinkList := CreateRowLinkList;
  FChangeClients := TList<TChangeClientDataEh>.Create;
  FCurrentRowIndex := -1;
end;

destructor TBaseTableDataLinkEh.Destroy;
begin
  Destroying;
  FreeAndNil(FFieldLinkList);
  FreeAndNil(FRowLinkList);
  FreeAndNil(FChangeClients);
  inherited Destroy;
end;

function TBaseTableDataLinkEh.CreateFieldLinkList: TTableFieldLinkListEh;
begin
  Result := TTableFieldLinkListEh.Create(Self);
end;

function TBaseTableDataLinkEh.CreateRowLinkList: TTableRowLinkListEh;
begin
  Result := TTableRowLinkListEh.Create(Self);
end;

procedure TBaseTableDataLinkEh.AddChangeNotification(Client: TComponent; EventHandler: TTableDataChangedEventEh);
begin
  FChangeClients.Add(CreateChangeClientDataEh(Client, EventHandler));
end;

procedure TBaseTableDataLinkEh.RemoveChangeNotification(Client: TComponent);
var
  I: Integer;
begin
  if FChangeClients = nil then Exit;

  for I := FChangeClients.Count - 1 downto 0 do
  begin
    if Client = FChangeClients[I].Component then
    begin
      FChangeClients.Delete(I);
    end;
  end;
end;

procedure TBaseTableDataLinkEh.SendChangeNotification(
  AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowLink: TTableRowLinkEh);
var
  I: Integer;
  ClientData: TChangeClientDataEh;
begin
  if IsTableDataLinkChangesLocked = True then Exit;

  for I := 0 to FChangeClients.Count - 1 do
  begin
    ClientData := FChangeClients[I];
    ClientData.EventHandler(AChangedType, NewIndex, OldIndex, ARowLink);
  end;
end;

function TBaseTableDataLinkEh.GetActive: Boolean;
begin
  Result := False;
end;

function TBaseTableDataLinkEh.GetCanModify: Boolean;
begin
  Result := False;
end;

function TBaseTableDataLinkEh.GetCurrentRow: TTableRowLinkEh;
begin
  if (Rows.Count > 0) and
     (CurrentRowIndex >= 0) and
     (CurrentRowIndex < Rows.Count)
  then
    Result := Rows[CurrentRowIndex]
  else
    Result := nil;
end;

procedure TBaseTableDataLinkEh.CheckActive;
begin
  if Active = False then
    RaiseInactiveError;
end;

procedure TBaseTableDataLinkEh.RaiseInactiveError;
begin
  raise Exception.Create('TBaseTableDataLinkEh is Inactive');
end;

{$REGION 'Rows Navigation'}

function TBaseTableDataLinkEh.AppendNewRow: Integer;
begin
  raise Exception.Create('TBaseTableDataLinkEh.AppendNewRow not implemented');
end;

function TBaseTableDataLinkEh.InsertNewRow: Integer;
begin
  raise Exception.Create('TBaseTableDataLinkEh.InsertNewRow not implemented');
end;

procedure TBaseTableDataLinkEh.CheckBrowseMode;
begin
  CheckActive;
  if (CurrentRow <> nil) then
  begin
    CheckWritePendingData();
    if (CurrentRow.Editing = True) then
    begin
      if CurrentRow.EditModified then
        PostCurrentRow
      else
        CancelCurrentRow;
    end;
  end;
end;

procedure TBaseTableDataLinkEh.CheckWritePendingData();
begin
  if HasPendingData then
  begin
    SendChangeNotification(TTableLinkEventTypeEh.WritePendingData, CurrentRowIndex, -1, CurrentRow);
    FHasPendingData := False;
  end;
end;

procedure TBaseTableDataLinkEh.EditCurrentRow();
begin
end;

procedure TBaseTableDataLinkEh.CancelCurrentRow();
begin
  raise Exception.Create('TBaseTableDataLinkEh.CancelCurrentRow is not implemented');
end;

procedure TBaseTableDataLinkEh.PostCurrentRow();
begin
  raise Exception.Create('TBaseTableDataLinkEh.PostCurrentRow is not implemented');
end;

procedure TBaseTableDataLinkEh.DeleteCurrentRow;
begin
  raise Exception.Create('TBaseTableDataLinkEh.CancelCurrentRow is not implemented');
end;
{$ENDREGION 'Rows Navigation'}


procedure TBaseTableDataLinkEh.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
end;

procedure TBaseTableDataLinkEh.UpdateAll;
begin
  CheckUpdateFieldLinkList;
end;

function TBaseTableDataLinkEh.CheckUpdateFieldLinkList: Boolean;
begin
  raise Exception.Create('TBaseTableDataLinkEh.CheckUpdateFieldLinkList is not implemented');
end;

procedure TBaseTableDataLinkEh.FillFieldLinkList;
begin
  FFieldLinkList.FillList;
end;

procedure TBaseTableDataLinkEh.ClearAll;
begin
  RowLinkListList();
  ClearFieldLinks();
end;

procedure TBaseTableDataLinkEh.RowLinkListList();
begin
  FRowLinkList.Clear;
end;

procedure TBaseTableDataLinkEh.ClearFieldLinks();
begin
  Fields.Clear;
end;

procedure TBaseTableDataLinkEh.FillRowLinkList;
begin
end;

procedure TBaseTableDataLinkEh.ClearRowLinkList;
begin
  FRowLinkList.Clear;
  FCurrentRowIndex := -1;
  SendChangeNotification(TTableLinkEventTypeEh.Reset, -1, -1, nil);
end;

procedure TBaseTableDataLinkEh.UpdateCurrentRowIndex(IsSendNotification: Boolean);
begin
end;

procedure TBaseTableDataLinkEh.LockTableDataLinkChanges;
begin
  FLockTableDataLinkChanges := FLockTableDataLinkChanges + 1;
end;

procedure TBaseTableDataLinkEh.UnlockTableDataLinkChanges;
begin
  FLockTableDataLinkChanges := FLockTableDataLinkChanges - 1;
end;

function TBaseTableDataLinkEh.IsTableDataLinkChangesLocked: Boolean;
begin
  Result := (FLockTableDataLinkChanges > 0);
end;

procedure TBaseTableDataLinkEh.MoveRowPosBy(Distance: Integer);
var
  NewPos: Integer;
begin
  NewPos := CurrentRowIndex + Distance;
  if NewPos < 0 then NewPos := 0;
  if NewPos > Rows.Count - 1 then NewPos := Rows.Count - 1;
  CurrentRowIndex := NewPos;
end;

procedure TBaseTableDataLinkEh.SetCurrentRowIndex(const Value: Integer);
begin
  raise Exception.Create('TTableRowLinkEh.SetCurrentRowIndex is not implemented');
end;

procedure TBaseTableDataLinkEh.SetCurrentRowValue(AValueIndex: Integer; const AValue: TValue);
begin
  raise Exception.Create('TTableRowLinkEh.SetCurrentRowValue is not implemented');
end;

procedure TBaseTableDataLinkEh.MarkPendingData;
begin
  FHasPendingData := True;
end;

procedure TBaseTableDataLinkEh.ResetPendingData;
begin
  FHasPendingData := False;
end;

{ TTableRowLinkListEh }

constructor TTableRowLinkListEh.Create(ATableDataLink: TBaseTableDataLinkEh);
begin
  inherited Create;
  FTableDataLink := ATableDataLink;
  FList := TList<TTableRowLinkEh>.Create;
end;

destructor TTableRowLinkListEh.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TTableRowLinkListEh.Clear;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
  begin
    FList[I].Free;
    FList[I] := nil;
  end;

  FList.Clear;
end;

function TTableRowLinkListEh.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TTableRowLinkListEh.GetEnumerator: TEnumerator<TTableRowLinkEh>;
begin
  Result := FList.GetEnumerator();
end;

function TTableRowLinkListEh.GetRowLink(Index: Integer): TTableRowLinkEh;
begin
  Result := FList[Index];
end;

function TTableRowLinkListEh.IndexOf(ARowLink: TTableRowLinkEh): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if Item[I] = ARowLink then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

function TTableRowLinkListEh.InternalNewEditRowLink(ARowPos: Integer): Integer;
var
  ARowLink: TTableRowLinkEh;
begin
  ARowLink := InternalCreateRowLink;
  ARowLink.InitNewRow(Self, ARowPos);

  if (ARowPos >= 0) and (ARowPos < FList.Count) then
  begin
    FList.Insert(ARowPos, ARowLink);
    Result := ARowPos;
  end else
  begin
    FList.Add(ARowLink);
    Result := FList.Count - 1;
  end;
end;

function TTableRowLinkListEh.InternalDelete(ARowIndex: Integer): TTableRowLinkEh;
begin
  Result := Item[ARowIndex];
  FList.Delete(ARowIndex);
end;

function TTableRowLinkListEh.InternalCreateRowLink: TTableRowLinkEh;
begin
  Result := TTableRowLinkEh.Create(Self);
end;

function TTableRowLinkListEh.InternalAddRowLink(ARowLink: TTableRowLinkEh): Integer;
begin
  FList.Add(ARowLink);
  Result := FList.Count - 1;
end;

procedure InitUnit;
begin

end;

procedure FinalUnit;
begin
end;

{ TChangeClientDataEh }

function CreateChangeClientDataEh(AComponent: TComponent; AEventHandler: TTableDataChangedEventEh): TChangeClientDataEh;
begin
  Result.Component := AComponent;
  Result.EventHandler := AEventHandler;
end;

initialization
  InitUnit;
finalization
  FinalUnit;
end.
