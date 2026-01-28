{
все изменения параметров работника, влияющих на з/п, турв и т.д. сохраняются в таблице свойств работников (сохраняется конкретный набор свойств, с уникальным айди)
при каждом изменении любого из свойств работника или их набора создается новая запись в таблице
для каждой записи предусмотрены начальная и конечная дата действия, если конечной нет, то действует сейчас
новую запись можно создать как с началом действия в будущем, так и в прошлом, но не ранее даты начала действия последней открытой записи рапботника (той же датой).
в случае создания новой записи начальной датой той же, что и действующая, новая запись не создается а изменяются параметры действующей без изменения айди
в случае создания датой позже, проставляется дата окончания действия предыдущей записи, равная дню ранее начала созданной
запись увольнения обрабатывается особым образом, все свойства в ней проставляются равными последней записи, дата окончания отстуствует, дата начала может быть
  равной началу предыдущей, но при этом ее не заменяет, дата окончания предыдущей проставляется днем увольнения а не прошлым днем.
запись приема может быть поставлена только первой для работника либо после записи увольнения, запись увольнения - не первой и не после записи увольнения
в диалоге добавления записи могут быть проставлены все свойства и дата начала действия статуса. организация и табельный номер вводится при риеме на работу,
  но оба поля вместе могут быть оставлены пустыми. в этом случае они могут быть заполнены в новой записи статуса, но после заполения уже не могут быть изменены.
в диалоге увольнения можно проставить только дату.
в любом диалоге мможно также проставить комментарий.
табельный номер уникален среди работников организзации, когда-либо работавших в ней и не может быть повторно выдан, работнику при повторном приеме выдается уже
  новый номер. проверяется не на уровне бд а в диалоге.
все записи статусов работников не зависят от статусов других работников.
исключение составляет статус Бригадир, так как в одно и то же времия для одного ТУРВ допустим только один (или ни одного) бригадира.
  данная ситуация обрабатывается особым образом, если задается статус бригадира и в турв данного подразделения после и в дату начала действия статуса
  в статусах других работников этого подразделения есть признак Бригадир, то он снимается в их статусах без фформирования новой записи, с изменением свойства
  на Отменен для контроля.

данные по дням турв (ячейкам) содержатся в общей таблице, в пк (дата, айди статуса).

состав работников турв формируется на основе выборки из таблицы статусов работников, путем фильтрации по подразделению и получению айди строк таблицы,
дата начала которых не позднее окончания периода турв, а дата окончания - отстутсвует или позднее даты начала периода турв. записи увольнения при
  формировании турв исключаются из обработки.

ячейки турв получаются чтением ячееек turv_cell за период турв по всем отфильтрованным строкам w_employee_properties, каждая строка турв в результате соответсвует
  отдельной строке статуса, то есть любое изменение статуса порождает новую строку. объединение по нужным параметрам производится в диалоге турв.

}

unit uTurv;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DBCtrlsEh, Buttons, DBGridEh, DBAxisGridsEh, GridsEh,
  ToolCtrlsEh, DBGridEhToolCtrls,
  MemTableDataEh, Db, Math, ExtCtrls,
  IniFiles, SearchPanelsEh,
  PropFilerEh, ActnList, Jpeg, uString, PngImage, DateUtils,
  uData, uForms;

type
  TTurv = class(TObject)
  private
  public
    constructor Create;
    function GetWorkerStatusArr(id: Integer): TVarDynArray2;
    //возвращаем начало периода турв, в колтором находится дата
    function GetTurvBegDate(dt: TDateTime): TDateTime;
    //возвращаем конец периода турв, в колтором находится дата
    function GetTurvEndDate(dt: TDateTime): TDateTime;
    function GetTurvArray(DivisionId: Integer; dt: TDateTime; SortByJob: Boolean = True): TVarDynArray2;
    function GetTurvArrayFromDB(DivisionId: Integer; dt: TDateTime; SortByJob: Boolean = True): TNamedArr;
    function GetcodeUV: Integer;
    function GetcodePER: Integer;
    function CreateTURV(DivisionId: Variant; AllDivisions: Integer; ActiveOnly: Boolean; dt: TDateTime; Silent: Boolean = True): Integer;
    function Synchronize(ID_Division: Integer; dt: TDateTime): Boolean;
    function ChangeWorkerInTURV(Id_Worker:Variant; ID_Division: Variant; ID_Job: Variant; Dt: TDateTime; ID_JStatus: Variant; Mode: Variant): Boolean;
    function DeleteTURV(ID: Integer; Silent: Boolean = False): Boolean;
    function GetWorkersNotInParsec(Mailing: Boolean=False): TVarDynArray2;
    function GetActiveWorkers: TVarDynArray2;
    function GetStatus(ID_Division: Integer; dt: TDateTime): Integer;
    function LoadParsecData: Boolean;
    function LoadParsecDataNew: Boolean;
    function GetDaysFromCalendar(DtBeg, DtEnd: TDateTime): TVarDynArray2;
    function GetDaysFromCalendar_Next(DtBeg: TDateTime; CntOfWork: Integer): TDateTime;
    //диалог ввода графика работы и норм рабочего времени по нему
    function ExecureWorkCheduleDialog(AOwner: TComponent; AId: Variant; AMode: TDialogType): Boolean;
    //диалог ввода для справочника первоняльных надбавок
    //данные надбавки и суммы за текущий и следующий месяц
    function ExecureRefPersBonusDialog(AOwner: TComponent; AId: Variant; AMode: TDialogType): Boolean;
    function ExecureJPersBonusDialog(AOwner: TComponent; AId: Variant; AIdEmpl: Variant; AMode: TDialogType): Boolean;
    function CreateAllTurvforDate(AOwner: TComponent; ADt: Variant): Boolean;
    function DeletePayrollCalculations(AId: Variant): Boolean;
//    function SetForemanAllowance(AId: Integer): Boolean;
    function  GetArrOfTurvPeriodStrings(ADate: TDateTime; APeriodCount: Integer): TVarDynArray;
    function  CreateAllPayrollTransfers: Boolean;
    function  CreateAllPayrollCash: Boolean;
    procedure LoadDataFromParsec;

    procedure ConvertEmployees202511;
  end;

  TTurvDataRows = array of record
    Seg: TNamedArr;
    Totals: TNamedArr;
  end;

  TTurvDataSchedules = array of record
    Title: TNamedArr;
    Hours: TVarDynArray2;
  end;

  TTurvData = record
  private
    FId: Variant;                                       //айди табеля
    FDepartament: Integer;
    FEmployee: Integer;
    FDtMonth: TDateTime;                                //1е число месяца турв
    FDtBeg: TDateTime;                                  //дата начала период турв
    FDtEnd: TDateTime;                                  //дата окончания периода
    FDaysCount: Integer;                                //количество дней в периоде
    FIsFinalized: Boolean;                              //флаг, что ведомость закрыта
    FWoTerminated: Integer;                             //при 1 в ведомость не загружаются записи по статусам, за которыми в данном периоде последовало увольенеие, при - 1 наоборот
    FTitle: TNamedArr;                                  //заголовочная запись табеля
    FRows: TTurvDataRows;                               //массив сгруппированных строк (как отображаются в турв), содержит информацию по сегментам строки, с 0
    FList: TNamedArr;                                   //записи, ссоотвествующие каждой записи статуса работника, попавшей в турв
    FCells: TNamedArr2;                                 //массив записей (индекс соотвествует позиции в FList), содержашие TNamedArr[16] для данных по отработанным дням по этому статусу работника
    FTurvCodes: TNamedArr;                              //коды турв
    FTurvCodeW: Integer;                                //код для "В"
    FTurvCodeOT: Integer;                               //код для "ОТ"
    FTurvCodeBL: Integer;                               //код для "БЛ"
    FSchedules: TTurvDataSchedules;                     //данные по графикам работы, которые используются в данном турв
    FPersBonus: TNamedArr;                              //данные по персональным надбавкам
    FScheduleNotApproved : Boolean;                     //флаг, что есть несогласованныые графики работы
    FEmptyDay: TNamedArr;
    FDays: TNamedArr;
    FParsec: TNamedArr;
    FIdsEmployees: TVarDynArray;
    FWherePart: string;
    function GetCount: Integer;
    function GetFinalized: Boolean;
  public
    property Departament: Integer read FDepartament;
    property Employee: Integer read FEmployee;
    property DtMonth: TDateTime read FDtMonth;
    property DtBeg: TDateTime read FDtBeg;
    property DtEnd: TDateTime read FDtEnd;
    property DaysCount: Integer read FDaysCount;
    property IsFinalized: Boolean read GetFinalized;
    property Count: Integer read GetCount;
    property Title: TNamedArr read FTitle;
    property Rows: TTurvDataRows read FRows;
    property Cells: TNamedArr2 read FCells;
    property List: TNamedArr read FList;
    property TurvCodes: TNamedArr read FTurvCodes;
    property TurvCodeW: Integer read FTurvCodeW;
    property TurvCodeOT: Integer read FTurvCodeOT;
    property TurvCodBL: Integer read FTurvCodeBL;
    property Schedules: TTurvDataSchedules read FSchedules;
    property PersBonus: TNamedArr read FPersBonus;
    property ScheduleNotApproved : Boolean read FScheduleNotApproved;
    property EmptyDay: TNamedArr read FEmptyDay;
    procedure Create(AId: Variant; ASort: string = ''; AGroup: string = ''; ADtBeg: TDateTime = 0.0; ADtEnd: TDateTime = 0.0; ADepartament: Integer = -1; AEmployee: Integer = -1; AWherePart: string = ''; ALoadDays: Boolean = True; AWoTerminated:  Integer = 0);
    procedure LoadList;
    function  GetListTitleString(ARow: Integer; AProp: string; ADay: Integer = -1): string;
    procedure LoadDays;
    procedure LoadSchedules;
    procedure LoadPersBonus;
    procedure LoadTurvCodes;
    function  GetTurvCode(AValue: Variant): Variant;
    function  R(ARow, ADay: Integer): Integer; overload;
    function  R(ARow: Integer): TVarDynArray; overload;
    function  GetDayCell(ARow, ADay, ANum: Integer; var AColor: Integer; var AComm: string; AFormatTime: Boolean = False): Variant;
    procedure SetDayValues(ARow, ADay: Integer; AField: string; ANewValue: Variant);
    procedure SortAndGroup(ASort, AGroup : TVarDynArray);
    procedure CalculateTotals(ARow: Integer; var AWorktime, APremium, APenalty: Extended); overload;
    function  CalculateTotals(ARow: Integer = -1): TNamedArr; overload;
    function  GetDataStatus: Integer;
    function  CellState(ARow, ADay: Integer): Integer ;
    procedure LoadFromParsec;
  end;


var
  Turv: TTurv;

const
  cTurvMilkcompensationSum = 500;

implementation

uses
  uDBOra,
  uMessages,
  uTasks,

  uDBParsec,
  uFrmBasicInput
  ;

procedure TTurvData.Create(AId: Variant; ASort: string = ''; AGroup: string = ''; ADtBeg: TDateTime = 0.0; ADtEnd: TDateTime = 0.0; ADepartament: Integer = -1; AEmployee: Integer = -1; AWherePart: string = ''; ALoadDays: Boolean = True; AWoTerminated: Integer = 0);
begin
  FDepartament := ADepartament;
  FEmployee := AEmployee;
  FWoTerminated := AWoTerminated;
  FDtBeg := ADtBeg;
  FWherePart := AWherePart;
  if AId <> null then begin
    Q.QLoadFromQuery('select id, id_departament, code, name, dt1, dt2, is_finalized, finalized, is_office, ids_editusers, IsStInCommaSt(:id_user$i, ids_editusers) as rgse, status, name from v_w_turv_period where id = :id$i', [User.GetId, AId], FTitle);
    FDepartament := FTitle.G('id_departament');
    FDtBeg := FTitle.G('dt1');
    FDtEnd := FTitle.G('dt2');
  end
  else begin
    if ADtEnd = 0.0 then
      FDtEnd := Turv.GetTurvEndDate(ADtBeg)
    else
      FDtEnd := ADtEnd;
  end;
  FDtMonth := EncodeDate(YearOf(DtBeg), MonthOf(DtBeg), 1);
  FDaysCount := DaysBetween(FDtEnd, FDtBeg) + 1;
  LoadList;
  if ALoadDays then begin
    LoadTurvCodes;
    LoadDays;
    LoadSchedules;
    LoadPersBonus;
  end;
  SortAndGroup(A.Explode(ASort, ';', True), A.Explode(AGroup, ';', True));
  if ALoadDays then
    CalculateTotals;
end;


procedure TTurvData.LoadList;
var
  i, j: Integer;
  st: string;
  va: TVarDynArray;
  na: TNamedArr;
begin
  FIdsEmployees := [];
  //загрузим список строк ТУРВ, каждая строка соотвествует отдельному статусу работника (кроме увольнений), который начался не позже даты окончания,
  //и окончился не раньше даты начала периода, по данному подразделению.
  Q.QLoadFromQuery(
    'select id, dt_beg, dt_end, id_employee, id_job, grade, id_schedule, id_departament, id_organization, is_trainee, is_foreman, is_concurrent, personnel_number, ' +
    'name, name as employee, departament, job, schedulecode, organization, has_milk_compensation, ' +
    'dt_beg as dt_beg1, dt_end as dt_end1, null as monthly_hours_norm, null as period_hours_norm, 0 as is_terminated, null as ids_pers_bonus, null as temp ' +
    'from v_w_employee_properties ' +
    'where is_terminated <> 1 and dt_beg <= :dt_end$d and (dt_end is null or dt_end >= :dt_beg$d) ' +
    'and id_departament = :id_dep$i ' +
    S.IIfStr(FEmployee <> -1, 'and id_employee = ' + IntToStr(FEmployee) + ' ') +
    ' ' + FWherePart + ' ' +
    'order by name, dt_beg, job',
    [FDtEnd, FDtBeg, FDepartament],
    FList
  );
  //данные по увольнениям за период  (вообще все уволенные в период турв по всем подразделениям)
  Q.QLoadFromQuery(
    'select id, id_employee, id_organization, personnel_number ' +
    'from v_w_employee_properties ' +
    'where is_terminated = 1 and dt_beg >= :dt_beg$d and dt_beg <= :dt_end$d ' +
    //'and id_departament = :id_dep$i ' +
    //S.IIfStr(FEmployee <> -1, 'and id_employee = ' + IntToStr(FEmployee) + ' ') +
    //' ' + FWherePart + ' ' +
    'order by id',
    [FDtBeg, FDtEnd],
    na
  );
  //проставим признак is_terminated, как флаг того, что за данным статусом последовало увольнение в данном периоде.
  //есть статус для этого работника с этим признаком, начинающийся в день окончания проверяемого
  //нужно для расчетных ведомостей
  for i := 0 to FList.Count - 1 do
    if (FList.G(i, 'dt_end') <> null) and (FList.G(i, 'dt_end') < FDtEnd) then
      if Q.QSelectOneRow('select is_terminated from w_employee_properties where id_employee = :id_employee$i and dt_beg = :dt_beg$d', [FList.G(i, 'id_employee'), IncDay(FList.G(i, 'dt_end'), 0)])[0] = 1 then
        FList.SetValue(i, 'is_terminated', 1);
  //если задано, удалим все записи записи по уволенным в течении периода (не только ту, что кончается увольнением)
  //так как сравнение производится по работнику+организации+табельному, то удалятся все строки от примема, и далее переводы, которые заканчиваются увольнением,
  //но не удалятся другие его записи, так как табельный смениьтся при другом приеме
  if FWoTerminated = 1 then
    for i := FList.Count - 1 downto 0 do
      for j := 0 to na.Count- 1 do
        if (FList.G(i, 'id_employee') = na.G(j, 'id_employee')) and (FList.G(i, 'id_organization') = na.G(j, 'id_organization')) and (FList.G(i, 'personnel_number') = na.G(j, 'personnel_number')) then begin
          Delete(FList.V, i, 1);
          Break;
        end;
  //или наоборот, оставим только те кто уволен
  if FWoTerminated = -1 then
    for i := FList.Count - 1 downto 0 do begin
      var b := False;
      for j := 0 to na.Count- 1 do
        if (FList.G(i, 'id_employee') = na.G(j, 'id_employee')) and (FList.G(i, 'id_organization') = na.G(j, 'id_organization')) and (FList.G(i, 'personnel_number') = na.G(j, 'personnel_number')) then begin
          b := True;
          Break;
        end;
      if not b then
        Delete(FList.V, i, 1);
    end;
{  if FWoTerminated = 1 then
    for i := FList.Count - 1 downto 0 do
      if FList.G(i, 'is_terminated') = 1 then
        Delete(FList.V, i, 1);
  if FWoTerminated = -1 then
    for i := FList.Count - 1 downto 0 do
      if FList.G(i, 'is_terminated') <> 1 then
        Delete(FList.V, i, 1);}
  for i := 0 to FList.Count - 1 do begin
    //массив всех работников, кторые есть в турв
    if not A.InArray(FList.G(i, 'id_employee'), FIdsEmployees) then
      FIdsEmployees := FIdsEmployees + [FList.G(i, 'id_employee')];
    //проставим даты начала и окончания чтобы не было за пределами периода
    var dt := FList.G(i, 'dt_beg1');
    if dt < FDtBeg then
      FList.SetValue(i, 'dt_beg1', FDtBeg);
    dt := FList.G(i, 'dt_end1');
    if (dt = null) or (dt > FDtEnd) then
      FList.SetValue(i, 'dt_end1', FDtEnd);
  end;
end;

function TTurvData.GetListTitleString(ARow: Integer; AProp: string; ADay: Integer = -1): string;   //!!!
var
  i, p, Row: Integer;
  va: TVarDynArray;
  v: Variant;
begin
  Result := '';
  if ARow < 0 then
    Exit;
  try
  if ADay = -1 then begin
    va := [];
    for i := 0 to FRows[ARow].Seg.Count - 1 do
  //    if FRows[ARow].Seg.G(i, 'r') >= 0 then
      va := va + [FList.G(FRows[ARow].Seg.G(i, 'r'), AProp)];
    v := '';
    for i := 0 to High(va) do
      if va[i].AsString <> v.AsString then begin
        S.ConcatStP(Result, va[i].AsString, '; ');
        v := va[i];
      end;
  end
  else begin
    //еслди передан столбец
    Row := R(ARow, ADay);
    if Row > -1 then
      //выведем строку для данного столбца без группировки
      Result := FList.G(Row, AProp).AsString
    else
      //если в данной ячейке нет данных, то выведем тект для первого статуса этой строки
      Result := FList.G(R(ARow)[0], AProp).AsString;
  end;
  except
    Result := '';
  end;
end;

function TTurvData.GetCount: Integer;
begin
  Result := Length(FRows);
end;

function TTurvData.GetFinalized: Boolean;
begin
  Result := FTitle.G('is_finalized').AsInteger = 1;
end;

procedure TTurvData.LoadDays;
var
  i, j, k: Integer;
begin
  Q.QLoadFromQuery(
    'select id, id_employee_properties, id_employee, dt, worktime1, worktime2, worktime3, id_turvcode1, id_turvcode2, id_turvcode3, premium, premium_comm, penalty, penalty_comm, production, ' +
    'comm1, comm2, comm3, begtime, endtime, settime3, nighttime, ' +
    'null as scheduled_hours, null as changed ' +
    'from w_turv_day where dt >= :dtbeg$d and dt <= :dtend$d and id_employee_properties in (' + S.IfEmptyStr(A.Implode(A.VarDynArray2ColToVD1(FList.V, 0), ','), '-1000') + ') ' +
    'order by dt',
     [FDtBeg, FDtEnd],
     FDays
  );
  FEmptyDay.FFull := FDays.FFull;
  FEmptyDay.F := FDays.F;
  SetLength(FEmptyDay.V, 1);
  SetLength(FEmptyDay.V[0], Length(FDays.F));
  for i := 0 to High(FDays.F) do
    FEmptyDay.V[0][i] := null;
end;

procedure TTurvData.LoadSchedules;
//загрузим все плановые графики работы, которые есть в этом турв, в промежуточную переменную
//установим статус, обозначающий наличие несогласованных графиков
var
  i, j: Integer;
  va: TVarDynArray;
  va2: TVarDynArray2;
  st: string;
  b: Boolean;
  e: Extended;
begin
  va := [];
  FScheduleNotApproved := False;
  //получим айди всех графиков, которые присуствуют
  for i := 0 to FList.Count - 1 do
    if not A.InArray(FList.G(i, 'id_schedule'), va) then
      va := va + [FList.G(i, 'id_schedule')];
  SetLength(FSchedules, Length(va));
  for i := 0 to High(va) do begin
    //загружаем график (дата на начало месяца!)
    Q.QLoadFromQuery('select id_schedule, hours, hours1, hours2, null as period_hours, approved from w_schedule_periods where id_schedule = :id$i and dt = :dt$d', [va[i], FDtMonth], FSchedules[i].Title);
    b := FSchedules[i].Title.Count > 0;
    FSchedules[i].Hours := [];
    if b then
      b := FSchedules[i].Title.G('approved') = 1
    else begin
      //создадим запись для графика, так как ее не будет в случае отсутствия ввода данного графика для периода турв (на практике будет за прошлый 2025 год)
      FSchedules[i].Title.Create(['id_schedule', 'hours', 'hours1', 'hours2', 'period_hours', 'approved'], 1);
      FSchedules[i].Title.SetValue('id_schedule', va[i]);
    end;
    if b then begin
      //если график найден и согласован, то загружаем по нему рабочее время
      FSchedules[i].Hours := Q.QLoadToVarDynArray2('select hours, dt from w_schedule_hours where id_schedule = :id$i and dt >= :dt1$d and dt <= :dt2$d order by dt', [va[i], FDtBeg, FDtEnd]);
      //посчитаем норму за период турв, ту к бд для графика поле есть но на данный момент оно не записывается!!!
      e := 0;
      for j := 0 to High(FSchedules[i].Hours) do
        e := e + FSchedules[i].Hours[j][0];
      FSchedules[i].Title.SetValue('period_hours', e);
    end
    else begin
      //иначе поставим флаг
      FScheduleNotApproved := True;
    end;
    for j := 0 to FList.Count - 1 do
      if FList.G(j, 'id_schedule') = va[i] then begin
        FList.SetValue(j, 'period_hours_norm', FSchedules[i].Title.G('period_hours'));
        FList.SetValue(j, 'monthly_hours_norm', FSchedules[i].Title.G('hours'));
      end;
  end;
end;

procedure TTurvData.LoadPersBonus;
//загрузим данные по персональным надбавкам
var
  i, j: Integer;
  na: TNamedArr;
  st: string;
begin
  if FList.Count = 0 then
    Exit;
  //загрузим записи о надбавках по всем работникам турв, для которых действие надбавки в пределах периода турв
  Q.QLoadFromQuery(
    'select b.id, b.id_employee, b.id_pers_bonus, b.dt_beg, b.dt_end, s.sum, t.name '+
    'from w_employee_pers_bonus b, w_pers_bonus_sum s, w_pers_bonus t '+
    'where b.id_pers_bonus = t.id and b.id_pers_bonus = s.id_pers_bonus (+) and s.dt (+) = :dt$d and '+
    'id_employee in (' + A.Implode(FIdsEmployees, ',') + ') and dt_beg <= :dt_end$d and (dt_end is null or dt_end >= :dt_beg$d)',
    [FDtMonth, FDtEnd, FDtBeg], na
  );
  //проставим данные надбавок в массиве по статусам (надбавки, кторые действуют в период десйтвия статуса в турв)
  //при расчете итогов эти данные испольуем для итоговой инфы по надбавкам и для расчета суммы по надбавкам
  for i := 0 to FList.High do begin
    st := '';
    for j := 0 to na.High do begin
      if (na.G(j, 'id_employee') = FList.G(i, 'id_employee')) and (na.G(j, 'dt_beg') <= FList.G(i, 'dt_end1')) and ((na.G(j, 'dt_end') = null) or (na.G(j, 'dt_end') >= FList.G(i, 'dt_beg1'))) then
        S.ConcatStP(st, na.G(j, 'id').AsString + #2 + na.G(j, 'id_pers_bonus').AsString + #2 + na.G(j, 'name').AsString + #2 + na.G(j, 'dt_beg').AsString + #2 + na.G(j, 'dt_end').AsString + #2 + na.G(j, 'sum').AsString, #1);
    end;
    FList.SetValue(i, 'ids_pers_bonus', st);
  end;

end;

procedure TTurvData.LoadTurvCodes;
//загрузим справочник кодов турв
begin
  FTurvCodeW := -1;
  Q.QLoadFromQuery('select id, code, name from ref_turvcodes order by code', [], FTurvCodes);
  for var j: Integer := 0 to FTurvCodes.Count - 1 do begin
    if FTurvCodes.G(j, 'code') = 'В' then
      FTurvCodeW := FTurvCodes.G(j, 'id');
    if FTurvCodes.G(j, 'code') = 'ОТ' then
      FTurvCodeOT := FTurvCodes.G(j, 'id');
    if FTurvCodes.G(j, 'code') = 'БЛ' then
      FTurvCodeBL := FTurvCodes.G(j, 'id');
  end;
end;

function TTurvData.GetTurvCode(AValue: Variant): Variant;
//получим код турв по айди этого кода
var
  i: Integer;
begin
  Result := null;
  i := A.PosInArray(AValue, FTurvCodes.V, 0);
  if i >= 0 then
    Result := FTurvCodes.V[i][1];
end;

function TTurvData.R(ARow, ADay: Integer): Integer;
//получиим позицию в List и Cells (она одинакова) по номеру строки ТУРВ (т.е. по номеру сгруппированной строки) и колонки (номеру дня)
begin
  Result := -1;
  //пройдем оп сегментам
  for var i := 0 to FRows[ARow].Seg.Count - 1 do begin
    if (FRows[ARow].Seg.G(i, 'c1') <= ADay) and (FRows[ARow].Seg.G(i, 'c2') >= ADay) then begin
      Result := FRows[ARow].Seg.G(i, 'r');
      Exit;
    end;
  end;
end;

function TTurvData.R(ARow: Integer): TVarDynArray;
//получиим в результирующем массиве  все строки негруппированных и несортированных данных,  присутствующих в этой отображаемой строке
begin
  Result := [];
  //пройдем оп сегментам
  for var i := 0 to FRows[ARow].Seg.Count - 1 do
    Result := Result + [FRows[ARow].Seg.G(i, 'r')];
end;



function TTurvData.GetDayCell(ARow, ADay, ANum: Integer; var AColor: Integer; var AComm: string; AFormatTime: Boolean = False): Variant;
var
  pos: Integer;
  res: array[0..3] of Variant;

  function GetDayValue(ANum: Integer): Variant;
  begin
    if FCells[pos].G(ADay, 'worktime' + IntToStr(ANum)) <> null then
      Result := FCells[pos].G(ADay, 'worktime' + IntToStr(ANum))
    else
      Result := GetTurvCode(FCells[pos].G(ADay, 'id_turvcode' + IntToStr(ANum)));
  end;

begin
  Result := '';
  AColor := -1;
  if ARow >= 0 then begin
    pos := R(ARow, ADay);
    if pos = -1 then
      Exit;
  end
  else
    pos := -ARow;
  AColor := 0;
  if pos = -2 then
    Exit;
  if ANum in [0..3] then begin
    res[1] := GetDayValue(1);  //время или код от мастеров
    res[2] := GetDayValue(2);  //время или код парсек
    res[3] := GetDayValue(3);  //проверенное время или код
    res[0] := res[3];
    if res[0] = null then begin
      if (res[1] = null) and (res[2] = null) then begin
        AColor := 0;
      end
      else if (res[1] <> null) and (res[2] = null) then begin
        AColor := 2;   //жетлтый
        res[0] := res[1];
      end
      else if (res[1] = null) and (res[2] <> null) then begin
        AColor := 1;   //красный
        res[0] := res[2];
      end
      else if (not S.IsNumber(S.NSt(res[1]), 0, 24)) and (not S.IsNumber(S.NSt(res[2]), 0, 24)) then begin
        res[0] := res[2];
      end
      else if S.IsNumber(S.NSt(res[1]), 0, 24) and S.IsNumber(S.NSt(res[2]), 0, 24) and (abs(StrToFloat(S.NSt(res[1])) - StrToFloat(S.NSt(res[2]))) <= Module.GetCfgVar(mycfgWtime_autoagreed)) then begin
        res[0] := res[2];
        if res[1] <> res[2] then
          AColor := 4; //красный цвет шрифта
      end
      else begin
        res[0] := res[2];
        AColor := 1;
      end;
    end;
    Result := res[ANum];
    if AFormatTime then begin
      if S.IsNumber(S.NSt(Result), 0, 24) then
        Result := FormatFloat('0.00', S.VarToFloat(Result))
      else
        Result := S.NSt(Result);
    end;
    if ANum <> 0 then
      AComm := FCells[pos].G(ADay, 'comm' + IntToStr(ANum)).AsString;
  end
  else if ANum = 4 then begin
    Result := FCells[pos].G(ADay, 'premium');
    AComm := FCells[pos].G(ADay, 'premium_comm').AsString;
  end
  else if ANum = 5 then begin
    Result := FCells[pos].G(ADay, 'penalty');
    AComm := FCells[pos].G(ADay, 'penalty_comm').AsString;
  end
  else if ANum = 6 then begin
    Result := FCells[pos].G(ADay, 'scheduled_hours');
    AComm := '';
  end
  else if ANum = 7 then begin
    Result := FormatFloat('00.00', FCells[pos].G(ADay, 'begtime').AsFloat);
    AComm := '';
  end
  else if ANum = 8 then begin
    Result := FormatFloat('00.00', FCells[pos].G(ADay, 'endtime').AsFloat);
    AComm := '';
  end
  else if ANum = 100 then begin
    Result := FCells[pos].G(ADay, 'nighttime');
    AComm := 'работа в ночную смену'; //FCells[pos].G(ADay, 'nighttime').AsString; //!!!
  end


end;

procedure TTurvData.SetDayValues(ARow, ADay: Integer; AField: string; ANewValue: Variant);
var
  pos, id, i: Integer;
begin
  pos := R(ARow, ADay);
  FCells[pos].SetValue(ADay, 'id_employee_properties', FList.G(pos, 'id'));
  FCells[pos].SetValue(ADay, 'dt', IncDay(FDtBeg, ADay - 1));
  FCells[pos].SetValue(ADay, AField, ANewValue);
end;


procedure TTurvData.SortAndGroup(ASort, AGroup : TVarDynArray);
//процедура должна быть вызвана обязательно!
//данные групируются по AGroup (строки, для которых все поля из AGroup одинаковы, объединяются)
//данные сортируются по ASort (писать надо в прямом порядке)
//процедуру можно применять неоднократно (в процессе работы)
var
  i, j, k, m, n, p, p2, ep, sh: Integer;
  b, b1: Boolean;
begin
  //сортируем массив строк, при этом сначала отсортируем по начальной дате статуса в любом случае
  ASort := ASort + ['dt_beg'];
  for i := High(ASort) downto 0 do
    A.VarDynArray2Sort(FList.V, FList.Col(ASort[i]) + 1);

  SetLength(FRows, 0);
  for i := 0 to FList.Count - 1 do begin
    //проверим, есть ли среди уже созданных записей такая, в которой все поля группировки совпадают с текущей
    b := False;
    if Length(AGroup) > 0 then
      for j := 0 to High(FRows) do begin
        b1 := True;
        for k := 0 to High(AGroup) do begin
          if FList.G(i, AGroup[k]) <> FList.G(FRows[j].Seg.G('r'), AGroup[k]) then begin
            b1  := False;
            Break;
          end;
          if not b1 then
            Break;
        end;
        if b1 then begin
          p := j;
          b := True;
          Break;
        end;
     end;
    if b then begin
      FRows[p].Seg.IncLength;
    end
    else begin
      SetLength(FRows, Length(FRows) + 1);
      FRows[High(FRows)].Seg.Create(['c1$i', 'c2$i', 'r$i'], 1);
      p := High(FRows);
    end;
    p2 := FRows[p].Seg.Count - 1;
    FRows[p].Seg.SetValue(p2, 'r', i);
    FRows[p].Seg.SetValue(p2, 'c1', Max(1, DaysBetween(FList.GetValue(i, 'dt_beg'), DtBeg) + 1));
    if FList.GetValue(i, 'dt_beg') < DtBeg then
      j := 1
    else
      j := DaysBetween(FList.GetValue(i, 'dt_beg'), DtBeg) + 1;
    FRows[p].Seg.SetValue(p2, 'c1', j);
    if FList.GetValue(i, 'dt_end') = null then
      j := 16
    else
      j := Min(16, DaysBetween(FList.GetValue(i, 'dt_end'), DtBeg) + 1);
    FRows[p].Seg.SetValue(p2, 'c2', j);
  end;
  //загрузим в данные в массив ячеек (дней), где номер строки соотвествует строке в FList,
  //и в строке TNamedArr, содержащий 16 записей данных по дню, строка соотвествует номеру дня (18-05-25 -> FCells[Row].G(3, 'dt')
  Setlength(FCells, 0);
  Setlength(FCells, FList.Count);
  for i := 0 to FList.Count - 1 do begin
    //найфдем позицию в массиве графиков для графика данных
    m := -1;
    for k := 0 to High(FSchedules) do
      if FSchedules[k].Title.G('id_schedule') = FList.G(i, 'id_schedule') then begin
        m := k;
        Break;
      end;
    //создадим запись для дня в ячейке
    FCells[i].Create(FDays.FFull, 17);
    FCells[i].SetNull;
    //загрузим данные по дням (только те дни, кторые загружены из бд!)
    for j := 0 to FDays.Count - 1 do begin
      ep := FDays.G(j, 'id_employee_properties');
      if ep = FList.G(i, 'id') then begin
        //копируем все поля из исходного сплошного массива дней в ячейку целевого массива,  при условии по айди статуса
        for k := 0 to High(FDays.V[0]) do
          FCells[i].V[DaysBetween(FDays.G(j, 'dt'), DtBeg) + 1][k] := FDays.V[j][k];
      end;
    end;
    //пройдем по всем ячейкам
    for j := 1 to FDaysCount do begin
      //загрузим данные по норме за день из расписания
      FCells[i].SetValue(j, 'scheduled_hours', null);
      if m <> -1 then begin
        k := A.PosInArray(IncDay(FDtBeg, j - 1), FSchedules[m].Hours, 1);
        if k > -1 then
          FCells[i].SetValue(j, 'scheduled_hours', FSchedules[m].Hours[k, 0]);
      end;
    end;
  end;
end;


procedure TTurvData.CalculateTotals(ARow: Integer; var AWorktime, APremium, APenalty: Extended);
//итоги по строке ТУРВ
//время - если енсть согласованное то оно, иначе по парсеку, время руководителя не учитывается
//премии, депремирование - сумма дневных значений
var
  i, j, pos: Integer;
begin
  AWorktime := 0;
  APremium := 0;
  APenalty := 0;
  for i := 1 to FDaysCount do begin
    pos := R(ARow, i);
    if pos < 0 then
      Continue;
    AWorktime := AWorktime + S.IIf(FCells[pos].G(i, 'worktime3') = null, FCells[pos].G(i, 'worktime2').AsFloat, FCells[pos].G(i, 'worktime3').AsFloat);
    APremium := APremium + FCells[pos].G(i, 'premium').AsFloat;
    APenalty := APenalty + FCells[pos].G(i, 'penalty').AsFloat;
  end;
end;

function TTurvData.CalculateTotals(ARow: Integer = -1): TNamedArr;
//итоги по строке ТУРВ
//время - если енсть согласованное то оно, иначе по парсеку, время руководителя не учитывается
//премии, депремирование - сумма дневных значений
var
  i, j, k, pos, idsh, r1, r2, status, Row: Integer;
  e1: Extended;
  v1, v2, v3: Variant;
  IdsBonus: TVarDynArray;
begin
  if ARow = -1 then begin
    r1 := 0;
    r2 := Count - 1;
  end
  else begin
    r1 := ARow;
    r2 := ARow;
  end;
  status := 1000;
  for Row := r1 to r2 do begin
    Result.Create(['is_incomplete', 'worktime', 'premium', 'penalty', 'overtime', 'milk_compensation', 'status', 'ids_pers_bonus', 'personal_pay'], 1);
    //предустановки некоторых значений
    Result.SetValue('status', 100);
    IdsBonus := [];

    //пройдем по сегментам строки
    for i := 0 to FRows[Row].Seg.High do begin
      pos := FRows[Row].Seg.G('r');
//      var va := A.Explode(FList.G(pos, 'ids_pers_bonus'), ',' ,True);
      IdsBonus := IdsBonus + A.Explode(FList.G(pos, 'ids_pers_bonus'), #1 ,True);
    end;
    //айди персональных надбавок
    IdsBonus := A.RemoveDuplicates(IdsBonus);
    Result.SetValue('ids_pers_bonus', S.IIf(Length(IdsBonus) = 0, '-', A.Implode(IdsBonus, #1)));

    //пройдем по всем дням периода и создадим агрегатные значения для полей, изменяющихся по дате
    for i := 1 to FDaysCount do begin
      //получим строку исходных данных, если данных в ячейке нет, пропустим итерацию
      pos := R(Row, i);
      if pos < 0 then
        Continue;
      var dt := IncDay(FDtBeg, i - 1);
      v1 := FCells[pos].G(i, 'worktime3');
      v2 := FCells[pos].G(i, 'id_turvcode3');
      if (v1 = null) and (v2 = null) then begin
        v1 := FCells[pos].G(i, 'worktime2');
        v2 := FCells[pos].G(i, 'id_turvcode2');
      end;
      //посчитаем переработку
      for j := 0 to High(FSchedules) do
        //найдем позицию в данных по графикам, тк нам нужны часы за день
        if FSchedules[j].Title.G('id_schedule') = FList.G(pos, 'id_schedule') then begin
          idsh := j;
          k := -1;
          //получим часы и код, если есть то из согласованного иначе из парсека
          //найдем позицию в данных по часам графика
          k := A.PosInArray(IncDay(FDtBeg, i -1), FSchedules[j].Hours, 1);
          //если коды не ОТ или БЛ и найдены часы, просуммируем переработку
          if (v2 <> FTurvCodeOT) and (v2 <> FTurvCodeBL) and (k > -1) then
            Result.SetValue(0, 'overtime', Result.G('overtime').AsFloat + v1.AsFloat - FSchedules[j].Hours[k][0]);
          Break;
        end;
      //посчитаем сумму по надбавкам
      var va1 := A.Explode(FList.G(pos, 'ids_pers_bonus'), #1 ,True);
      for j := 0 to High(va1) do begin
        var va2 := A.Explode(va1[j], #2);
        if (StrToDate(va2[3]) <= dt) and ((va2[4].AsString = '') or (StrToDate(va2[4]) >= dt)) then begin
          Result.SetValue('personal_pay', Result.G('personal_pay').AsFloat + va2[5].AsFloat  * v1.AsFloat / FList.G(R(Row)[0], 'monthly_hours_norm'));
        end;
      end;

      //итоговое рабочее время; если заданы время или код согласованные, берем согласованное время, иначе по парсеку
      Result.SetValue(0, 'worktime', Result.G('worktime').AsFloat + S.IIf((FCells[pos].G(i, 'worktime3') = null) and (FCells[pos].G(i, 'id_turvcode3') = null), FCells[pos].G(i, 'worktime2').AsFloat, FCells[pos].G(i, 'worktime3').AsFloat));
      //суммарные дневные премии
      Result.SetValue(0, 'premium', Result.G('premium').AsFloat + FCells[pos].G(i, 'premium').AsFloat);
      //суммарные дневные штрафы
      Result.SetValue(0, 'penalty', Result.G('penalty').AsFloat +  FCells[pos].G(i, 'penalty').AsFloat);
      Result.SetValue(0, 'status', Min(Result.G('status').AsInteger, CellState(Row, i)));
      status := Min(Result.G('status').AsInteger, status);
    end;

    //переработка не меньше 0
    Result.SetValue('overtime', Max(0.0, Result.G('overtime').AsFloat));
    //компенсация за молоко, некорректно (FList.G(R(ARow)[0] !!!), но досточно для зп про группировке по должности и графику
    //сумма * отработаное время / норму
    if FList.G(R(Row)[0], 'has_milk_compensation') = 1 then
      Result.SetValue('milk_compensation', Round(cTurvMilkcompensationSum * Result.G('worktime').AsFloat / FList.G(R(Row)[0], 'monthly_hours_norm')))
    else
      Result.SetValue('milk_compensation', 0);
    Result.SetValue('personal_pay', Round(Result.G('personal_pay').AsFloat));

    //установим строку в общщих итогах
    FRows[Row].Totals := Result;
  end;
end;

function TTurvData.GetDataStatus: Integer;
//порлучить статус заполненности данных (1 - все введено, можно закрывать,   0 - все согласованы, но не все заполнены,  3 - есть данные, трубующие исправления)
begin
  Result := 100;
  for var Row := 0 to Count - 1 do
    Result := Min(Result, FRows[Row].Totals.G('status'));
  Result := S.Decode([Result, 1, 1, 2, 1, 0, 2, 3]);
end;

function TTurvData.CellState(ARow, ADay: Integer): Integer;
//стутус некоректности, если:
//пустая ячейка руководителя или ОК
//в обоих ячейках время, и оно не совпадает, не важно на какое значение
//в одной ячейке время, а в другой код
//если обе коды, но разные - некритично, пропускаем!
//время/код согласованные перекрывают все, кроме пункта 1!
var
  p: Integer;
  t1, t2, t3, c1, c2, c3: Variant;
begin
  Result := 100;
  if ARow >= 0 then begin
    p := R(ARow, ADay);
    if p = -1 then
      Exit;
  end
  else
    p := -ARow;
  t1 := FCells[p].G(ADay, 'worktime1');
  t2 := FCells[p].G(ADay, 'worktime2');
  t3 := FCells[p].G(ADay, 'worktime3');
  c1 := FCells[p].G(ADay, 'id_turvcode1');
  c2 := FCells[p].G(ADay, 'id_turvcode2');
  c3 := FCells[p].G(ADay, 'id_turvcode3');
  Result := 1;
  if ((t1 = null) and (c1 = null)) and ((t2 = null) and (c2 = null)) then
    Result := 0  //ячейка не заполнена
  else if ((t1 = null) and (c1 = null)) and not ((t2 = null) and (c2 = null)) then
    Result := -1  //не заполнено время руководителя при заполненном для парсека
  else if not((t1 = null) and (c1 = null)) and ((t2 = null) and (c2 = null)) then
    Result := -2  //не заполнено время ОК при заполненном времени руководителя
  else if ((t1 <> null) and (c2 <> null)) or ((t2 <> null) and (c1 <> null)) then
    Result := -3  //в поле руководитя код, а ОК - время, или наоборот
  else if ((t1 <> null) and (t2 <> null)) and (Abs(t1 - t2) > Module.GetCfgVar(mycfgWtime_autoagreed)) then
    Result := -4  //времена руководителя и ок различаются более чем на час
  else if ((t1 <> null) and (t2 <> null)) and (t1 <> t2) then
    Result := -5  //времена руководителя и ок различаются но менее чем на час
  ;
  if not ((t3 = null) and (c3 = null)) and (Result < -3) and (Result >= -5) then
    Result := 2  //допустимые несовпадения перекрыты согласованным временем
  ;
end;



procedure TTurvData.LoadFromParsec;
//переделан запрос данных из парсека, по новым кодам данных, и с использованием объекта БД myDBParsec
var
  i, j, k, p, d: Integer;
  id_vyh: Integer;
  st: string;
  dt, dt1, dt2: TDateTime;
  ParsecEvents, va2, vp, vpb, vpe: TVarDynArray2;
  vab, vae: TVarDynArray;
  tbegday, tbegkontr, tobc, tobo, t1, t2, tp: Extended;
  v: Variant;
begin
  //первая дата - за 3 дня до начала текущего периода ТУРВ (можно бы за 3 дня до последнего успешного выполнения этой задачи)
  dt1:=IncDay(FDtBeg, -3);
  //вторая дата - конец текущих суток
  if Date > FDtEnd then dt2:= FDtEnd else dt2 := Date;
  dt2:=IncMilliSecond(IncDay(Date, 1), -1);
  //массивы данных по входу и уходу работников
  vpb:=[];
  vpe:=[];
  {
  Такие коды транзакций в БД Парсека

  на проходной ПЩ:
  590152 Фактический вход
  590153 Фактический выход

  в остальных случаях
  590144 Нормальный вход по ключу
  590145 Нормальный выход по ключу
  }

  //айди операций входа и выхода (есть по два события)
  ParsecEvents := [[590144, 590152], [590145, 590153]];
  //пытаемся подключиться к парсеку, выходим если не удалось (без диалога ошибки)
  //!!!на 2025-02-27 выдается окно ошибки, через минуту закроется
  if not myDBParsec.Connect(False) then
    Exit;
    //два запроса к БД, по событиям входа и выхода
  //время в БД UTC, приводим к Московскому!
  st := '';
  for i := 0 to FList.Count - 1 do
    S.ConcatStP(st, '''' + FList.G(i, 'name') + '''', ',');
  for i := 0 to 1 do begin
    vp := [];
    if st <> '' then
      vp := myDBParsec.QLoadToVarDynArray2(
        'select '+
        'format(dateadd(hour, 3, t.tran_date), ''dd.MM.yyyy HH:mm'') as dt, '+
        'case '+
        'when tt.trantype_desc = ''Нормальный вход по ключу'' then ''Приход'' '+
        'when tt.trantype_desc = ''Фактический вход'' then ''Приход'' '+
        'when tt.trantype_desc = ''Нормальный выход по ключу'' then ''Уход'' '+
        'when tt.trantype_desc = ''Фактический выход'' then ''Уход'' '+
        'end as event, '+
        'concat(p.last_name, '' '', p.first_name, '' '', p.middle_name) as name '+
        'from '+
        '  parsec3trans.dbo.translog as t '+
        '  left outer join '+
        '  parsec3.dbo.person as p '+
        '  on t.usr_id = p.pers_id '+
        '  left outer join '+
        '  parsec3.dbo.trantypes_desc tt '+
        '  on t.trantype_id = tt.trantype_id '+
        'where '+
        '  ((t.trantype_id = :trantype1$i)or '+
        '  (t.trantype_id = :trantype2$i)) '+
        '  and '+
        '  (tt.locale = ''RU'') '+
        '  and '+
        '  t.tran_date >= :dt1$d ' +
        '  and '+
        '  t.tran_date <= :dt2$d ' +
        '  and '+
        'concat(p.last_name, '' '', p.first_name, '' '', p.middle_name) in (' + st + ') '+
        'order by concat(p.last_name, '' '', p.first_name, '' '', p.middle_name), tran_date asc '
        ,
        [ParsecEvents[i][0], ParsecEvents[i][1], IncHour(dt1, -3), IncHour(dt2, -3)]
      );
    if i = 0 then
      vpb := copy(vp)
    else
      vpe := copy(vp);
  end;
  //MsgDbg([VTxt(vpb), VTxt(vpe)]);
  //пройдем по списку строк турв
  for i := 0 to High(FRows) do begin
    //пройдем по всему диапозону дней турв
    for d := 1 to 16 do begin
      p := R(i, d);
      //пропускаем ячейки, в которых нет данных
      if p = -1 then
        Continue;
      st := FList.G(p, 'name');
      //дата для данного номера дня
      dt := IncDay(DtBeg, d - 1);
      //первая позици работника в данных парсека
      j := A.PosInArray(st, vpb, 2);
      //соберем все приходы за день в массив
      vab := [];
      while (j > -1) and (j <= High(vpb)) and (vpb[j, 2] = st) do begin
        if (Trunc(StrToDateTime(vpb[j][0])) = dt) then
          vab := vab + [vpb[j][0]];
        inc(j);
      end;
      //соберем все уходы за день в массив
      j := A.PosInArray(st, vpe, 2);
      vae := [];
      while (j > -1) and (j <= High(vpe)) and (vpe[j, 2] = st) do begin
        if (Trunc(StrToDateTime(vpe[j][0])) = dt) then
          vae := vae + [vpe[j][0]];
        inc(j);
      end;
      //сохраним самое ранне время прихода
      if Length(vab) > 0 then begin
        v := HourOf(StrToDateTime(vab[0])) + (MinuteOf(StrToDateTime(vab[0])) / 100);
        if FCells[p].G(d, 'begtime') <> v then begin
          FCells[p].SetValue(d, 'begtime', v);
          FCells[p].SetValue(d, 'changed', 1);
        end;
      end;
      //сохраним самое позднее время ухода (за текущий день не проставляем вообще)
      if (Length(vae) > 0) and (dt <> Date) then begin
        v := HourOf(StrToDateTime(vae[High(vae)])) + (MinuteOf(StrToDateTime(vae[High(vae)])) / 100);
        if FCells[p].G(d, 'endtime') <> v then begin
          FCells[p].SetValue(d, 'endtime', v);
          FCells[p].SetValue(d, 'changed', 1);
        end;
      end;
      //проставляем флаг для подсмветки ячейки в детально таблице турв (если только одно из времен есть, либо есть повторные отметки прихода или ухода)
      if (dt <> Date) and ((Length(vab) = 0) or (Length(vab) > 1) or (Length(vae) = 0) or (Length(vae) > 1)) and not ((Length(vab) = 0) and (Length(vae) = 0)) then begin
        if FCells[p].G(d, 'settime3') <> 1 then begin
          FCells[p].SetValue(d, 'settime3', 1);
          FCells[p].SetValue(d, 'changed', 1);
        end;
      end;
    end;
  end;

  //время прихода и ухода в БД в часах и минутах (они в дробной части)
  //время работы в бд в часах и десятых часа!
  //времена t_xx в часах и десятых часа!

  //время начала рабочего дня, из настроек модуля, там оно в часах и минутах - целые это часы, а дробная часть минута, напр 8.30!
  tbegday := trunc(Module.GetCfgVar(mycfgWtime_beg_2)) + frac(Module.GetCfgVar(mycfgWtime_beg_2)) / 60 * 100;
  //время, если раньше него началась работа, подсветим  ..то учитываем весь период и подсветим
  tbegkontr := Max(tbegday - S.VarToFloat(Module.GetCfgVar(mycfgWtime_beg_diff_2)), 0);
  //время окончания обеда по офису, 12ч + время перерыва, в часах и десятых часа
  tobo := 12 + S.VarToFloat(Module.GetCfgVar(mycfgWtime_dinner_1));
  //время окончания обеда по цеху, 12ч + время перерыва, в часах и десятых часа
  tobc := 12 + S.VarToFloat(Module.GetCfgVar(mycfgWtime_dinner_2));
  id_vyh:=Q.QSelectOneRow('select id from w_turvcodes where code = ''В''', [])[0];

  //пройдем по списку строк турв
  for i := 0 to High(FRows) do begin
    //пройдем по всему диапозону дней турв
    for d := 1 to 16 do begin
      p := R(i, d);
      if p = -1 then
        Continue;
      if (FCells[p].G(d, 'worktime2') <> null) or (FCells[p].G(d, 'id_turvcode2') <> null) then
        Continue;
      //дата для данного номера дня
      dt := IncDay(DtBeg, d - 1);
      if dt >= Date then
        Continue;
      t1 := -1;
      if FCells[p].G(d, 'begtime') <> null then
        t1 := trunc(FCells[p].G(d, 'begtime')) + frac(FCells[p].G(d, 'begtime')) / 60 * 100;
      t2 := -1;
      if FCells[p].G(d, 'endtime') <> null then
        t2 := trunc(FCells[p].G(d, 'endtime')) + frac(FCells[p].G(d, 'endtime')) / 60 * 100;
      if (FTitle.G('is_office') = 1) or (FTitle.G('is_office') = 0) then begin
        //обработка для офиса, попроще
        if (t1 = -1) and (t2 = -1) then begin
          //нет ни прихода ни ухода - поставим выходной
          //если не было никакого кода, тк может быть еще отпуск
          if FCells[p].G(d, 'id_turvcode2') = null then
            FCells[p].SetValue(d, 'id_turvcode2', id_vyh);
            FCells[p].SetValue(d, 'changed', 1);
          //vt[i][7]:=1;
        end
        else if (t1 = -1) or (t2 = -1) then begin
          //нет одного времени - поставим 8.00 и подсветим
          FCells[p].SetValue(d, 'id_turvcode2', null);
          FCells[p].SetValue(d, 'worktime2', 8);
          FCells[p].SetValue(d, 'changed', 1);
        end
        else if (t1 > -1) and (t2 > -1) then begin
          //время начала рабочего дня возьмем максимальное от фактического или 8:00
          t1 := Max(t1, tbegday);
          tp := abs(t2 - t1);
          //вычтем обед, если время ухода ранее окончания обеда, и время прихода ранее его начала
          tp := Max(0.01, tp - S.IIf((t2 < tobo) or (t1 > tobo - 1), 0, S.VarToFloat(Module.GetCfgVar(mycfgWtime_dinner_1))));
          //округляем
          if frac(tp) <= 0.33 then
            tp := trunc(tp)
          else if frac(tp) <= 0.83 then
            tp := trunc(tp) + 0.5
          else
            tp := trunc(tp) + 1;
          FCells[p].SetValue(d, 'id_turvcode2', null);
          FCells[p].SetValue(d, 'worktime2', tp);
          FCells[p].SetValue(d, 'changed', 1);
//          vt[i][7]:=1;
        end;
      end
      else begin

      end;
    end;
  end;

  //пройдем по списку строк турв
  for i := 0 to High(FRows) do begin
    //пройдем по всему диапозону дней турв
    for d := 1 to 16 do begin
      p := R(i, d);
      if p = -1 then
        Continue;
      if FCells[p].G(d, 'changed') <> 1 then
        Continue;
      Q.QBeginTrans(True);
      Q.QExecSql(
        'insert into w_turv_day (id_employee_properties, dt, id_employee) '+
        'select :ide$i, :dt$d, :idempl$i from dual '+
        'where not exists '+
        '(select 1 from w_turv_day where id_employee_properties = :ide2$i and dt = :dt2$d)',
        [FCells[p].G(d, 'id_employee_properties'), FCells[p].G(d, 'dt'), FCells[p].G(d, 'id_employee'), FCells[p].G(d, 'id_employee_properties'), FCells[p].G(d, 'dt')]
      );
      //запишем данные в основную таблицу
      st := Q.QSIUDSql('Q', 'w_turv_day', 'begtime$f;endtime$f;settime3$i;id_turvcode2$i;worktime2$f' + ' where id_employee_properties = :ide$i and dt = :dt$d');
      Q.QExecSQL(st, [FCells[p].G(d, 'begtime'), FCells[p].G(d, 'endtime'), FCells[p].G(d, 'settime3'), FCells[p].G(d, 'id_turvcode2'), FCells[p].G(d, 'worktime2'), FCells[p].G(d, 'id_employee_properties'), FCells[p].G(d, 'dt')]);
      Q.QCommitOrRollback(True);
    end;
  end;


  (*  //время начала рабочего дня, из настроек модуля, там оно в часах и минутах - целые это часы, а дробная часть минута, напр 8.30!
  t3:=trunc(Module.GetCfgVar(mycfgWtime_beg_2)) + frac(Module.GetCfgVar(mycfgWtime_beg_2))/60*100;
  //время, если раньше него началась работа, подсветим  ..то учитываем весь период и подсветим
  t4:=Max(t3 - S.VarToFloat(Module.GetCfgVar(mycfgWtime_beg_diff_2)), 0);
//    'select dt, id_worker, begtime, endtime, id_turvcode3, worktime3, nighttime, 0, null, settime3, id_division from turv_day where begtime is null or endtime is null and id_division = 4 and dt >= :dt1$d and dt <= :dt2$d order by id_worker',
  //время окончания обеда по офису, 12ч + время перерыва, в часах и десятых часа
  tob1:=12 + S.VarToFloat(Module.GetCfgVar(mycfgWtime_dinner_1));
  //время окончания обеда по цеху, 12ч + время перерыва, в часах и десятых часа
  tob1:=12 + S.VarToFloat(Module.GetCfgVar(mycfgWtime_dinner_2));

  for i:=0 to High(vt) do begin
    //обрабатываем только те ячейки, где нет ни кода ни времени парсек или же код = В
    //если ранее было изменено время, или если это не последняя в выгрузке, и следующая запись на того же работника, и при этом это следующий день, и при этом было изменено время
    b:=(vt[i][7] = 1) or ((i < High(vt)) and (vt[i][1] = vt[i+1][1]) and
      (DaysBetween(vt[i+1][0], vt[i][0]) = 1) and (vt[i+1][7] = 1));
    //если время и код по парсеку еще не заданы, или же задан выходной но при этом в этот или следующий день были изменения времени прихода/ухода
    if ((vt[i][4] = null)and(vt[i][5] = null))or(((vt[i][4] = id_vyh){or(vt[i][4] = id_otp)}) and b) then begin  //2025-12 убран id_otp
      //если сменился айди подразделения, узнаем офис ли это
      if vt[i][10]<> idd then begin
        idd:=vt[i][10];
        isoffice:=A.PosInArray(idd, vdiv, 0) >= 0;
      end;
      //если хотя бы одно время из парсек не получено, то не считаем по данной ячеке
      //это значит что ЕЩЕ не получено, если прото не будет времени за данный день но оно уже опрашивалось, то будет -1 в данном времени!!!
      if (vt[i][2] = null)or(vt[i][3] = null) then continue;
      //здесь ранее внесенные в базу, в часах и минутах
      //переведем в часы и десятые часа
      t1:=-1;
      if vt[i][2]<>null then t1:=trunc(vt[i][2]) + frac(vt[i][2])/60*100;
      t2:=-1;
      if vt[i][3]<>null then t2:=trunc(vt[i][3]) + frac(vt[i][3])/60*100;
      //обработка для офиса, попроще
      if isoffice then begin
        if (t1 = -1)and(t2 = -1) then begin
          //нет ни прихода ни ухода - поставим выходной
          //если не было никакого кода, тк может быть еще отпуск
          if vt[i][4] = null then vt[i][4]:=id_vyh;
          vt[i][7]:=1;
        end
        else if (t1 = -1)or(t2 = -1) then begin
          //нет одного времени - поставим 8.00 и подсветим
          vt[i][4]:=null;
          vt[i][5]:=8;
          vt[i][9]:=1;
          vt[i][7]:=1;
        end
        else if (t1 > -1)and(t2 > -1) then begin
          //время начала рабочего дня возьмем максимальное от фактического или 8:00
          t1:=Max(t1, t3);
          //вычтем обед, если время ухода ранее окончания обеда
          tp:=abs(t2-t1);
//tp:=tp - S.IIf(t2 < tob1, 0, S.VarToFloat(Module.GetCfgVar(mycfgWtime_dinner_1)));
          tp:=Max(0.01, tp - S.IIf(t2 < tob1, 0, S.VarToFloat(Module.GetCfgVar(mycfgWtime_dinner_1))));
          //округляем
          if frac(tp) <= 0.33
            then tp:=trunc(tp)
            else if frac(tp) <= 0.83
            then tp:=trunc(tp) + 0.5
              else tp:=trunc(tp) + 1;
          vt[i][4]:=null;
          vt[i][5]:=tp;
          vt[i][7]:=1;
        end;
      end
*)

 (*

  //найдем времена прихода и ухода работников по данным парсек
//    'select dt, id_worker, begtime, endtime, id_turvcode3, worktime3, nighttime, 0, null from turv_day where begtime is null or endtime is null and id_division = 4 and dt >= :dt1$d and dt <= :dt2$d order by id_worker',
  j:=-1; st:='';
  for i:=0 to High(vt) do begin
//vt[i][2] := null;vt[i][3] := null; //!!! test
      if vt[i][1] <> j then begin
        //если айди работника изменился, то найдем фио этого работника
        st:='';
        for k:=0 to High(vw) do begin
          if vw[k][0] = vt[i][1] then begin
            st:=vw[k][1];
            j:=vw[k][0];
            Break;
          end;
        end;
      end;
      vt[i][8]:=st;
    //для текущего дня не проставляем
    //надо проставлять, тк бывает требууются данные ужде за предыдущий или текущий день!!!
    //if vt[i][0] = Date then Continue;
    //если нет еще данных по времени прихода или ухода
    if (vt[i][2] = null)or(vt[i][3] = null) then begin
      vtp:=[];
      //время прихода
      if (vt[i][2] = null) then begin
        m:=0;
        //найдем время по данным парсек
        for k:=0 to High(vpb) do begin
          if (vpb[k][2] = st)and(Trunc(StrToDateTime(vpb[k][0])) = StrToDate(vt[i][0])) then begin
            inc(m);
            if m = 1 then begin
              //это первое найденное время, его сохраним для турв
              vt[i][2]:=HourOf(StrToDateTime(vpb[k][0]))+(MinuteOf(StrToDateTime(vpb[k][0])) / 100);
              vt[i][7]:=1;
            end;
            //времен больше чем одно, нас интересует только этот факт, выйдем
            //if m > 1 then Break;
            vtp:=vtp + [Copy(vpb[k][0], 12, 5) + 'П'];
          end;
        end;
        //не найдено времени, и это не текущий день, проставим для времени -1
        if (m = 0)and(vt[i][0] < Date) then begin
          vt[i][2]:=-1;
          vt[i][7]:=1;
        end;
        //найдено времен больше 1, и это не тукущий день, проставим зеттиме, чтобы была подсветка
        if (m > 1)and(vt[i][0] < Date) then begin
          vt[i][9]:=1;    //settime3
          vt[i][7]:=1;    //признак изменения ячейки
        end;
      end;
      if (vt[i][3] = null) then begin
        m:=0;
        for k:=0 to High(vpe) do begin
          if (vpe[k][2] = st)and(Trunc(StrToDateTime(vpe[k][0])) = StrToDate(vt[i][0])) then begin
            inc(m);
            if m = 1 then begin
              vt[i][3]:=HourOf(StrToDateTime(vpe[k][0]))+(MinuteOf(StrToDateTime(vpe[k][0])) / 100);
              vt[i][7]:=1;
            end;
//            if m > 1 then Break;
            vtp:=vtp + [Copy(vpb[k][0], 12, 5) + 'У'];
          end;
        end;
        if (m = 0)and(vt[i][0] < Date) then begin
          vt[i][3]:=-1;
          vt[i][7]:=1;
        end;
        if (m > 1)and(vt[i][0] < Date) then begin
          vt[i][9]:=1;
          vt[i][7]:=1;
        end;
      end;
{     if Length(vtp) > 0 then begin
        A.VarDynArraySort(vtp, True);
        vt[i][12]:=A.Implode(vtp, #13#10);
        vt[i][7]:=1;
      end;}
    end;
  end;

*)
end;














constructor TTurv.Create;
begin
  inherited;
end;

function TTurv.GetWorkerStatusArr(id: Integer): TVarDynArray2;
begin
  Result:=Q.QLoadToVarDynArray2('select dt, status, id_division, id_job from j_worker_status where id_worker = :id$i order by dt desc, id_division, id_job', [id]);
end;

//возвращаем начало периода турв, в колтором находится дата
function TTurv.GetTurvBegDate(dt: TDateTime): TDateTime;
begin
  Result:=EncodeDate(YearOf(dt), MonthOf(dt), S.IIf(DayOf(dt)<=15, 1, 16));
end;

//возвращаем конец периода турв, в колтором находится дата
function TTurv.GetTurvEndDate(dt: TDateTime): TDateTime;
begin
  if DayOf(dt) <= 15
    then Result:=EncodeDate(YearOf(dt), MonthOf(dt), 15)
    else Result:=IncDay(IncMonth(EncodeDate(YearOf(dt), MonthOf(dt), 1), 1), -1);
end;

function TTurv.GetTurvArrayFromDB(DivisionId: Integer; dt: TDateTime; SortByJob: Boolean = True): TNamedArr;
//загрузим массив работников для турв в том же виде что и GetTurvArray, но напрямую из бд
//0-дата1, 1-дата2, 2-айди работника, 3-имя работника, 4-фйди профессии, 5-название профессии,
begin
  dt:=Turv.GetTurvBegDate(dt);
  //запрос. сортировка принципиальна
  Q.QLoadFromQuery(
    'select dt1p, dt2p, id_worker, workername, id_job, job, worker_has_schedule, id_schedule, schedule, id_schedule_active, premium, comm, id_division '+
    'from v_turv_workers where id_division = :id_division$i and dt1 = :dt1$d '+
    'order by ' + S.IIf(SortByJob, 'job', 'workername'),
    [DivisionId, dt],
    Result
  );
end;


//вернем массив работников, которые числятся в данном турв, на основании журнала статусо работников
//по строчке на каждого работника за подпериод в турв
//(если работник преходил между разными должностями, увольнялся и опять принимался в пределах турв, даже если возврат на ту же должность,
//для каждого периода работы отдельная строка в массиве)
//0-дата1, 1-дата2, 2-айди работника, 3-имя работника, 4-фйди профессии, 5-назавание профессии, 6-после периода: 1=переведен 2=уволен, 7-айди графика, 8- название графика
function TTurv.GetTurvArray(DivisionId: Integer; dt: TDateTime; SortByJob: Boolean = True): TVarDynArray2;
var
  i, j, k: Integer;
  dt1, dt2: TDateTime;
  st, st1, st2, w: string;
  v, v1, v2: TVarDynArray2;
  buf: Variant;
  changed: Boolean;
  size: Integer;
begin
  Result:=[];
  dt1:=Turv.GetTurvBegDate(dt);
  dt2:=Turv.GetTurvEndDate(dt);
  //запрос. сортировка принципиальна
  v:=Q.QLoadToVarDynArray2('select id_division, id_worker, workername, id_job, job, status, dt, id_schedule from v_j_worker_status order by workername, dt, job, id_division',[]);
  if Length(v) = 0 then Exit;
  w:=v[0][2];
  //v1 - массив по одному работнику
  //0-дата1, 1-дата2, 2-айди работника, 3-имя работника, 4-фйди профессии, 5-назавание профессии, 6-после периода: 1=переведен 2=уволен
  v1:=[];
  j:=High(v);
  for i:=0 to High(v)+1 do begin
    if (i = High(v)+1) or (v[i][2]<> w) then begin
      //изменился работник или кончились данные
      //скопируем в общий массив
      for j:=0 to High(v1) do begin
        SetLength(Result, Length(Result)+1);
        Result[High(Result)]:=[v1[j][0], v1[j][1], v1[j][2], v1[j][3], v1[j][4], v1[j][5], v1[j][6], v1[j][7]]
      end;
      if (i = High(v)+1) then Break;
      //очистим массив работника
      SetLength(v1, 0);
      w:=v[i][2];
    end;
    if  v[i][6] <= dt1 then begin
      //дата меньше или равна начала периода
      if (v[i][0] = DivisionId)and(Integer(v[i][5]) in [1, 2]) then begin
        //работник принял или переведен в это подразделение
        if Length(v1) = 0 Then SetLength(v1, 1);
        v1[0]:=[dt1, dt2, v[i][1], v[i][2], v[i][3], v[i][4], 0, v[i][7]];
      end
      else begin
        //уволен или переведен в другое подразделение
        SetLength(v1, 0);
      end;
    end
    else if v[i][6] <= dt2 then begin
      //дата в пределах от второго дня периода до конца периода турв
      if (v[i][0] = DivisionId)and(Integer(v[i][5]) in [1, 2]) then begin
        //работник принял или переведен в это подразделение
        if (Length(v1) > 0)and(v1[High(v1)][1] >= v[i][6]) Then begin
          //для прошлой записи работника поставим конечной датой предыдущую из этой записи
          v1[High(v1)][1]:=IncDay(v[i][6], -1);
          //и поставим статус перевод
          v1[High(v1)][6]:=1;
        end;
        SetLength(v1, Length(v1)+1);
        v1[High(v1)]:=[v[i][6], dt2, v[i][1], v[i][2], v[i][3], v[i][4], 0, v[i][7]];
      end
      else if Integer(v[i][5]) in [1, 2] then begin
        //переведен в другое подраздление
        if (Length(v1) > 0)and(v1[High(v1)][1] >= v[i][6]) Then begin
          v1[High(v1)][1]:=IncDay(v[i][6], -1);
          v1[High(v1)][6]:=1;
        end;
      end
      else if Integer(v[i][5]) in [3] then begin
        //уволен
        if (Length(v1) > 0)and(v1[High(v1)][1] >= v[i][6]) Then begin
          v1[High(v1)][1]:=IncDay(v[i][6], -1);
          v1[High(v1)][6]:=2;
        end;
      end;
    end;
  end;

  if not SortByJob then Exit;
// сортировка массива
  repeat
    changed := False; // пусть в текущем цикле нет обменов
    for k := 0 to High(Result) - 1 do
      if Result[k][5] > Result[k + 1][5] then
      begin // обменяем k-й и k+1-й элементы
        for j:=0 to High(Result[k]) do begin
          buf := Result[k][j];
          Result[k][j] := Result[k + 1][j];
          Result[k + 1][j] := buf;
        end;
        changed := True;
      end;
  until not changed; // если не было обменов, значит

end;


function TTurv.GetcodeUV: Integer;
begin
  Result:=16;
end;


function TTurv.GetcodePER: Integer;
begin
  Result:=15;
end;

function TTurv.DeleteTURV(ID: Integer; Silent: Boolean = False): Boolean;
begin
  Result:=False;
  if not Silent then
    if not ((MyQuestionMessage('Удалить ТУРВ?') = mrYes) and (MyQuestionMessage('Вы Уверены?') = mrYes))
      then Exit;
  Q.QExecSql('delete from turv_period where id = :id$i', [ID]);
  Result:=True;
end;



function TTurv.CreateTURV(DivisionId: Variant; AllDivisions: Integer; ActiveOnly: Boolean; dt: TDateTime; Silent: Boolean = True): Integer;
//создаем ТУРВы для указанных подразделений за указанный период
//передается строка через запятую или айди или массив айди подразделений
//AllDivisions = 0 - создает по перечисленным подразделениям, 1 - создает все, 2- создает по своим турв
//если ActiveOnly то не создает по неактивным
//если Silent то молча
//возвращает количество созданных
var
  i, j, k, res, res2: Integer;
  st, st1, st2, w: string;
  v0, v1, v2: TVarDynArray2;
  v: Variant;
  v3: TVarDynArray;
begin
  Result:=-1;
  dt:=GetTurvBegDate(dt);
  st:=S.IIFStr(ActiveOnly, ' and active = 1', '');
  case AllDivisions of
    1: begin
        v0:=Q.QLoadToVarDynArray2('select id, name, active, editusers, id_schedule from v_ref_divisions where 1 = 1' + st, []);
       end;
    2: begin
        v0:=Q.QLoadToVarDynArray2('select id, name, active, editusers, id_schedule from v_ref_divisions where IsStInCommaSt(:u$i, editusers) = 1' + st, [User.GetId]);
       end;
    else
      begin
        v0:=Q.QLoadToVarDynArray2(
          'select id, name, active, editusers, id_schedule from v_ref_divisions where id in (:st$i)' + st, [A.Implode(A.VarIntToArray(DivisionId), ',')]
        );
      end;
  end;
  Result:=0;
  for i:= 0 to High(v0) do begin
    v1:=Q.QLoadToVarDynArray2(
      'select id, id_division, dt1 from turv_period where id_division =:id_division$i and dt1 = :dt1$d',
      [v0[i][0], dt]
    );
    if Length(v1) = 1 then begin
      if not Silent then MyWarningMessage('ТУРВ для подразделения "' + v0[i][1] + '" уже создан!');
      continue;
    end;
    //0-дата1, 1-дата2, 2-айди работника, 3-имя работника, 4-фйди профессии, 5-назавание профессии, 6-после периода: 1=переведен 2=уволен
    v2:=GetTurvArray(v0[i][0], dt);
    if Length(v2) = 0 then begin
      if not Silent then MyWarningMessage('К подразделению "' + v0[i][1] + '" в заданный период не привязан ни один работник! ТУРВ не может быть создан!');
      continue;
    end;
    Q.QBeginTrans;
    res:=Q.QIUD('i', 'turv_period', '', 'id$i;id_division$i;dt1$d;dt2$d;commit$i;id_schedule$i', [0, v0[i][0], dt, GetTurvEndDate(dt), 0, v0[i][4]]);
    if Q.QRowsAffected = 0 then Result:=-1;
    if res = -1 then Result:=-1;
    if Result =- 1 then Break;
    for j:=0 to High(v2) do begin
      res2:=Q.QIUD('i', 'turv_worker', '', 'id$i;id_turv$i;id_worker$i;id_division$i;id_job$i;dt1$d;dt2$d;dt1p$d;dt2p$d;id_schedule',
        [
          0,
          res,            //айди турв период
          v2[j][2],       //работник
          v0[i][0],       //подразделение
          v2[j][4],       //должность
          dt,             //начало периода
          GetTurvEndDate(dt),      //конец
          v2[j][0],                //начало данных строки
          v2[j][1],                 //конец
          v2[j][7]       //график работы
        ]
      );
      if res2 = -1 then
        begin Result:=-1; Break; end;
    end;
    if Result <> -1
      then inc(Result)
      else begin
        Q.QRollbackTrans;
        Break;
      end;
    Q.QCommitTrans;
  end;
end;


function TTurv.ChangeWorkerInTURV(Id_Worker:Variant; ID_Division: Variant; ID_Job: Variant; Dt: TDateTime; ID_JStatus: Variant; Mode: Variant): Boolean;
//правит данные в таблицах для указанного работника, в соответствии с новыми параметрами начиная с указанной даты
//проверяются все турв, передаются новые значения для работника, указание старых параметров не требуется
//так как проверка согласованности выполняется еще по журналу статусов, то может быть изменена
//либо удалена и добавлена только одна запись turv_worker в периоде
//эта же функция изменяет и статус работника в таблице статусов
//добавляет запись для моде ин 1,2,3 и удаляем для -1
//все выполняется в транзакции, при ошибке скл откат
var
  i, j, k, d, res, res2: Integer;
  st, st1, st2, w, dn: string;
  v0, v1, v2, days: TVarDynArray2;
  v: Variant;
  v3: TVarDynArray;
  b, Result1: Boolean;
  m: Integer;
  dt1: TDateTime;
  dayfields: string;
begin
  Result := False;
  //найдем затрагиваемые периоды
  //это будут все периоды с конечной датой большей даты изменения статуса, содержащие любую запись для данного работника и
  //все периоды с ID_Division и также большей конечно датой, это независимо от режима изменения статуса
  //!!! изм 2023-11-17
  //ОШИБКА синхронизация подразделений с воркерстатус происходила по порядку, и если сначала идет подразделение в которой поступает работник,
  //то оно обрабатывалось первым и была попытка вставить запись работника, но это вызывает ошибку так как этот работник и с этой датой мог быть в другом подразделении
  //надо это подразделение обрабатывать последним
  m := Mode;
  v0 := Q.QLoadToVarDynArray2(
    'select distinct d.name, tp.commit, tp.dt1, tp.dt2, d.id from ref_divisions d, turv_period tp, turv_worker tw ' +
    'where d.id = tp.id_division and tp.id = tw.id_turv and tp.dt2 >= :dt$d ' +
    'and (tw.id_worker = :id_worker$i or d.id = :id_division$i) ' +
    'order by tp.dt1, d.name',
     [Dt, Id_Worker, S.IIf(S.NSt(ID_Division) = '', -1, ID_Division)]
  );
  st := '';
  dn := '';
//  v0:=v0 + v1;
  j := 0;
  k := 0;
  for i := 0 to High(v0) do
    if dn <> v0[i][0] then begin
      if S.NNum(v0[i][1]) = 1 then
        inc(k);
      if i < 10 then
        S.ConcatStP(st, v0[i][0] + ' (с ' + VarToStr(v0[i][2]) + ' по ' + VarToStr(v0[i][3]) + S.IIf(S.NNum(v0[i][1]) = 1, ' - Закрыт!', '') + ')', #13#10);
      dn := v0[i][1];
    end;
  if (st <> '') and (MyQuestionMessage('Будут внесены изменения в следующие ТУРВ:'#13#10#13#10 + st + S.IIf(High(v0) >= 10, #13#10'и еще ' + IntToStr(High(v0) - 10) + ' ТУРВ.'#13#10, '') + S.IIf(k > 0, S.IIf(k = Length(v0), #13#10#13#10'Все ТУРВ закрыты!', #13#10#13#10'Часть ТУРВ закрыты!'), '')) <> mrYes) then
    Exit;
  //делаем изменения в таблицах турв
  days := [];
  dayfields := 'dt$d;dt1$d;worktime1$f;worktime2$f;worktime3$f;id_turvcode1$i;id_turvcode2$i;id_turvcode3$i;' + 'premium$i;premium_comm$s;penalty$i;penalty_comm$s;production$i;' + 'comm1$s;comm2$s;comm3$s;begtime$f;endtime$f;settime3$i';
  //получим данные по временам, если у нас будет изменение и при этом работник останется, то данные восстановим
  if ID_Division <> null then begin
    st := Q.QSIUDSql('A', 'turv_day', dayfields) + ' where id_worker = :id_worker$i and dt >= :dt$d order by dt';
    days := Q.QLoadToVarDynArray2(st, [Id_Worker, Dt]);
  end;
  Result := True;
  Result1 := False;
  //начнем транзакцию
  Q.QBeginTrans;
  try
    repeat
    //изменим таблицу статусов, тк она понадобится для коррекции периодов
      if Mode = -1 then begin
        v3 := [ID_JStatus];
//        Result:= (Q.QIUD('d', 'j_worker_status', 'sq_j_worker_status', 'id$i;name;office;id_head;editusers', v3) >= 0);
        Result := (Q.QIUD('d', 'j_worker_status', 'sq_j_worker_status', 'id$i', [ID_JStatus]) >= 0);
      end
      else begin
        v3 := [ID_JStatus, Id_Worker, ID_Division, ID_Job, Mode, Dt];
        Result := (Q.QIUD('i', 'j_worker_status', 'sq_j_worker_status', 'id$i;id_worker$i;id_division$i;id_job$i;status$i;dt$d', [ID_JStatus, Id_Worker, ID_Division, ID_Job, Mode, Dt]) >= 0);
      end;
      if not Result then
        Break;
    //синхронизируем с журналом статусов все задействованные периоды
    //изм 2023-11-17
    //сначала синхронизируем старые для работника подразделения
      for i := 0 to High(v0) do begin
        if v0[i][4] <> S.NNum(ID_Division) then
          Result := Synchronize(v0[i][4], v0[i][2]);
        if not Result then
          Break;
      end;
      if not Result then
        Break;
    //а потом новое подразделение
      for i := 0 to High(v0) do begin
        if v0[i][4] = S.NNum(ID_Division) then
          Result := Synchronize(v0[i][4], v0[i][2]);
        if not Result then
          Break;
      end;
      if not Result then
        Break;
    //снова проставим данные по дням работника, для нового айди и тех же дат
      for i := 0 to High(days) do begin
        v3 := [];
        for j := 0 to High(days[i]) do
          v3 := v3 + [days[i, j]];
        v := v3 + [Id_Worker, days[i][0]];
        st := Q.QSIUDSql('Q', 'turv_day', dayfields) + ' where id_worker = :id_worker$i and dt = :dt_day$d';
        Result := Q.QExecSQL(st, v) >= 0;
        if not Result then
          Break;
      end;
      if not Result then
        Break;
    until True;
    Result1 := True;
  finally
  //фиксируем или отктываем транзакцию
  //для проверки можно вообще убрать и смотреть изменения до выхода из программы, завершить ее по стрл-ф2
    Q.QCommitOrRollback(Result and Result1);
  end;
  if not Result then
    MyWarningMessage('При сохранении данных возникла ошибка! Данные не изменены!');
end;


function TTurv.Synchronize(ID_Division: Integer; dt: TDateTime): Boolean;
var
  i, j, k, res, res2: Integer;
  st, st1, st2, w: string;
  v0, v1, v2: TVarDynArray2;
  v: Variant;
  v3: TVarDynArray;
  b: Boolean;
begin
  Result:=True;
  dt:=GetTurvBegDate(dt);
  v0:=Q.QLoadToVarDynArray2(
    'select id, id_division, dt1 from turv_period where id_division =:id_division$i and dt1 = :dt1$d',
    [id_Division, dt]
  );
  if Length(v0) <> 1 then Exit;
  //массив по работникам для данного турв из базы
  v1:=Q.QLoadToVarDynArray2(
    'select id,id_turv,id_worker,id_division,id_job,dt1,dt2,dt1p,dt2p,0 '+
    'from turv_worker ' +
    'where id_division =:id_division$i and dt1 = :dt1$d',
    [id_Division, dt]
  );
  //массив тутв вычисленный
  //0-дата1, 1-дата2, 2-айди работника, 3-имя работника, 4-фйди профессии, 5-назавание профессии, 6-после периода: 1=переведен 2=уволен
  v2:=GetTurvArray(ID_Division, dt);
  if (Length(v1) = 0) and (Length(v2) = 0) then Exit;
//  QBeginTrans;
  Result:=True;
  repeat
  //удалим записи по работникам, которых нет в вычисленном, сравнивая по айди работника и айди профессии
  for i:=0 to high(v1) do begin
    b:= False;
    for j:=0 to high(v2) do
      if (v1[i][2] = v2[j][2])and(v1[i][4] = v2[j][4]) then
        begin b:=True; Break; end;
    if not b then begin
      Result:=Q.QExecSql('delete from turv_worker where id = :id$i', [v1[i][0]]) >=0;
      v1[i][9]:=1;
      if not Result then Break;
    end;
  end;
  if not Result then Break;
  //теперь скорректируем те у которых не совпадают даты
  for i:=0 to high(v1) do begin
    b:= False;
    for j:=0 to high(v2) do
      //если совпадают по работнику и профессии
      if (v1[i][2] = v2[j][2])and(v1[i][4] = v2[j][4]) then
        //совпадает начальная дата данных по работнику в турв
        if (v1[i][7] = v2[j][0]) then
          if (v1[i][8] = v2[j][1])
            then begin
              //совпадает и конечная, оставим как есть
              v1[i][9]:= 2;
              Break;
            end
            else begin
              //конечная не совпадает, поправим
              Result:=Q.QExecSql('update turv_worker set dt2p = :dt$d where id = :id$i', [v2[j][1], v1[i][0]]) >=0;
              v1[i][9]:=3;
              Break;
            end;
    if not Result then Break;
  end;
  if not Result then Break;
  //удалим из бд те ззаписи, которые не были обработаны (т.е. ране не удалены, не совпадают полностью или не поправлена дата
  for i:=0 to high(v1) do begin
    if (v1[i][9] = 0) then begin
      Result:=Q.QExecSql('delete from turv_worker where id = :id$i', [v1[i][0]]) >=0;
      v1[i][9] := 1;
      if not Result then Break;
    end;
  end;
  if not Result then Break;
  v1:=Q.QLoadToVarDynArray2(
    'select id,id_turv,id_worker,id_division,id_job,dt1,dt2,dt1p,dt2p,0 '+
    'from turv_worker ' +
    'where id_division =:id_division$i and dt1 = :dt1$d',
    [id_Division, dt]
  );
  //добавим в таблицу записи, которых в ней еще нет
  for j:=0 to high(v2) do begin
    b:= False;
    //флаг, если среди обработанных есть с такими же работником, профессией и начальной датой
    for i:=0 to high(v1) do begin
//      if (v1[i][9] >= 2)and(v1[i][2] = v2[j][2])and(v1[i][4] = v2[j][4])and(v1[i][7] = v2[j][0]) then begin
      if (v1[i][2] = v2[j][2])and(v1[i][7] = v2[j][0]) then begin
        b:=True;
        Break;
      end;
    end;
    if not b then begin
      Result:=Q.QIUD('i', 'turv_worker', '', 'id$i;id_turv$i;id_worker$i;id_division$i;id_job$i;dt1$d;dt2$d;dt1p$d;dt2p$d',
        [
          0,
          v0[0][0],       //айди турв период
          v2[j][2],       //работник
          Id_Division,    //подразделение
          v2[j][4],       //должность
          dt,             //начало периода
          GetTurvEndDate(dt),      //конец
          v2[j][0],                //начало данных строки
          v2[j][1]                 //конец
        ]
      ) >=0;
    end;
    if not Result then Break;
  end;
  if not Result then Break;
  until True;
//        QRollbackTrans; exit;
end;

function TTurv.GetActiveWorkers: TVarDynArray2;
//получим массив работников, работающих на данный момент
begin
  Result:=Q.QLoadToVarDynArray2('select id, workername, dt, divisionname, job from v_ref_workers where job is not null', []);
end;

function TTurv.GetWorkersNotInParsec(Mailing: Boolean=False): TVarDynArray2;
//получим массив работников, которые сейчас работают по данным учета, но не найдены в Парсек
var
  vr, vp: TVarDynArray2;
  i, j: Integer;
  st, st1: string;
begin
  Result:=[];
  vr:=GetActiveWorkers;
  vp:=[];
  try
    MyData.QParsec.Close;
    MyData.QParsec.SQL.Text:=
      'select concat(p.last_name, '' '', p.first_name, '' '', p.middle_name) as name from parsec3.dbo.person as p'
    ;
    try
    MyData.QParsec.Open;
    except
    end;
    if not MyData.QParsec.Connection.Connected then Exit;
    while not MyData.QParsec.EOF do begin
      SetLength(vp, Length(vp) + 1);
      SetLength(vp[High(vp)], MyData.QParsec.FieldCount);
      for i:=0 to MyData.QParsec.FieldCount-1
        do vp[High(vp)][i]:=MyData.QParsec.Fields[i].AsVariant;
      MyData.QParsec.Next;
    end;
  except
  end;
  if MyData.QParsec.Active
    then MyData.QParsec.Close
    else Exit;
  for i:=0 to High(vr) do begin
    if A.PosInArray(vr[i][1], vp, 0) < 0
      then Result:=Result + [vr[i]];
  end;
  if High(Result) > 0 then begin
    st:=S.NSt(Q.QSelectOneRow('select emailaddr from v_users where id = :id$i', [33])[0]);
    if st = '' then Exit;
    st1:='';
    for i:=0 to High(Result) do
      st1:=st1+S.NSt(Result[i][1]) + '  [' + S.NSt(Result[i][3]) + ',  ' + S.NSt(Result[i][4])  +']' + #13#10;
    st1:='Следующие работники (которые сейчас работают в компании) отсутствуют в базе Parsec:'#13#10#13#10 + st1;
    Tasks.CreateTaskRoot(mytskopmail, [
//      ['to', 'sprokopenko@fr-mix.ru'],
    ['to', st],
    ['subject', 'Не все работники есть в Parsec!'],
    ['body', st1],
    ['user-name', 'Учёт']]
  );
  end;
end;

function TTurv.GetStatus(ID_Division: Integer; dt: TDateTime): Integer;
//проверим, можго ли закрыть турв, если можно вернем 0
//в будущем хотел сделать остальные статусы, введено все, не введен парсек и тп,
var
  i, j, k, res, res2: Integer;
  st, st1, st2, w: string;
  v0, v1, v2: TVarDynArray2;
  v: Variant;
  v3: TVarDynArray;
  b: Boolean;
begin
  Result:=0;
  v0:=Q.QLoadToVarDynArray2(
    'select id_turvcode1, worktime1, id_turvcode2, worktime2, id_turvcode3, worktime3 from turv_day where id_division = :id$i and dt1 = :dt1$d',
    [ID_Division, dt]
  );
  b:=True;
  //проверим, можно ли закрыть турв
  for i:=0 to High(v0) do begin
    //не введены данные от руководителя
    if (v0[i][0] = null) and (v0[i][1] = null)
      then begin b:=False; Break end;
    //не введены данные по парсек
    if (v0[i][2] = null) and (v0[i][3] = null)
      then begin b:=False; Break end;
    //есть время или код согласованный
    if (v0[i][4] <> null) or (v0[i][5] <> null)
      then Continue;
    //у руководителя время, а по парсек код, или наоборот
    if (v0[i][0] <> null)and(v0[i][2] = null)or(v0[i][0] = null)and(v0[i][2] <> null)or
       (v0[i][1] <> null)and(v0[i][3] = null)or(v0[i][1] = null)and(v0[i][3] <> null)
      then begin b:=False; Break end;
    //и по парсеку и от руководителя время, но различаются больше допустимого
    if (v0[i][1] <> null)and(v0[i][3] <> null)and
      (abs(S.VarToFloat(v0[i][1]) - S.VarToFloat(v0[i][3])) > Module.GetCfgVar(mycfgWtime_autoagreed))
      then begin b:=False; Break end;
  end;
  if not b then Result:=-1;
end;

(*
procedure TDlg_TURV.ImporFromParsec(FileeName: string);
//импорт данных из парсек
//в парсек выгружается отчет приход/уход за месяц, снимается ОБЯЗАТЕЛЬНО выгрузка по одному подразделению на лист
//экспорт отчета осуществляется в формат эксель2007, ставится галка data only
//файл нужно открыть в эксель, будет ошибка и восстановление, и пресохранить
var
  XlsFile:TXlsMemFileEh;
  cr: IXlsFileCellsRangeEh;
  sh: TXlsWorksheetEh;
  v: Variant;
  st: string;
  dt, dt1, dt2, dt3, dt4: TDateTime;
  res: Boolean;
  d1, d2, d1p, cnt, i, j, k, m, cemp: Integer;
  va, va31: TVarDynArray;
  t1, t2, t3, t4, tp: extended;
  vt: TStringDynArray;
const
  rTitle = 8;
  cDtSost = 29;
  cDt1 = 33;
  cDt2 = 36;
  cFio = 1;
  cT = 3;
begin
  if not CreateTXlsMemFileEhFromExists(FileeName, False, '', XlsFile, st) then Exit;
  sh:=xlsFile.Workbook.Worksheets[0]; //регистр имеет значение!
  res:= False;
  repeat
//  st1:=sh.name;
  //читает значение, втч результат формулы
  //col, row с нуля
  v:=sh.cells[0, rTitle].Value;
  if VarToStr(v)<>'ТАБЕЛЬ'#13#10'учета рабочего времени'
    then begin
      MyWarningMessage('Этот файл не является выгрузкой из Parsec!');
      Break;
    end;
  //период за который выбираем данные
  dt1:=Dlg_Turv_FromParsec.dedt_1.Value;
  dt2:=Dlg_Turv_FromParsec.dedt_2.Value;
  //начало и конец месяца
  dt3:=EncodeDate(YearOf(PeriodStartDate), MonthOf(PeriodStartDate), 1);
  dt4:=IncDay(IncMonth(dt3, 1), -1);
  //в файле первая дата должна быть на начало месяца, а вторая не ранее введенной в форме импорта
  if (dt3 <> sh.Cells[cDt1, rTitle].value)or(dt2 > sh.Cells[cDt2, rTitle].value)
    then begin
      MyWarningMessage('Этот файл не является выгрузкой данных за нужный период!');
      Break;
    end;
//  v:=sh.cells[cDtSost, rTitle].Value;
  if MyQuestionMessage('Это выгрузка из Parsec от ' + VartoStr(sh.Cells[cDtSost, rTitle].Value) + #13#10'Продолжить?') <> mrYes
    then Break;
  DBGridEh1.RowDetailPanel.Visible:=False;
  //номер начального столбца в таблице парсек, с единицы, не учитывая смещения
  d1p:=trunc(dt1 - dt3 + 1);
  //номер начального столбца в турв
  d1:= trunc(dt1 - PeriodStartDate + 1);
  //количество затрагиваемых столбцов
  cnt:=trunc(dt2 - dt1 + 1);
  //время начала рабочего дня, из настроек модуля, там оно в часах и минутах - целые это часы, а дробная часть вминута, напр 8.30!
//  t3:=trunc(S.VarToFloat(S.IIf(IsOffice, 0, Module.W_Dinner_Time_Beg_2))) + frac(S.VarToFloat(S.IIf(IsOffice, 0, Module.W_Dinner_Time_Beg_Diff_2)))/60*100;
  t3:=trunc(Module.GetCfgVar(mycfgWtime_beg_2)) + frac(Module.GetCfgVar(mycfgWtime_beg_2))/60*100;
  //время, если раньше него началась работа, подсветим  ..то учитываем весь период и подсветим
  t4:=Max(t3 - S.VarToFloat(Module.GetCfgVar(mycfgWtime_beg_diff_2)), 0);

  SetLength(va31, 32);
  //проходим по турв
  for i:= 0 to High(ArrTurv) do begin
    cemp:=0;
    k:=0;
    //пока не накопилось двадцать пустых клеток по вертикали подряд, ищем данные
    while (cemp < 20) do begin
      v:=Sh.Cells[cFio, k].Value;
      if S.NSt(v) = ''
        then inc(cemp)
        else begin
          if UpperCase(S.NSt(v)) = UpperCase(ArrTitle[i, 2])
            then begin
              //совпадают ФИО в турв и отчете парсек
              m:=ct;
              //выгрузим всю строку по дням подряд
              //тк нет возможности получить заголовок с числами, а есть пустые столбцы, то делаем так
              for j:=1 to 31 do begin
                while S.NSt(Sh.Cells[m, k].Value) = '' do inc(m);
                va31[j]:=S.NSt(Sh.Cells[m, k].Value);
                m:=m + 1;
              end;
              //проходим начиная с первого требуемого дня требуемое количество дней
              for j:=d1 to d1 + cnt - 1 do begin
                //проставляем только для не серых, при времени порасеку либо коду еще не проставленному, но переписываем, если код по парсеку В
                //так как выходные могут быть проставлены заранее из производственного календаря
                if (ArrTurv[i][j][atExists] <> -1) and((ArrTurv[i][j][atTPar] = null)and((ArrTurv[i][j][atCPar] = null)or(ArrTurv[i][j][atCPar] = TurvCodeVyh))) then begin
                  //в ячейке временя прихода и ухода, разделенные переводом строки, часы и минуты через двоеточие
                  vt:=Ah..ExplodeV(StringReplace(va31[j + DayOf(PeriodStartDate) - 1], ':', FormatSettings.DecimalSeparator, [rfReplaceAll]) , #13#10);
                  //сохраним времена
                  if S.IsNumber(vt[0],0,23.59)
                    then ArrTurv[i][j][atBegTime]:=StrToFloat(vt[0])
                    else ArrTurv[i][j][atBegTime]:=-1;
                  if S.IsNumber(vt[1],0,23.59)
                    then ArrTurv[i][j][atEndTime]:=StrToFloat(vt[1])
                    else ArrTurv[i][j][atEndTime]:=-1;
                  t1:=ArrTurv[i][j][atBegTime];
                  t2:=ArrTurv[i][j][atEndTime];
                  if (t1 = -1)and(t2 = -1) then begin
                    //нет ни прихода ни ухода - поставим выходной
                    ArrTurv[i][j][atTPar]:=null;
                    ArrTurv[i][j][atCPar]:=TurvCodeVyh;
                  end
                  else if (t1 = -1)or(t2 = -1) then begin
                    //нет одного времени - поставим 8.00
                    ArrTurv[i][j][atTPar]:=8;
                    ArrTurv[i][j][atCPar]:=null;
                    ArrTurv[i][j][atSetTime]:=1;
                  end
                  else begin
                    //есть оба времени - посчитаем интервал
                    //17:42 = 17.7    7:12 = 7.2    10.5 - 0/5 = 10             8.80 * 4 = 35.2 = 36 / 4 = 9
                    //7.14 - 17.07    7.23 -  17.12 - 0.5 = 9.39 * 4 =  37.56 = 38 = 38/4 = 9.5
                    t1:=trunc(t1) + frac(t1)/60*100;
                    t2:=trunc(t2) + frac(t2)/60*100;
                    {//учтем начало рабочего дня
                    //берем после 8ч, но если начало ранее чем 8ч - 1ч, то берем по парсеку
                    if not IsOffice then
                      if t1 < t4 then begin
                        t1:=Max(t1, t3);
                        ArrTurv[i][j][atSetTime]:=1;
                      end;}
                    //для всех, начало работы принимаем в 8ч (из настроек)
                    t1:=Max(t1, t3);
                    tp:=abs(t2-t1);
                    tp:=Max(0, tp - S.VarToFloat(S.IIf(IsOffice, Module.GetCfgVar(mycfgWtime_dinner_1), Module.GetCfgVar(mycfgWtime_dinner_2))));
                    //округляем до сотых
//                    tp:=RoundTo(tp, -2);
                    if frac(tp) <= 0.33
                      then tp:=trunc(tp)
                      else if frac(tp) <= 0.83
                      then tp:=trunc(tp) + 0.5
                        else tp:=trunc(tp) + 1;
                    //так было бы округление до 15мин всегда в большую сторону
                    //tp:=SimpleRoundTo(tp * 4, 0);
                    //tp:=tp / 4;
                    ArrTurv[i][j][atTPar]:=tp;
                    ArrTurv[i][j][atCPar]:=null;
                    //подсветим (по цеху) кто вышел на час раньше начала рабочего дня
                    ArrTurv[i][j][atSetTime]:=S.IIf((t1<t4) and not IsOffice, 1, null);
                  end;
                  //запишем в датасет для грида
                  SetTurvAllDay(i, j);
                  //запишем в бд
                  SaveDayToDB(i, j, atTPar);
                end;
              end;
              Break;
            end;
          cemp:=0;
        end;
      inc(k);
    end;
  end;
  //обновим грид
  Timer_AfterUpdate.Enabled:=True;
  res:=True;
  until True;
  sh.Free;
  xlsfile.free;
end;
*)


function TTurv.LoadParsecData: Boolean;
//переделан запрос данных из парсека, по новым кодам данных, и с использованием объекта БД myDBParsec
var
  vt, vr, vp, vpb, vpe, vw, vdiv, vpops: TVarDynArray2;
  vtp: TVarDynArray;
  i, j, k, m, idd: Integer;
  st, st1: string;
  dt1, dt2, dt: TDateTime;
  f1, f2: Extended;
  v: Variant;
  t1, t2, t3, t4, tp, tn, tob1, tob2: extended;
  id_vyh, id_otp: Variant;
  b, isoffice: Boolean;
  setprev: Boolean;

  f: TIniFile;
  ParsecConnectionString : string;
begin
//  QExecSql('update turv_day set begtime = null, endtime = null where id_division = 4 and dt >= :dt$d', incday(Date, -1));
  //берем с начала прошлого периода турв
//  dt1:=GetTurvBegDate(IncDay(GetTurvBegDate(Date), -1));
  //первая дата - за 3 дня до начала текущего периода ТУРВ (можно бы за 3 дня до последнего успешного выполнения этой задачи)
  dt1:=IncDay(GetTurvBegDate(Date), -3);
  //вторая дата - конец текущих суток
  dt2:=IncMilliSecond(IncDay(Date, 1), -1);
  vdiv:=Q.QLoadToVarDynArray2('select id from ref_divisions where office = 1', []);
  id_vyh:=Q.QSelectOneRow('select id from ref_turvcodes where code = ''В''', [])[0];
  if id_vyh = null then id_vyh:=-1;
  id_otp:=Q.QSelectOneRow('select id from ref_turvcodes where code = ''ОТ''', [])[0];
  if id_otp = null then id_otp:=-1;
  //бухгалтерия=4, кпп=27, станки = 16
  vt:=Q.QLoadToVarDynArray2(
    'select dt, id_worker, begtime, endtime, id_turvcode2, worktime2, nighttime, 0, null, settime3, id_division, 0, null from turv_day '+
    'where '+
//    '(begtime is null or endtime is null) and '+
    'id_division >= 0 and dt >= :dt1$d and dt <= :dt2$d '+
    'order by id_worker, dt',
    [dt1, Date]
  );
  vw:=Q.QLoadToVarDynArray2('select id, workername from v_ref_workers order by id', []);
  //массивы данных по входу и уходу работников
  vpb:=[];
  vpe:=[];

  {
  Такие коды транзакций в БД Парсека

  на проходной ПЩ:
  590152 Фактический вход
  590153 Фактический выход

  в остальных случаях
  590144 Нормальный вход по ключу
  590145 Нормальный выход по ключу
  }

  //айди операций входа и выхода (есть по два события)
  vpops := [[590144, 590152], [590145, 590153]];

  //пытаемся подключиться к парсеку, выходим если не удалось (без диалога ошибки)
  //!!!на 2025-02-27 выдается окно ошибки, через минуту закроется
  if not myDBParsec.Connect(False) then Exit;;

  //два запроса к БД, по событиям входа и выхода
  //время в БД UTC, приводим к Московскому!
  for i:=0 to 1 do begin
    vp:=[];
    vp := myDBParsec.QLoadToVarDynArray2(
    'select '+
    'format(dateadd(hour, 3, t.tran_date), ''dd.MM.yyyy HH:mm'') as dt, '+
    'case '+
    'when tt.trantype_desc = ''Нормальный вход по ключу'' then ''Приход'' '+
    'when tt.trantype_desc = ''Фактический вход'' then ''Приход'' '+
    'when tt.trantype_desc = ''Нормальный выход по ключу'' then ''Уход'' '+
    'when tt.trantype_desc = ''Фактический выход'' then ''Уход'' '+
    'end as event, '+
    'concat(p.last_name, '' '', p.first_name, '' '', p.middle_name) as name '+
    'from '+
    '  parsec3trans.dbo.translog as t '+
    '  left outer join '+
    '  parsec3.dbo.person as p '+
    '  on t.usr_id = p.pers_id '+
    '  left outer join '+
    '  parsec3.dbo.trantypes_desc tt '+
    '  on t.trantype_id = tt.trantype_id '+
    'where '+
    '  ((t.trantype_id = :trantype1$i)or '+
    '  (t.trantype_id = :trantype2$i)) '+
    '  and '+
    '  (tt.locale = ''RU'') '+
    '  and '+
    '  t.tran_date >= :dt1$d ' +
    '  and '+
    '  t.tran_date <= :dt2$d ' +
    'order by tran_date asc '
    ,
    [vpops[i][0], vpops[i][1], IncHour(dt1, -3), IncHour(dt2, -3)]
    );
    if i=0 then vpb:=copy(vp) else vpe:=copy(vp)
  end;
//Sys.SaveArray2ToFile(vpb, 'r:\vpb', False); Sys.SaveArray2ToFile(vpe, 'r:\vpe'); exit;

(*
  //получим данные по приходу и уходу (590144 - приход)

  //!!!ПАРАМЕТРЫ СОЕДИНЕНИЯ С ПАРСЕК ПОКА УСТАНОВИМ ЗДЕСЬ!!!
    if FileExists(ExtractFilePath(ParamStr(0)) + '\parsec.udl') then begin
    f:=TIniFile.Create(ExtractFilePath(ParamStr(0)) + '\parsec.udl');
    ParsecConnectionString:='Provider=' + f.ReadString('oledb', 'Provider', '');
    MyData.CnParsec.ConnectionString:= ParsecConnectionString;
    MyData.CnParsec.LoginPrompt:= False;
    MyData.CnParsecEh.InlineConnection.ConnectionString:= ParsecConnectionString;
    MyData.CnParsecEh.InlineConnection.LoginPrompt:= False;
    f.Free;
  end;

{
на проходной ПЩ:
590152 Фактический вход
590153 Фактический выход

в остальных случаях
590144 Нормальный вход по ключу
590145 Нормальный выход по ключу
}

  //айди операций входа и выхода
  vpops := [[590144, 590152], [590145, 590153]];

  for i:=0 to 1 do begin
  vp:=[];
  MyData.QParsec.Close;
  MyData.QParsec.SQL.Text:=
  'select '+
  'format(dateadd(hour, 3, t.tran_date), ''dd.MM.yyyy HH:mm'') as dt, '+
  'case '+
  'when tt.trantype_desc = ''Нормальный вход по ключу'' then ''Приход'' '+
  'when tt.trantype_desc = ''Нормальный выход по ключу'' then ''Уход'' '+
  'end as event, '+
  'concat(p.last_name, '' '', p.first_name, '' '', p.middle_name) as name '+
  'from '+
  '  parsec3trans.dbo.translog as t '+
  '  left outer join '+
  '  parsec3.dbo.person as p '+
  '  on t.usr_id = p.pers_id '+
  '  left outer join '+
  '  parsec3.dbo.trantypes_desc tt '+
  '  on t.trantype_id = tt.trantype_id '+
  'where '+
  '  ((t.trantype_id = :trantype1)or '+
  '  (t.trantype_id = :trantype2)) '+
  '  and '+
  '  (tt.locale = ''RU'') '+
  '  and '+
  '  t.tran_date >= :dt1 ' +
  '  and '+
  '  t.tran_date <= :dt2 ' +
   'order by tran_date asc '
  ;
    MyData.QParsec.Parameters[0].DataType:=ftInteger;
    MyData.QParsec.Parameters[0].Value:=vpops[i][0];
    MyData.QParsec.Parameters[1].DataType:=ftInteger;
    MyData.QParsec.Parameters[1].Value:=vpops[i][1];
    MyData.QParsec.Parameters[2].DataType:=ftDateTime;
    MyData.QParsec.Parameters[2].Value:=IncHour(dt1, -3);
    MyData.QParsec.Parameters[3].DataType:=ftDateTime;
    MyData.QParsec.Parameters[3].Value:=IncHour(dt2, -3);
    try
    MyData.QParsec.Open;
    except
    end;
    if not MyData.QParsec.Connection.Connected then Exit;
    while not MyData.QParsec.EOF do begin
      SetLength(vp, Length(vp) + 1);
      SetLength(vp[High(vp)], MyData.QParsec.FieldCount);
      for j:=0 to MyData.QParsec.FieldCount-1
        do vp[High(vp)][j]:=MyData.QParsec.Fields[j].AsVariant;
      MyData.QParsec.Next;
    end;
    if i=0 then vpb:=copy(vp) else vpe:=copy(vp)
  end;
  except
  end;
  if MyData.QParsec.Active
    then MyData.QParsec.Close
    else Exit;

Sys.SaveArray2ToFile(vpb, 'r:\vpb');
Sys.SaveArray2ToFile(vpe, 'r:\vpe');


exit;


*)

















  //найдем времена прихода и ухода работников по данным парсек
//    'select dt, id_worker, begtime, endtime, id_turvcode3, worktime3, nighttime, 0, null from turv_day where begtime is null or endtime is null and id_division = 4 and dt >= :dt1$d and dt <= :dt2$d order by id_worker',
  j:=-1; st:='';
  for i:=0 to High(vt) do begin
//vt[i][2] := null;vt[i][3] := null; //!!! test
      if vt[i][1] <> j then begin
        //если айди работника изменился, то найдем фио этого работника
        st:='';
        for k:=0 to High(vw) do begin
          if vw[k][0] = vt[i][1] then begin
            st:=vw[k][1];
            j:=vw[k][0];
            Break;
          end;
        end;
      end;
      vt[i][8]:=st;
    //для текущего дня не проставляем
    //надо проставлять, тк бывает требууются данные ужде за предыдущий или текущий день!!!
    //if vt[i][0] = Date then Continue;
    //если нет еще данных по времени прихода или ухода
    if (vt[i][2] = null)or(vt[i][3] = null) then begin
      vtp:=[];
      //время прихода
      if (vt[i][2] = null) then begin
        m:=0;
        //найдем время по данным парсек
        for k:=0 to High(vpb) do begin
          if (vpb[k][2] = st)and(Trunc(StrToDateTime(vpb[k][0])) = StrToDate(vt[i][0])) then begin
            inc(m);
            if m = 1 then begin
              //это первое найденное время, его сохраним для турв
              vt[i][2]:=HourOf(StrToDateTime(vpb[k][0]))+(MinuteOf(StrToDateTime(vpb[k][0])) / 100);
              vt[i][7]:=1;
            end;
            //времен больше чем одно, нас интересует только этот факт, выйдем
            //if m > 1 then Break;
            vtp:=vtp + [Copy(vpb[k][0], 12, 5) + 'П'];
          end;
        end;
        //не найдено времени, и это не текущий день, проставим для времени -1
        if (m = 0)and(vt[i][0] < Date) then begin
          vt[i][2]:=-1;
          vt[i][7]:=1;
        end;
        //найдено времен больше 1, и это не тукущий день, проставим зеттиме, чтобы была подсветка
        if (m > 1)and(vt[i][0] < Date) then begin
          vt[i][9]:=1;    //settime3
          vt[i][7]:=1;    //признак изменения ячейки
        end;
      end;
      if (vt[i][3] = null) then begin
        m:=0;
        for k:=0 to High(vpe) do begin
          if (vpe[k][2] = st)and(Trunc(StrToDateTime(vpe[k][0])) = StrToDate(vt[i][0])) then begin
            inc(m);
            if m = 1 then begin
              vt[i][3]:=HourOf(StrToDateTime(vpe[k][0]))+(MinuteOf(StrToDateTime(vpe[k][0])) / 100);
              vt[i][7]:=1;
            end;
//            if m > 1 then Break;
            vtp:=vtp + [Copy(vpb[k][0], 12, 5) + 'У'];
          end;
        end;
        if (m = 0)and(vt[i][0] < Date) then begin
          vt[i][3]:=-1;
          vt[i][7]:=1;
        end;
        if (m > 1)and(vt[i][0] < Date) then begin
          vt[i][9]:=1;
          vt[i][7]:=1;
        end;
      end;
{     if Length(vtp) > 0 then begin
        A.VarDynArraySort(vtp, True);
        vt[i][12]:=A.Implode(vtp, #13#10);
        vt[i][7]:=1;
      end;}
    end;
  end;


  SetLength(vp, 0);
  for i:=0 to High(vt) do begin
    if vt[i][7] = 1 then begin
      SetLength(vp, Length(vp) + 1);
      SetLength(vp[Length(vp)-1], High(vt[i]) + 1);
      for k:=0 to High(vt[i]) do
        vp[Length(vp)-1][k]:=vt[i][k];
    end;
  end;
//  Sys.SaveArray2ToFile(vp, 'r:\1');
//  exit;



  //время прихода и ухода в БД в часах и минутах (они в дробной части)
  //время работы в бд в часах и десятых часа!!!
  //времена t_xx в часах ()и десятых часа!
  //время начала рабочего дня, из настроек модуля, там оно в часах и минутах - целые это часы, а дробная часть минута, напр 8.30!
//  t3:=trunc(S.VarToFloat(S.IIf(IsOffice, 0, Module.W_Dinner_Time_Beg_2))) + frac(S.VarToFloat(S.IIf(IsOffice, 0, Module.W_Dinner_Time_Beg_Diff_2)))/60*100;
  t3:=trunc(Module.GetCfgVar(mycfgWtime_beg_2)) + frac(Module.GetCfgVar(mycfgWtime_beg_2))/60*100;
  //время, если раньше него началась работа, подсветим  ..то учитываем весь период и подсветим
  t4:=Max(t3 - S.VarToFloat(Module.GetCfgVar(mycfgWtime_beg_diff_2)), 0);
//    'select dt, id_worker, begtime, endtime, id_turvcode3, worktime3, nighttime, 0, null, settime3, id_division from turv_day where begtime is null or endtime is null and id_division = 4 and dt >= :dt1$d and dt <= :dt2$d order by id_worker',
  //время окончания обеда по офису, 12ч + время перерыва, в часах и десятых часа
  tob1:=12 + S.VarToFloat(Module.GetCfgVar(mycfgWtime_dinner_1));
  //время окончания обеда по цеху, 12ч + время перерыва, в часах и десятых часа
  tob1:=12 + S.VarToFloat(Module.GetCfgVar(mycfgWtime_dinner_2));
  idd:=-1;
  for i:=0 to High(vt) do begin
    //обрабатываем только те ячейки, где нет ни кода ни времени парсек или же код = В
    //если ранее было изменено время, или если это не последняя в выгрузке, и следующая запись на того же работника, и при этом это следующий день, и при этом было изменено время
    b:=(vt[i][7] = 1) or ((i < High(vt)) and (vt[i][1] = vt[i+1][1]) and
      (DaysBetween(vt[i+1][0], vt[i][0]) = 1) and (vt[i+1][7] = 1));
    //если время и код по парсеку еще не заданы, или же задан выходной но при этом в этот или следующий день были изменения времени прихода/ухода
    if ((vt[i][4] = null)and(vt[i][5] = null))or(((vt[i][4] = id_vyh){or(vt[i][4] = id_otp)}) and b) then begin  //2025-12 убран id_otp
      //если сменился айди подразделения, узнаем офис ли это
      if vt[i][10]<> idd then begin
        idd:=vt[i][10];
        isoffice:=A.PosInArray(idd, vdiv, 0) >= 0;
      end;
      //если хотя бы одно время из парсек не получено, то не считаем по данной ячеке
      //это значит что ЕЩЕ не получено, если прото не будет времени за данный день но оно уже опрашивалось, то будет -1 в данном времени!!!
      if (vt[i][2] = null)or(vt[i][3] = null) then continue;
      //здесь ранее внесенные в базу, в часах и минутах
      //переведем в часы и десятые часа
      t1:=-1;
      if vt[i][2]<>null then t1:=trunc(vt[i][2]) + frac(vt[i][2])/60*100;
      t2:=-1;
      if vt[i][3]<>null then t2:=trunc(vt[i][3]) + frac(vt[i][3])/60*100;
      //обработка для офиса, попроще
      if isoffice then begin
        if (t1 = -1)and(t2 = -1) then begin
          //нет ни прихода ни ухода - поставим выходной
          //если не было никакого кода, тк может быть еще отпуск
          if vt[i][4] = null then vt[i][4]:=id_vyh;
          vt[i][7]:=1;
        end
        else if (t1 = -1)or(t2 = -1) then begin
          //нет одного времени - поставим 8.00 и подсветим
          vt[i][4]:=null;
          vt[i][5]:=8;
          vt[i][9]:=1;
          vt[i][7]:=1;
        end
        else if (t1 > -1)and(t2 > -1) then begin
          //время начала рабочего дня возьмем максимальное от фактического или 8:00
          t1:=Max(t1, t3);
          //вычтем обед, если время ухода ранее окончания обеда
          tp:=abs(t2-t1);
//tp:=tp - S.IIf(t2 < tob1, 0, S.VarToFloat(Module.GetCfgVar(mycfgWtime_dinner_1)));
          tp:=Max(0.01, tp - S.IIf(t2 < tob1, 0, S.VarToFloat(Module.GetCfgVar(mycfgWtime_dinner_1))));
          //округляем
          if frac(tp) <= 0.33
            then tp:=trunc(tp)
            else if frac(tp) <= 0.83
            then tp:=trunc(tp) + 0.5
              else tp:=trunc(tp) + 1;
          vt[i][4]:=null;
          vt[i][5]:=tp;
          vt[i][7]:=1;
        end;
      end
      //для цеха
      else begin
        tp:=0;
        //предыдущая запись это прошлый день того же работника, и это ночная или суточная смена, пометим, так как это используется для вычисления времени
        if (i > 0) and (vt[i][1] = vt[i-1][1]) and (DaysBetween(vt[i-1][0], vt[i][0]) = 1) and ((vt[i-1][6] <> null) or (vt[i-1][5] >=20))
          then vt[i-1][11] := 1;
        //setprev:=False;
        if (t1 = -1)and(t2 = -1) then begin
          //нет ни прихода ни ухода - поставим выходной, или оставим код, там мог быть отпуск
          if vt[i][4] = null then vt[i][4]:=id_vyh;
          vt[i][7]:=1;
        end
        //есть приход, но нет ухода с работы, или уход раньше прихоода
        //(это будет если каждые сутки работает в ночную смену)
        else if (t1 > -1)and((t2 = -1)or(t2 < t1)) then begin
          //если это не последняя в выгрузке, и следующая запись на того же работника, и при этом это следующий день
          if (i < High(vt)) and (vt[i][1] = vt[i+1][1]) and (DaysBetween(vt[i+1][0], vt[i][0]) = 1) then begin
            if (vt[i+1][3]<>null)and(vt[i+1][3]<>-1) then begin
              t2:=trunc(vt[i+1][3]) + frac(vt[i+1][3])/60*100;
              t2:=t2 + 24;
              //суточная смена, обед не учитываем, не ставим больше 24 часов
              if (t2 - t1 >= 20)and(t2 - t1 <= 26) then begin
                tp:=Min(24, t2 - t1);
                vt[i][11]:=1;
              end
              //ночная смена, обед учитываем
              else if (t2 - t1 <= 14) then begin
                tp:=max(0.01, t2 - t1 - S.VarToFloat(Module.GetCfgVar(mycfgWtime_dinner_2)));
                t1:=max(t1, 22);
                //посчитаем время работы ночью (с 22ч до 6ч), обед в нее не ставится
                tn:=max(t2 - t1, 0);
                //не может быть больше продолжительности всей смены
                tn:=min(tn, tp);
                //округлим
                if frac(tn) <= 0.33
                  then tn:=trunc(tn)
                  else if frac(tn) <= 0.83
                  then tn:=trunc(tn) + 0.5
                    else tn:=trunc(tn) + 1;
                vt[i][6]:=tn;
                vt[i][11]:=1;
              end
              //не вложились по временам - поставим 8 с выделением
              else tp:=-8;
            end
            else if (vt[i+1][3] = -1) then begin
              //на следующий день ухода не было
              tp:=-8;
            end;
          end  //енд тот же работник завтра
          else tp:= -8;
        end  //енд есть приход а уход раньше или нет ухода
        else if (t1 = -1)and(t2 > -1) then begin
          if not((i > 0)and(vt[i-1][11] = 1))
            then tp:=-8
            else begin
              vt[i][4]:=id_vyh;
              vt[i][7]:=1;
            end;
        end
        else if (t1 > -1)and(t2 > -1) then begin
          //есть и приход и уход
          //время начала рабочего дня возьмем максимальное от фактического или 8:00
          t1:=Max(t1, t3);
          //вычтем обед
          tp:=abs(t2-t1);
          tp:=Max(0.01, tp - S.IIf(t2 < tob2, 0, S.VarToFloat(Module.GetCfgVar(mycfgWtime_dinner_2))));
        end;
        if tp > 0 then begin
          if frac(tp) <= 0.33
            then tp:=trunc(tp)
            else if frac(tp) <= 0.83
            then tp:=trunc(tp) + 0.5
              else tp:=trunc(tp) + 1;
          vt[i][4]:=null;
          vt[i][5]:=tp;
          vt[i][7]:=1;
        end
        else if tp = -8 then begin
          vt[i][4]:=null;
          vt[i][5]:=8;
          vt[i][9]:=1;
          vt[i][7]:=1;
        end;
      end;  //енд цех
    end;
  end;
//ночный и суточный только цеха
//есть сегодня приход, завтра уход
//смены по суткам и ночные только по цеху
//если разница 20-26ч то суточная смена 24ч или меньше, обед не вычитаем (меня за первый день)
//если разница до 14 часов, то смена, ночью у 22 до 6, вычитаем обед
//если не вписывается вэти промежутки то ставим 8ч
//с 8утра (макс 8ч - по парсеку) все, независимо от схемы  Не будет
//округление рабочего времени, и ночной смены до 0.5ч
//подсвечивать несколько входов или выходов, или отсутствие входа и выхода

  //создадим массив, где только измененные данные
  SetLength(vp, 0);
  for i:=0 to High(vt) do begin
    if vt[i][7] = 1 then begin
      SetLength(vp, Length(vp) + 1);
      SetLength(vp[Length(vp)-1], High(vt[i]) + 1);
      for k:=0 to High(vt[i]) do
        vp[Length(vp)-1][k]:=vt[i][k];
    end;
  end;

//  Sys.SaveArray2ToFile(vp, 'r:\111');
//exit;

  //запишем в бд
  Q.QBeginTrans;
  b:=False;
  try
  for i:=0 to High(vp) do begin
//    'select dt, id_worker, begtime, endtime, id_turvcode3, worktime3, nighttime, 0, null, settime3, id_division, 0 from turv_day '+
    Q.QExecSql(
    'update turv_day set begtime = :begtime$f, endtime = :endtime$f, '+
    'id_turvcode2 = :id_turvcode2$i, worktime2 = :worktime2$f, nighttime = :nighttime$f, settime3 = :settime3$i '+
    'where id_worker = :id_worker$i and dt = :dt$d',
    [
      vp[i][2], vp[i][3], vp[i][4], vp[i][5], vp[i][6], vp[i][9],
      vp[i][1], vp[i][0]
    ]
    );
  end;
  b:=True;
  finally
  Q.QCommitOrRollback(b);
  end;
end;


function TTurv.GetDaysFromCalendar(DtBeg, DtEnd: TDateTime): TVarDynArray2;
//вернет двумерный массив последовательныйх дат (за каждый день) и типа рабочий/выходной (0 - выходной, 1 - рабочий) с
//учетом производственного календаря
//[[1.1.23,1], [2.1.23,1],[3.1.23,0]....
var
  i, j: Integer;
  va2: TVarDynArray2;
  dt: TDateTime;
begin
  Result:=[];
  va2:=Q.QLoadToVarDynArray2('select dt, type from ref_holidays where dt >=:dt1$d and dt <=:dt2$d', [DtBeg, DtEnd]);
  dt:=DtBeg;
  while dt <= DtEnd do begin
    Result:=Result + [[dt, 1]];
    if DayOfTheWeek(dt) in [6,7] then Result[High(Result)][1]:=0;
    //1, 'в', 2, 'с', 3, 'р'
    j:= A.PosInArray(dt, va2, 0);
    if (j>=0)and(va2[j][1] = 1) then Result[High(Result)][1]:=0;
    if (j>=0)and(va2[j][1] > 1) then Result[High(Result)][1]:=1;
    dt:=IncDay(dt, 1);
  end;
end;

function TTurv.GetDaysFromCalendar_Next(DtBeg: TDateTime; CntOfWork: Integer): TDateTime;
//вернет ближайший рабочий день, отстоящий от переданной даты на CntOfWork  (+ - вперед, - назад)
//!!НЕТ т.е. CntOfWork = количество рабочих дней, считая текущий
//!!НЕТ напр сегодня вт, -1 и +1 будет вт -2 будет пн, -3 будет пт, но если сегодня сб, то -1 будет пт
//0 всегда возвращает текущий день, неважно рабочий он или нет
//-1 вернет вчерашний, если он был рабочий, а если вчера была суббота, то вернет пятницу.
//то есть CntOfWork количество рабочих дней, не считая текущий (не важно рабочий он или нет), которые надо прибавить/отнять к текущей дате
var
  i, j, k: Integer;
  va2: TVarDynArray2;
  dt: TDateTime;
begin
  Result := DtBeg;
  if CntOfWork = 0 then
    Exit;
  j := 0;
  k := -1;
  if CntOfWork > 0 then begin
    va2 := GetDaysFromCalendar(DtBeg, IncDay(DtBeg, CntOfWork + (CntOfWork div 7) * 2 + 20));
    for i := 0 to High(va2) do begin
      if va2[i][1] = 1 then
        inc(j);
      if j = CntOfWork then begin
        k := i;
        Break;
      end;
    end;
  end
  else begin
    va2 := GetDaysFromCalendar(IncDay(DtBeg, -(CntOfWork + (CntOfWork div 7) * 2 + 20)), DtBeg);
    for i := High(va2) - 1 downto 0 do begin
      if va2[i][1] = 1 then
        inc(j);
      if j = -CntOfWork then begin
        k := i;
        Break;
      end;
    end;
  end;
  if k <> -1 then
    Result := va2[k][0]          //!!! неверное если нет рабочих дней, напр каникулы НГ!!!
  else
    Result := micntBadDate;
end;

function TTurv.DeletePayrollCalculations(AId: Variant): Boolean;
begin
  Result := False;
  var va: TVarDynArray := Q.QSelectOneRow('select departament, employee, dt1, dt2 from v_w_payroll_calculations where id = :id$i', [AId]);
  if va[0] = null then
    Exit;
  if Q.DBLock(True, myfrm_Dlg_Payroll, AID)[0] <> True then
    Exit;
  if (MyQuestionMessage(
     'Будет удалена ведомость расчета заработной платы'#13#10 +
      S.IIFStr(va[1].AsString = '', 'по подразделению "' + va[0] + '"'#13#10, 'по работнику "' + va[1] + '"'#13#10 + '(подразделение "' + va[0] + '"'#13#10) +
      'за период с ' + va[2].AsDate + ' по ' + va[3].AsDate + #13#10 + #13#10 + '.' + 'Продолжить?'
     ) = mrYes) and (MyQuestionMessage('Удалить ведомость?') = mrYes) then begin
    Q.QExecSql('delete from payroll where id = :id$i', [AID], True);
    Q.DBLock(False, myfrm_Dlg_Payroll, AID);
    Result := True;
  end
  else
    Q.DBLock(False, myfrm_Dlg_Payroll, AID);
end;


function TTurv.ExecureWorkCheduledialog(AOwner: TComponent; AId: Variant; AMode: TDialogType): Boolean;
//диалог ввода графика работы и норм рабочего времени по нему
var
  i, j: Integer;
  va11, va12, va13: TVarDynArray;
  va2: TVarDynArray2;
  Id, IdH: Variant;
begin
  Result := False;
  va11 := Q.QSelectOneRow('select dt1, dt2, dt3, dt4 from v_w_schedules where rownum = 1', []);
  va12 := Q.QSelectOneRow('select code, name, hours1, hours2, hours3, hours4, comm, active from v_w_schedules where id = :id$i', [AId]);
  if va12[0] = null then
    va12 := ['', '', null, null, null, null, 1];
  for i := 0 to 3 do
    va2 := va2 + [[cntNEdit, 'С ' + DateToStr(va11[i]), '0:1000:2']];
    if TFrmBasicInput.ShowDialog(AOwner, '', [], AMode, 'График работы', 370, 80,
      [[cntEdit, 'Код', '1:50::T'], [cntEdit, 'Наименование', '1:400::T']] + va2 +  [[cntEdit, 'Комментарий', '0:400::T'], [cntCheckX, 'Используется', '']],
      va12,
      va13, [['Добавьте или отредактируйте параметра графика работы'#13#10'Задайте нормы рабочего времени по ближайшим периодам для данного графика']], nil
    ) < 0 then Exit;
  Id := Q.QIUD(Q.QFModeToIUD(AMode), 'w_schedules', '', 'id$i;code$s;name$s;comm;active$i', [AId, va13[0], va13[1], va13[6], va13[7]]);
  if Id = -1 then
    Exit;
  if AMode = fAdd then
    AId := Id;
  for i := 0 to 3 do begin
    IdH := Q.QSelectOneRow('select id from w_schedule_hours where id_schedule = :id$i and dt = :dt$d', [AId, va11[i]])[0];
    Id := Q.QIUD(S.IIf(IdH = null, 'i', 'u'), 'w_schedule_hours', '', 'id$i;id_schedule$i;dt$d;hours$f', [IdH, AId, va11[i], va13[1 + i]]);
  end;
  Result := True;
end;

function TTurv.ExecureJPersBonusDialog(AOwner: TComponent; AId: Variant; AIdEmpl: Variant; AMode: TDialogType): Boolean;
//диалог ввода персональной надбавки для работника
//!!! нужно обрабатывать сообщения об ошибках ORA-20000/20999, это генерация raise_application_error
var
  i, j: Integer;
  va11, va12, va13: TVarDynArray;
  va2: TVarDynArray2;
  Id, IdH: Variant;
  res: Integer;
begin
  Result := False;
  try
    TFrmBasicInput.ShowDialogDB3(AOwner, '', [dbioModal, dbioStatusBar], AMode, AId, 'w_employee_pers_bonus', 'Персональная надбавка', 600, 70, [
      ['id_pers_bonus$i', cntComboLK, 'Вид надбавки','1:400'],
      ['dt_beg$d', cntDEdit, 'C',':'],
      ['dt_end$d', cntDEdit, 'По',':']],
      ['select name, id from w_pers_bonus where active = 1 order by name'],
      [['caption dlgedit']]
    );
    if AMode = fAdd then
      res := Q.QExecSql('update w_employee_pers_bonus set id_employee = :ide$i where id_employee is null', [AIdEmpl]);
  except
    Q.QExecSql('delete from w_employee_pers_bonus where id_employee is null', [AIdEmpl], False);
    Result := res <> -1;
    MyWarningMessage('Диапазон дат перекрывается с существующей записью для данного работника и вида надбавки.'#13#10'Данные не изменены!');
    Exit;
  end;
  Q.QExecSql('delete from w_employee_pers_bonus where id_employee is null', [AIdEmpl]);
  Result := AMode <> fView;
end;

function TTurv.CreateAllTurvforDate(AOwner: TComponent; ADt: Variant): Boolean;
var
  va1, va2, va3: TVarDynArray;
  i, j: Integer;
  LDate: TDateTime;
begin
  Result := False;
  LDate := Date;
  if User.IsDeveloper then begin
    if TFrmBasicInput.ShowDialog(AOwner, '', [], fEdit, '~Дата для создаваемых ТУРВ', 370, 80,
      [[cntDtEdit, 'Дата', '*:*']], [Date], va3, [['Любая дата внутри периода для создаваемых ТУРВ']], nil
    ) < 0 then Exit;
    LDate := va3[0];
  end;
  if MyQuestionMessage('Создать все ТУРВ за период с ' + DateToStr(Turv.GetTurvBegDate(LDate)) + ' по ' + DateToStr(Turv.GetTurvEndDate(LDate)) + ' ?') <> mrYes then
    Exit;
  va1 := Q.QSelectOneRow('select id_departament from w_employee_properties where dt_beg <= :dte$d and (dt_end is null or dt_end >= :dtb$d)', [Turv.GetTurvEndDate(LDate), Turv.GetTurvBegDate(LDate)]);
  va2 := Q.QSelectOneRow('select id_departament from w_turv_period where dt1 = :dt$d', [Turv.GetTurvBegDate(LDate)]);
  j := 0;
  for i := 0 to High(va1) do
    if not A.InArray(va1[i], va2) then begin
      Q.QExecSql('insert into w_turv_period (id_departament, dt1, dt2, is_finalized, status) values (:idd$i, :dtb$d, :dte$d, 0, 0)', [va1[i], Turv.GetTurvBegDate(LDate), Turv.GetTurvEndDate(LDate)]);
      inc(j);
    end;
  if j = 0 then
    MyInfoMessage('Ни один ТУРВ не создан!')
  else begin
    MyInfoMessage('Создан ' + IntToStr(j) + ' ТУРВ.');
    Result := True;
  end;
end;



function TTurv.ExecureRefPersBonusDialog(AOwner: TComponent; AId: Variant; AMode: TDialogType): Boolean;
//диалог ввода для справочника первоняльных надбавок
//данные надбавки и суммы за текущий и следующий месяц
var
  i, j: Integer;
  va11, va12, va13: TVarDynArray;
  va2: TVarDynArray2;
  Id, IdH: Variant;
begin
  Result := False;
  va11 := [{EncodeDate(YearOf(IncMonth(Date, -1)), MonthOf(IncMonth(Date, -1)), 1), }EncodeDate(YearOf(IncMonth(Date, 0)), MonthOf(IncMonth(Date, 0)), 1), EncodeDate(YearOf(IncMonth(Date, +1)), MonthOf(IncMonth(Date, +1)), 1) ];
//  va11 := Q.QSelectOneRow('select dt1, dt2, dt3, dt4 from v_w_schedules where rownum = 1', []);
  va12 := Q.QSelectOneRow('select name, sum2, sum3, comm, active from v_w_pers_bonus where id = :id$i', [AId]);
  if va12[0] = null then
    va12 := ['', null, null, null, 1];
  for i := 0 to 1 do
    va2 := va2 + [[cntNEdit, 'С ' + DateToStr(va11[i]), '1:100000:2']];
    if TFrmBasicInput.ShowDialog(AOwner, '', [], AMode, 'Надбавка', 370, 80,
      [[cntEdit, 'Наименование', '1:400::T']] + va2 +  [[cntEdit, 'Комментарий', '0:4000::T'], [cntCheckX, 'Используется', '']],
      va12,
      va13, [['Добавьте или отредактируйте запись для вида персональной надбавки.'#13#10'Задайте суммы надбаки для текущего и следующего месяца.']], nil
    ) < 0 then Exit;
  Id := Q.QIUD(Q.QFModeToIUD(AMode), 'w_pers_bonus', '', 'id$i;name$s;comm;active$i', [AId, va13[0], va13[3], va13[4]]);
  if Id = -1 then
    Exit;
  if AMode = fAdd then
    AId := Id;
  for i := 0 to 1 do begin
    Q.QExecSql('delete from w_pers_bonus_sum where id_pers_bonus = :id$i and dt = :dt$d', [AId, va11[i]]);
    Q.QExecSql('insert into w_pers_bonus_sum (id_pers_bonus, dt, sum) values (:id$i, :dt$d, :sum$f)', [AId, va11[i], va13[1 + i]]);
  end;
  Result := True;
end;





function TTurv.LoadParsecDataNew: Boolean;
//переделан запрос данных из парсека, по новым кодам данных, и с использованием объекта БД myDBParsec
var
  vt, vr, vp, vpb, vpe, vw, vdiv, vpops: TVarDynArray2;
  vtp: TVarDynArray;
  i, j, k, m, idd: Integer;
  st, st1: string;
  dt1, dt2, dt: TDateTime;
  f1, f2: Extended;
  v: Variant;
  t1, t2, t3, t4, tp, tn, tob1, tob2: extended;
  id_vyh, id_otp: Variant;
  b, isoffice: Boolean;
  setprev: Boolean;

  f: TIniFile;

  EmplProps: TNamedArr;
begin
  //первая дата - за 3 дня до начала текущего периода ТУРВ (можно бы за 3 дня до последнего успешного выполнения этой задачи)
  dt1:=IncDay(GetTurvBegDate(Date), -3);
  //вторая дата - конец текущих суток
  dt2:=IncMilliSecond(IncDay(Date, 1), -1);
  vdiv:=Q.QLoadToVarDynArray2('select id from w_departaments where is_office = 1', []);
  id_vyh:=Q.QSelectOneRow('select id from w_turvcodes where code = ''В''', [])[0];
  if id_vyh = null then id_vyh:=-1;
  id_otp:=Q.QSelectOneRow('select id from w_turvcodes where code = ''ОТ''', [])[0];
  if id_otp = null then id_otp:=-1;

  Q.QLoadFromQuery(
    'select id, dt_beg, dt_end, id_employee, id_job, grade, id_schedule, id_departament, id_organization, is_trainee, is_foreman, is_concurrent, personnel_number, ' +
    'name, name as employee, departament, job, schedulecode ' +
    'from v_w_employee_properties ' +
    'where is_terminated <> 1 and dt_beg <= :dt_end$d and (dt_end is null or dt_end >= :dt_beg$d) ' +
    //'and id_departament = :id_dep$i ' +
    'order by id_employee, dt_beg, job',
    [dt2, dt1],
    EmplProps
  );

  for i := 0 to EmplProps.Count - 1 do begin

  end;

  Exit;



  //бухгалтерия=4, кпп=27, станки = 16
  vt:=Q.QLoadToVarDynArray2(
    'select dt, id_worker, begtime, endtime, id_turvcode2, worktime2, nighttime, 0, null, settime3, id_division, 0, null from turv_day '+
    'where '+
//    '(begtime is null or endtime is null) and '+
    'id_division >= 0 and dt >= :dt1$d and dt <= :dt2$d '+
    'order by id_worker, dt',
    [dt1, Date]
  );
  vw:=Q.QLoadToVarDynArray2('select id, workername from v_ref_workers order by id', []);
  //массивы данных по входу и уходу работников
  vpb:=[];
  vpe:=[];

  {
  Такие коды транзакций в БД Парсека

  на проходной ПЩ:
  590152 Фактический вход
  590153 Фактический выход

  в остальных случаях
  590144 Нормальный вход по ключу
  590145 Нормальный выход по ключу
  }

  //айди операций входа и выхода (есть по два события)
  vpops := [[590144, 590152], [590145, 590153]];

  //пытаемся подключиться к парсеку, выходим если не удалось (без диалога ошибки)
  //!!!на 2025-02-27 выдается окно ошибки, через минуту закроется
  if not myDBParsec.Connect(False) then Exit;;

  //два запроса к БД, по событиям входа и выхода
  //время в БД UTC, приводим к Московскому!
  for i:=0 to 1 do begin
    vp:=[];
    vp := myDBParsec.QLoadToVarDynArray2(
    'select '+
    'format(dateadd(hour, 3, t.tran_date), ''dd.MM.yyyy HH:mm'') as dt, '+
    'case '+
    'when tt.trantype_desc = ''Нормальный вход по ключу'' then ''Приход'' '+
    'when tt.trantype_desc = ''Фактический вход'' then ''Приход'' '+
    'when tt.trantype_desc = ''Нормальный выход по ключу'' then ''Уход'' '+
    'when tt.trantype_desc = ''Фактический выход'' then ''Уход'' '+
    'end as event, '+
    'concat(p.last_name, '' '', p.first_name, '' '', p.middle_name) as name '+
    'from '+
    '  parsec3trans.dbo.translog as t '+
    '  left outer join '+
    '  parsec3.dbo.person as p '+
    '  on t.usr_id = p.pers_id '+
    '  left outer join '+
    '  parsec3.dbo.trantypes_desc tt '+
    '  on t.trantype_id = tt.trantype_id '+
    'where '+
    '  ((t.trantype_id = :trantype1$i)or '+
    '  (t.trantype_id = :trantype2$i)) '+
    '  and '+
    '  (tt.locale = ''RU'') '+
    '  and '+
    '  t.tran_date >= :dt1$d ' +
    '  and '+
    '  t.tran_date <= :dt2$d ' +
    'order by tran_date asc '
    ,
    [vpops[i][0], vpops[i][1], IncHour(dt1, -3), IncHour(dt2, -3)]
    );
    if i=0 then vpb:=copy(vp) else vpe:=copy(vp)
  end;
















  //найдем времена прихода и ухода работников по данным парсек
//    'select dt, id_worker, begtime, endtime, id_turvcode3, worktime3, nighttime, 0, null from turv_day where begtime is null or endtime is null and id_division = 4 and dt >= :dt1$d and dt <= :dt2$d order by id_worker',
  j:=-1; st:='';
  for i:=0 to High(vt) do begin
//vt[i][2] := null;vt[i][3] := null; //!!! test
      if vt[i][1] <> j then begin
        //если айди работника изменился, то найдем фио этого работника
        st:='';
        for k:=0 to High(vw) do begin
          if vw[k][0] = vt[i][1] then begin
            st:=vw[k][1];
            j:=vw[k][0];
            Break;
          end;
        end;
      end;
      vt[i][8]:=st;
    //для текущего дня не проставляем
    //надо проставлять, тк бывает требууются данные ужде за предыдущий или текущий день!!!
    //if vt[i][0] = Date then Continue;
    //если нет еще данных по времени прихода или ухода
    if (vt[i][2] = null)or(vt[i][3] = null) then begin
      vtp:=[];
      //время прихода
      if (vt[i][2] = null) then begin
        m:=0;
        //найдем время по данным парсек
        for k:=0 to High(vpb) do begin
          if (vpb[k][2] = st)and(Trunc(StrToDateTime(vpb[k][0])) = StrToDate(vt[i][0])) then begin
            inc(m);
            if m = 1 then begin
              //это первое найденное время, его сохраним для турв
              vt[i][2]:=HourOf(StrToDateTime(vpb[k][0]))+(MinuteOf(StrToDateTime(vpb[k][0])) / 100);
              vt[i][7]:=1;
            end;
            //времен больше чем одно, нас интересует только этот факт, выйдем
            //if m > 1 then Break;
            vtp:=vtp + [Copy(vpb[k][0], 12, 5) + 'П'];
          end;
        end;
        //не найдено времени, и это не текущий день, проставим для времени -1
        if (m = 0)and(vt[i][0] < Date) then begin
          vt[i][2]:=-1;
          vt[i][7]:=1;
        end;
        //найдено времен больше 1, и это не тукущий день, проставим зеттиме, чтобы была подсветка
        if (m > 1)and(vt[i][0] < Date) then begin
          vt[i][9]:=1;    //settime3
          vt[i][7]:=1;    //признак изменения ячейки
        end;
      end;
      if (vt[i][3] = null) then begin
        m:=0;
        for k:=0 to High(vpe) do begin
          if (vpe[k][2] = st)and(Trunc(StrToDateTime(vpe[k][0])) = StrToDate(vt[i][0])) then begin
            inc(m);
            if m = 1 then begin
              vt[i][3]:=HourOf(StrToDateTime(vpe[k][0]))+(MinuteOf(StrToDateTime(vpe[k][0])) / 100);
              vt[i][7]:=1;
            end;
//            if m > 1 then Break;
            vtp:=vtp + [Copy(vpb[k][0], 12, 5) + 'У'];
          end;
        end;
        if (m = 0)and(vt[i][0] < Date) then begin
          vt[i][3]:=-1;
          vt[i][7]:=1;
        end;
        if (m > 1)and(vt[i][0] < Date) then begin
          vt[i][9]:=1;
          vt[i][7]:=1;
        end;
      end;
{     if Length(vtp) > 0 then begin
        A.VarDynArraySort(vtp, True);
        vt[i][12]:=A.Implode(vtp, #13#10);
        vt[i][7]:=1;
      end;}
    end;
  end;


  SetLength(vp, 0);
  for i:=0 to High(vt) do begin
    if vt[i][7] = 1 then begin
      SetLength(vp, Length(vp) + 1);
      SetLength(vp[Length(vp)-1], High(vt[i]) + 1);
      for k:=0 to High(vt[i]) do
        vp[Length(vp)-1][k]:=vt[i][k];
    end;
  end;
//  Sys.SaveArray2ToFile(vp, 'r:\1');
//  exit;



  //время прихода и ухода в БД в часах и минутах (они в дробной части)
  //время работы в бд в часах и десятых часа!!!
  //времена t_xx в часах ()и десятых часа!
  //время начала рабочего дня, из настроек модуля, там оно в часах и минутах - целые это часы, а дробная часть минута, напр 8.30!
//  t3:=trunc(S.VarToFloat(S.IIf(IsOffice, 0, Module.W_Dinner_Time_Beg_2))) + frac(S.VarToFloat(S.IIf(IsOffice, 0, Module.W_Dinner_Time_Beg_Diff_2)))/60*100;
  t3:=trunc(Module.GetCfgVar(mycfgWtime_beg_2)) + frac(Module.GetCfgVar(mycfgWtime_beg_2))/60*100;
  //время, если раньше него началась работа, подсветим  ..то учитываем весь период и подсветим
  t4:=Max(t3 - S.VarToFloat(Module.GetCfgVar(mycfgWtime_beg_diff_2)), 0);
//    'select dt, id_worker, begtime, endtime, id_turvcode3, worktime3, nighttime, 0, null, settime3, id_division from turv_day where begtime is null or endtime is null and id_division = 4 and dt >= :dt1$d and dt <= :dt2$d order by id_worker',
  //время окончания обеда по офису, 12ч + время перерыва, в часах и десятых часа
  tob1:=12 + S.VarToFloat(Module.GetCfgVar(mycfgWtime_dinner_1));
  //время окончания обеда по цеху, 12ч + время перерыва, в часах и десятых часа
  tob1:=12 + S.VarToFloat(Module.GetCfgVar(mycfgWtime_dinner_2));
  idd:=-1;
  for i:=0 to High(vt) do begin
    //обрабатываем только те ячейки, где нет ни кода ни времени парсек или же код = В
    //если ранее было изменено время, или если это не последняя в выгрузке, и следующая запись на того же работника, и при этом это следующий день, и при этом было изменено время
    b:=(vt[i][7] = 1) or ((i < High(vt)) and (vt[i][1] = vt[i+1][1]) and
      (DaysBetween(vt[i+1][0], vt[i][0]) = 1) and (vt[i+1][7] = 1));
    //если время и код по парсеку еще не заданы, или же задан выходной но при этом в этот или следующий день были изменения времени прихода/ухода
    if ((vt[i][4] = null)and(vt[i][5] = null))or(((vt[i][4] = id_vyh){or(vt[i][4] = id_otp)}) and b) then begin  //2025-12 убран id_otp
      //если сменился айди подразделения, узнаем офис ли это
      if vt[i][10]<> idd then begin
        idd:=vt[i][10];
        isoffice:=A.PosInArray(idd, vdiv, 0) >= 0;
      end;
      //если хотя бы одно время из парсек не получено, то не считаем по данной ячеке
      //это значит что ЕЩЕ не получено, если прото не будет времени за данный день но оно уже опрашивалось, то будет -1 в данном времени!!!
      if (vt[i][2] = null)or(vt[i][3] = null) then continue;
      //здесь ранее внесенные в базу, в часах и минутах
      //переведем в часы и десятые часа
      t1:=-1;
      if vt[i][2]<>null then t1:=trunc(vt[i][2]) + frac(vt[i][2])/60*100;
      t2:=-1;
      if vt[i][3]<>null then t2:=trunc(vt[i][3]) + frac(vt[i][3])/60*100;
      //обработка для офиса, попроще
      if isoffice then begin
        if (t1 = -1)and(t2 = -1) then begin
          //нет ни прихода ни ухода - поставим выходной
          //если не было никакого кода, тк может быть еще отпуск
          if vt[i][4] = null then vt[i][4]:=id_vyh;
          vt[i][7]:=1;
        end
        else if (t1 = -1)or(t2 = -1) then begin
          //нет одного времени - поставим 8.00 и подсветим
          vt[i][4]:=null;
          vt[i][5]:=8;
          vt[i][9]:=1;
          vt[i][7]:=1;
        end
        else if (t1 > -1)and(t2 > -1) then begin
          //время начала рабочего дня возьмем максимальное от фактического или 8:00
          t1:=Max(t1, t3);
          //вычтем обед, если время ухода ранее окончания обеда
          tp:=abs(t2-t1);
//tp:=tp - S.IIf(t2 < tob1, 0, S.VarToFloat(Module.GetCfgVar(mycfgWtime_dinner_1)));
          tp:=Max(0.01, tp - S.IIf(t2 < tob1, 0, S.VarToFloat(Module.GetCfgVar(mycfgWtime_dinner_1))));
          //округляем
          if frac(tp) <= 0.33
            then tp:=trunc(tp)
            else if frac(tp) <= 0.83
            then tp:=trunc(tp) + 0.5
              else tp:=trunc(tp) + 1;
          vt[i][4]:=null;
          vt[i][5]:=tp;
          vt[i][7]:=1;
        end;
      end
      //для цеха
      else begin
        tp:=0;
        //предыдущая запись это прошлый день того же работника, и это ночная или суточная смена, пометим, так как это используется для вычисления времени
        if (i > 0) and (vt[i][1] = vt[i-1][1]) and (DaysBetween(vt[i-1][0], vt[i][0]) = 1) and ((vt[i-1][6] <> null) or (vt[i-1][5] >=20))
          then vt[i-1][11] := 1;
        //setprev:=False;
        if (t1 = -1)and(t2 = -1) then begin
          //нет ни прихода ни ухода - поставим выходной, или оставим код, там мог быть отпуск
          if vt[i][4] = null then vt[i][4]:=id_vyh;
          vt[i][7]:=1;
        end
        //есть приход, но нет ухода с работы, или уход раньше прихоода
        //(это будет если каждые сутки работает в ночную смену)
        else if (t1 > -1)and((t2 = -1)or(t2 < t1)) then begin
          //если это не последняя в выгрузке, и следующая запись на того же работника, и при этом это следующий день
          if (i < High(vt)) and (vt[i][1] = vt[i+1][1]) and (DaysBetween(vt[i+1][0], vt[i][0]) = 1) then begin
            if (vt[i+1][3]<>null)and(vt[i+1][3]<>-1) then begin
              t2:=trunc(vt[i+1][3]) + frac(vt[i+1][3])/60*100;
              t2:=t2 + 24;
              //суточная смена, обед не учитываем, не ставим больше 24 часов
              if (t2 - t1 >= 20)and(t2 - t1 <= 26) then begin
                tp:=Min(24, t2 - t1);
                vt[i][11]:=1;
              end
              //ночная смена, обед учитываем
              else if (t2 - t1 <= 14) then begin
                tp:=max(0.01, t2 - t1 - S.VarToFloat(Module.GetCfgVar(mycfgWtime_dinner_2)));
                t1:=max(t1, 22);
                //посчитаем время работы ночью (с 22ч до 6ч), обед в нее не ставится
                tn:=max(t2 - t1, 0);
                //не может быть больше продолжительности всей смены
                tn:=min(tn, tp);
                //округлим
                if frac(tn) <= 0.33
                  then tn:=trunc(tn)
                  else if frac(tn) <= 0.83
                  then tn:=trunc(tn) + 0.5
                    else tn:=trunc(tn) + 1;
                vt[i][6]:=tn;
                vt[i][11]:=1;
              end
              //не вложились по временам - поставим 8 с выделением
              else tp:=-8;
            end
            else if (vt[i+1][3] = -1) then begin
              //на следующий день ухода не было
              tp:=-8;
            end;
          end  //енд тот же работник завтра
          else tp:= -8;
        end  //енд есть приход а уход раньше или нет ухода
        else if (t1 = -1)and(t2 > -1) then begin
          if not((i > 0)and(vt[i-1][11] = 1))
            then tp:=-8
            else begin
              vt[i][4]:=id_vyh;
              vt[i][7]:=1;
            end;
        end
        else if (t1 > -1)and(t2 > -1) then begin
          //есть и приход и уход
          //время начала рабочего дня возьмем максимальное от фактического или 8:00
          t1:=Max(t1, t3);
          //вычтем обед
          tp:=abs(t2-t1);
          tp:=Max(0.01, tp - S.IIf(t2 < tob2, 0, S.VarToFloat(Module.GetCfgVar(mycfgWtime_dinner_2))));
        end;
        if tp > 0 then begin
          if frac(tp) <= 0.33
            then tp:=trunc(tp)
            else if frac(tp) <= 0.83
            then tp:=trunc(tp) + 0.5
              else tp:=trunc(tp) + 1;
          vt[i][4]:=null;
          vt[i][5]:=tp;
          vt[i][7]:=1;
        end
        else if tp = -8 then begin
          vt[i][4]:=null;
          vt[i][5]:=8;
          vt[i][9]:=1;
          vt[i][7]:=1;
        end;
      end;  //енд цех
    end;
  end;
//ночный и суточный только цеха
//есть сегодня приход, завтра уход
//смены по суткам и ночные только по цеху
//если разница 20-26ч то суточная смена 24ч или меньше, обед не вычитаем (меня за первый день)
//если разница до 14 часов, то смена, ночью у 22 до 6, вычитаем обед
//если не вписывается вэти промежутки то ставим 8ч
//с 8утра (макс 8ч - по парсеку) все, независимо от схемы  Не будет
//округление рабочего времени, и ночной смены до 0.5ч
//подсвечивать несколько входов или выходов, или отсутствие входа и выхода

  //создадим массив, где только измененные данные
  SetLength(vp, 0);
  for i:=0 to High(vt) do begin
    if vt[i][7] = 1 then begin
      SetLength(vp, Length(vp) + 1);
      SetLength(vp[Length(vp)-1], High(vt[i]) + 1);
      for k:=0 to High(vt[i]) do
        vp[Length(vp)-1][k]:=vt[i][k];
    end;
  end;

//  Sys.SaveArray2ToFile(vp, 'r:\111');
//exit;

  //запишем в бд
  Q.QBeginTrans;
  b:=False;
  try
  for i:=0 to High(vp) do begin
//    'select dt, id_worker, begtime, endtime, id_turvcode3, worktime3, nighttime, 0, null, settime3, id_division, 0 from turv_day '+
    Q.QExecSql(
    'update turv_day set begtime = :begtime$f, endtime = :endtime$f, '+
    'id_turvcode2 = :id_turvcode2$i, worktime2 = :worktime2$f, nighttime = :nighttime$f, settime3 = :settime3$i '+
    'where id_worker = :id_worker$i and dt = :dt$d',
    [
      vp[i][2], vp[i][3], vp[i][4], vp[i][5], vp[i][6], vp[i][9],
      vp[i][1], vp[i][0]
    ]
    );
  end;
  b:=True;
  finally
  Q.QCommitOrRollback(b);
  end;
end;

function TTurv.GetArrOfTurvPeriodStrings(ADate: TDateTime; APeriodCount: Integer): TVarDynArray;
var
  CurrentStart, CurrentEnd: TDateTime;
  i: Integer;
  TargetPeriodIndex: Integer;
begin
  Result := [];
  if APeriodCount <= 0 then
    Exit;
  if DayOf(ADate) <= 15 then begin
    CurrentStart := EncodeDate(YearOf(ADate), MonthOf(ADate), 1);
    CurrentEnd := EncodeDate(YearOf(ADate), MonthOf(ADate), 15);
  end
  else begin
    CurrentStart := EncodeDate(YearOf(ADate), MonthOf(ADate), 16);
    CurrentEnd := EndOfTheMonth(ADate);
  end;
  for i := 0 to APeriodCount - 1 do begin
    Result := Result + [FormatDateTime('dd.mm.yyyy', CurrentStart) + ' - ' + FormatDateTime('dd.mm.yyyy', CurrentEnd)];
    if DayOf(CurrentStart) = 1 then begin
      CurrentEnd := IncMonth(CurrentStart, -1);
      CurrentEnd := EndOfTheMonth(CurrentEnd);
      CurrentStart := EncodeDate(YearOf(CurrentEnd), MonthOf(CurrentEnd), 16);
    end
    else begin
      CurrentEnd := EncodeDate(YearOf(CurrentStart), MonthOf(CurrentStart), 15);
      CurrentStart := EncodeDate(YearOf(CurrentStart), MonthOf(CurrentStart), 1);
    end;
  end;
end;

function TTurv.CreateAllPayrollTransfers: Boolean;
var
  dt, dt1, dt2: TDateTime;
  i, j: Integer;
  va1, va2: TVarDynArray2;
  va: TVarDynArray;
  Cnt: Integer;
  Msg: string;
  IdEmpl, IdDep, IdOrg: Variant;
  EmplInfo: TNamedArr;
begin
  if TFrmBasicInput.ShowDialog(Application, '', [], fAdd, '~Создать ведомости', 185, 45, [[cntComboL,'Период','1:400:0', 135]],
    [VarArrayOf([null, VarArrayOf(Turv.GetArrOfTurvPeriodStrings(Date, 5))])], va, [['']], nil) < 0 then
  Exit;
  S.GetDatesFromPeriodString(va[0], dt1, dt2);
{  dt := EncodeDate(2026, 01, 01); //!!!
  dt1 := GetTurvBegDate(dt);
  dt2 := GetTurvEndDate(dt);
  if MyQuestionMessage('Создать ведомости к перечислению за период ' + DateToStr(dt1) + ' - ' + DateToStr(dt2) + '?') <> mrYes then
    Exit;}
  Cnt := 0;
  Msg := '';
  //если есть расчетные ведомости за период по подразделениям, а общая ведомость к перечислению не создана - создадим
  if (Q.QSelectOneRow('select count(id) from w_payroll_calc where id_employee is null and dt1 = :dt1$d', [dt1])[0] <> 0) and
    (Q.QSelectOneRow('select count(id) from w_payroll_transfer where id_employee is null and dt1 = :dt1$d', [dt1])[0] = 0)
    then begin
      if Q.QIUD('i', 'w_payroll_transfer', '', 'id$i;dt1$d;dt2$d', [0, dt1, dt2]) <> -1 then
        inc(Cnt);
    end;
  //ведомости по уволенным работникам - сгруппированы по работнику и периоду работы
  va1 := Q.QLoadToVarDynArray2('select id_employee, id_organization, personnel_number from w_payroll_calc where id_employee is not null and dt1 = :dt1$d group by id_employee, id_organization, personnel_number', [dt1]);
  va2 := Q.QLoadToVarDynArray2('select id_employee, id_organization, personnel_number from w_payroll_transfer where id_employee is not null and dt1 = :dt1$d', [dt1]);
    for i := 0 to High(va1) do begin
      if (A.PosRowInArray(va1, va2, i) = -1) then begin
        //если ведомость еще не создана
        if Q.QIUD('i', 'w_payroll_transfer', '', 'id$i;id_employee$i;id_organization$i;personnel_number$s;dt1$d;dt2$d', [0, va1[i][0], va1[i][1], va1[i][2], dt1, dt2], False) <> -1 then
          inc(Cnt);
      end;
    end;
  //сообщение
  if Cnt = 0 then
    Msg := 'Ни одна ведомость не создана!' + Msg
  else
    Msg := 'Создан' + S.GetEnding(cnt, 'а', 'о', 'о') + ' ' + IntToStr(cnt) + ' ведомост' + S.GetEnding(cnt, 'ь', 'и', 'ей') + '.' ;
  MyInfoMessage(Msg, 1);
  Result := Cnt > 0;
end;

function TTurv.CreateAllPayrollCash: Boolean;
var
  dt, dt1, dt2: TDateTime;
  i, j: Integer;
  va1, va2, va3: TVarDynArray2;
  va: TVarDynArray;
  Cnt: Integer;
  Msg: string;
  IdEmpl, IdDep, IdOrg: Variant;
  EmplInfo: TNamedArr;
begin
  if TFrmBasicInput.ShowDialog(Application, '', [], fAdd, '~Создать ведомости', 185, 45, [[cntComboL,'Период','1:400:0', 135]],
    [VarArrayOf([null, VarArrayOf(Turv.GetArrOfTurvPeriodStrings(Date, 5))])], va, [['']], nil) < 0 then
  Exit;
  S.GetDatesFromPeriodString(va[0], dt1, dt2);
{
  dt := EncodeDate(2026, 01, 01); //!!!
  dt1 := GetTurvBegDate(dt);
  dt2 := GetTurvEndDate(dt);
  if MyQuestionMessage('Создать ведомости к выдаче за период ' + DateToStr(dt1) + ' - ' + DateToStr(dt2) + '?') <> mrYes then
    Exit;                 }
  Cnt := 0;
  Msg := '';
  //по работающим (по подразделениям)
  //создадим ведомости по всем подразделениям, которые есть в расчетных
  va1 := Q.QLoadToVarDynArray2('select id_departament from w_payroll_calc where id_employee is null and dt1 = :dt1$d', [dt1]);
  va2 := Q.QLoadToVarDynArray2('select id_departament from w_payroll_cash where id_employee is null and dt1 = :dt1$d', [dt1]);
  for i := 0 to High(va1) do begin
    if (A.PosRowInArray(va1, va2, i) = -1) then begin
      if Q.QIUD('i', 'w_payroll_cash', '', 'id$i;id_departament;dt1$d;dt2$d', [0, va1[i][0], dt1, dt2], False) <> -1 then
        inc(Cnt);  //увеличим количество созданных
    end;
  end;
  //выберем данные по уволенным
  //строка соответствует периоду работы, подразделение берется на момент увольнения
  va1 := Q.QLoadToVarDynArray2('select id_departament, id_employee, id_organization, personnel_number from w_payroll_calc where id_employee is not null and dt1 = :dt1$d', [dt1]);
  va2 := Q.QLoadToVarDynArray2('select id_departament, id_employee, id_organization, personnel_number from w_payroll_cash where dt1 = :dt1$d', [dt1]);
  va3 := Q.QLoadToVarDynArray2('select id_departament, id_employee, id_organization, personnel_number from w_employee_properties where is_terminated = 1 and dt_beg >= :dt1$d and dt_beg <= :dt2$d', [dt1,  Turv.GetTurvEndDate(IncDay(dt2, 1))]);
  for i := 0 to High(va1) do begin
    if (A.PosRowInArray(va1, va2, i) = -1) and (A.PosRowInArray(va1, va3, i) > -1) then begin
      //если ведомость еще не создана, и с такими параметрами есть в списке уволенных за периода
      //(таким образом исключаем ведомости с промежуточными подразделениями, т.е. если бли переходы по ним в течении периода работы, то будет создана только ведомость с подразделением на момент увольнения)
      if Q.QIUD('i', 'w_payroll_cash', '', 'id$i;id_departament;id_employee$i;id_organization$i;personnel_number$s;dt1$d;dt2$d', [0, va1[i][0], va1[i][1], va1[i][2], va1[i][3], dt1, dt2], False) <> -1 then
        inc(Cnt);  //увеличим количество созданных
    end;
  end;
  //сообщение
  if Cnt = 0 then
    Msg := 'Ни одна ведомость не создана!' + Msg
  else
    Msg := 'Создан' + S.GetEnding(cnt, 'а', 'о', 'о') + ' ' + IntToStr(cnt) + ' ведомост' + S.GetEnding(cnt, 'ь', 'и', 'ей') + '.' ;
  MyInfoMessage(Msg, 1);
  Result := Cnt > 0;
end;

procedure TTurv.LoadDataFromParsec;
var
  LTurv: TTurvData;
  Ids: TVarDynArray;
  i: Integer;
begin
  Ids := Q.QLoadToVarDynArrayOneCol('select id from w_turv_period where is_finalized = 0 and dt1 = :dt1$d', [GetTurvBegDate(IncDay(GetTurvBegDate(Date), -1))]);
  Ids := Ids + Q.QLoadToVarDynArrayOneCol('select id from w_turv_period where is_finalized = 0 and dt1 = :dt1$d', [GetTurvBegDate(Date)]);
  for i := 0 to High(Ids) do begin
    LTurv.Create(Ids[i], '', '');
//    try
    LTurv.LoadFromParsec;
//    except
//    end;
    LTurv := Default(TTurvData);
  end;
end;


procedure TTurv.ConvertEmployees202511;
var
  i, j, k, e: Integer;
  w ,sh : TVarDynArray2;
  es: TNamedArr;
  b1, b2, b3 : Boolean;
begin
Exit;
  if MyQuestionMessage('Импортировать данные?') <> mrYes then
    Exit;
  Q.QBeginTrans(True);
  Q.QExecSql('delete from w_turv_day', []);
  Q.QExecSql('delete from w_employee_properties', []);
  Q.QExecSql('delete from w_departaments', []);
  Q.QExecSql('delete from w_employees', []);
  Q.QExecSql('delete from w_jobs', []);
  Q.QExecSql('delete from w_schedule_hours', []);
  Q.QExecSql('delete from w_schedules', []);
  Q.QExecSql('insert into w_jobs (id, name, active) select id,name,active from ref_jobs', []);
  Q.QExecSql('delete from w_turvcodes', []);
  Q.QExecSql('insert into w_turvcodes (id, code, name, active) select id,code, name, 1 from ref_turvcodes', []);
  Q.QExecSql('insert into w_employees(id,f,i,o,is_concurrent) select id, f,i,o,concurrent_employee from ref_workers', []);
  Q.QExecSql('insert into w_departaments (id,code,name,id_head,id_prod_area,is_office,ids_editusers,active) select id,code,name,id_head,id_prod_area,office,editusers,active from ref_divisions', []);
  Q.QExecSql('insert into w_schedules(id,code,name,active) select id, code, name, active from ref_work_schedules', []);
  //Q.QExecSql('insert into w_schedule_hours(id,id_schedule,dt,hours) select id,id_work_schedule,dt,hours from ref_working_hours', []);
  Q.QExecSql('delete from w_turv_period', []);
  Q.QExecSql('insert into w_turv_period (id, id_departament, dt1, dt2, is_finalized, status) select id, id_division, dt1, dt2, commit, status from turv_period', []);
  Q.QExecSql('insert into w_employee_properties(id, dt, id_employee, id_job, id_departament, is_hired, is_terminated, dt_beg) '+
    'select id, dt, id_worker, id_job, id_division, decode(status, 1, 1, 0), decode(status ,3 , 1, 0), dt from j_worker_status', []
  );
  //увольнения ранее делались на день позже, тк неправильно была релализована логика (день увольнения д.б. последним рабочим)
  Q.QExecSql('update w_employee_properties set dt_beg = dt_beg - 1 where is_terminated = 1',[]);
  Q.QloadFromQuery('select 0 as f, id, id_employee, id_job, id_departament, is_hired, is_terminated, dt_beg, dt_end, personnel_number, id_organization, is_concurrent, id_schedule from w_employee_properties order by id_employee, id desc', [], es);
  w := Q.QloadToVarDynArray2('select  id, personnel_number, id_organization, concurrent_employee from ref_workers', []);
  sh := Q.QloadToVarDynArray2('select * from (select id_worker, id_schedule_active, dt1, row_number() over (partition by id_worker order by id desc) as rn from v_turv_workers) where rn = 1' ,[]);
  Q.QExecSql('insert into w_turv_day (dt, id_employee, '+
    'id_turvcode1, worktime1, comm1, id_turvcode2, worktime2, comm2, id_turvcode3, worktime3, comm3, premium, premium_comm, penalty, penalty_comm, production, begtime, endtime, nighttime, settime3) '+
    'select dt, id_worker, id_turvcode1, worktime1, comm1, id_turvcode2, worktime2, comm2, id_turvcode3, worktime3, comm3, premium, premium_comm, penalty, penalty_comm, production, begtime, endtime, nighttime, settime3 '+
    'from turv_day', []
  );
//Exit;
  //графики из v_turv_workers
  e := 0;
//  0 = 5  1 = 4...
  for i := 0 to es.Count - 1 do begin
    if es.G(i, 'id_employee') <> e then begin
      e := es.G(i, 'id_employee');
      b1 := True;
    end;
    //if e <> 1 then Continue;
    j := A.PosInArray(e, w, 0);
    if (j >= 0) and b1 then begin
      es.SetValue(i, 'f', 1);
      es.SetValue(i, 'id_organization', w[j][2]);
      es.SetValue(i, 'personnel_number', w[j][1]);
//      es.SetValue(i, 'is_concurrent', w[j][3]); //!!!
      es.SetValue(i, 'is_concurrent', 0);
    end;
    k := A.PosInArray(e, sh, 0);
    if (k >= 0) and b1 then begin
      es.SetValue(i, 'f', 1);
      es.SetValue(i, 'id_schedule', sh[k][1]);
    end;
    if b1 and es.G(i, 'is_hired') = 1 then
      b1 := False;

    //данные из статуса Увольнение из более ранней строки
    if (i < es.Count - 1) and (es.G(i, 'is_terminated') = 1) and (e = es.G(i + 1, 'id_employee').AsInteger) then begin
      es.SetValue(i, 'f', 1);
      es.SetValue(i, 'id_job', es.G(i + 1, 'id_job'));
      es.SetValue(i, 'id_departament', es.G(i + 1, 'id_departament'));
    end;
    //дата завершения статуса = дата начала следующего, из следующей строки - 1 (если следующий = увольнение, то равно ему!)
    if (i > 0) and (es.G(i, 'is_terminated') <> 1) and (e = es.G(i - 1, 'id_employee').AsInteger) then begin
      es.SetValue(i, 'f', 1);
      if es.G(i - 1, 'is_terminated') <> 1 then
        es.SetValue(i, 'dt_end', IncDay(es.G(i - 1, 'dt_beg'), - 1)) else es.SetValue(i, 'dt_end', es.G(i - 1, 'dt_beg'));
    end;
  end;
  for i := 0 to es.Count - 1 do
    if es.G(i, 'f') = 1 then
      Q.QIUD('u', 'w_employee_properties', '', 'id$i;id_employee$i;id_job$i;id_departament$i;is_hired$i;is_terminated$i;dt_beg$d;dt_end$d;personnel_number$s;id_organization$i;is_concurrent$i;id_schedule$i',[
        es.G(i, 'id'), es.G(i, 'id_employee'), es.G(i, 'id_job'), es.G(i, 'id_departament'), es.G(i, 'is_hired'), es.G(i, 'is_terminated'), es.G(i, 'dt_beg'),
        es.G(i, 'dt_end'), es.G(i, 'personnel_number'), es.G(i, 'id_organization'), es.G(i, 'is_concurrent'), es.G(i, 'id_schedule')
      ]);
  Q.QExecSql('update w_turv_day d set id_employee_properties = (select id from w_employee_properties p where p.is_terminated <> 1 and d.id_employee = p.id_employee and d.dt >= p.dt_beg and d.dt <= nvl(p.dt_end, TO_DATE(''15.11.2027'', ''DD.MM.YYYY'')))', []);
  // select workername, id_worker, id_schedule_active from v_turv_workers where dt1 = date '2026-01-01';
  Q.QExecSql('update w_employee_properties p set id_schedule = (select max(id_schedule_active) from v_turv_workers w where w.dt1 = date ''2026-01-01'' and w.id_worker = p.id_employee)', []);
  Q.QCommitOrRollback(True);
end;




begin
  Turv:=TTurv.Create;
end.



