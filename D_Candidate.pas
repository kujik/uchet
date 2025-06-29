unit D_Candidate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Math,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, Mask, uData, uForms, uDBOra, uString, uMessages, System.Types,
  Vcl.ExtCtrls, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, MemTableDataEh, MemTableEh,
  Data.DB, Vcl.Menus, uSettings, Vcl.Imaging.pngimage, V_MDI, Vcl.ComCtrls
  ;

type
  TDlg_Candidate = class(TForm_MDI)
    gb_Candidate: TGroupBox;
    edt_F: TDBEditEh;
    dedt_Birth: TDBDateTimeEditEh;
    edt_I: TDBEditEh;
    edt_Phone: TDBEditEh;
    edt_O: TDBEditEh;
    lbl_History: TLabel;
    gb_Vacancy: TGroupBox;
    pnl_Vacancy: TPanel;
    cmb_Division: TDBComboBoxEh;
    cmb_Job: TDBComboBoxEh;
    cmb_Head: TDBComboBoxEh;
    gb_Status: TGroupBox;
    dedt_Dt: TDBDateTimeEditEh;
    dedt_Pr: TDBDateTimeEditEh;
    dedt_Uv: TDBDateTimeEditEh;
    cmb_Status: TDBComboBoxEh;
    gb_Comment: TGroupBox;
    pnl_Comment: TPanel;
    mem_Comment: TMemo;
    pnl_Buttons: TPanel;
    Bt_Ok: TBitBtn;
    Bt_Cancel: TBitBtn;
    lbl_StatusError: TLabel;
    cmb_Ad: TDBComboBoxEh;
    Img_Info: TImage;
    Bt_SelectAd: TBitBtn;
    cmb_Vacancy: TDBComboBoxEh;
    lbl_VClosed: TLabel;
    lbl_Dt1: TLabel;
    lbl_Dt2: TLabel;
    Bt_AddWorker: TBitBtn;
    procedure cmb_VacancyChange(Sender: TObject);
    procedure ControlOnChange(Sender: TObject);
    procedure ControlOnExit(Sender: TObject);
    procedure ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean);
    procedure Bt_OkClick(Sender: TObject);
    procedure Bt_CancelClick(Sender: TObject);
    procedure Bt_SelectAdClick(Sender: TObject);
    procedure lbl_HistoryClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Bt_AddWorkerClick(Sender: TObject);
  private
    { Private declarations }
    aControls: array of TControl;
    LastName: string;
    CandidateInfo: TVarDynArray2;
    Ok: Boolean;
    OkStatus: Boolean;
    OkPressed: Boolean;
    function  Prepare: Boolean; override;
    procedure GetCandidateInfo;
    procedure SetStatus;
    procedure Verify(Sender: TObject; onInput: Boolean = False);
  public
    { Public declarations }
    constructor ShowDialog(aOwner: TComponent; aFormDoc: string; aMode: TDialogType; aID: Variant; AMyFormOptions: TMyFormOptions; aAccMode: Variant);
  end;

var
  Dlg_Candidate: TDlg_Candidate;

implementation

{$R *.dfm}

uses
  uWindows,
  D_Grid1
  ;


constructor TDlg_Candidate.ShowDialog(aOwner: TComponent; aFormDoc: string; aMode: TDialogType; aID: Variant; AMyFormOptions: TMyFormOptions; aAccMode: Variant);
begin
  inherited Create(aOwner, aFormDoc, AMyFormOptions + [myfoDialog], aMode, aID, null);
//inherited Create(aOwner, aFormDoc, 0, aMode, aID, [myfoDialog], null);
//  if aAccMode = null then aAccMode:=0;
//AccMode:=aAccMode;
end;


procedure TDlg_Candidate.cmb_VacancyChange(Sender: TObject);
//����� ��������
var
  v: TVarDynArray;
begin
  inherited;
  //��� �������� ������ ������� ��� ������ ������ - ����� ���������� ������, �������� ���� � ������� � ���
  if (InPrepare)and(Sender <> nil) then Exit;
  if cmb_Vacancy.ItemIndex <= 0 then begin
    cmb_Division.Text:='';
    cmb_Division.LimitTextToListValues:=True;
    cmb_Division.Enabled:=True;
    cmb_Job.Text:='';
    cmb_Job.LimitTextToListValues:=True;
    cmb_Job.Enabled:=True;
    cmb_Head.Text:='';
    cmb_Head.LimitTextToListValues:=True;
    cmb_Head.Enabled:=True;
  end
  else begin
    cmb_Division.LimitTextToListValues:=False;
    cmb_Division.Text:=Q.QSelectOneRow('select divisionname from v_j_vacancy where id = :id$i', [StrToInt(cmb_Vacancy.Value)])[0];
    cmb_Division.Enabled:=False;
    cmb_Job.LimitTextToListValues:=False;
    cmb_Job.Text:=Q.QSelectOneRow('select job from v_j_vacancy where id = :id$i', [StrToInt(cmb_Vacancy.Value)])[0];
    cmb_Job.Enabled:=False;
    cmb_Head.LimitTextToListValues:=False;
    cmb_Head.Text:=Q.QSelectOneRow('select headname from v_j_vacancy where id = :id$i', [StrToInt(cmb_Vacancy.Value)])[0];
    cmb_Head.Enabled:=False;
  end;
end;

function TDlg_Candidate.Prepare: Boolean;
var
  v, vc, vt: TVarDynArray;
  i: Integer;
  e: Extended;
  b, e1, e2: Boolean;
  ws: TWindowState;
  FieldNames, FieldNamesCp: string;
  Info: string;
begin
  Result:=False;
//  if Self.FormStyle = fsNormal then Wh.ModalResult:=mrNone;
  if FormDbLock = fNone then Exit;

  aControls:=[
    edt_F, edt_I, edt_O,
    dedt_Birth,
    edt_Phone,
    cmb_Ad,
    //������
    dedt_Dt,
//    chb_Pr,
    dedt_Pr,
 //   chb_Uv,
    dedt_Uv,
    cmb_Status,
    mem_Comment,
    cmb_Vacancy,
    cmb_Division,
    cmb_Job,
    cmb_Head
  ];

  //��������
  Q.QLoadToDBComboBoxEh(
    'select caption1 || ''  -  '' || job, id from v_j_vacancy where dt_end is null or id = (select id_vacancy from j_candidates where id = :id$i) order by caption1',
    [ID], cmb_Vacancy, cntComboLK0);
  //�������������
  Q.QLoadToDBComboBoxEh('select name, id from ref_divisions order by name', [], cmb_Division, cntComboLK0);
  //���������
  Q.QLoadToDBComboBoxEh('select name, id from ref_jobs order by name',[], cmb_Job, cntComboLK0);
  //���������  v_j_worker_status
  //!!!�����������, ���� ������������� ��������, � ������������, � ��� �����������, ��� �� ��������!!!
  Q.QLoadToDBComboBoxEh(
//    'select workername, id from v_j_worker_status where status <> 3 or id = (select id_head from v_j_candidates where id = :id$i) order by workername',
    'select workername, max(id_worker) from v_j_worker_status where status <> 3 or id_worker = (select id_head from v_j_candidates where id = :id$i) group by workername order by workername',
    [ID], cmb_Head, cntComboLK0);
  //�������
  Q.QLoadToDBComboBoxEh('select name, id from ref_candidates_status where id >= 10 order by name', [], cmb_Status, cntComboLK);
  //��������� ����������
  Q.QLoadToDBComboBoxEh('select name, id from ref_candidates_ad order by name', [], cmb_Ad, cntComboLK);
  //������� ������ �� �������� �������
//  FieldNames:='id$i;f$s;i$s;o$s;dt_birth$d;phone$s;id_ad$i;dt$d;0,dt1$d;0,dt2$d;id_status$i;comm$s;id_vacancy$i;id_division;id_job;id_head;vacancyclosed';
  FieldNames:='id$i;f$s;i$s;o$s;dt_birth$d;phone$s;id_ad$i;dt$d;dt1$d;dt2$d;id_status$i;comm$s;id_vacancy$i;id_division;id_job;id_head;vacancyclosed';
  FieldNamesCp:='id$i;f$s;i$s;o$s;dt_birth$d;phone$s';
  //��������� �������� �����
  v:=VarArrayOf([
    -1,
    '','','',  //���
    null,  //birth
    '',  //�������
    null,  //������     6

    Date,  //���� ���������   #7
    null, null, //�����-����������
    null,  //��-������    10
    '',  //�������
    0,  //���� ��������
    0, 0, 0,  //���� �������������, ���������, ������������
    null   //�������� �������       16
     ]);
  //�������� ������������, ���� ��� �� ���������� ������
  if Mode <> fAdd
    then begin
      if Mode = fCopy then begin
        //��� �������� ����������� ������ ������ ������ ����������
        vc:=Q.QSelectOneRow(Q.QSIUDSql('s', 'v_j_candidates', FieldNamesCp), [ID]);
        //���� �� ������� �������� �� ������ � ���������� ��� ������ �������
        if vc[0] = null then begin MsgRecordIsDeleted; Exit; end;
        for i:=1 to High(vc) do v[i]:=vc[i];
      end
      else begin
        v:=Q.QSelectOneRow(Q.QSIUDSql('s', 'v_j_candidates', FieldNames), [ID]);
        //���� �� ������� �������� �� ������ � ���������� ��� ������ �������
        if v[0] = null then begin MsgRecordIsDeleted; Exit; end;
      end;
    end;
  //������� ����, �� �� ������������ ��� ������ ����� ������� ������� �� ��� �� ���
  if Mode in [fAdd, fCopy] then ID:= -1;

   //������� onCahange �  onExit ��� ���� dbeh ���������
  Cth.SetControlsOnChange(Self, ControlOnChange);
  Cth.SetControlsOnExit(Self, ControlOnExit);
  Cth.SetControlsOnCheckDrawRequired(Self, ControlCheckDrawRequiredState);
  //��������� �������� ���������
  Cth.SetControlsVerification(
    [edt_F, edt_I, edt_O,
     dedt_Birth,
     edt_Phone,
     cmb_Ad,
     dedt_Dt,
     cmb_Status
    ],
    ['1:25:0:T','1:25:0:T','0:25:0:T',
     '1',
     '1:400:0:T',
     '1:200:0',
     '1',
     '0:200:0:n'
    ]
  );



  //����� ������/������
 // v[8] := v[9] <> null;
 // v[10] := v[11] <> null;
  for i:=0 to High(aControls) do begin
    Cth.SetControlValue(aControls[i], v[i+1]);
  end;

  //��������� ������ �� ������������� � ��������� �� ��������
  if cmb_Vacancy.ItemIndex > 0 then cmb_VacancyChange(nil);

  Cth.SetDialogForm(Self, Mode, '����������.');
  Cth.SetBtn(Bt_SelectAd, mybtSelectFromList, True, '���������� ���������� ���������� � ��������.');
  Cth.SetBtn(Bt_AddWorker, mybtAdd, True, '��������/������� ���������.');


  Cth.DlgSetControlsEnabled(Self, Mode, [], []);

  //���� ������ �� �������� ��������, �� � ������ �������������� �� ����� ������ �������� � �������, ����� ����������� ����������
  if (Mode = fEdit) and (v[16] <> null) then begin
    lbl_VClosed.Visible:=True;
    cmb_Division.Enabled:=False;
    cmb_Job.Enabled:=False;
    cmb_Head.Enabled:=False;
    cmb_Vacancy.Enabled:=False;
    dedt_Dt.Enabled:=False;
    dedt_Pr.Enabled:=False;
    cmb_Status.Enabled:=False;
  end;

  Bt_AddWorker.Visible:= not(Mode in [fDelete, fView]);

  Verify(nil);

  Info:=
  '���� ������ �� ����������.'#13#10+
  ''#13#10+
  '����������:'#13#10+
  '��������� ��� ���� (������ ���� �������� �� �����������.)'#13#10+
  '�� ���� ����� ������ ����� ��������, ������� �� ���� ��������� �� ��� � ����� �� ��� (�, ���� ���������, �/�)'#13#10+
  '��� ��������� ���� ���������� �������� �� ��������������� ������.'#13#10+
  ''#13#10+
  '��������:'#13#10+
  '�� ������ ������� ��������, �� ������� ���������� ����������, �� ������ �������� ������ ��������.'#13#10+
  '� ���� ������ ���������� ����� �������� � ������ ��������, ���� "�������������", "���������", "�������������" �����'#13#10+
  '��������� �� ������ �������� ��� ����������� �� ���������.'#13#10+
  '��� �� ������ �������� ���� "��������" ������, � ������� ��������� ���� ������� (� ���� ������ ��� �� ����������� ��� �����).'#13#10+
  ''#13#10+
  '������:'#13#10+
  '���������� ������ ����������.'#13#10+
  '���������� ��������� ���� ���������, ��� �������� ��� ����� ������� ����.'#13#10+
  '���� �������� �� ������ �� ������, ����� ������� ������ �� ������,'#13#10+
  '��� �� ����� ���������� ���� ������ (�� �� ����� ���� ���������).'#13#10+
  '� ����������, ���� �������� ����� ������, ����� ���������� ���� ���������� (���� �� ������ ���� ������ �� ������).'#13#10+
  ''#13#10+
  '�����������:'#13#10+
  '��������� ����������� � ������ ������� � ������� ����������� (�� �����������).'#13#10+
  '� ������������ ������� �������� �� ������ ��������� ���������� ���������� � ��������.'#13#10+
  '��� ���� ����� ������� ����� ������� ������� �����������, ������� ������ ������.'#13#10+
  ''#13#10+
  '������� ������ "+", ����� ������� ��������� �� ��������� ������ ����������, � ������ ������ � ������ �������� ���������.'#13#10+
  ''#13#10
  ;
  if Mode in [fView, fDelete] then Info:='';
  Cth.SetInfoIcon(Img_Info, Info, 20);
  BorderStyle:=bsDialog;
  PreventResize:=True;
  GetCandidateInfo;
  Verify(nil);

  Result:=True;

  //!!!
  lbl_VClosed.Visible:=False;
end;

procedure TDlg_Candidate.ControlOnChange(Sender: TObject);
begin
  if Sender = cmb_Vacancy then cmb_VacancyChange(Sender);
  //����� ���� � ��������� ��������
  if InPrepare then Exit;
  //��������, ������� ��� � ���� ������� ��������
  Verify(Sender, True);
end;

procedure TDlg_Candidate.ControlOnExit(Sender: TObject);
var
  st: string;
begin
  //����� ���� � ��������� ��������
  if InPrepare then Exit;
  //��������
  Verify(Sender);
  st:=edt_F.Text + '|' + edt_I.Text + '|' + edt_O.Text + '|' + dedt_Birth.Text;
  if st <> LastName then begin
    LastName:= st;
    GetCandidateInfo;
  end;
end;

procedure TDlg_Candidate.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  if Self.FormStyle = fsNormal then begin
{    if Self.ModalResult = mrOk
      then Wh.SelectDialogResult:=[1]
      else Wh.SelectDialogResult:=[0];}//++
  end;
end;

procedure TDlg_Candidate.ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean);
begin
  Cth.VerifyVisualise(Self);
end;

procedure TDlg_Candidate.GetCandidateInfo;
var
  st: string;
  param: TVarDynArray;
  sql: TvarDynArray;
begin
  if (edt_F.Text = '') or (edt_I.Text = '') then begin
    lbl_History.Visible := False;
  end
  else begin
    Param:= VarArrayOf([ID, edt_F.Text, edt_I.Text, edt_O.Text, dedt_Birth.Value]);
    sql:=['id<>:id$i', 'lower(f)=lower(:f$s)', 'lower(i)=lower(:i$s)', 'lower(o)=lower(:o$s)', 'dt_birth=:d$d'];
    if not(Cth.DteValueIsDate(dedt_Birth)) then SetLength(Param, 4);
    if (edt_O.Text = '')and(not(Cth.DteValueIsDate(dedt_Birth))) then SetLength(Param, 3);
    SetLength(Sql, Length(Param));
    st:=A.Implode(sql, ' and ');
    CandidateInfo:=Q.QLoadToVarDynArray2(
      'select name, dt_birth, dt, job, statusfull, comm from v_j_candidates where ' + st + ' order by dt asc',
      Param
    );
    lbl_History.Caption:=
      S.IIFStr(Length(CandidateInfo) = 0, '��������� �� ����.', '���� ' + IntToStr(Length(CandidateInfo)) + ' ��������' + S.GetEnding(Length(CandidateInfo), '�', '�', '�') + '.');
    lbl_History.Visible := True;
    if Length(CandidateInfo) > 0 then begin
      lbl_History.Font.Color:=clBlue;
      lbl_History.Font.Style:=[fsUnderline];
    end
    else begin
      lbl_History.Font.Color:=clBlack;
      lbl_History.Font.Style:=[];
    end;
  end;
end;

procedure TDlg_Candidate.lbl_HistoryClick(Sender: TObject);
begin
  inherited;
//  'select name, dt_birth, dt, job, statusfull, comm from v_j_candidates where ' + st + ' order by dt asc',
  if Length(CandidateInfo) = 0 then Exit;
  Dlg_Grid1.ShowDialog('���������', 950, 160,
    [
      ['name', ftString, 400, '���', 180, True],
      ['dt_birth', ftDate, 0, '�/�', 50, True],
      ['dt', ftDate, 0, '���������', 50, True],
      ['job', ftString, 400, '���������', 160, True],
      ['statusfull', ftString, 100, '������', 200, True],
      ['comm', ftString, 4000, '�����������', 300, True]
    ],
    CandidateInfo
  );
end;

//�������� ���������6���� ������
//���������� ������� ��� ��������, ��� ��� - ��������� ���
//� ������� ��� �������� ��� ����� ������ � �������� (� ������� onChange)
procedure TDlg_Candidate.Verify(Sender: TObject; onInput: Boolean = False);
var
  i,j,s:Integer;
  c: TControl;
begin
  //� ��������� � �������� ������ ��
  if (Mode = fView) or (Mode = fDelete)
    then begin
      Ok:=True;
      Bt_Ok.enabled := Ok;
      Exit;
    end;
  //�������� ������ �� ������� � ���������
  SetStatus;
//  Cth.VerifyControl(cmb_Status, False);
  if Sender = nil
    //�������� ��� DbEh
    then Cth.VerifyAllDbEhControls(Self)
    //�������� �������
    else Cth.VerifyControl(TControl(Sender), onInput);
  //������� ������ �������� � �������������
  Ok:=Cth.VerifyVisualise(Self) and OkStatus;
  //������ ������ ��
  Bt_Ok.Enabled := Ok;
end;

procedure TDlg_Candidate.SetStatus;
begin
  cmb_Status.Visible:=not((Cth.DteValueIsDate(dedt_Pr))or(Cth.DteValueIsDate(dedt_Uv)));
//  Cth.SetControlsVerification([cmb_Status], [S.IIFStr(Cth.DteValueIsDate(dedt_Dt), '0:200:0:n', '0:200:0')]);
  OkStatus:=(
    Cth.DteValueIsDate(dedt_Dt) and (
      (not((Cth.DteValueIsDate(dedt_Pr))or(Cth.DteValueIsDate(dedt_Uv))) and (cmb_Status.ItemIndex >=0))
      or
      (Cth.DteValueIsDate(dedt_Pr)and(dedt_Pr.Value >= dedt_Dt.Value)and(not Cth.DteValueIsDate(dedt_Uv)))
      or
      ((Cth.DteValueIsDate(dedt_Pr)and(dedt_Pr.Value >= dedt_Dt.Value)and(Cth.DteValueIsDate(dedt_Uv))and(dedt_Uv.Value >= dedt_Pr.Value)))
      )
    );
  lbl_StatusError.Visible:= not OkStatus;
end;

procedure TDlg_Candidate.Bt_CancelClick(Sender: TObject);
begin
  inherited;
  Close;
end;

procedure TDlg_Candidate.Bt_OkClick(Sender: TObject);
var
  NewID: Integer;
  b: Integer;
  v: Variant;
begin
  if (Mode = fView) then begin Close; Exit; end;
//v:=Cth.GetControlValue(cmb_Status);
  b:= Q.QIUD(Q.QFModeToIUD(Mode),
    'j_candidates', 'sq_j_candidates', 'id$i;f$s;i$s;o$s;dt_birth$d;phone$s;id_ad$i;dt$d;dt1$d;dt2$d;id_status$i;comm$s;id_vacancy$i;id_division$i;id_job$i;id_head$i',
    VarArrayOf([
      ID,
      Cth.GetControlValue(edt_F),
      Cth.GetControlValue(edt_I),
      Cth.GetControlValue(edt_O),
      Cth.GetControlValue(dedt_Birth),
      Cth.GetControlValue(edt_Phone),
      Cth.GetControlValue(cmb_Ad),
      Cth.GetControlValue(dedt_Dt),
      Cth.GetControlValue(dedt_Pr),
      Cth.GetControlValue(dedt_Uv),
      S.IIfV(Cth.DteValueIsDate(dedt_Pr) or Cth.DteValueIsDate(dedt_Uv), null, Cth.GetControlValue(cmb_Status)),
      mem_Comment.Text,
      S.IIfV(cmb_Vacancy.ItemIndex <= 0, null,  Cth.GetControlValue(cmb_Vacancy)),
      S.IIfV((cmb_Vacancy.ItemIndex > 0)or(cmb_Division.ItemIndex <= 0), null,  Cth.GetControlValue(cmb_Division)),
      S.IIfV((cmb_Vacancy.ItemIndex > 0)or(cmb_Job.ItemIndex <= 0), null,  Cth.GetControlValue(cmb_Job)),
      S.IIfV((cmb_Vacancy.ItemIndex > 0)or(cmb_Head.ItemIndex <= 0), null,  Cth.GetControlValue(cmb_Head))
    ])
  );
  if b = -1 then Exit;
  RefreshParentForm;
  //�������, ��� ����� �� ������ ��, ��� ���-����� �������� ����� ModalResult �� ����������
  //���� ���� ��������� � OnClose � ������ ���� � FE
//  OkPressed:=True;
//  Bt_Ok.ModalResult:=mrOk;
//  Self.ModalResult:=mrOk;
  FormDialogResult:=mrOk;
  Close;
end;


procedure TDlg_Candidate.Bt_SelectAdClick(Sender: TObject);
//������ ������ ����������� ���������� ����������
begin
{  Wh.SelectDialogResult:=[];
  Wh.ExecMDIForm(myfrm_R_Candidates_Ad_SELCH, True);
  if Length(Wh.SelectDialogResult) = 0 then Exit;
  try
  Q.QLoadToDBComboBoxEh('select name, id from ref_candidates_ad order by name', [], cmb_Ad, cntComboLK);
  cmb_Ad.Text:=Wh.SelectDialogResult[1];
  finally
  end;}//++
end;

procedure TDlg_Candidate.Bt_AddWorkerClick(Sender: TObject);
begin
  inherited;
  if (edt_F.Text ='') or (edt_I.Text = '') then Exit;
  if Q.QSelectOneRow('select count(id) from ref_workers where f=:f$s and i=:i$s and o=:o$s', [edt_F.Text, edt_I.Text, edt_O.Text])[0] = 0 then
    if MyQuestionMessage('������� ��������� "' + edt_F.Text + ' ' + edt_I.Text + ' ' + edt_O.Text + '"') = mrYes then begin
      Q.QIUD(
        'i',
        'ref_workers',
        'sq_ref_workers',
        'id;f;i;o;active',
        [null, edt_F.Text, edt_I.Text, edt_O.Text, 1]
      );
    end
    else Exit;
  Wh.ExecAdd(myfrm_Dlg_WorkerStatus, Self, fAdd, 0, [],
    VarArrayOf([
      edt_F.Text + ' ' + edt_I.Text + ' ' + edt_O.Text,
      cmb_Division.Text,
      cmb_Job.Text,
      S.IIfV(Cth.DteValueIsDate(dedt_Uv), dedt_Uv.Value, S.IIfV(Cth.DteValueIsDate(dedt_Pr), dedt_Pr.Value, null))
      ]),
    True
  );
end;

end.
