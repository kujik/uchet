unit uModule;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Jpeg, MemTableDataEh, Db,
  ADODB, DataDriverEh, GridsEh, DBGridEh, PropStorageEh, DBAxisGridsEh,
  PngImage, uString, IniFiles, DBCtrlsEh, ShellApi, Types,
  frxClass, frxDesgn, Vcl.Themes, Vcl.Styles, IdBaseComponent,
  IdTCPConnection, IdTCPClient, Xml.xmldom,
  IdSMTP, iDMessage,
  IdIOHandler, IdIOHandlerStack, IdSSL, IdSSLOpenSSL,
  Data.DBXOracle, Menus, DateUtils
  ;

type
  TModule = class
  //события иконки - Help, присутствующей на разных формах
  //события для панелей кнопок, вызывается при клике кнопки с выпадающим списком
  procedure MenuSpeedButton1Click(Sender: TObject);
  //получает из полного текста инфы текст хинта для true или окна инфы для false
  //если текст разделен ___ то что до этого разделителя выводится в подсказке, а что после - в окне
  //если текст разделен ... то в хинте выводится с начала текста, включая ..., в окне выводится полностью, многоточие вырезается
  //если без разделителей то выводится все и в хинте и в окне
  function InfoGetHintText(Sender: TObject; const AMode: Boolean = True): string;
  //клик по картинке-подсказке
  procedure InfoOnClick(Sender: TObject);
  //попадание мышки
  procedure InfoOnMouseEnter(Sender: TObject);
  //уход мышки
  procedure InfoOnMouseLeave(Sender: TObject);
  private
    FilesPath: string;
    OrderArchiveFilePath: string;
    OrderCurrentFilePath: string;
    CfgPc, CfgPick, CfgW: TVarDynArray2;
    QueryToExit: extended;
    FStyleName: string;
    //заполняем значения при создании экземпляра
    FDevFileExists: Boolean;
    FExePath: string;
    FRunFromIDE: Boolean;
    FInfoCurrentHint: string;
    FVersion: string;
    FCompileNumber: Integer;
    FCompileDate: string;
    FVersionString: string;
    FIsUserActive: Boolean;
    FUserActivityTime: TDateTime;
    procedure GetDevFile;
    //определяет, запущена программа из-под IDE или нет
    function GetRunFromIDE: Boolean;
    function GetExePath: string;
    procedure CreateModuleRuFileName;
  public
    property Version: string read FVersion;
    property VersionString: string read FVersionString;
    property CompileNumber: Integer read FCompileNumber;
    property CompileDate: string read FCompileDate;
    //название установленного стиля приложения
    property StyleName: string read FStyleName;
    //путь к каталогу, из которого запущена программа
    property ExePath: string read FExePath;
    //существует файл разрешания отладки /dev в каталоге программы
    property DevFileExists: Boolean read FDevFileExists;
    //запущена программа из-под IDE или нет
    property RunFromIDE: Boolean read FRunFromIDE;
    property IsUserActive: Boolean read FIsUserActive write FIsUserActive;
    property UserActivityTime: TDateTime read FUserActivityTime write FUserActivityTime;
    //конструктор
    constructor Create();
    //выполняется главной программой после создания класса Module и TORADb
    procedure Init;
    //проверяем, читая БД, не установлен ли таймер автозавершения.
    //если установлен, то в наступившее время принудительно завершаем программу
    procedure CheckAutoExit;
    //закрытие программы при длительной неактивности пользователя
    procedure AutoExitIfIdle;
    //загружаем и устанавливаем тему оформления
    procedure SetStyle(const AFileName: string = '');
    //вызов диалога сохранения файла
    function RunSaveDialog(const AFileName, AExtension: string): string;
    //читает переменную конфига приложения с данным именем
    //конфиги загружены из бд ранее,
    function GetCfgVar(const AVarName: string): Variant;
    //определяет, запущена программа с параметром /test
    function InTestmode: Boolean;
    //получить информацию о версии файла/проекта
    //устанавливается в настройках проекта, 3ю (минорную) версию ставим в настройках равной номеру сборки (не компиляции!)
    //после установки cnPack в его настройках выставляем:
    //добавлять дату компиляции в информацию о версии - yyyy/mm/dd hh:mm:ss - будет доступна по параметру LastCompiledTime
    //и автоинкремент номера билда при компиляции - тогда будет при каждой компиляции по F9 увеличиваться минорный в FileVersion
    function GetFileVersion(const AFileName: string = ''; const AParam: string = 'FileVersion'): string;
    //запись строки в лог-файл
    procedure ToLogFile(const AText: string);
    //отправка сообщения с помощью Thunderbird, передает данные в программу и открывает редактор письма
    procedure MailSendWithThunderBird(const ASendTo, ASubject: string; const ABody: string = ''; const AAttachments: string = '');
    //отправка письма
    //передается тема, тело письма в виде строки, и айди пользователей кому надо отправить
    //последние или одно число, или массив айди, или строка айди через запятую
    procedure MailSendToUsers(const ASubject, ABody: string; const AUsers: Variant);
    //Устанавливает таймер закрытия приложения
    //сработает через IntervalMin минут, дробная часть - секунды
    //если IntervalMin=0 то отменит срабатывание, если = -1 то закроет приложение сразу
    procedure CloseAppTimer(const AIntervalMin: extended);
    //--------------------------------------------------------------------------
    //загружает из ресурса Jpeg-картинку
    function GetResourceAsJpeg(const AResName: string): TjpegImage;
    //загружает картинку (TBitmap) из ресурса, тип ресурса определяется автоматом
    //(может быть разный - bmp, jpg, png)
    procedure SetBitmapFromResource(Bm: TBitmap; const AName: pchar);
    //получение информации о состоянии кучи
    function  MemGetHeapStatus: string;
    //получение информации о стеке потока (только для 32-бит)
    function  MemGetStackStatus: string;
    //не используется, оставлен для совместимости
    function  MemGetFreeStackSpace: NativeUInt;
    //запуск проверки утечек памяти (madExcept)
    procedure StartLeakChecking;
    //сохранение отчёта об утечках памяти с дополнительной информацией
    procedure SaveLeakReport;
    //--------------------------------------------------------------------------
    //получение путей к каталогам различных данных программы (счета, заказы...)
    //создание временной папки с меткой времени
    function GetPathNewDir: string;
    //путь к папке Счета
    function GetPath_Accounts(const APath: string = ''): string;
    //путь к папке Счета\Счета (внутри подпапки)
    function GetPath_Accounts_A(const APath: string = ''): string;
    //путь к папке Счета\Заявки
    function GetPath_Accounts_Z(const APath: string = ''): string;
    //путь к папке Комплектация
    function GetPath_Pick(const APath: string = ''): string;
    //путь к папке Комплектация\Изображения
    function GetPath_Pick_Pict(const APath: string = ''): string;
    //путь к папке Комплектация\Сметы
    function GetPath_Pick_Smeta(const APath: string = ''): string;
    //путь к папке Брак материалов\Основание
    function GetPath_Sn_Defectives_Basis(const APath: string = ''): string;
    //путь к папке Брак материалов\УПД
    function GetPath_Sn_Defectives_Upd(const APath: string = ''): string;
    //путь к папке Заказы\Монтаж\Акт
    function GetPath_OrMontage_Act(const APath: string = ''): string;
    //путь к папке Заказы\Монтаж\Фотоотчет
    function GetPath_OrMontage_Photos(const APath: string = ''): string;
    //путь к папке Номенклатура\Чертежи для указанного ID
    function GetPath_Nomencl_Drawings(const AID: Integer = 0): string;
    //путь к папке Заказы\Изделия\XML
    function GetPath_OrItems_Xml(const AID: Integer): string;
    //путь к папке Стандартные изделия\XML
    function GetPath_StdItems_Xml(const AID: Integer): string;
    //путь к папке Заявки СН\Сформированные
    function GetPath_Demand_Created: string;
    //путь к папке ошибок для пользователя и даты
    function GetPath_ErrorLog(const ALogin: string; const ADt: TDateTime): string;
    //путь к архиву заказов за указанный год
    function GetPath_OrderArchive(const AYear: string): string;
    //путь к текущим заказам за указанный год
    function GetPath_OrderCurrent(const AYear: string): string;
    //путь к заказам (текущие или архив) за год
    function GetPath_Order(const AYear: string; const AInArchive: Variant): string;
    //базовый путь к папке отчетов
    function GetPath_ReportsBase(const APath: string = ''): string;
    //путь к папке задач
    function GetPath_Tasks: string;
    //путь к папке стилей
    function GetPath_Styles: string;
    //возвращает путь к исходникам по данному модулю, данной версии и даты сборки
    function Getpath_SrcForVersion(const AModule: Variant; const AVersion, ADtCompiled: string): string;
    //получение полного пути к файлу отчета .xls, с проверкой существования
    function GetReportFileXls(const AFileName: string): string;
    //получение полного пути к файлу отчета .xlsx, с проверкой существования
    function GetReportFileXlsx(const AFileName: string): string;
    //получение полного пути к файлу отчета .xlsm, с проверкой существования
    function GetReportFileXlsm(const AFileName: string): string;
  end;

implementation

uses
  uData,
  uDBOra,
  uMessages,
  uSys,
  uFrmMain,
  madExcept
  ;

constructor TModule.Create();
//создание экземпляра, инициализация свойств
begin
  Inherited Create;
  GetExePath;
  FRunFromIDE := GetRunFromIDE;
  GetDevFile;
  CreateModuleRuFileName;
  FVersion := GetFileVersion;
  FCompileNumber := A.Explode(FVersion, '.')[3];
  FCompileDate := GetFileVersion(ParamStr(0), 'LastCompiledTime');
  FVersionString := FVersion + ' (' + FCompileDate + ')';
  FUserActivityTime := Now;
  FIsUserActive := True;
end;

procedure TModule.Init;
//выполняется главной программой после создания класса Module и TORADb
var
  QueryResult: Variant;
begin
  QueryResult := FRunFromIDE;
  QueryToExit := 0;
  //получим время в минутах с даты автозавершения модуля и время ожидания в минутах
  QueryResult := Q.QLoadRow('select (sysdate - autoclosedt)*24*60, autoclosemin from adm_modules where id = :id', [cMainModule]);
  // если не прошли заданные минуты с момента завершения, то выведем сообщение и завершим приложение
  if (QueryResult[0] > 0) and (QueryResult[0] < QueryResult[1]) then
  begin
    MessageBox(0,
      pWideChar('Приложение "' + string(ModuleRecArr[cMainModule].Caption) + '" не может быть запущено сейчас!' + #13#10 +
      'Попробуйте через ' + IntToStr(trunc(QueryResult[1] - QueryResult[0]) + 1) + ' минут' +
      S.GetEnding(trunc(QueryResult[1] - QueryResult[0]) + 1, 'у', 'ы', '') + '.'),
      'Внимание!', 0);
    Halt;
  end;
  QueryResult := Q.QLoadRow('select filespath, orderarchivepath, ordercurrentpath, orderestimatepath from adm_main_settings', []);
  FilesPath := QueryResult[0];
  OrderArchiveFilePath := QueryResult[1];
  OrderCurrentFilePath := QueryResult[2];
  //OrderEstimateFilePath := QueryResult[3];
  CfgPc := Q.QLoad('select ' + mycfgPCsum_autoagreed + ',' + mycfgPCsum_need_req + ' from sn_calendar_cfg', []);
  CfgPc := CfgPc + [[mycfgPCsum_autoagreed, mycfgPCsum_need_req]];
  CfgPick := Q.QLoadRow('select ' + mycfgKPick_font_size + ' from pick_cfg', []);
  CfgPick := CfgPick + [[mycfgKPick_font_size]];
  CfgW := Q.QLoad('select ' +
    A.Implode([
      mycfgWtime_autoagreed, mycfgWtime_dinner_1, mycfgWtime_dinner_2, mycfgWtime_beg_2, mycfgWtime_beg_diff_2, mycfgWpath_to_payrolls
      ], ',') +
    ' from workers_cfg', []);
  CfgW := CfgW + [[mycfgWtime_autoagreed, mycfgWtime_dinner_1, mycfgWtime_dinner_2, mycfgWtime_beg_2, mycfgWtime_beg_diff_2, mycfgWpath_to_payrolls]];
end;

function TModule.GetCfgVar(const AVarName: string): Variant;
//получение значения переменной конфигурации по её имени
var
  ConfigIndex, FieldIndex: Integer;
  IsFound: Boolean;
  Configs: array of TVarDynArray2;
  FieldValue, FieldName: Variant;
begin
  IsFound := False;
  Configs := [CfgPC, CfgPick, CfgW];
  for ConfigIndex := 0 to High(Configs) do
    for FieldIndex := 0 to High(Configs[ConfigIndex][0]) do
      if Configs[ConfigIndex][1][FieldIndex] = AVarName then
      begin
        Result := Configs[ConfigIndex][0][FieldIndex];
        IsFound := True;
        Exit;
      end;
  if not IsFound then
    Raise Exception.Create('Не найдена переменная конфигурации модуля!');
end;

procedure TModule.GetDevFile;
//проверка наличия файла /dev
begin
  FDevFileExists := Sys.GetDevFile;
end;

function TModule.GetRunFromIDE: Boolean;
//определение запуска из IDE по флагу debughook
begin
  Result := debughook = 1;
end;

function TModule.GetExePath: string;
//получение пути к исполняемому файлу
begin
  Result := ExtractFilePath(ParamStr(0));
  if Result[Length(Result)] = '\' then
    Result := Copy(Result, 1, Length(Result) - 1);
  FExePath := Result;
end;

procedure TModule.CreateModuleRuFileName;
//создание копии exe с русским именем при запуске из IDE
begin
  if not RunFromIDE then Exit;
  {$R-}
  DeleteFile(GetExePath + '\' + ModuleRecArr[cMainModule].FileName + '.exe');
  CopyFile(PChar(ParamStr(0)), PChar(GetExePath + '\' + ModuleRecArr[cMainModule].FileName + '.exe'), True);
  {$R+}
end;

procedure TModule.SetStyle(const AFileName: string = '');
//загрузка и установка стиля оформления
var
  StyleInfo: TStyleInfo;
  StyleHandle: TStyleManager.TStyleServicesHandle;
begin
  if not FileExists(AFileName) then
    Exit;
  if AFileName = '' then
  begin
    TStyleManager.SetStyle('windows');
    FStyleName := '';
    Exit;
  end;
  if TStyleManager.IsValidStyle(AFileName, StyleInfo) then
  begin
    //проверяем возможность подключения стиля
    if not TStyleManager.TrySetStyle(StyleInfo.Name, False) then
    begin
      StyleHandle := TStyleManager.LoadFromFile(AFileName);
      TStyleManager.SetStyle(StyleHandle);
      FStyleName := ExtractFileName(AFileName);
    end;
  end
  else
  begin
    TStyleManager.SetStyle('windows');
    FStyleName := '';
  end;
end;

function TModule.InTestmode: Boolean;
//проверка наличия параметра командной строки /test
begin
  Result := (ParamCount >= 1) and (ParamStr(1) = '/test');
end;

function TModule.GetFileVersion(const AFileName: string = ''; const AParam: string = 'FileVersion'): string;
//получение информации о версии файла (можно запросить разные параметры)
const
  LangCode = '040904E4'; // код языка и кодовой страницы (русский)
var
  InfoSize, ValueLen: DWORD;
  Buffer: PChar;
  VersionValue: PChar;
  FileName: string;
begin
  if AFileName = '' then
    FileName := Application.ExeName
  else
    FileName := AFileName;
  Result := '';
  InfoSize := GetFileVersionInfoSize(PChar(FileName), InfoSize);
  if InfoSize > 0 then
  begin
    Buffer := AllocMem(InfoSize);
    try
      if GetFileVersionInfo(PChar(FileName), 0, InfoSize, Buffer) then
      begin
        if VerQueryValue(Buffer,
                         PChar('StringFileInfo\' + LangCode + '\' + AParam),
                         Pointer(VersionValue), ValueLen) then
          Result := VersionValue;
      end;
    finally
      FreeMem(Buffer, InfoSize);
    end;
  end;
end;

procedure TModule.ToLogFile(const AText: string);
//запись строки в лог-файл
begin
  try
    ForceDirectories(FilesPath + '\Log');
    Sys.SaveTextToFile(
      FilesPath + '\Log\' + ModuleRecArr[cMainModule].FileName + '.txt',
      DateTimeToStr(Now) + ' - ' + AText + #13#10,
      True
    );
  except
    // игнорируем ошибки записи в лог
  end;
end;

procedure TModule.CheckAutoExit;
//проверка таймера автозавершения, если время вышло – закрываем программу
var
  QueryResult: Variant;
  MinutesLeft: Integer;
begin
  Q.SetEnableLoG(False);
  QueryResult := Q.QLoadRow('select round((sysdate - autoclosedt)*24*60,2), autoclosemin from adm_modules where id = :id$i', [cMainModule]);
  Q.SetEnableLoG(True);
  if (QueryResult[0] > 0) and (QueryResult[0] < 3) then
  begin
    if QueryToExit = 0 then
    begin
      QueryToExit := QueryResult[0];
      MinutesLeft := trunc(QueryResult[1] - QueryResult[0]);
      MyMessageDlg(
        'Внимание! Требуется обновление программы! Программа будет автоматически завершена через 1-2 минуты! Вы сможете вновь запустить программу еще примерно через ' +
        IntToStr(MinutesLeft) + ' минут' + S.GetEnding(MinutesLeft, 'у', 'ы', '') + '.',
        mtWarning, [mbOK]
      );
    end;
  end;
  if (QueryResult[0] >= 3) and (QueryResult[0] < 5) then
  begin
    FrmMain.AutoClose := True;
    FrmMain.Close;
  end;
end;

procedure TModule.AutoExitIfIdle;
//закрытие программы при длительной неактивности пользователя
begin
  try
    {$IFDEF SRV}
    Exit;
    {$ENDIF}
    if User.GetIdleTime = 0 then
      Exit;
    if IsUserActive and (MinutesBetween(Now, UserActivityTime) >= User.GetIdleTime) then
    begin
      FIsUserActive := False;
      MyWarningMessage(
        'Вы не были активны долгое время!' + #13#10 +
        'Программа закроется через несколько минут.' + #13#10 +
        'Нажмите Ок чтобы отменить завершение программы.' + #13#10
      );
    end;
    if (not FIsUserActive) and (MinutesBetween(Now, UserActivityTime) >= User.GetIdleTime + 3) then
      FrmMain.Close;
  except
    if (not FIsUserActive) and (MinutesBetween(Now, UserActivityTime) >= User.GetIdleTime + 3) then
      Halt;
  end;
end;

//==============================================================================
// пути к файлам

function TModule.GetPathNewDir: string;
//создание временной папки с меткой времени
begin
  Result := FormatDateTime('yyyy-mm-dd hh.mm.ss.zzz', Now);
end;

function TModule.GetPath_Accounts(const APath: string = ''): string;
//путь к папке Счета
begin
  Result := FilesPath + '\Files\Счета' + S.IIfStr(APath <> '', '\' + APath, '');
end;

function TModule.GetPath_Accounts_A(const APath: string = ''): string;
//путь к папке Счета\Счета (внутри подпапки)
begin
  Result := FilesPath + '\Files\Счета' + '\' + APath + '\Счета';
end;

function TModule.GetPath_Accounts_Z(const APath: string = ''): string;
//путь к папке Счета\Заявки
begin
  Result := FilesPath + '\Files\Счета' + '\' + APath + '\Заявки';
end;

function TModule.GetPath_Pick(const APath: string = ''): string;
//путь к папке Комплектация
begin
  Result := FilesPath + '\Files\Комплектация' + S.IIfStr(APath <> '', '\' + APath, '');
end;

function TModule.GetPath_Pick_Pict(const APath: string = ''): string;
//путь к папке Комплектация\Изображения
begin
  Result := FilesPath + '\Files\Комплектация' + '\' + APath + '\Изображения';
end;

function TModule.GetPath_Pick_Smeta(const APath: string = ''): string;
//путь к папке Комплектация\Сметы
begin
  Result := FilesPath + '\Files\Комплектация' + '\' + APath + '\Сметы';
end;

function TModule.GetPath_Sn_Defectives_Basis(const APath: string = ''): string;
//путь к папке Брак материалов\Основание
begin
  Result := FilesPath + '\Files\Брак материалов' + '\' + APath + '\Основание';
end;

function TModule.GetPath_Sn_Defectives_Upd(const APath: string = ''): string;
//путь к папке Брак материалов\УПД
begin
  Result := FilesPath + '\Files\Брак материалов' + '\' + APath + '\УПД';
end;

function TModule.GetPath_OrMontage_Act(const APath: string = ''): string;
//путь к папке Заказы\Монтаж\Акт
begin
  Result := FilesPath + '\Files\Заказы\Монтаж' + '\' + APath + '\Акт';
end;

function TModule.GetPath_OrMontage_Photos(const APath: string = ''): string;
//путь к папке Заказы\Монтаж\Фотоотчет
begin
  Result := FilesPath + '\Files\Заказы\Монтаж' + '\' + APath + '\Фотоотчет';
end;

function TModule.GetPath_Nomencl_Drawings(const AID: Integer = 0): string;
//путь к папке Номенклатура\Чертежи для указанного ID
var
  FolderName: string;
begin
  if AID <> 0 then
    FolderName := IntToStr(AID)
  else
    FolderName := GetPathNewDir;
  Result := FilesPath + '\Files\Номенклатура\' + FolderName + '\Чертежи';
end;

function TModule.GetPath_OrItems_Xml(const AID: Integer): string;
//путь к папке Заказы\Изделия\XML
begin
  Result := FilesPath + '\Files\Заказы\Изделия\' + IntToStr(AID) + '\XML';
end;

function TModule.GetPath_StdItems_Xml(const AID: Integer): string;
//путь к папке Стандартные изделия\XML
begin
  Result := FilesPath + '\Files\Стандартные изделия\' + IntToStr(AID) + '\XML';
end;

function TModule.GetPath_Demand_Created: string;
//путь к папке Заявки СН\Сформированные
begin
  Result := FilesPath + '\Files\Заявки СН\Сформированные';
end;

function TModule.GetPath_ErrorLog(const ALogin: string; const ADt: TDateTime): string;
//путь к папке ошибок для пользователя и даты
begin
  Result := FilesPath + '\Errors\' + ALogin + '\' + FormatDateTime('yyyy-mm-dd hh.mm.ss.zzz', ADt);
end;

function TModule.GetPath_OrderArchive(const AYear: string): string;
//путь к архиву заказов за указанный год
begin
  Result := StringReplace(OrderArchiveFilePath, 'YYYY', AYear, [rfReplaceAll, rfIgnoreCase]);
end;

function TModule.GetPath_OrderCurrent(const AYear: string): string;
//путь к текущим заказам за указанный год
begin
  Result := StringReplace(OrderCurrentFilePath, 'YYYY', AYear, [rfReplaceAll, rfIgnoreCase]);
end;

function TModule.GetPath_Order(const AYear: string; const AInArchive: Variant): string;
//путь к заказам (текущие или архив) за год
begin
  if VarToStr(AInArchive) = '1' then
    Result := StringReplace(OrderArchiveFilePath, 'YYYY', AYear, [rfReplaceAll, rfIgnoreCase])
  else
    Result := StringReplace(OrderCurrentFilePath, 'YYYY', AYear, [rfReplaceAll, rfIgnoreCase]);
end;

function TModule.GetPath_ReportsBase(const APath: string = ''): string;
//базовый путь к папке отчетов
begin
  Result := FilesPath + '\Reports';
end;

function TModule.GetPath_Tasks: string;
//путь к папке задач
begin
  Result := FilesPath + '\Tasks';
end;

function TModule.GetPath_Styles: string;
//путь к папке стилей
begin
  Result := FilesPath + '\Styles';
end;

function TModule.Getpath_SrcForVersion(const AModule: Variant; const AVersion, ADtCompiled: string): string;
//путь к исходникам для указанного модуля, версии и даты сборки
begin
  Result := FilesPath + '\Src\' + VarToStr(AModule) +
            '__' + AVersion + '__' + StringReplace(ADtCompiled, ':', '.', [rfReplaceAll]);
end;

function TModule.GetReportFileXls(const AFileName: string): string;
//получение полного пути к файлу отчета .xls, с проверкой существования
begin
  Result := Module.GetPath_ReportsBase + '\' + AFileName + '.xls';
  if not SysUtils.FileExists(Result) then
  begin
    MyWarningMessage('Файл отчета "' + AFileName + '.xls" не найден!');
    Result := '';
  end;
end;

function TModule.GetReportFileXlsx(const AFileName: string): string;
//получение полного пути к файлу отчета .xlsx, с проверкой существования
begin
  Result := Module.GetPath_ReportsBase + '\' + AFileName + '.xlsx';
  if not SysUtils.FileExists(Result) then
  begin
    MyWarningMessage('Файл отчета "' + AFileName + '.xlsx" не найден!');
    Result := '';
  end;
end;

function TModule.GetReportFileXlsm(const AFileName: string): string;
//получение полного пути к файлу отчета .xlsm, с проверкой существования
begin
  Result := Module.GetPath_ReportsBase + '\' + AFileName + '.xlsm';
  if not SysUtils.FileExists(Result) then
  begin
    MyWarningMessage('Файл отчета "' + AFileName + '.xlsm" не найден!');
    Result := '';
  end;
end;

procedure TModule.MailSendWithThunderBird(const ASendTo, ASubject: string; const ABody: string = ''; const AAttachments: string = '');
//отправка письма через Thunderbird (открывает окно редактора)
var
  Params: string;
  SendToParam, SubjectParam, BodyParam, AttachmentsParam: string;
begin
  SendToParam := S.IIfStr(ASendTo <> '', 'to=''' + ASendTo + '''', '');
  SubjectParam := S.IIfStr(ASubject <> '', 'subject=''' + ASubject + '''', '');
  if Pos(#133, ABody) = 0 then
    BodyParam := S.IIfStr(ABody <> '', 'body=''' + ABody + '''', '');
  AttachmentsParam := S.IIfStr(AAttachments <> '', 'attachments=''' + AAttachments + '''', '');
  Params := '-compose "' + A.ImplodeNotEmpty([SendToParam, SubjectParam, BodyParam, AttachmentsParam], ',') + '"';
  ShellExecute(Application.Handle, nil, pWideChar('thunderbird.exe'), pWideChar(Params), nil, SW_SHOWNORMAL);
end;

procedure TModule.MailSendToUsers(const ASubject, ABody: string; const AUsers: Variant);
//отправка письма пользователям по их ID (один, массив или строка через запятую)
var
  Msg: TIdMessage;
  UsersArray: TVarDynArray;
  UserIndex, FieldIndex: Integer;
  QueryResult, TempVar: Variant;
  EMailAddresses: string;
begin
  UsersArray := A.VarIntToArray(AUsers);
  if Length(UsersArray) = 0 then Exit;
  EMailAddresses := '';
  for UserIndex := 0 to High(UsersArray) do
  begin
    if StrToIntDef(VarToStr(UsersArray[UserIndex]), -1) = -1 then Continue;
    QueryResult := Q.QLoadRow('select emailaddr from v_users where id = :id$i', [S.VarToInt(UsersArray[UserIndex])]);
    if S.NSt(QueryResult[0]) <> '' then
      EMailAddresses := S.ConcatSt(EMailAddresses, QueryResult[0], ',');
  end;
  if EMailAddresses = '' then Exit;
  QueryResult := Q.QLoadRow('select emaildomain, emailuser, emailserver, emaillogin, emailpassword from adm_main_settings', []);
  Msg := nil;
  try
    MyData.IdSMTP1.Host := S.NSt(QueryResult[2]);
    MyData.IdSMTP1.Port := 25;
    MyData.IdSMTP1.Username := S.NSt(QueryResult[3]);
    MyData.IdSMTP1.Password := S.NSt(QueryResult[4]);
    MyData.IdSMTP1.AuthType := satDefault;
    MyData.IdSMTP1.Connect;
    if MyData.IdSMTP1.Connected then
    begin
      Msg := TIdMessage.Create(nil);
      try
        Msg.CharSet := 'UTF-8';
        Msg.Body.Text := UTF8Encode(ABody);
        Msg.Subject := ASubject;
        Msg.From.Address := S.NSt(QueryResult[1]) + '@' + S.NSt(QueryResult[0]);
        Msg.From.Name := 'Учет';
        Msg.Recipients.EMailAddresses := EMailAddresses;
        Msg.IsEncoded := True;
        MyData.IdSMTP1.Send(Msg);
      finally
        Msg.Free;
      end;
      MyData.IdSMTP1.Disconnect;
    end;
  except
    // если не удалось отправить, просто выходим
    MyData.IdSMTP1.Disconnect;
  end;
end;

procedure TModule.CloseAppTimer(const AIntervalMin: extended);
//установка таймера закрытия приложения (0 – отмена, -1 – немедленное закрытие)
begin
  if AIntervalMin = -1 then
    FrmMain.Close
  else if AIntervalMin = 0 then
  begin
    FrmMain.TimerSrvClose.Interval := 3000;
    FrmMain.TimerSrvClose.Enabled := False;
  end
  else
  begin
    FrmMain.TimerSrvClose.Interval := Trunc(AIntervalMin) * 60 * 1000 + Round(Frac(AIntervalMin) * 10000);
    FrmMain.TimerSrvClose.Enabled := True;
  end;
end;

procedure TModule.MenuSpeedButton1Click(Sender: TObject);
//обработчик клика по кнопке с выпадающим меню (вызывает всплывающее меню)
var
  Button: TControl;
  LowerLeft: TPoint;
  PopupMenu: TPopupMenu;
begin
  if Sender is TControl then
  begin
    Button := TControl(Sender);
    LowerLeft := Point(0, Button.Height);
    LowerLeft := Button.ClientToScreen(LowerLeft);
    PopupMenu := TPopupMenu(Button.Owner.FindComponent('M' + Button.Name));
    if PopupMenu <> nil then
      PopupMenu.Popup(LowerLeft.X, LowerLeft.Y);
  end;
end;

function TModule.InfoGetHintText(Sender: TObject; const AMode: Boolean = True): string;
//получение текста подсказки или полного текста окна информации в зависимости от режима
var
  SeparatorPos: Integer;
  FullText: string;
begin
  FullText := FInfoCurrentHint;
  SeparatorPos := Pos('...', FullText);
  if SeparatorPos > 0 then
  begin
    if AMode then
      Result := Copy(FullText, 1, SeparatorPos + 2)
    else
      Result := Copy(FullText, 1, SeparatorPos - 1) + Copy(FullText, SeparatorPos + 3, MaxInt);
  end
  else
  begin
    SeparatorPos := Pos('___', FullText);
    if SeparatorPos > 0 then
    begin
      if AMode then
        Result := Copy(FullText, 1, SeparatorPos - 1)
      else
        Result := Copy(FullText, SeparatorPos + 3, MaxInt);
    end
    else
      Result := FullText;
  end;
  if AMode and (SeparatorPos > 0) then
    Result := Result + #10#13 + '(нажмите!)';
end;

procedure TModule.InfoOnClick(Sender: TObject);
//обработчик клика по иконке помощи – показывает полный текст
begin
  if InfoGetHintText(Sender, False) <> '' then
    MyInfoMessage(InfoGetHintText(Sender, False), 1);
end;

procedure TModule.InfoOnMouseEnter(Sender: TObject);
//при наведении мыши на иконку – подменяем хинт на краткую подсказку
begin
  FInfoCurrentHint := TImage(Sender).Hint;
  TImage(Sender).Hint := InfoGetHintText(Sender, True);
  TImage(Sender).ShowHint := True;
end;

procedure TModule.InfoOnMouseLeave(Sender: TObject);
//при уходе мыши – восстанавливаем оригинальный хинт
begin
  TImage(Sender).ShowHint := False;
  TImage(Sender).Hint := FInfoCurrentHint;
end;

//------------------------------------------------------------------------------
// работа с ресурсами

function TModule.GetResourceAsJpeg(const AResName: string): TjpegImage;
//загрузка JPEG из ресурса
var
  ResourceStream: TResourceStream;
begin
  ResourceStream := TResourceStream.Create(hInstance, AResName, 'JPEG');
  try
    Result := TJPEGImage.Create;
    Result.LoadFromStream(ResourceStream);
  finally
    ResourceStream.Free;
  end;
end;

procedure TModule.SetBitmapFromResource(Bm: TBitmap; const AName: pchar);
//загрузка картинки из ресурса (автоопределение типа)
var
  Bmp: TBitmap;
  Jpg: TJPEGImage;
  Png: TPNGObject;
  ResourceFound: Integer;
begin
  ResourceFound := FindResource(HInstance, AName, RT_BITMAP);
  if ResourceFound <> 0 then
  begin
    Bmp := TBitmap.Create;
    try
      Bmp.LoadFromResourceName(HInstance, AName);
      Bm.Assign(Bmp);
    finally
      Bmp.Free;
    end;
    Exit;
  end;
  ResourceFound := FindResource(HInstance, AName, 'JPEG');
  if ResourceFound <> 0 then
  begin
    Jpg := GetResourceAsJpeg(AName);
    try
      Bm.Assign(Jpg);
    finally
      Jpg.Free;
    end;
    Exit;
  end;
  ResourceFound := FindResource(HInstance, AName, RT_RCDATA);
  if ResourceFound <> 0 then
  begin
    Png := TPNGObject.Create;
    try
      Png.LoadFromResourceName(HInstance, AName);
      Bm.Assign(Png);
    finally
      Png.Free;
    end;
  end;
end;

function TModule.RunSaveDialog(const AFileName, AExtension: string): string;
//вызов стандартного диалога сохранения файла
var
  CurrentDir: string;
begin
  Result := '';
  GetDir(0, CurrentDir);
  MyData.SaveDialog1.FileName := AFileName;
  MyData.SaveDialog1.DefaultExt := AExtension;
  if MyData.SaveDialog1.Execute then
    Result := MyData.SaveDialog1.FileName
  else
    Exit;
  if ExtractFileExt(Result) <> '.' + AExtension then
    Result := Result + '.' + AExtension;
  if FileExists(Result) and (MyQuestionMessage('Файл уже существует! Перезаписать его?') <> mrYes) then
  begin
    Result := '';
    Exit;
  end;
end;

procedure TModule.StartLeakChecking;
//запуск проверки утечек памяти (madExcept)
begin
  MadExcept.StopLeakChecking;
  MadExcept.ClearLeaks;
  MadExcept.StartLeakChecking;
  Beep;
end;

procedure TModule.SaveLeakReport;
//сохранение отчёта об утечках памяти с дополнительной информацией
var
  LineIndex: Integer;
  LeakCount, LeakSize: Integer;
  ReportText, HeaderText: string;
  Lines: TVarDynArray;
begin
  ReportText := MadExcept.GetLeakReport;
  LeakCount := 0;
  LeakSize := 0;
  Lines := A.Explode(ReportText, #13#10);
  for LineIndex := 0 to High(Lines) do
  begin
    if Pos('size: ', Lines[LineIndex]) = 1 then
    begin
      Inc(LeakCount);
      LeakSize := LeakSize + StrToIntDef(Copy(Lines[LineIndex], 7, 255), 0);
    end;
  end;
  HeaderText :=
    'Активная форма: ' + S.IIf(Screen.ActiveForm = nil, 'нет', Screen.ActiveForm.Name + ' (' + Screen.ActiveForm.Caption + ')') + #13#10 +
    'Активный контрол: ' + S.IIf(Screen.ActiveControl = nil, 'нет', Screen.ActiveControl.Name) + #13#10 +
    MemGetHeapStatus + #13#10 + MemGetStackStatus + #13#10 +
    'Memory Leaks: ' + IntToStr(LeakCount) + #13#10 + 'Memory Leak Size: ' + IntToStr(LeakSize);
  try
    if DirectoryExists('r:\') then
      Sys.SaveTextToFile('r:\!LeakReport.txt', HeaderText + #13#10#13#10 + ReportText);
  finally
    // ничего не делаем
  end;
  MadExcept.StopLeakChecking;
  MadExcept.ClearLeaks;
  MyInfoMessage(HeaderText);
end;

function TModule.MemGetHeapStatus: string;
//получение информации о состоянии кучи
var
  HeapStatus: THeapStatus;
begin
  HeapStatus := GetHeapStatus;
  Result := Format(
    '[Куча]  Выделено = %d Кб, Свободно = %d Кб, Макс. блок = %d Кб',
    [Round(HeapStatus.TotalAllocated / 1024), Round(HeapStatus.TotalFree / 1024), Round(HeapStatus.FreeBig / 1024)]
  );
end;

function TModule.MemGetStackStatus: string;
//получение информации о стеке потока (только для 32-бит)
var
  StackTop, StackBase, CurrentESP: Pointer;
begin
  asm
    mov eax, fs:[4]    // StackBase (TIB + 0x04)
    mov StackBase, eax
    mov eax, fs:[8]    // StackLimit (TIB + 0x08)
    mov StackTop, eax
    mov CurrentESP, esp // Текущий указатель стека
  end;
  Result := Format(
    '[Стек]  Всего = %d байт, Свободно = %d байт',
    [NativeUInt(StackBase) - NativeUInt(StackTop), NativeUInt(CurrentESP) - NativeUInt(StackTop)]
  );
end;

function TModule.MemGetFreeStackSpace: NativeUInt;
//не используется, оставлен для совместимости
begin
  Result := 0;
end;

end.
