{
диалог распределения количества изделий по отгрузочным заказам ("паспортам"), созданным на основании одного
производственного заказа (см. постановку задачи в переписке; вызов - меню журнала заказов, пункт
"Распределить изделия в отгрузочных паспортах", uFrmOGjrnOrders.pas, Tag = 1009).

в шапке (нередактируемой) - информация о производственном заказе: номер, тип, даты создания/отгрузки, проект.

в таблице по одной строке на каждую позицию (слеш) производственного заказа: слеш, наименование, количество по
производственному, по одной редактируемой колонке количества на каждый отгрузочный заказ серии (редактировать
можно только количество в заказах, ещё находящихся в статусе "Черновик" - у остальных колонка нередактируема),
общее введенное количество (сумма по всем отгрузочным), превышение (общее введенное минус количество по
производственному), количество на СГП (пока заглушка - 0, соответствующая вью ещё не написана) и дополнение
(из позиции производственного заказа).

при ручном редактировании количества по одной из колонок пользователю предлагается пересчитать (перераспределить)
количество по этой же строке в ПОСЛЕДУЮЩИХ (более новых, по id, т.е. по порядку создания в серии) заказах, ещё
являющихся черновиками - см. CascadeRecalcRow. то же самое можно сделать явно, двойным кликом по редактируемой
ячейке количества (без вопроса).

базовый класс - TFrmBasicEditabelGrid (единственный грид Frg1); структура грида - по аналогии с
uFrmOGrepItemsInOrder.pas, редактирование/проверка значений - по аналогии с гридом состава заказа в uFrmOWOrder.pas
(FrgItems). шапка (нередактируемая) - НЕ через FTitleTexts/CreateLabelColors (с этим механизмом были проблемы -
нечитаемое отображение), а статичные TLabel (lblCapt1, lblCapt2), добавленные вручную в pnlTop в .dfm, по аналогии
с uFrmOWrepStdItemsGroupCheck.pas; текст выставляется в PrepareForm так же, как там.

сохранение (см. Save) выполняется не штатным механизмом грида (Frg1 используется только в режиме 'u' - обновление,
без добавления/удаления строк, и без сохранения через Q.QSave), а самостоятельными UPDATE по каждой измененной
позиции измененных (черновых) отгрузочных заказов; сопоставление позиции внутри заказа - по полю id_std_item (а НЕ
по slash/"Паспорт" - выяснилось, что slash не копируется при создании заказа, а вычисляется в v_order_items как
ornum текущего заказа + pos, т.е. всегда РАЗНЫЙ у производственного и у каждого отгрузочного заказа серии; кроме
того, в order_items вообще нет физической колонки slash - см. SQL/d_orders.sql). id_std_item, наоборот, при простом
копировании состава заказа не переопределяется и остаётся тем же, что и у производственного заказа, в т.ч. для
нестандартных изделий (см. также аналогичный подход и комментарий в uFrmOWOrder.pas/PrepareFrgItems, где по
id_std_item считается уже отгруженное количество, и про id_std_item/MY_IDS_INSERTED_MIN).
}
unit uFrmOGedtDistributeQnt;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uFrmBasicMdi, uFrmBasicGrid2, uFrmBasicEditabelGrid, uFrDBGridEh, uNamedArr,
  uLabelColors
  ;

type
  TFrmOGedtDistributeQnt = class(TFrmBasicEditabelGrid)
    lblCapt1: TLabel;
    lblCapt2: TLabel;
  private
    //производственный заказ, для которого распределяем количество (совпадает с ID этой формы)
    FIdProduction: Variant;
    //отгрузочные заказы, созданные на основании производственного (без удаленных), отсортированы по id - именно
    //в этом порядке (по порядку создания) ведется каскадный пересчет количества; поля: id$i, ornum$s, id_status$i
    FSiblingOrders: TNamedArr;
    //имя динамической колонки количества грида для заказа с данным id
    function QntFieldName(AOrderId: Variant): string;
    //id заказа (из FSiblingOrders) по имени его колонки количества, или Null, если поле не является такой колонкой
    function OrderIdByFieldName(const AFieldName: string): Variant;
    //пересчитать (в самом гриде) поля "Общее введено"/"Превышение" для ТЕКУЩЕЙ строки грида
    procedure RecalcRowTotals;
    //каскадный пересчет количества по ТЕКУЩЕЙ строке грида, начиная от заказа AEditedOrderId (которому уже
    //присвоено в гриде значение AEditedValue) - см. подробный комментарий в реализации
    procedure CascadeRecalcRow(AEditedOrderId: Variant; AEditedValue: Double);
  protected
    function  PrepareForm: Boolean; override;
    function  Save: Boolean; override;
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
    procedure Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
  public
  end;

var
  FrmOGedtDistributeQnt: TFrmOGedtDistributeQnt;

implementation

uses
  uOrders, uDbOra;

{$R *.dfm}

const
  //светло-розовый фон - выделение ячейки "Превышение", если оно положительное (перебор количества по серии заказов)
  clMyExcessColor = $E0E0FF;

function TFrmOGedtDistributeQnt.QntFieldName(AOrderId: Variant): string;
begin
  Result := 'qnt_' + IntToStr(S.NInt(AOrderId));
end;

function TFrmOGedtDistributeQnt.OrderIdByFieldName(const AFieldName: string): Variant;
var
  i: Integer;
begin
  Result := Null;
  for i := 0 to FSiblingOrders.High do
    if SameText(QntFieldName(FSiblingOrders.G(i, 'id')), AFieldName) then
      Exit(FSiblingOrders.G(i, 'id'));
end;

function TFrmOGedtDistributeQnt.PrepareForm: Boolean;
var
  LHeaderRow: TVarDynArray;
  LFields: TVarDynArray2;
  LDtBegStr, LDtOtgrStr: string;
  LProdItems, LOrderItems, LGridData: TNamedArr;
  LGridFieldNames: TVarDynArray;
  LDynField: TVarDynArray;
  LFieldName: string;
  LTotal: Double;
  i, j, LIdx: Integer;
begin
  Result := False;
  FIdProduction := ID;

  //шапка (нередактируемая) - информация о производственном заказе
  LHeaderRow := Q.QLoadRow('select ornum, typename, dt_beg, dt_otgr, project from v_orders where id = :id$i', [FIdProduction]);
  if LHeaderRow[0] = null then begin
    MyWarningMessage('Производственный заказ не найден');
    Exit;
  end;
  if LHeaderRow[2] = null then LDtBegStr := '-' else LDtBegStr := DateToStr(LHeaderRow[2]);
  if LHeaderRow[3] = null then LDtOtgrStr := '-' else LDtOtgrStr := DateToStr(LHeaderRow[3]);
  Caption := 'Распределение количества изделий в отгрузочных заказах';
  //шапка - статичные метки в pnlTop (см. .dfm), а не FTitleTexts/CreateLabelColors (по аналогии с
  //uFrmOWrepStdItemsGroupCheck.pas); подсказка про двойной клик вынесена в Frg1.InfoArray (см. ниже)
  lblCapt1.SetCaption2('$0000A0Производственный заказ № ' + VarToStr(LHeaderRow[0]) + '  (' + VarToStr(LHeaderRow[1]) + ')');
  lblCapt2.Caption := 'Дата создания: ' + LDtBegStr + '    Дата отгрузки: ' + LDtOtgrStr + '    Проект: ' + VarToStr(LHeaderRow[4]);

  //отгрузочные заказы, созданные на основании этого производственного (без удаленных), по порядку создания
  Q.QLoad(
    'select id, ornum, id_status from orders where id_production_order = :id$i and id_status <> :del$i order by id',
    [FIdProduction, ORDER_ID_STATUS_DELETED], FSiblingOrders
  );
  if FSiblingOrders.Count = 0 then begin
    MyWarningMessage('По этому производственному заказу не создано ни одного отгрузочного заказа');
    Exit;
  end;

  //состав полей грида: служебные (скрытые, имя с "_") + слеш/изделие + количество по производственному +
  //по одной колонке количества на каждый отгрузочный заказ серии + итоговые колонки + количество на СГП
  //(заглушка - соответствующая вью ещё не написана) + дополнение (из позиции производственного заказа)
  LFields := [
    ['id$i', '_id', '40', 't=ch0'],
    ['id_std_item$i', '_std', '40', 't=ch0'],
    ['slash$s', 'Паспорт', '90', 't=ch0'],
    ['name$s', 'Изделие', '260;w', 't=ch0'],
    ['qnt_production$f', 'Кол-во (произв.)', '90', 't=ch0']
  ];
  for i := 0 to FSiblingOrders.High do begin
    LDynField := [
      QntFieldName(FSiblingOrders.G(i, 'id')) + '$f',
      'Заказ № ' + FSiblingOrders.G(i, 'ornum').AsString,
      '90',
      'e=0:9999999:0:N',
      't=chg,e'
    ];
    SetLength(LFields, Length(LFields) + 1);
    LFields[High(LFields)] := LDynField;
  end;
  LFields := LFields + [
    ['total_entered$f', 'Общее введено', '90', 't=ch0'],
    ['excess$f', 'Превышение', '90', 't=ch0'],
    ['qnt_sgp$f', 'Кол-во на СГП', '90', 't=ch0'],
    ['comm$s', 'Дополнение', '200;w', 't=ch0']
  ];
  Frg1.Opt.Caption := 'Распределение количества';
  Frg1.Opt.SetFields(LFields);
  Frg1.Opt.SetGridOperations('u');

  //подсказка про двойной клик - не в шапке, а в инфоиконке грида (см. TFrDBGridEh.CreateInfoIcon/Cth.SetInfoIconText)
  Frg1.InfoArray := [
    ['Двойной клик по редактируемой ячейке количества сразу пересчитывает количество по этой же строке в ' +
      'последующих (созданных позже) заказах серии, ещё находящихся в статусе "Черновик" - исходя из значения в ' +
      'этой ячейке. При обычном редактировании ячейки (Enter/Tab) будет предложено сделать то же самое.'#13#10]
  ];

  //редактировать количество можно только в заказах-черновиках - у остальных отключим редактирование колонки целиком
  for i := 0 to FSiblingOrders.High do
    if FSiblingOrders.G(i, 'id_status').AsInteger <> ORDER_ID_STATUS_DRAFT then
      Frg1.Opt.SetColFeature(QntFieldName(FSiblingOrders.G(i, 'id')), 'e', False);

  //состав производственного заказа - "хозяин" строк грида (по одной строке на слеш/позицию)
  Q.QLoad('select id, slash, id_std_item, name, qnt, comm from v_order_items where id_order = :id$i order by pos', [FIdProduction], LProdItems);
  if LProdItems.Count = 0 then begin
    MyWarningMessage('В производственном заказе нет позиций');
    Exit;
  end;

  //подготовим имена полей грида (без суффиксов $...) для инициализации TNamedArr
  LGridFieldNames := [];
  for i := 0 to High(LFields) do
    LGridFieldNames := LGridFieldNames + [Copy(LFields[i][0].AsString, 1, Pos('$', LFields[i][0].AsString) - 1)];
  LGridData.Create(LGridFieldNames, LProdItems.Count);

  for i := 0 to LProdItems.High do begin
    LGridData.SetValue(i, 'id', LProdItems.G(i, 'id'));
    LGridData.SetValue(i, 'id_std_item', LProdItems.G(i, 'id_std_item'));
    LGridData.SetValue(i, 'slash', LProdItems.G(i, 'slash'));
    LGridData.SetValue(i, 'name', LProdItems.G(i, 'name'));
    LGridData.SetValue(i, 'qnt_production', LProdItems.G(i, 'qnt'));
    LGridData.SetValue(i, 'comm', LProdItems.G(i, 'comm'));
    LGridData.SetValue(i, 'qnt_sgp', 0); //заглушка - см. комментарий в шапке модуля
  end;

  //по каждому отгрузочному заказу серии загрузим его текущие количества по позициям (сопоставление - по
  //id_std_item, а НЕ по slash - см. подробный комментарий в шапке модуля) и заполним соответствующую динамическую
  //колонку количества
  for j := 0 to FSiblingOrders.High do begin
    Q.QLoad('select id_std_item, qnt from v_order_items where id_order = :id$i', [FSiblingOrders.G(j, 'id')], LOrderItems);
    LFieldName := QntFieldName(FSiblingOrders.G(j, 'id'));
    for i := 0 to LGridData.High do begin
      LIdx := LOrderItems.FindFirst('id_std_item', LGridData.G(i, 'id_std_item'));
      if LIdx >= 0
        then LGridData.SetValue(i, LFieldName, LOrderItems.G(LIdx, 'qnt'))
        else LGridData.SetValue(i, LFieldName, 0);
    end;
  end;

  //посчитаем итоговые колонки (общее введено / превышение) по каждой строке
  for i := 0 to LGridData.High do begin
    LTotal := 0;
    for j := 0 to FSiblingOrders.High do
      LTotal := LTotal + S.NNum(LGridData.G(i, QntFieldName(FSiblingOrders.G(j, 'id'))));
    LGridData.SetValue(i, 'total_entered', LTotal);
    LGridData.SetValue(i, 'excess', LTotal - S.NNum(LGridData.G(i, 'qnt_production')));
  end;

  Frg1.SetInitData(LGridData);
  Frg1.OnCellValueSave := Frg1CellValueSave;
  Frg1.OnDbClick := Frg1OnDbClick;
  Frg1.OnColumnsGetCellParams := Frg1ColumnsGetCellParams;

  //Result := Inherited вызовет TFrmBasicEditabelGrid.PrepareForm (FTitleTexts у нас пустой - метки шапки уже
  //выставлены выше вручную через lblCapt1/lblCapt2, здесь только создаст кнопки) и далее TFrmBasicGrid2.PrepareForm
  //(см. uFrmBasicGrid2.pas) - именно там вызываются Frg1.Prepare и Frg1.RefreshGrid, поэтому здесь их вызывать
  //самостоятельно не нужно (и нельзя - до Prepare грид ещё не готов)
  Result := Inherited;
  Frg1.IsTableCorrect;
end;

procedure TFrmOGedtDistributeQnt.RecalcRowTotals;
//пересчитывает "Общее введено"/"Превышение" для ТЕКУЩЕЙ строки грида (см. Frg1.GetValue/SetValue без указания
//позиции строки - работают с текущей активной записью, см. по аналогии TFrmOWOrder.FrgItemsCellValueSave/
//FrgItemsColumnsGetCellParams)
var
  j: Integer;
  LTotal: Double;
begin
  LTotal := 0;
  for j := 0 to FSiblingOrders.High do
    LTotal := LTotal + Frg1.GetValueF(QntFieldName(FSiblingOrders.G(j, 'id')));
  Frg1.SetValue('total_entered', LTotal);
  Frg1.SetValue('excess', LTotal - Frg1.GetValueF('qnt_production'));
end;

procedure TFrmOGedtDistributeQnt.CascadeRecalcRow(AEditedOrderId: Variant; AEditedValue: Double);
//каскадный пересчет количества по ТЕКУЩЕЙ строке грида, начиная от заказа AEditedOrderId (его значению в гриде уже
//присвоено AEditedValue - см. вызовы в Frg1CellValueSave/Frg1OnDbClick).
//
//алгоритм (выбран пользователем как основной вариант при постановке задачи): идём по заказам серии в ПОРЯДКЕ
//СОЗДАНИЯ (по id, т.е. как отсортирован FSiblingOrders). "использовано" - сумма количеств по уже пройденным
//заказам (включая AEditedOrderId, для него берём именно AEditedValue, а не старое значение из грида). для каждого
//следующего по порядку заказа ПОСЛЕ отредактированного: если он черновик - пересчитываем его количество как
//"количество по производственному минус уже использовано", не уходя в минус, и добавляем это (новое) количество к
//"использовано"; если он не черновик (уже проведен и т.п.) - не трогаем его количество, но всё равно прибавляем
//его (неизменное) значение к "использовано", т.к. далее по цепочке оно по-прежнему считается занятым. заказы,
//идущие в серии РАНЬШЕ отредактированного, не трогаем и берём их значение из грида как есть.
var
  i: Integer;
  LOrderId: Variant;
  LFieldName: string;
  LQntProduction, LUsed, LNewQnt: Double;
  LPastEdited: Boolean;
begin
  LQntProduction := Frg1.GetValueF('qnt_production');
  LUsed := 0;
  LPastEdited := False;
  for i := 0 to FSiblingOrders.High do begin
    LOrderId := FSiblingOrders.G(i, 'id');
    LFieldName := QntFieldName(LOrderId);
    if LOrderId = AEditedOrderId then begin
      LUsed := LUsed + AEditedValue;
      LPastEdited := True;
    end
    else if not LPastEdited then
      //заказ идёт в серии раньше отредактированного - не трогаем, просто учитываем его в "использовано"
      LUsed := LUsed + Frg1.GetValueF(LFieldName)
    else begin
      //заказ идёт в серии после отредактированного
      if FSiblingOrders.G(i, 'id_status').AsInteger = ORDER_ID_STATUS_DRAFT then begin
        LNewQnt := Max(0, LQntProduction - LUsed);
        Frg1.SetValue(LFieldName, LNewQnt);
        LUsed := LUsed + LNewQnt;
      end
      else
        LUsed := LUsed + Frg1.GetValueF(LFieldName);
    end;
  end;
  RecalcRowTotals;
end;

procedure TFrmOGedtDistributeQnt.Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
var
  LOrderId: Variant;
begin
  Fr.SetValue(FieldName, Value);
  LOrderId := OrderIdByFieldName(FieldName);
  if VarIsNull(LOrderId) then
    Exit; //не наша динамическая колонка количества (не должно происходить - остальные колонки нередактируемы)
  RecalcRowTotals;
  //окончательное решение о поведении по умолчанию (спрашивать или нет) будет принято позже, по итогам обсуждения
  //с пользователями; пока - явный запрос подтверждения при обычном редактировании ячейки. двойной клик по ячейке
  //(см. Frg1OnDbClick) выполняет тот же пересчет без вопроса
  if MyQuestionMessage('Пересчитать количества по строке?') = mrYes then
    CascadeRecalcRow(LOrderId, S.NNum(Value));
  Fr.IsTableCorrect;
end;

procedure TFrmOGedtDistributeQnt.Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
var
  LFieldName: string;
  LOrderId: Variant;
  LOrderIdx: Integer;
begin
  LFieldName := Fr.GetColumnFieldName;
  LOrderId := OrderIdByFieldName(LFieldName);
  if VarIsNull(LOrderId) then
    Exit; //двойной клик не по динамической колонке количества - штатное поведение (Handled не трогаем)
  Handled := True; //подавим стандартную реакцию грида на двойной клик - открытия отдельной карточки тут нет
  LOrderIdx := FSiblingOrders.FindFirst('id', LOrderId);
  if (LOrderIdx < 0) or (FSiblingOrders.G(LOrderIdx, 'id_status').AsInteger <> ORDER_ID_STATUS_DRAFT) then
    Exit; //колонка нередактируемого (не черновик) заказа - пересчитывать по ней двойным кликом нет смысла
  CascadeRecalcRow(LOrderId, Fr.GetValueF(LFieldName));
  Fr.IsTableCorrect;
end;

procedure TFrmOGedtDistributeQnt.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  //выделим цветом превышение количества (сумма по заказам серии больше, чем в производственном заказе)
  if (FieldName = 'excess') and (Fr.GetValueF('excess') > 0) then
    Params.Background := clMyExcessColor;
end;

function TFrmOGedtDistributeQnt.Save: Boolean;
//сохраняем распределенное количество: по каждому отгрузочному заказу серии, ещё находящемуся в статусе "Черновик",
//обновляем qnt в order_items по всем позициям (сопоставление - по id_std_item, см. комментарий в шапке модуля;
//НЕ по slash - у order_items вообще нет такой физической колонки, slash существует только как вычисляемое поле
//вью v_order_items).
//заказы не в статусе "Черновик" не трогаем (их колонки количества и так были нередактируемы)
var
  i, j, LAffected: Integer;
  LOrderId, LIdStdItem: Variant;
  LFieldName, LSlash: string;
  LQnt: Double;
  LOk: Boolean;
begin
  Result := False;
  LOk := True;
  LSlash := '';
  Q.QBeginTrans(True);
  for j := 0 to FSiblingOrders.High do begin
    if FSiblingOrders.G(j, 'id_status').AsInteger <> ORDER_ID_STATUS_DRAFT then
      Continue;
    LOrderId := FSiblingOrders.G(j, 'id');
    LFieldName := QntFieldName(LOrderId);
//    for i := 0 to Frg1.GetRecordCount - 1 do begin                       //+++
    for i := 0 to Frg1.GetCount(False) - 1 do begin
      LIdStdItem := Frg1.GetValue('id_std_item', i, False);
      LSlash := Frg1.GetValueS('slash', i, False); //только для текста сообщения об ошибке ниже
      LQnt := Frg1.GetValueF(LFieldName, i, False);
      LAffected := Q.QExecSql(
        'update order_items set qnt = :q$f where id_order = :ord$i and id_std_item = :std$i',
        [LQnt, LOrderId, LIdStdItem]
      );
      if LAffected <> 1 then begin
        LOk := False;
        Break;
      end;
    end;
    if not LOk then
      Break;
  end;
  if not LOk then begin
    Q.QCommitOrRollback(False);
    MyWarningMessage(
      'Не удалось сохранить распределение количества - не найдена позиция с паспортом "' + LSlash + '" в одном ' +
      'из отгрузочных заказов. Изменения не сохранены, обратитесь к разработчику.'
    );
    Exit;
  end;
  Q.QCommitOrRollback(True);
  Result := True;
end;

end.
