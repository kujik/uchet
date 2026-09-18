{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{             EhLibFmx.CustomDataVertGrids              }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.CustomDataVertGrids;

interface

{$SCOPEDENUMS ON}

{$REGION 'uses'}
uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, System.Types,
  FMX.Graphics, System.UITypes, System.Math, FMX.Forms, System.Contnrs,
  EhLibUtils, DBUtilsEh,
  EhLib.TableLinks,
  EhLib.GridTableViews,

  EhLibFmx.LaHostVirtualPanels,
  EhLibFmx.Types,

  EhLibFmx.GridAxisData,
  EhLibFmx.Grids,
  EhLibFmx.Grid.Types,
  EhLibFmx.DataAxisGrids,
  EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.Grid.CellManagers,
  EhLibFmx.Grid.ToolControls,

  EhLibFmx.DataVertGrid.Rows,
  EhLibFmx.DataVertGrid.Columns,
  EhLibFmx.DataVertGrid.RowsHeader,
  EhLibFmx.DataVertGrid.GridManagers,
  EhLibFmx.DataVertGrid.ToolControls
  ;
{$ENDREGION 'uses'}

type
  TCustomDataVertGridEh = class;

{ TCustomDataVertGridEh }

  TCustomDataVertGridEh = class(TCustomDataAxisGridEh)
  private
    FCenter: TDataVertGridCenterEh;
    FCurrentColViewIndex: Integer;
    FGridDataColCount: Integer;
    FGridDataRowCount: Integer;
    FStartDataColIndex: Integer;
    FStartDataRowIndex: Integer;
    FStartListItemIndex: Integer;

    function GetCurrentColumn: TDataVertGridColumnEh;
    function GetCurrentRow: TDataVertGridBaseRowEh;
    function GetCurrentRowIndex: Integer;
    function GetRowOptions: TDataVertGridRowOptionsEh;
    function GetRows: TDataVertGridAllRowsEh;
    function GetRowsHeader: TDataVertGridRowsHeaderEh;
    function GetStaticRows: TDataVertGridStaticRowsEh;
    function GetVisibleRows: TDataVertGridVisibleRowsEh;
    function GetVisibleVisibleColumns: TDataVertGridColumnsEh;
    procedure SetColCount(NewColCount: Integer);
    procedure SetCurrentColumn(const Value: TDataVertGridColumnEh);
    procedure SetCurrentRowIndex(const Value: Integer);
    procedure SetRowOptions(const Value: TDataVertGridRowOptionsEh);
    procedure SetRowsHeader(const Value: TDataVertGridRowsHeaderEh);
    procedure SetStaticRows(const Value: TDataVertGridStaticRowsEh);
    function GetGridLineOptions: TDataVertGridLineOptionsEh;
    procedure SetGridLineOptions(const Value: TDataVertGridLineOptionsEh);
    procedure SetCenter(const Value: TDataVertGridCenterEh);
    function GetDisplayRows: TDataVertGridDisplayRowsEh;
    function GetAutoGenerateRows: Boolean;
    procedure SetAutoGenerateRows(const Value: Boolean);

  protected
    FGridDataColWidths: TIntegerDynArray;
    FRowHeightRecalcNeeded: Boolean;

    function CreateFieldBarOptions: TFieldBarOptionsEh; override;
    function CreateGridTableView(): TDataAxisGridTableViewEh; override;
    function CreateTitle(): TAxisGridTitleBarEh; override;
    function GetCurrentFieldBar(): TFieldBarEh; override;
    function GetCurrentListItemBar(): TTableRowViewEh; override;
    function GetDynaFieldBarClassByField(AField: TTableFieldLinkEh): TFieldBarEhClass; override;
    function InternalGetCellManagerAt(VirtPanel: TLaHostVirtualPanelEh; AColIndex, ARowIndex: Integer): TVPBaseCellManagerEh; override;
    function CreateGridLineOptions: TGridLineOptionsEh; override;
    function GetCellContentTextValue(Params: TBaseGridInitCellContentParamsEh): String; override;
    function GetListItemDirection: TGridListItemDirectionEh; override;

    function CalcRowsHeaderWidth(): Integer; virtual;

    procedure ApplyStyle; override;
    procedure CalcSizingState(X, Y: Integer; var State: TBaseGridMouseStateEh; var Index: Integer; var SizingPos, SizingOfs: Integer); override;
    procedure DoTabAction(GoForward: Boolean; Shift: TShiftState); override;
    procedure GetFieldBarListItemBarAtPos(AGridColIndex, AGridRowIndex: Integer; out AFieldBar: TFieldBarEh; out AListItemBar: TTableRowViewEh); override;
    procedure InteractiveSetColWidth(ColIndex: Integer; Value: Integer); override;
    procedure KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure Resize; override;
    procedure TableViewDataChanged(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer; ARowView: TTableRowViewEh); override;
    procedure UpdateViewLayout(); override;
    procedure UpdateVisibleFieldBarList(); override;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    procedure UpdateScrollBarPanels; override;

    procedure AddChildComponent(const Element: TComponent);
    procedure BuildHeaderCellPopupMenu(Params: TDataVertGridRowHeaderCellContextMenuParamsEh); virtual;
    procedure ComposeHeaderCellMenu(Params: TDataVertGridRowHeaderCellComposeContextMenuParamsEh); virtual;
    procedure HandleGetDataCellManager(Params: TBaseDataVertGridGetDataCellManagerParamsEh); virtual;
    procedure InvalidateRowHeight();
    procedure SetDataColCount(NewDataColCount: Integer);
    procedure UpdateCurrentColViewIndex();
    procedure UpdateGridColumnCount();
    procedure UpdateGridColumnWidths();
    procedure UpdateGridRowHeights();

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;

    procedure InteractiveFocusCell(AColIndex, ARowIndex: Integer; ActionSource: TInteractiveActionSourceEh); override;

    function DataToRawRowIndex(ADataRowIndex: Integer): Integer;
    function RawToDataRowIndex(ARowIndex: Integer): Integer;
    function MoveBy(Distance: Integer): Integer;
    function GridDataColIndexToVisibleColumnsIndex(AGridDataColIndex: Integer): Integer;
    function ShowCustomizeRowsDialog: Boolean; virtual;

    property AutoGenerateRows: Boolean read GetAutoGenerateRows write SetAutoGenerateRows default True;
    property CurrentColumn: TDataVertGridColumnEh read GetCurrentColumn write SetCurrentColumn;
    property CurrentRow: TDataVertGridBaseRowEh read GetCurrentRow;
    property CurrentRowIndex: Integer read GetCurrentRowIndex write SetCurrentRowIndex;
    property GridDataColCount: Integer read FGridDataColCount;
    property GridDataRowCount: Integer read FGridDataRowCount;
    property GridLineOptions: TDataVertGridLineOptionsEh read GetGridLineOptions write SetGridLineOptions;
    property RowOptions: TDataVertGridRowOptionsEh read GetRowOptions write SetRowOptions;
    property Rows: TDataVertGridAllRowsEh read GetRows;
    property RowsHeader: TDataVertGridRowsHeaderEh read GetRowsHeader write SetRowsHeader;
    property StartDataColIndex: Integer read FStartDataColIndex;
    property StartDataRowIndex: Integer read FStartDataRowIndex;
    property StartListItemIndex: Integer read FStartListItemIndex;
    property StaticRows: TDataVertGridStaticRowsEh read GetStaticRows write SetStaticRows;
    property VisibleColumns: TDataVertGridColumnsEh read GetVisibleVisibleColumns;
    property VisibleRows: TDataVertGridVisibleRowsEh read GetVisibleRows;
    property Center: TDataVertGridCenterEh read FCenter write SetCenter;
    property DisplayRows: TDataVertGridDisplayRowsEh read GetDisplayRows;
  end;

implementation

uses
  Data.DBConsts,
  FMX.DialogService,
  EhLibLangConsts,
  EhLibFmx.DataVertGrids,
  EhLibFmx.ImageReses;

type
  TDataVertGridRowsHeaderEhCrack = class(TDataVertGridRowsHeaderEh);
  TDataVertGridRowHeaderEhCrack = class(TDataVertGridRowHeaderEh);
  TDataVertGridBaseRowEhCrack = class(TDataVertGridBaseRowEh);

{$REGION 'TCustomDataVertGridEh'}

{ TCustomDataVertGridEh }

constructor TCustomDataVertGridEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FStartDataRowIndex := FixedRowCount;
  Center := TDataVertGridCenterEh.DefaultGridManager;

  Options := [
    TGridOptionEh.DrawFocusSelected,
    TGridOptionEh.Editing,
    TGridOptionEh.Tabs
    ];

  InvalidateRowHeight();
end;

destructor TCustomDataVertGridEh.Destroy;
begin
  Destroying;

  DataSource := nil;
  Center := nil;

  inherited Destroy;
end;

function TCustomDataVertGridEh.GetVisibleRows: TDataVertGridVisibleRowsEh;
begin
  Result := TDataVertGridVisibleRowsEh(VisibleFieldBars);
end;

function TCustomDataVertGridEh.GetRows: TDataVertGridAllRowsEh;
begin
  Result := TDataVertGridAllRowsEh(FieldBars);
end;

function TCustomDataVertGridEh.GetRowsHeader: TDataVertGridRowsHeaderEh;
begin
  Result := TDataVertGridRowsHeaderEh(inherited Title);
end;

procedure TCustomDataVertGridEh.SetRowsHeader(const Value: TDataVertGridRowsHeaderEh);
begin
  inherited Title := Value;
end;

function TCustomDataVertGridEh.GetRowOptions: TDataVertGridRowOptionsEh;
begin
  Result := TDataVertGridRowOptionsEh(FieldBarOptions);
end;

procedure TCustomDataVertGridEh.SetRowOptions(const Value: TDataVertGridRowOptionsEh);
begin
  FieldBarOptions := Value;
end;

function TCustomDataVertGridEh.CreateFieldBarOptions: TFieldBarOptionsEh;
begin
  Result := TDataVertGridRowOptionsEh.Create(Self);
end;

function TCustomDataVertGridEh.GetStaticRows: TDataVertGridStaticRowsEh;
begin
  Result := TDataVertGridStaticRowsEh(StaticFieldBars);
end;

procedure TCustomDataVertGridEh.SetStaticRows(const Value: TDataVertGridStaticRowsEh);
begin
  StaticRows.Assign(Value);
end;

function TCustomDataVertGridEh.ShowCustomizeRowsDialog: Boolean;
begin
  Result := Center.ShowCustomizeColumnsDialog(Self);
end;

function TCustomDataVertGridEh.GetVisibleVisibleColumns: TDataVertGridColumnsEh;
begin
  Result := TDataVertGridColumnsEh(TableView.FilteredRowList);
end;

procedure TCustomDataVertGridEh.HandleGetDataCellManager(Params: TBaseDataVertGridGetDataCellManagerParamsEh);
begin
end;

function TCustomDataVertGridEh.CreateGridTableView: TDataAxisGridTableViewEh;
begin
  Result := TDataVertGridColumnsViewEh.Create(Self);
end;

function TCustomDataVertGridEh.GetDisplayRows: TDataVertGridDisplayRowsEh;
begin
  Result := TDataVertGridDisplayRowsEh(DisplayFieldBars);
end;

function TCustomDataVertGridEh.GetDynaFieldBarClassByField(AField: TTableFieldLinkEh): TFieldBarEhClass;
begin
  if (AField.DataTypeInfo = TypeInfo(Boolean)) or
     ((AField.DataTypeInfo = TypeInfo(Variant)) and (AField.DataVarSubtype = varBoolean)) then
    Result := TDataVertGridCheckboxRowEh
  else if (AField.DataTypeInfo = TypeInfo(TInterfacedImageStreamEh)) then
    Result := TDataVertGridGraphicRowEh
  else
    Result := TDataVertGridStringRowEh;
end;

procedure TCustomDataVertGridEh.GetFieldBarListItemBarAtPos(AGridColIndex, AGridRowIndex: Integer;
  out AFieldBar: TFieldBarEh; out AListItemBar: TTableRowViewEh);
var
  ADataColIndex, ADataRowIndex: Integer;
begin
  ADataColIndex := AGridColIndex - StartDataColIndex + StartListItemIndex;
  ADataRowIndex := AGridRowIndex - StartDataRowIndex;

  if (ADataColIndex >= 0) and (ADataColIndex < VisibleColumns.Count)
    then AListItemBar := VisibleColumns[ADataColIndex]
    else AListItemBar := nil;

  if (ADataRowIndex >= 0) and (ADataRowIndex < VisibleRows.Count)
    then AFieldBar := VisibleRows[ADataRowIndex]
    else AFieldBar := nil;
end;

function TCustomDataVertGridEh.InternalGetCellManagerAt(VirtPanel: TLaHostVirtualPanelEh; AColIndex,
  ARowIndex: Integer): TVPBaseCellManagerEh;
var
  ALocalColIndex, ALocalRowIndex: Integer;
  Row: TDataVertGridBaseRowEh;
begin
  if VirtPanel = HFixedVDataPanel then 
  begin
    ALocalColIndex := AColIndex - VirtPanel.InGridStartCol;
    ALocalRowIndex := ARowIndex - VirtPanel.InGridStartRow;
    Result := RowsHeader.GetCellManagerAt(ALocalColIndex, ALocalRowIndex);
  end
  else if VirtPanel = HDataVDataPanel then 
  begin
    ALocalColIndex := AColIndex - VirtPanel.InGridStartCol;
    ALocalRowIndex := ARowIndex - VirtPanel.InGridStartRow;
    if (TableView.Active = True) then
    begin
      if ARowIndex < VisibleRows.Count
        then Row := VisibleRows[ALocalRowIndex]
        else Row := nil;
      if Row <> nil
        then Result := Row.GetCellManagerAt(ALocalColIndex)
        else Result := inherited InternalGetCellManagerAt(VirtPanel, AColIndex, ARowIndex);
    end else
    begin
      Result := inherited InternalGetCellManagerAt(VirtPanel, AColIndex, ARowIndex);
    end;
  end else
  begin
    Result := inherited InternalGetCellManagerAt(VirtPanel, AColIndex, ARowIndex);
  end;
end;

procedure TCustomDataVertGridEh.UpdateViewLayout;
var
  NewRowCount: Integer;

  procedure SetRowsCount(ARowCount, AFixedRowCount, AContraRowCount: Integer);
  begin
    if ARowCount <= FixedRowCount then
      FixedRowCount := ARowCount - 1;
    FixedRowCount := AFixedRowCount;
    RowCount := ARowCount;
    FGridDataRowCount := RowCount;
    ContraRowCount := AContraRowCount;
  end;

begin
  if RowsHeader.Visible then
  begin
    TDataVertGridRowsHeaderEhCrack(RowsHeader).FHeaderColIndex := 0;
    if FStartDataColIndex <> 1 then
    begin
      FStartDataColIndex := 1;
      RaiseCurrentChangedEvent();
    end;
  end else
  begin
    TDataVertGridRowsHeaderEhCrack(RowsHeader).FHeaderColIndex := -1;
    if FStartDataColIndex <> 0 then
    begin
      FStartDataColIndex := 0;
      RaiseCurrentChangedEvent();
    end;
  end;

  if FStartDataRowIndex <> 0 then
  begin
    FStartDataRowIndex := 0;
    RaiseCurrentChangedEvent();
  end;

  if (VisibleRows.Count > 0)
    then NewRowCount := VisibleRows.Count
    else NewRowCount := 1;

  SetRowsCount(NewRowCount + FStartDataRowIndex, FStartDataRowIndex, ContraRowCount);

  UpdateGridColumnCount;
  UpdateGridColumnWidths();
  UpdateGridRowHeights();

  inherited UpdateViewLayout;
end;

procedure TCustomDataVertGridEh.UpdateScrollBarPanels;
var
  OldVertScrollWidth: Single;
begin
  OldVertScrollWidth := VertScrollBarPanelControl.Width;
  inherited UpdateScrollBarPanels;
  if OldVertScrollWidth <> VertScrollBarPanelControl.Width then
    LayoutChanged;
end;

function TCustomDataVertGridEh.CreateTitle: TAxisGridTitleBarEh;
begin
  Result := TDataVertGridRowsHeaderEh.Create(Self);
end;

procedure TCustomDataVertGridEh.UpdateGridColumnCount;

  procedure ResetFixedColumns;
  begin
    FrozenColCount := 0;
    FixedColCount := StartDataColIndex;
    FrozenColCount := 0;
  end;

  procedure UpdateBaseDataRowHeights();
  var
    i: Integer;
    DataColCount: Integer;
  begin
    DataColCount := ColCount - StartDataColIndex;
    for i := 0 to DataColCount - 1 do
    begin
    end;
  end;

var
  NewDataColCount: Integer;
  t: Integer;
  ARowsHeaderWidth: Integer;
begin
  if TableView = nil then Exit;

  ResetFixedColumns();

  ContraColCount := 0;

  t := ColWidths[0];
  DefaultColWidth := 100;
  if RowsHeader.Visible then
    ColWidths[0] := t;
  NewDataColCount := 1;
  FStartListItemIndex := TableView.CurrentRowViewIndex;
  SetDataColCount(NewDataColCount);

  if RowsHeader.Visible then
  begin
    ARowsHeaderWidth := RowsHeader.Width;
    ColWidths[0] := ARowsHeaderWidth;
    VisibleRows.UpdateTitleMetrics;
  end;

  if not IsCanvasEnabled then Exit;

  Invalidate();
end;

procedure TCustomDataVertGridEh.UpdateGridColumnWidths();
var
  I: Integer;
  AColIndex: Integer;
  WeightViewWidth: Integer;
  NewColWidth: Integer;
  RestBit: Integer;
begin
  if (RowsHeader.HeaderColIndex <> -1) then
  begin
    ColWidths[RowsHeader.HeaderColIndex] := RowsHeader.Width + GridLineWidth;
  end;

  WeightViewWidth := HorzAxis.RollClientLen;
  NewColWidth := WeightViewWidth div GridDataColCount;
  RestBit := WeightViewWidth mod GridDataColCount;

  SetLength(FGridDataColWidths, GridDataColCount);

  for I := 0 to GridDataColCount - 1 do
  begin
    FGridDataColWidths[I] := NewColWidth - GridLineWidth;
    if RestBit > 0 then
    begin
      FGridDataColWidths[I] := FGridDataColWidths[I] + 1;
      RestBit := RestBit - 1;
    end;
  end;

  for I := 0 to GridDataColCount - 1 do
  begin
    AColIndex := StartDataColIndex + I;
    ColWidths[AColIndex] := FGridDataColWidths[I];
  end;
end;

procedure TCustomDataVertGridEh.Resize;
begin
  inherited Resize;
  InvalidateRowHeight();
end;

procedure TCustomDataVertGridEh.InvalidateRowHeight;
begin
  FRowHeightRecalcNeeded := True;
  LayoutChanged(True);
end;

procedure TCustomDataVertGridEh.UpdateVisibleFieldBarList;
begin
  inherited UpdateVisibleFieldBarList;
  InvalidateRowHeight();
end;

procedure TCustomDataVertGridEh.UpdateGridRowHeights();
var
  I: Integer;
  ARowIndex: Integer;
  RowHeight, MaxRowHeight: Integer;
  ColWidth: Integer;
  RowHeader: TDataVertGridRowHeaderEhCrack;
  Row: TDataVertGridBaseRowEhCrack;
  CI: Integer;
begin
  if FRowHeightRecalcNeeded then
  begin
    FRowHeightRecalcNeeded := False;

    for I := 0 to VisibleRows.Count - 1 do
    begin
      if RowsHeader.HeaderColIndex <> -1 then
      begin
        ColWidth := RowsHeader.Width;
        RowHeader := TDataVertGridRowHeaderEhCrack(VisibleRows[I].Header);
        RowHeader.FCellHeight := RowHeader.CalcCellHeight(Canvas, ColWidth);
      end;
    end;

    for I := 0 to VisibleRows.Count - 1 do
    begin
      Row := TDataVertGridBaseRowEhCrack(VisibleRows[I]);
      MaxRowHeight := Row.Header.CellHeight;
      for CI := 0 to GridDataColCount - 1 do
      begin
        RowHeight := Row.CalcDataCellHeight(Canvas, CI);
        if RowHeight > MaxRowHeight then
          MaxRowHeight := RowHeight;
      end;

      Row.FActualHeight := MaxRowHeight;
    end;
  end;

  for I := 0 to VisibleRows.Count - 1 do
  begin
    Row := TDataVertGridBaseRowEhCrack(VisibleRows[I]);
    ARowIndex := StartDataRowIndex + I;
    RowHeights[ARowIndex] := Row.ActualHeight + GridLineWidth;
  end;
end;

procedure TCustomDataVertGridEh.SetDataColCount(NewDataColCount: Integer);
begin
  SetColCount(NewDataColCount + StartDataColIndex);
  FGridDataColCount := NewDataColCount;
end;

procedure TCustomDataVertGridEh.SetCenter(const Value: TDataVertGridCenterEh);
begin
  if FCenter = Value then Exit;
  if FCenter <> nil then
    FCenter.RemoveChangeNotification(Self);
  FCenter := Value;
  if Value <> nil then
    FCenter.AddChangeNotification(Self);
end;

procedure TCustomDataVertGridEh.SetColCount(NewColCount: Integer);
begin
  if NewColCount <> RowCount then
  begin
    if NewColCount <= CurColIndex then
      MoveColRow(NewColCount - 1, CurRowIndex, False, False);
    ColCount := NewColCount;
    AdjustMaxTopLeft(True, True, not IsSmoothHorzScroll, not IsSmoothVertScroll);
  end;
end;

function TCustomDataVertGridEh.CalcRowsHeaderWidth: Integer;
begin
  Result := 120;
end;

procedure TCustomDataVertGridEh.CalcSizingState(X, Y: Integer; var State: TBaseGridMouseStateEh; var Index, SizingPos,
  SizingOfs: Integer);
begin
  inherited CalcSizingState(X, Y, State, Index, SizingPos, SizingOfs);
  if State = GridMouseStateManage.NormalState then
  begin
    if (X > HorzAxis.FixedBoundary - 7) and (X < HorzAxis.FixedBoundary + 7) then
    begin
      State := GridMouseStateManage.ColSizingState;
      SizingPos := HorzAxis.FixedBoundary;
      SizingOfs := HorzAxis.FixedBoundary - X;
      Index := 0;
    end;
  end;
end;

function TCustomDataVertGridEh.GetCurrentFieldBar: TFieldBarEh;
begin
  Result := GetCurrentRow;
end;

function TCustomDataVertGridEh.GetCurrentRow: TDataVertGridBaseRowEh;
begin
  if (CurrentRowIndex >= 0) and (VisibleRows.Count > 0) then
    Result := VisibleRows[CurrentRowIndex]
  else
    Result := nil;
end;

function TCustomDataVertGridEh.GetCurrentListItemBar: TTableRowViewEh;
begin
  Result := GetCurrentColumn;
end;

function TCustomDataVertGridEh.GetCurrentRowIndex: Integer;
begin
  Result := RawToDataRowIndex(CurRowIndex);
end;

procedure TCustomDataVertGridEh.SetCurrentRowIndex(const Value: Integer);
begin
  InteractiveFocusCell(CurColIndex, DataToRawRowIndex(Value), TInteractiveActionSourceEh.Other);
end;

function TCustomDataVertGridEh.RawToDataRowIndex(ARowIndex: Integer): Integer;
begin
  Result := ARowIndex - FStartDataRowIndex;
end;

function TCustomDataVertGridEh.DataToRawRowIndex(ADataRowIndex: Integer): Integer;
begin
  Result := ADataRowIndex + FStartDataRowIndex;
end;

function TCustomDataVertGridEh.GridDataColIndexToVisibleColumnsIndex(AGridDataColIndex: Integer): Integer;
begin
  Result := AGridDataColIndex + StartListItemIndex;
end;

procedure TCustomDataVertGridEh.SetCurrentColumn(const Value: TDataVertGridColumnEh);
var
  ColIndex: Integer;
begin
  if Value = nil then
  begin
    TableView.CurrentRowViewIndex := -1;
  end else
  begin
    ColIndex := VisibleColumns.IndexOf(Value);
    if ColIndex >= 0 then
      TableView.CurrentRowViewIndex := ColIndex
    else
      raise Exception.Create('TCustomDataGridEh.SetCurrentRow: DataGridRow is not in the list of Rows');
  end;
end;

function TCustomDataVertGridEh.GetCurrentColumn: TDataVertGridColumnEh;
begin
  if (VisibleColumns.Count > 0) and
     (TableView.CurrentRowViewIndex >= 0) and
     (TableView.CurrentRowViewIndex < VisibleColumns.Count)
  then
    Result := VisibleColumns[TableView.CurrentRowViewIndex]
  else
    Result := nil;
end;

procedure TCustomDataVertGridEh.TableViewDataChanged(AChangedType: TTableLinkEventTypeEh; NewIndex, OldIndex: Integer;
  ARowView: TTableRowViewEh);
begin
  inherited TableViewDataChanged(AChangedType, NewIndex, OldIndex, ARowView);

  if AChangedType = TTableLinkEventTypeEh.Reset then
  begin
    InvalidateRowHeight();
    LayoutChanged;
    RaiseCurrentChangedEvent();
  end;

  if (AChangedType = TTableLinkEventTypeEh.Reset) or
     (AChangedType = TTableLinkEventTypeEh.RowAdded) or
     (AChangedType = TTableLinkEventTypeEh.RowDeleted) then
  begin
    InvalidateRowHeight();
    UpdateGridColumnCount();
    UpdateCurrentColViewIndex();
    RaiseCurrentChangedEvent();
  end
  else if (AChangedType = TTableLinkEventTypeEh.RowChanged) or
          (AChangedType = TTableLinkEventTypeEh.RowStateChanged) then
  begin
    if CurrentColumn = ARowView then
      RaiseCurrentChangedEvent();

    InvalidateRowHeight();
  end
  else if AChangedType = TTableLinkEventTypeEh.CurrentPosChanged then
  begin
    UpdateCurrentColViewIndex();
    InvalidateRowHeight();
  end;

  Invalidate;
end;

procedure TCustomDataVertGridEh.InteractiveFocusCell(AColIndex, ARowIndex: Integer;
  ActionSource: TInteractiveActionSourceEh);
begin
  if not TableView.Active then Exit;

  if (ARowIndex <> CurRowIndex) then
  begin
    CheckWritePendingData;
    MoveColRow(CurColIndex, ARowIndex, True, True);
  end;

  MoveBy(AColIndex - CurColIndex);
end;

procedure TCustomDataVertGridEh.InteractiveSetColWidth(ColIndex, Value: Integer);
begin
  if ColIndex = RowsHeader.HeaderColIndex then
  begin
    RowsHeader.Width := Value;
  end else
  begin
    inherited InteractiveSetColWidth(ColIndex, Value);
  end;
end;

function TCustomDataVertGridEh.MoveBy(Distance: Integer): Integer;
begin
  Result := 0;
  if (Distance = 0) then Exit;
  Result := TableView.MoveRowPosBy(Distance);
end;

procedure TCustomDataVertGridEh.UpdateCurrentColViewIndex();
var
  NewGridCol: Integer;
//  ShowCol: Boolean;
  NewCurrentColViewIndex: Integer;
begin
  if TableView = nil then Exit;
  NewCurrentColViewIndex := -1;

  if TableView.Active then
  begin
    NewCurrentColViewIndex := TableView.CurrentRowViewIndex;
    if NewCurrentColViewIndex < 0 then NewCurrentColViewIndex := -1;

    FStartListItemIndex := NewCurrentColViewIndex;
    NewGridCol := StartDataColIndex;
    MoveColRow(NewGridCol, CurRowIndex, True, True);
  end;

  if NewCurrentColViewIndex <> FCurrentColViewIndex then
  begin
    FCurrentColViewIndex := NewCurrentColViewIndex;
    RaiseCurrentChangedEvent;
  end;
end;

procedure TCustomDataVertGridEh.KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  if [ssShift, ssAlt, ssCtrl] * Shift = [] then
  begin
    case Key of
      vkUp:
      begin
        
      end;

      vkDown:
      begin
        
      end;

      vkLeft:
      begin
        MoveBy(-1);
        Key := 0;
      end;

      vkRight:
      begin
        MoveBy(1);
        Key := 0;
      end;

      vkHome:
      begin
        Key := 0;
      end;

      vkEnd:
      begin
        Key := 0;
      end;

      vkNext:
      begin
      end;

      vkPrior:
      begin
      end;

      vkInsert:
      begin
        Key := 0;
      end;

      vkTab:
      begin
      end;

      vkReturn:
      begin
      end;

      vkEscape:
      begin
        TableView.CancelCurrentRow();
        CheckHideEditor();
        Key := 0;
      end;

      vkF2:
      begin
        EditorMode := True;
        Key := 0;
      end;

      vkDelete:
      begin
        Key := 0;
      end;

      vkAdd, vkSubtract, vkMultiply:
      begin
        Key := 0;
      end;
    end; 
  end;

  inherited KeyDown(Key, KeyChar, Shift);
end;

procedure TCustomDataVertGridEh.DoTabAction(GoForward: Boolean; Shift: TShiftState);
var
  NextRow: TDataVertGridBaseRowEh;
begin
  BeginUpdate;
  try
    NextRow := VisibleRows.GetNextTabRow(VisibleRows[CurrentRowIndex], GoForward);
    if NextRow = VisibleRows[CurrentRowIndex] then
    begin
      if GoForward then
      begin
        MoveBy(1);
        NextRow := VisibleRows.GetFirstTabRow;
      end else
      begin
        MoveBy(-1);
        NextRow := VisibleRows.GetLastTabRow;
      end;
      if NextRow <> nil then
        CurrentRowIndex := NextRow.VisibleIndex;
    end
    else if NextRow <> nil then
    begin
      CurrentRowIndex := NextRow.VisibleIndex;
    end;
  finally
    EndUpdate;
  end;
  if EditorMode then
    UpdateEdit;
end;

procedure TCustomDataVertGridEh.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  Row: TDataVertGridBaseRowEh;
  I: Integer;
begin
  for I := 0 to StaticRows.Count - 1 do
  begin
    Row:= StaticRows[I];
    Proc(Row);
  end;
end;

procedure TCustomDataVertGridEh.AddChildComponent(const Element: TComponent);
begin
  StaticRows.Add(Element as TDataVertGridBaseRowEh)
end;

procedure TCustomDataVertGridEh.SetGridLineOptions(const Value: TDataVertGridLineOptionsEh);
begin
  inherited GridLineOptions := Value;
end;

function TCustomDataVertGridEh.GetGridLineOptions: TDataVertGridLineOptionsEh;
begin
  Result := TDataVertGridLineOptionsEh(inherited GridLineOptions);
end;

function TCustomDataVertGridEh.CreateGridLineOptions: TGridLineOptionsEh;
begin
  Result := TDataVertGridLineOptionsEh.Create(Self);
end;

function TCustomDataVertGridEh.GetAutoGenerateRows: Boolean;
begin
  Result := AutoGeneratePropBars;
end;

procedure TCustomDataVertGridEh.SetAutoGenerateRows(const Value: Boolean);
begin
  AutoGeneratePropBars := Value;
end;

function TCustomDataVertGridEh.GetCellContentTextValue(Params: TBaseGridInitCellContentParamsEh): String;
begin
  Result := '';
end;

procedure TCustomDataVertGridEh.ApplyStyle;
begin
  inherited ApplyStyle;
end;

procedure TCustomDataVertGridEh.BuildHeaderCellPopupMenu(Params: TDataVertGridRowHeaderCellContextMenuParamsEh);
begin
end;

procedure TCustomDataVertGridEh.ComposeHeaderCellMenu(Params: TDataVertGridRowHeaderCellComposeContextMenuParamsEh);
begin
  Center.BuildTitleCellPopupMenu(Params);
end;

function TCustomDataVertGridEh.GetListItemDirection: TGridListItemDirectionEh;
begin
  Result := TGridListItemDirectionEh.Horizontal;
end;

{$ENDREGION 'TCustomDataVertGridEh'}

end.
