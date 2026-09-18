{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{               EhLibFmx.DataComboBoxes                 }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataComboBoxes;

{$I ..\Incl\EhLib.Inc}
{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils, System.Classes, System.Types, FMX.Controls, FMX.Graphics,
  System.Rtti, Data.DB, Variants,
  System.Contnrs,
  System.Generics.Collections,
  FMX.Controls.Presentation, FMX.StdCtrls, System.UITypes, FMX.Forms,
  FMX.Objects, FMX.Types, FMX.Platform, FMX.Menus,
  FMX.Edit, FMX.Controls.Model, FMX.BehaviorManager,
  DBUtilsEh, EhLibUtils, DefaultDataSourcesEh,
  EhLib.TableLinks, EhLib.TableLink.TypedLists, EhLib.TableLink.Db,
  EhLibFmx.Platform,
  EhLibFmx.ToolControls,
  EhLibFmx.Grid.Types,
  EhLibFmx.Grid.CellManagers,
  EhLibFmx.LaObjects,
  EhLibFmx.LaControls,
  EhLibFmx.LaPanels,
  EhLibFmx.LaHostVirtualPanels,
  EhLibFmx.CustomDataGrids,
  EhLibFmx.DataAxisGrid.ComboDataCells,
  EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.DataGrid.Rows,
  EhLibFmx.DataGrid.Columns,
  EhLibFmx.Types;

type
  TInsideEditEh = class;
  TPopupDataGridEh = class;
  TFieldDataLinkEh = class;
  TComboDropDownBoxEh = class;

{ TCustomDataComboBoxEh }

  TCustomDataComboBoxEh = class(TStyledControl, ICaret, ITextSettings)
  private
    FInsideEdit: TInsideEditEh;
    FArrowButton: TControl;
    FEditorBoundControl: TControl;
    FListFieldName: String;
    FKeyValue: TValue;
    FListItemsContainsPipe: Boolean;
    FListItems: TStrings;
    FItemsList: TObjectList<TKeyDisplayStringPairEh>;
    FListTableLink: TBaseTableDataLinkEh;
    FListItemsLink: TBaseTableDataLinkEh;
    FListKeyFieldName: String;
    FListSource: TComponent;
    FPopup: TPopup;
    FPopupGrid: TPopupDataGridEh;
    FGridColumn: TFieldBarEh;
    FDataPosting: Boolean;
    FDataLink: TFieldDataLinkEh;
    FInternalListDataChanging: Integer;
    FInternalTextSetting: Boolean;
    FDataFieldName: String;
    FDataFieldsUpdating: Boolean;
    FOnKeyValueChanged: TNotifyEvent;
    FDataSource: TComponent;
    FReadOnly: Boolean;
    FFormChangedSize: TSizeF;
    FDropDownBox: TComboDropDownBoxEh;

    function FindDisplayTextByStr(const Str: String; const PartialKey, CaseInsensitive: Boolean; var DisplayText: String): Boolean;
    function GetDataFieldName: String;
    function GetDataSource: TComponent;
    function GetDropDownBoxVisible: Boolean;
    function GetIsLookupMode: Boolean;
    function GetListItems: TStrings;
    function GetListKeyFieldName: String;
    function GetListSourceOrigin: TListSourceOriginEh;
    function GetReadOnly: Boolean;
    function GetText: string;
    function GetLookupDisplayText(const VarValue: TValue): String;

    procedure AddSourceChangeNotification;
    procedure CapturePopupGrid;
    procedure DoComboMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure ListItemsChanged(Sender: TObject);
    procedure RemoveSourceChangeNotification;
    procedure ResetListData;
    procedure SetDataFieldName(const Value: String);
    procedure SetDataSource(const Value: TComponent);
    procedure SetSelectedValue(const Value: TValue);
    procedure SetListFieldName(const Value: String);
    procedure SetListItems(const Value: TStrings);
    procedure SetListKeyFieldName(const Value: String);
    procedure SetListSource(const Value: TComponent);
    procedure SetReadOnly(const Value: Boolean);
    procedure SetText(const Value: string);
    procedure SourceDataChanged(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowView: TTableRowLinkEh);
    procedure ToggleDropDownBox;
    procedure SetKeyValue(const Value: TValue);

    { ICaret }
    function ICaret.GetObject = GetCaret;
    procedure ShowCaret;
    procedure HideCaret;
    function GetCaret: TCustomCaret;
    procedure SetCaret(const Value: TCustomCaret);

    { ITextSettings }
    function GetDefaultTextSettings: TTextSettings;
    function GetTextSettings: TTextSettings;
    procedure SetTextSettings(const Value: TTextSettings);
    function GetResultingTextSettings: TTextSettings;
    function GetStyledSettings: TStyledSettings;
    procedure SetStyledSettings(const Value: TStyledSettings);

    procedure DataChange(Sender: TObject);
    procedure EditingChange(Sender: TObject);
    procedure InternalUpdateData(Sender: TObject);
    procedure ActiveChange(Sender: TObject);
    procedure DataChanged; virtual;
    procedure SetEditText(const Value: String);
    procedure InternalSetText(const AText: String);
    procedure UpdateDataFields;
    procedure CheckNotCircular;
    function GetDBDataSource: TDataSource;
    procedure UpdateKeyDisplayText;
    procedure InternalSetKeyValue(const VarValue: TValue);
    procedure UpdateTextFromKeyValue;
    procedure UpdateInsideEdit;

    function GetDropDownBox: TComboDropDownBoxEh;
    procedure SetDropDownBox(const Value: TComboDropDownBoxEh);
    function GetCurrentListIndex: Integer;
    function GetSelectedValue: TValue;
    procedure SelectRelativeValue(IsForward: Boolean);

  protected
    function GetDefaultStyleLookupName: string; override;
    function GetDefaultSize: TSizeF; override;

    function CanDropDown(const AButton: TMouseButton; const AShift: TShiftState): Boolean; virtual;
    function IsUnboundMode: Boolean; virtual;
    function EditCanModify: Boolean; virtual;
    function CanModify: Boolean; virtual;

    procedure DoResized; override;
    procedure ApplyStyle; override;
    procedure EditorBoundControlResized(Sender: TObject);

    procedure KeyDown(var Key: Word; var KeyChar: System.WideChar; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; var KeyChar: Char; Shift: TShiftState); override;
    procedure DoEnter; override;
    procedure DoExit; override;

    procedure CloseDropDownBox(AcceptValue: Boolean);
    procedure ShowDropDownBox();
    procedure CalcPopupSize(APopup: TPopup); virtual;
    procedure KeyValueChanged; virtual;

    function InternalListDataChanging: Boolean; virtual;
    procedure BeginInternalListDataChanging;
    procedure EndInternalListDataChanging;
    procedure DoChangeTracking; virtual;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function ActualListTableLink(): TBaseTableDataLinkEh;
    function ActualListFieldName(): String;
    function ActualListKeyFieldName(): String;

    procedure UpdateData;
    procedure SelectAll;
    procedure Clear();
    procedure SelectNextValue();
    procedure SelectPriorValue();

    property DataLink: TFieldDataLinkEh read FDataLink;
    property IsLookupMode: Boolean read GetIsLookupMode;
    property SelectedValue: TValue read GetSelectedValue write SetSelectedValue;

    property DataFieldName: String read GetDataFieldName write SetDataFieldName;
    property DataSource: TComponent read GetDataSource write SetDataSource;
    property DBDataSource: TDataSource read GetDBDataSource;

    property ListFieldName: String read FListFieldName write SetListFieldName;
    property ListItems: TStrings read GetListItems write SetListItems;
    property ListKeyFieldName: String read GetListKeyFieldName write SetListKeyFieldName;
    property ListSource: TComponent read FListSource write SetListSource;
    property ListSourceOrigin: TListSourceOriginEh read GetListSourceOrigin;
    property ListTableDataLink: TBaseTableDataLinkEh read FListTableLink;
    property DropDownBoxVisible: Boolean read GetDropDownBoxVisible;
    property DropDownBox: TComboDropDownBoxEh read GetDropDownBox write SetDropDownBox;

    property ReadOnly: Boolean read GetReadOnly write SetReadOnly;
    property Text: string read GetText write SetText;
    property Caret: TCustomCaret read GetCaret write SetCaret;

  end;

{ TDataComboBoxEh }

  TDataComboBoxEh = class(TCustomDataComboBoxEh)
  published
    property DataFieldName;
    property DataSource;

    property ListFieldName;
    property ListItems;
    property ListKeyFieldName;
    property ListSource;
    property DropDownBox;

    property ReadOnly;

    property Align;
    property Anchors;
    property CanFocus default True;
    property CanParentFocus;
    property DisableFocusEffect;
    property Position;
    property Width;
    property Height;
    property HelpContext;
    property HelpKeyword;
    property HelpType;
    property Hint;
    property StyleLookup;
    property ClipChildren default False;
    property ClipParent default False;
    property Cursor;
    property DragMode default TDragMode.dmManual;
    property EnableDragHighlight default True;
    property Enabled default True;
    property Locked default False;
    property HitTest default True;
    property Padding;
    property Opacity;
    property Margins;
    property PopupMenu;
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property Size;
    property TabOrder;
    property TabStop;
    property TouchTargetExpansion;
    property Visible default True;
    property Caret;
    property ParentShowHint;
    property ShowHint;

    { events }
    property OnApplyStyleLookup;
    { Drag and Drop events }
    property OnDragEnter;
    property OnDragLeave;
    property OnDragOver;
    property OnDragDrop;
    property OnDragEnd;
    { Keyboard events }
    property OnKeyDown;
    property OnKeyUp;
    { Mouse events }
    property OnCanFocus;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnPainting;
    property OnPaint;
    property OnResize;
    property OnResized;

  end;

{ TComboDropDownBoxEh }

  TComboDropDownBoxEh = class(TComponent)
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

{ TInsideEditEh }

  TInsideEditEh = class(TEdit)
  private
    FContentControl: TControl;
    function GetComboBox: TCustomDataComboBoxEh;

  protected
    function DefineModelClass: TDataModelClass; override;
    function GetDefaultStyleLookupName: string; override;

    procedure ApplyStyle; override;
    procedure KeyDown(var Key: Word; var KeyChar: Char; Shift: TShiftState); override;
    procedure DialogKey(var Key: Word; Shift: TShiftState); override;

    function ProcessSearchStr(const Str: String): Boolean; virtual;
    function LocateStr(const Str: String; const PartialKey: Boolean; const CaseInsensitive: Boolean): Boolean;
    function FindDisplayTextByStr(const Str: String; const PartialKey: Boolean; const CaseInsensitive: Boolean; var DisplayText: String): Boolean;

    procedure DoChangeTracking; virtual;

  public
    constructor Create(AOwner: TComponent); override;

    property ComboBox: TCustomDataComboBoxEh read GetComboBox;
  end;

{ TCustomEditModel }

  TInsideEditModel = class(TCustomEditModel)
  private
    function GetInsideEdit: TInsideEditEh;
  protected
    procedure DoChangeTracking; override;
  public
    constructor Create; override;
    destructor Destroy; override;

    property InsideEdit: TInsideEditEh read GetInsideEdit;
  end;

{ TPopupDataGridEh }

  TPopupDataGridEh = class(TCustomDataGridEh)
  private
    FComboBox: TCustomDataComboBoxEh;
    FPopupOwner: TPopup;

  protected
    function HasFocus: Boolean; override;

    procedure HandleDataCellMouseClickEvent(Params: TGridCellMouseButtonParamsEh); override;
    procedure HandleDataCellGetStyleParams(Params: TDataAxisCellStyleParamsEh); override;
    procedure CellMouseMove(ACellMan: TBaseGridCellManagerEh; CellParams: TGridCellMouseParamsEh); override;
  public
    function LocateDisplayText(const DisplayText: String): Boolean;

    constructor Create(APopupOwner: TPopup); reintroduce; virtual;
    destructor Destroy; override;

    property PopupOwner: TPopup read FPopupOwner write FPopupOwner;
    property ComboBox: TCustomDataComboBoxEh read FComboBox write FComboBox;
  end;

{ TPopupDataGridColumnEh }

  TPopupDataGridColumnEh = class(TDataGridBaseColumnEh)
  protected
    procedure HandleCreateCellContent(Params: TBaseGridCreateCellContentParamsEh); override;
    procedure HandleDataCellInitContent(Params: TBaseGridInitCellContentParamsEh); override;
    procedure HandleGetDataCellManager(Params: TBaseDataGridGetDataCellManagerParamsEh); override;
  end;

{ TFieldDataLinkEh }

  TFieldDataLinkEh = class(TDataLink)
  private
    FFields: TFieldsArrEh;
    FFieldName: string;
    FControl: TComponent;
    FOnDataChange: TNotifyEvent;
    FOnEditingChange: TNotifyEvent;
    FOnUpdateData: TNotifyEvent;
    FOnActiveChange: TNotifyEvent;
    FMultiFields: Boolean;
    FIsUnbound: Boolean;
    FEditing: Boolean;
    FModified: Boolean;

    function GetActive: Boolean;
    function GetCanModify: Boolean;
    function GetDataSetActive: Boolean;
    function GetDataSource: TDataSource;
    function GetField: TField;
    function GetFieldsCount: Integer;
    function GetFieldsField(Index: Integer): TField;

    procedure SetDataSource(const Value: TDataSource);
    procedure SetEditing(Value: Boolean);
    procedure SetField(Value: TObjectList);
    procedure SetFieldName(const Value: string);
    procedure SetMultiFields(const Value: Boolean);
    function GetValue: Variant;

  protected
    function FieldFound(Value: TField): Boolean;
    procedure ActiveChanged; override;
    procedure DataEvent(Event: TDataEvent; Info: TDataEventInfoTypeEh); override;
    procedure EditingChanged; override;
{$IFDEF CIL}
    procedure FocusControl(const Field: TField); override;
{$ELSE}
    procedure FocusControl(Field: TFieldRef); override;
{$ENDIF}
    procedure LayoutChanged; override;
    procedure RecordChanged(Field: TField); override;
    procedure UpdateData; override;
    procedure UpdateDataIndependent;
    procedure UpdateField; virtual;
    procedure SetValue(Value: Variant);
  public
    DataIndependentValue: Variant;

    constructor Create;

    function Edit: Boolean;
    function CheckUnbound: Boolean; virtual;
    procedure Modified;
    procedure SetModified(Value: Boolean);
    procedure SetText(const Text: String);
    procedure Reset;

    property Active: Boolean read GetActive;
    property CanModify: Boolean read GetCanModify;
    property Control: TComponent read FControl write FControl;
    property IsUnbound: Boolean read FIsUnbound;
    property DataSetActive: Boolean read GetDataSetActive;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property Editing: Boolean read FEditing;
    property Field: TField read GetField;
    property FieldName: string read FFieldName write SetFieldName;
    property Fields[Index: Integer]: TField read GetFieldsField;
    property FieldsCount: Integer read GetFieldsCount;
    property MultiFields: Boolean read FMultiFields write SetMultiFields;
    property OnActiveChange: TNotifyEvent read FOnActiveChange write FOnActiveChange;
    property OnDataChange: TNotifyEvent read FOnDataChange write FOnDataChange;
    property OnEditingChange: TNotifyEvent read FOnEditingChange write FOnEditingChange;
    property OnUpdateData: TNotifyEvent read FOnUpdateData write FOnUpdateData;
    property Value: Variant read GetValue write SetValue;
  end;

implementation

{$IFDEF FPC}
{$ELSE}
uses
  DbConsts;
{$ENDIF}

type
  TPopupCrack = class(TPopup);
  TCustomDataGridEhCrack = class(TCustomDataGridEh);

{$REGION 'TCustomDataComboBoxEh'}

constructor TCustomDataComboBoxEh.Create(AOwner: TComponent);
var
  VGrid: TCustomDataGridEhCrack;
  VGridColumn: TDataGridBaseColumnEh;
begin
  inherited Create(AOwner);

  CanFocus := True;

  FDataLink := TFieldDataLinkEh.Create();;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnEditingChange := EditingChange;
  FDataLink.OnUpdateData := InternalUpdateData;
  FDataLink.OnActiveChange := ActiveChange;

  FDropDownBox := TComboDropDownBoxEh.Create(Self);

  FInsideEdit := TInsideEditEh.Create(Self);
  FInsideEdit.Parent := Self;
  FInsideEdit.Stored := False;

  FListItems := TStringList.Create;
  TStringList(FListItems).OnChange := ListItemsChanged;

  FListItemsLink := TListTableLinkEh<TKeyDisplayStringPairEh>.Create(nil);
  FItemsList := TObjectList<TKeyDisplayStringPairEh>.Create(True);
  TListTableLinkEh<TKeyDisplayStringPairEh>(FListItemsLink).SetList(FItemsList);

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

  UpdateKeyDisplayText;
end;

destructor TCustomDataComboBoxEh.Destroy;
begin
  FreeAndNil(FListItems);
  FreeAndNil(FListItemsLink);
  FreeAndNil(FItemsList);
  FreeAndNil(FDataLink);
  inherited Destroy;
end;

{$REGION 'TCustomDataComboBoxEh.System'}

function TCustomDataComboBoxEh.GetDataFieldName: String;
begin
  Result := FDataFieldName;
end;

procedure TCustomDataComboBoxEh.SetDataFieldName(const Value: String);
begin
  if FDataFieldName <> Value then
  begin
    FDataFieldName := Value;
    UpdateDataFields;
  end;
end;

procedure TCustomDataComboBoxEh.UpdateDataFields;
begin
  if FDataFieldsUpdating then Exit;
  FDataFieldsUpdating := True;
  try
    DataLink.FieldName := FDataFieldName;
    UpdateKeyDisplayText;
  finally
    FDataFieldsUpdating := False;
  end;
end;

function TCustomDataComboBoxEh.GetDBDataSource: TDataSource;
begin
  Result := DataLink.DataSource;
end;

function TCustomDataComboBoxEh.GetDataSource: TComponent;
begin
  Result := FDataSource;
end;

procedure TCustomDataComboBoxEh.SetDataSource(const Value: TComponent);
begin
  if Value = FDataSource then Exit;

  if Value = nil then
  begin
    FDataSource := nil;
    if FDataLink.DataSourceFixed = False then
      FDataLink.DataSource := nil;
  end
  else if Value is TDataSource then
  begin
    FDataSource := Value;
    if FDataLink.DataSourceFixed = False then
      FDataLink.DataSource := Value as TDataSource;
  end
  else if Value is TDataSet then
  begin
    FDataSource := Value;
    if FDataLink.DataSourceFixed = False then
      FDataLink.DataSource := GetDefaultDataSourceForDataSet(TDataSet(Value));
  end else
  begin
    raise Exception.Create('DataSource of ' + Value.ClassName + ' is not supported.');
  end;

  if FDataSource <> nil then FDataSource.FreeNotification(Self);

  DataChange(nil);
  FDataLink.UpdateDataIndependent;

  CheckNotCircular;
end;

function TCustomDataComboBoxEh.GetIsLookupMode: Boolean;
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

function TCustomDataComboBoxEh.GetListItems: TStrings;
begin
  Result := FListItems;
end;

procedure TCustomDataComboBoxEh.SetListItems(const Value: TStrings);
begin
  FListItems.Assign(Value);
end;

function TCustomDataComboBoxEh.GetListKeyFieldName: String;
begin
  Result := FListKeyFieldName;
end;

procedure TCustomDataComboBoxEh.SetListKeyFieldName(const Value: String);
begin
  if FListKeyFieldName <> Value then
  begin
    FListKeyFieldName := Value;
    ResetListData();
    DataChanged();
  end;
end;

procedure TCustomDataComboBoxEh.SetListFieldName(const Value: String);
begin
  if FListFieldName <> Value then
  begin
    FListFieldName := Value;
    ResetListData();
    DataChanged();
  end;
end;

procedure TCustomDataComboBoxEh.SetListSource(const Value: TComponent);
var
 ADataSource: TDataSource;
begin
  if Value = FListSource then Exit;

  if Value = nil then
  begin
    RemoveSourceChangeNotification();
    FListSource := nil;
    FListTableLink := nil;
    AddSourceChangeNotification();
    ResetListData();
  end
  else if Value is TBaseTableDataLinkEh then
  begin
    RemoveSourceChangeNotification();
    FListSource := Value;
    FListTableLink := Value as TBaseTableDataLinkEh;
    AddSourceChangeNotification();
    ResetListData();
  end
  else if Value is TDataSource then
  begin
    RemoveSourceChangeNotification();
    FListTableLink := GetDefaultTableDataLinkForDataSource(TDataSource(Value));
    FListSource := Value;
    AddSourceChangeNotification();
    ResetListData();
  end
  else if Value is TDataSet then
  begin
    RemoveSourceChangeNotification();
    ADataSource  := GetDefaultDataSourceForDataSet(TDataSet(Value));
    FListTableLink := GetDefaultTableDataLinkForDataSource(ADataSource);
    FListSource := Value;
    AddSourceChangeNotification();
    ResetListData();
  end else
  begin
    raise Exception.Create('DataSource of ' + Value.ClassName + ' is not supported.');
  end;

  if (Value <> nil) then
    Value.FreeNotification(Self);
end;

function TCustomDataComboBoxEh.GetListSourceOrigin: TListSourceOriginEh;
begin
  if ListSource <> nil
    then Result := TListSourceOriginEh.ListSource
    else Result := TListSourceOriginEh.ListItems;
end;

procedure TCustomDataComboBoxEh.CheckNotCircular;
begin
  Exit;
  if ListTableDataLink.Active and
     (ListTableDataLink is TDataSetTableLinkEh) and
     TDataSetTableLinkEh(ListTableDataLink).DataSet.IsLinkedTo(DBDataSource)
  then
  {$IFDEF FPC}
    DatabaseError('SCircularDataLink');
  {$ELSE}
    DatabaseError(SCircularDataLink);
  {$ENDIF}
end;

procedure TCustomDataComboBoxEh.UpdateKeyDisplayText;
begin
  if DataLink.Active then
  begin
    if IsLookupMode then
      InternalSetKeyValue(TValue.From<Variant>(DataLink.Value))
    else
      InternalSetText(VarToStr(DataLink.Value));
  end;
end;

function TCustomDataComboBoxEh.GetSelectedValue: TValue;
begin
  if IsLookupMode then
  begin
    Result := FKeyValue;
  end else
  begin
    Result := Text;
  end;
end;

procedure TCustomDataComboBoxEh.SetSelectedValue(const Value: TValue);
begin
  if EditCanModify = False then Exit;

  if IsLookupMode then
  begin
    SetKeyValue(Value);
  end else
  begin
    Text := ValueToString(Value);
  end;

  if IsFocused = False then
  begin
    if FDataPosting then Exit;
    try
      UpdateData;
    except
      raise;
    end;
  end;
end;

procedure TCustomDataComboBoxEh.SetKeyValue(const Value: TValue);
begin
  if not SameValue(FKeyValue, Value) then
  begin
    if EditCanModify = False then Exit;
    FKeyValue := Value;
    FDataLink.Modified();
    KeyValueChanged;
  end;
end;

procedure TCustomDataComboBoxEh.InternalSetKeyValue(const VarValue: TValue);
begin
  if SameValue(FKeyValue, VarValue) = False then
  begin
    FKeyValue := VarValue;
    KeyValueChanged();
  end
end;

procedure TCustomDataComboBoxEh.KeyValueChanged();
begin
  if Assigned(FOnKeyValueChanged) then
    FOnKeyValueChanged(Self);
  UpdateTextFromKeyValue();
end;

procedure TCustomDataComboBoxEh.UpdateData;
begin
  BeginInternalListDataChanging;
  try
    if IsLookupMode then
    begin
      FDataLink.SetValue(RttiValueToVariantValue(SelectedValue));
    end else
    begin
      FDataLink.SetValue(Text);
    end;
  finally
    EndInternalListDataChanging;
  end;
end;

procedure TCustomDataComboBoxEh.RemoveSourceChangeNotification();
begin
  if FListTableLink <> nil then
    FListTableLink.RemoveChangeNotification(Self);
end;

procedure TCustomDataComboBoxEh.AddSourceChangeNotification();
begin
  if FListTableLink <> nil then
    FListTableLink.AddChangeNotification(Self, SourceDataChanged);
end;

procedure TCustomDataComboBoxEh.SourceDataChanged(AChangedType: TTableLinkEventTypeEh;
  NewIndex, OldIndex: Integer; ARowView: TTableRowLinkEh);
begin

end;

procedure TCustomDataComboBoxEh.ListItemsChanged(Sender: TObject);
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

  TListTableLinkEh<TKeyDisplayStringPairEh>(FListItemsLink).SetList(FItemsList);
  ResetListData();
  DataChanged();
end;

procedure TCustomDataComboBoxEh.ResetListData;
begin
  FPopupGrid.DataSource := ActualListTableLink();
  FGridColumn.FieldName := ActualListFieldName();
  UpdateInsideEdit();
end;

procedure TCustomDataComboBoxEh.CalcPopupSize(APopup: TPopup);
var
  VGrid: TCustomDataGridEhCrack;
  LinesHeight: Integer;
  LinesCount: Integer;
begin
  if FFormChangedSize.Width > 0 then
  begin
    APopup.Width := FFormChangedSize.Width;
  end else
  begin
    if DropDownBox.Width = 0 then
      APopup.Width := Width
    else
      APopup.Width := DropDownBox.Width;
  end;

  if FFormChangedSize.Height > 0 then
  begin
    APopup.Height := FFormChangedSize.Height;
  end else
  begin
    VGrid := TCustomDataGridEhCrack(FPopupGrid);
    if DropDownBox.VisibleRowCount > VGrid.TableView.Rows.Count then
      LinesCount := VGrid.TableView.Rows.Count
    else
      LinesCount := DropDownBox.VisibleRowCount;
    LinesHeight := VGrid.DefaultRowHeight * LinesCount;

    APopup.Height := LinesHeight + 2;
  end;
end;

function TCustomDataComboBoxEh.CanDropDown(const AButton: TMouseButton; const AShift: TShiftState): Boolean;
begin
  Result := AButton = TMouseButton.mbLeft;
end;

procedure TCustomDataComboBoxEh.ToggleDropDownBox();
begin
  CapturePopupGrid();
  if FPopupGrid.PopupOwner.IsOpen then
    CloseDropDownBox(False)
  else
    ShowDropDownBox();
end;

procedure TCustomDataComboBoxEh.ShowDropDownBox();
var
  VGrid: TPopupDataGridEh;
begin
  CapturePopupGrid();
  VGrid := TPopupDataGridEh(FPopupGrid);
  VGrid.SizeGripAlwaysShow := DropDownBox.Resizable;
  VGrid.LocateDisplayText(Text);

  VGrid.PopupOwner.Placement := TPlacement.Bottom;
  VGrid.PopupOwner.ApplyStyleLookup;
  CalcPopupSize(VGrid.PopupOwner);
  VGrid.PopupOwner.IsOpen := True;
end;

procedure TCustomDataComboBoxEh.CloseDropDownBox(AcceptValue: Boolean);
var
  VGrid: TPopupDataGridEh;
  Value: TValue;
  ListTableLink: TBaseTableDataLinkEh;
  KeyFieldLink: TTableFieldLinkEh;
  RowLink: TTableRowLinkEh;
  KeyFieldValue: TValue;
begin
  VGrid := TPopupDataGridEh(FPopupGrid);

  if (AcceptValue = True) and
     (VGrid.CurrentRow <> nil) and
     (ReadOnly = False) then
  begin
    if IsLookupMode then
    begin
      ListTableLink := ActualListTableLink;
      KeyFieldLink := ListTableLink.Fields.FindField(ActualListKeyFieldName);
      RowLink := VGrid.CurrentRow.SourceRowLink;
      KeyFieldValue := RowLink.FieldValue[KeyFieldLink];
      if EditCanModify() = True then
        SetKeyValue(KeyFieldValue);
    end else
    begin
      Value := VGrid.Columns[0].GetRowValue(VGrid.CurrentRow);
      if EditCanModify() = True then
        Text := ValueToString(Value);
    end;
    SelectAll();
  end;

  VGrid.PopupOwner.IsOpen := False;
end;

procedure TCustomDataComboBoxEh.CapturePopupGrid();
begin
  FPopup.PlacementTarget := Self;
  FPopup.Parent := Self;
  FPopupGrid.ComboBox := Self;
end;

function TCustomDataComboBoxEh.ActualListFieldName: String;
begin
  if ListSourceOrigin = TListSourceOriginEh.ListSource then
    Result := ListFieldName
  else
    Result := 'DisplayValue';
end;

function TCustomDataComboBoxEh.ActualListKeyFieldName: String;
begin
  if ListSourceOrigin = TListSourceOriginEh.ListSource then
    Result := ListKeyFieldName
  else
    Result := 'KeyValue';
end;

function TCustomDataComboBoxEh.ActualListTableLink: TBaseTableDataLinkEh;
begin
  if ListSourceOrigin = TListSourceOriginEh.ListSource then
    Result := FListTableLink
  else
    Result := FListItemsLink;
end;

function TCustomDataComboBoxEh.FindDisplayTextByStr(const Str: String; const PartialKey,
  CaseInsensitive: Boolean; var DisplayText: String): Boolean;
var
  Row: TTableRowLinkEh;
  DisplayFieldValue: TValue;
  DisplayFieldLink: TTableFieldLinkEh;
  DisplayFieldText, FieldTextToCompare: String;
  ListTableLink: TBaseTableDataLinkEh;
begin
  Result := False;
  ListTableLink := ActualListTableLink();
  if ListTableLink <> nil then
  begin
    DisplayFieldLink := ListTableLink.Fields.FindField(ActualListFieldName);
    for Row in ListTableLink.Rows do
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

function TCustomDataComboBoxEh.GetReadOnly: Boolean;
begin
  Result := FReadOnly;
end;

procedure TCustomDataComboBoxEh.SetReadOnly(const Value: Boolean);
begin
  if FReadOnly <> Value then
  begin
    FReadOnly := Value;
    UpdateInsideEdit();
  end;
end;

function TCustomDataComboBoxEh.GetText: string;
begin
  Result := FInsideEdit.Text;
end;

procedure TCustomDataComboBoxEh.SetText(const Value: string);
begin
  FInsideEdit.Text := Value;
end;

function TCustomDataComboBoxEh.GetDefaultTextSettings: TTextSettings;
begin
  Result := FInsideEdit.DefaultTextSettings;
end;

function TCustomDataComboBoxEh.GetResultingTextSettings: TTextSettings;
begin
  Result := FInsideEdit.ResultingTextSettings;
end;

function TCustomDataComboBoxEh.GetStyledSettings: TStyledSettings;
begin
  Result := FInsideEdit.StyledSettings;
end;

procedure TCustomDataComboBoxEh.SetStyledSettings(const Value: TStyledSettings);
begin
  FInsideEdit.StyledSettings := Value;
end;

function TCustomDataComboBoxEh.GetTextSettings: TTextSettings;
begin
  Result := FInsideEdit.TextSettings;
end;

procedure TCustomDataComboBoxEh.SetTextSettings(const Value: TTextSettings);
begin
  FInsideEdit.TextSettings := Value;
end;

procedure TCustomDataComboBoxEh.KeyDown(var Key: Word; var KeyChar: System.WideChar; Shift: TShiftState);
begin
  inherited KeyDown(Key, KeyChar, Shift);
  FInsideEdit.KeyDown(Key, KeyChar, Shift);
end;

procedure TCustomDataComboBoxEh.KeyUp(var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  inherited KeyUp(Key, KeyChar, Shift);
  FInsideEdit.KeyUp(Key, KeyChar, Shift);
end;

procedure TCustomDataComboBoxEh.DataChange(Sender: TObject);
begin
  DataChanged;
end;

procedure TCustomDataComboBoxEh.DataChanged;
begin
  if (csDestroying in ComponentState) then Exit;

  if IsLookupMode = False then
  begin
    SetEditText(VarToStr(DataLink.Value));
    if DropDownBoxVisible then
      FPopupGrid.LocateDisplayText(Text);
  end else
  begin
    if DataLink.Active then
      InternalSetKeyValue(TValue.From<Variant>(DataLink.Value))
    else
      InternalSetKeyValue(TValue.From<Variant>(Null));
  end;
end;

procedure TCustomDataComboBoxEh.EditingChange(Sender: TObject);
begin

end;

procedure TCustomDataComboBoxEh.InternalUpdateData(Sender: TObject);
begin
  if IsLookupMode
    then FDataLink.SetValue(RttiValueToVariantValue(FKeyValue))
    else FDataLink.SetText(Text);
end;

procedure TCustomDataComboBoxEh.ActiveChange(Sender: TObject);
begin

end;

function TCustomDataComboBoxEh.InternalListDataChanging: Boolean;
begin
  Result := (FInternalListDataChanging > 0);
end;

procedure TCustomDataComboBoxEh.BeginInternalListDataChanging;
begin
  Inc(FInternalListDataChanging);
end;

procedure TCustomDataComboBoxEh.EndInternalListDataChanging;
begin
  Dec(FInternalListDataChanging);
end;

function TCustomDataComboBoxEh.IsUnboundMode: Boolean;
begin
  Result := FDataLink.IsUnbound;
end;

procedure TCustomDataComboBoxEh.SetEditText(const Value: String);
begin
  InternalSetText(Value);
end;

procedure TCustomDataComboBoxEh.InternalSetText(const AText: String);
begin
  FInternalTextSetting := True;
  try
    Text := AText;
  finally
    FInternalTextSetting := False;
  end;
end;

procedure TCustomDataComboBoxEh.UpdateTextFromKeyValue();
var
  DisplayText: String;
begin
  DisplayText := GetLookupDisplayText(FKeyValue);
  InternalSetText(DisplayText);
end;

function TCustomDataComboBoxEh.GetLookupDisplayText(const VarValue: TValue): String;
var
  Row: TTableRowLinkEh;
  FieldValue, DisplayFieldValue: TValue;
  KeyFieldLink: TTableFieldLinkEh;
  DisplayFieldLink: TTableFieldLinkEh;
  ListTableLink: TBaseTableDataLinkEh;
begin
  Result := '';
  ListTableLink := ActualListTableLink();
  if ListTableLink <> nil then
  begin
    KeyFieldLink := ListTableLink.Fields.FindField(ActualListKeyFieldName);
    DisplayFieldLink := ListTableLink.Fields.FindField(ActualListFieldName);
    for Row in ListTableLink.Rows do
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

function TCustomDataComboBoxEh.GetCurrentListIndex(): Integer;
var
  Row: TTableRowLinkEh;
  ListTableLink: TBaseTableDataLinkEh;
  FindFieldLink: TTableFieldLinkEh;
  FindValue, FieldValue: TValue;
  I: Integer;
begin
  Result := -1;
  ListTableLink := ActualListTableLink();
  if ListTableLink <> nil then
  begin
    FindValue := SelectedValue;
    if IsLookupMode
      then FindFieldLink := ListTableLink.Fields.FindField(ActualListKeyFieldName)
      else FindFieldLink := ListTableLink.Fields.FindField(ActualListFieldName);
    for I := 0 to ListTableLink.Rows.Count - 1 do
    begin
      Row := ListTableLink.Rows[I];
      FieldValue := Row.FieldValue[FindFieldLink];
      if SameValue(FieldValue, FindValue) then
      begin
        Result := I;
        Exit;
      end;
    end;
  end;
end;

procedure TCustomDataComboBoxEh.UpdateInsideEdit();
begin
  FInsideEdit.ReadOnly := ReadOnly or (IsLookupMode = True);
end;

function TCustomDataComboBoxEh.GetDropDownBox: TComboDropDownBoxEh;
begin
  Result := FDropDownBox;
end;

procedure TCustomDataComboBoxEh.SetDropDownBox(const Value: TComboDropDownBoxEh);
begin
  FDropDownBox.Assign(Value);
end;

function TCustomDataComboBoxEh.EditCanModify: Boolean;
begin
  Result := False;
  if CanModify then
    Result := FDataLink.Edit;
end;

function TCustomDataComboBoxEh.CanModify: Boolean;
begin
  Result := not ReadOnly and DataLink.CanModify;
end;

procedure TCustomDataComboBoxEh.DoChangeTracking;
begin
  if FInternalTextSetting = False then
    FDataLink.Modified;
end;

procedure TCustomDataComboBoxEh.DoEnter;
begin
  inherited DoEnter;
  FInsideEdit.CanFocus := True;
  try
    FInsideEdit.DoEnter;
  finally
    FInsideEdit.CanFocus := False;
  end;
end;

procedure TCustomDataComboBoxEh.DoExit;
begin
  CloseDropDownBox(False);
  FDataLink.UpdateRecord;
  inherited DoExit;
  FInsideEdit.DoExit;
end;

procedure TCustomDataComboBoxEh.Clear;
begin
  if IsLookupMode then
    SelectedValue := TValue.FromVariant(Null)
  else
    SelectedValue := '';
end;

procedure TCustomDataComboBoxEh.SelectNextValue();
begin
  SelectRelativeValue(True);
end;

procedure TCustomDataComboBoxEh.SelectPriorValue();
begin
  SelectRelativeValue(False);
end;

procedure TCustomDataComboBoxEh.SelectRelativeValue(IsForward: Boolean);
var
  CurListIndex: Integer;
  FindFieldLink: TTableFieldLinkEh;
  NextValue: TValue;
  Row: TTableRowLinkEh;
begin
  CurListIndex := GetCurrentListIndex();
  if ActualListTableLink.Rows.Count = 0 then Exit;

  if IsLookupMode
    then FindFieldLink := ActualListTableLink.Fields.FindField(ActualListKeyFieldName)
    else FindFieldLink := ActualListTableLink.Fields.FindField(ActualListFieldName);

  Row := nil;
  if IsForward then
  begin
    if CurListIndex < ActualListTableLink.Rows.Count - 1 then
      Row := ActualListTableLink.Rows[CurListIndex + 1];
  end else
  begin
    if CurListIndex > 0 then
      Row := ActualListTableLink.Rows[CurListIndex - 1];
  end;

  if Row <> nil then
  begin
    NextValue := Row.FieldValue[FindFieldLink];
    SelectedValue := NextValue;
    if IsFocused then
      SelectAll();
  end;
end;

{$ENDREGION 'TCustomDataComboBoxEh.System'}

{$REGION 'TCustomDataComboBoxEh.Visual'}

function TCustomDataComboBoxEh.GetDefaultStyleLookupName: string;
begin
  Result := 'ComboEditStyle';
end;

function TCustomDataComboBoxEh.GetDropDownBoxVisible: Boolean;
begin
  Result := (FPopup <> nil) and FPopup.IsOpen;
end;

procedure TCustomDataComboBoxEh.ApplyStyle;
begin
  inherited ApplyStyle;
  if FindStyleResource<TControl>('content', FEditorBoundControl) then
  begin
    FEditorBoundControl.OnResized := EditorBoundControlResized;
    EditorBoundControlResized(nil);
  end else
  begin
    raise Exception.Create('"content" style resource not found');
  end;
  if FindStyleResource<TControl>('arrow', FArrowButton) then
  begin
    FArrowButton.HitTest := True;
    FArrowButton.Cursor := crArrow;
    FArrowButton.OnMouseDown := Self.DoComboMouseDown;
  end;
end;

procedure TCustomDataComboBoxEh.DoResized;
begin
  inherited DoResized;
end;

procedure TCustomDataComboBoxEh.EditorBoundControlResized(Sender: TObject);
begin
  FInsideEdit.SetBounds(FEditorBoundControl.Position.X, FEditorBoundControl.Position.Y,
                        FEditorBoundControl.Width, FEditorBoundControl.Height);
end;

procedure TCustomDataComboBoxEh.DoComboMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  OldPressed: Boolean;
begin
  if CanDropDown(Button, Shift) then
  begin
    SetFocus;
    OldPressed := Pressed;
    try
      Pressed := True;
      ToggleDropDownBox();
    finally
      Pressed := OldPressed;
    end;
  end;
end;

procedure TCustomDataComboBoxEh.ShowCaret;
begin
  Caret.Show;
end;

procedure TCustomDataComboBoxEh.HideCaret;
begin
  Caret.Hide;
end;

function TCustomDataComboBoxEh.GetCaret: TCustomCaret;
begin
  Result := FInsideEdit.Caret;
end;

procedure TCustomDataComboBoxEh.SetCaret(const Value: TCustomCaret);
begin
  FInsideEdit.Caret := Caret;
end;

procedure TCustomDataComboBoxEh.SelectAll();
begin
  FInsideEdit.SelectAll();
end;

function TCustomDataComboBoxEh.GetDefaultSize: TSizeF;
var
  MetricsService: IFMXDefaultMetricsService;
begin
  if (TBehaviorServices.Current.SupportsBehaviorService(IFMXDefaultMetricsService, MetricsService, Self)
    or SupportsPlatformService(IFMXDefaultMetricsService, MetricsService))
    and MetricsService.SupportsDefaultSize(TComponentKind.Edit) then
    Result := TSizeF.Create(MetricsService.GetDefaultSize(TComponentKind.Edit))
  else
    Result := TSizeF.Create(100, 22);
end;

{$ENDREGION 'TCustomDataComboBoxEh.Visual'}

{$ENDREGION 'TCustomDataComboBoxEh'}

{$REGION 'TInsideEditEh'}

constructor TInsideEditEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CanFocus := False;
  CanParentFocus := True;
end;

procedure TInsideEditEh.ApplyStyle;
begin
  inherited ApplyStyle;
  if FindStyleResource<TControl>('content', FContentControl) then
  begin
    FContentControl.Margins.Rect := TRectF.Create(0, 0, 0, 0);
    SetAdjustType(TAdjustType.None);
  end else
  begin
    raise Exception.Create('"content" style resource not found');
  end;
end;

function TInsideEditEh.FindDisplayTextByStr(const Str: String; const PartialKey, CaseInsensitive: Boolean;
  var DisplayText: String): Boolean;
begin
  Result := ComboBox.FindDisplayTextByStr(Str, PartialKey, CaseInsensitive, DisplayText);
end;

function TInsideEditEh.GetComboBox: TCustomDataComboBoxEh;
begin
  Result := TCustomDataComboBoxEh(Owner);
end;

function TInsideEditEh.GetDefaultStyleLookupName: string;
begin
  Result := 'TransparentEdit';
end;

function TInsideEditEh.DefineModelClass: TDataModelClass;
begin
  Result := TInsideEditModel;
end;

procedure TInsideEditEh.KeyDown(var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  ACanModify: Boolean;
begin
  if (Key = vkReturn) and (ComboBox.DropDownBoxVisible = True) then
  begin
    ComboBox.CloseDropDownBox(True);
    Key := 0;
  end
  else if (Key = vkEscape) and (ComboBox.DropDownBoxVisible = True) then
  begin
    ComboBox.CloseDropDownBox(False);
    Key := 0;
  end
  else if (ssAlt in Shift) and ((Key = vkDOWN) or (Key = vkUp)) then
  begin
    ComboBox.ToggleDropDownBox();
    Key := 0;
  end
  else if (Key = vkDelete) and
          (ComboBox.EditCanModify) and
          (Self.ReadOnly = True) then
  begin
    ComboBox.Clear();
  end
  else if (ComboBox.ReadOnly = False) then
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
        ACanModify := ComboBox.EditCanModify();
        if ACanModify = True then
        begin
          ProcessSearchStr(KeyChar);
          KeyChar := #0;
        end else
        begin
          KeyChar := #0;
        end;
      end;
    end
    else
    begin
      if (Key = vkBack) or (KeyChar >= #32) then
      begin
        ACanModify := ComboBox.EditCanModify();
        if ACanModify = True then
        begin
          if ProcessSearchStr(KeyChar) then
            KeyChar := #0;
        end else
        begin
          KeyChar := #0;
        end;
      end;
    end;
  end;

  if (KeyChar = #0) and (Shift = []) then
  begin
    if ComboBox.DropDownBoxVisible = True then
    begin
      if Key = vkEscape then
      begin
        ComboBox.CloseDropDownBox(False);
        Key := 0;
      end
      else if Key = vkReturn then
      begin
        ComboBox.CloseDropDownBox(True);
        Key := 0;
      end
      else if Key = vkUP then
      begin
        ComboBox.FPopupGrid.Navigation.ToPriorRow();
        Key := 0;
      end
      else if Key = vkDOWN then
      begin
        ComboBox.FPopupGrid.Navigation.ToNextRow();
        Key := 0;
      end
      else if Key = vkNEXT then 
      begin
        ComboBox.FPopupGrid.Navigation.ToNextPage();
        Key := 0;
      end
      else if Key = vkPRIOR then 
      begin
        ComboBox.FPopupGrid.Navigation.ToPriorPage();
        Key := 0;
      end
    end else
    begin
      if (Key = vkUP) and (Shift = []) then
      begin
        ComboBox.SelectPriorValue();
        Key := 0;
      end
      else if (Key = vkDOWN) and (Shift = []) then
      begin
        ComboBox.SelectNextValue();
        Key := 0;
      end
    end;
  end;

  inherited KeyDown(Key, KeyChar, Shift);
end;

procedure TInsideEditEh.DialogKey(var Key: Word; Shift: TShiftState);
begin
  inherited DialogKey(Key, Shift);
end;

function TInsideEditEh.ProcessSearchStr(const Str: String): Boolean;
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

function TInsideEditEh.LocateStr(const Str: String; const PartialKey, CaseInsensitive: Boolean): Boolean;
var
  FoundText: String;
begin
  Result := FindDisplayTextByStr(Str, PartialKey, CaseInsensitive, FoundText);
  if Result then
  begin
    Text := FoundText;
    SelStart := TextLength(Str);
    SelLength := TextLength(Text) - SelStart;
    CaretPosition := TPoint.Create(TextLength(Str), 0).X;
  end else
  begin
  end;
end;

procedure TInsideEditEh.DoChangeTracking;
begin
  ComboBox.DoChangeTracking();

  if ComboBox.DropDownBoxVisible then
  begin
    ComboBox.FPopupGrid.LocateDisplayText(Text);
  end;
end;

{$ENDREGION 'TInsideEditEh'}

{$REGION 'TPopupDataGridEh'}

constructor TPopupDataGridEh.Create(APopupOwner: TPopup);
begin
  inherited Create(APopupOwner);
  Parent := APopupOwner;
  FPopupOwner := APopupOwner;
  AutoGenerateColumns := False;
  IndicatorColumn.Visible := False;
  Title.Visible := False;
  GridLineOptions.HorzLinesVisible := False;
  SelectionOptions.AllowedSelections := [];
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
end;

procedure TPopupDataGridEh.HandleDataCellMouseClickEvent(Params: TGridCellMouseButtonParamsEh);
begin
  inherited HandleDataCellMouseClickEvent(Params);
  if (ComboBox <> nil) then
  begin
    ComboBox.CloseDropDownBox(True);
  end;
end;

function TPopupDataGridEh.HasFocus: Boolean;
begin
  Result := True;
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

{$ENDREGION 'TPopupDataGridEh'}

{$REGION 'TPopupDataGridColumnEh'}

procedure TPopupDataGridColumnEh.HandleCreateCellContent(Params: TBaseGridCreateCellContentParamsEh);
begin
end;

procedure TPopupDataGridColumnEh.HandleGetDataCellManager(Params: TBaseDataGridGetDataCellManagerParamsEh);
begin
end;

procedure TPopupDataGridColumnEh.HandleDataCellInitContent(Params: TBaseGridInitCellContentParamsEh);
begin
end;

{$ENDREGION 'TPopupDataGridColumnEh'}

{$REGION 'TInsideEditModel'}

{$HINTS OFF}
type
  TCustomEditModelCoreCrack = class(TDataModel)
  private
    FChanged: Boolean;
    FText: string;
    FSelStart: Integer;
    FSelLength: Integer;
    FReadOnly: Boolean;
    FMaxLength: Integer;
    FPassword: Boolean;
    FKeyboardType : TVirtualKeyboardType;
    FReturnKeyType: TReturnKeyType;
    FImeMode: TImeMode;
    FHideSelectionOnExit: Boolean;
    FKillFocusByReturn: Boolean;
    FCheckSpelling: Boolean;
    FTextPrompt: string;
    FCaretPosition: Integer;
    FCaret: TCustomCaret;
  end;
{$HINTS ON}

{ TInsideEditModel }

constructor TInsideEditModel.Create;
var
  ACaret: TCustomCaret;
begin
  inherited Create;

  ACaret := TCustomEditModelCoreCrack(Self).FCaret;
  ACaret.Free;
  ACaret := TCaret.Create(InsideEdit.ComboBox as TFmxObject);
  ACaret.Visible := InputSupport;
  ACaret.ReadOnly := ReadOnly;
  TCustomEditModelCoreCrack(Self).FCaret := ACaret;
end;

destructor TInsideEditModel.Destroy;
begin
  inherited Destroy;
end;

procedure TInsideEditModel.DoChangeTracking;
begin
  inherited DoChangeTracking;
  InsideEdit.DoChangeTracking();
end;

function TInsideEditModel.GetInsideEdit: TInsideEditEh;
begin
  Result := Owner as TInsideEditEh;
end;

{$ENDREGION}

{$REGION 'TFieldDataLinkEh'}

constructor TFieldDataLinkEh.Create;
begin
  inherited Create;
  VisualControl := True;
  FIsUnbound := True;
  DataIndependentValue := Null;
end;

function TFieldDataLinkEh.Edit: Boolean;
begin
  if IsUnbound then
  begin
    if not Editing and not ReadOnly then
    begin
      FEditing := True;
      FModified := False;
      if Assigned(OnEditingChange) then OnEditingChange(Self);
    end;
  end else if CanModify then
    inherited Edit;
  Result := FEditing;
end;

function TFieldDataLinkEh.GetActive: Boolean;
begin
  if IsUnbound then Result := True
  else Result := inherited Active and (Field <> nil);
end;

function TFieldDataLinkEh.GetDataSetActive: Boolean;
begin
  Result := (DataSource <> nil) and
            (DataSource.DataSet <> nil) and
            DataSource.DataSet.Active;
end;

function TFieldDataLinkEh.GetCanModify: Boolean;
begin
  Result := ((Field <> nil) and Field.CanModify) or IsUnbound;
end;

function TFieldDataLinkEh.GetDataSource: TDataSource;
begin
  Result := inherited DataSource;
end;

procedure TFieldDataLinkEh.Modified;
begin
  FModified := True;
end;

procedure TFieldDataLinkEh.RecordChanged(Field: TField);
begin
  if (Field = nil) or FieldFound(Field) then
  begin
    if Assigned(FOnDataChange) then FOnDataChange(Self);
    FModified := False;
  end;
end;

procedure TFieldDataLinkEh.SetDataSource(const Value: TDataSource);
begin
  if Value <> inherited DataSource then
  begin
    inherited DataSource := Value;
    UpdateDataIndependent;
  end;
end;

procedure TFieldDataLinkEh.SetFieldName(const Value: string);
begin
  if FFieldName <> Value then
  begin
    FFieldName := Value;
    UpdateField;
    UpdateDataIndependent;
  end;
end;

procedure TFieldDataLinkEh.SetText(const Text: String);
begin
  if IsUnbound then
  begin
    DataIndependentValue := Text;
    RecordChanged(nil);
  end else if Field.IsBlob then
    Field.AsString := Text
  else
    Field.Text := Text;
end;

function TFieldDataLinkEh.GetValue: Variant;
begin
  if IsUnbound then
    Result := DataIndependentValue
  else if Field <> nil then
    Result := Field.Value
  else
    Result := Null;
end;

procedure TFieldDataLinkEh.SetValue(Value: Variant);
var
  i: Integer;
begin
  if IsUnbound then
  begin
    DataIndependentValue := Value;
    RecordChanged(nil);
  end else if FieldsCount > 1 then
  begin
    if VarEquals(Value, Null)
      then for i := 0 to FieldsCount - 1 do Fields[i].AsVariant := Null
      else for i := 0 to FieldsCount - 1 do Fields[i].AsVariant := Value[i]
  end else if Field <> nil then
{$IFDEF EH_LIB_8}
    Field.AsVariant := Value;
{$ELSE}
   if (Field.DataType = ftLargeInt) and (Value <> Null)
     then Field.AsFloat := Value
     else Field.AsVariant := Value;
{$ENDIF}
end;

procedure TFieldDataLinkEh.UpdateData;
begin
  if IsUnbound then
  begin
    if FModified then
      if Assigned(OnUpdateData) then OnUpdateData(Self);
    FEditing := False;
    FModified := False;
  end else if FModified then
  begin
    if (Field <> nil) and Assigned(FOnUpdateData) then FOnUpdateData(Self);
    FModified := False;
  end;
end;

procedure TFieldDataLinkEh.UpdateDataIndependent;
var
  OldIsUnbound: Boolean;
begin
  if FIsUnbound <> CheckUnbound then
  begin
    OldIsUnbound := FIsUnbound;
    FIsUnbound := CheckUnbound;
    DataIndependentValue := Null;
    LayoutChanged;
    if not OldIsUnbound and FIsUnbound then
      RecordChanged(nil);
  end;
end;

function TFieldDataLinkEh.CheckUnbound: Boolean;
begin
  Result := (DataSource = nil) and (FieldName = '');
end;

procedure TFieldDataLinkEh.ActiveChanged;
begin
  UpdateField;
  if Assigned(FOnActiveChange) then FOnActiveChange(Self);
end;

procedure TFieldDataLinkEh.EditingChanged;
begin
  SetEditing(inherited Editing and CanModify);
end;

function TFieldDataLinkEh.FieldFound(Value: TField): Boolean;
var i: Integer;
begin
  Result := False;
  for i := 0 to Length(FFields) - 1 do
    if FFields[i] = Value then
    begin
      Result := True;
      Exit;
    end;
end;

procedure TFieldDataLinkEh.FocusControl(Field: TFieldRef);
begin
  if (Field^ <> nil) and FieldFound(Field^) and (FControl is TWinControl) then
    if TWinControl(FControl).CanFocus then
    begin
      Field^ := nil;
      TWinControl(FControl).SetFocus;
    end;
end;

function TFieldDataLinkEh.GetField: TField;
begin
  if Length(FFields) = 0
    then Result := nil
    else Result := FFields[0];
end;

function TFieldDataLinkEh.GetFieldsCount: Integer;
begin
  Result := Length(FFields);
end;

function TFieldDataLinkEh.GetFieldsField(Index: Integer): TField;
begin
  if Length(FFields) = 0
    then Result := nil
    else Result := FFields[Index];
end;

procedure TFieldDataLinkEh.LayoutChanged;
begin
  UpdateField;
end;

procedure TFieldDataLinkEh.Reset;
begin
  RecordChanged(nil);
end;

procedure TFieldDataLinkEh.SetMultiFields(const Value: Boolean);
begin
  if FMultiFields <> Value then
  begin
    FMultiFields := Value;
    UpdateField;
  end;
end;

procedure TFieldDataLinkEh.UpdateField;
var
{$IFDEF EH_LIB_17}
  ListOfFields: TList<TField>;
  I: Integer;
{$ENDIF}
  FieldList: TObjectListEh;
begin
  FieldList := TObjectListEh.Create;
  try
  if inherited Active and (FFieldName <> '') then
  begin
    if MultiFields then
      if Assigned(FControl) then
        GetFieldsProperty(FieldList, DataSource.DataSet, FControl, FFieldName)
      else
      begin
{$IFDEF EH_LIB_17}
        ListOfFields := TList<TField>.Create;
        DataSet.GetFieldList(ListOfFields, FFieldName);
        for I := 0 to ListOfFields.Count-1 do
          FieldList.Add(ListOfFields[i]);
        FreeAndNil(ListOfFields);
{$ELSE}
        DataSet.GetFieldList(FieldList, FFieldName);
{$ENDIF}
      end
    else
      if Assigned(FControl)
        then FieldList.Add(GetFieldProperty(DataSource.DataSet, FControl, FFieldName))
        else FieldList.Add(DataSource.DataSet.FieldByName(FFieldName));
  end;
  SetField(FieldList);
  finally
    FreeAndNil(FieldList);
  end;
end;

procedure TFieldDataLinkEh.SetEditing(Value: Boolean);
begin
  if FEditing <> Value then
  begin
    FEditing := Value;
    FModified := False;
    if Assigned(FOnEditingChange) then
      FOnEditingChange(Self);
  end;
end;

procedure TFieldDataLinkEh.SetField(Value: TObjectList);

  function CompareFieldsAndList(Value: TObjectList): Boolean;
  begin
    Result := True;
  end;

var
  i: Integer;
begin
  if CompareFieldsAndList(Value) then
  begin
    SetLength(FFields, Value.Count);
    for i := 0 to Value.Count - 1 do
      FFields[i] := TField(Value[i]);
    EditingChanged;
    RecordChanged(nil);
  end;
end;

procedure TFieldDataLinkEh.SetModified(Value: Boolean);
begin
  FModified := Value;
end;

procedure TFieldDataLinkEh.DataEvent(Event: TDataEvent; Info: TDataEventInfoTypeEh);
begin
  inherited DataEvent(Event, Info);
  if Event = deDisabledStateChange then
  begin
    if Boolean(Info)
      then UpdateField
      else SetLength(FFields, 0);
  end;
end;

{$ENDREGION 'TFieldDataLinkEh'}

{$REGION 'TComboDropDownBoxEh'}

{ TComboDropDownBoxEh }

constructor TComboDropDownBoxEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetSubComponent(True);
  Name := 'DropDownBox';

  FWidth := 0;
  FVisibleRowCount := 24;
  FResizable := True;
end;

destructor TComboDropDownBoxEh.Destroy();
begin
  inherited Destroy();
end;

function TComboDropDownBoxEh.GetNamePath: string;
begin
  Result := inherited GetNamePath;
end;

function TComboDropDownBoxEh.GetOwner: TPersistent;
begin
  Result := inherited GetOwner;
end;

procedure TComboDropDownBoxEh.HandleCreateCellContent(Params: TBaseGridCreateCellContentParamsEh);
begin
end;

procedure TComboDropDownBoxEh.HandleDataCellGetStyleParams(Params: TDataAxisCellStyleParamsEh);
begin
end;

procedure TComboDropDownBoxEh.HandleGetDataCellManager(Params: TPersistent);
begin
end;

procedure TComboDropDownBoxEh.HandleInitDataCellContent(Params: TPersistent);
begin
end;

procedure TComboDropDownBoxEh.Changed();
begin
end;

procedure TComboDropDownBoxEh.SetResizable(const Value: Boolean);
begin
  if FResizable <> Value then
  begin
    FResizable := Value;
    Changed();
  end;
end;

procedure TComboDropDownBoxEh.SetVisibleRowCount(const Value: Integer);
begin
  if FVisibleRowCount <> Value then
  begin
    FVisibleRowCount := Value;
    Changed();
  end;
end;

procedure TComboDropDownBoxEh.SetWidth(const Value: Integer);
begin
  if FWidth <> Value then
  begin
    FWidth := Value;
    Changed();
  end;
end;

{$ENDREGION 'TComboDropDownBoxEh'}

end.
