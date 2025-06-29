unit uFrmODedtSplCategoryes;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions, Vcl.Mask,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2, uFrmBasicInput, uFields, uFrmBasicDbDialog
  ;

type
  TFrmODedtSplCategoryes = class(TFrmBasicDbDialog)
    edt_UserNames: TDBEditEh;
    edt_name: TDBEditEh;
    procedure edt_UserNamesEditButtons0Click(Sender: TObject; var Handled: Boolean);
  private
    FNewIds: string;
    function Prepare: Boolean; override;
  public
  end;

var
  FrmODedtSplCategoryes: TFrmODedtSplCategoryes;

implementation

uses
  uFrmXGsesUsersChoice
  ;


{$R *.dfm}

function TFrmODedtSplCategoryes.Prepare: Boolean;
begin
  Caption:='��������� ������ �� ���������';
  F.DefineFields:=[
    ['id$i'],
    ['name$s','V=1:50'],
    ['usernames$s;0','V=0:4000'],
    ['useravail$s']
  ];
  View:='v_spl_categoryes';
  Table:='spl_categoryes';
  FOpt.InfoArray := [[
  '�������������� ��������� ������ �� ���������.'#13#10+
  '������� ������������ ��������� � �������� �������������,'#13#10+
  '������� ����� ����������� �� ��� ������.'#13#10
  ]];
{  MinWidth:=400;
  MinHeight:=148;
  MaxHeight:=148;}
  FWHBounds.Y2 := -1;
  Result:=inherited;
  FNewIds := S.NSt(F.GetPropB('useravail'));
  edt_UserNames.ReadOnly := True;
  //�� ������� ��������� � ���� = 1
  if (Mode = fDelete)and(F.GetPropB('id') = 1)
    then btnOk.Enabled:=False;
end;


procedure TFrmODedtSplCategoryes.edt_UserNamesEditButtons0Click(Sender: TObject; var Handled: Boolean);
var
  NewNames: string;
begin
  if TFrmXGsesUsersChoice.ShowDialog(Application, True, FNewIDs, NewNames) <> mrOk then
    exit;
  edt_UserNames.Value := NewNames;
  F.SetProp('useravail', FNewIds);
end;

end.
