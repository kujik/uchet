{

Модуль сервера сканирования штрихкодов продукции (тестовый режим, первая
версия с типами штрихкодов и входом по бейджику). Клиент - мобильная веб-
страница (scan.html), открываемая в Chrome на телефоне в локальной сети
склада/цеха; сама страница лежит рядом с exe и отдаётся этим же сервером.

Поднимается в режиме "Сервер" (см. uServerTasks.pas, задача командной строки
/scanapi) и работает в фоне, пока запущен процесс - см. TScanApi.Start/Stop.
Реализовано на Indy (TIdHTTPServer), сервер сам поднимает фоновые потоки для
приема соединений, поэтому никакого отдельного цикла ожидания не требуется.

Штрихкоды - это ПРЕФИКС ТИПА (2 буквы, жёстко заданы для типа сущности) + её
id; отдельного поля-штрихкода в базе не заводим (кроме случаев, где это
физически невозможно) - код разбирается прямо на сервере (см. ParseBarcode):
  SI<id> - стандартное изделие (or_std_items.id)
  OI<id> - изделие заказа (order_items.id)
  EM<id> - работник (w_employees.id), это же бейджик для входа в систему

Вход в систему ("смена") обязателен для ЛЮБОГО действия в сканере, включая
простой просмотр информации по штрихкоду. Каждый телефон (браузер) сам
генерирует и хранит у себя случайный ClientId (см. scan.html), который
передаёт на сервер при каждом запросе - по нему сервер определяет, какой
работник сейчас "на смене" на этом конкретном телефоне (сессии хранятся в
памяти сервера, FSessions, под критической секцией - Indy обслуживает разные
соединения в разных потоках).

Сканирование EM-бейджика - это переключатель:
  - если на этом телефоне ещё никто не вошёл, или вошёл ДРУГОЙ работник -
    происходит вход (авто-смена работника без явного выхода - так решено
    пользователем, это нормально для одного телефона на несколько смен);
  - если сканируется бейджик ТОГО ЖЕ работника, который уже вошёл - это
    выход из системы, дальше на этом телефоне ничего сделать нельзя, пока
    кто-то не отсканирует свой бейджик заново.

Права на действия (приёмка на СГП/отгрузка) - по полям w_employees.
scan_can_accept/scan_can_ship (см. d_workers_new.sql), проверяются сервером
перед каждым действием - т.е. один и тот же вход не гарантирует доступ ко
всем действиям сразу.

Приёмка/отгрузка выполняются вызовом уже существующей и проверенной
процедуры p_OrderStage_SetItem (d_order_stages.sql), в режиме "добавления"
(Adding = 1) - повторное сканирование добавляет количество к уже
принятому/отгруженному за сегодняшнюю дату, а не заменяет его; UpdateOrders
передаётся 1, чтобы обновлялись orders.dt_to_sgp/dt_from_sgp - см. прецедент
этого же вызова в uFrmOWInvoiceToSgp.pas.

Данные для карточек читаются из вью v_scan_api_order_item/v_scan_api_std_item/
v_scan_api_employee (d_scan_api.sql).

HTTP API (везде JSON, в т.ч. и для ошибок - поле error; ClientId обязателен
всегда, кроме отдачи самой страницы):
  GET  /                                       - отдаёт scan.html
  GET  /scan.html                              - отдаёт scan.html
  POST /api/scan?client_id=...&barcode=...     - разбор любого отсканированного
                                                  штрихкода (бейджик - вход/выход,
                                                  изделие - карточка с информацией)
  POST /api/accept?client_id=...&barcode=...&qty=N  - приёмка на СГП (id_stage = 2),
                                                       barcode - позиции заказа (OI)
  POST /api/ship?client_id=...&barcode=...&qty=N    - отгрузка с СГП (id_stage = 3)

}


unit uScanApi;

interface

uses
  Classes, SysUtils, Variants, SyncObjs, Messages, Forms, Controls, StdCtrls,
  IdContext, IdCustomHTTPServer, IdHTTPServer, IdURI;

type
  //префикс типа штрихкода - см. заголовок модуля
  TScanEntityType = (etUnknown, etStdItem, etOrderItem, etEmployee);

  TScanApi = class
  private
    FHttpServer: TIdHTTPServer;
    FActive: Boolean;
    //сессии "смен" по телефонам: имена - ClientId, значения - id вошедшего работника
    FSessions: TStringList;
    FSessionsLock: TCriticalSection;
    //отладочное окошко на экране сервера - видно, какие штрихкоды реально приходят с
    //телефона (см. LogDebug); создаётся лениво при первом обращении, чтобы не мешать,
    //если сервер вообще никогда не сканировали
    FDebugForm: TForm;
    FDebugMemo: TMemo;
    procedure EnsureDebugForm;
    //пишет строку в отладочное окошко; можно звать из любого потока (Indy обслуживает
    //запросы не в главном потоке VCL) - сама переключается на главный поток через TThread.Queue
    procedure LogDebug(const AMsg: string);
    function  GetQueryParam(ARequestInfo: TIdHTTPRequestInfo; const AName: string): string;
    function  ParseBarcode(const ABarcode: string; out AEntityType: TScanEntityType; out AId: Integer): Boolean;
    function  GetSessionEmployee(const AClientId: string): Integer;
    procedure SetSessionEmployee(const AClientId: string; AIdEmployee: Integer);
    function  JEsc(const AValue: string): string;
    function  JStr(const AName: string; AValue: Variant): string;
    function  JNum(const AName: string; AValue: Variant): string;
    procedure SendJson(AResponseInfo: TIdHTTPResponseInfo; const AJson: string);
    procedure SendError(AResponseInfo: TIdHTTPResponseInfo; const AMessage: string);
    //строка с данными вошедшего работника (для ответа при входе/выходе и как часть карточки изделия) -
    //включает права scan_can_accept/scan_can_ship, чтобы клиент сразу знал, какие кнопки показывать
    function  EmployeeJsonFields(AIdEmployee: Integer): string;
    procedure HandleScan(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure HandleStageAction(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo; AIdStage: Integer);
    procedure HttpCommand(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  public
    constructor Create;
    destructor Destroy; override;
    //запускает сервер на указанном порту (по умолчанию 8098), ничего не делает, если уже запущен
    procedure Start(APort: Integer = 8098);
    //останавливает сервер, ничего не делает, если уже остановлен
    procedure Stop;
    property Active: Boolean read FActive;
  end;

var
  ScanApi: TScanApi;

implementation

uses
  uDBOra, uString, uNamedArr, uData;

{ TScanApi }

constructor TScanApi.Create;
begin
  inherited Create;
  FHttpServer := TIdHTTPServer.Create(nil);
  FHttpServer.OnCommandGet := HttpCommand;
  FHttpServer.OnCommandOther := HttpCommand;
  FSessions := TStringList.Create;
  FSessions.NameValueSeparator := '=';
  FSessionsLock := TCriticalSection.Create;
  FActive := False;
end;

destructor TScanApi.Destroy;
begin
  Stop;
  FHttpServer.Free;
  FSessions.Free;
  FSessionsLock.Free;
  try
    FreeAndNil(FDebugForm);
  except
  end;
  inherited Destroy;
end;

procedure TScanApi.Start(APort: Integer = 8098);
//запускает HTTP-сервер; если порт уже занят (например, предыдущий процесс не
//успел до конца освободить его после аварийного завершения) - не даём подняться
//необработанному исключению (раньше из-за этого мог зависнуть процесс на
//диалоге ошибки, которую некому закрыть - отсюда и пропадавшее диагностическое
//окно), а спокойно логируем и выходим с FActive = False. Вызывающий код
//(TTasksS.Run в uServerTasks.pas) в этом случае штатно завершает процесс, а
//следующая попытка запуска той же задачи по расписанию планировщика Windows
//(раз в 5 минут) начнёт всё заново
begin
  if FActive then
    Exit;
  FHttpServer.DefaultPort := APort;
  try
    FHttpServer.Active := True;
  except
    on E: Exception do begin
      Module.ToLogFile('Не удалось запустить сервер сканера штрихкодов на порту ' + IntToStr(APort) + ': ' + E.Message);
      Exit;
    end;
  end;
  FActive := True;
  Module.ToLogFile('Сервер сканера штрихкодов запущен на порту ' + IntToStr(APort));
  LogDebug('Сервер запущен, порт ' + IntToStr(APort));
end;

procedure TScanApi.EnsureDebugForm;
//вызывается только из главного потока VCL (см. LogDebug) - создаёт окно "вживую",
//без dfm, чтобы не заводить отдельный юнит/форму только ради одного мемо
begin
  if Assigned(FDebugForm) then
    Exit;
  FDebugForm := TForm.CreateNew(Application);
  FDebugForm.Caption := 'Сканер штрихкодов - отладка';
  FDebugForm.Position := poScreenCenter;
  FDebugForm.Width := 520;
  FDebugForm.Height := 420;
  FDebugMemo := TMemo.Create(FDebugForm);
  FDebugMemo.Parent := FDebugForm;
  FDebugMemo.Align := alClient;
  FDebugMemo.ScrollBars := ssVertical;
  FDebugMemo.ReadOnly := True;
  FDebugMemo.WordWrap := False;
  FDebugMemo.Font.Name := 'Consolas';
  FDebugMemo.Font.Size := 9;
end;

procedure TScanApi.LogDebug(const AMsg: string);
var
  LMsg: string;
begin
  LMsg := FormatDateTime('hh:nn:ss', Now) + '  ' + AMsg;
  //Indy обслуживает запросы не в главном потоке - трогать VCL можно только через очередь
  TThread.Queue(nil, procedure
  begin
    EnsureDebugForm;
    if not FDebugForm.Visible then
      FDebugForm.Show;
    FDebugMemo.Lines.Add(LMsg);
    if FDebugMemo.Lines.Count > 1000 then
      FDebugMemo.Lines.Delete(0);
    FDebugMemo.SelStart := Length(FDebugMemo.Text);
    FDebugMemo.SelLength := 0;
    FDebugMemo.Perform(EM_SCROLLCARET, 0, 0);
  end);
end;

procedure TScanApi.Stop;
begin
  if not FActive then
    Exit;
  FHttpServer.Active := False;
  FActive := False;
end;

function TScanApi.GetQueryParam(ARequestInfo: TIdHTTPRequestInfo; const AName: string): string;
//разбираем строку запроса вручную (а не полагаемся на ARequestInfo.Params) -
//чтобы не зависеть от точной семантики её заполнения в используемой версии Indy
var
  Query, Pair: string;
  Parts: TStringList;
  i, P: Integer;
begin
  Result := '';
  Query := ARequestInfo.QueryParams;
  if Query = '' then
    Exit;
  Parts := TStringList.Create;
  try
    Parts.StrictDelimiter := True;
    Parts.Delimiter := '&';
    Parts.DelimitedText := Query;
    for i := 0 to Parts.Count - 1 do begin
      Pair := Parts[i];
      P := Pos('=', Pair);
      if P = 0 then
        Continue;
      if SameText(TIdURI.URLDecode(Copy(Pair, 1, P - 1)), AName) then begin
        Result := TIdURI.URLDecode(Copy(Pair, P + 1, MaxInt));
        Break;
      end;
    end;
  finally
    Parts.Free;
  end;
end;

function TScanApi.ParseBarcode(const ABarcode: string; out AEntityType: TScanEntityType; out AId: Integer): Boolean;
var
  Prefix, IdSt: string;
begin
  Result := False;
  AEntityType := etUnknown;
  AId := 0;
  if Length(ABarcode) < 3 then
    Exit;
  Prefix := UpperCase(Copy(ABarcode, 1, 2));
  IdSt := Copy(ABarcode, 3, MaxInt);
  AId := StrToIntDef(IdSt, 0);
  if AId <= 0 then
    Exit;
  if Prefix = 'SI' then
    AEntityType := etStdItem
  else if Prefix = 'OI' then
    AEntityType := etOrderItem
  else if Prefix = 'EM' then
    AEntityType := etEmployee
  else
    Exit;
  Result := True;
end;

function TScanApi.GetSessionEmployee(const AClientId: string): Integer;
var
  i: Integer;
begin
  Result := 0;
  FSessionsLock.Enter;
  try
    i := FSessions.IndexOfName(AClientId);
    if i >= 0 then
      Result := StrToIntDef(FSessions.ValueFromIndex[i], 0);
  finally
    FSessionsLock.Leave;
  end;
end;

procedure TScanApi.SetSessionEmployee(const AClientId: string; AIdEmployee: Integer);
begin
  FSessionsLock.Enter;
  try
    if AIdEmployee = 0 then
      FSessions.Values[AClientId] := ''
    else
      FSessions.Values[AClientId] := IntToStr(AIdEmployee);
  finally
    FSessionsLock.Leave;
  end;
end;

function TScanApi.JEsc(const AValue: string): string;
//минимальное ручное json-экранирование строки (без внешних библиотек)
var
  i: Integer;
  C: Char;
begin
  Result := '';
  for i := 1 to Length(AValue) do begin
    C := AValue[i];
    case C of
      '"': Result := Result + '\"';
      '\': Result := Result + '\\';
      #13: Result := Result + '\r';
      #10: Result := Result + '\n';
      #9:  Result := Result + '\t';
    else
      if C < #32 then
        Result := Result + '\u' + IntToHex(Ord(C), 4)
      else
        Result := Result + C;
    end;
  end;
end;

function TScanApi.JStr(const AName: string; AValue: Variant): string;
begin
  Result := '"' + AName + '":"' + JEsc(S.NSt(AValue)) + '"';
end;

function TScanApi.JNum(const AName: string; AValue: Variant): string;
begin
  Result := '"' + AName + '":' + StringReplace(FloatToStr(S.NNum(AValue)), ',', '.', []);
end;

procedure TScanApi.SendJson(AResponseInfo: TIdHTTPResponseInfo; const AJson: string);
begin
  AResponseInfo.ResponseNo := 200;
  AResponseInfo.ContentType := 'application/json';
  AResponseInfo.CharSet := 'utf-8';
  AResponseInfo.ContentText := AJson;
end;

procedure TScanApi.SendError(AResponseInfo: TIdHTTPResponseInfo; const AMessage: string);
begin
  SendJson(AResponseInfo, '{' + JStr('error', AMessage) + '}');
end;

function TScanApi.EmployeeJsonFields(AIdEmployee: Integer): string;
//поля вошедшего работника (без внешних фигурных скобок - вставляются как часть другого json-объекта)
var
  na: TNamedArr;
begin
  Result := JStr('employee_name', '') + ',' + JNum('can_accept', 0) + ',' + JNum('can_ship', 0);
  if AIdEmployee <= 0 then
    Exit;
  if not Q.QLoad('select * from v_scan_api_employee where id = :id$i', [AIdEmployee], na, True) then
    Exit;
  Result :=
    JStr('employee_name', na.GetValue(0, 'name')) + ',' +
    JNum('can_accept', na.GetValue(0, 'scan_can_accept')) + ',' +
    JNum('can_ship', na.GetValue(0, 'scan_can_ship'));
end;

procedure TScanApi.HandleScan(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  ClientId, Barcode: string;
  EntityType: TScanEntityType;
  Id, IdCurrentEmployee: Integer;
  na: TNamedArr;
  Json: string;
begin
  ClientId := Trim(GetQueryParam(ARequestInfo, 'client_id'));
  Barcode := Trim(GetQueryParam(ARequestInfo, 'barcode'));
  LogDebug('/api/scan  barcode=' + Barcode + '  client=' + ClientId);
  if ClientId = '' then begin
    SendError(AResponseInfo, 'Не передан ClientId');
    Exit;
  end;
  if not ParseBarcode(Barcode, EntityType, Id) then begin
    SendError(AResponseInfo, 'Не удалось распознать штрихкод');
    Exit;
  end;
  //бейджик работника - вход/выход из системы на этом телефоне
  if EntityType = etEmployee then begin
    if not Q.QLoad('select * from v_scan_api_employee where id = :id$i', [Id], na, True) then begin
      SendError(AResponseInfo, 'Работник с таким бейджиком не найден');
      Exit;
    end;
    IdCurrentEmployee := GetSessionEmployee(ClientId);
    if IdCurrentEmployee = Id then begin
      //повторное сканирование своего же бейджика - выход
      SetSessionEmployee(ClientId, 0);
      Json := '{' + JStr('kind', 'logout') + ',' + JStr('employee_name', na.GetValue(0, 'name')) + '}';
    end
    else begin
      //вход (в т.ч. авто-смена, если до этого был вошёл другой работник)
      SetSessionEmployee(ClientId, Id);
      Json := '{' + JStr('kind', 'login') + ',' + EmployeeJsonFields(Id) + '}';
    end;
    SendJson(AResponseInfo, Json);
    Exit;
  end;
  //любой другой тип штрихкода - сначала обязателен вход по бейджику
  IdCurrentEmployee := GetSessionEmployee(ClientId);
  if IdCurrentEmployee = 0 then begin
    SendError(AResponseInfo, 'Сначала отсканируйте свой бейджик');
    Exit;
  end;
  case EntityType of
    etStdItem: begin
      if not Q.QLoad('select * from v_scan_api_std_item where id = :id$i', [Id], na, True) then begin
        SendError(AResponseInfo, 'Стандартное изделие с таким штрихкодом не найдено');
        Exit;
      end;
      Json :=
        '{' +
        JStr('kind', 'std_item') + ',' +
        JStr('name', na.GetValue(0, 'fullname')) + ',' +
        JStr('type_name', na.GetValue(0, 'type_name')) + ',' +
        JStr('or_format_name', na.GetValue(0, 'or_format_name')) + ',' +
        JNum('price_with_nds', na.GetValue(0, 'price_with_nds')) + ',' +
        JNum('active', na.GetValue(0, 'active')) +
        '}';
      SendJson(AResponseInfo, Json);
    end;
    etOrderItem: begin
      if not Q.QLoad('select * from v_scan_api_order_item where id = :id$i', [Id], na, True) then begin
        SendError(AResponseInfo, 'Изделие заказа с таким штрихкодом не найдено');
        Exit;
      end;
      Json :=
        '{' +
        JStr('kind', 'order_item') + ',' +
        JStr('ornum', na.GetValue(0, 'ornum')) + ',' +
        JStr('customer', na.GetValue(0, 'customer')) + ',' +
        JStr('project', na.GetValue(0, 'project')) + ',' +
        JStr('fullitemname', na.GetValue(0, 'fullitemname')) + ',' +
        JNum('qnt', na.GetValue(0, 'qnt')) + ',' +
        JNum('qnt_to_sgp', na.GetValue(0, 'qnt_to_sgp')) + ',' +
        JNum('qnt_shipped', na.GetValue(0, 'qnt_shipped')) + ',' +
        EmployeeJsonFields(IdCurrentEmployee) +
        '}';
      SendJson(AResponseInfo, Json);
    end;
  end;
end;

procedure TScanApi.HandleStageAction(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo; AIdStage: Integer);
//общий обработчик для /api/accept (AIdStage = 2, приёмка на СГП) и /api/ship
//(AIdStage = 3, отгрузка с СГП) - в обоих случаях используем уже существующую
//процедуру p_OrderStage_SetItem в режиме добавления к количеству, принятому/
//отгруженному за сегодня (см. заголовок модуля); требует входа по бейджику и
//соответствующего права (scan_can_accept/scan_can_ship) у вошедшего работника
var
  ClientId, Barcode: string;
  Qty: Double;
  EntityType: TScanEntityType;
  IdOrderItem, IdCurrentEmployee: Integer;
  na: TNamedArr;
  ResArr: TVarDynArray;
begin
  ClientId := Trim(GetQueryParam(ARequestInfo, 'client_id'));
  Barcode := Trim(GetQueryParam(ARequestInfo, 'barcode'));
  if AIdStage = 2 then
    LogDebug('/api/accept  barcode=' + Barcode + '  client=' + ClientId)
  else
    LogDebug('/api/ship  barcode=' + Barcode + '  client=' + ClientId);
  if ClientId = '' then begin
    SendError(AResponseInfo, 'Не передан ClientId');
    Exit;
  end;
  IdCurrentEmployee := GetSessionEmployee(ClientId);
  if IdCurrentEmployee = 0 then begin
    SendError(AResponseInfo, 'Сначала отсканируйте свой бейджик');
    Exit;
  end;
  if not Q.QLoad('select * from v_scan_api_employee where id = :id$i', [IdCurrentEmployee], na, True) then begin
    SendError(AResponseInfo, 'Работник, вошедший на этом телефоне, не найден');
    Exit;
  end;
  if (AIdStage = 2) and (S.NNum(na.GetValue(0, 'scan_can_accept')) = 0) then begin
    SendError(AResponseInfo, 'У работника ' + S.NSt(na.GetValue(0, 'name')) + ' нет прав на приёмку на СГП');
    Exit;
  end;
  if (AIdStage = 3) and (S.NNum(na.GetValue(0, 'scan_can_ship')) = 0) then begin
    SendError(AResponseInfo, 'У работника ' + S.NSt(na.GetValue(0, 'name')) + ' нет прав на отгрузку');
    Exit;
  end;
  if not ParseBarcode(Barcode, EntityType, IdOrderItem) or (EntityType <> etOrderItem) then begin
    SendError(AResponseInfo, 'Ожидался штрихкод изделия заказа');
    Exit;
  end;
  Qty := S.NNum(GetQueryParam(ARequestInfo, 'qty'));
  if Qty <= 0 then
    Qty := 1;
  Q.QBeginTrans(True);
  ResArr := Q.QCallStoredProc(
    'p_OrderStage_SetItem', 'IdOrderItem$i;IdStage$i;NewDt$d;NewQnt$f;UpdateOrders$i;ResQnt$fo;Adding$i',
    VarArrayOf([IdOrderItem, AIdStage, Date, Qty, 1, -1, 1])
  );
  if not Q.QCommitOrRollback then begin
    SendError(AResponseInfo, 'Ошибка при сохранении в БД');
    Exit;
  end;
  Module.ToLogFile('Сканер: работник=' + IntToStr(IdCurrentEmployee) + ', barcode=' + Barcode + ', stage=' + IntToStr(AIdStage) + ', qty=' + FloatToStr(Qty));
  SendJson(AResponseInfo, '{' + JNum('res_qnt', ResArr[5]) + '}');
end;

procedure TScanApi.HttpCommand(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
//вызывается Indy в отдельном потоке на каждое соединение (см. заголовок
//модуля). HandleScan/HandleStageAction/EmployeeJsonFields обращаются к
//общему Oracle-соединению Q (TADOConnection, uDB.pas) - это COM-объект,
//созданный и живущий на главном (VCL) потоке; вызывать его методы напрямую
//из чужого потока небезопасно (COM ждёт обслуживания от потока-владельца) -
//в частности, это было причиной зависания процесса при закрытии сервера
//(TScanApi.Stop мог ждать завершения этого же потока Indy, а тот - ждать
//обслуживания от главного потока, который к этому моменту уже не качает
//сообщения). Поэтому вся обработка запроса теперь целиком выполняется на
//главном потоке через TThread.Synchronize - поток Indy при этом просто
//ждёт результата, снаружи (для Indy) ничего не меняется: AResponseInfo
//по-прежнему полностью заполнен к моменту возврата из HttpCommand
var
  Doc, FileName: string;
begin
  TThread.Synchronize(nil, procedure
  begin
    try
      Doc := ARequestInfo.Document;
      if (Doc = '') or (Doc = '/') or (Doc = '/scan.html') then begin
        FileName := ExtractFilePath(ParamStr(0)) + 'scan.html';
        if FileExists(FileName) then begin
          AResponseInfo.ContentType := 'text/html';
          AResponseInfo.CharSet := 'utf-8';
          AResponseInfo.ContentStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
        end
        else begin
          AResponseInfo.ResponseNo := 404;
          AResponseInfo.CharSet := 'utf-8';
          AResponseInfo.ContentText := 'scan.html не найден рядом с программой';
        end;
      end
      else if Doc = '/api/scan' then
        HandleScan(ARequestInfo, AResponseInfo)
      else if Doc = '/api/accept' then
        HandleStageAction(ARequestInfo, AResponseInfo, 2)
      else if Doc = '/api/ship' then
        HandleStageAction(ARequestInfo, AResponseInfo, 3)
      else begin
        AResponseInfo.ResponseNo := 404;
        AResponseInfo.CharSet := 'utf-8';
        AResponseInfo.ContentText := 'Не найдено';
      end;
    except
      on E: Exception do begin
        Module.ToLogFile('Ошибка сервера сканера штрихкодов: ' + E.Message);
        try
          SendError(AResponseInfo, 'Внутренняя ошибка сервера');
        except
        end;
      end;
    end;
  end);
end;

initialization
  ScanApi := TScanApi.Create;

finalization
  FreeAndNil(ScanApi);

end.
