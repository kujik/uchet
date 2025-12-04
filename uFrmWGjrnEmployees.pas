{

названия: работник, должность, статус работника

нужен ли табельный номер в осн. табл.?
должность или профессия?
надо ли признак Самозанятый?
сделать в классе грида с подстановками   Fr.Opt.Caption := 'Работник: ' + Frg1.GetValueS('name');
быстрое обновление после редактирования, в опции
при удалении на текущую строку, в опции
TGridEhHelper.GridRefresh добавить опционально переход к созданной/измененной, если не поменялась позиция
сделать Fr.FindValueS(FieldName, i, False) -> Pos
ошибка в создании ведомости пор одному работнику на увольнение - пытается создать две один раз по крайней мере //шляхтов а.а.
    drop index idx_payroll_unique;
    create unique index idx_payroll_unique on payroll(id_division, id_worker, dt1);
    select * from payroll where id_worker = 100 order by dt1 desc;
    delete from payroll where id = 2848;
закрывается детальная панель при обновлении формой мдибасик, если в нее передан фрейм грида детальной. обновлется основной?
}


unit uFrmWGjrnEmployees;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms, ExtCtrls, StdCtrls, //обязательно
  DBGridEh,  //ehlib
  uData, uString, uFrDBGridEh, uFrmBasicGrid2
  ;

type
  TFrmWGjrnEmployees = class(TFrmBasicGrid2)
  private
    function  PrepareForm: Boolean; override;
    procedure Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    procedure Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure Frg2ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg2CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;
  public
  end;

var
  FrmWGjrnEmployees: TFrmWGjrnEmployees;

implementation

{$R *.dfm}

uses
  System.Variants,
  uForms, uMessages, uWindows, uFrmBasicMdi,   //my basic
  uTurv,
  uFrmWDedtEmployeeProperties
  ;

function TFrmWGjrnEmployees.PrepareForm: Boolean;
var
  c : TComponent;
  st1, st2: string;
begin
  Result := False;
  Caption := 'Работники';
  Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['name$s','ФИО','250;h'],
    ['birthday$d','Дата рождения','90'],
    ['age$i','Возраст','70'],
    ['dt_reg$d','Дата первого приема','100'],
    ['is_working_now$s','Статус','100','pic=работает;уволен:1;6:+'],
    ['last_hired$d','Дата последнего приема','100'],
    ['last_terminated$d','Дата последнего увольнения','100'],
    ['dt_last_transfer$d','Последняя должность|Дата перевода','90'],
    ['departament$s','~Подразделение','240;h'],
    ['job$s','~Должность','240;h'],
    ['comm$s','Комментарий','200;h']
  ]);
  Frg1.Opt.SetTable('v_w_employees');
  Frg1.CreateAddControls('1', cntCheck, 'Только работающие', 'chbActive', '', 4, yrefC, 200);
  Frg1.Opt.SetButtons(1, 'rveads', User.Role(rW_R_Workers_Ch));
  Frg1.Opt.DialogFormDoc := myfrm_Dlg_R_Workers;

  Frg2.Opt.Caption:='Работники';
  Frg2.Options := Frg2.Options + [myogGridLabels];

  Frg2.Opt.SetFields([
    ['id$i','_id','40'],
    ['id_departament$i','_id_dep','40'],
    ['id_job$i','_id_job','40'],
    ['id_schedule$i','_id_shed','40'],
    ['rn$i','Событие|№','40'],
    ['dt$d','~Дата события','80'],
    ['managername$s','~Менеджер','100'],
    ['status$s','Значения|Статус','120','pic=принят;уволен;переведен:7;6;1:+'],
    ['dt_beg$d','~С','80'],
    ['dt_end$d','~По','80'],
    ['departament$s','~Подразделение','200;h'],
    ['job$s','~Должность','200;h'],
    ['grade$f','~Разряд','60'],
    ['schedulecode$s','~График','70'],
    ['trainee$s','~Ученик','90'],
    ['foreman$s','~Бригадир','90'],
    ['concurrent$s','~Совместитель','90'],
    ['organization$s','~Организация','100'],
    ['personnel_number$s','~Табельный номер','90'],
    ['comm$s','Событие|Комментарий','200;h','e=1',rW_J_WorkerStatus_Ch]
  ]);
  Frg2.Opt.SetTable('v_w_employee_properties', 'w_employee_properties');
  Frg2.Opt.SetWhere('where id_employee = :id_employee$i order by rn');
  Frg2.Opt.SetButtons(1, [
   [mbtRefresh], [], [mbtView, True, 'Просмотреть выбранный статус работника'], [mbtAdd, User.Role(rW_J_WorkerStatus_Ch), 'Добавить статус работника'],
   [mbtDelete, 1, 'Удалить последний статус работника'], [mbtEdit, 1, 'Изимзенить выбранный статус работника'], [], [mbtGridSettings], [mbtTest, User.IsDeveloper]  //!!!
  ]);
  Frg2.Opt.SetButtonsIfEmpty([mbtTest]);

  Result := inherited;
end;

procedure TFrmWGjrnEmployees.Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
end;

procedure TFrmWGjrnEmployees.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
  //выполним и до загрузки грида
  if TControl(Sender).Name = 'chbActive' then begin
    Frg1.Opt.SetWhere(S.IIfStr(Frg1.GetControlValue('chbActive').AsInteger = 1, 'where is_working_now = ''работает'''));
    Frg1.RefreshGrid;
  end;
end;

procedure TFrmWGjrnEmployees.Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  Fr.SetSqlParameters('id_employee$i', [Frg1.ID]);
  Fr.Opt.Caption := 'Работник: ' + Frg1.GetValueS('name');
end;

procedure TFrmWGjrnEmployees.Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  Handled := True;
  if Tag = mbtTest then
    Turv.ConvertEmployees202511
  else
  if fMode <> fNone then
    TFrmWDedtEmployeeProperties.Show(Frg2, '*' , [myfoDialog, myfoSizeable], fMode, Fr.ID, Frg1.ID)
  else begin
    Handled := False;
    inherited;
  end;
end;


procedure TFrmWGjrnEmployees.Frg2ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
var
  i ,j, p: Integer;
begin
  if Fr.GetCount = 0 then
    Exit;
  if A.InArray(FieldName, ['job', 'grade', 'organization', 'departament', 'schedulecode', 'foreman', 'concurrent', 'trainee']) then begin
    p := Fr.GetValue('rn');
    if (p > 1) and (Fr.GetValueS('status') = 'переведен') then begin
      for i := 0 to Fr.GetCount(False) - 1 do
        if p = Fr.GetValue('rn', i, False) + 1 then
          if Fr.GetValueS(FieldName, i, False) <> Fr.GetValueS(FieldName) then begin
            Params.Background := RGB(220, 220, 255);
            //Fr.SetValue('trainee', i ,False, '111');
            Break;
          end;
    end;
  end;
end;

procedure TFrmWGjrnEmployees.Frg2CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
begin
{  if FieldName <> 'comm' then
    Exit;
  Q.QExecSql('update w_employee_properties set comm = :comm$s where id = :id', [Value]);
  Handled := True;}
end;





end.
