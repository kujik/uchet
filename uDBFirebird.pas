unit uDBFirebird;

interface

uses
  System.SysUtils, System.Classes, MemTableDataEh, Data.DB,
  Data.Win.ADODB, DataDriverEh,
  uString, uDB, ADODataDriverEh, MemTableEh, FireDAC.Phys.FBDef,
  FireDAC.Stan.Intf, FireDAC.Phys, FireDAC.Phys.IBBase, FireDAC.Phys.FB
  ;

type
  TmyDBFirebird = class(TmyDB)
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
  private
    { Private declarations }
  public
    { Public declarations }
    //см. !алгоритмы.txt, раздел "Компьютеры домена": аналог TmyDBParsec (uDBParsec.pas), но для
    //Firebird - БД резидентного агента (fresh.fdb на 10.1.1.4), собирающего информацию о компьютерах
    //пользователей домена (таблица usersinfo) - см. справочник "Компьютеры домена"
    //(uFrmAGlstDomainComputers.pas). В отличие от Парсека (тот всегда ADO), здесь ВСЕГДА FireDAC
    //(mydbbFireDac, передается фиксированно в Inherited CreateObject ниже) - у ADO нет надежного
    //штатного провайдера Firebird, см. также TmyDB.Connect (там для mydbtFirebird отдельная ветка,
    //целиком в обход ADO). Настройки подключения (Server/Database/User_Name/Password) берутся из
    //секции [Firebird.FireDAC] в uchet.cfg/uchet_test.cfg - см. TmyDB.ReadConnectionFile/
    //GetAppConfigSectionName. AConnectionFile здесь, как и у TmyDBParsec, фактически не используется
    //(имя секции конфига привязано к DbType, а не к этому параметру) - передается только для
    //единообразия с остальными потомками TmyDB и на случай отсутствия секции в конфиге
    //(тогда ReadConnectionFile попытался бы, как для остальных типов, читать AConnectionFile+'.udl' -
    //для Firebird такой файл не заводим, это просто отражено в имени параметра)
    constructor CreateObject(AOwner: TComponent; AConnectionFile: string; AConnectAfterCreate: Boolean = True); reintroduce;
  end;

var
  myDBFirebird: TmyDBFirebird;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

constructor TmyDBFirebird.CreateObject(AOwner: TComponent; AConnectionFile: string; AConnectAfterCreate: Boolean = True);
//см. комментарий у объявления в interface-секции
begin
  Inherited CreateObject(AOwner, mydbtFirebird, AConnectionFile, AConnectAfterCreate, mydbbFireDac);
end;


end.
