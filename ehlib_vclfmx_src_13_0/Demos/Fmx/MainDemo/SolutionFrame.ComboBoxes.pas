unit SolutionFrame.ComboBoxes;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, EhLibFmx.Api,
  EhLibFmx.ToolControls, EhLibFmx.Grids, EhLibFmx.DataAxisGrids, EhLibFmx.CustomDataGrids, EhLibFmx.DataGrids,
  FMX.Controls.Presentation, EhLibFmx.DataAxisGrid.FieldBars, EhLibFmx.DataGrid.Columns,
  EhLibFmx.DataComboBoxes;

type
  TfrComboBoxes = class(TFrame)
    Panel1: TPanel;
    DataGridEh1: TDataGridEh;
    DataGridEh1NameColumn1: TDataGridStringColumnEh;
    DataGridEh1CapitalColumn1: TDataGridStringColumnEh;
    DataGridEh1ContinentColumn1: TDataGridStringColumnEh;
    DataGridEh1CtntIdColumn1: TDataGridStringColumnEh;
    DataGridComboboxColumnEh1: TDataGridComboboxColumnEh;
    DataGridComboboxColumnEh2: TDataGridComboboxColumnEh;
    SimpleComboBoxEh1: TDataComboBoxEh;
    Label1: TLabel;
    SimpleComboBoxEh2: TDataComboBoxEh;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    LookupComboBoxEh2: TDataComboBoxEh;
    LookupComboBoxEh1: TDataComboBoxEh;
    procedure Label4Click(Sender: TObject);
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses DataModuleUnit;

{$R *.fmx}

{ TfrComboBoxes }

constructor TfrComboBoxes.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  //SimpleComboBoxEh1
  SimpleComboBoxEh1.DataSource := DataModule1.mtCountries;
  SimpleComboBoxEh1.DataFieldName := 'Continent';
  SimpleComboBoxEh1.ListSource := DataModule1.mtContinents;
  SimpleComboBoxEh1.ListFieldName := 'Name';

  //SimpleComboBoxEh2
  SimpleComboBoxEh2.DataSource := DataModule1.mtCountries;
  SimpleComboBoxEh2.DataFieldName := 'Continent';
  SimpleComboBoxEh2.ListItems.CommaText :=
    '"Africa",' + '"Antarctica",' + '"Asia",' + '"Australia",' +
    '"Europe",' + '"North America",' + '"South America"';


  //LookupComboBoxEh1
  LookupComboBoxEh1.DataSource := DataModule1.mtCountries;
  LookupComboBoxEh1.DataFieldName := 'CtntId';
  LookupComboBoxEh1.ListSource := DataModule1.mtContinents;
  LookupComboBoxEh1.ListFieldName := 'Name';
  LookupComboBoxEh1.ListKeyFieldName := 'Id';

  //LookupComboBoxEh2
  LookupComboBoxEh2.DataSource := DataModule1.mtCountries;
  LookupComboBoxEh2.DataFieldName := 'CtntId';
  LookupComboBoxEh2.ListItems.CommaText :=
  '"AFR|Africa",' +
  '"ANT|Antarctica",' +
  '"ASI|Asia",' +
  '"AUS|Australia",' +
  '"EUR|Europe",' +
  '"NAM|North America",' +
  '"SAM|South America"';
end;

procedure TfrComboBoxes.Label4Click(Sender: TObject);
begin
  LookupComboBoxEh2.DataSource := DataModule1.mtCountries;
  LookupComboBoxEh2.DataFieldName := 'CtntId';
  LookupComboBoxEh2.ListItems.CommaText :=
  '"AFR|Africa",' +
  '"ANT|Antarctica",' +
  '"ASI|Asia",' +
  '"AUS|Australia",' +
  '"EUR|Europe",' +
  '"NAM|North America",' +
  '"SAM|South America"';
end;

end.
