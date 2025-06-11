unit uDBParsec;

interface

uses
  System.SysUtils, System.Classes, MemTableDataEh, Data.DB,
  Data.Win.ADODB, DataDriverEh, ADODataDriverEh, MemTableEh,
  uString, uDB
  ;

type
  TmyDBParsec = class(TmyDB)
  private
    { Private declarations }
  public
    { Public declarations }
    //������� ������ ���� ������
    //���������� ���� �������� ���������� (������ ��� �����, ��� ����������), ���� AConnectAfterCreate �� ��� �� �������� ������������
    constructor CreateObject(AOwner: TComponent; AConnectionFile: string; AConnectAfterCreate: Boolean = True); reintroduce;
  end;

var
  myDBParsec: TmyDBParsec;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

constructor TmyDBParsec.CreateObject(AOwner: TComponent; AConnectionFile: string; AConnectAfterCreate: Boolean = True);
//������� ������ ���� ������
//���������� ���� �������� ���������� (������ ��� �����, ��� ����������), ���� AConnectAfterCreate �� ��� �� �������� ������������
var
  va: TVarDynArray;
begin
  Inherited CreateObject(AOwner, mydbtMsSql, AConnectionFile, AConnectAfterCreate);
end;


end.
