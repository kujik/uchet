unit uFrmOWedtProdCalculation;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls,
  ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls, MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd,
  MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils, Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uTurv, uNamedArr,
  uFrmBasicDbDialog, Vcl.Mask
  ;

type
  TFrmOWedtProdCalculation = class(TFrmBasicDbDialog)
    pnlTop: TPanel;
    edt_name: TDBEditEh;
    pgcMain: TPageControl;
    ts1: TTabSheet;
    Frg1: TFrDBGridEh;
    ts2: TTabSheet;
    ts3: TTabSheet;
    ts4: TTabSheet;
    Frg2: TFrDBGridEh;
    ts5: TTabSheet;
    Frg5: TFrDBGridEh;
    Frg3: TFrDBGridEh;
    Frg4: TFrDBGridEh;
    tsEconomic: TTabSheet;
    nedt_markup_percent: TDBNumberEditEh;
    nedt_purchase_sum: TDBNumberEditEh;
    nedt_overall_coeff: TDBNumberEditEh;
    nedt_sales_sum: TDBNumberEditEh;
    nedt_sales_sum_from_items: TDBNumberEditEh;
    nedt_coeff_from_items: TDBNumberEditEh;
  private
    //имя_таблицы, поля, с единицы
    FTablesData: TVarDynArray2;
    //настройки при создании формы
    function  Prepare: Boolean; override;
    //инициализитруем гриды и загрузим в них данные
    procedure PrepareAndLoadGrids;
    //сохранение данных
    function  Save: Boolean; override;
    //событие изменения сонтролов
    procedure ControlOnChange(Sender: TObject); override;
    //события гридов
    procedure FrgButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
    procedure FrgCellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
    procedure FrgUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
    procedure FrgCellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
    procedure FrgGetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
    /// посчтиать все поля в строке. если Row = -1 то берется текущая
    procedure CalculateOneRow(var Fr: TFrDBGridEh; const No: Integer; Row: Integer = 1);
    /// посчитать весь грид
    procedure CalculateAllRows(var Fr: TFrDBGridEh; const No: Integer);
    /// настройка полей гридов
    function  GetGridParams(ANo: Integer; var AName, ATable: string; var AFields: TVarDynArray2): Boolean;
    /// сохранение гридов в БД
    procedure SaveGrids;
    /// Рассчитать данные на вкладке Финансы, в том числе  на основе данных гридов
    procedure CalcFinance;
  public
  end;

var
  FrmOWedtProdCalculation: TFrmOWedtProdCalculation;

implementation

{$R *.dfm}

uses
  uWindows
;



function TFrmOWedtProdCalculation.Prepare: Boolean;
var
  i, j: Integer;
  c: TControl;
  va2: TVarDynArray2;
begin

  Result := False;
  Caption := 'Просчет';
  FOpt.RefreshParent := True;
  F.DefineFields := [
    ['id$i'],
    ['id_prod_calc$i', #0, AddParam],
    ['name$s','V=1:400::T'],
    ['purchase_sum$f'],                       //бщая сумма закупки
    ['markup_percent$f', 'v=0:1000:2:N'],     //запас цены, %
    ['overall_coeff$f', 'v=0.01:1000:2:N'],   //общий коэффициент, число ввод
    ['sales_sum$f'],
    ['sales_sum_from_items$f'],
    ['coeff_from_items$f']
  ];
  View := 'v_prod_calc_items';
  Table := 'prod_calc_items';
  Cth.AlignControls(tsEconomic, [], False);
  FOpt.InfoArray:=[[
    'Просчет.'#13#10+
    ''#13#10
  ]];
  Result := inherited;
  if not Result then
    Exit;
  F.SetProp('id_prod_calc$i', AddParam);
  SetControlsEditable([nedt_purchase_sum, nedt_sales_sum, nedt_sales_sum_from_items, nedt_coeff_from_items], False, False);
  PrepareAndLoadGrids;
  pgcMain.TabIndex := 0;
  Result := True;
end;

procedure TFrmOWedtProdCalculation.PrepareAndLoadGrids;
var
  Frg: TFrDBGridEh;
  LFields: TVarDynArray2;
  LName, LTable, LFieldsSt: string;
  LData: TNamedArr;
  LAssembly: TVarDynArray;
begin
  FTablesData := [['','']];
  LAssembly := Q.QLoadToVarDynArrayOneCol('select name from prod_calc_refs where type = ''assembly'' order by id', []);
  for var i := 1 to 5 do begin
    GetGridParams(i, LName, LTable, LFields);
    TTabSheet(Self.FindComponent('ts' + IntToStr(i))).Caption := LName;
    Frg := TFrDBGridEh(Self.FindComponent('Frg' + IntToStr(i)));
    Frg.Options := [myogColoredTitle, myogIndicatorColumn, myogHiglightEditableColumns, myogHiglightEditableCells, myogHasStatusBar];
    Frg.Opt.SetFields(LFields);
    Frg.OnButtonClick := FrgButtonClick;
    Frg.OnCellButtonClick := FrgCellButtonClick;
    Frg.OnGetCellReadOnly := FrgGetCellReadOnly;
    Frg.OnColumnsUpdateData := FrgUpdateData;
    Frg.OnCellValueSave := FrgCellValueSave;
    Frg.Opt.SetGridOperations('uiad');
    Frg.Opt.SetButtons(-3, 'aidcs', True, cbttSSmall);
    Frg.Opt.Caption := '~' + LName;
    LFieldsSt := Frg.GetFieldNamesEx('1', True).Implode(';');
    Frg.SetInitData([]);
    if Mode <> fAdd then
      Q.QLoadFromQuery('select * from ' + 'v_' + LTable + ' where id_prod_calc_item = :id$i order by name', [ID], LData);
    FTablesData := FTablesData + [[LTable, LFieldsSt]];
    Frg.SetInitData(LData);
    if  i = 1 then begin
      Frg1.Opt.SetPick('facing_id_banding_type', ['Авто', 'С 1й стороны', 'С 2х сторон'], [3, 1, 2], True, True);
      Frg1.Opt.SetPick('panel_type', Q.QLoadToVarDynArrayOneCol('select name from prod_calc_refs where type = ''panel_type'' order by id', []), [], False, True);
      Frg1.Opt.SetPick('panel_position', Q.QLoadToVarDynArrayOneCol('select name from prod_calc_refs where type = ''panel_position'' order by id', []), [], False, True);
    end;
    Frg.Opt.SetPick('assembly', LAssembly, [], False, True);
    Frg.Prepare;
    Frg.RefreshGrid;
    CalculateAllRows(Frg, i);
    Frg.SetState(False, False, null);
  end;
end;

function TFrmOWedtProdCalculation.Save: Boolean;
begin
  Q.QBeginTrans(True);
  Result := inherited Save;
  if Result then
    SaveGrids;
  Q.QCommitTrans;
  Result:=Q.CommitSuccess;
end;

procedure TFrmOWedtProdCalculation.ControlOnChange(Sender: TObject);
begin
  if Sender <> edt_name then
    CalcFinance;
  inherited;
end;

procedure TFrmOWedtProdCalculation.FrgButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if Mode in [fView, fDelete] then
    Exit;
  Handled := True;
  if Tag = mbtDelete then begin
    Fr.DeleteRow;
    CalculateAllRows(Fr, No);
    Fr.SetState(True, S.IIf(Fr.GetCount(False) = 0, False, null), null);
  end
  else if Tag = mbtAdd then begin
    Fr.AddRow(Fr.GetCount(False) = 0);
    CalculateAllRows(Fr, No);
    Fr.SetState(True, null, null);
  end
  else if Tag = mbtInsert then begin
    Fr.InsertRow(Fr.GetCount(False) = 0);
    CalculateAllRows(Fr, No);
    Fr.SetState(True, null, null);
  end
  else begin
    Handled := False;
    inherited;
  end;
end;

procedure TFrmOWedtProdCalculation.FrgCellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
var
  LHandled: Boolean;
begin
  Wh.SelectDialogResult := [];
  Wh.ExecReference(myfrm_R_Itm_Nomencl_SEL, Self, [myfoDialog, myfoModal, myfoSizeable], null);
  if Length(Wh.SelectDialogResult) = 0 then
    Exit;
  Fr.SetValue('id_' + Fr.CurrField, Wh.SelectDialogResult[0]);
  Fr.SetValue(Fr.CurrField, Wh.SelectDialogResult[2]);
  Fr.SetValue(StringReplace(Fr.CurrField, 'name', 'price0', []), Wh.SelectDialogResult[4]);
  FrgCellValueSave(Fr, No, Fr.CurrField, null, LHandled);
end;

procedure TFrmOWedtProdCalculation.FrgUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
end;

procedure TFrmOWedtProdCalculation.FrgCellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
begin
  Fr.SetState(True, null, null);
  if Fr.RecNo > 1 then
    for var st in ['waste', 'markup', 'facing_waste', 'facing_markup'] do
      if Fr.IsFieldExists(st) then
        Fr.SetValue(st, Fr.RecNo - 1, False, Fr.GetValueF(st, Fr.RecNo - 2, False));
  CalculateOneRow(Fr, No, -1);
end;

procedure TFrmOWedtProdCalculation.FrgGetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
  ReadOnly := False;
end;

procedure TFrmOWedtProdCalculation.CalculateOneRow(var Fr: TFrDBGridEh; const No: Integer; Row: Integer = 1);
var
  LIsValid: Boolean;
begin
  if (Row = -1) and (Fr.GetCount = 0) then
    Exit;
  if Row = -1 then
    Row := Fr.RecNo - 1;
  LIsValid := True;
  if No = 1 then begin
   Fr.SetValue('consumption', Row,False, Fr.GetValueF('length', Row, False) * Fr.GetValueF('width', Row, False) * Fr.GetValueF('waste', Row, False) * Fr.GetValueF('qnt', Row, False));
    Fr.SetValue('sum0', Row, False, Fr.GetValueF('price0', Row, False) * Fr.GetValueF('consumption', Row, False));
    Fr.SetValue('sum', Row, False, Fr.GetValueF('sum0', Row, False) * Fr.GetValueF('markup', Row, False));
    if Fr.GetValueI('facing_id_banding_type', Row, False) = 0 then
      Fr.SetValue('facing_consumption', Row, False, null)
    else if Fr.GetValueI('facing_id_banding_type', Row, False) = 3 then
      Fr.SetValue('facing_consumption', Row, False, Fr.GetValueF('length', Row, False) * Fr.GetValueF('width', Row, False) * Fr.GetValueF('qnt', Row, False) * Fr.GetValueF('facing_waste', Row, False))
    else
      Fr.SetValue('facing_consumption', Row, False, Fr.GetValueF('facing_length', Row, False) * Fr.GetValueF('facing_width', Row, False) * Fr.GetValueF('facing_waste', Row, False) *
        Fr.GetValueF('facing_qnt', Row, False) * Fr.GetValueF('facing_id_banding_type', Row, False));
    Fr.SetValue('facing_sum0', Row, False, Fr.GetValueF('facing_price0', Row, False) * Fr.GetValueF('facing_consumption', Row, False));
    Fr.SetValue('facing_sum', Row, False, Fr.GetValueF('facing_sum0', Row, False) * Fr.GetValueF('facing_markup', Row, False));
    LIsValid := (Fr.GetValueS('name', Row, False) <> '') and (Fr.GetValueF('sum0', Row, False) <> 0) and (Fr.GetValueF('sum', Row, False) <> 0);
    if LIsValid then
      LIsValid := (Fr.GetValueS('facing_name', Row, False) = '') or (Fr.GetValueS('facing_name', Row, False) <> '') and (Fr.GetValueF('facing_sum0', Row, False) <> 0) and (Fr.GetValueF('facing_sum', Row, False) <> 0);
  end
  else if No = 3 then begin
    Fr.SetValue('consumption', Row,False, Fr.GetValueF('length', Row, False)  * Fr.GetValueF('waste', Row, False) * Fr.GetValueF('qnt', Row, False));
    Fr.SetValue('sum0', Row, False, Fr.GetValueF('price0', Row, False) * Fr.GetValueF('consumption', Row, False));
    Fr.SetValue('sum', Row, False, Fr.GetValueF('sum0', Row, False) * Fr.GetValueF('markup', Row, False));
    Fr.SetValue('facing_consumption', Row, False, Fr.GetValueF('length', Row, False) * Fr.GetValueF('width', Row, False) * Fr.GetValueF('qnt', Row, False) * Fr.GetValueF('facing_waste', Row, False));
    Fr.SetValue('facing_sum0', Row, False, Fr.GetValueF('facing_price0', Row, False) * Fr.GetValueF('facing_consumption', Row, False));
    Fr.SetValue('facing_sum', Row, False, Fr.GetValueF('facing_sum0', Row, False) * Fr.GetValueF('facing_markup', Row, False));
    LIsValid := (Fr.GetValueS('name', Row, False) <> '') and (Fr.GetValueF('sum0', Row, False) <> 0) and (Fr.GetValueF('sum', Row, False) <> 0);
    if LIsValid then
      LIsValid := (Fr.GetValueS('facing_name', Row, False) = '') or (Fr.GetValueS('facing_name', Row, False) <> '') and (Fr.GetValueF('facing_sum0', Row, False) <> 0) and (Fr.GetValueF('facing_sum', Row, False) <> 0);
  end
  else begin
    Fr.SetValue('sum0', Row, False, Fr.GetValueF('price0', Row, False) * Fr.GetValueF('consumption', Row, False));
    Fr.SetValue('sum', Row, False, Fr.GetValueF('sum0', Row, False) * Fr.GetValueF('markup', Row, False));
    LIsValid := (Fr.GetValueS('name', Row, False) <> '') and (Fr.GetValueF('sum0', Row, False) <> 0) and (Fr.GetValueF('sum', Row, False) <> 0);
  end;
  Fr.SetValue('error', Row, False, S.IIf(LIsValid, 0, 1));
  Fr.SetState(null, not LIsValid, null);
  Fr.InvalidateGrid;
  CalcFinance;
end;

procedure TFrmOWedtProdCalculation.CalculateAllRows(var Fr: TFrDBGridEh; const No: Integer);
begin
  for var i := 0 to Fr.GetCount(False) - 1 do
    CalculateOneRow(Fr, No, i);
  //без этого не обновляет сумму после начальной загрузки
  Fr.RecalcSum;
  CalcFinance;
end;

function TFrmOWedtProdCalculation.GetGridParams(ANo: Integer; var AName, ATable: string; var AFields: TVarDynArray2): Boolean;
begin
  var sBtN := 'bt=-Выбрать номенклатуру:6';
  case ANo of
    1:
      begin
        AName := 'Пллитные материалы / стекло';
        ATable := 'prod_calc_boards';
        AFields:=[
          ['id$i','_id','100','t=1'],
          ['id_prod_calc_item$i','_idpc','40'],
          ['pos$i','_№','80'],
          ['id_name$i','_id_name','40','t=1'],
          ['id_facing_name$i','_id_facing_name','40','t=1'],
          ['changed$i','_ch','40'],
          ['error$i', 'x', '25', 'pic=0;1:1;6'],
          ['assembly$s','Узел изделия','150','t=1','e=0:100::T'],
          ['panel_type$s','Материалы основвы|Панель|Тип','150','t=1','e','e=0:100::T'],
          ['panel_position$s','!Панель|Расположение','150','t=1','e','e=0:100::T'],
          ['name$s','!Материал','300;h',sBtN],
          ['info$s','!Дополнительная информация','200;w;h','t=1','e','e=0:400::T'],
          ['length$f','!Длина, м.','60','t=1','e=0.001:100:3:N'],
          ['width$f','!Ширина, м.','60','t=1','e=0.001:100:3:N'],
          ['qnt$i','!Количество, шт.','60','t=1','e=1:100000:0:N'],
          ['waste$f','!Отходы','60','t=1','e=0:100:2:N'],
          ['consumption$f','!Расход, м.кв.','60'],
          ['price0$f','!Закупка, руб/кв.м.','60','f=r','t=1','e=0.01:10000000:2'],
          ['sum0$f','!Закупка, сумма','60','f=r:'],
          ['markup$f','!Наценка','60','t=1','e=0:100:2'],
          ['sum$f','!Продажа, сумма','60','f=r:'],

          ['facing_name$s','Материалы облицовки|Облицовка','300;h',sBtN],
          ['facing_length$f','!Длина, м.','60','t=1','e=0.001:100:3'],
          ['facing_width$f','!Ширина, м.','60','t=1','e=0.001:100:3'],
          ['facing_qnt$i','!Количество, шт.','60','t=1','e=1:1000000000:0'],
          ['facing_waste$f','!Отходы','60','t=1','e=0:100:2'],
          ['facing_id_banding_type$i','!Заполнение','80;L','t=1','e=-1:100:0'],
          ['facing_consumption$f','!Расход, м.кв.','60'],
          ['facing_price0$f','!Закупка, руб/м.кв.','60','f=r','t=1','e=0:10000000:2'],
          ['facing_sum0$f','!Закупка, сумма','60','f=r:'],
          ['facing_markup$f','!Наценка','60','t=1','e=0:100:2'],
          ['facing_sum$f','!Продажа, сумма','60','f=r:']
        ];
      end;
    2:
      begin
        AName := 'Кромка';
        ATable := 'prod_calc_edges';
        AFields:=[
          ['id$i','_id','100','t=1'],
          ['id_prod_calc_item$i','_idpc','40'],
          ['pos$i','_№','80'],
          ['id_name$i','_id_name','40','t=1'],
          ['changed$i','_ch','40'],
          ['error$i', 'x', '25', 'pic=0;1:1;6'],
          ['assembly$s','Узел изделия','150','t=1','e=0:100::T'],
          ['name$s','Материал','300;w;h',sBtN],
          ['info$s','Дополнительная информация','200;w;h','t=1','e=0:400::T'],
          ['consumption$f','Расход, м.п.','60','e=0.001:1000000000:3','t=1'],
          ['price0$f','Закупка, руб/м.п.','60','t=1','f=r','e=0.01:10000000:2'],
          ['sum0$f','Закупка, сумма','60','f=r:'],
          ['markup$f','Наценка','60','t=1','e=0:100:2'],
          ['sum$f','Продажа, сумма','60','f=r:']
        ];
      end;
    3:
      begin
         AName := 'Профильные детали';
         ATable := 'prod_calc_profiles';
         AFields:=[
          ['id$i','_id','100','t=1'],
          ['id_prod_calc_item$i','_idpc','40'],
          ['pos$i','_№','80'],
          ['id_name$i','_id_name','40','t=1'],
          ['id_facing_name$i','_id_facing_name','40','t=1'],
          ['changed$i','_ch','40'],
          ['error$i', 'x', '25', 'pic=0;1:1;6'],
          ['assembly$s','Узел изделия','150','t=1','e=0:100::T'],
          ['name$s','Материалы профилей|Материал','300;w;h',sBtN],
          ['info$s','!Дополнительная информация','200;w;h','t=1','e=0:400::T'],
          ['length$f','!Длина, м.','60','t=1','e=0.001:1000000000:3'],
          ['width$f','!Сечение, м.','60','t=1','e=0.001:100:3:N'],
          ['qnt$i','!Количество, шт.','60','t=1','e=1:1000000000:0'],
          ['waste$f','!Отходы','60','t=1','e=0:100:2:N'],
          ['consumption$f','!Расход, м.п.','60'],
          ['price0$f','!Закупка, руб/м.п.','60','t=1','f=r','e=0.01:10000000:2'],
          ['sum0$f','!Закупка, сумма','60','f=r:'],
          ['markup$f','!Наценка','60','t=1','e=0:100:2'],
          ['sum$f','!Продажа, сумма','60','f=r:'],

          ['facing_name$s','Материалы облицовки|Облицовка','300;h',sBtN],
          ['facing_waste$f','!Отходы','60','t=1','e=0:100:2'],
          ['facing_consumption$f','!Расход, м.кв.','60'],
          ['facing_price0$f','!Закупка, руб/м.кв.','60','f=r','t=1','e=0:10000000:2'],
          ['facing_sum0$f','!Закупка, сумма','60','f=r:'],
          ['facing_markup$f','!Наценка','60','t=1','e=0:100:2'],
          ['facing_sum$f','!Продажа, сумма','60','f=r:']
        ];
      end;
    4:
      begin
         AName := 'Фурнитура';
         ATable := 'prod_calc_furniture';
         AFields:=[
          ['id$i','_id','100','t=1'],
          ['id_prod_calc_item$i','_idpc','40'],
          ['pos$i','_№','80'],
          ['id_name$i','_id_name','40','t=1'],
          ['changed$i','_ch','40'],
          ['error$i', 'x', '25', 'pic=0;1:1;6'],
          ['assembly$s','Узел изделия','150','t=1','e=0:100::T'],
          ['name$s','Материал','300;w;h',sBtN],
          ['info$s','Дополнительная информация','200;w;h','t=1','e=0:400::T'],
          ['consumption$i','Количество, шт.','60','t=1','e=1:1000000000:0'],
          ['price0$f','Закупка, руб/шт.','60','t=1','f=r','e=0.01:10000000:2'],
          ['sum0$f','Закупка, сумма','60','f=r:'],
          ['markup$f','Наценка','60','t=1','e=0:100:2'],
          ['sum$f','Продажа, сумма','60','f=r:']
        ];
      end;
    5:
      begin
        AName := 'Электрика';
        ATable := 'prod_calc_electric';
        AFields:=[
          ['id$i','_id','100','t=1'],
          ['id_prod_calc_item$i','_idpc','40'],
          ['pos$i','_№','80'],
          ['id_name$i','_id_name','40','t=1'],
          ['changed$i','_ch','40'],
          ['error$i', 'x', '25', 'pic=0;1:1;6'],
          ['assembly$s','Узел изделия','150','e=0:100::T','t=1'],
          ['name$s','Материал','300;w;h',sBtN],
          ['info$s','Дополнительная информация','200;w;h','t=1','e=0:400::T'],
          ['consumption$i','Количество, шт.','60','t=1','e=1:1000000000:0'],
          ['price0$f','Закупка, руб/шт.','60','t=1','f=r','e=0.01:10000000:2'],
          ['sum0$f','Закупка, сумма','60','f=r:'],
          ['markup$f','Наценка','60','t=1','e=0:100:2'],
          ['sum$f','Продажа, сумма','60','f=r:']
        ];
      end;
  end;
end;

procedure TFrmOWedtProdCalculation.SaveGrids;
var
  Frg: TFrDBGridEh;
begin
  for var i := 1 to 5 do begin
    Frg := TFrDBGridEh(Self.FindComponent('Frg' + IntToStr(i)));
    if Length(Frg.EditData.IdsDeleted) > 0 then
      Q.QExecSql('delete from ' + FTablesData[i][0] + ' where id in (' + A.Implode(Frg.EditData.IdsDeleted, ',') + ')', []);
    for var j := 0 to Frg.GetCount(False) - 1 do begin
//      if Frg.GetValueI('changed', j, False) = 1 then
      if Frg.IsRowChanged(j, False) then
        Q.QIUD(S.IIf(Frg.GetValueI('id', j, False) >= MY_IDS_INSERTED_MIN, 'i', 'u'), FTablesData[i][0], '', FTablesData[i][1] + ';id_prod_calc_item$i', Frg.GetValuesArr(FTablesData[i][1].AsString, j, False) + [ID]);
    end;
  end;
end;

procedure TFrmOWedtProdCalculation.CalcFinance;
var
  Frg: TFrDBGridEh;
  LPurchaseSum, LSalesSum: Extended;
begin
  LPurchaseSum := 0;
  LSalesSum := 0;
  for var i := 1 to 5 do begin
    Frg := TFrDBGridEh(Self.FindComponent('Frg' + IntToStr(i)));
    LPurchaseSum := LPurchaseSum + Frg.GetFuterValue('sum0', False).AsFloat;
    LSalesSum := LSalesSum + Frg.GetFuterValue('sum', False).AsFloat;
    if i in [1, 3] then begin
      LPurchaseSum := LPurchaseSum + Frg.GetFuterValue('facing_sum0', False).AsFloat;
      LSalesSum := LSalesSum + Frg.GetFuterValue('facing_sum', False).AsFloat;
    end;
  end;
  LPurchaseSum := Round(LPurchaseSum);
  LSalesSum := Round(LSalesSum);
  nedt_purchase_sum.Value := LPurchaseSum;
  nedt_sales_sum_from_items.Value := LSalesSum;
  nedt_sales_sum.Value := Round(LPurchaseSum * ((nedt_markup_percent.Value.AsFloat + 100) / 100) * nedt_overall_coeff.Value.AsFloat);
  nedt_coeff_from_items.Value := null;
  if LPurchaseSum <> 0 then
    nedt_coeff_from_items.Value := RoundTo(LSalesSum / LPurchaseSum, -2);
end;


end.


