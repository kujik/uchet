unit DemoFrame.FishFacts;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, MemTableDataEh, Data.DB,
  MemTableEh, System.Rtti, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components,
  FrameDemoBase,
  Data.Bind.DBScope,
  EhLibRtl.Api,
  EhLibFmx.Api,
  EhLibFmx.DataAxisGrid.FieldBars, EhLibFmx.DataGrid.Columns,
  EhLibFmx.DataGrids, EhLibFmx.ToolControls, EhLibFmx.Grids,
  EhLibFmx.DataAxisGrids, EhLibFmx.CustomDataGrids;

type
  TfrFishFacts = class(TfrDemoBase)
    Panel1: TPanel;
    Text1: TText;
    DataSource1: TDataSource;
    MemTableEh1: TMemTableEh;
    DataGridEh1: TDataGridEh;
    DBGridEh1NotesColumn1: TDataGridStringColumnEh;
    DBGridEh1CategoryColumn1: TDataGridStringColumnEh;
    DBGridEh1Common_nameColumn1: TDataGridStringColumnEh;
    DBGridEh1LengthColumn1: TDataGridStringColumnEh;
    Button1: TButton;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    SpeedButtonBack: TSpeedButton;
    DataGridEh1SpeciesIdColumn1: TDataGridStringColumnEh;
    DataGridEh1Species_NameColumn1: TDataGridStringColumnEh;
    DataGridEh1ADateColumn1: TDataGridStringColumnEh;
    DataGridEh1AnmlClassColumn1: TDataGridStringColumnEh;
    DataGridEh1AnmlFamilyColumn1: TDataGridStringColumnEh;
    DataGridEh1AnmlGenusColumn1: TDataGridStringColumnEh;
    DataGridEh1AnmlKingdomColumn1: TDataGridStringColumnEh;
    DataGridEh1AnmlOrderColumn1: TDataGridStringColumnEh;
    DataGridEh1AnmlPhylumColumn1: TDataGridStringColumnEh;
    DataGridEh1AnmlSpeciesColumn1: TDataGridStringColumnEh;
    DataGridEh1OceanColumn1: TDataGridStringColumnEh;
    DataGridEh1PngGraphicColumn1: TDataGridGraphicColumnEh;
    procedure Button1Click(Sender: TObject);
    procedure SpeedButtonBackClick(Sender: TObject);
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.fmx}

constructor TfrFishFacts.Create(AOwner: TComponent);
var
  I: Integer;
begin
  inherited Create(AOwner);

  SpeedButtonBack.Visible := TEhLibFmxSettings.Default.PlatformWindowSizeType = TPlatformWindowSizeTypeEh.FullScreen;

  if TEhLibFmxSettings.Default.PlatformWindowSizeType = TPlatformWindowSizeTypeEh.FullScreen then
  begin
    for I := 0 to DataGridEh1.Columns.Count - 1 do
    begin
      if (DataGridEh1.Columns[I] = DBGridEh1NotesColumn1) or (DataGridEh1.Columns[I].FieldName = 'PngGraphic') then
      begin
        //Ok
      end else
      begin
        DataGridEh1.Columns[I].Visible := False;
      end;
    end;

    DataGridEh1.ColumnOptions.ColSizeUnit := TGridColSizeUnitEh.Weight;
    DataGridEh1.SelectionOptions.AllowedSelections := [];
  end;

  Button1Click(nil);
end;

procedure TfrFishFacts.Button1Click(Sender: TObject);
begin
  DataGridEh1.ColumnOptions.WordWrap := True;
  DataGridEh1.ColumnOptions.HeightAutoExpand := True;
end;

procedure TfrFishFacts.SpeedButtonBackClick(Sender: TObject);
begin
  BackButtonClicked;
end;

end.
