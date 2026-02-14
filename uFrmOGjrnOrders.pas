unit uFrmOGjrnOrders;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uData, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2
  ;

type
  TFrmOGjrnOrders = class(TFrmBasicGrid2)
  private
    function  OpenFromTemplate: Integer;
    procedure ViewInfo1;
  protected
    function  PrepareForm: Boolean; override;
    procedure LoadKnsAndThnList;
    //события первого (основного) фрейма грида
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    function  Frg1OnFilterExecute(var Fr: TFrDBGridEh; const No: Integer; var Handled: Boolean): string; override;
    procedure Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); override;
    procedure Frg1RowDetailPanelShow(var Fr: TFrDBGridEh; const No: Integer; var Hnadled: Boolean; var CanShow: Boolean); override;
    //события второго (детального) фрейма грида
    procedure Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure Frg2ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg2ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure Frg2SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    procedure Frg2GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); override;

  public
  end;

var
  FrmOGjrnOrders: TFrmOGjrnOrders;

implementation

uses

  uSys,
  uForms,
  uDBOra,
  uString,
  uMessages,
  uWindows,
  uOrders,
  uFrmOWOrder,
  D_Order_UPD,
  uPrintReport,
  D_OrderPrintLabels,
  uFrmOGrefOrStdItems,
  uFrmXDedtGridFilter,
  uFrmBasicInput
  ;


{$R *.dfm}

function TFrmOGjrnOrders.PrepareForm: Boolean;
var
  c : TComponent;
  va2: TVarDynArray2;
begin
  Caption:='Журнал заказов';
  Frg1.Options := Frg1.Options {- [myogsaveoptions]} + [myogIndicatorCheckBoxes, myogMultiSelect, myogGridLabels, myogRowDetailPanel, myogLoadAfterVisible];
  Frg1.Opt.SetFields([
    ['id$i','_id','d=40'],
    ['id_itm$i','_id_itm','40'],
    ['has_itm_est$i','_has_itm_est','40'],
    ['path$s','_path','40'],
    ['in_archive$i','_in_archive','20','pic='],
    ['dt_beg$d','Дата создания',''],
    ['ornum$s','№ заказа','80','bt=Открыть папку заказа:4;Регламент:36'],
    ['area_short$s','Площадка','20'],
    ['typename$s','Вид заказа','80'],
    ['organization$s','Организация','100'],
    ['customer$s','Заказчик','150'],
    ['project$s','Проект','150'],
    ['address$s','Адрес отгрузки','250'],
    ['dt_otgr$d','Отгрузка (план)',''],
    ['managername$s','Менеджер','100'],
    ['to_kns$i','Конструктор',''],
    ['to_thn$i','Технолог',''],
    ['dt_kns_max','Документы КНС',''],
    ['dt_thn_max','Документы ТХН',''],
    ['estimates$i','Смета','30', 'pic=-;+:6;7', True],
    ['xml_status$i','XML','30', 'pic=-;+:6;7'],
    ['dt_estimate_max$d','Изменение сметы',''],
    ['dt_reserve$d','Дата резервирования'],
    ['dt_aggr_estimate$d','Общая смета',''],
    ['status_itm$s', 'Статус заказа','80'],
    ['qnt_slashes$i', 'Кол-во слэшей', '80','f=:'],
    ['qnt_items$f', 'Кол-во изделий', '80','f=:'],
    ['qnt_in_prod$f', 'Кол-во изделий в производстве', '80','f=:'],
    ['dt_to_prod$d','Запущен в производство',''],
    ['qnt_to_sgp$f', 'Кол-во изделий, принятых на СГП', '80','f=:'],
    ['dt_to_sgp$d','Принят на СГП',''],
    ['dt_from_sgp$d','Отгружен',''],
    ['dt_end_manager$d','Завершение менеджером','','chbt=+', 'e',User.Roles([], [rOr_D_Order_SetCompletedM, rOr_D_Order_SetCompletedMA])],
    ['cancel$i','Заказ отменен','80','chb=6;0','f=#:#0','e', User.Role(rOr_D_Order_SetCanceled)],
    ['dt_end$d','Заказ закрыт','','chbt=+','e', User.Role(rOr_D_Order_SetCompleted) or User.Role(rOr_D_Order_SetUnCompleted)],
    ['early_or_late$i','Опережение / просрочка','70'],
    ['qnt_boards_m2$f','Плитные, м2','80', 'f=f:'],
    ['qnt_edges_m$f','Кромка, п.м.','80', 'f=f:'],
    ['qnt_panels_w_drill_all$i','Сверловка, панелей','80', 'f=f:'],
    ['dt_upd_reg','Регистрация УПД','', 'bt=Ввод УПД', User.Role(rOr_D_Order_EnteringUPD), 'bt=Просмотр УПД', not User.Role(rOr_D_Order_EnteringUPD)],
    ['dt_upd','Дата УПД',''],
    ['upd','Номер УПД','80'],
    ['pay$f','Оплачено','f=r:','null',not User.Role(rOr_J_Orders_Payments_V)],
    ['pay_n$f','Промежуточная оплата','f=r:','null',not User.Role(rOr_J_Orders_PaymentsN_V)],
    ['account$s','Счет','100'],
    ['cost_i_wo_nds$f','Стоимость изделий','80','f=r:','t=1'],
    ['cost_i_nosgp_wo_nds$f','Стоимость в производстве','f=r:','80','t=1'],
    ['cost_a_wo_nds$f','Стоимость доп. компл','80','f=r:','t=1'],
    ['cost_d_wo_nds$f','Стоимость доставки','80','f=r:','t=1'],
    ['cost_m_wo_nds$f','Стоимость монтажа','80','f=r:','t=1'],
    ['cost_wo_nds$f','Сумма заказа','80','f=r:','t=1'],
    ['cost$f','Сумма заказа с НДС','80','f=r:','t=1'],
    ['sum0$f','Себестоимость','80','f=r:','t=2','null'],
    ['comm$s','Дополнение','200']
//    ['','',''],
  ]);
  Frg1.Opt.SetTable('v_orders_list');
  Frg1.Opt.SetWhere('where id > 0');
  Frg1.CreateAddControls('1', cntCheck, 'Только незакрытые', 'ChbNoClosed', '', 4, yrefT, 200);
  Frg1.CreateAddControls('1', cntCheck, 'В производстве', 'ChbInProd', '', 4, yrefB, 200);
  //просроченные заказы - работают как радиобаттоны со снятием (-11)
  Frg1.CreateAddControls('1', cntCheck, 'Просроченные заказы', 'ChbFilter1', '', 4 + 130 + 4, yrefT, 200, -11);
  Frg1.CreateAddControls('1', cntCheck, 'Просроченные заказы + 7д', 'ChbFilter2', '', 4 + 130 + 4, yrefB, 200, -11);
  Frg1.CreateAddControls('1', cntCheck, 'Показать суммы', 'ChbViewSum', '', 310, yrefC, 200);

  Frg1.Opt.SetButtons(1, [
   [mbtRefresh], [],
   [mbtView], [mbtEdit, User.Role(rOr_D_Order_Ch)], [mbtAdd, 1], [mbtCopy, 1], [mbtCustom_OrderFromTemplate, 1], [mbtDelete, User.Role(rOr_D_Order_Del)], [],
   [mbtViewEstimate], [mbtLoadEstimate, User.Role(rOr_D_Order_Estimate)], [-mbtCustom_CreateAggregateEstimate, 1], [-1001, True, 'Пересчитать данные для производства'], [],
   [-mbtCustom_SendSnDocuments, User.Role(rOr_D_Order_AttachSnDocuments)], [],
   [-mbtCustom_OrToDevel, User.Role(rOr_J_Orders_ToDevel)],[-1004, User.Role(rOr_J_Orders_ToDevelThn), 'Добавить в журнал проверки'],
   [],
   [mbtTest, User.IsDeveloper],
   [mbtDividorM], [mbtPrint], [mbtPrintPassport], [mbtPrintLabels], [mbtDividorM], [],
   [mbtGridFilter], [], [mbtGridSettings], [], [mbtCtlPanel]
  ]);
  Frg1.Opt.SetButtonsIfEmpty([mbtCustom_OrderFromTemplate]);

//  Frg1.Opt.FilterRules := [[], ['dt_beg;dt_end'], ['Только производственные', 'prod'], ['Тест', '', True], ['Тест2'], ['ТТТТТТТТ', False]];
  Frg1.Opt.FilterRules := [[], ['dt_beg;dt_otgr;dt_end'], ['Показать себестоимость', 'Sum0', User.Role(rOr_J_Orders_Sum)]];

  Frg2.Options := Frg2.Options + [myogIndicatorCheckBoxes, myogMultiSelect];
  Frg2.Opt.SetFields([
    ['id$i','_id','40'],
    ['id_std_item$i','_id_std_item','40'],
    ['id_itm$i','_id_itm','40'],
    ['has_itm_est$i','_has_itm_est','40'],
    ['slash','№','100'],
    ['fullitemname','Изделие','200'],
    ['qnt','Количество','80'],
    ['qnt_in_prod$f', 'Кол-во изделий в производстве', '80','f=:'],
    ['qnt_to_sgp$f', 'Кол-во изделий, принятых на СГП', '80','f=:'],
    ['route2','Маршрут','120'],
    //['kns','Конструктор','120'],
    ['id_kns','Конструктор','120;L','e',(User.GetJobID = myjobKNS) or (User.GetJobID = myjobTHN) or User.IsDeveloper],
    //['thn','Технолог','120'],
    ['id_thn','Технолог','120;L','e',(User.GetJobID = myjobKNS) or (User.GetJobID = myjobTHN) or User.IsDeveloper],
    ['dt_estimate','Смета','80'],
    ['is_xml_loaded','XML','40','pic=0;1;2:6;7;12'],
    ['sgp','С СГП','40','pic'],
    ['nstd','Нестандарт','40','pic'],
    ['disassembled','В разборе','40','pic'],
    ['control_assembly','Контр. сборка','40','pic'],
    ['dt_kns','Документы КНС','80'],
    ['wo_kns','_wo_kns','40'],
    ['dt_thn','Документы ТХН','80'],
    ['qnt_boards_m2$f','Плитные, м2','80', 'f=f:'],
    ['qnt_edges_m$f','Кромка, п.м.','80', 'f=f:'],
    ['qnt_panels_w_drill_all$i','Сверловка, панелей','80', 'f=f:'],
    ['cost_wo_nds$f','Сумма','80','f=r:','t=1'],
    ['sum0$f','Себестоимость','80','f=r:','t=2','null'],
    ['comm$s','Дополнение','200']
  ]);
  Frg2.Opt.SetTable('v_order_items');
  Frg2.Opt.SetWhere('where id_order = :id_order$i and qnt > 0 order by slash');
  Frg2.Opt.SetButtons(1, [
    [mbtRefresh], [], [mbtViewEstimate], [mbtLoadEstimate, User.Role(rOr_D_Order_Estimate)], [-mbtCopyEstimate, True, 'Скопировать смету в буфер'],
    [],[-1002, (User.GetJobID = myjobKNS) or (User.GetJobID = myjobTHN) or User.IsDeveloper, 'Прикрепить документы КНС'],
    [],[-mbtCustom_Order_AttachThnDoc, User.Role(rOr_D_Order_AttachThnDocuments)],
    [],[-1003, (User.GetJobID = myjobKNS) or (User.GetJobID = myjobTHN) or User.IsDeveloper, 'Загрузить XML'],
     {[-mbtCustom_OrderSetAllSN, User.Role(rOr_D_Order_SetSn)], }
    [],[-mbtCustom_OrToDevel, User.Role(rOr_J_Orders_ToDevel)],[-1004, User.Role(rOr_J_Orders_ToDevelThn), 'Добавить в журнал проверки'],
    [],[-1001, True, 'Переход к стандартному изделию'],
    [], [mbtGridSettings], [-mbtTest, User.IsDeveloper]
  ]);


  Frg1.ReadControlValues;
  if not (User.Role(rOr_J_Orders_Sum)or(User.Role(rOr_J_Orders_PrimeCost))) then begin
    Cth.SetControlValue(TDBCheckBoxEh(Frg1.FindComponent('ChbViewSum')), 0);
    TDBCheckBoxEh(Frg1.FindComponent('ChbViewSum')).Enabled := False;
    Frg1.Opt.SetColFeature('1', 'null', True, False);
    Frg2.Opt.SetColFeature('1', 'null', True, False);
  end;
  Frg1.Opt.SetColFeature('1', 'i', Cth.GetControlValue(Frg1, 'ChbViewSum') = 0, False);
  Frg2.Opt.SetColFeature('1', 'i', Cth.GetControlValue(Frg1, 'ChbViewSum') = 0, False);

  Frg1.InfoArray:=[
    [Caption + '.'#13#10]
  ];

  Result := inherited;
end;


{основной грид}

procedure TFrmOGjrnOrders.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
var
  va1: TVarDynArray;
  va2: TVarDynArray2;
  st, st1: string;
  i, j: Integer;
begin
  if Tag = mbtTest then begin
    TFrmOWOrder.Show( Self, '_order', [myfodialog, myfoSizeable, myfoEnableMaximize], fEdit, Fr.ID, null);
{    Fr.setstate(null, True, 'wqdwqsdfwefsdfsdfgsdgsdfgdfsgdfsgsdfgdfgdfgfd');exit;
//    Fr.MemTableEh1.Close;
    Fr.Opt.SetColFeature('estimates', 'pic=+;1', True, True);
    Fr.Opt.SetColFeature('upd', 'bt', False, False);
    Fr.Opt.SetColFeature('dt_end_manager', 'chbt', False, False);
    Fr.Opt.SetColFeature('pay', 'f=#.000:', True, True);}
  end
{ else if (Tag = mbtRefresh) then begin
    //если этот флаг установлен, то при закрытии перечитывается строка, но в итоге
    //при обновлении всей таблицы при открытой доп. панеле происходит зависание
    InRowPanelDataChanged:=False;
    inherited;
//    SetColumnsVisible;
    Exit;
  end}
  else if Tag = mbtCustom_OrToDevel then begin
    Orders.OrderItemsToDevel(Fr.ID, null, 1);
  end
  else if Tag = 1004 then begin
    Orders.OrderItemsToDevel(Fr.ID, null, 2);
  end
  else if Tag = mbtViewEstimate then begin
    //просмотр общей сметы по одному или нескольким (отмеченным чекбоксами в индикаторе) заказам
    va1:=A.VarDynArray2ColToVD1(Gh.GetGridArrayOfChecked(Fr.DBGridEh1, -1), 0);
    if (Length(va1) = 0)
      then Wh.ExecReference(myfrm_R_AggEstimate, Self, [myfoDialog, myfoMultiCopyWoId, myfoSizeable, myfoEnableMaximize], VarArrayOf([Fr.ID]))
      else Wh.ExecReference(myfrm_R_AggEstimate, Self, [myfoDialog, myfoMultiCopyWoId, myfoSizeable, myfoEnableMaximize], va1);
  end
  else if Tag = mbtPrintPassport then begin
    PrintReport.pnl_Order(Fr.ID);
  end
  else if (Tag = mbtCustom_OrderFromTemplate) then begin
    //заказ из шаблона
    OpenFromTemplate;
  end
  else if (Tag = mbtLoadEstimate) then begin
    //обновление смет по всем изделиям, обновляются на стандартные изделия по данным справочника, на нестандартные,
    //если смета уже есть то пересчитывается количество
    if Orders.IsOrderFinalized(Fr.ID) > 0 then
      Exit;
    if MyQuestionMessage('Загрузить/обновить сметы по всем изделиям заказа ' + Fr.GetValue('ornum') + '?') <> mrYes then
      Exit;
    Fr.BeginOperation;
    Orders.RefreshEstimatesAndSyncWithITM(Fr.ID, [], True);
    Fr.EndOperation;
    Fr.RefreshRecord;
  end
  else if (Tag = mbtCustom_SendSnDocuments) then begin
    //отправить документы на снабжение
    if Orders.IsOrderFinalized(Fr.ID) > 0 then
      Exit;
    Orders.TaskForSendSnDocuments(Fr.ID, null);
    Fr.RefreshRecord;
  end
  else if (Tag = mbtPrintLabels) then begin
    Dlg_OrderPrinTLabels.ShowDialog(Fr.ID);
  end
  else if (Tag = mbtCustom_CreateAggregateEstimate) then begin
    Orders.CreateAggregateEstimate(Fr.ID, 0);
  end
  else if (Tag = mbtCustom_CreateCompleteEstimate) then begin
    Orders.CreateAggregateEstimate(Fr.ID, 1);
  end
  else if (Tag = 1001) then begin
    Q.QBeginTrans(True);
    Q.QCallStoredProc('P_SetOrderProdData', ':id$i', [Fr.ID]);
    Q.QCommitOrRollback(True);
    Fr.RefreshRecord;
  end
  else if Fmode <> fNone then begin
    //диалог ввода заказа
    Wh.ExecDialog(myfrm_Dlg_Order, Self, [], fMode, Fr.ID, null);
  end
  else Inherited;
end;

procedure TFrmOGjrnOrders.Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
  if not Fr.RefreshRecord then
    Exit;
  if Fr.CurrField = 'dt_end' then begin
    if Orders.FinalizeOrder(Fr.id, myOrFinalizeManual, 2, False) = 1
      then Fr.RefreshRecord;
  end
  else if Fr.CurrField = 'dt_end_manager' then begin
    if Orders.FinalizeOrderM(Fr.id) = 1
      then Fr.RefreshRecord;
  end
  else if Fr.CurrField = 'dt_upd_reg' then begin
    if Dlg_Order_UPD.ShowDialog(Fr.id)
      then Fr.RefreshRecord;
  end
  else if Fr.CurrField = 'ornum' then begin
    if TCellButtonEh(Sender).Hint = 'Регламент' then
      Wh.ExecDialog(myfrm_Dlg_Rep_OrderReglament, Self, [], fNone, Fr.ID, null)
    else
      //откроем папку заказа
      Sys.ExecFile(Module.GetPath_Order(IntToStr(YearOf(Fr.GetValue('dt_beg'))), Fr.GetValue('in_archive')) + '\' + Fr.GetValue('path'));
  end
  else inherited;
end;

procedure TFrmOGjrnOrders.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
end;

function  TFrmOGjrnOrders.Frg1OnFilterExecute(var Fr: TFrDBGridEh; const No: Integer; var Handled: Boolean): string;
begin
end;

procedure TFrmOGjrnOrders.Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  if (Cth.GetControlValue(Fr, 'ChbFilter1') = 1) or (Cth.GetControlValue(Fr, 'ChbFilter2') = 1) then begin
    //фильтр просроченных заказов - не учитываем остальные параметры фильтрации!
    SqlWhere := 'dt_end is null and dt_to_sgp is null and dt_from_sgp is null and to_thn is not null and dt_otgr >= :dt1$d and dt_otgr <= :dt2$d';
    Fr.SetSqlParameters('dt1$d;dt2$d', [IncMonth(Date, -2), IncDay(Date, S.IIf(Cth.GetControlValue(Fr, 'ChbFilter2') = 1, +7, +0))]);
  end;
  //только незакрытые заказы
  //сформируем фильтр по факту завершения заказа, и по диапозону для даты оформления
  SqlWhere := A.ImplodeNotEmpty([
    S.IIfStr(Cth.GetControlValue(Fr, 'ChbNoClosed') = 1, 'dt_end is null'),
    S.IIfStr(Cth.GetControlValue(Fr, 'ChbInProd') = 1, 'qnt_in_prod <> 0'),
    SqlWhere
    ]
    , ' and '
  );
  Frg1.Opt.SetColFeature('1', 'i', Cth.GetControlValue(Frg1, 'ChbViewSum') = 0, False);
end;

procedure TFrmOGjrnOrders.Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
//изменение данных в ячейке грида при вводе
var
  i: Integer;
  NewValue: Variant;
begin
  if UseText then NewValue:=Text else NewValue:=Value;
  //отмена заказа (клик на чекбоксе)
  if (Fr.CurrField = 'cancel') then begin
    //событие обработано, если сами не установим поле то значение чекбокса останется таким же как было
    Handled := True;
    //Fr.MemTableEh1.Cancel; //не обязательно
    //перечитаем строку
    if not Fr.RefreshRecord then Exit;
    //нельзх отменить завершенный
    if Fr.GetValue('dt_end') <> null then Exit;
    //далее ориентируемся на прочитанное значение поля Отменен, инвертируем его
    i:=S.NInt(Fr.GetValue);
//    i:=S.NInt(Value);
    if i = 0 then
      if MyQuestionMessage('Отменить заказ'#10#13'('+Fr.GetValue('ornum')+') ?') <> mrYes then Exit;
    if i = 1 then
      if MyQuestionMessage('Вернуть в работу заказ'#10#13'('+Fr.GetValue('ornum')+') ?') <> mrYes then Exit;
    Q.QExecSql(
      'update orders set dt_cancel=:dt_cancel$d where id=:id$i',
      [S.IIf(i = 1, null, Date), Fr.ID], False
    );
    if i = 0 then Orders.FinalizeOrder(Fr.ID, myOrFinalizeManual);
    Fr.RefreshRecord;
  end;
end;

procedure TFrmOGjrnOrders.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
  if not Fr.IsPrepared then
    Exit;
  if TControl(Sender).Name = 'ChbViewSum' then begin
    Frg1.Opt.SetColFeature('1', 'i', Cth.GetControlValue(Fr, 'ChbViewSum') = 0, False);
    Frg1.SetColumnsVisible;
    Frg2.Opt.SetColFeature('1', 'i', Cth.GetControlValue(Fr, 'ChbViewSum') = 0, False);
    Frg2.SetColumnsVisible;
  end
  else if A.InArray(TControl(Sender).Name, ['ChbFilter1', 'ChbFilter2']) then begin
    //для фильтра проспроченныз заказов снимем все фильтры в столбцах
    Gh.GridFilterClear(Fr.DbGridEh1, true, False);
    Frg1.RefreshGrid;
  end
  else Frg1.RefreshGrid;
end;

procedure TFrmOGjrnOrders.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if (FieldName = 'ornum') and (Fr.GetValue('dt_end') = null)
    then Params.Background:=clSkyBlue;
  if (FieldName = 'ornum') and (Fr.GetValue('id_itm') = null) then begin
    Params.Font.Color:=clBlue;
    Params.Font.Style := [fsUnderline];
  end;
  if (FieldName = 'pay') and
     (Fr.GetValue('pay') <> null)and(Fr.GetValue('cost') <> null) and
     (S.NNum(Fr.GetValue('pay')) = S.NNum(Fr.GetValue('cost'))) and
     (S.NNum(Fr.GetValue('cost')) <> 0)
    then Params.Background:=clMoneyGreen;
  //подсветим заказы, на которые есть все сметы в Учете, но не все есть в ИТМ
  //(если отдельное изделие не должно попадать в ИТМ, то это должно правильно обрабатываться и подсветки из-за него не будет)
  if (FieldName = 'estimates') and (Fr.GetValue('estimates') = '+') and (VarToDateTime(Fr.GetValue('dt_beg')) >= EncodeDate(2025, 01, 01)) and (Fr.GetValue('has_itm_est') = 0)
    then Params.Background:=clmyPink;
  //подсветим опережение производственных заказов зеленым, а просрочку розовым.
  if (FieldName = 'early_or_late') then
    if (Fr.GetValueI('early_or_late') > 0)
      then Params.Background:=clmyPink
      else if (Fr.GetValueI('early_or_late') < 0)
        then Params.Background:=clmyGreen
          else if (Fr.GetValue('early_or_late') = 0)
          then Params.Background:=clmyBlue;
end;

procedure TFrmOGjrnOrders.Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
end;

procedure TFrmOGjrnOrders.Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
end;

procedure TFrmOGjrnOrders.Frg1RowDetailPanelShow(var Fr: TFrDBGridEh; const No: Integer; var Hnadled: Boolean; var CanShow: Boolean);
begin
  LoadKnsAndThnList;
end;



{детальный грид}

procedure TFrmOGjrnOrders.Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  //у нас нет задач, которые нужны при пустой панели
//  if MemTableEh2.RecordCount = 0 then Exit;
  case Tag of
    mbtTest:
      begin
        Fr.SetState(True, True, null);
//        Fr.SetState(True, True, 'Ощибка!');
      end;
    mbtCustom_OrToDevel:
      begin
        Orders.OrderItemsToDevel(null, Fr.ID, 1);
      end;
    1004:
      begin
        Orders.OrderItemsToDevel(null, Fr.ID, 2);
      end;
    mbtViewEstimate: //просмотр сметы
      begin
        Wh.ExecReference(myfrm_R_Estimate, Self, [myfoDialog, myfoMultiCopyWoId, myfoSizeable, myfoEnableMaximize], VarArrayOf([Fr.ID, null]));
      end;
    mbtLoadEstimate: //загрузка сметы по позиции
      begin
        Orders.LoadBcadGroups(True);
        Orders.LoadEstimate(null, Fr.ID, null);
        Fr.RefreshRecord;
        Fr.SetState(True, null, null);
      end;
    mbtCopyEstimate:
      begin
        Orders.CopyEstimateToBuffer(null, fr.ID);
      end;
    mbtCustom_Order_AttachThnDoc:
      begin
        if Orders.IsOrderFinalized(Frg1.ID, True, cOrItmStatus_Completed) >= cOrItmStatus_Completed then
          Exit;
        if Orders.TaskForSendThnDocuments(Fr.ID) then begin
          Fr.RefreshRecord;
          Fr.SetState(True, null, null);
        end;
      end;
    1002:
      begin
        if Orders.IsOrderFinalized(Frg1.ID, True, cOrItmStatus_Completed) >= cOrItmStatus_Completed then
          Exit;
        if Orders.TaskForSendThnDocuments(Fr.ID, False) then begin
          Fr.RefreshRecord;
          Fr.SetState(True, null, null);
        end;
      end;
    1001:
      begin
        TFrmOGrefOrStdItems.GoToItem(Fr.GetValue('id_std_item'));
      end;
    1003:
      begin
        if Orders.AddOrItemXMLFile(Self, null, Fr.ID) then begin
          Fr.RefreshRecord;
          Fr.SetState(True, null, null);
        end;
      end
    else inherited;
  end;
end;

procedure TFrmOGjrnOrders.Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  Fr.SetSqlParameters('id_order$i', [Frg1.ID]);
  Fr.Opt.Caption := 'Заказ ' + Frg1.GetValueS('ornum');
  Frg2.Opt.SetColFeature('sum0', 'null', not TFrmXDedtGridFilter.GetChb(Frg1, 'Sum0') , False);
end;

procedure TFrmOGjrnOrders.Frg2ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  //подсветим ячейку с датой сметы
  if (FieldName = 'dt_estimate') and (Fr.GetValue('qnt') <> 0) then begin
    if (Fr.GetValue('dt_estimate') = null)
      //не загружена - желтым
      then Params.Background := clmyYelow
      else if (Fr.GetValue('id_itm') <> null) and (Fr.GetValue('has_itm_est') = null)
        //загружена в учете но не найдена в итм, при том что изделие в заказ в ИТМ передано - розовым
        then Params.Background := clmyPink;
  end;
  if (FieldName = 'dt_kns') then begin
    if (Fr.GetValue('dt_kns') <> null) and (Fr.GetValue('wo_kns') = 1) then
      Params.Text := 'нет';
  end;
end;

procedure TFrmOGjrnOrders.Frg2ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
//Exit;
  if (Fr.CurrField = 'id_kns') then begin
    if Value.AsString = '' then
      Exit;
    Fr.SetValue('id_kns', Value);
    Q.QExecSql('update order_items set id_kns = :id_kns$i where id = :id$i', [Value, Fr.ID]);
  end
  else if (Fr.CurrField = 'id_thn') then begin
    if Value.AsString = '' then
      Exit;
    Fr.SetValue('id_thn', Value);
    Q.QExecSql('update order_items set id_thn = :id_thn$i where id = :id$i', [Value, Fr.ID]);
  end;
end;

procedure TFrmOGjrnOrders.Frg2SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
  Fr.DbGridEh1.FindFieldColumn('id_kns').EditButton.Visible := not((Fr.GetValueI('sgp') = 1) {or (Fr.GetValue('dt_kns') <> null)}) and ((User.GetJobID = myjobKNS) or (User.GetJobID = myjobTHN) or User.IsDeveloper);
  Fr.DbGridEh1.FindFieldColumn('id_thn').EditButton.Visible := not((Fr.GetValueI('sgp') = 1) {or (Fr.GetValue('dt_thn') <> null)}) and ((User.GetJobID = myjobKNS) or (User.GetJobID = myjobTHN) or User.IsDeveloper);
end;

procedure TFrmOGjrnOrders.Frg2GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
  if (Fr.CurrField = 'id_kns') then
    ReadOnly := (Fr.GetValueI('sgp') = 1) {or (Fr.GetValue('dt_kns') <> null)};
  if (Fr.CurrField = 'id_thn') then
    ReadOnly := (Fr.GetValueI('sgp') = 1) {or (Fr.GetValue('dt_thn') <> null)};
end;




{
дополнительные функции
}

function TFrmOGjrnOrders.OpenFromTemplate: Integer;
var
  va: TvarDynArray;
  van, vaid: TvarDynArray;
  va2: TVarDynArray2;
  i: Integer;
begin
  va2:= Q.QLoadToVarDynArray2('select templatename from v_orders where id <= -1 order by templatename asc', []);
  if Length(va2) = 0
    then begin MyInfoMessage('Не найдено ни одного шаблона!'); Exit; end;
  van:=A.VarDynArray2ColToVD1(va2, 0);
  vaid:=A.VarDynArray2ColToVD1(Q.QLoadToVarDynArray2('select id from v_orders where id <= -1 order by templatename asc', []), 0);
  if TFrmBasicInput.ShowDialog(Self, '', [], fAdd, '~Шаблон заказа', 820, 85, [
//  if Dlg_BasicInput.ShowDialog(Self, 'Создать заказ из шаблона', 820, 85, fAdd, [
    [cntComboLK, 'Шаблон заказа','1:500:0']
   ],
   [
     VarArrayOf(['0', VarArrayOf(van), VarArrayOf(vaid)])
   ],
   va,
   [['']],
   nil
  ) < 0
  then Exit;
  Wh.ExecDialog(myfrm_Dlg_Order, Self, [], fCopy, va[0], null);
end;

procedure TFrmOGjrnOrders.ViewInfo1;
begin
  var Ids: TVarDynArray2 := Gh.GetGridArrayOfChecked(Frg1.DBGridEh1, Frg1.DBGridEh1.FindFieldColumn(Frg1.Opt.Sql.IdField).Index);
end;

procedure TFrmOGjrnOrders.LoadKnsAndThnList;
var
  va2: TVarDynArray2;
begin
  va2 := Q.QLoadToVarDynArray2('select name, id from adm_users where (job = :id_job$i and active = 1) or id = -100 or id = -101 or id in (select distinct id_kns from order_items where id_order = :id_order$i) order by name', [myjobKNS, Frg1.ID]);
  Frg2.Opt.SetPick('id_kns', A.VarDynArray2ColToVD1(va2, 0), A.VarDynArray2ColToVD1(va2, 1), True);
  va2 := Q.QLoadToVarDynArray2('select name, id from adm_users where (job = :id_job$i and active = 1) or id = -100 or id = -102 or id in (select distinct id_kns from order_items where id_order = :id_order$i) order by name', [myjobTHN, Frg1.ID]);
  Frg2.Opt.SetPick('id_thn', A.VarDynArray2ColToVD1(va2, 0), A.VarDynArray2ColToVD1(va2, 1), True);
  Frg2.SetColumnsPropertyes;
end;




end.
