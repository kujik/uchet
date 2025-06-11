{
Ввод данных УПД по заказу.
Имеет смысл только для префиксов Мб О и Ф
Вводится дата документа УПД и его номер (в тексте), дата регистрации проставляется автоматически
Данные записываются в таблицу orders, поля там есть всегда
Для удаления всех трех значений для УПД надо стереть в диалоге дату и номер документа.
}
unit D_Order_UPD;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_Normal, DBCtrlsEh, Vcl.StdCtrls,
  Vcl.Mask, Vcl.Buttons, uString, Vcl.ExtCtrls;

type
  TDlg_Order_UPD = class(TForm_Normal)
    Bt_Ok: TBitBtn;
    Bt_Cancel: TBitBtn;
    De_Upd_Reg: TDBDateTimeEditEh;
    De_Upd: TDBDateTimeEditEh;
    E_Upd: TDBEditEh;
    Img_Info: TImage;
    procedure Bt_OkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    ID: Variant;
    va2: TVarDynArray2;
  public
    { Public declarations }
    function ShowDialog(aID: Variant): Boolean;
  end;

var
  Dlg_Order_UPD: TDlg_Order_UPD;

implementation

{$R *.dfm}

uses
  uForms,
  uMessages,
  uDBOra,
  uData,
  uTurv
  ;

procedure TDlg_Order_UPD.Bt_OkClick(Sender: TObject);
begin
  inherited;
  ModalResult:=mrNone;
  if (va2[0][1] <> null)and(De_Upd.Value = null)and(Trim(E_Upd.Text) = '') then begin
    if (MyQuestionMessage('Удалить данные УПД?') = mrYes) then begin
    end
    else Exit;
  end
  else if (De_Upd.Value = null)or(Trim(E_Upd.Text) = '')or(De_Upd.Value > Date)or
          (De_Upd.Value < Turv.GetDaysFromCalendar_Next(va2[0][6], -5))
    then begin
      MyWarningMessage('Данные некорректны!');
      Exit;
    end;
  Q.QExecSql(
    'update orders set dt_upd_reg = :dt_upd_reg$d, dt_upd = :dt_upd$d, upd = :upd$s where id = :id$i',
    [S.IIf(De_Upd.Value = null, null, De_Upd_Reg.Value), De_Upd.Value, Trim(E_Upd.Text), ID]
  );
  ModalResult:=mrOk;
end;

procedure TDlg_Order_UPD.FormShow(Sender: TObject);
begin
  inherited;
  //почему-то съезжает вверх при первом показе формы, так правим
  Img_Info.Top:=Bt_Ok.top;
end;

function TDlg_Order_UPD.ShowDialog(aID: Variant): Boolean;
begin
  Result:=False;
  ID:= aID;
  va2:=Q.QLoadToVarDynArray2('select id, dt_upd_reg, dt_upd, upd, prefix, dt_end, dt_beg, id_type from orders where id = :id$i', [ID]);
  //выходим без диалога для заказов не того префикса, если заказ не найден, если рекламация
  if (Length(va2) = 0)or not A.InArray(va2[0][4], ['М','О','Ф'])or(va2[0][7] = 2) then Exit;
  //если заказ закрыт или нет прав - откроем на просмотр
  Mode:=S.IIf((va2[0][5] = null)and(User.Role(rOr_D_Order_EnteringUPD)), fEdit, fView);
  //!!!временно
  Mode:=S.IIf((User.Role(rOr_D_Order_EnteringUPD)), fEdit, fView);
  Cth.SetDialogForm(Self, Mode, 'УПД');
  Cth.SetControlValue(De_Upd_Reg, S.IIf(va2[0][1] = null, Date, va2[0][1]));
  Cth.SetControlValue(De_Upd, va2[0][2]);
  Cth.SetControlValue(E_Upd, va2[0][3]);
  De_Upd_Reg.Enabled:=False;
  De_Upd.Enabled:= Mode <> fView;
  E_Upd.Enabled:= Mode <> fView;
  E_Upd.MaxLength:=20;
  Cth.SetInfoIcon(Img_Info,Cth.SetInfoIconText(Self, [
   ['Введите данные УПД.'#13#10+
    'Дата документа и его номер обязательны. Дата регистрации ставится автоматически.'#13#10 ,
    Mode<>fView],
   ['Для удаления записи очистите поля "Дата УПД" и "№ УПД"' ,
   (Mode<>fView)and(va2[0][1] <> null)]
  ]), 20);
  Img_Info.Top:=Bt_Ok.top;
  Result:=ShowModal = mrOk;
end;


end.
