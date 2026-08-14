unit uFrmOGedtEstimate;
interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uFrmBasicEditabelGrid,
  uNamedArr
  ;
type
  TFrmOGedtEstimate = class(TFrmBasicEditabelGrid)
  private
    FIdEstimate: Integer;
    Err, Err2: TVarDynArray;
    FIdOfStdItem: Integer;    //айди стандартного изделия, к которому смета (непосредственно, или из спецификации заказа)
    FIdOfOrder: Integer;      //айди заказа, в составе которого данное изделие
    FGroupOfItem: Integer;    //группа стандартных изделий, к которой относится изделие сметы
    FTypeOfItem: string;      //тип изделия, к которому относиттся смета (Н,П,О,ПФ)
    FQntOfItem: Extended;     //количество единиц изделия заказа
    FFormatCaption: string;
    FName: string;
    FUseInputArray: Boolean;  //признак того, что смета получена/передается через массив (обертка), а не через прямую привязку к БД
    FInVerifyTable: Boolean;  //защита от реентерабельного вызова: VerifyTable вызывает Frg1.IsTableCorrect, которая сама
                               //по каждой ячейке дергает обратно OnVeryfyAndCorrectValues (=Frg1VeryfyAndCorrect), а тот снова
                               //вызывает VerifyTable - без этой защиты уходим в бесконечную рекурсию и переполнение стека
    function  PrepareForm: Boolean; override;
    function  PrepareFormAdd: Boolean; override;
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;
    procedure Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string); override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); override;
    procedure Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure btnClick(Sender: TObject); override;
    procedure VerifyRow(Row: Integer; Filtered: Boolean);
    procedure VerifyBeforeSave; override;
    function  Save: Boolean; override;
    procedure VerifyTable(AReloadStatus: boolean = False);
    procedure LoadFromDB;
    procedure LoadFromXls;
    procedure LoadFromBuffer;
    procedure SaveEstimateToBuffer;
    procedure LoadItemFromDB(Row: Integer);
    function  SaveEstimate: Boolean;
  protected
  public
  end;


var
  FrmOGedtEstimate: TFrmOGedtEstimate;
  //"боковой канал" для передачи массива-снимка сметы в диалог и получения отредактированного массива обратно,
  //используется оберткой (TOrders.LoadEstimate), т.к. .Show/.ShowModal2 не дают прямого доступа к создаваемому экземпляру формы;
  //устанавливаются вызывающим кодом непосредственно перед TFrmOGedtEstimate.ShowModal2 и читаются сразу после его завершения
  EstDlgHasInput: Boolean;         //True - диалог должен работать с массивом (EstDlgInputItems/EstDlgResultItems), а не с БД напрямую
  EstDlgInputItems: TNamedArr;     //входной массив (текущий состав сметы: name;id_group;id_unit;qnt1;comm)
  EstDlgResultItems: TNamedArr;    //результат редактирования (тот же состав полей), заполняется при успешном сохранении (Res.ModalResult = mrOk)
  EstDlgSourceUsed: Integer;       //источник данных для estimate_change_log.source (см. TOrders.LogEstimateChange)


implementation

uses
  uOrders,
  uFrmODedtOrStdItem,
  uWindows
  ;


{$R *.dfm}

const
  cIdSemiproduct = 2;
  cIdProduct = 104;
  cIdStuff = 1;
  cIdKrep = 103;


function TFrmOGedtEstimate.PrepareForm: Boolean;
var
  i: Integer;
  o: TFrDBGridEditOptions;
  va: TVarDynArray;
begin
  Caption := 'Смета';
  //получим айди сметы по айди стандартного изделия или заказа
  if AddParam = 1 then begin
    FIdOfStdItem := ID;
    FIdEstimate := Q.QLoadValue('select id from estimates where id_std_item = :id$i', [ID]);
    FName := Q.QLoadValue('select name from v_or_std_items where id = :id$i', [ID]);
    FTypeOfItem := Q.QLoadValue('select type_name from v_or_std_items where id = :id$i', [ID]);
    FFormatCaption  := Q.QLoadValue('select or_format_name || '' / '' || or_format_estimate_name || '' ['' || prefix || '']'' from v_or_std_items where id = :id$i', [ID]);
  end
  else begin
    FIdOfStdItem := Q.QLoadValue('select id_std_item from order_items where id = :id$i', [ID]);
    FIdEstimate := Q.QLoadValue('select id from estimates where id_order_item = :id$i', [ID]);
    va := Q.QLoadRow('select slash || '' '' || name, id_order, qnt from v_order_items where id = :id$i', [ID]);
    FName := va[0];
    FIdOfOrder := va[1];
    FQntOfItem := va[2];
    FTypeOfItem := 'И';
  end;
  //если сметы еще нет, то перейдем в режим добавления
  if  FIdEstimate = null then
    Mode := fAdd;
  //получим айди группы (не подгруппыв!) стандартных изделий для данной позиции
  FGroupOfItem := Q.QLoadValue('select id_format from or_format_estimates where id = (select id_or_format_estimates from or_std_items where id = :id$i)', [FIdOfStdItem]);
  //заголовочный лейбл
  FTitleTexts := [S.IIf(AddParam = 1, 'Смета к ' +
    S.Decode([FTypeOfItem, 'О', 'отгрузочному стандартному изделию', 'П', 'производственному стандартному изделию', 'ПФ', 'полуфабрикату', 'стандартному изделию'])  + '  ' +
    FFormatCaption + ':', 'Смета кизделию заказа:'),  {'$FF0000' + } FName];
  pnlTop.Height := 50;
  //прочитаем список групп и ед.изм.
  Orders.LoadBcadGroups(True);
  //теги - 1 = читать при обновлении, 2 = записать
  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['id_estimate$i','_ide','40'],
    ['id_or_std_item$i','_id_or_std_item','40','t=1,2'],
    ['id_item_estimate$i','_id_item_estimate','40','t=1,2'],
    ['type_of_item$s','Изделие','85', 'bt=Изделие:И:::009;Смета:С:::909', 'pic=;П;ПФ;Н;О:0;7;7;8;9:+','t=1'],
    ['id_group$i','Группа','250;w;L','e=1:100000:0:N','t=1,2'],
    ['name$s','Наименование','400;w;h','e=1:1000',
      'bt=Выбрать материал:М:::090' + S.IIFStr(FTypeOfItem <> 'П', ';Выбрать полуфабрикат:П:::909') + S.IIFStr(FTypeOfItem = 'О', ';Выбрать производственное изделие:И:::009') + ';Выбрать нестандартное изделие:Н:::000','t=1'],
    ['id_unit$i','Ед.изм.','100;L','e=1:1000000:0:N','t=1,2'],
    ['qnt1$f','Кол-во','80','e=0:999999:5:N','t=1,2'], {недопустимо пустое кол-во}
    ['qnt_on_stock$f','На складе','80','t=1'],
    //['null as purchase$i','Покупка','80','chb','e'],
    ['comm$s','Дополнение','300;w;h','e=0:1000::TP','t=1'],
    ['null as err$i','!','20','v=0:10:0','pic=-1;1:16;17'],
    ['null as newpos$i','_newpos','40'],
    ['null as errinfo$s','_errinfo','40']
  ]);
  Frg1.Opt.SetTable('v_estimate_for_edit_dlg', 'estimate_items');
  Frg1.Opt.SetGridOperations('uaid');
  Frg1.Opt.SetWhere('where id_estimate = :id$i order by id_group');
  //если данные для редактирования переданы оберткой (TOrders.LoadEstimate) через массив - используем их вместо прямой загрузки из БД;
  //признак фиксируем на момент подготовки формы, т.к. EstDlgHasInput - это временный "боковой канал", сбрасываемый вызывающим кодом сразу после ShowModal2
  FUseInputArray := EstDlgHasInput;
  if FUseInputArray then
    Frg1.SetInitData(EstDlgInputItems)
  else
    Frg1.SetInitData('*', [FIdEstimate]);
  Frg1.Opt.Caption := 'Сметные позиции';
  Frg1.Opt.SetPick('id_group', A.VarDynArray2ColToVD1(Orders.BcadGroups, 0), A.VarDynArray2ColToVD1(Orders.BcadGroups, 1), True);
  Frg1.Opt.SetPick('id_unit', A.VarDynArray2ColToVD1(Orders.BcadUnits, 0), A.VarDynArray2ColToVD1(Orders.BcadUnits, 1), True);
  Frg1.Opt.SetPick('type', ['Материал', 'Изделие', 'Полуфабрикат'], [0, 1, 2], True);
  O.AlwaysVerifyAllTable:= True;
  O.FieldsNoRepaeted:=['name'];
  Frg1.EditOptions := O;
  FOpt.InfoArray:= [[
  'Ввод сметы.'#13#10
  ]];
  Result := inherited;
  //проверим таблицу (с запросом к бд по каждой позиции)
  //VerifyTable;
end;

function TFrmOGedtEstimate.PrepareFormAdd: Boolean;
begin
  Frg1.Opt.SetButtons(4, [
    [mbtExcel, True, 'Загрузить смету из файла'],
    [mbtLoad, True, 'Загрузить текущую смету из БД'],
    [mbtToClipboard, True, 'Скопировать смету в буфер'],
    [mbtFromClipboard, True, 'Вставить смету из буфера'],
    [mbtInsertRow, alopInsertEh in Frg1.Opt.AllowedOperations],
    [mbtAddRow, alopAppendEh in Frg1.Opt.AllowedOperations],
    [mbtDeleteRow, alopDeleteEh in Frg1.Opt.AllowedOperations],
    [mbtDividorA],[-4]
//    [-1001, FTypeOfItem <> 2, 'Создать полуфабрикат'],
//    [-1002, FTypeOfItem <> 2, 'Редактировать смету полуфабриката']
    ], cbttBSmall, pnlFrmBtnsR
  );
  Result := True;
end;

procedure TFrmOGedtEstimate.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
//обработка нажатий кнопок фрейма
begin
  Handled := True;
  if (Tag = mbtLoad) and (MyQuestionMessage('Загрузить текущую смету из базы данных?') = mrYes) then
    Frg1.LoadData('*', [FIdEstimate])
  else if Tag = mbtExcel then
    LoadFromXls
  else if Tag = mbtFromClipboard then
    LoadFromBuffer
  else if Tag = mbtToClipboard then
    SaveEstimateToBuffer
  else begin
    Handled := False;
    inherited;
  end;
end;

procedure TFrmOGedtEstimate.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
   Cth.SetButtonState(Fr, 1001, null, null, Fr.GetValue('id_group') = cIdSemiproduct);
   Cth.SetButtonState(Fr, 1002, null, null, Fr.GetValue('id_group') = cIdSemiproduct);
end;

procedure TFrmOGedtEstimate.Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
//обработка нажатий кнопок в таблице
var
  va: TVarDynArray;
  i: Integer;
begin
  Wh.SelectDialogResult := [];
  if TCellButtonEh(Sender).Hint = 'Выбрать материал' then begin
    Wh.ExecReference(myfrm_R_bCAD_Nomencl_SelMaterials, Self, [myfoDialog, myfoModal], null);
    if Length(Wh.SelectDialogResult) = 0 then
      Exit;
    Frg1.SetValue('name', Wh.SelectDialogResult[2]);
    LoadItemFromDB(Frg1.RecNo - 1);
  end
  else if TCellButtonEh(Sender).Hint = 'Выбрать полуфабрикат' then begin
    Wh.ExecReference(myfrm_R_OrderStdItems_SelSemiproduct, Self, [myfoDialog, myfoModal], FGroupOfItem);
    if Length(Wh.SelectDialogResult) = 0 then
      Exit;
    Frg1.SetValue('name', Wh.SelectDialogResult[1]);
    LoadItemFromDB(Frg1.RecNo - 1);
  end
  else if TCellButtonEh(Sender).Hint = 'Выбрать производственное изделие' then begin
    Wh.ExecReference(myfrm_R_OrderStdItems_SelProdStdItem, Self, [myfoDialog, myfoModal], FGroupOfItem);
    if Length(Wh.SelectDialogResult) = 0 then
      Exit;
    Frg1.SetValue('name', Wh.SelectDialogResult[1]);
    LoadItemFromDB(Frg1.RecNo - 1);
  end
  else if TCellButtonEh(Sender).Hint = 'Выбрать нестандартное изделие' then begin
    Wh.ExecReference(myfrm_R_OrderStdItems_SelProdNStdItem, Self, [myfoDialog, myfoModal], FGroupOfItem);
    if Length(Wh.SelectDialogResult) = 0 then
      Exit;
    Frg1.SetValue('name', Wh.SelectDialogResult[1]);
    LoadItemFromDB(Frg1.RecNo - 1);
  end
  else if TCellButtonEh(Sender).Hint = 'Выбрать изделие' then begin
    Wh.ExecReference(myfrm_R_OrderStdItems_SEL, Self, [myfoDialog, myfoModal], null);
    if Length(Wh.SelectDialogResult) = 0 then
      Exit;
    Frg1.SetValue('name', Wh.SelectDialogResult[1]);
    LoadItemFromDB(Frg1.RecNo - 1);
  end
  else if TCellButtonEh(Sender).Hint = 'Смета' then begin
    if not ((Frg1.GetValueS('type_of_item') = '') or (Frg1.GetValueS('type_of_item') = 'Н')) and (Fr.GetValueS('id_item_estimate') <> '') then
      TFrmOGedtEstimate.Show(Self, myfrm_R_Estimate, [myfoDialog, myfoSizeable, myfoMultiCopy], fEdit, Fr.GetValue('id_or_std_item'), 1);
  end
  else if TCellButtonEh(Sender).Hint = 'Изделие' then begin
    if not ((Frg1.GetValueS('type_of_item') = '') or (Frg1.GetValueS('type_of_item') = 'Н')) then
      Wh.ExecDialog(myfrm_Dlg_R_OrderStdItems, Self, [], fView, Fr.GetValue('id_or_std_item'), 0);
  end;
  VerifyRow(Fr.RecNo - 1, True);
  //VerifyTable;
end;

procedure TFrmOGedtEstimate.Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string);
//выполняем действия после изменения данных в ячейках таблицы вручну
begin
end;

procedure TFrmOGedtEstimate.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
//подсветим ошибки и предупреждения
begin
  if Fr.GetValue('newpos').AsIntegerM = 1 then
    Params.Background := clYellow;
  if (FieldName = 'qnt_on_stock') and (Fr.GetValue('qnt_on_stock') <> null) and (Fr.GetValue('qnt1') <> null) then begin
    if Fr.GetValueF('qnt_on_stock') = 0 then
      Params.Background := clRed
    else if Fr.GetValueF('qnt1') > Fr.GetValueF('qnt_on_stock') then
      Params.Background := clYellow;
  end;
  if (FieldName = 'type_of_item') then begin
    if (Fr.GetValueS('id_item_estimate') = '') and (A.InArray(Fr.GetValueS('type_of_item'), ['П', 'ПФ'])) then
      Params.Font.Color := clRed;
    if (Fr.GetValueS('type_of_item') = 'О') then
      Params.Background := clRed;
  end;
  if (FieldName = 'name') then begin
    var st := Fr.GetValueS('name');
    if (Trim(st) <> st) or (Pos('  ', st) > 0) then
      Params.Background := clRed;
    //совпадение с именем или полным именем с префиксом изделия (стандартного или заказа)
//    if (st = AddParam[3]) or (st = AddParam[4]) then
//      Background := clRed;
  end;
end;

procedure TFrmOGedtEstimate.Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
  //запретим менять ед.изм. у готовых изделий и пф
  if ((Fr.GetValueI('id_group') = cIdProduct) or (Fr.GetValueI('id_group') = cIdSemiproduct)) and ({(Fr.CurrField = 'id_group') or }(Fr.CurrField = 'id_unit')) then
    ReadOnly := True;
  //заперетим ставить галку покупное, если это не ПФ
  if (Fr.GetValueI('id_group') <> cIdSemiproduct) and (Fr.CurrField =  'purchase') then
    ReadOnly := True;
end;

procedure TFrmOGedtEstimate.btnClick(Sender: TObject);
var
  Tag: Integer;
begin
  Tag := TControl(Self).Tag;
end;

procedure TFrmOGedtEstimate.Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
//после ручного ввода данных в ячейку
begin
  //при изменении наименования - загрузим по нему информацию из бд
  if A.InArray(FieldName, ['name']) then
    LoadItemFromDB(Fr.RecNo - 1);
  //при изменепнии наименования или группы проверяем валидность, выполняя хранимую процедуру
  if A.InArray(FieldName, ['name', 'id_group']) then begin
    VerifyRow(Fr.RecNo - 1, True);
  end;
end;

procedure TFrmOGedtEstimate.Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
  if (Fr.CurrField = 'err') and (Fr.GetValueI('err') <> 0) then
    MyInfoMessage(Fr.GetValueS('errinfo'), 1);
end;

procedure TFrmOGedtEstimate.VerifyRow(Row: Integer; Filtered: Boolean);
//проверим на ошибки (типа: это по группе материал, но есть в справочнике стд.изд.), запросив БД. сохраним результат в служебном столбце
const
  c = 3;
begin
  {
  p_estimate_type in varchar2, --тип объекта, к которому смета (П,О,ПФ,Н)
  p_group_id    in  number,  --айди группы бкад
  p_name        in  varchar2,--наименование
  p_group_std   in  number,  --айди группы стандартных изделий для родительской сметы
  p_result      out number,  --тип результата: 0 = ок, -1 = ошибка, 1 - предупреждение
  p_id_std_item out number,  --айди стандартнорго изделия для данной позиции
  p_id_estimate out number,  --айди сметы по данной позиции
  p_type_of_item out varcahr2,  --тип стандартного изделия ('',П,О,ПФ,Н)
  p_is_new_position out number,  --позиции нет в ИТМ
  p_message      out varchar2  --текст ошибки, или сообщения
  }
  var Res := Q.QCallStoredProc('p_test_estimate_item',
    'i1$s;i2$i;i3$s;i4Si;' +
    'o1$io;o2$io;o3$io;o4$so;o5$io;o6$so',
    [FTypeOfItem, Frg1.GetValue('id_group', Row, Filtered), Frg1.GetValueS('name', Row, Filtered), FGroupOfItem, -1, -1, -1, '', -1, '']);
  Frg1.SetValue('err', Row, Filtered, Res[c + 1]);
  Frg1.SetValue('id_or_std_item', Row, Filtered, Res[c + 2]);
  Frg1.SetValue('id_item_estimate', Row, Filtered, Res[c + 3]);
  Frg1.SetValue('type_of_item', Row, Filtered, Res[c + 4]);
  Frg1.SetValue('newpos', Row, Filtered, Res[c + 5]);
  Frg1.SetValue('errinfo', Row, Filtered, Res[c + 6]);
end;

procedure TFrmOGedtEstimate.VerifyBeforeSave;
//стандартная процедура проверки при нажатии кнопки Ок
begin
  Frg1.SetState(null, False, '');
  var LErrorMessage := '';
  var LWarningMessage := '';
  //еще раз проверим путем обращения к хранимой процедуре
  VerifyTable;
  //пройдем по гриду и соберем ошибки и предупреждения
  for var i := 0 to Frg1.GetRawCount - 1 do begin
    if Frg1.GetRawValue('err', i) = -1 then
      S.ConcatStP(LErrorMessage, IntToStr(i + 1) + ' - ' + Frg1.GetRawValueS('errinfo', i), #13#10)
    else if Frg1.GetRawValue('err', i) = 1 then
      S.ConcatStP(LWarningMessage, IntToStr(i + 1) + ' - ' + Frg1.GetRawValueS('errinfo', i), #13#10);
  end;
  FErrorMessage := '';
  if LErrorMessage <> '' then begin
    Frg1.SetState(null, True, LErrorMessage);
    FErrorMessage := 'В смете есть ошибки:'#13#10#13#10 + LErrorMessage + #13#10#13#10'Сохранить смету невозможно!';
  end
  else if LWarningMessage <> '' then begin
    FErrorMessage := '?' + 'Есть следующие замечания по смете:'#13#10#13#10 + LWarningMessage + #10#13#10#13'Записать смету?';
  end;
end;

procedure TFrmOGedtEstimate.VerifyTable(AReloadStatus: boolean = False);
//проверяем данные в таблице путем вызова хранимой процедуры для каждой строки
begin
  for var i := 0 to Frg1.GetRawCount - 1 do begin
    VerifyRow(i, False);
  end;
end;

function TFrmOGedtEstimate.Save: Boolean;
begin
  Result := SaveEstimate;
end;

procedure TFrmOGedtEstimate.LoadFromDB;
begin
  Frg1.SetInitData('*', [ID]);
  VerifyTable;
end;


procedure TFrmOGedtEstimate.LoadFromXls;
//загрузим смету из файла эксель
var
  i, j: Integer;
  Est: TVarDynArray2;
  FileName: string;
  va: TVarDynArray;
  va1, va2: TVarDynArray2;
  st : string;
begin
  FileName := '';
  //смету в массив
  if not Orders.EstimateFromFile(FileName, Est) then
    Exit;
  EstDlgSourceUsed := 1;
  //массив в мемтейбл
  Frg1.LoadSourceDataFromArray(Est, 'name;id_group;id_unit;qnt1;comm', '');
  st := '';
  //пройдем по данным, проверим в группе Крепёж по короткому имени, нет ли совпадения с именем полуфабриката или изделия в группе изделий для данной сметы
  //(такая ситуация будет при выгрузке из бкад, где в эту группу выгрузятся полуфабрикаты, но без префиксов)
  //если найдено единственнная такая позиция, то поставим группу, соответсвующую типу изделия, если найдено нсколько - очистим группу
  {for i := 0 to Frg1.GetCount(False) do begin
    if Frg1.GetValueI('id_group', i, False) = cIDKrep then begin  //Крепёж
      va2 := Q.QLoad('select fullname, id_format from v_or_std_items where name = :name$s and type = 0 and id_format = :f$i', [Frg1.GetValue('name', i, False), FGroupOfItem]);
      if Length(va2) > 0 then begin
        S.ConcatStP(st, Frg1.GetValue('name', i, False) + ' - является изделием!', #13#10);
        Frg1.SetValue('id_group', i, False, IIf(Length(va2) = 1, cIdProduct, null));
      end;
    end
    else begin
      va2 := Q.QLoad('select fullname, id_format from v_or_std_items where name = :name$s and type = 2 and (id_format = 0 or id_format = :f$i)', [Frg1.GetValue('name', i, False), FGroupOfItem]);
      if Length(va2) > 0 then begin
        S.ConcatStP(st, Frg1.GetValue('name', i, False) + ' - является полуфабрикатом!', #13#10);
        Frg1.SetValue('id_group', i, False, IIf(Length(va2) = 1, cIdSemiproduct, null));
      end;
    end;
  end;}
  //выполним проверку с чтением данных из БД
  VerifyBeforeSave;
  //выдадим сообщение, если была подмена группы
  if st <> '' then
    MyInfoMessage(st, 1);
end;

procedure TFrmOGedtEstimate.LoadFromBuffer;
//загрузим смету из личного буфера пользователя (заполняется кнопкой "Скопировать смету" в справочнике стандартных изделий,   //!!!
//см. Orders.CopyEstimateToBuffer; хранится как смета с id_estimate = -id_user)
begin
  if MyQuestionMessage('Вставить смету из буфера?') <> mrYes then
    Exit;
  if Q.QLoadValue('select count(*) from v_estimate where id_estimate = :id_estimate$i', [-User.GetId]) = 0 then begin
    MyWarningMessage('Буфер обмена смет пуст!');
    Exit;
  end;
  EstDlgSourceUsed := 2;
  Frg1.SetInitData('*', [ID]);
  VerifyTable;
end;

procedure TFrmOGedtEstimate.LoadItemFromDB(Row: Integer);
//загрузим из базы информацию по данному наименованию сметной позиции
var
  na: TNamedArr;
begin
  Q.QLoadRow('select ' + Frg1.GetFieldNamesEx('1').Implode(', ') + ' from ' + Frg1.Opt.Sql.View + ' where name = :name$s', [Frg1.GetValue('name', Row, True)], na);
  if na.Count > 0 then
    Frg1.LoadRow(na, Row, True);
end;

procedure TFrmOGedtEstimate.SaveEstimateToBuffer;
begin
  if MyQuestionMessage('В буфер будет скопирована уже сохраненная смета! Изменения, сделанные в этом окне без сохранения сметы, скопированы не будут! Продолжить?') <> mrYes then
    Exit;
   Orders.CopyEstimateToBuffer(S.IIf(AddParam = 1, ID, null), S.IIf(AddParam <> 1, ID, null));
end;

function TFrmOGedtEstimate.SaveEstimate: Boolean;
var
  Res: Integer;
  i, j: Integer;
begin
  Result := False;
  if FUseInputArray then begin
    //режим "массив в/массив из" (вызов из обертки TOrders.LoadEstimate) - в БД ничего не пишем,
    //а только формируем результирующий массив, который обертка заберет из EstDlgResultItems и сохранит сама
    EstDlgResultItems := Frg1.ExportToNa('id;id_estimate;id_or_std_item;id_item_estimate;type_of_item;id_group;name;id_unit;qnt1;qnt_on_stock;comm', False);
    Result := True;
  end;
  Exit;
  Q.QBeginTrans(True);
  Q.QSave(S.IIFStr(FIdEstimate = null, 'i', 'u')[1], 'estimates', '',
   'id$i;id_std_item$i;id_order_item$i;isempty$i;dt$d',
   [FIdEstimate, S.IIf(AddParam = 1, ID, null), S.IIf(AddParam = 0, ID, null), False, Date]);
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    if Length(Q.QCallStoredProc('p_createestimateitem',
      'pid_estimate$i;pid_group$i;pname$s;pid_unit$i;pcomment$s;pqnt1$f;pqnt$f',
       [FIdEstimate, Frg1.GetValue('id_group', i, False), Frg1.GetValue('name', i, False), Frg1.GetValue('id_unit', i, False),
        Frg1.GetValue('comm', i, False), Frg1.GetValue('qnt1', i, False), Frg1.GetValue('qnt1', i, False) * S.IIf(AddParam = 0, FQntOfItem, 1)] //!!!округление
       )) = 0 then
      Break;
  end;
  //скорректируем смету с учетом автозамены, проставим количества для итм
  Q.QCallStoredProc('p_CorrectEstimateWithReplace', 'id_estimate$i', [FIdEstimate]);
  //удалим смету, если в ней нет ни одного элемента
  Q.QCallStoredProc('p_DeleteFreeEstimate', 'id_estimate$i', [FIdEstimate]);
  //синхронизируем с ИТМ, в случае если загружается смета только по одному изделию заказа
  if AddParam = 0 then
    Orders.SyncOrderWithITM(FIdOfOrder, [ID], False);
  Q.QCommitOrRollback(True);
  Result := Q.CommitSuccess;
end;

end.


что можно выбирать в нестандартном изделии?????


везде проверить работу с фильтром!!!
