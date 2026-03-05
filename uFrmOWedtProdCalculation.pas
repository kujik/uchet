unit uFrmOWedtProdCalculation;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ToolCtrlsEh, DBGridEhToolCtrls,
  GridsEh, DBAxisGridsEh, DBGridEh, PropFilerEh, PropStorageEh, Math,
  Types, DBCtrlsEh, ExtCtrls, Vcl.ComCtrls, Vcl.Mask,
  uFrmBasicMdi, uFrmBasicDbDialog, uFrDBGridEh, uFrMyPanelCaption, uString
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
    ts5: TTabSheet;
    ts6: TTabSheet;
    Frg2: TFrDBGridEh;
    Frg3: TFrDBGridEh;
    ts4: TTabSheet;
    Frg4: TFrDBGridEh;
    Frg5: TFrDBGridEh;
    Frg6: TFrDBGridEh;
  private
    function  Prepare: Boolean; override;
    function  SetGrids: Boolean;
  public
  end;

var
  FrmOWedtProdCalculation: TFrmOWedtProdCalculation;

implementation

{$R *.dfm}

uses
  uWindows,
  uForms,
  uDBOra,
  uMessages,
  uData
;

function TFrmOWedtProdCalculation.Prepare: Boolean;
var
  i, j: Integer;
  c: TControl;
  va2: TVarDynArray2;
begin
(*  Result := False;
  FWHBounds.Y := 500;
  FWHBounds.X := 550;
  Caption := 'Регламент заказа';
  //поля
  F.DefineFields := [
    ['id$i'],
    ['active$i'],
    ['name$s','V=1:4000::T'],
    ['deadline$i','V=1:365:0:N'],
    ['ids_types$s'],
    ['ids_properties$s'],
    ['types$s'],
    ['properties$s']
  ];
  //добавим поля для снабжения, т.к. они хранятся в основной таблице (с цифрой), а наименования прописаны в массиве uOrders.cOrderReglamentSnTypes, количество везде берется по размеру массива
  for i := 1 to Length(cOrderReglamentSnTypes) do
    F.DefineFields := F.DefineFields + [['sn_' + InttoStr(i) + '$i']];
  //таблицы
  View := 'order_reglaments';
  Table := 'order_reglaments';
  //выровняем верхнюю панель
  Cth.AlignControls(pnlTop, []);
  //родительский метод
  Result := inherited;
  if not Result then
    Exit;
  //кол-во дней вводится не в редакторе, а в диалоге по эдитбаттон
  nedt_deadline.ReadOnly := True;

  //блок Типов заказа
  //заголовчный фрейм
  frmpcTypes.SetParameters(True, 'Типы заказов',
    [['Выберите типы заказов, для которых применим данный регламент. Хотя бы один тип заказа должен быть выбран.'#13#10'Внимание: при изменении отметки в этом списке список "Свойства заказов" будет очищен!']],
    False
  );
  //грид
//  Frg1.Options := [myogIndicatorColumn, myogColoredTitle, myogHiglightEditableCells, myogHiglightEditableColumns, myogHasStatusBar];
  FrgTypes.Opt.SetFields([
    ['id$i','_id','100'],
    ['pos$i','№','80'],
    ['name$s','Тип заказа','300;w;h'],
    ['used$i','X','40','chb','e']
  ]);
  FrgTypes.Opt.SetGridOperations('u');
  //FrgTypes.Opt.SetCaption
  FrgTypes.OnColumnsUpdateData := FrgTypesColumnsUpdateData;
  //загрузим список заказов
  FrgTypes.SetInitData('select id, pos, name, 0 as used from v_order_types where active = 1 order by pos',[]);
  FrgTypes.Prepare;
  FrgTypes.RefreshGrid;

  //блок Свойства заказов
  //заголовок
  frmpcProperties.SetParameters(True, 'Свойства заказов',
    [['Выберите свойства заказов, для которых применим данный регламент.']],
    False
  );
  //грид
  FrgProperties.Opt.SetFields([
    ['id$i','_id','100'],
    ['pos$i','№','80'],
    ['name$s','Свойство заказа','300;w;h'],
    ['used$i','X','40','chb','e']
  ]);
  FrgProperties.Opt.SetGridOperations('u');
  FrgProperties.OnColumnsUpdateData := FrgPropertiesColumnsUpdateData;
  FrgProperties.SetInitData([]);
  FrgProperties.Prepare;
  FrgProperties.RefreshGrid;
  //установим строки грида исходя из доступных для данных типов, и загрузим из бд галки по ним
  SetGridValues;

  //блок таймлайна
  //заголовок
  frmpcDays.SetParameters(True, 'Регламент прохождения заказа по участкам и закупки материалов снабжением.',
    [[
      'Заполните временные параметры заказа.'#13#10#13#10+
      'В таблице отображаются участки, по которым перемещается заказ, в порядке их прохождения.'#13#10+
      'Также в нижних строках отображены сроки закупки по типам материалов для снабжения.'#13#10+
      'Для задания дня начала работы по заказу для выбранного участка, нажмите левую клавишу мыши, удерживая левый Ctrl на требуемой ячейке.'#13#10+
      'Для задания дня окончания работы по заказу для выбранного участка, нажмите левую клавишу мыши, удерживая правый Ctrl на требуемой ячейке.'#13#10+
      'Если отмечена только одна ячейка, то при таком нажатии она будет очищена.'#13#10+
      'Ячейки для снабжения всегда выделяются с первого дня!'#13#10+
      'Если для данного типа регламента какой-либо участок или материал снабжения не используется, оставьте эту строку пустой.'#13#10+
      'Для каждой строки можно задать цвет ячеек, для этого нажмите левую клавишу мыши, удерживая Ctrl, на ячейке с наименованием участка.'#13#10+
      ''#13#10+
      'Важно: согласованность введенных данных по времени прохождения участков никак не проверяется, будьте внимательны!'#13#10
    ]],
    False
  );
  //настроим грид, загрузим участки и добавим строки с ними
  SetDaysGrid;
  //загрузим введенные по гриду данные
  LoadDaysGrid;

  //общая подсказка
  FOpt.InfoArray:=[[
    'Регламент заказа.'#13#10+
    'Введите наименование регламента (отображается в журнале) и количество дней обработки заказа для данного регламента.'#13#10+
    'Важно: количество дней вводится нажатием на кнопку в этом поле справа, и при его вводе таблица регламента будет очищена!'#13#10+
    'Заполните таблицы типов закаа, свойств заказа и регламента прохождения по участкам.'#13#10+
    ''#13#10
  ]];

  *)
  //ок


  Result := False;
  Caption := 'Просчет';
  F.DefineFields := [
    ['id$i'],
    ['name$s','V=1:400::T']
  ];
  View := 'prod_calc_items';
  Table := 'v_prod_calc_items';
  Result := inherited;
  if not Result then
    Exit;
  SetGrids;
  Result := True;
end;

function  TFrmOWedtProdCalculation.SetGrids: Boolean;
var
  LFgrOptions: TFrDBGridOptions;
begin
//    ['$','',''],
  LFgrOptions := [myogColoredTitle, myogIndicatorColumn, myogHiglightEditableColumns, myogHiglightEditableCells, myogHasStatusBar];

  ts1.Caption := 'Материалы основвы';
  Frg1.Options := LFgrOptions;
  Frg1.Opt.SetFields([
    ['id$i','_id','100'],
    ['pos$i','_№','80'],
    ['id_assembly$i','Узел изделия','150','t=1'],
    ['panel_type$i','Панель|Тип','150','t=1'],
    ['panel_position$i','Панель|Расположение','150','t=1'],
    ['name$s','Материал','300;w;h','t=1'],
    ['info$s','Дополнительная информация','200;w;h','t=1'],
    ['length$f','Длина, м.','80','t=1'],
    ['width$f','Ширина, м.','80','t=1'],
    ['qnt$i','Количество, шт.','80','t=1'],
    ['waste_percent$f','Отходы, %','80','t=1'],
    ['consumption$f','Расход, м.кв.','80'],
    ['price0$f','Закупка, руб/кв.м.','80'],
    ['sum0$f','Закупка, сумма','80'],
    ['markup_percent$f','Наценка','80','t=1'],
    ['sum$f','Продажа, сумма','80']
  ]);
  Frg1.Opt.SetGridOperations('uad');
//  Frg.OnColumnsUpdateData := FrgColumnsUpdateData;
  Frg1.SetInitData([]);
  Frg1.Prepare;
  Frg1.RefreshGrid;


  ts1.Caption := 'Материалы основвы';
  Frg1.Options := LFgrOptions;
  Frg1.Opt.SetFields([
    ['id$i','_id','100'],
    ['pos$i','_№','80'],
    ['id_assembly$i','Узел изделия','150','t=1'],
    ['panel_type$i','Панель|Тип','150','t=1'],
    ['panel_position$i','Панель|Расположение','150','t=1'],
    ['name$s','Материал','300;w;h','t=1'],
    ['info$s','Дополнительная информация','200;w;h','t=1'],
    ['length$f','Длина, м.','80','t=1'],
    ['width$f','Ширина, м.','80','t=1'],
    ['qnt$i','Количество, шт.','80','t=1'],
    ['waste_percent$f','Отходы, %','80','t=1'],
    ['consumption$f','Расход, м.кв.','80'],
    ['price0$f','Закупка, руб/кв.м.','80'],
    ['sum0$f','Закупка, сумма','80'],
    ['markup_percent$f','Наценка','80','t=1'],
    ['sum$f','Продажа, сумма','80']
  ]);
  Frg1.Opt.SetGridOperations('uad');
//  Frg.OnColumnsUpdateData := FrgColumnsUpdateData;
  Frg1.SetInitData([]);
  Frg1.Prepare;
  Frg1.RefreshGrid;

  ts2.Caption := 'Материалы облицовки';
  Frg2.Options := LFgrOptions;
  Frg2.Opt.SetFields([
    ['id$i','_id','100'],
    ['pos$i','_№','80'],
    ['id_assembly$i','Узел изделия','150','t=1'],
    ['name$s','Материал','300;w;h','t=1'],
    ['info$s','Дополнительная информация','200;w;h','t=1'],
    ['length$f','Длина, м.','60','t=1'],
    ['width$f','Ширина, м.','60','t=1'],
    ['qnt$i','Количество, шт.','60','t=1'],
    ['waste_percent$f','Отходы, %','60','t=1'],
    ['id_banding_type$i','Заполнение','80','t=1'],
    ['consumption$f','Расход, м.п.','60'],
    ['price0$f','Закупка, руб/м.п.','60'],
    ['sum0$f','Закупка, сумма','60'],
    ['markup_percent$f','Наценка','60','t=1'],
    ['sum$f','Продажа, сумма','60']
  ]);
  Frg2.Opt.SetGridOperations('uad');
  Frg2.SetInitData([]);
  Frg2.Prepare;
  Frg2.RefreshGrid;

  ts3.Caption := 'Кромка';
  Frg3.Options := LFgrOptions;
  Frg3.Opt.SetFields([
    ['id$i','_id','100'],
    ['pos$i','_№','80'],
    ['id_assembly$i','Узел изделия','150','t=1'],
    ['name$s','Материал','300;w;h','t=1'],
    ['info$s','Дополнительная информация','200;w;h','t=1'],
    ['consumption$f','Расход, м.п.','60'],
    ['price0$f','Закупка, руб/м.п.','60'],
    ['sum0$f','Закупка, сумма','60'],
    ['markup_percent$f','Наценка','60','t=1'],
    ['sum$f','Продажа, сумма','60']
  ]);
  Frg3.Opt.SetGridOperations('uad');
  Frg3.SetInitData([]);
  Frg3.Prepare;
  Frg3.RefreshGrid;

  ts4.Caption := 'Профильные детали';
  Frg4.Options := LFgrOptions;
  Frg4.Opt.SetFields([
    ['id$i','_id','100'],
    ['pos$i','_№','80'],
    ['id_assembly$i','Узел изделия','150','t=1'],
    ['name$s','Материал','300;w;h','t=1'],
    ['info$s','Дополнительная информация','200;w;h','t=1'],
    ['length$f','Длина, м.','60','t=1'],
    ['qnt$i','Количество, шт.','60','t=1'],
    ['waste_percent$f','Отходы, %','60','t=1'],
    ['consumption$f','Расход, м.п.','60'],
    ['price0$f','Закупка, руб/м.п.','60'],
    ['sum0$f','Закупка, сумма','60'],
    ['markup_percent$f','Наценка','60','t=1'],
    ['sum$f','Продажа, сумма','60']
  ]);
  Frg4.Opt.SetGridOperations('uad');
  Frg4.SetInitData([]);
  Frg4.Prepare;
  Frg4.RefreshGrid;

  ts5.Caption := 'Фурнитура';
  Frg5.Options := LFgrOptions;
  Frg5.Opt.SetFields([
    ['id$i','_id','100'],
    ['pos$i','_№','80'],
    ['id_assembly$i','Узел изделия','150','t=1'],
    ['name$s','Материал','300;w;h','t=1'],
    ['id_tyoe$i','Тип','120'],
    ['info$s','Дополнительная информация','200;w;h','t=1'],
    ['qnt$i','Количество, шт.','60','t=1'],
    ['price0$f','Закупка, руб/м.п.','60'],
    ['sum0$f','Закупка, сумма','60'],
    ['markup_percent$f','Наценка','60','t=1'],
    ['sum$f','Продажа, сумма','60']
  ]);
  Frg5.Opt.SetGridOperations('uad');
  Frg5.SetInitData([]);
  Frg5.Prepare;
  Frg5.RefreshGrid;

  ts6.Caption := 'Электрика';
  Frg6.Options := LFgrOptions;
  Frg6.Opt.SetFields([
    ['id$i','_id','100'],
    ['pos$i','_№','80'],
    ['id_assembly$i','Узел изделия','150','t=1'],
    ['name$s','Материал','300;w;h','t=1'],
    ['id_tyoe$i','Тип','120'],
    ['info$s','Дополнительная информация','200;w;h','t=1'],
    ['qnt$i','Количество, шт.','60','t=1'],
    ['price0$f','Закупка, руб/м.п.','60'],
    ['sum0$f','Закупка, сумма','60'],
    ['markup_percent$f','Наценка','60','t=1'],
    ['sum$f','Продажа, сумма','60']
  ]);
  Frg6.Opt.SetGridOperations('uad');
  Frg6.SetInitData([]);
  Frg6.Prepare;
  Frg6.RefreshGrid;

end;

end.
