unit uFrmWDedtWorkerStatus;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh, uFrmBasicMdi,
  uFrmBasicDbDialog, DateUtils, uData, uForms, uDBOra, uString, uMessages,
  uFields;

type
  TFrmWDedtWorkerStatus = class(TFrmBasicDbDialog)
    cmbJob: TDBComboBoxEh;
    cmbDivision: TDBComboBoxEh;
    cmbStatus: TDBComboBoxEh;
    dedtDate: TDBDateTimeEditEh;
    cmbWorker: TDBComboBoxEh;
    procedure cmb_StatusChange(Sender: TObject);
  private
    FDts: array[1..4] of TDateTime;
    FDep: TVarDynArray2;
    function Prepare: Boolean; override;
    function Load: Boolean; override;
    function Save: Boolean; override;
    function VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean; override;
    procedure btnOkClick(Sender: TObject); override;
    function VerifyWorker: Boolean;
    procedure CreateDep(dt: TDateTime; id: Integer);
    function VerifyTurvPeriods: string;
    function VerifyTurvDays(id_worker: Integer; dt: TDateTime): string;
    function DeleteTurvDays(id_worker: Integer; dt: TDateTime): string;
  public
  end;

var
  FrmWDedtWorkerStatus: TFrmWDedtWorkerStatus;

implementation

uses
  uTurv, D_CandidatesFromWorkerStatus;

{$R *.dfm}

function TFrmWDedtWorkerStatus.Prepare: Boolean;
begin
  Caption := '������ ���������';
  Result := inherited;
//  FOpt.StatusBarMode := stbmNone;
  if Mode = fAdd then
    Load;
end;

function TFrmWDedtWorkerStatus.VerifyWorker: Boolean;
//��� ���������� ������
//������ ��� ����� �� ������ ��� ��������� ������ ���� ������ ������
//������ ��� ����� �������� ��� ������������ �� ����� ���� ������
//���� �� ����� ���� ������� �� ������ ��� ���� � ���������� ������
//�� ����� ��������� � ���������� ������� ������������ ������������� � ���������
var
  st, msg, msg2: string;
  a, d: TVarDynArray2;
  idw: Integer;
  v: Variant;
begin
  Result := False;
  if HasError then
    Exit;
  st := '';
  idw := Cth.GetControlValue(cmbWorker);
  a := Turv.GetWorkerStatusArr(idw);
  d := [];
  if Mode = fAdd then begin
    //���������� ������
    if (Length(a) = 0) and (cmbStatus.Value <> '1') then
      st := '��� ����� ��������� �������� ������ ������ "������"';
    if (st = '') and (high(a) >= 0) then begin
      //�� ��������� ���� ��� ������ � ������� ��������
      if a[0][0] >= dedtDate.Value then
        st := '�������� ������ ����� ��������� ����� ������ �� ���� ������� ' + DateToStr(a[0][0])
      else if (a[0][1] = 3) and (cmbStatus.Value <> '1') then
        st := '��� ����� ��������� �������� ������ ������ "������"'
      else if ((a[0][1] = 1) or (a[0][1] = 2)) and (cmbStatus.Value = '1') then
        st := '��� ����� ��������� �� �������� ������ "������"'
      else if (cmbStatus.Value <> '3') and (Trunc(S.NNum(a[0][2])) = Cth.GetControlValue(cmbDivision)) and (Trunc(S.NNum(a[0][3])) = Cth.GetControlValue(cmbJob)) then
        st := '�������� ��� �������� � ���� ������������� � � ���� �� ���������!';
    end;
    if st = '' then begin
      if (Abs(DaysBetween(Cth.GetControlValue(dedtDate), Date)) > 31) and (MyQuestionMessage('���� ��������� ������� ������ ���������� �� �������! ��� ����� ����������?') <> mrYes) then
        Exit;
      Result := Turv.ChangeWorkerInTURV(Cth.GetControlValue(cmbWorker), Cth.GetControlValue(cmbDivision), Cth.GetControlValue(cmbJob), Cth.GetControlValue(dedtDate), ID, Cth.GetControlValue(cmbStatus));
      if not Result then
        Exit;
    end
    else begin
      //���� ���� ������ ������ �������� ������
      Result := False;
      MyWarningMessage(st);
    end;
  end
  else if Mode = fDelete then begin
    //�������� ������
    //�������� �� ������ ������ ��������� �� ������, ����� �� ����� ������ ������ �������� � ���� ������� ��� ����
    v := Q.QSelectOneRow('select nvl(max(id), -1) from j_worker_status where id_worker = :id$i', [idw])[0];
    if not ((v = -1) or (v = id)) then
      st := '��� ������ �� �������� ��������� ��� ������� ���������, ������� �� ����� ���� �������!';
    if st = '' then begin
      //v:=QSelectOneRow('select nvl(max(id), -1) from j_worker_status where id_worker = :id$i', idw)[0];
      if (Abs(DaysBetween(Cth.GetControlValue(dedtDate), Date)) > 31) and (MyQuestionMessage('���� ��������� ������� ������ ���������� �� �������! ��� ����� ����������?') <> mrYes) then
        Exit;
      v := Q.QSelectOneRow('select id, id_worker, id_division, id_job, status, dt from v_j_worker_status ' + 'where id_worker = :idw$i and id < :id and rownum = 1', [Cth.GetControlValue(cmbWorker), ID]);
      Result := Turv.ChangeWorkerInTURV(Cth.GetControlValue(cmbWorker), v[2], v[3], Cth.GetControlValue(dedtDate), ID, -1);
      if not Result then
        Exit;
    end
    else begin
      //���� ���� ������ ������ �������� ������
      Result := False;
      MyWarningMessage(st);
    end;
  end;
end;

//������ ���������, �� ����� �� ������������� �������� ����������� ����������, � ����� �������
//���� ��������� �� ������, �� ���������� �������� ������
function TFrmWDedtWorkerStatus.VerifyTurvPeriods: string;
var
  i, j: Integer;
  id, st: string;
  dt01, dt02: TDatetime;
  b: Boolean;
  v, v1: Variant;
begin
  Result := '';
  for i := 0 to High(FDep) do begin
    id := VarToStr(FDep[i][0]) + ' ' + FormatDateTime('yyyymmdd', TDateTime(FDep[i][1])) + ' ' + FormatDateTime('yyyymmdd', TDateTime(FDep[i][2]));
    v := Q.QSelectOneRow('select login, username from adm_locks where lock_docum = :docum$s and lock_docum_add = :documadd$s', [myfrm_Dlg_Turv, id]);
    if v[0] <> null then begin
      v1 := Q.QSelectOneRow('select name from ref_divisions where id = :id$i', [FDep[i][0]]);
      Result := Result + #13#10 + '���� �� ������ ' + VarToStr(v1[0]) + ' �� ������ � ' + DateToStr(TDateTime(FDep[i][1])) + ' �� ' + DateToStr(TDateTime(FDep[i][2])) + ' ������������ ' + VarToStr(v[1]) + '.';
    end;
    v := Q.QSelectOneRow('select id_division, name from v_turv_period where id = :id$s and commit = :commit$i', [id, 1]);
    if v[0] <> null then
      Result := Result + #13#10 + '���� �� ������ ' + VarToStr(v[1]) + ' �� ������ � ' + DateToStr(TDateTime(FDep[i][1])) + ' �� ' + DateToStr(TDateTime(FDep[i][2])) + ' �������� � �� ����� ���� �������!'
  end;
end;

//������ ���������, ������� ���� �� ���, ��� ������ ���� �������, ����� �������� ��������
//���, � ������� ����������� �� ������� �����, � ���� ����, �� ����������� � ������
function TFrmWDedtWorkerStatus.VerifyTurvDays(id_worker: Integer; dt: TDateTime): string;
var
  v: Variant;
begin
  Result := '';
  v := Q.QSelectOneRow('select count(*) from turv_day where (worktime1 is not null or worktime2 is not null or worktime3 is not null) and id_worker = :id_worker$i and dt >= :dt$d', [id_worker, dt]);
  if v[0] > 0 then
    Result := '� ���� ���� ' + VarToStr(v[0]) + ' ����, �� ������� ����������� ����� ������, � ������� ����� �������.';
end;

//������ ��� ������� ����� ��������� ������ ����
function TFrmWDedtWorkerStatus.DeleteTurvDays(id_worker: Integer; dt: TDateTime): string;
var
  v: Variant;
  b: array of Boolean;
  b1: Boolean;
  i: Integer;
  id: string;
begin
  Result := '';
  SetLength(b, Length(FDep));
  b1 := True;
  //���������� ������������� ��� ������������ �����
  for i := 0 to High(FDep) do begin
    id := VarToStr(FDep[i][0]) + ' ' + FormatDateTime('yyyymmdd', TDateTime(FDep[i][1])) + ' ' + FormatDateTime('yyyymmdd', TDateTime(FDep[i][2]));
    b[i] := Q.DBLock(True, myfrm_Dlg_Turv, id, '')[0];
    b1 := b1 and b[i];
  end;
  if b1 then begin
    Q.QExecSql('delete from turv_day where id_worker = :id_worker$i and dt >= :dt$d', [id_worker, dt], False);
  end
  else
    Result := '�� ������� ������������� ������������� ���� ��� ���������� ���������!';
  //������������, �� ��� ���� �������������
  for i := 0 to High(FDep) do begin
    id := VarToStr(FDep[i][0]) + ' ' + FormatDateTime('yyyymmdd', TDateTime(FDep[i][1])) + ' ' + FormatDateTime('yyyymmdd', TDateTime(FDep[i][2]));
    if b[i] then
      Q.DBLock(False, myfrm_Dlg_Turv, id, '');
  end;
end;



//������� ������������� ����
//� ������� [[��� ��1� ��2],[...]]
//��� ��� ������ ���������� ��� ������������ ����� �������, ��
//����� ����, � ������� �������� ���� � ��� ����������� �� ���������� ����
procedure TFrmWDedtWorkerStatus.cmb_StatusChange(Sender: TObject);
begin
  if FInPrepare then
    Exit;
  if S.NInt(cmbStatus.Value) = 3 then begin
    cmbDivision.Value := '';
    cmbJob.Value := '';
    cmbDivision.Enabled := False;
    cmbJob.Enabled := False;
  end
  else begin
    cmbDivision.Enabled := True;
    cmbJob.Enabled := True;
  end;
  inherited;
  ControlOnChangeEvent(Sender);
end;

procedure TFrmWDedtWorkerStatus.CreateDep(dt: TDateTime; id: Integer);
var
  i, j, id0: Integer;
  dt01, dt02: TDatetime;
  b: Boolean;
begin
  for i := 1 to High(FDts) - 1 do begin
    dt01 := FDts[i + 1];
    //�������� � ������, ���� ������ ���������� ����� ����
    if dt01 > dt then begin
      b := True;
      for j := 0 to High(FDep) do
        if (FDep[j][0] = id) and (FDep[j][1] = FDts[i]) then begin
          b := False;
          Break;
        end;
      if b then begin
        SetLength(FDep, Length(FDep) + 1);
        FDep[High(FDep)] := [id, FDts[i], IncDay(FDts[i + 1], -1)];
      end;
    end;
  end;
end;


procedure TFrmWDedtWorkerStatus.btnOkClick(Sender: TObject);
begin
  if (Mode = fView) then begin
    Close;
    Exit;
  end;
  Verify(nil);
  if not VerifyWorker then
    Exit;
  if not Save then
    Exit;
  RefreshParentForm;
  Close;
end;


function TFrmWDedtWorkerStatus.VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean;
begin
  Result := False;
  Cth.SetErrorMarker(cmbDivision, not ((cmbDivision.Value <> '') or (cmbStatus.Value = '3')));
  Cth.SetErrorMarker(cmbJob, not ((cmbJob.Value <> '') or (cmbStatus.Value = '3')));
end;

function TFrmWDedtWorkerStatus.Load: Boolean;
var
  v, v1: Variant;
  st: string;
begin
  Result := False;
  Q.QLoadToDBComboBoxEh('select w.f || '' '' || w.i || '' '' || w.o as name, id from ref_workers w order by name', [], cmbWorker, cntComboLK);
  Q.QLoadToDBComboBoxEh('select name, id from ref_divisions order by name', [], cmbDivision, cntComboLK);
  Q.QLoadToDBComboBoxEh('select name, id from ref_jobs order by name', [], cmbJob, cntComboLK);
  Cth.AddToComboBoxEh(cmbStatus, [['������', '1'], ['���������', '2'], ['������', '3']]);
  if Mode = fAdd then
    v := VarArrayOf([-1, '', '', '', '', ''])
  else
    v := Q.QSelectOneRow('select id, id_worker, id_division, id_job, status, dt from v_j_worker_status where id = :id', [id]);
  if v[0] = null then begin
    MsgRecordIsDeleted;
    Exit;
  end;
  Cth.SetControlValue(cmbWorker, v[1]);
  Cth.SetControlValue(cmbDivision, v[2]);
  Cth.SetControlValue(cmbJob, v[3]);
  Cth.SetControlValue(cmbStatus, v[4]);
  Cth.SetControlValue(dedtDate, v[5]);
  if Mode = fDelete then begin
    v1 := Q.QSelectOneRow('select nvl(max(id), -1) from j_worker_status where id_worker = :id$i', [v[1]])[0];
    if not ((v1 = -1) or (v1 = id)) then begin
      MyWarningMessage('��� ������ �� �������� ��������� ��� ������� ���������, ������� �� ����� ���� �������!');
      Exit;
    end;
  end;
  //��������� �������� ��������� - ��� �����������
  Cth.SetControlsVerification([cmbWorker, cmbDivision, cmbJob, cmbStatus, dedtDate], ['1:400', '1:400', '1:400', '1:400', '1']);
  Cth.DlgSetControlsEnabled(Self, Mode, [], []);
  cmbDivision.Enabled := (cmbStatus.Value <> '3') and (Mode = fAdd);
  cmbJob.Enabled := cmbDivision.Enabled;
  //���� ������������� ���� (������ ��������)
  FDts[2] := TURV.GetTurvBegDate(Date);
  FDts[1] := TURV.GetTurvBegDate(IncDay(FDts[2], -1));
  FDts[3] := TURV.GetTurvBegDate(IncDay(FDts[2], 17));
  FDts[4] := TURV.GetTurvBegDate(IncDay(FDts[3], 17));
  //���� ������� ������ ����������, �� ������� ����
  //(���� ����������� �������� �����, �������� ��� � ����������, �� �� ��������� ������)
  if VarIsArray(AddParam) then begin
    cmbWorker.Text := AddParam[0];
    if AddParam[1] <> '' then
      cmbDivision.Text := AddParam[1];
    if AddParam[2] <> '' then
      cmbJob.Text := AddParam[2];
    if AddParam[3] <> null then
      dedtDate.Value := AddParam[3];
  end;
  Result := True;
end;

function TFrmWDedtWorkerStatus.Save: Boolean;
//������ � �� ����������� � ������� VerifyWorker (� ��� � ���� ������� � ������ ������ TURV), ���������� �� ����������� ������� ������ ��!!!
var
  v: TVarDynArray;
  i, j: Integer;
begin
  Result := True;
  Exit;
  (*
  Result := False;
  if Mode = fDelete then begin
    v := [id];
    Result := (Q.QIUD('d', 'j_worker_status', 'sq_j_worker_status', 'id$i;name$s;office$i;id_head$i;editusers$s', v) >= 0);
  end
  else begin
    v := [id, Cth.GetControlValue(cmbWorker), Cth.GetControlValue(cmbDivision), Cth.GetControlValue(cmbJob), Cth.GetControlValue(cmbStatus), Cth.GetControlValue(dedtDate)];
    Result := (Q.QIUD('i', 'j_worker_status', 'sq_j_worker_status', 'id$i;id_worker$i;id_division$i;id_job$i;status$i;dt$d', v) >= 0);
 {   if Result then
      Dlg_CandidatesFromWorkerStatus.ShowDialog(v[1], v[4], v[5]);} //!!!
  end;*)
end;

end.

