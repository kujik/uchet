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
  end;

var
  Tasks: TTasks;

const
  //константы идентификации почтовых рассылок
  TASK_MAILING_ORDERS = 1;
  TASK_MAILING_ATTACH_ESTIMATE_SN = 3;
  TASK_MAILING_NO_ESTIMATE = 4;
  TASK_MAILING_ATTACH_THN = 5;
  TASK_MAILING_ORDERS_FIN = 6;
  TASK_MAILING_MONITORING_SN = 7;
  TASK_MAILING_EARLY_COMPLETION_ACTS = 8;
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



end.
