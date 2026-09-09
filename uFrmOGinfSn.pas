{
таблица подробной информации по различным параметрам для номенклатуры снабжения (минимальная партия,
резерв, в пути, расход, остатки на складах, приход, движение, расхождения по заказам, счета,
приходные накладные, по заявке, плановые заказы)

(09.09.2026) диалог заменяет собой D_Spl_InfoGrid.pas (построенный на промежуточном классе
F_MdiGridDialogTemplate.pas), который выводится из работы - переделан по образцу uFrmOGinfSgp.pas.
Логика веток (запросы, кнопки, двойные клики) перенесена как есть, включая ветку DiffInOrder,
которая была помечена автором как НЕ РАБОТАЕТ - её не чиним в рамках этого переноса.
}
unit uFrmOGinfSn;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh
  ;

type
  TFrmOGinfSn = class(TFrmBasicGrid2)
    lblCaption: TLabel;
  private
    function  PrepareForm: Boolean; override;
    procedure Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg2CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
  public
  end;

var
  FrmOGinfSn: TFrmOGinfSn;

implementation

uses
  uWindows,
  uSys,
  uFrmOWPlannedOrder
  ;

{$R *.dfm}

function TFrmOGinfSn.PrepareForm: Boolean;
var
  st: string;
  va: TVarDynArray;
begin
  Mode := fView;
  FOpt.DlgPanelStyle := dpsBottomRight;
  Frg1.InfoArray := [];
  //заголовок формы
  Caption := S.Decode([
     FormDoc,
     myfrm_Dlg_Spl_InfoGrid_MinPart, 'Минимальная партия',
     myfrm_Dlg_Spl_InfoGrid_Rezerv, 'Резерв',
     myfrm_Dlg_Spl_InfoGrid_OnWay, 'В пути',
     myfrm_Dlg_Spl_InfoGrid_Consumption, 'Расход',
     myfrm_Dlg_Spl_InfoGrid_QntOnStore, 'Остатки на складах',
     myfrm_Dlg_Spl_InfoGrid_Incoming, 'Приход за период',
     myfrm_Dlg_Spl_InfoGrid_MoveNomencl, 'Движение товара',
     myfrm_Dlg_Spl_InfoGrid_DiffInOrder, 'Расхождения по заказам',
     myfrm_Dlg_Spl_InfoGrid_SpSchetList, 'Счета по номенклатуре',
     myfrm_Dlg_Spl_InfoGrid_InBillList, 'Приходные накладные',
     myfrm_Dlg_Spl_InfoGrid_OnDemand, 'По заявке',
     myfrm_Dlg_Spl_InfoGrid_PlanneDOrders, 'Плановые заказы',
     'Информация'
  ]);
  //заголовочный лейбл - наименование номенклатуры, для которой открыта детализация
  //(передаётся вызывающей формой в AddParam[0], как и в старом D_Spl_InfoGrid.pas)
  lblCaption.Caption := VarToStr(AddParam[0]);

  if FormDoc = myfrm_Dlg_Spl_InfoGrid_MinPart then begin
    //минимальная партия по каждому поставщику данной номенклатуры
    Frg1.Opt.SetFields([
      ['id_supplier as id$i','_id','40'],
      ['supplier$s','Поставщик','250'],
      ['name$s','Наименование','300;h'],
      ['unit$s','Ед.изм.','80'],
      ['base_unit_k$f','Коэфф.','80'],
      ['minpart$f','Мин. партия','80']
    ]);
    Frg1.Opt.SetTable('v_spl_nomencl_minpart', '', 'id');
    Frg1.Opt.SetWhere('where id_nomencl = :id$i');
  end
  else if FormDoc = myfrm_Dlg_Spl_InfoGrid_Rezerv then begin
    //резерв номенклатуры по заказам
    Frg1.Opt.SetFields([
      ['numdoc as ornum$s','№ заказа','80','bt=Паспорт;Смета'],
      ['area_short$s','Площадка','80'],
      ['project$s','Проект','200;h'],
      ['dt_beg$d','Дата оформления','80'],
      ['dt_otgr$d','Дата отгрузки','80'],
      ['rashod$f','Кол-во','80','f=f:']
    ]);
    Frg1.Opt.SetTable('v_spl_rezerv_detail');
    Frg1.Opt.SetWhere('where id_nomencl = :id$i order by stockdate desc');
  end
  else if FormDoc = myfrm_Dlg_Spl_InfoGrid_OnWay then begin
    //в пути (по счетам поставщикам)
    Frg1.Opt.SetFields([
      ['id as id_schet$i','_id','40'],
      ['date_registr$d','Дата','80'],
      ['num$s','№ счета','100','bt=Открыть счет'],
      ['name_org$s','Поставщик','250;h'],
      ['quantity_suppl$f','Кол. поставщика','80','f=f:'],
      ['unit_suppl$s','Ед. поставщика','80'],
      ['nvl(quantity_main,0) as quantity_main$f','По счету','80','f=f:'],
      ['nvl(fact_quantity,0) as fact_quantity$f','По накладным','80','f=f:'],
      ['nvl(quantity_main,0) - nvl(fact_quantity,0) as rest$f','Остаток','80','f=f:']
    ]);
    Frg1.Opt.SetTable('v_spl_onway_detail');
    Frg1.Opt.SetWhere('where id_n = :id$i order by date_registr');
    //детализация по приходным накладным по данному счету (раскрывающаяся панель строки)
    Frg2.Opt.SetFields([
      ['id_inbill$i','_id','40'],
      ['dt$d','Дата','120'],
      ['num$s','№ накладной','120','bt=Открыть приходную накладную'],
      ['qnt$f','Кол-во','80','f=f:']
    ]);
    Frg2.Opt.SetTable('v_spl_onway_inbills_detail');
    Frg2.Opt.SetWhere('where id_nomencl = :idn2$i and docid = :idd2$i order by dt desc');
  end
  else if FormDoc = myfrm_Dlg_Spl_InfoGrid_Consumption then begin
    //документы по расходу за выбранный период (AddParam[2] - кол-во дней)
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['id_doc$i','_id_doc','40'],
      ['doctypename$s','Тип документа','100'],
      ['docnum$s','№ документа','100'],
      ['dt$d','Дата','80'],
      ['scladname$s','Со склада','100;h'],
      ['comm as ornum$s','Основание','150;h','bt=Паспорт;Смета'],
      ['qnt$f','Кол-во','80','f=f:']
    ]);
    Frg1.Opt.SetTable('v_spl_consumption');
    //05-09-24 убираем акты списания (doctype = 2)
    Frg1.Opt.SetWhere('where id_nomencl = :id$i and dt >= trunc(sysdate) - :d$i + 1 and doctype <> 2 order by dt');
  end
  else if FormDoc = myfrm_Dlg_Spl_InfoGrid_QntOnStore then begin
    //количество на складах
    Frg1.Opt.SetFields([
      ['skladname$s','Склад','200;h'],
      ['qnt$f','Кол-во','80','f=f:']
    ]);
    Frg1.Opt.SetTable('v_itm_qntonstore');
    Frg1.Opt.SetWhere('where id_nomencl = :id$i and id_sklad is not null and (not id_sklad in (842, 922)) order by skladname');
  end
  else if FormDoc = myfrm_Dlg_Spl_InfoGrid_Incoming then begin
    //документы по приходу за выбранный период (по приходным накладным, AddParam[2] - кол-во дней)
    Frg1.Opt.SetFields([
      ['td$s','Тип документа','120'],
      ['numdoc$s','№ документа','80'],
      ['stockdate$d','Дата','80'],
      ['basis$s','Основание','250;h'],
      ['prihod$f','Кол-во','80','f=f:']
    ]);
    Frg1.Opt.SetTable('v_itm_movenomencl');
    Frg1.Opt.SetWhere('where id_nomencl = :id$i and doctype in (1) and stockdate >= trunc(sysdate) - :d$i + 1 order by stockdate desc');
  end
  else if FormDoc = myfrm_Dlg_Spl_InfoGrid_MoveNomencl then begin
    //движение по номенклатуре за весь период, все документы движения (приходные, расходные, авр, акты списания, постановка в резерв)
    //при фильтре по конкретному складу в столбце "Со склада" будут корректно отображены документы РАСХОДА с данного склада, приход будет неверный,
    //и наоборот будет верный приход при фильтре "На склад"
    Frg1.Opt.SetFields([
      ['id_stock$i','_id','40'],
      ['id_doc$i','_id_doc','40'],
      ['doctype$i','_doctype','40'],
      ['td$s','Тип документа','120;w'],
      ['numdoc$s','№ документа','80'],
      ['stockdate$d','Дата документа','80'],
      ['skladsrc$s','Со склада','150;h'],
      ['skladdest$s','На склад','150;h'],
      ['basis as ornum$s','Основание','200;h','bt=Паспорт;Смета'],
      ['dt_beg$d','Дата оформления','80'],
      ['dt_otgr$d','Дата отгрузки','80'],
      ['project$s','Проект','200;h'],
      ['prihod$f','Приход','80','f=f:'],
      ['rashod$f','Расход','80','f=f:'],
      ['comments$s','Комментарий','400;h']
    ]);
    Frg1.Opt.SetTable('v_itm_movenomencl');
    Frg1.Opt.SetWhere('where id_nomencl = :id$i and stockdate >= :dt$d order by stockdate');
  end
  else if FormDoc = myfrm_Dlg_Spl_InfoGrid_DiffInOrder then begin
    //НЕ РАБОТАЕТ!!! (пометка автора из старого D_Spl_InfoGrid.pas, логику не чиним, переносим как есть)
    //движение по номенклатуре, отфильтрованное по расхождениям (см. подзапрос ниже) - список "оснований",
    //по которым сумма движений за период не равна нулю
    va := Q.QLoadCol(
      'select basis from ( ' +
      'select sum(prihod + (case when doctype = 3 then 0 else rashod end)) as moves, basis from v_itm_movenomencl ' +
      'where id_nomencl = :id$i and stockdate >= :dt$d and doctype in (-1,2,3,4,-5,-6) and not (doctype = 3 and rashod < 0) ' +
      'group by basis) ' +
      'where nvl(moves, 0) <> 0',
      [ID, EncodeDate(2024, 01, 01)]
    );
    if Length(va) = 0 then
      va := [-1];
    st := '''' + A.Implode(va, ''',''') + '''';
    Frg1.Opt.SetFields([
      ['id_stock$i','_id','40'],
      ['id_doc$i','_id_doc','40'],
      ['doctype$i','_doctype','40'],
      ['td$s','Тип документа','120;w'],
      ['numdoc$s','№ документа','80'],
      ['stockdate$d','Дата документа','80'],
      ['skladsrc$s','Со склада','150;h'],
      ['skladdest$s','На склад','150;h'],
      ['basis as ornum$s','Основание','200;h','bt=Паспорт;Смета'],
      ['dt_beg$d','Дата оформления','80'],
      ['dt_otgr$d','Дата отгрузки','80'],
      ['project$s','Проект','200;h'],
      ['prihod$f','Приход','80','f=f:'],
      ['rashod$f','Расход','80','f=f:'],
      ['comments$s','Комментарий','400;h']
    ]);
    Frg1.Opt.SetTable('v_itm_movenomencl');
    Frg1.Opt.SetWhere(
      'where id_nomencl = :id$i and stockdate >= :dt$d and doctype in (-1,2,3,4,-5,-6) and not (doctype = 3 and rashod < 0) ' +
      'and basis in (' + st + ') order by stockdate'
    );
  end
  else if FormDoc = myfrm_Dlg_Spl_InfoGrid_SpSchetList then begin
    //список счетов по данной номенклатуре
    Frg1.Opt.SetFields([
      ['id_schet$i','_id','40'],
      ['date_registr$d','Дата','80'],
      ['num$s','№ счета','100','bt=Открыть счет'],
      ['name_org$s','Поставщик','250;h'],
      ['name$s','Наименование у поставщика','250;h'],
      ['quantity$f','Кол. поставщика','80','f=f:'],
      ['unit$s','Ед. поставщика','80'],
      ['price$f','Цена','80','f']
    ]);
    Frg1.Opt.SetTable('v_spl_schetbynomencl');
    Frg1.Opt.SetWhere('where id_nomencl = :id$i order by date_registr');
  end
  else if FormDoc = myfrm_Dlg_Spl_InfoGrid_InBillList then begin
    //список приходных накладных по данной номенклатуре
    Frg1.Opt.SetFields([
      ['id_inbill$i','_id','40'],
      ['inbilldate$d','Дата','80'],
      ['inbillnum$s','№ ПН','100','bt=Открыть приходную накладную'],
      ['name_org$s','Поставщик','250;h'],
      ['ibquantity$f','Кол-во','80','f=f:'],
      ['fact_quantity$f','Кол-во по док.','80','f=f:'],
      ['name_unit as unit$s','Ед. изм','80'],
      ['price$f','Цена','80','f'],
      ['price_itogo$f','Цена с НДС','80','f']
    ]);
    Frg1.Opt.SetTable('v_spl_nom_inbills');
    Frg1.Opt.SetWhere('where id_nomencl = :id$i order by inbilldate');
  end
  else if FormDoc = myfrm_Dlg_Spl_InfoGrid_OnDemand then begin
    //по заявке (спрос на номенклатуру, ещё не превратившийся в заказ поставщику)
    Frg1.Opt.SetFields([
      ['id_demand$i','_id','40'],
      ['demand_date$d','Дата','80'],
      ['docstate$s','Статус','80'],
      ['quantity$f','Кол.','80','f=f:']
    ]);
    Frg1.Opt.SetTable('v_spl_nomencl_on_demand');
    Frg1.Opt.SetWhere('where id_nomencl = :id$i and demand_date > sysdate - (select on_demand_days from spl_minremains_params) order by demand_date');
  end
  else if FormDoc = myfrm_Dlg_Spl_InfoGrid_PlanneDOrders then begin
    //список плановых заказов по данной номенклатуре за данный месяц
    //номенклатура передаётся в AddParam[0], месяц в AddParam[1]
    //если месяц отрицательный, то берём из таблицы для СН, иначе из общей на 12 месяцев
    if AddParam[1] > 0 then
      st := S.NSt(Q.QLoadValue('select or' + VarToStr(AddParam[1]) + ' from planned_order_estimate12 where name = :name$s', [AddParam[0]]))
    else if AddParam[1] < 0 then
      st := S.NSt(Q.QLoadValue('select or' + VarToStr(-AddParam[1]) + ' from planned_order_estimate3 where name = :name$s', [AddParam[0]]));
    if st = '' then
      st := '0';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['num$s','№','80','bt=Открыть плановый заказ'],
      ['projectname as project$s','Проект','250;h'],
      ['dt_start$d','Начало','80'],
      ['dt_end$d','Окончание','80']
    ]);
    Frg1.Opt.SetTable('v_planned_orders');
    Frg1.Opt.SetWhere('where id in (' + st + ') order by num');
  end;
  Result := Inherited;
end;

procedure TFrmOGinfSn.Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
//клик по кнопке в ячейке основного грида
var
  IdOrder: Variant;
begin
  if Fr.IsEmpty then
    Exit;
  if TCellButtonEh(Sender).Hint = 'Паспорт' then begin
    //откроем паспорт заказа по номеру (поле ornum содержит номер заказа)
    IdOrder := Q.QLoadValue('select id from v_orders where ornum = :ornum$s', [Fr.GetValue('ornum')]);
    if IdOrder <> null then
      Wh.ExecDialog(myfrm_Dlg_Order, Self, [], fView, IdOrder, null);
  end;
  if TCellButtonEh(Sender).Hint = 'Смета' then begin
    //откроем смету заказа по номеру (поле ornum содержит номер заказа)
    IdOrder := Q.QLoadValue('select id from v_orders where ornum = :ornum$s', [Fr.GetValue('ornum')]);
    if IdOrder <> null then
      Wh.ExecReference(myfrm_R_AggEstimate, Self, [myfoDialog, myfoMultiCopyWoId, myfoSizeable, myfoEnableMaximize], VarArrayOf([IdOrder]));
  end;
  if TCellButtonEh(Sender).Hint = 'Открыть счет' then
    Wh.ExecReference(myfrm_R_Itm_Schet, Self, [myfoDialog, myfoSizeable, myfoEnableMaximize], Fr.GetValue('id_schet'));
  if TCellButtonEh(Sender).Hint = 'Открыть приходную накладную' then
    Wh.ExecReference(myfrm_R_Itm_InBill, Self, [myfoDialog, myfoSizeable, myfoEnableMaximize], Fr.GetValue('id_inbill'));
  if TCellButtonEh(Sender).Hint = 'Открыть плановый заказ' then
    TFrmOWPlannedOrder.Show(Self, myfrm_Dlg_PlannedOrder, [myfoSizeable, myfoMultiCopy], fView, Fr.GetValue('id'), null);
end;

procedure TFrmOGinfSn.Frg2CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
//клик по кнопке в ячейке детального грида (раскрывающаяся панель строки, только ветка OnWay)
begin
  if Fr.IsEmpty then
    Exit;
  if TCellButtonEh(Sender).Hint = 'Открыть приходную накладную' then
    Wh.ExecReference(myfrm_R_Itm_InBill, Self, [myfoDialog, myfoSizeable, myfoEnableMaximize], Fr.GetValue('id_inbill'));
end;

procedure TFrmOGinfSn.Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
var
  va: TVarDynArray;
begin
  inherited;
  if (FormDoc = myfrm_Dlg_Spl_InfoGrid_OnWay) and (Fr.CurrField = 'num') then begin
    va := Q.QLoadRow0(
      'select filename from sn_calendar_accounts where account = :account$s and accountdt = :dt$d',
      [Fr.GetValue('num'), Fr.GetValue('date_registr')]
    );
    if (Length(va) > 0) and (va[0] <> null) then
      Sys.OpenFileOrDirectory(Module.GetPath_Accounts_A(VarToStr(va[0])), 'Файл счета не найден!');
  end;
  if FormDoc = myfrm_Dlg_Spl_InfoGrid_Rezerv then begin
    if Fr.CurrField = 'ornum' then begin
      //покажем паспорт заказа
      va := Q.QLoadRow0('select id from v_orders where ornum = :ornum$s', [Fr.GetValue('ornum')]);
      if (Length(va) > 0) and (va[0] <> null) then
        Wh.ExecDialog(myfrm_Dlg_Order, Self, [], fView, va[0], null);
    end;
    if Fr.CurrField = 'rashod' then begin
      //покажем смету заказа
      va := Q.QLoadRow0('select id from v_orders where ornum = :ornum$s', [Fr.GetValue('ornum')]);
      if (Length(va) > 0) and (va[0] <> null) then
        Wh.ExecReference(myfrm_R_AggEstimate, Self, [myfoDialog, myfoMultiCopyWoId, myfoSizeable, myfoEnableMaximize], VarArrayOf([va[0]]));
    end;
  end;
end;

procedure TFrmOGinfSn.Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  if (FormDoc = myfrm_Dlg_Spl_InfoGrid_Consumption) or (FormDoc = myfrm_Dlg_Spl_InfoGrid_Incoming) then
    Fr.SetSqlParameters('id$i;d$i', [ID, AddParam[2]])
  else if (FormDoc = myfrm_Dlg_Spl_InfoGrid_MoveNomencl) or (FormDoc = myfrm_Dlg_Spl_InfoGrid_DiffInOrder) then
    Fr.SetSqlParameters('id$i;dt$d', [ID, EncodeDate(2024, 01, 01)])
  else
    Fr.SetSqlParameters('id$i', [ID]);
end;

procedure TFrmOGinfSn.Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  if FormDoc = myfrm_Dlg_Spl_InfoGrid_OnWay then
    Fr.SetSqlParameters('idn2$i;idd2$i', [ID, Frg1.GetValue('id_schet')]);
end;

end.
