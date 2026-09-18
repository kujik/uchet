{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{             EhLibFmx.LaHostVirtualPanels              }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.LaHostVirtualPanels;

{$I ..\Incl\EhLib.Inc}
{$SCOPEDENUMS ON}

interface

uses
  Types, Classes, SysUtils, Variants,
  Generics.Collections, DB, Math,
  System.UITypes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics,
  EhLibFmx.LaControls,
  EhLibFmx.LaPanels,
  EhLibFmx.LaObjects,
  EhLibFmx.ToolControls,
  EhLibUtils;

type
  TVPBaseCellHolderEh = class;
  TVirtPanelAllCellsArray = array of array of TVPBaseCellHolderEh;
  TLaHostVirtualPanelEh = class;
  TVirtualPanelRollEh = class;
  TVPBaseCellManagerEh = class;

{ TVirtualPanelRollEh }
  TVirtualPanelRollEh = class(TLaControlEh)
  private
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    function DoQueryLayoutClientArea(const QuerySize: TSizeF; ACanvas: TCanvas): TSizeF; overload; override;
    function DoPerformLayoutClientArea(const ClientRect: TRectF; ACanvas: TCanvas): TSizeF; overload; override;

  published
  end;

{ TLaHostVirtualPanelEh }

  TLaHostVirtualPanelEh = class(TControl, ILaHostWinControl, IScene)
  private
    FRollPosX: Single;
    FRollPosY: Single;
    FRollSizeX: Single;
    FRollSizeY: Single;

    FViewPortSize: TSizeF;

    FAllCells: TVirtPanelAllCellsArray;
    FCellFreePools: TDictionary<TObject, TList<TVPBaseCellHolderEh>>;

    FStartVisColIndex: Integer;
    FStartVisRowIndex: Integer;

    FInGridStopRow: Integer;
    FInGridStartRow: Integer;
    FVisColCount: Integer;
    FVisRowCount: Integer;
    FStartVisColOffset: Single;
    FStartVisRowOffset: Single;
    FInGridStopCol: Integer;
    FInGridStartCol: Integer;
    FCacheUpdateRect: Boolean;
    FCachedUpdateRect: TRectF;
    FBaseCellManager: TVPBaseCellManagerEh;
    FMouseMoveObject: TFmxObject;
    FNextParentList: TList<TFmxObject>;
    FCurrentMouseEnterList: TList<TFmxObject>;

    function GetColWidth(ColIndex: Integer): Single;
    function GetRowHeight(RowIndex: Integer): Single;
    function GetColCount: Integer;
    function GetRowCount: Integer;

    procedure SetRollPosX(const Value: Single);
    procedure SetRollPosY(const Value: Single);
    procedure SetRollSizeX(const Value: Single);
    procedure SetRollSizeY(const Value: Single);

    procedure SetStartVisColIndex(const Value: Integer);
    procedure SetStartVisColOffset(const Value: Single);
    procedure SetStartVisRowIndex(const Value: Integer);
    procedure SetStartVisRowOffset(const Value: Single);
    procedure SetCacheUpdateRect(const Value: Boolean);
    procedure FillParentList(ANextParentList: TList<TFmxObject>; AChild: TFmxObject);
    procedure UpdateChildMouseLeaveState();

  protected
    FUpdateCellsProps: Boolean;

    procedure DoAddObject(const AObject: TFmxObject); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure DoMouseEnter; override;
    procedure DoMouseLeave; override;
    procedure DoPaint; override;

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    function GetFreeCell(ACellManager: TVPBaseCellManagerEh): TVPBaseCellHolderEh; overload;
    function CreateBaseCellManager: TVPBaseCellManagerEh; virtual;
    function GetCellFreePoolByManagerId(ALaObjectManagerId: TObject): TList<TVPBaseCellHolderEh>; virtual;
    function SetReLayoutStateFor(LaParent: TLaObjectEh): Boolean;
    function CheckLayoutInterrupting(): Boolean;
    function IsLayoutInterruptible(): Boolean;

    procedure EnsureRevokeCellInPanel; virtual;
    procedure DeleteBadCells; virtual;
    procedure UpdateCellsProps; virtual;
    procedure InternalUpdateCellPositionProps; virtual;
    procedure InternalUpdateCells; virtual;
    procedure RevokeCellFromArrayPos(AColIndex, ARowIndex: Integer);
    procedure EnsureCellAtPos(AColIndex, ARowIndex: Integer);
    procedure UpdateAllCellsArraySize;
    procedure SetReLayoutState();
    procedure InternalUpdateCellsLayout; virtual;
    procedure RemoveCellManagerRefs(CellManager: TVPBaseCellManagerEh);

    {ILaHostWinControl}
    procedure Invalidate();

    procedure ProcessMouseDown(Params: TControlMouseButtonParamsEh);
    procedure ProcessMouseMove(Params: TControlMouseParamsEh);
    procedure ProcessMouseClick(Params: TControlMouseButtonParamsEh);
    procedure ProcessMouseUp(Params: TControlMouseButtonParamsEh);
    procedure ProcessDblClick(Params: TControlParamsEh);

    procedure ProcessPreviewMouseMove(Params: TControlMouseParamsEh);
    procedure ProcessPreviewMouseDown(Params: TControlMouseButtonParamsEh);
    procedure ProcessPreviewMouseUp(Params: TControlMouseButtonParamsEh);
    procedure ProcessPreviewMouseClick(Params: TControlMouseButtonParamsEh);
    procedure ProcessPreviewMouseEnter(Params: TControlParamsEh);
    procedure ProcessPreviewMouseLeave(Params: TControlParamsEh);
    procedure ProcessPreviewDblClick(Params: TControlParamsEh);

    procedure LayoutChanged(LaObject: TLaObjectEh); virtual;
    procedure ProcessPreviewKeyDown(Params: TLaObjectKeyEventParamsEh); virtual;
    procedure ProcessShowContextMenu(Params: TControlShowContextMenuParamsEh); virtual;

    { IStyleBookOwner }
    function GetStyleBook: TStyleBook;
    procedure SetStyleBook(const Value: TStyleBook);
    property StyleBook: TStyleBook read GetStyleBook write SetStyleBook;

    { IScene }

{$IFDEF EH_LIB_28} 
    procedure AddUpdateRect(const R: TRectF);
{$ELSE}
    procedure AddUpdateRect(R: TRectF);
{$ENDIF}
    function GetUpdateRectsCount: Integer;
    function GetUpdateRect(const Index: Integer): TRectF;
    function GetObject: TFmxObject;
    function GetCanvas: TCanvas;
    function GetSceneScale: Single;

{$IFDEF EH_LIB_28} 
    function LocalToScreen(const AScenePoint: TPointF): TPointF; reintroduce;
    function ScreenToLocal(const AScreenPoint: TPointF): TPointF; reintroduce;
{$ELSE}
    function LocalToScreen(AScenePoint: TPointF): TPointF; reintroduce;
    function ScreenToLocal(AScreenPoint: TPointF): TPointF; reintroduce;
{$ENDIF}

    procedure ChangeScrollingState(const AControl: TControl; const AActive: Boolean);
    
    procedure DisableUpdating;
    
    procedure EnableUpdating;
    property Canvas: TCanvas read GetCanvas;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function QueryPerformLayout(QuerySize: TSizeF): TSizeF;
    function GetCellManagerAt(AColIndex, ARowIndex: Integer): TVPBaseCellManagerEh; virtual;
    function GetCellRect(StartColPos, StartRowPos: Single; AColIndex, ARowIndex: Integer): TRectF; virtual;

    procedure DestroyCells;
    procedure UpdateLayout();
    procedure ScrollTo(ARollPosX, ARollPosY: Single);
    procedure SafeScrollTo(ARollPosX, ARollPosY: Single);
    procedure SafeScrollBy(ByX, ByY: Single);
    procedure RealignCells;
    procedure SetInGridCellRange(AInGridStartCol, AGridStopCol, AInGridStartRow, AGridStopRow: Integer);
    procedure InitCellHolder(ACellHolder: TVPBaseCellHolderEh); overload;
    procedure InitCellHolderPositionProps(ACellHolder: TVPBaseCellHolderEh; APanelColIndex, APanelRowIndex: Integer);
    procedure UpdateCellsLayoutState;
    procedure UpdateCellsLayout; virtual;

    property ViewPortSize: TSizeF read FViewPortSize;

    property RollSizeX: Single read FRollSizeX write SetRollSizeX;
    property RollSizeY: Single read FRollSizeY write SetRollSizeY;

    property RollPosX: Single read FRollPosX write SetRollPosX;
    property RollPosY: Single read FRollPosY write SetRollPosY;

    property StartVisColIndex: Integer read FStartVisColIndex write SetStartVisColIndex;
    property StartVisRowIndex: Integer read FStartVisRowIndex write SetStartVisRowIndex;
    property StartVisColOffset: Single read FStartVisColOffset write SetStartVisColOffset;
    property StartVisRowOffset: Single read FStartVisRowOffset write SetStartVisRowOffset;
    property VisColCount: Integer read FVisColCount;
    property VisRowCount: Integer read FVisRowCount;
    property ColCount: Integer read GetColCount;
    property RowCount: Integer read GetRowCount;

    property RowHeight[RowIndex: Integer]: Single read GetRowHeight;
    property ColWidth[ColIndex: Integer]: Single read GetColWidth;
    property InGridStartCol: Integer read FInGridStartCol;
    property InGridStartRow: Integer read FInGridStartRow;
    property InGridStopCol: Integer read FInGridStopCol;
    property InGridStopRow: Integer read FInGridStopRow;

    property CacheUpdateRect: Boolean read FCacheUpdateRect write SetCacheUpdateRect;
    property DefaultCellManager: TVPBaseCellManagerEh read FBaseCellManager;
  end;

{ TVPBaseCellManagerEh }

  TVPBaseCellManagerEh = class(TComponent)
  private
  protected
    procedure InitCellHolder(ACellHolder: TVPBaseCellHolderEh); virtual;
    procedure InitCellHolderPositionProps(ACellHolder: TVPBaseCellHolderEh); virtual;
  public
    constructor Create(AOwner: TComponent); override;

    function CreateCellHolder(): TVPBaseCellHolderEh; virtual;
    function InitAndCaclRenderCellHolder(AGrid: TControl; ACellRenderSize: TSizeF; ACellHolder: TVPBaseCellHolderEh; AGridColIndex, AGridRowIndex: Integer; ALocalColIndex, ALocalRowIndex: Integer): TSizeF;

    procedure InternalInitCellHolder(ACellHolder: TVPBaseCellHolderEh);
  end;

{ TVPBaseCellHolderEh }

  TVPBaseCellHolderEh = class(TLaLayoutPanelEh)
  protected
    FGrid: TControl;
    FColIndex: Integer;
    FRowIndex: Integer;
    FAreaColIndex: Integer;
    FAreaRowIndex: Integer;
    FControlsCreated: Boolean;
    FCellManager: TVPBaseCellManagerEh;
    FCellIsInGridCellPos: Boolean;
    FPrevColCellHolder: TVPBaseCellHolderEh;
    FNextColCellHolder: TVPBaseCellHolderEh;
    FPrevRowCellHolder: TVPBaseCellHolderEh;
    FNextRowCellHolder: TVPBaseCellHolderEh;
    FFastMockLayout: Boolean;

  protected
    procedure CreateControls(AParent: TLaObjectEh); virtual;

  public
    constructor Create(AOwner: TComponent; ACellManager: TVPBaseCellManagerEh); overload; virtual;
    destructor Destroy; override;

    class function GetParentCell(ChildObject: TLaObjectEh): TVPBaseCellHolderEh;
    procedure InitPositionProps(); virtual;

    procedure InitControls(); virtual;

    function DoQueryLayout(const QuerySize: TSizeF; ACanvas: TCanvas): TSizeF; override;
    function DoPerformLayout(const PerfSize: TSizeF; ACanvas: TCanvas): TSizeF; override;

    property ColIndex: Integer read FColIndex;
    property RowIndex: Integer read FRowIndex;
    property AreaColIndex: Integer read FAreaColIndex;
    property AreaRowIndex: Integer read FAreaRowIndex;

    property CellManager: TVPBaseCellManagerEh read FCellManager;
    property Grid: TControl read FGrid;
    property CellIsInGridCellPos: Boolean read FCellIsInGridCellPos;

    property PrevColCellHolder: TVPBaseCellHolderEh read FPrevColCellHolder;
    property NextColCellHolder: TVPBaseCellHolderEh read FNextColCellHolder;
    property PrevRowCellHolder: TVPBaseCellHolderEh read FPrevRowCellHolder;
    property NextRowCellHolder: TVPBaseCellHolderEh read FNextRowCellHolder;
  end;

{ TVPTextCellEh }

  TVPTextCellEh = class(TVPBaseCellHolderEh)
  private
    FText: TLaTextBlockEh;
    function GetText: String;
    procedure SetText(const Value: String);
  protected
    procedure CreateControls(AParent: TLaObjectEh); override;

  public
    constructor Create(AOwner: TComponent; ACellManager: TVPBaseCellManagerEh); override;
    destructor Destroy; override;

    property Text: String read GetText write SetText;
    property TextControl: TLaTextBlockEh read FText;
  end;

implementation

uses EhLibFmx.Grids;

type
  TCustomGridEhCrack = class(TCustomGridEh);
  TLaObjectEhCrack = class(TLaObjectEh);

  TLaHostVirtualPanelEhHelper = class helper for TLaHostVirtualPanelEh
  private
    function GetGrid: TCustomGridEhCrack;
  public
    property Grid: TCustomGridEhCrack read GetGrid;
  end;

function TLaHostVirtualPanelEhHelper.GetGrid: TCustomGridEhCrack;
begin
  Result := TCustomGridEhCrack(Owner);
end;

{ TLaHostVirtualPanelEh }

constructor TLaHostVirtualPanelEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FCellFreePools := TDictionary<TObject, TList<TVPBaseCellHolderEh>>.Create;

  ClipChildren := True;
  HitTest := True; 

  FInGridStopRow := -1;
  FInGridStartRow := -1;
  FInGridStopCol := -1;
  FInGridStartCol := -1;

  FBaseCellManager := CreateBaseCellManager;
  FNextParentList := TList<TFmxObject>.Create;
  FCurrentMouseEnterList := TList<TFmxObject>.Create;
end;

destructor TLaHostVirtualPanelEh.Destroy;
begin
  DestroyCells;
  FreeAndNil(FBaseCellManager);
  FreeAndNil(FNextParentList);
  FreeAndNil(FCurrentMouseEnterList);
  FreeAndNil(FCellFreePools);
  inherited Destroy;
end;

procedure TLaHostVirtualPanelEh.DestroyCells;
var
  KeyValue: TPair<TObject, TList<TVPBaseCellHolderEh>>;
begin
  SetInGridCellRange(0, -1, 0, -1);
  for KeyValue in FCellFreePools do
  begin
    KeyValue.Value.Free;
  end;
  FCellFreePools.Clear;
end;

procedure TLaHostVirtualPanelEh.RealignCells;
begin
  CacheUpdateRect := True;

  try
    FUpdateCellsProps := True;
    try
      DeleteBadCells();
      EnsureRevokeCellInPanel();
      UpdateCellsProps();
    finally
      FUpdateCellsProps := False;
    end;

    UpdateCellsLayoutState();
    UpdateCellsLayout();
  finally
    Scene.AddUpdateRect(FCachedUpdateRect);
    CacheUpdateRect := False;
  end;
end;

procedure TLaHostVirtualPanelEh.DeleteBadCells;

  procedure DeleteCellAtPos(CC, RC: Integer);
  var
    ACell: TVPBaseCellHolderEh;
  begin
    ACell := FAllCells[CC, RC];
    ACell.Free;
    FAllCells[CC, RC] := nil;
    FCurrentMouseEnterList.Clear;
  end;

var
  CC, RC: Integer;
  ACell: TVPBaseCellHolderEh;
  I: Integer;
  StrToListPair: TPair<TObject, TList<TVPBaseCellHolderEh>>;
begin
  for CC := 0 to Length(FAllCells) - 1 do
  begin
    for RC := 0 to Length(FAllCells[CC]) - 1 do
    begin
      ACell := FAllCells[CC, RC];
      if (ACell <> nil) and (ACell.CellManager = nil) then
      begin
        DeleteCellAtPos(CC, RC);
      end;
    end;
  end;

  for StrToListPair in FCellFreePools do
  begin
    for I := StrToListPair.Value.Count - 1 downto 0 do
    begin
      ACell := StrToListPair.Value[I];
      if ACell.CellManager = nil then
      begin
        ACell.Free;
        StrToListPair.Value.Delete(I);
      end;
    end;
  end;
end;

procedure TLaHostVirtualPanelEh.EnsureRevokeCellInPanel;
var
  CI, RI: Integer;
  FinishVisColIndex: Integer;
  FinishVisRowIndex: Integer;
  ViewCellsSize: TSizeF;
  VisCellsWidth: Single;
  VisCellsHeight: Single;
  CellManager: TVPBaseCellManagerEh;
  Cell: TVPBaseCellHolderEh;
begin
  FViewPortSize.Width := Round(Width);
  FViewPortSize.Height := Round(Height);

  ViewCellsSize.Width := FViewPortSize.Width - FStartVisColOffset;
  ViewCellsSize.Height := FViewPortSize.Height - FStartVisRowOffset;

  FVisColCount := 0;
  VisCellsWidth := 0;
  for CI := StartVisColIndex to ColCount - 1 do
  begin
    VisCellsWidth := VisCellsWidth + ColWidth[CI];
    FVisColCount := FVisColCount + 1;
    if VisCellsWidth > ViewCellsSize.Width then
      Break;
  end;

  FVisRowCount := 0;
  VisCellsHeight := 0;
  for RI := StartVisRowIndex to RowCount - 1 do
  begin
    VisCellsHeight := VisCellsHeight + RowHeight[RI];
    FVisRowCount := FVisRowCount + 1;
    if VisCellsHeight > ViewCellsSize.Height then
      Break;
  end;

  FinishVisColIndex := StartVisColIndex + FVisColCount - 1;
  FinishVisRowIndex := StartVisRowIndex + FVisRowCount - 1;

  for CI := 0 to ColCount - 1 do
  begin
    for RI := 0 to RowCount - 1 do
    begin
      if (CI >= StartVisColIndex) and
         (CI <= FinishVisColIndex) and
         (RI >= StartVisRowIndex) and
         (RI <= FinishVisRowIndex) then
      begin
        CellManager := GetCellManagerAt(CI, RI);
        Cell := FAllCells[CI, RI];

        if (Cell <> nil) and
           (CellManager <> Cell.CellManager) then
        begin
          RevokeCellFromArrayPos(CI, RI);
        end else
        begin
          
        end;
      end else
      begin
        if FAllCells[CI, RI] <> nil then
          RevokeCellFromArrayPos(CI, RI);
      end;
    end;
  end;

  for CI := StartVisColIndex to FinishVisColIndex do
  begin
    for RI := StartVisRowIndex to FinishVisRowIndex do
    begin
      EnsureCellAtPos(CI, RI);
    end;
  end;
end;

procedure TLaHostVirtualPanelEh.RevokeCellFromArrayPos(AColIndex, ARowIndex: Integer);
var
  ACell: TVPBaseCellHolderEh;
  ACellFreePool: TList<TVPBaseCellHolderEh>;
begin
  if FAllCells[AColIndex, ARowIndex] <> nil then
  begin
    ACell := FAllCells[AColIndex, ARowIndex];
    FAllCells[AColIndex, ARowIndex] := nil;

    ACellFreePool := GetCellFreePoolByManagerId(ACell.CellManager);
    ACellFreePool.Add(ACell);

    ACell.SetBounds(0, 0, 0, 0);
    ACell.Visible := False;
    ACell.FCellIsInGridCellPos := False;
  end;
end;


procedure TLaHostVirtualPanelEh.EnsureCellAtPos(AColIndex, ARowIndex: Integer);
var
  CurrCell: TVPBaseCellHolderEh;
  NewCell: TVPBaseCellHolderEh;
  CurCellManager: TVPBaseCellManagerEh;
  NewCellManager: TVPBaseCellManagerEh;
  CurCellManagerModelId, NewCellManagerModelId: TObject;
begin
  CurrCell := FAllCells[AColIndex, ARowIndex];
  if CurrCell <> nil then
  begin
    CurCellManager := CurrCell.CellManager;
    CurCellManagerModelId := CurCellManager;
  end else
  begin
    CurCellManagerModelId := nil;
  end;

  NewCellManager := GetCellManagerAt(AColIndex, ARowIndex);
  if NewCellManager <> nil
    then NewCellManagerModelId := NewCellManager
    else NewCellManagerModelId := nil;


  if CurCellManagerModelId <> NewCellManagerModelId then
  begin
    RevokeCellFromArrayPos(AColIndex, ARowIndex);
    NewCellManager.FreeNotification(Self);

    NewCell := GetFreeCell(NewCellManager);
    NewCell.Visible := True;
    NewCell.FCellIsInGridCellPos := True;
    FAllCells[AColIndex, ARowIndex] := NewCell;
  end;
end;


procedure TLaHostVirtualPanelEh.UpdateCellsLayoutState;
begin
  SetReLayoutState;
end;

procedure TLaHostVirtualPanelEh.UpdateCellsProps;
begin
  InternalUpdateCellPositionProps;
  InternalUpdateCells;
end;

procedure TLaHostVirtualPanelEh.InternalUpdateCellPositionProps;
var
  CI, RI: Integer;
  ACell: TLaObjectEh;
begin
  for CI := StartVisColIndex to StartVisColIndex + VisColCount - 1 do
  begin
    for RI := StartVisRowIndex to StartVisRowIndex + VisRowCount - 1 do
    begin
      ACell := FAllCells[CI, RI];
      if (ACell <> nil) then
        InitCellHolderPositionProps(TVPBaseCellHolderEh(ACell), CI, RI);
    end;
  end;
end;

procedure TLaHostVirtualPanelEh.InternalUpdateCells;
var
  CI, RI: Integer;
  ACell: TLaObjectEh;
begin
  for CI := StartVisColIndex to StartVisColIndex + VisColCount - 1 do
  begin
    for RI := StartVisRowIndex to StartVisRowIndex + VisRowCount - 1 do
    begin
      ACell := FAllCells[CI, RI];
      if (ACell <> nil) then
        InitCellHolder(TVPBaseCellHolderEh(ACell));
    end;
  end;
end;

procedure TLaHostVirtualPanelEh.UpdateCellsLayout;
begin
  InternalUpdateCellsLayout;
end;

procedure TLaHostVirtualPanelEh.InternalUpdateCellsLayout;
var
  CI, RI: Integer;
  CellLeft, CellTop: Single;
  ACell: TVPBaseCellHolderEh;
  CellRect: TRectF;
begin
  CellLeft := StartVisColOffset;
  for CI := StartVisColIndex to StartVisColIndex + VisColCount - 1 do
  begin
    CellTop := StartVisRowOffset;
    for RI := StartVisRowIndex to StartVisRowIndex + VisRowCount - 1 do
    begin
      ACell := FAllCells[CI, RI];
      if ACell <> nil then
      begin
        CellRect := GetCellRect(CellLeft, CellTop, CI, RI);
        if CheckLayoutInterrupting then
        begin
          ACell.FFastMockLayout := True;
        end else
        begin
          ACell.FFastMockLayout := False;
        end;
        ACell.QueryLayout(CellRect.Size, Canvas);
        ACell.PerformLayout(CellRect, Canvas, TLaObjectEh.UnlimitedRect);
      end;
      CellTop := CellTop + RowHeight[RI];
    end;
    CellLeft := CellLeft + ColWidth[CI];
  end;
end;

procedure TLaHostVirtualPanelEh.DoPaint;
begin
  inherited DoPaint;
end;

function TLaHostVirtualPanelEh.GetCellRect(StartColPos, StartRowPos: Single; AColIndex, ARowIndex: Integer): TRectF;
var
  ResultRight: Single;
  ResultBottom: Single;
begin
  ResultRight := StartColPos + ColWidth[AColIndex];
  ResultBottom := StartRowPos + RowHeight[ARowIndex];

  Result := TRectF.Create(StartColPos, StartRowPos, ResultRight, ResultBottom);
end;

procedure TLaHostVirtualPanelEh.InitCellHolderPositionProps(
  ACellHolder: TVPBaseCellHolderEh; APanelColIndex, APanelRowIndex: Integer);
var
  ALocalColIndex, ALocalRowIndex: Integer;
  AGridColIndex, AGridRowIndex: Integer;
begin
  if APanelColIndex >= 0 then
    AGridColIndex := APanelColIndex + InGridStartCol
  else
    AGridColIndex := -1;

  if APanelRowIndex >= 0 then
    AGridRowIndex := APanelRowIndex + InGridStartRow
  else
    AGridRowIndex := -1;

  Grid.GridColRowToLocalColRowIndex(AGridColIndex, AGridRowIndex, ALocalColIndex, ALocalRowIndex);

  if APanelColIndex > StartVisColIndex
    then ACellHolder.FPrevColCellHolder := FAllCells[APanelColIndex - 1, APanelRowIndex]
    else ACellHolder.FPrevColCellHolder := nil;

  if APanelColIndex < StartVisColIndex + VisColCount - 1
    then ACellHolder.FNextColCellHolder := FAllCells[APanelColIndex + 1, APanelRowIndex]
    else ACellHolder.FNextColCellHolder := nil;

  if APanelRowIndex > StartVisRowIndex
    then ACellHolder.FPrevRowCellHolder := FAllCells[APanelColIndex, APanelRowIndex - 1]
    else ACellHolder.FPrevRowCellHolder := nil;

  if APanelRowIndex < StartVisRowIndex + VisRowCount - 1
    then ACellHolder.FNextRowCellHolder := FAllCells[APanelColIndex, APanelRowIndex + 1]
    else ACellHolder.FNextRowCellHolder := nil;

  ACellHolder.FGrid := Grid;
  ACellHolder.FColIndex := AGridColIndex;
  ACellHolder.FRowIndex := AGridRowIndex;
  ACellHolder.FAreaColIndex := ALocalColIndex;
  ACellHolder.FAreaRowIndex := ALocalRowIndex;

  ACellHolder.CellManager.InitCellHolderPositionProps(ACellHolder);
end;

procedure TLaHostVirtualPanelEh.InitCellHolder(ACellHolder: TVPBaseCellHolderEh);
begin
  ACellHolder.CellManager.InternalInitCellHolder(ACellHolder);
end;

function TLaHostVirtualPanelEh.GetColWidth(ColIndex: Integer): Single;
begin
  Result := Grid.ColWidths[ColIndex + InGridStartCol];
end;

function TLaHostVirtualPanelEh.GetRowHeight(RowIndex: Integer): Single;
begin
  Result := Grid.RowHeights[RowIndex + InGridStartRow];
end;

function TLaHostVirtualPanelEh.GetColCount: Integer;
begin
  Result := InGridStopCol - InGridStartCol + 1;
end;

function TLaHostVirtualPanelEh.GetRowCount: Integer;
begin
  Result := InGridStopRow - InGridStartRow + 1;
end;

procedure TLaHostVirtualPanelEh.UpdateLayout;
begin
  if Canvas <> nil then
    QueryPerformLayout(Size.Size);
end;

function TLaHostVirtualPanelEh.QueryPerformLayout(QuerySize: TSizeF): TSizeF;
begin
  RealignCells;
end;

procedure TLaHostVirtualPanelEh.SetReLayoutState;
var
  FmxObject: TFmxObject;
  LaObject: TLaObjectEh;
  I: Integer;
begin
  for I := 0 to ChildrenCount - 1 do
  begin
    FmxObject := Children[I];
    if FmxObject is TLaObjectEh then
    begin
      LaObject := TLaObjectEh(FmxObject);
      SetReLayoutStateFor(LaObject);
    end;
  end;
end;

function TLaHostVirtualPanelEh.SetReLayoutStateFor(LaParent: TLaObjectEh): Boolean;
var
  FmxObject: TFmxObject;
  LaObject: TLaObjectEh;
  I: Integer;
  ReLayoutState: Boolean;
  ChildLayoutState: Boolean;
begin
  if (LaParent.Visible = True) and
     ((LaParent.IsQueryLayoutNeeded = True) or (LaParent.IsPerformLayoutNeeded = True)) then
  begin
    ReLayoutState := True;
  end else
  begin
    ReLayoutState := False;
  end;

  for I := 0 to LaParent.ChildrenCount - 1 do
  begin
    FmxObject := LaParent.Children[I];
    if FmxObject is TLaObjectEh then
    begin
      LaObject := TLaObjectEh(FmxObject);
      if LaObject.Visible = False then
        Continue;
      ChildLayoutState := SetReLayoutStateFor(LaObject);
      if ChildLayoutState = True then
        ReLayoutState := True;
    end;
  end;

  if (ReLayoutState = True) then
  begin
    LaParent.InternalLayoutChanged;
    Result := True;
  end else
  begin
    Result := False;
  end;
end;

procedure TLaHostVirtualPanelEh.SafeScrollBy(ByX, ByY: Single);
begin
  SafeScrollTo(RollPosX + ByX, RollPosY + ByY);
end;

procedure TLaHostVirtualPanelEh.SafeScrollTo(ARollPosX, ARollPosY: Single);
begin
  if ARollPosX + ViewPortSize.Width > RollSizeX then
    ARollPosX := RollSizeX - ViewPortSize.Width;
  if ARollPosX < 0 then
    ARollPosX := 0;

  if ARollPosY + ViewPortSize.Height > RollSizeY then
    ARollPosY := RollSizeY - ViewPortSize.Height;
  if ARollPosY < 0 then
    ARollPosY := 0;

  ScrollTo(ARollPosX, ARollPosY);
end;

procedure TLaHostVirtualPanelEh.ScrollTo(ARollPosX, ARollPosY: Single);
begin
  FRollPosX := ARollPosX;
  FRollPosY := ARollPosY;

  Realign;
end;

procedure TLaHostVirtualPanelEh.SetInGridCellRange(AInGridStartCol, AGridStopCol, AInGridStartRow, AGridStopRow: Integer);
begin
  if (AGridStopRow <> FInGridStopRow) or
     (AInGridStartRow <> FInGridStartRow) or
     (AGridStopCol <> FInGridStopCol) or
     (AInGridStartCol <> FInGridStartCol) then
  begin
    FInGridStopRow := AGridStopRow;
    FInGridStartRow := AInGridStartRow;
    FInGridStopCol := AGridStopCol;
    FInGridStartCol := AInGridStartCol;
    UpdateAllCellsArraySize;
  end;
end;

procedure TLaHostVirtualPanelEh.UpdateAllCellsArraySize;
var
  c,r: Integer;
  OldCC, OldRC: Integer;
  ARowCount, AColCount: Integer;
begin
  AColCount := ColCount;
  ARowCount := RowCount;
  if (Length(FAllCells) > 0) then
  begin
    OldRC := Length(FAllCells[0]);
    OldCC  := Length(FAllCells);
    if ARowCount > OldRC then
    begin
      for c := 0 to OldCC-1 do
      begin
        SetLength(FAllCells[c], ARowCount);
        for r := OldRC to ARowCount-1 do
          FAllCells[c, r] := nil;
      end;
    end else if ARowCount < OldRC then
    begin
      for c := 0 to OldCC-1 do
      begin
        for r := ARowCount to OldRC-1 do
        begin
          FAllCells[c, r].Free;
          FAllCells[c, r] := nil;
        end;
        SetLength(FAllCells[c], ARowCount);
      end;
    end;
  end;

  if AColCount > Length(FAllCells) then
  begin
    OldCC  := Length(FAllCells);
    SetLength(FAllCells, AColCount);
    for c := OldCC to AColCount-1 do
    begin
      SetLength(FAllCells[c], ARowCount);
      for r := 0 to ARowCount-1 do
        FAllCells[c, r] := nil;
    end;
  end else if AColCount < Length(FAllCells) then
  begin
    OldCC  := Length(FAllCells);
    for c := AColCount to OldCC-1 do
    begin
      for r := 0 to ARowCount-1 do
      begin
        FAllCells[c, r].Free;
        FAllCells[c, r] := nil;
      end;
    end;
    SetLength(FAllCells, AColCount);
  end;
end;

procedure TLaHostVirtualPanelEh.RemoveCellManagerRefs(CellManager: TVPBaseCellManagerEh);
var
  CC, RC: Integer;
  ACell: TVPBaseCellHolderEh;
  StrToListPair: TPair<TObject, TList<TVPBaseCellHolderEh>>;
begin
  for CC := 0 to Length(FAllCells) - 1 do
  begin
    for RC := 0 to Length(FAllCells[CC]) - 1 do
    begin
      ACell := FAllCells[CC, RC];
      if (ACell <> nil) and (ACell.CellManager = CellManager) then
        ACell.FCellManager := nil;
    end;
  end;

  if FCellFreePools <> nil then
  begin
    for StrToListPair in FCellFreePools do
    begin
      for ACell in  StrToListPair.Value do
      begin
        if ACell.CellManager = CellManager then
          ACell.FCellManager := nil;
      end;
    end;
  end;
end;

function TLaHostVirtualPanelEh.GetFreeCell(ACellManager: TVPBaseCellManagerEh): TVPBaseCellHolderEh;
var
  ACellFreePool: TList<TVPBaseCellHolderEh>;
begin
  ACellFreePool := GetCellFreePoolByManagerId(ACellManager);

  if ACellFreePool.Count = 0 then
  begin
    Result := ACellManager.CreateCellHolder();
    AddObject(Result);
  end
  else
  begin
    Result := ACellFreePool[ACellFreePool.Count - 1];
    ACellFreePool.Delete(ACellFreePool.Count - 1);
  end;
end;

function TLaHostVirtualPanelEh.GetCellManagerAt(AColIndex, ARowIndex: Integer): TVPBaseCellManagerEh;
begin
  Result := DefaultCellManager;
end;

function TLaHostVirtualPanelEh.CreateBaseCellManager: TVPBaseCellManagerEh;
begin
  Result := TVPBaseCellManagerEh.Create(Self);
end;

function TLaHostVirtualPanelEh.GetCellFreePoolByManagerId(ALaObjectManagerId: TObject): TList<TVPBaseCellHolderEh>;
begin
  if FCellFreePools.TryGetValue(ALaObjectManagerId, Result) then
  begin
    
  end else
  begin
    Result := TList<TVPBaseCellHolderEh>.Create;
    FCellFreePools.Add(ALaObjectManagerId, Result);
  end;
end;

procedure TLaHostVirtualPanelEh.SetRollPosX(const Value: Single);
begin
  FRollPosX := Value;
end;

procedure TLaHostVirtualPanelEh.SetRollPosY(const Value: Single);
begin
  FRollPosY := Value;
end;

procedure TLaHostVirtualPanelEh.SetRollSizeX(const Value: Single);
begin
  FRollSizeX := Value;
end;

procedure TLaHostVirtualPanelEh.SetRollSizeY(const Value: Single);
begin
  FRollSizeY := Value;
end;

procedure TLaHostVirtualPanelEh.SetStartVisColIndex(const Value: Integer);
begin
  FStartVisColIndex := Value;
end;

procedure TLaHostVirtualPanelEh.SetStartVisColOffset(const Value: Single);
begin
  FStartVisColOffset := Value;
end;

procedure TLaHostVirtualPanelEh.SetStartVisRowOffset(const Value: Single);
begin
  FStartVisRowOffset := Value;
end;

procedure TLaHostVirtualPanelEh.SetStartVisRowIndex(const Value: Integer);
begin
  FStartVisRowIndex := Value;
end;

procedure TLaHostVirtualPanelEh.Invalidate;
begin
end;

procedure TLaHostVirtualPanelEh.LayoutChanged(LaObject: TLaObjectEh);
begin
end;

procedure TLaHostVirtualPanelEh.FillParentList(ANextParentList: TList<TFmxObject>; AChild: TFmxObject);
var
  AParent: TFmxObject;
begin
  AParent := AChild;
  while (AParent <> nil) and (AParent <> Self) do
  begin
    if (AParent is TLaObjectEh) and TLaObjectEh(AParent).HitTest then
      ANextParentList.Add(AParent);
    AParent := AParent.Parent;
  end;

  ANextParentList.Reverse;
end;

procedure TLaHostVirtualPanelEh.ProcessPreviewMouseMove(Params: TControlMouseParamsEh);
var
  MinCount: Integer;
  I: Integer;
  SameCount: Integer;
  EnterParams: TControlParamsEh;
  LaObject: TLaObjectEhCrack;
begin
  if FMouseMoveObject <> Params.OriginalObject then
  begin
    EnterParams := TControlParamsEh.Create;
    EnterParams.Init(Params.OriginalObject);
    try
      FMouseMoveObject := Params.OriginalObject;

      FNextParentList.Clear;
      FillParentList(FNextParentList, FMouseMoveObject);

      MinCount := Math.Min(FNextParentList.Count, FCurrentMouseEnterList.Count);

      SameCount := MinCount;
      for I := 0 to MinCount - 1 do
      begin
        if FNextParentList[I] <> FCurrentMouseEnterList[I] then
        begin
          SameCount := I;
          Break;
        end;
      end;

      for I := FCurrentMouseEnterList.Count - 1 downto SameCount do
      begin
        if FCurrentMouseEnterList[I] is TLaObjectEh then
        begin
          LaObject := TLaObjectEhCrack(FCurrentMouseEnterList[I]);
          LaObject.MouseLeave(EnterParams);
          FCurrentMouseEnterList.Delete(I);
          LaObject.RemoveFreeNotify(Self);
        end;
      end;

      for I := SameCount to FNextParentList.Count - 1 do
      begin
        if FNextParentList[I] is TLaObjectEh then
        begin
          LaObject := TLaObjectEhCrack(FNextParentList[I]);
          LaObject.MouseEnter(EnterParams);
          FCurrentMouseEnterList.Add(LaObject);
          LaObject.AddFreeNotify(Self);
        end;
      end;
    finally
      EnterParams.Free;
    end;
  end;

  Grid.ProcessPreviewVirtPanelMouseMove(Self, Params);
end;

procedure TLaHostVirtualPanelEh.ProcessPreviewMouseEnter(Params: TControlParamsEh);
begin
  Grid.ProcessPreviewVirtPanelMouseEnter(Self, Params);
end;

procedure TLaHostVirtualPanelEh.ProcessPreviewMouseLeave(Params: TControlParamsEh);
begin
  UpdateChildMouseLeaveState();
  Grid.ProcessPreviewVirtPanelMouseLeave(Self, Params);
end;

procedure TLaHostVirtualPanelEh.UpdateChildMouseLeaveState();
var
  I: Integer;
  LaObject: TLaObjectEhCrack;
  EnterParams: TControlParamsEh;
begin
  if FCurrentMouseEnterList.Count = 0 then Exit;

  EnterParams := TControlParamsEh.Create;
  EnterParams.Init(Self);
  try
    for I := FCurrentMouseEnterList.Count - 1 downto 0 do
    begin
      if FCurrentMouseEnterList[I] is TLaObjectEh then
      begin
        LaObject := TLaObjectEhCrack(FCurrentMouseEnterList[I]);
        LaObject.MouseLeave(EnterParams);
        FCurrentMouseEnterList.Delete(I);
        LaObject.RemoveFreeNotify(Self);
      end;
    end;
  finally
    EnterParams.Free;
  end;

  FMouseMoveObject := nil;
end;

procedure TLaHostVirtualPanelEh.ProcessMouseDown(Params: TControlMouseButtonParamsEh);
begin
  Grid.ProcessVirtPanelMouseDown(Self, Params);
end;

procedure TLaHostVirtualPanelEh.ProcessPreviewMouseDown(Params: TControlMouseButtonParamsEh);
begin
  Grid.ProcessPreviewVirtPanelMouseDown(Self, Params);
end;

procedure TLaHostVirtualPanelEh.ProcessMouseMove(Params: TControlMouseParamsEh);
begin
  Grid.ProcessVirtPanelMouseMove(Self, Params);
end;

procedure TLaHostVirtualPanelEh.ProcessMouseUp(Params: TControlMouseButtonParamsEh);
begin
  Grid.ProcessVirtPanelMouseUp(Self, Params);
end;

procedure TLaHostVirtualPanelEh.ProcessPreviewMouseUp(Params: TControlMouseButtonParamsEh);
begin
  Grid.ProcessPreviewVirtPanelMouseUp(Self, Params);
end;

procedure TLaHostVirtualPanelEh.ProcessPreviewMouseClick(Params: TControlMouseButtonParamsEh);
begin
  Grid.ProcessPreviewVirtPanelMouseClick(Self, Params);
end;

procedure TLaHostVirtualPanelEh.ProcessMouseClick(Params: TControlMouseButtonParamsEh);
begin
  Grid.ProcessVirtPanelMouseClick(Self, Params);
end;

procedure TLaHostVirtualPanelEh.ProcessShowContextMenu(Params: TControlShowContextMenuParamsEh);
begin
  Grid.ProcessShowVirtPanelContextMenu(Self, Params);
end;

procedure TLaHostVirtualPanelEh.ProcessPreviewKeyDown(Params: TLaObjectKeyEventParamsEh);
begin
  Grid.ProcessPreviewVirtPanelKeyDown(Self, Params);
end;

procedure TLaHostVirtualPanelEh.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  MouseParams: TControlMouseButtonParamsEh;
begin
  inherited MouseDown(Button, Shift, X, Y);

  MouseParams := TControlMouseButtonParamsEh.Create;
  MouseParams.Init(Button, X, Y, Shift, Self);
  try
    Grid.ProcessPreviewVirtPanelMouseDown(Self, MouseParams);
  finally
    MouseParams.Free;
  end;
end;

procedure TLaHostVirtualPanelEh.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  MouseParams: TControlMouseButtonParamsEh;
begin
  inherited MouseUp(Button, Shift, X, Y);

  MouseParams := TControlMouseButtonParamsEh.Create;
  MouseParams.Init(Button, X, Y, Shift, Self);
  try
    Grid.ProcessPreviewVirtPanelMouseUp(Self, MouseParams);
  finally
    MouseParams.Free;
  end;
end;

procedure TLaHostVirtualPanelEh.MouseMove(Shift: TShiftState; X, Y: Single);
var
  MouseParams: TControlMouseParamsEh;
begin
  inherited MouseMove(Shift, X, Y);
  UpdateChildMouseLeaveState();

  MouseParams := TControlMouseParamsEh.Create;
  MouseParams.Init(X, Y, Shift, Self);
  try
    Grid.ProcessPreviewVirtPanelMouseMove(Self, MouseParams);
  finally
    MouseParams.Free;
  end;
end;

procedure TLaHostVirtualPanelEh.DoMouseEnter;
var
  EnterParams: TControlParamsEh;
begin
  inherited DoMouseEnter;

  EnterParams := TControlParamsEh.Create;
  EnterParams.Init(Self);
  try
    Grid.ProcessPreviewVirtPanelMouseEnter(Self, EnterParams);
  finally
    EnterParams.Free;
  end;
end;

procedure TLaHostVirtualPanelEh.DoMouseLeave;
begin
  inherited DoMouseLeave;
end;

procedure TLaHostVirtualPanelEh.ProcessDblClick(Params: TControlParamsEh);
begin
end;

procedure TLaHostVirtualPanelEh.ProcessPreviewDblClick(Params: TControlParamsEh);
begin
  Grid.ProcessPreviewVirtPanelDblClick(Self, Params);
end;

procedure TLaHostVirtualPanelEh.Notification(AComponent: TComponent; Operation: TOperation);
var
  LaObject: TLaObjectEh;
begin
  inherited Notification(AComponent, Operation);
  if (Operation = TOperation.opRemove) then
  begin
    if AComponent is TVPBaseCellManagerEh then
    begin
      RemoveCellManagerRefs(TVPBaseCellManagerEh(AComponent));
    end
    else if AComponent is TLaObjectEh then
    begin
      LaObject := TLaObjectEh(AComponent);
      FCurrentMouseEnterList.Remove(LaObject);
    end;
  end;
end;

procedure TLaHostVirtualPanelEh.DoAddObject(const AObject: TFmxObject);
begin
  inherited DoAddObject(AObject);
  if AObject is TControl then
  begin
    TControl(AObject).SetNewScene(Self);
  end
end;

procedure TLaHostVirtualPanelEh.SetCacheUpdateRect(const Value: Boolean);
begin
  if FCacheUpdateRect <> Value then
  begin
    FCacheUpdateRect := Value;
    FCachedUpdateRect := TRectF.Empty;
  end;
end;

function TLaHostVirtualPanelEh.CheckLayoutInterrupting: Boolean;
begin
  if IsLayoutInterruptible
    then Result := Grid.CheckAndSetLayoutInterrupting
    else Result := False;
end;

function TLaHostVirtualPanelEh.IsLayoutInterruptible: Boolean;
begin
  if Self = Grid.HFixedVDataPanel
    then Result := False
    else Result := True;
end;

{ IScene }

{$IFDEF EH_LIB_28} 
procedure TLaHostVirtualPanelEh.AddUpdateRect(const R: TRectF);
{$ELSE}
procedure TLaHostVirtualPanelEh.AddUpdateRect(R: TRectF);
{$ENDIF}
begin
  if (CacheUpdateRect = True) then
  begin
    if FCachedUpdateRect = TRectF.Empty then
      FCachedUpdateRect := R
    else
      UnionRect(FCachedUpdateRect, R, FCachedUpdateRect);
  end else
  begin
    FScene.AddUpdateRect(R);
  end;
end;

procedure TLaHostVirtualPanelEh.ChangeScrollingState(const AControl: TControl; const AActive: Boolean);
begin
  FScene.ChangeScrollingState(AControl, AActive);
end;

{$IFDEF EH_LIB_28} 
function TLaHostVirtualPanelEh.LocalToScreen(const AScenePoint: TPointF): TPointF;
{$ELSE}
function TLaHostVirtualPanelEh.LocalToScreen(AScenePoint: TPointF): TPointF;
{$ENDIF}
begin
  Result := FScene.LocalToScreen(AScenePoint);
end;

{$IFDEF EH_LIB_28} 
function TLaHostVirtualPanelEh.ScreenToLocal(const AScreenPoint: TPointF): TPointF;
{$ELSE}
function TLaHostVirtualPanelEh.ScreenToLocal(AScreenPoint: TPointF): TPointF;
{$ENDIF}
begin
  Result := FScene.ScreenToLocal(AScreenPoint);
end;

function TLaHostVirtualPanelEh.GetObject: TFmxObject;
begin
  Result := Self;
end;

procedure TLaHostVirtualPanelEh.DisableUpdating;
begin
  FScene.DisableUpdating;
end;

procedure TLaHostVirtualPanelEh.EnableUpdating;
begin
  FScene.EnableUpdating;
end;

function TLaHostVirtualPanelEh.GetStyleBook: TStyleBook;
var
  StyleBookOwnerItfs: IStyleBookOwner;
begin
  if Supports(FScene.GetObject, IStyleBookOwner, StyleBookOwnerItfs) then
    Result := StyleBookOwnerItfs.GetStyleBook()
  else
    Result := nil;
end;

procedure TLaHostVirtualPanelEh.SetStyleBook(const Value: TStyleBook);
var
  StyleBookOwnerItfs: IStyleBookOwner;
begin
  if Supports(FScene.GetObject, IStyleBookOwner, StyleBookOwnerItfs) then
    StyleBookOwnerItfs.SetStyleBook(Value);
end;

function TLaHostVirtualPanelEh.GetCanvas: TCanvas;
begin
  if FScene <> nil
    then Result := FScene.GetCanvas
    else Result := nil;
end;

function TLaHostVirtualPanelEh.GetSceneScale: Single;
begin
  Result := FScene.GetSceneScale;
end;

function TLaHostVirtualPanelEh.GetUpdateRect(const Index: Integer): TRectF;
begin
  Result := FScene.GetUpdateRect(Index);
end;

function TLaHostVirtualPanelEh.GetUpdateRectsCount: Integer;
begin
  Result := FScene.GetUpdateRectsCount;
end;

{ TVirtualPanelRollEh }

procedure TVirtualPanelRollEh.Assign(Source: TPersistent);
begin
  inherited Assign(Source);

end;

constructor TVirtualPanelRollEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

end;

destructor TVirtualPanelRollEh.Destroy;
begin

  inherited Destroy;
end;

function TVirtualPanelRollEh.DoPerformLayoutClientArea(const ClientRect: TRectF; ACanvas: TCanvas): TSizeF;
begin

end;

function TVirtualPanelRollEh.DoQueryLayoutClientArea(const QuerySize: TSizeF; ACanvas: TCanvas): TSizeF;
begin

end;

{ TVPBaseCellModelEh }

constructor TVPBaseCellManagerEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

function TVPBaseCellManagerEh.CreateCellHolder(): TVPBaseCellHolderEh;
begin
  Result := TVPTextCellEh.Create(nil, Self)
end;

function TVPBaseCellManagerEh.InitAndCaclRenderCellHolder(AGrid: TControl; ACellRenderSize: TSizeF;
  ACellHolder: TVPBaseCellHolderEh;
  AGridColIndex, AGridRowIndex: Integer;
  ALocalColIndex, ALocalRowIndex: Integer): TSizeF;
begin
  ACellHolder.FGrid := AGrid;
  ACellHolder.FColIndex := AGridColIndex;
  ACellHolder.FRowIndex := AGridRowIndex;
  ACellHolder.FAreaColIndex := ALocalColIndex;
  ACellHolder.FAreaRowIndex := ALocalRowIndex;
  InitCellHolderPositionProps(ACellHolder);

  InternalInitCellHolder(ACellHolder);

  ACellHolder.SetLayoutChangedForAll();
  Result := ACellHolder.QueryLayout(ACellRenderSize, TCanvasManager.MeasureCanvas);
end;

procedure TVPBaseCellManagerEh.InitCellHolder(ACellHolder: TVPBaseCellHolderEh);
begin
end;

procedure TVPBaseCellManagerEh.InitCellHolderPositionProps(ACellHolder: TVPBaseCellHolderEh);
begin
  ACellHolder.InitPositionProps();
end;

procedure TVPBaseCellManagerEh.InternalInitCellHolder(ACellHolder: TVPBaseCellHolderEh);
begin
  ACellHolder.InitControls();
  InitCellHolder(ACellHolder);
  TCustomGridEhCrack(ACellHolder.Grid).InitCellForRender(Self, ACellHolder);
end;

{ TVPBaseCellHolderEh }

constructor TVPBaseCellHolderEh.Create(AOwner: TComponent; ACellManager: TVPBaseCellManagerEh);
begin
  inherited Create(AOwner);

  FCellManager := ACellManager;
  HitTest := False;
end;

destructor TVPBaseCellHolderEh.Destroy;
begin
  inherited Destroy;
end;

class function TVPBaseCellHolderEh.GetParentCell(ChildObject: TLaObjectEh): TVPBaseCellHolderEh;
var
  CurParent: TLaObjectEh;
begin
  Result := nil;
  CurParent := ChildObject;

  while CurParent <> nil do
  begin
    if CurParent is TVPBaseCellHolderEh then
    begin
      Result := TVPBaseCellHolderEh(CurParent);
      Exit;
    end;

    CurParent := TLaObjectEh(CurParent.Parent);
  end;
end;

procedure TVPBaseCellHolderEh.InitControls;
begin
  if FControlsCreated = False then
  begin
    CreateControls(Self);
    FControlsCreated := True;
  end;
end;

function TVPBaseCellHolderEh.DoQueryLayout(const QuerySize: TSizeF; ACanvas: TCanvas): TSizeF;
begin
  if FFastMockLayout
    then Result := QuerySize
    else Result := inherited DoQueryLayout(QuerySize, ACanvas);
end;

function TVPBaseCellHolderEh.DoPerformLayout(const PerfSize: TSizeF; ACanvas: TCanvas): TSizeF;
begin
  if FFastMockLayout
    then Result := PerfSize
    else Result := inherited DoPerformLayout(PerfSize, ACanvas);
end;

procedure TVPBaseCellHolderEh.CreateControls;
begin
end;

procedure TVPBaseCellHolderEh.InitPositionProps;
begin
end;

{ TVPTextCellEh }

constructor TVPTextCellEh.Create(AOwner: TComponent; ACellManager: TVPBaseCellManagerEh);
begin
  inherited Create(AOwner, ACellManager);
end;

destructor TVPTextCellEh.Destroy;
begin
  inherited Destroy;
end;

procedure TVPTextCellEh.CreateControls(AParent: TLaObjectEh);
begin
  FText := TLaTextBlockEh.CreateWith(Self, RefSelf);
end;

function TVPTextCellEh.GetText: String;
begin
  Result := FText.Text;
end;

procedure TVPTextCellEh.SetText(const Value: String);
begin
  FText.Text := Value;
end;

end.
