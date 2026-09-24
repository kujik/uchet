{
см. !алгоритмы.txt, раздел "Компьютеры домена".

Справочник "Компьютеры домена" - показывает данные, которые собирает резидентный агент, запускаемый на
всех компьютерах предприятия через доменную политику (GPO). Агент пишет данные в таблицу usersinfo БД
Firebird (сервер 10.1.1.4, fresh.fdb) - см. myDBFirebird/TmyDBFirebird (uDBFirebird.pas) и секцию
[Firebird.FireDAC] в uchet.cfg.

Похожий по смыслу, но более старый справочник - "Пользователи домена" (uFrmAGlstDomainUsers.pas,
myfrm_Adm_DomainUsers) - читает данные того же агента, но из ДРУГОГО, более раннего источника (SQLite-
файл на сетевом ресурсе \\10.1.1.14\Scriptsw\Domain\freshagent.sqlite, см. этот юнит) и с меньшим набором
полей. Оставлен как есть (на случай, если этот источник у кого-то еще актуален) - этот справочник его не
заменяет и не трогает.

Только чтение (форма не редактирует usersinfo - соответствующих UPDATE-запросов в проекте Учет нет,
таблицу пишет только сам агент).
}

unit uFrmAGlstDomainComputers;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uDBFirebird
  ;

type
  TFrmAGlstDomainComputers = class(TFrmBasicGrid2)
  private
    function  PrepareForm: Boolean; override;
    procedure GetData;
  end;

var
  FrmAGlstDomainComputers: TFrmAGlstDomainComputers;

implementation

{$R *.dfm}

function TFrmAGlstDomainComputers.PrepareForm: Boolean;
begin
  Result := False;
  Caption := 'Компьютеры домена';
  //см. !алгоритмы.txt, раздел "Компьютеры домена": подключаемся лениво, только при открытии этого
  //справочника (myDBFirebird создается с AConnectAfterCreate = False, см. Uchet.dpr) - недоступность
  //этого сервера не должна мешать работе остальной части программы
  if not myDBFirebird.Connect(False) then begin
    //см. !алгоритмы.txt, раздел "Компьютеры домена" (правка после жалобы на "непонятно что не так" +
    //кракозябры): myDBFirebird.ErrorState - текст РЕАЛЬНОЙ ошибки FireDAC/Firebird (недоступна сеть,
    //неверный логин/пароль и т.п.), см. TmyDB.Connect (ветка mydbtFirebird) - раньше не показывался
    //вообще, пользователь видел только общую фразу без возможности понять причину
    Application.MessageBox(
      pWideChar('Не удалось подключиться к базе данных резидентного агента (Firebird, 10.1.1.4).' + sLineBreak +
      sLineBreak +
      'Причина: ' + myDBFirebird.ErrorState),
      'Ошибка', MB_ICONERROR);
    Exit;
  end;
  Frg1.Opt.SetFields([
    ['machine$s','Имя компьютера','130'],
    ['domain$s','Домен','100'],
    ['login$s','Логин','120'],
    ['name$s','Отображаемое имя','150'],
    ['os_version$s','Версия ОС','200;h'],
    ['ip_addresses$s','Адреса сетевых адаптеров','200;h'],
    ['ip_first$s','Первый IP-адрес','110'],
    ['mac_first$s','Первый MAC-адрес','120;h'],
    ['last_boot$s','Последняя загрузка','130'],
    ['last_login$s','Последний логин','130'],
    ['last_time$s','Последняя активность','130']
  ]);
  Frg1.InfoArray:=[[
    'Данные, которые собирает резидентный агент, запущенный на компьютерах предприятия (через доменную политику).'#10#13+
    'Обновляются автоматически, самим агентом - этот справочник только для чтения.'#10#13
  ]];
  Frg1.SetInitData([]);
  GetData;
  Result := Inherited;
end;

procedure TFrmAGlstDomainComputers.GetData;
var
  va2: TVarDynArray2;
begin
  va2 := myDBFirebird.QLoad(
    'select machine, domain, login, name, os_version, ip_addresses, ip_first, mac_first, ' +
    'last_boot, last_login, last_time ' +
    'from usersinfo ' +
    'order by machine, domain, login',
    []);
  Frg1.SetInitData(va2);
end;

end.
