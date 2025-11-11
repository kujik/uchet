unit uDBParsec;

interface

uses
  System.SysUtils, System.Classes, MemTableDataEh, Data.DB,
  Data.Win.ADODB, DataDriverEh,
  uString, uDB, ADODataDriverEh, MemTableEh
  ;

type
  TmyDBParsec = class(TmyDB)
  private
    { Private declarations }
  public
    { Public declarations }
    //создаем объект базы данных
    //передается файл настроек соединения (только имя файла, без расширения), если AConnectAfterCreate то тут же пытаемся подключиться
    constructor CreateObject(AOwner: TComponent; AConnectionFile: string; AConnectAfterCreate: Boolean = True); reintroduce;
  end;

var
  myDBParsec: TmyDBParsec;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

constructor TmyDBParsec.CreateObject(AOwner: TComponent; AConnectionFile: string; AConnectAfterCreate: Boolean = True);
//создаем объект базы данных
//передается файл настроек соединения (только имя файла, без расширения), если AConnectAfterCreate то тут же пытаемся подключиться
var
  va: TVarDynArray;
begin
  Inherited CreateObject(AOwner, mydbtMsSql, AConnectionFile, AConnectAfterCreate);
end;


end.
