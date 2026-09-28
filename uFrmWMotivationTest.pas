{
Мотивация - Тест (28.09.2026, см. !алгоритмы.txt) - экран для разработчика, первая версия отображения
мотивации по должности/сотруднику панелями-"сетками" (см. обсуждение с пользователем и осмотр образцов
Excel в Test/Мотивация/).

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
(selected_rating) только для НЕперсональных коэффициентов. Расчётная сумма доли вознаграждения
считается от тестовой суммы премии, вводимой вручную слева (edtPremium) - реальной начисленной
премии сотрудника в этой версии еще нет, см. "Итого не проверено".

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
  uString, uNamedArr, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uMotivationGridPanel
  ;

type
  TFrmWMotivationTest = class(TFrmBasicMdi)
  private
    pnlLeft, pnlLeftBottom, pnlPremium: TPanel;
    rbgMode: TRadioGroup;
    lbxJobs, lbxEmployees: TListBox;
    btnAddCoeff: TButton;
    lblPremium: TLabel;
    edtPremium: TEdit;
    lblSalary: TLabel;
    edtSalary: TEdit;
    sbxClient: TScrollBox;
    FBlocks: array of TMotGridData;
    FBlockLinkIds: array of Integer;
    FBlockBoxes: array of TPaintBox;
    FNextTop: Integer;
    function  Prepare: Boolean; override;
    function  GetSelectedJobId: Variant;
    function  GetTestPremiumBase: Variant;
    function  GetTestSalaryBase: Variant;
    procedure PopulateJobsList;
    procedure PopulateEmployeesList(AIdJobInternal: Variant);
    procedure ClearBlocks;
    procedure AddBlock(const AData: TMotGridData; ALinkId: Integer);
    procedure RenderJob(AIdJobInternal, AIdEmployee: Variant);
    procedure DoRender;
    procedure DoAddCoefficient;
    procedure RbgModeClick(Sender: TObject);
    procedure LbxJobsClick(Sender: TObject);
    procedure LbxEmployeesClick(Sender: TObject);
    procedure BtnAddCoeffClick(Sender: TObject);
    procedure EdtPremiumChange(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure PaintBoxDblClick(Sender: TObject);
  public
  end;

var
  FrmWMotivationTest: TFrmWMotivationTest;

implementation

uses
  uWindows, uFrmBasicInput
  ;

{$R *.dfm}

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
  LFrom := S.IIfStr(VarIsNull(ARangeFrom), '', FormatFloat('0.##', ARangeFrom));
  LTo := S.IIfStr(VarIsNull(ARangeTo), '', FormatFloat('0.##', ARangeTo));
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

function BuildSalaryHeaderBlock(const AJobName: string; ASalaryBase, APremiumBase: Variant;
  const AGradeSum: array of Variant; ACoeffCount: Integer): TMotGridData;
//"шапка" по образцу Excel-файлов (Test/Мотивация/, лист "Расчёт", строки 1-16) - см. обсуждение с
//пользователем 28.09.2026: месяц/должность/формула, блок "Зарплата на руки" (Оклад-пост.часть/
//Премия-расч.часть - тестовые значения слева, см. GetTestSalaryBase/GetTestPremiumBase), сводная
//таблица "Итоги работы" по 4 оценкам (премия по каждой оценке = сумма по всем критериям должности
//вида вес x тестовая премия x коэффициент этой оценки - см. v_w_motivation_coefficients_rates.value,
//расчёт в RenderJob) и заготовка "Итоговое вознаграждение"/учёт рабочего времени (ТУРВ) - эти два
//пока не считаются (нет ни хранения фактически выбранных оценок по сотруднику, ни данных по
//отработанному времени - см. "Итого не проверено" в заголовке модуля), показаны как заготовка ячеек
//с прочерком, чтобы сразу было видно расположение будущих значений
var
  LFormula, LMonth: string;
  k: Integer;
  LD3: Variant;

  function FmtOrDash(AValue: Variant): string;
  begin
    if VarIsNull(AValue) then Result := '-' else Result := FormatFloat('0.##', AValue);
  end;

  function GradeCell(AIdx: Integer): string;
  begin
    if VarIsNull(APremiumBase) then Result := '-' else Result := FormatFloat('0.##', AGradeSum[AIdx]);
  end;

begin
  LMonth := cMotMonthNames[MonthOf(Date)];

  LFormula := '';
  for k := 1 to ACoeffCount do begin
    if LFormula <> '' then LFormula := LFormula + ' + ';
    LFormula := LFormula + 'К' + IntToStr(k);
  end;
  if LFormula = '' then LFormula := 'нет критериев';
  LFormula := 'Формула ВЗ = ' + LFormula;

  if VarIsNull(ASalaryBase) or VarIsNull(APremiumBase) then
    LD3 := Null
  else
    LD3 := ASalaryBase + APremiumBase; //D3 = H3 + D5, D5 = H4 x 100% = H4

  MotGridSetSize(Result, [35, 150, 185, 135, 65, 65, 65, 135, 135, 65],
    [47, 14, 34, 34, 34, 14, 34, 34, 34, 34, 33, 14, 34, 54, 54, 54]);

  //строка 0 - месяц / должность / формула (A1:B1 / C1:E1 / F1:J1 в образце)
  MotGridSetCell(Result, 0, 0, MotCell(LMonth, 2, 1, True, clNone, mghCenter, clBlack, True, 18));
  MotGridSetCell(Result, 0, 2, MotCell(AJobName, 3, 1, True, clNone, mghCenter, clBlack, True, 14));
  MotGridSetCell(Result, 0, 5, MotCell(LFormula, 5, 1, True, clNone, mghCenter, clBlack, True, 14));

  //строка 2 - "Зарплата на руки" (A3:C3 / D3:E3 / F3:G3 / H3)
  MotGridSetCell(Result, 2, 0, MotCell('Зарплата на руки', 3, 1, True));
  MotGridSetCell(Result, 2, 3, MotCell(FmtOrDash(LD3), 2, 1, True, cMotYellowFill, mghCenter));
  MotGridSetCell(Result, 2, 5, MotCell('Оклад - постоянная часть', 2, 1, True));
  MotGridSetCell(Result, 2, 7, MotCell(FmtOrDash(ASalaryBase), 1, 1, True, cMotSelectedFill, mghCenter));

  //строка 3 - "Утверждённый размер премии на период" (период всегда 100% - пророации по периоду в
  //этой версии нет)
  MotGridSetCell(Result, 3, 0, MotCell('Утверждённый размер премии на период', 3, 1, True));
  MotGridSetCell(Result, 3, 3, MotCell('100%', 2, 1, True, cMotYellowFill, mghCenter));
  MotGridSetCell(Result, 3, 5, MotCell('Премия - расчётная часть', 2, 1, True));
  MotGridSetCell(Result, 3, 7, MotCell(FmtOrDash(APremiumBase), 1, 1, True, cMotSelectedFill, mghCenter));

  //строка 4 - "Премия - фактическая часть" = расчётная часть x 100%
  MotGridSetCell(Result, 4, 0, MotCell('Премия - фактическая часть', 3, 1, True));
  MotGridSetCell(Result, 4, 3, MotCell(FmtOrDash(APremiumBase), 2, 1, True, cMotYellowFill, mghCenter));

  //строка 6 - шапка "Итоги работы": если бы по всем критериям была получена одна и та же оценка
  MotGridSetCell(Result, 6, 0, MotCell('Итоги работы', 3, 1, True, cMotHeaderFill, mghCenter));
  MotGridSetCell(Result, 6, 3, MotCell('Оклад', 1, 1, True, cMotHeaderFill, mghCenter));
  MotGridSetCell(Result, 6, 4, MotCell('Премия', 1, 1, True, cMotHeaderFill, mghCenter));
  MotGridSetCell(Result, 6, 5, MotCell('На руки', 1, 1, True, cMotHeaderFill, mghCenter));

  MotGridSetCell(Result, 7, 0, MotCell('"ОТЛИЧНО"', 3, 1, True));
  MotGridSetCell(Result, 7, 3, MotCell(FmtOrDash(ASalaryBase), 1, 1, False, clNone, mghCenter));
  MotGridSetCell(Result, 7, 4, MotCell(GradeCell(0), 1, 1, False, clNone, mghCenter));
  MotGridSetCell(Result, 7, 5, MotCell('-', 1, 1, False, clNone, mghCenter));

  MotGridSetCell(Result, 8, 0, MotCell('"ХОРОШО"', 3, 1, True));
  MotGridSetCell(Result, 8, 3, MotCell(FmtOrDash(ASalaryBase), 1, 1, False, clNone, mghCenter));
  MotGridSetCell(Result, 8, 4, MotCell(GradeCell(1), 1, 1, False, clNone, mghCenter));
  MotGridSetCell(Result, 8, 5, MotCell('-', 1, 1, False, clNone, mghCenter));

  MotGridSetCell(Result, 9, 0, MotCell('"УДОВЛЕТВОРИТЕЛЬНО"', 3, 1, True));
  MotGridSetCell(Result, 9, 3, MotCell(FmtOrDash(ASalaryBase), 1, 1, False, clNone, mghCenter));
  MotGridSetCell(Result, 9, 4, MotCell(GradeCell(2), 1, 1, False, clNone, mghCenter));
  MotGridSetCell(Result, 9, 5, MotCell('-', 1, 1, False, clNone, mghCenter));

  MotGridSetCell(Result, 10, 0, MotCell('"ЗОНА РОСТА"', 3, 1, True));
  MotGridSetCell(Result, 10, 3, MotCell(FmtOrDash(ASalaryBase), 1, 1, False, clNone, mghCenter));
  MotGridSetCell(Result, 10, 4, MotCell(GradeCell(3), 1, 1, False, clNone, mghCenter));
  MotGridSetCell(Result, 10, 5, MotCell('-', 1, 1, False, clNone, mghCenter));

  //строка 12 - шапка "Итоговое вознаграждение" / учёт рабочего времени - пока заготовка
  MotGridSetCell(Result, 12, 0, MotCell('Итоговое вознаграждение', 3, 1, True, cMotHeaderFill, mghCenter));
  MotGridSetCell(Result, 12, 3, MotCell('Оклад', 1, 1, True, cMotHeaderFill, mghCenter));
  MotGridSetCell(Result, 12, 4, MotCell('Премия', 1, 1, True, cMotHeaderFill, mghCenter));
  MotGridSetCell(Result, 12, 5, MotCell('Итого', 1, 1, True, cMotHeaderFill, mghCenter));
  MotGridSetCell(Result, 12, 6, MotCell('Учёт рабочего времени', 4, 1, True, cMotHeaderFill, mghCenter));

  MotGridSetCell(Result, 13, 0, MotCell('Зарплата за период при отработке нормы часов по ТУРВ', 3, 1));
  MotGridSetCell(Result, 13, 3, MotCell('-', 1, 1, False, clNone, mghCenter));
  MotGridSetCell(Result, 13, 4, MotCell('-', 1, 1, False, clNone, mghCenter));
  MotGridSetCell(Result, 13, 5, MotCell('-', 1, 1, False, clNone, mghCenter));
  MotGridSetCell(Result, 13, 6, MotCell('План ТУРВ (рабочих часов в период)', 3, 1));
  MotGridSetCell(Result, 13, 9, MotCell('-', 1, 1, False, cMotSelectedFill, mghCenter));

  MotGridSetCell(Result, 14, 0, MotCell('Зарплата с учётом отработанных часов по ТУРВ на руки', 3, 1));
  MotGridSetCell(Result, 14, 3, MotCell('-', 1, 1, False, clNone, mghCenter));
  MotGridSetCell(Result, 14, 4, MotCell('-', 1, 1, False, clNone, mghCenter));
  MotGridSetCell(Result, 14, 5, MotCell('-', 1, 1, False, cMotYellowFill, mghCenter));
  MotGridSetCell(Result, 14, 6, MotCell('Факт ТУРВ (рабочих часов в период)', 3, 1));
  MotGridSetCell(Result, 14, 9, MotCell('-', 1, 1, False, cMotSelectedFill, mghCenter));

  MotGridSetCell(Result, 15, 0, MotCell(
    'Оклад и Премия - фактическая часть считаются от тестовых значений, введённых слева. В таблице ' +
    '"Итоги работы" колонка "Премия" уже считается по всем текущим критериям должности (вес x тестовая ' +
    'премия x коэффициент оценки); колонка "На руки" и весь блок "Итоговое вознаграждение"/учёт рабочего ' +
    'времени - заготовка расположения ячеек, расчёт по фактически выбранным оценкам сотрудника и ' +
    'отработанному времени будет добавлен позже.', 10, 1));
end;

function TFrmWMotivationTest.Prepare: Boolean;
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
    '"Итоги работы" по 4 оценкам, заготовка "Итоговое вознаграждение"/учёт рабочего времени - от'#13#10 +
    'тестовых оклада и премии слева), затем панели критериев, похожие по виду на существующие'#13#10 +
    'Excel-файлы расчёта мотивации (объединённые ячейки - описание слева, доля вознаграждения'#13#10 +
    'в проценте и расчётной сумме). Расчётные суммы считаются от тестовых оклада/премии, введённых'#13#10 +
    'в поля слева - реальных значений по сотруднику пока нет.'#13#10 +
    'Двойной клик по панели критерия - отвязать его от должности (в общем справочнике коэффициент'#13#10 +
    'останется). Кнопка "Добавить критерий..." - привязать коэффициент из общего справочника к'#13#10 +
    'выбранной должности с указанием доли вознаграждения.'
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
  pnlPremium.Height := 88;
  pnlPremium.BevelOuter := bvNone;

  lblPremium := TLabel.Create(Self);
  lblPremium.Parent := pnlPremium;
  lblPremium.Left := 4;
  lblPremium.Top := 2;
  lblPremium.Caption := 'Премия для расчёта (тест):';

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
  lblSalary.Caption := 'Оклад для расчёта (тест):';

  edtSalary := TEdit.Create(Self);
  edtSalary.Parent := pnlPremium;
  edtSalary.Left := 4;
  edtSalary.Top := 60;
  edtSalary.Width := 240;
  edtSalary.Text := '';
  edtSalary.OnChange := EdtPremiumChange;

  pnlLeftBottom := TPanel.Create(Self);
  pnlLeftBottom.Parent := pnlLeft;
  pnlLeftBottom.Align := alBottom;
  pnlLeftBottom.Height := 232;
  pnlLeftBottom.BevelOuter := bvNone;

  btnAddCoeff := TButton.Create(Self);
  btnAddCoeff.Parent := pnlLeftBottom;
  btnAddCoeff.Align := alTop;
  btnAddCoeff.Height := 28;
  btnAddCoeff.Caption := 'Добавить критерий...';
  btnAddCoeff.OnClick := BtnAddCoeffClick;

  lbxEmployees := TListBox.Create(Self);
  lbxEmployees.Parent := pnlLeftBottom;
  lbxEmployees.Align := alClient;
  lbxEmployees.Visible := False;
  lbxEmployees.OnClick := LbxEmployeesClick;

  lbxJobs := TListBox.Create(Self);
  lbxJobs.Parent := pnlLeft;
  lbxJobs.Align := alClient;
  lbxJobs.OnClick := LbxJobsClick;

  sbxClient := TScrollBox.Create(Self);
  sbxClient.Parent := pnlFrmClient;
  sbxClient.Align := alClient;
  sbxClient.BevelOuter := bvNone;
  sbxClient.Color := clWhite;

  FNextTop := 8;
  PopulateJobsList;

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
  Q.QLoad('select id, name from w_jobs_internal where active = 1 order by name', [], na);
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
  Q.QLoad('select id, name from v_w_motivation_employees_by_job where id_job_internal = :id$i order by name',
    [AIdJobInternal], na);
  for i := 0 to na.Count - 1 do
    lbxEmployees.Items.AddObject(na.GetValue(i, 'name'), TObject(Integer(na.GetValue(i, 'id'))));
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
  FNextTop := 8;
end;

procedure TFrmWMotivationTest.AddBlock(const AData: TMotGridData; ALinkId: Integer);
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

  PB := TPaintBox.Create(Self);
  PB.Parent := sbxClient;
  PB.Left := 8;
  PB.Top := FNextTop;
  PB.Width := MotGridWidth(AData);
  PB.Height := MotGridHeight(AData);
  PB.Tag := Idx;
  PB.OnPaint := PaintBoxPaint;
  PB.OnDblClick := PaintBoxDblClick;
  FBlockBoxes[Idx] := PB;

  FNextTop := FNextTop + PB.Height + 12;
end;

procedure TFrmWMotivationTest.PaintBoxPaint(Sender: TObject);
begin
  DrawMotGridPanel(TPaintBox(Sender).Canvas, 0, 0, FBlocks[TPaintBox(Sender).Tag]);
end;

procedure TFrmWMotivationTest.PaintBoxDblClick(Sender: TObject);
var
  LinkId: Integer;
begin
  LinkId := FBlockLinkIds[TPaintBox(Sender).Tag];
  if LinkId < 0 then Exit;
  if MyQuestionMessage('Отвязать этот коэффициент от должности?'#13#10'(сам коэффициент в общем справочнике останется)') <> mrYes then Exit;
  Q.QExecSql('delete from w_motivation_coefficient_for_job where id = :id$i', [LinkId], False);
  DoRender;
end;

procedure TFrmWMotivationTest.RenderJob(AIdJobInternal, AIdEmployee: Variant);
var
  LJobName, LEmployeeName, LTitle, LDescription: string;
  na, naRates: TNamedArr;
  i, j: Integer;
  Data: TMotGridData;
  LWeight, LPremiumBase, LSalaryBase, LSum: Variant;
  LGradeSum: array[0..3] of Variant;
  LFill: TColor;
begin
  ClearBlocks;
  if VarIsNull(AIdJobInternal) then Exit;

  LJobName := VarToStr(Q.QLoadValue('select name from w_jobs_internal where id = :id$i', [AIdJobInternal]));
  LEmployeeName := '';
  if not VarIsNull(AIdEmployee) then
    LEmployeeName := VarToStr(Q.QLoadValue('select name from v_w_motivation_employees_by_job where id = :id$i', [AIdEmployee]));

  //блок заголовка
  if LEmployeeName <> '' then
    MotGridSetSize(Data, [760], [30, 26])
  else
    MotGridSetSize(Data, [760], [30]);
  MotGridSetCell(Data, 0, 0, MotCell('Мотивация: ' + LJobName, 1, 1, True, cMotTitleFill));
  if LEmployeeName <> '' then
    MotGridSetCell(Data, 1, 0, MotCell('Сотрудник: ' + LEmployeeName));
  AddBlock(Data, -1);

  LSalaryBase := GetTestSalaryBase;
  LPremiumBase := GetTestPremiumBase;

  //"шапка" по образцу Excel (BuildSalaryHeaderBlock) - сводка "Итоги работы" по 4 оценкам считается
  //здесь заранее отдельным проходом по всем критериям должности (нужны все 4 значения по каждому
  //критерию, а не только по выбранной оценке, как в панелях критериев ниже)
  for j := 0 to 3 do LGradeSum[j] := 0;
  Q.QLoad('select id_coefficient, weight from v_w_motivation_coefficient_for_job ' +
    'where id_job_internal = :id_job_internal$i', [AIdJobInternal], na);
  if not VarIsNull(LPremiumBase) then
    for i := 0 to na.Count - 1 do begin
      LWeight := na.GetValue(i, 'weight');
      if VarIsNull(LWeight) then Continue;
      Q.QLoad('select rating, value from v_w_motivation_coefficients_rates ' +
        'where id_coefficient = :id$i order by rating', [na.GetValue(i, 'id_coefficient')], naRates);
      for j := 0 to Min(naRates.Count, 4) - 1 do
        if not VarIsNull(naRates.GetValue(j, 'value')) then
          LGradeSum[j] := LGradeSum[j] + LWeight * LPremiumBase * naRates.GetValue(j, 'value');
    end;
  AddBlock(BuildSalaryHeaderBlock(LJobName, LSalaryBase, LPremiumBase, LGradeSum, na.Count), -1);

  Q.QLoad('select id, id_coefficient, weight, name, description, is_personal ' +
    'from v_w_motivation_coefficient_for_job where id_job_internal = :id_job_internal$i order by pos',
    [AIdJobInternal], na);

  for i := 0 to na.Count - 1 do begin
    LTitle := VarToStr(na.GetValue(i, 'name'));
    if na.GetValue(i, 'is_personal') = 1 then
      LTitle := LTitle + '  [персональный]';
    LDescription := VarToStr(na.GetValue(i, 'description'));
    LWeight := na.GetValue(i, 'weight');

    Q.QLoad('select rating, rating_name, value, range_from, range_to, is_outside_range, comm, is_selected ' +
      'from v_w_motivation_coefficients_rates where id_coefficient = :id$i order by rating',
      [na.GetValue(i, 'id_coefficient')], naRates);

    //7 колонок: Описание | Доля возн.,% | Доля возн.,сумма | Оценка | Диапазон показателя |
    //Коэф-нт премии | Комментарий - описание и обе ячейки "доли вознаграждения" объединены по
    //вертикали (как в образцах Excel - B19:C23/D20:D23/E20:E23 в "Мастер 17 08.xlsx"): описание -
    //на всю высоту блока (шапка колонок + 4 строки оценок), доля вознаграждения - на 4 строки
    //оценок (см. обсуждение с пользователем 28.09.2026)
    MotGridSetSize(Data, [260, 90, 110, 130, 190, 110, 220], [32, 30, 28, 28, 28, 28]);
    MotGridSetCell(Data, 0, 0, MotCell(LTitle, 7, 1, True, cMotTitleFill));

    MotGridSetCell(Data, 1, 0, MotCell(LDescription, 1, 5));
    MotGridSetCell(Data, 1, 1, MotCell('Доля вознаграждения', 2, 1, True, cMotHeaderFill, mghCenter));
    MotGridSetCell(Data, 1, 3, MotCell('Оценка', 1, 1, True, cMotHeaderFill, mghCenter));
    MotGridSetCell(Data, 1, 4, MotCell('Диапазон показателя', 1, 1, True, cMotHeaderFill, mghCenter));
    MotGridSetCell(Data, 1, 5, MotCell('Коэффициент премии', 1, 1, True, cMotHeaderFill, mghCenter));
    MotGridSetCell(Data, 1, 6, MotCell('Комментарий', 1, 1, True, cMotHeaderFill, mghCenter));

    //доля вознаграждения, % (D20:D23 в образце)
    if VarIsNull(LWeight) then
      MotGridSetCell(Data, 2, 1, MotCell('', 1, 4))
    else
      MotGridSetCell(Data, 2, 1, MotCell(FormatFloat('0.##', LWeight * 100) + '%', 1, 4, True, clNone, mghCenter, clBlack, True, 16));

    //доля вознаграждения, расчётная сумма = вес * тестовая премия слева (E20:E23 в образце) -
    //пока считается от введённой вручную тестовой суммы, не от реальной начисленной премии
    //сотрудника - см. заголовок модуля про "Итого не проверено"
    if VarIsNull(LWeight) or VarIsNull(LPremiumBase) then
      MotGridSetCell(Data, 2, 2, MotCell('-', 1, 4, False, clNone, mghCenter))
    else begin
      LSum := LWeight * LPremiumBase;
      MotGridSetCell(Data, 2, 2, MotCell(FormatFloat('0.##', LSum), 1, 4, False, clNone, mghCenter));
    end;

    for j := 0 to naRates.Count - 1 do begin
      LFill := clNone;
      //подсветка выбранной оценки - только для НЕперсональных коэффициентов (для персональных
      //selected_rating на этом экране пока не задаётся - хранение значений по сотруднику еще не
      //реализовано, см. заголовок модуля)
      if (na.GetValue(i, 'is_personal') <> 1) and (naRates.GetValue(j, 'is_selected') = 1) then
        LFill := cMotSelectedFill;
      MotGridSetCell(Data, 2 + j, 3, MotCell(VarToStr(naRates.GetValue(j, 'rating_name')), 1, 1, False, LFill));
      MotGridSetCell(Data, 2 + j, 4, MotCell(
        FormatMotRange(naRates.GetValue(j, 'range_from'), naRates.GetValue(j, 'range_to'), naRates.GetValue(j, 'is_outside_range')),
        1, 1, False, LFill, mghCenter));
      MotGridSetCell(Data, 2 + j, 5, MotCell(
        S.IIfStr(VarIsNull(naRates.GetValue(j, 'value')), '', FormatFloat('0.###', naRates.GetValue(j, 'value'))),
        1, 1, False, LFill, mghCenter));
      MotGridSetCell(Data, 2 + j, 6, MotCell(VarToStr(naRates.GetValue(j, 'comm')), 1, 1, False, LFill));
    end;

    AddBlock(Data, na.GetValue(i, 'id'));
  end;

  if na.Count = 0 then begin
    MotGridSetSize(Data, [760], [26]);
    MotGridSetCell(Data, 0, 0, MotCell('К этой должности пока не привязано ни одного коэффициента - кнопка "Добавить критерий..." слева.'));
    AddBlock(Data, -1);
  end;
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
end;

procedure TFrmWMotivationTest.DoAddCoefficient;
var
  LIdJob: Variant;
  na: TNamedArr;
  Names, Ids: TVarDynArray;
  va: TVarDynArray;
  i: Integer;
  LIdCoeff, LNewPos: Variant;
begin
  LIdJob := GetSelectedJobId;
  if VarIsNull(LIdJob) then begin
    MyWarningMessage('Сначала выберите должность в списке слева.');
    Exit;
  end;
  //коэффициенты общего справочника, ещё не привязанные к этой должности
  Q.QLoad('select c.id, c.name from w_motivation_coefficients c ' +
    'where not exists (select 1 from w_motivation_coefficient_for_job f ' +
    'where f.id_job_internal = :id_job$i and f.id_coefficient = c.id) order by c.pos',
    [LIdJob], na);
  if na.Count = 0 then begin
    MyInfoMessage('Все коэффициенты общего справочника уже привязаны к этой должности.');
    Exit;
  end;
  SetLength(Names, na.Count);
  SetLength(Ids, na.Count);
  for i := 0 to na.Count - 1 do begin
    Names[i] := na.GetValue(i, 'name');
    Ids[i] := na.GetValue(i, 'id');
  end;

  if TFrmBasicInput.ShowDialog(Self, '', [], fAdd,
       '~Добавить критерий должности', 350, 110,
       [[cntComboLK, 'Коэффициент', '1:300'],
        [cntNEdit, 'Доля вознаграждения (%)', '0:100:2:N']],
       VarArrayOf([
         VarArrayOf(['', VarArrayOf(Names), VarArrayOf(Ids)]),
         0
       ]),
       va, [['']], nil
     ) < 0 then Exit;

  LIdCoeff := va[0];
  LNewPos := Q.QLoadValue('select nvl(max(pos), 0) + 1 from w_motivation_coefficient_for_job where id_job_internal = :id$i', [LIdJob]);
  if VarIsNull(LNewPos) then LNewPos := 1;
  Q.QSave('I', 'w_motivation_coefficient_for_job', '', 'id$i;id_job_internal$i;id_coefficient$i;pos$i;weight$f',
    [Null, LIdJob, LIdCoeff, LNewPos, S.NNum(va[1]) / 100], False);
  DoRender;
end;

procedure TFrmWMotivationTest.RbgModeClick(Sender: TObject);
begin
  lbxEmployees.Visible := rbgMode.ItemIndex = 1;
  if lbxEmployees.Visible then
    PopulateEmployeesList(GetSelectedJobId);
  DoRender;
end;

procedure TFrmWMotivationTest.LbxJobsClick(Sender: TObject);
begin
  if rbgMode.ItemIndex = 1 then
    PopulateEmployeesList(GetSelectedJobId);
  DoRender;
end;

procedure TFrmWMotivationTest.LbxEmployeesClick(Sender: TObject);
begin
  DoRender;
end;

procedure TFrmWMotivationTest.BtnAddCoeffClick(Sender: TObject);
begin
  DoAddCoefficient;
end;

procedure TFrmWMotivationTest.EdtPremiumChange(Sender: TObject);
begin
  DoRender;
end;

end.
