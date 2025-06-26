unit D_PayrollSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_Normal, Vcl.StdCtrls, Vcl.Mask,
  DBCtrlsEh, Vcl.Buttons, DateUtils,
  uString,
  Vcl.ComCtrls
  ;

type
  TDlg_PayrollSettings = class(TForm_Normal)
    Bt_OK: TBitBtn;
    Bt_Cancel: TBitBtn;
    Ne_Norm0: TDBNumberEditEh;
    Cb_Method: TDBComboBoxEh;
    Lb_Norm: TLabel;
    Ne_Norm1: TDBNumberEditEh;
    procedure Bt_OKClick(Sender: TObject);
  private
    { Private declarations }
    Values_ : TVarDynArray;
  public
    { Public declarations }
    function ShowDialog(var Values: TVarDynArray): Integer;
  end;

var
  Dlg_PayrollSettings: TDlg_PayrollSettings;

implementation

uses
  uTurv,
  uMessages,
  uDBOra,
  uData,
  uForms
  ;

{$R *.dfm}

procedure TDlg_PayrollSettings.Bt_OKClick(Sender: TObject);
var
  st1, st2: string;
begin
  inherited;
  ModalResult:=mrNone;
  if (Ne_Norm1.Value = null) or (Ne_Norm0.Value = null) or (Cth.GetControlValue(Cb_Method) = '')
    then Exit;
  if (Ne_Norm0.Value <> Values_[0]) or (Ne_Norm1.Value <> Values_[1])
      then st1:='Вы изменили значение нормы!'#13#10'Вам необходимо будет обновить все ведомости за этот период (в которых норма используется для расчета)!';
  if Cth.GetControlValue(Cb_Method) <> Values_[2]
    then st2:='Вы изменили способ расчета заработной платы!'#13#10'Некоторые введенные данные могут быть потеряны!';
  if (st1 <> '') or (st2 <> '') then begin
    if MyQuestionMessage(st1 + #13#10#13#10 + st2 + #13#10#13#10 + 'Продолжить?') <> mrYes then Exit;
    ModalResult:=mrYes;
  end
  else begin
    ModalResult:=mrOk;
  end;
end;

function TDlg_PayrollSettings.ShowDialog(var Values: TVarDynArray): Integer;
begin
  Cth.SetBtn(Bt_Ok, mybtOk, False);
  Cth.SetBtn(Bt_Cancel, mybtCancel, False);
  Values_:=Copy(Values);
  Ne_Norm0.Value:= Values[0];
  Ne_Norm1.Value:= Values[1];
  Q.QLoadToDBComboBoxEh('select name, id from payroll_method order by name', [], Cb_Method, cntComboLK);
  Cth.SetControlValue(Cb_Method, Values[2]);
  Bt_Ok.ModalResult:=mrNone;
  Result:=ShowModal;
  if Result <> mrYes then Exit;
  Values[0]:=Ne_Norm0.Value;
  Values[1]:=Ne_Norm1.Value;
  Values[2]:=Cth.GetControlValue(Cb_Method);
//  Result:=ModalResult;
end;


end.
