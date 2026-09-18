unit SolutionFrame.ImageAndTextInCell;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Rtti,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  EhLibFmx.Api, EhLibUtils, DBUtilsEh,
  EhLibFmx.ToolControls, EhLibFmx.Grids, EhLibFmx.DataAxisGrids,
  EhLibFmx.CustomDataGrids, EhLibFmx.DataGrids, FMX.Controls.Presentation,
  EhLibFmx.DataAxisGrid.FieldBars, EhLibFmx.DataGrid.Columns;

type
  TfrImageAndTextInCell = class(TFrame)
    Panel1: TPanel;
    DataGridEh1: TDataGridEh;
    DataGridEh1OrderNoColumn1: TDataGridStringColumnEh;
    DataGridEh1CustNoColumn1: TDataGridStringColumnEh;
    DataGridEh1PaymentMethodColumn1: TDataGridStringColumnEh;
    DataGridLayoutColumnEh1: TDataGridLayoutColumnEh;
    Button1: TButton;
    procedure DataGridLayoutColumnEh1CreateDataCellContent(Sender: TObject;
      Params: TDataGridCreateDataCellContentParamsEh);
    procedure DataGridLayoutColumnEh1DataCellInitContent(Sender: TObject;
      Params: TDataGridInitDataCellContentParamsEh);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses DataModuleUnit;

{$R *.fmx}

constructor TfrImageAndTextInCell.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Button1Click(nil);
  Panel1.Visible := False;
end;

procedure TfrImageAndTextInCell.Button1Click(Sender: TObject);
begin
  DataGridEh1PaymentMethodColumn1.Title.FilterItem.SetExpression(
    TSTFilterOperatorEh.foNotEqual, 'Credit',
    TSTFilterOperatorEh.foNon,
    TSTFilterOperatorEh.foNon, TValue.Empty);
  DataGridEh1.Title.Filter.ApplyFilter();
end;

procedure TfrImageAndTextInCell.DataGridLayoutColumnEh1CreateDataCellContent(Sender: TObject;
  Params: TDataGridCreateDataCellContentParamsEh);
begin
  with TLaGridPanelEh.CreateWith(Params.ContentParent) do
  begin
    Params.CellContent := RefSelf as TLaControlEh;

    Margins.Rect := TRectF.Create(10, 0, 1, 0);

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Pixel;
      Value := 32;
    end;

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Weight;
      Value := 1;
    end;

    //Col1 Image
    with TLaImageEh.CreateWith(RefSelf, RefSelf) do
    begin
      ControlCollection.AddControl(RefSelf, 0, -1);
      Name := 'InCellImage';
      Width := 24;
      Height := 24;
      ImageList := DataModule1.imLstPaymentTypes;
      ImageIndex := 0;
      VertAlignment := TLaVertAlignmentEh.Center;
    end;

    //Col2 Text
    with TLaTextBlockEh.CreateWith(RefSelf, RefSelf) do
    begin
      ControlCollection.AddControl(RefSelf, 1, -1);
      Margins.Rect := RectF(2, 2, 2, 2);
      VertAlignment := TLaVertAlignmentEh.Center;
      HorzAlignment := TLaHorzAlignmentEh.Stretch;
      Text := '1';
      FieldName := 'PaymentMethod';
    end;
  end;
end;

procedure TfrImageAndTextInCell.DataGridLayoutColumnEh1DataCellInitContent(Sender: TObject;
  Params: TDataGridInitDataCellContentParamsEh);
var
  ContValue: TValue;
  ImageIndex: Integer;
  InCellImage: TLaImageEh;
begin
  if Params.CellContent = nil then Exit;

  ContValue := DataGridEh1PaymentMethodColumn1.GetRowValue(Params.Row);

  InCellImage := Params.CellContent.GetElementByName('InCellImage') as TLaImageEh;
  ImageIndex := DataModule1.GetImageIndexByPaymentMethod(ValueToString(ContValue));
  InCellImage.ImageIndex := ImageIndex;
end;

end.
