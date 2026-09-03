{
отображает информацию об ошибках, сохраненных в логе (adm_error_log/v_adm_error_log)
диалог на TFrmBasicMdi, с учетом исправлений разбора стека вызовов madExcept

старый диалог (D_J_Error_Log/TDlg_J_Error_Log) удален из проекта - этот диалог его полностью заменяет

все данные грузит из бд сам, получая только айди записи лога. диск не используем (пишем все в бд)
}


unit uFrmXWErrorLog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmBasicMdi,
  fs_synmemo, Vcl.ExtCtrls, Vcl.StdCtrls, MemTableDataEh, Data.DB,
  ToolCtrlsEh, DBGridEhToolCtrls,
  DBCtrlsEh, GridsEh, DBAxisGridsEh, DBGridEh, MemTableEh,
  Vcl.ComCtrls, IoUtils, uString, uLabelColors, EhLibVclUtils, DBGridEhGrouping,
  DynVarsEh, Vcl.Mask, Vcl.Clipbrd, System.StrUtils, System.Types;

type
  TFrmXWErrorLog = class(TFrmBasicMdi)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    lbl_Module: TLabel;
    lbl_User: TLabel;
    lbl_Ver: TLabel;
    lbl_Compile: TLabel;
    lbl_ErrDt: TLabel;
    mem_ErrorText: TDBMemoEh;
    TabSheet2: TTabSheet;
    DBGridEh1: TDBGridEh;
    TabSheet3: TTabSheet;
    DBGridEh2: TDBGridEh;
    TabSheet4: TTabSheet;
    pnl1: TPanel;
    lbl_SrcPath: TLabel;
    lbl_FileName: TLabel;
    lbl_ErrorInfo: TLabel;
    mem_SourceFile: TfsSyntaxMemo;
    TabSheet5: TTabSheet;
    Panel3: TPanel;
    mem_OraError: TDBMemoEh;
    Panel4: TPanel;
    mem_OraSQL: TDBMemoEh;
    Panel2: TPanel;
    mem_OraParams: TDBMemoEh;
    TabSheet6: TTabSheet;
    Im_Pict: TImage;
    TabSheet7: TTabSheet;
    mem_FullReport: TfsSyntaxMemo;
    //даблклик по гриду стека вызовов, пытаемся загрузить исходник в соседнюю вкладку
    procedure DBGridEh2DblClick(Sender: TObject);
    //активация закладки скриншота
    procedure TabSheet6Show(Sender: TObject);
  private
    { Private declarations }
    ErrorArr: TVarDynArray;
    Fields: string;
    PictFile: string;
    function Prepare: Boolean; override;
    procedure btnClick(Sender: TObject); override;
    //строит текст запроса (mem_OraSQL) с параметрами, подставленными прямо в текст вместо :name$type
    function BuildSqlWithParams: string;
    //подставляет в тексте запроса ASql все вхождения :AParamName на ALiteral (только целыми вхождениями,
    //то есть не задевает более длинные имена параметров, начинающиеся так же)
    function ReplaceParamInSql(const ASql, AParamName, ALiteral: string): string;
    //формирует sql-литерал для подстановки в запрос по типу параметра и его текстовому значению
    function ParamValueToSqlLiteral(const AValue, ATypeChar: string): string;
  public
    { Public declarations }
  end;

var
  FrmXWErrorLog: TFrmXWErrorLog;

implementation

{$R *.dfm}

uses
  uModule,
  uData,
  uForms,
  uErrors,
  uDBOra,
  uMessages,
  uSys
  ;

const
//определены в uErrors
{  cmyerrId = 0;
  cmyerrTime = 1;
  cmyerrModule = 2;
  cmyerrModuleVer = 3;
  cmyerrModuleCompile = 4;
  cmyerrUserLogin = 5;
  cmyerrGeneral = 6;
  cmyerrMashineUser = 7;
  cmyerrMessage = 8;
  cmyerrSql = 9;
  cmyerrSqlParams = 10;
  cmyerrStack = 11;
  cmyerrHandled = 12;
  ide = 13;
  }
//дополнительные
  cmyerrUserName = 14;
  cmyerrFullReport = 15;
  cmyerrPict = 16;


procedure TFrmXWErrorLog.btnClick(Sender: TObject);
begin
  if TControl(Sender).Tag = 1001 then begin
    //скопировать в буфер обмена текст запроса с подставленными значениями параметров
    if Trim(mem_OraSQL.Text) = '' then begin
      MyInfoMessage('Текст запроса пуст, копировать нечего.');
      Exit;
    end;
    Clipboard.AsText := BuildSqlWithParams;
  end
  else
    inherited;
end;

function TFrmXWErrorLog.ParamValueToSqlLiteral(const AValue, ATypeChar: string): string;
//формирует sql-литерал для подстановки в запрос по типу параметра (символ типа - как в QGetParamTypeCharFromName:
//'s','t' - строка, 'd' - дата, 'h' - дата+время, 'i' - целое, 'f' - вещественное, 'c' - денежное) и его текстовому значению
var
  LFloat: Extended;
  LDate: TDateTime;
  LTypeChar: Char;
begin
  //значение параметра не задано
  if SameText(AValue, '<Null>') then begin
    Result := 'NULL';
    Exit;
  end;
  if ATypeChar <> '' then
    LTypeChar := ATypeChar[1]
  else
    LTypeChar := 's';
  case LTypeChar of
    'i':
      //целое - подставляем как есть, без кавычек; если вдруг не число - подстрахуемся кавычками,
      //чтобы результат хотя бы остался синтаксически корректным sql-выражением
      if S.IsInt(AValue) then
        Result := AValue
      else
        Result := '''' + StringReplace(AValue, '''', '''''', [rfReplaceAll]) + '''';
    'f', 'c':
      //вещественное/денежное - разделитель дробной части может быть точкой или запятой (в зависимости
      //от текущих региональных настроек), в литерале sql нужна точка
      if S.StrToNumberCommaDot(AValue, -1e15, 1e15, LFloat, -1) then
        Result := StringReplace(FloatToStr(LFloat), FormatSettings.DecimalSeparator, '.', [rfReplaceAll])
      else
        Result := '''' + StringReplace(AValue, '''', '''''', [rfReplaceAll]) + '''';
    'd':
      //дата (без времени) - ANSI-литерал date 'YYYY-MM-DD'
      if TryStrToDate(AValue, LDate) then
        Result := 'date ''' + FormatDateTime('yyyy-mm-dd', LDate) + ''''
      else
        Result := '''' + StringReplace(AValue, '''', '''''', [rfReplaceAll]) + '''';
    'h':
      //дата со временем - ANSI-литерал timestamp 'YYYY-MM-DD HH:MI:SS'
      if TryStrToDateTime(AValue, LDate) then
        Result := 'timestamp ''' + FormatDateTime('yyyy-mm-dd hh:nn:ss', LDate) + ''''
      else
        Result := '''' + StringReplace(AValue, '''', '''''', [rfReplaceAll]) + '''';
    else
      //строка (s,t) и все нераспознанные типы - как строковый литерал, с экранированием кавычек внутри
      Result := '''' + StringReplace(AValue, '''', '''''', [rfReplaceAll]) + '''';
  end;
end;

function TFrmXWErrorLog.ReplaceParamInSql(const ASql, AParamName, ALiteral: string): string;
//заменяет в ASql все вхождения ":AParamName" на ALiteral, но только целые вхождения - то есть не трогает
//случай, когда найденное имя оказывается лишь префиксом более длинного имени другого параметра
//(например, не подставляет внутрь :id2$i при поиске :id$i)
const
  cIdentChars = ['A'..'Z', 'a'..'z', '0'..'9', '_', '$'];
var
  LSearch: string;
  p, LEndPos: Integer;
begin
  Result := ASql;
  LSearch := ':' + AParamName;
  p := PosEx(LSearch, Result, 1);
  while p > 0 do begin
    LEndPos := p + Length(LSearch);
    if (LEndPos > Length(Result)) or not CharInSet(Result[LEndPos], cIdentChars) then begin
      Result := Copy(Result, 1, p - 1) + ALiteral + Copy(Result, LEndPos, MaxInt);
      p := PosEx(LSearch, Result, p + Length(ALiteral));
    end
    else
      //совпадение оказалось лишь началом более длинного имени параметра - пропускаем и ищем дальше
      p := PosEx(LSearch, Result, p + 1);
  end;
end;

function TFrmXWErrorLog.BuildSqlWithParams: string;
//строит текст запроса (mem_OraSQL) с параметрами, подставленными прямо в текст вместо :name$type
//в отличие от uFrmXWOracleError, строка параметров (mem_OraParams) здесь хранится в другом формате -
//все параметры на одной строке, разделены "|" (см. uErrors.pas: GetBugReportToArr/BugReportHeader),
//а не по одному "[name$type]=значение" на строку
var
  i, p: Integer;
  st, LParamName, LParamValue, LTypeChar: string;
  saParts: TStringDynArray;
  sa: TStringDynArray;
begin
  Result := mem_OraSQL.Text;
  saParts := A.ExplodeS(Trim(mem_OraParams.Text), '|');
  for i := 0 to High(saParts) do begin
    st := Trim(saParts[i]);
    if (st = '') or (Copy(st, 1, 1) <> '[') then Continue;
    p := Pos(']=', st);
    if p = 0 then Continue;
    LParamName := Copy(st, 2, p - 2);
    LParamValue := Copy(st, p + 2, MaxInt);
    if LParamName = '' then Continue;
    //имя параметра может быть без суффикса "$тип" (например [wo_estimate]=0) - тогда считаем его строковым
    sa := A.ExplodeS(LParamName, '$');
    if (Length(sa) >= 2) and (Length(sa[1]) >= 1)
      then LTypeChar := LowerCase(sa[1][1])
      else LTypeChar := 's';
    Result := ReplaceParamInSql(Result, LParamName, ParamValueToSqlLiteral(LParamValue, LTypeChar));
  end;
end;

function TFrmXWErrorLog.Prepare: Boolean;
var
  i, j, k: Integer;
  st, st1, st2: string;
  va, va1: TVarDynArray;
  va2: TVarDynArray2;
  b, b1, b2: Boolean;
begin
  Result := False;
  Caption := 'Информация об ошибке';
  if not inherited then
    Exit;

  FOpt.DlgButtonsR := [
    [1001, True, True, 160, 'Копировать запрос']
  ];

  //читаем данные из вьюхи
  Fields:='id;dt;modulename;ver;compile_dt;userlogin;general;mashineinfo;message;sql;sqlparams;stack;handled;ide;username;fullreportc;pictc';
  ErrorArr:= Q.QLoadRow0(Q.QGetSql('s', 'v_adm_error_log', Fields), [ID]);

  //в статусбар
  RefreshStatusBar('$0000FFОшибка: $000000[$FF0000' + VaRToStr(ErrorArr[cmyerrModule]) +
    '$000000 - $FF0000' + VaRToStr(ErrorArr[cmyerrUserLogin]) + '$000000 - $FF0000' + VaRToStr(VartoDatetime(ErrorArr[cmyerrTime]))+ '$000000]$FF0000'
    , '', True
  );

  //на главной вкладке
  lbl_Module.ResetColors;
  lbl_Module.SetCaption(lbl_Module.Caption + '  $FF0000' + ErrorArr[cmyerrModule]);
  lbl_Ver.ResetColors;
  lbl_Ver.SetCaption(lbl_Ver.Caption + '  $FF0000' + ErrorArr[cmyerrModuleVer]);
  lbl_Compile.ResetColors;
  lbl_Compile.SetCaption(lbl_Compile.Caption + '  $FF0000' + VarToStr(ErrorArr[cmyerrModuleCompile]));
  lbl_User.ResetColors;
  lbl_User.SetCaption(lbl_User.Caption + '  $FF0000' + S.NSt(ErrorArr[cmyerrUserName]) +  '(' + S.NSt(ErrorArr[cmyerrUserLogin]) + ')');
  lbl_ErrDt.ResetColors;
  lbl_ErrDt.SetCaption(lbl_ErrDt.Caption + '  $FF0000' + VarToStr(ErrorArr[cmyerrTime]));
  mem_ErrorText.Text:= ErrorArr[cmyerrMessage];


  //вкладка General
  va1:=A.Explode(ErrorArr[cmyerrGeneral], #13#10);
  va2:=[];
  for i:=0 to High(va1) do begin
    va:=A.Explode(va1[i], ':');
    st1:=Trim(va[0]);
    Delete(va, 0, 1);
    va2:=va2 + [[st1, Trim(A.Implode(va, ':'))]];
  end;
  //поле, тип данных, размер данных, заголовок (может с " ", "_", "|"), отображаемая ширина, видимость, автоподгонка ширины, перенос для столбца по словам
  Mth.CreateTableGrid(
    DBGridEh1, True, True, False, False,
    [['name', ftString, 60, 'Property', 250, True, False, False],
     ['value', ftString, 60, 'Value', 400, True, True, True]],
    va2, '', ''
  );

  //Call stack
  //текст стека может не поместиться в 4000 символов, и резаные строки портят разбор
  //удаляем все строки короче 70 символов, цифра достаточно условна
  va1:=A.Explode(ErrorArr[cmyerrStack], #13#10);
  for i:=high(va1) downto 0 do
    if length(va1[i]) < 30
      then Delete(va1, i,1);
  //строку стека разбираем не по вертикальным "пустым" колонкам (как было раньше - искали позиции символов,
  //где во ВСЕХ строках сразу пробел), а по структуре самой строки: делим её на слова по пробелам (подряд
  //идущие пробелы игнорируются) и определяем поля по их количеству и виду, а не по позиции символа. формат
  //строки madExcept: address rel module [unit [line +lineoffset]] function - секции unit и line+lineoffset
  //присутствуют, только если для модуля есть отладочная информация (для системных dll их нет, и после
  //module сразу идет function). ширина промежутков между полями НЕ фиксирована (от одного пробела до
  //нескольких десятков - поле переполняется и "съедает" отступ, зарезервированный под следующее поле), из-за
  //этого старый алгоритм поиска колонок, целиком состоящих из пробелов во всех строках сразу, работал
  //некорректно на строках с большими промежутками (широкий промежуток на одних строках "перекрывался"
  //содержимым другой, более длинной строки, и рассыпался на несколько кусков вместо одной границы) - разбор
  //по словам от ширины промежутков вообще не зависит
  //address;rel;module;unit;address(line);rel(lineoffset);function
  va2:=[];
  for i:=0 to high(va1) do begin
    va2:=va2+[['','','','','','','']];
    va:=A.Explode(Trim(va1[i]), ' ', True);
    if Length(va) < 4 then Continue; //не похоже на строку стека - пропускаем
    k:=High(va);
    va2[i][0]:=va[0];   //address
    va2[i][1]:=va[1];   //rel
    va2[i][2]:=va[2];   //module
    va2[i][6]:=va[k];   //function - всегда последнее слово в строке
    if k >= 4 then begin
      va2[i][3]:=va[3]; //unit
      //номер строки и смещение внутри строки есть, только если между unit и function ровно два слова:
      //число (номер строки) и слово вида "+число" (смещение)
      if (k = 6) and S.IsInt(va[4]) and (Copy(VarToStr(va[5]), 1, 1) = '+') then begin
        va2[i][4]:=va[4]; //addressf (номер строки)
        va2[i][5]:=va[5]; //relf (+смещение в строке)
      end;
    end;
  end;
  i:=high(va2);
  //поле, тип данных, размер данных, заголовок (может с " ", "_", "|"), отображаемая ширина, видимость, автоподгонка ширины, перенос для столбца по словам
   //address;rel;module;unit;address;rel;function
  Mth.CreateTableGrid(
    DBGridEh2, True, True, False, False,[
    ['address', ftString, 60, 'address', 70, True, False, False],
    ['rel', ftString, 60, 'rel', 70, True, False, False],
    ['module', ftString, 100, 'module', 200, True, True, True],
    ['unit', ftString, 50, 'unit', 200, True, True, True],
    ['addressf', ftString, 60, 'address', 70, True, False, False],
    ['relf', ftString, 60, 'rel', 70, True, False, False],
    ['function', ftString, 100, 'function', 200, True, True, True]],
    va2, '', ''
  );

  //ошибки базы данных Oracle
  mem_OraError.Lines.Text:=S.NSt(ErrorArr[cmyerrMessage]); mem_OraError.ReadOnly:= True;
  mem_OraSQL.Lines.Text:=S.NSt(ErrorArr[cmyerrSql]); mem_OraSQL.ReadOnly:= True;
  mem_OraParams.Lines.Text:=S.NSt(ErrorArr[cmyerrSqlParams]); mem_OraParams.ReadOnly:= True;

  //полный отчет в Тмемо
  mem_FullReport.Lines.Clear;
  mem_FullReport.Lines.Text:=S.NSt(ErrorArr[cmyerrFullReport]);

  PageControl1.ActivePageIndex:=0;
  Result := True;
end;

procedure TFrmXWErrorLog.TabSheet6Show(Sender: TObject);
//скриншот загружаем из бд при открытии формы, но показываем только при первом переходе на вкладку скриншота
//сделано пока криво, текст из бд сохраняется во временный файл виндовс, читается в картинку, затем файл стирается
begin
  inherited;
  Exit; //!!!
  //скриншот
  if PictFile <> '' then Exit;
  PictFile:=Sys.GetWinTempFileName+'.bmp';
  Sys.SaveTextToFile(PictFile, ErrorArr[cmyerrPict]);
  Im_Pict.Picture.LoadFromFile(PictFile);
  TFile.Delete(PictFile);
end;

procedure TFrmXWErrorLog.DBGridEh2DblClick(Sender: TObject);
//дабл-клик по гриду стека вызовов
var
  st, fname, dir: string;
  i,j: Integer;
  dt: TDateTime;
  strno: Integer;
begin
  inherited;
  dir:=Module.Getpath_SrcForVersion(ErrorArr[cmyerrModule], ErrorArr[cmyerrModuleVer], ErrorArr[cmyerrModuleCompile]);
  if not DirectoryExists(dir) then begin
    MyInfoMessage('Исходники для данной версии модуля не найдены!');
    Exit;
  end;
  fname:=S.NSt(TMemTableEh(DBGridEh2.DataSet).FieldByName('unit').AsString) + '.pas';
  st:=dir + '\' + fname;
  if not FileExists(st) then begin
    MyInfoMessage('Файл "' + fname + '" в исходниках не найден!');
    Exit;
  end;
  {$I-}
  lbl_FileName.SetCaption2('Файл:  $FF0000' + fname);
  lbl_SrcPath.SetCaption2('Путь:  $FF0000' + dir);
  lbl_ErrorInfo.SetCaption2('Место вызова:  Функция "$FF0000' +
    S.NSt(TMemTableEh(DBGridEh2.DataSet).FieldByName('function').AsString) + '$000000" в строке $FF0000' +
    S.NSt(TMemTableEh(DBGridEh2.DataSet).FieldByName('addressf').AsString) + '$000000   ($FF0000' +
    S.NSt(TMemTableEh(DBGridEh2.DataSet).FieldByName('relf').AsString) + '$000000)');
  mem_SourceFile.Lines.Clear;
  mem_SourceFile.Lines.LoadFromFile(st);
  strno:=S.VarToInt(TMemTableEh(DBGridEh2.DataSet).FieldByName('addressf').Value);
  if strno = -1 Then exit;
  try
  mem_SourceFile.AddBookmark(TMemTableEh(DBGridEh2.DataSet).FieldByName('addressf').AsInteger - 1, 1);
  mem_SourceFile.GotoBookmark(1);
  except
  end;
  {$I+}
end;

end.
