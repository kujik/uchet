{
����� � �������� ������� � �������� ������ �� ��������� ������
}

unit uFrmWGrepPersonal1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2, uFrmBasicInput
  ;

type
  TFrmWGrepPersonal1 = class(TFrmBasicGrid2)
  private
    function  PrepareForm: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    function  GetData: TVarDynArray2;
  public
  end;

var
  FrmWGrepPersonal1: TFrmWGrepPersonal1;

implementation

uses
  uTurv;

{$R *.dfm}

function TFrmWGrepPersonal1.PrepareForm: Boolean;
begin
  Caption:='����� � �������� �������';
  Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['job$s','������������ ���������','250;h'],
    ['workersqnt$i','���������� ����������, �������','120','f=#,##0:'],
    ['qnt1$i','�������, ���.','80','f=#,##0:'],
    ['qnt2$i','�������, ���.','80','f=#,##0:'],
    ['qntvac$i','�����������, ���.','120','f=#,##0:'],
    ['dtvac$d','���� ���������� ��������','120']
  ]);
  Frg1.Opt.SetButtons(1,[[mbtGo],[],[mbtExcel],[mbtPrintGrid],[],[mbtGridSettings],[],[mbtCtlPanel]]);
  Frg1.Opt.SetButtonsIfEmpty([mbtGo]);
  Frg1.CreateAddControls('1', cntDTEdit, '������ � ', 'edtd1', ':', 70, yrefC, 85);
  Frg1.CreateAddControls('1', cntDTEdit, '�� ', 'edtd2', ':', 180, yrefC, 85);
  Frg1.InfoArray:=[[
    '����� � �������� ������� �� ��������� ������.'#13#10+
    '��������� ���������� � ���������� ���������� �� ������ ��������� (�� ���� ��������� ������ ������),'#13#10+
    '���������� ��������, ��������� �� ������ ������ � ������ ���������, � �����'#13#10+
    '����������� � ������ (�� ���������, ������� ���� ������� ���� �� ���� ���� � ��������������� ������),'#13#10+
    '��� ���� ���� �������� ���� ���������, �� ���� �������� ������������� ���������.'#13#10+
    '�������� ������ ������� � �������� �� � Excel.'#13#10+
    ''
  ]];
  //������ �� �������
  Frg1.SetInitData([]);
  Result := Inherited;
end;

procedure TFrmWGrepPersonal1.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if Tag = mbtGo then begin
    GetData;
    Fr.RefreshGrid;
  end
  else
    inherited;
end;

function TFrmWGrepPersonal1.GetData: TVarDynArray2;
var
  dt: TDateTime;
  i, j, k: Integer;
  dt1, dt2: TDateTime;
  st, st1, st2, w: string;
  v, v1, v2, jobs, vac: TVarDynArray2;
  buf: Variant;
  changed: Boolean;
  size: Integer;
begin
  Result := [];
  //������, ���� �� ������� ��� ����, � ������ ��������
  if not (Cth.DteValueIsDate(Frg1.FindComponent('edtd1')) and Cth.DteValueIsDate(Frg1.FindComponent('edtd2')) and (Frg1.GetControlValue('edtd2') >= Frg1.GetControlValue('edtd1'))) then begin
    MyWarningMessage('������� ���������� ������ ��� ������!');
    Exit;
  end;
 dt1 := Frg1.GetControlValue('edtd1');
  dt2 := Frg1.GetControlValue('edtd2');
  //���������   0-����, 1-������������, 2-����������, 3-�������, 4-�������, 5-�����������, 6-���� ����������� ������
  jobs := Q.QLoadToVarDynArray2('select id, name, 0, 0, 0, 0, null from ref_jobs order by name', []);
  //������. ���������� �������������
  v := Q.QLoadToVarDynArray2('select id_division, id_worker, workername, id_job, job, status, dt from v_j_worker_status order by workername, dt, job, id_division', []);
  //�������� �� ������� ��������, ������������ �� ���������, ����� �� ����
  for i := 0 to High(v) do begin
    //������ �� ������ ���� - �� �� �������� ������ ������������� �� �������� ����, � �������� ������ �� ������ ����� ������
    if v[i][6] <= dt2 then begin
      //���� ������ ��� ���������
      if Integer(v[i][5]) in [1, 2] then begin
        //������ ��������� � �������
        for j := 0 to high(jobs) do
          if jobs[j][0] = v[i, 3] then begin
            //�������� ���������� ���������� �� ������ ���������
            inc(jobs[j][2]);
            //���� ������ ��������� ����, � ��� ����� � �� ������� �� �������� ���������� ��������
            if (v[i][6] >= dt1) and (v[i][5] = 1) then
              inc(jobs[j][3]);
            break;
          end;
      end;
      if Integer(v[i][5]) in [2, 3] then begin
        for j := 0 to high(jobs) do
          if jobs[j][0] = v[i - 1][3] then begin
            dec(jobs[j][2]);
            if (v[i][6] >= dt1) and (v[i][5] = 3) then
              inc(jobs[j][4]);
            break;
          end;
      end;
    end;
  end;
  //������� ��� ��������
  vac := Q.QLoadToVarDynArray2('select id_job, qnt, dt_beg, dt_end from j_vacancy order by id_job, dt_beg', []);
  for i := 0 to High(vac) do begin
    //�� ������, ���� �������� ���� ������ ������ �������, ��� �� ��������� ����� ����� �������
    if not ((vac[i][2] > dt2) or (vac[i][3] <> null) and (vac[i][3] < dt1)) then begin
      for j := 0 to High(jobs) do begin
        if jobs[j][0] = vac[i][0] then begin
          //������������� �����������, � ���� �������� ��������� �� ����������
          jobs[j][5] := jobs[j][5] + vac[i][1];
          jobs[j][6] := vac[i][2];
        end;
      end;
    end;
  end;
  //�������� ���� �� �������
  Frg1.SetInitData(jobs);
end;




end.


