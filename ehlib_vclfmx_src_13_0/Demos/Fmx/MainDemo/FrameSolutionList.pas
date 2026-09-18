unit FrameSolutionList;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, EhLibFmx.DataGrid.SearchPanels,
  System.IOUtils,
  MemTableDataEh, Data.DB, MemTableEh,
  MarkdownProcessor, AppUnit,
  EhLibUtils,
  EhLibRtl.Api,
  EhLibFmx.Api,
  EhLibFmx.DataGrids, EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.DataGrid.Columns, EhLibFmx.ToolControls, EhLibFmx.Grids,
  EhLibFmx.DataAxisGrids, EhLibFmx.CustomDataGrids;

type
  TfrSolutionList = class(TFrame)
    DBGridEh1: TDataGridEh;
    DBGridStringColumnEh1: TDataGridStringColumnEh;
    DataGridLayoutColumnEh1: TDataGridLayoutColumnEh;
    MemTableEh1: TMemTableEh;
    MemTableEh1MenuName: TWideStringField;
    MemTableEh1RefFrameClass: TRefObjectField;
    MemTableEh1RefFrame: TRefObjectField;
    MemTableEh1DetailInfo: TWideStringField;
    DataSource1: TDataSource;
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

uses SolutionFrame.GridThreeTextBlocksInCell,
     SolutionFrame.AnimatedGifs,
     SolutionFrame.ProgressBars,
     SolutionFrame.ComboBoxes,
     SolutionFrame.ImageAndTextInCell,
     SolutionFrame.ImageAndTextInCell2,
     SolutionFrame.TreeViewWithMemTableEh,
     SolutionFrame.TreeViewWithTreeListEh,
     SolutionFrame.RowAsWhole,
     SolutionFrame.HighlightingLinksFormatTextSections,
     SolutionFrame.FindInFiles;

{$R *.fmx}

type
  TControlClass = class of TControl;

{ TfrSolutionList }

constructor TfrSolutionList.Create(AOwner: TComponent);
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

procedure TfrSolutionList.CurrentDemoFrameChanged;
begin
  if Assigned(OnCurrentDemoFrameChanged) then
    OnCurrentDemoFrameChanged(Self);
end;

procedure TfrSolutionList.DataCellMouseClicked(Sender: TObject; Params: TDataGridDataCellMouseButtonParamsEh);
begin
  if Assigned(OnGridItemClicked) then
    OnGridItemClicked(Self);
end;

procedure TfrSolutionList.DataGridLayoutColumnEh1CreateDataCellContent(
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

procedure TfrSolutionList.DataSource1DataChange(Sender: TObject; Field: TField);
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

function TfrSolutionList.GetDemoListDataSet: TDataSet;
begin
  Result := MemTableEh1;
end;

function TfrSolutionList.GetFrameDescriptionAsHtml: String;
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

procedure TfrSolutionList.RebuildDemoList;
begin
  MemTableEh1.DisableControls;

  while not MemTableEh1.Eof do
  begin
    MemTableEh1.Delete;
  end;

  MemTableEh1.Append;
//  MemTableEh1.FieldValues['MenuName'] := ApplicationLanguageConsts.VertMenuMainGrid;
  MemTableEh1.FieldValues['MenuName'] := 'Three TextBlocks In Cell';
  MemTableEh1.FieldValues['DetailInfo'] := 'Three TextBlocks In Cell';
  TRefObjectField(MemTableEh1.FieldByName('RefFrameClass')).Value := TObject(TfrSolGridThreeTextBlocksInCell);
  MemTableEh1.FieldValues['DescFileName'] := 'Solution00-GridThreeTextBlocksInCell.md';

  MemTableEh1.Append;
//  MemTableEh1.FieldValues['MenuName'] := ApplicationLanguageConsts.VertMenuMainGrid;
  MemTableEh1.FieldValues['MenuName'] := 'Find In Files';
  MemTableEh1.FieldValues['DetailInfo'] := 'Find In Files';
  TRefObjectField(MemTableEh1.FieldByName('RefFrameClass')).Value := TObject(TfrSolFindInFiles);
  MemTableEh1.FieldValues['DescFileName'] := 'Solution01-FindInFiles.md';

  MemTableEh1.Append;
//  MemTableEh1.FieldValues['MenuName'] := ApplicationLanguageConsts.VertMenuMainGrid;
  MemTableEh1.FieldValues['MenuName'] := 'Animated Gifs';
  MemTableEh1.FieldValues['DetailInfo'] := 'Animated Gifs in Grid Cells';
  TRefObjectField(MemTableEh1.FieldByName('RefFrameClass')).Value := TObject(TfrAnimatedGifs1);
  MemTableEh1.FieldValues['DescFileName'] := 'Solution02-AnimatedGifs.md';

  MemTableEh1.Append;
//  MemTableEh1.FieldValues['MenuName'] := ApplicationLanguageConsts.VertMenuMainGrid;
  MemTableEh1.FieldValues['MenuName'] := 'ProgressBar';
  MemTableEh1.FieldValues['DetailInfo'] := 'ProgressBar in Grid Cells';
  TRefObjectField(MemTableEh1.FieldByName('RefFrameClass')).Value := TObject(TfrProgressBar);
  MemTableEh1.FieldValues['DescFileName'] := 'Solution03-ProgressBars.md';

  MemTableEh1.Append;
//  MemTableEh1.FieldValues['MenuName'] := ApplicationLanguageConsts.VertMenuMainGrid;
  MemTableEh1.FieldValues['MenuName'] := 'Image And Text in Cell 1';
  MemTableEh1.FieldValues['DetailInfo'] := 'Image And Text in Cell Grids Cell 1 (Using LayoutColumn event)';
  TRefObjectField(MemTableEh1.FieldByName('RefFrameClass')).Value := TObject(TfrImageAndTextInCell);
  MemTableEh1.FieldValues['DescFileName'] := 'Solution04-ImageAndTextCell.md';

  MemTableEh1.Append;
//  MemTableEh1.FieldValues['MenuName'] := ApplicationLanguageConsts.VertMenuMainGrid;
  MemTableEh1.FieldValues['MenuName'] := 'Image And Text in Cell 2';
  MemTableEh1.FieldValues['DetailInfo'] := 'Image And Text in Cell Grids Cell 2 (Using CellManager)';
  TRefObjectField(MemTableEh1.FieldByName('RefFrameClass')).Value := TObject(TfrImageAndTextInCell2);
  MemTableEh1.FieldValues['DescFileName'] := 'Solution05-ImageAndTextCell-2.md';

  MemTableEh1.Append;
//  MemTableEh1.FieldValues['MenuName'] := ApplicationLanguageConsts.VertMenuMainGrid;
  MemTableEh1.FieldValues['MenuName'] := 'Comboboxes';
  MemTableEh1.FieldValues['DetailInfo'] := 'TDataComboBoxEh + TDataGridComboboxColumnEh';
  TRefObjectField(MemTableEh1.FieldByName('RefFrameClass')).Value := TObject(TfrComboBoxes);
  MemTableEh1.FieldValues['DescFileName'] := 'Solution06-Comboboxes.md';

  MemTableEh1.Append;
//  MemTableEh1.FieldValues['MenuName'] := ApplicationLanguageConsts.VertMenuMainGrid;
  MemTableEh1.FieldValues['MenuName'] := 'TreeView with MemTableEh';
  MemTableEh1.FieldValues['DetailInfo'] := 'Show TreeView structure from MemTableEh';
  TRefObjectField(MemTableEh1.FieldByName('RefFrameClass')).Value := TObject(TfrTreeViewWithMemTableEh);
  MemTableEh1.FieldValues['DescFileName'] := 'Solution07-TreeViewWithMemTableEh.md';

  MemTableEh1.Append;
//  MemTableEh1.FieldValues['MenuName'] := ApplicationLanguageConsts.VertMenuMainGrid;
  MemTableEh1.FieldValues['MenuName'] := 'TreeView with TreeViewEh';
  MemTableEh1.FieldValues['DetailInfo'] := 'Show TreeView structure from TreeViewEh';
  TRefObjectField(MemTableEh1.FieldByName('RefFrameClass')).Value := TObject(TfrTreeViewWithTreeListEh);
  MemTableEh1.FieldValues['DescFileName'] := 'Solution08-TreeViewWithMemTreeList.md';

  MemTableEh1.Append;
//  MemTableEh1.FieldValues['MenuName'] := ApplicationLanguageConsts.VertMenuMainGrid;
  MemTableEh1.FieldValues['MenuName'] := 'Row As Whole';
  MemTableEh1.FieldValues['DetailInfo'] := 'Show record without separating it into cells.';
  TRefObjectField(MemTableEh1.FieldByName('RefFrameClass')).Value := TObject(TfrSolutionRowAsWhole);
  MemTableEh1.FieldValues['DescFileName'] := 'Solution09-RowAsWhole.md';

  MemTableEh1.Append;
//  MemTableEh1.FieldValues['MenuName'] := ApplicationLanguageConsts.VertMenuMainGrid;
  MemTableEh1.FieldValues['MenuName'] := 'Highlight Url In Grid Cells';
  MemTableEh1.FieldValues['DetailInfo'] := 'Highlight Url In Grid Cells and Format Text Sections';
  TRefObjectField(MemTableEh1.FieldByName('RefFrameClass')).Value := TObject(TfrHighlightingLinksFormatTextSections);
  MemTableEh1.FieldValues['DescFileName'] := 'Solution10-HighlightUrlFormatText.md';

  MemTableEh1.First;
  MemTableEh1.EnableControls;
end;

end.
