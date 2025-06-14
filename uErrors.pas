{
ОБРАБОТКА И ЛОГИРОВАНИЕ ОШИБОК
ориентировано на использование madExcept (free)

все сообщения об ошибках выводятся его диалогом, если нет подмены ошибки на Attention
(например, при вставке в таблицу ошибка уникальности - в этом случае будет выведено обычное окно предупреждения)

пользоваться так:
код в конструкцию
try
except on E: Exception do Application.ShowException(E);
end;

try
except on E: Exception do begin
  Errors.SetParam('MyProcedure', 'ошибка такая-то', myerrTypeDB, True /ShewError/);
  Application.ShowException(E);
end;

тут вывод исключения вручную не нужен. но в такой конструкции нарушается порядок выполнения -
если в вызвывавших этот код процедурах верхнего уровня не встретится try-except, то вывалится сразу
в основной поток и только после этого будет выдано сообщение об ошибке
try
finally
end;

так просто подавим вывод ошибок, если они не обработаны в таком блоке раньше
try
except
end;

если надо выдать ошибку при например неверных параметрах вручную
Errors.SetParam('MyProcedure', 'ошибка такая-то', myerrTypeDB, True /ShewError/);
raise Exception.Create('');

если в процедуре произошла ошибка, то выполнение перейдет в блок обработки ошибок в этой процедуре
или процедуре верхнего уровня, а при отстутствии такого блока - в основной поток.

дополнительные параметры (локация, доп. сообщение, тип ошибки, подавить показ ошибок)
задаются через Errors.SetParam(). сбрасываются автоматически при перехвате возникшей ошибки.
но нужно обеспечить сброс вызовом SetParam без параметров, когда область действия закончится.

при работе под иде запись дампа и запись лога в базу можно отключить константами, кторые здесь ниже

убрал запись данных на диск вообще, вся информация, включая полный дамп и картинку, пишется в БД, так выстрее
}

unit uErrors;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, uData, Jpeg, uString, PngImage, madExcept, madLinkDisAsm,
  madListHardware, madListProcesses, madListModules, AdoDB, DB;

const
  //тип ошибки
  myerrTypeNoErr = #2;
  myerrTypeDB = #3;

  //поля лога ошибок
  cmyerrId = 0;
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
  cmyerrEde = 13;

  //наименочвания файлов дампа
  cmyerrBugReportFileName = 'bugreport.txt';
  cmyerrScreenShotFileName = 'bugreport.png';
  cmyerrBugReportFullFileName = 'bugreport_full.txt';

  //писать ли ошибки в лог базы данных и на диск при запуске из-под ИДЕ
  cmyDebugSendErrToDB = True;
  cmyDebugSendErrToDisk = True;
  cmyDebugNOSavefromIDE = True;

type
  TmyErrors = class
  private
    //данные ошибки
    FErrorMessage: string;
    FErrorType: string;
    FLocation: string;
    FErrorMessageGlobal: string;
    FLocationGlobal: string;
    //данные по ошибке, вызванной работой с БД
    FErrDbRow: Integer;
    FErrDBErr: string;
    FErrDBQuery: string;
    FErrDBParams: string;
    FKnownErrors: TVarDynArray2;
    FIsExceptionHandlerDisabled: Boolean;
    //полное сообщение об ошибке, отобразится и запишется в БД
    FErrMessageFull: string;
    //массив лога
    FLogArray: TVarDynArray2;
    //настройки MadExcept
    MadSettings: IMESettings;
    //собирает в массив нужную нам информацию при вызове исключения и обработки его madExcept
    function GetBugReportToArr(const exceptIntf: IMEException): TVarDynArray;
    //пишем последнюю строку лога в БД
    procedure LogToDb(const exceptIntf: IMEException);
    //запишем отчет на диск в папку пользователь_дата_время
    procedure LogToDisk(const exceptIntf: IMEException);
  public
    //в окне исключений сообщение об ошибке заменяется на эту строку
    //симовол * в ней заменяется на E.Message? если пустая то тоже;
    //если поле начинается с myerrNoErr, то окно с ошибкой не выводится
    //для установки использовать SetErororMessage перед/в try/finally
    //сбрасывается автоматически при генерации исключения
    //(если сбрасывать в Finally, то оно выполнится раньше чем обработчик исключения)
    //сообщение об ошибке для подстановки
    property ErrorMessage: string read FErrorMessage;
    //тип ошибки
    //если поле ErororType равно myerrNoErr, то окно с ошибкой не выводится
    //для myerrDB в обработчике предусмотрен показ запроса
    property ErrorType: string read FErrorType;
    //массив лога - публичное свойство
    property LogArray: TVarDynArray2 read FLogArray;
    property KnownErrors: TVarDynArray2 read FKnownErrors;
    property IsExceptionHandlerDisabled : Boolean read FIsExceptionHandlerDisabled write FIsExceptionHandlerDisabled;
    //конструктор
    constructor Create;
    //установка параметров MadExcept, вызываем сразу в конструкторе, и при (пере)логине пользователя
    procedure SetMadExcept;
    //обработчик исключений MadExcept
    procedure ExceptionHandler(const exceptIntf: IMEException; var handled: Boolean);
    //обработчик акций MadExcept
    procedure ExceptActionHandler(action: TExceptAction; const exceptIntf: IMEException; var handled: Boolean);
    //устанавливает режим выдачи информации об ошибке для последующих ошибок
    //параметры приводятся к дефолтным при возникновении ошибки, или ручным вызововом Errors.SetParam без параметров
    //Location - можно установить для локализации места ошибки
    //ErrorMsg - модифицируем сообщение об ошибке. любой текст. "*" заменяется на оригинальную строку Exception.Message, если пустая то также выводится Exception.Message
    //ErrorType - дополнительный тип ошибки для кастомизации действий. пока DB и NoErr
    //ShowError - если установлен, отключает вывод окна ошибки, а также и сохранение ее в логах
    function SetParam(Location: string = ''; ErrorMsg: string = ''; ErrorType: string = ''; ShowError: Boolean = True): string;
    function SetErrorCapt(Location: string = ''; ErrorMsg: string = ''): string;
    //то же, но вызывает ошибку
    function RaiseErr(Location: string = ''; ErrorMsg: string = ''; ErrorType: string = ''; ShowError: Boolean = True): string;
    //проверим, что эта ошибка - отвал БД оракла
    //в этом случае, установим признак обработанной ошибки, чтобы не выходило окно ошибки, и выведем свое окно
    function IsOraDisconnect(EMessage: string; var handled: Boolean): Boolean;
    //вычленяем из строки сообщения об ошибке Oracle имена ошибки, схемы, таблицы и столбца
    {ORA-01400: cannot insert NULL into ("UCHET22"."TEST_3"."V1")}
    procedure GetOraItemsFromErrorMessage(EMessage: string; var Error: string; var Shema: string; var Table: string; var Column: string);
    procedure PreSetKnownErrors;
    function  GetKnownErrorMessage(ErrorMessage: string): string;
    procedure RaiseError(ErrorMsg: string = ''; Prefix: string = ''; ShowError: Boolean = True);
    procedure ShowErrorBox;
    procedure myError(EMessage: string; IsOraWarning: Boolean = False);
    //вызывает ошибку деления но 0
    procedure TestError;
    //для проверки
    procedure Test;
  end;

var
  Errors: TmyErrors;

implementation

uses
  uFrmXDmsgNoConnection, uFrmXWOracleError, uMessages, uFrmMain, uSys, uDBOra, uModule;

constructor TmyErrors.Create;
begin
  inherited;
  MadSettings := MESettings;
  SetMadExcept;
  PreSetKnownErrors;
end;

function TMyErrors.SetParam(Location: string = ''; ErrorMsg: string = ''; ErrorType: string = ''; ShowError: Boolean = True): string;
//устанавливает режим выдачи информации об ошибке для последующих ошибок
//параметры приводятся к дефолтным при возникновении ошибки, или ручным вызововом Errors.SetParam без параметров
//Location - можно установить для локализации места ошибки
//ErrorMsg - модифицируем сообщение об ошибке. любой текст. "*" заменяется на оригинальную строку Exception.Message, если пустая то также выводится Exception.Message
//ErrorType - дополнительный тип ошибки для кастомизации действий. пока DB и NoErr
//ShowError - если установлен, отключает вывод окна ошибки, а также и сохранение ее в логах
begin
  FLocation := Location;
  FErrorType := ErrorType;
  if not ShowError then
    FErrorMessage := myerrTypeNoErr + ErrorMsg
  else
    FErrorMessage := ErrorMsg;
  Result := FErrorMessage;
end;

function TMyErrors.SetErrorCapt(Location: string = ''; ErrorMsg: string = ''): string;
begin
  FLocationGlobal := Location;
  FErrorMessageGlobal := ErrorMsg;
end;



function TMyErrors.RaiseErr(Location: string = ''; ErrorMsg: string = ''; ErrorType: string = ''; ShowError: Boolean = True): string;
begin
  FLocation := Location;
  FErrorType := ErrorType;
  if not ShowError then
    FErrorMessage := myerrTypeNoErr + ErrorMsg
  else
    FErrorMessage := ErrorMsg;
  Result := FErrorMessage;
  raise Exception.Create(FErrorMessage);
end;


procedure TMyErrors.SetMadExcept;
//настроим madExcept
begin
  //если stTrySyncCallOnSuccess то остановит выполнение пока не будет закрыта окно
  //stDontSync - окно ошибки на переднем плане, выполненные продолжается (с диалогом ошибки оракле ExceptActionHandler при этом у меня виснет после закрытия окна)
//  RegisterExceptionHandler(ExceptionHandler, stDontSync, epMainPhase);
  RegisterExceptionHandler(ExceptionHandler, stTrySyncCallOnSuccess, epMainPhase);
  RegisterExceptActionHandler(ExceptActionHandler, stTrySyncCallOnSuccess);
  madSettings.AppendBugReports := True;
  madSettings.ShowPleaseWaitBox := True;
  madSettings.MailAddr := 'sprokopenko@fr-mix.ru';
  madSettings.MailFrom := 'uchet@fr-mix.ru';
  if User <> nil then
    madSettings.MailFrom := User.GetLogin + '@fr-mix.ru';
  madSettings.MailSubject := 'Ошибка в модуле ' + ModuleRecArr[cMainModule].FileName;
  madSettings.ListThreads := False;
  madSettings.ShowCpuRegisters := False;
  madSettings.ShowBtnCaption := 'Показать отчет';
  madSettings.SendBtnCaption := 'Отправить разработчику';
  madSettings.FrozenMsg := '*';
  madSettings.PrintBtnCaption := 'Распечатать';
  madSettings.ContinueBtnCaption := 'Продолжить выполнение';
  madSettings.CloseBtnCaption := 'Закрыть программу';
  madSettings.RestartBtnCaption := 'Перезапустить программу';
  madSettings.TitleBar := ModuleRecArr[cMainModule].FileName;
  madSettings.ExceptMsg := 'Внимание!. В программе возникла ошибка!';
  madSettings.PrintBtnVisible := False;
  madSettings.PrintBtnCaption := 'Показать запрос';
  madSettings.SendInBackground := True;
  madSettings.AutoSend := False;
//  madSettings.AutoSend:=not(Module.RunFromIDE or (User.GetLogin = 'sprokopenko'));
  madSettings.BugReportFile := 'uchet' + '.bug';
  if User <> nil then
    madSettings.BugReportFile := User.GetLogin + '.bug';
end;

procedure TMyErrors.ExceptionHandler(const exceptIntf: IMEException; var handled: Boolean);
//обработчик исключений madExcept

  procedure RemoveField(const Fields: IMEFields; const FieldName: UnicodeString);
  var
    Index: Integer;
  begin
    Index := exceptIntf.BugReportHeader.FindItem('computer name');
    if Index <> -1 then
      Fields.Delete(Index);
  end;

var
  IsOraError: Boolean;
  KnownErrMsg: string;
begin
  //myinfomessage('1');
  if FIsExceptionHandlerDisabled then begin
    handled := True;
    Exit;
  end;
  //специфическая ошибкас потери связи с Оракле - обработаем особым образом
  if IsOraDisconnect(exceptIntf.ExceptMessage, handled) then begin
    Exit;
  end;
  //работает таймер на закрытие приложения
  //похоже, в этом режиме могут возникать ошибки (в логе были ошибки, связанные вроде с невозможностью переместить окно на передний план , что было у человека - нге отследили)
  //не обрабатывваем и не пишем эти ошибки
  if FrmMain.TimerSrvClose.Enabled then begin
    handled := True;
    Exit;
  end;
  //если установлен признак myerrTypeNoErr, то не выводим окно, ошибку игнорируем
  if (Copy(ErrorMessage, 1, 1) = myerrTypeNoErr) or (ErrorType = myerrTypeNoErr) then begin
    handled := True;
    //сбросим установки параметров вывода ошибки
    SetParam;
    Exit;
  end;
  //полное сообщение об ошибке
  FErrMessageFull := S.IIf(ErrorMessage = '', exceptIntf.ExceptMessage, StringReplace(ErrorMessage, '*', exceptIntf.ExceptMessage, []));
  FErrMessageFull := A.Implode([FLocationGlobal, FErrorMessageGlobal, FLocation, FErrMessageFull], #13#10, True);
  //в заголовок - капшин и сообщение об ошибке
  madSettings.ExceptMsg := A.Implode(
    ['Внимание!. В программе возникла ошибка! Обратитесь к разработчику.' + #13#10, FErrMessageFull], #13#10, True);
  //откроем кнопку Просмотр запроса (это по факту кнопка печати), если это ошибка БД
  IsOraError := (Pos('ORA-', exceptIntf.ExceptMessage) > 0) or (ErrorType = myerrTypeDB);
  madSettings.PrintBtnVisible := IsOraError;
  //добавим в отчет об ошибке поля для оракла (уберем при этом переводы строки)
  if IsOraError then begin
    MESettings.AdditionalFields['SomeField'] := 'SomeText';
    exceptIntf.BugReportHeader['Запрос Oracle'] := StringReplace(Q.LastSql, #13#10, ' ', [rfReplaceAll]);
    exceptIntf.BugReportHeader['Параметры запроса Oracle'] := StringReplace(Q.LastParamsStr, #13#10, '|', [rfReplaceAll]);
    //приходится задавать тут параметры для показа запроса, так как класс БД допускает изменения строк последнего
    //запроса, даже если не включен лог. пока так.
    FErrDBErr := FErrMessageFull;
    FErrDBQuery := Q.LastSql;
    FErrDBParams := Q.LastParamsStr;
  end
  else begin
    exceptIntf.BugReportHeader['Запрос Oracle'] := '';
    exceptIntf.BugReportHeader['Параметры запроса Oracle'] := '';
  end;
  //добавим информация по активной форме и контролу
  exceptIntf.BugReportHeader['Active form'] := S.IIf(Screen.ActiveForm = nil, 'нет', Screen.ActiveForm.Name + ' (' + Screen.ActiveForm.Caption + ')');
  exceptIntf.BugReportHeader['Active control'] := S.IIf(Screen.ActiveControl = nil, 'нет', Screen.ActiveControl.Name);
  try
  //получим сообщение орб ошибке для замены диалога ошибки на ворнинг
    KnownErrMsg := GetKnownErrorMessage(FErrMessageFull);
    if KnownErrMsg <> '' then begin
    //если оно есть - покажем стандартный диалог предупреждения (с дополнительной кнопкой) и выйдем без окна madExcept, и не будем писать в лог
    {$IFDEF SRV}
      //для сервера - установим таймер завершения программы
      Module.CloseAppTimer(AutoCloseIfErrorInterval);
    {$ENDIF}
    //FrmMain.StatusBar.Panels[0].Text:= Emessage;
    //myMessageDlg(st+#13#10+'Данные не изменены!', mtWarning, [mbOK]);
      if IsOraError then begin
      //для ошибки работы с БД выведем кнопку Подробно для просмотра инфы
        if myMessageDlg(KnownErrMsg + #13#10 + 'Данные не изменены!', mtWarning, [mbYes, mbOk], 'Подробно;Ok') = mrYes then begin
          FrmXWOracleError.ShowDialog(FErrDbRow, FErrDBErr, FErrDBQuery, FErrDBParams);
        end;
      end
      else begin
      //для других известных ошибок просто сообщение
        myMessageDlg(KnownErrMsg, mtWarning, [mbOK]);
      end;
      Module.CloseAppTimer(0);
    //FrmMain.StatusBar.Panels[0].Text:= '';
      handled := True;
    //сбросим установки параметров вывода ошибки
      SetParam;
      Exit;
    end;
  //запомним строку лога, на которой остановились по ошибке, для показа ее в окне диалога ошибки оракле
    FErrDbRow := High(Q.LogArray);
  //сформируем массив нужных нам параметров из отчета, и запишем его в локальный лог
    GetBugReportToArr(exceptIntf);
    //запишем в БД последнюю строку локального лога
    LogToDB(exceptIntf);
  //запишем лог на диск
 // LogToDisk(exceptIntf);
    {$IFDEF SRV}
      //для сервера - установим таймер завершения программы
      Module.CloseAppTimer(AutoCloseIfErrorInterval);
    {$ENDIF}
  except
  end;
  //сбросим установки параметров вывода ошибки
  SetParam;
end;

function TMyErrors.GetBugReportToArr(const exceptIntf: IMEException): TVarDynArray;
//сформируем массив нужных нам параметров из отчета, и запишем его в локальный лог
//соберем из отчета нужную инфу для сохранения
var
  va, va1: TVarDynArray;
  i, j: Integer;
  r: Integer;
  st: string;
begin
  try
  //распарсим по строкам
    va := A.ExplodeV(exceptIntf.BugReport, #13#10);
    SetLength(FLogArray, Length(FLogArray) + 1);
  //добавим строку в лог
    r := High(FLogArray) + 1;
    SetLength(FLogArray, r + 1);
    SetLength(FLogArray[r], cmyerrHandled + 1);
  //параметры в массив
    FLogArray[r][cmyerrId] := 0;
    FLogArray[r][cmyerrTime] := Now;  //дата-время
    FLogArray[r][cmyerrModule] := cMainModule;
    FLogArray[r][cmyerrModuleVer] := Module.Version;
    FLogArray[r][cmyerrModuleCompile] := Module.CompileDate;
    FLogArray[r][cmyerrMessage] := FErrMessageFull; //!!!exceptIntf.ExceptMessage;  //сообщение об ошибке
    FLogArray[r][cmyerrUserLogin] := '<before logged>';       //если еще не было логина юзера
    if User <> nil then
      FLogArray[r][cmyerrUserLogin] := User.GetLogin;  //если был логин
    FLogArray[r][cmyerrMashineUser] := va[2] + ';  ' + va[1];  // машина и юзер ОС
  //вычленим информацию по стеку и добавленные вручную данные по бд
    j := 0;
    st := '';
    for i := 0 to High(va) do begin
      if va[i] = '' then
        Break;
      S.ConcatStP(FLogArray[r][cmyerrGeneral], va[i], #13#10);
      if Pos('Запрос Oracle', va[i]) = 1 then begin
        va1 := A.Explode(va[i], ':');
        Delete(va1, 0, 1);
        FLogArray[r][cmyerrSql] := Trim(A.Implode(va1, ':'));
      end;
      if Pos('Параметры запроса Oracle', va[i]) = 1 then begin
        va1 := A.Explode(va[i], ':');
        Delete(va1, 0, 1);
        FLogArray[r][cmyerrSqlParams] := Trim(A.Implode(va1, ':'));
//        FLogArray[r][cmyerrSqlParams] := va[i];
      end;
    end;
    j := i + 2;
    for i := j to High(va) do begin
      if va[i] = '' then
        Continue;
      if va[i] =  'modules:' then
        Break;
//    FLogArray[r][cmyerrStack]:=FLogArray[r][cmyerrStack] + Copy(va[i], Pos('    ', va[i]) + 4) + #13#10;
      S.ConcatStP(FLogArray[r][cmyerrStack], va[i], #13#10);
    end;
  //обрежим длинные строки
    for i := 0 to High(FLogArray[r]) do
      if Length(VarToStr(FLogArray[r][i])) > 4000 then
        FLogArray[r][i] := Copy(FLogArray[r][i], 1, 4000);
  except
  end;
end;

procedure TMyErrors.LogToDb(const exceptIntf: IMEException);
//пишем последнюю строку лога в БД
//пишем вручную, вложенные запросы (во время ошибок в процедурах-обертках запросов) - портят аналитику (логи)
type
  Win1252String = type AnsiString(1252);
var
  i, r: Integer;
  st: string;
  wst: WideString;
begin
  if not (cmyDebugSendErrToDb) then
    Exit;
  if Module = nil then
    Exit;
  //не писать ошибки под ИДЕ
  if cmyDebugNOSavefromIDE and Module.RunFromIDE then
    Exit;
  try
    r := High(FLogArray);
    if (not Q.Connected) or (r < 0) then
      Exit;
    if not Q.AdoConnection.InTransaction then begin
      //в инсерт можно передать поля типа CLob как ftString, но ни в uppdate, ни пареметрами функции или процедуры это не получвается (с разными ошибками),
      //правильно должны бы передаваться как ftWideMemo, и также надо бы установить .Size:=Length(exceptIntf.BugReport), но ничего из этого не помогает!
      //поэтому если мы не в транзакции, то вызываем инсерт, иначе фуннкцию с автономной транзакцией, но в нее не передаем CLob-поля
      Q.ADOQueryService.Close;
      Q.ADOQueryService.SQL.Text := 'insert into adm_error_log (' + 'dt, userlogin, id_module, ver, compile_dt, mashineinfo, message, sql, sqlparams, general, stack, handled, pictc, fullreportc, ide) values (' +   //,module,version
        ':dt, :userlogin, :id_module, :ver, :compile_dt, :mashineinfo, :message, :sql, :sqlparams, :general, :stack, :handled, :pictc, :fullreportc, :ide)';
      for i := 0 to Q.ADOQueryService.Parameters.Count - 1 do begin
        Q.ADOQueryService.Parameters[i].DataType := ftString;
        Q.ADOQueryService.Parameters[i].Attributes := [paNullable];
      end;
      Q.ADOQueryService.Parameters.ParamByName('dt').DataType := ftDateTime;
      Q.ADOQueryService.Parameters.ParamByName('dt').Value := VarToDateTime(FLogArray[r][cmyerrTime]);
      Q.ADOQueryService.Parameters.ParamByName('userlogin').Value := FLogArray[r][cmyerrUserLogin];
      Q.ADOQueryService.Parameters.ParamByName('id_module').Value := FLogArray[r][cmyerrModule];
      Q.ADOQueryService.Parameters.ParamByName('ver').Value := FLogArray[r][cmyerrModuleVer];
      Q.ADOQueryService.Parameters.ParamByName('compile_dt').Value := FLogArray[r][cmyerrModuleCompile];
      Q.ADOQueryService.Parameters.ParamByName('mashineinfo').Value := FLogArray[r][cmyerrMashineUser];
      Q.ADOQueryService.Parameters.ParamByName('message').Value := FLogArray[r][cmyerrMessage];
      Q.ADOQueryService.Parameters.ParamByName('sql').Value := FLogArray[r][cmyerrSql];
      Q.ADOQueryService.Parameters.ParamByName('sqlparams').Value := FLogArray[r][cmyerrSqlParams];
      Q.ADOQueryService.Parameters.ParamByName('general').Value := FLogArray[r][cmyerrGeneral];
      Q.ADOQueryService.Parameters.ParamByName('stack').Value := FLogArray[r][cmyerrStack];
      Q.ADOQueryService.Parameters.ParamByName('handled').Value := FLogArray[r][cmyerrHandled];
      Q.ADOQueryService.Parameters.ParamByName('pictc').Value := null; //AnsiToUtf8(exceptIntf.ScreenShot.AsBmpStr);
      Q.ADOQueryService.Parameters.ParamByName('fullreportc').Value :=  exceptIntf.BugReport;
      Q.ADOQueryService.Parameters.ParamByName('ide').Value := S.IIf(Module.RunFromIDE, 1, 0);
      Q.ADOQueryService.ExecSQL;
      Q.ADOQueryService.Close;
    end
    else begin
      Q.ADOQueryService.Close;
      Q.ADOQueryService.SQL.Text :=
        'select F_To_Adm_Error_Log(' +
        ':dt, :userlogin, :id_module, :ver, :compile_dt, :mashineinfo, :message, :sql, :sqlparams, :general, :stack, :handled, null, null, :ide) '+ //:pictc, :fullreportc
        'from dual';
      for i := 0 to Q.ADOQueryService.Parameters.Count - 1 do begin
        Q.ADOQueryService.Parameters[i].DataType := ftString;
        Q.ADOQueryService.Parameters[i].Attributes := [paNullable];
      end;
      Q.ADOQueryService.Parameters.ParamByName('dt').DataType := ftDateTime;
      Q.ADOQueryService.Parameters.ParamByName('dt').Value := VarToDateTime(FLogArray[r][cmyerrTime]);
      Q.ADOQueryService.Parameters.ParamByName('userlogin').Value := FLogArray[r][cmyerrUserLogin];
      Q.ADOQueryService.Parameters.ParamByName('id_module').Value := FLogArray[r][cmyerrModule];
      Q.ADOQueryService.Parameters.ParamByName('ver').Value := FLogArray[r][cmyerrModuleVer];
      Q.ADOQueryService.Parameters.ParamByName('compile_dt').Value := FLogArray[r][cmyerrModuleCompile];
      Q.ADOQueryService.Parameters.ParamByName('mashineinfo').Value := FLogArray[r][cmyerrMashineUser];
      Q.ADOQueryService.Parameters.ParamByName('message').Value := FLogArray[r][cmyerrMessage];
      Q.ADOQueryService.Parameters.ParamByName('sql').Value := FLogArray[r][cmyerrSql];
      Q.ADOQueryService.Parameters.ParamByName('sqlparams').Value := FLogArray[r][cmyerrSqlParams];
      Q.ADOQueryService.Parameters.ParamByName('general').Value := FLogArray[r][cmyerrGeneral];
      Q.ADOQueryService.Parameters.ParamByName('stack').Value := FLogArray[r][cmyerrStack];
      Q.ADOQueryService.Parameters.ParamByName('handled').Value := FLogArray[r][cmyerrHandled];
      Q.ADOQueryService.Parameters.ParamByName('ide').Value := S.IIf(Module.RunFromIDE, 1, 0);
      Q.ADOQueryService.ExecSQL;
      Q.ADOQueryService.Close;
{      Q.ADOQueryService.SQL.Text := 'update adm_error_log set pictc = :pictc, fullreportc = :fullreportc where id = (select max(id) from adm_error_log)';
      for i := 0 to Q.ADOQueryService.Parameters.Count - 1 do begin
        Q.ADOQueryService.Parameters[i].DataType := ftBLob;
        Q.ADOQueryService.Parameters[i].Attributes := [paNullable];
      end;
      Q.ADOQueryService.Parameters.ParamByName('pictc').Value := null; //AnsiToUtf8(exceptIntf.ScreenShot.AsBmpStr);
      Q.ADOQueryService.Parameters.ParamByName('fullreportc').Size:=200000;
      Q.ADOQueryService.Parameters.ParamByName('fullreportc').Value :=  exceptIntf.BugReport;
      Q.ADOQueryService.ExecSQL;
      Q.ADOQueryService.Close;
      }
(* {

//  wst:=exceptIntf.ScreenShot.AsBmpStr;
  wst:=exceptIntf.ScreenShot.AsBmpStr;
  setlength(St,Length(WSt));
 for I := 1 to length(WSt) do
 begin
 St[I]:= char(WSt[I]);
 end; //

 st:=Utf8Encode(WideString(exceptIntf.ScreenShot.AsBmpStr));
 }
      Q.AdoStoredProc.Parameters.Clear;
      Q.AdoStoredProc.ProcedureName := 'P_To_Adm_Error_Log';
      Q.AdoStoredProc.Parameters.CreateParameter('dt', ftDatetime, pdInput, 0, VarToDateTime(FLogArray[r][cmyerrTime]));
      Q.AdoStoredProc.Parameters.CreateParameter('userlogin', ftString, pdInput, 4000, VarToStr(FLogArray[r][cmyerrUserLogin]));
      Q.AdoStoredProc.Parameters.CreateParameter('id_module', ftString, pdInput, 4000, VarToStr(FLogArray[r][cmyerrModule]));
      Q.AdoStoredProc.Parameters.CreateParameter('ver', ftString, pdInput, 4000, VarToStr(FLogArray[r][cmyerrModuleVer]));
      Q.AdoStoredProc.Parameters.CreateParameter('compile_dt', ftString, pdInput, 4000, VarToStr(FLogArray[r][cmyerrModuleCompile]));
      Q.AdoStoredProc.Parameters.CreateParameter('mashineinfo', ftString, pdInput, 4000, VarToStr(FLogArray[r][cmyerrMashineUser]));
      Q.AdoStoredProc.Parameters.CreateParameter('message', ftString, pdInput, 4000, VarToStr(FLogArray[r][cmyerrMessage]));
      Q.AdoStoredProc.Parameters.CreateParameter('sql', ftString, pdInput, 4000, VarToStr(FLogArray[r][cmyerrSql]));
      Q.AdoStoredProc.Parameters.CreateParameter('sqlparams', ftString, pdInput, 4000, VarToStr(FLogArray[r][cmyerrSqlParams]));
      Q.AdoStoredProc.Parameters.CreateParameter('general', ftString, pdInput, 4000, VarToStr(FLogArray[r][cmyerrGeneral]));
      Q.AdoStoredProc.Parameters.CreateParameter('stack', ftString, pdInput, 4000, VarToStr(FLogArray[r][cmyerrStack]));
      Q.AdoStoredProc.Parameters.CreateParameter('handled', ftString, pdInput, 4000, VarToStr(FLogArray[r][cmyerrHandled]));
//  Q.AdoStoredProc.Parameters.CreateParameter('pictc' ,ftOraClob, pdInput, 4000000, AnsiToUtf8(exceptIntf.ScreenShot.AsBmpStr));
//  Q.AdoStoredProc.Parameters.CreateParameter('fullreportc' ,ftOraClob, pdInput, 4000000, exceptIntf.BugReport);
//      Q.AdoStoredProc.Parameters.CreateParameter('pictc', ftString, pdInput, 200000, '');  //!!!
      Q.AdoStoredProc.Parameters.CreateParameter('pictc', ftString, pdInput, 2, '');
//  Q.AdoStoredProc.Parameters.ParamByName('pictc').Value:= AnsiToUtf8(exceptIntf.ScreenShot.AsBmpStr);
      Q.AdoStoredProc.Parameters.CreateParameter('fullreportc', ftString, pdInput, 100000, exceptIntf.BugReport);
      Q.AdoStoredProc.Parameters.CreateParameter('ide', ftString, pdInput, 10, S.IIf(Module.RunFromIDE, 1, 0));
      for i := 0 to Q.AdoStoredProc.Parameters.Count - 1 do
        Q.AdoStoredProc.Parameters[i].Attributes := [paNullable];
      Q.AdoStoredProc.ExecProc;
*)
    end;
  except
  end;
end;

function TMyErrors.IsOraDisconnect(EMessage: string; var handled: Boolean): Boolean;
//проверим, что эта ошибка - отвал БД оракла
//в этом случае, установим признак обработанной ошибки, чтобы не выходило окно ошибки, и выведем свое окно
var
  b : Boolean;
begin
  Result := False;
  b := not Q.Connected or ((pos('ORA-03113', EMessage) > 0) or (pos('ORA-03114', EMessage) > 0) or (pos('ORA-12170', EMessage) > 0));
  if b then begin
    IsExceptionHandlerDisabled := True;
    {$IFDEF SRV}
    //если нет связи с ораклом, для сервера просто завершим программу
    //FrmMain.Close;
    //завершаем немедленно, во избежании возможных ошибок
    Halt;
    Exit;
    {$ENDIF}
    //не пытаемся повторно выводить окно сообщения, это вызовет ошибку! Сразу завершимся
    if FrmXDmsgNoConnection.Visible
      then Halt;
    //окно сообщения о потере связи с БД
    FrmXDmsgNoConnection.ShowModal;
    handled := True;
    Result := True;
  end;
end;

procedure TMyErrors.LogToDisk(const exceptIntf: IMEException);
var
  r: Integer;
  Path, FName, st: string;
begin
  if not (cmyDebugSendErrToDisk) and (Module = nil) then
    Exit;
  if not (cmyDebugSendErrToDisk) and (Module.RunFromIDE) then
    Exit;
  try
    r := High(FLogArray);
    if (User = nil) or (Module = nil) then
      Path := 'D:\'
    else
      Path := Module.GetPath_ErrorLog(User.GetLogin, FLogArray[r][cmyerrTime]);
    ForceDirectories(Path);
    Sys.SaveTextToFile(Path + '\' + cmyerrBugReportFileName, VarToStr(FLogArray[r][cmyerrTime]) + #13#10#13#10 + VarToStr(FLogArray[r][cmyerrUserLogin]) + #13#10#13#10 + VarToStr(FLogArray[r][cmyerrMashineUser]) + #13#10#13#10 + VarToStr(FLogArray[r][cmyerrMessage]) + #13#10#13#10 + VarToStr(FLogArray[r][cmyerrSql]) + #13#10#13#10 + VarToStr(FLogArray[r][cmyerrSqlParams]) + #13#10#13#10 + VarToStr(FLogArray[r][cmyerrStack]) + #13#10#13#10 + VarToStr(FLogArray[r][cmyerrHandled]), False);
//  MadSettings.BugReportFile:=Module.GetPath_ErrorLog(User.GetLogin, FLogArray[r][cmyerrTime]) + '\' + cmyerrBugReportFileName;
  //exceptIntf.ScreenShot.SavePng(Path + '\' + cmyerrScreenShotFileName);
{  Q.ADOQueryService.Close;
  Q.ADOQueryService.SQL.Text:='update adm_error_log set pict = :pict where id = 1';
  Q.ADOQueryService.Parameters[0].DataType:=ftBlob;
  Q.ADOQueryService.Parameters[0].Attributes:=[paNullable];
  Q.ADOQueryService.Parameters[0].Value:=exceptIntf.ScreenShot.AsBmpStr;
  Q.ADOQueryService.ExecSQL;
  Q.ADOQueryService.Close;
  Sys.SaveTextToFile('r:\pict1.bmp',exceptIntf.ScreenShot.AsBmpStr);
  Q.ADOQueryService.SQL.Text:='select pict from adm_error_log where id = 1';
  Q.ADOQueryService.Open;
  Sys.SaveTextToFile('r:\pict2.bmp', AnsiToUtf8(Q.ADOQueryService.Fields[0].AsString));
  Q.ADOQueryService.Close;
 }
  except
  end;
end;

procedure TMyErrors.ExceptActionHandler(action: TExceptAction; const exceptIntf: IMEException; var handled: Boolean);
//Обработчик событий madExcept
begin
  if action = eaPrintBugReport then begin
    handled := True;
    FrmXWOracleError.ShowDialog(FErrDbRow, FErrDBErr, FErrDBQuery, FErrDBParams);
  end;
  if action = eaSaveBugReport then begin
//    Sys.SaveTextToFile('__err', exceptIntf.BugReport); //GetThreadStackTrace);
//    Sys.SaveTextToFile('_err', exceptIntf.ExceptMessage, True);
//++    Sys.SaveTextToFile('_err', A.Implode(GetBugReportToArr(exceptIntf), #13#10#10#10));
//    handled:=False;
//    LogToDisk(exceptIntf);
//    handled:=True;
  end;
end;


//=============================================================================//

//

procedure TMyErrors.myError(EMessage: string; IsOraWarning: Boolean = False);
var
  st: string;
begin
//    Module.ErrMessage:=EMessage; exit;
{if pos(#1, EMessage) <> 1
  then begin
    Module.ErrMessage:=EMessage;
    raise Exception.Create(#1 + EMessage);
  end;

exit;}
  //если нет коннекшена выведем сообщение и завершаем программу
  if (pos('ORA-03114', EMessage) > 0) or (pos('ORA-12170', EMessage) > 0) then begin
      {$IFDEF SRV}
      //если нет связи с ораклом, для сервера просто завершим программу
    FrmMain.Close;
    exit;
      {$ENDIF}
    FrmXDmsgNoConnection.ShowModal;
  end;
//++  st:=GetOraMessages(EMessage);
  if st <> '' then begin
      {$IFDEF SRV}
    Module.CloseAppTimer(AutoCloseIfErrorInterval);
      {$ENDIF}
    FrmMain.StatusBar.Panels[0].Text := EMessage;
      //myMessageDlg(st+#13#10+'Данные не изменены!', mtWarning, [mbOK]);
    if myMessageDlg(st + #13#10 + 'Данные не изменены!', mtWarning, [mbYes, mbOk], 'Подробно;Ok') = mrYes then begin
      FrmXWOracleError.ShowDialog(-1);
    end;
    Module.CloseAppTimer(0);
    FrmMain.StatusBar.Panels[0].Text := '';
    Exit;
  end;
  {$IFDEF SRV}
  Module.CloseAppTimer(AutoCloseIfErrorInterval);
  {$ENDIF}
  //++Dlg_Error.MsgText:= EMessage;
  //++Dlg_Error.OraWarning:= IsOraWarning;
//  Dlg_Error.ShowModal;
  Module.CloseAppTimer(0);
  if pos(#1, EMessage) <> 1 then begin
    raise Exception.Create(#1 + EMessage);
  end;
end;

procedure TMyErrors.RaiseError(ErrorMsg: string = ''; Prefix: string = ''; ShowError: Boolean = True);
begin
{
  if (not ShowError)or(ErrorMessage='')
      then begin FSetErrorMessage:=''; Exit; end;
  if ErrorMsg = '' then ErrorMsg:= ErrorMessage;
  FSetErrorMessage:='';
  ErrorMsg := A.ImplodeNotEmpty([Prefix, ErrorMsg], ' ');
  raise Exception.Create(ErrorMsg);}
end;

procedure TMyErrors.ShowErrorBox;
begin
//  madExcept.IMEException.Show;
  NewException;
end;

procedure TMyErrors.PreSetKnownErrors;
begin
{(*}
  FKnownErrors := [
    //при выполнениее MemTable.RefresrRecord, если запись была удалена
    ['There are no fresh record on server', '*', 'Эта запись была удалена!'],

    [oraeChildFound, '*', 'Эта запись используется в других таблицах'],
    [oraeNumberTooLarge, '*', 'Число слишком длинное.'],
    [oraePkNotFound, '*', 'Данные не найдены в справочнике.'],
    [oraeStringTooLarge, '*', 'Строка слишком длинная.'],
    [oraeChildFound, '*', 'Эта запись используется в других таблицах.'],
    [oraeCannotInsertNull, '*', 'Задана пустая строка, что недопустимо.'],
    [oraeCannotUpdateNull, '*', 'Задана пустая строка, что недопустимо.'],    //+++чаще всего эту запись надо убирать, так как там первичный ключ, а это обычно ошибка. но если индекс, то это правильно
    [oraeNonUnique, '*', 'Данные должны быть уникальными.'],
    [oraeDeadLock, '*', 'Взаимная блокировка в базе данных. Попробуйте выполнить операцию позднее.'],


    [oraeChildFound, 'fk_or_otk_rejected_res', 'Эта запись используется в таблице приемки ОТК'],
    ['', 'IDX_REF_OTK_REJECT_REASONS_N', 'Причина неприемки ОТК должна быть уникальна (без учета регистра букв)']];
{*)}
(*

Img	Constraint	Schema	Table	Type	Enabled	Last DDL	Validated	Deferrable	Deferred	Delete Rule	Generated
	FK_ADM_USER_CFG_ID_MODULE	UCHET22	ADM_USER_CFG	R	Yes	23/05/2024 13:05:10	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_ADM_USER_CFG_ID_USER	UCHET22	ADM_USER_CFG	R	Yes	23/05/2024 13:05:11	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_ADM_USER_ROLES_ID_ROLE	UCHET22	ADM_USER_ROLES	R	Yes	23/05/2024 13:05:10	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_ADM_USER_ROLES_ID_USER	UCHET22	ADM_USER_ROLES	R	Yes	23/05/2024 13:05:11	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_DELAYED_PROD_REASONS_OR	UCHET22	DELAYED_PROD_REASONS	R	Yes	23/05/2024 13:05:16	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_DELAYED_PROD_REASONS_RES	UCHET22	DELAYED_PROD_REASONS	R	Yes	23/05/2024 13:05:12	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_ESTIMATES_ORDER_ITEM	UCHET22	ESTIMATES	R	Yes	23/05/2024 13:05:16	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_ESTIMATES_STD_ITEM	UCHET22	ESTIMATES	R	Yes	23/05/2024 13:05:17	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_ESTIMATE_ITEMS_COMMENT	UCHET22	ESTIMATE_ITEMS	R	Yes	23/05/2024 13:05:11	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_ESTIMATE_ITEMS_ESTIMATE	UCHET22	ESTIMATE_ITEMS	R	Yes	23/05/2024 13:05:12	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_ESTIMATE_ITEMS_GROUP	UCHET22	ESTIMATE_ITEMS	R	Yes	23/05/2024 13:05:11	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_ESTIMATE_ITEMS_NAME	UCHET22	ESTIMATE_ITEMS	R	Yes	23/05/2024 13:05:11	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_ESTIMATE_ITEMS_RESALE	UCHET22	ESTIMATE_ITEMS	R	Yes	23/05/2024 13:05:17	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_ESTIMATE_ITEMS_UNIT	UCHET22	ESTIMATE_ITEMS	R	Yes	23/05/2024 13:05:11	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_GRID_LABELS_USER	UCHET22	GRID_LABELS	R	Yes	23/05/2024 13:05:11	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_J_CANDIDATES_AD	UCHET22	J_CANDIDATES	R	Yes	23/05/2024 13:05:12	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_J_CANDIDATES_DIVISION	UCHET22	J_CANDIDATES	R	Yes	23/05/2024 13:05:12	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_J_CANDIDATES_HEAD	UCHET22	J_CANDIDATES	R	Yes	23/05/2024 13:05:14	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_J_CANDIDATES_JOB	UCHET22	J_CANDIDATES	R	Yes	23/05/2024 13:05:13	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_J_CANDIDATES_STATUS	UCHET22	J_CANDIDATES	R	Yes	23/05/2024 13:05:12	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_J_CANDIDATES_VACANCY	UCHET22	J_CANDIDATES	R	Yes	23/05/2024 13:05:15	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_J_DEVELOPMENT_ID_DEVELTYPE	UCHET22	J_DEVELOPMENT	R	Yes	23/05/2024 13:05:12	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_J_VACANCY_DIVISION	UCHET22	J_VACANCY	R	Yes	23/05/2024 13:05:12	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_J_VACANCY_HEAD	UCHET22	J_VACANCY	R	Yes	23/05/2024 13:05:14	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_J_VACANCY_JOB	UCHET22	J_VACANCY	R	Yes	23/05/2024 13:05:13	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_J_WORKER_STATUS_DIV	UCHET22	J_WORKER_STATUS	R	Yes	23/05/2024 13:05:12	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_J_WORKER_STATUS_JOB	UCHET22	J_WORKER_STATUS	R	Yes	23/05/2024 13:05:13	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_J_WORKER_STATUS_WORKER	UCHET22	J_WORKER_STATUS	R	Yes	23/05/2024 13:05:14	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_ORDERS_ADD_ORDER	UCHET22	ORDERS_ADD	R	Yes	23/05/2024 13:05:16	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_ORDERS_CUSTOMER	UCHET22	ORDERS	R	Yes	23/05/2024 13:05:12	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_ORDERS_CUSTOMER_CONTACT	UCHET22	ORDERS	R	Yes	23/05/2024 13:05:12	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_ORDERS_CUSTOMER_ORG	UCHET22	ORDERS	R	Yes	23/05/2024 13:05:12	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_ORDERS_ESTIMATES	UCHET22	ORDERS	R	Yes	23/05/2024 13:05:17	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_ORDERS_FORMAT	UCHET22	ORDERS	R	Yes	23/05/2024 13:05:16	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_ORDERS_MANAGER	UCHET22	ORDERS	R	Yes	23/05/2024 13:05:11	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_ORDERS_ORGANIZATION	UCHET22	ORDERS	R	Yes	23/05/2024 13:05:13	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_ORDER_COMPLAINTS_ID_ORDER	UCHET22	ORDER_COMPLAINTS	R	Yes	23/05/2024 13:05:16	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_ORDER_COMPLAINTS_ID_REASON	UCHET22	ORDER_COMPLAINTS	R	Yes	23/05/2024 13:05:12	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_ORDER_ITEMS_ID_ORDER	UCHET22	ORDER_ITEMS	R	Yes	23/05/2024 13:05:16	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_ORDER_ITEMS_KNS	UCHET22	ORDER_ITEMS	R	Yes	23/05/2024 13:05:10	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_ORDER_ITEMS_STD_ITEM	UCHET22	ORDER_ITEMS	R	Yes	23/05/2024 13:05:17	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_ORDER_ITEMS_THN	UCHET22	ORDER_ITEMS	R	Yes	23/05/2024 13:05:10	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_ORDER_ITEM_STAGES_ORITEM	UCHET22	ORDER_ITEM_STAGES	R	Yes	23/05/2024 13:05:16	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_OR_FORMAT_ESTIMATES_F	UCHET22	OR_FORMAT_ESTIMATES	R	Yes	23/05/2024 13:05:16	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_OR_MONTAGE_OR	UCHET22	OR_MONTAGE	R	Yes	23/05/2024 13:05:16	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_OR_OTK_REJECTED_OR	UCHET22	OR_OTK_REJECTED	R	Yes	23/05/2024 13:05:16	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_OR_OTK_REJECTED_RES	UCHET22	OR_OTK_REJECTED	R	Yes	23/05/2024 13:05:13	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_OR_PAYMENTS_N_ORDER	UCHET22	OR_PAYMENTS_N	R	Yes	23/05/2024 13:05:16	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_OR_PAYMENTS_ORDER	UCHET22	OR_PAYMENTS	R	Yes	23/05/2024 13:05:16	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_OR_STD_ITEMS_EST	UCHET22	OR_STD_ITEMS	R	Yes	23/05/2024 13:05:16	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_PAYROLL_DIV	UCHET22	PAYROLL	R	Yes	23/05/2024 13:05:12	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_PAYROLL_ITEM_JOB	UCHET22	PAYROLL_ITEM	R	Yes	23/05/2024 13:05:13	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_PAYROLL_ITEM_PAYROLL	UCHET22	PAYROLL_ITEM	R	Yes	23/05/2024 13:05:17	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_PAYROLL_ITEM_WORKER	UCHET22	PAYROLL_ITEM	R	Yes	23/05/2024 13:05:14	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_PAYROLL_METHOD	UCHET22	PAYROLL	R	Yes	23/05/2024 13:05:17	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_PAYROLL_WORKER	UCHET22	PAYROLL	R	Yes	23/05/2024 13:05:14	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_PICK_ADDCOMPL_ID_ITEM	UCHET22	PICK_ADDCOMPL	R	Yes	23/05/2024 13:05:17	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_PICK_FITTINGS_ID_FITTING	UCHET22	PICK_FITTINGS	R	Yes	23/05/2024 13:05:17	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_PICK_FITTINGS_ID_ITEM	UCHET22	PICK_FITTINGS	R	Yes	23/05/2024 13:05:17	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_PICK_ITEMS_ID_COLOR	UCHET22	PICK_ITEMS	R	Yes	23/05/2024 13:05:12	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_PICK_ITEMS_ID_GROUP	UCHET22	PICK_ITEMS	R	Yes	23/05/2024 13:05:17	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_PICK_LOG_ID_ITEM	UCHET22	PICK_LOG	R	Yes	23/05/2024 13:05:17	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_PICK_LOG_ID_USER	UCHET22	PICK_LOG	R	Yes	23/05/2024 13:05:11	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_PICK_PANELS_ID_ITEM	UCHET22	PICK_PANELS	R	Yes	23/05/2024 13:05:17	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_REF_CUSTOMER_CONTACT	UCHET22	REF_CUSTOMER_CONTACT	R	Yes	23/05/2024 13:05:12	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_REF_CUSTOMER_LEGAL	UCHET22	REF_CUSTOMER_LEGAL	R	Yes	23/05/2024 13:05:12	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_REF_DIVISIONS_HEAD	UCHET22	REF_DIVISIONS	R	Yes	23/05/2024 13:05:14	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_REF_ESTIMATE_REPLACE_NEW	UCHET22	REF_ESTIMATE_REPLACE	R	Yes	23/05/2024 13:05:11	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_REF_ESTIMATE_REPLACE_OLD	UCHET22	REF_ESTIMATE_REPLACE	R	Yes	23/05/2024 13:05:11	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_REF_EXPENSEITEMS_GROUP	UCHET22	REF_EXPENSEITEMS	R	Yes	23/05/2024 13:05:13	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_REP_SALARY_ID_JOB	UCHET22	REP_SALARY	R	Yes	23/05/2024 13:05:13	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_SN_CALENDAR_ACCOUNTS_EXP	UCHET22	SN_CALENDAR_ACCOUNTS	R	Yes	23/05/2024 13:05:13	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_SN_CALENDAR_ACCOUNTS_ORG	UCHET22	SN_CALENDAR_ACCOUNTS	R	Yes	23/05/2024 13:05:13	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_SN_CALENDAR_ACCOUNTS_SPL	UCHET22	SN_CALENDAR_ACCOUNTS	R	Yes	23/05/2024 13:05:13	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_SN_CALENDAR_ACCOUNTS_T_CT	UCHET22	SN_CALENDAR_ACCOUNTS_T	R	Yes	23/05/2024 13:05:13	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_SN_CALENDAR_ACCOUNTS_T_ID	UCHET22	SN_CALENDAR_ACCOUNTS_T	R	Yes	23/05/2024 13:05:14	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_SN_CALENDAR_PAYMENTS_ACC	UCHET22	SN_CALENDAR_PAYMENTS	R	Yes	23/05/2024 13:05:15	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_SN_CALENDAR_T_BASIS_ID_A	UCHET22	SN_CALENDAR_T_BASIS	R	Yes	23/05/2024 13:05:14	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_SN_CALENDAR_T_BASIS_ID_AB	UCHET22	SN_CALENDAR_T_BASIS	R	Yes	23/05/2024 13:05:15	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_SN_CALENDAR_T_ROUTE_ID_A	UCHET22	SN_CALENDAR_T_ROUTE	R	Yes	23/05/2024 13:05:15	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_SN_CALENDAR_T_ROUTE_P1	UCHET22	SN_CALENDAR_T_ROUTE	R	Yes	23/05/2024 13:05:13	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_SN_CALENDAR_T_ROUTE_P2	UCHET22	SN_CALENDAR_T_ROUTE	R	Yes	23/05/2024 13:05:13	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_SN_DEFECTIVES_ACCOUNT	UCHET22	SN_DEFECTIVES	R	Yes	23/05/2024 13:05:14	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_SN_DEFECTIVES_ACT_D	UCHET22	SN_DEFECTIVES_ACT	R	Yes	23/05/2024 13:05:15	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_SN_DEFECTIVES_ACT_ITEMS_D	UCHET22	SN_DEFECTIVES_ACT_ITEMS	R	Yes	23/05/2024 13:05:15	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_SN_DEFECTIVES_ACT_USER	UCHET22	SN_DEFECTIVES_ACT	R	Yes	23/05/2024 13:05:11	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_SN_DEFECTIVES_USER	UCHET22	SN_DEFECTIVES	R	Yes	23/05/2024 13:05:10	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_TURV_DAY_DIV	UCHET22	TURV_DAY	R	Yes	23/05/2024 13:05:12	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_TURV_DAY_TURVCODE1	UCHET22	TURV_DAY	R	Yes	23/05/2024 13:05:14	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_TURV_DAY_TURVCODE2	UCHET22	TURV_DAY	R	Yes	23/05/2024 13:05:14	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_TURV_DAY_TURVCODE3	UCHET22	TURV_DAY	R	Yes	23/05/2024 13:05:14	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_TURV_DAY_TURV_WORKER	UCHET22	TURV_DAY	R	Yes	23/05/2024 13:05:15	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_TURV_DAY_WORKER	UCHET22	TURV_DAY	R	Yes	23/05/2024 13:05:14	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_TURV_PERIOD_DIV	UCHET22	TURV_PERIOD	R	Yes	23/05/2024 13:05:12	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_TURV_WORKER_DIV	UCHET22	TURV_WORKER	R	Yes	23/05/2024 13:05:12	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_TURV_WORKER_JOB	UCHET22	TURV_WORKER	R	Yes	23/05/2024 13:05:13	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME
	FK_TURV_WORKER_TURV	UCHET22	TURV_WORKER	R	Yes	23/05/2024 13:05:15	Yes	NOT DEFERRABLE	IMMEDIATE	CASCADE	USER NAME
	FK_TURV_WORKER_WORKER	UCHET22	TURV_WORKER	R	Yes	23/05/2024 13:05:14	Yes	NOT DEFERRABLE	IMMEDIATE	NO ACTION	USER NAME


*)


end;

function TMyErrors.GetKnownErrorMessage(ErrorMessage: string): string;
var
  i, j, p1, p2: Integer;
  va, va1: TVarDynArray;
begin
  Result := '';
  va := [-1];
  for i := 0 to High(FKnownErrors) do begin
    if FKnownErrors[i][0] = '' then
      p1 := 1;
    p1 := S.PosI(FKnownErrors[i][0], ErrorMessage);
    if FKnownErrors[i][1] = '*' then
      p2 := 100000
    else begin
      va1 := A.ExplodeV(FKnownErrors[i][0], ';');
      for j := 0 to High(va1) do begin
        p1 := S.PosI(FKnownErrors[i][1], ErrorMessage);
        if p1 > 0 then
          Break;
      end;
    end;
    if (p1 > 0) and (p2 > p1) then
      if FKnownErrors[i][1] = '*' then
        va[0] := i
      else
        va := va + [i];
  end;
  if (High(va) = 0) and (va[0] = -1) then
    Exit;
  if (High(va) = 0) then
    Result := FKnownErrors[S.VarToInt(va[0])][2]
  else begin
    for i := 1 to High(va) do
      S.ConcatStP(Result, FKnownErrors[S.VarToInt(va[i])][2], #13#10);
  end;
end;

procedure TMyErrors.TestError;
var
  i: Integer;
begin
  i:= i div i;
end;

procedure TMyErrors.Test;
var
  va: TVarDynArray;
begin
  try
    MyInfoMessage(IntToStr(Q.QExecSql('update test1 set dt = sysdate where id = :id', ['aaa'], True)));
    //здесь ошибка, она в try/except, вызывается сразу, после MyInfoMessage выдает -1
  {0}
    va[10] := 0; //здесь ошибка
  finally
 {1}              MyInfoMessage('finally'); //выдается сообщение, затем диалог ошибки
  end;
  MyInfoMessage('end'); //это не выполняется
//если данная конструкция вызывалась из других процеддур без обертки try, то сразу вываливается
//после {1} в основной поток.
//если в вызывающих процедурах были блоки try-finally {2} end
//то они выполнятся в последовательности от самого глубоко вложенного, в данном случае: 1, потом 2,
//и вылетят в основной поток и только потом будет сообщение об ошибке в {0}
//конструкция try-except-end на любом этапе прерывает этот вылет для процедуры,
//в которой она находится
//после finally ничто выполняться не будет
//если исключение отловлено except, то выполнение продолжится после него
//если где-то в цепочке стека вызовов исключение поймано except, то в дальнейшем оно обрабатываться
//не будет и пойдет обычное выполнение программы. при этом except подавит вывод сообщение об ошибке,
//которая ранее не была обработана, чтобы вывести сообщение надо в него вставить конструкцию
//  except on E: Exception do Application.ShowException(E);
//если ошибка обработана в except надо, очевидно, проверять результат выполнения предыдущего кода
{
}


  Exit;

  try
    MyInfoMessage(IntToStr(Q.QExecSql('update test1 set dt = sysdate where id = :id', VarArrayOf([423, '--']), True)));
    va[100] := 10;
  finally
    MyInfoMessage('except');
  end;
  MyInfoMessage('end');
  Exit;
end;

procedure TMyErrors.GetOraItemsFromErrorMessage(EMessage: string; var Error: string; var Shema: string; var Table: string; var Column: string);
//вычленяем из строки сообщения об ошибке Oracle имена ошибки, схемы, таблицы и столбца
{ORA-01400: cannot insert NULL into ("UCHET22"."TEST_3"."V1")}
begin

end;

begin
  Errors := TmyErrors.Create;

end.
