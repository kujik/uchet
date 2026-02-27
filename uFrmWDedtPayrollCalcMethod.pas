unit uFrmWDedtPayrollCalcMethod;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, DBCtrlsEh, Vcl.ExtCtrls, Vcl.Mask,
  uFrmBasicMdi, uString, uNamedArr
  ;

type
  TFrmWDedtPayrollCalcMethod = class(TFrmBasicMdi)
    rgOvertime: TRadioGroup;
    rgMethod: TRadioGroup;
    procedure rgMethodClick(Sender: TObject);
    procedure rgOvertimeClick(Sender: TObject);
  private
    function  VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean; override;
  public
    function ShowDialog(var Params: TNamedArr): Boolean;
  end;

var
  FrmWDedtPayrollCalcMethod: TFrmWDedtPayrollCalcMethod;

implementation

uses
  uData, uForms, uMessages, uDBOra;

{$R *.dfm}

function TFrmWDedtPayrollCalcMethod.VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean;
begin
  Result := (rgMethod.ItemIndex = -1) or (rgOvertime.ItemIndex = -1) or ((rgMethod.ItemIndex = 2) and (rgOvertime.ItemIndex <> 0));
end;

procedure TFrmWDedtPayrollCalcMethod.rgMethodClick(Sender: TObject);
begin
  Verify(nil);
end;

procedure TFrmWDedtPayrollCalcMethod.rgOvertimeClick(Sender: TObject);
begin
  Verify(nil);
end;

function TFrmWDedtPayrollCalcMethod.ShowDialog(var Params: TNamedArr): Boolean;
begin
  PrepareCreatedForm(Application, '', '~Метод расчета', fEdit, null, [['Выберите метод расчета заработной платы'#13#10'(выбранный метод сохранится и будет использоваться и в будущих ведомостях)']], [myfoDialog, myfoDialogButtonsB]);

  rgMethod.Items.Clear;
  rgMethod.Items.Add('Офис');
  rgMethod.Items.Add('Цех');
  rgMethod.Items.Add('Загрузка мотивации');
  rgMethod.ItemIndex := -1;
  rgOvertime.Items.Clear;
  rgOvertime.Items.Add('Не учитываются');
  rgOvertime.Items.Add('Рассчитываются с коэффициентом 1');
  rgOvertime.Items.Add('Рассчитываются с коэффициентом 1.5');
  rgOvertime.ItemIndex := -1;

  if Params.G('calc_method') <> null then
    rgMethod.ItemIndex := Params.G('calc_method') - 1;
  if Params.G('overtime_method') <> null then
    rgOvertime.ItemIndex := Params.G('overtime_method') - 1;

  Result := False;
  if ShowModal <> mrOk then
    Exit;
  if rgMethod.ItemIndex = 2 then
    rgOvertime.ItemIndex := 0;
  if (Params.G('calc_method') = (rgMethod.ItemIndex + 1)) and (Params.G('overtime_method') = (rgOvertime.ItemIndex + 1)) then
    Exit;
  Params.SetValue('calc_method', rgMethod.ItemIndex + 1);
  Params.SetValue('overtime_method', rgOvertime.ItemIndex + 1);
  Result := True;
end;

end.
