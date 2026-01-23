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
    FrgHours: TFrDBGridEh;
    pnlTemplateC: TPanel;
    pnlTemplate: TPanel;
    FrgTemplate: TFrDBGridEh;
    frmpcTemplate: TFrMyPanelCaption;
    nedt_duration: TDBNumberEditEh;
    tbcYear: TTabControl;
    procedure tbcYearChange(Sender: TObject);
    procedure tbcYearChanging(Sender: TObject; var AllowChange: Boolean);
  private
    //данные по периодам
    FData: array [0..1] of record
      //год
      Year: Integer;
      //выходные, праздники, сокращенные, за концом месяца
      Holydays: TVarDynArray2;
      //весь массив грида (все столбцы, не только часы), полученные при загрузке
      Hours: TVarDynArray2;
      //весь массив грида, полученный при сохранении по Ок или переходу к другому году
      HoursN: TVarDynArray2;
    end;
    //массив грида для грида шаблонов
    FTemplate: TVarDynArray2;
    //режим редактирования всех данных для администратора
    FAdminMode: Boolean;
    function  GetY: Integer;
    property  Y: Integer read GetY;
    function  GetYn: Integer;
    property  Yn: Integer read GetYn;
    function  Prepare: Boolean; override;
    procedure ControlOnChangeEvent(Sender: TObject); override;
    procedure ControlOnExit(Sender: TObject); override;
    procedure VerifyBeforeSave; override;
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
    procedure SetControlsEditableState;
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

  if Mode = fAdd then
    ID := null;

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
  //FrgHours.Top := 23;
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
  FrgHours.Opt.SetButtons(1,[[-1000, User.IsDeveloper and (Mode in [fAdd, fEdit]) , 'Разрешить ввод данных', 'arrow_up'],[],[-1001, Mode in [fAdd, fEdit], 'Заполнить из шаблона', 'arrow_up']]);  //!!! не отображаются картинки в меню (вверху в кнопке - отображаются)
  FrgHours.OnColumnsGetCellParams := FrgHoursColumnsGetCellParams;
  FrgHours.OnColumnsUpdateData := FrgHoursColumnsUpdateData;
  FrgHours.OnButtonClick := FrgHoursButtonClick;
  LoadHours;
  FrgHours.SetInitData(FData[Yn].Hours);
  FrgHours.Opt.SetGridOperations('u');
  FrgHours.Prepare;
  FrgHours.RefreshGrid;

  SetControlsEditableState;

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

procedure TFrmWWedtWorkSchedule.VerifyBeforeSave;
begin
  FErrorMessage := S.IIFStr(not IsTemplateCorrect, 'Не заполнен шаблон графика!');
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
    case FData[Yn].Holydays[Fr.RecNo - 1][TColumnEh(Sender).Index].AsInteger of
      -1:
        Params.Background := clmyGray;
      1:
        Params.Background := clmyPink;
      2:
        Params.Background := clYellow;
    end;
    Params.ReadOnly := (FData[Yn].Holydays[Fr.RecNo - 1][TColumnEh(Sender).Index] = -1) or (Fr.GetValueI('approved', Fr.RecNo - 1) = 1);
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
    SetControlsEditableState;
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

function TFrmWWedtWorkSchedule.IsHoursRowCorrect(ARow: Integer): Boolean;  //!!!
begin
  Result := True;
  var LTotal := 0;
  for var i := 1 to 31 do begin
    LTotal := LTotal + FrgHours.GetValueI('d' + IntToStr(i), ARow, False);
    if (FData[Yn].Holydays[ARow][i + 1] <> -1) and (FrgHours.GetValue('d' + IntToStr(i), ARow, False) = null) then
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
  for i := High(va) + 2 to High(FTemplate[0]) do
    FTemplate[0][i] := null;
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
  i, j, k, m, Yn, y: Integer;
  h: Variant;
  va1, va2, va3: TVarDynArray2;
begin
  FData[0].Year := YearOf(Date);
  FData[1].Year := YearOf(IncYear(Date, 1));
  for Yn := 0 to 1 do begin
    y := FData[Yn].Year;
    tbcYear.Tabs[Yn] := IntToStr(y);
    //часы за каждый день года
    va1 := Q.QLoadToVarDynArray2('select dt, hours from w_schedule_hours where id_schedule = :id$i and dt >= :dt1$d and dt < :dt2$d order by dt', [ID, EncodeDate(y, 1, 1), EncodeDate(y + 1, 1, 1)]);
    //согласования и итоговые часы за каждый месяц
    va2 := Q.QLoadToVarDynArray2('select dt, hours, approved from w_schedule_periods where id_schedule = :id$i and dt >= :dt1$d and dt < :dt2$d order by dt', [ID, EncodeDate(y, 1, 1), EncodeDate(y + 1, 1, 1)]);
    //получим календарь за этот месяц  (1-выходной, 2-сокращенный, 3-рабочий)
    va3 := Q.QLoadToVarDynArray2('select dt, type, descr from ref_holidays where extract(year from dt) = :year$i', [y]);
    SetLength(FData[Yn].Hours, 0);
    SetLength(FData[Yn].Hours, 12);
    SetLength(FData[Yn].Holydays, 12);
    k := 0;
    m := 0;
    for i := 0 to 11 do begin
      SetLength(FData[Yn].Hours[i], 34);
      FData[Yn].Hours[i][0] := MonthsRu[i + 1];
      SetLength(FData[Yn].Holydays[i], 33);
      for j := 1 to 31 do begin
        FData[Yn].Holydays[i][j + 1] := 0;
        FData[Yn].Hours[i][j + 1] := null;
        if j > DayOf(EndOfTheMonth(EncodeDate(y, i + 1, 1))) then begin
          FData[Yn].Holydays[i][j + 1] := -1;
        end
        else begin
        //получим тип дня из календаря
          h := A.FindValueInArray2(EncodeDate(y, i + 1, j), 0, 1, va3).AsFloat;
        //отметим выходным, если праздник, или (сб,вс и при это не проставлен сокращенным или рабочим)
          if (h = 1) or ((DayOfTheWeek(EncodeDate(y, i + 1, j)) >= 6) and (h <> 2) and (h <> 3)) then
            FData[Yn].Holydays[i][j + 1] := 1
          else if h = 2 then
            FData[Yn].Holydays[i][j + 1] := 2;
          FData[Yn].Hours[i][j + 1] := A.FindValueInArray2(EncodeDate(y, i + 1, j), 0, 1, va1);
        end;
      end;
    //итоговое время за месяц, или нулл если нет в таблице
      FData[Yn].Hours[i][33] := A.FindValueInArray2(EncodeDate(y, i + 1, 1), 0, 1, va2);
    //признак согласования, или нулл
      FData[Yn].Hours[i][1] := A.FindValueInArray2(EncodeDate(y, i + 1, 1), 0, 2, va2);
    end;
  end;
end;

procedure TFrmWWedtWorkSchedule.SaveHours;
var
  i, j, k, y, Yn, Changed: Integer;
  st: string;
  b: Boolean;
begin
  FData[tbcYear.TabIndex].HoursN := FrgHours.ExportToVa2;
  for Yn := 0 to 1 do begin
    y := FData[Yn].Year;
    if Length(FData[Yn].HoursN) = 0 then
      Continue;  //сюда попадет, если не переходили на вторую вкладку
    if A.IsArraysEqual(FData[Yn].HoursN, FData[Yn].Hours) then
      Break;
    Changed := 0;
    for i := 1 to 12 do
      for j := 1 to 31 do
        if FData[Yn].HoursN[i - 1][j + 1] <> FData[Yn].Hours[i - 1][j + 1] then
          Inc(Changed);
    if Changed < 5 then begin
      for i := 1 to 12 do begin
        for j := 1 to 31 do begin
          if FData[Yn].HoursN[i - 1][j + 1] = FData[Yn].Hours[i - 1][j + 1] then
            Continue;
          Q.QExecSql('delete from w_schedule_hours where id_schedule = :id$i and dt = :dt1$d', [ID, EncodeDate(y, i, j)]);
          if FData[Yn].HoursN[i - 1][j + 1] <> null then
            Q.QExecSql('insert into w_schedule_hours (id_schedule, dt, hours) values (:id$i, :dt1$d, :hours$f)', [ID, EncodeDate(y, i, j), FData[Yn].HoursN[i - 1][j + 1]]);
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
            if FData[Yn].HoursN[i - 1][j + 1] = null then
              Continue;
            S.ConcatStP(st, IntToStr(k) + '-' + S.FormatNumberWithComma(FData[Yn].HoursN[i - 1][j + 1].AsFloat, False), ',');
          end;
      end;
      Q.QCallStoredProc('P_SaveScheduleHours', 'Id$i;y$i;h$s', [ID, y, st]);
    end;
    b := False;
    if Q.QSelectOneRow('select count(*) from w_schedule_periods where id_schedule = :id$i and dt >= :dt1$d and dt < :dt2$d order by dt', [ID, EncodeDate(y, 1, 1), EncodeDate(y + 1, 1, 1)])[0] = 0 then begin
      for i := 1 to 12 do
        Q.QExecSql('insert into w_schedule_periods (id_schedule, dt) values (:id$i, :dt1$d)', [ID, EncodeDate(y, i, 1)]);
      b := True;
    end;
    for i := 1 to 12 do begin
      if (not b) and ((FData[Yn].HoursN[i - 1][1] = FData[Yn].Hours[i - 1][1]) and (FData[Yn].HoursN[i - 1][33] = FData[Yn].Hours[i - 1][33])) then
        Continue;
      Q.QExecSql('update w_schedule_periods set approved = :approved$i, hours = :hours$i where id_schedule = :id$i and dt = :dt$d', [FData[Yn].HoursN[i - 1][1], FData[Yn].HoursN[i - 1][33], ID, EncodeDate(y, i, 1)]);
    end;
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
  i, j, d, r: Integer;
  va: TVarDynArray;
  msg: string;
begin
  d := StrToIntDef(Copy(FrgHours.CurrField, 2, 2), -1);
  if d  = -1 then
    Exit;
  if FData[Yn].Holydays[FrgHours.RecNo - 1][d + 1] = -1 then
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
    [[cntNEdit, 'Заполнить график с даты "' + DateToStr(EncodeDate(y, FrgHours.RecNo, d)) + '" вперед на (месяцев):  ', '1:' + InttoStr(12 - FrgHours.RecNo + 1) + ':0:N']],
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
//    if r > 11 then      Break;
    FrgHours.SetValue('d' + IntToStr(j), r, False, FrgTemplate.GetValue('d' + IntToStr((i mod nedt_duration.Value) + 1), 0, False));
    //достигли 31го числа или день за концом месяца
    if (j = 31) or (FData[Yn].Holydays[r][j + 2] = -1) then begin
      IsHoursRowCorrect(r);
      //увеличим строку и сбросим номер дня
      r := r + 1;
      j := 0;
      //если заполнили за декабрь, или заполнили целевое количество строка, то выход
      if (r > 11) or (r > FrgHours.RecNo - 1 + va[0]) then
        Break;
    end;
    //увеличим счетчики
    Inc(j);
    Inc(i);
  end;
  FrgHours.InvalidateGrid;
end;

procedure TFrmWWedtWorkSchedule.SetControlsEditableState;
begin
  if Mode in [fView, fDelete] then
    Exit;
  //SetControlsEditable([chb_active, edt_code, edt_name, edt_comm, nedt_duration], False);
  SetControlsEditable([nedt_duration], (Mode = fAdd) or FAdminMode      or (Mode = fEdit));    //  !!! временно d FEdit
  FrgTemplate.DbGridEh1.ReadOnly := not ((Mode = fAdd) or FAdminMode     or (Mode = fEdit));
end;

function TFrmWWedtWorkSchedule.GetYn: Integer;
begin
  Result := tbcYear.TabIndex;
end;

function TFrmWWedtWorkSchedule.GetY: Integer;
begin
  Result := FData[tbcYear.TabIndex].Year;
end;

procedure TFrmWWedtWorkSchedule.tbcYearChange(Sender: TObject);
begin
  inherited;
  FrgHours.SetInitData(FData[Yn].Hours);
  FrgHours.RefreshGrid;
end;

procedure TFrmWWedtWorkSchedule.tbcYearChanging(Sender: TObject; var AllowChange: Boolean);
begin
  inherited;
  FData[Yn].HoursN := FrgHours.ExportToVa2;
end;

end.

