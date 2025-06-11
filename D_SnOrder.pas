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
    De_Date: TDBDateTimeEditEh;
    Ne_Sum: TDBNumberEditEh;
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
  if (De_Date.Value = null) or (Ne_Sum.Value = null)
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
  Self.De_Date.Value:=adt;
  if Mode = fAdd then De_Date.Value:=Date;
  Self.Ne_Sum.Value:=aSum;
  Self.Ne_Sum.Enabled:=(Mode<>fDelete);
  Self.De_Date.Enabled:=Self.Ne_Sum.Enabled;
  Result:=-1;
  if Self.ShowModal = mrOk then
    begin
      Q.QCallStoredProc('p_Or_Payment'+S.IIf(Journal = 2, '_n', ''), 'IdOrder$i;PSum$f;PDt$d;PAdd$i',
        [ID_order, S.IIf(Mode = fDelete, 0, Cth.GetControlValue(Ne_Sum)), Cth.GetControlValue(De_Date), S.IIf(Mode = fAdd, 1, 0)]
      );
      Result:=1;
      if OrNum[1] = 'Ќ'
        then Orders.FinalizeOrder(ID_Order, myOrFinalizePay);
 {     Exit;
      if Mode = fDelete
        then v:=[ID]
        else v:= [ID, ID_Order, Cth.GetControlValue(De_Date), Cth.GetControlValue(Ne_Sum)];
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
