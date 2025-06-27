unit uFrmWDedtWorkerStatus;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh, uFrmBasicMdi,
  uFrmBasicDbDialog, DateUtils, uData, uForms, uDBOra, uString, uMessages,
  uFields;

type
  TFrmWDedtWorkerStatus = class(TFrmBasicDbDialog)
    Cb_Job: TDBComboBoxEh;
    Cb_Division: TDBComboBoxEh;
    Cb_Status: TDBComboBoxEh;
    De_Date: TDBDateTimeEditEh;
    Cb_Worker: TDBComboBoxEh;
    procedure Cb_StatusChange(Sender: TObject);
  private
    a: TVarDynArray2;
    dts: array[1..4] of TDateTime;
    dt1, dt2, dt3, dt4: TDateTime;
    dep: TVarDynArray2;
    function Prepare: Boolean; override;
    function Load: Boolean; override;
    function Save: Boolean; override;
    function VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean; override;
    procedure BtOKClick(Sender: TObject); override;
    function VerifyWorker: Boolean;
    procedure CreateDep(dt: TDateTime; id: Integer);
    function VerifyTurvPeriods: string;
    function VerifyTurvDays(id_worker: Integer; dt: TDateTime): string;
    function DeleteTurvDays(id_worker: Integer; dt: TDateTime): string;
  public
  end;

var
  FrmWDedtWorkerStatus: TFrmWDedtWorkerStatus;

implementation

uses
  uTurv, D_CandidatesFromWorkerStatus;

{$R *.dfm}

function TFrmWDedtWorkerStatus.Prepare: Boolean;
begin
  Caption := 'Статус работника';
  Result := inherited;
//  FOpt.StatusBarMode := stbmNone;
  if Mode = fAdd then
    Load;
end;

function TFrmWDedtWorkerStatus.VerifyWorker: Boolean;
//при добавлении записи
//статус для ранее не бывших или уволенных моржет быть только Принят
//статус для ранее принятых или переведенных не может быть Принят
//дата не может быть меньшей ли равной чем дата в предыдущей записи
//не могут совпадать с предыдущей записью одновременно подразделение и должность
var
  st, msg, msg2: string;
  d: TVarDynArray2;
  idw: Integer;
  v: Variant;
begin
  Result := False;
  if HasError then
    Exit;
  st := '';
  idw := Cth.GetControlValue(Cb_Worker);
  a := Turv.GetWorkerStatusArr(idw);
  d := [];
  if Mode = fAdd then begin
    //добавление записи
    if (Length(a) = 0) and (Cb_Status.Value <> '1') then
      st := 'Для этого работника допустим только статус "Принят"';
    if (st = '') and (high(a) >= 0) then begin
      //по работнику есть уже записи в журнале статусов
      if a[0][0] >= De_Date.Value then
        st := 'Изменить статус этого работника можно только на дату позднее ' + DateToStr(a[0][0])
      else if (a[0][1] = 3) and (Cb_Status.Value <> '1') then
        st := 'Для этого работника допустим только статус "Принят"'
      else if ((a[0][1] = 1) or (a[0][1] = 2)) and (Cb_Status.Value = '1') then
        st := 'Для этого работника не допустим статус "Принят"'
      else if (Cb_Status.Value <> '3') and (Trunc(S.NNum(a[0][2])) = Cth.GetControlValue(Cb_Division)) and (Trunc(S.NNum(a[0][3])) = Cth.GetControlValue(Cb_Job)) then
        st := 'Работник уже числится в этом подразделении и в этой же должности!';
    end;
    if st = '' then begin
      if (Abs(DaysBetween(Cth.GetControlValue(De_Date), Date)) > 31) and (MyQuestionMessage('Дата изменения статуса сильно отличается от текущей! Все равно продолжить?') <> mrYes) then
        Exit;
      Result := Turv.ChangeWorkerInTURV(Cth.GetControlValue(Cb_Worker), Cth.GetControlValue(Cb_Division), Cth.GetControlValue(Cb_Job), Cth.GetControlValue(De_Date), ID, Cth.GetControlValue(Cb_Status));
      if not Result then
        Exit;
    end
    else begin
      //если была строка ошибки контроля данных
      Result := False;
      MyWarningMessage(st);
    end;
  end
  else if Mode = fDelete then begin
    //удаление записи
    //проверим на всякий случай последняя ли запись, вдруг не сразу нажали кнопку удаления и была создана еще одна
    v := Q.QSelectOneRow('select nvl(max(id), -1) from j_worker_status where id_worker = :id$i', [idw])[0];
    if not ((v = -1) or (v = id)) then
      st := 'Эта запись не является последней для данного работника, поэтому не может быть удалена!';
    if st = '' then begin
      //v:=QSelectOneRow('select nvl(max(id), -1) from j_worker_status where id_worker = :id$i', idw)[0];
      if (Abs(DaysBetween(Cth.GetControlValue(De_Date), Date)) > 31) and (MyQuestionMessage('Дата изменения статуса сильно отличается от текущей! Все равно продолжить?') <> mrYes) then
        Exit;
      v := Q.QSelectOneRow('select id, id_worker, id_division, id_job, status, dt from v_j_worker_status ' + 'where id_worker = :idw$i and id < :id and rownum = 1', [Cth.GetControlValue(Cb_Worker), ID]);
      Result := Turv.ChangeWorkerInTURV(Cth.GetControlValue(Cb_Worker), v[2], v[3], Cth.GetControlValue(De_Date), ID, -1);
      if not Result then
        Exit;
    end
    else begin
      //если была строка ошибки контроля данных
      Result := False;
      MyWarningMessage(st);
    end;
  end;
end;

//вернет сообщение, на какие из затрагиваемых периодов установлена блокировка, и какие закрыты
//если сообщение не пустое, то продолжать действие нельзя
function TFrmWDedtWorkerStatus.VerifyTurvPeriods: string;
var
  i, j: Integer;
  id, st: string;
  dt01, dt02: TDatetime;
  b: Boolean;
  v, v1: Variant;
begin
  Result := '';
  for i := 0 to High(Dep) do begin
    id := VarToStr(Dep[i][0]) + ' ' + FormatDateTime('yyyymmdd', TDateTime(Dep[i][1])) + ' ' + FormatDateTime('yyyymmdd', TDateTime(Dep[i][2]));
    v := Q.QSelectOneRow('select login, username from adm_locks where lock_docum = :docum$s and lock_docum_add = :documadd$s', [myfrm_Dlg_Turv, id]);
    if v[0] <> null then begin
      v1 := Q.QSelectOneRow('select name from ref_divisions where id = :id$i', [Dep[i][0]]);
      Result := Result + #13#10 + 'ТУРВ по отделу ' + VarToStr(v1[0]) + ' за период с ' + DateToStr(TDateTime(Dep[i][1])) + ' по ' + DateToStr(TDateTime(Dep[i][2])) + ' заблокирован ' + VarToStr(v[1]) + '.';
    end;
    v := Q.QSelectOneRow('select id_division, name from v_turv_period where id = :id$s and commit = :commit$i', [id, 1]);
    if v[0] <> null then
      Result := Result + #13#10 + 'ТУРВ по отделу ' + VarToStr(v[1]) + ' за период с ' + DateToStr(TDateTime(Dep[i][1])) + ' по ' + DateToStr(TDateTime(Dep[i][2])) + ' завершен и не может быть изменен!'
  end;
end;

//вернет сообщение, сколько дней из тех, что должны быть удалены, имеют числовое значение
//дни, у которых установлено не рабочее время, а коды турв, не принимаются в расчет
function TFrmWDedtWorkerStatus.VerifyTurvDays(id_worker: Integer; dt: TDateTime): string;
var
  v: Variant;
begin
  Result := '';
  v := Q.QSelectOneRow('select count(*) from turv_day where (worktime1 is not null or worktime2 is not null or worktime3 is not null) and id_worker = :id_worker$i and dt >= :dt$d', [id_worker, dt]);
  if v[0] > 0 then
    Result := 'В ТУРВ есть ' + VarToStr(v[0]) + ' дней, по которым проставлено время работы, и которые будут удалены.';
end;

//удалим все дневные турвы работника старше даты
function TFrmWDedtWorkerStatus.DeleteTurvDays(id_worker: Integer; dt: TDateTime): string;
var
  v: Variant;
  b: array of Boolean;
  b1: Boolean;
  i: Integer;
  id: string;
begin
  Result := '';
  SetLength(b, Length(dep));
  b1 := True;
  //попытаемся заблокировать все используемые турвы
  for i := 0 to High(Dep) do begin
    id := VarToStr(Dep[i][0]) + ' ' + FormatDateTime('yyyymmdd', TDateTime(Dep[i][1])) + ' ' + FormatDateTime('yyyymmdd', TDateTime(Dep[i][2]));
    b[i] := Q.DBLock(True, myfrm_Dlg_Turv, id, '')[0];
    b1 := b1 and b[i];
  end;
  if b1 then begin
    Q.QExecSql('delete from turv_day where id_worker = :id_worker$i and dt >= :dt$d', [id_worker, dt], False);
  end
  else
    Result := 'Не удалось заблокировать затрагиваемые ТУРВ для выполнения изменений!';
  //разблокируем, те что были заблокированы
  for i := 0 to High(Dep) do begin
    id := VarToStr(Dep[i][0]) + ' ' + FormatDateTime('yyyymmdd', TDateTime(Dep[i][1])) + ' ' + FormatDateTime('yyyymmdd', TDateTime(Dep[i][2]));
    if b[i] then
      Q.DBLock(False, myfrm_Dlg_Turv, id, '');
  end;
end;



//добавим затрагиваемые ТУРВ
//в массиве [[идб дт1б дт2],[...]]
//так как период допустимых дат определяется тремя турвами, то
//берем турв, в который попадает дата и все последующие до предельной даты
procedure TFrmWDedtWorkerStatus.Cb_StatusChange(Sender: TObject);
begin
  if FInPrepare then
    Exit;
  if S.NInt(Cb_Status.Value) = 3 then begin
    Cb_Division.Value := '';
    Cb_Job.Value := '';
    Cb_Division.Enabled := False;
    Cb_Job.Enabled := False;
  end
  else begin
    Cb_Division.Enabled := True;
    Cb_Job.Enabled := True;
  end;
  inherited;
  ControlOnChangeEvent(Sender);
end;

procedure TFrmWDedtWorkerStatus.CreateDep(dt: TDateTime; id: Integer);
var
  i, j, id0: Integer;
  dt01, dt02: TDatetime;
  b: Boolean;
begin
  for i := 1 to High(dts) - 1 do begin
    dt01 := dts[i + 1];
    //помещаем в массив, если период закончился позже даты
    if dt01 > dt then begin
      b := True;
      for j := 0 to High(dep) do
        if (dep[j][0] = id) and (dep[j][1] = dts[i]) then begin
          b := False;
          Break;
        end;
      if b then begin
        SetLength(dep, Length(dep) + 1);
        dep[High(dep)] := [id, dts[i], IncDay(dts[i + 1], -1)];
      end;
    end;
  end;
end;


procedure TFrmWDedtWorkerStatus.BtOKClick(Sender: TObject);
begin
  if (Mode = fView) then begin
    Close;
    Exit;
  end;
  Verify(nil);
  if not VerifyWorker then
    Exit;
  if not Save then
    Exit;
  RefreshParentForm;
  Close;
end;


function TFrmWDedtWorkerStatus.VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean;
begin
  Result := False;
  Cth.SetErrorMarker(Cb_Division, not ((Cb_Division.Value <> '') or (Cb_Status.Value = '3')));
  Cth.SetErrorMarker(Cb_Job, not ((Cb_Job.Value <> '') or (Cb_Status.Value = '3')));
end;

function TFrmWDedtWorkerStatus.Load: Boolean;
var
  v, v1: Variant;
  st: string;
begin
  Result := False;
  Q.QLoadToDBComboBoxEh('select w.f || '' '' || w.i || '' '' || w.o as name, id from ref_workers w order by name', [], Cb_Worker, cntComboLK);
  Q.QLoadToDBComboBoxEh('select name, id from ref_divisions order by name', [], Cb_Division, cntComboLK);
  Q.QLoadToDBComboBoxEh('select name, id from ref_jobs order by name', [], Cb_Job, cntComboLK);
  Cth.AddToComboBoxEh(Cb_Status, [['Принят', '1'], ['Переведен', '2'], ['Уволен', '3']]);
  if Mode = fAdd then
    v := VarArrayOf([-1, '', '', '', '', ''])
  else
    v := Q.QSelectOneRow('select id, id_worker, id_division, id_job, status, dt from v_j_worker_status where id = :id', [id]);
  if v[0] = null then begin
    MsgRecordIsDeleted;
    Exit;
  end;
  Cth.SetControlValue(Cb_Worker, v[1]);
  Cth.SetControlValue(Cb_Division, v[2]);
  Cth.SetControlValue(Cb_Job, v[3]);
  Cth.SetControlValue(Cb_Status, v[4]);
  Cth.SetControlValue(De_Date, v[5]);
  if Mode = fDelete then begin
    v1 := Q.QSelectOneRow('select nvl(max(id), -1) from j_worker_status where id_worker = :id$i', [v[1]])[0];
    if not ((v1 = -1) or (v1 = id)) then begin
      MyWarningMessage('Эта запись не является последней для данного работника, поэтому не может быть удалена!');
      Exit;
    end;
  end;
  //параметры проверки контролов - все обязательны
  Cth.SetControlsVerification([Cb_Worker, Cb_Division, Cb_Job, Cb_Status, De_Date], ['1:400', '1:400', '1:400', '1:400', '1']);
  Cth.DlgSetControlsEnabled(Self, Mode, [], []);
  Cb_Division.Enabled := (Cb_Status.Value <> '3') and (Mode = fAdd);
  Cb_Job.Enabled := Cb_Division.Enabled;
  //даты затрагиваемых турв (начала периодов)
  dts[2] := TURV.GetTurvBegDate(Date);
  dts[1] := TURV.GetTurvBegDate(IncDay(dts[2], -1));
  dts[3] := TURV.GetTurvBegDate(IncDay(dts[2], 17));
  dts[4] := TURV.GetTurvBegDate(IncDay(dts[3], 17));
  //если передан массив параметров, то зададим поля
  //(если присваиваем свойство текст, которого нет в комбобоксе, то он останется пустым)
  if VarIsArray(AddParam) then begin
    Cb_Worker.Text := AddParam[0];
    if AddParam[1] <> '' then
      Cb_Division.Text := AddParam[1];
    if AddParam[2] <> '' then
      Cb_Job.Text := AddParam[2];
    if AddParam[3] <> null then
      De_Date.Value := AddParam[3];
  end;
  Result := True;
end;

function TFrmWDedtWorkerStatus.Save: Boolean;
var
  v: TVarDynArray;
  i, j: Integer;
begin
  Result := False;
  if Mode = fDelete then begin
    v := [id];
    Result := (Q.QIUD('d', 'j_worker_status', 'sq_j_worker_status', 'id$i;name$s;office$i;id_head$i;editusers$s', v) >= 0);
  end
  else begin
    v := [id, Cth.GetControlValue(Cb_Worker), Cth.GetControlValue(Cb_Division), Cth.GetControlValue(Cb_Job), Cth.GetControlValue(Cb_Status), Cth.GetControlValue(De_Date)];
    Result := (Q.QIUD('i', 'j_worker_status', 'sq_j_worker_status', 'id$i;id_worker$i;id_division$i;id_job$i;status$i;dt$d', v) >= 0);
 {   if Result then
      Dlg_CandidatesFromWorkerStatus.ShowDialog(v[1], v[4], v[5]);} //!!!
  end;
end;

end.

