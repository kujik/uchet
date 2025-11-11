unit D_DelayedInProd;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_Normal, DBCtrlsEh, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.ExtCtrls,
  uData, Vcl.Mask
  ;

type
  TDlg_DelayedInProd = class(TForm_Normal)
    Img_Info: TImage;
    Bt_Ok: TBitBtn;
    Bt_Cancel: TBitBtn;
    cmb_Reason: TDBComboBoxEh;
    mem_Comment: TDBMemoEh;
    procedure Bt_OkClick(Sender: TObject);
  private
    { Private declarations }
    InLoad: Boolean;
    ID_Order: Integer;
  public
    { Public declarations }
    function ShowDialog(aMode: TDialogType; aID_Order: Integer): Boolean;
  end;

var
  Dlg_DelayedInProd: TDlg_DelayedInProd;

implementation

{$R *.dfm}

uses


  uForms,
  uDBOra,
  uString,
  uMessages
  ;


procedure TDlg_DelayedInProd.Bt_OkClick(Sender: TObject);
var
  NewID: Integer;
  b: Integer;
begin
//  ModalResult:=mrnone;
//  if (Mode = fView) then begin Close; Exit; end;
//  if edt_name.Text = '' then Exit;
//  if cmb_Group.Text = '' then Exit;
  b:= Q.QIUD(Q.QFModeToIUD(Mode), 'delayed_prod_reasons', 'id', 'id$i;id_reason$i;comm$s',
    [ID_Order, S.NullIfEmpty(Cth.GetControlValue(cmb_Reason)), Cth.GetControlValue(mem_Comment)]
  );
  if b = -1 then Exit;
  ModalResult:=mrOk;
end;

function TDlg_DelayedInProd.ShowDialog(aMode: TDialogType; aID_Order: Integer): Boolean;
var
  va: TVarDynArray;
  va2: TVarDynArray2;
begin
  InLoad:=True;
  if Mode <> fView then Mode:=fEdit;
  ModalResult:=mrnone;
  ID_Order:= aID_Order;
  Cth.SetDialogForm(Self, Mode, 'Причина задержки');
  Cth.SetInfoIcon(Img_Info,Cth.SetInfoIconText(Self, [
   ['Выберите причину задержки заказа из списка.'#13#10+
    'Также вы можете ввести произвольный комментарий.'
   ]
  ]), 20);
 { Img_Info.Visible:=True;
  Img_Info.left:=1;
  Img_Info.top:=bt_ok.top+4;
  Img_Info.top:=240;}
  va:=Q.QSelectOneRow('select id, id_reason, comm from delayed_prod_reasons where id = :id$i', [ID_Order]);
  if va[0] = null then begin
    va:=[0, null, ''];
    if Mode <> fView then Mode:=fAdd;
  end;
  Q.QLoadToDBComboBoxEh('select name, id from ref_delayed_prod_reasons where active = 1 or id = :id$i', [va[1]], cmb_Reason, cntComboLK0);
  Cth.SetControlValue(cmb_Reason, va[1]);
  Cth.SetControlValue(mem_Comment, va[2]);
  Result:=ShowModal = mrOk;
end;


end.
