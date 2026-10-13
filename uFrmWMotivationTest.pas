{
Мотивация - Тест (28.09.2026, см. !алгоритмы.txt) - экран для разработчика, первая версия отображения
мотивации по должности/сотруднику панелями-"сетками" (см. обсуждение с пользователем и осмотр образцов
Excel в Test/Мотивация/).

Список должностей (07.10.2026) - только внутренние должности, по которым введена хотя бы часть данных
мотивации (привязаны коэффициенты, позиции специальных коэффициентов, грубые замечания или ЧС). Список
сотрудников - только работавшие в прошлом календарном месяце по ТУРВ (w_turv_day, рабочее время > 0).
Оклад (постоянная часть) и премия (стимулирующая часть) подставляются из справочника "Плановые
начисления по должностям" (w_job_salaries) за прошлый месяц - по официальной должности сотрудника, а
в режиме "По должности" - по официальным должностям специальности (если они однозначны); значения в
полях слева можно поменять вручную для пробного расчёта.

Слева - список внутренних должностей (w_jobs_internal) и переключатель режима "По должности"/"По
сотруднику". В режиме "По сотруднику" под списком должностей появляется список работающих сотрудников
данной должности (v_w_motivation_employees_by_job) - выбор сотрудника пока НИЧЕГО не меняет в самом
отображении (хранения персональных значений коэффициентов по сотруднику еще нет - см. "Итого не
проверено"), это сделано, чтобы сразу видеть разницу между "заготовкой" (без сотрудника) и тем, что
получится, когда персональные данные появятся.

Справа - панели критериев, привязанных к выбранной должности (w_motivation_coefficient_for_job,
вью v_w_motivation_coefficient_for_job) - вид блока подогнан под образцы Excel (Test/Мотивация/,
обсуждение с пользователем 28.09.2026, объединённые ячейки): строка-заголовок на всю ширину
(название, признак "персональный"), затем 7 колонок - "Описание" (description, объединена на всю
высоту блока), "Доля вознаграждения" (шапка на 2 колонки, под ней - % и расчётная сумма, каждая
объединена на все 4 строки оценок), "Оценка"/"Диапазон показателя"/"Коэффициент премии"/
"Комментарий" - по 4 строки оценок (v_w_motivation_coefficients_rates - как в существующем экране
"Мотивация - Коэффициенты", uFrmWGjrnMotivationCoefficients.pas), подсветка выбранной оценки
(вычисляется динамически по значению показателя и диапазонам, не хранится - см.
v_w_motivation_coefficients_rates.is_selected) только для НЕперсональных коэффициентов. Если диапазон
какой-либо оценки не задан/некорректен - в ячейке диапазона красным пишется причина, а в заголовке
блока - предупреждение. Под таблицей оценок выводится текущее значение показателя (с единицей
измерения) и таблица-расшифровка значения (до 3 строк, непустые), если они заданы. Расчётная сумма доли вознаграждения
считается от тестовой суммы премии, вводимой вручную слева (edtPremium) - реальной начисленной
премии сотрудника в этой версии еще нет, см. "Итого не проверено".

Если доли вознаграждения критериев должности в сумме не дают 100% (v_w_motivation_jobs_coeffs, см.
uFrmWGjrnMotivationCoeffsByJob.pas), в верхнем блоке красным выводится предупреждение.

Перед панелями критериев - "шапка" по образцу Excel-файлов (BuildSalaryHeaderBlock, обсуждение с
пользователем 28.09.2026): месяц/должность/формула, блок "Зарплата на руки" (от тестовых значений
оклада и премии слева - edtSalary/edtPremium), сводная таблица "Итоги работы" по 4 оценкам (колонка
"Премия" считается по всем текущим критериям должности), заготовка "Итоговое вознаграждение"/учёт
рабочего времени (ТУРВ) - без расчёта (нет ни фактически выбранных оценок по сотруднику, ни данных
по отработанному времени - см. "Итого не проверено").

Двойной клик по панели критерия - отвязать его от должности (саму запись в общем справочнике
коэффициентов не трогает). Кнопка "Добавить критерий..." - привязать коэффициент из общего справочника
к выбранной должности с указанием доли вознаграждения (создаёт запись в
w_motivation_coefficient_for_job).

Рисование - через uMotivationGridPanel.pas (DrawMotGridPanel) - один и тот же код рисования
предполагается использовать позже и для печати (см. комментарий в начале uMotivationGridPanel.pas) -
в этой версии печать еще не подключена.
}
unit uFrmWMotivationTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uNamedArr, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uMotivationGridPanel, uMotivationCalc
  ;

type
  //"горячая зона" блока - ячейка, по двойному щелчку на которой вводится значение (см. AddHot)
  //Kind: 1..4 и 6 (формула ВЗ) - ввод значения (зелёная линия под ячейкой), 0 - расчётная ячейка (синяя линия), 5 - значение берётся
  //из справочника/константы и здесь не вводится (серая линия); для 0 и 5 по двойному щелчку показывается описание Info
  TMotHotZone = record
    R: TRect;
    Kind: Integer;
    Id1, Id2: Integer;
    Info: string;
  end;
  TMotHotZoneArr = array of TMotHotZone;

  //фрагмент блока на странице при печати (см. TFrmWMotivationTest.PrintBlocks)
  TMotPrintItem = record
    Page, Block, FirstRow, LastRow, Y: Integer;
  end;

  //область с отрисованными блоками: по клику (в т.ч. по блоку - см. PaintBoxMouseDown) "захватывает" фокус, после чего
  //стрелки, PgUp/PgDn, Home/End и колесо мыши прокручивают таблицу (Shift+колесо, стрелки влево/вправо - по горизонтали).
  //фокус уходит, когда кликают в левую часть формы (см. LeftAreaMouseDown) или любой другой элемент управления
  TMotScrollBox = class(TScrollBox)
  protected
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function  DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
  end;

  TFrmWMotivationTest = class(TFrmBasicMdi)
  private
    pnlLeft, pnlLeftBottom, pnlPremium: TPanel;
    btnPrint: TButton;
    FPrintJobName, FPrintEmployee: string;
    //формула ВЗ текущей должности (для окна редактирования, см. DoEditFormula)
    FFormulaStored, FFormulaDefault, FFormulaMap: string;
    FFormulaVars: TMotVars;
    FFormulaNames: TMotNames;
    //блокировка данных, результаты расчёта (цвета в списках) - см. RefreshStateUI
    pnlLock: TPanel;
    lblLockState: TLabel;
    btnLock, btnRecalc: TButton;
    memState: TMemo;
    popRecalc: TPopupMenu;
    FState: TMotState;
    FSummary: string;
    FJobStates, FEmpStates: TNamedArr;
    rbgMode: TRadioGroup;
    lbxJobs, lbxEmployees: TListBox;
    lblPremium: TLabel;
    edtPremium: TEdit;
    lblSalary: TLabel;
    edtSalary: TEdit;
    lblPaySource: TLabel;
    FPayUpdating: Boolean;
    sbxClient: TMotScrollBox;
    FBlocks: array of TMotGridData;
    FBlockLinkIds: array of Integer;
    FBlockHot: array of array of TMotHotZone;
    FBlockBoxes: array of TPaintBox;
    FNextTop: Integer;
    function  Prepare: Boolean; override;
    function  GetSelectedJobId: Variant;
    function  GetTestPremiumBase: Variant;
    function  GetTestSalaryBase: Variant;
    procedure PopulateJobsList;
    procedure PopulateEmployeesList(AIdJobInternal: Variant);
    procedure LoadPlannedPay;
    procedure ClearBlocks;
    function  AddBlock(const AData: TMotGridData; ALinkId: Integer): Integer;
    procedure AddHot(ABlock: Integer; const ARect: TRect; AKind, AId1, AId2: Integer; const AInfo: string = '');
    procedure ShowMotInfo(const AInfo: string; AKind: Integer);
    procedure HandleHotZone(const Z: TMotHotZone);
    function  DoEditPersonalCoef(AIdCoef, AIdEmployee: Integer): Boolean;
    function  DoEditSpecValue(AIdItem, AIdEmployee: Integer): Boolean;
    function  DoEditRemarkFact(AIdEmployee, AListKind: Integer): Boolean;
    function  DoEditOutput(AIdCoef, AIdEmployee: Integer): Boolean;
    function  DoEditFormula(AIdJob: Variant): Boolean;
    procedure RenderJob(AIdJobInternal, AIdEmployee: Variant);
    procedure RenderSpecial(AIdJobInternal, AIdEmployee: Variant; AKind, ANum: Integer);
    procedure RenderRemarks(AIdJobInternal, AIdEmployee: Variant; ANum: Integer);
    procedure DoRender;
    procedure RbgModeClick(Sender: TObject);
    procedure LbxJobsClick(Sender: TObject);
    procedure LbxEmployeesClick(Sender: TObject);
    procedure EdtPremiumChange(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure PaintBoxDblClick(Sender: TObject);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure LeftAreaMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure BtnPrintClick(Sender: TObject);
    procedure PrintBlocks;
    procedure LoadResultStates;
    function  JobStateColor(AIdJob: Integer; var ACounts: string): TColor;
    function  EmpStateColor(AIdEmployee: Integer; var AStale: Boolean): TColor;
    procedure LbxDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure RefreshStateUI;
    procedure ShowSelectionState;
    function  RunRecalc(AMode: Integer): Boolean;
    procedure BtnRecalcClick(Sender: TObject);
    procedure MenuRecalcClick(Sender: TObject);
    procedure BtnLockClick(Sender: TObject);
  public
  end;

var
  FrmWMotivationTest: TFrmWMotivationTest;

implementation

uses
  uWindows, uFrmBasicInput, Printers
  ;

{$R *.dfm}

function MotFmt(const AValue: Variant; const AFormat: string): string;
//число из Variant в текст по формату; Null - пусто (FormatFloat от Null вызвал бы ошибку приведения типа)
begin
  if VarIsNull(AValue) or VarIsEmpty(AValue) then Result := '' else Result := FormatFloat(AFormat, AValue.AsFloat);
end;

const
  cMotOutputName = 'выработка';        //название коэффициента с особой отрисовкой/вводом (сравнение без регистра)
  cMotOutputPlanName = 'Норма времени текущий месяц';
  cMotOutputFactName = 'Фактическая выработка';
  cMotOutputTotalName = 'Итог';

function MotIsOutputCoef(const AName: string): Boolean;
//коэффициент "Выработка": слева таблица "норма времени / фактическая выработка / итог" (как в Excel Конструктора)
begin
  Result := AnsiLowerCase(Trim(AName)) = cMotOutputName;
end;

function MotParseNum(const AText: string): Variant;
//число из текста (разделитель - точка или запятая); пусто/не число - Null
var
  s: string;
  d: Double;
begin
  Result := Null;
  s := Trim(AText);
  if s = '' then Exit;
  s := StringReplace(StringReplace(s, '.', FormatSettings.DecimalSeparator, []), ',', FormatSettings.DecimalSeparator, []);
  if TryStrToFloat(s, d) then Result := d;
end;

function FormatMotRange(ARangeFrom, ARangeTo, AIsOutsideRange: Variant): string;
//текстовое представление диапазона показателя (range_from/range_to/is_outside_range - см.
//w_motivation_coefficients_rates) - как в комментарии к таблице в d_motivation.sql
var
  LFrom, LTo: string;
  LOutside: Boolean;
begin
  Result := '';
  LOutside := (not VarIsNull(AIsOutsideRange)) and (AIsOutsideRange = 1);
  if VarIsNull(ARangeFrom) and VarIsNull(ARangeTo) then Exit;
  LFrom := MotFmt(ARangeFrom, '0.##');
  LTo := MotFmt(ARangeTo, '0.##');
  if LOutside then begin
    if (LFrom <> '') and (LTo <> '') then
      Result := 'менее ' + LFrom + ' или более ' + LTo
    else if LFrom <> '' then
      Result := 'менее ' + LFrom
    else
      Result := 'более ' + LTo;
  end else begin
    if (LFrom <> '') and (LTo <> '') then
      Result := 'от ' + LFrom + ' до ' + LTo
    else if LFrom <> '' then
      Result := 'от ' + LFrom
    else if LTo <> '' then
      Result := 'до ' + LTo;
  end;
end;

const
  cMotMonthNames: array[1..12] of string = (
    'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
    'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь');

const
  //общая ширина блоков на экране (как у "шапки")
  cMotBlockWidth = 1035;
  //цвета состояния данных в списках должностей и сотрудников (см. JobStateColor/EmpStateColor)
  cMotStateGreen = TColor($00C8F0C8);
  cMotStateOrange = TColor($0099CCFF);
  cMotStateRed = TColor($00C8C8FF);


function MotNum(const AValue: Variant): string;
//число для текста описаний (до 4 знаков), Null - "нет данных"
begin
  if VarIsNull(AValue) or VarIsEmpty(AValue) then Result := 'нет данных' else Result := FormatFloat('0.####', AValue.AsFloat);
end;

function MotInfo(const ATitle, AFormula: string; const AVars: array of string; const ANote: string = ''): string;
//текст описания расчётной ячейки: название, формула вида x = a + b / c, расшифровка переменных (ячейки/источники и
//текущие значения), примечание
var
  i: Integer;
begin
  Result := ATitle + #13#10#13#10 + 'Формула: ' + AFormula;
  if Length(AVars) > 0 then begin
    Result := Result + #13#10#13#10 + 'Где:';
    for i := 0 to High(AVars) do
      Result := Result + #13#10 + '   ' + AVars[i];
  end;
  if ANote <> '' then
    Result := Result + #13#10#13#10 + ANote;
end;

function MotSrc(const ATitle, AText: string): string;
//текст описания ячейки, значение которой берётся из справочника/константы
begin
  Result := ATitle + #13#10#13#10 + AText;
end;

procedure MotAddZone(var AZones: TMotHotZoneArr; const AData: TMotGridData; ARow, ACol, ARowSpan, AColSpan, AKind: Integer;
  const AInfo: string; AId1: Integer = 0; AId2: Integer = 0);
//добавляет зону (прямоугольник ячейки с объединением) в массив зон блока
var
  n: Integer;
begin
  n := Length(AZones);
  SetLength(AZones, n + 1);
  AZones[n].R := MotGridCellRect(AData, ARow, ACol, ARowSpan, AColSpan);
  AZones[n].Kind := AKind;
  AZones[n].Id1 := AId1;
  AZones[n].Id2 := AId2;
  AZones[n].Info := AInfo;
end;

function BuildSalaryHeaderBlock(const AJobName: string; const AT: TMotTotals; const AFormula: string; var AZones: TMotHotZoneArr): TMotGridData;
//"шапка" по образцу Excel-файлов (Test/Мотивация/, лист "Расчёт", строки 1-16): месяц/должность/формула,
//"Зарплата на руки", сводка "Итоги работы" по 4 оценкам и "Итоговое вознаграждение" с учётом рабочего времени.
//Формулы как в Excel (проверены по файлам Мастер/Нач про-ва/СГП/ОТК):
//  D3 (Зарплата на руки) = оклад + премия (фактическая часть = расчётная x 100%);
//  "Итоги работы", оценка k: премия = L18..O18 x множители специальных коэффициентов для оценки k x замечания x ЧС
//    (AT.GradeSum[k] x AT.GradeMul[k]), на руки = оклад + премия;
//  "Итоговое вознаграждение": оклад = оклад, премия = SUM(J) x К-культура x К-качество x замечания x ЧС
//    (AT.SumJ x AT.FactMul), итого = оклад + премия; с учётом ТУРВ - обе суммы x факт/план часов.
//Множитель специального коэффициента без введённых оценок сотрудника (режим "По должности") = 1.
var
  LMonth: string;
  LSal, LPrem, LKoef, LFinalPrem: Double;
  LSalOk, LPremOk: Boolean;
  k: Integer;
  LGrade: string;
  LSalTxt, LPremTxt, LPlanTxt, LFactTxt: string;
  LRow1H, LFormulaFill: Integer;
  LFormulaFontSize: Integer;
  LWarnColor: TColor;

  function Fmt(AValue: Double): string;
  begin
    Result := FormatFloat('0.##', AValue);
  end;

  function FmtIf(AOk: Boolean; AValue: Double): string;
  begin
    if AOk then Result := Fmt(AValue) else Result := '-';
  end;

begin
  LMonth := cMotMonthNames[MonthOf(Date)];
  LSalOk := not VarIsNull(AT.Salary);
  LPremOk := not VarIsNull(AT.Premium);
  LSal := 0;
  LPrem := 0;
  if LSalOk then LSal := AT.Salary;
  if LPremOk then LPrem := AT.Premium;
  if AT.TurvPlan > 0 then LKoef := AT.TurvFact / AT.TurvPlan else LKoef := 0;

  //строка 1 - обычно отступ; при замечаниях к формуле (неиспользуемые/несуществующие коэффициенты, ошибка) - текст замечаний
  LRow1H := 14;
  if AT.FormulaMsg <> '' then
    LRow1H := 8 + 14 * (Length(AT.FormulaMsg) div 160 + 1 +
      (Length(AT.FormulaMsg) - Length(StringReplace(AT.FormulaMsg, #13#10, '', [rfReplaceAll]))) div 2);
  MotGridSetSize(Result, [35, 150, 185, 135, 65, 65, 65, 135, 135, 65],
    [47, LRow1H, 34, 34, 34, 14, 34, 34, 34, 34, 33, 14, 34, 54, 54, 54]);

  //строка 0 - месяц / должность / формула (A1:B1 / C1:E1 / F1:J1 в образце)
  MotGridSetCell(Result, 0, 0, MotCell(LMonth, 2, 1, True, clNone, mghCenter, clBlack, True, 18));
  MotGridSetCell(Result, 0, 2, MotCell(AJobName, 3, 1, True, clNone, mghCenter, clBlack, True, 14));
  case AT.FormulaSev of
    2: LFormulaFill := $00C8C8FF;   //светло-красный
    1: LFormulaFill := $0099CCFF;   //светло-оранжевый
  else
    LFormulaFill := clNone;
  end;
  if Length(AFormula) > 70 then LFormulaFontSize := 10 else if Length(AFormula) > 45 then LFormulaFontSize := 12 else LFormulaFontSize := 14;
  MotGridSetCell(Result, 0, 5, MotCell(AFormula, 5, 1, True, TColor(LFormulaFill), mghCenter, clBlack, True, LFormulaFontSize));
  if AT.FormulaMsg <> '' then begin
    if AT.FormulaSev = 2 then LWarnColor := clRed else LWarnColor := $000066CC;
    MotGridSetCell(Result, 1, 0, MotCell(AT.FormulaMsg, 10, 1, True, clNone, mghLeft, LWarnColor, True, 8));
  end;

  //строка 2 - "Зарплата на руки" (A3:C3 / D3:E3 / F3:G3 / H3)
  MotGridSetCell(Result, 2, 0, MotCell('Зарплата на руки', 3, 1, True));
  MotGridSetCell(Result, 2, 3, MotCell(FmtIf(LSalOk and LPremOk, LSal + LPrem), 2, 1, True, cMotYellowFill, mghCenter));
  MotGridSetCell(Result, 2, 5, MotCell('Оклад - постоянная часть', 2, 1, True));
  MotGridSetCell(Result, 2, 7, MotCell(FmtIf(LSalOk, LSal), 1, 1, True, cMotSelectedFill, mghCenter));

  //строка 3 - "Утверждённый размер премии на период" (период всегда 100% - пророции по периоду в этой версии нет)
  MotGridSetCell(Result, 3, 0, MotCell('Утверждённый размер премии на период', 3, 1, True));
  MotGridSetCell(Result, 3, 3, MotCell('100%', 2, 1, True, cMotYellowFill, mghCenter));
  MotGridSetCell(Result, 3, 5, MotCell('Премия - расчётная часть', 2, 1, True));
  MotGridSetCell(Result, 3, 7, MotCell(FmtIf(LPremOk, LPrem), 1, 1, True, cMotSelectedFill, mghCenter));

  //строка 4 - "Премия - фактическая часть" = расчётная часть x 100%
  MotGridSetCell(Result, 4, 0, MotCell('Премия - фактическая часть', 3, 1, True));
  MotGridSetCell(Result, 4, 3, MotCell(FmtIf(LPremOk, LPrem), 2, 1, True, cMotYellowFill, mghCenter));

  //строки 6-10 - "Итоги работы": если бы по всем критериям была получена одна и та же оценка
  MotGridSetCell(Result, 6, 0, MotCell('Итоги работы', 3, 1, True, cMotHeaderFill, mghCenter));
  MotGridSetCell(Result, 6, 3, MotCell('Оклад', 1, 1, True, cMotHeaderFill, mghCenter));
  MotGridSetCell(Result, 6, 4, MotCell('Премия', 1, 1, True, cMotHeaderFill, mghCenter));
  MotGridSetCell(Result, 6, 5, MotCell('На руки', 1, 1, True, cMotHeaderFill, mghCenter));

  MotGridSetCell(Result, 7, 0, MotCell('"ОТЛИЧНО"', 3, 1, True));
  MotGridSetCell(Result, 8, 0, MotCell('"ХОРОШО"', 3, 1, True));
  MotGridSetCell(Result, 9, 0, MotCell('"УДОВЛЕТВОРИТЕЛЬНО"', 3, 1, True));
  MotGridSetCell(Result, 10, 0, MotCell('"ЗОНА РОСТА"', 3, 1, True));

  for k := 0 to 3 do begin
    MotGridSetCell(Result, 7 + k, 3, MotCell(FmtIf(LSalOk, LSal), 1, 1, False, clNone, mghCenter));
    MotGridSetCell(Result, 7 + k, 4, MotCell(FmtIf(LPremOk and AT.FormulaOk, AT.GradePrem[k]), 1, 1, False, clNone, mghCenter));
    MotGridSetCell(Result, 7 + k, 5, MotCell(FmtIf(LSalOk and LPremOk and AT.FormulaOk, LSal + AT.GradePrem[k]), 1, 1, False, clNone, mghCenter));
  end;

  //строки 12-14 - "Итоговое вознаграждение" и учёт рабочего времени (ТУРВ)
  MotGridSetCell(Result, 12, 0, MotCell('Итоговое вознаграждение', 3, 1, True, cMotHeaderFill, mghCenter));
  MotGridSetCell(Result, 12, 3, MotCell('Оклад', 1, 1, True, cMotHeaderFill, mghCenter));
  MotGridSetCell(Result, 12, 4, MotCell('Премия', 1, 1, True, cMotHeaderFill, mghCenter));
  MotGridSetCell(Result, 12, 5, MotCell('Итого', 1, 1, True, cMotHeaderFill, mghCenter));
  MotGridSetCell(Result, 12, 6, MotCell('Учёт рабочего времени', 4, 1, True, cMotHeaderFill, mghCenter));

  LFinalPrem := AT.FinalPrem;
  MotGridSetCell(Result, 13, 0, MotCell('Зарплата за период при отработке нормы часов по ТУРВ', 3, 1));
  MotGridSetCell(Result, 13, 3, MotCell(FmtIf(LSalOk, LSal), 1, 1, False, clNone, mghCenter));
  MotGridSetCell(Result, 13, 4, MotCell(FmtIf(LPremOk and AT.FormulaOk, LFinalPrem), 1, 1, False, clNone, mghCenter));
  MotGridSetCell(Result, 13, 5, MotCell(FmtIf(LSalOk and LPremOk and AT.FormulaOk, LSal + LFinalPrem), 1, 1, False, clNone, mghCenter));
  MotGridSetCell(Result, 13, 6, MotCell('План ТУРВ (рабочих часов в период)', 3, 1));
  MotGridSetCell(Result, 13, 9, MotCell(FormatFloat('0.##', AT.TurvPlan), 1, 1, False, cMotSelectedFill, mghCenter));

  MotGridSetCell(Result, 14, 0, MotCell('Зарплата с учётом отработанных часов по ТУРВ на руки', 3, 1));
  MotGridSetCell(Result, 14, 3, MotCell(FmtIf(LSalOk, LSal * LKoef), 1, 1, False, clNone, mghCenter));
  MotGridSetCell(Result, 14, 4, MotCell(FmtIf(LPremOk and AT.FormulaOk, LFinalPrem * LKoef), 1, 1, False, clNone, mghCenter));
  MotGridSetCell(Result, 14, 5, MotCell(FmtIf(LSalOk and LPremOk and AT.FormulaOk, (LSal + LFinalPrem) * LKoef), 1, 1, True, cMotYellowFill, mghCenter));
  MotGridSetCell(Result, 14, 6, MotCell('Факт ТУРВ (рабочих часов в период)', 3, 1));
  MotGridSetCell(Result, 14, 9, MotCell(FormatFloat('0.##', AT.TurvFact), 1, 1, False, cMotSelectedFill, mghCenter));

  MotGridSetCell(Result, 15, 0, MotCell(
    'К расчёту принимается расчётное время, которое сотрудник должен был отработать без отпусков, больничных листов и отпуска за свой счёт. ' +
    'Переработки не учитываются (факт = отработано минус переработка, как в расчётной ведомости). ' + AT.TurvMsg + ' ' +
    'Премия считается по выбранным оценкам критериев; в режиме "По должности" множители специальных коэффициентов и замечаний/ЧС принимаются равными 1.',
    10, 1));

  //---- описания ячеек (двойной щелчок; синяя линия - расчёт, серая - значение из справочника/константы) ----
  SetLength(AZones, 0);
  LSalTxt := FmtIf(LSalOk, LSal);
  LPremTxt := FmtIf(LPremOk, LPrem);
  LPlanTxt := FormatFloat('0.##', AT.TurvPlan);
  LFactTxt := FormatFloat('0.##', AT.TurvFact);

  MotAddZone(AZones, Result, 0, 5, 1, 5, 6, MotInfo('Формула ВЗ (вознаграждения за период) - ДВОЙНОЙ ЩЕЛЧОК: редактировать',
    'ВЗ = ' + AT.FormulaText,
    ['К1, К2, ... - «Сумма премии» блоков критериев (каждая = коэф-нт выбранной оценки х доля х премия расчётная)',
     'следующие К - «Множитель к премии» выбранной оценки в блоках специальных коэффициентов (культура, качество) и «Факт» блока грубых замечаний и ЧС',
     'формула хранится для должности (если не задана, действует стандартная: (К1+К2+...)хК(культура)хК(качество)хК(замечания))'],
    'Тот же результат показан в строке «Итоговое вознаграждение» (колонка «Премия»). В режиме «По должности» множители равны 1.'));
  MotAddZone(AZones, Result, 2, 3, 1, 2, 0, MotInfo('Зарплата на руки', 'x = a + b',
    ['x - эта ячейка',
     'a - «Оклад - постоянная часть» (строка справа, колонка значений) = ' + LSalTxt,
     'b - «Премия - фактическая часть» (строка ниже, слева) = ' + FmtIf(LPremOk, LPrem)]));
  MotAddZone(AZones, Result, 2, 7, 1, 1, 5, MotSrc('Оклад - постоянная часть',
    'Здесь не вводится. Берётся из справочника «Плановые начисления по должностям» (постоянная часть, fixed_pay) за ' +
    'прошлый календарный месяц: в режиме «По сотруднику» - по официальной должности сотрудника, в режиме «По должности» - ' +
    'по официальным должностям специальности (если у них одинаковые значения). Для пробного расчёта можно поправить вручную ' +
    'в поле «Оклад» слева. Текущее значение: ' + LSalTxt));
  MotAddZone(AZones, Result, 3, 3, 1, 2, 5, MotSrc('Утверждённый размер премии на период',
    'Пока константа 100% (пропорций по периодам в этой версии нет).'));
  MotAddZone(AZones, Result, 3, 7, 1, 1, 5, MotSrc('Премия - расчётная часть',
    'Здесь не вводится. Берётся из справочника «Плановые начисления по должностям» (стимулирующая часть, variable_pay) за ' +
    'прошлый календарный месяц (по тем же правилам, что и оклад). Для пробного расчёта можно поправить вручную в поле ' +
    '«Премия» слева. Текущее значение: ' + LPremTxt));
  MotAddZone(AZones, Result, 4, 3, 1, 2, 0, MotInfo('Премия - фактическая часть', 'x = a х b',
    ['x - эта ячейка',
     'a - «Премия - расчётная часть» (строка выше, колонка значений справа) = ' + LPremTxt,
     'b - «Утверждённый размер премии на период» = 100%']));

  for k := 0 to 3 do begin
    case k of
      0: LGrade := 'ОТЛИЧНО';
      1: LGrade := 'ХОРОШО';
      2: LGrade := 'УДОВЛЕТВОРИТЕЛЬНО';
    else
      LGrade := 'ЗОНА РОСТА';
    end;
    MotAddZone(AZones, Result, 7 + k, 3, 1, 1, 0, MotInfo('Итоги работы "' + LGrade + '" - оклад', 'x = a',
      ['x - эта ячейка', 'a - «Оклад - постоянная часть» = ' + LSalTxt]));
    MotAddZone(AZones, Result, 7 + k, 4, 1, 1, 0, MotInfo('Итоги работы "' + LGrade + '" - премия', 'x = ВЗ(К1, К2, ...)',
      ['x - эта ячейка',
       'ВЗ - формула вознаграждения должности (' + AT.FormulaText + ') при условии, что по каждому критерию получена оценка "' + LGrade +
         '": К критериев = коэф-нт этой оценки х доля х премия расчётная; К специальных коэффициентов = «Множитель к премии» этой ' +
         'оценки в их таблицах диапазонов; К замечаний/ЧС = 1'],
      'Это сводка "что было бы, если...". Формулу можно изменить двойным щелчком по ней вверху.'));
    MotAddZone(AZones, Result, 7 + k, 5, 1, 1, 0, MotInfo('Итоги работы "' + LGrade + '" - на руки', 'x = a + b',
      ['x - эта ячейка',
       'a - «Оклад» этой же строки = ' + LSalTxt,
       'b - «Премия» этой же строки = ' + FmtIf(LPremOk and AT.FormulaOk, AT.GradePrem[k])]));
  end;

  MotAddZone(AZones, Result, 13, 3, 1, 1, 0, MotInfo('Итоговое вознаграждение - оклад (при отработке нормы)', 'x = a',
    ['x - эта ячейка', 'a - «Оклад - постоянная часть» = ' + LSalTxt]));
  MotAddZone(AZones, Result, 13, 4, 1, 1, 0, MotInfo('Итоговое вознаграждение - премия (при отработке нормы)', 'x = ВЗ(К1, К2, ...)',
    ['x - эта ячейка',
     'ВЗ - формула вознаграждения должности (' + AT.FormulaText + ') для ФАКТИЧЕСКИХ значений: К критериев = «Сумма премии» блока ' +
       '(коэф-нт ВЫБРАННОЙ оценки х доля х премия расчётная); К специальных коэффициентов = «Множитель к премии» выбранной оценки сотрудника; ' +
       'К замечаний/ЧС = итоговый «Факт» (нет значения - 1)'],
    'В режиме «По должности» множители специальных коэффициентов и замечаний равны 1. Личные коэффициенты без сотрудника дают 0.'));
  MotAddZone(AZones, Result, 13, 5, 1, 1, 0, MotInfo('Итоговое вознаграждение - итого', 'x = a + b',
    ['x - эта ячейка',
     'a - «Оклад» этой же строки = ' + LSalTxt,
     'b - «Премия» этой же строки = ' + FmtIf(LPremOk and AT.FormulaOk, LFinalPrem)]));
  MotAddZone(AZones, Result, 13, 9, 1, 1, 5, MotSrc('План ТУРВ (рабочих часов в период)',
    'Здесь не вводится. ' + LPlanTxt + ' ч - норма часов периода (период ТУРВ - прошлый месяц) по графику работы сотрудника, ' +
    'period_hours_norm из ТУРВ (так же, как в расчётной ведомости). ' + AT.TurvMsg));
  MotAddZone(AZones, Result, 14, 9, 1, 1, 5, MotSrc('Факт ТУРВ (рабочих часов в период)',
    'Здесь не вводится. ' + LFactTxt + ' ч - отработанное время сотрудника за период по ТУРВ БЕЗ переработки: ' +
    'worktime - overtime (CalculateTotals ТУРВ, как в расчётной ведомости). Переработка оплачивается отдельно. ' + AT.TurvMsg));
  MotAddZone(AZones, Result, 14, 3, 1, 1, 0, MotInfo('С учётом ТУРВ - оклад', 'x = a х f / p',
    ['x - эта ячейка',
     'a - «Оклад» строки «Зарплата за период при отработке нормы часов по ТУРВ» = ' + LSalTxt,
     'f - «Факт ТУРВ» = ' + LFactTxt,
     'p - «План ТУРВ» = ' + LPlanTxt]));
  MotAddZone(AZones, Result, 14, 4, 1, 1, 0, MotInfo('С учётом ТУРВ - премия', 'x = a х f / p',
    ['x - эта ячейка',
     'a - «Премия» строки «Зарплата за период при отработке нормы часов по ТУРВ» = ' + FmtIf(LPremOk, LFinalPrem),
     'f - «Факт ТУРВ» = ' + LFactTxt,
     'p - «План ТУРВ» = ' + LPlanTxt]));
  MotAddZone(AZones, Result, 14, 5, 1, 1, 0, MotInfo('С учётом ТУРВ - на руки', 'x = (a + b) х f / p',
    ['x - эта ячейка',
     'a - «Оклад» строки выше (при отработке нормы) = ' + LSalTxt,
     'b - «Премия» строки выше (при отработке нормы) = ' + FmtIf(LPremOk, LFinalPrem),
     'f - «Факт ТУРВ» = ' + LFactTxt,
     'p - «План ТУРВ» = ' + LPlanTxt]));
end;

function TFrmWMotivationTest.Prepare: Boolean;
var
  i: Integer;
  mi: TMenuItem;
begin
  Caption := 'Мотивация - Тест (для разработчика)';
  FOpt.DlgPanelStyle := dpsNone;
  FOpt.StatusBarMode := stbmNone;
  FOpt.AutoAlignControls := False;
  FOpt.InfoArray := [[
    'Мотивация - тестовый экран (для разработчика), первая версия.'#13#10 +
    'Слева - список должностей и режим отображения ("По должности" - без персональных данных'#13#10 +
    'сотрудника, для оценки общего вида; "По сотруднику" - выбор конкретного работника, пока без'#13#10 +
    'хранения персональных значений коэффициентов - следующий шаг).'#13#10 +
    'Справа - сначала "шапка" по образцу Excel (месяц/должность/формула, "Зарплата на руки", сводка'#13#10 +
    '"Итоги работы" по 4 оценкам и "Итоговое вознаграждение" с учётом ТУРВ - оклад и премия берутся из плановых начислений за прошлый месяц,'#13#10 +
    'часы ТУРВ - из ТУРВ за прошлый месяц без переработки (в режиме "По должности" норма 168 ч); премия считается как в Excel: сумма по выбранным оценкам критериев'#13#10 +
    '(доля x премия x коэф-нт) x множители культуры производства/качества работы x замечания/ЧС), затем панели'#13#10 +
    'критериев К1, К2, ... (порядок как в "Коэффициенты по должностям"): в строке выбранной оценки - значение'#13#10 +
    'показателя, справа в объединённой ячейке - сумма премии; затем блоки специальных коэффициентов и'#13#10 +
    '"Грубые замечания и чрезвычайные ситуации" (множители пока 1 - случаи по сотрудникам не хранятся).'#13#10 +
    'Двойной щелчок по ячейке значения - ввод: значение ЛИЧНОГО коэффициента и его расшифровки (режим "По'#13#10 +
    'сотруднику"), оценка показателя специального коэффициента (личная - по сотруднику, по отделу - по'#13#10 +
    'специальности, в т.ч. в режиме "По должности"), итоговый множитель замечаний/ЧС ("Факт"). Состав'#13#10 +
    'коэффициентов задаётся только справочником "Коэффициенты по должностям".'#13#10 +
    'Линия под ячейкой: зелёная - значение вводится (двойной щелчок), синяя - расчётная ячейка, серая - значение'#13#10 +
    'из справочника/константа; двойной щелчок по синей и серой показывает, как считается значение и откуда берутся данные.'
  ]];

  pnlLeft := TPanel.Create(Self);
  pnlLeft.Parent := pnlFrmClient;
  pnlLeft.Align := alLeft;
  pnlLeft.Width := 260;
  pnlLeft.BevelOuter := bvNone;

  rbgMode := TRadioGroup.Create(Self);
  rbgMode.Parent := pnlLeft;
  rbgMode.Align := alTop;
  rbgMode.Caption := 'Режим отображения';
  rbgMode.Height := 60;
  rbgMode.Items.Add('По должности');
  rbgMode.Items.Add('По сотруднику');
  rbgMode.ItemIndex := 0;
  rbgMode.OnClick := RbgModeClick;

  pnlPremium := TPanel.Create(Self);
  pnlPremium.Parent := pnlLeft;
  pnlPremium.Align := alTop;
  pnlPremium.Height := 124;
  pnlPremium.BevelOuter := bvNone;

  lblPremium := TLabel.Create(Self);
  lblPremium.Parent := pnlPremium;
  lblPremium.Left := 4;
  lblPremium.Top := 2;
  lblPremium.Caption := 'Премия (плановая стимулирующая часть):';

  edtPremium := TEdit.Create(Self);
  edtPremium.Parent := pnlPremium;
  edtPremium.Left := 4;
  edtPremium.Top := 18;
  edtPremium.Width := 240;
  edtPremium.Text := '';
  edtPremium.OnChange := EdtPremiumChange;

  //оклад (тестовое значение) - нужен для "шапки" блока по образцу Excel (BuildSalaryHeaderBlock) -
  //реального оклада по должности/сотруднику в этой версии еще нет, см. заголовок модуля
  lblSalary := TLabel.Create(Self);
  lblSalary.Parent := pnlPremium;
  lblSalary.Left := 4;
  lblSalary.Top := 44;
  lblSalary.Caption := 'Оклад (плановая постоянная часть):';

  edtSalary := TEdit.Create(Self);
  edtSalary.Parent := pnlPremium;
  edtSalary.Left := 4;
  edtSalary.Top := 60;
  edtSalary.Width := 240;
  edtSalary.Text := '';
  edtSalary.OnChange := EdtPremiumChange;

  lblPaySource := TLabel.Create(Self);
  lblPaySource.Parent := pnlPremium;
  lblPaySource.Left := 4;
  lblPaySource.Top := 86;
  lblPaySource.Width := 240;
  lblPaySource.Height := 34;
  lblPaySource.AutoSize := False;
  lblPaySource.WordWrap := True;
  lblPaySource.Font.Color := clGray;
  lblPaySource.Caption := '';

  btnPrint := TButton.Create(Self);
  btnPrint.Parent := pnlLeft;
  btnPrint.Align := alTop;
  btnPrint.Top := 10000;
  btnPrint.Height := 28;
  btnPrint.Caption := 'Печать...';
  btnPrint.OnClick := BtnPrintClick;

  //блокировка корректировки данных, пересчёт и состояние результата (см. RefreshStateUI)
  pnlLock := TPanel.Create(Self);
  pnlLock.Parent := pnlLeft;
  pnlLock.Align := alTop;
  pnlLock.Top := 10001;
  pnlLock.Height := 164;
  pnlLock.BevelOuter := bvNone;

  lblLockState := TLabel.Create(Self);
  lblLockState.Parent := pnlLock;
  lblLockState.SetBounds(4, 4, 250, 32);
  lblLockState.AutoSize := False;
  lblLockState.WordWrap := True;
  lblLockState.Font.Style := [fsBold];

  btnLock := TButton.Create(Self);
  btnLock.Parent := pnlLock;
  btnLock.SetBounds(4, 40, 124, 26);
  btnLock.Caption := 'Заблокировать...';
  btnLock.OnClick := BtnLockClick;

  btnRecalc := TButton.Create(Self);
  btnRecalc.Parent := pnlLock;
  btnRecalc.SetBounds(132, 40, 122, 26);
  btnRecalc.Caption := 'Пересчитать...';
  btnRecalc.OnClick := BtnRecalcClick;

  popRecalc := TPopupMenu.Create(Self);
  for i := 0 to 2 do begin
    mi := TMenuItem.Create(popRecalc);
    case i of
      0: mi.Caption := 'Все должности';
      1: mi.Caption := 'Выбранная должность';
      2: mi.Caption := 'Выбранный сотрудник';
    end;
    mi.Tag := i;
    mi.OnClick := MenuRecalcClick;
    popRecalc.Items.Add(mi);
  end;

  memState := TMemo.Create(Self);
  memState.Parent := pnlLock;
  memState.SetBounds(4, 72, 250, 88);
  memState.ReadOnly := True;
  memState.ScrollBars := ssVertical;
  memState.WordWrap := True;
  memState.Color := clBtnFace;
  memState.Font.Size := 8;

  pnlLeftBottom := TPanel.Create(Self);
  pnlLeftBottom.Parent := pnlLeft;
  pnlLeftBottom.Align := alBottom;
  pnlLeftBottom.Height := 232;
  pnlLeftBottom.BevelOuter := bvNone;

  lbxEmployees := TListBox.Create(Self);
  lbxEmployees.Parent := pnlLeftBottom;
  lbxEmployees.Align := alClient;
  lbxEmployees.Visible := False;
  lbxEmployees.OnClick := LbxEmployeesClick;
  lbxEmployees.Style := lbOwnerDrawFixed;
  lbxEmployees.ItemHeight := 18;
  lbxEmployees.OnDrawItem := LbxDrawItem;

  lbxJobs := TListBox.Create(Self);
  lbxJobs.Parent := pnlLeft;
  lbxJobs.Align := alClient;
  lbxJobs.OnClick := LbxJobsClick;
  lbxJobs.Style := lbOwnerDrawFixed;
  lbxJobs.ItemHeight := 18;
  lbxJobs.OnDrawItem := LbxDrawItem;

  sbxClient := TMotScrollBox.Create(Self);
  sbxClient.Parent := pnlFrmClient;
  sbxClient.Align := alClient;
  sbxClient.BevelOuter := bvNone;
  sbxClient.Color := clWhite;
  sbxClient.VertScrollBar.Increment := 40;
  sbxClient.HorzScrollBar.Increment := 40;

  //клик по пустым местам левой панели (не по спискам/полям - те сами забирают фокус) снимает фокус с таблицы
  pnlLeft.OnMouseDown := LeftAreaMouseDown;
  pnlPremium.OnMouseDown := LeftAreaMouseDown;
  pnlLeftBottom.OnMouseDown := LeftAreaMouseDown;
  lblPremium.OnMouseDown := LeftAreaMouseDown;
  lblSalary.OnMouseDown := LeftAreaMouseDown;
  lblPaySource.OnMouseDown := LeftAreaMouseDown;
  pnlLock.OnMouseDown := LeftAreaMouseDown;
  lblLockState.OnMouseDown := LeftAreaMouseDown;

  FNextTop := 8;
  PopulateJobsList;
  RefreshStateUI;

  Result := Inherited;
end;

function TFrmWMotivationTest.GetSelectedJobId: Variant;
begin
  if lbxJobs.ItemIndex < 0 then
    Result := Null
  else
    Result := Integer(lbxJobs.Items.Objects[lbxJobs.ItemIndex]);
end;

function TFrmWMotivationTest.GetTestPremiumBase: Variant;
//тестовая сумма премии (вводится вручную слева, ни к чему в бд не привязана) - только для того,
//чтобы на экране было видно, как считается "Доля вознаграждения, сумма" (вес * эта сумма) - см.
//обсуждение с пользователем 28.09.2026 про объединенные ячейки по образцу Excel-файлов
var
  v: Double;
begin
  if TryStrToFloat(Trim(edtPremium.Text), v) then
    Result := v
  else
    Result := Null;
end;

function TFrmWMotivationTest.GetTestSalaryBase: Variant;
//тестовое значение оклада (см. комментарий у edtSalary в Prepare) - только для "шапки" блока
//(BuildSalaryHeaderBlock), к реальным данным не привязано
var
  v: Double;
begin
  if TryStrToFloat(Trim(edtSalary.Text), v) then
    Result := v
  else
    Result := Null;
end;

procedure TFrmWMotivationTest.PopulateJobsList;
var
  na: TNamedArr;
  i: Integer;
begin
  lbxJobs.Items.Clear;
  //только должности, по которым введена хотя бы часть данных мотивации (см. MotLoadJobs)
  MotLoadJobs(na);
  for i := 0 to na.Count - 1 do
    lbxJobs.Items.AddObject(na.GetValue(i, 'name'), TObject(Integer(na.GetValue(i, 'id'))));
end;

procedure TFrmWMotivationTest.PopulateEmployeesList(AIdJobInternal: Variant);
var
  na: TNamedArr;
  i: Integer;
begin
  lbxEmployees.Items.Clear;
  if VarIsNull(AIdJobInternal) then Exit;
  //только работавшие в прошлом календарном месяце: по ТУРВ (w_turv_day) есть дни с рабочим временем > 0 (согласованное
  //время worktime3, если нет - по парсеку worktime2, как при расчёте итогов ТУРВ в uTurv.pas)
  Q.QLoad('select e.id, e.name from v_w_motivation_employees_by_job e where e.id_job_internal = :id$i and exists (' +
    'select 1 from w_turv_day d where d.id_employee = e.id and d.dt >= trunc(add_months(sysdate, -1), ''mm'') ' +
    'and d.dt < trunc(sysdate, ''mm'') and nvl(d.worktime3, d.worktime2) > 0) order by e.name',
    [AIdJobInternal], na);
  for i := 0 to na.Count - 1 do
    lbxEmployees.Items.AddObject(na.GetValue(i, 'name'), TObject(Integer(na.GetValue(i, 'id'))));
end;

procedure TFrmWMotivationTest.LoadPlannedPay;
//оклад и премия из справочника "Плановые начисления по должностям" за ПРОШЛЫЙ календарный месяц - см. MotLoadPlannedPay
//(сотрудник выбран - по его официальной должности; иначе по должностям специальности, если значения однозначны)
var
  LJob, LEmp, LSal, LPrem: Variant;
  LSrc: string;
begin
  LJob := GetSelectedJobId;
  LEmp := Null;
  if (rbgMode.ItemIndex = 1) and (lbxEmployees.ItemIndex >= 0) then
    LEmp := Integer(lbxEmployees.Items.Objects[lbxEmployees.ItemIndex]);
  LSal := Null;
  LPrem := Null;
  LSrc := '';
  if not VarIsNull(LJob) then
    MotLoadPlannedPay(LJob, LEmp, LSal, LPrem, LSrc);
  FPayUpdating := True;
  try
    edtSalary.Text := MotFmt(LSal, '0.##');
    edtPremium.Text := MotFmt(LPrem, '0.##');
  finally
    FPayUpdating := False;
  end;
  lblPaySource.Caption := LSrc;
end;

procedure TFrmWMotivationTest.ClearBlocks;
var
  i: Integer;
begin
  for i := 0 to High(FBlockBoxes) do
    FBlockBoxes[i].Free;
  SetLength(FBlockBoxes, 0);
  SetLength(FBlocks, 0);
  SetLength(FBlockLinkIds, 0);
  SetLength(FBlockHot, 0);
  FNextTop := 8;
end;

function TFrmWMotivationTest.AddBlock(const AData: TMotGridData; ALinkId: Integer): Integer;
var
  PB: TPaintBox;
  Idx: Integer;
begin
  Idx := Length(FBlocks);
  SetLength(FBlocks, Idx + 1);
  FBlocks[Idx] := AData;
  SetLength(FBlockLinkIds, Idx + 1);
  FBlockLinkIds[Idx] := ALinkId;
  SetLength(FBlockBoxes, Idx + 1);
  SetLength(FBlockHot, Idx + 1);

  PB := TPaintBox.Create(Self);
  PB.Parent := sbxClient;
  PB.Left := 8;
  PB.Top := FNextTop;
  PB.Width := MotGridWidth(AData);
  PB.Height := MotGridHeight(AData);
  PB.Tag := Idx;
  PB.OnPaint := PaintBoxPaint;
  PB.OnDblClick := PaintBoxDblClick;
  PB.OnMouseDown := PaintBoxMouseDown;
  FBlockBoxes[Idx] := PB;

  FNextTop := FNextTop + PB.Height + 12;
  Result := Idx;
end;

procedure TFrmWMotivationTest.PaintBoxPaint(Sender: TObject);
//рисует блок и под ячейками "горячих зон" тонкую цветную линию: зелёная - ячейка вводится (двойной щелчок - ввод),
//синяя - расчётная (двойной щелчок - как считается), серая - значение из справочника/константы (двойной щелчок - откуда)
var
  PB: TPaintBox;
  i: Integer;
  Z: TMotHotZone;
begin
  PB := TPaintBox(Sender);
  DrawMotGridPanel(PB.Canvas, 0, 0, FBlocks[PB.Tag]);
  if (PB.Tag < 0) or (PB.Tag > High(FBlockHot)) then Exit;
  PB.Canvas.Pen.Style := psSolid;
  PB.Canvas.Pen.Width := 2;
  for i := 0 to High(FBlockHot[PB.Tag]) do begin
    Z := FBlockHot[PB.Tag][i];
    case Z.Kind of
      0: PB.Canvas.Pen.Color := $00CC6600;     //синяя (RGB 0,102,204)
      5: PB.Canvas.Pen.Color := $00A0A0A0;     //серая
    else
      PB.Canvas.Pen.Color := $0000A000;        //зелёная (RGB 0,160,0)
    end;
    PB.Canvas.MoveTo(Z.R.Left + 3, Z.R.Bottom - 3);
    PB.Canvas.LineTo(Z.R.Right - 3, Z.R.Bottom - 3);
  end;
end;

procedure TFrmWMotivationTest.ShowMotInfo(const AInfo: string; AKind: Integer);
//описание расчётной ячейки (AKind = 0: как считается) или источника значения (AKind = 5: откуда берётся)
begin
  Application.MessageBox(PChar(AInfo), PChar(S.IIfStr(AKind = 5, 'Откуда берётся значение', 'Как считается')),
    MB_OK or MB_ICONINFORMATION);
end;

procedure TFrmWMotivationTest.RenderJob(AIdJobInternal, AIdEmployee: Variant);
//Порядок блоков (как в Excel): заголовок, шапка (итоги/итоговое вознаграждение), коэффициенты К1..Кn в порядке
//pos привязки к должности (w_motivation_coefficient_for_job.pos), затем специальные коэффициенты (культура
//производства, качество работы - если у должности есть позиции), затем грубые замечания и ЧС (если есть списки).
//У каждого блока префикс "К<номер> - " по порядку следования. Сначала отдельным проходом считаются итоги
//(TMotTotals - для шапки), потом строятся блоки. Состав коэффициентов задаётся только справочником
//"Коэффициенты по должностям" (отвязка/добавление с этого экрана убраны). Значения ЛИЧНЫХ коэффициентов,
//оценки показателей специальных коэффициентов и множители замечаний/ЧС вводятся отсюда двойным щелчком по
//ячейке значения ("горячие зоны" блока, см. AddHot/PaintBoxDblClick).
var
  LJobName, LEmployeeName, LTitle, LDescription, LFormula, LRangeHead: string;
  na, naRates: TNamedArr;
  i, j, n, LRow, LKind, LNum, LRating, LBlock, LDecCnt, LDescRows, LBase, LNeed, LHdesc, LLines: Integer;
  LRowHeights: array of Integer;
  LRangeBad, LPers, LByEmp: Boolean;
  Data: TMotGridData;
  T: TMotTotals;
  LCalc: TMotCalc;
  LStatusText: string;
  LStatusOk: Boolean;
  LStatusFill, LStatusColor: TColor;
  LStatusH: Integer;
  LWeight, LVal, LSelVal: Variant;
  LE, LSumCell: Double;
  LFill: TColor;
  LWeightsWarn: Boolean;
  LIsOutput: Boolean;
  LOutHours, LOutPct: Variant;
  LHeaderData: TMotGridData;
  LHeaderZones: TMotHotZoneArr;
  LSelName, LCoefTxt, LShareTxt, LPremTxt, LValTxt, LTotTxt: string;
  LZi: Integer;
  LTitleHeights: array of Integer;
  LTitleRow: Integer;
  LKindNum: array[1..2] of Integer;
  LRemarksNum: Integer;
  //состояние коэффициентов по номеру в списке na
  LCoefSel: array of Integer;
  LCoefFact: array of Variant;
  LCoefUnit: array of string;
  LCoefDecN, LCoefDecV: array of TMotStr3;
  LDecIdx: array[1..3] of Integer;
  LFName: string;

  function LinesOf(const AText: string; ACharsPerLine: Integer): Integer;
  //оценка числа строк текста при заданной ширине в символах (с учётом переводов строки)
  var
    sl: TStringList;
    k: Integer;
  begin
    sl := TStringList.Create;
    try
      sl.Text := AText;
      Result := 0;
      for k := 0 to sl.Count - 1 do
        Result := Result + Length(sl[k]) div ACharsPerLine + 1;
      if Result = 0 then Result := 1;
    finally
      sl.Free;
    end;
  end;

begin
  ClearBlocks;
  if VarIsNull(AIdJobInternal) then Exit;
  LByEmp := not VarIsNull(AIdEmployee);

  //расчёт (премия, формула ВЗ, проверка полноты и корректности данных) - uMotivationCalc.MotCalcJob; здесь только
  //отображение его результата
  MotCalcJob(AIdJobInternal, AIdEmployee, GetTestSalaryBase, GetTestPremiumBase, LCalc);
  LJobName := LCalc.JobName;
  LEmployeeName := LCalc.EmployeeName;
  FPrintJobName := LJobName;
  FPrintEmployee := LEmployeeName;
  LWeightsWarn := LCalc.WeightsWarn;

  //критерии должности в порядке следования (pos привязки) - те же, что в LCalc.Coefs
  Q.QLoad('select id, id_coefficient, weight, name, description, is_personal ' +
    'from v_w_motivation_coefficient_for_job where id_job_internal = :id_job_internal$i order by pos, id',
    [AIdJobInternal], na);

  //состояние каждого коэффициента (значение, выбранная оценка, расшифровка) - из результата расчёта
  SetLength(LCoefSel, na.Count);
  SetLength(LCoefFact, na.Count);
  SetLength(LCoefUnit, na.Count);
  SetLength(LCoefDecN, na.Count);
  SetLength(LCoefDecV, na.Count);
  for i := 0 to na.Count - 1 do begin
    LCoefSel[i] := 0;
    LCoefFact[i] := Null;
    LCoefUnit[i] := '';
    for j := 1 to 3 do begin
      LCoefDecN[i][j] := '';
      LCoefDecV[i][j] := '';
    end;
    if i <= High(LCalc.Coefs) then begin
      LCoefSel[i] := LCalc.Coefs[i].Sel;
      LCoefFact[i] := LCalc.Coefs[i].Fact;
      LCoefUnit[i] := LCalc.Coefs[i].UnitName;
      LCoefDecN[i] := LCalc.Coefs[i].DecN;
      LCoefDecV[i] := LCalc.Coefs[i].DecV;
    end;
  end;

  T := LCalc.Totals;
  LKindNum[1] := LCalc.KindNum[1];
  LKindNum[2] := LCalc.KindNum[2];
  LRemarksNum := LCalc.RemarksNum;
  FFormulaStored := LCalc.StoredF;
  FFormulaDefault := LCalc.DefaultF;
  FFormulaMap := LCalc.KMap;
  FFormulaVars := LCalc.KVars;
  FFormulaNames := LCalc.KNames;
  if LCalc.FormulaText = '' then
    LFName := 'нет критериев'
  else
    LFName := LCalc.FormulaText;
  LFormula := 'Формула ВЗ = ' + LFName + S.IIfStr(T.FormulaIsDefault and (LCalc.FormulaText <> ''), '  (стандартная)', '');

  //---- блок заголовка ----
  //статус данных по текущим данным (расчёт на лету); в списках слева цвета - по сохранённому пересчётом результату
  if LByEmp then LStatusOk := LCalc.JobOk and LCalc.EmpOk else LStatusOk := LCalc.JobOk;
  if LStatusOk then begin
    LStatusFill := cMotStateGreen;
    LStatusColor := clBlack;
    if LByEmp then
      LStatusText := 'Статус данных: все данные введены и корректны.' + S.IIfStr(LCalc.PremiumOk,
        ' Премия по формуле: ' + FormatFloat('0.##', T.FinalPrem) + ', с учётом ТУРВ: ' + FormatFloat('0.##', LCalc.PremiumTurv) + '.', '')
    else
      LStatusText := 'Статус данных должности: общие данные введены и корректны (данные сотрудников проверяются в режиме "По сотруднику").';
  end else begin
    LStatusFill := cMotStateRed;
    LStatusColor := clMaroon;
    LStatusText := 'Статус данных: ЕСТЬ ЗАМЕЧАНИЯ - данные введены не полностью или некорректны, окончательная премия не рассчитывается.';
    if LCalc.JobMsg <> '' then
      LStatusText := LStatusText + #13#10'ДОЛЖНОСТЬ:'#13#10 + LCalc.JobMsg;
    if LByEmp and (LCalc.EmpMsg <> '') then
      LStatusText := LStatusText + #13#10'СОТРУДНИК:'#13#10 + LCalc.EmpMsg;
  end;
  LStatusH := Max(26, 8 + 14 * LinesOf(LStatusText, 150));
  SetLength(LTitleHeights, 3 + Ord(LEmployeeName <> '') + Ord(LWeightsWarn));
  LTitleHeights[0] := 30;
  for LTitleRow := 1 to High(LTitleHeights) do LTitleHeights[LTitleRow] := 26;
  LTitleHeights[High(LTitleHeights)] := 30;
  LTitleHeights[High(LTitleHeights) - 1] := LStatusH;
  MotGridSetSize(Data, [cMotBlockWidth], LTitleHeights);
  MotGridSetCell(Data, 0, 0, MotCell('Мотивация: ' + LJobName, 1, 1, True, cMotTitleFill));
  LTitleRow := 1;
  if LEmployeeName <> '' then begin
    MotGridSetCell(Data, LTitleRow, 0, MotCell('Сотрудник: ' + LEmployeeName));
    Inc(LTitleRow);
  end;
  if LWeightsWarn then begin
    MotGridSetCell(Data, LTitleRow, 0, MotCell(
      'Внимание: сумма долей вознаграждения критериев этой должности = ' + FormatFloat('0.##', LCalc.WeightsPct) +
      '% (должна быть 100%) - см. "Мотивация - Коэффициенты по должностям".', 1, 1, True, clNone, mghLeft, clRed));
    Inc(LTitleRow);
  end;
  MotGridSetCell(Data, LTitleRow, 0, MotCell(LStatusText, 1, 1, True, LStatusFill, mghLeft, LStatusColor, True, 9));
  //легенда линий под ячейками
  MotGridSetCell(Data, High(LTitleHeights), 0, MotCell(
    'Линия под ячейкой: ЗЕЛЁНАЯ - значение вводится (двойной щелчок), СИНЯЯ - расчётная ячейка, СЕРАЯ - значение из ' +
    'справочника/константа. Двойной щелчок по синей и серой - описание: как считается и откуда берутся данные.',
    1, 1, False, clNone, mghLeft, clGray, True, 8));
  AddBlock(Data, -1);

  LHeaderData := BuildSalaryHeaderBlock(LJobName, T, LFormula, LHeaderZones);
  LBlock := AddBlock(LHeaderData, -1);
  for LZi := 0 to High(LHeaderZones) do
    AddHot(LBlock, LHeaderZones[LZi].R, LHeaderZones[LZi].Kind, 0, 0, LHeaderZones[LZi].Info);

  //---- блоки обычных и личных коэффициентов ----
  for i := 0 to na.Count - 1 do begin
    LPers := na.GetValue(i, 'is_personal') = 1;
    LTitle := 'К' + IntToStr(i + 1) + ' - ' + VarToStr(na.GetValue(i, 'name'));
    if LPers then
      LTitle := LTitle + '  [личный]';
    LDescription := VarToStr(na.GetValue(i, 'description'));
    LWeight := na.GetValue(i, 'weight');

    Q.QLoad('select rating, rating_name, value, range_from, range_to, is_outside_range, comm, ' +
      'range_state, range_state_name ' +
      'from v_w_motivation_coefficients_rates where id_coefficient = :id$i order by rating',
      [na.GetValue(i, 'id_coefficient')], naRates);

    //непустые строки расшифровки значения: они выводятся В ЛЕВОЙ ЯЧЕЙКЕ ПОД ОПИСАНИЕМ (до 3 строк, только введённые)
    LDecCnt := 0;
    for n := 1 to 3 do
      if (LCoefDecN[i][n] <> '') or (LCoefDecV[i][n] <> '') then begin
        Inc(LDecCnt);
        LDecIdx[LDecCnt] := n;
      end;

    //"Выработка": слева ВСЕГДА таблица из 3 строк (норма времени = план ТУРВ, фактическая выработка - вводится по
    //двойному щелчку, итог - процент = факт / норма). Часы факта хранятся в строке расшифровки 2 личного значения
    //(w_motivation_employee_values.decode_value2), процент - в fact_value (по нему вычисляется оценка).
    LIsOutput := MotIsOutputCoef(VarToStr(na.GetValue(i, 'name')));
    LOutHours := Null;
    LOutPct := Null;
    if LIsOutput then begin
      LDecCnt := 3;
      LOutHours := MotParseNum(LCoefDecV[i][2]);
      if (not VarIsNull(LOutHours)) and (LCalc.Totals.TurvPlan > 0) then
        LOutPct := Double(LOutHours) / LCalc.Totals.TurvPlan * 100
      else
        LOutPct := LCoefFact[i];
    end;

    //выбранная оценка и её коэф-нт
    LSelVal := Null;
    for j := 0 to naRates.Count - 1 do
      if Integer(naRates.GetValue(j, 'rating')) = LCoefSel[i] then
        LSelVal := naRates.GetValue(j, 'value');

    //признак того, что хотя бы один диапазон оценок не в порядке (для маркера в заголовке)
    LRangeBad := False;
    for j := 0 to naRates.Count - 1 do
      if (not VarIsNull(naRates.GetValue(j, 'range_state'))) and (naRates.GetValue(j, 'range_state') <> 0) then
        LRangeBad := True;
    if LRangeBad then
      LTitle := LTitle + '  [диапазоны оценок не заданы или некорректны]';

    //10 колонок: Описание/расшифровка (2 колонки: название | значение) | Доля,% | Доля,сумма | Оценка | Диапазон |
    //Коэф-нт | Значение показателя (в строке выбранной оценки) | Сумма премии (объединена на 4 строки) | Комментарий.
    //Слева: описание объединено на строки шапки и оценок, КРОМЕ последних LDecCnt строк - в них таблица
    //расшифровки (до 3 строк: название | значение). Высота строк под описание подбирается по длине текста.
    SetLength(LRowHeights, 6);
    LRowHeights[0] := 32;
    LRowHeights[1] := 30;
    LLines := LinesOf(LDescription, 30);
    LNeed := LLines * 13 + 8;
    LDescRows := 4 - LDecCnt;                //строк оценок под описанием (кроме шапки)
    LHdesc := 28;
    if LDescRows > 0 then
      LHdesc := Max(28, (LNeed - LRowHeights[1] + LDescRows - 1) div LDescRows);
    for j := 2 to 5 do
      if j <= 1 + LDescRows then LRowHeights[j] := LHdesc else LRowHeights[j] := 28;
    for j := 1 to LDecCnt do begin
      LRow := 5 - LDecCnt + j;                //строка таблицы расшифровки
      if LIsOutput then
        LRowHeights[LRow] := 30
      else begin
        LBase := Max(LinesOf(LCoefDecN[i][LDecIdx[j]], 18), LinesOf(LCoefDecV[i][LDecIdx[j]], 11));
        LRowHeights[LRow] := Max(28, LBase * 13 + 6);
      end;
    end;
    MotGridSetSize(Data, [130, 85, 65, 85, 115, 145, 75, 95, 95, 145], LRowHeights);
    MotGridSetCell(Data, 0, 0, MotCell(LTitle, 10, 1, True, cMotTitleFill));

    MotGridSetCell(Data, 1, 0, MotCell(LDescription, 2, 5 - LDecCnt));
    if LIsOutput then begin
      //строки: норма времени (план ТУРВ), фактическая выработка (вводится), итог (процент)
      MotGridSetCell(Data, 3, 0, MotCell(cMotOutputPlanName, 1, 1, False, clNone, mghLeft, clBlack, True, 7));
      MotGridSetCell(Data, 3, 1, MotCell(FormatFloat('0.##', LCalc.Totals.TurvPlan), 1, 1, True, clNone, mghCenter, clBlack, True, 8));
      MotGridSetCell(Data, 4, 0, MotCell(cMotOutputFactName, 1, 1, False, clNone, mghLeft, clBlack, True, 7));
      if not VarIsNull(LOutHours) then
        MotGridSetCell(Data, 4, 1, MotCell(MotFmt(LOutHours, '0.##'), 1, 1, True, clNone, mghCenter, clBlack, True, 8))
      else if LPers and LByEmp then
        MotGridSetCell(Data, 4, 1, MotCell('ввести (2 щелчка)', 1, 1, False, cMotYellowFill, mghCenter, clGray, True, 7))
      else
        MotGridSetCell(Data, 4, 1, MotCell('', 1, 1, False, clNone, mghCenter, clBlack, True, 8));
      MotGridSetCell(Data, 5, 0, MotCell(cMotOutputTotalName, 1, 1, True, clNone, mghLeft, clBlack, True, 7));
      MotGridSetCell(Data, 5, 1, MotCell(S.IIfStr(VarIsNull(LOutPct), '', MotFmt(LOutPct, '0.00') + '%'), 1, 1, True,
        clNone, mghCenter, clBlack, True, 8));
    end else
    for j := 1 to LDecCnt do begin
      LRow := 5 - LDecCnt + j;
      MotGridSetCell(Data, LRow, 0, MotCell(LCoefDecN[i][LDecIdx[j]], 1, 1, False, clNone, mghLeft, clBlack, True, 7));
      MotGridSetCell(Data, LRow, 1, MotCell(LCoefDecV[i][LDecIdx[j]], 1, 1, True, clNone, mghCenter, clBlack, True, 7));
    end;
    MotGridSetCell(Data, 1, 2, MotCell('Доля вознаграждения', 2, 1, True, cMotHeaderFill, mghCenter));
    MotGridSetCell(Data, 1, 4, MotCell('Оценка', 1, 1, True, cMotHeaderFill, mghCenter));
    LRangeHead := 'Диапазон показателя';
    if LCoefUnit[i] <> '' then LRangeHead := LRangeHead + ', ' + LCoefUnit[i];
    MotGridSetCell(Data, 1, 5, MotCell(LRangeHead, 1, 1, True, cMotHeaderFill, mghCenter));
    MotGridSetCell(Data, 1, 6, MotCell('Коэф-нт премии', 1, 1, True, cMotHeaderFill, mghCenter));
    MotGridSetCell(Data, 1, 7, MotCell('Значение показателя', 1, 1, True, cMotHeaderFill, mghCenter));
    MotGridSetCell(Data, 1, 8, MotCell('Сумма премии', 1, 1, True, cMotHeaderFill, mghCenter));
    MotGridSetCell(Data, 1, 9, MotCell('Комментарий', 1, 1, True, cMotHeaderFill, mghCenter));

    //доля вознаграждения, % и расчётная сумма (вес x премия фактическая часть)
    if VarIsNull(LWeight) then
      MotGridSetCell(Data, 2, 2, MotCell('', 1, 4))
    else
      MotGridSetCell(Data, 2, 2, MotCell(FormatFloat('0.##', Double(LWeight) * 100) + '%', 1, 4, True, clNone, mghCenter, clBlack, True, 16));
    if VarIsNull(LWeight) or VarIsNull(T.Premium) then
      MotGridSetCell(Data, 2, 3, MotCell('-', 1, 4, False, clNone, mghCenter))
    else
      MotGridSetCell(Data, 2, 3, MotCell(FormatFloat('0.##', Double(LWeight) * Double(T.Premium)), 1, 4, False, clNone, mghCenter));

    for j := 0 to naRates.Count - 1 do begin
      LFill := clNone;
      if Integer(naRates.GetValue(j, 'rating')) = LCoefSel[i] then
        LFill := cMotSelectedFill;
      MotGridSetCell(Data, 2 + j, 4, MotCell(VarToStr(naRates.GetValue(j, 'rating_name')), 1, 1, False, LFill));
      //диапазон обязателен - если не задан/некорректен/пересекается, вместо него красным пишем причину
      if (not VarIsNull(naRates.GetValue(j, 'range_state'))) and (naRates.GetValue(j, 'range_state') <> 0) then
        MotGridSetCell(Data, 2 + j, 5, MotCell(
          'диапазон: ' + AnsiLowerCase(VarToStr(naRates.GetValue(j, 'range_state_name'))),
          1, 1, True, LFill, mghCenter, clRed))
      else
        MotGridSetCell(Data, 2 + j, 5, MotCell(
          FormatMotRange(naRates.GetValue(j, 'range_from'), naRates.GetValue(j, 'range_to'), naRates.GetValue(j, 'is_outside_range')),
          1, 1, False, LFill, mghCenter));
      MotGridSetCell(Data, 2 + j, 6, MotCell(MotFmt(naRates.GetValue(j, 'value'), '0.###'), 1, 1, False, LFill, mghCenter));
      //значение показателя - в строке выбранной оценки (как "+" в колонке "Факт" Excel)
      if LFill = cMotSelectedFill then
        MotGridSetCell(Data, 2 + j, 7, MotCell(
          MotFmt(LCoefFact[i], '0.##') + S.IIfStr((LCoefUnit[i] <> '') and (not VarIsNull(LCoefFact[i])), ' ' + LCoefUnit[i], ''),
          1, 1, True, LFill, mghCenter))
      else
        MotGridSetCell(Data, 2 + j, 7, MotCell('', 1, 1, False, LFill));
      MotGridSetCell(Data, 2 + j, 9, MotCell(VarToStr(naRates.GetValue(j, 'comm')), 1, 1, False, LFill));
    end;

    //значение есть, но оценка не определилась - красным в объединённой ячейке (4 строки); значения нет - подсказка
    if LCoefSel[i] = 0 then begin
      if not VarIsNull(LCoefFact[i]) then
        MotGridSetCell(Data, 2, 7, MotCell(
          MotFmt(LCoefFact[i], '0.##') + S.IIfStr(LCoefUnit[i] <> '', ' ' + LCoefUnit[i], '') + #13#10'(оценка не определена)',
          1, 4, True, clNone, mghCenter, clRed))
      else if LPers then begin
        if LByEmp then
          MotGridSetCell(Data, 2, 7, MotCell('двойной щелчок - ввести значение', 1, 4, False, cMotYellowFill, mghCenter, clGray))
        else
          MotGridSetCell(Data, 2, 7, MotCell('личный: по сотруднику', 1, 4, False, clNone, mghCenter, clGray));
      end;
    end;

    //сумма премии по критерию = коэф-нт выбранной оценки x доля x премия - в объединённой ячейке на 4 строки
    if VarIsNull(LSelVal) or VarIsNull(LWeight) or VarIsNull(T.Premium) then
      MotGridSetCell(Data, 2, 8, MotCell('-', 1, 4, False, clNone, mghCenter))
    else begin
      LSumCell := Double(LSelVal) * Double(LWeight) * Double(T.Premium);
      MotGridSetCell(Data, 2, 8, MotCell(FormatFloat('0.##', LSumCell), 1, 4, True, cMotYellowFill, mghCenter, clBlack, True, 10));
    end;

    LBlock := AddBlock(Data, na.GetValue(i, 'id'));
    //личный коэффициент: двойной щелчок по ячейке значения - ввод (только когда выбран сотрудник). "Выработка" вводится
    //часами факта (вид 4): зоной служит и ячейка значения справа, и строка "Фактическая выработка" левой таблицы
    if LPers and LByEmp then begin
      AddHot(LBlock, MotGridCellRect(Data, 2, 7, 4, 1), 1 + 3 * Ord(LIsOutput), Integer(na.GetValue(i, 'id_coefficient')),
        Integer(AIdEmployee));
      if LIsOutput then
        AddHot(LBlock, MotGridCellRect(Data, 4, 0, 1, 2), 4, Integer(na.GetValue(i, 'id_coefficient')), Integer(AIdEmployee));
    end;

    //описания ячеек (двойной щелчок): синяя линия - расчёт, серая - значение из справочника/константа
    LSelName := 'не определена';
    for j := 0 to naRates.Count - 1 do
      if Integer(naRates.GetValue(j, 'rating')) = LCoefSel[i] then LSelName := VarToStr(naRates.GetValue(j, 'rating_name'));
    if VarIsNull(LWeight) then LShareTxt := 'не задана' else LShareTxt := FormatFloat('0.##', Double(LWeight) * 100) + '%';
    if VarIsNull(T.Premium) then LPremTxt := 'не задана' else LPremTxt := FormatFloat('0.##', Double(T.Premium));
    if VarIsNull(LCoefFact[i]) then LValTxt := 'не введено' else
      LValTxt := MotFmt(LCoefFact[i], '0.##') + S.IIfStr(LCoefUnit[i] <> '', ' ' + LCoefUnit[i], '');
    if VarIsNull(LSelVal) then LCoefTxt := 'нет' else LCoefTxt := MotFmt(LSelVal, '0.###');
    if VarIsNull(LWeight) or VarIsNull(T.Premium) then LTotTxt := 'нет данных'
    else LTotTxt := FormatFloat('0.##', Double(LWeight) * Double(T.Premium));

    AddHot(LBlock, MotGridCellRect(Data, 2, 2, 4, 1), 5, 0, 0, MotSrc('Доля вознаграждения, % (' + LShareTxt + ')',
      'Здесь не вводится. Задаётся в журнале «Мотивация - Коэффициенты по должностям» (доля критерия в вознаграждении ' +
      'должности). Сумма долей всех критериев должности должна быть 100%.'));
    AddHot(LBlock, MotGridCellRect(Data, 2, 3, 4, 1), 0, 0, 0, MotInfo('Доля вознаграждения, сумма', 'x = d х P',
      ['x - эта ячейка = ' + LTotTxt,
       'd - «Доля вознаграждения, %» (ячейка слева) = ' + LShareTxt,
       'P - «Премия - расчётная часть» (шапка) = ' + LPremTxt]));
    AddHot(LBlock, MotGridCellRect(Data, 2, 4, 4, 1), 0, 0, 0, MotInfo('Оценка (подсвеченная строка)',
      'оценка = та, в диапазон которой попадает значение показателя v',
      ['v - «Значение показателя» (колонка справа) = ' + LValTxt,
       'диапазоны - колонка «Диапазон показателя» (справочник «Мотивация - Коэффициенты»)',
       'текущая оценка = ' + LSelName],
      'Оценка не вводится и не хранится, а вычисляется при каждой отрисовке. Если значения нет или оно не попало ни в один ' +
      'диапазон - оценка не определена, и коэффициент в итог не входит.'));
    AddHot(LBlock, MotGridCellRect(Data, 2, 5, 4, 1), 5, 0, 0, MotSrc('Диапазон показателя',
      'Здесь не вводится. Диапазоны значений для каждой из 4 оценок задаются в журнале «Мотивация - Коэффициенты» ' +
      '(таблица оценок коэффициента).'));
    AddHot(LBlock, MotGridCellRect(Data, 2, 6, 4, 1), 5, 0, 0, MotSrc('Коэф-нт премии',
      'Здесь не вводится. Задаётся для каждой оценки в журнале «Мотивация - Коэффициенты» (таблица оценок коэффициента).'));
    if not (LPers and LByEmp) then begin
      if LPers then
        AddHot(LBlock, MotGridCellRect(Data, 2, 7, 4, 1), 5, 0, 0, MotSrc('Значение показателя (личный коэффициент)',
          'Значение личного коэффициента вводится по каждому сотруднику: выберите режим «По сотруднику» и сотрудника, ' +
          'затем двойной щелчок по этой ячейке (зелёная линия).'))
      else
        AddHot(LBlock, MotGridCellRect(Data, 2, 7, 4, 1), 5, 0, 0, MotSrc('Значение показателя',
          'Здесь не вводится. Значение (и таблица-расшифровка) вводится в журнале «Мотивация - Коэффициенты» (общее для ' +
          'всех сотрудников должности). Текущее значение: ' + LValTxt));
    end;
    AddHot(LBlock, MotGridCellRect(Data, 2, 8, 4, 1), 0, 0, 0, MotInfo('Сумма премии по критерию', 'x = k х d х P',
      ['x - эта ячейка',
       'k - «Коэф-нт премии» выбранной (подсвеченной) оценки (' + LSelName + ') = ' + LCoefTxt,
       'd - «Доля вознаграждения» (в долях единицы) = ' + LShareTxt,
       'P - «Премия - расчётная часть» (шапка) = ' + LPremTxt],
      'Сумма всех таких ячеек (К1, К2, ...) идёт в итоговую премию («Итоговое вознаграждение», колонка «Премия»).'));
    if LIsOutput then begin
      AddHot(LBlock, MotGridCellRect(Data, 3, 1, 1, 1), 5, 0, 0, MotSrc('Норма времени текущий месяц',
        'Здесь не вводится. Равна плану ТУРВ (рабочих часов в период) из шапки = ' + FormatFloat('0.##', LCalc.Totals.TurvPlan) + ' ч. ' + LCalc.Totals.TurvMsg));
      AddHot(LBlock, MotGridCellRect(Data, 5, 1, 1, 1), 0, 0, 0, MotInfo('Итог выработки, %', 'x = f / n х 100%',
        ['x - эта ячейка',
         'f - «Фактическая выработка», часы (строка выше; вводится двойным щелчком) = ' + MotFmt(LOutHours, '0.##'),
         'n - «Норма времени текущий месяц» (= план ТУРВ) = ' + FormatFloat('0.##', LCalc.Totals.TurvPlan)],
        'Процент сохраняется как «Значение показателя» и определяет оценку по диапазонам.'));
    end;
  end;

  if na.Count = 0 then begin
    MotGridSetSize(Data, [cMotBlockWidth], [26]);
    MotGridSetCell(Data, 0, 0, MotCell('К этой должности не привязано ни одного коэффициента - см. "Мотивация - Коэффициенты по должностям".'));
    AddBlock(Data, -1);
  end;

  //специальные коэффициенты и грубые замечания/ЧС (номера К - продолжение нумерации обычных)
  for LKind := 1 to 2 do
    if LKindNum[LKind] > 0 then
      RenderSpecial(AIdJobInternal, AIdEmployee, LKind, LKindNum[LKind]);
  if LRemarksNum > 0 then
    RenderRemarks(AIdJobInternal, AIdEmployee, LRemarksNum);
end;

procedure TFrmWMotivationTest.RenderRemarks(AIdJobInternal, AIdEmployee: Variant; ANum: Integer);
//блок "Кn - грубые замечания и чрезвычайные ситуации" по образцу Excel (К5/К6): два списка - "Грубые замечания
//(случаи по вине сотрудника)" и "Чрезвычайная ситуация (случаи по вине сотрудника)" - формулировки из списков
//должности (журналы "...по должностям", по pos), справа объединённые ячейки "Коэф-нт" и "Факт". Коэф-нт за случай
//не нужен (прочерк), "Факт" - итоговый множитель, выставляется ВРУЧНУЮ по сотруднику (двойной щелчок в режиме
//"По сотруднику"; w_motivation_remark_facts, нет значения - 1).
var
  Data: TMotGridData;
  naRem, naEm, naF: TNamedArr;
  LHeights: array of Integer;
  i, r, LTotal, LBlock: Integer;
  LFactRem, LFactEm: Variant;
  LByEmp: Boolean;
  LZones: TMotHotZoneArr;

  function RowH(const AText: string): Integer;
  begin
    Result := Max(24, 14 * (Length(AText) div 100 + 1) + 8);
  end;

  procedure FillList(const ACaption: string; var ANa: TNamedArr; AListKind: Integer; const AFact: Variant);
  var
    k, LFirst: Integer;
    LTxt: string;
  begin
    if ANa.Count = 0 then Exit;
    MotGridSetCell(Data, r, 0, MotCell(ACaption, 7, 1, True, cMotHeaderFill));
    MotGridSetCell(Data, r, 7, MotCell('Коэф-нт', 2, 1, True, cMotHeaderFill, mghCenter));
    MotGridSetCell(Data, r, 9, MotCell('Факт', 1, 1, True, cMotHeaderFill, mghCenter));
    Inc(r);
    LFirst := r;
    for k := 0 to ANa.Count - 1 do begin
      MotGridSetCell(Data, r, 0, MotCell('- ' + VarToStr(ANa.GetValue(k, 'name')), 7, 1));
      Inc(r);
    end;
    if VarIsNull(AFact) then LTxt := '1' else LTxt := MotFmt(AFact, '0.###');
    MotGridSetCell(Data, LFirst, 7, MotCell('-', 2, ANa.Count, False, clNone, mghCenter));
    MotGridSetCell(Data, LFirst, 9, MotCell(LTxt, 1, ANa.Count, True, cMotYellowFill, mghCenter, clBlack, True, 10));
    if LByEmp then begin
      SetLength(LZones, Length(LZones) + 1);
      LZones[High(LZones)].R := MotGridCellRect(Data, LFirst, 9, ANa.Count, 1);
      LZones[High(LZones)].Kind := 3;
      LZones[High(LZones)].Id1 := Integer(AIdEmployee);
      LZones[High(LZones)].Id2 := AListKind;
    end;
  end;

begin
  LByEmp := not VarIsNull(AIdEmployee);
  Q.QLoad('select name from v_w_motivation_negative_remarks_for_job where id_job_internal = :ij$i order by pos, id',
    [AIdJobInternal], naRem);
  Q.QLoad('select name from v_w_motivation_w_work_emergencies_for_job where id_job_internal = :ij$i order by pos, id',
    [AIdJobInternal], naEm);
  if (naRem.Count = 0) and (naEm.Count = 0) then Exit;
  LFactRem := Null;
  LFactEm := Null;
  if LByEmp then begin
    Q.QLoad('select kind, value from w_motivation_remark_facts where id_employee = :ie$i', [AIdEmployee], naF);
    for i := 0 to naF.Count - 1 do begin
      if Integer(naF.GetValue(i, 'kind')) = 1 then LFactRem := naF.GetValue(i, 'value');
      if Integer(naF.GetValue(i, 'kind')) = 2 then LFactEm := naF.GetValue(i, 'value');
    end;
  end;

  LTotal := 1;
  if naRem.Count > 0 then LTotal := LTotal + 1 + naRem.Count;
  if naEm.Count > 0 then LTotal := LTotal + 1 + naEm.Count;
  SetLength(LHeights, LTotal);
  LHeights[0] := 32;
  r := 1;
  if naRem.Count > 0 then begin
    LHeights[r] := 26;
    Inc(r);
    for i := 0 to naRem.Count - 1 do begin
      LHeights[r] := RowH(VarToStr(naRem.GetValue(i, 'name')));
      Inc(r);
    end;
  end;
  if naEm.Count > 0 then begin
    LHeights[r] := 26;
    Inc(r);
    for i := 0 to naEm.Count - 1 do begin
      LHeights[r] := RowH(VarToStr(naEm.GetValue(i, 'name')));
      Inc(r);
    end;
  end;

  MotGridSetSize(Data, [130, 85, 65, 85, 115, 145, 75, 95, 95, 145], LHeights);
  MotGridSetCell(Data, 0, 0, MotCell('К' + IntToStr(ANum) + ' - грубые замечания и чрезвычайные ситуации', 10, 1, True, cMotTitleFill));
  r := 1;
  FillList('Грубые замечания (случаи по вине сотрудника)', naRem, 1, LFactRem);
  FillList('Чрезвычайная ситуация (случаи по вине сотрудника)', naEm, 2, LFactEm);
  LBlock := AddBlock(Data, -1);
  for i := 0 to High(LZones) do
    AddHot(LBlock, LZones[i].R, LZones[i].Kind, LZones[i].Id1, LZones[i].Id2, LZones[i].Info);
end;

procedure TFrmWMotivationTest.RenderSpecial(AIdJobInternal, AIdEmployee: Variant; AKind, ANum: Integer);
//блок специального коэффициента (AKind: 1 - культура производства, 2 - качество работы по специальности):
//позиции должности с весом, признаком личная/по отделу и оценкой показателя (вводится двойным щелчком по ячейке:
//личная позиция - по выбранному сотруднику, позиция по отделу - по специальности, в т.ч. в режиме "По должности"),
//баллами, итог и вычисляемая оценка (если выбран сотрудник), затем таблица диапазонов итоговых баллов с
//множителями. Нет позиций - блока нет. Данные: v_w_motivation_special_items / v_w_motivation_spec_emp_items /
//w_motivation_special_values / v_w_motivation_spec_rates / v_w_motivation_spec_grades (SQL/d_motivation.sql)
var
  Data: TMotGridData;
  naItems, naRates, naGrade: TNamedArr;
  i, N, LRow, LBlock: Integer;
  LHeights: array of Integer;
  LKindName, LRangeText: string;
  LSelRating: Variant;
  LByEmp, LShowVal, LPers: Boolean;
  LFill: TColor;
  LWeightsSum: Double;
  LZones: TMotHotZoneArr;
  LTotRow: Integer;
  LPtsTxt, LMulTxt: string;
begin
  LByEmp := not VarIsNull(AIdEmployee);
  LKindName := S.IIfStr(AKind = 1, 'Культура производства', 'Качество работы по специальности');
  if LByEmp then
    Q.QLoad('select id, name, weight, scope_name, is_personal, value, points from v_w_motivation_spec_emp_items ' +
      'where id_employee = :ie$i and id_job_internal = :ij$i and kind = :k$i order by pos, id',
      [AIdEmployee, AIdJobInternal, AKind], naItems)
  else
    //в режиме "По должности" известны только оценки по отделу (id_employee = 0)
    Q.QLoad('select i.id, i.name, i.weight, decode(i.is_personal, 1, ''Личный'', ''По отделу'') scope_name, i.is_personal, ' +
      'v.value, v.value * i.weight points ' +
      'from w_motivation_special_items i, w_motivation_special_values v ' +
      'where i.id_job_internal = :ij$i and i.kind = :k$i and v.id_item (+) = i.id and v.id_employee (+) = 0 ' +
      'order by i.pos, i.id',
      [AIdJobInternal, AKind], naItems);
  if naItems.Count = 0 then Exit;
  Q.QLoad('select rating, rating_name, value, range_from, range_to, is_outside_range, comm, range_state, range_state_name ' +
    'from v_w_motivation_spec_rates where id_job_internal = :ij$i and kind = :k$i order by rating',
    [AIdJobInternal, AKind], naRates);
  LSelRating := Null;
  if LByEmp then begin
    Q.QLoad('select total_points, selected_rating, state_name from v_w_motivation_spec_grades ' +
      'where id_employee = :ie$i and kind = :k$i', [AIdEmployee, AKind], naGrade);
    if naGrade.Count > 0 then LSelRating := naGrade.GetValue(0, 'selected_rating');
  end;

  N := naItems.Count;
  //строки: заголовок, шапка, N позиций, итог, шапка диапазонов, диапазоны
  SetLength(LHeights, 4 + N + naRates.Count);
  LHeights[0] := 32;
  for i := 1 to High(LHeights) do LHeights[i] := 28;
  MotGridSetSize(Data, [440, 90, 130, 200, 175], LHeights);
  MotGridSetCell(Data, 0, 0, MotCell('К' + IntToStr(ANum) + ' - ' + LKindName + ' (множитель к премии, без доли вознаграждения)', 5, 1, True, cMotTitleFill));
  MotGridSetCell(Data, 1, 0, MotCell('Позиция', 1, 1, True, cMotHeaderFill, mghCenter));
  MotGridSetCell(Data, 1, 1, MotCell('Вес', 1, 1, True, cMotHeaderFill, mghCenter));
  MotGridSetCell(Data, 1, 2, MotCell('Оценка', 1, 1, True, cMotHeaderFill, mghCenter));
  MotGridSetCell(Data, 1, 3, MotCell('Оценка показателя', 1, 1, True, cMotHeaderFill, mghCenter));
  MotGridSetCell(Data, 1, 4, MotCell('Баллы', 1, 1, True, cMotHeaderFill, mghCenter));

  LWeightsSum := 0;
  for i := 0 to N - 1 do begin
    LPers := naItems.GetValue(i, 'is_personal') = 1;
    //значение показывается и вводится: по сотруднику - для любых позиций, без сотрудника - только для позиций по отделу
    LShowVal := LByEmp or (not LPers);
    MotGridSetCell(Data, 2 + i, 0, MotCell(VarToStr(naItems.GetValue(i, 'name'))));
    MotGridSetCell(Data, 2 + i, 1, MotCell(FormatFloat('0.##', S.NNum(naItems.GetValue(i, 'weight'))), 1, 1, False, clNone, mghCenter));
    MotGridSetCell(Data, 2 + i, 2, MotCell(VarToStr(naItems.GetValue(i, 'scope_name')), 1, 1, False, clNone, mghCenter));
    LWeightsSum := LWeightsSum + S.NNum(naItems.GetValue(i, 'weight'));
    if LShowVal then begin
      if VarIsNull(naItems.GetValue(i, 'value')) then begin
        MotGridSetCell(Data, 2 + i, 3, MotCell('не введена (двойной щелчок)', 1, 1, False, cMotYellowFill, mghCenter, clGray));
        MotGridSetCell(Data, 2 + i, 4, MotCell('', 1, 1, False, cMotYellowFill));
      end else begin
        MotGridSetCell(Data, 2 + i, 3, MotCell(MotFmt(naItems.GetValue(i, 'value'), '0.##'), 1, 1, True, clNone, mghCenter));
        MotGridSetCell(Data, 2 + i, 4, MotCell(MotFmt(naItems.GetValue(i, 'points'), '0.##'), 1, 1, False, clNone, mghCenter));
        MotAddZone(LZones, Data, 2 + i, 4, 1, 1, 0, MotInfo('Баллы по позиции «' + VarToStr(naItems.GetValue(i, 'name')) + '»',
          'x = v х w',
          ['x - эта ячейка = ' + MotNum(naItems.GetValue(i, 'points')),
           'v - «Оценка показателя» (ячейка слева) = ' + MotNum(naItems.GetValue(i, 'value')),
           'w - «Вес» позиции (колонка «Вес», вес задаётся в журнале специальных коэффициентов) = ' + MotNum(naItems.GetValue(i, 'weight'))]));
      end;
      SetLength(LZones, Length(LZones) + 1);
      LZones[High(LZones)].R := MotGridCellRect(Data, 2 + i, 3, 1, 1);
      LZones[High(LZones)].Kind := 2;
      LZones[High(LZones)].Id1 := Integer(naItems.GetValue(i, 'id'));
      if LByEmp then LZones[High(LZones)].Id2 := Integer(AIdEmployee) else LZones[High(LZones)].Id2 := 0;
    end else begin
      MotGridSetCell(Data, 2 + i, 3, MotCell('по сотруднику', 1, 1, False, clNone, mghCenter, clGray));
      MotGridSetCell(Data, 2 + i, 4, MotCell(''));
    end;
  end;

  //итог
  LRow := 2 + N;
  LTotRow := LRow;
  MotGridSetCell(Data, LRow, 0, MotCell('Итого', 1, 1, True, cMotHeaderFill));
  MotGridSetCell(Data, LRow, 1, MotCell(FormatFloat('0.##', LWeightsSum), 1, 1, True, cMotHeaderFill, mghCenter));
  if LByEmp and (naGrade.Count > 0) then begin
    MotGridSetCell(Data, LRow, 2, MotCell(VarToStr(naGrade.GetValue(0, 'state_name')), 2, 1, True, cMotHeaderFill, mghCenter));
    MotGridSetCell(Data, LRow, 4, MotCell(FormatFloat('0.##', S.NNum(naGrade.GetValue(0, 'total_points'))), 1, 1, True, cMotHeaderFill, mghCenter));
  end else
    MotGridSetCell(Data, LRow, 2, MotCell('', 3, 1, True, cMotHeaderFill));

  //диапазоны итоговых баллов
  Inc(LRow);
  MotGridSetCell(Data, LRow, 0, MotCell('Оценка', 1, 1, True, cMotHeaderFill, mghCenter));
  MotGridSetCell(Data, LRow, 1, MotCell('Диапазон итога баллов', 2, 1, True, cMotHeaderFill, mghCenter));
  MotGridSetCell(Data, LRow, 3, MotCell('Множитель к премии', 1, 1, True, cMotHeaderFill, mghCenter));
  MotGridSetCell(Data, LRow, 4, MotCell('Комментарий', 1, 1, True, cMotHeaderFill, mghCenter));
  for i := 0 to naRates.Count - 1 do begin
    Inc(LRow);
    LFill := clNone;
    if (not VarIsNull(LSelRating)) and (naRates.GetValue(i, 'rating') = LSelRating) then
      LFill := cMotSelectedFill;
    MotGridSetCell(Data, LRow, 0, MotCell(VarToStr(naRates.GetValue(i, 'rating_name')), 1, 1, False, LFill));
    //диапазон обязателен - если не задан/некорректен/пересекается, красным пишем причину
    if (not VarIsNull(naRates.GetValue(i, 'range_state'))) and (naRates.GetValue(i, 'range_state') <> 0) then
      MotGridSetCell(Data, LRow, 1, MotCell(
        'диапазон: ' + AnsiLowerCase(VarToStr(naRates.GetValue(i, 'range_state_name'))), 2, 1, True, LFill, mghCenter, clRed))
    else begin
      LRangeText := FormatMotRange(naRates.GetValue(i, 'range_from'), naRates.GetValue(i, 'range_to'), naRates.GetValue(i, 'is_outside_range'));
      MotGridSetCell(Data, LRow, 1, MotCell(LRangeText, 2, 1, False, LFill, mghCenter));
    end;
    MotGridSetCell(Data, LRow, 3, MotCell(MotFmt(naRates.GetValue(i, 'value'), '0.###'), 1, 1, False, LFill, mghCenter));
    MotGridSetCell(Data, LRow, 4, MotCell(VarToStr(naRates.GetValue(i, 'comm')), 1, 1, False, LFill));
  end;
  //описания итоговых ячеек (если выбран сотрудник и есть итог)
  if LByEmp and (naGrade.Count > 0) then begin
    LPtsTxt := MotNum(naGrade.GetValue(0, 'total_points'));
    LMulTxt := 'нет';
    for i := 0 to naRates.Count - 1 do
      if (not VarIsNull(LSelRating)) and (naRates.GetValue(i, 'rating') = LSelRating) then
        LMulTxt := MotNum(naRates.GetValue(i, 'value'));
    MotAddZone(LZones, Data, LTotRow, 4, 1, 1, 0, MotInfo('Итого баллов', 'x = сумма (v х w) по позициям',
      ['x - эта ячейка = ' + LPtsTxt,
       'v - «Оценка показателя» каждой позиции, w - её «Вес» (колонка «Баллы» = v х w)'],
      'Баллы считаются, только если оценки введены по всем позициям.'));
    MotAddZone(LZones, Data, LTotRow, 2, 1, 2, 0, MotInfo('Итоговая оценка (' + LKindName + ')',
      'оценка = та, в диапазон «Диапазон итога баллов» которой попадает x',
      ['x - «Итого» баллов (ячейка справа) = ' + LPtsTxt,
       'таблица диапазонов - ниже в этом блоке (подсвечена полученная оценка)',
       'множитель к премии полученной оценки = ' + LMulTxt],
      'Этот множитель входит в итоговую премию (шапка, «Итоговое вознаграждение»): премия = сумма по критериям х множители ...'));
  end;
  LBlock := AddBlock(Data, -1);
  for i := 0 to High(LZones) do
    AddHot(LBlock, LZones[i].R, LZones[i].Kind, LZones[i].Id1, LZones[i].Id2, LZones[i].Info);
end;

procedure TFrmWMotivationTest.AddHot(ABlock: Integer; const ARect: TRect; AKind, AId1, AId2: Integer; const AInfo: string = '');
//"горячая зона" блока (прямоугольник в координатах блока) - по двойному щелчку внутри неё открывается ввод:
//AKind = 1 - значение личного коэффициента (Id1 - айди коэффициента, Id2 - айди сотрудника),
//AKind = 2 - оценка показателя позиции специального коэффициента (Id1 - айди позиции, Id2 - айди сотрудника или 0
//для позиции по отделу), AKind = 3 - множитель замечаний (Id2 = 1) / ЧС (Id2 = 2) сотрудника (Id1 - айди сотрудника),
//AKind = 4 - фактическая выработка (часы) сотрудника по коэффициенту "Выработка" (Id1 - айди коэффициента, Id2 - сотрудника),
//AKind = 0 - расчётная ячейка и AKind = 5 - ячейка со значением из справочника/константой: по двойному щелчку показывается
//описание AInfo (как считается / откуда берётся). Цвет линии под ячейкой - см. PaintBoxPaint
var
  n: Integer;
begin
  if (ABlock < 0) or (ABlock > High(FBlockHot)) then Exit;
  n := Length(FBlockHot[ABlock]);
  SetLength(FBlockHot[ABlock], n + 1);
  FBlockHot[ABlock][n].R := ARect;
  FBlockHot[ABlock][n].Kind := AKind;
  FBlockHot[ABlock][n].Id1 := AId1;
  FBlockHot[ABlock][n].Id2 := AId2;
  FBlockHot[ABlock][n].Info := AInfo;
end;

procedure TFrmWMotivationTest.PaintBoxDblClick(Sender: TObject);
//двойной щелчок по ячейке значения - ввод (см. AddHot). Права на ввод пока не ограничиваются (экран разработчика);
//позже - проверка "пользователь вправе вводить значения личных коэффициентов/показателей по отделу для должности"
var
  PB: TPaintBox;
  P: TPoint;
  i: Integer;
  Z: TMotHotZone;
begin
  PB := TPaintBox(Sender);
  if (PB.Tag < 0) or (PB.Tag > High(FBlockHot)) then Exit;
  P := PB.ScreenToClient(Mouse.CursorPos);
  for i := 0 to High(FBlockHot[PB.Tag]) do
    if PtInRect(FBlockHot[PB.Tag][i].R, P) then begin
      Z := FBlockHot[PB.Tag][i];
      //ввод запускается отложенно: после него экран перестраивается (paintbox'ы пересоздаются), а удалять
      //компонент внутри его же обработчика события нельзя
      TThread.ForceQueue(nil,
        procedure
        begin
          HandleHotZone(Z);
        end);
      Exit;
    end;
end;

procedure TFrmWMotivationTest.HandleHotZone(const Z: TMotHotZone);
var
  LDone: Boolean;
  LPos: Integer;
  LDt: string;
begin
  //ввод значений при установленной блокировке запрещён (в БД то же делают триггеры - ORA-20010)
  if Z.Kind in [1, 2, 3, 4, 6] then begin
    FState := MotLoadState;
    if FState.IsLocked then begin
      RefreshStateUI;
      LDt := '';
      if not VarIsNull(FState.LockDt) then LDt := ', ' + FormatDateTime('dd.mm.yyyy hh:nn', VarToDateTime(FState.LockDt));
      MyInfoMessage('Данные мотивации заблокированы от изменений (' + FState.LockUser + LDt + ').'#13#10 +
        'Чтобы изменить значение, нужно снять блокировку (право на снятие блокировки).');
      Exit;
    end;
  end;
  case Z.Kind of
    0, 5:
      begin
        ShowMotInfo(Z.Info, Z.Kind);
        LDone := False;
      end;
    1: LDone := DoEditPersonalCoef(Z.Id1, Z.Id2);
    2: LDone := DoEditSpecValue(Z.Id1, Z.Id2);
    3: LDone := DoEditRemarkFact(Z.Id1, Z.Id2);
    4: LDone := DoEditOutput(Z.Id1, Z.Id2);
    6: LDone := DoEditFormula(GetSelectedJobId);
  else
    LDone := False;
  end;
  if not LDone then Exit;
  RefreshStateUI;
  LPos := sbxClient.VertScrollBar.Position;
  DoRender;
  sbxClient.VertScrollBar.Position := LPos;
end;

function TFrmWMotivationTest.DoEditPersonalCoef(AIdCoef, AIdEmployee: Integer): Boolean;
//ввод значения ЛИЧНОГО коэффициента по сотруднику и таблицы-расшифровки (3 строки, до 150 символов); оценка не
//вводится - вычисляется по диапазонам (v_w_motivation_emp_rates). Пустое значение и пустая расшифровка - удаляют запись.
var
  va: TVarDynArray;
  vc, vr: Variant;
  LUnit, LEmp: string;
  LVal: Variant;
begin
  Result := False;
  //QLoadRow: массив по числу полей, при отсутствии записи все элементы Null (QLoadRow0 в этом случае падает)
  vc := Q.QLoadRow('select name, unit_name from w_motivation_coefficients where id = :id$i', [AIdCoef]);
  if VarIsNull(vc[0]) then begin
    MsgRecordIsDeleted;
    Exit;
  end;
  LUnit := VarToStr(vc[1]);
  LEmp := VarToStr(Q.QLoadValue('select name from v_w_motivation_employees_by_job where id = :id$i', [AIdEmployee]));
  //значения у сотрудника может ещё не быть - тогда все поля Null, и диалог открывается пустым
  vr := Q.QLoadRow('select fact_value, decode_name1, decode_value1, decode_name2, decode_value2, decode_name3, decode_value3 ' +
    'from w_motivation_employee_values where id_coefficient = :ic$i and id_employee = :ie$i', [AIdCoef, AIdEmployee]);
  if TFrmBasicInput.ShowDialog(Self, '', [], fEdit,
       '~' + VarToStr(vc[0]) + ': ' + LEmp, 560, 120,
       [[cntNEdit, 'Значение'#13#10'показателя' + S.IIfStr(LUnit <> '', ', ' + LUnit, ''), '0:999999:2:N'],
        [],
        [cntEdit, 'Расшифровка'#13#10'значения', '0:150::N', 250],
        [cntEdit, '', '0:150::N', 150, 378],
        [cntEdit, '', '0:150::N', 250],
        [cntEdit, '', '0:150::N', 150, 378],
        [cntEdit, '', '0:150::N', 250],
        [cntEdit, '', '0:150::N', 150, 378]],
       [vr[0], VarToStr(vr[1]), VarToStr(vr[2]), VarToStr(vr[3]), VarToStr(vr[4]), VarToStr(vr[5]), VarToStr(vr[6])],
       va,
       [['Значение личного коэффициента сотрудника: ' + LEmp + '.'#13#10 +
         'Оценка не вводится - она определяется автоматически по диапазонам значений. Таблица-расшифровка'#13#10 +
         '(до 3 строк, название и значение, до 150 символов) выводится в блоке коэффициента под описанием;'#13#10 +
         'пустые строки не выводятся. Если очистить значение и расшифровку, запись удаляется.']],
       nil
  ) < 0 then Exit;
  if VarToStr(va[0]) = '' then LVal := Null else LVal := S.NNum(va[0]);
  Q.QCallStoredProc('p_w_motivation_emp_coeff_set_value',
    'p_id_coefficient$i;p_id_employee$i;p_user_id$i;p_fact_value$f;p_decode_name1$s;p_decode_value1$s;' +
    'p_decode_name2$s;p_decode_value2$s;p_decode_name3$s;p_decode_value3$s',
    [AIdCoef, AIdEmployee, User.GetId, LVal, VarToStr(va[1]), VarToStr(va[2]), VarToStr(va[3]), VarToStr(va[4]),
     VarToStr(va[5]), VarToStr(va[6])]);
  Result := True;
end;

function TFrmWMotivationTest.DoEditSpecValue(AIdItem, AIdEmployee: Integer): Boolean;
//ввод оценки показателя по позиции специального коэффициента: личная позиция - по сотруднику (AIdEmployee), позиция
//по отделу - по специальности (AIdEmployee не важен, хранится с id_employee = 0). Пустое значение удаляет оценку.
var
  va: TVarDynArray;
  vi, vr: Variant;
  LVal: Variant;
  LEmpId: Integer;
  LInfo: string;
begin
  Result := False;
  vi := Q.QLoadRow('select name, weight, is_personal from w_motivation_special_items where id = :id$i', [AIdItem]);
  if VarIsNull(vi[0]) then begin
    MsgRecordIsDeleted;
    Exit;
  end;
  if S.NNum(vi[2]) = 1 then begin
    LEmpId := AIdEmployee;
    LInfo := 'Личная позиция: оценка относится к сотруднику ' +
      VarToStr(Q.QLoadValue('select name from v_w_motivation_employees_by_job where id = :id$i', [AIdEmployee])) + '.';
  end else begin
    LEmpId := 0;
    LInfo := 'Позиция по отделу: оценка относится к специальности и действует для всех её сотрудников.';
  end;
  vr := Q.QLoadRow('select value, comm from w_motivation_special_values where id_item = :ii$i and id_employee = :ie$i',
    [AIdItem, LEmpId]);
  if TFrmBasicInput.ShowDialog(Self, '', [], fEdit,
       '~' + VarToStr(vi[0]), 520, 110,
       [[cntNEdit, 'Оценка показателя', '0:999999:2:N'],
        [cntEdit, 'Комментарий', '0:400::T']],
       [vr[0], VarToStr(vr[1])],
       va,
       [[LInfo + #13#10'Вес позиции: ' + FormatFloat('0.##', S.NNum(vi[1])) + '. Пустое значение удаляет оценку.']],
       nil
     ) < 0 then Exit;
  if VarToStr(va[0]) = '' then LVal := Null else LVal := S.NNum(va[0]);
  Q.QCallStoredProc('p_w_motivation_special_set_value',
    'p_id_item$i;p_id_employee$i;p_user_id$i;p_value$f;p_comm$s',
    [AIdItem, LEmpId, User.GetId, LVal, VarToStr(va[1])]);
  Result := True;
end;

type
  //окно редактирования формулы ВЗ должности (создаётся в коде, без dfm); проверка формулы - на каждое изменение текста
  TMotFormulaDlg = class(TForm)
  public
    memF: TMemo;
    lblState: TLabel;
    btnOk: TButton;
    Vars: TMotVars;
    Names: TMotNames;
    DefaultText: string;
    procedure FormulaChange(Sender: TObject);
    procedure DefaultClick(Sender: TObject);
  end;

procedure TMotFormulaDlg.FormulaChange(Sender: TObject);
var
  LText, LMsg, LHead: string;
  LSev: Integer;
  LVal: Double;
begin
  LText := Trim(memF.Text);
  LHead := '';
  if LText = '' then begin
    LText := DefaultText;
    LHead := 'Формула не задана - будет использоваться стандартная: ' + DefaultText + #13#10;
  end;
  if LText = '' then begin
    lblState.Font.Color := clGray;
    lblState.Caption := 'У должности нет коэффициентов - считать нечего.';
    btnOk.Enabled := True;
    Exit;
  end;
  LSev := MotFormulaCheck(LText, Vars, Names, LVal, LMsg);
  case LSev of
    2: lblState.Font.Color := clRed;
    1: lblState.Font.Color := $000066CC;
  else
    lblState.Font.Color := clGreen;
  end;
  if LSev < 2 then begin
    if LMsg <> '' then LMsg := LMsg + #13#10;
    LMsg := LMsg + 'Результат (премия по формуле) при текущих данных: ' + FormatFloat('#,##0.00', LVal) +
      ' (в режиме «По должности» множители специальных коэффициентов и замечаний равны 1).';
  end;
  lblState.Caption := LHead + LMsg;
  btnOk.Enabled := LSev < 2;
end;

procedure TMotFormulaDlg.DefaultClick(Sender: TObject);
begin
  memF.Text := DefaultText;
end;

function TFrmWMotivationTest.DoEditFormula(AIdJob: Variant): Boolean;
//ввод формулы вознаграждения (ВЗ) для внутренней должности (хранится в w_motivation_job_formulas); пустой текст или
//текст, совпадающий со стандартной формулой, - запись удаляется (формула снова стандартная и сама следует за составом
//коэффициентов). Сохранить можно формулу без ошибок (с предупреждением о неиспользуемых коэффициентах - можно)
var
  Dlg: TMotFormulaDlg;
  lbl: TLabel;
  memMap: TMemo;
  btnDefault, btnCancel: TButton;
  LText: string;
begin
  Result := False;
  if VarIsNull(AIdJob) then Exit;
  Dlg := TMotFormulaDlg.CreateNew(Self);
  try
    Dlg.Caption := 'Формула вознаграждения (ВЗ): ' + FPrintJobName;
    Dlg.BorderStyle := bsDialog;
    Dlg.Position := poOwnerFormCenter;
    Dlg.ClientWidth := 740;
    Dlg.ClientHeight := 520;
    Dlg.Vars := FFormulaVars;
    Dlg.Names := FFormulaNames;
    Dlg.DefaultText := FFormulaDefault;

    lbl := TLabel.Create(Dlg);
    lbl.Parent := Dlg;
    lbl.SetBounds(10, 8, 720, 16);
    lbl.Caption := 'Коэффициенты (номера К - в порядке следования блоков в таблице) и их текущие значения:';

    memMap := TMemo.Create(Dlg);
    memMap.Parent := Dlg;
    memMap.SetBounds(10, 28, 720, 200);
    memMap.ReadOnly := True;
    memMap.ScrollBars := ssVertical;
    memMap.Text := FFormulaMap;

    lbl := TLabel.Create(Dlg);
    lbl.Parent := Dlg;
    lbl.SetBounds(10, 236, 720, 16);
    lbl.Caption := 'Формула (числа, К1, К2, ..., знаки + - * / (х и × тоже умножение), скобки):';

    Dlg.memF := TMemo.Create(Dlg);
    Dlg.memF.Parent := Dlg;
    Dlg.memF.SetBounds(10, 256, 720, 64);
    Dlg.memF.ScrollBars := ssVertical;
    Dlg.memF.Font.Size := 11;
    Dlg.memF.Text := S.IIfStr(FFormulaStored <> '', FFormulaStored, FFormulaDefault);

    Dlg.lblState := TLabel.Create(Dlg);
    Dlg.lblState.Parent := Dlg;
    Dlg.lblState.SetBounds(10, 328, 720, 140);
    Dlg.lblState.AutoSize := False;
    Dlg.lblState.WordWrap := True;

    btnDefault := TButton.Create(Dlg);
    btnDefault.Parent := Dlg;
    btnDefault.SetBounds(10, 484, 170, 28);
    btnDefault.Caption := 'Стандартная формула';
    btnDefault.OnClick := Dlg.DefaultClick;

    Dlg.btnOk := TButton.Create(Dlg);
    Dlg.btnOk.Parent := Dlg;
    Dlg.btnOk.SetBounds(540, 484, 90, 28);
    Dlg.btnOk.Caption := 'Сохранить';
    Dlg.btnOk.ModalResult := mrOk;
    Dlg.btnOk.Default := True;

    btnCancel := TButton.Create(Dlg);
    btnCancel.Parent := Dlg;
    btnCancel.SetBounds(640, 484, 90, 28);
    btnCancel.Caption := 'Отмена';
    btnCancel.ModalResult := mrCancel;
    btnCancel.Cancel := True;

    Dlg.memF.OnChange := Dlg.FormulaChange;
    Dlg.FormulaChange(nil);

    if Dlg.ShowModal <> mrOk then Exit;
    LText := Trim(Dlg.memF.Text);
    if (LText = '') or (MotFormulaNormalize(LText) = MotFormulaNormalize(FFormulaDefault)) then
      LText := '';
    Q.QCallStoredProc('p_w_motivation_job_formula_set',
      'p_id_job_internal$i;p_user_id$i;p_k_count$i;p_formula$s',
      [AIdJob, User.GetId, Length(FFormulaVars), LText]);
    Result := True;
  finally
    Dlg.Free;
  end;
end;

function TFrmWMotivationTest.DoEditRemarkFact(AIdEmployee, AListKind: Integer): Boolean;
//ввод итогового множителя ("Факт") замечаний (AListKind = 1) или ЧС (AListKind = 2) сотрудника - выставляется вручную;
//пустое значение - множитель снова 1
var
  va: TVarDynArray;
  vr: Variant;
  LVal: Variant;
  LCaption: string;
begin
  Result := False;
  LCaption := S.IIfStr(AListKind = 1, 'Грубые замечания', 'Чрезвычайные ситуации');
  vr := Q.QLoadRow('select value, comm from w_motivation_remark_facts where id_employee = :ie$i and kind = :k$i',
    [AIdEmployee, AListKind]);
  if TFrmBasicInput.ShowDialog(Self, '', [], fEdit,
       '~' + LCaption + ': ' + VarToStr(Q.QLoadValue('select name from v_w_motivation_employees_by_job where id = :id$i', [AIdEmployee])),
       520, 110,
       [[cntNEdit, 'Итоговый '#13#10'множитель (факт)', '0:10:3:N'],
        [cntEdit, 'Комментарий', '0:400::T']],
       [vr[0], VarToStr(vr[1])],
       va,
       [['Итоговый множитель выставляется вручную (например, от 0,99 до 0,8 за каждый случай).'#13#10 +
         'Пустое значение - множитель 1 (случаев нет).']],
       nil
     ) < 0 then Exit;
  if VarToStr(va[0]) = '' then LVal := Null else LVal := S.NNum(va[0]);
  Q.QCallStoredProc('p_w_motivation_remark_fact_set',
    'p_id_employee$i;p_kind$i;p_user_id$i;p_value$f;p_comm$s',
    [AIdEmployee, AListKind, User.GetId, LVal, VarToStr(va[1])]);
  Result := True;
end;

function TFrmWMotivationTest.DoEditOutput(AIdCoef, AIdEmployee: Integer): Boolean;
//ввод фактической выработки (часы) сотрудника по коэффициенту "Выработка". Норма времени = план ТУРВ сотрудника (MotTurvPlanFor),
//итог (процент) = факт / норма x 100 вычисляется. Хранение - как у личного коэффициента: процент в fact_value (по нему
//вычисляется оценка по диапазонам), в таблице-расшифровке 3 строки: норма / факт (часы) / итог. Пустое значение удаляет запись.
var
  va: TVarDynArray;
  vr: Variant;
  LHours, LPct: Variant;
  LEmp: string;
  LH, LPlan: Double;
begin
  Result := False;
  //норма времени = план ТУРВ сотрудника за период (норма по графику); нет данных ТУРВ - ввод невозможен
  LPlan := MotTurvPlanFor(AIdEmployee);
  if LPlan <= 0 then begin
    MyWarningMessage('Нет плана ТУРВ сотрудника за прошлый месяц (нет данных ТУРВ или не утверждён график) - выработку (факт / норма) вычислить нельзя.');
    Exit;
  end;
  vr := Q.QLoadRow('select decode_value2, id from w_motivation_employee_values where id_coefficient = :ic$i and id_employee = :ie$i',
    [AIdCoef, AIdEmployee]);
  LHours := MotParseNum(VarToStr(vr[0]));
  LEmp := VarToStr(Q.QLoadValue('select name from v_w_motivation_employees_by_job where id = :id$i', [AIdEmployee]));
  if TFrmBasicInput.ShowDialog(Self, '', [], fEdit,
       '~Выработка: ' + LEmp, 460, 90,
       [[cntNEdit, cMotOutputFactName + ', ч', '0:99999:2:N']],
       [LHours],
       va,
       [['Норма времени: ' + FormatFloat('0.##', LPlan) + ' ч (план ТУРВ сотрудника). Итог = факт / норма.'#13#10 +
         'Переработки не учитываются. Пустое значение удаляет введённую выработку.']],
       nil
     ) < 0 then Exit;
  if VarToStr(va[0]) = '' then begin
    Q.QCallStoredProc('p_w_motivation_emp_coeff_set_value',
      'p_id_coefficient$i;p_id_employee$i;p_user_id$i;p_fact_value$f;p_decode_name1$s;p_decode_value1$s;' +
      'p_decode_name2$s;p_decode_value2$s;p_decode_name3$s;p_decode_value3$s',
      [AIdCoef, AIdEmployee, User.GetId, Null, '', '', '', '', '', '']);
    Result := True;
    Exit;
  end;
  LH := S.NNum(va[0]);
  LPct := Round(LH / LPlan * 100 * 10000) / 10000;
  Q.QCallStoredProc('p_w_motivation_emp_coeff_set_value',
    'p_id_coefficient$i;p_id_employee$i;p_user_id$i;p_fact_value$f;p_decode_name1$s;p_decode_value1$s;' +
    'p_decode_name2$s;p_decode_value2$s;p_decode_name3$s;p_decode_value3$s',
    [AIdCoef, AIdEmployee, User.GetId, LPct,
     cMotOutputPlanName, FormatFloat('0.##', LPlan),
     cMotOutputFactName, FormatFloat('0.##', LH),
     cMotOutputTotalName, FormatFloat('0.00', Double(LPct)) + '%']);
  Result := True;
end;

{ TMotScrollBox }

procedure TMotScrollBox.WMGetDlgCode(var Message: TWMGetDlgCode);
//без этого стрелки перехватывает диалоговая навигация формы и до KeyDown не доходят
begin
  inherited;
  Message.Result := Message.Result or DLGC_WANTARROWS;
end;

procedure TMotScrollBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if CanFocus and not Focused then
    SetFocus;
end;

procedure TMotScrollBox.KeyDown(var Key: Word; Shift: TShiftState);
const
  cStep = 40;
begin
  inherited;
  case Key of
    VK_UP:    VertScrollBar.Position := VertScrollBar.Position - cStep;
    VK_DOWN:  VertScrollBar.Position := VertScrollBar.Position + cStep;
    VK_LEFT:  HorzScrollBar.Position := HorzScrollBar.Position - cStep;
    VK_RIGHT: HorzScrollBar.Position := HorzScrollBar.Position + cStep;
    VK_PRIOR: VertScrollBar.Position := VertScrollBar.Position - Max(cStep, ClientHeight - cStep);
    VK_NEXT:  VertScrollBar.Position := VertScrollBar.Position + Max(cStep, ClientHeight - cStep);
    VK_HOME:  VertScrollBar.Position := 0;
    VK_END:   VertScrollBar.Position := VertScrollBar.Range;
  else
    Exit;
  end;
  Key := 0;
end;

function TMotScrollBox.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
//одно "щёлканье" колеса (WheelDelta = 120) - 3 шага прокрутки; с Shift - по горизонтали
const
  cStep = 40;
var
  LDelta: Integer;
begin
  LDelta := (WheelDelta * cStep * 3) div 120;
  if ssShift in Shift then
    HorzScrollBar.Position := HorzScrollBar.Position - LDelta
  else
    VertScrollBar.Position := VertScrollBar.Position - LDelta;
  Result := True;
end;

procedure TFrmWMotivationTest.PaintBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
//блоки - TPaintBox (не оконный элемент, фокус не берёт) - передаём фокус области прокрутки, чтобы работали стрелки и колесо
begin
  if sbxClient.CanFocus and not sbxClient.Focused then
    sbxClient.SetFocus;
end;

procedure TFrmWMotivationTest.LeftAreaMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
//клик в левой части формы вне элементов управления - убираем фокус с таблицы (фокус получает левая панель)
begin
  if pnlLeft.CanFocus then
    pnlLeft.SetFocus;
end;

procedure TFrmWMotivationTest.BtnPrintClick(Sender: TObject);
begin
  if Length(FBlocks) < 2 then begin
    MyWarningMessage('Нечего печатать - выберите должность (или сотрудника).');
    Exit;
  end;
  PrintBlocks;
end;

procedure TFrmWMotivationTest.PrintBlocks;
//печать основной таблицы (всех блоков, кроме блока заголовка экрана - он содержит легенду линий и предупреждения, а вместо
//него на КАЖДОЙ странице печатается шапка: должность, сотрудник, период). Блоки рисуются на принтере той же процедурой
//DrawMotGridPanel, что и на экране (с масштабом - см. AScale), поэтому вид тот же, но без цветных линий "горячих зон".
//Масштаб: по умолчанию размер как на экране (по разрешению принтера), но если блок шире страницы - уменьшается по ширине
//(при книжной ориентации таблица уменьшится, при альбомной обычно помещается без уменьшения; ориентацию можно изменить в
//окне свойств принтера). Блоки не разрезаются: если блок не помещается в остаток страницы, он целиком переносится на
//следующую; разрезается только блок, который не помещается и на целую страницу - и то только между строками (не разрывая
//объединённые по строкам ячейки, см. MotGridCanCutAfter). Нумерация страниц "N из M" - раскладка считается заранее.
var
  Dlg: TPrintDialog;
  Items: array of TMotPrintItem;
  PpiX, Margin, PageW, PageH, BodyTop, BodyBottom, HeaderH, FooterH, Gap: Integer;
  k, k0, WMax: Double;
  Pg, i, j, y, h, r, e, q, n, Avail, Acc, PageCount, TextH: Integer;
  Title1, Title2, Title3, FooterL, FooterR: string;
  Data, Part: TMotGridData;

  function RowsH(const AData: TMotGridData; AR1, AR2: Integer): Integer;
  var
    w: Integer;
  begin
    Result := 0;
    for w := AR1 to AR2 do
      Result := Result + Round(AData.RowHeights[w] * k);
  end;

  procedure AddItem(APage, ABlock, AR1, AR2, AY: Integer);
  begin
    SetLength(Items, Length(Items) + 1);
    with Items[High(Items)] do begin
      Page := APage; Block := ABlock; FirstRow := AR1; LastRow := AR2; Y := AY;
    end;
  end;

  procedure SetFont(ACanvas: TCanvas; APt: Double; ABold: Boolean);
  begin
    ACanvas.Font.Name := 'Tahoma';
    ACanvas.Font.Height := -Max(1, Round(APt * Screen.PixelsPerInch / 72 * k));
    if ABold then ACanvas.Font.Style := [fsBold] else ACanvas.Font.Style := [];
    ACanvas.Font.Color := clBlack;
    ACanvas.Brush.Style := bsClear;
  end;

begin
  if Printer.Printers.Count = 0 then begin
    MyWarningMessage('В системе не установлено ни одного принтера.');
    Exit;
  end;
  Printer.Orientation := poLandscape;
  Dlg := TPrintDialog.Create(Self);
  try
    if not Dlg.Execute then
      Exit;
  finally
    Dlg.Free;
  end;

  Printer.Title := 'Мотивация - ' + FPrintJobName;
  Printer.BeginDoc;
  try
    PpiX := GetDeviceCaps(Printer.Handle, LOGPIXELSX);
    Margin := Round(PpiX * 8 / 25.4);
    PageW := Printer.PageWidth;
    PageH := Printer.PageHeight;
    //масштаб: как на экране, но не шире страницы
    k0 := PpiX / Screen.PixelsPerInch;
    WMax := 1;
    for i := 1 to High(FBlocks) do
      if MotGridWidth(FBlocks[i]) > WMax then
        WMax := MotGridWidth(FBlocks[i]);
    k := Min(k0, (PageW - 2 * Margin) / WMax);

    Title1 := 'Мотивация: ' + FPrintJobName;
    Title2 := S.IIFStr(FPrintEmployee <> '', 'Сотрудник: ' + FPrintEmployee, 'По должности (без персональных данных сотрудника)');
    Title3 := 'Период: ' + FormatDateTime('mmmm yyyy', IncMonth(StartOfTheMonth(Date), -1));
    FooterL := 'Напечатано ' + DateTimeToStr(Now);

    //высота шапки и подвала страницы
    SetFont(Printer.Canvas, 12, True);
    HeaderH := Printer.Canvas.TextHeight(Title1);
    SetFont(Printer.Canvas, 9, False);
    TextH := Printer.Canvas.TextHeight(Title2);
    HeaderH := HeaderH + 2 * TextH + Round(10 * k);
    FooterH := TextH + Round(8 * k);
    BodyTop := Margin + HeaderH;
    BodyBottom := PageH - Margin - FooterH;
    Gap := Round(10 * k);

    //раскладка: блоки 1.. (блок 0 - заголовок экрана, не печатается)
    SetLength(Items, 0);
    Pg := 1;
    y := BodyTop;
    for i := 1 to High(FBlocks) do begin
      Data := FBlocks[i];
      n := Length(Data.RowHeights);
      if n = 0 then Continue;
      h := RowsH(Data, 0, n - 1);
      r := 0;
      while r < n do begin
        Avail := BodyBottom - y;
        //наибольшая последняя строка фрагмента e, при которой фрагмент помещается в остаток страницы
        //и после неё можно резать (или это последняя строка блока)
        e := -1;
        Acc := 0;
        for q := r to n - 1 do begin
          Acc := Acc + Round(Data.RowHeights[q] * k);
          if Acc > Avail then Break;
          if (q = n - 1) or MotGridCanCutAfter(Data, q) then e := q;
        end;
        if (r = 0) and (e < n - 1) and (y > BodyTop) and (h <= BodyBottom - BodyTop) then begin
          //блок целиком не помещается в остаток страницы, но поместится на новую - переносим его целиком
          Inc(Pg);
          y := BodyTop;
          Continue;
        end;
        if e < 0 then begin
          if y > BodyTop then begin
            Inc(Pg);
            y := BodyTop;
            Continue;
          end;
          e := r; //даже одна строка не помещается на пустую страницу - печатаем как есть
        end;
        AddItem(Pg, i, r, e, y);
        y := y + RowsH(Data, r, e);
        r := e + 1;
        if r < n then begin
          Inc(Pg);
          y := BodyTop;
        end
        else
          y := y + Gap;
      end;
    end;
    PageCount := Pg;

    //печать
    for Pg := 1 to PageCount do begin
      if Pg > 1 then
        Printer.NewPage;
      //шапка
      SetFont(Printer.Canvas, 12, True);
      Printer.Canvas.TextOut(Margin, Margin, Title1);
      y := Margin + Printer.Canvas.TextHeight(Title1);
      SetFont(Printer.Canvas, 9, False);
      Printer.Canvas.TextOut(Margin, y, Title2);
      y := y + TextH;
      Printer.Canvas.TextOut(Margin, y, Title3);
      y := BodyTop - Round(5 * k);
      Printer.Canvas.Pen.Color := clBlack;
      Printer.Canvas.Pen.Width := Max(1, Round(k));
      Printer.Canvas.MoveTo(Margin, y);
      Printer.Canvas.LineTo(PageW - Margin, y);
      //подвал
      SetFont(Printer.Canvas, 8, False);
      FooterR := 'Стр. ' + IntToStr(Pg) + ' из ' + IntToStr(PageCount);
      Printer.Canvas.TextOut(Margin, PageH - Margin - Printer.Canvas.TextHeight(FooterL), FooterL);
      Printer.Canvas.TextOut(PageW - Margin - Printer.Canvas.TextWidth(FooterR), PageH - Margin - Printer.Canvas.TextHeight(FooterR), FooterR);
      //блоки страницы
      for j := 0 to High(Items) do
        if Items[j].Page = Pg then begin
          Data := FBlocks[Items[j].Block];
          if (Items[j].FirstRow = 0) and (Items[j].LastRow = High(Data.RowHeights)) then
            DrawMotGridPanel(Printer.Canvas, Margin, Items[j].Y, Data, k)
          else begin
            Part := MotGridSlice(Data, Items[j].FirstRow, Items[j].LastRow);
            DrawMotGridPanel(Printer.Canvas, Margin, Items[j].Y, Part, k);
          end;
        end;
    end;
    Printer.EndDoc;
  except
    if Printer.Printing then
      Printer.Abort;
    raise;
  end;
end;

procedure TFrmWMotivationTest.LoadResultStates;
//сохранённые пересчётом результаты для цветов в списках: по должностям (w_motivation_job_state) и по сотрудникам
//(v_w_motivation_results). Таблиц может ещё не быть в БД (не выполнен SqlUpdater) - тогда без цветов
begin
  FJobStates.Clear;
  FEmpStates.Clear;
  if not FState.Loaded then Exit;
  try
    Q.QLoad('select id_job_internal, job_ok, emp_total, emp_valid from w_motivation_job_state', [], FJobStates);
    Q.QLoad('select id_employee, is_valid, is_actual from v_w_motivation_results', [], FEmpStates);
  except
    FJobStates.Clear;
    FEmpStates.Clear;
  end;
end;

function TFrmWMotivationTest.JobStateColor(AIdJob: Integer; var ACounts: string): TColor;
//цвет должности в списке по сохранённому результату: красный - общие данные должности некорректны, оранжевый - общие
//в порядке, но у части сотрудников есть замечания, зелёный - всё в порядке, clNone - не рассчитано.
//ACounts - "корректных сотрудников / всего"
var
  i: Integer;
  LValid, LTotal: Integer;
begin
  Result := clNone;
  ACounts := '';
  if FJobStates.Count = 0 then Exit;
  i := FJobStates.FindFirst('id_job_internal', AIdJob);
  if i < 0 then Exit;
  LValid := Round(S.NNum(FJobStates.GetValue(i, 'emp_valid')));
  LTotal := Round(S.NNum(FJobStates.GetValue(i, 'emp_total')));
  ACounts := IntToStr(LValid) + '/' + IntToStr(LTotal);
  if S.NNum(FJobStates.GetValue(i, 'job_ok')) <> 1 then
    Result := cMotStateRed
  else if LValid < LTotal then
    Result := cMotStateOrange
  else
    Result := cMotStateGreen;
end;

function TFrmWMotivationTest.EmpStateColor(AIdEmployee: Integer; var AStale: Boolean): TColor;
//цвет сотрудника в списке по сохранённому результату: зелёный - все данные введены и корректны, красный - есть замечания,
//clNone - не рассчитано. AStale - данные менялись после расчёта (результат устарел)
var
  i: Integer;
begin
  Result := clNone;
  AStale := False;
  if FEmpStates.Count = 0 then Exit;
  i := FEmpStates.FindFirst('id_employee', AIdEmployee);
  if i < 0 then Exit;
  AStale := S.NNum(FEmpStates.GetValue(i, 'is_actual')) <> 1;
  if S.NNum(FEmpStates.GetValue(i, 'is_valid')) = 1 then
    Result := cMotStateGreen
  else
    Result := cMotStateRed;
end;

procedure TFrmWMotivationTest.LbxDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
//отрисовка строк списков должностей и сотрудников с цветом состояния данных (см. JobStateColor/EmpStateColor);
//выбранная строка - обычное выделение, но с цветной полосой слева; устаревший результат - курсивом
var
  LB: TListBox;
  LColor: TColor;
  LStale: Boolean;
  LCounts: string;
begin
  LB := TListBox(Control);
  if (Index < 0) or (Index >= LB.Items.Count) then Exit;
  LStale := False;
  LCounts := '';
  if LB = lbxJobs then
    LColor := JobStateColor(Integer(LB.Items.Objects[Index]), LCounts)
  else
    LColor := EmpStateColor(Integer(LB.Items.Objects[Index]), LStale);
  if odSelected in State then begin
    LB.Canvas.Brush.Color := clHighlight;
    LB.Canvas.Font.Color := clHighlightText;
  end else begin
    if LColor <> clNone then LB.Canvas.Brush.Color := LColor else LB.Canvas.Brush.Color := LB.Color;
    LB.Canvas.Font.Color := clWindowText;
  end;
  LB.Canvas.FillRect(Rect);
  if (odSelected in State) and (LColor <> clNone) then begin
    LB.Canvas.Brush.Color := LColor;
    LB.Canvas.FillRect(System.Types.Rect(Rect.Left, Rect.Top, Rect.Left + 7, Rect.Bottom));
    LB.Canvas.Brush.Style := bsClear;
  end;
  LB.Canvas.Brush.Style := bsClear;
  if LStale then LB.Canvas.Font.Style := [fsItalic] else LB.Canvas.Font.Style := [];
  LB.Canvas.TextOut(Rect.Left + 10, Rect.Top + 1, LB.Items[Index]);
  if LCounts <> '' then begin
    if not (odSelected in State) then LB.Canvas.Font.Color := clGray;
    LB.Canvas.Font.Style := [];
    LB.Canvas.TextOut(Rect.Right - LB.Canvas.TextWidth(LCounts) - 4, Rect.Top + 1, LCounts);
  end;
end;

procedure TFrmWMotivationTest.RefreshStateUI;
//состояние блокировки (панель pnlLock), сводка по результатам и цвета в списках
var
  LDt: string;
begin
  FState := MotLoadState;
  btnLock.Enabled := FState.Loaded;
  btnRecalc.Enabled := FState.Loaded;
  FSummary := '';
  if not FState.Loaded then begin
    lblLockState.Font.Color := clGray;
    lblLockState.Caption := 'Блокировка недоступна: в БД нет таблиц (не выполнен SqlUpdater по d_motivation.sql)';
    btnLock.Caption := 'Заблокировать...';
  end else begin
    if FState.IsLocked then begin
      LDt := '';
      if not VarIsNull(FState.LockDt) then LDt := ', ' + FormatDateTime('dd.mm.yyyy hh:nn', VarToDateTime(FState.LockDt));
      lblLockState.Font.Color := clRed;
      lblLockState.Caption := 'ДАННЫЕ ЗАБЛОКИРОВАНЫ'#13#10 + FState.LockUser + LDt;
      btnLock.Caption := 'Снять блокировку...';
      if FState.LockComm <> '' then FSummary := 'Комментарий к блокировке: ' + FState.LockComm + #13#10;
    end else begin
      lblLockState.Font.Color := clGreen;
      lblLockState.Caption := 'Данные открыты для корректировки';
      btnLock.Caption := 'Заблокировать...';
    end;
    FSummary := FSummary + 'Результатов расчёта: ' + IntToStr(FState.EmpTotal) + ' сотр., корректных: ' + IntToStr(FState.EmpValid) + '.'#13#10;
    if FState.IsDirty then
      FSummary := FSummary + 'Данные менялись после последнего полного пересчёта - нужен пересчёт.'#13#10
    else if VarIsNull(FState.FullCalcDt) then
      FSummary := FSummary + 'Полный пересчёт ещё не выполнялся.'#13#10;
  end;
  LoadResultStates;
  lbxJobs.Invalidate;
  lbxEmployees.Invalidate;
  ShowSelectionState;
end;

procedure TFrmWMotivationTest.ShowSelectionState;
//подробности по выбранному сотруднику (режим "По сотруднику") или должности из сохранённых результатов расчёта
var
  LRes: TMotEmpResult;
  LRow: Variant;
  LTxt: string;
begin
  LTxt := FSummary;
  if FState.Loaded then begin
    if (rbgMode.ItemIndex = 1) and (lbxEmployees.ItemIndex >= 0) then begin
      LRes := MotGetEmployeeResult(Integer(lbxEmployees.Items.Objects[lbxEmployees.ItemIndex]), False);
      if not LRes.Found then
        LTxt := LTxt + #13#10'Сотрудник: результат не рассчитан (кнопка "Пересчитать").'
      else begin
        if LRes.IsValid then begin
          LTxt := LTxt + #13#10'Сотрудник: все данные введены и корректны.';
          if not VarIsNull(LRes.PremiumTurv) then
            LTxt := LTxt + #13#10'Премия к начислению (с учётом ТУРВ): ' + FormatFloat('0.##', Double(LRes.PremiumTurv));
        end else
          LTxt := LTxt + #13#10'Сотрудник: есть замечания:'#13#10 + LRes.StateText;
        if not LRes.IsActual then
          LTxt := LTxt + #13#10'(результат устарел: данные менялись после расчёта)';
        if not VarIsNull(LRes.DtCalc) then
          LTxt := LTxt + #13#10'Расчёт: ' + FormatDateTime('dd.mm.yyyy hh:nn', VarToDateTime(LRes.DtCalc));
      end;
    end else if not VarIsNull(GetSelectedJobId) then begin
      LRow := Q.QLoadRow('select job_ok, state_text, emp_total, emp_valid, dt_calc from w_motivation_job_state ' +
        'where id_job_internal = :ij$i', [GetSelectedJobId]);
      if VarIsNull(LRow[0]) then
        LTxt := LTxt + #13#10'Должность: результат не рассчитан (кнопка "Пересчитать").'
      else begin
        if S.NNum(LRow[0]) = 1 then
          LTxt := LTxt + #13#10'Должность: общие данные введены и корректны. Сотрудников с корректными данными: ' +
            IntToStr(Round(S.NNum(LRow[3]))) + ' из ' + IntToStr(Round(S.NNum(LRow[2]))) + '.'
        else
          LTxt := LTxt + #13#10'Должность: есть замечания:'#13#10 + VarToStr(LRow[1]);
        if not VarIsNull(LRow[4]) then
          LTxt := LTxt + #13#10'Расчёт: ' + FormatDateTime('dd.mm.yyyy hh:nn', VarToDateTime(LRow[4]));
      end;
    end;
  end;
  memState.Text := LTxt;
end;

function TFrmWMotivationTest.RunRecalc(AMode: Integer): Boolean;
//пересчёт с сохранением результата в БД: AMode = 0 - все должности, 1 - выбранная должность, 2 - выбранный сотрудник.
//Пока идёт расчёт, левая панель недоступна, в строке состояния показывается ход
var
  LJob, LEmp: Variant;
  LProgress: TMotProgress;
begin
  Result := False;
  LJob := GetSelectedJobId;
  LEmp := Null;
  if (rbgMode.ItemIndex = 1) and (lbxEmployees.ItemIndex >= 0) then
    LEmp := Integer(lbxEmployees.Items.Objects[lbxEmployees.ItemIndex]);
  if ((AMode = 1) and VarIsNull(LJob)) or ((AMode = 2) and VarIsNull(LEmp)) then begin
    MyInfoMessage('Не выбрана ' + S.IIfStr(AMode = 1, 'должность', 'должность и сотрудник (режим "По сотруднику")') + '.');
    Exit;
  end;
  LProgress := procedure(const ATitle: string; ACur, ATotal: Integer)
    begin
      lblLockState.Font.Color := clGray;
      lblLockState.Caption := 'Пересчёт ' + IntToStr(ACur) + ' из ' + IntToStr(ATotal) + #13#10 + ATitle;
      lblLockState.Update;
    end;
  Screen.Cursor := crHourGlass;
  pnlLeft.Enabled := False;
  try
    try
      case AMode of
        0: MotRecalcAll(LProgress);
        1: MotRecalcJob(Integer(LJob), LProgress);
        2: MotRecalcEmployee(Integer(LEmp));
      end;
      Result := True;
    except
      on E: Exception do
        MyInfoMessage('Ошибка пересчёта: ' + E.Message);
    end;
  finally
    pnlLeft.Enabled := True;
    Screen.Cursor := crDefault;
  end;
  RefreshStateUI;
end;

procedure TFrmWMotivationTest.BtnRecalcClick(Sender: TObject);
var
  P: TPoint;
begin
  popRecalc.Items[1].Enabled := not VarIsNull(GetSelectedJobId);
  popRecalc.Items[2].Enabled := (rbgMode.ItemIndex = 1) and (lbxEmployees.ItemIndex >= 0);
  P := btnRecalc.ClientToScreen(Point(0, btnRecalc.Height));
  popRecalc.Popup(P.X, P.Y);
end;

procedure TFrmWMotivationTest.MenuRecalcClick(Sender: TObject);
begin
  RunRecalc(TMenuItem(Sender).Tag);
  DoRender;
end;

procedure TFrmWMotivationTest.BtnLockClick(Sender: TObject);
//установка/снятие блокировки корректировки данных (права rW_Mtvn_Lock_Set / rW_Mtvn_Lock_Clear). Перед установкой
//выполняется полный пересчёт, чтобы сохранённые результаты соответствовали фиксируемым данным
var
  va: TVarDynArray;
  LMsg: string;
  LInvalid: Integer;
begin
  FState := MotLoadState;
  if not FState.Loaded then begin
    MyInfoMessage('Блокировка недоступна: в БД нет таблиц (не выполнен SqlUpdater по d_motivation.sql).');
    Exit;
  end;
  if FState.IsLocked then begin
    if not User.Role(rW_Mtvn_Lock_Clear) then begin
      MyInfoMessage('Нет права на снятие блокировки данных мотивации.');
      Exit;
    end;
    if MyQuestionMessage('Снять блокировку? После снятия значения коэффициентов, диапазоны, формулы и оценки можно будет менять, ' +
         'а результаты расчёта станут неактуальными после первого изменения.'#13#10#13#10'Блокировку установил: ' +
         FState.LockUser + '.') <> mrYes then Exit;
    Q.QCallStoredProc('p_w_motivation_lock_set', 'p_user_id$i;p_lock$i;p_comm$s', [User.GetId, 0, '']);
  end else begin
    if not User.Role(rW_Mtvn_Lock_Set) then begin
      MyInfoMessage('Нет права на установку блокировки данных мотивации.');
      Exit;
    end;
    if not RunRecalc(0) then Exit;
    LInvalid := FState.EmpTotal - FState.EmpValid;
    LMsg := 'Выполнен полный пересчёт. Сотрудников в расчёте: ' + IntToStr(FState.EmpTotal) + ', с корректными данными: ' +
      IntToStr(FState.EmpValid) + ', с замечаниями: ' + IntToStr(LInvalid) + '.';
    if LInvalid > 0 then
      LMsg := LMsg + #13#10#13#10'Внимание: по части сотрудников данные введены не полностью или некорректны (красные в списке) - ' +
        'премия по ним не будет рассчитана.';
    LMsg := LMsg + #13#10#13#10'Установить блокировку? После этого менять данные нельзя, пока блокировку не снимут.';
    if MyQuestionMessage(LMsg) <> mrYes then Exit;
    if TFrmBasicInput.ShowDialog(Self, '', [], fEdit, '~Блокировка данных мотивации', 520, 80,
         [[cntEdit, 'Комментарий', '0:400::N']], [''], va,
         [['Комментарий к блокировке (необязательно).']], nil) < 0 then Exit;
    Q.QCallStoredProc('p_w_motivation_lock_set', 'p_user_id$i;p_lock$i;p_comm$s', [User.GetId, 1, VarToStr(va[0])]);
  end;
  RefreshStateUI;
  DoRender;
end;

procedure TFrmWMotivationTest.DoRender;
var
  LIdJob, LIdEmployee: Variant;
begin
  LIdJob := GetSelectedJobId;
  LIdEmployee := Null;
  if (rbgMode.ItemIndex = 1) and (lbxEmployees.ItemIndex >= 0) then
    LIdEmployee := Integer(lbxEmployees.Items.Objects[lbxEmployees.ItemIndex]);
  RenderJob(LIdJob, LIdEmployee);
  ShowSelectionState;
end;

procedure TFrmWMotivationTest.RbgModeClick(Sender: TObject);
begin
  lbxEmployees.Visible := rbgMode.ItemIndex = 1;
  if lbxEmployees.Visible then
    PopulateEmployeesList(GetSelectedJobId);
  LoadPlannedPay;
  DoRender;
end;

procedure TFrmWMotivationTest.LbxJobsClick(Sender: TObject);
begin
  if rbgMode.ItemIndex = 1 then
    PopulateEmployeesList(GetSelectedJobId);
  LoadPlannedPay;
  DoRender;
end;

procedure TFrmWMotivationTest.LbxEmployeesClick(Sender: TObject);
begin
  LoadPlannedPay;
  DoRender;
end;

procedure TFrmWMotivationTest.EdtPremiumChange(Sender: TObject);
begin
  if FPayUpdating then Exit;      //значения подставляются программно (LoadPlannedPay) - перерисовка там
  DoRender;
end;

end.
