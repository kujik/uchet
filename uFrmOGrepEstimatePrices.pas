unit uFrmOGrepEstimatePrices;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uFrmBasicEditabelGrid, uLabelColors
  ;

type
  TFrmOGrepEstimatePrices = class(TFrmBasicEditabelGrid)
  private
    function  PrepareForm: Boolean; override;
    function  PrepareFormAdd: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure LoadFromXls;
  public
  end;

var
  FrmOGrepEstimatePrices: TFrmOGrepEstimatePrices;

implementation

{$R *.dfm}

uses
  uOrders,
  uWindows
  ;

function TFrmOGrepEstimatePrices.PrepareForm: Boolean;
var
  i: Integer;
//  o: TFrDBGridEditOptions;
  va: TVarDynArray;
begin
  Caption := 'Загрузка цен по смете';
  //прочитаем список групп и ед.изм.
  Orders.LoadBcadGroups(True);
  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['id_or_std_item$i','_id_or_std_item','40'],
    ['id_group$i','Группа','250;w;L'],
    ['name$s','Наименование','400;w;h'],
    ['id_unit$i','Ед.изм.','100;L'],
    ['qnt1$f','Кол-во','80'],
    ['null as purchase$i','_Покупка','80'],
    ['comm$s','Дополнение','300;w;h'],
    ['null as flags$s','_flags','40'],
    ['price$f','Цена','80','f=r'],
    ['sum$f','Сумма','80','f=r:r']
  ]);
  Frg1.Opt.SetPick('id_group', A.VarDynArray2ColToVD1(Orders.BcadGroups, 0), A.VarDynArray2ColToVD1(Orders.BcadGroups, 1), True);
  Frg1.Opt.SetPick('id_unit', A.VarDynArray2ColToVD1(Orders.BcadUnits, 0), A.VarDynArray2ColToVD1(Orders.BcadUnits, 1), True);
//  Frg1.Opt.SetTable('v_estimate', 'estimate_items');
  Frg1.Opt.SetGridOperations('');
  Frg1.SetInitData([]);
  Frg1.Opt.Caption := 'Сметные позиции';
  FOpt.InfoArray:= [[
    'Загрузите смету из xls-файла.'#13#10+
    'После этого по всем позициям, найденным в БД ИТМ, цены будут проставлены автоматически.'#13#10+
    '(цена загружается по последнему приходу данной номенклатуры, независимо от поставщика.)'#13#10
  ]];
  Result := inherited;
end;

function TFrmOGrepEstimatePrices.PrepareFormAdd: Boolean;
begin
  Frg1.Opt.SetButtons(4, [[mbtExcel, True, 'Загрузить смету из файла']],  cbttBSmall, pnlFrmBtnsR);
  Frg1.Opt.SetButtonsIfEmpty([mbtExcel]);
  Result := True;
end;

procedure TFrmOGrepEstimatePrices.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
//обработка нажатий кнопок фрейма
begin
  Handled := True;
  if Tag = mbtExcel then
    LoadFromXls
  else begin
    Handled := False;
    inherited;
  end;
end;

procedure TFrmOGrepEstimatePrices.LoadFromXls;
//загрузим смету из файла эксель
var
  i, j: Integer;
  Est: TVarDynArray2;
  FileName: string;
  va: TVarDynArray;
  va1, va2: TVarDynArray2;
  st : string;
  v: Variant;
begin
  FileName := '';
  //смету в массив
  if not Orders.EstimateFromFile(FileName, Est) then
    Exit;
  //массив в мемтейбл
  Frg1.LoadSourceDataFromArray(Est, 'name;id_group;id_unit;qnt1;comm', '');
  //получим последнюю цену (по последнему приходу любого поставщика)
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    v := Q.QSelectOneRow('select p.price_last from dv.nomenclatura n, v_spl_nom_lastibprice p where n.id_nomencl = p.id_nomencl (+) and n.name = :name$s and p.rn = 1', [Frg1.GetValue('name', i, False)])[0];
    if v <> null then begin
      v := RoundTo(v, -2);
      Frg1.SetValue('price', i, False, v);
      Frg1.SetValue('sum', i, False, RoundTo(v * Frg1.GetValue('qnt1', i, False), -2));
    end;
  end;
end;



end.
