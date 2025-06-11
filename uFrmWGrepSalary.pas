{
����� �� ���������� �����.
� ������� ����� ������� ������ �� �������� �� ������ � �����������, ��� ������ ��� ������� ������ �����
������������ � ���� ������ �� ������� �������
}
unit uFrmWGrepSalary;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2, uFrmBasicInput
  ;

type
  TFrmWGrepSalary = class(TFrmBasicGrid2)
  private
    function  PrepareForm: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);  override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    procedure Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;
//    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
//    procedure Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure CreateDatesList;
  public
  end;

var
  FrmWGrepSalary: TFrmWGrepSalary;

implementation

uses
  uTurv
  ;

{$R *.dfm}

function TFrmWGrepSalary.PrepareForm: Boolean;
begin
  Caption:='����� �� ���������� �����';
  Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
  Frg1.Opt.SetFields([
    ['to_char(rownum) as id','_id','40'],
    ['dt$d','_dt','40'],
    ['id_job','_id_job','40'],
    ['job','���������','250;h'],
    ['sum0','�������� �� �����������','80','f=r'],
    ['sum1','������� ��������','80','f=r','e=0:9999999:0',User.Role(rW_Rep_Salary_Ch) or User.IsDeveloper],
    ['sum2','����������� ��������','80','f=r','e=0:9999999:0',User.Role(rW_Rep_Salary_Ch) or User.IsDeveloper],
    ['sum3','������������ ��������','80','f=r','e=0:9999999:0',User.Role(rW_Rep_Salary_Ch) or User.IsDeveloper]
  ]);
  Frg1.Opt.SetTable('v_rep_salary', '', 'rownum', False, False); //������ ��������� ������, ��� ��� � ��� ��� ��������� ����
  Frg1.Opt.SetWhere('where dt = :dt$d');
  Frg1.Opt.SetButtons(1,[[btnRefresh],[],[btnGo,User.Role(rW_Rep_Salary_Ch) or User.IsDeveloper],[],[btnExcel],[btnPrintGrid],[],[btnGridSettings],[],[btnCtlPanel]]);
  Frg1.CreateAddControls('1', cntComboL, '����', 'CbDates', ':', 60, yrefC, 85);
  Frg1.CreateAddControls('1', cntNEditS, '������ �������'#13#10'(�� 2 ������)', 'NePeriod', '2:24:0:N', 250, yrefC, 45);
  CreateDatesList;
  Frg1.InfoArray:=[[
    '����� �� ���������� �����.'#13#10#13#10+
    '��� ������������ ������ �������� �� ������ ����'#13#10+
    '(���� � ���������� ������ ������������� ������ ���������� ������������ �������, ������������� �������� ������).'#13#10+
    '� ������ ������������ ��� ���������, � �� ������ 4 ��������:'#13#10+
    '������� (�� ������ 3 �������) �������� ��� ������ ��������� �� �����������;'#13#10+
    '������� �������� �� ������, �� ������ ����������� ������������ ��,'#13#10+
    '� ����� ����������� � ������������ �������� ������� �� ������.'#13#10+
    ''#13#10+
    S.IIFStr(User.Role(rW_Rep_Salary_Ch),
    '���� ����� ����, ������� ������ ��� ��� ������������. � ����� ����� ��������� ��� ���������,'#13#10+
    '�������� ������� �� ������ ����� ����� �� ����������� �������, �������� �� ����������� ���������� �� ��������� ���������� ����������.'#13#10+
    '���� �� � ������ ��� ���� ������, �� ��� ������� ������ �� ��������� �� ����������� ����� ���������.'#13#10+
    '�������� �� ������ ������� ����� � ������� �������. ��� ���������� ������ ��� ����� ���������.'#13#10,
    ''
    )+
    '�� ������ ����������� ������� ��� ��������� �� � Excel, ����� ������ ������� ����.'#13#10+
    ''
  ]];
  Result := Inherited;
end;

procedure TFrmWGrepSalary.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
var
  dt1, dt2, dt3: TDateTime;
  i: Integer;
begin
  if (Tag = btnGo) then begin
    if Fr.GetControlValue('CbDates') = null then
      Exit;
    if S.NNum(Fr.GetControlValue('NePeriod')) = 0 then begin
      MyInfoMessage('������� ������ �������!');
      Exit;
    end;
    //if MyQuestionMessage('������������ �����?') <> mrYes then Exit;
    dt1:=StrtoDate(Fr.GetControlValue('CbDates'));
    dt2:=Turv.GetTurvBegDate(IncDay(Turv.GetTurvBegDate(dt1), -1));
    dt3:=dt2;
    for i:=3 to Round(Fr.GetControlValue('NePeriod')) do
      dt3:=Turv.GetTurvBegDate(IncDay(dt3, -1));
//    dt3:=Turv.GetTurvBegDate(IncDay(dt2, -1));
//    dt3:=Turv.GetTurvBegDate(IncDay(dt3, -1));
    if MyQuestionMessage('������������ �����?'#13#10'������� �/� ����� ���������� �� ������ � ' + DateToStr(dt3) + ' �� ' + DateToStr(Turv.GetTurvEndDate(dt1)) + ')') <> mrYes then
      Exit;
    Q.QExecSql(
      'insert into rep_salary (id_job, dt) ' +
      'select id, :dt1$d as j from ref_jobs where not exists (select 1 from rep_salary where id_job = id and dt = :dt2$d)',
      [dt1, dt1]
    );
    Q.QExecSql(
      'update rep_salary s0 set ' +
      'sum1 = (select sum1 from rep_salary s1 where dt = :dt1$d and s0.id_job = s1.id_job), ' +
      'sum2 = (select sum2 from rep_salary s1 where dt = :dt2$d and s0.id_job = s1.id_job), ' +
      'sum3 = (select sum3 from rep_salary s1 where dt = :dt3$d and s0.id_job = s1.id_job) ' +
      'where sum1 is null and sum2 is null and sum3 is null and dt = :dtcurr$d',
      [dt2, dt2, dt2, dt1]
    );

    Q.QExecSql(
      'update rep_salary s0 set sum0 = (' +
      'select round(avg((itog1 - nvl(otpusk,0) - nvl(bl,0) - nvl(penalty,0)) / turv * norm) * 2) sumall ' +
      'from v_payroll_item pi ' +
      'where ' +
      'itog1 is not null and turv is not null and turv <> 0 ' +
      'and s0.id_job = pi.id_job ' +
      'and dt >= :dtbeg$d ' +
      'and dt <= :dtend$d ' +
      ') where s0.dt = :dt$d ' ,
      [dt3, dt1, dt1]
    );
    //����� ���� dt ���� �� ������ ������� ����
    MyInfoMessage('������ ���������.');
    Fr.RefreshGrid;
  end
  else inherited;
end;

procedure TFrmWGrepSalary.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
  if Fr.IsPrepared and (TControl(Sender).Name = 'CbDates') then
    Fr.RefreshGrid;
end;

procedure TFrmWGrepSalary.Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  if S.NullIfEmpty(Fr.GetControlValue('CbDates')) = null
    then Fr.SetSqlParameters('dt$d', [null])
    else Fr.SetSqlParameters('dt$d', [S.NullIfEmpty(StrToDate(Fr.GetControlValue('CbDates')))]);
end;

procedure TFrmWGrepSalary.Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
begin
  Q.QExecSQL(
    'update rep_salary set ' + FieldName + ' = :sum$i where dt = :dt$d and id_job = :job$i', [Value, Fr.GetValueI('dt'), Fr.GetValueI('id_job')]);
end;

procedure TFrmWGrepSalary.CreateDatesList;
var
  i:Integer;
  va: TVarDynArray2;
  dt: TDateTime;
begin
  va := Q.QLoadToVarDynArray2('select distinct dt from rep_salary order by dt desc', []);
  dt:=Turv.GetTurvBegDate(IncDay(Turv.GetTurvBegDate(Date), -1));
  if (High(va) = -1)
    then va:=[[dt]]   //���� �� ���� ���� ������ ����
    else while va[0][0] < dt do     //������� � ������ ��� ���� ������ ���� �� ��������������, ������� ��������� ���� ������
      va:=[[Turv.GetTurvBegDate(IncDay(va[0][0], 19))]] + va;
  Cth.AddToComboBoxEh(TDBComboBoxEh(Frg1.FindComponent('CbDates')), va);
{  for i:=0 to High(va) do
    Cb_Dt.Items.Add(VarToStr(va[i][0]));
  Cb_Dt.ItemIndex:=0;
  Cb_Dt.LimitTextToListValues:=True;}
end;





end.
