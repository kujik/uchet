{
���� ������ ��� �� ������.
����� ����� ������ ��� ��������� �� � � �
�������� ���� ��������� ��� � ��� ����� (� ������), ���� ����������� ������������� �������������
������ ������������ � ������� orders, ���� ��� ���� ������
��� �������� ���� ���� �������� ��� ��� ���� ������� � ������� ���� � ����� ���������.
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
    dedt_Upd_Reg: TDBDateTimeEditEh;
    dedt_Upd: TDBDateTimeEditEh;
    edt_Upd: TDBEditEh;
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
  if (va2[0][1] <> null)and(dedt_Upd.Value = null)and(Trim(edt_Upd.Text) = '') then begin
    if (MyQuestionMessage('������� ������ ���?') = mrYes) then begin
    end
    else Exit;
  end
  else if (dedt_Upd.Value = null)or(Trim(edt_Upd.Text) = '')or(dedt_Upd.Value > Date)or
          (dedt_Upd.Value < Turv.GetDaysFromCalendar_Next(va2[0][6], -5))
    then begin
      MyWarningMessage('������ �����������!');
      Exit;
    end;
  Q.QExecSql(
    'update orders set dt_upd_reg = :dt_upd_reg$d, dt_upd = :dt_upd$d, upd = :upd$s where id = :id$i',
    [S.IIf(dedt_Upd.Value = null, null, dedt_Upd_Reg.Value), dedt_Upd.Value, Trim(edt_Upd.Text), ID]
  );
  ModalResult:=mrOk;
end;

procedure TDlg_Order_UPD.FormShow(Sender: TObject);
begin
  inherited;
  //������-�� �������� ����� ��� ������ ������ �����, ��� ������
  Img_Info.Top:=Bt_Ok.top;
end;

function TDlg_Order_UPD.ShowDialog(aID: Variant): Boolean;
begin
  Result:=False;
  ID:= aID;
  va2:=Q.QLoadToVarDynArray2('select id, dt_upd_reg, dt_upd, upd, prefix, dt_end, dt_beg, id_type from orders where id = :id$i', [ID]);
  //������� ��� ������� ��� ������� �� ���� ��������, ���� ����� �� ������, ���� ����������
  if (Length(va2) = 0)or not A.InArray(va2[0][4], ['�','�','�'])or(va2[0][7] = 2) then Exit;
  //���� ����� ������ ��� ��� ���� - ������� �� ��������
  Mode:=S.IIf((va2[0][5] = null)and(User.Role(rOr_D_Order_EnteringUPD)), fEdit, fView);
  //!!!��������
  Mode:=S.IIf((User.Role(rOr_D_Order_EnteringUPD)), fEdit, fView);
  Cth.SetDialogForm(Self, Mode, '���');
  Cth.SetControlValue(dedt_Upd_Reg, S.IIf(va2[0][1] = null, Date, va2[0][1]));
  Cth.SetControlValue(dedt_Upd, va2[0][2]);
  Cth.SetControlValue(edt_Upd, va2[0][3]);
  dedt_Upd_Reg.Enabled:=False;
  dedt_Upd.Enabled:= Mode <> fView;
  edt_Upd.Enabled:= Mode <> fView;
  edt_Upd.MaxLength:=20;
  Cth.SetInfoIcon(Img_Info,Cth.SetInfoIconText(Self, [
   ['������� ������ ���.'#13#10+
    '���� ��������� � ��� ����� �����������. ���� ����������� �������� �������������.'#13#10 ,
    Mode<>fView],
   ['��� �������� ������ �������� ���� "���� ���" � "� ���"' ,
   (Mode<>fView)and(va2[0][1] <> null)]
  ]), 20);
  Img_Info.Top:=Bt_Ok.top;
  Result:=ShowModal = mrOk;
end;


end.
