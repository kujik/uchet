{
������� ��� - ��� ��� �����������, ��� � ��� ������������� �������
}
unit uFrmOGedtSgpRevision;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uFrmBasicEditabelGrid, uLabelColors
  ;

type
  TFrmOGedtSgpRevision = class(TFrmBasicEditabelGrid)
  private
    function  PrepareForm: Boolean; override;
    procedure Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string); override;
    procedure VerifyBeforeSave; override;
    function  Save: Boolean; override;
  public
  end;

var
  FrmOGedtSgpRevision: TFrmOGedtSgpRevision;

implementation

{$R *.dfm}

function TFrmOGedtSgpRevision.PrepareForm: Boolean;
begin
  Caption:= '������� ���';
  if ID = 0
    then FTitleTexts := ['$FF0000������������� �������']
    else FTitleTexts := ['�������:$FF0000 ' + S.NSt(Q.QSelectOneRow('select name from v_sgp_sell_formats where id = :id$i', [ID])[0])];
  Frg1.Opt.Caption := '�������';
  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['slash$s','����','110'],
    ['name$s','������������','300;w'],
    ['qnt$i','���-��','60'],
    ['null as qnt_fact$i','���-�� ����.','60','e=0.000000:1000000:0'], //��������, null ���������
    ['null as qnt_diff$i','�������','60']
  ]);
  Frg1.Opt.SetGridOperations('u');
  Frg1.Opt.SetTable(S.IIf(ID = 0, 'v_sgp2', 'v_sgp_items'));
  Frg1.Opt.SetWhere(S.IIf(ID = 0, 'order by slash, name', 'where id_format_est = :id$i order by slash, name'));
  Frg1.SetInitData('*',[ID]);
  FOpt.InfoArray:= [[
  '������� ������ ������� ��������� �� ���������� ���� ���������.'#13#10+
  '� ������� ������������ ��� ����������� ������� ������� ����, ���������� ����� �� ���.'#13#10+
  '� ���� "���-��" ������������ ����������, ������� ������ ���������� �� ��� �� ����������'#13#10+
  '(���������������� �������� ��� ������, ����������� ��� ������, � ��������� ����� ���� ������������� ��� ��������).'#13#10+
  ''#13#10+
  '������� � ����� "���-�� ����." �������� (����� �����), ���������� ��� ��������� �� ������.'#13#10+
  '(�� ������������ ������� ������ �� ������ �������, ����������� ������� ������ �� ����� ����������.)'#13#10+
  ''#13#10+
  '��� ������� ������ "��", ����� �������������, ����� ������������'#13#10+
  '(���� ���� ��������������� ����������� � ����������)'#13#10+
  '��� ������������� � ��� ��������, � ������� ������� ������ �� ����� "�������",'#13#10+
  '������������� � ������������� ��������������.'#13#10+
  '������ ����� � �� ���� ����� ����������� �������������.'#13#10+
  '������ �� ���� ����� �������� ��������������� � ������� � ������� ��� ��������� �������� ������� �� ���,'#13#10+
  '��� ����������� � �������� ������������ (������� ���� ������ � ����� "������� �������" � ������� �������� �������� � ���)'#13#10+
  ''#13#10+
  '��������������� ���� �������� ������� � ��������� �� ��� ���� ������!'#13#10+
  ''
  ]];
  Result := inherited;
end;

procedure TFrmOGedtSgpRevision.Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string);
begin
  if Mode <> dbgvCell then Exit;
  Fr.SetValue('qnt_diff', Row - 1, True, Fr.GetValueF('qnt_fact', Row - 1) - Fr.GetValueF('qnt', Row - 1));
end;

procedure TFrmOGedtSgpRevision.VerifyBeforeSave;
var
  i, cntin, cntout: Integer;
begin
  FErrorMessage := '';
  cntin := 0;
  cntout := 0;
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    if Frg1.GetValue('qnt_fact', i, False) = null then
      Continue
    else if Frg1.GetValue('qnt_fact', i, False) > Frg1.GetValueF('qnt', i, False) then
      inc(cntin)
    else if Frg1.GetValue('qnt_fact', i, False) < Frg1.GetValueF('qnt', i, False) then
      inc(cntout);
  end;
  if (cntin = 0) and (cntout = 0) then begin
    FErrorMessage := '��� ����������� ��� ������ �� �������. ���� ������������� � �������� ������������ �� �����!';
    Exit;
  end;
  if cntin > 0 then
    FErrorMessage := '?����� ����������� ��� ������������� �� ' + S.GetEndingFull(cntin, '������', '�', '�', '�') + '.';
  if cntout > 0 then
    FErrorMessage := '?����� ����������� ��� ������� �� ' + S.GetEndingFull(cntout, '������', '�', '�', '�') + '.';
end;

function TFrmOGedtSgpRevision.Save: Boolean;
var
  i, idi: Integer;
  qnt: Extended;
  va1, va2: TVarDynArray2;
  fld: string;
begin
  va1 := [];
  va2 := [];
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    if Frg1.GetValue('qnt_fact', i, False) = null then
      Continue;
    idi := Frg1.GetValueI('id', i, False);
    qnt := Frg1.GetValueF('qnt_fact', i, False) - Frg1.GetValueF('qnt', i, False);
    if qnt > 0 then
      va1 := va1 + [[idi, qnt]]
    else
      va2 := va2 + [[idi, qnt]];
  end;
  Q.QBeginTrans(True);
  if Length(va1) > 0 then begin
    idi := Q.QIUD('i', 'sgp_act_in', '', 'id$i;id_format$i;id_user$i;dt$d;comm$s', [-1, id, User.GetId, Now, '']);
    for i := 0 to High(va1) do
      Q.QIUD('i', 'sgp_act_in_items', '-', 'id_act_in$i;' + S.IIf(ID = 0, 'id_or_item$i', 'id_std_item$i') + ';qnt$f',
       [idi, va1[i][0], va1[i][1]]
      );
  end;
  if Length(va2) > 0 then begin
    idi := Q.QIUD('i', 'sgp_act_out', '', 'id$i;id_format$i;id_user$i;dt$d;comm$s', [-1, id, User.GetId, Now, '']);
    for i := 0 to High(va2) do
      Q.QIUD('i', 'sgp_act_out_items', '-', 'id_act_out$i;' + S.IIf(ID = 0, 'id_or_item$i', 'id_std_item$i') + ';qnt$f',
        [idi, va2[i][0], va2[i][1]]
      );
  end;
  Result := Q.QCommitOrRollback;
end;


end.
