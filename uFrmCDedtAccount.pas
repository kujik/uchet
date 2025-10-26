unit uFrmCDedtAccount;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh,
  uFrMyPanelCaption, uFrmBasicMdi, uFrmBasicDbDialog, uData
  ;

type
  TFrmCDedtAccount = class(TFrmBasicDbDialog)
    pnlGeneral: TPanel;
    pnlPayments: TPanel;
    pnlGeneralM: TPanel;
    cmb_Cash: TDBComboBoxEh;
    edt_Account: TDBEditEh;
    cmb_Supplier: TDBComboBoxEh;
    Dt_Account: TDBDateTimeEditEh;
    cmb_Org: TDBComboBoxEh;
    cmb_User: TDBComboBoxEh;
    cmb_ExpenseItem: TDBComboBoxEh;
    nedt_Sum: TDBNumberEditEh;
    nedt_SumWoNds: TDBNumberEditEh;
    frmpcGeneral: TFrMyPanelCaption;
  private
    function  Prepare: Boolean; override;
    function  LoadComboBoxes: Boolean; override;
    procedure ControlOnExit(Sender: TObject); override;
    procedure ControlOnChange(Sender: TObject); override;
    function  Save: Boolean; override;
  public
  end;

var
  FrmCDedtAccount: TFrmCDedtAccount;

implementation

uses
  uForms,
  uDBOra,
  uString,
  uMessages,
  uFields,
  uTasks
;


{$R *.dfm}

function TFrmCDedtAccount.Prepare: Boolean;
begin
  Result := False;

  Caption := '—чет';
  FOpt.RefreshParent := True;
  FOpt.DlgPanelStyle := dpsBottomRight;
  FOpt.StatusBarMode := stbmDialog;

  Cth.MakePanelsFlat(pnlFrmClient, []);

  frmpcGeneral.SetParameters(True, 'ќсновное по счету', [['ƒанные счета.']], True);
  //pnlGeneralT.BevelEdges := [beTop];

{ // FOpt.AutoAlignControls := True;

  //проверим блокировку, выйдем если нельз€ вз€ть (при попытке редактировани€ уйдет в просмотр, при удалении - выход)
  if FormDbLock = fNone then
    Exit;


  Cth.MakePanelsFlat(pnlFrmClient, []);
  F.PrepareDefineFieldsAdd;
  if Table = '' then
    Table := View;
  if Mode <> fAdd then
    if not Load then
      Exit;
  //загрузим комбобоксы и сделаем другие кастомные действи€
//  if not LoadComboBoxes then
//    Exit;
  F.SetPropsControls;
  SetControlsEditable([], Mode in [fEdit, fCopy, fAdd]);      }
  Result := True;
end;

function TFrmCDedtAccount.LoadComboBoxes: Boolean;
begin

end;

procedure TFrmCDedtAccount.ControlOnExit(Sender: TObject);
begin

end;

procedure TFrmCDedtAccount.ControlOnChange(Sender: TObject);
begin

end;

function TFrmCDedtAccount.Save: Boolean;
begin

end;



end.
