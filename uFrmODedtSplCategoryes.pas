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
    E_UserNames: TDBEditEh;
    E_Name: TDBEditEh;
    procedure E_UserNamesEditButtons0Click(Sender: TObject; var Handled: Boolean);
  private
    function Prepare: Boolean; override;
  public
  end;

var
  FrmODedtSplCategoryes: TFrmODedtSplCategoryes;

implementation

uses
  D_SelectUsers
  ;


{$R *.dfm}

function TFrmODedtSplCategoryes.Prepare: Boolean;
begin
  Caption:='Категории заявок на снабжение';
  F.DefineFields:=[
    ['id$i'],
    ['name$s','V=1:50'],
    ['usernames$s;0','V=0:4000'],
    ['useravail$s']
  ];
  View:='v_spl_categoryes';
  Table:='spl_categoryes';
  FOpt.InfoArray := [[
  'Реадктирование категории заявок на снабжение.'#13#10+
  'Введите наименование категории и выберите пользователей,'#13#10+
  'которые могут формировать по ним заявки.'#13#10
  ]];
{  MinWidth:=400;
  MinHeight:=148;
  MaxHeight:=148;}
  FWHBounds.Y2 := -1;
  Result:=inherited;
  E_UserNames.ReadOnly := True;
  //не удаляем категорию с айди = 1
  if (Mode = fDelete)and(F.GetPropB('id') = 1)
    then BtOk.Enabled:=False;
end;


procedure TFrmODedtSplCategoryes.E_UserNamesEditButtons0Click(Sender: TObject; var Handled: Boolean);
var
  NewIds, NewNames: string;
begin
  if Dlg_SelectUsers.ShowDialog(FormDoc + '_1', S.NSt(F.GetPropB('useravail')), True, NewIds, NewNames) <> mrOk then
    Exit;
  E_UserNames.Value := NewNames;
  F.SetProp('useravail', NewIds);
end;

end.
