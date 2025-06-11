{
устанавливает остаки по кассам и сбрасывает период отчета по платежам в журнале касс
}

unit uFrmCDedtCashRevision;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmBasicMdi, Vcl.ExtCtrls, Vcl.StdCtrls,
  DBCtrlsEh, Vcl.Mask, uData, uMessages, uString, uDBOra, uForms;

type
  TFrmCDedtCashRevision = class(TFrmBasicMdi)
    De_Date: TDBDateTimeEditEh;
    Ne_Cash1: TDBNumberEditEh;
    Ne_Cash2: TDBNumberEditEh;
    Ne_Deposit: TDBNumberEditEh;
    procedure FormShow(Sender: TObject);
  private
    function  Prepare: Boolean; override;
    procedure BtOkClick(Sender: TObject); override;
    procedure Save;
  public
  end;

var
  FrmCDedtCashRevision: TFrmCDedtCashRevision;

implementation

{$R *.dfm}

procedure TFrmCDedtCashRevision.BtOkClick(Sender: TObject);
//сюда попадает если видна кнопка Изменить (она же Ок после первого нажатия)
begin
  if Mode=fEdit then begin
    ModalResult:=mrNone;
    if MyQuestionMessage('Вы уверены, что хотите задать остатки по кассе на заданную дату?') <> mrYes then exit;
    //зададим контролы и их значения для режима редактирования
    Cth.SetBtn(BtOk, mybtOk, False);
//    Cth.SetBtn(BtCancel, mybtCancel, False);
    De_Date.Value:=Date;
    Ne_Cash1.Value:=null;
    Ne_Cash2.Value:=null;
    Ne_Deposit.Value:=null;
    //2023-01-20 - разрешваем задание остатков не сегодняшней датой
    SetControlsEditable([De_Date, Ne_Cash1, Ne_Cash2, Ne_Deposit], True);
    Mode:=fAdd;
  end
  else begin
    //в режиме редактирования - проверим все ли заполнено и переспросим
    ModalResult:=mrNone;
    if (De_Date.Value = null) or (Ne_Cash1.Value = null) or (Ne_Cash2.Value = null) or (Ne_Deposit.Value = null) then
      Exit;
    if MyQuestionMessage('Установить остатки по кассе на заданную дату?') <> mrYes then
      Exit;
    Save;
    Close;
  end;
end;

procedure TFrmCDedtCashRevision.FormShow(Sender: TObject);
begin
  inherited;
  if Mode = fEdit then
    Cth.SetBtn(BtOk, mybtEdit, False);
  SetControlsEditable([De_Date, Ne_Cash1, Ne_Cash2, Ne_Deposit], False);
end;

function TFrmCDedtCashRevision.Prepare: Boolean;
begin
  Result := False;
  Caption:='~Остатки по кассе';
  //центрировакие относительно родительской формы
  MyFormOptions := MyFormOptions + [myfoDialog, myfoModal];
  //панель кнопок внизу
  FOpt.DlgPanelStyle := dpsBottomRight;
  //если есть права на изменения остатков по кассе, предусмотрим кнопку редактирования
  if User.Roles([], [rPC_A_Cash_Revision_Ch])
    then Mode := fEdit
    else Mode := fView;
  //значения и состояния контролов в режиме просмотра
  De_Date.Value:=Q.QSelectOneRow('select dt from sn_cash_revision_dt', [])[0];
  Ne_Cash1.Value:=Q.QSelectOneRow('select sum from sn_cash_revision_sum where id = -1', [])[0];
  Ne_Cash2.Value:=Q.QSelectOneRow('select sum from sn_cash_revision_sum where id = -2', [])[0];
  Ne_Deposit.Value:=Q.QSelectOneRow('select sum from sn_cash_revision_sum where id = -9', [])[0];
  Result := True;
end;

procedure TFrmCDedtCashRevision.Save;
begin
  Q.QBeginTrans(True);
  Q.QExecSql('update sn_cash_revision_dt set dt = :dt', [Cth.GetControlValue(De_Date)]);
  Q.QExecSql('update sn_cash_revision_sum set sum = :sum where id=-1', [Cth.GetControlValue(Ne_Cash1)]);
  Q.QExecSql('update sn_cash_revision_sum set sum = :sum where id=-2', [Cth.GetControlValue(Ne_Cash2)]);
  Q.QExecSql('update sn_cash_revision_sum set sum = :sum where id=-9', [Cth.GetControlValue(Ne_Deposit)]);
  Q.QCommitOrRollback;
end;




end.
