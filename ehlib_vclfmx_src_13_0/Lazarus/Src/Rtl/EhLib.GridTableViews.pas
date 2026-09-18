{*******************************************************}
{                                                       }
{                      EhLib 12.1                       }
{                 EhLib.GridTableViews                  }
{                                                       }
{     Copyright (c) 2024-2025 by Dmitry V. Bolshakov    }
{                                                       }
{*******************************************************}

unit EhLib.GridTableViews;

{$I ..\Incl\EhLib.Inc}
{$SCOPEDENUMS ON}

interface

uses
  Variants, Contnrs,
  Db, SysUtils, Classes, TypInfo,
  Generics.Collections, Generics.Defaults, Rtti,
  DefaultDataSourcesEh,
  EhLib.TableLinks,
  EhLib.GridTableView.Filters,
  DBUtilsEh, EhLibUtils;

type
  TTableRowViewEh = class;
  TTableRowViewFilteredListEh = class;
  TTableRowViewSourceListEh = class;
  TTableRowViewSortedListEh = class;
  TBaseGridTableViewEh = class;

{ TTableRowViewEh }

  TTableRowViewEh = class(TPersistent)
  private
    FSourceRowLink: TTableRowLinkEh;
    FTableView: TBaseGridTableViewEh;
    function GetEditState: TRowLinkEditStateEh;
    function GetEditing: Boolean;
    function GetSourceItem: Pointer;
    function GetSourceObjectItem: TObject;
  protected
    procedure SetSourceRowView(ARowView: TTableRowLinkEh);
  public
    constructor Create(ATableView: TBaseGridTableViewEh);
    destructor Destroy; override;

    property EditState: TRowLinkEditStateEh read GetEditState;
    property Editing: Boolean read GetEditing;

    property SourceRowLink: TTableRowLinkEh read FSourceRowLink;
    property TableView: TBaseGridTableViewEh  read FTableView;
    property SourceItem: Pointer read GetSourceItem;
    property SourceObjectItem: TObject read GetSourceObjectItem;
  end;

{ TTableRowViewSourceListEh }

  TTableRowViewSourceListEh = class(TPersistent)
  private
    FGridTableView: TBaseGridTableViewEh;
    FList: TList<TTableRowViewEh>;
    function GetItem(Index: Integer): TTableRowViewEh;
    function GetCount: Integer;
  protected
    procedure SourceDataChanged(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowView: TTableRowLinkEh); virtual;
    procedure Clear;
  public
    constructor Create(AGridTableView: TBaseGridTableViewEh);
    destructor Destroy; override;

    property Item[Index: Integer]: TTableRowViewEh read GetItem; default;
    property Count: Integer read GetCount;
  end;

{ TOrderByItemEh }

  TOrderByItemEh = class(TObject)
  protected
    FFieldLink: TTableFieldLinkEh;
    FFieldViewIndex: Integer;
    FIsDesc: Boolean;
  public
    property FieldLink: TTableFieldLinkEh read FFieldLink;
    property FieldLinkIndex: Integer read FFieldViewIndex;
    property IsDesc: Boolean read FIsDesc;
  end;

{ TOrderByList }

  TOrderByListEh = class(TPersistent)
  private
    FItemList: TList<TOrderByItemEh>;
    FSortedItemList: TTableRowViewSortedListEh;

    function GetCount: Integer;
  protected
    function GetItem(Index: Integer): TOrderByItemEh;
    function FindFieldIndex(const FieldName: String): Integer; virtual;
  public
    constructor Create(ASortedItemList: TTableRowViewSortedListEh);
    destructor Destroy; override;

    procedure Clear;
    function GetToken(const Exp: String; var FromIndex: Integer): String;
    procedure ParseOrderByStr(const OrderByStr: String);

    property Items[Index: Integer]: TOrderByItemEh read GetItem; default;
    property Count: Integer read GetCount;
  end;

{ TTableRowViewSortedListEh }

  TTableRowViewSortedListEh = class(TPersistent)
  private
    FGridTableView: TBaseGridTableViewEh;
    FList: TList<TTableRowViewEh>;
    FSortOrderStr: String;
    FOrderByList: TOrderByListEh;

    function GetCount: Integer;
    function GetItem(Index: Integer): TTableRowViewEh;
    procedure SetSortOrderStr(const Value: String);
    function GetListIsSorted: Boolean;
  protected
    {$IFDEF FPC}
    function ListItemCompareProc(constref ALeft, ARight: TTableRowViewEh): Integer;
    {$ELSE}
    function ListItemCompareProc(const ALeft, ARight: TTableRowViewEh): Integer;
    {$ENDIF}

    procedure BaseListChanged(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; AxisListItem: TTableRowViewEh); virtual;
    procedure Clear;

    procedure ResortItems;

    property SortOrderStr: String read FSortOrderStr write SetSortOrderStr;
  public
    constructor Create(AGridTableView: TBaseGridTableViewEh);
    destructor Destroy; override;

    function IndexOf(AListItem: TTableRowViewEh): Integer; overload;
    function IndexOf(ARowView: TTableRowLinkEh): Integer; overload;

    property ListIsSorted: Boolean read GetListIsSorted;
    property Item[Index: Integer]: TTableRowViewEh read GetItem; default;
    property Count: Integer read GetCount;
  end;

{ TFilterListItemEh }

  TFilterListItemEh = record
    RowView: TTableRowViewEh;
    SortedRowViewIndex: Integer;

    constructor Create(ARowView: TTableRowViewEh; ASortedRowViewIndex: Integer);
  end;

{ TTableRowViewFilteredListEh }

  TTableRowViewFilteredListEh = class(TPersistent)
  private
    FList: TList<TFilterListItemEh>;
    FTableView: TBaseGridTableViewEh;
    FFilter: TTableViewFilterEh;

    function GetCount: Integer;
    function GetRowView(Index: Integer): TTableRowViewEh;
  protected
    function IsListItemMatchFilter(AListItem: TTableRowViewEh): Boolean;

    procedure InternalClear;
    procedure UpdateList;

    procedure SortedListChanged(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; AxisListItem: TTableRowViewEh); virtual;
    procedure FilterChanged(); virtual;
  public
    constructor Create(ATableView: TBaseGridTableViewEh);
    destructor Destroy; override;

    function IndexOf(ARowView: TTableRowViewEh): Integer; overload;
    function IndexOf(ARowLink: TTableRowLinkEh): Integer; overload;
    function FindItem(const KeyFields: string; const KeyValues: array of TValue): TTableRowViewEh;

    property ListItem[Index: Integer]: TTableRowViewEh read GetRowView; default;
    property Count: Integer read GetCount;
    property TableView: TBaseGridTableViewEh read FTableView;
    property Filter: TTableViewFilterEh read FFilter;
  end;

{ TBaseGridTableViewEh }

  TBaseGridTableViewEh = class(TComponent)
  private
    FDataSource: TComponent;
    FTableDataLink: TBaseTableDataLinkEh;
    FBaseList: TTableRowViewSourceListEh;
    FSortedList: TTableRowViewSortedListEh;
    FFilteredList: TTableRowViewFilteredListEh;
    FCurrentRowViewIndex: Integer; 

    function GetActive: Boolean;
    function GetAtEndOfRowsList: Boolean;
    function GetAtStartOfRowsList: Boolean;
    function GetCanModify: Boolean;
    function GetCurrentRow: TTableRowViewEh;
    function GetCurrentRowIsEditModified: Boolean;
    function GetDataSource: TComponent;
    function GetFields: TTableFieldLinkListEh;
    function GetSortOrderStr: String;
    function GetTableDataLink: TBaseTableDataLinkEh;

    procedure AddSourceChangeNotification;
    procedure RemoveSourceChangeNotification;
    procedure Reset;
    procedure SetCurrentRowViewIndex(const Value: Integer);
    procedure SetDataSource(const Value: TComponent);
    procedure SetSortOrderStr(const Value: String);
    function GetHasPendingData: Boolean;

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    function CreateAxisListItemBar(): TTableRowViewEh; virtual;
    function CreateViewListItems(): TTableRowViewFilteredListEh; virtual;
    function IsListItemMatchFilter(AListItem: TTableRowViewEh): Boolean; virtual;

    procedure SendWritePendingData;
    procedure SendDataNotification(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowView: TTableRowViewEh);
    procedure SourceDataChanged(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowView: TTableRowLinkEh); virtual;
    procedure DataNotification(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowView: TTableRowViewEh); virtual;

    procedure UpdateCurrentRowIndex(SendUpdateEvent: Boolean); virtual;

    procedure BaseItemListChanged(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowView: TTableRowViewEh); virtual;
    procedure SortedListChanged(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowView: TTableRowViewEh); virtual;
    procedure FinalListChanged(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowView: TTableRowViewEh); virtual;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure CheckActive;

    function EditCurrentRow(): Boolean;
    function MoveRowPosBy(Distance: Integer): Integer;

    procedure GotoPriorRow();
    procedure GotoNextRow();
    procedure GotoFirstRow();
    procedure GotoLastRow();
    procedure InsertNewRow();
    procedure AppendNewRow();
    procedure CancelCurrentRow();
    procedure PostCurrentRow();
    procedure DeleteCurrentRow();

    procedure WritePendingData; virtual;
    procedure MarkPendingData;
    procedure ResetPendingData;
    procedure UpdateFilteredList;

    property DataSource: TComponent read GetDataSource write SetDataSource;
    property TableDataLink: TBaseTableDataLinkEh read GetTableDataLink;

    property Fields: TTableFieldLinkListEh read GetFields;

    property BaseRowList: TTableRowViewSourceListEh read FBaseList;
    property SortedRowList: TTableRowViewSortedListEh read FSortedList;
    property FilteredRowList: TTableRowViewFilteredListEh read FFilteredList;
    property Rows: TTableRowViewFilteredListEh read FFilteredList;

    property Active: Boolean read GetActive;
    property CurrentRowViewIndex: Integer read FCurrentRowViewIndex write SetCurrentRowViewIndex;
    property CurrentRowView: TTableRowViewEh read GetCurrentRow;
    property CurrentRowIsEditModified: Boolean read GetCurrentRowIsEditModified;
    property AtEndOfRowsList: Boolean read GetAtEndOfRowsList;
    property AtStartOfRowsList: Boolean read GetAtStartOfRowsList;

    property CanModify: Boolean read GetCanModify;
    property HasPendingData: Boolean read GetHasPendingData;

    property SortOrderStr: String read GetSortOrderStr write SetSortOrderStr;
  end;

implementation

uses EhLib.TableLink.Db;

{ TDataSetTableViewEh }

constructor TBaseGridTableViewEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBaseList := TTableRowViewSourceListEh.Create(Self);
  FSortedList := TTableRowViewSortedListEh.Create(Self);
  FFilteredList := CreateViewListItems();
  FCurrentRowViewIndex := -1;
end;

destructor TBaseGridTableViewEh.Destroy;
begin
  DataSource := nil;
  FreeAndNil(FBaseList);
  FreeAndNil(FSortedList);
  FreeAndNil(FFilteredList);
  inherited Destroy;
end;

function TBaseGridTableViewEh.CreateAxisListItemBar: TTableRowViewEh;
begin
  Result := TTableRowViewEh.Create(Self);
end;

function TBaseGridTableViewEh.CreateViewListItems: TTableRowViewFilteredListEh;
begin
  Result := TTableRowViewFilteredListEh.Create(Self);
end;

{$REGION 'DataLink events'}
procedure TBaseGridTableViewEh.GotoPriorRow();
begin
  CheckActive;
  if CurrentRowViewIndex > 0 then
    CurrentRowViewIndex := CurrentRowViewIndex - 1;
end;

procedure TBaseGridTableViewEh.GotoNextRow();
begin
  CheckActive;
  if CurrentRowViewIndex < FilteredRowList.Count - 1 then
    CurrentRowViewIndex := CurrentRowViewIndex + 1;
end;

procedure TBaseGridTableViewEh.GotoFirstRow();
begin
  CheckActive;
  if FilteredRowList.Count > 0 then
    CurrentRowViewIndex := 0
  else
    CurrentRowViewIndex := -1;
end;

procedure TBaseGridTableViewEh.GotoLastRow();
begin
  CheckActive;
  if FilteredRowList.Count > 0 then
    CurrentRowViewIndex := FilteredRowList.Count - 1
  else
    CurrentRowViewIndex := -1;
end;

procedure TBaseGridTableViewEh.InsertNewRow();
begin
  CheckActive;
  TableDataLink.InsertNewRow();
end;

procedure TBaseGridTableViewEh.AppendNewRow();
begin
  CheckActive;
  TableDataLink.AppendNewRow();
end;

function TBaseGridTableViewEh.EditCurrentRow(): Boolean;
begin
  CheckActive;
  TableDataLink.EditCurrentRow();
  Result := CurrentRowView.EditState in [TRowLinkEditStateEh.Insert, TRowLinkEditStateEh.Edit];
end;

procedure TBaseGridTableViewEh.CancelCurrentRow();
begin
  CheckActive;
  TableDataLink.CancelCurrentRow();
end;

procedure TBaseGridTableViewEh.PostCurrentRow();
begin
  CheckActive;
  TableDataLink.PostCurrentRow();
end;

procedure TBaseGridTableViewEh.DeleteCurrentRow();
var
  BackToRow: TTableRowLinkEh;
  BackToRowIndex: Integer;
begin
  CheckActive;
  if (CurrentRowViewIndex = FilteredRowList.Count - 1) and (FilteredRowList.Count > 1) then
  begin
    BackToRow := FilteredRowList[CurrentRowViewIndex - 1].SourceRowLink;
  end
  else if (CurrentRowViewIndex < FilteredRowList.Count - 1) and (FilteredRowList.Count > 1) then
  begin
    BackToRow := FilteredRowList[CurrentRowViewIndex + 1].SourceRowLink;
  end else
  begin
    BackToRow := nil;
  end;

  TableDataLink.DeleteCurrentRow();

  if BackToRow <> nil then
  begin
    BackToRowIndex := TableDataLink.Rows.IndexOf(BackToRow);
    if BackToRowIndex <> -1 then
      TableDataLink.CurrentRowIndex := BackToRowIndex;
  end;
end;

function TBaseGridTableViewEh.MoveRowPosBy(Distance: Integer): Integer;
var
  NewPos: Integer;
  OldPos: Integer;
begin
  OldPos := CurrentRowViewIndex;
  NewPos := CurrentRowViewIndex + Distance;
  if NewPos < 0 then NewPos := 0;
  if NewPos > FilteredRowList.Count - 1 then NewPos := FilteredRowList.Count - 1;
  CurrentRowViewIndex := NewPos;
  Result := OldPos - CurrentRowViewIndex;
end;

procedure TBaseGridTableViewEh.WritePendingData;
begin
  TableDataLink.CheckWritePendingData();
end;

procedure TBaseGridTableViewEh.SendWritePendingData;
begin
  SendDataNotification(TTableLinkEventTypeEh.WritePendingData, CurrentRowViewIndex, -1, CurrentRowView);
end;

procedure TBaseGridTableViewEh.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
  begin
    if AComponent = FDataSource then
      DataSource := nil;
  end;
end;

{$ENDREGION 'DataLink events'}

procedure TBaseGridTableViewEh.CheckActive;
begin
  if Active = False then DatabaseError('DataSet is Closed', Self);
end;

procedure TBaseGridTableViewEh.Reset();
begin
  SourceDataChanged(TTableLinkEventTypeEh.Reset, -1, -1, nil);
  UpdateCurrentRowIndex(True);
end;

function TBaseGridTableViewEh.GetDataSource: TComponent;
begin
  Result := FDataSource;
end;

procedure TBaseGridTableViewEh.SetCurrentRowViewIndex(const Value: Integer);
var
  GridListItem: TTableRowViewEh;
  SourceIndex: Integer;
begin
  if FCurrentRowViewIndex <> Value then
  begin
    if Value = -1 then
    begin
      TableDataLink.CurrentRowIndex := -1;
    end else
    begin
      GridListItem := FilteredRowList[Value];
      SourceIndex := TableDataLink.Rows.IndexOf(GridListItem.SourceRowLink);
      TableDataLink.CurrentRowIndex := SourceIndex;
    end;
  end;
end;

procedure TBaseGridTableViewEh.SetDataSource(const Value: TComponent);
var
 ADataSource: TDataSource;
begin
  if Value = FDataSource then Exit;

  if Value = nil then
  begin
    RemoveSourceChangeNotification();
    FDataSource := nil;
    FTableDataLink := nil;
    AddSourceChangeNotification();
    Reset();
  end
  else if Value is TBaseTableDataLinkEh then
  begin
    RemoveSourceChangeNotification();
    FDataSource := Value;
    FTableDataLink := Value as TBaseTableDataLinkEh;
    AddSourceChangeNotification();
    Reset();
  end
  else if Value is TDataSource then
  begin
    RemoveSourceChangeNotification();
    FTableDataLink := GetDefaultTableDataLinkForDataSource(TDataSource(Value));
    FDataSource := Value;
    AddSourceChangeNotification();
    Reset();
  end
  else if Value is TDataSet then
  begin
    RemoveSourceChangeNotification();
    ADataSource  := GetDefaultDataSourceForDataSet(TDataSet(Value));
    FTableDataLink := GetDefaultTableDataLinkForDataSource(ADataSource);
    FDataSource := Value;
    AddSourceChangeNotification();
    Reset();
  end else
  begin
    raise Exception.Create('DataSource of ' + Value.ClassName + ' is not supported.');
  end;

  if (Value <> nil) then
    Value.FreeNotification(Self);
end;

procedure TBaseGridTableViewEh.SourceDataChanged(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowView: TTableRowLinkEh);
begin
  if AChangedType in [TTableLinkEventTypeEh.Reset,
                      TTableLinkEventTypeEh.RowAdded,
                      TTableLinkEventTypeEh.RowDeleted,
                      TTableLinkEventTypeEh.RowChanged,
                      TTableLinkEventTypeEh.RowStateChanged] then
  begin
    FBaseList.SourceDataChanged(AChangedType, NewIndex, OldIndex, ARowView);
    ResetPendingData;
  end
  else if AChangedType = TTableLinkEventTypeEh.CurrentPosChanged then
  begin
    UpdateCurrentRowIndex(True);
  end
  else if AChangedType = TTableLinkEventTypeEh.WritePendingData then
  begin
    SendWritePendingData;
  end else
  begin
    SendDataNotification(AChangedType, NewIndex, OldIndex, nil);
  end;
end;

procedure TBaseGridTableViewEh.BaseItemListChanged(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowView: TTableRowViewEh);
begin
  FSortedList.BaseListChanged(AChangedType, NewIndex, OldIndex, ARowView);
end;

procedure TBaseGridTableViewEh.SortedListChanged(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowView: TTableRowViewEh);
begin
  FFilteredList.SortedListChanged(AChangedType, NewIndex, OldIndex, ARowView);
end;

procedure TBaseGridTableViewEh.FinalListChanged(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowView: TTableRowViewEh);
begin
  if AChangedType = TTableLinkEventTypeEh.Reset then
  begin
    UpdateCurrentRowIndex(False);
  end;
  SendDataNotification(AChangedType, NewIndex, OldIndex, ARowView);
end;

procedure TBaseGridTableViewEh.UpdateCurrentRowIndex(SendUpdateEvent: Boolean);
var
  RowIndex: Integer;
  OldIndex: Integer;
  SourceRowView: TTableRowLinkEh;
begin
  if (TableDataLink <> nil) and (TableDataLink.CurrentRowIndex >= 0) then
  begin
    SourceRowView := TableDataLink.Rows[TableDataLink.CurrentRowIndex];
    RowIndex := FilteredRowList.IndexOf(SourceRowView);
  end else
  begin
    RowIndex := -1;
  end;

  if RowIndex <> CurrentRowViewIndex then
  begin
    OldIndex := FCurrentRowViewIndex;
    FCurrentRowViewIndex := RowIndex;
    if SendUpdateEvent then
      SendDataNotification(TTableLinkEventTypeEh.CurrentPosChanged, FCurrentRowViewIndex, OldIndex, nil);
  end;
end;

procedure TBaseGridTableViewEh.UpdateFilteredList;
begin
  FilteredRowList.UpdateList;
end;

procedure TBaseGridTableViewEh.SendDataNotification(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowView: TTableRowViewEh);
begin
  DataNotification(AChangedType, NewIndex, OldIndex, ARowView);
end;

procedure TBaseGridTableViewEh.DataNotification(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowView: TTableRowViewEh);
begin
end;

procedure TBaseGridTableViewEh.RemoveSourceChangeNotification();
begin
  if FTableDataLink <> nil then
    FTableDataLink.RemoveChangeNotification(Self);
end;

procedure TBaseGridTableViewEh.AddSourceChangeNotification();
begin
  if FTableDataLink <> nil then
    FTableDataLink.AddChangeNotification(Self, SourceDataChanged);
end;

function TBaseGridTableViewEh.GetTableDataLink: TBaseTableDataLinkEh;
begin
  Result := FTableDataLink;
end;

function TBaseGridTableViewEh.GetFields: TTableFieldLinkListEh;
begin
  if TableDataLink <> nil then
    Result := TableDataLink.Fields
  else
    Result := nil;
end;

function TBaseGridTableViewEh.GetCanModify: Boolean;
begin
  if (TableDataLink <> nil) then
    Result := TableDataLink.CanModify
  else
    Result := False;
end;

function TBaseGridTableViewEh.GetActive: Boolean;
begin
  if (TableDataLink <> nil) then
    Result := TableDataLink.Active
  else
    Result := False;
end;

function TBaseGridTableViewEh.GetCurrentRow: TTableRowViewEh;
begin
  if (CurrentRowViewIndex >= 0) and
     (CurrentRowViewIndex < FilteredRowList.Count)
  then
    Result := FilteredRowList[CurrentRowViewIndex]
  else
    Result := nil;
end;

function TBaseGridTableViewEh.GetCurrentRowIsEditModified: Boolean;
begin
  if CurrentRowView <> nil
    then Result := CurrentRowView.SourceRowLink.EditModified
    else Result := False;
end;

function TBaseGridTableViewEh.GetAtEndOfRowsList: Boolean;
begin
  if FilteredRowList.Count = 0 then
    Result := True
  else
    Result := CurrentRowViewIndex = FilteredRowList.Count - 1;
end;

function TBaseGridTableViewEh.GetAtStartOfRowsList: Boolean;
begin
  if FilteredRowList.Count = 0 then
    Result := True
  else
    Result := CurrentRowViewIndex <= 0;
end;

function TBaseGridTableViewEh.GetSortOrderStr: String;
begin
  Result := FSortedList.SortOrderStr;
end;

procedure TBaseGridTableViewEh.SetSortOrderStr(const Value: String);
begin
  FSortedList.SortOrderStr := Value;
end;

function TBaseGridTableViewEh.IsListItemMatchFilter(AListItem: TTableRowViewEh): Boolean;
begin
  Result := True;
end;

procedure TBaseGridTableViewEh.MarkPendingData;
begin
  TableDataLink.MarkPendingData();
end;

procedure TBaseGridTableViewEh.ResetPendingData;
begin
  if TableDataLink <> nil then
    TableDataLink.ResetPendingData();
end;

function TBaseGridTableViewEh.GetHasPendingData: Boolean;
begin
  Result := TableDataLink.HasPendingData;
end;

{ TFilteredItemListEh }

constructor TTableRowViewFilteredListEh.Create(ATableView: TBaseGridTableViewEh);
begin
  inherited Create;
  FTableView := ATableView;
  FList := TList<TFilterListItemEh>.Create;
  FFilter := TTableViewFilterEh.Create(Self);
end;

destructor TTableRowViewFilteredListEh.Destroy;
begin
  FreeAndNil(FList);
  FreeAndNil(FFilter);
  inherited Destroy;
end;

function TTableRowViewFilteredListEh.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TTableRowViewFilteredListEh.GetRowView(Index: Integer): TTableRowViewEh;
begin
  Result := FList[Index].RowView;
end;

function TTableRowViewFilteredListEh.IndexOf(ARowView: TTableRowViewEh): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FList.Count - 1 do
  begin
    if FList[I].RowView = ARowView then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TTableRowViewFilteredListEh.IndexOf(ARowLink: TTableRowLinkEh): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FList.Count - 1 do
  begin
    if FList[I].RowView.SourceRowLink = ARowLink then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TTableRowViewFilteredListEh.IsListItemMatchFilter(AListItem: TTableRowViewEh): Boolean;
begin
  if AListItem.SourceRowLink.Editing then
    Result := True
  else
  begin
    Result := Filter.IsListItemMatchFilter(AListItem.SourceRowLink);
    if Result then
      Result := TableView.IsListItemMatchFilter(AListItem);
  end;
end;

procedure TTableRowViewFilteredListEh.SortedListChanged(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; AxisListItem: TTableRowViewEh);
var
  I: Integer;
  hi: Integer;
  ItemAddedIndex: Integer;
  ItemDeleteIndex: Integer;
  ItemChangeIndex: Integer;
  FilterListItem: TFilterListItemEh;
begin
  if AChangedType = TTableLinkEventTypeEh.Reset then
  begin
    UpdateList;
  end
  else if AChangedType = TTableLinkEventTypeEh.RowAdded then
  begin
    if IsListItemMatchFilter(AxisListItem) then
    begin
      ItemAddedIndex := -1;

      for I := 0 to FList.Count - 1 do
      begin
        if FList[I].SortedRowViewIndex >= NewIndex then
        begin
          FList.Insert(I, TFilterListItemEh.Create(AxisListItem, NewIndex));
          ItemAddedIndex := I;
          for hi := ItemAddedIndex + 1 to FList.Count - 1 do
          begin
            FilterListItem := FList[hi];
            FilterListItem.SortedRowViewIndex := FilterListItem.SortedRowViewIndex + 1;
            FList[hi] := FilterListItem;
          end;
          Break;
        end;
      end;

      if ItemAddedIndex = -1 then
      begin
        FList.Add(TFilterListItemEh.Create(AxisListItem, NewIndex));
        ItemAddedIndex := FList.Count - 1;
      end;

      FTableView.FinalListChanged(TTableLinkEventTypeEh.RowAdded, ItemAddedIndex, ItemAddedIndex, AxisListItem);
    end;
  end
  else if AChangedType = TTableLinkEventTypeEh.RowDeleted then
  begin
    ItemDeleteIndex := -1;

    for I := 0 to FList.Count - 1 do
    begin
      if FList[I].SortedRowViewIndex >= NewIndex then
      begin
        if OldIndex = FList[I].SortedRowViewIndex then
        begin
          ItemDeleteIndex := I;
          FList.Delete(ItemDeleteIndex);
        end;

        for hi := I to FList.Count - 1 do
        begin
          FilterListItem := FList[hi];
          FilterListItem.SortedRowViewIndex := FilterListItem.SortedRowViewIndex - 1;
          FList[hi] := FilterListItem;
        end;
        Break;
      end;
    end;

    if ItemDeleteIndex >= 0 then
      FTableView.FinalListChanged(TTableLinkEventTypeEh.RowDeleted, -1, ItemDeleteIndex, AxisListItem);
  end
  else if AChangedType = TTableLinkEventTypeEh.RowChanged then
  begin
    ItemChangeIndex := IndexOf(AxisListItem);
    if ItemChangeIndex >= 0 then
    begin
      if IsListItemMatchFilter(AxisListItem) then
      begin
        FTableView.FinalListChanged(TTableLinkEventTypeEh.RowChanged, NewIndex, ItemChangeIndex, AxisListItem);
      end else
      begin
        FList.Delete(ItemChangeIndex);
        FTableView.FinalListChanged(TTableLinkEventTypeEh.RowDeleted, NewIndex, ItemChangeIndex, AxisListItem);
      end;
    end else
    begin
      if IsListItemMatchFilter(AxisListItem) then
      begin
        ItemAddedIndex := -1;
        for I := 0 to FList.Count - 1 do
        begin
          if FList[I].SortedRowViewIndex > NewIndex then
          begin
            ItemAddedIndex := I;
            FList.Insert(I, TFilterListItemEh.Create(AxisListItem, I));
            Break;
          end;
        end;

        if ItemAddedIndex = -1 then
        begin
          FList.Add(TFilterListItemEh.Create(AxisListItem, NewIndex));
          ItemAddedIndex := FList.Count - 1;
        end;

        FTableView.FinalListChanged(TTableLinkEventTypeEh.RowAdded, ItemAddedIndex, -1, AxisListItem);
      end else
      begin
        
      end;
    end;
  end
  else if AChangedType = TTableLinkEventTypeEh.RowStateChanged then
  begin
    ItemChangeIndex := IndexOf(AxisListItem);
    if ItemChangeIndex >= 0 then
      FTableView.FinalListChanged(TTableLinkEventTypeEh.RowStateChanged, ItemChangeIndex, ItemChangeIndex, AxisListItem);
  end;
end;

procedure TTableRowViewFilteredListEh.InternalClear;
begin
  FList.Clear;
end;

procedure TTableRowViewFilteredListEh.FilterChanged;
begin
  UpdateList;
end;

function SameValues(const AVals, BVals: array of TValue): Boolean;
var
  I: Integer;
begin
  if Length(AVals) <> Length(BVals) then Exit(False);

  for I := 0 to Length(AVals) - 1 do
  begin
    Result := SameValue(AVals[I], BVals[I]);
    if Result = False then Exit(False);
  end;

  Result := True;
end;

function CompareFieldValues(const KeyValues: array of TValue; AListItem: TTableRowViewEh; AFieldList: TList<TTableFieldLinkEh>): Boolean;
var
  I: Integer;
  AListItemValue: array of TValue;
begin
  SetLength(AListItemValue, AFieldList.Count);

  for I := 0 to AFieldList.Count - 1 do
  begin
    AListItemValue[I] := AListItem.SourceRowLink.FieldValue[AFieldList[I]];
  end;

  Result := SameValues(KeyValues, AListItemValue);
end;

function TTableRowViewFilteredListEh.FindItem(const KeyFields: string; const KeyValues: array of TValue): TTableRowViewEh;
var
  I: Integer;
  AListItem: TTableRowViewEh;
  FieldList: TList<TTableFieldLinkEh>;
begin
  FieldList := TList<TTableFieldLinkEh>.Create;

  FTableView.TableDataLink.Fields.GetFieldLinkList(KeyFields, FieldList);
  try
    for I := 0 to Count - 1 do
    begin
      AListItem := ListItem[I];
      if CompareFieldValues(KeyValues, AListItem, FieldList) = True then
        Exit(AListItem);
    end;
  finally
    FieldList.Free;
  end;

  Exit(nil);
end;

procedure TTableRowViewFilteredListEh.UpdateList;
var
  I: Integer;
  AxisListItem: TTableRowViewEh;
begin
  InternalClear;

  if FTableView.TableDataLink <> nil then
  begin
    Filter.Prepare(FTableView.TableDataLink.Fields);

    for I := 0 to FTableView.FSortedList.Count - 1 do
    begin
      AxisListItem := FTableView.FSortedList[I];
      if IsListItemMatchFilter(AxisListItem) then
        FList.Add(TFilterListItemEh.Create(AxisListItem, I));
    end;
  end;

  FTableView.FinalListChanged(TTableLinkEventTypeEh.Reset, -1, -1, nil);
end;

{ TTableRowViewEh }

constructor TTableRowViewEh.Create(ATableView: TBaseGridTableViewEh);
begin
  inherited Create;
  FTableView := ATableView;
end;

destructor TTableRowViewEh.Destroy;
begin
  inherited Destroy;
end;

function TTableRowViewEh.GetEditing: Boolean;
begin
  Result := SourceRowLink.Editing;
end;

function TTableRowViewEh.GetEditState: TRowLinkEditStateEh;
begin
  Result := SourceRowLink.EditState;
end;

procedure TTableRowViewEh.SetSourceRowView(ARowView: TTableRowLinkEh);
begin
  FSourceRowLink := ARowView;
end;

function TTableRowViewEh.GetSourceItem: Pointer;
begin
  if FSourceRowLink <> nil
    then Result := FSourceRowLink.SourceItem
    else Result := nil;
end;

function TTableRowViewEh.GetSourceObjectItem: TObject;
begin
  if FSourceRowLink <> nil
    then Result := FSourceRowLink.SourceObjectItem
    else Result := nil;
end;

{ TDataAxisSourceItemListEh }

constructor TTableRowViewSourceListEh.Create(AGridTableView: TBaseGridTableViewEh);
begin
  inherited Create;
  FGridTableView := AGridTableView;
  FList := TList<TTableRowViewEh>.Create;
end;

destructor TTableRowViewSourceListEh.Destroy;
begin
  Clear;
  FreeAndNil(FList);
  inherited Destroy;
end;

function TTableRowViewSourceListEh.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TTableRowViewSourceListEh.GetItem(Index: Integer): TTableRowViewEh;
begin
  Result := FList[Index];
end;

procedure TTableRowViewSourceListEh.SourceDataChanged(
  AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowView: TTableRowLinkEh);
var
  I: Integer;
  AxisListItem: TTableRowViewEh;
  RowView: TTableRowLinkEh;
begin
  if AChangedType = TTableLinkEventTypeEh.Reset then
  begin
    Clear;
    if FGridTableView.TableDataLink <> nil then
    begin
      for I := 0 to FGridTableView.TableDataLink.Rows.Count - 1 do
      begin
        AxisListItem := FGridTableView.CreateAxisListItemBar();
        RowView := FGridTableView.TableDataLink.Rows[I];
        AxisListItem.SetSourceRowView(RowView);
        FList.Add(AxisListItem);
      end;
    end;

    FGridTableView.BaseItemListChanged(TTableLinkEventTypeEh.Reset, -1, -1, nil);
  end
  else if AChangedType = TTableLinkEventTypeEh.RowAdded then
  begin
    AxisListItem := FGridTableView.CreateAxisListItemBar();
    AxisListItem.SetSourceRowView(ARowView);
    FList.Insert(NewIndex, AxisListItem);
    FGridTableView.BaseItemListChanged(TTableLinkEventTypeEh.RowAdded, NewIndex, OldIndex, AxisListItem);
  end
  else if AChangedType = TTableLinkEventTypeEh.RowDeleted then
  begin
    AxisListItem := FList[OldIndex];
    FList.Delete(OldIndex);
    FGridTableView.BaseItemListChanged(TTableLinkEventTypeEh.RowDeleted, NewIndex, OldIndex, AxisListItem);
    AxisListItem.Free;
  end
  else if AChangedType = TTableLinkEventTypeEh.RowChanged then
  begin
    AxisListItem := FList[NewIndex];
    FGridTableView.BaseItemListChanged(TTableLinkEventTypeEh.RowChanged, NewIndex, OldIndex, AxisListItem);
  end
  else if AChangedType = TTableLinkEventTypeEh.RowStateChanged then
  begin
    AxisListItem := FList[NewIndex];
    FGridTableView.BaseItemListChanged(TTableLinkEventTypeEh.RowStateChanged, NewIndex, OldIndex, AxisListItem);
  end;
end;

procedure TTableRowViewSourceListEh.Clear;
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

{ TDataAxisSortedItemListEh }

constructor TTableRowViewSortedListEh.Create(AGridTableView: TBaseGridTableViewEh);
begin
  inherited Create;
  FGridTableView := AGridTableView;
  FList := TList<TTableRowViewEh>.Create;
  FOrderByList := TOrderByListEh.Create(Self);
end;

destructor TTableRowViewSortedListEh.Destroy;
begin
  FreeAndNil(FList);
  FreeAndNil(FOrderByList);
  inherited Destroy;
end;

function TTableRowViewSortedListEh.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TTableRowViewSortedListEh.GetItem(Index: Integer): TTableRowViewEh;
begin
  Result := FList[Index];
end;

procedure TTableRowViewSortedListEh.BaseListChanged(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; AxisListItem: TTableRowViewEh);
var
  I: Integer;
  NewAxisListItem: TTableRowViewEh;
  SourceRowView: TTableRowLinkEh;
  RowIndex: Integer;
begin
  if AChangedType = TTableLinkEventTypeEh.Reset then
  begin
    Clear;

    for I := 0 to FGridTableView.FBaseList.Count - 1 do
    begin
      NewAxisListItem := FGridTableView.FBaseList[I];
      FList.Add(NewAxisListItem);
    end;

    if ListIsSorted then
      ResortItems;

    FGridTableView.SortedListChanged(TTableLinkEventTypeEh.Reset, -1, -1, nil);
  end
  else if AChangedType = TTableLinkEventTypeEh.RowAdded then
  begin
    if ListIsSorted then
    begin
      if (NewIndex < Count) then
      begin
        SourceRowView := FGridTableView.TableDataLink.Rows[FGridTableView.TableDataLink.CurrentRowIndex + 1];
        RowIndex := IndexOf(SourceRowView);
        FList.Insert(RowIndex, AxisListItem);
        NewIndex := RowIndex;
      end else
      begin
        FList.Insert(NewIndex, AxisListItem);
      end;
    end
    else
    begin
      FList.Insert(NewIndex, AxisListItem);
    end;
    FGridTableView.SortedListChanged(TTableLinkEventTypeEh.RowAdded, NewIndex, OldIndex, AxisListItem);
  end
  else if AChangedType = TTableLinkEventTypeEh.RowDeleted then
  begin
    if ListIsSorted then
    begin
      RowIndex := IndexOf(AxisListItem);
      FList.Delete(RowIndex);
      NewIndex := RowIndex;
      OldIndex := RowIndex;
    end else
    begin
      AxisListItem := FList[OldIndex];
      FList.Delete(OldIndex);
    end;
    FGridTableView.SortedListChanged(TTableLinkEventTypeEh.RowDeleted, NewIndex, OldIndex, AxisListItem);
  end
  else if AChangedType = TTableLinkEventTypeEh.RowChanged then
  begin
    FGridTableView.SortedListChanged(TTableLinkEventTypeEh.RowChanged, NewIndex, OldIndex, AxisListItem);
  end
  else if AChangedType = TTableLinkEventTypeEh.RowStateChanged then
  begin
    AxisListItem := FList[NewIndex];
    FGridTableView.SortedListChanged(TTableLinkEventTypeEh.RowStateChanged, NewIndex, OldIndex, AxisListItem);
  end;
end;

procedure TTableRowViewSortedListEh.Clear;
begin
  FList.Clear;
end;

procedure TTableRowViewSortedListEh.SetSortOrderStr(const Value: String);
begin
  if FSortOrderStr <> Value then
  begin
    FSortOrderStr := Value;
    FOrderByList.ParseOrderByStr(FSortOrderStr);
    ResortItems;
    FGridTableView.SortedListChanged(TTableLinkEventTypeEh.Reset, -1, -1, nil);
    FGridTableView.UpdateCurrentRowIndex(True);
  end;
end;

function TTableRowViewSortedListEh.GetListIsSorted: Boolean;
begin
  Result := FOrderByList.Count > 0;
end;

function TTableRowViewSortedListEh.IndexOf(AListItem: TTableRowViewEh): Integer;
begin
  Result := FList.IndexOf(AListItem);
end;

function TTableRowViewSortedListEh.IndexOf(ARowView: TTableRowLinkEh): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FList.Count - 1 do
  begin
    if FList[I].SourceRowLink = ARowView then
    begin
      Result := I;
      Break;
    end;
  end;
end;

{$IFDEF FPC}
function TTableRowViewSortedListEh.ListItemCompareProc(constref ALeft, ARight: TTableRowViewEh): Integer;
{$ELSE}
function TTableRowViewSortedListEh.ListItemCompareProc(const ALeft, ARight: TTableRowViewEh): Integer;
{$ENDIF}
var
  I: Integer;
  Val1, Val2: TValue;
  FieldViewIndex: Integer;
  VarRel: TVariantRelationship;
begin
  Result := 0;
  for I := 0 to FOrderByList.Count - 1 do
  begin
    FieldViewIndex := FOrderByList[I].FieldLinkIndex;
    Val1 := ALeft.SourceRowLink.Value[FieldViewIndex];
    Val2 := ARight.SourceRowLink.Value[FieldViewIndex];
    VarRel := CompareValue(Val1, Val2);
    case VarRel of
      TVariantRelationship.vrLessThan: Result := -1;
      TVariantRelationship.vrGreaterThan: Result := 1;
    end;

    if FOrderByList[I].IsDesc then
      Result := Result * -1;

    if Result <> 0 then
      Break;
  end;
end;

procedure TTableRowViewSortedListEh.ResortItems;
var
  I: Integer;
  AxisListItem: TTableRowViewEh;
begin
  if ListIsSorted then
  begin
    FList.Sort(TComparer<TTableRowViewEh>.Construct(ListItemCompareProc));
  end else
  begin
    Clear;

    for I := 0 to FGridTableView.FBaseList.Count - 1 do
    begin
      AxisListItem := FGridTableView.FBaseList[I];
      FList.Add(AxisListItem);
    end;
  end;
end;

{ TOrderByListEh }

constructor TOrderByListEh.Create(ASortedItemList: TTableRowViewSortedListEh);
begin
  inherited Create();
  FSortedItemList := ASortedItemList;
  FItemList := TList<TOrderByItemEh>.Create;
end;

destructor TOrderByListEh.Destroy;
begin
  Clear;
  FreeAndNil(FItemList);
  inherited Destroy;
end;

function TOrderByListEh.GetToken(const Exp: String; var FromIndex: Integer): String;
var
  Chars: TSysCharSet;
begin
  Result := '';
  if FromIndex > Length(Exp) then Exit;
  while Exp[FromIndex] = ' ' do
  begin
    Inc(FromIndex);
    if FromIndex > Length(Exp) then Exit;
  end;
  if FromIndex > Length(Exp) then Exit;

{$IFDEF EH_LIB_12}
  if CharInSet(Exp[FromIndex], [',', ';']) then
{$ELSE}
  if Exp[FromIndex] in [',', ';'] then
{$ENDIF}
  begin
    Result := Result + Exp[FromIndex];
    Inc(FromIndex);
    Exit;
  end;
  if Exp[FromIndex] = '[' then
  begin
    Chars := [#0, ']'];
    Inc(FromIndex);
  end else
    Chars := [#0, ' ', ',', ';'];
  while not CharInSetEh(Exp[FromIndex], Chars) do
  begin
    Result := Result + Exp[FromIndex];
    Inc(FromIndex);
    if FromIndex > Length(Exp) then Break;
  end;
  if (FromIndex <= Length(Exp)) and (Exp[FromIndex] = ']') then
    Inc(FromIndex);
end;

function TOrderByListEh.FindFieldIndex(const FieldName: String): Integer;
var
  FieldsView: TTableFieldLinkListEh;
begin
  FieldsView := FSortedItemList.FGridTableView.Fields;
  Result := FieldsView.IndexOf(FieldName);
end;

procedure TOrderByListEh.ParseOrderByStr(const OrderByStr: String);
var
  FieldName, Token: String;
  FromIndex: Integer;
  Desc: Boolean;
  OByItem: TOrderByItemEh;
  FieldIndex: Integer;
  i: Integer;
  OrderByList: TList<TOrderByItemEh>;
begin
  OrderByList := TList<TOrderByItemEh>.Create;
  try
    FromIndex := 1;
    FieldName := GetToken(OrderByStr, FromIndex);
    if FieldName = '' then
    begin
      Clear;
      Exit;
    end;

    FieldIndex := FindFieldIndex(FieldName);
    if FieldIndex = -1 then
      raise Exception.Create(' Field - "' + FieldName + '" not found.');
    Desc := False;
    while True do
    begin
      Token := GetToken(OrderByStr, FromIndex);
      if AnsiUpperCase(Token) = 'ASC' then
        Continue
      else if AnsiUpperCase(Token) = 'DESC' then
      begin
        Desc := True;
        Continue
      end else if (Token = ';') or (Token = ',') or (Token = '') then
      
      else
        raise Exception.Create(' Invalid token - "' + Token + '"');

      OByItem := TOrderByItemEh.Create;
      OByItem.FFieldViewIndex := FieldIndex;
      OByItem.FFieldLink := FSortedItemList.FGridTableView.Fields[FieldIndex];
      OByItem.FIsDesc := Desc;

      OrderByList.Add(OByItem);

      FieldName := GetToken(OrderByStr, FromIndex);
      if FieldName = '' then Break;
      FieldIndex := FindFieldIndex(FieldName);
      if FieldIndex = -1 then
        raise Exception.Create(' Field - "' + FieldName + '" not found.');
      Desc := False;
    end;

    Clear;

    for i := 0 to OrderByList.Count-1 do
      FItemList.Add(OrderByList[i]);

  finally
    OrderByList.Free;
  end;
end;

function TOrderByListEh.GetItem(Index: Integer): TOrderByItemEh;
begin
  Result := FItemList[Index];
end;

procedure TOrderByListEh.Clear;
var
  i: Integer;
begin
  for i := 0 to Count-1 do
  begin
    FItemList[i].Free;
    FItemList[i] := nil;
  end;
  FItemList.Clear;
end;

function TOrderByListEh.GetCount: Integer;
begin
  Result := FItemList.Count;
end;

{ TFilterListItemEh }

constructor TFilterListItemEh.Create(ARowView: TTableRowViewEh; ASortedRowViewIndex: Integer);
begin
  RowView := ARowView;
  SortedRowViewIndex := ASortedRowViewIndex;
end;

end.

