{
���������� ���������

  ������������� ��������� ������ � ������� ���������� �� ������� ������������� (�, ��������, ������ ���������) �� ������ ������
(��������� � Dlg_CreatePayroll)
  ��� ������ �������� ����������� �������� �� ������ ����, ������ � ���������� ���������� ������������, ��������� ������� ������,
���������, �� ������� ���� �������������� ��������� �� ��������. ��������� ������ ����������� �������. �� ������ � ����� �������
�� ���������� ��������� (�� ������� ������) �� ������� ������������� (�� ����� �������������). ����� ������� ������� ����� ��
���� ���������.
  ��� ������� ������ ���� - �������������� ������ (����������� ������, ������� ��� �� ����, ���� �� ��� ��� �������������� ����������,
��������� �� �����, �� �� �� ��, ������, ��� ������� ������ ��� ������ � ����). ����������� ������ �� ������� �����, �������, �������,
� ��������������� �����.
  ������ � ����� (���) - �����, ��� ����, � ���� ����������� �� 10�
  ������ ����������� ��� �������� ���������, ������� � ��������� ��������, � ��������� ������ ���������� � ���������


ID	NAME	COMM
14	������/������/�������/��������	������ ���, ����� ��������, ������ �� ������ ���
13	������������/���������	������ ���, ����� ��������, ������ �� ������ ���
12	����, ������, ���	�����, ����� �� �����, ������ �� ������ �������
11	��������/��������	�����, ����� ���������, ������ �� ������ �������
10	�������/���������	�����, ����� �� �����, ������ �� �������� ������ (�������), ������ �� ����������� (�������)
}

unit F_Payroll;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_MDI, Vcl.ExtCtrls, Vcl.ComCtrls, uData,
  DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, MemTableDataEh,
  Data.DB, MemTableEh, Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh, EhLibVCL, GridsEh,
  DBAxisGridsEh, DBGridEh, Vcl.Buttons, Menus, DateUtils,
  uString, frxClass, PrnDbgEh, Math, IOUtils, Types
  ;

type
  TForm_Payroll = class(TForm_MDI)
    pnl_Top: TPanel;
    DBGridEh1: TDBGridEh;
    DBGridEh3: TDBGridEh;
    edt_PPComment: TDBEditEh;
    MemTableEh1: TMemTableEh;
    DataSource1: TDataSource;
    lbl_Caption1: TLabel;
    pnl_Right: TPanel;
    lbl_Info: TLabel;
    Timer_AfterUpdate: TTimer;
    pnl_Left: TPanel;
    pnl_Center: TPanel;
    PrintDBGridEh1: TPrintDBGridEh;
    FileOpenDialog1: TFileOpenDialog;
    Timer_Print: TTimer;
    procedure DBGridEh1Columns0GetCellParams(Sender: TObject;
      EditMode: Boolean; Params: TColCellParamsEh);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure DBGridEh1Columns0UpdateData(Sender: TObject; var Text: string;
      var Value: Variant; var UseText, Handled: Boolean);
    procedure Bt_SettingsClick(Sender: TObject);
    procedure Timer_AfterUpdateTimer(Sender: TObject);
    procedure MemTableEh1AfterScroll(DataSet: TDataSet);
    procedure BitBtn1Click(Sender: TObject);
    procedure Bt_Click(Sender: TObject);
    procedure PrintDBGridEh1BeforePrint(Sender: TObject);
    procedure PrintDBGridEh1AfterPrint(Sender: TObject);
    procedure Timer_PrintTimer(Sender: TObject);
    procedure DBGridEh1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    PeriodStartDate, PeriodEndDate: TDateTime;
    ID_Division: Integer;
    ID_Worker: Variant;
    DivisionName, WorkerName: string;
    ColWidth: Integer;
    IsEditable: Boolean;
    CalcMode: Variant;  //��� ������� - ���� ������ �������
    Norma: Variant;     //����� � ����� � �����, ������������ ��� CalcMode=0
    Norma01: Variant;
    Buttons: TmybtArr;             //������ ������ TmybnRec
    ButtonsState: TVarDynArray;    //������ �������� ��������� ������
    IsOffice: Boolean;
    DeletedWorkers: TVarDynArray;
    RecNoCh: Integer;
    Commit: Boolean;
    function  Prepare: Boolean; override;
    function  CreateTurvList: Integer;
    function  GetList: Integer;
    function  GetTurvList: Integer;
    function  Save: Integer;
    procedure CalculateRow(row:Integer);
    procedure CalculateAll;
    procedure SetButtons;
    procedure PayrollSettings;
    procedure SavePayroll;
    procedure CheckEmpty;
    function  IsChanged: Boolean;
    procedure GetXlsData;
    procedure GetNdfl;
    procedure PrintGrid;
    procedure PrintLabels;
    procedure ClearFilter;
    procedure SetColumns;
    procedure ExportToXlsxA7;
    procedure CommitPayroll;
  public
    { Public declarations }
    constructor ShowDialog(aOwner: TComponent; aFormDoc: string; aMode: TDialogType; aID: Variant; AMyFormOptions: TMyFormOptions);
  end;

var
  Form_Payroll: TForm_Payroll;

implementation

uses
  uTurv,
  uForms,
  uMessages,
  uSettings,
  uDBOra,
  XlsMemFilesEh,
  uExcel,
  D_PayrollSettings,
  Printers,
  PrViewEH,
  uPrintReport,
  uModule,
  uSys
  ;

{$R *.dfm}

procedure TForm_Payroll.SavePayroll;
var
  i, j, k, rn: Integer;
  va, vadel: TVarDynArray2;
  st, st1, st2, w: string;
  v, v1, v2: Variant;
  buf: Variant;
  changed: Boolean;
  id1: extended;
begin
  ClearFilter;
  //������� ����� �������
  Q.QExecSql('update payroll set id_method = :id_method$i, commit = :commit$i where id = :id$i', [CalcMode, S.IIf(Commit, 1, null), ID]);
  //������ �� �� ����, ���� ������� �� ������ ��� ������� ������ ����
  //����� ������� ������, ���� ���������� ������������� ���������, ������� �� ��������� ����������, � �������� ����
  for i:=0 to High(DeletedWorkers) do begin
    Q.QExecSql('delete from payroll_item where id_payroll = :id$i and id_worker = :id_worker$i', [id, DeletedWorkers[i]], False);
  end;
  rn:=MemTableEh1.RecNo;
  for i:=1 to MemTableEh1.RecordCount do begin
    MemTableEh1.RecNo:=i;
    id1:=S.NNum(MemTableEh1.FieldByName('id').AsVariant);
    if id1 = 0 then begin
      Q.QIUD('i', 'payroll_item', 'sq_payroll_item', 'id;id_payroll;id_division;id_worker;id_job;dt',
        [-1, ID, Integer(ID_Division), MemTableEh1.FieldByName('id_worker').AsInteger, MemTableEh1.FieldByName('id_job').AsInteger, PeriodStartDate],
        False
      );
      MemTableEh1.Edit;
      MemTableEh1.FieldByName('id').Value:=Q.LastSequenceId;
      MemTableEh1.Post;
      MemTableEh1.Edit;
    end;
    //lastgeneraateid
    Q.QIUD('u', 'payroll_item', 'sq_payroll_item',
      'id;blank$f;ball_m$f;turv$f;ball$f;premium_m_src$f;premium_m$f;premium$f;premium_p$f;otpusk$f;bl$f;penalty$f;itog1$f;ud$f;ndfl$f;fss$f;pvkarta$f;karta$f;itog$f',
      [
        MemTableEh1.FieldByName('id').AsInteger,
        MemTableEh1.FieldByName('blank').AsVariant,
        MemTableEh1.FieldByName('ball_m').AsVariant,
        MemTableEh1.FieldByName('turv').AsVariant,
        MemTableEh1.FieldByName('ball').AsVariant,
        MemTableEh1.FieldByName('premium_m_src').AsVariant,
        MemTableEh1.FieldByName('premium_m').AsVariant,
        MemTableEh1.FieldByName('premium').AsVariant,
        MemTableEh1.FieldByName('premium_p').AsVariant,
        MemTableEh1.FieldByName('otpusk').AsVariant,
        MemTableEh1.FieldByName('bl').AsVariant,
        MemTableEh1.FieldByName('penalty').AsVariant,
        MemTableEh1.FieldByName('itog1').AsVariant,
        MemTableEh1.FieldByName('ud').AsVariant,
        MemTableEh1.FieldByName('ndfl').AsVariant,
        MemTableEh1.FieldByName('fss').AsVariant,
        MemTableEh1.FieldByName('pvkarta').AsVariant,
        MemTableEh1.FieldByName('karta').AsVariant,
        MemTableEh1.FieldByName('itog').AsVariant
      ], True
    );
  end;
  MemTableEh1.RecNo:=rn;
end;

function TForm_Payroll.CreateTurvList: Integer;
//��������� ��������� (������ �������������) �� ������ ���� �� ������� ������ (�������������� ��������)
//���������� ������ � ������, ���� � ��������� ��� �� ����� ������, ��� �������� ���������
//���� ���� ��� ������ ��������, �� ������ ����� ��������� GetList
var
  i, j, k: Integer;
  va, va1, vadel: TVarDynArray2;
  st, st1, st2, w: string;
  v, v1, v2: Variant;
  buf: Variant;
  changed: Boolean;
  size: Integer;
begin
  if Q.QSelectOneRow('select count(*) from payroll_item where id_payroll = :id$i', [id])[0] > 0 then Exit;
  //0-����1, 1-����2, 2-���� ���������, 3-��� ���������, 4-���� ���������, 5-��������� ���������, 6-����� �������: 1=��������� 2=������
  va:=uTurv.Turv.GetTurvArray(ID_Division, PeriodStartDate, False);
  vadel:=[[]];
  //������ ������������� �� ��� ������
  i:=0; j:=0; st:='';
  while i < High(va) do begin
    if va[i][3] = st then begin
      delete(va, i, 1);
    end
    else begin
      st:=va[i][3];
      inc(i);
    end;
  end;
  if ID_Worker = null then begin
    //���� ��������� �� �������������
    // ���������� �������
    repeat
      changed := False;
      for k := 0 to High(va) - 1 do
        if va[k][5] > va[k + 1][5] then
        begin // �������� k-� � k+1-� ��������
          for j:=0 to High(va[k]) do begin
            buf := va[k][j];
            va[k][j] := va[k + 1][j];
            va[k + 1][j] := buf;
          end;
          changed := True;
        end;
    until not changed;
    //�������� ���� ����������, �� ������� ������� �� ���� ������ ��������� ���������
    vadel:=Q.QLoadToVarDynArray2(
      'select id_worker from v_payroll where id_worker is not null and dt1 = :dt1$d',
      [PeriodStartDate]
    );
  end
  else begin
    //������ ��� ������, ����� ��������� �� �������� ���������
    for i:= High(va) downto 0 do begin
      if va[i][2] <> ID_Worker then Delete(va, i, 1);
    end;
  end;
  //�������� ���������� �� �������� ���� �� ����� �� ������������� (�� ����� �������������)
  va1:=Q.QLoadToVarDynArray2(
    'select id_worker, blank, ball_m from payroll_item where id_division = :id_division$i and dt = :dt1$d',
    [ID_Division, Turv.GetTurvBegDate(IncDay(PeriodStartDate, -1))]
  );
  //�������� �� ������ � ����� �� ������ (�����) �� �������� �������
  for i:=0 to High(va) do begin
    j:=A.PosInArray(va[i][2], va1, 0);
    if j >= 0 then begin
      va[i][5]:=va1[j][1];
      va[i][6]:=va1[j][2];
    end
    else begin
      va[i][5]:=null;
      va[i][6]:=null;
    end;
  end;

  //�������� ������ �� ������������� ��� ������ ��������� � �� (��� ���� �������� ��������)
  //���� ����� � �������� ���������� ���� ��������� �������� ��������� � �� ����� ������� ����� �� ������ �������������,
  //�� ����� ������ ������������, ����� �� �� �������
  //����� ��������, ��������� ��� ����� ����� ���������� �� ��
  //����� - �� ���-���� ������ �������� ����� �� ����������� �� �� ������� �������������� ���������, ���� ��� � �� �����������
  for i:=0 to High(va) do begin
    if not A.PosInArray(va[i][2], vadel, 0) >=0 then
      Q.QIUD('i', 'payroll_item', 'sq_payroll_item', 'id;id_payroll;id_division;id_worker;id_job;dt;blank$f;ball_m$f',
        [-1, ID, Integer(ID_Division), Integer(va[i][2]), Integer(va[i][4]), PeriodStartDate, va[i][5], va[i][6]],
        False
      );
  end;
  if Length(va) > 0 then begin
    Q.QExecSql('update payroll set id_method = (select id_method from payroll where id_division = :id_division$i and dt1 = :dt1$d and id_worker is null) where id = :id$i',
      [ID_Division, Turv.GetTurvBegDate(IncDay(PeriodStartDate, -1)), ID]
    );
  end;
end;

function TForm_Payroll.GetList: Integer;
//��������� ��������� (��� ������) �� �� � �������� ��� �����
var
  i, j, k: Integer;
  va: TVarDynArray2;
  st, st1, st2, w: string;
  v, v1, v2: Variant;
  buf: Variant;
  changed: Boolean;
  size: Integer;
begin
  //���� ������ ���� ����������� � ��� �� ������� ��� � ��� �������� �������
  va:=Q.QLoadToVarDynArray2(
    'select workername, job, id, id_worker, id_job, null, blank, ball_m, turv, ball, premium_m_src, premium, premium_p, premium_m ,otpusk, bl, penalty, itog1, ud, ndfl, fss, pvkarta, karta, itog '+
    'from v_payroll_item where id_payroll = :id$i order by job, workername',
    [ID]
  );
  //MemTableEh1.Edit;
  for i:=0 to High(va) do begin
    MemTableEh1.Append;
    for j:=0 to High(va[i]) do begin
      MemTableEh1.Fields[j].Value:=va[i][j];
    end;
    MemTableEh1.Post;
  end;
end;

function TForm_Payroll.GetTurvList: Integer;
//������ ������ �� ���� �� ������� ����� ������
var
  i, j, k: Integer;
  va, va1, vadel: TVarDynArray2;
  st, st1, st2, w: string;
  v, v1, v2: Variant;
  buf: Variant;
  changed: Boolean;
  size: Integer;
  e, e1, e2, e3: extended;
  rn : Integer;
  b, b2: Boolean;
begin
  ClearFilter;
  //�������� ���� ����������, �� ������� ������� �� ���� ������ ��������� ���������
  vadel:=Q.QLoadToVarDynArray2(
    'select id_worker from v_payroll where id_worker is not null and dt1 = :dt1$d',
    [PeriodStartDate]
  );
  //������� ������ ���� �� ������, ��������������� �� ���, ����� �� ����
  //0-����1, 1-����2, 2-���� ���������, 3-��� ���������, 4-���� ���������, 5-��������� ���������, 6-����� �������: 1=��������� 2=������
  va:=uTurv.Turv.GetTurvArray(ID_Division, PeriodStartDate, False);
  for i:=0 to High(va) do begin
    SetLength(va[i], 10);
    //�� ������� ��������� (������, �� ������ ������, �� ��� ������ ���������� ��������� ����� �� ������ ���������)
    //������ ������ �� ������� ���� �� ������, ��������� ��� ������ ������
    va1:=Q.QLoadToVarDynArray2(
      'select worktime1, worktime2, worktime3, id_turvcode2, id_turvcode3, premium, penalty from turv_day '+
      'where id_division = :id_division$i and id_worker = :id_worker$i and dt >= :dt1$d  and dt <= :dt2$d',
      [ID_Division, va[i][2], va[i][0], va[i][1]]
    );
    e:=0; e1:=0; e2:=0;
    //�������� �� ���� ����� ��� ������� ������
    for j:=0 to High(va1) do begin
      //���� ���� ������������� ����� ��� ������������� ���, �� ����� ������������� ����� (���� ��� ������������� ���, �� ����� = ����, ���� = 0)
      //���� �� ��� ���, �� ����� ����� �� �������, ��� ����������� ������ ���� (��� ���), � ����������� � ������ ���� ��� ������������
      //����� ������������ ����� �� ���������
      //++��� �������, ��������� ����� ������������, ����� ������ ���������
      if (va1[j][2]<>null) or (va1[j][4]<>null)
        then e:=e + S.NNum(va1[j][2])
        else if (va1[j][1]<>null) or (va1[j][3]<>null)
          then e:=e + S.NNum(va1[j][1])
          else e:=e + S.NNum(va1[j][0]);
      //������ � ������ �� ����
      e1:=e1 + S.NNum(va1[j][5]);
      e2:=e2 + S.NNum(va1[j][6]);
    end;
    //�������� ����� � �������
    va[i][6]:=e;
    va[i][7]:=e1;
    va[i][8]:=e2;
  end;
  //������ ������������� �� ��� ������, ��� ���� ��������� �������� ��� � ����� - ������ �� �������
  i:=0; j:=0; st:='';
  while i < High(va) do begin
    if va[i][3] = st then begin
      //������������ �����
      va[i-1][6]:=va[i-1][6] + va[i][6];
      delete(va, i, 1);
    end
    else begin
      st:=va[i][3];
      inc(i);
    end;
  end;
  //���������� �������
  repeat
    changed := False;
    for k := 0 to High(va) - 1 do
      if va[k][5] > va[k + 1][5] then
      begin
        // �������� k-� � k+1-� ��������
        for j:=0 to High(va[k]) do begin
          buf := va[k][j];
          va[k][j] := va[k + 1][j];
          va[k + 1][j] := buf;
        end;
        changed := True;
      end;
  until not changed;

  //���� ��������� �� ������ ���������, �� ������ �� ������� ���� ���������� ����� �����
  if ID_Worker <> null then begin
    for i:=High(va) downto 0 do begin
      if va[i][2] <> ID_Worker then Delete(va, i, 1);
    end;
  end;

  //������� �� ���� ������ �� ������� ������ (��� ��������� �� ���� ����, �� � ����� ����� ���� ��������� ����� �� ������ ���������, ��� ������� ���������)
  va1:=Q.QLoadToVarDynArray2(
    'select id_worker, sum(premium) from turv_worker where id_division = :id_division$i and dt1 = :dt1$d group by id_worker',
    [ID_Division, PeriodStartDate]
  );
  //�������� �� � ������� � ������� �������
  for i:=0 to High(va1) do begin
    for j:= 0 to High(va) do begin
      if va[j][2] = va1[i][0] then begin
        va[j][9]:=va1[i][1];
        Break;
      end;
    end;
  end;

  //�������� �������

  st:='';   //������ ���������
  b:=False; //������� ��������� �������
  rn:=MemTableEh1.RecNo;
  //������ �� ��������
  i:=1;
  Mth.Post(MemTableEh1); MemTableEh1.Edit;
  //����� ������ � �������!!!
  while i <= MemTableEh1.RecordCount do begin
    MemTableEh1.RecNo:=i;
    //������ �� ������� ����
    b2:=False;
    for j:=0 to High(va) do begin
      if MemTableEh1.FieldByName('name').AsString = va[j][3] then begin
        MemTableEh1.Edit;
        if MemTableEh1.FieldByName('job').AsString <> va[j][5] then begin
          MemTableEh1.FieldByName('job').Value:=va[j][5];
          MemTableEh1.FieldByName('changed').Value:=1;
          st:=st + va[j][3] + ': �������� ���������.'#13#10;
          b:=True;
        end;
        if MemTableEh1.FieldByName('turv').AsVariant <> Round(va[j][6]) then begin
          if MemTableEh1.FieldByName('turv').AsVariant <> null
            then st:=st + va[j][3] + ': ������� ������� ���� � ' + MemTableEh1.FieldByName('turv').AsString + ' �� ' + VarToStr(Round(va[j][6])) + #13#10;
          MemTableEh1.FieldByName('turv').Value:=Round(va[j][6]);
          MemTableEh1.FieldByName('changed').Value:=1;
          b:=True;
        end;
        if MemTableEh1.FieldByName('premium').AsVariant <> S.NullIf0(va[j][7]) then begin
          if MemTableEh1.FieldByName('premium').AsVariant <> null
            then st:=st + va[j][3] + ': ������� ������� ������� ������ � ' + MemTableEh1.FieldByName('premium').AsString + ' �� ' + VarToStr(va[j][7]) + #13#10;
          MemTableEh1.FieldByName('premium').Value:=S.NullIf0(va[j][7]);
          MemTableEh1.FieldByName('changed').Value:=1;
          b:=True;
        end;
        if (CalcMode = 10) then begin
          v2:=Round(S.NNum(va[j][9]) / extended(Norma) * Min(S.NNum(va[j][6]), extended(Norma)));
          if (MemTableEh1.FieldByName('premium_m_src').AsVariant <> S.NullIf0(v2)) then begin
            if MemTableEh1.FieldByName('premium_m_src').AsVariant <> null
              then st:=st + va[j][3] + ': ������� ������� ������*  � ' + MemTableEh1.FieldByName('premium_m_src').AsString + ' �� ' + VarToStr(v2) + #13#10;
            MemTableEh1.FieldByName('premium_m_src').Value:=S.NullIf0(v2);
            MemTableEh1.FieldByName('changed').Value:=1;
            b:=True;
          end;
        end;
        if MemTableEh1.FieldByName('penalty').AsVariant <> S.NullIf0(va[j][8]) then begin
          if MemTableEh1.FieldByName('penalty').AsVariant <> null
            then st:=st + va[j][3] + ': ������� ������� ������ � ' + MemTableEh1.FieldByName('penalty').AsString + ' �� ' + VarToStr(va[j][8]) + #13#10;
          MemTableEh1.FieldByName('penalty').Value:=S.NullIf0(va[j][8]);
          MemTableEh1.FieldByName('changed').Value:=1;
          b:=True;
        end;
        MemTableEh1.Post;
        MemTableEh1.Edit;
        //������� ��� ��� ������ ���� ��������� � ����
        va[j][0]:=-1;
        b2:=True;
        Break;
      end;
    end;
    if b2
      then inc(i)
      else begin
        //� ������ ��������� ����������
        st:=st + MemTableEh1.FieldByName('name').AsString + ': �������� ������ �� ���������.'#13#10;
        DeletedWorkers:=DeletedWorkers + [MemTableEh1.FieldByName('id_worker').AsInteger];
        MemTableEh1.Edit;
        MemTableEh1.Delete;
        MemTableEh1.Post;
        MemTableEh1.Edit;
//        st:=st + va[j][3] + ': �������� ������ �� ���������.'#13#10;
        //� ������ ��������� ����������
//        DeletedWorkers:=DeletedWorkers + [va[j][2]];
        b:=True;
      end;
  end;
  //������� � ������� ��� ����������, ������� �� ���� ������� � ���������
  for j:=0 to High(va) do
    if va[j][0] <> -1 then begin
      //���������, �� ������ �� ��� ������� ��������� �������������� ��������� �� ������ ������
      b2:=False;
      for k:=0 to High(vadel) do
        if vadel[k][0] = va[j][2] then begin
          b2:=True;
          Break;
        end;
      //�������, ��������� ����
      if b2 then continue;
      //����� ������� � ����� ����
      MemTableEh1.Edit;
      MemTableEh1.Append;
      MemTableEh1.FieldByName('id_worker').AsString:=va[j][2];
      MemTableEh1.FieldByName('name').AsString:=va[j][3];
      MemTableEh1.FieldByName('turv').Value:=va[j][6];
      MemTableEh1.FieldByName('id_job').AsString:=va[j][4];
      MemTableEh1.FieldByName('job').Value:=va[j][5];
      MemTableEh1.FieldByName('changed').Value:=1;
      MemTableEh1.Post;
      MemTableEh1.Edit;
      st:=st + va[j][3] + ': �������� �������� � ���������.'#13#10;
      b:=True;
    end;
  //������ ������� � �����MemTableEh1.RecNo:=rn;
  //����������� �������
  CalculateAll;
  DBGridEh1.SetFocus;
  //������� ���������
  MyInfoMessage('���� ��������.'#13#10#13#10 + S.IIFStr(b = False, '��������� �� ����.', st));
  CheckEmpty;
end;

procedure TForm_Payroll.CheckEmpty;
//���������, �� ������ �� ������
//���� ������, �� ��������� ����� ��������������, � ��� ����� ������ � ���������� ����, ��� �������� ������
//�������� ����� ���������� ������ ����� ��������� ����
//� ���� ������ ��������� ��������� �� �����, � �� ����� ����� ������ �������
begin
  if MemTableEh1.RecordCount <> 0 then Exit;
  Mode:=fView;
  IsEditable:=False;
  MyInfoMessage('��� ���� ��������� �� ������� �� ���� ������! �� �� ������ ������������� ��� ���������, � ������ ������� ��!');
  SetButtons;
end;



procedure TForm_Payroll.MemTableEh1AfterScroll(DataSet: TDataSet);
begin
  inherited;
  MemTableEh1.Edit;
end;

function TForm_Payroll.Save: Integer;
begin

end;


procedure TForm_Payroll.DBGridEh1Columns0GetCellParams(Sender: TObject;
  EditMode: Boolean; Params: TColCellParamsEh);
var
  st: string;
  color, r, d: Integer;
  dt: TDateTime;
  b: Boolean;
begin
  if InPrepare then Exit;
  Params.ReadOnly:=False;
  if
    (Mode = fView) or (Norma = null) or (CalcMode = null) or Commit or
    (A.InArray(TColumnEh(Sender).FieldName, ['pos','name','job','itog1','itog','turv', S.IIf(CalcMode <> 15, 'ball', ''),'premium','premium_m_src','premium_p','penalty'])) or
//    ((TColumnEh(Sender).FieldName = 'ball_m')and(CalcMode = 1)) or
//    ((TColumnEh(Sender).FieldName = 'ball')and(CalcMode = 0)) or
    (not IsEditable)
    then begin
      //��� ��������������� ����
      Params.ReadOnly:=True;
      Params.TextEditing:=False;
    end;
    //��������� ������������� �����
    if TColumnEh(Sender).FieldName = 'itog' then
      if MemTableEh1.FieldByName('itog').AsFloat < 0
        then Params.Background:=clRed
        else Params.Background:=clWhite;
  inherited;
end;

procedure TForm_Payroll.DBGridEh1Columns0UpdateData(Sender: TObject;
  var Text: string; var Value: Variant; var UseText, Handled: Boolean);
var
  st: string;
  i,j: Integer;
begin
  inherited;
  if InPrepare then Exit;
  if A.InArray(TColumnEh(Sender).FieldName, ['changed']) then Exit;
  //��������� �������, ��� ������ � ������ ����������
  MemTableEh1.FieldByName('changed').Value:=1;
  //� ������ ������� ��������� ������ - �������
  if UseText then st:=Text else st:=VarToStr(Value);
  if (st<>'') and (not S.IsNumber(st, 0, 9999999))
    then begin
      Value:=null;
      Handled:=True;
    end;
  //����������� - ����������� ����, ����� � ������� ����� �������� ������� ��������
  MemTableEh1.post;
  MemTableEh1.edit;
//MyInfoMessage(inttostr(MemTableEh1.RecNo));
  //���������� ������, � ������� ����� ���������� ������
  RecNoCh:=MemTableEh1.RecNo;
  Timer_AfterUpdate.Enabled:=True;
  //��-��������, ���� ����� ��� � �������, �� � ������� �� ����� �������� ���������� ��������
  //CalculateRow(DBGridEh1.Row-1);
end;

procedure TForm_Payroll.DBGridEh1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
  if Key = vk_F7 then PrintLabels;
end;

function TForm_Payroll.IsChanged: Boolean;
var
  rn, i: Integer;
begin
  Result:= (Length(DeletedWorkers) > 0);
  if Result then Exit;
  rn:=MemTableEh1.RecNo;
  for i:=1 to MemTableEh1.RecordCount do begin
    MemTableEh1.RecNo:=i;
    if MemTableEh1.FieldByName('changed').AsVariant = 1 then Result:=True;
  end;
  MemTableEh1.RecNo:=rn;
end;


procedure TForm_Payroll.FormClose(Sender: TObject; var Action: TCloseAction);
var
  rn, i, res: Integer;
  changed: Boolean;
begin
  //������, ���� �������� ���������� ��� ���������� ������, ��������, ��-�� ��������� ����������
//if InPrepare or not IsEditable then Exit;
  if InPrepare then Exit; //�� ����� ����� ���� ���  or not IsEditable
  ClearFilter;
  if IsChanged then begin
    res:=myMessageDlg('���������� ��������� ���� ��������!'#13#10'��������� ������?', mtConfirmation, mbYesNoCancel);
    if res = mrYes then begin
      SavePayroll;
      RefreshParentForm;
    end
    else if res = mrCancel then begin
      Action:=caNone;
      Exit;
    end;
  end;
  inherited;
  Settings.SaveWindowPos(Self, FormDoc +'_' + IntToStr(ID_Division) +'_' + VarToStr(ID_worker));
end;

procedure TForm_Payroll.FormShow(Sender: TObject);
begin
  inherited;
  //��������������� ������� � ��������� ����, ���� ������� ��������� � ��
  //��� ��� � ������� ������ ������ ������ ���� ���������� �� formdoc
  Settings.RestoreWindowPos(Self, FormDoc +'_' + IntToStr(ID_Division) +'_' + VarToStr(ID_worker));
end;

procedure TForm_Payroll.BitBtn1Click(Sender: TObject);
begin
  inherited;
MemTableEh1.Delete; //MemTableEh1.Edit;
end;

procedure TForm_Payroll.Bt_SettingsClick(Sender: TObject);
var
  i,j,rn:Integer;
  st: string;
begin
  inherited;
//  CalculateRow(0);
//MemTableEh1.Edit;
DBGridEh1.setfocus;
             st:='';
  i:=1;
  while i < MemTableEh1.RecordCount +1 do begin
    MemTableEh1.RecNo:=i;
    st:=st+MemTableEh1.FieldByName('name').AsString + #13#10;
    inc(i);
  end;
MyInfoMessage(st);

end;

procedure TForm_Payroll.CalculateAll;
var
  i,j,rn:Integer;
begin
  rn:=MemTableEh1.RecNo;
  for i:=1 to MemTableEh1.RecordCount do begin
    MemTableEh1.RecNo:=i;
    MemTableEh1.Edit;
    CalculateRow(i);
    MemTableEh1.Post;
    MemTableEh1.Edit;
  end;
  MemTableEh1.RecNo:=rn;
  //DBGridEh1.setfocus;
end;



function TForm_Payroll.Prepare: Boolean;
var
  i, j, w1: Integer;
  v: Variant;
begin
  Result:=False;

  if FormDbLock = fNone then Exit;

  v:=Q.QSelectOneRow('select id, id_division, id_worker, dt1, dt2, divisionname, workername, office, id_method, commit from v_payroll where id = :id$i', [id]);
  if v[0] = null then Exit;
  ID_Division:=v[1];
  ID_Worker:=v[2];
  PeriodStartDate:=v[3];
  PeriodEndDate:=v[4];
  DivisionName:=S.NSt(v[5]);
  WorkerName:=S.NSt(v[6]);
  IsOffice:=v[7] = 1;;
  CalcMode:=v[8];
  Commit:=v[9] = 1;

  lbl_Caption1.Caption:=S.IIf(WorkerName<>'', WorkerName + ' (' + DivisionName + ')', DivisionName) + ' � ' +DateToStr(PeriodStartDate) + ' �� ' +DateToStr(PeriodEndDate);
  IsEditable:=Mode = fEdit;
//  lbl_ReadOnly.Visible:=IsEditable;

  Norma01:=Q.QSelectOneRow('select norm0, norm1 from payroll_norm where dt = :dt$d', [PeriodStartDate]);
  Norma:=S.IIf(IsOffice, Norma01[1], Norma01[0]);

  DeletedWorkers:=[];

  ColWidth:=45;
  MemTableEh1.FieldDefs.Clear;
  Mth.AddTableColumn(DBGridEh1, 'name', ftString, 400, '���', 200, True);
  Mth.AddTableColumn(DBGridEh1, 'job', ftString, 400, '���������', 150, True);
  Mth.AddTableColumn(DBGridEh1, 'id', ftInteger, 0, '_id', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'id_worker', ftInteger, 0, '_id_worker', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'id_job', ftInteger, 0, '_id_job', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'changed', ftInteger, 0, '_changed', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'blank', ftInteger, 0, '  � ������', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'ball_m', ftInteger, 0, '  �����', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'turv', ftFloat, 0, '  ����', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'ball', ftInteger, 0, '  ������' + sLineBreak + '  ������', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'premium_m_src', ftInteger, 0, '  ������ ' + sLineBreak + '  (��������)', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'premium', ftInteger, 0, '  ������' + sLineBreak + '  �������', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'premium_p', ftInteger, 0, '  ������ ��' + sLineBreak + '  �����������', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'premium_m', ftInteger, 0, '  ������' + sLineBreak + '', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'otpusk', ftInteger, 0, '  ��', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'bl', ftInteger, 0, '  ��', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'penalty', ftInteger, 0, '  ������', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'itog1', ftInteger, 0, '  �����' + sLineBreak + '  ���������', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'ud', ftInteger, 0, '  ��������', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'ndfl', ftInteger, 0, '  ����', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'fss', ftInteger, 0, '  ���������' + sLineBreak + '  ���', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'pvkarta', ftInteger, 0, '  �������������' + sLineBreak + '  ������� - �����', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'karta', ftInteger, 0, '  �����', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'itog', ftInteger, 0, '  ����� �' + sLineBreak + '  ���������', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'sign', ftInteger, 0, '  �������', ColWidth + 10, True);
//  Mth.AddTableColumn(DBGridEh1, '', ftInteger, 0, '', ColWidth, True);
  MemTableEh1.CreateDataSet;

  for i:=0 to DBGridEh1.Columns.Count-1 do begin
    if (i <= 7) then DBGridEh1.Columns[i].Color:=RGB(200,200,200);
    if (i >= 3) then DBGridEh1.Columns[i].Alignment:=taRightJustify;
    if (i >= 3) then DBGridEh1.Columns[i].Title.Orientation:=tohVertical;
    if (i > 7) then DBGridEh1.Columns[i].DisplayFormat:='###,###,###';
    DBGridEh1.Columns[i].Title.Alignment:=taCenter;
    DBGridEh1.Columns[i].OnGetCellParams:= DBGridEh1Columns0GetCellParams;
    DBGridEh1.Columns[i].OnUpdateData:= DBGridEh1Columns0UpdateData;
    if (DBGridEh1.Columns[i].Title.Caption[1] ='_') then DBGridEh1.Columns[i].Visible:=False;
  end;

//  Gh.GetGridColumn(DBGridEh1, 'turv').DisplayFormat:='###,###,###.00';
  Gh.GetGridColumn(DBGridEh1, 'sign').Visible:=False;


  DBGridEh1.Columns[0].Visible:=False;

//  DBGridEh1.Columns[6].Local:=True;

//  Gh._SetDBGridEhDisplayFormat(DBGridEh1, 'ball;itog1;itog', FloatDisplayFormat);
  //Gh._SetDBGridEhSumFooter(DBGridEh1, 'premium_m;premium;premium_p;otpusk;bl;itog1;ud;ndfl;fss;pvkarta;karta;itog', '###,###,##0');
  Gh.SetGridColumnsProperty(DBGridEh1, cptSumFooter, 'premium_m;premium;premium_p;otpusk;bl;itog1;ud;ndfl;fss;pvkarta;karta;itog', '###,###,##0');
  Gh.SetGridOptionsTitleAppearance(DBGridEh1, True);
//  Gh.SetGridOptionsTitleAppearance(DBGridEh1, False);
  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh+[dghShowRecNo];
  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh+[dghEnterAsTab];
  DBGridEh1.ShowHint:=True;
  DBGridEh1.ColumnDefValues.ToolTips:=True;
  DBGridEh1.TitleParams.RowHeight:=90;
  //DBGridEh1.TitleParams.MultiTitle:=True;
 //����������� ��������
  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh-[dghColumnMove];
  //��������� ������ ��������
  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh-[dghColumnResize];
  DBGridEh1.FixedColor:=RGB(200,200,200);
//  DBGridEh1.FrozenCols:=5;
  DBGridEh1.ShowHint:=True;
  DBGridEh1.IndicatorOptions:=[gioShowRowIndicatorEh,gioShowRecNoEh];
  DBGridEh1.ReadOnly:=False;

  DBGridEh1.StFilter.Local:=True;
  DBGridEh1.SortLocal:=True;
  DBGridEh1.STFilter.Visible:=True;
  DBGridEh1.STFilter.Location:=stflInTitleFilterEh;
  for i:=0 to DbGridEh1.Columns.Count - 1 do
    DBGridEh1.Columns[i].STFilter.Visible:=False;
  Gh.GetGridColumn(DBGridEh1, 'blank').STFilter.Visible:=True;
//  DBGridEh1.Columns[7].STFilter.Visible:=True;
//  DBGridEh1.Columns.FindColumnByName('BLANK').STFilter.Visible:=True;


  w1:=75;
  for i:=0 to DBGridEh1.Columns.Count-1 do begin
    if DBGridEh1.Columns[i].Visible then w1:=w1+DBGridEh1.Columns[i].Width;
  end;
  //������ ���� �� ������ �����
  Self.Width:=w1;
  Self.MinWidth:=1100;
  Self.MinHeight:=300;
//  lbl_ReadOnly.Left:=Width - pnl_Right.Width - lbl_ReadOnly.Width - 50;

  //���� � ������ ��������� ��� �� ����� ������, ��������� �� �������
  CreateTurvList;
  //��������� �� �� ���������
  GetList;


//norma:=56;
//CalcMode:=0;

  DBGridEh1.AllowedOperations:=[alopUpdateEh];

//  Buttons:=[mybtSettings, mybtDividor, mybtCustom_Turv, mybtCustom_Payroll, mybtCard, mybtDividor, mybtExcel, mybtPrint, mybtPrint, mybtPrintLabel, mybtDividor, mybtLock];
  Buttons:=[mybtSettings, mybtDividor, mybtCustom_Turv, mybtCustom_Payroll, mybtCard, mybtDividor, mybtExcel, mybtDividorM, mybtPrint, mybtPrint, mybtPrintLabels, mybtDividorM, mybtDividor, mybtLock];
  ButtonsState:=[True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True];
  pnl_Left.Width:=Cth.CreateGridBtns(Self, pnl_Left, Buttons, ButtonsState, Bt_Click) + 5;
  Cth.GetSpeedBtn(pnl_Left, mbtCard).Hint:='��������� ���� � �����';
  SetButtons;
  CheckEmpty;

  //��������� ����������� ����������� ������ � ����������� �� ������� ������ � �������
//  Cth.SetBtnAndMenuEnabled(pnl1, Pm_Grid, mbtView, IsNotEmpty);


  Result:=True;
end;

constructor TForm_Payroll.ShowDialog(aOwner: TComponent; aFormDoc: string; aMode: TDialogType; aID: Variant; AMyFormOptions: TMyFormOptions);
begin
  inherited Create(aOwner, aFormDoc, AMyFormOptions, aMode, aID, null);
end;

//���� �� ������ ������ ����� ��� �� ������ ����������� ���� �� ������
procedure TForm_Payroll.Bt_Click(Sender: TObject);
var
  BtnTag: Integer;
  rn, i: Integer;
begin
  if Sender is TSpeedButton then
    if TSpeedButton(Sender).Enabled
      then BtnTag:=Integer(TSpeedButton(Sender).tag);
  if Sender is TMenuItem then
    if TMenuItem(Sender).Enabled
      then BtnTag:=Integer(TMenuItem(Sender).tag);
  case BtnTag of
    mbtCustom_Turv:
      if MyQuestionMessage('��������� ������ �� ����?') = mrYes then GetTurvList;
    mbtCustom_Payroll:
      if MyQuestionMessage('��������� ������ ������?') = mrYes then GetXlsData;
    mbtCard:
      if MyQuestionMessage('��������� ���� � �����?') = mrYes then GetNdfl;
    mbtSettings:
      PayrollSettings;
    mbtExcel:
      ExportToXlsxA7;
//      ClearFilter;
    mbtPrint:
      PrintGrid;
    mbtPrintLabels:
      PrintLabels;
    mbtLock:
      CommitPayroll;
  end;
end;


procedure TForm_Payroll.Timer_AfterUpdateTimer(Sender: TObject);
//��������� ������, � ������� ��� ����, � �������, �� �� �������� �� �������
//� ���������� ���������� ���������� ����� ������ � ��������, � ������� ���� ���������, �� ������� ����� ���
//����� ���� �� ���, � ������� �������, ���� ����� ����� ������ ������� ����� ��� ����
var
  rn: Integer;
begin
  inherited;
  Mth.Post(MemTableEh1);
  Timer_AfterUpdate.Enabled:=False;
  rn:=MemTableEh1.RecNo;
  if MemTableEh1.RecNo <> RecNoCh then MemTableEh1.RecNo:=RecNoCh;
  MemTableEh1.Edit;
  CalculateRow(RecNoCh);
  Mth.Post(MemTableEh1);
  if MemTableEh1.RecNo <> rn then MemTableEh1.RecNo:=rn;
end;


procedure TForm_Payroll.SetButtons;
begin
  if Mode = fView
    then begin
      lbl_Info.Caption:='������ ��������.';
      lbl_Info.Font.Color:=clBlack;
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtSettings, False);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtCustom_Turv, False);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtCustom_Payroll, False);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtCard, False);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtLock, False);
    end
    else if (Norma = null) or (CalcMode = null) then begin
      lbl_Info.Caption:='������� ���������!';
      lbl_Info.Font.Color:=clRed;
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtSettings, True);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtCustom_Turv, False);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtCustom_Payroll, False);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtCard, False);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtLock, False);
    end
    else if Commit then begin
      lbl_Info.Caption:='��������� �������, ������ ��������.';
      lbl_Info.Font.Color:=clGreen;
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtSettings, False);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtCustom_Turv, False);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtCustom_Payroll, False);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtCard, False);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtLock, True);
    end
    else begin
      lbl_Info.Caption:='���� ������.';
      lbl_Info.Font.Color:=RGB(255, 0, 255);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtSettings, True);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtCustom_Turv, True);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtCustom_Payroll, Integer(CalcMode) in [13, 14]);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtCard, True);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtLock, True);
    end;
  Cth.GetSpeedBtn(pnl_Left, mbtLock).Hint:=S.IIf(Commit, '�������� �������� ���������', '������� ���������');
  SetColumns;
end;


procedure TForm_Payroll.PayrollSettings;
var
  va1, va2: TVarDynArray;
  n: Variant;
  rn, i: Integer;
begin
  //��������� ���������
  va1:=[Norma01[0], Norma01[1], CalcMode];
  va2:=Copy(va1);
  n:=S.IIf(IsOffice, Norma01[1], Norma01[0]);
  //���������� mrYes ���� ������ ���� ���������
  if Dlg_PayrollSettings.ShowDialog(va2) <> mrYes then Exit;
  Norma01[0]:=va2[0];
  Norma01[1]:=va2[1];
  CalcMode:=va2[2];
  Norma:=S.IIf(IsOffice, Norma01[1], Norma01[0]);
  if (va1[0] <> va2[0]) or (va1[1] <> va2[1])  then begin
    //�������� � ������� ��� �����
    if Q.QselectOneRow('select count(*) from payroll_norm where dt = :dt$d', [PeriodStartDate])[0] = 0
      then Q.QExecSql('insert into payroll_norm (dt) values (:dt$d)', [PeriodStartDate]);
    Q.QExecSql('update payroll_norm set norm0 = :norm0$f, norm1 = :norm1$f where dt = :dt$d', [Norma01[0], Norma01[1], PeriodStartDate]);
  end;
  //(� ����� ������� ����������� ��� ���������� ���������)
  //���� ���� �� ���-�� ���������� (�������� �� ������ ���� ����� ������ ���������� � �����, � ����� �� ���� ����������� ���������� ��� ����������)
  if not((n <> Norma) or (va1[2] <> va2[2])) then Exit;
  //������� �����, ������ � ������ (����� ������ �� ������, ������� �������� ������ �������)
  rn:=MemTableEh1.RecNo;
  for i:=1 to MemTableEh1.RecordCount do begin
    MemTableEh1.RecNo:=i;
    MemTableEh1.Edit;
    MemTableEh1.FieldByName('ball').Value:=null;
    MemTableEh1.FieldByName('turv').Value:=null;
    MemTableEh1.FieldByName('premium').Value:=null;
    MemTableEh1.FieldByName('premium_m_src').Value:=null;
    MemTableEh1.FieldByName('premium_p').Value:=null;
    MemTableEh1.FieldByName('penalty').Value:=null;
    MemTableEh1.FieldByName('changed').Value:=1;
    MemTableEh1.Post;
    MemTableEh1.Edit;
  end;
  MemTableEh1.RecNo:=rn;
  //����������� ���������
  CalculateAll;
  SetButtons;
end;



procedure TForm_Payroll.GetXlsData;
var
  i, j, k, emp: Integer;
  va, va1, vadel: TVarDynArray2;
  st, st1, st2, w, FileName, err, fio: string;
  v, v1, v2: Variant;
  buf: Variant;
  changed: Boolean;
  size: Integer;
  e, e1, e2, e3: extended;
  rn : Integer;
  b, b2, res: Boolean;
  XlsFile:TXlsMemFileEh;
  cr: IXlsFileCellsRangeEh;
  sh, sh1: TXlsWorksheetEh;
  cStart, cFIO, cSum : Integer;
  Files: TStringDynArray;
  SR:TSearchRec;
  FindRes:Integer;
  sl: TStrings;
const
  ccStart = 2;
  crSheet = 6;
  crFIO = 7;
  crSum = 9;
  cstMarker ='���� ������';
begin
  res:= False;
  st:='';   //������ ���������
  b:=False; //������� ��������� �������
  b2:=False; //������� ������� ������������� �������
  err:='���� ������� ������ �� ������!';
  FileName:='';
  ClearFilter;
  repeat
  sl:=TStringList.Create;
  //������� ������ ���� ������ � �������� �� ��������
  Sys.GetFilesInDirectoryRecursive(Module.GetCfgVar(mycfgWpath_to_payrolls), sl);
  //������ ��, �������� ���� ���� ���� "���� 1/������ 1.xlsx"
  for i:=0 to sl.Count - 1 do begin
    if pos(MonthsRu[MonthOf(PeriodStartDate)] + ' ' + S.IIFStr(DayOf(PeriodStartDate) = 1, '1', '2') + '\' + DivisionName + '.xlsm', sl[i]) > 0
      then FileName:= sl[i];
  end;
  sl.Free;
{  try
  Files:=TDirectory.GetFiles(Module.W_PayrollPath + '\' + MonthsRu[MonthOf(PeriodStartDate)] + ' ' + S.IIFStr(DayOf(PeriodStartDate) = 1, '1', '2'), DivisionName + '.xlsm');
  except
    err:='���� ������� ������ �� ������!';
    Break;
  end;
  FileName:=Files[0];}
{  FindRes:=FindFirst(Module.W_PayrollPath + '\' + MonthsRu[MonthOf(PeriodStartDate)] + '?' + S.IIFStr(DayOf(PeriodStartDate) = 1, '1', '2') + '\' + DivisionName +'.*',//+ '.xlsm',
    faAnyFile, SR);
  while findres = 0 do
    begin
      FileName:=SR.Name;
      FindRes:=FindNext(SR);
      Break;
    end;
  FindClose(SR);}
  if FileName = '' then Break;
  err:='���� "' + FileName + '" �� �������� ������ ������� ������';
  if not CreateTXlsMemFileEhFromExists(FileName, True, '$2', XlsFile, st) then Exit;
  try
    sh1:=xlsFile.Workbook.Worksheets['=']; //������� ����� ��������!
    if sh1.Cells[ccStart - 1, crSheet - 1].Value <> cstMarker then Break;
    cFIO:=sh1.Cells[ccStart, crFio - 1].Value;
    cSum:=sh1.Cells[ccStart, crSum - 1].Value;
    st1:=sh1.Cells[ccStart, crSheet - 1].Value;
    for i:=0 to 100 do begin
      if Trim(UpperCase(XlsFile.Workbook.Worksheets[i].Name)) = Trim(UpperCase(st1)) then begin
        sh:=XlsFile.Workbook.Worksheets[i];
//        st1:=XlsFile.Workbook.Worksheets[i].Name;
        Break;
      end;
    end;
    err:='��� �������� ���� ������!';
    //�������� �������
    rn:=MemTableEh1.RecNo;
    //������ �� ��������
    i:=1;
    Mth.Post(MemTableEh1); MemTableEh1.Edit;
    //����� ������ � �������!!!
    while i <= MemTableEh1.RecordCount do begin
      MemTableEh1.RecNo:=i;
      fio:=MemTableEh1.FieldByName('name').AsString;
      emp:=0;
      j:=0;
      st1:='';
      while emp < 300 do begin
        st1:=S.NSt(sh.Cells[cFIO - 1, j].Value);
        if st1 = ''
          then inc(emp)
          else if st1 = fio
            then Break
            else emp:=0;
        inc(j);
      end;
      if st1 = fio then begin
        e:=Round(sh.Cells[cSum - 1, j].Value);
        if MemTableEh1.FieldByName('ball').AsVariant <> e then begin
          if MemTableEh1.FieldByName('ball').AsVariant <> null
            then st:=st + fio + ': ������� ������� ����� � ' + MemTableEh1.FieldByName('ball').AsString + ' �� ' + VarToStr(e) + #13#10;
          MemTableEh1.FieldByName('ball').Value:=e;
          MemTableEh1.FieldByName('changed').Value:=1;
          MemTableEh1.Post;
          MemTableEh1.Edit;
          b:=True;
        end;
      end
      else begin
        st:=st + fio + ': �� ������ � ����� ������� ������!' + #13#10;
        b2:=True;
        //!!!���� �� �������� �����?
      end;
      inc(i);
    end;
  except
    Break;
  end;
  sh.Free;
  sh1.Free;
  res:=True;
  err:='';
  until True;
  if XlsFile<> nil then XlsFile.Free;
  if (err <> '')and(not res) then MyWarningMessage(err);
//  if not b then Exit;
  //������ ������� � �����MemTableEh1.RecNo:=rn;
  //����������� �������
  CalculateAll;
  DBGridEh1.SetFocus;
  //������� ���������
  if b or b2
    then MyInfoMessage('����� ���������' + S.IIf(b2, ', ������ �� ��� ��������� �������!', '.') + #13#10#13#10 + S.IIFStr(not b and not b2, '��������� �� ����.', st));
  CheckEmpty;
end;

procedure TForm_Payroll.ClearFilter;
var
  st: string;
begin
st:=Gh.GetGridColumn(DBGridEh1, 'blank').STFilter.ExpressionStr;
  Gh.GetGridColumn(DBGridEh1, 'blank').STFilter.ExpressionStr:='';
  DBGridEh1.DefaultApplyFilter;
  MemTableEh1.Edit;
end;

procedure TForm_Payroll.PrintDBGridEh1AfterPrint(Sender: TObject);
begin
  inherited;
  {Gh.GetGridColumn(DBGridEh1, 'blank').Visible:=True;
  Gh.GetGridColumn(DBGridEh1, 'sign').Visible:=False;
  Gh.SetGridOptionsTitleAppearance(DBGridEh1, True);}
end;

procedure TForm_Payroll.PrintDBGridEh1BeforePrint(Sender: TObject);
begin
  inherited;
{  PrintDBGridEh1.Options:=PrintDBGridEh1.Options - [pghFitGridToPageWidth];
  PrintDBGridEh1.Options:=PrintDBGridEh1.Options + [pghFitGridToPageWidth];
//  PrintDBGridEh1.}

end;

procedure TForm_Payroll.Timer_PrintTimer(Sender: TObject);
begin
  inherited;
  PrintDBGridEh1.Preview;
  Timer_Print.Enabled:=False;
end;


procedure TForm_Payroll.PrintLabels;
//������ �������� �� ��������  //���� �� F7
begin
  if MyQuestionMessage('���������� ��������?') <> mrYes then Exit;
  PrintReport.pnl_PayrollLabels(MemTableEh1);
end;

procedure TForm_Payroll.PrintGrid;
//������ �����
var
  BeforeGridText:TStringsEh;
  i, j, rn: Integer;
  ar: TVarDynArray;
begin
  Gh.GetGridColumn(DBGridEh1, 'blank').Visible:=False;
  Gh.GetGridColumn(DBGridEh1, 'sign').Visible:=True;
  rn:=MemTableEh1.RecNo;
  ar:=[];
  SetLength(ar, MemTableEh1.Fields.Count + 2);
  //��� �� ����� ������ �������, ������� �� ����� ������ �� � ����� ������
  {
  MemTableEh1.DisableControls;
  for i:=1 to MemTableEh1.RecordCount do begin
    MemTableEh1.RecNo:=i;
    for j:=6 to MemTableEh1.Fields.Count - 1 do
      if MemTableEh1.Fields[j].Value <> null
        then ar[j+1]:=1;
  end;
  MemTableEh1.RecNo:=rn;
  MemTableEh1.EnableControls;
  for i:=DbGridEh1.Columns.count - 3 downto 8 do begin
    if (DbGridEh1.Columns[i].Visible) and (ar[i] <> 1) then begin
      DbGridEh1.Columns[i].Visible:=False;
      ar[i] := 2;
    end;
  end;
  }
  Gh.SetGridOptionsTitleAppearance(DBGridEh1, False);
  //Title ������������ ������ ������, ������ ������ ������ �������, �� ������ ������ ���������� �� ������, ��� ���������.
//  PrintDBGridEh1.Title.Clear;  PrintDBGridEh1.Title[0]:=lbl_Caption1.Caption;
  //���������� BeforeGridText - ��������������� ������
  //���������� ������ ������ ����� � ���������, ���� ��������������� ������, � ����� �� ��������
//  PrintDBGridEh1.BeforeGridText.Clear; PrintDBGridEh1.BeforeGridText.Delete(0);
//  DBGridEh1.Repaint;
//  i:=Gh.GetGridColumn(DBGridEh1, 'name').Width;
//  Gh.GetGridColumn(DBGridEh1, 'name').Width:=1800;
//  PrintDBGridEh1.Options:=PrintDBGridEh1.Options - [pghFitGridToPageWidth];
  PrintDBGridEh1.BeforeGridText[0]:=lbl_Caption1.Caption;
  //��������� ����������
  PrinterPreview.Orientation := poLandscape;
  //������������ ��� ������� ��� �������� �� ��������
  //�� ���� ������� ������ ������ ��������, �� ��� �� �����������!!!
  PrintDBGridEh1.Options:=PrintDBGridEh1.Options + [pghFitGridToPageWidth];
//  Gh.GetGridColumn(DBGridEh1, 'name').Width:=i;
  //������� ���� ������������� (� ������)
  //��� ��� ����� �� ���������������, � ������� ��� ������� ���������� ����� ����� � ��������, �� ��� ������������ �� ���������� ����� ������,
  //��� ������� ����� �������� � ���� ��� �� ������, �� ����� �������� �������, �������� ����� (� ���� ������ ���� ��������� ��� ������)!!!
  //���������� ��������� ������� �� ������� ����� ������ ��� ������, ������������ ������
  PrintDBGridEh1.Preview;
//  Timer_Print.Enabled:=True;

//  PrintDBGridEh1.Options:=PrintDBGridEh1.Options + [pghFitGridToPageWidth];
  //������� ������� �������
//exit;
  for i:=DbGridEh1.Columns.count - 3 downto 80 do
    if ar[i] = 2
      then DbGridEh1.Columns[i].Visible:=True;
//exit;
  Gh.GetGridColumn(DBGridEh1, 'blank').Visible:=True;
  Gh.GetGridColumn(DBGridEh1, 'sign').Visible:=False;
  Gh.SetGridOptionsTitleAppearance(DBGridEh1, True);
end;

procedure TForm_Payroll.ExportToXlsxA7;
var
  i,j,rn,x,y,y1,y2 : Integer;
  Rep: TA7Rep;
  FileName:string;
begin
  FileName:='���������� ���������';
  FileName:=Module.GetReportFileXlsx(FileName);
  if FileName = '' then Exit;
  Rep:= TA7Rep.Create;
  try
    Rep.OpenTemplate(FileName);
  except
    Rep.Free;
    Exit;
  end;
  Rep.PasteBand('HEADER');
  Rep.SetValue('#TITLE#',lbl_Caption1.Caption);
  rn:=MemTableEh1.RecNo;
  for j:=0 to MemTableEh1.Fields.Count - 1 do begin
    Rep.ExcelFind('#d' + IntToStr(j) + '#', x, y, xlValues);
    if x >= 0 then Rep.TemplateSheet.Columns[x].Hidden:=not DBGridEh1.Columns[j+1].Visible;
    Rep.SetValue('#d' + IntToStr(j) + '#', DBGridEh1.Columns[j+1].Title.Caption);
  end;
  Rep.ExcelFind('  � ������', x, y, xlValues);
  if x > -1 then Rep.TemplateSheet.Columns[x].Hidden:=True;
  y1:=-1;
  for i:=1 to MemTableEh1.RecordCount do begin
    MemTableEh1.RecNo:=i;
    Rep.PasteBand('TABLE');
    Rep.ExcelFind('#N#', x, y2, xlValues);
    if y1=-1 then y1:=y2;
    Rep.SetValue('#N#', IntToStr(i));
    for j:=0 to MemTableEh1.Fields.Count - 1 do
      Rep.SetValue('#d' + IntToStr(j) + '#', MemTableEh1.Fields[j].AsString);
  end;
  MemTableEh1.RecNo:=rn;
  Rep.PasteBand('FOOTER');
  if (y1>-1) and (y2 > -1) then
    for j:=0 to MemTableEh1.Fields.Count - 1 do
      Rep.SetSumFormula('#d' + IntToStr(j) + '#', y1, y2);
  Rep.DeleteCol1;
  Rep.Show;
  Rep.Free;
end;


procedure TForm_Payroll.SetColumns;
//�������/������ ������� � ����������� �� ������ �������
var
  m: Integer;
begin
  m:=0;
  if CalcMode <> null then m:=Integer(CalcMode);
  Gh.GetGridColumn(DBGridEh1, 'ball_m').Visible := not (m in [13, 14]);
  Gh.GetGridColumn(DBGridEh1, 'premium_m_src').Visible := (m in [10]);
  Gh.GetGridColumn(DBGridEh1, 'premium_p').Visible := (m in [10]);
end;

procedure TForm_Payroll.CommitPayroll;
begin
  if MyQuestionMessage(S.IIf(Commit, '����� ������ "�������" ��� ���������?', '��������� ������ "�������" ��� ���������?')) <> mrYes then exit;
  Commit:=not Commit;
  SetButtons;
  try
  MemTableEh1.RecNo:=1;
  MemTableEh1.Edit;
  MemTableEh1.FieldByName('changed').Value:=1;
  MemTableEh1.Post;
  MemTableEh1.Edit;
  finally
  end;
end;


procedure TForm_Payroll.CalculateRow(row:Integer);
var
  e1, e2, e3: extended;
  v1, v2, v3: Variant;
  Norma_ : Extended;
begin
{
14	������/������/�������/��������	������ ���, ����� ��������, ������ �� ������ ���
13	������������/���������	������ ���, ����� ��������, ������ �� ������ ���
12	����, ������, ���	�����, ����� �� �����, ������ �� ������ �������
11	��������/��������	�����, ����� ���������, ������ �� ������ �������
10	�������/���������	�����, ����� �� �����, ������ �� �������� ������ (�������), ������ �� ����������� (�������)

premium - ������� ������, �� ���� - ����� ������� ������
premium_m - ������ �� ������, �������� ��������
premium_m_src - ������ ���������
premium_p - ������ �� �����������
(������ �� ������ �� ���� �� ��������, ������ ������ ��� ���������, � ��� �� ��� ���������� ���������)

}
  if Norma = null
    then Norma_:=80 else norma_:=extended(norma);
  e1:=MemTableEh1.FieldByName('ball_m').AsFloat;
  e2:=MemTableEh1.FieldByName('turv').AsFloat;
  //�����, �� ������ �����
  if (CalcMode = 10)or(CalcMode = 12) then begin
    if e2 > Norma_ then e2:= Norma_;
    e3:=e1/Norma_*e2;
  end;
  //�����, ���������
  if (CalcMode = 11) then begin
    e3:=e1/Norma_*e2;
  end;
  //�����, ��������
  if (CalcMode = 13)or(CalcMode = 14)or(CalcMode = 15) then begin
    e3:=MemTableEh1.FieldByName('ball').AsFloat;
  end;
  //��������� �����
  v3:=S.IIf(e3=0, null, round(e3));
  MemTableEh1.FieldByName('ball').Value:=v3;
  //������ �� �����������
  if (CalcMode = 10) then begin
//�� 22-09-23
//    MemTableEh1.FieldByName('premium_p').Value:=Round(Max(0, (e1 + MemTableEh1.FieldByName('premium_m_src').AsFloat) / Norma_ * (MemTableEh1.FieldByName('turv').AsFloat - Norma_) * 1.5));
//� 22-09-23
    MemTableEh1.FieldByName('premium_p').Value:=Round(Max(0, (e1) / Norma_ * (MemTableEh1.FieldByName('turv').AsFloat - Norma_) * 1.5));
  end;
  //��������� ����� �����, �� ����� ���������
  e3:=MemTableEh1.FieldByName('ball').AsFloat + MemTableEh1.FieldByName('premium_m_src').AsFloat + MemTableEh1.FieldByName('premium_p').AsFloat  + MemTableEh1.FieldByName('premium_m').AsFloat + MemTableEh1.FieldByName('premium').AsFloat + MemTableEh1.FieldByName('otpusk').AsFloat + MemTableEh1.FieldByName('bl').AsFloat - MemTableEh1.FieldByName('penalty').AsFloat;
  v3:=S.IIf(e3=0, null, round(e3));
  MemTableEh1.FieldByName('itog1').Value:=v3;
  //��������� ����
  e3:=MemTableEh1.FieldByName('itog1').AsFloat - MemTableEh1.FieldByName('ud').AsFloat - MemTableEh1.FieldByName('ndfl').AsFloat - MemTableEh1.FieldByName('fss').AsFloat - MemTableEh1.FieldByName('pvkarta').AsFloat - MemTableEh1.FieldByName('karta').AsFloat;
  //���� - �������� �� �������� (2024-03-11 ���������� �� �����)
  v3:=S.IIf(e3=0, null, roundto(e3, 2));
  MemTableEh1.FieldByName('itog').Value:=v3;

      //���� ������ ���, �� �������� ����� �������, �������� ������ � ����������, � ������� ���������� ��� ���
      //  e1:=S.NNum(MemTableEh1.RecordsView.MemTableData.RecordsList[row].DataValues['ball_m' ,dvvValueEh]);
      //���� ������ ���, �� �������� � ������������� ������ ����� �� ��������, ���� ���� ������ �����, �� ��� ��� ��������, ���� ������ �� � ������������� ������ � � ������
      //  MemTableEh1.RecordsView.MemTableData.RecordsList[row].DataValues['ball' ,dvvValueEh]:=v3;
//  MemTableEh1.RecordsView.MemTableData.RecordsList[row].DataValues['itog' ,dvvValueEh]:='9999';
      //  Bt_Settings.SetFocus;
      //  DBGridEh1.SetFocus;

end;

procedure TForm_Payroll.GetNdfl;
//�������� �� ������ ������ �� ���� � �����
//� ����� ������ ���������� �� ������ ������, 1� ������� - ���, 2� - ����, ����� - �����
var
  i, j, k, emp: Integer;
  st, st1, st2, w, FileName, err, fio: string;
  v, v1, v2: Variant;
  e, e1, e2, e3: extended;
  rn : Integer;
  b, b2, res: Boolean;
  XlsFile:TXlsMemFileEh;
  cr: IXlsFileCellsRangeEh;
  sh, sh1: TXlsWorksheetEh;
  Files: TStringDynArray;
  sl: TStrings;
  ar: TVarDynArray2;
begin
  FileOpenDialog1.Options:=FileOpenDialog1.Options + [fdoPickFolders];
  if not FileOpenDialog1.Execute then Exit;
  Files:=TDirectory.GetFiles(FileOpenDialog1.FileName, '*.xlsx');

  ClearFilter;

  MemTableEh1.DisableControls;
  SetLength(ar, MemTableEh1.RecordCount + 1);
  rn:=MemTableEh1.RecNo;
  for i:=1 to MemTableEh1.RecordCount do begin
    MemTableEh1.RecNo:=i;
    ar[i]:=[MemTableEh1.FieldByName('name').AsString, 0, 0, 0];
  end;

  for k:= 0 to High(Files) do begin
    if not CreateTXlsMemFileEhFromExists(Files[k], True, '$2', XlsFile, st) then Continue;
    sh:=xlsFile.Workbook.Worksheets[0];
    for i:= 1 to 2000 do begin
      st:=sh.Cells[1 - 1, i].Value;
      if st = '' then Break;
      for j := 1 to High(ar) do begin
        if ar[j][0] = st then begin
          ar[j][1]:=1;
          ar[j][2]:=ar[j][2] + sh.Cells[2 - 1, i].Value;
          ar[j][3]:=ar[j][3] + sh.Cells[3 - 1, i].Value;
        end;
      end;
    end;
    sh.Free;
    XlsFile.Free;
  end;

  st:=''; b:=False; b2:=False;
  for i:=1 to MemTableEh1.RecordCount do begin
    MemTableEh1.RecNo:=i;
    MemTableEh1.Edit;
    if ar[i][1] = 1 then begin
      if MemTableEh1.FieldByName('ndfl').AsVariant <> S.NullIf0(ar[i][2]) then begin
        if MemTableEh1.FieldByName('ndfl').AsVariant <> null then
          st:=st + ar[i][0] + ': ������� ������� ���� � ' + MemTableEh1.FieldByName('ndfl').AsString + ' �� ' + VarToStr(S.NullIf0(ar[i][2])) + #13#10;
        MemTableEh1.FieldByName('ndfl').Value:=S.NullIf0(ar[i][2]);
        MemTableEh1.FieldByName('changed').Value:=1;
        b:=True;
      end;
      if MemTableEh1.FieldByName('karta').AsVariant <> S.NullIf0(ar[i][3]) then begin
        if MemTableEh1.FieldByName('karta').AsVariant <> null then
          st:=st + ar[i][0] + ': ������� ������� ����� � ' + MemTableEh1.FieldByName('karta').AsString + ' �� ' + VarToStr(S.NullIf0(ar[i][3])) + #13#10;
        MemTableEh1.FieldByName('karta').Value:=S.NullIf0(ar[i][3]);
        MemTableEh1.FieldByName('changed').Value:=1;
        b:=True;
      end;
      MemTableEh1.Post;
      MemTableEh1.Edit;
    end
    else begin
      st:=st + ar[i][0] + ': �� ������ � ������ ��������!' + #13#10;
      b2:=True;
    end;
  end;

  MemTableEh1.EnableControls;
  MemTableEh1.RecNo:=rn;
  //����������� �������
  CalculateAll;
  DBGridEh1.SetFocus;
  //������� ���������
  if b or b2
    then MyInfoMessage('������ ���������' + S.IIf(b2, ', ������ �� ��� ��������� �������!', '.') + #13#10#13#10 + S.IIFStr(not b and not b2, '��������� �� ����.', st));
  CheckEmpty;
end;




end.
