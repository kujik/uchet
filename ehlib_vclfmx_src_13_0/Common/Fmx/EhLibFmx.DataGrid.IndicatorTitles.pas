{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{          EhLibFmx.DataGrid.IndicatorTitles            }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataGrid.IndicatorTitles;

interface

{$SCOPEDENUMS ON}

uses
  System.SysUtils, System.Classes, System.UIConsts,
  FMX.Types, FMX.Controls, System.Types, FMX.Menus,
  FMX.Graphics, System.UITypes, System.Math, FMX.Forms, System.Contnrs,
  FMX.Grid, FMX.Platform, Data.DB, System.Variants, FMX.Objects,
  FMX.ImgList,
  EhLibFmx.ToolControls,
  EhLibFmx.ImageReses,

  EhLibFmx.Grids,
  EhLibFmx.Grid.CellManagers,

  EhLibFmx.DataGrid.ToolControls,

  EhLibFmx.Platform,
  EhLibFmx.Types,
  EhLibFmx.LaHostVirtualPanels,
  EhLibFmx.LaObjects,
  EhLibFmx.LaControls,
  EhLibFmx.LaGridPanels,
  EhLibFmx.LaPanels,
  EhLibFmx.Grid.ToolControls;

type

  TDataGridIndicatorTitleMouseDownEventEh = procedure(Sender: TObject; Params: TGridCellMouseButtonParamsEh) of object;
  TDataGridIndicatorTitleMouseClickEventEh = procedure (Sender: TObject; Params: TGridCellMouseButtonParamsEh) of object;
  TDataGridIndicatorTitleCreateCellContentEventEh = procedure(Sender: TObject; Params: TBaseGridCreateCellContentParamsEh) of object;

{ TDataGridIndicatorTitleEh }

  TDataGridIndicatorTitleEh = class(TComponent)
  private
    FGrid: TControl;
    FTimer: TTimer;
    FIsClickShowGridMenu: Boolean;
    FDefaultCellManager: TBaseGridCellManagerEh;
    FInternalDefCellManager: TBaseGridCellManagerEh;
    FIsShowDropDownSign: Boolean;
    FOnMouseDown: TDataGridIndicatorTitleMouseDownEventEh;
    FOnMouseClick: TDataGridIndicatorTitleMouseClickEventEh;
    procedure SetDefaultCellManager(const Value: TBaseGridCellManagerEh);
    procedure SetIsShowDropDownSign(const Value: Boolean);

  protected
    FPersistentDown: Boolean;

    procedure OnTimer(Sender: TObject);
    procedure Changed(CellLayoutAffects: Boolean = False);
    procedure HandleMouseDownEvent(Params: TGridCellMouseButtonParamsEh); virtual;
    procedure HandleMouseClickEvent(Params: TGridCellMouseButtonParamsEh); virtual;

  public
    constructor Create(AGrid: TControl); reintroduce;
    destructor Destroy; override;

    function CanClickShowGridMenu: Boolean; virtual;
    function CanClickDropDownSign: Boolean; virtual;
    function GetCellManagerAt(ALocalColIndex, ALocalRowIndex: Integer): TBaseGridCellManagerEh; virtual;

    procedure BuildAndShowIndicatorTitleMenu(Pos: TPointF);

    property Grid: TControl read FGrid;
    property DefaultCellManager: TBaseGridCellManagerEh read FDefaultCellManager write SetDefaultCellManager;

  published
    property IsClickShowGridMenu: Boolean read FIsClickShowGridMenu write FIsClickShowGridMenu default True;
    property IsShowDropDownSign: Boolean read FIsShowDropDownSign write SetIsShowDropDownSign default True;

    property OnMouseDown: TDataGridIndicatorTitleMouseDownEventEh read FOnMouseDown write FOnMouseDown;
    property OnMouseClick: TDataGridIndicatorTitleMouseClickEventEh read FOnMouseClick write FOnMouseClick;
  end;

{ TDataGridIndicatorTitleCellManagerEh }

  TDataGridIndicatorTitleCellManagerEh = class(TBaseGridCellManagerEh)
  private
    FOnCreateCellContent: TDataGridIndicatorTitleCreateCellContentEventEh;
  protected
    function CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh; override;
    function CreateCellContentParams(): TBaseGridCreateCellContentParamsEh; override;

    procedure HandleMouseDownEvent(Params: TGridCellMouseButtonParamsEh); override;
    procedure HandleMouseClickEvent(Params: TGridCellMouseButtonParamsEh); override;
    procedure HandleCreateCustomCellContent(Params: TBaseGridCreateCellContentParamsEh); override;

    procedure MouseDown(Params: TGridCellMouseButtonParamsEh); override;
    procedure MouseClick(Params: TGridCellMouseButtonParamsEh); override;
  public
    function GetBackgroundStyle(AParams: TBaseGridInitCellParamsEh): TControl; override;
    function IsShowSelectionLayer(AGrid: TControl; ACell: TGridBaseCellEh): Boolean; override;

    procedure InitCell(ACell: TGridBaseCellEh); override;
    procedure DefaultInitCellContent(Params: TBaseGridInitCellContentParamsEh); override;

    property OnCreateCellContent: TDataGridIndicatorTitleCreateCellContentEventEh read FOnCreateCellContent write FOnCreateCellContent;
  end;

{ TDataGridIndicatorTitleCellEh }

  TDataGridIndicatorTitleCellEh = class(TGridBaseCellEh)
  private
    FDropDownSign: TLaLayoutPanelEh;

  protected

    procedure MouseClick(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure CreateControls(); override;

    function CreateDefaultCellContentControls(AParentObject: TLaObjectEh): TLaObjectEh; override;

  public
    constructor Create(ACellHolder: TGridBaseCellHolderEh);
    destructor Destroy; override;

    property DropDownSign: TLaLayoutPanelEh read FDropDownSign write FDropDownSign;
  end;

implementation

uses EhLibFmx.CustomDataGrids;

type
  TCustomDataGridEhCrack = class(TCustomDataGridEh);
  TLaLayoutPanelEhCrack = class(TLaLayoutPanelEh);

{ TDataGridIndicatorTitleEh }

constructor TDataGridIndicatorTitleEh.Create(AGrid: TControl);
begin
  inherited Create(AGrid);
  SetSubComponent(True);
  Name := 'IndicatorTitle';
  FGrid := AGrid;
  FTimer := TTimer.Create(nil);
  FTimer.OnTimer := OnTimer;
  FTimer.Interval := 1;
  FTimer.Enabled := False;
  FIsClickShowGridMenu := True;
  FIsShowDropDownSign := True;
  FInternalDefCellManager := TDataGridIndicatorTitleCellManagerEh.Create(nil);
  FDefaultCellManager := FInternalDefCellManager;
end;

destructor TDataGridIndicatorTitleEh.Destroy;
begin
  FreeAndNil(FInternalDefCellManager);
  FreeAndNil(FTimer);
  inherited Destroy;
end;

function TDataGridIndicatorTitleEh.CanClickDropDownSign: Boolean;
begin
  Result := (IsShowDropDownSign = True) and
            (TEhLibFmxSettings.Default.PlatformWindowSizeType = TPlatformWindowSizeTypeEh.Sizable);
end;

function TDataGridIndicatorTitleEh.CanClickShowGridMenu: Boolean;
begin
  Result := (IsClickShowGridMenu = True) and
            (TEhLibFmxSettings.Default.PlatformWindowSizeType = TPlatformWindowSizeTypeEh.Sizable);
end;

procedure TDataGridIndicatorTitleEh.Changed(CellLayoutAffects: Boolean);
begin
  TCustomDataGridEhCrack(FGrid).LayoutChanged;
end;

procedure TDataGridIndicatorTitleEh.OnTimer(Sender: TObject);
begin
  FPersistentDown := False;
  FTimer.Enabled := False;
  TCustomDataGridEhCrack(FGrid).Invalidate;
end;

procedure TDataGridIndicatorTitleEh.BuildAndShowIndicatorTitleMenu(Pos: TPointF);
var
  APopupMenu: TPopupMenu;
begin

  APopupMenu := TCustomDataGridEhCrack(FGrid).GetBuildIndicatorTitleCellPopupMenu(nil);

  if APopupMenu <> nil then
  begin
    APopupMenu.PopupComponent := Grid;
    FPersistentDown := True;
    APopupMenu.Popup(Pos.X, Pos.Y);
    FTimer.Enabled := True;
  end;
end;

function TDataGridIndicatorTitleEh.GetCellManagerAt(ALocalColIndex,
  ALocalRowIndex: Integer): TBaseGridCellManagerEh;
begin
  Result := DefaultCellManager;
end;

procedure TDataGridIndicatorTitleEh.SetDefaultCellManager(
  const Value: TBaseGridCellManagerEh);
begin
  if FDefaultCellManager <> Value then
  begin
    FDefaultCellManager := Value;
    if FDefaultCellManager = nil then
      FDefaultCellManager := FInternalDefCellManager;
    Changed;
  end;
end;

procedure TDataGridIndicatorTitleEh.SetIsShowDropDownSign(const Value: Boolean);
begin
  if FIsShowDropDownSign <> Value then
  begin
    FIsShowDropDownSign := Value;
    Changed;
  end;
end;

procedure TDataGridIndicatorTitleEh.HandleMouseClickEvent(Params: TGridCellMouseButtonParamsEh);
begin
  if Assigned(OnMouseClick) then
    OnMouseClick(Self, Params);
end;

procedure TDataGridIndicatorTitleEh.HandleMouseDownEvent(Params: TGridCellMouseButtonParamsEh);
begin
  if Assigned(OnMouseDown) then
    OnMouseDown(Self, Params);
end;

{ TDataGridIndicatorTitleCellEh }

constructor TDataGridIndicatorTitleCellEh.Create(ACellHolder: TGridBaseCellHolderEh);
begin
  inherited Create(ACellHolder);
  HitTest := True;
end;

destructor TDataGridIndicatorTitleCellEh.Destroy;
begin
  inherited Destroy;
end;

procedure TDataGridIndicatorTitleCellEh.CreateControls;
begin
  inherited CreateControls;
end;

function TDataGridIndicatorTitleCellEh.CreateDefaultCellContentControls(AParentObject: TLaObjectEh): TLaObjectEh;
begin
  with TLaLayoutPanelEh.CreateWith(AParentObject, AParentObject) do
  begin
    DropDownSign := TLaLayoutPanelEh(RefSelf);
    Margins.Rect := TRectF.Create(1, 1, 1, 1);
    VertAlignment := TLaVertAlignmentEh.Center;
    HorzAlignment := TLaHorzAlignmentEh.Right;
    Width := 10;
    Height := 18;

    with TLaControlsGenericHelper.CreateControlWith<TImage>(Self, RefSelf) do
    begin
      Align := TAlignLayout.Center;
      WrapMode := TImageWrapMode.Place;
      MultiResBitmap := EhLibImageResources.DropDownSign;
      HitTest := False;
      Locked := True;
    end;

    Result := RefSelf;
  end;
end;

procedure TDataGridIndicatorTitleCellEh.MouseClick(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited MouseClick(Button, Shift, X, Y);
end;

procedure TDataGridIndicatorTitleCellEh.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  inherited MouseDown(Button, Shift, X, Y);
end;

{$REGION 'TDataGridIndicatorTitleCellManagerEh'}

{ TDataGridIndicatorTitleCellManagerEh }

function TDataGridIndicatorTitleCellManagerEh.CreateCellContentParams: TBaseGridCreateCellContentParamsEh;
begin
  Result := TBaseGridCreateCellContentParamsEh.Create;
end;

function TDataGridIndicatorTitleCellManagerEh.CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh;
begin
  Result := TDataGridIndicatorTitleCellEh.Create(ACellHolder);
end;

procedure TDataGridIndicatorTitleCellManagerEh.HandleCreateCustomCellContent(
  Params: TBaseGridCreateCellContentParamsEh);
begin
  if Assigned(OnCreateCellContent) then
    OnCreateCellContent(Self, Params);
end;

procedure TDataGridIndicatorTitleCellManagerEh.HandleMouseClickEvent(Params: TGridCellMouseButtonParamsEh);
var
  AGrid: TCustomDataGridEhCrack;
begin
  AGrid := TCustomDataGridEhCrack(Params.Grid);
  AGrid.IndicatorTitle.HandleMouseClickEvent(Params);
end;

procedure TDataGridIndicatorTitleCellManagerEh.HandleMouseDownEvent(Params: TGridCellMouseButtonParamsEh);
var
  AGrid: TCustomDataGridEhCrack;
begin
  AGrid := TCustomDataGridEhCrack(Params.Grid);
  AGrid.IndicatorTitle.HandleMouseDownEvent(Params);
end;

function TDataGridIndicatorTitleCellManagerEh.GetBackgroundStyle(
  AParams: TBaseGridInitCellParamsEh): TControl;
var
  VGrid: TCustomDataGridEhCrack;
begin
  VGrid := TCustomDataGridEhCrack(AParams.Grid);
  Result := VGrid.StylePainter.TopFixedCellBackground;
end;

procedure TDataGridIndicatorTitleCellManagerEh.InitCell(ACell: TGridBaseCellEh);
begin
  inherited InitCell(ACell);
end;

function TDataGridIndicatorTitleCellManagerEh.IsShowSelectionLayer(
  AGrid: TControl; ACell: TGridBaseCellEh): Boolean;
var
  VGrid: TCustomDataGridEhCrack;
begin
  VGrid := TCustomDataGridEhCrack(ACell.Grid);
  Result := (VGrid.Selection.SelectionType = TDataGridSelectionTypeEh.All) or
            (VGrid.IndicatorTitle.FPersistentDown = True);
end;

procedure TDataGridIndicatorTitleCellManagerEh.DefaultInitCellContent(
  Params: TBaseGridInitCellContentParamsEh);
begin
  inherited DefaultInitCellContent(Params);
end;

procedure TDataGridIndicatorTitleCellManagerEh.MouseClick(Params: TGridCellMouseButtonParamsEh);
begin
  inherited MouseClick(Params);
end;

procedure TDataGridIndicatorTitleCellManagerEh.MouseDown(Params: TGridCellMouseButtonParamsEh);
var
  AGrid: TCustomDataGridEhCrack;
  CellLeftButton: TPointF;
begin
  inherited MouseDown(Params);

  if Params.Handled = False then
  begin
    AGrid := TCustomDataGridEhCrack(Params.Grid);
    if (AGrid.IndicatorTitle.FPersistentDown = False) and
       (AGrid.IndicatorTitle.CanClickShowGridMenu() = True) then
    begin
      CellLeftButton := PointF(0, Params.Cell.ActualHeight);
      CellLeftButton := Params.Cell.LocalToScreen(CellLeftButton);
      AGrid.IndicatorTitle.BuildAndShowIndicatorTitleMenu(CellLeftButton);
    end;
  end;
end;

{$ENDREGION 'TDataGridIndicatorTitleCellManagerEh'}

end.
