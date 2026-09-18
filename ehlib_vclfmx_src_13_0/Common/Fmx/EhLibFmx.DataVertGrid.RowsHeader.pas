{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{          EhLibFmx.DataVertGrid.HeaderColumns          }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataVertGrid.RowsHeader;

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
  EhLibFmx.Grids,

  EhLibFmx.DataVertGrid.Rows,
  EhLibFmx.DataVertGrid.ToolControls,

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
  TDataVertGridRowHeaderCellContextMenuParamsEh = class;
  TDataVertGridRowHeaderCellEh = class;
  TDataVertGridRowHeaderCreateCellContentParamsEh = class;
  TDataVertGridRowHeaderInitCellContentParamsEh = class;

{ TDataVertGridColumnHeaderInitCellParamsEh }

  TDataVertGridColumnHeaderInitCellParamsEh = class(TBaseGridInitCellParamsEh)
  private
    FColumnTitle: TDataVertGridRowHeaderEh;

  public
    procedure Init(AGrid: TControl; ACellManager: TBaseGridCellManagerEh; ACell: TGridBaseCellEh); override;
    property ColumnTitle: TDataVertGridRowHeaderEh read FColumnTitle;
  end;

{ TDataVertGridRowHeaderInitCellContentParamsEh }

  TDataVertGridRowHeaderInitCellContentParamsEh = class(TDataAxisGridTitleInitCellContentParamsEh)
  private
    function GetColumnTitle: TDataVertGridRowHeaderEh;
  protected
    function GetFieldBarTitle: TFieldBarTitleEh; override;

  public
    procedure Init(ACell: TGridBaseCellEh; ACellContent: TLaObjectEh; InitCellParams: TBaseGridInitCellParamsEh); override;

    property ColumnTitle: TDataVertGridRowHeaderEh read GetColumnTitle;
  end;

{ TDataVertGridRowHeaderCreateCellContentParamsEh }

  TDataVertGridRowHeaderCreateCellContentParamsEh = class(TDataAxisGridTitleCreateCellContentParamsEh)
  private
  public
  end;

{ TDataVertGridRowHeaderCellContextMenuParamsEh }

  TDataVertGridRowHeaderCellContextMenuParamsEh = class(TBaseGridCellContextMenuParamsEh)
  private
    FRowHeader: TDataVertGridRowHeaderEh;

  public
    procedure Reset(AGrid: TControl; ACell: TGridBaseCellEh); override;

    property RowHeader: TDataVertGridRowHeaderEh read FRowHeader;
  end;

{ TDataVertGridRowHeaderCellComposeContextMenuParamsEh }

  TDataVertGridRowHeaderCellComposeContextMenuParamsEh = class(TBaseGridCellComposeContextMenuParamsEh)
  private
    FRow: TDataVertGridBaseRowEh;

  public
    procedure Init(AGrid: TControl; ACell: TGridBaseCellEh; AControlParams: TControlShowContextMenuParamsEh); override;

    property Row: TDataVertGridBaseRowEh read FRow;
  end;

{ TDataVertGridRowHeaderGetCellManagerParamsEh }

  TDataVertGridRowHeaderGetCellManagerParamsEh = class(TPersistent)
  private
    FRowHeader: TDataVertGridRowHeaderEh;
    FGrid: TControl;
    FCellManager: TBaseGridCellManagerEh;

  public
    procedure Init(AGrid: TControl; ARowHeader: TDataVertGridRowHeaderEh; ADefaultCellManager: TBaseGridCellManagerEh); virtual;

    property Grid: TControl read FGrid;
    property RowHeader: TDataVertGridRowHeaderEh read FRowHeader;
    property CellManager: TBaseGridCellManagerEh read FCellManager write FCellManager;
  end;

  TDataVertGridRowHeaderCreateCellContentEventEh = procedure(Sender: TObject; Params: TDataVertGridRowHeaderCreateCellContentParamsEh) of object;
  TDataVertGridRowHeaderInitCellContentEventEh = procedure(Sender: TObject; Params: TDataVertGridRowHeaderInitCellContentParamsEh) of object;
  TDataVertGridRowHeaderGetCellManagerEventEh = procedure(Sender: TObject; Params: TDataVertGridRowHeaderGetCellManagerParamsEh) of object;

{ TDataVertGridRowsHeaderEh }

  TDataVertGridRowsHeaderEh = class(TAxisGridTitleBarEh)
  private
    FDefaultCellManager: TBaseGridCellManagerEh;
    FInternalDefCellManager: TBaseGridCellManagerEh;
    FOnCreateCellContent: TDataVertGridRowHeaderCreateCellContentEventEh;
    FOnCellInitContent: TDataVertGridRowHeaderInitCellContentEventEh;
    FOnGetCellManager: TDataVertGridRowHeaderGetCellManagerEventEh;
    FWidth: Integer;

    procedure SetMouseInTitle(const Value: Boolean);
    procedure SetDefaultCellManager(const Value: TBaseGridCellManagerEh);
    procedure SetWidth(const Value: Integer);

  protected
    FHeaderColIndex: Integer;
    FMouseInTitle: Boolean;

    function CreateGetCellManagerParams(): TDataVertGridRowHeaderGetCellManagerParamsEh; virtual;
    function DefaultHorzAlign(): TTextAlign; override;
    function GetDefaultCellManagerAt(ALocalColIndex, ALocalRowIndex: Integer): TBaseGridCellManagerEh; virtual;

    procedure HandleCreateCellContent(Params: TDataVertGridRowHeaderCreateCellContentParamsEh); virtual;
    procedure HandleGetCellManager(Params: TDataVertGridRowHeaderGetCellManagerParamsEh); virtual;
    procedure HandleInitCellContent(Params: TDataVertGridRowHeaderInitCellContentParamsEh); virtual;
    procedure ProcessGetCellManager(Params: TDataVertGridRowHeaderGetCellManagerParamsEh); virtual;

  public
    constructor Create(AGrid: TControl);
    destructor Destroy; override;

    function GetCellManagerAt(ALocalColIndex, ALocalRowIndex: Integer): TBaseGridCellManagerEh; virtual;

    procedure CellContextMenuNeeded(Params: TDataVertGridRowHeaderCellContextMenuParamsEh);

    property HeaderColIndex: Integer read FHeaderColIndex;
    property MouseInTitle: Boolean read FMouseInTitle write SetMouseInTitle;
    property DefaultCellManager: TBaseGridCellManagerEh read FDefaultCellManager write SetDefaultCellManager;
    property Width: Integer read FWidth write SetWidth default 120;

  published

    property OnCreateCellContent: TDataVertGridRowHeaderCreateCellContentEventEh read FOnCreateCellContent write FOnCreateCellContent;
    property OnCellInitContent: TDataVertGridRowHeaderInitCellContentEventEh read FOnCellInitContent write FOnCellInitContent;
    property OnGetCellManager: TDataVertGridRowHeaderGetCellManagerEventEh read FOnGetCellManager write FOnGetCellManager;
  end;

{ TDataGridVirtualPanelEh }

  TDataGridTitleVirtualPanelEh = class(TGridLaHostVirtualPanelEh)
  private
  protected
  public
  end;

{ TDataGridTitleCellManagerEh }

  TDataGridTitleCellManagerEh = class(TBaseGridCellManagerEh)
  private
    FOnCreateCellContent: TDataVertGridRowHeaderCreateCellContentEventEh;
    FOnCellInitContent: TDataVertGridRowHeaderInitCellContentEventEh;

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
    function IsShowSelectionLayer(AGrid: TControl; ACell: TGridBaseCellEh): Boolean; override;

    procedure InitCellHolder(ACell: TVPBaseCellHolderEh); override;
    procedure InitCellPositionProps(ACell: TGridBaseCellEh); override;
    procedure DefaultInitCellProps(Params: TBaseGridInitCellParamsEh); override;
    procedure DefaultInitCellContent(AParams: TBaseGridInitCellContentParamsEh); override;

    property OnCreateCellContent: TDataVertGridRowHeaderCreateCellContentEventEh read FOnCreateCellContent write FOnCreateCellContent;
    property OnCellInitContent: TDataVertGridRowHeaderInitCellContentEventEh read FOnCellInitContent write FOnCellInitContent;
  end;

{ TDataGridVPTitleCellEh }

  TDataVertGridRowHeaderCellEh = class(TGridBaseCellEh)
  private
    FMouseDownPos: TPoint;
//    FSelectionLayer: TLaControlEh;
    FTextControl: TLaTextBlockEh;
    FCellContent: TLaControlEh;
    FRowHeader: TDataVertGridRowHeaderEh;

    function GetText: String;
    procedure SetText(const Value: String);

  protected

    function GetCursorAtMousePos(Shift: TShiftState; X, Y: Single): TCursor; override;
    function CreateCellClientControls(AParent: TLaObjectEh): TLaObjectEh; override;

    procedure ProcessMouseDown(Params: TControlMouseButtonParamsEh); override;
    procedure ProcessMouseMove(Params: TControlMouseParamsEh); override;

    procedure MouseClick(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseEnter(Params: TControlParamsEh); override;
    procedure MouseLeave(Params: TControlParamsEh); override;
    procedure CreateControls(); override;

    function CreateDefaultCellContentControls(AParentObject: TLaObjectEh): TLaObjectEh; override;

  public
    constructor Create(ACellHolder: TGridBaseCellHolderEh);
    destructor Destroy; override;

    property Text: String read GetText write SetText;
    property TextControl: TLaTextBlockEh read FTextControl;
    property CellContent: TLaControlEh read FCellContent;
    property RowHeader: TDataVertGridRowHeaderEh read FRowHeader;
  end;

implementation

uses EhLibFmx.CustomDataVertGrids;

type
  TCustomDataVertGridEhCrack = class(TCustomDataVertGridEh);
  TDataVertGridRowHeaderEhCrack = class(TDataVertGridRowHeaderEh);
  TLaLayoutPanelEhCrack = class(TLaLayoutPanelEh);

{ TDataVertGridRowsHeaderEh }

constructor TDataVertGridRowsHeaderEh.Create(AGrid: TControl);
begin
  inherited Create(AGrid);
  FMouseInTitle := False;
  FWidth := 120;
  FInternalDefCellManager := TDataGridTitleCellManagerEh.Create(nil);
  FDefaultCellManager := FInternalDefCellManager;
end;

destructor TDataVertGridRowsHeaderEh.Destroy;
begin
  FreeAndNil(FInternalDefCellManager);
  inherited Destroy;
end;

function TDataVertGridRowsHeaderEh.GetDefaultCellManagerAt(ALocalColIndex, ALocalRowIndex: Integer): TBaseGridCellManagerEh;
var
  Column: TDataVertGridBaseRowEh;
begin
  if ALocalColIndex < TCustomDataVertGridEhCrack(Grid).VisibleRows.Count
    then Column := TCustomDataVertGridEhCrack(Grid).VisibleRows[ALocalColIndex]
    else Column := nil;

  if Column <> nil then
    Result := Column.Header.GetCellManager()
  else
    Result := DefaultCellManager;
end;

function TDataVertGridRowsHeaderEh.GetCellManagerAt(ALocalColIndex, ALocalRowIndex: Integer): TBaseGridCellManagerEh;
var
  GetCellManagerParams: TDataVertGridRowHeaderGetCellManagerParamsEh;
  Grid: TCustomDataVertGridEhCrack;
  ADefaultCellManager: TBaseGridCellManagerEh;
  ColumnTitle: TDataVertGridRowHeaderEh;
begin
  Grid := TCustomDataVertGridEhCrack(Self.Grid);
  if ALocalColIndex < TCustomDataVertGridEhCrack(Grid).VisibleRows.Count
    then ColumnTitle := TCustomDataVertGridEhCrack(Grid).VisibleRows[ALocalColIndex].Header
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

function TDataVertGridRowsHeaderEh.CreateGetCellManagerParams(): TDataVertGridRowHeaderGetCellManagerParamsEh;
begin
  Result := TDataVertGridRowHeaderGetCellManagerParamsEh.Create;
end;

procedure TDataVertGridRowsHeaderEh.ProcessGetCellManager(Params: TDataVertGridRowHeaderGetCellManagerParamsEh);
begin
  if (Params.RowHeader <> nil) then
    TDataVertGridRowHeaderEhCrack(Params.RowHeader).HandleGetCellManager(Params);
  HandleGetCellManager(Params);
end;

procedure TDataVertGridRowsHeaderEh.HandleGetCellManager(Params: TDataVertGridRowHeaderGetCellManagerParamsEh);
begin
  if Assigned(OnGetCellManager) then
    OnGetCellManager(Self, Params);
end;

procedure TDataVertGridRowsHeaderEh.CellContextMenuNeeded(Params: TDataVertGridRowHeaderCellContextMenuParamsEh);
begin
  TCustomDataVertGridEhCrack(Grid).BuildHeaderCellPopupMenu(Params);
end;

function TDataVertGridRowsHeaderEh.DefaultHorzAlign: TTextAlign;
begin
  Result := inherited DefaultHorzAlign;
end;

procedure TDataVertGridRowsHeaderEh.SetMouseInTitle(const Value: Boolean);
var
  AGrid: TCustomDataVertGridEhCrack;
begin
  AGrid := TCustomDataVertGridEhCrack(Grid);
  if FMouseInTitle <> Value then
  begin
    FMouseInTitle := Value;
    AGrid.Invalidate;
  end;
end;

procedure TDataVertGridRowsHeaderEh.SetWidth(const Value: Integer);
var
  AGrid: TCustomDataVertGridEhCrack;
begin
  AGrid := TCustomDataVertGridEhCrack(Grid);
  if FWidth <> Value then
  begin
    FWidth := Value;
    AGrid.InvalidateRowHeight();
  end;
end;

procedure TDataVertGridRowsHeaderEh.SetDefaultCellManager(const Value: TBaseGridCellManagerEh);
begin
  if FDefaultCellManager <> Value then
  begin
    FDefaultCellManager := Value;
    if FDefaultCellManager = nil then
      FDefaultCellManager := FInternalDefCellManager;
    Changed;
  end;
end;

procedure TDataVertGridRowsHeaderEh.HandleCreateCellContent(Params: TDataVertGridRowHeaderCreateCellContentParamsEh);
begin
  if Assigned(OnCreateCellContent) then
    OnCreateCellContent(Self, Params);
end;

procedure TDataVertGridRowsHeaderEh.HandleInitCellContent(Params: TDataVertGridRowHeaderInitCellContentParamsEh);
begin
  if Assigned(OnCellInitContent) then
    OnCellInitContent(Self, Params);
end;

{ TDataVertGridRowHeaderCellContextMenuParamsEh }

procedure TDataVertGridRowHeaderCellContextMenuParamsEh.Reset(AGrid: TControl; ACell: TGridBaseCellEh);
var
  VGrid: TCustomDataVertGridEhCrack;
begin
  VGrid := TCustomDataVertGridEhCrack(AGrid);

  inherited Reset(AGrid, ACell);

  if (AreaColIndex >= 0) and (AreaColIndex < VGrid.VisibleRows.Count) then
    FRowHeader := VGrid.VisibleRows[AreaColIndex].Header
  else
    FRowHeader := nil;
end;

{ TDataGridTitleCellManagerEh }

function TDataGridTitleCellManagerEh.CreateCellHolder: TVPBaseCellHolderEh;
begin
  Result := inherited CreateCellHolder();
end;

procedure TDataGridTitleCellManagerEh.ComposeContextMenu(ACellParams: TBaseGridCellComposeContextMenuParamsEh);
var
  VGrid: TCustomDataVertGridEhCrack;
begin
  VGrid := TCustomDataVertGridEhCrack(ACellParams.Grid);
  VGrid.ComposeHeaderCellMenu(ACellParams as TDataVertGridRowHeaderCellComposeContextMenuParamsEh);
end;

function TDataGridTitleCellManagerEh.CreateComposeContextMenuParams: TBaseGridCellComposeContextMenuParamsEh;
begin
  Result := TDataVertGridRowHeaderCellComposeContextMenuParamsEh.Create;
end;

function TDataGridTitleCellManagerEh.CreateCellContentParams(): TBaseGridCreateCellContentParamsEh;
begin
  Result := TDataVertGridRowHeaderCreateCellContentParamsEh.Create;
end;

procedure TDataGridTitleCellManagerEh.HandleCreateCustomCellContent(Params: TBaseGridCreateCellContentParamsEh);
var
  VGrid: TCustomDataVertGridEhCrack;
  TitleContentParams: TDataVertGridRowHeaderCreateCellContentParamsEh;
begin
  VGrid := TCustomDataVertGridEhCrack(Params.Cell.Grid);
  TitleContentParams := TDataVertGridRowHeaderCreateCellContentParamsEh(Params);
  VGrid.RowsHeader.HandleCreateCellContent(TitleContentParams);

  if Assigned(OnCreateCellContent) then
    OnCreateCellContent(Self, TitleContentParams);
end;

function TDataGridTitleCellManagerEh.DefaultCreateContentControls(ACell: TGridBaseCellEh; AParentObject: TLaObjectEh): TLaControlEh;
var
  TitleCell: TDataVertGridRowHeaderCellEh;
begin
  with TLaLayoutPanelEh.CreateWith(AParentObject, AParentObject) do
  begin

    TitleCell := TDataVertGridRowHeaderCellEh(ACell);
    TitleCell.FTextControl := TLaTextBlockEh.CreateWith(AParentObject, RefSelf);
    TitleCell.FTextControl.Padding.Rect := RectF(2, 0, 2, 0);
    TitleCell.FTextControl.VertAlignment := TLaVertAlignmentEh.Center;
    TitleCell.FTextControl.HorzAlignment := TLaHorzAlignmentEh.Stretch;

    Result := TLaControlEh(RefSelf);
  end;
end;

function TDataGridTitleCellManagerEh.CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh;
begin
  Result := TDataVertGridRowHeaderCellEh.Create(ACellHolder);
end;

function TDataGridTitleCellManagerEh.CreateInitCellParams: TBaseGridInitCellParamsEh;
begin
  Result := TDataVertGridColumnHeaderInitCellParamsEh.Create;
end;

procedure TDataGridTitleCellManagerEh.HandleInitCell(Params: TBaseGridInitCellParamsEh);
begin
end;

procedure TDataGridTitleCellManagerEh.DefaultInitCellProps(Params: TBaseGridInitCellParamsEh);
var
  VGrid: TCustomDataVertGridEhCrack;
  Row: TDataVertGridBaseRowEh;
  TitleCell: TDataVertGridRowHeaderCellEh;
begin
  TitleCell := TDataVertGridRowHeaderCellEh(Params.Cell);
  VGrid := TCustomDataVertGridEhCrack(Params.Grid);
  if (Params.Cell.AreaRowIndex >= 0) and (Params.Cell.AreaRowIndex < VGrid.VisibleRows.Count) then
  begin
    Row := VGrid.VisibleRows[Params.Cell.AreaRowIndex];
    if TitleCell.TextControl <> nil then
    begin
      TitleCell.Text := Row.Header.Text;
      TitleCell.TextControl.TextAlign := Row.Header.HorzAlign;
      TitleCell.TextControl.VertAlignment := TLaVertAlignmentEh.Center;
      TitleCell.TextControl.Margins := Row.Header.Padding;
      TitleCell.TextControl.WordWrap := Row.Header.WordWrap;
      TitleCell.TextControl.Font := Row.Header.Font;
      TitleCell.TextControl.FontColor := Row.Header.FontColor;
    end;

    TitleCell.Fill.Kind := TBrushKind.Gradient;
    TitleCell.Fill.Gradient.Points[0].Color := MakeColor(234, 234, 234);
    TitleCell.Fill.Gradient.Points[0].Offset := 0.66;
    TitleCell.Fill.Gradient.Points[1].Color := $FFF0F0F0; 
    TitleCell.Fill.Gradient.Points[1].Offset := 1;
    TitleCell.Fill.Gradient.StartPosition.X := 0.5;
    TitleCell.Fill.Gradient.StartPosition.Y := 1.0;
    TitleCell.Fill.Gradient.StopPosition.X := 0.5;
    TitleCell.Fill.Gradient.StopPosition.Y := 0.0;

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
    TitleCell.Fill.Kind := TBrushKind.Solid;
    TitleCell.Fill.Color := VGrid.FInternalFixedColor;
  end;
end;

function TDataGridTitleCellManagerEh.IsShowSelectionLayer(AGrid: TControl; ACell: TGridBaseCellEh): Boolean;
var
  TitleCell: TDataVertGridRowHeaderCellEh;
begin
  TitleCell := TDataVertGridRowHeaderCellEh(ACell);
  if TitleCell.RowHeader <> nil
    then Result := TitleCell.RowHeader.Row.IsSelected
    else Result := False;
end;

function TDataGridTitleCellManagerEh.CreateInitCellContentParams: TBaseGridInitCellContentParamsEh;
begin
  Result := TDataVertGridRowHeaderInitCellContentParamsEh.Create;
end;

procedure TDataGridTitleCellManagerEh.HandleInitCellContent(Params: TBaseGridInitCellContentParamsEh);
var
  TitleParams: TDataVertGridRowHeaderInitCellContentParamsEh;
begin
  TitleParams := Params as TDataVertGridRowHeaderInitCellContentParamsEh;
  if Assigned(OnCellInitContent) then
    OnCellInitContent(Self, TitleParams);

  if TitleParams.Handled = False then
    TCustomDataVertGridEhCrack(Params.Grid).RowsHeader.HandleInitCellContent(TitleParams);
  if (TitleParams.Handled = False) and (TitleParams.ColumnTitle <> nil) then
    TDataVertGridRowHeaderEhCrack(TitleParams.ColumnTitle).HandleInitCellContent(TitleParams);
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
  VGrid: TCustomDataVertGridEhCrack;
  TitleCell: TDataVertGridRowHeaderCellEh;
begin
  inherited InitCellPositionProps(ACell);

  VGrid := TCustomDataVertGridEhCrack(ACell.Grid);
  TitleCell := TDataVertGridRowHeaderCellEh(ACell);
  if (ACell.AreaRowIndex >= 0) and (ACell.AreaRowIndex < VGrid.VisibleRows.Count) then
    TitleCell.FRowHeader := VGrid.VisibleRows[ACell.AreaRowIndex].Header
  else
    TitleCell.FRowHeader := nil;
end;

{ TDataVertGridRowHeaderCellEh }

constructor TDataVertGridRowHeaderCellEh.Create(ACellHolder: TGridBaseCellHolderEh);
begin
  inherited Create(ACellHolder);
  HitTest := True;
end;

destructor TDataVertGridRowHeaderCellEh.Destroy;
begin
  inherited Destroy;
end;

function TDataVertGridRowHeaderCellEh.CreateCellClientControls(AParent: TLaObjectEh): TLaObjectEh;
begin
  with TLaGridPanelEh.CreateWith(AParent, AParent) do
  begin
    Result := RefSelf;
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
  end;
end;

procedure TDataVertGridRowHeaderCellEh.CreateControls;
begin
  inherited CreateControls;
end;

function TDataVertGridRowHeaderCellEh.CreateDefaultCellContentControls(AParentObject: TLaObjectEh): TLaObjectEh;
begin
  Result := TDataGridTitleCellManagerEh(CellManager).DefaultCreateContentControls(Self, AParentObject);
end;

function TDataVertGridRowHeaderCellEh.GetText: String;
begin
  if FTextControl <> nil then
    Result := FTextControl.Text
  else
    Result := '';
end;

procedure TDataVertGridRowHeaderCellEh.SetText(const Value: String);
begin
  if FTextControl <> nil then
    FTextControl.Text := Value;
end;

function TDataVertGridRowHeaderCellEh.GetCursorAtMousePos(Shift: TShiftState; X, Y: Single): TCursor;
begin
  Result := inherited GetCursorAtMousePos(Shift, X, Y);
end;

procedure TDataVertGridRowHeaderCellEh.ProcessMouseDown(Params: TControlMouseButtonParamsEh);
var
  AGrid: TCustomDataVertGridEhCrack;
begin
  inherited ProcessMouseDown(Params);

  AGrid := TCustomDataVertGridEhCrack(Grid);
  FMouseDownPos := PointF(Params.X, Params.Y).Round;

  if (AreaColIndex >= AGrid.VisibleRows.Count) then
    Exit;

  if (Params.Handled = True) then
    Exit;
end;

procedure TDataVertGridRowHeaderCellEh.ProcessMouseMove(Params: TControlMouseParamsEh);
begin
  inherited ProcessMouseMove(Params);
end;

procedure TDataVertGridRowHeaderCellEh.MouseEnter(Params: TControlParamsEh);
var
  AGrid: TCustomDataVertGridEhCrack;
begin
  AGrid := TCustomDataVertGridEhCrack(Grid);
  inherited MouseEnter(Params);
  AGrid.RowsHeader.MouseInTitle := True;
end;

procedure TDataVertGridRowHeaderCellEh.MouseLeave(Params: TControlParamsEh);
var
  AGrid: TCustomDataVertGridEhCrack;
begin
  AGrid := TCustomDataVertGridEhCrack(Grid);
  inherited MouseLeave(Params);
  AGrid.RowsHeader.MouseInTitle := False;
end;

procedure TDataVertGridRowHeaderCellEh.MouseClick(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  AGrid: TCustomDataVertGridEhCrack;
begin
  AGrid := TCustomDataVertGridEhCrack(Grid);

  inherited MouseClick(Button, Shift, X, Y);

  if (AreaRowIndex >= AGrid.VisibleRows.Count) then
    Exit;
end;

{ TDataVertGridRowHeaderCellComposeContextMenuParamsEh }

procedure TDataVertGridRowHeaderCellComposeContextMenuParamsEh.Init(AGrid: TControl; ACell: TGridBaseCellEh;
  AControlParams: TControlShowContextMenuParamsEh);
var
  VGrid: TCustomDataVertGridEhCrack;
begin
  VGrid := TCustomDataVertGridEhCrack(AGrid);

  inherited Init(AGrid, ACell, AControlParams);

  if (AreaRowIndex >= 0) and (AreaRowIndex < VGrid.VisibleRows.Count) then
    FRow := VGrid.VisibleRows[AreaRowIndex]
  else
    FRow := nil;
end;

{ TDataVertGridColumnHeaderInitCellParamsEh }

procedure TDataVertGridColumnHeaderInitCellParamsEh.Init(AGrid: TControl; ACellManager: TBaseGridCellManagerEh; ACell: TGridBaseCellEh);
var
  VGrid: TCustomDataVertGridEhCrack;
begin
  inherited Init(AGrid, ACellManager, ACell);

  VGrid := TCustomDataVertGridEhCrack(ACell.Grid);
  if (ACell.AreaColIndex >= 0) and (ACell.AreaColIndex < VGrid.VisibleRows.Count) then
    FColumnTitle := VGrid.VisibleRows[ACell.AreaColIndex].Header
  else
    FColumnTitle := nil;
end;

{ TDataVertGridRowHeaderInitCellContentParamsEh }

procedure TDataVertGridRowHeaderInitCellContentParamsEh.Init(ACell: TGridBaseCellEh; ACellContent: TLaObjectEh; InitCellParams: TBaseGridInitCellParamsEh);
begin
  inherited Init(ACell, ACellContent, InitCellParams);
end;

function TDataVertGridRowHeaderInitCellContentParamsEh.GetFieldBarTitle: TFieldBarTitleEh;
var
  VGrid: TCustomDataVertGridEhCrack;
begin
  VGrid := TCustomDataVertGridEhCrack(Cell.Grid);
  if (Cell.AreaRowIndex >= 0) and (Cell.AreaRowIndex < VGrid.VisibleRows.Count) then
    Result := VGrid.VisibleRows[Cell.AreaRowIndex].Header
  else
    Result := nil;
end;

function TDataVertGridRowHeaderInitCellContentParamsEh.GetColumnTitle: TDataVertGridRowHeaderEh;
begin
  Result := TDataVertGridRowHeaderEh(FieldBarTitle);
end;

{ TDataGridTitleGetCellManagerParamsEh }

procedure TDataVertGridRowHeaderGetCellManagerParamsEh.Init(AGrid: TControl;
  ARowHeader: TDataVertGridRowHeaderEh; ADefaultCellManager: TBaseGridCellManagerEh);
begin
  FGrid := AGrid;
  FRowHeader := ARowHeader;
  FCellManager := ADefaultCellManager;
end;

end.

