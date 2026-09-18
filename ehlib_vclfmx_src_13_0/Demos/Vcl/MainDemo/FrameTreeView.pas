unit FrameTreeView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, GridsEh, DBGridEh,
  StdCtrls, ExtCtrls, MemTableDataEh, Db, MemTableEh, Mask, DBCtrlsEh,
  DBAxisGridsEh, DynVarsEh, EhLibVclUtils;

type
  TfrTreeView = class(TFrame)
    Panel1: TPanel;
    PaintBox1: TPaintBox;
    Label1: TLabel;
    DBGridEh9: TDBGridEh;
    mtTreeView: TMemTableEh;
    mtTreeViewExpCount: TAggregateField;
    dsTreeView: TDataSource;
    Panel2: TPanel;
    CheckBox1: TCheckBox;
    DBComboBoxEh1: TDBComboBoxEh;
    Label2: TLabel;
    mtTreeImages: TMemTableEh;
    procedure PaintBox1Paint(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure DBComboBoxEh1Change(Sender: TObject);
    procedure DBGridEh9Columns0CellButtons0Draw(Grid: TCustomDBGridEh;
      Column: TColumnEh; CellButton: TDBGridCellButtonEh; Canvas: TCanvas; Cell,
      AreaCell: TGridCoord; const ARect: TRect;
      ButtonDrawParams: TCellButtonDrawParamsEh; var Handled: Boolean);
  private
    { Private declarations }
  protected
    procedure CreateWnd; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses Unit1;

{$R *.dfm}

constructor TfrTreeView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Align := alClient;
  Panel1.Height := 36;
//  if Form1.PixelsPerInch <> 96 then
//    ScaleBy(Form1.PixelsPerInch, 96);
  DBGridEh9.Border.Color := DBGridEh9.GridLineParams.GetDarkColor;
  DBGridEh9.TitleParams.SecondColor := ApproximateColor(clBtnFace, clWindow, 125);
  Panel1.DoubleBuffered := True;
  mtTreeView.Open;
end;

procedure TfrTreeView.CreateWnd;
begin
  inherited CreateWnd;
  if (CustomStyleActive) then
    DBComboBoxEh1.ItemIndex := 0;
end;

procedure TfrTreeView.PaintBox1Paint(Sender: TObject);
begin
  Form1.FillFrameTopPanel(PaintBox1.Canvas, Rect(0, 0, PaintBox1.Width, PaintBox1.Height));
end;

procedure TfrTreeView.CheckBox1Click(Sender: TObject);
begin
  DBGridEh9.TreeViewParams.ShowTreeLines := CheckBox1.Checked;
end;

procedure TfrTreeView.DBComboBoxEh1Change(Sender: TObject);
begin
  case DBComboBoxEh1.ItemIndex of
    0: DBGridEh9.TreeViewParams.GlyphStyle := tvgsClassicEh;
    1: DBGridEh9.TreeViewParams.GlyphStyle := tvgsThemedEh;
    2: DBGridEh9.TreeViewParams.GlyphStyle := tvgsExplorerThemedEh;
  end;
end;

procedure TfrTreeView.DBGridEh9Columns0CellButtons0Draw(Grid: TCustomDBGridEh;
  Column: TColumnEh; CellButton: TDBGridCellButtonEh; Canvas: TCanvas; Cell,
  AreaCell: TGridCoord; const ARect: TRect;
  ButtonDrawParams: TCellButtonDrawParamsEh; var Handled: Boolean);
var
  DrawPict: TPicture;
begin
  //v := mtTreeImages.Lookup('ImageId', mtTreeView.FieldByName('ImageId').Value, 'Image');
  if not (mtTreeImages.Locate('ImageId', mtTreeView.FieldByName('ImageId').Value, [])) then Exit;
  DrawPict := GetPictureForField(mtTreeImages.FieldByName('Image'));
  if DrawPict <> nil then
  begin
    Canvas.Draw(ARect.Left, ARect.Top, DrawPict.Graphic);
  end;
  DrawPict.Free;
end;

end.
