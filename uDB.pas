{
Базовый класс работы с БД
от него наследуются классы для работы с конкретными типами баз данных

AdoConnection - соединение с бд
AdoConnectionProviderEh - для запросов из компонентов EhLib
(если для него выставить Connection = AdoConnection, то использует это подключение и будет одна сессия на программу,
если не выставлять использует InlineConnection и сессийй будет две. В остальном работа одинакова. Нужен для отлова/модификации
запросов из компонентов EhLib, холтя запросы из них умеют работать напрямую через AdoConnection, но последний не позволяет
их отлавливать. Режим работы - подключать ли инлайнконнекшн - определяется по установленноу/снятому в дизайнтайме AdoConnectionProviderEh.onnection
)

для TAdoDataDriverEh на формах выставляем свойство AdoConnectionProvider:= myDBOra.AdoConnectionProviderEh, AdoConnection оставляем пустым

вложенные запросы (для записи логов самих запросов, или ошибок) пишем вручную,
вложенные запросы (во время ошибок в процедурах-обертках запросов) - портят аналитику (логи)
для них можно использовать AdoQueryService
}

unit uDB;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  MemTableDataEh, DataDriverEh, Math, Types, Dialogs, StdCtrls, DBCtrlsEh, DB,
  AdoDB, uString, Variants, MemTableEh, IniFiles, ADODataDriverEh, DBGridEh,
  uFrmXDmsgNoConnection, uErrors, uData, uNamedArr,
  //МИГРАЦИЯ НА FIREDAC (см. !алгоритмы.txt, раздел 6): базовый TmyDB теперь параллельно (не взамен ADO)
  //поддерживает исполнение запросов через FireDAC - выбор на уровне объекта, см. TmyDB.Backend.
  FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Phys, FireDAC.Phys.Oracle, FireDAC.Phys.OracleDef, FireDAC.VCLUI.Wait,
  //TFDParam/TFDParams (TFDStoredProc.Params.CreateParam возвращает именно TFDParam, не базовый TParam -
  //см. QCallStoredProc, переменная fp) объявлены здесь; юнит нужно указать явно в uses этого модуля,
  //т.к. видимость идентификаторов не наследуется транзитивно через FireDAC.Comp.Client.
  FireDAC.Stan.Param;

type
  //см. !алгоритмы.txt, раздел "Компьютеры домена": mydbtFirebird добавлен для БД резидентного агента
  //(fresh.fdb на 10.1.1.4), собирающего данные о компьютерах пользователей - см. uDBFirebird.pas
  TmydbType = (mydbtOra, mydbtMsSql, mydbtSqLite, mydbtFirebird);
  //бэкенд, через который TmyDB реально исполняет запросы (см. TmyDB.Backend) - ОБА бэкенда доступны
  //параллельно на одном объекте, ADO при этом не отключается и не заменяется (см. раздел 6 !алгоритмы.txt)
  TmyDbBackend = (mydbbAdo, mydbbFireDac);

const
  cmydbLogId = 0;
  cmydbLogTime = 1;
  cmydbLogSource = 2;
  cmydbLogQuery = 3;
  cmydbLogParams = 4;
  cmydbLogError = 5;

type
  TmyDB = class(TDataModule)
    AdoStoredProc: TADOStoredProc;
    ADODataDriverEh: TADODataDriverEh;
    DataSource1: TDataSource;
    MemTableEh1: TMemTableEh;
    AdoQuery: TADOQuery;
    AdoConnectionProviderEh: TADOConnectionProviderEh;
    AdoConnection: TADOConnection;
    ADOQueryService: TADOQuery;
    procedure AdoConnectionWillExecute(Connection: TADOConnection; var CommandText: WideString; var CursorType: TCursorType; var LockType: TADOLockType; var CommandType: TCommandType; var ExecuteOptions: TExecuteOptions; var EventStatus: TEventStatus; const Command: _Command; const Recordset: _Recordset);
    function AdoConnectionProviderEhExecuteCommand(SQLDataDriver: TCustomSQLDataDriverEh; Command: TCustomSQLCommandEh; var Cursor: TDataSet; var FreeOnEof, Processed: Boolean): Integer;
    procedure AdoQueryBeforeOpen(DataSet: TDataSet);
  private
    { Private declarations }
    //вернем статус соединения
    //функция проверяем и сессию Adoconnection и сессию AdoconnectionEh
    function GetConnectState: Boolean;
    //МИГРАЦИЯ НА FIREDAC: единое на объект (лениво создаваемое) FireDAC-подключение/запрос/сторед-прок -
    //см. пояснение у FFdConnection. Перенесено сюда (в базовый класс) из TmyDBOra - было специфично только
    //для Oracle, теперь DriverName выбирается по FDbType, работает для любого потомка TmyDB.
    function GetFdConnection: TFDConnection;
    function GetFdQuery: TFDQuery;
    function GetFdStoredProc: TFDStoredProc;
    //МИГРАЦИЯ НА FIREDAC (см. !алгоритмы.txt, раздел 6.11): имя секции этой БД в новом общем
    //конфиг-файле подключений uchet.cfg/uchet_test.cfg - см. реализацию и ReadConnectionFile.
    function GetAppConfigSectionName: string;
  protected
    FDbType: TMyDbType;
    //МИГРАЦИЯ НА FIREDAC: выбор бэкенда исполнения запросов для этого объекта Q - см. свойство Backend.
    //По умолчанию mydbbAdo - без явной установки в mydbbFireDac поведение объекта не меняется НИКАК.
    FBackend: TmyDbBackend;
    //единое на всё приложение (для этого объекта Q) FireDAC-подключение - см. property FdConnection.
    //Создаётся лениво в GetFdConnection по образцу наработок UchetFD (R:\Projects\UchetFD\uQF.pas),
    //парсится из уже имеющейся ADO-строки ConnectionString (см. ExtractAdoConnParam в implementation) -
    //отдельного пароля/файла настроек под FireDAC не заводим.
    FFdConnection: TFDConnection;
    //рабочий TFDQuery для примитивов QOpen/QExecSql/QSetParams и т.д. в режиме Backend = mydbbFireDac -
    //аналог AdoQuery, но для FireDAC; создаётся лениво (GetFdQuery), Connection выставляется на FdConnection
    FFdQuery: TFDQuery;
    //рабочий TFDStoredProc для QCallStoredProc в режиме Backend = mydbbFireDac - аналог AdoStoredProc
    FFdStoredProc: TFDStoredProc;
    //МИГРАЦИЯ НА FIREDAC (см. !алгоритмы.txt, раздел 6.11): если для этой БД в uchet.cfg/uchet_test.cfg
    //задана секция [Секция.FireDAC] - сюда (в ReadConnectionFile) копируются её "Имя=Значение" пары
    //(TIniFile.ReadSectionValues уже возвращает их в формате, ожидаемом TFDConnection.Params) - явные и
    //ПОЛНОСТЬЮ ОТДЕЛЬНЫЕ от ADO параметры FireDAC-подключения (см. GetFdConnection). Nil/пусто, если
    //секции нет - тогда GetFdConnection по-прежнему выводит параметры из ConnectionString (ADO), как
    //было изначально (см. раздел 6).
    FFdConfigParams: TStrings;
    FConnectionFile: string;
    FConnectionFileFull: string;
    FConnectionString: string;
    FCurrentShema: string;
    FTestDB: Boolean;
    FConnected: Boolean;
    FErrorState: string;
    FIsLogEnabled: Boolean;
    FSQLLog: TVarDynArray2;
    FLastSequenceId: Variant;
    FSuccess: Boolean;
    FSuccessAll: Boolean;
    FRowsAffected: Integer;
    FPackageMode: Integer;
    FCommitSuccess: Boolean;
    FLastReceivedFiedNames: TVarDynArray;
    //строковое представление строки запроса, параметров при попытке их установки, и ошибка
    //при их установке, для лога, генерируется в QSetParams
    FLastSql: string;
    FLastParamsStr: string;
    FLastParamsErr: string;
    _FLastSql: string;
    _FLastParamsStr: string;
    _FLastParamsErr: string;
    //массив лога
    FLogArray: TVarDynArray2;
    //возвращает "текущий" датасет (AdoQuery либо FdQuery) в зависимости от Backend - используется теми
    //методами верхнего уровня (QLoadToRec/QLoadToMemTableEh/QLoadToDBComboBoxEh/QLoadToTStringList),
    //которые после QOpen обходят результат только через базовые методы TDataSet (EOF/Fields/Next) -
    //поэтому им не требуется собственное дублирование под каждый бэкенд.
    function ActiveDataSet: TDataSet;
  public
    { Public declarations }

    //тип базы данных
    property DbType: TmyDbType read FDbType;
    //полное имя файла подключения *.UDL, который был загружен
    property ConnectionFileFull: string read FConnectionFileFull;
    //строка подключения
    property ConnectionString: string read FConnectionString;
    //текущая схема/юзер
    property CurrentShema: string read FCurrentShema;
    //установлено, если тестовая база
    property TestDB: Boolean read FTestDB;
    //установлено, если есть соединение
    property Connected: Boolean read GetConnectState;
    property ErrorState: string read FErrorState;
    //айди, возвращенный секвенцией
    property LastSequenceId: Variant read FLastSequenceId;
    property Success: Boolean read FSuccess;
    //property SuccessAll: Boolean;//ad FSuccessAll write SucessAllClear;
    property RowsAffected: Integer read FRowsAffected;
    //режим пакетного выполнения.
    //инициируется началом транзакции с режимом True (устанавливается в 1)
    //если хотя бы одна опарация после этого заавершается неуспешно, PackageMode выставляется в -1
    //и остальные опарции QExecSql не выполняются, транзакция автоматически откатывается, и снимает режим пакетного выполнения
    property PackageMode: Integer read FPackageMode;
    //статус фиксации последней транзакции
    property CommitSuccess: Boolean read FCommitSuccess;
    //разрешить запись запросов в лог
    property IsLogEnabled: Boolean read FIsLogEnabled;
    //лог всех операций с базой в текущей сессии работы программы
    property LastSql: string read FLastSql;
    property LastParamsStr: string read FLastParamsStr;
    property LastParamsErr: string read FLastParamsErr;
    //массив имен полей, который вернула последняяоперация типа select
    property LastReceivedFiedNames: TVarDynArray read FLastReceivedFiedNames;
    //массив лога sql-запросов для публичного доступа
    property LogArray: TVarDynArray2 read FLogArray;

    //МИГРАЦИЯ НА FIREDAC (см. !алгоритмы.txt, раздел 6): какой бэкенд реально исполняет запросы этого
    //объекта - QOpen/QClose/QExecSql/QSetParams/QRowsAffected/QGetReturnValues/QCallStoredProc/транзакции
    //(и всё, что построено поверх них - QLoad*/QSave/QLoadToMemTableEh и т.д.). По умолчанию mydbbAdo -
    //поведение объекта без явной установки в mydbbFireDac не меняется НИКАК, ADO при этом никогда не
    //отключается и не заменяется - это ПАРАЛЛЕЛЬНАЯ поддержка двух бэкендов на одном объекте, а не миграция
    //с потерей старого. QSetParamsEh и ToLogEh к этому флагу не относятся - они всегда только ADO/EhLib
    //(старый мост живого драйвера гридов), при Backend = mydbbFireDac не используются вообще.
    property Backend: TmyDbBackend read FBackend write FBackend;
    //единое FireDAC-подключение этого объекта (см. FFdConnection) - используется как примитивами Q при
    //Backend = mydbbFireDac, так и напрямую TFrDBGridEh (режим myogdmWithFdDriver, PrepareFdConnection) -
    //в обоих случаях нужна ОДНА сессия FireDAC на всё приложение, а не по одной на каждого потребителя
    property FdConnection: TFDConnection read GetFdConnection;
    //МИГРАЦИЯ НА FIREDAC (см. !алгоритмы.txt, раздел 6.7): применяет к переданному TFDQuery опытным
    //путём подобранные настройки FetchOptions/UpdateOptions (иначе FireDAC заметно медленнее ADO на
    //больших выборках) - публичный, т.к. используется не только внутри Q (GetFdQuery), но и напрямую
    //из TFrDBGridEh.PrepareFdConnection для собственных FFdQuery/FFdRefreshQuery грида.
    procedure TuneFdQuery(AQuery: TFDQuery);

    //конструктор
    //создаем объект базы данных
    //передается файл настроек соединения (только имя файла, без расширения, оно всегда ".udl"),
    //если AConnectAfterCreate то тут же пытаемся подключиться
    //конструктор пытается загрузить файл "AConnectionFile"_test, если удалось то считает что это тестовый режим
    constructor CreateObject(AOwner: TComponent; ADbType: TMyDbType; AConnectionFile: string; AConnectAfterCreate: Boolean = True; ABackend: TmyDbBackend = mydbbAdo); virtual;
    //МИГРАЦИЯ НА FIREDAC (см. !алгоритмы.txt, раздел 6.11): освобождает FFdConfigParams (см. поле) -
    //до этого у TmyDB не было собственного деструктора вообще.
    destructor Destroy; override;
    //получим ConnectionString для oracle и mssql (в которой крутится парсек)
    //вернем статус рабочей базы True (если найден файл тестовой версии, то читаем настройки из него и вернем False)
    function ReadConnectionFile: Boolean;
    //подключиться к БД
    function Connect(MessageIfError: Boolean = True): Boolean;

    {функции выполнения запросов и загрузки данных}
    //для выполнения запросов используются всегда только QOpen или QExecSql, остальное - функции-обертки

    //открываем запрос, установив параметры (если есть)
    //передается текст запроса, массив  параметров
    //возвращаем количество строк в запросе, или -1
    function QOpen(Sql: string; ParamValues: TVarDynArray): Integer;
    //закрываем запрос
    procedure QClose;
    //выполняем запрос на модификации данных
    //передается текст запроса, вариантный массив параметров
    //возвращает количество затронутых строк или -1 при ошибке
    function QExecSql(Sql: string; ParamValues: TVarDynArray; ShowErrors: Boolean = True): Integer;
    //выполнить произвольный запрос без передачи параметров
    function QExecSqlSimple(Sql: string; ShowErrors: Boolean = True): Integer;
    //возвращаем айди из переданной секвенции
    function QSelectId(sequence: string): LongInt;

    //загружаем результат запроса в вариантный двухмерный массив, содержащий чередующиеся имена параметров и их значения
    function QLoadToRec(Sql: string; ParamValues: TVarDynArray; OneRow: Boolean = False): TNamedArr;
    //выполняет загрузку данных из БД в TNamedArr
    //передается либо готовый запрос, либо строка для конструирования запроса (ее признаком является позиция ";" в строке до первой кавычки):
    //"имя_таблицы;{условие (where...|*|+);}имена_полей"
    //условие определяется на основе слова-признака, если его нет, следующие слова считаются полями
    //если условие не передано, таблица читается по айди (первое поле), если * то вся, начинается с where - испольуется как есть
    //использовать ";" в условии нельзя (поломает логику разбора, на наличие литералов проверки нет)
    //если установлено OneRow, читает только одну строку (при отсутствии данных вернет пустую запись)
    function QLoad(Sql: string; ParamValues: TVarDynArray; var Res: TNamedArr; OneRow: Boolean = False): Boolean; overload;
    function QLoad(Sql: string; ParamValues: TVarDynArray; var Res: TVarDynArray2): Boolean; overload;
    function QLoad(Sql: string; ParamValues: TVarDynArray; var Res: TVarDynArray): Boolean; overload;
    function QLoad(Sql: string; ParamValues: TVarDynArray; Res: TMemTableEh; ByFieldNames: Boolean = True; ClearTable: Boolean = True): Boolean; overload;
    function QLoad(Sql: string; ParamValues: TVarDynArray; Res: TDBGridEh; ByFieldNames: Boolean = True; ClearTable: Boolean = True): Boolean; overload;
    function QLoad(Sql: string; ParamValues: TVarDynArray): TVarDynArray2; overload;
    //возвращаем первую строку запроса
    //возвращается всегда вариантный массив по количеству полей, если запрос не вернуул ни одной строки то все элементы массива будут null
    function QLoadRow(Sql: string; ParamValues: TVarDynArray): Variant; overload;
    procedure QLoadRow(Sql: string; ParamValues: TVarDynArray; var Res: TNamedArr); overload;
    //возвращаем первую строку запроса; если записей нет, вернет пустой массив
    function QLoadRow0(Sql: string; ParamValues: TVarDynArray): TVarDynArray;
    //вернет всегда значение первого поля первой строки запроса; если запрос не вернул данных, то вернет null
    function QLoadValue(Sql: string; ParamValues: TVarDynArray): Variant;
    //загружаем результат запроса в вариантный двухмерный массив
//    function QLoad(Sql: string; ParamValues: TVarDynArray): TVarDynArray2;
    //загружаем одну строку в вариантный одномерный массив
    //если данные не выбраны, массив будет нулевой длины
//    function QLoadRow0(Sql: string; ParamValues: TVarDynArray): TVarDynArray;
    //загружаем одно поле (столбец) из полученных строк в вариантный одномерный массив
    function QLoadCol(Sql: string; ParamValues: TVarDynArray): TVarDynArray;
    //запись результатов запроса селект в мемтаблеех
    //передается запрос, параметры запроса,
    //строка наименований столбцов мемтейбл через ;, признак добавления данных в таблицу - добавляется в позицию (2), в конец (1) или очищается (0).
    //устанавливаются только поля из списка FieldNames (через ;), если он передан, если пустой то утанавливаются
    //поля мемтейбл по именам полей запроса, если FieldNames='-' то устанавливаются поля по порядку независимо от названий
    //вернет количество загруженных строк
    function QLoadToMemTableEh(Sql: string; ParamValues: TVarDynArray; MemTableEh: TMemTableEh; FieldNames: string = ''; Append: Byte = 0): Integer;
    //загружает список в комбобокс по переденному СКЛ
    //вырианты загрузки: с-список, С-список и пустая в начале,к-список и список ключей,К-список и список ключей и пустая вначале
    //если требуется ключевой список то селект должно возвращать в строе - значение,ключ
    //если Append=0 то списки перед загрузкой очищаются
    function QLoadToDBComboBoxEh(Sql: string; ParamValues: TVarDynArray; DBComboboxEh: TDBComboboxEh; ComboBoxMode: TMyControlType; Append: Byte = 0): Integer;
    //загружает данные из запроса в TStringList
    //если запрос возвращает одно поле то загружает только его, иначе загружает пару значений Key=Value, притом Value берется из левого (нулевого) поля
    function QLoadToTStringList(Sql: string; ParamValues: TVarDynArray; StringList: TStringList; Append: Byte = 0): Integer;
    //выполняет SQL-запрос на вставку/изменение/удаление данных
    //передается режим работы, имя таблицы, имя секвенции,
    //строка полей через ; (слева всегда должно быть поле айди, поля могут быть в виде имя_поля$тип),
    //значения параметров в массиве (левый всегда айди), показывать ли сообщение об ошибке
    //параметры можно для всех значений передавать одинаковые, в них поддерживаются модификаторы типа
    //в случае вставки может передаваться имя сиквенса, в этос случае делается селекст из него, и вставляется значение для первого параметра
    //или же, если последовательность не передана, то пытается выполнить с returning для первого параметра, указывать в виде id или id$i не id$ir
    //если передать сиквенс = '-' ии 'id', то айди не генерируется, а берется из первого поля
    //для вставки всегда подразумевается первый параметр (поле) числовым, и возвращается значение этого параметра
    //в случае ошибки возвращается -1, иначе для инзерт - значение айди, для остальных - количество обработанных строк
    function QSave(Mode: string; Table: string; Sequence: string; FieldsSt: string; Values: TVarDynArray; ShowError: Boolean = True): Integer;
    //выполнение хранимой процедуры Oracle
    //передается имя процедуры, параметры (или в строке через ;, или в VarArrayOf), значения всех параметров (или одно, или в VarArrayOf)
    //каждый параметра должне после ; содержать первой буквой тип параметра, второй - направлние данных (I - входящий, B - InOut, O - выходной)
    //вернет массив со значениями всех параметров (и входных и выходных), или пустой массив в случае ошибки
    function QCallStoredProc(ProcName: string; ParamNames: Variant; ParamValues: TVarDynArray): TVarDynArray;

    {функции установки параметров (bind-переменных) запроса}

    //получить имена параметров из полного sql-запроса
    function QGetParamNamesFromSql(Sql: string): string;
    //установим параметры запроса
    //передаются имена параметров, либо строка, может содержать один параметр, или несколько через ";", или же VarArrayOf
    //имена параметров указываются без двоеточия
    //также передается массив вариант значений параметров
    function QSetParams(ParamNames: Variant; ParamValues: TVarDynArray): Boolean;
    //устанавливает параметры в ADODataDriverEh1
    //типы определяются по модификаторам $s, $f, $i, $d
    //устанавливает для запроса драйвера в соотв с CommandType (по умолчанию s - selectsql)
    //если IgnoreRemainings=True (не по умолчанию), то переданные но не найденные в запросе параметры проигнорирует, иначе выдаст ошибку
    //устанавливает параметры в ADODataDriverEh1
    //типы определяются по модификаторам $s, $f, $i, $d
    //устанавливает для запроса драйвера в соотв с CommandType (по умолчанию s - selectsql)
    //если IgnoreRemainings=True (не по умолчанию), то переданные но не найденные в запросе параметры проигнорирует, иначе выдаст ошибку
    function QSetParamsEh(ADODataDriverEh1: TADODataDriverEh; ParamNames: Variant; ParamValues: TVarDynArray; CommandType: string = 's'; IgnoreRemainings: Boolean = False): Boolean;

    {работа с транзакциями}

    //открываем транзакцию
    //если установлено APackageMode, инициируем пакетный режим
    //(в котором запросы перестают выполняться после первого сбоя, и если он был транзакция откатится независимо от параметра)
    //если есть открытая трензакция, то откатим ее!
    function QBeginTrans(APackageMode: Boolean = False; ShowErrors: Boolean = True): Boolean;
    //фиксируем или откатываем транзакцию
    //если пакетный режим, то режим фиксации/отката определяется его результатом and Commit
    //также проставим свойтво статуса последней транзакции
    //если нет открытой транзакции, выйдем с False
    //иначе вернем в статусе, была ли транзакция зафиксирована.
    //также сбросим пакетный режим
    function QCommitOrRollback(Commit: Boolean = True; ShowErrors: Boolean = True): Boolean;
    //коммитим транзакцию
    function QCommitTrans: Boolean;
    //откатываем транзакцию
    function QRollbackTrans: Boolean;

    {вспомогательные функции}

    //парсит полное имя поля вида nameindb as fieldname$s400
    function ParseFieldNameFull(FieldNameFull: string; var FieldWithMod: string; var Alias: string; var DbFieldName: string; var FieldType: string; var DataType: TDataType; var DataLength: Integer): Boolean;
    //возвращает строковый модификатор по типу данных
    function QGetDataTypeAsChar(DataType: TDataType): Char;
    //возвращает строковый модификатор параметра из его строкового названия
    //если не задан возвращает ''
    function QGetParamTypeCharFromName(ParamName: string): string;
    //вернуть режим скл, использующийся в QSave, в зависимости от режима диалогового окна
    function QFModeToIUD(fMode: TDialogType): char;
    //вернуть количество затронутых запросом строк
    function QRowsAffected: Integer;
    //возвращает значения параметров последнего запроса в массиве
    //параметры могут быть перечислена в строке через ; или массивом
    //могут указываться полностью с модификаторами $ или без них
    function QGetReturnValues(ParamNames: Variant): Variant;
    //формирует из списка полей через ; и имени таблицы строку скл-запроса для селект/инзерт/апдейт/делит
    //айди передается всегда крайним левым значением в строке полей
    //поля могут быть переданы с модификатором, в этом случае в качестве имен в таблице используется левая часть имени до $, правая определяет тип
    function QGetSql(Mode: string; Table, FieldsSt: string): string;

    {функции логирования}

    //разрешить или запретить запись запросов в лог
    function SetEnableLog(Enable: Boolean = True): Boolean;
    //запись запроса и параметров в массив лога
    //также устанавливает последнюю команду, и при открытом журнале лога вызывает его обновление (добавление строки)
    procedure ToLog(Source, Query, Params, ErrMsg: string);
    //добавляет в лог данные из AdoDataDriverEh при выполнении команды
    procedure ToLogEh(Command: TCustomSQLCommandEh; ErrMsg: string = '');
  end;

var
  myDB: TmyDB;

//МИГРАЦИЯ НА FIREDAC (см. !алгоритмы.txt, раздел 6.10) - см. пояснение у реализации в implementation.
//Объявлена в interface, т.к. вызывается из Uchet.dpr ДО создания Q/myDBParsec, чтобы решить, какой
//бэкенд передать в CreateObject (см. TmyDB.CreateObject/Connect - бэкенд должен быть известен ДО
//попытки подключения, чтобы установить только одну сессию, а не обе сразу).
function ReadAppDbBackend(const ADbSectionName: string; ADefault: TmyDbBackend): TmyDbBackend;

implementation

uses
  uMessages, uForms, uFrmXGsrvSqlMonitor;


{%CLASSGROUP 'Vcl.Controls.TControl'}


{$R *.dfm}


constructor TmyDB.CreateObject(AOwner: TComponent; ADbType: TMyDbType; AConnectionFile: string; AConnectAfterCreate: Boolean = True; ABackend: TmyDbBackend = mydbbAdo);
//конструктор
//создаем объект базы данных
//передается файл настроек соединения (только имя файла, без расширения, оно всегда ".udl"),
//если AConnectAfterCreate то тут же пытаемся подключиться
//конструктор пытается загрузить файл "AConnectionFile"_test, если удалось то считает что это тестовый режим
//МИГРАЦИЯ НА FIREDAC (см. !алгоритмы.txt, раздел 6.10): ABackend теперь передаётся СРАЗУ в конструктор
//(а не выставляется отдельной строкой Q.Backend := ... ПОСЛЕ CreateObject, как было раньше) - именно
//потому, что Connect (см. ниже) должен ЗНАТЬ нужный бэкенд ДО того, как реально устанавливает
//соединение, чтобы установить ТОЛЬКО одну сессию (ADO либо FireDAC), а не обе сразу. По умолчанию
//mydbbAdo - для существующих вызовов без этого параметра (MSSQL/Парсек) поведение не меняется никак.
begin
  inherited Create(AOwner);
  FDbType := ADbType;
  FBackend := ABackend;
  FConnectionFile := AConnectionFile;
  ReadConnectionFile;
  FConnected := False;
  if FErrorState <> '' then
    Exit;
  if AConnectAfterCreate then
    Connect;
  FIsLogEnabled := True;
end;

destructor TmyDB.Destroy;
//МИГРАЦИЯ НА FIREDAC (см. !алгоритмы.txt, раздел 6.11): единственное, что требует явного освобождения
//из добавленных за миграцию полей - FFdConfigParams (обычный TStrings, не компонент-владелец).
begin
  FFdConfigParams.Free;
  inherited;
end;

function TmyDB.GetAppConfigSectionName: string;
//МИГРАЦИЯ НА FIREDAC (см. !алгоритмы.txt, раздел 6.11): имя секции этой БД в новом общем конфиг-файле
//подключений uchet.cfg/uchet_test.cfg - используется ReadConnectionFile для поиска секций
//[Секция]/[Секция.ADO]/[Секция.FireDAC] (по аналогии с уже существующей ReadAppDbBackend, которая читает
//из [Секция] ключ Backend). Специально НЕ привязано к FConnectionFile ('connect'/'parsec') - чтобы не
//требовать переименования уже существующих *.udl-файлов при переходе на новый формат.
//Пустой результат (неизвестный/новый FDbType, например будущий Firebird до того, как он тут прописан) -
//сигнал ReadConnectionFile пропустить новый конфиг и использовать старый *.udl-режим как раньше.
begin
  case FDbType of
    mydbtOra: Result := 'Oracle';
    mydbtMsSql: Result := 'MSSQL';
    //см. !алгоритмы.txt, раздел "Компьютеры домена": секция [Firebird]/[Firebird.FireDAC] в uchet.cfg
    mydbtFirebird: Result := 'Firebird';
  else
    Result := '';
  end;
end;

function TmyDB.ReadConnectionFile: Boolean;
//получим ConnectionString для oracle и mssql (в которой крутится парсек)
//вернем статус рабочей базы True (если найден файл тестовой версии, то читаем настройки из него и вернем False)
//МИГРАЦИЯ НА FIREDAC (см. !алгоритмы.txt, раздел 6.11): СНАЧАЛА проверяем новый общий конфиг-файл
//подключений uchet.cfg/uchet_test.cfg (секции [Секция]/[Секция.ADO]/[Секция.FireDAC], имя секции - см.
//GetAppConfigSectionName). Если для этой БД там задана строка подключения (ключ ConnectionString в
//[Секция.ADO]) и/или секция [Секция.FireDAC] - используем ИХ, полностью в обход *.udl. Если подходящей
//секции/файла нет - падаем в СТАРЫЙ режим (*.udl) БЕЗ ИЗМЕНЕНИЙ (код ниже не тронут) - это защищает любую
//БД (в первую очередь MSSQL/Парсек), для которой новая секция ещё не заведена.
var
  f: TIniFile;
  st: string;
const
  FileExt = '.udl';

  function TryReadAppConfig: Boolean;
  var
    cf: TIniFile;
    cfSt, SectionName: string;
    FdParams: TStrings;
  begin
    Result := False;
    SectionName := GetAppConfigSectionName;
    if SectionName = '' then
      Exit;
    cfSt := Module.ExePath + '\uchet_test.cfg';
    if not FileExists(cfSt) then
      cfSt := Module.ExePath + '\uchet.cfg';
    if not FileExists(cfSt) then
      Exit;
    cf := TIniFile.Create(cfSt);
    try
      if cf.SectionExists(SectionName + '.ADO') then
        FConnectionString := Trim(cf.ReadString(SectionName + '.ADO', 'ConnectionString', ''));
      if cf.SectionExists(SectionName + '.FireDAC') then begin
        FdParams := TStringList.Create;
        cf.ReadSectionValues(SectionName + '.FireDAC', FdParams);
        if FdParams.Count > 0 then
          FFdConfigParams := FdParams
        else
          FdParams.Free;
      end;
    finally
      cf.Free;
    end;
    if (FConnectionString = '') and (FFdConfigParams = nil) then
      Exit; //в новом файле нет ни одной секции для этой БД - используем старый *.udl-режим
    FTestDB := SameText(ExtractFileName(cfSt), 'uchet_test.cfg');
    FConnectionFileFull := cfSt;
    if FConnectionString <> '' then begin
      FCurrentShema := copy(ConnectionString, pos(';User ID=', ConnectionString) + 9, 1000);
      FCurrentShema := copy(CurrentShema, 1, pos(';', CurrentShema) - 1);
    end
    else if FFdConfigParams <> nil then
      FCurrentShema := FFdConfigParams.Values['User_Name'];
    Result := True;
  end;

begin
  Result := False;
  FConnectionString := '';
  FCurrentShema := '';
  FConnectionFileFull := '';
  FreeAndNil(FFdConfigParams);
  try
    if TryReadAppConfig then begin
      Result := True;
      Exit;
    end;
  except
    FErrorState := 'Не удалось прочитать конфиг-файл настроек соединения с базой данных (uchet.cfg).';
    Exit;
  end;
  try
    f := nil;
    st := Module.ExePath + '\' + FConnectionFile + '_test' + FileExt;
    if FileExists(st) then begin
      f := TIniFile.Create(st);
      FTestDB := True;
    end
    else begin
      st := Module.ExePath + '\' + FConnectionFile + '' + FileExt;
      if FileExists(st) then begin
        f := TIniFile.Create(st);
        FTestDB := False;
      end
    end;
    FConnectionString := 'Provider=' + f.ReadString('oledb', 'Provider', '');
    FCurrentShema := copy(ConnectionString, pos(';User ID=', ConnectionString) + 9, 1000);
    FCurrentShema := copy(CurrentShema, 1, pos(';', CurrentShema) - 1);
    FConnectionFileFull := st;
    Result := True;
    f.Free;
  except //on E: Exception do Application.ShowException(E);
    if not Result then
      FErrorState := 'Не удалось прочитать файл настроек соединения с базой данных.';
    f.Free;
  end;
{  if FileExists(ExtractFilePath(ParamStr(0)) + '\parsec.udl') then begin
    f:=TIniFile.Create(ExtractFilePath(ParamStr(0)) + '\parsec.udl');
    ParsecConnectionString:='Provider=' + f.ReadString('oledb', 'Provider', '');
    MyData.CnParsec.ConnectionString:= ParsecConnectionString;
    MyData.CnParsec.LoginPrompt:= False;
    MyData.CnParsecEh.InlineConnection.ConnectionString:= ParsecConnectionString;
    MyData.CnParsecEh.InlineConnection.LoginPrompt:= False;
    f.Free;
  end;}
end;

function ReadAppDbBackend(const ADbSectionName: string; ADefault: TmyDbBackend): TmyDbBackend;
//МИГРАЦИЯ НА FIREDAC (см. !алгоритмы.txt, раздел 6.10): читает выбор бэкенда (ADO/FireDAC) для указанной
//БД (секция ADbSectionName, например 'Oracle' или 'MSSQL') из общего конфиг-файла подключений всех БД -
//uchet.cfg, а если рядом лежит uchet_test.cfg - то ИЗ НЕГО (по аналогии с уже существующим соглашением
//"<файл>_test.udl" для тестового режима у каждой БД по отдельности, см. TmyDB.ReadConnectionFile).
//Если ни один файл не найден, либо в нём нет секции/ключа Backend, либо значение не распознано -
//возвращает ADefault: отсутствие файла НИКАК не меняет поведение приложения (обратная совместимость).
//Формат секции в файле:
//  [Oracle]
//  Backend=FireDAC
//Допустимые значения ключа Backend: "ADO" и "FireDAC" (без учета регистра).
var
  f: TIniFile;
  st, BackendSt: string;
begin
  Result := ADefault;
  st := Module.ExePath + '\uchet_test.cfg';
  if not FileExists(st) then
    st := Module.ExePath + '\uchet.cfg';
  if not FileExists(st) then
    Exit;
  f := TIniFile.Create(st);
  try
    BackendSt := Trim(f.ReadString(ADbSectionName, 'Backend', ''));
    if SameText(BackendSt, 'FireDAC') then
      Result := mydbbFireDac
    else if SameText(BackendSt, 'ADO') then
      Result := mydbbAdo;
    //пустое/нераспознанное значение - оставляем ADefault
  finally
    f.Free;
  end;
end;

function TmyDB.Connect(MessageIfError: Boolean = True): Boolean;
//подключаемся к базе данных
//если это подключение к Oracle, то в случае ошибки подключения, выводим окно и завершаем программу
//в других случаях не выводим никакого сообщения, выходим с Result := False
var
  i: Integer;
  ok: Boolean;
begin
  //см. !алгоритмы.txt, раздел "Компьютеры домена": Firebird ВСЕГДА подключается только через FireDAC -
  //у ADO нет надежного штатного OLEDB-провайдера для Firebird (в отличие от Oracle/MSSQL), поэтому,
  //в отличие от остальных типов БД, здесь нет и не предполагается ADO-режим вообще (ABackend всегда
  //mydbbFireDac - см. TmyDBFirebird.CreateObject, uDBFirebird.pas). Ветка ниже (для mydbtOra) и
  //ветка "else" (для mydbtMsSql/mydbtSqLite, всегда ADO) для Firebird не используются - отдельная
  //проверка ДО них, по той же схеме, что и Oracle+FireDAC чуть ниже (только статус уже
  //установленного соединения; здесь, в отличие от остальных веток, ошибка НЕ проглатывается молча -
  //ее текст запоминается в FErrorState, см. ниже, чтобы вызывающий код (см.
  //uFrmAGlstDomainComputers.PrepareForm) мог показать пользователю точную причину, а не просто
  //"не удалось подключиться")
  if FDbType = mydbtFirebird then begin
    ok := False;
    try
      ok := FdConnection.Connected;
    except
      //GetFdConnection в случае неудачи перевызывает исключение с уже человекочитаемым текстом,
      //включающим и исходную ошибку FireDAC/Firebird (сеть недоступна, неверный логин/пароль и т.п.)
      on E: Exception do
        FErrorState := E.Message;
    end;
    Result := ok;
    Exit;
  end;
  if FDbType = mydbtOra then begin
  //МИГРАЦИЯ НА FIREDAC (см. !алгоритмы.txt, раздел 6.10): при Backend = mydbbFireDac устанавливаем
  //ТОЛЬКО FireDAC-подключение, ADO вообще не трогаем - раньше при переключении Backend на FireDAC
  //ADO всё равно подключался здесь (см. ветку ниже), и в сессиях Oracle было видно ДВЕ сессии на одно
  //приложение (одна ADO, одна FireDAC) вместо одной. В этом режиме старые "онлайн"-гриды для Oracle
  //(myogdmWithAdoDriver, через ADODataDriverEh1/AdoConnectionProviderEh) работать не будут - это
  //ожидаемо для тестового режима "всё через один бэкенд", а не баг.
  if FBackend = mydbbFireDac then begin
    ok := False;
    try
      ok := FdConnection.Connected;
    except
    end;
    //ВРЕМЕННО ОТКЛЮЧЕНО по просьбе пользователя (см. !алгоритмы.txt, раздел 6.13): в момент этого вызова
    //(not AfterProgramStart - т.е. самое первое подключение Q при старте программы, см. Uchet.dpr) форма
    //FrmXDmsgNoConnection ЕЩЁ НЕ СОЗДАНА (Application.CreateForm(TFrmXDmsgNoConnection, ...) в Uchet.dpr
    //выполняется ПОЗЖЕ) - ShowModal здесь фактически вызывался бы на ещё не созданном объекте формы.
    //Ошибку подключения при старте программы и так корректно показывает TFrmXWNoConnectionAfterStart.Execute
    //(Uchet.dpr, вызывается сразу после создания Q и myDBParsec, уже после AfterProgramStart := True) - он
    //создаёт свою форму заново и сам проверяет Q.Connected. Нужно решить отдельно, вызывать ли что-то
    //(и что именно) отсюда, из Connect, для этого случая - пока просто не показываем ничего.
    {if (not ok) and (not AfterProgramStart) and MessageIfError then
      FrmXDmsgNoConnection.ShowModal;}
    Result := ok;
    Exit;
  end;
  i := 0;
  repeat
    try
    try
      ok := False;
      if not AdoConnection.Connected then begin
        AdoConnection.ConnectionString := ConnectionString;
        AdoConnection.LoginPrompt := False;
        try
          AdoConnection.Connected := True;
        except
        end;
      end;
      if AdoConnectionProviderEh.Connection = nil then begin
        if AdoConnection.Connected and not AdoConnectionProviderEh.InlineConnection.Connected then begin
          AdoConnectionProviderEh.InlineConnection.ConnectionString := ConnectionString;
          AdoConnectionProviderEh.InlineConnection.LoginPrompt := False;
          try
            AdoConnectionProviderEh.InlineConnection.Connected := True;
          except
          end;
        end;
      end;
      ok := True;
    except
    end;
    finally
    //ВРЕМЕННО ОТКЛЮЧЕНО - см. подробное объяснение у аналогичного места чуть выше (ветка FBackend =
    //mydbbFireDac), !алгоритмы.txt раздел 6.13: FrmXDmsgNoConnection ещё не создана в момент первого
    //подключения Q при старте программы (not AfterProgramStart) - ShowModal здесь был потенциальным
    //обращением к ещё не созданной форме.
    {if (not ok) and (not AfterProgramStart) then
      if MessageIfError
        then FrmXDmsgNoConnection.ShowModal;}
    end;
    inc(i);
  until (GetConnectState) or (i > 0);
  Result := ok;
  end
  else begin
    try
      Result := False;
      if not AdoConnection.Connected then begin
        AdoConnection.ConnectionString := ConnectionString;
        AdoConnection.LoginPrompt := False;
          AdoConnection.Connected := True;
      end;
      if AdoConnectionProviderEh.Connection = nil then begin
        if AdoConnection.Connected and not AdoConnectionProviderEh.InlineConnection.Connected then begin
          AdoConnectionProviderEh.InlineConnection.ConnectionString := ConnectionString;
          AdoConnectionProviderEh.InlineConnection.LoginPrompt := False;
            AdoConnectionProviderEh.InlineConnection.Connected := True;
        end;
      end;
      Result := True;
    except
    end;
  end;
end;

function TmyDB.GetConnectState: Boolean;
//возвращает статус соединения
//должны быть подключены AdoDriver (и AdoDriverEh в случае AdoDriverEh.Connection = null)
//МИГРАЦИЯ НА FIREDAC (см. !алгоритмы.txt, раздел 6.10): при Backend = mydbbFireDac ADO вообще не
//подключается (см. Connect) - поэтому статус соединения в этом режиме проверяем по FdConnection,
//а не по AdoConnection/AdoConnectionProviderEh
begin
  if FBackend = mydbbFireDac
    then Result := (FFdConnection <> nil) and FFdConnection.Connected
    else Result := AdoConnection.Connected and ((AdoConnectionProviderEh.Connection <> nil) or (AdoConnectionProviderEh.InlineConnection.Connected));
end;

{================== МИГРАЦИЯ НА FIREDAC (см. !алгоритмы.txt, раздел 6) =========}

function ExtractAdoConnParam(const AConnStr, AParamName: string): string;
//разбирает строку ADO-подключения вида "Provider=...;Data Source=X;User ID=Y;Password=Z;..." и возвращает
//значение параметра AParamName (без учета регистра, пустая строка если не найден).
//используется ТОЛЬКО для настройки параллельного FireDAC-подключения (TmyDB.GetFdConnection) по уже
//имеющейся ADO-строке ConnectionString, не запрашивая и не храня пароль отдельно нигде в коде.
//перенесена сюда из uDBOra.pas при переносе FireDAC-инфраструктуры в базовый класс.
var
  parts: TStringList;
  i, eqpos: Integer;
  pname, pvalue: string;
begin
  Result := '';
  parts := TStringList.Create;
  try
    parts.Delimiter := ';';
    parts.StrictDelimiter := True;
    parts.DelimitedText := AConnStr;
    for i := 0 to parts.Count - 1 do begin
      eqpos := Pos('=', parts[i]);
      if eqpos = 0 then Continue;
      pname := Trim(Copy(parts[i], 1, eqpos - 1));
      pvalue := Trim(Copy(parts[i], eqpos + 1, MaxInt));
      if SameText(pname, AParamName) then begin
        Result := pvalue;
        Exit;
      end;
    end;
  finally
    parts.Free;
  end;
end;

function TmyDB.GetFdConnection: TFDConnection;
//создаём ОДНО FireDAC-подключение лениво при первом обращении и переиспользуем его для всех дальнейших
//операций этого объекта (как через Backend = mydbbFireDac, так и напрямую из гридов, TFrDBGridEh) -
//нужна одна сессия FireDAC на всё приложение, как и с ADO (см. комментарий в начале файла)
//МИГРАЦИЯ НА FIREDAC (см. !алгоритмы.txt, раздел 6.11): если ReadConnectionFile нашёл для этой БД секцию
//[Секция.FireDAC] в uchet.cfg/uchet_test.cfg (FFdConfigParams <> nil) - используем ЕЁ параметры как есть
//(явно и полностью отдельно от ADO, включая DriverID/Database/User_Name/Password и любые другие, вплоть
//до таймингов). Иначе (старый режим, нет секции в конфиге) - параметры, как и раньше, выводятся из уже
//имеющейся ADO ConnectionString через ExtractAdoConnParam.
var
  vDatabase, vUser, vPassword: string;
begin
  if FFdConnection = nil then begin
    FFdConnection := TFDConnection.Create(Self);
    try
      if (FFdConfigParams <> nil) and (FFdConfigParams.Count > 0) then
        FFdConnection.Params.AddStrings(FFdConfigParams)
      else begin
        vDatabase := ExtractAdoConnParam(ConnectionString, 'Data Source');
        vUser := ExtractAdoConnParam(ConnectionString, 'User ID');
        vPassword := ExtractAdoConnParam(ConnectionString, 'Password');
        if vDatabase = '' then
          raise Exception.CreateFmt('TmyDB.GetFdConnection: не удалось извлечь "Data Source" из ConnectionString. ' +
            'User ID распознан как [%s]. Ожидаемый формат ConnectionString (ADO OLEDB): ' +
            '"...;Data Source=...;User ID=...;Password=...;", либо явно задайте параметры FireDAC в ' +
            'секции [%s.FireDAC] конфиг-файла uchet.cfg.', [vUser, GetAppConfigSectionName]);
        case FDbType of
          mydbtOra: FFdConnection.DriverName := 'Ora';
          mydbtMsSql: FFdConnection.DriverName := 'MSSQL';
        else
          raise Exception.Create('TmyDB.GetFdConnection: FireDAC-подключение для этого типа БД (DbType) пока не настроено');
        end;
        FFdConnection.Params.Values['Database'] := vDatabase;
        FFdConnection.Params.Values['User_name'] := vUser;
        FFdConnection.Params.Values['Password'] := vPassword;
      end;
      //МИГРАЦИЯ НА FIREDAC (см. !алгоритмы.txt, раздел 6.7): опытным путём подобранные в прототипе
      //UchetFD (uQF.pas, ReadConnectionFile) настройки FormatOptions - без них FireDAC заметно медленнее
      //ADO на "большой таблице" (сложное вью)
      FFdConnection.FormatOptions.StrsEmpty2Null := True;
      FFdConnection.FormatOptions.StrsTrim := False;
      try
        FFdConnection.Connected := True;
      except
        on E: Exception do
          raise Exception.CreateFmt('TmyDB.GetFdConnection: не удалось подключиться через FireDAC. Исходная ошибка: %s', [E.Message]);
      end;
    except
      FreeAndNil(FFdConnection);
      raise;
    end;
  end;
  Result := FFdConnection;
end;

function TmyDB.GetFdQuery: TFDQuery;
//рабочий TFDQuery для примитивов Q (QOpen/QExecSql/QSetParams...) при Backend = mydbbFireDac - аналог
//AdoQuery, создаётся лениво один раз на объект
begin
  if FFdQuery = nil then begin
    FFdQuery := TFDQuery.Create(Self);
    FFdQuery.Connection := FdConnection;
    TuneFdQuery(FFdQuery);
  end;
  Result := FFdQuery;
end;

procedure TmyDB.TuneFdQuery(AQuery: TFDQuery);
//МИГРАЦИЯ НА FIREDAC (см. !алгоритмы.txt, раздел 6.7): применяет к любому TFDQuery, использующему
//FdConnection, опытным путём подобранные (в более раннем прототипе UchetFD, uQF.pas) настройки -
//настройки FireDAC по умолчанию оказались заметно медленнее ADO на "большой таблице" (сложное вью,
//много строк): 9-10 сек на FireDAC против 5-6 на ADO. ВАЖНО: для Oracle БОЛЬШОЙ RowsetSize (пробовали
//2500) оказался МЕДЛЕННЕЕ умеренного (100) - поэтому не увеличивать не проверив опытным путём заново.
//Используется как из GetFdQuery (примитивы Q), так и напрямую из TFrDBGridEh.PrepareFdConnection
//(FFdQuery/FFdRefreshQuery грида "большой таблицы") - отсюда метод публичный, а не protected.
begin
  if AQuery = nil then
    Exit;
  AQuery.FetchOptions.Items := AQuery.FetchOptions.Items - [fiMeta, fiDetails];
  AQuery.FetchOptions.Mode := fmAll;
  AQuery.FetchOptions.RowsetSize := 100;
  AQuery.FetchOptions.CursorKind := ckDefault;
  AQuery.FetchOptions.LiveWindowParanoic := False;
  AQuery.UpdateOptions.RefreshMode := rmManual;
end;

function TmyDB.GetFdStoredProc: TFDStoredProc;
//рабочий TFDStoredProc для QCallStoredProc при Backend = mydbbFireDac - аналог AdoStoredProc, создаётся
//лениво один раз на объект
begin
  if FFdStoredProc = nil then begin
    FFdStoredProc := TFDStoredProc.Create(Self);
    FFdStoredProc.Connection := FdConnection;
  end;
  Result := FFdStoredProc;
end;

function TmyDB.ActiveDataSet: TDataSet;
//см. пояснение у объявления в interface-секции
begin
  if FBackend = mydbbFireDac
    then Result := GetFdQuery
    else Result := AdoQuery;
end;

{================== СОБЫТИЯ КОИПОНЕНТОВ =======================================}

function TmyDB.AdoConnectionProviderEhExecuteCommand(SQLDataDriver: TCustomSQLDataDriverEh; Command: TCustomSQLCommandEh; var Cursor: TDataSet; var FreeOnEof, Processed: Boolean): Integer;
var
  st, st0, ErrMsg, st1, st2: string;
  p: TParams;
  v: Variant;
  i, j: Integer;
begin
//MyInfoMessage('!!!');
  st := Command.CommandText.text;
  try
    FLastSql := st;
    FLastParamsStr := '';
    p := Command.GetParams;
    for i := 0 to p.count - 1 do begin
      S.ConcatStP(FLastParamsStr, '[' + p[i].Name + ']=' + S.iif(p[i].Value = null, '<Null>', VarToStr(p[i].Value)), sLineBreak);
    end;

    st0 := st;
  //исправляем ошибку в модуле EhLib, там вместо Nextval было Curval
    if DbType = mydbtOra then
      if Pos('.curval ', st) > 0 then
        Command.CommandText.text := StringReplace(st, '.curval ', '.nextval ', []);
  //исправляем ситуацию, когда при динамическом создании полей в мемтейбл на основе селекта
  //если айди числовой то в рефрешрекорд возникала ошибка
  //она возникала потому что получалась передача столбца в виде 12.0000
  //в данном случае заменяем параметр :ID с учетом регистра на его значение, округляя
  //при это не помогает ни выставление типа параметра непосредственно в вызывающем справочнике,
  //ни попытка изменить тип там же   MemTableEh1.FieldDefs[MemTableEh1.FieldDefs.IndexOf('id')].DataType:=ftInteger;
  //(MemTableEh1.FieldByName('id').DataType при этом ридонли)
  //MemTableEh1.FieldDefs.Add('id', ftInteger, 0, False);  MemTableEh1.Mth.CreateTableGrid; приводи к ошибке сразу же
  //и никакие манипуляции с параметрами здесь (попытка изменить тип, округлить значение, удалить и вставить новый параметр)

    if (pos(':ID', st) > 1) and (pos('where', st) > 1) and (pos(':ID', st) > pos('where', st)) then begin
      st := Command.FinalCommandText.text;
      p := Command.GetParams;
//    v:=p.ParamByName('ID').value;
      v := p.ParamByName('ID').value;
      Command.CommandText.text := StringReplace(st, ':ID', IntToStr(Round(v)), []);
      p.Delete(p.ParamByName('ID').Index);
//    p.Delete(p.ParamByName('ID').Index);
//Command.CommandText.text:= StringReplace(st, ':ID', ':id$i', []);
//    p:=command.GetParams;
//    command.GetParams.ParamByName('ID').DataType:=ftFloat;
//    command.GetParams.ParamByName('ID').value:=trunc(v);
{    v:=p.ParamByName('ID').value;
    Command.CommandText.text:= StringReplace(st, ':ID', IntToStr(Round(v)), []);
    p.Delete(p.ParamByName('ID').Index);}
  //  p.ParamByName('ID').value:=IntToStr(Round(v));
  //  p.ParamByName('ID').AsString:='''' + IntToStr(Round(v)) + '''';
    end;
{  p:=command.GetParams;
  for i:=0 to p.Count - 1 do begin
    if p[i].Name  =  'dt_beg' then p[i].DataType:=ftDate;
  end;}
  //AppendSQLInfoEh(Command);
  //IsOraTreat:=True;
    ErrMsg := '';
    Result := AdoConnectionProviderEh.DefaultExecuteCommand(SQLDataDriver, Command, Cursor, FreeOnEof, Processed);
  except
    on E: Exception do begin
      ToLogEh(Command, E.Message);
      //Errors.SetParam('' ,'', myerrTypeDB);
      Application.ShowException(E);
    end;
  end;
  ToLogEh(Command, ErrMsg);
  //IsOraTreat:=False;
  if Command.CommandText.text <> st0 then
    Command.CommandText.text := st0;
end;

procedure TmyDB.AdoConnectionWillExecute(Connection: TADOConnection; var CommandText: WideString; var CursorType: TCursorType; var LockType: TADOLockType; var CommandType: TCommandType; var ExecuteOptions: TExecuteOptions; var EventStatus: TEventStatus; const Command: _Command; const Recordset: _Recordset);
begin
  //
end;

procedure TmyDB.AdoQueryBeforeOpen(DataSet: TDataSet);
begin
//  FLastSQL:=AdoQuery.SQL.Text;
end;


{=========================== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ==========================}

function TmyDB.QGetDataTypeAsChar(DataType: TDataType): Char;    //++убрать
//возвращает строковый модификатор по типу данных
begin
  case DataType of
    ftString:
      Result := 's';
    ftInteger:
      Result := 'i';
    ftFloat:
      Result := 'f';
    ftBcd, ftFMTbcd:    //тип поля в Delphi для хранения чисел с фиксированной точностью
      Result := 'f';
    ftDate:
      Result := 'd';
    ftDateTime:
      Result := 'd';
  else
    Result := 's';
  end;
end;

function TmyDB.ParseFieldNameFull(FieldNameFull: string; var FieldWithMod: string; var Alias: string; var DbFieldName: string; var FieldType: string; var DataType: TDataType; var DataLength: Integer): Boolean;
//парсит полное имя поля вида "data as fieldname$s400"
//FieldNameFull = fieldname$s400, alias = ieldname, DbFieldName = data
var
  i: Integer;
  va1, va: TVarDynArray;
  st: string;
begin
  try
  Result:= False;
  va1:= A.Explode(FieldNameFull, ' as ');
  FieldWithMod := va1[High(va1)];
  if High(va1) > 1 then Exit;
  if High(va1) > 0 then DbFieldName:= va1[0];
  va:= A.Explode(FieldWithMod, '$');
  if High(va1) = 0 then DbFieldName:= va[0];
  Alias:= va[0];
  FieldType:= '';
  DataType:= ftUnknown;
  DataLength:= 0;
  if (Length(va) <> 2)
    then begin Result:= True; Exit; end;
  FieldType:=LowerCase(va[1])[1];
  if (FieldType = '') or not (FieldType[1] in ['s', 't', 'd', 'h', 'i', 'f', 'c']) then Exit;
  DataLength:= StrToIntDef(Copy(va[1], 2), -1);
  if DataLength = -1 then begin
    if FieldType[1] in ['s', 't'] then DataLength:=4000 else DataLength:=0;
  end;
  case FieldType[1] of
    's', 't':  DataType:= ftString;
    'i':  DataType:= ftInteger;
    'f':  DataType:= ftFloat;
    'd':  DataType:= ftDateTime;
  end;
  finally
  end;
  Result:= True;
end;

function TmyDB.QFModeToIUD(fMode: TDialogType): char;
//вернуть режим скл, использующийся в QSave, в зависимости от режима диалогового окна
begin
  Result := '-';
  case fMode of
    fAdd, fCopy:
      Result := 'i';
    fDelete:
      Result := 'd';
    fEdit:
      Result := 'u';
  end;
end;

function TmyDB.QGetParamTypeCharFromName(ParamName: string): string;
//возвращает строковый модификатор параметра из его строкового названия (приводит в нижнему регистру)
//вернем всю строку модификаторов (1й - тип 's','t','d','h','i','f','c',  2й - R = возвращаемый
//если не задан возвращает 's  '
var
  sa: TStringDynArray;
begin
  try
    Result := 's  ';
    sa := A.ExplodeS(ParamName, '$');
    if (Length(sa) < 2) or (Length(sa[1]) < 1) then
      Exit;
    Result := LowerCase(sa[1]);
    if (Result <> '') and not (Result[1] in ['s', 't', 'd', 'h', 'i', 'f', 'c']) then begin
      Errors.SetParam('', 'Неверный тип параметра ($) в запросе', myerrTypeDB);
      raise Exception.Create('Неверный тип параметра ($) в запросе');
    end;
  except
    on E: Exception do begin
      Errors.SetParam('', '', myerrTypeDB);
      Application.ShowException(E);
    end;
  end;
end;

(*
function TmyDB.QGetParamNamesFromSql(Sql: string): string;
//находит параметры в строке запроса (начинаются с :, состоят из английских букв и символа $),
//и возвращает строку из имен параметров через точку с запятой
var
  i, j: Integer;
  sa: TStringDynArray;
  st: string;
begin
  try
    sa := A.ExplodeS(Sql, ':');
    Result := '';
    for i := 1 to High(sa) do begin
      st := '';
      for j := 1 to Length(sa[i]) do
        if (sa[i][j] in EngChars_) or (sa[i][j] in ['0'..'9']) or (sa[i][j] = '$') then
          st := st + sa[i][j]
        else
          Break;
      S.ConcatStP(Result, st, ';');
    end;
  except
    on E: Exception do begin
      Errors.SetParam('', '', myerrTypeDB);
      Application.ShowException(E);
    end;
  end;
end;
*)

function TmyDB.QGetParamNamesFromSql(Sql: string): string;
//находит параметры в строке запроса (начинаются с :, состоят из английских букв и символа $),
//и возвращает строку из имен параметров через точку с запятой
var
  i, j: Integer;
  sa: TStringDynArray;
  ParamList: TParams;
  st: string;
begin
  try
    ParamList := TParams.Create(nil);
    ParamList.ParseSQL(SQL, True); //Force to create the params from the SQL
    for i := 0 to ParamList.Count - 1 do
      S.ConcatStP(Result, ParamList[i].Name, ';');
  finally
    ParamList.Free;
  end;
end;

function TmyDB.QGetSql(Mode: string; Table, FieldsSt: string): string;
//формирует из списка полей через ; и имени таблицы строку скл-запроса для селект/инзерт/апдейт/делит
//айди передается всегда крайним левым значением в строке полей
//поля могут быть переданы с модификатором, в этом случае в качестве имен в таблице используется левая часть имени до $, правая определяет тип
var
  Fields, FieldsWType: TVarDynArray;
  i, j: Integer;
  St, St1: string;
begin
  A.ExplodeP(FieldsSt, ';', Fields);
  FieldsWType := copy(Fields);
  for i := 0 to High(Fields) do begin
    if Pos('$', Fields[i]) > 0 then
      Fields[i] := Copy(Fields[i], 1, Pos('$', Fields[i]) - 1);
  end;
  Mode := UpCase(Mode[1]);
  case Mode[1] of
    'D':
      begin
        St := 'delete from ' + Table + ' where ' + Fields[0] + ' = :' + FieldsWType[0] + '';
      end;
    'S':
      begin
        St := '';
        for i := 0 to High(Fields) do begin
          S.ConcatStP(St, Fields[i], ', ');
        end;
        St := 'select ' + St + ' from ' + Table + ' where ' + Fields[0] + ' = :' + FieldsWType[0];
      end;
    'I':
      begin
        St := '';
        St1 := '';
        for i := 0 to High(Fields) do begin
          S.ConcatStP(St, Fields[i], ', ');
          S.ConcatStP(St1, ':' + FieldsWType[i], ', ');
        end;
        St := 'insert into ' + Table + '(' + St + ') values (' + St1 + ')';
      end;
    'U':
      begin
        St := '';
        for i := 1 to High(Fields) do begin
          S.ConcatStP(St, Fields[i] + '= :' + FieldsWType[i], ', ');
        end;
        St := 'update ' + Table + ' set ' + St + ' where ' + Fields[0] + ' = :' + FieldsWType[0];
      end;
    'Q':
      begin
        St := '';
        for i := 0 to High(Fields) do begin
          S.ConcatStP(St, Fields[i] + '= :' + FieldsWType[i], ', ');
        end;
        St := 'update ' + Table + ' set ' + St;
      end;
    'A':
      begin
        St := '';
        for i := 0 to High(Fields) do
          S.ConcatStP(St, Fields[i], ', ');
        St := 'select ' + St + ' from ' + Table;
      end;
    'N':
      begin
        St := '';
        for i := 0 to High(Fields) do
          S.ConcatStP(St, Fields[i], ', ');
        St := 'select ' + St + ' from ' + Table + ' where 0=1';
      end;
  end;
  Result := St;
end;

function TmyDB.QSetParams(ParamNames: Variant; ParamValues: TVarDynArray): Boolean;
//установим параметры запроса
//передаются имена параметров, либо строка, может содержать один параметр, или несколько через ";", или же VarArrayOf
//имена параметров указываются без двоеточия
//также передается массив вариант значений параметров
var
  i, j: Integer;
  st, st1, st2: string;
  v: Variant;
  ParamNamesA: TVarDynArray;
  CurrParamName, CurrParamValue, CurrParamType: string;
begin
//st :=  AdoQuery.SQL.Text;
  Result := True;
  //строку параметров для лога/окна показа ошибки БД обновляем только если лог включен -
  //иначе запрос, исключенный из лога (Q.SetEnableLog(False), например служебный запрос
  //в таймере главной формы), затер бы собой данные последнего "настоящего" запроса,
  //которые используются при показе окна ошибки БД
  if FIsLogEnabled then begin
    FLastParamsStr := '';
    FLastParamsErr := '';
  end;
  ParamNamesA := A.ExplodeV(ParamNames, ';');
  if (Length(ParamNamesA) = 0) or (ParamNamesA[0] = '') then
    Exit;
  for i := 0 to Max(High(ParamNamesA), High(ParamValues)) do begin
    if i <= High(ParamNamesA) then
      st1 := VarToStr(ParamNamesA[i])
    else
      st1 := '<Unknown>';
    if i <= High(ParamValues) then
      st2 := S.IIf(VarIsNull(ParamValues[i]), '<Null>', VarToStr(ParamValues[i]))
    else
      st2 := '<Unknown>';
    if FIsLogEnabled then
      S.ConcatStP(FLastParamsStr, '[' + st1 + ']=' + st2, sLineBreak);
  end;
  try
    Result := False;
    if (High(ParamNamesA)) = (High(ParamValues)) then begin
      for i := Low(ParamNamesA) to High(ParamNamesA) do
      try
        if ParamNamesA[i] <> '' then begin
          CurrParamName := ParamNamesA[i];
          CurrParamValue := VarToStr(ParamValues[i]);
          CurrParamType := QGetParamTypeCharFromName(ParamNamesA[i]);
          //МИГРАЦИЯ НА FIREDAC: FdQuery.Params - это стандартный Data.DB.TParams (TFDParams - его потомок),
          //в отличие от ADO, у которого свой собственный TParameters/TParameter (Direction/Attributes) -
          //поэтому здесь два разных API, а не общий код через ActiveDataSet
          if FBackend = mydbbFireDac then begin
            case CurrParamType[1] of
              's', 't':
                GetFdQuery.ParamByName(ParamNamesA[i]).DataType := ftString;
              'd':
                FFdQuery.ParamByName(ParamNamesA[i]).DataType := ftDate;
              'h':
                FFdQuery.ParamByName(ParamNamesA[i]).DataType := ftDateTime;
              'i':
                FFdQuery.ParamByName(ParamNamesA[i]).DataType := ftInteger;
              'f':
                FFdQuery.ParamByName(ParamNamesA[i]).DataType := ftFloat;
              'c':
                FFdQuery.ParamByName(ParamNamesA[i]).DataType := ftCurrency;
            end;
            if CurrParamType[2] = 'r' then
              FFdQuery.ParamByName(ParamNamesA[i]).ParamType := ptResult
            else
              FFdQuery.ParamByName(ParamNamesA[i]).ParamType := ptInput;
            //пустую строку всегда преобразуем в null!!!  2025-07-28
            FFdQuery.ParamByName(ParamNamesA[i]).Value := S.NullIfEmpty(ParamValues[i]);
          end
          else begin
            case CurrParamType[1] of
              's', 't':
                AdoQuery.Parameters.ParamByName(ParamNamesA[i]).DataType := ftString;
              'd':
                AdoQuery.Parameters.ParamByName(ParamNamesA[i]).DataType := ftDate;
              'h':
                AdoQuery.Parameters.ParamByName(ParamNamesA[i]).DataType := ftDateTime;
              'i':
                AdoQuery.Parameters.ParamByName(ParamNamesA[i]).DataType := ftInteger;
              'f':
                AdoQuery.Parameters.ParamByName(ParamNamesA[i]).DataType := ftFloat;
              'c':
                AdoQuery.Parameters.ParamByName(ParamNamesA[i]).DataType := ftCurrency;
            end;
            if CurrParamType[2] = 'r' then
              AdoQuery.Parameters.ParamByName(ParamNamesA[i]).Direction := pdReturnValue
            else
              AdoQuery.Parameters.ParamByName(ParamNamesA[i]).Direction := pdInput;
            AdoQuery.Parameters.ParamByName(ParamNamesA[i]).Attributes := [paNullable];
            //пустую строку всегда преобразуем в null!!!  2025-07-28
            AdoQuery.Parameters.ParamValues[ParamNamesA[i]] := S.NullIfEmpty(ParamValues[i]);
          end;
        end;
      except
        on E: Exception do begin
          if FIsLogEnabled then
            FLastParamsErr := 'Ошибка установки параметра запроса (' + CurrParamName + ' = "' + CurrParamValue + '")'#13#10'*';
          Errors.SetParam('', FLastParamsErr, myerrTypeDB);
          Application.ShowException(E);
          FLastParamsErr := '';
        end;
      end;
    end
    else begin
      FLastParamsErr := 'Ошибка установки параметров запроса (не совпадают количество переданных и запрошенных параметров)';
      Errors.SetParam('', FLastParamsErr, myerrTypeDB);
      raise Exception.Create(FLastParamsErr);
      FLastParamsErr := '';
    end;
    Result := True;
  except
    on E: Exception do begin
      Errors.SetParam('', '', myerrTypeDB);
      Application.ShowException(E);
      FLastParamsErr := E.Message;
    end;
  end;
end;

function TmyDB.QGetReturnValues(ParamNames: Variant): Variant;
//возвращает значения параметров последнего запроса в массиве
//параметры могут быть перечислена в строке через ; или массивом
//могут указываться полностью с модификаторами $ или без них
var
  i, j: Integer;
  v: Variant;
  ParamNamesA, ParamValuesA: TVarDynArray;
  b: Boolean;
begin
  Result := null;
  try
    ParamNamesA := A.ExplodeV(ParamNames, ';');
    if (Length(ParamNamesA) = 0) or (ParamNamesA[0] = '') then
      Exit;
    for i := 0 to High(ParamNamesA) do begin
      b := False;
      if FBackend = mydbbFireDac then begin
        for j := 0 to FFdQuery.Params.Count - 1 do
          if (ParamNamesA[i] = FFdQuery.Params[j].Name) or (Pos(ParamNamesA[i] + '$', FFdQuery.Params[j].Name) = 1) then begin
            ParamValuesA := ParamValuesA + [FFdQuery.Params[j].Value];
            b := True;
            Break;
          end;
      end
      else begin
        for j := 0 to AdoQuery.Parameters.Count - 1 do
          if (ParamNamesA[i] = AdoQuery.Parameters[j].Name) or (Pos(ParamNamesA[i] + '$', AdoQuery.Parameters[j].Name) = 1) then begin
            ParamValuesA := ParamValuesA + [AdoQuery.Parameters[j].Value];
            b := True;
            Break;
          end;
      end;
      if not b then
        Break;
    end;
    if not b then begin
      Errors.SetParam('', 'Не верны имена параметров, возвращаемых из запроса /не все найдены/ (' + A.Implode(ParamNamesA, ';') + ')', myerrTypeDB);
      raise Exception.Create('Не верны имена параметров, возвращаемых из запроса /не все найдены/ (' + A.Implode(ParamNamesA, ';') + ')');
    end;
    Result := ParamValuesA;
  except
    on E: Exception do begin
      Errors.SetParam('', '', myerrTypeDB);
      Application.ShowException(E);
    end;
  end;
end;

function TmyDB.QRowsAffected: Integer;
//вернуть количество затронутых запросом строк
begin
  if FBackend = mydbbFireDac
    then Result := GetFdQuery.RowsAffected
    else Result := AdoQuery.RowsAffected;
  FRowsAffected := Result;
end;


{================= ФУНКЦИИ ВЫПОЛНЕНИЯ ЗАПРОСОВ И ЗАГРУЗКИ ДАННЫХ ==============}

function TmyDB.QExecSql(Sql: string; ParamValues: TVarDynArray; ShowErrors: Boolean = True): Integer;
//выполняем запрос на модификации данных
//передается текст запроса, вариантный массив параметров
//возвращает количество затронутых строк или -1 при ошибке
var
  err: Boolean;
  ErrMsg: string;
begin
  if PackageMode = -1 then
    Exit;
  Result := -1;
  ErrMsg := '';
  //FLastSql (как и FLastParamsStr в QSetParams) обновляем только если лог включен - иначе запрос,
  //исключенный из лога, затер бы собой данные последнего "настоящего" запроса
  if FIsLogEnabled then
    FLastSql := Sql;
  try
    if FBackend = mydbbFireDac then begin
      GetFdQuery.Close;
      FFdQuery.SQL.Text := Sql;
      if not QSetParams(QGetParamNamesFromSql(Sql), ParamValues) then begin
        ToLog('Fd', Sql, FLastParamsStr, FLastParamsErr);
        Exit;
      end;
      FFdQuery.ExecSQL;
      Result := FFdQuery.RowsAffected;
    end
    else begin
      AdoQuery.Close;
      AdoQuery.SQL.Text := Sql;
      if not QSetParams(QGetParamNamesFromSql(Sql), ParamValues) then begin
        ToLog('Ado', Sql, FLastParamsStr, FLastParamsErr);
        Exit;
      end;
      Result := AdoQuery.ExecSQL;
    end;
  except
    on E: Exception do begin
      Errors.SetParam('', '*', myerrTypeDB, ShowErrors);
      ErrMsg := E.Message;
      Application.ShowException(E);
    end;
  end;
  ToLog(S.IIf(FBackend = mydbbFireDac, 'Fd', 'Ado'), Sql, FLastParamsStr, ErrMsg);
  if (PackageMode = 1) and (Result < 0) then
    FPackageMode := -1;
end;

function TmyDB.QOpen(Sql: string; ParamValues: TVarDynArray): Integer;
//открываем запрос, установив параметры (если есть)
//передается текст запроса, массив  параметров
//возвращаем количество строк в запросе, или -1
var
  i: Integer;
  b: Boolean;
begin
  Result := -1;
  try
    //FLastSql (как и FLastParamsStr в QSetParams) обновляем только если лог включен - иначе запрос,
    //исключенный из лога (например, служебный запрос в таймере главной формы), затер бы собой данные
    //последнего "настоящего" запроса, которые используются при показе окна ошибки БД
    if FIsLogEnabled then
      FLastSql := Sql;
    if FBackend = mydbbFireDac then begin
      GetFdQuery.Close;
      FFdQuery.SQL.Text := Sql;
      if not QSetParams(QGetParamNamesFromSql(Sql), ParamValues) then begin
        ToLog('Fd', Sql, FLastParamsStr, FLastParamsErr);
        Exit;
      end;
      FFdQuery.Open;
      Result := FFdQuery.RecordCount;
    end
    else begin
      AdoQuery.Close;
      AdoQuery.SQL.Text := Sql;
      if not QSetParams(QGetParamNamesFromSql(Sql), ParamValues) then begin
        ToLog('Ado', Sql, FLastParamsStr, FLastParamsErr);
        Exit;
      end;
      AdoQuery.Open;
      Result := AdoQuery.RecordCount;
    end;
  except
    on E: Exception do begin
      Errors.SetParam('', '*', myerrTypeDB);
      try ActiveDataSet.Close; except end;
      Application.ShowException(E);
    end;
  end;
  ToLog(S.IIf(FBackend = mydbbFireDac, 'Fd', 'Ado'), Sql, FLastParamsStr, FLastParamsErr);
end;

procedure TmyDB.QClose;
//закрываем запрос
begin
  try
    ActiveDataSet.Close;
  except
  end;
end;

function TmyDB.QExecSqlSimple(Sql: string; ShowErrors: Boolean = True): Integer;
//выполняет sql-команду без параметров; возвращает количество затронутых строк или -1 при ошибке
begin
  Result := QExecSql(Sql, [], ShowErrors);
end;

function TmyDB.QSave(Mode: string; Table: string; Sequence: string; FieldsSt: string; Values: TVarDynArray; ShowError: Boolean = True): Integer;
//выполняет SQL-запрос на вставку/изменение/удаление данных
//передается режим работы, имя таблицы, имя секвенции,
//строка полей через ; (слева всегда должно быть поле айди, поля могут быть в виде имя_поля$тип),
//значения параметров в массиве (левый всегда айди), показывать ли сообщение об ошибке
//параметры можно для всех значений передавать одинаковые, в них поддерживаются модификаторы типа
//в случае вставки может передаваться имя сиквенса, в этос случае делается селекст из него, и вставляется значение для первого параметра
//или же, если последовательность не передана, то пытается выполнить с returning для первого параметра, указывать в виде id или id$i не id$ir
//если передать сиквенс = '-' ии 'id', то айди не генерируется, а берется из первого поля
//для вставки всегда подразумевается первый параметр (поле) числовым, и возвращается значение этого параметра
//в случае ошибки возвращается -1, иначе для инзерт - значение айди, для остальных - количество обработанных строк
var
  Fields, ParamsDeb: TVarDynArray;
  Params: Variant;
  i, j: Integer;
  St, St1, sql: string;
  id: longint;
  AutoId: Boolean;
begin
  if PackageMode = -1 then
    Exit;
  A.ExplodeP(FieldsSt, ';', Fields);
  Mode := UpperCase(Mode);
  sql := QGetSql(Mode, Table, FieldsSt);
  if Mode = 'U' then begin
    Params := VarArrayCreate([0, High(Fields)], varVariant);
    for i := 1 to high(Fields) do
      Params[i - 1] := Values[i];
    Params[High(Fields)] := Values[0];
    Result := QExecSql(sql, Params, ShowError);
    Exit;
  end;
  if Mode = 'I' then begin
    AutoId := not ((UpperCase(Sequence) = 'ID') or (Sequence = '-'));
    Params := VarArrayCreate([0, High(Fields) + S.IIf((Sequence = ''), 1, 0)], varVariant);
    for i := 1 to high(Fields) do
      Params[i] := Values[i];
    if AutoId and (Sequence <> '') then begin
      id := QSelectId(Sequence);
      Params[0] := id;
    end;
{    if AutoId and (Sequence = '') then begin
      Params[0] := -1;
    end;}
    if not AutoId then begin
      id := Values[0];
      Params[0] := id;
    end;
// Sys.SaveTextToFile('r:\1', sql);
// Sys.SaveTextToFile('r:\2', A.Implode(Params, '; '));
    ParamsDeb := Params;
    Result := QExecSql(sql + S.IIf(Sequence = '', ' returning ' + A.ExplodeV(Fields[0], '$')[0] + ' into :' + A.ExplodeV(Fields[0], '$')[0] + '$ir', ''), Params, ShowError);
    if Result >= 0 then
      if Sequence <> '' then
        Result := id
      else
        Result := QGetReturnValues(A.ExplodeV(Fields[0], '$')[0] + '$ir')[0];
    Exit;
  end;
  if Mode = 'D' then begin
    Params := VarArrayCreate([0, 0], varVariant);
    Params[0] := Values[0];
    Result := QExecSql(sql, Params, ShowError);
    Exit;
  end;
end;

(*function TmyDB.QLoadRow(Sql: string; ParamValues: TVarDynArray): Variant;
//возвращаем первую строку запроса
//передается текст запроса, массив параметров
//возвращается ВСЕГДА МАССИВ по количеству полей, если запрос не вернуул ни одной строки то все элементы массива будут нулл!!!
var
  i: Integer;
begin
  Result := VarArrayOf([]);
  FLastReceivedFiedNames := [];
  try
    AdoQuery.Close;
    AdoQuery.SQL.Text := Sql;
    if FIsLogEnabled then
      FLastSql := Sql;
    if not QSetParams(QGetParamNamesFromSql(Sql), ParamValues) then begin
      ToLog('Ado', Sql, FLastParamsStr, FLastParamsErr);
      Exit;
    end;
    AdoQuery.Open;
    Result := VarArrayCreate([0, AdoQuery.FieldCount - 1], varVariant);
    if Length(FLastReceivedFiedNames) = 0 then
      for i := 0 to AdoQuery.FieldCount - 1 do
        FLastReceivedFiedNames := FLastReceivedFiedNames + [AdoQuery.Fields[i].FieldName];
    if not AdoQuery.EOF then begin
      for i := 0 to AdoQuery.FieldCount - 1 do
        Result[i] := AdoQuery.Fields[i].AsVariant
    end
    else
      for i := 0 to AdoQuery.FieldCount - 1 do
        Result[i] := Null;
  except
    on E: Exception do begin
      Errors.SetParam('', '', myerrTypeDB);
      Application.ShowException(E);
    end;
  end;
  ToLog('Ado', Sql, FLastParamsStr, FLastParamsErr);
  QClose;
end;     *)

(*
function TmyDB.QLoad(Sql: string; ParamValues: TVarDynArray): TVarDynArray2;
//загружаем результат запроса в вариантный двухмерный массив
var
  res, i, j: Integer;
begin
  Result := [];
  FLastReceivedFiedNames := [];
  if QOpen(Sql, ParamValues) < 0 then
    Exit;
  if Length(FLastReceivedFiedNames) = 0 then
    for i := 0 to AdoQuery.FieldCount - 1 do
      FLastReceivedFiedNames := FLastReceivedFiedNames + [AdoQuery.Fields[i].FieldName];
  while not AdoQuery.EOF do begin
    SetLength(Result, Length(Result) + 1);
    SetLength(Result[High(Result)], AdoQuery.FieldCount);
    for i := 0 to AdoQuery.FieldCount - 1 do
      Result[High(Result)][i] := AdoQuery.Fields[i].AsVariant;
    AdoQuery.Next;
  end;
  QClose;
end;
*)

function TmyDB.QLoadToRec(Sql: string; ParamValues: TVarDynArray; OneRow: Boolean = False): TNamedArr;
//загружаем результат запроса в вариантный двухмерный массив, содержащий чередующиеся имена параметров и их значения
var
  res, i, j: Integer;
begin
  try
    Result.Create;
    FLastReceivedFiedNames := [];
    if QOpen(Sql, ParamValues) < 0 then
      Exit;
    //МИГРАЦИЯ НА FIREDAC: ActiveDataSet (AdoQuery либо FdQuery, см. Backend) - оба обходятся тут только
    //через базовые методы TDataSet (EOF/FieldCount/Fields/Next), поэтому отдельного FD-варианта не нужно
    if Length(FLastReceivedFiedNames) = 0 then
      for i := 0 to ActiveDataSet.FieldCount - 1 do
        FLastReceivedFiedNames := FLastReceivedFiedNames + [ActiveDataSet.Fields[i].FieldName];
    while not ActiveDataSet.EOF do begin
      SetLength(Result.V, Length(Result.V) + 1);
      SetLength(Result.V[High(Result.V)], ActiveDataSet.FieldCount);
      for i := 0 to ActiveDataSet.FieldCount - 1 do
        Result.V[High(Result.V)][i] := ActiveDataSet.Fields[i].AsVariant;
      if OneRow then
        Break;
      ActiveDataSet.Next;
    end;
    Result.FFull := FLastReceivedFiedNames;
    Result.F := FLastReceivedFiedNames;
    for j := 0 to High(Result.F) do begin
      i := Pos('$', Result.F[j]);
      if i > 0 then
        Result.F[j] := Copy(Result.F[j], 1, i - 1);
    end;
  except
    on E: Exception do begin
      Errors.SetErrorCapt(Self.Name, 'Oшибка при загрузке данных из БД');
      Application.ShowException(E);
      Errors.SetErrorCapt;
    end;
  end;
  QClose;
end;

function TmyDB.QLoad(Sql: string; ParamValues: TVarDynArray; var Res: TNamedArr; OneRow: Boolean = False): Boolean;
//выполняет загрузку данных из БД в TNamedArr
//передается либо готовый запрос, либо строка для конструирования запроса (ее признаком является позиция ";" в строке до первой кавычки):
//"имя_таблицы;{условие (where...|*|+);}имена_полей"
//условие определяется на основе слова-признака, если его нет, следующие слова считаются полями
//если условие не передано, таблица читается по айди (первое поле), если * то вся, начинается с where - испольуется как есть
//использовать ";" в условии нельзя (поломает логику разбора, на наличие литералов проверки нет)
//если установлено OneRow, читает только одну строку (при отсутствии данных вернет пустую запись)
var
  LParams, LFields: TVarDynArray;
  LWhere: string;
  SqlM: string;
begin
  Result := False;
  if pos(';', Sql) > 0 then begin
    LParams := A.Explode(Sql, ';');
    if (LParams[1] = '') then
      LParams[1] := '*';
    if (LParams[1] = '') or (Pos('where ', LParams[1]) = 1) or (Pos('+', LParams[1]) = 1) or (Pos('*', LParams[1]) = 1) then
      LWhere := LParams[1]
    else
      LWhere := '';
    LFields := Copy(LParams, S.IIf(LWhere <> '', 2, 1).AsInteger);
    Sql := QGetSql(S.IIf((LWhere = '*') or (Pos('where ', LWhere) = 1), 'a', 's'), LParams[0], A.Implode(LFields, ';')) + S.IIfStr((LWhere <> '') and (LWhere <> '*'), ' ' + LWhere);
  end;
  Res := QLoadToRec(Sql, ParamValues);
  Result := Res.Count > 0;
end;

function TmyDB.QLoad(Sql: string; ParamValues: TVarDynArray; var Res: TVarDynArray2): Boolean;
var
  na: TNamedArr;
begin
  Result := QLoad(Sql, ParamValues, na);
  Res := na.V;
end;

function TmyDB.QLoad(Sql: string; ParamValues: TVarDynArray; var Res: TVarDynArray): Boolean;
var
  na: TNamedArr;
begin
  Result := QLoad(Sql, ParamValues, na);
  if na.Count > 0 then
    Res := A.VarDynArray2RowToVD1(na.V, 0)
  else
    Res := [null];
end;

function TmyDB.QLoad(Sql: string; ParamValues: TVarDynArray; Res: TMemTableEh; ByFieldNames: Boolean = True; ClearTable: Boolean = True): Boolean;
var
  na: TNamedArr;
begin
  Result := QLoad(Sql, ParamValues, na);
  Mth.LoadMemTableFromNamedArray(Res, na, ByFieldNames, ClearTable);
end;

function TmyDB.QLoad(Sql: string; ParamValues: TVarDynArray; Res: TDBGridEh; ByFieldNames: Boolean = True; ClearTable: Boolean = True): Boolean;
var
  na: TNamedArr;
begin
  Result := QLoad(Sql, ParamValues, na);
  Mth.LoadGridFromNamedArray(Res, na, ByFieldNames, ClearTable);
end;

function TmyDB.QLoad(Sql: string; ParamValues: TVarDynArray): TVarDynArray2;
var
  na: TNamedArr;
begin
  QLoad(Sql, ParamValues, na);
  Result := na.V;
end;

function TmyDB.QLoadRow(Sql: string; ParamValues: TVarDynArray): Variant;
var
  na: TNamedArr;
  i: Integer;
begin
  QLoad(Sql, ParamValues, na, True);
  Result := VarArrayCreate([0, na.FieldsCount - 1], varVariant);
  if Length(na.V) = 0 then
    for i := 0 to High(na.F) do
      Result[i] := Null
  else
    for i := 0 to High(na.F) do
      Result[i] := na.V[0][i];
end;

procedure TmyDB.QLoadRow(Sql: string; ParamValues: TVarDynArray; var Res: TNamedArr);
begin
  QLoad(Sql, ParamValues, Res, True);
end;

function TmyDB.QLoadRow0(Sql: string; ParamValues: TVarDynArray): TVarDynArray;
var
  na: TNamedArr;
begin
  QLoad(Sql, ParamValues, na, True);
  Result := na.V[0];
end;

function TmyDB.QLoadValue(Sql: string; ParamValues: TVarDynArray): Variant;
var
  na: TNamedArr;
begin
  Result := Null;
  QLoad(Sql, ParamValues, na, True);
  if na.Count > 0 then
    Result := na.V[0][0];
end;

function TmyDB.QLoadCol(Sql: string; ParamValues: TVarDynArray): TVarDynArray;
//загружаем одно поле (столбец) из полученных строк в вариантный одномерный массив
var
  na: TNamedArr;
begin
  QLoad(Sql, ParamValues, na, True);
  Result := A.VarDynArray2ColToVD1(na.V, 0);
end;




(*

function TmyDB.QLoadRow0(Sql: string; ParamValues: TVarDynArray): TVarDynArray;
//загружаем одну строку в вариантный одномерный массив
var
  res, i, j: Integer;
  FName: string;
begin
  Result := [];
  FLastReceivedFiedNames := [];
  if QOpen(Sql, ParamValues) < 0 then
    Exit;
  for i := 0 to AdoQuery.FieldCount - 1 do
    FLastReceivedFiedNames := FLastReceivedFiedNames + [AdoQuery.Fields[i].FieldName];
  if not AdoQuery.EOF then begin
    SetLength(Result, AdoQuery.FieldCount);
    for i := 0 to AdoQuery.FieldCount - 1 do begin
      Result[i] := AdoQuery.Fields[i].AsVariant;
    end;
  end;
  QClose;
end;
*)

(*
function TmyDB.QLoadCol(Sql: string; ParamValues: TVarDynArray): TVarDynArray;
//загружаем одно поле (столбец) из полученных строк в вариантный одномерный массив
var
  res, i, j: Integer;
  FName: string;
begin
  Result := [];
  FLastReceivedFiedNames := [];
  if QOpen(Sql, ParamValues) < 0 then
    Exit;
  if Length(FLastReceivedFiedNames) = 0 then
    FLastReceivedFiedNames := [AdoQuery.Fields[0].FieldName];
  while not AdoQuery.EOF do begin
    SetLength(Result, Length(Result) + 1);
    Result[High(Result)] := AdoQuery.Fields[0].AsVariant;
    AdoQuery.Next;
  end;
  QClose;
end;
*)

function TmyDB.QLoadToMemTableEh(Sql: string; ParamValues: TVarDynArray; MemTableEh: TMemTableEh; FieldNames: string = ''; Append: Byte = 0): Integer;
//запись результатов запроса селект в мемтаблеех
//передается запрос, параметры запроса,
//строка наименований столбцов мемтейбл через ;, признак добавления данных в таблицу - добавляется в позицию (2), в конец (1) или очищается (0).
//устанавливаются только поля из списка FieldNames (через ;), если он передан, если пустой то утанавливаются
//поля мемтейбл по именам полей запроса, если FieldNames='-' то устанавливаются поля по порядку независимо от названий
//вернет количество загруженных строк
var
  res, i, j: Integer;
  FName: string;
begin
  Result := 0;
  if QOpen(Sql, ParamValues) < 0 then
    Exit;
  MemTableEh.DisableControls;
  if (Append <> 1) and (Append <> 2) then begin
    j := MemTableEh.RecordCount - 1;
    MemTableEh.First;
    for i := 0 to j do begin
      MemTableEh.Delete;
    end;
  end;
  while not ActiveDataSet.EOF do begin
    if Append = 2 then
      MemTableEh.Last;
    MemTableEh.Append;
    for i := 0 to ActiveDataSet.FieldCount - 1 do begin
      FName := ActiveDataSet.Fields[i].FieldName;
      if (FieldNames = '') or (S.InCommaStrI(FName, FieldNames, ';')) then
        MemTableEh.FieldByName(ActiveDataSet.Fields[i].FieldName).Value := ActiveDataSet.Fields[i].AsVariant
      else if (FieldNames = '-') then
        MemTableEh.Fields[i].Value := ActiveDataSet.Fields[i].AsVariant;
    end;
    ActiveDataSet.Next;
  end;
  QClose;
  MemTableEh.First;
  Mth.Post(MemTableEh);
  Result := MemTableEh.RecordCount;
  MemTableEh.EnableControls;
end;

function TmyDB.QLoadToDBComboBoxEh(Sql: string; ParamValues: TVarDynArray; DBComboboxEh: TDBComboboxEh; ComboBoxMode: TMyControlType; Append: Byte = 0): Integer;
//загружает список в комбобокс по переденному СКЛ
//вырианты загрузки: с-список, С-список и пустая в начале,к-список и список ключей,К-список и список ключей и пустая вначале
//если требуется ключевой список то селект должно возвращать в строе - значение,ключ
//если Append=0 то списки перед загрузкой очищаются
var
  i: Integer;
begin
  Result := 0;
  if QOpen(Sql, ParamValues) < 0 then
    Exit;
  if Append = 0 then begin
    DBComboboxEh.Items.Clear;
    DBComboboxEh.KeyItems.Clear;
  end;
  if (ComboBoxMode = cntComboL0) or (ComboBoxMode = cntComboLK0) then
    DBComboboxEh.Items.Add('');
  if (ComboBoxMode = cntComboLK0) then
    DBComboboxEh.KeyItems.Add('0');
  while not ActiveDataSet.EOF do begin
    DBComboboxEh.Items.Add(ActiveDataSet.Fields[0].AsString);
    if (ComboBoxMode = cntComboLK) or (ComboBoxMode = cntComboLK0) or (ComboBoxMode = cntComboEK) then
      DBComboboxEh.KeyItems.Add(ActiveDataSet.Fields[1].AsString);
    ActiveDataSet.Next;
    inc(Result);
  end;
  QClose;
end;

function TmyDB.QLoadToTStringList(Sql: string; ParamValues: TVarDynArray; StringList: TStringList; Append: Byte = 0): Integer;
//загружает данные из запроса в TStringList
//если запрос возвращает одно поле то загружает только его, иначе загружает пару значений Key=Value, притом Value берется из левого (нулевого) поля
var
  i: Integer;
begin
  Result := 0;
  if QOpen(Sql, ParamValues) < 0 then
    Exit;
  if Append = 0 then begin
    StringList.Clear;
  end;
  while not ActiveDataSet.EOF do begin
    if ActiveDataSet.Fields.Count = 1 then
      StringList.Add(ActiveDataSet.Fields[0].AsString)
    else
      StringList.Add(ActiveDataSet.Fields[1].AsString + '=' + ActiveDataSet.Fields[0].AsString);
    ActiveDataSet.Next;
    inc(Result);
  end;
  QClose;
end;

//выполнение хранимой процедуры Oracle
//передается имя процедуры, параметры (или в строке через ;, или в VarArrayOf), значения всех параметров (или одно, или в VarArrayOf)
//каждый параметра должне после ; содержать первой буквой тип параметра, второй - направлние данных (I - входящий, B - InOut, O - выходной)
//вернет массив со значениями всех параметров (и входных и выходных), или пустой массив в случае ошибки
function TmyDB.QCallStoredProc(ProcName: string; ParamNames: Variant; ParamValues: TVarDynArray): TVarDynArray;
var
  i, j: Integer;
  st, st1, st2: string;
  v: Variant;
  ParamNamesA, ParamValuesA: TVarDynArray;
  pt: TFieldType;
  pd: TParameterDirection;
  //МИГРАЦИЯ НА FIREDAC: у FdStoredProc.Params (стандартный Data.DB.TParams) направление параметра
  //задаётся через ParamType: TParamType (ptInput/ptOutput/ptInputOutput/ptResult), а не через
  //Direction: TParameterDirection (pdInput/...), как у ADO - поэтому отдельная переменная
  fpt: TParamType;
  //TFDStoredProc.Params.CreateParam переопределен в FireDAC и возвращает ковариантный TFDParam,
  //а не базовый TParam ([dcc32] E2010 Incompatible types: 'TParam' and 'TFDParam') - поэтому тип
  //переменной должен быть именно TFDParam (см. FireDAC.Stan.Param в uses)
  fp: TFDParam;
  ps: Integer;
  //МИГРАЦИЯ НА FIREDAC: имя параметра в ParamNamesA[i] содержит наш модификатор типа/направления
  //через "$" (например "par$s") - для ADO это неважно (Oracle-провайдер ADO вызывает процедуру чисто
  //позиционно через {call proc(?,?)}, имя параметра игнорируется), а для FireDAC (нативный OCI) это
  //реальное имя параметра, которое используется для сопоставления с фактическим именем аргумента
  //хранимой процедуры в БД (см. ORA-28106 при вызове set_context_value - "par$s"/"val$i" не совпадали
  //с настоящими именами аргументов par/val) - поэтому для FD-параметра модификатор нужно отрезать
  RawParamName: string;
begin
  if PackageMode = -1 then
    Exit;
  Result := [];
  FLastSql := 'Call "' + ProcName + '"';
  FLastParamsStr := ParamNames + ' = ' + A.Implode(ParamValues, ' | ');
  try
    ParamNamesA := A.ExplodeV(ParamNames, ';');
    if (Length(ParamNamesA) = 0) or (ParamNamesA[0] = '') then
      ParamNamesA := [];
    ParamValuesA := ParamValues;
    if FBackend = mydbbFireDac then begin
      GetFdStoredProc.Params.Clear;
      FFdStoredProc.StoredProcName := ProcName;
      //МИГРАЦИЯ НА FIREDAC (см. !алгоритмы.txt, раздел 6.17): Prepare здесь заставляет FireDAC
      //сразу подтянуть из каталога БД реальные параметры процедуры - с их настоящими типами
      //(для "голого" number, без точности/масштаба, это обычно ftFMTBcd). Это нужно, чтобы НИЖЕ,
      //при простановке значений, не пытаться создавать параметр заново со СВОИМ типом (по "$"-
      //модификатору, ftInteger/ftFloat/...) - если имя совпадает с реальным аргументом (как и
      //должно быть), но тип отличается от того, что уже определил FireDAC, вылетает
      //[FireDAC][Phys][Ora]-338 "Param ... type changed ... Query must be reprepared" (было на
      //p_UserLogon после исправления имён параметров в 6.15). Если Prepare не удался (например,
      //нет прав на просмотр метаданных, или процедура не найдена) - не страшно, ниже все равно
      //есть запасной путь (создание параметра вручную, как было раньше).
      try
        FFdStoredProc.Prepare;
      except
      end;
    end
    else begin
      AdoStoredProc.Parameters.Clear;
      AdoStoredProc.ProcedureName := ProcName;
    end;
    if (High(ParamNamesA)) = (High(ParamValuesA))       //!!!!!!!!!!
      then begin
      for i := Low(ParamNamesA) to High(ParamNamesA) do
      try
        if ParamNamesA[i] <> '' then begin
          st1 := QGetParamTypeCharFromName(ParamNamesA[i]);
          if st1[2] = ' ' then
            st1[2] := 'i';
          pt := ftString;
          pd := pdInput;
          ps := 4000;
  {          st1:='S'; st2:='I'; ps:=0;
            j:=pos('$', ParamNamesA[i]);
            if j > 0 then begin
              st:=copy(ParamNamesA[i],1,j-1);
              st1:=copy(ParamNamesA[i],j+1,1);
              st2:=copy(ParamNamesA[i],j+2,1);
              if st2 = '' then st2:='I';
            end;}
          case st1[1] of
            'f':
              pt := ftFloat;
            'i':
              pt := ftInteger;
            'd':
              pt := ftDateTime;
            'h':
              pt := ftDateTime;
            'c':
              pt := ftCurrency;
          else
            begin
              pt := ftString;
              ps := 4000;
            end;
          end;
          if FBackend = mydbbFireDac then begin
            case st1[2] of
              'r':
                fpt := ptResult;
              'i':
                fpt := ptInput;
              'b':
                fpt := ptInputOutput;
              'o':
                fpt := ptOutput;
            else
              fpt := ptInput;
            end;
            RawParamName := ParamNamesA[i];
            j := Pos('$', RawParamName);
            if j > 0 then
              RawParamName := Copy(RawParamName, 1, j - 1);
            //см. комментарий у Prepare выше (6.17): если Prepare уже создал параметр с этим
            //именем (по реальным метаданным БД) - используем его как есть, НЕ пересоздавая и не
            //меняя его тип (только значение) - иначе конфликт типов. Создаём вручную (со своим
            //типом по "$"-модификатору) только если такого параметра не нашлось
            fp := TFDParam(FFdStoredProc.Params.FindParam(RawParamName));
            if fp = nil then
              fp := FFdStoredProc.Params.CreateParam(pt, RawParamName, fpt);
            fp.Value := ParamValuesA[i];
          end
          else begin
            case st1[2] of
              'r':
                pd := pdReturnValue;
              'i':
                pd := pdInput;
              'b':
                pd := pdInputOutput;
              'o':
                pd := pdOutput;
            else
              begin
                pd := pdInput
              end;
            end;
            AdoStoredProc.Parameters.CreateParameter(ParamNamesA[i], pt, pd, ps, ParamValuesA[i]);
            AdoStoredProc.Parameters[i].Attributes := [paNullable];
          end;
        end;
      except
        on E: Exception do begin
          Errors.SetParam('', 'Ошибка установки параметра запроса (' + ParamNamesA[i] + ' = "' + ParamValuesA[i] + '")'#13#10'*', myerrTypeDB);
          Application.ShowException(E);
          if (PackageMode = 1) then
            FPackageMode := -1;
        end;
      end;
    end
    else begin
      Errors.SetParam('', 'Ошибка установки параметров запроса (не совпадают количество переданных и запрошенных параметров)', myerrTypeDB);
      raise Exception.Create('Ошибка установки параметров запроса (не совпадают количество переданных и запрошенных параметров)');
      if (PackageMode = 1) then
        FPackageMode := -1;
      Exit;
    end;
    if FBackend = mydbbFireDac then begin
      FFdStoredProc.ExecProc;
      //МИГРАЦИЯ НА FIREDAC (см. 6.17): после Prepare (см. выше) FFdStoredProc.Params может
      //содержать БОЛЬШЕ параметров, чем передано в ParamNames (Prepare подтягивает ВСЕ реальные
      //параметры процедуры из каталога БД, включая необязательные с default, которые вызывающий
      //код мог не передавать) - поэтому результат нужно собирать не по всем FFdStoredProc.Params,
      //а только по тем именам, что реально были в ParamNames (и в том же порядке) - иначе длина и
      //порядок Result разъедутся с тем, что ожидают вызывающие (они обращаются к Result по индексу,
      //соответствующему позиции параметра в исходной строке ParamNames)
      for i := Low(ParamNamesA) to High(ParamNamesA) do begin
        RawParamName := ParamNamesA[i];
        j := Pos('$', RawParamName);
        if j > 0 then
          RawParamName := Copy(RawParamName, 1, j - 1);
        fp := TFDParam(FFdStoredProc.Params.FindParam(RawParamName));
        if fp <> nil then
          Result := Result + [fp.Value]
        else
          Result := Result + [Null];
      end;
    end
    else begin
      AdoStoredProc.ExecProc;
      for i := 0 to AdoStoredProc.Parameters.Count - 1 do
        Result := Result + [AdoStoredProc.Parameters[i].Value];
    end;
  except
    on E: Exception do begin
      Errors.SetParam('', '', myerrTypeDB);
      Application.ShowException(E);
      if (PackageMode = 1) then
        FPackageMode := -1;
    end;
  end;
end;


{=========================== ФУНКЦИИ РАБОТЫ С ТРАНЗАКЦИЯМИ ====================}

function TmyDB.QBeginTrans(APackageMode: Boolean = False; ShowErrors: Boolean = True): Boolean;
//открываем транзакцию
//если установлено APackageMode, инициируем пакетный режим
//(в котором запросы перестают выполняться после первого сбоя, и если он был транзакция откатится независимо от параметра)
//если есть открытая трензакция, то откатим ее!
begin
  try
    Result := False;
    //МИГРАЦИЯ НА FIREDAC: у TFDConnection транзакции - StartTransaction/Commit/Rollback/InTransaction,
    //а не BeginTrans/CommitTrans/RollbackTrans, как у ADO - разные имена методов, поэтому ветвление
    if FBackend = mydbbFireDac then begin
      if FdConnection.InTransaction then
        FdConnection.Rollback;
      FdConnection.StartTransaction;
    end
    else begin
      if AdoConnection.InTransaction then
        AdoConnection.RollbackTrans;
      AdoConnection.BeginTrans;
    end;
    Result := True;
  except
    on E: Exception do begin
      Errors.SetParam('', '', myerrTypeDB, ShowErrors);
      Application.ShowException(E);
    end;
  end;
  FPackageMode := S.IIf(APackageMode, S.IIf(Result, 1, -1), 0);
end;

function TmyDB.QCommitOrRollback(Commit: Boolean = True; ShowErrors: Boolean = True): Boolean;
//фиксируем или откатываем транзакцию
//если пакетный режим, то режим фиксации/отката определяется его результатом and Commit
//также проставим свойтво статуса последней транзакции
//если нет открытой транзакции, выйдем с False
begin
  if FBackend = mydbbFireDac then begin
    if not FdConnection.InTransaction then begin
      Result := False;
      Exit;
    end;
  end
  else begin
    if not AdoConnection.InTransaction then begin
      Result := False;
      Exit;
    end;
  end;
  if PackageMode <> 0 then
    Commit := (PackageMode = 1) and (Commit);
  try
    Result := False;
    if FBackend = mydbbFireDac then begin
      if Commit then
        FdConnection.Commit
      else
        FdConnection.Rollback;
    end
    else begin
      if Commit then
        AdoConnection.CommitTrans
      else
        AdoConnection.RollbackTrans;
    end;
    Result := True;
  except
    on E: Exception do begin
      Errors.SetParam('', '', myerrTypeDB, ShowErrors);
      Application.ShowException(E);
    end;
  end;
  //сбросим пакетный режим
  FPackageMode := 0;
  FCommitSuccess := Result and Commit;
  //изм 2026-08-22 - венрнем  не результат самой операции, но статус фиксации транзакции
  Result := Result and Commit;
end;

function TmyDB.QCommitTrans: Boolean;
//коммитим транзакцию
begin
  Result := QCommitOrrollback(True);
end;

function TmyDB.QRollbackTrans: Boolean;
//откатываем транзакцию
begin
  Result := QCommitOrRollback(False);
end;

function TmyDB.QSelectId(sequence: string): LongInt;
//возвращаем айди из переданной секвенции
begin
  Result := StrToInt(VarToStr(QLoadValue('select ' + sequence + '.nextval from dual', [])));
  FLastSequenceId := Result;
end;


{=========================== УСТАНОВКА BIND-ПЕРЕМЕННЫХ ДЛЯ ЗАПРОСОВ ===========}

function TmyDB.QSetParamsEh(ADODataDriverEh1: TADODataDriverEh; ParamNames: Variant; ParamValues: TVarDynArray; CommandType: string = 's'; IgnoreRemainings: Boolean = False): Boolean;
//устанавливает параметры в ADODataDriverEh1
//типы определяются по модификаторам $s, $f, $i, $d
//устанавливает для запроса драйвера в соотв с CommandType (по умолчанию s - selectsql)
//если IgnoreRemainings=True (не по умолчанию), то переданные но не найденные в запросе параметры проигнорирует, иначе выдаст ошибку
//устанавливает параметры в ADODataDriverEh1
//типы определяются по модификаторам $s, $f, $i, $d
//устанавливает для запроса драйвера в соотв с CommandType (по умолчанию s - selectsql)
//если IgnoreRemainings=True (не по умолчанию), то переданные но не найденные в запросе параметры проигнорирует, иначе выдаст ошибку
var  //++ поставить исключения!!!  параметры в []
  i, j, k: Integer;
  st, st1, st2: string;
  v: Variant;
  ParamNamesA: TVarDynArray;
  Parameters: TParameters;
  Command: TAdoCommandEh;
  b: Boolean;
begin
  //проверять так
  //if VarType(V) and VarArray = VarArray then  или VarIsArray(ParamValues)
  Result := False;
  try
    if ParamNames = '' then
      Exit;
    FLastParamsStr := '';
    FLastParamsErr := '';
    case UpCase(CommandType[1]) of
      'U':
        Command := ADODataDriverEh1.UpdateCommand;
      'D':
        Command := ADODataDriverEh1.DeleteCommand;
      'G':
        Command := ADODataDriverEh1.GetrecCommand;
      'R':
        Command := ADODataDriverEh1.GetrecCommand;
    else
      Command := ADODataDriverEh1.SelectCommand;
    end;
    if FIsLogEnabled then
      FLastSql := Command.CommandText.Text;
    ;
    ParamNamesA := A.ExplodeV(ParamNames, ';');
    if (Length(ParamNamesA) = 0) or (ParamNamesA[0] = '') then
      Exit;
    Result := False;
    for i := 0 to Max(High(ParamNamesA), High(ParamValues)) do begin
      if i <= High(ParamNamesA) then
        st1 := VarToStr(ParamNamesA[i])
      else
        st1 := '<Unknown>';
      if i <= High(ParamValues) then
        st2 := S.IIf(VarIsNull(ParamValues[i]), '<Null>', VarToStr(ParamValues[i]))
      else
        st2 := '<Unknown>';
      S.ConcatStP(FLastParamsStr, '[' + st1 + ']=' + st2, sLineBreak);
    end;
    Parameters := Command.Parameters;
    if (High(ParamNamesA)) = (High(ParamValues)) then begin
      for i := Low(ParamNamesA) to High(ParamNamesA) do
      try
        if ParamNamesA[i] <> '' then begin
          b := False;
          for k := 0 to Parameters.Count - 1 do
            if Parameters[k].Name = ParamNamesA[i] then begin
              b := True;
              Break;
            end;
          if b or (IgnoreRemainings = False) then
            if pos('$', ParamNamesA[i]) = 0 then
              Parameters.ParamValues[ParamNamesA[i]] := ParamValues[i]
            else begin
              j := pos('$', ParamNamesA[i]);
              st := copy(ParamNamesA[i], 1, j - 1);
              st1 := copy(ParamNamesA[i], j + 1, 1);
              if UpperCase(st1) = 'F' then
                Parameters.ParamByName(ParamNamesA[i]).DataType := ftFloat
              else if UpperCase(st1) = 'I' then
                Parameters.ParamByName(ParamNamesA[i]).DataType := ftInteger
              else if UpperCase(st1) = 'S' then
                Parameters.ParamByName(ParamNamesA[i]).DataType := ftString
              else if UpperCase(st1) = 'D' then
                Parameters.ParamByName(ParamNamesA[i]).DataType := ftDateTime;
  //Parameters.ParamByName(ParamNamesA[i]).Attributes:=[paNullable];
              Parameters.ParamValues[ParamNamesA[i]] := ParamValues[i];
            end;
        end;
        FLastParamsErr := 'Ошибка установки параметра запроса (' + ParamNamesA[i] + ' = "' + VarToStr(ParamValues[i]) + '")'#13#10'*';
      except
        on E: Exception do begin
          Errors.SetParam('', FLastParamsErr, myerrTypeDB);
          Application.ShowException(E);
          FLastParamsErr := ''
        end;
      end;
    end
    else begin
      Errors.SetParam('', 'Ошибка установки параметров запроса (не совпадают количество переданных и запрошенных параметров)', myerrTypeDB);
      raise Exception.Create('Ошибка установки параметров запроса (не совпадают количество переданных и запрошенных параметров)');
    end;
    Result := True;
  except
    on E: Exception do begin
      Errors.SetParam('', FLastParamsErr, myerrTypeDB);
      Application.ShowException(E);
      FLastParamsErr := E.Message;
    end;
  end;
  //MyData.IsOraTreat:=False;
end;

{===================== РАБОТА С ЛОГАМИ ========================================}

function TmyDB.SetEnableLog(Enable: Boolean = True): Boolean;
//разрешить или запретить запись запросов в лог
begin
  if FIsLogEnabled = Enable then
    Exit;
  Result := Enable;
  FIsLogEnabled := Enable;
  //FLastSql := '';
  //FLastParamsStr := '';
  //FLastParamsErr := ''
  {
  S.SwapPlaces(FLastSql, _FLastSql);
  S.SwapPlaces(FLastParamsStr, _FLastParamsStr);
  S.SwapPlaces(FLastParamsErr, _FLastParamsErr);}
end;

procedure TmyDB.ToLogEh(Command: TCustomSQLCommandEh; ErrMsg: string = '');
//добавляет в лог данные из AdoDataDriverEh при выполнении команды
var
  ap: TParameters;
  i: Integer;
  s, ps: string;
begin
  if not FIsLogEnabled then
    Exit;
  if Command is TADOCommandEh then begin
    ap := TADOCommandEh(Command).Parameters;
    for i := 0 to ap.Count - 1 do begin
      if VarIsNull(ap[i].Value) then
        ps := '<Null>'
      else
        ps := VarToStr(ap[i].Value);
      s := s + '[' + ap[i].Name + ']=' + ps + sLineBreak;
    end;
  end;
  ToLog('Eh', Command.FinalCommandText.Text, s, ErrMsg);
end;

procedure TmyDB.ToLog(Source, Query, Params, ErrMsg: string);
//запись запроса и параметров в массив лога
//также устанавливает последнюю команду, и при открытом журнале лога вызывает его обновление (добавление строки)
begin
  if not FIsLogEnabled then
    Exit;
  FLogArray := FLogArray + [[-1, Now, Source, Query, Params, ErrMsg]];
  try
    if FrmXGSrvSqlMonitor <> nil then
      FrmXGSrvSqlMonitor.LoadLogRowToGrid;
  except
  end;
end;

end.
