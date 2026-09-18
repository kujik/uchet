unit DemoFrame.VerticalGrid;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FrameDemoBase, FMX.Objects,
  FMX.Controls.Presentation, FMX.Layouts, EhLibFmx.Api, EhLibFmx.CustomDataVertGrids, EhLibFmx.DataVertGrids,
  EhLibFmx.ToolControls, EhLibFmx.Grids, EhLibFmx.DataAxisGrids, EhLibFmx.CustomDataGrids, EhLibFmx.DataGrids,
  EhLibFmx.DataAxisGrid.FieldBars, EhLibFmx.DataGrid.Columns, EhLibFmx.DataVertGrid.Rows;

type
  TfrVerticalGrid = class(TfrDemoBase)
    Panel1: TPanel;
    Text1: TText;
    SpeedButtonBack: TSpeedButton;
    Layout1: TLayout;
    DataGridEh1: TDataGridEh;
    DataVertGridEh1: TDataVertGridEh;
    Splitter1: TSplitter;
    DataGridEh1SpeciesIdColumn1: TDataGridStringColumnEh;
    DataGridEh1CategoryColumn1: TDataGridStringColumnEh;
    DataGridEh1Common_nameColumn1: TDataGridStringColumnEh;
    DataGridEh1Species_NameColumn1: TDataGridStringColumnEh;
    DataGridEh1LengthColumn1: TDataGridStringColumnEh;
    DataVertGridEh1SpeciesIdRow1: TDataVertGridStringRowEh;
    DataVertGridEh1NotesRow1: TDataVertGridStringRowEh;
    DataVertGridEh1CategoryRow1: TDataVertGridStringRowEh;
    DataVertGridEh1Common_nameRow1: TDataVertGridStringRowEh;
    DataVertGridEh1Species_NameRow1: TDataVertGridStringRowEh;
    DataVertGridEh1LengthRow1: TDataVertGridStringRowEh;
    DataVertGridEh1PngGraphicRow1: TDataVertGridGraphicRowEh;
    procedure SpeedButtonBackClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frVerticalGrid: TfrVerticalGrid;

implementation

uses DataModuleUnit;

{$R *.fmx}

procedure TfrVerticalGrid.SpeedButtonBackClick(Sender: TObject);
begin
  BackButtonClicked();
end;

end.
