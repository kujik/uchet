{

Модуль, обеспечивающий выполнение фоновых задач.

Программа Сервер в этом режиме запускается по планировщику заданий, с
передачей в параметре наименования задачи, которую нужно выполнить.
Управление передается процедуре TasksS.Run, которая выполняет необходимые
задачи и после выполнения завершаает программу.
В случае ошибок в обработчике предусмотрено закрытие программы без вывода
диалога с ожиданием.

для каждой задачи имеется параметр командной строки, который и определяет тип задачи, при старте "сервер.exe /задача"
в тот же момент выполняеся данная задача, после чего происходит выход из программы
несколько задач одновременно в одном экземпляре программы - не могут быть выполнены

приложение Сервер не стартует, если ему не передан параметр (и только один параметр)
в случае запуска из дельфи, будет еще вопрос для подтверждения выполнения задачи (чтобы не выполнилась случайно)

в случае ошибки во время выполнения задачи, выдается окно ошибки, и через 3 минуты программа закроется

на данный момент для создания расписания задач нужно использовать планировщик виндовс, где запускается приложение Сервер с параметром
как правило, устанавливаем время старта задачи в расписании ежедневно
если надо повторять в течении дня (как загрузка парсек), то ставим в нижней части повтор в течении напр 12ч, с интервалом в час.

/fromparsec
ежедневно в 8:10, повтор ежечасно, в течении 12ч
/turvreport
две задачи, ежедневно в 8ч и в 15ч (задача сама определяем когда надо сделать рассылку, с учетом выходных дней)


----------------
В этом же модуле находятся и сами выполняемые сервером задания.

}



unit uServerTasks;

interface

uses
 Graphics, Classes, DateUtils, Variants, SysUtils, Types, Windows, uNamedArr, uString, uTasks
 ;

type
  TTasksS = record
  private
  public
    //процедура выполняется при старте модуля Сервер
    //выполняет задачу в соответствии с переданным параметром
    procedure Run;
    //вополняет задачи раз в час
    //сейчас здесь же прописываю выполнение ежедневных задач в жестко заданное время
    procedure HourlyTasks;

    //удаление устаревших данных
    procedure DeleteOldData;
    //получение из интернета производственного календаря
    function  GetProductionCalendar(Year: Variant): Integer;
    //посчитаем количество по сметным позициям плановых заказов для отчета и для снабжения
    procedure CalcPlannedOrders;
    //закроем период в итм с конца предыдущего до прошедшего воскресенья включительно
    procedure CloseItmWorkPeriod;
    //устанавливает в таблице заказов проиизводственные статусы и данные, взятые из ИТМ
    //(является ли заказ производственныым, дата выдачи в производство, количество плитных и кромочных материалов по смете в изделиях заказа)
    procedure SetProdustionDataForOrders;
    //отчет по заказам, по кторым не созданы сметы
    procedure ReportForOrdersWithoutEstimate;
    //ежечасный мониторинг сделаок по снабжению
    //регистрирует позиции по счетам, цена по которым была выше контрольной
    function  ReportForHorlySupplyDeals: Integer;
    //мониторинг счетов снабжения за вчерашний день, а также наличия приходных накладных без оснований
    procedure ReportForYesterdaySupplyDeals;
    //финансовый отчет по производственным или отгрузочным заказам, запущенным за вчерашний день
    //1'Отчет по производственным заказам за вчерашний день',
    //2'Отчет по производственным заказам в работе',
    //3'Отчет по отгрузочным заказам за вчерашний день',
    //4'Отчет по отгрузочным заказам в работе'
    //5'Отчет по производственным заказам за прошедшую неделю'
    //6'Отчет по производственным заказам за прошешеший месяц'
    procedure ReportForYesterdayOrders(AOrderTypes: Integer; AMailing: Boolean = True);
    //отчет по созданным в ИТМ АВР, по которым по заказу не было полного поринятия на сгп в Учете
    procedure ReportForEarlyCompletionActs;
    //отчет по сырью, находящемуся в пути при отсуствии резерва на него
    procedure ReportForSupplyisOnwaySurplus;
    //отчет по материалам на   складах готовой продукции, являющихся сырьем а не изделиями
    procedure ReportForRawMaterialsOnSgp;
    //информация по актам списания и оприходования за вчерашний день
    procedure ReportForActsWriteoffReceipt;
  end;

var
  TasksS: TTasksS;


implementation

uses
  ZLib,
  uDBOra,
  uData,
  uSys,
  uTurv,
  uMessages,
  uFrmMain,
  Dialogs,
  XmlDoc,
  Xml.XMLIntf,
  uHtmlUtils,
  uExportToXlsx,
  uFrDBGridEh,
  DBGridEh,
  uOrders
  ;

procedure TTasksS.Run;
//процедура выполняется при старте модуля Сервер
//выполняет задачу в соответствии с переданным параметром
var
  IsIscorrectTask: Boolean;
  HasError: Boolean;
begin
  repeat
    IsIscorrectTask := False;
    HasError := True;
    try
      if ParamStr(1) = '/turvreport1' then begin
        IsIscorrectTask := True;
      //if DayOf(Date) in [1, 16] then TestTurvComplete;
      end;
      if ParamStr(1) = '/turvreport2' then begin
        IsIscorrectTask := True;
      //RunTestTurvDifferences;
      end;
      if ParamStr(1) = '/fromparsec' then begin
        IsIscorrectTask := True;
        TURV.LoadParsecData;
      end;
      if ParamStr(1) = '/ReportForOrdersWithoutEstimate' then begin
        IsIscorrectTask := True;
        ReportForOrdersWithoutEstimate;
      end;
      if ParamStr(1) = '/deleteolddata' then begin
        IsIscorrectTask := True;
        DeleteOldData;
      end;
      if ParamStr(1) = '/getcalendar' then begin
        IsIscorrectTask := True;
        GetProductionCalendar(YearOf(Date));
        GetProductionCalendar(YearOf(Date) + 1);
      end;
      if ParamStr(1) = '/calcplanned' then begin
        IsIscorrectTask := True;
        CalcPlannedOrders;
      end;
      if ParamStr(1) = '/CloseItmWorkPeriod' then begin
        IsIscorrectTask := True;
        CloseItmWorkPeriod
      end;
      if ParamStr(1) = '/hourly' then begin
        IsIscorrectTask := True;
        HourlyTasks;
      end;
      if ParamStr(1) = '/test' then begin
        IsIscorrectTask := True;
      end;
      HasError := False;
    finally
      //на всякий случай откатим транзакцию, если была незафиксированная
      Q.QRollbackTrans;
    end;
    //запишем в лог
    if IsIscorrectTask then
      Module.ToLogFile(ParamStr(1) + S.IIf(HasError, ' [Ошибка!]', ''));
  until True;
  //завершает приложение
  FrmMain.Close;
end;

procedure TTasksS.HourlyTasks;
//вополняет задачи раз в час
//сейчас здесь же прописываю выполнение ежедневных задач в жестко заданное время
begin
  //задачи, выполняющиеся каждый час
  CalcPlannedOrders;
  SetProdustionDataForOrders;
  ReportForHorlySupplyDeals;
  Turv.LoadDataFromParsec;
  Turv.SaveAllTurvToExportTable;
  Turv.ExtendPersBonuses;
  //задачи, выполняющиеся в начале рабочего дня
  if HourOf(Now) = 8 then begin
    ReportForYesterdaySupplyDeals;
    ReportForYesterdayOrders(1);
    ReportForYesterdayOrders(3);
    ReportForEarlyCompletionActs;
    ReportForSupplyisOnwaySurplus;
    ReportForRawMaterialsOnSgp;
    ReportForActsWriteoffReceipt;
    //задачи по понедельникам
    if DayOfWeek(Date) = 1 then begin
      ReportForYesterdayOrders(5);
      ReportForYesterdayOrders(7);
    end;
    //задачи первого числа месяца
    if DayOf(Date) = 1 then begin
      ReportForYesterdayOrders(6);
      ReportForYesterdayOrders(8);
    end;
  end;
end;

procedure TTasksS.DeleteOldData;
//автоматическое удаление старых данных
var
  i, j: Integer;
  vtimes: TVarDynArray;
  va1, va2, va3: TVarDynArray2;
  va: TVarDynArray;
  body: string;
  dt1, dt2: TDateTime;
  ok: Boolean;
begin
  //времена удаления, перые в днях, а турв и зп в периодах 2 недели
  vtimes := Q.QLoadRow('select or_to_archive, orders_n, accounts_n, turv, payrolls from adm_delete_old', []);
  if S.NNum(vtimes[0]) >= 10 then begin
    //перенесем в архив заказы, которые завершены ранее /2 недель/ назад, и еще не в архиве
    dt1 := IncDay(Date, -vtimes[0]);
    va1 := Q.QLoad('select id, path, dt_beg, dt_end from v_orders where nvl(in_archive, 0) <> 1 and dt_end is not null and dt_end < :dt1$d', [dt1]);
    for i := 0 to High(va1) do begin
      dt1 := EncodeDate(YearOf(va1[i][3]), MonthOf(va1[i][3]), DayOf(va1[i][3]));
      Q.QExecSql('update orders set in_archive = 1 where id = :id$i', [va1[i][0]]);
      Tasks.CreateTaskRoot(mytskopMoveToArchive, [['directory', va1[i][1]], ['in_archive', 0], ['year', YearOf(va1[i][2])]]);
    end;
  end;
  ///удаение счетов за наличный расчет
  if S.NNum(vtimes[2]) >= 10 then begin
    //удаляем счета за наличный расчет
    //счет должен быть полностью оплачен и последняя дата платежа должна быть раньше целевой даты и даты ревизии кассы
    dt1 := IncDay(Date, -vtimes[2]);
    va1 := Q.QLoad('select id, filename, type, maxdtpaid, dt from v_sn_calendar_accounts where ' + 'type <> 1 and paimentstatus = ''полностью'' and maxdtpaid < :dt1$d and ' + 'maxdtpaid < (select dt from sn_cash_revision_dt) order by maxdtpaid asc', [dt1]);
//    Sys.SaveArray2ToFile(va1,'r:\2');
    for i := 00000 to High(va1) do begin
      Q.QBeginTrans(True);
      ok := False;
      repeat
        if Q.QExecSql('update sn_calendar_t_basis set id_acc = null where id_acc = :id$i', [va1[i][0]]) < 0 then
          Break;
        if Q.QExecSql('delete from sn_calendar_accounts where id = :id$i', [va1[i][0]]) < 0 then
          Break;
        ok := True;
      until True;
      if ok then begin
        Q.QCommitTrans;
        Tasks.CreateTaskRoot(mytskopDeleteAllFromAccounts, [['directory', va1[i][1]]]);
      end
      else
        Q.QRollbackTrans;
    end;
  end;
  //удаление ТУРВ старше Х периодов
  //при Х=1 удаляется ТУРВ, предшествующий текущему
{  if S.NNum(vtimes[3]) >= 3 then begin
    dt1 := TURV.GetTurvBegDate(Date);
    for i := 1 to vtimes[3] do begin
      dt1 := TURV.GetTurvBegDate(IncDay(dt1, -1));
    end;
    dt2 := dt1;
    Q.QExecSql('delete from turv_period where dt1 <= :dt1$d', [dt1]);
  end;
  //удаление платежных ведомостей старше Х периодов
  if S.NNum(vtimes[4]) >= 3 then begin
    dt1 := TURV.GetTurvBegDate(Date);
    for i := 1 to vtimes[4] do begin
      dt1 := TURV.GetTurvBegDate(IncDay(dt1, -1));
    end;
    Q.QExecSql('delete from payroll where dt1 <= :dt1$d', [dt1]);
  end;}
end;

{------------------------------------------------------------------------------}
{                                  ЗАДАЧИ                                      }
{------------------------------------------------------------------------------}


function TTasksS.GetProductionCalendar(Year: Variant): Integer;
//получение из интернета производственного календаря
var
  i,j,k:Integer;
  st: string;

  FileStream: TFileStream;
  DecompressionStream: TDecompressionStream;
  Strings: TStringList;
  MS:TMemoryStream;
//  XMLDocument:TXMLDocument;
  RootNode: IXMLNode;
  a1: TVarDynArray;
  a2, a3: TVarDynArray2;
  b: Boolean;
begin
(*
<!--
year    - год на который сформирован календарь
lang    - двухбуквенный код языка на котором представлены названия праздников
date    - дата формирования xml-календаря в формате ГГГГ.ММ.ДД
country - двухбуквенный код страны
-->
<calendar year="2014" lang="ru" date="2014.01.01" country="ru">
  <!--
    holidays - Список праздников
    id - идентификатор праздника
    title - название праздника
  -->
  <holidays>
    <holiday id="1" title="Новогодние каникулы" />
    <holiday id="2" title="Рождество Христово" />
    <holiday id="3" title="День защитника Отечества" />
    <holiday id="4" title="Международный женский день" />
    <holiday id="5" title="Праздник Весны и Труда" />
    <holiday id="6" title="День Победы" />
    <holiday id="7" title="День России" />
    <holiday id="8" title="День народного единства" />
  </holidays>
  <!--
    days - праздники/короткие дни/рабочие дни (суббота либо воскресенье)
    d (day) - день (формат ММ.ДД)
    t (type) - тип дня: 1 - выходной день, 2 - рабочий и сокращенный (может быть использован для любого дня недели), 3 - рабочий день (суббота/воскресенье)
    h (holiday) - номер праздника (ссылка на атрибут id тэга holiday)
    f (from) - дата с которой был перенесен выходной день
    суббота и воскресенье считаются выходными, если нет тегов day с атрибутом t=2 и t=3 за этот день
  -->
  <days>
    <day d="01.01" t="1" h="1" />
    <day d="01.02" t="1" h="1" />
    <day d="01.03" t="1" h="1" />
    <day d="02.22" t="1" f="01.03" />
    ...
  </days>
</calendar>
*)
  Result:=-1;
  repeat
  try
  if not Sys.LoadFileFromWWW('http://xmlcalendar.ru/data/ru/' + VarToStr(Year) + '/calendar.xml.gz', Sys.GetWinTemp+'\calendar.xml.gz') then break;
  FileStream := TFileStream.Create(Sys.GetWinTemp+'\calendar.xml.gz', fmOpenRead);
{   windowBits can also be greater than 15 for optional gzip decoding.  Add
   32 to windowBits to enable zlib and gzip decoding with automatic header
   detection, or add 16 to S.Decode only the gzip format (the zlib format will
   return a Z_DATA_ERROR).}
  DecompressionStream := TDecompressionStream.Create(FileStream, 15 + 16);  // 31 bit wide window = gzip only mode
  Strings := TStringList.Create;
  Strings.LoadFromStream(DecompressionStream);
  Strings.Text:=UTF8Decode(Strings.Text);
//  ShowMessage(Strings.Text);

  MyData.XMLDocument.LoadFromXML(Strings.Text);
  MyData.XMLDocument.Active := True;

  st:=MyData.XMLDocument.DocumentElement.ChildNodes['holidays'].ChildNodes[1].xml;//ChildNodes['holideys'].XML;

  a1:=[''];
  for i:=0 to MyData.XMLDocument.DocumentElement.ChildNodes['holidays'].ChildNodes.Count - 1 do begin
    j:=StrToInt(MyData.XMLDocument.DocumentElement.ChildNodes['holidays'].ChildNodes[i].Attributes['id']);
    if j > High(a1) then SetLength(a1, j+1);
    a1[j]:=S.NSt(MyData.XMLDocument.DocumentElement.ChildNodes['holidays'].ChildNodes[i].Attributes['title']);
  end;

  SetLength(a2, MyData.XMLDocument.DocumentElement.ChildNodes['days'].ChildNodes.Count);
  for i:=0 to MyData.XMLDocument.DocumentElement.ChildNodes['days'].ChildNodes.Count - 1 do begin
    st:=MyData.XMLDocument.DocumentElement.ChildNodes['days'].ChildNodes[i].Attributes['d'];
    a2[i]:=[
      EncodeDate(S.VarToInt(Year), StrToInt(Copy(st,1,2)), StrToInt(Copy(st,4,2))),
      StrToInt(MyData.XMLDocument.DocumentElement.ChildNodes['days'].ChildNodes[i].Attributes['t']),
      a1[StrToIntDef(S.NSt(MyData.XMLDocument.DocumentElement.ChildNodes['days'].ChildNodes[i].Attributes['h']), 0)]
    ]
  end;

//  text;//ChildNodes['holideys1'].text;//ChildNodes[1].Text;
//  ShowMessage(st);
  if Length(a2) > 0 then begin
    a3:=Q.QLoad('select dt, type, descr from ref_holidays where extract(year from dt) = :year order by dt', [S.VarToInt(Year)]);
    b:=Length(a2) <> Length(a3);
    if not b then
      for i:=0 to High(a2) do
        if (a2[i][0] <> a3[i][0])or(a2[i][1] <> a3[i][1])or(a2[i][2] <> S.NSt(a3[i][2]))
          then begin b:=True; Break end;
    if b then begin
      Q.QExecSql('delete from ref_holidays where extract(year from dt) = :year', [S.VarToInt(Year)]);
      for i:=0 to High(a2) do
        Q.QExecSql('insert into ref_holidays (dt, type, descr) values (:dt$d, :type$i, :descr$t)', [a2[i][0], a2[i][1], Copy(a2[i][2], 1, 200)]);
      Result:=1;
    end
    else Result:=0;
    Break;
  end;
  except
    Break;
  end;
  until False;
//  XMLDocument.Free;
  DecompressionStream.Free;
  FileStream.Free;
  Strings.Free;
end;

procedure TTasksS.CalcPlannedOrders;
//посчитаем количество по сметным позициям плановых заказов для отчета и для снабжения
begin
  Orders.CrealeEstimateOnPlannesOrders(Date, False);
  Orders.CrealeEstimateOnPlannesOrders(Date, True);
end;

procedure TTasksS.CloseItmWorkPeriod;
//закроем период в итм с конца предыдущего до прошедшего воскресенья включительно
var
  i, j: Integer;
  va2: TVarDynArray2;
  dt1, dt2: TDateTime;
function GetLastSunday(AValue: TDateTime): TDateTime;
var
  Day: Integer;
begin
  Day := DayOfTheWeek(AValue);
  if Day = 7
    then Result := AValue - 7
    else Result := AValue - (Day);
end;
begin
  //закрытие периода - получить максимальну дапту окончания, прибавить день, в качестве начальной
  //неделю назад в качестве конечной
  //вставить строку в таблицу, айди из последовательности
  //sq_closed_period_id
  va2 := Q.QLoad('select max(end_date) from dv.closed_period', []);
  if Length(va2) = 0
    then dt1 := IncMonth(Date, -1)
    else dt1 := IncDay(VarToDateTime(va2[0][0]), 1);
  dt2 := GetLastSunday(Date);
  if dt1 >= dt2 then
    Exit;
  Q.QSave('i', 'dv.closed_period', 'dv.sq_closed_period_id', 'id_closed_period$i;period_name$s;start_date$d;end_date$d;is_closed$i',
    [-1, 'Новый период', dt1, dt2, 1]
  );
end;

procedure TTasksS.SetProdustionDataForOrders;
//устанавливает в таблице заказов проиизводственные статусы и данные, взятые из ИТМ
//(является ли заказ производственныым, дата выдачи в производство, количество плитных и кромочных материалов по смете в изделиях заказа)
begin
  Q.QBeginTrans(True);
  Q.QCallStoredProc('P_SetOrdersProdData', '', []);
  Q.QCommitOrRollback(True);
end;

procedure TTasksS.ReportForOrdersWithoutEstimate;
//отчет по заказам, по кторым не созданы сметы
var
  i, j: Integer;
  va: TVarDynArray2;
  va1: TVarDynArray;
  body: string;
  addr: string;
begin
  va := Q.QLoad('select org || '' '' || num as ordernum, project, customer, dt_beg, dt_otgr, constructor ' + 'from uchet.v_to_orders_list_current2 where (dt_smeta is null) and (dt_end is null) order by ordernum', []);
  if High(va) < 0 then
    Exit;
  SetLength(va1, Length(va[0]));
  for i := 0 to High(va) do begin
    for j := 0 to High(va[i]) do
      if S.NNum(va1[j]) < Length(S.NSt(va[i][j])) then
        va1[j] := Length(S.NSt(va[i][j]));
  end;
  body := 'Незавершенные заказы, по которым еще не была отправлена смета:'#13#10#13#10;
  for i := 0 to High(va) do begin
    for j := 0 to High(va[i]) do
      S.ConcatStP(body, Copy(VarToStr(va[i][j]) + '       ', 1, S.VarToInt(va1[j]) + 3), ' ');
    S.ConcatStP(body, #13#10);
  end;
  S.ConcatStP(body, #13#10);
  Tasks.SendMail(TASK_MAILING_NO_ESTIMATE, 'Заказы в работе, по которым не созданы сметы', body, [], '~', False);
end;

function TTasksS.ReportForHorlySupplyDeals: Integer;
//ежечасный мониторинг сделаок по снабжению
//регистрирует позиции по счетам, цена по которым была выше контрольной
var
  Fields: TVarDynArray2;
  i,j: Integer;
  IdSch, IdSchN, IdIb, IdIbN: Integer;
  na: TNamedArr;
  st, css: string;
  FileToSend: string;
  Tbl: THTMLTable;
  HTML, Title: string;
begin
  Title := 'За последний час были выставлены счета по завышенным ценам!';
  Fields := [
    ['name$s', 'Наименование', '500;h'],
    ['price$f', 'Цена', '80', 'r'],
    ['price_check$f', 'Контрольная цена', '80', 'r'],
    ['name_unit$s', 'Ед. изм.', '80', 'r'],
    ['qnt$f', 'Кол-во', '80', 'r'],
    ['sum$f', 'Сумма по счету', '80', 'f=#:', 's', 'r'],
    ['sum_diff$f', 'Разница с контрольной','80', 'f=#:', 's', 'r'],
    ['num_w_dt$s', 'Счет', '150;h']
  ];
  //получим список номенкклатуры из еще не обработанных этим скриптом счетов, по которой есть превышение закупочной цены над кеонтрольной
  try
    Q.QBeginTrans(True);
    IdSch := S.IfNotEmpty(Q.QLoadValue('select i from properties where prop = ''spl_monitoring_prices'' and subprop = ''id_schet_mon''', []), 36327);
    Q.QLoad(Q.QGetSql('A', 'v_prices_from_sp_schet', Fields.Col(0).Implode(';')) + ' where monitor_price = 1 and id_schet > :id$i order by name asc', [IdSch], na);
    IdSchN := Q.QLoadValue('select max(id_schet) from dv.sp_schet', []);
    //сохраним айди обработанного счета
    Q.QCallStoredProc('p_SetProp', 'p$s;sp$s;st$s;dt$d;i$i;f$f', ['spl_monitoring_prices', 'id_schet_mon', '', null, IdSchN, null]);
    if na.Count > 0 then begin
      Tbl.InitDefaults;
      Tbl.SetOptions('report-table', '—', True, '0.00', 'dd.mm.yyyy', 'dd.mm.yyyy hh:nn:ss', True, True);
      HTML := '<b>По следующей номенклатуре были выставлены счета, в которых цена номенклатуры превышает контрольную цену:</b><br>' + Tbl.GenerateEmail(na, Fields, 1, 2, 0);
      Tasks.SendMail(TASK_MAILING_MONITORING_SN, Title, HTML, [], '~');
    end;
    //сохраним в таблице информцию по номенклатуре и ПН из еще не обработанных приходных накладных, где округленные до рубля закупочная и контрольная цена различаются
    IdIb := S.IfNotEmpty(Q.QLoadValue('select i from properties where prop = ''spl_deals_monitoring'' and subprop = ''id_inbill''', []), 113205);
    Q.QExecSql(
      'insert into spl_deals_monitoring '+
        '(dt, id_nomencl, id_inbill, price_check) '+
        '(select trunc(sysdate), id_nomencl, id_inbill, price_check '+
          'from v_spl_deals_monitoring_get '+
          'where id_inbill > :id$i'+
        ')',
      [IdIb]
    );
    //обновим контрольную цену, если найдена в накладных, старше айди из properties, цена меньше контрольной
    Q.QExecSql('update spl_itm_nom_props t set price_check = nvl((select price_new from v_spl_prices_check_get g where g.id_nomencl = t.id), t.price_check)', []);
    //получим и сохраним айди последней накладной
    IdIbN := Q.QLoadValue('select max(id_inbill) from dv.in_bill', []);
    Q.QCallStoredProc('p_SetProp', 'p$s;sp$s;st$s;dt$d;i$i;f$f', ['spl_deals_monitoring', 'id_inbill', '', null, IdSchN, null]);
  except
    Q.QRollbackTrans;
  end;
    Q.QCommitTrans;
end;

procedure ReportForYesterdaySupplyDealsXlsxFormatter(var Fr: TFrDBGridEh; FieldName: string; Params: TColCellParamsEh);
//мониторинг счетов снабжения за вчерашний день, callback для форматирования файла эксель
begin
  if (FieldName = 'sum_diff') and (Fr.GetValueF('sum_diff') > 0) then
    Params.Font.Color := clRed;
end;

function ReportForYesterdaySupplyDealsTblFormatter(ARow, ACol: Integer; const AValue: Variant; const AFormattedValue: string): string;
//мониторинг счетов снабжения за вчерашний день, callback для форматирования таблицы
begin
  //выделим жирным 'sum_diff'
  if (ACol = 6) and (AValue.AsFloat > 0) then
    Result := '<b>' + AFormattedValue + '</b>'
  else
    Result := AFormattedValue;
end;

procedure TTasksS.ReportForYesterdaySupplyDeals;
//мониторинг счетов снабжения за вчерашний день, а также наличия приходных накладных без оснований
var
  i,j: Integer;
  na: TNamedArr;
  va: TVarDynArray;
  Summ: Extended;
  Fields: TVarDynArray2;
  FileToSend: string;
  Tbl: THTMLTable;
  HTML, Title: string;
  TopSt: string;
begin
  Title := 'Счета снабжения за вчерашний день';
  TopSt := 'Счета снабжения за ' + DateTimeToStr(IncDay(Date, -1));
  Fields := [
    ['name$s', 'Наименование', '500;h'],
    ['price$f', 'Цена', '80', 'r'],
    ['price_check$f', 'Контрольная цена', '80', 'r'],
    ['name_unit$s', 'Ед. изм.', '80', 'r'],
    ['qnt$f', 'Кол-во', '80', 'r'],
    ['sum$f', 'Сумма по счету', '80', 'f=#:', 's', 'r'],
    ['sum_diff$f', 'Разница с контрольной','80', 'f=#:', 's', 'r'],
    ['num_w_dt$s', 'Счет', '150;h']
  ];
  Q.QLoad(Q.QGetSql('A', 'v_prices_from_sp_schet_day', Fields.Col(0).Implode(';')) + ' /*where monitor_price = 1*/ order by name asc', [], na);
  va := Q.QLoadCol('select to_char(inbillnum) from dv.in_bill where docstr is null and inbilldate >= trunc(sysdate) - 1 and inbilldate < trunc(sysdate)', []);
  HTML := '';
  if na.Count > 0 then begin
    Summ := na.Sum('sum_diff');
    Tbl.InitDefaults;
    Tbl.SetOptions('report-table', '—', True, '0.00', 'dd.mm.yyyy', 'dd.mm.yyyy hh:nn:ss', True, True);
    HTML := '<b>Номенклатура по счетам за вчерашний день:</b><br>' + Tbl.GenerateEmail(na, Fields, 1, 2, 0, ReportForYesterdaySupplyDealsTblFormatter) + '<br>' + 'Всего по счетам: <b>' + FloatToStr(Round(Summ)) + 'р.</b>';
    FileToSend := Sys.GetWinTemp + '\' + TopSt + '.xlsx';
    ExportToXlsx(FileToSend, na, Fields, TopSt, '', True, ReportForYesterdaySupplyDealsXlsxFormatter);
  end
  else
    HTML := 'За вчерашний день на было создано ни одного счета.<br>';
  if Length(va) > 0 then begin
    HTML := S.IIFStr(HTML <> '', HTML + '<br><br>----------------------------------<br><b>') + 'Были приходные накладные без основания за вчерашний день:</b><br>Номера: ' + A.Implode(va,', ') + '<br>';
  end;
  if HTML = '' then
    Exit;
  Tasks.SendMail(TASK_MAILING_MONITORING_SN, Title, HTML, [FileToSend], '~');
end;

procedure TTasksS.ReportForYesterdayOrders(AOrderTypes: Integer; AMailing: Boolean = True);
//финансовый отчет по производственным или отгрузочным заказам, запущенным за вчерашний день
//1'Отчет по производственным заказам за вчерашний день',
//2'Отчет по производственным заказам в работе',    //убрал
//3'Отчет по отгрузочным заказам за вчерашний день',
//4'Отчет по отгрузочным заказам в работе'          //убрал
//5'Отчет по производственным заказам за прошедшую неделю'
//6'Отчет по производственным заказам за прошешеший месяц'
//7'Отчет по отгрузочным заказам за прошедшую неделю'
//8'Отчет по отгрузочным заказам за прошешеший месяц'
var
  na: TNamedArr;
  Fields: TVarDynArray2;
  Tbl: THTMLTable;
  HTML, Title, TopSt, FileToSend, st1, st2, st3: string;
  DtBeg: TDateTime;
  DataType: Integer;
begin
  case AOrderTypes of
    1:
      begin
        st1 := 'производственным';
        st2 := 'вчерашний день';
        st3 := DateTimeToStr(IncDay(Date, -1));
        DtBeg := IncDay(Date, -1);
        DataType := 1;
      end;
    3:
      begin
        st1 := 'отгрузочным';
        st2 := 'вчерашний день';
        st3 := DateTimeToStr(IncDay(Date, -1));
        DtBeg := IncDay(Date, -1);
        DataType := 1;
      end;
    5:
      begin
        st1 := 'производственным';
        st2 := 'прошлую неделю';
        st3 := 'прошлую неделю';
        DtBeg := Date - DayOfTheWeek(Date);
        DataType := 5;
      end;
    6:
      begin
        st1 := 'производственным';
        st2 := 'прошлый месяц';
        st3 := 'прошлый месяц';
        DtBeg := DateOf(EndOfTheMonth(IncMonth(Date, -1)));
        DataType := 6;
      end;
    7:
      begin
        st1 := 'отгрузочным';
        st2 := 'прошлую неделю';
        st3 := 'прошлую неделю';
        //дата окончания периода!
        DtBeg := Date - DayOfTheWeek(Date);
        DataType := 5;
      end;
    8:
      begin
        st1 := 'отгрузочным';
        st2 := 'прошлый месяц';
        st3 := 'прошлый месяц';
        //дата окончания периода!
        DtBeg := DateOf(EndOfTheMonth(IncMonth(Date, -1)));
        DataType := 6;
      end;
  end;
  Title := 'Отчет по ' + st1 + ' заказам за ' + st2 + '.';
  TopSt := 'Отчет по ' + st1 + ' заказам за ' + st3 + '.';
  Fields := [
    ['rownum$i', '№', '20'],
    ['item_wo_estimate_st$s', 'Нет сметы', '60'],
    ['ornums$s', 'Заказы', '200;h'],
    ['customer$s', 'Покупатели', '200;h'],
    ['fullname$s', 'Изделие', '500;h'],
    ['qnt$i', 'Количество', '80', 'r'],
    ['qnt_on_sgp$i', 'Количество на СГП', '80', 'r'],
    ['qnt_need_on_sgp$i', 'Избыток/ Потребность на СГП', '80'],
    ['price_std$i', 'Цена по справочнику без НДС', '80', 'r'],
    ['price$i', 'Цена продажи без НДС', '80', 'r'],
    ['price_diff$i', 'Занижение цены без НДС', '80', 'r'],
    ['summ$i', 'Сумма продажи без НДС', '80', 'f=#:', 's', 'r'],
    ['priceraw_wo_nds_std$i', 'Себестоимость по смете стд. изд., без НДС', '80', 's', 'r'],
    ['priceraw_wo_nds$i', 'Себестоимость по смете, за шт., без НДС', '80', 's', 'r'],
    ['sum0$i', 'Себестоимость по смете, сумма без НДС', '80', 'f=#:', 's', 'r'],
    ['sum0_percent$i', '%', '80', 'r'],
    ['labor_cost_0$i', 'Трудозатраты по ПЩ', 'f=#:', '80', 's', 'r'],
    ['labor_cost_0_percent$i', '%', '80', 'r'],
    ['labor_cost_2$i', 'Трудозатраты по ЛОК', '80', 'f=#:', 's', 'r'],
    ['labor_cost_2_percent$i', '%', '80', 'f=#:', 'r'],
    ['prime_cost$i', 'Затраты всего, сумма', '80', 'f=#:', 's', 'r', 'b'],
    ['prime_cost_percent$i', 'Затраты всего, %', '80', 'r']
  ];
  Q.QLoad(Q.QGetSql('A', S.IIf(AOrderTypes in [1, 3], 'v_orders_fin_monitoring', 'v_orders_fin_monitoring') , Fields.Col(0).Implode(';')) +
    ' where data_type = :data_type$i and order_type = :order_type$i and dt = trunc(:dt$d) order by prime_cost_percent desc',
    [DataType, S.IIf(st1 = 'отгрузочным', 0, -1), DtBeg], na
  );
  HTML := '';
  if na.Count = 0 then begin
    if AOrderTypes < 5 then
      HTML := 'Вчера ' + S.IIf(AOrderTypes in [3, 4], 'отгрузочных', 'производственных') + ' заказов запущено не было.'
    else
      HTML := 'За этот период не было запущено ни одного заказа.';
    FileToSend := '';
  end
  else begin
    if AMailing and (AOrderTypes < 5) then begin
      Tbl.InitDefaults;
      Tbl.SetOptions('report-table', '—', True, '0.00', 'dd.mm.yyyy', 'dd.mm.yyyy hh:nn:ss', True, True);
      HTML := TopSt + '<br>' + Tbl.GenerateEmail(na, Fields);
    end;
    FileToSend := S.IIfStr(AMailing, Sys.GetWinTemp + '\' )+ TopSt + '.xlsx';
    ExportToXlsx(FileToSend, na, Fields, TopSt, '', True);
  end;
  if AMailing then
    Tasks.SendMail(TASK_MAILING_ORDERS_FIN, Title, HTML, [FileToSend], '~');
end;

procedure TTasksS.ReportForEarlyCompletionActs;
//отчет по созданным в ИТМ АВР, по которым по заказу не было полного поринятия на сгп в Учете
var
  HTML: string;
  naP, naO: TNamedArr;
begin
  Q.QLoad(
    'select o.ornum , o.customer, o.project, dt_beg, a.actdate '+
    'from v_orders o, dv.acts a '+
    'where o.id_itm = a.id_zakaz and o.dt_to_sgp is null and o.id_organization = -1 and a.actdate = :dt$d ' +
    'order by dt_beg, ornum',
    [IncDay(Date, -1)],
    naP
  );
  Q.QLoad(
    'select o.ornum , o.customer, o.project, dt_beg, a.actdate '+
    'from v_orders o, dv.acts a '+
    'where o.id_itm = a.id_zakaz and o.dt_to_sgp is null and o.id_organization <> -1 and a.actdate = :dt$d ' +
    'order by dt_beg, ornum',
    [IncDay(Date, -1)],
    naO
  );
  if (naP.Count = 0) and (naO.Count = 0) then
    Exit;
  HTML := '<b>Вчера были преждевременно созданы АВР</b><br>';
  if naP.Count > 0 then begin
    HTML := HTML + '<br><b>По производственным заказам:</b><br>';
    for var i := 0 to naP.High do begin
      S.ConcatStP(HTML, naP.G(i, 'ornum') + '  ' + DateToStr(naP.G(i, 'dt_beg')) {+ '  ' + DateToStr(naP.G(i, 'actdate'))} + '"   "' + naP.G(i, 'project') + '"', '<br>');
    end;
  end;
  if naO.Count > 0 then begin
    HTML := HTML + '<br><br><b>По отгрузочным заказам:</b><br>';
    for var i := 0 to naO.High do begin
      S.ConcatStP(HTML, naO.G(i, 'ornum') + '  ' + DateToStr(naO.G(i, 'dt_beg')) {+ '  ' + DateToStr(naO.G(i, 'actdate'))} + '   "' + naO.G(i, 'customer') + '"   "' + naO.G(i, 'project') + '"', '<br>');
    end;
  end;
  Tasks.SendMail(TASK_MAILING_EARLY_COMPLETION_ACTS, 'Преждевременно созданы АВР', HTML, [], '~');
end;

procedure TTasksS.ReportForSupplyisOnwaySurplus;
//отчет по сырью, находящемуся в пути при отсуствии резерва на него
var
  na: TNamedArr;
  Fields: TVarDynArray2;
  FileToSend: string;
  Tbl: THTMLTable;
  HTML, Title, TopSt: string;
begin
  Title := 'Номенклатура в пути без резерва за вчерашний день';
  TopSt := 'Номенклатура в пути без резерва за ' + DateTimeToStr(IncDay(Date, -1));
  Fields := [
    ['name$s', 'Наименование', '500;h'],
    ['name_unit$s', 'Ед. изм.', '80'],
    ['price_main$f', 'Цена', '80', 'r'],
    ['price_check$f', 'Контрольная цена', '80', 'r'],
    ['qnt$f', 'Кол-во на складах', '80', 'r'],
    ['need$f', 'Потребность','80', 'f=#:', 'r'],
    ['rezerv$f', 'Резерв','80', 'f=#:', 'r'],
    ['qnt_onway$f', 'В пути', '80', 'f=#:', 'r'],
    ['qnt_onway_surplus$s', 'Превышение', '80', 'f=#:', 'r'],
    ['qnt_onway_sum$f', 'Сумаа в пути', '80', 'f=#:', 'r']
  ];
  Q.QLoad(Q.QGetSql('A', 'v_spl_minremains', Fields.Col(0).Implode(';'))+ ' where /*monitor_price = 1 and*/ qnt_onway_surplus is not null order by qnt_onway_surplus desc', [], na);
  HTML := '';
  if na.Count > 0 then begin
    Tbl.InitDefaults;
    Tbl.SetOptions('report-table', '—', True, '0.00', 'dd.mm.yyyy', 'dd.mm.yyyy hh:nn:ss', True, True);
    HTML := '<b>Номенклатура в пути без резерва:</b><br>' + Tbl.GenerateEmail(na, Fields, 1, 2, 0);
    FileToSend := Sys.GetWinTemp + '\' + TopSt + '.xlsx';
    ExportToXlsx(FileToSend, na, Fields, TopSt, '', True);
  end
  else
    HTML := 'Номенклатура в пути без резерва отсуствует.<br>';
  Tasks.SendMail(TASK_MAILING_MONITORING_SN, Title, HTML, [FileToSend], '~');
end;

procedure TTasksS.ReportForRawMaterialsOnSgp;
//отчет по материалам на складах готовой продукции, являющихся сырьем а не изделиями
var
  na: TNamedArr;
  Fields: TVarDynArray2;
  FileToSend: string;
  Tbl: THTMLTable;
  HTML, Title, TopSt: string;
begin
  Title := 'Номенклатура на СГП, не являющаяся готовой продукцией';
  TopSt := Title;
  Fields := [
    ['name$s', 'Наименование', '500;h'],
    ['stockname$s', 'Склад', '160'],
    ['qnt$f', 'Кол-во', '80', 'r']
  ];
  Q.QLoad(Q.QGetSql('A', 'v_spl_raw_materials_on_sgp', Fields.Col(0).Implode(';'))+ ' order by stockname, name', [], na);
  HTML := '';
  if na.Count > 0 then begin
    Tbl.InitDefaults;
    Tbl.SetOptions('report-table', '—', True, '0.00', 'dd.mm.yyyy', 'dd.mm.yyyy hh:nn:ss', True, True);
    HTML := '<b>' + Title + '</b><br>' + Tbl.GenerateEmail(na, Fields, 1, 2, 0);
    FileToSend := Sys.GetWinTemp + '\' + TopSt + '.xlsx';
    ExportToXlsx(FileToSend, na, Fields, TopSt, '', True);
  end
  else
    HTML := '';
  if HTML <> '' then
    Tasks.SendMail(TASK_MAILING_MONITORING_SN, Title, HTML, [FileToSend], '~');
end;

procedure TTasksS.ReportForActsWriteoffReceipt;
//информация по актам списания и оприходования за вчерашний день
var
  na: TNamedArr;
  Fields: TVarDynArray2;
  FileToSend: string;
  Tbl: THTMLTable;
  HTML, Title, TopSt: string;
begin
  Title := 'Акты списания и оприходования за вчерашний день';
  TopSt := 'Акты списания и оприходования за ' + DateTimeToStr(IncDay(Date, -1));
  Fields := [
    ['doctype$s', 'Вид документа', '120'],
    ['docnum$s', '№', '80'],
    ['stockname$s', 'Склад', '150'],
    ['comments$s', 'Примечание', '400;h'],
    ['is_inventory$s', 'Инвентаризация', '120'],
    ['name$s', 'Наименование', '500;h'],
    ['name_unit$s', 'Ед. изм.', '80'],
    ['qnt$f', 'Кол-во', '80', 'r']
  ];
  Q.QLoad(Q.QGetSql('A', 'v_acts_writeoff_receipt', Fields.Col(0).Implode(';')) + ' where dt = :dt$d order by doctype, name', [IncDay(Date, -1)], na);
  HTML := '';
  if na.Count > 0 then begin
    Tbl.InitDefaults;
    Tbl.SetOptions('report-table', '—', True, '0.00', 'dd.mm.yyyy', 'dd.mm.yyyy hh:nn:ss', True, True);
    HTML := '<b>' + TopSt + '</b><br>' + Tbl.GenerateEmail(na, Fields, 1, 2, 0);
    FileToSend := Sys.GetWinTemp + '\' + TopSt + '.xlsx';
    ExportToXlsx(FileToSend, na, Fields, TopSt, '', True);
  end
  else
    HTML := '';
  if HTML <> '' then
    Tasks.SendMail(TASK_MAILING_MONITORING_SN, Title, HTML, [FileToSend], '~');
end;


end.
