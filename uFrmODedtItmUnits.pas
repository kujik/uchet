unit uFrmODedtItmUnits;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFields, uFrmBasicDbDialog,
  Vcl.Mask
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
  Caption:='≈диница измерени€';
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
    '¬вод единицы измерени€.'#13#10+
    '≈сли будет найдена похожа€ единица измерени€, то будет выдыно предупреждение!'#13#10+
    ''#13#10
  ]];
{  AutoSaveWindowPos:= True;
  MinWidth:=295;
  MinHeight:=200;}
  Result:=inherited;
end;


procedure TFrmODedtItmUnits.VerifyBeforeSave;
//проверим, нет ли похожей единицы измерени€ (по краткому наименованию)
//дл€ этого приведем к верхнему регистру и уберем из наименований точки и пробелы
//в итм нет даже уникальногшо индекса по имени ед.изм.
//если вернет в Result True, то будет выдано сообщение "ƒанные не корректны!"
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
    FErrorMessage := '?≈диница измерени€ с похожим названием уже существует:'#13#10 + S.NSt(va[i]) + #13#10'¬се равно создать?'
  else
    FErrorMessage := '';
end;

function TFrmODedtItmUnits.LoadComboBoxes: Boolean;
begin
  Q.QLoadToDBComboBoxEh('select name, id_measuregroup from dv.groups_measure order by name', [], cmb_Id_MeasureGroup, cntComboLK);
  Result:=True;
end;


end.
