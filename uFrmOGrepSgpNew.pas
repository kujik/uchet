unit uFrmOGrepSgpNew;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2
  ;

type
  TFrmOGrepSgpNew = class(TFrmBasicGrid2)
  private
    FFormats: TVarDynArray2;          //список групп (or_formats) для отображения данных СГП нового формата
    FIdFormat: Variant;
    function  PrepareForm: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);  override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    procedure Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
  public
  end;

var
  FrmOGrepSgpNew: TFrmOGrepSgpNew;

implementation

uses
  uWindows, uFrmOGinfSgp
  ;

{$R *.dfm}

function TFrmOGrepSgpNew.PrepareForm: Boolean;
begin
  //(07.09.2026) живой отчёт "Текущее состояние СГП" по стандартным изделиям для заказов
  //НОВОГО формата (id_order >= properties.id_order_format_26) - в отличие от архивного
  //uFrmOGrepSgp.pas (замороженный снимок на момент перехода, только старые заказы), этот
  //отчёт живой и считает по v_sgp_new_format_items (см. d_sgp.sql и !алгоритмы.txt, раздел
  //про СГП). Сопоставление производственных и отгрузочных изделий - по внутренней id-связи
  //or_std_items.id_prod_std_item, а НЕ по совпадению наименования. Доступ к архивному отчёту
  //по старым заказам - кнопка "Архив по старым заказам" ниже (Tag = 1000).
  Caption:= 'Текущее состояние СГП (стандартные изделия)';
  Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['format_name','Группа','250;h'],
    ['name','Изделие','300;h'],
    ['qnt_psp_sell','Заказано всего','80'],
    ['qnt_psp_prod','Запущено в производство','80'],
    ['qnt_sgp_registered','Принято на СГП всего','80'],
    ['qnt_shipped','Отгружено всего','80'],
    ['qnt','Текущий остаток','80'],
    ['qnt_in_prod','В производстве','80'],
    ['qnt_to_shipped','Отгрузка план','80'],
    ['qnt_need','Избыток / Потребность','80'],
    ['price','Цена продажи','80','f=r','i',not User.Role(rOr_Rep_Sgp_ViewPrice)],
    ['summ','Сумма продажи','80','f=r:','i',not User.Role(rOr_Rep_Sgp_ViewPrice)],
    ['priceraw','Цена по смете','80','f=r','i',not User.Role(rOr_Rep_Sgp_ViewPrice)],
    ['sumraw','Сумма по смете','80','f=r:','i',not User.Role(rOr_Rep_Sgp_ViewPrice)]
  ]);
  Frg1.Opt.SetTable('v_sgp_new_format_items');
  Frg1.Opt.SetButtons(1,[[mbtRefresh],[],[-mbtCustom_JRevisions,1,'Журнал ревизий'],[],[-1000,1,'Архив по старым заказам'],[],[mbtGridSettings],[],[mbtCtlPanel]]);
  Frg1.Opt.SetButtonsIfEmpty([mbtCustom_JRevisions]);
  Frg1.CreateAddControls('1', cntComboLK, 'Группа:', 'CbFormat', '', 50, yrefC, 400);
  FFormats:=Q.QLoad(
    'select name, id from (select ''[все]'' as name, -1000 as id, 0 as srt from dual union all ' +
    'select f.name, f.id, 1 as srt from or_formats f where f.id in (select distinct id_format from v_sgp_new_format_items) order by srt, name)', []
  );
  Cth.AddToComboBoxEh(TDBComboBoxEh(Frg1.FindComponent('CbFormat')), FFormats);
  TDBComboBoxEh(Frg1.FindComponent('CbFormat')).ItemIndex := 0;
  FIdFormat:= Frg1.GetControlValue('CbFormat');
  Frg1.InfoArray:=[
    [Caption + '.'#13#10#13#10],[
      'Живой отчёт (не архив) по остаткам СГП для заказов НОВОГО формата.'#13#10+
      'Сопоставление производственных и отгрузочных изделий идёт по внутренней '#13#10+
      'id-связи в справочнике стандартных изделий, а не по совпадению наименования - '#13#10+
      'поэтому переименование изделия не влияет на расчёт остатка.'#13#10+
      ''#13#10+
      'Остаток по СТАРЫМ заказам (до перехода на новый формат) - в отдельном архивном '#13#10+
      'отчёте, см. кнопку "Архив по старым заказам".'#13#10+
      ''#13#10+
      'Для отображения нужной вам группы выберите её в выпадающем списке сверху.'#13#10+
      'Не набираете в этом поле текст и не прокручивайте колесиком мыши, в этих случаях программа может надолго зависнуть!'#13#10+
      'Найдите необходимую позицию, двигая мышкой ползунок справа, и кликните на нее.'#13#10
    ]];
  Frg1.Opt.ColumnsInfo:=[
    ['name', 'Наименование производственного стандартного изделия (эталона), как оно задано в справочнике.'],
    ['qnt_psp_sell', 'Сколько всего изделия заказано по отгрузочным заказам нового формата.'],
    ['qnt_psp_prod', 'Сколько всего изделия запущено по производственным заказам нового формата.'],
    ['qnt_sgp_registered', 'Сколько изделий принято на СГП (этап 2) по производственным заказам нового формата.'],
    ['qnt_shipped', 'Сколько изделий отгружено с СГП (этап 3) по отгрузочным заказам нового формата.'],
    ['qnt', 'Текущий расчётный остаток изделия на складе (приёмка минус отгрузка, с учётом ручных актов из журнала ревизий).'],
    ['qnt_in_prod', 'Количество изделий в открытых производственных заказах, ещё не принятое на СГП.'],
    ['qnt_to_shipped', 'Количество изделий в открытых отгрузочных заказах, ещё не отгруженное с СГП.'],
    ['qnt_need', 'Текущий остаток с прибавкой количества "В производстве" и за вычетом количества "Отгрузка план".'],
    ['price', 'Средняя цена изделия без НДС из справочника стандартных изделий (по отгрузке).'],
    ['summ', 'Стоимость текущего остатка изделия на СГП.'],
    ['priceraw', 'Цена по смете производственного изделия.'],
    ['sumraw', 'Стоимость по смете текущего остатка изделия на СГП.']
  ];
  Result := inherited;
end;

procedure TFrmOGrepSgpNew.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if Tag = mbtCustom_JRevisions then begin
    //журнал актов списания/оприходования по данной группе (см. v_sgp_revisions) - включает
    //в т.ч. ручные акты по заказам нового формата, которые уже учтены в текущем остатке выше
    Wh.ExecReference(myfrm_J_Sgp_Acts, Self, [], FIdFormat);
  end
  else if Tag = 1000 then begin
    //переход к архивному отчёту по СТАРЫМ заказам (замороженный снимок на момент перехода
    //на новую логику учёта) - см. uFrmOGrepSgp.pas
    Wh.ExecReference(myfrm_Rep_Sgp, Self, [], Null);
  end
  else inherited;
end;

procedure TFrmOGrepSgpNew.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
  if Fr.IsPrepared then
    Fr.RefreshGrid;
end;

procedure TFrmOGrepSgpNew.Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
  //(07.09.2026, часть 6) детализация по двойному клику - переиспользуем диалог uFrmOGinfSgp.pas
  //(раньше обслуживал старый живой отчёт uFrmOGrepSgp.pas, но детализация там была убрана при
  //переводе того отчёта в архив - см. !алгоритмы.txt). Те же 7 разрезов, что и раньше, но
  //переписанные на семью через id_prod_std_item и данные нового формата (см. d_sgp.sql,
  //v_sgp_new_psp_prod_list/v_sgp_new_psp_sell_list/v_sgp_new_registered_list/
  //v_sgp_new_shipped_list/v_sgp_new_in_prod_list/v_sgp_new_to_shipped_list/v_sgp_new_move_list).
  //Fr.ID здесь = g.id_prod_std_item (строка отчёта), как и раньше в старом отчёте.
  if Fr.CurrField = 'qnt_psp_sell' then
    TFrmOGinfSgp.Show(Self, myfrm_Dlg_Sgp_InfoGrid_PspSell, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, Null)
  else if Fr.CurrField = 'qnt_psp_prod' then
    TFrmOGinfSgp.Show(Self, myfrm_Dlg_Sgp_InfoGrid_PspProd, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, Null)
  else if Fr.CurrField = 'qnt_sgp_registered' then
    TFrmOGinfSgp.Show(Self, myfrm_Dlg_Sgp_InfoGrid_Registered, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, Null)
  else if Fr.CurrField = 'qnt_shipped' then
    TFrmOGinfSgp.Show(Self, myfrm_Dlg_Sgp_InfoGrid_Shipped, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, Null)
  else if Fr.CurrField = 'qnt_to_shipped' then
    TFrmOGinfSgp.Show(Self, myfrm_Dlg_Sgp_InfoGrid_Shipped_Plan, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, Null)
  else if Fr.CurrField = 'qnt_in_prod' then
    TFrmOGinfSgp.Show(Self, myfrm_Dlg_Sgp_InfoGrid_In_Prod, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, Null)
  else if Fr.CurrField = 'qnt' then
    TFrmOGinfSgp.Show(Self, myfrm_Dlg_Sgp_InfoGrid_Move, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, Null);
end;

procedure TFrmOGrepSgpNew.Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  FIdFormat := Fr.GetControlValue('CbFormat');
  //(07.09.2026, известная проблема) при самом первом запуске формы у пользователя значение
  //комбобокса ещё не сохранено в конфиге и приходит пустой строкой (не Null) - сравнение
  //'' >= 0 в Delphi бросает исключение (Invalid variant operation). Пустое значение
  //трактуем так же, как явный выбор "[все]" (id = -1000 в FFormats выше) - т.е. без фильтра
  if S.NSt(FIdFormat) = '' then
    FIdFormat := -1000;
  SqlWhere := S.IIfStr(FIdFormat >= 0, 'id_format = :id_format$i');
  Fr.SetSqlParameters('id_format$i', [FIdFormat]);
end;

procedure TFrmOGrepSgpNew.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if FieldName = 'qnt_need' then begin
    if (Fr.GetValueF('qnt_need') < 0) then
      Params.Background :=clmyPink;  //розовый
  end;
end;


end.
