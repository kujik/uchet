{
Синхронизация комментариев к столбцам таблиц из текста SQL-скриптов в БД.

В скриптах SQL (каталог SQL, файлы d_*.sql) комментарии к полям таблиц пишутся справа
от поля в скрипте create table, и в БД не устанавливаются (comment on column не выполняется).

Форма разбирает текст выбранного файла, находит в нем блоки create table ... (...),
извлекает из них пары "поле / комментарий", проверяет существование таблицы и поля в БД
(user_tab_columns) и позволяет установить/обновить комментарии к столбцам через comment on column.

В обработку попадают только строки внутри блока create table, не являющиеся строками
table-level constraint (constraint ...), и только те, где справа от определения поля есть
комментарий вида --текст.
}

unit uFrmXAdmSqlCommentSync;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, IOUtils, RegularExpressions,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh
  ;

type
  TSqlCommentItem = record
    TableName: string;     //имя таблицы (без схемы), в нижнем регистре
    ColumnName: string;    //имя поля, в нижнем регистре
    CommentFile: string;   //комментарий, разобранный из текста скрипта
    ExistsInDb: Boolean;   //таблица и поле найдены в бд (user_tab_columns)
    CommentDb: string;     //текущий комментарий к полю в бд (user_col_comments), если есть
  end;
  TSqlCommentItemArray = array of TSqlCommentItem;

  TFrmXAdmSqlCommentSync = class(TFrmBasicGrid2)
    bt_SelectFile: TButton;
    edt_FileName: TEdit;
    bt_Parse: TButton;
    bt_Apply: TButton;
    OpenDialog1: TOpenDialog;
    procedure bt_SelectFileClick(Sender: TObject);
    procedure bt_ParseClick(Sender: TObject);
    procedure bt_ApplyClick(Sender: TObject);
  private
    FItems: TSqlCommentItemArray;
    function  ParseFile(const AFileName: string; out Items: TSqlCommentItemArray; out ErrMsg: string): Boolean;
    procedure CheckDbAndFillGrid;
    procedure ApplyComments;
  protected
    function  PrepareForm: Boolean; override;
  public
  end;

var
  FrmXAdmSqlCommentSync: TFrmXAdmSqlCommentSync;

implementation

{$R *.dfm}

uses
  uDB;

const
  //допустимые символы в имени поля/таблицы (для выделения идентификатора из начала строки)
  cIdentChars = ['a'..'z', 'A'..'Z', '0'..'9', '_', '$', '#'];

{-------------------------------------------------------------------------------------------------}

function TFrmXAdmSqlCommentSync.PrepareForm: Boolean;
begin
  Caption := 'Синхронизация комментариев к столбцам с БД';
  Frg1.Opt.SetFields([
    ['num$i','№','40'],
    ['tablename$s','Таблица','200'],
    ['columnname$s','Поле','200'],
    ['commentfile$s','Комментарий в файле','350;w'],
    ['existsindb$s','В БД','50'],
    ['commentdb$s','Текущий комментарий в БД','350;w'],
    ['status$s','Статус','220;w']
  ]);
  Frg1.SetInitData([], '');
  Result := inherited;
  bt_Apply.Enabled := False;
end;

{-------------------------------------------------------------------------------------------------}
//поиск в тексте файла блоков create table (...) и разбор в них пар поле/комментарий

function TFrmXAdmSqlCommentSync.ParseFile(const AFileName: string; out Items: TSqlCommentItemArray; out ErrMsg: string): Boolean;
var
  Text: string;

  //находим позицию закрывающей скобки, парной открывающей на позиции StartPos (сама она - '(');
  //пропускаем строковые литералы и строчные комментарии, чтобы скобки внутри них не сбивали подсчет
  function FindMatchingParenEnd(StartPos: Integer): Integer;
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

  //выделяем комментарий (--текст) из строки, обрезая его от Line
  function ExtractComment(var Line: string): string;
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

  //первый идентификатор в начале строки (имя поля)
  function ExtractLeadIdent(const Line: string): string;
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

var
  Enc: TEncoding;
  RE: TRegEx;
  M: TMatch;
  TableName, Block, Ln, TrimmedLn, Comment, ColName: string;
  BlockStartPos, BlockEndPos, i: Integer;
  Lines: TStringList;
begin
  Result := False;
  ErrMsg := '';
  SetLength(Items, 0);

  if not TFile.Exists(AFileName) then begin
    ErrMsg := 'Файл не найден: ' + AFileName;
    Exit;
  end;

  try
    Enc := TEncoding.GetEncoding(1251);
    try
      Text := TFile.ReadAllText(AFileName, Enc);
    finally
      Enc.Free;
    end;
  except
    on E: Exception do begin
      ErrMsg := 'Не удалось прочитать файл: ' + E.Message;
      Exit;
    end;
  end;

  Lines := TStringList.Create;
  try
    RE := TRegEx.Create('create\s+table\s+([a-zA-Z0-9_\.\$#]+)\s*\(', [roIgnoreCase]);
    for M in RE.Matches(Text) do begin
      TableName := LowerCase(M.Groups[1].Value);
      if Pos('.', TableName) > 0 then
        TableName := Copy(TableName, Pos('.', TableName) + 1, MaxInt);

      //M.Index (1-based) указывает на начало совпадения, конец совпадения - открывающая скобка блока
      BlockStartPos := M.Index + Length(M.Value) - 1; //позиция самой '('
      BlockEndPos := FindMatchingParenEnd(BlockStartPos);
      if BlockEndPos = 0 then
        Continue; //не удалось найти парную скобку - нестандартный синтаксис, пропускаем

      Block := Copy(Text, BlockStartPos + 1, BlockEndPos - BlockStartPos - 1);

      Lines.Text := Block;
      for i := 0 to Lines.Count - 1 do begin
        Ln := Lines[i];
        TrimmedLn := Trim(Ln);
        if TrimmedLn = '' then
          Continue;
        if SameText(Copy(TrimmedLn, 1, 10), 'constraint') then
          Continue;
        Comment := ExtractComment(Ln);
        if Comment = '' then
          Continue;
        ColName := LowerCase(ExtractLeadIdent(Ln));
        if ColName = '' then
          Continue;
        SetLength(Items, Length(Items) + 1);
        Items[High(Items)].TableName := TableName;
        Items[High(Items)].ColumnName := ColName;
        Items[High(Items)].CommentFile := Comment;
      end;
    end;
    Result := True;
  finally
    Lines.Free;
  end;
end;

{-------------------------------------------------------------------------------------------------}
//проверяем существование таблицы/поля в бд и текущий комментарий к нему, заполняем грид

procedure TFrmXAdmSqlCommentSync.CheckDbAndFillGrid;
var
  i: Integer;
  ExistsCnt, CommentDb: Variant;
  Status: string;
begin
  Frg1.MemTableEh1.EmptyTable;
  for i := 0 to High(FItems) do begin
    ExistsCnt := Q.QLoadValue(
      'select count(*) from user_tab_columns where table_name = upper(:t$s) and column_name = upper(:c$s)',
      [FItems[i].TableName, FItems[i].ColumnName]);
    FItems[i].ExistsInDb := VarToStr(ExistsCnt) <> '0';

    CommentDb := Null;
    if FItems[i].ExistsInDb then
      CommentDb := Q.QLoadValue(
        'select comments from user_col_comments where table_name = upper(:t$s) and column_name = upper(:c$s)',
        [FItems[i].TableName, FItems[i].ColumnName]);
    FItems[i].CommentDb := VarToStr(CommentDb);

    if not FItems[i].ExistsInDb then
      Status := 'таблица/поле не найдены в БД'
    else if Trim(FItems[i].CommentDb) = Trim(FItems[i].CommentFile) then
      Status := 'совпадает, изменение не требуется'
    else if Trim(FItems[i].CommentDb) = '' then
      Status := 'будет установлен'
    else
      Status := 'будет изменён';

    Frg1.MemTableEh1.Append;
    Frg1.MemTableEh1.FieldByName('num').Value := i + 1;
    Frg1.MemTableEh1.FieldByName('tablename').Value := FItems[i].TableName;
    Frg1.MemTableEh1.FieldByName('columnname').Value := FItems[i].ColumnName;
    Frg1.MemTableEh1.FieldByName('commentfile').Value := FItems[i].CommentFile;
    Frg1.MemTableEh1.FieldByName('existsindb').Value := S.IIf(FItems[i].ExistsInDb, 'да', 'нет');
    Frg1.MemTableEh1.FieldByName('commentdb').Value := FItems[i].CommentDb;
    Frg1.MemTableEh1.FieldByName('status').Value := Status;
    Frg1.MemTableEh1.Post;
  end;
  bt_Apply.Enabled := Length(FItems) > 0;
end;

{-------------------------------------------------------------------------------------------------}
//устанавливаем/обновляем в бд комментарии, отличающиеся от текущих (comment on column)

procedure TFrmXAdmSqlCommentSync.ApplyComments;
var
  i, Cnt: Integer;
  Sql, CommentEsc: string;
begin
  if Length(FItems) = 0 then
    Exit;
  if MyQuestionMessage('Установить/обновить в БД комментарии к столбцам, отличающиеся от текущих (см. столбец "Статус")?') <> mrYes then
    Exit;
  Cnt := 0;
  Cth.SetWaitCursor(True);
  try
    for i := 0 to High(FItems) do begin
      if not FItems[i].ExistsInDb then
        Continue;
      if Trim(FItems[i].CommentDb) = Trim(FItems[i].CommentFile) then
        Continue;
      CommentEsc := StringReplace(FItems[i].CommentFile, '''', '''''', [rfReplaceAll]);
      Sql := 'comment on column ' + FItems[i].TableName + '.' + FItems[i].ColumnName + ' is ''' + CommentEsc + '''';
      if Q.QExecSqlSimple(Sql) >= 0 then
        Inc(Cnt);
    end;
  finally
    Cth.SetWaitCursor(False);
  end;
  MyInfoMessage('Установлено/обновлено комментариев: ' + IntToStr(Cnt), []);
  CheckDbAndFillGrid; //перечитаем актуальное состояние из бд
end;

{-------------------------------------------------------------------------------------------------}

procedure TFrmXAdmSqlCommentSync.bt_SelectFileClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    edt_FileName.Text := OpenDialog1.FileName;
end;

procedure TFrmXAdmSqlCommentSync.bt_ParseClick(Sender: TObject);
var
  ErrMsg: string;
begin
  if Trim(edt_FileName.Text) = '' then begin
    MyWarningMessage('Не выбран файл.');
    Exit;
  end;
  if not FileExists(edt_FileName.Text) then begin
    MyWarningMessage('Файл не найден: ' + edt_FileName.Text);
    Exit;
  end;

  Cth.SetWaitCursor(True);
  try
    if not ParseFile(edt_FileName.Text, FItems, ErrMsg) then begin
      MyWarningMessage(ErrMsg);
      Exit;
    end;
  finally
    Cth.SetWaitCursor(False);
  end;

  if Length(FItems) = 0 then begin
    MyInfoMessage('В файле не найдено полей с комментариями в определениях таблиц (create table).', []);
    Frg1.MemTableEh1.EmptyTable;
    bt_Apply.Enabled := False;
    Exit;
  end;

  Cth.SetWaitCursor(True);
  try
    CheckDbAndFillGrid;
  finally
    Cth.SetWaitCursor(False);
  end;
end;

procedure TFrmXAdmSqlCommentSync.bt_ApplyClick(Sender: TObject);
begin
  ApplyComments;
end;

end.
