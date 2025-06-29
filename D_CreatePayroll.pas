{
1:
�������� ����� ���� ���������� ���������� �� ���� ������ ����
���������� �� ������� ���������� ���������� (��������� ����� ����)
������� ������ ������ ��� ��� �������������, ��� ������� � ������ ������� ������� ����
� ������� ������ ������ ������ �� ������� ������ � ������ �� �������� ����,
��� ���������� �� ����� ������ � ��� ����������

2:
������� ��������� �� ����������� ���������
������� ����� ��������� �� ���� ��������������, � ������� �������� �������� �� ������ ������,
� �� ������ �� ���� �������� - ������� � ���������
��� ���������� �� ����, �� ����� ������.
�� ���������� �� �������������� �� ������ ������ ������ � ���� ���������� ����� �������

��������� ������ ������ � ������� payroll, ��� ����������

��� �������� �� ��������� �������, ���� ���� �� �� ��������� ��-�� ������������

������� ���� ������� �������

}
unit D_CreatePayroll;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_Normal, Vcl.StdCtrls, Vcl.Mask,
  DBCtrlsEh, Vcl.Buttons, DateUtils,
  Vcl.ComCtrls
  ;

type
  TDlg_CreatePayroll = class(TForm_Normal)
    Bt_OK: TBitBtn;
    Bt_Cancel: TBitBtn;
    PageControl1: TPageControl;
    ts_Divisions: TTabSheet;
    ts_Worker: TTabSheet;
    lbl1: TLabel;
    dedt_Dt1: TDBDateTimeEditEh;
    dedt_Dt2: TDBDateTimeEditEh;
    lbl2: TLabel;
    chb_Prev: TDBCheckBoxEh;
    chb_Curr: TDBCheckBoxEh;
    dedt_W: TDBDateTimeEditEh;
    cmb_Worker: TDBComboBoxEh;
    procedure Bt_OKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Mode: Integer;
    OwnerForm: TForm;
    //mode = 1  - �������� ���������� �� ��������� ������ �� ��������������
    function ShowDialog(aOwner: TForm; aMode: Integer): Integer;
  end;

var
  Dlg_CreatePayroll: TDlg_CreatePayroll;

implementation

{$R *.dfm}

uses
  uTurv,
  uMessages,
  uDBOra,
  uData,
  uString,
  uForms
  ;

procedure TDlg_CreatePayroll.Bt_OKClick(Sender: TObject);
var
  dt1, dt2: TDateTime;
  i, j, periods: Integer;
  v, v1, v2: Variant;
  va1, va2: TVarDynArray2;
  cnt: Integer;
  b, b1: Boolean;
  st: string;
  wid: Integer;
  dep: TVarDynArray;
begin
  inherited;
  cnt:=0;
  st:= '';
  //��� �������� �� ���� ��������������
  if PageControl1.ActivePageIndex = 0 then begin
    //���� ������ ������� ������ ���� ���������� �����, �� ������������, �� ��� ����������� ������ ����
    if not Cth.DteValueIsDate(dedt_Dt1) then Exit;
    if MyQuestionMessage('������� ���������� ���������?') <> mrYes then Exit;
    //�������� ���� ������ � ����� ������� ���� ������ �� ���� ������
    //������������ ��� �������, � �������� ������ ���� �������� ������
    dedt_Dt1.Value:=Turv.GetTurvBegDate(dedt_Dt1.Value);
    dedt_Dt2.Value:=Turv.GetTurvEndDate(dedt_Dt1.Value);
    //������� ������ ��������� ���� �� ������
    va1:=Q.QLoadToVarDynArray2(
      'select id_division, name, commit from v_turv_period where dt1 = :dt1$d',
      [dedt_Dt1.Value]
    );
    //������� ������ ���������� �� ��, �� ������ �������������� �� ���� ������
    va2:=Q.QLoadToVarDynArray2(
      'select id_division from v_payroll where dt1 = :dt1$d and id_worker is null',  //and id_division = :id_division$i
      [dedt_Dt1.Value]
    );
    for i:=0 to High(va1) do begin
      b:=True;
      for j:=0 to High(va2) do
        if va1[i, 0] = va2[j, 0] then
          begin b:=False; Break; end;
      //���� �� ����� � ���������, �� �������� ������ �� ����
      if b then
        if va1[i,2] <> 1 then begin
          if not User.IsDeveloper then b:=False;                   //�� ������� ��� ����������� ����
          st:=st +  va1[i,1] + #13#10;  //� ��������
        end;
      if b then begin
  //      if QIUD('i', 'payroll', 'sq_payroll', 'id;id_division$i;dt1$d;dt2$d', [0, va1[i,0], dedt_Dt1.Value, dedt_Dt2.Value], False) <> -1
        //������� ���������� ���������, ���� ��� �� �� ����� ����� ���������� ��� ����� ���� �������, �� ����� ������ ����������� �������, ����� �� �� �������
        if Q.QIUD('i', 'payroll', 'sq_payroll', 'id;id_division;dt1;dt2', [0, Integer(va1[i,0]), dedt_Dt1.Value, dedt_Dt2.Value], False) <> -1
          then inc(cnt);  //�������� ���������� ���������
      end;
    end;
    //���������
    if st<>''
      then st:= #13#10#13#10'�� ��������� �������������� �� ������� ����:'#13#10 + st;
  end
  //��� �������� �� ���������� ���������
  else begin
    if (not Cth.DteValueIsDate(dedt_W))or(not chb_Prev.Checked and not chb_Curr.Checked and not dedt_W.Visible) then Exit;
    //�� ������� ��������� �� ���������, ���� ���� �� � ����-�� ������� �� �������������� ����� ���������
    //�� �������� ����� �������� � �������� �� ������������ ���������
    v:=Q.QSelectOneRow('select login, username from adm_locks where lock_docum = :docum$s', [myfrm_Dlg_Payroll]);
    if v[0]<> null Then begin
      MyInfoMessage('���������� ��������� (� ��� ��� � ������� ������������) ������� ��� ��������������.'#13#10'���� ��� �� ����� �������, �������� ���������� �� ������ ��������� ����������!');
      Exit;
    end;
    if MyQuestionMessage('������� ���������� ���������?') <> mrYes then Exit;
    wid:=Cth.GetControlValue(cmb_Worker);
    va1:=Turv.GetWorkerStatusArr(wid);
//  Result:=QLoadToVarDynArray2('select dt, status, id_division, id_job from j_worker_status where id_worker = :id$i order by dt desc, id_division, id_job', id);
    for periods:=0 to 1 do begin
      dt1:= MinDateTime;
      //������� ���� ������ �������
      //���� ����� ���� ����, �� ������ ���� ������ � ��� ��������
      if dedt_W.Visible and (periods = 0) then dt1:= Turv.GetTurvBegDate(dedt_W.Value);
      //�����, ���� �������� �������, ������� � ������� ������
      if not(dedt_W.Visible) and (chb_Prev.Checked) and (periods = 0) then dt1:= dedt_Dt1.Value;
      if not(dedt_W.Visible) and (chb_Curr.Checked) and (periods = 1) then dt1:= Turv.GetTurvBegDate(Date);
      if dt1 = MinDateTime then continue;
      //����� �������
      dt2:=Turv.GetTurvEndDate(dt1);
      //������ ���������� �������������
      dep:=[];
      //������ �� ������� �������� ���������
      //� �������� ��������, �� ��� ����� ���� ������ �� ������ ���, � ������ ������������ �� ����� � ����� ������
      for i:=High(va1) downto 0 do begin
        //����� �������, �������
        if va1[i][0] > dt2 then Break;
        //�� ������ ��� � ������ ���� - �������� ��������� �������������
        if (va1[i][0] <= dt1) and (Integer(va1[i][1]) in [1,2]) then dep:=[va1[i][2]];
        //����� ������ � �� ����� ������� - ��������� ������ ������������� ���� ������/���������
        if (va1[i][0] > dt1) and (Integer(va1[i][1]) in [1,2]) then dep:=dep + [va1[i][2]];
      end;
      for i:=0 to High(dep) do begin
        //������ ������ � ����� ���������� �� ���������� (������ �� ���������� �� �������, � �� �� ����������!)
        Q.QExecSql('delete from payroll_item i where '+
          'id_division = :id_division$i and id_worker = :id_worker$i and dt = :dt$d ' +
          'and (select id_worker from payroll where i.id_payroll = id) is null'
          ,[dep[i], wid, dt1]);
        //�������� ��������� �� ��������� � ������ ��������� ������������� �� ������ ������
        if Q.QIUD('i', 'payroll', 'sq_payroll', 'id;id_division$i;dt1;dt2;id_worker', [0, dep[i], dt1, dt2, wid], False) <> -1
          then inc(cnt);  //�������� ���������� ���������
      end;
    end;
  end;
  //���������
  if cnt = 0
    then st:= '�� ���� ��������� �� �������!' + st
    else st:= '������' + S.GetEnding(cnt, '�', '�', '�') + ' ' + IntToStr(cnt) + ' ��������' + S.GetEnding(cnt, '�','�','��') + '.' + st;
  MyInfoMessage(st);
  //������� ����� �������
  OwnerForm.Refresh;
  Close;
end;

function TDlg_CreatePayroll.ShowDialog(aOwner: TForm; aMode: Integer): Integer;
begin
  Mode:=AMode;
  OwnerForm:=aOwner;
  Cth.SetBtn(Bt_Ok, mybtOk, False);
  Cth.SetBtn(Bt_Cancel, mybtCancel, False);
  //���� ��� ������� �� �������� �������
  dedt_Dt1.Value:=Turv.GetTurvBegDate(IncDay(Turv.GetTurvBegDate(Date), -1));
  dedt_Dt2.Value:=Turv.GetTurvEndDate(dedt_Dt1.Value);
  //���� ��� ��������� �� ��������� - ������� � ���������� �������
//  chb_Prev.Caption:='� ' + DateToStr(Turv.GetTurvBegDate(IncDay(Turv.GetTurvBegDate(dedt_Dt1.Value), -1)))+ ' �� ' + DateToStr(IncDay(Turv.GetTurvBegDate(dedt_Dt2.Value), -1));
  chb_Prev.Caption:='� ' + DateToStr(dedt_Dt1.Value) + ' �� ' + DateToStr(dedt_Dt2.Value);
  chb_Curr.Caption:='� ' + DateToStr(Turv.GetTurvBegDate(Date)) + ' �� ' + DateToStr(Turv.GetTurvEndDate(Date));
  //������ ���� ��� ������� � ������� ������������ ��� ��������� �������� ������ ������������ � �������������� ������ (��� �������)
  dedt_W.Value:=Turv.GetTurvBegDate(Date);
  dedt_Dt1.Enabled:=User.IsDeveloper or User.IsDataEditor;
  dedt_Dt2.Enabled:=dedt_Dt1.Enabled;
  dedt_W.Visible:=dedt_Dt1.Enabled;
  //������ ����������
  Q.QLoadToDBComboBoxEh('select w.f || '' '' || w.i || ''  '' || w.o as name, id from ref_workers w order by name', [], cmb_Worker, cntComboLK);


  {  if Mode = 1 then begin
//    lbl1.Caption:='������� ���������� ��������� �� ��������������.';
    //���� �� �������� ������� ����
    dedt_Dt1.Value:=Turv.GetTurvBegDate(IncDay(Turv.GetTurvBegDate(Date), -1));
    dedt_Dt2.Value:=Turv.GetTurvEndDate(dedt_Dt1.Value);
    ShowModal;
  end;}
  ShowModal;
end;


end.
