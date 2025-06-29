//!!!”ƒјЋ»“№

unit D_SnOrder;
//ввод даты и суммы платежа дл€ журнала платежей по заказам
//работает в диалоговом режиме

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, uDBOra, uMessages, uData,
  DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, EhLibVCL,
  GridsEh, DBAxisGridsEh, DBGridEh, PropFilerEh, PropStorageEh, Math,
  Mask, uStringCalculator, V_Normal,
  DBCtrlsEh, ExtCtrls, uString, uForms;

type
  TDlg_SnOrder = class(TForm_Normal)
    dedtDate: TDBDateTimeEditEh;
    nedt_Sum: TDBNumberEditEh;
    Bt_Ok: TBitBtn;
    Bt_Cancel: TBitBtn;
    procedure Bt_OkClick(Sender: TObject);
  private
    { Private declarations }
    Journal: Integer;
    Mode: TDialogType;
    ID: Integer;
    ID_Order: Integer;
    OrNum: string;
  public
    { Public declarations }
    function ShowDialog(aJournal: Integer; aMode: TDialogType; aID: Integer; aID_Order: Integer; aDt: TdateTime; aSum: Extended; aOrNum: string): Integer;
  end;

var
  Dlg_SnOrder: TDlg_SnOrder;

implementation

uses
  uOrders;

{$R *.dfm}

procedure TDlg_SnOrder.Bt_OkClick(Sender: TObject);
begin
  if (dedtDate.Value = null) or (nedt_Sum.Value = null)
    then ModalResult:=mrNone
    else ModalResult:=mrOk;
end;

//вызов диалога
//данные не читаютс€ из таблицы, берутс€ из грида, передаютс€ сюда
function TDlg_SnOrder.ShowDialog(aJournal: Integer; aMode: TDialogType; aID: Integer; aID_Order: Integer; aDt: TdateTime; aSum: Extended; aOrNum: string): Integer;
var
  v: TVarDynArray;
  i, j: Integer;
  IUDMode: char;
begin
  Journal:=aJournal;
  ID:=aID;
  ID_Order:=aID_Order;
  OrNum:=aOrNum;
  Mode:=aMode;
  Cth.SetDialogForm(Self, Mode, 'ѕлатЄж');
  Self.dedtDate.Value:=adt;
  if Mode = fAdd then dedtDate.Value:=Date;
  Self.nedt_Sum.Value:=aSum;
  Self.nedt_Sum.Enabled:=(Mode<>fDelete);
  Self.dedtDate.Enabled:=Self.nedt_Sum.Enabled;
  Result:=-1;
  if Self.ShowModal = mrOk then
    begin
      Q.QCallStoredProc('p_Or_Payment'+S.IIf(Journal = 2, '_n', ''), 'IdOrder$i;PSum$f;PDt$d;PAdd$i',
        [ID_order, S.IIf(Mode = fDelete, 0, Cth.GetControlValue(nedt_Sum)), Cth.GetControlValue(dedtDate), S.IIf(Mode = fAdd, 1, 0)]
      );
      Result:=1;
      if OrNum[1] = 'Ќ'
        then Orders.FinalizeOrder(ID_Order, myOrFinalizePay);
 {     Exit;
      if Mode = fDelete
        then v:=[ID]
        else v:= [ID, ID_Order, Cth.GetControlValue(dedtDate), Cth.GetControlValue(nedt_Sum)];
      case Mode of
        fAdd, fCopy: IUDMode:='i';
        fDelete: IUDMode:='d';
        fEdit: IUDMode:='u';
      end;
      //Result:= 1;
      Result:= QIUD(IUDMode, 'sn_order_payments', 'sq_sn_order_payments', 'id;id_order;dt;sum', v);}
    end;
end;


end.
