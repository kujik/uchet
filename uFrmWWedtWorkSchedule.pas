unit uFrmWWedtWorkSchedule;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ToolCtrlsEh, DBGridEhToolCtrls,
  GridsEh, DBAxisGridsEh, DBGridEh, PropFilerEh, PropStorageEh, Math,
  Types, DBCtrlsEh, ExtCtrls, Vcl.ComCtrls, Vcl.Mask,
  uFrmBasicMdi, uFrmBasicDbDialog, uFrDBGridEh, uFrMyPanelCaption, uData, uString
  ;

type
  TFrmWWedtWorkSchedule = class(TFrmBasicDbDialog)
    pnlPropertiesC: TPanel;
    frmpcProperties: TFrMyPanelCaption;
    pnlProperties: TPanel;
    edt_name: TDBEditEh;
    chb_active: TDBCheckBoxEh;
    edt_code: TDBEditEh;
    edt_comm: TDBEditEh;
    pnlHoursC: TPanel;
    frmpcHours: TFrMyPanelCaption;
    pnlHours: TPanel;
    cbb_year: TDBComboBoxEh;
    FrgHours: TFrDBGridEh;
    pnlTemplateC: TPanel;
    pnlTemplate: TPanel;
    FrgTemplate: TFrDBGridEh;
    frmpcTemplate: TFrMyPanelCaption;
    nedt_duration: TDBNumberEditEh;
    chb_is_individual: TDBCheckBoxEh;
  private
    FHolydays: TVarDynArray2;
    FTemplate: TVarDynArray2;
    FHours: TVarDynArray2;
    FAdminMode: Boolean;
    function  Prepare: Boolean; override;
    procedure ControlOnChangeEvent(Sender: TObject); override;
    procedure ControlOnExit(Sender: TObject); override;
    function  Save: Boolean; override;
    procedure FrgTemplateColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
    procedure FrgTemplateColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
    procedure FrgHoursColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
    procedure FrgHoursColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
    procedure FrgHoursButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
    function  GetHoursValue(AValue: Variant): Variant;
    function  IsHoursRowCorrect(ARow: Integer): Boolean;
    procedure LoadTemplate;
    procedure SaveTemplate;
    procedure LoadHours;
    procedure SaveHours;
    function  IsTemplateCorrect: Boolean;
    procedure FillHoursFromTemplate;
  public
  end;

var
  FrmWWedtWorkSchedule: TFrmWWedtWorkSchedule;

implementation

uses
  uForms,
  uDBOra,
  uMessages,
  uFrmBasicInput,
  DateUtils
  ;

{$R *.dfm}

function TFrmWWedtWorkSchedule.Prepare: Boolean;
var
  i, j: Integer;
  c: TControl;
  va2: TVarDynArray2;
//ширина ячейки вренмени
const
  w = 30;
begin
  Result := False;
  Caption := 'График работы';
  //поля
  F.DefineFields := [
    ['id$i'],
    ['active$i'],
    ['code$s','V=1:50::T'],
    ['name$s','V=1:400::T'],
    ['comm$s','V=0:400::T'],
    ['duration$i','V=1:31:0']
  ];
  View := 'w_schedules';
  Table := 'w_schedules';
  Cth.AlignControls(pnlProperties, [], True);
  pnlPropertiesC.Height := pnlProperties.Height + frmpcProperties.Height;
  FrgTemplate.Height := 50;
  pnlTemplate.Height := FrgTemplate.Top + FrgTemplate.Height;
  pnlTemplateC.Height := pnlTemplate.Height + frmpcTemplate.Height;
  FrgHours.Height :=247;
  pnlHours.Height := FrgHours.Top + FrgHours.Height;
  pnlHoursC.Height := pnlHours.Height + frmpcHours.Height;
  FWHBounds.Y := pnlHoursC.Top + pnlHoursC.Height;
  FWHBounds.X := 71 + 71 + (w + 1) * 31 + 51 + 10 + 4;
  Self.ClientWidth := FWHBounds.X;
  MyFormOptions := MyFormOptions - [myfoSizeable];
  //родительский метод
  Result := inherited;
  if not Result then
    Exit;
  frmpcProperties.SetParameters(True, 'Параметры',
    [[
      'Задайте основные параметры графика работы.'#13#10+
      'Код графика является обязательным, именно он выбирается из списка при назначении графика работнику.'#13#10+
      'Наименование содержит понятную информацию о графике и также обязательно.'#13#10+
      'Можно также ввести необязательный комментарий.'#13#10+
      'Чтобы иметь возможность назначать данный график работникам, поставьте галочку "Используется"'#13#10+
      ''#13#10
    ]],
    False
  );
  //заголовок
  frmpcTemplate.SetParameters(True, 'Шаблон графика',
    [['Задайте шаблон графика.'#13#10+
     'Для этого сначала введите длительность шаблона'#13#10+
     '(например, 7 дней; каждые 7 дней в плановом графике будет повторяться данный шаблон).'#13#10+
     'Затем заполните рабочее время в часах для каждой ячейки шаблона, или задайте день выходным, введя "В" иили 0.'
    ]],
    False
  );
  //грид
  FrgTemplate.Options := [myogColoredTitle];
  va2 := [['name$s','Дни:','140']];
  for i := 1 to 31 do
    va2 := va2 + [['d' + IntToStr(i) + '$s', IntToStr(i), IntToStr(w), 'e']];
  FrgTemplate.Opt.SetFields(va2 + [['null$s', '', '50']]);
  FrgTemplate.Opt.SetGridOperations('u');
  FrgTemplate.OnColumnsGetCellParams := FrgTemplateColumnsGetCellParams;
  FrgTemplate.OnColumnsUpdateData := FrgTemplateColumnsUpdateData;
  LoadTemplate;
  FrgTemplate.SetInitData(FTemplate);
  FrgTemplate.Prepare;
  FrgTemplate.RefreshGrid;


  //заголовок
  frmpcHours.SetParameters(True, 'График',
    [['Веедите время работы для каждого месяца календарного года.']],
    False
  );
  //грид
  FrgHours.Options := [myogColoredTitle];
  va2 := [['month$s','Месяц','70'], ['approved$i', 'Согласован', '70', 'chb', 'e']];
  for i := 1 to 31 do
    va2 := va2 + [['d' + IntToStr(i) + '$s', IntToStr(i), IntToStr(w) + ';c', 'e']];
  FrgHours.Opt.SetFields(va2 + [['total$s', 'Итого', '50;c']]);
  FrgHours.Opt.SetGridOperations('u');
  FrgHours.Opt.SetButtons(1,[[-1000, True, 'Разрешить ввод данных', 'arrow_up'],[],[-1001, 'Заполнить из шаблона', 'arrow_up']]);  //!!! не отображаются картинки в меню (вверху в кнопке - отображаются)
  FrgHours.OnColumnsGetCellParams := FrgHoursColumnsGetCellParams;
  FrgHours.OnColumnsUpdateData := FrgHoursColumnsUpdateData;
  FrgHours.OnButtonClick := FrgHoursButtonClick;
  LoadHours;
  FrgHours.SetInitData(FHours);
  FrgHours.Opt.SetGridOperations('u');
  FrgHours.Prepare;
  FrgHours.RefreshGrid;

  //общая подсказка
  FOpt.InfoArray:=[[
    'Плановый график работы.'#13#10+
    ''#13#10+
    ''#13#10+
    ''#13#10+
    ''#13#10+
    ''#13#10+
    ''#13#10+
    ''#13#10+
    ''#13#10+
    ''#13#10
  ]];
  //ок
  Result := True;
end;

procedure TFrmWWedtWorkSchedule.ControlOnChangeEvent(Sender: TObject);
begin
end;

procedure TFrmWWedtWorkSchedule.ControlOnExit(Sender: TObject);
var
  i: Integer;
begin
  inherited;
  if Sender = nedt_duration then begin
    for i := nedt_duration.Value.AsInteger + 1 to 31 do
      FrgTemplate.SetValue('d' + IntToStr(i), 0, False, null);
    FrgTemplate.InvalidateGrid;
  end;
end;

procedure TFrmWWedtWorkSchedule.FrgTemplateColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  Params.ReadOnly := True;
  if FieldName = 'name' then
    Params.Background := clmyGray
  else if TColumnEh(Sender).Index > Cth.GetControlValue(nedt_duration).AsFloat then
    Params.Background := clmyGray
  else begin
    if Params.Text = '0' then
      Params.Text := 'В';
    Params.ReadOnly := False;
    if Params.Text = 'В' then
      Params.Font.Color := clRed;
  end;
end;

function TFrmWWedtWorkSchedule.Save: Boolean;
begin
  Result := inherited;
  if not Result then
    Exit;
  Q.QBeginTrans(True);
  SaveTemplate;
  SaveHours;
  Result := Q.QCommitOrRollback;
end;

procedure TFrmWWedtWorkSchedule.FrgTemplateColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
  Fr.SetValue(Fr.CurrField, Fr.RecNo - 1, False, GetHoursValue(Value));
  Fr.InvalidateGrid;
  Handled := True;
end;

procedure TFrmWWedtWorkSchedule.FrgHoursColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if FieldName = 'month' then begin
    Params.Background := clmyGray;
    Params.ReadOnly := True;
  end
  else if FieldName = 'approved' then begin
    Params.Background := clmyGreen
  end
  else if FieldName = 'total' then begin
    Params.Background := clSkyBlue;
  end
  else begin
    case FHolydays[Fr.RecNo - 1][TColumnEh(Sender).Index].AsInteger of
      -1:
        Params.Background := clmyGray;
      1:
        Params.Background := clmyPink;
      2:
        Params.Background := clYellow;
    end;
    Params.ReadOnly := (FHolydays[Fr.RecNo - 1][TColumnEh(Sender).Index] = -1) or (Fr.GetValueI('approved', Fr.RecNo - 1) = 1);
    if Params.Text = '0' then
      Params.Text := 'В';
    if Params.Text = 'В' then
      Params.Font.Color := clRed;
  end;
end;

procedure TFrmWWedtWorkSchedule.FrgHoursColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
  if Fr.CurrField = 'approved' then begin
    if IsHoursRowCorrect(Fr.RecNo - 1) then
      Exit;
    Handled := True;
  end
  else begin
    Fr.SetValue(Fr.CurrField, Fr.RecNo - 1, False, GetHoursValue(Value));
    IsHoursRowCorrect(Fr.RecNo - 1);
    Fr.InvalidateGrid;
    Handled := True;
  end;
end;

procedure TFrmWWedtWorkSchedule.FrgHoursButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  Handled := True;
  if Tag = 1000 then begin
    if MyQuestionMessage(S.IIf(FAdminMode, 'Выключить', 'Включить') + ' режим редактирования всех данных?') = mrYes then
      FAdminMode := not FAdminMode;
  end
  else if Tag = 1001 then begin
    FillHoursFromTemplate;
  end
  else Handled := False;
end;

function TFrmWWedtWorkSchedule.GetHoursValue(AValue: Variant): Variant;
begin
  if (AValue.AsString = '0') or (AValue.AsString = 'В') or (AValue.AsString = 'в') then
    Result := 0
  else begin
    if S.IsNumber(AValue, 0.5, 24, 1) then
      Result := StrToFloat(AValue)
    else
      Result := null;
  end;
end;

function TFrmWWedtWorkSchedule.IsHoursRowCorrect(ARow: Integer): Boolean;
begin
  Result := True;
  var LTotal := 0;
  for var i := 1 to 31 do begin
    LTotal := LTotal + FrgHours.GetValueI('d' + IntToStr(i), ARow, False);
    if (FHolydays[ARow][i + 1] <> -1) and (FrgHours.GetValue('d' + IntToStr(i), ARow, False) = null) then
      Result := False;
  end;
  FrgHours.SetValue('total', ARow, False, S.IIf(Result, LTotal, null));
end;

procedure TFrmWWedtWorkSchedule.LoadTemplate;
var
  i: Integer;
  va: TVarDynArray;
begin
  va := Q.QLoadToVarDynArrayOneCol('select hours from w_schedule_templates where id_schedule = :id$i order by pos', [ID]);
  SetLength(FTemplate, 1);
  SetLength(FTemplate[0], 33);
  FTemplate[0][0] := 'Время работы:';
  for i := 0 to High(va) do
    FTemplate[0][i + 1] := va[i];
  for i := High(va) + 1 to High(FTemplate[0]) do
    FTemplate[0][i + 1] := null;
end;

procedure TFrmWWedtWorkSchedule.SaveTemplate;
var
  i: Integer;
  va21, va22: TVarDynArray2;
begin
  va21 := FrgTemplate.ExportToVa2;
  if A.IsArraysEqual(va21, FTemplate) then
    Exit;
  Q.QExecSql('delete from w_schedule_templates where id_schedule = :id$i', [ID]);
  for i := 1 to nedt_duration.Value.AsInteger do
    Q.QExecSql('insert into w_schedule_templates (id_schedule, pos, hours) values (:id$i, :pos$i, :hours$f)', [ID, i, va21[0][i]]);
end;

procedure TFrmWWedtWorkSchedule.LoadHours;
var
  i, j, k, m, y: Integer;
  h: Variant;
  va1, va2, va3: TVarDynArray2;
begin
  y := 2025;
  //часы за каждый день года
  va1:= Q.QLoadToVarDynArray2('select dt, hours from w_schedule_hours where id_schedule = :id$i and dt >= :dt1$d and dt < :dt2$d order by dt', [ID, EncodeDate(y, 1, 1), EncodeDate(y + 1, 1, 1)]);
  //согласования и итоговые часы за каждый месяц
  va2 := Q.QLoadToVarDynArray2('select dt, hours, approved from w_schedule_periods where id_schedule = :id$i and dt >= :dt1$d and dt < :dt2$d order by dt', [ID, EncodeDate(y, 1, 1), EncodeDate(y + 1, 1, 1)]);
  //получим календарь за этот месяц  (1-выходной, 2-сокращенный, 3-рабочий)
  va3:= Q.QLoadToVarDynArray2('select dt, type, descr from ref_holidays where extract(year from dt) = :year$i', [y]);

  SetLength(FHours, 0);
  SetLength(FHours, 12);
  SetLength(FHolydays, 12);
  k := 0;
  m := 0;
  for i := 0 to 11 do begin
    SetLength(FHours[i], 34);
    FHours[i][0] := MonthsRu[i + 1];
    SetLength(FHolydays[i], 33);
    for j := 1 to 31 do begin
      FHolydays[i][j + 1] := 0;
      FHours[i][j + 1] := null;
      if j > DayOf(EndOfTheMonth(EncodeDate(y, i + 1, 1))) then begin
        FHolydays[i][j+ 1] := -1;
      end
      else begin
        //получим тип дня из календаря
        h := A.FindValueInArray2(EncodeDate(y, i + 1, j), 0, 1, va3).AsFloat;
        //отметим выходным, если праздник, или (сб,вс и при это не проставлен сокращенным или рабочим)
        if (h = 1) or ((DayOfTheWeek(EncodeDate(y, i + 1, j)) >= 6) and (h <> 2) and (h <> 3)) then
          FHolydays[i][j + 1] := 1
        else if h = 2 then
          FHolydays[i][j + 1] := 2;
        FHours[i][j + 1] := A.FindValueInArray2(EncodeDate(y, i + 1, j), 0, 1, va1);
      end;
    end;
    //итоговое время за месяц, или нулл если нет в таблице
    FHours[i][33] := A.FindValueInArray2(EncodeDate(y, i + 1, 1), 0, 1, va2);
    //признак согласования, или нулл
    FHours[i][1] := A.FindValueInArray2(EncodeDate(y, i + 1, 1), 0, 1, va2);
  end;
end;

procedure TFrmWWedtWorkSchedule.SaveHours;
var
  i, j, k, y, Changed: Integer;
  LHours: TVarDynArray2;
  st: string;
begin
  y := 2025;
  LHours := FrgHours.ExportToVa2;
  if A.IsArraysEqual(LHours, FHours) then
    Exit;
  Changed := 0;
  for i := 1 to 12 do
    for j := 1 to 31 do
      if LHours[i - 1][j + 1] <> FHours[i - 1][j + 1] then
        Inc(Changed);
  if Changed < 6 then begin
    for i := 1 to 12 do begin
      for j := 1 to 31 do begin
        if LHours[i - 1][j + 1] = FHours[i - 1][j + 1] then
          Continue;
        Q.QExecSql('delete from w_schedule_hours where id_schedule = :id$i and dt = :dt1$d', [ID, EncodeDate(y, i, j)]);
        if LHours[i - 1][j + 1] <> null then
          Q.QExecSql('insert into w_schedule_hours (id_schedule, dt, hours) values (:id$i, :dt1$d, :hours$f)', [ID, EncodeDate(y, i, j), LHours[i - 1][j + 1]]);
      end;
    end;
  end
  else begin
    st := '';
    k := 0;
    for i := 1 to 12 do begin
      for j := 1 to 31 do
        if j <= DayOf(EndOfTheMonth(EncodeDate(y, i, 1))) then begin
          Inc(k);
          if LHours[i - 1][j + 1] = null then
            Continue;
          S.ConcatStP(st, IntToStr(k) + '-' + S.FormatNumberWithComma(LHours[i - 1][j + 1].AsFloat, False), ',');
        end;
    end;
    Q.QCallStoredProc('P_SaveScheduleHours', 'Id$i;y$i;h$s', [ID, y, st]);
  end;
end;

function TFrmWWedtWorkSchedule.IsTemplateCorrect: Boolean;
begin
  Result := False;
  if nedt_duration.Value.AsString = '' then
    Exit;
  Result := True;
  for var i := 1 to nedt_duration.Value.AsInteger do
    if FrgTemplate.GetValue('d' + IntToStr(i), 0, False) = null then begin
      Result := False;
      Exit;
    end;
end;

procedure TFrmWWedtWorkSchedule.FillHoursFromTemplate;
var
  i, j, y, d, r: Integer;
  va: TVarDynArray;
  msg: string;
begin
  y := 2025;
  d := StrToIntDef(Copy(FrgHours.CurrField, 2, 2), -1);
  if d  = -1 then
    Exit;
  if FHolydays[FrgHours.RecNo - 1][d + 1] = -1 then
    Exit;
  msg := '';
  if not IsTemplateCorrect then
    msg := 'Не задан или не полностью введён шаблон графика!';
  if FrgHours.GetValueI('approved') = 1 then
    msg := 'График на этот месяц уже согласован!';
  if msg <> '' then begin
    MyWarningMessage(msg);
    Exit;
  end;
  //выдадим запрос, на сколько месяцев заполнять, и сообщим дату начала графика (текущая ячейка)
  if TFrmBasicInput.ShowDialog(Self, '', [], fAdd, '~', 380, 330,
    [[cntNEdit, 'Заполнить график с даты "' + DateToStr(EncodeDate(y, FrgHours.RecNo, d)) + '" вперед на (месяцев):  ', '1:' + InttoStr(12 - FrgHours.RecNo) + ':0:N']],
    [1],
    va, [['']], nil
  ) < 0 then Exit;
  //i - текущий номер заполняемого дня (не попадут дни старше конца месяца), начинается с номера дня графика на 1е число месяца, в который кликнули
  //j - номер дня от 1 до 31
  //r - номер строки
  i := 0;
  j := d;
  //отмотаем назад так чтобы шаблон начинался 1го числа или ранее
  while j > 1 do
    j := j - nedt_duration.Value;
  i := -(j - 1);
  j := 1;
  //текущая строка в массиве с 0
  r := FrgHours.RecNo - 1;
  //цикл по максимально возможному количеству днейй
  while i <= 31 * 12 do begin
    FrgHours.SetValue('d' + IntToStr(j), r, False, FrgTemplate.GetValue('d' + IntToStr((i mod nedt_duration.Value) + 1), 0, False));
    //достигли 31го числа или день за концом месяца
    if (j = 31) or (FHolydays[r][j + 2] = -1) then begin
      IsHoursRowCorrect(r);
      //увеличим строку и сбросим номер дня
      r := r + 1;
      j := 0;
      //если заполнили за декабрь, или заполнили целевое количество строка, то выход
      if (r > 12) or (r > FrgHours.RecNo - 1 + va[0]) then
        Break;
    end;
    //увеличим счетчики
    Inc(j);
    Inc(i);
  end;
  FrgHours.InvalidateGrid;
end;

end.

