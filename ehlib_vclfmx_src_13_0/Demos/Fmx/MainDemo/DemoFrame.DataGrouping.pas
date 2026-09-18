unit DemoFrame.DataGrouping;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FrameDemoBase,
  FMX.Objects, FMX.Controls.Presentation, EhLibFmx.Api, EhLibFmx.ToolControls, EhLibFmx.Grids,
  EhLibFmx.DataAxisGrids, EhLibFmx.CustomDataGrids, EhLibFmx.DataGrids,
  EhLibFmx.DataAxisGrid.FieldBars, EhLibFmx.DataGrid.Columns;

type
  TfrDataGrouping = class(TfrDemoBase)
    Panel1: TPanel;
    Text1: TText;
    SpeedButtonBack: TSpeedButton;
    DataGridEh1: TDataGridEh;
    DataGridEh1CustNoColumn1: TDataGridStringColumnEh;
    DataGridEh1CompanyColumn1: TDataGridStringColumnEh;
    DataGridEh1OrderNoColumn1: TDataGridStringColumnEh;
    DataGridEh1ShipDateColumn1: TDataGridStringColumnEh;
    DataGridEh1ShipVIAColumn1: TDataGridStringColumnEh;
    DataGridEh1TermsColumn1: TDataGridStringColumnEh;
    DataGridEh1ItemsTotalColumn1: TDataGridStringColumnEh;
    DataGridEh1PartNoColumn1: TDataGridStringColumnEh;
    DataGridEh1QtyColumn1: TDataGridStringColumnEh;
    DataGridEh1DiscountColumn1: TDataGridStringColumnEh;
    DataGridEh1PartPriceColumn1: TDataGridStringColumnEh;
    procedure SpeedButtonBackClick(Sender: TObject);
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  frDataGrouping: TfrDataGrouping;

implementation

uses DataModuleUnit;

{$R *.fmx}

constructor TfrDataGrouping.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if DataGridEh1.VisibleRows.Count > 0 then
    if DataGridEh1.VisibleRows[0] is TDataGridGroupHeaderRowEh then
      TDataGridGroupHeaderRowEh(DataGridEh1.VisibleRows[0]).IsExpanded := True;
end;

procedure TfrDataGrouping.SpeedButtonBackClick(Sender: TObject);
begin
  BackButtonClicked();
end;

end.
