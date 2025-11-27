unit uFrmWDedtCreatePayrollN;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmBasicMdi, Vcl.ExtCtrls, Vcl.StdCtrls,
  DBCtrlsEh, Vcl.ComCtrls, DateUtils, Vcl.Mask;

type
  TFrmWDedtCreatePayrollN = class(TFrmBasicMdi)
    pgcMain: TPageControl;
    ts_Divisions: TTabSheet;
    lbl1: TLabel;
    dedtDt1: TDBDateTimeEditEh;
    dedtDt2: TDBDateTimeEditEh;
    ts_Worker: TTabSheet;
    lbl2: TLabel;
    chbPrev: TDBCheckBoxEh;
    chbCurr: TDBCheckBoxEh;
    dedtW: TDBDateTimeEditEh;
    cmbWorker: TDBComboBoxEh;
  private
    Mode: Integer;
    OwnerForm: TForm;
    procedure btnOkclick(Sender: TObject); override;
    function Prepare: Boolean; override;
  public
  end;

var
  FrmWDedtCreatePayrollN: TFrmWDedtCreatePayrollN;

implementation

{$R *.dfm}

uses
  uTurv,
  uMessages,
  uDBOra,
  uData,
  uString,
  uForms
  ;

procedure TFrmWDedtCreatePayrollN.btnOkclick(Sender: TObject);
var
  dt1, dt2: TDateTime;
  i, j, periods: Integer;
  v, v1, v2: Variant;
  va1, va2: TVarDynArray2;
  cnt: Integer;
  b, b1: Boolean;
  st: string;
  wid: Integer;
  dep: TVarDynArray;
begin
  //inherited;
  cnt := 0;
  st := '';
  //для создания по всем подразделениям
  if pgcMain.ActivePageIndex = 0 then begin
    //дата начала периода должна быть корректной датой, но произвольной, по ней высчитываем начало турв
    if not Cth.DteValueIsDate(dedtDt1) then
      Exit;
    if MyQuestionMessage('Создать ведомости расчета заработной платы?') <> mrYes then
      Exit;
    //поставим дату начала и конца периода турв исходя из даты начала
    //используется для отладки, в реальном режиме даты изменять нельзя
    dedtDt1.Value := Turv.GetTurvBegDate(dedtDt1.Value);
    dedtDt2.Value := Turv.GetTurvEndDate(dedtDt1.Value);
    //получим список созданных турв за период
    va1 := Q.QLoadToVarDynArray2('select id_departament, departament, is_finalized from v_w_turv_period where dt1 = :dt1$d', [dedtDt1.Value]);
    //получим список ведомостей по зп, по полным подразделениям за этот период
    va2 := Q.QLoadToVarDynArray2('select id_departament from v_w_payroll_calculations where dt1 = :dt1$d and id_employee is null',  //and id_division = :id_division$i
      [dedtDt1.Value]);
    for i := 0 to High(va1) do begin
      b := True;
      for j := 0 to High(va2) do
        if va1[i, 0] = va2[j, 0] then begin
          b := False;
          Break;
        end;
      //если не нашли в созданных, то проверим закрыт ли турв
{      if b then
       if va1[i, 2] <> 1 then begin
          if not User.IsDeveloper then
            b := False;                   //не создаем для незакрытого турв
          st := st + va1[i, 1] + #13#10;  //в собщение
        end;  }
      if b then begin
  //      if QIUD('i', 'payroll', 'sq_payroll', 'id;id_division$i;dt1$d;dt2$d', [0, va1[i,0], dedt_Dt1.Value, dedt_Dt2.Value], False) <> -1
        //создаем зарплатную ведомость, если все же во время между проверками уже такая была создана, то будет ошибка уникального индекса, здесь ее не выводим
        if Q.QIUD('i', 'w_payroll_calculations', '', 'id$i;id_departament$i;dt1$d;dt2$d', [0, Integer(va1[i, 0]), dedtDt1.Value, dedtDt2.Value], False) <> -1 then
          inc(cnt);  //увеличим количество созданных
      end;
    end;
    //сообщение
    if st <> '' then
      st := #13#10#13#10'По следующим подразделениям не закрыты ТУРВ:'#13#10 + st;
  end
  //для создания по выбранному работнику
  else begin
    if (not Cth.DteValueIsDate(dedtW)) or (not chbPrev.Checked and not chbCurr.Checked and not dedtW.Visible) then
      Exit;
    //не создаем ведомости по работнику, если хотя бы у кого-то открыты по подразделениям любые ведомости
    //тк создание может привести к удалению из существующей ведомости
    Q.DBLock(True, 'clear', '-');
    Q.DBLock(False, 'clear', '-');
    v := Q.QSelectOneRow('select login, username from adm_locks where lock_docum = :docum$s', [myfrm_Dlg_Payroll]);
    if v[0] <> null then begin
      MyInfoMessage('Ведомости расчета заработной платы (у Вас или у другого пользователя) открыты для редактирования.'#13#10'Пока они не будут закрыты, создание ведомостей по одному работнику невозможно!');
      Exit;
    end;
    //не выбран работник, выйдем
    if  Cth.GetControlValue(cmbWorker) = null then
      Exit;
    if MyQuestionMessage('Создать ведомости расчета заработной платы?') <> mrYes then
      Exit;
    wid := Cth.GetControlValue(cmbWorker);
    va1 := Turv.GetWorkerStatusArr(wid);
//  Result:=QLoadToVarDynArray2('select dt, status, id_division, id_job from j_worker_status where id_worker = :id$i order by dt desc, id_division, id_job', id);
    for periods := 0 to 1 do begin
      dt1 := MinDateTime;
      //получим дату начала периода
      //если виден ввод даты, то только один период и это значение
      if dedtW.Visible and (periods = 0) then
        dt1 := Turv.GetTurvBegDate(dedtW.Value);
      //иначе, если отмечено галками, прошлый и текущий период
      if not (dedtW.Visible) and (chbPrev.Checked) and (periods = 0) then
        dt1 := dedtDt1.Value;
      if not (dedtW.Visible) and (chbCurr.Checked) and (periods = 1) then
        dt1 := Turv.GetTurvBegDate(Date);
      if dt1 = MinDateTime then
        continue;
      //конец периода
      dt2 := Turv.GetTurvEndDate(dt1);
      //массив затронутых подразделений
      dep := [];
      //проход по массиву статусов работника
      //в обратном поряядке, тк нам здесь надо проход от старых дат, а массив отсортирован от новых к более старым
      for i := High(va1) downto 0 do begin
        //после периода, выходим
        if va1[i][0] > dt2 then
          Break;
        //до начала или в первый день - выбираем последнее подразделение
        if (va1[i][0] <= dt1) and (Integer(va1[i][1]) in [1, 2]) then
          dep := [va1[i][2]];
        //после начала и до конца периода - добавляем каждое подразделение куда принят/переведен
        if (va1[i][0] > dt1) and (Integer(va1[i][1]) in [1, 2]) then
          dep := dep + [va1[i][2]];
      end;
      Q.QBeginTrans(True);
(*      for i := 0 to High(dep) do begin
        //удалим строки с таким работником из ведомостей (только из ведомостей по отделам, а не по работникам!)
        Q.QExecSql('delete from payroll_item i where ' + 'id_division = :id_division$i and id_worker = :id_worker$i and dt = :dt$d ' + 'and (select id_worker from payroll where i.id_payroll = id) is null', [dep[i], wid, dt1]);
        //создадим ведомость по работнику в каждом найденном подразделении за данный период
        if Q.QIUD('i', 'payroll', 'sq_payroll', 'id$i;id_division$i;dt1$d;dt2$d;id_worker$i', [0, dep[i], dt1, dt2, wid], False) <> -1 then
          inc(cnt);  //увеличим количество созданных
      end; *)
      //Q.QRollbackTrans;
      Q.QCommitOrRollback(True);
    end;
  end;
  //сообщение
  if cnt = 0 then
    st := 'Ни одна ведомость не создана!' + st
  else
    st := 'Создан' + S.GetEnding(cnt, 'а', 'о', 'о') + ' ' + IntToStr(cnt) + ' ведомост' + S.GetEnding(cnt, 'ь', 'и', 'ей') + '.' + st;
  MyInfoMessage(st);
  //обновим форму журнала
  if cnt > 0 then
    RefreshParentForm;
  Close;
end;

function TFrmWDedtCreatePayrollN.Prepare: Boolean;
begin
  Result := False;
  Caption := '~Добавить ведомости расчета заработной платы';
  FOpt.RefreshParent := True;
  FOpt.DlgPanelStyle := dpsBottomRight;
  FOpt.StatusBarMode := stbmNone;
  FOpt.AutoAlignControls := True;
  //даты для отделов по текущему периоду
  dedtDt1.Value := Turv.GetTurvBegDate(IncDay(Turv.GetTurvBegDate(Date), -1));
  dedtDt2.Value := Turv.GetTurvEndDate(dedtDt1.Value);
  //даты для ведомости по работнику - текущий и предыдущий периоды
  chbPrev.Caption := 'с ' + DateToStr(dedtDt1.Value) + ' по ' + DateToStr(dedtDt2.Value);
  chbCurr.Caption := 'с ' + DateToStr(Turv.GetTurvBegDate(Date)) + ' по ' + DateToStr(Turv.GetTurvEndDate(Date));
  //менять даты для отделов и вводить произвольную для работнику разрешим только разработчику и администратору дянных (для отладки)
  dedtW.Value := Turv.GetTurvBegDate(Date);
  //изменение дат создания ведомстей только для отладки
  dedtDt1.Enabled := User.IsDeveloper;
  dedtDt2.Enabled := dedtDt1.Enabled;
  dedtW.Visible := dedtDt1.Enabled;
  //список работников
  Q.QLoadToDBComboBoxEh('select f_fio(f, i, o) as name, id from w_employees order by name', [], cmbWorker, cntComboLK);
  Result := True;
end;


end.
