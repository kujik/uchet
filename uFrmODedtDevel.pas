unit uFrmODedtDevel;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions, Vcl.Mask,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2, uFrmBasicInput, uFields, uFrmBasicDbDialog
  ;

type
  TFrmODedtDevel = class(TFrmBasicDbDialog)
    mem_Comm: TDBMemoEh;
    nedt_Time: TDBNumberEditEh;
    nedt_Cnt: TDBNumberEditEh;
    cmb_Id_Kns: TDBComboBoxEh;
    cmb_Id_Status: TDBComboBoxEh;
    dedt_Dt_End: TDBDateTimeEditEh;
    dedt_Dt_Plan: TDBDateTimeEditEh;
    dedt_Dt_Beg: TDBDateTimeEditEh;
    cmb_Name: TDBComboBoxEh;
    cmb_Project: TDBComboBoxEh;
    cmb_Slash: TDBComboBoxEh;
    cmb_Id_DevelType: TDBComboBoxEh;
  private
    function  Prepare: Boolean; override;
    function  LoadComboBoxes: Boolean; override;
    procedure ControlOnChange(Sender: TObject); override;
  public
  end;

var
  FrmODedtDevel: TFrmODedtDevel;

implementation

{$R *.dfm}

function TFrmODedtDevel.LoadComboBoxes: Boolean;
begin
  //��������� ����������
  Q.QLoadToDBComboBoxEh('select name, id from ref_develtypes order by name', [], cmb_Id_DevelType, cntComboLK);
  Q.QLoadToDBComboBoxEh('select distinct project from j_development order by project', [], cmb_Project, cntComboE);
  Q.QLoadToDBComboBoxEh('select distinct name from j_development order by name', [], cmb_Name, cntComboE);
  Q.QLoadToDBComboBoxEh('select slash from v_order_items where id_order > 0 and qnt > 0 and dt_end is null order by slash', [], cmb_Slash, cntComboE);
  cmb_Slash.MaxLength:=25;
  //��������� ������� ������ ��������
  Cth.AddToComboBoxEh(cmb_Id_Status, [
    ['�����', '1'],
    ['� ������', '2'],
    ['����������', '3'],
    ['�� ������������', '4'],
    ['�����', '5'],
    ['������', '100']
  ]);
  //�������� ��������� �������������, ��� ��� ��� ����� ���� ����� ���� � ������� ��������, ����� ��������� ����������� �� ������� ��� � ��� ����
  Q.QLoadToDBComboBoxEh(
    'select name, id from adm_users where (job = :id_job$i and active = 1) or id = :id_old$i order by name asc',
    [myjobKNS, F.GetPropB('id_kns')],
    cmb_Id_Kns,
    cntComboLK
  );
  Result:=True;
end;

function TFrmODedtDevel.Prepare: Boolean;
begin
  Caption:='������ ����������';
  Caption:='������';
  F.DefineFields:=[
    ['id$i'],
    ['id_develtype$i','V=1:400',#0],
    ['project$s','V=1:400:0:T',#0],
    ['name$s','V=1:400:0:T',#0],
    ['dt_beg$d','V=1',#0,Date],
    ['dt_plan$d','V=1',#0],
    ['dt_end$d',#0],
    ['id_status$i','V=0:400',#0,1],
    ['cnt$f','V=0:9999999:1',#0],
    ['comm$s','V=0:4000:0:T',#0],
    ['id_kns$i','V=0:400',#0],
    ['time$f','V=0:9999999:1',#0],
    ['slash$s','V=0:25:0:T',#0]
  ];
  View:='v_j_development';
  Table:='j_development';
  FOpt.UseChbNoClose:= False;
  FOpt.InfoArray := [[
    '�������������� ������� ����������.'#13#10+
    '��� ������ ����� ���� ������ ������ �� ����������� ���������.'#13#10+
    '������ � ������������ ����� ���� ������, �� ������ ���� ����������� ������.'#13#10+
    '����������� ����� ���������� ������.'#13#10+
    '���� ������� ������������� ������������� ��� ��������, � ���� ���������� - ��� ��������� ������� ������.'#13#10+
    '���� ������, ����, ����������� � ����������� ������������� �� ��������.'#13#10
  ]];
  FWHBounds.X := 610;
  FWHBounds.Y := 400;
  Result:=inherited;
  SetControlsEditable([dedt_Dt_Beg], False);
  SetControlsEditable([dedt_Dt_End], (cmb_Id_Status.Value = '100')and(Mode in [fCopy, fEdit, fAdd]));
  if F.GetPropB('id_status') = 100 then
    Cth.SetControlVerification(dedt_dt_end, '1');
end;

procedure TFrmODedtDevel.ControlOnChange(Sender: TObject);
//������� ��������� ������ ��������
begin
  //����� ���� � ��������� ��������
  if FInPrepare then
    Exit;
  if Sender = cmb_Id_Status then
    if cmb_Id_Status.Value = '100' then begin
      Cth.SetControlsVerification([dedt_Dt_End], ['1']);
      Cth.SetControlValue(dedt_Dt_End, Date);
      SetControlsEditable([dedt_Dt_End], True);
      Verify(dedt_Dt_End);
    end
    else begin
      Cth.SetControlsVerification([dedt_Dt_End], ['']);
      Cth.SetControlValue(dedt_Dt_End, null);
      SetControlsEditable([dedt_Dt_End], False);
      Verify(dedt_Dt_End);
    end;
  inherited;
end;


end.
