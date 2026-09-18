unit SolutionFrame.FindInFiles;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  IOUtils, StrUtils, FMX.Edit, FMX.Controls.Presentation,
  System.Contnrs,
  System.Generics.Collections,
  EhLibRtl.Api,
  EhLibFmx.Api,
  EhLibFmx.DataGrids, EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.DataGrid.Columns, EhLibFmx.ToolControls, EhLibFmx.Grids,
  EhLibFmx.DataAxisGrids, EhLibFmx.CustomDataGrids;

type
  TfrSolFindInFiles = class(TFrame)
    Panel1: TPanel;
    Button1: TButton;
    eTextToFind: TEdit;
    Label1: TLabel;
    eDirs: TEdit;
    Label2: TLabel;
    bSelectDir: TButton;
    DataGridEh1: TDataGridEh;
    colRichFileName: TDataGridLayoutColumnEh;
    colRichText: TDataGridLayoutColumnEh;
    colSimpleText: TDataGridStringColumnEh;
    colFileName: TDataGridStringColumnEh;
    procedure bSelectDirClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure colRichFileNameCreateDataCellContent(Sender: TObject;
      Params: TDataGridCreateDataCellContentParamsEh);
    procedure colRichFileNameDataCellInitContent(Sender: TObject;
      Params: TDataGridInitDataCellContentParamsEh);
    procedure colRichFileNameFooters0GetDisplayText(Sender: TObject;
      Params: TDataGridFooterGetDisplayTextParamsEh);
    procedure colRichTextCreateDataCellContent(Sender: TObject;
      Params: TDataGridCreateDataCellContentParamsEh);
    procedure colRichTextDataCellInitContent(Sender: TObject;
      Params: TDataGridInitDataCellContentParamsEh);
  private
    FCountryListTableLink: TListTableLinkEh;
    FCountryList: TObjectList;

    procedure InitControls;
    procedure InitGridList;
    procedure FindLinesInFile(AFileName: String);
    function FindStrInText(Str, Text: String; out FoundResult: TArray<Integer>): Boolean;
  public

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.fmx}

type

  TFoundInfo = class(TPersistent)
  private
    FText: String;
    FFileName: String;
    FFileFullName: String;
    FHitPos: Integer;
    FHitLen: Integer;
    FLineNo: Integer;
  public
     constructor Create(AText: String; AFileName: String; AFileFullName: String; ALineNo, AHitPos, AHitLen: Integer);

    property Text: String read FText write FText;
    property FileName: String read FFileName write FFileName;
    property FileFullName: String read FFileFullName write FFileFullName;
    property HitPos: Integer read FHitPos;
    property HitLen: Integer read FHitLen;
    property LineNo: Integer read FLineNo;
  end;

{ TFoundInfo }

constructor TFoundInfo.Create(AText: String; AFileName: String; AFileFullName: String; ALineNo, AHitPos, AHitLen: Integer);
begin
  FText := AText;
  FFileName := AFileName;
  FFileFullName := AFileFullName;
  FHitPos := AHitPos;
  FHitLen := AHitLen;
  FLineNo := ALineNo;
end;

{ TfrSolFindInFiles }

constructor TfrSolFindInFiles.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  InitControls;
  InitGridList;
end;

destructor TfrSolFindInFiles.Destroy;
begin
  FreeAndNil(FCountryListTableLink);
  FreeAndNil(FCountryList);
  inherited Destroy;
end;

procedure TfrSolFindInFiles.FindLinesInFile(AFileName: String);
var
  Lines: TStringList;
  Line: string;
  FoundResult: TArray<Integer>;
  HitPos: Integer;
  LineNo: Integer;
begin
  Lines := TStringList.Create;
  Lines.LoadFromFile(AFileName);
  for LineNo := 0 to Lines.Count - 1 do
  begin
    Line := Lines[LineNo];
    if FindStrInText(eTextToFind.Text, Line, FoundResult) then
    begin
      for HitPos in FoundResult do
      begin
        FCountryList.Add(TFoundInfo.Create(Line, TPath.GetFileName(AFileName), AFileName, LineNo, HitPos, Length(eTextToFind.Text)));
      end;
    end;
  end;
  Lines.Free;
end;

function TfrSolFindInFiles.FindStrInText(Str, Text: String;
  out FoundResult: TArray<Integer>): Boolean;
var
  ResultPChar: PChar;
  FoundPoses: TList<Integer>;
  StartPos: Integer;
  FoundPos: Integer;
begin
  Result := False;
  StartPos := 0;
  FoundPoses := TList<Integer>.Create;
  while True do
  begin
    ResultPChar := SearchBuf(PChar(Text), Length(Text), 0, StartPos, Str, [soDown, soMatchCase, soWholeWord]);
    if ResultPChar <> nil then
    begin
      FoundPos := (ResultPChar - PChar(Text));
//      FoundPos := (ResultPChar - PChar(Text)) div SizeOf(PChar);
      FoundPoses.Add(FoundPos);
      Break;
    end else
    begin
      Break;
    end;
  end;
  if FoundPoses.Count > 0 then
  begin
    FoundResult := FoundPoses.ToArray();
    Result := True;
  end;
  FoundPoses.Free;
end;

procedure TfrSolFindInFiles.InitControls;
var
  ExePath: String;
begin
  eTextToFind.Text := 'Sender';

  ExePath := ExcludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  if FileExists(ExePath + '\SolutionFrame.FindInFiles.pas') then
    eDirs.Text := TPath.GetFullPath(ExePath)
  else if FileExists(ExePath + '\..\SolutionFrame.FindInFiles.pas') then
    eDirs.Text := TPath.GetFullPath(ExePath + '\..\')
  else if FileExists(ExePath + '\..\..\SolutionFrame.FindInFiles.pas') then
    eDirs.Text := TPath.GetFullPath(ExePath + '\..\..\')
  else
    eDirs.Text := 'C:\Temp'
end;

procedure TfrSolFindInFiles.InitGridList;
var
  AList: TObjectList;
  ListItem: TFoundInfo;
begin

  if FCountryListTableLink = nil then
  begin
    AList := TObjectList.Create;

    ListItem := TFoundInfo.Create('Found Text', 'FileName', 'FullFileName', 1, 10, 4);
    AList.Add(ListItem);

    FCountryList := AList;

    FCountryListTableLink := TListTableLinkEh.Create(nil);
    FCountryListTableLink.SetList(AList, TypeInfo(TFoundInfo));
  end;

  DataGridEh1.DataSource := FCountryListTableLink;
end;

procedure TfrSolFindInFiles.bSelectDirClick(Sender: TObject);
var
  Directory: String;
begin
  if SelectDirectory('Select folder', eDirs.Text, Directory) = True then
    eDirs.Text := Directory;
end;

procedure TfrSolFindInFiles.Button1Click(Sender: TObject);
var
  FileName: string;
  Files: TStringDynArray;
begin
  FCountryList.Clear;

  Files := TDirectory.GetFiles(eDirs.Text, '*.pas', TSearchOption.soAllDirectories);
  for FileName in Files do
  begin
    FindLinesInFile(FileName);
  end;

  FCountryListTableLink.SetList(FCountryList, TypeInfo(TFoundInfo));
end;

procedure TfrSolFindInFiles.colRichFileNameCreateDataCellContent(
  Sender: TObject; Params: TDataGridCreateDataCellContentParamsEh);
begin
  with TLaStackPanelEh.CreateWith(Params.ContentParent, Params.ContentParent) do
  begin
    Margins.Rect := TRect.Create(4, 2, 2, 2);
    Params.CellContent := TLaControlEh(RefSelf);
    Orientation := TLaOrientationEh.Horizontal;

    //BlockBefore
    with TLaTextBlockEh.CreateWith(RefSelf, RefSelf) do
    begin
      Text := 'FileName(';
      FontColor := $FF0E4A84;
      Name := 'BlockBefore';
    end;

    //BlockFoundText
    with TLaTextBlockEh.CreateWith(RefSelf, RefSelf) do
    begin
      FontColor := $FFFF8C00;
      Text := 'XXX';
      Name := 'BlockFoundText';
    end;

    //BlockAfter
    with TLaTextBlockEh.CreateWith(RefSelf, RefSelf) do
    begin
      Text := ')';
      FontColor := $FF0E4A84;
      Name := 'BlockAfter';
    end;
  end;
end;

procedure TfrSolFindInFiles.colRichFileNameDataCellInitContent(Sender: TObject;
  Params: TDataGridInitDataCellContentParamsEh);
var
  BlockBefore: TLaTextBlockEh;
  BlockFoundText: TLaTextBlockEh;
  BlockAfter: TLaTextBlockEh;
  SrcItemObject: TPersistent;
  FoundInfoItem: TFoundInfo;
begin
  if Params.Row = nil then Exit;

  SrcItemObject := Params.Row.SourceRowLink.SourceObjectItem as TPersistent;
  if SrcItemObject is TFoundInfo then
  begin
    FoundInfoItem := TFoundInfo(SrcItemObject);
    BlockBefore := Params.CellContent.GetElementByName('BlockBefore') as TLaTextBlockEh;
    BlockBefore.Text := FoundInfoItem.FileName + '(';

    BlockFoundText := Params.CellContent.GetElementByName('BlockFoundText') as TLaTextBlockEh;
    BlockFoundText.Text := (FoundInfoItem.LineNo + 1).ToString;

    BlockAfter := Params.CellContent.GetElementByName('BlockAfter') as TLaTextBlockEh;
    BlockAfter.Text := '):';
  end;
end;

procedure TfrSolFindInFiles.colRichFileNameFooters0GetDisplayText(
  Sender: TObject; Params: TDataGridFooterGetDisplayTextParamsEh);
begin
  Params.DisplayText := 'Found: ' + DataGridEh1.TableView.BaseRowList.Count.ToString;
  Params.Handled := True;
end;

procedure TfrSolFindInFiles.colRichTextCreateDataCellContent(Sender: TObject;
  Params: TDataGridCreateDataCellContentParamsEh);
begin
  with TLaStackPanelEh.CreateWith(Params.ContentParent, Params.ContentParent) do
  begin
    Params.CellContent := TLaControlEh(RefSelf);
    Orientation := TLaOrientationEh.Horizontal;
    Margins.Rect := TRect.Create(4, 2, 2, 2);

    //BlockBefore
    with TLaTextBlockEh.CreateWith(RefSelf, RefSelf) do
    begin
      Text := 'BlockBefore';
      Name := 'BlockBefore';
    end;

    //BlockFoundText
    with TLaTextBlockEh.CreateWith(RefSelf, RefSelf) do
    begin
      //FontColor := TAlphaColorRec.Gray;
      FontColor := $FF7E1701;
      Font.Style := [TFontStyle.fsBold, TFontStyle.fsUnderline];
      Text := 'BlockFoundText';
      Name := 'BlockFoundText';
    end;

    //BlockAfter
    with TLaTextBlockEh.CreateWith(RefSelf, RefSelf) do
    begin
      Text := 'BlockAfter';
      Name := 'BlockAfter';
    end;
  end;
end;

procedure TfrSolFindInFiles.colRichTextDataCellInitContent(Sender: TObject;
  Params: TDataGridInitDataCellContentParamsEh);
var
  BlockBefore: TLaTextBlockEh;
  BlockFoundText: TLaTextBlockEh;
  BlockAfter: TLaTextBlockEh;
  SrcItemObject: TPersistent;
  FoundInfoItem: TFoundInfo;
begin
  if Params.Row = nil then Exit;

  SrcItemObject := TObject(TTypedListItemLinkEh(Params.Row.SourceRowLink).SourceItem) as TPersistent;
  if SrcItemObject is TFoundInfo then
  begin
    FoundInfoItem := TFoundInfo(SrcItemObject);
    BlockBefore := Params.CellContent.GetElementByName('BlockBefore') as TLaTextBlockEh;
    BlockBefore.Text := Copy(FoundInfoItem.Text, 1, FoundInfoItem.HitPos);

    BlockFoundText := Params.CellContent.GetElementByName('BlockFoundText') as TLaTextBlockEh;
    BlockFoundText.Text := Copy(FoundInfoItem.Text, FoundInfoItem.HitPos + 1, FoundInfoItem.HitLen);

    BlockAfter := Params.CellContent.GetElementByName('BlockAfter') as TLaTextBlockEh;
    BlockAfter.Text := Copy(FoundInfoItem.Text, FoundInfoItem.HitPos + 1 + FoundInfoItem.HitLen, Length(FoundInfoItem.Text));
  end;
end;

end.
