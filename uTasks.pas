unit uTasks;

{

Модуль, обеспечивающий работу с серверным процессом
(скрипт на php, работающий в режиме демона на файловом сервере).

скрипт обеспечивает такие задачи, как копирование на сервер или удаление на нем
файлов, рассылку почты, перемещение папок на сервере и т.п., для чего работает
от root.

посылка данных скрипту осуществляется созданием в служебном каталоге директории
с названием по текущему времени.
каждый параметр, необходимый для работы серверного скрипта, хранится в этом
каталоге в отдельном файле. в подкаталогах каталога задачи могут находяться
файлы, которые надо передать на сервер.

порядок работы:
каталог создается и возвращаетмя функцией CreateTaskDir.
далее процедура создания задачи создает в нем необходимые для сервного
процесса файлы и папки.
после вызывается процедура FinalizeTaskDir(TaskDir).
она переименовывает каталог задачи, добавляя префикс "GO_", после чего сервер
обрабатывает задачу.
по окончанию обработки серверный скрипт переименовывает каталог задачи,
присываивая префикс "OLD_".
то, что задача обработана, мождно проверить функцией
IsTaskComplete(const TaskDir)


}

interface

uses
 Graphics, Classes, DateUtils, Variants, SysUtils, Types, uString,Windows, uNamedArr
 ;


type
  TMyTskOpTypes = (
    mytskopMail, mytskopMailHtml, mytskopMoveToArchive, mytskopDeleteFromArchive, mytskopMoveToCurrent, mytskopSmetaReport, mytskopDeleteAllFromAccounts,
    mytskopGetFileListByMask, mytskopDeleteDirectoriesFromList, mytskopDeleteFilesFromList, mytskopToPassportChange,
    mytskopToSnDocuments, mytskopToEstimates, mytskopToThnDocuments, mytskopLinkMontage, mytskopToKnsDocuments
  );

type
  TTasks = record
  private
  public
    //создает на сервере паку для задачи
    function  CreateTaskDir: string;
    //финализирует задачу, после чего ее может обработать сервер
    function  FinalizeTaskDir(TaskDir: string): Boolean;
    //создает каталог и файлы задачи для серверного процессса (php-скрипт на файловом сервере)
    //обмен данными односторонний, осуществляется через создание каталога с файлами, в которых передаются параметры для скрипта
    //возвращает временную метку, с которой создан каталог задачи
    function  CreateTaskRoot(Operation: TMyTskOpTypes; Fields: TVarDynArray2; ForTesting: Boolean = False; AutoRun: Boolean = True): string;
    //проверяет, что зхадача обработалась сервером
    function  IsTaskComplete(const TaskDir: string): Boolean;

    //вернуть адрес почтовой рассылки
    //в тестовом режиме (запуск приложенния с параметром /test) всегда возвращает почту разработчика
    function  GetMailingAddr(AMaining: Integer): string;
    //оправляем почту с прикрепленными файлами
    //адресат - код рассылки или перечисление адресов через запятую
    //тело, в случае html, без тега <body>
    //отправитель, если путой, то текущий пользователь, если '~' то Учет, если строка то как передан, в режиме /test всегда отправка разработчику
    function  SendMail(const ASendTo: Variant; const ASubject, ABody: string; const AFiles: TVarDynArray; const AFromUser: string = ''; const AAsHTML: Boolean = True): Boolean;
    //выгружает в adm_mailing эталонный список рассылок серверных заданий
    //(id/название/позиция заданы прямо в реализации ниже) - для кода
    //рассылки, которого там еще нет, вставляет строку; если код уже есть, но
    //отличается название или позиция - обновляет только их, не трогая
    //userids/customemail/addresses/dt (заполняются вручную через форму
    //настройки рассылок). вызывается по кнопке разработчика "Задать
    //рассылки" формы uFrmADedtMailingSettings (uFrmADedtMailingSettings.pas)
    procedure SyncServerTaskMailings;
  end;

var
  Tasks: TTasks;

const
  //константы идентификации почтовых рассылок
  //TTasks.SyncServerTaskMailings ниже - переносит эти коды, их названия (как
  //у соответствующего задания расписания) и позиции в интерфейсе рассылок в
  //таблицу adm_mailing
  TASK_MAILING_ORDERS = 1;
  TASK_MAILING_ATTACH_ESTIMATE_SN = 3;
  TASK_MAILING_NO_ESTIMATE = 4;
  TASK_MAILING_ATTACH_THN = 5;
  TASK_MAILING_ORDERS_FIN = 6;
  TASK_MAILING_CREATED_SUPPLIER_DEMAND = 7;
  TASK_MAILING_EARLY_COMPLETION_ACTS = 8;
  TASK_MAILING_MONITORING_STOCKS = 9;
  TASK_MAILING_ORDERS_APPROVE = 10;
  TASK_MAILING_ORDERS_REJECT = 11;
  TASK_MAILING_SUPPLY_DEALS_HOURLY_MONITORING = 12;
  TASK_MAILING_SUPPLY_DEALS_YESTERDAY = 13;
//  TASK_MAILING_PRODUCTION_ORDERS_YESTERDAY = 14;
//  TASK_MAILING_SHIPMENT_ORDERS_YESTERDAY = 15;
  TASK_MAILING_SUPPLY_ONWAY_SURPLUS = 16;
  TASK_MAILING_RAW_MATERIALS_ON_SGP = 17;
  TASK_MAILING_ACTS_WRITEOFF_RECEIPT = 18;
  TASK_MAILING_NEGATIVE_QUANTITY_ON_STOCKS = 19;
  TASK_MAILING_NEGATIVE_QUANTITY_ON_SGP = 20;
  TASK_MAILING_NEGATIVE_NEED_BY_SGP = 21;
  TASK_MAILING_OVERDUE_PRODUCTION_ORDERS = 22;
  TASK_MAILING_OVERDUE_SHIPMENT_ORDERS = 23;
  TASK_MAILING_OVERDUE_ORDERS_BY_PRODUCTION_START_DATE = 24;
  TASK_MAILING_SUPPLIERS_NEGATIVE_DEMAND = 25;
  TASK_MAILING_ESTIMATES_OVERDUE = 26;
  TASK_MAILING_TECHNOLOGISTS_LOAD_OVERDUE = 27;
  TASK_MAILING_ORDERS_PLANNED_TO_START_TOMORROW = 28;
  TASK_MAILING_REQUIRED_MATERIALS_TOMORROW = 29;
  TASK_MAILING_PLANNED_SHIPMENTS = 30;
//  TASK_MAILING_PRODUCTION_ORDERS_LAST_WEEK = 31;
//  TASK_MAILING_SHIPMENT_ORDERS_LAST_WEEK = 32;
//  TASK_MAILING_PRODUCTION_ORDERS_LAST_MONTH = 33;
//  TASK_MAILING_SHIPMENT_ORDERS_LAST_MONTH = 34;
  TASK_MAILING_MATERIAL_OPEN_REQUIREMENTS = 35;
  //пользователь (подпись) для служебных почтовых рассылок
  TASK_DEFAULT_SENDER = 'Учёт';

implementation

uses
  uDBOra,
  uData,
  uSys,
  uHtmlUtils,
  uExportToXlsx
  ;


function TTasks.GetMailingAddr(AMaining: Integer): string;
//вернуть адрес почтовой рассылки
//в тестовом режиме (запуск приложенния с параметром /test) всегда возвращает почту разработчика
begin
  if Q.QLoadValue('select count(*) from adm_mailing where id = :i$i', [AMaining]) <> 0 then begin
    if Module.InTestmode then
      Result := DEVELOPER_MAIL
    else
      Result := Q.QLoadValue('select addresses from adm_mailing where id = :i$i', [AMaining]).AsString
  end
  else
    raise Exception.Create('Не существует почтовая рассылка с кодом ' + IntToStr(AMaining));
//Result := DEVELOPER_MAIL
end;

function TTasks.CreateTaskDir: string;
//создает на сервере паку для задачи
var
  st: string;
begin
  Result := '';
  try
    st := Module.GetPath_Tasks + '\' + FormatDateTime('yyyy.mm.dd_hh-mm-ss,zzzzzz', Now);
    if not ForceDirectories(st + '\Files') then
      Exit;
  except
    Exit;
  end;
  Result := st;
end;

function TTasks.FinalizeTaskDir(TaskDir: string): Boolean;
//финализирует задачу, после чего ее может обработать сервер (переименовывает папку задачи)
begin
  Result := RenameFile(TaskDir, ExtractFilePath(TaskDir) + '\GO_' + ExtractFileName(TaskDir));
end;

function TTasks.CreateTaskRoot(Operation: TMyTskOpTypes; Fields: TVarDynArray2; ForTesting: Boolean = False; AutoRun: Boolean = True): string;
//создает каталог и файлы задачи для серверного процессса (php-скрипт на файловом сервере)
//обмен данными односторонний, осуществляется через создание каталога с файлами, в которых передаются параметры для скрипта
//возвращает временную метку, с которой создан каталог задачи
var
  st, TaskDir: string;
  op: string;
  i: Integer;
  b: Boolean;
begin
  Result := '';
  TaskDir := CreateTaskDir;
  if TaskDir = '' then
    Exit;
  case Operation of
    myTskOpMail:
      op := 'message';
    myTskOpMailHtml:
      op := 'messagehtml';
    mytskopMoveToArchive:
      op := 'to_move_in_archive';
    mytskopDeleteFromArchive:
      op := 'to_delete_from_archive';
    mytskopMoveToCurrent:
      op := 'to_move_in_current';
    mytskopDeleteAllFromAccounts:
      op := 'to_deleteall_from_accounts';
    mytskopGetFileListByMask:
      op := 'get_file_list_by_mask';
    mytskopDeleteDirectoriesFromList:
      op := 'delete_directories_from_list';
    mytskopDeleteFilesFromList:
      op := 'delete_files_from_list';
    mytskopToPassportChange:
      op := 'to_passport_change';
    mytskopToSnDocuments:
      op := 'to_sn_documents';
    mytskopToEstimates:
      op := 'to_estimates';
    mytskopToThnDocuments:
      op := 'to_thn_documents';
    mytskopToKnsDocuments:
      op := 'to_kns_documents';
    mytskopLinkMontage:
      op := 'to_link_montage';
//    mytskSmetaReport: op:='';
  end;
  b := False;
  for i := 0 to High(Fields) do begin
    if Fields[i][0] = 'user-name' then
      b := True;
    if Module.InTestmode and (Fields[i][0] = 'to') then
      Fields[i][1] := DEVELOPER_MAIL;
    if not Sys.SaveTextToFile(TaskDir + '\__' + Fields[i][0], Fields[i][1]) then
      Exit;
  end;
  //если параметр 'user-name' не передан, то добавим св него имя текущего пользователя (оно будет в подписи письма)
  if not b then
    if not Sys.SaveTextToFile(TaskDir + '\__user-name', User.GetName) then
      Exit;
  if ForTesting then
    if not Sys.SaveTextToFile(TaskDir + '\__for-testing', '') then
      Exit;
  if not Sys.SaveTextToFile(TaskDir + '\__operation', op) then
    Exit;
  if AutoRun then
    if not FinalizeTaskDir(TaskDir) then
      Exit;
  Result := ExtractFileName(TaskDir);
end;

function TTasks.IsTaskComplete(const TaskDir: string): Boolean;
//проверяет, что зхадача обработалась сервером
begin
  Result := False;
  try
    Result := DirectoryExists(Module.GetPath_Tasks + '\OLD_' + TaskDir);
  except
  end;
end;


function TTasks.SendMail(const ASendTo: Variant; const ASubject, ABody: string; const AFiles: TVarDynArray; const AFromUser: string = ''; const AAsHTML: Boolean = True): Boolean;
//оправляем почту с прикрепленными файлами
//адресат - код рассылки или перечисление адресов через запятую
//тело, в случае html, без тега <body>
//отправитель, если путой, то текущий пользователь, если '~' то Учет, если строка то как передан, в режиме /test всегда отправка разработчику
var
  i: Integer;
  LTaskDef: TVarDynArray2;
  LTaskDir, LSendTo, LFileToSend, LFromUser: string;
begin
  Result := False;
  //если передано число, то берем пользователей с этим кодом рассылки, иначе перечисленныхuser
  //в тестовом режиме /test всегда отправка разработчику
  if Module.InTestmode then
    LSendTo := DEVELOPER_MAIL
  else if S.VarType(ASendTo) = varInteger then
    LSendTo := GetMailingAddr(ASendTo.AsInteger)
  else
    LSendTo := ASendTo.AsString;
  //выйдем, если некому отправлять
  if LSendTo = '' then
    Exit;
  LFileToSend := '';
  for i := 0 to High(AFiles) do
    S.ConcatStP(LFileToSend, ExtractFileName(AFiles[i].AsString), #13#10);
  //поля задачи
  LTaskDef := [
    ['to', LSendTo],
    ['subject', ASubject],
    ['body', ABody + S.IIFStr(AAsHTML, '<br>')],
    ['files-to-send', LFileToSend]
  ];
  //если не прикреплять этого тега, уйдет от текущего пользователя
  if AFromUser <> '' then
    LTaskDef := LTaskDef + [['user-name', S.IIf(AFromUser = '~', TASK_DEFAULT_SENDER, AFromUser)]];
  //создадим папку задачи
  LTaskDir := CreateTaskRoot(S.IIf(AAsHTML, myTskOpMailHtml, myTskOpMail), LTaskDef, False, False);
  if LTaskDir = '' then
    Exit;
  //скопируем в каталог задачи файлы, которые были прикреплены в качестве вложений
  //при неудаче пропустим копирование
  for i := 0 to High(AFiles) do begin
    try
      CopyFile(pWideChar(AFiles[i].AsString), pWideChar(Module.GetPath_Tasks + '\' + LTaskDir + '\Files\' + ExtractFileName(AFiles[i].AsString)), True);
    except
    end;
  end;
  //отправим задачу на выполнение
  Result := Tasks.FinalizeTaskDir(Module.GetPath_Tasks + '\' + LTaskDir);
end;

procedure TTasks.SyncServerTaskMailings;
//выгружает в adm_mailing эталонный список рассылок серверных заданий (id -
//константа TASK_MAILING_* выше, название - как у соответствующего задания в
//InitScheduledTasks (uServerTasks.pas), позиция - порядок в интерфейсе
//рассылок) - см. заголовок SyncServerTaskMailings в интерфейсе. каждая
//строка обрабатывается независимо (не единой транзакцией) - ошибка на одном
//коде не мешает обработать остальные
var
  cList: TVarDynArray2;
  i: Integer;
  Row: Variant;
begin
  cList := [
    [TASK_MAILING_ORDERS, 'Создание и изменение заказа', 100],
    [TASK_MAILING_ORDERS_APPROVE, 'Проведение заказа', 110],
    [TASK_MAILING_ORDERS_REJECT, 'Отклонение заказа', 120],

    [TASK_MAILING_ATTACH_ESTIMATE_SN, 'Прикрепление документов для снабжения', 200],
    [TASK_MAILING_NO_ESTIMATE, 'Заказы без смет', 0],
    [TASK_MAILING_ATTACH_THN, 'Прикрепление документов технологов', 210],
//    [TASK_MAILING_ORDERS_FIN, '',],
//    [TASK_MAILING_MONITORING_SN, '',],
//    [TASK_MAILING_MONITORING_STOCKS, '',],

    [TASK_MAILING_SUPPLY_DEALS_HOURLY_MONITORING, 'Мониторинг цен по счетам снабжения', 500],
    [TASK_MAILING_SUPPLY_DEALS_YESTERDAY, 'Счета снабжения за вчерашний день', 510],
    [TASK_MAILING_SUPPLY_ONWAY_SURPLUS, 'Сырьё в пути без резерва', 520],

    [TASK_MAILING_ORDERS_FIN, 'Финансовые показатели заказов за вчерашний день/неделю/месяц', 1000],
{    [TASK_MAILING_PRODUCTION_ORDERS_YESTERDAY, 'Производственные заказы за вчерашний день', 1000],
    [TASK_MAILING_SHIPMENT_ORDERS_YESTERDAY, 'Отгрузочные заказы за вчерашний день', 1001],
    [TASK_MAILING_PRODUCTION_ORDERS_LAST_WEEK, 'Производственные заказы за прошедшую неделю', 1002],
    [TASK_MAILING_SHIPMENT_ORDERS_LAST_WEEK, 'Отгрузочные заказы за прошедшую неделю', 1003],
    [TASK_MAILING_PRODUCTION_ORDERS_LAST_MONTH, 'Производственные заказы за прошедший месяц', 1004],
    [TASK_MAILING_SHIPMENT_ORDERS_LAST_MONTH, 'Отгрузочные заказы за прошедший месяц', 1005],}
    [TASK_MAILING_PLANNED_SHIPMENTS, 'Заказы, запланированные к отгрузке (сегодня/завтра/послезавтра)', 1020],
    [TASK_MAILING_ORDERS_PLANNED_TO_START_TOMORROW, 'Производственные заказы к выдаче завтра', 1030],
    [TASK_MAILING_OVERDUE_PRODUCTION_ORDERS, 'Просроченные производственные заказы', 1040],
    [TASK_MAILING_OVERDUE_SHIPMENT_ORDERS, 'Просроченные отгрузочные заказы', 1050],
    [TASK_MAILING_OVERDUE_ORDERS_BY_PRODUCTION_START_DATE, 'Просроченные по дате начала производства заказы', 1060],

    [TASK_MAILING_ACTS_WRITEOFF_RECEIPT, 'Акты списания и оприходования за вчерашний день', 2000],
    [TASK_MAILING_EARLY_COMPLETION_ACTS, 'Преждевременно созданные АВР', 2010],
    [TASK_MAILING_NEGATIVE_QUANTITY_ON_STOCKS, 'Отрицательные остатки на складах', 2020],

    [TASK_MAILING_NEGATIVE_QUANTITY_ON_SGP, 'Отрицательные остатки на СГП', 3000],
    [TASK_MAILING_NEGATIVE_NEED_BY_SGP, 'Отрицательная потребность по текущему состоянию СГП', 3010],
    [TASK_MAILING_RAW_MATERIALS_ON_SGP, 'Материалы на складах СГП, являющиеся сырьём', 3020],

    [TASK_MAILING_CREATED_SUPPLIER_DEMAND, 'Создание заявки на снабжение', 4000],
    [TASK_MAILING_REQUIRED_MATERIALS_TOMORROW, 'Потребность в материалах на завтра', 4010],
    [TASK_MAILING_SUPPLIERS_NEGATIVE_DEMAND, 'Потребность в материалах', 4020],
    [TASK_MAILING_MATERIAL_OPEN_REQUIREMENTS, 'Материалы, по которым не закрыта потребность', 4030],

    [TASK_MAILING_ESTIMATES_OVERDUE, 'Просроченные сметы', 9000],
    [TASK_MAILING_TECHNOLOGISTS_LOAD_OVERDUE, 'Просроченные загрузки технологов', 9001]
  ];
  for i := 0 to High(cList) do begin
    if Q.QLoadValue('select count(*) from adm_mailing where id = :id$i', [cList[i][0]]) = 0 then
      Q.QSave('i', 'adm_mailing', '-', 'id$i;comm$s;pos$i', [cList[i][0], cList[i][1], cList[i][2]])
    else begin
      Row := Q.QLoadRow('select comm, pos from adm_mailing where id = :id$i', [cList[i][0]]);
      if (S.NSt(Row[0]) <> cList[i][1]) or (S.NInt(Row[1]) <> cList[i][2]) then
        Q.QSave('u', 'adm_mailing', '-', 'id$i;comm$s;pos$i', [cList[i][0], cList[i][1], cList[i][2]]);
    end;
  end;
end;

end.
