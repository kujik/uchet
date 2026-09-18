unit EhLibFmx.DataGrid.DataGroupingPanels;

interface

{$SCOPEDENUMS ON}

{$REGION 'uses'}
uses
  System.UITypes, SysUtils, Classes,
  Variants, Types,
  System.Generics.Collections,
  FMX.Types,
  FMX.StdCtrls,
  FMX.Controls,
  FMX.Menus,
  FMX.Edit,
  FMX.Platform,
  FMX.Graphics,
  FMX.Objects,
  FMX.Forms,

  EhLibUtils,
  EhLibFmx.LaObjects,
  EhLibFmx.LaControls,
  EhLibFmx.LaPanels,
  EhLibFmx.LaGridPanels,
  EhLibFmx.LaHostVirtualPanels,

  EhLibFmx.Platform,
  EhLibFmx.ToolControls,
  EhLibFmx.ImageReses,
  EhLibFmx.Types,
  EhLibFmx.DataGrid.Columns,
  EhLibFmx.DataGrid.DataGrouping
  ;
{$ENDREGION 'uses'}

type
  TDataGridGroupingPanelEh = class;
  TDataGridGroupHeaderPanelEh = class;
  TDataGridGroupDescriptionControlManagerEh = class;
  TDataGridGroupDescriptionControlHolderEh = class;
  TDataGridGroupDescriptionControlEh = class;

{ TDataGridGroupingPanelEh }

  TDataGridGroupingPanelEh = class(TLaHostWinControl)
  private
    FGroupHeaderPanel: TDataGridGroupHeaderPanelEh;
    FDataGrouping: TDataGridDataGroupingEh;
    FMouseInControl: Boolean;
    FDescriptionControlBounds: TList<TRectF>;
    function GetGrid: TControl;

  protected

    function CalcSearchInfoBoxWidth: Integer; virtual;
    function IsDrawButtonBorder: Boolean; virtual;
    function IsDrawRightBorder: Boolean; virtual;
    function GetBorderColor: TAlphaColor; virtual;

    procedure Paint; override;
    procedure Resize; override;

    procedure ProcessPreviewMouseLeave(Params: TControlParamsEh); override;
    procedure ProcessPreviewMouseEnter(Params: TControlParamsEh); override;
    procedure DoMouseEnter; override;
    procedure DoMouseLeave; override;
    procedure LayoutUpdated(); override;

    procedure SetMouseInControl(AMouseInControl: Boolean);
    procedure MouseInControlChanged(); virtual;

  public

    constructor Create(AOwner: TComponent; ADataGrouping: TDataGridDataGroupingEh); reintroduce;
    destructor Destroy; override;

    function CalcAutoHeight: Integer;
    function CalcAutoWidthForHeight(ANewHeight: Integer): Integer;
    function GetDescriptionControlBoundIndex(ScreenMousePos: TPointF): Integer;

    procedure RealignControls; virtual;
    procedure GroupDescriptionsChanged(); virtual;
    procedure UpdateControlsState();
    procedure GetDescriptionControlBoundLineBounds(ADescriptionIndex: Integer; out AScreenLinePos: TPointF; out ALineHeight: Single);

    procedure InitCellHolderPositionProps(ACellManager: TDataGridGroupDescriptionControlManagerEh; ACellHolder: TVPBaseCellHolderEh);

    property DataGrouping: TDataGridDataGroupingEh read FDataGrouping;
    property MouseInControl: Boolean read FMouseInControl;
    property Grid: TControl read GetGrid;
  end;

{ TDataGridGroupHeaderPanelEh }

  TDataGridGroupHeaderPanelEh = class(TLaStackPanelEh)
  private
  protected
    FGroupingPanel: TDataGridGroupingPanelEh;
    procedure ProcessMouseMove(Params: TControlMouseParamsEh); override;
  public
    constructor Create(AOwner: TComponent); override;

    procedure DrawClientForeground(const AClientRect: TRectF; ACanvas: TCanvas); override;
  published
  end;

{ TDataGridGroupDescriptionControlManagerEh }

  TDataGridGroupDescriptionControlManagerEh = class(TVPBaseCellManagerEh)
  private
  protected
    function CreateGridCell(ACellHolder: TDataGridGroupDescriptionControlHolderEh): TDataGridGroupDescriptionControlEh; virtual;
    function CreateGroupDescriptionControlArea(): TDataGridGroupDescriptionControlHolderEh; virtual;

//    procedure InitCellHolder(ADescrControlArea: TDataGridGroupDescriptionControlAreaEh); virtual;

    procedure CellClick(Sender: TObject; Params: TControlMouseButtonParamsEh);

  public
    constructor Create(AOwner: TComponent); override;

    procedure InitCellHolder(ACellHolder: TVPBaseCellHolderEh); override;
  end;

{ TDataGridGroupDescriptionControlHolderEh }

  TDataGridGroupDescriptionControlHolderEh = class(TVPBaseCellHolderEh)
  private
    FCellClient: TDataGridGroupDescriptionControlEh;

    function GetCellManager: TDataGridGroupDescriptionControlManagerEh;
  protected
    FGrid: TControl;
    FGroupDescription: TDataGridGroupDescriptionEh;
    FMouseDownPos: TPoint;

    procedure CreateControls(AParent: TLaObjectEh); override;

    procedure ProcessMouseDown(Params: TControlMouseButtonParamsEh); override;
    procedure ProcessMouseMove(Params: TControlMouseParamsEh); override;
    procedure ProcessMouseClick(Params: TControlMouseButtonParamsEh); override;
  public
    constructor Create(AOwner: TComponent; ACellManager: TVPBaseCellManagerEh); override;
    destructor Destroy; override;

    property CellManager: TDataGridGroupDescriptionControlManagerEh read GetCellManager;
    property CellClient: TDataGridGroupDescriptionControlEh read FCellClient;
    property GroupDescription: TDataGridGroupDescriptionEh read FGroupDescription;
  published
    property Locked stored False;
  end;

{ TDataGridGroupDescriptionControlEh }

  TDataGridGroupDescriptionControlEh = class(TLaLayoutPanelEh)
  private
    FCellHolder: TDataGridGroupDescriptionControlHolderEh;
    FTextBlock: TLaTextBlockEh;
    FSortMarkerPanel: TLaLayoutPanelEh;
    FStyledBackgroundHolder: TLaLayoutPanelEh;
    FButtonImage: TImage;
    FFilterButton: TLaButtonEh;
    FBackgroundStyle: TControl;
    function GetGrid: TControl;
    function GetGroupDescription: TDataGridGroupDescriptionEh;
    function GetIsShowButtonFace: Boolean;
    function GetIsShowFilterButton: Boolean;
    procedure SetIsShowButtonFace(const Value: Boolean);
    procedure SetIsShowFilterButton(const Value: Boolean);
    procedure SetBackgroundStyle(const Value: TControl);
  protected
    procedure CreateControls(); virtual;
    procedure FilterButtonMouseDown(Sender: TObject; Params: TControlMouseButtonParamsEh);

    procedure InTitleFilterListboxCloseUp();
    procedure InTitleFilterListboxDropDown(Column: TDataGridBaseColumnEh);

  public
    constructor Create(ACellHolder: TDataGridGroupDescriptionControlHolderEh);
    destructor Destroy; override;

    property Grid: TControl read GetGrid;
    property TextBlock: TLaTextBlockEh read FTextBlock;
    property GroupDescription: TDataGridGroupDescriptionEh read GetGroupDescription;
    property BackgroundStyle: TControl read FBackgroundStyle write SetBackgroundStyle;

    property IsShowButtonFace: Boolean read GetIsShowButtonFace write SetIsShowButtonFace;
    property IsShowFilterButton: Boolean read GetIsShowFilterButton write SetIsShowFilterButton;

  published
  end;

implementation

uses Math,
     EhLibFmx.CustomDataGrids,
     EhLibLangConsts;

type
  TControlCrack = class(TControl);
  TCustomDataGridEhCrack = class(TCustomDataGridEh);
  TColumnTitleEhCrack = class(TColumnTitleEh);
  TLaLayoutPanelEhCrack = class(TLaLayoutPanelEh);
  TVPBaseCellHolderEhCrack = class(TVPBaseCellHolderEh);

procedure InitRes;
begin
end;

procedure FinRes;
begin
end;

{$REGION 'TDataGridGroupingPanelEh'}

{ TDataGridGroupingPanelEh }

constructor TDataGridGroupingPanelEh.Create(AOwner: TComponent; ADataGrouping: TDataGridDataGroupingEh);
var
  VGrid: TCustomDataGridEhCrack;
begin
  inherited Create(AOwner);

  FDataGrouping := ADataGrouping;
  VGrid := TCustomDataGridEhCrack(Grid);

  FGroupHeaderPanel := TDataGridGroupHeaderPanelEh.Create(Self);
  FGroupHeaderPanel.Align := TAlignLayout.Client;
  FGroupHeaderPanel.FGroupingPanel := Self;
  FGroupHeaderPanel.Fill := VGrid.StylePainter.BackgroundMiddleFill;
  LaObject := FGroupHeaderPanel;
  FDescriptionControlBounds := TList<TRectF>.Create;
end;

destructor TDataGridGroupingPanelEh.Destroy;
begin
  FreeAndNil(FDescriptionControlBounds);
  inherited Destroy;
end;

function TDataGridGroupingPanelEh.IsDrawButtonBorder: Boolean;
begin
  Result := True;
end;

function TDataGridGroupingPanelEh.IsDrawRightBorder: Boolean;
begin
  Result := False;
end;

function TDataGridGroupingPanelEh.CalcAutoHeight: Integer;
begin
  Result := 38;
end;

function TDataGridGroupingPanelEh.CalcAutoWidthForHeight(ANewHeight: Integer): Integer;
begin
  Result := 120 + ANewHeight + ANewHeight + ANewHeight + ANewHeight;
end;

procedure TDataGridGroupingPanelEh.Paint;
var
  I: Integer;
  Bounds1, Bounds2: TRectF;
  Point1, Point2: TPointF;
begin
  Canvas.Stroke.Color := GetBorderColor();
  Canvas.Stroke.Kind := TBrushKind.Solid;
  if IsDrawButtonBorder then
    Canvas.DrawLine(TPointF.Create(0.5, Height - 0.5), TPointF.Create(Width - 0.5, Height - 0.5), 1);
  if IsDrawRightBorder then
    Canvas.DrawLine(TPointF.Create(Width - 0.5, Height - 0.5), TPointF.Create(Width - 0.5, 0.5), 1);

  if FGroupHeaderPanel.ChildrenCount > 0 then
  begin
    for I := 0 to FGroupHeaderPanel.ChildrenCount - 1 do
    begin
      if I = 0 then
      begin
        Bounds1 := TControl(FGroupHeaderPanel.Children[I]).BoundsRect;
      end else
      begin
        Bounds2 := TControl(FGroupHeaderPanel.Children[I]).BoundsRect;

        Point1.X := Bounds1.Right + 0.5;
        Point1.Y := Bounds1.Top + Round(Bounds1.Height / 4) + 0.5;
        Point2.X := Bounds1.Right + Round((Bounds2.Left - Bounds1.Right) / 2) + 0.5;
        Point2.Y := Point1.Y;
        Canvas.DrawLine(Point1, Point2, 1);

        Point1.X := Point2.X;
        Point1.Y := Point2.Y;
        Point2.X := Point2.X;
        Point2.Y := Point1.Y + Round(Bounds1.Height / 2) - 1;
        Canvas.DrawLine(Point1, Point2, 1);

        Point1.X := Point2.X;
        Point1.Y := Point2.Y;
        Point2.X := Bounds2.Left;
        Point2.Y := Point1.Y;
        Canvas.DrawLine(Point1, Point2, 1);

        Bounds1 := Bounds2;
      end;
    end;
  end;

end;

procedure TDataGridGroupingPanelEh.ProcessPreviewMouseEnter(Params: TControlParamsEh);
begin
  inherited ProcessPreviewMouseEnter(Params);
  SetMouseInControl(True);
end;

procedure TDataGridGroupingPanelEh.ProcessPreviewMouseLeave(Params: TControlParamsEh);
var
  LocalPos: TPointF;
begin
  inherited ProcessPreviewMouseLeave(Params);
  LocalPos := ScreenToLocal(Screen.MousePos);
  if TRectF.Create(0, 0, Width, Height).Contains(LocalPos) = False then
    DoMouseLeave;
end;

procedure TDataGridGroupingPanelEh.DoMouseEnter;
begin
  inherited DoMouseEnter;
  SetMouseInControl(True);
end;

procedure TDataGridGroupingPanelEh.DoMouseLeave;
var
  LocalPos: TPointF;
begin
  inherited DoMouseLeave;
  LocalPos := ScreenToLocal(Screen.MousePos);
  if TRectF.Create(0, 0, Width, Height).Contains(LocalPos) = False then
    SetMouseInControl(False);
end;

procedure TDataGridGroupingPanelEh.SetMouseInControl(AMouseInControl: Boolean);
begin
  if AMouseInControl <> FMouseInControl then
  begin
    FMouseInControl := AMouseInControl;
    MouseInControlChanged();
  end;
end;

procedure TDataGridGroupingPanelEh.MouseInControlChanged();
begin
  UpdateControlsState();
end;

function TDataGridGroupingPanelEh.GetBorderColor: TAlphaColor;
var
  VGrid: TCustomDataGridEhCrack;
begin
  VGrid := TCustomDataGridEhCrack(Grid);
  Result := VGrid.StylePainter.CellBorderLineDarkColor;
end;

procedure TDataGridGroupingPanelEh.GroupDescriptionsChanged;
begin
  RealignControls;
end;

procedure TDataGridGroupingPanelEh.RealignControls;
var
  k: Integer;
  GroupDescription: TDataGridGroupDescriptionEh;
  DescrControlArea: TDataGridGroupDescriptionControlHolderEh;
  DescrControlManager: TDataGridGroupDescriptionControlManagerEh;
begin
  FGroupHeaderPanel.DeleteChildren();

  for k := 0 to DataGrouping.ActiveGroupDescriptions.Count - 1 do
  begin
    GroupDescription := DataGrouping.ActiveGroupDescriptions[k];
    DescrControlManager := TDataGridGroupDescriptionControlManagerEh(DataGrouping.GroupDescriptionControlManager);
    DescrControlArea := DescrControlManager.CreateGroupDescriptionControlArea();
    DescrControlArea.FGrid := DataGrouping.Grid;
    DescrControlArea.FGroupDescription := GroupDescription;

    FGroupHeaderPanel.AddObject(DescrControlArea);

    InitCellHolderPositionProps(DescrControlManager, DescrControlArea);
    DescrControlManager.InternalInitCellHolder(DescrControlArea);
  end;

  UpdateLayout();
end;

procedure TDataGridGroupingPanelEh.UpdateControlsState();
var
  k: Integer;
  DescrControlArea: TDataGridGroupDescriptionControlHolderEh;
begin
  if FGroupHeaderPanel.ChildrenCount = 0 then Exit;

  for k := 0 to FGroupHeaderPanel.ChildrenCount - 1 do
  begin
    if (FGroupHeaderPanel.Children[k] is TDataGridGroupDescriptionControlHolderEh) then
    begin
      DescrControlArea := TDataGridGroupDescriptionControlHolderEh(FGroupHeaderPanel.Children[k]);
      //DescrControlArea.CellManager.InternalInitCellHolderPositionProps(DescrControlArea, DataGrouping.Grid, -1, -1, -1, -1);
      InitCellHolderPositionProps(DescrControlArea.CellManager, DescrControlArea);
      DescrControlArea.CellManager.InternalInitCellHolder(DescrControlArea);
    end;
  end;
end;

procedure TDataGridGroupingPanelEh.InitCellHolderPositionProps(ACellManager: TDataGridGroupDescriptionControlManagerEh; ACellHolder: TVPBaseCellHolderEh);
begin
  TVPBaseCellHolderEhCrack(ACellHolder).FGrid := DataGrouping.Grid;
  TVPBaseCellHolderEhCrack(ACellHolder).FColIndex := -1;
  TVPBaseCellHolderEhCrack(ACellHolder).FRowIndex := -1;
  TVPBaseCellHolderEhCrack(ACellHolder).FAreaColIndex := -1;
  TVPBaseCellHolderEhCrack(ACellHolder).FAreaRowIndex := -1;
  ACellManager.InitCellHolderPositionProps(ACellHolder);
end;

procedure TDataGridGroupingPanelEh.LayoutUpdated;
var
  k: Integer;
  DescrControlArea: TDataGridGroupDescriptionControlHolderEh;
  Bounds: TRectF;
begin
  inherited LayoutUpdated;

  FDescriptionControlBounds.Clear;

  if FGroupHeaderPanel.ChildrenCount > 0 then
  begin
    for k := 0 to FGroupHeaderPanel.ChildrenCount - 1 do
    begin
      if (FGroupHeaderPanel.Children[k] is TDataGridGroupDescriptionControlHolderEh) then
      begin
        DescrControlArea := TDataGridGroupDescriptionControlHolderEh(FGroupHeaderPanel.Children[k]);
        Bounds := DescrControlArea.BoundsRect;
        Bounds.Left := Bounds.Left - 4;
        Bounds.Right := Bounds.Right + 5;
        FDescriptionControlBounds.Add(Bounds);
      end;
    end;
  end else
  begin
    FDescriptionControlBounds.Add(TRectF.Create(4, 6, 5, FGroupHeaderPanel.ActualHeight - 10));
  end;
end;

function TDataGridGroupingPanelEh.GetDescriptionControlBoundIndex(ScreenMousePos: TPointF): Integer;
var
  GroupHeaderPanelMousePos: TPointF;
  I: Integer;
  Bounds: TRectF;
  IndexBorder: Single;
begin
  if FGroupHeaderPanel.ChildrenCount = 0 then Exit(0);

  GroupHeaderPanelMousePos := FGroupHeaderPanel.ScreenToLocal(ScreenMousePos);
  Result := FDescriptionControlBounds.Count;
  for I := 0 to FDescriptionControlBounds.Count - 1 do
  begin
    Bounds := FDescriptionControlBounds[I];
    IndexBorder := (Bounds.Left + Bounds.Right) / 2;
    if (GroupHeaderPanelMousePos.X < IndexBorder) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

procedure TDataGridGroupingPanelEh.GetDescriptionControlBoundLineBounds(
  ADescriptionIndex: Integer; out AScreenLinePos: TPointF; out ALineHeight: Single);
var
  Bounds: TRectF;
begin
  if ADescriptionIndex < FDescriptionControlBounds.Count then
  begin
    Bounds := FDescriptionControlBounds[ADescriptionIndex];
    AScreenLinePos.X := Bounds.Left;
    AScreenLinePos.Y := Bounds.Top + 2;
    AScreenLinePos := FGroupHeaderPanel.LocalToScreen(AScreenLinePos);
    ALineHeight := Bounds.Height - 4;
  end else
  begin
    Bounds := FDescriptionControlBounds[FDescriptionControlBounds.Count - 1];
    AScreenLinePos.X := Bounds.Right;
    AScreenLinePos.Y := Bounds.Top + 2;
    AScreenLinePos := FGroupHeaderPanel.LocalToScreen(AScreenLinePos);
    ALineHeight := Bounds.Height - 4;
  end;
end;

function TDataGridGroupingPanelEh.GetGrid: TControl;
begin
  Result := DataGrouping.Grid;
end;

procedure TDataGridGroupingPanelEh.Resize;
begin
  inherited Resize;
  UpdateLayout();
end;

function TDataGridGroupingPanelEh.CalcSearchInfoBoxWidth: Integer;
begin
  Result := 0;
end;

{$ENDREGION  'TDataGridGroupingPanelEh'}

{$REGION 'TDataGridGroupHeaderPanelEh'}

{ TDataGridGroupHeaderPanelEh }

constructor TDataGridGroupHeaderPanelEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Orientation := TLaOrientationEh.Horizontal;
end;

procedure TDataGridGroupHeaderPanelEh.DrawClientForeground(const AClientRect: TRectF;
  ACanvas: TCanvas);
begin
  if ChildrenCount = 0 then
  begin
    ACanvas.Fill.Color := TCustomDataGridEhCrack(FGroupingPanel.Grid).StylePainter.ForegroundColor;
    ACanvas.FillText(TRectF.Create(5, 0, ActualWidth, ActualHeight),
                    'Drag a column header here to group by that column',
                    False, 1, [], TTextAlign.Leading, TTextAlign.Center);
  end;
end;

procedure TDataGridGroupHeaderPanelEh.ProcessMouseMove(Params: TControlMouseParamsEh);
begin
  inherited ProcessMouseMove(Params);
end;

{$ENDREGION 'TDataGridGroupHeaderPanelEh'}

{$REGION 'TDataGridGroupDescriptionControlManagerEh'}

{ TDataGridGroupDescriptionControlManagerEh}

procedure TDataGridGroupDescriptionControlManagerEh.CellClick(Sender: TObject; Params: TControlMouseButtonParamsEh);
var
  Control: TDataGridGroupDescriptionControlEh;
begin
  Control := Sender as TDataGridGroupDescriptionControlEh;
  if Control.GroupDescription.SortOrder = TSortOrderEh.soAscEh
    then Control.GroupDescription.SortOrder := TSortOrderEh.soDescEh
    else Control.GroupDescription.SortOrder := TSortOrderEh.soAscEh;
end;

constructor TDataGridGroupDescriptionControlManagerEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

function TDataGridGroupDescriptionControlManagerEh.CreateGridCell(ACellHolder: TDataGridGroupDescriptionControlHolderEh): TDataGridGroupDescriptionControlEh;
begin
  Result := TDataGridGroupDescriptionControlEh.Create(ACellHolder);
  Result.OnMouseClick := CellClick
end;

function TDataGridGroupDescriptionControlManagerEh.CreateGroupDescriptionControlArea: TDataGridGroupDescriptionControlHolderEh;
begin
  Result := TDataGridGroupDescriptionControlHolderEh.Create(nil, Self);
end;

procedure TDataGridGroupDescriptionControlManagerEh.InitCellHolder(ACellHolder: TVPBaseCellHolderEh);
var
  VGrid: TCustomDataGridEhCrack;
  VDescrControlArea: TDataGridGroupDescriptionControlHolderEh;
  VDescrControl: TDataGridGroupDescriptionControlEh;
  GroupDescription: TDataGridGroupDescriptionEh;
begin
  VGrid := TCustomDataGridEhCrack(ACellHolder.Grid);
  VDescrControlArea := ACellHolder as TDataGridGroupDescriptionControlHolderEh;
  GroupDescription := VDescrControlArea.GroupDescription;

  ACellHolder.Height := 23;
  ACellHolder.VertAlignment := TLaVertAlignmentEh.Top;
  ACellHolder.HorzAlignment := TLaHorzAlignmentEh.Left;
  ACellHolder.Margins.Left := 9;
//  ACellHolder.Margins.Top := 5 + GroupDescription.Index * 8;
  ACellHolder.Margins.Top := 5;
  ACellHolder.Fill := VGrid.Title.Fill;

  ACellHolder.Borders.Left.Thickness := 1;
  ACellHolder.Borders.Left.Color := VGrid.GridLineOptions.DarkColor;

  ACellHolder.Borders.Top.Thickness := 1;
  ACellHolder.Borders.Top.Color := VGrid.GridLineOptions.DarkColor;

  ACellHolder.Borders.Right.Thickness := 1;
  ACellHolder.Borders.Right.Color := VGrid.GridLineOptions.DarkColor;

  ACellHolder.Borders.Bottom.Thickness := 1;
  ACellHolder.Borders.Bottom.Color := VGrid.GridLineOptions.DarkColor;

  VDescrControl := VDescrControlArea.CellClient as TDataGridGroupDescriptionControlEh;
  VDescrControl.TextBlock.Text := GroupDescription.Column.Title.Text;
  VDescrControl.TextBlock.VertAlignment := TLaVertAlignmentEh.Center;
  VDescrControl.TextBlock.FontColor := GroupDescription.Column.Title.FontColor;

//  VDescrControl.FStyledBackground.Fill := VGrid.StylePainter.TitleFill;
  VDescrControl.BackgroundStyle := VGrid.StylePainter.TopFixedCellBackground;

  VDescrControl.IsShowFilterButton := GroupDescription.Column.Title.FilterItem.IsShowFilterButton;
  VDescrControl.IsShowButtonFace := VGrid.GroupingPanel.MouseInControl or GroupDescription.Column.Title.FilterFormIsVisible;

  if GroupDescription.SortOrder = TSortOrderEh.soAscEh then
    TLaLayoutPanelEhCrack(VDescrControl.FSortMarkerPanel).RotationAngle := 0
  else
    TLaLayoutPanelEhCrack(VDescrControl.FSortMarkerPanel).RotationAngle := 180;

end;

{$ENDREGION 'TDataGridGroupDescriptionControlManagerEh'}

{$REGION 'TDataGridGroupDescriptionControlHolderEh'}

{ TDataGridGroupDescriptionControlHolderEh }

constructor TDataGridGroupDescriptionControlHolderEh.Create(AOwner: TComponent; ACellManager: TVPBaseCellManagerEh);
begin
  inherited Create(AOwner, ACellManager);
  Locked := True;
  HitTest := True;
  AutoCapture := True;
end;

destructor TDataGridGroupDescriptionControlHolderEh.Destroy;
begin
  inherited Destroy;
end;

procedure TDataGridGroupDescriptionControlHolderEh.CreateControls(AParent: TLaObjectEh);
begin
  FCellClient := CellManager.CreateGridCell(Self);
  FCellClient.Parent := AParent;
  FCellClient.CreateControls;
end;

function TDataGridGroupDescriptionControlHolderEh.GetCellManager: TDataGridGroupDescriptionControlManagerEh;
begin
  Result := TDataGridGroupDescriptionControlManagerEh(inherited CellManager);
end;

procedure TDataGridGroupDescriptionControlHolderEh.ProcessMouseClick(Params: TControlMouseButtonParamsEh);
begin
  inherited ProcessMouseClick(Params);

  if GroupDescription.SortOrder = TSortOrderEh.soAscEh
    then GroupDescription.SortOrder := TSortOrderEh.soDescEh
    else GroupDescription.SortOrder := TSortOrderEh.soAscEh;
  Params.Handled := True;
end;

procedure TDataGridGroupDescriptionControlHolderEh.ProcessMouseDown(Params: TControlMouseButtonParamsEh);
begin
  inherited ProcessMouseDown(Params);
  FMouseDownPos := PointF(Params.X, Params.Y).Round;
  if AutoCapture and (IsMouseCaptured = False) and (Root.Captured = nil) then
    Capture;
end;

procedure TDataGridGroupDescriptionControlHolderEh.ProcessMouseMove(Params: TControlMouseParamsEh);
var
  VGrid: TCustomDataGridEhCrack;
  GridMouseDownPos: TPoint;
  GridMouseMovePos: TPoint;
  ScreenMousePos: TPointF;
//  MoveToGroupDescriptionIndex: Integer;
begin
  VGrid := TCustomDataGridEhCrack(FGrid);
  inherited ProcessMouseMove(Params);

  if (VGrid.GridMouseState = VGrid.GridMouseStateManage.NormalState) and
     (VGrid.FDataGridMouseState = TDataGridMouseStateEh.Normal) and
     (Self.IsMouseCaptured = True) and
     (ssLeft in Params.Shift) then
  begin
    GridMouseDownPos := FGrid.ScreenToLocal(LocalToScreen(FMouseDownPos)).Round;
    GridMouseMovePos := Params.GetPositionRelativeTo(VGrid).Round;
    if GridMouseDownPos <> GridMouseMovePos then
    begin
      ScreenMousePos := LocalToScreen(GridMouseMovePos);

      VGrid.Capture;
      VGrid.StartGroupDescriptionControlMoving(GroupDescription, ScreenMousePos);
    end;
  end;

end;

{$ENDREGION 'TDataGridGroupDescriptionControlHolderEh'}

{$REGION 'TDataGridGroupDescriptionControlEh'}

{ TDataGridGroupDescriptionControlEh}

constructor TDataGridGroupDescriptionControlEh.Create(ACellHolder: TDataGridGroupDescriptionControlHolderEh);
begin
  inherited Create(ACellHolder);
  FCellHolder := ACellHolder;
  AutoCapture := True;
end;

destructor TDataGridGroupDescriptionControlEh.Destroy;
begin

  inherited Destroy;
end;

procedure TDataGridGroupDescriptionControlEh.FilterButtonMouseDown(
  Sender: TObject;
  Params: TControlMouseButtonParamsEh);
var
  Column: TDataGridBaseColumnEh;
  ColumnTitle: TColumnTitleEhCrack;
begin
  if (Params.Button <> TMouseButton.mbLeft) then
    Exit;

  Column := GroupDescription.Column;
  ColumnTitle := TColumnTitleEhCrack(Column.Title);

  if ColumnTitle.FilterFormIsVisible
    then InTitleFilterListboxCloseUp()
    else InTitleFilterListboxDropDown(Column);
end;

procedure TDataGridGroupDescriptionControlEh.InTitleFilterListboxCloseUp;
begin

end;

procedure TDataGridGroupDescriptionControlEh.InTitleFilterListboxDropDown(
  Column: TDataGridBaseColumnEh);
var
  ColumnTitle: TColumnTitleEhCrack;
  ACellRectF: TRectF;
  VCellRect: TRect;
  VCellScreenRect: TRect;
  AGrid: TCustomDataGridEhCrack;
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

procedure TDataGridGroupDescriptionControlEh.CreateControls;
var
  NewSortMarker: TControl;
  AGrid: TCustomDataGridEhCrack;
begin
  AGrid := TCustomDataGridEhCrack(Grid);

  with TLaLayoutPanelEh.CreateWith(Self, RefSelf) do
  begin
    Name := 'StyledBackgroundHolder';
    FStyledBackgroundHolder := RefSelf as TLaLayoutPanelEh;
  end;

  with TLaGridPanelEh.CreateWith(Self, RefSelf) do
  begin

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

    
    with TLaTextBlockEh.CreateWith(RefSelf, RefSelf) do
    begin
      ControlCollection.AddControl(RefSelf, 0, -1);

      FTextBlock := RefSelf as TLaTextBlockEh;
      Name := 'DefaultCellContent';
      Text := 'DefaultCellContent';
      Margins.Left := 2;
      Margins.Right := 2;
    end;

    
    with TLaLayoutPanelEh.CreateWith(RefSelf, RefSelf) do
    begin
      ControlCollection.AddControl(RefSelf, 1, -1);
      Margins.Rect := TRectF.Create(2, 0, 2, 0);
      VertAlignment := TLaVertAlignmentEh.Center;
      Width := 10;
      Height := 5;

      if AGrid.StylePainter.SortMarker <> nil then
      begin
        NewSortMarker := AGrid.StylePainter.SortMarker.Clone(RefSelf) as TControl;
        NewSortMarker.Parent := RefSelf;
      end;
      FSortMarkerPanel := TLaLayoutPanelEh(RefSelf);
      FSortMarkerPanel.Name := 'SortMarkerPanel';
    end;

    
    with TLaButtonEh.CreateWith(RefSelf, RefSelf) do
    begin
      ControlCollection.AddControl(RefSelf, 2, -1);
      VertAlignment := TLaVertAlignmentEh.Center;
      Width := 16;
      Height := 18;
      Margins.Rect := TRectF.Create(2, 1, 2, 1);
      OnMouseDown := FilterButtonMouseDown;

      FButtonImage := TImage.Create(RefSelf);
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

function TDataGridGroupDescriptionControlEh.GetGrid: TControl;
begin
  Result := FCellHolder.FGrid;
end;

function TDataGridGroupDescriptionControlEh.GetGroupDescription: TDataGridGroupDescriptionEh;
begin
  Result := FCellHolder.GroupDescription;
end;

function TDataGridGroupDescriptionControlEh.GetIsShowButtonFace: Boolean;
begin
  Result := FFilterButton.IsButtonBackVisible;
end;

procedure TDataGridGroupDescriptionControlEh.SetBackgroundStyle(const Value: TControl);
var
  StyledBackground: TControl;
begin
  if FBackgroundStyle <> Value then
  begin
    FStyledBackgroundHolder.DeleteChildren;
    FStyledBackgroundHolder.TagObject := Value;
    if Value <> nil then
    begin
      StyledBackground := Value.Clone(Self) as TControl;
      StyledBackground.Align := TAlignLayout.None;
      FStyledBackgroundHolder.AddObject(StyledBackground);
    end;
    FBackgroundStyle := Value;
  end;
end;

procedure TDataGridGroupDescriptionControlEh.SetIsShowButtonFace(const Value: Boolean);
begin
  FFilterButton.IsButtonBackVisible := Value;
end;

function TDataGridGroupDescriptionControlEh.GetIsShowFilterButton: Boolean;
begin
  Result := FFilterButton.Visible
end;

procedure TDataGridGroupDescriptionControlEh.SetIsShowFilterButton(const Value: Boolean);
begin
  FFilterButton.Visible := Value;
end;

{$ENDREGION 'TDataGridGroupDescriptionControlEh'}

initialization
  InitRes;
finalization
  FinRes;
end.
