unit Frame1FishFacts;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, LaObjectsEh, LaControlsEh, LaPanelsEh, LaGridPanelsEh,
  LaFlowRichBlocksEh, DBGridEh, MemTableEh, Forms, Controls, ExtCtrls,
  ToolCtrlsEh, DataDriverEh,
  Graphics, StdCtrls;

type

  { TfrOneFishFacts }

  TfrOneFishFacts = class(TFrame)
    DataSource1: TDataSource;
    DBGridEh1: TDBGridEh;
    Label1: TLabel;
    MemTableEh1: TMemTableEh;
    MemTableEh1Category: TStringField;
    MemTableEh1Common_name: TStringField;
    MemTableEh1Graphic: TBlobField;
    MemTableEh1Length: TFloatField;
    MemTableEh1Notes: TMemoField;
    MemTableEh1SpeciesId: TAutoIncField;
    MemTableEh1Species_Name: TStringField;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    SQLDataDriverEh1: TSQLDataDriverEh;
  private
    function CreateGridLaControls: TLaObjectEh;
    procedure GetFlowRichBlockHintInfo(Sender: TLaObjectEh; EventArgs: TLaHintInfoEventArgs);
    function CreateLaHintControl: TLaObjectEh;
    procedure UpdateHintData;

  public
    LaHintControl: TLaObjectEh;

    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses Unit1;

{$R *.lfm}

{ TfrOneFishFacts }

constructor TfrOneFishFacts.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Panel1.Height := 36;
  DBGridEh1.FooterParams.VertLineColor := DBGridEh1.GridLineParams.DarkColor;
  DBGridEh1.FooterParams.HorzLineColor := DBGridEh1.GridLineParams.DarkColor;
  DBGridEh1.FooterParams.Color := ApproximateColor(DBGridEh1.FixedColor, clWindow, 128);
    DBGridEh1.TitleParams.SecondColor := ApproximateColor(clBtnFace, clWindow, 170);

  DBGridEh1.FooterParams.Font.Style := [fsBold];

  DBGridEh1.Columns[0].LaControlTemplate := CreateGridLaControls;
  LaHintControl := CreateLaHintControl;
  MemTableEh1.Open;
end;

function TfrOneFishFacts.CreateGridLaControls: TLaObjectEh;
begin

  with TLaStackPanelEh.Create(Self) do
  begin
    Font.Size := 14;
    Orientation := TLaOrientation.Vertical;

    with TLaGridPanelEh.CreateWith(RefSelf) do
    begin
      with ColumnCollection.Add do
      begin
        SizeStyle := TLaSizeStyleEh.Weight;
        Value := 1;
      end;

      with ColumnCollection.Add do
      begin
        SizeStyle := TLaSizeStyleEh.Weight;
        Value := 1;
      end;

      with ColumnCollection.Add do
      begin
        SizeStyle := TLaSizeStyleEh.Weight;
        Value := 2;
      end;

      with TLaContentPanelEh.CreateWith(RefSelf) do
      begin
        ControlCollection.AddControl(RefSelf, 0, -1);
        Margins.SetBounds(10, 10 ,10, 10);
        BorderThickness.SetBounds(1, 1, 1, 1);
        BorderColor := clMedGray;

        with TLaImageEh.CreateWith(RefSelf) do
        begin
          FieldName := 'Graphic';
        end;

        with TLaImageEh.CreateWith(RefSelf) do
        begin
//          ControlCollection.AddControl(RefSelf, 0, -1);
          Margins.SetBounds(2, 2, 2, 2);
          ImageList := Form1.ImageList1;
          ImageIndex := 9;
          HorzAlignment := TLaHorzAlignment.Left;
          VertAlignment := TLaVertAlignment.Top;

          OnGetHintInfo := @GetFlowRichBlockHintInfo;
        end;
      end;

      with TLaStackPanelEh.CreateWith(RefSelf) do
      begin
        ControlCollection.AddControl(RefSelf, 1, -1);
        Margins.SetBounds(0, 10, 0, 10);
        BorderThickness.SetBounds(0, 0, 0, 0);
        BorderColor := clMedGray;
        Font.Style := [fsBold];

        with TLaContentPanelEh.CreateWith(RefSelf) do
        begin
          BorderThickness.SetBounds(1, 1, 1, 0);
          Padding.SetBounds(4, 4, 4, 4);
          BorderColor := clMedGray;
          with TLaTextBlockEh.CreateWith(RefSelf) do
          begin
            Text := 'Category:';
            //FieldName := 'Notes';
          end;
        end;

        with TLaContentPanelEh.CreateWith(RefSelf) do
        begin
          BorderThickness.SetBounds(1, 1, 1, 0);
          BorderColor := clMedGray;
          Padding.SetBounds(4, 4, 4, 4);
          with TLaTextBlockEh.CreateWith(RefSelf) do
          begin
            Text := 'Common name:';
          end;
        end;

        with TLaContentPanelEh.CreateWith(RefSelf) do
        begin
          BorderThickness.SetBounds(1, 1, 1, 0);
          BorderColor := clMedGray;
          Padding.SetBounds(4, 4, 4, 4);
          with TLaTextBlockEh.CreateWith(RefSelf) do
          begin
            Text := 'Species name:';
          end;
        end;

        with TLaContentPanelEh.CreateWith(RefSelf) do
        begin
          BorderThickness.SetBounds(1, 1, 1, 1);
          BorderColor := clMedGray;
          Padding.SetBounds(4, 4, 4, 4);
          with TLaTextBlockEh.CreateWith(RefSelf) do
          begin
            Text := 'Length:';
          end;
        end;
      end;

      with TLaStackPanelEh.CreateWith(RefSelf) do
      begin
        ControlCollection.AddControl(RefSelf, 2, -1);
        Margins.SetBounds(0, 10, 10, 10);
        BorderThickness.SetBounds(0, 0, 0, 0);
        BorderColor := clMedGray;

        with TLaContentPanelEh.CreateWith(RefSelf) do
        begin
          BorderThickness.SetBounds(0, 1, 1, 0);
          BorderColor := clMedGray;
          Padding.SetBounds(4, 4, 4, 4);
          with TLaTextBlockEh.CreateWith(RefSelf) do
          begin
            FieldName := 'Category';
          end;
        end;

        with TLaContentPanelEh.CreateWith(RefSelf) do
        begin
          BorderThickness.SetBounds(0, 1, 1, 0);
          BorderColor := clMedGray;
          Padding.SetBounds(4, 4, 4, 4);
          with TLaTextBlockEh.CreateWith(RefSelf) do
          begin
            FieldName := 'Common_name';
          end;
        end;

        with TLaContentPanelEh.CreateWith(RefSelf) do
        begin
          BorderThickness.SetBounds(0, 1, 1, 0);
          BorderColor := clMedGray;
          Padding.SetBounds(4, 4, 4, 4);
          with TLaTextBlockEh.CreateWith(RefSelf) do
          begin
            FieldName := 'Species_Name';
          end;
        end;

        with TLaContentPanelEh.CreateWith(RefSelf) do
        begin
          BorderThickness.SetBounds(0, 1, 1, 1);
          BorderColor := clMedGray;
          Padding.SetBounds(4, 4, 4, 4);
          with TLaTextBlockEh.CreateWith(RefSelf) do
          begin
            FieldName := 'Length';
          end;
        end;
      end;
    end;

    with TLaTextBlockEh.CreateWith(RefSelf) do
    begin
      Margins.SetBounds(10, 0, 10, 10);
      BorderThickness.SetBounds(1, 1, 1, 1);
      BorderColor := clMedGray;
      Padding.SetBounds(4, 4, 4, 4);
      FieldName := 'Notes';
      WordWrap := True;
      Font.Size := 7;
    end;

    Result := RefSelf;
  end;

end;

procedure TfrOneFishFacts.GetFlowRichBlockHintInfo(Sender: TLaObjectEh;
  EventArgs: TLaHintInfoEventArgs);
begin
  UpdateHintData;
  EventArgs.HintObject := LaHintControl;
  EventArgs.HideTimeout := 4000;
  EventArgs.Handled := True;
end;

function TfrOneFishFacts.CreateLaHintControl: TLaObjectEh;
begin
  with TLaStackPanelEh.CreateWith(Self, TLaObjectEh(nil)) do
  begin
    Orientation := TLaOrientation.Horizontal;
    Margins.SetBounds(5, 5, 5, 5);

    with TLaImageEh.CreateWith(RefSelf) do
    begin
      Margins.SetBounds(10, 10 ,10, 10);
      BorderThickness.SetBounds(1, 1, 1, 1);
      BorderColor := clMedGray;
      Name := 'Graphic';
    end;

    with TLaStackPanelEh.CreateWith(RefSelf) do
    begin
      Orientation := TLaOrientation.Vertical;
       with TLaTextBlockEh.CreateWith(RefSelf) do
      begin
        Font.Style := [fsBold];
        Text := 'Category:';
      end;

      with TLaFlowRichBlockEh.CreateWith(RefSelf) do
      begin
        Font.Style := [fsBold];
        with TFlBreakableTextEh.Create(RefSelf) do
          Text := 'Common name:';
      end;

      //Result := RefSelf;
    end;

    with TLaStackPanelEh.CreateWith(RefSelf) do
    begin
      Orientation := TLaOrientation.Vertical;
      Margins.SetBounds(5, 0, 0, 0);

      with TLaTextBlockEh.CreateWith(RefSelf) do
      begin
        //Text := DBGridEh1.DataSource.DataSet.FieldByName('Category').AsString;
        FieldName := 'Category';
      end;

      with TLaTextBlockEh.CreateWith(RefSelf) do
      begin
        FieldName := 'Common_name';
      end;

    end;

    Result := RefSelf;
  end;
end;

procedure TfrOneFishFacts.UpdateHintData;
var
  PngGraphic: TLaImageEh;
  APicture: TPicture;
begin
  PngGraphic := LaHintControl.GetElementByName('Graphic') as TLaImageEh;
  APicture := ToolCtrlsEh.GetPictureForField(DBGridEh1.DataSet.FieldByName('Graphic'));
  PngGraphic.Picture := APicture;
  APicture.Free;
end;

end.

