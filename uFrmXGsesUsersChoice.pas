unit uFrmXGsesUsersChoice;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uFrmBasicEditabelGrid, uLabelColors
  ;

type
  TFrmXGsesUsersChoice = class(TFrmBasicEditabelGrid)
  private
    function  PrepareForm: Boolean; override;
  public
    class function ShowDialog(AOwner: TComponent; var AIds: string; var ANames: string): Integer;
  end;

var
  FrmXGsesUsersChoice: TFrmXGsesUsersChoice;

implementation

{$R *.dfm}

function TFrmXGsesUsersChoice.PrepareForm: Boolean;
begin
  Caption:='Выбор пользователей';
  Frg1.Options := FrDBGridOptionDef + [myogMultiselect, myogIndicatorCheckBoxes];
  Mode := fEdit;
  Frg1.Opt.SetFields([
    ['id$i','id','100'],
    ['name$s','Пользователь','300;w;h'],
    ['value$i','Выбран','80','e','chb']
  ]);
//  Frg1.Opt.SetGridOperations('uaid');
  Frg1.SetInitData('select id, name, 0 as value from adm_users order by name',[]);
end;

class function TFrmXGsesUsersChoice.ShowDialog(AOwner: TComponent; var AIds: string; var ANames: string): Integer;
var
  F: TForm;
begin
  F:= Create(AOwner, 'DlgUsersChoice', [myfoModal, myfoSizeable, myfoDialog], FEdit, null, null, []);
  Result := TFrmXGsesUsersChoice(F).ModalResult;
  AfterFormClose(F);
end;



end.
