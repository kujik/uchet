{

Модуль, обеспечивающий выполнение фоновых задач.

----------------
Резидентный режим - общее устройство.

Сервер полностью резидентен: с каким бы параметром командной строки он ни был
запущен ("сервер.exe /задача"), после разовой попытки выполнить
соответствующую параметру задачу (см. TTasksS.ExecuteTaskByName) процесс НЕ
завершается - остаётся работать неограниченно долго, и делает две вещи:
1) обслуживает HTTP-сервер сканера штрихкодов (ScanApi, см. заголовок
   uScanApi.pas) - эта задача работает всегда, независимо от параметра, с
   которым запущен процесс, конфликтов с прочими задачами по доступу к БД нет;
2) выполняет по расписанию все прочие задачи - см. раздел "Расписание задач"
   ниже.
Единственность резидентного процесса (независимо от параметра, с которым он
запущен) обеспечена мьютексом в Uchet.dpr (CheckInstance) - мьютекс общий для
модуля Сервер целиком, параметр командной строки в его имени больше не
участвует (иначе процессы, запущенные с разными параметрами, могли бы
одновременно работать резидентно, дублируя выполнение задач).

Планировщик виндовс должен быть настроен на повторный запуск "Сервер.exe" (с
любым распознаваемым параметром, см. TTasksS.ExecuteTaskByName, либо просто
TASK_SCAN_API) каждые 5 минут (это отдельная настройка планировщика, не код) -
это даёт "сторожевой" эффект на случай аварийного завершения процесса или
сервера: если резидентный процесс жив - новый запуск тут же завершится по
мьютексу выше; если не жив (упал, либо сам завершился по любой из причин
ниже) - именно этот запуск станет новым резидентным процессом.
Индивидуальные задания планировщика для отдельных задач (/fromparsec,
/turvreport и т.п.) по мере переноса их логики в расписание (см. ниже)
становятся не нужны и постепенно удаляются - до этого момента они не мешают
резидентному процессу (просто выполняют свою задачу ещё раз при срабатывании,
см. ExecuteTaskByName).

----------------
Расписание задач.

Задача расписания - это запись в массиве ScheduledTasks: краткое название на
русском (для лога и меню ручного запуска), необязательный комментарий,
ссылка на выполняемую процедуру и расписание в формате cron (пять полей -
минута, час, день месяца, месяц, день недели; поддерживаются "*", списки,
диапазоны и шаг - см. CronMatches/CronFieldMatches). Массив заполняется один
раз при старте резидентного процесса - см. InitScheduledTasks, куда сейчас
перенесены все задачи из прежней TTasksS.HourlyTasks (время каждой из них
было и раньше жёстко задано в коде - здесь оно просто выражено в виде cron
вместо вложенных if). Задачи, время которых не привязано к уже
существующему коду (перенос со старых заданий планировщика Windows -
/fromparsec и т.п.), в расписание пока не добавлены - это делается отдельно,
по мере переноса.

Расписание проверяется раз в минуту, из TServerWatchdog (см. ниже) -
TTasksS.ProcessScheduledTasks сравнивает cron каждой задачи с каждой минутой,
прошедшей с прошлой проверки, и выполняет совпавшие задачи. Обычно это ровно
одна (текущая) минута, но диапазон может быть шире одной минуты, если
предыдущая проверка долго выполняла другую задачу (просрочка) - в этом
случае все задачи, чьё время наступило за это время (их может быть
несколько), не теряются, а выполняются одна за другой сразу после
освобождения таймера, СТРОГО В ПОРЯДКЕ ИХ РАСПОЛОЖЕНИЯ В МАССИВЕ
ScheduledTasks (а не в порядке просроченных минут).

Для ручного запуска (см. раздел "Режим разработки и выполнение заданий
вручную" ниже) выбор идёт из тех же названий задач расписания (см.
TTasksS.ScheduledTaskNames/RunScheduledTask) - отдельного списка для этого
не заводится.

----------------
Обновление сервера.

Пока сервер резидентно работает, TServerWatchdog (см. ниже в этом модуле) раз в
5 минут проверяет, не появилась ли на сервере дистрибутива новая версия exe -
тем же приёмом, что и uUpdater.CheckForUpdatesAndRunUpdater для обычных
клиентских модулей: по файлу Updater\updater.dir рядом с exe сравнивается дата
локального файла с копией на сервере (см. GetUpdateServerBasePath/
IsExeUpdateAvailable в uUpdater.pas). Сам исполняемый файл текущего процесса
при этом НЕ трогаем и не перезаписываем напрямую - на живом процессе это
приводит к краху приложения; вместо этого, как и для обычного клиента,
запускается Uchet_Updater.exe (RunUpdaterAndHalt), который дожидается закрытия
процесса и подменяет файл уже после этого - см. заголовок uUpdater.pas.

----------------
Соединение с БД.

Если пропало соединение с БД (Q.Connected = False), процесс сразу
завершается (см. TServerWatchdog.MinutelyTimerTimer) - без соединения ни
сканирование, ни прочие задачи всё равно не могут работать. Следующая
попытка запуска - через 5 минут, по сторожевому заданию планировщика (см.
выше).

----------------
Логирование.

Каждое выполнение задачи (и разовой, при старте, и по расписанию - в том
числе КАЖДАЯ отдельная задача расписания по отдельности, а не пачкой)
логируется отдельной строкой, и в файловый лог
(Module.ToLogFile), и в БД (таблица adm_db_log, см. TmyDBOra.QLog) - см.
LogTaskEvent ниже в этом модуле. Ошибка внутри отдельной задачи логируется и
не прерывает работу резидентного процесса - выполнение остальных задач (и
работа сканера штрихкодов) продолжается, см. RunLoggedTask/
ExecuteTaskByName. Это отдельный, дополнительный уровень защиты сверх
имеющегося глобального перехвата необработанных исключений (madExcept) -
последний по-прежнему завершает процесс с выводом окна (что приемлемо,
процесс перезапустится по сторожевому заданию планировщика), но благодаря
LogTaskEvent ошибка в любом случае успевает попасть в лог до этого.

----------------
Режим разработки и выполнение заданий вручную.

При наличии в каталоге программы файла "dev" (см. Module.DevFileExists) при
старте резидентного процесса выводится вопрос, выполнять ли задания по
расписанию (см. TTasksS.Run) - это позволяет поднять сервер для отладки, не
запуская автоматически реальные ежедневные/ежечасные задачи (рассылки,
изменения данных и т.п.); сканирование и самообновление при этом всё равно
продолжают работать. Независимо от режима (не только в режиме разработки),
выполнить любую задачу расписания вручную, немедленно и вне расписания,
можно через пункт главного меню "Выполнить задание..." (см.
TFrmMain.ExecuteMainMenuItem) - он показывает список названий задач
расписания (TTasksS.ScheduledTaskNames) и выполняет выбранную
(TTasksS.RunScheduledTask).

}



unit uServerTasks;

interface

uses
 Graphics, Classes, DateUtils, Variants, SysUtils, Types, Windows, uNamedArr, uString, uTasks
 ;

type
  TTasksS = record
  private
  public
    //процедура выполняется при старте модуля Сервер
    //запускает сканер штрихкодов (работает всегда) и резидентный сторож
    //(TServerWatchdog), затем выполняет разовую задачу в соответствии с
    //переданным параметром - см. заголовок модуля
    procedure Run;
    //выполняет одну задачу по её "имени" (совпадает с параметром командной
    //строки, см. константы вида "/задача" по тексту модуля и TASK_SCAN_API);
    //используется и при старте процесса (см. Run), и при выполнении задания
    //вручную (см. TFrmMain - пункт главного меню "Выполнить задание...").
    //возвращает False, если имя задачи не распознано. ошибка внутри задачи
    //не прерывает работу резидентного процесса - логируется (и в файл, и в
    //БД, см. LogTaskEvent) и выполнение продолжается
    function ExecuteTaskByName(const ATaskName: string): Boolean;
    //имена всех задач расписания (см. InitScheduledTasks в реализации) - в
    //порядке их следования в расписании - для выбора при ручном запуске
    //задания (см. TFrmMain.ExecuteMainMenuItem, пункт "Выполнить задание...")
    function ScheduledTaskNames: TVarDynArray;
    //выполняет одну задачу расписания по индексу (см. ScheduledTaskNames)
    //немедленно, вне очереди - для ручного запуска
    procedure RunScheduledTask(AIndex: Integer);

    //удаление устаревших данных
    procedure DeleteOldData;
    //получение из интернета производственного календаря
    function  GetProductionCalendar(Year: Variant): Integer;
    //посчитаем количество по сметным позициям плановых заказов для отчета и для снабжения
    procedure CalcPlannedOrders;
    //закроем период в итм с конца предыдущего до прошедшего воскресенья включительно
    procedure CloseItmWorkPeriod;
    //устанавливает в таблице заказов проиизводственные статусы и данные, взятые из ИТМ
    //(является ли заказ производственныым, дата выдачи в производство, количество плитных и кромочных материалов по смете в изделиях заказа)
    procedure SetProdustionDataForOrders;
    //отчет по заказам, по кторым не созданы сметы
    procedure ReportForOrdersWithoutEstimate;
    //ежечасный мониторинг сделаок по снабжению
    //регистрирует позиции по счетам, цена по которым была выше контрольной
    function  ReportForHorlySupplyDeals: Integer;
    //мониторинг счетов снабжения за вчерашний день, а также наличия приходных накладных без оснований
    procedure ReportForYesterdaySupplyDeals;
    //финансовый отчет по производственным или отгрузочным заказам, запущенным за вчерашний день
    //1'Отчет по производственным заказам за вчерашний день',
    //2'Отчет по производственным заказам в работе',
    //3'Отчет по отгрузочным заказам за вчерашний день',
    //4'Отчет по отгрузочным заказам в работе'
    //5'Отчет по производственным заказам за прошедшую неделю'
    //6'Отчет по производственным заказам за прошешеший месяц'
    procedure ReportForYesterdayOrders(AOrderTypes: Integer; AMailing: Boolean = True);
    //отчет по созданным в ИТМ АВР, по которым по заказу не было полного поринятия на сгп в Учете
    procedure ReportForEarlyCompletionActs;
    //отчет по сырью, находящемуся в пути при отсуствии резерва на него
    procedure ReportForSupplyisOnwaySurplus;
    //отчет по материалам на складах готовой продукции, являющихся сырьем а не изделиями
    procedure ReportForRawMaterialsOnSgp;
    //информация по актам списания и оприходования за вчерашний день
    procedure ReportForActsWriteoffReceipt;
    //отчет по номенклатурым позициям (материалы) с отрицательным оличеством на складах
    procedure ReportForNegativeQuantityOnStocks;
    //отчет по позициям на СГП (стандартные изделия) с отрицательным текущим количеством
    procedure ReportForNegativeQuantityOnSgp;
    //отчет по просроченным заказам
    //(которые не готовы после наступления плановой даты отгрузки)
    procedure ReportForOverdueOrders(AForProductionOrders: Boolean);
    //отчет по просроченным по дате начала производства производственным заказам
    procedure ReportForOverdueOrdersByStartTpoProductionDate;
    //отчет по сырью, у которого есть отрицательная (с учетом минимального остатка) потребность на текущий момент
    procedure ReportForSuppliersNegativeDemand;
    //отчет по просроченным сметам (1) и загрузкам технологов (2)
    procedure ReportForEstimatesOverdue(ObjType: Integer);
    //отчет по позициям с отрицательной потребностью из текущего состояния сгп
    procedure ReportForNegativeNeedBySgp;
    //отчет по производственным заказам, планирующемся к выдаче в производтство на завтра
    //(дата определяется следующим днем поле участка планирования по регламенту)
    procedure ReportForOrdersPlannedToStartTomorrow;
    //Недостающие материалы для производства заказов, запланированных на завтра
    procedure ReportForRequiredMaterialsForPlannedOrdersTomorrow;
    //заказы, запланированные к отгрузке сегодня, завтра и псолезавтра
    procedure ReportForPlannedShipments;
  end;

const
  //название команды запуска сервера сканера штрихкодов продукции (uScanApi.pas) -
  //отдельно от прочих задач, т.к. после её запуска процесс не завершается, а
  //остаётся резидентно висеть, обслуживая HTTP-запросы (см. TTasksS.Run)
  TASK_SCAN_API = '/scanapi';

var
  TasksS: TTasksS;


implementation

uses
  ZLib,
  uDBOra,
  uData,
  uSys,
  uTurv,
  uMessages,
  uFrmMain,
  Dialogs,
  XmlDoc,
  Xml.XMLIntf,
  uHtmlUtils,
  uExportToXlsx,
  uFrDBGridEh,
  DBGridEh,
  uOrders,
  uScanApi,
  uUpdater,
  Forms,
  Controls,
  ExtCtrls,
  IOUtils
  ;

var
  //разрешено ли выполнение заданий по расписанию (см. ProcessScheduledTasks,
  //вызывается из минутного таймера) в текущем запуске резидентного процесса;
  //в обычном режиме всегда True, в режиме разработки (Module.DevFileExists) -
  //по ответу на вопрос при старте, см. TTasksS.Run. Сканирование и проверка
  //обновлений от этого флага не зависят - работают всегда
  IsScheduleEnabled: Boolean = True;

procedure LogTaskEvent(const ATaskName, AComment: string);
//логирует событие, связанное с выполнением задачи, одновременно в файловый
//лог (Module.ToLogFile) и в БД (таблица adm_db_log, см. TmyDBOra.QLog) -
//см. заголовок модуля, раздел "Логирование". ошибку записи в БД (например,
//если только что пропало соединение) не считаем фатальной для самого
//логирования - в файл запись в любом случае уже сделана выше
begin
  Module.ToLogFile(ATaskName + ' - ' + AComment);
  try
    Q.QLog(ATaskName, AComment);
  except
  end;
end;

procedure RunLoggedTask(const ATaskName: string; ATaskProc: TProc);
//выполняет одну задачу (переданную как ссылку на процедуру) с
//индивидуальным логированием результата - см. LogTaskEvent. ошибка внутри
//задачи не прерывает работу резидентного процесса и не мешает выполнению
//остальных задач - логируется, и выполнение продолжается со следующей
//задачи (см. заголовок модуля, раздел "Логирование"); используется для
//каждой отдельной задачи расписания (см. ProcessScheduledTasks ниже), а
//не для всей пачки задач целиком
begin
  try
    ATaskProc();
    LogTaskEvent(ATaskName, 'выполнено');
  except
    on E: Exception do
      LogTaskEvent(ATaskName, 'ошибка: ' + E.Message);
  end;
end;

type
  TScheduledTaskProc = reference to procedure;

  //одна задача расписания - см. заголовок модуля, раздел "Расписание задач".
  //Cron - расписание в стандартном 5-польном формате
  //"минута час день_месяца месяц день_недели" (день недели: 0 = воскресенье,
  //1 = понедельник, ..., 6 = суббота); поддерживаются "*", список через
  //запятую ("1,3,5"), диапазон ("8-19") и шаг ("*/15", "8-19/2") - см.
  //CronMatches/CronFieldMatches ниже. День недели в расписании сознательно
  //не используется нигде в InitScheduledTasks - см. пояснение там же
  TScheduledTask = record
    Name: string;     //краткое имя на русском - в лог, в БД, в меню ручного запуска
    Comment: string;   //необязательный комментарий
    Cron: string;      //расписание
    Proc: TScheduledTaskProc;
  end;

var
  //расписание всех задач, выполняемых по времени - заполняется один раз при
  //старте резидентного процесса, см. InitScheduledTasks и TTasksS.Run. порядок
  //элементов важен - см. ProcessScheduledTasks
  ScheduledTasks: array of TScheduledTask;

function TruncToMinute(ADateTime: TDateTime): TDateTime;
//отбрасывает секунды и миллисекунды - для поминутного сравнения времени
begin
  Result := RecodeMilliSecond(RecodeSecond(ADateTime, 0), 0);
end;

function CronFieldMatches(const AField: string; AValue: Integer): Boolean;
//проверяет, попадает ли AValue в одно поле расписания в стиле cron -
//поддерживается "*", список через запятую ("1,3,5"), диапазон ("8-19") и
//шаг ("*/15" или "8-19/2"). поля принимают только числа (без имён месяцев
//или дней недели)
var
  Parts, RangeParts: TStringDynArray;
  i, RangeFrom, RangeTo, Step: Integer;
  Part, RangeSt, StepSt: string;
begin
  Result := False;
  Parts := A.ExplodeS(AField, ',');
  for i := 0 to High(Parts) do begin
    Part := Trim(Parts[i]);
    if Pos('/', Part) > 0 then begin
      RangeSt := Copy(Part, 1, Pos('/', Part) - 1);
      StepSt := Copy(Part, Pos('/', Part) + 1, Length(Part));
      Step := StrToIntDef(StepSt, 1);
    end
    else begin
      RangeSt := Part;
      Step := 1;
    end;
    if Step < 1 then
      Step := 1;
    if RangeSt = '*' then begin
      RangeFrom := 0;
      RangeTo := 59; //достаточно широко - реальные границы поля здесь не важны
    end
    else if Pos('-', RangeSt) > 0 then begin
      RangeParts := A.ExplodeS(RangeSt, '-');
      RangeFrom := StrToIntDef(RangeParts[0], -1);
      RangeTo := StrToIntDef(RangeParts[High(RangeParts)], -1);
    end
    else begin
      RangeFrom := StrToIntDef(RangeSt, -1);
      RangeTo := RangeFrom;
    end;
    if (AValue >= RangeFrom) and (AValue <= RangeTo) and ((AValue - RangeFrom) mod Step = 0) then begin
      Result := True;
      Exit;
    end;
  end;
end;

function CronMatches(const ACron: string; AMoment: TDateTime): Boolean;
//проверяет, подходит ли момент времени AMoment (с точностью до минуты) под
//расписание в формате cron - пять полей через пробел: "минута час
//день_месяца месяц день_недели" (день недели: 0 = воскресенье, ..., 6 = суббота)
var
  Fields: TStringDynArray;
begin
  Fields := A.ExplodeS(Trim(ACron), ' ');
  Result := Length(Fields) = 5;
  if not Result then
    Exit;
  Result :=
    CronFieldMatches(Fields[0], MinuteOf(AMoment)) and
    CronFieldMatches(Fields[1], HourOf(AMoment)) and
    CronFieldMatches(Fields[2], DayOf(AMoment)) and
    CronFieldMatches(Fields[3], MonthOf(AMoment)) and
    CronFieldMatches(Fields[4], DayOfWeek(AMoment) - 1);
end;

procedure InitScheduledTasks;
//заполняет расписание всех задач, выполняемых по времени (см. ScheduledTasks
//выше) - вызывается один раз при старте резидентного процесса, см.
//TTasksS.Run. порядок задач в массиве важен - см. ProcessScheduledTasks:
//задачи, просроченные из-за выполнения другой задачи, выполняются именно в
//этом порядке (порядке следования в массиве), а не в порядке просроченных
//минут.
//
//расписание перенесено сюда из прежних TTasksS.HourlyTasks (время каждой
//задачи было и раньше жёстко задано в коде - здесь оно просто выражено в
//виде cron вместо вложенных if). День недели ("по понедельникам")
//сознательно не выражен через поле cron, а проверяется прямо в теле
//задачи - в модуле есть два разных модуля (DateUtils и SysUtils),
//объявляющих функцию DayOfWeek с разными соглашениями о нумерации дней, и
//чтобы не ошибиться в этом при переносе в расписание, здесь используется
//то же самое условие, что было в исходном коде, без изменений
  procedure AddTask(const AName, AComment, ACron: string; AProc: TScheduledTaskProc);
  begin
    SetLength(ScheduledTasks, Length(ScheduledTasks) + 1);
    ScheduledTasks[High(ScheduledTasks)].Name := AName;
    ScheduledTasks[High(ScheduledTasks)].Comment := AComment;
    ScheduledTasks[High(ScheduledTasks)].Cron := ACron;
    ScheduledTasks[High(ScheduledTasks)].Proc := AProc;
  end;
begin
  SetLength(ScheduledTasks, 0);
  //задачи, выполняющиеся каждый час, в начале часа
  AddTask('Обновление плановых заказов', '', '0 * * * *', procedure begin TasksS.CalcPlannedOrders; end);
  AddTask('Производственные данные по заказам из ИТМ', '', '0 * * * *', procedure begin TasksS.SetProdustionDataForOrders; end);
  AddTask('Мониторинг цен по счетам снабжения', '', '0 * * * *', procedure begin TasksS.ReportForHorlySupplyDeals; end);
  AddTask('Загрузка данных ТУРВ из Парсек', '', '0 * * * *', procedure begin Turv.LoadDataFromParsec; end);
  AddTask('Выгрузка ТУРВ в таблицу экспорта', '', '0 * * * *', procedure begin Turv.SaveAllTurvToExportTable; end);
  AddTask('Продление персональных бонусов', '', '0 * * * *', procedure begin Turv.ExtendPersBonuses; end);
  //задача, выполняющаяся раз в сутки в 4 часа
  AddTask('Финансовый мониторинг заказов', 'p_run_insert_orders_fin_monitoring', '0 4 * * *',
    procedure begin Q.QCallStoredProc('p_run_insert_orders_fin_monitoring', '', []); end);
  //задачи, выполняющиеся в начале рабочего дня, в 8 часов
  AddTask('Счета снабжения за вчерашний день', '', '0 8 * * *', procedure begin TasksS.ReportForYesterdaySupplyDeals; end);
  AddTask('Производственные заказы за вчерашний день', '', '0 8 * * *', procedure begin TasksS.ReportForYesterdayOrders(1); end);
  AddTask('Отгрузочные заказы за вчерашний день', '', '0 8 * * *', procedure begin TasksS.ReportForYesterdayOrders(3); end);
  AddTask('Преждевременно созданные АВР', '', '0 8 * * *', procedure begin TasksS.ReportForEarlyCompletionActs; end);
  AddTask('Сырьё в пути без резерва', '', '0 8 * * *', procedure begin TasksS.ReportForSupplyisOnwaySurplus; end);
  AddTask('Материалы на складах СГП, являющиеся сырьём', '', '0 8 * * *', procedure begin TasksS.ReportForRawMaterialsOnSgp; end);
  AddTask('Акты списания и оприходования за вчерашний день', '', '0 8 * * *', procedure begin TasksS.ReportForActsWriteoffReceipt; end);
  AddTask('Отрицательные остатки на складах', '', '0 8 * * *', procedure begin TasksS.ReportForNegativeQuantityOnStocks; end);
  AddTask('Отрицательные остатки на СГП', '', '0 8 * * *', procedure begin TasksS.ReportForNegativeQuantityOnSgp; end);
  AddTask('Отрицательная потребность по текущему состоянию СГП', '', '0 8 * * *', procedure begin TasksS.ReportForNegativeNeedBySgp; end);
  AddTask('Просроченные производственные заказы', '', '0 8 * * *', procedure begin TasksS.ReportForOverdueOrders(True); end);
  AddTask('Просроченные отгрузочные заказы', '', '0 8 * * *', procedure begin TasksS.ReportForOverdueOrders(False); end);
  AddTask('Просроченные по дате начала производства заказы', '', '0 8 * * *', procedure begin TasksS.ReportForOverdueOrdersByStartTpoProductionDate; end);
  AddTask('Отрицательная потребность по сырью у поставщиков', '', '0 8 * * *', procedure begin TasksS.ReportForSuppliersNegativeDemand; end);
  AddTask('Просроченные сметы', '', '0 8 * * *', procedure begin TasksS.ReportForEstimatesOverdue(1); end);
  AddTask('Просроченные загрузки технологов', '', '0 8 * * *', procedure begin TasksS.ReportForEstimatesOverdue(2); end);
  AddTask('Производственные заказы к выдаче завтра', '', '0 8 * * *', procedure begin TasksS.ReportForOrdersPlannedToStartTomorrow; end);
  AddTask('Недостающие материалы для заказов, запланированных на завтра', '', '0 8 * * *', procedure begin TasksS.ReportForRequiredMaterialsForPlannedOrdersTomorrow; end);
  AddTask('Заказы, запланированные к отгрузке (сегодня/завтра/послезавтра)', '', '0 8 * * *', procedure begin TasksS.ReportForPlannedShipments; end);
  //задачи по понедельникам - день недели проверяется внутри задачи, см.
  //комментарий к InitScheduledTasks выше
  AddTask('Производственные заказы за прошедшую неделю', 'выполняется только по понедельникам', '0 8 * * *',
    procedure begin if DayOfWeek(Date) = 1 then TasksS.ReportForYesterdayOrders(5); end);
  AddTask('Отгрузочные заказы за прошедшую неделю', 'выполняется только по понедельникам', '0 8 * * *',
    procedure begin if DayOfWeek(Date) = 1 then TasksS.ReportForYesterdayOrders(7); end);
  //задачи первого числа месяца - день месяца задан прямо в расписании
  AddTask('Производственные заказы за прошедший месяц', '', '0 8 1 * *', procedure begin TasksS.ReportForYesterdayOrders(6); end);
  AddTask('Отгрузочные заказы за прошедший месяц', '', '0 8 1 * *', procedure begin TasksS.ReportForYesterdayOrders(8); end);
end;

procedure ProcessScheduledTasks(AFrom, ATo: TDateTime);
//проверяет расписание всех задач (см. ScheduledTasks) на каждую минуту в
//диапазоне [AFrom; ATo] (включительно, с точностью до минуты), и выполняет
//те, для которых нашлось хотя бы одно совпадение - строго в порядке их
//расположения в массиве ScheduledTasks (а не в порядке просроченных минут).
//диапазон шире одной минуты бывает, если предыдущий тик минутного таймера
//долго выполнял другую задачу (просрочка, см. заголовок модуля) - таким
//образом просроченные задачи не теряются, а выполняются одна за другой
//сразу после освобождения таймера
var
  i: Integer;
  Moment: TDateTime;
  IsDue: array of Boolean;
begin
  SetLength(IsDue, Length(ScheduledTasks));
  Moment := AFrom;
  while Moment <= ATo do begin
    for i := 0 to High(ScheduledTasks) do
      if not IsDue[i] then
        if CronMatches(ScheduledTasks[i].Cron, Moment) then
          IsDue[i] := True;
    Moment := IncMinute(Moment, 1);
  end;
  for i := 0 to High(ScheduledTasks) do
    if IsDue[i] then
      RunLoggedTask(ScheduledTasks[i].Name, TProc(ScheduledTasks[i].Proc));
end;

type
  //резидентный "сторож" процесса сервера (см. заголовок модуля выше):
  //пока сервер работает, следит через собственные таймеры за -
  //1) не появилась ли на сервере дистрибутива новая версия exe - если да,
  //   безопасно запускает обновление и штатно завершает процесс (см.
  //   UpdateCheckTimerTimer ниже - самих файлов запущенного процесса не трогаем);
  //2) есть ли соединение с БД - если пропало, процесс сразу завершается
  //   (см. MinutelyTimerTimer), следующая попытка - через 5 минут, по
  //   сторожевому заданию планировщика;
  //3) не наступило ли время одной из задач расписания (см. ScheduledTasks,
  //   InitScheduledTasks, ProcessScheduledTasks выше) - выполняется, только
  //   если разрешено расписание (см. IsScheduleEnabled выше).
  //создаётся и стартует в TTasksS.Run при любом старте процесса (сервер
  //полностью резидентен, см. заголовок модуля); единственность самого
  //резидентного процесса обеспечена мьютексом в Uchet.dpr (CheckInstance) -
  //здесь это заново не проверяется
  TServerWatchdog = class
  private
    FUpdateCheckTimer: TTimer;
    FMinutelyTimer: TTimer;
    FLastScheduleCheckMoment: TDateTime;
    procedure UpdateCheckTimerTimer(Sender: TObject);
    procedure MinutelyTimerTimer(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
  end;

var
  //не nil, пока сервер резидентно работает (то есть всегда, после того как
  //TTasksS.Run отработает разовую часть), см. TTasksS.Run
  ServerWatchdog: TServerWatchdog;

{ TServerWatchdog }

constructor TServerWatchdog.Create;
begin
  inherited Create;
  //расписание проверяется только начиная с текущей минуты - то, что могло
  //быть пропущено, пока резидентный процесс не работал, не наверстывается
  //(см. ProcessScheduledTasks)
  FLastScheduleCheckMoment := TruncToMinute(Now);
  FUpdateCheckTimer := TTimer.Create(Application);
  FUpdateCheckTimer.Interval := 5 * 60 * 1000;
  FUpdateCheckTimer.OnTimer := UpdateCheckTimerTimer;
  FMinutelyTimer := TTimer.Create(Application);
  FMinutelyTimer.Interval := 60 * 1000;
  FMinutelyTimer.OnTimer := MinutelyTimerTimer;
end;

destructor TServerWatchdog.Destroy;
begin
  FreeAndNil(FUpdateCheckTimer);
  FreeAndNil(FMinutelyTimer);
  inherited Destroy;
end;

procedure TServerWatchdog.UpdateCheckTimerTimer(Sender: TObject);
//раз в 5 минут - проверка, не появилась ли на сервере дистрибутива (см.
//Updater\updater.dir рядом с exe - тот же приём, что и в
//uUpdater.CheckForUpdatesAndRunUpdater для обычных клиентских модулей) новая
//версия текущего exe. Файл САМОГО работающего процесса при этом не трогаем и
//не перезаписываем напрямую - это приводит к краху приложения; вместо этого,
//как и обычный клиентский апдейтер, запускаем Uchet_Updater.exe и штатно
//завершаемся - обновлятор дождётся закрытия процесса и подменит файл уже
//после этого (см. заголовок uUpdater.pas)
var
  UpdaterDir, ServerBasePath: string;
begin
  UpdaterDir := ExtractFilePath(ParamStr(0)) + 'Updater' + PathDelim;
  if not GetUpdateServerBasePath(UpdaterDir, ServerBasePath) then
    Exit; //нет updater.dir рядом с exe - обновление для этого расположения не настроено
  if not IsExeUpdateAvailable(ServerBasePath) then
    Exit;
  LogTaskEvent('Сервер', 'обнаружена новая версия ' + ExtractFileName(ParamStr(0)) + ' - запускается обновление, процесс завершается');
  ScanApi.Stop;
  try
    RunUpdaterAndHalt(ServerBasePath, UpdaterDir); //при успехе - Halt(0) внутри, сюда управление не вернётся
  except
    on E: Exception do begin
      //не удалось запустить обновление (например, нет Uchet_Updater.exe) -
      //логируем и восстанавливаем работу сервера со старой версией, попробуем
      //снова через 5 минут на следующем срабатывании таймера
      LogTaskEvent('Сервер', 'не удалось запустить обновление: ' + E.Message);
      ScanApi.Start;
    end;
  end;
end;

procedure TServerWatchdog.MinutelyTimerTimer(Sender: TObject);
//раз в минуту - проверка соединения с БД (при его отсутствии дальнейшая
//работа невозможна ни для сканирования, ни для прочих задач - процесс сразу
//завершается), и, если разрешено расписание (см. IsScheduleEnabled),
//выполнение задач расписания за все минуты, прошедшие с прошлой проверки
//(см. ProcessScheduledTasks - обычно это ровно одна минута, но может быть
//больше, если предыдущий тик долго выполнял задачу, см. заголовок модуля).
//Ошибки внутри самих задач логируются и не прерывают их выполнение - см.
//RunLoggedTask, используемый внутри ProcessScheduledTasks; внешний
//try/except здесь - дополнительная защита на случай ошибки в самой логике
//планирования
var
  CheckFrom, CheckTo: TDateTime;
begin
  if not Q.Connected then begin
    LogTaskEvent('Сервер', 'потеряно соединение с БД - процесс завершается');
    Halt;
  end;
  if not IsScheduleEnabled then
    Exit;
  try
    CheckTo := TruncToMinute(Now);
    CheckFrom := IncMinute(FLastScheduleCheckMoment, 1);
    if CheckFrom <= CheckTo then begin
      ProcessScheduledTasks(CheckFrom, CheckTo);
      FLastScheduleCheckMoment := CheckTo;
    end;
  except
    on E: Exception do
      LogTaskEvent('Сервер', 'ошибка при выполнении заданий по расписанию: ' + E.Message);
  end;
end;

procedure TTasksS.Run;
//процедура выполняется при старте модуля Сервер - см. заголовок модуля.
//сервер полностью резидентен: какой бы параметр ни был передан при старте,
//после разовой попытки выполнить соответствующую ему задачу процесс не
//завершается - остаётся работать, обслуживая HTTP-сервер сканера штрихкодов
//(ScanApi, работает всегда, независимо от параметра) и выполняя все
//прочие задачи по расписанию через ServerWatchdog (см. выше в этом модуле)
begin
  ScanApi.Start;
  InitScheduledTasks;
  if Module.DevFileExists then
    IsScheduleEnabled := MyQuestionMessage('Обнаружен файл "dev" (режим разработки).' + sLineBreak + 'Выполнять задания по расписанию?') = mrYes;
  if not ExecuteTaskByName(ParamStr(1)) then
    LogTaskEvent(ParamStr(1), 'параметр запуска не распознан');
  ServerWatchdog := TServerWatchdog.Create;
end;

function TTasksS.ExecuteTaskByName(const ATaskName: string): Boolean;
//выполняет одну задачу по её "имени" - см. описание в интерфейсной части
var
  IsMatched: Boolean;
begin
  IsMatched := True;
  try
    try
      if ATaskName = '/turvreport1' then begin
        //if DayOf(Date) in [1, 16] then TestTurvComplete;
      end
      else if ATaskName = '/turvreport2' then begin
        //RunTestTurvDifferences;
      end
      else if ATaskName = '/fromparsec' then
        TURV.LoadParsecData
      else if ATaskName = '/ReportForOrdersWithoutEstimate' then
        ReportForOrdersWithoutEstimate
      else if ATaskName = '/deleteolddata' then
        DeleteOldData
      else if ATaskName = '/getcalendar' then begin
        GetProductionCalendar(YearOf(Date));
        GetProductionCalendar(YearOf(Date) + 1);
      end
      else if ATaskName = '/calcplanned' then
        CalcPlannedOrders
      else if ATaskName = '/CloseItmWorkPeriod' then
        CloseItmWorkPeriod
      //'/hourly' больше не поддерживается - вся его прежняя нагрузка перенесена
      //в расписание (см. ScheduledTasks/InitScheduledTasks), которое выполняется
      //резидентным процессом само, без внешнего запуска по этому параметру
      else if ATaskName = '/test' then begin
        //
      end
      else if ATaskName = TASK_SCAN_API then begin
        //сама задача сканирования запускается отдельно и всегда, при старте
        //TTasksS.Run (см. выше) - по этому имени дополнительно ничего не
        //требуется, ветка нужна только для распознавания параметра
      end
      else
        IsMatched := False;
      if IsMatched then
        LogTaskEvent(ATaskName, 'выполнено');
    except
      on E: Exception do
        LogTaskEvent(ATaskName, 'ошибка: ' + E.Message);
    end;
  finally
    //на всякий случай откатим транзакцию, если была незафиксированная
    Q.QRollbackTrans;
  end;
  Result := IsMatched;
end;

function TTasksS.ScheduledTaskNames: TVarDynArray;
//имена всех задач расписания - см. описание в интерфейсной части
var
  i: Integer;
begin
  SetLength(Result, Length(ScheduledTasks));
  for i := 0 to High(ScheduledTasks) do
    Result[i] := ScheduledTasks[i].Name;
end;

procedure TTasksS.RunScheduledTask(AIndex: Integer);
//выполняет одну задачу расписания по индексу - см. описание в интерфейсной части
begin
  if (AIndex < 0) or (AIndex > High(ScheduledTasks)) then
    Exit;
  RunLoggedTask(ScheduledTasks[AIndex].Name, TProc(ScheduledTasks[AIndex].Proc));
end;

procedure TTasksS.DeleteOldData;
//автоматическое удаление старых данных
var
  i, j: Integer;
  vtimes: TVarDynArray;
  va1, va2, va3: TVarDynArray2;
  va: TVarDynArray;
  body: string;
  dt1, dt2: TDateTime;
  ok: Boolean;
begin
  //времена удаления, перые в днях, а турв и зп в периодах 2 недели
  vtimes := Q.QLoadRow('select or_to_archive, orders_n, accounts_n, turv, payrolls from adm_delete_old', []);
  if S.NNum(vtimes[0]) >= 10 then begin
    //перенесем в архив заказы, которые завершены ранее /2 недель/ назад, и еще не в архиве
    dt1 := IncDay(Date, -vtimes[0]);
    va1 := Q.QLoad('select id, path, dt_beg, dt_end from v_orders where nvl(in_archive, 0) <> 1 and dt_end is not null and dt_end < :dt1$d', [dt1]);
    for i := 0 to High(va1) do begin
      dt1 := EncodeDate(YearOf(va1[i][3]), MonthOf(va1[i][3]), DayOf(va1[i][3]));
      Q.QExecSql('update orders set in_archive = 1 where id = :id$i', [va1[i][0]]);
      Tasks.CreateTaskRoot(mytskopMoveToArchive, [['directory', va1[i][1]], ['in_archive', 0], ['year', YearOf(va1[i][2])]]);
    end;
  end;
  ///удаение счетов за наличный расчет
  if S.NNum(vtimes[2]) >= 10 then begin
    //удаляем счета за наличный расчет
    //счет должен быть полностью оплачен и последняя дата платежа должна быть раньше целевой даты и даты ревизии кассы
    dt1 := IncDay(Date, -vtimes[2]);
    va1 := Q.QLoad('select id, filename, type, maxdtpaid, dt from v_sn_calendar_accounts where ' + 'type <> 1 and paimentstatus = ''полностью'' and maxdtpaid < :dt1$d and ' + 'maxdtpaid < (select dt from sn_cash_revision_dt) order by maxdtpaid asc', [dt1]);
//    Sys.SaveArray2ToFile(va1,'r:\2');
    for i := 00000 to High(va1) do begin
      Q.QBeginTrans(True);
      ok := False;
      repeat
        if Q.QExecSql('update sn_calendar_t_basis set id_acc = null where id_acc = :id$i', [va1[i][0]]) < 0 then
          Break;
        if Q.QExecSql('delete from sn_calendar_accounts where id = :id$i', [va1[i][0]]) < 0 then
          Break;
        ok := True;
      until True;
      if ok then begin
        Q.QCommitTrans;
        Tasks.CreateTaskRoot(mytskopDeleteAllFromAccounts, [['directory', va1[i][1]]]);
      end
      else
        Q.QRollbackTrans;
    end;
  end;
  //удаление ТУРВ старше Х периодов
  //при Х=1 удаляется ТУРВ, предшествующий текущему
{  if S.NNum(vtimes[3]) >= 3 then begin
    dt1 := TURV.GetTurvBegDate(Date);
    for i := 1 to vtimes[3] do begin
      dt1 := TURV.GetTurvBegDate(IncDay(dt1, -1));
    end;
    dt2 := dt1;
    Q.QExecSql('delete from turv_period where dt1 <= :dt1$d', [dt1]);
  end;
  //удаление платежных ведомостей старше Х периодов
  if S.NNum(vtimes[4]) >= 3 then begin
    dt1 := TURV.GetTurvBegDate(Date);
    for i := 1 to vtimes[4] do begin
      dt1 := TURV.GetTurvBegDate(IncDay(dt1, -1));
    end;
    Q.QExecSql('delete from payroll where dt1 <= :dt1$d', [dt1]);
  end;}
end;

{------------------------------------------------------------------------------}
{                                  ЗАДАЧИ                                      }
{------------------------------------------------------------------------------}


function TTasksS.GetProductionCalendar(Year: Variant): Integer;
//получение из интернета производственного календаря
var
  i,j,k:Integer;
  st: string;

  FileStream: TFileStream;
  DecompressionStream: TDecompressionStream;
  Strings: TStringList;
  MS:TMemoryStream;
//  XMLDocument:TXMLDocument;
  RootNode: IXMLNode;
  a1: TVarDynArray;
  a2, a3: TVarDynArray2;
  b: Boolean;
begin
(*
<!--
year    - год на который сформирован календарь
lang    - двухбуквенный код языка на котором представлены названия праздников
date    - дата формирования xml-календаря в формате ГГГГ.ММ.ДД
country - двухбуквенный код страны
-->
<calendar year="2014" lang="ru" date="2014.01.01" country="ru">
  <!--
    holidays - Список праздников
    id - идентификатор праздника
    title - название праздника
  -->
  <holidays>
    <holiday id="1" title="Новогодние каникулы" />
    <holiday id="2" title="Рождество Христово" />
    <holiday id="3" title="День защитника Отечества" />
    <holiday id="4" title="Международный женский день" />
    <holiday id="5" title="Праздник Весны и Труда" />
    <holiday id="6" title="День Победы" />
    <holiday id="7" title="День России" />
    <holiday id="8" title="День народного единства" />
  </holidays>
  <!--
    days - праздники/короткие дни/рабочие дни (суббота либо воскресенье)
    d (day) - день (формат ММ.ДД)
    t (type) - тип дня: 1 - выходной день, 2 - рабочий и сокращенный (может быть использован для любого дня недели), 3 - рабочий день (суббота/воскресенье)
    h (holiday) - номер праздника (ссылка на атрибут id тэга holiday)
    f (from) - дата с которой был перенесен выходной день
    суббота и воскресенье считаются выходными, если нет тегов day с атрибутом t=2 и t=3 за этот день
  -->
  <days>
    <day d="01.01" t="1" h="1" />
    <day d="01.02" t="1" h="1" />
    <day d="01.03" t="1" h="1" />
    <day d="02.22" t="1" f="01.03" />
    ...
  </days>
</calendar>
*)
  Result:=-1;
  repeat
  try
  if not Sys.LoadFileFromWWW('http://xmlcalendar.ru/data/ru/' + VarToStr(Year) + '/calendar.xml.gz', Sys.GetWinTemp+'\calendar.xml.gz') then break;
  FileStream := TFileStream.Create(Sys.GetWinTemp+'\calendar.xml.gz', fmOpenRead);
{   windowBits can also be greater than 15 for optional gzip decoding.  Add
   32 to windowBits to enable zlib and gzip decoding with automatic header
   detection, or add 16 to S.Decode only the gzip format (the zlib format will
   return a Z_DATA_ERROR).}
  DecompressionStream := TDecompressionStream.Create(FileStream, 15 + 16);  // 31 bit wide window = gzip only mode
  Strings := TStringList.Create;
  Strings.LoadFromStream(DecompressionStream);
  Strings.Text:=UTF8Decode(Strings.Text);
//  ShowMessage(Strings.Text);

  MyData.XMLDocument.LoadFromXML(Strings.Text);
  MyData.XMLDocument.Active := True;

  st:=MyData.XMLDocument.DocumentElement.ChildNodes['holidays'].ChildNodes[1].xml;//ChildNodes['holideys'].XML;

  a1:=[''];
  for i:=0 to MyData.XMLDocument.DocumentElement.ChildNodes['holidays'].ChildNodes.Count - 1 do begin
    j:=StrToInt(MyData.XMLDocument.DocumentElement.ChildNodes['holidays'].ChildNodes[i].Attributes['id']);
    if j > High(a1) then SetLength(a1, j+1);
    a1[j]:=S.NSt(MyData.XMLDocument.DocumentElement.ChildNodes['holidays'].ChildNodes[i].Attributes['title']);
  end;

  SetLength(a2, MyData.XMLDocument.DocumentElement.ChildNodes['days'].ChildNodes.Count);
  for i:=0 to MyData.XMLDocument.DocumentElement.ChildNodes['days'].ChildNodes.Count - 1 do begin
    st:=MyData.XMLDocument.DocumentElement.ChildNodes['days'].ChildNodes[i].Attributes['d'];
    a2[i]:=[
      EncodeDate(S.VarToInt(Year), StrToInt(Copy(st,1,2)), StrToInt(Copy(st,4,2))),
      StrToInt(MyData.XMLDocument.DocumentElement.ChildNodes['days'].ChildNodes[i].Attributes['t']),
      a1[StrToIntDef(S.NSt(MyData.XMLDocument.DocumentElement.ChildNodes['days'].ChildNodes[i].Attributes['h']), 0)]
    ]
  end;

//  text;//ChildNodes['holideys1'].text;//ChildNodes[1].Text;
//  ShowMessage(st);
  if Length(a2) > 0 then begin
    a3:=Q.QLoad('select dt, type, descr from ref_holidays where extract(year from dt) = :year order by dt', [S.VarToInt(Year)]);
    b:=Length(a2) <> Length(a3);
    if not b then
      for i:=0 to High(a2) do
        if (a2[i][0] <> a3[i][0])or(a2[i][1] <> a3[i][1])or(a2[i][2] <> S.NSt(a3[i][2]))
          then begin b:=True; Break end;
    if b then begin
      Q.QExecSql('delete from ref_holidays where extract(year from dt) = :year', [S.VarToInt(Year)]);
      for i:=0 to High(a2) do
        Q.QExecSql('insert into ref_holidays (dt, type, descr) values (:dt$d, :type$i, :descr$t)', [a2[i][0], a2[i][1], Copy(a2[i][2], 1, 200)]);
      Result:=1;
    end
    else Result:=0;
    Break;
  end;
  except
    Break;
  end;
  until False;
//  XMLDocument.Free;
  DecompressionStream.Free;
  FileStream.Free;
  Strings.Free;
end;

procedure TTasksS.CalcPlannedOrders;
//посчитаем количество по сметным позициям плановых заказов для отчета и для снабжения
begin
  Orders.CrealeEstimateOnPlannesOrders(Date, False);
  Orders.CrealeEstimateOnPlannesOrders(Date, True);
end;

procedure TTasksS.CloseItmWorkPeriod;
//закроем период в итм с конца предыдущего до прошедшего воскресенья включительно
var
  i, j: Integer;
  va2: TVarDynArray2;
  dt1, dt2: TDateTime;
function GetLastSunday(AValue: TDateTime): TDateTime;
var
  Day: Integer;
begin
  Day := DayOfTheWeek(AValue);
  if Day = 7
    then Result := AValue - 7
    else Result := AValue - (Day);
end;
begin
  //закрытие периода - получить максимальну дапту окончания, прибавить день, в качестве начальной
  //неделю назад в качестве конечной
  //вставить строку в таблицу, айди из последовательности
  //sq_closed_period_id
  va2 := Q.QLoad('select max(end_date) from dv.closed_period', []);
  if Length(va2) = 0
    then dt1 := IncMonth(Date, -1)
    else dt1 := IncDay(VarToDateTime(va2[0][0]), 1);
  dt2 := GetLastSunday(Date);
  if dt1 >= dt2 then
    Exit;
  Q.QSave('i', 'dv.closed_period', 'dv.sq_closed_period_id', 'id_closed_period$i;period_name$s;start_date$d;end_date$d;is_closed$i',
    [-1, 'Новый период', dt1, dt2, 1]
  );
end;

procedure TTasksS.SetProdustionDataForOrders;
//устанавливает в таблице заказов проиизводственные статусы и данные, взятые из ИТМ
//(является ли заказ производственныым, дата выдачи в производство, количество плитных и кромочных материалов по смете в изделиях заказа)
begin
  Q.QBeginTrans(True);
  Q.QCallStoredProc('P_SetOrdersProdData', '', []);
  Q.QCommitOrRollback(True);
end;

procedure TTasksS.ReportForOrdersWithoutEstimate;
//отчет по заказам, по кторым не созданы сметы
var
  i, j: Integer;
  va: TVarDynArray2;
  va1: TVarDynArray;
  body: string;
  addr: string;
begin
  va := Q.QLoad('select org || '' '' || num as ordernum, project, customer, dt_beg, dt_otgr, constructor ' + 'from uchet.v_to_orders_list_current2 where (dt_smeta is null) and (dt_end is null) order by ordernum', []);
  if High(va) < 0 then
    Exit;
  SetLength(va1, Length(va[0]));
  for i := 0 to High(va) do begin
    for j := 0 to High(va[i]) do
      if S.NNum(va1[j]) < Length(S.NSt(va[i][j])) then
        va1[j] := Length(S.NSt(va[i][j]));
  end;
  body := 'Незавершенные заказы, по которым еще не была отправлена смета:'#13#10#13#10;
  for i := 0 to High(va) do begin
    for j := 0 to High(va[i]) do
      S.ConcatStP(body, Copy(VarToStr(va[i][j]) + '       ', 1, S.VarToInt(va1[j]) + 3), ' ');
    S.ConcatStP(body, #13#10);
  end;
  S.ConcatStP(body, #13#10);
  Tasks.SendMail(TASK_MAILING_NO_ESTIMATE, 'Заказы в работе, по которым не созданы сметы', body, [], '~', False);
end;

function TTasksS.ReportForHorlySupplyDeals: Integer;
//ежечасный мониторинг сделаок по снабжению
//регистрирует позиции по счетам, цена по которым была выше контрольной
var
  Fields: TVarDynArray2;
  i,j: Integer;
  IdSch, IdSchN, IdIb, IdIbN: Integer;
  na: TNamedArr;
  st, css: string;
  FileToSend: string;
  Tbl: THTMLTable;
  HTML, Title: string;
begin
  Title := 'За последний час были выставлены счета по завышенным ценам!';
  Fields := [
    ['name$s', 'Наименование', '500;h'],
    ['price$f', 'Цена', '80', 'r'],
    ['price_check$f', 'Контрольная цена', '80', 'r'],
    ['name_unit$s', 'Ед. изм.', '80', 'r'],
    ['qnt$f', 'Кол-во', '80', 'r'],
    ['sum$f', 'Сумма по счету', '80', 'f=#:', 's', 'r'],
    ['sum_diff$f', 'Разница с контрольной','80', 'f=#:', 's', 'r'],
    ['num_w_dt$s', 'Счет', '150;h']
  ];
  //получим список номенкклатуры из еще не обработанных этим скриптом счетов, по которой есть превышение закупочной цены над кеонтрольной
  try
    Q.QBeginTrans(True);
    IdSch := S.IfNotEmpty(Q.QLoadValue('select i from properties where prop = ''spl_monitoring_prices'' and subprop = ''id_schet_mon''', []), 36327);
    Q.QLoad(Q.QGetSql('A', 'v_prices_from_sp_schet', Fields.Col(0).Implode(';')) + ' where monitor_price = 1 and id_schet > :id$i order by name asc', [IdSch], na);
    IdSchN := Q.QLoadValue('select max(id_schet) from dv.sp_schet', []);
    //сохраним айди обработанного счета
    Q.QCallStoredProc('p_SetProp', 'p$s;sp$s;st$s;dt$d;i$i;f$f', ['spl_monitoring_prices', 'id_schet_mon', '', null, IdSchN, null]);
    if na.Count > 0 then begin
      Tbl.InitDefaults;
      Tbl.SetOptions('report-table', '—', True, '0.00', 'dd.mm.yyyy', 'dd.mm.yyyy hh:nn:ss', True, True);
      HTML := '<b>По следующей номенклатуре были выставлены счета, в которых цена номенклатуры превышает контрольную цену:</b><br>' + Tbl.GenerateEmail(na, Fields, 1, 2, 0);
      Tasks.SendMail(TASK_MAILING_MONITORING_SN, Title, HTML, [], '~');
    end;
    //сохраним в таблице информцию по номенклатуре и ПН из еще не обработанных приходных накладных, где округленные до рубля закупочная и контрольная цена различаются
    IdIb := S.IfNotEmpty(Q.QLoadValue('select i from properties where prop = ''spl_deals_monitoring'' and subprop = ''id_inbill''', []), 113205);
    Q.QExecSql(
      'insert into spl_deals_monitoring '+
        '(dt, id_nomencl, id_inbill, price_check) '+
        '(select trunc(sysdate), id_nomencl, id_inbill, price_check '+
          'from v_spl_deals_monitoring_get '+
          'where id_inbill > :id$i'+
        ')',
      [IdIb]
    );
    //обновим контрольную цену, если найдена в накладных, старше айди из properties, цена меньше контрольной
    Q.QExecSql('update spl_itm_nom_props t set price_check = nvl((select price_new from v_spl_prices_check_get g where g.id_nomencl = t.id), t.price_check)', []);
    //получим и сохраним айди последней накладной
    IdIbN := Q.QLoadValue('select max(id_inbill) from dv.in_bill', []);
    Q.QCallStoredProc('p_SetProp', 'p$s;sp$s;st$s;dt$d;i$i;f$f', ['spl_deals_monitoring', 'id_inbill', '', null, IdIbN, null]);
  except
    Q.QRollbackTrans;
  end;
    Q.QCommitTrans;
end;

procedure ReportForYesterdaySupplyDealsXlsxFormatter(var Fr: TFrDBGridEh; FieldName: string; Params: TColCellParamsEh);
//мониторинг счетов снабжения за вчерашний день, callback для форматирования файла эксель
begin
  if (FieldName = 'sum_diff') and (Fr.GetValueF('sum_diff') > 0) then
    Params.Font.Color := clRed;
end;

function ReportForYesterdaySupplyDealsTblFormatter(ARow, ACol: Integer; const AValue: Variant; const AFormattedValue: string): string;
//мониторинг счетов снабжения за вчерашний день, callback для форматирования таблицы
begin
  //выделим жирным 'sum_diff'
  if (ACol = 6) and (AValue.AsFloat > 0) then
    Result := '<b>' + AFormattedValue + '</b>'
  else
    Result := AFormattedValue;
end;

procedure TTasksS.ReportForYesterdaySupplyDeals;
//мониторинг счетов снабжения за вчерашний день, а также наличия приходных накладных без оснований
var
  i,j: Integer;
  na: TNamedArr;
  va: TVarDynArray;
  Summ: Extended;
  Fields: TVarDynArray2;
  FileToSend: string;
  Tbl: THTMLTable;
  HTML, Title: string;
  TopSt: string;
begin
  Title := 'Счета снабжения за вчерашний день';
  TopSt := 'Счета снабжения за ' + DateTimeToStr(IncDay(Date, -1));
  Fields := [
    ['name$s', 'Наименование', '500;h'],
    ['price$f', 'Цена', '80', 'r'],
    ['price_check$f', 'Контрольная цена', '80', 'r'],
    ['name_unit$s', 'Ед. изм.', '80', 'r'],
    ['qnt$f', 'Кол-во', '80', 'r'],
    ['sum$f', 'Сумма по счету', '80', 'f=#:', 's', 'r'],
    ['sum_diff$f', 'Разница с контрольной','80', 'f=#:', 's', 'r'],
    ['num_w_dt$s', 'Счет', '150;h']
  ];
  Q.QLoad(Q.QGetSql('A', 'v_prices_from_sp_schet_day', Fields.Col(0).Implode(';')) + ' /*where monitor_price = 1*/ order by name asc', [], na);
  va := Q.QLoadCol('select to_char(inbillnum) from dv.in_bill where docstr is null and inbilldate >= trunc(sysdate) - 1 and inbilldate < trunc(sysdate)', []);
  HTML := '';
  if na.Count > 0 then begin
    Summ := na.Sum('sum_diff');
    Tbl.InitDefaults;
    Tbl.SetOptions('report-table', '—', True, '0.00', 'dd.mm.yyyy', 'dd.mm.yyyy hh:nn:ss', True, True);
    HTML := '<b>Номенклатура по счетам за вчерашний день:</b><br>' + Tbl.GenerateEmail(na, Fields, 1, 2, 0, ReportForYesterdaySupplyDealsTblFormatter) + '<br>' + 'Всего по счетам: <b>' + FloatToStr(Round(Summ)) + 'р.</b>';
    FileToSend := Sys.GetWinTemp + '\' + TopSt + '.xlsx';
    ExportToXlsx(FileToSend, na, Fields, TopSt, '', True, ReportForYesterdaySupplyDealsXlsxFormatter);
  end
  else
    HTML := 'За вчерашний день на было создано ни одного счета.<br>';
  if Length(va) > 0 then begin
    HTML := S.IIFStr(HTML <> '', HTML + '<br><br>----------------------------------<br><b>') + 'Были приходные накладные без основания за вчерашний день:</b><br>Номера: ' + A.Implode(va,', ') + '<br>';
  end;
  if HTML = '' then
    Exit;
  Tasks.SendMail(TASK_MAILING_MONITORING_SN, Title, HTML, [FileToSend], '~');
end;

procedure TTasksS.ReportForYesterdayOrders(AOrderTypes: Integer; AMailing: Boolean = True);
//финансовый отчет по производственным или отгрузочным заказам, запущенным за вчерашний день
//1'Отчет по производственным заказам за вчерашний день',
//2'Отчет по производственным заказам в работе',    //убрал
//3'Отчет по отгрузочным заказам за вчерашний день',
//4'Отчет по отгрузочным заказам в работе'          //убрал
//5'Отчет по производственным заказам за прошедшую неделю'
//6'Отчет по производственным заказам за прошешеший месяц'
//7'Отчет по отгрузочным заказам за прошедшую неделю'
//8'Отчет по отгрузочным заказам за прошешеший месяц'
var
  na: TNamedArr;
  Fields: TVarDynArray2;
  Tbl: THTMLTable;
  HTML, Title, TopSt, FileToSend, st1, st2, st3: string;
  DtBeg: TDateTime;
  DataType: Integer;
begin
  case AOrderTypes of
    1:
      begin
        st1 := 'производственным';
        st2 := 'вчерашний день';
        st3 := DateTimeToStr(IncDay(Date, -1));
        DtBeg := IncDay(Date, -1);
        DataType := 1;
      end;
    3:
      begin
        st1 := 'отгрузочным';
        st2 := 'вчерашний день';
        st3 := DateTimeToStr(IncDay(Date, -1));
        DtBeg := IncDay(Date, -1);
        DataType := 1;
      end;
    5:
      begin
        st1 := 'производственным';
        st2 := 'прошлую неделю';
        st3 := 'прошлую неделю';
        DtBeg := Date - DayOfTheWeek(Date);
        DataType := 5;
      end;
    6:
      begin
        st1 := 'производственным';
        st2 := 'прошлый месяц';
        st3 := 'прошлый месяц';
        DtBeg := DateOf(EndOfTheMonth(IncMonth(Date, -1)));
        DataType := 6;
      end;
    7:
      begin
        st1 := 'отгрузочным';
        st2 := 'прошлую неделю';
        st3 := 'прошлую неделю';
        //дата окончания периода!
        DtBeg := Date - DayOfTheWeek(Date);
        DataType := 5;
      end;
    8:
      begin
        st1 := 'отгрузочным';
        st2 := 'прошлый месяц';
        st3 := 'прошлый месяц';
        //дата окончания периода!
        DtBeg := DateOf(EndOfTheMonth(IncMonth(Date, -1)));
        DataType := 6;
      end;
  end;
  Title := 'Отчет по ' + st1 + ' заказам за ' + st2 + '.';
  TopSt := 'Отчет по ' + st1 + ' заказам за ' + st3 + '.';
  Fields := [
    ['rownum$i', '№', '20'],
    ['item_wo_estimate_st$s', 'Нет сметы', '60'],
    ['ornums$s', 'Заказы', '200;h'],
    ['customer$s', 'Покупатели', '200;h'],
    ['fullname$s', 'Изделие', '500;h'],
    ['qnt$i', 'Количество', '80', 'r'],
    ['qnt_on_sgp$i', 'Количество на СГП', '80', 'r'],
    ['qnt_need_on_sgp$i', 'Избыток/ Потребность на СГП', '80'],
    ['price_std$i', 'Цена по справочнику без НДС', '80', 'r'],
    ['price$i', 'Цена продажи без НДС', '80', 'r'],
    ['price_diff$i', 'Занижение цены без НДС', '80', 'r'],
    ['summ$i', 'Сумма продажи без НДС', '80', 'f=#:', 's', 'r'],
    ['priceraw_wo_nds_std$i', 'Себестоимость по смете стд. изд., без НДС', '80', 's', 'r'],
    ['priceraw_wo_nds$i', 'Себестоимость по смете, за шт., без НДС', '80', 's', 'r'],
    ['sum0$i', 'Себестоимость по смете, сумма без НДС', '80', 'f=#:', 's', 'r'],
    ['sum0_percent$i', '%', '80', 'r'],
    ['labor_cost_0$i', 'Трудозатраты по ПЩ', 'f=#:', '80', 's', 'r'],
    ['labor_cost_0_percent$i', '%', '80', 'r'],
    ['labor_cost_2$i', 'Трудозатраты по ЛОК', '80', 'f=#:', 's', 'r'],
    ['labor_cost_2_percent$i', '%', '80', 'f=#:', 'r'],
    ['prime_cost$i', 'Затраты всего, сумма', '80', 'f=#:', 's', 'r', 'b'],
    ['prime_cost_percent$i', 'Затраты всего, %', '80', 'r'],
    ['kns$s', 'Конструктора', '200;h'],
    ['thn$s', 'Технологи', '200;h']
  ];
  Q.QLoad(Q.QGetSql('A', S.IIf(AOrderTypes in [1, 3], 'v_orders_fin_monitoring', 'v_orders_fin_monitoring') , Fields.Col(0).Implode(';')) +
    ' where data_type = :data_type$i and order_type = :order_type$i and dt = trunc(:dt$d) order by prime_cost_percent desc',
    [DataType, S.IIf(st1 = 'отгрузочным', 0, -1), DtBeg], na
  );
  HTML := '';
  if na.Count = 0 then begin
    if AOrderTypes < 5 then
      HTML := 'Вчера ' + S.IIf(AOrderTypes in [3, 4], 'отгрузочных', 'производственных') + ' заказов запущено не было.'
    else
      HTML := 'За этот период не было запущено ни одного заказа.';
    FileToSend := '';
  end
  else begin
    if AMailing and (AOrderTypes < 5) then begin
      Tbl.InitDefaults;
      Tbl.SetOptions('report-table', '—', True, '0.00', 'dd.mm.yyyy', 'dd.mm.yyyy hh:nn:ss', True, True);
      HTML := TopSt + '<br>' + Tbl.GenerateEmail(na, Fields);
    end;
    FileToSend := S.IIfStr(AMailing, Sys.GetWinTemp + '\' )+ TopSt + '.xlsx';
    ExportToXlsx(FileToSend, na, Fields, TopSt, '', True);
  end;
  if AMailing then
    Tasks.SendMail(TASK_MAILING_ORDERS_FIN, Title, HTML, [FileToSend], '~');
end;

procedure TTasksS.ReportForEarlyCompletionActs;
//отчет по созданным в ИТМ АВР, по которым по заказу не было полного поринятия на сгп в Учете
var
  HTML: string;
  naP, naO: TNamedArr;
begin
  Q.QLoad(
    'select o.ornum , o.customer, o.project, dt_beg, a.actdate '+
    'from v_orders o, dv.acts a '+
    'where o.id_itm = a.id_zakaz and o.dt_to_sgp is null and o.id_organization = -1 and a.actdate = :dt$d ' +
    'order by dt_beg, ornum',
    [IncDay(Date, -1)],
    naP
  );
  Q.QLoad(
    'select o.ornum , o.customer, o.project, dt_beg, a.actdate '+
    'from v_orders o, dv.acts a '+
    'where o.id_itm = a.id_zakaz and o.dt_to_sgp is null and o.id_organization <> -1 and a.actdate = :dt$d ' +
    'order by dt_beg, ornum',
    [IncDay(Date, -1)],
    naO
  );
  if (naP.Count = 0) and (naO.Count = 0) then
    Exit;
  HTML := '<b>Вчера были преждевременно созданы АВР</b><br>';
  if naP.Count > 0 then begin
    HTML := HTML + '<br><b>По производственным заказам:</b><br>';
    for var i := 0 to naP.High do begin
      S.ConcatStP(HTML, naP.G(i, 'ornum') + '  ' + DateToStr(naP.G(i, 'dt_beg')) {+ '  ' + DateToStr(naP.G(i, 'actdate'))} + '"   "' + naP.G(i, 'project') + '"', '<br>');
    end;
  end;
  if naO.Count > 0 then begin
    HTML := HTML + '<br><br><b>По отгрузочным заказам:</b><br>';
    for var i := 0 to naO.High do begin
      S.ConcatStP(HTML, naO.G(i, 'ornum') + '  ' + DateToStr(naO.G(i, 'dt_beg')) {+ '  ' + DateToStr(naO.G(i, 'actdate'))} + '   "' + naO.G(i, 'customer') + '"   "' + naO.G(i, 'project') + '"', '<br>');
    end;
  end;
  Tasks.SendMail(TASK_MAILING_EARLY_COMPLETION_ACTS, 'Преждевременно созданы АВР', HTML, [], '~');
end;

procedure TTasksS.ReportForSupplyisOnwaySurplus;
//отчет по сырью, находящемуся в пути при отсуствии резерва на него
var
  na: TNamedArr;
  Fields: TVarDynArray2;
  FileToSend: string;
  Tbl: THTMLTable;
  HTML, Title, TopSt: string;
begin
  Title := 'Номенклатура в пути без резерва за вчерашний день';
  TopSt := 'Номенклатура в пути без резерва за ' + DateTimeToStr(IncDay(Date, -1));
  Fields := [
    ['name$s', 'Наименование', '500;h'],
    ['name_unit$s', 'Ед. изм.', '80'],
    ['price_main$f', 'Цена', '80', 'r'],
    ['price_check$f', 'Контрольная цена', '80', 'r'],
    ['qnt$f', 'Кол-во на складах', '80', 'r'],
    ['need$f', 'Потребность','80', 'f=#:', 'r'],
    ['min_ostatok$i','Минимальный остаток','80','r'],
    ['rezerv$f', 'Резерв','80', 'f=#:', 'r'],
    ['qnt_onway$f', 'В пути', '80', 'f=#:', 'r'],
    ['qnt_onway_surplus$s', 'Превышение', '80', 'f=#:', 'r'],
    ['qnt_onway_sum$f', 'Сумма в пути', '80', 'f=#:', 'r']
  ];
  Q.QLoad(Q.QGetSql('A', 'v_spl_minremains', Fields.Col(0).Implode(';'))+ ' where id_category = 1 and qnt_onway_surplus is not null order by qnt_onway_surplus desc', [], na);
  HTML := '';
  if na.Count > 0 then begin
    Tbl.InitDefaults;
    Tbl.SetOptions('report-table', '—', True, '0.00', 'dd.mm.yyyy', 'dd.mm.yyyy hh:nn:ss', True, True);
    HTML := '<b>Номенклатура в пути без резерва:</b><br>' + Tbl.GenerateEmail(na, Fields, 1, 2, 0);
    FileToSend := Sys.GetWinTemp + '\' + TopSt + '.xlsx';
    ExportToXlsx(FileToSend, na, Fields, TopSt, '', True);
  end
  else
    HTML := 'Номенклатура в пути без резерва отсуствует.<br>';
  Tasks.SendMail(TASK_MAILING_MONITORING_SN, Title, HTML, [FileToSend], '~');
end;

procedure TTasksS.ReportForRawMaterialsOnSgp;
//отчет по материалам на складах готовой продукции, являющихся сырьем а не изделиями
var
  na: TNamedArr;
  Fields: TVarDynArray2;
  FileToSend: string;
  Tbl: THTMLTable;
  HTML, Title, TopSt: string;
begin
  Title := 'Номенклатура на СГП, не являющаяся готовой продукцией';
  TopSt := Title;
  Fields := [
    ['name$s', 'Наименование', '500;h'],
    ['stockname$s', 'Склад', '160'],
    ['qnt$f', 'Кол-во', '80', 'r']
  ];
  Q.QLoad(Q.QGetSql('A', 'v_spl_raw_materials_on_sgp', Fields.Col(0).Implode(';'))+ ' order by stockname, name', [], na);
  HTML := '';
  if na.Count > 0 then begin
    Tbl.InitDefaults;
    Tbl.SetOptions('report-table', '—', True, '0.00', 'dd.mm.yyyy', 'dd.mm.yyyy hh:nn:ss', True, True);
    HTML := '<b>' + Title + '</b><br>' + Tbl.GenerateEmail(na, Fields, 1, 2, 0);
    FileToSend := Sys.GetWinTemp + '\' + TopSt + '.xlsx';
    ExportToXlsx(FileToSend, na, Fields, TopSt, '', True);
  end
  else
    HTML := '';
  if HTML <> '' then
    Tasks.SendMail(TASK_MAILING_MONITORING_STOCKS, Title, HTML, [FileToSend], '~');
end;

procedure TTasksS.ReportForActsWriteoffReceipt;
//информация по актам списания и оприходования за вчерашний день
var
  na: TNamedArr;
  Fields: TVarDynArray2;
  FileToSend: string;
  Tbl: THTMLTable;
  HTML, Title, TopSt: string;
begin
  Title := 'Акты списания и оприходования за вчерашний день';
  TopSt := 'Акты списания и оприходования за ' + DateTimeToStr(IncDay(Date, -1));
  Fields := [
    ['doctype$s', 'Вид документа', '120'],
    ['docnum$s', '№', '80'],
    ['stockname$s', 'Склад', '150'],
    ['comments$s', 'Примечание', '400;h'],
    ['is_inventory$s', 'Инвентаризация', '120'],
    ['name$s', 'Наименование', '500;h'],
    ['name_unit$s', 'Ед. изм.', '80'],
    ['qnt$f', 'Кол-во', '80', 'r']
  ];
  Q.QLoad(Q.QGetSql('A', 'v_acts_writeoff_receipt', Fields.Col(0).Implode(';')) + ' where dt = :dt$d order by doctype, name', [IncDay(Date, -1)], na);
  HTML := '';
  if na.Count > 0 then begin
    Tbl.InitDefaults;
    Tbl.SetOptions('report-table', '—', True, '0.00', 'dd.mm.yyyy', 'dd.mm.yyyy hh:nn:ss', True, True);
    HTML := '<b>' + TopSt + '</b><br>' + Tbl.GenerateEmail(na, Fields, 1, 2, 0);
    FileToSend := Sys.GetWinTemp + '\' + TopSt + '.xlsx';
    ExportToXlsx(FileToSend, na, Fields, TopSt, '', True);
  end
  else
    HTML := '';
  if HTML <> '' then
    Tasks.SendMail(TASK_MAILING_MONITORING_STOCKS, Title, HTML, [FileToSend], '~');
end;

procedure TTasksS.ReportForNegativeQuantityOnSgp;
//отчет по позициям на СГП (стандартные изделия) с отрицательным текущим количеством
var
  na: TNamedArr;
  Fields: TVarDynArray2;
  FileToSend: string;
  FileToSendArr: TVarDynArray;
  Tbl: THTMLTable;
  HTML, Title, TopSt: string;
begin
  Title := 'Изделия с отрицательным остатком на СГП';
  TopSt := 'Изделия с отрицательным остатком на СГП на ' + DateTimeToStr(IncDay(Date, -1));
  Fields := [
    ['format_name$s', 'Формат', '150'],
    ['slash$s', 'Слеш', '00'],
    ['name$s', 'Наименование', '500;h'],
    ['qnt$f', 'Кол-во', '80', 'r']
  ];
  Q.QLoad(Q.QGetSql('A', 'v_sgp_items', Fields.Col(0).Implode(';')) + ' where qnt < 0 order by format_name, name', [IncDay(Date, -1)], na);
  HTML := '';
  if na.Count > 0 then begin
    Tbl.InitDefaults;
    Tbl.SetOptions('report-table', '—', True, '0.00', 'dd.mm.yyyy', 'dd.mm.yyyy hh:nn:ss', True, True);
    HTML := '<b>' + TopSt + '</b><br>' + Tbl.GenerateEmail(na, Fields, 1, 2, 0);
    FileToSend := Sys.GetWinTemp + '\' + TopSt + '.xlsx';
    ExportToXlsx(FileToSend, na, Fields, TopSt, '', True);
    FileToSendArr := [FileToSend];
  end
  else
    HTML := 'На СГП нет позиций с отрицательными остатками.';
  if HTML <> '' then
    Tasks.SendMail(TASK_MAILING_MONITORING_STOCKS, Title, HTML, FileToSendArr, '~');
end;

procedure TTasksS.ReportForNegativeQuantityOnStocks;
//отчет по номенклатурым позициям (материалы) с отрицательным оличеством на складах
var
  na: TNamedArr;
  Fields: TVarDynArray2;
  FileToSend: string;
  FileToSendArr: TVarDynArray;
  Tbl: THTMLTable;
  HTML, Title, TopSt: string;
begin
  Title := 'Материалы с отрицательным остатком на складах';
  TopSt := 'Материалы с отрицательным остатком на складах на ' + DateTimeToStr(IncDay(Date, -1));
  Fields := [
    ['name$s', 'Наименование', '500;h'],
    ['artikul$s', 'Артикул', '150'],
    ['name_unit$s', 'Ед. изм.', '00'],
    ['qnt$f', 'Текущий остаток', '100', 'r']
  ];
  Q.QLoad(Q.QGetSql('A', 'v_spl_minremains', Fields.Col(0).Implode(';')) + ' where qnt < 0 order by name', [IncDay(Date, -1)], na);
  HTML := '';
  if na.Count > 0 then begin
    Tbl.InitDefaults;
    Tbl.SetOptions('report-table', '—', True, '0.00', 'dd.mm.yyyy', 'dd.mm.yyyy hh:nn:ss', True, True);
    HTML := '<b>' + TopSt + '</b><br>' + Tbl.GenerateEmail(na, Fields, 1, 2, 0);
    FileToSend := Sys.GetWinTemp + '\' + TopSt + '.xlsx';
    ExportToXlsx(FileToSend, na, Fields, TopSt, '', True);
    FileToSendArr := [FileToSend];
  end
  else
    HTML := 'На складах нет материалов с отрицательными остатками.';
  if HTML <> '' then
    Tasks.SendMail(TASK_MAILING_MONITORING_STOCKS, Title, HTML, FileToSendArr, '~');
end;


procedure TTasksS.ReportForOverdueOrders(AForProductionOrders: Boolean);
//отчет по просроченным заказам
//(которые не готовы после наступления плановой даты отгрузки)
var
  na: TNamedArr;
  Fields: TVarDynArray2;
  FileToSend: string;
  FileToSendArr: TVarDynArray;
  Tbl: THTMLTable;
  HTML, Title, TopSt: string;
begin
  Title := 'Просроченные ' + S.IIf(AForProductionOrders, 'производственные', 'отгрузочные') + ' заказы';
  TopSt := Title + ' на ' + DateTimeToStr(IncDay(Date, -1));
  Fields := [
    ['ornum$s', 'Заказ', '90'],
    ['dt_beg$d', 'Дата создания', '100'],
    ['customer$s', 'Покупатель', '300;h'],
    ['project$s', 'Проект', '300;h'],
    ['or_reference$s', 'Основание', '80'],
    ['area_short$s', 'Площадка', '80'],
    ['dt_otgr$d', 'Плановая дата отгрузки', ''],
    ['dt_to_prod$d', 'Запущен в производство', '100'],
    ['dt_to_sgp$d', 'Принят на СГП', '100'],
    ['dt_from_sgp$d', 'Отгружен с СГП', '100'],
    ['overdue_days$i', 'Просрочка', '100']
  ];
  Q.QLoad(Q.QGetSql('A',
    S.IIf(AForProductionOrders, 'v_rep_overdue_production_orders', 'v_rep_overdue_shipment_orders'),
    Fields.Col(0).Implode(';')) + ' where dt_control is null order by dt_beg, ornum', [], na
  );
  HTML := '';
  if na.Count > 0 then begin
    Tbl.InitDefaults;
    Tbl.SetOptions('report-table', '—', True, '0.00', 'dd.mm.yyyy', 'dd.mm.yyyy hh:nn:ss', True, True);
    HTML := '<b>' + TopSt + '</b><br>' + Tbl.GenerateEmail(na, Fields, 1, 2, 0);
    FileToSend := Sys.GetWinTemp + '\' + TopSt + '.xlsx';
    ExportToXlsx(FileToSend, na, Fields, TopSt, '', True);
    FileToSendArr := [FileToSend];
  end
  else
    HTML := TopSt + ' отсутствуют.';
  if HTML <> '' then
    Tasks.SendMail(TASK_MAILING_ORDERS_FIN, Title, HTML, FileToSendArr, '~');
end;

procedure TTasksS.ReportForOverdueOrdersByStartTpoProductionDate;
//отчет по просроченным по дате начала производства производственным заказам
//даты по регламенту считаются не от даты оформления заказы, а обратныым образом, от даты отгрузки!
var
  na: TNamedArr;
  Fields: TVarDynArray2;
  FileToSend: string;
  FileToSendArr: TVarDynArray;
  Tbl: THTMLTable;
  HTML, Title, TopSt: string;
begin
  Title := 'Просроченные по дате выдачи в производство заказы';
  TopSt := Title + ' на ' + DateTimeToStr(IncDay(Date, -1));
  Fields := [
    ['ornum$s', 'Заказ', '90'],
    ['dt_beg$d', 'Дата создания', '100'],
    ['project$s', 'Проект', '300;h'],
    ['or_reference$s', 'Основание', '80'],
    ['area_short$s', 'Площадка', '80'],
    ['dt_otgr$d', 'Плановая дата отгрузки', ''],
    ['dt_by_reglament_from_otgr$d', 'Плановая дата запуска', '100'],
//    ['dt_to_prod$d', 'Запущен в производство', '100'],
    ['overdue_days_from_otgr$i', 'Просрочка', '100']
  ];
  Q.QLoad(Q.QGetSql('A', 'v_rep_overdue_start_production_orders',
    Fields.Col(0).Implode(';')) + ' where dt_control is null and overdue_days > 0 order by dt_beg, ornum', [], na
  );
  HTML := '';
  if na.Count > 0 then begin
    Tbl.InitDefaults;
    Tbl.SetOptions('report-table', '—', True, '0.00', 'dd.mm.yyyy', 'dd.mm.yyyy hh:nn:ss', True, True);
    HTML := '<b>' + TopSt + '</b><br>' + Tbl.GenerateEmail(na, Fields, 1, 2, 0);
    FileToSend := Sys.GetWinTemp + '\' + TopSt + '.xlsx';
    ExportToXlsx(FileToSend, na, Fields, TopSt, '', True);
    FileToSendArr := [FileToSend];
  end
  else
    HTML := TopSt + ' отсутствуют.';
  if HTML <> '' then
    Tasks.SendMail(TASK_MAILING_ORDERS_FIN, Title, HTML, FileToSendArr, '~');
end;

procedure TTasksS.ReportForSuppliersNegativeDemand;
//отчет по сырью, у которого есть отрицательная (с учетом минимального остатка) потребность на текущий момент
var
  na, naCats: TNamedArr;
  Fields: TVarDynArray2;
  FileToSend: string;
  FileToSendArr: TVarDynArray;
  Tbl: THTMLTable;
  HTML, Title, TopSt, CatName: string;
  i: Integer;
begin
  Title := 'Номенклатура с отрицательной потребностью на вчерашний день';
  TopSt := 'Номенклатура с отрицательной потребностью на ' + DateTimeToStr(IncDay(Date, -1));
  Fields := [
    ['name$s', 'Наименование', '500;h'],
    ['name_unit$s', 'Ед. изм.', '80'],
    ['qnt$f', 'Кол-во на складах', '80', 'r'],
    ['min_ostatok$i','Минимальный остаток','80','r'],
    ['rezerv$f', 'Резерв','80', 'f=#', 'r'],
    ['qnt_onway$f', 'В пути', '80', 'f=#', 'r'],
    ['qnt1$f', 'Расход за месяц', '80', 'f=#:', 'r'],      //период по факту может быть любой, он настраивается в таблице снабжения
    ['price$f', 'Цена','80', 'f=#', 'r'],
    ['need$f', 'Мин. потребность','80', 'f=#', 'r'],
    ['need_cost$f', 'Стоимость мин. потребности','100', 'f=#:', 'r'],  //стоимость по price_main, если ее нет то по контрольной!
    ['need_m$f', 'Потребность с учетом остатка','80', 'f=#', 'r'],
    ['need_m_cost$f', 'Стоимость потребности с учетом остатка','100', 'f=#:', 'r']
  ];
  //список категорий, по которым вообще есть отрицательная потребность, по возрастанию айди
  //категории (у "снабжение" id=1, обычно должна идти первой), "без категории" - последней
  Q.QLoad('select distinct category_name, nvl(id_category, 999999) as sortord from v_rep_suppliers_negative_demand ' +
    'where need_m < 0 order by sortord, category_name', [], naCats);
  HTML := '';
  FileToSendArr := [];
  for i := 0 to naCats.Count - 1 do begin
    CatName := naCats.GetValue(i, 'category_name');
    Q.QLoad(Q.QGetSql('A', 'v_rep_suppliers_negative_demand', Fields.Col(0).Implode(';'))+
      ' where need_m < 0 and category_name = :category_name$s order by need_m asc', [CatName], na);
    if na.Count > 0 then begin
      Tbl.InitDefaults;
      Tbl.SetOptions('report-table', '—', True, '0.00', 'dd.mm.yyyy', 'dd.mm.yyyy hh:nn:ss', True, True);
      HTML := HTML + '<b>' + CatName + ':</b><br>' + Tbl.GenerateEmail(na, Fields, 1, 2, 0) + '<br>';
      FileToSend := Sys.GetWinTemp + '\' + TopSt + ' - ' + CatName + '.xlsx';
      ExportToXlsx(FileToSend, na, Fields, TopSt + ' - ' + CatName, '', True);
      FileToSendArr := FileToSendArr + [FileToSend];
    end;
  end;
  if HTML = '' then
    HTML := 'Номенклатура с отрицательной потребностью отсуствует.<br>';
  Tasks.SendMail(TASK_MAILING_MONITORING_SN, Title, HTML, FileToSendArr, '~');
end;


procedure TTasksS.ReportForEstimatesOverdue(ObjType: Integer);
//отчет по просроченным сметам (1) и загрузкам технологов (2)
var
  na: TNamedArr;
  Fields: TVarDynArray2;
  FileToSend: string;
  Tbl: THTMLTable;
  HTML, Title, TopSt, ObjSt, SqlWhere: string;
begin
  ObjSt := S.IIFStr(ObjType = 1, 'сметы', 'файлы технологов');
  SqlWhere := S.IIFStr(ObjType = 1, 'Конструктор смета', 'Технолог загрузка');
  Title := 'Изделия, по которым были просрочены ' + ObjSt;
  TopSt := 'Изделия, по которым были просрочены ' + ObjSt + ' на ' + DateTimeToStr(IncDay(Date, -1));
  Fields := [
    ['slash$s', '', '80'],
    ['itemname$s', 'Наименование', '300;h'],
    ['project$s', 'Проект', '200'],
    ['dt_beg$d', 'Дата заказа', '80'],
    ['dt_otgr$s', 'Дата отгрузки', '80'],
    ['kns$s', 'Конструктор', '100'],
    ['thn$s', 'Технолог', '100'],
    ['dt_by_reglament$d', 'Дата по регламенту', '80'],
    ['dt_fact$d', 'Дата фактическая', '80'],
    ['overdue_days_yesterday$i', 'Просрочка', '80']
  ];
  //выберем с условием, что смета/файлы еще не загружены,
  Q.QLoad(Q.QGetSql('A', 'v_rep_orders_overdue_kns_thn_2', Fields.Col(0).Implode(';'))+ ' where type = ''' + SqlWhere +
    ''' and dt_fact is null and overdue_days_yesterday < 0 order by overdue_days_yesterday asc', [], na
  );
  HTML := '';
  if na.Count > 0 then begin
    Tbl.InitDefaults;
    Tbl.SetOptions('report-table', '—', True, '0.00', 'dd.mm.yyyy', 'dd.mm.yyyy hh:nn:ss', True, True);
    HTML := '<b>' + Title + ':</b><br>' + Tbl.GenerateEmail(na, Fields, 1, 2, 0);
    FileToSend := Sys.GetWinTemp + '\' + TopSt + '.xlsx';
    ExportToXlsx(FileToSend, na, Fields, TopSt, '', True);
  end
  else
    HTML := Title + ', отсуствуют.<br>';
  Tasks.SendMail(TASK_MAILING_ORDERS_FIN, Title, HTML, [FileToSend], '~');
end;

procedure TTasksS.ReportForNegativeNeedBySgp;
//отчет по позициям с отрицательной потребностью из текущего состояния сгп
var
  na: TNamedArr;
  Fields: TVarDynArray2;
  FileToSend: string;
  FileToSendArr: TVarDynArray;
  Tbl: THTMLTable;
  HTML, Title, TopSt: string;
begin
  Title := 'Изделия с отрицательной потребностью на СГП';
  TopSt := Title + ' на ' + DateTimeToStr(IncDay(Date, -1));
  Fields := [
    ['format_name$s', 'Формат', '150'],
    ['slash$s', 'Слеш', '00'],
    ['name$s', 'Наименование', '500;h'],
    ['qnt$f', 'Кол-во', '80', 'r'],
    ['qnt_need$f', 'Потребность', '80', 'r']
  ];
  Q.QLoad(Q.QGetSql('A', 'v_sgp_items', Fields.Col(0).Implode(';')) + ' where qnt_need < 0 order by qnt_need, format_name, name', [IncDay(Date, -1)], na);
  HTML := '';
  if na.Count > 0 then begin
    Tbl.InitDefaults;
    Tbl.SetOptions('report-table', '—', True, '0.00', 'dd.mm.yyyy', 'dd.mm.yyyy hh:nn:ss', True, True);
    HTML := '<b>' + TopSt + '</b><br>' + Tbl.GenerateEmail(na, Fields, 1, 2, 0);
    FileToSend := Sys.GetWinTemp + '\' + TopSt + '.xlsx';
    ExportToXlsx(FileToSend, na, Fields, TopSt, '', True);
    FileToSendArr := [FileToSend];
  end
  else
    HTML := 'На СГП нет позиций с отрицательной потребностью.';
  if HTML <> '' then
    Tasks.SendMail(TASK_MAILING_MONITORING_STOCKS, Title, HTML, FileToSendArr, '~');
end;

procedure TTasksS.ReportForOrdersPlannedToStartTomorrow;
//отчет по производственным заказам, планирующемся к выдаче в производтство на завтра
//(дата определяется следующим днем поле участка планирования по регламенту)
var
  na: TNamedArr;
  Fields: TVarDynArray2;
  FileToSend: string;
  FileToSendArr: TVarDynArray;
  Tbl: THTMLTable;
  HTML, Title, TopSt: string;
begin
  Title := 'Заказы, запланированные к производству на завтра';
  TopSt := Title + ' (на ' + DateTimeToStr(IncDay(Date, +1)) + ')';
  Fields := [
    ['ornum$s', 'Заказ', '90'],
    ['dt_beg$d', 'Дата создания', '100'],
    ['project$s', 'Проект', '300;h'],
    ['or_reference$s', 'Основание', '80'],
    ['area_short$s', 'Площадка', '80'],
    ['dt_otgr$d', 'Плановая дата отгрузки', '']
  ];
  Q.QLoad(Q.QGetSql('A', 'v_rep_for_orders_planned_to_start_tomorrow',
    Fields.Col(0).Implode(';')) + ' order by dt_beg, ornum', [], na
  );
  HTML := '';
  if na.Count > 0 then begin
    Tbl.InitDefaults;
    Tbl.SetOptions('report-table', '—', True, '0.00', 'dd.mm.yyyy', 'dd.mm.yyyy hh:nn:ss', True, True);
    HTML := '<b>' + TopSt + '</b><br>' + Tbl.GenerateEmail(na, Fields, 1, 2, 0);
    FileToSend := Sys.GetWinTemp + '\' + TopSt + '.xlsx';
    ExportToXlsx(FileToSend, na, Fields, TopSt, '', True);
    FileToSendArr := [FileToSend];
  end
  else
    HTML := TopSt + ', отсутствуют.';
  if HTML <> '' then
    Tasks.SendMail(TASK_MAILING_ORDERS_FIN, Title, HTML, FileToSendArr, '~');
end;


procedure TTasksS.ReportForRequiredMaterialsForPlannedOrdersTomorrow;
//Недостающие материалы для производства заказов, запланированных на завтра
var
  na: TNamedArr;
  Fields: TVarDynArray2;
  FileToSend: string;
  FileToSendArr: TVarDynArray;
  Tbl: THTMLTable;
  HTML, Title, TopSt: string;
begin
  Title := 'Недостающие материалы для производства заказов, запланированных на завтра';
  TopSt := Title + ' (на ' + DateTimeToStr(IncDay(Date, +1)) + ')';
  Fields := [
    ['groupname$s','Группа','200'],
    ['artikul$s','Артикул','120'],
    ['name$s','Наименование','300;h'],
    ['unit$s','Ед.изм','70'],
    ['qnt$f','Кол-во по смете','90','f=f'],
    ['qnt_diff$f','Незватка','90','f=f']
  ];
  Q.QLoad(Q.QGetSql('A', 'v_rep_required_materials_for_planned_orders_tomorrow',
    Fields.Col(0).Implode(';')) + ' where qnt_diff < 0 order by groupname, name', [], na
  );
  HTML := '';
  if na.Count > 0 then begin
    Tbl.InitDefaults;
    Tbl.SetOptions('report-table', '—', True, '0.00', 'dd.mm.yyyy', 'dd.mm.yyyy hh:nn:ss', True, True);
    HTML := '<b>' + TopSt + '</b><br>' + Tbl.GenerateEmail(na, Fields, 1, 2, 0);
    FileToSend := Sys.GetWinTemp + '\' + TopSt + '.xlsx';
    ExportToXlsx(FileToSend, na, Fields, TopSt, '', True);
    FileToSendArr := [FileToSend];
  end
  else
    HTML := TopSt + ', отсутствуют.';
  if HTML <> '' then
    Tasks.SendMail(TASK_MAILING_ORDERS_FIN, Title, HTML, FileToSendArr, '~');
end;

procedure TTasksS.ReportForPlannedShipments;
//заказы, запланированные к отгрузке сегодня, завтра и псолезавтра
var
  naOrders, naItems: TNamedArr;
  FieldsOrders, FieldsItems: TVarDynArray2;
  FileToSend: string;
  FileToSendArr: TVarDynArray;
  Tbl: THTMLTable;
  HTML, Title, TopSt: string;
begin
  Title := 'Запланированные отгрузки';
  TopSt := Title + ' (' + DateTimeToStr(Date) + ' - ' + DateTimeToStr(IncDay(Date, 2)) + ')';
  FieldsOrders := [
    ['ornum$s', 'Заказ', '90'],
    ['dt_beg$d', 'Дата создания', '100'],
    ['customer$s', 'Покупатель', '300;h'],
    ['project$s', 'Проект', '300;h'],
    ['cost$f', 'Стоимость заказа', '100', 'f=#:', 'r'],
    ['dt_otgr$d', 'Дата отгрузки', '100']
  ];
  FieldsItems := [
    ['ornum$s', 'Заказ', '90'],
    ['dt_otgr$d', 'Дата отгрузки', '100'],
    ['fullitemname$s', 'Изделие', '400;h'],
    ['qnt$f', 'Количество', '80', 'r'],
    ['qnt_on_sgp$f', 'Количество на СГП', '80', 'r'],
    ['qnt_shortage$f', 'Нехватка', '80', 'r']
  ];
  Q.QLoad(Q.QGetSql('A', 'v_rep_planned_shipments_orders', FieldsOrders.Col(0).Implode(';')) + ' order by dt_otgr, ornum', [], naOrders);
  Q.QLoad(Q.QGetSql('A', 'v_rep_planned_shipments_items', FieldsItems.Col(0).Implode(';')) + ' order by dt_otgr, ornum, pos', [], naItems);
  HTML := '';
  FileToSendArr := [];
  if naOrders.Count > 0 then begin
    Tbl.InitDefaults;
    Tbl.SetOptions('report-table', '', True, '0.00', 'dd.mm.yyyy', 'dd.mm.yyyy hh:nn:ss', True, True);
    HTML := '<b>' + TopSt + '</b><br>' + Tbl.GenerateEmail(naOrders, FieldsOrders, 1, 2, 0) + '<br>';
    FileToSend := Sys.GetWinTemp + '\' + TopSt + ' - заказы.xlsx';
    ExportToXlsx(FileToSend, naOrders, FieldsOrders, TopSt, '', True);
    FileToSendArr := FileToSendArr + [FileToSend];
  end
  else
    HTML := TopSt + ' - заказы отсутствуют.<br>';
  if naItems.Count > 0 then begin
    Tbl.InitDefaults;
    Tbl.SetOptions('report-table', '', True, '0.00', 'dd.mm.yyyy', 'dd.mm.yyyy hh:nn:ss', True, True);
    HTML := HTML + '<b>Изделия по заказам:</b><br>' + Tbl.GenerateEmail(naItems, FieldsItems, 1, 2, 0);
    FileToSend := Sys.GetWinTemp + '\' + TopSt + ' - изделия.xlsx';
    ExportToXlsx(FileToSend, naItems, FieldsItems, TopSt + ' - изделия', '', True);
    FileToSendArr := FileToSendArr + [FileToSend];
  end;
  Tasks.SendMail(TASK_MAILING_ORDERS_FIN, Title, HTML, FileToSendArr, '~');
end;

end.


