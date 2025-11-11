unit D_Grid1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_Normal, ToolCtrlsEh,
  DBGridEhToolCtrls, Vcl.StdCtrls, DBCtrlsEh,
  GridsEh, DBAxisGridsEh, DBGridEh, MemTableDataEh, Data.DB, MemTableEh,
  uString, EhLibVclUtils, DBGridEhGrouping, DynVarsEh, Vcl.Mask  ;

type
  TDlg_Grid1 = class(TForm_Normal)
    DBGridEh1: TDBGridEh;
    edt_PPComment: TDBEditEh;
    MemTableEh1: TMemTableEh;
    DataSource1: TDataSource;
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ShowDialog(fCaption: string; fWidth, fHeight: Integer; DefGrid: TVarDynArray2; Data: TVarDynArray2);
  end;

var
  Dlg_Grid1: TDlg_Grid1;

implementation

{$R *.dfm}

uses
  uForms
  ;

procedure TDlg_Grid1.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
  if Key = VK_ESCAPE then Close;
end;

procedure TDlg_Grid1.ShowDialog(fCaption: string; fWidth, fHeight: Integer; DefGrid: TVarDynArray2; Data: TVarDynArray2);
var
  i, j: Integer;
begin
  DBGridEh1.Columns.Clear;
  MemTableEh1.Close;
  MemTableEh1.FieldDefs.Clear;
  //добавляет столбец в memtable и в грид
  //Mth.AddTableColumn(DBGridEh1: TDBGridEh; aFieldName: string; aFieldType:TFieldType; aFieldSize: Integer; aCaption: string; aWidth: Integer; aVisible: Boolean);
  for i:=0 to High(DefGrid) do begin
    Mth.AddTableColumn(DBGridEh1, DefGrid[i][0], DefGrid[i][1], DefGrid[i][2], DefGrid[i][3], DefGrid[i][4], DefGrid[i][5]);
  end;
 //создаем датасет
  MemTableEh1.CreateDataSet;
  //заполним поля из массива
  MemTableEh1.First;
  for i := 0 to High(Data) do begin
    MemTableEh1.Last;
    MemTableEh1.Insert;
    for j:=0 to High(Data[i]) do
      MemTableEh1.Fields[j].Value := Data[i][j];
    MemTableEh1.Post;
  end;
  MemTableEh1.First;
//  MemTableEh1.Pos
  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh+[dghShowRecNo];
  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh+[dghEnterAsTab];
  DBGridEh1.ShowHint:=True;
//  Gh.SetGridOptionsTitleAppearance(DBGridEh1);
  Gh.SetGridOptionsDefault(DBGridEh1);
//  DBGridEh1.TitleParams.FillStyle:=cfstGradientEh;
  //DBGridEh1.TitleParams.MultiTitle:=True;
//  DBGridEh1.TitleParams.SecondColor:=clSkyBlue;
//  DBGridEh1.TitleParams.Color:=clWindow;
 //перемещение столбцов
  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh-[dghColumnMove];
  //изменение ширины столбцов
  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh-[dghColumnResize];
//  DBGridEh1.FixedColor:=RGB(200,200,200);

//  DBGridEh1.Columns[1].

  DBGridEh1.ReadOnly:=True;

  Caption:=fCaption;
  ClientHeight:=fHeight;
  ClientWidth:=fWidth;
  BorderStyle:=bsDialog;
  //чтобы перехватывать нажатия клавишь на форме
  KeyPreview:=True;
  ShowModal;
end;


end.
