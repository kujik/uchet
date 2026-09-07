unit uFrmOGrepSgp;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2
  ;

type
  TFrmOGrepSgp = class(TFrmBasicGrid2)
  private
    FFormats: TVarDynArray2;          //список форматов паспортов для отображение данных СГП
    FIdFormat: Variant;
    function  PrepareForm: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);  override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    procedure Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
  public
  end;

var
  FrmOGrepSgp: TFrmOGrepSgp;

implementation

uses
  uWindows
  ;

{$R *.dfm}

function TFrmOGrepSgp.PrepareForm: Boolean;
begin
  //07.09.2026: экран переведён в режим архива (только просмотр) - показывает остаток СГП
  //по стандартным изделиям, замороженный на момент перехода на новую логику учёта (см.
  //!алгоритмы.txt, раздел про СГП). Источник данных - таблица-снимок (sgp_snapshot_std_items
  //через v_sgp_snapshot_std_items), а не живая v_sgp_items; выбор в комбобоксе - ГРУППА
  //(or_formats) целиком, а не отдельный отгрузочный подформат, как раньше (это же исправляет
  //дублирование остатка одного изделия по нескольким отгрузочным подформатам одной группы).
  //Правка/ревизия из этого экрана больше не производится - см. удалённые Frg1CellValueSave
  //(правка "мин. остатка") и Frg1OnDbClick (детализация движения) - для статичного архива
  //они не имеют смысла (лежащие в их основе живые вью считают по подформату, а не по группе).
  Caption:= 'Состояние СГП (стандартные изделия) - архив на момент перехода на новую логику учёта';
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
    ['sumraw','Сумма по смете','80','f=r:','i',not User.Role(rOr_Rep_Sgp_ViewPrice)],
    ['dt_snapshot','Дата снимка','90']
  ]);
  Frg1.Opt.SetTable('v_sgp_snapshot_std_items');
  Frg1.Opt.SetButtons(1,[[mbtRefresh],[],[-mbtCustom_JRevisions,1,'Журнал ревизий'],[],[mbtGridSettings],[],[mbtCtlPanel]]);
  Frg1.Opt.SetButtonsIfEmpty([mbtCustom_JRevisions]);
  Frg1.CreateAddControls('1', cntComboLK, 'Группа:', 'CbFormat', '', 50, yrefC, 400);
  FFormats:=Q.QLoad(
    'select name, id from (select ''[все]'' as name, -1000 as id, 0 as srt from dual union all ' +
    'select f.name, f.id, 1 as srt from or_formats f where f.id in (select distinct id_or_formats from sgp_snapshot_std_items) order by srt, name)', []
  );
  Cth.AddToComboBoxEh(TDBComboBoxEh(Frg1.FindComponent('CbFormat')), FFormats);
  TDBComboBoxEh(Frg1.FindComponent('CbFormat')).ItemIndex := 0;
  FIdFormat:= Frg1.GetControlValue('CbFormat');
  Frg1.InfoArray:=[
    [Caption + '.'#13#10#13#10],[
      'Эта таблица - архив (только для чтения) состояния склада готовой продукции по '#13#10+
      'стандартным изделиям СТАРЫХ заказов на момент перехода на новую логику учёта СГП.'#13#10+
      'Дальше эти цифры не пересчитываются и не редактируются.'#13#10+
      ''#13#10+
      'Учёт по новым заказам ведётся отдельным отчётом. По старым заказам, пока они не будут '#13#10+
      'полностью приняты и отгружены, движение продолжает фиксироваться отдельными актами - '#13#10+
      'см. кнопку "Журнал ревизий". Подробности - в файле "!Алгоритмы" проекта, раздел про СГП.'#13#10+
      ''#13#10+
      'Для отображения нужной вам группы выберите её в выпадающем списке сверху.'#13#10+
      'Не набираете в этом поле текст и не прокручивайте колесиком мыши, в этих случаях программа может надолго зависнуть!'#13#10+
      'Найдите необходимую позицию, двигая мышкой ползунок справа, и кликните на нее.'#13#10+
      ''#13#10+
      'На момент снимка сопоставление изделий между производственными и отгрузочными паспортами '#13#10+
      'производилось по их наименованию, в разрезе группы целиком (а не отдельного отгрузочного '#13#10+
      'подформата, как было раньше) - поэтому остаток по одноимённому изделию показан одной строкой, '#13#10+
      'даже если у группы несколько отгрузочных подформатов.'#13#10
    ]];
  Frg1.Opt.ColumnsInfo:=[
    ['name', 'Наименование изделия, как оно было задано в списке стандартных изделий на момент снимка, без префикса типа изделия.'],
    ['qnt_psp_sell', 'Информация, сколько всего изделия было заказано по отгрузочным паспортам на момент снимка'],
    ['qnt_psp_prod', 'Информация, сколько всего изделия было запущено по производственным паспортам на момент снимка'],
    ['qnt_sgp_registered', 'Столько изделий было принято на СГП по производственым паспортам на момент снимка'],
    ['qnt_shipped', 'Столько изделий было отгружено по отгрузочным паспортам на момент снимка'],
    ['qnt', 'Расчётное количество изделия на складе на момент снимка (см. дату снимка).'],
    ['qnt_in_prod', 'Количество изделий, находившихся в производстве на момент снимка (в позициях из незакрытых производственных паспортов, ещё не оприходованных на СГП)'],
    ['qnt_to_shipped', 'Отгрузка план. Количество изделия из отгрузочных паспортов, ещё не отгруженное с СГП на момент снимка'],
    ['qnt_need', 'Сумма текущего количества на складе на момент снимка, с прибавкой количества "В производстве" и за вычетом количества "К отгрузке".'],
    ['price', 'Цена изделия из справочника стандартных изделий на момент снимка (по отгрузке).'],
    ['summ', 'Стоимость остатка изделия на СГП на момент снимка.'],
    ['priceraw', 'Цена по смете соответствующего изделия из группы производственных изделий (ИТМ) на момент снимка.'],
    ['sumraw', 'Стоимость по смете остатка изделия на СГП на момент снимка.'],
    ['dt_snapshot', 'Дата и время, когда был сделан этот снимок (переход на новую логику учёта СГП).']
  ];
  Result := inherited;
end;

procedure TFrmOGrepSgp.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  //07.09.2026: кнопка "Ревизия" (mbtCustom_Revision) убрана - экран переведён в архив,
  //новых актов по этим (замороженным) данным больше не создаётся
  if Tag = mbtCustom_JRevisions then begin
    //журнал актов списания/оприходования по данной группе (см. v_sgp_revisions - теперь
    //переопределено на группу, а не на отгрузочный подформат, см. !алгоритмы.txt)
    Wh.ExecReference(myfrm_J_Sgp_Acts, Self, [], FIdFormat);
  end
  else inherited;
end;

procedure TFrmOGrepSgp.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
  if Fr.IsPrepared then
    Fr.RefreshGrid;
end;

procedure TFrmOGrepSgp.Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  FIdFormat := Fr.GetControlValue('CbFormat');
  //07.09.2026: фильтр теперь по группе (id_or_formats), а не по отгрузочному подформату
  //(id_format_est) - см. v_sgp_snapshot_std_items/!алгоритмы.txt
  SqlWhere := S.IIfStr(FIdFormat >= 0, 'id_or_formats = :id_or_formats$i');
  Fr.SetSqlParameters('id_or_formats$i', [FIdFormat]);
end;

procedure TFrmOGrepSgp.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if FieldName = 'qnt_need' then begin
    if (Fr.GetValueF('qnt_need') < 0) then
      Params.Background :=clmyPink;  //розовый
  end;
end;


end.
