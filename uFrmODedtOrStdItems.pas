unit uFrmODedtOrStdItems;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2, uFrmBasicInput, uFields,
  uFrmBasicDbDialog, Vcl.Mask
  ;

type
  TFrmODedtOrStdItems = class(TFrmBasicDbDialog)
    E_Name: TDBEditEh;
    Chb_R0: TDBCheckBoxEh;
    Chb_Wo_Estimate: TDBCheckBoxEh;
    Ne_Price: TDBNumberEditEh;
    Ne_Price_PP: TDBNumberEditEh;
    Chb_by_sgp: TDBCheckBoxEh;
    Cb_type_of_semiproduct: TDBComboBoxEh;
    Cb_id_or_format_estimates: TDBComboBoxEh;
  private
    FRcount: Integer;
    FNameOld : string;
    FWoEstimateOld: Integer;
    FIdEstimate: Variant;
    FPrefix: string ;
    FIsRouteChanged: Boolean;
function  Prepare: Boolean; override;
    function  Load: Boolean; override;
    procedure ControlOnExit(Sender: TObject); override;
    procedure ControlOnChange(Sender: TObject); override;
    function  VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean; override;
  protected
    procedure VerifyBeforeSave; override;
    function  Save: Boolean; override;
    procedure SetRoute;
  public
  end;

var
  FrmODedtOrStdItems: TFrmODedtOrStdItems;

implementation

 uses
   uOrders
   ;

 {$R *.dfm}

function TFrmODedtOrStdItems.Prepare: Boolean;
var
  i, j: Integer;
  va: TVarDynArray;
  va1, va2: TVarDynArray2;
begin
  Caption:='Стандартное изделие';

  va1 := Q.QLoadToVarDynArray2('select code, id from work_cell_types where pos is not null order by pos', []);

  for i:=0 to High(va1) do begin
    Cth.CreateControls(PMDIClient, cntCheck, va1[i][0], 'Chb_r_' + S.NSt(va1[i][1]), '', 0, E_Name.Left + i * 50, E_Name.Top + E_Name.Height + MY_FORMPRM_H_EDGES);
    va2 :=  va2 + [['Chb_r_' + S.NSt(va1[i][1]) + ';0;0']];
  end;

  va2 := [
    ['id$i'],
    ['id_or_format_estimates$i'],
    ['name$s','V=1:400::T'],
    ['price$f','V=0:9999999:2:n'],
    ['price_pp$f','V=0:9999999:2:n'],
    ['wo_estimate$i'],
    ['r0$i'],
    ['by_sgp$i']
  ] ;//+ va2;


  F.DefineFields:=va2;
  View := 'or_std_items';
  Table := 'or_std_items';
  FOpt.UseChbNoClose:= True;
  //Opt.RequestWhereClose:= cqYNC;
  FOpt.InfoArray:= [
    ['Ввод параметров стандартного изделия.'#13#10+
     ''#13#10
    ]
  ];
  Result := inherited;
  if Mode <> fDelete then begin
    FNameOld := S.NSt(F.GetPropB('name'));
    FWoEstimateOld:=S.NInt(F.GetPropB('wo_estimate'));
    FIdEstimate := AddParam;;
    FPrefix := S.NSt(Q.QSelectOneRow('select prefix from or_format_estimates where id = :id$i', [FIdEstimate])[0]);
  end;
  SetRoute;
end;

function  TFrmODedtOrStdItems.Load: Boolean;
var
  i, j: Integer;
  va2 : TVarDynArray2;
begin
  Result := inherited;
  if not Result then Exit;
  va2:=Q.QLoadToVarDynArray2('select id_work_cell_type from or_std_item_route where id_or_std_item = :id$i', [ID]);
  FRcount := High(va2);
  for i:=0 to High(va2) do
    TDBCheckBoxEh(Self.FindComponent('Chb_r_' + S.NSt(va2[i][0]))).Checked  := True;
end;


procedure TFrmODedtOrStdItems.ControlOnExit(Sender: TObject);
begin
  inherited;
end;

procedure TFrmODedtOrStdItems.ControlOnChange(Sender: TObject);
begin
  if (A.InArray(TControl(Sender).Name, ['Chb_R0', 'Chb_Wo_Estimate'])) or (Copy(TControl(Sender).Name, 1, 6) = 'Chb_r_') then
    SetRoute;
  inherited;
end;

function TFrmODedtOrStdItems.VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean;
//проверим здесь моменты:
//если не задан маршрут, когда он должен быть
//если цена перепродажи больше общей
var
  i, j: Integer;
begin
  j := 0;
  for i := 0 to ComponentCount - 1 do
    if (Copy(Components[i].Name, 1, 6) = 'Chb_r_') and (TDBCheckBoxEh(Components[i]).Checked) then
      j := j + 1;
  for i := 0 to ComponentCount - 1 do
    if (Copy(Components[i].Name, 1, 6) = 'Chb_r_') then
      Cth.SetErrorMarker(TDBCheckBoxEh(Components[i]), TDBCheckBoxEh(Components[i]).Enabled and (j = 0));
  //цена перепродажи не должна быть больше общей цены
  Cth.SetErrorMarker(Ne_Price_PP, (Ne_Price_PP.Value > Ne_Price.Value) or (Ne_Price_PP.Value = null));
end;

function TFrmODedtOrStdItems.Save: Boolean;
//запись результатов в бд
//при изменении значения чекбокса Без сметы в режиме редактирования нам надо подправить смету после записи основной таблицы
//(если галка была снята, то загрузить пустую смету, если же галка поставлена, то смету просто удалить - будет требовать ввода в дальнешем)
var
  name, nameold, prefix: string;
  i: Integer;
  Res: Integer;
begin
  Q.QBeginTrans(True);
  repeat
  //сохраним основные данные
    Result := inherited;
    if (Mode <> fDelete) and FIsRouteChanged then begin
      Q.QExecSql('delete from or_std_item_route where id_or_std_item = :id$i', [ID]);
      for i := 0 to ComponentCount - 1 do
        if (Copy(Components[i].name, 1, 6) = 'Chb_r_') and (TDBCheckBoxEh(Components[i]).Checked) then
          Q.QExecSql('insert into or_std_item_route (id_or_std_item, id_work_cell_type) values (:ido$i, :idt$i)', [ID, Copy(Components[i].name, 7)])
    end;
    if (Mode = fEdit) and (E_Name.Text <> FNameOld) then begin
    //если это редактирование и наименование изменилось - попробуем изменить его и в БД ИТМ (с учетом префикса)
    //получим префикс изедия
      prefix := '';
      if FIdEstimate > 0 then
        prefix := Q.QSelectOneRow('select prefix from or_format_estimates where id = :id$i', [FIdEstimate])[0];
    //старое и новое имя
      name := S.IIFStr(prefix <> '', prefix + '_', '') + Trim(E_Name.Text);
      nameold := S.IIFStr(prefix <> '', prefix + '_', '') + FNameOld;
    //проверим, есть ли уже в итм в продукции запись соответствующая новому имени
      Res := Q.QSelectOneRow('select count(1) from dv.nomenclatura where id_group = :ig_group$i and name = :name$s', [ItmGroups_Production_ID, name])[0];
      if Res = 0 then begin
      //если нет, то переименуем запись со старым именем в новое (если она естественно есть)
        Result := Q.QExecSql('update dv.nomenclatura set name = :name$s, fullname = :fullname$s where id_group = :ig_group$i and name = :nameold$s', [name, name, ItmGroups_Production_ID, nameold]) >= 0;
      end;
    end;
    if not Result then
      Break;
    if (Mode = fEdit) and (Cth.GetControlValue(Chb_Wo_Estimate) <> FWoEstimateOld) then begin
    //если изменился признак "Без сметы", то удаляем смету
    //(в проверке перед записью спросит, если при этом была подгружена непустая смета)
      Result := Orders.RemoveEstimateForStdItem(id, True);
    end;
    if (Mode = fEdit) then begin
    //утсановим в шаблонах цену и маршрут изделий, соответствующих данному
      Result := Q.QExecSql('update order_items set ' + 'price = :price$f, price_pp = :price_pp$f ' + 'where id_order < 0 and id_std_item = :id_std_item$i', [Ne_Price.Value, Ne_Price_PP.Value, ID]) >= 0;
      if Result then begin
{      Result:= Q.QExecSql(
        'update order_items set '+
        'r0 = :r0$i, r1 = :r1$i, r2 = :r2$i, r3 = :r3$i, r4 = :r4$i, r5 = :r5$i, r6 = :r6$i, r7 = :r7$i '+
        'where id_order < 0 and id_std_item = :id_std_item$i and nvl(sgp, 0) <> 1',
        [Cth.GetControlValue(Chb_R0),Cth.GetControlValue(Chb_R1),Cth.GetControlValue(Chb_R2),Cth.GetControlValue(Chb_R3),
         Cth.GetControlValue(Chb_R4),Cth.GetControlValue(Chb_R5),Cth.GetControlValue(Chb_R6),Cth.GetControlValue(Chb_R7),
         ID
        ]
      ) >= 0;}
      end;
    end;
  until True;
  Q.QCommitOrRollback(Result);
end;


procedure TFrmODedtOrStdItems.VerifyBeforeSave;
var
  i, res1, res2, res3: Integer;
  NewEmptyEstimate: Boolean;
begin
  //проверки при редактировании или добавлении записи (только если изменилорсь наименование)
  //проверим, нет ли такого наименования среди стандартных изделий того же типа паспорта
  //также наименование с преиксом не должно быть в базе сметных наименований учета    //!!!
  //и также и в базе итм с типом "материалы и комплектующие"
  if (Mode <> fDelete) and (FIdEstimate > 1) and (E_Name.Text <> FNameOld) then begin
    res1 := Q.QSelectOneRow('select count(1) from or_std_items where id <> :id$i and (id_or_format_estimates = :idf$i) and name = :name$s', [ID, FIdEstimate, E_Name.Text])[0];
    //res2 := Q.QSelectOneRow('select count(1) from bcad_nomencl where name = :name$s', [Prefix + '_' + E_Name.Text])[0];
    res3 := Q.QSelectOneRow('select count(1) from dv.nomenclatura where id_nomencltype = 0 and name = :name$s', [FPrefix + '_' + E_Name.Text])[0];
    if res1 + res2 + res3 > 0 then begin
      MyWarningMessage(S.IIf(res1 > 0, 'Такое наименование уже существует в этой группе стандартных изделий Учета!'#13#10, '') +
          //S.IIf(res2 > 0, 'Такое наименование (с учетом префикса) уже существует в справочнике сметных позиций Учета!'#13#10, '') +
        S.IIf(res3 > 0, 'Такое наименование (с учетом префикса) уже есть в ИТМ среди номенклатуры типа "материалы и комплектующие"!'#13#10, '') + #13#10'Данные не могут быть сохранены!');
      HasError := True;
      Exit;
    end;
  end;
  if (Mode = fEdit) and (Chb_Wo_Estimate.Checked) then begin
    NewEmptyEstimate := Q.QSelectOneRow('select count(1) from estimates where id_std_item = :id$i and isempty = 0', [id])[0] > 0;
    if NewEmptyEstimate then
      if MyQuestionMessage('Для этого изделия выбран тип "без сметы", но сейчас к нему уже подгружена непустая смета.'#13#10'Она будет удалена.'#13#10'Продолжить?') <> mrYes then begin
        HasError := True;
        Exit;
      end;
  end;
end;


procedure TFrmODedtOrStdItems.SetRoute;
var
  i: Integer;
begin
  if Mode in [fDelete, fView] then
    Exit;
  if (Cth.GetControlValue(Chb_Wo_Estimate) = 1) or (Cth.GetControlValue(Chb_R0) = 1) then
    for i := 0 to ComponentCount - 1 do
      if Copy(Components[i].Name, 1, 6) = 'Chb_r_' then begin
        TDBCheckBoxEh(Components[i]).Checked := False;
        TDBCheckBoxEh(Components[i]).Enabled := False;
      end;
  if (Cth.GetControlValue(Chb_Wo_Estimate) = 0) and (Cth.GetControlValue(Chb_R0) = 0) then
    for i := 0 to ComponentCount - 1 do
      if Copy(Components[i].Name, 1, 6) = 'Chb_r_' then begin
        TDBCheckBoxEh(Components[i]).Enabled := True;
      end;
  FIsRouteChanged := True;
end;




end.
