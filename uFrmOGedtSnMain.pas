unit uFrmOGedtSnMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, uLabelColors,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2
  ;


type
  TFrmOGedtSnMain = class(TFrmBasicGrid2)
    pnlName: TPanel;
    lblName: TLabel;
    Frg3: TFrDBGridEh;
    procedure tmrAfterCreateTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FDays: TVarDynArray;
    FPeriodNames: TVarDynArray;
    FEditFieldName: string;
    FPrcMinOst, FPrcQnt, FPrcNeedM: Extended;
    FFields3: string;
    FNames3: string;
    //начальная дата, на которую сформированы плановые потребности
    FPlannedDt: TDateTime;
    //данные для катомизации графы "в пути" - испольуются кастомные, дата конечная, дата начальная
    FCustomOnWay: TVarDynArray;
    //для передачи цвета ячеек в инфогрид, и в форму выгрузки в эксель
    FRowColors, FRowFontColors: TVarDynArray;
    //все категории (нейм, айди, пользователи)
    FCategoryes: TVarDynArray2;
    //свои категории
    FCategoryesSelf: TVarDynArray2;
    //айди категории, по которой была выставлена блокировка на редактирование текущим пользователем
    FIdCategoryLock: Variant;
    //если доступна категория "снабжение" (у них доп права)
    FIsSnab: Boolean;
    //включен режим редактирования любых данных, для администратора данных, включается по Ctrl-E в гриде
    FAdminEditMode: Boolean;
    InAddControlChangeEvent: Boolean;
    FLockEdit: Boolean;
    function  PrepareForm: Boolean; override;
    procedure SetDetailGrid;
    procedure SetCategoryes;
    procedure SetFieldsEditable;
    procedure EditSettings;
    procedure SetCategory;
    function  ExportGridToXLSX(Open: Boolean = False; OnlyNot0: Boolean = False): Boolean;
    procedure RecalcPlannedEst;
    procedure InfoOnTheQntInProccessing;
    procedure SetLock;
    procedure ViewXLSFiles;
    function  CreateDemand: Boolean;
    procedure FillFromPlanned;
    procedure SetDetailInfo;
    procedure ClearInvalidReserve;
  protected
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    procedure Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); override;
//    procedure Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Msg: string); virtual;
//    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); virtual;
    procedure Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
  public
  end;

var
  FrmOGedtSnMain: TFrmOGedtSnMain;

implementation

uses
  RegularExpressions,
  uWindows,
  uOrders,
  uPrintReport,
  D_Spl_InfoGrid,
  uFrmODedtNomenclFiles,
  uExcel,
  uSys,
  uFrmBasicInput
  ;

{$R *.dfm}

function TFrmOGedtSnMain.PrepareForm: Boolean;
var
  IsNstd: Boolean;
  va, va1: TVarDynArray;
  va2: TVarDynArray2;
  i, j: Integer;
begin
  Caption := 'Формирование заявок на снабжение';
  FDays:=Q.QLoadToVarDynArrayOneRow('select d0,d1,d2,d3,d4,d5,d6,prc_min_ost, prc_qnt, prc_need_m, planned_dt from spl_minremains_params', []);

  Q.QExecSql('delete from spl_remains_enter', []);
  FPrcMinOst:=FDays[7];
  FPrcQnt:=FDays[8];
  FPrcNeedM:=FDays[9];
  if FDays[10] = null
    then FPlannedDt := Date
    else FPlannedDt:=FDays[10];
  FDays:=Copy(FDays, 0, 7);
  FPeriodNames := [];
  for i := 0 to High(FDays) - 1 do
    FPeriodNames := FPeriodNames + [S.iif(FDays[i] < 0, 'нет', S.GetDaysCountToName(FDays[i]))];    //!!! ошибка при уборке периода в настройках
  //данные для кастомного отображения "в пути" (если onway_custom = 1) - важно порядок dt2, dt1, они в базе перепутаны логически(
  FCustomOnWay:=Q.QLoadToVarDynArrayOneRow('select onway_custom, onway_dt2, onway_dt1, onway_old_days from spl_minremains_params', []);
  //поля
  Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible, myogIndicatorCheckboxes, myogMultiSelect];
  va2 := [
    ['id$i','_id','40'],
    ['aprc_min_ost$f','_aprc_min_ost','40'],
    ['aprc_qnt$f','_aprc_qnt','40'],
    ['aprc_need_m$f','_aprc_need_m','40'],
    ['e_min_ostatok$i','_emo','40'],
    ['e_qnt_order_opt$i','_eoo','40'],
    ['e_qnt_order$i','_eqo','40'],

    ['id_category$i','Категория','80;L'],
    ['artikul$s','Номенклатура|Артикул','80'],
    ['name$s','Номенклатура|Наименование','180'],
    ['name_unit$s','Номенклатура|Ед.изм.','50'],
    ['has_files$s','Номенклатура|Файлы.','40','pic'],
    ['supplierinfo$s','Поставщик|Наименование','120','bt=Поставщики','t=2'],
    ['suppliers_cnt$s','Поставщик|Кол.','40','t=2'],
    ['no_namenom_supplier$s','Поставщик|Нет назв.','40','t=2','pic=-:6'],
    ['qnt0$f','Расход|'+S.GetDaysCountToName(FDays[0]),'60']
  ];
  //Q.QExecSql('selet 1 from', [], False);
  va := Copy(FPeriodNames, 1);
  //поля по периодам для прихода
  for i:=1 to High(va) + 1 do
    va2 := va2 + [['qnti' + InttoStr(i) + '$f', 'Приход|' + va[i - 1], '60', 't=1']];
  //поля по периодам для расхода
  for i:=1 to High(va) + 1 do
    va2 := va2 + [['qnt' + InttoStr(i) + '$f', 'Расход|' + va[i - 1], '60', 't=1']];
  va2 := va2 +
  [
    ['qnta0$f','Текущий остаток|ПЩ','60'],
    ['qnta1$f','Текущий остаток|И','60'],
    ['qnta2$f','Текущий остаток|ДМ','60'],
    ['qnt$f','Текущий остаток|Всего','60'],
    ['prc_qnt$f','% по остатку','40'],
    ['rezerva0$f','Текущий резерв|ПЩ','40'],
    ['rezerva1$f','Текущий резерв|И','40'],
    ['rezerva2$f','Текущий резерв|ДМ','40'],
    ['rezerv$f','Текущий резерв|Всего','40'],
    ['qnt_onway$f','В пути|Кол-во','40'],
    ['onway_old$f','В пути|Давно','40', 'pic=1:3'],
    ['qnt_in_processing$f','В обработке','40'],
    ['qnt_suspended$f','Зависшие остатки','40'],
    ['min_ostatok$i','Минимальный остаток|ВВОД','40','t=3'],
    ['prc_min_ost$f','Минимальный остаток|%','40'],
    ['qnt_order_opt$i','Партия ВВОД','40','t=3'],
    ['planned_need_days$i','Период закупки  ВВОД','40','t=3'],
    ['qnt_order$f','Заказ|ВВОД','60','t=3'],
    ['to_order$i','Заказ|В заявку','40', 'chb','f=f:','t=3'],
    ['need$f','Потребность|Мин.','60'],
    ['need_p$f','Потребность|Плановая','60'],
    ['need_m$f','Потребность|С остатком','60'],
    ['prc_need_m$f','Потребность|%','40'],
    ['price_check$f','Стоимость|Контрольная цена','60'],
    ['price_main$f','Стоимость|Цена','60'],
    ['order_cost$f','Стоимость|Заказ','60','f=r:'],
    ['qnt_cost$f','Стоимость|Остаток','60','f=r:'],
    ['onway_cost$f','Стоимость|В пути','60','f=r:'],
    ['ornumwoqnt$s','Заказ с нехваткой','60'],
    ['qnt_pl1$f','Плановый резерв|' + MonthsRu[MonthOf(IncMonth(FPlannedDt, 0))],'60'],
    ['qnt_pl2$f','Плановый резерв|' + MonthsRu[MonthOf(IncMonth(FPlannedDt, 1))],'60'],
    ['qnt_pl3$f','Плановый резерв|' + MonthsRu[MonthOf(IncMonth(FPlannedDt, 2))],'60'],
    ['qnt_pl$f', 'Плановый резерв|Всего','60']
  ];
  Frg1.Opt.SetFields(va2);
  Frg1.Opt.SetTable('v_spl_minremains');

  //кнопки (формирование заявки только для тех у кого права на изменение)
  Frg1.Opt.SetButtons(1,[[mbtRefresh],[],[mbtParams, User.Role(rOr_Other_R_MinRemains_Ch)],[mbtGridSettings,User.Role(rOr_Other_R_MinRemains_ViewReports)],[],
    [-mbtCustom_SetCategory],
    [],[-1003,True,'Выбрать заказ'],[],
    [-mbtCustom_SnRecalcPlannedEst, User.Role(rOr_Other_R_MinRemains_Ch), 'Пересчитать плановую потребность'],
    [-mbtCustom_SnFillFromPlanned, 1, 'Заполнить из плановой потребности'], [-mbtCustom_SetOnWayPeriod],
    [],[-1002,User.Role(rOr_Other_R_MinRemains_Ch),'Очистить подвисшие резервы'],[],
    [],[mbtExcelView],[-1001, True,'Просмотреть историю'],[],[mbtGo, User.Role(rOr_Other_R_MinRemains_Ch), 'Сформировать заявку'],[mbtCtlPanel]
  ]);
  Frg1.Opt.SetButtonsIfEmpty([1003]);

  Frg1.CreateAddControls('1', cntCheck, 'Данные по периодам', 'ChbPeriods', '', 4, yrefC, 129);
  Frg1.CreateAddControls('1', cntCheck, 'Поставщик', 'ChbSupplier', '', -1, yrefC, 120);
//  Frg1.CreateAddControls('1', cntCheck, 'Артикул, ед.изм.', 'chb_Article', '', 260, yrefT, 120);
//  Frg1.CreateAddControls('1', cntCheck, 'Только выбранные', 'chb_Checked', '', 1, yrefB, 120);
//  Frg1.CreateAddControls('1', cntCheck, 'По фак. остаткам', 'chb_AQnt', '', 130, yrefB, 120);
//  Frg1.CreateAddControls('1', cntCheck, 'По мин. остаткам', 'chb_AMinOst', '', 260, yrefB, 120);
//  Frg1.CreateAddControls('1', cntCheck, 'По потребности', 'chb_ANeedM', '', 390, yrefB, 120);

  Frg1.CreateAddControls('1', cntComboLK, 'Категория', 'CbCategory', '', 420, yrefC, 180);
  Frg1.CreateAddControls('1', cntCheck, 'Пустые', 'ChbCatEmpty', '', 620 , yrefC, 80);
  Frg1.CreateAddControls('1', cntCheck, 'Все', 'ChbCatAll', '', 620 + 80, yrefC, 40);
//  Frg1.ReadControlValues;

  Frg2.Opt.SetFields([
    ['id$i','_id','40'],
    ['dt$d','Дата','120'],
    ['state$s','Статус','120'],
    ['supplierinfo$s','Основной поставщик','150'],
    ['qnta0$f','Текущий остаток|ПЩ','60'],
    ['qnta1$f','Текущий остаток|И','60'],
    ['qnta2$f','Текущий остаток|ДМ','60'],
    ['qnt$f','Текущий остаток|Всего','60'],
    ['rezerva0$f','Текущий резерв|ПЩ','40'],
    ['rezerva1$f','Текущий резерв|И','40'],
    ['rezerva2$f','Текущий резерв|ДМ','40'],
    ['rezerv$f','Текущий резерв|Всего','40'],
    ['qnt_onway$f','В пути','40'],
    ['qnt_in_processing$f','В обработке','40'],
    ['planned_need_days$i','Период закупки','40','t=3'],
    ['qnt_order$f','Заказ|Кол-ко','60','t=3'],
    ['to_order$i','Заказ|В заявку','40', 'chb','t=3'],
    ['need$f','Потребность|Мин.','60'],
    ['need_p$f','Потребность|Плановая','60'],
    ['price_check$f','Стоимость|Контрольная цена','60'],
    ['price_main$f','Стоимость|Цена','60'],
    ['qnt_pl1$f','Плановый резерв|' + MonthsRu[MonthOf(IncMonth(FPlannedDt, 0))],'60'],
    ['qnt_pl2$f','Плановый резерв|' + MonthsRu[MonthOf(IncMonth(FPlannedDt, 1))],'60'],
    ['qnt_pl3$f','Плановый резерв|' + MonthsRu[MonthOf(IncMonth(FPlannedDt, 2))],'60'],
    ['qnt_pl$f', 'Плановый резерв|Всего','60']
  ]);
  Frg2.Opt.SetTable('spl_history');
  Frg2.Opt.SetWhere('where id = :id$i');
  Frg2.Opt.Caption := 'История по номенклатуре';

  SetCategoryes;

  //изменяемые поля если есть права на изменение
  SetFieldsEditable;

  SetDetailGrid;

  Frg1.InfoArray:=[
    [Caption + '.'#13#10#13#10],[
    'В таблице по каждой номенклатурной позиции отображаются данные по расходу и приходу за выбранные периоды,'#13#10+
    'информация по текущему остатку на складах и резерву, текущему минимальному остатку, '#13#10+
    'товару в пути и в обработке по заявкам.'#13#10+
    'На основании этих даннх непосредственно в таблице вводятся парамеры номенклатуры для снабжания:'#13#10+
    'минимальный поддерживаемый на складе остаток, оптимальный размер партии к заказу'#13#10+
    'и принимается решние, какой и сколько номенклатуры необходимо заказать.'#13#10+
    'Для облегчения оценки выводятся данныепо процентам относительно расхода за оценочный период,'#13#10+
    'при достижении пороговых значений данные подсвечиваются.'#13#10+
    'Для справки выводятся данне по расходу и приходу номенклатурры за несколько (до 6) периодов, последняя цена и суммы.'#13#10+
    'Для части данных доступна детализация, окно с ней открывается по двойному клику в ячейке.'#13#10+
    'Также необходимо привязать к позициям номенклатуру поставщиков, форма для этого открывается при нажатии кнопки в колонке "Поставщик".'#13#10+
    'Для этого менеджер вводит размер заказа и устанавливает галку "в заявку".'#13#10+
    'Для создания заявки в ИТМ необходимо нажать кнопку "Старт", будут сформированы заявки по позициям,'#13#10+
    'по которым проставлен объем заказа и галочка "В заказ"'#13#10+
    'Все вводимые данные в таблице сохраняются непосредственно в момент ввода.'#13#10+
    'При формировании заявки сбросится только галочка "В заявку", все остальные данные сохранятся.'#13#10+
    ''#13#10+
    'Настройки (проценты для предупреждения, периоды) задаются по кнопке "Параметры" и действуют для всех пользователей.'#13#10+
    ''#13#10+
    'В таблице работает поиск, фильтрация, сортировка столбцов, Вы можете перемещать столбцы, показывать их и скрывать (используйте кнопку вида таблицы)'#13#10+
    ''#13#10
  ]];
  Frg1.Opt.ColumnsInfo:=[
    ['tomin', 'Если галочки проставлены, то можно отметить галочку "Только выбранные" в заголовке, и в таблице будут отображаться только эти записи'],
    ['id_category' ,
      'Номенклатура распределена по категориям снабжения. Вы видете здесь только свои категории (и пустые, если поставлена галка'+
      '"Показывать пустые"'#13#10'Пока категория не будет проставлена, вы не сможете ввести данные в таблицу по этой записи'#1#10+
      'Выбрать ее можно из выпадающего списка для конкретно позиции, или же отметить нужные позицци галками и выбрать пункт "задать категорию" в контектном меню.'#1#10+
      'При формировании заявки, формируется отдельная заявка на снабжение для каждой категории, категория указывается в комментарии к заявке'+
      ''#1#10
    ],
    ['supplierinfo', 'Отображается наименование основного поставщика по данной номенклатуре. Поле будет пустым, если записей в таблице Номенклатура поставщика'+
      'несколько, но позиция по умолчанию не выбрана'#1#10+
      'Нажмите кнопку справа в ячейке чтобы просмотреть (или редактировать, если у вас есть права) данные по номенклатуре поставщика'#1#10
    ],
    ['suppliers_cnt', 'Количество записей в таблице Номенклатура поставщика для данной номенклатурной позиции'],
    ['no_namenom_supplier', 'Если таблица Номенклатура поставщиков для данной строки непустая, но в этой таблице есть строки с пустыми наименованиями, здеть будет отображаться красный минус'],
    ['qnt0','Расход по номенклатуре за оценочный период. С учетом этого периода, а его можно задать в настройках, рассчитываются все проценты и подсветка данных в таблице.'+
     'Расход расчитывается по проведенным накладным при выдаче в производство, а также по актам сисания.'#1#10+
     'По двойному клику мышки можно посмотреть детализацию по расходу'#1#10
    ],
    ['qnt1;qnt2;qnt3;qnt4;qnt5;qnt5','Расход по номенклатуре за заданный период. Расход расчитывается по проведенным накладным при выдаче в производство, а также по актам сисания.'+
     'По двойному клику мышки можно посмотреть детализацию по расходу'#1#10
    ],
    ['qnti1;qnti2;qnti3;qnti4;qnti5;qnti5','Приход по номенклатуре за заданный период. Расчитывается по проведенным приходным накладным, акты оприходования не учитываются.'+
     'По двойному клику мышки можно посмотреть детализацию по приходу'#1#10
    ],
    ['qnt', 'Текущий (фактический) остаток на всех складах (но не на производстве. подсвечивается красным, если проценнт остатка от '+
    'расхода за оценочный период меньше 50% (этот процент настраивается). По двойному клику будут показаны остатки по складам.'
    ],
    ['prc_qnt', 'показывает, сколько процентов составляет фактически остаток от расхода за оценочный период. Глобально задается в настройках, но может быть изменен для конкретной записи, в этом случае он будет подсвечен синим (для изменения сделайте двойной клик в ячейке)'],
    ['rezerv', 'Резерв по заказам. Сделайте двойной клик по ячейке, чтобы посмотреть детализацию'],
    ['qnt_onway', 'Рассчитывается как количестов товара в счете поставщика, по которыму еще не созданы приходные накладные. По даблклику вы можете посмотреть детализациэацию.'#13#10+
    'Для контроля можно задать произвольные период расчета для этих данных (по правой кнопке мышки).'#13#10+
    'Если этот период задан, он действует и на расчет данных для всей таблицы, а данные в этом столбце будут подсвечены синим.'
    ],
//    ['qnt_in_processing','количество по позиции, по кторой созданы заявки на снабжение, за минусом уже оприходованного количества и за минусом количества В пути. По даблклику - дополнительная информация.'],
    ['qnt_in_processing','количество по заявкам на снабжение за последние 7 дней. По даблклику - список заявок СН.'],
    ['min_ostatok','Остаток, который должен поддерживаться на складах. Вводится в ячеке, если есть права на ркдактирование. '+
     'Подсвечивается красным, если этот остаток на 10% меньше расхода за оценочный период, и желтым, если на 10% больше расхода. '+
     '(процент оценки можно изменить в настройках, а также и отдельно для нужнх позиций.)'
    ],
    ['prc_min_ost', 'Показывает, насколько минимальный остаток превышает разход за оценочный период, в процентах. '+
     'Если раход больше мин. остатка, то процент будет меньше нуля, если же расход меньше, то процент будет пложительный. ' +
     'по этим данным поле "Мин. остаток" подсвечивается. Процент для подсветки конкретной номенклатуры можно изменитиь, для '+
     'этого дважды кликните на этой ячейке и введите значение. Изменнные позиции будут подсвечиваться синим шрифтом.'
    ],
    ['qnt_order_opt','Оптимальная партия для закупки товара. Вводится в ячеке.'],
    ['qnt_order','Количество по номенклатуре в основных единицах измерения, которое попадет в заявку на снабжение в ИТМ. Вводится в ячейке.'+
     'Если нажать левый Shift, то будет введено значении оптимальной партии. Введенное значение не сбрасывается при формировании заявки.'
    ],
    ['to_order','Те позиции, по которым здесь проставлены галочки (при условии, что к ним также проставлено количество к заказу), при нажатии кнопки "Сформировать заяку", попадут в создаваемую в ИТМ заявку поставщику.'],
    ['need','Это количество нужно привезти, чтобы закрыть потребность (закрыть резерв по заказам, с учетом количества, которое есть на складе, и с учетов того, что уже заказано и в пути).'+
     'Заказывать необходимо, если потребность отрицательная. В этом случае ячейка будет подсвечена серым.'
    ],
    ['need_m','Это количество нужно привезти, чтобы закрыть потребность (закрыть резерв по заказам, с учетом количества, которое есть на складе, и с учетов того, что уже заказано и в пути.), '+
     'и при этом довести количество на складах до минимального остатка. Заказывать необходимо, если потребность отрицательная. В этом случае ячейка будет подсвечена серым.'
    ],
    ['price_main','Цена последнего прихода по номенклатуре, на основании ПН от основного поставщика (в наших единицы измерения). '+
     'Цена подсвечивается, если ее целая часть хотя бы на 1 рубль отличается он контрольной цены.'+
     'По двойному клику будет показан список всех приходных накладных по позицции, в нем таже возможен просмотр самих накладных.'
    ],
    ['order_cost','Стоимость (по последней цене) товара в количестве, введенной в графе "К заказу". По двойному щелчку будут показаны данные из счетов по этой номенклатуре за весь период, там же возможен просмотр самих счетов.'],
    ['qnt_cost','Стоимость фактического остатка'],
    ['onway_cost','Стоимость товара "в пути"'],
    ['ornumwoqnt','Самый ранний по дате отгрузки заказ (номер и дата отгрузки), на который не хватает складского запаса плюс товара в пути.'],
    ['price_check','Цена для контроля закупок по позиции, вводится вручную.'],
    ['has_files','Галочка в этом поле показывает, что к данной номенклатуре есть прикрепленные файлы. По двойному щелчку будет открыт диалог с возможностью просмотра и копирования этих файлов.'],
    ['qnt_pl1;qnt_pl2;qnt_pl3','Потребность по плановым заказам за указанный месяц. По двойному щелчку будут отображены плановые заказы, по которым посчитана эта потребность, с возможностью их просмотра.'],
    ['qnt_pl','Потребность по плановым заказам за три месяца, начиная с текущего. При изменении плановых заказов и смет и переходе в следующий месяц автоматически не пересчитывается! Чтобы расчитать ее заново, выберите "Пересчитать плановую потребность" в меню.'],
    ['qnt_suspended','Зависшие остатки - текущий остаток, деленный на расход по третьему периоду (длительность периода задается в настройках таблицы)'],
    ['','']
  ];


  Result := inherited;
//  Frg1.Prepare;
//  Result := True;

  FIdCategoryLock := -1;
//  SetLock;

  SetLength(FRowColors, Frg1.DBGridEh1.Columns.Count + 1);
  SetLength(FRowFontColors, Frg1.DBGridEh1.Columns.Count + 1);

  FrmOGedtSnMain := Self;
end;

procedure TFrmOGedtSnMain.SetDetailGrid;
begin
  Frg3.Opt.SetFields([
    ['id$i', '_id', 20],
    ['qnt$f', 'Остаток', 50],
    ['prc_qnt$f', '%', 20],
    ['rezerv$f', 'Резерв', 50],
    ['qnt_onway$f', 'В пути', 50],
    ['qnt_in_processing$f', 'В обр.', 50],
    ['min_ostatok$f', 'Мин.ост.', 55],
    ['prc_min_ost$f', '%', 20],
    ['qnt_order_opt$f', 'Партия', 50],
    ['need$f', 'Потребность', 80],
    ['need_m$f', 'Потребность+', 80],
    ['price_main$f', '? Цена', 70],
    ['order_cost$f', '? Заказ', 70],
    ['qnt_cost$f', '? Остаток', 70],
    ['onway_cost$f', '? В пути', 70],
    ['qnt0$f', 'Расход 1', 70],
    ['qnt2$f', 'Расход 2', 70],
    ['qnt3$f', 'Расход 3', 70],
    ['qnt4$f', 'Расход 4', 70],
    ['qnt5$f', 'Расход 5', 70],
    ['qnt6$f', 'Расход 6', 70],
    ['qnti1$f', 'Приход 1', 70],
    ['qnti2$f', 'Приход 2', 70],
    ['qnti3$f', 'Приход 3', 70],
    ['qnti4$f', 'Приход 4', 70],
    ['qnti5$f', 'Приход 5', 70],
    ['qnti6$f', 'Приход 6', 70]
  ]);
  Frg3.Opt.SetDataMode(myogdmFromArray);
  Frg3.Prepare;
  Frg3.LoadSourceDataFromArray([[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]]);
  Frg3.DbGridEh1.HorzScrollBar.VisibleMode := sbNeverShowEh;
end;


{события грида}

procedure TFrmOGedtSnMain.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
  Frg1.Opt.SetColFeature('1', 'i', Cth.GetControlValue(Fr, 'ChbPeriods') = 0, False);
  Frg1.Opt.SetColFeature('2', 'i', Cth.GetControlValue(Fr, 'ChbSupplier') = 0, False);
  Frg1.SetColumnsVisible;
  if not A.InArray(TControl(Sender).Name, ['ChbPeriods', 'ChbSupplier']) and Fr.IsPrepared then
    Frg1.RefreshGrid;
end;

procedure TFrmOGedtSnMain.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
var
  i, j: Integer;
  va1, va2: TVarDynArray;
  b: Boolean;
begin
  if Tag = mbtGo then begin
    CreateDemand;
  end
  else if Tag = mbtTest then begin
  end
  else if Tag = mbtExcelView then begin
    ViewXLSFiles;
  end
  else if Tag = mbtExcel then begin
    ExportGridToXLSX(True, False);
  end
  else if Tag = mbtCustom_SetCategory then begin
    SetCategory;
  end
  else if Tag = mbtCustom_SnRecalcPlannedEst then begin
    RecalcPlannedEst;
  end
  else if Tag = mbtCustom_SnFillFromPlanned then begin
    FillFromPlanned;
  end
  else if Tag = 1001 then begin
    va1 := Q.QLoadToVarDynArrayOneCol('select caption from v_spl_history_contents', []);
    if TFrmBasicInput.ShowDialog(Parent, '', [], fAdd, '~История состояния СН', 50 + 200, 50,
      [[cntComboL, 'Дата:','1:500']],
      [VarArrayOf(['', VarArrayOf(va1)])],
      va2, [['']], nil
    ) < 0 then
      Exit;
    Wh.ExecReference(myfrm_J_SnHistory, Self, [], va2[0]);
  end
  else if Tag = 1002 then begin
    ClearInvalidReserve;
  end
  else if Tag = 1003 then begin
    va1 := Q.QLoadToVarDynArrayOneCol('select ornum from v_orders where id > 0 and id_itm is not null order by id', []);
    va2 := Q.QLoadToVarDynArrayOneCol('select id from v_orders where id > 0 and id_itm is not null order by id', []);
    if TFrmBasicInput.ShowDialog(Parent, '', [], fAdd, '~Заказ для фильтра', 50 + 100, 50,
      [[cntComboLK, 'Заказ:','0:500']],
      [VarArrayOf([null, VarArrayOf(va1), VarArrayOf(va2)])],
      va2, [['']], nil
    ) < 0 then
      Exit;
    if va2[0].AsString = '' then begin
      Frg1.Opt.SetWhere('');
      Frg1.Opt.Caption := Caption;
    end
    else begin
      va1 := Q.QLoadToVarDynArrayOneRow('select id_itm, ornum from v_orders where id = :id$i', [va2[0]]);
      Frg1.Opt.SetWhere(' where id in (select id_nomencl from dv.nomenclatura_in_izdel where id_nomizdel_parent_t is not null and id_zakaz = ' + va1[0].AsString + ')');
      Frg1.Opt.Caption := Caption + ' (' + va1[1].AsString + ')';
    end;
    Frg1.RefreshGrid;
 end
  else if Tag = mbtParams then begin
    repeat
      va2:=[];
      va1 := copy(FDays);
      for i := 0 to High(va1) do
        if va1[i] < 0 then
          va1[i] := 0;
      if TFrmBasicInput.ShowDialog(Self, '', [], fEdit, '~Параметры', 200, 100,
          [
            [cntNEdit, '% выделения'#13#10'мин. остатка', '1:100', 80],
            [cntNEdit, '% выделения'#13#10'факт. остатка', '1:100', 80],
            [cntNEdit, '% выделения'#13#10'потребности', '1:100', 80],
            [cntNEdit, 'Период оценки', '1:10000', 80],
            [cntNEdit, 'Период 1', '0:10000', 80], [cntNEdit, 'Период 2', '0:10000', 80],
            [cntNEdit, 'Период 3', '0:10000'], [cntNEdit, 'Период 4', '0:10000', 80], [cntNEdit, 'Период 5', '0:10000', 80], [cntNEdit, 'Период 6', '0:10000', 80]
          ],
          [FPrcMinOst, FPrcQnt, FPrcNeedM] + va1,
          va2,
          [['Задайте период оценки, проценты для выделения значений и периоды просмотра расхода/прихода (в днях).'#13#10+
            'Если поставить 0, то данный период отображаться не будет.'#13#10+
            'Период оценки желательно чтобы совпадал с периодом 1'#13#10+
            'Значения, установленные здесь, действуют глобально для всех пользователей!'
           ]],
           nil
        ) <= 0 then Exit;  //выход по отмене или если нет изменений
      b := True;
      for i := 3 to High(va2) do
        if va2[i] > 0 then
          b := False;
      if not b then
        Break;
      va1 := Copy(va2);
      MyWarningMessage('Должен быть задан хотя бы один период!');
    until False;
    FPrcMinOst := va2[0];
    FPrcQnt := va2[1];
    FPrcNeedM := va2[2];
    va1 := Copy(va2, 4);
    for i := 0 to High(va1) do
      if va1[i] = 0 then
        va1[i] := 100000;
    a.VarDynArraySort(va1, True);
    for i := 0 to High(va1) do
      if va1[i] = 100000 then
        va1[i] := -100;
    FDays := [va2[3]] + va1;
    Q.QExecSql(
      'update spl_minremains_params set '+
      'd0=:d0$i,d1=:d1$i,d2=:d2$i,d3=:d3$i,d4=:d4$i,d5=:d5$i,d6=:d6$i,prc_min_ost=:prc_min_ost$i,prc_qnt=:prc_qnt$i,prc_need_m=:prc_need_m$i',
      [va2[3]] + va1 + [FPrcMinOst, FPrcQnt, FPrcNeedM]
    );
//    SetCaptions;
//!!!    Gh.SetGridColumnsProperty(DBGridEh1, cptCaption, Pr[1].Fields, Pr[1].Captions);
    Fr.RefreshGrid;
  end
  else if Tag = mbtCustom_SetOnWayPeriod then begin
    if TFrmBasicInput.ShowDialog(Self, '', [], fEdit, '~Период "В пути', 200, 100,
        [
          [cntCheck, 'Включить', '', 80],
          [cntDtEdit, 'Период с', '*:*', 80],
          [cntDtEdit, 'по', '*:*', 80],
          [cntNEdit, 'Подсветка, дней', '0:10000:0', 80]
        ],
        FCustomOnWay,
        va2,
        [['Задайте период отсечки данных для графы "В пути"'#13#10+
          '(для использования этих значений установить галочку "включить")'#13#10+
          'Важно: в расчете остальных данных будет взято именно это значение "в пути"!'#13#10+#13#10+
          'Также установите параметр "Подсветка, дней".'#13#10+
          'При этом ячейки, где есть более ранние записи по товару в пути, будут подсвечены красным фоном..'#13#10
         ]],
         nil
      ) <= 0 then Exit;  //выход по отмене или если нет изменений
    FCustomOnWay:= va2;
    Q.QExecSql('update spl_minremains_params set onway_custom = :p1$i, onway_dt2 = :p2$d, onway_dt1 = :p3$d, onway_old_days = :p4$i', FCustomOnWay);
    Fr.RefreshGrid;
  end
  else
    inherited;
end;

procedure TFrmOGedtSnMain.Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
  if Fr.CurrField = 'supplierinfo' then begin
    Wh.ExecDialog(myfrm_Dlg_SupplierMinPart, Self, [myfoModal, myfoSizeable], S.IIf(User.Role(rOr_Other_R_MinRemains_Ch_Suppl), fEdit, fView), Fr.ID,
      VararrayOf([Fr.GetValue('name'), Fr.GetValue('name_unit')])
    );
    Fr.RefreshRecord;
  end;
  Fr.ChangeSelectedData;
end;

procedure TFrmOGedtSnMain.Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
var
  st1, st2: string;
  i: Integer;
  b: Boolean;
begin
  //поля, которые будут заменены на null независимо от их видимости [поля, скрыть(True), {сделать служебными - только если есть замена на нулл}, {значение для null - null, 0}]
(*  Pr[1].NullFields := [];
  b := Cth.GetControlValue(TControl(Self.FindComponent('chb_Periods'))) = 1;
  for i := 1 to High(FDays) do
    if (FDays[i] < 0) { or (not b)} then begin
      Pr[1].NullFields := Pr[1].NullFields + [['qnt' + IntToStr(i), True, False, 0]];
      Pr[1].NullFields := Pr[1].NullFields + [['qnti' + IntToStr(i), True, False, 0]];
    end;*)
  SqlWhere := A.ImplodeNotEmpty([
    //S.IIf(TDbCheckBoxEh(Self.FindComponent('chb_Checked')).Checked, 'nvl(tomin, 0) = 1', ''),
    //S.IIf(TDbCheckBoxEh(Self.FindComponent('chb_AMinOst')).Checked, '(prc_min_ost <= -aprc_min_ost or prc_min_ost >= aprc_min_ost)', ''),
    //S.IIf(TDbCheckBoxEh(Self.FindComponent('chb_AQnt')).Checked, '(prc_qnt <= aprc_qnt)', ''),
    //S.IIf(TDbCheckBoxEh(Self.FindComponent('chb_ANeedM')).Checked, '((need_m < 0)or(prc_need_m <= -aprc_need_m or prc_need_m >= aprc_need_m))', ''),
    S.IIfStr((Fr.GetControlValue('ChbCatAll') = 0) and (Length(FCategoryesSelf) > 0),
      '(id_category = ' + VarToStr(Fr.GetControlValue('CbCategory')) + S.IIfStr(Fr.GetControlValue('ChbCatEmpty') = 1, ' or id_category is null') + ')')
    ], ' and '
  );
end;


procedure TFrmOGedtSnMain.Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
//при вводе данных в гриде вручную (нажатие Enter или уход фокуса после того, как были введены данные в редакторе ячейки, или клик по чекбоксу)
var
  i: Integer;
  e: extended;
  va2: TVarDynArray2;
begin
  Handled := True;
  if not Fr.RefreshRecord then begin
    //сюда попадем, если запись была удалена (сообдение будет выдано в RefreshRecord)
    Fr.MemTableEh1.Cancel;
    Exit;
  end;
  //SetFieldEditable делать обязательно, без этого не сработает, все равно будет запись в таблицу, даже если проверять MemTableEh1.ReadOnly и здесь,
  //и даже ниже, непосредственно при записи. не знаю почему так происходит, в общем не принципиально. Можно в принципе просто вызвать и проверить CancelEdit,
  //но это не позволит снять подчеркивание, если ячейка заблокировалась на редактирование, но не было ухода фокуса.
//!!!  SetFieldEditable(1);
//  if MemTableEh1.ReadOnly then begin
//    MemTableEh1.Cancel;
//    Exit;
//  end;
  //обработаем изменения ячейки, для чисел новое значение возьмем из параметра процедуры (Value)
  //для чекбоксов значение берем как MemTableEh1.FieldByName(Fr.CurrField).AsInteger,
  //и при этом его надо инвертировать (если получен 0, то в базу пишем 1, и наоборот)!
  //для перемещения в ячеку внизу по Enter вызываем GoToNextEdit(1), но злоупотреблять им нельзя,
  //поскольку перемещается в ячейку на строку вниз по факту при любом уходе фокуса, даже если ушли мышкой в другую ячейку.
  //в случае, если была запись в базу, перечитаем строку (расчет значений зависимых ячеек ведется в базе данных во вью).
  repeat
    if (Fr.CurrField = 'tomin') then begin
      i := S.Iif(Fr.MemTableEh1.FieldByName(Fr.CurrField).AsInteger = 0, 1, 0);
      Q.QCallStoredProc('p_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([Fr.ID, 1, S.NullIfEmpty(Value)]));
      Fr.RefreshRecord;
    end;
    if (Fr.CurrField = 'min_ostatok') then begin
      if not (S.IsNumber(Value, 0, 1000000) or (VarToStr(Value) = '')) then
        Break;
      Q.QCallStoredProc('p_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([Fr.ID, 2, S.NullIfEmpty(Value)]));
//      GoToNextEdit(1);    //для перемещения в ячекй внизу по Enter
      Fr.RefreshRecord;
    end;
    if (Fr.CurrField = 'qnt_order_opt') then begin
      if not (S.IsNumber(Value, 0, 1000000) or (VarToStr(Value) = '')) then
        Break;
      Q.QCallStoredProc('p_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([Fr.ID, 3, S.NullIfEmpty(Value)]));
//      GoToNextEdit(1);    //для перемещения в ячекй внизу по Enter
      Fr.RefreshRecord;
    end;
    if (Fr.CurrField = 'to_order'){ and not MemTableEh1.ReadOnly} then begin
      i := S.Iif(Fr.MemTableEh1.FieldByName(Fr.CurrField).AsInteger = 0, 1, 0);
      Q.QCallStoredProc('p_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([Fr.ID, 5, S.NullIfEmpty(Value)]));
      va2 := Q.QLoadToVarDynArray2('select to_order from spl_itm_nom_props where id = :id$i', [Fr.ID]);
      if (Length(va2) = 0) or (va2[0][0] <> S.NullIfEmpty(Value)) then begin
        MyWarningMessage('Не удалось установить значение!');
        Fr.MemTableEh1.Cancel;
      end
      else begin
        Fr.MemTableEh1.FieldByName(Fr.CurrField).AsInteger := i;
        Mth.PostAndEdit(Fr.MemTableEh1);
//        Exit;
      end;
      //MemTableEh1.RefreshRecord;
      //Mth.PostAndEdit(MemTableEh1);
    end;
    if (Fr.CurrField = 'qnt_order') then begin
      if not (S.IsNumber(Value, 0, 1000000) or (VarToStr(Value) = '')) then
        Break;
      Q.QCallStoredProc('p_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([Fr.ID, 4, S.NullIfEmpty(Value)]));
      va2 := Q.QLoadToVarDynArray2('select qnt_order from spl_itm_nom_props where id = :id$i', [Fr.ID]);
      if (Length(va2) = 0) or (va2[0][0] <> S.NullIfEmpty(Value)) then begin
        MyWarningMessage('Не удалось установить значение!');
        Fr.MemTableEh1.Cancel;
      end
      else begin
        Fr.MemTableEh1.FieldByName(Fr.CurrField).AsVariant := S.NullIfEmpty(Value);
        Fr.MemTableEh1.FieldByName('order_cost').AsVariant := S.NullIf0(Round(S.NNum(Value) * S.NNum(Fr.MemTableEh1.FieldByName('price_main').AsFloat)));
        Fr.MemTableEh1.FieldByName('e_qnt_order').AsInteger := 1;
        Mth.PostAndEdit(Fr.MemTableEh1);
//        GoToNextEdit(1);    //для перемещения в ячекй внизу по Enter
      end;
    end;
    if (Fr.CurrField = 'id_category') then begin
      Q.QCallStoredProc('p_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([Fr.ID, 6, S.NullIfEmpty(Value)]));
      Fr.RefreshRecord;
    end;
    if (Fr.CurrField = 'price_check') then begin
      if not (S.IsNumber(Value, 0, 100000000, 2) or (VarToStr(Value) = '')) then
        Break;
      Q.QCallStoredProc('p_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([Fr.ID, 7, S.NullIfEmpty(Value)]));
      Fr.RefreshRecord;
    end;
    if (Fr.CurrField = 'planned_need_days') then begin
      if not (S.IsNumber(Value, 0, 90, 0) or (VarToStr(Value) = '')) then
        Break;
      Q.QCallStoredProc('p_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([Fr.ID, 9, S.NullIfEmpty(Value)]));
      Orders.CalcSplNeedPlanned(Fr.ID);
      Fr.RefreshRecord;
    end;
    //!!!обязательно!!!
    Fr.ChangeSelectedData;
    Exit;
  until False;
  Fr.MemTableEh1.Cancel;
end;

procedure TFrmOGedtSnMain.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
var
  v: Variant;
begin
//exit;
  if Fr.IsEmpty then
    Exit;
  if FieldName = 'min_ostatok' then begin
    if S.NNum(Fr.GetValue('prc_min_ost')) <= - S.NNum(Fr.GetValue('aprc_min_ost')) then
      Params.Background := clmyPink;  //розовый
    if S.NNum(Fr.GetValue('prc_min_ost')) >= + S.NNum(Fr.GetValue('aprc_min_ost')) then
      Params.Background := clmyYelow;  //желтый
  end;
  if FieldName = 'qnt_order_opt' then begin
    if Fr.GetValue('e_qnt_order_opt') = 1 then begin
      Params.Font.Color := clBlue;
      Params.Font.Style := [fsUnderline];
    end;
  end;
  if FieldName = 'min_ostatok' then begin
    if Fr.GetValue('e_min_ostatok') = 1 then begin
      Params.Font.Color := clBlue;
      Params.Font.Style := [fsUnderline];
    end;
  end;
  if FieldName = 'qnt_order' then begin
    if Fr.GetValue('e_qnt_order') = 1 then begin
      Params.Font.Color := clBlue;
      Params.Font.Style := [fsUnderline];
    end;
    if (S.NNum(Fr.GetValue('to_order')) = 1) and (
      (S.NNum(Fr.GetValue('need_p')) >= 0) or
      (S.NNum(Fr.GetValue('qnt_order')) / - S.NNum(Fr.GetValue('need_p')) > 1.33))
      then Params.Background := clmyPink;
  end;
  if FieldName = 'prc_qnt' then begin
    if S.NNum(Fr.GetValue('aprc_qnt')) <> FPrcQnt then
      Params.Font.Color := clBlue;
  end;
  if FieldName = 'prc_min_ost' then begin
    if S.NNum(Fr.GetValue('aprc_min_ost')) <> FPrcMinOst then
      Params.Font.Color := clBlue;
  end;
  if FieldName = 'prc_need_m' then begin
    if S.NNum(Fr.GetValue('aprc_need_m')) <> FPrcNeedM then
      Params.Font.Color := clBlue;
  end;
  if FieldName = 'need' then begin
    if S.NNum(Fr.GetValue('need')) < 0 then
      Params.Background := clmyGray;
  end;
  if FieldName = 'need_p' then begin
    if S.NNum(Fr.GetValue('need_p')) < 0 then
      Params.Background := clmyGray;
  end;
  if FieldName = 'need_m' then begin
{    if MemTableEh1.FieldByName('prc_need_m').AsFloat <= -MemTableEh1.FieldByName('aprc_need_m').AsFloat then
      Background := RGB(255, 180, 180)  //розовый
    else if MemTableEh1.FieldByName('prc_need_m').AsFloat >= +MemTableEh1.FieldByName('aprc_need_m').AsFloat then
      Background := RGB(255, 255, 100)  //желтый
    else if MemTableEh1.FieldByName('need_m').AsFloat < 0 then
      Background := RGB(200, 200, 200);}
    if S.NNum(Fr.GetValue('need_m')) < 0 then
      Params.Background := clmyGray;
  end;
  if FieldName = 'qnt' then begin
    if (S.NNum(Fr.GetValue('qnt0')) > 0) and (S.NNum(Fr.GetValue('prc_qnt')) <= S.NNum(Fr.GetValue('aprc_qnt'))) then
      Params.Background :=clMyPink;
  end;
  if FieldName = 'qnt_onway' then begin
    //подсветим ячейку "в пути", если задан кастомный период для этих данных
    if FCustomOnWay[0] = 1 then
      Params.Font.Color := clBlue;
    if (S.NNum(Fr.GetValue('onway_old')) = 1) then
      Params.Background :=clMyPink;  //розовый
  end;
  if FieldName = 'price_main' then begin
    //подсветим последнюю цену основного поставщика, если рублевая часть отличается хотя бы на рубль, соотвественно зеленым или розовым
    if not ((Fr.GetValue('price_main') = null) or (Fr.GetValue('price_check') = null)) then begin
      if Trunc(S.NNum(Fr.GetValue('price_main'))) < Trunc(S.NNum(Fr.GetValue('price_check')))
        then Params.Background := clmyGreen;  //зеленоватый
      if Trunc(S.NNum(Fr.GetValue('price_main'))) > Trunc(S.NNum(Fr.GetValue('price_check')))
        then Params.Background := clmyPink;  //розовый
    end;
  end;
  if (Length(FRowColors) > 0) and (Frg1.MemTableEh1.Active) and (Frg1.MemTableEh1.RecordCount > 0) and (Frg1.MemTableEh1.RecNo = Frg1.DbGridEh1.Row) then begin
    FRowColors[TColumnEh(Sender).Index] := Params.BackGround;
    FRowFontColors[TColumnEh(Sender).Index] := Params.Font.Color;
//    SetDetailInfo;
    //это вызывает внутреннюю ошибку в объектах при вызове MemTable.Refresh в родительском классе!!!
//    ChangeSelectedData;
  end;
end;

procedure TFrmOGedtSnMain.Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
var
  va: TVarDynArray;
  i: Integer;
  st: string;
  AddParamD: Variant;
  AddParamAr: tVarDynArray;
  rx1: TRegEx;
begin
  inherited;
  if A.PosInArray(Fr.CurrField, ['prc_qnt', 'prc_min_ost', 'prc_need_m']) >= 0 then begin
      if TFrmBasicInput.ShowDialog(Self, '', [], fEdit, '', 180, 80,
          [[cntNEdit, '% выделения', '1:100:N', 80]],
          [Fr.GetValue('a'+Fr.CurrField)], va,
          [['Процент предупреждения по даннной номенклатуре.'#13#10'Чтобы использовать процент по умолчанию, задайте пустое значение.']],
           nil
        ) < 0 then Exit;
    Q.QExecSql('insert into spl_itm_nom_props (id) select :id1$i from dual where not exists (select null from spl_itm_nom_props where id = :id2$i)', [Fr.ID, Fr.ID]);    Q.QExecSql('update spl_itm_nom_props set ' + Fr.CurrField + '=:prc$i where id = :id$i', [va[0], id]);
    Fr.RefreshRecord;
  end;
  AddParamAr:= [Fr.GetValueS('name'), Fr.GetValueS('name_unit')];
  AddParamD:= VararrayOf(AddParamAr);
  if Fr.CurrField = 'supplierinfo' then begin
    Wh.ExecDialog(myfrm_Dlg_SupplierMinPart, Self, [myfoModal, myfoSizeable], S.IIf(User.Role(rOr_Other_R_MinRemains_Ch_Suppl), fEdit, fView), Fr.ID, AddParamD);
    Fr.RefreshRecord;
  end;
  if Fr.CurrField = 'qnt_order_opt' then begin
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_MinPart, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, AddParamD);
  end;
  if Fr.CurrField = 'rezerv' then begin
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_Rezerv, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, AddParamD);
  end;
  if Fr.CurrField = 'qnt' then begin
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_QntOnStore, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, AddParamD);
  end;
  if Fr.CurrField = 'qnt_onway' then begin
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_OnWay, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, AddParamD);
  end;
  if Fr.CurrField = 'qnt_in_processing' then begin
//    Info_QntInProccessing;
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_OnDemand, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, AddParamD);
  end;
  if Fr.CurrField = 'price_main' then begin
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_InBillList, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, AddParamD);
  end;
  if Fr.CurrField = 'order_cost' then begin
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_SpSchetList, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, AddParamD);
  end;
  if Fr.CurrField = 'name' then begin
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_MoveNomencl, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, AddParamD);
  end;
  if TRegEx.IsMatch(Fr.CurrField, '^qnt[0-9]{1}$') then begin
    AddParamD:= VararrayOf(AddParamAr + [FDays[StrtoInt(Fr.CurrField[4])]]);
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_Consumption, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, AddParamD);
  end;
  if TRegEx.IsMatch(Fr.CurrField, '^qnti[0-9]{1}$') then begin
    AddParamD:= VararrayOf(AddParamAr + [FDays[StrtoInt(Fr.CurrField[5])]]);
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_Incoming, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, AddParamD);
  end;
  if TRegEx.IsMatch(Fr.CurrField, '^qnt_pl[1-3]{1}$') then begin
    AddParamD[1] := -S.NNum(Copy(Fr.CurrField, 7, 1));
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_PlannedOrders, [myfoModal, myfoSizeable, myfoDialog], fView, Fr.ID, AddParamD);
  end;
  if Fr.CurrField = 'has_files' then begin
    TFrmODedtNomenclFiles.ShowDialog(Self, Fr.ID);
  end;
end;

procedure TFrmOGedtSnMain.Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
  //разрешим для записей в выбранной сейчас категории
  //кроме этого, разрешим изменение категории для всех записей снабжению
  //разрешим изменение категории записей, для которых она пустая или своя, всем остальным
  //(проверка, что неьзя поставить пустую категорию, производится в онапдейтдата)
  //разрешим изменение любой ячейки в изменяемом столбце администратору после подтверждения
//exit;
  if Fr.CurrField = 'price_check' then
  else if Fr.CurrField = 'id_category'
    then ReadOnly := not (FIsSnab or (A.PosInArray(Fr.GetValue('id_category'), FCategoryesSelf + [['', null]], 1) >= 0))
    else ReadOnly := (Length(FCategoryesSelf) = 0) or (not FAdminEditMode and
      not (Fr.GetValue('id_category') = Cth.GetControlValue(Fr, 'CbCategory')));
end;

procedure TFrmOGedtSnMain.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
  SetDetailInfo;
end;

procedure TFrmOGedtSnMain.Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  Fr.SetSqlParameters('id$i', [Frg1.ID]);
end;


{END события грида}


procedure TFrmOGedtSnMain.SetCategoryes;
var
  i: Integer;
begin
  FCategoryes:=Q.QLoadToVarDynArray2('select name, id, useravail from spl_categoryes order by name', []);
  FCategoryesSelf:=[];
  for i:=0 to High(FCategoryes) do
    if S.InCommaStr(IntToStr(User.GetId), FCategoryes[i, 2]) then begin
      FCategoryesSelf:=FCategoryesSelf +[ [FCategoryes[i][0], FCategoryes[i][1]]];
      if FCategoryes[i][1] = 1 then FIsSnab:= True;
    end;
  Cth.AddToComboBoxEh(TDBComboBoxEh(Frg1.FindComponent('CbCategory')), FCategoryesSelf);
  TDBComboBoxEh(Frg1.FindComponent('CbCategory')).ItemIndex:=0;
  if not FIsSnab then begin
    TDBCheckBoxEh(Frg1.FindComponent('ChbCatAll')).Checked:=False;
    TDBCheckBoxEh(Frg1.FindComponent('ChbCatAll')).Visible:=False;
  end
  else TDBComboBoxEh(Frg1.FindComponent('CbCategory')).Value:='1';
  Frg1.Opt.SetPick('id_category', A.VarDynArray2ColToVD1(FCategoryes, 0), A.VarDynArray2ColToVD1(FCategoryes, 1), True);
end;

procedure TFrmOGedtSnMain.SetFieldsEditable;
//изменяемые поля если есть права на изменение
begin
  Frg1.Opt.SetColFeature('3', 'e', User.Roles([], [rOr_Other_R_MinRemains_Ch]) and not FLockEdit, False);
  Frg1.Opt.SetColFeature('price_check', 'e', User.Roles([], [rOr_Other_R_MinRemains_ChPriceCheck]) and not FLockEdit, False);
  Frg1.Opt.SetColFeature('id_category', 'e', User.Roles([], [rOr_Other_R_MinRemains_Ch]), False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtGo, null, not FLockEdit);
  Frg1.DBGridEh1.Repaint;
end;

procedure TFrmOGedtSnMain.EditSettings;
var
  i, j: Integer;
  va1, va2: TVarDynArray;
  b: Boolean;
begin
  va1 := copy(FDays);
  for i := 0 to High(va1) do
    if va1[i] < 0 then
      va1[i] := 0;
  repeat
    if TFrmBasicInput.ShowDialog(Self, '', [], fAdd, '', 180, 80,
      [[cntNEdit, 'Оценка', '1:10000', 80], [cntNEdit, 'Период 1', '0:10000', 80], [cntNEdit, 'Период 2', '0:10000', 80], [cntNEdit, 'Период 3', '0:10000', 80],
       [cntNEdit, 'Период 4', '0:10000', 80], [cntNEdit, 'Период 5', '0:10000', 80], [cntNEdit, 'Период 6', '0:10000', 80]],
       va1, va2,
       [['Задайте период оценки и периоды просмотра расхода/прихода (в днях). Если поставить 0, то данный период отображаться не будет.']], nil
    ) < 0 then Exit;
    b := True;
    for i := 1 to High(va2) do
      if va2[i] > 0 then
        b := False;
    if not b then
      Break;
    va1 := Copy(va2);
    MyWarningMessage('Должен быть задан хотя бы один период!');
  until False;
  va1 := Copy(va2, 1);
  for i := 0 to High(va1) do
    if va1[i] = 0 then
      va1[i] := 100000;
  a.VarDynArraySort(va1, True);
  for i := 0 to High(va1) do
    if va1[i] = 100000 then
      va1[i] := -100;
  FDays := [va2[0]] + va1;
  Q.QExecSql('update spl_minremains_params set d0=:d0$i,d1=:d1$i,d2=:d2$i,d3=:d3$i,d4=:d4$i,d5=:d5$i,d6=:d6$i', [va2[0]] + va1);
//  SetCaptions;
//  Gh.SetGridColumnsProperty(DBGridEh1, cptCaption, Pr[1].Fields, Pr[1].Captions);
  Frg1.RefreshGrid;
end;

procedure TFrmOGedtSnMain.SetCategory;
//выбор и установка категории для всех отмеченных чекбоксами позиций
//категория выбирается из списка своих (а также может быть пустая)
//будут заменены или очищены только те позиции, категория которых является своей, или пустая
var
  va2: TVarDynArray2;
  va, vak, vav: TVarDynArray;
  i, j: Integer;
  fcat: Integer;
  cat, catn: Variant;
  catname: string;
begin
(*
//  if not FIsSnab then Exit; //пока запретим устанвливать всем, кроме снабжения!!!
  //получим массив отмеченных записей
  va2:= Gh.GetGridArrayOfChecked(DbGridEh1, -1);
  //сообщим и выйдем, если нет отмеченных
  if (Length(va2) = 0) then begin
    MyInfoMessage('Отметьте записи, для которых вы хотите установить категорию.');
    Exit;
  end;
  fcat:=MemTableEh1.FieldByName('id_category').Index;
  //массивы наименований и ключей своих категорий для диалога
  vak:=['']; vav:=[''];
  for i:=0 to High(FCategoryesSelf) do begin
    vak:= vak + [FCategoryesSelf[i][1]];
    vav:= vav + [FCategoryesSelf[i][0]];
  end;
  //диалог
  if TFrmBasicInput.ShowDialog(Self, '', [], fEdit, 'Установить категорию', 300, 80,
//  if Dlg_BasicInput.ShowDialog(Self, 'Установить категорию', 300, 80, fEdit,
    [[cntComboLK, 'Категория', '0:200:0:n', 210]],
    [VarArrayOf([vak[0], VarArrayOf(vav), VarArrayOf(vak)])],
    va,
    [['Установить или очистить категорию по выбранным позициям. Только свои категории могут быть изменены или очищены.']],
    nil
  ) < 0 then Exit; //выйдем, если отмена
  //получим название и айди выбранной категории
  cat:=va[0];
  catname:=''; if cat <> '' then begin
    i:= A.PosInArray(cat, FCategoryes, 1);
    if i >=0 then catname:= FCategoryes[i, 0];
  end;
  if (Length(va2) = 0)or(MyQuestionMessage('Установить для ' + S.GetEndingFull(Length(va2), 'наименовани', 'я', 'й', 'й') + ' категорию "' + catname + '"?') <> mrYes)
    then Exit;
  //зададим категорию
  for i:=0 to High(va2) do begin
    //только если категория пустая или своя, и не такая же
    va:=Q.QSelectOneRow('select id, id_category from spl_itm_nom_props where id = :id$i', [va2[i][0]]);
    if (va[0] <> null)and(VarToStr(va[1]) <> VarToStr(cat))and((va[1] = null)or(A.PosInArray(va[1], FCategoryesSelf, 1) >= 0))
      then Q.QCallStoredProc('p_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([va2[i, 0], 6, S.NullIfEmpty(cat)]));
  end;
  //снимем отметку
  Gh.SetGridIndicatorSelection(DbGridEh1, -1);
  //обновим
  Refresh;
  MyInfoMessage('Готово!');
  *)
end;

function TFrmOGedtSnMain.ExportGridToXLSX(Open: Boolean = False; OnlyNot0: Boolean = False): Boolean;
//формировапние выгрузки таблицы в эксель
//требуется, т.к. стандартная выгрузка EhLib выгружает некорректно
//(выгружает, но при открытии в эксель находит неверное содержисое в какой-то строке в поле Наименование, узнать это никак, а содержимео не восттанавливается и вообще оказывается пустым)
//выгрузка по шаблону, заголовок статичный в шаблоне, поля находятся по соответствию полям датасета
var
  Rep: TA7Rep;
  Range: Variant;
  i, j, k, x, y: Integer;
  v: Variant;
  FileName: string;
  b: Boolean;
  va: TVarDynArray;
  st, st1: string;
  RecNo: Integer;
begin
  Result := False;
  //откроем шаблон
  FileName := Module.GetReportFileXlsx('Формирование заявок СН');
  if FileName = '' then
    Exit;
  Rep := TA7Rep.Create;
  try
    Rep.OpenTemplate(FileName, False, True);
  except
    Rep.Free;
    Exit;
  end;
  //заголовок
  Rep.PasteBand('HEADER');
  //установим текст в заголовке документа - наименование формы с датой создания
  Rep.ExcelFind('#' + 'caption' + '#', x, y, xlValues);
  if x > -1 then
    Rep.SetValue('#' + Self.Caption + '  [' + DateTimeToStr(Now) + ']' + '#', st1);
  //Rep.PasteBand('EMPTY');
  //обработка тела таблицы

  //не отключаем контролы при проходе по мемтебл - у нас в событии грида сохраняются цвета ячеек текущей сроки, будем их использовать
  //MemTableEh1.DisableControls;
  RecNo := Frg1.MemTableEh1.RecNo;
  //в шаблоне метки соответствуют полям таблицы, кроме позиции #pos#
  for i := 1 to Frg1.MemTableEh1.RecordCount do begin
    Frg1.MemTableEh1.RecNo := i;
    Rep.PasteBand('TABLE');
    Rep.SetValue('#pos#', IntToStr(i));
    //проход по полям датасета
    for j := 0 to Frg1.MemTableEh1.Fields.count - 1 do begin
      //для таблицы - значение метки и поля
      st := Frg1.MemTableEh1.Fields[j].FieldName;
      st1 := S.NSt(Frg1.MemTableEh1.Fields[j].AsString);
      //найдем метку в шаблоне, соответствующую имени поля, и если ее нет - пропустим итерацию
      Rep.ExcelFind('#' + st + '#', x, y, xlValues);
      if x = -1 then  Continue;
      //значение поля
      Rep.SetValue('#' + st + '#', st1);
      //установим цвет фона из сохраненных в событии грида, если он не цвет четной строки (их почему-то закрышивает черным)
      if not VarIsEmpty(FRowColors[Frg1.DBGridEh1.FindFieldColumn(st).Index])
        then if FRowColors[Frg1.DBGridEh1.FindFieldColumn(st).Index] <> Frg1.DBGridEh1.EvenRowColor
          then Rep.TemplateSheet.Cells[y, x].Interior.Color := FRowColors[Frg1.DBGridEh1.FindFieldColumn(st).Index];
      //и установим цвет шрифта - дает возможность отображать метки
      if not VarIsEmpty(FRowFontColors[Frg1.DBGridEh1.FindFieldColumn(st).Index])
        then Rep.TemplateSheet.Cells[y, x].Font.Color := FRowFontColors[Frg1.DBGridEh1.FindFieldColumn(st).Index];
    end;
  end;
  //вернемся к исходной строке таблицы
  Frg1.MemTableEh1.RecNo := RecNo;
  Frg1.MemTableEh1.EnableControls;
  //футер таблицы
  Rep.PasteBand('FOOTER');
  //закрепим области. если это сделать в шаблоне, то по какой-то причине закрепляется последняя строка данных,
  //хотя в шаблоне все работает, и после закрепленной строки сделан промуск (бенд EMPTY), чтобы не копировалось при вставке.
  // снимаем закрепление области, если оно было задано
  Rep.Excel.ActiveWindow.FreezePanes:=False;
  // выделяем нужную ячейку, ПЕРЕД строкой которой будет закрепление, строки тут как в эксель с единицы
  Rep.Excel.Range['A3'].Select;
  // устанавливаем закрепление области
  Rep.Excel.ActiveWindow.FreezePanes:=True;
  //установим автофильтр. если он был в шаблоне, то не сохранится при вставуке бенда, поэтому в коде
  //нельзя поставить стобец А, потому что в этой ячейке первая и вторая строка объединены, и в этом случае при указании A2 фильтр все равно появится в первой строке
  //передевать надо диапозон по столбцам с буквы до буквы, а строку в обоих ячейках - ту, в которой должен быть расположен фильтр (с единицы)
  Rep.Excel.Range['A2', 'Z2'].AutoFilter;
  Rep.DeleteCol1;
  if Open then begin
    Rep.Show;
    Rep.Free;
    Result := True;
  end
  else begin
    try
      //Использовать именно .Save, а не .SaveAs !
      ForceDirectories(Module.GetPath_Demand_Created);
      Rep.Save(Module.GetPath_Demand_Created +'\' + FormatDateTime('yyyy-mm-dd_hh.nn.ss', Now) + '__(' + User.GetName + ')' + '.xlsx');
      Result := True;
    except
    end;
  end;
end;

procedure TFrmOGedtSnMain.RecalcPlannedEst;
//пересчитать плановую потребноть (по данным плановых заказов на три месяца вперед, включая текущий)
begin
  if MyQuestionMessage('Плановая потребность рассчитана на ' + DateTimeToStr(FPlannedDt) + #13#10'Обновить?') <> mrYes then
    Exit;
  Orders.CrealeEstimateOnPlannesOrders(Now, True);
  FPlannedDt:=Q.QLoadToVarDynArrayOneRow('select planned_dt from spl_minremains_params', [])[0];
  Frg1.RefreshGrid;
end;

procedure TFrmOGedtSnMain.InfoOnTheQntInProccessing;
//информация по номенклатуре В Обработке
begin
  MyInfoMessage(
    'Ининформация по позициям "В обработке"'#13#10#13#10+
    'Количество, на которые созданы заявки на снабжение, за минусом полученного по накладным и за минусом товара "В пути"'#13#10+
    ''#13#10+
    'Запрошено по заявкам: ' + VarToStr(Q.QselectOneRow('select qnt from v_spl_nom_on_demand where id_nomencl = :id$i', [Frg1.ID])[0]) + #13#10+
    'Получено по накладным: ' + VarToStr(Q.QselectOneRow('select qnt from v_spl_nom_on_inbill where id_nomencl = :id$i', [Frg1.ID])[0]) + #13#10+
    'В пути: ' + VarToStr(Q.QselectOneRow('select qnt from v_spl_nom_onway_agg where id_nomencl = :id$i', [Frg1.ID])[0]) + #13#10 +
    ''#13#10+
    'Итого: ' + S.NSt(Frg1.GetValue('qnt_in_processing'))
  );
end;

procedure TFrmOGedtSnMain.SetLock;
//возьмем блокировку на редактирование таблицы по выбранной категории
//если успех, то разрешим редактирование данных и создание заявки, иначе запретим (кроме столбца категории)
var
  va, va1: TVarDynArray;
  i, j: Integer;
  st, st1: string;
  v: Variant;
begin
  //выйдем, если нет прав на редактирвоание, также и если не назначены категории (либо комбобокс очищен, т.е. категория не выбрана)
  if not (User.Roles([], [rOr_Other_R_MinRemains_Ch]) and (S.NSt(Frg1.GetControlValue('CbCategory')) <> ''))
    then Exit;
  //очистим блокировку на прошлую выбранную категорию
  va1:=Q.DBLock(False, FormDoc, VarToStr(FIdCategoryLock), '', fNone);
  //попытаемся взять блокировку
  va1:=Q.DBLock(True, FormDoc, VarToStr(Frg1.GetControlValue('CbCategory')), '', fNone);
  //сохраним категорию которую выбрали
  FIdCategoryLock:= Frg1.GetControlValue('CbCategory');
  //признка, что редактирование заблокировано
  FLockEdit:= not va1[0];
  if FLockEdit then begin
    //если заблокировано, то выдадим сообщение
    MyWarningMessage('Пользователь "' + S.NSt(va1[1]) + '" сейчас редактирует таблицу по данной категории.'#13#10'Вы не можете редактировать данные и формировать заявку!');
  end;
  //изменим список редактируемых полей (в случае блокровки, добави к ним спереди "_", а иначе - восстановим как были
  SetFieldsEditable;
end;

procedure TFrmOGedtSnMain.tmrAfterCreateTimer(Sender: TObject);
begin
  inherited;
  SetLock;
end;

procedure TFrmOGedtSnMain.ViewXLSFiles;
//просмотр сохраненных xls-файлов из каталога данных Учета, которые сохраняются при создании заявки автоматически
//файлы сохранены с именами по ддате/времени, в формате ексель.
//процедура выводит окно со списком файлов, и открывает выбранный файл
var
  sa: TStringDynArray;
  va1, va2: TVarDynArray;
  i: Integer;
begin
  sa := TDirectory.GetFiles(Module.GetPath_Demand_Created, '*.*', TSearchOption.soTopDirectoryOnly);
  for i:=0 to High(sa) do
    sa[i]:=ExtractFileName(sa[i]);
  va1:= A.StringDynArrayToVarDynArray(sa);
  A.VarDynArraySort(va1, False);
      if TFrmBasicInput.ShowDialog(Self, '', [], fEdit, '', 600, 50,
        [[cntComboL, 'Файл:', '1:4000', 540]],
        [VarArrayOf(['', VarArrayOf(va1)])],
        va2,
        [['Просмотреть данные в формате Excel на момент создания заявки.'#13#10]],
         nil
      ) <= 0 then Exit;
  Sys.ExecFileIfExists(Module.GetPath_Demand_Created + '\' + VarToStr(va2[0]), 'Файл не найден!');
end;


function TFrmOGedtSnMain.CreateDemand: Boolean;
//создадим заявку на снабжение
//заявка создается только по позициям, для которых категория соответствует текущей
//перед созданием возможно сохранение всей таблицы (со снятым фильтром) в экселе в специальном каталоге
//в заявку выгрузятся только позиции по текущей категории, для которых задана и не нулевое количество к заказу и стоит галка В заказ
var
  i, j, ToDemand: Integer;
  idd, res: Integer;
  gf: TVarDynArray2;
  id_category: Integer;
  va2: TVarDynArray2;
  st: string;
begin
  //получим айди категории
  id_category:= Frg1.GetControlValue('CbCategory');
  //количество, которое попадет в заявку
  ToDemand := Q.QSelectOneRow('select count(*) from spl_itm_nom_props where nvl(qnt_order, 0) > 0 and to_order = 1 and id_category = :id_category$i', [id_category])[0];
  //если ничего нет, то выйдем
  if ToDemand = 0 then begin
    MyInfoMessage('Нет ни одной позиции к заказу!');
    Result := False;
    Exit;
  end;
  va2 := Q.QLoadToVarDynArray2(
    'select v.name, v.need from v_spl_minremains v, spl_itm_nom_props p where v.id = p.id and nvl(v.need, 0) < 0 and p.to_order <> 1 and p.id_category = :id_category$i',
    [id_category]
  );
  if Length(va2) > 0 then begin
    st := 'Не отмечены к заказу следующие (' + IntToStr(Length(va2)) + ') позиции с потребностью:'#13#10;
    for i := 0 to High(va2) do
      S.ConcatStP(st, va2[i][0] + '  [' + VarToStr(va2[i][1]) + ']', #13#10);
    st := st + #13#10#13#10'Продолжить формирование заявки?';
    if MyQuestionMessage(st, 1) <> mrYes then
      Exit;
  end;
  //переспросим
  if MyQuestionMessage(
    'Создать заявку на снабжение из ' + S.GetEndingFull(ToDemand, 'позици', 'и', 'й', 'й') + ' по категории "' +
    A.FindValueInArray2(id_category, 1, 0, FCategoryes) + '"?'
    ) <> mrYes then  Exit;
  //спросим, сохранить ли в экселе
  if MyQuestionMessage('Сохранить текущее состояние данных в Excel-файле?') = mrYes then begin
    //сохраним и очистим фильтр в столбцах и строке
    gf := Gh.GridFilterSave(Frg1.DbGridEh1);
    Gh.GridFilterClear(Frg1.DbGridEh1);
    //экспорт в эксель (с сохранением фона ячеек, но по шаблону), выгрузка автоматом в каталог в Data, без предпросмотра
    ExportGridToXLSX(False);
    //восстановим фильтр
    Gh.GridFilterRestore(Frg1.DbGridEh1, gf);
  end;
  //вызовем процедуру формирования заявки поставщику по переданной категории
  Q.QBeginTrans(True);
  Q.QCallStoredProc('p_Spl_Create_History', 'st$s', ['Заказ']);
  Q.QCallStoredProc('p_CreateSplDemand', 'IdCategory$i', [id_category]);
  Q.QCommitOrRollback();
  //если завершилось неудачно, сообщим и выйдем
  if Q.PackageMode <> 1 then begin
    MyWarningMessage('Ошибка создания заявки!');
    Exit;
  end;
  //удача - сообщим и обновим грид
  Frg1.RefreshGrid;
  MyInfoMessage('Заявка создана.');
end;

procedure TFrmOGedtSnMain.FillFromPlanned;
//устанавливает поля "Партия (ввод)" и "Минимальный остаток" равными плановой потребности за выбранный месяц
var
  va, van, vaid: TVarDynArray;
  va2: TVarDynArray2;
  i: Integer;
begin
  //диалог выбора месяца
  van := [MonthsRu[MonthOf(FPlannedDt)], MonthsRu[MonthOf(IncMonth(FPlannedDt, 1))], MonthsRu[MonthOf(IncMonth(FPlannedDt, 2))]];
  vaid := [1,2,3];
  if TFrmBasicInput.ShowDialog(Self, '', [], fAdd, '~Выбор периода', 160, 45,
    [[cntComboLK, 'Месяц:','1:50', 1]],
    [VarArrayOf(['', VarArrayOf(van), VarArrayOf(vaid)])],
    va,
    [],
    nil
  ) < 0 then
    Exit;
  //спросим
  if MyQuestionMessage(
    'Партия и Минимальный остаток будут заполнены исходя из значений плановой потребности за ' + van[S.NInt(va[0]) - 1] + #13#10'Продолжить?'
  ) <> mrYes then
    Exit;
  //получим непустые (но нулевые установим!) плановые потребности за этот месяц
  va2 := Q.QLoadToVarDynArray2('select id_nomencl, qnt' + va[0] + ' from planned_order_estimate3 where id_nomencl is not null and qnt' + va[0] + ' is not null', []);
  //пройдем пор полученному массиву и установим целевые значения (окрушляем до десятых)
  Q.QBeginTrans(True);
  for i := 0 to High(va2) do begin
    Q.QCallStoredProc('p_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([va2[i][0], 2, S.NullIfEmpty(RoundTo(va2[i][1], -1))]));     //min_ostatok
    Q.QCallStoredProc('p_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([va2[i][0], 3, S.NullIfEmpty(RoundTo(va2[i][1], -1))]));     //qnt_order_opt
  end;
  Q.QCommitOrRollback(True);
  //обновим грид
  Frg1.RefreshGrid;
  MyInfoMessage('Готово!');
end;

procedure TFrmOGedtSnMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //очистим блокировку на прошлую выбранную категорию
  Q.DBLock(False, FormDoc, VarToStr(FIdCategoryLock), '', fNone);
  inherited;
end;

procedure TFrmOGedtSnMain.SetDetailInfo;
var
  i, j: Integer;
  f: string;
begin
  if Frg1.IsEmpty then
    Exit;
  if Frg1.MemTableEh1.ControlsDisabled then
    Exit;
  if not Frg1.MemTableEh1.Active or (Frg1.GetCount < 1) then
    lblName.SetCaption2('')
  else
    lblName.SetCaption2('Наименование: $FF0000 ' + Frg1.GetValueS('name'));
  Frg3.MemTableEh1.Edit;
  for i := 0 to Frg3.MemTableEh1.Fields.Count - 1 do begin
    f := Frg3.MemTableEh1.Fields[i].FieldName;
    Frg3.MemTableEh1.Fields[i].Value := null;
//    if not MemTableEh1.Active or (MemTableEh1.RecordCount < 1) then Continue;
    if Frg1.DbGridEh1.FindFieldColumn(f) = nil then
      Continue;
    Frg3.MemTableEh1.Fields[i].Value := Frg1.MemTableEh1.FieldByName(f).Value;
    if (Length(FRowColors) > 0) and (not VarIsEmpty(FRowColors[Frg1.DBGridEh1.FindFieldColumn(f).Index])) then
      Frg3.DBGridEh1.FindFieldColumn(f).Color := FRowColors[Frg1.DBGridEh1.FindFieldColumn(f).Index];
    if TRegEx.IsMatch(f, 'price_main') then
      Frg3.DBGridEh1.FindFieldColumn(f).Color := RGB(150, 150, 255);
    if TRegEx.IsMatch(f, '_cost$') then
      Frg3.DBGridEh1.FindFieldColumn(f).Color := RGB(150, 150, 255);
    if TRegEx.IsMatch(f, '^qnt[0-9]{1}$') then
      Frg3.DBGridEh1.FindFieldColumn(f).Color := RGB(255, 255, 150);
    if TRegEx.IsMatch(f, '^qnti[0-9]{1}$') then
      Frg3.DBGridEh1.FindFieldColumn(f).Color := RGB(150, 255, 150);
  end;
end;

procedure TFrmOGedtSnMain.ClearInvalidReserve;
var
  va: TVarDynArray;
  i: Integer;
begin
  i := Q.QSelectOneRow('select count(*) from v_reservpos_completed_orders2', [])[0];
  if i = 0 then begin
    MyInfoMessage('Нет подвисших резервов.');
    Exit;
  end;
  va := Q.QLoadToVarDynArrayOneCol('select info from v_reservpos_completed_orders2', []);
  if MyQuestionMessage('В резерве зависли следующие (' + IntToStr(i) + ') позиции по закрытым в Учете заказам:'#13#10+
    '(Нажмите "Да" чтобы очистить резервы)'#13#10 + A.Implode(va, #13#10), 1) <> mrYes then
    Exit;
  Q.QBeginTrans(True);
  Q.QCallStoredProc('p_Itm_DelRezervForCompleted', '', []);
  Q.QCommitOrRollback(True);
  Frg1.RefreshGrid;
end;







end.
