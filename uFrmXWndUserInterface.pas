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
    pnlLeft: TPanel;
    bvl1: TBevel;
    btnDef: TBitBtn;
    chbDesignReports: TCheckBox;
    cmbD: TDBComboBoxEh;
    cmbJ: TDBComboBoxEh;
    cmbQ: TDBComboBoxEh;
    cmbStyles: TDBComboBoxEh;
    btn1: TBitBtn;
    rb1: TRadioButton;
    chb1: TCheckBox;
    edt1: TDBEditEh;
    lbl1: TLabel;
    lbl2: TLabel;
    Frg1: TFrDBGridEh;
    procedure Bt_DefClick(Sender: TObject);
  private
    function  Prepare: Boolean; override;
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
  cmbQ.ItemIndex:=0;
  cmbJ.ItemIndex:=0;
  cmbD.ItemIndex:=1;
  cmbStyles.ItemIndex:=0;
end;

procedure TFrmXWndUserInterface.ControlOnChange(Sender: TObject);
var
  st: string;
begin
  if FInPrepare then Exit;
  if A.InArray(TControl(Sender).Name, ['cmbQ', 'cmbJ', 'cmbD']) then
    Settings.WriteInterfaceSettings(S.IIFStr(cmbStyles.ItemIndex = 0, '', cmbStyles.Text), cmbQ.ItemIndex, cmbJ.ItemIndex, cmbD.ItemIndex)
  else if TControl(Sender).Name = 'chbDesignReports' then
    PrintReport.SetDesignReport(chbDesignReports.Checked)
  else if TControl(Sender).Name = 'cmbStyles' then begin
    if cmbStyles.Text = 'СТАНДАРТ' then st:='' else st:= Module.GetPath_Styles + '\' + cmbStyles.Text;
    Settings.WriteInterfaceSettings(S.IIFStr(cmbStyles.ItemIndex = 0, '', cmbStyles.Text), cmbQ.ItemIndex, cmbJ.ItemIndex, cmbD.ItemIndex);
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

  Cth.SetBtn(btn1, mybtCancel);
  btn1.Caption:='Кнопка';
  //lbl1.Font.Color:=rgb(200,10,210);
  sda:=Sys.GetFileInDirectoryOnly(Module.GetPath_Styles);
  cmbStyles.Items.Add('СТАНДАРТ');
  for i:=0 to high(sda) do cmbStyles.Items.Add(SysUtils.ExtractFileName(sda[i]));
  if Module.StyleName='' then cmbStyles.ItemIndex:= 0 else cmbStyles.Text:=Module.StyleName;
  cmbQ.Items.Add('Завершить без подтверждения');
  cmbQ.Items.Add('Спросить, если открыты любые окна');
  cmbQ.Items.Add('Спросить, если открыт ввод данных');
  cmbQ.ItemIndex:=Settings.InterfaceQuit;
  cmbJ.Items.Add('Открывать только одно окно данного типа');
  cmbJ.Items.Add('Открывать несколько окон');
  cmbJ.ItemIndex:=Settings.InterfaceFormsN;
  cmbD.Items.Add('Открывать только одно окно данного типа');
  cmbD.Items.Add('Открывать несколько окон');
  cmbD.ItemIndex:=Settings.InterfaceDialogsN;
  chbDesignReports.Checked:=PrintReport.DesignReport;
  FOpt.AutoAlignControls := False;
  Result:=True;
end;


end.
