unit uFrmXWndUserInterface;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Math,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, Mask, uData, uForms, uDBOra, uString, uMessages, System.Types,
  Vcl.ExtCtrls, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, MemTableDataEh, MemTableEh,
  Data.DB, Vcl.Menus, Vcl.Imaging.pngimage, Vcl.ComCtrls,
  uSettings, uFrmBasicMdi, uFrDBGridEh
  ;

type
  TFrmXWndUserInterface = class(TFrmBasicMdi)
    PLeft: TPanel;
    Bevel1: TBevel;
    Bt_Def: TBitBtn;
    Chb_DesignReports: TCheckBox;
    Cb_D: TDBComboBoxEh;
    Cb_J: TDBComboBoxEh;
    Cb_Q: TDBComboBoxEh;
    Cb_Styles: TDBComboBoxEh;
    Bt_1: TBitBtn;
    RadioButton1: TRadioButton;
    CheckBox1: TCheckBox;
    DBEditEh1: TDBEditEh;
    Label1: TLabel;
    Label2: TLabel;
    Frg1: TFrDBGridEh;
    procedure Bt_DefClick(Sender: TObject);
  private
    function Prepare: Boolean; override;
    procedure ControlOnChange(Sender: TObject); override;
  public
  end;

var
  FrmXWndUserInterface: TFrmXWndUserInterface;

implementation

{$R *.dfm}

uses
  uWindows,
  uFrmMain,
  uPrintReport,
  uSys
  ;

{$R *.dfm}


procedure TFrmXWndUserInterface.Bt_DefClick(Sender: TObject);
begin
  Cb_Q.ItemIndex:=0;
  Cb_J.ItemIndex:=0;
  Cb_D.ItemIndex:=1;
  Cb_Styles.ItemIndex:=0;
end;

procedure TFrmXWndUserInterface.ControlOnChange(Sender: TObject);
var
  st: string;
begin
  if FInPrepare then Exit;
  if A.InArray(TControl(Sender).Name, ['Cb_Q', 'Cb_J', 'Cb_D']) then
    Settings.WriteInterfaceSettings(S.IIFStr(Cb_Styles.ItemIndex = 0, '', Cb_Styles.Text), Cb_Q.ItemIndex, Cb_J.ItemIndex, Cb_D.ItemIndex)
  else if TControl(Sender).Name = 'Chb_DesignReports' then
    PrintReport.SetDesignReport(Chb_DesignReports.Checked)
  else if TControl(Sender).Name = 'Cb_Styles' then begin
    if Cb_Styles.Text = 'СТАНДАРТ' then st:='' else st:= Module.GetPath_Styles + '\' + Cb_Styles.Text;
    Settings.WriteInterfaceSettings(S.IIFStr(Cb_Styles.ItemIndex = 0, '', Cb_Styles.Text), Cb_Q.ItemIndex, Cb_J.ItemIndex, Cb_D.ItemIndex);
    Module.SetStyle(st);
    Close;
    FrmMain.TimerSetStyle.Enabled := True;
  end;
end;

function TFrmXWndUserInterface.Prepare: Boolean;
var
  i: Integer;
  sda: TStringDynArray;
  va2: TVarDynArray2;
begin
  Caption := '~Настройки программы';

  Frg1.Opt.SetFields([
    ['f1$s','100;w','Заголовок 1'],
    ['f2$s','100;w','Заголовок 2', 'bt=кнопка в таблице'],
    ['f3$s','40','3','chb']
  ]);
  for i:=1 to 10 do
    va2 := va2 + [['Строка ' + IntToStr(i), 'Строка ' + IntToStr(i), S.IIf(odd(i), 0, 1)]];
  Frg1.SetInitData(va2, '');
  Frg1.Prepare;
  Frg1.RefreshGrid;

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
  FOpt.AutoAlignControls := False;
  Result:=True;
end;


end.
