unit uFrmOGlstEstimate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2, uFrmBasicInput
  ;

type
  TFrmOGlstEstimate = class(TFrmBasicGrid2)
    procedure DBGridEh1CanUserSelectRow(Grid: TCustomDBGridEh; var CanSelectRow: Boolean);
  private
    FCapt: string;
    FIsPrepared: Boolean;
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
  uPrintReport
  ;

{$R *.dfm}

function TFrmOGlstEstimate.PrepareForm: Boolean;
var
  IsNstd: Boolean;
  va: TVarDynArray;
  va2: TVarDynArray2;
  i, j: Integer;
begin
  FCapt := '';
  Frg1.Options := Frg1.Options + [myogLoadAfterVisible, myogIndicatorCheckBoxes, myogMultiSelect];
  Frg1.Opt.SetButtons(1,[[mbtRefresh],[],[mbtPrint],[],[mbtGridSettings],[],[mbtCtlPanel]]);
  Frg1.Opt.SetGrouping(['groupname'], [], [clGradientActiveCaption], True);
  if FormDoc = myfrm_R_Estimate then begin
    Caption := 'Смета';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['groupname','Группа','200'],
      ['artikul','Артикул','120'],
      ['name','Наименование','300;h'],
      ['unit','Ед.изм','70'],
      ['qnt1+0 as qnt1$f','Кол-во на ед.','70'],
      ['qnt+0 as qnt$f','Кол-во','70','f=f:'],
      ['comm','Дополнение','300;h'],
      ['price$f','Цена','80','f=r','i'],
      ['sum1$f','Сумма за ед.','80','f=r:'],
      ['0 as chb','_chb','60']
    ]);
    Frg1.Opt.SetTable('v_estimate_add');  //v_estimate_prices
    if AddParam[0] <> null then begin
      Frg1.Opt.SetWhere('where deleted = 0 and id_order_item = :id$i /*ANDWHERE*/');
      FCapt := Q.QSelectOneRow('select slash || ''    '' || itemname || ''  [кол-во: '' || qnt || '']'' from v_order_items where id = :id$i', [AddParam[0]])[0];
      IsNstd := Q.QSelectOneRow('select nstd from v_order_items where id = :id$i', [AddParam[0]])[0] = 1;
    end;
    if AddParam[1] <> null then begin
      Frg1.Opt.SetWhere('where deleted = 0 and id_std_item = :id$i /*ANDWHERE*/');
      FCapt := Q.QSelectOneRow('select name from v_or_std_items where id = :id$i', [AddParam[1]])[0];
      IsNstd := False;
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
      FCapt := Q.QSelectOneRow('select ornum from v_orders where id = :id$i', TVarDynArray(AddParam))[0]
    else begin
      j := Length(TVarDynArray(AddParam)) - 10;
      va := [];
      for i := 0 to Min(Length(TVarDynArray(AddParam)), 10) - 1 do
        va := va + [TVarDynArray(AddParam)[i]];
      A.VarDynArraySort(va);
      va2 := Q.QLoadToVarDynArray2('select ornum from v_orders where id in (' + A.Implode(va, ',') + ') order by ornum', []);
      FCapt := A.Implode(A.VarDynArray2ColToVD1(va2, 0), ', ') + S.IIf(j <= 0, '', ' и еще ' + IntToStr(j));
    end;
  end;
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
    if AddParam[0] <> null
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
    va2 := Q.QLoadToVarDynArray2('select name from v_itm_ext_nomencl where skladname = :skladname$s', [TDBComboBoxEh(Frg1.FindComponent('CbStock')).Text]);
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
