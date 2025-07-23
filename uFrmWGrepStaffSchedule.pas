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
    ['id_job$i','_Должность','40'],
    ['id_division$i','_Подразделение','40'],
    ['office$s','офис /цех','50'],
    ['job$s','Должность','250;h'],
    ['division$s','Подразделение','250;h'],
    ['qnt$i','Количество работников','100'],
    ['qnt_need$i','Потребность','100','f=f:','e=0:100:0',User.Role(rW_Rep_StaffSchedule_Ch)]
  ]);
  Frg1.Opt.SetButtons(1,[[mbtGo],[],[mbtExcel],[mbtPrintGrid],[],[mbtGridSettings],[],[mbtCtlPanel]]);
  Frg1.Opt.SetButtonsIfEmpty([mbtGo]);
  Frg1.CreateAddControls('1', cntDTEdit, 'Дата', 'edtd1', ':', 50, yrefC, 85);
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

procedure TFrmWGrepStaffSchedule.GetData;
var
  i, qc, qo: Integer;
  na : TNamedArr;
begin
  if not Cth.DteValueIsDate(Frg1.FindComponent('edtd1')) then
    Exit;
  Q.QSetContextValue('staff_schedule_dt', Frg1.GetControlValue('edtd1'));
  Q.QLoadFromQuery('select rownum, id_job, id_division, office, job, division, qnt, qnt_need from v_staff_schedule', [], na);
  qc := 0;
  qo := 0;
  for i := 0 to na.Count - 2 do
    if na.G(i, 'id_division') = null then
      if na.G(i, 'office') = 'цех' then
        qc := qc + na.G(i, 'qnt')
      else
        qo := qo + na.G(i, 'qnt');
  Delete(na.V, na.Count - 1, 1);
  na.V := na.V + [[100000, null, null, 'Итого:', '', 'офис', qo, null]];
  na.V := na.V + [[100001, null, null, 'Итого:', '', 'цех', qc, null]];
  na.V := na.V + [[100002, null, null, 'Итого:', '', 'всего', qc + qo, null]];
  Frg1.SetInitData(na);
end;




end.


