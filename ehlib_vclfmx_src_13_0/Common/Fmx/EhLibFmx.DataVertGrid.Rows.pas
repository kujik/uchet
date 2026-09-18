{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{              EhLibFmx.DataVertGrid.Rows               }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataVertGrid.Rows;

{$I ..\Incl\EhLib.Inc}
{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, System.Types,
  FMX.Graphics, System.UITypes, System.Math, FMX.Forms, System.Contnrs,
  FMX.Platform, Data.DB, System.Variants,
  System.Generics.Collections, System.Rtti,
  EhLibUtils,
  DBUtilsEh,
  MemTreeEh,
  EhLib.TableLinks,
  EhLib.GridTableViews,
  EhLibFmx.Types,
  EhLibFmx.LaObjects,
  EhLibFmx.LaControls,
  EhLibFmx.LaHostVirtualPanels,
  EhLibFmx.ToolControls,
  EhLibFmx.Grid.ToolControls,
  EhLibFmx.Grid.CellManagers,

  EhLibFmx.Grid.Types,
  EhLibFmx.Grids,

  EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.DataAxisGrid.ToolControls,
  EhLibFmx.DataAxisGrid.DataCells,
  EhLibFmx.DataAxisGrids,

  EhLibFmx.DataVertGrid.Columns
  ;


type
  TDataVertGridStaticRowsEh = class;
  TDataVertGridBaseRowEh = class;

{ TRowFieldBarEnumeratorEh }

  TRowFieldBarEnumeratorEh = class(TEnumerator<TDataVertGridBaseRowEh>)
  private
    FFieldBarEnumerator: TEnumerator<TFieldBarEh>;
  protected
    function DoGetCurrent: TDataVertGridBaseRowEh; override;
    function DoMoveNext: Boolean; override;
  public
    constructor Create(AFieldBarEnumerator: TEnumerator<TFieldBarEh>);
    destructor Destroy; override;

    property Current: TDataVertGridBaseRowEh read DoGetCurrent;
  end;

{ TDataVertGridDataCellParamsEh }

  TDataVertGridDataCellParamsEh = class(TPersistent)
  private
    FColumn: TDataVertGridBaseRowEh;

  public
    property Row: TDataVertGridBaseRowEh read FColumn;
  end;

{ TBaseDataVertGridGetDataCellManagerParamsEh }

  TBaseDataVertGridGetDataCellManagerParamsEh = class(TPersistent)
  private
    FRow: TDataVertGridBaseRowEh;
    FColumn: TDataVertGridColumnEh;
    FGrid: TControl;
    FCellManager: TBaseGridCellManagerEh;

  public
    procedure Init(AGrid: TControl; ARow: TDataVertGridBaseRowEh; AColumn: TDataVertGridColumnEh; ADefaultCellManager: TBaseGridCellManagerEh); virtual;

    property Grid: TControl read FGrid;
    property Row: TDataVertGridBaseRowEh read FRow;
    property Column: TDataVertGridColumnEh read FColumn;
    property CellManager: TBaseGridCellManagerEh read FCellManager write FCellManager;
  end;

{ TDataVertGridRowsListEh }

  TDataVertGridRowsListEh = class(TFieldBarsListEh)
  private
    function GetColumn(Index: TListItemIndex): TDataVertGridBaseRowEh;
    procedure SetColumn(Index: TListItemIndex; const Value: TDataVertGridBaseRowEh);
  public
    constructor Create; overload;

    property Items[Index: TListItemIndex]: TDataVertGridBaseRowEh read GetColumn write SetColumn; default;
  end;

{ TDataVertGridRowHeaderEh }

  TDataVertGridRowHeaderEh = class(TFieldBarTitleEh)
  private

    function GetRow: TDataVertGridBaseRowEh;

  protected
    FCellHeight: Integer;

    procedure HandleGetCellManager(Params: TPersistent); virtual;
    procedure HandleInitCellContent(Params: TPersistent); virtual;

  public
    constructor Create(FieldBar: TFieldBarEh);
    destructor Destroy; override;

    function GetCellManager: TBaseGridCellManagerEh; virtual;
    function CalcCellHeight(ACanvas: TCanvas; ACellWidth: Integer): Integer;

    procedure PrepareToDestroy;

    property Row: TDataVertGridBaseRowEh read GetRow;
    property CellHeight: Integer read FCellHeight;

  published
  end;

{ TDataVertGridBaseRowEh }

  TDataVertGridBaseRowEh = class(TFieldBarEh)
  private
    FWidth: Single;
    FWidthStored: Boolean;

    function GetIsSelected: Boolean;
    function GetHeader: TDataVertGridRowHeaderEh;
    function GetWidth: Single;
    function IsWidthStored: Boolean;

    procedure SetIsSelected(const Value: Boolean);
    procedure SetHeader(const Value: TDataVertGridRowHeaderEh);
    procedure SetWidth(const Value: Single);
    procedure WidthChanged;

  protected
    FActualHeight: Integer;
    FDefCellManager: TBaseGridCellManagerEh;
    FIsSelectedInternal: Boolean;
    FSizeCalculatorCellObject: TVPBaseCellHolderEh;

    function CreateTitle: TFieldBarTitleEh; override;

    function CreateCellManager: TBaseGridCellManagerEh; virtual;
    function CreateGetCellManagerParams(): TBaseDataVertGridGetDataCellManagerParamsEh; virtual;
    function CreateCellEditParams(): TBaseGridCellEditParamsEh; virtual;
    function CreateInitEditorParams(): TBaseGridInitEditorParamsEh; virtual;
    function GetCellManagerAtListItemBar(AListItemBar: TTableRowViewEh): TBaseGridCellManagerEh; override;

    procedure DoBeforeFirstDrawing; override;
    procedure FieldChanged; override;
    procedure FieldNameChanged; override;
    procedure HandleDataCellKeyDownEvent(Params: TBaseGridCellKeyDownParamsEh); override;
    procedure LinkActiveChanged; override;
    procedure RefreshDefaultPadding(); override;
    procedure SetParentComponent(Value: TComponent); override;
    procedure UpdateDefaults; override;

    procedure CheckInitWidth;
    procedure HandleGetDataCellManager(Params: TBaseDataVertGridGetDataCellManagerParamsEh); virtual;
    procedure HandleInitDataCell(Params: TPersistent); virtual;
    procedure HandleInitCellEditor(AParams: TBaseGridInitEditorParamsEh); override;

    procedure HeightAutoExpandChanged(); override;
    procedure InitWidth;
    procedure ProcessDataCellKeyDown(Params: TBaseGridCellKeyDownParamsEh); virtual;
    procedure ProcessGetCellManager(Params: TBaseDataVertGridGetDataCellManagerParamsEh); virtual;

  public
    constructor Create(AOwner: TComponent); overload; override;
    constructor CreateWith(AOwner: TComponent; AParent: TComponent); overload;

    destructor Destroy; override;

    function HasParent: Boolean; override;
    function GetParentComponent: TComponent; override;

    function CalcDefaultRowHeight(Canvas: TCanvas): Integer;
    function CalcNeededDataCellWidth(ACanvas: TCanvas; ADataRowIndex: Integer): Integer;
    function CalcDataCellHeight(ACanvas: TCanvas; AGridDataColIndex: Integer): Integer;
    function CellHeightIsRowDependent(): Boolean;
    function DefaultWidth: Single; virtual;
    function GetCellManager(): TBaseGridCellManagerEh; virtual;
    function GetCellManagerAt(ADataColIndex: Integer): TVPBaseCellManagerEh; virtual;
    function GetCellManagerAtColumn(ARow: TDataVertGridColumnEh): TBaseGridCellManagerEh; virtual;
    function GetColValue(ARow: TDataVertGridColumnEh): TValue;

    procedure ClampInView;
    procedure InitCell(ACell: TGridBaseCellEh; AStyleParams: TDataAxisCellStyleParamsEh); override;
    procedure DefaultInitCellEditor(AParams: TBaseGridInitEditorParamsEh); virtual;
    procedure MTViewDataEvent(RowNum: Integer; Event: TMTViewEventTypeEh; OldRowNum: Integer);
    procedure OptimizeWidth; virtual;
    procedure RemoveColumn(); virtual;

    property IsSelected: Boolean read GetIsSelected write SetIsSelected;
    property ActualHeight: Integer read FActualHeight;

  published

    property FieldName;
    property Fill;
    property FillStored;
    property Font;
    property FontColor;
    property FontColorStored;
    property FontStored;
    property HeightAutoExpand;
    property HeightAutoExpandStored;
    property HorzAlign;
    property HorzAlignStored;
    property Padding;
    property PaddingStored;
    property PopupMenu;
    property ReadOnly;
    property Header: TDataVertGridRowHeaderEh read GetHeader write SetHeader;
    property Tooltips;
    property TooltipsStored;
    property VertAlign;
    property VertAlignStored;
    property Visible;
    property Width: Single read GetWidth write SetWidth stored IsWidthStored;
  end;

  TColumnEhClass = class of TDataVertGridBaseRowEh;

{ TDataVertGridStaticRowsEh }

  TDataVertGridStaticRowsEh = class(TGridStaticFieldBarsEh)
  private
    function GetRow(Index: Integer): TDataVertGridBaseRowEh;
  protected
  public
    constructor Create(AGrid: TCustomGridEh); reintroduce; virtual;
    destructor Destroy; override;

    procedure RemoveRow(Row: TDataVertGridBaseRowEh);
    procedure SetOrder(Rows: TArray<TDataVertGridBaseRowEh>);
    procedure CreateAllFromDynamic();

    procedure Add(Row: TDataVertGridBaseRowEh);
    property Row[Index: Integer]: TDataVertGridBaseRowEh read GetRow; default;
  end;

{ TDataGridAllColumnsEh }

  TDataVertGridAllRowsEh = class(TGridAllFieldBarListEh)
  private
    function GetItem(Index: Integer): TDataVertGridBaseRowEh;

  protected

  public
    procedure RefreshTitleDefaultFont; override;
    procedure RefreshTitleDefaultPadding; override;
    procedure RefreshTitleDefaultFill; override;

    function RowByFieldName(FieldName: String): TDataVertGridBaseRowEh;
    function RowByName(ColName: String): TDataVertGridBaseRowEh;

    function FindRowByFieldName(FieldName: String): TDataVertGridBaseRowEh;
    function FindRowByName(ColName: String): TDataVertGridBaseRowEh;

    property Items[Index: Integer]: TDataVertGridBaseRowEh read GetItem; default;
  end;

{ TDataGridDisplayColumnsEh }

  TDataVertGridDisplayRowsEh = class(TGridDisplayFieldBarsEh)
  private
    function GetItem(Index: Integer): TDataVertGridBaseRowEh;
  public
    constructor Create(AGrid: TControl; AList: TList<TFieldBarEh>);
    destructor Destroy; override;
    procedure SetRowsOrder(AOrderedList: TList<TDataVertGridBaseRowEh>); overload;

    property Items[Index: Integer]: TDataVertGridBaseRowEh read GetItem; default;
  end;

{ TDataGridVisibleColumnsEh }

  TDataVertGridVisibleRowsEh = class(TGridVisibleFieldBarsEh)
  private
    function GetItem(Index: Integer): TDataVertGridBaseRowEh;
  public
    constructor Create(AGrid: TControl; AList: TList<TFieldBarEh>);
    destructor Destroy; override;

    function GetFirstTabRow: TDataVertGridBaseRowEh;
    function GetLastTabRow: TDataVertGridBaseRowEh;
    function GetNextTabRow(ForRow: TDataVertGridBaseRowEh; GoForward: Boolean): TDataVertGridBaseRowEh;
    function GetEnumerator: TRowFieldBarEnumeratorEh;

    procedure MoveRow(Column: TDataVertGridBaseRowEh; NewVisibleIndex: Integer);
    procedure MoveRows(ColumnList: TDataVertGridRowsListEh; NewVisibleIndex: Integer);
    procedure UpdateActualWidths();
    procedure UpdateTitleMetrics();

    property Items[Index: Integer]: TDataVertGridBaseRowEh read GetItem; default;
  end;

{ TDataVertGridDynamicRowsEh }

  TDataVertGridDynamicRowsEh = class(TGridDynamicFieldBarsEh)
  protected
  public
    constructor Create(AGrid: TControl; AList: TList<TFieldBarEh>);
    destructor Destroy; override;

    function GetColumnClassByField(AField: TTableFieldLinkEh): TFieldBarEhClass; override;
  end;

implementation

uses
  EhLibFmx.CustomDataVertGrids,
  EhLibFmx.DataVertGrid.ToolControls,
  EhLibFmx.DataVertGrid.RowsHeader;

type
  TCustomDataVertGridEhCrack = class(TCustomDataVertGridEh);
  TDataVertGridRowHeaderEhCrack = class(TDataVertGridRowHeaderEh);

{ TDataVertGridRowsListEh }

constructor TDataVertGridRowsListEh.Create;
begin
  inherited Create;
end;

function TDataVertGridRowsListEh.GetColumn(Index: TListItemIndex): TDataVertGridBaseRowEh;
begin
  Result := TDataVertGridBaseRowEh(inherited Items[Index]);
end;

procedure TDataVertGridRowsListEh.SetColumn(Index: TListItemIndex; const Value: TDataVertGridBaseRowEh);
begin
  inherited Items[Index] := Value;
end;

{ TColumnsEh }

constructor TDataVertGridStaticRowsEh.Create(AGrid: TCustomGridEh);
begin
  inherited Create(AGrid);
end;

destructor TDataVertGridStaticRowsEh.Destroy;
begin
  inherited Destroy;
end;

procedure TDataVertGridStaticRowsEh.Add(Row: TDataVertGridBaseRowEh);
begin
  inherited Add(Row);
end;

function TDataVertGridStaticRowsEh.GetRow(Index: Integer): TDataVertGridBaseRowEh;
begin
  Result := TDataVertGridBaseRowEh(FieldBar[Index]);
end;

procedure TDataVertGridStaticRowsEh.RemoveRow(Row: TDataVertGridBaseRowEh);
begin
  InternalRemove(Row);
end;

procedure TDataVertGridStaticRowsEh.SetOrder(Rows: TArray<TDataVertGridBaseRowEh>);
var
  I: Integer;
  FieldBars: TArray<TFieldBarEh>;
begin
  SetLength(FieldBars, Length(Rows));
  for I := 0 to Length(Rows) - 1 do
    FieldBars[I] := Rows[I];
  inherited SetOrder(FieldBars);
end;

procedure TDataVertGridStaticRowsEh.CreateAllFromDynamic;
var
  NewFieldList: TList<TTableFieldLinkEh>;
  Field: TTableFieldLinkEh;
  I: Integer;
  FieldBar: TDataVertGridBaseRowEh;
  Grid: TCustomDataVertGridEhCrack;
begin
  Grid := TCustomDataVertGridEhCrack(Self.Grid);
  NewFieldList := TList<TTableFieldLinkEh>.Create;

  if (Grid.TableView.Active = True) then
  begin
    for I := 0 to Grid.TableView.Fields.Count - 1 do
    begin
      Field := Grid.TableView.Fields[I];
      if (IndexOfByFieldName(Field.FieldName) = -1) then
        NewFieldList.Add(Field);
    end;
  end;

  for I := 0 to NewFieldList.Count - 1 do
  begin
    FieldBar := Grid.CreateFieldBarByField(NewFieldList[I]) as TDataVertGridBaseRowEh;
    FieldBar.FieldName := NewFieldList[I].FieldName;
    Self.Add(FieldBar);
  end;

  NewFieldList.Free;
end;

{ TDataVertGridAllRowsEh }

function TDataVertGridAllRowsEh.FindRowByFieldName(FieldName: String): TDataVertGridBaseRowEh;
var
  I: Integer;
  Column: TDataVertGridBaseRowEh;
begin
  Result := nil;

  for I := 0 to Count - 1 do
  begin
    Column := Items[I];
    if Column.FieldName = FieldName then
    begin
      Result := Column;
      Exit;
    end;
  end;
end;

function TDataVertGridAllRowsEh.RowByFieldName(FieldName: String): TDataVertGridBaseRowEh;
begin
  Result := FindRowByFieldName(FieldName);

  if Result = nil then
    raise Exception.Create('TDataVertGridAllRowsEh.ColByFieldName: FieldName "' + FieldName + '" does not exists.');
end;

function TDataVertGridAllRowsEh.FindRowByName(ColName: String): TDataVertGridBaseRowEh;
var
  I: Integer;
  Column: TDataVertGridBaseRowEh;
begin
  Result := nil;

  for I := 0 to Count - 1 do
  begin
    Column := Items[I];
    if Column.Name = ColName then
    begin
      Result := Column;
      Exit;
    end;
  end;
end;

function TDataVertGridAllRowsEh.RowByName(ColName: String): TDataVertGridBaseRowEh;
begin
  Result := FindRowByName(ColName);

  if Result = nil then
    raise Exception.Create('TDataVertGridAllRowsEh.ColByName: ColName "' + ColName + '" does not exists.');
end;

function TDataVertGridAllRowsEh.GetItem(Index: Integer): TDataVertGridBaseRowEh;
begin
  Result := TDataVertGridBaseRowEh(inherited Items[Index]);
end;

procedure TDataVertGridAllRowsEh.RefreshTitleDefaultFill;
begin
  inherited RefreshDefaultFill;
end;

procedure TDataVertGridAllRowsEh.RefreshTitleDefaultFont;
begin
  inherited RefreshTitleDefaultFont;
end;

procedure TDataVertGridAllRowsEh.RefreshTitleDefaultPadding;
begin
  inherited RefreshTitleDefaultPadding;
end;

{ TDataVertGridRowHeaderEh }

constructor TDataVertGridRowHeaderEh.Create(FieldBar: TFieldBarEh);
begin
  inherited Create(FieldBar);
end;

destructor TDataVertGridRowHeaderEh.Destroy;
begin
  PrepareToDestroy;
  inherited Destroy;
end;

procedure TDataVertGridRowHeaderEh.PrepareToDestroy;
begin
end;

function TDataVertGridRowHeaderEh.GetCellManager: TBaseGridCellManagerEh;
var
  AGrid: TCustomDataVertGridEhCrack;
begin
  AGrid :=  TCustomDataVertGridEhCrack(Row.Grid);

  if AGrid <> nil
    then Result := AGrid.RowsHeader.DefaultCellManager
    else Result := nil;
end;

function TDataVertGridRowHeaderEh.CalcCellHeight(ACanvas: TCanvas; ACellWidth: Integer): Integer;
var
  Height: Single;
  Grid: TCustomDataVertGridEhCrack;
  CellLaObject: TVPBaseCellHolderEh;
  QrCellSize: TSizeF;
  ResCellSize: TSizeF;
  ACellManager: TVPBaseCellManagerEh;
begin
  Grid := TCustomDataVertGridEhCrack(Row.GetGrid);
  if Grid.HFixedVDataPanel = nil then Exit(0);

  QrCellSize := TSizeF.Create(ACellWidth, TLaControlEh.MaxSize.Height);
  ACellManager := GetCellManager;
  CellLaObject := ACellManager.CreateCellHolder;
  try
    ResCellSize := ACellManager.InitAndCaclRenderCellHolder(
      Grid, QrCellSize, CellLaObject, -1, -1, Row.VisibleIndex, 0);

    Height := ResCellSize.Height;
  finally
    CellLaObject.Free;
  end;

  Result := Round(Height);
end;

function TDataVertGridRowHeaderEh.GetRow: TDataVertGridBaseRowEh;
begin
  Result := TDataVertGridBaseRowEh(FieldBar);
end;

procedure TDataVertGridRowHeaderEh.HandleGetCellManager(Params: TPersistent);
begin
end;

procedure TDataVertGridRowHeaderEh.HandleInitCellContent(Params: TPersistent);
begin
end;

{ TDataVertGridBaseRowEh }

constructor TDataVertGridBaseRowEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDefCellManager := CreateCellManager;
end;

constructor TDataVertGridBaseRowEh.CreateWith(AOwner: TComponent; AParent: TComponent);
var
  Grid: TCustomDataVertGridEhCrack;
begin
  Create(AOwner);

  Grid := TCustomDataVertGridEhCrack(TDataVertGridRowsHeaderEh(AParent).Grid);
  Grid.StaticRows.Add(Self);
end;

destructor TDataVertGridBaseRowEh.Destroy;
begin
  Destroying;
  RemoveColumn();
  Header.PrepareToDestroy;
  FreeAndNil(FDefCellManager);
  FreeAndNil(FSizeCalculatorCellObject);
  inherited Destroy;
end;

procedure TDataVertGridBaseRowEh.RemoveColumn;
var
  Grid: TCustomDataVertGridEhCrack;
begin
  Grid := TCustomDataVertGridEhCrack(GetGrid);

  if Grid <> nil then
    Grid.StaticRows.RemoveRow(Self);
end;

procedure TDataVertGridBaseRowEh.FieldNameChanged;
begin
end;

procedure TDataVertGridBaseRowEh.FieldChanged;
begin
  inherited FieldChanged;
end;

function TDataVertGridBaseRowEh.CreateTitle: TFieldBarTitleEh;
begin
  Result := TDataVertGridRowHeaderEh.Create(Self);
end;

function TDataVertGridBaseRowEh.GetHeader: TDataVertGridRowHeaderEh;
begin
  Result := TDataVertGridRowHeaderEh(inherited Title);
end;

procedure TDataVertGridBaseRowEh.OptimizeWidth;
var
  List: TDataVertGridRowsListEh;
  Grid: TCustomDataVertGridEhCrack;
begin
  Grid := TCustomDataVertGridEhCrack(GetGrid);

  if Assigned(Grid) then
  begin
    List := TDataVertGridRowsListEh.Create;
    try
      List.Add(Self);
    finally
      List.Free;
    end;
  end;
end;

function TDataVertGridBaseRowEh.GetWidth: Single;
begin
  if FWidthStored
    then Result := FWidth
    else Result := DefaultWidth;
end;

procedure TDataVertGridBaseRowEh.HandleInitDataCell(Params: TPersistent);
begin
end;

procedure TDataVertGridBaseRowEh.ProcessDataCellKeyDown(Params: TBaseGridCellKeyDownParamsEh);
begin
end;

procedure TDataVertGridBaseRowEh.RefreshDefaultPadding;
begin
  inherited RefreshDefaultPadding;
end;

procedure TDataVertGridBaseRowEh.HandleDataCellKeyDownEvent(Params: TBaseGridCellKeyDownParamsEh);
begin
end;

function TDataVertGridBaseRowEh.GetIsSelected: Boolean;
begin
  Result := False;
end;

procedure TDataVertGridBaseRowEh.SetIsSelected(const Value: Boolean);
begin
end;

procedure TDataVertGridBaseRowEh.SetHeader(const Value: TDataVertGridRowHeaderEh);
begin
  inherited Title := Value;
end;

procedure TDataVertGridBaseRowEh.SetWidth(const Value: Single);
begin
  if (FWidthStored = False) or (Value <> FWidth) then
  begin
    FWidth := Value;
    FWidthStored := True;
    WidthChanged();
  end;
end;

function TDataVertGridBaseRowEh.DefaultWidth: Single;
var
  Grid: TCustomDataVertGridEhCrack;
begin
  Grid := TCustomDataVertGridEhCrack(GetGrid);

  if Assigned(Grid) and
     Assigned(Field) and
     Assigned(Grid.Canvas) then
  begin
    Grid.Canvas.Font.Assign(Self.Font);
    Result := 64;
  end else
  begin
    Result := 64;
  end;
end;

function TDataVertGridBaseRowEh.IsWidthStored: Boolean;
begin
  Result := FWidthStored;
end;

procedure TDataVertGridBaseRowEh.LinkActiveChanged;
begin
  inherited LinkActiveChanged;
  CheckInitWidth;
end;

procedure TDataVertGridBaseRowEh.DoBeforeFirstDrawing;
begin
  CheckInitWidth;
end;

procedure TDataVertGridBaseRowEh.CheckInitWidth;
var
  Grid: TCustomDataVertGridEhCrack;
begin
  Grid := TCustomDataVertGridEhCrack(GetGrid);
  if (Grid <> nil) and
     (Grid.TableView.Active = True) and
     (InListState = TInListFieldBarStateEh.DynamicState) and
     (Grid.IsCanvasEnabled)
     then
  begin
    InitWidth;
  end;
end;

procedure TDataVertGridBaseRowEh.InitWidth;
begin
end;

procedure TDataVertGridBaseRowEh.WidthChanged();
begin
end;

procedure TDataVertGridBaseRowEh.UpdateDefaults;
begin
  inherited UpdateDefaults;
end;

function TDataVertGridBaseRowEh.GetCellManager: TBaseGridCellManagerEh;
begin
  Result := FDefCellManager;
end;

function TDataVertGridBaseRowEh.GetCellManagerAt(ADataColIndex: Integer): TVPBaseCellManagerEh;
var
  Grid: TCustomDataVertGridEhCrack;
begin
  Grid := TCustomDataVertGridEhCrack(GetGrid);

  if (Grid <> nil) and
     (ADataColIndex >= 0) and
     (ADataColIndex < Grid.VisibleColumns.Count) then
  begin
    Result := GetCellManagerAtColumn(Grid.VisibleColumns[ADataColIndex]);
  end
  else
  begin
    Result := GetCellManagerAtColumn(nil);
  end;
end;

function TDataVertGridBaseRowEh.GetCellManagerAtColumn(ARow: TDataVertGridColumnEh): TBaseGridCellManagerEh;
var
  GetCellManagerParams: TBaseDataVertGridGetDataCellManagerParamsEh;
  Grid: TCustomDataVertGridEhCrack;
begin
  Grid := TCustomDataVertGridEhCrack(GetGrid);
  GetCellManagerParams := CreateGetCellManagerParams();
  GetCellManagerParams.Init(Grid, Self, ARow, GetCellManager());
  ProcessGetCellManager(GetCellManagerParams);
  Result := GetCellManagerParams.CellManager;
  GetCellManagerParams.Free;
end;

function TDataVertGridBaseRowEh.CreateGetCellManagerParams(): TBaseDataVertGridGetDataCellManagerParamsEh;
begin
  Result := TBaseDataVertGridGetDataCellManagerParamsEh.Create;
end;

procedure TDataVertGridBaseRowEh.ProcessGetCellManager(Params: TBaseDataVertGridGetDataCellManagerParamsEh);
var
  Grid: TCustomDataVertGridEhCrack;
begin
  Grid := TCustomDataVertGridEhCrack(GetGrid);
  HandleGetDataCellManager(Params);
  if (Grid <> nil) then
    Grid.HandleGetDataCellManager(Params);
end;

procedure TDataVertGridBaseRowEh.HandleGetDataCellManager(Params: TBaseDataVertGridGetDataCellManagerParamsEh);
begin
end;

procedure TDataVertGridBaseRowEh.InitCell(ACell: TGridBaseCellEh; AStyleParams: TDataAxisCellStyleParamsEh);
var
  DataCell: TDataAxisCellEh;
const
  LaHorzAlignments: array [TTextAlign] of TLaHorzAlignmentEh =
    (TLaHorzAlignmentEh.Center, TLaHorzAlignmentEh.Left, TLaHorzAlignmentEh.Right);
begin
  DataCell := TDataAxisCellEh(ACell);

  DataCell.Fill := AStyleParams.Fill;
  DataCell.FontColor := AStyleParams.FontColor;
  DataCell.Font := AStyleParams.Font;
  DataCell.ReadOnly := not CanModifyCellValue(DataCell.ListItemBar);
end;

function TDataVertGridBaseRowEh.CalcDefaultRowHeight(Canvas: TCanvas): Integer;
begin
  Result := CalcDataCellHeight(Canvas, -1);
end;

function TDataVertGridBaseRowEh.CellHeightIsRowDependent(): Boolean;
begin
  Result := HeightAutoExpand = True;
end;

function TDataVertGridBaseRowEh.CalcDataCellHeight(ACanvas: TCanvas; AGridDataColIndex: Integer): Integer;
var
  Grid: TCustomDataVertGridEhCrack;
  CellWidth: Integer;
  Height: Single;
  QrCellSize: TSizeF;
  ResCellSize: TSizeF;
  ACellManager: TVPBaseCellManagerEh;
  AGridColIndex: Integer;
  AGridRowIndex: Integer;
begin
  Grid := TCustomDataVertGridEhCrack(GetGrid);
  CellWidth := Grid.FGridDataColWidths[AGridDataColIndex];
  QrCellSize := TSizeF.Create(CellWidth, TLaControlEh.MaxSize.Height);
  ACellManager := GetCellManagerAt(AGridDataColIndex);
  if FSizeCalculatorCellObject = nil then
  begin
    FSizeCalculatorCellObject := ACellManager.CreateCellHolder;
  end else if FSizeCalculatorCellObject.CellManager <> ACellManager then
  begin
    FSizeCalculatorCellObject.Free;
    FSizeCalculatorCellObject := ACellManager.CreateCellHolder;
  end;
  try
    AGridColIndex := AGridDataColIndex + Grid.StartDataColIndex;
    AGridRowIndex := VisibleIndex + Grid.StartDataRowIndex;
//    ACellManager.InternalInitCellHolderPositionProps(FSizeCalculatorCellObject, Grid, AGridColIndex, AGridRowIndex, AGridDataColIndex, VisibleIndex);
//    ACellManager.InternalInitCellHolder(FSizeCalculatorCellObject);
//    FSizeCalculatorCellObject.SetLayoutChangedForAll();
//    ResCellSize := FSizeCalculatorCellObject.QueryLayout(QrCellSize, ACanvas);
    ResCellSize := ACellManager.InitAndCaclRenderCellHolder(
      Grid, QrCellSize, FSizeCalculatorCellObject, AGridColIndex, AGridRowIndex, AGridDataColIndex, VisibleIndex);

    Height := ResCellSize.Height;
  finally
  end;

  Result := Round(Height);
end;

function TDataVertGridBaseRowEh.CalcNeededDataCellWidth(ACanvas: TCanvas; ADataRowIndex: Integer): Integer;
var
  AWidth: Single;
  Grid: TCustomDataVertGridEhCrack;
  QrCellSize: TSizeF;
  ResCellSize: TSizeF;
  ACellManager: TVPBaseCellManagerEh;
begin
  Grid := TCustomDataVertGridEhCrack(GetGrid);

  QrCellSize := TSizeF.Create(TLaControlEh.MaxSize.Width, 0);
  ACellManager := GetCellManagerAt(ADataRowIndex);
  if FSizeCalculatorCellObject = nil then
    FSizeCalculatorCellObject := ACellManager.CreateCellHolder;
  try
    ResCellSize := ACellManager.InitAndCaclRenderCellHolder(
      Grid, QrCellSize, FSizeCalculatorCellObject, VisibleIndex, ADataRowIndex, VisibleIndex, ADataRowIndex);
    AWidth := ResCellSize.Width;
  finally
  end;

  Result := Round(AWidth);
end;

procedure TDataVertGridBaseRowEh.MTViewDataEvent(RowNum: Integer; Event: TMTViewEventTypeEh; OldRowNum: Integer);
begin

end;

function TDataVertGridBaseRowEh.CreateCellManager: TBaseGridCellManagerEh;
begin
  Result := TDataAxisTextCellManagerEh.Create(nil, Self);
end;

function TDataVertGridBaseRowEh.GetColValue(ARow: TDataVertGridColumnEh): TValue;
begin
  Result := GetListItemValue(ARow);
end;

procedure TDataVertGridBaseRowEh.ClampInView;
begin
end;

procedure TDataVertGridBaseRowEh.HeightAutoExpandChanged;
begin
  inherited HeightAutoExpandChanged;
end;

procedure TDataVertGridBaseRowEh.SetParentComponent(Value: TComponent);
begin
  if Value is TCustomDataVertGridEh then
    TCustomDataVertGridEhCrack(Value).AddChildComponent(Self)
  else
    inherited SetParentComponent(Value);
end;

function TDataVertGridBaseRowEh.GetParentComponent: TComponent;
begin
  Result := GetGrid
end;

function TDataVertGridBaseRowEh.HasParent: Boolean;
begin
  Result := True;
end;

function TDataVertGridBaseRowEh.CreateCellEditParams: TBaseGridCellEditParamsEh;
begin
  Result := TDataAxisCellEditParamsEh.Create();
end;

function TDataVertGridBaseRowEh.CreateInitEditorParams: TBaseGridInitEditorParamsEh;
begin
  Result := TDataAxisCellInitEditorParamsEh.Create();
end;

procedure TDataVertGridBaseRowEh.DefaultInitCellEditor(AParams: TBaseGridInitEditorParamsEh);
begin

end;

procedure TDataVertGridBaseRowEh.HandleInitCellEditor(AParams: TBaseGridInitEditorParamsEh);
begin

end;

function TDataVertGridBaseRowEh.GetCellManagerAtListItemBar(AListItemBar: TTableRowViewEh): TBaseGridCellManagerEh;
begin
  Result := GetCellManagerAtColumn(TDataVertGridColumnEh(AListItemBar));
end;


{ TDataVertGridDisplayRowsEh }

constructor TDataVertGridDisplayRowsEh.Create(AGrid: TControl; AList: TList<TFieldBarEh>);
begin
  inherited Create(AGrid, AList);
end;

destructor TDataVertGridDisplayRowsEh.Destroy;
begin
  inherited Destroy;
end;

function TDataVertGridDisplayRowsEh.GetItem(Index: Integer): TDataVertGridBaseRowEh;
begin
  Result := TDataVertGridBaseRowEh(inherited Items[Index]);
end;

procedure TDataVertGridDisplayRowsEh.SetRowsOrder(AOrderedList: TList<TDataVertGridBaseRowEh>);
var
  I: Integer;
  ColIndex: Integer;
  Grid: TCustomDataVertGridEhCrack;
begin
  if (Count <> AOrderedList.Count) then
    raise Exception.Create('TDataVertGridDisplayRowsEh.SetDisplayOrder: AOrderedList.Count <> SelfList.Count');

  Grid := TCustomDataVertGridEhCrack(FGrid);
  Grid.Rows.BeginUpdate;
  for I := 0 to AOrderedList.Count - 1 do
  begin
    ColIndex := IndexOf(AOrderedList[I]);
    if ColIndex < 0 then
      raise Exception.Create('TDataVertGridDisplayRowsEh.SetDisplayOrder: ColIndex ' + IntToStr(I) + ' is not found');
    Items[ColIndex].DisplayIndex := I;
  end;
  Grid.Rows.EndUpdate;
end;

{ TDataVertGridVisibleRowsEh }

constructor TDataVertGridVisibleRowsEh.Create(AGrid: TControl; AList: TList<TFieldBarEh>);
begin
  inherited Create(AGrid, AList);
end;

destructor TDataVertGridVisibleRowsEh.Destroy;
begin
  inherited Destroy;
end;

function TDataVertGridVisibleRowsEh.GetItem(Index: Integer): TDataVertGridBaseRowEh;
begin
  Result := TDataVertGridBaseRowEh(inherited Items[Index]);
end;

procedure TDataVertGridVisibleRowsEh.MoveRow(Column: TDataVertGridBaseRowEh;
  NewVisibleIndex: Integer);
begin
  MoveFieldBar(Column, NewVisibleIndex);
end;

procedure TDataVertGridVisibleRowsEh.MoveRows(ColumnList: TDataVertGridRowsListEh;
  NewVisibleIndex: Integer);
begin
  MoveFieldBars(ColumnList, NewVisibleIndex);
end;

function TDataVertGridVisibleRowsEh.GetFirstTabRow: TDataVertGridBaseRowEh;
begin
  Result := Items[0];
end;

function TDataVertGridVisibleRowsEh.GetLastTabRow: TDataVertGridBaseRowEh;
begin
  Result := Items[Count - 1];
end;

function TDataVertGridVisibleRowsEh.GetNextTabRow(ForRow: TDataVertGridBaseRowEh;
  GoForward: Boolean): TDataVertGridBaseRowEh;
var
  ARowIndex, Original: Integer;
  Grid: TCustomDataVertGridEhCrack;
begin
  Grid := TCustomDataVertGridEhCrack(FGrid);
  ARowIndex := ForRow.VisibleIndex;
  Result := ForRow;
  Original := ARowIndex;

  while True do
  begin
    if GoForward
      then Inc(ARowIndex)
      else Dec(ARowIndex);
    if ARowIndex >= Count - Grid.ContraRowCount then
      Exit
    else if ARowIndex < 0 then
      Exit;
    if ARowIndex = Original then Exit;
    if True then
    begin
      Result := Items[ARowIndex];
      Exit;
    end;
  end;
end;

procedure TDataVertGridVisibleRowsEh.UpdateActualWidths;
begin
end;

procedure TDataVertGridVisibleRowsEh.UpdateTitleMetrics;
begin
end;

function TDataVertGridVisibleRowsEh.GetEnumerator: TRowFieldBarEnumeratorEh;
begin
  Result := TRowFieldBarEnumeratorEh.Create(inherited GetEnumerator);
end;

{ TDataVertGridDynamicRowsEh }

constructor TDataVertGridDynamicRowsEh.Create(AGrid: TControl;
  AList: TList<TFieldBarEh>);
begin
  inherited Create(AGrid, AList);
end;

destructor TDataVertGridDynamicRowsEh.Destroy;
begin
  inherited Destroy;
end;

function TDataVertGridDynamicRowsEh.GetColumnClassByField(AField: TTableFieldLinkEh): TFieldBarEhClass;
begin
  Result := inherited GetColumnClassByField(AField);
end;

{ TRowFieldBarEnumeratorEh }

constructor TRowFieldBarEnumeratorEh.Create(AFieldBarEnumerator: TEnumerator<TFieldBarEh>);
begin
  inherited Create;
  FFieldBarEnumerator := AFieldBarEnumerator;
end;

destructor TRowFieldBarEnumeratorEh.Destroy;
begin
  FreeAndNil(FFieldBarEnumerator);
  inherited Destroy;
end;

function TRowFieldBarEnumeratorEh.DoGetCurrent: TDataVertGridBaseRowEh;
begin
  Result := TDataVertGridBaseRowEh(FFieldBarEnumerator.Current);
end;

function TRowFieldBarEnumeratorEh.DoMoveNext: Boolean;
begin
  Result := FFieldBarEnumerator.MoveNext;
end;

{ TBaseDataVertGridGetDataCellManagerParamsEh }

procedure TBaseDataVertGridGetDataCellManagerParamsEh.Init(AGrid: TControl;
  ARow: TDataVertGridBaseRowEh; AColumn: TDataVertGridColumnEh;
  ADefaultCellManager: TBaseGridCellManagerEh);
begin
  FGrid := AGrid;
  FColumn := AColumn;
  FRow := ARow;
  FCellManager := ADefaultCellManager;
end;

end.

