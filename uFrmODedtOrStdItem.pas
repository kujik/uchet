{
Редактирование стандартного изделия.
В дополнительном параметре всегда передается айди сметной группы (id_or_format_estimates).
Редактировать цену можно только обладая правом на это.

ПЕРЕРАБОТАНО (см. задание пользователя и переписку по уточняющим вопросам): вкладки парных изделий с ручной
синхронизацией/пропуском (chb_TabSync/chb_TabNotCreate/chb_OneOnly, pgcFormat) убраны. Теперь для ЛЮБОЙ
группы форматов, КРОМЕ полуфабрикатов (для них поведение прежнее - см. ниже), синхронизация состава семейства
подгрупп ВСЕГДА обязательна и не отключаема:
- Наименование и поля маршрута (chb_R0/chb_Wo_Estimate/chb_r1..rN) относятся к производственному изделию и
  остаются ОДНИМ общим набором контролов на все семейство (без изменений по смыслу - как и раньше, эти же
  значения используются при сохранении любой строки семейства).
- Цена - ДЛЯ ЛЮБОГО типа подгруппы (произв./отгруз.), но теперь СВОЯ у каждой строки семейства (раньше цена
  была одним общим полем, синхронизируемым/копируемым между вкладками) - см. FRows/TCounterpartRow,
  LoadCounterpartRows. Под общими полями построчно, по одной строке на каждую активную подгруппу семейства
  (тот же id_format и sync_group, что у подгруппы, из которой открыт диалог - сама она тоже одна из строк, не
  отдельно) показываются: наименование подгруппы (с префиксом), Цена без НДС, Цена с НДС (пересчитываются друг
  в друга по ставке из общего комбобокса "Ставка НДС" cmb_nds_rate - см. тот же расчет, что и в справочнике
  стандартных изделий, Frg1CellValueSave/CbNdsRate в uFrmOGrefOrStdItems.pas; сама Цена с НДС нигде не хранится
  - чисто отображение/способ ввода), и, только для отгрузочных подгрупп - чекбокс "Учет по СГП" (тоже теперь
  свой у каждой такой строки, редактируется независимо).
Порядок строк - сначала производственная (если она входит в семейство), затем остальные по алфавиту (см.
LoadCounterpartRows); строка, из которой открыт диалог (FIdOrFormatEstimate), не обязательно первая - она
просто выделяется подчеркнутым шрифтом подписи.
При сохранении изделие создается/обновляется В КАЖДОЙ строке семейства безусловно - пропустить какую-то
подгруппу больше нельзя (см. переписку с пользователем - "приняли строгое соответствие состава групп"); цена
обязательна для каждой строки (пустая цена блокирует сохранение - см. VerifyBeforeSave).
Сопоставление строки семейства с уже существующим изделием в БД (создавать новое или обновлять найденное) - по
имени, ОДИН РАЗ при построении строк (LoadCounterpartRows), и только в режиме fEdit/fView/fDelete (по имени на
момент открытия диалога - FNameOld); далее это сопоставление закреплено до конца редактирования, независимо от
дальнейшего ввода в поле "Наименование" (как и в прежней версии - см. RenameNomenclatura/SaveRow). В режиме
добавления (fAdd/fCopy) сопоставление НЕ выполняется вовсе - совпадение имени с уже существующим изделием в
любой из подгрупп семейства теперь ошибка, блокирующая сохранение (см. VerifyBeforeSave), а не молчаливая
подстановка данных найденного изделия, как было раньше.
При удалении изделия - в ОДНОЙ пакетной транзакции (Q.QBeginTrans(True) - см. общий комментарий там же в
uDB.pas) удаляется само изделие и все найденные парные изделия семейства; при сбое любого из удалений вся
транзакция откатывается (см. Save, ветка Mode = fDelete).
Для полуфабрикатов (STDITEM_TYPE_SEMIPRODUCT) - интерфейс/проверки прежние: своего семейства подгрупп у них
нет (LoadCounterpartRows его и не строит - для полуфабриката всегда ровно одна строка, сама открытая
подгруппа), цена одна (без НДС - см. общий комментарий у CheckSemiproductNameConflicts).
Параметры вызова диалога (CallMode 1..4, AddParam) и логика их разбора - БЕЗ ИЗМЕНЕНИЙ, см. общий комментарий
в Prepare.

ВРЕМЕННО, на период миграции данных - для пользователей с правом "администратор данных" (User.IsDataEditor)
доступен чекбокс "Только одно" (chb_SingleItemOnly, создается динамически, только если есть это право, и не в
fView) в режимах fAdd/fCopy/fEdit/fDelete. При включении семейная синхронизация (см. выше) отключается ПОЛНОСТЬЮ -
LoadCounterpartRows строит FRows из ОДНОЙ строки (сама открытая подгруппа), точно как для полуфабрикатов - поэтому
ВСЕ дальнейшие механизмы, завязанные на перебор FRows (сохранение остальных строк, DeleteFamilyItems, плановый
список подтверждения LPlanText и т.п.), автоматически не затрагивают никакие парные изделия семейства - отдельный
код для этого не потребовался. Переименование САМОГО изделия в номенклатуре ИТМ и в справочнике сметных позиций
(RenameNomenclatura) при этом выполняется как обычно - оно всегда было привязано только к одной, редактируемой
записи, а не к семейству. Поскольку обычный диалог подтверждения (LPlanText) в этом режиме ничего не покажет про
пропущенные парные изделия (их просто нет в FRows), при каждом нажатии ОК с отмеченной галкой отдельно
переспрашивается явное предупреждение (см. начало VerifyBeforeSave). УДАЛИТЬ ПОСЛЕ ЗАВЕРШЕНИЯ МИГРАЦИИ - сам
чекбокс, поле chb_SingleItemOnly и все связанные с ним проверки (искать по имени chb_SingleItemOnly).

ЧЕТЫРЕ ПОПРАВКИ (по факту тестирования):
1) Поля маршрута/"без сметы"/"без маршрута" (chb_Wo_Estimate/chb_R0/chb_r1..N) относятся ТОЛЬКО к
производственному изделию семейства (см. выше), но базовый механизм диалога (F.DefineFields) загружает их
напрямую из записи, физически открытой по ID - т.е. если диалог открыт на ОТГРУЗОЧНОЙ подгруппе, показывались бы
собственные (у отгрузочных изделий всегда 0 - см. SaveRow/Save) значения ЭТОГО изделия, а не реальный маршрут
производственного. Исправлено отдельной, самостоятельной подстановкой ПОСЛЕ обычной загрузки - см.
LoadRouteFromProductionItem (вызывается из Prepare сразу после повторного LoadCounterpartRows). Поскольку запрос
не использует FRows, поправка продолжает работать и при включенной галке "Только одно" (chb_SingleItemOnly) -
FRows в этом режиме намеренно ограничен одной строкой, но производственное изделие семейства ищется отдельным,
не зависящим от FRows запросом.
2) SaveRow (сохранение остальных строк семейства, НЕ FSourceRowIndex) сохранял новое наименование в саму таблицу
or_std_items, но не вызывал RenameNomenclatura - в отличие от Save, который вызывает ее только для
FSourceRowIndex. Из-за этого при переименовании, открытом со стороны ОТГРУЗОЧНОЙ подгруппы (когда сама
production-строка сохраняется как сиблинг именно в SaveRow), запись в bcad_nomencl для производственного
изделия не переименовывалась - и последующая CheckSelfSmetaAction ошибочно сообщала, что уже верная смета
"не соответствует ожидаемой" (она продолжала ссылаться на старое имя). Исправлено - SaveRow теперь тоже вызывает
RenameNomenclatura при изменении имени сохраняемой строки.
3) Общие чекбоксы маршрута (chb_Wo_Estimate/chb_R0/chb_r1..N), хоть и показывают (см. п.1 выше) реальный маршрут
производственного изделия, оставались доступны для редактирования и при открытой ОТГРУЗОЧНОЙ строке - хотя
изменить там ничего фактически нельзя (при сохранении отгрузочного изделия они принудительно обнуляются, см.
Save/SaveRow), что вводило в заблуждение. Исправлено в SetRowsControlsState - при открытой отгрузочной строке
семейства эти чекбоксы теперь принудительно недоступны (Enabled = False).
4) (Найдено при проверке поправки 3 - реальный, более серьезный баг.) SaveRow (сохранение остальных строк
семейства, НЕ FSourceRowIndex) и SyncOrderItemTemplates при сохранении ПРОИЗВОДСТВЕННОЙ строки как "соседа"
(т.е. когда диалог открыт на ОТГРУЗОЧНОЙ подгруппе) брали значения маршрута из общих чекбоксов формы - а они, с
учетом поправки 1/3, в этом случае лишь ОТОБРАЖАЮТ реальный маршрут и заблокированы для редактирования; при
любом сохранении, вызванном переименованием/изменением цены со стороны отгрузочной подгруппы, это приводило к
перезаписи (фактически обнулению или порче) реального маршрута производственного изделия в БД. Исправлено:
SaveRow при ОБНОВЛЕНИИ существующего производственного изделия как соседа теперь вообще не включает поля
маршрута в SQL (оставляет как есть в БД); значения из чекбоксов там больше не участвуют. Аналогично
SyncOrderItemTemplates не трогает маршрут в шаблонах заказов для производственной строки-соседа. Поля маршрута
из чекбоксов используются в SaveRow только при СОЗДАНИИ нового производственного изделия впервые именно отсюда -
и то не из чекбоксов, а жестким нулем (маршрут в этом случае еще не задан нигде, задается позже, при
редактировании самого производственного изделия).
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
  //одна строка семейства синхронизации (произв./отгруз.) - см. общий комментарий в начале модуля и
  //LoadCounterpartRows. FRows[FSourceRowIndex] - сама редактируемая/добавляемая подгруппа (FIdOrFormatEstimate) -
  //не обязательно первая строка по порядку (см. IsSource/порядок построения строк в LoadCounterpartRows).
  TCounterpartRow = record
    IdOrFormatEstimate: Variant;
    ItemType: Integer;
    IsSource: Boolean;
    //Null - изделия с текущим именем (FNameOld, только фиксируется в fEdit/fView/fDelete - см. общий комментарий
    //в начале модуля) в этой подгруппе еще нет, будет создано новое; иначе - id найденного изделия (для
    //IsSource - это ID диалога в fEdit/fView/fDelete, всегда Null в fAdd/fCopy)
    ExistingId: Variant;
    //имя/цена/учет по СГП найденного изделия (снимок на момент загрузки, ExistingId <> Null) - используются
    //и для подстановки начальных значений строки, и для RowNeedsSave (не дергать БД впустую, если ничего не
    //поменялось), и для переименования при сохранении (см. Save/RenameNomenclatura)
    ExistingName: string;
    ExistingPriceBase: Variant;
    ExistingBySgp: Integer;
    LblCaption: TLabel;                 //подпись строки - "Формат [Подгруппа]" (подчеркнута, если IsSource)
    NEdtPriceBase: TDBNumberEditEh;     //Цена без НДС - для IsSource это тот же контрол, что и nedt_price_base
    NEdtPriceWithVat: TDBNumberEditEh;  //Цена с НДС - нигде не хранится, см. общий комментарий в начале модуля
    ChbBySgp: TDBCheckBoxEh;            //только для отгрузочных строк (ItemType = STDITEM_TYPE_SHIPMENT), иначе nil
  end;

  TFrmODedtOrStdItem = class(TFrmBasicDbDialog)
    cmb_id_or_format_estimates: TDBComboBoxEh;
    edt_prefix: TDBEditEh;
    edt_name: TDBEditEh;
    chb_R0: TDBCheckBoxEh;
    chb_Wo_Estimate: TDBCheckBoxEh;
    nedt_price_base: TDBNumberEditEh;
    lblSemiproductErrors: TLabel;
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
    //в CreateSemiproductFromRow, uFrmOGedtEstimate.pas). ВАЖНО: сами эти режимы вызова и разбор параметров НЕ
    //затронуты переделкой (см. общий комментарий в начале модуля) - без изменений с прежней версии.
    FCallMode: Integer;
    //наименование по умолчанию - необязательный третий элемент AddParam (см. общий комментарий у FCallMode) -
    //подставляется в поле "Наименование" при добавлении (Mode = fAdd), пользователь может его изменить; для
    //старых вызовов (AddParam из двух элементов) остается пустым - см. разбор в начале Prepare
    FDefaultName: string;
    //группа (id_format) и тип (см. STDITEM_TYPE_* в uOrders) переданной (исходной) подгруппы - см. LoadCbFormatEstimates
    FIdFormat: Variant;
    FItemType: Integer;
    //строки семейства синхронизации (см. TCounterpartRow) и индекс строки самой открытой подгруппы в FRows
    //(FIdOrFormatEstimate) - см. общий комментарий там же про порядок построения строк
    FRows: array of TCounterpartRow;
    FSourceRowIndex: Integer;
    //список полей маршрута (через ;), которые одинаковы для ВСЕХ строк семейства (одни общие контролы на всю
    //форму - см. общий комментарий в начале модуля); цена сюда больше не входит (теперь своя у каждой строки)
    FRouteSyncFields: string;
    //комбобокс "Ставка НДС" (как в заголовке справочника стандартных изделий - см. CbNdsRate в
    //uFrmOGrefOrStdItems.pas) - создается динамически (см. общий комментарий у chb_OneOnly в прежней версии
    //модуля про приватные методы/DFM streaming), общий на все строки - см. LoadCounterpartRows/NdsRateChange
    cmb_nds_rate: TDBComboBoxEh;
    FNdsRates: TVarDynArray;
    //ВРЕМЕННО, на период миграции данных (см. общий комментарий в начале модуля) - создается только если
    //User.IsDataEditor и Mode <> fView (см. Prepare); не Assigned для обычных пользователей - это и есть
    //ограничение доступности. УДАЛИТЬ ПОСЛЕ ЗАВЕРШЕНИЯ МИГРАЦИИ вместе со всеми проверками Assigned(...) по
    //этому полю (LoadCounterpartRows/ControlOnChange/VerifyBeforeSave/Prepare).
    chb_SingleItemOnly: TDBCheckBoxEh;
    //признак программной установки значения цены (см. RecalcRowPriceWithVat/RecalcRowPriceBase/NdsRateChange) -
    //не даёт зациклиться на взаимных OnChange двух контролов одной строки при пересчете
    FUpdatingPrice: Boolean;
    function  Prepare: Boolean; override;
    procedure AfterFormActivate; override;
    procedure ControlOnChange(Sender: TObject); override;
    function  VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean; override;
    //заполняет комбобокс Формат по правилам, зависящим от типа исходной подгруппы (FItemType) - см. реализацию.
    //БЕЗ ИЗМЕНЕНИЙ с прежней версии.
    procedure LoadCbFormatEstimates;
    //обновляет FPrefix и поле "Префикс" по текущему значению, выбранному в комбобоксе Формат. БЕЗ ИЗМЕНЕНИЙ.
    procedure SetPrefixByFormat;
    //пересоздает строки семейства синхронизации (FRows) по коду синхронизации (or_format_estimates.sync_group) -
    //см. подробный комментарий у реализации и общий комментарий в начале модуля
    procedure LoadCounterpartRows;
    //подставляет в общие чекбоксы маршрута/"без сметы"/"без маршрута" (chb_Wo_Estimate/chb_R0/chb_r1..N) реальные
    //значения ИЗ ПРОИЗВОДСТВЕННОГО изделия семейства - эти поля имеют смысл только для него (см. общий
    //комментарий в начале модуля: группы отгрузочных изделий - лишь хранилища цены для его вариантов), поэтому
    //подставляются независимо от того, какая подгруппа физически открыта, и независимо от FRows/chb_SingleItemOnly
    //(отдельный, самостоятельный запрос - продолжает корректно работать и во временном режиме миграции "Только
    //одно", когда FRows намеренно ограничен одной строкой - см. подробности у реализации). Ничего не делает для
    //полуфабрикатов (для них эти поля - собственные, обычная загрузка через F.DefineFields верна) и при
    //добавлении новой записи (FNameOld = '' - производственного изделия для сопоставления по имени еще нет).
    procedure LoadRouteFromProductionItem;
    //создает (один раз, если еще не создан) комбобокс "Ставка НДС" (cmb_nds_rate) - список значений тот же,
    //что и в заголовке справочника (см. CbNdsRate/FNdsRates в uFrmOGrefOrStdItems.pas)
    procedure CreateNdsRateCombo;
    procedure NdsRateChange(Sender: TObject);
    //создает подпись+два поля цены (+чекбокс "Учет по СГП" для отгрузочных) для строки семейства ARowIndex,
    //на позиции AT op (Y); подставляет начальные значения (найденное изделие либо пусто/0 для нового)
    procedure CreateRowControls(ARowIndex, ATop: Integer);
    procedure RecalcRowPriceWithVat(ARowIndex: Integer);
    procedure RecalcRowPriceBase(ARowIndex: Integer);
    procedure RowPriceBaseChange(Sender: TObject);
    procedure RowPriceWithVatChange(Sender: TObject);
    //блокировка/разблокировка полей строк семейства (право на изменение цены, режим просмотра/удаления) - и
    //живая подсветка (только в fAdd/fCopy) строк, чье имя уже занято в БД - см. подробности у реализации
    procedure SetRowsControlsState;
    //только для fAdd/fCopy (см. общий комментарий в начале модуля) - живая (по текущему тексту edt_name, с
    //обращением к БД - в отличие от прежней версии, где для этого держался предзагруженный в память список;
    //здесь не держим, т.к. подстановки данных найденного изделия больше нет, только предупреждение) подсветка
    //строк семейства, чье имя уже занято каким-то ДРУГИМ изделием в этой подгруппе - см. VerifyAdd
    procedure UpdateAddDuplicateMarkers;
    //проверяет состояние сметы ОТГРУЗОЧНОГО изделия (см. общий комментарий у реализации/у CreateSelfSmeta про
    //смену модели - смета создается для отгрузочных изделий и ссылается на производственное, а не наоборот).
    //AIdShipmentItem - id отгрузочного изделия, для которого проверяется смета (Null, если оно еще не
    //сохранено - новое). AIdProductionItem - id (уже сохраненного к этому моменту) производственного изделия,
    //на которое должна ссылаться единственная позиция сметы. Возвращает 0 (ничего не требуется), 1 (требуется
    //создание), 2 (смета уже есть, но отличается - только предупреждаем, не трогаем); ADetails - текст для
    //диалога подтверждения/предупреждения. БЕЗ ИЗМЕНЕНИЙ с прежней версии.
    function CheckSelfSmetaAction(AIdShipmentItem, AIdProductionItem: Variant; const AShipmentDisplayName, AProductionPrefixedName: string; out ADetails: string): Integer;
    //создает смету отгрузочного изделия (см. CheckSelfSmetaAction) через Orders.ApplyEstimateArray - единственная
    //позиция ссылается на производственное изделие (по имени через bcad_nomencl И по id через id_or_std_item).
    //ВАЖНО: открывает и коммитит/откатывает СВОЮ отдельную транзакцию (см. TOrders.ApplyEstimateArray) - вызывать
    //только ПОСЛЕ фиксации (Q.QCommitTrans) собственной транзакции сохранения изделий, см. комментарий в Save.
    //БЕЗ ИЗМЕНЕНИЙ с прежней версии.
    procedure CreateSelfSmeta(AIdShipmentItem, AIdProductionItem: Variant; const AProductionPrefixedName: string);
    //нужна ли строке ARowIndex (не IsSource) РЕАЛЬНАЯ запись в БД - см. подробности у реализации (то же по
    //смыслу, что и прежний CounterpartTabNeedsSave, но проще - синхронизация теперь безусловна, сравнение идет
    //просто с ExistingXxx-снимком строки, без индирекции через активную вкладку/слоты)
    function RowNeedsSave(ARowIndex: Integer): Boolean;
    //наименование с префиксом подгруппы AIdOrFormatEstimate. БЕЗ ИЗМЕНЕНИЙ.
    function GetPrefixedName(AIdOrFormatEstimate: Variant; const AName: string): string;
    //переименовывает полное (с префиксом подгруппы) наименование в ИТМ (dv.nomenclatura) и bcad_nomencl - общим
    //методом для любой сохраняемой строки. БЕЗ ИЗМЕНЕНИЙ по смыслу с прежней версии.
    procedure RenameNomenclatura(AIdOrFormatEstimate: Variant; const AOldName, ANewName: string; AItemType: Integer);
    //текст для диалога подтверждения, ЗАРАНЕЕ предсказывающий, что сделает RenameNomenclatura. БЕЗ ИЗМЕНЕНИЙ.
    function GetNomenclaturaRenamePlanText(AIdOrFormatEstimate: Variant; const AOldName, ANewName: string; AItemType: Integer): string;
    //мандатная (обязательная для каждого сохраняемого изделия) проверка в БД, не занято ли имя (простое/с
    //префиксом) каким-то ДРУГИМ изделием. БЕЗ ИЗМЕНЕНИЙ.
    function CheckDuplicateNameInDb(AIdOrFormatEstimate, AExcludeId: Variant; const AName, APrefixedName: string; out AMsg: string): Boolean;
    //только для полуфабрикатов - проверка "голого" (без префикса) имени AName на конфликты ЗА ПРЕДЕЛАМИ своей
    //подгруппы. БЕЗ ИЗМЕНЕНИЙ.
    function CheckSemiproductNameConflicts(AExcludeId: Variant; const AName: string; out AErrorMsg, AWarningMsg: string): Boolean;
    //для полуфабрикатов в режиме fView/fEdit - прогоняет CheckSemiproductNameConflicts. БЕЗ ИЗМЕНЕНИЙ.
    procedure UpdateSemiproductErrorsLabel;
    //сохраняет изделие строки ARowIndex (не IsSource) - см. подробности у реализации. Возвращает id
    //сохраненного/созданного изделия, либо Null при ошибке сохранения.
    function SaveRow(ARowIndex: Integer): Variant;
    //удаляет (в уже открытой пакетной транзакции - см. Save, ветка Mode = fDelete) изделия всех найденных строк
    //семейства, КРОМЕ строки FSourceRowIndex (её удаляет сам базовый механизм диалога, inherited Save)
    procedure DeleteFamilyItems;
    //синхронизирует цену/маршрут в шаблонах заказов (order_items с псевдо-id_order) для изделия AId строки
    //ARowIndex. Адаптировано под чтение цены из собственного контрола строки вместо GetTabFieldValue.
    procedure SyncOrderItemTemplates(ARowIndex: Integer; AId: Variant);
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
  //геометрия построчного списка семейства (см. CreateRowControls) - высота одной строки и координаты столбцов
  //(наименование подгруппы / Цена без НДС / Цена с НДС / Учет по СГП), считая от левого края pnlFrmClient
  cRowHeight = 27;
  cRowLblLeft = 8;
  cRowLblWidth = 300;
  cRowPriceBaseLeft = 320;
  cRowPriceWidth = 104;
  cRowPriceWithVatLeft = 440;
  cRowBySgpLeft = 560;

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

  //при вызове НЕ из справочника (uFrmOGrefOrStdItems), где исходная подгруппа заведомо не известна вызывающему
  //коду (передан Null/0) и известен только сам AId - подгруппу резолвим сами, простым запросом по AId
  if (Mode in [fEdit, fView, fDelete]) and (S.NNum(FIdOrFormatEstimate) <= 0) and (S.NNum(ID) > 0) then
    FIdOrFormatEstimate := Q.QLoadValue('select id_or_format_estimates from or_std_items where id = :id$i', [ID]);

  //группа форматов (id_format) и тип (О/П/ПФ) исходной подгруппы нужны для формирования списка комбобокса
  //Формат (см. LoadCbFormatEstimates); делаем это до вызова inherited, т.к. в режиме редактирования inherited
  //сразу загружает из БД и устанавливает в комбобокс текущее значение поля id_or_format_estimates, а список
  //комбобокса должен быть заполнен заранее, иначе значение не отобразится.
  //Для CallMode = 3 переданная подгруппа может отсутствовать (Null/0) - тогда группу/тип изначально не знаем,
  //определятся уже по факту выбора пользователем в комбобоксе (см. ControlOnChange); до этого момента считаем
  //тип "неизвестным" (не полуфабрикатом).
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

  //список полей маршрута, общих для ВСЕХ строк семейства (цена сюда больше не входит - см. общий комментарий в
  //начале модуля); порядок соответствует порядку создания chb_r1..rN ниже
  FRouteSyncFields := 'wo_estimate;r0';
  for i := 0 to High(RouteFields) do
    FRouteSyncFields := FRouteSyncFields + ';r' + IntToStr(i + 1);

  for i := 0 to High(RouteFields) do begin
    Cth.CreateControls(pnlFrmClient, cntCheck, RouteFields[i], 'chb_r' + IntToStr(i + 1), '', 0, edt_name.Left + i * 50, edt_name.Top + edt_name.Height + MY_FORMPRM_H_EDGES);
    TDBCheckBoxEh(Self.FindComponent('chb_r' + IntToStr(i + 1))).Caption := RouteFields[i];
    va2 :=  va2 + [['r' + IntToStr(i + 1) + '$i']];
  end;

  //строки семейства синхронизации (FRows) и комбобокс "Ставка НДС" - создаются здесь, ДО inherited (тот же
  //прием, что и для chb_r1..rN выше), чтобы базовый механизм диалога (SetControlsEditable в
  //TFrmBasicDbDialog.Prepare) сразу корректно выставил им начальную доступность по режиму - см. общий
  //комментарий в начале модуля. cmb_nds_rate создаем один раз здесь; сами строки (и цена nedt_price_base -
  //единственное поле цены, которое остается в F.DefineFields, см. ниже) пересоздаются в LoadCounterpartRows,
  //в т.ч. повторно из ControlOnChange при смене подгруппы в режиме добавления/копирования.
  //ВРЕМЕННО (период миграции) - см. общий комментарий у поля chb_SingleItemOnly. Создаем ДО первого вызова
  //LoadCounterpartRows ниже (как и chb_r1..rN выше), чтобы к моменту его первого выполнения контрол уже
  //существовал; по умолчанию не отмечен - обычное поведение с полной синхронизацией семейства не меняется.
  //Не создается вовсе для пользователей без права "администратор данных" и в режиме fView (там нечего сохранять) -
  //это и есть ограничение доступности (см. также комментарий про доступность/Enabled чуть ниже, после inherited).
  if User.IsDataEditor and (Mode <> fView) then begin
    chb_SingleItemOnly := TDBCheckBoxEh(Cth.CreateControls(pnlFrmClient, cntCheck,
      'Только одно (без связи с группой, миграция)', 'chb_SingleItemOnly', '', 0, 300, 182));
    chb_SingleItemOnly.Width := 320;
  end;

  CreateNdsRateCombo;
  LoadCounterpartRows;

  F.DefineFields:=[
    ['id$i'],
    ['name$s','V=1:400::T'],
    ['price_base$f','V=0:9999999:2:n'],
    ['wo_estimate$i'],
    ['r0$i'],
    ['id_or_format_estimates$i','V=1:400:1']
  ] + va2;

  View := 'v_or_std_items';
  Table := 'or_std_items';
  FOpt.UseChbNoClose:= True;
  //подсказки пользователю (иконка Info) - разные тексты для разных режимов вызова диалога
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
     'При изменении маршрута они будут скорректированы во всех шаблонах паспортов заказов.'#13#10,
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
    ['Если для этой подгруппы настроена хотя бы одна парная подгруппа (произв./отгруз.) в той же группе'#13#10 +
     'форматов, ниже появляются дополнительные строки - по одной на каждую подгруппу семейства (сначала'#13#10 +
     'производственная, затем по алфавиту; строка, из которой открыт диалог, подчеркнута). У каждой строки'#13#10 +
     'своя цена (без/с НДС - пересчитываются друг в друга по ставке из поля "Ставка НДС"); у отгрузочных строк'#13#10 +
     'также свой чекбокс "Учет по СГП". При сохранении изделие создается/обновляется во ВСЕХ строках семейства'#13#10 +
     'одновременно - пропустить какую-то подгруппу нельзя. Если в какой-то подгруппе уже есть изделие с таким'#13#10 +
     'именем - при редактировании это и есть искомая парная запись (будет обновлена/переименована наравне с'#13#10 +
     'текущей), при ДОБАВЛЕНИИ - это ошибка, сохранение будет заблокировано.'#13#10 +
     'При сохранении отгрузочного изделия в паре с производственным, если у отгрузочного еще нет сметы, она'#13#10 +
     'создается автоматически - из одной позиции со ссылкой на связанное производственное изделие.'#13#10,
     (FItemType <> STDITEM_TYPE_SEMIPRODUCT) and (Mode <> fDelete)]
  ];

  //форма сделана горизонтально растягиваемой, но НЕ вертикально - логика расположения контролов не рассчитана
  //на вертикальное растягивание (см. также общий комментарий в прежней версии модуля)
  FWHBounds.Y2 := -1;
  Result := inherited;
  if not Result then
    Exit;
  //доступность выбора подгруппы (и синхронно с ней - поля префикса, оно всегда только отображает префикс
  //выбранной подгруппы, см. SetPrefixByFormat) - как в прежней версии с вкладками. Важно делать это ПОСЛЕ
  //inherited: базовый Prepare (см. SetControlsEditable([], Mode in [fEdit, fCopy, fAdd]) в uFrmBasicDbDialog/
  //uFrmBasicInput) сам разблокирует все контролы по режиму - если выставить .Enabled раньше, inherited его
  //перезатрет. По той же причине используем SetControlsEditable (как и базовый метод), а не .Enabled напрямую -
  //иначе не синхронизируется состояние кнопки выбора у DBEditEh/визуальный стиль "недоступно":
  //- при вызове ИЗ справочника (FCallMode = 1 - см. общий комментарий у FCallMode) подгруппа/префикс - это
  //  ВСЕГДА текущая (переданная) подгруппа, выбор недоступен ни в одном режиме, включая добавление - в
  //  справочнике подгруппа уже выбрана до открытия диалога (см. Frg1CellValueSave/CbEstimate,
  //  uFrmOGrefOrStdItems.pas);
  //- при вызове НЕ из справочника, только на добавление (FCallMode = 2/3/4), подгруппу можно выбрать - для
  //  ПФ это два разных варианта (FCallMode = 4 - только среди подгрупп ПФ; FCallMode = 3 - среди подгрупп
  //  любого типа, включая ПФ), как было ранее; см. также LoadCbFormatEstimates - вне добавления/копирования
  //  в списке остается только одна, текущая строка
  SetControlsEditable([cmb_id_or_format_estimates, edt_prefix], (Mode in [fAdd, fCopy]) and (FCallMode <> 1));
  //ВРЕМЕННО (период миграции) - см. общий комментарий у поля chb_SingleItemOnly. Ту же поправку, что и выше
  //(ставить ПОСЛЕ inherited, иначе базовый Prepare/SetControlsEditable задизейблит), применяем и здесь: чекбокс
  //должен оставаться доступным даже в fDelete/fCopy/fView (fView он вообще не создан) - именно в fDelete как
  //раз и есть основной смысл этой временной функции.
  if Assigned(chb_SingleItemOnly) then
    SetControlsEditable([chb_SingleItemOnly], True);
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
    //перезагрузим строки семейства теперь, когда F готов и в него загружено реальное имя/цена (в момент
    //первого вызова LoadCounterpartRows выше, до inherited, F.GetPropB('name')/nedt_price_base еще не были
    //заполнены данными записи - строка FSourceRowIndex тогда создавалась с пустыми начальными значениями)
    LoadCounterpartRows;
    //поправка по факту тестирования - см. общий комментарий у LoadRouteFromProductionItem: чекбоксы маршрута
    //должны всегда отражать производственное изделие семейства, а не то, что физически загрузил inherited по ID
    //открытой записи (актуально, если диалог открыт на отгрузочной подгруппе)
    LoadRouteFromProductionItem;
  end;
  SetRoute;
  SetRowsControlsState;
end;

procedure TFrmODedtOrStdItem.ControlOnChange(Sender: TObject);
var
  va: TVarDynArray;
begin
  if (A.InArray(TControl(Sender).Name, ['chb_R0', 'chb_Wo_Estimate'])) or (Copy(TControl(Sender).Name, 1, 6) = 'chb_r') then
    SetRoute;
  if TControl(Sender).Name = 'cmb_id_or_format_estimates' then begin
    SetPrefixByFormat;
    //подгруппа сменилась (возможно только в режиме добавления/копирования - в остальных комбобокс задизейблен) -
    //пересчитаем состав строк семейства по новой подгруппе (у нее может быть другой id_format/sync_group)
    FIdOrFormatEstimate := Cth.GetControlValue(cmb_id_or_format_estimates);
    va := Q.QLoadRow('select id_format, type from or_format_estimates where id = :id$i', [FIdOrFormatEstimate]);
    FIdFormat := va[0];
    FItemType := S.NInt(va[1]);
    LoadCounterpartRows;
    SetRoute;
    SetRowsControlsState;
  end;
  //ВРЕМЕННО (период миграции) - см. общий комментарий у поля chb_SingleItemOnly. Переключение галки должно
  //живьем перестраивать состав FRows (в обе стороны - и включение, и снятие галки), точно так же, как это уже
  //делает смена подгруппы в комбобоксе Формат выше.
  if Assigned(chb_SingleItemOnly) and (TControl(Sender).Name = 'chb_SingleItemOnly') then begin
    LoadCounterpartRows;
    SetRoute;
    SetRowsControlsState;
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
//БЕЗ ИЗМЕНЕНИЙ с прежней версии модуля.
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
//в комбобоксе Формат. БЕЗ ИЗМЕНЕНИЙ с прежней версии модуля.
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

procedure TFrmODedtOrStdItem.CreateNdsRateCombo;
//создает (один раз) комбобокс "Ставка НДС" - тот же список значений, что и в заголовке справочника стандартных
//изделий (см. CbNdsRate в uFrmOGrefOrStdItems.pas): ставки продавцов (ref_sn_organizations.nds_rate, is_seller
//= 1) плюс 0%. Позиционируется на месте, где раньше была статичная (см. .dfm) метка цены - теперь единственное
//поле цены на форме без привязки к строке семейства (nedt_price_base) само стало частью построчного списка
//(см. LoadCounterpartRows/CreateRowControls), поэтому строка "Ставка НДС" идет отдельно, над этим списком.
begin
  if Assigned(cmb_nds_rate) then
    Exit;
  //дедупликация и сортировка - как в заголовке справочника стандартных изделий (см. CbNdsRate,
  //uFrmOGrefOrStdItems.pas, FNdsRates)
  FNdsRates := Q.QLoadCol('select nds_rate from ref_sn_organizations where is_seller = 1', []) + [0];
  FNdsRates := A.RemoveDuplicates(FNdsRates);
  FNdsRates.SortP(True);
  cmb_nds_rate := TDBComboBoxEh(Cth.CreateControls(pnlFrmClient, cntComboLK, 'Ставка НДС:', 'cmb_nds_rate', '', 0,
    nedt_price_base.Left, nedt_price_base.Top));
  Cth.AddToComboBoxEh(cmb_nds_rate, FNdsRates, []);
  cmb_nds_rate.LimitTextToListValues := True;
  cmb_nds_rate.Width := 80;
  if cmb_nds_rate.Items.Count > 0 then
    cmb_nds_rate.ItemIndex := 0;
  cmb_nds_rate.OnChange := NdsRateChange;
  //прежнее поле цены (со своей меткой "Цена (без НДС)") больше не используется как отдельная подпись - теперь
  //это просто poле цены строки FSourceRowIndex (см. CreateRowControls), подпись строки - отдельная динамическая
  //метка (LblCaption), как и у остальных строк семейства
  nedt_price_base.ControlLabel.Visible := False;
end;

procedure TFrmODedtOrStdItem.NdsRateChange(Sender: TObject);
//смена ставки НДС - по просьбе пользователя пересчитываем "Цена с НДС" по ВСЕМ строкам семейства заново (цена
//без НДС остается как есть, она первична)
var
  i: Integer;
begin
  for i := 0 to High(FRows) do
    RecalcRowPriceWithVat(i);
end;

procedure TFrmODedtOrStdItem.LoadCounterpartRows;
//пересоздает строки семейства синхронизации (FRows) - подгруппы того же id_format (FIdFormat), того же кода
//синхронизации (or_format_estimates.sync_group), что и у исходной подгруппы (FIdOrFormatEstimate), ЛЮБОГО типа
//О/П (произв./отгруз., включая саму исходную подгруппу - в отличие от прежней версии, где парные вкладки
//строились ОТДЕЛЬНО от "своей" 0-й вкладки, здесь один запрос сразу возвращает все строки семейства, включая
//исходную); sync_group = 0 у исходной подгруппы означает, что синхронизация для нее не предлагается вообще
//(строка будет только одна - сама исходная подгруппа); учитываются только активные (active=1) подгруппы.
//Полуфабрикаты (тип STDITEM_TYPE_SEMIPRODUCT) в семействах не участвуют вовсе - для них всегда ровно одна
//строка (сама исходная подгруппа), без обращения к sync_group - см. общий комментарий в начале модуля.
//
//Порядок строк - см. общий комментарий в начале модуля: сначала производственная (если есть в семействе),
//затем остальные по алфавиту (order by ниже) - НЕ обязательно совпадает с тем, какая строка соответствует
//исходной подгруппе (FSourceRowIndex просто указывает на нужный элемент FRows, где бы он ни оказался).
//
//Сопоставление с уже существующим изделием (ExistingId/ExistingName/ExistingPriceBase/ExistingBySgp) - только
//в fEdit/fView/fDelete, по имени FNameOld (см. общий комментарий в начале модуля); в fAdd/fCopy сопоставление
//не выполняется (ExistingId всегда Null) - совпадение имени в этих режимах проверяется отдельно, как ошибка
//(см. VerifyBeforeSave/UpdateAddDuplicateMarkers).
//
//Вызывается из Prepare (дважды - см. комментарий там же), а также повторно из ControlOnChange при смене выбора
//в комбобоксе Формат (только в режиме добавления/копирования).
var
  i: Integer;
  va2: TVarDynArray2;
  LFound: TVarDynArray;
  LSyncGroup: Variant;
  LTop: Integer;
  LOldPriceBase, LOldPriceWithVat: Variant;
  LHadOldPrice: Boolean;
begin
  //запомним текущую (уже введенную пользователем) цену строки FSourceRowIndex - переживет пересоздание строк
  //при смене подгруппы в комбобоксе Формат (см. общий комментарий выше); при первом вызове (из Prepare, до
  //того как F заполнен реальными данными) строк еще нет - тогда просто нечего запоминать
  LHadOldPrice := (Length(FRows) > 0) and Assigned(FRows[FSourceRowIndex].NEdtPriceBase);
  if LHadOldPrice then begin
    LOldPriceBase := FRows[FSourceRowIndex].NEdtPriceBase.Value;
    LOldPriceWithVat := FRows[FSourceRowIndex].NEdtPriceWithVat.Value;
  end;

  //удалим динамически созданные контролы прежних строк (кроме самого nedt_price_base - см. CreateRowControls,
  //он переиспользуется как поле цены строки FSourceRowIndex, а не пересоздается)
  for i := 0 to High(FRows) do begin
    if Assigned(FRows[i].LblCaption) then
      FRows[i].LblCaption.Free;
    if Assigned(FRows[i].NEdtPriceBase) and (FRows[i].NEdtPriceBase <> nedt_price_base) then
      FRows[i].NEdtPriceBase.Free;
    if Assigned(FRows[i].NEdtPriceWithVat) then
      FRows[i].NEdtPriceWithVat.Free;
    if Assigned(FRows[i].ChbBySgp) then
      FRows[i].ChbBySgp.Free;
  end;
  SetLength(FRows, 0);

  //ровно 2 колонки (id, type) - см. select ниже (e.id, e.type) и общий комментарий в интерфейсе: строкой
  //ниже (в блоке fEdit/fView/fDelete) НЕ пытаемся дописывать в va2[i] третий элемент как временный буфер -
  //ветка Q.QLoad ниже в любом случае вернет ровно 2 колонки на строку, запись в va2[i][2] там была бы
  //выходом за границы массива и приводила к AV (см. LFound - отдельная переменная для найденной строки)
  SetLength(va2, 1);
  SetLength(va2[0], 2);
  va2[0][0] := FIdOrFormatEstimate;
  va2[0][1] := FItemType;
  //ВРЕМЕННО (период миграции) - см. общий комментарий у поля chb_SingleItemOnly: при отмеченной галке семейный
  //запрос ниже пропускается точно так же, как и для полуфабрикатов - va2 остается той самой единственной
  //(исходной) строкой, заполненной чуть выше. Это единственное место, где реально отключается синхронизация -
  //все остальные механизмы (Save/VerifyBeforeSave/DeleteFamilyItems и т.д.) просто перебирают FRows и сами
  //ничего не делают для отсутствующих строк.
  if (FItemType <> STDITEM_TYPE_SEMIPRODUCT) and
     not (Assigned(chb_SingleItemOnly) and (Cth.GetControlValue(chb_SingleItemOnly) = 1)) then begin
    LSyncGroup := Q.QLoadValue('select sync_group from or_format_estimates where id = :id$i', [FIdOrFormatEstimate]);
    if S.NNum(LSyncGroup) > 0 then
      va2 := Q.QLoad(
        'select e.id, e.type ' +
        'from or_formats f, or_format_estimates e ' +
        'where e.id_format = f.id and e.id_format = :idf$i and e.active = 1 and e.sync_group = :sg$i ' +
        'and e.type <> :tsp$i ' +
        'order by e.type, e.name',
        [FIdFormat, LSyncGroup, STDITEM_TYPE_SEMIPRODUCT]
      );
  end;

  SetLength(FRows, Length(va2));
  FSourceRowIndex := 0;
  LTop := nedt_price_base.Top + cRowHeight;
  for i := 0 to High(va2) do begin
    FRows[i].IdOrFormatEstimate := va2[i][0];
    FRows[i].ItemType := S.NInt(va2[i][1]);
    FRows[i].IsSource := VarToStr(FRows[i].IdOrFormatEstimate) = VarToStr(FIdOrFormatEstimate);
    if FRows[i].IsSource then
      FSourceRowIndex := i;
    FRows[i].ExistingId := Null;
    FRows[i].ExistingName := '';
    FRows[i].ExistingPriceBase := Null;
    FRows[i].ExistingBySgp := 0;
    if (Mode in [fEdit, fView, fDelete]) and (FNameOld <> '') then begin
      LFound := Q.QLoadRow(
        'select id, price_base, by_sgp from or_std_items where id_or_format_estimates = :idf$i and name = :name$s' +
        S.IIfStr(FRows[i].IsSource, ' and id = :id$i', ''),
        [FRows[i].IdOrFormatEstimate, FNameOld] + A.IIfArr(FRows[i].IsSource, [ID], [])
      );
      if not VarIsNull(LFound[0]) then begin
        FRows[i].ExistingId := LFound[0];
        FRows[i].ExistingName := FNameOld;
        FRows[i].ExistingPriceBase := LFound[1];
        FRows[i].ExistingBySgp := S.NInt(LFound[2]);
      end;
    end;
    CreateRowControls(i, LTop);
    LTop := LTop + cRowHeight;
  end;

  //восстановим запомненную в начале процедуры цену строки FSourceRowIndex, если она была (пользователь уже
  //что-то ввел до смены подгруппы) - иначе (первый вызов, либо строка ранее была найдена в БД) оставляем то,
  //что уже подставлено выше (ExistingPriceBase, либо 0 по умолчанию - см. CreateRowControls)
  if LHadOldPrice and (S.NNum(LOldPriceBase) > 0) then begin
    FRows[FSourceRowIndex].NEdtPriceBase.Value := LOldPriceBase;
    FRows[FSourceRowIndex].NEdtPriceWithVat.Value := LOldPriceWithVat;
  end;
end;

procedure TFrmODedtOrStdItem.LoadRouteFromProductionItem;
//см. общий комментарий у объявления. Находим производственную подгруппу семейства (для самого производственного
//изделия - это просто его собственная подгруппа FIdOrFormatEstimate; для отгрузочного/полуфабриката - подгруппу
//типа "производственное" с тем же sync_group), затем в ней - изделие с именем FNameOld (тем же именем, что и
//у только что открытого/редактируемого изделия - все строки семейства именуются одинаково, см. общий комментарий
//в начале модуля), и подставляем в общие чекбоксы его текущие значения маршрута из БД. Если что-то не найдено
//(семейства нет, производственного изделия с таким именем еще нет и т.п.) - просто не трогаем то, что уже
//загружено обычным механизмом (F.DefineFields по ID открытой записи).
var
  i: Integer;
  LProdIdEstimate, LProdId: Variant;
  LRoute: TVarDynArray;
  LSql: string;
begin
  if FItemType = STDITEM_TYPE_SEMIPRODUCT then
    Exit;
  if FNameOld = '' then
    Exit; //fAdd/fCopy - сопоставлять пока не с чем
  if FItemType = STDITEM_TYPE_PRODUCTION then
    LProdIdEstimate := FIdOrFormatEstimate
  else
    LProdIdEstimate := Q.QLoadValue(
      'select e.id from or_formats f, or_format_estimates e ' +
      'where e.id_format = f.id and e.id_format = :idf$i and e.active = 1 and e.type = :tp$i and ' +
      'e.sync_group = (select sync_group from or_format_estimates where id = :ids$i)',
      [FIdFormat, STDITEM_TYPE_PRODUCTION, FIdOrFormatEstimate]
    );
  if S.NNum(LProdIdEstimate) <= 0 then
    Exit;
  LProdId := Q.QLoadValue('select id from or_std_items where id_or_format_estimates = :ide$i and name = :name$s', [LProdIdEstimate, FNameOld]);
  if S.NNum(LProdId) <= 0 then
    Exit;
  LSql := 'select wo_estimate, r0';
  for i := 0 to High(RouteFields) do
    LSql := LSql + ', r' + IntToStr(i + 1);
  LSql := LSql + ' from or_std_items where id = :id$i';
  LRoute := Q.QLoadRow(LSql, [LProdId]);
  Cth.SetControlValue(chb_Wo_Estimate, LRoute[0]);
  Cth.SetControlValue(chb_R0, LRoute[1]);
  for i := 0 to High(RouteFields) do
    Cth.SetControlValue(TDBCheckBoxEh(FindComponent('chb_r' + IntToStr(i + 1))), LRoute[2 + i]);
end;

procedure TFrmODedtOrStdItem.CreateRowControls(ARowIndex, ATop: Integer);
//см. общий комментарий у LoadCounterpartRows/TCounterpartRow. Для строки FSourceRowIndex поле "Цена без НДС" -
//это САМ nedt_price_base (единственное поле цены, оставшееся в F.DefineFields, см. Prepare) - просто
//перемещенный на нужную позицию, а не заново созданный контрол; для остальных строк - независимый, не связанный
//с F, контрол (значение читается/пишется напрямую, см. SaveRow/RowNeedsSave).
var
  LCapt: string;
  LIsSourceRow: Boolean;
begin
  LIsSourceRow := VarToStr(FRows[ARowIndex].IdOrFormatEstimate) = VarToStr(FIdOrFormatEstimate);
  LCapt := VarToStr(Q.QLoadValue(
    'select f.name || '' ['' || e.name || '']'' from or_formats f, or_format_estimates e ' +
    'where e.id_format = f.id and e.id = :id$i',
    [FRows[ARowIndex].IdOrFormatEstimate]
  ));

  FRows[ARowIndex].LblCaption := TLabel(Cth.CreateControls(pnlFrmClient, cntLabel, LCapt, '', '', 0, cRowLblLeft, ATop + 3));
  FRows[ARowIndex].LblCaption.Width := cRowLblWidth;
  if LIsSourceRow then
    FRows[ARowIndex].LblCaption.Font.Style := [fsUnderline];

  if LIsSourceRow then begin
    FRows[ARowIndex].NEdtPriceBase := nedt_price_base;
    nedt_price_base.Top := ATop;
    nedt_price_base.Left := cRowPriceBaseLeft;
  end
  else begin
    FRows[ARowIndex].NEdtPriceBase := TDBNumberEditEh(Cth.CreateControls(pnlFrmClient, cntNEdit, '', '', '0:999999999:2', 0, cRowPriceBaseLeft, ATop));
    FRows[ARowIndex].NEdtPriceBase.Width := cRowPriceWidth;
  end;
  FRows[ARowIndex].NEdtPriceBase.OnChange := RowPriceBaseChange;
  if not VarIsNull(FRows[ARowIndex].ExistingPriceBase) then
    FRows[ARowIndex].NEdtPriceBase.Value := FRows[ARowIndex].ExistingPriceBase
  else
    FRows[ARowIndex].NEdtPriceBase.Value := 0;

  FRows[ARowIndex].NEdtPriceWithVat := TDBNumberEditEh(Cth.CreateControls(pnlFrmClient, cntNEdit, '', '', '0:999999999:2', 0, cRowPriceWithVatLeft, ATop));
  FRows[ARowIndex].NEdtPriceWithVat.Width := cRowPriceWidth;
  FRows[ARowIndex].NEdtPriceWithVat.OnChange := RowPriceWithVatChange;
  RecalcRowPriceWithVat(ARowIndex);

  if FRows[ARowIndex].ItemType = STDITEM_TYPE_SHIPMENT then begin
    FRows[ARowIndex].ChbBySgp := TDBCheckBoxEh(Cth.CreateControls(pnlFrmClient, cntCheck, 'Учет по СГП', '', '', 0, cRowBySgpLeft, ATop));
    FRows[ARowIndex].ChbBySgp.Checked := FRows[ARowIndex].ExistingBySgp = 1;
  end
  else
    FRows[ARowIndex].ChbBySgp := nil;
end;

procedure TFrmODedtOrStdItem.RecalcRowPriceWithVat(ARowIndex: Integer);
//см. тот же расчет в справочнике стандартных изделий - Frg1CellValueSave/CbNdsRate в uFrmOGrefOrStdItems.pas
var
  LRate: Integer;
begin
  if FUpdatingPrice or not Assigned(FRows[ARowIndex].NEdtPriceWithVat) then
    Exit;
  LRate := S.NInt(Cth.GetControlValue(cmb_nds_rate));
  FUpdatingPrice := True;
  try
    FRows[ARowIndex].NEdtPriceWithVat.Value := RoundTo(S.NNum(FRows[ARowIndex].NEdtPriceBase.Value) * (1 + LRate / 100), -2);
  finally
    FUpdatingPrice := False;
  end;
end;

procedure TFrmODedtOrStdItem.RecalcRowPriceBase(ARowIndex: Integer);
var
  LRate: Integer;
begin
  if FUpdatingPrice or not Assigned(FRows[ARowIndex].NEdtPriceBase) then
    Exit;
  LRate := S.NInt(Cth.GetControlValue(cmb_nds_rate));
  FUpdatingPrice := True;
  try
    FRows[ARowIndex].NEdtPriceBase.Value := RoundTo(S.NNum(FRows[ARowIndex].NEdtPriceWithVat.Value) / (1 + LRate / 100), -2);
  finally
    FUpdatingPrice := False;
  end;
end;

procedure TFrmODedtOrStdItem.RowPriceBaseChange(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to High(FRows) do
    if FRows[i].NEdtPriceBase = Sender then begin
      RecalcRowPriceWithVat(i);
      Break;
    end;
end;

procedure TFrmODedtOrStdItem.RowPriceWithVatChange(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to High(FRows) do
    if FRows[i].NEdtPriceWithVat = Sender then begin
      RecalcRowPriceBase(i);
      Break;
    end;
end;

procedure TFrmODedtOrStdItem.SetRowsControlsState;
//блокировка/разблокировка полей строк семейства - право на изменение цены (та же роль, что и раньше для
//единственного поля цены - rOr_R_StdItems_Set_Prices, только теперь в режиме fEdit применяется ко ВСЕМ строкам)
//и режим просмотра/удаления (там нечего редактировать вовсе). Плюс живая подсветка занятых имен - см.
//UpdateAddDuplicateMarkers. Плюс (см. ниже) блокировка общих чекбоксов маршрута для отгрузочной строки -
//вызывается после LoadCounterpartRows/SetRoute во всех трех местах, где меняется состав FRows/FSourceRowIndex
//(Prepare, ControlOnChange - смена подгруппы в комбобоксе Формат и переключение chb_SingleItemOnly), поэтому
//это общее подходящее место и для пересчета блокировки по типу открытой строки.
var
  i: Integer;
  LReadOnly, LIsShipmentRow: Boolean;
begin
  LReadOnly := (Mode in [fView, fDelete]) or ((Mode = fEdit) and not User.Role(rOr_R_StdItems_Set_Prices));
  for i := 0 to High(FRows) do begin
    FRows[i].NEdtPriceBase.ReadOnly := LReadOnly;
    FRows[i].NEdtPriceWithVat.ReadOnly := LReadOnly;
    Cth.SetEhControlColor(FRows[i].NEdtPriceBase, S.IIf(LReadOnly, clmyDisabled, clWindow));
    Cth.SetEhControlColor(FRows[i].NEdtPriceWithVat, S.IIf(LReadOnly, clmyDisabled, clWindow));
    if Assigned(FRows[i].ChbBySgp) then
      FRows[i].ChbBySgp.Enabled := not (Mode in [fView, fDelete]);
  end;
  UpdateAddDuplicateMarkers;
  //поправка по факту тестирования - см. общий комментарий в начале модуля и LoadRouteFromProductionItem: поля
  //маршрута/"без сметы"/"без маршрута" относятся ТОЛЬКО к производственному изделию семейства - если открыта
  //ОТГРУЗОЧНАЯ строка (FRows[FSourceRowIndex]), эти чекбоксы хоть и показывают (см. LoadRouteFromProductionItem)
  //реальный маршрут производственного изделия, редактировать их отсюда бессмысленно: при сохранении отгрузочного
  //изделия они все равно принудительно записываются как 0, независимо от того, что тут показано (см. Save/
  //SaveRow) - поэтому просто блокируем, чтобы не вводить в заблуждение.
  //chb_r1..rN НЕ трогаем в обратную сторону (когда открыта НЕ отгрузочная строка) - их доступность в этом случае
  //уже корректно выставлена только что отработавшим SetRoute (взаимоисключение с chb_Wo_Estimate/chb_R0), не
  //нужно ее здесь перезатирать; а вот chb_Wo_Estimate/chb_R0 сам SetRoute не трогает вовсе, поэтому для них
  //обязательны ОБЕ ветки (иначе после блокировки по отгрузочной строке они останутся заблокированы навсегда,
  //даже если пользователь потом переключится на производственную подгруппу в комбобоксе Формат).
  LIsShipmentRow := (Length(FRows) > 0) and (FRows[FSourceRowIndex].ItemType = STDITEM_TYPE_SHIPMENT);
  SetControlsEditable([chb_Wo_Estimate, chb_R0], not LIsShipmentRow and not (Mode in [fView, fDelete]));
  if LIsShipmentRow then
    for i := 0 to High(RouteFields) do
      SetControlsEditable([TDBCheckBoxEh(FindComponent('chb_r' + IntToStr(i + 1)))], False);
end;

procedure TFrmODedtOrStdItem.UpdateAddDuplicateMarkers;
//только для fAdd/fCopy (см. общий комментарий в начале модуля) - по текущему тексту edt_name проверяет по
//каждой строке семейства (кроме FSourceRowIndex - для нее уже есть отдельная, не тронутая проверка на 0-й
//вкладке в прежней версии VerifyBeforeSave/Cth.SetErrorMarker(edt_name,...)), не занято ли это имя уже каким-то
//изделием в этой подгруппе - если да, красным подчеркиванием подписи строки предупреждаем, что при сохранении
//это будет ошибка (см. VerifyBeforeSave - жесткая блокировка через CheckDuplicateNameInDb).
var
  i, LCnt: Integer;
  LName: string;
begin
  if not (Mode in [fAdd, fCopy]) then
    Exit;
  LName := Trim(edt_name.Text);
  for i := 0 to High(FRows) do begin
    if FRows[i].IsSource then
      Continue;
    LCnt := 0;
    if LName <> '' then
      LCnt := Q.QLoadValue('select count(1) from or_std_items where id_or_format_estimates = :idf$i and name = :name$s',
        [FRows[i].IdOrFormatEstimate, LName]);
    if LCnt > 0 then
      FRows[i].LblCaption.Font.Color := clRed
    else
      FRows[i].LblCaption.Font.Color := clWindowText;
  end;
end;

procedure TFrmODedtOrStdItem.AfterFormActivate;
begin
  inherited;
  UpdateSemiproductErrorsLabel;
end;

function TFrmODedtOrStdItem.VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean;
//проверим здесь моменты:
//если не задан маршрут, когда он должен быть
//если наименование совпадает с уже существующим изделием на какой-либо из строк семейства (только fAdd/fCopy -
//см. UpdateAddDuplicateMarkers)
var
  i, j: Integer;
begin
  Result := False;
  UpdateAddDuplicateMarkers;
  //хотя бы один участок маршрута должен быть выбран, если не стоит "Без маршрута" (r0) и не стоит "Без сметы" -
  //в этих двух случаях маршрут не требуется вовсе.
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
end;

function TFrmODedtOrStdItem.Save: Boolean;
//запись результатов в бд
//при изменении значения чекбокса Без сметы в режиме редактирования нам надо подправить смету после записи основной таблицы
//(если галка была снята, то загрузить пустую смету, если же галка поставлена, то смету просто удалить - будет требовать ввода в дальнешем)
//
//ВАЖНО: сохраняются ВСЕ строки семейства безусловно (кроме случая fDelete - см. отдельную ветку ниже,
//DeleteFamilyItems) - синхронизация теперь не отключаема, см. общий комментарий в начале модуля.
var
  i: Integer;
  LProdPrefixedName, LDummy: string;
  LRowIds: TVarDynArray;
  LProdCount, LProdRowIndex: Integer;
  LProdId: Variant;
begin
  Q.QBeginTrans(True);

  if Mode = fDelete then begin
    Result := inherited;
    if not Result then begin
      Q.QRollbackTrans;
      Exit;
    end;
    DeleteFamilyItems;
    Result := Q.QCommitTrans;
    Exit;
  end;

  //поля маршрута/"без сметы"/"без маршрута" относятся ТОЛЬКО к производственному изделию (см. общий
  //комментарий в начале модуля и SaveRow) - если сама открытая строка (FSourceRowIndex) отгрузочная,
  //принудительно обнуляем их перед сохранением базовым механизмом, независимо от того, что показывают общие
  //чекбоксы формы (chb_Wo_Estimate/chb_R0/chb_r1..N)
  if FRows[FSourceRowIndex].ItemType = STDITEM_TYPE_SHIPMENT then begin
    F.SetProp('wo_estimate$i', 0);
    F.SetProp('r0$i', 0);
    for i := 0 to High(RouteFields) do
      F.SetProp('r' + IntToStr(i + 1) + '$i', 0);
  end;
  //сохраним основные (строки FSourceRowIndex) данные - обычным механизмом базового диалога
  Result := inherited;
  if not Result then begin
    Q.QRollbackTrans;
    Exit;
  end;
  //переименование полного (с префиксом) наименования в ИТМ/bcad_nomencl
  if (Mode = fEdit) and (edt_name.Text <> FNameOld) then
    RenameNomenclatura(FIdEstimateGroup, FNameOld, Trim(edt_name.Text), FItemType);
  if (Mode = fEdit) and (Cth.GetControlValue(chb_Wo_Estimate) <> FWoEstimateOld) then begin
    //если изменился признак "Без сметы", то удаляем смету
    //(в проверке перед записью спросит, если при этом была подгружена непустая смета)
    Orders.RemoveEstimateForStdItem(id, True);
  end;
  SyncOrderItemTemplates(FSourceRowIndex, ID);

  //--- сохранение ОСТАЛЬНЫХ строк семейства (все, кроме FSourceRowIndex) - см. общий комментарий выше ---------
  SetLength(LRowIds, Length(FRows));
  LRowIds[FSourceRowIndex] := ID;
  for i := 0 to High(FRows) do
    if (i <> FSourceRowIndex) and RowNeedsSave(i) then begin
      LRowIds[i] := SaveRow(i);
      if VarIsNull(LRowIds[i]) then begin
        Result := False;
        Break;
      end;
      SyncOrderItemTemplates(i, LRowIds[i]);
    end
    else if i <> FSourceRowIndex then
      LRowIds[i] := FRows[i].ExistingId;
  if not Result then begin
    Q.QRollbackTrans;
    Exit;
  end;

  //--- решение по смете(ам) отгрузочных изделий (см. общий комментарий у CheckSelfSmetaAction/CreateSelfSmeta) -
  //считаем ДО commit (нужны только уже вычисленные id/имена, в БД пока не пишем), выполняем - ТОЛЬКО ПОСЛЕ.
  LProdCount := 0;
  LProdRowIndex := -1;
  for i := 0 to High(FRows) do
    if FRows[i].ItemType = STDITEM_TYPE_PRODUCTION then begin
      Inc(LProdCount);
      LProdRowIndex := i;
    end;

  Result := Q.QCommitTrans;
  //ВАЖНО: CreateSelfSmeta вызываем ТОЛЬКО ПОСЛЕ фиксации своей транзакции выше, а не внутри нее - см. подробный
  //комментарий у CreateSelfSmeta про собственную транзакцию Orders.ApplyEstimateArray.
  if Result and (LProdCount = 1) then begin
    LProdId := LRowIds[LProdRowIndex];
    LProdPrefixedName := GetPrefixedName(FRows[LProdRowIndex].IdOrFormatEstimate, edt_name.Text);
    for i := 0 to High(FRows) do
      if FRows[i].ItemType = STDITEM_TYPE_SHIPMENT then
        if CheckSelfSmetaAction(LRowIds[i], LProdId, edt_name.Text, LProdPrefixedName, LDummy) = 1 then
          CreateSelfSmeta(LRowIds[i], LProdId, LProdPrefixedName);
  end;

  //для модальных вызовов, которым нужен id только что созданной/сохраненной записи (0-й, основной вкладки) -
  //например, "Создать полуфабрикат" из диалога сметы (см. CreateSemiproductFromRow, uFrmOGedtEstimate.pas)
  if Result then
    FFormResult.Data := ID;
end;

procedure TFrmODedtOrStdItem.DeleteFamilyItems;
//удаляет (внутри уже открытой пакетной транзакции - Q.QBeginTrans(True) в Save) изделия ВСЕХ найденных строк
//семейства, КРОМЕ FSourceRowIndex (её удаляет сам базовый механизм диалога, inherited Save - Q.QSave('D', ...)
//на саму запись ID). "Пакетный режим" (см. TmyDB.QBeginTrans в uDB.pas) гарантирует, что при сбое любого из
//удалений итоговый Q.QCommitTrans в Save фактически откатит всю транзакцию целиком, независимо от того, что
//сама эта процедура ошибок не перехватывает - см. общий комментарий в начале модуля.
var
  i: Integer;
begin
  for i := 0 to High(FRows) do
    if (i <> FSourceRowIndex) and (S.NNum(FRows[i].ExistingId) > 0) then
      Q.QExecSql('delete from or_std_items where id = :id$i', [FRows[i].ExistingId]);
end;

procedure TFrmODedtOrStdItem.VerifyBeforeSave;
var
  i, res1, res3: Integer;
  NewEmptyEstimate: Boolean;
  LPlanText, LPrefixedName, LOldPrefixedName, LDetails, LMsg, LTypeCapt: string;
  LAction, LProdCount, LProdRowIndex: Integer;
  LProdId: Variant;
  LSemiErrMsg, LSemiWarnMsg: string;
begin
  //ВРЕМЕННО (период миграции) - см. общий комментарий у поля chb_SingleItemOnly. Обычный диалог подтверждения
  //ниже (LPlanText) в этом режиме ничего "лишнего" про парные изделия семейства не покажет - именно потому,
  //что FRows нарочно ограничен одной строкой (см. LoadCounterpartRows), и они в нем просто не участвуют.
  //Поэтому здесь - отдельное, явное предупреждение; переспрашиваем при КАЖДОМ нажатии ОК, пока галка отмечена,
  //до всех остальных проверок (чтобы не гонять лишние запросы к БД, если администратор данных передумает).
  if Assigned(chb_SingleItemOnly) and (Cth.GetControlValue(chb_SingleItemOnly) = 1) then
    if MyQuestionMessage(
      'Включен временный режим миграции "Только одно (без связи с группой)"!'#13#10 +
      'Операция будет выполнена ТОЛЬКО для изделия текущей подгруппы - без создания, переименования или '+
      'удаления парных изделий семейства синхронизации, даже если по обычным правилам это требовалось бы.'#13#10 +
      'Переименование в номенклатуре ИТМ и в справочнике сметных позиций для САМОГО этого изделия при этом '+
      'выполняется как обычно.'#13#10#13#10'Вы уверены, что хотите продолжить?'
    ) <> mrYes then begin
      HasError := True;
      Exit;
    end;
  //проверки при редактировании или добавлении записи (только если изменилорсь наименование)
  //проверим, нет ли такого наименования среди стандартных изделий того же типа паспорта
  //также наименование с преиксом не должно быть в базе сметных наименований учета
  //и также и в базе итм с типом "материалы и комплектующие"
  //ВАЖНО: эту проверку (для строки FSourceRowIndex) намеренно не трогаем и не расширяем - см. тот же по смыслу,
  //но обобщенный вариант (CheckDuplicateNameInDb) для остальных строк семейства ниже.
  if (Mode <> fDelete) and (FIdEstimateGroup > 1) and (edt_name.Text <> FNameOld) then begin
    res1 := Q.QLoadValue('select count(1) from or_std_items where id <> :id$i and (id_or_format_estimates = :idf$i) and name = :name$s', [ID, FIdEstimateGroup, edt_name.Text]);
    res3 := Q.QLoadValue('select count(1) from dv.nomenclatura where id_nomencltype = 0 and name = :name$s', [FPrefix + '_' + edt_name.Text]);
    if res1 + res3 > 0 then begin
      MyWarningMessage(S.IIf(res1 > 0, 'Такое наименование уже существует в этой группе стандартных изделий Учета!'#13#10, '') +
        S.IIf(res3 > 0, 'Такое наименование (с учетом префикса) уже есть в ИТМ среди номенклатуры типа "материалы и комплектующие"!'#13#10, '') + #13#10'Данные не могут быть сохранены!');
      HasError := True;
      Exit;
    end;
  end;
  if (Mode = fEdit) and (chb_Wo_Estimate.Checked) and (Cth.GetControlValue(chb_Wo_Estimate) <> FWoEstimateOld) then begin
    NewEmptyEstimate := Q.QLoadValue('select count(1) from estimates where id_std_item = :id$i and isempty = 0', [id]) > 0;
    if NewEmptyEstimate then
      if MyQuestionMessage('Для этого изделия выбран тип "без сметы", но сейчас к нему уже подгружена непустая смета.'#13#10'Она будет удалена.'#13#10'Продолжить?') <> mrYes then begin
        HasError := True;
        Exit;
      end;
  end;

  if Mode <> fDelete then begin
    //--- цена обязательна для КАЖДОЙ строки семейства (см. общий комментарий в начале модуля - "если цена не
    //задана, просто не пропускаем диалог")
    for i := 0 to High(FRows) do
      if (FRows[i].NEdtPriceBase.Text = '') or VarIsNull(FRows[i].NEdtPriceBase.Value) then begin
        MyWarningMessage('Не задана цена для подгруппы "' + Trim(FRows[i].LblCaption.Caption) + '"!'#13#10'Данные не могут быть сохранены!');
        HasError := True;
        Exit;
      end;

    //--- обязательная проверка в БД для каждой ДОПОЛНИТЕЛЬНО сохраняемой строки семейства (см. общий комментарий
    //в начале Save и CheckDuplicateNameInDb). В fAdd/fCopy - ЛЮБОЕ совпадение теперь ошибка (см. общий
    //комментарий в начале модуля - раньше здесь подставлялись данные найденного изделия); в fEdit - только для
    //строк, где сопоставление НЕ было найдено при загрузке (ExistingId = Null, т.е. будет создано новое) или
    //где найденная запись переименовывается (текущее edt_name.Text разошлось с ExistingName).
    for i := 0 to High(FRows) do begin
      if i = FSourceRowIndex then
        Continue;
      if S.NNum(FRows[i].ExistingId) <= 0 then begin
        LPrefixedName := GetPrefixedName(FRows[i].IdOrFormatEstimate, edt_name.Text);
        if not CheckDuplicateNameInDb(FRows[i].IdOrFormatEstimate, Null, edt_name.Text, LPrefixedName, LMsg) then begin
          MyWarningMessage(LMsg + #13#10'Данные не могут быть сохранены!');
          HasError := True;
          Exit;
        end;
      end
      else if UpperCase(Trim(FRows[i].ExistingName)) <> UpperCase(Trim(edt_name.Text)) then begin
        LPrefixedName := GetPrefixedName(FRows[i].IdOrFormatEstimate, edt_name.Text);
        if not CheckDuplicateNameInDb(FRows[i].IdOrFormatEstimate, FRows[i].ExistingId, edt_name.Text, LPrefixedName, LMsg) then begin
          MyWarningMessage(LMsg + #13#10'Данные не могут быть сохранены!');
          HasError := True;
          Exit;
        end;
      end;
    end;
  end;

  //--- для полуфабрикатов: проверка "голого" имени на конфликты за пределами своей подгруппы
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

  //--- смета(ы) отгрузочных изделий, переименование в bcad_nomencl и список создаваемых/обновляемых строк
  //семейства - собираем ЗАРАНЕЕ (до транзакции) список того, что будет сделано при сохранении, и одним диалогом
  //просим подтверждение.
  if Mode in [fAdd, fCopy, fEdit] then begin
    LPlanText := '';

    for i := 0 to High(FRows) do
      if (i <> FSourceRowIndex) and RowNeedsSave(i) then begin
        LTypeCapt := S.IIf(FRows[i].ItemType = STDITEM_TYPE_PRODUCTION, 'производственное', 'отгрузочное');
        if (S.NNum(FRows[i].ExistingId) > 0) and (UpperCase(Trim(FRows[i].ExistingName)) <> UpperCase(Trim(edt_name.Text))) then begin
          S.ConcatStP(LPlanText, Format('- будет переименовано существующее %s изделие "%s" в "%s" (%s)',
            [LTypeCapt, Trim(FRows[i].ExistingName), Trim(edt_name.Text), Trim(FRows[i].LblCaption.Caption)]), #13#10);
          LDetails := GetNomenclaturaRenamePlanText(FRows[i].IdOrFormatEstimate, FRows[i].ExistingName, Trim(edt_name.Text), FRows[i].ItemType);
          if LDetails <> '' then
            S.ConcatStP(LPlanText, LDetails, #13#10);
        end
        else if S.NNum(FRows[i].ExistingId) > 0 then
          S.ConcatStP(LPlanText, Format('- будет обновлено существующее %s изделие "%s" (%s)', [LTypeCapt, Trim(edt_name.Text), Trim(FRows[i].LblCaption.Caption)]), #13#10)
        else
          S.ConcatStP(LPlanText, Format('- будет создано новое %s изделие "%s" (%s)', [LTypeCapt, Trim(edt_name.Text), Trim(FRows[i].LblCaption.Caption)]), #13#10);
      end;

    if FItemType <> STDITEM_TYPE_SEMIPRODUCT then begin
      //смета для ОТГРУЗОЧНЫХ изделий со ссылкой на ЕДИНСТВЕННОЕ производственное
      LProdCount := 0;
      LProdRowIndex := -1;
      for i := 0 to High(FRows) do
        if FRows[i].ItemType = STDITEM_TYPE_PRODUCTION then begin
          Inc(LProdCount);
          LProdRowIndex := i;
        end;
      if LProdCount = 1 then begin
        LProdId := FRows[LProdRowIndex].ExistingId;
        if LProdRowIndex = FSourceRowIndex then
          LOldPrefixedName := GetPrefixedName(FRows[FSourceRowIndex].IdOrFormatEstimate, FNameOld)
        else if S.NNum(FRows[LProdRowIndex].ExistingId) > 0 then
          LOldPrefixedName := GetPrefixedName(FRows[LProdRowIndex].IdOrFormatEstimate, FRows[LProdRowIndex].ExistingName)
        else
          LOldPrefixedName := GetPrefixedName(FRows[LProdRowIndex].IdOrFormatEstimate, edt_name.Text);
        for i := 0 to High(FRows) do
          if FRows[i].ItemType = STDITEM_TYPE_SHIPMENT then begin
            LAction := CheckSelfSmetaAction(FRows[i].ExistingId, LProdId, Trim(edt_name.Text), LOldPrefixedName, LDetails);
            if LAction = 1 then
              S.ConcatStP(LPlanText, '- ' + LDetails, #13#10)
            else if LAction = 2 then
              MyWarningMessage(LDetails);
          end;
      end;
    end;
    //переименование записи в номенклатуре ИТМ (dv.nomenclatura) И, ОТДЕЛЬНО, в справочнике сметных позиций
    //Учета (bcad_nomencl) для строки FSourceRowIndex
    if (Mode = fEdit) and (edt_name.Text <> FNameOld) then begin
      LDetails := GetNomenclaturaRenamePlanText(FIdEstimateGroup, FNameOld, Trim(edt_name.Text), FItemType);
      if LDetails <> '' then
        S.ConcatStP(LPlanText, LDetails, #13#10);
    end;
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
//(bcad_units.id = 1), группа "Готовые изделия" (bcad_groups.id = 104). БЕЗ ИЗМЕНЕНИЙ с прежней версии.
var
  LIdEstimate: Variant;
  LCnt: Integer;
  va: TVarDynArray;
begin
  ADetails := '';
  if S.NNum(AIdShipmentItem) = 0 then begin
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
//см. общий комментарий у CheckSelfSmetaAction. БЕЗ ИЗМЕНЕНИЙ с прежней версии.
var
  Ctx: TEstimateApplyContext;
  Est: TVarDynArray2;
begin
  Ctx.IdEstimate := Null;
  Ctx.IdOrder := Null;
  Ctx.IdOrderItem := Null;
  Ctx.IdStdItem := AIdShipmentItem;
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
  Ctx.Silent := True;
  Ctx.EstBefore := Orders.LoadEstimateArray(Null);
  Ctx.EstLogSource := '0';
  Est := [[AProductionPrefixedName, BCAD_GROUP_FINISHED_ITEMS, BCAD_UNIT_PCS, 1, '', AIdProductionItem]];
  Orders.ApplyEstimateArray(Ctx, Est);
end;

function TFrmODedtOrStdItem.RowNeedsSave(ARowIndex: Integer): Boolean;
//строка ARowIndex (не FSourceRowIndex) реально нуждается в записи в БД, только если это НОВОЕ изделие
//(ExistingId = Null - его в любом случае нужно создать, иначе ссылаться в смете будет не на что) ЛИБО уже
//существующее, но цена/учет по СГП сейчас отличаются от снимка в БД, либо переименовывается. Проще прежнего
//CounterpartTabNeedsSave - синхронизация теперь безусловна, никакой индирекции через активную
//вкладку/пользовательские слоты не требуется, сравниваем напрямую текущие значения контролов строки.
begin
  Result := True;
  if S.NNum(FRows[ARowIndex].ExistingId) <= 0 then
    Exit; //новое изделие - всегда нуждается в создании
  if UpperCase(Trim(FRows[ARowIndex].ExistingName)) <> UpperCase(Trim(edt_name.Text)) then
    Exit; //переименовано
  if S.NNum(FRows[ARowIndex].NEdtPriceBase.Value) <> S.NNum(FRows[ARowIndex].ExistingPriceBase) then
    Exit;
  if Assigned(FRows[ARowIndex].ChbBySgp) and (S.IIf(FRows[ARowIndex].ChbBySgp.Checked, 1, 0) <> FRows[ARowIndex].ExistingBySgp) then
    Exit;
  Result := False;
end;

function TFrmODedtOrStdItem.GetPrefixedName(AIdOrFormatEstimate: Variant; const AName: string): string;
//БЕЗ ИЗМЕНЕНИЙ с прежней версии.
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
//(bcad_nomencl) - по ПОЛНОМУ (с учетом префикса подгруппы AIdOrFormatEstimate) наименованию. БЕЗ ИЗМЕНЕНИЙ по
//смыслу с прежней версии (только источник вызова обобщен - см. Save/SaveRow).
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
//текст для диалога подтверждения - ЗАРАНЕЕ (без изменений в БД) предсказывает, что реально сделает
//RenameNomenclatura. БЕЗ ИЗМЕНЕНИЙ с прежней версии.
var
  LOldName, LNewName: string;
begin
  Result := '';
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

function TFrmODedtOrStdItem.CheckDuplicateNameInDb(AIdOrFormatEstimate, AExcludeId: Variant; const AName, APrefixedName: string; out AMsg: string): Boolean;
//мандатная проверка в БД - не занято ли наименование (простое - в or_std_items этой же подгруппы, и с
//префиксом - в ИТМ среди номенклатуры типа "материалы и комплектующие") каким-то ДРУГИМ (не AExcludeId)
//изделием. БЕЗ ИЗМЕНЕНИЙ с прежней версии.
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
//для полуфабрикатов - "голое" (без префикса) наименование должно быть уникально среди ВСЕХ групп полуфабрикатов
//и нестандартных изделий - иначе жесткая ошибка (п.1). также жесткая ошибка, если оно совпадает с ПОЛНЫМ (с
//префиксом) наименованием какого-либо стандартного (производственного/отгрузочного) изделия (п.2). отдельно
//(НЕ блокируя) предупреждаем, если голое имя полуфабриката просто совпало с ГОЛЫМ (без префикса) именем
//какого-то стандартного изделия (п.3). БЕЗ ИЗМЕНЕНИЙ с прежней версии.
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
//БЕЗ ИЗМЕНЕНИЙ с прежней версии.
var
  LErrorMsg, LWarningMsg: string;
  LErrorsText: string;
begin
  lblSemiproductErrors.Visible := False;
  if (FItemType <> STDITEM_TYPE_SEMIPRODUCT) or not (Mode in [fView, fEdit]) or (S.NNum(ID) <= 0) then
    Exit;
  CheckSemiproductNameConflicts(ID, Trim(edt_name.Text), LErrorMsg, LWarningMsg);
  LErrorsText := '';
  if LErrorMsg <> '' then
    S.ConcatStP(LErrorsText, LErrorMsg, #13#10);
  if LWarningMsg <> '' then
    S.ConcatStP(LErrorsText, LWarningMsg, #13#10);
  if LErrorsText <> '' then begin
    lblSemiproductErrors.Tag := 0; //не используется - текст показываем через замыкание ниже нет смысла, см. lblSemiproductErrorsClick
    lblSemiproductErrors.Caption := 'Есть ошибки!';
    lblSemiproductErrors.Hint := LErrorsText;
    lblSemiproductErrors.Visible := True;
  end;
end;

procedure TFrmODedtOrStdItem.lblSemiproductErrorsClick(Sender: TObject);
begin
  if lblSemiproductErrors.Hint <> '' then
    MyWarningMessage(lblSemiproductErrors.Hint);
end;

function TFrmODedtOrStdItem.SaveRow(ARowIndex: Integer): Variant;
//сохраняет изделие строки ARowIndex (не FSourceRowIndex): если сопоставление с уже существующим изделием было
//найдено при загрузке строк (FRows[ARowIndex].ExistingId - см. LoadCounterpartRows) - обновляет найденную
//запись (цену/учет по СГП, маршрут - см. ниже, и, если наименование успело разойтись, то и само наименование);
//иначе - создает НОВУЮ запись or_std_items в этой подгруппе.
//
//поправка по факту тестирования (маршрут производственного изделия обнулялся при редактировании со стороны
//отгрузочной подгруппы): строка ARowIndex здесь - ВСЕГДА "сосед", не сама открытая (ту сохраняет базовый
//механизм диалога, inherited Save, см. Save). Соответственно, если это ПРОИЗВОДСТВЕННАЯ строка - а это
//единственный случай, когда SaveRow вообще может сохранять производственное изделие, т.к. открытая строка
//(FSourceRowIndex) в этом случае обязательно ОТГРУЗОЧНАЯ (см. общий комментарий у LoadRouteFromProductionItem) -
//поля маршрута НЕЛЬЗЯ брать из общих чекбоксов формы: сейчас они лишь ОТОБРАЖАЮТ реальный маршрут (см.
//LoadRouteFromProductionItem) и заблокированы для редактирования (см. SetRowsControlsState) - изменить маршрут
//производственного изделия можно только через диалог, открытый непосредственно на нем самом. Поэтому при
//ОБНОВЛЕНИИ уже существующего производственного изделия как соседа поля маршрута теперь вообще НЕ включаются в
//SQL (LIncludeRoute=False) - в БД остается то, что там уже было; они включаются (с жестким нулем, не из
//чекбоксов) только при СОЗДАНИИ нового производственного изделия впервые именно отсюда - его маршрут в этом
//случае еще не задан нигде, задать его можно будет позже, отредактировав само производственное изделие. Для
//отгрузочной строки поведение прежнее - маршрут всегда 0, и всегда включается в SQL (что при создании, что при
//обновлении), независимо от того, что показывают общие чекбоксы (даже если открыта на редактирование сама
//отгрузочная строка - см. также Save).
var
  LFields: string;
  LValues: TVarDynArray;
  i: Integer;
  LId, LRes: Variant;
  LBySgp: Integer;
  LRoute: TVarDynArray;
  LIncludeRoute: Boolean;
begin
  Result := Null;
  LBySgp := 0;
  if Assigned(FRows[ARowIndex].ChbBySgp) then
    LBySgp := S.IIf(FRows[ARowIndex].ChbBySgp.Checked, 1, 0);
  SetLength(LRoute, Length(RouteFields));
  for i := 0 to High(RouteFields) do
    LRoute[i] := 0;
  LIncludeRoute := (FRows[ARowIndex].ItemType = STDITEM_TYPE_SHIPMENT) or (S.NNum(FRows[ARowIndex].ExistingId) <= 0);
  if S.NNum(FRows[ARowIndex].ExistingId) > 0 then begin
    LId := FRows[ARowIndex].ExistingId;
    LFields := 'id$i;name$s;price_base$f';
    LValues := [LId, Trim(edt_name.Text), FRows[ARowIndex].NEdtPriceBase.Value];
    if LIncludeRoute then begin
      LFields := LFields + ';wo_estimate$i;r0$i';
      LValues := LValues + [0, 0];
      for i := 0 to High(RouteFields) do begin
        LFields := LFields + ';r' + IntToStr(i + 1) + '$i';
        LValues := LValues + [LRoute[i]];
      end;
    end;
    if Assigned(FRows[ARowIndex].ChbBySgp) then begin
      LFields := LFields + ';by_sgp$i';
      LValues := LValues + [LBySgp];
    end;
    LRes := Q.QSave('U', 'or_std_items', '', LFields, LValues);
    if LRes < 0 then
      Exit;
    //переименование в номенклатуре ИТМ/справочнике сметных позиций для ЭТОЙ (не FSourceRowIndex) строки семейства -
    //поправка по факту тестирования: раньше вызывалось только в Save для FSourceRowIndex, из-за чего при
    //переименовании, открытом со стороны ДРУГОЙ строки семейства (например, с отгрузочной подгруппы, когда сама
    //production-строка сохраняется здесь, в SaveRow, как сиблинг), запись в bcad_nomencl для нее не переименовывалась -
    //и последующая CheckSelfSmetaAction ошибочно считала уже верную смету "не соответствующей ожидаемой"
    //(она продолжала ссылаться на старое, непереименованное имя)
    if UpperCase(Trim(FRows[ARowIndex].ExistingName)) <> UpperCase(Trim(edt_name.Text)) then
      RenameNomenclatura(FRows[ARowIndex].IdOrFormatEstimate, FRows[ARowIndex].ExistingName, Trim(edt_name.Text), FRows[ARowIndex].ItemType);
    Result := LId;
  end
  else begin
    LFields := 'id$i;name$s;price_base$f;by_sgp$i;id_or_format_estimates$i';
    LValues := [Null, Trim(edt_name.Text), FRows[ARowIndex].NEdtPriceBase.Value, LBySgp, FRows[ARowIndex].IdOrFormatEstimate];
    //LIncludeRoute здесь всегда True (см. условие выше - ExistingId <= 0 в этой ветке всегда) - жесткий 0, не
    //из чекбоксов, см. общий комментарий у процедуры
    LFields := LFields + ';wo_estimate$i;r0$i';
    LValues := LValues + [0, 0];
    for i := 0 to High(RouteFields) do begin
      LFields := LFields + ';r' + IntToStr(i + 1) + '$i';
      LValues := LValues + [LRoute[i]];
    end;
    LId := Q.QSave('I', 'or_std_items', '', LFields, LValues);
    if LId < 0 then
      Exit;
    Result := LId;
  end;
end;

procedure TFrmODedtOrStdItem.SyncOrderItemTemplates(ARowIndex: Integer; AId: Variant);
//устанавливает в шаблонах (order_items с псевдо-id_order - см. условие ниже) цену и маршрут изделий,
//соответствующих данному (AId) - вызывается для КАЖДОГО сохраняемого изделия семейства.
//Вызывается только для уже СУЩЕСТВОВАВШИХ изделий - для только что созданных шаблонов еще нет и быть не может.
var
  i: Integer;
  LSqlFields: TVarDynArray;
  LValues: TVarDynArray;
  LIsShipment, LIncludeRoute: Boolean;
begin
  if (ARowIndex = FSourceRowIndex) and (Mode <> fEdit) then
    Exit;
  if (ARowIndex <> FSourceRowIndex) and (S.NNum(FRows[ARowIndex].ExistingId) <= 0) then
    Exit;
  //поля маршрута относятся только к производственному изделию (см. общий комментарий в начале модуля и
  //SaveRow) - для отгрузочной строки семейства всегда пишем 0, независимо от общих чекбоксов формы.
  //Поправка по факту тестирования (см. тот же по смыслу комментарий у SaveRow): общие чекбоксы формы отражают
  //АКТУАЛЬНЫЙ, редактируемый маршрут только когда сама эта строка и есть FSourceRowIndex (диалог открыт
  //непосредственно на ней); если производственная строка синхронизируется здесь как "сосед" (диалог открыт на
  //отгрузочной подгруппе) - чекбоксы сейчас лишь отображают маршрут, заблокированы для правки, и в SaveRow
  //маршрут этой строки уже НЕ переписывается - соответственно, и здесь (в шаблонах заказов) его трогать не
  //нужно: raз or_std_items не менялся, и шаблоны менять незачем.
  LIsShipment := FRows[ARowIndex].ItemType = STDITEM_TYPE_SHIPMENT;
  LIncludeRoute := LIsShipment or (ARowIndex = FSourceRowIndex);
  LSqlFields := ['price_base$f'];
  LValues := [FRows[ARowIndex].NEdtPriceBase.Value];
  if LIncludeRoute then begin
    LSqlFields := LSqlFields + ['r0$i'];
    LValues := LValues + [S.IIf(LIsShipment, 0, Cth.GetControlValue(chb_R0))];
    for i := 0 to High(RouteFields) do begin
      LSqlFields := LSqlFields + ['r' + IntToStr(i + 1) + '$i'];
      LValues := LValues + [S.IIf(LIsShipment, 0, Cth.GetControlValue(TDBCheckBoxEh(FindComponent('chb_r' + IntToStr(i + 1)))))];
    end;
  end;
  Q.QExecSql(Q.QGetSql('Q', 'order_items', LSqlFields.Implode(';')) + ' where id_order < 0 and id_order > -100000 and id_std_item = :id_std_item$i', LValues + [AId]);
end;

procedure TFrmODedtOrStdItem.SetRoute;
//БЕЗ ИЗМЕНЕНИЙ с прежней версии.
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
