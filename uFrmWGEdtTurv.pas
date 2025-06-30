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
  private
    FPeriodStartDate: TDateTime;
    FPeriodEndDate: TDateTime;
    FIdDivision: Integer;
    FDayColWidth: Integer;
    FArrTitle: TVarDynArray2;
    FTurvCodes: TNamedArr;
    FArrTurv: array of array of array of Variant;
    function  PrepareForm: Boolean; override;
    function  LoadTurv: Boolean;
    procedure LoadTurvCodes;
    function  GetTurvCode(AValue: Variant): Variant;
    function  GetTurvCell(ARow, ADay, ANum: Integer): Variant;
    procedure PushTurvToGrid;
    procedure PushTurvCellToGrid(r, d: Integer);
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

function TFrmWGEdtTurv.PrepareForm: Boolean;
var
  i, j: Integer;
  va2: TVarDynArray2;
begin
  Result := False;

  Mode := fEdit;

  FPeriodStartDate :=  EncodeDate(2025, 06, 01);
  FPeriodEndDate :=  EncodeDate(2025, 06, 15);
  FDayColWidth := 30;

  Caption:='~ТУРВ';

  //добавляем 16 колонок для дневных данных
  //заголовок соотвествует дню из даты
  //поле соответствует позиции в массиве
  //скроем столбцы, большие даты конца периода
  for i := 1 to 16 do begin
    va2 := va2 + [[
      'd' + IntToStr(i) + '$f',
      S.IIfStr(IncDay(FPeriodStartDate, i - 1) > FPeriodEndDate, '_') +
        'Период|' + IntToStr(DayOf(IncDay(FPeriodStartDate, i - 1))) + ', '+ DaysOfWeek2[DayOfTheWeek(IncDay(FPeriodStartDate, i - 1))],
      IntToStr(FDayColWidth),
      'e'
    ]];
  end;

  Frg1.Opt.SetFields([
//  ['id$i','_id','40'],
    ['x$s', '*','20'],
    ['worker$s','Работник|ФИО','200'],
    ['job$s','Работник|Должность','100'],
    ['r$i','_Работник|Разряд','0']
    ] + va2 + [
    ['premium_p$f', 'Итоги|Время', '50'] ,
    ['time$f', 'Итоги|Премия за период', '50'],
    ['premium$f', 'Итоги|Премии', '50'],
    ['penalty$f', 'Итоги|Штрафы', '50'],
    ['comm$s', 'Итоги|Комментарий', '100']
  ]);
  Frg1.Opt.SetGridOperations('u');
  Frg1.SetInitData([], '');
//  Frg1.Opt.SetTable('v_ref_work_schedules');

  Result := inherited;
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
  FArrTitle:=[];
  FArrTurv:=[];
  v:=[];
  vs:=[];
  v2:=[];
  v:=Turv.GetTurvArrayFromDb(FIdDivision, FPeriodStartDate);
  Result:=Length(v) > 0;
  if not Result then Exit;
  //проходим по списку
  for i := 0 to High(v) do begin
   //v:  0-дата1, 1-дата2, 2-айди работника, 3-имя работника, 4-фйди профессии, 5-назавание профессии, 6-после периода: 1=переведен 2=уволен
    SetLength(FArrTitle, i + 1, 7);
    SetLength(FArrTurv, i + 1, 31, cItog + 1);
    //массив заголовков (работник, должность...)
    FArrTitle[i][0] := v[i][2];  //id worker
    FArrTitle[i][1] := v[i][4];  //id job
    FArrTitle[i][2] := v[i][3];  //workername
    FArrTitle[i][3] := v[i][5];  //job
    FArrTitle[i][4] := '';       //ccegory
    FArrTitle[i][5] := 0;        //премия за отчетный период
    FArrTitle[i][6] := '';       //комментатрий, общий для работника
    //читаем турв_дей в для данного работника в промежутке, в котором он в этом ТУРВ, сортируем по дате
    vs := Q.QLoadToVarDynArray2(
      'select dt, worktime1, worktime2, worktime3, id_turvcode1, id_turvcode2, id_turvcode3, premium, premium_comm, penalty, penalty_comm, production, ' +
      'null, null, comm1, comm2, comm3, begtime, endtime, settime3, nighttime ' +
      'from turv_day where id_worker = :id_worker$i and dt >= :dtbeg$d and dt <= :dtend$d order by dt',
       [FArrTitle[i][0], v[i][0], v[i][1]]
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
      FArrTitle[i][5] := vs[0][0];
      FArrTitle[i][6] := vs[0][1];
    end;
  end;
end;

procedure TFrmWGEdtTurv.LoadTurvCodes;
//загрузим справочник кодов турв
begin
  Q.QLoadFromQuery('select id, code, name from ref_turvcodes order by code', [], FTurvCodes);
end;


function TFrmWGEdtTurv.GetTurvCode(AValue: Variant): Variant;
//получим код турв по айди этого кода
var
  i: Integer;
begin
  Result:=null;
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
  i, j, k: Integer;
begin
  for i := 0 to High(ArrTitle) do begin
    MemTableEh1.Last;
    MemTableEh1.Insert;
    MemTableEh1.FieldByName('name').Value := ArrTitle[i][2];
    MemTableEh1.FieldByName('job').Value := ArrTitle[i][3];
    MemTableEh1.FieldByName('category').Value := null; //ArrTitle[i][4];
    MemTableEh1.Post;
    for j:=1 to 16 do begin
      SetTurvAllDay(i, j);
    end;
  end;
end;

//отобразим ячейку в общем гриде на основании массива данных
procedure TFrmWGEdtTurv.PushTurvCellToGrid(r, d: Integer);
var
  st:string;
  v,v0,v1,v2,v3,v4: Variant;
  color: Integer;
  i,j: Integer;
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
//exit;
//  можно делать так или так, но таблица должна находиться в состоянии изменения
//  DbGridEh1.FieldColumns['d'+ IntToStr(d)].Field.Value:=ArrTurv[DBGridEh1.Row][d][1];
//  MemTableEh1.FieldByName('d'+ IntToStr(d)).Value:=ArrTurv[r][d][1];
v:=ArrTurv[r][d][0];
  //получим автоматически номер активной строки грида
  if r = -1 then r:=MemTableEh1.RecNo-1;

//  if ArrTurv[r][d][0] <> 1 then begin //иначе данные не загружены в ячейку, и не могут быть изменены

    v0:=GetTurvCell(r,d,3);  //проверенное время или код
    v1:=GetTurvCell(r,d,1);  //время или код от мастеров
    v2:=GetTurvCell(r,d,2);  //время или код парсек
    color:=0;
    //если задано проверенное время/код, то выводим его, иначе выводим от мастеров
    if v0 = null then begin
      if (v1 = null)and(v2 = null)
        then begin
          color:=0;
        end
        else if (v1<>null)and(v2=null)
        then begin
          color:=2;   //жетлтый
          v0:=v1;
        end
        else if (v1 = null)and(v2 <> null)
        then begin
          color:=1;   //красный
          v0:=v2;
        end
        else if (not S.IsNumber(S.NSt(v1),0,24)) and (not S.IsNumber(S.NSt(v2),0,24))
        then begin
          v0:=v2;
        end
        else if S.IsNumber(S.NSt(v1),0,24) and S.IsNumber(S.NSt(v2),0,24) and (abs(StrToFloat(S.NSt(v1)) - StrToFloat(S.NSt(v2))) <= Module.GetCfgVar(mycfgWtime_autoagreed))
        then begin
          v0:=v2;
          if v1 <> v2 then color:=-1; //красный цвет шрифта
        end
        else begin
          v0:=v2;
          color := 1;
        end;
    end;
{
if v1 = '5,5' then begin
  b:= S.IsNumber(S.NSt(v1),0,24) ;
  st:= VarToStr(S.NSt(v1));
  v4:=GetTurvCell(r,d,1);
end;
}
    ArrTurv[r][d][atColor]:=color;
    //при редактировании в основном гриде будем отображать в нем время от мастеров/руководителя
    if (EditInGrid1)and(InEditMode) then v0:=v1;
    //форматируем строку, если число
    if S.IsNumber(S.NSt(v0),0,24) then st:=FormatFloat('0.00', S.VarToFloat(v0)) else st:=S.NSt(v0);
    //изменим напрямую во внутреннем массиве данных
    //при этом на экране отображения только после получения гридом фокуса, переключение фокуса оставляем за вызывающим
    MemTableEh1.RecordsView.MemTableData.RecordsList[r].DataValues['d'+ IntToStr(d),dvvValueEh]:=st;
//end;
//exit;

  //итоги в правой части таблицы
  Setlength(sum, 3);
  b:=True;
  //цикл по дням
  for i:=1 to DayColumnsCount do
    begin
      //время - от мастеров, если установлено парсек то парсек, если установлено согласованное то оно
      e:= S.NNum(ArrTurv[r][i][1]);
      if (ArrTurv[r][i][2] <> null) or (ArrTurv[r][i][5] <> null) then e := S.NNum(ArrTurv[r][i][2]);
      if (ArrTurv[r][i][3] <> null) or (ArrTurv[r][i][6] <> null) then e := S.NNum(ArrTurv[r][i][3]);
      sum[0] := sum[0] + e;
      sum[1] := sum[1] + S.NNum(ArrTurv[r][i][7]);
      sum[2] := sum[2] + S.NNum(ArrTurv[r][i][9]);
      //ячейки красные и желтые, или пустые итоговые и при этом не серые - не даем возможности закрыть турв
      if (S.NNum(ArrTurv[r][i][12]) = 1)or(S.NNum(ArrTurv[r][i][12]) = 2)or
         ((ArrTurv[r][i][0] <> -1) and (ArrTurv[r][i][1]) = null)
        then b:=False;
    end;
  //заполним итоговые ячейки мемтейбл
  MemTableEh1.RecordsView.MemTableData.RecordsList[r].DataValues['time', dvvValueEh]:=FormatFloat('0.00', S.NNum(sum[0]));
  MemTableEh1.RecordsView.MemTableData.RecordsList[r].DataValues['premium_p', dvvValueEh]:=FormatFloat('0.00', S.NNum(ArrTitle[r][5]));
  MemTableEh1.RecordsView.MemTableData.RecordsList[r].DataValues['premium', dvvValueEh]:=FormatFloat('0.00', S.NNum(sum[1]));
  MemTableEh1.RecordsView.MemTableData.RecordsList[r].DataValues['penalty', dvvValueEh]:=FormatFloat('0.00', S.NNum(sum[2]));
  //кнопка Закрыть период
  Status:=1;
  for j:= 0 to High(ArrTurv) do begin
    for i:=1 to DayColumnsCount do
      begin
        if (ArrTurv[j][i][atColor] = -1)and(Status = 1) then Status:=2;
        if ArrTurv[j][i][atColor] = 1 then Status:=3;
        if Status = 3 then break
      end;
    if Status = 3 then break
  end
  //Bt_Commit.Enabled:=b; //!!!
end;



(*
//отрисуем ячейку
procedure TDlg_TURV.DBGridEh1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell,
  AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect;
  var Params: TColCellParamsEh; var Processed: Boolean);
var
  v1, v2, v3, v4: Variant;
  r, c: Integer;
begin
  inherited;
  //рисуем только столбцы с днями
  if (Params.Col<5)or(Params.Col>5+16-1) then Exit;
//  v:=MemTableEh1.RecordsView.MemTableData.RecordsList[Params.row-1].DataValues['d'+ IntToStr(Params.Col-4),dvvValueEh];
  //получим комментарии
  v1:=ArrTurv[Params.row-1][Params.Col-4][atComRuk];
  v2:=ArrTurv[Params.row-1][Params.Col-4][atComPar];
  v3:=ArrTurv[Params.row-1][Params.Col-4][atComSogl];
  v4:=ArrTurv[Params.row-1][Params.Col-4][atNight];
  //если выйдем, то будет стандартная отрисовка
//  if (v<>'8.00')and(v<>'8,00')  then exit;
  //выйдем, если нет никакого комментария
  if (((VarIsEmpty(v1))or(S.NSt(v1) = '')) and ((VarIsEmpty(v2))or(S.NSt(v2) = '')) and ((VarIsEmpty(v3))or(S.NSt(v3) = '')) and ((VarIsEmpty(v4))or(S.NNum(v4) = 0))) then Exit;
  //стандартная отрисовка
  TDBGridEh(Sender).DefaultDrawColumnDataCell(Cell, AreaCell, Column, ARect, Params);
  if S.NSt(v1) + S.NSt(v2) + S.NSt(v3) <> '' then begin
    //и поверху квадратик комментария
    TDBGridEh(Sender).Canvas.Pen.Width:=1;
    //если есть комментарии проверенное/согласованное, то подсветим бирюзовым, если только мастер, то синим
    if (VarToStr(v2) <> '')or(VarToStr(v3) <> '')
      then TDBGridEh(Sender).Canvas.Brush.Color:=RGB(255,0,255)
      else TDBGridEh(Sender).Canvas.Brush.Color:=clBlue;
    //нарисуем прямоугольник в верхнем левом углу ячейки
    TDBGridEh(Sender).Canvas.Rectangle(ARect.Left, ARect.Top , ARect.Left+7, ARect.Top+7);
  end;
  if S.NNum(v4) <> 0 then begin
    TDBGridEh(Sender).Canvas.Pen.Width:=1;
    TDBGridEh(Sender).Canvas.Brush.Color:=clBlack;
    //нарисуем прямоугольник в левом нижнем углу ячейки
    TDBGridEh(Sender).Canvas.Rectangle(ARect.Left, ARect.Bottom - 7 , ARect.Left+7, ARect.Bottom);
  end;
  //флаг что обработати, если не поставить то будет стандартная отрисовка
  Processed:=True;
end;
*)

end.
