{*******************************************************}
{                                                       }
{                      EhLib 12.1                       }
{                  EhLib.TableLink.Db                   }
{                                                       }
{     Copyright (c) 2024-2025 by Dmitry V. Bolshakov    }
{                                                       }
{*******************************************************}

unit EhLib.TableLink.Db;

{$I ..\Incl\EhLib.Inc}
{$SCOPEDENUMS ON}

interface

uses Classes, SysUtils,
  Variants, Contnrs,
  Generics.Collections, TypInfo, Rtti, Db,
  EhLib.TableLinks,
  DBUtilsEh, EhLibUtils;

type
  TDataSetTableLinkEh = class;
  TDataSetFieldLinkEh = class;
  TDataSetRecLinkEh = class;
  TDataSetRecLinkListEh = class;

{ TDataSetTableLinkDataLinkEh }

  TDataSetTableLinkDataLinkEh = class(TDataLink)
  private
    FTableLink: TDataSetTableLinkEh;
  protected
    procedure ActiveChanged; override;

    procedure DataEvent(Event: TDataEvent; Info: TDataEventInfoTypeEh); override;
    procedure DataSetChanged; override;
    procedure DataSetScrolled(Distance: Integer); override;
    procedure EditingChanged; override;
    procedure RecordChanged(Field: TField); override;

  public
    constructor Create(ATableLink: TDataSetTableLinkEh);
    destructor Destroy; override;

    property TableDataLink: TDataSetTableLinkEh read FTableLink;
  end;

{ TDataSetFieldLinkEh }

  TDataSetFieldLinkEh = class(TTableFieldLinkEh)
  private
  protected
    FField: TField;

    function GetFieldName: String; override;
    function GetDisplayName: String; override;
    function GetDisplayFormat: String; override;

    function GetDataTypeInfo: PTypeInfo; override;
    function GetDataVarSubtype: TVarType; override;

  public
    constructor Create(AFieldLinkList: TTableFieldLinkListEh);
    destructor Destroy; override;

    property Field: TField read FField;
  end;

{ TDataSetFieldLinkListEh }

  TDataSetFieldLinkListEh = class(TTableFieldLinkListEh)
  private
    function GetFieldLink(Index: Integer): TDataSetFieldLinkEh;
    function GetTableLink: TDataSetTableLinkEh;

  protected
    procedure FillList; override;

  public
    constructor Create(ATableLink: TBaseTableDataLinkEh);
    destructor Destroy; override;

    function IndexOf(AField: TField): Integer;

    property FieldLink[Index: Integer]: TDataSetFieldLinkEh read GetFieldLink; default;
    property TableDataLink: TDataSetTableLinkEh read GetTableLink;
  end;

  TRowLinkDataValuesEh = array of TValue;

{ TDataSetRecLinkEh }

  TDataSetRecLinkEh = class(TTableRowLinkEh)
  private
    FDataBookmark: TBookmark;
    function GetRowLinkList: TDataSetRecLinkListEh;
  protected
    FDataValues: TRowLinkDataValuesEh;

    function GetEditModified: Boolean; override;
    function GetEditState: TRowLinkEditStateEh; override;
    function GetValue(ValueIndex: Integer): TValue; override;
    function GetSourceItem: Pointer; override;
    function GetSourceObjectItem: TObject; override;

    procedure UpdateValuesFromDataSet(ADataSet: TDataSet; AField: TField);
    procedure InternalSetFieldValue(AFieldLinkIndex: Integer; AField: TField);
    procedure InternalSetDataValue(ValueIndex: Integer; const Value: TValue);

    procedure InitNewRow(ARowLinkList: TTableRowLinkListEh; ARowPos: Integer); override;

  public
    constructor Create(ARowLinkList: TTableRowLinkListEh);
    destructor Destroy; override;

    property RowLinkList: TDataSetRecLinkListEh read GetRowLinkList;
    property DataBookmark: TBookmark read FDataBookmark;

  end;

{ TDataSetRecLinkListEh }

  TDataSetRecLinkListEh = class(TTableRowLinkListEh)
  private
    function GetRowLink(Index: Integer): TDataSetRecLinkEh;
    function GetTableDataLink: TDataSetTableLinkEh;
  protected
    function InternalCreateRowLink: TTableRowLinkEh; override;
    procedure FetchDataSetRecord(ADataSet: TDataSet);

  public
    constructor Create(ATableDataLink: TBaseTableDataLinkEh);
    destructor Destroy; override;

    function IndexOf(ADataBookmark: TBookmark): Integer; overload;

    property RowLink[Index: Integer]: TDataSetRecLinkEh read GetRowLink; default;
    property TableDataLink: TDataSetTableLinkEh read GetTableDataLink;
  end;

{ TDataSetTableLinkEh }

  TDataSetTableLinkEh = class(TBaseTableDataLinkEh)
  private
    FDataLink: TDataSetTableLinkDataLinkEh;

    FLockDataSetChanges: Integer;
    FPostStarted: Boolean;
    FPostFinished: Boolean;
    FCancelStarted: Boolean;
    FCancelFinished: Boolean;
    FDeleteStarted: Boolean;
    FDeleteFinished: Boolean;

    function GetDataSet: TDataSet;
    function GetCurrentRow: TDataSetRecLinkEh;
    function GetFieldLinkList: TDataSetFieldLinkListEh;
    function GetRows: TDataSetRecLinkListEh;
    function GetDataSource: TComponent;

    procedure CheckPostSynchronization;
    procedure CheckPostBookmarkDuplication;

  protected
    FDataSource: TComponent;

    function GetCanModify: Boolean; override;
    function GetActive: Boolean; override;
    function CheckUpdateFieldLinkList: Boolean; override;
    function CreateFieldLinkList: TTableFieldLinkListEh; override;
    function CreateRowLinkList: TTableRowLinkListEh; override;
    function PreconvertValueToSet(AFieldValueIndex: Integer; const AValue: TValue): TValue; virtual;

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure RaiseInactiveError; override;
    procedure SetDataSource(const Value: TComponent);
    procedure FillRowLinkList; override;
    procedure UpdateCurrentRowIndex(IsSendNotification: Boolean); override;
    procedure SetCurrentRowIndex(const Value: Integer); override;
    procedure SetCurrentRowValue(AFieldValueIndex: Integer; const AValue: TValue); override;

    procedure DataLinkActiveChanged; virtual;
    procedure DataLinkDataSetChanged; virtual;
    procedure DataLinkDataSetScrolled; virtual;
    procedure DataLinkEditingChanged; virtual;
    procedure DataLinkRecordChanged(AField: TField); virtual;
    procedure UpdateFieldLinkList;

    procedure LockDataSetChanges;
    procedure UnlockDataSetChanges;
    function DataSetChangesIsLocked: Boolean;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property DataLink: TDataSetTableLinkDataLinkEh read FDataLink;
    property DataSet: TDataSet read GetDataSet;

    function AppendNewRow(): Integer; override;
    function InsertNewRow(): Integer; override;
    procedure EditCurrentRow(); override;
    procedure CancelCurrentRow(); override;
    procedure PostCurrentRow(); override;
    procedure DeleteCurrentRow(); override;

    property Fields: TDataSetFieldLinkListEh read GetFieldLinkList;
    property Rows: TDataSetRecLinkListEh read GetRows;
    property CurrentRow: TDataSetRecLinkEh read GetCurrentRow;
    property DataSource: TComponent read GetDataSource write SetDataSource;
  end;

{ TDefaultTableDataLinkListEh }

  TDefaultTableDataLinkListEh = class(TComponent)
  private
    FSetToSourceDic: TDictionary<TDataSource, TDataSetTableLinkEh>;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function GetTableDataLinkForDataSource(ADataSource: TDataSource): TDataSetTableLinkEh;
  end;

function FiledDataTypeToVarType(AFieldType: TFieldType): TVarType;
function GetDefaultTableDataLinkForDataSource(ADataSource: TDataSource): TBaseTableDataLinkEh;

implementation

uses
{$IFDEF FPC}
  DbConst,
{$ELSE}
  DbConsts, SqlTimSt,
{$ENDIF}
  FmtBcd,
  DefaultDataSourcesEh;

var
  DefaultTableDataLinkList: TDefaultTableDataLinkListEh;

function FiledDataTypeToVarType(AFieldType: TFieldType): TVarType;
var
  AVarArray: Variant;
begin
  case AFieldType of
    ftUnknown: Result := varError;
    ftString: Result := varString;
    ftSmallint: Result := varSmallint;
    ftInteger: Result := varInteger;
    ftWord: Result := varInteger;
    ftBoolean: Result := varBoolean;
    ftFloat: Result := varDouble;
    ftCurrency: Result := varCurrency;
    ftBCD: Result := varCurrency;
    ftDate: Result := varDate;
    ftTime: Result := varDate;
    ftDateTime: Result := varDate;
    ftBytes: Result := varArray;
    ftVarBytes: Result := varArray;
    ftAutoInc: Result := varInteger;
{$IFDEF EH_LIB_12}
    ftBlob: Result := varArray;
    ftMemo: Result := varString;
    ftGraphic: Result := varArray;
    ftFmtMemo: Result := varString;
    ftParadoxOle: Result := varArray;
    ftDBaseOle: Result := varArray;
    ftTypedBinary: Result := varArray;
{$ELSE}
    ftBlob: Result := varString;
    ftMemo: Result := varString;
    ftGraphic: Result := varString;
    ftFmtMemo: Result := varString;
    ftParadoxOle: Result := varString;
    ftDBaseOle: Result := varString;
    ftTypedBinary: Result := varString;
{$ENDIF}
    ftCursor: Result := varError;
    ftFixedChar: Result := varString;
    ftWideString: Result := varUString; 
    ftLargeint: Result := varInt64;
    ftADT: Result := varError;
    ftArray: Result := varError;
    ftReference: Result := varError;
    ftDataSet: Result := varError;
{$IFDEF EH_LIB_12}
    ftOraBlob: Result := varArray;
{$ELSE}
    ftOraBlob: Result := varString;
{$ENDIF}
    ftOraClob: Result := varString;
    ftVariant: Result := varVariant;
    ftInterface: Result := varUnknown;
    ftIDispatch: Result := varDispatch;
    ftGuid: Result := varString;
    {$IFDEF FPC}
    ftTimeStamp: Result := varString;
    {$ELSE}
    ftTimeStamp: Result := VarSQLTimeStamp;
    {$ENDIF}

    ftFMTBcd: Result := varFMTBcd;
    ftFixedWideChar: Result := varOleStr;
    ftWideMemo: Result := varOleStr;
{$IFDEF EH_LIB_10}
    ftOraTimeStamp: Result := VarSQLTimeStamp;
    ftOraInterval: Result := varString;
{$ENDIF}
{$IFDEF EH_LIB_12}
    ftLongWord: Result := varLongWord;
    ftShortint: Result := varShortInt;
    ftByte: Result := varByte;
    ftExtended: Result := varDouble;
    ftConnection: Result := varError;
    ftParams: Result := varError;
    ftStream: Result := varError;
{$ENDIF}
{$IFDEF EH_LIB_13}
    ftTimeStampOffset: Result := VarSQLTimeStampOffset;
    ftSingle: Result := varSingle;
{$ENDIF}
  else
    Result := varEmpty;
  end;
{$IFDEF EH_LIB_12}
  if AFieldType in [ftBytes, ftVarBytes, ftBlob, ftGraphic, ftParadoxOle,
      ftDBaseOle, ftTypedBinary, ftOraBlob] then
{$ELSE}
  if AFieldType in [ftBytes, ftVarBytes] then
{$ENDIF}
  begin
    AVarArray := VarArrayCreate([0, 1], varByte);
    Result := VarType(AVarArray);
  end;
end;

function GetDefaultTableDataLinkForDataSource(ADataSource: TDataSource): TBaseTableDataLinkEh;
begin
  if DefaultTableDataLinkList = nil then
  begin
    DefaultTableDataLinkList := TDefaultTableDataLinkListEh.Create(nil);
  end;

  Result := DefaultTableDataLinkList.GetTableDataLinkForDataSource(ADataSource);
end;

function GetFieldDisplayFormat(AField: TField): String;
begin
  if (AField is TNumericField) then
    Result := TNumericField(AField).DisplayFormat
  else if (AField is TDateTimeField) then
    Result := TDateTimeField(AField).DisplayFormat
{$IFDEF FPC}
{$ELSE}
  else if (AField is TSQLTImeStampField) then
    Result := TSQLTImeStampField(AField).DisplayFormat
{$ENDIF}
  else
    Result := '';
end;

{ TDefaultTableDataLinkListEh }

constructor TDefaultTableDataLinkListEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSetToSourceDic := TDictionary<TDataSource, TDataSetTableLinkEh>.Create;
end;

destructor TDefaultTableDataLinkListEh.Destroy;
var
  SetSourcePair: TPair<TDataSource, TDataSetTableLinkEh>;
begin
  for SetSourcePair in FSetToSourceDic do
  begin
    SetSourcePair.Value.Free;
  end;
  FreeAndNil(FSetToSourceDic);
  inherited Destroy;
end;

function TDefaultTableDataLinkListEh.GetTableDataLinkForDataSource(ADataSource: TDataSource): TDataSetTableLinkEh;
begin
  if FSetToSourceDic.TryGetValue(ADataSource, Result) = False then
  begin
    Result := TDataSetTableLinkEh.Create(nil);
    Result.DataSource := ADataSource;
    FSetToSourceDic.Add(ADataSource, Result);
    ADataSource.FreeNotification(Self);
  end;
end;

procedure TDefaultTableDataLinkListEh.Notification(AComponent: TComponent; Operation: TOperation);
var
  Pair: TPair<TDataSource, TDataSetTableLinkEh>;
begin
  inherited Notification(AComponent, Operation);
  if AComponent is TDataSource then
  begin
    Pair := FSetToSourceDic.ExtractPair(TDataSource(AComponent));
    if Pair.Value <> nil then
      Pair.Value.Free;
  end;
end;

{ TDataSetTableLinkDataLinkEh }

constructor TDataSetTableLinkDataLinkEh.Create(ATableLink: TDataSetTableLinkEh);
begin
  inherited Create();
  FTableLink := ATableLink;
end;

destructor TDataSetTableLinkDataLinkEh.Destroy;
begin
  inherited Destroy();
end;

procedure TDataSetTableLinkDataLinkEh.DataEvent(Event: TDataEvent; Info: TDataEventInfoTypeEh);
begin
  inherited DataEvent(Event, Info);
end;

procedure TDataSetTableLinkDataLinkEh.DataSetChanged;
begin
  if DataSet.State = dsBrowse then
    FTableLink.DataLinkDataSetChanged;
end;

procedure TDataSetTableLinkDataLinkEh.DataSetScrolled(Distance: Integer);
begin
  FTableLink.DataLinkDataSetScrolled;
end;

procedure TDataSetTableLinkDataLinkEh.EditingChanged;
begin
  inherited EditingChanged;
  if DataSet <> nil  then
    FTableLink.DataLinkEditingChanged;
end;

procedure TDataSetTableLinkDataLinkEh.RecordChanged(Field: TField);
begin
  inherited RecordChanged(Field);
  FTableLink.DataLinkRecordChanged(Field);
end;

procedure TDataSetTableLinkDataLinkEh.ActiveChanged;
begin
  inherited ActiveChanged();
  FTableLink.DataLinkActiveChanged;
end;

{ TDataSetTableLinkEh }

constructor TDataSetTableLinkEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TDataSetTableLinkDataLinkEh.Create(Self);
end;

destructor TDataSetTableLinkEh.Destroy;
begin
  Destroying;
  DataSource := nil;
  FreeAndNil(FDataLink);
  inherited Destroy;
end;

function TDataSetTableLinkEh.GetCanModify: Boolean;
begin
  if (DataSet <> nil) then
    Result := DataSet.CanModify
  else
    Result := False;
end;

function TDataSetTableLinkEh.GetActive: Boolean;
begin
  if (DataSet <> nil) then
    Result := DataSet.Active
  else
    Result := False;
end;

procedure TDataSetTableLinkEh.RaiseInactiveError;
begin
  DatabaseError('DataSet is Closed', Self);
end;

function TDataSetTableLinkEh.CreateFieldLinkList: TTableFieldLinkListEh;
begin
  Result := TDataSetFieldLinkListEh.Create(Self);
end;

function TDataSetTableLinkEh.CreateRowLinkList: TTableRowLinkListEh;
begin
  Result := TDataSetRecLinkListEh.Create(Self);
end;

procedure TDataSetTableLinkEh.FillRowLinkList;
var
  ABookmark: TBookmark;
begin
  if (DataSet <> nil) and (DataSet.Active) then
  begin
    DataSet.CheckBrowseMode;
    LockDataSetChanges;
    ABookmark := DataSet.Bookmark;
    DataSet.DisableControls;
    try
      DataSet.First;
      while not DataSet.Eof do
      begin
        Rows.FetchDataSetRecord(DataSet);
        DataSet.Next;
      end;
    finally
      DataSet.EnableControls;
    end;
    DataSet.Bookmark := ABookmark;
    UnlockDataSetChanges;
  end;
  SendChangeNotification(TTableLinkEventTypeEh.Reset, -1, -1, nil);
end;

procedure TDataSetTableLinkEh.UpdateCurrentRowIndex(IsSendNotification: Boolean);
var
  RowIndex: Integer;
  OldIndex: Integer;
begin
  RowIndex := Rows.IndexOf(DataSet.Bookmark);
  if RowIndex <> CurrentRowIndex then
  begin
    OldIndex := FCurrentRowIndex;
    FCurrentRowIndex := RowIndex;
    if IsSendNotification then
      SendChangeNotification(TTableLinkEventTypeEh.CurrentPosChanged, FCurrentRowIndex, OldIndex, CurrentRow);
  end;
end;

procedure TDataSetTableLinkEh.SetCurrentRowIndex(const Value: Integer);
var
  OldIndex: Integer;
begin
  CheckActive;
  if FCurrentRowIndex <> Value then
  begin
    CheckBrowseMode;
    if Value = -1 then
    begin
      OldIndex := FCurrentRowIndex;
      FCurrentRowIndex := -1;
      SendChangeNotification(TTableLinkEventTypeEh.CurrentPosChanged, FCurrentRowIndex, OldIndex, CurrentRow);
    end else
    begin
      if FCurrentRowIndex = -1 then
      begin
        DataSet.First;
        DataSet.MoveBy(Value);
      end else
      begin
        DataSet.MoveBy(Value - FCurrentRowIndex);
      end;
    end;
  end;
end;

function TDataSetTableLinkEh.PreconvertValueToSet(AFieldValueIndex: Integer; const AValue: TValue): TValue;
var
  Field: TField;
  AVarType: TVarType;
  VarValue: Variant;
begin
  {$IFDEF FPC}
  Field := DataSet.Fields[AFieldValueIndex];
  VarValue := Null; 
  {$ELSE}
  Field := DataSet.FieldList[AFieldValueIndex];
  VarValue := AValue.AsVariant;
  {$ENDIF}
  AVarType := VarType(VarValue);

  if Field.DataType in [ftString, ftMemo, ftFmtMemo, ftFixedChar, ftWideString, ftOraClob,
                        ftVariant, ftGuid, ftFixedWideChar, ftWideMemo] then
  begin
    Result := AValue;
  end
  else if ( (AVarType = varString) or
            {$IFDEF EH_LIB_12}(AVarType = varUString) or {$ENDIF}
            (AVarType = varOleStr)
          ) and
          (VarSameValue(VarValue, '') = True) then
  begin
    Result := TValue.From<Variant>(Null);
  end
  else
  begin
    Result := AValue;
  end;
end;

procedure TDataSetTableLinkEh.SetCurrentRowValue(AFieldValueIndex: Integer; const AValue: TValue);
var
  PreValue: TValue;
begin
  PreValue := PreconvertValueToSet(AFieldValueIndex, AValue);
  {$IFDEF FPC}
  
  DataSet.Fields[AFieldValueIndex].AsVariant := Null; 
  {$ELSE}
  DataSet.FieldList[AFieldValueIndex].AsVariant := PreValue.AsVariant;
  {$ENDIF}
end;

function TDataSetTableLinkEh.GetCurrentRow: TDataSetRecLinkEh;
begin
  Result := TDataSetRecLinkEh(inherited CurrentRow);
end;

function TDataSetTableLinkEh.GetDataSet: TDataSet;
begin
  if FDataLink.DataSource <> nil then
    Result := FDataLink.DataSource.DataSet
  else
    Result := nil;
end;

function TDataSetTableLinkEh.GetFieldLinkList: TDataSetFieldLinkListEh;
begin
  Result := TDataSetFieldLinkListEh(inherited Fields);
end;

function TDataSetTableLinkEh.GetRows: TDataSetRecLinkListEh;
begin
  Result := TDataSetRecLinkListEh(inherited Rows);
end;

function TDataSetTableLinkEh.AppendNewRow: Integer;
begin
  CheckActive;
  CheckBrowseMode;
  DataSet.Append;
  Result := CurrentRowIndex;
end;

function TDataSetTableLinkEh.InsertNewRow: Integer;
begin
  CheckActive;
  CheckBrowseMode;
  DataSet.Insert;
  Result := CurrentRowIndex;
end;

procedure TDataSetTableLinkEh.EditCurrentRow();
begin
  CheckActive;
  DataSet.Edit;
end;

procedure TDataSetTableLinkEh.CancelCurrentRow();
var
  IsInserting: Boolean;
  RowIndex: Integer;
  ARowLink: TTableRowLinkEh;
begin
  CheckActive;
  if (CurrentRow <> nil) and
     (CurrentRow.EditState in [TRowLinkEditStateEh.Insert, TRowLinkEditStateEh.Edit]) then
  begin
    FCancelStarted := True;
    IsInserting := CurrentRow.EditState = TRowLinkEditStateEh.Insert;
    RowIndex := CurrentRowIndex;

    try
      DataSet.Cancel;
    finally
      FCancelStarted := False;
    end;

    if FCancelFinished = True then
    begin
      FCancelFinished := False;
      if IsInserting then
      begin
        ARowLink := Rows.InternalDelete(RowIndex);
        UpdateCurrentRowIndex(True);
        SendChangeNotification(TTableLinkEventTypeEh.RowDeleted, RowIndex, RowIndex, ARowLink);
        ARowLink.Free;
      end else
      begin
        CurrentRow.UpdateValuesFromDataSet(DataSet, nil);
        SendChangeNotification(TTableLinkEventTypeEh.RowChanged, CurrentRowIndex, CurrentRowIndex, CurrentRow);
      end;
    end;
  end;
end;

procedure TDataSetTableLinkEh.CheckPostSynchronization();
begin
  if DataSet.IsEmpty = True then
    raise Exception.Create('TDataSetTableLinkEh.CheckPostSynchronization(): Data desync detected. ' + sLineBreak +
      'DataSet.IsEmpty after post!!!');
  CheckPostBookmarkDuplication();
end;

procedure TDataSetTableLinkEh.CheckPostBookmarkDuplication();
var
  CurBookmark: TBookmark;
  CurBookmarkIndex: Integer;
  I: Integer;
begin
  if DataSet.IsEmpty = True then Exit;

  CurBookmark := DataSet.Bookmark;
  CurBookmarkIndex := CurrentRowIndex;

  for I := 0 to Rows.Count - 1 do
  begin
    if (I <> CurBookmarkIndex) and
       (DataSet.CompareBookmarks(Rows[I].DataBookmark, CurBookmark) = 0) then
      raise Exception.Create('TDataSetTableLinkEh.CheckPostBookmarkDuplication(): Data desync detected. ' + sLineBreak +
        'Rows[' + IntToStr(I) + '].DataBookmark = CurBookmark!!!');
  end;
end;

procedure TDataSetTableLinkEh.PostCurrentRow();
begin
  CheckActive;
  if (CurrentRow <> nil) and
     (CurrentRow.EditState in [TRowLinkEditStateEh.Insert, TRowLinkEditStateEh.Edit]) then
  begin
    FPostStarted := True;
    try
      DataSet.Post;
    finally
      FPostStarted := False;
    end;

    if FPostFinished = True then
    begin
      FPostFinished := False;
      CheckPostSynchronization();

      CurrentRow.UpdateValuesFromDataSet(DataSet, nil);
      SendChangeNotification(TTableLinkEventTypeEh.RowChanged, CurrentRowIndex, CurrentRowIndex, CurrentRow);
    end;
  end;
end;

procedure TDataSetTableLinkEh.DeleteCurrentRow;
var
  RowIndex: Integer;
  ARowLink: TTableRowLinkEh;
begin
  CheckActive;

  if Rows.Count = 0 then DatabaseError(SDataSetEmpty, Self);

  if CurrentRow.EditState = TRowLinkEditStateEh.Insert then
  begin
    CancelCurrentRow;
  end else
  begin
    if CurrentRow.EditState = TRowLinkEditStateEh.Edit then
      CancelCurrentRow;

    RowIndex := CurrentRowIndex;
    FDeleteStarted := True;

    try
      DataSet.Delete;
    finally
      FDeleteStarted := False;
    end;

    if FDeleteFinished = True then
    begin
      FDeleteFinished := False;

      ARowLink := Rows.InternalDelete(RowIndex);
      SendChangeNotification(TTableLinkEventTypeEh.RowDeleted, RowIndex, RowIndex, ARowLink);
      UpdateCurrentRowIndex(True);
      ARowLink.Free;
    end;
  end;
end;

procedure TDataSetTableLinkEh.LockDataSetChanges;
begin
  FLockDataSetChanges := FLockDataSetChanges + 1;
end;

procedure TDataSetTableLinkEh.UnlockDataSetChanges;
begin
  FLockDataSetChanges := FLockDataSetChanges - 1;
end;

function TDataSetTableLinkEh.DataSetChangesIsLocked: Boolean;
begin
  Result := (FLockDataSetChanges > 0);
end;

function TDataSetTableLinkEh.GetDataSource: TComponent;
begin
  Result := FDataSource;
end;

procedure TDataSetTableLinkEh.SetDataSource(const Value: TComponent);
begin
  if Value = FDataSource then Exit;

  if Value = nil then
  begin
    FDataSource := nil;
    if FDataLink.DataSource = nil
      then UpdateAll
      else FDataLink.DataSource := nil;
  end
  else if Value is TDataSource then
  begin
    FDataSource := Value;
    FDataLink.DataSource := Value as TDataSource;
  end
  else if Value is TDataSet then
  begin
    FDataSource := Value;
    FDataLink.DataSource := GetDefaultDataSourceForDataSet(TDataSet(Value));
  end else
  begin
    raise Exception.Create('DataSource of ' + Value.ClassName + ' is not supported.');
  end;

  if (Value <> nil) then
    Value.FreeNotification(Self);
end;

procedure TDataSetTableLinkEh.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) then
  begin
    if AComponent = FDataSource then
    begin
      FDataSource := nil;
      ClearAll;
    end;
  end;
end;

function TDataSetTableLinkEh.CheckUpdateFieldLinkList: Boolean;
var
  {$IFDEF FPC}
  FieldList: TFields;
  {$ELSE}
  FieldList: TFieldList;
  {$ENDIF}
  I: Integer;
begin
  Result := False;
  try
    if (DataLink.DataSet = nil) and (Fields.Count > 0) then
    begin
      Result := True;
    end else if DataLink.DataSet <> nil then
    begin
      {$IFDEF FPC}
      FieldList := DataLink.DataSet.Fields;
      {$ELSE}
      FieldList := DataLink.DataSet.FieldList;
      {$ENDIF}

      if FieldList.Count <> Fields.Count then
      begin
        Result := True;
      end else
      begin
        for I := 0 to FieldList.Count - 1 do
        begin
          if FieldList[I] <> Fields[I].Field then
          begin
            Result := True;
            Break;
          end;
        end;
      end;
    end;

    if Result then
    begin
      UpdateFieldLinkList;
    end;
  finally
  end;
end;

procedure TDataSetTableLinkEh.UpdateFieldLinkList;
begin
  ClearAll;
  FillFieldLinkList;
end;

{$REGION 'DataLink events'}

procedure TDataSetTableLinkEh.DataLinkActiveChanged;
begin
  if DataSetChangesIsLocked then Exit;

  UpdateFieldLinkList;
  if DataLink.Active then
  begin
    FillRowLinkList;
    UpdateCurrentRowIndex(True);
  end else
  begin
    ClearRowLinkList;
  end;
end;

procedure TDataSetTableLinkEh.DataLinkDataSetChanged;
begin
  if DataSetChangesIsLocked then Exit;

  if FDeleteStarted = True then
  begin
    FDeleteFinished := True;
  end
  else if FCancelStarted = True then
  begin
    FCancelFinished := True;
  end
  else if FPostStarted = True then
  begin
    FPostFinished := True;
  end else
  begin
    LockTableDataLinkChanges;
    try
      ClearRowLinkList;
      FillRowLinkList;
    finally
      UpdateCurrentRowIndex(False);
      UnlockTableDataLinkChanges;
      SendChangeNotification(TTableLinkEventTypeEh.Reset, -1, -1, nil);
    end;
  end;
end;

procedure TDataSetTableLinkEh.DataLinkDataSetScrolled;
begin
  if DataSetChangesIsLocked then Exit;

  UpdateCurrentRowIndex(True);
end;

procedure TDataSetTableLinkEh.DataLinkEditingChanged;
var
  InsertedPos: Integer;
  NewPos: Integer;
  CurrentPosChanged: Boolean;
begin
  if DataSetChangesIsLocked then Exit;

  if DataSet.State = TDataSetState.dsInsert then
  begin
    if DataSet.Eof then
      NewPos := -1
    else
      NewPos := CurrentRowIndex;

    InsertedPos := Rows.InternalNewEditRowLink(NewPos);

    if FCurrentRowIndex <> InsertedPos then
    begin
      FCurrentRowIndex := InsertedPos;
      CurrentPosChanged := True;
    end else
    begin
      CurrentPosChanged := False;
    end;

    SendChangeNotification(TTableLinkEventTypeEh.RowAdded, InsertedPos, -1, Rows[InsertedPos]);
    if CurrentPosChanged then
      SendChangeNotification(TTableLinkEventTypeEh.CurrentPosChanged, InsertedPos, -1, Rows[InsertedPos]);
 end;

  SendChangeNotification(TTableLinkEventTypeEh.RowStateChanged, CurrentRowIndex, -1, CurrentRow);
end;

procedure TDataSetTableLinkEh.DataLinkRecordChanged(AField: TField);
begin
  if DataSetChangesIsLocked then Exit;

  CurrentRow.UpdateValuesFromDataSet(DataSet, AField);
  SendChangeNotification(TTableLinkEventTypeEh.RowChanged, CurrentRowIndex, CurrentRowIndex, CurrentRow);
end;

{$ENDREGION}

{ TDataSetFieldLinkListEh }

constructor TDataSetFieldLinkListEh.Create(ATableLink: TBaseTableDataLinkEh);
begin
  inherited Create(ATableLink);
end;

destructor TDataSetFieldLinkListEh.Destroy;
begin
  inherited Destroy;
end;

procedure TDataSetFieldLinkListEh.FillList;
var
  {$IFDEF FPC}
  FieldList: TFields;
  {$ELSE}
  FieldList: TFieldList;
  {$ENDIF}
  I: Integer;
  AFieldLink: TDataSetFieldLinkEh;
  Field: TField;
begin
  if (TableDataLink.DataSet <> nil) and
     (TableDataLink.DataSet.Active = True) and
     (Count = 0) then
  begin
    begin
      {$IFDEF FPC}
      FieldList := TableDataLink.DataLink.DataSet.Fields;
      {$ELSE}
      FieldList := TableDataLink.DataLink.DataSet.FieldList;
      {$ENDIF}
      for I := 0 to FieldList.Count - 1 do
      begin
        Field := FieldList[I];
        AFieldLink := TDataSetFieldLinkEh.Create(Self);
        AFieldLink.FField := Field;
        InternalAddField(AFieldLink);
      end;
    end;
  end;
end;

function TDataSetFieldLinkListEh.GetFieldLink(Index: Integer): TDataSetFieldLinkEh;
begin
  Result := TDataSetFieldLinkEh(inherited Item[Index]);
end;

function TDataSetFieldLinkListEh.GetTableLink: TDataSetTableLinkEh;
begin
  Result := TDataSetTableLinkEh(inherited TableDataLink);
end;

function TDataSetFieldLinkListEh.IndexOf(AField: TField): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if FieldLink[I].Field = AField then
    begin
      Result := I;
      Break;
    end;
  end;
end;

{ TDataSetRecLinkEh }

constructor TDataSetRecLinkEh.Create(ARowLinkList: TTableRowLinkListEh);
begin
  inherited Create(ARowLinkList);
end;

destructor TDataSetRecLinkEh.Destroy;
begin
  inherited Destroy;
end;

function TDataSetRecLinkEh.GetEditModified: Boolean;
begin
  if RowLinkList.TableDataLink.CurrentRow = Self then
    Result := RowLinkList.TableDataLink.DataSet.Modified
  else
    Result := False;
end;

function TDataSetRecLinkEh.GetRowLinkList: TDataSetRecLinkListEh;
begin
  Result := TDataSetRecLinkListEh(inherited RowLinkList);
end;

procedure TDataSetRecLinkEh.UpdateValuesFromDataSet(ADataSet: TDataSet; AField: TField);
var
  I: Integer;
  ForField: TField;
begin
  FDataBookmark := ADataSet.Bookmark;

  if Length(FDataValues) <> RowLinkList.TableDataLink.Fields.Count then
    SetLength(FDataValues, RowLinkList.TableDataLink.Fields.Count);

  for I := 0 to Length(FDataValues) - 1 do
  begin
    {$IFDEF FPC}
    ForField := RowLinkList.TableDataLink.DataSet.Fields[I];
    {$ELSE}
    ForField := RowLinkList.TableDataLink.DataSet.FieldList[I];
    {$ENDIF}
    if (AField = nil) or (AField = ForField) then
      InternalSetFieldValue(I, ForField);
  end;
end;

procedure TDataSetRecLinkEh.InternalSetFieldValue(AFieldLinkIndex: Integer; AField: TField);
var
  VarImgStream: Variant;
begin
  if (AField is TGraphicField) or
     ((AField is TBlobField) and (TBlobField(AField).BlobType = TFieldType.ftGraphic)) then
  begin
    VarImgStream := CreateImageStream(AField);
    InternalSetDataValue(AFieldLinkIndex, TValue.From<Variant>(VarImgStream));
  end else
  begin
    InternalSetDataValue(AFieldLinkIndex, TValue.From<Variant>(AField.Value));
  end;
end;

function TDataSetRecLinkEh.GetValue(ValueIndex: Integer): TValue;
begin
  Result := FDataValues[ValueIndex];
end;

procedure TDataSetRecLinkEh.InternalSetDataValue(ValueIndex: Integer; const Value: TValue);
begin
  FDataValues[ValueIndex] := Value;
end;

procedure TDataSetRecLinkEh.InitNewRow(ARowLinkList: TTableRowLinkListEh; ARowPos: Integer);
begin
  inherited InitNewRow(ARowLinkList, ARowPos);
  UpdateValuesFromDataSet(RowLinkList.TableDataLink.DataSet, nil);
end;

function TDataSetRecLinkEh.GetEditState: TRowLinkEditStateEh;
var
  DataSetState: TDataSetState;
begin
  if RowLinkList.TableDataLink.CurrentRow = Self then
  begin
    DataSetState := RowLinkList.TableDataLink.DataSet.State;
    if DataSetState = TDataSetState.dsInsert then
      Result := TRowLinkEditStateEh.Insert
    else if DataSetState = TDataSetState.dsEdit then
      Result := TRowLinkEditStateEh.Edit
    else
      Result := TRowLinkEditStateEh.Browse;
  end else
  begin
    Result := TRowLinkEditStateEh.Browse;
  end;
end;

function TDataSetRecLinkEh.GetSourceItem: Pointer;
begin
  Result := DataBookmark;
end;

function TDataSetRecLinkEh.GetSourceObjectItem: TObject;
begin
  Result := nil;
end;

{ TDataSetRecLinkListEh }

constructor TDataSetRecLinkListEh.Create(ATableDataLink: TBaseTableDataLinkEh);
begin
  inherited Create(ATableDataLink);
end;

destructor TDataSetRecLinkListEh.Destroy;
begin
  inherited Destroy;
end;

function TDataSetRecLinkListEh.InternalCreateRowLink: TTableRowLinkEh;
begin
  Result := TDataSetRecLinkEh.Create(Self);
end;

procedure TDataSetRecLinkListEh.FetchDataSetRecord(ADataSet: TDataSet);
var
  ARowLink: TDataSetRecLinkEh;
begin
  ARowLink := TDataSetRecLinkEh(InternalCreateRowLink);
  ARowLink.InitNewRow(Self, -1);
  InternalAddRowLink(ARowLink);
end;

function TDataSetRecLinkListEh.IndexOf(ADataBookmark: TBookmark): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if DataSetCompareBookmarks(TableDataLink.DataSet, RowLink[I].DataBookmark, ADataBookmark) = 0 then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

function TDataSetRecLinkListEh.GetRowLink(Index: Integer): TDataSetRecLinkEh;
begin
  Result := TDataSetRecLinkEh(inherited Item[Index]);
end;

function TDataSetRecLinkListEh.GetTableDataLink: TDataSetTableLinkEh;
begin
  Result := TDataSetTableLinkEh(inherited TableDataLink);
end;

procedure InitUnit;
begin
end;

procedure FinalUnit;
begin
  FreeAndNil(DefaultTableDataLinkList);
end;

{ TDataSetFieldLinkEh }

constructor TDataSetFieldLinkEh.Create(AFieldLinkList: TTableFieldLinkListEh);
begin
  inherited Create(AFieldLinkList);
end;

destructor TDataSetFieldLinkEh.Destroy;
begin
  inherited Destroy;
end;

function TDataSetFieldLinkEh.GetDataTypeInfo: PTypeInfo;
begin
  if (FField is TGraphicField) or
     ((FField is TBlobField) and (TBlobField(FField).BlobType = TFieldType.ftGraphic))
  then
    Result := TypeInfo(TInterfacedImageStreamEh)
  else
    Result := TypeInfo(Variant);
end;

function TDataSetFieldLinkEh.GetDataVarSubtype: TVarType;
begin
  if FField <> nil then
  begin
    if (FField is TGraphicField) or
       ((FField is TBlobField) and (TBlobField(FField).BlobType = TFieldType.ftGraphic))
    then
      Result := varDispatch
    else
      Result := FiledDataTypeToVarType(FField.DataType);
  end else
    Result := varError;
end;

function TDataSetFieldLinkEh.GetDisplayFormat: String;
begin
  if (Field <> nil) then
    Result := GetFieldDisplayFormat(Field)
  else
    Result := '';
end;

function TDataSetFieldLinkEh.GetDisplayName: String;
begin
  if FField <> nil then
    Result := FField.DisplayName
  else
    Result := '';
end;

function TDataSetFieldLinkEh.GetFieldName: String;
begin
  if FField <> nil then
    Result := FField.FieldName
  else
    Result := '';
end;

initialization
  InitUnit;
finalization
  FinalUnit;
end.
