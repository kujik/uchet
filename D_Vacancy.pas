unit D_Vacancy;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Math,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, Mask, uData, uForms, uDBOra, uString, uMessages, System.Types,
  Vcl.ExtCtrls, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  GridsEh, DBAxisGridsEh, DBGridEh, MemTableDataEh, MemTableEh,
  Data.DB, Vcl.Menus, uSettings, Vcl.Imaging.pngimage, V_MDI, Vcl.ComCtrls,
  EhLibVclUtils
  ;

type
  TDlg_Vacancy = class(TForm_MDI)
    pnl_Top: TPanel;
    pnl_Grid: TPanel;
    pnl_Bottom: TPanel;
    pnl_Buttons: TPanel;
    cmb_Division: TDBComboBoxEh;
    cmb_Job: TDBComboBoxEh;
    cmb_Head: TDBComboBoxEh;
    dedt_Dt: TDBDateTimeEditEh;
    cmb_Status: TDBComboBoxEh;
    nedt_Qnt: TDBNumberEditEh;
    nedt_QntOpen: TDBNumberEditEh;
    DBGridEh1: TDBGridEh;
    edt_PPComment: TDBEditEh;
    DataSource1: TDataSource;
    MemTableEh1: TMemTableEh;
    dedt_DtEnd: TDBDateTimeEditEh;
    cmb_Reason: TDBComboBoxEh;
    Bt_Ok: TBitBtn;
    Bt_Cancel: TBitBtn;
    mem_Comm: TMemo;
    lbl_comm: TLabel;
    Img_Info: TImage;
    chb_Close: TCheckBox;
    Bt_Refresh: TBitBtn;
    Bt_Add: TBitBtn;
    Bt_Edit: TBitBtn;
    lbl_Candidates: TLabel;
    procedure ControlOnChange(Sender: TObject);
    procedure ControlOnExit(Sender: TObject);
    procedure ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean);
    procedure chb_CloseClick(Sender: TObject);
    procedure Bt_CancelClick(Sender: TObject);
    procedure Bt_OkClick(Sender: TObject);
    procedure Bt_RefreshClick(Sender: TObject);
    procedure Bt_AddClick(Sender: TObject);
    procedure Bt_EditClick(Sender: TObject);
    procedure DBGridEh1DblClick(Sender: TObject);
  private
    { Private declarations }
    aControls: array of TControl;
    Ok: Boolean;
    InClose: Boolean;
    function  Prepare: Boolean; override;
    procedure SetControlsVer;
    procedure SetControlsEnabled;
    procedure SetGrid;
    procedure LoadGrid;
    procedure Verify(Sender: TObject; onInput: Boolean = False);
  public
    { Public declarations }
    constructor ShowDialog(aOwner: TComponent; aFormDoc: string; aMode: TDialogType; aID: Variant; AMyFormOptions: TMyFormOptions; aAccMode: Variant);
  end;

var
  Dlg_Vacancy: TDlg_Vacancy;

implementation

{$R *.dfm}

uses
  uWindows,
  D_Grid1
  ;


constructor TDlg_Vacancy.ShowDialog(aOwner: TComponent; aFormDoc: string; aMode: TDialogType; aID: Variant; AMyFormOptions: TMyFormOptions; aAccMode: Variant);
begin
  inherited Create(aOwner, aFormDoc, AMyFormOptions + [myfoDialog], aMode, aID, null);
end;

function TDlg_Vacancy.Prepare: Boolean;
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
  if FormDbLock = fNone then Exit;

  aControls:=[
    cmb_Division,
    cmb_Job,
    cmb_Head,
    dedt_Dt,
    cmb_Status,
    nedt_Qnt,
    nedt_QntOpen,

    dedt_DtEnd,
    cmb_Reason,
    mem_Comm,
    chb_Close
  ];


  cmb_Status.Items.Add('��������');
  cmb_Status.KeyItems.Add('0');
  cmb_Status.Items.Add('�������');
  cmb_Status.KeyItems.Add('1');
  cmb_Status.Items.Add('������');
  cmb_Status.KeyItems.Add('2');

  cmb_Reason.Items.Add('�������� �������');
  cmb_Reason.KeyItems.Add('1');
  cmb_Reason.Items.Add('������� ������������');
  cmb_Reason.KeyItems.Add('2');

  //�������������
  Q.QLoadToDBComboBoxEh('select name, id from ref_divisions order by name', [], cmb_Division, cntComboLK);
  //���������
  Q.QLoadToDBComboBoxEh('select name, id from ref_jobs order by name',[], cmb_Job, cntComboLK);
  //���������
  Q.QLoadToDBComboBoxEh(
    'select workername, max(id_worker) from v_j_worker_status where status <> 3 or id_worker = (select id_head from v_j_vacancy where id = :id$i) group by workername order by workername',
    [ID], cmb_Head, cntComboLK);
  //������� ������ �� �������� �������
  FieldNames:='id$i;id_division$i;id_job$i;id_head$i;dt_beg$d;status$i;qnt$i;qntopen$i;dt_end$d;reason$i;comm$s';
//  FieldNamesCp:='id$i;f$s;i$s;o$s;dt_birth$d;phone$s';
  //��������� �������� �����
  v:=VarArrayOf([
    -1,
    null,
    null,
    null,
    Date,
    null,
    null,
    null, //QndOpen
    null,
    null,
    '',
    0
  ]);
  //�������� ������������, ���� ��� �� ���������� ������
  if Mode <> fAdd
    then begin
{      if Mode = fCopy then begin
        //��� �������� ����������� ������ ������ ������ ����������
        vc:=QSelectOneRow(QSIUDSql('s', 'v_j_candidates', FieldNamesCp), ID);
        //���� �� ������� �������� �� ������ � ���������� ��� ������ �������
        if vc[0] = null then begin MsgRecordIsDeleted; Exit; end;
        for i:=1 to High(vc) do v[i]:=vc[i];
      end
      else}
      begin
        v:=Q.QSelectOneRow(Q.QSIUDSql('s', 'v_j_vacancy', FieldNames), [ID]);
        //���� �� ������� �������� �� ������ � ���������� ��� ������ �������
        if v[0] = null then begin MsgRecordIsDeleted; Exit; end;
      end;
    end;
  //������� ����, �� �� ������������ ��� ������ ����� ������� ������� �� ��� �� ���
  if Mode in [fAdd, fCopy] then ID:= -1;

  //���� � ������� ��� �����
  SetGrid;

   //������� onCahange �  onExit ��� ���� dbeh ���������
  Cth.SetControlsOnChange(Self, ControlOnChange);
  Cth.SetControlsOnExit(Self, ControlOnExit);
  Cth.SetControlsOnCheckDrawRequired(Self, ControlCheckDrawRequiredState);
  //������� �������� �����
  v[11]:=S.IIf(v[8] <> null, 1, 0);
  //��������� ��������
  for i:=0 to High(aControls) do begin
    Cth.SetControlValue(aControls[i], v[i+1]);
  end;
  LoadGrid;

  Cth.SetDialogForm(Self, Mode, '��������.');
  Cth.SetBtn(Bt_Refresh, mybtRefresh, False, '��������');
  Cth.SetBtn(Bt_Add, mybtAdd, False, '��������');
  Cth.SetBtn(Bt_Edit, mybtEdit, False, '��������');

  Info:=
  S.IIFStr(Mode = fDelete,
  '������� ��, ����� ������� ��������'+
  '(������ �� ����� �������, ���� ���� ���������� �� ������ ��������.'#13#10+
  '���� ������ ����������� �� ������, ��� ����� �������� ������� - ������� ������, ��� ������ - ��� ������� �������� � ������!)'#13#10
  ,
  S.IIFStr(Mode = fAdd,
  '���������� ����� ��������.'#13#10+
  '���������� ����������� ������.'#13#10+
  '����� ������ ��������� ������ ��������, � ����������� �� ���, �������� ��� ����, ����� ��,'#13#10+
  '����� ���� �������� �������� � �������. ������ �� ������ ��������������� �� ��� �������� ���������.'#13#10
  ,
  '������� ������ �� ��������. �����, ��� �������������, �������� ��� �������� ������ ����������� ��� ���� ��������.'#13#10+
  ''#13#10
  )
  )
  ;

  if Mode in [fView, fDelete] then Info:='';
  Cth.SetInfoIcon(Img_Info, Info, 20);

  SetControlsVer;
  SetControlsEnabled;
  Verify(nil);

  if Mode = fAdd then begin
    pnl_Grid.Visible:=False;
    pnl_Bottom.Visible:=False;
    Self.ClientHeight:=pnl_Buttons.Top + pnl_Buttons.Height;
//    Self.Height:=Self.ClientHeight + 15;
  end;

  BorderStyle:=bsDialog;
  PreventResize:=True;

  Result:=True;

end;

procedure TDlg_Vacancy.SetControlsVer;
begin
  Cth.SetControlsVerification(
    [
      cmb_Division,
      cmb_Job,
      cmb_Head,
      dedt_Dt,
      cmb_Status,
      nedt_Qnt,
      dedt_DtEnd,
      cmb_Reason
    ],
    ['1:400','1:400','0:400',
     '1',
     '1:400',
     '1:200:0',
     S.IIFStr(chb_Close.Checked, '1', ''),
     S.IIFStr(chb_Close.Checked, '1:400', '0:400:0:n')
    ]
  );
end;


procedure TDlg_Vacancy.SetControlsEnabled;
//����������� ���������
//� ��������� �����������, ���� ����� ����� �������� ��������
var
  i:Integer;
  c: TVarDynArray;
  b: Boolean;
begin
  b:=not chb_Close.Checked and not (Mode in [fView, fDelete]);
  Cth.DlgSetControlsEnabled(Self, Mode, [], []);
  cmb_Division.Enabled:=b;
  cmb_Job.Enabled:=b;
  cmb_Head.Enabled:=b;
  cmb_Status.Enabled:=b;
  dedt_Dt.Enabled:=b;
  nedt_Qnt.Enabled:=b;
  nedt_QntOpen.Enabled:=False;
  Bt_Add.Enabled:=b;
  Bt_Edit.Enabled:=b;
  //���� � ������ �������� ����� ������ ��� ��������� �����
  dedt_DtEnd.Visible:=chb_Close.Checked;
  cmb_Reason.Visible:=chb_Close.Checked;
end;


procedure TDlg_Vacancy.Verify(Sender: TObject; onInput: Boolean = False);
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
//  Cth.VerifyControl(cmb_Status, False);
  if Sender = nil
    //�������� ��� DbEh
    then Cth.VerifyAllDbEhControls(Self)
    //�������� �������
    else Cth.VerifyControl(TControl(Sender), onInput);
  //������� ������ �������� � �������������
  Ok:=Cth.VerifyVisualise(Self);
  //������ ������ ��
  Bt_Ok.Enabled := Ok;
end;

procedure TDlg_Vacancy.ControlOnChange(Sender: TObject);
begin
  //����� ���� � ��������� ��������
  if InPrepare then Exit;
  //��������, ������� ��� � ���� ������� ��������
  Verify(Sender, True);
end;

procedure TDlg_Vacancy.ControlOnExit(Sender: TObject);
var
  st: string;
begin
  //����� ���� � ��������� ��������
  if InPrepare then Exit;
  //��������
  Verify(Sender);
end;


procedure TDlg_Vacancy.DBGridEh1DblClick(Sender: TObject);
begin
  inherited;
  if Bt_Edit.Enabled then Bt_EditClick(nil);
end;

procedure TDlg_Vacancy.Bt_CancelClick(Sender: TObject);
begin
  inherited;
  Close;
end;


procedure TDlg_Vacancy.chb_CloseClick(Sender: TObject);
//���� �� �������� �������� �����
begin
  inherited;
  if InClose or InPrepare then Exit;
  InClose:=True;
  //���� ��������� �����, �������� ��� �� ������� � ������ ��� �����, � ���� �� ��� �� ������
  if (chb_Close.Checked) then begin
    chb_Close.Checked:=False;
    SetControlsVer;
    if (not Ok) then begin
      MyWarningMessage('�� ��� ������ �� �������� �������!');
    end
    else chb_Close.Checked:=True;
  end;
  SetControlsVer;
  SetControlsEnabled;
  Verify(nil);
  InClose:=False;
end;

procedure TDlg_Vacancy.ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean);
begin
  Cth.VerifyVisualise(Self);
end;

procedure TDlg_Vacancy.Bt_OkClick(Sender: TObject);
var
  NewID: Integer;
  b: Integer;
  v: Variant;
begin
  if (Mode = fView) then begin Close; Exit; end;
//v:=Cth.GetControlValue(cmb_Status);
  b:= Q.QIUD(Q.QFModeToIUD(Mode),
    'j_vacancy', 'sq_j_vacancy',
    'id$i;id_division$i;id_job$i;id_head$i;dt_beg$d;status$i;qnt$i;dt_end$d;reason$i;comm$s',
    VarArrayOf([
      ID,
      Cth.GetControlValue(cmb_Division),
      Cth.GetControlValue(cmb_Job),
      Cth.GetControlValue(cmb_Head),
      Cth.GetControlValue(dedt_Dt),
      Cth.GetControlValue(cmb_Status),
      Cth.GetControlValue(nedt_Qnt),
      S.IIfV(chb_Close.Checked, Cth.GetControlValue(dedt_DtEnd), null),
      S.IIfV(chb_Close.Checked, Cth.GetControlValue(cmb_Reason), null),
      mem_Comm.Text
    ])
  );
  if b = -1 then Exit;
  RefreshParentForm;
  Close;
end;

procedure TDlg_Vacancy.Bt_RefreshClick(Sender: TObject);
begin
  inherited;
  LoadGrid;
end;

procedure TDlg_Vacancy.SetGrid;
begin
  MemTableEh1.FieldDefs.Clear;
  Mth.AddTableColumn(DBGridEh1, 'id', ftInteger, 0, '_id', 20, False);
  Mth.AddTableColumn(DBGridEh1, 'name', ftString, 400, '���', 200, True);
  Mth.AddTableColumn(DBGridEh1, 'dt', ftDate, 0, '���������', 50, True);
  Mth.AddTableColumn(DBGridEh1, 'statusfull', ftString, 400, '������', 200, True);
  //������� �������
  MemTableEh1.CreateDataSet;
  //�������� ���� �� �������
  MemTableEh1.First;
{  for i := 0 to High(Data) do begin
    MemTableEh1.Last;
    MemTableEh1.Insert;
    for j:=0 to High(Data[i]) do
      MemTableEh1.Fields[j].Value := Data[i][j];
    MemTableEh1.Post;
  end;
  MemTableEh1.First;}

//  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh+[dghShowRecNo];
//  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh+[dghEnterAsTab];
//  DBGridEh1.ShowHint:=True;
//  Gh.SetGridOptionsTitleAppearance(DBGridEh1);
  Gh.SetGridOptionsDefault(DBGridEh1);
  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh-[dghColumnMove];
  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh-[dghColumnResize];
  DBGridEh1.ReadOnly:=True;
end;

procedure TDlg_Vacancy.LoadGrid;
begin
  Q.QLoadToMemTableEh('select id, name, dt, statusfull from v_j_candidates where id_vacancy = :id$i order by dt', [ID], MemTableEh1);
  MemTableEh1.First;
  if ID>0 then
    Cth.SetControlValue(nedt_QntOpen, Q.QSelectOneRow('select qntopen from v_j_vacancy where id = :id$i', [ID])[0]);
end;

procedure TDlg_Vacancy.Bt_AddClick(Sender: TObject);
begin
  inherited;
  Wh.ExecAdd(myfrm_Dlg_Candidate, Self, fAdd, -1, [], null, True);
//  if Wh.FormDialogResult = mrOk then LoadGrid; //++
end;

procedure TDlg_Vacancy.Bt_EditClick(Sender: TObject);
begin
  inherited;
  if MemTableEh1.RecNo <= 0 then Exit;
  Wh.ExecAdd(myfrm_Dlg_Candidate, Self, fEdit, MemTableEh1.FieldByName('id').Value, [], null, True);
//  if Wh.FormDialogResult = mrOk then LoadGrid;
end;

end.
