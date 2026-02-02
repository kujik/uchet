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
    procedure Frg1DbGridEh1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell, AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean);
    procedure Frg1DbGridEh1RowDetailPanelShow(Sender: TCustomDBGridEh; var CanShow: Boolean);
    procedure Frg1DbGridEh1DataHintShow(Sender: TCustomDBGridEh; CursorPos: TPoint; Cell: TGridCoord; InCellCursorPos: TPoint; Column: TColumnEh; var Params: TDBGridEhDataHintParams; var Processed: Boolean);
    procedure Frg2DbGridEh1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell, AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean);
    procedure Frg2DbGridEh1DataHintShow(Sender: TCustomDBGridEh; CursorPos: TPoint; Cell: TGridCoord; InCellCursorPos: TPoint; Column: TColumnEh; var Params: TDBGridEhDataHintParams; var Processed: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FTurv : TTurvData;

    FRgsCommit, FRgsEdit1, FRgsEdit2, FRgsEdit3: Boolean;  //права

    FInEditMainGridMode: Boolean;
    FInEditMode: Boolean;
    FIsDetailGridUpdated: Boolean;
    FIsChanged: Boolean;

    FDayColWidth: Integer;
    FLeftPartWidth: Integer;

    function  PrepareForm: Boolean; override;
    function  SetLock: Boolean;
    function  LoadTurv: Boolean;
    procedure PushTurvToGrid;
    procedure PushTurvCellToGrid(ARow, ADay: Integer; ARepaint: Boolean);
    procedure PushTurvCellToDetailGrid(ARow, ADay: Integer);
    function  GetDay(AFieldName: string = ''; AGridNo: Integer = 0): Integer;
    procedure PrintRowsTitle;

    procedure SetLblDivisionText;
    procedure SetLblWorkerText;
    procedure SetLblsDetailText;
    procedure SetGridEditableMode;
    procedure FrgsColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
    procedure FinalizeTurv;
    procedure InputDialog(Mode : Integer);
    procedure SaveDayToDB(r, d: Integer);
    procedure ExportToXlsxA7(Doc: Integer; Date1, Date2: Variant; AutoOpen: Boolean);
    procedure SundaysToTurv(AMode: Integer);
//    procedure SendEMailToHead;





    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;

    procedure Frg2ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg2ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure Frg2SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    procedure Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
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
  var ssort := 'job;employee;schedulecode;organization;personnel_number';
  var sgroup := 'schedulecode;job;employee';
  //var sgroup := 'job;employee;schedulecode;organization;personnel_number';
  FTurv.Create(ID, ssort, sgroup);
  //FTurv.LoadFromParsec;

{
  FTurv.Create(ID);
  FTurv.LoadTurvCodes;
  FTurv.LoadList;
  FTurv.LoadDays;
  FTurv.LoadSchedules;
//  FTurv.SortAndGroup(['job','employee'], ['job']);
  FTurv.SortAndGroup(['job'], []);  //сортировка по должности
  }
//  FTurv.LoadFromParsec;


  if FTurv.Count = 0 then begin
    MyInfoMessage('В этом табеле нет ни одной записи!');
    Exit;
  end;
  if FTurv.ScheduleNotApproved then begin
    MyInfoMessage('Не согласованы плановые графики работы!');
    Mode := fView;
  end;

  FOpt.RefreshParent := True;
  FRgsEdit1 := FTurv.Title.G('rgse') = 1;
  FRgsEdit2 := User.Role(rW_J_Turv_TP);
  FRgsEdit3 := User.Role(rW_J_Turv_TS);
  FRgsCommit := User.Role(rW_J_Turv_Commit);
  ;


  //возьмем блокировки, отдельно на изменение каждого вида времени
  SetLock;
  if Mode = fNone then
    Exit;
  //если турв был открыт на реадктирование, то редактируемость установим = не закрыт, и блокировок не делаем, ту она уже взята при открытии турв
  //если же был в режиме просмотра, то в режим редактирования не переходим

  FInEditMode := (Mode = fEdit) and (not FTurv.IsFinalized);
  //режим ввода времени руководителя - если права на ввод этого времени, но не ввод парсек или согласованного
  FInEditMainGridMode := FInEditMode and FRgsEdit1 and not (FRgsEdit2 or FRgsEdit3);

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

  Frg1.Options := FrDBGridOptionDef + [myogPanelFind] - [myogColoredEven];
  Frg1.Opt.SetFields([
    ['x$s', '*','20'],
    ['name$s','Работник|ФИО','200'],
    ['job$s','Работник|Должность','150'],
    ['is_foreman$s','Работник|Бригадир','50','pic','i'],
    ['is_trainee$s','Работник|Ученик','40','pic','i'],
    ['grade$s','Работник|Разряд','40'],
    ['schedulecode$s','Работник|График','50'],
    ['period_hours_norm$s','Работник|Норма','50']
    ] + flds1 + [
    ['time$f', 'Итоги|Время', '50'] ,
    ['overtime$f', 'Итоги|Перера'#13#10'ботка', '50'] ,
    ['premium$f', 'Итоги|Премии', '50'],
    ['penalty$f', 'Итоги|Депреми'#13#10'рование', '50'],
    ['ids_pers_bonus$s', 'Итоги|Перс.'#13#10'выплата', '50', 'pic=-:0;10'],
    ['status$i', 'Статус', '40', 'pic=0;1;2:2;1;7;3']  //не введено - синяя галка, ок - зеленая, закрыта согласованным +, при ошибках -
//    ['comm$s', 'Итоги|Комментарий', '100']
  ]);
  //ширина столбцов описания работника
  FLeftPartWidth := 200 + 150 + {50 + 40 +} 40 + 50 + 50+ 3;
  Frg1.Opt.SetGridOperations('u');
  Frg1.Opt.SetButtons(1, [
    [mbtView, FRgsEdit1, True, 'Итоговое время'],
    [mbtEdit, FRgsEdit1, False, 'Ввод времени руководителя'],
    {[],
    [-mbtDivisionScedule, FInEditMode, True],
    [-mbtWorkerScedule, FInEditMode, True],}
    [],
    [-mbtPremiumForDay, FInEditMode and FRgsEdit1, True],
    [-mbtFine, FInEditMode and FRgsEdit1, True],
    [-mbtComment, FInEditMode, True],
    [],
    //[mbtSendEMail, FRgsEdit2 and FInEditMode],
    [-1002, FInEditMode and FRgsEdit1 and (FTurv.Title.G('is_office') = 1), FInEditMode, 'Проставить выходные (время руководитяля)'],
    [-1003, FInEditMode and FRgsEdit2, FInEditMode, 'Проставить выходные (время отдела кадров)'],
    [],
    [-1004, FInEditMode and User.IsDeveloper, FInEditMode, 'Загрузить время по Parsec'],
    [],
    [mbtLock, FRgsCommit and (FTurv.IsFinalized or (Mode = fEdit)), True, S.IIFStr(FTurv.IsFinalized, 'Отменить закрытие периода', 'Закрыть период')],
    [],
    [mbtPrint],
    [],
    [mbtCtlPanel]
  ]);

  Frg1.CreateAddControls('1', cntLabelClr, '', 'lblDivision', '', 4, yrefT, 800);
  Frg1.CreateAddControls('1', cntLabelClr, '', 'lblWorker', '', 4, yrefB, 800);
  Frg1.SetInitData([], '');

  Frg2.Options := FrDBGridOptionDef  - [myogColoredEven];
  flds2 := [['type$s', 'Значение', IntToStr(FLeftPartWidth - 22)]] + flds2;
  Frg2.Opt.SetFields(flds2);
  Frg2.Opt.SetGridOperations('u');
  Frg2.Opt.SetButtons(1, [
    {[mbtCtlPanel, True, FLeftPartWidth - 4],
    [],
    [mbtPremiumForPeriod, FInEditMode and FRgsEdit1, False, 'Премия за период', 'edit'],
    [mbtCtlPanel, True, 150],
    [],
    [mbtCommentForWorker, FInEditMode, False, 'Комментарий по работнику', 'edit'],
    [mbtCtlPanel, True, 500],
    [],}
    [mbtCtlPanel],
    [-mbtPremiumForDay, FInEditMode and FRgsEdit1, True, 'Преимия за день'],
    [-mbtFine, FInEditMode and FRgsEdit1, True, 'Депремирование за день'],
    //[-ghtNightWork, FInEditMode, True, 'Ночная смена'],
    [-mbtComment, FInEditMode, True, 'Комментарий'],
    []
  ], cbttSSmall);

  Frg2.CreateAddControls('1', cntLabelClr, 'Работник:', 'lblDWorker', '', 4, yrefC, FLeftPartWidth - 4);
  Frg2.CreateAddControls('2', cntLabelClr, 'Премия:', 'lblDPremium', '', 4, yrefC, 200);
  Frg2.CreateAddControls('3', cntLabelClr, 'Комментарий:', 'lblDComm', '', 4, yrefC, 500);

  Captions2 := ['Время (руководитель)', 'Время (отдел кадров)', 'Время (согласованное)', 'Премия', 'Депремирование', 'Время по графику', 'Приход на работу', 'Уход с работы'];
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


  Result := inherited;
  if not Result then
    Exit;
  SetLblDivisionText;
  PushTurvToGrid;
  Frg1.MemTableEh1.First;
  SetGridEditableMode;
end;

procedure TFrmWGedtTurvN.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  if FIsChanged then begin
    Q.QExecSql('update w_turv_period set status = :status$i where id = :id$i', [FTurv.GetDataStatus, ID]);
  end;
  if FRgsEdit1 then
    Q.DBLock(False, FormDoc, VarToStr(id) + '-1', '', fNone);
  if FRgsEdit2 then
    Q.DBLock(False, FormDoc, VarToStr(id) + '-2', '', fNone);
  if FRgsEdit3 then
    Q.DBLock(False, FormDoc, VarToStr(id) + '-3', '', fNone);
end;

function TFrmWGEdtTurvN.SetLock: Boolean;
var
  st, st1, st2, st3, st4: string;
begin
  //блокировки
  //нужны только в режиме редактирования и если период еще не закрыт
  if not ((Mode = fEdit) and not FTurv.IsFinalized) then
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

procedure TFrmWGedtTurvN.Frg1DbGridEh1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell, AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean);
//отрисуем ячейку
var
  v, v1, v2, v3, v4: string;
  Row, Day, Pos, Color: Integer;
begin
  inherited;
  //рисуем только столбцы с днями
  Day := GetDay(Column.FieldName, 1);
  if Day < 1 then
    Exit;
  //получим комментарии
  FTurv.GetDayCell(Frg1.RecNo - 1, Day, 1, color, v1);
  FTurv.GetDayCell(Frg1.RecNo - 1, Day, 2, color, v2);
  FTurv.GetDayCell(Frg1.RecNo - 1, Day, 3, color, v3);
  v4 := FTurv.GetDayCell(Frg1.RecNo - 1, Day, 100, color, v).AsString;
  //если выйдем, то будет стандартная отрисовка
  //выйдем, если нет никакого комментария
  if (((VarIsEmpty(v1)) or (S.NSt(v1) = '')) and ((VarIsEmpty(v2)) or (S.NSt(v2) = '')) and ((VarIsEmpty(v3)) or (S.NSt(v3) = '')) and ((VarIsEmpty(v4)) or (S.NNum(v4) = 0))) and Frg1.DbGridEh1.ReadOnly then
    Exit;
  //стандартная отрисовка
  TDBGridEh(Sender).DefaultDrawColumnDataCell(Cell, AreaCell, Column, ARect, Params);
  TDBGridEh(Sender).Canvas.Brush.Color := Rgb(150, 255, 150);
  TDBGridEh(Sender).Canvas.Pen.Color := Rgb(150, 255, 150);
  TDBGridEh(Sender).Canvas.Rectangle(ARect.Left, ARect.Top, ARect.Left + 3, ARect.Bottom);
  if S.NSt(v1) + S.NSt(v2) + S.NSt(v3) <> '' then begin
    //и поверху квадратик комментария
    TDBGridEh(Sender).Canvas.Pen.Width := 1;
    //если есть комментарии проверенное/согласованное, то подсветим бирюзовым, если только мастер, то синим
    if (VarToStr(v2) <> '') or (VarToStr(v3) <> '') then
      TDBGridEh(Sender).Canvas.Brush.Color := RGB(255, 0, 255)
    else
      TDBGridEh(Sender).Canvas.Brush.Color := clBlue;
    //нарисуем прямоугольник в верхнем левом углу ячейки
    TDBGridEh(Sender).Canvas.Rectangle(ARect.Left, ARect.Top, ARect.Left + 7, ARect.Top + 7);
  end;
  if S.NNum(v4) <> 0 then begin
    TDBGridEh(Sender).Canvas.Pen.Width := 1;
    TDBGridEh(Sender).Canvas.Brush.Color := clBlack;
    //нарисуем прямоугольник в левом нижнем углу ячейки
    TDBGridEh(Sender).Canvas.Rectangle(ARect.Left, ARect.Bottom - 7, ARect.Left + 7, ARect.Bottom);
  end;
  //флаг что обработали, если не поставить то будет стандартная отрисовка
  Processed := True;
end;

procedure TFrmWGedtTurvN.Frg1DbGridEh1DataHintShow(Sender: TCustomDBGridEh; CursorPos: TPoint; Cell: TGridCoord; InCellCursorPos: TPoint; Column: TColumnEh; var Params: TDBGridEhDataHintParams; var Processed: Boolean);
var
  v1, v2, v3, v4, st: string;
  color, day, w, h: Integer;
begin
  inherited;
  //только столбцы с днями
  day := GetDay(Column.FieldName, 1);
  if day < 1 then
    Exit;
  //получим комментарии
  FTurv.GetDayCell(Frg1.RecNo - 1, Day, 1, color, v1);
  FTurv.GetDayCell(Frg1.RecNo - 1, Day, 2, color, v2);
  FTurv.GetDayCell(Frg1.RecNo - 1, Day, 3, color, v3);
  v4 := FTurv.GetDayCell(Frg1.RecNo - 1, Day, 100, color, st).AsString;
  //если мышка в верхнем лефом углу, вызовем метод формы посказки, а он уже покажет форму, если комментарий непустой,
  //также передаются координаты чтобы форма была помещена в нужном месте.
  if ((InCellCursorPos.X <= 7) and (InCellCursorPos.Y <= 7)) then
    FrmWWsrvTurvComment.ShowDialog(Self, CursorPos.X, CursorPos.Y, v1, v2, v3, null);
  if ((InCellCursorPos.X <= 7) and (InCellCursorPos.Y >= Frg1.DBGridEh1.CellRect(Cell.X, Cell.Y).Bottom - Frg1.DBGridEh1.CellRect(Cell.X, Cell.Y).Top - 7)) then
    FrmWWsrvTurvComment.ShowDialog(Self, CursorPos.X, CursorPos.Y, null, null, null, v4);
end;

procedure TFrmWGedtTurvN.Frg1DbGridEh1RowDetailPanelShow(Sender: TCustomDBGridEh; var CanShow: Boolean);
var
  i, w, h: Integer;
begin
  Frg1.DbGridEh1RowDetailPanelShow(Sender, CanShow);
  //заполним сетки
  for i := 1 to 16 do begin
    PushTurvCellToDetailGrid(-1, i);
  end;
  Frg2.MemTableEh1.First;
  SetLblsDetailText;
  Frg2.GetGridDimensions(w, h);
  Frg1.DbGridEh1.RowDetailPanel.Height := Frg2.DbGridEh1.Top + h + 6 + S.IIf(Frg1.DbGridEh1.RowDetailPanel.Width < (w + 10), 24, 0);
//  SetBtns;
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

procedure TFrmWGEdtTurvN.PushTurvToGrid;
var
  i, j: Integer;
  Premium, Penalty, Worktime: Extended;
  na: TNamedArr;
begin
  Frg1.MemTableEh1.EmptyTable;
  FTurv.CalculateTotals;
  for i := 0 to FTurv.Count - 1 do begin
    Frg1.MemTableEh1.Last;
    Frg1.MemTableEh1.Insert;
    Frg1.MemTableEh1.FieldByName('name').Value := FTurv.GetListTitleString(i, 'name');
    Frg1.MemTableEh1.FieldByName('job').Value := FTurv.GetListTitleString(i, 'job');
    Frg1.MemTableEh1.FieldByName('is_foreman').Value := FTurv.GetListTitleString(i, 'is_foreman');
    Frg1.MemTableEh1.FieldByName('is_trainee').Value := FTurv.GetListTitleString(i, 'is_trainee');
    Frg1.MemTableEh1.FieldByName('grade').Value := FTurv.GetListTitleString(i, 'grade');
    Frg1.MemTableEh1.FieldByName('schedulecode').Value := FTurv.GetListTitleString(i, 'schedulecode');
    Frg1.MemTableEh1.FieldByName('period_hours_norm').Value := FTurv.GetListTitleString(i, 'period_hours_norm');
     Frg1.MemTableEh1.Post;
    for j := 1 to FTurv.DaysCount do begin
      PushTurvCellToGrid(i, j, False);
    end;
    Frg1.MemTableEh1.Edit;
    Frg1.MemTableEh1.FieldByName('time').Value := FTurv.Rows[i].Totals.G('worktime');
    Frg1.MemTableEh1.FieldByName('premium').Value := FTurv.Rows[i].Totals.G('premium');
    Frg1.MemTableEh1.FieldByName('penalty').Value := FTurv.Rows[i].Totals.G('penalty');
    Frg1.MemTableEh1.FieldByName('overtime').Value := FTurv.Rows[i].Totals.G('overtime');
    Frg1.MemTableEh1.FieldByName('status').Value := FTurv.Rows[i].Totals.G('status');
    Frg1.MemTableEh1.FieldByName('ids_pers_bonus').Value := FTurv.Rows[i].Totals.G('ids_pers_bonus');
    Frg1.MemTableEh1.Post;
  end;
  Frg1.MemTableEh1.First;
end;

procedure TFrmWGEdtTurvN.PushTurvCellToGrid(ARow, ADay: Integer; ARepaint: Boolean);
//отобразим ячейку в общем гриде на основании массива данных
var
  v0: Variant;
  Color: Integer;
  st: string;
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
  //получим автоматически номер активной строки грида
  if ARow = -1 then
    ARow := Frg1.MemTableEh1.RecNo - 1;
  //при редактировании в основном гриде будем отображать в нем время от мастеров/руководителя, иначе результирующее
  v0 := FTurv.GetDayCell(ARow, ADay, S.IIf(FInEditMainGridMode and FInEditMode, 1, 0), Color, st, True);
  //изменим напрямую во внутреннем массиве данных
  //при этом на экране отображения только после получения гридом фокуса, переключение фокуса оставляем за вызывающим
  Frg1.SetValue('d' + IntToStr(ADay), ARow, False, v0);
  //посчитаем итоги по строке и обновим данные в таблице
  var na := FTurv.CalculateTotals(ARow);
  Frg1.SetValue('time', ARow, True, na.G('worktime'));
  Frg1.SetValue('premium', ARow, True, na.G('premium'));
  Frg1.SetValue('penalty', ARow, True, na.G('penalty'));
  Frg1.SetValue('overtime', ARow, True, na.G('overtime'));
  Frg1.SetValue('status', ARow, True, na.G('status'));
  Frg1.SetValue('ids_pers_bonus', ARow, True, na.G('ids_pers_bonus'));
  if ARepaint then begin
    Frg1.InvalidateGrid;
    Frg1.DbGridEh1.Repaint;
    //обновим текст лейбла
    SetLblWorkerText;
  end;
end;

procedure TFrmWGEdtTurvN.PushTurvCellToDetailGrid(ARow, ADay: Integer);
//отобразим ячейку в общем гриде на основании массива данных
var
  i, color: Integer;
  v: Variant;
  st: string;
begin
//  try
  if (not Frg2.MemTableEh1.Active) or (Frg2.GetCount(False) = 0) then
    Exit;
  //получим автоматически номер активной строки грида
  if ARow = -1 then
    ARow := Frg1.RecNo - 1;
  for i := 1 to 8 do begin
    v := FTurv.GetDayCell(ARow, ADay, i, color, st, True);
    Frg2.SetValue('d' + IntToStr(ADay), i - 1, False, v);
  end;
  Frg2.InvalidateGrid;
end;

procedure TFrmWGEdtTurvN.PrintRowsTitle;
//скорректируем заголовочную часть основной таблицы (напр профессию, график), если есть группировка
//процедура вызывается при перемещении по гриду
var
  i, j, d: Integer;
  f: TVarDynArray;
  v: Variant;
  b: Boolean;
begin
  d := GetDay;
//  f := ['name', 'job', 'is_foreman', 'grade', 'schedulecode'];
  f := ['name', 'job', 'is_foreman', 'grade', 'schedulecode'];
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    for j := 0 to High(f) do begin
      v := FTurv.GetListTitleString(i, f[j], d);
      if Frg1.GetValue(f[j], i, False) <> v then begin
        Frg1.SetValue(f[j], i, False, v);
        b := True;
      end;
    end;
  end;
  if b then
    Frg1.InvalidateGrid;
end;

function TFrmWGEdtTurvN.GetDay(AFieldName: string = ''; AGridNo: Integer = 0): Integer;
var
  Grid: TFrDBGridEh;
begin
  if  (AGridNo = 2) or ((AGridNo = 0) and Frg2.DbGridEh1.Focused) then Grid := Frg2 else Grid :=Frg1;
  Result := StrToIntDef(Copy(S.IfEmptyStr(AFieldName, Grid.CurrField), 2, 2), -1);
end;

 procedure TFrmWGEdtTurvN.SetLblDivisionText;
var
  st, stc : string;
begin
  if (FInEditMode) and (FInEditMainGridMode) then begin
    st := 'Ввод времени руководителя';
    stc := '$FF0060';
  end
  else if (FInEditMode) and (not FInEditMainGridMode) then begin
    st := 'Ввод данных';
    stc := '$FF00FF';
  end
  else if FTurv.IsFinalized then begin
    st := 'Только просмотр, период закрыт';
    stc := '$0000FF';
  end
  else begin
    st := 'Только просмотр';
    stc := '$009000';
  end;
  TLabelClr(Frg1.FindComponent('lblDivision')).SetCaptionAr2([
    '$000000', 'Подразделение: ', '$FF0000', FTurv.Title.G('name'),
    '$000000', '   Период с ', '$FF0000',  DateToStr(FTurv.DtBeg), '$000000 по $FF0000', DateToStr(FTurv.DtEnd),
    '$000000      [', stc, st, '$000000]'
    ]);
end;

procedure TFrmWGEdtTurvN.SetLblWorkerText;
//выведем данные по работнику и времни, на которого установлена позиция в основном гриде.
//вызываем из события изменения столбца детального грида и изменения столбца основного, а также афтерскролл мемтейбл1
//!если открыт детальнфй грид, и в из ячейки основного ткнуться в детальный и там сразу откроется редактирование, и обратно,
//то сюда не попадает - не вызывается события ни colEnter, ни Cellclick, ни CellMouseClick, если ячейки уже в режиме редактирования!
var
  r, d, pos, posl, i: Integer;
  rec, va: TVarDynArray;
  st: string;
begin

  //выйдем во время загрузки данных
  //а первоначальный показ в итоге прихождится делать в form.onshow
//  if Frg1.InLoadData or Frg2.InLoadData then
//    Exit;
  //если видна детальная панель, то получим из нее, иначе из основной
  if Frg2.DBGridEh1.Focused then begin
    if not Frg2.MemTableEh1.Active or (Frg2.RecNo < 1) or Frg2.InLoadData then
      Exit;
    d := StrToIntDef(Copy(Frg2.CurrField, 2, 2), -1)
  end
  else begin
    if not Frg1.MemTableEh1.Active or (Frg1.RecNo < 1) or Frg1.InLoadData then
      Exit;
    d := StrToIntDef(Copy(Frg1.CurrField, 2, 2), -1);
  end;
  //позиции в массиве данных
  r := Frg1.RecNo - 1;
  if (r < 0) then
    Exit;
  posl := FTurv.Rows[r].Seg.G(0, 'r');
  if posl < 0 then
    Exit;
  pos := FTurv.R(r, d);
  if (d < 0) then
    //не колонки дней - только фио
    TLabelClr(Frg1.FindComponent('lblWorker')).SetCaptionAr2(['$000000Работник: $FF00FF', FTurv.List.G(posl, 'name')])       //!!!T2!!!
  else
    //колонки дней - данные по текущей ячейке
    //два цвета не могут в лейбле сейчас идти подряд без промежутков!
    va := [];
    if pos >= 0 then begin
      va := [
        '$000000', '   Время: ', '$FF0000' +
        FTurv.GetDayCell(-pos, d, 1, i, st, True), ' $000000/$FF0000', FTurv.GetDayCell(-pos, d, 2, i, st, True), ' $000000/$FF0000', FTurv.GetDayCell(-pos, d, 3, i, st, True),
        S.IIfStr(FTurv.Cells[pos].G(d, 'premium').AsInteger > 0, ' $000000   Премия: $FF0000 ' + FTurv.Cells[pos].G(d, 'premium').AsString),
        S.IIfStr(FTurv.Cells[pos].G(d, 'penalty').AsInteger > 0, ' $000000   Депремирование: $FF0000 ' + FTurv.Cells[pos].G(d, 'penalty').AsString),
        S.IIfStr(FTurv.Cells[pos].G(d, 'begtime').AsString <> '', ' $000000   Приход: $FF0000 ' + S.IIfStr(FTurv.Cells[pos].G(d, 'begtime').AsFloat = -1, '-',
          StringReplace(FormatFloat('00.00', FTurv.Cells[pos].G(d, 'begtime').AsFloat), FormatSettings.DecimalSeparator, ':', []))),
        S.IIfStr(FTurv.Cells[pos].G(d, 'endtime').AsString <> '', ' $000000   Уход: $FF0000 ' + S.IIfStr(FTurv.Cells[pos].G(d, 'endtime').AsFloat = -1, '-',
          StringReplace(FormatFloat('00.00', FTurv.Cells[pos].G(d, 'endtime').AsFloat), FormatSettings.DecimalSeparator, ':', []))),
        S.IIfStr(FTurv.Cells[pos].G(d, 'nighttime').AsString <> '', ' $000000   Ночью: $FF0000 ' + S.IIfStr(FTurv.Cells[pos].G(d, 'nighttime').AsFloat = -1, '-',
          StringReplace(FormatFloat('00.00', FTurv.Cells[pos].G(d, 'nighttime').AsFloat), FormatSettings.DecimalSeparator, ':', [])))
      ];
    end;
    TLabelClr(Frg1.FindComponent('lblWorker')).SetCaptionAr2([
      '$000000Работник: $FF00FF', FTurv.List.G(posl, 'name'),
      '$000000', '   Дата: ', '$FF0000', DateToStr(IncDay(FTurv.DtBeg, d - 1))
      ] + va
    );
end;

procedure TFrmWGEdtTurvN.SetLblsDetailText;
//показать в детальной панеле премию и комментарий пользователя, кнопки редактирования
begin
  if not Frg1.MemTableEh1.Active or (Frg1.RecNo < 1) or not Frg2.MemTableEh1.Active or (Frg2.RecNo < 1) or Frg2.InLoadData then
    Exit;
  TLabelClr(Frg2.FindComponent('lblDWorker')).SetCaptionAr2(['$FF0000', Frg1.GetValue('name')]);
{  TLabelClr(Frg2.FindComponent('lblDComm')).SetCaptionAr2(['Комментарий:$FF0000 ', S.IIf(S.NSt(FArrTitle.G(Frg1.RecNo - 1, 'comm')) <> '', FArrTitle.G(Frg1.RecNo - 1, 'comm'), 'нет')]);
  TLabelClr(Frg2.FindComponent('lblDComm')).ShowHint := Length(VarToStr(FArrTitle.G(Frg1.RecNo - 1, 'comm'))) > 150;
  TLabelClr(Frg2.FindComponent('lblDComm')).Hint := VarToStr(FArrTitle.G(Frg1.RecNo - 1, 'comm'));
  TLabelClr(Frg2.FindComponent('lblDPremium')).SetCaptionAr2(['Премия за период:$FF0000 ', FormatFloat('0.00', S.NNum(FArrTitle.G(Frg1.RecNo - 1, 'premium')))]);
  Frg2.SetBtnNameEnabled(1001, null, FInEditMode and FRgsEdit1);
  Frg2.SetBtnNameEnabled(1002, null, FInEditMode);}
end;

procedure TFrmWGEdtTurvN.SetGridEditableMode;
begin
  Frg1.DbGridEh1.ReadOnly := not FRgsEdit1 or not FInEditMode or not FInEditMainGridMode or FTurv.IsFinalized;
  Frg2.DbGridEh1.ReadOnly := not FInEditMode or FTurv.IsFinalized;
  Frg1.Invalidate;
  Frg2.Invalidate;
end;





{ --- События основного грида -------------------------------------------------}

procedure TFrmWGEdtTurvN.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
var
  Row, Day, Pos: Integer;
  Color: Integer;
  v1, v2, v3: Variant;
  st: string;
  status: Integer;
begin
  if (Params.Row = 0) then
    Exit;
  Row := Params.Row - 1;
  Day := GetDay(FieldName, 1);
  if Day < 1 then begin
    Params.Background := clSkyBlue;
    Exit;
  end;
  v3 := FTurv.GetDayCell(Row, Day, 6, Color, st);
  v2 := FTurv.GetDayCell(Row, Day, 2, Color, st);
  v1 := FTurv.GetDayCell(Row, Day, 1, Color, st);
  status := FTurv.CellState(Row, Day);
  if Color = - 1 then begin
    Params.Background := clmyGray;
    Params.ReadOnly := True;
  end
  else begin
    {
    -1  //не заполнено время руководителя при заполненном для парсека
    -2  //не заполнено время ОК при заполненном времени руководителя
    -3  //в поле руководитя код, а ОК - время, или наоборот
    -4  //времена руководителя и ок различаются более чем на час
    -5  //времена руководителя и ок различаются но менее чем на час}
    if status = -1 then Params.Background := clmyPink;
    if status = -2 then Params.Background := clmyYelow;
    if status = -3 then Params.Background := clBlue;
    if status = -4 then Params.Background := clPurple;
    if status = -5 then Params.Background := clAqua;
    //подсветим красным шрифтом выходы в выходные/отпуск/больникц по парсеку и в выходной по графику
    if S.IsNumber(v1.AsString, 0.01, 24) and ((v2.AsString = 'БЛ') or (v2.AsString = 'ОТ') or (v2.AsString = 'В') or (v3.AsString = '0')) then
      Params.Font.Color := clRed;
  end;
{
  case Color of
    1:
      Params.Background := clRed;
    2:
      Params.Background := clYellow;
    4:
      Params.Font.Color := clRed;
    -1:
      begin
        Params.Background := clmyGray;
        Params.ReadOnly := True;
      end;
  end;}
end;

procedure TFrmWGEdtTurvN.Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
  FrgsColumnsUpdateData(Fr, No, Sender, Text, Value, UseText, Handled);
end;

procedure TFrmWGEdtTurvN.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
var
  i, j: Integer;
begin
  SetLblWorkerText;
  PrintRowsTitle;
  for i := 1 to Frg1.DBGridEh1.Columns.Count - 1 do
    if GetDay(Frg1.DBGridEh1.Columns[i].FieldName, 1) > 0 then
      if Frg1.DBGridEh1.Columns[i].PickList.Count = 0 then
        for j := 0 to FTurv.TurvCodes.Count - 1 do
          Frg1.DBGridEh1.Columns[i].PickList.Add(FTurv.TurvCodes.G(j, 'code') + ' - ' + FTurv.TurvCodes.G(j, 'name'));
  Cth.SetButtonState(Frg1, mbtComment, 'Комментарий руководителя', null, FInEditMode and FRgsEdit1);
end;

procedure TFrmWGEdtTurvN.Frg2ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
var
  Row, Day, Pos: Integer;
  Color: Integer;
  v: Variant;
  st: string;
begin
  if (Params.Row = 0) then
    Exit;
  Day := GetDay(FieldName, 1);
  if Day < 1 then begin
    Params.Background := clSkyBlue;
    Exit;
  end
  else begin
    Row := FTurv.R(Frg1.RecNo - 1, Day);
    if Params.Row > 5 then begin
      if Row = -1 then
        Params.Background := clmyGray
      else
        Params.Background := RGB(220, 255, 180);
      if Params.Text = '0' then begin
        Params.Text := 'B';
        Params.Font.Color := clRed;
      end else if S.IsNumber(Params.Text, 0, 10000) then
        Params.Text := FormatFloat('#0.00', StrToFloat(Params.Text));
      if Copy(Params.Text, 1, 1) = '-' then
        Params.Text := '';
      if (Params.Text = '00.00') or (Params.Text = '0.00') then
        Params.Text := '';
      Params.ReadOnly := True;
      Exit;
    end;
    if Row = -1 then begin
      Params.Background := clmyGray;
      Params.ReadOnly := True;
    end
    else if (Params.Row = 2) and FRgsEdit2 then begin
       if FTurv.Cells[Row].G(Day, 'settime3') = 1 then
         Params.Font.Color := clBlue;
    end;
  end;
end;

procedure TFrmWGEdtTurvN.Frg2ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
  FrgsColumnsUpdateData(Fr, No, Sender, Text, Value, UseText, Handled);
end;

procedure TFrmWGEdtTurvN.Frg2SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
var
  i, j: Integer;
begin
  SetLblWorkerText;
  PrintRowsTitle;
  for i := 1 to 16 do begin
    if (Frg2.RecNo in [1, 2, 3]) then begin
      if Frg2.DBGridEh1.Columns[i].PickList.Count = 0 then
        for j := 0 to FTurv.TurvCodes.Count - 1 do
          Frg2.DBGridEh1.Columns[i].PickList.Add(FTurv.TurvCodes.G(j, 'code') + ' - ' + FTurv.TurvCodes.G(j, 'name'));
    end
    else
      Frg2.DBGridEh1.Columns[i].PickList.Clear;
  end;
  if Frg2.MemTableEh1.Active then begin
    Frg2.DbGridEh1.ReadOnly := not FInEditMode or FTurv.IsFinalized or (Frg2.RecNo > 3) or ((Frg2.RecNo = 1) and not FRgsEdit1) or ((Frg2.RecNo = 2) and not FRgsEdit2) or ((Frg2.RecNo = 3) and not FRgsEdit3);
    case Frg2.RecNo of
      1: Cth.SetButtonState(Frg2, mbtComment, 'Комментарий руководителя', null, FInEditMode and FRgsEdit1);
      2: Cth.SetButtonState(Frg2, mbtComment, 'Комментарий отдела кадров', null, FInEditMode and FRgsEdit2);
      3: Cth.SetButtonState(Frg2, mbtComment, 'Комментарий согласовывающего', null, FInEditMode and FRgsEdit3);
      4: Cth.SetButtonState(Frg2, mbtComment, 'Комментарий к премии', null, FInEditMode and FRgsEdit1);
      5: Cth.SetButtonState(Frg2, mbtComment, 'Комментарий к депремированию', null, FInEditMode and FRgsEdit1);
    end;
  end;
end;

procedure TFrmWGEdtTurvN.Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  case Tag of
    mbtComment, mbtPremiumForDay, mbtFine, mbtPremiumForPeriod, mbtCommentForWorker, ghtNightWork: InputDialog(Tag);
  end;
  Handled := True;
end;



procedure TFrmWGedtTurvN.Frg2DbGridEh1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell, AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean);
var
  v1, v2: string;
  r, c: Integer;
  day: Integer;
  color: Integer;
begin
  inherited;
  day :=GetDay(Column.FieldName, 2);
  //рисуем только столбцы с днями
  if day <= 0 then
    Exit;
  //получим комментарии
  FTurv.GetDayCell(Frg1.RecNo - 1, day, Params.Row, color, v1);
  v2 := '';
  if Params.Row = 2 then
    v2 := FTurv.GetDayCell(Frg1.RecNo - 1, day, 100, color, v2).AsString;
  //стандартная отрисовка
  TDBGridEh(Sender).DefaultDrawColumnDataCell(Cell, AreaCell, Column, ARect, Params);
  //зеленая полоса
  if not(not FInEditMode or FTurv.IsFinalized or (Params.Row > 3) or ((Params.Row= 1) and not FRgsEdit1) or ((Params.Row = 2) and not FRgsEdit2) or ((Params.Row = 3) and not FRgsEdit3)) then begin
    TDBGridEh(Sender).Canvas.Brush.Color := Rgb(150, 255, 150);
    TDBGridEh(Sender).Canvas.Pen.Color := Rgb(150, 255, 150);
    TDBGridEh(Sender).Canvas.Rectangle(ARect.Left, ARect.Top, ARect.Left + 3, ARect.Bottom);
  end;
  //и поверху квадратик комментария
  TDBGridEh(Sender).Canvas.Pen.Width := 1;
  if (VarToStr(v1) <> '') then begin
    if (Params.Row in [2, 3]) then
      TDBGridEh(Sender).Canvas.Brush.Color := RGB(255, 0, 255)
    else
      TDBGridEh(Sender).Canvas.Brush.Color := clBlue;
    //нарисуем прямоугольник в верхнем левом углу ячейки
    TDBGridEh(Sender).Canvas.Rectangle(ARect.Left, ARect.Top, ARect.Left + 7, ARect.Top + 7);
  end;
  if S.NNum(v2) <> 0 then begin
    TDBGridEh(Sender).Canvas.Pen.Width := 1;
    TDBGridEh(Sender).Canvas.Brush.Color := clBlack;
    //нарисуем прямоугольник в левом нижнем углу ячейки
    TDBGridEh(Sender).Canvas.Rectangle(ARect.Left, ARect.Bottom - 7, ARect.Left + 7, ARect.Bottom);
  end;
  //флаг что обработать, если не поставить то будет стандартная отрисовка
  Processed := True;
end;

procedure TFrmWGedtTurvN.Frg2DbGridEh1DataHintShow(Sender: TCustomDBGridEh; CursorPos: TPoint; Cell: TGridCoord; InCellCursorPos: TPoint; Column: TColumnEh; var Params: TDBGridEhDataHintParams; var Processed: Boolean);
var
  v, v1, v2, v3, v4: string;
  day, color: Integer;
begin
  Day := GetDay(Column.FieldName, 1);
  if Day < 1 then
    Exit;
  //получим комментарии
  v1 := '';
  //FTurv.GetDayCell(Frg1.RecNo - 1, Day, 2, color, v2);
  v2 := '';
  v3 := '';
  v4 := '';
  case Cell.Y of
    1:
      FTurv.GetDayCell(Frg1.RecNo - 1, Day, Cell.Y, color, v1);
    2:
      begin
        FTurv.GetDayCell(Frg1.RecNo - 1, Day, Cell.Y, color, v2);
        v4 := FTurv.GetDayCell(Frg1.RecNo - 1, Day, 100, color, v).AsString;
      end;
    3:
      FTurv.GetDayCell(Frg1.RecNo - 1, Day, Cell.Y, color, v3);
    4:
      FTurv.GetDayCell(Frg1.RecNo - 1, Day, Cell.Y, color, v1);
    5:
      FTurv.GetDayCell(Frg1.RecNo - 1, Day, Cell.Y, color, v1);
  end;
  //если мышка в верхнем лефом углу, вызовем метод формы посказки, а он уже покажет форму, если комментарий непустой,
  //также передаются координаты чтобы форма была помещена в нужном месте.
  if (InCellCursorPos.X <= 7) and (InCellCursorPos.Y <= 7) then
    FrmWWsrvTurvComment.ShowDialog(Self, CursorPos.X, CursorPos.Y + Frg1.RecNo * Frg1.DBGridEh1.RowHeight, v1, v2, v3, null);
  if ((InCellCursorPos.X <= 7) and (InCellCursorPos.Y >= Frg2.DBGridEh1.CellRect(Cell.X, Cell.Y).Bottom - Frg2.DBGridEh1.CellRect(Cell.X, Cell.Y).Top - 7)) then
    FrmWWsrvTurvComment.ShowDialog(Self, CursorPos.X, CursorPos.Y, null, null, null, v4);
end;

procedure TFrmWGEdtTurvN.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
var
  rn, i, j: Integer;
  dt: TDateTime;
  b: Boolean;
  va: TVarDynArray;
  st, st1, st2, st3: string;
begin
  Handled := True;
  if A.InArray(Tag, [mbtComment, mbtPremiumForDay, mbtFine, mbtDivisionScedule, mbtWorkerScedule]) then begin
    //InputDialog(Tag)
  end
  //кнопки ввода времни руководителя/ввода итогов
  else if Tag in [mbtView, mbtEdit] then begin
    if Tag = mbtEdit then
      FInEditMainGridMode := True;
    if Tag = mbtView then
      FInEditMainGridMode := False;
    Frg1.MemTableEh1.DisableControls;
    for i := 0 to Frg1.GetCount(False) - 1 do
      for j := 1 to 16 do
        PushTurvCellToGrid(i, j, False);
    Frg1.MemTableEh1.EnableControls;
  end
  //кнопка закрытия периода
  else if Tag = mbtLock then begin
    FinalizeTurv;
  end
  else if Tag = mbtSendEmail then begin
//    SendEMailToHead;
  end
  else if Tag = 1002 then begin
    SundaysToTurv(1);
  end
  else if Tag = 1003 then begin
    SundaysToTurv(2);
  end
  else if Tag = 1004 then begin
    FTurv.LoadFromParsec;
  end
  else if Tag = mbtPrint then begin
    if FRgsEdit2 then begin
      if TFrmBasicInput.ShowDialog(Self, '', [], fAdd, 'Экспорт в Excel', 270, 50, [
        [cntComboLK,'Шаблон','1:500:0', 210],
        [cntDTEdit,'Дата с','' + S.DateTimeToIntStr(FTurv.DtBeg) + ':' + S.DateTimeToIntStr(FTurv.DtEnd), 90],
        [cntDTEdit,'по ','' + S.DateTimeToIntStr(FTurv.DtBeg) + ':' + S.DateTimeToIntStr(FTurv.DtEnd), 90, 170]],
        [VarArrayOf(['0', VarArrayOf(['ТУРВ по Parsec']), VarArrayOf(['0'])]), FTurv.DtBeg, FTurv.DtEnd],
        va, [['']],  nil
      ) >=0
      then ExportToXlsxA7(Integer(va[0]), va[1], va[2], True);
    end;
  end
  else begin
    Handled := False;
    inherited;
  end;
  SetLblDivisionText;
  SetLblWorkerText;
  SetGridEditableMode;
end;

procedure TFrmWGEdtTurvN.Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
  if (Fr.CurrField = 'ids_pers_bonus') and (Fr.GetValue <> '-') then begin
    var st := 'Персональные надбавки:'#13#10;
    var va1 := A.Explode(Fr.GetValue, #1);
    for var i := 0 to High(va1) do begin
      var va2 := A.Explode(va1[i], #2);
      S.ConcatStP(st, '"' + va2[2].AsString + '" c ' + va2[3].AsString + S.IIfStr(va2[4].AsString <> '', ' по ' + va2[4].AsString) + ', ' + va2[5].AsString + ' руб в месяц', #13#10);
    end;
    MyInfoMessage(st, 1);
  end;
end;

procedure TFrmWGEdtTurvN.FinalizeTurv;
var
  st, st1, st2, st3: string;
begin
  if not FTurv.IsFinalized then
    //если период не закрыт, то проверим, можно ли его закрыть
    if FTurv.GetDataStatus <> 1 then begin
      MyInfoMessage('В этом ТУРВ введены не все данные, закрыть его нельзя!');
      Exit;
    end;
  if MyQuestionMessage(S.IIFStr(FTurv.IsFinalized, 'Вы уверены, что хотите снять статус "Закрыт" с этого ТУРВ?', 'Вы уверены, что хотите отметить этот ТУРВ как "Закрыт"?'#13#10'В этом случае ввод данных в него будет невозможен!')) <> mrYes then
    Exit;
    //пробуем заблокировать турв для каждого типа доступа отдельно
  st1 := Q.DBLock(True, FormDoc, VarToStr(id) + '-1', '', fNone)[1];
  st2 := Q.DBLock(True, FormDoc, VarToStr(id) + '-2', '', fNone)[1];
  st3 := Q.DBLock(True, FormDoc, VarToStr(id) + '-3', '', fNone)[1];
  if (st1 = User.GetName) then
    st1 := '';
  if (st2 = User.GetName) then
    st2 := '';
  if (st3 = User.GetName) then
    st3 := '';
  st := A.ImplodeNotEmpty([st1, st2, st3], #13#10);
  if st <> '' then begin
    MyWarningMessage('Этот турв сейчас открыт на редактирование у'#13#10 + st + #13#10'Установка статуса невозможна!');
    Exit;
  end;
  FTurv.Title.SetValue('is_finalized', S.IIf(FTurv.IsFinalized, 0, 1));
  Q.QExecSql('update w_turv_period set is_finalized = :is_finalized$i where id = :id$i', [S.IIf(FTurv.IsFinalized, 1, 0), ID]);
  FIsChanged := True;
  RefreshParentForm;
end;

procedure TFrmWGEdtTurvN.InputDialog(Mode : Integer);
var
  va1, va2, va3, va4: TVarDynArray;
  i, j, r, d, n, n1, pos, color: Integer;
  st, comm: string;
  rsd: TVarDynArray;
  DataMode: Integer;
  v: Variant;
begin
  for i := 0 to High(myDefaultBtns) do
    if myDefaultBtns[i].Bt = Mode then begin
      st := myDefaultBtns[i].Caption;
      Break;
    end;
  r := Frg1.RecNo - 1;
  //день турв
  d := GetDay;
  if d = -1 then
    Exit;
  pos := FTurv.R(r, d);
  if Mode = mbtComment then begin
    //какой тип данных вводится
    if Frg2.DbGridEh1.Focused then
      n1 := Frg2.RecNo
    else
      n1 := 1;
    FTurv.GetDayCell(-pos, 0, n1, color, comm);
    //тип данных - руководитель, парсек, согласование (1, 2, 3)
 //!!!   if not (((va3[n1] = cComPar) and FRgsEdit2) or ((va3[n1] = cComSogl) and FRgsEdit3) or FRgsEdit1) or not FInEditMode then
 //     Exit;
    if TFrmBasicInput.ShowDialog(Parent, '', [], fAdd, '~' + st, 500, 80, [[cntEdit, 'Комментарий:', '0:400::T']], [comm], va2, [['']], nil) < 0 then
      Exit;
    FTurv.SetDayValues(r, d, S.Decode([n1, 4, 'premium_comm', 5, 'penalty_comm', 'comm' + IntToStr(n1)]), va2[0]);
  end
  else if Mode = mbtPremiumForDay then begin
    v := FTurv.GetDayCell(-pos, 0, 4, color, comm);
    if TFrmBasicInput.ShowDialog(Parent, '', [], fAdd, '~' + st, 500, 80, [[cntNEdit, 'Сумма:', '0:100000'], [cntEdit, 'Комментарий:', '0:400::T']], [v, comm], va2, [['']], nil) < 0 then
      Exit;
    FTurv.SetDayValues(r, d, 'premium', va2[0]);
    FTurv.SetDayValues(r, d, 'premium_comm', va2[1]);
  end
  else if Mode = mbtFine then begin
    v := FTurv.GetDayCell(-pos, 0, 5, color, comm);
    if TFrmBasicInput.ShowDialog(Parent, '', [], fAdd, '~' + st, 500, 80, [[cntNEdit, 'Сумма:', '0:100000'], [cntEdit, 'Комментарий:', '0:400::T']], [v, comm], va2, [['']], nil) < 0 then
      Exit;
    FTurv.SetDayValues(r, d, 'penalty', va2[0]);
    FTurv.SetDayValues(r, d, 'penalty_comm', va2[1]);
  end
  else if Mode = ghtNightWork then begin
    v := FTurv.GetDayCell(-pos, 0, 100, color, comm);
    if TFrmBasicInput.ShowDialog(Parent, '', [], fAdd, '~' + st, 500, 80, [[cntNEdit, 'Ночью, ч.:', '0:24:2:N']], [v], va2, [['']], nil) < 0 then
      Exit;
    FTurv.SetDayValues(r, d, 'nighttime', va2[0]);
  end;
  (*
  else if Mode = mbtPremiumForPeriod then begin
    if d = -1 then
      d := 1;
    va1 := [S.NSt(FArrTitle.G(r, 'premium'))];
    if TFrmBasicInput.ShowDialog(Parent, '', [], fAdd, '~' + st, 180, 60,
      [[cntNEdit, 'Сумма:','0:100000']],
      va1, va2, [['']], nil
    ) < 0 then
      Exit;
    FArrTitle.SetValue(r, 'premium', va2[0]);
    SetLblsDetailText;
    SaveWorkerToDB(r);
  end
  else if Mode = mbtCommentForWorker then begin
    if d = -1 then
      d := 1;
    va1 := [S.NSt(FArrTitle.G(r, 'comm'))];
    if TFrmBasicInput.ShowDialog(Parent, '', [], fAdd, '~' + st, 500, 80,
      [[cntEdit, 'Комментарий:','0:400::T']],
      va1, va2, [['']], nil
    ) < 0 then
      Exit;
    FArrTitle.SetValue(r, 'comm', va2[0]);
    SetLblsDetailText;
    SaveWorkerToDB(r);
  end;}
  else if Mode = mbtDivisionScedule then begin
    if d = -1 then
      d := 1;
    va3 := Q.QLoadToVarDynArrayOneCol('select code from ref_work_schedules where active = 1 order by code', []);
    va4 := Q.QLoadToVarDynArrayOneCol('select id from ref_work_schedules where active = 1 order by code', []);
    va1 := [VarArrayOf([null, VarArrayOf(va3), VarArrayOf(va4)])];
    if TFrmBasicInput.ShowDialog(Parent, '', [], fAdd, '~' + st, 500, 80,
      [[cntComboLk, 'График:','1:50']],
      va1, va2, [['График подразделения (только для данного периода!). Но если это текущий период, то график работы поменяется и в справочнике подразделений.']], nil
    ) < 0 then
      Exit;
    FDivisionScehdule := Q.QSelectOneRow('select code from ref_work_schedules where id = :id', [va2[0]])[0];
    for i := 0 to Frg1.GetCount(False) - 1 do
      if S.NNum(FArrTitle.G(i, 'worker_has_schedule')) <> 1 then begin
        FArrTitle.SetValue(i, 'schedule', FDivisionScehdule);
        Frg1.SetValue('schedule', i, False, FDivisionScehdule);
      end;
    Q.QExecSql('update turv_period set id_schedule = :id_schedule$i where id_division = :id_division$i and dt1 = :dt1$d', [va2[0], FIdDivision, FPeriodStartDate]);
    if FPeriodEndDate >= Date then
      Q.QExecSql('update ref_divisions set id_schedule = :id_schedule$i where id = :id$i', [va2[0], FIdDivision]);
  end
  else if Mode = mbtWorkerScedule then begin
    if d = -1 then
      d := 1;
    va3 := Q.QLoadToVarDynArrayOneCol('select code from ref_work_schedules where active = 1 order by code', []);
    va4 := Q.QLoadToVarDynArrayOneCol('select id from ref_work_schedules where active = 1 order by code', []);
    va1 := [VarArrayOf([null, VarArrayOf(va3), VarArrayOf(va4)])];
    if TFrmBasicInput.ShowDialog(Parent, '', [], fAdd, '~' + st, 500, 80,
      [[cntComboLk, 'График:','0:50']],
      va1, va2,
        [['График работы для выбранного работника. Если он задан (даже такой же, как для подразделения!), то в дальнейшем будет привязан к данному работнику, '+
         'даже при изменении графика подразделения или переводах работника. '+
         'Чтобы привязать график к снова к подразделению, введите здесь пустое значение'
        ]], nil
    ) < 0 then
      Exit;
    FArrTitle.SetValue(r, 'id_schedule', va2[0]);
    if S.NSt(va2[0]) = '' then begin
      FArrTitle.SetValue(r, 'worker_has_schedule', 0);
      st := FDivisionScehdule;
    end
    else begin
      FArrTitle.SetValue(r, 'worker_has_schedule', 1);
      st := Q.QSelectOneRow('select code from ref_work_schedules where id = :id', [va2[0]])[0];
    end;
    FArrTitle.SetValue(r, 'schedule', st);
    Frg1.SetValue('schedule', r, False, st);
    SaveWorkerToDB(r);
    if FPeriodEndDate >= Date then
      Q.QExecSql('update ref_workers set id_schedule = :id_schedule$i where id = :id_worker$i', [S.NullIfEmpty(va2[0]), FArrTitle.G(r, 'id_worker')]);
  end;  *)
  //отобразим данные в основной таблице
  PushTurvCellToGrid(r, d, True);
  //отобразим данные в детальной таблице
  PushTurvCellToDetailGrid(r, d);
  //запишем в БД
  SaveDayToDB(r, d);
end;



procedure TFrmWGEdtTurvN.FrgsColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
var
  st, st1, stc: string;
  v: Variant;
  rsd: TVarDynArray;
  e, e1: extended;
  i, j, r, d, rd: Integer;
  dt: TDateTime;
  sa1: TStringDynArray;
begin
  FIsDetailGridUpdated := TDBGridColumnEh(Sender).Grid = Frg2.DBGridEh1;
  if UseText then
    st := Text
  else
    st := VarToStr(Value);
  r := Frg1.RecNo - 1;
  d := StrToIntDef(Copy(TColumnEh(Sender).FieldName, 2, 2), -1);
  if d = -1 then
    Exit;
  //дополнение к индексу ячейки по типу времени
  if FIsDetailGridUpdated then
    rd := Frg2.RecNo
  else
    rd := 1;
  dt := IncDay(FTurv.DtBeg, d - 1);
  if d < 1 then
    Exit;
  if rd <= 3 then begin
    UseText := True;
    //выделим комментарий - часть введенной строки после прямого слэша
    //!!! работает неправильно если есть слэши в коде турв или его описании, если в коде то он вообще не будет введен!!!
    stc := '~'; //признак что комменатрий не изменился
    sa1 := A.ExplodeS(st, '/');
    st := sa1[0];
    if High(sa1) > 0 then begin
      stc := sa1[1];
      for i := 2 to High(sa1) do
        stc := stc + '/' + sa1[i];
      stc := trim(stc);
    end;
    if not S.IsNumber(st, 0.01, 24, 2) then begin
      //не число, пытаемся вытащить код
      FTurv.SetDayValues(r, d, 'worktime' + IntToStr(rd), null);                  //!!!T
      FTurv.SetDayValues(r, d, 'id_turvcode' + IntToStr(rd), null);
      i := pos(' - ', st);
      if i > 0 then
        st1 := copy(st, 1, i - 1)
      else
        st1 := st;
      for i := 0 to FTurv.TurvCodes.Count - 1 do
        if UpperCase(st1) = UpperCase(FTurv.TurvCodes.G(i, 'code')) then begin
          FTurv.SetDayValues(r, d, 'id_turvcode' + IntToStr(rd), FTurv.TurvCodes.G(i, 'id'));
          Break;
        end;
    end
    else if dt > Date then begin
      //чиисло, но дата больше текущей
      FTurv.SetDayValues(r, d, 'worktime' + IntToStr(rd), null);
      FTurv.SetDayValues(r, d, 'id_turvcode' + IntToStr(rd), null);
    end
    else begin
      //если число от 0 до 24
      //округляем до четверти часа, не менее 0.25
      e := StrToFloat(st);
{        if e<0.13 then e1:=0.25
          else if frac(e)<0.13
          then e1:=round(e)
          else if frac(e)<0.26
          then e1:=trunc(e)+0.25
          else if frac(e)<0.51
          then e1:=trunc(e)+0.5
          else if frac(e)<0.76
          then e1:=trunc(e)+0.75
          else e1:=round(e);}
      //допускаем только значения Х, Х.0 или Х.5
{      if frac(e) >= 0.5 then
        e := trunc(e) + 0.5
      else
        e := trunc(e);}
      e := RoundTo(e, -1);
      if e > 24 then
        e := 24;
      e1 := e;
      //форматируем до двух знаков после запятой
      st := FormatFloat('0.00', e1);
      FTurv.SetDayValues(r, d, 'worktime' + IntToStr(rd), e1);
      FTurv.SetDayValues(r, d, 'id_turvcode' + IntToStr(rd), null);
    end;
    //комментарий
    if stc <> '~' then
      FTurv.SetDayValues(r, d, 'comm' + IntToStr(rd), stc);
    //сбросим подсветку синим при отсутствии одного из времен парсек, если было введено время Парсек
    if rd = 2 then
      FTurv.SetDayValues(r, d, 'settime3', null);
  end;
  //событие обработано
  Handled := True;
  //отобразим данные в основной таблице
  PushTurvCellToGrid(r, StrToInt(Copy(TDBGridColumnEh(Sender).FieldName, 2, 2)), True);
  //отобразим данные в детальной таблице
  PushTurvCellToDetailGrid(r, StrToInt(Copy(TDBGridColumnEh(Sender).FieldName, 2, 2)));
  //сохраним в бд
  SaveDayToDB(r, d);
end;

procedure TFrmWGEdtTurvN.SaveDayToDB(r, d: Integer);
//сохраняем в бд переданную ячейку
var
  Fields, Values: TVarDynArray;
  res, pos, i: Integer;
  dt: TDateTime;
  st: string;
begin
  pos := FTurv.R(r, d);
  //ячейки нет в этом турв - выход
  if pos < 0 then
    Exit;
  if FTurv.Cells[pos].G(d, 'id_employee_properties').AsString = ''
    then FTurv.Cells[pos].SetValue(d, 'id_employee_properties', FTurv.List.G(pos, 'id_employee_properties'));
  if FTurv.Cells[pos].G(d, 'dt').AsString = ''
    then FTurv.Cells[pos].SetValue(d, 'dt', IncDay(FTurv.DtBeg, d - 1));
  if FTurv.Cells[pos].G(d, 'id_employee').AsString = ''
    then FTurv.Cells[pos].SetValue(d, 'id_employee', FTurv.List.G(pos, 'id_employee'));
  //занесем данные
  Fields := [];
  if FRgsEdit1 then
    Fields := Fields + ['worktime1$f', 'id_turvcode1$i', 'comm1$s', 'premium$f', 'premium_comm$s', 'penalty$f', 'penalty_comm$s'];
  if FRgsEdit2 then
    Fields := Fields + ['worktime2$f', 'id_turvcode2$i', 'comm2$s', 'begtime$f', 'endtime$f', 'settime3$i', 'nighttime$f'];
  if FRgsEdit3 then
    Fields := Fields + ['worktime3$f', 'id_turvcode3$i' ,'comm3$s'];
  Q.QBeginTrans(True);
  Q.QExecSql(
    'insert into w_turv_day (id_employee_properties, dt, id_employee) '+
    'select :ide$i, :dt$d, :idempl$i from dual '+
    'where not exists '+
    '(select 1 from w_turv_day where id_employee_properties = :ide2$i and dt = :dt2$d)',
    [FTurv.Cells[pos].G(d, 'id_employee_properties'), FTurv.Cells[pos].G(d, 'dt'), FTurv.Cells[pos].G(d, 'id_employee'), FTurv.Cells[pos].G(d, 'id_employee_properties'), FTurv.Cells[pos].G(d, 'dt')]
  );
  //запишем данные в основную таблицу
  st := Q.QSIUDSql('Q', 'w_turv_day', A.Implode(Fields, ';')) + ' where id_employee_properties = :ide$i and dt = :dt$d';
  Fields := Fields + ['id_employee_properties$i', 'dt$d'];
  Values := [];
  for i := 0 to High(Fields) do
    Values := Values + [FTurv.Cells[pos].G(d, Fields[i])];
  Q.QExecSQL(st, Values);
  FIsChanged := True;
  Q.QCommitOrRollback(True);
end;

procedure TFrmWGEdtTurvN.ExportToXlsxA7(Doc: Integer; Date1, Date2: Variant; AutoOpen: Boolean);
var
  i, j, d1, d2, x, y: Integer;
  sm, sum, sumall: Double;
  v, v1: Variant;
  Rep: TA7Rep;
  FileName: string;
  dt1, dt2: TDateTime;
  b: Boolean;
  Range: Variant;
  st: string;
  color: Integer;
begin
  if Date2 < Date1 then
    Exit;
  if Doc = 0 then
    FileName := 'ТУРВ по Parsec';
  FileName := Module.GetReportFileXlsx(FileName);
  if FileName = '' then
    Exit;
  Rep := TA7Rep.Create;
  try
    Rep.OpenTemplate(FileName);
  except
    Rep.Free;
    Exit;
  end;
  dt1 := Date1;
  dt2 := Date2;
  d1 := trunc(dt1 - FTurv.DtBeg + 1);
  d2 := trunc(dt2 - FTurv.DtBeg + 1);
  Rep.PasteBand('HEADER');
  Rep.SetValue('#MONTH#', DateToStr(FTurv.DtBeg) + ' - ' + DateToStr(FTurv.DtEnd));
  for j := 1 to 16 do begin
    b := (j >= d1) and (j <= d2);
    Rep.ExcelFind('#d' + IntToStr(j) + '#', x, y, xlValues);
    Rep.TemplateSheet.Columns[x].Hidden := not b;
    if b then
      Rep.SetValue('#d' + IntToStr(j) + '#', IntToStr(DayOf(FTurv.DtBeg + j - 1)));
  end;
  for i := 0 to FTurv.List.Count - 1 do begin
    Rep.PasteBand('TABLE');
    Rep.SetValue('#N#', i + 1);
    Rep.SetValue('#FIO#', FTurv.List.G(i, 'name'));
    Rep.SetValue('#JOB#', FTurv.List.G(i, 'job'));             //T!!!
    sum := 0;
    for j := d1 to d2 do begin
      v := FTurv.GetDayCell(i, j, 2, color, st, False).AsString;
      if S.IsNumber(v, 0, 24) then
        sum := sum + v;
      Rep.SetValue('#d' + IntToStr(j) + '#', v);
    end;
    Rep.SetValue('#ITOG#', sum);
    sumall := 0;
    for j := 1 to 16 do begin
      v := FTurv.GetDayCell(i, j, 2, color, st, False).AsString;
      if S.IsNumber(v, 0, 24) then
        sumall := sumall + v;
    end;
    Rep.SetValue('#ITOGA#', sumall);
  end;
//  Rep.PasteBand('FOOTER');
//  Rep.SetValue('#дополнение#',mem_Comm.Text);
  Rep.DeleteCol1;
  Rep.Show;
  Rep.Free;
  Exit;
end;

procedure TFrmWGEdtTurvN.SundaysToTurv(AMode: Integer);
var
  i, j, r1, r2, p: Integer;
begin
  i := MyMessageDlg(
    'Проставить выходные (время '+ S.IIf(AMode = 1, 'руководителя', 'отдела кадров') +')'#13#10'на основе планового графика?'#13#10'(заполненные ячейки не будут изменены)',
     mtConfirmation, [mbYes, mbNo, mbCancel], 'Для всех;В строке;Отмена'
  );
  if i = mrCancel then
    Exit
  else if i = mrYes then begin
    r1 := 0;
    r2 := FTurv.Count - 1;
  end
  else begin
    r1 := Frg1.RecNo - 1;
    r2 := r1;
  end;
  for i := r1 to r2 do
    for j := 1 to FTurv.DaysCount - 1 do begin
      p := FTurv.R(i, j);
      if (p > -1) and (FTurv.Cells[p].G(j, 'worktime' + IntToStr(AMode)) = null) and (FTurv.Cells[p].G(j, 'id_turvcode' + IntToStr(AMode)) = null) and (FTurv.Cells[p].G(j, 'scheduled_hours') = 0) then begin
        FTurv.Cells[p].SetValue(j, 'id_turvcode' + IntToStr(AMode), FTurv.TurvCodeW);
        SaveDayToDB(i, j);
      end;
    end;
  FTurv.CalculateTotals;
  Frg1.InvalidateGrid;
end;


(*
procedure TFrmWGEdtTurv.SendEMailToHead;
//сформируем письмо для руководителей отдела ТУРВ (тех, кто заполняет), с информацией о незаполненных ячейках и ячейках с расхождениями
//времн от руководителя и по парсеку, с указанием работников, чисел и времен
//и откроем сформированное письмо в Thunderbird
var
  i, j, k: Integer;
  v: Variant;
  st, st1: string;
  b, b1, b2: Boolean;
  va1: TVarDynArray;
  va11: TVarDynArray2;
begin
  b := True;
  va1 := [];
  va11 := [];
  //проверим что не все времена по парсеку введены
  for j := 0 to High(FArrTurv) do
    for i := 1 to FDayColumnsCount do
      if (FArrTurv[j][i][cExists] <> -1) and (FArrTurv[j][i][cTPar] = null) and (FArrTurv[j][i][cCPar] = null) then begin
        b := False;
        Break;
      end;
  if (not b) and (MyQuestionMessage('В этом ТУРВ еще не введены все данные по Parsec. Все равно продолжить?') <> mrYes) then
    Exit;
  //получим список работников по которым критические ошибки (красные ячейки) или не запонены данные от руководителя
  for j := 0 to High(FArrTurv) do
    for i := 1 to FDayColumnsCount do
      if (FArrTurv[j][i][cExists] <> -1) and ((FArrTurv[j][i][cTRuk] = null) and (FArrTurv[j][i][cCRuk] = null) or (S.NNum(FArrTurv[j][i][cColor]) = 1)) then begin
        va1 := va1 + [FArrTitle.G(j, 'workername')];
        Break;
      end;
  //получим список работников и для них даты и времена, по которым есть расхождения с парсеком
  for j := 0 to High(FArrTurv) do begin
    st := '';
    for i := 1 to FDayColumnsCount do
      if (FArrTurv[j][i][cExists] <> -1) and (FArrTurv[j][i][cCRuk] = null) and (FArrTurv[j][i][cCPar] = null) and (FArrTurv[j][i][cTRuk] <> null) and (FArrTurv[j][i][cTPar] <> null) and (FArrTurv[j][i][cTRuk] <> FArrTurv[j][i][cTPar]) then
        S.ConcatStP(st, IntToStr(DayOf(FPeriodStartDate) + i - 1) + ':' + VarToStr(FArrTurv[j][i][cTRuk]) + '/' + VarToStr(FArrTurv[j][i][cTPar]), ', ');
    if st <> '' then
      va11 := va11 + [[FArrTitle.G(j, 'workername'), st]];
  end;
  if (Length(va1) = 0) and (Length(va11) = 0) and (MyQuestionMessage('В этом ТУРВ, похоже, введены и согласованы все данные. Все равно сформировать письмо?') <> mrYes) then
    Exit;
  st := 'Внимание!'#13#10 + 'В этом ТУРВ есть недопустимые или несогласованные данные!'#13#10#13#10;
  if Length(va1) > 0 then
    st := st + 'Вы совсем не ввели данные, или же по ним имеются недопустимый расхождения (эти ячейки выделаны красным фоном) по следующим работникам:'#13#10 + A.Implode(va1, #13#10) + #13#10#13#10;
  if Length(va11) > 0 then begin
    st := st + 'Времена по следующим работникам, введенные руководителем, и по Parsec, различаются:'#13#10;
    for i := 0 to High(va11) do
      st := st + va11[i][0] + ':.... ' + va11[i][1] + #13#10;
  end;
  if not b then
    st := st + #13#10 + 'Важно: для этого ТУРВ еще заполнены не все времена по Parsec!!!';
  Module.MailSendWithThunderBird(S.NSt(Q.QSelectOneRow('select GetUsersEmail(:editusers$s) from dual', [FEditUsers])[0]), 'Необходимо поправить ТУРВ "' + FDivisionName + '"', st, '');
end;
*)


end.
