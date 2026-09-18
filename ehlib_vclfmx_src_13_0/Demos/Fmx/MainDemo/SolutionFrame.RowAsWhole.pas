unit SolutionFrame.RowAsWhole;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  EhLibFmx.Api,
  EhLibFmx.DataAxisGrid.FieldBars, EhLibFmx.DataGrid.Columns, EhLibFmx.DataGrids, EhLibFmx.ToolControls,
  EhLibFmx.Grids, EhLibFmx.DataAxisGrids, EhLibFmx.CustomDataGrids, FMX.Controls.Presentation;

type
  TfrSolutionRowAsWhole = class(TFrame)
    Panel1: TPanel;
    DataGridEh1: TDataGridEh;
    DataGridEh1NameColumn1: TDataGridStringColumnEh;
    DataGridEh1CapitalColumn1: TDataGridStringColumnEh;
    DataGridEh1ContinentColumn1: TDataGridStringColumnEh;
    procedure DataGridEh1GetDataRowSplitWay(Sender: TObject; Params: TDataGridGetDataRowSplitWayParamsEh);
    procedure DataGridEh1GetDataRowManager(Sender: TObject; Params: TDataGridGetDataRowManagerParamsEh);
  private
    { Private declarations }
  public
    GridRowCellManager: TBaseGridCellManagerEh;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

{ TGroupRowCaptionCellManagerEh }

  TGroupRowCaptionCellManagerEh = class(TDataGridDataRowBandManagerEh)
  public
    procedure DefaultInitCellContent(Params: TDataAxisInitCellContentParamsEh); override;
  end;

implementation

uses DataModuleUnit;

{$R *.fmx}

{ TGroupRowCaptionCellManagerEh }

procedure TGroupRowCaptionCellManagerEh.DefaultInitCellContent(Params: TDataAxisInitCellContentParamsEh);
var
  GroupCaption: TListGroupCaption;
  TextBlock: TLaTextBlockEh;
begin
//  inherited DefaultInitCellContent(Params);
  GroupCaption := Params.ListItemBar.SourceObjectItem as TListGroupCaption;
  if Params.CellContent is TLaTextBlockEh then
  begin
    TextBlock := TLaTextBlockEh(Params.CellContent);
    TextBlock.Text := GroupCaption.Caption;
    TextBlock.Margins.Rect := TRectF.Create(2, 2, 2, 6);
    TextBlock.Font.Style := [TFontStyle.fsBold];
  end;
end;

{ TfrSolutionRowAsWhole }

constructor TfrSolutionRowAsWhole.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  DataGridEh1.ColumnOptions.HeightAutoExpand := True;

  GridRowCellManager := TGroupRowCaptionCellManagerEh.Create(Self);

  DataGridEh1.DataSource := DataModule1.GetCountriesGroupedAsList();
end;

destructor TfrSolutionRowAsWhole.Destroy;
begin
  inherited Destroy;
end;

procedure TfrSolutionRowAsWhole.DataGridEh1GetDataRowManager(Sender: TObject;
  Params: TDataGridGetDataRowManagerParamsEh);
begin
  Params.CellManager := GridRowCellManager;
end;

procedure TfrSolutionRowAsWhole.DataGridEh1GetDataRowSplitWay(Sender: TObject;
  Params: TDataGridGetDataRowSplitWayParamsEh);
var
  SourceListItem: TObject;
begin
  if Params.Row = nil then Exit;

  SourceListItem := Params.Row.SourceObjectItem;
  if SourceListItem is TListGroupCaption then
    Params.RowSplitWay := TDataGridRowSplitWayEh.NoSplit
  else
    Params.RowSplitWay := Params.DefaultGetRowSplitWay();
end;

end.
