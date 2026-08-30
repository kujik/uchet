{
Просмотр текущего предупреждения "Проверить группу"/"Проверить все группы" (or_std_items_group_checks)
для ОДНОЙ группы форматов стандартных изделий (or_formats). ID = or_formats.id (id_format).

История не хранится - в or_std_items_group_checks остается только последняя проверка по группе, и
только если она нашла предупреждения (см. TOrders.CheckStdItemsGroupSync в uOrders.pas); отсутствие
строки для группы означает "предупреждений нет" (либо проверка еще не запускалась - эти два случая
неразличимы, см. общий комментарий у TOrders.CheckStdItemsGroupSync).

Открывается через Wh.ExecDialog(myfrm_Rep_StdItemsGroupCheck, ..., fView, AIdFormat, null) - см.:
- пункт меню "Просмотр предупреждения" (без кнопки, отрицательный тег) в справочнике стандартных изделий
  (uFrmOGrefOrStdItems.pas, Frg1ButtonClick, Tag = 1006) - id_format определяется по выбранной в
  CbEstimate подгруппе;
- двойной клик по столбцу "Внимание" в справочнике "Форматы стандартных изделий"
  (uFrmXGlstMain.pas, Frg1OnDbClick, FormDoc = myfrm_R_StdPspFormats) - там Fr.ID уже сам id_format.
}
unit uFrmOWrepStdItemsGroupCheck;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmBasicMdi, Vcl.ExtCtrls, Vcl.StdCtrls,
  DBCtrlsEh, uData, Vcl.Mask, uString, uLabelColors;

type
  TFrmOWrepStdItemsGroupCheck = class(TFrmBasicMdi)
    pnlTop: TPanel;
    lblCapt1: TLabel;
    lblCapt2: TLabel;
    lblDateTime: TLabel;
    lblUser: TLabel;
    lblWarnings: TLabel;
    mmoReport: TDBMemoEh;
  private
    { Private declarations }
    function  Prepare: Boolean; override;
  public
    { Public declarations }
  end;

var
  FrmOWrepStdItemsGroupCheck: TFrmOWrepStdItemsGroupCheck;

implementation

{$R *.dfm}

uses
  uSettings,
  uForms,
  uDBOra,
  uMessages
  ;

function TFrmOWrepStdItemsGroupCheck.Prepare: Boolean;
//ID = or_formats.id (id_format проверяемой группы) - см. общий комментарий в начале модуля
var
  LFormatName: string;
  va: TVarDynArray;
begin
  Result := False;
  Caption := '~Проверка группы стандартных изделий';
  BorderStyle := bsSizeable;
  if not inherited then
    Exit;

  mmoReport.ReadOnly := True;
  mmoReport.ScrollBars := ssVertical;

  LFormatName := VarToStr(Q.QLoadValue('select name from or_formats where id = :id$i', [ID]));
  lblCapt1.Caption := 'Проверка группы форматов стандартных изделий:';
  lblCapt2.SetCaption2('$FF0000' + LFormatName);

  va := Q.QLoadRow('select dt, username, report from v_or_std_items_group_checks where id_format = :id_format$i', [ID]);

  if va[0] = null then begin
    lblDateTime.Caption := '';
    lblUser.Caption := '';
    lblWarnings.SetCaption2('Предупреждения: $008000нет');
    mmoReport.Lines.Text := '';
  end
  else begin
    lblDateTime.SetCaption2('Дата/время проверки: $FF0000' + DateTimeToStr(VarToDateTime(va[0])));
    lblUser.SetCaption2('Пользователь: $FF0000' + VarToStr(va[1]));
    lblWarnings.SetCaption2('Предупреждения: $FF0000ЕСТЬ');
    mmoReport.Lines.Text := VarToStr(va[2]);
  end;

  Result := True;
end;

end.
