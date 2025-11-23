{
проверка что были изменения при добавлении статуса по сравнению с прошлым статусом
диапозон дат начала статуса
блокировки, уведомления
режим редактирования для разработчика
}

unit uFrmWDedtEmployeeProperties;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Mask, Vcl.StdCtrls,
  DBCtrlsEh, DBGridEh,  //ehlib
  uData, uString, uFrDBGridEh,  //my
  uFrmBasicDbDialog
  ;

type
  TFrmWDedtEmployeeProperties = class(TFrmBasicDbDialog)
    cmb_id_mode: TDBComboBoxEh;
    dedt_dt_beg: TDBDateTimeEditEh;
    cmb_id_departament: TDBComboBoxEh;
    cmb_id_job: TDBComboBoxEh;
    cmb_id_schedule: TDBComboBoxEh;
    edt_comm: TDBEditEh;
    chb_is_trainee: TDBCheckBoxEh;
    chb_is_foreman: TDBCheckBoxEh;
    chb_is_concurrent: TDBCheckBoxEh;
    cmb_id_organization: TDBComboBoxEh;
    edt_personnel_number: TDBEditEh;
    cmb_grade: TDBComboBoxEh;
  private
    FIdMode: Variant;
    FIdEmp: Integer;
    FIdLast: Variant;
    FLastRec: TNamedArr;
    function Prepare: Boolean; override;
    function LoadComboBoxes: Boolean; override;
    function Save: Boolean; override;
    procedure ControlOnChange(Sender: TObject); override;
    procedure SetControlsState;
  public
  end;

var
  FrmWDedtEmployeeProperties: TFrmWDedtEmployeeProperties;

implementation

uses
  Types, RegularExpressions, Math, DateUtils, IOUtils, Clipbrd,   //basi
  uSettings, uSys, uForms, uFields, uDBOra, uMessages, uWindows, uPrintReport, uFrmBasicInput, uFrmBasicMdi   //my basic
  ;

{$R *.dfm}

function TFrmWDedtEmployeeProperties.Prepare: Boolean;
var
  v: Variant;
  DtVer: string;
  va: TVarDynArray;
begin
  Result := False;
  FIdEmp := AddParam;
  if Mode <> fView then begin
    //получим айди последней по работнику записи
    FIdLast := Q.QSelectOneRow('select id from w_employee_properties where id_employee = :id_e$i order by id desc', [FIdEmp])[0];
    if (Mode = fDelete) then begin
      //в случае удаления статуса - выйдем если нет записей, иначе возьмем айди последней
      if FIdLast = null then
        Exit;
      ID := FIdLast;
      //и найдем запись, предшествующую последней
      FIdLast := Q.QSelectOneRow('select id from w_employee_properties where id_employee = :id_e$i and id <> :id$i order by id desc', [FIdEmp, ID])[0];
    end;
    //получим все поля этой записи
    if FIdLast <> null then
      Q.QLoadFromQuery('select * from w_employee_properties where id = :id$i', [FIdLast], FLastRec);
  end;
  if (Mode = fAdd) and (FIdLast <> null) and (FLastRec.G('is_terminated') <> 1) then begin
    //в режиме создания нового статуса, если он не первый для работника и последний не есть увольнение, поставим режим копирования и айди послдедней записи
    ID := FIdLast;
    Mode := fCopy;
  end;
  //первоначальнай режим прием/перевод/увольнение (только прием при первом или после увольения, какой есть для просмотра или удаления, в противном случае не выбран)
  FIdMode := null;
  if Mode in [fView, fDelete] then begin
    va := Q.QSelectOneRow('select is_terminated, is_hired from w_employee_properties where id = :id$i', [ID]);
    FIdMode := S.IIf(va[0] = 1, 3, S.IIf(va[1] = 1, 1, 2));
  end
  else if (Mode = fAdd) and ((FIdLast = null) or (FLastRec.G('is_terminated') = 1)) then
    FIdMode := 1;
  //проверка начальной даты
  //при добавлении статуса, дата позднее начальной даты прошлого статуса, если это ббыли прием или увольнение, или дата его начала, если это перевод (перевод можно перекрыть)
  DtVer := '*:*';
  if (Mode in [fAdd, fCopy]) then begin
    DtVer := DateToStr(IncDay(Date, -62));
    if (FIdLast <> null) then
      if (FLastRec.G('is_terminated') = 1) or (FLastRec.G('is_hired') = 1) then
        DtVer :=  S.DateTimeToIntStr(IncDay(FLastRec.G('dt_beg'), 1))
      else
        DtVer :=  S.DateTimeToIntStr(IncDay(FLastRec.G('dt_beg'), 0));
    DtVer := 'V=' + DtVer + ':' +  S.DateTimeToIntStr(IncDay(Date, +16));
  end;
  Caption := '~' + S.Decode([Mode, fCopy, 'Статус работника - Добавить', fAdd, 'Статус работника - Добавить', fDelete, 'Статус работника - Удалить', fEdit, 'Статус работника - Изменить', 'Статус работника - Просмотреть']);
  F.DefineFields:=[
    ['id$i'],
    ['dt$d',#0,Date],
    ['id_mode$i;0;0','V='+S.IIf(Mode = fEdit, '0', '1')+':400',#0,FIdMode],
    ['id_manager$i',#0,User.GetId],
    ['dt_beg$d',DtVer],
    ['id_employee$i','V=1:400'],
    ['id_departament$i','V=1:400'],
    ['id_job$i','V=1:400'],
    ['grade$f','V=1:400'],
    ['id_schedule$i','V=1:400'],
    ['is_concurrent$i'],
    ['is_foreman$i'],
    ['is_trainee$i'],
    ['id_organization$i','V=0:400'],
    ['personnel_number$s','V=0:400'],
    ['comm$s','V=0:400'],
    ['is_terminated$i;0']
  ];

  View := 'w_employee_properties';
  Table := 'w_employee_properties';
  FOpt.InfoArray:= [
    ['Ввод данных.'#13#10+
     ''#13#10+
     ''#13#10
     ,not A.InArray(Mode, [fView, fDelete]) {and (User.GetId = S.NInt(CtrlValues[3]))}
    ],
    [
     ''#13#10
    ,not A.InArray(Mode, [fView, fDelete])],
    [''
    ,A.InArray(Mode, [fView, fDelete])]
  ];
  FWHBounds.Y2 := -1;
  //выполним метод родителя
  Result := inherited;
  if not Result then
    Exit;
  SetControlsState;
end;

function TFrmWDedtEmployeeProperties.LoadComboBoxes: Boolean;
var
  va2: TVarDynArray2;
begin
  //загружаем комбобоксы
  Q.QLoadToDBComboBoxEh('select name, id from ref_sn_organizations where active = 1 and id > 0 or id = :id_old$i order by name asc', [F.GetPropB('id_organization')], cmb_id_organization, cntComboLK);
  Q.QLoadToDBComboBoxEh('select name, id from w_jobs where active = 1 or id = :id_old$i order by name asc', [F.GetPropB('id_job')], cmb_id_job, cntComboLK);
  Q.QLoadToDBComboBoxEh('select name, id from w_departaments where active = 1 or id = :id_old$i order by name asc', [F.GetPropB('id_departament')], cmb_id_departament, cntComboLK);
  Q.QLoadToDBComboBoxEh('select code, id from w_schedules where active = 1 or id = :id_old$i order by code asc', [F.GetPropB('id_schedule')], cmb_id_schedule, cntComboLK);
  Q.QLoadToDBComboBoxEh('select grade, grade as key from w_grades where active = 1 or grade = :grade_old$i order by grade asc', [F.GetPropB('grade')], cmb_grade, cntComboLK);
  if Mode in [fView, fDelete] then
    va2 := [['принят', '1'], ['переведен', '2'], ['уволен', '3']]
  else if (FIdLast = null) or (FLastRec.G('is_terminated') = 1) then
    va2 := [['принять', '1']]
  else
    va2 := [['перевести', '2'], ['уволить', '3']];
  Cth.AddToComboBoxEh(cmb_id_mode, va2);
  Result := True;
end;


function TFrmWDedtEmployeeProperties.Save: Boolean;
var
  st, st1: string;
  dt: TDateTime;
begin
  Result := True;
  Q.QBeginTrans(True);
  if Mode = fEdit then
    Result := inherited
  //проставим дату окончания прошлого статуса, поправим айди статусов в таблице дней турв, при увольнении дни после него удалим
  else if (FIdLast <> null) and (FLastRec.G('is_terminated') <> 1) then begin
    //есть предыдущий статус и это не увольнение
    //(у увольнения нет конечноq даты, и нет дней, которым назначен этот статус)
    if Mode = fDelete then begin
      //при удалении статуса сбросим конечную дату прошлого статуса
      Q.QExecSql('update w_employee_properties set dt_end = :dt$d where id = :id$i', [null, FIdLast]);
      //и присвоим всем дням с удаленным id_employee_properties айди того, к которому откатились
      Q.QExecSql('update w_turv_day set id_employee_properties = :id_last$i where id_employee_properties = :id$i', [FIdLast, ID]);
      //вызовем родительскую процедуру (поле FID будет обновлено)
 //     Q.QExecSql('delete from w_employee_properties where id = :id$i', [ID]);
      //!!! ЕСЛИ ДЕЛАТЬ ТАК - СТРАННАЯ ОШИБКА ПРИ УДАЛЕНИИ, НАДО РАЗБИРАТЬСЯ - В ЛОГАХ ДРУГОЙ АЙДИ!!!
      Result := inherited;
    end
    else begin
      //вызовем родительскую процедуру (поле FID будет обновлено)
      Result := inherited;
      //при добавлении конечную дату прошлого поставим на день раньше начала созданного статуса,
      //но если увольнение - поставим днем начала (днем увольнения, так по тк)
      Q.QExecSql('update w_employee_properties set dt_end = :dt$d where id = :id$i', [IncDay(GetcontrolValue('dedt_dt_beg'), S.IIf(GetcontrolValue('cmb_id_mode').AsInteger = 3, 0, -1)), FIdLast]);
      if GetcontrolValue('cmb_id_mode').AsInteger = 3 then
        //если увольнение, то удалим безвозвратно данные по дням для этого работника после и в дату увольнения
        Q.QExecSql('delete from w_turv_day where id_employee = :id_e$i and dt >= :dt_beg$d', [FIdEmp, GetcontrolValue('dedt_dt_beg')])
      else
        //при переводе поправим в данных по дням айди статуса для работника после начала действия созданного статуса на его айди
        Q.QExecSql('update w_turv_day set id_employee_properties = :id$i where id_employee = :id_e$i and dt >= :dt_beg$d', [ID, FIdEmp, GetcontrolValue('dedt_dt_beg')]);
      //если дата окончания прошлого периода оказалась меньше даты его начала, то удалим его
      Q.QExecSql('delete from w_employee_properties where dt_end < dt_beg and id = :id$i', [FIdLast]);
    end;
  end
  else
    //если нет предыдущего статуса, или же предыдущий есть увольнение - просто обработаем текущую строку
    //(это либо удаление последнего статуса, либо приём на работу)
    //для увольнения не нужно корректировать дату и править таблицу дней
    Result := inherited;
  Q.QCommitOrRollback(Result);
end;

procedure TFrmWDedtEmployeeProperties.ControlOnChange(Sender: TObject);
begin
  if FInPrepare then
    Exit;
  if Sender = cmb_id_mode then
    SetControlsState;
  inherited;
end;

procedure TFrmWDedtEmployeeProperties.SetControlsState;
begin
  if Mode in [fView, fDelete] then
    Exit
  else if Mode = fEdit then
    SetControlsEditable([cmb_id_mode, dedt_dt_beg], False);
  //заблокируем все если выбрали режим Увольнение
  SetControlsEditable(
    [cmb_id_job, cmb_grade, cmb_id_schedule, cmb_id_departament, cmb_id_organization, chb_is_trainee, chb_is_foreman, chb_is_concurrent, edt_personnel_number],
    (GetControlValue('cmb_id_mode').AsString <> '3') and not ((Mode = fEdit) and (F.GetPropB('is_terminated') = 1))
  );
  if Mode = fEdit then
    Exit;
  //заблокирем изменение организации и табльного номера, если это не прием, или если они уже введены
  if FIdMode <> 1 then begin
    if (FIdLast <> null) and (FLastRec.G('id_organization') <> null) then
      SetControlsEditable([cmb_id_organization], False);
    if (FIdLast <> null) and (FLastRec.G('personnel_number') <> null) then
      SetControlsEditable([edt_personnel_number], False);
  end;
  if GetControlValue('cmb_id_mode').AsString <> '3' then
    Exit;
  F.SetPropsControls('id_job;grade;id_schedule;id_departament;id_organization;is_trainee;is_foreman;is_concurrent;personnel_number', [fvtVBeg]);
end;


end.
