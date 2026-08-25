{
Диалог ввода/редактирования сметы (позиций сметы - estimate_items) к стандартному изделию либо
к позиции (изделию) заказа - в зависимости от AddParam (1 - стандартное изделие, ID = его айди;
0 - позиция заказа, ID = айди order_items).

ОТКРЫТИЕ ДИАЛОГА
Открывать этот диалог следует только через обертку TOrders.LoadEstimate (uOrders.pas), а не
напрямую через ShowModal2/.Show - обертка берет на себя создание записи в estimates при первом
сохранении, проверку признака "без сметы" у стандартного изделия, подготовку бокового канала
(см. ниже) и уникальный ключ блокировки повторного открытия окна. Пример корректного вызова из
кода самого диалога - см. Frg1CellButtonClick, кнопка "Смета" (переход к смете сметной позиции).

МОДАЛЬНЫЙ И НЕМОДАЛЬНЫЙ РЕЖИМЫ
LoadEstimate открывает диалог модально (ShowModal2, AModal = True) либо немодально (.Show,
AModal = False по умолчанию). В модальном режиме обертка дожидается закрытия диалога и сама
сохраняет результат в БД. В немодальном режиме .Show возвращает управление немедленно, а
собственно сохранение происходит позже, асинхронно - когда пользователь нажмет "Ок" в уже
открытом диалоге, SaveEstimate вызывает заранее подготовленный оберткой колбэк FOnApply (копия
OnApply из канала, см. ниже), и уже он пишет данные в БД (TOrders.ApplyEstimateArray).

ДАННЫЕ ВСЕГДА ЧЕРЕЗ МАССИВ
При вызове через обертку диалог всегда работает в режиме FUseInputArray = True и сам не читает
и не пишет estimate_items в БД. Текущий состав сметы обертка передает в готовом виде (через канал,
поле InputItems), результат редактирования диалог возвращает тем же способом (ResultItems), а
собственно запись в БД (создание/обновление позиций, простановка дат изменения и т.п.) целиком
выполняет TOrders.ApplyEstimateArray на стороне обертки. Если диалог все же открыт в обход
обертки (FUseInputArray = False) - сохранение ничего не делает, см. SaveEstimate.

БОКОВОЙ КАНАЛ (EstDlgChannels, см. TEstDlgChannel и EstDlgChannelOpen/Find/AddSource/SetResult/Close)
Общая для модуля структура EstDlgChannels (объявлена ниже) используется вместо параметров, т.к.
.Show/ShowModal2 не дают вызывающему коду прямого доступа к созданному экземпляру формы. Это
МАССИВ записей, а не одна общая запись на все диалоги - каждая запись привязана к своему Id (см.
TEstDlgChannel), и в качестве Id используется то же значение, которым уже пользуется блокировка
повторного открытия окна (AID в TOrders.LoadEstimate, оно же ID у самого диалога - см.
PrepareForm). Поскольку в рамках одного процесса нельзя открыть одну и ту же смету дважды (см.
следующий раздел), у любых одновременно открытых немодальных диалогов заведомо разные Id, и их
записи в EstDlgChannels никогда не пересекаются - в отличие от прежней реализации на общих (одних
на все диалоги) переменных, где, например, поле "источник загрузки" могло быть перезаписано
ДРУГИМ одновременно открытым немодальным диалогом раньше, чем текущий диалог будет сохранен, и
источник в лог изменений (estimate_change_log.source) для немодального режима принципиально
нельзя было уточнить корректно.
Запись канала создает обертка (EstDlgChannelOpen) непосредственно перед ShowModal2/.Show; диалог
читает ее в PrepareForm (HasInput/InputItems/OnApply) и обновляет при загрузке из файла/буфера
(SourceUsed - см. LoadFromXls/LoadFromBuffer). Удаляется запись (EstDlgChannelClose) либо
оберткой - сразу после того как она использовала результат (в модальном режиме - сразу после
ShowModal2, в немодальном - изнутри колбэка OnApply, при сохранении), либо самим диалогом, в
FormClose, если диалог закрыт БЕЗ сохранения (Отмена/крестик) - в этом случае ни обертка, ни
OnApply не вызываются и не удалят запись сами.

SourceUsed (см. TEstDlgChannel) - это СПИСОК кодов канала изменения через запятую (string, не
одиночный Integer), т.к. за одно открытие диалога может быть использовано несколько каналов
(например, загрузка из xls, а затем еще и ручная правка нескольких позиций) - см.
estimate_change_log.source (d_estimates.sql) и просмотрщик истории изменений сметы
(uFrmOWrepEstimateChanges.pas), который переводит коды в текст. Открывается канал (EstDlgChannelOpen)
всегда с пустым SourceUsed; коды добавляются по мере использования через EstDlgChannelAddSource
(без дублирования одного и того же кода) - автоматически из LoadFromXls (код 1) и LoadFromBuffer
(код 2), а код 3 (ручное редактирование) - только явным вызовом извне публичного метода
MarkManualInputChannel (см. ниже) - этот вызов НЕ добавлен в код диалога автоматически.

ОДНОВРЕМЕННОЕ РЕДАКТИРОВАНИЕ ОДНОЙ И ТОЙ ЖЕ СМЕТЫ РАЗНЫМИ ПОЛЬЗОВАТЕЛЯМИ
Блокировка повторного открытия (см. TOrders.LoadEstimate, TFrmBasicMdi.TestMultiInstances,
Wh.BringToFrontIfExists) хранит список открытых окон в памяти конкретного запущенного процесса
Учет.exe - она работает только в пределах одного процесса и сама по себе не защищает от того, что
смету одновременно откроют и будут редактировать разные пользователи на разных компьютерах.
Для этого в PrepareForm дополнительно берется серверная блокировка по документу (см. FormDbLock,
Q.DBLock, таблица adm_locks) по тому же ключу (FormDoc, ID) - если смету в момент открытия уже
редактирует другой пользователь, Mode понижается до fView (только просмотр) с предупреждающим
сообщением (текст формирует сам Q.DBLock), грид переводится в режим только чтения (см.
Frg1.Opt.SetGridOperations в PrepareForm), а кнопки загрузки/замены сметы скрываются (см.
PrepareFormAdd) - т.е. конфликт одновременного редактирования предотвращается заранее, а не
обнаруживается постфактум. Снимается блокировка автоматически при закрытии формы (см.
TFrmBasicMdi.FormClose) - никаких дополнительных действий для ее освобождения не требуется. Для
только что создаваемой сметы (Mode = fAdd, FIdEstimate еще null) блокировка не берется вовсе -
как и для любых других fAdd-диалогов в проекте (см. Q.DBLock - блокирует только fEdit/fDelete).
Само сохранение (TOrders.ApplyEstimateArray), тем не менее, по-прежнему каждый раз полностью
пересобирает состав сметы по массиву, снятому в редакторе (все текущие позиции сначала помечаются
на удаление, затем заново создаются/обновляются по переданному массиву, а оставшиеся помеченными -
удаляются) - серверная блокировка защищает от ОДНОВРЕМЕННОГО редактирования, но не от устаревшего
снимка вообще (например, если первый пользователь успел закрыть диалог и снять блокировку до
того, как второй его открыл, - тогда второй все равно откроется в режиме редактирования со своим,
уже не самым свежим на момент сохранения, снимком). Для обнаружения такой ситуации в estimates
добавлено поле dt_changed_any (дата любого изменения сметы, проставляется в коде - см.
TOrders.ApplyEstimateArray), но сама проверка "не изменилась ли смета с момента открытия диалога"
пока не реализована - на данный момент это поле только фиксируется, но нигде не сравнивается и не
используется.
}
unit uFrmOGedtEstimate;
interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uFrmBasicEditabelGrid,
  uNamedArr
  ;
type
  TFrmOGedtEstimate = class(TFrmBasicEditabelGrid)
  private
    //контекст текущей сметы (см. PrepareForm)
    FIdEstimate: Variant;     //айди сметы (estimates.id); null, если смета еще не создана (режим добавления, см. Mode := fAdd) -
                               //тип именно Variant, а не Integer: значение приходит из QLoadValue и может быть null
    FIdOfStdItem: Integer;    //айди стандартного изделия, к которому смета (непосредственно, или из спецификации заказа)
    FGroupOfItem: Integer;    //группа (не подгруппа!) стандартных изделий, к которой относится изделие сметы
    FTypeOfItem: string;      //тип изделия, к которому относится смета (Н,П,О,ПФ)
    FFormatCaption: string;   //подпись формата/спецификации для заголовка окна (только для AddParam = 1)
    FName: string;            //наименование изделия для заголовка окна
    FUseInputArray: Boolean;  //признак того, что смета получена/передается через массив (обертка), а не через прямую привязку к БД
    FOnApply: TProc;          //колбэк для немодального режима - копируется из записи бокового канала (см.
                               //TEstDlgChannel/EstDlgChannelOpen) в момент создания формы (см. PrepareForm),
                               //т.к. привязан к КОНКРЕТНОМУ экземпляру и вызывается позже, асинхронно, при
                               //сохранении; если не назначен - сохранение через массив не выполняет никаких
                               //действий (см. SaveEstimate)
    FEstimateSaved: Boolean;  //признак того, что сохранение через массив (SaveEstimate) успешно состоялось -
                               //используется в FormClose, чтобы понять, нужно ли самостоятельно подчистить за
                               //собой запись бокового канала (если диалог закрыт без сохранения - см. FormClose)

    //подготовка и закрытие формы
    function  PrepareForm: Boolean; override;
    function  PrepareFormAdd: Boolean; override;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);  //не override (в TFrmBasicMdi не virtual) - см.
                                                                      //общий комментарий в начале модуля, раздел
                                                                      //про боковой канал

    //обработчики событий грида сметных позиций (Frg1)
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure LoadItemFromDB(Row: Integer);
    //"Создать полуфабрикат" (кнопка тега cBtnCreateSemiproduct - см. PrepareFormAdd/Frg1ButtonClick) - см.
    //подробный комментарий у реализации
    procedure CreateSemiproductFromRow;
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;
    procedure Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; Filtered: Boolean; var Value: Variant; var Msg: string); override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); override;
    procedure Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure btnClick(Sender: TObject); override;  //похоже, не используется - тело ничего не делает с считанным Tag

    //проверка данных
    procedure VerifyRow(Row: Integer; Filtered: Boolean);
    procedure VerifyTable(AReloadStatus: boolean = False);
    procedure VerifyBeforeSave; override;

    //сохранение и загрузка сметы
    function  Save: Boolean; override;
    function  SaveEstimate: Boolean;
    procedure LoadFromDB;
    procedure LoadFromXls;
    procedure LoadFromBuffer;
    procedure SaveEstimateToBuffer;
  protected
  public
    //фиксирует использование канала "ручное редактирование" (код 3) для текущей сметы, в дополнение к уже
    //зафиксированным (загрузка из xls/буфера) - см. TEstDlgChannel.SourceUsed и общий комментарий в начале
    //модуля, раздел БОКОВОЙ КАНАЛ. Вызывается извне, самим вызывающим кодом (не из этого модуля) - в тех
    //местах, где он считает нужным явно пометить, что пользователь редактировал смету вручную. Если диалог
    //открыт в обход обертки TOrders.LoadEstimate (FUseInputArray = False) - ничего не делает
    procedure MarkManualInputChannel;
  end;


type
  //запись "бокового канала" (см. общий комментарий в начале модуля) для ОДНОГО открытого диалога сметы,
  //идентифицируемого Id - тем же значением, которым уже пользуется блокировка повторного открытия окна
  //(AID в TOrders.LoadEstimate, оно же ID у самого диалога)
  TEstDlgChannel = record
    Id: Variant;
    HasInput: Boolean;      //True - диалог должен работать с массивом (InputItems/ResultItems), а не с БД напрямую
    InputItems: TNamedArr;  //входной массив (текущий состав сметы: name;id_group;id_unit;qnt1;comm)
    ResultItems: TNamedArr; //результат редактирования (тот же состав полей), заполняется при успешном сохранении
    SourceUsed: string;     //список кодов источника (через запятую, без дублей) для estimate_change_log.source
                             //(см. TOrders.LogEstimateChange, EstDlgChannelAddSource) - изначально пустая строка
    OnApply: TProc;         //колбэк для немодального режима (.Show вместо ShowModal2) - см. FOnApply
  end;

var
  FrmOGedtEstimate: TFrmOGedtEstimate;
  //"боковой канал" для передачи массива-снимка сметы в диалог и получения отредактированного массива обратно -
  //массив записей (TEstDlgChannel), по одной на каждый одновременно открытый диалог сметы, см. TEstDlgChannel и
  //общий комментарий в начале модуля
  EstDlgChannels: array of TEstDlgChannel;

//найти запись канала по Id; возвращает False, если записи нет (диалог открыт в обход обертки TOrders.LoadEstimate)
function EstDlgChannelFind(const AId: Variant; out AChannel: TEstDlgChannel): Boolean;
//создать (или полностью перезаписать, если уже была) запись канала для AId - вызывается оберткой перед ShowModal2/.Show;
//ASourceUsed - начальный список кодов источника (как правило, пустая строка - см. общий комментарий в начале модуля)
procedure EstDlgChannelOpen(const AId: Variant; AHasInput: Boolean; const AInputItems: TNamedArr; ASourceUsed: string; AOnApply: TProc);
//добавить код канала ASourceCode в список SourceUsed уже открытого канала AId (без дублирования, если код там уже есть) -
//вызывается диалогом из LoadFromXls/LoadFromBuffer, а также извне - из MarkManualInputChannel; если записи нет - ничего не делает
procedure EstDlgChannelAddSource(const AId: Variant; ASourceCode: Integer);
//обновить ResultItems для уже открытого канала AId - вызывается диалогом из SaveEstimate; если записи нет - ничего не делает
procedure EstDlgChannelSetResult(const AId: Variant; const AResultItems: TNamedArr);
//удалить запись канала для AId (если она есть) - вызывается либо оберткой сразу после использования результата,
//либо самим диалогом в FormClose, если диалог был закрыт без сохранения
procedure EstDlgChannelClose(const AId: Variant);


implementation

uses
  uOrders,
  uFrmODedtOrStdItem,
  uWindows
  ;


{$R *.dfm}

const
  cIdSemiproduct = 2;
  cIdProduct = 104;
  cIdStuff = 1;
  cIdKrep = 103;
  //кастомный тег кнопки "Создать полуфабрикат" (см. PrepareFormAdd/Frg1ButtonClick/CreateSemiproductFromRow) -
  //число сохранено таким же, каким оно уже было в предыдущей (нерабочей, закомментированной) заготовке этой
  //кнопки и в уже существующем Frg1SelectedDataChange (управление доступностью кнопки по текущей строке)
  cBtnCreateSemiproduct = 1001;


function EstDlgChannelIndex(const AId: Variant): Integer;
//внутренний поиск по массиву EstDlgChannels; -1, если не найдено
begin
  for var i := 0 to High(EstDlgChannels) do
    if EstDlgChannels[i].Id = AId then
      Exit(i);
  Result := -1;
end;

function EstDlgChannelFind(const AId: Variant; out AChannel: TEstDlgChannel): Boolean;
var
  i: Integer;
begin
  i := EstDlgChannelIndex(AId);
  Result := i >= 0;
  if Result then
    AChannel := EstDlgChannels[i];
end;

procedure EstDlgChannelOpen(const AId: Variant; AHasInput: Boolean; const AInputItems: TNamedArr; ASourceUsed: string; AOnApply: TProc);
var
  i: Integer;
  LChannel: TEstDlgChannel;
begin
  LChannel.Id := AId;
  LChannel.HasInput := AHasInput;
  LChannel.InputItems := AInputItems;
  LChannel.SourceUsed := ASourceUsed;
  LChannel.OnApply := AOnApply;
  i := EstDlgChannelIndex(AId);
  if i < 0 then begin
    SetLength(EstDlgChannels, Length(EstDlgChannels) + 1);
    i := High(EstDlgChannels);
  end;
  EstDlgChannels[i] := LChannel;
end;

procedure EstDlgChannelAddSource(const AId: Variant; ASourceCode: Integer);
var
  i: Integer;
  LCode: string;
begin
  i := EstDlgChannelIndex(AId);
  if i < 0 then
    Exit;
  LCode := IntToStr(ASourceCode);
  //не дублируем код, если он уже есть в списке (сравниваем с разделителями по краям, чтобы не спутать, например, "1" и "21")
  if Pos(',' + LCode + ',', ',' + EstDlgChannels[i].SourceUsed + ',') > 0 then
    Exit;
  if EstDlgChannels[i].SourceUsed = ''
    then EstDlgChannels[i].SourceUsed := LCode
    else EstDlgChannels[i].SourceUsed := EstDlgChannels[i].SourceUsed + ',' + LCode;
end;

procedure EstDlgChannelSetResult(const AId: Variant; const AResultItems: TNamedArr);
var
  i: Integer;
begin
  i := EstDlgChannelIndex(AId);
  if i >= 0 then
    EstDlgChannels[i].ResultItems := AResultItems;
end;

procedure EstDlgChannelClose(const AId: Variant);
var
  i: Integer;
begin
  i := EstDlgChannelIndex(AId);
  if i >= 0 then
    Delete(EstDlgChannels, i, 1);
end;

function TFrmOGedtEstimate.PrepareForm: Boolean;
var
  o: TFrDBGridEditOptions;
  va: TVarDynArray;
  LChannel: TEstDlgChannel;
begin
  Caption := 'Смета';
  //получим айди сметы по айди стандартного изделия или заказа
  if AddParam = 1 then begin
    FIdOfStdItem := ID;
    FIdEstimate := Q.QLoadValue('select id from estimates where id_std_item = :id$i', [ID]);
    FName := Q.QLoadValue('select name from v_or_std_items where id = :id$i', [ID]);
    FTypeOfItem := Q.QLoadValue('select type_name from v_or_std_items where id = :id$i', [ID]);
    FFormatCaption  := Q.QLoadValue('select or_format_name || '' / '' || or_format_estimate_name || '' ['' || prefix || '']'' from v_or_std_items where id = :id$i', [ID]);
  end
  else begin
    FIdOfStdItem := Q.QLoadValue('select id_std_item from order_items where id = :id$i', [ID]);
    FIdEstimate := Q.QLoadValue('select id from estimates where id_order_item = :id$i', [ID]);
    va := Q.QLoadRow('select slash || '' '' || name, id_order, qnt from v_order_items where id = :id$i', [ID]);
    FName := va[0];
    FTypeOfItem := 'И';
  end;
  //если сметы еще нет, то перейдем в режим добавления
  if  FIdEstimate = null then
    Mode := fAdd;
  //защита от одновременного редактирования одной и той же сметы разными пользователями (серверная блокировка,
  //см. общий комментарий в начале модуля) - для fAdd ничего не делает, для fEdit при конфликте понижает Mode
  //до fView и показывает предупреждение с именем пользователя, уже редактирующего смету
  if FormDbLock = fNone then
    Exit;
  //получим айди группы (не подгруппы!) стандартных изделий для данной позиции
  FGroupOfItem := Q.QLoadValue('select id_format from or_format_estimates where id = (select id_or_format_estimates from or_std_items where id = :id$i)', [FIdOfStdItem]);
  //заголовочный лейбл
  FTitleTexts := [S.IIf(AddParam = 1, 'Смета к ' +
    S.Decode([FTypeOfItem, 'О', 'отгрузочному стандартному изделию', 'П', 'производственному стандартному изделию', 'ПФ', 'полуфабрикату', 'стандартному изделию'])  + '  ' +
    FFormatCaption + ':', 'Смета к изделию заказа:'),  {'$FF0000' + } FName];
  pnlTop.Height := 50;
  //прочитаем список групп и ед.изм.
  Orders.LoadBcadGroups(True);
  //теги - 1 = читать при обновлении, 2 = записать
  Frg1.Options := Frg1.Options - [myogSaveOptions];
  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['id_estimate$i','_ide','40'],
    ['id_or_std_item$i','_id_or_std_item','40','t=1,2'],
    ['id_item_estimate$i','_id_item_estimate','40','t=1,2'],
    ['type_of_item$s','Изделие','85', 'bt=Изделие:И:::009;Смета:С:::909'{, 'pic=;П;ПФ;Н;О:0;7;7;8;9:+'},'t=1'],
    ['id_group$i','Группа','250;w;L','e=1:100000:0:N','t=1,2'],
    ['name$s','Наименование','400;w;h','e=1:1000',
      'bt=Выбрать материал:М:::090' + S.IIFStr(FTypeOfItem <> 'П', ';Выбрать полуфабрикат:П:::909') + S.IIFStr(FTypeOfItem = 'О', ';Выбрать производственное изделие:И:::009') {+ ';Выбрать нестандартное изделие:Н:::000','t=1'}],
    ['id_unit$i','Ед.изм.','100;L','e=1:1000000:0:N','t=1,2'],
    ['qnt1$f','Кол-во','80','e=0:999999:5:N','t=1,2'], {недопустимо пустое кол-во}
    ['qnt_on_stock$f','На складе','80','t=1'],
    //['null as purchase$i','Покупка','80','chb','e'],
    ['comm$s','Дополнение','300;w;h','e=0:1000::TP','t=1'],
    ['null as err$i','!','20','v=0:10:0','pic=-1;1:16;17'],
    ['null as newpos$i','_newpos','40'],
    ['null as errinfo$s','_errinfo','40']
  ]);
  Frg1.Opt.SetTable('v_estimate_for_edit_dlg', 'estimate_items');
  //если смету сейчас редактирует другой пользователь (см. FormDbLock выше) - грид только для чтения
  Frg1.Opt.SetGridOperations(S.IIf(Mode in [fEdit, fAdd], 'uaid', ''));
  Frg1.Opt.SetWhere('where id_estimate = :id$i order by id_group');
  //если данные для редактирования переданы оберткой (TOrders.LoadEstimate) через боковой канал - используем их
  //вместо прямой загрузки из БД; канал ищем по своему ID (см. TEstDlgChannel, общий комментарий в начале модуля)
  FUseInputArray := EstDlgChannelFind(ID, LChannel) and LChannel.HasInput;
  if FUseInputArray then begin
    FOnApply := LChannel.OnApply;
    Frg1.SetInitData(LChannel.InputItems);
  end
  else
    Frg1.SetInitData('*', [FIdEstimate]);
  Frg1.Opt.Caption := 'Сметные позиции';
  Frg1.Opt.SetPick('id_group', A.VarDynArray2ColToVD1(Orders.BcadGroups, 0), A.VarDynArray2ColToVD1(Orders.BcadGroups, 1), True);
  Frg1.Opt.SetPick('id_unit', A.VarDynArray2ColToVD1(Orders.BcadUnits, 0), A.VarDynArray2ColToVD1(Orders.BcadUnits, 1), True);
  //Frg1.Opt.SetPick('type', ['Материал', 'Изделие', 'Полуфабрикат'], [0, 1, 2], True);
  O.AlwaysVerifyAllTable:= True;
  O.FieldsNoRepaeted:=['name'];
  Frg1.EditOptions := O;
  FOpt.InfoArray:= [[
  'Ввод сметы.'#13#10
  ]];
  Result := inherited;
  if not Result then
    Exit;
  if Frg1.GetRawCount = 0 then
    Frg1.AddRow;
  //проверим таблицу (с запросом к бд по каждой позиции)
  //VerifyTable;
end;

function TFrmOGedtEstimate.PrepareFormAdd: Boolean;
begin
  //загрузка/замена сметы целиком (mbtExcel/mbtLoad/mbtFromClipboard) недоступна, если смету сейчас редактирует
  //другой пользователь и мы открылись в режиме "только просмотр" (см. FormDbLock в PrepareForm); mbtToClipboard -
  //это чтение (копирование в буфер), его оставляем доступным всегда
  Frg1.Opt.SetButtons(4, [
    [mbtExcel, Mode <> fView, 'Загрузить смету из файла'],
    [mbtLoad, Mode <> fView, 'Загрузить текущую смету из БД'],
    [mbtToClipboard, True, 'Скопировать смету в буфер'],
    [mbtFromClipboard, Mode <> fView, 'Вставить смету из буфера'],
    [mbtInsertRow, alopInsertEh in Frg1.Opt.AllowedOperations],
    [mbtAddRow, alopAppendEh in Frg1.Opt.AllowedOperations],
    [mbtDeleteRow, alopDeleteEh in Frg1.Opt.AllowedOperations],
    [mbtDividorA],
    [-cBtnCreateSemiproduct, alopUpdateEh in Frg1.Opt.AllowedOperations, 'Создать полуфабрикат']
    ], cbttBSmall, pnlFrmBtnsR
  );
  Frg1.Opt.SetButtonsIfEmpty([mbtExcel, mbtFromClipboard, mbtInsertRow]);
  Result := True;
end;

procedure TFrmOGedtEstimate.FormClose(Sender: TObject; var Action: TCloseAction);
//не override - в TFrmBasicMdi.FormClose (см. uFrmBasicMdi.pas) не virtual, поэтому просто переопределяем
//метод с тем же именем; т.к. связывание события OnClose идет по имени метода, это корректно перехватывает
//закрытие формы и для этого (унаследованного через .dfm) обработчика - подробнее см. общий комментарий в
//начале модуля, раздел про боковой канал
begin
  //если диалог закрывается БЕЗ успешного сохранения (Отмена/крестик) - ни обертка (после ShowModal2 в
  //модальном режиме), ни колбэк FOnApply (в немодальном) не вызовутся и не удалят за собой запись бокового
  //канала; подчистим ее сами, чтобы она не осталась висеть до следующего открытия той же сметы
  if FUseInputArray and not FEstimateSaved then
    EstDlgChannelClose(ID);
  inherited FormClose(Sender, Action);
end;

procedure TFrmOGedtEstimate.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
//   Cth.SetButtonState(Fr, cBtnCreateSemiproduct, null, null, Fr.GetValue('id_group') = cIdSemiproduct);
//   Cth.SetButtonState(Fr, 1002, null, null, Fr.GetValue('id_group') = cIdSemiproduct);
end;

procedure TFrmOGedtEstimate.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
//обработка нажатий кнопок фрейма
begin
  Handled := True;
  if (Tag = mbtLoad) and (FIdEstimate <> null) and (MyQuestionMessage('Загрузить текущую смету из базы данных?') = mrYes) then
    Frg1.LoadData('*', [FIdEstimate])
  else if Tag = mbtExcel then
    LoadFromXls
  else if Tag = mbtFromClipboard then
    LoadFromBuffer
  else if Tag = mbtToClipboard then
    SaveEstimateToBuffer
  else if Tag = cBtnCreateSemiproduct then
    CreateSemiproductFromRow
  else if Tag = mbtDeleteRow then begin
    Frg1.DeleteRow;
    VerifyTable;
  end
  else begin
    Handled := False;
    inherited;
  end;
end;

procedure TFrmOGedtEstimate.Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
//обработка нажатий кнопок в таблице
begin
  Wh.SelectDialogResult := [];
  if TCellButtonEh(Sender).Hint = 'Выбрать материал' then begin
    Wh.ExecReference(myfrm_R_bCAD_Nomencl_SelMaterials, Self, [myfoDialog, myfoModal], null);
    if Length(Wh.SelectDialogResult) = 0 then
      Exit;
    MarkManualInputChannel;
    Frg1.SetValue('name', Wh.SelectDialogResult[2]);
    LoadItemFromDB(Frg1.RecNo - 1);
  end
  else if TCellButtonEh(Sender).Hint = 'Выбрать полуфабрикат' then begin
    Wh.ExecReference(myfrm_R_OrderStdItems_SelSemiproduct, Self, [myfoDialog, myfoModal], FGroupOfItem);
    if Length(Wh.SelectDialogResult) = 0 then
      Exit;
    MarkManualInputChannel;
    Frg1.SetValue('name', Wh.SelectDialogResult[1]);
    LoadItemFromDB(Frg1.RecNo - 1);
  end
  else if TCellButtonEh(Sender).Hint = 'Выбрать производственное изделие' then begin
    Wh.ExecReference(myfrm_R_OrderStdItems_SelProdStdItem, Self, [myfoDialog, myfoModal], FGroupOfItem);
    if Length(Wh.SelectDialogResult) = 0 then
      Exit;
    MarkManualInputChannel;
    Frg1.SetValue('name', Wh.SelectDialogResult[1]);
    LoadItemFromDB(Frg1.RecNo - 1);
  end
  else if TCellButtonEh(Sender).Hint = 'Выбрать нестандартное изделие' then begin
    Wh.ExecReference(myfrm_R_OrderStdItems_SelProdNStdItem, Self, [myfoDialog, myfoModal], FGroupOfItem);
    if Length(Wh.SelectDialogResult) = 0 then
      Exit;
    MarkManualInputChannel;
    Frg1.SetValue('name', Wh.SelectDialogResult[1]);
    LoadItemFromDB(Frg1.RecNo - 1);
  end
  else if TCellButtonEh(Sender).Hint = 'Выбрать изделие' then begin
    Wh.ExecReference(myfrm_R_OrderStdItems_SEL, Self, [myfoDialog, myfoModal], null);
    if Length(Wh.SelectDialogResult) = 0 then
      Exit;
    MarkManualInputChannel;
    Frg1.SetValue('name', Wh.SelectDialogResult[1]);
    LoadItemFromDB(Frg1.RecNo - 1);
  end
  else if TCellButtonEh(Sender).Hint = 'Смета' then begin
    //редактирование сметы к сметной позиции (если позиция сама является стандартным изделием и имеет свою смету -
    //см. p_test_estimate_item/VerifyRow) - открываем не напрямую через форму, а той же оберткой, что и везде
    //(TOrders.LoadEstimate), чтобы сохранение, блокировка окна и признак "нет сметы" работали единообразно
    if not ((Frg1.GetValueS('type_of_item') = '') or (Frg1.GetValueS('type_of_item') = 'Н')) and (Fr.GetValueS('id_item_estimate') <> '') then
      Orders.LoadEstimate(null, null, Fr.GetValue('id_or_std_item'));
  end
  else if TCellButtonEh(Sender).Hint = 'Изделие' then begin
    if not ((Frg1.GetValueS('type_of_item') = '') or (Frg1.GetValueS('type_of_item') = 'Н')) then begin
      //AddParam теперь VarArrayOf([IdOrFormatEstimate, CallMode]) - см. общий комментарий в начале Prepare
      //(uFrmODedtOrStdItem.pas); CallMode = 1, подгруппу передаем как 0 (Null) - Prepare сам определит
      //реальную подгруппу изделия по переданному AId (см. новый блок резолвинга FIdOrFormatEstimate там же -
      //задача пользователя "переделать вызов диалога без справочника, чтобы открывался на редактирование/
      //просмотр так же, по переданному айди изделия"). Режим - редактирование, если сама смета сейчас
      //редактируется (иначе только просмотр - как и было раньше); прочие ограничения (права на цены и т.п.)
      //проверяются уже внутри самого диалога изделия.
      var LItemMode := fView;
      if Mode = fEdit then
        LItemMode := fEdit;
      Wh.ExecDialog(myfrm_Dlg_R_OrderStdItems, nil, [], LItemMode, Fr.GetValue('id_or_std_item'), VarArrayOf([0, 1]));
    end;
  end;
  VerifyRow(Fr.RecNo - 1, True);
  VerifyTable;
end;

procedure TFrmOGedtEstimate.LoadItemFromDB(Row: Integer);
//загрузим из базы информацию по данному наименованию сметной позиции
var
  na: TNamedArr;
begin
  Q.QLoadRow('select ' + Frg1.GetFieldNamesEx('1').Implode(', ') + ' from ' + Frg1.Opt.Sql.View + ' where name = :name$s', [Frg1.GetValue('name', Row, True)], na);
  if na.Count > 0 then
    Frg1.LoadRow(na, Row, True);
end;

procedure TFrmOGedtEstimate.CreateSemiproductFromRow;
//"Создать полуфабрикат" (кнопка тега cBtnCreateSemiproduct, см. PrepareFormAdd/Frg1ButtonClick) - для текущей
//строки сметы, уже отнесенной к группе "Полуфабрикаты" (см. Frg1SelectedDataChange - доступность кнопки), но
//наименование которой введено вручную и пока не соответствует ни одному реальному изделию в справочнике
//(id_or_std_item еще не определен). Открывает диалог добавления изделия (uFrmODedtOrStdItem) МОДАЛЬНО, режимом
//CallMode = 4 (добавление в ЛЮБУЮ активную подгруппу полуфабрикатов - см. общий комментарий у FCallMode там же),
//с этим наименованием, подставленным по умолчанию (пользователь может изменить его прямо в диалоге).
//Проверка конфликтов имени (с другими полуфабрикатами/нестандартными/стандартными изделиями) выполняется
//штатным механизмом самого диалога при сохранении (VerifyBeforeSave/CheckSemiproductNameConflicts,
//uFrmODedtOrStdItem.pas) - при конфликте диалог просто не даст сохранить, и мы получим ModalResult <> mrOk.
//После успешного создания подставляет окончательное (возможно, измененное пользователем в диалоге) имя нового
//изделия в текущую строку сметы и подгружает по нему данные - тем же способом, что и остальные целлбаттоны
//выбора изделия (см. Frg1CellButtonClick).
var
  LName: string;
  LRes: TMDIResult;
  LNewName: Variant;
begin
  LName := Trim(Frg1.GetValueS('name'));
  if LName = '' then begin
    MyWarningMessage('Сначала введите наименование позиции в столбце "Наименование".');
    Exit;
  end;
  //опции - те же, что и по умолчанию использует диспетчер Wh.ExecDialog для этого же диалога (см. ExecDialog,
  //uWindows.pas) плюс myfoSizeable; вызываем ShowModal2 напрямую, в обход диспетчера, т.к. только так можно
  //получить обратно TMDIResult с id созданного изделия (Wh.ExecDialog - процедура, результат вызова .Show
  //внутри нее отбрасывается) - см. общий комментарий выше и FFormResult.Data в TFrmODedtOrStdItem.Save
  LRes := TFrmODedtOrStdItem.ShowModal2(nil{при Self обновит этот диалог!}, myfrm_Dlg_R_OrderStdItems, [myfoDialog, myfoRefreshParent, myfoMultiCopy, myfoSizeable], fAdd, Null, VarArrayOf([Null, 4, LName]));
  if (LRes.ModalResult <> mrOk) or (LRes.Data = Null) then
    Exit;
  MarkManualInputChannel;
  LNewName := Q.QLoadValue('select name from or_std_items where id = :id$i', [LRes.Data]);
  Frg1.SetValue('name', LNewName);
  LoadItemFromDB(Frg1.RecNo - 1);
  VerifyRow(Frg1.RecNo - 1, True);
end;

procedure TFrmOGedtEstimate.Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
//после ручного ввода данных в ячейку
begin
  //при изменении наименования - загрузим по нему информацию из бд
  if A.InArray(FieldName, ['name']) then
    LoadItemFromDB(Fr.RecNo - 1);
  //при изменении наименования или группы проверяем валидность, выполняя хранимую процедуру
  if A.InArray(FieldName, ['name', 'id_group']) then begin
    VerifyRow(Fr.RecNo - 1, True);
  end;
end;

procedure TFrmOGedtEstimate.Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; Filtered: Boolean; var Value: Variant; var Msg: string);
//выполняем действия после изменения данных в ячейках таблицы вручную (тело пока пустое)
begin
  //проставим признак Ручное изменение, если менялись наименование или количество
  if (Mode = dbgvBefore) and A.InArray(FieldName, ['name', 'qnt1']) then
    MarkManualInputChannel;
end;

procedure TFrmOGedtEstimate.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
//подсветим ошибки и предупреждения
begin
  if Fr.GetValue('newpos').AsIntegerM = 1 then
    Params.Background := clYellow;
  if (FieldName = 'qnt_on_stock') and (Fr.GetValue('qnt_on_stock') <> null) and (Fr.GetValue('qnt1') <> null) then begin
    if Fr.GetValueF('qnt_on_stock') = 0 then
      Params.Background := clRed
    else if Fr.GetValueF('qnt1') > Fr.GetValueF('qnt_on_stock') then
      Params.Background := clYellow;
  end;
  if (FieldName = 'type_of_item') then begin
    if (Fr.GetValueS('id_item_estimate') = '') and (A.InArray(Fr.GetValueS('type_of_item'), ['П', 'ПФ'])) then
      Params.Font.Color := clRed;
    if (Fr.GetValueS('type_of_item') = 'О') then
      Params.Background := clRed;
  end;
  if (FieldName = 'name') then begin
    var st := Fr.GetValueS('name');
    if (Trim(st) <> st) or (Pos('  ', st) > 0) then
      Params.Background := clRed;
    //совпадение с именем или полным именем с префиксом изделия (стандартного или заказа)
//    if (st = AddParam[3]) or (st = AddParam[4]) then
//      Background := clRed;
  end;
end;

procedure TFrmOGedtEstimate.Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
  //запретим менять ед.изм. у готовых изделий и пф
  if ((Fr.GetValueI('id_group') = cIdProduct) or (Fr.GetValueI('id_group') = cIdSemiproduct)) and ({(Fr.CurrField = 'id_group') or }(Fr.CurrField = 'id_unit')) then
    ReadOnly := True;
  //запретим ставить галку покупное, если это не ПФ
  if (Fr.GetValueI('id_group') <> cIdSemiproduct) and (Fr.CurrField =  'purchase') then
    ReadOnly := True;
end;

procedure TFrmOGedtEstimate.Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
  if (Fr.CurrField = 'err') and (Fr.GetValueI('err') <> 0) then
    MyInfoMessage(Fr.GetValueS('errinfo'), 1);
end;

procedure TFrmOGedtEstimate.btnClick(Sender: TObject);
var
  Tag: Integer;
begin
  Tag := TControl(Self).Tag;
end;

procedure TFrmOGedtEstimate.VerifyRow(Row: Integer; Filtered: Boolean);
//проверим на ошибки (типа: это по группе материал, но есть в справочнике стд.изд.), запросив БД. сохраним результат в служебном столбце
const
  c = 3;
begin
  {
  p_estimate_type in varchar2, --тип объекта, к которому смета (П,О,ПФ,Н)
  p_group_id    in  number,  --айди группы бкад
  p_name        in  varchar2,--наименование
  p_group_std   in  number,  --айди группы стандартных изделий для родительской сметы
  p_result      out number,  --тип результата: 0 = ок, -1 = ошибка, 1 - предупреждение
  p_id_std_item out number,  --айди стандартнорго изделия для данной позиции
  p_id_estimate out number,  --айди сметы по данной позиции
  p_type_of_item out varcahr2,  --тип стандартного изделия ('',П,О,ПФ,Н)
  p_is_new_position out number,  --позиции нет в ИТМ
  p_message      out varchar2  --текст ошибки, или сообщения
  }
  var Res := Q.QCallStoredProc('p_test_estimate_item',
    'i1$s;i2$i;i3$s;i4$i;' +
    'o1$io;o2$io;o3$io;o4$so;o5$io;o6$so',
    [FTypeOfItem, Frg1.GetValue('id_group', Row, Filtered), Frg1.GetValueS('name', Row, Filtered), FGroupOfItem, -1, -1, -1, '', -1, '']);
  Frg1.SetValue('err', Row, Filtered, Res[c + 1]);
  Frg1.SetValue('id_or_std_item', Row, Filtered, Res[c + 2]);
  Frg1.SetValue('id_item_estimate', Row, Filtered, Res[c + 3]);
  Frg1.SetValue('type_of_item', Row, Filtered, Res[c + 4]);
  Frg1.SetValue('newpos', Row, Filtered, Res[c + 5]);
  Frg1.SetValue('errinfo', Row, Filtered, Res[c + 6]);
end;

procedure TFrmOGedtEstimate.VerifyTable(AReloadStatus: boolean = False);
//проверяем данные в таблице путем вызова хранимой процедуры для каждой строки
begin
  for var i := 0 to Frg1.GetRawCount - 1 do begin
    VerifyRow(i, False);
  end;
  Frg1.IsTableCorrect;
end;

procedure TFrmOGedtEstimate.VerifyBeforeSave;
//стандартная процедура проверки при нажатии кнопки Ок
begin
  Frg1.SetState(null, False, '');
  if Frg1.GetRawCount = 0 then begin
    Frg1.SetState(null, True, '');
    FErrorMessage := 'Сохранить пустую смету невозможно!';
  end;
  var LErrorMessage := '';
  var LWarningMessage := '';
  //еще раз проверим путем обращения к хранимой процедуре
  VerifyTable;
  //пройдем по гриду и соберем ошибки и предупреждения
  for var i := 0 to Frg1.GetRawCount - 1 do begin
    if Frg1.GetRawValue('err', i) = -1 then
      S.ConcatStP(LErrorMessage, IntToStr(i + 1) + ' - ' + Frg1.GetRawValueS('errinfo', i), #13#10)
    else if Frg1.GetRawValue('err', i) = 1 then
      S.ConcatStP(LWarningMessage, IntToStr(i + 1) + ' - ' + Frg1.GetRawValueS('errinfo', i), #13#10);
  end;
  FErrorMessage := '';
  if LErrorMessage <> '' then begin
    Frg1.SetState(null, True, LErrorMessage);
    FErrorMessage := 'В смете есть ошибки:'#13#10#13#10 + LErrorMessage + #13#10#13#10'Сохранить смету невозможно!';
  end
  else if Frg1.HasError then begin
    FErrorMessage := 'В смете есть ошибки:'#13#10'Сохранить смету невозможно!';
  end
  else if LWarningMessage <> '' then begin
    FErrorMessage := '?' + 'Есть следующие замечания по смете:'#13#10#13#10 + LWarningMessage + #10#13#10#13'Записать смету?';
  end;
end;

function TFrmOGedtEstimate.Save: Boolean;
begin
  Result := SaveEstimate;
end;

function TFrmOGedtEstimate.SaveEstimate: Boolean;
begin
  Result := False;
  if FUseInputArray then begin
    //проставим признак, что было ручное изменение, в случае если были удалены строки
    if Frg1.EditData.IdsDeleted.Count > 0 then
      MarkManualInputChannel;
    //режим "массив в/массив из" (вызов из обертки TOrders.LoadEstimate) - в БД ничего не пишем, а только
    //формируем результирующий массив и кладем его в запись бокового канала (по своему ID), откуда его заберет
    //и сохранит сама обертка
    EstDlgChannelSetResult(ID, Frg1.ExportToNa('id;id_estimate;id_or_std_item;id_item_estimate;type_of_item;id_group;name;id_unit;qnt1;qnt_on_stock;comm', False));
    //немодальный режим (.Show): синхронного возврата в обертку не будет, поэтому применяем результат сами -
    //через колбэк, подготовленный оберткой заранее (см. TOrders.LoadEstimate, ветка AModal = False)
    if Assigned(FOnApply) then
      FOnApply();
    FEstimateSaved := True; //см. FormClose - при успешном сохранении запись канала подчищает сама обертка
    Result := True;
  end;
end;

procedure TFrmOGedtEstimate.LoadFromDB;
begin
  Frg1.SetInitData('*', [ID]);
  VerifyTable;
end;

procedure TFrmOGedtEstimate.LoadFromXls;
//загрузим смету из файла эксель
var
  i: Integer;
  Est: TVarDynArray2;
  FileName: string;
  va2: TVarDynArray2;
  st : string;
begin
  FileName := '';
  //смету в массив
  if not Orders.EstimateFromFile(FileName, Est) then
    Exit;
  EstDlgChannelAddSource(ID, 1);
  //массив в мемтейбл
  Frg1.LoadSourceDataFromArray(Est, 'name;id_group;id_unit;qnt1;comm', '');
  VerifyTable;
  Exit;

  st := '';
  //пройдем по данным, проверим в группе Крепёж по короткому имени, нет ли совпадения с именем полуфабриката или изделия в группе изделий для данной сметы
  //(такая ситуация будет при выгрузке из бкад, где в эту группу выгрузятся полуфабрикаты, но без префиксов)
  //если найдено единственная такая позиция, то поставим группу, соответствующую типу изделия, если найдено несколько - очистим группу
  {for i := 0 to Frg1.GetCount(False) do begin
    if Frg1.GetValueI('id_group', i, False) = cIDKrep then begin  //Крепёж
      va2 := Q.QLoad('select fullname, id_format from v_or_std_items where name = :name$s and type = 0 and id_format = :f$i', [Frg1.GetValue('name', i, False), FGroupOfItem]);
      if Length(va2) > 0 then begin
        S.ConcatStP(st, Frg1.GetValue('name', i, False) + ' - является изделием!', #13#10);
        Frg1.SetValue('id_group', i, False, IIf(Length(va2) = 1, cIdProduct, null));
      end;
    end
    else begin
      va2 := Q.QLoad('select fullname, id_format from v_or_std_items where name = :name$s and type = 2 and (id_format = 0 or id_format = :f$i)', [Frg1.GetValue('name', i, False), FGroupOfItem]);
      if Length(va2) > 0 then begin
        S.ConcatStP(st, Frg1.GetValue('name', i, False) + ' - является полуфабрикатом!', #13#10);
        Frg1.SetValue('id_group', i, False, IIf(Length(va2) = 1, cIdSemiproduct, null));
      end;
    end;
  end;}
  //выполним проверку с чтением данных из БД
  VerifyBeforeSave;
  //выдадим сообщение, если была подмена группы
  if st <> '' then
    MyInfoMessage(st, 1);
end;

procedure TFrmOGedtEstimate.LoadFromBuffer;
//загрузим смету из личного буфера пользователя (заполняется кнопкой "Скопировать смету" в справочнике стандартных изделий,   //!!!
//см. Orders.CopyEstimateToBuffer; хранится как смета с id_estimate = -id_user)
begin
  if MyQuestionMessage('Вставить смету из буфера?') <> mrYes then
    Exit;
  if Q.QLoadValue('select count(*) from v_estimate where id_estimate = :id_estimate$i', [-User.GetId]) = 0 then begin
    MyWarningMessage('Буфер обмена смет пуст!');
    Exit;
  end;
  EstDlgChannelAddSource(ID, 2);
  Frg1.SetInitData('*', [ID]);
  VerifyTable;
end;

procedure TFrmOGedtEstimate.MarkManualInputChannel;
begin
  if FUseInputArray then
    EstDlgChannelAddSource(ID, 3);
end;

procedure TFrmOGedtEstimate.SaveEstimateToBuffer;
begin
  if MyQuestionMessage('В буфер будет скопирована уже сохраненная смета! Изменения, сделанные в этом окне без сохранения сметы, скопированы не будут! Продолжить?') <> mrYes then
    Exit;
   Orders.CopyEstimateToBuffer(S.IIf(AddParam = 1, ID, null), S.IIf(AddParam <> 1, ID, null));
end;

end.


что можно выбирать в нестандартном изделии?????
везде проверить работу с фильтром!!!
какие кнопки выбора изделия когда нужны?
менять группу в смете для полуфабрикатов на ПФ?
заменить все такие группы скриптом?
