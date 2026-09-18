unit SolutionFrame.GridThreeTextBlocksInCell;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, EhLibFmx.DataGrid.SearchPanels,
  EhLibUtils, Rtti,
  EhLibRtl.Api,
  EhLibFmx.Api,
  EhLibFmx.DataGrids, EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.DataGrid.Columns, EhLibFmx.ToolControls, EhLibFmx.Grids,
  EhLibFmx.DataAxisGrids, EhLibFmx.CustomDataGrids
  ;

type
  TfrSolGridThreeTextBlocksInCell = class(TFrame)
    DataGridEh1: TDataGridEh;
    DataGridEh1NameColumn1: TDataGridStringColumnEh;
    DataGridLayoutColumnEh1: TDataGridLayoutColumnEh;
    procedure DataGridLayoutColumnEh1CreateDataCellContent(Sender: TObject;
      Params: TDataGridCreateDataCellContentParamsEh);
    procedure DataGridLayoutColumnEh1DataCellInitContent(Sender: TObject; Params: TDataGridInitDataCellContentParamsEh);
    procedure DataGridEh1DataCellGetStyleParams(Sender: TObject; Params: TDataGridDataCellStyleParamsEh);
  private
    function GetHotColor(Percent: Double): TAlphaColor;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses DataModuleUnit;

{$R *.fmx}

var
  HotColors: array [0..5] of TAlphaColor;

constructor TfrSolGridThreeTextBlocksInCell.Create(AOwner: TComponent);
var
  Alpha: TAlphaColor;
begin
  inherited Create(AOwner);

  Alpha := TAlphaColor($8C000000);
  HotColors[0] := Alpha or $4FBF3F;
  HotColors[1] := Alpha or $7FBF3F;
  HotColors[2] := Alpha or $AFBF3F;
  HotColors[3] := Alpha or $BF9F3F;
  HotColors[4] := Alpha or $BF6F3F;
  HotColors[5] := Alpha or $BF3F3F;
end;

function TfrSolGridThreeTextBlocksInCell.GetHotColor(Percent: Double): TAlphaColor;
var
  ColIndex: Integer;
begin
  ColIndex := Round(Percent / 16.6666);
  if ColIndex < 0 then ColIndex := 0;
  if ColIndex > 5 then ColIndex := 5;
  Result := HotColors[ColIndex];
end;

procedure TfrSolGridThreeTextBlocksInCell.DataGridEh1DataCellGetStyleParams(Sender: TObject;
  Params: TDataGridDataCellStyleParamsEh);
begin
  if Params.DataRowIndex mod 2 = 1 then
    Params.Fill.Color := TAlphaColorRec.Whitesmoke;
end;

procedure TfrSolGridThreeTextBlocksInCell.DataGridLayoutColumnEh1CreateDataCellContent(Sender: TObject;
  Params: TDataGridCreateDataCellContentParamsEh);
begin
  with TLaStackPanelEh.CreateWith(Params.ContentParent) do
  begin
    Params.CellContent := RefSelf as TLaControlEh;

    Orientation := TLaOrientationEh.Horizontal;
    HorzAlignment := TLaHorzAlignmentEh.Center;
    VertAlignment := TLaVertAlignmentEh.Center;
    Font.Style := [TFontStyle.fsBold];

    with TLaTextBlockEh.CreateWith(RefSelf) do
    begin
      Margins.Rect := TRect.Create(2, 2, 2, 2);
      Padding.Rect := TRect.Create(4, 4, 4, 4);
      Fill.Color := HotColors[1];
      Fill.Kind := TBrushKind.Solid;
//      Borders.RoundCorners := [TCorner.TopLeft, TCorner.TopRight];
      Borders.RoundCorners := [TCorner.TopLeft, TCorner.BottomLeft];
      Borders.RoundCornerRadius := 4;

//      Borders.SetThicknesses(2, 2, 2, 2);
      Borders.SetThicknesses(1, 1, 1, 1);
      Borders.SetColors(TAlphaColorRec.Chocolate, TAlphaColorRec.Chocolate, TAlphaColorRec.Chocolate, TAlphaColorRec.Chocolate);

      Width := 48;
      FieldName := 'ColVal1';
      TextAlign := TTextAlign.Center;
      Name := 'TextBlock1';
    end;

    with TLaTextBlockEh.CreateWith(RefSelf) do
    begin
      Margins.Rect := TRect.Create(2, 2, 2, 2);
      Padding.Rect := TRect.Create(4, 4, 4, 4);
      Fill.Color := HotColors[3];
      Fill.Kind := TBrushKind.Solid;

      Borders.RoundCorners := [];
      Borders.RoundCornerRadius := 4;

      Width := 48;
      FieldName := 'ColVal2';
      TextAlign := TTextAlign.Center;
      Name := 'TextBlock2';
    end;

    with TLaTextBlockEh.CreateWith(RefSelf) do
    begin
      Margins.Rect := TRect.Create(2, 2, 2, 2);
      Padding.Rect := TRect.Create(4, 4, 4, 4);
      Fill.Color := HotColors[5];
      Fill.Kind := TBrushKind.Solid;

      Borders.RoundCorners := [TCorner.TopRight, TCorner.BottomRight];
      Borders.RoundCornerRadius := 4;
      Width := 48;
      FieldName := 'ColVal3';
      TextAlign := TTextAlign.Center;
      Name := 'TextBlock3';
    end;
  end;
end;

procedure TfrSolGridThreeTextBlocksInCell.DataGridLayoutColumnEh1DataCellInitContent(Sender: TObject;
  Params: TDataGridInitDataCellContentParamsEh);
var
  TextBlock: TLaTextBlockEh;
  DataContext: IDataContextEh;
  FieldValue: TValue;
begin
  if Params.CellContent = nil then Exit;

  TextBlock := Params.CellContent.GetElementByName('TextBlock1') as TLaTextBlockEh;
  DataContext := TextBlock.DataContext;
  if DataContext <> nil then
  begin
    FieldValue := DataContext.GetFieldValue('ColVal1');
    TextBlock.Fill.Color := GetHotColor(Double((FieldValue.AsExtended - 50) * 2.5));
//    TextBlock.Fill.Color := TAlphaColorRec.Null;
  end;

  TextBlock := Params.CellContent.GetElementByName('TextBlock2') as TLaTextBlockEh;
  DataContext := TextBlock.DataContext;
  if DataContext <> nil then
  begin
    FieldValue := DataContext.GetFieldValue('ColVal2');
    TextBlock.Fill.Color := GetHotColor(Double((FieldValue.AsExtended - 50) * 2.5));
  end;

  TextBlock := Params.CellContent.GetElementByName('TextBlock3') as TLaTextBlockEh;
  DataContext := TextBlock.DataContext;
  if DataContext <> nil then
  begin
    FieldValue := DataContext.GetFieldValue('ColVal3');
    TextBlock.Fill.Color := GetHotColor(Double((FieldValue.AsExtended - 50) * 2.5));
  end;
end;

end.
