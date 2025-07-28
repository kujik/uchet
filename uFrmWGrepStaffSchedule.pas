{
Штатное расписание
}

unit uFrmWGrepStaffSchedule;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2, uFrmBasicInput
  ;

type
  TFrmWGrepStaffSchedule = class(TFrmBasicGrid2)
  private
    function  PrepareForm: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); override;
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;
    procedure GetData;
  public
  end;

var
  FrmWGrepStaffSchedule: TFrmWGrepStaffSchedule;

implementation

uses
  uTurv;

{$R *.dfm}

function TFrmWGrepStaffSchedule.PrepareForm: Boolean;
begin
  Caption:='Штатное расписание';
  Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible] - [myogSorting];
  Frg1.Opt.SetFields([
    ['rownum$i','_id','40'],
    ['is_title$i','_title','40'],
    ['id_job$i','_Должность','40'],
    ['id_division$i','_Подразделение','40'],
    ['office$s','офис /цех','50'],
    ['job$s','Должность','250;h'],
    ['division$s','Подразделение','250;h'],
    ['qnt$i','Количество работников','100'],
    ['qnt_need$i','Потребность','100','f=f:','e=0:100:0',User.Roles([], [rW_Rep_StaffSchedule_Ch_O, rW_Rep_StaffSchedule_Ch_C])]
  ]);
  Frg1.Opt.SetButtons(1,[[mbtGo],[],[mbtExcel],[mbtPrintGrid],[],[mbtGridSettings],[],[mbtCtlPanel]]);
  Frg1.Opt.SetButtonsIfEmpty([mbtGo]);
  Frg1.CreateAddControls('1', cntDTEdit, 'Дата', 'edtd1', ':', 50, yrefC, 85);
  Frg1.CreateAddControls('1', cntComboL, 'Площадка', 'cmbArea', ':', 50 + 85 + 80, yrefC, 100);
  Q.QLoadToDBComboBoxEh('select ''Все'' from dual union select distinct area_shortname || '' - '' || isoffice from v_ref_divisions order by 1', [], TDBComboBoxEh(Frg1.FindComponent('cmbArea')), cntComboL);
  Frg1.InfoArray:=[[
    'Штатное расписание.'#13#10
  ]];
  //данные из массива
  Frg1.SetInitData([]);
  Result := Inherited;
end;

procedure TFrmWGrepStaffSchedule.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if Tag = mbtGo then begin
    GetData;
    Fr.RefreshGrid;
  end
  else
    inherited;
end;

procedure TFrmWGrepStaffSchedule.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if Fr.GetValue('office') = 'Итого:' then
    Params.Background := clmyYelow
  else if (Fr.GetValue('id_division') = null) or (Fr.GetValue('is_title') = 1) then
    Params.Background := clmyGray
end;

procedure TFrmWGrepStaffSchedule.Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
  ReadOnly := (Fr.GetValue('id_division') = null) or
    ((Fr.GetValue('office') = 'цех') and not User.Role(rW_Rep_StaffSchedule_Ch_C)) or
    ((Fr.GetValue('office') = 'цех') and not User.Role(rW_Rep_StaffSchedule_Ch_C));
end;

procedure TFrmWGrepStaffSchedule.Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
begin
  Q.QExecSql('delete from ref_workers_needed where id_division = :id_division$i and id_job = :id_job$i', [Fr.GetValue('id_division'), Fr.GetValue('id_job')]);
  Q.QExecSql('insert into ref_workers_needed (id_division, id_job, qnt) values (:id_division$i, :id_job$i, :qnt$i)', [Fr.GetValue('id_division'), Fr.GetValue('id_job'), S.NullIf0(Value)]);
end;

procedure TFrmWGrepStaffSchedule.GetData;
var
  i, qc, qo: Integer;
  na : TNamedArr;
  st: string;
begin
  if (not Cth.DteValueIsDate(Frg1.FindComponent('edtd1'))) or (S.NSt(Frg1.GetControlValue('cmbArea')) = '') then
    Exit;
  if Frg1.GetControlValue('cmbArea')  <> 'Все' then begin
    i := Pos(' - ', Frg1.GetControlValue('cmbArea'));
    Q.QSetContextValue('staff_schedule_office', S.IIf(Copy(Frg1.GetControlValue('cmbArea'), i + 3) = 'офис' , 1, 0));
    Q.QSetContextValue('staff_schedule_area', Copy(Frg1.GetControlValue('cmbArea'), 1, i -1));
  end
  else begin
    Q.QSetContextValue('staff_schedule_office', '');
    Q.QSetContextValue('staff_schedule_area', '');
  end;
  Q.QSetContextValue('staff_schedule_dt', Frg1.GetControlValue('edtd1'));
  Q.QLoadFromQuery('select rownum, 0 as is_title, id_job, id_division, office, job, division, qnt, qnt_need from v_staff_schedule', [], na);
  //посчитаем итоги по цеху и офису
  qc := 0;
  qo := 0;
  for i := 0 to na.Count - 2 do
    if na.G(i, 'id_division') <> null then
      if na.G(i, 'office') = 'цех' then
        qc := qc + na.G(i, 'qnt')
      else
        qo := qo + na.G(i, 'qnt');
  //удалим последнюю строку (вью там возвращает строку с общим итогом)
  Delete(na.V, na.Count - 1, 1);
  //добавим итоги
  na.V := na.V + [[100000, null, null, null, 'Итого:', '', 'офис', qo, null]];
  na.V := na.V + [[100001, null, null, null, 'Итого:', '', 'цех', qc, null]];
  na.V := na.V + [[100002, null, null, null, 'Итого:', '', 'всего', qc + qo, null]];
  //удалим итоги по тем профессиям по которым только одна запись (цифра в предыдущей строке совпадает с текущей)
  i := 1;
  while i <= na.Count - 4 do begin
    if (na.G(i, 'qnt') = na.G(i - 1, 'qnt')) and (na.G(i, 'id_division') = null) then begin
      Delete(na.V, i, 1);
      na.SetValue(i - 1, 'is_title', 1);
    end;
    Inc(i);
  end;
  Frg1.SetInitData(na);
end;




end.


