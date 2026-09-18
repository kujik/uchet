unit DemoFrame.MainGrid;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, MemTableDataEh, Data.DB, MemTableEh,
  FrameDemoBase,
  EhLibRtl.Api,
  EhLibFmx.Api, EhLibFmx.Utils,
  EhLibFmx.DataGrids, EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.DataGrid.Columns, EhLibFmx.ToolControls, EhLibFmx.Grids,
  EhLibFmx.DataAxisGrids, EhLibFmx.CustomDataGrids;

type
  TfrMainGrid = class(TfrDemoBase)
    Panel1: TPanel;
    Text1: TText;
    DBGridEh1: TDataGridEh;
    DataSource1: TDataSource;
    MemTableEh1: TMemTableEh;
    ColVNo: TDataGridStringColumnEh;
    ColVName: TDataGridStringColumnEh;
    ColPNo: TDataGridStringColumnEh;
    ColPDescription: TDataGridStringColumnEh;
    ColCost: TDataGridStringColumnEh;
    ColQty: TDataGridStringColumnEh;
    ColVPreferred: TDataGridCheckboxColumnEh;
    Button1: TButton;
    SpeedButtonBack: TSpeedButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure SpeedButtonBackClick(Sender: TObject);
  private
    FBaseCaptionColor: TAlphaColor;
    procedure CreateComplexTitle;
  protected
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.fmx}

{ TfrMainGrid }

constructor TfrMainGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SpeedButtonBack.Visible := TEhLibFmxSettings.Default.PlatformWindowSizeType = TPlatformWindowSizeTypeEh.FullScreen;
  if TEhLibFmxSettings.Default.PlatformWindowSizeType = TPlatformWindowSizeTypeEh.FullScreen then
  begin
    DBGridEh1.Columns.ColByFieldName('PCost').Visible := False;
    DBGridEh1.Columns.ColByFieldName('IQty').Visible := False;
    DBGridEh1.Columns.ColByFieldName('VPreferred').Visible := False;
    DBGridEh1.SelectionOptions.AllowedSelections := [];
  end;

  CreateComplexTitle;
//  FBaseCaptionColor := Text1.TextSettings.FontColor;
end;

procedure TfrMainGrid.Resize;
begin
  inherited Resize;
  if FBaseCaptionColor <> TAlphaColorRec.Null then
  begin
    if TStyleManagerEh.Current.StyleColorMode = TStyleColorModeEh.Dark then
      Text1.TextSettings.FontColor := AdjustColorForDarkTheme(FBaseCaptionColor)
    else
      Text1.TextSettings.FontColor := FBaseCaptionColor;
  end
  else if Text1 <> nil then
    FBaseCaptionColor := Text1.TextSettings.FontColor;
end;

procedure TfrMainGrid.CreateComplexTitle;
begin
  DBGridEh1.Title.IsComplexTitle := True;

  DBGridEh1.Title.ComplexTitleTree.BeginUpdate;

  with TDataGridSuperTitleEh.CreateWith(Self, DBGridEh1.Title) do
  begin
    Text := 'Vendor of parts';
    with TDataGridSuperTitleEh.CreateWith(Self, RefSelf) do
    begin
      Text := 'Vendor Number';
      MoveChild(ColVNo);
    end;
    with TDataGridSuperTitleEh.CreateWith(Self, RefSelf) do
    begin
      Text := 'Vendor Name';
      MoveChild(ColVName);
    end;
  end;

  with TDataGridSuperTitleEh.CreateWith(Self, DBGridEh1.Title) do
  begin
    Text := 'Parts';
    with TDataGridSuperTitleEh.CreateWith(Self, RefSelf) do
    begin
      Text := 'PNo';
      MoveChild(ColPNo);
    end;
    with TDataGridSuperTitleEh.CreateWith(Self, RefSelf) do
    begin
      Text := 'Description';
      MoveChild(ColPDescription);
    end;

    if DBGridEh1.Columns.ColByFieldName('PCost').Visible = True then
    begin
      with TDataGridSuperTitleEh.CreateWith(Self, RefSelf) do
      begin
        Text := 'Cost';
        MoveChild(ColCost);
      end;
    end;
  end;

  if DBGridEh1.Columns.ColByFieldName('IQty').Visible = True then
  begin
    with TDataGridSuperTitleEh.CreateWith(Self, DBGridEh1.Title) do
    begin
      Text := 'Items';
      with TDataGridSuperTitleEh.CreateWith(Self, RefSelf) do
      begin
        Text := 'Qty';
        MoveChild(ColQty);
      end;
      MoveChild(ColVPreferred);
    end;
  end;

  DBGridEh1.Title.ComplexTitleTree.EndUpdate;

  DBGridEh1.ColumnOptions.ColSizeUnit := TGridColSizeUnitEh.Weight;
end;

procedure TfrMainGrid.Button1Click(Sender: TObject);
begin
  CreateComplexTitle;
end;

procedure TfrMainGrid.Button2Click(Sender: TObject);
begin
  DBGridEh1.Title.IsComplexTitle := False;
  DBGridEh1.ColumnOptions.ColSizeUnit := TGridColSizeUnitEh.Pixels;
end;

procedure TfrMainGrid.SpeedButtonBackClick(Sender: TObject);
begin
  BackButtonClicked;
end;

end.
