unit DemoFrame.MasterDetail;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, System.Rtti,
  FMX.Controls.Presentation, MemTableDataEh, Data.DB, MemTableEh,
  FrameDemoBase,
  EhLibRtl.Api,
  EhLibFmx.Api,
  EhLibFmx.ToolControls, EhLibFmx.Grids, EhLibFmx.DataAxisGrids,
  EhLibFmx.CustomDataGrids, EhLibFmx.DataGrids, EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.DataGrid.Columns;

type
  TfrMasterDetail = class(TfrDemoBase)
    Panel1: TPanel;
    Text1: TText;
    DataGridEh1: TDataGridEh;
    DataGridEh2: TDataGridEh;
    DataSource1: TDataSource;
    mtTable1: TMemTableEh;
    mtTable2: TMemTableEh;
    DataSource2: TDataSource;
    Button1: TButton;
    SpeedButtonBack: TSpeedButton;
    DBGridEh1OrderNoColumn1: TDataGridStringColumnEh;
    DBGridEh1CustNoColumn1: TDataGridStringColumnEh;
    DBGridEh1SaleDateColumn1: TDataGridStringColumnEh;
    DBGridEh1ShipDateColumn1: TDataGridStringColumnEh;
    DBGridEh1EmpNoColumn1: TDataGridStringColumnEh;
    DBGridEh1ShipToContactColumn1: TDataGridStringColumnEh;
    DBGridEh1ShipToAddr1Column1: TDataGridStringColumnEh;
    DBGridEh1ShipToAddr2Column1: TDataGridStringColumnEh;
    DBGridEh1ShipToCityColumn1: TDataGridStringColumnEh;
    DBGridEh1ShipToStateColumn1: TDataGridStringColumnEh;
    DBGridEh1ShipToZipColumn1: TDataGridStringColumnEh;
    DBGridEh1ShipToCountryColumn1: TDataGridStringColumnEh;
    DBGridEh1ShipToPhoneColumn1: TDataGridStringColumnEh;
    DBGridEh1ShipVIAColumn1: TDataGridStringColumnEh;
    DBGridEh1POColumn1: TDataGridStringColumnEh;
    DBGridEh1TermsColumn1: TDataGridStringColumnEh;
    DBGridEh1PaymentMethodColumn1: TDataGridStringColumnEh;
    DBGridEh1ItemsTotalColumn1: TDataGridStringColumnEh;
    DBGridEh1TaxRateColumn1: TDataGridStringColumnEh;
    DBGridEh1FreightColumn1: TDataGridStringColumnEh;
    DBGridEh1AmountPaidColumn1: TDataGridStringColumnEh;
    procedure Button1Click(Sender: TObject);
    procedure SpeedButtonBackClick(Sender: TObject);
    procedure DBGridEh1TitleCreateCellContent(Sender: TObject;
      Params: TDataGridTitleCreateCellContentParamsEh);
    procedure DBGridEh1TitleCellInitContent(Sender: TObject;
      Params: TDataGridTitleInitCellContentParamsEh);
    procedure DBGridEh1SaleDateColumn1Footers0GetDisplayText(Sender: TObject;
      Params: TDataGridFooterGetDisplayTextParamsEh);
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.fmx}

{ TfrMasterDetail }

constructor TfrMasterDetail.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SpeedButtonBack.Visible := TEhLibFmxSettings.Default.PlatformWindowSizeType = TPlatformWindowSizeTypeEh.FullScreen;
//  Button1Click(nil);
end;

procedure TfrMasterDetail.DBGridEh1SaleDateColumn1Footers0GetDisplayText(
  Sender: TObject; Params: TDataGridFooterGetDisplayTextParamsEh);
var
  FuncName: String;
begin
  FuncName := TRttiEnumerationType.GetName<TFooterAggregateFunction>(Params.ColumnFooter.AggregateFunction);
  Params.DisplayText := FuncName + ': ' + Params.DefaultGetDisplayText;
  Params.Handled := True;
end;

procedure TfrMasterDetail.DBGridEh1TitleCreateCellContent(Sender: TObject;
  Params: TDataGridTitleCreateCellContentParamsEh);
begin
  with TLaStackPanelEh.CreateWith(Params.ContentParent, Params.ContentParent) do
  begin
    Orientation := TLaOrientationEh.Vertical;

    with Params.DefaultCreateCellContent(RefSelf) do
    begin
    end;

    with TLaTextBlockEh.CreateWith(RefSelf, RefSelf) do
    begin
      Text := 'Type of Column';
      Name := 'TypeInfo';
      Padding.Rect := RectF(2, 0, 2, 0);
      VertAlignment := TLaVertAlignmentEh.Center;
      HorzAlignment := TLaHorzAlignmentEh.Stretch;
      Font.Size := 10;
      FontColor := TAlphaColorRec.Gray;
    end;

    Params.CellContent := TLaControlEh(RefSelf);
//    Params.Handled := True;
  end;
end;

procedure TfrMasterDetail.DBGridEh1TitleCellInitContent(Sender: TObject;
  Params: TDataGridTitleInitCellContentParamsEh);
var
  TextBlock: TLaTextBlockEh;
  DBFieldLink: TDataSetFieldLinkEh;
  DBTypeName: String;
begin
  if Params.ColumnTitle <> nil then
  begin

    DBTypeName := '';
    if (Params.ColumnTitle.Column.Field <> nil) then
    begin
      if Params.ColumnTitle.Column.Field is TDataSetFieldLinkEh then
      begin
        DBFieldLink := TDataSetFieldLinkEh(Params.ColumnTitle.Column.Field);
        DBTypeName := TRttiEnumerationType.GetName(DBFieldLink.Field.DataType);
        DBTypeName := Copy(DBTypeName, 3, Length(DBTypeName));

        if DBFieldLink.Field.DataType in [ftString, ftFixedChar, ftWideString, ftFixedWideChar] then
          DBTypeName :=  DBTypeName + ' (' + DBFieldLink.Field.Size.ToString +  ')';
      end;
    end;

    TextBlock := Params.CellContent.GetElementByName('TypeInfo') as TLaTextBlockEh;
    TextBlock.Text := DBTypeName;
  end;
  Params.Handled := True;
end;

procedure TfrMasterDetail.Button1Click(Sender: TObject);
begin
  if DataGridEh1.DataSource = nil then
    DataGridEh1.DataSource := DataSource1
  else
    DataGridEh1.DataSource := nil;
end;

procedure TfrMasterDetail.SpeedButtonBackClick(Sender: TObject);
begin
  BackButtonClicked;
end;

end.
