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
  {$IFDEF DEBUG}
//  ,FastMM4
  {$ENDIF}
  ;


type
  TModule = class
    //события иконки - Help, присутствующей на разных формах
    //события для панелей кнопок, вызывается при клике кнопки с выпадающим списком
    procedure MenuSpeedButton1Click(Sender: TObject);
    //получсает из полного текста инфы текст хинта для тру или окна инфы для фолс
    //если текст разделен ___ то что до этого разделителя выводится в подсказке, а что после - в окне
    //если тект разделен ... то в хинте выводится с начала текста, включая ..., в окне выводится полностью, многоточие вырезается
    //если без разделителей то выводится все и в хинте и в окне
    function InfoGetHintText(Sender: TObject; Mode: Boolean = True): string;
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
    FIsUserActive: Boolean;
    FUserActivityTime: TDateTime;
    procedure GetDevFile;
    //определяет, запущена программа из-под IDE или нет
    function GetRunFromIDE: Boolean;
    function GetExePath: string;
    procedure CreateModuleRuFileName;
  public
    property Version: string read FVersion;
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
    //выполняется главной программаой после создания класса Module и TORADb
    procedure Init;
    //проверяем, читая БД, не установлен ли таймер автозавершения.
    //если установлен, то в наступившее время принудительно завершаем программу
    procedure CheckAutoExit;
    procedure AutoExitIfIdle;
    //загружаем и устанавливаем тему оформления
    procedure SetStyle(filename: string = '');
    //вызов диалога сохранения файла
    function RunSaveDialog(FileName, Extention: string): string;
    //читает переменную конфига приложения с данным именем
    //конфиги загруужени из бд ранее,
    function GetCfgVar(VarName: string): Variant;
    //определяет, запущена программа с параметром /test
    function InTestmode: Boolean;
    //получить информацию о версии файла/проекта
    //устанавлитвается в настройках проекта, 3ю (минорную) версию ставим в настройках равной номеру сборки (не компиляции!)
    //после установки cnPack в его настройках выставляем:
    //добапвлять дату компиляции в информацию о версии - yyyy/mm/dd hh:mm:ss - будет доступна по параметру LastCompiledTime
    //и автоинкремент номера билда при компиляции - тогда будет при каждой компиляции по F9 увеличиваться минорный в FileVersion
    function GetFileVersion(Filename: string = ''; Param: string = 'FileVersion'): string;
    procedure ToLogFile(st: string);
    //отправка сообщения с помощью Thunderbird, передает данные в программу и открывает редактор письма
    procedure MailSendWithThunderBird(SendTo: string; Subject: string; Body: string = ''; Attachments: string = '');
    //отправка письма
    //передается тема, тело письма в виде строки, и айди пользователей кому надо отправить
    //последнии или однно число, или массив айди, или строка айди через запятую
    procedure MailSendToUsers(Subject: string; Body: string; Users: Variant);
    //Устанавливает таймер закрытия приложения
    //сработает через IntervalMin минут, дробная часть - секунды
    //если IntervalMin=0 то отменит срабатывание, если = -1 то закроет приложение сразу
    procedure CloseAppTimer(IntervalMin: extended);
    //--------------------------------------------------------------------------
    //загружает из ресурса Jpeg-картинку
    function GetResourceAsJpeg(const resname: string): TjpegImage;
    //загружает картинку (TBitmap) из ресурса, тип ресурса определяется автоматом
    //(может быть разный - bmp, jpg, png)
    procedure SetBitmapFromResource(Bm: TBitmap; Name: pchar);


    function  MemGetHeapStatus: string;
    function  MemGetStackStatus: string;
    function  MemGetFreeStackSpace: NativeUInt;
    procedure StartLeakChecking;
    procedure SaveLeakReport;
    //--------------------------------------------------------------------------
    //получение путей к каталогам различных данных программы (счета, запазы...)
    function GetPathNewDir: string;
    function GetPath_Accounts(Path: string = ''): string;
    function GetPath_Accounts_A(Path: string = ''): string;
    function GetPath_Accounts_Z(Path: string = ''): string;
    function GetPath_Pick(Path: string = ''): string;
    function GetPath_Pick_Pict(Path: string = ''): string;
    function GetPath_Pick_Smeta(Path: string = ''): string;
    function GetPath_Sn_Defectives_Basis(Path: string = ''): string;
    function GetPath_Sn_Defectives_Upd(Path: string = ''): string;
    function GetPath_OrMontage_Act(Path: string = ''): string;
    function GetPath_OrMontage_Photos(Path: string = ''): string;
    function GetPath_Nomencl_Drawings(ID: Integer = 0): string;
    function GetPath_OrItems_Xml(ID: Integer): string;
    function GetPath_StdItems_Xml(ID: Integer): string;
    function GetPath_Demand_Created: string;
    function GetPath_ErrorLog(Login: string; Dt: TDateTime): string;
    function GetPath_OrderArchive(Year:string): string;
    function GetPath_OrderCurrent(Year:string): string;
    function GetPath_Order(Year:string; InArchive:Variant): string;
    function GetPath_ReportsBase(Path: string = ''): string;
    function GetPath_Tasks: string;
    function GetPath_Styles: string;
    //возвращает путь к исходникам по данному модулю, данной версии и даты сборки
    function Getpath_SrcForVersion(AModule: Variant; AVersion: string; ADtCompiled: string): string;
    //получение файлов отчета Excel из папки отчетов, с сообщением если не найден
    function GetReportFileXls(FileName: string): string;
    function GetReportFileXlsx(FileName: string): string;
    function GetReportFileXlsm(FileName: string): string;
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
begin
  Inherited Create;
  //получим путь к исполняемому файлу
  GetExePath;
  //статус работы под ИДЕ
  FRunFromIDE:=GetRunFromIDE;
  //файл разрешения отладки
  GetDevFile;
  //Создадим файл с русским названием, если программа запущена из-под ИДЕ
  CreateModuleRuFileName;
  FVersion:=GetFileVersion;
  FCompileNumber:=A.Explode(FVersion, '.')[3];
  FCompileDate:=GetFileVersion(ParamStr(0), 'LastCompiledTime');
  FUserActivityTime := Now;
  FIsUserActive := True;
end;

procedure TModule.Init;
//выполняется главной программаой после создания класса Module и TORADb
var
  v: Variant;
begin
v:=FRunFromIDE;
  QueryToExit:= 0;
  //получим время в минутах с даты автозавершения модуля и время ожидания в минутах (дата может быть нулл и это пройдет нормально)
  v:=Q.QSelectOneRow('select (sysdate - autoclosedt)*24*60, autoclosemin from adm_modules where id = :id', [cMainModule]);
  // если не прошли заданные минуты с момента завершения, то выведем сообщение и завершим приложение
  if (v[0]>0) and (v[0]<v[1]) then begin
    MessageBox(0,pWideChar('Приложение "' + string(ModuleRecArr[cMainModule].Caption) + '" не может быть запущено сейчас!'+#13#10+
      'Попробуйте через '+IntToStr(trunc(v[1]-v[0])+1)+' минут'+S.GetEnding(trunc(v[1]-v[0])+1,'у','ы','')+'.'),'Внимание!',0);
    Halt;
  end;
  v:=Q.QSelectOneRow('select filespath, orderarchivepath, ordercurrentpath, orderestimatepath from adm_main_settings', []);
  FilesPath:=v[0];
  OrderArchiveFilePath:= v[1];
  OrderCurrentFilePath:= v[2];
  //OrderEstimateFilePath:= v[3];
  CfgPc:=Q.QLoadToVarDynArray2('select ' + mycfgPCsum_autoagreed + ',' + mycfgPCsum_need_req + ' from sn_calendar_cfg', []);
  CfgPc:=CfgPc + [[mycfgPCsum_autoagreed, mycfgPCsum_need_req]];
{  PC_AutoAgreed:= v[0];
  PC_ReqSum:= v[1];}
  CfgPick:=Q.QSelectOneRow('select ' + mycfgKPick_font_size + ' from pick_cfg', []); //, path_to_files
  CfgPick:=CfgPick + [[mycfgKPick_font_size]];
//  Pick_FilePath:= v[1];
  CfgW:=Q.QLoadToVarDynArray2('select ' +
    A.Implode([
      mycfgWtime_autoagreed, mycfgWtime_dinner_1, mycfgWtime_dinner_2, mycfgWtime_beg_2, mycfgWtime_beg_diff_2, mycfgWpath_to_payrolls
      ], ',') +
    ' from workers_cfg', []);
  CfgW:=CfgW + [[mycfgWtime_autoagreed, mycfgWtime_dinner_1, mycfgWtime_dinner_2, mycfgWtime_beg_2, mycfgWtime_beg_diff_2, mycfgWpath_to_payrolls]];
{  W_AutoAgreedTurvTime:=v[0];
  W_Dinner_Time_1:=v[1];
  W_Dinner_Time_2:=v[2];
  W_Time_Beg_2:=v[3];
  W_Time_Beg_Diff_2:=v[4];
  W_PayrollPath:=v[5];//'R:\Uchet\ЗП шаблон\Test';}

//  v:=GetCfgVar(mycfgWtime_dinner_2);
end;

function TModule.GetCfgVar(VarName: string): Variant;
var
  i, j: Integer;
  v: Variant;
  b: Boolean;
  va: Array of TVarDynArray2;
begin
  b:=False;
  va:=[CfgPC, CfgPick, CfgW];
  for i:=0 to High(va) do
    for j:=0 to High(va[i][0]) do
      if va[i][1][j] = VarName then begin
        Result:=va[i][0][j];
        b:=True;
        Exit;
      end;
  if not b
    then Raise Exception.Create('Не найдена переменная конфигурации модуля!');
end;

procedure TModule.GetDevFile;
begin
  FDevFileExists:= Sys.GetDevFile;
end;

function TModule.GetRunFromIDE: Boolean;
//после применения msdExcept, сначала по ходу выполнения debughook равен 1, а потом 2
//проверку иде делаем только при запуске
begin
  Result:=debughook = 1;
end;

function TModule.GetExePath: string;
begin
  Result:=ExtractFilePath(ParamStr(0));
  if Result[Length(Result)] = '\' then Result:=Copy(Result,1, Length(Result)-1);
  FExePath:= Result;
end;

procedure TModule.CreateModuleRuFileName;
begin
  if not RunFromIDE then Exit;
  {$R-}
  DeleteFile(GetExePath + '\' + ModuleRecArr[cMainModule].FileName + '.exe');
  CopyFile(PChar(ParamStr(0)), PChar(GetExePath + '\' + ModuleRecArr[cMainModule].FileName + '.exe'), True);
  {$R+}
end;

procedure TModule.SetStyle(filename: string = '');
//загружаем и устанавливаем тему оформления
var
  StyleInfo: TStyleInfo;
  Handle:TStyleManager.TStyleServicesHandle;
begin
  if not FileExists(FileName) then FileName:='';
  if FileName = ''
    then begin TStyleManager.SetStyle('windows'); FStyleName:=''; Exit; end;
   if TStyleManager.IsValidStyle(FileName, StyleInfo)=True then
   begin
     {выводим информацию}
{      lbl8.Caption:=si.Name;
      lbl9.Caption:=si.Author;
      lbl10.Caption:=si.AuthorEMail;
      lbl11.Caption:=si.AuthorURL;
      lbl12.Caption:=si.Version;}
     //проверяем возможность подключения стиля
     if TStyleManager.TrySetStyle(StyleInfo.Name,False)=False then
     begin
       //стиль следует загрузить и зарегистрировать
       Handle:=TStyleManager.LoadFromFile(FileName);
       TStyleManager.SetStyle(Handle);
       FStyleName:=ExtractFileName(filename);
     end;
  end
  else begin
    TStyleManager.SetStyle('windows'); FStyleName:='';
  end;
end;

function TModule.InTestmode: Boolean;
//определяет, запущена программа с параметром /test
begin
  Result:=(ParamCount >= 1)and(ParamStr(1) = '/test');
end;

function TModule.GetFileVersion(Filename: string = ''; Param: string = 'FileVersion'): string;
//получить информацию о версии файла/проекта
//устанавлитвается в настройках проекта, 3ю (минорную) версию ставим в настройках равной номеру сборки (не компиляции!)
//после установки cnPack в его настройках модуля Информация о версии выставляем:
//добапвлять дату компиляции в информацию о версии - yyyy/mm/dd hh:mm:ss - будет доступна по параметру LastCompiledTime
//и автоинкремент номера билда при компиляции - тогда будет при каждой компиляции по F9 увеличиваться минорный в FileVersion

{// FileVersion можно заменить на:
// CompanyName
// FileDescription
// FileVersion         +cnPack - compile
// InternalName
// LegalCopyright
// LegalTradeMarks
// OriginalFileName
// ProductName
// ProductVersion
// Comments
// LastCompiledTime   +cnPack
}
var
  N, Len: DWORD;
  Buf: PChar;
  Value: PChar;
begin
  if FileName='' then FileName:=Application.ExeName;
  Result := '';
  N := GetFileVersionInfoSize(PChar(Filename), N);
  if N > 0 then
  begin
     Buf := AllocMem(N);
     GetFileVersionInfo(PChar(Filename), 0, N, Buf);
     if VerQueryValue(Buf,
                      PChar('StringFileInfo\040904E4\' + Param), //про это смотреть ниже
                      Pointer(Value), Len) then
        Result := Value;
     FreeMem(Buf, N);
  end;
end;

procedure TModule.ToLogFile(st: string);
begin
  try
    ForceDirectories(FilesPath + '\Log');
    Sys.SaveTextToFile(
      FilesPath + '\Log\' + ModuleRecArr[cMainModule].FileName + '.txt',
      DateTimeToStr(Now) + ' - ' + st + #13#10,
      True
    );
  except
  end;
end;

procedure TModule.CheckAutoexit;
//проверяем, читая БД, не установлен ли таймер автозавершения.
//если установлен, то в наступившее время принудительно завершаем программу
var
  i:Variant;
  m:Integer;
begin
//exit;
  //получим время в минутах с даты автозавершения модуля и время ожидания в минутах (дата может быть нулл и это пройдет нормально)
  Q.SetEnableLoG(False);
  //на этой строке при получении значения поля в QSelectOneRow можути быть выданна ошибка:
  //1180.8833333333333333333333333 is not a valid BCD value.
  //попоробуем ограничить количество десятичнх знаков
  i:=Q.QSelectOneRow('select round((sysdate - autoclosedt)*24*60,2), autoclosemin from adm_modules where id = :id$i', [cMainModule]);
  Q.SetEnableLoG(True);
  if (i[0]>0) and (i[0]<3) then begin
    //среагирует в течении одной-не более трех трех минут после времени завершения, выдадим сообщение если не было уже выдано ранее
    if QueryToExit = 0
      then begin
        QueryToExit:= i[0];
        m:=trunc(i[1]-i[0]);
        MyMessageDlg('Внимание! Требуется обновление программы! Программа будет автоматически завершена через 1-2 минуты! Вы сможете вновь запустить программу еще примерно через '+IntToStr(m)+' минут'+S.GetEnding(m,'у','ы','')+'.' , mtWarning,  [mbOK] );
      end;
  end;
  if (i[0]>=3) and (i[0]<5) then begin
    //через 3-4 минуты после времени завершения закроем программу
    FrmMain.AutoClose:=True;
    FrmMain.Close;
  end;
end;

procedure TModule.AutoExitIfIdle;
//проверяем, что пользователь не был активен заданное для него время
//(не нажимал клавиши и кнопку мыши, что проверяется в обработчике событий главной формы)
//ели это так, выводим окно, и если не будет нажатий или оно не будет закрыто, то через 3мин закроем программу
begin
  try
    {$IFDEF SRV}
    Exit;
    {$ENDIF}
    if User.GetIdleTime = 0 then
      Exit;
    if IsUserActive and (MinutesBetween(Now, UserActivityTime) >= User.GetIdleTime) then begin
      FIsUserActive := False;
      MyWarningMessage(
        'Вы не были активны долгое время!'#13#10+
        'Программа закроется через несколько минут.'#13#10+
        'Нажмите Ок чтобы отменить завершение программы.'#13#10
      );
    end;
    if (not FIsUserActive) and (MinutesBetween(Now, UserActivityTime) >= User.GetIdleTime + 3) then begin
     FrmMain.Close;
    end;
  except
    if (not FIsUserActive) and (MinutesBetween(Now, UserActivityTime) >= User.GetIdleTime + 3) then
      Halt;
  end;

end;


//==============================================================================

//пути к файлам
//как правило для каждого документа используется папка в виде времени создания
//айди использовать не получается тк на момент загрузки документа, в случае создания нового документа, айди еще неизвестен

function TModule.GetPathNewDir: string;
begin
  Result:=FormatDateTime('yyyy-mm-dd hh.mm.ss.zzz', Now);
end;

function TModule.GetPath_Accounts(Path: string = ''): string;
begin
  Result:=FilesPath + '\Files\Счета' + S.IIf(Path = '', '', '\' + Path);
end;

function TModule.GetPath_Accounts_A(Path: string = ''): string;
begin
  Result:=FilesPath + '\Files\Счета'  + '\' + Path + '\Счета';
end;

function TModule.GetPath_Accounts_Z(Path: string = ''): string;
begin
  Result:=FilesPath + '\Files\Счета'  + '\' + Path + '\Заявки';
end;

function TModule.GetPath_Pick(Path: string = ''): string;
begin
  Result:=FilesPath + '\Files\Комплектация' + S.IIf(Path = '', '', '\' + Path);
end;

function TModule.GetPath_Pick_Pict(Path: string = ''): string;
begin
  Result:=FilesPath + '\Files\Комплектация' + '\' + Path + '\Изображения';
end;

function TModule.GetPath_Pick_Smeta(Path: string = ''): string;
begin
  Result:=FilesPath + '\Files\Комплектация' + '\' + Path + '\Сметы';
end;

function TModule.GetPath_Sn_Defectives_Basis(Path: string = ''): string;
begin
  Result:=FilesPath + '\Files\Брак материалов' + '\' + Path + '\Основание';
end;

function TModule.GetPath_Sn_Defectives_Upd(Path: string = ''): string;
begin
  Result:=FilesPath + '\Files\Брак материалов' + '\' + Path + '\УПД';
end;

function TModule.GetPath_OrMontage_Act(Path: string = ''): string;
begin
  Result:=FilesPath + '\Files\Заказы\Монтаж'  + '\' + Path + '\Акт';
end;

function TModule.GetPath_OrMontage_Photos(Path: string = ''): string;
begin
  Result:=FilesPath + '\Files\Заказы\Монтаж'  + '\' + Path + '\Фотоотчет';
end;

function TModule.GetPath_Nomencl_Drawings(ID: Integer = 0): string;
var
  st: string;
begin
  if ID <> 0
    then st := IntToStr(ID)
    else st := GetPathNewDir;
  Result:=FilesPath + '\Files\Номенклатура\' + st + '\Чертежи';
end;

function TModule.GetPath_OrItems_Xml(ID: Integer): string;
begin
  Result := FilesPath + '\Files\Заказы\Изделия\' + IntToStr(ID) + '\XML';
end;

function TModule.GetPath_StdItems_Xml(ID: Integer): string;
begin
  Result := FilesPath + '\Files\Стандартные изделия\' + IntToStr(ID) + '\XML';
end;

function TModule.GetPath_Demand_Created: string;
begin
  Result:=FilesPath + '\Files\Заявки СН\Сформированные';
end;

function TModule.GetPath_ErrorLog(Login: string; Dt: TDateTime): string;
begin
  Result:=FilesPath + '\Errors\' + Login + '\' + FormatDateTime('yyyy-mm-dd hh.mm.ss.zzz', Dt);
end;

function TModule.GetPath_ReportsBase(Path: string = ''): string;
begin
  Result:=FilesPath + '\Reports';
end;

function TModule.GetPath_Tasks(): string;
begin
  Result:=FilesPath + '\Tasks';
end;

function TModule.GetPath_Styles: string;
begin
  Result:=FilesPath + '\Styles';
end;

function TModule.Getpath_SrcForVersion(AModule: Variant; AVersion: string; ADtCompiled: string): string;
//возвращает путь к исходникам по данному модулю, данной версии и даты сборки
begin
//  Result:=FilesPath + '\Src\' + S.IIf(S.IsInt(AModule), ModuleRecArr[S.VarToInt(AModule)].Caption, AModule) +
  Result:=FilesPath + '\Src\' + AModule +
          '__' + AVersion + '__' + StringReplace(ADtCompiled, ':', '.', [rfReplaceAll]);
end;



function TModule.GetPath_OrderArchive(Year:string): string;
begin
  Result:=StringReplace(OrderArchiveFilePath,'YYYY', year, [rfReplaceAll, rfIgnoreCase]);
end;

function TModule.GetPath_OrderCurrent(Year:string): string;
begin
  Result:=StringReplace(OrderCurrentFilePath,'YYYY', year, [rfReplaceAll, rfIgnoreCase]);
end;

function TModule.GetPath_Order(Year:string; InArchive:Variant): string;
begin
  if VarToStr(InArchive) = '1'
    then Result:=StringReplace(OrderArchiveFilePath,'YYYY', year, [rfReplaceAll, rfIgnoreCase])
    else Result:=StringReplace(OrderCurrentFilePath,'YYYY', year, [rfReplaceAll, rfIgnoreCase]);
end;

function TModule.GetReportFileXls(FileName: string): string;
begin
  Result:= Module.GetPath_ReportsBase + '\'  + FileName + '.xls';
  if not SysUtils.FileExists(Result) then begin
    MyWarningMessage('Файл отчета "' + FileName + '.xls" не найден!');
    Result:='';
  end;
end;

function TModule.GetReportFileXlsx(FileName: string): string;
begin
  Result:= Module.GetPath_ReportsBase + '\'  + FileName + '.xlsx';
  if not SysUtils.FileExists(Result) then begin
    MyWarningMessage('Файл отчета "' + FileName + '.xlsm" не найден!');
    Result:='';
  end;
end;

function TModule.GetReportFileXlsm(FileName: string): string;
begin
  Result:= Module.GetPath_ReportsBase + '\'  + FileName + '.xlsm';
  if not SysUtils.FileExists(Result) then begin
    MyWarningMessage('Файл отчета "' + FileName + '.xlsx" не найден!');
    Result:='';
  end;
end;

procedure TModule.MaILSendwithThunderBird(SendTo: string; Subject: string; Body: string = ''; Attachments: string = '');
//отправка сообщения с помощью Thunderbird, передает данные в программу и открывает редактор письма
//thunderbird -compose "to='john@example.com,kathy@example.com',cc='britney@example.com',subject='dinner',body='How about dinner tonight?',attachment='C:\temp\info.doc,C:\temp\food.doc'"
var
  Params, st, Messagefile: string;
begin
  if SendTo<>'' then SendTo:= 'to=''' + SendTo + '''';
  if Subject<>'' then Subject:= 'subject=''' + Subject + '''';
  if Pos(#133, Body) = 0 then begin
    if Body<>'' then Body:= 'body=''' + Body + '''';
    Messagefile:='';
  end;
  if Attachments<>'' then Attachments:= 'attachments=''' + Attachments + '''';
  Params:='-compose "' + A.ImplodeNotEmpty([SendTo, Subject, Body, MessageFile, Attachments], ',') + '"';
  ShellExecute(Application.Handle, nil, pWideChar('thunderbird.exe'), pWideChar(Params), nil, SW_SHOWNORMAL);
end;

//отправка письма
//передается тема, тело письма в виде строки, и айди пользователей кому надо отправить
//последнии или однно число, или массив айди, или строка айди через запятую
procedure TModule.MailSendToUsers(Subject: string; Body: string; Users: Variant);
var
  msg:TIdMessage;
  UsersAll: TVarDynArray;
  i, j: Integer;
  v, v1: Variant;
  EMailAddresses: string;
begin
  UsersAll := A.VarIntToArray(Users);
  if Length(UsersAll) = 0 then Exit;
  EMailAddresses:='';
  for i:= 0 to High(UsersAll) do begin
    if StrToIntDef(VarToStr(UsersAll[i]), -1) = -1 then Continue;
    v:=Q.QSelectOneRow('select emailaddr from v_users where id = :id$i', [S.VarToInt(UsersAll[i])]);
    if S.NSt(v[0]) <> ''
      then EMailAddresses:=S.ConcatSt(EMailAddresses, v[0], ',');
  end;
  if EMailAddresses = '' then Exit;
  v:=Q.QSelectOneRow('select emaildomain, emailuser, emailserver, emaillogin, emailpassword from adm_main_settings', []);
  try
    MyData.IdSMTP1.Host:=S.NSt(v[2]);
    MyData.IdSMTP1.Port:=25; //587;
    MyData.IdSMTP1.Username:=S.NSt(v[3]);
    MyData.IdSMTP1.Password:=S.NSt(v[4]);
    MyData.IdSMTP1.AuthType:=satDefault;
    //это необходимо использовать для SSL
    {
    IdSSLIOHandlerSocketOpenSSL1:= TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    IdSSLIOHandlerSocketOpenSSL1.Destination := IdSMTP1.Host+':'+IntToStr(IdSMTP1.Port);
    IdSSLIOHandlerSocketOpenSSL1.Host := IdSMTP1.Host;
    IdSSLIOHandlerSocketOpenSSL1.Port := IdSMTP1.Port;
    IdSSLIOHandlerSocketOpenSSL1.DefaultPort := 0;
    IdSSLIOHandlerSocketOpenSSL1.SSLOptions.Method := sslvTLSv1;
    IdSSLIOHandlerSocketOpenSSL1.SSLOptions.Mode := sslmUnassigned;
    IdSMTP1.IOHandler := IdSSLIOHandlerSocketOpenSSL1;
    IdSMTP1.UseTLS := utUseExplicitTLS;
    }
    {
    для ссл скачать балиотеки
    https://indy.fulgan.com/SSL/
    подошла openssl-1.0.2q-i386-win32.zip
    положить в папку с программой
    не работает ни с ссл и без вне локльной сети, не нравится локальный хост (не фулл-квалифи хостнейм)
    }
    //подключаемся и отправляем
    MyData.IdSMTP1.Connect;
    if MyData.IdSMTP1.Connected then begin
      msg:=TIdMessage.Create(nil);
      msg.CharSet:='UTF-8';
      msg.Body.Text:=UTF8Encode(Body);
      msg.Subject:=Subject;
      msg.From.Address:=S.NSt(v[1]) + '@' + S.NSt(v[0]);
      msg.From.Name:='Учет';
      msg.Recipients.EMailAddresses:=EMailAddresses;
      msg.IsEncoded:=True;
      MyData.IdSMTP1.Send(msg);
      msg.Free;
      MyData.IdSMTP1.Disconnect;
    end;
  except
    msg.Free;
    MyData.IdSMTP1.Disconnect;
  end;
end;

//Устанавливает таймер закрытия приложения
//сработает через IntervalMin минут, дробная часть - 0.1 = 10 секунд
//если IntervalMin=0 то отменит срабатывание, если = -1 то закроет приложение сразу
procedure TModule.CloseAppTimer(IntervalMin: extended);
begin
  if IntervalMin = -1
    then FrmMain.Close
    else if IntervalMin = -0 then begin
      FrmMain.TimerSrvClose.Interval:=3000;//MaxInt;
      FrmMain.TimerSrvClose.Enabled:=False;
    end
    else begin
      FrmMain.TimerSrvClose.Interval:=Trunc(IntervalMin) * 60 * 1000 + Round(Frac(IntervalMin)*10000);
      FrmMain.TimerSrvClose.Enabled:=True;
    end;
end;

procedure TModule.MenuSpeedButton1Click(Sender: TObject);
//события для панелей кнопок, вызывается при клике кнопки с выпадающим списком
//здесь, так как кнопки создаются динамически на разных формах, а обработчик-то нужен
var
  button: TControl;
  lowerLeft: TPoint;
  pm: TPopupMenu;
begin
  if Sender is TControl then
  begin
    button := TControl(Sender);
    lowerLeft := Point(0, button.Height);
    lowerLeft := button.ClientToScreen(lowerLeft);
    pm:=TPopupMenu(button.owner.FindComponent('M' + button.Name));
//    pm:=TPopupMenu(button.Parent.FindChildControl('M' + button.Name));
    pm.Popup(lowerLeft.X, lowerLeft.Y);
  end;
end;

//получсает из полного текста инфы текст хинта для тру или окна инфы для фолс
//если текст разделен ___ то что до этого разделителя выводится в подсказке, а что после - в окне
//если тект разделен ... то в хинте выводится с начала текста, включая ..., в окне выводится полностью, многоточие вырезается
//если без разделителей то выводится все и в хинте и в окне
function TModule.InfoGetHintText(Sender: TObject; Mode: Boolean = True): string;
var
  i: Integer;
  st: string;
begin
  Result:=FInfoCurrentHint;
  i:=pos('...', FInfoCurrentHint);
  if i>0 then begin
    if Mode
      then Result:=copy(FInfoCurrentHint,0,i+2)
      else Result:=copy(FInfoCurrentHint,0,i-1) + copy(FInfoCurrentHint,i+3, 100000);
  end
  else begin
    i:=pos('___', FInfoCurrentHint);
    if i>0 then begin
      if Mode
        then Result:=copy(FInfoCurrentHint,0,i-1)
        else Result:=copy(FInfoCurrentHint,i+3, 100000);
    end;
  end;
  if Mode and (i > 0) then Result:=Result + #10#13 + '(нажмите!)';
end;

//клик по картинке-подсказке
procedure TModule.InfoOnClick(Sender: TObject);
begin
  if InfoGetHintText(Sender, False) <> '' then
    MyInfoMessage(InfoGetHintText(Sender, False), 1);
end;

//попадание мышки
procedure TModule.InfoOnMouseEnter(Sender: TObject);
begin
  FInfoCurrentHint:=TImage(Sender).Hint;
  TImage(Sender).Hint:=InfoGetHintText(Sender, True);
  TImage(Sender).ShowHint:=True;
end;

//уход мышки
procedure TModule.InfoOnMouseLeave(Sender: TObject);
begin
  TImage(Sender).ShowHint:=False;
  TImage(Sender).Hint:=FInfoCurrentHint;
end;

//------------------------------------------------------------------------------
//работа с ресурсами

function TModule.GetResourceAsJpeg(const resname: string): TjpegImage;
//загружает из ресурса Jpeg-картинку
var
  Stream: TResourceStream;
begin
  Stream := TResourceStream.Create(hInstance, ResName, 'JPEG');
  try
    Result := TJPEGImage.Create;
    Result.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TModule.SetBitmapFromResource(Bm: TBitmap; Name: pchar);
//загружает картинку (TBitmap) из ресурса, тип ресурса определяется автоматом
//(может быть разный - bmp, jpg, png)
var
  Bmp: TBitmap;
  Jpg: TJPEGImage;
  Png: TPNGObject;
  Ico: TIcon;
  HResInfo: Integer;
begin
{  HResInfo := FindResource(HInstance, Name, 'ICON');
  if HResInfo <> 0 then begin
    Ico:=TIcon.Create;
    Ico.Handle := LoadIcon(hInstance, Name);
    Bm.Assign(Ico);
    Ico.Free;
    Exit;
 end;}
  HResInfo := FindResource(HInstance, Name, RT_BITMAP);
  if HResInfo <> 0 then begin
    Bmp := TBitmap.Create;
    Bmp.LoadFromResourceName(HInstance, Name);
    Bm.Assign(Bmp);
    Bmp.Free;
    Exit;
  end;
  HResInfo := FindResource(HInstance, Name, 'JPEG');
  if HResInfo <> 0 then begin
    Jpg := GetResourceAsJpeg(Name);
    Bm.Assign(Jpg);
    Jpg.Free;
    Exit;
  end;
  HResInfo := FindResource(HInstance, Name, RT_RCDATA);
  if HResInfo <> 0 then begin
    png := TPNGObject.Create;
    png.LoadFromResourceName(HInstance, Name);
    Bm.Assign(png);
    png.Free;
    Exit;
  end;
end;

function TModule.RunSaveDialog(FileName, Extention: string): string;
//вызов диалога сохранения файла
var
  Path: string;
begin
  Result := '';
  GetDir(0, Path);
  MyData.SaveDialog1.FileName := FileName;
  MyData.SaveDialog1.DefaultExt := Extention;
  if MyData.SaveDialog1.Execute then begin
    Result := MyData.SaveDialog1.FileName;
  end
  else
    exit;
  if ExtractFileExt(Result) <> '.' + Extention then
    Result := Result + '.' + Extention;
  if FileExists(Result) and (MyQuestionMessage('Файл уже существует! Перезаписать его?') <> mrYes) then begin
    Result := '';
    Exit;
  end;
end;


procedure TModule.StartLeakChecking;
begin
  MadExcept.StopLeakChecking;
  MadExcept.ClearLeaks;
  MadExcept.StartLeakChecking;
  beep;
end;

procedure TModule.SaveLeakReport;
var
  i, j, size, leaks: Integer;
  st, st1: string;
  va: TVarDynArray;
begin
  //MadExcept.StopLeakChecking;
 // MadExcept.ReportLeaksNow;
  st := MadExcept.GetLeakReport;
  leaks := 0;
  size := 0;
  va := A.Explode(st, #13#10);
  for i := 0 to High(va) do begin
    if pos('size: ', va[i]) = 1 then begin
      inc(leaks);
      size := size + StrtoIntDef(Copy(va[i], 7, 255), 0);
    end;
  end;
  st1 :=
    'Активная форма: ' + S.IIf(Screen.ActiveForm = nil, 'нет', Screen.ActiveForm.Name + ' (' + Screen.ActiveForm.Caption + ')') + #13#10 +
    'Активный контрол: ' + S.IIf(Screen.ActiveControl = nil, 'нет', Screen.ActiveControl.Name) + #13#10 +
    MemGetHeapStatus + #13#10 + MemGetStackStatus + #13#10 +
    'Memory Leaks: ' + IntToStr(leaks) + #13#10 + 'Memory Leak Size: ' + InttoStr(size);
  try
  if DirectoryExists('r:\') then
    Sys.SaveTextToFile('r:\!LeakReport.txt', st1 + #13#10#13#10 +  st);
  finally
  end;
  MadExcept.StopLeakChecking;
  MadExcept.ClearLeaks;
  MyInfoMessage(st1);
end;

function TModule.MemGetHeapStatus: string;
var
  HeapStatus: THeapStatus;
begin
  HeapStatus := GetHeapStatus;
  Result := Format(
    '[Куча]  Выделено = %d Кб, Свободно = %d Кб, Макс. блок = %d Кб',
    [round(HeapStatus.TotalAllocated / 1024), round(HeapStatus.TotalFree / 1024), round(HeapStatus.FreeBig / 1024)]
  );
end;


(*
procedure ShowFastMMMemoryStats;
// {$IFDEF DEBUG} uses FastMM4 {$ENDIF}
var
  MemStats: TMemoryManagerUsageSummary;
begin
  GetMemoryManagerUsageSummary(MemStats);
  Writeln(Format(
    '[Куча (FastMM)] Выделено = %d байт, Накладные расходы = %d байт',
    [MemStats.AllocatedBytes, MemStats.OverheadBytes]
  ));
end;
*)


function TModule.MemGetFreeStackSpace: NativeUInt;
//Свободное место в стеке (32-бит)	Не работает в 64-бит
var
  StackBase, StackTop, CurrentStackPtr: Pointer;
begin
{  asm
    mov StackBase, fs:[4]
    mov StackTop, fs:[8]
    mov CurrentStackPtr, esp
  end;
  Result := NativeUInt(CurrentStackPtr) - NativeUInt(StackTop);}
end;

function TModule.MemGetStackStatus: string;
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
  // Стек растет вниз, потому: Свободно = ESP - StackLimit
  Result := Format(
  '[Стек]  Всего = %d байт, Свободно = %d байт',
    [NativeUInt(StackBase) - NativeUInt(StackTop), NativeUInt(CurrentESP) - NativeUInt(StackTop)]
  );
//  Result := Sys.GetThreadStackInfo(GetCurrentThread);
end;



end.
