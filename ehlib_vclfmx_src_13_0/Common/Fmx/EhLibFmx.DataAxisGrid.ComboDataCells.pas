{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{           EhLibFmx.DataAxisGrid.ComboDataCells        }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataAxisGrid.ComboDataCells;

interface

{$SCOPEDENUMS ON}

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, System.Types,
  System.Variants, Data.DB,
  System.Generics.Collections, Rtti,
  FMX.Graphics, System.UITypes, FMX.StdCtrls, FMX.TextLayout, FMX.ImgList,
  FMX.Objects, FMX.Forms,
  EhLibUtils, DBUtilsEh,
  EhLib.TableLink.TypedLists,
  EhLib.TableLinks,
  EhLib.TableLink.Db,
  DefaultDataSourcesEh,
  EhLibFmx.ToolControls,
  EhLibFmx.ImageReses,

  EhLibFmx.Grids,
  EhLibFmx.Grid.Types,
  EhLibFmx.Grid.CellManagers,
  EhLibFmx.Grid.InplaceEditors,

  EhLibFmx.DataAxisGrids,
  EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.DataAxisGrid.DataCells,

  EhLibFmx.Platform,
  EhLibFmx.Types,
  EhLibFmx.LaHostVirtualPanels,
  EhLibFmx.LaObjects,
  EhLibFmx.LaControls,
  EhLibFmx.LaGridPanels,
  EhLibFmx.LaPanels,
  EhLibFmx.Grid.ToolControls;

type

  TDataAxisGridComboboxCellEh = class;
  TKeyDisplayStringPairEh = class;

{ TBaseDataAxisGridComboDropDownBoxEh }

  TBaseDataAxisGridComboDropDownBoxEh = class(TComponent)
  private
    FWidth: Integer;
    FVisibleRowCount: Integer;
    FResizable: Boolean;

    procedure SetResizable(const Value: Boolean);
    procedure SetVisibleRowCount(const Value: Integer);
    procedure SetWidth(const Value: Integer);

  protected
    function GetOwner: TPersistent; override;

    procedure Changed(); virtual;
    procedure HandleDataCellGetStyleParams(Params: TDataAxisCellStyleParamsEh); virtual;
    procedure HandleCreateCellContent(Params: TBaseGridCreateCellContentParamsEh); virtual;
    procedure HandleInitDataCellContent(Params: TPersistent); virtual;
    procedure HandleGetDataCellManager(Params: TPersistent); virtual;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;

    function GetNamePath: string; override;

  published
    property Resizable: Boolean read FResizable write SetResizable default True;
    property Width: Integer read FWidth write SetWidth default 0;
    property VisibleRowCount: Integer read FVisibleRowCount write SetVisibleRowCount default 24;
  end;

{ TDataAxisGridComboboxCellManagerEh }

  TDataAxisGridComboboxCellManagerEh = class(TDataAxisTextCellManagerEh)
  private
    FListItems: TStrings;
    FListItemsContainsPipe: Boolean;
    FListSource: TComponent;
    FListKeyFieldName: String;
    FListFieldName: String;
    FTableDataLink: TBaseTableDataLinkEh;
    FListItemsDataLink: TBaseTableDataLinkEh;
    FItemsList: TObjectList<TKeyDisplayStringPairEh>;

    FDropDownBox: TBaseDataAxisGridComboDropDownBoxEh;
    FPopup: TPopup;
    FPopupGrid: TControl;
    FGridColumn: TFieldBarEh;

    function GetIsLookupMode: Boolean;
    function GetDropDownBox: TBaseDataAxisGridComboDropDownBoxEh;
    function GetListItems: TStrings;

    procedure AddSourceChangeNotification;
    procedure RemoveSourceChangeNotification();
    procedure Reset;
    procedure SetDropDownBox(const Value: TBaseDataAxisGridComboDropDownBoxEh);
    procedure SetListItems(const Value: TStrings);
    procedure SetListFieldName(const Value: String);
    procedure SetListKeyFieldName(const Value: String);
    procedure SetListSource(const Value: TComponent);
    procedure SourceDataChanged(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowView: TTableRowLinkEh);
    function GetListSourceOrigin: TListSourceOriginEh;
    procedure ListItemsChanged(Sender: TObject);

  protected
    FFormChangedSize: TSizeF;

    function CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh; override;

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    constructor Create(AOwner: TComponent; ABoundFieldBar: TFieldBarEh; ADropDownBox: TBaseDataAxisGridComboDropDownBoxEh); reintroduce; overload;
    destructor Destroy; override;

    function GetDefaultDisplayText(const VarValue: TValue): String; override;

    procedure DefaultInitCellEditor(AInitEditorParams: TBaseGridInitEditorParamsEh); override;
    procedure DefaultInitCellContent(Params: TBaseGridInitCellContentParamsEh); override;
    procedure DefaultInitCell(Params: TBaseGridInitCellParamsEh); override;
    procedure ReleasePopupGrid(APopupGrid: TControl);

    function GetLookupDisplayText(const VarValue: TValue): String; virtual;
    function LookupKeyValueForDisplayValue(const DisplayValue: TValue): TValue; virtual;
    function FindDisplayTextByStr(const Str: String; const PartialKey, CaseInsensitive: Boolean; var DisplayText: String): Boolean;
    function CapturePopupGrid(APlacementTarget: TControl; APopupParent: TFmxObject; AComboDataCell: TDataAxisGridComboboxCellEh): TControl;
    function ActualTableDataLink(): TBaseTableDataLinkEh;
    function ActualListFieldName(): String;
    function ActualListKeyFieldName(): String;

    property IsLookupMode: Boolean read GetIsLookupMode;
    property ListTableDataLink: TBaseTableDataLinkEh read FTableDataLink;
    property ListSourceOrigin: TListSourceOriginEh read GetListSourceOrigin;

  published
    property ListItems: TStrings read GetListItems write SetListItems;
    property ListSource: TComponent read FListSource write SetListSource;
    property ListFieldName: String read FListFieldName write SetListFieldName;
    property ListKeyFieldName: String read FListKeyFieldName write SetListKeyFieldName;
    property DropDownBox: TBaseDataAxisGridComboDropDownBoxEh read GetDropDownBox write SetDropDownBox;
  end;

{ TDataAxisGridComboboxCellEh }

  TDataAxisGridComboboxCellEh = class(TDataAxisTextCellEh)
  private
    FDropDownWidth: Integer;
    FDropDownCount: Integer;
    FDropDownResizable: Boolean;
    FPopupGrid: TControl;
    function GetDropDownBoxVisible: Boolean;
    function GetCellManager: TDataAxisGridComboboxCellManagerEh;
    procedure SetDropDownResizable(const Value: Boolean);
  protected
    FButtonImage: TImage;
    FFilterButton: TLaButtonEh;

    procedure CreateRightStackControls(AStackPanel: TLaStackPanelEh); override;
    procedure FilterButtonMouseDown(Sender: TObject; Params: TControlMouseButtonParamsEh); virtual;
    procedure ToggleDropDownBox(); virtual;
    procedure CalcPopupSize(APopup: TPopup); virtual;
    procedure FormResize(Sender: TObject); virtual;
  public
    constructor Create(ACellHolder: TGridBaseCellHolderEh);
    destructor Destroy; override;

    function GetInplaceEditClass: TInplaceEditClass; override;
    function FindDisplayTextByStr(const Str: String; const PartialKey: Boolean; const CaseInsensitive: Boolean; var DisplayText: String): Boolean;

    procedure CloseDropDownBox(AcceptValue: Boolean);
    procedure ShowDropDownBox();
    procedure CapturePopupGrid();

    property CellManager: TDataAxisGridComboboxCellManagerEh read GetCellManager;

    property DropDownBoxVisible: Boolean read GetDropDownBoxVisible;
    property FilterButton: TLaButtonEh read FFilterButton;
    property DropDownCount: Integer  read FDropDownCount write FDropDownCount;
    property DropDownWidth: Integer  read FDropDownWidth write FDropDownWidth;
    property DropDownResizable: Boolean read FDropDownResizable write SetDropDownResizable default True;
  end;

{ TKeyDisplayStringPairEh }

  TKeyDisplayStringPairEh = class(TPersistent)
  private
    FKeyValue: String;
    FDisplayValue: String;
  public
    constructor Create; overload;
    constructor Create(AKeyValue, ADisplayValue: String); overload;

    property KeyValue: String read FKeyValue write FKeyValue;
    property DisplayValue: String read FDisplayValue write FDisplayValue;
  end;

implementation

uses EhLibFmx.DataGrid.Rows,
     EhLibFmx.DataGrid.Columns,
     EhLibFmx.CustomDataGrids,
     EhLibFmx.DataGrids;

type
  TCustomDataGridEhCrack = class(TCustomDataGridEh);
  TPopupCrack = class(TPopup);

type

{ TPopupDataGridEh }

  TPopupDataGridEh = class(TCustomDataGridEh)
  protected
    FComboDataCell: TDataAxisGridComboboxCellEh;
    FPopupOwner: TPopup;

    procedure HandleDataCellMouseClickEvent(Params: TGridCellMouseButtonParamsEh); override;
    procedure HandleDataCellGetStyleParams(Params: TDataAxisCellStyleParamsEh); override;
    procedure CellMouseMove(ACellMan: TBaseGridCellManagerEh; CellParams: TGridCellMouseParamsEh); override;
  public
    function LocateDisplayText(const DisplayText: String): Boolean;

    constructor Create(APopupOwner: TPopup); reintroduce; virtual;
    destructor Destroy; override;

    property PopupOwner: TPopup read FPopupOwner write FPopupOwner;
    property ComboDataCell: TDataAxisGridComboboxCellEh read FComboDataCell write FComboDataCell;
  end;

{ TDataGridComboInplaceEdit }

  TDataGridComboInplaceEdit = class(TDBAxisGridInplaceEdit)
  private
    function GetCell: TDataAxisGridComboboxCellEh;

  protected
    procedure KeyDown(var Key: Word; var KeyChar: Char; Shift: TShiftState); override;
    procedure DialogKey(var Key: Word; Shift: TShiftState); override;
    procedure VisibleChanged; override;
    procedure AncestorVisibleChanged(const Visible: Boolean); override;
    procedure UserTextChanged; override;

    function LocateStr(const Str: String; const PartialKey: Boolean; const CaseInsensitive: Boolean): Boolean;
    function FindDisplayTextByStr(const Str: String; const PartialKey: Boolean; const CaseInsensitive: Boolean; var DisplayText: String): Boolean;

    function ProcessSearchStr(const Str: String): Boolean; virtual;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;

    property Cell: TDataAxisGridComboboxCellEh read GetCell;
  end;

{ TPopupDataGridColumnEh }

  TPopupDataGridColumnEh = class(TDataGridBaseColumnEh)
  protected
    procedure HandleCreateCellContent(Params: TBaseGridCreateCellContentParamsEh); override;
    procedure HandleDataCellInitContent(Params: TBaseGridInitCellContentParamsEh); override;
    procedure HandleGetDataCellManager(Params: TBaseDataGridGetDataCellManagerParamsEh); override;
  end;

{$REGION 'TPopupDataGridEh'}

{ TPopupDataGridEh }

constructor TPopupDataGridEh.Create(APopupOwner: TPopup);
begin
  inherited Create(APopupOwner);
  Parent := APopupOwner;
  FPopupOwner := APopupOwner;
  AutoGenerateColumns := False;
  IndicatorColumn.Visible := False;
  Title.Visible := False;
  CanFocus := False;
  GridLineOptions.HorzLinesVisible := False;
end;

destructor TPopupDataGridEh.Destroy;
begin
  inherited Destroy;
end;

procedure TPopupDataGridEh.CellMouseMove(ACellMan: TBaseGridCellManagerEh;
  CellParams: TGridCellMouseParamsEh);
var
  DataRowIndex: Integer;
begin
  inherited CellMouseMove(ACellMan, CellParams);
  if FMoveAndScrollService.Active then Exit;

  DataRowIndex := RawToDataRowIndex(CellParams.RowIndex);
  if (DataRowIndex >= 0) and (DataRowIndex < VisibleRows.Count) then
    CurrentRowIndex := DataRowIndex;
end;

procedure TPopupDataGridEh.HandleDataCellGetStyleParams(Params: TDataAxisCellStyleParamsEh);
begin
  inherited HandleDataCellGetStyleParams(Params);
  if (FComboDataCell <> nil) then
    FComboDataCell.CellManager.DropDownBox.HandleDataCellGetStyleParams(Params);
end;

procedure TPopupDataGridEh.HandleDataCellMouseClickEvent(Params: TGridCellMouseButtonParamsEh);
begin
  inherited HandleDataCellMouseClickEvent(Params);
  if (FComboDataCell <> nil) then
  begin
    FComboDataCell.CloseDropDownBox(True);
  end;
end;

function TPopupDataGridEh.LocateDisplayText(const DisplayText: String): Boolean;
var
  Row: TDataGridRowEh;
  I: Integer;
  Col: TDataGridBaseColumnEh;
  Str: String;
  FoundRow: TDataGridRowEh;
begin
  Result := False;
  FoundRow := nil;
  Col := StaticColumns[0];
  for I := 0 to VisibleRows.Count - 1 do
  begin
    Row := VisibleRows[I];
    Str := Col.GetRowDisplayText(Row);
    if SameStr(DisplayText, Str) then
    begin
      FoundRow := Row;
      Break;
    end;
  end;

  if FoundRow <> nil then
    Result := True;
  CurrentRow := FoundRow;
end;

{$ENDREGION}

{$REGION 'TDataAxisGridComboboxCellManagerEh'}

constructor TDataAxisGridComboboxCellManagerEh.Create(AOwner: TComponent);
var
  VGrid: TCustomDataGridEhCrack;
  VGridColumn: TDataGridBaseColumnEh;
begin
  inherited Create(AOwner);
  FFormChangedSize := TSizeF.Create(-1, -1);
  if FDropDownBox = nil then
    FDropDownBox := TBaseDataAxisGridComboDropDownBoxEh.Create(Self);
  FListItems := TStringList.Create;
  TStringList(FListItems).OnChange := ListItemsChanged;

  FListItemsDataLink := TListTableLinkEh<TKeyDisplayStringPairEh>.Create(nil);
  FItemsList := TObjectList<TKeyDisplayStringPairEh>.Create(True);
  TListTableLinkEh<TKeyDisplayStringPairEh>(FListItemsDataLink).SetList(FItemsList);

  FPopup := TPopup.Create(Self);
  FPopup.StyleLookup := 'ComboPopupStyle';
  FPopup.Stored := False;
  FPopup.Locked := True;
  FPopup.DragWithParent := False;
  FPopup.Width := 240;
  FPopup.Height := 620;
  FPopup.BorderWidth := 0;

  FPopupGrid := TPopupDataGridEh.Create(FPopup);
  FPopupGrid.Stored := False;
  FPopupGrid.Align := TAlignLayout.Client;
  FPopupGrid.Margins.Rect := RectF(1, 1, 1, 1);
  VGrid := TCustomDataGridEhCrack(FPopupGrid);
  VGrid.Border.Style := TBorderStyle.None;
  VGrid.ColumnOptions.AllowShowEditor := False;

  VGridColumn := TPopupDataGridColumnEh.Create(Self);
  VGridColumn.ColSizeUnit := TGridColSizeUnitEh.Weight;
  VGrid.StaticColumns.Add(VGridColumn);
  FGridColumn := VGridColumn;
end;

constructor TDataAxisGridComboboxCellManagerEh.Create(AOwner: TComponent; ABoundFieldBar: TFieldBarEh;
  ADropDownBox: TBaseDataAxisGridComboDropDownBoxEh);
begin
  FDropDownBox := ADropDownBox;
  inherited Create(AOwner, ABoundFieldBar);
end;

destructor TDataAxisGridComboboxCellManagerEh.Destroy;
begin
  FreeAndNil(FListItems);
  FreeAndNil(FListItemsDataLink);
  FreeAndNil(FItemsList);
  inherited Destroy;
end;

function TDataAxisGridComboboxCellManagerEh.GetDefaultDisplayText(const VarValue: TValue): String;
begin
  if IsLookupMode then
    Result := GetLookupDisplayText(VarValue)
  else
    Result := inherited GetDefaultDisplayText(VarValue);
end;

function TDataAxisGridComboboxCellManagerEh.CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh;
begin
  Result := TDataAxisGridComboboxCellEh.Create(ACellHolder);
end;

procedure TDataAxisGridComboboxCellManagerEh.DefaultInitCell(Params: TBaseGridInitCellParamsEh);
var
  ComboboxCell: TDataAxisGridComboboxCellEh;
  VGrid: TCustomDataGridEhCrack;
begin
  inherited DefaultInitCell(Params);
  ComboboxCell := Params.Cell as TDataAxisGridComboboxCellEh;
  ComboboxCell.DropDownCount := DropDownBox.VisibleRowCount;
  ComboboxCell.DropDownWidth := DropDownBox.Width;
  ComboboxCell.DropDownResizable := DropDownBox.Resizable;

  VGrid := TCustomDataGridEhCrack(Params.Cell.Grid);
  if (Params.Cell.RowIndex = VGrid.CurRowIndex) or
     (Params.Cell.RowIndex = VGrid.FHotTrackCell.Y)
  then
    ComboboxCell.FilterButton.IsButtonBackVisible := True
  else
    ComboboxCell.FilterButton.IsButtonBackVisible := False;
end;

procedure TDataAxisGridComboboxCellManagerEh.DefaultInitCellContent(Params: TBaseGridInitCellContentParamsEh);
begin
  inherited DefaultInitCellContent(Params);
end;

procedure TDataAxisGridComboboxCellManagerEh.DefaultInitCellEditor(AInitEditorParams: TBaseGridInitEditorParamsEh);
var
  InplaceTextEdit: TLaInplaceTextEdit;
begin
  inherited DefaultInitCellEditor(AInitEditorParams);

  if (AInitEditorParams.Editor is TLaInplaceTextEdit) then
  begin
    InplaceTextEdit := TLaInplaceTextEdit(AInitEditorParams.Editor);
    if IsLookupMode then
      InplaceTextEdit.ReadOnly := True;
  end;
end;

function TDataAxisGridComboboxCellManagerEh.GetIsLookupMode: Boolean;
begin
  if ListSourceOrigin = TListSourceOriginEh.ListSource then
  begin
    if ListKeyFieldName <> ''
      then Result := True
      else Result := False;
  end else
  begin
    if FListItemsContainsPipe
      then Result := True
      else Result := False;
  end;
end;

procedure TDataAxisGridComboboxCellManagerEh.SetListFieldName(const Value: String);
begin
  FListFieldName := Value;
  FGridColumn.FieldName := Value;
end;

procedure TDataAxisGridComboboxCellManagerEh.SetListKeyFieldName(const Value: String);
begin
  FListKeyFieldName := Value;
end;

function TDataAxisGridComboboxCellManagerEh.GetDropDownBox: TBaseDataAxisGridComboDropDownBoxEh;
begin
  Result := FDropDownBox;
end;

procedure TDataAxisGridComboboxCellManagerEh.SetDropDownBox(const Value: TBaseDataAxisGridComboDropDownBoxEh);
begin
  FDropDownBox.Assign(Value);
end;

function TDataAxisGridComboboxCellManagerEh.GetListItems: TStrings;
begin
  Result := FListItems;
end;

procedure TDataAxisGridComboboxCellManagerEh.SetListItems(const Value: TStrings);
begin
  FListItems.Assign(Value);
end;

procedure TDataAxisGridComboboxCellManagerEh.RemoveSourceChangeNotification();
begin
  if FTableDataLink <> nil then
    FTableDataLink.RemoveChangeNotification(Self);
end;

function TDataAxisGridComboboxCellManagerEh.ActualListFieldName: String;
begin
  if ListSourceOrigin = TListSourceOriginEh.ListSource then
    Result := ListFieldName
  else
    Result := 'DisplayValue';
end;

function TDataAxisGridComboboxCellManagerEh.ActualListKeyFieldName: String;
begin
  if ListSourceOrigin = TListSourceOriginEh.ListSource then
    Result := ListKeyFieldName
  else
    Result := 'KeyValue';
end;

function TDataAxisGridComboboxCellManagerEh.ActualTableDataLink: TBaseTableDataLinkEh;
begin
  if ListSourceOrigin = TListSourceOriginEh.ListSource then
    Result := FTableDataLink
  else
    Result := FListItemsDataLink;
end;

procedure TDataAxisGridComboboxCellManagerEh.AddSourceChangeNotification();
begin
  if FTableDataLink <> nil then
    FTableDataLink.AddChangeNotification(Self, SourceDataChanged);
end;

procedure TDataAxisGridComboboxCellManagerEh.SourceDataChanged(AChangedType: TTableLinkEventTypeEh;
  NewIndex, OldIndex: Integer; ARowView: TTableRowLinkEh);
begin

end;

procedure TDataAxisGridComboboxCellManagerEh.Reset;
var
  VGrid: TPopupDataGridEh;
begin
  VGrid := FPopupGrid as TPopupDataGridEh;
  VGrid.DataSource := ActualTableDataLink();
  FGridColumn.FieldName := ActualListFieldName();
end;

procedure TDataAxisGridComboboxCellManagerEh.SetListSource(const Value: TComponent);
var
 ADataSource: TDataSource;
begin
  if Value = FListSource then Exit;

  if Value = nil then
  begin
    RemoveSourceChangeNotification();
    FListSource := nil;
    FTableDataLink := nil;
    AddSourceChangeNotification();
    Reset();
  end
  else if Value is TBaseTableDataLinkEh then
  begin
    RemoveSourceChangeNotification();
    FListSource := Value;
    FTableDataLink := Value as TBaseTableDataLinkEh;
    AddSourceChangeNotification();
    Reset();
  end
  else if Value is TDataSource then
  begin
    RemoveSourceChangeNotification();
    FTableDataLink := GetDefaultTableDataLinkForDataSource(TDataSource(Value));
    FListSource := Value;
    AddSourceChangeNotification();
    Reset();
  end
  else if Value is TDataSet then
  begin
    RemoveSourceChangeNotification();
    ADataSource  := GetDefaultDataSourceForDataSet(TDataSet(Value));
    FTableDataLink := GetDefaultTableDataLinkForDataSource(ADataSource);
    FListSource := Value;
    AddSourceChangeNotification();
    Reset();
  end else
  begin
    raise Exception.Create('DataSource of ' + Value.ClassName + ' is not supported.');
  end;

  if (Value <> nil) then
    Value.FreeNotification(Self);
end;

procedure TDataAxisGridComboboxCellManagerEh.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if Operation = opRemove then
  begin
    if AComponent = FListSource then
      ListSource := nil;
  end;
end;

procedure TDataAxisGridComboboxCellManagerEh.ListItemsChanged(Sender: TObject);
var
  I: Integer;
  S, SKey, SDisplay: String;
  SArr: TArray<string>;
begin
  FItemsList.Clear;
  if (ListItems.Count > 0) and (ListItems[0].Contains('|'))
    then FListItemsContainsPipe := True
    else FListItemsContainsPipe := False;

  for I := 0 to ListItems.Count - 1 do
  begin
    S := ListItems[I];
    if FListItemsContainsPipe then
    begin
      SArr := S.Split(['|']);
      if Length(SArr) > 0
        then SKey := SArr[0]
        else SKey := '';
      if Length(SArr) > 1
        then SDisplay := SArr[1]
        else SDisplay := '';
    end else
    begin
      SKey := '';
      SDisplay := S;
    end;
    FItemsList.Add(TKeyDisplayStringPairEh.Create(SKey, SDisplay));
  end;

  TListTableLinkEh<TKeyDisplayStringPairEh>(FListItemsDataLink).SetList(FItemsList);
  Reset();
end;

function TDataAxisGridComboboxCellManagerEh.LookupKeyValueForDisplayValue(const DisplayValue: TValue): TValue;
var
  Row: TTableRowLinkEh;
  DisplayFieldValue: TValue;
  KeyFieldLink: TTableFieldLinkEh;
  DisplayFieldLink: TTableFieldLinkEh;
  TableDataLink: TBaseTableDataLinkEh;
begin
  Result := TValue.Empty;
  TableDataLink := ActualTableDataLink();
  if TableDataLink <> nil then
  begin
    KeyFieldLink := TableDataLink.Fields.FindField(ActualListKeyFieldName);
    DisplayFieldLink := TableDataLink.Fields.FindField(ActualListFieldName);
    for Row in TableDataLink.Rows do
    begin
      DisplayFieldValue := Row.FieldValue[DisplayFieldLink];
      if SameValue(DisplayFieldValue, DisplayValue) then
      begin
        Result := Row.FieldValue[KeyFieldLink];
        Exit;
      end;
    end;
  end;
end;

function TDataAxisGridComboboxCellManagerEh.FindDisplayTextByStr(const Str: String; const PartialKey,
  CaseInsensitive: Boolean; var DisplayText: String): Boolean;
var
  Row: TTableRowLinkEh;
  DisplayFieldValue: TValue;
  DisplayFieldLink: TTableFieldLinkEh;
  DisplayFieldText, FieldTextToCompare: String;
  TableDataLink: TBaseTableDataLinkEh;
begin
  Result := False;
  TableDataLink := ActualTableDataLink();
  if TableDataLink <> nil then
  begin
    DisplayFieldLink := TableDataLink.Fields.FindField(ActualListFieldName);
    for Row in TableDataLink.Rows do
    begin
      DisplayFieldValue := Row.FieldValue[DisplayFieldLink];
      DisplayFieldText := ValueToString(DisplayFieldValue);

      if PartialKey = True then
        FieldTextToCompare := TextCopy(DisplayFieldText, 1, Length(Str))
      else
        FieldTextToCompare := DisplayFieldText;

      if CaseInsensitive then
        Result := SameText(FieldTextToCompare, Str)
      else
        Result := SameStr(FieldTextToCompare, Str);

      if Result = True then
      begin
        DisplayText := DisplayFieldText;
        Exit;
      end;
    end;
  end;
end;

function TDataAxisGridComboboxCellManagerEh.GetListSourceOrigin: TListSourceOriginEh;
begin
  if ListSource <> nil
    then Result := TListSourceOriginEh.ListSource
    else Result := TListSourceOriginEh.ListItems;
end;

function TDataAxisGridComboboxCellManagerEh.GetLookupDisplayText(const VarValue: TValue): String;
var
  Row: TTableRowLinkEh;
  FieldValue, DisplayFieldValue: TValue;
  KeyFieldLink: TTableFieldLinkEh;
  DisplayFieldLink: TTableFieldLinkEh;
  TableDataLink: TBaseTableDataLinkEh;
begin
  Result := '';
  TableDataLink := ActualTableDataLink();
  if TableDataLink <> nil then
  begin
    KeyFieldLink := TableDataLink.Fields.FindField(ActualListKeyFieldName);
    DisplayFieldLink := TableDataLink.Fields.FindField(ActualListFieldName);
    for Row in TableDataLink.Rows do
    begin
      FieldValue := Row.FieldValue[KeyFieldLink];
      if SameValue(FieldValue, VarValue) then
      begin
        DisplayFieldValue := Row.FieldValue[DisplayFieldLink];
        Result := ValueToString(DisplayFieldValue);
        Exit;
      end;
    end;
  end;
end;

procedure TDataAxisGridComboboxCellManagerEh.ReleasePopupGrid(APopupGrid: TControl);
var
  VGrid: TPopupDataGridEh;
begin
  VGrid := FPopupGrid as TPopupDataGridEh;
  if VGrid.ComboDataCell <> nil then
  begin
    if VGrid.PopupOwner.IsOpen = True then
      VGrid.ComboDataCell.CloseDropDownBox(False);
    VGrid.PopupOwner.PlacementTarget := nil;
    VGrid.PopupOwner.Parent := nil;
    VGrid.ComboDataCell := nil;
  end;
end;

function TDataAxisGridComboboxCellManagerEh.CapturePopupGrid(
  APlacementTarget: TControl; APopupParent: TFmxObject; AComboDataCell: TDataAxisGridComboboxCellEh): TControl;
var
  VGrid: TPopupDataGridEh;
begin
  VGrid := FPopupGrid as TPopupDataGridEh;
  if VGrid.ComboDataCell <> AComboDataCell then
  begin
    ReleasePopupGrid(VGrid);
    VGrid.PopupOwner.PlacementTarget := APlacementTarget;
    VGrid.PopupOwner.Parent := APlacementTarget;
    VGrid.ComboDataCell := AComboDataCell;
  end;

  Result := VGrid;
end;

{$ENDREGION 'TDataAxisGridComboboxCellManagerEh'}

{$REGION 'TDataAxisGridComboboxCellEh'}

{ TDataGridComboboxDataCellEh }

constructor TDataAxisGridComboboxCellEh.Create(ACellHolder: TGridBaseCellHolderEh);
begin
  inherited Create(ACellHolder);
  FDropDownResizable := True;
end;

procedure TDataAxisGridComboboxCellEh.CreateRightStackControls(AStackPanel: TLaStackPanelEh);
begin
  with TLaButtonEh.CreateWith(AStackPanel, AStackPanel) do
  begin
    VertAlignment := TLaVertAlignmentEh.Center;
    Width := 16;
    Height := 18;
    Margins.Rect := TRectF.Create(2, 1, 2, 1);
    OnMouseDown := FilterButtonMouseDown;

    FButtonImage := TImage.Create(Self);
    FButtonImage.WrapMode := TImageWrapMode.Place;
    FButtonImage.MultiResBitmap := EhLibImageResources.DropDownSign;
    FButtonImage.HitTest := False;
    FButtonImage.Locked := True;

    FFilterButton := RefSelf as TLaButtonEh;
    FFilterButton.Content := FButtonImage;
    FFilterButton.StaysPressed := True;
  end;
end;

destructor TDataAxisGridComboboxCellEh.Destroy;
begin
  inherited Destroy;
end;

function TDataAxisGridComboboxCellEh.GetCellManager: TDataAxisGridComboboxCellManagerEh;
begin
  Result := TDataAxisGridComboboxCellManagerEh(inherited CellManager);
end;

procedure TDataAxisGridComboboxCellEh.CapturePopupGrid;
begin
  FPopupGrid := GetCellManager.CapturePopupGrid(Self, Self, Self);
end;

procedure TDataAxisGridComboboxCellEh.FilterButtonMouseDown(Sender: TObject; Params: TControlMouseButtonParamsEh);
var
  VDataGrid: TCustomDataGridEhCrack;
begin
  VDataGrid := TCustomDataGridEhCrack(Grid);
  VDataGrid.ShowEditor();
  if VDataGrid.EditorMode then
    ToggleDropDownBox();
end;

procedure TDataAxisGridComboboxCellEh.SetDropDownResizable(const Value: Boolean);
begin
  FDropDownResizable := Value;
end;

function TDataAxisGridComboboxCellEh.GetDropDownBoxVisible: Boolean;
begin
  if FPopupGrid = nil then
    Result := False
  else
  Result := TPopupDataGridEh(FPopupGrid).PopupOwner.IsOpen;
end;

function TDataAxisGridComboboxCellEh.GetInplaceEditClass: TInplaceEditClass;
begin
  Result := TDataGridComboInplaceEdit;
end;

procedure TDataAxisGridComboboxCellEh.ToggleDropDownBox();
var
  VGrid: TPopupDataGridEh;
begin
  CapturePopupGrid();
  VGrid := TPopupDataGridEh(FPopupGrid);
  if VGrid.PopupOwner.IsOpen then
    CloseDropDownBox(False)
  else
    ShowDropDownBox();
end;

procedure TDataAxisGridComboboxCellEh.CloseDropDownBox(AcceptValue: Boolean);
var
  VGrid: TPopupDataGridEh;
  Value: TValue;
begin
  VGrid := TPopupDataGridEh(FPopupGrid);

  if (AcceptValue = True) and
     (VGrid.CurrentRow <> nil) and
     (ReadOnly = False) then
  begin
    Value := VGrid.Columns[0].GetRowValue(VGrid.CurrentRow);
    TextCellContent.EditorText := ValueToString(Value);
  end;

  VGrid.PopupOwner.IsOpen := False;
end;

procedure TDataAxisGridComboboxCellEh.ShowDropDownBox;
var
  VGrid: TPopupDataGridEh;
begin
  CapturePopupGrid();
  VGrid := TPopupDataGridEh(FPopupGrid);
  VGrid.SizeGripAlwaysShow := DropDownResizable;
  if EditMode
    then VGrid.LocateDisplayText(EditorText)
    else VGrid.LocateDisplayText(Text);

  VGrid.PopupOwner.Placement := TPlacement.Bottom;
  VGrid.PopupOwner.ApplyStyleLookup;
  CalcPopupSize(VGrid.PopupOwner);
  VGrid.PopupOwner.IsOpen := True;
  TCustomPopupForm(TPopupCrack(VGrid.PopupOwner).PopupForm).OnResize := FormResize;
end;

procedure TDataAxisGridComboboxCellEh.CalcPopupSize(APopup: TPopup);
var
  VGrid: TCustomDataGridEhCrack;
  LinesHeight: Integer;
  LinesCount: Integer;
begin
  if CellManager.FFormChangedSize.Width > 0 then
  begin
    APopup.Width := CellManager.FFormChangedSize.Width;
  end else
  begin
    if DropDownWidth = 0 then
      APopup.Width := ActualWidth
    else
      APopup.Width := DropDownWidth;
  end;

  if CellManager.FFormChangedSize.Height > 0 then
  begin
    APopup.Height := CellManager.FFormChangedSize.Height;
  end else
  begin
    VGrid := TCustomDataGridEhCrack(FPopupGrid);
    if DropDownCount > VGrid.TableView.Rows.Count then
      LinesCount := VGrid.TableView.Rows.Count
    else
      LinesCount := DropDownCount;
    LinesHeight := VGrid.DefaultRowHeight * LinesCount;

    APopup.Height := LinesHeight + 2;
  end;
end;

function TDataAxisGridComboboxCellEh.FindDisplayTextByStr(const Str: String; const PartialKey, CaseInsensitive: Boolean;
  var DisplayText: String): Boolean;
begin
 Result := CellManager.FindDisplayTextByStr(Str, PartialKey, CaseInsensitive, DisplayText);
end;

procedure TDataAxisGridComboboxCellEh.FormResize(Sender: TObject);
var
  VGrid: TPopupDataGridEh;
  Form: TCustomPopupForm;
begin
  VGrid := TPopupDataGridEh(FPopupGrid);
  Form := TCustomPopupForm(TPopupCrack(VGrid.PopupOwner).PopupForm);

  CellManager.FFormChangedSize.Width := Form.Width;
  CellManager.FFormChangedSize.Height := Form.Height;
end;

{$ENDREGION 'TDataAxisGridComboboxCellEh'}

{$REGION 'TDataGridComboInplaceEdit'}

{ TDataGridComboInplaceEdit }

constructor TDataGridComboInplaceEdit.Create(Owner: TComponent);
begin
  inherited Create(Owner);
end;

destructor TDataGridComboInplaceEdit.Destroy;
begin
  inherited Destroy;
end;

procedure TDataGridComboInplaceEdit.DialogKey(var Key: Word; Shift: TShiftState);
var
  ComboCell:  TDataAxisGridComboboxCellEh;
  VGrid: TCustomDataGridEhCrack;
begin
  ComboCell := TDataAxisGridComboboxCellEh(Cell);
  VGrid := TCustomDataGridEhCrack(ComboCell.FPopupGrid);
  inherited DialogKey(Key, Shift);
  if ComboCell.DropDownBoxVisible = True then
  begin
    if Key = vkEscape then
    begin
      ComboCell.CloseDropDownBox(False);
      Key := 0;
    end
    else if Key = vkReturn then
    begin
      ComboCell.CloseDropDownBox(True);
      Key := 0;
    end
    else if Key = vkUP then
    begin
      VGrid.Navigation.ToPriorRow;
      Key := 0;
    end
    else if Key = vkDOWN then
    begin
      VGrid.Navigation.ToNextRow;
      Key := 0;
    end
    else if Key = vkNEXT then 
    begin
      VGrid.Navigation.ToNextPage;
      Key := 0;
    end
    else if Key = vkPRIOR then 
    begin
      VGrid.Navigation.ToPriorPage;
      Key := 0;
    end
  end;
end;

function TDataGridComboInplaceEdit.GetCell: TDataAxisGridComboboxCellEh;
begin
  Result := TDataAxisGridComboboxCellEh(inherited Cell);
end;

procedure TDataGridComboInplaceEdit.KeyDown(var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  ComboCell:  TDataAxisGridComboboxCellEh;
begin
  ComboCell := TDataAxisGridComboboxCellEh(Cell);
  if (Key = vkEscape) and (ComboCell.DropDownBoxVisible = True) then
  begin
    ComboCell.CloseDropDownBox(False);
    Key := 0;
  end
  else if (ssAlt in Shift) and ((Key = vkDOWN) or (Key = vkUp)) then
  begin
    ComboCell.ToggleDropDownBox();
    Key := 0;
  end
  else if (Cell.ReadOnly = False) then
  begin
    if (Self.ReadOnly = True) then
    begin
      if Key = vkBack then
      begin
        if SelStart > 0 then
          SelStart := SelStart - 1;
        Key := 0;
      end
      else if KeyChar >= #32 then
      begin
        ProcessSearchStr(KeyChar);
        KeyChar := #0;
      end;
    end
    else
    begin
      if KeyChar >= #32 then
      begin
        if ProcessSearchStr(KeyChar) then
          KeyChar := #0;
      end;
    end;
  end;


  inherited KeyDown(Key, KeyChar,Shift);
end;

function TDataGridComboInplaceEdit.ProcessSearchStr(const Str: String): Boolean;
var
  S, SearchText, RestStr: String;
begin
  if ReadOnly = True then
  begin
    SearchText := TextCopy(Text, 1, SelStart);
    S := SearchText + Str;
  end else
  begin
    SearchText := TextCopy(Text, 1, SelStart);
    RestStr := TextCopy(Text, SelStart + SelLength + 1, Length(Text));
    S := SearchText + Str + RestStr;
  end;

  Result := LocateStr(S, True, True);
end;

function TDataGridComboInplaceEdit.LocateStr(const Str: String; const PartialKey: Boolean;
  const CaseInsensitive: Boolean): Boolean;
var
  FoundText: String;
begin
  Result := FindDisplayTextByStr(Str, PartialKey, CaseInsensitive, FoundText);
  if Result then
  begin
    Text := FoundText;
    SelStart := TextLength(Str);
    SelLength := TextLength(Text) - SelStart;
    CaretPosition := TPoint.Create(TextLength(Str), 0);
  end else
  begin
  end;
end;

procedure TDataGridComboInplaceEdit.UserTextChanged;
var
  VGrid: TPopupDataGridEh;
begin
  inherited UserTextChanged;

  if Cell.DropDownBoxVisible then
  begin
    VGrid := TPopupDataGridEh(Cell.FPopupGrid);
    VGrid.LocateDisplayText(Text);
  end;

end;

function TDataGridComboInplaceEdit.FindDisplayTextByStr(const Str: String; const PartialKey: Boolean;
  const CaseInsensitive: Boolean; var DisplayText: String): Boolean;
begin
  Result := Cell.FindDisplayTextByStr(Str, PartialKey, CaseInsensitive, DisplayText);
end;

procedure TDataGridComboInplaceEdit.VisibleChanged;
begin
  inherited VisibleChanged;
end;

procedure TDataGridComboInplaceEdit.AncestorVisibleChanged(const Visible: Boolean);
var
  ComboCell:  TDataAxisGridComboboxCellEh;
begin
  ComboCell := TDataAxisGridComboboxCellEh(Cell);
  if ComboCell.DropDownBoxVisible = True then
    ComboCell.CloseDropDownBox(False);
  inherited AncestorVisibleChanged(Visible);
end;

{$ENDREGION}

{$REGION 'TBaseDataAxisGridComboDropDownBoxEh'}

{ TBaseDataAxisGridComboDropDownBoxEh }

constructor TBaseDataAxisGridComboDropDownBoxEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetSubComponent(True);
  Name := 'DropDownBox';

  FWidth := 0;
  FVisibleRowCount := 24;
  FResizable := True;
end;

destructor TBaseDataAxisGridComboDropDownBoxEh.Destroy();
begin
  inherited Destroy();
end;

function TBaseDataAxisGridComboDropDownBoxEh.GetNamePath: string;
begin
  Result := inherited GetNamePath;
end;

function TBaseDataAxisGridComboDropDownBoxEh.GetOwner: TPersistent;
begin
  Result := inherited GetOwner;
end;

procedure TBaseDataAxisGridComboDropDownBoxEh.HandleCreateCellContent(Params: TBaseGridCreateCellContentParamsEh);
begin
end;

procedure TBaseDataAxisGridComboDropDownBoxEh.HandleDataCellGetStyleParams(Params: TDataAxisCellStyleParamsEh);
begin
end;

procedure TBaseDataAxisGridComboDropDownBoxEh.HandleGetDataCellManager(Params: TPersistent);
begin
end;

procedure TBaseDataAxisGridComboDropDownBoxEh.HandleInitDataCellContent(Params: TPersistent);
begin
end;

procedure TBaseDataAxisGridComboDropDownBoxEh.Changed();
begin
end;

procedure TBaseDataAxisGridComboDropDownBoxEh.SetResizable(const Value: Boolean);
begin
  if FResizable <> Value then
  begin
    FResizable := Value;
    Changed();
  end;
end;

procedure TBaseDataAxisGridComboDropDownBoxEh.SetVisibleRowCount(const Value: Integer);
begin
  if FVisibleRowCount <> Value then
  begin
    FVisibleRowCount := Value;
    Changed();
  end;
end;

procedure TBaseDataAxisGridComboDropDownBoxEh.SetWidth(const Value: Integer);
begin
  if FWidth <> Value then
  begin
    FWidth := Value;
    Changed();
  end;
end;

{$ENDREGION 'TBaseDataAxisGridComboDropDownBoxEh'}

{$REGION 'TPopupDataGridColumnEh'}

procedure TPopupDataGridColumnEh.HandleCreateCellContent(Params: TBaseGridCreateCellContentParamsEh);
var
  Grid: TPopupDataGridEh;
begin
  Grid := Self.Grid as TPopupDataGridEh;
  if (Grid.FComboDataCell <> nil) then
    Grid.FComboDataCell.CellManager.DropDownBox.HandleCreateCellContent(Params);
end;

procedure TPopupDataGridColumnEh.HandleGetDataCellManager(Params: TBaseDataGridGetDataCellManagerParamsEh);
var
  Grid: TPopupDataGridEh;
begin
  Grid := Self.Grid as TPopupDataGridEh;
  if (Grid.FComboDataCell <> nil) then
    Grid.FComboDataCell.CellManager.DropDownBox.HandleGetDataCellManager(Params);
end;

procedure TPopupDataGridColumnEh.HandleDataCellInitContent(Params: TBaseGridInitCellContentParamsEh);
var
  Grid: TPopupDataGridEh;
begin
  Grid := Self.Grid as TPopupDataGridEh;
  if (Grid.FComboDataCell <> nil) then
    Grid.FComboDataCell.CellManager.DropDownBox.HandleInitDataCellContent(Params);
end;

{$ENDREGION 'TPopupDataGridColumnEh'}

{$REGION 'TKeyDisplayStringPairEh'}

{ TKeyDisplayStringPairEh }

constructor TKeyDisplayStringPairEh.Create(AKeyValue, ADisplayValue: String);
begin
  FKeyValue := AKeyValue;
  FDisplayValue := ADisplayValue;
end;

constructor TKeyDisplayStringPairEh.Create;
begin

end;

{$ENDREGION}

end.
