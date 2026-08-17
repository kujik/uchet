{
Общая логика инструмента SqlUpdater.

Здесь собраны: разбор текста sql-скриптов (создание таблиц, комментарии к таблицам/
столбцам, блоки --!go begin/--!go end), последовательное выполнение операторов ддл/дмл,
поиск определений объектов бд по всем файлам (для директив !rebuild/!drop), и ведение
лога выполнения.

Все реальные операторы выполняются через ExecRawSql - отдельный TADOQuery с выключенным
ParamCheck, а не через Q.QExecSql/QExecSqlSimple: тела триггеров содержат :new/:old,
которые стандартный разбор параметров ADO (используемый в Q) ошибочно принимает за
именованные параметры запроса, и выполнение либо падает, либо тихо не происходит.

Теги действия (--!+/--!- на столбцах и объектах, блоки --!go begin/--!go end) имеют три
состояния:
  - взведён ("!") - подлежит выполнению при обработке;
  - обработан ("$") - уже успешно выполнен (--!+/--!- -> --$+/--$-, --!go begin/end ->
    --$go begin/end); переход "! -> $" происходит автоматически сразу после успешного
    выполнения, без обращения к бд для повторной проверки. Пункт меню "Восстановить
    триггеры действий" делает обратную замену ($ -> !) для выбранных файлов - это позволяет
    прогнать файлы повторно (например, на тестовой копии базы), не выполняя вручную заново
    то, что уже отработано;
  - финал - необратимо, ставится пунктом меню "Удалить триггеры": --$+/--$- (оба вида) ->
    --$dropped, --$go begin -> --$completed begin (--$go end и --!go end не трогаются -
    единственная метка, значимая для парной go-строки - begin). Финальные метки упдатером
    больше не обрабатываются - сами строки/блоки с ними пользователь удаляет вручную.
  Как и раньше, три и более дефиса перед "!"/"$" (например, ---!+, ---$go begin) - отключенная,
  игнорируемая конструкция.
}

unit uSqlUpdaterCore;

interface

uses
  UITypes, SysUtils, Classes, Variants, Types, IOUtils, RegularExpressions, ADODB, DB,
  uString, uDB, uDBOra, uMessages;

type
  TSqlColumnComment = record
    ColName: string;
    Comment: string;    //может быть пустым - тогда в бд комментарий (если есть) должен быть удален
    Tag: Char;           //'+' - добавить столбец (alter table add), '-' - удалить (alter table drop column), #0 - нет тега (только взведенный "!" тег)
    ColDef: string;      //полное определение столбца (без хвостовой запятой/комментария/тега) - для alter table add
    LinePos: Integer;    //позиция начала строки этого столбца в тексте файла - для пометки тега обработанным
  end;
  TSqlColumnCommentArray = array of TSqlColumnComment;

  TSqlTableInfo = record
    TableName: string;
    HasComment: Boolean;  //найден блок --таблица .../.../ ... непосредственно над create table
    Comment: string;      //текст комментария к таблице (если HasComment)
    Columns: TSqlColumnCommentArray;
  end;
  TSqlTableInfoArray = array of TSqlTableInfo;

  //результат поиска определения объекта бд для !rebuild/!drop
  TSqlObjectDef = record
    Found: Boolean;
    ObjType: string;     //'table','view','function','procedure','trigger','sequence','index','constraint'
    ObjectName: string;
    TableName: string;   //для constraint/index - таблица, к которой относится
    DefText: string;     //полный текст определения (для пересоздания)
    SourceFile: string;
  end;

  //тег --!+/--!- на строке заголовка (пере)создания объекта (create table/view/function/...)
  TSqlObjectTagInfo = record
    ObjType: string;
    ObjectName: string;
    TableName: string;  //для constraint/index
    Tag: Char;           //'+' или '-' (только взведенный "!" тег)
    SourceFile: string;
    LinePos: Integer;    //позиция начала строки заголовка в тексте файла - для пометки тега обработанным
  end;
  TSqlObjectTagInfoArray = array of TSqlObjectTagInfo;

  TSqlAttentionItem = record
    TagLineExtra: string;   //текст на строке с --!!! после самого тега, если там что-то есть кроме пробелов
    NextLineText: string;   //первая непустая строка под тегом
  end;
  TSqlAttentionItemArray = array of TSqlAttentionItem;

  //взведенный блок --!go begin ... --!go end
  TSqlGoBlock = record
    BeginLinePos: Integer;  //позиция начала строки --!go begin в тексте
    EndLinePos: Integer;    //позиция начала строки --!go end в тексте
    Content: string;        //текст между begin и end (из уже "очищенного" StripBlockComments текста)
  end;
  TSqlGoBlockArray = array of TSqlGoBlock;

//----------------------------- чтение и предобработка текста -----------------------------
function LoadSqlFileText(const AFileName: string; out ErrMsg: string): string;
function StripBlockComments(const Text: string): string;

//----------------------------- разбор create table + комментариев ------------------------
function ParseFileTables(const AFileName: string; out Tables: TSqlTableInfoArray; out ErrMsg: string): Boolean;
function FindMatchingParenEnd(const Text: string; StartPos: Integer): Integer;
function FindPrecedingTableComment(const Text: string; TableStartPos, LowerBoundPos: Integer; const TableName: string; out CommentText: string): Boolean;
function ExtractLineTag(var Line: string): Char;
function ExtractLineTagEx(var Line: string; AStateChar: Char): Char;

//----------------------------- --!go begin/--!go end и разбор операторов -----------------
//ExtractGoBlocksByState - общая реализация для взведенных (AStateChar = '!', см. ExtractGoBlocksEx)
//и уже обработанных (AStateChar = '$', см. BuildProcessedTagsReport) блоков --Xgo begin/--Xgo end
function ExtractGoBlocksByState(const Text: string; const AStateChar: Char): TSqlGoBlockArray;
function ExtractGoBlocksEx(const Text: string): TSqlGoBlockArray;
function ExtractGoBlocks(const Text: string): TStringDynArray;
function HasActiveGoBlocks(const Text: string): Boolean;
function BuildGoBlocksReport(const Text: string): string;
function SplitStatements(const Text: string): TStringDynArray;

//----------------------------- маркер --!!! (внимание) ------------------------------------
function FindAttentionMarkers(const Text: string): TSqlAttentionItemArray;
function HasAttentionMarkers(const Text: string): Boolean;
function BuildAttentionReport(const Text: string): string;

//----------------------------- теги --!+/--!- на объектах ---------------------------------
function ScanFileObjectTags(const Text, ASourceFile: string): TSqlObjectTagInfoArray;
function BuildTagsReport(const ATables: TSqlTableInfoArray; const AObjTags: TSqlObjectTagInfoArray): string;
function HasAnyTags(const ATables: TSqlTableInfoArray; const AObjTags: TSqlObjectTagInfoArray): Boolean;

//----------------------------- уже обработанные/финальные метки --$+/--$-/--$go/--$dropped/--$completed --
//в отличие от ScanFileObjectTags/ParseFileTables (--!+/--!-), здесь НЕ разбирается, к какому именно
//объекту/столбцу относится строка - только сам факт наличия метки и её текст (см. общую задачу
//пользователя - "нужно отображение наличия в файле тегов --$... и также просмотр строк/блоков с ними")
function FindProcessedMarkerLines(const Text: string): TStringDynArray;
function HasProcessedTags(const Text: string): Boolean;
function BuildProcessedTagsReport(const Text: string): string;

//----------------------------- сводный разбор файла для колонок грида ---------------------
function ScanFileMarkers(const AFileName: string; out AHasAttention, AHasGoBlocks, AHasTags, AHasProcessed: Boolean; out ErrMsg: string): Boolean;

//----------------------------- поиск определений объектов (!rebuild/!drop) ---------------
function FindObjectDefinition(const AFiles: TStringDynArray; const AObjectName: string; out ADef: TSqlObjectDef): Boolean;
function ExtractSqlStatementText(const Text: string; StartPos: Integer): string;
function ExtractPlsqlBody(const Text: string; StartPos: Integer): string;

//----------------------------- выполнение -------------------------------------------------
function ExecRawSql(const Sql: string; out ErrMsg: string): Boolean;
function RebuildObject(const ADef: TSqlObjectDef; out ErrMsg: string): Boolean;
function DropObjectByName(const AFiles: TStringDynArray; const AObjectName: string; out ErrMsg: string): Boolean;
function ExecuteStatements(const AStatements: TStringDynArray; const AAllFiles: TStringDynArray; ALog: TStrings; var AAborted: Boolean): Integer;

//----------------------------- комментарии -------------------------------------------------
function SyncTableComments(const Tables: TSqlTableInfoArray; ALog: TStrings): Integer;

//----------------------------- теги --!+/--!- на столбцах и объектах: выполнение ----------
function TableExistsInDb(const ATableName: string): Boolean;
function MarkLineTagProcessed(var AText: string; ALinePos: Integer; AKindChar: Char): Boolean;
procedure MarkGoBlockLineProcessed(var AText: string; ALinePos: Integer);
function ExecColumnAdd(const ATableName: string; const ACol: TSqlColumnComment; out ErrMsg: string): Boolean;
function ExecColumnDrop(const ATableName, AColName: string; out ErrMsg: string): Boolean;
function ExecObjectTag(const ATag: TSqlObjectTagInfo; const AAllFiles: TStringDynArray; out ErrMsg: string): Boolean;
procedure CountPendingTags(const AFiles: TStringDynArray; out AObjAdd, AColAdd, AObjDel, AColDel, AGoBlocks: Integer);
function ProcessFileTags(const AFileName: string; const AAllFiles: TStringDynArray; ALog: TStrings; var AAborted: Boolean): Integer;
function MarkObjectDroppedInFiles(const AFiles: TStringDynArray; const AObjectName: string): Boolean;

//----------------------------- очистка текста файлов после выполнения ---------------------
function SaveSqlFileText(const AFileName, AText: string; out ErrMsg: string): Boolean;
function RemoveAttentionMarkers(const AFileName: string; out ARemoved: Integer; out ErrMsg: string): Boolean;
function DisableGoBlocksInFile(const AFileName: string; out ADisabled: Integer; out ErrMsg: string): Boolean;
function RestoreActionTriggers(const AFileName: string; out ARestored: Integer; out ErrMsg: string): Boolean;
function RemoveActionTriggers(const AFileName: string; out ARemoved: Integer; out ErrMsg: string): Boolean;

//----------------------------- верхнеуровневая обработка файлов ---------------------------
function ProcessFileGoBlocks(const AFileName: string; const AAllFiles: TStringDynArray; ALog: TStrings; var AAborted: Boolean): Integer;
function ProcessSqlScriptFile(const AFileName: string; const AAllFiles: TStringDynArray; ALog: TStrings; var AAborted: Boolean): Integer;

//----------------------------- лог ----------------------------------------------------------
function WriteLogFile(const ALogFolder: string; const ALog: TStrings): string;
function EscapeSqlLiteral(const S: string): string;

implementation

const
  cIdentChars = ['a'..'z', 'A'..'Z', '0'..'9', '_', '$', '#'];

{------------------------------------------------------------------------------------------}

function LoadSqlFileText(const AFileName: string; out ErrMsg: string): string;
var
  Enc: TEncoding;
begin
  Result := '';
  ErrMsg := '';
  if not TFile.Exists(AFileName) then begin
    ErrMsg := 'файл не найден: ' + AFileName;
    Exit;
  end;
  try
    Enc := TEncoding.GetEncoding(1251);
    try
      Result := TFile.ReadAllText(AFileName, Enc);
    finally
      Enc.Free;
    end;
  except
    on E: Exception do
      ErrMsg := 'не удалось прочитать файл "' + AFileName + '": ' + E.Message;
  end;
end;

function StripBlockComments(const Text: string): string;
//заменяет содержимое /* ... */ на пробелы (кроме переводов строк) - блочные комментарии
//не должны попадать ни в разбор create table, ни в поиск --!go/!rebuild/!drop, ни в выполнение
var
  i: Integer;
  InComment: Boolean;
begin
  Result := Text;
  i := 1;
  InComment := False;
  while i <= Length(Result) do begin
    if not InComment then begin
      if (i < Length(Result)) and (Result[i] = '/') and (Result[i + 1] = '*') then begin
        InComment := True;
        Result[i] := ' ';
        Result[i + 1] := ' ';
        Inc(i, 2);
        Continue;
      end;
    end
    else begin
      if (i < Length(Result)) and (Result[i] = '*') and (Result[i + 1] = '/') then begin
        InComment := False;
        Result[i] := ' ';
        Result[i + 1] := ' ';
        Inc(i, 2);
        Continue;
      end
      else if Result[i] <> #10 then
        Result[i] := ' ';
    end;
    Inc(i);
  end;
end;

{------------------------------------------------------------------------------------------}

function FindMatchingParenEnd(const Text: string; StartPos: Integer): Integer;
//находит позицию закрывающей скобки, парной открывающей на позиции StartPos (сама она - '(');
//пропускает строковые литералы и однострочные -- комментарии
var
  p, depth: Integer;
  InStr: Boolean;
begin
  Result := 0;
  depth := 0;
  InStr := False;
  p := StartPos;
  while p <= Length(Text) do begin
    if InStr then begin
      if Text[p] = '''' then
        InStr := False;
    end
    else if (Text[p] = '-') and (p < Length(Text)) and (Text[p + 1] = '-') then begin
      while (p <= Length(Text)) and (Text[p] <> #10) do
        Inc(p);
      Continue;
    end
    else if Text[p] = '''' then
      InStr := True
    else if Text[p] = '(' then
      Inc(depth)
    else if Text[p] = ')' then begin
      Dec(depth);
      if depth = 0 then begin
        Result := p;
        Exit;
      end;
    end;
    Inc(p);
  end;
end;

function ExtractLineComment(var Line: string): string;
//выделяет комментарий (--текст) из строки, обрезая его от Line; возвращает '' если комментария нет
var
  p: Integer;
begin
  Result := '';
  p := Pos('--', Line);
  if p > 0 then begin
    Result := Trim(Copy(Line, p + 2, MaxInt));
    Line := Copy(Line, 1, p - 1);
  end;
end;

function ExtractLineTagEx(var Line: string; AStateChar: Char): Char;
//ищет в конце строки тег --<AStateChar>+ (добавить) или --<AStateChar>- (удалить) - ровно два
//дефиса перед ним (---!+/---!- - отключенная конструкция, три и более дефиса, игнорируется);
//если найден - обрезает его (и хвостовые пробелы) от Line и возвращает '+' или '-', иначе #0 и
//Line не меняется. тег ищется правее столбца/заголовка объекта, в том числе правее его
//--комментария (весь хвост после первого -- на строке все равно один комментарий - тег просто
//его завершающая часть). AStateChar - '!' (взведенный тег) или '$' (уже обработанный)
var
  TrimmedLine: string;
  L: Integer;
  TagChar: Char;
begin
  Result := #0;
  TrimmedLine := TrimRight(Line);
  L := Length(TrimmedLine);
  if L < 4 then
    Exit;
  TagChar := TrimmedLine[L];
  if (TagChar <> '+') and (TagChar <> '-') then
    Exit;
  //ожидаем на позициях L-3..L-1 ровно "--" + AStateChar
  if (TrimmedLine[L - 1] <> AStateChar) or (TrimmedLine[L - 2] <> '-') or (TrimmedLine[L - 3] <> '-') then
    Exit;
  //перед --! / --$ не должно быть еще одного дефиса (---!+ - отключено)
  if (L - 4 >= 1) and (TrimmedLine[L - 4] = '-') then
    Exit;
  Result := TagChar;
  Line := TrimRight(Copy(TrimmedLine, 1, L - 4));
end;

function ExtractLineTag(var Line: string): Char;
//тег --!+/--!- (взведенный) - см. ExtractLineTagEx
begin
  Result := ExtractLineTagEx(Line, '!');
end;

function ExtractLeadIdent(const Line: string): string;
//первый идентификатор в начале строки (имя поля)
var
  p: Integer;
begin
  Result := '';
  p := 1;
  while (p <= Length(Line)) and CharInSet(Line[p], [' ', #9]) do
    Inc(p);
  while (p <= Length(Line)) and CharInSet(Line[p], cIdentChars) do begin
    Result := Result + Line[p];
    Inc(p);
  end;
end;

function FindPrecedingTableComment(const Text: string; TableStartPos, LowerBoundPos: Integer; const TableName: string; out CommentText: string): Boolean;
//ищет над create table, в границах от LowerBoundPos (конец определения предыдущей таблицы в
//файле, или 1 - если это первая таблица) до TableStartPos, ближайший блок построчных --
//комментариев вида "--таблица <имя>" + текст. между блоком комментария и create table могут
//быть посторонние строки - пустые, другие -- комментарии, и даже незакомментированный код
//(например, вручную оставленная строка alter table add column) - это не должно мешать найти
//настоящий блок, если он есть чуть выше; поэтому вся область от LowerBoundPos и выше
//просматривается целиком, а не только до первой "постронней" строки.
//строка вида ---... (три и более дефиса вместо двух) - отключенная конструкция, не
//распознается как заголовок.
//пустая строка (а также любая "настоящая", не -- комментарий, строка кода) считается границей
//абзаца: в комментарий к таблице попадают только строки, непосредственно следующие за
//найденным заголовком, до первой такой границы или конца области.
var
  Lines, RawLines, CommentLines: TStringList;
  PrecedingText, HeaderRest: string;
  i, HeaderIdx, StartPos: Integer;
begin
  Result := False;
  CommentText := '';
  StartPos := LowerBoundPos;
  if StartPos < 1 then
    StartPos := 1;
  if StartPos >= TableStartPos then
    Exit;
  PrecedingText := Copy(Text, StartPos, TableStartPos - StartPos);
  Lines := TStringList.Create;
  RawLines := TStringList.Create;
  CommentLines := TStringList.Create;
  try
    Lines.Text := PrecedingText;
    for i := 0 to Lines.Count - 1 do
      RawLines.Add(Trim(Lines[i])); //пустые и "настоящие" (не -- комментарий) строки остаются как есть - поиск заголовка их просто пропустит

    //ищем ближайший (последний по порядку сверху вниз, т.е. ближайший к create table) заголовок
    HeaderIdx := -1;
    for i := 0 to RawLines.Count - 1 do begin
      if Copy(RawLines[i], 1, 2) <> '--' then
        Continue; //пустая строка или посторонний код
      if Copy(RawLines[i], 1, 3) = '---' then
        Continue; //отключенная конструкция
      HeaderRest := Trim(Copy(RawLines[i], 3, MaxInt));
      if not SameText(Copy(HeaderRest, 1, 7), 'таблица') then
        Continue;
      HeaderRest := Trim(Copy(HeaderRest, 8, MaxInt));
      if SameText(HeaderRest, TableName) then
        HeaderIdx := i;
    end;
    if HeaderIdx = -1 then
      Exit;

    for i := HeaderIdx + 1 to RawLines.Count - 1 do begin
      if (RawLines[i] = '') or (Copy(RawLines[i], 1, 2) <> '--') then
        Break;
      CommentLines.Add(Copy(RawLines[i], 3, MaxInt));
    end;
    while (CommentLines.Count > 0) and (Trim(CommentLines[CommentLines.Count - 1]) = '') do
      CommentLines.Delete(CommentLines.Count - 1);
    for i := 0 to CommentLines.Count - 1 do
      CommentLines[i] := Trim(CommentLines[i]);
    CommentText := Trim(CommentLines.Text);
    Result := CommentLines.Count > 0;
  finally
    Lines.Free;
    RawLines.Free;
    CommentLines.Free;
  end;
end;

function ParseFileTables(const AFileName: string; out Tables: TSqlTableInfoArray; out ErrMsg: string): Boolean;
var
  Text: string;
  RE: TRegEx;
  M: TMatch;
  BlockStartPos, BlockEndPos, PrevTableEndPos: Integer;
  TableName, Ln, TrimmedLn, Comment, ColName, ColDef, TableComment: string;
  Cols: TSqlColumnCommentArray;
  HasComment: Boolean;
  Tag: Char;
  p, LineStartPos, LineEndPos: Integer;
begin
  Result := False;
  ErrMsg := '';
  SetLength(Tables, 0);

  Text := LoadSqlFileText(AFileName, ErrMsg);
  if ErrMsg <> '' then
    Exit;
  Text := StripBlockComments(Text);

  PrevTableEndPos := 0;
  RE := TRegEx.Create('create\s+table\s+([a-zA-Z0-9_\.\$#]+)\s*\(', [roIgnoreCase]);
  for M in RE.Matches(Text) do begin
    TableName := LowerCase(M.Groups[1].Value);
    if Pos('.', TableName) > 0 then
      TableName := Copy(TableName, Pos('.', TableName) + 1, MaxInt);

    BlockStartPos := M.Index + Length(M.Value) - 1;
    BlockEndPos := FindMatchingParenEnd(Text, BlockStartPos);
    if BlockEndPos = 0 then
      Continue;

    SetLength(Cols, 0);
    //построчный проход по блоку столбцов с сохранением абсолютной позиции начала каждой
    //строки в Text (LinePos) - нужна для последующей точечной пометки тега обработанным
    p := BlockStartPos + 1;
    while p < BlockEndPos do begin
      LineStartPos := p;
      while (p < BlockEndPos) and (Text[p] <> #10) do
        Inc(p);
      LineEndPos := p;
      if p < BlockEndPos then
        Inc(p); //пропускаем сам #10
      Ln := Copy(Text, LineStartPos, LineEndPos - LineStartPos);
      TrimmedLn := Trim(Ln);
      if TrimmedLn = '' then
        Continue;
      if SameText(Copy(TrimmedLn, 1, 10), 'constraint') then
        Continue;
      Tag := ExtractLineTag(TrimmedLn); //тег --!+/--!- (если есть) - справа от столбца, правее комментария
      Comment := ExtractLineComment(TrimmedLn);
      ColName := LowerCase(ExtractLeadIdent(TrimmedLn));
      if ColName = '' then
        Continue;
      ColDef := Trim(TrimmedLn);
      if (ColDef <> '') and (ColDef[Length(ColDef)] = ',') then
        ColDef := Trim(Copy(ColDef, 1, Length(ColDef) - 1));
      SetLength(Cols, Length(Cols) + 1);
      Cols[High(Cols)].ColName := ColName;
      Cols[High(Cols)].Comment := Comment;
      Cols[High(Cols)].Tag := Tag;
      Cols[High(Cols)].ColDef := ColDef;
      Cols[High(Cols)].LinePos := LineStartPos;
    end;

    HasComment := FindPrecedingTableComment(Text, M.Index, PrevTableEndPos, TableName, TableComment);
    PrevTableEndPos := BlockEndPos;

    SetLength(Tables, Length(Tables) + 1);
    Tables[High(Tables)].TableName := TableName;
    Tables[High(Tables)].HasComment := HasComment;
    Tables[High(Tables)].Comment := TableComment;
    Tables[High(Tables)].Columns := Cols;
  end;
  Result := True;
end;

{------------------------------------------------------------------------------------------}

function ExtractGoBlocksByState(const Text: string; const AStateChar: Char): TSqlGoBlockArray;
//находит все пары --<AStateChar>go begin / --<AStateChar>go end (ровно два дефиса; ---Xgo
//begin/end - отключено), с позициями строк begin/end (для последующей точечной пометки
//"обработано") и содержимым между ними по порядку. AStateChar = '!' - взведенные (см.
//ExtractGoBlocksEx/HasActiveGoBlocks; --$go begin/end при этом не попадают в результат - см.
//RestoreActionTriggers, чтобы их снова начать выполнять), '$' - уже обработанные, еще не
//финальные (см. BuildProcessedTagsReport)
var
  Res: TSqlGoBlockArray;
  p, LineStart, LineEnd: Integer;
  TrimmedLn: string;
  InBlock: Boolean;
  BeginPos, ContentStart: Integer;
  BeginMarker, EndMarker: string;
begin
  BeginMarker := '--' + AStateChar + 'go begin';
  EndMarker := '--' + AStateChar + 'go end';
  SetLength(Res, 0);
  InBlock := False;
  BeginPos := 0;
  ContentStart := 0;
  p := 1;
  while p <= Length(Text) do begin
    LineStart := p;
    while (p <= Length(Text)) and (Text[p] <> #10) do
      Inc(p);
    LineEnd := p; //позиция #10 либо Length(Text)+1
    TrimmedLn := Trim(Copy(Text, LineStart, LineEnd - LineStart));
    if p <= Length(Text) then
      Inc(p); //пропускаем сам #10

    if not InBlock then begin
      if SameText(TrimmedLn, BeginMarker) then begin
        InBlock := True;
        BeginPos := LineStart;
        ContentStart := p;
      end;
    end
    else begin
      if SameText(TrimmedLn, EndMarker) then begin
        SetLength(Res, Length(Res) + 1);
        Res[High(Res)].BeginLinePos := BeginPos;
        Res[High(Res)].EndLinePos := LineStart;
        Res[High(Res)].Content := Copy(Text, ContentStart, LineStart - ContentStart);
        InBlock := False;
      end;
    end;
  end;
  Result := Res;
end;

function ExtractGoBlocksEx(const Text: string): TSqlGoBlockArray;
begin
  Result := ExtractGoBlocksByState(Text, '!');
end;

function ExtractGoBlocks(const Text: string): TStringDynArray;
//только содержимое блоков (без позиций) - для отчета/подсчета
var
  Blocks: TSqlGoBlockArray;
  i: Integer;
  Res: TStringDynArray;
begin
  Blocks := ExtractGoBlocksEx(Text);
  SetLength(Res, Length(Blocks));
  for i := 0 to High(Blocks) do
    Res[i] := Blocks[i].Content;
  Result := Res;
end;

function HasActiveGoBlocks(const Text: string): Boolean;
begin
  Result := Length(ExtractGoBlocksEx(Text)) > 0;
end;

function BuildGoBlocksReport(const Text: string): string;
//отчет по всем активным --!go begin/--!go end блокам файла - для показа по клику в колонке "Скрипты"
const
  cDivider = '-------------------';
var
  Blocks: TStringDynArray;
  i: Integer;
  Res: TStringList;
begin
  Result := '';
  Blocks := ExtractGoBlocks(Text);
  if Length(Blocks) = 0 then
    Exit;
  Res := TStringList.Create;
  try
    for i := 0 to High(Blocks) do begin
      if i > 0 then
        Res.Add(cDivider);
      Res.Add(Trim(Blocks[i]));
    end;
    Result := Res.Text;
  finally
    Res.Free;
  end;
end;

{------------------------------------------------------------------------------------------}

function FindAttentionMarkers(const Text: string): TSqlAttentionItemArray;
//находит все строки --!!! (ровно два дефиса) вне блочных комментариев (текст должен быть уже
//пропущен через StripBlockComments); для каждой - текст после тега на той же строке (если
//там есть что-то кроме пробелов) и первую непустую строку под ней
var
  Lines: TStringList;
  i, j: Integer;
  TrimmedLn, Extra, NextLn: string;
  Res: TSqlAttentionItemArray;
begin
  SetLength(Res, 0);
  Lines := TStringList.Create;
  try
    Lines.Text := Text;
    for i := 0 to Lines.Count - 1 do begin
      TrimmedLn := Trim(Lines[i]);
      if Copy(TrimmedLn, 1, 5) <> '--!!!' then
        Continue;
      Extra := Trim(Copy(TrimmedLn, 6, MaxInt));
      NextLn := '';
      for j := i + 1 to Lines.Count - 1 do begin
        if Trim(Lines[j]) <> '' then begin
          NextLn := Trim(Lines[j]);
          Break;
        end;
      end;
      SetLength(Res, Length(Res) + 1);
      Res[High(Res)].TagLineExtra := Extra;
      Res[High(Res)].NextLineText := NextLn;
    end;
  finally
    Lines.Free;
  end;
  Result := Res;
end;

function HasAttentionMarkers(const Text: string): Boolean;
begin
  Result := Length(FindAttentionMarkers(Text)) > 0;
end;

function BuildAttentionReport(const Text: string): string;
const
  cDivider = '-------------------';
var
  Items: TSqlAttentionItemArray;
  i: Integer;
  Res: TStringList;
begin
  Result := '';
  Items := FindAttentionMarkers(Text);
  if Length(Items) = 0 then
    Exit;
  Res := TStringList.Create;
  try
    for i := 0 to High(Items) do begin
      if i > 0 then
        Res.Add(cDivider);
      if Items[i].TagLineExtra <> '' then
        Res.Add(Items[i].TagLineExtra);
      if Items[i].NextLineText <> '' then
        Res.Add(Items[i].NextLineText);
    end;
    Result := Res.Text;
  finally
    Res.Free;
  end;
end;

{------------------------------------------------------------------------------------------}

function ScanFileObjectTags(const Text, ASourceFile: string): TSqlObjectTagInfoArray;
//находит теги --!+/--!- на строках заголовков create table/view/function/procedure/trigger/
//sequence/index/(alter table ... add constraint) - текст должен быть уже пропущен через
//StripBlockComments
var
  Res: TSqlObjectTagInfoArray;

  procedure Scan(const APattern, AObjType: string; ANameGroup: Integer; ATableGroup: Integer = -1);
  var
    RE: TRegEx;
    M: TMatch;
    LineStartPos, LineEndPos, p: Integer;
    Ln: string;
    Tag: Char;
  begin
    RE := TRegEx.Create(APattern, [roIgnoreCase]);
    for M in RE.Matches(Text) do begin
      //найдем границы строки, в которую попадает начало совпадения
      LineStartPos := M.Index;
      while (LineStartPos > 1) and (Text[LineStartPos - 1] <> #10) do
        Dec(LineStartPos);
      LineEndPos := M.Index;
      while (LineEndPos <= Length(Text)) and (Text[LineEndPos] <> #10) and (Text[LineEndPos] <> #13) do
        Inc(LineEndPos);
      Ln := Copy(Text, LineStartPos, LineEndPos - LineStartPos);
      Tag := ExtractLineTag(Ln);
      if Tag = #0 then
        Continue;
      SetLength(Res, Length(Res) + 1);
      Res[High(Res)].ObjType := AObjType;
      Res[High(Res)].ObjectName := LowerCase(Trim(M.Groups[ANameGroup].Value));
      if ATableGroup >= 0 then
        Res[High(Res)].TableName := LowerCase(Trim(M.Groups[ATableGroup].Value))
      else
        Res[High(Res)].TableName := '';
      Res[High(Res)].Tag := Tag;
      Res[High(Res)].SourceFile := ASourceFile;
      Res[High(Res)].LinePos := LineStartPos;
    end;
  end;

begin
  SetLength(Res, 0);
  //порядок сканирования типов объектов важен: он определяет порядок выполнения тегов --!+ в
  //ProcessFileTags (объекты выполняются в порядке следования в Res, а не в порядке следования в
  //тексте файла) - поэтому таблицы и последовательности (от которых ничего не зависит, а от них
  //могут зависеть индексы/констрейнты/триггеры/представления) должны сканироваться первыми,
  //а представления/функции/процедуры (которые чаще всего зависят от уже существующих таблиц и
  //триггеров) - последними
  Scan('create\s+table\s+([a-zA-Z0-9_\$#]+)\s*\(', 'table', 1);
  Scan('create\s+sequence\s+([a-zA-Z0-9_\$#]+)\b', 'sequence', 1);
  Scan('create\s+(?:unique\s+)?index\s+([a-zA-Z0-9_\$#]+)\s+on\s+(\S+)', 'index', 1, 2);
  Scan('alter\s+table\s+(\S+)\s+add\s+constraint\s+([a-zA-Z0-9_\$#]+)\b', 'constraint', 2, 1);
  Scan('create\s+(?:or\s+replace\s+)?trigger\s+([a-zA-Z0-9_\$#]+)\b', 'trigger', 1);
  Scan('create\s+(?:or\s+replace\s+)?view\s+([a-zA-Z0-9_\$#]+)\s+as\b', 'view', 1);
  Scan('create\s+(?:or\s+replace\s+)?function\s+([a-zA-Z0-9_\$#]+)\b', 'function', 1);
  Scan('create\s+(?:or\s+replace\s+)?procedure\s+([a-zA-Z0-9_\$#]+)\b', 'procedure', 1);
  Result := Res;
end;

function BuildTagsReport(const ATables: TSqlTableInfoArray; const AObjTags: TSqlObjectTagInfoArray): string;
const
  cDivider = '-------------------';
var
  Res: TStringList;
  i, j: Integer;
  First: Boolean;
begin
  Result := '';
  Res := TStringList.Create;
  try
    First := True;
    for i := 0 to High(ATables) do
      for j := 0 to High(ATables[i].Columns) do
        if ATables[i].Columns[j].Tag <> #0 then begin
          if not First then
            Res.Add(cDivider);
          First := False;
          if ATables[i].Columns[j].Tag = '+' then
            Res.Add('добавить столбец ' + ATables[i].TableName + '.' + ATables[i].Columns[j].ColName + ': ' + ATables[i].Columns[j].ColDef)
          else
            Res.Add('удалить столбец ' + ATables[i].TableName + '.' + ATables[i].Columns[j].ColName);
        end;
    for i := 0 to High(AObjTags) do begin
      if not First then
        Res.Add(cDivider);
      First := False;
      if AObjTags[i].Tag = '+' then
        Res.Add('(пере)создать ' + AObjTags[i].ObjType + ' ' + AObjTags[i].ObjectName)
      else
        Res.Add('удалить ' + AObjTags[i].ObjType + ' ' + AObjTags[i].ObjectName);
    end;
    Result := Res.Text;
  finally
    Res.Free;
  end;
end;

function HasAnyTags(const ATables: TSqlTableInfoArray; const AObjTags: TSqlObjectTagInfoArray): Boolean;
var
  i, j: Integer;
begin
  Result := Length(AObjTags) > 0;
  if Result then
    Exit;
  for i := 0 to High(ATables) do
    for j := 0 to High(ATables[i].Columns) do
      if ATables[i].Columns[j].Tag <> #0 then begin
        Result := True;
        Exit;
      end;
end;

{------------------------------------------------------------------------------------------}

function FindProcessedMarkerLines(const Text: string): TStringDynArray;
//находит все строки (текст должен быть уже пропущен через StripBlockComments) с уже
//обработанными или финальными метками: --$+ / --$- в конце строки (столбец/объект),
//--$dropped, --$completed begin. В отличие от ScanFileObjectTags/ParseFileTables, здесь НЕ
//разбирается, к какому именно объекту/столбцу относится строка - только сам факт наличия
//метки и её текст, этого достаточно для обзора (см. общую задачу пользователя). Строки-маркеры
//--$go begin/--$go end сюда не включаются - целые блоки между ними показываются отдельно (см.
//BuildProcessedTagsReport/ExtractGoBlocksByState), чтобы не дублировать
var
  Lines: TStringList;
  i: Integer;
  Ln: string;
  Res: TStringDynArray;
begin
  SetLength(Res, 0);
  Lines := TStringList.Create;
  try
    Lines.Text := Text;
    for i := 0 to Lines.Count - 1 do begin
      Ln := Lines[i];
      if Pos('--$', Ln) = 0 then
        Continue;
      if SameText(Trim(Ln), '--$go begin') or SameText(Trim(Ln), '--$go end') then
        Continue;
      SetLength(Res, Length(Res) + 1);
      Res[High(Res)] := Trim(Ln);
    end;
  finally
    Lines.Free;
  end;
  Result := Res;
end;

function HasProcessedTags(const Text: string): Boolean;
begin
  Result := (Length(FindProcessedMarkerLines(Text)) > 0) or (Length(ExtractGoBlocksByState(Text, '$')) > 0);
end;

function BuildProcessedTagsReport(const Text: string): string;
const
  cDivider = '-------------------';
var
  Lines: TStringDynArray;
  Blocks: TSqlGoBlockArray;
  i: Integer;
  Res: TStringList;
  First: Boolean;
begin
  Result := '';
  Res := TStringList.Create;
  try
    First := True;
    Lines := FindProcessedMarkerLines(Text);
    for i := 0 to High(Lines) do begin
      if not First then
        Res.Add(cDivider);
      First := False;
      Res.Add(Lines[i]);
    end;
    Blocks := ExtractGoBlocksByState(Text, '$');
    for i := 0 to High(Blocks) do begin
      if not First then
        Res.Add(cDivider);
      First := False;
      Res.Add('--$go begin ... --$go end:');
      Res.Add(Trim(Blocks[i].Content));
    end;
    Result := Res.Text;
  finally
    Res.Free;
  end;
end;

{------------------------------------------------------------------------------------------}

function ScanFileMarkers(const AFileName: string; out AHasAttention, AHasGoBlocks, AHasTags, AHasProcessed: Boolean; out ErrMsg: string): Boolean;
var
  Text: string;
  Tables: TSqlTableInfoArray;
  ObjTags: TSqlObjectTagInfoArray;
begin
  Result := False;
  AHasAttention := False;
  AHasGoBlocks := False;
  AHasTags := False;
  AHasProcessed := False;
  Text := LoadSqlFileText(AFileName, ErrMsg);
  if ErrMsg <> '' then
    Exit;
  Text := StripBlockComments(Text);
  AHasAttention := HasAttentionMarkers(Text);
  AHasGoBlocks := HasActiveGoBlocks(Text);
  if not ParseFileTables(AFileName, Tables, ErrMsg) then
    Tables := nil;
  ErrMsg := '';
  ObjTags := ScanFileObjectTags(Text, AFileName);
  AHasTags := HasAnyTags(Tables, ObjTags);
  AHasProcessed := HasProcessedTags(Text);
  Result := True;
end;

function FindTopLevelSemicolonInLine(const S: string): Integer;
//первый ';' вне строкового литерала и вне -- комментария в пределах одной строки; 0 - не найден
var
  p: Integer;
  InStr: Boolean;
begin
  Result := 0;
  InStr := False;
  p := 1;
  while p <= Length(S) do begin
    if InStr then begin
      if S[p] = '''' then
        InStr := False;
    end
    else if (S[p] = '-') and (p < Length(S)) and (S[p + 1] = '-') then
      Break
    else if S[p] = '''' then
      InStr := True
    else if S[p] = ';' then begin
      Result := p;
      Exit;
    end;
    Inc(p);
  end;
end;

function StartsPlsqlBlock(const AUpperTrimmedLine: string): Boolean;
begin
  Result :=
    (Pos('CREATE OR REPLACE PROCEDURE', AUpperTrimmedLine) = 1) or (Pos('CREATE PROCEDURE', AUpperTrimmedLine) = 1) or
    (Pos('CREATE OR REPLACE FUNCTION', AUpperTrimmedLine) = 1) or (Pos('CREATE FUNCTION', AUpperTrimmedLine) = 1) or
    (Pos('CREATE OR REPLACE TRIGGER', AUpperTrimmedLine) = 1) or (Pos('CREATE TRIGGER', AUpperTrimmedLine) = 1) or
    (Pos('DECLARE', AUpperTrimmedLine) = 1) or (Pos('BEGIN', AUpperTrimmedLine) = 1);
end;

function SplitStatements(const Text: string): TStringDynArray;
//разбивает текст на отдельные исполняемые "операторы":
//- строки !rebuild/!drop - как отдельный атомарный оператор (директива);
//- объекты plsql (procedure/function/trigger/declare/begin) - до строки, содержащей только '/';
//- обычные ddl/dml - до первого ';' верхнего уровня.
//строки, целиком являющиеся -- комментарием (например, закомментированное действие вида
//"--alter table ttt..." - см. пример в справке по --!go begin/end), вне уже накапливаемого
//оператора пропускаются целиком - не порождают отдельный "оператор" и не выполняются.
var
  Lines: TStringList;
  Buf: TStringList;
  Res: TStringDynArray;
  i, PSemi: Integer;
  Ln, TrimmedLn: string;
  IsPlsql: Boolean;

  procedure FlushBuf;
  var
    s: string;
  begin
    s := Trim(Buf.Text);
    if s <> '' then begin
      SetLength(Res, Length(Res) + 1);
      Res[High(Res)] := s;
    end;
    Buf.Clear;
    IsPlsql := False;
  end;

begin
  SetLength(Res, 0);
  Lines := TStringList.Create;
  Buf := TStringList.Create;
  try
    Lines.Text := Text;
    IsPlsql := False;
    i := 0;
    while i <= Lines.Count - 1 do begin
      Ln := Lines[i];
      TrimmedLn := Trim(Ln);

      if (Buf.Count = 0) and ((Pos('!rebuild', LowerCase(TrimmedLn)) = 1) or (Pos('!drop', LowerCase(TrimmedLn)) = 1)) then begin
        SetLength(Res, Length(Res) + 1);
        Res[High(Res)] := TrimmedLn;
        Inc(i);
        Continue;
      end;

      if (Buf.Count = 0) and ((TrimmedLn = '') or (Pos('--', TrimmedLn) = 1)) then begin
        Inc(i);
        Continue;
      end;

      if Buf.Count = 0 then
        IsPlsql := StartsPlsqlBlock(UpperCase(TrimmedLn));

      if IsPlsql then begin
        if TrimmedLn = '/' then
          FlushBuf
        else
          Buf.Add(Ln);
        Inc(i);
        Continue;
      end;

      PSemi := FindTopLevelSemicolonInLine(Ln);
      if PSemi > 0 then begin
        Buf.Add(Copy(Ln, 1, PSemi - 1));
        FlushBuf;
      end
      else
        Buf.Add(Ln);
      Inc(i);
    end;
    FlushBuf; //последний накопленный оператор, если файл не закончился явным разделителем
  finally
    Lines.Free;
    Buf.Free;
  end;
  Result := Res;
end;

{------------------------------------------------------------------------------------------}

function FindStatementEndSemicolon(const Text: string; StartPos: Integer): Integer;
//первый ';' вне строковых литералов/комментариев начиная с StartPos (по всему многострочному тексту)
var
  p: Integer;
  InStr: Boolean;
begin
  Result := 0;
  InStr := False;
  p := StartPos;
  while p <= Length(Text) do begin
    if InStr then begin
      if Text[p] = '''' then
        InStr := False;
    end
    else if (Text[p] = '-') and (p < Length(Text)) and (Text[p + 1] = '-') then begin
      while (p <= Length(Text)) and (Text[p] <> #10) do
        Inc(p);
      Continue;
    end
    else if Text[p] = '''' then
      InStr := True
    else if Text[p] = ';' then begin
      Result := p;
      Exit;
    end;
    Inc(p);
  end;
end;

function ExtractSqlStatementText(const Text: string; StartPos: Integer): string;
var
  EndPos: Integer;
begin
  EndPos := FindStatementEndSemicolon(Text, StartPos);
  if EndPos = 0 then
    Result := Trim(Copy(Text, StartPos, MaxInt))
  else
    Result := Trim(Copy(Text, StartPos, EndPos - StartPos));
end;

function ExtractPlsqlBody(const Text: string; StartPos: Integer): string;
//текст plsql-объекта от StartPos до (не включая) строки, содержащей только '/'
var
  Tail: string;
  Lines, ResultLines: TStringList;
  i: Integer;
begin
  Result := '';
  Tail := Copy(Text, StartPos, MaxInt);
  Lines := TStringList.Create;
  ResultLines := TStringList.Create;
  try
    Lines.Text := Tail;
    for i := 0 to Lines.Count - 1 do begin
      if Trim(Lines[i]) = '/' then
        Break;
      ResultLines.Add(Lines[i]);
    end;
    Result := Trim(ResultLines.Text);
  finally
    Lines.Free;
    ResultLines.Free;
  end;
end;

function FindObjectDefinition(const AFiles: TStringDynArray; const AObjectName: string; out ADef: TSqlObjectDef): Boolean;
//ищет по всем файлам (в порядке списка) момент определения объекта с именем AObjectName;
//возвращает первое найденное совпадение (по любому поддерживаемому типу объекта)
var
  i: Integer;
  Text, ErrMsg, NamePattern: string;
  M: TMatch;

  function TryType(const APattern, AType: string; APlsql: Boolean): Boolean;
  var
    RE: TRegEx;
    LM: TMatch;
  begin
    Result := False;
    RE := TRegEx.Create(APattern, [roIgnoreCase]);
    LM := RE.Match(Text);
    if not LM.Success then
      Exit;
    ADef.Found := True;
    ADef.ObjType := AType;
    ADef.ObjectName := AObjectName;
    ADef.SourceFile := AFiles[i];
    if APlsql then
      ADef.DefText := ExtractPlsqlBody(Text, LM.Index)
    else
      ADef.DefText := ExtractSqlStatementText(Text, LM.Index);
    Result := True;
  end;

begin
  FillChar(ADef, SizeOf(ADef), 0);
  Result := False;
  NamePattern := TRegEx.Escape(AObjectName);
  for i := 0 to High(AFiles) do begin
    Text := LoadSqlFileText(AFiles[i], ErrMsg);
    if (Text = '') or (ErrMsg <> '') then
      Continue;
    Text := StripBlockComments(Text);

    if TryType('create\s+(or\s+replace\s+)?view\s+' + NamePattern + '\s+as\b', 'view', False)
    or TryType('create\s+(or\s+replace\s+)?function\s+' + NamePattern + '\b', 'function', True)
    or TryType('create\s+(or\s+replace\s+)?procedure\s+' + NamePattern + '\b', 'procedure', True)
    or TryType('create\s+(or\s+replace\s+)?trigger\s+' + NamePattern + '\b', 'trigger', True)
    or TryType('create\s+sequence\s+' + NamePattern + '\b', 'sequence', False)
    or TryType('create\s+(unique\s+)?index\s+' + NamePattern + '\s+on\s+(\S+)', 'index', False)
    or TryType('create\s+table\s+' + NamePattern + '\s*\(', 'table', False)
    or TryType('alter\s+table\s+(\S+)\s+add\s+constraint\s+' + NamePattern + '\b', 'constraint', False)
    then begin
      if ADef.ObjType = 'constraint' then begin
        M := TRegEx.Match(ADef.DefText, 'alter\s+table\s+(\S+)\s+add\s+constraint', [roIgnoreCase]);
        if M.Success then
          ADef.TableName := LowerCase(Trim(M.Groups[1].Value));
      end
      else if ADef.ObjType = 'index' then begin
        M := TRegEx.Match(ADef.DefText, 'create\s+(unique\s+)?index\s+\S+\s+on\s+(\S+)', [roIgnoreCase]);
        if M.Success then
          ADef.TableName := LowerCase(Trim(M.Groups[2].Value));
      end;
      Result := True;
      Exit;
    end;
  end;
end;

{------------------------------------------------------------------------------------------}

function EscapeSqlLiteral(const S: string): string;
begin
  Result := StringReplace(S, '''', '''''', [rfReplaceAll]);
end;

function ExecRawSql(const Sql: string; out ErrMsg: string): Boolean;
//выполняет произвольный текст ddl/дмл напрямую через отдельный TADOQuery с выключенным
//ParamCheck - иначе ':new'/':old' в телах триггеров были бы ошибочно приняты за параметры ado
var
  Qry: TADOQuery;
begin
  Result := False;
  ErrMsg := '';
  if Trim(Sql) = '' then begin
    Result := True;
    Exit;
  end;
  Qry := TADOQuery.Create(nil);
  try
    Qry.ParamCheck := False;
    Qry.Connection := Q.AdoConnection;
    Qry.SQL.Text := Sql;
    try
      Qry.ExecSQL;
      Result := True;
    except
      on E: Exception do
        ErrMsg := E.Message;
    end;
  finally
    Qry.Free;
  end;
end;

function RebuildObject(const ADef: TSqlObjectDef; out ErrMsg: string): Boolean;
begin
  Result := False;
  ErrMsg := '';
  if not ADef.Found then begin
    ErrMsg := 'определение объекта "' + ADef.ObjectName + '" не найдено ни в одном файле';
    Exit;
  end;

  if SameText(ADef.ObjType, 'view') or SameText(ADef.ObjType, 'function')
  or SameText(ADef.ObjType, 'procedure') or SameText(ADef.ObjType, 'trigger') then begin
    //эти виды поддерживают create or replace - пересоздаём напрямую, без предварительного drop
    Result := ExecRawSql(ADef.DefText, ErrMsg);
  end
  else if SameText(ADef.ObjType, 'sequence') then begin
    if VarToStr(Q.QLoadValue('select count(*) from user_sequences where sequence_name = upper(:n$s)', [ADef.ObjectName])) <> '0' then
      if not ExecRawSql('drop sequence ' + ADef.ObjectName, ErrMsg) then
        Exit;
    Result := ExecRawSql(ADef.DefText, ErrMsg);
  end
  else if SameText(ADef.ObjType, 'index') then begin
    if VarToStr(Q.QLoadValue('select count(*) from user_indexes where index_name = upper(:n$s)', [ADef.ObjectName])) <> '0' then
      if not ExecRawSql('drop index ' + ADef.ObjectName, ErrMsg) then
        Exit;
    Result := ExecRawSql(ADef.DefText, ErrMsg);
  end
  else if SameText(ADef.ObjType, 'constraint') then begin
    if ADef.TableName = '' then begin
      ErrMsg := 'не удалось определить таблицу для констрейнта "' + ADef.ObjectName + '"';
      Exit;
    end;
    if VarToStr(Q.QLoadValue('select count(*) from user_constraints where constraint_name = upper(:n$s)', [ADef.ObjectName])) <> '0' then
      if not ExecRawSql('alter table ' + ADef.TableName + ' drop constraint ' + ADef.ObjectName, ErrMsg) then
        Exit;
    Result := ExecRawSql(ADef.DefText, ErrMsg);
  end
  else
    ErrMsg := 'пересоздание объектов типа "' + ADef.ObjType + '" не поддерживается';
end;

function DropObjectByName(const AFiles: TStringDynArray; const AObjectName: string; out ErrMsg: string): Boolean;
//удаляет объект по имени (используется и для тега --!-, и для директивы !drop - см.
//ExecObjectTag/DropAndLog). Перед реальным drop для каждого типа проверяем, есть ли объект в
//бд вообще - если уже нет (удален вручную, или уже был удален предыдущим прогоном, а тег
//почему-то остался взведенным) - считаем это успехом без выполнения drop и без ошибки (по
//просьбе пользователя: "если ошибка такая что он уже не существует - ошибку не выводить, тег
//изменения гасить") - тот же прием, что уже применялся только для таблиц, теперь одинаково для
//всех типов объектов. Проверка идет по метаданным бд (user_views/user_objects/user_triggers/
//user_sequences/user_indexes/user_constraints), а не по разбору текста ошибки - надежнее.
var
  ADef: TSqlObjectDef;
begin
  Result := False;
  ErrMsg := '';
  if not FindObjectDefinition(AFiles, AObjectName, ADef) then begin
    ErrMsg := 'определение объекта "' + AObjectName + '" не найдено ни в одном файле';
    Exit;
  end;
  if SameText(ADef.ObjType, 'table') then begin
    if not TableExistsInDb(AObjectName) then begin
      Result := True;
      Exit;
    end;
    Result := ExecRawSql('drop table ' + AObjectName + ' cascade constraints', ErrMsg);
  end
  else if SameText(ADef.ObjType, 'view') then begin
    if VarToStr(Q.QLoadValue('select count(*) from user_views where view_name = upper(:n$s)', [AObjectName])) = '0' then begin
      Result := True;
      Exit;
    end;
    Result := ExecRawSql('drop view ' + AObjectName, ErrMsg);
  end
  else if SameText(ADef.ObjType, 'function') then begin
    if VarToStr(Q.QLoadValue('select count(*) from user_objects where object_name = upper(:n$s) and object_type = ''FUNCTION''', [AObjectName])) = '0' then begin
      Result := True;
      Exit;
    end;
    Result := ExecRawSql('drop function ' + AObjectName, ErrMsg);
  end
  else if SameText(ADef.ObjType, 'procedure') then begin
    if VarToStr(Q.QLoadValue('select count(*) from user_objects where object_name = upper(:n$s) and object_type = ''PROCEDURE''', [AObjectName])) = '0' then begin
      Result := True;
      Exit;
    end;
    Result := ExecRawSql('drop procedure ' + AObjectName, ErrMsg);
  end
  else if SameText(ADef.ObjType, 'trigger') then begin
    if VarToStr(Q.QLoadValue('select count(*) from user_triggers where trigger_name = upper(:n$s)', [AObjectName])) = '0' then begin
      Result := True;
      Exit;
    end;
    Result := ExecRawSql('drop trigger ' + AObjectName, ErrMsg);
  end
  else if SameText(ADef.ObjType, 'sequence') then begin
    if VarToStr(Q.QLoadValue('select count(*) from user_sequences where sequence_name = upper(:n$s)', [AObjectName])) = '0' then begin
      Result := True;
      Exit;
    end;
    Result := ExecRawSql('drop sequence ' + AObjectName, ErrMsg);
  end
  else if SameText(ADef.ObjType, 'index') then begin
    if VarToStr(Q.QLoadValue('select count(*) from user_indexes where index_name = upper(:n$s)', [AObjectName])) = '0' then begin
      Result := True;
      Exit;
    end;
    Result := ExecRawSql('drop index ' + AObjectName, ErrMsg);
  end
  else if SameText(ADef.ObjType, 'constraint') then begin
    if ADef.TableName = '' then begin
      ErrMsg := 'не удалось определить таблицу для констрейнта "' + AObjectName + '"';
      Exit;
    end;
    if VarToStr(Q.QLoadValue('select count(*) from user_constraints where constraint_name = upper(:n$s)', [AObjectName])) = '0' then begin
      Result := True;
      Exit;
    end;
    Result := ExecRawSql('alter table ' + ADef.TableName + ' drop constraint ' + AObjectName, ErrMsg);
  end
  else
    ErrMsg := 'удаление объектов типа "' + ADef.ObjType + '" не поддерживается';
end;

{------------------------------------------------------------------------------------------}

function RebuildAndLog(const AObjectName: string; const AAllFiles: TStringDynArray; ALog: TStrings): Boolean;
var
  ADef: TSqlObjectDef;
  ErrMsg: string;
begin
  Result := False;
  if not FindObjectDefinition(AAllFiles, AObjectName, ADef) then begin
    ALog.Add(FormatDateTime('hh:nn:ss', Now) + '  ОШИБКА: !rebuild ' + AObjectName + ' -- определение объекта не найдено ни в одном файле');
    Exit;
  end;
  Result := RebuildObject(ADef, ErrMsg);
  if Result then
    ALog.Add(FormatDateTime('hh:nn:ss', Now) + '  OK: !rebuild ' + AObjectName + ' (' + ADef.ObjType + ', из файла ' + ExtractFileName(ADef.SourceFile) + ')')
  else
    ALog.Add(FormatDateTime('hh:nn:ss', Now) + '  ОШИБКА: !rebuild ' + AObjectName + ' -- ' + ErrMsg);
end;

function DropAndLog(const AObjectName: string; const AAllFiles: TStringDynArray; ALog: TStrings): Boolean;
var
  ErrMsg: string;
begin
  Result := DropObjectByName(AAllFiles, AObjectName, ErrMsg);
  if Result then begin
    ALog.Add(FormatDateTime('hh:nn:ss', Now) + '  OK: !drop ' + AObjectName);
    //проставим --!- рядом с именем объекта в тексте (если еще не проставлен) - чтобы уборка
    //"удалить из файла удаленные объекты" тоже увидела этот объект как уже удаленный из бд
    MarkObjectDroppedInFiles(AAllFiles, AObjectName);
  end
  else
    ALog.Add(FormatDateTime('hh:nn:ss', Now) + '  ОШИБКА: !drop ' + AObjectName + ' -- ' + ErrMsg);
end;

function ExecuteStatements(const AStatements: TStringDynArray; const AAllFiles: TStringDynArray; ALog: TStrings; var AAborted: Boolean): Integer;
//выполняет операторы по порядку (обычные sql либо !rebuild/!drop);
//при ошибке показывает диалог с вопросом "продолжить?" - при ответе "нет" AAborted:=True и выполнение прерывается
var
  i: Integer;
  Stmt, TrimmedStmt, LowerStmt, ErrMsg, Preview, ObjName: string;
  Ok: Boolean;
begin
  Result := 0;
  for i := 0 to High(AStatements) do begin
    if AAborted then
      Break;
    Stmt := AStatements[i];
    TrimmedStmt := Trim(Stmt);
    LowerStmt := LowerCase(TrimmedStmt);
    Preview := TrimmedStmt;
    if Length(Preview) > 150 then
      Preview := Copy(Preview, 1, 150) + '...';

    if Pos('!rebuild', LowerStmt) = 1 then begin
      ObjName := Trim(Copy(TrimmedStmt, Length('!rebuild') + 1, MaxInt));
      Ok := RebuildAndLog(ObjName, AAllFiles, ALog);
      ErrMsg := 'см. лог';
    end
    else if Pos('!drop', LowerStmt) = 1 then begin
      ObjName := Trim(Copy(TrimmedStmt, Length('!drop') + 1, MaxInt));
      Ok := DropAndLog(ObjName, AAllFiles, ALog);
      ErrMsg := 'см. лог';
    end
    else begin
      Ok := ExecRawSql(Stmt, ErrMsg);
      if Ok then
        ALog.Add(FormatDateTime('hh:nn:ss', Now) + '  OK: ' + Preview)
      else
        ALog.Add(FormatDateTime('hh:nn:ss', Now) + '  ОШИБКА: ' + Preview + ' -- ' + ErrMsg);
    end;

    if Ok then
      Inc(Result)
    else begin
      if MyQuestionMessage('Ошибка при выполнении оператора:'#13#10 + Preview + #13#10#13#10 + ErrMsg + #13#10#13#10'Продолжить выполнение?') <> mrYes then
        AAborted := True;
    end;
  end;
end;

{------------------------------------------------------------------------------------------}

function SyncTableComments(const Tables: TSqlTableInfoArray; ALog: TStrings): Integer;
//устанавливает/обновляет/удаляет комментарии к таблицам и столбцам по результатам разбора файла;
//ошибки не прерывают обработку, только пишутся в лог
var
  i, j: Integer;
  ExistsCnt, CurComment: Variant;
  ErrMsg, NewComment: string;
begin
  Result := 0;
  for i := 0 to High(Tables) do begin
    if Tables[i].HasComment then begin
      CurComment := Q.QLoadValue('select comments from user_tab_comments where table_name = upper(:t$s)', [Tables[i].TableName]);
      if Trim(VarToStr(CurComment)) <> Trim(Tables[i].Comment) then begin
        if ExecRawSql('comment on table ' + Tables[i].TableName + ' is ''' + EscapeSqlLiteral(Tables[i].Comment) + '''', ErrMsg) then
          Inc(Result)
        else
          ALog.Add('ОШИБКА (комментарий к таблице ' + Tables[i].TableName + '): ' + ErrMsg);
      end;
    end;

    for j := 0 to High(Tables[i].Columns) do begin
      ExistsCnt := Q.QLoadValue(
        'select count(*) from user_tab_columns where table_name = upper(:t$s) and column_name = upper(:c$s)',
        [Tables[i].TableName, Tables[i].Columns[j].ColName]);
      if VarToStr(ExistsCnt) = '0' then
        Continue;
      CurComment := Q.QLoadValue(
        'select comments from user_col_comments where table_name = upper(:t$s) and column_name = upper(:c$s)',
        [Tables[i].TableName, Tables[i].Columns[j].ColName]);
      NewComment := Tables[i].Columns[j].Comment;
      if Trim(VarToStr(CurComment)) <> Trim(NewComment) then begin
        if ExecRawSql('comment on column ' + Tables[i].TableName + '.' + Tables[i].Columns[j].ColName + ' is ''' + EscapeSqlLiteral(NewComment) + '''', ErrMsg) then
          Inc(Result)
        else
          ALog.Add('ОШИБКА (комментарий к столбцу ' + Tables[i].TableName + '.' + Tables[i].Columns[j].ColName + '): ' + ErrMsg);
      end;
    end;
  end;
end;

{------------------------------------------------------------------------------------------}
{  теги --!+/--!- на столбцах и объектах - проверка существования, выполнение              }
{------------------------------------------------------------------------------------------}

function TableExistsInDb(const ATableName: string): Boolean;
begin
  Result := VarToStr(Q.QLoadValue('select count(*) from user_tables where table_name = upper(:t$s)', [ATableName])) <> '0';
end;

function MarkLineTagProcessed(var AText: string; ALinePos: Integer; AKindChar: Char): Boolean;
//строка, начинающаяся с ALinePos, должна заканчиваться (после отбрасывания пробелов справа)
//на --!<AKindChar> (взведенный тег, ровно два дефиса) - меняет "!" на "$" прямо на месте
//(длина текста не меняется, все прочие позиции LinePos остаются в силе). используется сразу
//после успешного выполнения тега - на этот момент строка гарантированно имеет именно такой
//вид (тег был перед этим найден через ExtractLineTag/ScanFileObjectTags)
var
  LineEnd, i: Integer;
begin
  Result := False;
  LineEnd := ALinePos;
  while (LineEnd <= Length(AText)) and (AText[LineEnd] <> #10) and (AText[LineEnd] <> #13) do
    Inc(LineEnd);
  i := LineEnd - 1;
  while (i >= ALinePos) and CharInSet(AText[i], [' ', #9]) do
    Dec(i);
  if (i < ALinePos) or (AText[i] <> AKindChar) then
    Exit; //не должно случаться, но на всякий случай не падаем
  if (i - 1 < ALinePos) or (AText[i - 1] <> '!') then
    Exit;
  if (i - 2 < ALinePos) or (AText[i - 2] <> '-') or (AText[i - 3] <> '-') then
    Exit;
  AText[i - 1] := '$';
  Result := True;
end;

procedure MarkGoBlockLineProcessed(var AText: string; ALinePos: Integer);
//строка, начинающаяся с ALinePos (возможно, с ведущими пробелами), должна начинаться на
//"--!go" - меняет "!" на "$" прямо на месте (--!go begin/end -> --$go begin/end)
var
  p: Integer;
begin
  p := ALinePos;
  while (p <= Length(AText)) and CharInSet(AText[p], [' ', #9]) do
    Inc(p);
  if (p + 2 <= Length(AText)) and (AText[p] = '-') and (AText[p + 1] = '-') and (AText[p + 2] = '!') then
    AText[p + 2] := '$';
end;

function ExecColumnAdd(const ATableName: string; const ACol: TSqlColumnComment; out ErrMsg: string): Boolean;
begin
  ErrMsg := '';
  if VarToStr(Q.QLoadValue('select count(*) from user_tab_columns where table_name = upper(:t$s) and column_name = upper(:c$s)',
    [ATableName, ACol.ColName])) <> '0' then begin
    Result := True; //уже существует - тег уже фактически выполнен
    Exit;
  end;
  if ACol.ColDef = '' then begin
    Result := False;
    ErrMsg := 'не удалось определить полное определение столбца';
    Exit;
  end;
  Result := ExecRawSql('alter table ' + ATableName + ' add (' + ACol.ColDef + ')', ErrMsg);
end;

function ExecColumnDrop(const ATableName, AColName: string; out ErrMsg: string): Boolean;
begin
  ErrMsg := '';
  if VarToStr(Q.QLoadValue('select count(*) from user_tab_columns where table_name = upper(:t$s) and column_name = upper(:c$s)',
    [ATableName, AColName])) = '0' then begin
    Result := True; //уже отсутствует - тег уже фактически выполнен
    Exit;
  end;
  Result := ExecRawSql('alter table ' + ATableName + ' drop column ' + AColName, ErrMsg);
end;

function ExecObjectTag(const ATag: TSqlObjectTagInfo; const AAllFiles: TStringDynArray; out ErrMsg: string): Boolean;
var
  ADef: TSqlObjectDef;
begin
  Result := False;
  ErrMsg := '';
  if ATag.Tag = '+' then begin
    if SameText(ATag.ObjType, 'table') then begin
      if TableExistsInDb(ATag.ObjectName) then begin
        Result := True; //таблица уже есть - дропать существующую для пересоздания не будем (данные)
        Exit;
      end;
      if not FindObjectDefinition(AAllFiles, ATag.ObjectName, ADef) then begin
        ErrMsg := 'определение таблицы "' + ATag.ObjectName + '" не найдено ни в одном файле';
        Exit;
      end;
      Result := ExecRawSql(ADef.DefText, ErrMsg);
    end
    else begin
      if not FindObjectDefinition(AAllFiles, ATag.ObjectName, ADef) then begin
        ErrMsg := 'определение объекта "' + ATag.ObjectName + '" не найдено ни в одном файле';
        Exit;
      end;
      Result := RebuildObject(ADef, ErrMsg);
    end;
  end
  else begin //'-'
    if SameText(ATag.ObjType, 'table') then begin
      if not TableExistsInDb(ATag.ObjectName) then begin
        Result := True; //уже удалена
        Exit;
      end;
      Result := ExecRawSql('drop table ' + ATag.ObjectName + ' cascade constraints', ErrMsg);
    end
    else
      Result := DropObjectByName(AAllFiles, ATag.ObjectName, ErrMsg);
  end;
end;

procedure CountPendingTags(const AFiles: TStringDynArray; out AObjAdd, AColAdd, AObjDel, AColDel, AGoBlocks: Integer);
var
  i, j, k: Integer;
  Text, ErrMsg: string;
  Tables: TSqlTableInfoArray;
  ObjTags: TSqlObjectTagInfoArray;
begin
  AObjAdd := 0; AColAdd := 0; AObjDel := 0; AColDel := 0; AGoBlocks := 0;
  for i := 0 to High(AFiles) do begin
    Text := LoadSqlFileText(AFiles[i], ErrMsg);
    if ErrMsg <> '' then
      Continue;
    Text := StripBlockComments(Text);
    AGoBlocks := AGoBlocks + Length(ExtractGoBlocks(Text));

    if ParseFileTables(AFiles[i], Tables, ErrMsg) then
      for j := 0 to High(Tables) do
        for k := 0 to High(Tables[j].Columns) do
          if Tables[j].Columns[k].Tag = '+' then
            Inc(AColAdd)
          else if Tables[j].Columns[k].Tag = '-' then
            Inc(AColDel);

    ObjTags := ScanFileObjectTags(Text, AFiles[i]);
    for j := 0 to High(ObjTags) do
      if ObjTags[j].Tag = '+' then
        Inc(AObjAdd)
      else if ObjTags[j].Tag = '-' then
        Inc(AObjDel);
  end;
end;

function ProcessFileTags(const AFileName: string; const AAllFiles: TStringDynArray; ALog: TStrings; var AAborted: Boolean): Integer;
//выполняет взведенные ("!") теги --!+/--!- на столбцах и объектах одного файла: сначала
//добавление/пересоздание объектов (--!+), затем добавление столбцов (--!+), затем удаление
//столбцов (--!-), затем удаление объектов (--!-). при ошибке - как и для --!go блоков -
//диалог Продолжить/Отменить. каждый успешно выполненный тег сразу же помечается обработанным
//(--!+/--!- -> --$+/--$-) прямо в тексте файла - это позволяет повторный запуск того же файла
//пропустить уже сделанное и, если что-то не выполнилось, продолжить именно с этого места.
var
  RawText, StrippedText, ErrMsg: string;
  Tables: TSqlTableInfoArray;
  ObjTags: TSqlObjectTagInfoArray;
  i, j: Integer;
  Ok, Changed: Boolean;
begin
  Result := 0;
  Changed := False;
  if not ParseFileTables(AFileName, Tables, ErrMsg) then begin
    ALog.Add('ОШИБКА разбора файла (теги столбцов): ' + ErrMsg);
    Tables := nil;
  end;
  RawText := LoadSqlFileText(AFileName, ErrMsg);
  if ErrMsg = '' then
    StrippedText := StripBlockComments(RawText)
  else begin
    RawText := '';
    StrippedText := '';
  end;
  ObjTags := ScanFileObjectTags(StrippedText, AFileName);

  for i := 0 to High(ObjTags) do begin
    if AAborted then
      Break;
    if ObjTags[i].Tag <> '+' then
      Continue;
    Ok := ExecObjectTag(ObjTags[i], AAllFiles, ErrMsg);
    if Ok then begin
      ALog.Add(FormatDateTime('hh:nn:ss', Now) + '  OK: --!+ ' + ObjTags[i].ObjType + ' ' + ObjTags[i].ObjectName);
      Inc(Result);
      if MarkLineTagProcessed(RawText, ObjTags[i].LinePos, '+') then
        Changed := True;
    end
    else begin
      ALog.Add(FormatDateTime('hh:nn:ss', Now) + '  ОШИБКА: --!+ ' + ObjTags[i].ObjType + ' ' + ObjTags[i].ObjectName + ' -- ' + ErrMsg);
      if MyQuestionMessage('Ошибка при создании/пересоздании ' + ObjTags[i].ObjType + ' "' + ObjTags[i].ObjectName + '":'#13#10 +
        ErrMsg + #13#10#13#10'Продолжить выполнение?') <> mrYes then
        AAborted := True;
    end;
  end;

  for i := 0 to High(Tables) do begin
    if AAborted then Break;
    for j := 0 to High(Tables[i].Columns) do begin
      if AAborted then Break;
      if Tables[i].Columns[j].Tag <> '+' then
        Continue;
      Ok := ExecColumnAdd(Tables[i].TableName, Tables[i].Columns[j], ErrMsg);
      if Ok then begin
        ALog.Add(FormatDateTime('hh:nn:ss', Now) + '  OK: --!+ столбец ' + Tables[i].TableName + '.' + Tables[i].Columns[j].ColName);
        Inc(Result);
        if MarkLineTagProcessed(RawText, Tables[i].Columns[j].LinePos, '+') then
          Changed := True;
      end
      else begin
        ALog.Add(FormatDateTime('hh:nn:ss', Now) + '  ОШИБКА: --!+ столбец ' + Tables[i].TableName + '.' + Tables[i].Columns[j].ColName + ' -- ' + ErrMsg);
        if MyQuestionMessage('Ошибка при добавлении столбца "' + Tables[i].TableName + '.' + Tables[i].Columns[j].ColName + '":'#13#10 +
          ErrMsg + #13#10#13#10'Продолжить выполнение?') <> mrYes then
          AAborted := True;
      end;
    end;
  end;

  for i := 0 to High(Tables) do begin
    if AAborted then Break;
    for j := 0 to High(Tables[i].Columns) do begin
      if AAborted then Break;
      if Tables[i].Columns[j].Tag <> '-' then
        Continue;
      Ok := ExecColumnDrop(Tables[i].TableName, Tables[i].Columns[j].ColName, ErrMsg);
      if Ok then begin
        ALog.Add(FormatDateTime('hh:nn:ss', Now) + '  OK: --!- столбец ' + Tables[i].TableName + '.' + Tables[i].Columns[j].ColName);
        Inc(Result);
        if MarkLineTagProcessed(RawText, Tables[i].Columns[j].LinePos, '-') then
          Changed := True;
      end
      else begin
        ALog.Add(FormatDateTime('hh:nn:ss', Now) + '  ОШИБКА: --!- столбец ' + Tables[i].TableName + '.' + Tables[i].Columns[j].ColName + ' -- ' + ErrMsg);
        if MyQuestionMessage('Ошибка при удалении столбца "' + Tables[i].TableName + '.' + Tables[i].Columns[j].ColName + '":'#13#10 +
          ErrMsg + #13#10#13#10'Продолжить выполнение?') <> mrYes then
          AAborted := True;
      end;
    end;
  end;

  for i := 0 to High(ObjTags) do begin
    if AAborted then Break;
    if ObjTags[i].Tag <> '-' then
      Continue;
    Ok := ExecObjectTag(ObjTags[i], AAllFiles, ErrMsg);
    if Ok then begin
      ALog.Add(FormatDateTime('hh:nn:ss', Now) + '  OK: --!- ' + ObjTags[i].ObjType + ' ' + ObjTags[i].ObjectName);
      Inc(Result);
      if MarkLineTagProcessed(RawText, ObjTags[i].LinePos, '-') then
        Changed := True;
    end
    else begin
      ALog.Add(FormatDateTime('hh:nn:ss', Now) + '  ОШИБКА: --!- ' + ObjTags[i].ObjType + ' ' + ObjTags[i].ObjectName + ' -- ' + ErrMsg);
      if MyQuestionMessage('Ошибка при удалении ' + ObjTags[i].ObjType + ' "' + ObjTags[i].ObjectName + '":'#13#10 +
        ErrMsg + #13#10#13#10'Продолжить выполнение?') <> mrYes then
        AAborted := True;
    end;
  end;

  if Changed then begin
    if not SaveSqlFileText(AFileName, RawText, ErrMsg) then
      ALog.Add('ОШИБКА сохранения файла ' + ExtractFileName(AFileName) + ' (пометка обработанных тегов): ' + ErrMsg);
  end;
end;

function MarkObjectDroppedInFiles(const AFiles: TStringDynArray; const AObjectName: string): Boolean;
//после успешного классического !drop object_name (минуя тег --!-) - находит определение
//объекта и, если строка его заголовка еще не помечена никаким тегом/маркером, приписывает в
//конец строки финальный маркер --$dropped (drop уже реально выполнен - взведенное состояние
//тут не нужно, отмечаем сразу как "готово, можно удалить из файла")
var
  ADef: TSqlObjectDef;
  ErrMsg, Text, StrippedText, Pattern, LineText: string;
  RE: TRegEx;
  M: TMatch;
  LineStartPos, LineEndPos: Integer;
begin
  Result := False;
  if not FindObjectDefinition(AFiles, AObjectName, ADef) then
    Exit;
  Text := LoadSqlFileText(ADef.SourceFile, ErrMsg);
  if ErrMsg <> '' then
    Exit;
  StrippedText := StripBlockComments(Text);

  if SameText(ADef.ObjType, 'table') then Pattern := 'create\s+table\s+'
  else if SameText(ADef.ObjType, 'view') then Pattern := 'create\s+(?:or\s+replace\s+)?view\s+'
  else if SameText(ADef.ObjType, 'function') then Pattern := 'create\s+(?:or\s+replace\s+)?function\s+'
  else if SameText(ADef.ObjType, 'procedure') then Pattern := 'create\s+(?:or\s+replace\s+)?procedure\s+'
  else if SameText(ADef.ObjType, 'trigger') then Pattern := 'create\s+(?:or\s+replace\s+)?trigger\s+'
  else if SameText(ADef.ObjType, 'sequence') then Pattern := 'create\s+sequence\s+'
  else if SameText(ADef.ObjType, 'index') then Pattern := 'create\s+(?:unique\s+)?index\s+'
  else if SameText(ADef.ObjType, 'constraint') then Pattern := 'alter\s+table\s+\S+\s+add\s+constraint\s+'
  else Exit;
  Pattern := Pattern + TRegEx.Escape(AObjectName) + '\b';

  RE := TRegEx.Create(Pattern, [roIgnoreCase]);
  M := RE.Match(StrippedText);
  if not M.Success then
    Exit;

  LineStartPos := M.Index;
  while (LineStartPos > 1) and (Text[LineStartPos - 1] <> #10) do
    Dec(LineStartPos);
  LineEndPos := M.Index;
  while (LineEndPos <= Length(Text)) and (Text[LineEndPos] <> #10) and (Text[LineEndPos] <> #13) do
    Inc(LineEndPos);

  LineText := TrimRight(Copy(Text, LineStartPos, LineEndPos - LineStartPos));
  //если строка уже несет любой маркер (взведенный, обработанный или финальный) - не дублируем
  if (Length(LineText) >= 4) and CharInSet(LineText[Length(LineText)], ['+', '-'])
    and CharInSet(LineText[Length(LineText) - 1], ['!', '$']) and (LineText[Length(LineText) - 2] = '-') and (LineText[Length(LineText) - 3] = '-') then begin
    Result := True;
    Exit;
  end;
  if (Length(LineText) >= 10) and SameText(Copy(LineText, Length(LineText) - 9, 10), '--$dropped') then begin
    Result := True;
    Exit;
  end;

  Text := Copy(Text, 1, LineEndPos - 1) + ' --$dropped' + Copy(Text, LineEndPos, MaxInt);
  Result := SaveSqlFileText(ADef.SourceFile, Text, ErrMsg);
end;

{------------------------------------------------------------------------------------------}
{  очистка текста файлов                                                                    }
{------------------------------------------------------------------------------------------}

function SaveSqlFileText(const AFileName, AText: string; out ErrMsg: string): Boolean;
begin
  Result := False;
  ErrMsg := '';
  try
    TFile.WriteAllText(AFileName, AText, TEncoding.GetEncoding(1251));
    Result := True;
  except
    on E: Exception do
      ErrMsg := 'не удалось сохранить файл "' + AFileName + '": ' + E.Message;
  end;
end;

function RemoveAttentionMarkers(const AFileName: string; out ARemoved: Integer; out ErrMsg: string): Boolean;
//убирает --!!! из строк (вне блочных комментариев); если после этого строка пустая - строка
//удаляется целиком, если оставалось что-то еще - остается
var
  Text, StrippedText: string;
  Lines, StrippedLines, ResLines: TStringList;
  i, p: Integer;
  Ln, TrimmedStripped, Rest: string;
begin
  Result := False;
  ARemoved := 0;
  Text := LoadSqlFileText(AFileName, ErrMsg);
  if ErrMsg <> '' then
    Exit;
  StrippedText := StripBlockComments(Text);
  Lines := TStringList.Create;
  StrippedLines := TStringList.Create;
  ResLines := TStringList.Create;
  try
    Lines.Text := Text;
    StrippedLines.Text := StrippedText;
    for i := 0 to Lines.Count - 1 do begin
      Ln := Lines[i];
      TrimmedStripped := Trim(StrippedLines[i]);
      if Copy(TrimmedStripped, 1, 5) = '--!!!' then begin
        Inc(ARemoved);
        p := Pos('--!!!', StrippedLines[i]);
        Rest := Trim(Copy(Ln, 1, p - 1) + Copy(Ln, p + 5, MaxInt));
        if Rest <> '' then
          ResLines.Add(Rest);
      end
      else
        ResLines.Add(Ln);
    end;
    if ARemoved = 0 then begin
      Result := True;
      Exit;
    end;
    Result := SaveSqlFileText(AFileName, ResLines.Text, ErrMsg);
  finally
    Lines.Free;
    StrippedLines.Free;
    ResLines.Free;
  end;
end;

function DisableGoBlocksInFile(const AFileName: string; out ADisabled: Integer; out ErrMsg: string): Boolean;
//заменяет активные --!go begin на ---!go begin (по принятой конвенции трех дефисов - отключено).
//--$go begin/--$completed begin (уже не взведенные) не трогает - их отключать незачем, они и
//так не выполняются
var
  Text, StrippedText: string;
  Lines, StrippedLines, ResLines: TStringList;
  i, p: Integer;
  Ln: string;
begin
  Result := False;
  ADisabled := 0;
  Text := LoadSqlFileText(AFileName, ErrMsg);
  if ErrMsg <> '' then
    Exit;
  StrippedText := StripBlockComments(Text);
  Lines := TStringList.Create;
  StrippedLines := TStringList.Create;
  ResLines := TStringList.Create;
  try
    Lines.Text := Text;
    StrippedLines.Text := StrippedText;
    for i := 0 to Lines.Count - 1 do begin
      Ln := Lines[i];
      if SameText(Trim(StrippedLines[i]), '--!go begin') then begin
        Inc(ADisabled);
        p := Pos('--!GO BEGIN', UpperCase(Ln));
        if p > 0 then
          Ln := Copy(Ln, 1, p - 1) + '-' + Copy(Ln, p, MaxInt);
      end;
      ResLines.Add(Ln);
    end;
    if ADisabled = 0 then begin
      Result := True;
      Exit;
    end;
    Result := SaveSqlFileText(AFileName, ResLines.Text, ErrMsg);
  finally
    Lines.Free;
    StrippedLines.Free;
    ResLines.Free;
  end;
end;

function RestoreActionTriggers(const AFileName: string; out ARestored: Integer; out ErrMsg: string): Boolean;
//переводит уже обработанные ("$") теги обратно во взведенное состояние ("!"):
//--$+/--$- -> --!+/--!-, --$go begin/--$go end -> --!go begin/--!go end. финальные метки
//(--$dropped, --$completed begin) не трогает - они уже не подлежат восстановлению.
var
  Text, StrippedText: string;
  Lines, StrippedLines, ResLines: TStringList;
  i, p: Integer;
  Ln, TrimmedStripped, TestLn: string;
  Tag: Char;
begin
  Result := False;
  ARestored := 0;
  Text := LoadSqlFileText(AFileName, ErrMsg);
  if ErrMsg <> '' then
    Exit;
  StrippedText := StripBlockComments(Text);
  Lines := TStringList.Create;
  StrippedLines := TStringList.Create;
  ResLines := TStringList.Create;
  try
    Lines.Text := Text;
    StrippedLines.Text := StrippedText;
    for i := 0 to Lines.Count - 1 do begin
      Ln := Lines[i];
      TrimmedStripped := Trim(StrippedLines[i]);
      if SameText(TrimmedStripped, '--$go begin') then begin
        Inc(ARestored);
        p := Pos('--$GO BEGIN', UpperCase(Ln));
        if p > 0 then
          Ln := Copy(Ln, 1, p - 1) + '--!go begin' + Copy(Ln, p + 11, MaxInt);
      end
      else if SameText(TrimmedStripped, '--$go end') then begin
        Inc(ARestored);
        p := Pos('--$GO END', UpperCase(Ln));
        if p > 0 then
          Ln := Copy(Ln, 1, p - 1) + '--!go end' + Copy(Ln, p + 9, MaxInt);
      end
      else begin
        TestLn := StrippedLines[i];
        Tag := ExtractLineTagEx(TestLn, '$');
        if Tag <> #0 then begin
          //строка гарантированно заканчивается (после хвостовых пробелов) на --$+ или --$-
          Ln := TrimRight(Ln);
          if (Length(Ln) >= 4) and (Ln[Length(Ln)] = Tag) and (Ln[Length(Ln) - 1] = '$') then begin
            Ln[Length(Ln) - 1] := '!';
            Inc(ARestored);
          end;
        end;
      end;
      ResLines.Add(Ln);
    end;
    if ARestored = 0 then begin
      Result := True;
      Exit;
    end;
    Result := SaveSqlFileText(AFileName, ResLines.Text, ErrMsg);
  finally
    Lines.Free;
    StrippedLines.Free;
    ResLines.Free;
  end;
end;

function RemoveActionTriggers(const AFileName: string; out ARemoved: Integer; out ErrMsg: string): Boolean;
//переводит уже обработанные ("$") теги в финальное, необратимое состояние:
//--$+/--$- (оба вида) -> --$dropped, --$go begin -> --$completed begin (--$go end не
//трогается - см. обсуждение с пользователем, значима только строка begin). после этого шага
//сами строки/блоки с финальными метками упдатером больше не разбираются - пользователь
//находит их (F5 в просмотрщике) и удаляет вручную.
var
  Text, StrippedText: string;
  Lines, StrippedLines, ResLines: TStringList;
  i, p: Integer;
  Ln, TrimmedStripped, TestLn: string;
  Tag: Char;
begin
  Result := False;
  ARemoved := 0;
  Text := LoadSqlFileText(AFileName, ErrMsg);
  if ErrMsg <> '' then
    Exit;
  StrippedText := StripBlockComments(Text);
  Lines := TStringList.Create;
  StrippedLines := TStringList.Create;
  ResLines := TStringList.Create;
  try
    Lines.Text := Text;
    StrippedLines.Text := StrippedText;
    for i := 0 to Lines.Count - 1 do begin
      Ln := Lines[i];
      TrimmedStripped := Trim(StrippedLines[i]);
      if SameText(TrimmedStripped, '--$go begin') then begin
        Inc(ARemoved);
        p := Pos('--$GO BEGIN', UpperCase(Ln));
        if p > 0 then
          Ln := Copy(Ln, 1, p - 1) + '--$completed begin' + Copy(Ln, p + 11, MaxInt);
      end
      else begin
        TestLn := StrippedLines[i];
        Tag := ExtractLineTagEx(TestLn, '$');
        if Tag <> #0 then begin
          Ln := TrimRight(Ln);
          if (Length(Ln) >= 4) and (Ln[Length(Ln)] = Tag) and (Ln[Length(Ln) - 1] = '$') then begin
            Ln := Copy(Ln, 1, Length(Ln) - 4) + '--$dropped';
            Inc(ARemoved);
          end;
        end;
      end;
      ResLines.Add(Ln);
    end;
    if ARemoved = 0 then begin
      Result := True;
      Exit;
    end;
    Result := SaveSqlFileText(AFileName, ResLines.Text, ErrMsg);
  finally
    Lines.Free;
    StrippedLines.Free;
    ResLines.Free;
  end;
end;

{------------------------------------------------------------------------------------------}

function ProcessFileGoBlocks(const AFileName: string; const AAllFiles: TStringDynArray; ALog: TStrings; var AAborted: Boolean): Integer;
//обрабатывает все взведенные --!go begin/--!go end блоки внутри файла; блок, выполненный без
//прерывания (AAborted), сразу помечается обработанным (--!go begin/end -> --$go begin/end -
//позиции остальных блоков не сбиваются, так как замена "!"->"$" не меняет длину текста)
var
  RawText, StrippedText, ErrMsg: string;
  Blocks: TSqlGoBlockArray;
  Stmts: TStringDynArray;
  i: Integer;
  Changed: Boolean;
begin
  Result := 0;
  Changed := False;
  RawText := LoadSqlFileText(AFileName, ErrMsg);
  if ErrMsg <> '' then begin
    ALog.Add('ОШИБКА чтения файла ' + ExtractFileName(AFileName) + ': ' + ErrMsg);
    Exit;
  end;
  StrippedText := StripBlockComments(RawText);
  Blocks := ExtractGoBlocksEx(StrippedText);
  for i := 0 to High(Blocks) do begin
    if AAborted then
      Break;
    Stmts := SplitStatements(Blocks[i].Content);
    Result := Result + ExecuteStatements(Stmts, AAllFiles, ALog, AAborted);
    if not AAborted then begin
      MarkGoBlockLineProcessed(RawText, Blocks[i].BeginLinePos);
      MarkGoBlockLineProcessed(RawText, Blocks[i].EndLinePos);
      Changed := True;
    end;
  end;
  if Changed then begin
    if not SaveSqlFileText(AFileName, RawText, ErrMsg) then
      ALog.Add('ОШИБКА сохранения файла ' + ExtractFileName(AFileName) + ' (пометка обработанных go-блоков): ' + ErrMsg);
  end;
end;

function ProcessSqlScriptFile(const AFileName: string; const AAllFiles: TStringDynArray; ALog: TStrings; var AAborted: Boolean): Integer;
//выполняет файл целиком как обычный скрипт, без разбора тегов/комментариев (используется для
//"Действия после импорта" - _after_import.sql; GO.sql теперь обрабатывается тем же движком,
//что и обычные файлы - см. ParseFileTables+ProcessFileTags+ProcessFileGoBlocks в RunFullProcess)
var
  Text, ErrMsg: string;
  Stmts: TStringDynArray;
begin
  Result := 0;
  Text := LoadSqlFileText(AFileName, ErrMsg);
  if ErrMsg <> '' then begin
    ALog.Add('ОШИБКА чтения файла ' + ExtractFileName(AFileName) + ': ' + ErrMsg);
    Exit;
  end;
  Text := StripBlockComments(Text);
  Stmts := SplitStatements(Text);
  Result := ExecuteStatements(Stmts, AAllFiles, ALog, AAborted);
end;

{------------------------------------------------------------------------------------------}

function WriteLogFile(const ALogFolder: string; const ALog: TStrings): string;
begin
  ForceDirectories(ALogFolder);
  Result := IncludeTrailingPathDelimiter(ALogFolder) + FormatDateTime('yyyy-mm-dd_hh-nn-ss', Now) + '.log';
  ALog.SaveToFile(Result, TEncoding.GetEncoding(1251));
end;

end.
