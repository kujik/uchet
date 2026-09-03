{
Диалог подробностей ошибки при работе с базой данных.
отображает сообщение об ошибке, текст запроса и значения параметров.
}
unit uFrmXWOracleError;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, StrUtils,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi,
  Vcl.Imaging.pngimage, Vcl.Mask
  ;

type
  TFrmXWOracleError = class(TFrmBasicMdi)
    pnlCenter: TPanel;
    pnlLeft: TPanel;
    MError: TDBMemoEh;
    MSql: TDBMemoEh;
    MParams: TDBMemoEh;
    Image1: TImage;
    procedure FormActivate(Sender: TObject);
  private
    procedure btnClick(Sender: TObject); override;
    //строит текст запроса с параметрами, подставленными прямо в текст (вместо :name$type - их значения)
    function BuildSqlWithParams: string;
    //подставляет в тексте запроса ASql все вхождения :AParamName на ALiteral (только целыми вхождениями,
    //то есть не задевает более длинные имена параметров, начинающиеся так же)
    function ReplaceParamInSql(const ASql, AParamName, ALiteral: string): string;
    //формирует sql-литерал для подстановки в запрос по типу параметра (из QGetParamTypeCharFromName) и его текстовому значению
    function ParamValueToSqlLiteral(const AValue, ATypeChar: string): string;
  public
    //покажем окно с ошибкой, запросом и параметрами запроса к БД
    //если заданы строковые значения AError и т.д., то будут показаны они
    //иначе будет показан запрос из лога по переданной строке (при -1 - послений)
    procedure ShowDialog(ARow: Integer = -1; AError: string = ''; AQuery: string = ''; AParams: string = '');
  end;

var
  FrmXWOracleError: TFrmXWOracleError;

implementation

uses
  uDB,
  uWindows
  ;


{$R *.dfm}

procedure TFrmXWOracleError.btnClick(Sender: TObject);
begin
  if TControl(Sender).Tag = 1001 then begin
    //скопировать в буфер обмена текст запроса с подставленными значениями параметров
    if Trim(MSql.Text) = '' then begin
      MyInfoMessage('Текст запроса пуст, копировать нечего.');
      Exit;
    end;
    Clipboard.AsText := BuildSqlWithParams;
  end
  else
    Wh.ExecReference(myfrm_Srv_SqlMonitor);
end;

function TFrmXWOracleError.ParamValueToSqlLiteral(const AValue, ATypeChar: string): string;
//формирует sql-литерал для подстановки в запрос по типу параметра (символ типа - как в QGetParamTypeCharFromName:
//'s','t' - строка, 'd' - дата, 'h' - дата+время, 'i' - целое, 'f' - вещественное, 'c' - денежное) и его текстовому значению
//(текстовое значение - в том виде, в каком оно показано в MParams, то есть VarToStr от реального значения параметра)
var
  LFloat: Extended;
  LDate: TDateTime;
  LTypeChar: Char;
begin
  //значение параметра не задано (см. запись лога параметров - TmyDB.QSetParams/AdoConnectionProviderEhExecuteCommand)
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

function TFrmXWOracleError.ReplaceParamInSql(const ASql, AParamName, ALiteral: string): string;
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

function TFrmXWOracleError.BuildSqlWithParams: string;
//строит текст запроса (MSql) с параметрами, подставленными прямо в текст вместо :name$type
//разбор строк параметров (MParams) - формат "[name$type]=значение", по одной строке на параметр
//(см. запись в TmyDB.QSetParams / AdoConnectionProviderEhExecuteCommand)
var
  i, p: Integer;
  st, LParamName, LParamValue, LTypeChar: string;
  sa: TStringDynArray;
begin
  Result := MSql.Text;
  for i := 0 to MParams.Lines.Count - 1 do begin
    st := Trim(MParams.Lines[i]);
    if (st = '') or (Copy(st, 1, 1) <> '[') then Continue;
    p := Pos(']=', st);
    if p = 0 then Continue;
    LParamName := Copy(st, 2, p - 2);
    LParamValue := Copy(st, p + 2, MaxInt);
    if LParamName = '' then Continue;
    sa := A.ExplodeS(LParamName, '$');
    if (Length(sa) >= 2) and (Length(sa[1]) >= 1)
      then LTypeChar := LowerCase(sa[1][1])
      else LTypeChar := 's';
    Result := ReplaceParamInSql(Result, LParamName, ParamValueToSqlLiteral(LParamValue, LTypeChar));
  end;
end;


procedure TFrmXWOracleError.FormActivate(Sender: TObject);
begin
  inherited;
  Top := 200;
end;

procedure TFrmXWOracleError.ShowDialog(ARow: Integer = -1; AError: string = ''; AQuery: string = ''; AParams: string = '');
//покажем окно с ошибкой, запросом и параметрами запроса к БД
//если заданы строковые значения AError и т.д., то будут показаны они
//иначе будет показан запрос из лога по переданной строке (при -1 - послений)
begin
  PrepareCreatedForm(Application, myfrm_Dlg_OracleError, '~Ошибка при работе с БД', fView, null, [], [myfoModal, myfoDialog, myfoDialogButtonsB, myfoSizeable], False);
  FOpt.DlgButtonsR := [
    [1000, True, True, 120, 'Журнал запросов', 'view'],
    [1001, True, True, 160, 'Копировать запрос']
  ];
  ARow := Min(S.IIf(ARow < 0, MaxInt, ARow), High(Q.LogArray));
  Caption := ModuleRecArr[uData.cMainModule].Caption + ' - Ошибка!';
  Module.SetBitmapFromResource(Image1.Picture.Bitmap, PChar('error64'));
  MError.Text := '';
  MSql.Text := '';
  MParams.Text := '';
  if AError + AQuery + AParams <> '' then begin
    MError.Text := AError;
    MSql.Text := AQuery;
    MParams.Text := AParams;
  end
  else if ARow >= 0 then begin
    MError.Text := Q.LogArray[ARow][cmydbLogError];
    MSql.Text := Q.LogArray[ARow][cmydbLogQuery];
    MParams.Text := Q.LogArray[ARow][cmydbLogParams];
  end;
  Self.ShowModal;
end;

end.
