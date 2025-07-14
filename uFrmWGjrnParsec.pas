{
������ ������� � ����� ����������
������ ������� �� �� Parsec � ������ ��������� �������

!!! �� ��������� ������ ����� ��������� �������� ������� (���������� ����� �����)
!!! �� ���������� ����������� ������, ����� ���� ����� ��������
}

unit uFrmWGjrnParsec;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2, uDBParsec
  ;

type
  TFrmWGjrnParsec = class(TFrmBasicGrid2)
  private
    function  PrepareForm: Boolean; override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    function  GetSql: string;
    procedure RefreshGrid;
  public
  end;

var
  FrmWGjrnParsec: TFrmWGjrnParsec;

implementation

{$R *.dfm}

function TFrmWGjrnParsec.PrepareForm: Boolean;
begin
  Caption := '������ �������/����� ����������';
  if not myDBParsec.Connect(True) then
    Exit;
  Frg1.Opt.SetFields([
    ['dt$d','����','140'],
    ['dt2$d','����','80'],
    ['event$s','�������','80'],
    ['name$s','��������','180'],
    ['id$s','_id_����','90']
  ]);
//  Frg1.Opt.SetSql(GetSql);
//  Frg1.Opt.FilterRules := [[], ['id']];
  Frg1.Opt.SetButtons(1, 'rsp');
  Frg1.CreateAddControls('1', cntCheck, '�����������', 'ChbGroup', '', -1, yrefC, 100);
  Frg1.CreateAddControls('1', cntCheck, '������ ���� ����', 'ChbMyOnly', '', -1, yrefC, 120);
  Frg1.ReadControlValues;
  Frg1.InfoArray:=[[
    '������ ������� ������� � ����� ����������.'#10#13+
    '������ ���������� �� �������� �������� ������� (Parsec).'#10#13+
    '����������� ������ �������, ����� ��������� ������ �������� (��������, ��������� 7 ����), � ���� �������� ������.'#10#13+
    '���� �� �������� ������� "������������", �� �� ������� ��������� ����� �������� ����� ������� � ����� � ����� ������, ����� ��� ����� ������ �������.'#10#13+
    '��������� ������� "������ ���� ����", ����� �������� ������� ������ �� ��� ����������, �� ������� �� ���������� ������ � ����.'#10#13+
    ''#10#13+
    '�����: ������, ������ �����, ����� �������� ������ � ������� �����!'#10#13
  ]];
//  Frg1.Opt.SetDataMode(myogdmFromArray);
  Frg1.ADODataDriverEh1.ConnectionProvider := myDBParsec.AdoConnectionProviderEh;
  Frg1.Prepare;
  Frg1AddControlChange(Frg1, 1, nil);
  Frg1.RefreshGrid;
  if Gh.GetGridColumn(Frg1.DBGridEh1, 'dt') <> nil then
    Gh.GetGridColumn(Frg1.DBGridEh1, 'dt').Title.Caption := S.IIFStr(Frg1.GetControlValue('ChbGroup') = 1, '������', '����');
  Result := True;
end;

procedure TFrmWGjrnParsec.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
var
  b: Boolean;
begin
  Frg1.Opt.SetSql(GetSql);
  b := Frg1.GetControlValue('ChbGroup') = 1;
  Frg1.Opt.SetColFeature('dt2', 'i', not b, False);
  Frg1.Opt.SetColFeature('event', 'i', b, False);
  if Gh.GetGridColumn(Frg1.DBGridEh1, 'dt') <> nil then
    Gh.GetGridColumn(Frg1.DBGridEh1, 'dt').Title.Caption := S.IIFStr(b, '������', '����');
  Frg1.SetColumnsVisible;
  if Frg1.IsPrepared then
    Frg1.RefreshGrid;
end;

function TFrmWGjrnParsec.GetSql: string;
var
  va1: TVarDynArray2;
  st, st1, st2: string;
  i:Integer;
begin
  st:='';
  if Frg1.GetControlValue('ChbMyOnly') = 1 then begin
    va1:=Q.QLoadToVarDynArray2(
      'select workername from v_j_worker_status where IsStInCommaSt(:userid$i, editusers) = 1',
      [User.GetId]
    );
    for i:=0 to High(va1) do st:=st + ',''' + va1[i][0] + '''';
    Delete(st, 1, 1);
    if st = ''
      then st:='~1'
      else st:=' concat(p.last_name, '' '', p.first_name, '' '', p.middle_name) in (' + st + ') and ';
  end;
  if Frg1.GetControlValue('ChbGroup') = 1
    then st2:='590144'
    else st2:='590145';
//st2:='590145';     st:='';
  Result :=
  'select '+
//  'TRY_CONVERT(DATETIME, format(dateadd(hour, 3, t.tran_date), ''YYYY-MM-DD HH:MI:SS''), 120) as dt, '+
  'dateadd(hour, 3, t.tran_date) as dt, '+
  '(select top(1) format(dateadd(hour, 3, tran_date), ''HH:mm'') from parsec3trans.dbo.translog pt where '+
  '  day(pt.tran_date) = day(t.tran_date) and '+
  '  pt.tran_date > t.tran_date '+
  '  and pt.trantype_id = 590145 and '+
  '  pt.usr_id = t.usr_id) '+
  'as dt2, '+
  'case '+
  'when tt.trantype_desc = ''���������� ���� �� �����'' then ''������'' '+
  'when tt.trantype_desc = ''���������� ����� �� �����'' then ''����'' '+
  'end as event, '+
  'concat(p.last_name, '' '', p.first_name, '' '', p.middle_name) as name, '+
  't.tran_date as id '+
  'from '+
  '  parsec3trans.dbo.translog as t '+
  '  left outer join '+
  '  parsec3.dbo.person as p '+
  '  on t.usr_id = p.pers_id '+
  '  left outer join '+
  '  parsec3.dbo.trantypes_desc tt '+
  '  on t.trantype_id = tt.trantype_id '+
  'where '+
  '  (t.trantype_id = ' + st2 + ' or t.trantype_id = 590144) '+
  '  and '+
  st +
  '  (tt.locale = ''RU'') '+
  '     ' +
  '     '+
   'order by tran_date desc '
  ;
//  Clipboard.AsText:=ADODataDriverEh1.SelectSQL.Text;
end;

procedure TFrmWGjrnParsec.RefreshGrid;
begin
//  Frg1.LoadSourceDataFromArray(myDBParsec.QLoadToVarDynArray2(GetSql, []), '', True);
end;




end.
