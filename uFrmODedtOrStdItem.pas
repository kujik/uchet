{
Редактирование стандартного изделия.
В дополнительном параметре всегда передается айди сметной группы (id_or_format_estimates).
Редактировать цену можно только обладая правом на это.
}


unit uFrmODedtOrStdItem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFields, uFrmBasicDbDialog,
  Vcl.Mask
  ;

type
  //одна вкладка синхронизации парных изделий (произв./отгруз.) - см. общий комментарий к LoadCounterpartTabs.
  //FTabs[0] - всегда само редактируемое/добавляемое изделие (своя TTabSheet создается наравне с остальными -
  //см. LoadCounterpartTabs, иначе индексы FTabs и pgcFormat.Pages расходятся), FTabs[1..] - парные подгруппы
  //(тот же id_format, тот же sync_group, противоположный тип О/П). SyncChecked/NotCreateChecked - состояние
  //чекбоксов "Синхронизировать"/"Не создавать" для вкладки; сами чекбоксы общие на форму (chb_TabSync/
  //chb_TabNotCreate под pgcFormat), а не по одному на вкладку - см. SetTabsControlsState/ChbSyncClick.
  TCounterpartTab = record
    IdOrFormatEstimate: Variant;
    ItemType: Integer;
    Sheet: TTabSheet;
    SyncChecked: Boolean;
    NotCreateChecked: Boolean;
    //массив уже существующих изделий этой подгруппы (or_std_items.id_or_format_estimates = IdOrFormatEstimate),
    //предзагруженный ОДИН РАЗ при построении вкладки (см. LoadCounterpartTabs/LoadExistingNamesForTab) - чтобы
    //проверка "такое наименование уже есть" по мере ввода в edt_name (см. CheckNameDuplicates) не дёргала БД на
    //каждое нажатие клавиши, а искала в уже загруженном в память списке. Столбцы (см. LoadExistingNamesForTab):
    //[0]=наименование, [1]=id, [2..]=price_base/wo_estimate/r0/r1..rN - строго тем же полям и в том же порядке,
    //что и FSyncFields (см. общий комментарий там же). Собственная запись редактируемого изделия (ID) в выборку
    //не включается (она не может быть "дубликатом самой себя").
    ExistingNames: TVarDynArray2;
    //найдено ли ПРЯМО СЕЙЧАС (по текущему тексту edt_name) совпадение среди ExistingNames этой вкладки, и
    //индекс найденной строки (используются в pgcFormatDrawTab - маркер+цвет на заголовке вкладки - и в
    //CheckNameDuplicates/ApplyExistingItemToTabSlot - подстановка данных найденного изделия в поля вкладки)
    DuplicateFound: Boolean;
    DuplicateRow: Integer;
  end;

  TFrmODedtOrStdItem = class(TFrmBasicDbDialog)
    pgcFormat: TPageControl;
    cmb_id_or_format_estimates: TDBComboBoxEh;
    edt_prefix: TDBEditEh;
    edt_name: TDBEditEh;
    chb_R0: TDBCheckBoxEh;
    chb_Wo_Estimate: TDBCheckBoxEh;
    nedt_price_base: TDBNumberEditEh;
    chb_by_sgp: TDBCheckBoxEh;
    bvlTabSync: TBevel;
    chb_TabSync: TCheckBox;
    chb_TabNotCreate: TCheckBox;
    lblSemiproductErrors: TLabel;
    btn_TabCopyRoute: TButton;
    procedure lblSemiproductErrorsClick(Sender: TObject);
  private
    FRcount: Integer;
    FNameOld : string;
    FWoEstimateOld: Integer;
    FIdEstimateGroup: Variant;
    FPrefix: string ;
    FIsRouteChanged: Boolean;
    FIdOrFormatEstimate: Variant;
    //режим вызова диалога, AddParam[1] - см. общий комментарий в начале Prepare (VarArrayOf([IdOrFormatEstimate,
    //CallMode]) или VarArrayOf([IdOrFormatEstimate, CallMode, DefaultName]) - см. также FCallMode = 4 ниже):
    //1 - обычный вызов из справочника (uFrmOGrefOrStdItems), 2 - только добавление с выбором подгруппы по
    //прежней (ограниченной по группе/типу) логике, 3 - только добавление с выбором ЛЮБОЙ активной подгруппы
    //любой активной группы, любого типа изделий (см. LoadCbFormatEstimates), 4 - только добавление, подгруппу
    //можно выбрать из ЛЮБОЙ активной подгруппы ПОЛУФАБРИКАТОВ (тип фиксирован, но без привязки к конкретной
    //группе форматов) - используется для вызова "Создать полуфабрикат" из диалога сметы (см. общий комментарий
    //в CreateSemiproductFromRow, uFrmOGedtEstimate.pas)
    FCallMode: Integer;
    //наименование по умолчанию - необязательный третий элемент AddParam (см. общий комментарий у FCallMode) -
    //подставляется в поле "Наименование" при добавлении (Mode = fAdd), пользователь может его изменить; для
    //старых вызовов (AddParam из двух элементов) остается пустым - см. разбор в начале Prepare
    FDefaultName: string;
    //группа (id_format) и тип (см. STDITEM_TYPE_* в uOrders) переданной (исходной) подгруппы - см. LoadCbFormatEstimates
    FIdFormat: Variant;
    FItemType: Integer;
    //вкладки синхронизации парных изделий (см. TCounterpartTab) и текущая активная вкладка (индекс в FTabs)
    FTabs: array of TCounterpartTab;
    FActiveTab: Integer;
    //список полей (через ;), которые копируются между вкладками при синхронизации - см. SwitchToTab;
    //наименование (синхронизируется всегда, отдельно) и by_sgp (никогда не синхронизируется) сюда не входят
    FSyncFields: string;
    //признак чекбокса "Создать одно"/"Редактировать одно" в левой панели кнопок - см. ChbOneOnlyClick
    FOneOnly: Boolean;
    //признак, что первоначальное автовыравнивание/подгонка размеров формы (CorrectFormSize, вызывается один раз
    //из FormShow) уже произошла - пока False, SetTabsControlsState НЕ трогает видимость bvlTabSync/chb_TabSync/
    //chb_TabNotCreate/btn_TabCopyRoute (кроме случая полного отсутствия вкладок - см. там же), чтобы на момент
    //авторасчета высоты формы (Cth.AlignControls в uForms.pas) эти контролы посчитались как обычные видимые и
    //под них было зарезервировано место - иначе (см. подробный комментарий у TFrmBasicMdi.CorrectFormSize)
    //авторасчет полностью проигнорирует их (место не резервируется под изначально невидимые контролы), и при
    //первом же переключении на парную вкладку они окажутся ниже реально показанной высоты панели - формально
    //Visible = True, но невидимы, пока пользователь не растянет форму вручную. Взводится в AfterFormActivate
    //(гарантированно после CorrectFormSize) - см. там же.
    FTabsVisReady: Boolean;
    //id подгрупп (FTabs[1..].IdOrFormatEstimate), временно добавленных в список cmb_id_or_format_estimates
    //только для отображения на парных вкладках (см. SyncFormatComboWithTabs) - обычный список комбобокса
    //(LoadCbFormatEstimates) строится только по подгруппам ТОГО ЖЕ типа, что исходная (FItemType), а парные
    //вкладки всегда ПРОТИВОПОЛОЖНОГО типа, поэтому их подгрупп там нет и без явного добавления значение поля
    //Формат на этих вкладках отображалось бы пустым (см. SwitchToTab). Список нужен, чтобы при повторном вызове
    //LoadCounterpartTabs (смена подгруппы на 0-й вкладке в режиме добавления/копирования - см. ControlOnChange)
    //можно было снять ранее добавленные записи и не копить дубликаты.
    FComboAppendedIds: TVarDynArray;
    //текст для окна по клику на lblSemiproductErrors (заполняется в UpdateSemiproductErrorsLabel) - объединяет
    //и блокирующие, и предупреждающие конфликты имени (см. CheckSemiproductNameConflicts), т.к. здесь это уже
    //просто информация по СУЩЕСТВУЮЩЕЙ записи, а не гейт перед сохранением
    FSemiproductErrorsText: string;
    function  Prepare: Boolean; override;
    procedure AfterFormActivate; override;
    procedure ControlOnChange(Sender: TObject); override;
    function  VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean; override;
    //заполняет комбобокс Формат по правилам, зависящим от типа исходной подгруппы (FItemType) - см. реализацию
    procedure LoadCbFormatEstimates;
    //обновляет FPrefix и поле "Префикс" по текущему значению, выбранному в комбобоксе Формат
    procedure SetPrefixByFormat;
    //пересоздает вкладки парных изделий (FTabs[1..]) по коду синхронизации (or_format_estimates.sync_group)
    procedure LoadCounterpartTabs;
    //дополняет список cmb_id_or_format_estimates подгруппами парных вкладок FTabs[1..] (только для отображения,
    //выбрать их вручную нельзя - см. общий комментарий у FComboAppendedIds); вызывается из LoadCounterpartTabs
    procedure SyncFormatComboWithTabs;
    procedure pgcFormatChange(Sender: TObject);
    procedure pgcFormatDrawTab(Control: TCustomTabControl; TabIndex: Integer; const Rect: TRect; Active: Boolean);
    //переключение общих контролов (FSyncFields) на данные другой вкладки - см. реализацию
    procedure SwitchToTab(ANewIndex: Integer);
    procedure ChbSyncClick(Sender: TObject);
    procedure ChbNotCreateClick(Sender: TObject);
    procedure BtnCopyRouteClick(Sender: TObject);
    procedure ChbOneOnlyClick(Sender: TObject);
    //блокировка/разблокировка общих полей в зависимости от активной вкладки и ее состояния синхронизации
    procedure SetTabsControlsState;
    //предзагружает ATab.ExistingNames - см. общий комментарий у TCounterpartTab.ExistingNames; вызывается из
    //LoadCounterpartTabs для каждой вкладки (включая FTabs[0]) сразу при её построении
    procedure LoadExistingNamesForTab(var ATab: TCounterpartTab);
    //ищет AName (уже нормализованное - UpperCase(Trim(...))) среди ATab.ExistingNames; -1, если не найдено
    function  FindExistingNameRow(const ATab: TCounterpartTab; const AName: string): Integer;
    //живая (без обращения к БД) проверка совпадения текущего edt_name с уже существующими изделиями по каждой
    //вкладке - см. подробный комментарий у реализации; вызывается из VerifyAdd на каждое изменение любого поля
    procedure CheckNameDuplicates;
    //подставляет в поля вкладки ATabIndex (через её слот fvtCustom, см. общий комментарий в SwitchToTab) данные
    //найденного изделия (строка ARow в ExistingNames этой вкладки) и снимает синхронизацию на этой вкладке -
    //см. подробный комментарий у реализации
    procedure ApplyExistingItemToTabSlot(ATabIndex, ARow: Integer);
    //обратное действие ApplyExistingItemToTabSlot - совпадение по имени на вкладке ATabIndex пропало,
    //возвращаем синхронизацию по умолчанию (True)
    procedure ResetTabSlotSync(ATabIndex: Integer);
    //показывает/прячет чекбокс "Создать одно"/"Редактировать одно" по текущему FItemType (не для полуфабрикатов) -
    //отдельным методом, а не только в Prepare, т.к. тип может смениться уже после Prepare, если пользователь
    //выбирает другую подгруппу в комбобоксе Формат (актуально для CallMode = 3, см. ControlOnChange)
    procedure UpdateChbOneOnlyVisible;
    //проверяет состояние сметы ОТГРУЗОЧНОГО изделия (см. общий комментарий у реализации/у CreateSelfSmeta про
    //смену модели - смета создается для отгрузочных изделий и ссылается на производственное, а не наоборот).
    //AIdShipmentItem - id отгрузочного изделия, для которого проверяется смета (Null, если оно еще не
    //сохранено - новое). AIdProductionItem - id (уже сохраненного к этому моменту) производственного изделия,
    //на которое должна ссылаться единственная позиция сметы. Возвращает 0 (ничего не требуется), 1 (требуется
    //создание), 2 (смета уже есть, но отличается - только предупреждаем, не трогаем); ADetails - текст для
    //диалога подтверждения/предупреждения
    function CheckSelfSmetaAction(AIdShipmentItem, AIdProductionItem: Variant; const AShipmentDisplayName, AProductionPrefixedName: string; out ADetails: string): Integer;
    //создает смету отгрузочного изделия (см. CheckSelfSmetaAction) через Orders.ApplyEstimateArray - единственная
    //позиция ссылается на производственное изделие (по имени через bcad_nomencl И по id через id_or_std_item).
    //ВАЖНО: открывает и коммитит/откатывает СВОЮ отдельную транзакцию (см. TOrders.ApplyEstimateArray) - вызывать
    //только ПОСЛЕ фиксации (Q.QCommitTrans) собственной транзакции сохранения изделий, см. комментарий в Save
    procedure CreateSelfSmeta(AIdShipmentItem, AIdProductionItem: Variant; const AProductionPrefixedName: string);
    //должна ли вкладка ATabIndex вообще сохраняться - см. подробности у реализации (учитывает "Только одно" и
    //"Не создавать")
    function ShouldSaveTab(ATabIndex: Integer): Boolean;
    //нужна ли вкладке ATabIndex (>0), которая ShouldSaveTab, РЕАЛЬНАЯ запись в БД - см. подробности у
    //реализации; отличает "нечего менять у уже существующего парного изделия" (синхронизация выключена,
    //пользователь ничего на этой вкладке не трогал) от настоящего создания/изменения
    function CounterpartTabNeedsSave(ATabIndex: Integer): Boolean;
    //разрешает текущее (на момент вызова, с учетом активной вкладки/синхронизации) значение поля AField
    //(без суффикса типа - см. соглашение FSyncFields) для вкладки ATabIndex - см. подробности у реализации
    function GetTabFieldValue(ATabIndex: Integer; const AField: string): Variant;
    //наименование с префиксом подгруппы AIdOrFormatEstimate (см. также FPrefix/SetPrefixByFormat - для 0-й
    //вкладки то же самое можно получить как FPrefix + '_' + editable-имя, но для других вкладок префикс свой)
    function GetPrefixedName(AIdOrFormatEstimate: Variant; const AName: string): string;
    //переименовывает полное (с префиксом подгруппы) наименование в ИТМ (dv.nomenclatura) и bcad_nomencl - общим
    //методом для 0-й И любой парной вкладки (см. подробности у реализации)
    procedure RenameNomenclatura(AIdOrFormatEstimate: Variant; const AOldName, ANewName: string; AItemType: Integer);
    //текст для диалога подтверждения, ЗАРАНЕЕ предсказывающий, что сделает RenameNomenclatura (см. подробности
    //у реализации) - той же логикой, без изменений в БД
    function GetNomenclaturaRenamePlanText(AIdOrFormatEstimate: Variant; const AOldName, ANewName: string; AItemType: Integer): string;
    //id уже существующего (до сохранения) изделия вкладки ATabIndex - см. подробности у реализации
    function GetTabExistingId(ATabIndex: Integer): Variant;
    //мандатная (обязательная для каждого сохраняемого изделия, см. общий комментарий в VerifyBeforeSave)
    //проверка в БД, не занято ли имя (простое/с префиксом) каким-то ДРУГИМ изделием - используется как для 0-й,
    //так и для остальных сохраняемых вкладок
    function CheckDuplicateNameInDb(AIdOrFormatEstimate, AExcludeId: Variant; const AName, APrefixedName: string; out AMsg: string): Boolean;
    //только для полуфабрикатов (см. общий комментарий у реализации и переписку с пользователем) - проверка
    //"голого" (без префикса) имени AName на конфликты ЗА ПРЕДЕЛАМИ своей подгруппы: с другими подгруппами
    //полуфабрикатов/нестандартными изделиями и с полным/голым именем стандартных изделий. Result = False, если
    //найден блокирующий конфликт (AErrorMsg заполнен) - сохранение недопустимо. AWarningMsg заполняется
    //отдельно и НЕ блокирует сохранение (см. п.3 в реализации).
    function CheckSemiproductNameConflicts(AExcludeId: Variant; const AName: string; out AErrorMsg, AWarningMsg: string): Boolean;
    //для полуфабрикатов в режиме fView/fEdit - прогоняет CheckSemiproductNameConflicts по уже сохраненному
    //имени (ID/FNameOld) и показывает/прячет lblSemiproductErrors по результату (см. общее требование
    //пользователя - переписка: "получить сразу же" красный подчеркнутый лейбл при просмотре/редактировании).
    //Вызывается из AfterFormActivate (один раз при показе формы).
    procedure UpdateSemiproductErrorsLabel;
    //сохраняет изделие парной вкладки ATabIndex (>0) - см. подробности у реализации. Возвращает id
    //сохраненного/созданного изделия, либо Null при ошибке сохранения (для этого случая - ошибка уже показана
    //пользователем внутри Q.QSave/QExecSql, ShowError по умолчанию True)
    function SaveCounterpartTab(ATabIndex: Integer): Variant;
    //синхронизирует цену/маршрут в шаблонах заказов (order_items с псевдо-id_order) для изделия AId вкладки
    //ATabIndex - вынесено в общий метод (было только для 0-й вкладки) - см. подробности у реализации
    procedure SyncOrderItemTemplates(ATabIndex: Integer; AId: Variant);
  protected
    procedure VerifyBeforeSave; override;
    function  Save: Boolean; override;
    procedure SetRoute;
  public
  end;

var
  FrmODedtOrStdItem: TFrmODedtOrStdItem;

implementation

 uses
   uOrders
   ;

 {$R *.dfm}

const
  //группа "Готовые изделия" и единица измерения "шт." в bcad_groups/bcad_units (d_estimates.sql) - используются
  //при автосоздании "самосметы" производственного изделия, см. CheckSelfSmetaAction/CreateSelfSmeta
  BCAD_GROUP_FINISHED_ITEMS = 104;
  BCAD_UNIT_PCS = 1;

function TFrmODedtOrStdItem.Prepare: Boolean;
var
  i, j: Integer;
  va: TVarDynArray;
  va1, va2: TVarDynArray2;
begin
  Result := False;
  Caption:='Стандартное изделие';

  //айди переданной (исходной) подгруппы и режим вызова диалога - см. общий комментарий вверху модуля.
  //AddParam теперь VarArrayOf([IdOrFormatEstimate, CallMode]) - см. также объявление FCallMode:
  //  CallMode = 1 - обычный вызов из справочника (uFrmOGrefOrStdItems) или на просмотр (uFrmOGedtEstimate) -
  //    вся прежняя логика без изменений;
  //  CallMode = 2 - вызов ТОЛЬКО на добавление (например, из диалога сметы) - подгруппа выбирается в комбобоксе
  //    Формат по прежней, ограниченной по группе форматов/типу логике (как и раньше при добавлении);
  //  CallMode = 3 - вызов только на добавление, но подгруппу можно выбрать из ЛЮБОЙ активной подгруппы любой
  //    активной группы форматов, любого типа изделий (не только совпадающего с переданной) - см.
  //    LoadCbFormatEstimates. Переданная подгруппа (AddParam[0]) в этом случае может быть Null - тогда в
  //    комбобоксе изначально просто ничего не выбрано.
  //Для CallMode 2 и 3 принудительно выставляем Mode := fAdd, чтобы не ошибиться, если вызывающий код передал
  //что-то другое - режимы добавления по смыслу и не предполагают ничего, кроме добавления.
  FIdOrFormatEstimate := AddParam[0];
  FCallMode := S.NInt(AddParam[1]);
  //необязательный третий элемент AddParam - наименование по умолчанию (см. общий комментарий у FCallMode/
  //FDefaultName) - используется ниже, после inherited, и только для Mode = fAdd
  FDefaultName := '';
  if VarIsArray(AddParam) and (VarArrayHighBound(AddParam, 1) >= 2) then
    FDefaultName := VarToStr(AddParam[2]);
  if FCallMode in [2, 3, 4] then
    Mode := fAdd;

  //НОВОЕ (см. задачу пользователя - "переделать вызов диалога без справочника, чтобы открывался на
  //редактирование/просмотр так же, по переданному айди изделия"): при вызове НЕ из справочника
  //(uFrmOGrefOrStdItems), где исходная подгруппа заведомо не известна вызывающему коду (передан Null/0) и
  //известен только сам AId (например, целлбаттон "И" в диалоге сметы - см. Frg1CellButtonClick,
  //uFrmOGedtEstimate.pas) - подгруппу резолвим сами, простым запросом по AId. Делаем это ДО построения
  //комбобокса "Формат" (LoadCbFormatEstimates) и до inherited - см. комментарий чуть ниже про то, почему
  //список комбобокса должен быть построен заранее.
  if (Mode in [fEdit, fView, fDelete]) and (S.NNum(FIdOrFormatEstimate) <= 0) and (S.NNum(ID) > 0) then
    FIdOrFormatEstimate := Q.QLoadValue('select id_or_format_estimates from or_std_items where id = :id$i', [ID]);

  //группа форматов (id_format) и тип (О/П/ПФ) исходной подгруппы нужны для формирования списка комбобокса
  //Формат (см. LoadCbFormatEstimates); делаем это до вызова inherited, т.к. в режиме редактирования inherited
  //сразу загружает из БД и устанавливает в комбобокс текущее значение поля id_or_format_estimates, а список
  //комбобокса должен быть заполнен заранее, иначе значение не отобразится.
  //Для CallMode = 3 переданная подгруппа может отсутствовать (Null/0) - тогда группу/тип изначально не знаем,
  //определятся уже по факту выбора пользователем в комбобоксе (см. ControlOnChange); до этого момента считаем
  //тип "неизвестным" (не полуфабрикатом, чтобы не спрятать чекбокс "Создать одно" раньше времени - см. ниже).
  if S.NNum(FIdOrFormatEstimate) > 0 then begin
    va := Q.QLoadRow('select id_format, type from or_format_estimates where id = :id$i', [FIdOrFormatEstimate]);
    FIdFormat := va[0];
    FItemType := S.NInt(va[1]);
  end
  else begin
    FIdFormat := Null;
    FItemType := -1;
  end;
  LoadCbFormatEstimates;
  //поле Формат доступно для выбора только при добавлении/копировании - см. LoadCbFormatEstimates (в остальных
  //режимах в списке остается только одна, текущая строка, и поле недоступно)
  cmb_id_or_format_estimates.Enabled := Mode in [fAdd, fCopy];

  //чекбокс "Создать одно"/"Редактировать одно" - в левой панели кнопок; полностью отключает вкладки парных
  //изделий (см. ChbOneOnlyClick); не показывается для полуфабрикатов (для них вкладок нет вообще) и в
  //режиме просмотра/удаления (там нечего создавать/менять). Создаём его здесь один раз (если режим вообще
  //допускает), а видимость по типу подгруппы обновляем отдельно (UpdateChbOneOnlyVisible) - тип подгруппы может
  //поменяться уже после Prepare, если пользователь выбирает другую подгруппу в комбобоксе (актуально для
  //CallMode = 3, где в комбобоксе вперемешку подгруппы всех типов, включая полуфабрикаты - см. ControlOnChange).
  FOneOnly := False;
  if not (Mode in [fView, fDelete]) then begin
    //ВАЖНО: текст подписи специально короткий и ОДИНАКОВЫЙ для режимов "создать"/"редактировать" ("Только
    //одно", а не "Создать одно"/"Редактировать одно") - в стандартную ширину чекбокса по умолчанию (см.
    //CreateControls, uForms.pas) не помещался более длинный вариант текста, а автоподгонка ширины под текст
    //(Cth.AutoSizeCheckBoxes ниже) для TDBCheckBoxEh на практике не работает (проверено - см. TODO ниже,
    //разбор отложен) - поэтому пока обходим проблему коротким текстом вместо борьбы с шириной контрола.
    Cth.CreateControls(pnlFrmBtnsL, cntCheck, 'Только одно', 'chb_OneOnly', '', 0, 4, 4);
    TDBCheckBoxEh(Self.FindComponent('chb_OneOnly')).OnClick := ChbOneOnlyClick;
    //ВАЖНО: сбрасываем кеш порядка контролов панели (InvalidatePanelOrder) сразу после динамического создания
    //chb_OneOnly, ДО первого же ArrangeControlsOnPanel для этой панели. Причина: GetPanelOrder (uFrmBasicMdi.pas)
    //кеширует список контролов панели один раз при первом обращении (например, ещё в конструкторе/при более
    //раннем ArrangeControlsOnPanel), и если это произошло раньше, чем создан chb_OneOnly, кеш навсегда останется
    //без него - тогда ни один последующий пересчёт ширины панели (в т.ч. ниже, в UpdateChbOneOnlyVisible) не
    //учтёт чекбокс. Актуально не только для широкого варианта текста - оставляем на будущее.
    InvalidatePanelOrder(pnlFrmBtnsL);
    //TODO: подгонка ширины chb_OneOnly под текст (Cth.AutoSizeCheckBoxes) на практике не работает для
    //TDBCheckBoxEh - см. TODO-список в конце модуля (после end.) с планом на будущее. Пока не убираем вызов -
    //вреда не приносит, при коротком тексте "Только одно" ширины по умолчанию (см. CreateControls) хватает.
    Cth.AutoSizeCheckBoxes(pnlFrmBtnsL, [], [], ['chb_OneOnly'], []);
  end;
  //видимость (по типу подгруппы) и раскладка панели - см. подробный комментарий в UpdateChbOneOnlyVisible про
  //CorrectFormSize и ширину панели (актуально в т.ч. когда чекбокс выше вообще не создавался - тогда просто выйдет)
  UpdateChbOneOnlyVisible;

  //вкладки парных изделий (произв./отгруз.) - см. LoadCounterpartTabs; при просмотре/удалении показываем
  //ридонли (сами блокировки полей обеспечит общий механизм диалога для этих режимов).
  //OnClick общих контролов синхронизации назначаем здесь, кодом, а не через .dfm - методы приватные, и при
  //потоковой загрузке формы (DFM streaming) Delphi не резолвит приватные методы в OnClick ("invalid property
  //value" при открытии формы) - см. также chb_OneOnly ниже, тот же паттерн.
  pgcFormat.OwnerDraw := True;
  pgcFormat.OnDrawTab := pgcFormatDrawTab;
  chb_TabSync.OnClick := ChbSyncClick;
  chb_TabNotCreate.OnClick := ChbNotCreateClick;
  btn_TabCopyRoute.OnClick := BtnCopyRouteClick;
  FActiveTab := 0;
  LoadCounterpartTabs;

  for i := 0 to High(RouteFields) do begin
    Cth.CreateControls(pnlFrmClient, cntCheck, RouteFields[i], 'chb_r' + IntToStr(i + 1), '', 0, edt_name.Left + i * 50, edt_name.Top + edt_name.Height + MY_FORMPRM_H_EDGES);
    TDBCheckBoxEh(Self.FindComponent('chb_r' + IntToStr(i + 1))).Caption := RouteFields[i];
    va2 :=  va2 + [['r' + IntToStr(i + 1) + '$i']];
  end;

  //список полей, синхронизируемых между вкладками (наименование - отдельно, всегда; by_sgp - никогда, см. SwitchToTab)
  FSyncFields := 'price_base;wo_estimate;r0';
  for i := 0 to High(RouteFields) do
    FSyncFields := FSyncFields + ';r' + IntToStr(i + 1);

  F.DefineFields:=[
    ['id$i'],
    ['name$s','V=1:400::T'],
    ['price_base$f','V=0:9999999:2:n'],
    ['wo_estimate$i'],
    ['r0$i'],
    ['by_sgp$i'],
    ['id_or_format_estimates$i','V=1:400:1']
  ] + va2;

  View := 'v_or_std_items';
  Table := 'or_std_items';
  FOpt.UseChbNoClose:= True;
  //Opt.RequestWhereClose:= cqYNC;
  //подсказки пользователю (иконка Info) - разные тексты для разных режимов вызова диалога (см. общую задачу
  //пользователя - "напиши подсказку для пользователей для каждого режима"). Формат - см. общий комментарий у
  //TMDIOpt.InfoArray (uFrmBasicMdi.pas) и TControlsHelper.SetInfoIconText (uForms.pas): [[текст, показывать ли
  //(True/False)], ...] - элемент без второго значения показывается всегда; здесь у каждого элемента есть
  //условие показа, поэтому "всегда видимых" элементов нет. FItemType на этом месте (до inherited) уже
  //корректно определен для fEdit/fView/fDelete (см. блок резолвинга FIdOrFormatEstimate по AId чуть выше) и
  //для "обычного" добавления с уже переданной исходной подгруппой (CallMode 1/2); для CallMode 3/4 (подгруппа
  //изначально не выбрана) остается неизвестным (-1) до первого выбора в комбобоксе "Формат" - см. ControlOnChange.
  FOpt.InfoArray := [
    ['Ввод параметров нового стандартного изделия.'#13#10 +
     'Введите все необходимые данные и нажмите "Сохранить" - изделие появится в справочнике стандартных'#13#10 +
     'изделий. Если такое наименование (с учетом префикса подгруппы) уже занято другим изделием, сохранение'#13#10 +
     'будет заблокировано с соответствующим сообщением.'#13#10,
     (Mode in [fAdd, fCopy]) and (FCallMode <> 4)],
    ['Изменение параметров стандартного изделия.'#13#10 +
     'Измените необходимые данные и нажмите "Сохранить".'#13#10 +
     'При изменении наименования оно будет автоматически изменено во всех изделиях Учета и ИТМ'#13#10 +
     '(но если такое наименование уже используется как позиция в смете, то там оно изменено не будет!).'#13#10 +
     'При изменении маршрута или цен по изделию, они будут скорректированы во всех шаблонах паспортов заказов.'#13#10,
     Mode = fEdit],
    ['Вы просматриваете данные изделия. Изменение значений недоступно - для редактирования закройте это'#13#10 +
     'окно и откройте изделие заново на изменение.'#13#10,
     Mode = fView],
    ['Добавление ПОЛУФАБРИКАТА, вызванное из диалога сметы (кнопка "Создать полуфабрикат" в столбце'#13#10 +
     '"Наименование" грида сметных позиций). Наименование уже подставлено по тому, что было введено'#13#10 +
     'в строке сметы - при необходимости его можно изменить прямо здесь.'#13#10 +
     'Выберите подгруппу полуфабриката в поле "Формат" - доступна ЛЮБАЯ активная подгруппа полуфабрикатов,'#13#10 +
     'а не только та, что относится к текущей смете.'#13#10 +
     'Наименование (без учета регистра, БЕЗ ПРЕФИКСА подгруппы) должно быть уникальным среди ВСЕХ'#13#10 +
     'полуфабрикатов (любых подгрупп) и нестандартных изделий - при совпадении сохранение будет заблокировано.'#13#10 +
     'Совпадение с ПОЛНЫМ (с префиксом подгруппы) наименованием любого стандартного (производственного или'#13#10 +
     'отгрузочного) изделия - также ошибка, сохранение заблокировано. Совпадение с "голым" (без префикса)'#13#10 +
     'наименованием стандартного изделия - только предупреждение, сохранить в этом случае можно.'#13#10,
     FCallMode = 4],
    ['Если наименование полуфабриката (без учета регистра, без префикса) совпадает с наименованием другого'#13#10 +
     'полуфабриката, нестандартного или стандартного изделия, об этом сообщит красная подчеркнутая надпись'#13#10 +
     '"Есть ошибки!" под полем "Наименование" - нажмите на нее, чтобы увидеть подробности.'#13#10,
     (FItemType = STDITEM_TYPE_SEMIPRODUCT) and (Mode in [fView, fEdit])],
    ['Если для этой подгруппы настроена парная подгруппа противоположного типа (произв./отгруз.) в той же'#13#10 +
     'группе форматов, наверху появляются дополнительные вкладки - по одной на каждое связанное изделие.'#13#10 +
     'Совпадение по наименованию с уже существующим изделием парной подгруппы - вкладка заполняется его'#13#10 +
     'данными (отмечается точкой), иначе будет создано новое парное изделие.'#13#10 +
     'Галка "Синхронизировать" - цена и маршрут повторяют первую вкладку и недоступны для правки; снимите,'#13#10 +
     'если изделие должно отличаться. "Не создавать" - изделие этой вкладки не создается/не меняется вовсе.'#13#10 +
     'Кнопка "Скопировать маршрут" разово переносит цену/маршрут с первой вкладки. Галка "Создать одно"/'#13#10 +
     '"Редактировать одно" скрывает все парные вкладки - работа идет только с текущим изделием.'#13#10 +
     'При сохранении отгрузочного изделия в паре с производственным, если у отгрузочного еще нет сметы, она'#13#10 +
     'создается автоматически - из одной позиции со ссылкой на связанное производственное изделие.'#13#10,
     (FItemType <> STDITEM_TYPE_SEMIPRODUCT) and (Mode <> fDelete)]
  ];

  FWHBounds.Y2 := -1;
  Result := inherited;
  if not Result then
    Exit;
  if Mode <> fDelete then begin
    FNameOld := S.NSt(F.GetPropB('name'));
    FWoEstimateOld:=S.NInt(F.GetPropB('wo_estimate'));
    //AddParam теперь массив (см. общий комментарий в начале Prepare) - берём уже разобранное значение группы
    FIdEstimateGroup := FIdOrFormatEstimate;
    F.SetProp('id_or_format_estimates$i',FIdOrFormatEstimate);
    //FPrefix/FIdEstimateGroup - см. SetPrefixByFormat; вызывается и здесь (для начального значения), и из
    //ControlOnChange при смене выбора в комбобоксе Формат (актуально в режиме добавления/копирования)
    SetPrefixByFormat;
    //наименование по умолчанию (см. общий комментарий у FCallMode/FDefaultName) - только при добавлении
    if (Mode = fAdd) and (FDefaultName <> '') then
      F.SetProp('name$s', FDefaultName);
  end;
  if (Mode = fEdit) and not User.Role(rOr_R_StdItems_Set_Prices) then begin
    nedt_price_base.ReadOnly := True;
    //nedt_Price_PP.ReadOnly := True;
  end;
  SetRoute;
  //обработчик переключения вкладок подключаем только теперь, когда F полностью готов (иначе сработает уже
  //при создании самих TTabSheet в LoadCounterpartTabs, до готовности полей)
  pgcFormat.OnChange := pgcFormatChange;
  SetTabsControlsState;
end;

procedure TFrmODedtOrStdItem.ControlOnChange(Sender: TObject);
var
  va: TVarDynArray;
begin
  if (A.InArray(TControl(Sender).Name, ['chb_R0', 'chb_Wo_Estimate'])) or (Copy(TControl(Sender).Name, 1, 5) = 'chb_r') then
    SetRoute;
  if TControl(Sender).Name = 'cmb_id_or_format_estimates' then begin
    SetPrefixByFormat;
    //подгруппа сменилась (возможно только в режиме добавления/копирования - в остальных комбобокс задизейблен) -
    //пересчитаем состав вкладок парных изделий по новой подгруппе (у нее может быть другой id_format/sync_group)
    FIdOrFormatEstimate := Cth.GetControlValue(cmb_id_or_format_estimates);
    va := Q.QLoadRow('select id_format, type from or_format_estimates where id = :id$i', [FIdOrFormatEstimate]);
    FIdFormat := va[0];
    FItemType := S.NInt(va[1]);
    FActiveTab := 0;
    LoadCounterpartTabs;
    SetTabsControlsState;
    //тип выбранной подгруппы мог смениться (актуально для CallMode = 3, где в комбобоксе вперемешку подгруппы
    //всех типов, включая полуфабрикаты) - обновляем видимость чекбокса "Создать одно" под новый тип
    UpdateChbOneOnlyVisible;
  end;
  inherited;
end;

procedure TFrmODedtOrStdItem.LoadCbFormatEstimates;
//заполняет cmb_id_or_format_estimates (комбобокс Формат):
//- при CallMode = 3 (см. общий комментарий в Prepare) - вообще без ограничений: все активные подгруппы всех
//  активных групп, любого типа изделий (произв./отгруз./ПФ вперемешку) - используется при вызове диалога только
//  на добавление откуда угодно (не из справочника), когда исходная подгруппа не важна или вовсе не задана;
//- при CallMode = 4 (см. общий комментарий в Prepare) - все активные подгруппы ВСЕХ групп форматов, но ТОЛЬКО
//  типа "полуфабрикат" - используется для "Создать полуфабрикат" из диалога сметы, где исходная подгруппа не
//  передается вовсе (FIdOrFormatEstimate = Null/0), а FItemType поэтому еще не известен (не может быть =
//  STDITEM_TYPE_SEMIPRODUCT, как в ветке ниже) - тот же результат, что и следующая ветка, но не зависящий от
//  FItemType;
//- иначе (CallMode 1/2), если исходная подгруппа - полуфабрикат (STDITEM_TYPE_SEMIPRODUCT) - все подгруппы всех
//  групп с типом "полуфабрикат", при этом подгруппы, принадлежащие текущей группе (FIdFormat), идут сразу за
//  верхней строкой;
//- иначе (отгрузочное/производственное) - только подгруппы той же группы форматов (того же id_format, FIdFormat)
//  и того же типа.
//самая верхняя строка списка - всегда исходная подгруппа (FIdOrFormatEstimate), см. decode(e.id, ..., 0, 1) -
//если она не задана (Null/0, допустимо при CallMode = 3 и 4), верхняя строка ничем не выделяется, список идет в
//обычном алфавитном порядке (decode с NULL-параметром ни с одной реальной e.id не совпадёт).
//в режиме, отличном от добавления/копирования, в списке остается только эта одна (верхняя) строка -
//см. cmb_id_or_format_estimates.Enabled в Prepare
var
  i: Integer;
begin
  if FCallMode = 3 then
    Q.QLoadToDBComboBoxEh(
      'select f.name || '' ['' || e.name || '']'' as estimate, e.id as id ' +
      'from or_formats f, or_format_estimates e ' +
      'where e.id_format = f.id and (e.active = 1 or e.id = :idsel1$i) ' +
      'order by decode(e.id, :idsel2$i, 0, 1), f.name, e.name',
      [FIdOrFormatEstimate, FIdOrFormatEstimate],
      cmb_id_or_format_estimates, cntComboLK
    )
  else if FCallMode = 4 then
    Q.QLoadToDBComboBoxEh(
      'select f.name || '' ['' || e.name || '']'' as estimate, e.id as id ' +
      'from or_formats f, or_format_estimates e ' +
      'where e.id_format = f.id and e.type = :type1$i and (e.active = 1 or e.id = :idsel1$i) ' +
      'order by decode(e.id, :idsel2$i, 0, 1), f.name, e.name',
      [STDITEM_TYPE_SEMIPRODUCT, FIdOrFormatEstimate, FIdOrFormatEstimate],
      cmb_id_or_format_estimates, cntComboLK
    )
  else if FItemType = STDITEM_TYPE_SEMIPRODUCT then
    Q.QLoadToDBComboBoxEh(
      'select f.name || '' ['' || e.name || '']'' as estimate, e.id as id ' +
      'from or_formats f, or_format_estimates e ' +
      'where e.id_format = f.id and e.type = :type1$i and (e.active = 1 or e.id = :idsel1$i) ' +
      'order by decode(e.id, :idsel2$i, 0, 1), decode(e.id_format, :idformat1$i, 0, 1), f.name, e.name',
      [STDITEM_TYPE_SEMIPRODUCT, FIdOrFormatEstimate, FIdOrFormatEstimate, FIdFormat],
      cmb_id_or_format_estimates, cntComboLK
    )
  else
    Q.QLoadToDBComboBoxEh(
      'select f.name || '' ['' || e.name || '']'' as estimate, e.id as id ' +
      'from or_formats f, or_format_estimates e ' +
      'where e.id_format = f.id and e.id_format = :idformat1$i and e.type = :type1$i and (e.active = 1 or e.id = :idsel1$i) ' +
      'order by decode(e.id, :idsel2$i, 0, 1), f.name, e.name',
      [FIdFormat, FItemType, FIdOrFormatEstimate, FIdOrFormatEstimate],
      cmb_id_or_format_estimates, cntComboLK
    );
  if not (Mode in [fAdd, fCopy]) then
    //вне добавления/копирования подгруппа изделия уже определена и не должна меняться - оставим только
    //верхнюю (см. order by выше - это всегда исходная подгруппа) строку списка
    for i := cmb_id_or_format_estimates.Items.Count - 1 downto 1 do begin
      cmb_id_or_format_estimates.Items.Delete(i);
      cmb_id_or_format_estimates.KeyItems.Delete(i);
    end;
end;

procedure TFrmODedtOrStdItem.SetPrefixByFormat;
//обновляет FPrefix/FIdEstimateGroup и отображаемое поле "Префикс" по подгруппе, выбранной в данный момент
//в комбобоксе Формат (FIdEstimateGroup используется далее в VerifyBeforeSave/Save для проверки уникальности
//наименования и синхронизации переименования с ИТМ - см. эти процедуры)
var
  LId: Variant;
begin
  LId := Cth.GetControlValue(cmb_id_or_format_estimates);
  FIdEstimateGroup := LId;
  if S.NNum(LId) > 0 then
    FPrefix := Q.QLoadValue('select prefix from or_format_estimates where id = :id$i', [LId]).AsString
  else
    FPrefix := '';
  edt_prefix.Text := FPrefix;
end;

procedure TFrmODedtOrStdItem.LoadCounterpartTabs;
//пересоздает вкладки парных изделий - подгруппы того же id_format (FIdFormat), того же кода синхронизации
//(or_format_estimates.sync_group), что и у исходной подгруппы (FIdOrFormatEstimate), и ПРОТИВОПОЛОЖНОГО типа
//О/П (произв./отгруз.); sync_group = 0 у исходной подгруппы означает, что синхронизация для нее не предлагается
//вообще (вкладок не будет); учитываются только активные (active=1) подгруппы. Полуфабрикаты (тип
//STDITEM_TYPE_SEMIPRODUCT) в парах никогда не участвуют - ни как исходная подгруппа (тогда вкладок нет вообще,
//см. проверку FItemType ниже), ни как кандидат в пару (см. "and e.type <> :tsp$i" в запросе) - у них своя,
//отдельная логика (см. общий комментарий по ПФ), даже если по ошибке/по умолчанию у них тот же sync_group.
//
//TTabSheet создается для КАЖДОГО элемента FTabs, включая FTabs[0] (само редактируемое/добавляемое изделие) -
//это важно, чтобы pgcFormat.Pages[i] всегда 1-в-1 соответствовал FTabs[i] (иначе переключение вкладок съезжает
//на один индекс - см. pgcFormatChange/SwitchToTab). "Содержимое" любой вкладки - это общие поля формы
//(edt_name/nedt_price_base/маршрут и т.д.), всегда видимые под pgcFormat и переключаемые между вкладками -
//см. SwitchToTab, где объясняется сам механизм. Чекбоксы "Синхронизировать"/"Не создавать" и кнопка копирования
//маршрута - тоже общие на форму (chb_TabSync/chb_TabNotCreate/btn_TabCopyRoute под pgcFormat), не по одному на
//вкладку - см. SetTabsControlsState.
//
//Если пары не нашлось - вкладок не создается вообще (в т.ч. и для FTabs[0]) - pgcFormat остается пуст и скрыт.
//
//Вызывается из Prepare, а также повторно из ControlOnChange при смене выбора в комбобоксе Формат (только в
//режиме добавления/копирования - см. там же).
var
  i: Integer;
  va2: TVarDynArray2;
  LSyncGroup: Variant;
  LSheet: TTabSheet;
  LCapt0: string;
begin
  while pgcFormat.PageCount > 0 do
    pgcFormat.Pages[0].Free;
  SetLength(FTabs, 1);
  FTabs[0].IdOrFormatEstimate := FIdOrFormatEstimate;
  FTabs[0].ItemType := FItemType;
  FTabs[0].Sheet := nil;
  FTabs[0].DuplicateFound := False;
  FTabs[0].DuplicateRow := -1;
  //предзагрузка списка существующих изделий своей же подгруппы - нужна независимо от наличия парных вкладок
  //(см. CheckNameDuplicates - подсветка edt_name при добавлении, если наименование уже занято в этой подгруппе)
  LoadExistingNamesForTab(FTabs[0]);

  if FItemType <> STDITEM_TYPE_SEMIPRODUCT then begin
    LSyncGroup := Q.QLoadValue('select sync_group from or_format_estimates where id = :id$i', [FIdOrFormatEstimate]);
    if S.NNum(LSyncGroup) > 0 then
      va2 := Q.QLoad(
        'select e.id, e.type, f.name || '' ['' || e.name || '']'' as capt ' +
        'from or_formats f, or_format_estimates e ' +
        'where e.id_format = f.id and e.id_format = :idf$i and e.active = 1 and e.sync_group = :sg$i ' +
        'and e.type <> :t$i and e.type <> :tsp$i ' +
        'order by e.type, capt',
        [FIdFormat, LSyncGroup, FItemType, STDITEM_TYPE_SEMIPRODUCT]
      );
  end;

  if Length(va2) > 0 then begin
    //своя вкладка (FTabs[0]) - см. общий комментарий выше
    LCapt0 := VarToStr(Q.QLoadValue(
      'select f.name || '' ['' || e.name || '']'' from or_formats f, or_format_estimates e ' +
      'where e.id_format = f.id and e.id = :id$i',
      [FIdOrFormatEstimate]
    ));
    LSheet := TTabSheet.Create(Self);
    LSheet.PageControl := pgcFormat;
    //3 пробела спереди - зарезервированное место под маркер совпадения (см. pgcFormatDrawTab/CheckNameDuplicates).
    //Ширина таба, которую реально выделяет Windows/VCL под кнопку вкладки, считается ОДИН РАЗ по этой, статической
    //Caption - то, что рисуется в OnDrawTab (pgcFormatDrawTab), на эту ширину уже не влияет. Если добавлять
    //маркер только при обнаружении (меняя длину текста), текст вылезает за пределы уже отведенной под таб
    //области и не стирается корректно при снятии маркера, пока не перерисуется соседняя вкладка. Поэтому длину
    //Caption фиксируем сразу, а маркер потом только подменяет первый символ на месте (см. pgcFormatDrawTab).
    //Пробелов взято 3, а не 2 - шрифт не моноширный, и маркер "●" визуально немного шире одного пробела, двух
    //впритык не хватало (текст всё равно слегка наезжал на соседнюю вкладку); один запасной пробел с гарантией
    //покрывает эту разницу.
    LSheet.Caption := '   ' + LCapt0;
    FTabs[0].Sheet := LSheet;

    for i := 0 to High(va2) do begin
      SetLength(FTabs, Length(FTabs) + 1);
      FTabs[High(FTabs)].IdOrFormatEstimate := va2[i][0];
      FTabs[High(FTabs)].ItemType := S.NInt(va2[i][1]);
      FTabs[High(FTabs)].SyncChecked := True;
      FTabs[High(FTabs)].NotCreateChecked := False;
      FTabs[High(FTabs)].DuplicateFound := False;
      FTabs[High(FTabs)].DuplicateRow := -1;
      LoadExistingNamesForTab(FTabs[High(FTabs)]);
      LSheet := TTabSheet.Create(Self);
      LSheet.PageControl := pgcFormat;
      //см. комментарий про 3 пробела спереди у LCapt0/FTabs[0] выше
      LSheet.Caption := '   ' + VarToStr(va2[i][2]);
      FTabs[High(FTabs)].Sheet := LSheet;
    end;
  end;

  pgcFormat.Visible := (not FOneOnly) and (pgcFormat.PageCount > 0);
  SyncFormatComboWithTabs;
end;

procedure TFrmODedtOrStdItem.SyncFormatComboWithTabs;
//см. общий комментарий у FComboAppendedIds в interface-секции. Сначала снимаем записи, добавленные предыдущим
//вызовом (LoadCounterpartTabs может вызываться повторно - см. ControlOnChange при смене подгруппы 0-й вкладки),
//затем добавляем по одной записи на каждую парную вкладку (FTabs[1..]), если её подгруппы еще нет в списке
//(при CallMode = 3 список и так может содержать подгруппы любого типа - дублировать в этом случае не нужно).
var
  i, j: Integer;
  LKey: string;
begin
  for i := High(FComboAppendedIds) downto 0 do begin
    j := cmb_id_or_format_estimates.KeyItems.IndexOf(VarToStr(FComboAppendedIds[i]));
    if j >= 0 then begin
      cmb_id_or_format_estimates.Items.Delete(j);
      cmb_id_or_format_estimates.KeyItems.Delete(j);
    end;
  end;
  SetLength(FComboAppendedIds, 0);
  for i := 1 to High(FTabs) do begin
    LKey := VarToStr(FTabs[i].IdOrFormatEstimate);
    if cmb_id_or_format_estimates.KeyItems.IndexOf(LKey) < 0 then begin
      //см. комментарий про 3 пробела спереди у LCapt0 в LoadCounterpartTabs - Trim убирает этот резерв,
      //здесь он не нужен (это не заголовок вкладки, а строка комбобокса)
      cmb_id_or_format_estimates.Items.Add(Trim(FTabs[i].Sheet.Caption));
      cmb_id_or_format_estimates.KeyItems.Add(LKey);
      SetLength(FComboAppendedIds, Length(FComboAppendedIds) + 1);
      FComboAppendedIds[High(FComboAppendedIds)] := FTabs[i].IdOrFormatEstimate;
    end;
  end;
end;

procedure TFrmODedtOrStdItem.LoadExistingNamesForTab(var ATab: TCounterpartTab);
//см. общий комментарий у TCounterpartTab.ExistingNames. Список полей после name/id - price_base, wo_estimate,
//r0, r1..rN - специально повторяет порядок построения FSyncFields (см. Prepare, тот же цикл по RouteFields);
//на момент вызова (из LoadCounterpartTabs, а она - из Prepare, до объявления FSyncFields) сама переменная
//FSyncFields еще не построена, поэтому колонки строим напрямую по RouteFields, а не через FSyncFields -
//при изменении состава FSyncFields в Prepare не забыть поправить и здесь.
var
  i: Integer;
  LFields: string;
begin
  LFields := 'price_base, wo_estimate, r0';
  for i := 0 to High(RouteFields) do
    LFields := LFields + ', r' + IntToStr(i + 1);
  ATab.ExistingNames := Q.QLoad(
    'select name, id, ' + LFields + ' from or_std_items where id_or_format_estimates = :idf$i and id <> :id$i',
    [ATab.IdOrFormatEstimate, ID]
  );
end;

function TFrmODedtOrStdItem.FindExistingNameRow(const ATab: TCounterpartTab; const AName: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  if AName = '' then
    Exit;
  for i := 0 to High(ATab.ExistingNames) do
    if UpperCase(Trim(VarToStr(ATab.ExistingNames[i][0]))) = AName then begin
      Result := i;
      Exit;
    end;
end;

procedure TFrmODedtOrStdItem.CheckNameDuplicates;
//по текущему тексту edt_name проверяет по каждой вкладке (FTabs[i]), нет ли уже среди ExistingNames этой
//вкладки изделия с таким же наименованием - без обращения к БД (см. LoadExistingNamesForTab). Вызывается из
//VerifyAdd, т.е. фактически на каждое изменение любого поля формы (не только edt_name) - лишняя работа
//(лишний проход по уже загруженным в память небольшим массивам), но по-другому не выйдет без отдельного
//OnChange именно для edt_name, а общий диспетчер (ControlOnChangeEvent -> Verify -> VerifyAdd) уже вызывается
//централизованно на любое изменение, см. uFrmBasicMdi.pas.
//
//Для вкладок i > 0 (парные подгруппы) совпадение означает, что там уже есть отдельно существующее изделие с
//таким наименованием - подставляем его данные (цена/маршрут) в поля этой вкладки и снимаем синхронизацию по
//умолчанию (ApplyExistingItemToTabSlot). ВАЖНО (исправлено - было иначе, см. ниже): подставляем ТОЛЬКО при
//НОВОМ обнаружении совпадения (переход "не было -> есть", либо сменилась сама найденная строка - например,
//наименование изменили на другое, тоже совпадающее с каким-то изделием) - а не при КАЖДОМ вызове, пока
//совпадение просто продолжает держаться. Раньше подстановка (и, соответственно, сброс SyncChecked в False)
//происходила безусловно при каждом обнаружении - т.к. эта процедура вызывается на ЛЮБОЕ изменение любого поля
//формы (см. выше), это ломало явное включение синхронизации пользователем через ChbSyncClick: пользователь
//ставит галку "Синхронизировать" (это тоже "изменение поля" - копируются значения с 0-й вкладки), тут же снова
//отрабатывает CheckNameDuplicates, повторно находит ТО ЖЕ САМОЕ (не изменившееся) совпадение и немедленно
//откатывает и синхронизацию, и подставленные значения обратно к данным найденного изделия - внешне выглядело
//так, будто галка "не ставится". Теперь, пока найденная строка не меняется, ApplyExistingItemToTabSlot повторно
//не вызывается, и явный выбор пользователя (синхронизировать или нет) сохраняется.
//Для вкладки 0 (само добавляемое/редактируемое изделие) совпадение - это НЕ пара, а обычный конфликт
//уникальности (тот же случай, что и так уже блокируется на сохранении - см. VerifyBeforeSave); данные никуда
//не подставляются, только маркер на вкладке (см. pgcFormatDrawTab) и, только в режиме добавления, подсветка
//самого поля edt_name (Cth.SetErrorMarker) - в режиме редактирования подсветка поля избыточна, при
//редактировании без смены имени собственная запись уже исключена запросом (id <> :id$i в LoadExistingNamesForTab).
//
//ВАЖНО (найдено по факту - см. переписку с пользователем): в режиме редактирования (Mode = fEdit) для ПАРНЫХ
//вкладок (i > 0) уже НАЙДЕННАЯ пара (FTabs[i].DuplicateFound) больше НЕ переоценивается заново на каждое
//изменение edt_name - иначе переименование 0-й вкладки "теряло" уже найденную пару, как только текст edt_name
//переставал буквально совпадать с ее именем в БД: с этого момента пара считалась ненайденной, и при сохранении
//вместо ПЕРЕИМЕНОВАНИЯ существующего парного изделия (наравне с самой 0-й вкладкой) создавалось бы НОВОЕ,
//задваивая изделие. Однажды найденная в режиме редактирования пара теперь считается той же самой записью до
//конца редактирования, независимо от того, что дальше введено в имени - само переименование (or_std_items.name)
//найденной записи выполняется позже, при сохранении (см. SaveCounterpartTab/CounterpartTabNeedsSave/
//VerifyBeforeSave - везде добавлено сравнение текущего edt_name.Text с сохраненным в найденной строке именем).
//В режиме добавления (fAdd) поведение НЕ меняется - там совпадение по-прежнему может быть случайным (пользователь
//еще подбирает наименование для НОВОГО изделия), поэтому переоценка на каждое изменение остается прежней.
var
  i, LRow: Integer;
  LName: string;
  LRedraw: Boolean;
begin
  LName := UpperCase(Trim(edt_name.Text));
  LRedraw := False;
  for i := 0 to High(FTabs) do begin
    if (Mode = fEdit) and (i > 0) and FTabs[i].DuplicateFound then
      Continue; //пара уже зафиксирована на время редактирования - см. общий комментарий выше
    LRow := FindExistingNameRow(FTabs[i], LName);
    if (LRow >= 0) <> FTabs[i].DuplicateFound then
      LRedraw := True;
    if LRow >= 0 then begin
      //подставляем данные найденного изделия только если это НОВОЕ обнаружение (см. общий комментарий выше) -
      //проверяем ДО того, как ниже перезапишем DuplicateFound/DuplicateRow новыми значениями
      if (i > 0) and ((not FTabs[i].DuplicateFound) or (FTabs[i].DuplicateRow <> LRow)) then
        ApplyExistingItemToTabSlot(i, LRow);
      FTabs[i].DuplicateFound := True;
      FTabs[i].DuplicateRow := LRow;
    end
    else begin
      if FTabs[i].DuplicateFound and (i > 0) then
        ResetTabSlotSync(i);
      FTabs[i].DuplicateFound := False;
      FTabs[i].DuplicateRow := -1;
    end;
  end;
  if LRedraw and (pgcFormat.PageCount > 0) then
    pgcFormat.Invalidate;
  Cth.SetErrorMarker(edt_name, (Mode = fAdd) and (Length(FTabs) > 0) and FTabs[0].DuplicateFound);
end;

procedure TFrmODedtOrStdItem.ApplyExistingItemToTabSlot(ATabIndex, ARow: Integer);
//подставляет в слот fvtCustom[ATabIndex] значения полей найденного изделия (строка ARow в ExistingNames этой
//вкладки - см. общий комментарий у TCounterpartTab.ExistingNames про порядок столбцов) и снимает синхронизацию
//на этой вкладке (SyncChecked := False) - раз изделие уже существует независимо, синхронизировать его с
//первой вкладкой по умолчанию не нужно. Если ATabIndex - активная вкладка прямо сейчас, дополнительно
//обновляем видимые контролы и их состояние (замок/разблокировка) - см. SwitchToTab/SetTabsControlsState,
//логика та же, что при обычном переключении на несинхронизированную вкладку.
//ВАЖНО: вызывается из CheckNameDuplicates только при НОВОМ обнаружении совпадения (см. подробный комментарий
//там же) - т.е. однократно сбрасывает синхронизацию по умолчанию в момент, когда совпадение только что
//появилось, но не переустанавливает её принудительно повторно, если пользователь после этого сам включит
//синхронизацию вручную (ChbSyncClick), пока совпадение продолжает держаться на той же самой строке.
var
  LFields: TVarDynArray;
  j: Integer;
begin
  LFields := A.ExplodeV(FSyncFields, ';');
  for j := 0 to High(LFields) do
    if j + 2 <= High(FTabs[ATabIndex].ExistingNames[ARow]) then
      F.SetProp(VarToStr(LFields[j]), FTabs[ATabIndex].ExistingNames[ARow][j + 2], ATabIndex);
  FTabs[ATabIndex].SyncChecked := False;
  if ATabIndex = FActiveTab then begin
    F.SetPropsFromCustom(FSyncFields, ATabIndex, fvtVCurr, True);
    SetTabsControlsState;
  end;
end;

procedure TFrmODedtOrStdItem.ResetTabSlotSync(ATabIndex: Integer);
//см. ApplyExistingItemToTabSlot - обратное действие, когда совпадение по имени на вкладке ATabIndex пропало
//(наименование поменяли на другое, для которого пары уже нет): возвращаем синхронизацию по умолчанию (как в
//LoadCounterpartTabs при первом построении вкладки)
begin
  FTabs[ATabIndex].SyncChecked := True;
  if ATabIndex = FActiveTab then begin
    F.SetPropsFromCustom(FSyncFields, 0, fvtVCurr, True);
    SetTabsControlsState;
  end;
end;

procedure TFrmODedtOrStdItem.UpdateChbOneOnlyVisible;
//показывает/прячет чекбокс "Создать одно"/"Редактировать одно" по ТЕКУЩЕМУ FItemType (не показываем для
//полуфабрикатов - для них вкладок парных изделий нет вообще, чекбокс не нужен, см. LoadCounterpartTabs).
//Отдельным методом, а не только внутри Prepare - потому что тип может смениться уже ПОСЛЕ Prepare, если
//пользователь выбирает другую подгруппу в комбобоксе Формат (актуально для CallMode = 3, где в комбобоксе
//вперемешку подгруппы всех типов - см. ControlOnChange). Чекбокс может быть вовсе не создан (режим
//просмотра/удаления - см. Prepare) - тогда просто ничего не делаем.
//
//После изменения Visible пересчитываем раскладку панели (ArrangeControlsOnPanel) - без этого место под чекбокс
//на панели не пересчитывается само по себе при смене Visible/Width (тот же нюанс, что и при первоначальной
//подгонке ширины чекбокса в Prepare, см. подробный комментарий там про CorrectFormSize).
var
  LChbOneOnly: TDBCheckBoxEh;
begin
  LChbOneOnly := TDBCheckBoxEh(FindComponent('chb_OneOnly'));
  if not Assigned(LChbOneOnly) then
    Exit;
  LChbOneOnly.Visible := FItemType <> STDITEM_TYPE_SEMIPRODUCT;
  ArrangeControlsOnPanel(pnlFrmBtnsL);
end;

procedure TFrmODedtOrStdItem.pgcFormatDrawTab(Control: TCustomTabControl; TabIndex: Integer; const Rect: TRect; Active: Boolean);
//раскраска заголовков вкладок в зависимости от типа (произв./отгруз.) - см. FTabs[TabIndex].ItemType; отдельно -
//маркер и цвет текста, если на этой вкладке найдено совпадение по наименованию с уже существующим изделием
//(FTabs[TabIndex].DuplicateFound, см. CheckNameDuplicates) - это важнее признака активности вкладки, т.к.
//должно быть видно сразу на ВСЕХ вкладках одновременно, не переключаясь на них.
var
  LType: Integer;
  LCaption: string;
begin
  if TabIndex > High(FTabs) then
    Exit;
  LType := FTabs[TabIndex].ItemType;
  if LType = STDITEM_TYPE_PRODUCTION then
    Control.Canvas.Brush.Color := clMoneyGreen
  else
    Control.Canvas.Brush.Color := clSkyBlue;
  Control.Canvas.FillRect(Rect);
  Control.Canvas.Brush.Style := bsClear;
  //активную вкладку (без совпадения) выделяем цветом шрифта, а не жирным - жирный текст шире обычного и
  //вылезает на соседнюю вкладку (см. правку пользователя выше по TTabControl(Control).Tabs[TabIndex])
  if FTabs[TabIndex].DuplicateFound then
    Control.Canvas.Font.Color := clRed
  else if Active then
    Control.Canvas.Font.Color := clNavy
  else
    Control.Canvas.Font.Color := clWindowText;
  //подменяем ПЕРВЫЙ символ уже готового (заранее дополненного 2 пробелами, см. LoadCounterpartTabs) заголовка на
  //маркер или обратно на пробел - длина строки не меняется, поэтому ширина, реально выделенная Windows/VCL под
  //кнопку вкладки (посчитанная один раз по статической Caption при создании), не расходится с тем, что рисуем
  //здесь, и текст не вылезает за пределы вкладки при появлении/исчезновении маркера
  LCaption := TTabControl(Control).Tabs[TabIndex];
  if (Length(LCaption) > 0) then begin
    if FTabs[TabIndex].DuplicateFound then
      LCaption[1] := '●'
    else
      LCaption[1] := ' ';
  end;
  Control.Canvas.TextOut(Rect.Left + 6, Rect.Top + 3, LCaption);
end;

procedure TFrmODedtOrStdItem.pgcFormatChange(Sender: TObject);
begin
  SwitchToTab(pgcFormat.ActivePageIndex);
end;

procedure TFrmODedtOrStdItem.SwitchToTab(ANewIndex: Integer);
//переключение общих контролов (FSyncFields) на данные вкладки ANewIndex. Реальных отдельных наборов контролов
//на вкладках нет (см. общий комментарий в LoadCounterpartTabs) - вместо этого используются пользовательские
//слоты значений полей (см. uFields.pas, fvtCustom/CopyPropToCustom/SetPropsFromCustom), по одному на вкладку
//(индекс слота = индекс вкладки в FTabs). При уходе с вкладки её текущие значения запоминаются в её же слот
//(в т.ч. для вкладки 0 - как источник данных для синхронизированных вкладок). При приходе на вкладку: если
//это вкладка 0, либо на ней включена синхронизация - подставляются значения из слота 0 (то есть от первой
//вкладки); иначе - значения из собственного слота этой вкладки (последнее, что там было независимо введено).
//Наименование (edt_name) в это не входит - оно всегда одно, отдельно управляется в SetTabsControlsState.
//
//Формат (cmb_id_or_format_estimates) и Префикс (edt_prefix) - НЕ входят в FSyncFields (это свойства самой
//подгруппы вкладки, а не синхронизируемые между вкладками значения полей изделия) - раньше вообще не менялись
//при переключении вкладок и продолжали показывать подгруппу 0-й вкладки на любой вкладке. Подставляем их здесь
//отдельно, всегда по СОБСТВЕННОЙ подгруппе новой активной вкладки (FTabs[ANewIndex].IdOrFormatEstimate) -
//независимо от синхронизации по FSyncFields, т.к. подгруппа/префикс парной вкладки не меняются синхронизацией
//(сама вкладка = сама подгруппа, см. LoadCounterpartTabs). На парных вкладках cmb_id_or_format_estimates всё
//равно недоступен для редактирования (см. SetTabsControlsState) - его значение здесь выставлено только для
//отображения, поэтому список комбобокса заранее дополнен подгруппами парных вкладок (SyncFormatComboWithTabs).
//OnChange комбобокса на время программной установки значения отключаем - иначе сработает ControlOnChangeEvent
//(uFrmBasicMdi.pas) -> ControlOnChange, которая при смене cmb_id_or_format_estimates заново пересчитывает
//FIdOrFormatEstimate/FIdFormat/FItemType и перестраивает вкладки (LoadCounterpartTabs) как будто пользователь
//сам сменил подгруппу 0-й вкладки - здесь это неуместно и разрушило бы уже построенный набор FTabs.
begin
  if (ANewIndex = FActiveTab) or (ANewIndex < 0) or (ANewIndex > High(FTabs)) then
    Exit;
  F.CopyPropToCustom(FSyncFields, fvtVCurr, FActiveTab);
  FActiveTab := ANewIndex;
  if (FActiveTab = 0) or FTabs[FActiveTab].SyncChecked then
    F.SetPropsFromCustom(FSyncFields, 0, fvtVCurr, True)
  else
    F.SetPropsFromCustom(FSyncFields, FActiveTab, fvtVCurr, True);
  cmb_id_or_format_estimates.OnChange := nil;
  try
    Cth.SetControlValue(cmb_id_or_format_estimates, FTabs[FActiveTab].IdOrFormatEstimate);
  finally
    cmb_id_or_format_estimates.OnChange := ControlOnChangeEvent;
  end;
  if FActiveTab = 0 then
    edt_prefix.Text := FPrefix
  else
    edt_prefix.Text := VarToStr(Q.QLoadValue(
      'select prefix from or_format_estimates where id = :id$i', [FTabs[FActiveTab].IdOrFormatEstimate]));
  SetTabsControlsState;
end;

procedure TFrmODedtOrStdItem.ChbSyncClick(Sender: TObject);
//включение/выключение синхронизации на активной вкладке. chb_TabSync - общий контрол на форму (виден только
//при FActiveTab > 0 - см. SetTabsControlsState), поэтому всегда относится именно к текущей активной вкладке.
//При включении - если независимые значения полей на этой вкладке отличаются от значений первой вкладки,
//переспрашиваем перед тем как их перезаписать. Сравниваем через S.NNum, а не VarToStr - все поля FSyncFields
//числовые (price_base/wo_estimate/r0..rN, см. Prepare), S.NNum безопасно приводит и Null (в т.ч. пустое поле)
//к 0, так что отдельная проверка на "оба пустые" не нужна. VarToStr сравнивал СТРОКОВОЕ представление - одно и
//то же число в разных Variant-подтипах (Integer/Double/Currency) или с разным форматированием давало ложное
//расхождение и лишний вопрос пользователю, даже когда реальной разницы не было.
var
  LFields: TVarDynArray;
  i: Integer;
  LDiffers: Boolean;
begin
  if FActiveTab = 0 then
    Exit; //подстраховка - контрол не должен быть видим/активен на первой (своей) вкладке
  if chb_TabSync.Checked then begin
    LFields := A.ExplodeV(FSyncFields, ';');
    LDiffers := False;
    for i := 0 to High(LFields) do
      if S.NNum(F.GetProp(VarToStr(LFields[i]), fvtVCurr)) <> S.NNum(F.GetProp(VarToStr(LFields[i]), 0)) then begin
        LDiffers := True;
        Break;
      end;
    if LDiffers and (MyQuestionMessage('Значения на этой вкладке отличаются от значений первой вкладки.'#13#10'Заменить их значениями первой вкладки?') <> mrYes) then begin
      chb_TabSync.Checked := False;
      Exit;
    end;
    F.SetPropsFromCustom(FSyncFields, 0, fvtVCurr, True);
  end;
  FTabs[FActiveTab].SyncChecked := chb_TabSync.Checked;
  SetTabsControlsState;
end;

procedure TFrmODedtOrStdItem.ChbNotCreateClick(Sender: TObject);
begin
  if FActiveTab = 0 then
    Exit;
  FTabs[FActiveTab].NotCreateChecked := chb_TabNotCreate.Checked;
  if FTabs[FActiveTab].NotCreateChecked then
    FTabs[FActiveTab].SyncChecked := False; //раз изделие на этой вкладке не создаём - синхронизировать нечего
  SetTabsControlsState;
end;

procedure TFrmODedtOrStdItem.BtnCopyRouteClick(Sender: TObject);
//разовое копирование цены/маршрута с первой вкладки в текущую - независимо от состояния "Синхронизировать",
//удобно как отправная точка при независимом (несинхронизированном) заполнении
begin
  if FActiveTab = 0 then
    Exit;
  F.SetPropsFromCustom(FSyncFields, 0, fvtVCurr, True);
end;

procedure TFrmODedtOrStdItem.ChbOneOnlyClick(Sender: TObject);
//при отметке "Создать одно"/"Редактировать одно" вкладки парных изделий скрываются целиком (см. ниже) -
//синхронизация на них теряет смысл, снимаем её на всех, чтобы при повторном показе вкладок (снятии галки)
//не оставалось "зависшего" состояния синхронизации от предыдущего раза. Сам чекбокс имеет смысл только на
//первой вкладке (см. SetTabsControlsState, где он же блокируется на остальных) - но на случай программного
//вызова/старого состояния всё равно всегда явно переходим на вкладку 0.
var
  i: Integer;
begin
  FOneOnly := TDBCheckBoxEh(Sender).Checked;
  if FOneOnly then
    for i := 1 to High(FTabs) do
      FTabs[i].SyncChecked := False;
  pgcFormat.Visible := (not FOneOnly) and (pgcFormat.PageCount > 0);
  //ВАЖНО: программная установка ActivePageIndex, в отличие от переключения вкладки самим пользователем, НЕ
  //вызывает событие OnChange (pgcFormatChange) - это стандартное поведение VCL, TCustomTabControl.Change
  //вызывается только из обработки уведомления TCN_SELCHANGE, т.е. по факту действия пользователя. Поэтому
  //полагаться на pgcFormatChange -> SwitchToTab(0) здесь нельзя (раньше это иногда "срабатывало" - на самом
  //деле нет, и именно поэтому чекбоксы под разделителем не убирались, если "Создать одно" отмечали не с
  //первой вкладки) - переключаем вкладку и обновляем состояние контролов явно, кодом.
  pgcFormat.ActivePageIndex := 0;
  SwitchToTab(0); //если уже были на вкладке 0 - ничего не сделает (см. защиту в начале SwitchToTab), тогда
                   //состояние контролов всё равно обновит SetTabsControlsState ниже
  SetTabsControlsState; //гарантированно подхватывает новое значение pgcFormat.Visible (видимость bvlTabSync и
                         //т.п.) независимо от того, был ли выше реальный переход между вкладками
end;

procedure TFrmODedtOrStdItem.SetTabsControlsState;
//блокировка/разблокировка общих полей (кроме наименования - см. отдельно) в зависимости от активной вкладки:
//если это вкладка 0 или синхронизация на активной вкладке выключена - поля доступны на обычных условиях
//(с учетом права на изменение цены и правил маршрута - см. SetRoute); если синхронизация включена - поля
//заблокированы (они зеркалят первую вкладку, см. SwitchToTab).
//
//Также здесь же управляем видимостью и состоянием общих (не по одному на вкладку) контролов синхронизации
//bvlTabSync/chb_TabSync/chb_TabNotCreate/btn_TabCopyRoute (под pgcFormat, см. .dfm) - показываем их только
//когда вообще есть парные вкладки (pgcFormat.Visible) и активна не первая, "своя" вкладка.
var
  i: Integer;
  LLocked: Boolean;
  LCtrls: array of TControl;
  LChbOneOnly: TDBCheckBoxEh;
begin
  edt_name.ReadOnly := (FActiveTab <> 0) or (Mode in [fView, fDelete]);
  //ReadOnly сам по себе фон не перекрашивает (см. также ниже про nedt_price_base/edt_prefix/формат) - явно
  //красим/возвращаем фон в зависимости от активной вкладки, как и для остальных заблокированных полей, иначе
  //наименование выглядит редактируемым (белый фон), даже когда фактически заблокировано
  if edt_name.ReadOnly then
    Cth.SetEhControlColor(edt_name, clmyDisabled)
  else
    Cth.SetEhControlColor(edt_name, clWindow);

  //Префикс (edt_prefix) - чисто информационное поле (выводится по выбранному Формату, см. SetPrefixByFormat),
  //неизменяемо НИКОГДА, ни на какой вкладке, ни в каком режиме - оно и в .dfm по умолчанию ReadOnly = True.
  //Раньше здесь (в ветке "не заблокировано") ошибочно возвращалось ReadOnly := False вместе с остальными полями -
  //из-за этого поле становилось редактируемым на первой вкладке/при отключенной синхронизации. Выставляем
  //постоянно, безусловно, вне веток LLocked ниже - так проще не забыть и не завязывать на состояние синхронизации.
  edt_prefix.ReadOnly := True;
  Cth.SetEhControlColor(edt_prefix, clmyDisabled);

  //чекбокс "Создать одно"/"Редактировать одно" имеет смысл только на первой ("своей") вкладке - именно по ней
  //решается, создаём мы новое изделие или нет; на остальных вкладках блокируем его, чтобы не провоцировать
  //повторное переключение на вкладку 0 не глядя и не путать с блокировкой полей самой вкладки. Чекбокс создаётся
  //не всегда (см. Prepare - для полуфабрикатов и в режиме просмотра/удаления его нет вовсе), поэтому по имени.
  LChbOneOnly := TDBCheckBoxEh(FindComponent('chb_OneOnly'));
  if Assigned(LChbOneOnly) then
    LChbOneOnly.Enabled := (FActiveTab = 0);

  LLocked := (FActiveTab > 0) and FTabs[FActiveTab].SyncChecked;
  if LLocked then begin
    //SetControlsEditable вместо прямой установки ReadOnly/Enabled - помимо блокировки, дополнительно красит
    //фон полей серым (см. SetControlsEditable -> Cth.SetControlNotEditable(..., Greyed=True) -> clmyDisabled) -
    //так виднее, что поля именно временно заблокированы синхронизацией с первой вкладкой, а не недоступны вовсе.
    //Формат (cmb_id_or_format_estimates) раньше сюда не входил и оставался доступен для редактирования на любой
    //вкладке независимо от синхронизации - тоже блокируем его здесь. Префикс (edt_prefix) сюда не входит - он
    //заблокирован всегда и безусловно, см. отдельно в начале процедуры.
    SetLength(LCtrls, 4);
    LCtrls[0] := nedt_price_base;
    LCtrls[1] := chb_R0;
    LCtrls[2] := chb_Wo_Estimate;
    LCtrls[3] := cmb_id_or_format_estimates;
    for i := 0 to ComponentCount - 1 do
      if Copy(Components[i].Name, 1, 5) = 'chb_r' then begin
        SetLength(LCtrls, Length(LCtrls) + 1);
        LCtrls[High(LCtrls)] := TControl(Components[i]);
      end;
    SetControlsEditable(LCtrls, False);
  end
  else begin
    //разрешаем менять цену, если есть право User.Role(rOr_R_StdItems_Set_Prices) (иначе только просмотр)
    nedt_price_base.ReadOnly := (Mode = fEdit) and not User.Role(rOr_R_StdItems_Set_Prices);
    //ReadOnly сам по себе фон не перекрашивает - если до этого вкладка была заблокирована синхронизацией
    //(см. блок LLocked выше, SetControlsEditable закрашивает фон серым), явно возвращаем обычный белый фон,
    //иначе поле визуально выглядит заблокированным, даже когда оно уже редактируемо
    Cth.SetEhControlColor(nedt_price_base, clWindow);
    chb_R0.Enabled := True;
    chb_Wo_Estimate.Enabled := True;
    //Формат редактируем ТОЛЬКО на 0-й вкладке (это подгруппа самого редактируемого/добавляемого изделия) - на
    //парных вкладках подгруппа берется из уже существующей парной записи (или из выбора пользователя на 0-й
    //вкладке при первом сохранении, см. LoadCounterpartTabs) и не должна меняться отсюда; раньше здесь ошибочно
    //разрешалось редактирование Формата на любой (в т.ч. парной) вкладке в режиме добавления/копирования, хотя
    //реально отображаемое значение при этом всё равно было от 0-й вкладки (см. общий комментарий в SwitchToTab).
    //Префикс сюда не входит - он заблокирован всегда и безусловно, см. отдельно в начале процедуры.
    cmb_id_or_format_estimates.Enabled := (FActiveTab = 0) and (Mode in [fAdd, fCopy]);
    if cmb_id_or_format_estimates.Enabled then
      Cth.SetEhControlColor(cmb_id_or_format_estimates, clWindow)
    else
      Cth.SetEhControlColor(cmb_id_or_format_estimates, clmyDisabled);
    SetRoute; //своими правилами восстановит доступность строк маршрута (r0/без сметы)
  end;

  //чекбокс "Учет по СГП" имеет смысл только для ОТГРУЗОЧНЫХ изделий (для производственных и полуфабрикатов
  //прием на СГП по стандартным изделиям не ведется) - для прочих типов принудительно снимаем и блокируем.
  //В ОТЛИЧИЕ от полей выше (nedt_price_base/chb_R0/chb_Wo_Estimate/chb_r*/cmb_id_or_format_estimates),
  //доступность НЕ зависит от блокировки LLocked/синхронизации вкладки - by_sgp никогда не входит в FSyncFields
  //(см. комментарий у объявления FSyncFields) и никогда не копируется с первой вкладки, поэтому на отгрузочной
  //вкладке должен редактироваться всегда, даже если на ней включена галка "Синхронизировать". Тип берем по
  //АКТИВНОЙ вкладке (FTabs[FActiveTab].ItemType), а не по FItemType - у парных вкладок тип обычно другой (см.
  //общий комментарий у TCounterpartTab).
  chb_by_sgp.Enabled := FTabs[FActiveTab].ItemType = STDITEM_TYPE_SHIPMENT;
  if not chb_by_sgp.Enabled then
    chb_by_sgp.Checked := False;

  //до первого автовыравнивания формы (FTabsVisReady = False, взводится в AfterFormActivate) НЕ трогаем
  //видимость этих контролов - см. подробный комментарий у поля FTabsVisReady в interface-секции: пусть
  //остаются видимыми по умолчанию (как в .dfm), чтобы CorrectFormSize/Cth.AlignControls зарезервировали под
  //них место. Единственное исключение - вкладок вообще нет (PageCount = 0): тогда скрыть их можно сразу,
  //это никак не связано с переключением между вкладками и на авторасчет высоты не влияет по-другому.
  if FTabsVisReady or (pgcFormat.PageCount = 0) then begin
    bvlTabSync.Visible := pgcFormat.Visible;
    chb_TabSync.Visible := pgcFormat.Visible and (FActiveTab > 0);
    chb_TabNotCreate.Visible := pgcFormat.Visible and (FActiveTab > 0);
    btn_TabCopyRoute.Visible := pgcFormat.Visible and (FActiveTab > 0);
//btn_TabCopyRoute.Left := 20;
//btn_TabCopyRoute.Top := 4;
  end;
  if FActiveTab > 0 then begin
    chb_TabSync.Checked := FTabs[FActiveTab].SyncChecked;
    chb_TabNotCreate.Checked := FTabs[FActiveTab].NotCreateChecked;
    chb_TabSync.Enabled := not FTabs[FActiveTab].NotCreateChecked;
  end;
end;

procedure TFrmODedtOrStdItem.AfterFormActivate;
//вызывается из TFrmBasicMdi.FormActivate, т.е. гарантированно ПОСЛЕ FormShow/CorrectFormSize (см. подробности
//там же и у поля FTabsVisReady) - здесь впервые разрешаем SetTabsControlsState реально скрыть
//bvlTabSync/chb_TabSync/chb_TabNotCreate/btn_TabCopyRoute, если активна вкладка 0 (обычный случай при
//первом открытии формы).
begin
  inherited;
  FTabsVisReady := True;
  SetTabsControlsState;
  UpdateSemiproductErrorsLabel;
end;

function TFrmODedtOrStdItem.VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean;
//проверим здесь моменты:
//если не задан маршрут, когда он должен быть
//если цена перепродажи больше общей
//если наименование совпадает с уже существующим изделием на какой-либо из вкладок (см. CheckNameDuplicates)
var
  i, j: Integer;
begin
  Result := False;
  CheckNameDuplicates;
  //хотя бы один участок маршрута должен быть выбран, если не стоит "Без маршрута" (r0) и не стоит "Без сметы" -
  //в этих двух случаях маршрут не требуется вовсе. ВАЖНО (исправлено): было Copy(..., 1, 6) = 'chb_r' - т.к.
  //'chb_r' САМО состоит из 5 символов, сравнение 6-символьной копии с 5-символьной строкой не выполнялось
  //никогда (разные длины не равны) - проверка ниже фактически не работала. Значения r0/чекбоксов участков
  //приходят по Checked, т.к. на этот момент они уже отражают только что введенное пользователем (см. общий
  //комментарий у SwitchToTab про общие контролы/слоты вкладок) - самой активной вкладки.
  if (Cth.GetControlValue(chb_R0) <> 1) and (Cth.GetControlValue(chb_Wo_Estimate) <> 1) then begin
    j := 0;
    for i := 0 to ComponentCount - 1 do
      if (Copy(Components[i].Name, 1, 5) = 'chb_r') and (TDBCheckBoxEh(Components[i]).Checked) then
        j := j + 1;
    for i := 0 to ComponentCount - 1 do
      if (Copy(Components[i].Name, 1, 5) = 'chb_r') then
        Cth.SetErrorMarker(TDBCheckBoxEh(Components[i]), TDBCheckBoxEh(Components[i]).Enabled and (j = 0));
  end
  else
    for i := 0 to ComponentCount - 1 do
      if (Copy(Components[i].Name, 1, 5) = 'chb_r') then
        Cth.SetErrorMarker(TDBCheckBoxEh(Components[i]), False);
  //цена перепродажи не должна быть больше общей цены
//  Cth.SetErrorMarker(nedt_Price_PP, (nedt_Price_PP.Value > nedt_Price.Value) or (nedt_Price_PP.Value = null));
end;

function TFrmODedtOrStdItem.Save: Boolean;
//запись результатов в бд
//при изменении значения чекбокса Без сметы в режиме редактирования нам надо подправить смету после записи основной таблицы
//(если галка была снята, то загрузить пустую смету, если же галка поставлена, то смету просто удалить - будет требовать ввода в дальнешем)
//
//ВАЖНО (см. также подробные комментарии у ShouldSaveTab/SaveCounterpartTab/GetTabFieldValue): сохраняются ВСЕ
//вкладки (изделия), для которых ShouldSaveTab возвращает True - т.е. и 0-я (основная, штатным механизмом
//диалога), и все парные, не отмеченные "Не создавать" (если не стоит "Только одно" - тогда только 0-я).
//Обязательно, иначе вся синхронизация парных изделий не имеет смысла (см. переписку с пользователем).
var
  nameold: string;
  i: Integer;
  LProdPrefixedName, LDummy: string;
  LTabIds: TVarDynArray;
  LProdCount, LProdTabIndex: Integer;
  LProdId: Variant;
begin
  Q.QBeginTrans(True);
  //F в этот момент может показывать данные ЧУЖОЙ активной вкладки (FActiveTab <> 0), если пользователь нажал
  //сохранение, не переключившись обратно на первую - явно подставляем значения слота 0 (см. тот же прием в
  //SwitchToTab) перед вызовом inherited, иначе сохранились бы price_base/маршрут с чужой вкладки
  if FActiveTab <> 0 then begin
    //КРИТИЧНО (найдено по факту - при сохранении активной парной вкладки БЕЗ синхронизации ее только что
    //введенные значения price_base/маршрута пропадали и вместо них сохранялись значения 0-й вкладки): пока
    //активна вкладка FActiveTab, F.GetProp(field, fvtVCurr) - это ЕЕ актуальные, только что введенные
    //пользователем значения (см. GetTabFieldValue - для активной вкладки берется именно fvtVCurr, а не слот).
    //Подмена ниже (F.SetPropsFromCustom(FSyncFields, 0, ...)) нужна ТОЛЬКО чтобы inherited ниже сохранил
    //корректные данные 0-й вкладки - но она перезаписывает те же самые live-контролы, которые GetTabFieldValue
    //будет читать чуть позже для самой FActiveTab (см. цикл сохранения парных вкладок) - без этого сохранения
    //в слот вкладка FActiveTab потеряла бы свои реальные правки и сохранилась бы с данными 0-й вкладки вместо
    //своих собственных. Сохраняем текущие (истинные) значения FActiveTab в ее собственный слот - и восстановим
    //их обратно в live-контролы после вызова inherited, перед циклом сохранения парных вкладок (см. ниже).
    F.CopyPropToCustom(FSyncFields, fvtVCurr, FActiveTab);
    F.SetPropsFromCustom(FSyncFields, 0, fvtVCurr, True);
    //КРИТИЧНО (найдено по факту - ORA-00001 нарушение уникальности IDX_OR_STD_ITEMS_NAME при сохранении с
    //включенной синхронизацией без возврата на 0-ю вкладку): cmb_id_or_format_estimates - это ЖИВОЙ, связанный
    //с F контрол поля id_or_format_estimates САМОЙ 0-й вкладки (см. F.DefineFields в Prepare, где это поле
    //зарегистрировано как 'id_or_format_estimates$i') - inherited ниже читает ЕГО ТЕКУЩЕЕ значение (fvtVCurr)
    //как то, под какой подгруппой сохранить саму 0-ю вкладку. Но SwitchToTab (см. её комментарий) теперь
    //подставляет в этот же контрол подгруппу АКТИВНОЙ вкладки для отображения (иначе Формат на парных вкладках
    //не менялся - см. переписку с пользователем) - в отличие от FSyncFields, это поле НЕ хранится в
    //пользовательских слотах (fvtCustom), а напрямую подменяет отображаемое/live-значение самого контрола.
    //Если сохранение происходит, не переключившись обратно на 0-ю вкладку, inherited попытался бы сохранить
    //0-ю вкладку под ЧУЖОЙ (той, что сейчас отображена для другой вкладки) подгруппой - с тем же именем, что и
    //реальное изделие в этой подгруппе (например, сама эта парная вкладка) - отсюда и нарушение уникальности
    //(id_or_format_estimates, lower(name)). OnChange на время программной установки отключаем - см. тот же
    //прием и то же обоснование в SwitchToTab (иначе сработает полная перестройка вкладок).
    cmb_id_or_format_estimates.OnChange := nil;
    try
      Cth.SetControlValue(cmb_id_or_format_estimates, FTabs[0].IdOrFormatEstimate);
    finally
      cmb_id_or_format_estimates.OnChange := ControlOnChangeEvent;
    end;
  end;
  //сохраним основные (0-й вкладки) данные
  Result := inherited;
  if not Result then begin
    Q.QRollbackTrans;
    Exit;
  end;
  //переименование полного (с префиксом) наименования в ИТМ/bcad_nomencl - общим методом (см. RenameNomenclatura),
  //одинаково для 0-й и для каждой реально переименовываемой парной вкладки (см. тот же цикл ниже) - по просьбе
  //пользователя (см. переписку): обработка должна быть одной и той же для всех сохраняемых вкладок.
  if (Mode = fEdit) and (edt_name.Text <> FNameOld) then
    RenameNomenclatura(FIdEstimateGroup, FNameOld, Trim(edt_name.Text), FItemType);
  if (Mode = fEdit) and (Cth.GetControlValue(chb_Wo_Estimate) <> FWoEstimateOld) then begin
    //если изменился признак "Без сметы", то удаляем смету
    //(в проверке перед записью спросит, если при этом была подгружена непустая смета)
    Orders.RemoveEstimateForStdItem(id, True);
  end;
  //синхронизация цены/маршрута в шаблоны заказов - теперь общим методом (см. SyncOrderItemTemplates), т.к.
  //применяется не только к 0-й, но и к каждой сохраняемой парной вкладке (см. ниже)
  SyncOrderItemTemplates(0, ID);

  //возвращаем в live-контролы истинные значения FActiveTab (см. комментарий в начале Save), сохраненные в ее
  //слот перед подменой на данные 0-й вкладки для inherited выше - иначе GetTabFieldValue/SaveCounterpartTab
  //ниже прочитали бы для активной вкладки чужие (0-й вкладки) значения вместо ее собственных только что
  //введенных пользователем
  if FActiveTab <> 0 then
    F.SetPropsFromCustom(FSyncFields, FActiveTab, fvtVCurr, True);

  //--- сохранение ПАРНЫХ вкладок (если не "Только одно" и не отмечены "Не создавать") - см. ShouldSaveTab -------
  //ВАЖНО: обязательно (см. общий комментарий в начале Save) - без этого вся синхронизация парных изделий
  //(цена/маршрут/наименование) не имела бы смысла, т.к. фактически в БД сохранялось бы только само редактируемое
  //изделие (0-я вкладка), а его "пара" оставалась бы нетронутой несмотря на то, что пользователь ее видел и
  //(вероятно) редактировал на экране.
  //Но реальную запись (SaveCounterpartTab) делаем только когда есть что писать - см. CounterpartTabNeedsSave:
  //для уже существующего парного изделия без синхронизации и без ручных правок на его вкладке значения и так
  //совпадают с БД, лишний (пустой) UPDATE не нужен - достаточно просто взять его текущий id (GetTabExistingId)
  //для дальнейшего использования (ссылка в смете и т.п.).
  SetLength(LTabIds, Length(FTabs));
  LTabIds[0] := ID;
  if Mode <> fDelete then
    for i := 1 to High(FTabs) do
      if ShouldSaveTab(i) and CounterpartTabNeedsSave(i) then begin
        //ВАЖНО (добавлено - см. общий комментарий в RenameNomenclatura/CheckNameDuplicates): если это найденное
        //(не новое) парное изделие, и текущее edt_name.Text разошлось с тем, под которым оно значится в БД -
        //переименовываем его в ИТМ/bcad_nomencl ТАК ЖЕ, как и саму запись or_std_items (см. SaveCounterpartTab)
        //- запоминаем старое имя ДО вызова SaveCounterpartTab (сам вызов имя записи в FTabs[i].ExistingNames не
        //меняет, но для ясности - явно фиксируем его именно "до").
        if FTabs[i].DuplicateFound and (FTabs[i].DuplicateRow >= 0) then
          nameold := VarToStr(FTabs[i].ExistingNames[FTabs[i].DuplicateRow][0])
        else
          nameold := '';
        LTabIds[i] := SaveCounterpartTab(i);
        if VarIsNull(LTabIds[i]) then begin
          Result := False;
          Break;
        end;
        if (nameold <> '') and (UpperCase(Trim(nameold)) <> UpperCase(Trim(edt_name.Text))) then
          RenameNomenclatura(FTabs[i].IdOrFormatEstimate, nameold, Trim(edt_name.Text), FTabs[i].ItemType);
        SyncOrderItemTemplates(i, LTabIds[i]);
      end
      else if ShouldSaveTab(i) then
        LTabIds[i] := GetTabExistingId(i)
      else
        LTabIds[i] := Null;
  if not Result then begin
    Q.QRollbackTrans;
    Exit;
  end;

  //--- решение по смете(ам) отгрузочных изделий (см. общий комментарий у CheckSelfSmetaAction/CreateSelfSmeta) -
  //считаем ДО commit (нужны только уже вычисленные id/имена, в БД пока не пишем), выполняем - ТОЛЬКО ПОСЛЕ.
  //Правило (см. переписку с пользователем): смета создается для ОТГРУЗОЧНЫХ изделий и содержит ссылку на
  //ПРОИЗВОДСТВЕННОЕ - независимо от того, какое из них было на 0-й (изначально открытой) вкладке. Если среди
  //СОХРАНЯЕМЫХ вкладок производственных изделий несколько - неоднозначно, на какое ссылаться, смета не создается
  //вообще ни для одного отгрузочного. Если ровно одно - для каждого сохраняемого отгрузочного изделия создается
  //(если нужно) одинаковая по содержанию смета (см. CheckSelfSmetaAction), ссылающаяся на это единственное
  //производственное изделие.
  LProdCount := 0;
  LProdTabIndex := -1;
  if Mode <> fDelete then
    for i := 0 to High(FTabs) do
      if ShouldSaveTab(i) and (FTabs[i].ItemType = STDITEM_TYPE_PRODUCTION) then begin
        Inc(LProdCount);
        LProdTabIndex := i;
      end;

  Result := Q.QCommitTrans;
  //ВАЖНО: CreateSelfSmeta (через Orders.ApplyEstimateArray) вызываем ТОЛЬКО ПОСЛЕ фиксации своей транзакции
  //выше, а не внутри нее. ApplyEstimateArray сама открывает и коммитит/откатывает СВОЮ транзакцию (см. ее
  //реализацию в uOrders.pas), а Q.QBeginTrans в этом проекте НЕ поддерживает вложенность - при вызове внутри
  //уже открытой транзакции она сначала ОТКАТЫВАЕТ её целиком (см. комментарий в самой QBeginTrans, uDB.pas) -
  //вызов отсюда до commit привёл бы к потере уже сделанных выше изменений (запись изделий, переименования и
  //т.п.), хотя внешне сохранение выглядело бы успешным.
  if Result and (Mode <> fDelete) and (LProdCount = 1) then begin
    LProdId := LTabIds[LProdTabIndex];
    LProdPrefixedName := GetPrefixedName(FTabs[LProdTabIndex].IdOrFormatEstimate, edt_name.Text);
    for i := 0 to High(FTabs) do
      if ShouldSaveTab(i) and (FTabs[i].ItemType = STDITEM_TYPE_SHIPMENT) then
        if CheckSelfSmetaAction(LTabIds[i], LProdId, edt_name.Text, LProdPrefixedName, LDummy) = 1 then
          CreateSelfSmeta(LTabIds[i], LProdId, LProdPrefixedName);
  end;

  //для модальных вызовов, которым нужен id только что созданной/сохраненной записи (0-й, основной вкладки) -
  //например, "Создать полуфабрикат" из диалога сметы (см. CreateSemiproductFromRow, uFrmOGedtEstimate.pas) -
  //возвращаем его через стандартный канал TMDIResult.Data (см. общий комментарий у TMDIResult, uFrmBasicMdi.pas).
  //ShowModal2 отдает это значение вызывающему коду вместе с ModalResult сразу после закрытия формы с "Ок"
  //(FFormResult.ModalResult к этому моменту еще не установлен - это сделает сам framework в ShowForm/AForm.ShowModal
  //уже ПОСЛЕ выхода из Save - поэтому здесь достаточно заполнить только Data).
  if Result then
    FFormResult.Data := ID;
end;


procedure TFrmODedtOrStdItem.VerifyBeforeSave;
var
  i, res1, res2, res3: Integer;
  NewEmptyEstimate: Boolean;
  LPlanText, LPrefixedName, LOldPrefixedName, LDetails, LMsg, LTypeCapt: string;
  LAction, LProdCount, LProdTabIndex: Integer;
  LProdId: Variant;
  LSemiErrMsg, LSemiWarnMsg: string;
begin
  //проверки при редактировании или добавлении записи (только если изменилорсь наименование)
  //проверим, нет ли такого наименования среди стандартных изделий того же типа паспорта
  //также наименование с преиксом не должно быть в базе сметных наименований учета    //!!!
  //и также и в базе итм с типом "материалы и комплектующие"
  //ВАЖНО: эту проверку (для 0-й вкладки) пока намеренно не трогаем и не расширяем (в т.ч. res2/bcad_nomencl
  //закомментирован не случайно) - в дальнейшем ее надо будет дорабатывать отдельно с учетом нестандартных
  //изделий и полуфабрикатов. Тот же по смыслу (но не идентичный - см. CheckDuplicateNameInDb) вариант проверки
  //теперь ОБЯЗАТЕЛЕН и для остальных сохраняемых вкладок - см. блок ниже, после этого, не тронутого блока.
  if (Mode <> fDelete) and (FIdEstimateGroup > 1) and (edt_name.Text <> FNameOld) then begin
    res1 := Q.QLoadValue('select count(1) from or_std_items where id <> :id$i and (id_or_format_estimates = :idf$i) and name = :name$s', [ID, FIdEstimateGroup, edt_name.Text]);
    //res2 := Q.QSelectOneRow('select count(1) from bcad_nomencl where name = :name$s', [Prefix + '_' + edt_name.Text])[0];
    //ВАЖНО (исправлено): res2 сама проверка отключена намеренно (см. общий комментарий выше), но res2 при этом
    //нигде не присваивался - использовался в сумме res1 + res2 + res3 НЕИНИЦИАЛИЗИРОВАННЫМ (мусор со стека),
    //из-за чего проверка могла СЛУЧАЙНО заблокировать сохранение без единой реальной причины в тексте
    //предупреждения (обе строки-причины для res1/res3 могли оказаться пустыми). Явно обнуляем.
    res2 := 0;
    res3 := Q.QLoadValue('select count(1) from dv.nomenclatura where id_nomencltype = 0 and name = :name$s', [FPrefix + '_' + edt_name.Text]);
    if res1 + res2 + res3 > 0 then begin
      MyWarningMessage(S.IIf(res1 > 0, 'Такое наименование уже существует в этой группе стандартных изделий Учета!'#13#10, '') +
          //S.IIf(res2 > 0, 'Такое наименование (с учетом префикса) уже существует в справочнике сметных позиций Учета!'#13#10, '') +
        S.IIf(res3 > 0, 'Такое наименование (с учетом префикса) уже есть в ИТМ среди номенклатуры типа "материалы и комплектующие"!'#13#10, '') + #13#10'Данные не могут быть сохранены!');
      HasError := True;
      Exit;
    end;
  end;
  //ВАЖНО (исправлено): раньше условие проверяло только ТЕКУЩЕЕ состояние чекбокса (chb_Wo_Estimate.Checked),
  //без сравнения со старым (FWoEstimateOld) - если "Без сметы" стояло и до, и после (не менялось), это
  //предупреждение "она будет удалена" всё равно могло показаться, хотя реально Save() ничего не удаляет (см.
  //там же - Orders.RemoveEstimateForStdItem вызывается ТОЛЬКО когда значение чекбокса РЕАЛЬНО изменилось,
  //Cth.GetControlValue(chb_Wo_Estimate) <> FWoEstimateOld). Добавлено то же самое условие, что и в Save.
  if (Mode = fEdit) and (chb_Wo_Estimate.Checked) and (Cth.GetControlValue(chb_Wo_Estimate) <> FWoEstimateOld) then begin
    NewEmptyEstimate := Q.QLoadValue('select count(1) from estimates where id_std_item = :id$i and isempty = 0', [id]) > 0;
    if NewEmptyEstimate then
      if MyQuestionMessage('Для этого изделия выбран тип "без сметы", но сейчас к нему уже подгружена непустая смета.'#13#10'Она будет удалена.'#13#10'Продолжить?') <> mrYes then begin
        HasError := True;
        Exit;
      end;
  end;

  //--- обязательная проверка в БД для каждой ДОПОЛНИТЕЛЬНО сохраняемой (парной) вкладки - см. общий комментарий
  //в начале Save и CheckDuplicateNameInDb. Для тех, что будут ВСТАВЛЕНЫ как новые записи (DuplicateFound = False)
  //- проверяем на общих основаниях (имя еще никому не принадлежит). Для тех, что будут ОБНОВЛЕНЫ (найдено
  //совпадение по имени - FTabs[i].DuplicateFound) - раньше здесь считалось, что переименования вообще не
  //бывает (найденное имя всегда совпадает с edt_name.Text), но это уже не так (см. общий комментарий в
  //CheckNameDuplicates - однажды найденная в режиме редактирования пара больше не переоценивается, и
  //SaveCounterpartTab теперь ее переименовывает наравне с 0-й вкладкой) - если текущее edt_name.Text
  //разошлось с именем, под которым найденная запись значится в БД, точно так же нужна проверка на занятость
  //НОВОГО имени (исключая саму переименовываемую запись, см. AExcludeId), иначе возможно нарушение уникальности.
  for i := 1 to High(FTabs) do
    if ShouldSaveTab(i) then begin
      if not FTabs[i].DuplicateFound then begin
        LPrefixedName := GetPrefixedName(FTabs[i].IdOrFormatEstimate, edt_name.Text);
        if not CheckDuplicateNameInDb(FTabs[i].IdOrFormatEstimate, Null, edt_name.Text, LPrefixedName, LMsg) then begin
          MyWarningMessage(LMsg + #13#10'Данные не могут быть сохранены!');
          HasError := True;
          Exit;
        end;
      end
      else if (FTabs[i].DuplicateRow >= 0) and
              (UpperCase(Trim(VarToStr(FTabs[i].ExistingNames[FTabs[i].DuplicateRow][0]))) <> UpperCase(Trim(edt_name.Text))) then begin
        LPrefixedName := GetPrefixedName(FTabs[i].IdOrFormatEstimate, edt_name.Text);
        if not CheckDuplicateNameInDb(FTabs[i].IdOrFormatEstimate, FTabs[i].ExistingNames[FTabs[i].DuplicateRow][1], edt_name.Text, LPrefixedName, LMsg) then begin
          MyWarningMessage(LMsg + #13#10'Данные не могут быть сохранены!');
          HasError := True;
          Exit;
        end;
      end;
    end;

  //--- для полуфабрикатов: проверка "голого" имени на конфликты за пределами своей подгруппы (см. общее
  //требование пользователя и комментарий у CheckSemiproductNameConflicts) - при добавлении/копировании (имя
  //задается заново) или при редактировании, если имя реально изменилось.
  if (FItemType = STDITEM_TYPE_SEMIPRODUCT) and (Mode in [fAdd, fCopy, fEdit]) and
     ((Mode <> fEdit) or (edt_name.Text <> FNameOld)) then begin
    if not CheckSemiproductNameConflicts(S.IIf(Mode = fEdit, ID, Null), Trim(edt_name.Text), LSemiErrMsg, LSemiWarnMsg) then begin
      MyWarningMessage(LSemiErrMsg + #13#10'Данные не могут быть сохранены!');
      HasError := True;
      Exit;
    end;
    if LSemiWarnMsg <> '' then
      MyWarningMessage(LSemiWarnMsg);
  end;

  //--- смета(ы) отгрузочных изделий, переименование в bcad_nomencl и список создаваемых/обновляемых парных
  //изделий - собираем ЗАРАНЕЕ (до транзакции, здесь можно только читать БД) список того, что будет сделано при
  //сохранении, и одним диалогом просим подтверждение - см. общий комментарий у CheckSelfSmetaAction/Save.
  //Пока делаем это безусловно при каждом добавлении/сохранении с изменением наименования - это может
  //потребовать доработки (меньше "надоедать" диалогом), но пользователь явно попросил показывать его в любом
  //случае, пока эта логика не обкатана.
  if Mode in [fAdd, fCopy, fEdit] then begin
    LPlanText := '';

    //список создаваемых/обновляемых парных изделий (сама 0-я вкладка сюда не входит - её сохранение и так
    //очевидно пользователю, это ведь то, что он и открыл на редактирование/добавление). Уже существующие парные
    //изделия, которые реально нечем обновлять (синхронизация выключена, пользователь их не трогал - см.
    //CounterpartTabNeedsSave), в список НЕ включаем - иначе любое не связанное с ними изменение 0-й вкладки
    //ошибочно выглядело бы как "будет изменено ... изделие", хотя фактически ничего не меняется.
    for i := 1 to High(FTabs) do
      if ShouldSaveTab(i) and CounterpartTabNeedsSave(i) then begin
        LTypeCapt := S.IIf(FTabs[i].ItemType = STDITEM_TYPE_PRODUCTION, 'производственное', 'отгрузочное');
        //ВАЖНО (добавлено - см. общий комментарий в CheckNameDuplicates/SaveCounterpartTab): если найденная пара
        //отличается от edt_name.Text именем - это переименование существующей записи (наравне с 0-й вкладкой),
        //а не обычное "обновление" (цены/маршрута) - показываем это отдельной, более точной формулировкой.
        if FTabs[i].DuplicateFound and (FTabs[i].DuplicateRow >= 0) and
           (UpperCase(Trim(VarToStr(FTabs[i].ExistingNames[FTabs[i].DuplicateRow][0]))) <> UpperCase(Trim(edt_name.Text))) then begin
          S.ConcatStP(LPlanText, Format('- будет переименовано существующее %s изделие "%s" в "%s" (%s)',
            [LTypeCapt, Trim(VarToStr(FTabs[i].ExistingNames[FTabs[i].DuplicateRow][0])), Trim(edt_name.Text), Trim(FTabs[i].Sheet.Caption)]), #13#10);
          //ВАЖНО (обобщено - см. общий комментарий в RenameNomenclatura): переименование парной вкладки при
          //сохранении затрагивает и ее ИТМ/bcad_nomencl (по ее собственному префиксу, FTabs[i].IdOrFormatEstimate)
          //- предупреждаем об этом тем же способом, что и для 0-й вкладки (см. п.2 ниже).
          LDetails := GetNomenclaturaRenamePlanText(FTabs[i].IdOrFormatEstimate,
            VarToStr(FTabs[i].ExistingNames[FTabs[i].DuplicateRow][0]), Trim(edt_name.Text), FTabs[i].ItemType);
          if LDetails <> '' then
            S.ConcatStP(LPlanText, LDetails, #13#10);
        end
        else if FTabs[i].DuplicateFound then
          S.ConcatStP(LPlanText, Format('- будет обновлено существующее %s изделие "%s" (%s)', [LTypeCapt, Trim(edt_name.Text), Trim(FTabs[i].Sheet.Caption)]), #13#10)
        else
          S.ConcatStP(LPlanText, Format('- будет создано новое %s изделие "%s" (%s)', [LTypeCapt, Trim(edt_name.Text), Trim(FTabs[i].Sheet.Caption)]), #13#10);
      end;

    if FItemType = STDITEM_TYPE_SEMIPRODUCT then begin
      //полуфабрикаты: собственной сметы/самосметы у них не бывает (парных вкладок тоже - см. LoadCounterpartTabs,
      //поэтому список создаваемых/обновляемых парных изделий выше для них всегда пуст), поэтому блок ниже (для
      //непроизводственных типов) для них не выполняется. Отдельное предупреждение здесь больше не нужно - после
      //появления CheckSemiproductNameConflicts переименование bcad_nomencl теперь выполняется и для
      //полуфабрикатов тоже (см. RenameNomenclatura), так что позиции в сметах, где изделие используется как
      //компонент, обновляются автоматически (тем же способом, что и для остальных типов) - см. п.2 ниже.
    end
    else begin
      //не полуфабрикат: 1) смета для ОТГРУЗОЧНЫХ изделий со ссылкой на ЕДИНСТВЕННОЕ производственное - см.
      //общий комментарий у CheckSelfSmetaAction/Save про правило "производственных вкладок несколько"
      LProdCount := 0;
      LProdTabIndex := -1;
      for i := 0 to High(FTabs) do
        if ShouldSaveTab(i) and (FTabs[i].ItemType = STDITEM_TYPE_PRODUCTION) then begin
          Inc(LProdCount);
          LProdTabIndex := i;
        end;
      if LProdCount = 1 then begin
        LProdId := GetTabExistingId(LProdTabIndex);
        //LOldPrefixedName здесь временно используется для другой цели - как имя ПРОИЗВОДСТВЕННОГO изделия с
        //префиксом (переменных на все случаи не напасешься) - к переименованию (см. ниже, п.2) отношения не имеет.
        //ВАЖНО (исправлено - найдено по факту, см. переписку с пользователем): если производственное изделие
        //ПЕРЕИМЕНОВЫВАЕТСЯ прямо сейчас (само это редактирование, либо парная вкладка, чье имя переименовывается
        //наравне с 0-й - см. CheckNameDuplicates/SaveCounterpartTab), то в БД (и в bcad_nomencl, на который
        //ссылается существующая смета отгрузочного изделия) оно на момент ЭТОЙ проверки еще числится под СТАРЫМ
        //именем - переименование произойдет только при сохранении. Сравнивать здесь нужно со СТАРЫМ именем,
        //иначе CheckSelfSmetaAction ложно решит, что смета "отличается от ожидаемой" только из-за еще не
        //случившегося переименования, хотя на самом деле она соответствует текущему (дореименованному) состоянию.
        if LProdTabIndex = 0 then
          LOldPrefixedName := GetPrefixedName(FTabs[0].IdOrFormatEstimate, FNameOld)
        else if FTabs[LProdTabIndex].DuplicateFound and (FTabs[LProdTabIndex].DuplicateRow >= 0) then
          LOldPrefixedName := GetPrefixedName(FTabs[LProdTabIndex].IdOrFormatEstimate,
            VarToStr(FTabs[LProdTabIndex].ExistingNames[FTabs[LProdTabIndex].DuplicateRow][0]))
        else
          LOldPrefixedName := GetPrefixedName(FTabs[LProdTabIndex].IdOrFormatEstimate, edt_name.Text);
        for i := 0 to High(FTabs) do
          if ShouldSaveTab(i) and (FTabs[i].ItemType = STDITEM_TYPE_SHIPMENT) then begin
            LAction := CheckSelfSmetaAction(GetTabExistingId(i), LProdId, Trim(edt_name.Text), LOldPrefixedName, LDetails);
            if LAction = 1 then
              S.ConcatStP(LPlanText, '- ' + LDetails, #13#10)
            else if LAction = 2 then
              //отличается от ожидаемой - это только предупреждение, не входит в подтверждение (действие и так
              //не выполняется - трогать существующую нестандартную смету автоматически не будем)
              MyWarningMessage(LDetails);
          end;
      end;
    end;
    //2) при переименовании 0-й вкладки - переименование записи в номенклатуре ИТМ (dv.nomenclatura) И, ОТДЕЛЬНО,
    //в справочнике сметных позиций Учета (bcad_nomencl) - общим методом (см. GetNomenclaturaRenamePlanText/
    //RenameNomenclatura), тем же, что используется выше для парных вкладок. ВАЖНО (исправлено): раньше этот блок
    //находился ВНУТРИ ветки "не полуфабрикат" выше и для полуфабрикатов вообще не показывался - но Save()
    //переименовывает запись в ИТМ (dv.nomenclatura) для ЛЮБОГО типа изделия, включая полуфабрикаты (это не
    //связано со сметами - см. отдельное предупреждение для полуфабрикатов выше); поэтому вынесено сюда, чтобы
    //выполняться безусловно по типу, как и в Save.
    if (Mode = fEdit) and (edt_name.Text <> FNameOld) then begin
      LDetails := GetNomenclaturaRenamePlanText(FIdEstimateGroup, FNameOld, Trim(edt_name.Text), FItemType);
      if LDetails <> '' then
        S.ConcatStP(LPlanText, LDetails, #13#10);
    end;
    //ВАЖНО (добавлено по просьбе пользователя): собственное переименование 0-й вкладки (самого редактируемого
    //изделия) нигде выше в LPlanText не попадает - оно и так очевидно пользователю (это то, что он открыл на
    //редактирование), поэтому диалог подтверждения не показывается ТОЛЬКО из-за него одного (см. общий
    //комментарий в начале этого if-блока). Но если диалог и так будет показан по другим причинам (счетчик
    //LPlanText уже не пуст - другие вкладки/ИТМ/смета) - добавляем эту информацию первой строкой, чтобы
    //пользователь видел полную картину происходящего в одном месте, а не только последствия для остальных вкладок.
    if (LPlanText <> '') and (Mode = fEdit) and (edt_name.Text <> FNameOld) then
      LPlanText := Format('- будет переименовано редактируемое изделие "%s" в "%s"', [FNameOld, Trim(edt_name.Text)]) + #13#10 + LPlanText;
    if LPlanText <> '' then
      if MyQuestionMessage('Будут внесены следующие изменения:'#13#10 + LPlanText + #13#10'Продолжить сохранение?') <> mrYes then begin
        HasError := True;
        Exit;
      end;
  end;
end;

function TFrmODedtOrStdItem.CheckSelfSmetaAction(AIdShipmentItem, AIdProductionItem: Variant; const AShipmentDisplayName, AProductionPrefixedName: string; out ADetails: string): Integer;
//смета ОТГРУЗОЧНОГО изделия из ОДНОЙ позиции, ссылающейся на ПРОИЗВОДСТВЕННОЕ изделие - и по наименованию (с
//префиксом, через bcad_nomencl), и по id (id_or_std_item) напрямую, количество 1, единица измерения "шт."
//(bcad_units.id = 1), группа "Готовые изделия" (bcad_groups.id = 104). Нужна, чтобы у отгрузочного изделия
//вообще была хоть какая-то смета для последующего учета/списания в готовой продукции (списывается фактически
//произведенное производственное изделие), даже если само отгрузочное изделие не имеет собственного состава.
//Создается ТОЛЬКО когда среди сохраняемых вкладок ровно одно производственное изделие - см. общий комментарий
//у мест вызова (Save/VerifyBeforeSave) про правило "производственных вкладок несколько - не создаем вообще".
//
//AIdShipmentItem - id отгрузочного изделия (Null, если оно еще не сохранено - новое). AIdProductionItem - id
//(уже сохраненного или существующего) производственного изделия, на которое должна ссылаться позиция сметы.
//
//Возвращает:
//  0 - ничего не требуется (смета уже есть и в точности соответствует ожидаемой)
//  1 - смету нужно создать (либо ее еще нет вовсе, либо отгрузочное изделие только создается)
//  2 - смета уже есть, но отличается от ожидаемой - только предупреждаем, НЕ трогаем ее автоматически
//ADetails - текст с описанием (для диалога подтверждения при результате 1, для предупреждения при результате 2)
var
  LIdEstimate: Variant;
  LCnt: Integer;
  va: TVarDynArray;
begin
  ADetails := '';
  if S.NNum(AIdShipmentItem) = 0 then begin
    //отгрузочное изделие еще не сохранено (новое) - смету для него по определению проверить негде, всегда создаем
    Result := 1;
    ADetails := Format('изделие "%s" (новое) - будет создана смета из 1 позиции со ссылкой на производственное изделие "%s" (шт., группа "Готовые изделия")', [AShipmentDisplayName, AProductionPrefixedName]);
    Exit;
  end;
  LIdEstimate := Q.QLoadValue('select id from estimates where id_std_item = :id$i', [AIdShipmentItem]);
  if LIdEstimate = null then begin
    Result := 1;
    ADetails := Format('изделие "%s" - смета отсутствует, будет создана из 1 позиции со ссылкой на производственное изделие "%s" (шт., группа "Готовые изделия")', [AShipmentDisplayName, AProductionPrefixedName]);
    Exit;
  end;
  LCnt := Q.QLoadValue('select count(1) from estimate_items where id_estimate = :ide$i and deleted = 0', [LIdEstimate]);
  if LCnt = 1 then begin
    va := Q.QLoadRow(
      'select n.name, ei.id_or_std_item, ei.id_group, ei.id_unit, ei.qnt1 from estimate_items ei, bcad_nomencl n ' +
      'where ei.id_estimate = :ide$i and ei.deleted = 0 and n.id = ei.id_name',
      [LIdEstimate]);
    //ВАЖНО: требуем ЯВНО положительный AIdProductionItem для совпадения (S.NNum(AIdProductionItem) > 0) - без
    //этого, если производственное изделие еще НЕ сохранено (вызов из VerifyBeforeSave ДО сохранения, id пока
    //Null) и у существующей позиции сметы ei.id_or_std_item тоже почему-то Null/0 (например, смета была создана
    //не этим механизмом), S.NNum(Null) = 0 = S.NNum(0) совпали бы СЛУЧАЙНО - результат 0 ("ничего не требуется")
    //был бы неверным: после реального сохранения производственного изделия (уже с настоящим id) то же самое
    //сравнение почти наверняка дало бы несовпадение (результат 2). Проверка гарантирует, что "уже всё совпадает"
    //никогда не сообщается, пока производственное изделие реально не существует.
    if (VarToStr(va[0]) = AProductionPrefixedName) and (S.NNum(va[1]) = S.NNum(AIdProductionItem)) and
       (S.NNum(AIdProductionItem) > 0) and
       (S.NInt(va[2]) = BCAD_GROUP_FINISHED_ITEMS) and (S.NInt(va[3]) = BCAD_UNIT_PCS) and (S.NNum(va[4]) = 1) then begin
      Result := 0;
      Exit;
    end;
  end;
  Result := 2;
  ADetails := Format('изделие "%s" - смета уже существует, но отличается от ожидаемой (не 1 позиция со ссылкой на производственное изделие "%s", шт., группа "Готовые изделия", кол-во 1) - оставлена без изменений, проверьте вручную', [AShipmentDisplayName, AProductionPrefixedName]);
end;

procedure TFrmODedtOrStdItem.CreateSelfSmeta(AIdShipmentItem, AIdProductionItem: Variant; const AProductionPrefixedName: string);
//см. общий комментарий у CheckSelfSmetaAction. Вызывать только когда CheckSelfSmetaAction вернул 1 (создание),
//и только ПОСЛЕ фиксации собственной транзакции сохранения изделий (см. подробный комментарий в Save) -
//Orders.ApplyEstimateArray сама открывает и коммитит/откатывает отдельную транзакцию.
var
  Ctx: TEstimateApplyContext;
  Est: TVarDynArray2;
begin
  Ctx.IdEstimate := Null;
  Ctx.IdOrder := Null;
  Ctx.IdOrderItem := Null;
  Ctx.IdStdItem := AIdShipmentItem; //смета создается ДЛЯ отгрузочного изделия...
  Ctx.OrderIdUchet := Null;
  Ctx.OrQnt := Null;
  Ctx.IsEstimateEmpty := 0;
  Ctx.OrDtEst := Null;
  Ctx.OrSlash := Null;
  Ctx.ParentIdEstimate := Null;
  Ctx.OrName := AProductionPrefixedName;
  Ctx.FileName := '';
  Ctx.OneItem := True;
  Ctx.QntChanged := False;
  Ctx.IsOrItemStd := False;
  //свои сообщения об успехе/ошибке не показываем - пользователь уже был предупрежден и подтвердил действие
  //заранее, в VerifyBeforeSave (см. общий комментарий там же)
  Ctx.Silent := True;
  Ctx.EstBefore := Orders.LoadEstimateArray(Null); //снимок "до" - пустой, смета только создается
  Ctx.EstLogSource := '0'; //факт первичной загрузки, см. TOrders.LogEstimateChange
  //...а единственная позиция в ней ссылается на ПРОИЗВОДСТВЕННОЕ изделие - и по имени (через bcad_nomencl,
  //name), и по id напрямую (id_or_std_item) - см. общий комментарий у CheckSelfSmetaAction про смену модели
  //[name, id_group, id_unit, qnt1, comment, id_or_std_item] - см. формат в TOrders.ApplyEstimateArray/LoadEstimate
  Est := [[AProductionPrefixedName, BCAD_GROUP_FINISHED_ITEMS, BCAD_UNIT_PCS, 1, '', AIdProductionItem]];
  Orders.ApplyEstimateArray(Ctx, Est);
end;

function TFrmODedtOrStdItem.ShouldSaveTab(ATabIndex: Integer): Boolean;
//0-я вкладка (само редактируемое/добавляемое изделие) сохраняется всегда - на ней и держится вся форма.
//Остальные (парные) - только если НЕ отмечено "Только одно" (FOneOnly - тогда вкладки вообще не в счет, как
//будто их нет) и на конкретной вкладке не отмечено "Не создавать" (FTabs[ATabIndex].NotCreateChecked).
begin
  if ATabIndex = 0 then
    Result := True
  else
    Result := (not FOneOnly) and not FTabs[ATabIndex].NotCreateChecked;
end;

function TFrmODedtOrStdItem.CounterpartTabNeedsSave(ATabIndex: Integer): Boolean;
//вкладка ATabIndex (>0), для которой ShouldSaveTab уже вернул True - реально нуждается в записи в БД, только
//если это НОВОЕ изделие (FTabs[ATabIndex].DuplicateFound = False - его в любом случае нужно создать, иначе
//ссылаться в смете будет не на что, см. общий комментарий в Save) ЛИБО уже существующее, но хотя бы одно из
//синхронизируемых полей (FSyncFields) сейчас отличается от того, что уже есть в БД (снимок в ExistingNames,
//см. LoadExistingNamesForTab/ApplyExistingItemToTabSlot).
//
//Без этой проверки ЛЮБОЕ изменение 0-й вкладки при ВЫКЛЮЧЕННОЙ синхронизации на парной вкладке приводило бы к
//тому, что VerifyBeforeSave безусловно показывал бы "будет обновлено существующее ... изделие" для этой парной
//вкладки, а Save реально выполнял бы её пустое обновление (теми же значениями, что уже в БД) - хотя
//пользователь эту вкладку вообще не трогал и синхронизацию не включал (см. переписку с пользователем). Когда
//синхронизация ВКЛЮЧЕНА, GetTabFieldValue для этой вкладки как раз и берет АКТУАЛЬНЫЕ значения 0-й вкладки
//(см. её общий комментарий) - если они успели разойтись со снимком в БД, здесь это корректно обнаружится как
//реальное изменение. Сравнение через S.NNum - см. тот же приём и то же обоснование в ChbSyncClick.
//
//ВАЖНО (добавлено - найдено по факту, см. переписку с пользователем и общий комментарий в CheckNameDuplicates):
//раз найденная в режиме редактирования пара теперь "закреплена" независимо от дальнейшего ввода в edt_name,
//переименование 0-й вкладки САМО ПО СЕБЕ (даже без изменений FSyncFields) - тоже причина, по которой парную
//вкладку нужно сохранить (переименовать наравне с 0-й) - без этой проверки чистое переименование при
//неизменных цене/маршруте тут же попало бы на "Result := False" ниже, и SaveCounterpartTab вообще не вызвался бы.
var
  LFields: TVarDynArray;
  j: Integer;
begin
  Result := True;
  if (ATabIndex = 0) or not FTabs[ATabIndex].DuplicateFound or (FTabs[ATabIndex].DuplicateRow < 0) then
    Exit; //новое изделие (или подстраховка при некорректном состоянии) - всегда нуждается в создании
  if UpperCase(Trim(VarToStr(FTabs[ATabIndex].ExistingNames[FTabs[ATabIndex].DuplicateRow][0]))) <> UpperCase(Trim(edt_name.Text)) then
    Exit; //переименовано - см. общий комментарий выше
  LFields := A.ExplodeV(FSyncFields, ';');
  for j := 0 to High(LFields) do
    if (j + 2 <= High(FTabs[ATabIndex].ExistingNames[FTabs[ATabIndex].DuplicateRow])) and
       (S.NNum(GetTabFieldValue(ATabIndex, VarToStr(LFields[j]))) <>
        S.NNum(FTabs[ATabIndex].ExistingNames[FTabs[ATabIndex].DuplicateRow][j + 2])) then
      Exit;
  Result := False;
end;

function TFrmODedtOrStdItem.GetTabFieldValue(ATabIndex: Integer; const AField: string): Variant;
//разрешает АКТУАЛЬНОЕ (на текущий момент, независимо от того, какая вкладка сейчас реально отображается)
//значение поля AField (без суффикса типа - имя из FSyncFields, например 'price_base', НЕ 'price_base$f') для
//вкладки ATabIndex:
//  - если ATabIndex - вкладка, активная ПРЯМО СЕЙЧАС - значения полей формы (fvtVCurr) актуальны напрямую;
//  - если это НЕ активная вкладка, но >0 и с включенной синхронизацией - синхронизированные поля зеркалят
//    0-ю вкладку (см. SwitchToTab/ChbSyncClick), поэтому берем АКТУАЛЬНОЕ значение именно 0-й вкладки (не
//    свой слот - он мог не обновляться с прошлого визита и быть устаревшим, если пользователь менял поля на
//    0-й вкладке уже после того, как в последний раз покидал/заходил на эту вкладку);
//  - иначе (не активна, не синхронизирована, либо это 0-я вкладка и она не активна) - берем значение из
//    собственного слота вкладки (fvtCustom[ATabIndex]) - оно обновляется при каждом уходе с вкладки (см.
//    SwitchToTab) или при обнаружении совпадения по имени (см. ApplyExistingItemToTabSlot).
begin
  if ATabIndex = FActiveTab then
    Result := F.GetProp(AField, fvtVCurr)
  else if (ATabIndex > 0) and FTabs[ATabIndex].SyncChecked then begin
    if FActiveTab = 0 then
      Result := F.GetProp(AField, fvtVCurr)
    else
      Result := F.GetProp(AField, 0)
  end
  else
    Result := F.GetProp(AField, ATabIndex);
end;

function TFrmODedtOrStdItem.GetPrefixedName(AIdOrFormatEstimate: Variant; const AName: string): string;
var
  LPrefix: string;
begin
  LPrefix := '';
  if S.NNum(AIdOrFormatEstimate) > 0 then
    LPrefix := VarToStr(Q.QLoadValue('select prefix from or_format_estimates where id = :id$i', [AIdOrFormatEstimate]));
  Result := S.IIFStr(LPrefix <> '', LPrefix + '_', '') + Trim(AName);
end;

procedure TFrmODedtOrStdItem.RenameNomenclatura(AIdOrFormatEstimate: Variant; const AOldName, ANewName: string; AItemType: Integer);
//переименовывает запись в номенклатуре ИТМ (dv.nomenclatura) и, ОТДЕЛЬНО, в справочнике сметных позиций Учета
//(bcad_nomencl) - по ПОЛНОМУ (с учетом префикса подгруппы AIdOrFormatEstimate, см. GetPrefixedName) наименованию.
//ВАЖНО (обобщено по просьбе пользователя - см. переписку): раньше это переименование выполнялось только для
//0-й вкладки (единственной, которую можно было переименовать) - теперь, когда однажды найденная в режиме
//редактирования парная вкладка тоже переименовывается наравне с 0-й (см. общий комментарий в
//CheckNameDuplicates/SaveCounterpartTab), обработка должна быть ОДИНАКОВОЙ для любой сохраняемой вкладки: и
//сама запись or_std_items (см. SaveCounterpartTab/inherited Save), и ее полное наименование в ИТМ/bcad_nomencl.
//Вызывается из Save для 0-й вкладки (AIdOrFormatEstimate = FIdEstimateGroup, AOldName = FNameOld) и для каждой
//реально переименовываемой парной вкладки (AIdOrFormatEstimate = FTabs[i].IdOrFormatEstimate - у каждой
//подгруппы свой префикс, AOldName - имя, под которым найденная запись значится в БД).
//
//Идентифицирующее имя - ПОЛНОЕ (с учетом префикса подгруппы AIdOrFormatEstimate, см. GetPrefixedName) для всех
//типов, КРОМЕ полуфабрикатов - у полуфабриката собственного префикса в bcad_nomencl/ИТМ нет, он идентифицируется
//"голым" именем наравне с нестандартными изделиями (см. общее требование пользователя - переписка, и комментарий
//в CheckSemiproductNameConflicts); поэтому для AItemType = STDITEM_TYPE_SEMIPRODUCT берем Trim(AOldName/ANewName)
//напрямую, НЕ вызывая GetPrefixedName (не полагаемся на то, что в БД у подгруппы полуфабриката прописан пустой
//префикс - правило соблюдается явно, в коде).
//ВАЖНО (обобщено по просьбе пользователя - см. переписку): раньше bcad_nomencl переименовывался только для
//НЕ-полуфабрикатов - теперь (после появления CheckSemiproductNameConflicts, гарантирующей отсутствие конфликтов
//имени) переименовываем и для полуфабрикатов тоже, тем же способом, что и ИТМ, ниже.
//В estimate_items ссылка на компонент делается ПО ИМЕНИ через bcad_nomencl (id_name) - переименование самой
//записи bcad_nomencl автоматически "протаскивает" новое имя во все сметы, где изделие уже использовано как
//компонент, без необходимости искать и править каждую такую смету отдельно.
//
//Совпадения полных/голых имён практически исключены (для полуфабрикатов - см. CheckSemiproductNameConflicts,
//для остальных типов - см. общий комментарий выше), поэтому просто переименовываем существующую запись, если
//только запись с НОВЫМ именем уже не существует (защита от нарушения уникальности) - то же самое условие
//заранее проверяется в VerifyBeforeSave (для текста подтверждения).
var
  LOldName, LNewName: string;
  Res: Integer;
begin
  if AItemType = STDITEM_TYPE_SEMIPRODUCT then begin
    LOldName := Trim(AOldName);
    LNewName := Trim(ANewName);
  end
  else begin
    LOldName := GetPrefixedName(AIdOrFormatEstimate, AOldName);
    LNewName := GetPrefixedName(AIdOrFormatEstimate, ANewName);
  end;
  if LOldName = LNewName then
    Exit;
  Res := Q.QLoadValue('select count(1) from dv.nomenclatura where id_group = :ig_group$i and name = :name$s', [ItmGroups_Production_ID, LNewName]);
  if Res = 0 then
    Q.QExecSql('update dv.nomenclatura set name = :name$s, fullname = :fullname$s where id_group = :ig_group$i and name = :nameold$s',
      [LNewName, LNewName, ItmGroups_Production_ID, LOldName]);
  Res := Q.QLoadValue('select count(1) from bcad_nomencl where name = :name$s', [LNewName]);
  if Res = 0 then
    Q.QExecSql('update bcad_nomencl set name = :name$s where name = :nameold$s', [LNewName, LOldName]);
end;

function TFrmODedtOrStdItem.GetNomenclaturaRenamePlanText(AIdOrFormatEstimate: Variant; const AOldName, ANewName: string; AItemType: Integer): string;
//текст для диалога подтверждения (см. VerifyBeforeSave) - ЗАРАНЕЕ (без изменений в БД) предсказывает, что
//реально сделает RenameNomenclatura при сохранении - той же самой логикой (в т.ч. той же защитой от нарушения
//уникальности - "не переименовываем, если целевое имя уже занято"), чтобы обещание в диалоге строго совпадало
//с тем, что произойдет при сохранении (см. общее требование пользователя в начале VerifyBeforeSave).
var
  LOldName, LNewName: string;
begin
  Result := '';
  //см. общий комментарий в RenameNomenclatura про "голое" (без префикса) идентифицирующее имя для полуфабрикатов
  if AItemType = STDITEM_TYPE_SEMIPRODUCT then begin
    LOldName := Trim(AOldName);
    LNewName := Trim(ANewName);
  end
  else begin
    LOldName := GetPrefixedName(AIdOrFormatEstimate, AOldName);
    LNewName := GetPrefixedName(AIdOrFormatEstimate, ANewName);
  end;
  if LOldName = LNewName then
    Exit;
  if (Q.QLoadValue('select count(1) from dv.nomenclatura where id_group = :ig$i and name = :n$s', [ItmGroups_Production_ID, LOldName]) > 0) and
     (Q.QLoadValue('select count(1) from dv.nomenclatura where id_group = :ig$i and name = :n$s', [ItmGroups_Production_ID, LNewName]) = 0) then
    S.ConcatStP(Result, Format('- в номенклатуре ИТМ запись "%s" будет переименована в "%s"', [LOldName, LNewName]), #13#10);
  if (Q.QLoadValue('select count(1) from bcad_nomencl where name = :n$s', [LOldName]) > 0) and
     (Q.QLoadValue('select count(1) from bcad_nomencl where name = :n$s', [LNewName]) = 0) then
    S.ConcatStP(Result, Format('- в справочнике сметных позиций (bcad_nomencl) запись "%s" будет переименована в "%s" (это же затронет сметы, где изделие используется как компонент)', [LOldName, LNewName]), #13#10);
end;

function TFrmODedtOrStdItem.GetTabExistingId(ATabIndex: Integer): Variant;
//id уже существующего (до сохранения) изделия вкладки ATabIndex, если он уже известен - для 0-й вкладки это
//ID диалога (заполнен в режимах fEdit/fView/fDelete), для остальных - найденное по совпадению имени в
//ExistingNames (FTabs[i].DuplicateFound/DuplicateRow, см. CheckNameDuplicates), либо Null, если изделие еще
//не существует и будет создано заново
begin
  if ATabIndex = 0 then
    Result := S.IIf(Mode = fEdit, ID, Null)
  else if FTabs[ATabIndex].DuplicateFound and (FTabs[ATabIndex].DuplicateRow >= 0) then
    Result := FTabs[ATabIndex].ExistingNames[FTabs[ATabIndex].DuplicateRow][1]
  else
    Result := Null;
end;

function TFrmODedtOrStdItem.CheckDuplicateNameInDb(AIdOrFormatEstimate, AExcludeId: Variant; const AName, APrefixedName: string; out AMsg: string): Boolean;
//мандатная проверка в БД (см. общий комментарий в VerifyBeforeSave) - не занято ли наименование (простое -
//в or_std_items этой же подгруппы, и с префиксом - в ИТМ среди номенклатуры типа "материалы и комплектующие")
//каким-то ДРУГИМ (не AExcludeId) изделием. По смыслу и структуре сообщений - то же самое, что и старая,
//намеренно не тронутая проверка для 0-й вкладки (см. начало VerifyBeforeSave), но обобщено на произвольную
//подгруппу/имя/исключаемый id, чтобы использовать для любой сохраняемой вкладки.
var
  res1, res3: Integer;
begin
  Result := True;
  AMsg := '';
  res1 := Q.QLoadValue('select count(1) from or_std_items where id <> :id$i and id_or_format_estimates = :idf$i and name = :name$s',
    [S.IIf(S.NNum(AExcludeId) > 0, AExcludeId, -1), AIdOrFormatEstimate, AName]);
  res3 := Q.QLoadValue('select count(1) from dv.nomenclatura where id_nomencltype = 0 and name = :name$s', [APrefixedName]);
  if res1 + res3 > 0 then begin
    AMsg := S.IIf(res1 > 0, 'Такое наименование уже существует в этой группе стандартных изделий Учета!'#13#10, '') +
      S.IIf(res3 > 0, 'Такое наименование (с учетом префикса) уже есть в ИТМ среди номенклатуры типа "материалы и комплектующие"!'#13#10, '');
    Result := False;
  end;
end;

function TFrmODedtOrStdItem.CheckSemiproductNameConflicts(AExcludeId: Variant; const AName: string; out AErrorMsg, AWarningMsg: string): Boolean;
//см. общее требование пользователя (переписка): для полуфабрикатов "голое" (без префикса) наименование должно
//быть уникально среди ВСЕХ групп полуфабрикатов и нестандартных изделий - иначе жесткая ошибка (п.1). также
//жесткая ошибка, если оно совпадает с ПОЛНЫМ (с префиксом) наименованием какого-либо стандартного
//(производственного/отгрузочного) изделия (п.2) - именно по полному наименованию идентифицируются позиции и в
//bcad_nomencl, и в сметах, поэтому такое совпадение реально опасно. отдельно (НЕ блокируя) предупреждаем, если
//голое имя полуфабриката просто совпало с ГОЛЫМ (без префикса) именем какого-то стандартного изделия (п.3) - у
//стандартного изделия идентификация все равно только по полному имени, риска подмены нет, но стоит перепроверить.
//
//проверка ЗА ПРЕДЕЛАМИ своей подгруппы - совпадения ВНУТРИ своей подгруппы уже проверяются существующей (не
//тронутой) проверкой в начале VerifyBeforeSave (плюс уникальный индекс idx_or_std_items_name как страховка).
var
  LExcludeId: Variant;
  LRows: TVarDynArray2;
  i: Integer;
  LText: string;
begin
  Result := True;
  AErrorMsg := '';
  AWarningMsg := '';
  LExcludeId := S.IIf(S.NNum(AExcludeId) > 0, AExcludeId, -1);

  //п.1: совпадение голого имени с другой группой полуфабрикатов или с нестандартным изделием
  LRows := Q.QLoad(
    'select i.name, fe.type, fe.name as subgroup_name ' +
    'from or_std_items i join or_format_estimates fe on fe.id = i.id_or_format_estimates ' +
    'where i.id <> :excludeid$i and i.active = 1 and lower(trim(i.name)) = lower(trim(:name$s)) ' +
    'and ((fe.type = 2 and i.id_or_format_estimates <> :idgroup$i) or i.id_or_format_estimates = 0)',
    [LExcludeId, AName, FIdEstimateGroup]
  );
  if Length(LRows) > 0 then begin
    LText := '';
    for i := 0 to High(LRows) do
      if S.NNum(LRows[i][1]) = 2 then
        S.ConcatStP(LText, Format('- полуфабрикат "%s" (группа "%s")', [VarToStr(LRows[i][0]), VarToStr(LRows[i][2])]), #13#10)
      else
        S.ConcatStP(LText, Format('- нестандартное изделие "%s"', [VarToStr(LRows[i][0])]), #13#10);
    S.ConcatStP(AErrorMsg, 'Такое наименование (без учета регистра, без префикса) уже занято:'#13#10 + LText, #13#10);
    Result := False;
  end;

  //п.2: совпадение голого имени с ПОЛНЫМ (с префиксом) наименованием стандартного изделия
  LRows := Q.QLoad(
    'select i.name, fe.prefix, fo.name as format_name ' +
    'from or_std_items i join or_format_estimates fe on fe.id = i.id_or_format_estimates and fe.type in (0, 1) ' +
    'join or_formats fo on fo.id = fe.id_format ' +
    'where i.id <> :excludeid$i and i.active = 1 and lower(trim(fe.prefix || ''_'' || i.name)) = lower(trim(:name$s))',
    [LExcludeId, AName]
  );
  if Length(LRows) > 0 then begin
    LText := '';
    for i := 0 to High(LRows) do
      S.ConcatStP(LText, Format('- изделие "%s_%s" (формат "%s")', [VarToStr(LRows[i][1]), VarToStr(LRows[i][0]), VarToStr(LRows[i][2])]), #13#10);
    S.ConcatStP(AErrorMsg, 'Такое наименование совпадает с полным (с учетом префикса) наименованием стандартного изделия:'#13#10 + LText, #13#10);
    Result := False;
  end;

  //п.3: совпадение голого имени с ГОЛЫМ (без префикса) именем стандартного изделия - только предупреждение
  LRows := Q.QLoad(
    'select i.name, fe.prefix, fo.name as format_name ' +
    'from or_std_items i join or_format_estimates fe on fe.id = i.id_or_format_estimates and fe.type in (0, 1) ' +
    'join or_formats fo on fo.id = fe.id_format ' +
    'where i.id <> :excludeid$i and i.active = 1 and lower(trim(i.name)) = lower(trim(:name$s))',
    [LExcludeId, AName]
  );
  if Length(LRows) > 0 then begin
    LText := '';
    for i := 0 to High(LRows) do
      S.ConcatStP(LText, Format('- изделие "%s" (полное имя "%s_%s", формат "%s")',
        [VarToStr(LRows[i][0]), VarToStr(LRows[i][1]), VarToStr(LRows[i][0]), VarToStr(LRows[i][2])]), #13#10);
    AWarningMsg := 'Внимание: имя совпадает (без учета регистра) с "голым" (без префикса) именем стандартного изделия - само по себе это не ошибка, но стоит перепроверить:'#13#10 + LText;
  end;
end;

procedure TFrmODedtOrStdItem.UpdateSemiproductErrorsLabel;
var
  LErrorMsg, LWarningMsg: string;
begin
  lblSemiproductErrors.Visible := False;
  FSemiproductErrorsText := '';
  if (FItemType <> STDITEM_TYPE_SEMIPRODUCT) or not (Mode in [fView, fEdit]) or (S.NNum(ID) <= 0) then
    Exit;
  CheckSemiproductNameConflicts(ID, Trim(edt_name.Text), LErrorMsg, LWarningMsg);
  if LErrorMsg <> '' then
    S.ConcatStP(FSemiproductErrorsText, LErrorMsg, #13#10);
  if LWarningMsg <> '' then
    S.ConcatStP(FSemiproductErrorsText, LWarningMsg, #13#10);
  if FSemiproductErrorsText <> '' then begin
    lblSemiproductErrors.Caption := 'Есть ошибки!';
    lblSemiproductErrors.Visible := True;
  end;
end;

procedure TFrmODedtOrStdItem.lblSemiproductErrorsClick(Sender: TObject);
begin
  if FSemiproductErrorsText <> '' then
    MyWarningMessage(FSemiproductErrorsText);
end;

function TFrmODedtOrStdItem.SaveCounterpartTab(ATabIndex: Integer): Variant;
//сохраняет изделие парной вкладки ATabIndex (>0): если ранее было найдено совпадение по имени в этой
//подгруппе (FTabs[ATabIndex].DuplicateFound - см. CheckNameDuplicates/ApplyExistingItemToTabSlot) - обновляет
//НАЙДЕННУЮ существующую запись (цену/маршрут, и, если наименование успело разойтись - см. ниже - то и само
//наименование); иначе - создает НОВУЮ запись or_std_items в этой подгруппе. Использует тот же Q.QSave
//(insert/update по id, Sequence пустая строка - генерация id триггером trg_or_std_items_bi_r + returning), что
//и базовый механизм диалога (TFrmBasicDbDialog.Save) для самой 0-й вкладки - см. тот же прием там.
//
//ВАЖНО про by_sgp: это поле НИКОГДА не синхронизируется между вкладками (см. общий комментарий у FSyncFields) -
//для новой записи используется значение по умолчанию 0, для уже существующей (обновление) не трогается вовсе.
//
//ВАЖНО (исправлено - найдено по факту, см. переписку с пользователем): раньше наименование найденной записи
//считалось неизменным ("оно уже совпадает") - это было верно, пока CheckNameDuplicates переоценивала совпадение
//на каждое изменение edt_name. Теперь, в режиме редактирования, однажды найденная пара "закреплена" (см.
//общий комментарий в CheckNameDuplicates) и дальнейшее редактирование имени 0-й вкладки больше не сбрасывает
//найденное совпадение - вместо этого парное изделие должно быть ПЕРЕИМЕНОВАНО наравне с 0-й вкладкой. Поэтому
//name теперь всегда включено в UPDATE (безвредно, если имя не менялось - тогда просто перезапишется тем же).
//ВАЖНО (обобщено по просьбе пользователя - см. переписку): переименование полного (с префиксом ПОДГРУППЫ ЭТОЙ
//ЖЕ вкладки) наименования в ИТМ/bcad_nomencl теперь ТОЖЕ выполняется для парных вкладок, той же обработкой, что
//и для 0-й - см. RenameNomenclatura, вызывается из Save сразу после SaveCounterpartTab (не отсюда - этот метод
//сам по себе не знает "старое" имя записи после вызова, оно определяется в Save до вызова).
//
//Возвращает id сохраненного/созданного изделия, либо Null при ошибке (ошибка уже показана пользователем самим
//Q.QSave/QExecSql, см. их параметр ShowError по умолчанию True).
var
  LFields: string;
  LValues: TVarDynArray;
  i: Integer;
  LId, LRes: Variant;
begin
  Result := Null;
  if FTabs[ATabIndex].DuplicateFound and (FTabs[ATabIndex].DuplicateRow >= 0) then begin
    LId := FTabs[ATabIndex].ExistingNames[FTabs[ATabIndex].DuplicateRow][1];
    LFields := 'id$i;name$s;price_base$f;wo_estimate$i;r0$i';
    LValues := [LId, Trim(edt_name.Text), GetTabFieldValue(ATabIndex, 'price_base'), GetTabFieldValue(ATabIndex, 'wo_estimate'), GetTabFieldValue(ATabIndex, 'r0')];
    for i := 0 to High(RouteFields) do begin
      LFields := LFields + ';r' + IntToStr(i + 1) + '$i';
      LValues := LValues + [GetTabFieldValue(ATabIndex, 'r' + IntToStr(i + 1))];
    end;
    LRes := Q.QSave('U', 'or_std_items', '', LFields, LValues);
    if LRes < 0 then
      Exit;
    Result := LId;
  end
  else begin
    LFields := 'id$i;name$s;price_base$f;wo_estimate$i;r0$i;by_sgp$i;id_or_format_estimates$i';
    LValues := [Null, Trim(edt_name.Text), GetTabFieldValue(ATabIndex, 'price_base'), GetTabFieldValue(ATabIndex, 'wo_estimate'),
      GetTabFieldValue(ATabIndex, 'r0'), 0, FTabs[ATabIndex].IdOrFormatEstimate];
    for i := 0 to High(RouteFields) do begin
      LFields := LFields + ';r' + IntToStr(i + 1) + '$i';
      LValues := LValues + [GetTabFieldValue(ATabIndex, 'r' + IntToStr(i + 1))];
    end;
    LId := Q.QSave('I', 'or_std_items', '', LFields, LValues);
    if LId < 0 then
      Exit;
    Result := LId;
  end;
end;

procedure TFrmODedtOrStdItem.SyncOrderItemTemplates(ATabIndex: Integer; AId: Variant);
//устанавливает в шаблонах (order_items с псевдо-id_order - см. условие ниже) цену и маршрут изделий,
//соответствующих данному (AId) - было только для 0-й вкладки (в режиме редактирования), вынесено в общий метод,
//т.к. теперь применяется к КАЖДОМУ сохраняемому изделию (см. общий комментарий в начале Save) - при изменении
//цены/маршрута любого из них его шаблоны в заказах должны быть скорректированы точно так же (см. FOpt.InfoArray
//в Prepare - "по изделию", а не только по тому, что открыто в диалоге).
//
//Вызывается только для уже СУЩЕСТВОВАВШИХ изделий - для только что созданных шаблонов еще нет и быть не может.
var
  i: Integer;
  LSqlFields, LValues: TVarDynArray;
  LPlainFields: TVarDynArray;
begin
  if (ATabIndex = 0) and (Mode <> fEdit) then
    Exit;
  if (ATabIndex > 0) and not FTabs[ATabIndex].DuplicateFound then
    Exit;
  LSqlFields := ['price_base$f', 'r0$i'];
  LPlainFields := ['price_base', 'r0'];
  for i := 0 to High(RouteFields) do begin
    LSqlFields := LSqlFields + ['r' + IntToStr(i + 1) + '$i'];
    LPlainFields := LPlainFields + ['r' + IntToStr(i + 1)];
  end;
  LValues := [];
  for i := 0 to High(LPlainFields) do
    LValues := LValues + [GetTabFieldValue(ATabIndex, VarToStr(LPlainFields[i]))];
  Q.QExecSql(Q.QGetSql('Q', 'order_items', LSqlFields.Implode(';')) + ' where id_order < 0 and id_order > -100000 and id_std_item = :id_std_item$i', LValues + [AId]);
end;

procedure TFrmODedtOrStdItem.SetRoute;
var
  i: Integer;
begin
  if Mode in [fDelete, fView] then
    Exit;
  if (Cth.GetControlValue(chb_Wo_Estimate) = 1) or (Cth.GetControlValue(chb_R0) = 1) then
    for i := 0 to ComponentCount - 1 do
      if Copy(Components[i].name, 1, 5) = 'chb_r' then begin
        TDBCheckBoxEh(Components[i]).Checked := False;
        TDBCheckBoxEh(Components[i]).Enabled := False;
      end;
  if (Cth.GetControlValue(chb_Wo_Estimate) = 0) and (Cth.GetControlValue(chb_R0) = 0) then
    for i := 0 to ComponentCount - 1 do
      if Copy(Components[i].name, 1, 5) = 'chb_r' then begin
        TDBCheckBoxEh(Components[i]).Enabled := True;
      end;
  FIsRouteChanged := True;
end;

end.

{
  TODO (chb_OneOnly / Cth.CreateControls, Cth.AutoSizeCheckBoxes - uForms.pas):

  - Проверить автоширину чекбокса (TDBCheckBoxEh). Сейчас Cth.AutoSizeCheckBoxes фактически не подгоняет
    Width под текст на практике (по факту Width остаётся дефолтным - проверено, при полной подписи
    "Редактировать одно"/"Создать одно" текст обрезался) - при этом проверка типа "if not (c is
    TCustomCheckBox) then Continue" в uForms.pas была расширена до "... or (c is TDBCheckBoxEh)" (т.к.
    TDBCheckBoxEh не наследуется от TCustomCheckBox), но и это ничего не изменило. У TDBCheckBoxEh нет
    свойства AutoSize вообще (подтверждено компилятором) - значит автоширина для этого класса, если и
    работает где-то в проекте, реализована каким-то другим приёмом, не через AutoSize.
    Пока обходим проблему коротким текстом подписи ("Только одно" вместо двух длинных вариантов) - в
    дефолтную ширину чекбокса он помещается без подгонки.

  - В Cth.CreateControls (uForms.pas) добавить параметр Width: при 0 - использовать текущую дефолтную ширину
    (как сейчас), при -1 - автоматическую подгонку под текст. Судя по всему, для вручную созданных
    TDBCheckBoxEh автоширина где-то в проекте уже работает - см. как это сделано в uFrmOWOrder.pas
    ("wOrders") - разобрать этот пример и повторить тот же приём здесь.
    ВАЖНАЯ ЗАЦЕПКА: в uFrmOWOrder.pas вызов Cth.AutoSizeCheckBoxes(Self) сделан не в Prepare, а в
    AfterFormActivate (т.е. уже ПОСЛЕ показа формы и одноразового замера CorrectFormSize - см. тот же приём,
    что и с FTabsVisReady в этом модуле). Возможно, дело именно в моменте вызова: в Prepare (рано, контрол
    ещё может быть не до конца инициализирован - шрифт/размер шрифта через Font могут ещё не соответствовать
    реальному отображаемому) bmp.Canvas.TextWidth в AutoSizeCheckBoxes мог посчитать неверную (заниженную)
    ширину. Стоит попробовать перенести вызов для chb_OneOnly в AfterFormActivate по аналогии.

  - Для чекбоксов, создаваемых через CreateControls (в частности chb_OneOnly в этом модуле), по возможности
    переключить на автоширину по умолчанию, если удастся добиться, чтобы она действительно работала.
}


