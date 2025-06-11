unit uDBOra;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Types,
  Dialogs, StdCtrls, DBCtrlsEh, uData, DB, AdoDB, uString, Variants, MemTableEh, uErrors, IniFiles, ADODataDriverEh,
  uFrmXDmsgNoConnection, MemTableDataEh, DataDriverEh, uDB
  ;

const
  oraeNonUnique = '00001';
  oraeNumberTooLarge = '01438';
  oraePkNotFound = '02291';
  oraeStringTooLarge = '12899';
  oraeChildFound = '02292';
  oraeCannotInsertNull = '01400';
  oraeCannotUpdateNull = '01407';
  oraeDeadLock = '00060';

type
  TmyDBOra = class(TmyDB)
    //без перекрытия этого метода не попадало в метод родителя, хотя в dfm nil не было
    function AdoConnectionProviderEhExecuteCommand(
      SQLDataDriver: TCustomSQLDataDriverEh; Command: TCustomSQLCommandEh;
      var Cursor: TDataSet; var FreeOnEof, Processed: Boolean): Integer;
  private
    { Private declarations }
  public
    { Public declarations }
    //создаем объект базы данных
    //передается файл настроек соединения (только имя файла, без расширения), если AConnectAfterCreate то тут же пытаемся подключиться
    constructor CreateObject(AOwner: TComponent; AConnectionFile: string; AConnectAfterCreate: Boolean = true); reintroduce;
    //установка в контексте сеайнса переданного параметра равному переданному значению
    //поскольку сессий две (для запросов и для dbgrideh, устанавливаются и в том и в том контексте
    function QSetContextValue(Par: string; Val: Variant): Integer;
    //запись в журнал действийй БД
    //передается имя события (процедура, таблица...) и произвольный коммент до 4000 символов
    procedure QLog(ItemName, Comm: string);
    //Проверяем и устанавливаем блокироку документа (по произвольным строкам Docum, documAdd)
    //унитарная операция!
    //если передано сообщение Msg, то оно выводится в случае ошибки установки блокировки ($u заменяется на имя юзера)
    //Msg содержит сообщение Если Другой пользователь открыл|Если сам открыл
    //блокировку в текущем виде проверяет в том числе и для себя, но в данной версии не различая вход под одним логином с разных компов
    //если очищать блокировки при логине пользователя, то будет некорректно работать если вход под одним пользователем с разных компов
    //блокировки для закрытых сессий сбрасываются запросом возврата блокировки, поэтомуц после закрытия программы все блокировки пользователя исчезнут автоматически
    // Mode: Integer = 0 fNone - зацикливается на подключении модулей
    function DBLock(SetLock: Boolean; Docum: string; DocumAdd: string = ''; Msg: string = '*|*'; Mode: TDialogType = fNone) : TVarDynArray;
    //очистить все блокироки для текущего пользователя
    procedure DBLock_ClearAll;
    procedure OraError(msg: string);
  end;

var
  Q: TmyDBOra;

implementation

uses
  uWindows,
  uMessages,
  uForms
  ;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}


function TmyDBOra.AdoConnectionProviderEhExecuteCommand(
  SQLDataDriver: TCustomSQLDataDriverEh; Command: TCustomSQLCommandEh;
  var Cursor: TDataSet; var FreeOnEof, Processed: Boolean): Integer;
begin
  inherited;
//
end;

constructor TmyDBOra.CreateObject(AOwner: TComponent; AConnectionFile: string; AConnectAfterCreate: Boolean = true);
//создаем объект базы данных
//передается файл настроек соединения (только имя файла, без расширения), если AConnectAfterCreate то тут же пытаемся подключиться
var
  va: TVarDynArray;
begin
  Inherited CreateObject(AOwner, mydbtOra, AConnectionFile, AConnectAfterCreate);
end;

function TmyDBOra.QSetContextValue(Par: string; Val: Variant): Integer;
//установка в контексте сеайнса переданного параметра равному переданному значению
//поскольку сессий две (для запросов и для dbgrideh, устанавливаются и в том и в том контексте
//в бд значение контекста имеет тип varchar2, но блигодаря модификаторам к нему успешнео приводится любой
var
  ValType: string;
begin
  Result:=-1;
  try
    ValType := 's';
    if S.VarType(Val) = varDate then
      ValType := 'd';
    if S.VarType(Val) = varInteger then
      ValType := 'i';
    if S.VarType(Val) = varDouble then
      ValType := 'f';
    //для контекста сессии ehlib
    if AdoConnectionProviderEh.Connection <> nil then begin
      ADODataDriverEh.SelectSQL.Text:='select f_set_context_value(:par$s, :val$' + ValType + ') from dual';
      ADODataDriverEh.SelectCommand.Parameters.ParamByName('par$s').Value:= Par;
      ADODataDriverEh.SelectCommand.Parameters.ParamByName('val$' + ValType + '').Value:=Val;
      MemTableEh1.Active:=true;
      MemTableEh1.Active:=false;
    end;
    //для контекста основной сессии
    QCallStoredProc('set_context_value', 'par$s;val$' + ValType + '', [Par, Val]);
    Result:=0;
  except on E: Exception do Application.ShowException(E);
  end;
end;

procedure TmyDBOra.QLog(ItemName, Comm: string);
//запись в журнал действийй БД
//передается имя события (процедура, таблица...) и произвольный коммент до 4000 символов
begin
  QExecSql('insert into adm_db_log (itemname, comm) values (:itemname$s, :comm$s)', [ItemName, Comm], false);
end;

procedure TmyDBOra.OraError(msg: string);
var
  Msg1, EMsg: string;
begin
  Msg1:='';
  EMsg:= msg; //E.Message;
  if Pos('unique constraint ', EMsg)> 0 then msg:='Строка должна быть уникальной! Данные не изменены!';
  if Msg = '' then Msg:=EMsg;
//  If E is Exception then
//    ShowMessage ('ErrE - ' + E.Message)
//  else
//    ShowMessage ('ErrNE - ' + E.Message);
  ShowMessage (Msg);
end;


//Проверяем и устанавливаем блокироку документа (по произвольным строкам Docum, documAdd)
//унитарная операция!
//если передано сообщение Msg, то оно выводится в случае ошибки установки блокировки ($u заменяется на имя юзера)
//Msg содержит сообщение Если Другой пользователь открыл|Если сам открыл
//блокировку в текущем виде проверяет в том числе и для себя, но в данной версии не различая вход под одним логином с разных компов
//если очищать блокировки при логине пользователя, то будет некорректно работать если вход под одним пользователем с разных компов
//блокировки для закрытых сессий сбрасываются запросом возврата блокировки, поэтомуц после закрытия программы все блокировки пользователя исчезнут автоматически
function TmyDBOra.DBLock(SetLock: Boolean; Docum: string; DocumAdd: string = ''; Msg: string = '*|*'; Mode: TDialogType = fNone) : TVarDynArray;
var
  res: Variant;
  resi: Integer;
  v: TVarDataArray;
  Msgs: TStringDynArray;
  m1, m2: string;
begin
  Result:= [S.IIf(Mode in [fNone, fEdit, fDelete], true, null), '', '', Mode];
  if not (Mode in [fNone, fEdit, fDelete]) then Exit;
  if SetLock
    then begin
      //убьем блокировки в мертвых сессиях
      QExecSql('delete from adm_locks l where (select count(1) from v$session vs where l.sid = vs.sid and l.serial# = vs.serial#) = 0', [], false);
      //попытаемся установить блокировку
      resi:= QExecSql(
        'insert into adm_locks (logon_time, sid, serial#, login, username, lock_time, lock_docum, lock_docum_add) values ('+
        '(select logon_time from v$session where sid in (select sid from v$mystat where rownum = 1)), ' +
        '(select sid from v$session where sid in (select sid from v$mystat where rownum = 1)), ' +
        '(select serial# from v$session where sid in (select sid from v$mystat where rownum = 1)), ' +
        ':login$s, :username$s, current_date, :docum$s, :documadd$s)',
        [User.GetLogin, User.GetName, Docum, DocumAdd], false
        );
      if resi = -1 then
        begin
          //ошибка установки блокировки
          res:= QSelectOneRow(
//            'select login, username, lock_time from locks where login <> :login and lock_docum = :docum and lock_docum_add = :documadd',
//            VarArrayOf([User.GetLogin, Docum, DocumAdd])
            'select login, username, lock_time from adm_locks where lock_docum = :docum and lock_docum_add = :documadd',
            [Docum, DocumAdd]
            );
          Result[0]:= False;
          Result[1]:= S.NSt(res[1]);
          Result[2]:= res[2];
          Result[3]:= fNone;
          if Msg='' then Msg:='|';
          Msgs:=A.ExplodeS(Msg, '|');
          if (Mode in [fNone, fDelete])
            then if (Msgs[0] <> '*')
              then m1:= Msgs[0]
              else m1:= 'Этот документ нельзя открыть, так как он сейчас редактируется пользователем $u.';
          if (Mode in [fEdit])
            then if (Msgs[0] <> '*')
              then m1:= Msgs[0]
              else m1:= 'Этот документ сейчас редактируется пользователем $u и будет открыт только для чтения.';
          if Length(Msgs) = 0 then m2:= m1 else m2:= Msgs[1];
//        if (m2 = '*') and (Mode = 0) then m2:= 'Вы уже открыли этот документ для редактирования.';
          if (m2 = '*') then m2:= 'Вы уже открыли этот документ для редактирования.';
          if res[0] <> User.GetLogin
            //открыт другим пользоователем
            then begin
              //если параметр Редактирование, то меняем на Просмотр, если другой, то просто не открываем
              Result[3]:= S.IIf(Mode = fEdit, fView, fNone);
              //и выводим сообщение
              if m1 <> '' then myMessageDlg(StringReplace(m1, '$u', VarToStr(Res[1]),[rfReplaceAll, rfIgnoreCase]), mtWarning, [mbOk]);
            end
            //открыт собой же
            else begin
              //если не передан режим, или передан и найдено окно с такими параметрами, пытаемся перейти в него
//              if (Mode = fNone) or not Wh.BringToFrontSelfLockedDialog(Docum, DocumAdd) //++
              if True or (Mode = fNone)// or not Wh.BringToFrontSelfLockedDialog(Docum, DocumAdd)
                //а если не удалось то выводим сообщение
                then if m2 <> '' then myMessageDlg(StringReplace(m2, '$u', VarToStr(Res[1]),[rfReplaceAll, rfIgnoreCase]), mtWarning, [mbOk]);
              Result[3]:= fNone;
            end;
        end;
    end
    else begin
      //удаляем блокироку
      resi:= QExecSql(
        'delete from adm_locks where login = :login$s and lock_docum = :docum$s and lock_docum_add = :documadd$s',
        [User.GetLogin, Docum, DocumAdd], false
      );
    end;
end;

//очистить все блокироки для текущего пользователя
procedure TmyDBOra.DBLock_ClearAll;
begin
  QExecSql('delete from adm_locks where login = :login$s', [User.GetLogin], false);
end;



end.

{
числа:
при вставке числа округляет до указанного количества дробных разрядов, в том числе если не указана дробная часть то округляет до целого
если же общее число знаков, включая дробные (для i3 number(3,1) напр ошибка будет при 123.4)) больше числа занков то возникает
ORA-01438: value larger than specified precision allowed for this column
без указания столбца!!!

не найден родительский ключ
пытаемся вставить запипись, которой нет в справочнике
ORA-02291: integrity constraint (UCHET.FK_PAS_TEST) violated - parent key not found

значение должно быть уникальным
ORA-00001: unique constraint (UCHET.PK_PAS_TEST) violated

количество знаков в числе слишком большое (и при апдейте и при вставке)
ORA-01438: value larger than specified precision allowed for this column

строка слишком длинная
ORA-12899: value too large for column "UCHET"."PAS_TEST2"."S" (actual: 12, maximum: 10)

найдена дочерняя запись при удалении
нельзя удалить запись, так как данные еще используются
ORA-02292: integrity constraint (UCHET.FK_PAS_TEST) violated - child record found

нельзя добавить пустую строку, для поля в котором есть ограничение not null
поле не может быть пустым
ORA-01400: cannot insert NULL into ("UCHET"."PAS_TEST1"."S")

нельзя вставить пустую строку, для поля в котором есть ограничение not null
поле не может быть пустым
ORA-01407: cannot update ("UCHET"."PAS_TEST1"."S") to NULL

ORA-03114: нет связи с ORACLE

ORA-00060: deadlock detected while waiting for resource

}

работа с полями BLOB и CLOB видимо в АДО не совсем корректно
при выставлении типа oraBlob или oraClob для параметров происходит ошибка
при выставлении Blob строка корректно записывапется, но читаются из базы искаженные данные

c Clob тем не менее просто рабоать можно как с типом ftString, если в бд эти поля объявленыв
как CLOB, то длинные строки в них пишутся и читаются из них при типа параметра ftString/
