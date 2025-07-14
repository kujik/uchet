(*
Форма дефолтного фильтра для TFrDBGridEh

Поддерживает фильтр по дате по выбранному столбцу и любой количество независимых чекбоксов
для управления кастомными правилами фильтрации.

Статически сделаны контролы для выбора поля и периода фильтра по дате,
при отстутствии фильтра по дате в правилах или не нахождении ни одного столбца из них
контролы удаляются. Чекбоксы добавляются динамичеки.

Правила фильра заданы в свойстве TFrDBGridEh.Opt.FilterRules
[[текст_дополнения_общей_подсказки, {подсказки_чекбоксов_не _реализовано}],
 ['dtfield1;dtfieldN'],
 [заголовок, {имя_контрола}, {sql-правило}, {True/False}], [...]
]

sql-правило - через ; правило для установленного и снятого чекбокса (если нет ; то для снятго будет пустое)
правила обрабатываются методом фильтра по умолчанию соединяясь через and если они не пустые

Результат фильтра обрабатывается каждый раз при открытии или обновлении грида, после чего производится
вызов SetSqlParams(Self, FNo, stw), где stw есть результат обработки дефолтного фильтра GetDefRule. если событие назначено,
то в нем можно обработать поля фильтра кастомно (втч те которым не назначены sql-правило), или вообще произвольно
изменить where-часть запроса (также там и присваиваются параметры и например значения видимости или нулл)

если логику можно реализовать правилами в настройках фильтра, доп обработка не нужна.

для обработки можно применять методы этого класса GetCth, GetDt, GetChb, GetDefRule

сериализованная строка результата фильтра сохраняется фреймом в настройках пользователя
*)

unit uFrmXDedtGridFilter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  GridsEh, DBAxisGridsEh, DBGridEh, PropFilerEh, PropStorageEh, Math,
  Mask, Types, DBCtrlsEh, ExtCtrls, DateUtils, ClipBrd,
  uLabelColors, uString, uFrmBasicMdi, uFrDBGridEh, Vcl.Menus
  ;

type
  TFrmXDedtGridFilter = class(TFrmBasicMdi)
    dedt1: TDBDateTimeEditEh;
    dedt2: TDBDateTimeEditEh;
    nedtDays: TDBNumberEditEh;
    bvl1: TBevel;
    cmbField: TDBComboBoxEh;
    cmbPeriod: TDBCheckBoxEh;
    cmbDays: TDBCheckBoxEh;
    pmPeriod: TPopupMenu;
  private
    //грид - родитель
    FrDbGrid: TFrDBGridEh;
    FControlOnChange: Boolean;
    //дополнение к общей подсказке формы, из правил фильтра
    FHelp: string;
    //признаки, что есть условие выбор дат, есть чекбоксы
    FHasDate, FHasChb: Boolean;
    procedure SetControls;
    procedure PmPeriodClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject); override;
    procedure ControlOnChange(Sender: TObject); override;
    function  Prepare: Boolean; override;
  public
    //получить значение контрола на форме фильтра по имени без учета регистра, если не найден вернет ''
    class function GetCth(Frg: TFrDBGridEh; Chb: Variant): string;
    //получить правило задания фильтра по дате, если там есть условие, в виде where-части запроса с явныо прописанными датами
    class function GetDt(Frg: TFrDBGridEh): string;
    //получить значения параметра-чекбокса по номеру (чекбока, начиная с 1, а не элемента массива!),
    //или имени. если не найден, вернет False
    class function GetChb(Frg: TFrDBGridEh; Chb: Variant): Boolean;
    //получить общее правило обработки фильтра одной строкой из всех правил и фильтра даты, через 'and'
    //если нет части по дате и ни одного правила или чекбокса, вернет ''
    class function GetDefRule(Frg: TFrDBGridEh): string;
  end;

var
  FrmXDedtGridFilter: TFrmXDedtGridFilter;

implementation

uses
  uForms,
  uMessages,
  uData,
  uErrors,
  uSys,
  uDBOra,
  uWindows,
  uSettings
  ;


{$R *.dfm}

class function TFrmXDedtGridFilter.GetDefRule(Frg: TFrDBGridEh): string;
var
  st: string;
  va, va1: TVarDynArray;
  i, j: Integer;
  b: Boolean;
begin
  va := [GetDt(Frg)];
  for i := 1 to High(Frg.Opt.FilterRules) - 1 do
    if (High(Frg.Opt.FilterRules[i + 1]) >= 2) and (S.VarType(Frg.Opt.FilterRules[i + 1][2]) = varString) then begin
      va1 := A.Explode(Frg.Opt.FilterRules[i + 1][2], ';') + [''];
      if GetChb(Frg, i)
        then va := va + [va1[0]]
        else va := va + [va1[1]];
    end;
  Result:= A.ImplodeNotEmpty(va, 'and ');
end;


class function TFrmXDedtGridFilter.GetDt(Frg: TFrDBGridEh): string;
var
  v1, v2, v3, v4, v5, v6: Variant;
  i1, i2, i3: Integer;
  f1, f2: double;
  dt1, dt2: TDateTime;
  st1, st2: string;
begin
  v1 := GetCth(Frg, 'nedtDays');
  v2 := GetCth(Frg, 'dedt1');
  v3 := GetCth(Frg, 'dedt2');
  v4 := GetCth(Frg, 'cmbPeriod');
  v5 := GetCth(Frg, 'cmbDays');
  v6 := GetCth(Frg, 'cmbField');
  Result := '';
  if S.Nst(v6) = '' then
    Exit;
  dt1 := -1;
  dt2 := -1;
  if (v4 = '1') then begin
    if v2 <> '' then dt1 :=  StrToDateDef(v2, Date);
    if v3 <> '' then dt2 :=  StrToDateDef(v3, Date);
  end
  else if (v5 = '1') and (v1 <> '') then begin
    dt1 := IncDay(Date, -S.VarToInt(v1) + 1);
    dt2 := -1;
  end;
  if (dt1 = -1) and (dt2 = -1) then
    Exit;
  if (dt1 > -1) then
    Result := v6 + ' >= ''' + S.SQLdate(dt1) + '''';
  if (dt2 > -1) then
    Result := Result + S.IIf(Result <> '', ' and ', '') + v6 + ' <= ''' + S.SQLdate(dt2) + '''';
end;

class function TFrmXDedtGridFilter.GetCth(Frg: TFrDBGridEh; Chb: Variant): string;
var
  va2: TVarDynArray2;
  i : Integer;
begin
  Result := '';
  va2 := Cth.DeSerializeControlValuesArr2(Frg.Opt.FilterResult);
  i := A.PosInArray(Chb, va2, 0, True);
  if i >= 0 then
    Result := va2[i][1];
end;

class function TFrmXDedtGridFilter.GetChb(Frg: TFrDBGridEh; Chb: Variant): Boolean;
var
  va2: TVarDynArray2;
  i : Integer;
  v: Variant;
begin
  Result := False;
  if High(Frg.Opt.FilterRules) < 2 then
    Exit;
  if S.VarType(Chb) = varInteger then begin
    if High(Frg.Opt.FilterRules) <= Chb then
      Exit;
    i := Chb;
    if (High(Frg.Opt.FilterRules[i + 1]) > 1) and (S.VarType(Frg.Opt.FilterRules[i + 1][1]) = varString)
      then Chb := Frg.Opt.FilterRules[i + 1][1]
      else Chb := 'Chb' + InttoStr(i);
    if (S.VarType(Frg.Opt.FilterRules[i + 1][High(Frg.Opt.FilterRules[i + 1])]) = varBoolean) and (Frg.Opt.FilterRules[i + 1][High(Frg.Opt.FilterRules[i + 1])] = False) then
      Exit;
  end;
  va2 := Cth.DeSerializeControlValuesArr2(Frg.Opt.FilterResult);
  i := A.PosInArray(Chb, va2, 0, True);
  if i >= 0 then
    Result := va2[i][1] = '1';
end;


procedure TFrmXDedtGridFilter.btnOkClick(Sender: TObject);
var
  st: string;
  b: Boolean;
begin
  inherited;
  //сохраним значения контролов формы как результат фильра дляфрейма (строка - сериализованный массив имен/наченийй контролов)
  FrDbGrid.Opt.FilterResult := Cth.SerializeControlValuesArr2(Cth.GetControlValuesArr2(Self, pnlFrmClient, [], []));
  b := GetChb(FrDbGrid, 'prod');
  b := GetChb(FrDbGrid, 'pro');
  b := GetChb(FrDbGrid, 1);
  b := GetChb(FrDbGrid, 2);
  b := GetChb(FrDbGrid, 'Chb3');
  st := GetDt(FrDbGrid);
end;

procedure TFrmXDedtGridFilter.PmPeriodClick(Sender: TObject);
var
  dt1, dt2 : TDateTime;
begin
  S.GetDatePeriod(TComponent(Sender).Tag, Date, dt1, dt2);
  dedt1.Value := dt1;
  dedt2.Value := dt2;
end;

procedure TFrmXDedtGridFilter.ControlOnChange(Sender: TObject);
//обработка событий изменения контролов
//нам важна только часть, связанная с периодом дат
var
  n: string;
  v: Variant;
begin
  if FInPrepare or FControlOnChange then Exit;
  FControlOnChange := True;
  //имя и значение текущего контрола
  n := TControl(Sender).Name;
  v := Cth.GetControlValue(Sender);
  //для имени столбца, если оно пустое - выбираем первое
  if (n = 'cmbField')and(v = null) then
    cmbField.ItemIndex := 0
  //если это чекбокс За последние, дней, или поле ввода количества дней -
  //снимем галку За период, поставим За последние
  else if (n = 'cmbDays')or(n = 'nedtDays') then begin
    if cmbPeriod.Checked then
      cmbPeriod.Checked := False;
    if (n <> 'cmbDays') and not cmbDays.Checked then
      cmbDays.Checked := True;
  end
  //с периодом дат - аналогично
  else if (n = 'cmbPeriod')or(n = 'dedt1')or(n = 'dedt2') then begin
    if (n <> 'cmbPeriod') and not cmbPeriod.Checked then
      cmbPeriod.Checked := True;
    if cmbDays.Checked then
      cmbDays.Checked := False;
  end;
  FControlOnChange := False;
end;

procedure TFrmXDedtGridFilter.SetControls;
//настроим контролы на форме
var
  sa: TStringDynArray;
  i, j, t: Integer;
  st: string;
  c: TControl;
  va: TVarDynArray;
  va2: TVarDynArray2;
begin
  if High(FrDbGrid.Opt.FilterRules[0]) >= 0 then
    FHelp := FrDbGrid.Opt.FilterRules[0][0];
  //если элемент #1 правил фильтра не пустой (в #0 help)
  if High(FrDbGrid.Opt.FilterRules[1]) >= 0 then begin
    //соберем массив полей и названий для переданных полей дат, если они найдены в гриде
    va := A.Explode(FrDbGrid.Opt.FilterRules[1][0], ';');
    for i := 0 to High(va) do begin
      if FrDbGrid.DbGridEh1.FindFieldColumn(va[i]) = nil then
        Continue;
      va2 := va2 + [[FrDbGrid.DbGridEh1.FindFieldColumn(va[i]).Title.Caption, va[i], True]];
    end;
    //очистим, если ни одного столбца не найдено
    FHasDate := High(va2) > -1;
    //установим комбобокс столбцов
    Cth.AddToComboBoxEh(cmbField, va2);
    cmbField.ItemIndex := 0;
    //верх первого чекбокса
    t := bvl1.Top;
  end;
  //если нет полей дат - удалим все контролы с панели формы
  if not FHasDate then begin
    while pnlFrmClient.ControlCount > 0 do
      pnlFrmClient.Controls[pnlFrmClient.ControlCount - 1].Free;
    t := 1;
  end;
  //создадим чекбоксы, переданные в с 2 по последний эеллементе массива правил фильра
  //[[заголовок, {имя_контрола}, {True/False}], [...]]
  for i:= 2 to High(FrDbGrid.Opt.FilterRules) do begin
    if (High(FrDbGrid.Opt.FilterRules[i]) = -1) or
       ((S.VarType(FrDbGrid.Opt.FilterRules[i][High(FrDbGrid.Opt.FilterRules[i])]) = varBoolean) and
       (FrDbGrid.Opt.FilterRules[i][High(FrDbGrid.Opt.FilterRules[i])] = False)) then
      Break;
    if (High(FrDbGrid.Opt.FilterRules[i]) > 0) and (S.VarType(FrDbGrid.Opt.FilterRules[i][1]) = varString) and (FrDbGrid.Opt.FilterRules[i][1] <> '')
      then st := FrDbGrid.Opt.FilterRules[i][1]
      else st := 'Chb' + IntToStr(i - 1);
    c:=Cth.CreateControls(pnlFrmClient, cntCheck, FrDbGrid.Opt.FilterRules[i][0], st, '', 0);
    c.Left := 4;
    c.Width := pnlFrmClient.Width - 10;
    c.Top := t + 4 + i * MY_FORMPRM_CONTROL_H;
    FHasChb := True;
  end;
  va2 := [];
  for i := 0 to High(DatePeriods) do
    va2 := va2 + [[i, True, DatePeriods[i], '']];
  Cth.CreatePopupMenu(pmPeriod, va2, PmPeriodClick);
  //восстановим значения контролов из строки результата фильтра в фрейме
  Cth.SetControlValuesArr2(Self, Cth.DeSerializeControlValuesArr2(FrDbGrid.Opt.FilterResult));
end;


function TFrmXDedtGridFilter.Prepare: Boolean;
//подготовка формы
var
  i, j: Integer;
  va2: TVarDynArray;
begin
  Result := False;
  Mode := fEdit;
  Caption := '~Фильтр';
  FOpt.DlgPanelStyle:= dpsBottomRight;
  Cth.MakePanelsFlat(pnlFrmClient, []);
  FrDbGrid := TFrDBGridEh(ParentControl);
  if High(FrDbGrid.Opt.FilterRules) = -1 then
    Exit;
  SetControls;
  FOpt.AutoAlignControls:=True;
  FOpt.InfoArray:=[
    ['Установите фильтр для загрузки данных, это позволит не загружать все данные в таблицу и ускорит работу.'#13#10],
    ['Вы можете устанорить фильтр по дате, '#13#10+
      'для этого выберите колонку, по которой ставится фильтр, из списка, далее поставьте галочку "за период"'#13#10+
      'и задайте даты начала и конца периода (или любую одну, тогда интервал будет открытым),'#13#10+
      'или же галочку "за последние", в этом случаем будут выводиться записи за заданное количество дней до текущей даты.'#13#10+
      'Фильтр по дате будет использоваться, если установлена галочка против периода или количества дней.'#13#10
      ,FHasDate
    ],
    ['Кроме даты, доступны флажки, с помощью которых вы можете также задать условие загрузки данных в таблицу.'#13#10, FHasChb],
    [#13#10 + FHelp + #13#10, FHelp <> ''],
    ['Настройки фильтра сохраняются при перезапуске программы.']
  ];

  Result := True;
end;


end.
