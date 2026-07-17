unit uErrors;

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
  если в вызывавших этот код процедурах верхнего уровня не встретится try-except, то вывалится сразу
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
  или процедуре верхнего уровня, а при отсутствии такого блока - в основной поток.

  дополнительные параметры (локация, доп. сообщение, тип ошибки, подавить показ ошибок)
  задаются через Errors.SetParam(). сбрасываются автоматически при перехвате возникшей ошибки.
  но нужно обеспечить сброс вызовом SetParam без параметров, когда область действия закончится.

  при работе под ide запись дампа и запись лога в базу можно отключить константами, которые здесь ниже

  убрал запись данных на диск вообще, вся информация, включая полный дамп и картинку, пишется в БД, так быстрее
}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, uData, Jpeg, uString, PngImage, madExcept,
  AdoDB, DB;

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

  //наименования файлов дампа
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
    //символ * в ней заменяется на E.Message; если пустая то тоже;
    //если поле начинается с myerrNoErr, то окно с ошибкой не выводится
    //для установки использовать SetErrorMessage перед/в try/finally
    //сбрасывается автоматически при генерации исключения
    //(если сбрасывать в Finally, то оно выполнится раньше чем обработчик исключения)
    //сообщение об ошибке для подстановки
    property ErrorMessage: string read FErrorMessage;
    //тип ошибки
    //если поле ErrorType равно myerrNoErr, то окно с ошибкой не выводится
    //для myerrDB в обработчике предусмотрен показ запроса
    property ErrorType: string read FErrorType;
    //массив лога - публичное свойство
    property LogArray: TVarDynArray2 read FLogArray;
    property KnownErrors: TVarDynArray2 read FKnownErrors;
    property IsExceptionHandlerDisabled: Boolean read FIsExceptionHandlerDisabled write FIsExceptionHandlerDisabled;
    //конструктор
    constructor Create;
    //установка параметров MadExcept, вызываем сразу в конструкторе, и при (пере)логине пользователя
    procedure SetMadExcept;
    //обработчик исключений MadExcept
    procedure ExceptionHandler(const exceptIntf: IMEException; var handled: Boolean);
    //обработчик акций MadExcept
    procedure ExceptActionHandler(action: TExceptAction; const exceptIntf: IMEException; var handled: Boolean);
    //устанавливает режим выдачи информации об ошибке для последующих ошибок
    //параметры приводятся к дефолтным при возникновении ошибки, или ручным вызовом Errors.SetParam без параметров
    //Location - можно установить для локализации места ошибки
    //ErrorMsg - модифицируем сообщение об ошибке. любой текст. "*" заменяется на оригинальную строку Exception.Message, если пустая то также выводится Exception.Message
    //ErrorType - дополнительный тип ошибки для кастомизации действий. пока DB и NoErr
    //ShowError - если установлен, отключает вывод окна ошибки, а также и сохранение ее в логах
    function SetParam(const ALocation: string = ''; const AErrorMsg: string = ''; const AErrorType: string = ''; const AShowError: Boolean = True): string;
    function SetErrorCapt(const ALocation: string = ''; const AErrorMsg: string = ''): string;
    //то же, но вызывает ошибку
    function RaiseErr(const ALocation: string = ''; const AErrorMsg: string = ''; const AErrorType: string = ''; const AShowError: Boolean = True): string;
    //проверим, что эта ошибка - отвал БД оракла
    //в этом случае, установим признак обработанной ошибки, чтобы не выходило окно ошибки, и выведем свое окно
    function IsOraDisconnect(const AEMessage: string; var handled: Boolean): Boolean;
    //вычленяем из строки сообщения об ошибке Oracle имена ошибки, схемы, таблицы и столбца
    {ORA-01400: cannot insert NULL into ("UCHET22"."TEST_3"."V1")}
    procedure GetOraItemsFromErrorMessage(const AEMessage: string; var AError: string; var AShema: string; var ATable: string; var AColumn: string);
    procedure PreSetKnownErrors;
    function GetKnownErrorMessage(const AErrorMessage: string): string;
    procedure RaiseError(const AErrorMsg: string = ''; const APrefix: string = ''; const AShowError: Boolean = True);
    procedure ShowErrorBox;
    procedure myError(const AEMessage: string; const AIsOraWarning: Boolean = False);
    //вызывает ошибку деления на 0
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
//инициализация
begin
  inherited;
  MadSettings := MESettings;
  SetMadExcept;
  PreSetKnownErrors;
end;

function TMyErrors.SetParam(const ALocation, AErrorMsg, AErrorType: string; const AShowError: Boolean): string;
//установка параметров для последующих ошибок
begin
  FLocation := ALocation;
  FErrorType := AErrorType;
  if not AShowError then
    FErrorMessage := myerrTypeNoErr + AErrorMsg
  else
    FErrorMessage := AErrorMsg;
  Result := FErrorMessage;
end;

function TMyErrors.SetErrorCapt(const ALocation, AErrorMsg: string): string;
//установка глобального заголовка и сообщения
begin
  FLocationGlobal := ALocation;
  FErrorMessageGlobal := AErrorMsg;
end;

function TMyErrors.RaiseErr(const ALocation, AErrorMsg, AErrorType: string; const AShowError: Boolean): string;
//установка параметров и генерация исключения
begin
  FLocation := ALocation;
  FErrorType := AErrorType;
  if not AShowError then
    FErrorMessage := myerrTypeNoErr + AErrorMsg
  else
    FErrorMessage := AErrorMsg;
  Result := FErrorMessage;
  raise Exception.Create(FErrorMessage);
end;

procedure TMyErrors.SetMadExcept;
//настройка madExcept
begin
  RegisterExceptionHandler(ExceptionHandler, stTrySyncCallOnSuccess, epMainPhase);
  RegisterExceptActionHandler(ExceptActionHandler, stTrySyncCallOnSuccess);
  madSettings.AppendBugReports := True;
  madSettings.ShowPleaseWaitBox := True;
  madSettings.MailAddr := DEVELOPER_MAIL;
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
  madSettings.BugReportFile := 'uchet.bug';
  if User <> nil then
    madSettings.BugReportFile := User.GetLogin + '.bug';
end;

procedure TMyErrors.ExceptionHandler(const exceptIntf: IMEException; var handled: Boolean);
//обработчик исключений madExcept
var
  b: Boolean;
  KnownErrMsg: string;
  IsOraError: Boolean;
begin
  if FIsExceptionHandlerDisabled then begin
    handled := True;
    Exit;
  end;

  //специфическая ошибка потери связи с Оракл
  if IsOraDisconnect(exceptIntf.ExceptMessage, handled) then
    Exit;

  //если включен таймер закрытия – ошибки игнорируем
  if FrmMain.TimerSrvClose.Enabled then begin
    handled := True;
    Exit;
  end;

  //если установлен признак myerrTypeNoErr, то не выводим окно
  if (Copy(ErrorMessage, 1, 1) = myerrTypeNoErr) or (ErrorType = myerrTypeNoErr) then begin
    handled := True;
    SetParam;
    Exit;
  end;

  //полное сообщение об ошибке
  FErrMessageFull := S.IIf(ErrorMessage = '', exceptIntf.ExceptMessage, StringReplace(ErrorMessage, '*', exceptIntf.ExceptMessage, []));
  FErrMessageFull := A.Implode([FLocationGlobal, FErrorMessageGlobal, FLocation, FErrMessageFull], #13#10, True);

  //заголовок madExcept
  madSettings.ExceptMsg := A.Implode(
    ['Внимание!. В программе возникла ошибка! Обратитесь к разработчику.' + #13#10, FErrMessageFull], #13#10, True);

  IsOraError := (Pos('ORA-', exceptIntf.ExceptMessage) > 0) or (ErrorType = myerrTypeDB);
  madSettings.PrintBtnVisible := IsOraError;

  if IsOraError then begin
    MESettings.AdditionalFields['SomeField'] := 'SomeText';
    exceptIntf.BugReportHeader['Запрос Oracle'] := StringReplace(Q.LastSql, #13#10, ' ', [rfReplaceAll]);
    exceptIntf.BugReportHeader['Параметры запроса Oracle'] := StringReplace(Q.LastParamsStr, #13#10, '|', [rfReplaceAll]);
    FErrDBErr := FErrMessageFull;
    FErrDBQuery := Q.LastSql;
    FErrDBParams := Q.LastParamsStr;
  end
  else begin
    exceptIntf.BugReportHeader['Запрос Oracle'] := '';
    exceptIntf.BugReportHeader['Параметры запроса Oracle'] := '';
  end;

  //добавим информацию об активной форме и контроле
  exceptIntf.BugReportHeader['Active form'] := S.IIf(Screen.ActiveForm = nil, 'нет', Screen.ActiveForm.Name + ' (' + Screen.ActiveForm.Caption + ')');
  exceptIntf.BugReportHeader['Active control'] := S.IIf(Screen.ActiveControl = nil, 'нет', Screen.ActiveControl.Name);

  try
    KnownErrMsg := GetKnownErrorMessage(FErrMessageFull);
    if KnownErrMsg <> '' then begin
      {$IFDEF SRV}
      Module.CloseAppTimer(AutoCloseIfErrorInterval);
      {$ENDIF}
      if IsOraError then begin
        if myMessageDlg(KnownErrMsg + #13#10 + 'Данные не изменены!', mtWarning, [mbYes, mbOk], 'Подробно;Ok') = mrYes then
          FrmXWOracleError.ShowDialog(FErrDbRow, FErrDBErr, FErrDBQuery, FErrDBParams);
      end
      else begin
        myMessageDlg(KnownErrMsg, mtWarning, [mbOK]);
      end;
      Module.CloseAppTimer(0);
      handled := True;
      SetParam;
      Exit;
    end;

    FErrDbRow := High(Q.LogArray);
    GetBugReportToArr(exceptIntf);
    LogToDB(exceptIntf);
    {$IFDEF SRV}
    Module.CloseAppTimer(AutoCloseIfErrorInterval);
    {$ENDIF}
  except
  end;

  SetParam;
end;

function TMyErrors.GetBugReportToArr(const exceptIntf: IMEException): TVarDynArray;
//формирование массива данных из отчёта madExcept
var
  i, j, r: Integer;
  st: string;
  ReportLines, Parts: TVarDynArray;
begin
  try
    ReportLines := A.ExplodeV(exceptIntf.BugReport, #13#10);
    r := High(FLogArray) + 1;
    SetLength(FLogArray, r + 1);
    SetLength(FLogArray[r], cmyerrHandled + 1);

    FLogArray[r][cmyerrId] := 0;
    FLogArray[r][cmyerrTime] := Now;
    FLogArray[r][cmyerrModule] := cMainModule;
    FLogArray[r][cmyerrModuleVer] := Module.Version;
    FLogArray[r][cmyerrModuleCompile] := Module.CompileDate;
    FLogArray[r][cmyerrMessage] := FErrMessageFull;
    FLogArray[r][cmyerrUserLogin] := '<before logged>';
    if User <> nil then
      FLogArray[r][cmyerrUserLogin] := User.GetLogin;
    FLogArray[r][cmyerrMashineUser] := ReportLines[2] + ';  ' + ReportLines[1];

    j := 0;
    for i := 0 to High(ReportLines) do begin
      if ReportLines[i] = '' then Break;
      S.ConcatStP(FLogArray[r][cmyerrGeneral], ReportLines[i], #13#10);
      if Pos('Запрос Oracle', ReportLines[i]) = 1 then begin
        Parts := A.Explode(ReportLines[i], ':');
        Delete(Parts, 0, 1);
        FLogArray[r][cmyerrSql] := Trim(A.Implode(Parts, ':'));
      end;
      if Pos('Параметры запроса Oracle', ReportLines[i]) = 1 then begin
        Parts := A.Explode(ReportLines[i], ':');
        Delete(Parts, 0, 1);
        FLogArray[r][cmyerrSqlParams] := Trim(A.Implode(Parts, ':'));
      end;
    end;

    j := i + 2;
    for i := j to High(ReportLines) do begin
      if ReportLines[i] = '' then Continue;
      if ReportLines[i] = 'modules:' then Break;
      S.ConcatStP(FLogArray[r][cmyerrStack], ReportLines[i], #13#10);
    end;

    for i := 0 to High(FLogArray[r]) do
      if Length(VarToStr(FLogArray[r][i])) > 4000 then
        FLogArray[r][i] := Copy(FLogArray[r][i], 1, 4000);
  except
  end;
end;

procedure TMyErrors.LogToDb(const exceptIntf: IMEException);
//запись последней строки лога в БД
var
  i, r: Integer;
begin
  if not cmyDebugSendErrToDb then Exit;
  if Module = nil then Exit;
  if cmyDebugNOSavefromIDE and Module.RunFromIDE then Exit;

  try
    r := High(FLogArray);
    if (not Q.Connected) or (r < 0) then Exit;

    if not Q.AdoConnection.InTransaction then begin
      Q.ADOQueryService.Close;
      Q.ADOQueryService.SQL.Text := 'insert into adm_error_log (' +
        'dt, userlogin, id_module, ver, compile_dt, mashineinfo, message, sql, sqlparams, general, stack, handled, pictc, fullreportc, ide) ' +
        'values (:dt, :userlogin, :id_module, :ver, :compile_dt, :mashineinfo, :message, :sql, :sqlparams, :general, :stack, :handled, :pictc, :fullreportc, :ide)';
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
      Q.ADOQueryService.Parameters.ParamByName('pictc').Value := Null;
      Q.ADOQueryService.Parameters.ParamByName('fullreportc').Value := exceptIntf.BugReport;
      Q.ADOQueryService.Parameters.ParamByName('ide').Value := S.IIf(Module.RunFromIDE, 1, 0);
      Q.ADOQueryService.ExecSQL;
      Q.ADOQueryService.Close;
    end
    else begin
      Q.ADOQueryService.Close;
      Q.ADOQueryService.SQL.Text :=
        'select F_To_Adm_Error_Log(' +
        ':dt, :userlogin, :id_module, :ver, :compile_dt, :mashineinfo, :message, :sql, :sqlparams, :general, :stack, :handled, null, null, :ide) ' +
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
    end;
  except
  end;
end;

function TMyErrors.IsOraDisconnect(const AEMessage: string; var handled: Boolean): Boolean;
//проверка, является ли ошибка потерей связи с Oracle
var
  b: Boolean;
begin
  Result := False;
  b := not Q.Connected or
       (Pos('ORA-03113', AEMessage) > 0) or
       (Pos('ORA-03114', AEMessage) > 0) or
       (Pos('ORA-12170', AEMessage) > 0);
  if b then begin
    IsExceptionHandlerDisabled := True;
    {$IFDEF SRV}
    Halt;
    Exit;
    {$ENDIF}
    if FrmXDmsgNoConnection.Visible then
      Halt;
    FrmXDmsgNoConnection.ShowModal;
    handled := True;
    Result := True;
  end;
end;

procedure TMyErrors.LogToDisk(const exceptIntf: IMEException);
//запись отчёта на диск (в текущей реализации не используется)
var
  r: Integer;
  Path: string;
begin
  if not cmyDebugSendErrToDisk or (Module = nil) then Exit;
  if cmyDebugSendErrToDisk and Module.RunFromIDE then Exit;

  try
    r := High(FLogArray);
    if (User = nil) or (Module = nil) then
      Path := 'D:\'
    else
      Path := Module.GetPath_ErrorLog(User.GetLogin, FLogArray[r][cmyerrTime]);
    ForceDirectories(Path);
    Sys.SaveTextToFile(Path + '\' + cmyerrBugReportFileName,
      VarToStr(FLogArray[r][cmyerrTime]) + #13#10#13#10 +
      VarToStr(FLogArray[r][cmyerrUserLogin]) + #13#10#13#10 +
      VarToStr(FLogArray[r][cmyerrMashineUser]) + #13#10#13#10 +
      VarToStr(FLogArray[r][cmyerrMessage]) + #13#10#13#10 +
      VarToStr(FLogArray[r][cmyerrSql]) + #13#10#13#10 +
      VarToStr(FLogArray[r][cmyerrSqlParams]) + #13#10#13#10 +
      VarToStr(FLogArray[r][cmyerrStack]) + #13#10#13#10 +
      VarToStr(FLogArray[r][cmyerrHandled]), False);
  except
  end;
end;

procedure TMyErrors.ExceptActionHandler(action: TExceptAction; const exceptIntf: IMEException; var handled: Boolean);
//обработчик действий madExcept (кнопки)
begin
  if action = eaPrintBugReport then begin
    handled := True;
    FrmXWOracleError.ShowDialog(FErrDbRow, FErrDBErr, FErrDBQuery, FErrDBParams);
  end;
  // другие действия не обрабатываем
end;

procedure TMyErrors.myError(const AEMessage: string; const AIsOraWarning: Boolean = False);
//вывод пользовательской ошибки с возможностью показа подробностей
var
  st: string;
begin
  if (Pos('ORA-03114', AEMessage) > 0) or (Pos('ORA-12170', AEMessage) > 0) then begin
    {$IFDEF SRV}
    FrmMain.Close;
    Exit;
    {$ENDIF}
    FrmXDmsgNoConnection.ShowModal;
  end;

  st := ''; // здесь должен быть вызов GetOraMessages, но он не реализован
  if st <> '' then begin
    {$IFDEF SRV}
    Module.CloseAppTimer(AutoCloseIfErrorInterval);
    {$ENDIF}
    FrmMain.StatusBar.Panels[0].Text := AEMessage;
    if myMessageDlg(st + #13#10 + 'Данные не изменены!', mtWarning, [mbYes, mbOk], 'Подробно;Ok') = mrYes then
      FrmXWOracleError.ShowDialog(-1);
    Module.CloseAppTimer(0);
    FrmMain.StatusBar.Panels[0].Text := '';
    Exit;
  end;

  {$IFDEF SRV}
  Module.CloseAppTimer(AutoCloseIfErrorInterval);
  {$ENDIF}
  Module.CloseAppTimer(0);
  if Pos(#1, AEMessage) <> 1 then
    raise Exception.Create(#1 + AEMessage);
end;

procedure TMyErrors.RaiseError(const AErrorMsg, APrefix: string; const AShowError: Boolean);
//устаревший метод, оставлен для совместимости
begin
  // реализация отсутствует
end;

procedure TMyErrors.ShowErrorBox;
//показать окно ошибки madExcept вручную
begin
  NewException;
end;

procedure TMyErrors.PreSetKnownErrors;
//предустановка известных ошибок для замены сообщений
begin
  FKnownErrors := [
    ['There are no fresh record on server', '*', 'Эта запись была удалена!'],
    [oraeChildFound, '*', 'Эта запись используется в других таблицах'],
    [oraeNumberTooLarge, '*', 'Число слишком длинное.'],
    [oraePkNotFound, '*', 'Данные не найдены в справочнике.'],
    [oraeStringTooLarge, '*', 'Строка слишком длинная.'],
    [oraeCannotInsertNull, '*', 'Задана пустая строка, что недопустимо.'],
    [oraeCannotUpdateNull, '*', 'Задана пустая строка, что недопустимо.'],
    [oraeNonUnique, '*', 'Данные должны быть уникальными.'],
    [oraeDeadLock, '*', 'Взаимная блокировка в базе данных. Попробуйте выполнить операцию позднее.'],
    [oraeChildFound, 'fk_or_otk_rejected_res', 'Эта запись используется в таблице приемки ОТК'],
    ['', 'IDX_REF_OTK_REJECT_REASONS_N', 'Причина неприемки ОТК должна быть уникальна (без учета регистра букв)']
  ];
end;

function TMyErrors.GetKnownErrorMessage(const AErrorMessage: string): string;
//поиск известного сообщения об ошибке по шаблону
var
  i, j: Integer;
  Pos1, Pos2: Integer;
  FoundIndices, SplitParts: TVarDynArray;
begin
  Result := '';
  FoundIndices := [-1];
  for i := 0 to High(FKnownErrors) do begin
    if FKnownErrors[i][0] = '' then
      Pos1 := 1
    else
      Pos1 := S.PosI(FKnownErrors[i][0], AErrorMessage);

    if FKnownErrors[i][1] = '*' then
      Pos2 := 100000
    else begin
      SplitParts := A.ExplodeV(FKnownErrors[i][0], ';');
      for j := 0 to High(SplitParts) do begin
        Pos1 := S.PosI(FKnownErrors[i][1], AErrorMessage);
        if Pos1 > 0 then Break;
      end;
    end;

    if (Pos1 > 0) and (Pos2 > Pos1) then
      if FKnownErrors[i][1] = '*' then
        FoundIndices[0] := i
      else
        FoundIndices := FoundIndices + [i];
  end;

  if (High(FoundIndices) = 0) and (FoundIndices[0] = -1) then Exit;
  if High(FoundIndices) = 0 then
    Result := FKnownErrors[S.VarToInt(FoundIndices[0])][2]
  else begin
    for i := 1 to High(FoundIndices) do
      S.ConcatStP(Result, FKnownErrors[S.VarToInt(FoundIndices[i])][2], #13#10);
  end;
end;

procedure TMyErrors.TestError;
//тестовая ошибка деления на ноль
var
  i: Integer;
begin
  i := i div i;
end;

procedure TMyErrors.Test;
//тестовый метод для проверки обработки исключений
var
  va: TVarDynArray;
begin
  try
    MyInfoMessage(IntToStr(Q.QExecSql('update test1 set dt = sysdate where id = :id', ['aaa'], True)));
    va[10] := 0;
  finally
    MyInfoMessage('finally');
  end;
  MyInfoMessage('end');

  try
    MyInfoMessage(IntToStr(Q.QExecSql('update test1 set dt = sysdate where id = :id', VarArrayOf([423, '--']), True)));
    va[100] := 10;
  finally
    MyInfoMessage('except');
  end;
  MyInfoMessage('end');
end;

procedure TMyErrors.GetOraItemsFromErrorMessage(const AEMessage: string; var AError, AShema, ATable, AColumn: string);
//вычленение частей из сообщения Oracle (заглушка)
begin
  // реализация отсутствует
end;

begin
  Errors := TmyErrors.Create;
end.
