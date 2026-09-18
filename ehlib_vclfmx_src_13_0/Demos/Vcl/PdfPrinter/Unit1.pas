unit Unit1;

{$I EhLib.Inc}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, MemTableDataEh, Db, DBGridEhGrouping, ADODB, GridsEh, DBGridEh,
  MemTableEh, ToolCtrlsEh, DBGridEhToolCtrls, StdCtrls, Mask, DBCtrlsEh,
  ObjectInspectorEh, SqlTimSt, EhLibUtils,
  EhLibVclUtils, Types,
  PrntsEh, PdfPrintersEh, PrViewEh, ShellAPI,
  DBLookupEh, DynVarsEh, DBAxisGridsEh;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure PrintData1To(VirtualPrinter: TBaseVirtualPrinter);
    procedure PrintData2To(VirtualPrinter: TBaseVirtualPrinter);
    procedure PrintData3To(VirtualPrinter: TBaseVirtualPrinter);
  end;

var
  Form1: TForm1;

implementation

uses Unit2;

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  Caption := Caption + ' ' + EhLibVerInfo + ' ' + EhLibBuildInfo;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F11 then
    ShowObjectInspectorForm(ActiveControl, Rect(Left+Width+10, Top, Left+Width+10+300, Top+Height));
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  AFilename: String;
  Path: String;
  FullFileName: String;
begin
  GetDir(0, Path);
  AFilename := 'PdfDataFile.pdf';
  FullFileName := Path + '\' + AFilename;

  PdfPrinter.BeginDoc(FullFileName);
  PrintData1To(PdfPrinter);
  PdfPrinter.EndDoc();

  ShellExecute(Handle, nil, PChar(FullFileName), nil, nil, SW_SHOWNORMAL);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  PrinterPreview.BeginDoc;
  PrintData1To(PrinterPreview);
  PrinterPreview.EndDoc;
end;

procedure TForm1.PrintData1To(VirtualPrinter: TBaseVirtualPrinter);
var
  ARect: TRect;
  AText: String;
  Ppx, Ppy: Integer;
begin
  Ppx := VirtualPrinter.Canvas.PixelsPerInchX;
  Ppy := VirtualPrinter.Canvas.PixelsPerInchY;
  VirtualPrinter.Canvas.Brush.Style := bsClear;

  ARect := Rect(Ppx, Ppy, Ppx + Ppx, Ppy + Ppy);

  //1x1 inch Square.
  VirtualPrinter.Canvas.Pen.Width := Ppx div 50;
  VirtualPrinter.Canvas.Rectangle(ARect);


  //Text
  AText := 'Hello World!';
  VirtualPrinter.Canvas.Font.Size := 14;
  VirtualPrinter.Canvas.TextRect(ARect, AText, []);

  //Wrapped Text
  OffsetRect(ARect, Ppx * 2, 0);
  VirtualPrinter.Canvas.Rectangle(ARect);

  AText := 'PdfPrinter Demo. This is word wrap text.';
  VirtualPrinter.Canvas.TextRect(ARect, AText, [tfWordBreak]);
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  AFilename: String;
  Path: String;
  FullFileName: String;
begin
  GetDir(0, Path);
  AFilename := 'PdfDataFile.pdf';
  FullFileName := Path + '\' + AFilename;

  PdfPrinter.BeginDoc(FullFileName);
  PrintData2To(PdfPrinter);
  PdfPrinter.EndDoc();

  ShellExecute(Handle, nil, PChar(FullFileName), nil, nil, SW_SHOWNORMAL);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  PrinterPreview.BeginDoc;
  PrintData2To(PrinterPreview);
  PrinterPreview.EndDoc;
end;

procedure TForm1.PrintData2To(VirtualPrinter: TBaseVirtualPrinter);
var
  SidesRatio: Double;
  ARect: TRect;
  Ppx: Integer;
  ImListBitmap: TBitmap;
begin
  Ppx := VirtualPrinter.Canvas.PixelsPerInchX;
  SidesRatio := Form2.Image1.Picture.Graphic.Width / Form2.Image1.Picture.Graphic.Height;

  ARect := Rect(Ppx, Ppx, Ppx + Round(Ppx * SidesRatio), Ppx + Ppx);
  VirtualPrinter.Canvas.StretchDraw(ARect, Form2.Image1.Picture.Graphic);

  ImListBitmap := ImListImageToBitmap(Form2.ImageList32, 0);
  OffsetRect(ARect, 0, Ppx * 2);
  ARect.Right := ARect.Left + RectHeight(ARect);
  VirtualPrinter.Canvas.StretchDraw(ARect, ImListBitmap);
  ImListBitmap.Free;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  AFilename: String;
  Path: String;
  FullFileName: String;
begin
  GetDir(0, Path);
  AFilename := 'PdfDataFile.pdf';
  FullFileName := Path + '\' + AFilename;

  PdfPrinter.BeginDoc(FullFileName);
  PrintData3To(PdfPrinter);
  PdfPrinter.EndDoc();

  ShellExecute(Handle, nil, PChar(FullFileName), nil, nil, SW_SHOWNORMAL);
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  PrinterPreview.BeginDoc;
  PrintData3To(PrinterPreview);
  PrinterPreview.EndDoc;
end;

procedure TForm1.PrintData3To(VirtualPrinter: TBaseVirtualPrinter);
var
  ARect: TRect;
  Ppx: Integer;
  PageCount, LastPageBlockHeight: Integer;
begin
  //MeasureRtfTextLayout
  Ppx := VirtualPrinter.Canvas.PixelsPerInchX;
  ARect := Rect(Ppx, Ppx, VirtualPrinter.PageWidth - Ppx * 2, VirtualPrinter.PageHeight - Ppx * 2);
  VirtualPrinter.Canvas.DrawRtfText(Form2.DBRichEditEh1.RtfText,
    ARect.Top, ARect.Top, ARect.Bottom, ARect.Left, ARect.Right, PageCount, LastPageBlockHeight);
end;

initialization
end.
