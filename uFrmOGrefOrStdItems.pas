{
справочник стандартных изделий
отображает стандартные изделия из группы, выбранной в комбобоксе в шапке
позволяет скопировать все изделия из другой группы
открывает диалоги редактирования, проверки, загрузки, просмотра и удаления сметы
в таблице позволяет редактировать цену
}
unit uFrmOGrefOrStdItems;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2, uFrmBasicInput
  ;

type
  TFrmOGrefOrStdItems = class(TFrmBasicGrid2)
    procedure FormDestroy(Sender: TObject);
    procedure Timer_AfterStartTimer(Sender: TObject);
  private
    //айди изделия, к которому будет автоматический переход
    ItemId: Integer;
    function  PrepareForm: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);  override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    procedure Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure SetCbEstimate;
    procedure CopyAllItems;
  public
    //открытие справочника, если он не открыт, на странице для нужного изделия и переход к его строке
    class procedure GoToItem(AId: integer);
  end;

var
  FrmOGrefOrStdItems: TFrmOGrefOrStdItems;

implementation

uses
  uWindows,
  uOrders,
  uFrmODedtOrStdItems
  ;

{$R *.dfm}

function TFrmOGrefOrStdItems.PrepareForm: Boolean;
begin
  FrmOGrefOrStdItems := Self;
  Caption:='Справочник стандартных изделий';
  Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['id_or_format_estimates','_id_format_est',''],
    ['wo_estimate','_wo_estimate',''],
    ['name','Наименование','500;h'],
    ['price$f','Цена','70','f=r','e=0:999999999:2',User.Role(rOr_R_StdItems_Ch)],
    ['price_pp$f','Перепродажа','70','f=r','e=0:999999999:2',User.Role(rOr_R_StdItems_Ch)],
    ['priceraw$f','Цена по смете','70','f=r'],
    ['route2','Производственный маршрут','120'],
    ['dt_estimate','Смета','75'],
    ['by_sgp','Учет по СГП','40','pic']
  ]);
  Frg1.Opt.SetTable('v_or_std_items');
  Frg1.Opt.SetWhere('where id_or_format_estimates = :id_or_format_estimates$i');
  Frg1.Opt.SetButtons(1,[[btnRefresh],[],[btnView],[btnEdit,User.Role(rOr_R_StdItems_Ch)],[btnAdd,1],[btnCopy,1],[btnDelete,1],[],
    [btnViewEstimate],[btnLoadEstimate,User.Role(rOr_R_StdItems_Estimate)],[-btnCopyEstimate,1,'Скопировать смету'],[-btnDeleteEstimate,1],[],
    [-btnCustom_RepOrStDItemsErr, True, 'Найти ошибки'],[],[btnGridSettings],[],[btnCtlPanel],[],[1000, User.Role(rOr_R_StdItems_Ch), 'Скопировать изделия из...', 'copy']]
  );
  Frg1.CreateAddControls('1', cntComboLK, 'Формат:', 'CbEstimate', '', 80, yrefC, 400);
  SetCbEstimate;
  Frg1.InfoArray:=[
    [Caption + '.'#13#10+
    'В верхней части в выпадающем списке выберете формат, для которого вы хотите просмотреть или редактировать стандартные изделия '#13#10+
    '(ети форматы должны быть предварительно настроены в справочнике Стандартные форматы паспортов).'#13#10+
    'С помощью кнопок или меню ПКМ откройте диалог для создания, изменения, копирования стандартных изделий,'#13#10+
    'и вводите их наименования и параметры.'#13#10+
    'Цены каждого изделия и цену перепродажи в его составе вы может редактировть не открывая диалога, а'#13#10+
    'непосредственно изменяя значение цены в ячейке таблицы'#13#10+
    '(цена перепродажи не может быть более цены изделия, а в случае дополнительной комплектации, обе цены равны).'#13#10+
    'Цена по смете рассчитывается по данным ИТМ (если в смете есть изделия, они не разворачиваются).'#13#10+
    'Наименования язделий не могут совпадать с наименованиями дополнительной комплектации, и не могут повторяться внутри одного формата.'#13#10+
    'В ИТМ изделия используются в качестве позиций заказа, и к ним добавляются префиксы, настроенные ранее в спрвочнике Стандартные форматы паспортов.'#13#10+
    'При переименовании изделия, в Учете позиции во всех ранее созданных заказах будут обновлены,'#13#10+
    'также программа в этом случае пытается переименовать данную номенклатурную позицию и в ИТМ.'#13#10
    ]
  ];
  Result := inherited;
end;

procedure TFrmOGrefOrStdItems.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if fMode <> fNone then begin
    if (S.NNum(Fr.GetControlValue('CbEstimate')) < 0)  then
      Exit;
    if Fr.IsEmpty and (fMode <> fAdd) then
      Exit;
if Fr.GetControlValue('CbEstimate') = 35 then                                             //!!!
TFrmODedtOrStdItems.Show(Self, 'dddd', [myfoDialog], fMode, Fr.ID, Fr.GetControlValue('CbEstimate'))
else
    Wh.ExecDialog(myfrm_Dlg_R_OrderStdItems, Self, [], fMode, Fr.ID, Fr.GetControlValue('CbEstimate'));
  end
  else if Tag = btnCustom_RepOrStDItemsErr then begin
    Wh.ExecReference(myfrm_Rep_OrderStdItems_Err)
  end
  else if Tag = btnCopyEstimate then begin
    Orders.CopyEstimateToBuffer(Fr.ID, null);
  end
  else if (Tag = btnViewEstimate) then begin
    //в справочнике стандартных изделий покажем смету (если это не группа общих изделий)
    if (Fr.GetCol > 0)and(Fr.GetValueI('id_or_format_estimates') > 0) then
      Wh.ExecReference(myfrm_R_Estimate, Self, [myfoDialog, myfoMultiCopyWoId, myfoSizeable, myfoEnableMaximize], VarArrayOf([null, Fr.ID]));
  end
  else if (Tag = btnLoadEstimate) then begin
    //в справочнике стандартных изделий загрузим смету (если это не группа общих изделий)
    if (Fr.GetCol > 0)and(Fr.GetValueI('id_or_format_estimates') > 0) then begin
      Orders.LoadBcadGroups(True);
      Orders.LoadEstimate(null, null, Fr.ID);
      Fr.RefreshGrid;
    end;
  end
  else if (Tag = btnDeleteEstimate) then begin
    //в справочнике стандартных изделий удалим смету (если это не группа общих изделий)
    if (Fr.GetCol > 0)and(Fr.GetValueI('id_or_format_estimates') > 0) then begin
      Orders.RemoveEstimateForStdItem(Fr.ID);
      Fr.RefreshGrid;
    end;
  end
  else if Tag = 1000 then begin
    CopyAllItems;
  end
  else
    inherited;
end;

procedure TFrmOGrefOrStdItems.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
  if Fr.IsPrepared then
    Fr.RefreshGrid;
end;

procedure TFrmOGrefOrStdItems.Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  Fr.SetSqlParameters('id_or_format_estimates$i', [Cth.GetControlValue(Fr, 'CbEstimate')]);
end;

procedure TFrmOGrefOrStdItems.FormDestroy(Sender: TObject);
begin
  inherited;
  FrmOGrefOrStdItems := nil;
end;

procedure TFrmOGrefOrStdItems.Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
begin
  //запишем цену (поля 'price', 'price_pp')
  Q.QCallStoredProc('P_SetStdItemPrice', 'IdStdItem$i;PriceNew$f;PriceType$i',
    [Fr.ID, S.NNum(Value), S.Decode([FieldName, 'price', 1, 2])]
  );
end;

procedure TFrmOGrefOrStdItems.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if (Fr.IsEmpty) or (Fr.GetControlValue('CbEstimate') = -1) then
    Exit;
  if Fr.GetControlValue('CbEstimate') = 0 then begin
    if FieldName <> 'name' then
      Params.Background := RGB(255, 150, 150);
    Exit;
  end;
  if (FieldName = 'dt_estimate') then
    if (Fr.GetValue('dt_estimate') = null)
      then Params.Background := clmyPink  //красный - не подгружена сметы
      else if (Fr.GetValueI('wo_estimate') = 1)
        then Params.Background := clmyYelow;  //желтый - смета пустая (не нужна)
end;

procedure TFrmOGrefOrStdItems.SetCbEstimate;
var
  i: Integer;
  st: string;
begin
  //комбобокс форматов в виде группа - подгруппа; 0 - общий формат
  Q.QLoadToDBComboBoxEh(
    'select f.name || '' ['' || e.name || '']'' as estimate, e.id as id '+
    'from or_formats f, or_format_estimates e '+
    'where e.id_format = f.id and e.active = 1 and f.active = 1 and ((e.id_format > 1)or(e.id_format = 0))'+
    'order by 1 asc',
    [], TDBComboBoxEh(Frg1.FindComponent('CbEstimate')), cntComboLK
  );
  TDBComboBoxEh(Frg1.FindComponent('CbEstimate')).ItemIndex:=0;  //нужно в случае первого запуска у пользователя, если значение комбобокса не чиатеся из бд, или он был очищен перед закрытием журнала
end;

procedure TFrmOGrefOrStdItems.Timer_AfterStartTimer(Sender: TObject);
begin
  inherited;
  if ItemId = 0 then
    Exit;
  FrmOGrefOrStdItems.Frg1.DbGridEh1.SetFocus;
  FrmOGrefOrStdItems.Frg1.MemTableEh1.Locate('id', ItemId, []);
end;

class procedure TFrmOGrefOrStdItems.GoToItem(AId: integer);
//открытие справочника, если он не открыт, на странице для нужного изделия и переход к его строке
var
  va: TVarDynArray;
begin
  if AID = null then
    Exit;
  //получим группу стд изделий по его айди, если не найдено или это нестандарт (0) - выйдем
  va := Q.QSelectOneRow('select id_or_format_estimates from or_std_items where id = :id$i', [AId]);
  if S.NNum(va[0]) = 0 then
    Exit;
  if FrmOGrefOrStdItems = nil then
    Wh.ExecReference(myfrm_R_OrderStdItems);
  FrmOGrefOrStdItems.Frg1.SetControlValue('CbEstimate', va[0]);
  FrmOGrefOrStdItems.ItemId := AId;
  FrmOGrefOrStdItems.Frg1.DbGridEh1.SetFocus;
  FrmOGrefOrStdItems.Frg1.MemTableEh1.Locate('id', AID, []);
end;

procedure TFrmOGrefOrStdItems.CopyAllItems;
var
  va, vak, vav: TVarDynArray;
  va2, va3: TVarDynArray2;
  i, j, gr: Integer;
  Fields: string;
begin
  gr := S.NInt(Frg1.GetControlValue('CbEstimate'));
  if gr <= 1 then
    Exit;  //для нестандарных изделия (формат Общий) и Доп комплектации копирование недопустимо
  va2 := Q.QLoadToVarDynArray2('select f.name || '' ['' || e.name || '']'' as estimate, e.id as id ' + 'from or_formats f, or_format_estimates e ' + 'where e.id_format > 1 and e.id_format = f.id and e.active = 1 and f.active = 1 ' + 'and e.id <>:id$i ' + 'order by 1 asc', [gr]);
  va := [];
  vak := [];
  vav := [];
  for i := 0 to High(va2) do begin
    vav := vav + [va2[i][0]];
    vak := vak + [va2[i][1]];
  end;
  if Length(vav) = 0 then
    Exit;
  if TFrmBasicInput.ShowDialog(Self, '', [], fAdd, '~Скопировать стандартные изделия', 300, 80,
   [[cntComboLK, 'Источник', '1:400:0', 210]], [VarArrayOf([vak[0], VarArrayOf(vav), VarArrayOf(vak)])], va, [['']], nil) >= 0 then begin
    Fields := 'id$i;id_or_format_estimates$i;name$s;r1$i;r2$i;r3$i;r4$i;r5$i;r6$i;r7$i;r8$i;r9$i;resale$i;price$f;price_pp$f;setofpan$i';
    if MyQuestionMessage('Будут скопированы изделия из справочника'#13#10 + '"' + vav[A.PosInArray(va[0], vak)] + '"'#13#10 + '(кроме тех, что уже существуют).'#13#10'Продолжить?') <> mrYes then
      Exit;
    va2 := Q.QLoadToVarDynArray2(Q.QSIUDSql('A', 'or_std_items', Fields) + ' where id_or_format_estimates = :ide$i', [va[0]]);
    for i := 0 to High(va2) do begin
      j := Q.QSelectOneRow('select count(*) from or_std_items where lower(name) = lower(:name$s) and id_or_format_estimates = :ide$i', [va2[i][2], gr])[0];
      if j > 0 then
        Continue;
      va2[i][1] := gr;
      Q.QIUD('i', 'or_std_items', '', Fields, TVarDynArray(va2[i]));
      Frg1.RefreshGrid;
    end;
  end;
end;


end.
