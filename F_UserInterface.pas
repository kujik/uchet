unit F_UserInterface;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Math,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, Mask, uData, uForms, uDBOra, uString, uMessages, System.Types,
  Vcl.ExtCtrls, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, MemTableDataEh, MemTableEh,
  Data.DB, Vcl.Menus, uSettings, Vcl.Imaging.pngimage, V_MDI, Vcl.ComCtrls
  ;

type
  TForm_UserInterface = class(TForm_MDI)
    DBGridEh1: TDBGridEh;
    MemTableEh1: TMemTableEh;
    DataSource1: TDataSource;
    Cb_Styles: TDBComboBoxEh;
    Bt_1: TBitBtn;
    CheckBox1: TCheckBox;
    RadioButton1: TRadioButton;
    DBEditEh1: TDBEditEh;
    Label1: TLabel;
    Label2: TLabel;
    Cb_Q: TDBComboBoxEh;
    Cb_J: TDBComboBoxEh;
    Cb_D: TDBComboBoxEh;
    Bevel1: TBevel;
    Bt_Def: TBitBtn;
    Chb_DesignReports: TCheckBox;
    procedure Cb_StylesChange(Sender: TObject);
    procedure Bt_DefClick(Sender: TObject);
    procedure Cb_Change(Sender: TObject);
    procedure Chb_DesignReportsClick(Sender: TObject);
  private
    function Prepare: Boolean; override;
  public
  end;

var
  Form_UserInterface: TForm_UserInterface;

implementation

uses
  uWindows,
  uFrmMain,
  uPrintReport,
  uSys
  ;

{$R *.dfm}


procedure TForm_UserInterface.Bt_DefClick(Sender: TObject);
begin
  Cb_Q.ItemIndex:=0;
  Cb_J.ItemIndex:=0;
  Cb_D.ItemIndex:=1;
  Cb_Styles.ItemIndex:=0;
end;

procedure TForm_UserInterface.Cb_Change(Sender: TObject);
begin
  if InPrepare then Exit;
  Settings.WriteInterfaceSettings(S.IIFStr(Cb_Styles.ItemIndex = 0, '', Cb_Styles.Text), Cb_Q.ItemIndex, Cb_J.ItemIndex, Cb_D.ItemIndex);
end;

procedure TForm_UserInterface.Cb_StylesChange(Sender: TObject);
var
  st: string;
begin
  if InPrepare then Exit;
  if Cb_Styles.Text = 'СТАНДАРТ' then st:='' else st:= Module.GetPath_Styles + '\' + Cb_Styles.Text;
  Settings.WriteInterfaceSettings(S.IIFStr(Cb_Styles.ItemIndex = 0, '', Cb_Styles.Text), Cb_Q.ItemIndex, Cb_J.ItemIndex, Cb_D.ItemIndex);
  Module.SetStyle(st);
  Close;
  FrmMain.TimerSetStyle.Enabled := True;
end;

procedure TForm_UserInterface.Chb_DesignReportsClick(Sender: TObject);
begin
  inherited;
  if InPrepare then Exit;
  PrintReport.SetDesignReport(Chb_DesignReports.Checked);
end;

function TForm_UserInterface.Prepare: Boolean;
var
  i: Integer;
  sda: TStringDynArray;
begin
  Mth.AddGridColumn(DBGridEh1, 'f1', 'Заголовок 1', 150, True);
  Mth.AddGridColumn(DBGridEh1, 'f2', 'Заголовок 2', 150, True);
  Mth.AddGridColumn(DBGridEh1, 'f3', '3', 50, True);
  MemTableEh1.Close;
  //очистим определение полей
  MemTableEh1.FieldDefs.Clear;
  //определяем поля
  MemTableEh1.FieldDefs.Add('f1', ftString, 20, False);
  MemTableEh1.FieldDefs.Add('f2', ftString, 20, False);
  MemTableEh1.FieldDefs.Add('f3', ftInteger, 0, False);
  MemTableEh1.CreateDataSet;
  MemTableEh1.Active:=True;
  for i:=1 to 10 do begin
    MemTableEh1.Insert;
    MemTableEh1.FieldByName('f1').Value:='Строка ' + inttostr(i);
    MemTableEh1.FieldByName('f3').Value:=S.IIf(odd(i), 0, 1);
    MemTableEh1.Post;
  end;
  Gh.SetGridInCellCheckBoxes(DBGridEh1, 'f3', '1;', -1);
  DBGridEh1.FieldColumns['f2'].CellButtons.Add;
  DBGridEh1.FieldColumns['f2'].CellButtons[0].Style:=ebsEllipsisEh;
  DBGridEh1.FieldColumns['f2'].CellButtons[0].hint:='кнопка в таблице';
  Gh.SetGridOptionsDefault(DBGridEh1);
  Gh.SetGridOptionsMain(DBGridEh1);
  Cth.SetBtn(Bt_1, mybtCancel);
  Bt_1.Caption:='Кнопка';
  //Label1.Font.Color:=rgb(200,10,210);
  sda:=Sys.GetFileInDirectoryOnly(Module.GetPath_Styles);
  Cb_Styles.Items.Add('СТАНДАРТ');
  for i:=0 to high(sda) do Cb_Styles.Items.Add(SysUtils.ExtractFileName(sda[i]));
  if Module.StyleName='' then Cb_Styles.ItemIndex:= 0 else Cb_Styles.Text:=Module.StyleName;
  Cb_Q.Items.Add('Завершить без подтверждения');
  Cb_Q.Items.Add('Спросить, если открыты любые окна');
  Cb_Q.Items.Add('Спросить, если открыт ввод данных');
  Cb_Q.ItemIndex:=Settings.InterfaceQuit;
  Cb_J.Items.Add('Открывать только одно окно данного типа');
  Cb_J.Items.Add('Открывать несколько окон');
  Cb_J.ItemIndex:=Settings.InterfaceFormsN;
  Cb_D.Items.Add('Открывать только одно окно данного типа');
  Cb_D.Items.Add('Открывать несколько окон');
  Cb_D.ItemIndex:=Settings.InterfaceDialogsN;
  Chb_DesignReports.Checked:=PrintReport.DesignReport;
  Result:=True;
end;

end.
