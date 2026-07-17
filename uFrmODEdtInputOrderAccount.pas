unit uFrmODEdtInputOrderAccount;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,Vcl.StdCtrls,
  DBCtrlsEh, Vcl.ExtCtrls, Vcl.Mask,
  uFrmBasicMdi, uData
  ;

type
  TFrmODEdtInputOrderAccount = class(TFrmBasicMdi)
    dedt_Upd_Reg: TDBDateTimeEditEh;
    dedt_Upd: TDBDateTimeEditEh;
    edt_Upd: TDBEditEh;
  private
    FIsNewAccount: Boolean;
    procedure VerifyBeforeSave; override;
    function Save: Boolean; override;
  public
    function ShowDialog(AOwner: TObject; AIdOrder: Integer): Boolean;
  end;

var
  FrmODEdtInputOrderAccount: TFrmODEdtInputOrderAccount;

implementation

{$R *.dfm}

uses
  uNamedArr, uString, uDBOra, uForms
  ;


function TFrmODEdtInputOrderAccount.Save: Boolean;
begin
  Result := Q.QExecSql(
    'update orders set dt_account_reg = :dt_account_reg$d, dt_account = :dt_account$d, account = :account$s where id = :id$i',
    [S.IIf(dedt_Upd.Value = null, null, dedt_Upd_Reg.Value), dedt_Upd.Value, Trim(edt_Upd.Text), ID]
  ) >= 0;
end;

function TFrmODEdtInputOrderAccount.ShowDialog(AOwner: TObject; AIdOrder: Integer): Boolean;
var
  na: TNamedArr;
  LInfo: TVarDynArray2;
begin
  Result := False;
  Q.QLoad('select id, dt_account_reg, dt_account, account, prefix, dt_end, dt_beg, id_type, cashtype from orders where id = :id$i', [AIdOrder], na);
  //выходим без диалога для заказов не того префикса, если заказ не найден, если рекламация
  if (na.Count = 0) or(na.G('cashtype') <> 1) then Exit;
  //если заказ закрыт или нет прав - откроем на просмотр
  Mode:=S.IIf((na.G('dt_end') = null)and(User.Role(rOr_D_Order_EnteringAccount)), fEdit, fView);
  LInfo := [
   ['Введите данные счета.'#13#10+
    'Дата документа и его номер обязательны. Дата регистрации ставится автоматически.'#13#10 ,
    Mode <> fView],
   ['Для удаления записи очистите поля "Дата счета" и "№ счета"' ,
   Mode <> fView
  ]];
  PrepareCreatedForm(AOwner, Self.Name, '~Данные счета', Mode, AIdOrder, LInfo, [myfoModal, myfoDialog, myfoDialogButtonsB]);
  Cth.SetControlValue(dedt_Upd_Reg, S.IIf(na.G('dt_account_reg') = null, Date, na.G('dt_account_reg')));
  Cth.SetControlValue(dedt_Upd, na.G('dt_account'));
  Cth.SetControlValue(edt_Upd, na.G('account'));
  FIsNewAccount := na.G('dt_account_reg') = null;
  dedt_Upd_Reg.Enabled := False;
  dedt_Upd.Enabled := Mode <> fView;
  edt_Upd.Enabled := Mode <> fView;
  edt_Upd.MaxLength := 400;
  Result := ShowModal = mrOk;
  if not Result then
    Exit;
end;

procedure TFrmODEdtInputOrderAccount.VerifyBeforeSave;
begin
  if (dedt_Upd.Value = null) and (Trim(edt_Upd.Text) = '') and not FIsNewAccount then
    FErrorMessage := '?Удалить данные счета?'
  else if (dedt_Upd.Value = null) or (Trim(edt_Upd.Text) = '') then
    FErrorMessage := 'Данные некорректны!';
end;

end.


