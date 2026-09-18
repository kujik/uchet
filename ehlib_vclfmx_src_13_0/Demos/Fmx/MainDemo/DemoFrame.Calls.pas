unit DemoFrame.Calls;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.ImageList, FMX.ImgList,
  FMX.Controls.Presentation,
  EhLibRtl.Api,
  EhLibFmx.Api,
  EhLibFmx.DataAxisGrid.FieldBars, EhLibFmx.DataGrid.Columns,
  EhLibFmx.DataGrids, EhLibFmx.ToolControls, EhLibFmx.Grids,
  EhLibFmx.DataAxisGrids, EhLibFmx.CustomDataGrids
  ;

type
  TfrCalls = class(TFrame)
    DataGridEh1: TDataGridEh;
    DataGridLayoutColumnEh1: TDataGridLayoutColumnEh;
    Button1: TButton;
    ImageList1: TImageList;
    procedure Button1Click(Sender: TObject);
    procedure FrameResized(Sender: TObject);
  private
    procedure GetCellManager1(Sender: TObject; Params: TDataGridGetDataCellManagerParamsEh);
    procedure CreateItemContent(Sender: TObject; Params: TDataAxisCreateCellContentParamsEh);
    procedure InitCellItemContent(Sender: TObject; Params: TDataAxisGridInitDataCellContentParamsEh);

    procedure AlignGrid();
  public
    ListDataItemCellMan: TDataAxisCellManagerEh;
    ListCaptionCellMan: TDataAxisCellManagerEh;

    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses DataModuleUnit;

{$R *.fmx}

{ TfrCalls }

procedure TfrCalls.AlignGrid;
var
  NewWidth, NewHeight, NewLeft: Single;
begin
  if Self.Width > 16 + 16 + 400 then
  begin
    NewLeft := Round((Self.Width - 400) / 2);
    NewWidth := 400;
  end else
  begin
    NewLeft := 16;
    NewWidth := Self.Width - 16 - 16;
  end;
  NewHeight := Self.Height - 16 - 16;

  DataGridEh1.SetBounds(NewLeft, 16, NewWidth, NewHeight);
end;

procedure TfrCalls.Button1Click(Sender: TObject);
begin
  DataGridEh1.DataSource := DataModule1.GetCallsHistory();
  DataGridLayoutColumnEh1.OnGetDataCellManager := GetCellManager1;
end;

constructor TfrCalls.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  DataGridEh1.Anchors := [TAnchorKind.akLeft, TAnchorKind.akTop];

  ListDataItemCellMan := TDataAxisLayoutCellManagerEh.Create(Self);
  ListDataItemCellMan.Name := 'ListDataItemCellMan';
  ListDataItemCellMan.OnCreateCellContent := CreateItemContent;
  ListDataItemCellMan.OnInitCellContent := InitCellItemContent;

  ListCaptionCellMan := TDataAxisTextCellManagerEh.Create(Self);
  ListCaptionCellMan.Name := 'ListCaptionCellMan';
  ListCaptionCellMan.OnInitCellContent := InitCellItemContent;

  Button1.Visible := False;
  Button1Click(nil);
end;

procedure TfrCalls.CreateItemContent(Sender: TObject;
  Params: TDataAxisCreateCellContentParamsEh);
var
  ATextBlock: TLaTextBlockEh;
begin
  with TLaGridPanelEh.CreateWith(Params.ContentParent) do
  begin
    Params.CellContent := RefSelf as TLaControlEh;

    Margins.Rect := TRectF.Create(10, 0, 1, 0);

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Pixel;
      Value := 32;
    end;

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Weight;
      Value := 1;
    end;

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Pixel;
      Value := 48;
    end;

    //Col1
    with TLaImageEh.CreateWith(RefSelf, RefSelf) do
    begin
      ControlCollection.AddControl(RefSelf, 0, -1);
      Name := 'CallTypeImage';
      Width := 16;
      Height := 16;
      ImageList := ImageList1;
      VertAlignment := TLaVertAlignmentEh.Center;
    end;

    //Col2
    with TLaLayoutPanelEh.CreateWith(RefSelf, RefSelf) do
    begin
      ControlCollection.AddControl(RefSelf, 1, -1);

      //Text Area
      ATextBlock := TDataAxisTextDataCellBlockEh.CreateWith(RefSelf, RefSelf);
      ATextBlock.Margins.Rect := RectF(2, 10, 2, 10);
      ATextBlock.VertAlignment := TLaVertAlignmentEh.Center;
      ATextBlock.HorzAlignment := TLaHorzAlignmentEh.Stretch;
      ATextBlock.Text := '1';
      ATextBlock.Font.Size := 16;
      ATextBlock.Name := 'TextBlock';
    end;

    //Col3
    with TLaStackPanelEh.CreateWith(RefSelf, RefSelf) do
    begin
      ControlCollection.AddControl(RefSelf, 2, -1);
      VertAlignment := TLaVertAlignmentEh.Center;
      Margins.Right := 12;

      //Simcard area
      with TLaImageEh.CreateWith(RefSelf, RefSelf) do
      begin
        Name := 'SimCardImage';
        Width := 12;
        Height := 12;
        HorzAlignment := TLaHorzAlignmentEh.Right;
        ImageList := ImageList1;
        VertAlignment := TLaVertAlignmentEh.Center;
      end;

      //CallTime area
      with TLaTextBlockEh.CreateWith(RefSelf, RefSelf) do
      begin
        Margins.Rect := RectF(2, 2, 2, 2);
        HorzAlignment := TLaHorzAlignmentEh.Right;
        FontColor := TAlphaColorRec.Gray;
        Text := '12:33';
        Name := 'TimeTextBlock';
      end;
    end;

  end;
end;

procedure TfrCalls.GetCellManager1(Sender: TObject; Params: TDataGridGetDataCellManagerParamsEh);
var
  SrcItemObject: TPersistent;
begin
  if Params.Row = nil then Exit;

  SrcItemObject := TObject(TTypedListItemLinkEh(Params.Row.SourceRowLink).SourceItem) as TPersistent;
  if SrcItemObject is TCallHistoryItem then
  begin
    Params.CellManager := ListDataItemCellMan;
  end else
  begin
    Params.CellManager := ListCaptionCellMan;
  end;
end;

procedure TfrCalls.InitCellItemContent(Sender: TObject; Params: TDataAxisGridInitDataCellContentParamsEh);
var
  ATextBlock: TLaTextBlockEh;
  SrcItemObject: TPersistent;
  CallHistoryItem: TCallHistoryItem;
  CaptionItem: TListGroupCaption;
  TextCellContent: TDataAxisTextCellContentEh;
  CallTypeImage: TLaImageEh;
  TimeTextBlock: TLaTextBlockEh;
  SimCardImage: TLaImageEh;
begin
  if Params.CellContent = nil then Exit;
  if Params.ListItemBar = nil then Exit;


  SrcItemObject := TObject(TTypedListItemLinkEh(Params.ListItemBar.SourceRowLink).SourceItem) as TPersistent;
  if SrcItemObject is TCallHistoryItem then
  begin
    CallHistoryItem := TCallHistoryItem(SrcItemObject);
    ATextBlock := Params.CellContent.GetElementByName('TextBlock') as TLaTextBlockEh;
    if CallHistoryItem.ContactCaption <> '' then
      ATextBlock.Text := CallHistoryItem.ContactCaption
    else
      ATextBlock.Text := CallHistoryItem.PhoneNumber;

    CallTypeImage := Params.CellContent.GetElementByName('CallTypeImage') as TLaImageEh;
    if CallHistoryItem.CallType = TCallType.Incoming then
      CallTypeImage.ImageIndex := 1
    else if CallHistoryItem.CallType = TCallType.Outgoing then
      CallTypeImage.ImageIndex := 2
    else if CallHistoryItem.CallType = TCallType.Missed then
      CallTypeImage.ImageIndex := 0
    else
      CallTypeImage.ImageIndex := -1;

    TimeTextBlock := Params.CellContent.GetElementByName('TimeTextBlock') as TLaTextBlockEh;
    TimeTextBlock.Text := FormatDateTime('HH:NN', CallHistoryItem.CallDateTime);

    SimCardImage := Params.CellContent.GetElementByName('SimCardImage') as TLaImageEh;
    if CallHistoryItem.SimCardNumber = 1 then
      SimCardImage.ImageIndex := 4
    else if CallHistoryItem.SimCardNumber = 2 then
      SimCardImage.ImageIndex := 5
    else
      SimCardImage.ImageIndex := -1;

    Params.Handled := True;
  end else if SrcItemObject is TListGroupCaption then
  begin
    CaptionItem := TListGroupCaption(SrcItemObject);
    TextCellContent := Params.CellContent as TDataAxisTextCellContentEh;
    TextCellContent.TextBlock.Margins.Bottom := 4;
    TextCellContent.TextBlock.Margins.Top := 8;
    TextCellContent.TextBlock.Margins.Left := 12;
    TextCellContent.TextBlock.Font.Style := [TFontStyle.fsBold];
    TextCellContent.TextBlock.FontColor := TAlphaColorRec.Gray;
    TextCellContent.Text := CaptionItem.Caption;
//    Params.Cell.BackColor := TAlphaColorRec.Whitesmoke;
    Params.Cell.Fill.Color := TAlphaColorRec.Whitesmoke;
    Params.Cell.Fill.Kind := TBrushKind.Solid;
    Params.Handled := True;
  end;
end;

procedure TfrCalls.FrameResized(Sender: TObject);
begin
  AlignGrid();
end;

end.
