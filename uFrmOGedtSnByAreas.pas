{
������� �������� ����������� �������� �������� ��� ������� �������
(�� ������ ������ ��� �������, ������ ���������� ������ �� foformDoc)
���������� ���������� �� ���� �������, ����������� � �������, ����� ������������

�������������� ������������ ����������� ����� ���� (���������� �������� ������ ������������, ��� ��� ��������� � ���)

������ ������������ ����� ��� ���� ��������
(������ �������� � ����� �������, �� ������ �� ������������, ���������� ��������
� �������� �������� � ���������, ��������������� ������ ��������)

������� ����������� ����� ������������ ������� ��� ��������,
� ����� ����� ���������� "� ������" (�� LShift ��� Space ������� ���� �����, ������������ �� ���. �������)
� ������� "� ������", � �������� ���� ������ � ������� ������������ ������ ��
(� ��������� ����� ����������� ���������� � ����� � ������ � �������, ������� �������� �����, � �������� ����� �� ��������� ��������� ������ �����)
}

unit uFrmOGedtSnByAreas;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, uLabelColors,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2
  ;

type
  TFrmOGedtSnByAreas = class(TFrmBasicGrid2)
  private
    IdArea: Integer;
    AreaSuffix: string;
    AreaName: string;
    function  PrepareForm: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;
    function CreateDemand: Boolean;
  public
  end;

var
  FrmOGedtSnByAreas: TFrmOGedtSnByAreas;

implementation

uses
  RegularExpressions,
  uWindows,
  uOrders,
  uPrintReport,
  D_Spl_InfoGrid,
  uFrmODedtNomenclFiles,
  uExcel,
  uSys,
  uFrmBasicInput
  ;


{$R *.dfm}

function TFrmOGedtSnByAreas.PrepareForm: Boolean;
var
  IsNstd: Boolean;
  va, va1: TVarDynArray;
  va2: TVarDynArray2;
  i, j: Integer;
begin
  IdArea:= 0;
  if FormDoc = myfrm_R_MinRemainsI then IdArea:= 1;
  if FormDoc = myfrm_R_MinRemainsD then IdArea:= 2;
  AreaSuffix:='_' + IntToStr(IdArea);
  AreaName:= Q.QSelectOneRow('select name from ref_production_areas where id = :id$i', [IdArea])[0];
  Caption := '����������� �� ������� "' + AreaName + '"';
  Frg1.Options := Frg1.Options + [myogGridLabels];
  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['artikul','�������','100'],
    ['name','������������','400;h'],
    ['qnt'+AreaSuffix,'������� �������','80'],
    ['qnt_min'+AreaSuffix,'����������� �������','80','e',User.Role(rOr_Other_R_MinRemainsI_ChAll)],
    ['qnt_order'+AreaSuffix,'� ������','80','e',User.Role(rOr_Other_R_MinRemainsI_ChAll)],
    ['to_order'+AreaSuffix,'� ������','60','chb','e',User.Role(rOr_Other_R_MinRemainsI_ChAll)]
  ]);
  Frg1.Opt.SetTable('v_spl_minremains_byareas');
  Frg1.Opt.SetWhere('');
  Frg1.Opt.SetButtons(1,[[btnRefresh],[],[btnAdd, User.Role(rOr_Other_R_MinRemainsI_ChAll)],[btnDelete,1],[],[btnGridSettings],[],[btnGo,User.Role(rOr_Other_R_MinRemainsI_ChAll)]]);
  Frg1.InfoArray:=[
    [Caption + '.'#13#10#13#10],
    ['�������� ����� ���� ��� ������������, ������� �� ������� �� ������� �������� ����� ��������������.'#13#10, User.Role(rOr_Other_R_MinRemainsIAdd_Ch)],
    ['� ����� "������� �������" �� ������� ������� ������ �� ������� ���� ��������.'#13#10],
    ['������� ����������� ������� �� �������� (����� ������ ����� � �������), �� ������� ����� ���������������� ����������.'#13#10+
    '�� ������ ��������� ������ � ������ ��������� ������� � ������� ������������ ������ �� ���������.'#13#10+
    '��� ����� ��������� ���� "� ������" � ���������� ������� � ������ �������� "� ������", � ����� ������� ������ "�����"'#13#10+
    '(��� �������� ����� � ����� "� ������" ����������, ������������ ������� �� ������������, ������� � ���� ������ ������ ��� ����� ����.)'#13#10, User.Role(rOr_Other_R_MinRemainsIAdd_Ch)]
  ];
  Frg1.Opt.ColumnsInfo:=[
    ['tomin', '���� ������� �����������, �� ����� �������� ������� "������ ���������" � ���������, � � ������� ����� ������������ ������ ��� ������'],
    ['','']
  ];
  Result := inherited;
end;

procedure TFrmOGedtSnByAreas.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
var
  i, j: Integer;
  idi: Variant;
  va, va1, va2: TVarDynArray;
  b: Boolean;
begin
  if Tag = btnGo then begin
    CreateDemand;
  end
  else if Tag in [btnAdd] then begin
    va1:=['', 0];
    while True do begin
      if TFrmBasicInput.ShowDialog(Self, '', [], CtH.BtnModeToFMode(Tag), S.Decode([Tag, btnAdd, '��������', btnEdit, '��������', btnDelete, '�������']), 700, 85,
        [[cntEdit, '������������', '1:400:T', 600], [cntCheck, '�� ��������� ����', '', 200]],
        va1, va2, [['������� ������������ ������������, ������� ���� � ���.'#13#10]], nil
      ) >= 0
      then begin
        if Q.QSelectOneRow('select count(*) from v_spl_minremains_byareas where name = :name$s', [va2[0]])[0] > 0
          then begin MyWarningMessage('��� ������������ ��� ���� � ������!'); Continue; end;
        idi:=Q.QSelectOneRow('select id_nomencl from dv.nomenclatura where name = :name$s', [va2[0]])[0];
        if idi = null
          then begin MyWarningMessage('������ ������������ ��� � ���!'); Continue; end;
        Q.QExecSql('insert into spl_minremains_byareas (id) values (:id$i)', [idi]);
        Refresh;
        if va2[1] = 1 then Continue;
      end;
      Break;
    end;
  end
  else if Tag = btnDelete then begin
    if MyQuestionMessage('������� ������� �� ������?') <> mrYes then Exit;
    Q.QExecSql('delete from spl_minremains_byareas where id = :id$i', [id]);
    Refresh;
  end
  else
    inherited;
end;

procedure TFrmOGedtSnByAreas.Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
var
  i: Integer;
  e: extended;
begin
  if TRegEx.IsMatch(FieldName, '^to_order_[0-9]{1}$')
    then Q.QExecSql('update spl_minremains_byareas set ' + FieldName + ' = :to_order$i where id = :id$i', [Value, Fr.ID])
    else if TRegEx.IsMatch(FieldName, '^qnt_min_[0-9]{1}$') or TRegEx.IsMatch(FieldName, '^qnt_order_[0-9]{1}$')
      then Q.QExecSql('update spl_minremains_byareas set ' + FieldName + ' = :qnt$f where id = :id$i', [S.NullIfEmpty(Value), Fr.ID]);
end;


function TFrmOGedtSnByAreas.CreateDemand: Boolean;
//�������� ������ �� ���������
//������ ��������� ������ �� ��������, ��� ������� ��������� ������������� �������
//����� ��������� �������� ���������� ���� ������� (�� ������ ��������) � ������ � ����������� ��������
//� ������ ���������� ������ ������� �� ������� ���������, ��� ������� ������ � �� ������� ���������� � ������ � ����� ����� � �����
var
  i, j: Integer;
  e: extended;
  idd, res: Integer;
  gf: TVarDynArray2;
  id_category, idi: Integer;
begin
  //����������, ������� ������� � ������
  i := Q.QSelectOneRow('select count(*) from spl_minremains_byareas where nvl(qnt_order'+AreaSuffix+', 0) > 0 and to_order'+AreaSuffix+' = 1', [])[0];
  //���� ������ ���, �� ������
  if i = 0 then begin
    MyInfoMessage('��� �� ����� ������� � ������!');
    Result := False;
    Exit;
  end;
  //����������, ���������� �� ��������� � �������� �������
  j := Q.QSelectOneRow('select count(*) from spl_itm_nom_props where nvl(qnt_order, 0) > 0 and to_order = 1 and id_category = :id_category$i', [1])[0];
  //�����������
  if MyQuestionMessage(
    '������ ������ � ������� ������������ ������ �� ��������� �� ' + S.GetEndingFull(i, '������', '�', '��', '��') + '"?'#13#10+
    S.IIfStr(i > 0, '(' + S.GetEndingFull(j, '������', '�', '�' ,'�') + ' � ��� ������ �������' + S.GetEnding(j, '�', '�' ,'�') + ', ������� ����� �����!)'#13#10)+
    #13#10+
    '���� �������� ������� � ��� �������, ��������� ������!'
    ) <> mrYes then  Exit;
  Q.QBeginTrans(True);
  Q.QExecSql('update spl_itm_nom_props set to_order = 0 where to_order = 1 and id_category = :id_category$i', [1]);
  for i:=0 to Frg1.MemTableEh1.RecordsView.MemTableData.RecordsList.Count - 1 do begin
    if S.NInt(Frg1.MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['to_order'+AreaSuffix, dvvValueEh]) <> 1 then Continue;
    e:=S.NNum(Frg1.MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['qnt_order'+AreaSuffix, dvvValueEh]);
    idi:= Frg1.MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['id', dvvValueEh];
    if e = 0 then Continue;
    //to_order
    Q.QCallStoredProc('P_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([idi, 5, 1]));
    //qnt_order
    Q.QCallStoredProc('P_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([idi, 4, e]));
  end;
  Q.QExecSql('update spl_minremains_byareas set to_order'+AreaSuffix+' = 0', []);
  Q.QCommitOrRollback();
  //���� ����������� ��������, ������� � ������
  if Q.PackageMode <> 1 then begin
    MyWarningMessage('������ ��������!');
    Exit;
  end;
  Refresh;
  MyInfoMessage('������.');
  Close;
end;

end.
