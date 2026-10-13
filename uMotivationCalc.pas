unit uMotivationCalc;

{
Расчёт мотивации без привязки к экрану (12.10.2026, см. !алгоритмы.txt, раздел 6.81).

Сюда вынесено из экрана "Мотивация - Тест" (uFrmWMotivationTest.pas) всё, что считает: разборщик формулы ВЗ
(MotFormulaCheck), загрузка состояния коэффициентов, плановые начисления, итоги по должности/сотруднику
(MotCalcJob). Экран только рисует результат MotCalcJob, а расчёт зарплаты и сервер берут готовое:

  MotCalcJob             - расчёт по должности (AIdEmployee = Null: общие данные) или по сотруднику; кроме итогов
                           премии проверяет, что ВСЕ данные введены и корректны (JobOk/JobMsg - общие данные
                           должности и формула, EmpOk/EmpMsg - личные данные сотрудника и данные по отделу,
                           которые входят в его оценки), см. описание полей TMotCalc;
  MotRecalcEmployee / MotRecalcJob / MotRecalcAll
                         - расчёт "в произвольный момент" с сохранением результата в БД (w_motivation_results,
                           w_motivation_job_state; вью v_w_motivation_results, функция f_w_motivation_premium);
  MotGetEmployeeResult   - статус и премия сотрудника (из таблицы; если результата нет или он устарел -
                           сначала пересчёт); для расчёта зарплаты;
  MotLoadState / MotIsLocked
                         - состояние блокировки данных (w_motivation_state, триггеры-запреты в d_motivation.sql).

ТУРВ (13.10.2026): часы берутся из ТУРВ так же, как в расчётной ведомости (TFrmWGedtPayrollCalc.GetDataFromTurv) -
TTurvData.Create с группировкой 'job;employee;schedulecode;organization;personnel_number' за прошлый календарный
месяц (мотивация считается за прошедший месяц, как и плановые начисления), по каждому подразделению, где у
сотрудника были статусы в периоде. План = норма часов периода по графику (period_hours_norm), факт = отработанное
время (worktime) БЕЗ переработки (overtime, CalculateTotals): премия идёт пропорционально факту / плану, а
переработка оплачивается в ведомости отдельно. Единственное место - MotGetTurv; в режиме "По должности" (сотрудник не
задан) ТУРВ не читается и берётся норма по умолчанию cMotTurvDefault (план = факт).
}

interface

uses
  SysUtils, Variants, Classes, Math, DateUtils,
  uString, uNamedArr, uDBOra, uData
  ;

type
  TMotStr3 = array[1..3] of string;
  //значения и названия коэффициентов К1, К2, ... для формулы ВЗ (индекс 0 = К1) - см. MotFormulaCheck
  TMotVars = array of Double;
  TMotNames = array of string;

  TMotTotals = record
    Salary, Premium: Variant;        //оклад (постоянная часть) и премия - расчётная часть; Null - не заданы
    GradeSum: array[0..3] of Double; //аналог L18:O18 в Excel - сумма по критериям (доля x премия x коэф-нт), если бы по ВСЕМ критериям получена оценка 1..4 (без множителей)
    GradeMul: array[0..3] of Double; //произведение множителей специальных коэффициентов (культура, качество) для оценки 1..4
    SumJ: Double;                    //аналог SUM(J) в Excel - сумма по выбранным оценкам критериев (доля x премия x коэф-нт выбранной оценки)
    FactMul: Double;                 //произведение фактических множителей: специальные коэффициенты (по оценке сотрудника) x грубые замечания x ЧС
    TurvPlan, TurvFact: Double;      //ТУРВ: план (норма периода) и факт (отработано БЕЗ переработки) рабочих часов за период
    TurvOvertime: Double;            //справочно: переработка за период (в факт не входит)
    TurvFound: Boolean;              //данные ТУРВ получены (для сотрудника); False - режим "По должности" или данных нет
    TurvMsg: string;                 //пояснение: за какой период, из чего получено, или почему данных нет
    //формула вознаграждения (ВЗ) должности - см. MotCalcJob, MotFormulaCheck
    FormulaText: string;             //действующий текст формулы (пусто - у должности нет коэффициентов)
    FormulaIsDefault: Boolean;       //формула стандартная (не сохранена для должности)
    FormulaSev: Integer;             //0 - в порядке, 1 - предупреждение (не все коэффициенты), 2 - ошибка (расчёт невозможен)
    FormulaMsg: string;              //текст замечаний к формуле
    FormulaOk: Boolean;              //премия по формуле рассчитана (FormulaSev < 2)
    FinalPrem: Double;               //премия по формуле для фактических (выбранных/введённых) значений
    GradePrem: array[0..3] of Double;//премия по формуле, если по ВСЕМ критериям получена оценка 1..4
  end;

  //состояние одного коэффициента К1..Кn должности
  TMotCoef = record
    Id: Integer;                     //айди привязки к должности (w_motivation_coefficient_for_job)
    IdCoef: Integer;                 //айди коэффициента в справочнике
    Name, Description: string;
    IsPersonal: Boolean;
    Weight: Variant;                 //доля вознаграждения (0..1), Null - не задана
    Sel: Integer;                    //выбранная оценка 1..4, 0 - не определена
    Fact: Variant;                   //значение показателя, Null - нет
    UnitName: string;
    DecN, DecV: TMotStr3;            //таблица-расшифровка значения
  end;

  //результат MotCalcJob
  TMotCalc = record
    JobName, EmployeeName: string;
    WeightsState: Integer;           //v_w_motivation_jobs_coeffs.weights_state: 0 - 100%, 1 - меньше, 2 - больше, 3 - нет критериев
    WeightsPct: Double;
    WeightsWarn: Boolean;            //доли критериев не дают 100% (состояния 1 и 2)
    Coefs: array of TMotCoef;
    Totals: TMotTotals;
    KindNum: array[1..2] of Integer; //номер К блока культуры производства (1) и качества работы (2), 0 - блока нет
    RemarksNum: Integer;             //номер К блока замечаний/ЧС, 0 - блока нет
    KVars: TMotVars;                 //значения К1..Кn для формулы
    KNames: TMotNames;
    KMap: string;                    //расшифровка К1..Кn (для окна формулы)
    DefaultF, StoredF, FormulaText: string; //стандартная формула, сохранённая (пусто - нет), действующая
    //проверка полноты и корректности данных: сообщения по строкам (пусто - всё в порядке)
    JobOk, EmpOk: Boolean;
    JobMsg, EmpMsg: string;
    PremiumOk: Boolean;              //премия по формуле рассчитана (есть плановая премия, формула без ошибок)
    PremiumTurv: Double;             //премия с учётом факта/плана ТУРВ (имеет смысл при PremiumOk)
  end;

  //состояние блокировки данных и сводка по результатам (w_motivation_state, v_w_motivation_state)
  TMotState = record
    Loaded: Boolean;                 //False - таблицы ещё нет в БД (не выполнен SqlUpdater)
    IsLocked: Boolean;
    LockDt: Variant;
    LockUser, LockComm: string;
    IsDirty: Boolean;                //исходные данные менялись после последнего полного пересчёта
    FullCalcDt: Variant;
    EmpTotal, EmpValid: Integer;
  end;

  //результат по сотруднику из БД (v_w_motivation_results)
  TMotEmpResult = record
    Found: Boolean;                  //результат есть
    IsValid: Boolean;                //все данные введены и корректны, премия рассчитана
    IsActual: Boolean;               //посчитан после последнего изменения исходных данных
    JobOk, EmpOk: Boolean;
    IdJob: Integer;
    StateText, Formula: string;
    FixedPay, VariablePay: Variant;  //оклад и премия - расчётная часть (плановые начисления)
    Premium: Variant;                //премия по формуле при отработке нормы
    TurvPlan, TurvFact: Variant;
    PremiumTurv: Variant;            //премия к начислению с учётом ТУРВ (Null - не рассчитана)
    DtCalc: Variant;
  end;

  //ход пересчёта: ATitle - что считается, ACur из ATotal
  TMotProgress = reference to procedure(const ATitle: string; ACur, ATotal: Integer);

const
  //норма часов по умолчанию: используется, только когда ТУРВ не читается (режим "По должности", сотрудник не задан)
  cMotTurvDefault = 168;

function  MotFormulaNormalize(const AText: string): string;
function  MotFormulaCheck(const AText: string; const AVars: TMotVars; const ANames: TMotNames; var AValue: Double; var AMsg: string): Integer;

procedure MotLoadCoefState(AIdCoef: Integer; AIdEmployee: Variant; AIsPersonal: Boolean; var ASel: Integer; var AFact: Variant;
  var AUnit: string; var ADecN, ADecV: TMotStr3);
procedure MotLoadPlannedPay(AIdJob, AIdEmployee: Variant; var ASalary, APremium: Variant; var ASrc: string);
procedure MotTurvPeriod(var ADt1, ADt2: TDateTime);
function  MotGetTurv(AIdEmployee: Variant; var APlan, AFact, AOvertime: Double; var AMsg: string): Boolean;
function  MotTurvPlanFor(AIdEmployee: Variant): Double;
procedure MotLoadJobs(var ANa: TNamedArr);
procedure MotCalcJob(AIdJob, AIdEmployee, ASalary, APremium: Variant; var C: TMotCalc);

function  MotLoadState: TMotState;
function  MotIsLocked: Boolean;
function  MotRecalcEmployee(AIdEmployee: Integer): Boolean;
function  MotRecalcJob(AIdJob: Integer; AProgress: TMotProgress = nil): Integer;
function  MotRecalcAll(AProgress: TMotProgress = nil): Integer;
function  MotGetEmployeeResult(AIdEmployee: Integer; ARecalcIfNeeded: Boolean = True): TMotEmpResult;

implementation

uses
  uTurv;

type
  EMotFormula = class(Exception);

  //разбор и вычисление формулы вознаграждения (ВЗ): числа, коэффициенты К1, К2, ... (русская или латинская К, регистр
  //не важен), + - * / и скобки; знаком умножения считаются также х/Х (русская и латинская) и ×, деления - : и ÷.
  //Без скрипта и функций. Использованные номера запоминаются в Used, номера, которых нет среди переданных значений
  //(AVars), - в Missing (значение такого коэффициента принимается равным 0, ошибка выдаётся вызывающим кодом)
  TMotFormulaParser = class
  private
    FText: string;
    FPos: Integer;
    FVars: TMotVars;
    FFs: TFormatSettings;
    function  Cur: Char;
    procedure SkipSpaces;
    procedure Fail(const AMsg: string);
    function  ParseExpr: Double;
    function  ParseTerm: Double;
    function  ParseUnary: Double;
    function  ParsePrimary: Double;
  public
    Used, Missing: array[1..99] of Boolean;
    function Run(const AText: string; const AVars: TMotVars): Double;
  end;

function MotFormulaNormalize(const AText: string): string;
var
  i: Integer;
  c: Char;
begin
  Result := AText;
  for i := 1 to Length(Result) do begin
    c := Result[i];
    if (c = 'х') or (c = 'Х') or (c = 'x') or (c = 'X') or (c = '×') or (c = '·') or (c = '∙') then
      Result[i] := '*'
    else if (c = '÷') or (c = ':') then
      Result[i] := '/'
    else if (c = '−') or (c = '–') or (c = '—') then
      Result[i] := '-'
    else if (c = #160) or (c = #9) or (c = #13) or (c = #10) then
      Result[i] := ' ';
  end;
end;

function TMotFormulaParser.Cur: Char;
begin
  if FPos <= Length(FText) then Result := FText[FPos] else Result := #0;
end;

procedure TMotFormulaParser.SkipSpaces;
begin
  while (FPos <= Length(FText)) and (FText[FPos] = ' ') do
    Inc(FPos);
end;

procedure TMotFormulaParser.Fail(const AMsg: string);
begin
  raise EMotFormula.Create(AMsg);
end;

function TMotFormulaParser.ParseExpr: Double;
begin
  Result := ParseTerm;
  while True do begin
    SkipSpaces;
    if Cur = '+' then begin
      Inc(FPos);
      Result := Result + ParseTerm;
    end
    else if Cur = '-' then begin
      Inc(FPos);
      Result := Result - ParseTerm;
    end
    else
      Break;
  end;
end;

function TMotFormulaParser.ParseTerm: Double;
var
  d: Double;
begin
  Result := ParseUnary;
  while True do begin
    SkipSpaces;
    if Cur = '*' then begin
      Inc(FPos);
      Result := Result * ParseUnary;
    end
    else if Cur = '/' then begin
      Inc(FPos);
      d := ParseUnary;
      if d = 0 then
        Fail('деление на ноль');
      Result := Result / d;
    end
    else
      Break;
  end;
end;

function TMotFormulaParser.ParseUnary: Double;
begin
  SkipSpaces;
  if Cur = '-' then begin
    Inc(FPos);
    Result := -ParseUnary;
  end
  else if Cur = '+' then begin
    Inc(FPos);
    Result := ParseUnary;
  end
  else
    Result := ParsePrimary;
end;

function TMotFormulaParser.ParsePrimary: Double;
var
  c: Char;
  LStart, n: Integer;
  st: string;
begin
  SkipSpaces;
  c := Cur;
  if c = '(' then begin
    Inc(FPos);
    Result := ParseExpr;
    SkipSpaces;
    if Cur <> ')' then
      Fail('не закрыта скобка');
    Inc(FPos);
  end
  else if CharInSet(c, ['0'..'9', '.', ',']) then begin
    LStart := FPos;
    while CharInSet(Cur, ['0'..'9', '.', ',']) do
      Inc(FPos);
    st := StringReplace(Copy(FText, LStart, FPos - LStart), ',', '.', [rfReplaceAll]);
    if not TryStrToFloat(st, Result, FFs) then
      Fail('неверное число "' + st + '"');
  end
  else if (c = 'К') or (c = 'к') or (c = 'K') or (c = 'k') then begin
    Inc(FPos);
    LStart := FPos;
    while CharInSet(Cur, ['0'..'9']) do
      Inc(FPos);
    if FPos = LStart then
      Fail('после буквы К должен идти номер коэффициента (К1, К2, ...)');
    n := StrToIntDef(Copy(FText, LStart, FPos - LStart), 0);
    if (n < 1) or (n > 99) then
      Fail('неверный номер коэффициента К' + Copy(FText, LStart, FPos - LStart));
    Used[n] := True;
    if n <= Length(FVars) then
      Result := FVars[n - 1]
    else begin
      Missing[n] := True;
      Result := 0;
    end;
  end
  else if c = #0 then
    Fail('формула закончилась раньше времени (ожидается число, коэффициент или скобка)')
  else begin
    Fail('недопустимый символ "' + c + '"');
    Result := 0;
  end;
end;

function TMotFormulaParser.Run(const AText: string; const AVars: TMotVars): Double;
var
  i: Integer;
begin
  for i := 1 to 99 do begin
    Used[i] := False;
    Missing[i] := False;
  end;
  FFs := TFormatSettings.Create;
  FFs.DecimalSeparator := '.';
  FVars := AVars;
  FText := MotFormulaNormalize(Trim(AText));
  FPos := 1;
  if FText = '' then
    Fail('формула пуста');
  Result := ParseExpr;
  SkipSpaces;
  if FPos <= Length(FText) then
    Fail('лишний символ "' + Cur + '" (возможно, пропущен знак действия или лишняя скобка)');
end;

function MotFormulaCheck(const AText: string; const AVars: TMotVars; const ANames: TMotNames; var AValue: Double; var AMsg: string): Integer;
//вычисляет формулу и проверяет её состав: 0 - всё в порядке; 1 - предупреждение (в формуле используются не все
//коэффициенты, расчёт выполнен); 2 - ошибка (синтаксис, деление на ноль или используются коэффициенты, которых нет у
//должности - расчёт невозможен, значение 0). Текст замечаний - в AMsg
var
  P: TMotFormulaParser;
  i, NK: Integer;
  LMiss, LUnused: string;
begin
  AValue := 0;
  AMsg := '';
  Result := 0;
  NK := Length(AVars);
  P := TMotFormulaParser.Create;
  try
    try
      AValue := P.Run(AText, AVars);
    except
      on E: EMotFormula do begin
        AValue := 0;
        AMsg := 'Ошибка в формуле: ' + E.Message + '. Премия не рассчитана.';
        Result := 2;
        Exit;
      end;
    end;
    LMiss := '';
    for i := 1 to 99 do
      if P.Missing[i] then
        LMiss := LMiss + ', К' + IntToStr(i);
    if LMiss <> '' then begin
      Delete(LMiss, 1, 2);
      AMsg := 'В формуле используются несуществующие коэффициенты: ' + LMiss;
      if NK > 0 then
        AMsg := AMsg + ' (у этой должности есть только К1..К' + IntToStr(NK) + ')'
      else
        AMsg := AMsg + ' (у этой должности нет коэффициентов)';
      AMsg := AMsg + '. Премия не рассчитана.';
      AValue := 0;
      Result := 2;
    end;
    LUnused := '';
    for i := 1 to NK do
      if not P.Used[i] then begin
        LUnused := LUnused + ', К' + IntToStr(i);
        if (i <= Length(ANames)) and (ANames[i - 1] <> '') then
          LUnused := LUnused + ' («' + ANames[i - 1] + '»)';
      end;
    if LUnused <> '' then begin
      Delete(LUnused, 1, 2);
      if AMsg <> '' then
        AMsg := AMsg + #13#10;
      AMsg := AMsg + 'В формуле не используются коэффициенты: ' + LUnused + '.';
      if Result = 0 then
        Result := 1;
    end;
  finally
    P.Free;
  end;
end;

procedure MotLoadCoefState(AIdCoef: Integer; AIdEmployee: Variant; AIsPersonal: Boolean; var ASel: Integer; var AFact: Variant;
  var AUnit: string; var ADecN, ADecV: TMotStr3);
//текущее состояние коэффициента: значение показателя (AFact), выбранная оценка 1..4 (ASel, 0 - не
//определена), единица измерения и таблица-расшифровка. Обычный коэффициент - значение и расшифровка из
//w_motivation_coefficients, оценка из v_w_motivation_coefficients_rates; ЛИЧНЫЙ - из w_motivation_employee_values и
//v_w_motivation_emp_rates по выбранному сотруднику (без сотрудника значения нет).
var
  naC, naV, naS: TNamedArr;
  n: Integer;
begin
  ASel := 0;
  AFact := Null;
  for n := 1 to 3 do begin
    ADecN[n] := '';
    ADecV[n] := '';
  end;
  Q.QLoad('select fact_value, unit_name, decode_name1, decode_value1, decode_name2, decode_value2, ' +
    'decode_name3, decode_value3 from w_motivation_coefficients where id = :id$i', [AIdCoef], naC);
  AUnit := '';
  if naC.Count = 0 then Exit;
  AUnit := VarToStr(naC.GetValue(0, 'unit_name'));
  if not AIsPersonal then begin
    AFact := naC.GetValue(0, 'fact_value');
    for n := 1 to 3 do begin
      ADecN[n] := VarToStr(naC.GetValue(0, 'decode_name' + IntToStr(n)));
      ADecV[n] := VarToStr(naC.GetValue(0, 'decode_value' + IntToStr(n)));
    end;
    Q.QLoad('select rating from v_w_motivation_coefficients_rates where id_coefficient = :ic$i and is_selected = 1',
      [AIdCoef], naS);
  end else begin
    if VarIsNull(AIdEmployee) then Exit;
    Q.QLoad('select fact_value, decode_name1, decode_value1, decode_name2, decode_value2, decode_name3, decode_value3 ' +
      'from w_motivation_employee_values where id_coefficient = :ic$i and id_employee = :ie$i',
      [AIdCoef, AIdEmployee], naV);
    if naV.Count > 0 then begin
      AFact := naV.GetValue(0, 'fact_value');
      for n := 1 to 3 do begin
        ADecN[n] := VarToStr(naV.GetValue(0, 'decode_name' + IntToStr(n)));
        ADecV[n] := VarToStr(naV.GetValue(0, 'decode_value' + IntToStr(n)));
      end;
    end;
    Q.QLoad('select rating from v_w_motivation_emp_rates where id_coefficient = :ic$i and id_employee = :ie$i and is_selected = 1',
      [AIdCoef, AIdEmployee], naS);
  end;
  if naS.Count > 0 then ASel := Integer(naS.GetValue(0, 'rating'));
end;

procedure MotLoadPlannedPay(AIdJob, AIdEmployee: Variant; var ASalary, APremium: Variant; var ASrc: string);
//оклад (постоянная часть) и премия (стимулирующая часть) из справочника "Плановые начисления по должностям"
//(w_job_salaries) за ПРОШЛЫЙ календарный месяц (мотивация считается за прошедший месяц). Сотрудник задан - берётся
//его официальная должность (v_w_motivation_employees_by_job.id_job); иначе - официальные должности внутренней
//должности AIdJob (w_jobs.id_job_internal): значения возвращаются, только если они у всех одинаковы (неоднозначность
//или отсутствие записи - Null). ASrc - пояснение, откуда значения (или почему их нет)
var
  na: TNamedArr;
  i: Integer;
  LSame: Boolean;
  LMonth: string;
begin
  ASalary := Null;
  APremium := Null;
  ASrc := '';
  if VarIsNull(AIdJob) and VarIsNull(AIdEmployee) then Exit;
  LMonth := FormatDateTime('mmmm yyyy', IncMonth(StartOfTheMonth(Date), -1));
  if not VarIsNull(AIdEmployee) then
    Q.QLoad('select s.fixed_pay, s.variable_pay from w_job_salaries s, v_w_motivation_employees_by_job e ' +
      'where e.id = :ie$i and s.id_job = e.id_job and s.dt = trunc(add_months(sysdate, -1), ''mm'')', [AIdEmployee], na)
  else
    Q.QLoad('select s.fixed_pay, s.variable_pay from w_job_salaries s, w_jobs j ' +
      'where j.id_job_internal = :ij$i and s.id_job = j.id and s.dt = trunc(add_months(sysdate, -1), ''mm'')', [AIdJob], na);
  if na.Count = 0 then begin
    ASrc := 'Плановых начислений за ' + LMonth + ' по должности нет - введите вручную.';
    Exit;
  end;
  LSame := True;
  for i := 1 to na.Count - 1 do
    if (S.NNum(na.GetValue(i, 'fixed_pay')) <> S.NNum(na.GetValue(0, 'fixed_pay'))) or
       (S.NNum(na.GetValue(i, 'variable_pay')) <> S.NNum(na.GetValue(0, 'variable_pay'))) then
      LSame := False;
  if not LSame then begin
    ASrc := 'У официальных должностей специальности разные плановые начисления - введите вручную или выберите сотрудника.';
    Exit;
  end;
  ASalary := na.GetValue(0, 'fixed_pay');
  APremium := na.GetValue(0, 'variable_pay');
  ASrc := 'Источник: "Плановые начисления по должностям" за ' + LMonth + '.';
end;

procedure MotTurvPeriod(var ADt1, ADt2: TDateTime);
//период ТУРВ для мотивации - прошлый календарный месяц (как у плановых начислений, см. MotLoadPlannedPay)
begin
  ADt1 := StartOfTheMonth(IncMonth(Date, -1));
  ADt2 := DateOf(EndOfTheMonth(ADt1));
end;

function MotGetTurv(AIdEmployee: Variant; var APlan, AFact, AOvertime: Double; var AMsg: string): Boolean;
//план и факт рабочих часов сотрудника за прошлый месяц по ТУРВ - так же, как в расчётной ведомости
//(TFrmWGedtPayrollCalc.GetDataFromTurv): TTurvData по подразделению с группировкой по должности/графику/организации/
//табельному, строки итогов - CalculateTotals.
//  факт = worktime - overtime (отработанное время без переработки; переработка оплачивается отдельно),
//  план = period_hours_norm (норма периода по графику); при нескольких строках (перевод, несколько графиков)
//  факт суммируется, план берётся наибольший (норма полного периода, а не сумма норм по статусам).
//AIdEmployee = Null (режим "По должности") - ТУРВ не читается: план = факт = cMotTurvDefault, результат False.
//Результат True, если найдена хотя бы одна строка ТУРВ с нормой > 0; иначе план = факт = 0, AMsg - причина.
const
  cGrouping = 'job;employee;schedulecode;organization;personnel_number';
var
  LDt1, LDt2: TDateTime;
  LDeps: TVarDynArray;
  LTurv: TTurvData;
  LNa: TNamedArr;
  LNorm: Variant;
  LPeriodTxt: string;
  i, j, r: Integer;
  LRows: Integer;
  LNotApproved: Boolean;
begin
  APlan := cMotTurvDefault;
  AFact := cMotTurvDefault;
  AOvertime := 0;
  AMsg := 'Режим "По должности": ТУРВ не читается, принята норма ' + IntToStr(cMotTurvDefault) + ' ч (план = факт).';
  Result := False;
  if VarIsNull(AIdEmployee) then Exit;

  MotTurvPeriod(LDt1, LDt2);
  LPeriodTxt := FormatDateTime('dd.mm.yyyy', LDt1) + ' - ' + FormatDateTime('dd.mm.yyyy', LDt2);
  APlan := 0;
  AFact := 0;
  LRows := 0;
  LNotApproved := False;
  //подразделения, в которых у сотрудника были статусы в периоде (ТУРВ ведётся по подразделению)
  LDeps := Q.QLoadCol('select distinct id_departament from v_w_employee_properties where id_employee = :ie$i ' +
    'and is_terminated <> 1 and dt_beg <= :dt2$d and (dt_end is null or dt_end >= :dt1$d)', [AIdEmployee, LDt2, LDt1]);
  for j := 0 to High(LDeps) do begin
    if VarIsNull(LDeps[j]) then Continue;
    LTurv.Create(Null, cGrouping, cGrouping, LDt1, LDt2, Integer(LDeps[j]), Integer(AIdEmployee), '', True, 0);
    if LTurv.ScheduleNotApproved then
      LNotApproved := True;
    for i := 0 to LTurv.Count - 1 do begin
      r := LTurv.R(i)[0];
      LNorm := LTurv.List.G(r, 'period_hours_norm');
      if VarIsNull(LNorm) then Continue;                //график не утверждён / нет нормы - строка не учитывается
      LNa := LTurv.CalculateTotals(i);
      AFact := AFact + S.NNum(LNa.G('worktime')) - S.NNum(LNa.G('overtime'));
      AOvertime := AOvertime + S.NNum(LNa.G('overtime'));
      if S.NNum(LNorm) > APlan then
        APlan := S.NNum(LNorm);
      Inc(LRows);
    end;
  end;
  AFact := Round(AFact * 100) / 100;
  AOvertime := Round(AOvertime * 100) / 100;
  Result := (LRows > 0) and (APlan > 0);
  if Result then
    AMsg := 'ТУРВ за ' + LPeriodTxt + ': норма ' + FormatFloat('0.##', APlan) + ' ч, отработано без переработки ' +
      FormatFloat('0.##', AFact) + ' ч' + S.IIfStr(AOvertime > 0, ' (переработка ' + FormatFloat('0.##', AOvertime) + ' ч не учитывается)')
  else begin
    APlan := 0;
    AFact := 0;
    AOvertime := 0;
    if LNotApproved then
      AMsg := 'Нет данных ТУРВ за ' + LPeriodTxt + ': график работы сотрудника не утверждён (нет нормы часов)'
    else
      AMsg := 'Нет данных ТУРВ за ' + LPeriodTxt + ': у сотрудника нет статусов в этом периоде';
  end;
end;

function MotTurvPlanFor(AIdEmployee: Variant): Double;
//план ТУРВ (норма часов периода) для сотрудника; без сотрудника - норма по умолчанию; нет данных ТУРВ - 0
var
  LPlan, LFact, LOver: Double;
  LMsg: string;
begin
  MotGetTurv(AIdEmployee, LPlan, LFact, LOver, LMsg);
  Result := LPlan;
end;

procedure MotLoadJobs(var ANa: TNamedArr);
//внутренние должности, по которым введена хотя бы часть данных мотивации: коэффициенты, позиции специальных
//коэффициентов, грубые замечания или ЧС (id, name)
begin
  Q.QLoad('select ji.id, ji.name from w_jobs_internal ji where ji.active = 1 and (' +
    'exists (select 1 from w_motivation_coefficient_for_job x where x.id_job_internal = ji.id) or ' +
    'exists (select 1 from w_motivation_special_items x where x.id_job_internal = ji.id) or ' +
    'exists (select 1 from w_motivation_negative_remarks_for_job x where x.id_job_internal = ji.id) or ' +
    'exists (select 1 from w_motivation_w_work_emergencies_for_job x where x.id_job_internal = ji.id)) order by ji.name', [], ANa);
end;

procedure MotCalcJob(AIdJob, AIdEmployee, ASalary, APremium: Variant; var C: TMotCalc);
//Расчёт мотивации по внутренней должности (AIdEmployee = Null - только общие данные: личные коэффициенты и оценки
//сотрудника не учитываются) или по сотруднику. ASalary/APremium - оклад и премия (расчётная часть) для расчёта сумм,
//Null - не заданы. Порядок К1..Кn: критерии должности по pos, затем специальные коэффициенты (культура
//производства, качество работы - если у должности есть позиции), затем грубые замечания и ЧС (если есть списки).
//Одновременно проверяется, что все данные введены и корректны: JobMsg - общее (доли критериев = 100%, диапазоны
//оценок коэффициентов и специальных, значения общих коэффициентов, оценки позиций по отделу, формула без ошибок
//и использует все К), EmpMsg - данные сотрудника (значения личных коэффициентов, оценки личных позиций, итоговые
//множители замечаний/ЧС, плановая премия). JobOk/EmpOk - сообщений нет.
var
  na, naCalc, naSp, naFacts: TNamedArr;
  i, j, LKind, LNum, LRating, LGi, LKi, LNK, LCnt, LCntRem, LCntEm: Integer;
  LByEmp, LBadRange, LNoVal, LHasRemarks: Boolean;
  LWeightsInfo, LWeight, LVal, LRow, LStoredRow, LFactRem, LFactEm: Variant;
  LE: Double;
  LCritSel: array of Double;
  LCritGrade: array of array[0..3] of Double;
  LSpecGrade: array[1..2] of array[0..3] of Double;
  LSpecFact: array[1..2] of Double;
  LRemFact: Double;
  LGVars: TMotVars;
  LFMsg, LKTxt, LKindName: string;
  LFVal: Double;

  procedure JobErr(const AMsg: string);
  begin
    if C.JobMsg <> '' then C.JobMsg := C.JobMsg + #13#10;
    C.JobMsg := C.JobMsg + AMsg;
  end;

  procedure EmpErr(const AMsg: string);
  begin
    if C.EmpMsg <> '' then C.EmpMsg := C.EmpMsg + #13#10;
    C.EmpMsg := C.EmpMsg + AMsg;
  end;

begin
  C := Default(TMotCalc);
  if VarIsNull(AIdJob) then begin
    C.JobMsg := 'Должность не задана';
    Exit;
  end;
  LByEmp := not VarIsNull(AIdEmployee);
  C.JobName := VarToStr(Q.QLoadValue('select name from w_jobs_internal where id = :id$i', [AIdJob]));
  if LByEmp then
    C.EmployeeName := VarToStr(Q.QLoadValue('select name from v_w_motivation_employees_by_job where id = :id$i', [AIdEmployee]));

  //сумма долей критериев должности должна быть ровно 100%
  C.WeightsState := 3;
  C.WeightsPct := 0;
  LWeightsInfo := Q.QLoadRow('select weights_state, weights_pct from v_w_motivation_jobs_coeffs where id = :id$i', [AIdJob]);
  if not VarIsNull(LWeightsInfo[0]) then begin
    C.WeightsState := Round(S.NNum(LWeightsInfo[0]));
    C.WeightsPct := S.NNum(LWeightsInfo[1]);
  end;
  C.WeightsWarn := (C.WeightsState = 1) or (C.WeightsState = 2);
  if C.WeightsWarn then
    JobErr('Сумма долей вознаграждения критериев = ' + FormatFloat('0.##', C.WeightsPct) + '% (должна быть 100%)');

  //критерии должности в порядке следования (pos привязки) и состояние каждого (значение, выбранная оценка, расшифровка)
  Q.QLoad('select id, id_coefficient, weight, name, description, is_personal ' +
    'from v_w_motivation_coefficient_for_job where id_job_internal = :id_job_internal$i order by pos, id',
    [AIdJob], na);
  if na.Count = 0 then
    JobErr('К должности не привязано ни одного коэффициента');
  SetLength(C.Coefs, na.Count);
  for i := 0 to na.Count - 1 do begin
    C.Coefs[i].Id := Integer(na.GetValue(i, 'id'));
    C.Coefs[i].IdCoef := Integer(na.GetValue(i, 'id_coefficient'));
    C.Coefs[i].Name := VarToStr(na.GetValue(i, 'name'));
    C.Coefs[i].Description := VarToStr(na.GetValue(i, 'description'));
    C.Coefs[i].IsPersonal := na.GetValue(i, 'is_personal') = 1;
    C.Coefs[i].Weight := na.GetValue(i, 'weight');
    MotLoadCoefState(C.Coefs[i].IdCoef, AIdEmployee, C.Coefs[i].IsPersonal, C.Coefs[i].Sel, C.Coefs[i].Fact,
      C.Coefs[i].UnitName, C.Coefs[i].DecN, C.Coefs[i].DecV);
  end;

  //---- итоги для шапки ----
  C.Totals.Salary := ASalary;
  C.Totals.Premium := APremium;
  for j := 0 to 3 do begin
    C.Totals.GradeSum[j] := 0;
    C.Totals.GradeMul[j] := 1;
  end;
  C.Totals.SumJ := 0;
  C.Totals.FactMul := 1;
  SetLength(LCritSel, na.Count);
  SetLength(LCritGrade, na.Count);
  for i := 0 to na.Count - 1 do begin
    LCritSel[i] := 0;
    for j := 0 to 3 do
      LCritGrade[i][j] := 0;
  end;
  for LKind := 1 to 2 do begin
    LSpecFact[LKind] := 1;
    for LGi := 0 to 3 do
      LSpecGrade[LKind][LGi] := 1;
  end;
  LRemFact := 1;
  C.Totals.TurvFound := MotGetTurv(AIdEmployee, C.Totals.TurvPlan, C.Totals.TurvFact, C.Totals.TurvOvertime, C.Totals.TurvMsg);
  //для сотрудника без данных ТУРВ (нет статуса в периоде / не утверждён график) премию с учётом часов не посчитать
  if LByEmp and (not C.Totals.TurvFound) then
    EmpErr(C.Totals.TurvMsg);

  //обычные и личные коэффициенты: по каждой оценке - вес x премия x коэф-нт (L18..O18 Excel); выбранная оценка
  //(динамически вычисляется, не хранится) идёт в SUM(J). Заодно проверка диапазонов и значений
  for i := 0 to na.Count - 1 do begin
    LKTxt := 'К' + IntToStr(i + 1) + ' «' + C.Coefs[i].Name + '»';
    LWeight := C.Coefs[i].Weight;
    if VarIsNull(LWeight) then
      JobErr(LKTxt + ': не задана доля вознаграждения');
    Q.QLoad('select rating, value, range_state from v_w_motivation_coefficients_rates where id_coefficient = :ic$i',
      [C.Coefs[i].IdCoef], naCalc);
    LBadRange := naCalc.Count < 4;
    LNoVal := False;
    for j := 0 to naCalc.Count - 1 do begin
      if (not VarIsNull(naCalc.GetValue(j, 'range_state'))) and (naCalc.GetValue(j, 'range_state') <> 0) then
        LBadRange := True;
      if VarIsNull(naCalc.GetValue(j, 'value')) then
        LNoVal := True;
    end;
    if LBadRange then
      JobErr(LKTxt + ': диапазоны оценок не заданы или некорректны');
    if LNoVal then
      JobErr(LKTxt + ': не заданы коэффициенты премии для всех оценок');
    if C.Coefs[i].Sel = 0 then begin
      //общий коэффициент - данные должности; личный - данные сотрудника (без сотрудника не проверяется)
      if not C.Coefs[i].IsPersonal then
        JobErr(LKTxt + ': ' + S.IIfStr(VarIsNull(C.Coefs[i].Fact), 'значение показателя не введено',
          'оценка не определена (значение вне диапазонов)'))
      else if LByEmp then
        EmpErr(LKTxt + ' [личный]: ' + S.IIfStr(VarIsNull(C.Coefs[i].Fact), 'значение показателя не введено',
          'оценка не определена (значение вне диапазонов)'));
    end;
    if VarIsNull(LWeight) or VarIsNull(C.Totals.Premium) then Continue;
    LE := Double(LWeight) * Double(C.Totals.Premium);
    for j := 0 to naCalc.Count - 1 do begin
      LVal := naCalc.GetValue(j, 'value');
      LRating := Integer(naCalc.GetValue(j, 'rating'));
      if VarIsNull(LVal) or (LRating < 1) or (LRating > 4) then Continue;
      C.Totals.GradeSum[LRating - 1] := C.Totals.GradeSum[LRating - 1] + Double(LVal) * LE;
      LCritGrade[i][LRating - 1] := Double(LVal) * LE;
      if LRating = C.Coefs[i].Sel then begin
        C.Totals.SumJ := C.Totals.SumJ + Double(LVal) * LE;
        LCritSel[i] := Double(LVal) * LE;
      end;
    end;
  end;

  //специальные коэффициенты: множитель по каждой оценке (сводка "Итоги работы") и фактический (оценка сотрудника)
  LNum := na.Count + 1;
  for LKind := 1 to 2 do begin
    C.KindNum[LKind] := 0;
    LCnt := Round(S.NNum(Q.QLoadValue('select count(*) from w_motivation_special_items where id_job_internal = :ij$i and kind = :k$i',
      [AIdJob, LKind])));
    if LCnt <= 0 then Continue;
    C.KindNum[LKind] := LNum;
    LKindName := S.IIfStr(LKind = 1, 'Культура производства', 'Качество работы');
    LKTxt := 'К' + IntToStr(LNum) + ' «' + LKindName + '»';
    Inc(LNum);
    Q.QLoad('select rating, value from v_w_motivation_spec_rates where id_job_internal = :ij$i and kind = :k$i',
      [AIdJob, LKind], naSp);
    LNoVal := naSp.Count < 4;
    for i := 0 to naSp.Count - 1 do begin
      LRating := Integer(naSp.GetValue(i, 'rating'));
      LVal := naSp.GetValue(i, 'value');
      if VarIsNull(LVal) then LNoVal := True;
      if (LRating >= 1) and (LRating <= 4) and (not VarIsNull(LVal)) then begin
        C.Totals.GradeMul[LRating - 1] := C.Totals.GradeMul[LRating - 1] * Double(LVal);
        LSpecGrade[LKind][LRating - 1] := LSpecGrade[LKind][LRating - 1] * Double(LVal);
      end;
    end;
    //диапазоны итоговых баллов (4 оценки) и множители к премии
    LRow := Q.QLoadValue('select range_state from v_w_motivation_spec_sets_state where kind = :k$i and id_job_internal = :ij$i',
      [LKind, AIdJob]);
    if VarIsNull(LRow) or (S.NNum(LRow) <> 0) then
      JobErr(LKTxt + ': диапазоны итоговых баллов не заданы или некорректны');
    if LNoVal then
      JobErr(LKTxt + ': не заданы множители к премии для всех оценок');
    //оценки позиций ПО ОТДЕЛУ (общие на специальность) введены
    LCnt := Round(S.NNum(Q.QLoadValue('select count(*) from w_motivation_special_items i where i.id_job_internal = :ij$i ' +
      'and i.kind = :k$i and i.is_personal = 0 and not exists (select 1 from w_motivation_special_values v ' +
      'where v.id_item = i.id and v.id_employee = 0 and v.value is not null)', [AIdJob, LKind])));
    if LCnt > 0 then
      JobErr(LKTxt + ': не введены оценки по отделу (позиций: ' + IntToStr(LCnt) + ')');
    if LByEmp then begin
      LRow := Q.QLoadRow('select selected_rate_value, selected_rating, state_name from v_w_motivation_spec_grades ' +
        'where id_employee = :ie$i and kind = :k$i', [AIdEmployee, LKind]);
      if not VarIsNull(LRow[0]) then begin
        C.Totals.FactMul := C.Totals.FactMul * Double(LRow[0]);
        LSpecFact[LKind] := LSpecFact[LKind] * Double(LRow[0]);
      end else if not VarIsNull(LRow[1]) then
        EmpErr(LKTxt + ': для полученной оценки не задан множитель к премии')
      else
        EmpErr(LKTxt + ': ' + S.IIfStr(VarToStr(LRow[2]) = '', 'нет данных по сотруднику', VarToStr(LRow[2])));
    end;
  end;

  //грубые замечания и ЧС: итоговый множитель выставляется ВРУЧНУЮ (по сотруднику, w_motivation_remark_facts),
  //нет значения - 1 в расчёте, но для проверки данных значение должно быть введено (если у должности есть список)
  //два простых запроса вместо одного с двумя подзапросами и разными параметрами (на нём ADO падало с
  //"ошибки во время выполнения многошаговой операции")
  LCntRem := Round(S.NNum(Q.QLoadValue('select count(*) from w_motivation_negative_remarks_for_job where id_job_internal = :ij$i',
    [AIdJob])));
  LCntEm := Round(S.NNum(Q.QLoadValue('select count(*) from w_motivation_w_work_emergencies_for_job where id_job_internal = :ij$i',
    [AIdJob])));
  LHasRemarks := (LCntRem > 0) or (LCntEm > 0);
  C.RemarksNum := 0;
  if LHasRemarks then begin
    C.RemarksNum := LNum;
    LKTxt := 'К' + IntToStr(LNum) + ' «Грубые замечания и ЧС»';
    if LByEmp then begin
      LFactRem := Null;
      LFactEm := Null;
      Q.QLoad('select kind, value from w_motivation_remark_facts where id_employee = :ie$i', [AIdEmployee], naFacts);
      for i := 0 to naFacts.Count - 1 do
        if not VarIsNull(naFacts.GetValue(i, 'value')) then begin
          C.Totals.FactMul := C.Totals.FactMul * Double(naFacts.GetValue(i, 'value'));
          LRemFact := LRemFact * Double(naFacts.GetValue(i, 'value'));
          if Integer(naFacts.GetValue(i, 'kind')) = 1 then LFactRem := naFacts.GetValue(i, 'value');
          if Integer(naFacts.GetValue(i, 'kind')) = 2 then LFactEm := naFacts.GetValue(i, 'value');
        end;
      if (LCntRem > 0) and VarIsNull(LFactRem) then
        EmpErr(LKTxt + ': не введён итоговый множитель грубых замечаний');
      if (LCntEm > 0) and VarIsNull(LFactEm) then
        EmpErr(LKTxt + ': не введён итоговый множитель чрезвычайных ситуаций');
    end;
  end;

  //---- формула ВЗ: хранится по должности (w_motivation_job_formulas), нет сохранённой - стандартная как в Excel:
  //(К1+К2+...)хК<культура>хК<качество>хК<замечания>. Значения К: критерии - "Сумма премии" блока (выбранная оценка),
  //специальные коэффициенты - множитель выбранной оценки сотрудника (нет - 1), замечания/ЧС - итоговый "Факт" (нет - 1)
  LNK := na.Count + Ord(C.KindNum[1] > 0) + Ord(C.KindNum[2] > 0) + Ord(C.RemarksNum > 0);
  SetLength(C.KVars, LNK);
  SetLength(C.KNames, LNK);
  C.KMap := '';
  for i := 0 to na.Count - 1 do begin
    C.KVars[i] := LCritSel[i];
    C.KNames[i] := C.Coefs[i].Name;
    C.KMap := C.KMap + 'К' + IntToStr(i + 1) + ' - ' + C.KNames[i];
    if not VarIsNull(C.Coefs[i].Weight) then
      C.KMap := C.KMap + ' (доля ' + FormatFloat('0.##', Double(C.Coefs[i].Weight) * 100) + '%)';
    C.KMap := C.KMap + ': сумма премии = ' + FormatFloat('0.##', C.KVars[i]) + #13#10;
  end;
  for LKind := 1 to 2 do
    if C.KindNum[LKind] > 0 then begin
      LKi := C.KindNum[LKind] - 1;
      C.KVars[LKi] := LSpecFact[LKind];
      C.KNames[LKi] := S.IIfStr(LKind = 1, 'Культура производства', 'Качество работы');
      C.KMap := C.KMap + 'К' + IntToStr(C.KindNum[LKind]) + ' - ' + C.KNames[LKi] + ': множитель = ' + FormatFloat('0.####', C.KVars[LKi]) + #13#10;
    end;
  if C.RemarksNum > 0 then begin
    LKi := C.RemarksNum - 1;
    C.KVars[LKi] := LRemFact;
    C.KNames[LKi] := 'Грубые замечания и ЧС';
    C.KMap := C.KMap + 'К' + IntToStr(C.RemarksNum) + ' - ' + C.KNames[LKi] + ': итоговый множитель = ' + FormatFloat('0.####', C.KVars[LKi]) + #13#10;
  end;
  if C.KMap = '' then C.KMap := 'У должности нет коэффициентов.';

  C.DefaultF := '';
  if na.Count > 0 then begin
    for i := 1 to na.Count do begin
      if C.DefaultF <> '' then C.DefaultF := C.DefaultF + '+';
      C.DefaultF := C.DefaultF + 'К' + IntToStr(i);
    end;
    if na.Count > 1 then C.DefaultF := '(' + C.DefaultF + ')';
    for LKind := 1 to 2 do
      if C.KindNum[LKind] > 0 then C.DefaultF := C.DefaultF + '*К' + IntToStr(C.KindNum[LKind]);
    if C.RemarksNum > 0 then C.DefaultF := C.DefaultF + '*К' + IntToStr(C.RemarksNum);
  end;

  C.StoredF := '';
  LStoredRow := Null;
  try
    LStoredRow := Q.QLoadRow('select formula, k_count from w_motivation_job_formulas where id_job_internal = :ij$i', [AIdJob]);
    C.StoredF := Trim(VarToStr(LStoredRow[0]));
  except
    C.StoredF := '';
    LStoredRow := Null;
  end;
  C.Totals.FormulaIsDefault := C.StoredF = '';
  if C.Totals.FormulaIsDefault then C.FormulaText := C.DefaultF else C.FormulaText := C.StoredF;
  C.Totals.FormulaText := C.FormulaText;
  C.Totals.FormulaMsg := '';
  C.Totals.FormulaSev := 0;
  C.Totals.FormulaOk := True;
  C.Totals.FinalPrem := 0;
  for LGi := 0 to 3 do C.Totals.GradePrem[LGi] := 0;
  if C.FormulaText <> '' then begin
    C.Totals.FormulaSev := MotFormulaCheck(C.FormulaText, C.KVars, C.KNames, LFVal, LFMsg);
    C.Totals.FormulaOk := C.Totals.FormulaSev < 2;
    C.Totals.FinalPrem := LFVal;
    C.Totals.FormulaMsg := LFMsg;
    //то же для сводки "Итоги работы": по всем критериям одна оценка (К замечаний/ЧС = 1)
    for LGi := 0 to 3 do begin
      SetLength(LGVars, LNK);
      for i := 0 to na.Count - 1 do
        LGVars[i] := LCritGrade[i][LGi];
      for LKind := 1 to 2 do
        if C.KindNum[LKind] > 0 then LGVars[C.KindNum[LKind] - 1] := LSpecGrade[LKind][LGi];
      if C.RemarksNum > 0 then LGVars[C.RemarksNum - 1] := 1;
      MotFormulaCheck(C.FormulaText, LGVars, C.KNames, LFVal, LFMsg);
      C.Totals.GradePrem[LGi] := LFVal;
    end;
    //состав коэффициентов изменился с момента сохранения формулы - номера К могли сдвинуться (позиционные)
    if (not C.Totals.FormulaIsDefault) and (not VarIsNull(LStoredRow)) and (not VarIsNull(LStoredRow[1])) and
       (Integer(LStoredRow[1]) <> LNK) then begin
      if C.Totals.FormulaMsg <> '' then C.Totals.FormulaMsg := C.Totals.FormulaMsg + #13#10;
      C.Totals.FormulaMsg := C.Totals.FormulaMsg + 'Состав коэффициентов должности изменился с момента сохранения формулы (было К1..К' +
        IntToStr(Integer(LStoredRow[1])) + ', сейчас К1..К' + IntToStr(LNK) + ') - номера К позиционные и могли сдвинуться, проверьте формулу.';
      if C.Totals.FormulaSev = 0 then C.Totals.FormulaSev := 1;
    end;
    //любое замечание к формуле (в т.ч. не используются все К) - данные не считаются корректными
    if C.Totals.FormulaSev <> 0 then
      JobErr('Формула ВЗ: ' + C.Totals.FormulaMsg);
  end;

  //плановая премия нужна для расчёта премии сотрудника
  if LByEmp and VarIsNull(C.Totals.Premium) then
    EmpErr('Нет плановой премии (стимулирующей части) за прошлый месяц в «Плановых начислениях по должностям»');

  C.PremiumOk := (not VarIsNull(C.Totals.Premium)) and (C.FormulaText <> '') and C.Totals.FormulaOk;
  if C.Totals.TurvPlan > 0 then
    C.PremiumTurv := C.Totals.FinalPrem * C.Totals.TurvFact / C.Totals.TurvPlan
  else
    C.PremiumTurv := 0;
  C.JobOk := C.JobMsg = '';
  C.EmpOk := C.EmpMsg = '';
end;

//---------------------------------------------------------------------------------------------------------------
//состояние блокировки, пересчёт и результаты

function MotLoadState: TMotState;
var
  LRow: Variant;
begin
  Result := Default(TMotState);
  Result.LockDt := Null;
  Result.FullCalcDt := Null;
  try
    LRow := Q.QLoadRow('select is_locked, lock_dt, lock_user_name, lock_comm, is_dirty, full_calc_dt, emp_total, emp_valid ' +
      'from v_w_motivation_state', []);
  except
    Exit;        //вью ещё нет в БД (не выполнен SqlUpdater)
  end;
  if VarIsNull(LRow[0]) then Exit;
  Result.Loaded := True;
  Result.IsLocked := S.NNum(LRow[0]) = 1;
  Result.LockDt := LRow[1];
  Result.LockUser := VarToStr(LRow[2]);
  Result.LockComm := VarToStr(LRow[3]);
  Result.IsDirty := S.NNum(LRow[4]) = 1;
  Result.FullCalcDt := LRow[5];
  Result.EmpTotal := Round(S.NNum(LRow[6]));
  Result.EmpValid := Round(S.NNum(LRow[7]));
end;

function MotIsLocked: Boolean;
begin
  Result := MotLoadState.IsLocked;
end;

function MotBuildStateText(const C: TMotCalc): string;
//текст причин некорректности для БД (до 1900 символов)
begin
  Result := '';
  if C.JobMsg <> '' then
    Result := 'ДОЛЖНОСТЬ:'#13#10 + C.JobMsg;
  if C.EmpMsg <> '' then begin
    if Result <> '' then Result := Result + #13#10;
    Result := Result + 'СОТРУДНИК:'#13#10 + C.EmpMsg;
  end;
  if Length(Result) > 1900 then
    Result := Copy(Result, 1, 1897) + '...';
end;

procedure MotSaveEmployeeResult(AIdJob, AIdEmployee: Integer);
//считает сотрудника и сохраняет результат (p_w_motivation_result_save). Ошибка расчёта не прерывает пересчёт - она
//сохраняется как причина некорректности
const
  cSaveParams = 'p_id_employee$i;p_id_job_internal$i;p_user_id$i;p_job_ok$i;p_emp_ok$i;p_state_text$s;p_formula$s;' +
    'p_fixed_pay$f;p_variable_pay$f;p_premium$f;p_turv_plan$f;p_turv_fact$f;p_premium_turv$f';
var
  C: TMotCalc;
  LSal, LPrem, LPremVal, LPremTurv: Variant;
  LSrcTxt: string;
begin
  try
    MotLoadPlannedPay(AIdJob, AIdEmployee, LSal, LPrem, LSrcTxt);
    MotCalcJob(AIdJob, AIdEmployee, LSal, LPrem, C);
    if C.PremiumOk then begin
      LPremVal := C.Totals.FinalPrem;
      LPremTurv := C.PremiumTurv;
    end else begin
      LPremVal := Null;
      LPremTurv := Null;
    end;
    Q.QCallStoredProc('p_w_motivation_result_save', cSaveParams,
      [AIdEmployee, AIdJob, User.GetId, Ord(C.JobOk), Ord(C.EmpOk), MotBuildStateText(C), C.FormulaText,
       LSal, LPrem, LPremVal, C.Totals.TurvPlan, C.Totals.TurvFact, LPremTurv]);
  except
    on E: Exception do begin
      Q.QCallStoredProc('p_w_motivation_result_save', cSaveParams,
        [AIdEmployee, AIdJob, User.GetId, 0, 0, Copy('Ошибка расчёта: ' + E.Message, 1, 1900), '', Null, Null, Null, Null, Null, Null]);
    end;
  end;
end;

function MotRecalcEmployee(AIdEmployee: Integer): Boolean;
//пересчёт одного сотрудника и состояния его должности; False - сотрудника нет среди работающих (его результат удалён)
var
  LRow: Variant;
  LIdJob: Integer;
  C0: TMotCalc;
begin
  LRow := Q.QLoadRow('select id_job_internal from v_w_motivation_employees_by_job where id = :id$i', [AIdEmployee]);
  if VarIsNull(LRow[0]) then begin
    Q.QCallStoredProc('p_w_motivation_calc_done', 'p_id_job_internal$i;p_full$i', [Null, 0]);
    Result := False;
    Exit;
  end;
  LIdJob := Integer(LRow[0]);
  MotSaveEmployeeResult(LIdJob, AIdEmployee);
  //состояние должности по общим данным
  try
    MotCalcJob(LIdJob, Null, Null, Null, C0);
  except
    on E: Exception do begin
      C0 := Default(TMotCalc);
      C0.JobMsg := 'Ошибка расчёта: ' + E.Message;
    end;
  end;
  Q.QCallStoredProc('p_w_motivation_job_state_save', 'p_id_job_internal$i;p_user_id$i;p_job_ok$i;p_state_text$s',
    [LIdJob, User.GetId, Ord(C0.JobOk), MotBuildStateText(C0)]);
  Result := True;
end;

function MotRecalcJob(AIdJob: Integer; AProgress: TMotProgress): Integer;
//пересчёт всех работающих сотрудников внутренней должности и её состояния; возвращает число сотрудников
var
  naEmp: TNamedArr;
  C0: TMotCalc;
  i: Integer;
begin
  Q.QLoad('select id from v_w_motivation_employees_by_job where id_job_internal = :ij$i order by name', [AIdJob], naEmp);
  for i := 0 to naEmp.Count - 1 do begin
    if Assigned(AProgress) then
      AProgress('Сотрудник ' + IntToStr(i + 1) + ' из ' + IntToStr(naEmp.Count), i + 1, naEmp.Count);
    MotSaveEmployeeResult(AIdJob, Integer(naEmp.GetValue(i, 'id')));
  end;
  try
    MotCalcJob(AIdJob, Null, Null, Null, C0);
  except
    on E: Exception do begin
      C0 := Default(TMotCalc);
      C0.JobMsg := 'Ошибка расчёта: ' + E.Message;
    end;
  end;
  Q.QCallStoredProc('p_w_motivation_calc_done', 'p_id_job_internal$i;p_full$i', [AIdJob, 0]);
  Q.QCallStoredProc('p_w_motivation_job_state_save', 'p_id_job_internal$i;p_user_id$i;p_job_ok$i;p_state_text$s',
    [AIdJob, User.GetId, Ord(C0.JobOk), MotBuildStateText(C0)]);
  Result := naEmp.Count;
end;

function MotRecalcAll(AProgress: TMotProgress): Integer;
//полный пересчёт: все должности, по которым есть данные мотивации (MotLoadJobs); возвращает число сотрудников
var
  naJobs: TNamedArr;
  i: Integer;
begin
  Result := 0;
  MotLoadJobs(naJobs);
  for i := 0 to naJobs.Count - 1 do begin
    if Assigned(AProgress) then
      AProgress('Должность: ' + VarToStr(naJobs.GetValue(i, 'name')), i + 1, naJobs.Count);
    Result := Result + MotRecalcJob(Integer(naJobs.GetValue(i, 'id')), nil);
  end;
  Q.QCallStoredProc('p_w_motivation_calc_done', 'p_id_job_internal$i;p_full$i', [Null, 1]);
end;

function MotGetEmployeeResult(AIdEmployee: Integer; ARecalcIfNeeded: Boolean): TMotEmpResult;
//статус валидности и премия сотрудника по всем введённым данным (w_motivation_results). ARecalcIfNeeded: если
//результата нет или он устарел (данные менялись после расчёта) - сначала пересчитывается этот сотрудник. Использовать
//PremiumTurv (премия к начислению с учётом ТУРВ) можно только при IsValid = True
  function LoadRow: TMotEmpResult;
  var
    LRow: Variant;
  begin
    Result := Default(TMotEmpResult);
    Result.FixedPay := Null;
    Result.VariablePay := Null;
    Result.Premium := Null;
    Result.TurvPlan := Null;
    Result.TurvFact := Null;
    Result.PremiumTurv := Null;
    Result.DtCalc := Null;
    LRow := Q.QLoadRow('select is_valid, is_actual, job_ok, emp_ok, id_job_internal, state_text, formula, fixed_pay, ' +
      'variable_pay, premium, turv_plan, turv_fact, premium_turv, dt_calc from v_w_motivation_results where id_employee = :ie$i',
      [AIdEmployee]);
    if VarIsNull(LRow[0]) then Exit;
    Result.Found := True;
    Result.IsValid := S.NNum(LRow[0]) = 1;
    Result.IsActual := S.NNum(LRow[1]) = 1;
    Result.JobOk := S.NNum(LRow[2]) = 1;
    Result.EmpOk := S.NNum(LRow[3]) = 1;
    Result.IdJob := Round(S.NNum(LRow[4]));
    Result.StateText := VarToStr(LRow[5]);
    Result.Formula := VarToStr(LRow[6]);
    Result.FixedPay := LRow[7];
    Result.VariablePay := LRow[8];
    Result.Premium := LRow[9];
    Result.TurvPlan := LRow[10];
    Result.TurvFact := LRow[11];
    Result.PremiumTurv := LRow[12];
    Result.DtCalc := LRow[13];
  end;

begin
  Result := LoadRow;
  if ARecalcIfNeeded and ((not Result.Found) or (not Result.IsActual)) then begin
    MotRecalcEmployee(AIdEmployee);
    Result := LoadRow;
  end;
end;

end.
