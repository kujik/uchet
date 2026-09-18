unit DemoFrame.LaObjectFishFacts;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Rtti,
  FrameDemoBase, FMX.Objects,
  FMX.Controls.Presentation,
  EhLibRtl.Api,
  EhLibFmx.Api,
  EhLibFmx.DataGrids, EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.DataGrid.Columns, EhLibFmx.ToolControls, EhLibFmx.Grids,
  EhLibFmx.DataAxisGrids, EhLibFmx.CustomDataGrids;

type
  TfrLaObjectFishFacts = class(TfrDemoBase)
    Panel1: TPanel;
    Text1: TText;
    SpeedButtonBack: TSpeedButton;
    DataGridEh1: TDataGridEh;
    SpeciesIdCol: TDataGridStringColumnEh;
    DBGridLayoutColumnEh1: TDataGridLayoutColumnEh;
    procedure SpeedButtonBackClick(Sender: TObject);
    procedure DBGridLayoutColumnEh1CreateDataCellContent(Sender: TObject;
      Params: TDataGridCreateDataCellContentParamsEh);
    procedure DBGridLayoutColumnEh1DataCellInitContent(Sender: TObject;
      Params: TDataGridInitDataCellContentParamsEh);
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  frLaObjectFishFacts: TfrLaObjectFishFacts;

implementation

uses DataModuleUnit;

{$R *.fmx}

{ TfrDemoBase2 }

constructor TfrLaObjectFishFacts.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SpeedButtonBack.Visible := TEhLibFmxSettings.Default.PlatformWindowSizeType = TPlatformWindowSizeTypeEh.FullScreen;

  if TEhLibFmxSettings.Default.PlatformWindowSizeType = TPlatformWindowSizeTypeEh.FullScreen then
  begin
    SpeciesIdCol.Visible := False;
    DataGridEh1.SelectionOptions.AllowedSelections := [];
  end;
end;

procedure TfrLaObjectFishFacts.DBGridLayoutColumnEh1CreateDataCellContent(
  Sender: TObject; Params: TDataGridCreateDataCellContentParamsEh);
begin
  with TLaStackPanelEh.CreateWith(Params.ContentParent) do
  begin
    Params.CellContent := TLaControlEh(RefSelf);
    Font.Size := 14;
    Orientation := TLaOrientationEh.Vertical;

    with TLaGridPanelEh.CreateWith(RefSelf) do
    begin
      with ColumnCollection.Add do
      begin
        SizeStyle := TLaGridPanelSizeStyleEh.Weight;
        Value := 1;
      end;

      with ColumnCollection.Add do
      begin
        SizeStyle := TLaGridPanelSizeStyleEh.Weight;
        Value := 1;
      end;

      with ColumnCollection.Add do
      begin
        SizeStyle := TLaGridPanelSizeStyleEh.Weight;
        Value := 2;
      end;

      with TLaLayoutPanelEh.CreateWith(RefSelf) do
      begin
        ControlCollection.AddControl(RefSelf, 0, -1);
        Margins.Rect := TRectF.Create(10, 10 ,10, 10);
        Borders.Left.Thickness := 1;
        Borders.Top.Thickness := 1;
        Borders.Bottom.Thickness := 1;
        Borders.Right.Thickness := 1;
        Borders.Left.Color := TAlphaColors.MedGray;
        Borders.Top.Color := TAlphaColors.MedGray;
        Borders.Bottom.Color := TAlphaColors.MedGray;
        Borders.Right.Color := TAlphaColors.MedGray;

        with TLaImageEh.CreateWith(RefSelf) do
        begin
          FieldName := 'PngGraphic';

        end;

        with TLaImageEh.CreateWith(RefSelf) do
        begin
//          ControlCollection.AddControl(RefSelf, 0, -1);
          Margins.Rect := TRectF.Create(2, 2, 2, 2);
//          ImageList := Form1.ImageList16;
//          ImageIndex := 12;
          HorzAlignment := TLaHorzAlignmentEh.Left;
          VertAlignment := TLaVertAlignmentEh.Top;

//          OnGetHintInfo := GetFlowRichBlockHintInfo;
        end;
      end;

      with TLaStackPanelEh.CreateWith(RefSelf) do
      begin
        ControlCollection.AddControl(RefSelf, 1, -1);
        Margins.Rect := TRectF.Create(0, 10, 0, 10);
//        BorderThickness.SetBounds(0, 0, 0, 0);
//        BorderColor := clMedGray;
        Font.Style := [TFontStyle.fsBold];

        with TLaLayoutPanelEh.CreateWith(RefSelf) do
        begin
          Borders.SetThicknesses(1, 1, 1, 0);
          Borders.SetColors(TAlphaColors.MedGray, TAlphaColors.MedGray, TAlphaColors.MedGray, TAlphaColors.MedGray);
          Padding.Rect := TRectF.Create(4, 4, 4, 4);
          with TLaTextBlockEh.CreateWith(RefSelf) do
          begin
            Text := 'Category:';
            //FieldName := 'Notes';
          end;
        end;

        with TLaLayoutPanelEh.CreateWith(RefSelf) do
        begin
          Borders.SetThicknesses(1, 1, 1, 0);
          Borders.SetColors(TAlphaColors.MedGray, TAlphaColors.MedGray, TAlphaColors.MedGray, TAlphaColors.MedGray);
          Padding.Rect := TRectF.Create(4, 4, 4, 4);
          with TLaTextBlockEh.CreateWith(RefSelf) do
          begin
            Text := 'Common name:';
          end;
        end;

        with TLaLayoutPanelEh.CreateWith(RefSelf) do
        begin
          Borders.SetThicknesses(1, 1, 1, 0);
          Borders.SetColors(TAlphaColors.MedGray, TAlphaColors.MedGray, TAlphaColors.MedGray, TAlphaColors.MedGray);
          Padding.Rect := TRectF.Create(4, 4, 4, 4);
          with TLaTextBlockEh.CreateWith(RefSelf) do
          begin
            Text := 'Species name:';
          end;
        end;

        with TLaLayoutPanelEh.CreateWith(RefSelf) do
        begin
          Borders.SetThicknesses(1, 1, 1, 1);
          Borders.SetColors(TAlphaColors.MedGray, TAlphaColors.MedGray, TAlphaColors.MedGray, TAlphaColors.MedGray);
          Padding.Rect := TRectF.Create(4, 4, 4, 4);
          with TLaTextBlockEh.CreateWith(RefSelf) do
          begin
            Text := 'Length:';
          end;
        end;
      end;

      with TLaStackPanelEh.CreateWith(RefSelf) do
      begin
        ControlCollection.AddControl(RefSelf, 2, -1);
        Margins.Rect := TRectF.Create(0, 10, 10, 10);
        Borders.SetThicknesses(0, 0, 0, 0);
        Borders.SetColors(TAlphaColors.MedGray, TAlphaColors.MedGray, TAlphaColors.MedGray, TAlphaColors.MedGray);

        with TLaLayoutPanelEh.CreateWith(RefSelf) do
        begin
          Borders.SetThicknesses(0, 1, 1, 0);
          Borders.SetColors(TAlphaColors.MedGray, TAlphaColors.MedGray, TAlphaColors.MedGray, TAlphaColors.MedGray);
          Padding.Rect := TRectF.Create(4, 4, 4, 4);
          with TLaTextBlockEh.CreateWith(RefSelf) do
          begin
            FieldName := 'Category';
          end;
        end;

        with TLaLayoutPanelEh.CreateWith(RefSelf) do
        begin
          Borders.SetThicknesses(0, 1, 1, 0);
          Borders.SetColors(TAlphaColors.MedGray, TAlphaColors.MedGray, TAlphaColors.MedGray, TAlphaColors.MedGray);
          Padding.Rect := TRectF.Create(4, 4, 4, 4);
          with TLaTextBlockEh.CreateWith(RefSelf) do
          begin
            FieldName := 'Common_name';
          end;
        end;

        with TLaLayoutPanelEh.CreateWith(RefSelf) do
        begin
          Borders.SetThicknesses(0, 1, 1, 0);
          Borders.SetColors(TAlphaColors.MedGray, TAlphaColors.MedGray, TAlphaColors.MedGray, TAlphaColors.MedGray);
          Padding.Rect := TRectF.Create(4, 4, 4, 4);
          with TLaTextBlockEh.CreateWith(RefSelf) do
          begin
            FieldName := 'Species_Name';
          end;
        end;

        with TLaLayoutPanelEh.CreateWith(RefSelf) do
        begin
          Borders.SetThicknesses(0, 1, 1, 1);
          Borders.SetColors(TAlphaColors.MedGray, TAlphaColors.MedGray, TAlphaColors.MedGray, TAlphaColors.MedGray);
          Padding.Rect := TRectF.Create(4, 4, 4, 4);
          with TLaTextBlockEh.CreateWith(RefSelf) do
          begin
            FieldName := 'Length';
          end;
        end;
      end;
    end;

    with TLaTextBlockEh.CreateWith(RefSelf) do
    begin
      Margins.Rect := TRectF.Create(10, 0, 10, 10);
      Borders.SetThicknesses(1, 1, 1, 1);
      Borders.SetColors(TAlphaColors.MedGray, TAlphaColors.MedGray, TAlphaColors.MedGray, TAlphaColors.MedGray);
      Padding.Rect := TRectF.Create(4, 4, 4, 4);
      FieldName := 'Notes';
      WordWrap := True;
      Font.Size := 9;
    end;

//    Result := RefSelf;
  end;
end;

procedure TfrLaObjectFishFacts.DBGridLayoutColumnEh1DataCellInitContent(
  Sender: TObject; Params: TDataGridInitDataCellContentParamsEh);
begin
//  inherited;
end;

procedure TfrLaObjectFishFacts.SpeedButtonBackClick(Sender: TObject);
begin
  BackButtonClicked;
end;

end.
