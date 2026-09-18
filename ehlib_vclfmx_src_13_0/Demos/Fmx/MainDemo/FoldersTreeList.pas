unit FoldersTreeList;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
{$IFDEF MSWINDOWS}
  ShellAPI, Windows, Vcl.Graphics,
{$ENDIF}
  Generics.Collections, Rtti,
  IOUtils, FMX.Graphics,
  Contnrs, MemTreeEh, EhLibUtils, EhLibRtl.Api;

type
  TFileInfoTreeListEh = class;
  TFileInfoNodeEh = class;

{ TFileInfoNodeEh }

  TTreeNodeExpandedStateChangedEventEh = procedure (Sender: TFileInfoTreeListEh; PropTreeNode: TFileInfoNodeEh) of object;

  TFileInfoNodeEh = class(TBaseTreeNodeEh)
  private
    FDisplayName: String;
    FFullPath: String;
    FHasSubfolders: Boolean;
    FSubfoldersLoaded: Boolean;
    FImage: TBitmap;

    function GetItem(const Index: Integer): TFileInfoNodeEh; reintroduce;
    function GetNodeOwner: TFileInfoTreeListEh;
    function GetNodeParent: TFileInfoNodeEh;
    function GetVisibleItem(const Index: Integer): TFileInfoNodeEh;
    procedure SetNodeParent(const Value: TFileInfoNodeEh);

  protected
    procedure RefreshValue;

  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Collapse;
    procedure Expand;
    procedure ExpandedStateChanged();

    property Expanded;
    property HasChildren;
    property Level;
    property VisibleCount;
    property Count;
    property Items[const Index: Integer]: TFileInfoNodeEh read GetItem; default;
    property Owner: TFileInfoTreeListEh read GetNodeOwner;
    property Parent: TFileInfoNodeEh read GetNodeParent write SetNodeParent;
    property VisibleItem[const Index: Integer]: TFileInfoNodeEh read GetVisibleItem;
  published
    property DisplayName: String read FDisplayName write FDisplayName;
    property FullPath: String read FFullPath write FFullPath;
    property HasSubfolders: Boolean read FHasSubfolders write FHasSubfolders;
    property SubfoldersLoaded: Boolean read FSubfoldersLoaded write FSubfoldersLoaded;
    property Image: TBitmap read FImage write FImage;
  end;

  TPropTreeNodeClassEh = class of TFileInfoNodeEh;

{ TFileInfoTreeListEh }

  TFileInfoTreeListEh = class(TTreeListEh)
  private
    FVisibleExpandedItems: TObjectList;
    FVisibleItemsObsolete: Boolean;
    FOnVisibleListChanged: TNotifyEvent;
    FOnTreeNodeExpandedStateChanged: TTreeNodeExpandedStateChangedEventEh;
    function GetRoot: TFileInfoNodeEh;
    function GetVisibleExpandedItems: TObjectList;

  protected
    function GetVisibleCount: Integer;
    function GetVisibleExpandedItem(const Index: Integer): TFileInfoNodeEh; virtual;
    procedure VisibleListChanged;

  public
    constructor Create(ItemClass: TPropTreeNodeClassEh);
    destructor Destroy; override;

    function LoadSubfolders(Parent: TFileInfoNodeEh): TFileInfoNodeEh;
    function CheckIfPathHasSubfolders(Dir: String): Boolean;

    procedure BuildVisibleItems;
    procedure VisibleItemsBecomeObsolete;
    procedure RefreshAllValues;
    procedure ExpandedStateChanged(PropTreeNode: TFileInfoNodeEh);
    procedure Clear;

    property Root: TFileInfoNodeEh read GetRoot;
    property VisibleExpandedCount: Integer read GetVisibleCount;
    property VisibleExpandedItem[const Index: Integer]: TFileInfoNodeEh read GetVisibleExpandedItem; default;
    property VisibleExpandedItems: TObjectList read GetVisibleExpandedItems;
    property VisibleItemsObsolete: Boolean read FVisibleItemsObsolete;

    property OnVisibleListChanged: TNotifyEvent read FOnVisibleListChanged write FOnVisibleListChanged;
    property OnTreeNodeExpandedStateChanged: TTreeNodeExpandedStateChangedEventEh read FOnTreeNodeExpandedStateChanged write FOnTreeNodeExpandedStateChanged;

  end;

{ TFileAssociationDetails }

  TFileAssociationDetails = class(TObject)
  private
    FExtensions: TStringList;
    FDescriptions: TStringList;
    FImages: TObjectList<TBitmap>;

    function GetOSDescriptionForExtension(Extension: String): String;
    function GetOSBitmapForExtension(Extension: String): TBitmap;

  public
    constructor Create;
    destructor Destroy; override;

    function GetDescriptionForExtension(Extension: String): String;
    function GetBitmapForExtension(Extension: String): TBitmap;

    procedure Clear;
    procedure AddExtensionDescriptionImage(Extension, Description: String; Image: TBitmap);
  end;

  TFileInfo = class(TPersistent)
  private
    FFileName: String;
    FFullPath: String;
    FTypeDescription: String;
    FIsFolder: Boolean;
    FImage: TBitmap;
    FFileExtension: String;
  public
    property FileName: String read FFileName write FFileName;
    property FileExtension: String read FFileExtension write FFileExtension;
    property FullPath: String read FFullPath write FFullPath;
    property TypeDescription: String read FTypeDescription write FTypeDescription;
    property IsFolder: Boolean read FIsFolder write FIsFolder;
    property Image: TBitmap read FImage write FImage;
  end;

var
  FileAssocDet: TFileAssociationDetails;

implementation

function IsUnwantedSearchFile(const SearchRec: TSearchRec): Boolean;
begin
{$WARN SYMBOL_PLATFORM OFF}
//  if ((SearchRec.Attr and faHidden) <> 0) then
//    Result := True
//  else
  if ((SearchRec.Attr and faSymLink) <> 0) then
    Result := True
  else
    Result := False;
{$WARN SYMBOL_PLATFORM ON}
end;

{ TFormItemNodeEh }

constructor TFileInfoNodeEh.Create;
begin
  inherited Create;
  Expanded := True;
end;

destructor TFileInfoNodeEh.Destroy;
begin
  inherited Destroy;
end;

procedure TFileInfoNodeEh.Collapse;
begin
  Expanded := False;
  ExpandedStateChanged();
end;

procedure TFileInfoNodeEh.Expand;
begin
  Expanded := True;
  ExpandedStateChanged();
end;

procedure TFileInfoNodeEh.ExpandedStateChanged;
begin
  Owner.ExpandedStateChanged(Self);
end;

function TFileInfoNodeEh.GetItem(const Index: Integer): TFileInfoNodeEh;
begin
  Result := TFileInfoNodeEh(inherited Items[Index]);
end;

function TFileInfoNodeEh.GetNodeOwner: TFileInfoTreeListEh;
begin
  Result := TFileInfoTreeListEh(inherited TreeList);
end;

function TFileInfoNodeEh.GetNodeParent: TFileInfoNodeEh;
begin
  Result := TFileInfoNodeEh(inherited Parent);
end;

function TFileInfoNodeEh.GetVisibleItem(const Index: Integer): TFileInfoNodeEh;
begin
  Result := TFileInfoNodeEh(inherited VisibleItems[Index])
end;

procedure TFileInfoNodeEh.RefreshValue;
begin

end;

procedure TFileInfoNodeEh.SetNodeParent(const Value: TFileInfoNodeEh);
begin
  inherited Parent := Value;
end;

function TFileInfoTreeListEh.CheckIfPathHasSubfolders(Dir: String): Boolean;
//var
//  FoldersEnum: IEnumerable<string>;
//  Path: String;
//  DirPredicate: TDirectory.TFilterPredicate;
//  SearchRec: TSearchRec;
//  FindResult: Integer;
begin
  Result := Length(TDirectory.GetDirectories(Dir)) > 0;
//  DirPredicate :=
//    function(const Path: string; const SearchRec: TSearchRec): Boolean
//    begin
//      if IsUnwantedSearchFile(SearchRec) = True then
//        Result := False
//      else
//        Result := True;
//    end;

//  Result := False;
//  FindResult := System.SysUtils.FindFirst(Dir + '\*.*', faDirectory, SearchRec);
//  if (FindResult = 0) and (SearchRec.Name = '.') then
//  begin
//    FindResult := System.SysUtils.FindNext(SearchRec);
//    if (FindResult = 0) and (SearchRec.Name = '..') then
//    begin
//      FindResult := System.SysUtils.FindNext(SearchRec);
//      if FindResult = 0 then
//        Result := True;
//    end;
//  end;
//  System.SysUtils.FindClose(SearchRec);

//  FoldersEnum := TDirectory.GetDirectoriesEnumerator(Dir, DirPredicate);
//  for path in FoldersEnum  do
//  begin
//    Result := True;
//    Exit;
//  end;
end;

procedure TFileInfoTreeListEh.Clear;
begin
  inherited Clear;
end;

{ TPropTreeListEh }

constructor TFileInfoTreeListEh.Create(ItemClass: TPropTreeNodeClassEh);
begin
  inherited Create(ItemClass);
  FVisibleExpandedItems := TObjectListEh.Create;
end;

destructor TFileInfoTreeListEh.Destroy;
begin
  FreeAndNil(FVisibleExpandedItems);
  inherited Destroy;
end;

procedure TFileInfoTreeListEh.ExpandedStateChanged(PropTreeNode: TFileInfoNodeEh);
begin
  if Assigned(OnTreeNodeExpandedStateChanged) then
    OnTreeNodeExpandedStateChanged(Self, PropTreeNode);
end;

procedure TFileInfoTreeListEh.BuildVisibleItems;
var
  CurNode: TBaseTreeNodeEh;
begin
  FVisibleExpandedItems.Clear;
  CurNode := GetFirstVisible;
  while CurNode <> nil do
  begin
    FVisibleExpandedItems.Add(CurNode);
    CurNode := GetNextVisible(CurNode, True);
  end;

  FVisibleItemsObsolete := False;
end;

function TFileInfoTreeListEh.GetVisibleCount: Integer;
begin
  if FVisibleItemsObsolete then
    BuildVisibleItems;
  Result := FVisibleExpandedItems.Count;
end;

function TFileInfoTreeListEh.GetVisibleExpandedItem(const Index: Integer): TFileInfoNodeEh;
begin
  if FVisibleItemsObsolete then
    BuildVisibleItems;
  if (Index < 0) or (Index > FVisibleExpandedItems.Count-1) then
  begin
    Result := nil;
    Exit;
  end;
  Result := TFileInfoNodeEh(FVisibleExpandedItems.Items[Index]);
end;

function TFileInfoTreeListEh.GetVisibleExpandedItems: TObjectList;
begin
  if FVisibleItemsObsolete then
    BuildVisibleItems;
  Result := FVisibleExpandedItems;
end;

function TFileInfoTreeListEh.LoadSubfolders(Parent: TFileInfoNodeEh): TFileInfoNodeEh;
var
  Dirs: TStringDynArray;
  Dir: String;
  ChildNode: TFileInfoNodeEh;
  PathToLoad: String;
  DirPredicate: TDirectory.TFilterPredicate;
  RootPath, RootName: String;
begin
  DirPredicate :=
    function(const Path: string; const SearchRec: TSearchRec): Boolean
    begin
      if IsUnwantedSearchFile(SearchRec) = True then
        Result := False
      else
        Result := True;
    end;

  Result := nil;
  if Parent = nil then
  begin
    ChildNode := AddChild(Dir, Parent, nil) as TFileInfoNodeEh;
{$IFDEF ANDROID}
    RootPath := '/storage/emulated/0/';
{$ELSE}
    RootPath := TPath.GetPathRoot(TDirectory.GetCurrentDirectory);
{$ENDIF}
    if Length(RootPath) > 1 then
      RootName := ExcludeTrailingPathDelimiter(RootPath)
    else
      RootName := RootPath;
    ChildNode.DisplayName := RootName;
    ChildNode.FullPath := RootPath;
    ChildNode.Expanded := True;
    ChildNode.Image := FileAssocDet.GetBitmapForExtension('.<Disk>');
    Result := ChildNode;
  end else
  begin
    PathToLoad := Parent.FullPath;
    Dirs := TDirectory.GetDirectories(PathToLoad, DirPredicate);
    for Dir in Dirs do
    begin
      if Dir = '' then Continue;

      ChildNode := AddChild(Dir, Parent, nil) as TFileInfoNodeEh;
      ChildNode.DisplayName := TPath.GetFileName(Dir);
      ChildNode.FullPath := Dir;
      ChildNode.HasSubfolders := CheckIfPathHasSubfolders(Dir);
      ChildNode.HasChildren := ChildNode.HasSubfolders;
      ChildNode.Expanded := False;
      ChildNode.Image := FileAssocDet.GetBitmapForExtension('.<Folder>');

      Result := ChildNode;
    end;
    Parent.SubfoldersLoaded := True;
  end;
end;

procedure TFileInfoTreeListEh.VisibleItemsBecomeObsolete;
begin
  FVisibleItemsObsolete := True;
end;

procedure TFileInfoTreeListEh.VisibleListChanged;
begin
  if Assigned(OnVisibleListChanged) then
    OnVisibleListChanged(Self);
end;

function TFileInfoTreeListEh.GetRoot: TFileInfoNodeEh;
begin
  Result := TFileInfoNodeEh(inherited Root);
end;

procedure TFileInfoTreeListEh.RefreshAllValues;
var
  CurNode: TBaseTreeNodeEh;
begin
  CurNode := GetFirst;
  while CurNode <> nil do
  begin
    TFileInfoNodeEh(CurNode).RefreshValue;
    CurNode := GetNext(CurNode);
  end;
end;

{ TFileAssociationDetails }

constructor TFileAssociationDetails.Create;
begin
  inherited Create;

  FExtensions := TStringList.Create;
  FExtensions.Sorted := true;
  FDescriptions := TStringList.Create;
  FImages := TObjectList<TBitmap>.Create;
end;

destructor TFileAssociationDetails.Destroy;
begin
  FExtensions.Free;
  FDescriptions.Free;
  FImages.Free;
  inherited Destroy;
end;

procedure TFileAssociationDetails.AddExtensionDescriptionImage(Extension,
  Description: String; Image: TBitmap);
var
  ExtIndex: Integer;
begin
  Extension := UpperCase(Extension);

  if FExtensions.Find(Extension, ExtIndex) = False then
  begin
    FExtensions.Add(Extension);
    FDescriptions.Insert(ExtIndex, Description);
    FImages.Insert(ExtIndex, Image);
  end;
end;

procedure TFileAssociationDetails.Clear;
begin
  FExtensions.Clear;
end;

function TFileAssociationDetails.GetBitmapForExtension(
  Extension: String): TBitmap;
var
  ExtIndex: Integer;
begin
  GetDescriptionForExtension(Extension);

  Extension := UpperCase(Extension);
  if FExtensions.Find(Extension, ExtIndex) then
    Result := FImages[ExtIndex]
  else
    Result := nil;
end;

function TFileAssociationDetails.GetDescriptionForExtension(Extension: String): String;
var
  ExtIndex: Integer;
  Description: String;
  Bitmap: TBitmap;
begin
  Extension := UpperCase(Extension);
  if FExtensions.Find(Extension, ExtIndex) then
  begin
    Result := FDescriptions[ExtIndex];
  end else
  begin
    FExtensions.Add(Extension);

    Description := GetOSDescriptionForExtension(Extension);
    FDescriptions.Insert(ExtIndex, Description);
    Result := FDescriptions[ExtIndex];

    Bitmap := GetOSBitmapForExtension(Extension);
    FImages.Insert(ExtIndex, Bitmap);
  end;
end;

function TFileAssociationDetails.GetOSBitmapForExtension(Extension: String): TBitmap;
{$IFDEF MSWINDOWS}
var
  Icon: Vcl.Graphics.TIcon;
  FileInfo : SHFILEINFO;
  tmpStream: TMemoryStream;
begin
  Icon := TIcon.Create;

  SHGetFileInfo(PChar(Extension),
                FILE_ATTRIBUTE_NORMAL,
                FileInfo,
                SizeOf(FileInfo),
                SHGFI_ICON or SHGFI_SMALLICON or
                SHGFI_SYSICONINDEX or SHGFI_USEFILEATTRIBUTES
                );

  Icon.Handle := FileInfo.hIcon;

  Result := FMX.Graphics.TBitmap.Create;
  tmpStream := TMemoryStream.Create;
  try
    Icon.SaveToStream(tmpStream);
    Result.LoadFromStream(tmpStream);
  finally
    tmpStream.Free;
  end;

  Icon.Free;
end;
{$ELSE}
begin
  Result := nil;
end;
{$ENDIF}

function TFileAssociationDetails.GetOSDescriptionForExtension(Extension: String): String;
{$IFDEF MSWINDOWS}
var
  FileInfo : SHFILEINFO;
begin
  Extension := '*' + UpperCase(Extension);

  // Get description type
  SHGetFileInfo(PChar(Extension),
                FILE_ATTRIBUTE_NORMAL,
                FileInfo,
                SizeOf(FileInfo),
                SHGFI_TYPENAME or SHGFI_USEFILEATTRIBUTES
                );

  Result := FileInfo.szTypeName;

end;
{$ELSE}
begin
  Result := Extension;
end;
{$ENDIF}

initialization
  FileAssocDet := TFileAssociationDetails.Create;
finalization
  FreeAndNil(FileAssocDet);
end.
