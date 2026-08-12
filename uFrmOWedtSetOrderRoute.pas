{
Установка производственного маршрута для позиции заказа (order_items).
В качестве айди передается id записи в order_items.
Задается производственный маршрут (поля rXX), а также признаки "Без маршрута" (r0) и "Без сметы" (wo_estimate).
Если установлен признак "Без маршрута" или "Без сметы", флажки маршрута снимаются и блокируются.
}


unit uFrmOWedtSetOrderRoute;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFields, uFrmBasicDbDialog,
  Vcl.Mask
  ;

type
  TFrmOWedtSetOrderRoute = class(TFrmBasicDbDialog)
    chb_R0: TDBCheckBoxEh;
    chb_Wo_Estimate: TDBCheckBoxEh;
  private
    function  Prepare: Boolean; override;
    procedure ControlOnChange(Sender: TObject); override;
    function  VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean; override;
  protected
    procedure SetRoute;
  public
  end;

var
  FrmOWedtSetOrderRoute: TFrmOWedtSetOrderRoute;

implementation

{$R *.dfm}

function TFrmOWedtSetOrderRoute.Prepare: Boolean;
var
  i: Integer;
  va2: TVarDynArray2;
begin
  Result := False;
  Caption := 'Производственный маршрут';

  //создадим динамически чекбоксы для полей маршрута (rXX), аналогично TFrmODedtOrStdItem
  for i := 0 to High(RouteFields) do begin
    Cth.CreateControls(pnlFrmClient, cntCheck, RouteFields[i], 'chb_r' + IntToStr(i + 1), '', 0, chb_R0.Left + i * 50, chb_R0.Top + chb_R0.Height + MY_FORMPRM_H_EDGES);
    TDBCheckBoxEh(Self.FindComponent('chb_r' + IntToStr(i + 1))).Caption := RouteFields[i];
    va2 := va2 + [['r' + IntToStr(i + 1) + '$i']];
  end;

  F.DefineFields:=[
    ['id$i'],
    ['r0$i'],
    ['wo_estimate$i']
  ] + va2;

  View := 'v_order_items';
  Table := 'order_items';
  FOpt.UseChbNoClose := True;
  FOpt.InfoArray := [[
     'Задание производственного маршрута позиции заказа.'#13#10+
     'Если установлен признак "Без маршрута" или "Без сметы", флажки маршрута снимаются и блокируются.'#13#10+
     'Изменение маршрута доступно конструкторам и технологам.'
  ]];

  Result := inherited;

  F.SetProp('wo_estimate', False, fvtDsbl);

  if not Result then
    Exit;
  SetRoute;
end;

procedure TFrmOWedtSetOrderRoute.ControlOnChange(Sender: TObject);
begin
  if (A.InArray(TControl(Sender).Name, ['chb_R0', 'chb_Wo_Estimate'])) or (Copy(TControl(Sender).Name, 1, 5) = 'chb_r') then
    SetRoute;
  inherited;
end;

function TFrmOWedtSetOrderRoute.VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean;
//если не заданы "Без маршрута" и "Без сметы" - должна быть отмечена хотя бы одна галка маршрута
var
  i, j: Integer;
begin
  Result := False;
  j := 0;
  for i := 0 to ComponentCount - 1 do
    if (Copy(Components[i].Name, 1, 5) = 'chb_r') and (TDBCheckBoxEh(Components[i]).Checked) then
      j := j + 1;
  for i := 0 to ComponentCount - 1 do
    if (Copy(Components[i].Name, 1, 5) = 'chb_r') then
      Cth.SetErrorMarker(TDBCheckBoxEh(Components[i]), TDBCheckBoxEh(Components[i]).Enabled and (j = 0));
end;

procedure TFrmOWedtSetOrderRoute.SetRoute;
//снимаем и блокируем чекбоксы маршрута, если установлено "Без сметы" или "Без маршрута";
//иначе разблокируем их (сам признак "Без маршрута"/"Без сметы" при этом не трогаем)
var
  i: Integer;
begin
  if Mode in [fDelete, fView] then
    Exit;
  if (Cth.GetControlValue(chb_Wo_Estimate) = 1) or (Cth.GetControlValue(chb_R0) = 1) then
    for i := 0 to ComponentCount - 1 do
      if Copy(Components[i].name, 1, 5) = 'chb_r' then begin
        TDBCheckBoxEh(Components[i]).Checked := False;
        TDBCheckBoxEh(Components[i]).Enabled := False;
      end;
  if (Cth.GetControlValue(chb_Wo_Estimate) = 0) and (Cth.GetControlValue(chb_R0) = 0) then
    for i := 0 to ComponentCount - 1 do
      if Copy(Components[i].name, 1, 5) = 'chb_r' then begin
        TDBCheckBoxEh(Components[i]).Enabled := True;
      end;
end;

end.
