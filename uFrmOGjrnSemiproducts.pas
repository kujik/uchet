{
создание паспортов на полуфабрикаты МТ

сам заказ создается в бд процкедурой
p_CreatePspForSemiproducts
регламент и срок выполнения 10 дней прописаны жестко в ней!
}

unit uFrmOGjrnSemiproducts;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uData, uFrmBasicMdi, uString, uFrDBGridEh, uFrmBasicGrid2
  ;

type
  TFrmOGjrnSemiproducts = class(TFrmBasicGrid2)
    procedure Frg1DbGridEh1DrawDataCell(Sender: TObject; const Rect: TRect; Field: TField; State: TGridDrawState);
    procedure Frg1DbGridEh1DataGroupGetRowText(Sender: TCustomDBGridEh; GroupDataTreeNode: TGroupDataTreeNodeEh; var GroupRowText: string);
    procedure Frg1DbGridEh1DataGroupGetRowParams(Sender: TCustomDBGridEh; GroupDataTreeNode: TGroupDataTreeNodeEh; Params: TGroupRowParamsEh);
    procedure Frg1DbGridEh1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Frg1DbGridEh1ApplyFilter(Sender: TObject);
  private
    //количество заказов к обработке (полностью заполенных)
    FQntOrdersToDemand: Integer;
    //номера заказов к обработке (где хотя бы одна позиция заполнена)
    FOrdersToDemand: TVarDynArray;
    //заказы, ранее обработанные (есть информация в таблице обработанных изделий по этому заказу)
    FOrdersProcessed: TVarDynArray;
    //заказы, которые были обработаны, и с тех пор количество или состав изделий в заказе изменился
    //(не попадет сюда, если изделие из заказа было удалено!))
    FOrdersModifyed: TVarDynArray;
    //то же, по слешам в заказе
    FOrderItemsModifyed: TVarDynArray;
    //заказы, по которым нельзя создать ПЗ, т.к. не удалось загрузить или не согласованы данные по стд. изделиям, соотвествующим полуфабрикатам
    FOrdersWithErrors: TVarDynArray;
    //исходные заказы, успешно обработанные по нажатии кнопки создать в Save
    FOrdersTreated: TVarDynArray;
    //производственные заказы, которые были созданы по исходным в Save
    FOrdersCreated: TVarDynArray;
    FInSaveData: Boolean;
    function  PrepareForm: Boolean; override;
    procedure LoadData;
    procedure VerifyTable(RecNo: Integer = MaxInt);
    procedure SetQntForChecked;
    function  GetDataForSemiproducts: Boolean;
    procedure TreatOrder(OrNum : string);
    function  Save: Boolean;
  protected
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    procedure Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string); override;
  public
  end;

var
  FrmOGjrnSemiproducts: TFrmOGjrnSemiproducts;

implementation

uses


  uForms,
  uDBOra,
  uMessages,
  uWindows,
  uOrders,



  uFrmODedtNomenclFiles
  ;


{$R *.dfm}

function TFrmOGjrnSemiproducts.PrepareForm: Boolean;
var
  c : TComponent;
  va2: TVarDynArray2;
  st: string;
begin
  Caption:='~Заказы на полуфабрикаты';
  //попробуем взять блокировку, если режим fEdit (задается при вызове справочника исходя из прав доступа)
  //если права на редактирование, и открыт другим пользователем, то fMode := fView
  FormDbLock;
  //при попытке закрыть форму, если введены данные, будет запрос
  FOpt.RequestWhereClose := cqYN;

  Frg1.Options := Frg1.Options + [myogIndicatorCheckBoxes, myogMultiSelect, myogLoadAfterVisible];
  Frg1.Opt.SetFields([
    ['id$i','_id','d=40'],
    ['id_order$i','_id_order_item','d=40'],
    ['id_order_item$i','_id_order_item','d=40'],
    ['id_nomencl$i','_id_nomencl','d=40'],
    ['id_unit$i','_id_unitl','d=40'],
    ['dt_beg$d','_dt_otgr','d=40'],
    ['dt_otgr$d','_dt_otgr','d=40'],
    ['filter$i','_filter','d=40'],
    ['ornum$s','_№ заказа','80','bt=Открыть папку заказа:4',False],
    ['project$s','_Проект','150'],
    ['slash$s','_Слеш','150'],
    ['itemname$s','_Изделие','200'],
    ['ordercaption$s','Заказ','d=200;h'],
    ['itemcaption$s','Изделие','d=200;h'],
    ['name$s','Полуфабрикат','d=200;h'],
    ['qnt_in_order$f','Кол-во в заказе','80'],
    ['qnt_in_order_diff$f','Изменения','80'],
    ['qnt_in_demand$i','Кол-во к запуску','80', 'e=0:999999:0', 'i', Mode = FView],
    ['qnt_in_demand_old$i','Запущено ранее','80'],
    ['need_curr$f','Потребность с учетом ввода','80', 'i', Mode = FView],
    ['need$f','Потребность на все заказы','80'],
    ['qnt_onway$f','В пути','80'],
    ['qnt_on_stock$f','Текущий остаток','80'],
    ['qnt_nin$f','Мин. остаток','80'],
    ['has_files$i','Файлы','40','pic'],
    ['id_std_item$i','_id_std_item','d=40'],
    ['id_template$i','_id_template','d=40'],
    ['has_estimate$i','_has_estimate','d=40']
  ]);
  Frg1.Opt.SetTable('v_semiproducts_srcorders');

  Frg1.CreateAddControls('1', cntComboLK, 'Полуфабрикаты', 'CbType', '', 90, yrefC, 150);
  Cth.AddToComboBoxEh(TDBComboBoxEh(Frg1.FindComponent('CbType')),
    [['Металл', '6212'], ['Стекло', '2770999']],
    False
  );

  Frg1.CreateAddControls('1', cntCheck, 'Все', 'ChbViewAll', '', 90 + 150 + 10, yrefC, 40);
  Frg1.CreateAddControls('1', cntCheck, 'Новые', 'ChbViewNew', '', -1, yrefC, 55);
  Frg1.CreateAddControls('1', cntCheck, 'Измененные', 'ChbViewChanged', '', -1, yrefC, 85);
  Frg1.CreateAddControls('1', cntCheck, 'Завершенные', 'ChbViewCompleted', '', -1, yrefC, 90);
  Frg1.CreateAddControls('1', cntCheck, 'Только с потребностью', 'ChbViewNeededOnly', '', -1, yrefC, 150);
  Frg1.ReadControlValues;
  TDBCheckBoxEh(Frg1.FindComponent('ChbViewAll')).Checked := True;
  TDBCheckBoxEh(Frg1.FindComponent('ChbViewNew')).Checked := True;
  TDBCheckBoxEh(Frg1.FindComponent('ChbViewChanged')).Checked := True;
  TDBCheckBoxEh(Frg1.FindComponent('ChbViewCompleted')).Checked := True;
  TDBCheckBoxEh(Frg1.FindComponent('ChbViewNeededOnly')).Checked := False;


  Frg1.Opt.SetButtons(1, [
   [1000, True, -90, 'Группировка', 'grouping'], [1001, True, 'Раскрыть все', 'expand'], [1002, True, 'Схлопнуть все', 'collapse'], [],
   [1003, Mode = FEdit, 'Заполнить выбранные', 'ok_double'], [],
   [mbtGo, Mode = FEdit, 'Сформировать паспорта'], [], [mbtCtlPanel]
  ]);

  //данные группировки (масиивы полей, каждое соотвествует уроню групировки, шрифтов и цветов фона - могут быть пустыми), и активность группировки.
  Frg1.Opt.SetGrouping(['ordercaption', 'itemcaption'], [], [clGradientActiveCaption, clGradientInactiveCaption], True{Cth.GetControlValue(Frg1, 'ChbGrouping') = 1});

  Frg1.InfoArray:=[
    [Caption + '.'#13#10]
  ];
  Frg1.Opt.SetDataMode(myogdmFromArray);
  Frg1.Prepare;

  Frg1.Opt.SetColFeature('qnt_in_demand', 'e', Frg1.DbGridEh1.DataGrouping.Active, True);
  TSpeedButton(TPanel(Frg1.FindComponent('pnlTopBtns')).Controls[0]).Down := Frg1.DbGridEh1.DataGrouping.Active;
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, 1001, null, Frg1.DbGridEh1.DataGrouping.Active);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, 1002, null, Frg1.DbGridEh1.DataGrouping.Active);

  LoadData;

  //st:=Frg1.pmgrid.Items[0].Owner.Name;

  Result := True;
end;

procedure TFrmOGjrnSemiproducts.Frg1DbGridEh1ApplyFilter(Sender: TObject);
//фильтрация грида
//всегда фильтруем по скрытому столбцу в зависимости от чекбоксов, задающих,
//заказы в каком статусе надо отображать.
//фильтр в итоге накладывается на фильтры в других столбцах и в панели
var
  st: string;
  i, j: Integer;
  va: TVarDynArray;
begin
  va := [9];
  st := 'in (9';
  If Cth.GetControlValue(Frg1, 'ChbViewNew') = 1 then
    va := va + [0];
  If Cth.GetControlValue(Frg1, 'ChbViewChanged') = 1 then
    va := va + [2];
  If Cth.GetControlValue(Frg1, 'ChbViewCompleted') = 1 then
    va := va + [1];
  If Cth.GetControlValue(Frg1, 'ChbViewNeededOnly') <> 1 then begin
    for i := High(va) downto 0 do
      va := va + [va[i] + 10];
  end;
  st := 'in ( ' + A.Implode(va, ',') + ')';
  Gh.GetGridColumn(Frg1.DBGridEh1, 'filter').STFilter.ExpressionStr := st;
  Frg1.DBGridEh1.DefaultApplyFilter;
end;

procedure TFrmOGjrnSemiproducts.Frg1DbGridEh1DataGroupGetRowParams(
  Sender: TCustomDBGridEh; GroupDataTreeNode: TGroupDataTreeNodeEh;
  Params: TGroupRowParamsEh);
//параметры строки заголовоков групп
var
  st, ornum: string;
  va: TVarDynArray;
begin
  inherited;
  //раскрасим строки в зависимости от статуса заказа либо слеша
  va := A.Explode(Params.GroupRowText, ' ');
  if (High(va) >= 1) and A.InArray(va[1], FOrdersModifyed)
    then Params.Font.Color := clBlue
    else if (High(va) >= 1) and A.InArray(va[1], FOrdersProcessed)
      then Params.Font.Color := clGreen;
  if (High(va) >= 1) and A.InArray(va[1], FOrderItemsModifyed)
    then Params.Font.Color := clBlue;
end;

procedure TFrmOGjrnSemiproducts.Frg1DbGridEh1DataGroupGetRowText(
  Sender: TCustomDBGridEh; GroupDataTreeNode: TGroupDataTreeNodeEh;
  var GroupRowText: string);
//получение теста заголовков групп
var
  va: TVarDynArray;
begin
  inherited;
//  GroupRowText := GroupRowText + ' [' + DateToStr(VarToDateTime(Frg1.GetValue('dt_otgr')))+ ']';
  //добавим сообщение статуса в конце строки для заголовков заказов -
  //вводятся данные или введены полностью по данному заказу
  va := A.Explode(GroupRowText, ' ');
  if (High(va) >= 1) and A.InArray(va[1], FOrdersToDemand) then
    if Pos(va[1], Frg1.ErrorMessage) > 0
      then GroupRowText := GroupRowText + '     (Ввод)'
      else GroupRowText := GroupRowText + '     (Данные введены)';
end;

procedure TFrmOGjrnSemiproducts.Frg1DbGridEh1DrawDataCell(Sender: TObject;
  const Rect: TRect; Field: TField; State: TGridDrawState);
begin
  inherited;
  //
end;

procedure TFrmOGjrnSemiproducts.Frg1DbGridEh1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
//нажатие клавиши
var
  st: string;
begin
  if FInSaveData then
    Exit;
  Frg1.DbGridEh1KeyDown(Sender, Key, Shift);
  if Frg1.DbGridEh1.DataGrouping.Active and (Frg1.CurrField = 'qnt_in_demand') and (Key = 16{VK_LSHIFT}) then begin
    //в столбце К запуску по лефому шифту - введем количество, которое в заказе, и спустимся на ячейку ниже
    Frg1.MemTableEh1.Edit;
    Frg1.SetValue('qnt_in_demand', Frg1.GetValue('qnt_in_order'));
    //слуш для текущей строки
    st := Frg1.GetValue('slash');
    //пересчитаем/проверим данные в таблице
    VerifyTable(Frg1.RecNo);
    //перейдем вниз
    Frg1.MemTableEh1.Next;
    //если слеш изменился, вернемся назад - то есть через границу слыша (иначе - группировки) - не переходим!
    if st <> Frg1.GetValue('slash') then
      Frg1.MemTableEh1.Prior;
  end;
  if Frg1.DbGridEh1.DataGrouping.Active and (Key = VK_F4) then begin
    Gh.RootGroupExpandCollapse(Frg1.DbGridEh1, 0);
  end;
end;

procedure TFrmOGjrnSemiproducts.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
//обработка нажатия кнопок/меню
begin
  if FInSaveData then
    Exit;
  if Tag = mbtGo then
    //сохраним данные, создадим заявки и заказы (если это возможно)
    Save;
  if Tag = 1000 then begin
    //кнопка группироки, со статусом нажата/отжата (меняется автоматически, им не управляем)
    //инвертируем статус группировки
    Fr.DbGridEh1.DataGrouping.Active := not Fr.DbGridEh1.DataGrouping.Active;
    //разрешгим редактирование только в режиме группировки
    Fr.Opt.SetColFeature('qnt_in_demand', 'e', Fr.DbGridEh1.DataGrouping.Active, True);
    Fr.ChangeSelectedData;
  end;
  if Tag = 1001 then begin
    //схлопнем все группы на всех уровнях
    Gh.AllGroupsExpandCollapse(Fr.DbGridEh1, 1, True);
  end;
  if Tag = 1002 then begin
    //раскроем все группы на всех уровнях
    Gh.AllGroupsExpandCollapse(Fr.DbGridEh1, 1, False);
  end;
  if Tag = 1003 then
    //проставим количесто К запуску, расное тому, что в заказе, для всех отмеченных записей
    SetQntForChecked;
end;

procedure TFrmOGjrnSemiproducts.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
//изменение фокуса в гридже либо данных в текущей строке
begin
  inherited;
  //доступность кнопоку схопнуть/расхлопнуть - только в режиме групировки
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, 1001, null, Fr.DbGridEh1.DataGrouping.Active);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, 1002, null, Fr.DbGridEh1.DataGrouping.Active);
  //доступность кнопки Ввод для отмеченных - при группировке и если есть отмеченные чекбоксы в индикаторе
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, 1003, null, Fr.DbGridEh1.DataGrouping.Active and (Frg1.DbGridEh1.SelectedRows.Count > 0));
  //доступность кнопки Сформировать
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtGo, null, Fr.DbGridEh1.DataGrouping.Active);
end;


procedure TFrmOGjrnSemiproducts.Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
//русной ввод в ячейке
begin
exit;
  if not S.IsInt(Value) then Value := null;
  Frg1.SetValue('', Value);
//Frg1.setvalue('name',0,False,Frg1.GetValue);
  VerifyTable(Frg1.RecNo);
  Handled := True;
end;

procedure TFrmOGjrnSemiproducts.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if (FieldName = 'need') and (S.NNum(Fr.GetValue(FieldName)) < 0) then
    Params.Background := clmyGreen;
end;

procedure TFrmOGjrnSemiproducts.Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
  if (Fr.CurrField = 'has_files')and(Fr.GetValue = 1) then
    TFrmODedtNomenclFiles.ShowDialog(Self, Fr.GetValue('id_nomencl'));
end;

procedure TFrmOGjrnSemiproducts.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
//обработка изменений контролов в верхней панели
var
  st: string;
begin
  //выйдем на этапе загрузки
  if not Fr.IsPrepared then
    Exit;
  //выйдей если уже в этом событии
  if Fr.InAddControlChange then
    Exit;
  if FInSaveData then
    Exit;
  Fr.InAddControlChange := True;
  if TControl(Sender).Name = 'CbType' then begin
    //выбор типа полуфабриката - загрузим данные
    LoadData;
    Fr.ChangeSelectedData;
  end;
  if TControl(Sender).Name = 'ChbViewAll' then begin
    //галка Все - утсановим все галки отображения по статусам заказов
    Cth.SetControlValue(Frg1, 'ChbViewNew', 1);
    Cth.SetControlValue(Frg1, 'ChbViewChanged', 1);
    Cth.SetControlValue(Frg1, 'ChbViewCompleted', 1);
  end;
  if A.InArray(TControl(Sender).Name, ['ChbViewNew', 'ChbViewChanged', 'ChbViewCompleted']) then
    //галки по статусам заказов - если все установлены, то Все станет чекед
    TDBCheckBoxEh(Fr.FindComponent('ChbViewAll')).Checked :=
      (Cth.GetControlValue(Frg1, 'ChbViewNew') + Cth.GetControlValue(Frg1, 'ChbViewChanged') + Cth.GetControlValue(Frg1, 'ChbViewCompleted')) = 3;
  if A.InArray(TControl(Sender).Name, ['ChbViewAll', 'ChbViewNew', 'ChbViewChanged', 'ChbViewCompleted', 'ChbViewNeededOnly']) then
    //для любой галки фильрации заказов по статусом - вызовем событие фильтра (не DefaulApplyFilter !)
    Frg1DbGridEh1ApplyFilter(Fr.DbGridEh1);
  Fr.InAddControlChange := False;
end;

procedure TFrmOGjrnSemiproducts.Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string);
begin
  if Mode = dbgvBefore then
    Exit;
  VerifyTable(Row);
end;


procedure TFrmOGjrnSemiproducts.SetQntForChecked;
//установим количество К запуску для отмеченных в индикаторе позиций (если есть и после запроса)
var
  i, j: Integer;
  va2: TVarDynArray2;
begin
  if not Frg1.DbGridEh1.DataGrouping.Active then
    Exit;
  if Frg1.DbGridEh1.SelectedRows.Count = 0 then
    Exit;
  //кнопки будут расположены на форме в предопределенном порядке, не соответствуюзщим порядку заголовков!
  j := MyMessageDlg('Проставить количество для выбранных позиций?', mtConfirmation, [mbYesToAll, mbAbort, mbNo, mbOk, mbCancel], 'Заказ;Потребность;Ноль;Пустое;Отмена');
  //7,1,2,3 myinfomessage(inttostr(j)); exit;
  if j = 14 then
    Exit;
  va2 := Gh.GetGridArrayOfChecked(Frg1.DbGridEh1, 0);
  for i := 0 to Frg1.GetCount(False) - 1 do
    if A.PosInArray(Frg1.GetValue('id', i, False), va2, 0) >= 0 then begin
      if j = 7
        then Frg1.SetValue('qnt_in_demand', i, False, Frg1.GetValue('qnt_in_order', i, False))
        else if j = 2 then Frg1.SetValue('qnt_in_demand', i, False, 0)
          else if j = 3 then Frg1.SetValue('qnt_in_demand', i, False, null)
          else begin
            if S.NNum(Frg1.GetValue('need', i, False)) < 0
              then Frg1.SetValue('qnt_in_demand', i, False, Frg1.GetValue('qnt_in_order', i, False))
              else Frg1.SetValue('qnt_in_demand', i, False, 0);
          end;
      VerifyTable(-i);
    end;
end;

procedure TFrmOGjrnSemiproducts.VerifyTable(RecNo: Integer = MaxInt);
//проверка таблицы
//здесь же получаем список заказов, по которым введены данные, и статус неполного ввода
//если передано RecNo, то модифицируем колонку Потребность для записей с наименованием в данной строке,
//с учетом введенного во всех позициях с данным наименованием количества к заказу
//если RecNo положительно, то это MemTableEh1.RecNo, иначе это индекс в нефильтрованном массиве
var
  i ,j, k, m, n: Integer;
  st, err: string;
  b1, b2: Boolean;
  e: Extended;
begin
  //в режиме без группировки ввод запрещен, и проверку и коррекцию даннх не делаем
  //(проверка основана на том что записи отстортированы по номеру заказа, как это будет при группировке)
  if not Frg1.DbGridEh1.DataGrouping.Active then
    Exit;
  st := '';
  err := '';
  m := 0;
  FQntOrdersToDemand := 0;  //сколько заказов в заявку
  FOrdersToDemand := [];
  for i := 0 to Frg1.GetCount(False) do begin
    if (i = Frg1.GetCount(False)) or (st <> Frg1.GetValue('ornum', i, False)) then begin
      if st <> '' then begin
        //при переходе на другой заказ
        if (j <> 0) then
          //заказы к обработке (где хотя-бы что-то введено)
          FOrdersToDemand := FOrdersToDemand + [st];
        if (j <> 0) and (j <> k) then
          //если введено количество хотя бы одно, но не по всем позициям - номер заказа в текст ошибки
          S.ConcatStP(err, st, ', ');
        if j = k then
          //если введено по всем - увеличим количество заказов к формированию
          inc(FQntOrdersToDemand);
      end;
      if i = Frg1.GetCount(False) then
        Break;
      st := Frg1.GetValue('ornum', i, False);
      j := 0;
      k := 0;
    end;
    if Frg1.GetValue('qnt_in_demand' ,i, False) <> null then
      inc(j);
    inc(k);
  end;
  //проставим статус
  //изменением обозначим наличие заказов для заявки, ошибка и ее статусное сообщение - неполностью заполеннные заказы
  Frg1.SetState(Length(FOrdersToDemand) > 0, err <> '', S.IIfStr(err <> '', 'Данные по следующим заказам заполнены не полностью:'#13#10 + err));

  //посчитаем потребность - добавим к первоначально загруженной по данной номенклатуре введенное количество
  //(тк потребность отрицательна)
  if RecNo <> MaxInt then begin
    //из текущей записи (при вводе) или из переданного индекса
    if RecNo > 0
      then st := Frg1.GetValue('name')
      else st := Frg1.GetValue('name', -RecNo, False);
    if RecNo > 0
      then e := Frg1.GetValue('need')
      else e := Frg1.GetValue('need', -RecNo, False);
    for i := 0 to Frg1.GetCount(False) - 1 do
      if Frg1.GetValue('name' ,i, False) = st then
        e := e + S.NNum(Frg1.GetValue('qnt_in_demand' ,i, False));
    for i := 0 to Frg1.GetCount(False) - 1 do
      if Frg1.GetValue('name' ,i, False) = st then
        Frg1.SetValue('need_curr', i, False, e);
  end;
  //выбор типа полуфабриката доступен, если только нет введенных данных в графе К заказу
  TDBComboBoxEh(Frg1.FindComponent('CbType')).Enabled := Length(FOrdersToDemand) = 0;
end;


procedure TFrmOGjrnSemiproducts.LoadData;
//загрузка данных
//основное наполение таблицы - данные по заказам, в которых есть ПФ по металлу и которые находятся в резерве ИТМ
var
  va: TVarDynArray;
  va2: TVarDynArray2;
  i, j: Integer;
  b: Boolean;
  st: string;
begin
  Frg1.BeginOperation('Загрузка данных');
  //айди поставщика - в переменную контекста
  Q.QSetContextValue('semiproduct_supplier', Cth.GetControlValue(Frg1, 'CbType'));
  //запрос загрузки данных
  va2 := Q.QLoadToVarDynArray2(
    'select id, id_order, id_order_item, id_nomencl, id_unit, dt_beg, dt_otgr, null as filter, '+
    'ornum, project, slash, itemname, ordercaption, itemcaption, name, '+
    'qnt_in_order, qnt_in_order_diff, null as qnt_in_demand, qnt_in_demand_old, '+
    'need as need_curr, need, qnt_on_stock, qnt_nin, has_files '+
    'from v_semiproducts_srcorders '+
    S.IIFStr(S.NSt(Cth.GetControlValue(Frg1, 'CbType')) = '', 'where 1 = 2 ', '')+
    'order by ornum, slash',
    []
  );
//  Frg1.DbGridEh1.DataGrouping.Active := False;
  //перед загрузкой сбросим фильтры и очистим чекбокса в индикаторе
  //иначе после загрузки нарушается работа чекбоксов
  //(отменять группироку не обязательно)
  if Frg1.GetCount(False) > 0 then begin
    b := True;
    Gh.GridFilterClear(Frg1.DbGridEh1);
    //почему-то вызщывает мелькание контролов, хотя внутри делается DisableControls;
    //при вызове из грида например инферсси/снятия меток мелькания не вызывает
    //предположение что это из-за BeginOperation не подтвердиилось!
    if Frg1.DbGridEh1.SelectedRows.Count > 0 then
      Gh.SetGridIndicatorSelection(Frg1.DbGridEh1, -1);
  end;
  //загрузим массив в мемтейбл
  Frg1.LoadSourceDataFromArray(va2, '', '', True);
  //получим номера заказов - уже обработанных, которые были изменены, и слеши, которые были изменены
  FOrdersProcessed := [];
  FOrdersModifyed := [];
  FOrderItemsModifyed := [];
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    if S.Nst(Frg1.GetValue('qnt_in_demand_old', i, False)) <> '' then
      FOrdersProcessed := FOrdersProcessed + [Frg1.GetValue('ornum', i, False)];
    if S.Nst(Frg1.GetValue('qnt_in_order_diff', i, False)) <> '' then begin
      FOrdersModifyed := FOrdersModifyed + [Frg1.GetValue('ornum', i, False)];
      FOrderItemsModifyed := FOrderItemsModifyed + [Frg1.GetValue('slash', i, False)];
    end;
  end;
  //получим заказы с потребностью.
  va := [];
  for i := 0 to Frg1.GetCount(False) - 1 do
    if S.NNum(Frg1.GetValue('need', i, False)) < 0 then
      va := va + [Frg1.GetValue('ornum', i, False)];
  //установим значение в служебной колонке для фильтрации галками по типу заказа
  //(новый, обработан, изменен), и плюс еще если по заказу по любой позиции есть потребность
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    if A.InArray(Frg1.GetValue('ornum', i, False), FOrdersModifyed)
      then j := 2
      else if A.InArray(Frg1.GetValue('ornum', i, False), FOrdersProcessed)
        then j := 1
        else j := 0;
    if not A.InArray(Frg1.GetValue('ornum', i, False), va) then
      j := 10 + j;
    Frg1.SetValue('filter', i, False, j)
  end;
  VerifyTable;
  //сохраним фильтрацию галками по типу заказа
  //если ранее датасет был пустой, то по какой-то причине, хотя строка фильтрацции верная и статусы проставлена,
  //но все строки оказываются скрыты фильтром и таблица пуста!
  if b then
    Frg1DbGridEh1ApplyFilter(Frg1.DbGridEh1);
  //активируем группировку
//  Frg1.MemTableEh1.DisableControls;
  Frg1.DbGridEh1.DataGrouping.Active := True;
//  Frg1.MemTableEh1.EnableControls;
  //снимаем серый фон
  Frg1.EndOperation;
  //перерисуем грид, иначе не будет раскраски записей, пока в него не перейдет фокус
  Frg1.DbGridEh1.Repaint;
end;

function TFrmOGjrnSemiproducts.Save: Boolean;
var
  i, j: Integer;
  v: Variant;
  b: Boolean;
begin
  if Frg1.ErrorMessage <> '' then begin
    MyWarningMessage(Frg1.ErrorMessage);
    Exit;
  end;
  if FQntOrdersToDemand = 0 then begin
    MyWarningMessage('Нет заказов для обработки!');
    Exit;
  end;
  if MyQuestionMessage('Сформировать заявки и паспорта по ' + S.GetEndingFull(FQntOrdersToDemand, 'заказ', 'у', 'ам', 'ам') + '?') <> mrYes then
    Exit;

  FInSaveData := True;

  FOrdersTreated := [];
  FOrdersCreated := [];

  FDisableClose := True;
  Enabled := False;
  Frg1.BeginOperation;
  try
    b := GetDataForSemiproducts;
    if b then
      for i := 0 to High(FOrdersToDemand) do begin
        if not A.InArray(FOrdersToDemand[i], FOrdersWithErrors) then
          TreatOrder(FOrdersToDemand[i]);
      end;
  except on E: Exception do
    begin
      FDisableClose := False;
      Application.ShowException(E);
    end;
  end;
  Frg1.EndOperation;
  FDisableClose := False;
  Enabled := True;
  if b then
    MyInfoMessage('Готово!');

  FInSaveData := False;
  if b then
    LoadData;
end;

procedure TFrmOGjrnSemiproducts.TreatOrder(OrNum : string);
//обработаем заказ с переданным номером
//(сохраним данные по нему в таблице обработки ПЗ полуфабрикатов, создадим заявку СН, создадим производственный ПЗ)
var
  rb, re, o, i, j: Integer;
  PfArr: TVarDynArray2;
  IdO: Integer;
  DtO: TDateTime;
  StO: string;
  Err: Boolean;
  Lock: TVarDynArray;

  function GetPfArr: Boolean;
  var
    i, j: Integer;
  begin
    Result := False;
    PfArr := [];
    for i := rb to re do begin
      if S.NNum(Frg1.GetValue('qnt_in_demand', i, False)) = 0 then
        Continue;
      for j := 0 to High(PfArr) do
        if PfArr[j][0] = Frg1.GetValue('id_nomencl', i, False) then begin
          PfArr[j][1] := PfArr[j][1] + Frg1.GetValue('qnt_in_demand', i, False);
          Break;
        end;
      if (j <= High(PfArr)) and (High(PfArr) >= 0) then
        Continue;
      PfArr := PfArr + [[Frg1.GetValue('id_nomencl', i, False), Frg1.GetValue('qnt_in_demand', i, False), Frg1.GetValue('id_unit', i, False), 0]];
    end;
    Result := True;
  end;


  function SaveMtTable: Boolean;
  var
    i: Integer;
  begin
    Result := False;
    for i := rb to re do begin
      if Frg1.GetValue('qnt_in_demand' ,i, False) <> null then begin
        Q.QExecSql(
          'delete from j_semiproducts_src where '+
          'id_supplier = :id_supplier$i and id_order = :id_order$i and id_order_item = :id_order_item$i and id_nomencl = :id_nomencl$i',
          [Cth.GetControlValue(Frg1, 'CbType'), Frg1.GetValue('id_order', i, False), Frg1.GetValue('id_order_item', i, False), Frg1.GetValue('id_nomencl', i, False)]
        );
        Q.QExecSql(
          'insert into j_semiproducts_src (id_supplier, id_order, id_order_item, id_nomencl, qnt_in_order, qnt_in_demand) '+
          'values (:id_supplier$i, :id_order$i, :id_order_item$i, :id_nomencl$i, :qnt_in_order$f, :qnt_in_demand$f)',
          [Cth.GetControlValue(Frg1, 'CbType'), Frg1.GetValue('id_order', i, False), Frg1.GetValue('id_order_item', i, False), Frg1.GetValue('id_nomencl', i, False),
          Frg1.GetValue('qnt_in_order', i, False), Frg1.GetValue('qnt_in_demand', i, False) + S.NNum(Frg1.GetValue('qnt_in_demand_old', i, False))]
        );
      end;
    end;
    Result := Q.PackageMode = 1;
  end;

  function SaveOrder: Boolean;
  var
    i, j, k, IdT: Integer;
    IdReg: Variant;
    StI, StC: string;
    va: TVarDynArray;
    v: Variant;
  begin
    Result := False;
    StI := '';
    for i := rb to re do begin
      if Frg1.GetValue('qnt_in_demand' ,i, False) <> null then
        for j := 0 to High(PfArr) do
          if (Frg1.GetValue('id_nomencl', i, False) = PfArr[j][0]) and (PfArr[j][3] = 0) then begin
            S.ConcatStP(StI, VarToStr(Frg1.GetValue('id_std_item', i, False)) + '=' + VarToStr(PfArr[j][1]), ',');
            PfArr[j][3] := 1;
          end;
      v := Frg1.GetValue('id_template', i, False);
      if v <> null then
        IdT := S.NInt(v);
    end;
    if IdT = 0 then
      Exit;
    IdReg := null;
    if TDbComboBoxEh(Frg1.FindComponent('CbType')).Text = 'Металл' then begin
      //пропишем регламент и дату отгрузки (по регламенту 10 дней включая текущий)
      IdReg := 113;
      DtO := IncDay(Date, Q.QSelectOneRow('select deadline from order_reglaments where id = :id$i', [IdReg])[0] - 1);
    end
    else begin
      k := Trunc(Frg1.GetValue('dt_otgr', rb, False)) - Trunc(Frg1.GetValue('dt_beg', rb, False));
      k := Round(k * 24 / 30);
      DtO := IncDay(Frg1.GetValue('dt_beg', rb, False), k);
      if Frg1.GetValue('dt_otgr', rb, False) < DtO then
        DtO := Frg1.GetValue('dt_otgr', rb, False);
    end;
    StC := 'К заказу ' + Frg1.GetValue('ornum', rb, False);
    //pnl_CreatePspForSemiproducts(-99, '4063=12,4064=123', 33, 'К заказу 1234', trunc(sysdate), i, v);
    va := Q.QCallStoredProc(
      'p_CreatePspForSemiproducts',
      'id_t$i;items$s;id_u$i;comm$s;dt_otgr$d;id_reg$i;id$io;ornum$so',
       [IdT, StI, User.GetId, StC, DtO, IdReg, -1, -1]
    );
    if Length(va) = 0 then
      Exit;
    IdO := va[5];
    StO := va[6];
    Result := True;
  end;


  function SaveSnDemand: Boolean;
  var
    IdDemand: Integer;
    i, j: Integer;
  begin
    Result := False;
    IdDemand := Q.QIUD('i', 'dv.demand', '', 'id_demand$i;id_category$i;id_docstate$i;comments$s;control_date$d',
      [-1, 3, 1, TDBComboBoxEh(Frg1.FindComponent('CbType')).Text + ' к ' + StO + ' (отгр. ' + DateToStr(DtO)+ ')', Date]
    );
    if IdDemand < 0 then
      Exit;
    for i := 0 to High(PfArr) do begin
      Q.QExecSql(
        'insert into dv.demand_spec (id_demand, quantity, id_nomencl, id_unit) '+
        'values (:IdDemand$i, :qnt_order$f, :id_nomencl$i, :id_unit$i)',
        [IdDemand, PfArr[i][1], PfArr[i][0], PfArr[i][2]]
      );
    end;
    Result := Q.PackageMode = 1;
  end;


begin
  //Frg1.BeginOperation('Обработка заказа ' + OrNum);
  //получим диапозон для данного заказа в мемтейбл
  //(кнопка нажимается только при группировке, в этом случае записи отсортированы по номеру заказа)
  rb := -1;
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    if (rb = -1) and (Frg1.GetValue('ornum', i, False) = OrNum) then
      rb := i;
    if (rb <> -1) and (Frg1.GetValue('ornum', i, False) = OrNum) then
      re := i;
  end;

  repeat
    Lock := Q.DBLock(True, 'ordercreate', '-1', '');
    if Lock[0] = True then Break;
    if MyQuestionMessage(
      'Сейчас проводится заказ пользователем ' + Lock[1] + #13#10+
      'Подождите немного и нажмите "Да", чтобы продолжить, '#13#10+
      'или нажмите "Нет" и прервите операцию.'
    ) <> mrYes then
      Exit;
  until False;

  //сохраним данные в таблице ПФ, создадим  ПЗ и заявку СН в транзакции.
  //если хоть одна операция неудачна, то транзакцию откатываем.
  Err := True;
  Q.QBeginTrans(True);
  try
  repeat
    //пишем данные в таблицу ПФ
    if not SaveMtTable then
      Break;
    //получим массив полуфабрикатов для заказа (может быть пуст, если везде проставили 0)
    if not GetPfArr then
      Break;
    //дальнейшие шаги, если есть полуфабррикаты к заявке
    if Length(PfArr) <> 0 then begin
      //создадим заказ
      if not SaveOrder then
        Break;
      //создадим задачу на сервер, втч в ней ПЗ в excel
      if not Orders.SetTaskForCreateOrder(IdO) then
        Break;
      //заявка на снабжение
      if not SaveSnDemand then
        Break;
    end;
    Err := False;
  until True;
  except on E: Exception do begin
    Q.QRollbackTrans;
    Q.DBLock(False, 'ordercreate', '-1', '');
    Application.ShowException(E);
    end;
  end;
  Q.QCommitOrRollback(not Err);
  Q.DBLock(False, 'ordercreate', '-1', '');
  //Frg1.EndOperation;
end;

function TFrmOGjrnSemiproducts.GetDataForSemiproducts: Boolean;
//получаем для всех номенклатурных позиций во всех заказах, назначенных к обработке,
//данные по номенклатуре - айди соотвествующенго стд изделия, айди щаблона, есть ли смета
var
  i, j, k, p, tmpl: Integer;
  va2: TVarDynArray2;
  nm, msg, msg1: string;
  b: Boolean;
begin
  Result := False;
  Frg1.SetStatusBarCaption('Получении информации по номенклатуре полуфабрикатов...', True);
  FOrdersWithErrors := [];
  tmpl := 2;
  //проходим по всему массиву
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    if not A.InArray(Frg1.GetValue('ornum', i, False), FOrdersToDemand) then
      Continue;
    nm := Frg1.GetValue('name', i, False);
    //пропустим позиции, которые не идут к заказу
    if S.NNum(Frg1.GetValue('qnt_in_demand', i, False)) = 0 then
      Continue;
    //попытаемся найти такое же наименование в ранее пройденных и уже по которым получена информация
    b := False;
    p := 0;
    for k := 0 to i - 1 do begin
      p := k;
      if (nm = Frg1.GetValue('name', k, False)) and (S.NSt(Frg1.GetValue('id_std_item', k, False)) <> '') then begin
        //если нашли, возьмем данные из него
        Frg1.SetValue('id_std_item', i, False, Frg1.GetValue('id_std_item', k, False));
        Frg1.SetValue('id_template', i, False, Frg1.GetValue('id_template', k, False));
        Frg1.SetValue('has_estimate', i, False, Frg1.GetValue('has_estimate', k, False));
        b := True;
        Break;
      end;
    end;
    if (i = 0) or not b {or (k = i)} then begin
      //если не нашли, делаем запрос для проверки
      va2 := Q.QLoadToVarDynArray2(
        'select id_std_item, id_template, dt_estimate from v_semiproducts_get_std_item where name = :name$s',
        [Frg1.GetValue('name', i, False)]  //было k!
      );
      if Length(va2) = 0
        then va2 := [[0, null, null]]
        else if Length(va2) > 1
          then va2 := [[{-1} 0, null, null]];
      //установим данные запроса в массиве
      Frg1.SetValue('id_std_item', i, False, va2[0][0]);
      Frg1.SetValue('id_template', i, False, va2[0][1]);
      Frg1.SetValue('has_estimate', i, False, va2[0][2]);
      //проверим
      if Frg1.GetValue('id_std_item', i, False) = 0
        then S.ConcatStP(msg1, nm + '     : ' + 'не найден в справочнике стандартных изделий.', #13#10)
        else if Frg1.GetValue('id_template', i, False) = null
          then S.ConcatStP(msg1, nm + '     : ' + 'не найден в шаблонах.', #13#10)
        else if Frg1.GetValue('has_estimate', i, False) = null
          then S.ConcatStP(msg1, nm + '     : ' + 'нет сметы.', #13#10)
    end;
    //проверим и установим признак, что айди шаблонов для номенклатуры зваказа оказались разные
    if tmpl = 2
      then tmpl := S.NInt(Frg1.GetValue('id_template', k, False))
      else if tmpl <> S.NInt(Frg1.GetValue('id_template', k, False))
        then tmpl := 1;
    //если перешли на другой заказ, или это последняя запись
    if (i = Frg1.GetCount(False) - 1) or (Frg1.GetValue('ornum', i, False) <> Frg1.GetValue('ornum', i + 1, False)) then begin
      if (msg1 = '') and (tmpl = 1) then
        msg := Frg1.GetValue('ornum', i, False) + '     : ' + 'разные шаблоны для изделий.';
      //признак, что есть ошибки в заказе
      if msg1 <> ''
        then FOrdersWithErrors := FOrdersWithErrors + [Frg1.GetValue('ornum', i, False)];
      //общее сообщение
      S.ConcatStP(msg, msg1, #13#10, True);
      msg1 := '';
      tmpl := 2;
    end;
  end;
  //если есть ошибка, спросим продолжить ли
  if msg <> '' then begin
    MyWarningMessage(msg, 1);
    if Length(FOrdersWithErrors) <> Length(FOrdersToDemand)
      then Result := MyQuestionMessage('Паспорта по следующим заказам не могут быть сформированы!'#13#10 + A.Implode(FOrdersWithErrors, ', ') + #13#10'Сформировать по остальным заказам?', 1) = mrYes
      else MyWarningMessage('Не может быть создан ни один паспорт заказа!');
  end
  else Result := True;
  Frg1.SetStatusBarCaption('', True)
end;



end.
