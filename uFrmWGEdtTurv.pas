unit uFrmWGEdtTurv;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls,
  DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls, DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd,
  ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils, Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh
  ;

type
  TFrmWGEdtTurv = class(TFrmBasicGrid2)
    procedure Frg1DbGridEh1RowDetailPanelShow(Sender: TCustomDBGridEh;  var CanShow: Boolean);
    procedure Frg1DbGridEh1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell,
      AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean);
    procedure Frg2DbGridEh1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell,
      AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean);
  private
    FPeriodStartDate: TDateTime;
    FPeriodEndDate: TDateTime;
    FDayColumnsCount: Integer;
    FIdDivision: Integer;
    FArrTitle: TVarDynArray2;
    FTurvCodes: TNamedArr;
    FArrTurv: array of array of array of Variant;
    FEditInGrid1: Boolean;
    FInEditMode: Boolean;
    FIsDetailGridUpdated: Boolean;
    FDayColWidth: Integer;


    function  PrepareForm: Boolean; override;
    function  LoadTurv: Boolean;
    function  LoadTurvCodes: Boolean;
    function  GetTurvCode(AValue: Variant): Variant;
    function  GetTurvCell(ARow, ADay, ANum: Integer): Variant;
    procedure PushTurvToGrid;
    procedure PushTurvCellToGrid(ARow, ADay: Integer);
    procedure PushTurvCellToDetailGrid(ARow, ADay: Integer);

    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;

    procedure Frg2ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
  public
  end;

var
  FrmWGEdtTurv: TFrmWGEdtTurv;

implementation

uses
  uTurv;

{$R *.dfm}

const
  cExists = 0;
  cTRuk = 1;               //время от мастеров
  cTPar =2;                //время парсек
  cTSogl = 3;              //время согласованное
  cCRuk = 4;               //код руководителя
  cCPar = 5;               //код парсек
  cCSog = 6;               //код согласованный
  cSumPr = 7;              //сумма премии
  cComPr = 8;              //комментарий к премии
  cSumSct = 9;             //сумма штрафа
  cComSct = 10;            //комментарий к штрафу
  cVyr = 11;               //сдана ли выработка
  cColor = 12;             //цвет фона
  cColorF = 13;            //цвет шрифта
  cComRuk = 14;            //комментарий руководителя
  cComPar = 15;            //комментарий парсека
  cComSogl = 16;           //ко мментрий по согласованному
  cBegTime = 17;           //время прихода по парсеку
  cEndTime = 18;           //время ухода по парсеку
  cSetTime = 19;           //если 1, то ячейка подсвечивается. устанавливается в 1 если нет одного из времен или работник по цеху вышел раньше. сбрасывается при вводе значения в парсек вручную          нет!!! - 1, когда время по парсеку worktime2 установлено
  cNight = 20 ;            //время в часах в ночную смену
  cItog = 21;              //итоговая строка, которая отображается

  cTlIdW = 0;             //id worker
  cTlIdJ = 1;             //id job
  cTlW = 2;               //workername
  cTlJ = 3;               //job
  cTlPremium = 5;         //премия за отчетный период
  cTlComm = 6;            //комментатрий, общий для работника
  cTlSchedule = 7;

  cTmM = 1;               //время или код от мастеров
  cTmP = 2;               //время или код парсек
  cTmV = 3;               //проверенное время или код

function TFrmWGEdtTurv.PrepareForm: Boolean;
var
  i, j: Integer;
  va2, flds1, flds2, values2: TVarDynArray2;
  Captions2: TVarDynArray;
begin
  Result := False;

  Caption:='~ТУРВ';

//  Mode := fEdit;
//  ID := 2234;

  Q.QLoadFromQuery('select id, id_division, code, name, dt1, dt2, committxt, commit, editusers, status from v_turv_period where id = :id$i', [ID], va2);

  if Length(va2) = 0 then
    Exit;

  FIdDivision := va2[0][1];
  FPeriodStartDate := va2[0][4];
  FPeriodEndDate := va2[0][5];
  FDayColumnsCount := DaysBetween(FPeriodEndDate, FPeriodStartDate) + 1;


  FDayColWidth := 40;

  //добавляем 16 колонок для дневных данных
  //заголовок соотвествует дню из даты
  //поле соответствует позиции в массиве
  //скроем столбцы, большие даты конца периода
  for i := 1 to 16 do begin
    flds1 := flds1 + [[
      'd' + IntToStr(i) + '$s',
      S.IIfStr(IncDay(FPeriodStartDate, i - 1) > FPeriodEndDate, '_') +
        //'Период|' +
        IntToStr(DayOf(IncDay(FPeriodStartDate, i - 1))) + ', '+ DaysOfWeek2[DayOfTheWeek(IncDay(FPeriodStartDate, i - 1))],
      IntToStr(FDayColWidth) + ';R',
      'e'
    ]];
    flds2 := flds2 + [[
      'd' + IntToStr(i) + '$s',
      S.IIfStr(IncDay(FPeriodStartDate, i - 1) > FPeriodEndDate, '_') +
        IntToStr(DayOf(IncDay(FPeriodStartDate, i - 1))) + ', '+ DaysOfWeek2[DayOfTheWeek(IncDay(FPeriodStartDate, i - 1))],
      IntToStr(FDayColWidth) + ';R',
      'e'
    ]];
  end;

  Frg1.Options := FrDBGridOptionDef + [myogPanelFind];
  Frg1.Opt.SetFields([
    ['x$s', '*','20'],
    ['worker$s','Работник|ФИО','200'],
    ['job$s','Работник|Должность','150'],
    ['schedule$s','Работник|График','60']
    ] + flds1 + [
    ['time$f', 'Итоги|Время', '50'] ,
    ['premium_p$f', 'Итоги|Премия за период', '50'],
    ['premium$f', 'Итоги|Премии', '50'],
    ['penalty$f', 'Итоги|Штрафы', '50'],
    ['comm$s', 'Итоги|Комментарий', '100']
  ]);
  Frg1.Opt.SetGridOperations('u');
  Frg1.Opt.SetButtons(1, [
    [mbtView],
    [mbtEdit],
    [],
    [mbtSendEMail],
    [mbtCustom_SundaysToTurv],
    [mbtLock],
    [],
    [mbtCtlPanel]
  ]);

  Frg1.SetInitData([], '');


 {
    DBGridEh1.ReadOnly:=not (InEditMode and EditInGrid1);
  Cth.GetSpeedBtn(pnl_Left, mbtView).Hint:='Итоговое время';
  Cth.GetSpeedBtn(pnl_Left, mbtView).Enabled:=EditInGrid1 and InEditMode;
  Cth.GetSpeedBtn(pnl_Left, mbtEdit).Hint:='Ввод времени руководителя';
  Cth.GetSpeedBtn(pnl_Left, mbtEdit).Enabled:=not EditInGrid1 and InEditMode and RgsEdit1;
  Cth.GetSpeedBtn(pnl_Left, mbtCustom_FromParsec).Hint:='Загрузить данные парсек';
  Cth.GetSpeedBtn(pnl_Left, mbtCustom_FromParsec).Enabled:= RgsEdit2 and InEditMode;
  Cth.GetSpeedBtn(pnl_Left, mbtSendEMail).Enabled:= RgsEdit2 and InEditMode;
  Cth.GetSpeedBtn(pnl_Left, mbtCustom_SundaysToTurv).Enabled:= InEditMode;
  //видимость кнопки Завершить период (она одна и завершает и отменяет завершение)
  //должны быть права
  //а также или режим редактирования исходный, или видна только в случае уже Завершенного периода, те позволит при просмотре только снять завершение, но не выставить
  //(так как тогда надо делать блокировку при установке завершения, ведь при просмотре может быть турв открыта у кого-то на редактирование!)
  Cth.GetSpeedBtn(pnl_Left, mbtLock).Enabled:=RgsCommit and (IsCommited or (Mode = fEdit));
  Cth.GetSpeedBtn(pnl_Left, mbtLock).Hint:=S.IIFStr(IsCommited, 'Отменить закрытие периода', 'Закрыть период');
  if (InEditMode)and(EditInGrid1) then begin
    st:='Ввод времени руководителя';
    stc:='$FF0060';
  end
  else if (InEditMode)and(not EditInGrid1) then begin
    st:='Ввод данных';
    stc:='$FF00FF';
  end
  else if IsCommited then begin
    st:='Только просмотр, период закрыт';
    stc:='$0000FF';
  end
  else begin
    st:='Только просмотр';
    stc:='$009000';
  end;
  lbl_Division.ResetColors;
  lbl_Division.SetCaptionAr([
    '$000000', 'Подразделение: ', '$FF0000', DivisionName,
    '$000000', '   Период с ', '$FF0000',  DateToStr(PeriodStartDate), '$000000 по $FF0000', DateToStr(PeriodEndDate),
    '$000000      [', stc, st, '$000000]'
    ]);
end;
}


  Frg2.Options := FrDBGridOptionDef;
  flds2 := [['type$s', 'Значение', '150']] + flds2;
  Frg2.Opt.SetFields(flds2);
  Frg2.Opt.SetGridOperations('u');

  Captions2 := ['Время (руководитель)', 'Время (парсек)', 'Время (согласованное)', 'Премия', 'Штраф'];
  for i := 0 to High(Captions2) do
    values2 := values2 + [[Captions2[i], null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null]];
  Frg2.SetInitData(values2, '');

  Result := inherited;
  if not (Result and LoadTurvCodes and LoadTurv) then
    Exit;

  PushTurvToGrid;

end;

function TFrmWGEdtTurv.LoadTurv: Boolean;
var
  i, j, k: Integer;
  v, vs: TVarDynArray2;
  v2: TVarDynArray;
  v1: Variant;
  dt, dt1, dtbeg, dtend: TDateTime;
  y, m: Integer;
  res: Integer;
  st: string;
begin
  //получим список работников для данного турв
  FArrTitle := [];
  FArrTurv := [];
  v := [];
  vs := [];
  v2 := [];
  v := Turv.GetTurvArrayFromDb(FIdDivision, FPeriodStartDate);
  Result := Length(v) > 0;
  if not Result then
    Exit;
  //проходим по списку
  for i := 0 to High(v) do begin
   //v:  0-дата1, 1-дата2, 2-айди работника, 3-имя работника, 4-фйди профессии, 5-назавание профессии, 6-после периода: 1=переведен 2=уволен
    SetLength(FArrTitle, i + 1, 8);
    SetLength(FArrTurv, i + 1, 31, cItog + 1);
    //массив заголовков (работник, должность...)
    FArrTitle[i][cTlIdW] := v[i][2];  //id worker
    FArrTitle[i][cTlIdJ] := v[i][4];  //id job
    FArrTitle[i][cTlW] := v[i][3];    //workername
    FArrTitle[i][cTlJ] := v[i][5];    //job
    FArrTitle[i][4] := '';            //ccegory
    FArrTitle[i][cTlPremium] := 0;    //премия за отчетный период
    FArrTitle[i][cTlComm] := '';      //комментатрий, общий для работника
    FArrTitle[i][cTlSchedule] := '5/2';
    //читаем турв_дей в для данного работника в промежутке, в котором он в этом ТУРВ, сортируем по дате
    vs := Q.QLoadToVarDynArray2(
      'select dt, worktime1, worktime2, worktime3, id_turvcode1, id_turvcode2, id_turvcode3, premium, premium_comm, penalty, penalty_comm, production, ' +
      'null, null, comm1, comm2, comm3, begtime, endtime, settime3, nighttime ' +
      'from turv_day where id_worker = :id_worker$i and dt >= :dtbeg$d and dt <= :dtend$d order by dt',
       [FArrTitle[i][cTlIdW], v[i][0], v[i][1]]
    );
    //проход по массиву турв
    for j := 1 to 16 do begin
      //заполним нулл
      for k := 0 to cItog do
        FArrTurv[i][j][k] := null;
      //если меньше начально или больше конечной даты, то признак что данной клетки в турв нет
      if (IncDay(FPeriodStartDate, j - 1) < v[i][0]) or (IncDay(FPeriodStartDate, j - 1) > v[i][1]) then
        FArrTurv[i][j][0] := -1
      else begin
        FArrTurv[i][j][cExists] := 0;
        for k := 0 to High(vs) do
          if DayOf(vs[k][0]) = DayOf(FPeriodStartDate) + j - 1 then begin
            //клетка есть в турв и бд
            FArrTurv[i][j][cExists] := 1;    //id
            FArrTurv[i][j][cTRuk] := vs[k][1];    //время от мастеров
            FArrTurv[i][j][cTPar] := vs[k][2];    //время парсек
            FArrTurv[i][j][cTSogl] := vs[k][3];    //время согласованное
            FArrTurv[i][j][cCRuk] := vs[k][4];    //код от мастеров
            FArrTurv[i][j][cCPar] := vs[k][5];    //код от парсек
            FArrTurv[i][j][cCSog] := vs[k][6];    //код согласованное
            FArrTurv[i][j][cSumPr] := vs[k][7];    //сумма премии
            FArrTurv[i][j][cComPr] := vs[k][8];     //комментарий к премии
            FArrTurv[i][j][cSumSct] := vs[k][9];    //сумма штрафа
            FArrTurv[i][j][cComSct] := vs[k][10];     //комментарий к штрафу
            FArrTurv[i][j][cVyr] := vs[k][11];    //сдана ли выработка
            FArrTurv[i][j][cComRuk] := vs[k][14];    //комментарий руководителя
            FArrTurv[i][j][cComPar] := vs[k][15];    //комментрий по парсеку
            FArrTurv[i][j][cComSogl] := vs[k][16];    //комментрий по согласованному
            FArrTurv[i][j][cBegTime] := vs[k][17];    // время прихода по парсеку
            FArrTurv[i][j][cEndTime] := vs[k][18];    //время ухода по парсеку
            FArrTurv[i][j][cSetTime] := vs[k][19];    //1, когда время по парсеку worktime2 установлено
            FArrTurv[i][j][cNight] := vs[k][20];    //время в ночную смену
          end;
      end;
    end;
    //прочитаем из БД премии и штрафы
    vs := Q.QLoadToVarDynArray2(
      'select premium, comm from turv_worker where id_worker = :id_worker$i and id_division = :id_division$i and id_job = :id_job$i and dt1 = :dt1$d',
      [FArrTitle[i][0], FIDDivision, FArrTitle[i][1], FPeriodStartDate]
    );
    if Length(vs) > 0 then begin
      FArrTitle[i][cTlPremium] := vs[0][0];
      FArrTitle[i][cTlComm] := vs[0][1];
    end;
  end;
end;

function TFrmWGEdtTurv.LoadTurvCodes: Boolean;
//загрузим справочник кодов турв
begin
  Result := False;
  Q.QLoadFromQuery('select id, code, name from ref_turvcodes order by code', [], FTurvCodes);
  Result := True;
end;


function TFrmWGEdtTurv.GetTurvCode(AValue: Variant): Variant;
//получим код турв по айди этого кода
var
  i: Integer;
begin
  Result := null;
  i := A.PosInArray(AValue, FTurvCodes.V, 0);
  if i >= 0 then
    Result := FTurvCodes.V[i][1];
end;

function TFrmWGEdtTurv.GetTurvCell(ARow, ADay, ANum: Integer): Variant;
begin
  if FArrTurv[ARow][ADay][ANum] <> null then
    Result := FArrTurv[ARow][ADay][ANum]
  else
    Result := GetTurvCode(FArrTurv[ARow][ADay][ANum + 3]);
end;

procedure TFrmWGEdtTurv.PushTurvToGrid;
var
  i, j: Integer;
begin
  for i := 0 to High(FArrTitle) do begin
    Frg1.MemTableEh1.Last;
    Frg1.MemTableEh1.Insert;
    Frg1.MemTableEh1.FieldByName('worker').Value := FArrTitle[i][cTlW];
    Frg1.MemTableEh1.FieldByName('job').Value := FArrTitle[i][cTlJ];
    Frg1.MemTableEh1.FieldByName('schedule').Value := FArrTitle[i][cTlSchedule];
    Frg1.MemTableEh1.Post;
    for j := 1 to 16 do begin
      PushTurvCellToGrid(i, j);
    end;
  end;
end;

procedure TFrmWGEdtTurv.PushTurvCellToGrid(ARow, ADay: Integer);
//отобразим ячейку в общем гриде на основании массива данных
var
  st: string;
  v, v0, v1, v2: Variant;
  color: Integer;
  i, j: Integer;
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
  v := FArrTurv[ARow][ADay][0];
  //получим автоматически номер активной строки грида
  if ARow = -1 then
    ARow := Frg1.MemTableEh1.RecNo - 1;
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
  if (FEditInGrid1) and (FInEditMode) then
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
  Frg1.SetValue('premium_p', ARow, False, FormatFloat('0.00', S.NNum(FArrTitle[ARow][cTlPremium])));
  Frg1.SetValue('premium', ARow, False, FormatFloat('0.00', S.NNum(sum[1])));
  Frg1.SetValue('penalty', ARow, False, FormatFloat('0.00', S.NNum(sum[2])));
    //кнопка Закрыть период  //!!!
{  Status := 1;
  for j := 0 to High(ArrTurv) do begin
    for i := 1 to DayColumnsCount do begin
      if (ArrTurv[j][i][atColor] = -1) and (Status = 1) then
        Status := 2;
      if ArrTurv[j][i][atColor] = 1 then
        Status := 3;
      if Status = 3 then
        break
    end;
    if Status = 3 then
      break
  end}
end;

procedure TFrmWGEdtTurv.PushTurvCellToDetailGrid(ARow, ADay: Integer);
//отобразим ячейку в общем гриде на основании массива данных
var
  i: Integer;
  st: string;
  v1, v2, v3: Variant;
begin
  if (not Frg2.MemTableEh1.Active) or (Frg1.GetCount(False) = 0) then
    Exit;
  //получим автоматически номер активной строки грида
  if ARow = -1 then
    ARow := Frg1.RecNo - 1;
  //клетка не входит в данный турв
//  if VarType(ArrTurv[ARow][ADay][0]) <> varInteger then exit;
  if FArrTurv[ARow][ADay][0] = -1 then begin
    //сделаем все пустые и выйдем
    for i := 0 to 4 do
      Frg2.SetValue('d' + IntToStr(ADay), i, False, null);
    exit;
  end;
  //изменим напрямую во внутреннем массиве данных
  //при этом на экране отображения только после получения гридом фокуса, переключение фокуса оставляем за вызывающим
  v1 := GetTurvCell(ARow, ADay, cTmM);
  v2 := GetTurvCell(ARow, ADay, cTmP);
  v3 := GetTurvCell(ARow, ADay, cTmV);
  //форматируем строку, если число
  if S.IsNumber(S.NSt(v1), 0, 24) then
    st := FormatFloat('0.00', S.VarToFloat(v1))
  else
    st := S.NSt(v1);
  Frg2.SetValue('d' + IntToStr(ADay), 0, False, st);
  if S.IsNumber(S.NSt(v2), 0, 24) then
    st := FormatFloat('0.00', S.VarToFloat(v2))
  else
    st := S.NSt(v2);
  Frg2.SetValue('d' + IntToStr(ADay), 1, False, st);
  if S.IsNumber(S.NSt(v3), 0, 24) then
    st := FormatFloat('0.00', S.VarToFloat(v3))
  else
    st := S.NSt(v3);
  Frg2.SetValue('d' + IntToStr(ADay), 2, False, st);
  //премии и штрафы
  if (FArrTurv[ARow][ADay][cSumPr] <> null) then begin
    st := FormatFloat('0', S.NNum(FArrTurv[ARow][ADay][cSumPr]));
    Frg2.SetValue('d' + IntToStr(ADay), 3, False, st);
  end
  else
    Frg2.SetValue('d' + IntToStr(ADay), 3, False, null);
  if (FArrTurv[ARow][ADay][cSumSct] <> null) then begin
    st := FormatFloat('0', S.NNum(FArrTurv[ARow][ADay][cSumSct]));
    Frg2.SetValue('d' + IntToStr(ADay), 4, False, st);
  end
  else
    Frg2.SetValue('d' + IntToStr(ADay), 4, False, null);
  Frg2.DbGridEh1.Invalidate;
end;









procedure TFrmWGEdtTurv.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
var
  Row, Day: Integer;
  Color: Integer;
begin
  if Params.Row = 0 then
    Exit;
  Row := Params.Row - 1;
  Day := StrToIntDef(Copy(FieldName, 2, 2), -1);
//if (Row < 0) or (Day > 16) then begin
//  Params.Background := clBlue; exit; end;
  if Day <> -1 then begin
    case FArrTurv[Row][Day][cColor] of
      1 : Params.Background := clRed;
      2 : Params.Background := clYellow;
      -1: Params.Font.Color := clRed;
    end;
  end
  else Params.Background := clmyGray;
end;

procedure TFrmWGEdtTurv.Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
                           var
  st, st1, stc: string;
  v: Variant;
  rsd: TVarDynArray;
  e,e1: extended;
  i,j,r,d,rd: Integer;
  dt : TDateTime;
  sa1: TStringDynArray;
begin
  FIsDetailGridUpdated:= TDBGridColumnEh(Sender).Grid = Frg2.DBGridEh1;

  if UseText
    then st:=Text
    else st:=VarToStr(Value);

  r:=Frg1.RecNo-1;

  if FIsDetailGridUpdated
    then begin
      d:=Frg2.DBGridEh1.Col-1;
      rd:=Frg1.RecNo-1;
    end
    else begin
      d:=Frg1.DBGridEh1.Col-3;
      rd:=0;
    end;
  dt := IncDay(FPeriodStartDate, d-1);
  if d < 1 then exit;
  if rd < 3 then begin
    UseText:=True;
    //выделим комментарий - часть введенной строки после прямого слэша
    //!!! работает неправильно если есть слэши в коде турв или его описании, если в коде то он вообще не будет введен!!!
    stc:='~'; //признак что комменатрий не изменился
    sa1:=A.ExplodeS(st, '/');
    st:=sa1[0];
    if High(sa1) > 0
      then begin
        stc:=sa1[1];
        for i:=2 to High(sa1) do stc:=stc + '/' + sa1[i];
        stc:=trim(stc);
      end;
    if not S.IsNumber(st,0.01,24,2)
      then begin
        //не число, пытаемся вытащить код
        FArrTurv[r][d][cTRuk+rd]:=null;
        FArrTurv[r][d][cCRuk+rd]:=null;
        i:=pos(' - ', st);
        if i > 0 then st1:=copy(st,1,i - 1) else st1:=st;
        st:= '';
{        for i:= 0 to TurvCodes.Count-1 do
          if UpperCase(st1) = UpperCase(TurvCodes[i])
            then begin
              st:= TurvCodes[i];
              ArrTurv[r][d][atTRuk+rd]:=null;
              ArrTurv[r][d][atCRuk+rd]:=TurvCodesIds[i];
            end;}
      end
      else if dt > Date then begin
        //чиисло, но дата больше текущей
        FArrTurv[r][d][cTRuk-1+Frg1.RecNo]:=null;
        FArrTurv[r][d][cCRuk-1+Frg1.RecNo]:=null;
      end
      else begin
        //если число от 0 до 24
        //округляем до четверти часа, не менее 0.25
        e:=StrToFloat(st);
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
        e1:=e;
        //форматируем до двух знаков после запятой
        st:=FormatFloat('0.00', e1);
        FArrTurv[r][d][cTRuk+rd]:=e1;
        FArrTurv[r][d][cCRuk+rd]:=null;
      end;
    //комментарий
    if stc <> '~'
      then FArrTurv[r][d][cComRuk+rd]:=stc;
    //сбросим подсветку синим при отсутствии одного из времен парсек
    if rd = 1
      then FArrTurv[r][d][cSetTime]:=null;
  end;
  //событие обработано
  Handled:=True;
  //отобразим данные в основной таблице
  PushTurvCellToGrid(r,StrToInt(Copy(TDBGridColumnEh(Sender).FieldName, 2,2)));
  //отобразим данные в детальной таблице
  PushTurvCellToDetailGrid(r,StrToInt(Copy(TDBGridColumnEh(Sender).FieldName, 2,2)));
  //сменим фокус чтобы отобразить изменения в таблицах на экране
//  Timer_AfterUpdate.Enabled:=True;
  //сохраним в бд
  rsd:=[cTRuk, cTPar, cTSogl, cTRuk, cTRuk];
//!!!  SaveDayToDB(r, StrToInt(Copy(TDBGridColumnEh(Sender).FieldName, 2, 2)), rsd[rd]);
end;


procedure TFrmWGEdtTurv.Frg1DbGridEh1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell, AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean);
//отрисуем ячейку
var
  v1, v2, v3, v4: Variant;
  ARow, c: Integer;
begin
  inherited;
  //рисуем только столбцы с днями
  if (Params.Col < 5) or (Params.Col > 5 + 16 - 1) then  //!!!
    Exit;
  //получим комментарии
  v1 := FArrTurv[Params.row - 1][Params.Col - 4][cComRuk];
  v2 := FArrTurv[Params.row - 1][Params.Col - 4][cComPar];
  v3 := FArrTurv[Params.row - 1][Params.Col - 4][cComSogl];
  v4 := FArrTurv[Params.row - 1][Params.Col - 4][cNight];
  //если выйдем, то будет стандартная отрисовка
  //выйдем, если нет никакого комментария
  if (((VarIsEmpty(v1)) or (S.NSt(v1) = '')) and ((VarIsEmpty(v2)) or (S.NSt(v2) = '')) and ((VarIsEmpty(v3)) or (S.NSt(v3) = '')) and ((VarIsEmpty(v4)) or (S.NNum(v4) = 0))) then
    Exit;
  //стандартная отрисовка
  TDBGridEh(Sender).DefaultDrawColumnDataCell(Cell, AreaCell, Column, ARect, Params);
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

procedure TFrmWGEdtTurv.Frg1DbGridEh1RowDetailPanelShow(Sender: TCustomDBGridEh; var CanShow: Boolean);
var
  i: Integer;
begin
  Frg1.DbGridEh1RowDetailPanelShow(Sender, CanShow);
//  SetRowDetailCaptions;
  //заполним сетки
  for i := 1 to 16 do begin
    PushTurvCellToDetailGrid(-1, i);
  end;
//  SetBtns;
end;

procedure TFrmWGEdtTurv.Frg2ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
var
  Row, Day: Integer;
  Color: Integer;
begin
  Row := Params.Row - 1;
  Day := StrToIntDef(Copy(FieldName, 2, 2), -1);
  if Day <> -1 then begin
{    case FArrTurv[Row][Day][cColor] of
      1 : Params.Background := clRed;
      2 : Params.Background := clYellow;
      -1: Params.Font.Color := clRed;
    end;}
  end
  else Params.Background := clmyGray;
end;



procedure TFrmWGEdtTurv.Frg2DbGridEh1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell, AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean);
var
  v1, v2, v3: Variant;
  r, c: Integer;
begin
  inherited;
  //рисуем только столбцы с днями
  if (Params.Col <= 1) or (Params.Col > 1 + 16 - 1) then
    Exit;
  //получим комментарии
  case Params.Row of
    1..3:
      v1 := FArrTurv[Frg1.RecNo - 1][Params.Col - 1][cComRuk + Params.row - 1];
    4:
      v1 := FArrTurv[Frg1.RecNo - 1][Params.Col - 1][cComPr];
    5:
      v1 := FArrTurv[Frg1.RecNo - 1][Params.Col - 1][cComSct];
  end;
  v2 := null;
  if Params.Row = 2 then
    v2 := FArrTurv[Frg1.RecNo - 1][Params.Col - 1][cNight];
  //если выйдем, то будет стандартная отрисовка
  //выйдем, если нет никакого комментария
  if (VarToStr(v1) = '') and (VarToStr(v2) = '') then
    Exit;
  //стандартная отрисовка
  TDBGridEh(Sender).DefaultDrawColumnDataCell(Cell, AreaCell, Column, ARect, Params);
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

end.
