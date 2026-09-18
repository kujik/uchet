{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{         EhLibFmx.DataGrid.IndicatorColumns            }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataGrid.IndicatorColumns;

interface

{$SCOPEDENUMS ON}

uses
  System.SysUtils, System.Classes, System.UIConsts,
  FMX.Types, FMX.Objects, FMX.Controls, System.Types,
  FMX.Graphics, System.UITypes, System.Math, FMX.Forms, System.Contnrs,
  FMX.Grid, FMX.Platform, Data.DB, System.Variants,
  EhLib.TableLinks,
  EhLibFmx.ToolControls,
  EhLibFmx.ImageReses,

  EhLibFmx.Grids,
  EhLibFmx.Grid.CellManagers,

  EhLibFmx.DataGrid.ToolControls,
  EhLibFmx.DataGrid.Rows,

  EhLibFmx.Platform,
  EhLibFmx.Types,
  EhLibFmx.LaHostVirtualPanels,
  EhLibFmx.LaObjects,
  EhLibFmx.LaControls,
  EhLibFmx.LaGridPanels,
  EhLibFmx.LaPanels,
  EhLibFmx.Grid.ToolControls;

type
  TDataGridIndicatorColumnEh = class;

  TDataGridRowEditStateEh = (Unassigned, Browse, Edit, New);

{ TDataGridIndicatorColumnGetCellManagerParamsEh }

  TDataGridIndicatorColumnGetCellManagerParamsEh = class(TPersistent)
  private
    FRow: TDataGridRowEh;
    FGrid: TControl;
    FCellManager: TBaseGridCellManagerEh;

  public
    procedure Init(AGrid: TControl; ARow: TDataGridRowEh; ADefaultCellManager: TBaseGridCellManagerEh); virtual;

    property Grid: TControl read FGrid;
    property Row: TDataGridRowEh read FRow;
    property CellManager: TBaseGridCellManagerEh read FCellManager write FCellManager;
  end;

{ TDataGridIndicatorColumnInitCellParamsEh }

  TDataGridIndicatorColumnInitCellParamsEh = class(TBaseGridInitCellParamsEh)
  private
    FRow: TDataGridRowEh;
    FGrid: TControl;
    FCellManager: TBaseGridCellManagerEh;
    FCell: TGridBaseCellEh;
    FHandled: Boolean;

  public
    procedure Init(AGrid: TControl; ACellManager: TBaseGridCellManagerEh; ACell: TGridBaseCellEh); override;
    procedure DefaultInitCell();

    property Grid: TControl read FGrid;
    property Row: TDataGridRowEh read FRow;
    property CellManager: TBaseGridCellManagerEh read FCellManager;
    property Cell: TGridBaseCellEh read FCell;
    property Handled: Boolean read FHandled write FHandled;
  end;

{ TDataGridIndicatorColumnCreateCellContentParamsEh }

  TDataGridIndicatorColumnCreateCellContentParamsEh = class(TBaseGridCreateCellContentParamsEh)
  private
  public
  end;

{ TDataGridIndicatorColumnInitCellContentParamsEh }

  TDataGridIndicatorColumnInitCellContentParamsEh = class(TBaseGridInitCellContentParamsEh)
  private
    FRow: TDataGridRowEh;

  public
    procedure Init(ACell: TGridBaseCellEh; ACellContent: TLaObjectEh; InitCellParams: TBaseGridInitCellParamsEh); override;

    property Row: TDataGridRowEh read FRow;
  end;

{ TDataGridIndicatorColumnCalcWidthParamsEh }

  TDataGridIndicatorColumnCalcWidthParamsEh = class(TPersistent)
  private
    FWidth: Integer;
    FGrid: TControl;
    FHandled: Boolean;
    function GetIndicatorColumn: TDataGridIndicatorColumnEh;
  public
    procedure Init(AGrid: TControl);
    function DefaultCalcColumnWidth(): Integer;

    property IndicatorColumn: TDataGridIndicatorColumnEh read GetIndicatorColumn;
    property Grid: TControl read FGrid;
    property Handled: Boolean read FHandled write FHandled;
    property Width: Integer read FWidth write FWidth;
  end;

  TDataGridIndicatorColumnGetCellManagerEventEh = procedure(Sender: TObject; Params: TDataGridIndicatorColumnGetCellManagerParamsEh) of object;
  TDataGridIndicatorColumnInitCellContentEventEh = procedure(Sender: TObject; Params: TDataGridIndicatorColumnInitCellContentParamsEh) of object;
  TDataGridIndicatorColumnCreateCellContentEventEh = procedure(Sender: TObject; Params: TDataGridIndicatorColumnCreateCellContentParamsEh) of object;
  TDataGridIndicatorColumnCalcWidthEventEh = procedure(Sender: TObject; Params: TDataGridIndicatorColumnCalcWidthParamsEh) of object;

{ TDataGridIndicatorColumnEh }

  TDataGridIndicatorColumnEh = class(TComponent)
  private
    FGrid: TControl;
    FVisible: Boolean;
    FHorzLines: Boolean;
    FHorzLinesStored: Boolean;
    FVertLines: Boolean;
    FVertLinesStored: Boolean;
    FShowRecNo: Boolean;
    FRecNoShowStep: Integer;
    FShowEditIndicator: Boolean;
    FHorzLinesColorStored: Boolean;
    FHorzLinesColor: TAlphaColor;
    FVertLinesColorStored: Boolean;
    FVertLinesColor: TAlphaColor;
    FDefaultCellManager: TBaseGridCellManagerEh;
    FInternalDefCellManager: TBaseGridCellManagerEh;
    FOnGetCellManager: TDataGridIndicatorColumnGetCellManagerEventEh;
    FOnCellInitContent: TDataGridIndicatorColumnInitCellContentEventEh;
    FOnCreateCellContent: TDataGridIndicatorColumnCreateCellContentEventEh;
    FOnCalcColumnWidth: TDataGridIndicatorColumnCalcWidthEventEh;

    function GetHorzLinesVisible: Boolean;
    function GetVertLinesVisible: Boolean;
    function IsHorzLinesVisibleStored: Boolean;
    function IsVertLinesVisibleStored: Boolean;

    procedure SetVisible(const Value: Boolean);
    procedure SetHorzLinesVisible(const Value: Boolean);
    procedure SetHorzLinesVisibleStored(const Value: Boolean);
    procedure SetVertLinesVisible(const Value: Boolean);
    procedure SetVertLinesVisibleStored(const Value: Boolean);
    procedure SetShowRecNo(const Value: Boolean);
    procedure SetRecNoShowStep(const Value: Integer);
    procedure SetShowEditIndicator(const Value: Boolean);

    function GetHorzLinesColor: TAlphaColor;
    function IsHorzLinesColorStored: Boolean;
    procedure SetHorzLinesColor(const Value: TAlphaColor);
    procedure SetHorzLinesColorStored(const Value: Boolean);
    function GetVertLinesColor: TAlphaColor;
    function IsVertLinesColorStored: Boolean;
    procedure SetVertLinesColor(const Value: TAlphaColor);
    procedure SetVertLinesColorStored(const Value: Boolean);
    procedure SetDefaultCellManager(const Value: TBaseGridCellManagerEh);

  protected
    FBaseColIndex: Integer;
    FWidthRecalcNeeded: Boolean;
    FCalculatedWidth: Integer;

    function DefaultHorzLinesVisible: Boolean; virtual;
    function DefaultVertLinesVisible: Boolean; virtual;
    function DefaultHorzLinesColor(): TAlphaColor; virtual;
    function DefaultVertLinesColor(): TAlphaColor; virtual;
    function CreateGetCellManagerParams(): TDataGridIndicatorColumnGetCellManagerParamsEh; virtual;
    function GetDefaultCellManagerAt(ALocalColIndex, ALocalRowIndex: Integer): TBaseGridCellManagerEh; virtual;

    procedure Changed();
    procedure HandleGetCellManager(Params: TDataGridIndicatorColumnGetCellManagerParamsEh); virtual;
    procedure ProcessGetCellManager(Params: TDataGridIndicatorColumnGetCellManagerParamsEh); virtual;
    procedure HandleCreateCellContent(Params: TDataGridIndicatorColumnCreateCellContentParamsEh); virtual;
    procedure HandleInitCellContent(Params: TDataGridIndicatorColumnInitCellContentParamsEh); virtual;
    procedure HandleCalcColumnWidth(Params: TDataGridIndicatorColumnCalcWidthParamsEh); virtual;

  public
    constructor Create(AGrid: TControl); reintroduce;
    destructor Destroy; override;

    function CalcColumnWidth(): Integer;
    function DefaultCalcColumnWidth(): Integer;
    function GetRecNoText(ADataRowIndex: Integer): String; virtual;
    function GetRowEditState(ARow: TDataGridRowEh): TDataGridRowEditStateEh; virtual;
    function GetCellManagerAt(ALocalColIndex, ALocalRowIndex: Integer): TBaseGridCellManagerEh; virtual;

    procedure SetWidthRecalcNeeded();

    property Grid: TControl read FGrid;
    property BaseColIndex: Integer read FBaseColIndex;
    property DefaultCellManager: TBaseGridCellManagerEh read FDefaultCellManager write SetDefaultCellManager;

  published
    property HorzLinesColor: TAlphaColor read GetHorzLinesColor write SetHorzLinesColor stored IsHorzLinesColorStored;
    property HorzLinesColorStored: Boolean read FHorzLinesColorStored write SetHorzLinesColorStored default False;
    property HorzLinesVisible: Boolean read GetHorzLinesVisible write SetHorzLinesVisible stored IsHorzLinesVisibleStored;
    property HorzLinesVisibleStored: Boolean read IsHorzLinesVisibleStored write SetHorzLinesVisibleStored stored False;
    property RecNoShowStep: Integer read FRecNoShowStep write SetRecNoShowStep default 10;
    property ShowEditIndicator: Boolean read FShowEditIndicator write SetShowEditIndicator default True;
    property ShowRecNo: Boolean read FShowRecNo write SetShowRecNo default True;
    property VertLinesColor: TAlphaColor read GetVertLinesColor write SetVertLinesColor stored IsVertLinesColorStored;
    property VertLinesColorStored: Boolean read FVertLinesColorStored write SetVertLinesColorStored default False;
    property VertLinesVisible: Boolean read GetVertLinesVisible write SetVertLinesVisible stored IsVertLinesVisibleStored;
    property VertLinesVisibleStored: Boolean read IsVertLinesVisibleStored write SetVertLinesVisibleStored stored False;
    property Visible: Boolean read FVisible write SetVisible default True;

    property OnCalcColumnWidth: TDataGridIndicatorColumnCalcWidthEventEh read FOnCalcColumnWidth write FOnCalcColumnWidth;
    property OnCellInitContent: TDataGridIndicatorColumnInitCellContentEventEh read FOnCellInitContent write FOnCellInitContent;
    property OnCreateCellContent: TDataGridIndicatorColumnCreateCellContentEventEh read FOnCreateCellContent write FOnCreateCellContent;
    property OnGetCellManager: TDataGridIndicatorColumnGetCellManagerEventEh read FOnGetCellManager write FOnGetCellManager;
  end;

{ TDataGridTitleCellManagerEh }

  TDataGridIndicatorCellManagerEh = class(TBaseGridCellManagerEh)
  private
  protected
    function CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh; override;

    function CreateInitCellParams: TBaseGridInitCellParamsEh; override;
    function CreateInitCellContentParams: TBaseGridInitCellContentParamsEh; override;
    function CreateCellContentParams(): TBaseGridCreateCellContentParamsEh; override;

    procedure HandleInitCellContent(Params: TBaseGridInitCellContentParamsEh); override;
    procedure HandleCreateCustomCellContent(Params: TBaseGridCreateCellContentParamsEh); override;

  public
    function GetBackgroundStyle(AParams: TBaseGridInitCellParamsEh): TControl; override;
    function IsShowSelectionLayer(AGrid: TControl; ACell: TGridBaseCellEh): Boolean; override;

    procedure DefaultInitCellProps(Params: TBaseGridInitCellParamsEh); override;
    procedure DefaultInitCellContent(Params: TBaseGridInitCellContentParamsEh); override;
    procedure InitCellPositionProps(ACell: TGridBaseCellEh); override;

    function DefaultCreateContentControls(ACell: TGridBaseCellEh; AParentObject: TLaObjectEh): TLaControlEh; virtual;
  end;

{ TDataGridIndicatorCellEh }

  TDataGridIndicatorCellEh = class(TGridBaseCellEh)
  private
    FRow: TDataGridRowEh;
//    FSelectionLayer: TLaControlEh;
//    FStyledBackground: TLaLayoutPanelEh;

//    function GetShowSelectionLayer: Boolean;
//    procedure SetShowSelectionLayer(const Value: Boolean);

  protected
    function CreateDefaultCellContentControls(AParentObject: TLaObjectEh): TLaObjectEh; override;

    procedure MouseClick(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure ProcessMouseDown(Params: TControlMouseButtonParamsEh); override;
    procedure CreateControls(); override;

  public
    constructor Create(ACellHolder: TGridBaseCellHolderEh);
    destructor Destroy; override;

//    property ShowSelectionLayer: Boolean read GetShowSelectionLayer write SetShowSelectionLayer;
    property Row: TDataGridRowEh read FRow;
  end;

{ TDataGridIndicatorCellContentEh }

  TDataGridIndicatorCellContentEh = class(TLaGridPanelEh)
  private
    FTextArea: TLaLayoutPanelEh;
    FTextBlock: TLaTextBlockEh;
    FEditState: TDataGridRowEditStateEh;
    FEditStateArea: TLaLayoutPanelEh;
    FEditStateImage: TImage;

    function GetText: String;
    function GetTextAreaVisible: Boolean;
    function GetEditStateAreaVisible: Boolean;

    procedure SetEditState(const Value: TDataGridRowEditStateEh);
    procedure SetEditStateAreaVisible(const Value: Boolean);
    procedure SetText(const Value: String);
    procedure SetTextAreaVisible(const Value: Boolean);
  public
    constructor Create(ACell: TGridBaseCellEh; AParentObject: TLaObjectEh);
    destructor Destroy; override;

    property Text: String read GetText write SetText;
    property TextBlock: TLaTextBlockEh read FTextBlock;
    property TextAreaVisible: Boolean read GetTextAreaVisible write SetTextAreaVisible;
    property EditState: TDataGridRowEditStateEh read FEditState write SetEditState;
    property EditStateAreaVisible: Boolean read GetEditStateAreaVisible write SetEditStateAreaVisible;
  end;

implementation

uses EhLibFmx.CustomDataGrids;

type
  TCustomDataGridEhCrack = class(TCustomDataGridEh);

  TDataGridIndicatorColumnEhHelper = class helper for TDataGridIndicatorColumnEh
  private
    function GetGrid: TCustomDataGridEhCrack;
  public
    property Grid: TCustomDataGridEhCrack read GetGrid;
  end;

function MiddleDotChar: Char;
begin
  Result := Char($B7);
end;

{ TDataGridIndicatorColumnEhHelper }

function TDataGridIndicatorColumnEhHelper.GetGrid: TCustomDataGridEhCrack;
begin
  Result := TCustomDataGridEhCrack(FGrid);
end;

{$REGION 'TDataGridIndicatorColumnEh'}
{ TDataGridIndicatorColumnEh }

constructor TDataGridIndicatorColumnEh.Create(AGrid: TControl);
begin
  inherited Create(AGrid);
  SetSubComponent(True);
  Name := 'IndicatorColumn';
  FGrid := AGrid;
  FVisible := True;
  FShowRecNo := True;
  FRecNoShowStep := 10;
  FShowEditIndicator := True;
  FInternalDefCellManager := TDataGridIndicatorCellManagerEh.Create(nil);
  FDefaultCellManager := FInternalDefCellManager;
end;

destructor TDataGridIndicatorColumnEh.Destroy;
begin
  FreeAndNil(FInternalDefCellManager);
  inherited Destroy;
end;

procedure TDataGridIndicatorColumnEh.Changed;
begin
  if (Grid <> nil) then
    Grid.LayoutChanged;
end;

{$REGION HorzLinesColor}
function TDataGridIndicatorColumnEh.GetHorzLinesColor: TAlphaColor;
begin
  if HorzLinesColorStored
    then Result := FHorzLinesColor
    else Result := DefaultHorzLinesColor();
end;

procedure TDataGridIndicatorColumnEh.SetHorzLinesColor(const Value: TAlphaColor);
begin
  if (FHorzLinesColor <> Value) or (FHorzLinesColorStored = False) then
  begin
    FHorzLinesColor := Value;
    FHorzLinesColorStored := True;
    Changed;
  end;
end;

function TDataGridIndicatorColumnEh.IsHorzLinesColorStored: Boolean;
begin
  Result := FHorzLinesColorStored;
end;

procedure TDataGridIndicatorColumnEh.SetHorzLinesColorStored(const Value: Boolean);
begin
  if FHorzLinesColorStored <> Value then
  begin
    FHorzLinesColorStored := Value;
    if FHorzLinesColorStored then
      FHorzLinesColor := DefaultHorzLinesColor;
    Changed;
  end;
end;

function TDataGridIndicatorColumnEh.DefaultHorzLinesColor(): TAlphaColor;
begin
  Result := Grid.GridLineOptions.DarkColor;
end;
{$ENDREGION HorzLinesColor}

{$REGION HorzLinesVisible}
function TDataGridIndicatorColumnEh.GetHorzLinesVisible: Boolean;
begin
  if HorzLinesVisibleStored
    then Result := FHorzLines
    else Result := DefaultHorzLinesVisible;
end;

procedure TDataGridIndicatorColumnEh.SetHorzLinesVisible(const Value: Boolean);
begin
  if HorzLinesVisibleStored and (Value = FHorzLines) then Exit;
  HorzLinesVisibleStored := True;
  FHorzLines := Value;
  Grid.Invalidate;
end;

function TDataGridIndicatorColumnEh.IsHorzLinesVisibleStored: Boolean;
begin
  Result := FHorzLinesStored;
end;

procedure TDataGridIndicatorColumnEh.SetHorzLinesVisibleStored(const Value: Boolean);
begin
  if (Value = True) and (IsHorzLinesVisibleStored = False) then
  begin
    FHorzLinesStored := True;
    FHorzLines := DefaultHorzLinesVisible;
    Grid.Invalidate;
  end else if (Value = False) and (IsHorzLinesVisibleStored = True) then
  begin
    FHorzLinesStored := False;
    FHorzLines := DefaultHorzLinesVisible;
    Grid.Invalidate;
  end;
end;

function TDataGridIndicatorColumnEh.DefaultHorzLinesVisible: Boolean;
begin
  Result := TCustomDataGridEhCrack(FGrid).GridLineOptions.HorzLinesVisible;
end;
{$ENDREGION HorzLinesVisible}

{$REGION VertLinesColor}
function TDataGridIndicatorColumnEh.GetVertLinesColor: TAlphaColor;
begin
  if VertLinesColorStored
    then Result := FVertLinesColor
    else Result := DefaultVertLinesColor();
end;

procedure TDataGridIndicatorColumnEh.SetVertLinesColor(const Value: TAlphaColor);
begin
  if (FVertLinesColor <> Value) or (FVertLinesColorStored = False) then
  begin
    FVertLinesColor := Value;
    FVertLinesColorStored := True;
    Changed;
  end;
end;

function TDataGridIndicatorColumnEh.IsVertLinesColorStored: Boolean;
begin
  Result := FVertLinesColorStored;
end;

procedure TDataGridIndicatorColumnEh.SetVertLinesColorStored(const Value: Boolean);
begin
  if FVertLinesColorStored <> Value then
  begin
    FVertLinesColorStored := Value;
    if FVertLinesColorStored then
      FVertLinesColor := DefaultVertLinesColor;
    Changed;
  end;
end;

function TDataGridIndicatorColumnEh.DefaultVertLinesColor(): TAlphaColor;
begin
  Result := Grid.GridLineOptions.DarkColor;
end;
{$ENDREGION VertLinesColor}

{$REGION VertLinesVisible}
function TDataGridIndicatorColumnEh.GetVertLinesVisible: Boolean;
begin
  if VertLinesVisibleStored
    then Result := FVertLines
    else Result := DefaultVertLinesVisible;
end;

procedure TDataGridIndicatorColumnEh.SetVertLinesVisible(const Value: Boolean);
begin
  if VertLinesVisibleStored and (Value = FVertLines) then Exit;
  VertLinesVisibleStored := True;
  FVertLines := Value;
  Grid.Invalidate;
end;

function TDataGridIndicatorColumnEh.IsVertLinesVisibleStored: Boolean;
begin
  Result := FVertLinesStored;
end;

procedure TDataGridIndicatorColumnEh.SetVertLinesVisibleStored(const Value: Boolean);
begin
  if (Value = True) and (IsVertLinesVisibleStored = False) then
  begin
    FVertLinesStored := True;
    FVertLines := DefaultVertLinesVisible;
    Grid.Invalidate;
  end else if (Value = False) and (IsVertLinesVisibleStored = True) then
  begin
    FVertLinesStored := False;
    FVertLines := DefaultVertLinesVisible;
    Grid.Invalidate;
  end;
end;

function TDataGridIndicatorColumnEh.DefaultVertLinesVisible: Boolean;
begin
  Result := True;
end;
{$ENDREGION VertLinesVisible}

procedure TDataGridIndicatorColumnEh.SetVisible(const Value: Boolean);
begin
  if(FVisible <> Value) then
  begin
    FVisible := Value;
    SetWidthRecalcNeeded();
  end;
end;

procedure TDataGridIndicatorColumnEh.SetShowEditIndicator(const Value: Boolean);
begin
  if (FShowEditIndicator <> Value) then
  begin
    FShowEditIndicator := Value;
    SetWidthRecalcNeeded();
  end;
end;

procedure TDataGridIndicatorColumnEh.SetShowRecNo(const Value: Boolean);
begin
  if FShowRecNo <> Value then
  begin
    FShowRecNo := Value;
    SetWidthRecalcNeeded();
  end;
end;

procedure TDataGridIndicatorColumnEh.SetRecNoShowStep(const Value: Integer);
begin
  if FRecNoShowStep <> Value then
  begin
    FRecNoShowStep := Value;
    SetWidthRecalcNeeded();
  end;
end;

function TDataGridIndicatorColumnEh.DefaultCalcColumnWidth: Integer;
var
  Width: Single;
  AGrid: TCustomDataGridEhCrack;
  CellLaObject: TVPBaseCellHolderEh;
  QrCellSize: TSizeF;
  ResCellSize: TSizeF;
  AreaColIndex, AreaRowIndex: Integer;
  ACellManager: TVPBaseCellManagerEh;
begin

  AGrid := TCustomDataGridEhCrack(Grid);

  if (AGrid.Canvas = nil) or (Grid.HFixedVDataPanel = nil) then
  begin
    Result := 11;
    Exit;
  end;

  AreaColIndex := 0;
  AreaRowIndex := -1;

  QrCellSize := TSizeF.Create(0, TLaControlEh.MaxSize.Height);
  ACellManager := Grid.HFixedVDataPanel.GetCellManagerAt(AreaColIndex, AreaRowIndex);
  CellLaObject := ACellManager.CreateCellHolder;
  try
    Grid.GridColRowToLocalColRowIndex(0, AGrid.RowCount - 1, AreaColIndex, AreaRowIndex);

    ResCellSize := ACellManager.InitAndCaclRenderCellHolder(
      Grid, QrCellSize, CellLaObject, 0, AGrid.RowCount - 1, AreaColIndex, AreaRowIndex);
    Width := ResCellSize.Width;
  finally
    CellLaObject.Free;
  end;

  Result := Round(Width);
end;

function TDataGridIndicatorColumnEh.CalcColumnWidth(): Integer;
var
  CalcParams: TDataGridIndicatorColumnCalcWidthParamsEh;
begin
  if FWidthRecalcNeeded = False then
  begin
    Result := FCalculatedWidth;
    Exit;
  end;

  CalcParams := TDataGridIndicatorColumnCalcWidthParamsEh.Create;
  CalcParams.Init(Grid);
  HandleCalcColumnWidth(CalcParams);
  if CalcParams.Handled = True
    then Result := CalcParams.Width
    else Result := DefaultCalcColumnWidth();
  CalcParams.Free;

  FCalculatedWidth := Result;
  FWidthRecalcNeeded := False;
end;

procedure TDataGridIndicatorColumnEh.HandleCalcColumnWidth(Params: TDataGridIndicatorColumnCalcWidthParamsEh);
begin
  if Assigned(OnCalcColumnWidth) then
    OnCalcColumnWidth(Self, Params);
end;

function TDataGridIndicatorColumnEh.GetRecNoText(ADataRowIndex: Integer): String;
var
  ARecNo: Integer;
begin
  Result := '';
  if (not Grid.TableView.Active) then Exit;

  ARecNo := ADataRowIndex + 1;

  if (ARecNo mod Grid.IndicatorColumn.RecNoShowStep = 0) or
     (ARecNo = 1) or
     (ARecNo = Grid.DataRowCount) or
     (ADataRowIndex = Grid.CurRowIndex - Grid.GetTitleRows)
  then
    Result := IntToStr(ARecNo)
  else if (Grid.IndicatorColumn.RecNoShowStep mod 2 = 0) and
          ((ARecNo mod Grid.IndicatorColumn.RecNoShowStep) = (Grid.IndicatorColumn.RecNoShowStep div 2)) then
    Result := '-'
  else
    Result := MiddleDotChar();
end;

function TDataGridIndicatorColumnEh.GetRowEditState(ARow: TDataGridRowEh): TDataGridRowEditStateEh;
var
  DSState: TRowLinkEditStateEh;
  SourceRowView: TTableRowLinkEh;
begin
  Result := TDataGridRowEditStateEh.Unassigned;
  if (ARow = nil) then Exit;

  if ARow is TDataGridDataRowEh then
  begin
    SourceRowView := TDataGridDataRowEh(ARow).TableRow.SourceRowLink;
    if (ARow = Grid.CurrentRow) then
    begin
      DSState := SourceRowView.EditState;
      if (DSState = TRowLinkEditStateEh.Edit) then
        Result := TDataGridRowEditStateEh.Edit
      else if (DSState = TRowLinkEditStateEh.Insert) then
        Result := TDataGridRowEditStateEh.New
      else
        Result := TDataGridRowEditStateEh.Browse;
    end;
  end;
end;

function TDataGridIndicatorColumnEh.GetCellManagerAt(ALocalColIndex, ALocalRowIndex: Integer): TBaseGridCellManagerEh;
var
  GetCellManagerParams: TDataGridIndicatorColumnGetCellManagerParamsEh;
  Grid: TCustomDataGridEhCrack;
  ADefaultCellManager: TBaseGridCellManagerEh;
  Row: TDataGridRowEh;
begin
  Grid := TCustomDataGridEhCrack(Self.Grid);
  if (ALocalRowIndex >= 0) and (ALocalRowIndex < TCustomDataGridEhCrack(Grid).VisibleRows.Count)
    then Row := TCustomDataGridEhCrack(Grid).VisibleRows[ALocalRowIndex]
    else Row := nil;
  ADefaultCellManager := GetDefaultCellManagerAt(ALocalColIndex, ALocalRowIndex);
  GetCellManagerParams := CreateGetCellManagerParams();
  GetCellManagerParams.Init(Grid, Row, ADefaultCellManager);
  ProcessGetCellManager(GetCellManagerParams);
  Result := GetCellManagerParams.CellManager;
  GetCellManagerParams.Free;
end;

function TDataGridIndicatorColumnEh.CreateGetCellManagerParams: TDataGridIndicatorColumnGetCellManagerParamsEh;
begin
  Result := TDataGridIndicatorColumnGetCellManagerParamsEh.Create;
end;

procedure TDataGridIndicatorColumnEh.ProcessGetCellManager(Params: TDataGridIndicatorColumnGetCellManagerParamsEh);
begin
  HandleGetCellManager(Params);
end;

procedure TDataGridIndicatorColumnEh.HandleCreateCellContent(Params: TDataGridIndicatorColumnCreateCellContentParamsEh);
begin
  if Assigned(OnCreateCellContent) then
    OnCreateCellContent(Self, Params);
end;

procedure TDataGridIndicatorColumnEh.HandleGetCellManager(Params: TDataGridIndicatorColumnGetCellManagerParamsEh);
begin
  if Assigned(OnGetCellManager) then
    OnGetCellManager(Self, Params);
end;

function TDataGridIndicatorColumnEh.GetDefaultCellManagerAt(ALocalColIndex, ALocalRowIndex: Integer): TBaseGridCellManagerEh;
begin
  Result := DefaultCellManager;
end;

procedure TDataGridIndicatorColumnEh.SetDefaultCellManager(const Value: TBaseGridCellManagerEh);
begin
  if FDefaultCellManager <> Value then
  begin
    FDefaultCellManager := Value;
    if FDefaultCellManager = nil then
      FDefaultCellManager := FInternalDefCellManager;
    Changed;
  end;
end;

procedure TDataGridIndicatorColumnEh.HandleInitCellContent(Params: TDataGridIndicatorColumnInitCellContentParamsEh);
begin
  if Assigned(OnCellInitContent) then
    OnCellInitContent(Self, Params);
end;

procedure TDataGridIndicatorColumnEh.SetWidthRecalcNeeded;
begin
  FWidthRecalcNeeded := True;
  Grid.LayoutChanged();
end;
{$ENDREGION 'TDataGridIndicatorColumnEh'}

{ TDataGridIndicatorCellEh }

constructor TDataGridIndicatorCellEh.Create(ACellHolder: TGridBaseCellHolderEh);
begin
  inherited Create(ACellHolder);
  HitTest := True;
end;

destructor TDataGridIndicatorCellEh.Destroy;
begin
  inherited Destroy;
end;

procedure TDataGridIndicatorCellEh.CreateControls;
begin
  inherited CreateControls;
end;

function TDataGridIndicatorCellEh.CreateDefaultCellContentControls(AParentObject: TLaObjectEh): TLaObjectEh;
begin
  Result := TDataGridIndicatorCellManagerEh(CellManager).DefaultCreateContentControls(Self, AParentObject);
end;

procedure TDataGridIndicatorCellEh.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TDataGridIndicatorCellEh.ProcessMouseDown(Params: TControlMouseButtonParamsEh);
var
  AGrid: TCustomDataGridEhCrack;
begin
  inherited ProcessMouseDown(Params);

  AGrid := TCustomDataGridEhCrack(Grid);

  if AGrid.TableView.Active then
  begin
    AGrid.CheckHideEditor;

    if AGrid.CanSelectType(TDataGridSelectionTypeEh.RecordBookmarks) and
      (Params.Button = TMouseButton.mbLeft) then
    begin
      AGrid.Capture;
      AGrid.StartRowSelection(RowIndex, Params.Shift);
    end;
  end;
end;

procedure TDataGridIndicatorCellEh.MouseClick(Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  inherited MouseClick(Button, Shift, X, Y);
end;

{ TDataGridIndicatorCellContentEh }

constructor TDataGridIndicatorCellContentEh.Create(ACell: TGridBaseCellEh; AParentObject: TLaObjectEh);
begin
  inherited Create(ACell);
  Parent := AParentObject;

  begin
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

    
    with TLaLayoutPanelEh.CreateWith(Self, RefSelf) do
    begin
      FTextArea := TLaLayoutPanelEh(RefSelf);
      ControlCollection.AddControl(RefSelf, 0, -1);

      FTextBlock := TLaTextBlockEh.CreateWith(Self, RefSelf);
      FTextBlock.Padding.Rect := RectF(2, 0, 2, 1);
      FTextBlock.VertAlignment := TLaVertAlignmentEh.Center;
      FTextBlock.HorzAlignment := TLaHorzAlignmentEh.Center;
      FTextBlock.Text := '1'
    end;

    
    with TLaLayoutPanelEh.CreateWith(Self, RefSelf) do
    begin
      FEditStateArea := TLaLayoutPanelEh(RefSelf);
      ControlCollection.AddControl(RefSelf, 1, -1);
      Margins.Rect := TRectF.Create(2, 1, 2, 1);
      VertAlignment := TLaVertAlignmentEh.Center;
      Width := 10;
      Height := 18;

      with TLaControlsGenericHelper.CreateControlWith<TImage>(Self, RefSelf) do
      begin
        WrapMode := TImageWrapMode.Place;
        MultiResBitmap := nil;
        HitTest := False;
        Locked := True;
        FEditStateImage := TImage(RefSelf);
        //Size.DefaultValue := TSize
      end;
    end;
  end;
end;

destructor TDataGridIndicatorCellContentEh.Destroy;
begin
  inherited Destroy;
end;

function TDataGridIndicatorCellContentEh.GetText: String;
begin
  Result := FTextBlock.Text;
end;

procedure TDataGridIndicatorCellContentEh.SetText(const Value: String);
begin
  FTextBlock.Text := Value;
end;

procedure TDataGridIndicatorCellContentEh.SetEditState(const Value: TDataGridRowEditStateEh);
begin
  if FEditState <> Value then
  begin
    FEditState := Value;
    if FEditState = TDataGridRowEditStateEh.Unassigned then
      FEditStateImage.MultiResBitmap := nil
    else if FEditState = TDataGridRowEditStateEh.Browse then
      FEditStateImage.MultiResBitmap := EhLibImageResources.GridCurrentRowSign
    else if FEditState = TDataGridRowEditStateEh.Edit then
      FEditStateImage.MultiResBitmap := EhLibImageResources.GridEditRowSign
    else if FEditState = TDataGridRowEditStateEh.New then
      FEditStateImage.MultiResBitmap := EhLibImageResources.GridNewRowSign;
  end;
end;

function TDataGridIndicatorCellContentEh.GetTextAreaVisible: Boolean;
begin
  Result := FTextArea.Visible;
end;

procedure TDataGridIndicatorCellContentEh.SetTextAreaVisible(const Value: Boolean);
begin
  FTextArea.Visible := Value;
end;

function TDataGridIndicatorCellContentEh.GetEditStateAreaVisible: Boolean;
begin
  Result := FEditStateArea.Visible;
end;

procedure TDataGridIndicatorCellContentEh.SetEditStateAreaVisible(const Value: Boolean);
begin
  FEditStateArea.Visible := Value;
end;

{ TDataGridIndicatorCellManagerEh }

function TDataGridIndicatorCellManagerEh.CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh;
begin
  Result := TDataGridIndicatorCellEh.Create(ACellHolder);
end;

function TDataGridIndicatorCellManagerEh.CreateInitCellParams: TBaseGridInitCellParamsEh;
begin
  Result := TDataGridIndicatorColumnInitCellParamsEh.Create;
end;

function TDataGridIndicatorCellManagerEh.CreateCellContentParams(): TBaseGridCreateCellContentParamsEh;
begin
  Result := TDataGridIndicatorColumnCreateCellContentParamsEh.Create;
end;

function TDataGridIndicatorCellManagerEh.DefaultCreateContentControls(ACell: TGridBaseCellEh; AParentObject: TLaObjectEh): TLaControlEh;
begin
  Result := TDataGridIndicatorCellContentEh.Create(ACell, AParentObject);
end;

procedure TDataGridIndicatorCellManagerEh.DefaultInitCellProps(Params: TBaseGridInitCellParamsEh);
begin
  inherited DefaultInitCellProps(Params);
end;

function TDataGridIndicatorCellManagerEh.GetBackgroundStyle(AParams: TBaseGridInitCellParamsEh): TControl;
var
  VGrid: TCustomDataGridEhCrack;
begin
  VGrid := TCustomDataGridEhCrack(AParams.Grid);
  Result := VGrid.StylePainter.TopFixedCellBackground;
end;

function TDataGridIndicatorCellManagerEh.CreateInitCellContentParams: TBaseGridInitCellContentParamsEh;
begin
  Result := TDataGridIndicatorColumnInitCellContentParamsEh.Create;
end;

procedure TDataGridIndicatorCellManagerEh.HandleCreateCustomCellContent(Params: TBaseGridCreateCellContentParamsEh);
var
  VGrid: TCustomDataGridEhCrack;
begin
  VGrid := TCustomDataGridEhCrack(Params.Cell.Grid);
  VGrid.IndicatorColumn.HandleCreateCellContent(TDataGridIndicatorColumnCreateCellContentParamsEh(Params));
end;

procedure TDataGridIndicatorCellManagerEh.HandleInitCellContent(Params: TBaseGridInitCellContentParamsEh);
var
  IndicatorColumnParams: TDataGridIndicatorColumnInitCellContentParamsEh;
begin
  IndicatorColumnParams := TDataGridIndicatorColumnInitCellContentParamsEh(Params);
  TCustomDataGridEhCrack(Params.Grid).IndicatorColumn.HandleInitCellContent(IndicatorColumnParams);
end;

procedure TDataGridIndicatorCellManagerEh.DefaultInitCellContent(Params: TBaseGridInitCellContentParamsEh);
var
  CellContent: TDataGridIndicatorCellContentEh;
  VGrid: TCustomDataGridEhCrack;
  IndicatorColumnParams: TDataGridIndicatorColumnInitCellContentParamsEh;
begin
  if Params.CellContent is TDataGridIndicatorCellContentEh then
  begin
    VGrid := TCustomDataGridEhCrack(Params.Grid);
    CellContent := TDataGridIndicatorCellContentEh(Params.CellContent);
    IndicatorColumnParams := TDataGridIndicatorColumnInitCellContentParamsEh(Params);

    if (IndicatorColumnParams.Row <> nil) then
    begin
      try
        CellContent.EditState := VGrid.IndicatorColumn.GetRowEditState(IndicatorColumnParams.Row);
        CellContent.Text := VGrid.IndicatorColumn.GetRecNoText(Params.Cell.AreaRowIndex);
        CellContent.TextBlock.Font.Size := VGrid.Font.Size * 0.85;
        CellContent.TextBlock.FontColor := VGrid.FInternalFontColor;
        CellContent.TextAreaVisible := VGrid.IndicatorColumn.ShowRecNo;
        CellContent.EditStateAreaVisible := VGrid.IndicatorColumn.ShowEditIndicator;
      finally
      end;
    end else
    begin
      CellContent.EditState := TDataGridRowEditStateEh.Unassigned;
      CellContent.Text := '';
    end;
  end;
end;

procedure TDataGridIndicatorCellManagerEh.InitCellPositionProps(ACell: TGridBaseCellEh);
var
  VGrid: TCustomDataGridEhCrack;
  VDCell: TDataGridIndicatorCellEh;
begin
  inherited InitCellPositionProps(ACell);

  VGrid := TCustomDataGridEhCrack(ACell.Grid);
  VDCell := TDataGridIndicatorCellEh(ACell);
  if (ACell.AreaRowIndex >= 0) and (ACell.AreaRowIndex < VGrid.VisibleRows.Count)
    then VDCell.FRow := VGrid.VisibleRows[ACell.AreaRowIndex]
    else VDCell.FRow := nil;
end;

function TDataGridIndicatorCellManagerEh.IsShowSelectionLayer(AGrid: TControl;
  ACell: TGridBaseCellEh): Boolean;
var
  VDCell: TDataGridIndicatorCellEh;
  VGrid: TCustomDataGridEhCrack;
begin
  if ACell is TDataGridIndicatorCellEh then
  begin
    VDCell := TDataGridIndicatorCellEh(ACell);
    VGrid := TCustomDataGridEhCrack(ACell.Grid);
    if (VDCell.Row <> nil) then
      Result := VGrid.Selection.IsRowInSelection(VDCell.Row)
    else
      Result := False;
  end else
    Result := False;
end;

{ TDataGridIndicatorColumnGetCellManagerParamsEh }

procedure TDataGridIndicatorColumnGetCellManagerParamsEh.Init(AGrid: TControl; ARow: TDataGridRowEh;
  ADefaultCellManager: TBaseGridCellManagerEh);
begin
  FGrid := AGrid;
  FRow := ARow;
  FCellManager := ADefaultCellManager;
end;

{ TDataGridIndicatorColumnInitCellParamsEh }

procedure TDataGridIndicatorColumnInitCellParamsEh.Init(AGrid: TControl; ACellManager: TBaseGridCellManagerEh; ACell: TGridBaseCellEh);
var
  Grid: TCustomDataGridEhCrack;
begin
  inherited Init(AGrid, ACellManager, ACell);

  Grid := TCustomDataGridEhCrack(AGrid);
  if (ACell.AreaRowIndex >= 0) and (ACell.AreaRowIndex < Grid.VisibleRows.Count)
    then FRow := Grid.VisibleRows[ACell.AreaRowIndex]
    else FRow := nil;
end;

procedure TDataGridIndicatorColumnInitCellParamsEh.DefaultInitCell;
begin

end;

{ TDataGridIndicatorColumnInitCellContentParamsEh }

procedure TDataGridIndicatorColumnInitCellContentParamsEh.Init(ACell: TGridBaseCellEh; ACellContent: TLaObjectEh; InitCellParams: TBaseGridInitCellParamsEh);
var
  Grid: TCustomDataGridEhCrack;
begin
  inherited Init(ACell, ACellContent, InitCellParams);

  Grid := TCustomDataGridEhCrack(ACell.Grid);
  if (ACell.AreaRowIndex >= 0) and (ACell.AreaRowIndex < Grid.VisibleRows.Count)
    then FRow := Grid.VisibleRows[ACell.AreaRowIndex]
    else FRow := nil;
end;

{ TDataGridCalcIndicatorCalcColumnWidthParamsEh }

function TDataGridIndicatorColumnCalcWidthParamsEh.DefaultCalcColumnWidth: Integer;
begin
  Result := IndicatorColumn.DefaultCalcColumnWidth;
end;

function TDataGridIndicatorColumnCalcWidthParamsEh.GetIndicatorColumn: TDataGridIndicatorColumnEh;
var
  VGrid: TCustomDataGridEhCrack;
begin
  VGrid := TCustomDataGridEhCrack(FGrid);
  Result := VGrid.IndicatorColumn;
end;

procedure TDataGridIndicatorColumnCalcWidthParamsEh.Init(AGrid: TControl);
begin
  FGrid := AGrid;
  FWidth := 0;
  FHandled := False;
end;

end.
