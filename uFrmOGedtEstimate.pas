unit uFrmOGedtEstimate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uFrmBasicEditabelGrid, uLabelColors
  ;

type
  TFrmOGedtEstimate = class(TFrmBasicEditabelGrid)
  private
    Err, Err2: TVarDynArray;
    IdSemiproduct, IdProduct,  IdStuff: Integer;
    IsOrderItem: Boolean;    //это смета к иизделию заказа, а не к стандартному
    IdOfStdItem: Integer;    //айди стандартного изделия, к которому смета (непосредственно, или из спецификации заказа)
    GroupOfItem: Integer;    //группа стандартных изделий, к которой относится изделие сметы
    TypeOfItem: Integer;     //тип изделия, к которому относиттся смета (произв., отгр., п/ф)
    IsItemStd: Boolean;      //изделие сметы является стандартным
    function  PrepareForm: Boolean; override;
    function  PrepareFormAdd: Boolean; override;
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string); override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); override;
    procedure btnClick(Sender: TObject); override;
    procedure VerifyRow(Row: Integer);
    procedure VerifyBeforeSave; override;
    function  Save: Boolean; override;
    procedure VerifyTable(AReloadStatus: boolean = False);
    procedure LoadFromDB;
    procedure LoadFromXls;
    procedure LoadItemFromDB(Row: Integer);
  protected
  public
  end;

var
  FrmOGedtEstimate: TFrmOGedtEstimate;

implementation

uses
  uOrders,
  uWindows
  ;

{$R *.dfm}

function TFrmOGedtEstimate.PrepareForm: Boolean;
var
  i: Integer;
  o: TFrDBGridEditOptions;
  va: TVarDynArray;
begin
  Caption := 'Смета';

  va := Q.QSelectOneRow('select id_std_item, id_order_item from estimates where id = :id$i', [ID]);
  if TVarDynArray(AddParam)[1] = 0 then
    IdOfStdItem := va[0]
  else
    IdOfStdItem := Q.QSelectOneRow('select id_std_item from order_items where id = :id$i', [va[1]])[0];
  GroupOfItem := Q.QSelectOneRow('select id_format from or_format_estimates where id = (select id_or_format_estimates from or_std_items where id = :id$i)', [IdOfStdItem])[0];
  TypeOfItem := Q.QSelectOneRow('select type from or_format_estimates where id = (select id_or_format_estimates from or_std_items where id = :id$i)', [IdOfStdItem])[0];

  FTitleTexts := [S.IIf(TVarDynArray(AddParam)[1] = 0, 'Смета к стандартному изделию:', 'Смета кизделию заказа:'),  {'$FF0000' + }TVarDynArray(AddParam)[2]];
  pnlTop.Height := 50;

  Orders.LoadBcadGroups(True);

  IdSemiproduct := 2;
  IdProduct := 104;
  IdStuff := 1;


  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['id_or_std_item$i','_id_or_std_item','40'],
    ['id_group$i','Группа','250;w;L','e=1:100000::TP'],
    ['name$s','Наименование','400;w;h','e=1:1000','bt=Выбрать материал:М:::090' + S.IIFStr(TypeOfItem <> 2, ';Выбрать полуфабрикат:П:::909') + S.IIFStr(TypeOfItem = 1, ';Выбрать производственное изделие:И:::009') ],
    ['id_unit$i','Ед.изм.','100;L','e=0:1000000::TP'],
    ['qnt1$f','Кол-во','80','e=0:999999:5:N'], {недопустимо пустое кол-во}
    ['null as purchase$i','Покупка','80','chb','e'],
    ['comm$s','Дополнение','300;w;h','e=0:1000::TP'],
    ['null as flags$s','_flags','40']
  ]);
  Frg1.Opt.SetTable('v_estimate', 'estimate_items');
  Frg1.Opt.SetGridOperations('uaid');
  Frg1.Opt.SetWhere('where id_estimate = :id$i order by id_group');
  Frg1.SetInitData('*', [ID]);
  Frg1.Opt.Caption := 'Сметные позиции';

  Frg1.Opt.SetPick('id_group', A.VarDynArray2ColToVD1(Orders.BcadGroups, 0), A.VarDynArray2ColToVD1(Orders.BcadGroups, 1), True);
  Frg1.Opt.SetPick('id_unit', A.VarDynArray2ColToVD1(Orders.BcadUnits, 0), A.VarDynArray2ColToVD1(Orders.BcadUnits, 1), True);
  Frg1.Opt.SetPick('type', ['Материал','Изделие','Полуфабрикат'], [0,1,2], True);

  o.AlwaysVerifyAllTable:= True;
  O.FieldsNoRepaeted:=['name'];
  Frg1.EditOptions := o; //(AlwaysVerifyAllTable: True);

//  .AlwaysVerifyAllTable := True

//  Frg1.Dbgrideh1.Columns[4].CellButtons[0].Caption :='М';
//  Frg1.Dbgrideh1.Columns[3].CellButtons[1].Caption :='И';

  FOpt.InfoArray:= [[
  'Ввод сметы.'#13#10
  ]];
  Result := inherited;
end;

function TFrmOGedtEstimate.PrepareFormAdd: Boolean;
begin
  Frg1.Opt.SetButtons(4, [
    [mbtExcel, True, 'Загрузить смету из файла'],
    [mbtLoad, True, 'Загрузить текущую смету из БД'],
    [mbtPasteEstimate, True, 'Вставить смету из буфера'],
    [mbtInsertRow, alopInsertEh in Frg1.Opt.AllowedOperations],
    [mbtAddRow, alopAppendEh in Frg1.Opt.AllowedOperations],
    [mbtDeleteRow, alopDeleteEh in Frg1.Opt.AllowedOperations],
    [mbtDividorA],[-4],
    [-1001, TypeOfItem <> 2, 'Создать полуфабрикат'],
    [-1002, TypeOfItem <> 2, 'Редактировать смету полуфабриката']],
    cbttBSmall, pnlFrmBtnsR
  );
  Result := True;
end;

procedure TFrmOGedtEstimate.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
//обработка нажатий кнопок фрейма
begin
  Handled := True;
  if (Tag = mbtLoad) and (MyQuestionMessage('Загрузить текущую смету из базы данных?') = mrYes) then
    Frg1.LoadData('*', [ID])
  else if Tag = mbtExcel then
    LoadFromXls
  else begin
    Handled := False;
    inherited;
  end;
end;

procedure TFrmOGedtEstimate.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
   Cth.SetButtonState(Fr, 1001, null, null, Fr.GetValue('id_group') = IdSemiproduct);
   Cth.SetButtonState(Fr, 1002, null, null, Fr.GetValue('id_group') = IdSemiproduct);
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
    Wh.ExecReference(myfrm_R_OrderStdItems_SelSemiproduct, Self, [myfoDialog, myfoModal], GroupOfItem);
    if Length(Wh.SelectDialogResult) = 0 then
      Exit;
    Frg1.SetValue('name', Wh.SelectDialogResult[1]);
    LoadItemFromDB(Frg1.RecNo - 1);
  end
  else if TCellButtonEh(Sender).Hint = 'Выбрать производственное изделие' then begin
    Wh.ExecReference(myfrm_R_OrderStdItems_SelProdStdItem, Self, [myfoDialog, myfoModal], GroupOfItem);
    if Length(Wh.SelectDialogResult) = 0 then
      Exit;
    Frg1.SetValue('name', Wh.SelectDialogResult[1]);
    LoadItemFromDB(Frg1.RecNo - 1);
  end;
  VerifyRow(Fr.RecNo - 1);
  VerifyTable;
end;


procedure TFrmOGedtEstimate.Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string);
//выполняем действия после изменения данных в ячейках таблицы вручну
begin
  if Mode <> dbgvCell then
    Exit;
  //только для группы и наименования
  if (Fr.GetValue('id_group') = null) or (Fr.GetValue('name') = null) then
    Exit;
  if A.InArray(FieldName, ['name', '--id_group']) then begin
    LoadItemFromDB(Row - 1);
  end;
  VerifyRow(Row - 1);
  VerifyTable;
end;

procedure TFrmOGedtEstimate.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
//подсветим ошибки и предупреждения
begin
  if Fr.GetValueS('flags') = '' then
    Exit;
  if Fr.GetValueS('flags')[1] = '0' then
    Params.Background := clYellow
  else if Fr.GetValueS('flags')[1] = '1' then
    Params.Background := clRed
  else if Fr.GetValueS('flags')[1] = '2' then
    Params.Background := RGB(255, 0, 255)
  else if Fr.GetValueS('flags')[1] = '3' then
    Params.Background := RGB(100, 0, 255);
end;

procedure TFrmOGedtEstimate.Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
  //запретим менять ед.изм. у готовых изделий и пф
  if ((Fr.GetValueI('id_group') = IdProduct) or (Fr.GetValueI('id_group') = IdSemiproduct)) and ({(Fr.CurrField = 'id_group') or }(Fr.CurrField = 'id_unit')) then
    ReadOnly := True;
  //заперетим ставить галку покупное, если это не ПФ
  if (Fr.GetValueI('id_group') <> IdSemiproduct) and (Fr.CurrField =  'purchase') then
    ReadOnly := True;
end;

procedure TFrmOGedtEstimate.btnClick(Sender: TObject);
var
  Tag: Integer;
begin
  Tag := TControl(Self).Tag;
end;

procedure TFrmOGedtEstimate.VerifyRow(Row: Integer);
//проверим на ошибки (типа: это по группе материал, но есть в справочнике стд.изд.), запросив БД. сохраним результат в служебном столбце
var
  st: string;
begin
  Frg1.SetValue('flags', Row, False, S.NSt(Q.QSelectOneRow('select F_TestEstimateItem_New(:g$i, :n$s, :sg$i) from dual', [Frg1.GetValue('id_group', Row, False), Frg1.GetValue('name', Row, False), GroupOfItem])[0]));
end;

procedure TFrmOGedtEstimate.VerifyBeforeSave;
//стандартная процедура проверки при нажатии кнопки Ок
begin
  //проверим таблицу с выполнением запросов к бд по кажждой строке
  VerifyTable(True);
end;

procedure TFrmOGedtEstimate.VerifyTable(AReloadStatus: boolean = False);
//проверяем таблицу
//вызываем при каждом изменении данных без запросов к бд в эитой процедуре, и после загрузки и перед записью - с запросами
var
  i, j, k, m: Integer;
  Err: TVarDynArray;
  st: string;
  b: Boolean;
begin
  Err := [];
  b := True;
  //стандартная проврка таблицы фрейма на корректномть - по маскам редактирования и на повторяющиеся значения в таблице
  Frg1.IsTableCorrect;
  if Frg1.ErrorMessage <> '' then
    b := FaLse;
  //дополнительная проверка по базу данных
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    //--проверим правильность и новизну сметной позиции, вернем в строке
    //--1й символ = 0 если нет такой позция в справочнике номенклатуры бкад
    //--2й символ = 0 - ошибка для номенклатуры из группы Изделий - нет такого изделия в v_or_std_items
    //--3й символ = 0 - ошибка для номенклатуры из группы сметных позиций бкад - номенклатура найдена в списке изделий, при этом являясь материалом согласно группе
    st := Frg1.GetValueS('flags', i, False);
    if AReloadStatus then begin
      st := S.NSt(Q.QSelectOneRow('select F_TestEstimateItem_New(:g$i, :n$s, :sg$i) from dual', [Frg1.GetValueS('id_group', i, False), Frg1.GetValueS('name', i, False), GroupOfItem])[0]);
      Frg1.SetValue('flags', i, False, st);
    end;
    if st <> '' then begin
      if st[1] <> '0' then
        b := False;  //были ошибки, с которыми сохранять смету нельзя.
      Err := Err + ['[ ' + Frg1.GetValueS('name', i, False) + ' ] - ' + Copy(Frg1.GetValueS('flags', i, False), 3)];
    end;
  end;
  FErrorMessage := '';
  if (Frg1.ErrorMessage = '') and (Length(Err) = 0) then begin
    Frg1.SetState(null, False, '');
  end
  else begin
    FErrorMessage := S.ConcatSt(Frg1.ErrorMessage, A.Implode(Err, #13#10), #13#10);
    Frg1.SetState(null, not b, FErrorMessage);
    if b then
      FErrorMessage := '?' + FErrorMessage + #10#13#10#13 + 'Записать смету?';
  end;
end;

function  TFrmOGedtEstimate.Save: Boolean;
var
  i: Integer;
begin
  Result := False;
Exit;
  Wh.SelectDialogResult2 := [];
  for i := 0 to Frg1.GetCount - 1 do begin
    if Frg1.GetValueS('name', i, False) <> '' then
      Wh.SelectDialogResult2 := Wh.SelectDialogResult2 + [[Frg1.GetValue('name'), Frg1.GetValue('id_group'), Frg1.GetValue('id_unit'), Frg1.GetValue('qnt1'), Frg1.GetValue('comm')]];
  end;
  //Result := True;
end;

procedure TFrmOGedtEstimate.LoadFromDB;
begin
  Frg1.SetInitData('*',[]);
  VerifyBeforeSave;
end;

procedure TFrmOGedtEstimate.LoadFromXls;
var
  i, j: Integer;
  Est: TVarDynArray2;
  FileName: string;
begin
  FileName := '';
  if not Orders.EstimateFromFile(FileName, Est) then
    Exit;
  Frg1.LoadSourceDataFromArray(Est, 'name;id_group;id_unit;qnt1;comm', '');//, '3;2;4;5;7');
  VerifyBeforeSave;
end;

procedure TFrmOGedtEstimate.LoadItemFromDB(Row: Integer);
//загрузим из базы информацию по данному наименованию сметной позиции
var
  i, j: Integer;
  va: TVarDynArray;
begin
  va := Q.QSelectOneRow('select id, is_semiproduct from v_or_std_items where fullname = :fullname$s', [Frg1.GetValue('name', Row, False)]);
  if va[0] <> null then begin
    //это изделие
    Frg1.SetValue('id_group', S.IIf(va[1] = 1, IdSemiproduct, IdProduct));
    Frg1.SetValue('id_unit', IdStuff);
  end
  else begin
    //это материал
    va := Q.QSelectOneRow('select id, id_group, id_unit from v_estimate where name = :name$s', [Frg1.GetValue('name', Row, False)]);
    if va[0] <> null then begin
      Frg1.SetValue('id_group', va[1]);
      Frg1.SetValue('id_unit', va[2]);
    end;
  end;
  //очистим галку покупной, если это не полуфабрикат
  if Frg1.GetValue('id_group') <> Group_Semiproducts_Id then
    Frg1.SetValue('purchase', 0);
end;




end.
