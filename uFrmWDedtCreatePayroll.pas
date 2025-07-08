unit uFrmWDedtCreatePayroll;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmBasicMdi, Vcl.ExtCtrls, Vcl.StdCtrls,
  DBCtrlsEh, Vcl.Mask, Vcl.ComCtrls, DateUtils;

type
  TFrmWDedtCreatePayroll = class(TFrmBasicMdi)
    pgcMain: TPageControl;
    ts_Divisions: TTabSheet;
    lbl1: TLabel;
    dedtDt1: TDBDateTimeEditEh;
    dedtDt2: TDBDateTimeEditEh;
    ts_Worker: TTabSheet;
    lbl2: TLabel;
    chbPrev: TDBCheckBoxEh;
    chbCurr: TDBCheckBoxEh;
    dedtW: TDBDateTimeEditEh;
    cmbWorker: TDBComboBoxEh;
  private
    Mode: Integer;
    OwnerForm: TForm;
    procedure btnOkclick(Sender: TObject); override;
    function Prepare: Boolean; override;
  public
  end;

var
  FrmWDedtCreatePayroll: TFrmWDedtCreatePayroll;

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

procedure TFrmWDedtCreatePayroll.btnOkclick(Sender: TObject);
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
  if pgcMain.ActivePageIndex = 0 then begin
    //���� ������ ������� ������ ���� ���������� �����, �� ������������, �� ��� ����������� ������ ����
    if not Cth.DteValueIsDate(dedtDt1) then Exit;
    if MyQuestionMessage('������� ���������� ���������?') <> mrYes then Exit;
    //�������� ���� ������ � ����� ������� ���� ������ �� ���� ������
    //������������ ��� �������, � �������� ������ ���� �������� ������
    dedtDt1.Value:=Turv.GetTurvBegDate(dedtDt1.Value);
    dedtDt2.Value:=Turv.GetTurvEndDate(dedtDt1.Value);
    //������� ������ ��������� ���� �� ������
    va1:=Q.QLoadToVarDynArray2(
      'select id_division, name, commit from v_turv_period where dt1 = :dt1$d',
      [dedtDt1.Value]
    );
    //������� ������ ���������� �� ��, �� ������ �������������� �� ���� ������
    va2:=Q.QLoadToVarDynArray2(
      'select id_division from v_payroll where dt1 = :dt1$d and id_worker is null',  //and id_division = :id_division$i
      [dedtDt1.Value]
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
        if Q.QIUD('i', 'payroll', 'sq_payroll', 'id;id_division;dt1;dt2', [0, Integer(va1[i,0]), dedtDt1.Value, dedtDt2.Value], False) <> -1
          then inc(cnt);  //�������� ���������� ���������
      end;
    end;
    //���������
    if st<>''
      then st:= #13#10#13#10'�� ��������� �������������� �� ������� ����:'#13#10 + st;
  end
  //��� �������� �� ���������� ���������
  else begin
    if (not Cth.DteValueIsDate(dedtW))or(not chbPrev.Checked and not chbCurr.Checked and not dedtW.Visible) then Exit;
    //�� ������� ��������� �� ���������, ���� ���� �� � ����-�� ������� �� �������������� ����� ���������
    //�� �������� ����� �������� � �������� �� ������������ ���������
    v:=Q.QSelectOneRow('select login, username from adm_locks where lock_docum = :docum$s', [myfrm_Dlg_Payroll]);
    if v[0]<> null Then begin
      MyInfoMessage('���������� ��������� (� ��� ��� � ������� ������������) ������� ��� ��������������.'#13#10'���� ��� �� ����� �������, �������� ���������� �� ������ ��������� ����������!');
      Exit;
    end;
    if MyQuestionMessage('������� ���������� ���������?') <> mrYes then Exit;
    wid:=Cth.GetControlValue(cmbWorker);
    va1:=Turv.GetWorkerStatusArr(wid);
//  Result:=QLoadToVarDynArray2('select dt, status, id_division, id_job from j_worker_status where id_worker = :id$i order by dt desc, id_division, id_job', id);
    for periods:=0 to 1 do begin
      dt1:= MinDateTime;
      //������� ���� ������ �������
      //���� ����� ���� ����, �� ������ ���� ������ � ��� ��������
      if dedtW.Visible and (periods = 0) then dt1:= Turv.GetTurvBegDate(dedtW.Value);
      //�����, ���� �������� �������, ������� � ������� ������
      if not(dedtW.Visible) and (chbPrev.Checked) and (periods = 0) then dt1:= dedtDt1.Value;
      if not(dedtW.Visible) and (chbCurr.Checked) and (periods = 1) then dt1:= Turv.GetTurvBegDate(Date);
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
//  OwnerForm.Refresh;
  Close;
end;

function TFrmWDedtCreatePayroll.Prepare: Boolean;
begin
  Result := False;
  Caption := '~�������� ��������� ���������';
  FOpt.RefreshParent := True;
  FOpt.DlgPanelStyle := dpsBottomRight;
  FOpt.StatusBarMode := stbmNone;
  FOpt.AutoAlignControls := True;
  //���� ��� ������� �� �������� �������
  dedtDt1.Value:=Turv.GetTurvBegDate(IncDay(Turv.GetTurvBegDate(Date), -1));
  dedtDt2.Value:=Turv.GetTurvEndDate(dedtDt1.Value);
  //���� ��� ��������� �� ��������� - ������� � ���������� �������
  chbPrev.Caption:='� ' + DateToStr(dedtDt1.Value) + ' �� ' + DateToStr(dedtDt2.Value);
  chbCurr.Caption:='� ' + DateToStr(Turv.GetTurvBegDate(Date)) + ' �� ' + DateToStr(Turv.GetTurvEndDate(Date));
  //������ ���� ��� ������� � ������� ������������ ��� ��������� �������� ������ ������������ � �������������� ������ (��� �������)
  dedtW.Value:=Turv.GetTurvBegDate(Date);
  dedtDt1.Enabled:=User.IsDeveloper or User.IsDataEditor;
  dedtDt2.Enabled:=dedtDt1.Enabled;
  dedtW.Visible:=dedtDt1.Enabled;
  //������ ����������
  Q.QLoadToDBComboBoxEh('select w.f || '' '' || w.i || ''  '' || w.o as name, id from ref_workers w order by name', [], cmbWorker, cntComboLK);
  Result := True;
end;


end.
