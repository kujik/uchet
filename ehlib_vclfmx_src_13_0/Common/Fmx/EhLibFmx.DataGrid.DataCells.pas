{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{             EhLibFmx.DataGrid.DataCells               }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataGrid.DataCells;

interface

{$SCOPEDENUMS ON}

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, System.Types,
  System.Variants, Data.DB, TypInfo,
  System.Generics.Collections, Rtti,
  FMX.Graphics, System.UITypes, FMX.StdCtrls, FMX.TextLayout, FMX.ImgList,
  FMX.Objects,
  EhLibUtils, DBUtilsEh,
  EhLibFmx.ToolControls,
  EhLibFmx.ImageReses,

  EhLibFmx.Grids,
  EhLibFmx.Grid.Types,
  EhLibFmx.Grid.CellManagers,
  EhLibFmx.Grid.InplaceEditors,

  EhLibFmx.DataAxisGrids,
  EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.DataAxisGrid.DataCells,

  EhLibFmx.DataGrid.Columns,
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
  TRowBandContainerManagerEh = class;

{ TDataGridDataVirtualPanelEh }

  TDataGridDataVirtualPanelEh = class(TDataGridVirtualPanelEh)
  private
    FContainerManager: TRowBandContainerManagerEh;
  protected
  public
    function GetContainerManager: TRowBandContainerManagerEh;
    function GetCellRect(StartColPos, StartRowPos: Single; AColIndex, ARowIndex: Integer): TRectF; override;
    function GetCellManagerAt(AColIndex, ARowIndex: Integer): TVPBaseCellManagerEh; override;
    function CreateBaseCellManager: TVPBaseCellManagerEh; override;
  end;

{ TDataGridDataRowBandManagerEh }

  TDataGridDataRowBandManagerEh = class(TDataAxisCellManagerEh)
  public
    function CreateCellHolder(): TVPBaseCellHolderEh; override;
    function CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh; override;

    procedure DefaultInitCellProps(Params: TBaseGridInitCellParamsEh); override;
    procedure DefaultInitCellContent(Params: TDataAxisInitCellContentParamsEh); override;
  end;

{ TDataGridDataRowBandEh }

  TDataGridDataRowBandEh = class(TDataAxisCellEh)
  private
    function GetRow: TDataGridDataRowEh;

  public
    constructor Create(ACellHolder: TGridBaseCellHolderEh);
    destructor Destroy; override;

    property Row: TDataGridDataRowEh read GetRow;
  end;

{ TRowBandContainerManagerEh }

  TRowBandContainerManagerEh = class(TVPBaseCellManagerEh)
  private
    FContentCellManager: TVPBaseCellManagerEh;

  protected
    procedure InitCellHolderPositionProps(ACellHolder: TVPBaseCellHolderEh); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function CreateCellHolder(): TVPBaseCellHolderEh; override;
    procedure InitCellHolder(ACellHolder: TVPBaseCellHolderEh); override;

    property ContentCellManager: TVPBaseCellManagerEh read FContentCellManager write FContentCellManager;
  end;

{ TVPCellHolderContainerEh }

  TVPCellHolderContainerEh = class(TVPBaseCellHolderEh)
  private
    FCellContentHolder: TVPBaseCellHolderEh;
  protected
    procedure CreateControls(AParent: TLaObjectEh); override;
    property CellContentHolder: TVPBaseCellHolderEh read FCellContentHolder;
  end;

implementation

uses EhLibFmx.CustomDataGrids,
     EhLibFmx.DataGrids;

type
  TCustomDataGridEhCrack = class(TCustomDataGridEh);
  TVPBaseCellHolderEhCrack = class(TVPBaseCellHolderEh);
  TVPBaseCellManagerEhCrack = class(TVPBaseCellManagerEh);

function TDataGridDataVirtualPanelEh.CreateBaseCellManager: TVPBaseCellManagerEh;
begin
  Result := TDataAxisCellManagerEh.Create(nil);
end;

{ TDataGridDataVirtualPanelEh }

function TDataGridDataVirtualPanelEh.GetCellManagerAt(AColIndex, ARowIndex: Integer): TVPBaseCellManagerEh;
begin
  Result := inherited GetCellManagerAt(AColIndex, ARowIndex);
end;

function TDataGridDataVirtualPanelEh.GetCellRect(StartColPos, StartRowPos: Single; AColIndex, ARowIndex: Integer): TRectF;
var
  VGrid: TCustomDataGridEhCrack;
  Row: TDataGridRowEh;
  RowSplitWay: TDataGridRowSplitWayEh;
  I: Integer;
  ResultBottom: Single;
  StartCellLeftMargin: Single;
begin
  VGrid := TCustomDataGridEhCrack(Owner);

  if ARowIndex < VGrid.VisibleRows.Count
    then Row := VGrid.VisibleRows[ARowIndex]
    else Row := nil;

  if Row <> nil then
    RowSplitWay := VGrid.GetRowSplitWay(Row)
  else
    RowSplitWay := TDataGridRowSplitWayEh.SplitByCell;

  if RowSplitWay = TDataGridRowSplitWayEh.NoSplit then
  begin
    StartCellLeftMargin := 0;
    for I := 0 to AColIndex - 1 do
      StartCellLeftMargin := StartCellLeftMargin - ColWidth[I];

    ResultBottom := StartRowPos + RowHeight[ARowIndex];
    Result := TRectF.Create(0, StartRowPos, 0, ResultBottom);
    for I := 0 to ColCount - 1 do
      Result.Width := Result.Width + ColWidth[I];
    Result.Offset(StartColPos + StartCellLeftMargin, 0);
  end else
  begin
    Result := inherited GetCellRect(StartColPos, StartRowPos, AColIndex, ARowIndex);
  end;
end;

function TDataGridDataVirtualPanelEh.GetContainerManager: TRowBandContainerManagerEh;
begin
  if FContainerManager = nil then
    FContainerManager := TRowBandContainerManagerEh.Create(Self);
  Result := FContainerManager;
end;

{ TRowCellManagerEh }

function TDataGridDataRowBandManagerEh.CreateCellHolder: TVPBaseCellHolderEh;
begin
  Result := inherited CreateCellHolder();
end;

function TDataGridDataRowBandManagerEh.CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh;
begin
  Result := TDataGridDataRowBandEh.Create(ACellHolder);
end;

procedure TDataGridDataRowBandManagerEh.DefaultInitCellContent(Params: TDataAxisInitCellContentParamsEh);
var
  TextBlock: TLaTextBlockEh;
begin
  if Params.CellContent is TLaTextBlockEh then
  begin
    TextBlock := TLaTextBlockEh(Params.CellContent);
    TextBlock.Text := 'RowCell.Text';
    TextBlock.Margins.Rect := TRectF.Create(2, 2, 2, 6);
  end;
end;

procedure TDataGridDataRowBandManagerEh.DefaultInitCellProps(Params: TBaseGridInitCellParamsEh);
begin
  inherited DefaultInitCellProps(Params);
end;

{ TRowBandContainerManagerEh }

constructor TRowBandContainerManagerEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TRowBandContainerManagerEh.Destroy;
begin
  inherited Destroy;
end;

function TRowBandContainerManagerEh.CreateCellHolder: TVPBaseCellHolderEh;
begin
  Result := TVPCellHolderContainerEh.Create(nil, Self);
end;

procedure TRowBandContainerManagerEh.InitCellHolderPositionProps(ACellHolder: TVPBaseCellHolderEh);
begin
  inherited InitCellHolderPositionProps(ACellHolder);
end;

procedure TRowBandContainerManagerEh.InitCellHolder(ACellHolder: TVPBaseCellHolderEh);
var
  CellContentHolder: TVPBaseCellHolderEhCrack;
begin
  inherited InitCellHolder(ACellHolder);

  if ACellHolder is TVPCellHolderContainerEh then
  begin
    CellContentHolder := TVPBaseCellHolderEhCrack(TVPCellHolderContainerEh(ACellHolder).CellContentHolder);
    CellContentHolder.FGrid := ACellHolder.Grid;
    CellContentHolder.FColIndex := ACellHolder.ColIndex;
    CellContentHolder.FRowIndex := ACellHolder.RowIndex;
    CellContentHolder.FAreaColIndex := ACellHolder.AreaColIndex;
    CellContentHolder.FAreaRowIndex := ACellHolder.AreaRowIndex;
//  ADataCellHolder.FFieldBar := AFieldBar;
//  ADataCellHolder.FListItemBar := AListItemBar;

    TVPBaseCellManagerEhCrack(ContentCellManager).InitCellHolderPositionProps(CellContentHolder);
    ContentCellManager.InternalInitCellHolder(CellContentHolder);
  end;
end;

{ TVPCellHolderContainerEh }

procedure TVPCellHolderContainerEh.CreateControls(AParent: TLaObjectEh);
begin
  FCellContentHolder := TRowBandContainerManagerEh(CellManager).ContentCellManager.CreateCellHolder();
  FCellContentHolder.Parent := AParent;
  TVPBaseCellHolderEhCrack(FCellContentHolder).InitControls;
end;

{ TDataGridDataRowBandEh }

constructor TDataGridDataRowBandEh.Create(ACellHolder: TGridBaseCellHolderEh);
begin
  inherited Create(ACellHolder);
end;

destructor TDataGridDataRowBandEh.Destroy;
begin
  inherited Destroy;
end;

function TDataGridDataRowBandEh.GetRow: TDataGridDataRowEh;
begin
  Result := (ListItemBar as TDataGridTableRowEh).GridDataRow;
end;

end.

