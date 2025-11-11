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
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
  public
  end;

var
  FrmOGrepSgp: TFrmOGrepSgp;

implementation

uses
  uWindows,
  uFrmOGinfSgp
  ;

{$R *.dfm}

function TFrmOGrepSgp.PrepareForm: Boolean;
begin
  Caption:= 'Состояние СГП (стандартные изделия)';
  Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['slash','Слеш','110'],
    ['name','Изделие','300;h'],
    ['qnt_psp_sell','Заказано всего','80'],
    ['qnt_psp_prod','Запущено в производство','80'],
    ['qnt_sgp_registered','Принято на СГП всего','80'],
    ['qnt_shipped','Отгружено всего','80'],
    ['qnt','Текущий остаток','80'],
    ['qnt_in_prod','В производстве','80'],
    ['qnt_to_shipped','Отгрузка план','80'],
    ['qnt_min','Минимальный остаток','80','e=0:9999999:0',User.Role(rOr_Rep_Sgp_Ch1)], //пустое допустимо
    ['qnt_need','Избыток / Потребность','80'],
    ['price','Цена продажи','80','f=r','i',not User.Role(rOr_Rep_Sgp_ViewPrice)],
    ['summ','Сумма продажи','80','f=r:','i',not User.Role(rOr_Rep_Sgp_ViewPrice)],
    ['priceraw','Цена по смете','80','f=r','i',not User.Role(rOr_Rep_Sgp_ViewPrice)],
    ['sumraw','Сумма по смете','80','f=r:','i',not User.Role(rOr_Rep_Sgp_ViewPrice)]
  ]);
  Frg1.Opt.SetTable('v_sgp_items');
  Frg1.Opt.SetWhere('where id_format_est = :id_format_est$i');
  Frg1.Opt.SetButtons(1,[[mbtRefresh],[],[-mbtCustom_Revision,User.Role(rOr_Rep_Sgp_Rev),'Ревизия'],[-mbtCustom_JRevisions,1,'Журнал ревизий'],[],[mbtGridSettings],[],[mbtCtlPanel]]);
  Frg1.Opt.SetButtonsIfEmpty([mbtCustom_JRevisions]);
  Frg1.CreateAddControls('1', cntComboLK, 'Формат:', 'CbFormat', '', 50, yrefC, 400);
  FFormats:=Q.QLoadToVarDynArray2('select name, id from v_sgp_sell_formats order by name', []);
  Cth.AddToComboBoxEh(TDBComboBoxEh(Frg1.FindComponent('CbFormat')), FFormats);
  TDBComboBoxEh(Frg1.FindComponent('CbFormat')).ItemIndex := 0;
  FIdFormat:= Frg1.GetControlValue('CbFormat');
  Frg1.InfoArray:=[
    [Caption + '.'#13#10#13#10],[
      'В таблице отображается и по ней контролируется состояние склада готовой продукции в разрезе '#13#10+
      'выбранного формата паспортов (стандартных изделий, что то же).'#13#10+
      'Какие форматы и изделия будут отображаться в данной таблице, определяет менеджер.'#13#10+
      ''#13#10+
      'Для отображения нужного вам формата выберите его в выпадающем списке сверху.'#13#10+
      'Не набираете в этом поле текст и не прокручивайте колесиком мыши, в этих случаях программа может надолго зависнуть!'#13#10+
      'Найдите необходимую позицию, двигая мышкой ползунок справа, и кликните на нее.'#13#10+
      ''#13#10+
      'Данные заполняются на основании принятых заказов (по журналу заказов), журналу приемки на СГП, журналу отгрузки с СГП,'#13#10+
      'а также внутренним ревизиям склада.'#13#10+
      ''#13#10+
      'Приход на склад вычисляется как суммарный приход изделия на склад СГП по соответствующему журналу, только по производственным паспортам.'#13#10+
      'Расход, аналогично приходу, по отгрузочным папортам в разрезе выбранных изделий, по моменту отгрузки с СГП.'#13#10+
      'Сопоставление изделий между производственными и отгрузочными паспортами производится по их наименованию!'#13#10+
      '(префикс не учитывается)'#13#10+
      ''#13#10+
      'Дополнительные данные в таблице представлены колонками '#13#10+
      '"Заказано всего", "Запущено в производство", "В производстве", "Отгрузка план.", "Мин. остаток"'#13#10+
      'Вычисляемая графа "Потребность" показывает разницу текущего остатка плюс значения "В производстве" за минусом'#13#10+
      'планируемой отгрузки. Она будет положительной, если на складе останется запас для отгрузки при этих условиях, если же его не хватает, '#13#10+
      'значение будет отрицательным и отметится розовым цветом.'#13#10+
      ''#13#10+
      'Значение в графе "Минимальный остаток" вводится в этой же таблице вручную и является справочным.'#13#10+
      ''#13#10+
      'Чтобы провести ревизию склада, воспользуйтесь соответствующим пунктом выпадающего меню в таблице.'#13#10+
      'Также через меню можно просмотреть и журнал ревизий.'#13#10+
      ''#13#10+
      'Двойной клик мышкой по ячейке, как правило, открывает окно детализации во времени для изделия из текущей строки, по параметру, который показывавет столбец.'#13#10
    ]];
  Frg1.Opt.ColumnsInfo:=[
    ['slash', 'Слеш изделия, выбирается из самого нового шаблона паспорта, если таковой найден для данного формата. '+
     'Если найти не удается, или данного изделия нет в этом шаблоне, то поле останется пустым.'],
    ['name', 'Наименование изделия, как оно задано в списке станадртных изделий, без префикса типа изделия. Все сопоставления отгрузочных и производственных паспортов производятся по наименованию.'],
    ['qnt_psp_sell', 'Информация, сколько всего изделия было заказано по отгрузочным паспортам (т.е. их количества в теле паспорта) за весь отчетный период'],
    ['qnt_psp_prod', 'Информация, сколько всего изделия было запущено по производственным паспортам за весь отчетный период'],
    ['qnt_sgp_registered', 'Столько изделий принято на СГП по производственым паспортам'],
    ['qnt_shipped', 'Столько изделий отгружено по производственным паспортам'],
    ['qnt', 'Текущее расчетное количество изделия на складе.'#13#10'Является разницей принятых на СГП по производственным и отгруженных с СГП по отгрузочным паспортам'#13#10+
    'также здесь учитываются созданные на основании ревизий акты приемки и списания на/с СГП.'#13#10'По даблклику вы можете посмотреть движение по складу СГП в разрезе данного изделия.'+
    ''],
    ['qnt_in_prod', 'Количество изделий, находящихся сейчас в производстве (это количество в позиции из незакрытых производственных паспортов по изделиям, которое еще не было оприходовано на СГП.)'],
    ['qnt_to_shipped', 'Отгрузка план. Количество изделия из отгрузочных паспортов, которые еще не были отгружены с СГП'],
    ['qnt_min', 'Минимальное количество, которое требуется поддерживать на складе. Вводится непосредственнно в ячейку таблицы. Несет справочную функцию, на другие данные не влияет.'],
    ['qnt_need', 'Суммма текущего количества на складе, с прибавкой количества "В производстве", и за вычетом количества "К отгрузке".'+
    'Характеризует запас изделий, отрицательное значение (подсвечивается) означает, что количество на складе и текущее запущенное в производство не покроют уже запланированных отгрузок.'],
    ['price', 'Цена изделий из справочника стандартных изделий (по отгрузке).'],
    ['summ', 'Стоимость текущего остатка изделия на СГП. Цена берется из справочника стандартных изделий (по отгрузке).'],
    ['priceraw', 'Цена по смете соотвествующего изделия из группы производственных изделий, взятая из ИТМ.'],
    ['sumraw', 'Стоимость по смете текущего остатка изделия на СГП.']
  ];
  Result := inherited;
end;

procedure TFrmOGrepSgp.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if Tag = mbtCustom_Revision then begin
    //ревизия сгп по формату
    Wh.ExecDialog(myfrm_Dlg_Sgp_Revision, Self, [], fEdit, FIdFormat, null);
  end
  else if Tag = mbtCustom_JRevisions then begin
    //журнал актов списания/оприходования по данному формату
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
  FIdFormat:= Fr.GetControlValue('CbFormat');
  Fr.SetSqlParameters('id_format_est$i', [FIdFormat]);
end;

procedure TFrmOGrepSgp.Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
begin
  Q.QCallStoredProc('p_SetSgpItemAdd', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([Fr.ID, 1, S.NullIfEmpty(Value)]));
end;

procedure TFrmOGrepSgp.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if FieldName = 'qnt_need' then begin
    if (Fr.GetValueF('qnt_need') < 0) then
      Params.Background :=clmyPink;  //розовый
  end;
end;

procedure TFrmOGrepSgp.Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
  if Fr.CurrField = 'qnt_psp_sell' then
    TFrmOGinfSgp.Show(Self, myfrm_Dlg_Sgp_InfoGrid_PspSell, [myfoMultiCopy, myfoSizeable, myfoDialog], fView, Fr.ID, null)
  else if Fr.CurrField = 'qnt_psp_prod' then
    TFrmOGinfSgp.Show(Self, myfrm_Dlg_Sgp_InfoGrid_PspProd, [myfoMultiCopy, myfoSizeable, myfoDialog], fView, Fr.ID, null)
  else if Fr.CurrField = 'qnt_shipped' then
    TFrmOGinfSgp.Show(Self, myfrm_Dlg_Sgp_InfoGrid_Shipped, [myfoMultiCopy, myfoSizeable, myfoDialog], fView, Fr.ID, null)
  else if Fr.CurrField = 'qnt_sgp_registered' then
    TFrmOGinfSgp.Show(Self, myfrm_Dlg_Sgp_InfoGrid_Registered, [myfoMultiCopy, myfoSizeable, myfoDialog], fView, Fr.ID, null)
  else if Fr.CurrField = 'qnt_to_shipped' then
    TFrmOGinfSgp.Show(Self, myfrm_Dlg_Sgp_InfoGrid_Shipped_Plan, [myfoMultiCopy, myfoSizeable, myfoDialog], fView, Fr.ID, null)
  else if Fr.CurrField = 'qnt_in_prod' then
    TFrmOGinfSgp.Show(Self, myfrm_Dlg_Sgp_InfoGrid_In_Prod, [myfoMultiCopy, myfoSizeable, myfoDialog], fView, Fr.ID, null)
  else if Fr.CurrField = 'qnt' then
    TFrmOGinfSgp.Show(Self, myfrm_Dlg_Sgp_InfoGrid_Move, [myfoMultiCopy, myfoSizeable, myfoDialog], fView, Fr.ID, null);
end;


end.
