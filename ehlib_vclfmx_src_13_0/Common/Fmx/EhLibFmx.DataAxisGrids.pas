{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{                EhLibFmx.DataAxisGrids                 }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataAxisGrids;

interface

{$SCOPEDENUMS ON}

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, System.Types,
  FMX.Graphics, System.UITypes, System.Math, FMX.Forms, System.Contnrs,
  FMX.Menus, FMX.ImgList,
  FMX.Platform, Data.DB, System.Variants,
  System.Generics.Collections, Rtti,
  FMX.Edit,
  DefaultDataSourcesEh,
  EhLibUtils, DBUtilsEh,
  EhLib.TableLinks,
  EhLib.GridTableViews,
  EhLibFmx.Grid.CellManagers,
  EhLibFmx.ToolControls,
  EhLibFmx.Grid.InplaceEditors,
  EhLibFmx.Grids,

  EhLibFmx.DataAxisGrid.ToolControls,
  EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.DataAxisGrid.DataCells,

  EhLibFmx.Platform,
  EhLibFmx.Types,
  EhLibFmx.Grid.Types,
  EhLibFmx.Grid.ToolControls;

type
  TCustomDataAxisGridEh = class;

  TDataGridTableViewDataChangedEventEh = procedure (Sender: TObject; AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer) of object;

  TGridListItemDirectionEh = (Vertical, Horizontal);

{ TDataAxisGridTableViewEh }

  TDataAxisGridTableViewEh = class(TBaseGridTableViewEh)
  private
    FGrid: TCustomDataAxisGridEh;
  protected
    procedure DataNotification(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowView: TTableRowViewEh); override;
  public
    constructor Create(AGrid: TCustomDataAxisGridEh); reintroduce;
    destructor Destroy; override;

    property Grid: TCustomDataAxisGridEh read FGrid;
  end;

{ TDBAxisGridLineParamsEh }

  TDBAxisGridLineParamsEh = class(TGridLineOptionsEh)
  private
    FDataBoundaryColor: TAlphaColor;
    FDataHorzLines: Boolean;
    FDataHorzLinesStored: Boolean;
    FDataVertLines: Boolean;
    FDataVertLinesStored: Boolean;
    FGridBoundaries: Boolean;

    function GetDataHorzLines: Boolean;
    function GetDataVertLines: Boolean;
    function GetGrid: TCustomDataAxisGridEh;
    function GetGridBoundaries: Boolean;
    function IsDataHorzLinesStored: Boolean;
    function IsDataVertLinesStored: Boolean;
    procedure SetDataBoundaryColor(const Value: TAlphaColor);

  protected
    function DefaultDataHorzLines: Boolean; virtual;
    function DefaultDataVertLines: Boolean; virtual;

    procedure SetDataHorzLines(const Value: Boolean); virtual;
    procedure SetDataHorzLinesStored(const Value: Boolean); virtual;
    procedure SetDataVertLines(const Value: Boolean); virtual;
    procedure SetDataVertLinesStored(const Value: Boolean); virtual;
    procedure SetGridBoundaries(const Value: Boolean); virtual;

    property Grid: TCustomDataAxisGridEh read GetGrid;
  public
    constructor Create(AGrid: TCustomGridEh);

    function GetVertAreaContraVertColor: TAlphaColor; override;
    function GetDataBoundaryColor: TAlphaColor; virtual;

  public
    property DarkColor;
    property BrightColor;

    property DataBoundaryColor: TAlphaColor read FDataBoundaryColor write SetDataBoundaryColor default TAlphaColorRec.Null;
    property DataHorzColor;
    property DataHorzLines: Boolean read GetDataHorzLines write SetDataHorzLines stored IsDataHorzLinesStored;
    property DataHorzLinesStored: Boolean read IsDataHorzLinesStored write SetDataHorzLinesStored stored False;
    property DataVertColor;
    property DataVertLines: Boolean read GetDataVertLines write SetDataVertLines stored IsDataVertLinesStored;
    property DataVertLinesStored: Boolean read IsDataVertLinesStored write SetDataVertLinesStored stored False;
    property GridBoundaries: Boolean read GetGridBoundaries write SetGridBoundaries default False;

  end;

  TDataGridAllowedOperationEh = (Insert, Update, Delete, Append);
  TDataGridAllowedOperationsEh = set of TDataGridAllowedOperationEh;

{ TCustomDataAxisGridEh }

  TCustomDataAxisGridEh = class(TCustomGridEh)
  private
    FAllFieldBarList: TList<TFieldBarEh>;
    FAllFieldBars: TGridAllFieldBarListEh;
    FAllowedOperations: TDataGridAllowedOperationsEh;
    FAutoGeneratePropBars: Boolean;
    FDisplayFieldBarList: TList<TFieldBarEh>;
    FDisplayFieldBars: TGridDisplayFieldBarsEh;
    FDynamicBarList: TList<TFieldBarEh>;
    FDynamicFieldBars: TGridDynamicFieldBarsEh;
    FFieldBarOptions: TFieldBarOptionsEh;
    FLayoutChangedInUpdateLock: Boolean;
    FLayoutLock: Byte;
    FReadOnly: Boolean;
    FStaticFieldBars: TGridStaticFieldBarsEh;
    FTableView: TDataAxisGridTableViewEh;
    FTitle: TAxisGridTitleBarEh;
    FUpdateLock: Byte;
    FVisibleFieldBarList: TList<TFieldBarEh>;
    FVisibleFieldBars: TGridVisibleFieldBarsEh;

    FOnTableViewDataChanged: TDataGridTableViewDataChangedEventEh;

    function GetDataSource: TComponent;
    function GetFieldBarByFieldName(const FieldName: String): TFieldBarEh;
    function GetGridLineParams: TDBAxisGridLineParamsEh;
    function GetIsLoaded: Boolean;

    procedure SetAllowedOperations(const Value: TDataGridAllowedOperationsEh);
    procedure SetAutoGeneratePropBars(const Value: Boolean);
    procedure SetFieldBarOptions(const Value: TFieldBarOptionsEh);
    procedure SetGridLineParams(const Value: TDBAxisGridLineParamsEh);
    procedure SetReadOnly(const Value: Boolean);
    procedure SetStaticFieldBars(Value: TGridStaticFieldBarsEh);
    procedure SetTitle(const Value: TAxisGridTitleBarEh);

  protected
    { IInplaceEditHolderEh }
    function InplaceEditCanModify(Control: TWinControl): Boolean; virtual;

    procedure GetMouseDownInfo(var Pos: TPoint; var Time: Integer); virtual;
    procedure InplaceEditKeyDown(Control: TWinControl; var Key: Word; Shift: TShiftState); virtual;
    procedure InplaceEditKeyPress(Control: TWinControl; var Key: Char); virtual;
    procedure InplaceEditKeyUp(Control: TWinControl; var Key: Word; Shift: TShiftState); virtual;

  protected
    FAcquireFocus: Boolean;
    FVisibleBarListNeedUpdate: Boolean;

    function CanEditAcceptKey(Key: Char): Boolean; override;
    function CanEditModify: Boolean; override;
    function CanShowEditor: Boolean; override;
    function CreateGridLineOptions: TGridLineOptionsEh; override;
    function GetEditLimit: Integer; override;
    function GetEditMask(AColIndex, ARowIndex: Integer): string; override;
    function GetEditText(AColIndex, ARowIndex: Integer): string; override;
    function GetIsEditorModified: Boolean; override;
    function GetEditorValue(InplaceEditor: TLaInplaceTextEdit): TValue; override;
    function IsShowFocusLayerForCell(ACell: TGridBaseCellEh): Boolean; override;

    function AcquireFocus: Boolean; virtual;
    function AcquireLayoutLock: Boolean;
    function AllowedOperationUpdate: Boolean; virtual;
    function AxisColumnsStorePropertyName: String; virtual;
    function BoxRect(ALeft, ATop, ARight, ABottom: Integer): TRect;
    function CanEditModifyColumn(Index: Integer): Boolean; virtual;
    function CanEditorMode: Boolean; virtual;
    function CreateAllFieldBarList(ABaseList: TList<TFieldBarEh>): TGridAllFieldBarListEh; virtual;
    function CreateDataCellKeyDownParams(AGrid: TControl; AColIndex, ARowIndex, AAreaColIndex, AAreaRowIndex: Integer): TBaseGridCellKeyDownParamsEh; virtual;
    function CreateDisplayFieldBars(ABaseList: TList<TFieldBarEh>): TGridDisplayFieldBarsEh; virtual;
    function CreateDynamicFieldBars(ABaseList: TList<TFieldBarEh>): TGridDynamicFieldBarsEh; virtual;
    function CreateFieldBarByField(AField: TTableFieldLinkEh): TFieldBarEh; virtual;
    function CreateFieldBarOptions: TFieldBarOptionsEh; virtual;
    function CreateGridTableView: TDataAxisGridTableViewEh; virtual;
    function CreateStaticFieldBars: TGridStaticFieldBarsEh; virtual;
    function CreateTitle: TAxisGridTitleBarEh; virtual;
    function CreateVisibleFieldBars(ABaseList: TList<TFieldBarEh>): TGridVisibleFieldBarsEh; virtual;
    function DefaultTitleAlignment: TAlignment; virtual;
    function DefaultTitleColor: TAlphaColor; virtual;
    function ExcludeLinesFromCellRect(AColIndex, ARowIndex: Integer; const CellRect: TRect): TRect;
    function FindNextCellPos(const RightToLeft, CheckNextCol, CheckNextRow, CheckTabStob: Boolean; out AColIndex, ARowIndex: Integer): Boolean; virtual;
    function GetCurrentFieldBar: TFieldBarEh; virtual;
    function GetCurrentListItemBar: TTableRowViewEh; virtual;
    function GetDataCellHorzOffset(AFieldBar: TFieldBarEh): Integer; virtual;
    function GetDynaFieldBarClassByField(AField: TTableFieldLinkEh): TFieldBarEhClass; virtual;
    function GetRestoreStateControl: TObject; virtual;
    function GetSelectionColor: TAlphaColor; virtual;
    function GetSelectionInactiveColor: TAlphaColor; virtual;
    function InplaceEditorVisible: Boolean;
    function IsDrawCellBorder(AColIndex, ARowIndex: Integer; BorderType: TGridCellBorderTypeEh): Boolean;
    function IsSideParentableForProperty(const PropertyName: String): Boolean;
    function MouseCellIsImageLink: Boolean; virtual;
    function MouseCellIsLink: Boolean; virtual;
    function MouseCellIsTextLink: Boolean; virtual;
    function StoreColumns: Boolean;
    function GetAxisDataTreeViewAreaParams(AFieldBar: TFieldBarEh; ARecordBar: TTableRowViewEh): TDataAxisCellTreeViewAreaParamsEh; virtual;
    function GetDataCellHighlightingText(): String; virtual;
    function GetListItemDirection: TGridListItemDirectionEh; virtual;

    procedure ColWidthsChanged; override;
    procedure CurrentCellMoved(OldCurrent: TGridCoord); override;
    procedure DefineProperties(Filer: TFiler); override;
    procedure DialogKey(var Key: Word; Shift: TShiftState); override;
    procedure DoAddObject(const AObject: TFmxObject); override;
    procedure DoBeforeFirstDrawing; override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure FlatChanged; override;
    procedure FocusCell(AColIndex, ARowIndex: Integer; MoveAnchor: Boolean); override;
    procedure FontChanged(); override;
    procedure HandleDataCellKeyDownEvent(Params: TBaseGridCellKeyDownParamsEh); virtual;
    procedure HandleDataCellMouseDownEvent(Params: TGridCellMouseButtonParamsEh); virtual;
    procedure HandleDataCellMouseClickEvent(Params: TGridCellMouseButtonParamsEh); virtual;
    procedure HandleCurrentPosChange(); virtual;
    procedure HideEditor(const Accept: Boolean); override;
    procedure InvalidateEditor; override;
    procedure KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Paint; override;
    procedure Resize; override;
    procedure RolPosChanged(OldRowPosX, OldRowPosY: Integer); override;
    procedure SaveEditorValue(EditorValue: TValue); override;
    procedure SetEditorModified(IsModified: Boolean); override;
    procedure SetPaintColors; override;
    procedure ShowEditor; override;
    procedure UpdateEdit; override;
    procedure UpdateText(EditorChanged: Boolean); override;
    procedure ApplyStyle; override;
    procedure StyleApplied; override;

    procedure AllFieldBarPropsEndUpdate; virtual;
    procedure BarListChanged; virtual;
    procedure BeginUpdate; reintroduce;
    procedure CancelLayout;
    procedure CheckPropertiesConsistent(); virtual;
    procedure CheckWritePendingData; virtual;
    procedure ClientAreaSizeChanged;
    procedure DataOrPositionChanged(); virtual;
    procedure DeferLayout;
    procedure DisplayFieldBarListChanged; virtual;
    procedure DoTabAction(GoForward: Boolean; Shift: TShiftState); virtual;
    procedure DynamicBarListChanged(); virtual;
    procedure EndUpdate; reintroduce;
    procedure FieldBarChanged(AFieldBar: TFieldBarEh; CellLayoutAffects: Boolean = False);
    procedure FieldBarVisibleStateChanged(AFieldBar: TFieldBarEh);
    procedure FullFieldBarListChanged(); virtual;
    procedure HandleDataCellGetDisplayText(Params: TDataAxisGridGetDisplayTextParamsEh); virtual;
    procedure HandleDataCellGetStyleParams(Params: TDataAxisCellStyleParamsEh); virtual;
    procedure HandleDataCellGetValue(Params: TDataAxisGridGetBarValueParamsEh); virtual;
    procedure HandleDataCellSetValue(Params: TDataAxisGridSetBarValueParamsEh); virtual;
    procedure HandleDataCellInitEditParams(AParams: TDataAxisCellEditParamsEh); virtual;
    procedure HandleDataCellStartEdit(Params: TDataAxisCellStartEditParamsEh); virtual;
    procedure HandleCanModifyCellValue(AParams: TDataAxisCellCanModifyParamsEh); virtual;
    procedure HandleDataCellInTextLinkClick(Params: TDataAxisCellInTextLinkClickParamsEh); virtual;

    procedure InternalLayout; virtual;
    procedure InternalLayoutChanged(CellLayoutAffects: Boolean = False); virtual;
    procedure InvalidateCell(AColIndex, ARowIndex: Integer);
    procedure InvalidateCol(AColIndex: Integer);
    procedure InvalidateRow(ARowIndex: Integer);
    procedure KeyPropertyModified;
    procedure LayoutChanged(CellLayoutAffects: Boolean = False); virtual;
    procedure LinkActive(Value: Boolean); virtual;
    procedure ProcessGetDataTreeViewAreaParams(Params: TDataAxisCellTreeViewAreaParamsEh); virtual;
    procedure ProcessSetDataTreeSignState(Params: TDataAxisCellTreeSignStateParamsEh); virtual;
    procedure RebindFieldBarsFields; virtual;
    procedure ResetData;
    procedure SetCellLayoutAffects(); virtual;
    procedure SetColumnAttributes; virtual;
    procedure SetDataSource(Value: TComponent); virtual;
    procedure SourceFieldListChanged(); virtual;
    procedure StaticBarListChanged(); virtual;
    procedure TableViewDataChanged(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowView: TTableRowViewEh); virtual;
    procedure UpdateActive; virtual;
    procedure UpdateBarList;
    procedure UpdateDisplayFieldBarList(); virtual;
    procedure UpdateDynamicBarList();
    procedure UpdateVisibleFieldBarList(); virtual;
    procedure WritePendingData; virtual;
    procedure GetFieldBarListItemBarAtPos(AGridColIndex, AGridRowIndex: Integer; out AFieldBar: TFieldBarEh; out ARecordBar: TTableRowViewEh); virtual;
    procedure ComposeDataCellMenu(ACellParams: TDataAxisCellComposeContextMenuParamsEh); virtual;
    procedure RaiseCurrentChangedEvent();

    property AllFieldBarList: TList<TFieldBarEh> read FAllFieldBarList;
    property AutoGeneratePropBars: Boolean read FAutoGeneratePropBars write SetAutoGeneratePropBars;
    property CurrentFieldBar: TFieldBarEh read GetCurrentFieldBar;
    property CurrentListItemBar: TTableRowViewEh read GetCurrentListItemBar;
    property DisplayFieldBarList: TList<TFieldBarEh> read FDisplayFieldBarList;
    property DisplayFieldBars: TGridDisplayFieldBarsEh read FDisplayFieldBars;
    property DynamicFieldBars: TGridDynamicFieldBarsEh read FDynamicFieldBars;
    property FieldBars: TGridAllFieldBarListEh read FAllFieldBars;
    property GridLineParams: TDBAxisGridLineParamsEh read GetGridLineParams write SetGridLineParams;
    property IsLoaded: Boolean read GetIsLoaded;
    property LayoutLock: Byte read FLayoutLock;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    property StaticFieldBars: TGridStaticFieldBarsEh read FStaticFieldBars write SetStaticFieldBars;
    property UpdateLock: Byte read FUpdateLock;
    property VisibleFieldBars: TGridVisibleFieldBarsEh read FVisibleFieldBars;
    property FieldBarOptions: TFieldBarOptionsEh read FFieldBarOptions write SetFieldBarOptions;
    property FieldFieldBars[const FieldName: String]: TFieldBarEh read GetFieldBarByFieldName; default;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function CellRect(AColIndex, ARowIndex: Integer; IncludeCellLines: Boolean = True): TRect;
    function CellRectAbs(AColIndex, ARowIndex: Integer; IncludeCellLines: Boolean = False): TRect;
    function DataSetActive: Boolean;
    function FindFieldColumn(const FieldName: String): TFieldBarEh;

    procedure SetNewScene(AScene: IScene); override;

    procedure BeginLayout;
    procedure CancelEditing; virtual;
    procedure EndLayout;
    procedure UpdateData; virtual;

    property AllowedOperations: TDataGridAllowedOperationsEh read FAllowedOperations write SetAllowedOperations default [TDataGridAllowedOperationEh.Insert, TDataGridAllowedOperationEh.Update, TDataGridAllowedOperationEh.Delete, TDataGridAllowedOperationEh.Append];
    property Canvas;
    property DataSource: TComponent read GetDataSource write SetDataSource;
    property EditorMode;
    property FixedColor;
    property TableView: TDataAxisGridTableViewEh read FTableView;
    property Title: TAxisGridTitleBarEh read FTitle write SetTitle;

    property OnTableViewDataChanged: TDataGridTableViewDataChangedEventEh read FOnTableViewDataChanged write FOnTableViewDataChanged;
  end;

{ TDBAxisGridInplaceEdit }

  TDBAxisGridInplaceEdit = class(TInplaceEdit)
  private
    FFieldBar: TFieldBarEh;
  protected
    procedure KeyDown(var Key: Word; var KeyChar: Char; Shift: TShiftState); override;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;

    procedure UpdateContents; override;
    procedure UserTextChanged; override;
  end;

{ TDBAxisGridLaInplaceTextEdit }

  TDBAxisGridLaInplaceTextEdit = class(TLaInplaceTextEdit)
  protected
    function DefaultCreateInternalEdit: TInplaceEdit; override;
  public
    constructor Create(AOwner: TComponent; InternalEditClass: TInplaceEditClass); overload; override;
    constructor Create(AOwner: TComponent); overload; override;
  end;

implementation

type
  TFieldBarEhCrack = class(TFieldBarEh);
  TGridAllFieldBarListEhCrack = class(TGridAllFieldBarListEh);
  TGridDisplayFieldBarsEhCrack = class(TGridDisplayFieldBarsEh);
  TGridVisibleFieldBarsEhCrack = class(TGridVisibleFieldBarsEh);

{ TDBAxisGridLineParamsEh }

constructor TDBAxisGridLineParamsEh.Create(AGrid: TCustomGridEh);
begin
  inherited Create(AGrid);
  FDataBoundaryColor := TAlphaColorRec.Null; 
end;

function TDBAxisGridLineParamsEh.GetDataBoundaryColor: TAlphaColor;
begin
  if DataBoundaryColor <> TAlphaColorRec.Null then
    Result := DataBoundaryColor
  else
  begin
    Result := DarkColor;
  end;
end;

function TDBAxisGridLineParamsEh.GetDataHorzLines: Boolean;
begin
  if DataHorzLinesStored
    then Result := FDataHorzLines
    else Result := DefaultDataHorzLines;
end;

function TDBAxisGridLineParamsEh.IsDataHorzLinesStored: Boolean;
begin
  Result := FDataHorzLinesStored;
end;

procedure TDBAxisGridLineParamsEh.SetDataHorzLines(const Value: Boolean);
begin
  if DataHorzLinesStored and (Value = FDataHorzLines) then Exit;
  DataHorzLinesStored := True;
  FDataHorzLines := Value;
  Grid.LayoutChanged;
end;

procedure TDBAxisGridLineParamsEh.SetDataHorzLinesStored(const Value: Boolean);
begin
  if (Value = True) and (IsDataHorzLinesStored = False) then
  begin
    FDataHorzLinesStored := True;
    FDataHorzLines := DefaultDataHorzLines;
    Grid.LayoutChanged;
  end else if (Value = False) and (IsDataHorzLinesStored = True) then
  begin
    FDataHorzLinesStored := False;
    FDataHorzLines := DefaultDataHorzLines;
    Grid.LayoutChanged;
  end;
end;

function TDBAxisGridLineParamsEh.DefaultDataHorzLines: Boolean;
begin
  raise Exception.Create('Realize DefaultDataHorzLines in an inherited class');
end;

function TDBAxisGridLineParamsEh.GetDataVertLines: Boolean;
begin
  if DataVertLinesStored
    then Result := FDataVertLines
    else Result := DefaultDataVertLines;
end;

function TDBAxisGridLineParamsEh.IsDataVertLinesStored: Boolean;
begin
  Result := FDataVertLinesStored;
end;

procedure TDBAxisGridLineParamsEh.SetDataVertLines(const Value: Boolean);
begin
  if DataVertLinesStored and (Value = FDataVertLines) then Exit;
  DataVertLinesStored := True;
  FDataVertLines := Value;
  Grid.Invalidate;
end;

procedure TDBAxisGridLineParamsEh.SetDataVertLinesStored(const Value: Boolean);
begin
  if (Value = True) and (IsDataVertLinesStored = False) then
  begin
    FDataVertLinesStored := True;
    FDataVertLines := DefaultDataVertLines;
    Grid.Invalidate;
  end else if (Value = False) and (IsDataVertLinesStored = True) then
  begin
    FDataVertLinesStored := False;
    FDataVertLines := DefaultDataVertLines;
    Grid.Invalidate;
  end;
end;

function TDBAxisGridLineParamsEh.DefaultDataVertLines: Boolean;
begin
  raise Exception.Create('Realize DefaultDataVertLines in an inherited class');
end;

function TDBAxisGridLineParamsEh.GetGrid: TCustomDataAxisGridEh;
begin
  Result := TCustomDataAxisGridEh(inherited Grid);
end;

function TDBAxisGridLineParamsEh.GetVertAreaContraVertColor: TAlphaColor;
begin
  Result := inherited GetVertAreaContraVertColor;
end;

procedure TDBAxisGridLineParamsEh.SetDataBoundaryColor(const Value: TAlphaColor);
begin
  if Value <> FDataBoundaryColor then
  begin
    FDataBoundaryColor := Value;
    Grid.Invalidate;
  end;
end;

function TDBAxisGridLineParamsEh.GetGridBoundaries: Boolean;
begin
  Result := FGridBoundaries;
end;

procedure TDBAxisGridLineParamsEh.SetGridBoundaries(const Value: Boolean);
begin
  if Value <> FGridBoundaries then
  begin
    FGridBoundaries := Value;
    Grid.Invalidate;
  end;
end;

{$REGION 'TCustomDataAxisGridEh'}

{ TCustomDataAxisGridEh }

constructor TCustomDataAxisGridEh.Create(AOwner: TComponent);
begin

  inherited Create(AOwner);

  FAcquireFocus := True;

  FFieldBarOptions := CreateFieldBarOptions();

  FStaticFieldBars := CreateStaticFieldBars();
  

  FTitle := CreateTitle;
  FTitle.Name := 'Title';

  FAllowedOperations := [TDataGridAllowedOperationEh.Insert,
                         TDataGridAllowedOperationEh.Update,
                         TDataGridAllowedOperationEh.Delete,
                         TDataGridAllowedOperationEh.Append];
  FAutoGeneratePropBars := True;

  inherited RowCount := 2;
  inherited ColCount := 2;
  FTableView := CreateGridTableView;

  FDynamicBarList := TList<TFieldBarEh>.Create;
  FDynamicFieldBars := CreateDynamicFieldBars(FDynamicBarList);
  FAllFieldBarList := TList<TFieldBarEh>.Create;
  FAllFieldBars := CreateAllFieldBarList(FAllFieldBarList);
  FDisplayFieldBarList := TList<TFieldBarEh>.Create;
  FDisplayFieldBars := CreateDisplayFieldBars(FDisplayFieldBarList);
  FVisibleFieldBarList := TList<TFieldBarEh>.Create;
  FVisibleFieldBars := CreateVisibleFieldBars(FVisibleFieldBarList);
end;

destructor TCustomDataAxisGridEh.Destroy;
begin
  Destroying;
  DataSource := nil;
  FStaticFieldBars.Clear;

  FreeAndNil(FFieldBarOptions);
  FreeAndNil(FVisibleFieldBars);

  FreeAndNil(FStaticFieldBars);
  FreeAndNil(FDynamicFieldBars);
  FreeAndNil(FDynamicBarList);
  FreeAndNil(FAllFieldBarList);
  FreeAndNil(FAllFieldBars);
  FreeAndNil(FVisibleFieldBars);
  FreeAndNil(FVisibleFieldBarList);
  FreeAndNil(FDisplayFieldBars);
  FreeAndNil(FDisplayFieldBarList);

  FreeAndNil(FTitle);

  inherited Destroy;
end;

function TCustomDataAxisGridEh.AcquireFocus: Boolean;
begin
  Result := True;
  if HasFocus or ((CellEditor <> nil) and CellEditor.IsFocused) then
    Exit;
  if FAcquireFocus and CanFocus and not (csDesigning in ComponentState) then
  begin
    SetFocus;
    Result := IsFocused or ((CellEditor <> nil) and CellEditor.IsFocused);
  end;
end;

function TCustomDataAxisGridEh.AcquireLayoutLock: Boolean;
begin
  Result := (FUpdateLock = 0) and (FLayoutLock = 0);
  if Result then BeginLayout;
end;

procedure TCustomDataAxisGridEh.BeginLayout;
begin
  if FStaticFieldBars = nil then Exit;

  BeginUpdate;
  if (FLayoutLock = 0) then
    StaticFieldBars.BeginUpdate;
  Inc(FLayoutLock);
end;

procedure TCustomDataAxisGridEh.BeginUpdate;
begin
  if FUpdateLock = 0 then
    FLayoutChangedInUpdateLock := False;
  Inc(FUpdateLock);
end;

procedure TCustomDataAxisGridEh.CancelLayout;
begin
  if FLayoutLock > 0 then
  begin
    if FLayoutLock = 1 then
      StaticFieldBars.EndUpdate;
    Dec(FLayoutLock);
    EndUpdate;
  end;
end;

procedure TCustomDataAxisGridEh.EndLayout;
begin
  if FStaticFieldBars = nil then Exit;

  if FLayoutLock > 0 then
  begin
    try
      try
        if FLayoutLock = 1 then
          InternalLayout;
      finally
        if FLayoutLock = 1 then
        begin
          FStaticFieldBars.EndUpdate;
          FLayoutChangedInUpdateLock := False;
        end;
      end;
    finally
      if FLayoutLock > 0 then
        Dec(FLayoutLock);
      EndUpdate;
    end;
  end;
end;

procedure TCustomDataAxisGridEh.EndUpdate;
begin
  if FUpdateLock > 0
    then Dec(FUpdateLock);
  if (FUpdateLock = 0) and
     FLayoutChangedInUpdateLock and
     not (csDestroying in ComponentState)
  then
  begin
    LayoutChanged;
    FLayoutChangedInUpdateLock := False;
  end;
end;

procedure TCustomDataAxisGridEh.DoTabAction(GoForward: Boolean; Shift: TShiftState);
begin
  raise Exception.Create('TCustomDataAxisGridEh.DoTabAction should be implemented');
end;

function TCustomDataAxisGridEh.FindNextCellPos(
  const RightToLeft, CheckNextCol, CheckNextRow, CheckTabStob: Boolean;
  out AColIndex, ARowIndex: Integer): Boolean;
begin
  raise Exception.Create('TCustomDataAxisGridEh.FindNextCellPos should be implemented');
end;

procedure TCustomDataAxisGridEh.DialogKey(var Key: Word; Shift: TShiftState);
begin
  if ContainsFocus then
  begin
    case Key of
      vkTab:
        if (TGridOptionEh.Tabs in Options) then
        begin
          DoTabAction(not (ssShift in Shift), Shift);
          Key := 0;
        end;

      vkReturn:
        if (Shift * [ssShift, ssAlt, ssCtrl] = [])  then
        begin
          if EditorMode then
          begin
            CheckHideEditor;
            Key := 0;
          end
          else if CanShowEditor then
          begin
            ShowEditor;
            Key := 0;
          end;
        end;

      vkEscape:
        if EditorMode then
        begin
          HideEditor(False);

          Key := 0;
        end;
    end;
  end;

  inherited DialogKey(Key, Shift);
end;

procedure TCustomDataAxisGridEh.KeyDown(var Key: Word; var KeyChar: WideChar;
  Shift: TShiftState);
var
  LControl: IControl;
begin
  if Key = 0 then
  begin
    if (KeyChar <> #0) and
       not EditorMode and
       not CurrentFieldBar.ReadOnly and
       CurrentFieldBar.ValidChar(KeyChar) then
    begin
      ShowEditor;
      if EditorMode then
      begin
        if Supports(CellEditor, IControl, LControl) then
          LControl.KeyDown(Key, KeyChar, Shift);
        KeyChar := #0;
      end;
    end;
  end;

  inherited KeyDown(Key, KeyChar, Shift);
end;

function TCustomDataAxisGridEh.CanEditAcceptKey(Key: Char): Boolean;
begin
  Result := True;
end;

function TCustomDataAxisGridEh.CanEditModifyColumn(Index: Integer): Boolean;
begin
  Result := False;
end;

function TCustomDataAxisGridEh.CanEditModify: Boolean;
begin
  Result := False;
end;

function TCustomDataAxisGridEh.CanShowEditor: Boolean;
begin
  Result := inherited CanShowEditor;

  if Result then
  begin
    Result := (VisibleFieldBars.Count > 0) and
              (CurrentFieldBar <> nil) and
              TableView.Active;
    Result := Result and CurrentFieldBar.CanEditShowListItem(CurrentListItemBar);
  end;
end;

function TCustomDataAxisGridEh.CanEditorMode: Boolean;
begin
  Result := False;
end;

procedure TCustomDataAxisGridEh.ColWidthsChanged;
begin
  inherited ColWidthsChanged;
end;

function TCustomDataAxisGridEh.CreateStaticFieldBars: TGridStaticFieldBarsEh;
begin
  Result := TGridStaticFieldBarsEh.Create(Self);
end;

function TCustomDataAxisGridEh.CreateDynamicFieldBars(ABaseList: TList<TFieldBarEh>): TGridDynamicFieldBarsEh;
begin
  Result := TGridDynamicFieldBarsEh.Create(Self, ABaseList);
end;

function TCustomDataAxisGridEh.CreateAllFieldBarList(ABaseList: TList<TFieldBarEh>): TGridAllFieldBarListEh;
begin
  Result := TGridAllFieldBarListEh.Create(Self, ABaseList);
end;

function TCustomDataAxisGridEh.CreateVisibleFieldBars(ABaseList: TList<TFieldBarEh>): TGridVisibleFieldBarsEh;
begin
  Result := TGridVisibleFieldBarsEh.Create(Self, ABaseList);
end;

function TCustomDataAxisGridEh.CreateDisplayFieldBars(ABaseList: TList<TFieldBarEh>): TGridDisplayFieldBarsEh;
begin
  Result := TGridDisplayFieldBarsEh.Create(Self, ABaseList);
end;

function TCustomDataAxisGridEh.CreateFieldBarOptions: TFieldBarOptionsEh;
begin
  Result := TFieldBarOptionsEh.Create(Self);
end;

function TCustomDataAxisGridEh.CreateTitle: TAxisGridTitleBarEh;
begin
  Result := TAxisGridTitleBarEh.Create(Self);
end;

procedure TCustomDataAxisGridEh.DeferLayout;
begin
end;

procedure TCustomDataAxisGridEh.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
end;

function TCustomDataAxisGridEh.GetDataSource: TComponent;
begin
  Result := TableView.DataSource;
end;

procedure TCustomDataAxisGridEh.SetDataSource(Value: TComponent);
begin
  TableView.DataSource := Value;
end;

function TCustomDataAxisGridEh.GetEditLimit: Integer;
begin
  Result := 0;
end;

function TCustomDataAxisGridEh.GetEditMask(AColIndex, ARowIndex: Integer): string;
begin
  Result := 'Must be rewritten in the inherited class';
end;

function TCustomDataAxisGridEh.GetEditText(AColIndex, ARowIndex: Integer): string;
begin
  Result := 'Must be rewritten in the inherited class';
end;

procedure TCustomDataAxisGridEh.InternalLayout;
begin
  if (csLoading in ComponentState) or
     (csDestroying in ComponentState) or
     (Canvas = nil)
  then
    Exit;

  try
    RebindFieldBarsFields;
    if (FVisibleBarListNeedUpdate) then
      UpdateVisibleFieldBarList();

  finally
  end;

  Invalidate;
end;

procedure TCustomDataAxisGridEh.RebindFieldBarsFields;
var
  i: Integer;
begin
  for i := 0 to FieldBars.Count - 1 do
  begin
    FieldBars[I].BindField;
  end;
end;

procedure TCustomDataAxisGridEh.UpdateDynamicBarList();
var
  NewFieldList: TList<TTableFieldLinkEh>;
  DynaListChanged: Boolean;
  Field: TTableFieldLinkEh;
  I: Integer;
  FieldBar: TFieldBarEh;
begin
  NewFieldList := TList<TTableFieldLinkEh>.Create;

  if (TableView.Active = True) then
  begin
    for I := 0 to TableView.Fields.Count - 1 do
    begin
      Field := TableView.Fields[I];
      if (StaticFieldBars.IndexOfByFieldName(Field.FieldName) = -1) then
        NewFieldList.Add(Field);
    end;
  end;

  DynaListChanged := False;
  if (FDynamicBarList.Count <> NewFieldList.Count) then
  begin
    DynaListChanged := True;
  end else
  begin
    for I := 0 to FDynamicBarList.Count - 1  do
    begin
      if (FDynamicBarList[I].Field <> NewFieldList[I]) then
      begin
        DynaListChanged := True;
        Break;
      end;
    end;
  end;

  if DynaListChanged then
  begin
    for I := 0 to FDynamicBarList.Count - 1 do
      FDynamicBarList[I].Free;
    FDynamicBarList.Clear;

    for I := 0 to NewFieldList.Count - 1 do
    begin
      FieldBar := CreateFieldBarByField(NewFieldList[I]);
      TFieldBarEhCrack(FieldBar).FieldName := NewFieldList[I].FieldName;
      TFieldBarEhCrack(FieldBar).SetGrid(Self, TInListFieldBarStateEh.DynamicState);
      FDynamicBarList.Add(FieldBar);
    end;

    DynamicBarListChanged();
  end;

  NewFieldList.Free;
end;

function TCustomDataAxisGridEh.CreateFieldBarByField(AField: TTableFieldLinkEh): TFieldBarEh;
var
  FieldBarClass: TFieldBarEhClass;
begin
  FieldBarClass := DynamicFieldBars.GetColumnClassByField(AField);
  Result := FieldBarClass.Create(nil);
end;

procedure TCustomDataAxisGridEh.DynamicBarListChanged();
begin
  if (csLoading in ComponentState) or
     (csDestroying in ComponentState) then
   Exit;

  UpdateBarList();
end;

procedure TCustomDataAxisGridEh.StaticBarListChanged();
begin
  if (csLoading in ComponentState) or
     (csDestroying in ComponentState) then
   Exit;

  UpdateBarList();
end;

procedure TCustomDataAxisGridEh.UpdateBarList();
var
  I: Integer;
  OldFAllFieldBarList: TList<TFieldBarEh>;
  ABarListChanged: Boolean;
begin
  OldFAllFieldBarList := TList<TFieldBarEh>.Create;
  try
  OldFAllFieldBarList.AddRange(FAllFieldBarList);

  FAllFieldBarList.Clear;

  for I := 0 to FStaticFieldBars.Count - 1 do
    FAllFieldBarList.Add(FStaticFieldBars[I]);

  if AutoGeneratePropBars then
  begin
    for I := 0 to FDynamicBarList.Count - 1 do
      FAllFieldBarList.Add(FDynamicBarList[I]);
  end;

  ABarListChanged := False;
  if OldFAllFieldBarList.Count <> FAllFieldBarList.Count then
  begin
    ABarListChanged := True;
  end else
  begin
    for I := 0 to OldFAllFieldBarList.Count - 1 do
      if OldFAllFieldBarList[I] <> FAllFieldBarList[I] then
      begin
        ABarListChanged := True;
        Break;
      end;
  end;

  if ABarListChanged then
    FullFieldBarListChanged();

  finally
    OldFAllFieldBarList.Free;
  end;
end;

procedure TCustomDataAxisGridEh.FullFieldBarListChanged();
begin
  UpdateDisplayFieldBarList();
  UpdateVisibleFieldBarList();
  BarListChanged();
end;

procedure TCustomDataAxisGridEh.UpdateDisplayFieldBarList();
var
  I: Integer;
begin
  FDisplayFieldBarList.Clear;
  for I := 0 to FAllFieldBarList.Count - 1 do
    FDisplayFieldBarList.Add(FAllFieldBarList[I]);
  DisplayFieldBarListChanged();
end;

procedure TCustomDataAxisGridEh.UpdateVisibleFieldBarList();
var
  I: Integer;
  FieldBar: TFieldBarEh;
begin
  FVisibleFieldBarList.Clear;
  for I := 0 to FDisplayFieldBarList.Count - 1 do
  begin
    FieldBar := FDisplayFieldBarList[I];
    if (FieldBar.Visible = True) then
      FVisibleFieldBarList.Add(FDisplayFieldBarList[I]);
  end;

  TGridDisplayFieldBarsEhCrack(DisplayFieldBars).ResetIndexes;
  TGridVisibleFieldBarsEhCrack(VisibleFieldBars).ResetIndexes;

  FVisibleBarListNeedUpdate := False;
end;

procedure TCustomDataAxisGridEh.BarListChanged();
begin
  LayoutChanged;
end;

procedure TCustomDataAxisGridEh.Loaded;
begin
  inherited Loaded;
  CheckPropertiesConsistent();
  UpdateBarList();
  LayoutChanged();
  DeferLayout();
  ResetData();
end;

procedure TCustomDataAxisGridEh.CheckPropertiesConsistent();
begin

end;

procedure TCustomDataAxisGridEh.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TCustomDataAxisGridEh.MouseMove(Shift: TShiftState; X, Y: Single);
begin
  inherited MouseMove(Shift, X, Y);
end;

procedure TCustomDataAxisGridEh.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited MouseUp(Button, Shift, X, Y);
end;

procedure TCustomDataAxisGridEh.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) then
  begin
  end;
end;

procedure TCustomDataAxisGridEh.InvalidateEditor;
begin
  inherited InvalidateEditor;
end;

procedure TCustomDataAxisGridEh.SetStaticFieldBars(Value: TGridStaticFieldBarsEh);
begin
  FStaticFieldBars.Assign(Value);
end;

procedure TCustomDataAxisGridEh.SetColumnAttributes;
begin
  inherited;
end;

procedure TCustomDataAxisGridEh.KeyPropertyModified;
begin
end;

function TCustomDataAxisGridEh.StoreColumns: Boolean;
begin
  Result := False;
end;

procedure TCustomDataAxisGridEh.UpdateActive;
begin
end;

function TCustomDataAxisGridEh.GetEditorValue(InplaceEditor: TLaInplaceTextEdit): TValue;
begin
  Result := CellEditor.Text;
end;

procedure TCustomDataAxisGridEh.SaveEditorValue(EditorValue: TValue);
begin
  CurrentFieldBar.SetCurrentListItemValue(EditorValue);
end;

function TCustomDataAxisGridEh.GetIsEditorModified: Boolean;
begin
  Result := TableView.HasPendingData;
end;

procedure TCustomDataAxisGridEh.SetEditorModified(IsModified: Boolean);
begin
  if IsModified then
    TableView.MarkPendingData
  else
    TableView.ResetPendingData;
end;

procedure TCustomDataAxisGridEh.CheckWritePendingData;
begin
  TableView.WritePendingData;
end;

procedure TCustomDataAxisGridEh.WritePendingData;
begin
  SaveEditorData;
end;

procedure TCustomDataAxisGridEh.UpdateData;
begin
  SaveEditorData;
end;

procedure TCustomDataAxisGridEh.SetPaintColors;
begin
  inherited SetPaintColors;
end;

function TCustomDataAxisGridEh.GetIsLoaded: Boolean;
begin
  Result := not (csLoading in ComponentState);
end;

procedure TCustomDataAxisGridEh.Paint;
begin
  inherited Paint;
end;

function TCustomDataAxisGridEh.IsDrawCellBorder(AColIndex, ARowIndex: Integer; BorderType: TGridCellBorderTypeEh): Boolean;
var
  IsExtent: Boolean;
  BorderColor: TAlphaColor;
begin
  CheckDrawCellBorder(AColIndex, ARowIndex, BorderType, Result, BorderColor, IsExtent);
end;

function TCustomDataAxisGridEh.FindFieldColumn(const FieldName: String): TFieldBarEh;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to VisibleFieldBars.Count - 1 do
  begin
    if AnsiCompareText(VisibleFieldBars[i].FieldName, FieldName) = 0 then
    begin
      Result := VisibleFieldBars[i];
      Break;
    end;
  end;
end;

function TCustomDataAxisGridEh.GetFieldBarByFieldName(const FieldName: String): TFieldBarEh;
begin
  Result := FindFieldColumn(FieldName);
  if Result = nil then
    RaiseGridError('Format(EhLibLanguageConsts.FieldNameNotFound, [FieldName])');
end;

function TCustomDataAxisGridEh.IsSideParentableForProperty(
  const PropertyName: String): Boolean;
begin
  if PropertyName = 'DataSource'
    then Result := True
    else Result := False;
end;

procedure TCustomDataAxisGridEh.DoExit;
begin
  inherited DoExit;
end;

procedure TCustomDataAxisGridEh.DoEnter;
begin
  inherited DoEnter;
end;

procedure TCustomDataAxisGridEh.ShowEditor;
begin
  inherited ShowEditor;
end;

procedure TCustomDataAxisGridEh.HideEditor(const Accept: Boolean);
begin
  inherited HideEditor(Accept);
end;

procedure TCustomDataAxisGridEh.UpdateEdit;
begin
  inherited UpdateEdit;
end;

procedure TCustomDataAxisGridEh.UpdateText(EditorChanged: Boolean);
begin
  inherited UpdateText(EditorChanged);
end;

procedure TCustomDataAxisGridEh.GetMouseDownInfo(var Pos: TPoint; var Time: Integer);
begin
end;

function TCustomDataAxisGridEh.InplaceEditCanModify(Control: TWinControl): Boolean;
begin
  Result := True;
end;

procedure TCustomDataAxisGridEh.InplaceEditKeyDown(Control: TWinControl;
  var Key: Word; Shift: TShiftState);
begin
end;

procedure TCustomDataAxisGridEh.InplaceEditKeyPress(Control: TWinControl; var Key: Char);
begin
end;

procedure TCustomDataAxisGridEh.InplaceEditKeyUp(Control: TWinControl;
  var Key: Word; Shift: TShiftState);
begin

end;

function TCustomDataAxisGridEh.BoxRect(ALeft, ATop, ARight, ABottom: Integer): TRect;
begin
  Result := inherited BoxRect(ALeft, ATop, ARight, ABottom);
end;

function TCustomDataAxisGridEh.CellRect(AColIndex, ARowIndex: Integer; IncludeCellLines: Boolean = True): TRect;
begin
  Result := inherited CellRect(AColIndex, ARowIndex, False);
  if not IncludeCellLines then
    Result := ExcludeLinesFromCellRect(AColIndex, ARowIndex, Result);
end;

function TCustomDataAxisGridEh.CellRectAbs(AColIndex, ARowIndex: Integer; IncludeCellLines: Boolean = False): TRect;
begin
  Result := inherited CellRectAbs(AColIndex, ARowIndex, False);
  if not IncludeCellLines then
    Result := ExcludeLinesFromCellRect(AColIndex, ARowIndex, Result);
end;

function TCustomDataAxisGridEh.ExcludeLinesFromCellRect(AColIndex, ARowIndex: Integer; const CellRect: TRect): TRect;
begin
  Result := CellRect;
  if CheckCellLine(AColIndex, ARowIndex, TGridCellBorderTypeEh.Right) and
     (Result.Left + ColWidths[AColIndex] <= Result.Right) then
  begin
    if UseRightToLeftAlignment
      then Inc(Result.Left, GridLineWidth)
      else Dec(Result.Right, GridLineWidth)
  end;

  if CheckCellLine(AColIndex, ARowIndex, TGridCellBorderTypeEh.Bottom) then
    Dec(Result.Bottom, GridLineWidth);
end;

procedure TCustomDataAxisGridEh.KeyUp(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  inherited KeyUp(Key, KeyChar, Shift);
end;

procedure TCustomDataAxisGridEh.RolPosChanged(OldRowPosX, OldRowPosY: Integer);
begin
  inherited RolPosChanged(OldRowPosX, OldRowPosY);
end;

procedure TCustomDataAxisGridEh.ClientAreaSizeChanged;
begin
end;

function TCustomDataAxisGridEh.AllowedOperationUpdate: Boolean;
begin
  Result := False;
  if not TableView.Active then Exit;
  Result := (TDataGridAllowedOperationEh.Update in AllowedOperations) or
   (  not (TDataGridAllowedOperationEh.Update in AllowedOperations) and (TableView.CurrentRowView <> nil) and (TableView.CurrentRowView.EditState = TRowLinkEditStateEh.Insert));

  if TableView.FilteredRowList.Count = 0 then
  begin
    Result := Result and
              (TDataGridAllowedOperationEh.Insert in AllowedOperations) and
              (TDataGridAllowedOperationEh.Append in AllowedOperations);
  end;
end;

procedure TCustomDataAxisGridEh.FlatChanged;
begin
end;

function TCustomDataAxisGridEh.InplaceEditorVisible: Boolean;
begin
  Result := (CellEditor <> nil) and (CellEditor.Visible);
end;

procedure TCustomDataAxisGridEh.SetReadOnly(const Value: Boolean);
begin
  if Value <> FReadOnly then
  begin
    FReadOnly := Value;
    Invalidate();
    if not (csReading in ComponentState) and
       not (csLoading in ComponentState) then
    begin
      SetColumnAttributes;
    end;
  end;
end;

procedure TCustomDataAxisGridEh.SetFieldBarOptions(const Value: TFieldBarOptionsEh);
begin
  FFieldBarOptions.Assign(Value);
end;

procedure TCustomDataAxisGridEh.SetTitle(const Value: TAxisGridTitleBarEh);
begin
  FTitle.Assign(Value);
end;

procedure TCustomDataAxisGridEh.InvalidateCol(AColIndex: Integer);
begin
  inherited InvalidateCol(AColIndex);
end;

procedure TCustomDataAxisGridEh.InvalidateRow(ARowIndex: Integer);
begin
  inherited InvalidateRow(ARowIndex);
end;

procedure TCustomDataAxisGridEh.InvalidateCell(AColIndex, ARowIndex: Integer);
begin
  if (AColIndex >= 0) and
     (AColIndex < FullColCount) and
     (ARowIndex >= 0) and
     (ARowIndex < FullRowCount)
  then
    inherited InvalidateCell(AColIndex, ARowIndex);
end;

function TCustomDataAxisGridEh.CreateGridTableView: TDataAxisGridTableViewEh;
begin
  Result := TDataAxisGridTableViewEh.Create(Self);
end;

function TCustomDataAxisGridEh.GetDataCellHorzOffset(AFieldBar: TFieldBarEh): Integer;
begin
  Result := 3;
end;

procedure TCustomDataAxisGridEh.CancelEditing;
begin
  TableView.CancelCurrentRow;
end;

function TCustomDataAxisGridEh.DefaultTitleAlignment: TAlignment;
begin
  Result := taLeftJustify;
end;

function TCustomDataAxisGridEh.DefaultTitleColor: TAlphaColor;
begin
  Result := FixedColor;
end;

function TCustomDataAxisGridEh.GetSelectionInactiveColor: TAlphaColor;
begin
  Result := TAlphaColorRec.Gray;
end;

function TCustomDataAxisGridEh.GetSelectionColor: TAlphaColor;
begin
  Result := TAlphaColorRec.Blue;
end;

function TCustomDataAxisGridEh.AxisColumnsStorePropertyName: String;
begin
  Result := '<Define property Name>';
end;

function TCustomDataAxisGridEh.GetCurrentFieldBar: TFieldBarEh;
begin
  Result := nil;
end;

function TCustomDataAxisGridEh.GetCurrentListItemBar: TTableRowViewEh;
begin
  Result := nil;
end;

procedure TCustomDataAxisGridEh.FocusCell(AColIndex, ARowIndex: Integer; MoveAnchor: Boolean);
begin
  inherited FocusCell(AColIndex, ARowIndex, MoveAnchor);
end;

procedure TCustomDataAxisGridEh.FontChanged;
begin
  inherited FontChanged;
  Title.RefreshDefaultFont;
  FieldBarOptions.RefreshDefaultFont;
end;

function TCustomDataAxisGridEh.CreateGridLineOptions: TGridLineOptionsEh;
begin
  Result := TDBAxisGridLineParamsEh.Create(Self);
end;

function TCustomDataAxisGridEh.GetGridLineParams: TDBAxisGridLineParamsEh;
begin
  Result := TDBAxisGridLineParamsEh(inherited GridLineOptions);
end;

procedure TCustomDataAxisGridEh.SetGridLineParams(const Value: TDBAxisGridLineParamsEh);
begin
  inherited GridLineOptions := Value;
end;

procedure TCustomDataAxisGridEh.SetAllowedOperations(const Value: TDataGridAllowedOperationsEh);
begin
  if FAllowedOperations <> Value then
  begin
    FAllowedOperations := Value;
  end;
end;

procedure TCustomDataAxisGridEh.SetAutoGeneratePropBars(const Value: Boolean);
begin
  if (FAutoGeneratePropBars <> Value) then
  begin
    FAutoGeneratePropBars := Value;
    DynamicBarListChanged();
  end;
end;

function TCustomDataAxisGridEh.MouseCellIsLink: Boolean;
begin
  Result := MouseCellIsTextLink or MouseCellIsImageLink;
end;

function TCustomDataAxisGridEh.MouseCellIsTextLink: Boolean;
begin
  Result := False;
end;

function TCustomDataAxisGridEh.MouseCellIsImageLink: Boolean;
begin
  Result := False;
end;

function TCustomDataAxisGridEh.GetRestoreStateControl: TObject;
begin
  Result := nil;
end;

function TCustomDataAxisGridEh.DataSetActive: Boolean;
begin
  Result := (TableView <> nil) and TableView.Active;
end;

procedure TCustomDataAxisGridEh.FieldBarChanged(AFieldBar: TFieldBarEh; CellLayoutAffects: Boolean = False);
begin
  LayoutChanged(CellLayoutAffects);
end;

procedure TCustomDataAxisGridEh.FieldBarVisibleStateChanged(AFieldBar: TFieldBarEh);
begin
  DisplayFieldBarListChanged;
  LayoutChanged;
end;

procedure TCustomDataAxisGridEh.SourceFieldListChanged;
begin

end;

procedure TCustomDataAxisGridEh.DoAddObject(const AObject: TFmxObject);
begin
  inherited DoAddObject(AObject);
end;

procedure TCustomDataAxisGridEh.DoBeforeFirstDrawing;
begin
  inherited DoBeforeFirstDrawing;
  TGridAllFieldBarListEhCrack(FieldBars).DoBeforeFirstDrawing;
end;

procedure TCustomDataAxisGridEh.SetNewScene(AScene: IScene);
begin
  inherited SetNewScene(AScene);
end;

procedure TCustomDataAxisGridEh.DisplayFieldBarListChanged;
begin
  FVisibleBarListNeedUpdate := True;
end;

procedure TCustomDataAxisGridEh.AllFieldBarPropsEndUpdate;
var
  I: Integer;
begin
  for I := 0 to FieldBars.Count - 1 do
    TFieldBarEhCrack(FieldBars[I]).UpdateDisplayIndex;

  TGridDisplayFieldBarsEhCrack(DisplayFieldBars).UpdateDisplayOrderFromDisplayIndex;
end;

procedure TCustomDataAxisGridEh.InternalLayoutChanged(CellLayoutAffects: Boolean = False);
begin
  if AcquireLayoutLock then
    EndLayout
  else if FUpdateLock > 0 then
    FLayoutChangedInUpdateLock := True;
end;

procedure TCustomDataAxisGridEh.LayoutChanged(CellLayoutAffects: Boolean = False);
begin
  InternalLayoutChanged(CellLayoutAffects);
  if CellLayoutAffects then
    SetCellLayoutAffects();
  GridLayoutChanged();
end;

procedure TCustomDataAxisGridEh.SetCellLayoutAffects();
begin
end;

procedure TCustomDataAxisGridEh.LinkActive(Value: Boolean);
begin
  if (csDestroying in ComponentState) then Exit;
  if not Value and EditorMode then HideEditor(False);

  LayoutChanged;

  if Value and
     CanEditorMode and
     (TGridOptionEh.AlwaysShowEditor in Options)
  then
    ShowEditor;

  if not (csLoading in ComponentState) then
    TGridAllFieldBarListEhCrack(FieldBars).LinkActiveChanged;
end;

procedure TCustomDataAxisGridEh.ResetData;
begin
  TableViewDataChanged(TTableLinkEventTypeEh.Reset, -1, -1, nil);
end;

procedure TCustomDataAxisGridEh.Resize;
begin
  inherited Resize;
  LayoutChanged;
end;

procedure TCustomDataAxisGridEh.TableViewDataChanged(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowView: TTableRowViewEh);
begin
  if (csLoading in ComponentState) then Exit;

  if (AChangedType = TTableLinkEventTypeEh.Reset) then
  begin
    CancelEditor();
    UpdateDynamicBarList();
    LinkActive(TableView.Active);
    LayoutChanged;
  end
  else if AChangedType = TTableLinkEventTypeEh.RowAdded then
  begin
    LayoutChanged;
  end
  else if AChangedType = TTableLinkEventTypeEh.RowDeleted then
  begin
    LayoutChanged;
  end
  else if AChangedType = TTableLinkEventTypeEh.WritePendingData then
  begin
    WritePendingData;
  end
  else
  begin
    InvalidateGrid;
  end;

  if Assigned(OnTableViewDataChanged) then
    OnTableViewDataChanged(Self, AChangedType, NewIndex, OldIndex);
end;

function TCustomDataAxisGridEh.GetDynaFieldBarClassByField(AField: TTableFieldLinkEh): TFieldBarEhClass;
begin
  Result := nil;
end;

procedure TCustomDataAxisGridEh.HandleDataCellGetValue(Params: TDataAxisGridGetBarValueParamsEh);
begin
end;

procedure TCustomDataAxisGridEh.HandleDataCellInitEditParams(AParams: TDataAxisCellEditParamsEh);
begin
end;

procedure TCustomDataAxisGridEh.HandleDataCellInTextLinkClick(Params: TDataAxisCellInTextLinkClickParamsEh);
begin
end;

procedure TCustomDataAxisGridEh.HandleDataCellSetValue(Params: TDataAxisGridSetBarValueParamsEh);
begin
end;

procedure TCustomDataAxisGridEh.HandleDataCellStartEdit(Params: TDataAxisCellStartEditParamsEh);
begin
end;

procedure TCustomDataAxisGridEh.HandleDataCellGetDisplayText(Params: TDataAxisGridGetDisplayTextParamsEh);
begin
end;

procedure TCustomDataAxisGridEh.HandleDataCellGetStyleParams(Params: TDataAxisCellStyleParamsEh);
begin
end;

procedure TCustomDataAxisGridEh.GetFieldBarListItemBarAtPos(AGridColIndex, AGridRowIndex: Integer;
  out AFieldBar: TFieldBarEh; out ARecordBar: TTableRowViewEh);
begin
  AFieldBar := nil;
  ARecordBar := nil;
end;

procedure TCustomDataAxisGridEh.ComposeDataCellMenu(ACellParams: TDataAxisCellComposeContextMenuParamsEh);
begin

end;

{$REGION TreeViewArea}
function TCustomDataAxisGridEh.GetAxisDataTreeViewAreaParams(AFieldBar: TFieldBarEh;
  ARecordBar: TTableRowViewEh): TDataAxisCellTreeViewAreaParamsEh;
begin
  Result := nil;
end;

procedure TCustomDataAxisGridEh.ProcessGetDataTreeViewAreaParams(Params: TDataAxisCellTreeViewAreaParamsEh);
begin
end;

procedure TCustomDataAxisGridEh.ProcessSetDataTreeSignState(Params: TDataAxisCellTreeSignStateParamsEh);
begin
end;
{$ENDREGION TreeViewArea}

function TCustomDataAxisGridEh.GetDataCellHighlightingText: String;
begin
  Result := '';
end;

procedure TCustomDataAxisGridEh.HandleDataCellKeyDownEvent(Params: TBaseGridCellKeyDownParamsEh);
begin
end;

procedure TCustomDataAxisGridEh.HandleDataCellMouseDownEvent(Params: TGridCellMouseButtonParamsEh);
begin
end;

procedure TCustomDataAxisGridEh.HandleDataCellMouseClickEvent(Params: TGridCellMouseButtonParamsEh);
begin
end;

procedure TCustomDataAxisGridEh.DataOrPositionChanged();
begin
  RaiseCurrentChangedEvent();
end;

procedure TCustomDataAxisGridEh.RaiseCurrentChangedEvent();
begin
  if csDestroying in ComponentState then Exit;
  HandleCurrentPosChange();
end;

procedure TCustomDataAxisGridEh.HandleCurrentPosChange();
begin
end;

procedure TCustomDataAxisGridEh.CurrentCellMoved(OldCurrent: TGridCoord);
begin
  inherited CurrentCellMoved(OldCurrent);

  if (CurColIndex = OldCurrent.X) and (CurRowIndex = OldCurrent.Y) then Exit;
  RaiseCurrentChangedEvent();
end;

function TCustomDataAxisGridEh.CreateDataCellKeyDownParams(AGrid: TControl;
  AColIndex, ARowIndex, AAreaColIndex, AAreaRowIndex: Integer): TBaseGridCellKeyDownParamsEh;
begin
  Result := TBaseGridCellKeyDownParamsEh.Create;
end;

procedure TCustomDataAxisGridEh.HandleCanModifyCellValue(AParams: TDataAxisCellCanModifyParamsEh);
begin
end;

function TCustomDataAxisGridEh.IsShowFocusLayerForCell(ACell: TGridBaseCellEh): Boolean;
begin
  if TableView.Rows.Count > 0 then
  begin
    if (CurrentListItemBar = nil) or (CurrentFieldBar = nil) then
      Result := False
    else    
      Result := inherited IsShowFocusLayerForCell(ACell);
  end else
  begin
    Result := inherited IsShowFocusLayerForCell(ACell);
  end;
end;

procedure TCustomDataAxisGridEh.ApplyStyle;
begin
  inherited ApplyStyle;
end;

procedure TCustomDataAxisGridEh.StyleApplied;
begin
  inherited StyleApplied;
  FieldBarOptions.RefreshDefaultFill();
end;

function TCustomDataAxisGridEh.GetListItemDirection: TGridListItemDirectionEh;
begin
  Result := TGridListItemDirectionEh.Vertical;
end;

{$ENDREGION 'TCustomDataAxisGridEh'}

{ TDBAxisGridInplaceEdit }

constructor TDBAxisGridInplaceEdit.Create(Owner: TComponent);
begin
  inherited Create(Owner);
end;

destructor TDBAxisGridInplaceEdit.Destroy;
begin
  inherited Destroy;
end;

procedure TDBAxisGridInplaceEdit.KeyDown(var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  if not FFieldBar.ValidChar(KeyChar) then
    KeyChar := #0;
  inherited KeyDown(Key, KeyChar, Shift);
end;

procedure TDBAxisGridInplaceEdit.UpdateContents;
var
  Grid: TCustomDataAxisGridEh;
begin
  Grid := TCustomDataAxisGridEh(Self.Grid);
  FFieldBar := Grid.CurrentFieldBar;

  InternalSetText(FFieldBar.GetListItemEditText(Grid.CurrentListItemBar));
  MaxLength := Grid.GetEditLimit;
  Grid.SetEditorModified(False)
end;

procedure TDBAxisGridInplaceEdit.UserTextChanged;
var
  Grid: TCustomDataAxisGridEh;
  DataCell: TDataAxisCellEh;
begin
  Grid := TCustomDataAxisGridEh(Self.Grid);
  if (Grid = nil) then Exit;

  DataCell := Cell as TDataAxisCellEh;
  if (DataCell.StartEdit() = True) then
    Grid.SetEditorModified(True)
  else
    raise Exception.Create('TDBAxisGridInplaceEdit.UserTextChanged: TDataLink is not in Edit Mode.');
end;

{ TDBAxisGridLaInplaceTextEdit }

constructor TDBAxisGridLaInplaceTextEdit.Create(AOwner: TComponent; InternalEditClass: TInplaceEditClass);
begin
  inherited Create(AOwner, InternalEditClass);
end;

constructor TDBAxisGridLaInplaceTextEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

function TDBAxisGridLaInplaceTextEdit.DefaultCreateInternalEdit: TInplaceEdit;
begin
  Result := TDBAxisGridInplaceEdit.Create(Self);
end;

{ TDataAxisGridTableViewEh }

constructor TDataAxisGridTableViewEh.Create(AGrid: TCustomDataAxisGridEh);
begin
  inherited Create(AGrid);
  FGrid := AGrid;
end;

destructor TDataAxisGridTableViewEh.Destroy;
begin
  inherited Destroy;
end;

procedure TDataAxisGridTableViewEh.DataNotification(AChangedType: TTableLinkEventTypeEh;
  NewIndex, OldIndex: Integer; ARowView: TTableRowViewEh);
begin
  TCustomDataAxisGridEh(FGrid).TableViewDataChanged(AChangedType, NewIndex, OldIndex, ARowView);
end;

end.
