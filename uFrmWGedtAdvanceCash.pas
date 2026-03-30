unit uFrmWGedtAdvanceCash;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls,
  ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls, MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd,
  MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils, Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uFrmBasicGrid2, uFrDBGridEh, uFrmBasicMdi, uNamedArr
  ;

type
  TFrmWGedtAdvanceCash = class(TFrmBasicGrid2)
    PrintDBGridEh1: TPrintDBGridEh;
  private
    FPayrollParams: TNamedArr;
    FDeletedWorkers: TVarDynArray;
    FIsEditableAdd, FIsEditableAll: Boolean;
    function  PrepareForm: Boolean; override;
    function  Save: Boolean; override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;
    function  GetDataFromDb: Integer;
    function  GetDataFromCalc: Integer;
    function  GetCaption(Colored: Boolean = False): string;
    procedure PrintGrid;
    procedure CalculateBanknotes;
    procedure CalculateAll;
    procedure CalculateRow(Row:Integer);
  public
  end;

var
  FrmWGedtAdvanceCash: TFrmWGedtAdvanceCash;

implementation

{$R *.dfm}

uses
  uMessages,
  uForms,
  uDBOra,
  uTurv,
  uFrmBasicInput,
  uExcel,
  uPrintReport,
  XlsMemFilesEh,
  Printers,
  PrViewEH,
  uModule,
  uSys,
  uFrmMain,
  uFrmWDedtPayrollCalcMethod
  ;

const

  cFieldsS =
    'id$i;id_employee$i;id_job$i;pay_cash$f;banknotes$s';
  cFieldsL =
    'employee$s;job$s;temp$i';

  cColWidth = 45;

  cmbtEditAll = 1004;


function TFrmWGedtAdvanceCash.PrepareForm: Boolean;
var
  i, j, w1: Integer;
  v: Variant;
  wcol, fcol: string;
begin
  Result:=False;

  Caption:='Авансовая ведомость к выдаче';
  FOpt.RefreshParent := True;

  if FormDbLock = fNone then Exit;

  Q.QLoad('select id, id_employee, id_departament, dt, employee, departament from v_w_advance_cash where id = :id$i', [ID], FPayrollParams);
  if FPayrollParams.Count = 0 then begin
    MsgRecordIsDeleted;
    Exit;
  end;

  FDeletedWorkers := [];
  Frg1.Options := FrDBGridOptionDef + [myogPanelFind, myogColumnResize, myogPanelfind, myogHasStatusBar] - [myogColumnFilter];

  //определим поля
  wcol := IntToStr(cColWidth) + ';r';
  Frg1.Opt.SetFields([
    ['id$i', '_id','40'],
    ['id_employee$i', '_id_employee', wcol],
    ['id_job$i', '_id_job', wcol],
    ['temp$i', '_temp', wcol],
    ['employee$s', 'ФИО', '200;h'],
    ['job$s', 'Должность', '200;h'],
    ['pay_cash$f', 'Итого к'#13#10' получению', 70, 'f=###,###,###:'],
    ['banknotes$s', 'Купюры', 100, 'f=t:t'],
    ['sign$i', 'Подпись', '60', 'i', True]
  ]);
  Frg1.Opt.SetGridOperations('u');
  Frg1.Opt.SetButtons(1, [
    [mbtRefresh, Mode = fEdit, 'Обновить данные'], [], [mbtPrintGrid],
    [],[mbtCtlPanel]
  ]);
  Frg1.Opt.ButtonsNoAutoState := [0];

  Frg1.CreateAddControls('1', cntLabelClr, GetCaption(True), 'lblDivision', '', 4, yrefT, 800);
  Frg1.CreateAddControls('1', cntLabelClr, '', 'lblInfo', '', 4, yrefB, 800);
  Frg1.SetInitData([], '');

  Frg1.InfoArray := [[
    'Ведомость к перечислению.'#13#10#13#10
  ]];
  FQueryCloseMessage := 'Ведомость была изменена!'#13#10'Сохранить данные?';
  FOpt.RequestWhereClose := cqYNC;
  Result := inherited;
  if not Result then
    Exit;

  //ширина окна по ширине грида
  Self.Width := Frg1.GetTableWidth + 75;

  //прочитаем из БД ведомость
  GetDataFromDb;
  //если ведомость пуста- выполним первоначальную загрузка по данным турв
  if Frg1.GetCount(False) = 0 then
    GetDataFromCalc;

  CalculateBanknotes;

  Result:=True;
end;

function TFrmWGedtAdvanceCash.Save: Boolean;
var
  i, j: Integer;
  f, fn, va: TVarDynArray;
begin
  Result := False;
  Q.QBeginTrans(True);
  if Length(FDeletedWorkers) > 0 then
    Q.QExecSql('delete from w_advance_cash_item where id in (' + A.Implode(FDeletedWorkers, ',') + ')', []);
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    if Frg1.GetValueI('id', i, False) = 0 then begin
      var idn := Q.QSave('i', 'w_advance_cash_item', '', 'id$i;id_advance_cash$i', [-1, ID]);
      Frg1.SetValue('id', i, False, idn);
    end;
    f := A.Explode(cFieldsS, ';');
    va := [];
    for j := 0 to High(f) do
    fn := A.Explode(f[j],'$') ;
    for j := 0 to High(f) do begin
      va := va + [Frg1.GetValue(A.Explode(f[j],'$')[0], i, False)];
    end;
    Q.QSave('u', 'w_advance_cash_item', '', cFieldsS, va);
  end;
  Q.QCommitOrRollback(True);
  Result := Q.CommitSuccess;
end;

procedure TFrmWGedtAdvanceCash.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if A.InArray(FieldName, ['employee', 'job']) then
      Params.Background := clmyGray;
  if A.InArray(FieldName, ['pay_cash']) then
      Params.Background := RGB(220, 255, 190);
  if A.InArray(FieldName, ['pay_cash']) and (Frg2.GetValueF(FieldName) < 0) then
      Params.Background := clRed;
end;

procedure TFrmWGedtAdvanceCash.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  Handled := True;
  case Tag of
    mbtRefresh:
      if MyQuestionMessage('Загрузить данные из ведомостей к перечислению?') = mrYes then
        GetDataFromCalc;
    mbtPrintGrid:
      PrintGrid;
  else
    Handled := False;
  end;
end;

procedure TFrmWGedtAdvanceCash.Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
//вызывается после ручного изменения ячейки. установим статус изменения грида и пересчитаем строку
begin
  Fr.SetState(True, null, null);
  CalculateRow(-1);
end;

function TFrmWGedtAdvanceCash.GetDataFromDb: Integer;
//прочитаем ведомость (все данные) из БД и заполним ими сетку
var
  na : TNamedArr;
begin
  Q.QLoad(Q.QGetSql('a', 'v_w_advance_cash_item', cFieldsS + ';' + cFieldsL) + ' where id_advance_cash = :id$i' + S.IIFStr(AddParam <> null, ' and id_employee = ' + AddParam.AsString) + ' order by employee, job',
    [ID], na
  );
  Frg1.LoadData(na);
end;

function TFrmWGedtAdvanceCash.GetDataFromCalc: Integer;
//читаем данные из по нажатию соотв кнопки
var
  i, j, k: Integer;
  st1, st2, st3: string;
  v1, v2: Variant;
  dt1, dt2: TDateTime;
  b: Boolean;
  NoData: Boolean;
  na, na1, na2: TNamedArr;

  MsgDel, MsgIns, MsgChg: string;
  flds: TVarDynArray2;
  flds1, flds2: TVarDynArray;

begin
  //загружаем данные только в режиме редактирования
  if Mode <> fEdit then
    Exit;

  //отметим, что были изменения, если грид пуст
  //(т.к. в алгоритме далее изменений может не быть, но первоначальное заполенние из запроса будет)
  if Frg1.GetCount(False) = 0 then
    Frg1.SetState(True, null, null);

  //поля, по кторым сравниваем для сопоставления данных в турв и гшриде
  flds1 := ['id_employee', 'id_organization', 'personnel_number'];
  //поля для заголовка сообщания об изменениях
//  flds2 := ['employee', 'organization', 'personnel_number'];
  flds2 := ['employee', 'job'];
  //поля, по кторым сравниваем для сопоставления данных в турв и гшриде
  flds1 := ['id_employee'];
  //поля для заголовка сообщания об изменениях
  flds2 := ['employee'];

  dt1 := FPayrollParams.G('dt');
  dt2:= EncodeDate(YearOf(dt1), MonthOf(dt1), 15);

  if FPayrollParams.G('id_employee') = null then begin
    Q.QLoad(
      'select max(employee) as employee, id_employee, null as id_departament, null as id_job, null as departament, null as job, sum(pay_cash) as pay_cash, null as temp ' +
      'from v_w_advance_transfer_item where dt = :dt$d and id_target_employee is null ' +
      'group by id_employee '+
      'order by id_employee',
      [dt1],
      na1
    );
    Q.QLoad(
      'select id_employee, id_departament, id_job, departament, job from v_w_employee_properties where dt_beg <= :dt_end$d and (dt_end is null or dt_end >= :dt_beg$d) order by employee, id desc', [dt2, dt1], na2
    );
    for i := 0 to na1.High do begin
      for j := 0 to na2.High do begin
        if na1.G(i, 'id_employee') = na2.G(j, 'id_employee') then begin
          na1.SetValue(i, 'id_departament',na2.G(j, 'id_departament'));
          na1.SetValue(i, 'id_job',na2.G(j, 'id_job'));
          na1.SetValue(i, 'departament',na2.G(j, 'departament'));
          na1.SetValue(i, 'job',na2.G(j, 'job'));
//          na1.SetValue(i, '',na2.G(j, ''))
          Break;
        end;
      end;
    end;
    for i := na1.High downto 0 do begin
      if na1.G(i, 'id_departament') <> FPayrollParams.G('id_departament') then
        Delete(na1.V, i ,1);
    end;
  end
  else begin
    Q.QLoad(
      'select max(employee) as employee, id_employee, null as id_departament, null as id_job, null as departament, null as job, sum(pay_cash) as pay_cash, null as temp ' +
      'from v_w_advance_transfer_item where dt = :dt$d and id_target_employee = :ide$i ' +
      'group by id_employee '+
      'order by id_employee',
      [dt1, FPayrollParams.G('id_employee')],
      na1
    );
    Q.QLoad(
      'select id_employee, id_departament, id_job, departament, job from v_w_employee_properties where dt_beg <= :dt_end$d and (dt_end is null or dt_end >= :dt_beg$d) and id_departament = :id_departament$i order by employee, id desc',
      [dt2, dt1, FPayrollParams.G('id_departament')], na2
    );
    for i := 0 to na1.High do begin
      for j := 0 to na2.High do begin
        if na1.G(i, 'id_employee') = na2.G(j, 'id_employee') then begin
          na1.SetValue(i, 'id_departament',FPayrollParams.G(0, 'id_departament'));
          na1.SetValue(i, 'id_job',na2.G(j, 'id_job'));
          na1.SetValue(i, 'departament',FPayrollParams.G(0, 'departament'));
          na1.SetValue(i, 'job',na2.G(j, 'job'));
          Break;
        end;
      end;
    end;
    for i := na1.High downto 0 do begin
      if na1.G(i, 'id_departament') <> FPayrollParams.G('id_departament') then
        Delete(na1.V, i ,1);
    end;
  end;
  //сортируем по ФИО
  A.VarDynArray2Sort(na1.V, 1);

  NoData := Frg1.GetCount = 0;

  //заполним то что загружается из турв, остальные данные ранее загруженными из бд, удалим строки из ведомости, которых в турв теперь нет

  //получим для удобства работы данные из грида - они там сейчас те, что загрузились из БД
  na := Frg1.ExportToNa('', False);
  MsgDel := '';
  MsgIns := '';
  MsgChg := '';
  //найдем те строки в гриде, которых более нет в турв
  for i := 0 to na.Count - 1 do begin
    na.SetValue(i, 'temp', -1);
    st1 := '';
    for k := 0 to High(flds1) do
      S.ConcatStP(st1, na.G(i, flds1[k]).AsString, '|');
    b := False;
    for j := 0 to na1.Count - 1 do begin
      st2 := '';
      for k := 0 to High(flds1) do
        S.ConcatStP(st2, na1.G(j, flds1[k]).AsString, '|');
      if st1 = st2 then begin
        b := True;
        //сохраним во временной поле массива турв позицию из грида (из загруженной расчетной ведомости)
        na1.SetValue(j, 'temp', i);
        na.SetValue(i, 'temp', j);
        Break;
      end;
    end;
    //если не нашли в гриде - айди в массив, и данные в сообщение
    if not b then begin
      //данные строки для сообщения
      st1 := '';
      for k := 0 to High(flds2) do
        S.ConcatStP(st1, na.G(i, flds2[k]).AsString, ' | ');
      S.ConcatStP(MsgDel, st1, #13#10);
      //в массив удаленных - только те, которые загружены из БД
      if na.G(i, 'id') <> null then
        FDeletedWorkers := FDeletedWorkers + [na.G(i, 'id')];
      Frg1.SetState(True, null, null);
    end;
  end;

  //пройдем по данным, загруженным из турв
  for i := 0 to na1.Count - 1 do begin
    //если строки, которая есть в турв, нет в ведомости
    if na1.G(i, 'temp').AsIntegerM = -1 then begin
      //данные строки для сообщения
      st1 := '';
      for k := 0 to High(flds2) do
        S.ConcatStP(st1, na1.G(i, flds2[k]).AsString, ' | ');
      S.ConcatStP(MsgIns, st1, #13#10);
      //добавим строку
      na.IncLength;
      na.SetNull(na.High);
      //установим поля и итоговые данные из турв
      for k := 0 to High(na.F) do
        if not A.InArray(na.F[k],  ['id', 'temp', 'banknotes', 'sign']) then
          na.SetValue(na.High, na.F[k], na1.G(i, na.F[k]));
    end;
  end;

  //удалим позиции в ведомости, которые пропали из турв
  for i := na.High downto 0 do
    if na.G(i, 'temp') = -1 then begin
      Delete(na.V, i ,1);
    end;

  //пройдем по массиву ведомости, по тем строкам, для которых есть данные турв (а значит могли быть изменения)
  for i := na.High downto 0 do begin
    j := na.G(i, 'temp').AsIntegerM;
    if j <> -1 then begin
      if na.G(i, 'pay_cash') <> na1.G(j, 'pay_cash') then begin
        st2 :=  ':   "' + na.G(i, 'pay_cash').AsString  + '" -> "' + na1.G(j, 'pay_cash').AsString + '""';
        na.SetValue(i, 'pay_cash', na1.G(j, 'pay_cash'));
      end
      else
        st2 := '';
      if st2 <> '' then begin
        st1 := '';
        for k := 0 to High(flds2) do
          S.ConcatStP(st1, na.G(i, flds2[k]).AsString, ' | ');
        S.ConcatStP(MsgChg, st1 + st2);
      end;
    end;
  end;

  //загрузим данные в грид
  Frg1.LoadData(na);
  CalculateAll;

  if MsgIns + MsgDel + MsgChg = '' then begin
    MyInfoMessage('Изменений в ведомости не было.');
  end
  else begin
    Frg1.SetState(True, null, null);
    MyInfoMessage(
      'Данные обновлены.'#13#10#13#10 +
      S.IIFStr(MsgIns <> '', 'Внесены записи:'#13#10 + MsgIns + #13#10#13#10) +
      S.IIFStr(MsgDel <> '', 'Удалены записи:'#13#10 + MsgDel + #13#10#13#10) +
      S.IIFStr(MsgChg <> '', 'Изменены записи:'#13#10 + MsgChg),
      1
    );
  end;

end;

function TFrmWGedtAdvanceCash.GetCaption(Colored: Boolean = False): string;
begin
  var dt := FPayrollParams.G('dt');
  Result := S.IIFStr(Colored, '$FF0000') + S.IIf(FPayrollParams.G('employee') <> null, FPayrollParams.G('employee'), FPayrollParams.G('departament')) +
    S.IIFStr(Colored, '$000000') + ' с' + S.IIFStr(Colored, '$FF00FF') +' ' + DateToStr(dt) +
    S.IIFStr(Colored, '$000000') + ' по ' + S.IIFStr(Colored,  '$FF00FF') + DateToStr(EncodeDate(YearOf(dt), MonthOf(dt), 15));
end;

procedure TFrmWGedtAdvanceCash.PrintGrid;
//печать грида
var
  BeforeGridText: TStringsEh;
  i, j, rn: Integer;
  ar: TVarDynArray;
begin
  Gh.GetGridColumn(Frg1.DBGridEh1, 'sign').Visible := True;
  rn := Frg1.MemTableEh1.RecNo;
  ar := [];
  SetLength(ar, Frg1.MemTableEh1.Fields.Count + 2);
  //так мы можем скрыть столбцы, которые не имеют данных ни в одной строке
  Gh.SetGridOptionsTitleAppearance(Frg1.DBGridEh1, False);
  PrintDBGridEh1.BeforeGridText[0] :=  GetCaption;
  //альбомная ориентация
  PrinterPreview.Orientation := poLandscape;
  //масштабируем всю таблицу для умещения на стронице
  //но если таблица меньше ширины страницы, то она не реасширится!!!
  PrintDBGridEh1.Options := Frg1.PrintDBGridEh1.Options + [pghFitGridToPageWidth];
  PrintDBGridEh1.Preview;
  Gh.SetGridOptionsTitleAppearance(Frg1.DBGridEh1, True);
  Gh.GetGridColumn(Frg1.DBGridEh1, 'sign').Visible := False;
end;

procedure TFrmWGedtAdvanceCash.CalculateBanknotes;
//подсчет итогового количества банкнот (только по отфильтрованным строкам!)
var
  i: Integer;
  va1, va2: TVarDynArray;
begin
  va2 := [0, 0, 0, 0];
  for i := 0 to Frg1.GetCount(True) - 1 do begin
    va1 := A.Explode(Frg1.GetValueS('banknotes', i, True), ',');
    if Length(va1) <> 4 then
      Continue;
    va2[0] := va2[0] + Max(StrToInt(va1[0]), 0);
    va2[1] := va2[1] + Max(StrToInt(va1[1]), 0);
    va2[2] := va2[2] + Max(StrToInt(va1[2]), 0);
    va2[3] := va2[3] + Max(StrToInt(va1[3]), 0);
  end;
  Frg1.DBGridEh1.FieldColumns['banknotes'].Footer.Value := A.Implode(va2, ',');
end;

procedure TFrmWGedtAdvanceCash.CalculateAll;
var
  i: Integer;
begin
  for i := 0 to Frg1.GetCount(False) - 1 do
    CalculateRow(i);
end;

procedure TFrmWGedtAdvanceCash.CalculateRow(Row: Integer);
  function GetBanknotes: string;
  var
    s, i, i1, i2, i3, i4 : Integer;
  begin
    Result := '';
    s := Frg1.GetValueI('pay_cash', Row, False);
    if s <= 0 then
      Exit;
    i1 := s div 5000;
    i := s - i1 * 5000;
    i2 := i div 1000;
    i := i - i2 * 1000;
    i3 := i div 500;
    i := i - i3 * 500;
    i4 :=  i div 100;
    Result := IntToStr(i1) + ',' + IntToStr(i2) + ',' + IntToStr(i3) + ',' + IntToStr(i4);
  end;
begin
  if Row = -1 then
    Row := Frg1.MemTableEh1.RecNo - 1;
  Frg1.SetValue('banknotes', Row, False, GetBanknotes);
  CalculateBanknotes;
end;




end.
