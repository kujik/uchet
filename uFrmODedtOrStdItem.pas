{
Редактирование стандартного изделия.
В дополнительном параметре всегда передается айди сметной группы (id_or_format_estimates).
Редактировать цену можно только обладая правом на это.
}


unit uFrmODedtOrStdItem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFields, uFrmBasicDbDialog,
  Vcl.Mask
  ;

type
  TFrmODedtOrStdItem = class(TFrmBasicDbDialog)
    edt_name: TDBEditEh;
    chb_R0: TDBCheckBoxEh;
    chb_Wo_Estimate: TDBCheckBoxEh;
    nedt_Price: TDBNumberEditEh;
    nedt_Price_PP: TDBNumberEditEh;
    chb_by_sgp: TDBCheckBoxEh;
  private
    FRcount: Integer;
    FNameOld : string;
    FWoEstimateOld: Integer;
    FIdEstimateGroup: Variant;
    FPrefix: string ;
    FIsRouteChanged: Boolean;
    FIdOrFormatEstimate: Variant;
    function  Prepare: Boolean; override;
    procedure ControlOnChange(Sender: TObject); override;
    function  VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean; override;
  protected
    procedure VerifyBeforeSave; override;
    function  Save: Boolean; override;
    procedure SetRoute;
  public
  end;

var
  FrmODedtOrStdItem: TFrmODedtOrStdItem;

implementation

 uses
   uOrders
   ;

 {$R *.dfm}

function TFrmODedtOrStdItem.Prepare: Boolean;
var
  i, j: Integer;
  va: TVarDynArray;
  va1, va2: TVarDynArray2;
begin
  Result := False;
  Caption:='Стандартное изделие';

  for i := 0 to High(RouteFields) do begin
    Cth.CreateControls(pnlFrmClient, cntCheck, RouteFields[i], 'chb_r' + IntToStr(i + 1), '', 0, edt_name.Left + i * 50, edt_name.Top + edt_name.Height + MY_FORMPRM_H_EDGES);
    TDBCheckBoxEh(Self.FindComponent('chb_r' + IntToStr(i + 1))).Caption := RouteFields[i];
    va2 :=  va2 + [['r' + IntToStr(i + 1) + '$i']];
  end;

  F.DefineFields:=[
    ['id$i'],
    ['name$s','V=1:400::T'],
    ['price$f','V=0:9999999:2:n'],
    ['price_pp$f','V=0:9999999:2:n'],
    ['wo_estimate$i'],
    ['r0$i'],
    ['by_sgp$i'],
    ['id_or_format_estimates$i','V=1:400:1']
  ] + va2;

  View := 'v_or_std_items';
  Table := 'or_std_items';
  FOpt.UseChbNoClose:= True;
  //Opt.RequestWhereClose:= cqYNC;
  FOpt.InfoArray:= [[
     'Ввод параметров стандартного изделия.'#13#10+
     'Введите или измените все необходимые данные.'#13#10+
     'При изменении наименования оно будет автоматически изменено во всех изделиях Учета и ИТМ'#13#10+
     '(но если такое наименование есть в качестве позиции в смете, то там оно изменено не будет!)'#13#10+
     'При изменении маршрута или цен по изделию, они будут скорректированы во всех шаблонах папортов.'#13#10
  ]];

  Result := inherited;
  if not Result then
    Exit;
  if Mode <> fDelete then begin
    FNameOld := S.NSt(F.GetPropB('name'));
    FWoEstimateOld:=S.NInt(F.GetPropB('wo_estimate'));
    FIdEstimateGroup := AddParam;
    FIdOrFormatEstimate := AddParam;
    F.SetProp('id_or_format_estimates$i',FIdOrFormatEstimate);
    FPrefix := Q.QLoadValue('select prefix from or_format_estimates where id = :id$i', [FIdOrFormatEstimate]).AsString;
  end;
  if (Mode = fEdit) and not User.Role(rOr_R_StdItems_Set_Prices) then begin
    nedt_Price.ReadOnly := True;
    nedt_Price_PP.ReadOnly := True;
  end;
  SetRoute;
end;

procedure TFrmODedtOrStdItem.ControlOnChange(Sender: TObject);
begin
  if (A.InArray(TControl(Sender).Name, ['chb_R0', 'chb_Wo_Estimate'])) or (Copy(TControl(Sender).Name, 1, 6) = 'chb_r') then
    SetRoute;
  inherited;
end;

function TFrmODedtOrStdItem.VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean;
//проверим здесь моменты:
//если не задан маршрут, когда он должен быть
//если цена перепродажи больше общей
var
  i, j: Integer;
begin
  j := 0;
  for i := 0 to ComponentCount - 1 do
    if (Copy(Components[i].Name, 1, 6) = 'chb_r') and (TDBCheckBoxEh(Components[i]).Checked) then
      j := j + 1;
  for i := 0 to ComponentCount - 1 do
    if (Copy(Components[i].Name, 1, 6) = 'chb_r') then
      Cth.SetErrorMarker(TDBCheckBoxEh(Components[i]), TDBCheckBoxEh(Components[i]).Enabled and (j = 0));
  //цена перепродажи не должна быть больше общей цены
  Cth.SetErrorMarker(nedt_Price_PP, (nedt_Price_PP.Value > nedt_Price.Value) or (nedt_Price_PP.Value = null));
end;

function TFrmODedtOrStdItem.Save: Boolean;
//запись результатов в бд
//при изменении значения чекбокса Без сметы в режиме редактирования нам надо подправить смету после записи основной таблицы
//(если галка была снята, то загрузить пустую смету, если же галка поставлена, то смету просто удалить - будет требовать ввода в дальнешем)
//запись результатов в бд
//при изменении значения чекбокса Без сметы в режиме редактирования нам надо подправить смету после записи основной таблицы
//(если галка была снята, то загрузить пустую смету, если же галка поставлена, то смету просто удалить - будет требовать ввода в дальнешем)
var
  name, nameold, prefix, fields: string;
  i: Integer;
  Res: Integer;
begin
  Q.QBeginTrans(True);
  //сохраним основные данные
  Result := inherited;
  if not Result then begin
    Q.QRollbackTrans;
    Exit;
  end;
  if (Mode = fEdit) and (edt_name.Text <> FNameOld) then begin
    //если это редактирование и наименование изменилось - попробуем изменить его и в БД ИТМ (с учетом префикса)
    //получим префикс изедия
    prefix := '';
    if FIdEstimateGroup > 0 then
      prefix := Q.QLoadValue('select prefix from or_format_estimates where id = :id$i', [FIdEstimateGroup]);
    //старое и новое имя
    name := S.IIFStr(prefix <> '', prefix + '_', '') + Trim(edt_name.Text);
    nameold := S.IIFStr(prefix <> '', prefix + '_', '') + FNameOld;
    //проверим, есть ли уже в итм в продукции запись соответствующая новому имени
    Res := Q.QLoadValue('select count(1) from dv.nomenclatura where id_group = :ig_group$i and name = :name$s', [ItmGroups_Production_ID, name]);
    if Res = 0 then begin
      //если нет, то переименуем запись со старым именем в новое (если она естественно есть)
      Q.QExecSql('update dv.nomenclatura set name = :name$s, fullname = :fullname$s where id_group = :ig_group$i and name = :nameold$s', [name, name, ItmGroups_Production_ID, nameold]);
    end;
  end;
  if (Mode = fEdit) and (Cth.GetControlValue(chb_Wo_Estimate) <> FWoEstimateOld) then begin
    //если изменился признак "Без сметы", то удаляем смету
    //(в проверке перед записью спросит, если при этом была подгружена непустая смета)
    Orders.RemoveEstimateForStdItem(id, True);
  end;
  if (Mode = fEdit) then begin
    //утсановим в шаблонах цену и маршрут изделий, соответствующих данному
    var FieldsArr: TVarDynArray := ['price', 'price_pp', 'r0'];
    for i := 0 to High(RouteFields) do
      FieldsArr := FieldsArr + ['r' + IntToStr(i + 1)];
    var FiealdsVal: TVarDynArray := [];
    for i := 0 to High(FieldsArr) do
      FiealdsVal := FiealdsVal + [F.GetProp(FieldsArr[i].AsString)];
    Q.QExecSql(Q.QGetSql('Q', 'order_items', FieldsArr.Implode(';')) + ' where id_order < 0 and id_std_item = :id_std_item$i', FiealdsVal + [ID]);
  end;
  Result := Q.QCommitTrans;
end;


procedure TFrmODedtOrStdItem.VerifyBeforeSave;
var
  i, res1, res2, res3: Integer;
  NewEmptyEstimate: Boolean;
begin
  //проверки при редактировании или добавлении записи (только если изменилорсь наименование)
  //проверим, нет ли такого наименования среди стандартных изделий того же типа паспорта
  //также наименование с преиксом не должно быть в базе сметных наименований учета    //!!!
  //и также и в базе итм с типом "материалы и комплектующие"
  if (Mode <> fDelete) and (FIdEstimateGroup > 1) and (edt_name.Text <> FNameOld) then begin
    res1 := Q.QLoadValue('select count(1) from or_std_items where id <> :id$i and (id_or_format_estimates = :idf$i) and name = :name$s', [ID, FIdEstimateGroup, edt_name.Text]);
    //res2 := Q.QSelectOneRow('select count(1) from bcad_nomencl where name = :name$s', [Prefix + '_' + edt_name.Text])[0];
    res3 := Q.QLoadValue('select count(1) from dv.nomenclatura where id_nomencltype = 0 and name = :name$s', [FPrefix + '_' + edt_name.Text]);
    if res1 + res2 + res3 > 0 then begin
      MyWarningMessage(S.IIf(res1 > 0, 'Такое наименование уже существует в этой группе стандартных изделий Учета!'#13#10, '') +
          //S.IIf(res2 > 0, 'Такое наименование (с учетом префикса) уже существует в справочнике сметных позиций Учета!'#13#10, '') +
        S.IIf(res3 > 0, 'Такое наименование (с учетом префикса) уже есть в ИТМ среди номенклатуры типа "материалы и комплектующие"!'#13#10, '') + #13#10'Данные не могут быть сохранены!');
      HasError := True;
      Exit;
    end;
  end;
  if (Mode = fEdit) and (chb_Wo_Estimate.Checked) then begin
    NewEmptyEstimate := Q.QLoadValue('select count(1) from estimates where id_std_item = :id$i and isempty = 0', [id]) > 0;
    if NewEmptyEstimate then
      if MyQuestionMessage('Для этого изделия выбран тип "без сметы", но сейчас к нему уже подгружена непустая смета.'#13#10'Она будет удалена.'#13#10'Продолжить?') <> mrYes then begin
        HasError := True;
        Exit;
      end;
  end;
end;

procedure TFrmODedtOrStdItem.SetRoute;
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
  FIsRouteChanged := True;
end;

end.


