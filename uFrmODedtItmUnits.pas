unit uFrmODedtItmUnits;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions, Vcl.Mask,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2, uFrmBasicInput, uFields, uFrmBasicDbDialog
  ;

type
  TFrmODedtItmUnits = class(TFrmBasicDbDialog)
    cmb_Id_MeasureGroup: TDBComboBoxEh;
    edt_Name_Unit: TDBEditEh;
    nedt_Full_Name: TDBEditEh;
    nedt_Pression: TDBNumberEditEh;
  private
    function  Prepare: Boolean; override;
    function  LoadComboBoxes: Boolean; override;
    procedure VerifyBeforeSave; override;
  public
  end;

var
  FrmODedtItmUnits: TFrmODedtItmUnits;

implementation

{$R *.dfm}

function TFrmODedtItmUnits.Prepare: Boolean;
begin
  Caption:='������� ���������';
  F.DefineFields:=[
    ['id_unit$i'],
    ['id_measuregroup$i','V=1:200',#0,0],
    ['name_unit$s','V=1:50:0:T'],
    ['full_name$s','V=1:200:0:T'],
    ['pression$i','V=0:5:0:N',#0,1]
  ];
//  Fields:='id_unit$i;id_measuregroup$i;name_unit$s;full_name$s;pression$i';
  View:='v_itm_units';
  Table:='dv.unit';
//  CtrlVerifications:=['','1:200','1:50:0:T','1:200:0:T','0:5:0:N'];
//  CtrlValuesDefault:=[-1, 0, '', '', 1];
  FOpt.InfoArray:=[[
    '���� ������� ���������.'#13#10+
    '���� ����� ������� ������� ������� ���������, �� ����� ������ ��������������!'#13#10+
    ''#13#10
  ]];
{  AutoSaveWindowPos:= True;
  MinWidth:=295;
  MinHeight:=200;}
  Result:=inherited;
end;


procedure TFrmODedtItmUnits.VerifyBeforeSave;
//��������, ��� �� ������� ������� ��������� (�� �������� ������������)
//��� ����� �������� � �������� �������� � ������ �� ������������ ����� � �������
//� ��� ��� ���� ������������ ������� �� ����� ��.���.
//���� ������ � Result True, �� ����� ������ ��������� "������ �� ���������!"
var
  va: TVarDynArray;
  i: Integer;
  st1, st2: string;
begin
  if Mode = fDelete then
    Exit;
  st1 := S.ToUpper(StringReplace(StringReplace(edt_Name_Unit.Text, ' ', '', [rfReplaceAll]), '.', '', [rfReplaceAll]));
  va := Q.QLoadToVarDynArrayOneCol('select name_unit from dv.unit where id_unit <> :id$i', [id]);
  i := 0;
  for i := 0 to High(va) do
    if st1 = S.ToUpper(StringReplace(StringReplace(va[i], ' ', '', [rfReplaceAll]), '.', '', [rfReplaceAll])) then
      Break;
  if i <= High(va) then
    FErrorMessage := '?������� ��������� � ������� ��������� ��� ����������:'#13#10 + S.NSt(va[i]) + #13#10'��� ����� �������?'
  else
    FErrorMessage := '';
end;

function TFrmODedtItmUnits.LoadComboBoxes: Boolean;
begin
  Q.QLoadToDBComboBoxEh('select name, id_measuregroup from dv.groups_measure order by name', [], cmb_Id_MeasureGroup, cntComboLK);
  Result:=True;
end;


end.
