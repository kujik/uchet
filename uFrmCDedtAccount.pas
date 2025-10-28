unit uFrmCDedtAccount;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh, Math,
  uFrMyPanelCaption, uFrmBasicMdi, uFrmBasicDbDialog, uData, uFrDBGridEh,
  Data.Bind.EngExt, Vcl.Bind.DBEngExt, Data.Bind.Components
  ;

type
  TFrmCDedtAccount = class(TFrmBasicDbDialog)
    pnlGeneral: TPanel;
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
    cmb_Nds: TDBComboBoxEh;
    pnlRoute: TPanel;
    frmpcRoute: TFrMyPanelCaption;
    pnl_Route: TPanel;
    cmb_CarType: TDBComboBoxEh;
    cmb_Flight: TDBComboBoxEh;
    nedt_Kilometrage: TDBNumberEditEh;
    dedt_FlightDt: TDBDateTimeEditEh;
    nedt_Idle: TDBNumberEditEh;
    nedt_PriceKm: TDBNumberEditEh;
    nedt_PriceIdle: TDBNumberEditEh;
    nedt_SumOther: TDBNumberEditEh;
    FrgRoute: TFrDBGridEh;
    pnlBasis: TPanel;
    frmpcBasis: TFrMyPanelCaption;
    FrgBasis: TFrDBGridEh;
    BindingsList1: TBindingsList;
    pnlPayments: TPanel;
    scrlbxPaymentsM: TScrollBox;
    pnlPaymentsD: TPanel;
    dedt_1: TDBDateTimeEditEh;
    nedt_1: TDBNumberEditEh;
    frmpcPayments: TFrMyPanelCaption;
  private
    function  Prepare: Boolean; override;
    function  LoadComboBoxes: Boolean; override;
    procedure ControlOnExit(Sender: TObject); override;
    procedure ControlOnEnter(Sender: TObject); override;
    procedure ControlOnChange(Sender: TObject); override;
    procedure EdtPaymentOnChaange(Sender: TObject);
    function  Save: Boolean; override;

    procedure CreatePaymentsEdts;
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

procedure TFrmCDedtAccount.CreatePaymentsEdts;
var
  i, j: Integer;
  dedt1: TDBDateTimeEditEh;
  nedt1: TDBNumberEditEh;
  w: Integer;
begin
  pnlPaymentsD.Visible := False;
  w := nedt_1.Left + nedt_1.Width + 25;
  for i := 1 to 10 do
    for j := S.IIf(i = 1, 2, 1) to 3 do begin
      dedt1 := TDBDateTimeEditEh.Create(Self);
      dedt1.Parent := pnlPaymentsD;
      dedt1.Name := 'dedt_' + IntToStr((i - 1) * 3 + j);
      dedt1.Visible := (i = 1) and (j = 1);
      dedt1.Left := (j - 1) * w  + dedt_1.Left;
      dedt1.Width := dedt_1.Width;
      dedt1.Top := (i - 1) * (dedt_1.Height + 4) + dedt_1.Top;
      dedt1.ControlLabelLocation.Position := lpLeftCenterEh;
      dedt1.ControlLabel.Visible := True;
      dedt1.ControlLabel.Caption := IntToStr((i - 1) * 3 + j);
      nedt1 := TDBNumberEditEh.Create(Self);
      nedt1.Parent := pnlPaymentsD;
      nedt1.Name := 'nedt_' + IntToStr((i - 1) * 3 + j);
      nedt1.Visible := (i = 1) and (j = 1);
      nedt1.Left := (j - 1) * w  + nedt_1.Left;
      nedt1.Width := nedt_1.Width;
      nedt1.Top := dedt1.Top;
    end;
  pnlPaymentsD.Visible := True;
end;

procedure TFrmCDedtAccount.EdtPaymentOnChaange(Sender: TObject);
var
  i, j: Integer;
  b: Boolean;
begin
  i := 30;
  while (i > 1) and ((GetControlValue('dedt_' + IntToStr(i), True) = null) and (GetControlValue('nedt_' + IntToStr(i), True) = null)) do
    dec(i);
  b := False;
  for j := i downto 1 do
    if (GetControlValue('dedt_' + IntToStr(j), True) = null) and (GetControlValue('nedt_' + IntToStr(j), True) = null) then begin
       b := True;
       Break;
    end;
  if (not b) and (i < 30) then begin
    TControl(FindComponent('dedt_' + IntToStr(i + 1))).Visible := True;
    TControl(FindComponent('nedt_' + IntToStr(i + 1))).Visible := True;
  end;
  i := 30;
  while (i > 1) and not TControl(FindComponent('dedt_' + IntToStr(i))).Visible do
    dec(i);
  pnlPaymentsD.Height := TControl(FindComponent('nedt_' + IntToStr(i))).Top + TControl(FindComponent('nedt_' + IntToStr(i))).Height + 8;
  scrlbxPaymentsM.Height := Min(pnlPaymentsD.Height + 4, (dedt_1.Height + 4) * 3 + 4 + 4);
  pnlPayments.Height := frmpcPayments.Height + scrlbxPaymentsM.Height;
end;



function TFrmCDedtAccount.Prepare: Boolean;
begin
  Result := False;

  Caption := 'Счет';
  FOpt.RefreshParent := True;
  FOpt.DlgPanelStyle := dpsBottomRight;
  FOpt.StatusBarMode := stbmDialog;

  Cth.MakePanelsFlat(pnlFrmClient, []);

  frmpcGeneral.SetParameters(True, 'Основное по счету', [['Данные счета.']], False);
  //FWHCorrected := Cth.AlignControls(pnlFrmClient, FOpt.ControlsWoAligment, False);
  Cth.AlignControls(pnlGeneralM, FOpt.ControlsWoAligment, True);
  pnlGeneral.Height := frmpcGeneral.Height + pnlGeneralM.Height;

  frmpcPayments.SetParameters(True, 'Платежи', [['Данные счета.']], False);
  CreatePaymentsEdts;
  //Cth.AlignControls(pnlPaymentsM, FOpt.ControlsWoAligment, True);
//  dedt_1.Visible := True;


  //pnlGeneralT.BevelEdges := [beTop];

{ // FOpt.AutoAlignControls := True;

  //проверим блокировку, выйдем если нельзя взять (при попытке редактирования уйдет в просмотр, при удалении - выход)
  if FormDbLock = fNone then
    Exit;


  Cth.MakePanelsFlat(pnlFrmClient, []);
  F.PrepareDefineFieldsAdd;
  if Table = '' then
    Table := View;
  if Mode <> fAdd then
    if not Load then
      Exit;
  //загрузим комбобоксы и сделаем другие кастомные действия
//  if not LoadComboBoxes then
//    Exit;
  F.SetPropsControls;
  SetControlsEditable([], Mode in [fEdit, fCopy, fAdd]);      }
  Result := True;
end;

function TFrmCDedtAccount.LoadComboBoxes: Boolean;
begin

end;

procedure TFrmCDedtAccount.ControlOnEnter(Sender: TObject);
begin

end;

procedure TFrmCDedtAccount.ControlOnExit(Sender: TObject);
begin

end;

procedure TFrmCDedtAccount.ControlOnChange(Sender: TObject);
var
  Name: string;
begin
  Name := TControl(Sender).Name;
  if ((Pos('dedt_', Name) = 1) or (Pos('nedt_', Name) = 1)) and  S.IsNumber(Copy(Name, 6, 2), 1, 99)  then
    EdtPaymentOnChaange(Sender);

end;

function TFrmCDedtAccount.Save: Boolean;
begin

end;



end.
