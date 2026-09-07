unit uFrmOGlstEstimate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2,
  uLabelColors
  ;

type
  TFrmOGlstEstimate = class(TFrmBasicGrid2)
    lblCapt1: TLabel;  //шапка (см. pnlTop в .dfm) - только для FormDoc = myfrm_R_Estimate (см. PrepareForm);
    lblCapt2: TLabel;  //для myfrm_R_AggEstimate шапка по-прежнему через Frg1.CreateAddControls(cntLabel), как раньше
    procedure DBGridEh1CanUserSelectRow(Grid: TCustomDBGridEh; var CanSelectRow: Boolean);
  private
    FCapt: string;
    FIsPrepared: Boolean;
    //если для просмотра передана позиция заказа (AddParam[0]), но по ней сработал редирект на смету-эталон
    //нестандартного изделия типа П нового (26) формата (см. TOrders.ResolveEstimateDisplayTarget) - здесь
    //хранится id этого стандартного изделия (or_std_items, группа -1), чтобы Frg1OnSetSqlParams подставил
    //именно его, а не id самой (пустой/неактуальной) позиции заказа
    FIdStdItemForEstimate: Variant;
    function  PrepareForm: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);  override;
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    procedure Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure GetStockList;
    procedure MarkStockList;
    procedure Print;
  public
  end;

var
  FrmOGlstEstimate: TFrmOGlstEstimate;

implementation

uses
  uPrintReport,
  uOrders,
  uFrmMain,
  uFrmOGedtEstimate
  ;

{$R *.dfm}

const
  //кастомный (отрицательный, по аналогии с cBtnCreateSemiproduct в uFrmOGedtEstimate.pas - чтобы не путать с
  //положительными framework-овыми mbt*) тег кнопки "Альтернативный просмотр" (см. PrepareForm/Frg1ButtonClick)
  cBtnAltView = 1001;

function TFrmOGlstEstimate.PrepareForm: Boolean;
var
  IsNstd: Boolean;
  va: TVarDynArray;
  va2: TVarDynArray2;
  i, j: Integer;
  LCapt1, LCapt2: string;
begin
  FCapt := '';
  //шапка (нередактируемая, см. pnlTop в .dfm) - раскрашенные статичные метки lblCapt1/lblCapt2, по аналогии с
  //uFrmOGedtDistributeQnt.pas (там же комментарий, почему не через FTitleTexts/CreateLabelColors - было
  //нечитаемо); используется только для FormDoc = myfrm_R_Estimate (см. ниже) - раньше вся информация (слеш
  //заказа, наименование изделия, кол-во, признак сметы-эталона) шла ОДНОЙ строкой без расцветки через общий
  //для обоих FormDoc динамический Frg1.CreateAddControls(cntLabel, FCapt, ...) - для myfrm_R_AggEstimate этот
  //механизм оставлен без изменений (см. ниже), поэтому саму шапку скрываем/показываем по FormDoc (06.09.2026)
  pnlTop.Visible := FormDoc = myfrm_R_Estimate;
  lblCapt1.Caption := '';
  lblCapt2.Caption := '';
  Frg1.Options := Frg1.Options + [myogLoadAfterVisible, myogIndicatorCheckBoxes, myogMultiSelect];
  //кнопка "Альтернативный просмотр" (см. Frg1ButtonClick) - только для просмотра сметы по одному слешу
  //(FormDoc = myfrm_R_Estimate: позиция заказа или отдельно стандартное изделие), а не общей сметы по
  //заказу/заказам (myfrm_R_AggEstimate, там понятия "один слеш" нет) - открывает тот же диалог, что и для
  //редактирования (uFrmOGedtEstimate), но в режиме просмотра (fView) - см. общий комментарий у Frg1ButtonClick
  if FormDoc = myfrm_R_Estimate
    then Frg1.Opt.SetButtons(1,[[mbtRefresh],[],[mbtPrint],[],[mbtGridSettings],[],[mbtCtlPanel],[],[-cBtnAltView, True, 'Альтернативный просмотр']])
    else Frg1.Opt.SetButtons(1,[[mbtRefresh],[],[mbtPrint],[],[mbtGridSettings],[],[mbtCtlPanel]]);
  Frg1.Opt.SetGrouping(['groupname'], [], [clGradientActiveCaption], True);
  if FormDoc = myfrm_R_Estimate then begin
    Caption := 'Смета';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
//      ['id_dependent_estimate $i','_dep','40'],
      ['groupname','Группа','200'],
      ['artikul','Артикул','120'],
      ['name','Наименование','300;h'],
      ['unit','Ед.изм','70'],
      ['qnt1+0 as qnt1$f','Кол-во на ед.','70'],
      ['qnt+0 as qnt$f','Кол-во','70','f=f:'],
      ['comm','Дополнение','300;h'],
      ['price$f','Цена','80','f=r','i'],
      ['sum1$f','Сумма за ед. (с НДС)','80','f=r:'],
      ['0 as chb','_chb','60']
    ]);
    Frg1.Opt.SetTable('v_estimate_add');  //v_estimate_prices
    FIdStdItemForEstimate := null;
    if AddParam[0] <> null then begin
      //раньше все три поля (слеш, наименование, кол-во) грузились одним QLoadValue сразу в готовую строку
      //FCapt - для шапки это и было причиной "все на одной строке"; теперь грузим их по отдельности, чтобы
      //разнести по двум меткам (см. ниже), а FCapt (для печати - см. Print) по-прежнему собираем целиком
      va := Q.QLoadRow('select slash, itemname, qnt from v_order_items where id = :id$i', [AddParam[0]]);
      FCapt := va[0] + '    ' + va[1] + '  [кол-во: ' + S.NSt(va[2]) + ']';
      IsNstd := Q.QLoadValue('select nstd from v_order_items where id = :id$i', [AddParam[0]]) = 1;
      //заказ (слеш) - отдельной строкой (lblCapt1), изделие и количество - отдельной (lblCapt2)
      LCapt1 := '$FF00FFЗаказ, слеш:$FF0000 ' + va[0];
      LCapt2 := '$000000Изделие:$FF0000 ' + va[1] + '$000000    Кол-во:$FF0000 ' + S.NSt(va[2]);
      //для нестандартного изделия типа П нового (26) формата содержательная смета лежит в эталоне
      //стандартного изделия, а не в копии самой позиции заказа (см. TOrders.LoadEstimate, редирект для П,
      //и TOrders.ResolveEstimateDisplayTarget) - без этой проверки просмотр показывал бы пустую смету
      if Orders.ResolveEstimateDisplayTarget(AddParam[0], FIdStdItemForEstimate) then begin
        Frg1.Opt.SetWhere('where deleted = 0 and id_std_item = :id$i /*ANDWHERE*/');
        //текст сознательно НЕ раскрывает архитектуру хранения (эталон/группа -1 и т.п.) - пользователю
        //это неинтересно и только запутает (см. правку 06.09.2026); слеш/наименование уже показаны выше
        //(LCapt1/LCapt2), поэтому здесь только сама отметка, без повтора контекста
        FCapt := FCapt + '  (к производственному (отгрузочному) изделию заказа)';
        //признак редиректа - отдельным, заметным (красным) хвостом первой строки шапки
        LCapt1 := LCapt1 + '$0000FF    (к производственному (отгрузочному) изделию заказа)';
      end
      else
        Frg1.Opt.SetWhere('where deleted = 0 and id_order_item = :id$i /*ANDWHERE*/');
      lblCapt1.SetCaption2(LCapt1);
      lblCapt2.SetCaption2(LCapt2);
    end;
    if AddParam[1] <> null then begin
      Frg1.Opt.SetWhere('where deleted = 0 and id_std_item = :id$i /*ANDWHERE*/');
      FCapt := Q.QLoadValue('select name from v_or_std_items where id = :id$i', [AddParam[1]]);
      IsNstd := False;
      //нет позиции заказа - показывать нечего, кроме наименования самого стандартного изделия; вторую
      //строку (lblCapt2) не используем вовсе (она уже очищена выше)
      lblCapt1.SetCaption2('$FF00FFСтандартное изделие:$FF0000 ' + FCapt);
    end;
    //Frg1.CreateAddControls('1', cntComboLK, 'Площадка:', 'CbArea', '', 80, yrefC, 80);
    Frg1.InfoArray:=[];
  end;
  if FormDoc = myfrm_R_AggEstimate then begin
    Frg1.Options := Frg1.Options - [myogLoadAfterVisible]; //добавление where в конец запроса будет некорректным
    if Length(TVarDynArray(AddParam)) = 1 then
      Caption := 'Общая смета по заказу'
    else
      Caption := 'Общая смета по ' + IntToStr(Length(TVarDynArray(AddParam))) + ' заказ' + S.GetEnding(Length(TVarDynArray(AddParam)), 'у', 'ам', 'ам');
    Frg1.Opt.SetFields([
      ['to_char(rownum) as id$i','_id','40'],
      ['groupname','Группа','200'],
      ['artikul','Артикул','120'],
      ['name','Наименование','300;h'],
      ['unit','Ед.изм','70'],
      ['qnt+0 as qnt$f','Кол-во','70','f=f:'],
      ['0 as chb','_chb','60']
    ]);
    Frg1.Opt.SetTable('v_aggregate_estimate');
//    Pr[1].Fields := 'to_char(rownum) as id;groupname;name;unit;qnt as qnt;0 as chb';
    //если в доп параметре передан один элемент массива, то формируем запрос для просмотра общей сметы по этому заказу
    //иначе смотрим во всем переданным в массиве
    //и также можно по всем заказм вообще, но это не используем!
    //if Length(TVarDynArray(AddParam)) = 1 then
    //  Frg1.Opt.SetWhere('where id_order = :id_order$i')
    //else
    if Length(TVarDynArray(AddParam)) > 1 then begin
      Frg1.Opt.SetSql(
        'select '+
        'to_char(max(rownum)) as id,max(groupname) as groupname, name ,max(unit) as unit, '+
        'sum(qnt+0) as qnt, 0 as chb '+
        'from v_aggregate_estimate where id_order in (' + A.Implode(TVarDynArray(AddParam), ',') + ') group by name'
      );
    end;
    if Length(TVarDynArray(AddParam)) = 1 then
      FCapt := Q.QLoadValue('select ornum from v_orders where id = :id$i', TVarDynArray(AddParam))
    else begin
      j := Length(TVarDynArray(AddParam)) - 10;
      va := [];
      for i := 0 to Min(Length(TVarDynArray(AddParam)), 10) - 1 do
        va := va + [TVarDynArray(AddParam)[i]];
      A.VarDynArraySort(va);
      va2 := Q.QLoad('select ornum from v_orders where id in (' + A.Implode(va, ',') + ') order by ornum', []);
      FCapt := A.Implode(A.VarDynArray2ColToVD1(va2, 0), ', ') + S.IIf(j <= 0, '', ' и еще ' + IntToStr(j));
    end;
  end;
  //для myfrm_R_Estimate шапка теперь показывается через lblCapt1/lblCapt2 в pnlTop (см. выше) - этот
  //динамический ярлык внутри грида больше не дублирует ее; для myfrm_R_AggEstimate поведение не меняем
  if FormDoc = myfrm_R_AggEstimate then
    Frg1.CreateAddControls('1', cntLabel, FCapt, 'LbCapt', '', 5, yrefT, 3000);
  Frg1.CreateAddControls('1', cntCheck, 'Показать по группам', 'ChbGrouping', '', 5, yrefB, 200);
  if True then begin
    Frg1.CreateAddControls('1', cntComboLK, 'Склад:', 'CbStock', '', 180, yrefB, 170);
    GetStockList;
      //TDBComboBoxEh(FindComponent('cmb_Stock')).ItemIndex:=0;
  end;
  Frg1.CreateAddControls('1', cntCheck, 'Исходная', 'ChbSource', '', 360, yrefB, 80);
  if User.Role(rOr_R_Estimate_PrimeCost) then
    Frg1.CreateAddControls('1', cntCheck, 'Цены', 'ChbPrices', '', 450, yrefB, 80);
  if Length(TVarDynArray(AddParam)) = 1 then begin
    Frg1.CreateAddControls('1', cntEdit, 'Слеши:', 'ENums', '', 450+80+50, yrefB, 300);
    TDBEditEh(Frg1.FindComponent('ENums')).Text := '';
  end;
  Result := inherited;
  if Frg1.FindComponent('CbStock') <> nil then
    Frg1.SetControlValue('CbStock', null);
end;

procedure TFrmOGlstEstimate.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
var
  va, vak, res: TVarDynArray;
  va2, va3: TVarDynArray2;
  i, j, gr, recno: Integer;
  Fields, SpFilter: string;
  b, b1: Boolean;
  st: string;
begin
  if (FormDoc = myfrm_R_AggEstimate) and (Length(TVarDynArray(AddParam)) = 1) and (Tag = mbtRefresh) then begin
    Frg1.RefreshGrid;
    Handled := True;
  end
  else if Tag = mbtPrint then begin
    Print;
    Handled := True;
  end
  else if Tag = cBtnAltView then begin
    //"Альтернативный просмотр" - кнопка добавлена только для FormDoc = myfrm_R_Estimate (см. PrepareForm),
    //поэтому здесь ID/AddParam всегда однозначны. Открываем ТОТ ЖЕ диалог, что и для полноценного
    //редактирования сметы (uFrmOGedtEstimate) - но в режиме fView (только чтение, без блокировки документа -
    //см. Q.DBLock/FormDbLock там же), напрямую, в обход TOrders.LoadEstimate/бокового канала (EstDlgChannel) -
    //никакой загрузки массива и сохранения тут не требуется, диалог сам прочитает текущий состав сметы из БД
    //(см. TFrmOGedtEstimate.PrepareForm, ветка FUseInputArray = False). Если для просмотра сработал редирект на
    //смету-эталон нестандартного изделия (см. FIdStdItemForEstimate/Frg1OnSetSqlParams выше) - открываем именно
    //ее (AddParam = 1), а не пустую/неактуальную позицию заказа - иначе увидели бы не то же самое, что в гриде
    if FIdStdItemForEstimate <> null then
      TFrmOGedtEstimate.Show(FrmMain, myfrm_Dlg_EdtEstimate, [myfoDialog, myfoSizeable, myfoMultiCopy], fView, FIdStdItemForEstimate, 1)
    else if AddParam[0] <> null then
      TFrmOGedtEstimate.Show(FrmMain, myfrm_Dlg_EdtEstimate, [myfoDialog, myfoSizeable, myfoMultiCopy], fView, AddParam[0], 0)
    else if AddParam[1] <> null then
      TFrmOGedtEstimate.Show(FrmMain, myfrm_Dlg_EdtEstimate, [myfoDialog, myfoSizeable, myfoMultiCopy], fView, AddParam[1], 1);
    Handled := True;
  end
  else
    inherited;
end;

procedure TFrmOGlstEstimate.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
var
  i, n: Integer;
  e, eall: Extended;
  b: Boolean;
begin
  //CanSelectRow := True;
  //inherited;
  //для общей сметы - посчитаем сумму по позициям, отмеченным чекбоксами
  //если отметка есть, то выведем эту сумму, а иначе выведем автосумму
//  if True and (FormDoc = myfrm_R_AggEstimate) then begin
    e := 0;
    eall := 0;
    b := False;
    //так можно пройти по всему с\писку отфильтрованных позиций, без перемещения фокуса (но мы пойдем другим путем!)
    {for i := 0 to MemTableEh1.RecordsView.Count - 1 do begin
      eall := eall + MemTableEh1.FieldByName('qnt').AsFloat;
    end;}
    //посчитаем отмеченные чекбоксами /ТОЛЬКО среди отфильтрованных записей/
    for i := 0 to Frg1.MemTableEh1.InstantReadRowCount - 1 do begin
      Frg1.MemTableEh1.InstantReadEnter(i); //в режим чтения
      if Frg1.DBGridEh1.SelectedRows.CurrentRowSelected then begin
        b := True;
        e := e + Frg1.MemTableEh1.FieldByName('qnt').AsFloat;
      end;
      Frg1.MemTableEh1.InstantReadLeave;    //в нормальный режим
    end;
    //если не найдено отмеченных, то включим автосумму, а иначе запишем текст
    if not b then begin
      Frg1.DBGridEh1.FieldColumns['qnt'].Footer.ValueType := fvtSum;
      Frg1.DBGridEh1.FieldColumns['qnt'].Footer.Font.Color := clWindowText;
    end
    else begin
      Frg1.DBGridEh1.FieldColumns['qnt'].Footer.ValueType := fvtStaticText;
      Frg1.DBGridEh1.FieldColumns['qnt'].Footer.Font.Color := clBlue;
      Frg1.DBGridEh1.FieldColumns['qnt'].Footer.Value := FormatFloat('#,###.###', e);
    end;
//  end;
end;




procedure TFrmOGlstEstimate.Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
//подстановка параметров
//здесь же меняем текст запроса - отображать количества итм или исходные
//в данном случае это удобнее чем делать скрытые поля, к тому же в одном из 4 вариантов смет скл-запрос задается явно
var
  va, vak, res: TVarDynArray;
  va2, va3: TVarDynArray2;
  i, j, gr, recno: Integer;
  Fields, SpFilter: string;
  b, b1: Boolean;
  st: string;
  v: Variant;
begin
    //обрабатываем тут замену скл при показе общей сметы по одному заказу
    //если в ТЕдит перечислены слеши, то показываем только по ним
    //или, если в начале строки стоит -, то по всем кроме перечисленных
    //(на самом деле можно всегда использовать этот способ!)
  if (FormDoc = myfrm_R_AggEstimate) and (Length(TVarDynArray(AddParam)) = 1) then begin
    st := Trim(Fr.GetControlValue('ENums'));
  //вернем строку в формат in (1,2,...)
  //удалим все кроме цифр и запятых, переведем в массив и снова соединим крому пустых
    b := Pos('-', st) = 1;
    for i := Length(st) downto 1 do
      if not (st[i] in ['0'..'9', ',']) then
        Delete(st, i, 1);
    va := A.ExplodeV(st, ',');
    st := A.ImplodeNotEmpty(va, ',');
    TDBEditEh(Fr.FindComponent('ENums')).Text := S.IIf(b, '-', '') + st;
    if st = '' then begin
    //это по всему заказу
      Fr.Opt.SetSql('select to_char(1) as id, groupname, artikul, name, unit, qnt+0 as qnt, 0 as chb ' + 'from v_aggregate_estimate where id_order = :id_order$i');
    end
    else begin
    //это по слешам заказа
      Fr.Opt.SetSql('select to_char(1) as id, max(groupname) as groupname, max(artikul) as artikul, max(name) as name, max(unit) as unit, sum(qnt+0) as qnt, 0 as chb ' + 'from v_aggregate_estimate_or1 where pos ' + S.IIf(b, 'not', '') + ' in (' + st + ') and id_order = :id_order$i group by name');
    end;
  end;

  if Fr.GetControlValue('ChbSource') = 1 then begin
    Fr.ADODataDriverEh1.SelectSQL.Text := StringReplace(Fr.ADODataDriverEh1.SelectSQL.Text, ', qnt1_itm+0 as', ', qnt1+0 as', []);
    Fr.ADODataDriverEh1.SelectSQL.Text := StringReplace(Fr.ADODataDriverEh1.SelectSQL.Text, ', qnt_itm+0 as', ', qnt+0 as', []);
    Fr.ADODataDriverEh1.SelectSQL.Text := StringReplace(Fr.ADODataDriverEh1.SelectSQL.Text, 'sum(qnt_itm+0)', 'sum(qnt+0)', []);
  end
  else begin
    Fr.ADODataDriverEh1.SelectSQL.Text := StringReplace(Fr.ADODataDriverEh1.SelectSQL.Text, ', qnt1+0 as', ', qnt1_itm+0 as', []);
    Fr.ADODataDriverEh1.SelectSQL.Text := StringReplace(Fr.ADODataDriverEh1.SelectSQL.Text, ', qnt+0 as', ', qnt_itm+0 as', []);
    Fr.ADODataDriverEh1.SelectSQL.Text := StringReplace(Fr.ADODataDriverEh1.SelectSQL.Text, 'sum(qnt+0)', 'sum(qnt_itm+0)', []);
  end;
  if FormDoc = myfrm_R_Estimate then
    if FIdStdItemForEstimate <> null
      //редирект на смету-эталон нестандартного изделия (см. PrepareForm) - подставляем id эталона,
      //а не исходной (пустой/неактуальной) позиции заказа из AddParam[0]
      then Fr.SetSqlParameters('id$i', [FIdStdItemForEstimate])
      else if AddParam[0] <> null
        then Fr.SetSqlParameters('id$i', [AddParam[0]])
        else Fr.SetSqlParameters('id$i', [AddParam[1]]);
  if (FormDoc = myfrm_R_AggEstimate) and (Length(TVarDynArray(AddParam)) = 1) then begin
    v := AddParam[0];
    Fr.SetSqlParameters('id_order$i', [AddParam[0]]);
  end;
end;

procedure TFrmOGlstEstimate.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
var
  v: Variant;
begin
  v := Frg1.GetControlValue('ChbPrices');
  Frg1.Opt.SetColFeature('price;sum1', 'i', v <> 1);
  Frg1.Opt.SetColFeature('price;sum1', 'null', v <> 1);
  Frg1.DbGridEh1.DataGrouping.Active := Frg1.GetControlValue('ChbGrouping') = 1;
  Frg1.Opt.SetColFeature('groupname', 'i', not Frg1.DbGridEh1.DataGrouping.Active);
  Frg1.SetColumnsVisible;
  if TControl(Sender).Name = 'ChbGrouping' then begin
//    Frg1.DbGridEh1.DataGrouping.Active := TDBCheckBoxEh(Sender).Checked;
//    Frg1.Opt.SetColFeature('groupname', 'i', not Frg1.DbGridEh1.DataGrouping.Active);
  end
  else if (TControl(Sender).Name = 'CbStock') and Frg1.IsPrepared then
    MarkStockList
  else if (A.InArray(TControl(Sender).Name, ['ChbPrices-', 'ChbSource'])) and Frg1.IsPrepared then
    Frg1.RefreshGrid;
end;

procedure TFrmOGlstEstimate.GetStockList;
//получим список складов
begin
  Q.QLoadToDBComboBoxEh('select skladname, id_sklad from dv.sklad order by skladname', [], TDBComboBoxEh(Frg1.FindComponent('CbStock')), cntComboLK0);
  TDBComboBoxEh(Frg1.FindComponent('CbStock')).ItemIndex := 0;
end;

procedure TFrmOGlstEstimate.MarkStockList;
//отметим галочками наименвания, которые есть на выбранном складе (остальные снимим)
var
  va2: TVarDynArray2;
  i, j, recno: Integer;
begin
  Gh.GridFilterClear(Frg1.DBGridEh1);
  va2 := [];
  if TDBComboBoxEh(Frg1.FindComponent('CbStock')).Text <> '' then
    va2 := Q.QLoad('select name from v_itm_ext_nomencl where skladname = :skladname$s', [TDBComboBoxEh(Frg1.FindComponent('CbStock')).Text]);
  Frg1.MemTableEh1.DisableControls;
  recno := Frg1.MemTableEh1.RecNo;
  for i := 1 to Frg1.MemTableEh1.RecordCount do begin
    Frg1.MemTableEh1.RecNo := i;
    Frg1.DBGridEh1.SelectedRows.CurrentRowSelected := A.PosInArray(Frg1.MemTableEh1.FieldByName('name').Value, va2, 0) > -1;
  end;
  Frg1.MemTableEh1.RecNo := recno;
  Frg1.MemTableEh1.EnableControls;
end;

procedure TFrmOGlstEstimate.DBGridEh1CanUserSelectRow(Grid: TCustomDBGridEh; var CanSelectRow: Boolean);
var
  i, n: Integer;
  e, eall: Extended;
  b: Boolean;
begin
  CanSelectRow := True;
  inherited;
  //для общей сметы - посчитаем сумму по позициям, отмеченным чекбоксами
  //если отметка есть, то выведем эту сумму, а иначе выведем автосумму
//  if True and (FormDoc = myfrm_R_AggEstimate) then begin
    e := 0;
    eall := 0;
    b := False;
    //так можно пройти по всему с\писку отфильтрованных позиций, без перемещения фокуса (но мы пойдем другим путем!)
    {for i := 0 to MemTableEh1.RecordsView.Count - 1 do begin
      eall := eall + MemTableEh1.FieldByName('qnt').AsFloat;
    end;}
    //посчитаем отмеченные чекбоксами /ТОЛЬКО среди отфильтрованных записей/
    for i := 0 to Frg1.MemTableEh1.InstantReadRowCount - 1 do begin
      Frg1.MemTableEh1.InstantReadEnter(i); //в режим чтения
      if Frg1.DBGridEh1.SelectedRows.CurrentRowSelected then begin
        b := True;
        e := e + Frg1.MemTableEh1.FieldByName('qnt').AsFloat;
      end;
      Frg1.MemTableEh1.InstantReadLeave;    //в нормальный режим
    end;
    //если не найдено отмеченных, то включим автосумму, а иначе запишем текст
    if not b then begin
      Frg1.DBGridEh1.FieldColumns['qnt'].Footer.ValueType := fvtSum;
      Frg1.DBGridEh1.FieldColumns['qnt'].Footer.Font.Color := clWindowText;
    end
    else begin
      Frg1.DBGridEh1.FieldColumns['qnt'].Footer.ValueType := fvtStaticText;
      Frg1.DBGridEh1.FieldColumns['qnt'].Footer.Font.Color := clBlue;
      Frg1.DBGridEh1.FieldColumns['qnt'].Footer.Value := FormatFloat('#,###.###', e);
    end;
    Frg1.DBGridEh1.InvalidateFooter;
//  end;
end;


procedure TFrmOGlstEstimate.Print;
var
  va, vak, res: TVarDynArray;
  va2, va3: TVarDynArray2;
  i, j, gr, recno: Integer;
  Fields, SpFilter: string;
  b, b1: Boolean;
  st: string;
begin
    //если есть отметки в чекбоксах в индикаторном столбце, то печатаем только отмеченные, и при этом все отсмеченные, независимо от любых фильтров
    // и в этом случвае отключаем все фильры на время печати, но по чекбоксам создаем фильтр в специальной колонке, а после все фильтры
    // (и в столбцах, и в сеархпанели) - восстанавливаем
    //если же отмеченных чекбоксов нет, то фильтры не трогаем, и печать происходит по совокупности фильтров
    //при этом, если нет группировки, то можно и не заморачиваться со снятием/восстановлением фильтров, и служебным столбцом,\
    // печатаются только отмеченные чекбоксами
    // а если есть группировка, то в этой ситуации из печатной формы пропадают грумппы, и нужна вся это свистопляска
    //если в настройках панель фильтра и фильтр в столбцах отключены, это не влияет на работоспособность
  if Frg1.GetCount = 0 then
    Exit;
  Frg1.MemTableEh1.DisableControls;
  recno := Frg1.MemTableEh1.RecNo;
  va := [];
  SpFilter := '';
  if Frg1.DBGridEh1.SelectedRows.Count > 0 then begin
    va2 := Gh.GridFilterSave(Frg1.DBGridEh1);
    Gh.GridFilterClear(Frg1.DBGridEh1);
  end;
  for i := 1 to Frg1.MemTableEh1.RecordCount do begin
    Frg1.MemTableEh1.RecNo := i;
    b := Frg1.DBGridEh1.SelectedRows.CurrentRowSelected;
    Frg1.DBGridEh1.SelectedRows.CurrentRowSelected := False;
    b1 := b1 or b;
    if b then
      va := va + [i];
    Frg1.MemTableEh1.Edit;
    Frg1.MemTableEh1.FieldByName('chb').Value := S.IIfInt(b, 1, 0);
    Frg1.MemTableEh1.Post;
  end;
  Frg1.MemTableEh1.RecNo := recno;
  Frg1.MemTableEh1.EnableControls;
  if b1 then begin
    Gh.GetGridColumn(Frg1.DBGridEh1, 'chb').STFilter.ExpressionStr := '=1';
    Frg1.DBGridEh1.DefaultApplyFilter;
  end;

  Frg1.MemTableEh1.DisableControls; //иначе будет перемещение по гриду при печати
  PrintReport.SetReportDataset('capt$s', [FCapt]);
  PrintReport.pnl_Estimate(Frg1.MemTableEh1, S.IIf(FormDoc = myfrm_R_AggEstimate, 2, 1));
  try
  //здесь по данным журнала ошибок возникает Access violation
  Frg1.MemTableEh1.EnableControls;
  except
  end;
  Gh.GetGridColumn(Frg1.DBGridEh1, 'chb').STFilter.ExpressionStr := '';
  Frg1.DBGridEh1.DefaultApplyFilter;
  Frg1.MemTableEh1.DisableControls;
  for i := 1 to Frg1.MemTableEh1.RecordCount do begin
    Frg1.MemTableEh1.RecNo := i;
    Frg1.DBGridEh1.SelectedRows.CurrentRowSelected := Frg1.MemTableEh1.FieldByName('chb').Value = 1;
  end;
  Gh.GridFilterRestore(Frg1.DBGridEh1, va2);
  Frg1.MemTableEh1.RecNo := recno;
  Frg1.MemTableEh1.EnableControls;
end;



end.
