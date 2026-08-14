{
SqlUpdater - обработка sql-скриптов проекта (каталог SQL).

Грид со списком файлов d_*.sql (путь задан константой cSqlFolder), с галочкой отметки
файлов для обработки. При открытии формы и по кнопке "Обновить" все файлы списка
предварительно разбираются (ScanFileMarkers) - заполняются колонки "Изменения" (есть ли в
файле --!!!), "Скрипты" (есть ли взведенные --!go begin/--!go end) и "Создание/удаление" (есть
ли взведенные --!+/--!-); по клику на галку в этих колонках (cellbutton) показывается
подробный отчет.

Теги действия (--!+/--!- на столбцах/объектах, блоки --!go begin/end) - трехсостоятельные:
взведен ("!", подлежит выполнению) -> обработан ("$", уже выполнен - ставится автоматически) ->
финал (--$dropped / --$completed begin, ставится вручную через "Удалить триггеры", после чего
строку/блок можно удалить из файла). "Восстановить триггеры действий" переводит обработанные
("$") теги обратно во взведенные - удобно, чтобы прогнать файлы повторно, например на тестовой
копии базы, перед финальным прогоном на боевой.

Кнопки тулбара (Frg1.Opt.SetButtons):
  - Открыть файл / целлбаттон на колонке "Файл" - просмотр текста файла (uFrmXWViewFile);
  - Установка комментариев - для отмеченных файлов синхронизирует комментарии к таблицам/
    столбцам с бд;
  - Полная обработка - для отмеченных файлов: комментарии + теги --!+/--!- (добавление/
    удаление столбцов и объектов) + блоки --!go begin/--!go end, затем (если включена галочка
    "Выполнить GO.sql") - GO.sql (тем же движком - комментарии/теги/go-блоки, а не как единый
    скрипт), и в конце - пересборка схемы. Перед стартом показывается сводка (сколько
    объектов/столбцов добавится/удалится, сколько go-блоков выполнится);
  - Обновить - перечитывает список файлов и переразбирает признаки в колонках;
  - Снять --!!! / Снять го-блоки - для отмеченных файлов убирает соответствующие маркеры
    из текста (--!!! удаляется совсем, --!go begin отключается добавлением дефиса);
  - Дополнительно - выпадающее меню: Действия после импорта (выполняет _after_import.sql),
    Восстановить триггеры действий, Удалить триггеры;
  - Просмотр логов - выбор и открытие файла лога из папки SQL\updater.logs.

Вся содержательная логика (разбор, поиск объектов, выполнение) - в uSqlUpdaterCore, эта форма
только показывает список файлов и вызывает функции этого юнита.
}

unit uFrmXAdmSqlUpdater;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, IOUtils,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh,
  uSqlUpdaterCore, uFrmXWViewFile
  ;

const
  cSqlFolder = 'R:\Projects\Uchet\SQL';
  cLogFolder = 'R:\Projects\Uchet\SQL\updater.logs';
  cGoSqlFile = 'R:\Projects\Uchet\SQL\GO.sql';
  cAfterImportFile = 'R:\Projects\Uchet\SQL\_after_import.sql';

type
  TFrmXAdmSqlUpdater = class(TFrmBasicGrid2)
    OpenLogDialog: TOpenDialog;
  private
    function  PrepareForm: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
    procedure LoadFileList;
    function  GetAllGridFiles: TStringDynArray;
    function  GetCheckedFiles: TStringDynArray;
    procedure ShowResultLog(ALog: TStrings);
    procedure ViewSelectedFile;
    procedure ViewFileByRow(No: Integer);
    procedure RunCommentsOnly;
    procedure RunFullProcess;
    procedure RunAfterImport;
    procedure ViewLogsList;
    procedure RunClearAttention;
    procedure RunDisableGoBlocks;
    procedure RunRestoreTriggers;
    procedure RunRemoveTriggers;
  public
  end;

var
  FrmXAdmSqlUpdater: TFrmXAdmSqlUpdater;

implementation

{$R *.dfm}

uses
  uDB;

function TFrmXAdmSqlUpdater.PrepareForm: Boolean;
begin
  Caption := 'SqlUpdater - обработка SQL-скриптов';
  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['num$i','№','40'],
    ['checked$i','Обраб.','60','chb','e',True],
    ['filename$s','Файл','230','bt=Просмотр'],
    ['dt$d','Изменён','110'],
    ['haschanges$i','Изменения','90','chb','bt=Показать'],
    ['hasscripts$i','Скрипты','90','chb','bt=Показать'],
    ['hastags$i','Создание/удаление','120','chb','bt=Показать']
  ]);
  Frg1.SetInitData([], '');
  Frg1.Opt.SetButtons(1, [
    [mbtCustom_SqlUpd_Refresh, True, 'Обновить', 'refresh'],[],
    [-mbtCustom_SqlUpd_ViewFile, True, 'Открыть файл'],
    [mbtCustom_SqlUpd_FullProcess, True, 120, 'Полная обработка'],
    [mbtCustom_SqlUpd_Comments, True, 140, 'Установка комментариев'],[],
    [mbtCustom_SqlUpd_ClearAttention, True, 80, 'Снять --!!!', ''],
    [mbtCustom_SqlUpd_DisableGoBlocks, True, 90, 'Снять го-блоки', ''],[],
    [-mbtCustom_SqlUpd_ViewLogs, True, 'Просмотр логов'],[],
    [mbtDividorM],
    [mbtCustom_SqlUpd_More, True, 115, 'Дополнительно', 'ok'],
    [mbtCustom_SqlUpd_AfterImport, True, 'Действия после импорта'],
    [mbtCustom_SqlUpd_RestoreTriggers, True, 'Восстановить триггеры действий'],
    [mbtCustom_SqlUpd_RemoveTriggers, True, 'Удалить триггеры'],
    [mbtDividorM],[],
    [mbtGridSettings],[],[mbtCtlPanel]
  ]);
  Frg1.CreateAddControls('1', cntCheck, 'Выполнить GO.sql', 'ChbRunGoSql', '', -1, yrefC, 160);
  Frg1.OnCellButtonClick := Frg1CellButtonClick;
  Frg1.InfoArray := [[
    'SqlUpdater - обработка sql-скриптов проекта (каталог SQL, файлы по маске d_*.sql).'#13#10 +
    'Отметьте галочкой файлы для обработки, при необходимости откройте их (кнопка "Открыть файл"'#13#10 +
    'либо целлбаттон на колонке "Файл") и проверьте/подготовьте нужные конструкции в тексте -'#13#10 +
    'см. "Синтаксис sql-файлов" ниже.'#13#10 +
    #13#10 +

    'КНОПКИ'#13#10 +
    'Обновить - перечитывает список файлов и заново разбирает признаки в колонках'#13#10 +
    '  "Изменения"/"Скрипты"/"Создание-удаление".'#13#10 +
    'Открыть файл - просмотр/редактирование текста файла (то же самое, что целлбаттон на колонке'#13#10 +
    '  "Файл").'#13#10 +
    'Полная обработка - для отмеченных файлов по порядку: комментарии к таблицам/столбцам,'#13#10 +
    '  теги --!+/--!- (добавление/удаление столбцов и объектов), блоки --!go begin/--!go end;'#13#10 +
    '  затем, если включена галочка "Выполнить GO.sql" - тем же порядком обрабатывается GO.sql;'#13#10 +
    '  в конце - пересборка схемы (compile_schema). Перед стартом показывается сводка (сколько'#13#10 +
    '  объектов/столбцов добавится/удалится, сколько go-блоков выполнится) с запросом подтверждения.'#13#10 +
    '  При первой же ошибке выполнения (не при установке комментариев - те только пишутся в лог)'#13#10 +
    '  показывается окно с вопросом "Продолжить?".'#13#10 +
    'Установка комментариев - только синхронизация комментариев к таблицам/столбцам с БД, без'#13#10 +
    '  тегов и go-блоков.'#13#10 +
    'Снять --!!! - убирает из отмеченных файлов все строки-метки внимания --!!! (см. ниже).'#13#10 +
    'Снять го-блоки - отключает (не выполняя) взведенные блоки --!go begin/--!go end в отмеченных'#13#10 +
    '  файлах, добавлением дефиса (--!go begin -> ---!go begin).'#13#10 +
    'Просмотр логов - выбор и открытие ранее сохраненного файла лога из SQL\updater.logs.'#13#10 +
    'Дополнительно:'#13#10 +
    '  Действия после импорта - выполняет целиком файл _after_import.sql (независимо от отметок'#13#10 +
    '    в гриде).'#13#10 +
    '  Восстановить триггеры действий - в отмеченных файлах переводит уже обработанные ("$")'#13#10 +
    '    теги/блоки обратно во взведенные ("!"), чтобы прогнать их еще раз - например, повторно'#13#10 +
    '    на боевой базе после отладки на тестовой копии.'#13#10 +
    '  Удалить триггеры - в отмеченных файлах переводит обработанные ("$") теги/блоки в финальное,'#13#10 +
    '    необратимое состояние (--$dropped / --$completed begin) - после этого их можно (вручную,'#13#10 +
    '    ориентируясь на F5 в просмотрщике) убрать из текста файла.'#13#10 +
    #13#10 +

    'СИНТАКСИС SQL-ФАЙЛОВ'#13#10 +
    'Три и более дефиса вместо двух в начале любой из описанных ниже конструкций (например'#13#10 +
    '---!+, ---!go begin, ---таблица) полностью отключает ее - парсер такую строку/блок'#13#10 +
    'игнорирует. Стандартный способ временно "выключить" что угодно из нижеперечисленного, не'#13#10 +
    'удаляя из текста.'#13#10 +
    #13#10 +
    'Комментарий к столбцу: -- сразу после определения столбца в create table - устанавливается'#13#10 +
    'в БД через comment on column (отсутствует/пустой, но есть в БД - будет удален).'#13#10 +
    #13#10 +
    'Комментарий к таблице: блок построчных -- комментариев над create table table_name вида'#13#10 +
    '  --таблица table_name'#13#10 +
    '  --текст комментария (может быть несколько строк)'#13#10 +
    '  --'#13#10 +
    'устанавливает comment on table (без учета первой строки-заголовка).'#13#10 +
    #13#10 +
    'Теги --!+ / --!- - на строке столбца или на строке заголовка (пере)создания объекта'#13#10 +
    '(create table/view/function/procedure/trigger/sequence/index, alter table add constraint):'#13#10 +
    '  --!+  добавить столбец/(пере)создать объект, если его еще нет в БД;'#13#10 +
    '  --!-  удалить столбец/объект, если он есть в БД.'#13#10 +
    'Три состояния тега: взведен ("!", ожидает выполнения) -> обработан ("$", проставляется'#13#10 +
    'автоматически сразу после успешного выполнения - "!" меняется на "$" на той же строке,'#13#10 +
    'повторно уже не выполняется) -> финал (--$dropped, ставится вручную кнопкой "Удалить'#13#10 +
    'триггеры" - после этого строку можно удалить из файла). Кнопка "Восстановить триггеры'#13#10 +
    'действий" переводит "$" обратно в "!" для повторного прогона.'#13#10 +
    #13#10 +
    'Блок --!go begin ... --!go end - произвольные ddl/dml операторы (через ; для обычных'#13#10 +
    'команд, через одиночную / в своей строке - для plsql-объектов: procedure/function/'#13#10 +
    'trigger/declare/begin), выполняются по порядку. Строки, целиком являющиеся -- комментарием'#13#10 +
    '(например, закомментированное "лишнее" действие), пропускаются и не выполняются - это'#13#10 +
    'удобно, чтобы держать в блоке "запасной" вариант команды, не выполняя его сейчас. После'#13#10 +
    'успешного выполнения блок целиком помечается обработанным: --!go begin/end -> --$go'#13#10 +
    'begin/end (строка --!go end/--$go end сама по себе никогда не меняется командой "Удалить'#13#10 +
    'триггеры" - трогается только begin).'#13#10 +
    #13#10 +
    '!rebuild object_name / !drop object_name - как отдельные "операторы" внутри GO.sql или'#13#10 +
    'блока --!go begin/end: ищут по всем файлам грида момент определения view/function/'#13#10 +
    'procedure/trigger/sequence/index/constraint (или таблицы) с этим именем и пересоздают'#13#10 +
    '(!rebuild) либо удаляют (!drop, для таблицы - cascade constraints).'#13#10 +
    #13#10 +
    'GO.sql (каталог SQL) - отдельный файл, не входит в список файлов грида, включается'#13#10 +
    'галочкой "Выполнить GO.sql". Обрабатывается тем же движком, что и обычные файлы -'#13#10 +
    'комментарии/теги/go-блоки, - после отмеченных файлов (если такие есть).'#13#10 +
    #13#10 +
    '--!!! - метка внимания на отдельной строке, для собственных пометок разработчика (не'#13#10 +
    'исполняется). Кнопка "Снять --!!!" убирает такие строки целиком.'#13#10 +
    #13#10 +

    'ПРОСМОТРЩИК/РЕДАКТОР ФАЙЛА'#13#10 +
    'F3 - следующая (по кругу) взведенная метка: --!!!, --!-, --!+, --!go begin.'#13#10 +
    'F4 - следующая обработанная метка: --$-, --$+, --$go begin.'#13#10 +
    'F5 - следующая финальная метка: --$dropped, --$completed begin.'#13#10 +
    'Ctrl+F - поиск текста (без учета регистра, вперед от каретки, по кругу).'#13#10 +
    'Галочка "Разрешить редактирование" + кнопка "Сохранить" - правка файла прямо в'#13#10 +
    'просмотрщике.'
  ]];
  Result := inherited;
  LoadFileList;
end;

procedure TFrmXAdmSqlUpdater.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if Tag = mbtCustom_SqlUpd_ViewFile then
    ViewSelectedFile
  else if Tag = mbtCustom_SqlUpd_Refresh then
    LoadFileList
  else if Tag = mbtCustom_SqlUpd_FullProcess then
    RunFullProcess
  else if Tag = mbtCustom_SqlUpd_Comments then
    RunCommentsOnly
  else if Tag = mbtCustom_SqlUpd_ClearAttention then
    RunClearAttention
  else if Tag = mbtCustom_SqlUpd_DisableGoBlocks then
    RunDisableGoBlocks
  else if Tag = mbtCustom_SqlUpd_AfterImport then
    RunAfterImport
  else if Tag = mbtCustom_SqlUpd_RestoreTriggers then
    RunRestoreTriggers
  else if Tag = mbtCustom_SqlUpd_RemoveTriggers then
    RunRemoveTriggers
  else if Tag = mbtCustom_SqlUpd_ViewLogs then
    ViewLogsList
  else
    inherited;
end;

procedure TFrmXAdmSqlUpdater.Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
var
  FileName, Report: string;
  Text, ErrMsg: string;
begin
  if Fr.CurrField = 'filename' then begin
    ViewFileByRow(No);
    Exit;
  end;

  if (Fr.CurrField <> 'haschanges') and (Fr.CurrField <> 'hasscripts') and (Fr.CurrField <> 'hastags') then
    Exit;

  FileName := IncludeTrailingPathDelimiter(cSqlFolder) + VarToStr(Fr.GetValue('filename', No));
  Text := LoadSqlFileText(FileName, ErrMsg);
  if ErrMsg <> '' then begin
    MyWarningMessage(ErrMsg);
    Exit;
  end;
  Text := StripBlockComments(Text);

  Report := '';
  if Fr.CurrField = 'haschanges' then
    Report := BuildAttentionReport(Text)
  else if Fr.CurrField = 'hasscripts' then
    Report := BuildGoBlocksReport(Text)
  else if Fr.CurrField = 'hastags' then begin
    var Tables: TSqlTableInfoArray;
    var ParseErr: string;
    if not ParseFileTables(FileName, Tables, ParseErr) then
      Tables := nil;
    Report := BuildTagsReport(Tables, ScanFileObjectTags(Text, FileName));
  end;

  if Trim(Report) = '' then
    MyInfoMessage('Ничего не найдено (возможно, признак уже не актуален - нажмите "Обновить").', [])
  else
    MyInfoMessage(ExtractFileName(FileName) + ':'#13#10#13#10 + Report, [], 1);
end;

procedure TFrmXAdmSqlUpdater.LoadFileList;
//заполняем грид файлами по маске d_*.sql из cSqlFolder и сразу разбираем признаки по каждому
var
  SearchRec: TSearchRec;
  i: Integer;
  FullName: string;
  HasAttn, HasGo, HasTags: Boolean;
  ErrMsg: string;
begin
  Frg1.MemTableEh1.EmptyTable;
  i := 0;
  Cth.SetWaitCursor(True);
  try
    if FindFirst(IncludeTrailingPathDelimiter(cSqlFolder) + 'd_*.sql', faAnyFile, SearchRec) = 0 then begin
      try
        repeat
          if (SearchRec.Attr and faDirectory) = 0 then begin
            Inc(i);
            FullName := IncludeTrailingPathDelimiter(cSqlFolder) + SearchRec.Name;
            ScanFileMarkers(FullName, HasAttn, HasGo, HasTags, ErrMsg);
            Frg1.MemTableEh1.Append;
            Frg1.MemTableEh1.FieldByName('id').Value := i;
            Frg1.MemTableEh1.FieldByName('num').Value := i;
            Frg1.MemTableEh1.FieldByName('checked').Value := 0;
            Frg1.MemTableEh1.FieldByName('filename').Value := SearchRec.Name;
            Frg1.MemTableEh1.FieldByName('dt').Value := FileDateToDateTime(SearchRec.Time);
            Frg1.MemTableEh1.FieldByName('haschanges').Value := S.IIf(HasAttn, 1, 0);
            Frg1.MemTableEh1.FieldByName('hasscripts').Value := S.IIf(HasGo, 1, 0);
            Frg1.MemTableEh1.FieldByName('hastags').Value := S.IIf(HasTags, 1, 0);
            Frg1.MemTableEh1.Post;
          end;
        until FindNext(SearchRec) <> 0;
      finally
        FindClose(SearchRec);
      end;
    end;
  finally
    Cth.SetWaitCursor(False);
  end;
end;

function TFrmXAdmSqlUpdater.GetAllGridFiles: TStringDynArray;
//полные пути ко всем файлам, попавшим в грид (используется для поиска объектов !rebuild/!drop)
var
  Res: TStringDynArray;
begin
  SetLength(Res, 0);
  Frg1.MemTableEh1.DisableControls;
  try
    Frg1.MemTableEh1.First;
    while not Frg1.MemTableEh1.Eof do begin
      SetLength(Res, Length(Res) + 1);
      Res[High(Res)] := IncludeTrailingPathDelimiter(cSqlFolder) + VarToStr(Frg1.MemTableEh1.FieldByName('filename').Value);
      Frg1.MemTableEh1.Next;
    end;
  finally
    Frg1.MemTableEh1.EnableControls;
  end;
  Result := Res;
end;

function TFrmXAdmSqlUpdater.GetCheckedFiles: TStringDynArray;
//полные пути к отмеченным галкой файлам
var
  Res: TStringDynArray;
begin
  SetLength(Res, 0);
  Frg1.MemTableEh1.DisableControls;
  try
    Frg1.MemTableEh1.First;
    while not Frg1.MemTableEh1.Eof do begin
      if VarToStr(Frg1.MemTableEh1.FieldByName('checked').Value) = '1' then begin
        SetLength(Res, Length(Res) + 1);
        Res[High(Res)] := IncludeTrailingPathDelimiter(cSqlFolder) + VarToStr(Frg1.MemTableEh1.FieldByName('filename').Value);
      end;
      Frg1.MemTableEh1.Next;
    end;
  finally
    Frg1.MemTableEh1.EnableControls;
  end;
  Result := Res;
end;

procedure TFrmXAdmSqlUpdater.ShowResultLog(ALog: TStrings);
//пишет лог в файл, показывает его целиком, и отдельно - если были ошибки - показывает
//предупреждение и лог именно ошибок
var
  ErrLog: TStringList;
  i: Integer;
begin
  WriteLogFile(cLogFolder, ALog);
  MyInfoMessage(ALog.Text, [], 1);
  ErrLog := TStringList.Create;
  try
    for i := 0 to ALog.Count - 1 do
      if Pos('ОШИБКА', ALog[i]) > 0 then
        ErrLog.Add(ALog[i]);
    if ErrLog.Count > 0 then begin
      MyWarningMessage('В ходе обработки зафиксированы ошибки (' + IntToStr(ErrLog.Count) + '). Ниже - только они:');
      MyInfoMessage(ErrLog.Text, [], 1);
    end;
  finally
    ErrLog.Free;
  end;
  LoadFileList; //признаки в колонках могли измениться
end;

procedure TFrmXAdmSqlUpdater.ViewSelectedFile;
var
  FileName: string;
begin
  if Frg1.MemTableEh1.IsEmpty then
    Exit;
  FileName := IncludeTrailingPathDelimiter(cSqlFolder) + VarToStr(Frg1.MemTableEh1.FieldByName('filename').Value);
  TFrmXWViewFile.Show(Self, myfrm_Adm_SqlUpd_ViewFile, [myfoSizeable, myfoMulticopy, myfoEnableMaximize], fNone, 0, FileName);
end;

procedure TFrmXAdmSqlUpdater.ViewFileByRow(No: Integer);
var
  FileName: string;
begin
  FileName := IncludeTrailingPathDelimiter(cSqlFolder) + VarToStr(Frg1.GetValue('filename', No));
  TFrmXWViewFile.Show(Self, myfrm_Adm_SqlUpd_ViewFile, [myfoSizeable, myfoMulticopy, myfoEnableMaximize], fNone, 0, FileName);
end;

procedure TFrmXAdmSqlUpdater.RunCommentsOnly;
var
  Files: TStringDynArray;
  i, TotalChanged: Integer;
  Tables: TSqlTableInfoArray;
  ErrMsg: string;
  Log: TStringList;
begin
  Files := GetCheckedFiles;
  if Length(Files) = 0 then begin
    MyWarningMessage('Не отмечено ни одного файла.');
    Exit;
  end;
  Log := TStringList.Create;
  try
    Log.Add('SqlUpdater - установка комментариев, ' + DateTimeToStr(Now));
    Log.Add('');
    TotalChanged := 0;
    Cth.SetWaitCursor(True);
    try
      for i := 0 to High(Files) do begin
        Log.Add('--- ' + ExtractFileName(Files[i]) + ' ---');
        if not ParseFileTables(Files[i], Tables, ErrMsg) then begin
          Log.Add('ОШИБКА разбора файла: ' + ErrMsg);
          Continue;
        end;
        TotalChanged := TotalChanged + SyncTableComments(Tables, Log);
      end;
    finally
      Cth.SetWaitCursor(False);
    end;
    Log.Add('');
    Log.Add('Изменено комментариев: ' + IntToStr(TotalChanged));
    ShowResultLog(Log);
  finally
    Log.Free;
  end;
end;

procedure TFrmXAdmSqlUpdater.RunFullProcess;
var
  Files, AllFiles: TStringDynArray;
  i, TotalComments, TotalStmts, TotalTags: Integer;
  ObjAdd, ColAdd, ObjDel, ColDel, GoBlocksCnt: Integer;
  Tables: TSqlTableInfoArray;
  ErrMsg: string;
  Log: TStringList;
  Aborted, RunGoSql: Boolean;
begin
  Files := GetCheckedFiles;
  if Length(Files) = 0 then begin
    MyWarningMessage('Не отмечено ни одного файла.');
    Exit;
  end;
  RunGoSql := Frg1.GetControlValue('ChbRunGoSql') = 1;

  CountPendingTags(Files, ObjAdd, ColAdd, ObjDel, ColDel, GoBlocksCnt);
  if MyQuestionMessage('Сводка перед обработкой ' + IntToStr(Length(Files)) + ' отмеченных файлов:'#13#10 +
    'объектов будет добавлено/пересоздано: ' + IntToStr(ObjAdd) + #13#10 +
    'столбцов будет добавлено: ' + IntToStr(ColAdd) + #13#10 +
    'объектов будет удалено: ' + IntToStr(ObjDel) + #13#10 +
    'столбцов будет удалено: ' + IntToStr(ColDel) + #13#10 +
    'go-блоков выполнится: ' + IntToStr(GoBlocksCnt) +
    S.IIf(RunGoSql, #13#10 + '+ GO.sql', '') + #13#10#13#10'Продолжить?') <> mrYes then
    Exit;

  AllFiles := GetAllGridFiles;
  //GO.sql может определять свои объекты (тегами --!+) - должен быть виден в поиске определений,
  //даже если сам не входит в основной список файлов грида (маска d_*.sql)
  if TFile.Exists(cGoSqlFile) then begin
    SetLength(AllFiles, Length(AllFiles) + 1);
    AllFiles[High(AllFiles)] := cGoSqlFile;
  end;

  Log := TStringList.Create;
  try
    Log.Add('SqlUpdater - полная обработка, ' + DateTimeToStr(Now));
    Log.Add('');
    TotalComments := 0;
    TotalStmts := 0;
    TotalTags := 0;
    Aborted := False;
    Cth.SetWaitCursor(True);
    try
      for i := 0 to High(Files) do begin
        if Aborted then
          Break;
        Log.Add('=== ' + ExtractFileName(Files[i]) + ' ===');

        if not ParseFileTables(Files[i], Tables, ErrMsg) then
          Log.Add('ОШИБКА разбора файла (комментарии): ' + ErrMsg)
        else
          TotalComments := TotalComments + SyncTableComments(Tables, Log);

        TotalTags := TotalTags + ProcessFileTags(Files[i], AllFiles, Log, Aborted);

        if not Aborted then
          TotalStmts := TotalStmts + ProcessFileGoBlocks(Files[i], AllFiles, Log, Aborted);
      end;

      if (not Aborted) and RunGoSql then begin
        if TFile.Exists(cGoSqlFile) then begin
          Log.Add('=== GO.sql ===');
          //GO.sql обрабатывается тем же движком, что и обычные файлы - та же структура
          //(комментарии/теги --!+/--!- /блоки --!go begin/end), просто отдельным шагом
          if not ParseFileTables(cGoSqlFile, Tables, ErrMsg) then
            Log.Add('ОШИБКА разбора GO.sql (комментарии): ' + ErrMsg)
          else
            TotalComments := TotalComments + SyncTableComments(Tables, Log);
          TotalTags := TotalTags + ProcessFileTags(cGoSqlFile, AllFiles, Log, Aborted);
          if not Aborted then
            TotalStmts := TotalStmts + ProcessFileGoBlocks(cGoSqlFile, AllFiles, Log, Aborted);
        end
        else
          Log.Add('GO.sql не найден, пропущено: ' + cGoSqlFile);
      end;

      if not Aborted then begin
        Log.Add('=== пересборка схемы ===');
        if ExecRawSql('begin sys.dbms_utility.compile_schema(schema => user); end;', ErrMsg) then
          Log.Add('OK: compile_schema')
        else
          Log.Add('ОШИБКА compile_schema: ' + ErrMsg);
      end;
    finally
      Cth.SetWaitCursor(False);
    end;

    Log.Add('');
    Log.Add('Изменено комментариев: ' + IntToStr(TotalComments) + ', выполнено тегов --!+/--!-: ' + IntToStr(TotalTags) +
      ', выполнено операторов: ' + IntToStr(TotalStmts) + S.IIf(Aborted, ' (прервано пользователем)', ''));
    if TotalTags > 0 then
      Log.Add('успешно выполненные теги --!+/--!- автоматически помечены обработанными (--$+/--$-) в тексте файлов.');

    ShowResultLog(Log);
  finally
    Log.Free;
  end;
end;

procedure TFrmXAdmSqlUpdater.RunAfterImport;
var
  AllFiles: TStringDynArray;
  Log: TStringList;
  Aborted: Boolean;
  Cnt: Integer;
begin
  if not TFile.Exists(cAfterImportFile) then begin
    MyWarningMessage('Файл не найден: ' + cAfterImportFile);
    Exit;
  end;
  if MyQuestionMessage('Выполнить действия после импорта из файла "_after_import.sql"?') <> mrYes then
    Exit;

  AllFiles := GetAllGridFiles;
  Log := TStringList.Create;
  try
    Log.Add('SqlUpdater - действия после импорта, ' + DateTimeToStr(Now));
    Log.Add('');
    Aborted := False;
    Cth.SetWaitCursor(True);
    try
      Cnt := ProcessSqlScriptFile(cAfterImportFile, AllFiles, Log, Aborted);
    finally
      Cth.SetWaitCursor(False);
    end;
    Log.Add('');
    Log.Add('Выполнено операторов: ' + IntToStr(Cnt) + S.IIf(Aborted, ' (прервано пользователем)', ''));
    ShowResultLog(Log);
  finally
    Log.Free;
  end;
end;

procedure TFrmXAdmSqlUpdater.RunClearAttention;
var
  Files: TStringDynArray;
  i, Removed, Total: Integer;
  ErrMsg: string;
  Log: TStringList;
begin
  Files := GetCheckedFiles;
  if Length(Files) = 0 then begin
    MyWarningMessage('Не отмечено ни одного файла.');
    Exit;
  end;
  if MyQuestionMessage('Убрать метки --!!! из ' + IntToStr(Length(Files)) + ' отмеченных файлов?') <> mrYes then
    Exit;
  Log := TStringList.Create;
  try
    Log.Add('SqlUpdater - снятие --!!!, ' + DateTimeToStr(Now));
    Log.Add('');
    Total := 0;
    Cth.SetWaitCursor(True);
    try
      for i := 0 to High(Files) do begin
        if RemoveAttentionMarkers(Files[i], Removed, ErrMsg) then begin
          if Removed > 0 then begin
            Log.Add(ExtractFileName(Files[i]) + ': убрано меток --!!! - ' + IntToStr(Removed));
            Total := Total + Removed;
          end;
        end
        else
          Log.Add('ОШИБКА в файле ' + ExtractFileName(Files[i]) + ': ' + ErrMsg);
      end;
    finally
      Cth.SetWaitCursor(False);
    end;
    Log.Add('');
    Log.Add('Всего убрано: ' + IntToStr(Total));
    ShowResultLog(Log);
  finally
    Log.Free;
  end;
end;

procedure TFrmXAdmSqlUpdater.RunDisableGoBlocks;
var
  Files: TStringDynArray;
  i, Disabled, Total: Integer;
  ErrMsg: string;
  Log: TStringList;
begin
  Files := GetCheckedFiles;
  if Length(Files) = 0 then begin
    MyWarningMessage('Не отмечено ни одного файла.');
    Exit;
  end;
  if MyQuestionMessage('Отключить взведенные блоки --!go begin...--!go end в ' + IntToStr(Length(Files)) + ' отмеченных файлах?') <> mrYes then
    Exit;
  Log := TStringList.Create;
  try
    Log.Add('SqlUpdater - отключение go-блоков, ' + DateTimeToStr(Now));
    Log.Add('');
    Total := 0;
    Cth.SetWaitCursor(True);
    try
      for i := 0 to High(Files) do begin
        if DisableGoBlocksInFile(Files[i], Disabled, ErrMsg) then begin
          if Disabled > 0 then begin
            Log.Add(ExtractFileName(Files[i]) + ': отключено блоков - ' + IntToStr(Disabled));
            Total := Total + Disabled;
          end;
        end
        else
          Log.Add('ОШИБКА в файле ' + ExtractFileName(Files[i]) + ': ' + ErrMsg);
      end;
    finally
      Cth.SetWaitCursor(False);
    end;
    Log.Add('');
    Log.Add('Всего отключено: ' + IntToStr(Total));
    ShowResultLog(Log);
  finally
    Log.Free;
  end;
end;

procedure TFrmXAdmSqlUpdater.RunRestoreTriggers;
//переводит обработанные ("$") теги обратно во взведенные ("!") в отмеченных файлах - --$+/--$-
//-> --!+/--!-, --$go begin/end -> --!go begin/end. позволяет прогнать полную обработку файлов
//еще раз (например, повторно на тестовой копии базы), не выполняя вручную заново то, что уже
//отработано в предыдущем прогоне. финальные метки (--$dropped, --$completed begin) не трогает.
var
  Files: TStringDynArray;
  i, Restored, Total: Integer;
  ErrMsg: string;
  Log: TStringList;
begin
  Files := GetCheckedFiles;
  if Length(Files) = 0 then begin
    MyWarningMessage('Не отмечено ни одного файла.');
    Exit;
  end;
  if MyQuestionMessage('Восстановить (перевести обратно во взведенное состояние) обработанные триггеры действий в ' +
    IntToStr(Length(Files)) + ' отмеченных файлах?') <> mrYes then
    Exit;
  Log := TStringList.Create;
  try
    Log.Add('SqlUpdater - восстановление триггеров действий, ' + DateTimeToStr(Now));
    Log.Add('');
    Total := 0;
    Cth.SetWaitCursor(True);
    try
      for i := 0 to High(Files) do begin
        if RestoreActionTriggers(Files[i], Restored, ErrMsg) then begin
          if Restored > 0 then begin
            Log.Add(ExtractFileName(Files[i]) + ': восстановлено триггеров - ' + IntToStr(Restored));
            Total := Total + Restored;
          end;
        end
        else
          Log.Add('ОШИБКА в файле ' + ExtractFileName(Files[i]) + ': ' + ErrMsg);
      end;
    finally
      Cth.SetWaitCursor(False);
    end;
    Log.Add('');
    Log.Add('Всего восстановлено: ' + IntToStr(Total));
    ShowResultLog(Log);
  finally
    Log.Free;
  end;
end;

procedure TFrmXAdmSqlUpdater.RunRemoveTriggers;
//переводит обработанные ("$") теги в финальное, необратимое состояние: --$+/--$- -> --$dropped,
//--$go begin -> --$completed begin. дальше упдатер эти метки не разбирает - пользователь
//находит их (F5 в просмотрщике) и удаляет из файла вручную.
var
  Files: TStringDynArray;
  i, Removed, Total: Integer;
  ErrMsg: string;
  Log: TStringList;
begin
  Files := GetCheckedFiles;
  if Length(Files) = 0 then begin
    MyWarningMessage('Не отмечено ни одного файла.');
    Exit;
  end;
  if MyQuestionMessage('Перевести обработанные триггеры действий в финальное состояние (--$dropped / --$completed begin) в ' +
    IntToStr(Length(Files)) + ' отмеченных файлах? Это необратимо - после этого строки/блоки с такими метками нужно будет ' +
    'удалить из файла вручную.') <> mrYes then
    Exit;
  Log := TStringList.Create;
  try
    Log.Add('SqlUpdater - удаление триггеров действий (перевод в финал), ' + DateTimeToStr(Now));
    Log.Add('');
    Total := 0;
    Cth.SetWaitCursor(True);
    try
      for i := 0 to High(Files) do begin
        if RemoveActionTriggers(Files[i], Removed, ErrMsg) then begin
          if Removed > 0 then begin
            Log.Add(ExtractFileName(Files[i]) + ': переведено в финал - ' + IntToStr(Removed));
            Total := Total + Removed;
          end;
        end
        else
          Log.Add('ОШИБКА в файле ' + ExtractFileName(Files[i]) + ': ' + ErrMsg);
      end;
    finally
      Cth.SetWaitCursor(False);
    end;
    Log.Add('');
    Log.Add('Всего переведено в финал: ' + IntToStr(Total));
    ShowResultLog(Log);
  finally
    Log.Free;
  end;
end;

procedure TFrmXAdmSqlUpdater.ViewLogsList;
begin
  if not DirectoryExists(cLogFolder) then begin
    MyWarningMessage('Папка логов не найдена: ' + cLogFolder);
    Exit;
  end;
  OpenLogDialog.InitialDir := cLogFolder;
  if OpenLogDialog.Execute then
    TFrmXWViewFile.Show(Self, myfrm_Adm_SqlUpd_ViewFile, [myfoSizeable, myfoMulticopy, myfoEnableMaximize], fNone, 0, OpenLogDialog.FileName);
end;

end.
