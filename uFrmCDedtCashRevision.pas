{
������������� ������ �� ������ � ���������� ������ ������ �� �������� � ������� ����
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
//���� �������� ���� ����� ������ �������� (��� �� �� ����� ������� �������)
begin
  if Mode=fEdit then begin
    ModalResult:=mrNone;
    if MyQuestionMessage('�� �������, ��� ������ ������ ������� �� ����� �� �������� ����?') <> mrYes then exit;
    //������� �������� � �� �������� ��� ������ ��������������
    Cth.SetBtn(BtOk, mybtOk, False);
//    Cth.SetBtn(BtCancel, mybtCancel, False);
    De_Date.Value:=Date;
    Ne_Cash1.Value:=null;
    Ne_Cash2.Value:=null;
    Ne_Deposit.Value:=null;
    //2023-01-20 - ���������� ������� �������� �� ����������� �����
    SetControlsEditable([De_Date, Ne_Cash1, Ne_Cash2, Ne_Deposit], True);
    Mode:=fAdd;
  end
  else begin
    //� ������ �������������� - �������� ��� �� ��������� � �����������
    ModalResult:=mrNone;
    if (De_Date.Value = null) or (Ne_Cash1.Value = null) or (Ne_Cash2.Value = null) or (Ne_Deposit.Value = null) then
      Exit;
    if MyQuestionMessage('���������� ������� �� ����� �� �������� ����?') <> mrYes then
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
  Caption:='~������� �� �����';
  //������������� ������������ ������������ �����
  MyFormOptions := MyFormOptions + [myfoDialog, myfoModal];
  //������ ������ �����
  FOpt.DlgPanelStyle := dpsBottomRight;
  //���� ���� ����� �� ��������� �������� �� �����, ������������ ������ ��������������
  if User.Roles([], [rPC_A_Cash_Revision_Ch])
    then Mode := fEdit
    else Mode := fView;
  //�������� � ��������� ��������� � ������ ���������
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
