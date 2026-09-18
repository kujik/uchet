unit DemoFrame.Contacts;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation,
  EhLibRtl.Api,
  EhLibFmx.Api,
  EhLibFmx.DataAxisGrid.FieldBars, EhLibFmx.DataGrid.Columns,
  EhLibFmx.DataGrids, EhLibFmx.ToolControls, EhLibFmx.Grids,
  EhLibFmx.DataAxisGrids, EhLibFmx.CustomDataGrids;

type
  TfrContacts = class(TFrame)
    DataGridEh1: TDataGridEh;
    DataGridLayoutColumnEh1: TDataGridLayoutColumnEh;
    Button1: TButton;
    rdStyle1: TRadioButton;
    rdStyle2: TRadioButton;
    procedure Button1Click(Sender: TObject);
    procedure rdStyle1Change(Sender: TObject);
    procedure FrameResized(Sender: TObject);
  private
    procedure GetCellManager1(Sender: TObject; Params: TDataGridGetDataCellManagerParamsEh);
    procedure CreateItemContent(Sender: TObject; Params: TDataAxisCreateCellContentParamsEh);
    procedure CreateCaptionContent(Sender: TObject; Params: TDataAxisCreateCellContentParamsEh);
    procedure CreateItemContent2(Sender: TObject; Params: TDataAxisCreateCellContentParamsEh);
    procedure DataCellInitContent(Sender: TObject; Params: TDataAxisInitCellContentParamsEh);

    procedure FilterRow(Sender: TObject; Params: TDataGridFilterRowParamsEh);
    procedure AlignGrid();

  public
    ListDataItemCellMan: TDataAxisLayoutCellManagerEh;
    ListCaptionCellMan: TDataAxisLayoutCellManagerEh;
    ListDataItemCellMan2: TDataAxisLayoutCellManagerEh;

    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.fmx}

uses DataModuleUnit;

{ TFrame1 }

procedure TfrContacts.AlignGrid;
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
  NewHeight := Self.Height - 40 - 16;

  DataGridEh1.SetBounds(NewLeft, 40, NewWidth, NewHeight);
end;

procedure TfrContacts.Button1Click(Sender: TObject);
begin
  DataGridEh1.DataSource := DataModule1.GetContactsGroupedByName();
  DataGridLayoutColumnEh1.OnGetDataCellManager := GetCellManager1;
end;

constructor TfrContacts.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  DataGridEh1.OnFilterRow := FilterRow;
  DataGridEh1.Anchors := [TAnchorKind.akLeft, TAnchorKind.akTop];

  ListDataItemCellMan := TDataAxisLayoutCellManagerEh.Create(Self);
  ListDataItemCellMan.Name := 'ListDataItemCellMan';
  ListDataItemCellMan.OnCreateCellContent := CreateItemContent;
  ListDataItemCellMan.OnInitCellContent := DataCellInitContent;

  ListCaptionCellMan := TDataAxisLayoutCellManagerEh.Create(Self);
  ListCaptionCellMan.Name := 'ListCaptionCellMan';
  ListCaptionCellMan.OnCreateCellContent := CreateCaptionContent;
  ListCaptionCellMan.OnInitCellContent := DataCellInitContent;

  ListDataItemCellMan2 := TDataAxisLayoutCellManagerEh.Create(Self);
  ListDataItemCellMan2.Name := 'ListDataItemCellMan2';
  ListDataItemCellMan2.OnCreateCellContent := CreateItemContent2;
  ListDataItemCellMan2.OnInitCellContent := DataCellInitContent;

  Button1.Visible := False;
  Button1Click(nil);
end;

procedure TfrContacts.GetCellManager1(Sender: TObject; Params: TDataGridGetDataCellManagerParamsEh);
var
  SrcItemObject: TPersistent;
begin
  if Params.Row = nil then Exit;

  SrcItemObject := Params.Row.SourceObjectItem as TPersistent;
  if SrcItemObject is TContactListItem then
  begin
   if rdStyle1.IsChecked then
     Params.CellManager := ListDataItemCellMan
   else
     Params.CellManager := ListDataItemCellMan2;
  end else
  begin
    Params.CellManager := ListCaptionCellMan;
  end;
end;

procedure TfrContacts.CreateItemContent(Sender: TObject;
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
      SizeStyle := TLaGridPanelSizeStyleEh.Auto;
      Value := 1;
    end;

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Weight;
      Value := 1;
    end;

    with TLaLayoutPanelEh.CreateWith(RefSelf, RefSelf) do
    begin
      Padding.Rect := TRect.Create(2, 4, 4, 4);
      ControlCollection.AddControl(RefSelf, 0, -1);

      with TLaControlsGenericHelper.CreateControlWith<TCircle>(RefSelf, RefSelf) do
      begin
        Size.Width := 24;
        Size.Height := 24;
        Fill.Color := $FFFFAAFF;
        Stroke.Kind := TBrushKind.None;
        Name := 'Circle';

        with TLaControlsGenericHelper.CreateControlWith<TText>(RefSelf, RefSelf) do
        begin
          Margins.Bottom := 2;
          Align := TAlignLayout.Client;
          Text := 'A';
          Name := 'CircleLetter';
          TextSettings.Font.Size := 16;
          TextSettings.FontColor := TAlphaColorRec.White;
        end;
      end;
    end;

    with TLaLayoutPanelEh.CreateWith(RefSelf, RefSelf) do
    begin
      ControlCollection.AddControl(RefSelf, 1, -1);

      //Text Area
      ATextBlock := TDataAxisTextDataCellBlockEh.CreateWith(RefSelf, RefSelf);
      ATextBlock.Margins.Rect := RectF(2, 2, 2, 2);
      ATextBlock.VertAlignment := TLaVertAlignmentEh.Center;
      ATextBlock.HorzAlignment := TLaHorzAlignmentEh.Stretch;
      ATextBlock.Text := '1';
      ATextBlock.Font.Size := 14;
      ATextBlock.Name := 'ContactNameBlock';
    end;
  end;
end;

procedure TfrContacts.CreateCaptionContent(Sender: TObject;
  Params: TDataAxisCreateCellContentParamsEh);
begin
  with TLaTextBlockEh.CreateWith(Params.ContentParent, Params.ContentParent) do
  begin
    Params.CellContent := RefSelf as TLaControlEh;
    Margins.Rect := RectF(4, 4, 4, 4);
    FontColor := TAlphaColorRec.Gray;
    Font.Style := [TFontStyle.fsBold];
    Text := 'Caption';
    Name := 'CaptionBlock';
  end;
end;

procedure TfrContacts.CreateItemContent2(Sender: TObject;
  Params: TDataAxisCreateCellContentParamsEh);
var
  ATextBlock: TLaTextBlockEh;
begin
  with TLaGridPanelEh.CreateWith(Params.ContentParent) do
  begin
    Params.CellContent := RefSelf as TLaControlEh;

    Margins.Rect := TRectF.Create(10, 4, 1, 4);

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Auto;
      Value := 1;
    end;

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Weight;
      Value := 1;
    end;

    with TLaLayoutPanelEh.CreateWith(RefSelf, RefSelf) do
    begin
      Padding.Rect := TRect.Create(2, 4, 4, 4);
      ControlCollection.AddControl(RefSelf, 0, -1);

      with TLaControlsGenericHelper.CreateControlWith<TCircle>(RefSelf, RefSelf) do
      begin
        Size.Width := 24;
        Size.Height := 24;
        Fill.Color := $FFFFAAFF;
        Stroke.Kind := TBrushKind.None;
        Name := 'Circle';
      end;

      with TLaControlsGenericHelper.CreateControlWith<TText>(RefSelf, RefSelf) do
      begin
        Margins.Bottom := 2;
        Align := TAlignLayout.Client;
        Text := 'A';
        Name := 'CircleLetter';
        TextSettings.Font.Size := 16;
        TextSettings.FontColor := TAlphaColorRec.White;
      end;
    end;

    with TLaStackPanelEh.CreateWith(RefSelf, RefSelf) do
    begin
      ControlCollection.AddControl(RefSelf, 1, -1);
      VertAlignment := TLaVertAlignmentEh.Center;
      Margins.Right := 12;

      //ContactNameBlock
      ATextBlock := TDataAxisTextDataCellBlockEh.CreateWith(RefSelf, RefSelf);
      ATextBlock.Margins.Rect := RectF(2, 2, 2, 0);
      ATextBlock.VertAlignment := TLaVertAlignmentEh.Center;
      ATextBlock.HorzAlignment := TLaHorzAlignmentEh.Stretch;
      ATextBlock.Text := '1';
      ATextBlock.Font.Size := 14;
      ATextBlock.Name := 'ContactNameBlock';

      //ContactPhoneBlock
      with TLaTextBlockEh.CreateWith(RefSelf, RefSelf) do
      begin
        Margins.Rect := RectF(2, 0, 2, 4);
        FontColor := TAlphaColorRec.Gray;
        Text := '+7 0000000000000';
        Name := 'ContactPhoneBlock';
      end;
    end;
  end;
end;

procedure TfrContacts.DataCellInitContent(Sender: TObject; Params: TDataAxisInitCellContentParamsEh);
var
  AContactNameBlock: TLaTextBlockEh;
  ContactPhoneBlock: TLaTextBlockEh;
  CircleLetter: TText;
  Circle: TCircle;
  SrcItemObject: TPersistent;
  ContactListItem: TContactListItem;
  CaptionItem: TListGroupCaption;
  TextCellContent: TLaTextBlockEh;
begin
  if Params.CellContent = nil then Exit;
  if Params.ListItemBar = nil then Exit;

  SrcItemObject := Params.ListItemBar.SourceObjectItem as TPersistent;
  if SrcItemObject is TContactListItem then
  begin
    ContactListItem := TContactListItem(SrcItemObject);
    AContactNameBlock := Params.CellContent.GetElementByName('ContactNameBlock') as TLaTextBlockEh;
    AContactNameBlock.Text := ContactListItem.FirstName + ' ' + ContactListItem.LastName;

    CircleLetter := Params.CellContent.GetElementByName('CircleLetter') as TText;
    CircleLetter.Text := Copy(ContactListItem.FirstName, 1, 1);

    Circle := Params.CellContent.GetElementByName('Circle') as TCircle;
    Circle.Fill.Color := ContactListItem.PictureColor;

    if rdStyle2.IsChecked then
    begin
      ContactPhoneBlock := Params.CellContent.GetElementByName('ContactPhoneBlock') as TLaTextBlockEh;
      ContactPhoneBlock.Text := ContactListItem.Phone;
    end;

    Params.Handled := True;
  end else if SrcItemObject is TListGroupCaption then
  begin
    CaptionItem := TListGroupCaption(SrcItemObject);
    TextCellContent := Params.CellContent as TLaTextBlockEh;

    TextCellContent.Text := CaptionItem.Caption;
    Params.Cell.Fill.Color := TAlphaColorRec.Whitesmoke;
    Params.Cell.Fill.Kind := TBrushKind.Solid;
    Params.Handled := True;
  end;
end;

procedure TfrContacts.rdStyle1Change(Sender: TObject);
begin
  DataGridEh1.ReloadData;
end;

procedure TfrContacts.FilterRow(Sender: TObject; Params: TDataGridFilterRowParamsEh);
var
  SrcItemObject: TPersistent;
begin
  SrcItemObject := Params.Row.SourceObjectItem as TPersistent;
  if (SrcItemObject is TListGroupCaption) and (rdStyle2.IsChecked = True) then
    Params.Accept := False;
end;

procedure TfrContacts.FrameResized(Sender: TObject);
begin
  AlignGrid();
end;

end.
