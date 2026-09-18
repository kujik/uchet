unit DemoFrame.CellFormating;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, Data.Bind.EngExt, Fmx.Bind.DBEngExt,
  Data.Bind.Components, Data.Bind.DBScope, Rtti, FMX.Controls.Presentation,
  FrameDemoBase,
  FMX.Objects, EhLibUtils,
  EhLibRtl.Api,
  EhLibFmx.Api,
  EhLibFmx.DataAxisGrid.FieldBars, EhLibFmx.DataGrid.Columns,
  EhLibFmx.DataGrids, EhLibFmx.ToolControls, EhLibFmx.Grids,
  EhLibFmx.DataAxisGrids, EhLibFmx.CustomDataGrids;

type
  TfrCellFormating = class(TfrDemoBase)
    Panel1: TPanel;
    Text1: TText;
    Button1: TButton;
    SpeedButtonBack: TSpeedButton;
    DBGridEh1: TDataGridEh;
    DBGridEh1NameColumn1: TDataGridStringColumnEh;
    DBGridEh1CapitalColumn1: TDataGridStringColumnEh;
    DBGridEh1ContinentColumn1: TDataGridStringColumnEh;
    DBGridEh1AreaColumn1: TDataGridStringColumnEh;
    DBGridEh1PopulationColumn1: TDataGridStringColumnEh;
    procedure DBGridEh1DataCellGetStyleParams(Sender: TObject; Params: TDataGridDataCellStyleParamsEh);
    procedure SpeedButtonBackClick(Sender: TObject);
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses DataModuleUnit;

{$R *.fmx}

constructor TfrCellFormating.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SpeedButtonBack.Visible := TEhLibFmxSettings.Default.PlatformWindowSizeType = TPlatformWindowSizeTypeEh.FullScreen;
end;

procedure TfrCellFormating.DBGridEh1DataCellGetStyleParams(Sender: TObject; Params: TDataGridDataCellStyleParamsEh);
var
  ContValue: TValue;
begin
  ContValue := DBGridEh1ContinentColumn1.GetRowValue(Params.Row);
  if CompareValue(ContValue, 'North America') = TVariantRelationship.vrEqual then
  begin
    Params.Font.Style := Params.Font.Style + [TFontStyle.fsBold];
    Params.FontColor := TAlphaColorRec.Lightslategray;
    Params.Fill.Color := TAlphaColorRec.Bisque;
    if Params.Column.FieldName = 'Name' then
      Params.HorzAlign := TTextAlign.Center;
    if Params.Column.FieldName = 'Capital' then
      Params.Padding.Rect := TRectF.Create(20, 2, 2, 2);
  end;
end;

procedure TfrCellFormating.SpeedButtonBackClick(Sender: TObject);
begin
  BackButtonClicked;
end;

end.
