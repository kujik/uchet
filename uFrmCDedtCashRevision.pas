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
    dedtDate: TDBDateTimeEditEh;
    nedtCash1: TDBNumberEditEh;
    nedtCash2: TDBNumberEditEh;
    nedtDeposit: TDBNumberEditEh;
    procedure FormShow(Sender: TObject);
  private
    function  Prepare: Boolean; override;
    procedure btnOkClick(Sender: TObject); override;
    procedure Save;
  public
  end;

var
  FrmCDedtCashRevision: TFrmCDedtCashRevision;

implementation

{$R *.dfm}

procedure TFrmCDedtCashRevision.btnOkClick(Sender: TObject);
//���� �������� ���� ����� ������ �������� (��� �� �� ����� ������� �������)
begin
  if Mode=fEdit then begin
    ModalResult:=mrNone;
    if MyQuestionMessage('�� �������, ��� ������ ������ ������� �� ����� �� �������� ����?') <> mrYes then exit;
    //������� �������� � �� �������� ��� ������ ��������������
    Cth.SetBtn(btnOk, mybtOk, False);
//    Cth.SetBtn(btnCancel, mybtCancel, False);
    dedtDate.Value:=Date;
    nedtCash1.Value:=null;
    nedtCash2.Value:=null;
    nedtDeposit.Value:=null;
    //2023-01-20 - ���������� ������� �������� �� ����������� �����
    SetControlsEditable([dedtDate, nedtCash1, nedtCash2, nedtDeposit], True);
    Mode:=fAdd;
  end
  else begin
    //� ������ �������������� - �������� ��� �� ��������� � �����������
    ModalResult:=mrNone;
    if (dedtDate.Value = null) or (nedtCash1.Value = null) or (nedtCash2.Value = null) or (nedtDeposit.Value = null) then
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
    Cth.SetBtn(btnOk, mybtEdit, False);
  SetControlsEditable([dedtDate, nedtCash1, nedtCash2, nedtDeposit], False);
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
  dedtDate.Value:=Q.QSelectOneRow('select dt from sn_cash_revision_dt', [])[0];
  nedtCash1.Value:=Q.QSelectOneRow('select sum from sn_cash_revision_sum where id = -1', [])[0];
  nedtCash2.Value:=Q.QSelectOneRow('select sum from sn_cash_revision_sum where id = -2', [])[0];
  nedtDeposit.Value:=Q.QSelectOneRow('select sum from sn_cash_revision_sum where id = -9', [])[0];
  Result := True;
end;

procedure TFrmCDedtCashRevision.Save;
begin
  Q.QBeginTrans(True);
  Q.QExecSql('update sn_cash_revision_dt set dt = :dt', [Cth.GetControlValue(dedtDate)]);
  Q.QExecSql('update sn_cash_revision_sum set sum = :sum where id=-1', [Cth.GetControlValue(nedtCash1)]);
  Q.QExecSql('update sn_cash_revision_sum set sum = :sum where id=-2', [Cth.GetControlValue(nedtCash2)]);
  Q.QExecSql('update sn_cash_revision_sum set sum = :sum where id=-9', [Cth.GetControlValue(nedtDeposit)]);
  Q.QCommitOrRollback;
end;




end.
