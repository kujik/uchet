{
зарплатная ведомость

  первоначально создается запись в таблице ведомостей по данному подразделений (и, возможно, одному работнику) за данный период
(создается в Dlg_CreatePayroll)
  при первом открытии заполняется строками на основе ТУРВ, строки с одинаковым работником объединяются, должность пишется первая,
работники, по которым есть индивидуальные ведомости не вносятся. расчетные данные заполняются пустыми. но бланка и оклад берутся
из предыдущей ведомости (за прошлый период) по данному подразделению (по всему подразделению). метод расчета берется также из
этой ведомости.
  при нажатии кнопки турв - корректируется список (добавляются записи, которых еще не было, если по ним нет индивидуальных ведомостей,
удаляются из сетки, но не из БД, записи, для которых больше нет строки в турв). загружаются данные по рабочим часам, премиям, штрафам,
и пересчитывается сетка.
  данные в сетке (все) - целые, втч турв, а итог округляется до 10р
  данные сохраняются при закрытии ведомости, включая и изменение настроек, и изменение списка работников в ведомости


ID	NAME	COMM
14	Сборка/станки/реклама/покраска	оклада нет, баллы выгрузка, премии за период нет
13	Конструктора/технологи	оклада нет, баллы выгрузка, премии за период нет
12	Офис, мастер, ОТК	оклад, баллы до нормы, премия за период вручную
11	Наладчик/электрик	оклад, баллы полностью, премия за период вручную
10	Грузчик/упаковщик	оклад, баллы до нормы, премия за отчетный период (формула), премия за переработку (формула)
}

unit uFrmWGedtPayroll;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls,
  DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls, DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd,
  ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils, Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh
  ;

type
  TFrmWGedtPayroll = class(TFrmBasicGrid2)
  private
    FPayrollParams: TNamedArr;
    FIsEditable: Boolean;
    FDeletedWorkers: TVarDynArray;
    FColWidth: Integer;
    function  PrepareForm: Boolean; override;
    function  CreatePayroll: Integer;
    function  GetDataFromDb: Integer;
    procedure SetButtons;
{    function  SetLock: Boolean;
    function  LoadTurv: Boolean;
    function  LoadTurvCodes: Boolean;
    function  GetTurvCode(AValue: Variant): Variant;
    function  GetTurvCell(ARow, ADay, ANum: Integer): Variant;
    procedure PushTurvToGrid;
    procedure PushTurvCellToGrid(ARow, ADay: Integer);
    procedure PushTurvCellToDetailGrid(ARow, ADay: Integer);
    procedure SetLblDivisionText;
    procedure SetLblWorkerText;
    procedure SetLblsDetailText;
    function  FormatTurvCell(v: Variant): string;
    procedure FrgsColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
    procedure InputDialog(Mode : Integer);
    function  GetDay: Integer;
    procedure SaveDayToDB(r, d: Integer; Mode: Integer);
    procedure SaveWorkerToDB(r: Integer);
    procedure ExportToXlsxA7(Doc: Integer; Date1, Date2: Variant; AutoOpen: Boolean);
    procedure SundaysToTurv;
    procedure SendEMailToHead;
    procedure SetGridEditableMode;
}
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
  public
  end;

var
  FrmWGedtPayroll: TFrmWGedtPayroll;

implementation

uses
  uTurv,
  uLabelColors2,
  uFrmBasicInput,
  uExcel,
  uPrintReport
  ;


{$R *.dfm}

function TFrmWGedtPayroll.PrepareForm: Boolean;
var
  i, j, w1: Integer;
  v: Variant;
  wcol, fcol: string;
begin
  Result:=False;

  Caption:='Зарплатная ведомость';
  FOpt.RefreshParent := True;

  if FormDbLock = fNone then Exit;

  Q.QLoadFromQuery('select id, id_division, id_worker, dt1, dt2, divisionname, workername, office, id_method, commit from v_payroll where id = :id$i', [ID], FPayrollParams);
  if FPayrollParams.Count = 0 then begin
    MsgRecordIsDeleted;
    Exit;
  end;
{  ID_Division:=v[1];
  ID_Worker:=v[2];
  PeriodStartDate:=v[3];
  PeriodEndDate:=v[4];
  DivisionName:=S.NSt(v[5]);
  WorkerName:=S.NSt(v[6]);
  IsOffice:=v[7] = 1;;
  CalcMode:=v[8];
  Commit:=v[9] = 1;

  lbl_Caption1.Caption:=S.IIf(WorkerName<>'', WorkerName + ' (' + DivisionName + ')', DivisionName) + ' с ' +DateToStr(PeriodStartDate) + ' по ' +DateToStr(PeriodEndDate);
//  IsEditable:=Mode = fEdit;
//  lbl_ReadOnly.Visible:=IsEditable;

  Norma01:=Q.QSelectOneRow('select norm0, norm1 from payroll_norm where dt = :dt$d', [PeriodStartDate]);
  Norma:=S.IIf(IsOffice, Norma01[1], Norma01[0]);

  FPayrollParams

}

  FDeletedWorkers := [];
  FColWidth := 45;
  wcol := IntToStr(FColWidth) + ';r';
  fcol := 'f=###,###,###:';
  Frg1.Options := FrDBGridOptionDef + [myogPanelFind];
  Frg1.Opt.SetFields([
    ['id$i', '_id','40'],
    ['id_worker$i', '_id_worker', wcol],
    ['id_job$i', '_id_job', wcol],
    ['changed$i', '_changed', wcol],
    ['workername$s', 'ФИО', '200;h'],
    ['job$s', 'Должность', '150;h'],
    ['blank$i', '~  № бланка', wcol],
    ['ball_m$i', '~  Оклад', wcol],
    ['turv$f', '~  ТУРВ', wcol, fcol],
    ['ball$i', '~  Расчет' + sLineBreak + '  оклада', wcol, fcol],
    ['premium_m_src$i', '~  Премия ' + sLineBreak + '  (грузчики)', wcol, fcol],
    ['premium$i', '~  Премия' + sLineBreak + '  текущая', wcol, fcol],
    ['premium_p$i', '~  Премия за' + sLineBreak + '  переработки', wcol, fcol],
    ['premium_m$i', '~  Премия' + sLineBreak + '', wcol, fcol],
    ['otpusk$i', '~  ОТ', wcol, fcol],
    ['bl$i', '~  БЛ', wcol, fcol],
    ['penalty$i', '~  Штрафы', wcol, fcol],
    ['itog1$i', '~  Итого' + sLineBreak + '  начислено', wcol, fcol],
    ['ud$i', '~  Удержано', wcol, fcol],
    ['ndfl$i', '~  НДФЛ', wcol, fcol],
    ['fss$i', '~  Выплачено' + sLineBreak + '  ФСС', wcol, fcol],
    ['pvkarta$i', '~  Промежуточная' + sLineBreak + '  выплата - карта', wcol, fcol],
    ['karta$i', '~  Карта', wcol, fcol],
    ['itog$i', '~  Итого к' + sLineBreak + '  получению', wcol, fcol],
    ['sign$i', '~  Подпись', '55']
  ]);
  Frg1.Opt.SetGridOperations('u');
  Frg1.Opt.SetButtons(1, [
    [mbtSettings],[],[mbtCustom_Turv],[mbtCustom_Payroll],[mbtCard],[],[mbtExcel],
    [mbtDividorM],[mbtPrint],[mbtPrint],[mbtPrintLabels],[mbtDividorM],[],[mbtLock],
    [],
    [mbtCtlPanel]
  ]);


  Frg1.CreateAddControls('1', cntLabelClr,
    '$FF0000' + S.IIf(FPayrollParams.G('workername') <> null, FPayrollParams.G('workername') + ' (' + FPayrollParams.G('divisionname') + ')', FPayrollParams.G('divisionname')) +
    '$000000 с$FF00FF ' + DateToStr(FPayrollParams.G('dt1')) + ' $000000 по $FF00FF' + DateToStr(FPayrollParams.G('dt2')),
    'lblDivision', '', 4, yrefT, 800
  );
  Frg1.CreateAddControls('1', cntLabelClr, '', 'lblInfo', '', 4, yrefB, 800);
  Frg1.SetInitData([], '');

  Result := inherited;
  if not Result then
    Exit;
  //Frg1.DBGridEh1.TitleParams.RowHeight := 90;
{  DBGridEh1.STFilter.Visible:=True;
  DBGridEh1.STFilter.Location:=stflInTitleFilterEh;
  for i:=0 to DbGridEh1.Columns.Count - 1 do
    DBGridEh1.Columns[i].STFilter.Visible:=False;
  Gh.GetGridColumn(DBGridEh1, 'blank').STFilter.Visible:=True;}
  //ширина окна по ширине грида
  Self.Width := Frg1.GetTableWidth + 75;

  GetDataFromDb;
  SetButtons;

  {  Self.MinWidth:=1100;
  Self.MinHeight:=300;
//  lbl_ReadOnly.Left:=Width - pnl_Right.Width - lbl_ReadOnly.Width - 50;

  //если в данной ведомости нет ни одной записи, попробуем их создать
  CreateTurvList;
  //прочитаем из БД ведомость
  GetList;}


(*
  //изменение ширины столбцов
  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh-[dghColumnResize];
  DBGridEh1.FixedColor:=RGB(200,200,200);
//  DBGridEh1.FrozenCols:=5;
  SetButtons;
  CheckEmpty;

  //установим доступность стандартных кнопок в зависимости от наличия данных в таблице
//  Cth.SetBtnAndMenuEnabled(pnl1, Pm_Grid, mbtView, IsNotEmpty);

*)
  Result:=True;
end;

function TFrmWGedtPayroll.CreatePayroll: Integer;
//формируем ведомость (список пользователей) на основе ТУРВ по данному отделу (Первоначальное создание)
//вызывается только в случае, если в ведомости нет ни одной строки, при открытии ведомости
//даже если это первое открытие, то список будет перечитан вызовом GetDataFromDb
var
  i, j, k: Integer;
  va, va1, vadel: TVarDynArray2;
  st, st1, st2, w: string;
  v, v1, v2: Variant;
  buf: Variant;
  changed: Boolean;
  size: Integer;
begin
  if Q.QSelectOneRow('select count(*) from payroll_item where id_payroll = :id$i', [id])[0] > 0 then
    Exit;
  //0-дата1, 1-дата2, 2-айди работника, 3-имя работника, 4-фйди профессии, 5-назавание профессии, 6-после периода: 1=переведен 2=уволен
  va := uTurv.Turv.GetTurvArray(FPayrollParams.G('id_division'), FPayrollParams.G('dt1'), False);
  vadel := [[]];
  //уберем повторяющиеся по фио строки
  i := 0;
  j := 0;
  st := '';
  while i < High(va) do begin
    if va[i][3] = st then begin
      delete(va, i, 1);
    end
    else begin
      st := va[i][3];
      inc(i);
    end;
  end;
  if FPayrollParams.G('id_worker') = null then begin
    //если ведомость по подразделению
    // сортировка массива
    repeat
      changed := False;
      for k := 0 to High(va) - 1 do
        if va[k][5] > va[k + 1][5] then begin // обменяем k-й и k+1-й элементы
          for j := 0 to High(va[k]) do begin
            buf := va[k][j];
            va[k][j] := va[k + 1][j];
            va[k + 1][j] := buf;
          end;
          changed := True;
        end;
    until not changed;
    //загрузим айди работников, по которым созданя за этот период отдельные ведомости
    vadel := Q.QLoadToVarDynArray2('select id_worker from v_payroll where id_worker is not null and dt1 = :dt1$d', [FPayrollParams.G('dt1')]);
  end
  else begin
    //удалим все строки, кроме работника по которому ведомость
    for i := High(va) downto 0 do begin
      if va[i][2] <> FPayrollParams.G('id_worker') then
        Delete(va, i, 1);
    end;
  end;
  //загрузим работников из прошлой ведомости по этому же подразделению (по всему подразделению)
  va1:=Q.QLoadToVarDynArray2(
    'select id_worker, blank, ball_m from payroll_item where id_division = :id_division$i and dt = :dt1$d',
    [FPayrollParams.G('id_division'), Turv.GetTurvBegDate(IncDay(FPayrollParams.G('dt1'), -1))]
  );
  //заполним но бланка и баллы за период (оклад) из прошлого периода
  for i := 0 to High(va) do begin
    j := A.PosInArray(va[i][2], va1, 0);
    if j >= 0 then begin
      va[i][5] := va1[j][1];
      va[i][6] := va1[j][2];
    end
    else begin
      va[i][5] := null;
      va[i][6] := null;
    end;
  end;

  //создадим данные по пользователям для данной ведомости в БД (без всех числовых значений)
  //если вдруг в процессе выполнения этой процедуры элементы ведомости в бд будут созданы такие же другим пользователем,
  //то будет ошибка уникальности, здесь ее не выводим
  //после создания, ведомость все равно будет перечитана из БД
  //убрал - но все-таки сделал проверку чтобы не создавались те по которым индивидуальные ведомости, хотя это и не обязательно
  for i := 0 to High(va) do begin
    if not A.PosInArray(va[i][2], vadel, 0) >=0 then
      Q.QIUD('i', 'payroll_item', 'sq_payroll_item', 'id;id_payroll;id_division;id_worker;id_job;dt;blank$f;ball_m$f',
        [-1, ID, Integer(FPayrollParams.G('id_division')), Integer(va[i][2]), Integer(va[i][4]), FPayrollParams.G('dt1'), va[i][5], va[i][6]],
        False
      );
  end;
  if Length(va) > 0 then begin
    Q.QExecSql('update payroll set id_method = (select id_method from payroll where id_division = :id_division$i and dt1 = :dt1$d and id_worker is null) where id = :id$i',
      [FPayrollParams.G('id_division'), Turv.GetTurvBegDate(IncDay(FPayrollParams.G('dt1'), -1)), ID]
    );
  end;
end;

function TFrmWGedtPayroll.GetDataFromDb: Integer;
//прочитаем ведомость (все данные) из БД и заполним ими сетку
var
  na : TNamedArr;
begin
  Q.QLoadFromQuery(
    'select workername, job, id, id_worker, id_job, blank, ball_m, turv, ball, premium_m_src, premium, premium_p, premium_m ,otpusk, bl, penalty, itog1, ud, ndfl, fss, pvkarta, karta, itog '+
    'from v_payroll_item where id_payroll = :id$i order by job, workername',
    [ID], na
  );
  Frg1.LoadData(na);
end;


procedure TFrmWGedtPayroll.SetButtons;
begin
      Frg1.SetControlValue('lblInfo', '$000000Только просмотр.')
(*  if Mode = fView
    then begin
      Frg1.SetControlValue('lblInfo', '$000000Только просмотр.')
{      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtSettings, False);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtCustom_Turv, False);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtCustom_Payroll, False);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtCard, False);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtLock, False);}
    end
    else if (Norma = null) or (CalcMode = null) then begin
      lbl_Info.Caption:='Задайте параметры!';
      lbl_Info.Font.Color:=clRed;
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtSettings, True);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtCustom_Turv, False);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtCustom_Payroll, False);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtCard, False);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtLock, False);
    end
    else if Commit then begin
      lbl_Info.Caption:='Ведомость закрыта, только просмотр.';
      lbl_Info.Font.Color:=clGreen;
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtSettings, False);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtCustom_Turv, False);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtCustom_Payroll, False);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtCard, False);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtLock, True);
    end
    else begin
      lbl_Info.Caption:='Ввод данных.';
      lbl_Info.Font.Color:=RGB(255, 0, 255);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtSettings, True);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtCustom_Turv, True);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtCustom_Payroll, Integer(CalcMode) in [13, 14]);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtCard, True);
      Cth.SetBtnAndMenuEnabled(pnl_Left, nil, mbtLock, True);
    end;
  Cth.GetSpeedBtn(pnl_Left, mbtLock).Hint:=S.IIf(Commit, 'Отменить закрытие ведомости', 'Закрыть ведомость');
  SetColumns;
*)
end;



{==============================================================================}

procedure TFrmWGedtPayroll.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
end;

procedure TFrmWGedtPayroll.Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
end;

procedure TFrmWGedtPayroll.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
end;

procedure TFrmWGedtPayroll.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
end;




end.
