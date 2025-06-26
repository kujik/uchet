unit D_WorkerStatus;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, Mask, uData, uForms, uDBOra, uString, uMessages, F_MDIDlg1,
  DateUtils
  ;

type
  TDlg_WorkerStatus = class(TForm_MDIDlg1)
    Cb_Worker: TDBComboBoxEh;
    De_Date: TDBDateTimeEditEh;
    Cb_Status: TDBComboBoxEh;
    Cb_Division: TDBComboBoxEh;
    Cb_Job: TDBComboBoxEh;
    procedure Cb_StatusChange(Sender: TObject);
  private
    { Private declarations }
    a: TVarDynArray2;
    dts : array [1..4] of TDateTime;
    dt1, dt2, dt3, dt4: TDateTime;
    dep: TVarDynArray2;
    function Load: Boolean; override;
    function Save: Boolean; override;
    function VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean; override;
    function AfterPrepare: Boolean; override;
    procedure BtOKClick; override;
    function  VerifyWorker: Boolean;
    procedure CreateDep(dt: TDateTime; id: Integer);
    function  VerifyTurvPeriods: string;
    function  VerifyTurvDays(id_worker: Integer; dt: TDateTime): string;
    function  DeleteTurvDays(id_worker: Integer; dt: TDateTime): string;
  public
    { Public declarations }
  end;

var
  Dlg_WorkerStatus: TDlg_WorkerStatus;

implementation

uses
  uTurv,
  uWindows,
  D_CandidatesFromWorkerStatus
  ;

{$R *.dfm}

function TDlg_WorkerStatus.VerifyWorker: Boolean;
//��� ���������� ������
//������ ��� ����� �� ������ ��� ��������� ������ ���� ������ ������
//������ ��� ����� �������� ��� ������������ �� ����� ���� ������
//���� �� ����� ���� ������� �� ������ ��� ���� � ���������� ������
//�� ����� ��������� � ���������� ������� ������������ ������������� � ���������
var
  st, msg, msg2: string;
  d: TVarDynArray2;
  idw: Integer;
  v: Variant;
begin
  Result:=False;
  if not Ok then Exit;
  st:='';
  idw:=Cth.GetControlValue(Cb_Worker);
  a:=Turv.GetWorkerStatusArr(idw);
  d:=[];
  if Mode = fAdd then begin
    //���������� ������
    if (Length(a) = 0) and (Cb_Status.Value <> '1') then st:='��� ����� ��������� �������� ������ ������ "������"';
    if (st = '') and (high(a) >= 0) then begin
      //�� ��������� ���� ��� ������ � ������� ��������
      if a[0][0] >= De_Date.Value
        then st:='�������� ������ ����� ��������� ����� ������ �� ���� ������� ' + DateToStr(a[0][0])
        else if (a[0][1] = 3) and (Cb_Status.Value <> '1')
          then st:='��� ����� ��������� �������� ������ ������ "������"'
          else if ((a[0][1] = 1) or (a[0][1] = 2)) and (Cb_Status.Value = '1') then st:='��� ����� ��������� �� �������� ������ "������"'
            else if (Cb_Status.Value <> '3') and (Trunc(S.NNum(a[0][2]))= Cth.GetControlValue(Cb_Division)) and (Trunc(S.NNum(a[0][3])) = Cth.GetControlValue(Cb_Job))
              then st:='�������� ��� �������� � ���� ������������� � � ���� �� ���������!';
    end;
    if st = '' then begin
      if (Abs(DaysBetween(Cth.GetControlValue(De_Date), Date)) > 31)and(MyQuestionMessage('���� ��������� ������� ������ ���������� �� �������! ��� ����� ����������?') <> mrYes) then Exit;
      Result:=Turv.ChangeWorkerInTURV(
        Cth.GetControlValue(Cb_Worker), Cth.GetControlValue(Cb_Division), Cth.GetControlValue(Cb_Job), Cth.GetControlValue(De_Date), ID, Cth.GetControlValue(Cb_Status)
      );
      if not Result then Exit;
    end
    else begin
      //���� ���� ������ ������ �������� ������
      Result:= False;
      MyWarningMessage(st);
    end;
    //Exit;
 {   if st = '' then begin
      //���� ��������� ���������, ������� ������������� �������
      //��� ������ � �������� ��� ����� �� ����������� ������, ��� �������� � �������� ����� �� ��������� ������ ����� �����������, ���� ����� �� �����������
      if (Cb_Status.Value = '1')or(Cb_Status.Value = '2')
        then CreateDep(De_Date.Value, Cth.GetControlValue(Cb_Division));
      if (Length(a) > 0)and((Cb_Status.Value = '2')or(Cb_Status.Value = '3'))
        then CreateDep(De_Date.Value, Integer(a[0][2]));
    end;}
  end
  else if Mode = fDelete then begin
    //�������� ������
    //�������� �� ������ ������ ��������� �� ������, ����� �� ����� ������ ������ �������� � ���� ������� ��� ����
    v:=Q.QSelectOneRow('select nvl(max(id), -1) from j_worker_status where id_worker = :id$i', [idw])[0];
    if not((v = -1)or(v = id))
      then st:='��� ������ �� �������� ��������� ��� ������� ���������, ������� �� ����� ���� �������!';
    if st = '' then begin
      //v:=QSelectOneRow('select nvl(max(id), -1) from j_worker_status where id_worker = :id$i', idw)[0];
      if (Abs(DaysBetween(Cth.GetControlValue(De_Date), Date)) > 31)and(MyQuestionMessage('���� ��������� ������� ������ ���������� �� �������! ��� ����� ����������?') <> mrYes) then Exit;
      v:=Q.QSelectOneRow(
        'select id, id_worker, id_division, id_job, status, dt from v_j_worker_status '+
        'where id_worker = :idw$i and id < :id and rownum = 1',
        [Cth.GetControlValue(Cb_Worker), ID]
      );
      Result:=Turv.ChangeWorkerInTURV(
        Cth.GetControlValue(Cb_Worker), v[2], v[3], Cth.GetControlValue(De_Date), ID, -1
      );
      if not Result then Exit;
    end
    else begin
      //���� ���� ������ ������ �������� ������
      Result:= False;
      MyWarningMessage(st);
    end;
{      else if De_Date.Value < dts[1]
        then st:='������ ������� ����� ������ ������!';
    if st = '' then begin
      //������������� �������, ��� �������� ������ � ������ � �������� ��� ����� �� ������, � ��� ��������� � �������� ����������� �����, ��� � ���� � ��������� ���������
      if (Cb_Status.Value = '1')or(Cb_Status.Value = '2')
        then CreateDep(De_Date.Value, Cth.GetControlValue(Cb_Division));
      if (Length(a) > 1)and((Cb_Status.Value = '2')or(Cb_Status.Value = '3'))
        then CreateDep(De_Date.Value, Integer(a[1][2]));
    end;}
  end;
//exit;
{  if st = '' then begin

    //������ �� ���� ������ ��� �������������, ������� ���� ����� ����������� ������, � ������� ������ ����� ����,
    //�������� �� �������� ������� � �������� �� ������ ����
    //������ �� ���� ������ ��� ������ �������������, ������� � ����, �������� �� �������� ������� � �������� �� ������ ����
    Msg:=VerifyTurvPeriods;
    Msg2:=VerifyTurvDays(idw, De_Date.Value);
    //���� � ������� ����������� ����, ��� ��������������� ��������������
    if msg<>'' then begin
      MyWarningMessage(msg + #13#10#13#10 + msg2);
      Result := False;
      Exit;
    end;
    //���� ���� ��� �� ��������, �� ������� ���������, ���� �� Yes �� ������ �� ������, ���� �� ���������
    if (msg2<>'') and (MyQuestionMessage(msg2 + ' ����������?') <> mrYes) then begin
      Result := False;
      Exit;
    end;
    //������� turv_day ��� ������������ ������ ���� ���������
    msg:=DeleteTurvDays(idw, De_Date.Value);
    if msg<>'' then begin
      //��������� ���� �� ������� ��� ���� ����� ���������� �� ��� ����, � ���� ������ ������� �� �����, � ���� �� ���������
      MyWarningMessage(msg);
      Result := False;
    end;
    //������ ���, ��� ������ ������� ���� � ��������� ���-������ �� ���������� ���������
    Result:=True;
//    result := False; exit;

    Result:= True;
  end
  else begin
    //���� ���� ������ ������ �������� ������
    Result:= False;
    MyWarningMessage(st);
  end;}
end;

//������ ���������, �� ����� �� ������������� �������� ����������� ����������, � ����� �������
//���� ��������� �� ������, �� ���������� �������� ������
function TDlg_WorkerStatus.VerifyTurvPeriods: string;
var
  i, j: Integer;
  id, st: string;
  dt01, dt02: TDatetime;
  b: Boolean;
  v, v1: Variant;
begin
  Result:='';
  for i:= 0 to High(Dep) do begin
    id:=VarToStr(Dep[i][0]) + ' ' + FormatDateTime('yyyymmdd', TDateTime(Dep[i][1])) + ' ' + FormatDateTime('yyyymmdd', TDateTime(Dep[i][2]));
    v:=Q.QSelectOneRow('select login, username from adm_locks where lock_docum = :docum$s and lock_docum_add = :documadd$s', [myfrm_Dlg_Turv, id]);
    if v[0]<> null Then begin
      v1:=Q.QSelectOneRow('select name from ref_divisions where id = :id$i', [Dep[i][0]]);
      Result:=Result + #13#10 + '���� �� ������ ' + VarToStr(v1[0]) +
      ' �� ������ � ' + DateToStr(TDateTime(Dep[i][1])) + ' �� ' + DateToStr(TDateTime(Dep[i][2])) +
      ' ������������ ' + VarToStr(v[1]) + '.';
    end;
    v:=Q.QSelectOneRow('select id_division, name from v_turv_period where id = :id$s and commit = :commit$i', [id, 1]);
    if v[0]<> null Then
      Result:=Result + #13#10 + '���� �� ������ ' + VarToStr(v[1]) +
      ' �� ������ � ' + DateToStr(TDateTime(Dep[i][1])) + ' �� ' + DateToStr(TDateTime(Dep[i][2])) +
      ' �������� � �� ����� ���� �������!'
  end;
end;

//������ ���������, ������� ���� �� ���, ��� ������ ���� �������, ����� �������� ��������
//���, � ������� ����������� �� ������� �����, � ���� ����, �� ����������� � ������
function TDlg_WorkerStatus.VerifyTurvDays(id_worker: Integer; dt: TDateTime): string;
var
  v: Variant;
begin
  Result:='';
  v:=Q.QSelectOneRow(
    'select count(*) from turv_day where (worktime1 is not null or worktime2 is not null or worktime3 is not null) and id_worker = :id_worker$i and dt >= :dt$d',
     [id_worker, dt]);
  if v[0] > 0 then
    Result:='� ���� ���� ' + VarToStr(v[0]) + ' ����, �� ������� ����������� ����� ������, � ������� ����� �������.';
end;

//������ ��� ������� ����� ��������� ������ ����
function TDlg_WorkerStatus.DeleteTurvDays(id_worker: Integer; dt: TDateTime): string;
var
  v: Variant;
  b: array of Boolean;
  b1: Boolean;
  i: Integer;
  id: string;
begin
  Result:='';
  SetLength(b, Length(dep));
  b1:=True;
  //���������� ������������� ��� ������������ �����
  for i:= 0 to High(Dep) do begin
    id:=VarToStr(Dep[i][0]) + ' ' + FormatDateTime('yyyymmdd', TDateTime(Dep[i][1])) + ' ' + FormatDateTime('yyyymmdd', TDateTime(Dep[i][2]));
    b[i]:=Q.DBLock(True, myfrm_Dlg_Turv, id, '')[0];
    b1:=b1 and b[i];
  end;
  if b1 then begin
    Q.QExecSql('delete from turv_day where id_worker = :id_worker$i and dt >= :dt$d', [id_worker, dt], False);
  end
  else Result:='�� ������� ������������� ������������� ���� ��� ���������� ���������!';
  //������������, �� ��� ���� �������������
  for i:= 0 to High(Dep) do begin
    id:=VarToStr(Dep[i][0]) + ' ' + FormatDateTime('yyyymmdd', TDateTime(Dep[i][1])) + ' ' + FormatDateTime('yyyymmdd', TDateTime(Dep[i][2]));
    if b[i] then Q.DBLock(False, myfrm_Dlg_Turv, id, '');
  end;
end;



//������� ������������� ����
//� ������� [[��� ��1� ��2],[...]]
//��� ��� ������ ���������� ��� ������������ ����� �������, ��
//����� ����, � ������� �������� ���� � ��� ����������� �� ���������� ����
procedure TDlg_WorkerStatus.CreateDep(dt: TDateTime; id: Integer);
var
  i, j, id0: Integer;
  dt01, dt02: TDatetime;
  b: Boolean;
begin
  for i:= 1 to High(dts)-1 do begin
    dt01:=dts[i+1];
    //�������� � ������, ���� ������ ���������� ����� ����
    if dt01 > dt then begin
      b:=True;
      for j:=0 to High(dep) do
        if (dep[j][0] = id)and(dep[j][1]=dts[i])
          then begin b:=False; Break; end;
      if b then begin
        SetLength(dep, Length(dep)+1);
        dep[High(dep)]:=[id, dts[i], IncDay(dts[i+1], -1)];
      end;
    end;
  end;
end;


procedure TDlg_WorkerStatus.BtOKClick;
begin
  if (Mode = fView) then begin Close; Exit; end;
  Verify(nil);
  if not Bt_Ok.Enabled then Exit;
  if not VerifyWorker then Exit;
//  exit;
//  if not Save then Exit;
  RefreshParentForm;
  Close;
end;

function TDlg_WorkerStatus.VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean;
begin
  Result:=True;
//  if (TControl(Sender).Name = 'Cb_Division')
  Cth.SetErrorMarker(Cb_Division, not((Cb_Division.Value<>'') or (Cb_Status.Value = '3')));
  Cth.SetErrorMarker(Cb_Job, not((Cb_Job.Value<>'') or (Cb_Status.Value = '3')));
  //������ ������ ���� ������ ������ ����������� ���� � ����� ��������� ����������
//  Cth.SetErrorMarker(De_Date, not(Cth.DteValueIsDate(De_Date)) or (De_Date.Value < dts[1]) or (De_Date.Value >= dts[High(dts)]));
end;


procedure TDlg_WorkerStatus.Cb_StatusChange(Sender: TObject);
begin
  if Cb_Status.Value = 3 then begin
    Cb_Division.Value:='';
    Cb_Job.Value:='';
    Cb_Division.Enabled:=False;
    Cb_Job.Enabled:=False;
  end
  else
  begin
    Cb_Division.Enabled:=True;
    Cb_Job.Enabled:=True;
  end;
  inherited;
  ControlOnChange(Sender);
end;

function TDlg_WorkerStatus.Load: Boolean;
var
  v,v1: Variant;
  st: string;
begin
  Result:=False;
  Q.QLoadToDBComboBoxEh('select w.f || '' '' || w.i || '' '' || w.o as name, id from ref_workers w order by name', [], Cb_Worker, cntComboLK);
  Q.QLoadToDBComboBoxEh('select name, id from ref_divisions order by name', [], Cb_Division, cntComboLK);
  Q.QLoadToDBComboBoxEh('select name, id from ref_jobs order by name', [], Cb_Job, cntComboLK);
  Cth.AddToComboBoxEh(Cb_Status, [['������', '1'], ['���������', '2'], ['������', '3']]);
  if Mode = fAdd
    then v:=VarArrayOf([-1,'','','','',''])
    else v:=Q.QSelectOneRow('select id, id_worker, id_division, id_job, status, dt from v_j_worker_status where id = :id', [ID]);
  if v[0] = null then begin MsgRecordIsDeleted;  Exit; end;
  Cth.SetControlValue(Cb_Worker, v[1]);
  Cth.SetControlValue(Cb_Division, v[2]);
  Cth.SetControlValue(Cb_Job, v[3]);
  Cth.SetControlValue(Cb_Status, v[4]);
  Cth.SetControlValue(De_Date, v[5]);
  if Mode = fDelete then begin
    v1:=Q.QSelectOneRow('select nvl(max(id), -1) from j_worker_status where id_worker = :id$i', [v[1]])[0];
    if not((v1 = -1)or(v1 = id)) then begin
      MyWarningMessage('��� ������ �� �������� ��������� ��� ������� ���������, ������� �� ����� ���� �������!');
      Exit;
    end;
  end;
  //��������� �������� ��������� - ��� �����������
  Cth.SetControlsVerification(
    [Cb_Worker, Cb_Division, Cb_Job, Cb_Status, De_Date],
    ['1:400', '1:400', '1:400', '1:400', '1']
  );
  Cth.DlgSetControlsEnabled(Self, Mode, [], []);
  Cb_Division.Enabled:=(Cb_Status.Value <> '3') and (Mode = fAdd);
  Cb_Job.Enabled:=Cb_Division.Enabled;
  //���� ������������� ���� (������ ��������)
  dts[2]:=TURV.GetTurvBegDate(Date);
  dts[1]:=TURV.GetTurvBegDate(IncDay(dts[2], -1));
  dts[3]:=TURV.GetTurvBegDate(IncDay(dts[2], 17));
  dts[4]:=TURV.GetTurvBegDate(IncDay(dts[3], 17));
  //���� ������� ������ ����������, �� ������� ����
  //(���� ����������� �������� �����, �������� ��� � ����������, �� �� ��������� ������)
  if VarIsArray(AddParam) then begin
    Cb_Worker.Text:=AddParam[0];
    if AddParam[1] <> '' then Cb_Division.Text:=AddParam[1];
    if AddParam[2] <> '' then Cb_Job.Text:=AddParam[2];
    if AddParam[3] <> null then  De_Date.Value:=AddParam[3];
  end;
  Result:=True;
end;

function TDlg_WorkerStatus.AfterPrepare: Boolean;
begin
  Cb_Status.OnChange:=Cb_StatusChange;
  Result:=True;
end;

function TDlg_WorkerStatus.Save: Boolean;
var
  v: TVarDynArray;
  i, j: Integer;
begin
  Result:=False;
  Exit;
  if Mode = fDelete
    then begin
      v:=[ID];
      Result:= (Q.QIUD('d', 'j_worker_status', 'sq_j_worker_status', 'id;name;office;id_head;editusers', v) >= 0);
    end
    else begin
      v:= [ID, Cth.GetControlValue(Cb_Worker), Cth.GetControlValue(Cb_Division), Cth.GetControlValue(Cb_Job), Cth.GetControlValue(Cb_Status), Cth.GetControlValue(De_Date)];
      Result:= (Q.QIUD('i', 'j_worker_status', 'sq_j_worker_status', 'id;id_worker;id_division;id_job;status;dt', v) >= 0);
      if Result then
        Dlg_CandidatesFromWorkerStatus.ShowDialog(v[1], v[4], v[5]);
  end;
end;


end.
