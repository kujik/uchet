{
���������� �������������� ������� � ���� ����� � ���
����������� ������ ���������� ����� �������, ������������ ����� ������� � �������������� � ���������.

���� ������� � ����� ����, �� ��� �� ���������. ���� ���� � ���, � ��� ������� ������� - ���� �� ���������.
���� � ��� ���� ��� ��������, �� �������, ������ � ��� �� ���������, � ����� ���������.

� ����� � ���� �������� ������ ������������, �� ������� � ������ ��������� �� � �������������, � � ������.

��� ��� ���������� ������ �� ������ ����� (���������� ���� ��� ��� ������� � ���������� �� ���),
������� ��������� �� ����������� ������ ���� �����.

��� �������� ������ � ��� ������������� ������� (���� ���� �������� ������), �� �������� �� ��������� �������� ���.
}

unit uFrmDlgEditNomenclatura;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh,
  uFrmBasicMdi, uFrmBasicDbDialog, uData
  ;

type
  TFrmDlgEditNomenclatura = class(TFrmBasicDbDialog)
    edt_name: TDBEditEh;
    cmb_id_group: TDBComboBoxEh;
    cmb_id_unit: TDBComboBoxEh;
    edt_id_group_itm: TDBEditEh;
    procedure edt_id_group_itmEditButtons0click(Sender: TObject; var Handled: Boolean);
  private
    FIdGroupItm: Variant;
    function  Prepare: Boolean; override;
    procedure AfterPrepare; override;
    function  LoadComboBoxes: Boolean; override;
    procedure VerifyBeforeSave; override;
    function  Save: Boolean;  override;
    procedure GetGroupItm;
  public
  end;

var
  FrmDlgEditNomenclatura: TFrmDlgEditNomenclatura;

implementation

uses
  uForms,
  uDBOra,
  uString,
  uMessages,
  F_TestTree
;

{$R *.dfm}


procedure TFrmDlgEditNomenclatura.VerifyBeforeSave;
begin
end;

procedure TFrmDlgEditNomenclatura.GetGroupItm;
begin
  Cth.SetControlValue(edt_id_group_itm,
    Q.QSelectOneRow('select path from v_itm_getnomenclpath where id_group = :id_group$i', [FIdGroupItm])[0]
  );
end;

procedure TFrmDlgEditNomenclatura.edt_id_group_itmEditButtons0click(Sender: TObject; var Handled: Boolean);
begin
  inherited;
  FIdGroupItm := Form_TestTree.ShowDialog(FIdGroupItm);
  GetGroupItm;
end;

function TFrmDlgEditNomenclatura.LoadComboBoxes: Boolean;
begin
  Q.QLoadToDBComboBoxEh('select name, id from bcad_groups where name <> ''������� �������'' order by name', [], cmb_id_group, cntComboLK);
  Q.QLoadToDBComboBoxEh('select name, id from bcad_units order by name', [], cmb_id_unit, cntComboLK);
  Result := True;
end;


function TFrmDlgEditNomenclatura.Save: Boolean;
var
  va1, va2: TVarDynArray;
  vau, vai: TVarDynArray;
  i, j: Integer;
  IdUnitItm: Integer;
begin
  Result:= False;
  if Q.QSelectOneRow('select count(*) from bcad_nomencl where name = :name$s', [edt_name.Text])[0] <> 0 then begin
    MyWarningMessage('��������� ������������ ��� ���� � ���� ������������ �����!');
    Exit;
  end;
  vai:= Q.QSelectOneRow('select name, id_group, id_nomencltype from dv.nomenclatura where name = :name$s', [edt_name.Text]);
  if (S.NSt(vai[0]) <> '') and (vai[2] = 0) then begin
    if MyQuestionMessage('��������� ������������ ��� ���� � ���� ������������ ���! ������ � ��� �������� �� �����. �������� ������ � ���������� �����?') <> mrYes then
      Exit;
  end;
  if (S.NSt(vai[0]) <> '') and (vai[2] <> 0) then begin
    MyWarningMessage('��������� ������������ ��� ���� � ���� ������������ ��� �� �������� "������� �������"!');
    Exit;
  end;
//  Result := True; Exit;

  Q.QBeginTrans(True);
  IdUnitItm := Q.QSelectOneRow('select id_unit from dv.unit where name_unit = :name$s', [cmb_id_unit.Text])[0];
//  Q.QIUD(Q.QFModeToIUD(Mode), 'bcad_nomencl', '', 'id$i;name$s;id_group$i;id_unit$i',
//    [ID, edt_name.Text, cmb_id_group.Value, cmb_id_unit.Value]
//  );
  Q.QIUD(Q.QFModeToIUD(Mode), 'bcad_nomencl', '', 'id$i;name$s',
    [-1, edt_name.Text]
  );
  //���������� ������� � ���
  //� ��� ����� ������������� �������, ������������ ��� ��������� ��������, ������� ��� ���� ���� �����
  //�������� ����������� ����� �� ������� � ��������� � �������� ��� � ������
  //����� ������� ������� � ��� �������� ������� ����������, ��� ������� ���� �� ������������
  //����� �������� 1 � ��������
  va1:= Q.QLoadToVarDynArrayOneCol('select artikul from dv.nomenclatura where id_group = :id_group$i', [FIdGroupItm]);
  va2:=[];
  for i:= 0 to High(va1) do begin
    j:= StrToIntDef(S.Right(S.NSt(va1[i]), 4), -1);
    if j <> -1
      then va2:= va2 + [j];
  end;
  A.VarDynArraySort(va2, False);
  if Length(va2) = 0
    then i:= 0 else i:= va2[0];
  if S.NSt(vai[0]) = '' then begin
    ID := Q.QIUD(Q.QFModeToIUD(Mode), 'dv.nomenclatura', '', 'id_nomencl$i;name$s;fullname$s;id_group$i;id_unit$i;id_nomencltype$i',
      [-1, edt_name.Text, edt_name.Text, FIdGroupItm, IdUnitItm, 0]
    );
    Q.QExecSQL('update dv.groups set count_item = :count_item$i where id_group = :id_group$i', [i, FIdGroupItm]);
    Q.QExecSQL(
      'update dv.nomenclatura set id_group=:id_group$i, artikul=(select dv.CreateArtikul(:id_group1$i) from dual) where id_nomencl=:id$i',
      [FIdGroupItm, FIdGroupItm, ID]
    );
    Q.QExecSQL('update dv.groups set count_item=nvl(count_item, 0) + 1 where id_group = :id_group$i', [FIdGroupItm]);
  end;
  Q.QCommitOrRollback;
  Result:= Q.CommitSuccess;
  if not Result
    then MyWarningMessage('�� ������� ��������� ������!');
end;


procedure TFrmDlgEditNomenclatura.AfterPrepare;
begin
  inherited;
  cmb_id_group.Enabled := False;
  edt_id_group_itm.ReadOnly := True;
end;


function TFrmDlgEditNomenclatura.Prepare: Boolean;
begin
  Caption:='������������';
  F.DefineFields:=[
    ['id$i',#0,-1], ['name$s','V=1:255::T'], ['id_group$i'], ['0 as id_group_itm$i','V=1:255'], ['id_unit$i','V=1:255']
  ];
  View:='v_bcad_nomencl_add';
  Table:='bcad_nomencl';
  FOpt.UseChbNoClose:= True;
  FOpt.InfoArray:= [
    ['���������� �������������� ������� � ����������� ����� � ���.'#13#10+
    '��� ������ ������������ � ��� ���������� ������ (�� ������) � ������� ���������.'#13#10+
    '��� ���������� � ��� ������������� ������������� �������.'#13#10+
    '������ � ����� �� ������������.'#13#10+
    '� ����� ������ ����������� � ���������� ������� ������� � ����� "��� �����",'#13#10+
    '� ����� �������� ��� ������ � ������.'
    ,A.InArray(Mode, [fEdit])]
  ];
  FWHBounds.Y2:= -1;
  Result:=inherited;
end;



end.
