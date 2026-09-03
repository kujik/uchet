{
Ввод данных УПД по заказу.
Имеет смысл только для префиксов М, О и Ф
Вводится дата документа УПД и его номер (в тексте), дата регистрации проставляется автоматически
Данные записываются в таблицу orders, поля там есть всегда
Для удаления всех трех значений для УПД надо стереть в диалоге дату и номер документа.
См. также аналогичный диалог uFrmODEdtInputOrderAccount.pas (данные счета по заказу) - структура и логика те же.
}
unit uFrmODedtOrderUPD;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  DBCtrlsEh, Vcl.ExtCtrls, Vcl.Mask,
  uFrmBasicMdi, uData
  ;

type
  TFrmODedtOrderUPD = class(TFrmBasicMdi)
    dedt_Upd_Reg: TDBDateTimeEditEh;
    dedt_Upd: TDBDateTimeEditEh;
    edt_Upd: TDBEditEh;
  private
    { Private declarations }
    FDtBeg: Variant;
    FIsNewUpd: Boolean;
    procedure VerifyBeforeSave; override;
    function Save: Boolean; override;
  public
    { Public declarations }
    function ShowDialog(AOwner: TObject; AIdOrder: Integer): Boolean;
  end;

var
  FrmODedtOrderUPD: TFrmODedtOrderUPD;

implementation

{$R *.dfm}

uses
  uNamedArr, uString, uDBOra, uForms, uTurv
  ;

function TFrmODedtOrderUPD.ShowDialog(AOwner: TObject; AIdOrder: Integer): Boolean;
var
  na: TNamedArr;
  LInfo: TVarDynArray2;
begin
  Result := False;
  Q.QLoad('select id, dt_upd_reg, dt_upd, upd, prefix, dt_end, dt_beg, id_type from orders where id = :id$i', [AIdOrder], na);
  //выходим без диалога для заказов не того префикса, если заказ не найден, если рекламация
  if (na.Count = 0) or not A.InArray(na.G('prefix'), ['М','О','Ф']) or (na.G('id_type') = 2) then Exit;
  //режим - по праву на ввод УПД (см. также исходный D_Order_UPD.ShowDialog: там было закомментированное "!!!временно",
  //которое реально и срабатывало - проверка dt_end (закрыт ли заказ) в расчете режима не участвовала; это поведение
  //сохранено без изменений)
  Mode := S.IIf(User.Role(rOr_D_Order_EnteringUPD), fEdit, fView);
  FDtBeg := na.G('dt_beg');
  FIsNewUpd := na.G('dt_upd_reg') = null;
  LInfo := [
   ['Введите данные УПД.'#13#10+
    'Дата документа и его номер обязательны. Дата регистрации ставится автоматически.'#13#10,
    Mode <> fView],
   ['Для удаления записи очистите поля "Дата УПД" и "№ УПД"',
   (Mode <> fView) and not FIsNewUpd]
  ];
  PrepareCreatedForm(AOwner, Self.Name, '~УПД', Mode, AIdOrder, LInfo, [myfoModal, myfoDialog, myfoDialogButtonsB]);
  Cth.SetControlValue(dedt_Upd_Reg, S.IIf(na.G('dt_upd_reg') = null, Date, na.G('dt_upd_reg')));
  Cth.SetControlValue(dedt_Upd, na.G('dt_upd'));
  Cth.SetControlValue(edt_Upd, na.G('upd'));
  dedt_Upd_Reg.Enabled := False;
  dedt_Upd.Enabled := Mode <> fView;
  edt_Upd.Enabled := Mode <> fView;
  edt_Upd.MaxLength := 20;
  Result := ShowModal = mrOk;
end;

procedure TFrmODedtOrderUPD.VerifyBeforeSave;
//проверка перед сохранением (см. TFrmBasicMdi.btnOkClick): если FErrorMessage начинается с '?' - показывается
//вопрос (Да - сохраняем), иначе - предупреждение (сохранение блокируется). см. также аналогичный пример в
//uFrmODEdtInputOrderAccount.VerifyBeforeSave
begin
  if (dedt_Upd.Value = null) and (Trim(edt_Upd.Text) = '') and not FIsNewUpd then
    FErrorMessage := '?Удалить данные УПД?'
  else if (dedt_Upd.Value = null) or (Trim(edt_Upd.Text) = '') or (dedt_Upd.Value > Date) or
          (dedt_Upd.Value < Turv.GetDaysFromCalendar_Next(FDtBeg, -5)) then
    FErrorMessage := 'Данные некорректны!';
end;

function TFrmODedtOrderUPD.Save: Boolean;
begin
  Result := Q.QExecSql(
    'update orders set dt_upd_reg = :dt_upd_reg$d, dt_upd = :dt_upd$d, upd = :upd$s where id = :id$i',
    [S.IIf(dedt_Upd.Value = null, null, dedt_Upd_Reg.Value), dedt_Upd.Value, Trim(edt_Upd.Text), ID]
  ) >= 0;
end;

end.
