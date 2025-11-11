{
//!!!ERROR
где-то в TFrmBasicDbDialog или uFields
если встречаетс€ определение ['id_mode$i;0;0','V=1:400',#0,1] не после списка всех остальных, то съезжают значени€ в контролах !!!!!!!!


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
    cmb_id_sxhedule: TDBComboBoxEh;
    edt_comm: TDBEditEh;
    chb_is_trainee: TDBCheckBoxEh;
    chb_is_foreman: TDBCheckBoxEh;
    chb_is_concurrent: TDBCheckBoxEh;
    cmb_id_organization: TDBComboBoxEh;
    edt_personnel_number: TDBEditEh;
  private
    function Prepare: Boolean; override;
    function Save: Boolean; override;
  public
  end;

var
  FrmWDedtEmployeeProperties: TFrmWDedtEmployeeProperties;

implementation

uses
  Types, RegularExpressions, Math, DateUtils, IOUtils, Clipbrd,   //basi
  uSettings, uSys, uForms, uDBOra, uMessages, uWindows, uPrintReport, uFrmBasicInput, uFrmBasicMdi   //my basic
  ;

{$R *.dfm}

function TFrmWDedtEmployeeProperties.Prepare: Boolean;
begin
  Caption := '«адача';
  F.DefineFields:=[
    ['id$i'],
    ['dt$d',#0,Date],
    ['id_mode$i;0;0','V=1:400',#0,1],
    ['id_manager$i',#0,User.GetId],
    ['dt_beg$d','V=:'],
    ['id_employee$i','V=1:400'],
    ['id_departament$i','V=1:400'],
    ['id_job$i','V=1:400'],
    ['id_schedule$i','V=1:400'],
    ['is_concurrent$i'],
    ['is_foreman$i'],
    ['is_trainee$i'],
    ['id_organization$i','V=0:400'],
    ['personnel_number$s','V=0:400'],
    ['comm$s','V=0:400']
  ];

  View := 'w_employee_properties';
  Table := 'w_employee_properties';
  FOpt.InfoArray:= [
    ['¬вод данных.'#13#10+
     ''#13#10+
     ''#13#10
     ,not A.InArray(Mode, [fView, fDelete]) {and (User.GetId = S.NInt(CtrlValues[3]))}
    ],
    [
     '≈сли вы исполнитель, поставьте текущий статус задачи, и, если нужно, комментарий к ней.'#13#10+
     ''#13#10
    ,not A.InArray(Mode, [fView, fDelete])],
    ['ƒанные задачи'
    ,A.InArray(Mode, [fView, fDelete])]
  ];
  FWHBounds.Y2 := -1;
  Result := inherited;
  if not Result then
    Exit;
{  SetControlsEditable([], True);
  //даты и инициаора никогда не редактируем
  SetControlsEditable([edt_user1, dedt_dt, dedt_dt_beg, dedt_dt_end], False);
  //согласование редактирет инициатор при статусе √отово
  SetControlsEditable([chb_confirmed], (User.GetId = S.NInt(F.GetPropB('id_user1'))) and (S.NInt(F.GetPropB('id_state')) = 99));
  if (Mode in [fCopy, fAdd, fEdit]) and not ((User.GetId = S.NNum(F.GetPropB('id_user2'))) or (User.GetId = S.NInt(F.GetPropB('id_user1')))) then begin
    //закроем пол€ исполнител€, если открывает не исполнитель (или не инициатор, ему все открыто!)
    SetControlsEditable([cmb_id_state, mem_comm2], False);
  end
  else if (Mode in [fEdit]) and (User.GetId <> S.NInt(F.GetPropB('id_user1'))) then begin
    //закроем пол€ инициатора, если открывает не инициатор (при редактировании)
    SetControlsEditable([cmb_type, edt_name, cmb_id_user2, cmb_id_order, cmb_id_order_item, mem_comm1, dedt_dt_planned, chb_confirmed], False);
  end
  else if Mode in [fDelete, fView] then
    SetControlsEditable([], False);
  Cth.SetControlVerification(dedt_dt_planned, S.DateTimeToIntStr(F.GetPropB('dt')));
  FOldState := cmb_id_state.Value;
  FOldOrder := cmb_id_order.Text;         }
end;

function TFrmWDedtEmployeeProperties.Save: Boolean;
var
  st, st1: string;
begin
  Result := inherited;
end;


end.
