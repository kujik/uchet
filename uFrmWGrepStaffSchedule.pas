{
������� ����������
���� - ����
}

unit uFrmWGrepStaffSchedule;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2, uFrmBasicInput, uWindows
  ;

type
  TFrmWGrepStaffSchedule = class(TFrmBasicGrid2)
  private
    function  PrepareForm: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); override;
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    procedure SetMode;
    procedure GetData;
    procedure FromExcel;
  public
  end;

var
  FrmWGrepStaffSchedule: TFrmWGrepStaffSchedule;

implementation

uses
  uTurv,
  uExcel,
  XlsMemFilesEh
  ;

{$R *.dfm}

function TFrmWGrepStaffSchedule.PrepareForm: Boolean;
var
  NoSum: boolean;
begin
  Caption:='������� ����������';
  Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible] - [myogSorting];
  //NoSum := not A.InArray(User.GetLogin, ['sprokopenko','ostulihina','eteplyakova']);
  Frg1.Opt.SetFields([
    ['rownum$i','_id','40'],
    ['is_title$i','_title','40'],
    ['id_job$i','_���������','40'],
    ['id_division$i','_�������������','40'],
    ['office$s','���� /���','50'],
    ['job$s','���������','250;h'],
    ['division$s','�������������','250;h'],
    ['qnt$i','����������� ����������� ����������','100'],
    ['qnt_plan$i','�������� ����������� ����������','100','f=f:','e=0:100:0',User.Roles([], [rW_Rep_StaffSchedule_Ch_O, rW_Rep_StaffSchedule_Ch_C])],
    ['qnt_need$i','����������� � ����������','100','f=f:'],
    ['schedule$s','������ ������','100'],
    ['salary_avg$i','����������� �/� (�������)','100','f=f','t=1'],
    ['salary_plan$i','����������� �/� (��������)','100','f=f','e','t=1'],
    ['salary_wo_ndfl$i','�/� ����� ������ ����','100','f=f','t=1'],
    ['salary_sity$i','�����, ������.','100','f=f','e','t=1'],
    ['budget$i','������ ������ �� ���-�� ����. ������� ������','100','f=f','t=1'],
    ['salary_diff$i','���������� �� ����� �� ���������','100','f=f','t=1'],
    ['budget_sity$i','������ �� �����','100','f=f','t=1'],
    ['budget_diff$i','���������� ������� �� �����','100','f=f','t=1']
  ]);
  Frg1.Opt.SetButtons(1,[[mbtGo],[],[mbtExcel],[mbtPrintGrid],[],[-1001, User.Role(rW_Rep_StaffSchedule_Ch_O), '��������� ���������'],[],[mbtGridSettings],[],[mbtCtlPanel]]);
  Frg1.Opt.SetButtonsIfEmpty([mbtGo]);
  Frg1.CreateAddControls('1', cntDTEdit, '����', 'edtd1', ':',30, yrefC, 85);
  Frg1.CreateAddControls('1', cntComboL, '��������', 'cmbArea', ':', 30 + 65 + 80, yrefC, 100);
  if User.Roles([], [rW_Rep_StaffSchedule_V_S]) then
    Frg1.CreateAddControls('1', cntCheck, '������ �� �/�', 'chbSalary', '', -1, yrefC, 100);
  if User.Roles([], [rW_Rep_StaffSchedule_Ch_O, rW_Rep_StaffSchedule_Ch_C, rW_Rep_StaffSchedule_Ch_SP, rW_Rep_StaffSchedule_Ch_SS]) then
    Frg1.CreateAddControls('1', cntCheck, '���� ������', 'chbEdit', '', -1, yrefC, 100);
  Q.QLoadToDBComboBoxEh('select ''���'' from dual union select distinct area_shortname || '' - '' || isoffice from v_ref_divisions order by 1', [], TDBComboBoxEh(Frg1.FindComponent('cmbArea')), cntComboL);
  Frg1.InfoArray:=[[
    '������� ����������.'#13#10
  ]];
  //������ �� �������
  Frg1.SetInitData([]);
  Result := Inherited;
  SetMode;
end;

procedure TFrmWGrepStaffSchedule.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  //if Tag = mbtExcel then FromExcel else
  if Tag = mbtGo then begin
    GetData;
    Fr.RefreshGrid;
  end
  else if Tag = 1001 then
    Wh.ExecReference(myfrm_Ref_JobsNeeded)
  else
    inherited;
end;

procedure TFrmWGrepStaffSchedule.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if Fr.GetValue('office') = '�����:' then
    Params.Background := clmyYelow
  else if (Fr.GetValue('id_division') = null) or (Fr.GetValue('is_title') = 1) then
    Params.Background := clmyGray;
  if (FieldName = 'qnt_need') and (Fr.GetValue('qnt_need') <> null) then begin
    if Fr.GetValue('qnt_need') < 0 then
      Params.Background := clmyPink
    else if Fr.GetValue('qnt_need') > 0 then
      Params.Background := clmyGreen;
  end;
end;

procedure TFrmWGrepStaffSchedule.Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
  ReadOnly := (Fr.GetValue('id_division') = null) or
    ((Fr.GetValue('office') = '���') and not User.Role(rW_Rep_StaffSchedule_Ch_C)) or
    ((Fr.GetValue('office') = '���') and not User.Role(rW_Rep_StaffSchedule_Ch_C));
end;

procedure TFrmWGrepStaffSchedule.Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
var
  t: Integer;
begin
  t := A.PosInArray(FieldName, ['','qnt_plan','salary_plan','salary_sity']);
  if t > 0 then begin
    Q.QExecSql('delete from ref_staff_schedule where id_division = :id_division$i and id_job = :id_job$i and dt = :dt$d and type = :t$i', [Fr.GetValue('id_division'), Fr.GetValue('id_job'), Date, t]);
    Q.QExecSql('insert into ref_staff_schedule (id_division, id_job, dt, type, value) values (:id_division$i, :id_job$i, :dt$d, :t$i, :value$i)', [Fr.GetValue('id_division'), Fr.GetValue('id_job'), Date, t, S.NullIf0(Value)]);
  end;
end;

procedure TFrmWGrepStaffSchedule.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
  SetMode;
end;

procedure TFrmWGrepStaffSchedule.SetMode;
begin
  Frg1.Opt.SetColFeature('1', 'i', not ((Frg1.GetControlValue('chbSalary') = 1) and User.Role(rW_Rep_StaffSchedule_V_S)), True);
  Frg1.Opt.SetColFeature('qnt_plan', 'e', (Frg1.GetControlValue('chbEdit') = 1) and User.Roles([], [rW_Rep_StaffSchedule_Ch_O, rW_Rep_StaffSchedule_Ch_C]), False);
  Frg1.Opt.SetColFeature('salary_plan', 'e', (Frg1.GetControlValue('chbEdit') = 1) and User.Role(rW_Rep_StaffSchedule_Ch_SP), False);
  Frg1.Opt.SetColFeature('salary_sity', 'e', (Frg1.GetControlValue('chbEdit') = 1) and User.Role(rW_Rep_StaffSchedule_Ch_SS), False);
  Frg1.SetColumnsVisible;
  Frg1.DbGridEh1.Invalidate;
end;


procedure TFrmWGrepStaffSchedule.GetData;
var
  i, j, qc, qo, qdp, qn, qnp, qnm, qdn: Integer;
  na : TNamedArr;
  st: string;
  ArSalary, ArSalaryPlan, ArSalarySity, ArQntPlan: TVarDynArray2;
  v1: Variant;
begin
  if (not Cth.DteValueIsDate(Frg1.FindComponent('edtd1'))) or (S.NSt(Frg1.GetControlValue('cmbArea')) = '') then
    Exit;
  if Frg1.GetControlValue('cmbArea')  <> '���' then begin
    i := Pos(' - ', Frg1.GetControlValue('cmbArea'));
    Q.QSetContextValue('staff_schedule_office', S.IIf(Copy(Frg1.GetControlValue('cmbArea'), i + 3) = '����' , 1, 0));
    Q.QSetContextValue('staff_schedule_area', Copy(Frg1.GetControlValue('cmbArea'), 1, i -1));
  end
  else begin
    Q.QSetContextValue('staff_schedule_office', '');
    Q.QSetContextValue('staff_schedule_area', '');
  end;
  Q.QSetContextValue('staff_schedule_dt', Frg1.GetControlValue('edtd1'));
  Q.QLoadFromQuery(
    'select rownum, 0 as is_title, id_job, id_division, office, job, division, qnt, qnt_plan, qnt_need, schedule, '+
    'null as salary_avg, salary_plan, null as salary_wo_ndfl, null as salary_diff, salary_sity, null as budget, null as budget_sity, null as budget_diff '+
    'from v_staff_schedule',
  [], na);
  ArSalary := Q.QLoadToVarDynArray2(
    'select pi.id_job, round(avg((nvl(itog1, 0) - nvl(otpusk,0) - nvl(bl,0) - nvl(penalty,0)) / turv * norm) * 2) sumall ' +
    'from v_payroll_item pi, v_staff_schedule ss ' +
    'where ' +
    'itog1 is not null and turv is not null and turv <> 0 ' +
    'and ss.id_job = pi.id_job ' +
    'and dt >= :dtbeg$d ' +
    'and dt <= :dtend$d ' +
    'group by pi.id_job',
    [EncodeDate(2025, 5, 1), EncodeDate(2025, 7, 15)]
  );

  ArSalaryPlan := Q.QLoadToVarDynArray2(
    'select id_division, id_job, value from ref_staff_schedule where dt = ( '+
    'select max(dt) from ref_staff_schedule '+
    'where dt < :dt$d and type = 2'+
    'group by id_division, id_job)',
    [Frg1.GetControlValue('edtd1')]
  );
  //��������� ����� �� ���� � �����
  qc := 0;
  qo := 0;
  for i := 0 to na.Count - 2 do
    if na.G(i, 'id_division') <> null then
      if na.G(i, 'office') = '���' then
        qc := qc + na.G(i, 'qnt')
      else
        qo := qo + na.G(i, 'qnt');
  //������ ��������� ������ (��� ��� ���������� ������ � ����� ������)
  Delete(na.V, na.Count - 1, 1);
  //������� �����
  na.V := na.V + [[100000, null, null, null, '�����:', '', '����', qo, null,null,null,null,null,null,null,null,null,null,null]];
  na.V := na.V + [[100001, null, null, null, '�����:', '', '���', qc, null,null,null,null,null,null,null,null,null,null,null]];
  na.V := na.V + [[100002, null, null, null, '�����:', '', '�����', qc, null,null,null,null,null,null,null,null,null,null,null]];
  //������ ����� �� ��� ���������� �� ������� ������ ���� ������ (����� � ���������� ������ ��������� � �������)
  i := 1;
  while i <= na.Count - 4 do begin
    if (na.G(i, 'qnt') = na.G(i - 1, 'qnt')) and (na.G(i, 'id_division') = null) then begin
      Delete(na.V, i, 1);
      na.SetValue(i - 1, 'is_title', 1);
    end;
    Inc(i);
  end;
  i := 0;
  qn := 0;
  qnp := 0;
  qnm := 0;
  qdn := 0;
  while i <= na.Count - 4 do begin
    if na.G(i, 'id_division') = null then begin
      na.SetValue(i, 'division', '�� ���� ��������������:');
      na.SetValue(i, 'qnt_plan', qdp);
      na.SetValue(i, 'qnt_need', qdn);
      if na.G(i, 'qnt_plan').AsInteger <> 0 then
        na.SetValue(i, 'qnt_need', qdp - na.G(i, 'qnt'));
    end
    else if na.G(i, 'qnt_plan') <> null then begin
      qdp := qdp + na.G(i, 'qnt_plan').AsInteger;
      qdn := qdn + na.G(i, 'qnt_need').AsInteger;
      qnp := qnp + Max(na.G(i, 'qnt_need').AsInteger, 0);
      qnm := qnm + Min(na.G(i, 'qnt_need').AsInteger, 0);
    end;
    if na.G(i, 'is_title') = 1 then begin
      qdp := 0;
      qdn := 0;
    end;
    Inc(i);
  end;
  na.SetValue(na.Count - 1, 'qnt_need', qnp + qnm);
  i := 0;
  while i <= na.Count - 4 do begin
    if na.G(i, 'id_division') = null then begin
      //na.SetValue(i, 'qnt_plan', null);
      //na.SetValue(i, 'qnt_need', null);
      na.SetValue(i, 'schedule', null);
    end;
    if (na.G(i, 'is_title') = 1) or (na.G(i, 'id_division') = null) then begin
      j := A.PosInArray(na.G(i, 'id_job'), ArSalary, 0);
      if j >= 0 then
        na.SetValue(i, 'salary_avg', ArSalary[j][1]);
      j := A.PosInArray(na.G(i, 'id_job'), ArSalaryPlan, 0);
      na.SetValue(i, 'salary_wo_ndfl', Round(na.G(i, 'salary_avg').AsInteger * 0.87));
      na.SetValue(i, 'budget', na.G(i, 'salary_avg').AsInteger * na.G(i, 'qnt').AsInteger);
      na.SetValue(i, 'salary_diff', na.G(i, 'salary_avg').AsInteger - na.G(i, 'salary_sity').AsInteger);
      na.SetValue(i, 'budget_sity', na.G(i, 'salary_sity').AsInteger * na.G(i, 'qnt').AsInteger);
      na.SetValue(i, 'budget_diff', na.G(i, 'budget').AsInteger - na.G(i, 'budget_sity').AsInteger);
    end;
    inc(i);
  end;
  Frg1.SetInitData(na);
end;


procedure TFrmWGrepStaffSchedule.FromExcel;
var
  i, j, k: Integer;
  st, st1: string;
  v, v1, v2: Variant;
  b, b1, b2: Boolean;
  XlsFile: TXlsMemFileEh;
  sh, sh1: TXlsWorksheetEh;
  ArXls, va2: TVarDynArray2;
  EmplCn: TVarDynArray;
  e1, e2: Extended;
begin
  va2:=Q.QLoadToVarDynArray2('select id, name from ref_jobs', []);
  //������� ����
  MyData.OpenDialog1.Filter := '����� Excel (*.xlsx)|*.xlsx';
  if not MyData.OpenDialog1.Execute then
    Exit;
  if not CreateTXlsMemFileEhFromExists(MyData.OpenDialog1.FileName, True, '$2', XlsFile, st) then
    Exit;
  //������� ������ �������������
  EmplCn := Q.QLoadToVarDynArrayOneCol('select id from ref_workers where concurrent_employee = 1', []);
  //�������� � ������ ������ �� ������ �� ������ ������ �� ������ ������
  ArXls := [];
  sh := XlsFile.Workbook.Worksheets[0];
  for i := 3 to 2000 do begin
    if (sh.Cells[0, i].Value.AsString = '') then
      break;
    j:=a.PosInArray(sh.Cells[0, i].Value.AsString, va2, 1);
    if j >= 0 then begin
      Q.QExecSql('insert into ref_staff_schedule (id_job, dt, type, value) values (:j$i, :dt$d, 3, :v$i)', [va2[j][0], Date, sh.Cells[16, i].Value.AsInteger]);
    end;
  end;
  sh := XlsFile.Workbook.Worksheets[1];
  for i := 3 to 2000 do begin
    if (sh.Cells[0, i].Value.AsString = '') then
      break;
    j:=a.PosInArray(sh.Cells[0, i].Value.AsString, va2, 1);
    if j >= 0 then begin
      Q.QExecSql('insert into ref_staff_schedule (id_job, dt, type, value) values (:j$i, :dt$d, 3, :v$i)', [va2[j][0], Date, sh.Cells[13, i].Value.AsInteger]);
    end;
  end;
  for i := 0 to Frg1.GetCount - 1 do
   if Frg1.GetValue('id_division', i) <> null then
     Q.QExecSql('insert into ref_staff_schedule (id_job, id_division, dt, type, value) values (:j$i, :d$i, :dt$d, 1, :v$i)',
       [Frg1.GetValue('id_job',i), Frg1.GetValue('id_division',i), Date,Frg1.GetValue('qnt',i)]);
end;


end.


