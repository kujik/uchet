unit SolutionFrame.ImageAndTextInCell2;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  EhLibFmx.Api, System.Rtti, EhLibUtils, DBUtilsEh,
  EhLibFmx.DataGrids, EhLibFmx.DataAxisGrid.FieldBars, EhLibFmx.DataGrid.Columns, EhLibFmx.ToolControls,
  CustomCells.ImageAndTextEdit, EhLibFmx.Grids, EhLibFmx.DataAxisGrids, EhLibFmx.CustomDataGrids,
  FMX.Controls.Presentation, EhLibFmx.CustomDataVertGrids,
  EhLibFmx.DataVertGrids, FMX.Layouts, EhLibFmx.DataVertGrid.Rows;

type
  TfrImageAndTextInCell2 = class(TFrame)
    Panel1: TPanel;
    Button1: TButton;
    Layout1: TLayout;
    DataGridEh1: TDataGridEh;
    DataGridEh1OrderNoColumn1: TDataGridStringColumnEh;
    DataGridEh1CustNoColumn1: TDataGridStringColumnEh;
    DataGridEh1PaymentMethodColumn1: TDataGridStringColumnEh;
    DataGridStringColumnEh1: TDataGridStringColumnEh;
    DataVertGridEh1: TDataVertGridEh;
    Splitter1: TSplitter;
    DataVertGridEh1OrderNoRow1: TDataVertGridStringRowEh;
    DataVertGridEh1CustNoRow1: TDataVertGridStringRowEh;
    DataVertGridEh1PaymentMethodRow1: TDataVertGridStringRowEh;
    DataVertGridStringRowEh1: TDataVertGridStringRowEh;
    procedure DataGridStringColumnEh1GetDataCellManager(Sender: TObject;
      Params: TDataGridGetDataCellManagerParamsEh);
    procedure Button1Click(Sender: TObject);
    procedure DataVertGridStringRowEh1GetDataCellManager(Sender: TObject;
      Params: TDataVertGridGetDataCellManagerParamsEh);
  private
    { Private declarations }
  public
    ImageTextCellMan: TDataAxisImageTextCellManagerEh;

    procedure InitImageTextCellContent(Sender: TObject; Params: TDataAxisInitCellContentParamsEh);
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses DataModuleUnit;

{$R *.fmx}

procedure TfrImageAndTextInCell2.Button1Click(Sender: TObject);
begin
  DataGridEh1PaymentMethodColumn1.Title.FilterItem.SetExpression(
    TSTFilterOperatorEh.foNotEqual, 'Credit',
    TSTFilterOperatorEh.foNon,
    TSTFilterOperatorEh.foNon, TValue.Empty);
  DataGridEh1.Title.Filter.ApplyFilter();
end;

constructor TfrImageAndTextInCell2.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  ImageTextCellMan := TDataAxisImageTextCellManagerEh.Create(Self);
  ImageTextCellMan.OnInitCellContent := InitImageTextCellContent;

  Button1Click(nil);
  Panel1.Visible := False;
end;

procedure TfrImageAndTextInCell2.DataGridStringColumnEh1GetDataCellManager(Sender: TObject;
  Params: TDataGridGetDataCellManagerParamsEh);
begin
  Params.CellManager := ImageTextCellMan;
end;

procedure TfrImageAndTextInCell2.DataVertGridStringRowEh1GetDataCellManager(
  Sender: TObject; Params: TDataVertGridGetDataCellManagerParamsEh);
begin
  Params.CellManager := ImageTextCellMan;
end;

procedure TfrImageAndTextInCell2.InitImageTextCellContent(Sender: TObject;
  Params: TDataAxisInitCellContentParamsEh);
var
  ContValue: TValue;
  ImageIndex: Integer;
  InCellImage: TLaImageEh;
begin
  if Params.CellContent = nil then Exit;
  if Params.ListItemBar = nil then Exit;

  ContValue := Params.ListItemBar.SourceRowLink.FieldValue[DataGridEh1PaymentMethodColumn1.Field];

  InCellImage := (Params.Cell as TDataAxisImageTextCellEh).InCellImage;
  ImageIndex := DataModule1.GetImageIndexByPaymentMethod(ValueToString(ContValue));
  InCellImage.ImageIndex := ImageIndex;
  InCellImage.ImageList := DataModule1.imLstPaymentTypes;
  InCellImage.Margins.Right := 8;
end;

end.
