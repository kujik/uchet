unit uFrmWGedtTurvN;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls,
  ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls, MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd,
  MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils, Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uTurv
  ;

type
  TFrmWGedtTurvN = class(TFrmBasicGrid2)
  private
    FTurv : TTurvData;

    FRgsCommit, FRgsEdit1, FRgsEdit2, FRgsEdit3: Boolean;  //права
    FEditUsers: string;
    FStatus, FStatusOld : Integer;

    FArrTitle: TNamedArr;
    FTurvCodes: TNamedArr;
    FTurvCodeWeekend: Integer;
    FArrTurv: array of array of array of Variant;
    FInEditMainGridMode: Boolean;
    FInEditMode: Boolean;
    FIsDetailGridUpdated: Boolean;

    FDayColWidth: Integer;
    FLeftPartWidth: Integer;

    function  PrepareForm: Boolean; override;
    function  SetLock: Boolean;
    function  LoadTurv: Boolean;
    function  LoadTurvCodes: Boolean;
    procedure PushTurvToGrid;
    procedure PushTurvCellToGrid(ARow, ADay: Integer);
  public
  end;

var
  FrmWGedtTurvN: TFrmWGedtTurvN;

implementation

uses
  uLabelColors2,
  uFrmBasicInput,
  uFrmWWsrvTurvComment,
  uExcel
  ;

{$R *.dfm}

function TFrmWGEdtTurvN.PrepareForm: Boolean;
var
  i, j: Integer;
  va2, va21, flds1, flds2, values2: TVarDynArray2;
  Captions2: TVarDynArray;
begin
  Result := False;
  FDayColWidth := 40;

  Caption:='ТУРВ';
  FTurv.Create(ID);
  FTurv.LoadList;
  FTurv.LoadDays;

//  FDayColumnsCount := DaysBetween(FPeriodEndDate, FPeriodStartDate) + 1;


  (*
  FOpt.RefreshParent := True;

  Q.QLoadFromQuery('select id, id_division, code, name, dt1, dt2, committxt, commit, editusers, status, name, id_schedule from v_turv_period where id = :id$i', [ID], va2);
  if Length(va2) = 0 then begin
    MsgRecordIsDeleted;
    Exit;
  end;
  Q.QLoadFromQuery('select name, IsStInCommaSt(:id_user$i, editusers), editusers from ref_divisions where id = :id$i', [User.GetId, va2[0][1]], va21);
  FDivisionScehdule := Q.QSelectOneRow('select code from ref_work_schedules where id = :id', [va2[0][11]])[0];
  FIsOffice := Q.QSelectOneRow('select office from ref_divisions where id = :id$i', [va2[0][1]])[0] = 1;


  if Length(va2) = 0 then
    Exit;

  FIdDivision := va2[0][1];
  FDivisionName := va2[0][10];
  FPeriodStartDate := va2[0][4];
  FPeriodEndDate := va2[0][5];
  FDayColumnsCount := DaysBetween(FPeriodEndDate, FPeriodStartDate) + 1;
  FRgsCommit:=User.Role(rW_J_Turv_Commit);;
  FRgsEdit1:=va21[0][1]=1;
  FRgsEdit2:=User.Role(rW_J_Turv_TP);
  FRgsEdit3:=User.Role(rW_J_Turv_TS);;
  FEditUsers:=va21[0][2];
  FIsCommited:=va2[0][7];

  //возьмем блокировки, отдельно на изменение каждого вида времени
  SetLock;
  if Mode = fNone then
    Exit;
  //если турв был открыт на реадктирование, то редактируемость установим = не закрыт, и блокировок не делаем, ту она уже взята при открытии турв
  //если же был в режиме просмотра, то в режим редактирования не переходим
  FInEditMode := (Mode = fEdit) and (not FIsCommited);
  //режим ввода времени руководителя - если права на ввод этого времени, но не ввод парсек или согласованного
  FInEditMainGridMode := FInEditMode and FRgsEdit1 and not (FRgsEdit2 or FRgsEdit3);
*)
  //добавляем 16 колонок для дневных данных
  //заголовок соотвествует дню из даты
  //поле соответствует позиции в массиве
  //скроем столбцы, большие даты конца периода
  for i := 1 to 16 do begin
    flds1 := flds1 + [[
      'd' + IntToStr(i) + '$s',
      S.IIfStr(IncDay(FTurv.DtBeg, i - 1) > FTurv.DtEnd, '_') +
        //'Период|' +
        IntToStr(DayOf(IncDay(FTurv.DtBeg, i - 1))) + ', '+ DaysOfWeek2[DayOfTheWeek(IncDay(FTurv.DtBeg, i - 1))],
      IntToStr(FDayColWidth) + ';R',
      'e'
    ]];
    flds2 := flds2 + [[
      'd' + IntToStr(i) + '$s',
      S.IIfStr(IncDay(FTurv.DtBeg, i - 1) > FTurv.DtEnd, '_') +
        IntToStr(DayOf(IncDay(FTurv.DtBeg, i - 1))) + ', '+ DaysOfWeek2[DayOfTheWeek(IncDay(FTurv.DtBeg, i - 1))],
      IntToStr(FDayColWidth) + ';R',
      'e'
    ]];
  end;

  Frg1.Options := FrDBGridOptionDef + [myogPanelFind];
  Frg1.Opt.SetFields([
    ['x$s', '*','20'],
    ['name$s','Работник|ФИО','200'],
    ['job$s','Работник|Должность','150'],
    ['is_foreman$s','Работник|Бригадир','40','pic'],
    ['is_trainee$s','Работник|Ученик','40','pic'],
    ['grade$f','Работник|Разряд','40'],
    ['schedulecode$s','Работник|График','50']
    ] + flds1 + [
    ['time$f', 'Итоги|Время', '50'] ,
//    ['premium_p$f', 'Итоги|Премия за период', '50'],
    ['premium$f', 'Итоги|Премии', '50'],
    ['penalty$f', 'Итоги|Депреми' + sLineBreak + 'рование', '50']
//    ['comm$s', 'Итоги|Комментарий', '100']
  ]);
  //ширина столбцов описания работника
  FLeftPartWidth := 200 + 150 + 50;
  Frg1.Opt.SetGridOperations('u');
  Frg1.Opt.SetButtons(1, [
    [mbtView, FRgsEdit1, True, 'Итоговое время'],
    [mbtEdit, FRgsEdit1, False, 'Ввод времени руководителя'],
    [],
    [-mbtDivisionScedule, FInEditMode, True],
    [-mbtWorkerScedule, FInEditMode, True],
    [],
    [-mbtPremiumForDay, FInEditMode and FRgsEdit1, True],
    [-mbtFine, FInEditMode and FRgsEdit1, True],
    [-mbtComment, FInEditMode, True],
    [],
    [mbtSendEMail, FRgsEdit2 and FInEditMode],
    [mbtCustom_SundaysToTurv, FInEditMode and FRgsEdit2, FInEditMode],
    [mbtLock, FRgsCommit and (FTurv.IsCommited or (Mode = fEdit)), True, S.IIFStr(FTurv.IsCommited, 'Отменить закрытие периода', 'Закрыть период')],
    [],
    [mbtPrint],
    [],
    [mbtCtlPanel]
  ]);

  Frg1.CreateAddControls('1', cntLabelClr, '', 'lblDivision', '', 4, yrefT, 800);
  Frg1.CreateAddControls('1', cntLabelClr, '', 'lblWorker', '', 4, yrefB, 800);
  Frg1.SetInitData([], '');

  Frg2.Options := FrDBGridOptionDef;
  flds2 := [['type$s', 'Значение', IntToStr(FLeftPartWidth - 22)]] + flds2;
  Frg2.Opt.SetFields(flds2);
  Frg2.Opt.SetGridOperations('u');
  Frg2.Opt.SetButtons(1, [
    [mbtCtlPanel, True, FLeftPartWidth - 4],
    [],
    [mbtPremiumForPeriod, FInEditMode and FRgsEdit1, False, 'Премия за период', 'edit'],
    [mbtCtlPanel, True, 150],
    [],
    [mbtCommentForWorker, FInEditMode, False, 'Комментарий по работнику', 'edit'],
    [mbtCtlPanel, True, 500],
    [],
    [-mbtPremiumForDay, FInEditMode and FRgsEdit1, True, 'Преимия за день'],
    [-mbtFine, FInEditMode and FRgsEdit1, True, 'Депремирование за день'],
    [-ghtNightWork, FInEditMode, True, 'Ночная смена'],
    [-mbtComment, FInEditMode, True, 'Комментарий'],
    []
  ], cbttSSmall);

  Frg2.CreateAddControls('1', cntLabelClr, 'Работник:', 'lblDWorker', '', 4, yrefC, FLeftPartWidth - 4);
  Frg2.CreateAddControls('2', cntLabelClr, 'Премия:', 'lblDPremium', '', 4, yrefC, 200);
  Frg2.CreateAddControls('3', cntLabelClr, 'Комментарий:', 'lblDComm', '', 4, yrefC, 500);

  Captions2 := ['Время (руководитель)', 'Время (парсек)', 'Время (согласованное)', 'Премия', 'Депремирование'];
  for i := 0 to High(Captions2) do
    values2 := values2 + [[Captions2[i], null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null]];
  Frg2.SetInitData(values2, '');

  Frg1.InfoArray := [
  ['Табель учета рабочего времени.'#13#10#13#10+
  'Здесь отображается список работников подразделения, их должности, графики работы, итоговое время работы за каждый день периода с точностью до получаса '#13#10+
  '(в часах и десятых долях часа), а в правой части - суммарное отработанное время за период, сумма дневных премий и депремирование работника, '#13#10+
  'отдельно премия за весь период, а также комментарий.'#13#10+
  'Над таблицей отображается общая информация о подразделении, а также о выбранном работнике (включая время прихода и ухода работника по системе объективного контроля).'#13#10+
  ''#13#10
  ],
  [
  'При открытии в сетке отображается время от руководителя, и Вы можете вводить данные непосредственно в основной таблице.'#13#10+
  'Для отображения итогового времени нажмите соответствующую кнопку (в этом случае вводить данные в основной таблице будет нельзя!)'#13#10
  , FInEditMode and FRgsEdit1],
  [
  'Для задания графика работы всего подразделения или же конкретного работника за данный период выберите соответствующий пункт контекстного меню.'#13#10+
  'Если для работника задан явно график работы, он подсвечивается синим, иначе график работника будет таким же, как всего подразделения.'#13#10+
  'Время работы работника по системе контроля Парсек вводится автоматически (оно заполняется не при открытии таблицы, а периодически),'#13#10+
  'но Вы можете ввести или скорректировать его вручную в детальной табллице, в этом случае будут использованы введенные Вами данные.'#13#10+
  'Время Парсек имеет приоритет над временем, заданным руководителем, однако ниже по приоритету, чем Согласованное время.'#13#10+
  ''#13#10+
  ''#13#10
  , FInEditMode and FRgsEdit2],
  [
  'Вы можете заполнить согласованное время в детальной таблице. Данное время имеет приоритет, и, если оно задано, то именно оно будет использовано в качестве итогового.'#13#10+
  'Когда все данные в таблице заполнены, нажмите кнопку "Закрыть период". Если все данные введены и корректны, период будет закрыт и внесение изменений в ТУРВ станет невозможным.'#13#10+
  'Однако при необходимости Вы можете отменить закрытие периода (этой же кнопкой).'#13#10+
  ''#13#10
  ,FRgsEdit2],
  [
  'Вы можете нажать "+" слева от имени работника, и открыть таблицу со всеми данными '#13#10+
  '(времена от руководителя, парксек, согласованное, премии), и редактировать данные уже в ней, в соответствии со своим доступом.'#13#10+
  'Нажмите (в любой таблице) правую кнопку мыши для ввода премии, депремирование или комментария.'#13#10+
  '(комментарий вводится к той строке таблицы, которая сейчас выбрана, то есть к примеру это время руководитея, согласованное, или премия).'#13#10+
  'Подведите мышку к синему квадратику, для того чтобы увидеть комментарий.'#13#10+
  'Если Вы руководитель подразделения, то можете ввести также комментарий к строке таблицы и премию работника за период, нажав кнопку сверху.'#13#10+
  'Также для удобства над таблицей отображается информация по работнику по той ячекй, которая сейчас активна.'+
  ''#13#10
  , FInEditMode],
  [
  'Ввод данных в ячейке начинается автоматически при вводе символа, а для редактирования надо дважды кликнуть мышкой по ячейке или нажать F2.'#13#10+
  'Нажатие Enter завершает ввод и перемещает фокус на ячейку вправо, стрелки Вверх и Вниз также завершают ввод и перемещают в предыдущую или следуующую строку таблицы.'#13#10+
  'Клавиша Esc отменяет ввод.'#13#10#13#10
  , FInEditMode],
  [
  'Желтым в таблице отображается отсутствие времени, введенного по системе контроля доступа, а при расхождении'#13#10+
  'его со временем руководителя более чем на час, ячейка становится красной. Серым отображаются дни, в которые работник не числится в подразделении.'#13#10+
  ''#13#10
  ],
  [
  'Данные при вводе сохраняются сразу, сохранять документ дополнительно не нужно.'#13#10
  , FInEditMode]
  ];


  Result := inherited and LoadTurvCodes and LoadTurv;
  if not Result then
    Exit;
//  SetLblDivisionText;
  PushTurvToGrid;
  Frg1.MemTableEh1.First;
//  SetGridEditableMode;
end;

function TFrmWGEdtTurvN.SetLock: Boolean;
var
  st, st1, st2, st3, st4: string;
begin
  //блокировки
  //нужны только в режиме редактирования и если период еще не закрыт
  if not ((Mode = fEdit) and not FTurv.IsCommited) then
    Exit;
  st := '';
  st1 := '';
  st2 := '';
  st3 := '';
    //пробуем заблокировать турв для каждого типа доступа отдельно
  if FRgsEdit1 then
    st1 := Q.DBLock(True, FormDoc, VarToStr(id) + '-1', '', fNone)[1];
  if FRgsEdit2 then
    st2 := Q.DBLock(True, FormDoc, VarToStr(id) + '-2', '', fNone)[1];
  if FRgsEdit3 then
    st3 := Q.DBLock(True, FormDoc, VarToStr(id) + '-3', '', fNone)[1];
  if (st1 = User.GetName) or (st2 = User.GetName) or (st3 = User.GetName) then begin
      //если хотя бы одна блокировка своя, то скажем что мы уже редактируем
    st := 'Вы уже открыли этот ТУРВ для редактирования!';
    MyWarningMessage(st);
    FLockInDB := fNone;
    Mode := fNone;
    Exit;
  end
  else if byte(FRgsEdit1) + byte(FRgsEdit2) + byte(FRgsEdit3) = 1 then begin
      //если только одно право, например время руководителя, то не пишем подробно, просто что уже редактируется други
    if st1 + st2 + st3 <> '' then begin
      st := 'Этот ТУРВ уже редактируется пользователем ' + A.ImplodeNotEmpty([st1, st2, st3], ',') + ' и будет открыт только для просмотра!';
      MyWarningMessage(st);
      Mode := fView;
    end;
  end
  else begin
      //если нескольо прав, то распишем подробно что заблокировано
    if st1 <> '' then begin
      st1 := 'Ввод времени руководителя невозможен, так как этот ТУРВ редактирует ' + st1;
      FRgsEdit1 := False;
    end;
    if st2 <> '' then begin
      st2 := 'Ввод времени по Parsec невозможен, так как этот ТУРВ редактирует ' + st2;
      FRgsEdit2 := False;
    end;
    if st3 <> '' then begin
      st3 := 'Ввод согласованного времени невозможен, так как этот ТУРВ редактирует ' + st3;
      FRgsEdit3 := False;
    end;
    if not (FRgsEdit1 or FRgsEdit2 or FRgsEdit3) then
      Mode := fView;
    st := A.ImplodeNotEmpty([st1, st2, st3], #13#10);
    if st <> '' then
      MyWarningMessage(st);
  end;
end;

function TFrmWGEdtTurvN.LoadTurv: Boolean;
var
  i, j, k: Integer;
  vs: TVarDynArray2;
  v2: TVarDynArray;
  v1: Variant;
  dt, dt1, dtbeg, dtend: TDateTime;
  y, m: Integer;
  res: Integer;
  st: string;
  TurwW: TNamedArr;
begin
  Result := True;
end;

function TFrmWGEdtTurvN.LoadTurvCodes: Boolean;
//загрузим справочник кодов турв
begin
  Result := False;
  Q.QLoadFromQuery('select id, code, name from ref_turvcodes order by code', [], FTurvCodes);
  Result := True;
end;

procedure TFrmWGEdtTurvN.PushTurvToGrid;
var
  i, j: Integer;
begin
  for i := 0 to FTurv.Count - 1 do begin
    Frg1.MemTableEh1.Last;
    Frg1.MemTableEh1.Insert;
    Frg1.MemTableEh1.FieldByName('name').Value := FTurv.GetListTitleString(i, 'name');
    Frg1.MemTableEh1.FieldByName('job').Value := FTurv.GetListTitleString(i, 'job');
    Frg1.MemTableEh1.FieldByName('is_foreman').Value := FTurv.GetListTitleString(i, 'is_foreman');
    Frg1.MemTableEh1.FieldByName('is_trainee').Value := FTurv.GetListTitleString(i, 'is_trainee');
    Frg1.MemTableEh1.FieldByName('grade').Value := FTurv.GetListTitleString(i, 'grade');
    Frg1.MemTableEh1.FieldByName('schedulecode').Value := FTurv.GetListTitleString(i, 'schedulecode');
    Frg1.MemTableEh1.Post;
    for j := 1 to 16 do begin
      PushTurvCellToGrid(i, j);
    end;
  end;
end;

procedure TFrmWGEdtTurvN.PushTurvCellToGrid(ARow, ADay: Integer);
//отобразим ячейку в общем гриде на основании массива данных
var
  st: string;
  v, v0, v1, v2: Variant;
  color: Integer;
  i, j, pos: Integer;
  sum: TVarDynArray;
  e: extended;
  b: Boolean;
{
   если протавлено любое значение в проверенных, то выводится оно, независимо от значения и наличия данных от мастера и парсек
   в противном случае, значение от мастера обязательно должно быть проставлено
   при этом, если не проставлено значение парсек, выводится значение от мастера и жетый фон
   если проставлено время парсек, и разница во времени парсек и мастера менее часа, то выводится время парсек
   если проставлен код парсек, то выводится код парсек, перекрывая значение мастера
   но если протавлены данные и мастера и парсек, при этом одно из них время а другое код, или оба времена, но отличаются болле часа,
   то хоть выводится парсек, но цвет красный, требует согласования
}
begin

//  v := FArrTurv[ARow][ADay][0];
  //получим автоматически номер активной строки грида
  if ARow = -1 then
    ARow := Frg1.MemTableEh1.RecNo - 1;
//arow:=1;
  pos := FTurv.GetPosInDays(ARow, ADay);
  Frg1.SetValue('d' + IntToStr(ADay), ARow, False, IntToStr(pos));
  Frg1.DbGridEh1.Invalidate;
  (*

  v0 := GetTurvCell(ARow, ADay, cTmV);  //проверенное время или код
  v1 := GetTurvCell(ARow, ADay, cTmM);  //время или код от мастеров
  v2 := GetTurvCell(ARow, ADay, cTmP);  //время или код парсек
  color := 0;
    //если задано проверенное время/код, то выводим его, иначе выводим от мастеров
  if v0 = null then begin
    if (v1 = null) and (v2 = null) then begin
      color := 0;
    end
    else if (v1 <> null) and (v2 = null) then begin
      color := 2;   //жетлтый
      v0 := v1;
    end
    else if (v1 = null) and (v2 <> null) then begin
      color := 1;   //красный
      v0 := v2;
    end
    else if (not S.IsNumber(S.NSt(v1), 0, 24)) and (not S.IsNumber(S.NSt(v2), 0, 24)) then begin
      v0 := v2;
    end
    else if S.IsNumber(S.NSt(v1), 0, 24) and S.IsNumber(S.NSt(v2), 0, 24) and (abs(StrToFloat(S.NSt(v1)) - StrToFloat(S.NSt(v2))) <= Module.GetCfgVar(mycfgWtime_autoagreed)) then begin
      v0 := v2;
      if v1 <> v2 then
        color := -1; //красный цвет шрифта
    end
    else begin
      v0 := v2;
      color := 1;
    end;
  end;
  FArrTurv[ARow][ADay][cColor] := color;
    //при редактировании в основном гриде будем отображать в нем время от мастеров/руководителя
  if (FInEditMainGridMode) and (FInEditMode) then
    v0 := v1;
    //форматируем строку, если число
  if S.IsNumber(S.NSt(v0), 0, 24) then
    st := FormatFloat('0.00', S.VarToFloat(v0))
  else
    st := S.NSt(v0);
    //изменим напрямую во внутреннем массиве данных
    //при этом на экране отображения только после получения гридом фокуса, переключение фокуса оставляем за вызывающим
  Frg1.SetValue('d' + IntToStr(ADay), ARow, False, st);
  Frg1.DbGridEh1.Invalidate;

  //итоги в правой части таблицы
  Setlength(sum, 3);
  b := True;
  //цикл по дням
  for i := 1 to FDayColumnsCount do begin
      //время - от мастеров, если установлено парсек то парсек, если установлено согласованное то оно
    e := S.NNum(FArrTurv[ARow][i][1]);
    if (FArrTurv[ARow][i][2] <> null) or (FArrTurv[ARow][i][5] <> null) then
      e := S.NNum(FArrTurv[ARow][i][2]);
    if (FArrTurv[ARow][i][3] <> null) or (FArrTurv[ARow][i][6] <> null) then
      e := S.NNum(FArrTurv[ARow][i][3]);
    sum[0] := sum[0] + e;
    sum[1] := sum[1] + S.NNum(FArrTurv[ARow][i][7]);
    sum[2] := sum[2] + S.NNum(FArrTurv[ARow][i][9]);
      //ячейки красные и желтые, или пустые итоговые и при этом не серые - не даем возможности закрыть турв
    if (S.NNum(FArrTurv[ARow][i][12]) = 1) or (S.NNum(FArrTurv[ARow][i][12]) = 2) or ((FArrTurv[ARow][i][0] <> -1) and (FArrTurv[ARow][i][1]) = null) then
      b := False;
  end;
  //заполним итоговые ячейки мемтейбл
  Frg1.SetValue('time', ARow, False, FormatFloat('0.00', S.NNum(sum[0])));
  Frg1.SetValue('premium_p', ARow, False, FormatFloat('0.00', S.NNum(FArrTitle.G(ARow, 'premium'))));
  Frg1.SetValue('premium', ARow, False, FormatFloat('0.00', S.NNum(sum[1])));
  Frg1.SetValue('penalty', ARow, False, FormatFloat('0.00', S.NNum(sum[2])));
  Frg1.SetValue('comm', ARow, False, FArrTitle.G(ARow, 'comm'));
  //кнопка Закрыть период
  FStatus := 1;
  for j := 0 to High(FArrTurv) do begin
    for i := 1 to FDayColumnsCount do begin
      if (FArrTurv[j][i][cColor] = -1) and (FStatus = 1) then
        FStatus := 2;
      if FArrTurv[j][i][cColor] = 1 then
        FStatus := 3;
      if FStatus = 3 then
        break
    end;
    if FStatus = 3 then
      break
  end;
  *)
end;




end.
