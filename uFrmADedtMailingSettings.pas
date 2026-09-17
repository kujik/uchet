unit uFrmADedtMailingSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmBasicMdi, Vcl.ExtCtrls, Vcl.StdCtrls,
  DBCtrlsEh, ToolCtrlsEh, Vcl.Mask, System.Math,
  uData, uString, uMailingInterface, uTasks
  ;

type
  TFrmADedtMailingSettings = class(TFrmBasicMdi)
    pnlClient: TPanel;
    //прокручиваемая область вокруг pnlClient (см. .dfm) - добавлена, так как
    //число рассылок может быть большим и не помещаться по высоте экрана
    //(см. Prepare - раньше при большом числе рассылок вместо прокрутки
    //неограниченно росла высота самой формы)
    sbxClient: TScrollBox;
  private
    { Private declarations }
    //по одному экземпляру на каждую отображаемую рассылку (см. Prepare) - в
    //том же порядке, что и созданные для них контролы
    MailingInterfaces: array of TMailingInterface;
    function Prepare: Boolean; override;
    procedure VerifyBeforeSave; override;
    function Save: Boolean; override;
    procedure btnClick(Sender: TObject); override;
  public
    { Public declarations }
  end;

var
  FrmADedtMailingSettings: TFrmADedtMailingSettings;

implementation

uses
  uDBOra, uForms
  ;

const
  //тег кнопки для разработчика "Задать рассылки" (см. FOpt.DlgButtonsL в
  //Prepare и обработку в btnClick ниже) - выгружает в adm_mailing заданный в
  //коде (uTasks.pas, TTasks.SyncServerTaskMailings) список рассылок
  //серверных заданий; управление самим списком рассылок в adm_mailing
  //(добавление/удаление, задание pos) через эту кнопку не делается - список
  //по-прежнему задаётся только в коде
  cBtnDevSetMailings = 2001;

{$R *.dfm}

function TFrmADedtMailingSettings.Prepare: Boolean;
//строит по одному редактору адресатов на каждую рассылку из adm_mailing, у
//которой pos > 0 (pos <= 0 или не задан - рассылка не используется и не
//показывается), в порядке pos - см. постановку задачи. каждый редактор
//управляется своим TMailingInterface (uMailingInterface.pas) - тот же
//механизм выбора пользователей/произвольных адресов, что был на убранной
//вкладке "Настройки почты" формы uFrmADedtMainSettings (см. её заголовок).
//
//рассылок может быть много, и они могут не поместиться по высоте экрана -
//поэтому pnlClient размещён внутри прокручиваемой области sbxClient (см.
//.dfm): сам pnlClient растёт под фактическое число рассылок (как и раньше
//росла вся форма), а высота ФОРМЫ теперь ограничена разумным пределом
//(cMaxClientHeight) - если содержимое выше этого предела, лишнее становится
//доступно через полосу прокрутки sbxClient, а не за счёт формы, вылезающей
//за экран
const
  cMaxClientHeight = 500; //подобрано так, чтобы форма помещалась на типичном экране
var
  va: TVarDynArray2;
  i, t: Integer;
  c: TControl;
begin
  Result := True;
  Caption := '~Настройки почтовых рассылок';
  FOpt.DlgPanelStyle := dpsBottomRight;
  FOpt.StatusBarMode := stbmDialog;
  //кнопка видна только разработчику - см. константу cBtnDevSetMailings выше
  FOpt.DlgButtonsL := [[cBtnDevSetMailings, User.IsDeveloper, True, 160, 'Задать рассылки', 'settings_spanner']];

  //ширина pnlClient - по ширине видимой области прокрутки (без учёта
  //вертикальной полосы прокрутки, которую сам TScrollBox добавит к
  //ClientWidth только когда она реально появится - на ширину контролов
  //внутри это не влияет, они заведомо уже на величину отступов)
  pnlClient.Width := sbxClient.ClientWidth;
  va := Q.QLoad('select id, comm from adm_mailing where pos > 0 order by pos', []);
  SetLength(MailingInterfaces, Length(va));
  t := 19;
  for i := 0 to High(va) do begin
    c := Cth.CreateControls(pnlClient, cntEdit, va[i][1], 'edtMailing' + IntToStr(va[i][0]), '', 0);
    //лейбл над контролом (как на прежней вкладке), а не слева от него -
    //Cth.CreateControls по умолчанию ставит лейбл слева, что не годится для
    //длинных подписей рассылок
    TDbEditEh(c).ControlLabelLocation.Position := lpAboveLeftEh;
    TDbEditEh(c).ReadOnly := True;
    c.Left := 3;
    c.Top := t;
    c.Width := pnlClient.Width - 10;
    c.Anchors := [akLeft, akTop, akRight];
    MailingInterfaces[i] := TMailingInterface.Create(Self, TDbEditEh(c), va[i][0], '*', True);
    MailingInterfaces[i].Load;
    Inc(t, 42);
  end;
  //растим pnlClient (а не форму) под фактическое число рассылок - лишнее
  //станет доступно через прокрутку sbxClient (см. комментарий выше)
  pnlClient.Height := t + 10;
  //высота формы ограничена разумным пределом (cMaxClientHeight) вместо
  //неограниченного роста под все рассылки сразу (было раньше - см.
  //комментарий выше); аналогичный приём (подгонка высоты формы) - в
  //TFrmChooseDialog.ShowDialog, uFrmChooseDialog.pas, но там без ограничения
  //сверху, так как там количество строк заведомо небольшое
  Self.ClientHeight := Min(t + 10, cMaxClientHeight) + pnlFrmBtns.Height + pnlStatusBar.Height;
end;

procedure TFrmADedtMailingSettings.VerifyBeforeSave;
//см. TFrmBasicMdi.btnOkClick: если FErrorMessage начинается с '?' - показывается
//вопрос (Да - сохраняем), иначе - предупреждение (сохранение блокируется)
var
  i: Integer;
  Changed: Boolean;
begin
  Changed := False;
  for i := 0 to High(MailingInterfaces) do
    if MailingInterfaces[i].IsChanged then begin
      Changed := True;
      Break;
    end;
  if not Changed then begin
    FErrorMessage := 'Данные не были изменены.';
    Exit;
  end;
  FErrorMessage := '?Данные были изменены. Сохранить?';
end;

function TFrmADedtMailingSettings.Save: Boolean;
var
  i: Integer;
begin
  for i := 0 to High(MailingInterfaces) do
    MailingInterfaces[i].Save;
  Result := True;
end;

procedure TFrmADedtMailingSettings.btnClick(Sender: TObject);
begin
  if TButton(Sender).Tag = cBtnDevSetMailings then begin
    Tasks.SyncServerTaskMailings;
    ShowMessage('Список рассылок серверных заданий выгружен в adm_mailing.' +
      ' Если появились новые рассылки, для их отображения форму нужно открыть заново.');
  end;
end;

end.
