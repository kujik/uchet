{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{               EhLibFmx.DataGrid.Titles                }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataGrid.Titles;

interface

{$SCOPEDENUMS ON}

uses
  System.SysUtils, System.Classes, System.Contnrs, System.Types,
  FMX.Types, FMX.Controls, Rtti, System.UIConsts,
  System.Generics.Collections, Db, FMX.Graphics, System.UITypes,
  System.Variants,
  FMX.StdCtrls,
  FMX.Forms,
  FMX.ImgList,
  FMX.Objects,

  EhLibUtils, DBUtilsEh, DynVarsEh,
  EhLibFmx.ImageReses,
  EhLibFmx.Grid.Types,
  EhLibFmx.Grid.CellManagers,
  EhLibFmx.Grid.ToolControls,
  EhLibFmx.DataGrid.Columns,
  EhLibFmx.DataGrid.ToolControls,
  EhLibFmx.DataGrid.ComplexTitles,
  EhLibFmx.DataGrid.TitleFilters,

  EhLibFmx.Types,
  EhLibFmx.Platform,
  EhLibFmx.ToolControls,
  EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.LaHostVirtualPanels,
  EhLibFmx.LaObjects,
  EhLibFmx.LaControls,
  EhLibFmx.LaGridPanels,
  EhLibFmx.LaPanels
  ;

type
  TDataGridTitleSortMarkingEh = class;
  TDataGridTitleCellManagerEh = class;
  TDataGridSortItemEh = class;
  TDataGridTitleCellContextMenuParamsEh = class;
  TDataGridTitleCellEh = class;
  TDataGridTitleCreateCellContentParamsEh = class;
  TDataGridTitleInitCellContentParamsEh = class;

{ TDataGridTitleInitCellParamsEh }

  TDataGridTitleInitCellParamsEh = class(TBaseGridInitCellParamsEh)
  private
    FColumnTitle: TColumnTitleEh;

  public
    procedure Init(AGrid: TControl; ACellManager: TBaseGridCellManagerEh; ACell: TGridBaseCellEh); override;
    property ColumnTitle: TColumnTitleEh read FColumnTitle;
  end;

{ TDataGridTitleInitCellContentParamsEh }

  TDataGridTitleInitCellContentParamsEh = class(TDataAxisGridTitleInitCellContentParamsEh)
  private
    function GetColumnTitle: TColumnTitleEh;
  protected
    function GetFieldBarTitle: TFieldBarTitleEh; override;

  public
    procedure Init(ACell: TGridBaseCellEh; ACellContent: TLaObjectEh; InitCellParams: TBaseGridInitCellParamsEh); override;

    property ColumnTitle: TColumnTitleEh read GetColumnTitle;
  end;

{ TDataGridTitleCreateCellContentParamsEh }

  TDataGridTitleCreateCellContentParamsEh = class(TDataAxisGridTitleCreateCellContentParamsEh)
  private
  public
  end;

{ TDataGridTitleCellContextMenuParamsEh }

  TDataGridTitleCellContextMenuParamsEh = class(TBaseGridCellContextMenuParamsEh)
  private
    FColumnTitle: TColumnTitleEh;

  public
    procedure Reset(AGrid: TControl; ACell: TGridBaseCellEh); override;

    property ColumnTitle: TColumnTitleEh read FColumnTitle;
  end;

{ TDataGridTitleCellComposeContextMenuParamsEh }

  TDataGridTitleCellComposeContextMenuParamsEh = class(TBaseGridCellComposeContextMenuParamsEh)
  private
    FColumn: TDataGridBaseColumnEh;

  public
    procedure Init(AGrid: TControl; ACell: TGridBaseCellEh; AControlParams: TControlShowContextMenuParamsEh); override;

    property Column: TDataGridBaseColumnEh read FColumn;
  end;

{ TDataGridTitleGetCellManagerParamsEh }

  TDataGridTitleGetCellManagerParamsEh = class(TPersistent)
  private
    FColumnTitle: TColumnTitleEh;
    FGrid: TControl;
    FCellManager: TBaseGridCellManagerEh;

  public
    procedure Init(AGrid: TControl; AColumnTitle: TColumnTitleEh; ADefaultCellManager: TBaseGridCellManagerEh); virtual;

    property Grid: TControl read FGrid;
    property ColumnTitle: TColumnTitleEh read FColumnTitle;
    property CellManager: TBaseGridCellManagerEh read FCellManager write FCellManager;
  end;

{ TDataGridInteractiveSortMarkersChangedParamsEh }

  TDataGridInteractiveSortMarkersChangedParamsEh = class(TPersistent)
  private
    FGrid: TControl;
    FHandled: Boolean;
  public
    constructor Create;
    procedure Init(AGrid: TControl);

    procedure ApplySorting();

    property Grid: TControl read FGrid;
    property Handled: Boolean read FHandled write FHandled;
  end;

  TDataGridTitleCreateCellContentEventEh = procedure(Sender: TObject; Params: TDataGridTitleCreateCellContentParamsEh) of object;
  TDataGridTitleInitCellContentEventEh = procedure(Sender: TObject; Params: TDataGridTitleInitCellContentParamsEh) of object;
  TDataGridTitleGetCellManagerEventEh = procedure(Sender: TObject; Params: TDataGridTitleGetCellManagerParamsEh) of object;
  TDataGridInteractiveSortMarkersChangedEventEh = procedure(Sender: TObject; Params: TDataGridInteractiveSortMarkersChangedParamsEh) of object;

{ TDataGridTitleBarEh }

  TDataGridTitleBarEh = class(TAxisGridTitleBarEh)
  private
    FSortMarking: TDataGridTitleSortMarkingEh;
    FComplexTitle: Boolean;
    FComplexTitleTree: TDataGridComplexTitleTreeListEh;
    FFilter: TDataGridTitleFilterEh;
    FDblClickOptimizeColWidth: Boolean;
    FDefaultCellManager: TBaseGridCellManagerEh;
    FInternalDefCellManager: TBaseGridCellManagerEh;
    FOnCreateCellContent: TDataGridTitleCreateCellContentEventEh;
    FOnCellInitContent: TDataGridTitleInitCellContentEventEh;
    FOnGetCellManager: TDataGridTitleGetCellManagerEventEh;
    FOnInteractiveSortMarkersChanged: TDataGridInteractiveSortMarkersChangedEventEh;

    procedure SetSortMarking(const Value: TDataGridTitleSortMarkingEh);
    procedure SetComplexTitle(const Value: Boolean);
    procedure SetFilter(const Value: TDataGridTitleFilterEh);
    procedure SetMouseInTitle(const Value: Boolean);
    procedure SetDefaultCellManager(const Value: TBaseGridCellManagerEh);

  protected
    FTitleRowIndex: Integer;
    FMouseInTitle: Boolean;
    FHeightRecalcNeeded: Boolean;
    FTitleHeight: Integer;

    function CreateGetCellManagerParams(): TDataGridTitleGetCellManagerParamsEh; virtual;
    function DefaultHorzAlign(): TTextAlign; override;
    function GetDefaultCellManagerAt(ALocalColIndex, ALocalRowIndex: Integer): TBaseGridCellManagerEh; virtual;

    procedure Changed(CellLayoutAffects: Boolean = False); override;

    procedure AddChangeSortMarking(Column: TDataGridBaseColumnEh; IsMultiSortMarking: Boolean);
    procedure HandleCreateCellContent(Params: TDataGridTitleCreateCellContentParamsEh); virtual;
    procedure HandleGetCellManager(Params: TDataGridTitleGetCellManagerParamsEh); virtual;
    procedure HandleInitCellContent(Params: TDataGridTitleInitCellContentParamsEh); virtual;
    procedure ProcessGetCellManager(Params: TDataGridTitleGetCellManagerParamsEh); virtual;

    procedure InTitleFilterDropDownFormCallbackProc(DropDownForm: TCustomForm; Accept: Boolean; DynParams: TDynVarsEh; SysParams: TDropDownFormSysParams);

  public
    constructor Create(AGrid: TControl);
    destructor Destroy; override;

    function GetCellManagerAt(ALocalColIndex, ALocalRowIndex: Integer): TBaseGridCellManagerEh; virtual;

    procedure TitlePropChange(CellLayoutAffects: Boolean = False); override;
    procedure InTitleFilterDropDownFormForRect(Column: TDataGridBaseColumnEh; ForScreenRect: TRect);

    procedure CellContextMenuNeeded(Params: TDataGridTitleCellContextMenuParamsEh);
    procedure HandleInteractiveSortMarkersChanged(Params: TDataGridInteractiveSortMarkersChangedParamsEh);

    property TitleRowIndex: Integer read FTitleRowIndex;
    property ComplexTitleTree: TDataGridComplexTitleTreeListEh read FComplexTitleTree;
    property MouseInTitle: Boolean read FMouseInTitle write SetMouseInTitle;
    property DefaultCellManager: TBaseGridCellManagerEh read FDefaultCellManager write SetDefaultCellManager;
    property HeightRecalcNeeded: Boolean read FHeightRecalcNeeded;

  published
    property SortMarking: TDataGridTitleSortMarkingEh read FSortMarking write SetSortMarking;
    property IsComplexTitle: Boolean read FComplexTitle write SetComplexTitle default False;
    property Filter: TDataGridTitleFilterEh read FFilter write SetFilter;
    property DblClickOptimizeColWidth: Boolean read FDblClickOptimizeColWidth write FDblClickOptimizeColWidth default True;

    property OnCreateCellContent: TDataGridTitleCreateCellContentEventEh read FOnCreateCellContent write FOnCreateCellContent;
    property OnCellInitContent: TDataGridTitleInitCellContentEventEh read FOnCellInitContent write FOnCellInitContent;
    property OnGetCellManager: TDataGridTitleGetCellManagerEventEh read FOnGetCellManager write FOnGetCellManager;
    property OnInteractiveSortMarkersChanged: TDataGridInteractiveSortMarkersChangedEventEh read FOnInteractiveSortMarkersChanged write FOnInteractiveSortMarkersChanged;
  end;

{ TDataGridSortItemEh }

  TDataGridSortItemEh = class(TPersistent)
  private
    FColumn: TDataGridBaseColumnEh;
    FSortDirection: TSortOrderEh;
  public
    constructor Create();
    destructor Destroy; override;

    property Column: TDataGridBaseColumnEh read FColumn;
    property SortDirection: TSortOrderEh read FSortDirection;
  end;

{ TDataGridTitleSortMarkingEh }

  TDataGridTitleSortMarkingEh = class(TPersistent)
  private
    FGridTitle: TDataGridTitleBarEh;
    FMultiSortMarkable: Boolean;
    FSortMarkable: Boolean;
    FSortMarkers: TReadonlyList<TDataGridSortItemEh>;
    FSortMarkerList: TList<TDataGridSortItemEh>;
    FSortMarkersChanged: Boolean;

  protected
    procedure DefaultApplySortMarkers; virtual;

  public
    constructor Create(AGridTitle: TDataGridTitleBarEh);
    destructor Destroy; override;

    function IndexOfSortMarkerByColumn(AColumn: TDataGridBaseColumnEh): Integer;

    procedure ApplySortMarkers();
    procedure SetSortState(AColumn: TDataGridBaseColumnEh; SortDirection: TSortOrderEh);
    procedure AddSortItem(AColumn: TDataGridBaseColumnEh; SortDirection: TSortOrderEh);
    procedure ChangeStateAsTitleClick(AColumn: TDataGridBaseColumnEh; IsMultiSortMarking: Boolean);
    procedure RemoveSortMarkerByColumn(AColumn: TDataGridBaseColumnEh);
    procedure ClearSortMarkers();

    property SortMarkers: TReadonlyList<TDataGridSortItemEh> read FSortMarkers;
    property SortMarkersChanged: Boolean read FSortMarkersChanged;

  published
    property SortMarkable: Boolean read FSortMarkable write FSortMarkable default True;
    property MultiSortMarkable: Boolean read FMultiSortMarkable write FMultiSortMarkable default True;
  end;

{ TDataGridVirtualPanelEh }

  TDataGridTitleVirtualPanelEh = class(TDataGridVirtualPanelEh)
  private
  protected
    procedure EnsureRevokeCellInPanel; override;
    procedure InternalUpdateCellPositionProps; override;
    procedure InternalUpdateCellsLayout; override;
  public
    function CreateBaseCellManager: TVPBaseCellManagerEh; override;
    function GetCellRect(StartColPos, StartRowPos: Single; ColIndex, RowIndex: Integer): TRectF; override;
  end;

{ TDataGridTitleCellManagerEh }

  TDataGridTitleCellManagerEh = class(TDataAxisGridTitleCellManagerEh)
  private
    FOnCreateCellContent: TDataGridTitleCreateCellContentEventEh;
    FOnCellInitContent: TDataGridTitleInitCellContentEventEh;

  protected

    function CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh; override;
    function CreateInitCellContentParams: TBaseGridInitCellContentParamsEh; override;
    function CreateInitCellParams: TBaseGridInitCellParamsEh; override;
    function CreateCellContentParams(): TBaseGridCreateCellContentParamsEh; override;

    procedure HandleInitCell(Params: TBaseGridInitCellParamsEh); override;
    procedure HandleInitCellContent(Params: TBaseGridInitCellContentParamsEh); override;
    procedure ComposeContextMenu(ACellParams: TBaseGridCellComposeContextMenuParamsEh); override;
    procedure HandleCreateCustomCellContent(Params: TBaseGridCreateCellContentParamsEh); override;

    function DefaultCreateContentControls(ACell: TGridBaseCellEh; AParentObject: TLaObjectEh): TLaControlEh; virtual;

  public
    function CreateCellHolder(): TVPBaseCellHolderEh; override;
    function CreateComposeContextMenuParams(): TBaseGridCellComposeContextMenuParamsEh; override;
    function GetBackgroundStyle(AParams: TBaseGridInitCellParamsEh): TControl; override;
    function IsShowSelectionLayer(AGrid: TControl; ACell: TGridBaseCellEh): Boolean; override;

    procedure InitCellHolder(ACell: TVPBaseCellHolderEh); override;
    procedure InitCellPositionProps(ACell: TGridBaseCellEh); override;
    procedure DefaultInitCellProps(Params: TBaseGridInitCellParamsEh); override;
    procedure DefaultInitCellContent(AParams: TBaseGridInitCellContentParamsEh); override;

    property OnCreateCellContent: TDataGridTitleCreateCellContentEventEh read FOnCreateCellContent write FOnCreateCellContent;
    property OnCellInitContent: TDataGridTitleInitCellContentEventEh read FOnCellInitContent write FOnCellInitContent;
  end;

{ TDataGridVPTitleCellEh }

  TDataGridTitleCellEh = class(TGridBaseCellEh)
  private
    FButtonImage: TImage;
    FFilterButton: TLaButtonEh;
    FHasFilter: Boolean;
    FMouseDownPos: TPoint;
//    FSelectionLayer: TLaControlEh;
    FSortIndexPanel: TLaTextBlockEh;
    FSortMarkerPanel: TLaLayoutPanelEh;
    FTextControl: TLaTextBlockEh;
    FCellContent: TLaControlEh;
//    FStyledBackground: TLaLayoutPanelEh;
    FColumnTitle: TColumnTitleEh;

    function GetIsShowButtonFace: Boolean;
    function GetIsShowFilterButton: Boolean;
//    function GetShowSelectionLayer: Boolean;
    function GetText: String;
    procedure SetHasFilter(const Value: Boolean);
    procedure SetIsShowButtonFace(const Value: Boolean);
    procedure SetIsShowFilterButton(const Value: Boolean);
//    procedure SetShowSelectionLayer(const Value: Boolean);
    procedure SetText(const Value: String);

  protected

    function GetCursorAtMousePos(Shift: TShiftState; X, Y: Single): TCursor; override;

    procedure ProcessMouseDown(Params: TControlMouseButtonParamsEh); override;
    procedure ProcessMouseMove(Params: TControlMouseParamsEh); override;
    procedure ProcessMouseClick(Params: TControlMouseButtonParamsEh); override;

    procedure MouseClick(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseEnter(Params: TControlParamsEh); override;
    procedure MouseLeave(Params: TControlParamsEh); override;
    procedure CreateControls(); override;

    function CreateDefaultCellContentControls(AParentObject: TLaObjectEh): TLaObjectEh; override;
    function CreateCellClientControls(AParent: TLaObjectEh): TLaObjectEh; override;

    procedure InTitleFilterListboxCloseUp();
    procedure InTitleFilterListboxDropDown(Column: TDataGridBaseColumnEh);
    procedure FilterButtonMouseDown(Sender: TObject; Params: TControlMouseButtonParamsEh);

  public
    constructor Create(ACellHolder: TGridBaseCellHolderEh);
    destructor Destroy; override;

    property Text: String read GetText write SetText;
    property TextControl: TLaTextBlockEh read FTextControl;
    property SortMarkerPanel: TLaLayoutPanelEh read FSortMarkerPanel;
    property SortIndexPanel: TLaTextBlockEh read FSortIndexPanel;
    property HasFilter: Boolean read FHasFilter write SetHasFilter;
    property IsShowButtonFace: Boolean read GetIsShowButtonFace write SetIsShowButtonFace;
    property IsShowFilterButton: Boolean read GetIsShowFilterButton write SetIsShowFilterButton;
    property CellContent: TLaControlEh read FCellContent;
    property ColumnTitle: TColumnTitleEh read FColumnTitle;
  end;

implementation

uses EhLibFmx.CustomDataGrids,
     EhLibFmx.DataGrid.FilterForm;

type
  TCustomDataGridEhCrack = class(TCustomDataGridEh);
  TColumnTitleEhCrack = class(TColumnTitleEh);
  TLaLayoutPanelEhCrack = class(TLaLayoutPanelEh);

{$REGION 'TDataGridEhIndicatorColumnHelper'}

{ TDataGridEhIndicatorColumnHelper }

  TDataGridTitleVirtualPanelEhHelper = class helper for TDataGridTitleVirtualPanelEh
  private
    function GetGridCore: TCustomDataGridEhCrack;
  public
    property GridCore: TCustomDataGridEhCrack read GetGridCore;
  end;

function TDataGridTitleVirtualPanelEhHelper.GetGridCore: TCustomDataGridEhCrack;
begin
  Result := TCustomDataGridEhCrack(Self.Grid);
end;

{$ENDREGION 'TDataGridEhIndicatorColumnHelper'}

{$REGION 'TDataGridTitleSortMarkingEh'}

{ TDataGridTitleSortMarkingEh }

constructor TDataGridTitleSortMarkingEh.Create(AGridTitle: TDataGridTitleBarEh);
begin
  inherited Create();
  FGridTitle := AGridTitle;
  FSortMarkerList := TList<TDataGridSortItemEh>.Create;
  FSortMarkers := TReadonlyList<TDataGridSortItemEh>.Create(FSortMarkerList);
  FSortMarkable := True;
  FMultiSortMarkable := True;
end;

destructor TDataGridTitleSortMarkingEh.Destroy;
var
  I: Integer;
begin
  FSortMarkers.Free;
  for I := 0 to FSortMarkerList.Count - 1 do
  begin
    FSortMarkerList[I].Free;
  end;
  FSortMarkerList.Free;
  inherited Destroy;
end;

procedure TDataGridTitleSortMarkingEh.ChangeStateAsTitleClick(AColumn: TDataGridBaseColumnEh; IsMultiSortMarking: Boolean);
var
  si: TDataGridSortItemEh;
  siIndex: Integer;
  sd: TSortOrderEh;
begin
  siIndex := IndexOfSortMarkerByColumn(AColumn);
  if (IsMultiSortMarking) then
  begin
    if (siIndex >= 0) then
    begin
      si := SortMarkers[siIndex];
      if (si.SortDirection = soAscEh) then
        si.FSortDirection := soDescEh
      else
        RemoveSortMarkerByColumn(AColumn);
    end
    else
    begin
      AddSortItem(AColumn, soAscEh);
    end
  end
  else
  begin
    if (siIndex >= 0) then
    begin
      si := SortMarkers[siIndex];
      if (si.SortDirection = soAscEh) then
        SetSortState(AColumn, soDescEh)
      else
        SetSortState(AColumn, soAscEh);
    end
    else
    begin
      sd := soAscEh;
      SetSortState(AColumn, sd);
    end;
  end;
  FSortMarkersChanged := True;
end;

procedure TDataGridTitleSortMarkingEh.ClearSortMarkers;
var
  I: Integer;
begin
  for I := 0 to FSortMarkerList.Count - 1 do
    FSortMarkerList[I].Free;
  FSortMarkerList.Clear;
end;

function TDataGridTitleSortMarkingEh.IndexOfSortMarkerByColumn(AColumn: TDataGridBaseColumnEh): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to SortMarkers.Count - 1 do
  begin
    if SortMarkers[I].Column = AColumn then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

procedure TDataGridTitleSortMarkingEh.RemoveSortMarkerByColumn
  (AColumn: TDataGridBaseColumnEh);
var
  I: Integer;
  SI: TDataGridSortItemEh;
begin
  for I := 0 to FSortMarkerList.Count - 1 do
  begin
    if FSortMarkerList[I].Column = AColumn then
    begin
      SI := FSortMarkerList[I];
      FSortMarkerList.Delete(I);
      SI.Free;
      Exit;
    end;
  end;
end;

procedure TDataGridTitleSortMarkingEh.AddSortItem(AColumn: TDataGridBaseColumnEh; SortDirection: TSortOrderEh);
var
  SortItem: TDataGridSortItemEh;
begin
  if (IndexOfSortMarkerByColumn(AColumn) >= 0) then
    raise Exception.Create('column is not unique in DataGridSortCollection');
  SortItem := TDataGridSortItemEh.Create;
  SortItem.FColumn := AColumn;
  SortItem.FSortDirection := SortDirection;
  FSortMarkerList.Add(SortItem);
  FSortMarkersChanged := True;
end;

procedure TDataGridTitleSortMarkingEh.SetSortState(AColumn: TDataGridBaseColumnEh; SortDirection: TSortOrderEh);
begin
  ClearSortMarkers();
  AddSortItem(AColumn, SortDirection);
  FSortMarkersChanged := True;
end;

procedure TDataGridTitleSortMarkingEh.ApplySortMarkers;
var
  AGrid: TCustomDataGridEhCrack;
  SMCParams: TDataGridInteractiveSortMarkersChangedParamsEh;
begin
  AGrid := TCustomDataGridEhCrack(FGridTitle.Grid);
  SMCParams := TDataGridInteractiveSortMarkersChangedParamsEh.Create;
  try
    SMCParams.Init(AGrid);
    FGridTitle.HandleInteractiveSortMarkersChanged(SMCParams);
    if SMCParams.Handled = False then
      DefaultApplySortMarkers();
  finally
    SMCParams.Free;
  end;
end;

procedure TDataGridTitleSortMarkingEh.DefaultApplySortMarkers();
var
  AGrid: TCustomDataGridEhCrack;
begin
  AGrid := TCustomDataGridEhCrack(FGridTitle.Grid);
  AGrid.ApplySorting();
  FSortMarkersChanged := False;
end;

{$ENDREGION 'TDataGridTitleSortMarkingEh'}

{$REGION 'TDataGridTitleBarEh'}

{ TDataGridTitleBarEh }

constructor TDataGridTitleBarEh.Create(AGrid: TControl);
begin
  inherited Create(AGrid);
  FSortMarking := TDataGridTitleSortMarkingEh.Create(Self);
  FComplexTitleTree := TDataGridComplexTitleTreeListEh.Create(Self, TDataGridComplexTitleTreeNodeEh);
  FFilter := TDataGridTitleFilterEh.Create(Self);
  FMouseInTitle := False;
  FDblClickOptimizeColWidth := True;
  FInternalDefCellManager := TDataGridTitleCellManagerEh.Create(nil);
  FDefaultCellManager := FInternalDefCellManager;
end;

destructor TDataGridTitleBarEh.Destroy;
begin
  FreeAndNil(FInternalDefCellManager);
  FreeAndNil(FSortMarking);
  FreeAndNil(FComplexTitleTree);
  FreeAndNil(FFilter);
  inherited Destroy;
end;

function TDataGridTitleBarEh.GetDefaultCellManagerAt(ALocalColIndex, ALocalRowIndex: Integer): TBaseGridCellManagerEh;
var
  Column: TDataGridBaseColumnEh;
begin
  if ALocalColIndex < TCustomDataGridEhCrack(Grid).VisibleColumns.Count
    then Column := TCustomDataGridEhCrack(Grid).VisibleColumns[ALocalColIndex]
    else Column := nil;

  if Column <> nil then
    Result := Column.Title.GetCellManager()
  else
    Result := DefaultCellManager;
end;

function TDataGridTitleBarEh.GetCellManagerAt(ALocalColIndex, ALocalRowIndex: Integer): TBaseGridCellManagerEh;
var
  GetCellManagerParams: TDataGridTitleGetCellManagerParamsEh;
  Grid: TCustomDataGridEhCrack;
  ADefaultCellManager: TBaseGridCellManagerEh;
  ColumnTitle: TColumnTitleEh;
begin
  Grid := TCustomDataGridEhCrack(Self.Grid);
  if ALocalColIndex < TCustomDataGridEhCrack(Grid).VisibleColumns.Count
    then ColumnTitle := TCustomDataGridEhCrack(Grid).VisibleColumns[ALocalColIndex].Title
    else ColumnTitle := nil;
  ADefaultCellManager := GetDefaultCellManagerAt(ALocalColIndex, ALocalRowIndex);
  GetCellManagerParams := CreateGetCellManagerParams();
  try
    GetCellManagerParams.Init(Grid, ColumnTitle, ADefaultCellManager);
    ProcessGetCellManager(GetCellManagerParams);
    Result := GetCellManagerParams.CellManager;
  finally
    GetCellManagerParams.Free;
  end;
end;

function TDataGridTitleBarEh.CreateGetCellManagerParams(): TDataGridTitleGetCellManagerParamsEh;
begin
  Result := TDataGridTitleGetCellManagerParamsEh.Create;
end;

procedure TDataGridTitleBarEh.ProcessGetCellManager(Params: TDataGridTitleGetCellManagerParamsEh);
begin
  if (Params.ColumnTitle <> nil) then
    TColumnTitleEhCrack(Params.ColumnTitle).HandleGetCellManager(Params);
  HandleGetCellManager(Params);
end;

procedure TDataGridTitleBarEh.HandleGetCellManager(Params: TDataGridTitleGetCellManagerParamsEh);
begin
  if Assigned(OnGetCellManager) then
    OnGetCellManager(Self, Params);
end;

procedure TDataGridTitleBarEh.AddChangeSortMarking(Column: TDataGridBaseColumnEh;
  IsMultiSortMarking: Boolean);
var
  DoMultiSortMarking: Boolean;
begin
  DoMultiSortMarking := IsMultiSortMarking and SortMarking.MultiSortMarkable;
  SortMarking.ChangeStateAsTitleClick(Column, DoMultiSortMarking);
  if (DoMultiSortMarking = False) then
    SortMarking.ApplySortMarkers()
  else
    TCustomDataGridEh(Grid).Invalidate;
end;

procedure TDataGridTitleBarEh.CellContextMenuNeeded(Params: TDataGridTitleCellContextMenuParamsEh);
begin
  TCustomDataGridEhCrack(Grid).BuildTitleCellPopupMenu(Params);
end;

function TDataGridTitleBarEh.DefaultHorzAlign: TTextAlign;
begin
  if IsComplexTitle then
    Result := TTextAlign.Center
  else
    Result := inherited DefaultHorzAlign;
end;

procedure TDataGridTitleBarEh.SetComplexTitle(const Value: Boolean);
var
  AGrid: TCustomDataGridEhCrack;
begin
  if FComplexTitle <> Value then
  begin
    AGrid := TCustomDataGridEhCrack(Grid);
    if (Value = True) and ((csLoading in AGrid.ComponentState) = False) then
    begin
      if AGrid.AutoGenerateColumns = True then
        raise Exception.Create('ComplexTitle mode cannot operate simultaneously with AutoGenerateColumns = True');
    end;

    FComplexTitle := Value;
    if FComplexTitle = True then
      FComplexTitleTree.BuildTreeFromColumns
    else
      FComplexTitleTree.DestructTree;
    AGrid.LayoutChanged;
    AGrid.FullFieldBarListChanged();
  end;
end;

procedure TDataGridTitleBarEh.SetFilter(const Value: TDataGridTitleFilterEh);
begin
  FFilter.Assign(Value)
end;

procedure TDataGridTitleBarEh.SetMouseInTitle(const Value: Boolean);
var
  AGrid: TCustomDataGridEhCrack;
begin
  AGrid := TCustomDataGridEhCrack(Grid);
  if FMouseInTitle <> Value then
  begin
    FMouseInTitle := Value;
    AGrid.Invalidate;
  end;
end;

procedure TDataGridTitleBarEh.SetSortMarking(const Value: TDataGridTitleSortMarkingEh);
begin
  FSortMarking.Assign(Value);
end;

procedure TDataGridTitleBarEh.SetDefaultCellManager(const Value: TBaseGridCellManagerEh);
begin
  if FDefaultCellManager <> Value then
  begin
    FDefaultCellManager := Value;
    if FDefaultCellManager = nil then
      FDefaultCellManager := FInternalDefCellManager;
    Changed;
  end;
end;

procedure TDataGridTitleBarEh.HandleCreateCellContent(Params: TDataGridTitleCreateCellContentParamsEh);
begin
  if Assigned(OnCreateCellContent) then
    OnCreateCellContent(Self, Params);
end;

procedure TDataGridTitleBarEh.HandleInitCellContent(Params: TDataGridTitleInitCellContentParamsEh);
begin
  if Assigned(OnCellInitContent) then
    OnCellInitContent(Self, Params);
end;

procedure TDataGridTitleBarEh.HandleInteractiveSortMarkersChanged(
  Params: TDataGridInteractiveSortMarkersChangedParamsEh);
begin
  if Assigned(OnInteractiveSortMarkersChanged) then
    OnInteractiveSortMarkersChanged(Self, Params);
end;

procedure TDataGridTitleBarEh.Changed(CellLayoutAffects: Boolean);
begin
  FHeightRecalcNeeded := True;
  inherited Changed(CellLayoutAffects);
end;

procedure TDataGridTitleBarEh.TitlePropChange(CellLayoutAffects: Boolean);
var
  AGrid: TCustomDataGridEhCrack;
begin
  inherited TitlePropChange(CellLayoutAffects);
  AGrid := TCustomDataGridEhCrack(Grid);
  FHeightRecalcNeeded := True;
  AGrid.LayoutChanged(True);
end;

procedure TDataGridTitleBarEh.InTitleFilterDropDownFormForRect(Column: TDataGridBaseColumnEh; ForScreenRect: TRect);
var
  DDParams: TDynVarsEh;
  SysParams: TDataGridFilterFormSysParamsEh;
  IntDropDownForm: IDropDownFormEh;
  ADropDownForm: TDataGridFilterDropDownForm;
  DropDownAlign: TDropDownAlign;
  AGrid: TCustomDataGridEhCrack;
begin
  AGrid := TCustomDataGridEhCrack(Column.Grid);

  ADropDownForm := GetLockDataGridFilterDropDownForm(Column);

  DDParams := TDynVarsEh.Create(Self);
  SysParams := TDataGridFilterFormSysParamsEh.Create;

  SysParams.FreeFormOnClose := False;
  SysParams.FEditControl := AGrid;
  SysParams.FEditButton := nil;
  SysParams.FEditButtonObj := nil;
  SysParams.Column := Column;

  if Supports(ADropDownForm, IDropDownFormEh, IntDropDownForm) then
    IntDropDownForm.ReadOnly := False;

  DDParams['Column'].AsRefObject := Column;

  if Supports(ADropDownForm, IDropDownFormEh, IntDropDownForm) then
  begin
    AGrid.FInTitleFilterListboxColumn := Column;
    DropDownAlign := TDropDownAlign.Left;

    IntDropDownForm.ExecuteNoModal(AGrid, ForScreenRect, nil, DropDownAlign, DDParams, SysParams, InTitleFilterDropDownFormCallbackProc);
  end;
end;

procedure TDataGridTitleBarEh.InTitleFilterDropDownFormCallbackProc(DropDownForm: TCustomForm;
  Accept: Boolean; DynParams: TDynVarsEh; SysParams: TDropDownFormSysParams);
var
  AColumn: TDataGridBaseColumnEh;
  FilterDropDownForm: TDataGridFilterDropDownForm;
  ColumnFilter: TSTColumnFilterEh;
  ColumnTitle: TColumnTitleEhCrack;
  Operand1: TValue;
  Operand1Arr: TArray<TValue>;
  GridSysParams: TDataGridFilterFormSysParamsEh;
  ValList: TList<TValue>;
begin
  FilterDropDownForm := (DropDownForm as TDataGridFilterDropDownForm);
  AColumn := FilterDropDownForm.Column;
  ReleaseLockDataGridFilterDropDownForm(False);
  ColumnTitle := TColumnTitleEhCrack(AColumn.Title);
  ColumnTitle.FFilterDropDownForm := nil;
  GridSysParams := TDataGridFilterFormSysParamsEh(SysParams);
  ValList := GridSysParams.ReturnSelValList;

  if Accept then
  begin
    ColumnFilter := ColumnTitle.FilterItem;
    ColumnFilter.Clear;

    Operand1Arr := ValList.ToArray;

    if ValList.Count > 0 then
    begin
      Operand1 := TValue.FromArray(TypeInfo(TArray<TValue>), Operand1Arr);
      ColumnFilter.SetExpression(TSTFilterOperatorEh.foIn, Operand1,
        TSTFilterOperatorEh.foNon, TSTFilterOperatorEh.foNon, TValue.Empty);
    end else
    begin
      ColumnFilter.Clear;
    end;

    TCustomDataGridEhCrack(AColumn.Grid).Title.Filter.ApplyFilter;
  end;

  if AColumn.Grid <> nil  then
    TCustomDataGridEhCrack(AColumn.Grid).InvalidateGrid;

  DynParams.Free;
  SysParams.Free;
end;

{$ENDREGION 'TDataGridTitleBarEh'}

{$REGION 'TDataGridSortItemEh'}

{ TDataGridSortItemEh }

constructor TDataGridSortItemEh.Create;
begin
end;

destructor TDataGridSortItemEh.Destroy;
begin
  inherited Destroy;
end;

{$ENDREGION 'TDataGridSortItemEh'}

{$REGION 'TDataGridTitleCellContextMenuParamsEh'}

{ TDataGridTitleCellContextMenuParamsEh }

procedure TDataGridTitleCellContextMenuParamsEh.Reset(AGrid: TControl; ACell: TGridBaseCellEh);
var
  VGrid: TCustomDataGridEhCrack;
begin
  VGrid := TCustomDataGridEhCrack(AGrid);

  inherited Reset(AGrid, ACell);

  if (AreaColIndex >= 0) and (AreaColIndex < VGrid.VisibleColumns.Count) then
    FColumnTitle := VGrid.VisibleColumns[AreaColIndex].Title
  else
    FColumnTitle := nil;
end;

{$ENDREGION 'TDataGridTitleCellContextMenuParamsEh'}

{$REGION 'TDataGridTitleCellManagerEh'}

{ TDataGridTitleCellManagerEh }

function TDataGridTitleCellManagerEh.CreateCellHolder: TVPBaseCellHolderEh;
begin
  Result := inherited CreateCellHolder();
end;

procedure TDataGridTitleCellManagerEh.ComposeContextMenu(ACellParams: TBaseGridCellComposeContextMenuParamsEh);
var
  VGrid: TCustomDataGridEhCrack;
begin
  VGrid := TCustomDataGridEhCrack(ACellParams.Grid);
  VGrid.ComposeTitleCellMenu(ACellParams as TDataGridTitleCellComposeContextMenuParamsEh);
end;

function TDataGridTitleCellManagerEh.CreateComposeContextMenuParams: TBaseGridCellComposeContextMenuParamsEh;
begin
  Result := TDataGridTitleCellComposeContextMenuParamsEh.Create;
end;

function TDataGridTitleCellManagerEh.CreateCellContentParams(): TBaseGridCreateCellContentParamsEh;
begin
  Result := TDataGridTitleCreateCellContentParamsEh.Create;
end;

procedure TDataGridTitleCellManagerEh.HandleCreateCustomCellContent(Params: TBaseGridCreateCellContentParamsEh);
var
  VGrid: TCustomDataGridEhCrack;
  TitleContentParams: TDataGridTitleCreateCellContentParamsEh;
begin
  VGrid := TCustomDataGridEhCrack(Params.Cell.Grid);
  TitleContentParams := TDataGridTitleCreateCellContentParamsEh(Params);
  VGrid.Title.HandleCreateCellContent(TitleContentParams);

  if Assigned(OnCreateCellContent) then
    OnCreateCellContent(Self, TitleContentParams);
end;

function TDataGridTitleCellManagerEh.DefaultCreateContentControls(ACell: TGridBaseCellEh; AParentObject: TLaObjectEh): TLaControlEh;
var
  TitleCell: TDataGridTitleCellEh;
begin
  with TLaLayoutPanelEh.CreateWith(AParentObject, AParentObject) do
  begin

    TitleCell := TDataGridTitleCellEh(ACell);
    TitleCell.FTextControl := TLaTextBlockEh.CreateWith(AParentObject, RefSelf);
    TitleCell.FTextControl.Padding.Rect := RectF(2, 0, 2, 0);
    TitleCell.FTextControl.VertAlignment := TLaVertAlignmentEh.Center;
    TitleCell.FTextControl.HorzAlignment := TLaHorzAlignmentEh.Stretch;

    Result := TLaControlEh(RefSelf);
  end;
end;

function TDataGridTitleCellManagerEh.CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh;
begin
  Result := TDataGridTitleCellEh.Create(ACellHolder);
end;

function TDataGridTitleCellManagerEh.CreateInitCellParams: TBaseGridInitCellParamsEh;
begin
  Result := TDataGridTitleInitCellParamsEh.Create;
end;

procedure TDataGridTitleCellManagerEh.HandleInitCell(Params: TBaseGridInitCellParamsEh);
begin
end;

procedure TDataGridTitleCellManagerEh.DefaultInitCellProps(Params: TBaseGridInitCellParamsEh);
var
  VGrid: TCustomDataGridEhCrack;
  Column: TDataGridBaseColumnEh;
  TitleCell: TDataGridTitleCellEh;
  SortOrder: TSortOrderEh;
  SortIndex: Integer;
begin
  inherited DefaultInitCellProps(Params);

  TitleCell := TDataGridTitleCellEh(Params.Cell);
  VGrid := TCustomDataGridEhCrack(Params.Grid);
  if (Params.Cell.AreaColIndex >= 0) and (Params.Cell.AreaColIndex < VGrid.VisibleColumns.Count) then
  begin
    Column := VGrid.VisibleColumns[Params.Cell.AreaColIndex];
    if TitleCell.TextControl <> nil then
    begin
      TitleCell.Text := Column.Title.Text;
      TitleCell.TextControl.TextAlign := Column.Title.HorzAlign;
      TitleCell.TextControl.VertAlignment := TLaVertAlignmentEh.Center;
      TitleCell.TextControl.Margins := Column.Title.Padding;
      TitleCell.TextControl.WordWrap := Column.Title.WordWrap;
      TitleCell.TextControl.Font := Column.Title.Font;
      TitleCell.TextControl.FontColor := Column.Title.FontColor;
    end;

    TitleCell.Fill := Column.Title.Fill;

//    TitleCell.ShowSelectionLayer := Column.IsSelected;
    TitleCell.FFilterButton.IsPressed := Column.Title.FilterFormIsVisible;
    TitleCell.IsShowButtonFace := VGrid.Title.MouseInTitle or Column.Title.FilterFormIsVisible;
    TitleCell.IsShowFilterButton := Column.Title.FilterItem.IsShowFilterButton;
    TitleCell.HasFilter := Column.Title.FilterItem.HasValue;

    if Column.Title.GetSortMarkerParams(SortOrder, SortIndex) then
    begin
      TitleCell.SortMarkerPanel.Visible := True;
      if SortIndex > 0 then
      begin
        TitleCell.SortIndexPanel.Visible := True;
        TitleCell.SortIndexPanel.Text := SortIndex.ToString;
      end;
      if SortOrder = TSortOrderEh.soAscEh then
        TLaLayoutPanelEhCrack(TitleCell.SortMarkerPanel).RotationAngle := 0
      else
        TLaLayoutPanelEhCrack(TitleCell.SortMarkerPanel).RotationAngle := 180;
    end else
    begin
      TitleCell.SortMarkerPanel.Visible := False;
      TLaLayoutPanelEhCrack(TitleCell.SortMarkerPanel).RotationAngle := 0;
      TitleCell.SortIndexPanel.Visible := False;
      TitleCell.SortIndexPanel.Text := '';
    end;
  end else
  begin
    if TitleCell.TextControl <> nil then
    begin
      TitleCell.Text := '';
      TitleCell.TextControl.HorzAlignment := TLaHorzAlignmentEh.Left;
      TitleCell.TextControl.VertAlignment := TLaVertAlignmentEh.Center;
      TitleCell.TextControl.Margins.Left := 2;
      TitleCell.TextControl.WordWrap := False;
    end;
    TitleCell.Fill := VGrid.Title.Fill;
    TitleCell.SortMarkerPanel.Visible := False;
    TitleCell.SortIndexPanel.Visible := False;
    TitleCell.SortIndexPanel.Text := '';
    TitleCell.FFilterButton.IsPressed := False;
    TitleCell.IsShowButtonFace := False;
    TitleCell.IsShowFilterButton := False;
    TitleCell.HasFilter := False;
    TLaLayoutPanelEhCrack(TitleCell.SortMarkerPanel).RotationAngle := 0;
  end;
end;

function TDataGridTitleCellManagerEh.CreateInitCellContentParams: TBaseGridInitCellContentParamsEh;
begin
  Result := TDataGridTitleInitCellContentParamsEh.Create;
end;

procedure TDataGridTitleCellManagerEh.HandleInitCellContent(Params: TBaseGridInitCellContentParamsEh);
var
  TitleParams: TDataGridTitleInitCellContentParamsEh;
begin
  TitleParams := Params as TDataGridTitleInitCellContentParamsEh;
  if Assigned(OnCellInitContent) then
    OnCellInitContent(Self, TitleParams);

  if TitleParams.Handled = False then
    TCustomDataGridEhCrack(Params.Grid).Title.HandleInitCellContent(TitleParams);
  if (TitleParams.Handled = False) and (TitleParams.ColumnTitle <> nil) then
    TColumnTitleEhCrack(TitleParams.ColumnTitle).HandleInitCellContent(TitleParams);
end;

procedure TDataGridTitleCellManagerEh.DefaultInitCellContent(AParams: TBaseGridInitCellContentParamsEh);
begin
end;

procedure TDataGridTitleCellManagerEh.InitCellHolder(ACell: TVPBaseCellHolderEh);
begin
  inherited InitCellHolder(ACell);
end;

procedure TDataGridTitleCellManagerEh.InitCellPositionProps(ACell: TGridBaseCellEh);
var
  VGrid: TCustomDataGridEhCrack;
  TitleCell: TDataGridTitleCellEh;
begin
  inherited InitCellPositionProps(ACell);

  VGrid := TCustomDataGridEhCrack(ACell.Grid);
  TitleCell := TDataGridTitleCellEh(ACell);
  if (ACell.AreaColIndex >= 0) and (ACell.AreaColIndex < VGrid.VisibleColumns.Count) then
    TitleCell.FColumnTitle := VGrid.VisibleColumns[ACell.AreaColIndex].Title
  else
    TitleCell.FColumnTitle := nil;
end;

function TDataGridTitleCellManagerEh.GetBackgroundStyle(AParams: TBaseGridInitCellParamsEh): TControl;
var
  VGrid: TCustomDataGridEhCrack;
begin
  VGrid := TCustomDataGridEhCrack(AParams.Grid);
  Result := VGrid.StylePainter.TopFixedCellBackground;
end;

function TDataGridTitleCellManagerEh.IsShowSelectionLayer(AGrid: TControl; ACell: TGridBaseCellEh): Boolean;
var
  TitleCell: TDataGridTitleCellEh;
begin
  TitleCell := TDataGridTitleCellEh(ACell);
  if TitleCell.ColumnTitle <> nil
    then Result := TitleCell.ColumnTitle.Column.IsSelected
    else Result := False;
end;

{$ENDREGION 'TDataGridTitleCellManagerEh'}

{$REGION 'TDataGridTitleVirtualPanelEh'}

{ TDataGridTitleVirtualPanelEh }

function TDataGridTitleVirtualPanelEh.CreateBaseCellManager: TVPBaseCellManagerEh;
begin
  Result := TDataGridTitleCellManagerEh.Create(nil);
end;

procedure TDataGridTitleVirtualPanelEh.EnsureRevokeCellInPanel;
var
  FullTitleRect: TRectF;
  ViewPortRect: TRectF;
begin
  inherited EnsureRevokeCellInPanel;

  if GridCore.Title.IsComplexTitle then
  begin
    FullTitleRect := TRectF.Create(-GridCore.HorzAxis.RollStartVisPos,
                                 GridCore.VertAxis.GridClientStart,
                                 GridCore.HorzAxis.RollLen-GridCore.HorzAxis.RollStartVisPos,
                                 GridCore.VertAxis.FixedBoundary);
    ViewPortRect := TRectF.Create(0, 0, 0, 0);

    GridCore.Title.ComplexTitleTree.EnsureRevokeCellInPanel(Self, FullTitleRect, ViewPortRect);
  end;
end;

procedure TDataGridTitleVirtualPanelEh.InternalUpdateCellPositionProps;
begin
  inherited InternalUpdateCellPositionProps;
  if GridCore.Title.IsComplexTitle then
  begin
    GridCore.Title.ComplexTitleTree.UpdateCellsProps(Self);
  end;
end;

procedure TDataGridTitleVirtualPanelEh.InternalUpdateCellsLayout;
var
  FullTitleRect: TRectF;
  ViewPortRect: TRectF;
begin
  inherited InternalUpdateCellsLayout;
  if GridCore.Title.IsComplexTitle then
  begin
    FullTitleRect := TRectF.Create(
      -GridCore.HorzAxis.RollStartVisPos,
      0,
      GridCore.HorzAxis.RollLen - GridCore.HorzAxis.RollStartVisPos,
      GridCore.VertAxis.FixedBoundary - GridCore.VertAxis.GridClientStart);
    ViewPortRect := TRectF.Create(0, 0, 0, 0);
    GridCore.Title.ComplexTitleTree.UpdateCellsLayout(Self, FullTitleRect, ViewPortRect);
  end;
end;

function TDataGridTitleVirtualPanelEh.GetCellRect(StartColPos, StartRowPos: Single; ColIndex, RowIndex: Integer): TRectF;
var
  VGrid: TCustomDataGridEhCrack;
  GridColIndex: Integer;
  DataColIndex: Integer;
  Column: TDataGridBaseColumnEh;
  TitleNode: TDataGridComplexTitleTreeNodeEh;
begin
  VGrid := TCustomDataGridEhCrack(Grid);
  if (VGrid.Title.IsComplexTitle = True) and
     (VGrid.VisibleColumns.Count > 0) then
  begin
    GridColIndex := InGridStartCol + ColIndex;
    DataColIndex := VGrid.RawToDataColumn(GridColIndex);
    Column := VGrid.VisibleColumns[DataColIndex];
    TitleNode := TDataGridComplexTitleTreeNodeEh(Column.Title.ComplexTitleNode);
    Result := TitleNode.DisplayRect;
    Result.Offset(-GridCore.HorzAxis.RollStartVisPos, 0);
  end else
  begin
    Result := inherited GetCellRect(StartColPos, StartRowPos, ColIndex, RowIndex);
  end;
end;

{$ENDREGION 'TDataGridTitleVirtualPanelEh'}

{$REGION 'TDataGridTitleCellEh'}

{ TDataGridTitleCellEh }

constructor TDataGridTitleCellEh.Create(ACellHolder: TGridBaseCellHolderEh);
begin
  inherited Create(ACellHolder);
  HitTest := True;
end;

destructor TDataGridTitleCellEh.Destroy;
begin
  inherited Destroy;
end;

function TDataGridTitleCellEh.CreateCellClientControls(AParent: TLaObjectEh): TLaObjectEh;
var
  VGrid: TCustomDataGridEhCrack;
  NewSortMarker: TControl;
begin
  VGrid := TCustomDataGridEhCrack(Grid);
  Name := 'DataGridTitleCell';

//  with TLaLayoutPanelEh.CreateWith(Self, RefSelf) do
//  begin
//    Name := 'StyledBackground';
//    FStyledBackground := RefSelf as TLaLayoutPanelEh;
//  end;

  with TLaGridPanelEh.CreateWith(Self, RefSelf) do
  begin
    Result := RefSelf;
    Result.Name := 'CellClient';

    Margins.Rect := TRectF.Create(1, 0, 1, 0);

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Weight;
      Value := 1;
    end;

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Auto;
    end;

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Auto;
    end;

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Auto;
    end;

    
    with CreateCellContent(RefSelf) do
    begin
      ControlCollection.AddControl(RefSelf, 0, -1);
      FCellContent := RefSelf as TLaControlEh;
      FCellContent.Name := 'CellContent';
    end;

    
    with TLaLayoutPanelEh.CreateWith(Self, RefSelf) do
    begin
      ControlCollection.AddControl(RefSelf, 1, -1);
      Margins.Rect := TRectF.Create(2, 0, 2, 0);
      VertAlignment := TLaVertAlignmentEh.Center;
      Width := 10;
      Height := 5;

      if VGrid.StylePainter.SortMarker <> nil then
      begin
        NewSortMarker := VGrid.StylePainter.SortMarker.Clone(Self) as TControl;
        NewSortMarker.Parent := RefSelf;
      end;
      FSortMarkerPanel := TLaLayoutPanelEh(RefSelf);
      FSortMarkerPanel.Name := 'SortMarkerPanel';
    end;

    
    with TLaTextBlockEh.CreateWith(Self, RefSelf) do
    begin
      ControlCollection.AddControl(RefSelf, 2, -1);
      Padding.Rect := RectF(0, 0, 2, 0);
      VertAlignment := TLaVertAlignmentEh.Center;
      Text := '1';
      Font.Size := 7;
      FontColor := VGrid.StylePainter.TopFixedCellForegroundColor;
      FSortIndexPanel := TLaTextBlockEh(RefSelf);
      Name := 'SortMarkerIndex';
    end;

    
    with TLaButtonEh.CreateWith(Self, RefSelf) do
    begin
      ControlCollection.AddControl(RefSelf, 3, -1);
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
      FFilterButton.Name := 'FilterButton';
    end;
  end;
end;

procedure TDataGridTitleCellEh.CreateControls;
begin
  inherited CreateControls;
end;

function TDataGridTitleCellEh.CreateDefaultCellContentControls(AParentObject: TLaObjectEh): TLaObjectEh;
begin
  Result := TDataGridTitleCellManagerEh(CellManager).DefaultCreateContentControls(Self, AParentObject);
end;

function TDataGridTitleCellEh.GetText: String;
begin
  if FTextControl <> nil then
    Result := FTextControl.Text
  else
    Result := '';
end;

procedure TDataGridTitleCellEh.SetText(const Value: String);
begin
  if FTextControl <> nil then
    FTextControl.Text := Value;
end;

//function TDataGridTitleCellEh.GetShowSelectionLayer: Boolean;
//begin
//  Result := FSelectionLayer.Visible;
//end;

procedure TDataGridTitleCellEh.SetHasFilter(const Value: Boolean);
begin
  if FHasFilter <> Value then
  begin
    FHasFilter := Value;
    if FHasFilter = True then
      FButtonImage.MultiResBitmap := EhLibImageResources.DropDownArrowHasFilter
    else
      FButtonImage.MultiResBitmap := EhLibImageResources.DropDownSign;
  end;
end;

function TDataGridTitleCellEh.GetIsShowButtonFace: Boolean;
begin
  Result := FFilterButton.IsButtonBackVisible;
end;

procedure TDataGridTitleCellEh.SetIsShowButtonFace(const Value: Boolean);
begin
  FFilterButton.IsButtonBackVisible := Value;
end;

//procedure TDataGridTitleCellEh.SetShowSelectionLayer(const Value: Boolean);
//begin
//  FSelectionLayer.Visible := Value;
//end;

function TDataGridTitleCellEh.GetCursorAtMousePos(Shift: TShiftState; X, Y: Single): TCursor;
begin
  Result := inherited GetCursorAtMousePos(Shift, X, Y);
end;

function TDataGridTitleCellEh.GetIsShowFilterButton: Boolean;
begin
  Result := FFilterButton.Visible
end;

procedure TDataGridTitleCellEh.SetIsShowFilterButton(const Value: Boolean);
begin
  FFilterButton.Visible := Value;
end;

procedure TDataGridTitleCellEh.ProcessMouseDown(Params: TControlMouseButtonParamsEh);
var
  AGrid: TCustomDataGridEhCrack;
  Column: TDataGridBaseColumnEh;
begin
  inherited ProcessMouseDown(Params);

  AGrid := TCustomDataGridEhCrack(Grid);
  FMouseDownPos := PointF(Params.X, Params.Y).Round;

  if (AreaColIndex >= AGrid.VisibleColumns.Count) then
    Exit;

  if (Params.Handled = True) then
    Exit;

  Column := AGrid.VisibleColumns[AreaColIndex];

  if (Params.OriginalObject = Self) and
     (Params.Button = TMouseButton.mbLeft) and
     (AGrid.FDataGridPotentialMouseState = TDataGridMouseStateEh.ColSelecting) then
  begin
    AGrid.StartColumnSelection(Column, Params.Shift);
  end
  else if (Params.OriginalObject = Self) then
  begin
    if AGrid.GridMouseState = AGrid.GridMouseStateManage.NormalState then
      Capture;
  end;
end;

procedure TDataGridTitleCellEh.ProcessMouseMove(Params: TControlMouseParamsEh);
var
  AGrid: TCustomDataGridEhCrack;
  GridMouseDownPos: TPoint;
  GridMouseMovePos: TPoint;
  AColIndex: Integer;
  ARowIndex: Integer;
  ScreenPos: TPointF;
begin
  AGrid := TCustomDataGridEhCrack(Grid);

  inherited ProcessMouseMove(Params);

  if (AGrid.GridMouseState = AGrid.GridMouseStateManage.NormalState) and
     (AGrid.FDataGridMouseState = TDataGridMouseStateEh.Normal) and
     (Self.IsMouseCaptured = True) and
     (ssLeft in Params.Shift) then
  begin
    GridMouseDownPos := AGrid.ScreenToLocal(LocalToScreen(FMouseDownPos)).Round;
    GridMouseMovePos := Params.GetPositionRelativeTo(AGrid).Round;
    if GridMouseDownPos <> GridMouseMovePos then
    begin
      AColIndex := ColIndex;
      ARowIndex := RowIndex;
      ScreenPos := LocalToScreen(FMouseDownPos);
      AGrid.Capture;
      if AGrid.CheckBeginColumnDrag(AColIndex, AColIndex, GridMouseDownPos) then
          AGrid.StartColMoving(AColIndex, ARowIndex, ScreenPos);
    end;
  end;
end;

procedure TDataGridTitleCellEh.FilterButtonMouseDown(Sender: TObject; Params: TControlMouseButtonParamsEh);
var
  AGrid: TCustomDataGridEhCrack;
  Column: TDataGridBaseColumnEh;
  ColumnTitle: TColumnTitleEhCrack;
begin
  AGrid := TCustomDataGridEhCrack(Grid);

  if (AreaColIndex >= AGrid.VisibleColumns.Count) then
    Exit;

  if (Params.Button <> TMouseButton.mbLeft) then
    Exit;

  Column := AGrid.VisibleColumns[AreaColIndex];
  ColumnTitle := TColumnTitleEhCrack(Column.Title);

  if ColumnTitle.FilterFormIsVisible
    then InTitleFilterListboxCloseUp()
    else InTitleFilterListboxDropDown(Column);
end;

procedure TDataGridTitleCellEh.MouseEnter(Params: TControlParamsEh);
var
  AGrid: TCustomDataGridEhCrack;
begin
  AGrid := TCustomDataGridEhCrack(Grid);
  inherited MouseEnter(Params);
  AGrid.Title.MouseInTitle := True;
end;

procedure TDataGridTitleCellEh.MouseLeave(Params: TControlParamsEh);
var
  AGrid: TCustomDataGridEhCrack;
begin
  AGrid := TCustomDataGridEhCrack(Grid);
  inherited MouseLeave(Params);
  AGrid.Title.MouseInTitle := False;
end;

procedure TDataGridTitleCellEh.InTitleFilterListboxCloseUp();
begin

end;

procedure TDataGridTitleCellEh.InTitleFilterListboxDropDown(Column: TDataGridBaseColumnEh);
var
  AGrid: TCustomDataGridEhCrack;
  ColumnTitle: TColumnTitleEhCrack;
  ACellRectF: TRectF;
  VCellRect: TRect;
  VCellScreenRect: TRect;
begin
  AGrid := TCustomDataGridEhCrack(Grid);
  ColumnTitle := TColumnTitleEhCrack(Column.Title);
  if ColumnTitle.FilterFormIsVisible then
    InTitleFilterListboxCloseUp();

  ACellRectF.Location := TPointF.Create(0, 0);
  ACellRectF.Size := TSizeF.Create(ActualWidth, ActualHeight);
  VCellRect := ACellRectF.Round;
  VCellScreenRect := VCellRect;
  VCellScreenRect.Location := LocalToScreen(VCellScreenRect.Location).Round;

  AGrid.Title.InTitleFilterDropDownFormForRect(Column, VCellScreenRect);
end;

procedure TDataGridTitleCellEh.ProcessMouseClick(Params: TControlMouseButtonParamsEh);
var
  AGrid: TCustomDataGridEhCrack;
  IsMultiSortMarking: Boolean;
  Column: TDataGridBaseColumnEh;
  WasPressed: Boolean;
begin
  AGrid := TCustomDataGridEhCrack(Grid);
  WasPressed := PressedOrChildPressed;

  inherited ProcessMouseClick(Params);

  if (AreaColIndex >= AGrid.VisibleColumns.Count) then
    Exit;

  Column := AGrid.VisibleColumns[AreaColIndex];
  if (WasPressed = True) and
     (Params.Button = TMouseButton.mbLeft) and
     (AGrid.Title.SortMarking.SortMarkable = True) and
     (AGrid.TableView.Active = True) then
  begin
    IsMultiSortMarking := ssCtrl in Params.Shift;
    AGrid.Title.AddChangeSortMarking(Column, IsMultiSortMarking);
  end;
end;

procedure TDataGridTitleCellEh.MouseClick(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited MouseClick(Button, Shift, X, Y);
end;

{$ENDREGION 'TDataGridTitleCellEh'}

{$REGION 'TDataGridTitleCellComposeContextMenuParamsEh'}

{ TDataGridTitleCellComposeContextMenuParamsEh }

procedure TDataGridTitleCellComposeContextMenuParamsEh.Init(AGrid: TControl; ACell: TGridBaseCellEh;
  AControlParams: TControlShowContextMenuParamsEh);
var
  VGrid: TCustomDataGridEhCrack;
begin
  VGrid := TCustomDataGridEhCrack(AGrid);
  inherited Init(AGrid, ACell, AControlParams);

  if (AreaColIndex >= 0) and (AreaColIndex < VGrid.VisibleColumns.Count) then
    FColumn := VGrid.VisibleColumns[AreaColIndex]
  else
    FColumn := nil;
end;

{$ENDREGION 'TDataGridTitleCellComposeContextMenuParamsEh'}

{$REGION 'TDataGridTitleInitCellParamsEh'}

{ TDataGridTitleInitCellParamsEh }

procedure TDataGridTitleInitCellParamsEh.Init(AGrid: TControl; ACellManager: TBaseGridCellManagerEh; ACell: TGridBaseCellEh);
var
  VGrid: TCustomDataGridEhCrack;
begin
  inherited Init(AGrid, ACellManager, ACell);

  VGrid := TCustomDataGridEhCrack(ACell.Grid);
  if (ACell.AreaColIndex >= 0) and (ACell.AreaColIndex < VGrid.VisibleColumns.Count) then
    FColumnTitle := VGrid.VisibleColumns[ACell.AreaColIndex].Title
  else
    FColumnTitle := nil;
end;

{$ENDREGION 'TDataGridTitleInitCellParamsEh'}

{$REGION 'TDataGridTitleInitCellContentParamsEh'}

{ TDataGridTitleInitCellContentParamsEh }

procedure TDataGridTitleInitCellContentParamsEh.Init(ACell: TGridBaseCellEh; ACellContent: TLaObjectEh; InitCellParams: TBaseGridInitCellParamsEh);
begin
  inherited Init(ACell, ACellContent, InitCellParams);
end;

function TDataGridTitleInitCellContentParamsEh.GetFieldBarTitle: TFieldBarTitleEh;
var
  VGrid: TCustomDataGridEhCrack;
begin
  VGrid := TCustomDataGridEhCrack(Cell.Grid);
  if (Cell.AreaColIndex >= 0) and (Cell.AreaColIndex < VGrid.VisibleColumns.Count) then
    Result := VGrid.VisibleColumns[Cell.AreaColIndex].Title
  else
    Result := nil;
end;

function TDataGridTitleInitCellContentParamsEh.GetColumnTitle: TColumnTitleEh;
begin
  Result := TColumnTitleEh(FieldBarTitle);
end;

{$ENDREGION 'TDataGridTitleInitCellContentParamsEh'}

{$REGION 'TDataGridTitleGetCellManagerParamsEh'}

{ TDataGridTitleGetCellManagerParamsEh }

procedure TDataGridTitleGetCellManagerParamsEh.Init(AGrid: TControl;
  AColumnTitle: TColumnTitleEh; ADefaultCellManager: TBaseGridCellManagerEh);
begin
  FGrid := AGrid;
  FColumnTitle := AColumnTitle;
  FCellManager := ADefaultCellManager;
end;

{$ENDREGION 'TDataGridTitleGetCellManagerParamsEh'}

{ TDataGridInteractiveSortMarkersChangedParamsEh }

procedure TDataGridInteractiveSortMarkersChangedParamsEh.ApplySorting;
begin
  TCustomDataGridEhCrack(FGrid).Title.SortMarking.DefaultApplySortMarkers();
end;

constructor TDataGridInteractiveSortMarkersChangedParamsEh.Create;
begin
  inherited Create;
end;

procedure TDataGridInteractiveSortMarkersChangedParamsEh.Init(AGrid: TControl);
begin
  FGrid := AGrid;
end;

end.
