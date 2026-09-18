{*******************************************************}
{                                                       }
{  This Demo shows how to use TXlsMemFileEh class       }
{  to create Xlsx files from scratch                    }
{                                                       }
{*******************************************************}

unit Unit2;

{$I EhLib.Inc}

interface

uses
  Windows, Messages, SysUtils, Variants, Graphics,
{$IFDEF EH_LIB_17} System.UITypes, {$ENDIF}
  ShellAPI, XlsMemFilesEh, DBGridEhImpExp, DBVertGridEhImpExp,
  Forms, Dialogs, DBGridEhGrouping, ToolCtrlsEh, EhLibVclMTE,
  DBGridEhToolCtrls, DynVarsEh, MemTableDataEh, Db, MemTableEh,
  DBVertGridsEh, EhLibVclUtils, GridsEh, DBAxisGridsEh, DBGridEh, ComCtrls,
  StdCtrls, Controls, ExtCtrls, Classes, DBCtrlsEh, Mask;

type
  TForm2 = class(TForm)
    qrVendors: TMemTableEh;
    DataSource1: TDataSource;
    mtQuery1: TMemTableEh;
    mtQuery1VNo: TFloatField;
    mtQuery1VName: TStringField;
    mtQuery1PNo: TFloatField;
    mtQuery1PDescription: TStringField;
    mtQuery1PCost: TCurrencyField;
    mtQuery1IQty: TIntegerField;
    mtQuery1VName1: TStringField;
    mtQuery1VPreferred: TBooleanField;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    DBGridEh1: TDBGridEh;
    DBVertGridEh1: TDBVertGridEh;
    DBEditEh1: TDBEditEh;
    DBEditEh2: TDBEditEh;
    tbSourceCode: TTabSheet;
    DBRichEditEh1: TDBRichEditEh;
    PageControl2: TPageControl;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    Panel2: TPanel;
    PaintBox1: TPaintBox;
    Label1: TLabel;
    btnExportAsXlsx: TButton;
    CheckBox1: TCheckBox;
    Label2: TLabel;
    btnImportModifyExport: TButton;
    CheckBox2: TCheckBox;
    procedure btnExportAsXlsxClick(Sender: TObject);
    procedure btnImportModifyExportClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure ExportWorksheet1(Sheet: TXlsWorksheetEh);
    procedure ExportWorksheet2(Sheet: TXlsWorksheetEh; Index: Integer);
    { Private declarations }
  public
    procedure ExportWorksheet1Title(Sheet: TXlsWorksheetEh; DBGridEh: TDBGridEh; out ToRow: Integer);
    procedure ExportWorksheet1Grid(Sheet: TXlsWorksheetEh; DBGridEh: TDBGridEh; FromRow: Integer; out ToRow: Integer);
    procedure ExportWorksheet1Footer(Sheet: TXlsWorksheetEh; DBGridEh: TDBGridEh; FromRow: Integer);
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.FormCreate(Sender: TObject);
begin
  PageControl2.ActivePageIndex := 0;
end;

procedure TForm2.btnExportAsXlsxClick(Sender: TObject);
var
  xlsFile: TXlsMemFileEh;
  Path: String;
begin
  GetDir(0, Path);
  Path := Path + '\TestXlsFile.xlsx';
  xlsFile := TXlsMemFileEh.Create;
  xlsFile.Workbook.Worksheets[0].Name := 'DBGrid';
  xlsFile.Workbook.AddWorksheet('VertGrid');

  ExportWorksheet1(xlsFile.Workbook.Worksheets[0]);
  ExportWorksheet2(xlsFile.Workbook.Worksheets[1], 0);

  xlsFile.SaveToFile(Path);

  xlsFile.Free;

  if (CheckBox1.Checked) then
    ShellExecute(Application.Handle, 'Open', PChar(Path), nil, nil, SW_SHOWNORMAL)
  else
    ShellExecute(Application.Handle, 'Open', 'explorer.exe', PChar('/select,"' + Path + '"'), nil, SW_SHOWNORMAL);
end;

procedure TForm2.btnImportModifyExportClick(Sender: TObject);
var
  xlsFile: TXlsMemFileEh;
  Path: String;
  Idx: Integer;
begin
  GetDir(0, Path);
  Path := Path + '\TestXlsFile.xlsx';
  xlsFile := TXlsMemFileEh.Create;
  xlsFile.LoadFromFile(Path);

  Idx := xlsFile.Workbook.WorksheetCount;
  xlsFile.Workbook.AddWorksheet('VertGrid-'+IntToStr(Idx));

  ExportWorksheet2(xlsFile.Workbook.Worksheets[Idx], Idx);

  xlsFile.SaveToFile(Path);

  xlsFile.Free;

  if (CheckBox2.Checked) then
    ShellExecute(Application.Handle, 'Open', PChar(Path), nil, nil, SW_SHOWNORMAL)
  else
    ShellExecute(Application.Handle, 'Open', 'explorer.exe', PChar('/select,"' + Path + '"'), nil, SW_SHOWNORMAL);
end;

procedure TForm2.ExportWorksheet1(Sheet: TXlsWorksheetEh);
var
  FromRow: Integer;
  ToRow: Integer;
begin
  ExportWorksheet1Title(Sheet, DBGridEh1, ToRow);

  FromRow := ToRow;
  ExportWorksheet1Grid(Sheet, DBGridEh1, FromRow, ToRow);

  FromRow := ToRow;
  ExportWorksheet1Footer(Sheet, DBGridEh1, FromRow);
end;

procedure TForm2.ExportWorksheet1Title(Sheet: TXlsWorksheetEh; DBGridEh: TDBGridEh; out ToRow: Integer);
var
  cr: IXlsFileCellsRangeEh;
begin
  //Caption
  Sheet.Cells[0, 0].Value := DBEditEh1.Text;
  cr := Sheet.GetCellsRange(0,0,0,0);
  cr.Font.Size := 24;
  cr.HorzAlign := chaCenterEh;

  cr.ApplyChanges;

  Sheet.MergeCell(0,0, DBGridEh.VisibleColumns.Count, 1);

  ToRow := 1;
end;

procedure TForm2.ExportWorksheet1Grid(Sheet: TXlsWorksheetEh;
  DBGridEh: TDBGridEh; FromRow: Integer; out ToRow: Integer);
var
  i: Integer;
  cr: IXlsFileCellsRangeEh;
  TitleMarix: TDBGridMultiTitleExportNodeMatrixEh;
  ci, ri: Integer;
  ti: TDBGridMultiTitleExportNodeEh;
  StartDataRow: Integer;
  TitleRowCount: Integer;
begin

  for i := 0 to DBGridEh.VisibleColumns.Count - 1 do
  begin
    Sheet.Columns[i].Width := Sheet.Columns.ScreenToXlsWidth(DBGridEh.VisibleColumns[i].Width);
  end;

  if (DBGridEh.TitleParams.MultiTitle) then
  begin
    CalcMultiTitleMatrix(DBGridEh, TitleMarix);
    for ci := 0 to Length(TitleMarix)-1 do
    begin
      for ri := 0 to Length(TitleMarix[ci])-1 do
      begin
        ti := TitleMarix[ci, ri];
        if (ti <> nil) then
        begin
          Sheet.Cells[ci, ri + FromRow].Value := TitleMarix[ci, ri].Text;
          if (ti.MergeColCount > 0) or (ti.MergeRowCount > 0) then
          begin
            Sheet.MergeCell(ci, ri + FromRow, ti.MergeColCount + 1, ti.MergeRowCount + 1);
          end;
        end;
      end;

//      if (ti.Column <> nil) and (ti.Column.Title.Orientation = tohVertical) then
//      begin
//        cr := Sheet.GetCellsRange(ci,ri + FromRow, ci,ri + FromRow);
//        cr.Rotation := 90;
//        cr.ApplyChanges;
//      end;
    end;
    TitleRowCount := Length(TitleMarix[0]);
    FreeMultiTitleMatrix(TitleMarix);
  end else
  begin
    for i := 0 to DBGridEh.VisibleColumns.Count - 1 do
    begin
      Sheet.Cells[i, 3].Value := DBGridEh.VisibleColumns[i].Title.Caption;
    end;
    TitleRowCount := 1;
  end;

  StartDataRow := ToRow + TitleRowCount;

  //Export Data rows
  i := 0;
  mtQuery1.DisableControls;
  mtQuery1.First;
  while not mtQuery1.Eof do
  begin
    for ci := 0 to DBGridEh.VisibleColumns.Count - 1 do
    begin
      Sheet.Cells[ci, i + StartDataRow].Value := DBGridEh.VisibleColumns[ci].Field.Value;
    end;

    i := i + 1;
    mtQuery1.Next;
  end;
  mtQuery1.First;
  mtQuery1.EnableControls;

  // Title formats
  cr := Sheet.GetCellsRange(0, ToRow,DBGridEh.VisibleColumns.Count - 1, TitleRowCount);
  cr.Border.Top.Style := clsMediumEh;
  cr.Border.Bottom.Style := clsMediumEh;
  cr.Border.Left.Style := clsMediumEh;
  cr.Border.Right.Style := clsMediumEh;

  cr.Border.InsideVertical.Style := clsThinEh;
  cr.Border.InsideHorizontal.Style := clsThinEh;

  cr.VertAlign := cvaCenterEh;
  cr.HorzAlign := chaCenterEh;

  cr.ApplyChanges;

  //Data formats
  cr := Sheet.GetCellsRange(0,4,6,i+4);
  cr.Border.Top.Style := clsMediumEh;
  cr.Border.Bottom.Style := clsMediumEh;
  cr.Border.Left.Style := clsMediumEh;
  cr.Border.Right.Style := clsMediumEh;

  cr.Border.InsideVertical.Style := clsThinEh;
  cr.Border.InsideHorizontal.Style := clsThinEh;

  cr.ApplyChanges;

  //Data Columns formats
  cr := Sheet.GetCellsRange(0,4,0,i+4);
  cr.NumberFormat := '"VN "0000';
  cr.ApplyChanges;

  cr := Sheet.GetCellsRange(2,4,2,i+4);
  cr.NumberFormat := '"PN-"00000';
  cr.ApplyChanges;

  cr := Sheet.GetCellsRange(4,4,4,i+4);
  cr.NumberFormat := '#,##0.0000';
  cr.ApplyChanges;

  //Footer values
  Sheet.Cells[0, i+4].Value := 'Sum of cost';
  Sheet.Cells[1, i+4].Formula := 'SUM(E5:' + 'E' + IntToStr(i+3) + ')';
  cr := Sheet.GetCellsRange(1,i+4,1,i+4);
  cr.NumberFormat := '#,##0.0000';
  cr.ApplyChanges;

  Sheet.Cells[3, i+4].Value := 'Sum';
  Sheet.Cells[4, i+4].Formula := 'SUM(E5:' + 'E' + IntToStr(i+3) + ')';
  cr := Sheet.GetCellsRange(4,i+4,4,i+4);
  cr.NumberFormat := '#,##0.0000';
  cr.ApplyChanges;

  //Footer Format
  cr := Sheet.GetCellsRange(0,i+4,6,i+4);
  cr.Border.Top.Style := clsMediumEh;
  cr.Border.Bottom.Style := clsMediumEh;
  cr.Border.Left.Style := clsMediumEh;
  cr.Border.Right.Style := clsMediumEh;
  cr.Font.IsBold := True;
  cr.ApplyChanges;

  //Final
  Sheet.FrozenRowCount := 4;
  Sheet.AutoFilterRange.FromCol := 0;
  Sheet.AutoFilterRange.FromRow := 3;
  Sheet.AutoFilterRange.ToCol := 6;
  Sheet.AutoFilterRange.ToRow := i + 4 - 1;

  ToRow := Sheet.AutoFilterRange.ToRow + 2;
end;

procedure TForm2.ExportWorksheet1Footer(Sheet: TXlsWorksheetEh;
  DBGridEh: TDBGridEh; FromRow: Integer);
begin
  Sheet.Cells[0, FromRow].Value := 'Sheet Footer';
end;

procedure TForm2.ExportWorksheet2(Sheet: TXlsWorksheetEh; Index: Integer);
var
  cr: IXlsFileCellsRangeEh;
  i: Integer;
  AFont: TFont;
begin
  Sheet.Columns[0].Width := Sheet.Columns.ScreenToXlsWidth(DBVertGridEh1.ColWidths[0]);
  Sheet.Columns[1].Width := Sheet.Columns.ScreenToXlsWidth(DBVertGridEh1.ColWidths[1]);

  Sheet.Cells[0, 0].Value := DBEditEh2.Text;
  if (Index > 0) then
    Sheet.Cells[0, 0].Value := Sheet.Cells[0, 0].Value + ' - ' + IntToStr(Index);

  cr := Sheet.GetCellsRange(0,0,0,0);
  cr.Font.Size := 24;
  cr.ApplyChanges;

  for i := 0 to DBVertGridEh1.VisibleFieldRowCount - 1 do
  begin
    //Label Cell
    Sheet.Cells[0, i+1].Value := DBVertGridEh1.VisibleFieldRow[i].RowLabel.Caption;
    cr := Sheet.GetCellsRange(0, i+1, 0, i+1);
    cr.Fill.Color := DBVertGridEh1.VisibleFieldRow[i].RowLabel.Color;

    AFont := DBVertGridEh1.VisibleFieldRow[i].RowLabel.Font;
    cr.Font.Name := AFont.Name;
    cr.Font.Size := AFont.Size;
    cr.Font.Color := AFont.Color;
    cr.Font.IsBold := fsBold in AFont.Style;
    cr.Font.IsItalic := fsItalic in AFont.Style;
    cr.Font.IsUnderline := fsUnderline in AFont.Style;

    cr.ApplyChanges;

    //Data Cell
    Sheet.Cells[1, i+1].Value := DBVertGridEh1.VisibleFieldRow[i].Field.Value;
    cr := Sheet.GetCellsRange(1, i+1, 1, i+1);
    cr.Fill.Color := DBVertGridEh1.VisibleFieldRow[i].Color;

    AFont := DBVertGridEh1.VisibleFieldRow[i].Font;
    cr.Font.Name := AFont.Name;
    cr.Font.Size := AFont.Size;
    cr.Font.Color := AFont.Color;
    cr.Font.IsBold := fsBold in AFont.Style;
    cr.Font.IsItalic := fsItalic in AFont.Style;
    cr.Font.IsUnderline := fsUnderline in AFont.Style;

    cr.HorzAlign := AlignmentToXlsFileCellHorzAlign(DBVertGridEh1.VisibleFieldRow[i].Alignment);

    cr.ApplyChanges;
  end;

  cr := Sheet.GetCellsRange(0,1,1,DBVertGridEh1.VisibleFieldRowCount);
  cr.Border.Top.Style := clsMediumEh;
  cr.Border.Bottom.Style := clsMediumEh;
  cr.Border.Left.Style := clsMediumEh;
  cr.Border.Right.Style := clsMediumEh;

  cr.Border.InsideVertical.Style := clsThinEh;
  cr.Border.InsideHorizontal.Style := clsThinEh;
  cr.ApplyChanges;

  cr := Sheet.GetCellsRange(1,1,1,DBVertGridEh1.VisibleFieldRowCount);
  cr.WrapText := True;
  cr.HorzAlign := chaLeftEh;
  cr.ApplyChanges;

  cr.ApplyChanges;
end;

initialization
//  System.ReportMemoryLeaksOnShutdown := True;
end.

