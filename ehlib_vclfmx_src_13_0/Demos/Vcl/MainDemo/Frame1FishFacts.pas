unit Frame1FishFacts;

{$I EhLib.Inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
{$IFDEF EH_LIB_6} Variants, {$ENDIF}
  Themes,
  LaObjectsEh, LaControlsEh, LaPanelsEh, LaGridPanelsEh, LaFlowRichBlocksEh,
  Dialogs, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, ExtCtrls,
  GridsEh, DBGridEh, MemTableDataEh, Db, ADODB, DataDriverEh,
  ADODataDriverEh, MemTableEh, StdCtrls, DynVarsEh, EhLibVclUtils, DBAxisGridsEh;

type
  TfrOneFishFacts = class(TFrame)
    Panel1: TPanel;
    DataSource1: TDataSource;
    mtQuery1: TMemTableEh;
    ddrData1: TADODataDriverEh;
    PaintBox1: TPaintBox;
    Label1: TLabel;
    DBGridEh1: TDBGridEh;
    procedure PaintBox1Paint(Sender: TObject);
  private
    function CreateGridLaControls: TLaObjectEh;
    procedure GetFlowRichBlockHintInfo(Sender: TLaObjectEh; EventArgs: TLaHintInfoEventArgs);
    function CreateLaHintControl: TLaObjectEh;
    procedure UpdateHintData;
    { Private declarations }
  protected

    procedure ReadState(Reader: TReader); override;
  public
    LaHintControl: TLaObjectEh;

    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses Unit1;

{$R *.dfm}

{ TfrFrameOne }

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
  mtQuery1.Open;
end;

procedure TfrOneFishFacts.PaintBox1Paint(Sender: TObject);
begin
  Form1.FillFrameTopPanel(PaintBox1.Canvas, Rect(0, 0, PaintBox1.Width, PaintBox1.Height));
end;

procedure TfrOneFishFacts.ReadState(Reader: TReader);
begin
  inherited ReadState(Reader);
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
          FieldName := 'PngGraphic';

        end;

        with TLaImageEh.CreateWith(RefSelf) do
        begin
//          ControlCollection.AddControl(RefSelf, 0, -1);
          Margins.SetBounds(2, 2, 2, 2);
          ImageList := Form1.ImageList16;
          ImageIndex := 12;
          HorzAlignment := TLaHorzAlignment.Left;
          VertAlignment := TLaVertAlignment.Top;

          OnGetHintInfo := GetFlowRichBlockHintInfo;
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

procedure TfrOneFishFacts.GetFlowRichBlockHintInfo(Sender: TLaObjectEh; EventArgs: TLaHintInfoEventArgs);
begin
  UpdateHintData;
  EventArgs.HintObject := LaHintControl;
  EventArgs.HideTimeout := 4000;
  EventArgs.Handled := True;
end;

procedure TfrOneFishFacts.UpdateHintData;
var
  PngGraphic: TLaImageEh;
  APicture: TPicture;
begin
  PngGraphic := LaHintControl.GetElementByName('PngGraphic') as TLaImageEh;
  APicture := ToolCtrlsEh.GetPictureForField(DBGridEh1.DataSet.FieldByName('PngGraphic'));
  PngGraphic.Picture := APicture;
  APicture.Free;
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
      Name := 'PngGraphic';
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

end.
