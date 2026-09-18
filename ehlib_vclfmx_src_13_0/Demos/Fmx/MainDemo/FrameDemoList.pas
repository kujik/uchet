unit FrameDemoList;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  MemTableDataEh, Data.DB, MemTableEh,
  EhLibRtl.Api,
  EhLibFmx.Api,
  System.IOUtils,
  MarkdownProcessor,
  EhLibFmx.DataGrids, EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.DataGrid.Columns, EhLibFmx.ToolControls, EhLibFmx.Grids,
  EhLibFmx.DataAxisGrids, EhLibFmx.CustomDataGrids;

type
  TfrDemoList = class(TFrame)
    DBGridEh1: TDataGridEh;
    DBGridStringColumnEh1: TDataGridStringColumnEh;
    MemTableEh1: TMemTableEh;
    MemTableEh1MenuName: TWideStringField;
    MemTableEh1RefFrameClass: TRefObjectField;
    MemTableEh1RefFrame: TRefObjectField;
    MemTableEh1DetailInfo: TWideStringField;
    DataSource1: TDataSource;
    DataGridLayoutColumnEh1: TDataGridLayoutColumnEh;
    MemTableEh1DescFileName: TWideStringField;
    procedure DataSource1DataChange(Sender: TObject; Field: TField);
    procedure DataGridLayoutColumnEh1CreateDataCellContent(Sender: TObject;
      Params: TDataGridCreateDataCellContentParamsEh);
  private
    FCurrentFrame: TFrame;
    FOnCurrentDemoFrameChanged: TNotifyEvent;
    FOnGridItemClicked: TNotifyEvent;

    function GetDemoListDataSet: TDataSet;

    procedure RebuildDemoList;
    procedure CurrentDemoFrameChanged();
    procedure DataCellMouseClicked(Sender: TObject; Params: TDataGridDataCellMouseButtonParamsEh);
  public
    constructor Create(AOwner: TComponent); override;

    function GetFrameDescriptionAsHtml(): String;

    property DemoListDataSet: TDataSet read GetDemoListDataSet;
    property CurrentFrame: TFrame read FCurrentFrame;
    property OnCurrentDemoFrameChanged: TNotifyEvent read FOnCurrentDemoFrameChanged write FOnCurrentDemoFrameChanged;
    property OnGridItemClicked: TNotifyEvent read FOnGridItemClicked write FOnGridItemClicked;
  end;

implementation

uses
     EhLibUtils,
     FrameTest,
     AppUnit,
     DemoFrame.MainGrid,
     DemoFrame.MasterDetail,
     DemoFrame.FishFacts,
     DemoFrame.SearchPanel,
     DemoFrame.LaObjectFishFacts,
     DemoFrame.CellFormating,
     DemoFrame.FileExplorer,
     DemoFrame.ContactsNCalls,
     DemoFrame.VerticalGrid,
     DemoFrame.DataGrouping
     ;

{$R *.fmx}

type
  TControlClass = class of TControl;

{ TfrDemoList }

constructor TfrDemoList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Align := TAlignLayout.Client;
  RebuildDemoList;
  DataSource1.OnDataChange := DataSource1DataChange;
  DataSource1DataChange(nil, nil);
  DBGridEh1.OnDataCellMouseClick := DataCellMouseClicked;
  DBGridStringColumnEh1.Visible := False;
//  CurrentDemoFrameChanged();
end;

procedure TfrDemoList.CurrentDemoFrameChanged;
begin
  if Assigned(OnCurrentDemoFrameChanged) then
    OnCurrentDemoFrameChanged(Self);
end;

procedure TfrDemoList.DataCellMouseClicked(Sender: TObject; Params: TDataGridDataCellMouseButtonParamsEh);
begin
  if Assigned(OnGridItemClicked) then
    OnGridItemClicked(Self);
end;

procedure TfrDemoList.DataGridLayoutColumnEh1CreateDataCellContent(
  Sender: TObject; Params: TDataGridCreateDataCellContentParamsEh);
begin
  with TLaStackPanelEh.CreateWith(Params.ContentParent, Params.ContentParent) do
  begin
    Orientation := TLaOrientationEh.Vertical;

    with TLaTextBlockEh.CreateWith(RefSelf) do
    begin
      Margins.Rect := TRectF.Create(14, 4, 4, 4);
      FieldName := 'MenuName';
    end;

    with TLaTextBlockEh.CreateWith(RefSelf) do
    begin
      Margins.Rect := TRectF.Create(28, 2, 2, 2);
      Font.Size := 9;
      FontColor := TAlphaColorRec.Gray;
      FieldName := 'DetailInfo';
      //  OnGetHintInfo := GetHintInfo;
    end;

    Params.CellContent := TLaControlEh(RefSelf);
  end;
end;

procedure TfrDemoList.DataSource1DataChange(Sender: TObject; Field: TField);
var
  AClass: TControlClass;
  AFrame: TControl;
  Rec: TMemoryRecordEh;
  OldFrame :TFrame;
begin
  if MemTableEh1RefFrame.Value = nil then
  begin
    if MemTableEh1RefFrameClass.Value = nil then
    begin
      MemTableEh1.InstantReadEnter(MemTableEh1.InstantReadCurRow+1);
      Rec := MemTableEh1.Rec;
      if MemTableEh1RefFrame.Value = nil then
      begin
        AClass := TControlClass(MemTableEh1RefFrameClass.Value);
        AFrame := AClass.Create(Self);
      end else
        AFrame := TControl(MemTableEh1RefFrame.Value);
      MemTableEh1.InstantReadLeave;
      DataSource1.OnDataChange := nil;
      MemTableEh1.Edit;
      MemTableEh1RefFrame.Value := AFrame;
      MemTableEh1.Post;
      DataSource1.OnDataChange := DataSource1DataChange;
      if VarIsNull(Rec.DataValues['RefFrame', dvvValueEh]) then
        Rec.DataValues['RefFrame', dvvValueEh] := RefObjectToVariant(MemTableEh1RefFrame.Value);

//      ShowMessage('To Do')
    end else
    begin
      DataSource1.OnDataChange := nil;
      MemTableEh1.Edit;
      MemTableEh1RefFrame.Value := TControlClass(MemTableEh1RefFrameClass.Value).Create(Self);
      MemTableEh1.Post;
      DataSource1.OnDataChange := DataSource1DataChange;
    end;
  end;

  OldFrame := CurrentFrame;
//  Frame.Parent := nil;
  if (MemTableEh1RefFrame.Value <> nil) and (MemTableEh1RefFrame.Value <> CurrentFrame) then
  begin
    FCurrentFrame := TFrame(MemTableEh1RefFrame.Value);
    CurrentDemoFrameChanged;
//    Frame.Parent := Panel1;
//    Frame.Align := TAlignLayout.Client;
    if OldFrame <> nil then
      OldFrame.Parent := nil;
  end;
end;

function TfrDemoList.GetDemoListDataSet: TDataSet;
begin
  Result := MemTableEh1;
end;

function TfrDemoList.GetFrameDescriptionAsHtml: String;
var
 md: TMarkdownProcessor;
 html: String;
 TextData: String;
 FileName: String;
 FileLoaded: Boolean;
begin
  FileLoaded := False;
  FileName := VarToStrEh(MemTableEh1.FieldValues['DescFileName']);
  if FileName <> '' then
  begin
    if TDirectory.Exists('.\MDHelpFiles') then
      FileName := '.\MDHelpFiles\' + FileName
    else if TDirectory.Exists('..\MDHelpFiles') then
      FileName := '..\MDHelpFiles\' + FileName
    else if TDirectory.Exists('..\..\MDHelpFiles') then
      FileName := '..\..\MDHelpFiles\' + FileName;

    if TFile.Exists(FileName) = True then
    begin
      TextData := TFile.ReadAllText(FileName, TEncoding.UTF8);
      FileLoaded := True;
    end;
  end;

  if FileLoaded = False then
    TextData := VarToStrEh(MemTableEh1.FieldValues['DetailInfo']);

  md := TMarkdownProcessor.createDialect(mdCommonMark);
  html := md.process(TextData);
  html := MarkDownHtmlHead + sLineBreak + '<body>' + html + '</body>';
  md.Free;

  Result := Html;
//  WebBrowser1.LoadFromStrings(html, '');
end;

procedure TfrDemoList.RebuildDemoList;
begin
  MemTableEh1.DisableControls;

  while not MemTableEh1.Eof do
  begin
    MemTableEh1.Delete;
  end;

  MemTableEh1.Append;

//  MemTableEh1.FieldValues['MenuName'] := ApplicationLanguageConsts.VertMenuMainGrid;
  MemTableEh1.FieldValues['MenuName'] := 'Main Grid';
  MemTableEh1.FieldValues['DetailInfo'] := 'Main Grid Demo. MultiTitle, Footer, AutoFitColWidths, LookupComboColumn';
  TRefObjectField(MemTableEh1.FieldByName('RefFrameClass')).Value := TObject(TfrMainGrid);
  MemTableEh1.FieldValues['DescFileName'] := 'Demo-MainGrid.md';

  MemTableEh1.Append;
//  MemTableEh1.FieldValues['MenuName'] := ApplicationLanguageConsts.VertMenuMasterDetail;
  MemTableEh1.FieldValues['MenuName'] := 'Master/Detail';
  MemTableEh1.FieldValues['DetailInfo'] := 'Master DBGrid and Detail DBGrid. Master Grid with a footer.';
  TRefObjectField(MemTableEh1.FieldByName('RefFrameClass')).Value := TObject(TfrMasterDetail);
  MemTableEh1.FieldValues['DescFileName'] := 'Demo-MasterDetail.md';
  MemTableEh1.Post;

  MemTableEh1.Append;
//  MemTableEh1.FieldValues['MenuName'] := ApplicationLanguageConsts.VertMenuMasterDetail;
  MemTableEh1.FieldValues['MenuName'] := 'Data Grouping';
  MemTableEh1.FieldValues['DetailInfo'] := 'The records in the grid can be grouped based on the data in the columns. At the same time, footers can be configured in groups.';
  TRefObjectField(MemTableEh1.FieldByName('RefFrameClass')).Value := TObject(TfrDataGrouping);
  MemTableEh1.FieldValues['DescFileName'] := '';
  MemTableEh1.Post;

  MemTableEh1.Append;
//  MemTableEh1.FieldValues['MenuName'] := ApplicationLanguageConsts.VertMenuFishFact;
  MemTableEh1.FieldValues['MenuName'] := 'Fish facts';
  MemTableEh1.FieldValues['DetailInfo'] := 'Display of long text with automatic word wrap and automatic row height adjustment to fit the entire cell content.';
  TRefObjectField(MemTableEh1.FieldByName('RefFrameClass')).Value := TObject(TfrFishFacts);
  MemTableEh1.FieldValues['DescFileName'] := 'Demo-FishFacts.md';
  MemTableEh1.Post;

  MemTableEh1.Append;
//  MemTableEh1.FieldValues['MenuName'] := ApplicationLanguageConsts.VertMenuFishFact;
  MemTableEh1.FieldValues['MenuName'] := 'Vertical Grid';
  MemTableEh1.FieldValues['DetailInfo'] := 'The grid demonstrates the display of long text, pictures and the selection of the line height for the height of the contents of the cells.';
  TRefObjectField(MemTableEh1.FieldByName('RefFrameClass')).Value := TObject(TfrVerticalGrid);
  MemTableEh1.FieldValues['DescFileName'] := 'Demo-VerticalGrid.md';
  MemTableEh1.Post;

  MemTableEh1.Append;
//  MemTableEh1.FieldValues['MenuName'] := ApplicationLanguageConsts.VertMenuFishFact;
  MemTableEh1.FieldValues['MenuName'] := 'Search Panel';
  MemTableEh1.FieldValues['DetailInfo'] := 'Search and filter in the grid using the built-in Search Panel control.';
  TRefObjectField(MemTableEh1.FieldByName('RefFrameClass')).Value := TObject(TfrSearchPanel);
  MemTableEh1.FieldValues['DescFileName'] := 'Demo-SearchPanel.md';
  MemTableEh1.Post;

  MemTableEh1.Append;
  MemTableEh1.FieldValues['MenuName'] := 'LaObjects.FishFacts';
  MemTableEh1.FieldValues['DetailInfo'] := 'List of fish of our seas. Using LaObjects format and DBGridEh.';
  TRefObjectField(MemTableEh1.FieldByName('RefFrameClass')).Value := TObject(TfrLaObjectFishFacts);
  MemTableEh1.FieldValues['DescFileName'] := 'Demo-LaObjects.FishFacts.md';
  MemTableEh1.Post;

  MemTableEh1.Append;
  MemTableEh1.FieldValues['MenuName'] := 'Cell Formating';
  MemTableEh1.FieldValues['DetailInfo'] := 'Possibility of formatting data in grid cells via event handlers.';
  TRefObjectField(MemTableEh1.FieldByName('RefFrameClass')).Value := TObject(TfrCellFormating);
  MemTableEh1.FieldValues['DescFileName'] := 'Demo-CellFormatting.md';
  MemTableEh1.Post;

  MemTableEh1.Append;
  MemTableEh1.FieldValues['MenuName'] := 'Contacts And Call';
  MemTableEh1.FieldValues['DetailInfo'] := 'Possibility of individual content and formatting of each cell in the grid.';
  TRefObjectField(MemTableEh1.FieldByName('RefFrameClass')).Value := TObject(TfrContactsNCalls);
  MemTableEh1.FieldValues['DescFileName'] := 'Demo-ContacsAndCalls.md';
  MemTableEh1.Post;

  MemTableEh1.Append;
  MemTableEh1.FieldValues['MenuName'] := 'File Explorer';
  MemTableEh1.FieldValues['DetailInfo'] := 'Using DataGridEh as a List of folders and files';
  TRefObjectField(MemTableEh1.FieldByName('RefFrameClass')).Value := TObject(TfrFileExplorer);
  MemTableEh1.FieldValues['DescFileName'] := 'Demo-FileExplorer.md';
  MemTableEh1.Post;

  MemTableEh1.First;
  MemTableEh1.EnableControls;
end;


end.
