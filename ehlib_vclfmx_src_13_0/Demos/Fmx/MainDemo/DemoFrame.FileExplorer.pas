unit DemoFrame.FileExplorer;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FrameDemoBase,
  Generics.Collections, Rtti, IOUtils,
  EhLibRtl.Api, EhLibUtils,
  EhLibFmx.Api,
  FoldersTreeList,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Objects, FMX.Controls.Presentation,
  FMX.ImgList,
  CustomCells.ImageAndTextEdit,
  EhLibFmx.DataGrids, EhLibFmx.DataAxisGrid.FieldBars, EhLibFmx.DataGrid.Columns, EhLibFmx.ToolControls, EhLibFmx.Grids,
  EhLibFmx.DataAxisGrids, EhLibFmx.CustomDataGrids, FMX.Layouts, System.ImageList;

type
  TfrFileExplorer = class(TfrDemoBase)
    Panel1: TPanel;
    Text1: TText;
    Button1: TButton;
    SpeedButtonBack: TSpeedButton;
    BtnLoadData: TButton;
    BtnUp: TSpeedButton;
    Layout1: TLayout;
    DataGridEh1: TDataGridEh;
    ColLaStringDisplayName: TDataGridStringColumnEh;
    ColLaDisplayName: TDataGridLayoutColumnEh;
    DataGridStringColumnEh1: TDataGridStringColumnEh;
    Splitter1: TSplitter;
    GridRightFiles: TDataGridEh;
    RightGridStringColumn1: TDataGridStringColumnEh;
    DataGridStringColumnEh3: TDataGridStringColumnEh;
    ImageList1: TImageList;
    procedure SpeedButtonBackClick(Sender: TObject);
    procedure BtnLoadDataClick(Sender: TObject);
    procedure BtnUpClick(Sender: TObject);

    procedure ColLaDisplayNameGetDataCellManager(Sender: TObject; Params: TDataGridGetDataCellManagerParamsEh);
    procedure DataGridEh1CurrentChange(Sender: TObject; Params: TDataGridEventParamsEh);
    procedure ColLaStringDisplayNameDataCellMouseDown(Sender: TObject; Params: TDataGridDataCellMouseButtonParamsEh);
    procedure RightGridStringColumn1GetDataCellManager(Sender: TObject; Params: TDataGridGetDataCellManagerParamsEh);
    procedure GridRightFilesDataCellMouseClick(Sender: TObject; Params: TDataGridDataCellMouseButtonParamsEh);
    procedure GridRightFilesDataCellMouseDown(Sender: TObject; Params: TDataGridDataCellMouseButtonParamsEh);
    procedure DataGridEh1GetDataTreeViewAreaParams(Sender: TObject; Params: TDataGridDataTreeViewAreaParamsEh);
    procedure DataGridEh1SetDataTreeSignState(Sender: TObject; Params: TDataGridSetDataTreeSignStateParamsEh);
  private
    FFormItemsTreeList: TFileInfoTreeListEh;
    DirTreeTableLink: TListTableLinkEh;

    RigthFilesList: TObjectList<TFileInfo>;
    RigthFilesTableLink: TListTableLinkEh;

    TreeTextDataCellManager: TDataAxisImageTextCellManagerEh;
    TextImageCellManager: TDataAxisImageTextCellManagerEh;

    LastPropTreeNode: TFileInfoNodeEh;
    LastVertRollPos: Int64;

    procedure SetTreeSignState(Sender: TObject; Column: TDataGridColumnEh; Row: TDataGridRowEh; SignState: TTreeSignStateEh);

    procedure LocatePathInTree(Path: String);
    procedure SetFileInfoNodeExpandedState(FileInfoNode: TFileInfoNodeEh; ExpandedState: TTreeSignStateEh);

    procedure SafeViewState();
    procedure RestoreViewState();
    procedure FillRightFilesList(Path: String; AList: TList<TFileInfo>);
    procedure InitRightCellContent(Sender: TObject; Params: TDataAxisInitCellContentParamsEh);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure FillLaObjectTreeView;
    procedure LoadRightFilesList();
  end;

implementation

{$R *.fmx}

{ TFrame1 }

constructor TfrFileExplorer.Create(AOwner: TComponent);
var
  FolderImage: TBitmap;
  MultiResBitmap: TMultiResBitmap;
begin
  inherited Create(AOwner);
  SpeedButtonBack.Visible := TEhLibFmxSettings.Default.PlatformWindowSizeType = TPlatformWindowSizeTypeEh.FullScreen;

  DirTreeTableLink := TListTableLinkEh.Create(Self);
  FFormItemsTreeList := TFileInfoTreeListEh.Create(TFileInfoNodeEh);

  TreeTextDataCellManager := TDataAxisImageTextCellManagerEh.Create(Self);
  TreeTextDataCellManager.OnInitCellContent := InitRightCellContent;

  TextImageCellManager := TDataAxisImageTextCellManagerEh.Create(Self);
  TextImageCellManager.OnInitCellContent := InitRightCellContent;

  FolderImage := TBitmap.Create;
  MultiResBitmap := ImageList1.Destination[0].Layers[0].MultiResBitmap;
  FolderImage.Assign(MultiResBitmap.Bitmaps[1]);
  FileAssocDet.AddExtensionDescriptionImage('.<Folder>', 'File folder', FolderImage);

  FolderImage := TBitmap.Create;
  MultiResBitmap := ImageList1.Destination[1].Layers[0].MultiResBitmap;
  FolderImage.Assign(MultiResBitmap.Bitmaps[1]);
  FileAssocDet.AddExtensionDescriptionImage('.<Disk>', 'Disk', FolderImage);
end;

destructor TfrFileExplorer.Destroy;
begin
  FreeAndNil(FFormItemsTreeList);
  FreeAndNil(RigthFilesList);

  inherited Destroy;
end;

procedure TfrFileExplorer.FillLaObjectTreeView;
var
  RootFolderNode: TFileInfoNodeEh;
begin
  FFormItemsTreeList.Clear;

  RootFolderNode := FFormItemsTreeList.LoadSubfolders(nil);
  FFormItemsTreeList.LoadSubfolders(RootFolderNode);
  FFormItemsTreeList.VisibleItemsBecomeObsolete;

  DirTreeTableLink.SetList(FFormItemsTreeList.VisibleExpandedItems, TypeInfo(TFileInfoNodeEh));

  DataGridEh1.DataSource := DirTreeTableLink;
end;

procedure TfrFileExplorer.BtnUpClick(Sender: TObject);
var
  CurTreeNode: TFileInfoNodeEh;
  UpPath, LastFolder: String;
  LastFolderLen: Integer;
begin
  if DataGridEh1.CurrentRow = nil then Exit;

  CurTreeNode := TFileInfoNodeEh(DataGridEh1.CurrentRow.SourceObjectItem);
  LastFolder := IOUtils.TPath.GetFileName(CurTreeNode.FullPath);
  LastFolderLen := Length(LastFolder);
  UpPath := CurTreeNode.FullPath;
  Delete(UpPath, Length(UpPath) - LastFolderLen, LastFolderLen + 1);

  if UpPath <> '' then
    LocatePathInTree(UpPath);
end;

procedure TfrFileExplorer.BtnLoadDataClick(Sender: TObject);
begin
  FillLaObjectTreeView;
end;

procedure TfrFileExplorer.SpeedButtonBackClick(Sender: TObject);
begin
  BackButtonClicked;
end;

procedure TfrFileExplorer.ColLaDisplayNameGetDataCellManager(
  Sender: TObject; Params: TDataGridGetDataCellManagerParamsEh);
begin
  Params.CellManager := TreeTextDataCellManager;
end;

procedure TfrFileExplorer.ColLaStringDisplayNameDataCellMouseDown(
  Sender: TObject; Params: TDataGridDataCellMouseButtonParamsEh);
var
  FileTreeNode: TFileInfoNodeEh;
  NextSignState: TTreeSignStateEh;
begin
  if ssDouble in Params.Shift then
  begin
    FileTreeNode := TFileInfoNodeEh(Params.Row.SourceObjectItem);
    if FileTreeNode.Expanded then
      NextSignState := TTreeSignStateEh.Collapsed
    else
      NextSignState := TTreeSignStateEh.Expanded;

    SetTreeSignState(nil, TDataGridColumnEh(Params.Column), Params.Row, NextSignState);
  end;
end;

procedure TfrFileExplorer.DataGridEh1CurrentChange(Sender: TObject; Params: TDataGridEventParamsEh);
begin
  LoadRightFilesList();
end;

procedure TfrFileExplorer.LoadRightFilesList;
var
  CurTreeNode: TFileInfoNodeEh;
begin
  if RigthFilesList = nil then
  begin
    RigthFilesList := TObjectList<TFileInfo>.Create;
    RigthFilesTableLink := TListTableLinkEh.Create(Self);
  end;

  RigthFilesList.Clear;

  if DataGridEh1.CurrentRow = nil then Exit;

  CurTreeNode := TFileInfoNodeEh(DataGridEh1.CurrentRow.SourceObjectItem);
  FillRightFilesList(CurTreeNode.FullPath, RigthFilesList);

  RigthFilesTableLink.SetList<TFileInfo>(RigthFilesList);

  GridRightFiles.DataSource := RigthFilesTableLink;
end;

procedure TfrFileExplorer.LocatePathInTree(Path: String);
var
  PathItems: TList<String>;
  PathRest: String;
  Item: String;
  LastItemLen: Integer;
  I: Integer;
  RootStr: String;
  Node: TFileInfoNodeEh;

  function FineChildNodeByFolderName(ParentNode: TFileInfoNodeEh; Folder: String): TFileInfoNodeEh;
  var
    I: Integer;
  begin
    Result := nil;
    for I := 0 to ParentNode.Count - 1 do
    begin
      if ParentNode.Items[I].DisplayName = Folder then
      begin
        Result := ParentNode.Items[I];
        Break;
      end;
    end;
  end;

begin
  PathItems := TList<String>.Create;

  PathRest := Path;
  while True do
  begin
    Item := IOUtils.TPath.GetFileName(PathRest);
    LastItemLen := Length(Item);
    if LastItemLen = 0 then
    begin
      if Length(PathRest) > 1 then
        PathRest := ExcludeTrailingPathDelimiter(PathRest);
      PathItems.Add(PathRest);
      Break;
    end;
    PathItems.Add(Item);
    Delete(PathRest, Length(PathRest) - LastItemLen, LastItemLen + 1);
  end;

  PathItems.Reverse;

  RootStr := PathItems[0];
  Node := nil;
//  if RootStr = FFormItemsTreeList.Root.Items[0].DisplayName then
  begin
    Node := FFormItemsTreeList.Root.Items[0];
    for I := 1 to PathItems.Count - 1 do
    begin
      Node := FineChildNodeByFolderName(Node, PathItems[I]);
      if Node <> nil then
        SetFileInfoNodeExpandedState(Node, TTreeSignStateEh.Expanded)
      else
        Break;
    end;
  end;

  if Node <> nil then
  begin
    DataGridEh1.LocateRow(
      function(ADataRow: TDataGridRowEh): Boolean
      begin
        if ADataRow.SourceObjectItem = Node then
          Result := True
        else
          Result := False;
      end
    );
  end;

  PathItems.Free;
end;

procedure TfrFileExplorer.FillRightFilesList(Path: String; AList: TList<TFileInfo>);
var
  Files: TStringDynArray;
  FileName: String;
  FileInfo: TFileInfo;
begin
  Files := TDirectory.GetDirectories(Path);
  for FileName in Files do
  begin
    FileInfo := TFileInfo.Create;
    FileInfo.FileName := IOUtils.TPath.GetFileName(FileName);
    FileInfo.FileExtension := '.<Folder>';
    FileInfo.FullPath := FileName;
    FileInfo.TypeDescription := 'File folder';
    FileInfo.IsFolder := True;
    FileInfo.Image := FileAssocDet.GetBitmapForExtension('.<Folder>');
    AList.Add(FileInfo);
  end;

  Files := TDirectory.GetFiles(Path);
  for FileName in Files do
  begin
    FileInfo := TFileInfo.Create;
    FileInfo.FileName := IOUtils.TPath.GetFileName(FileName);
    FileInfo.FileExtension := IOUtils.TPath.GetExtension(FileInfo.FileName);
    FileInfo.FullPath := FileName;
    FileInfo.TypeDescription := FileAssocDet.GetDescriptionForExtension(FileInfo.FileExtension);
    FileInfo.IsFolder := False;
    FileInfo.Image := FileAssocDet.GetBitmapForExtension(FileInfo.FileExtension);
    AList.Add(FileInfo);
  end;
end;

procedure TfrFileExplorer.InitRightCellContent(Sender: TObject;
  Params: TDataAxisInitCellContentParamsEh);
var
  FileInfo: TFileInfo;
  FileInfoNode: TFileInfoNodeEh;
  InCellImage: TLaImageEh;
begin
  if Params.CellContent = nil then Exit;
  if Params.ListItemBar = nil then Exit;

  InCellImage := (Params.Cell as TDataAxisImageTextCellEh).InCellImage;
  if Params.ListItemBar.SourceObjectItem is TFileInfoNodeEh then
  begin
    FileInfoNode := Params.ListItemBar.SourceObjectItem as TFileInfoNodeEh;
    InCellImage.Margins.Left := 0;
    InCellImage.Bitmap := FileInfoNode.Image;
  end else
  begin
    InCellImage.Margins.Left := 10;
    FileInfo := Params.ListItemBar.SourceObjectItem as TFileInfo;
    InCellImage.Bitmap := FileInfo.Image;
  end;
end;

procedure TfrFileExplorer.DataGridEh1GetDataTreeViewAreaParams(Sender: TObject;
  Params: TDataGridDataTreeViewAreaParamsEh);
var
  FileInfoNode: TFileInfoNodeEh;
begin
  if Params.Row = nil then Exit;

  FileInfoNode := TFileInfoNodeEh(Params.Row.SourceObjectItem);
  Params.TreeAreaVisible := True;
  Params.Level := FileInfoNode.Level - 1;
  Params.SignVisible := FileInfoNode.HasChildren;
  if FileInfoNode.Expanded then
    Params.SignState := TTreeSignStateEh.Expanded
  else
    Params.SignState := TTreeSignStateEh.Collapsed;
end;

procedure TfrFileExplorer.DataGridEh1SetDataTreeSignState(Sender: TObject;
  Params: TDataGridSetDataTreeSignStateParamsEh);
var
  FileInfoNode: TFileInfoNodeEh;
begin
  FileInfoNode := TFileInfoNodeEh(Params.Row.SourceObjectItem);
  SetFileInfoNodeExpandedState(FileInfoNode, Params.SignState);
end;

procedure TfrFileExplorer.SetTreeSignState(Sender: TObject;
  Column: TDataGridColumnEh; Row: TDataGridRowEh; SignState: TTreeSignStateEh);
var
  FileInfoNode: TFileInfoNodeEh;
begin
  FileInfoNode := TFileInfoNodeEh(Row.SourceObjectItem);
  SetFileInfoNodeExpandedState(FileInfoNode, SignState);
end;

procedure TfrFileExplorer.GridRightFilesDataCellMouseClick(Sender: TObject;
  Params: TDataGridDataCellMouseButtonParamsEh);
begin
  if ssDouble in Params.Shift then
  begin
    DoNothing();
  end;
end;

procedure TfrFileExplorer.GridRightFilesDataCellMouseDown(Sender: TObject;
  Params: TDataGridDataCellMouseButtonParamsEh);
var
  FileInfo: TFileInfo;
begin
  if (ssDouble in Params.Shift) and (Params.Row <> nil) then
  begin
    FileInfo := TFileInfo(Params.Row.SourceObjectItem);
    if FileInfo.IsFolder then
      LocatePathInTree(FileInfo.FullPath);
  end;
end;

procedure TfrFileExplorer.SetFileInfoNodeExpandedState(FileInfoNode: TFileInfoNodeEh; ExpandedState: TTreeSignStateEh);
begin
  if ExpandedState = TTreeSignStateEh.Expanded then
  begin
    if FileInfoNode.SubfoldersLoaded = False then
      FFormItemsTreeList.LoadSubfolders(FileInfoNode);
    FileInfoNode.Expanded := True;
  end else
    FileInfoNode.Expanded := False;

  SafeViewState;

  FFormItemsTreeList.VisibleItemsBecomeObsolete;
  DirTreeTableLink.SetList(FFormItemsTreeList.VisibleExpandedItems, TypeInfo(TFileInfoNodeEh));

  RestoreViewState;
end;

procedure TfrFileExplorer.SafeViewState;
begin
  if DataGridEh1.CurrentRow <> nil then
    LastPropTreeNode := TFileInfoNodeEh(DataGridEh1.CurrentRow.SourceObjectItem)
  else
    LastPropTreeNode := nil;

  LastVertRollPos := DataGridEh1.VertAxis.RollStartVisPos;
end;

procedure TfrFileExplorer.RestoreViewState;
begin
  if LastPropTreeNode <> nil then
  begin
    DataGridEh1.LocateRow(
      function(ADataRow: TDataGridRowEh): Boolean
      begin
        if ADataRow.SourceObjectItem = LastPropTreeNode then
          Result := True
        else
          Result := False;
      end);
  end;

  DataGridEh1.Invalidate;
  DataGridEh1.CheckUpdateViewLayout;
  DataGridEh1.SafeSetTopRollPos(LastVertRollPos);
end;

procedure TfrFileExplorer.RightGridStringColumn1GetDataCellManager(Sender: TObject;
  Params: TDataGridGetDataCellManagerParamsEh);
begin
  Params.CellManager := TextImageCellManager;
end;

end.
