unit uFrmODedtDevel;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, Vcl.Mask,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFields, uFrmBasicDbDialog
  ;

type
  TFrmODedtDevel = class(TFrmBasicDbDialog)
    mem_Comm: TDBMemoEh;
    nedt_Hours: TDBNumberEditEh;
    cmb_Id_Kns: TDBComboBoxEh;
    cmb_Id_Status: TDBComboBoxEh;
    dedt_Dt_End: TDBDateTimeEditEh;
    dedt_Dt_Plan: TDBDateTimeEditEh;
    dedt_Dt_Beg: TDBDateTimeEditEh;
    cmb_Name: TDBComboBoxEh;
    cmb_Project: TDBComboBoxEh;
    cmb_Slash: TDBComboBoxEh;
    cmb_Id_DevelType: TDBComboBoxEh;
  private
    FDeveloper: Integer;
    FCaption: string;
    FHours: TVarDynArray2;
    function  Prepare: Boolean; override;
    function  LoadComboBoxes: Boolean; override;
    procedure ControlOnChange(Sender: TObject); override;
  public
  end;

var
  FrmODedtDevel: TFrmODedtDevel;

implementation

{$R *.dfm}

function TFrmODedtDevel.LoadComboBoxes: Boolean;
begin
  //загружаем комбобоксы
  Q.QLoadToDBComboBoxEh('select name, id from ref_develtypes where developer = :d$i order by name', [FDeveloper], cmb_Id_DevelType, cntComboLK);
  Q.QLoadToDBComboBoxEh('select distinct project from j_development where developer = :d$i order by project', [FDeveloper], cmb_Project, cntComboE);
  Q.QLoadToDBComboBoxEh('select distinct name from j_development where developer = :d$i order by name', [FDeveloper], cmb_Name, cntComboE);
  Q.QLoadToDBComboBoxEh('select slash from v_order_items where id_order > 0 and qnt > 0 and dt_end is null order by slash', [], cmb_Slash, cntComboE);    //долго!
  cmb_Slash.MaxLength:=25;
  //комбобокс статуса жестко прописан
  Cth.AddToComboBoxEh(cmb_Id_Status, [
    ['новый', '1'],
    ['в работе', '2'],
    ['остановлен', '3'],
    ['на согласовании', '4'],
    ['завис', '5'],
    ['готово', '100']
  ]);
  //загрузим комбобокс конструкторов, так как дл€ этого надо знать айди в таблице проектов, чтобы загрузить неактивного но который уже в ней есть
  Q.QLoadToDBComboBoxEh(
    'select name, id from adm_users where (job = :id_job$i and active = 1) or id = :id_old$i order by name asc',
    [S.Decode([FormDoc, myfrm_Dlg_J_Devel, myjobKNS, myjobTHN]), F.GetPropB('id_kns')],
    cmb_Id_Kns,
    cntComboLK
  );
  FHours := Q.QLoadToVarDynArray2('select hours, id from ref_develtypes where developer = :d$i', [FDeveloper]);
  Result:=True;
end;

function TFrmODedtDevel.Prepare: Boolean;
begin
  FDeveloper := S.Decode([FormDoc, myfrm_Dlg_J_Devel, 1, 2]);
  FCaption := S.Decode([FormDoc, myfrm_Dlg_J_Devel, '∆урнал разработки', '∆урнал проверки заказов']);
  Caption := '«адача';
  F.DefineFields:=[
    ['id$i'],
    ['developer$i',#0,FDeveloper],
    ['id_develtype$i','V=1:400',#0],
    ['project$s','V=1:400:0:T',#0],
    ['name$s','V=1:400:0:T',#0],
    ['dt_beg$d','V=1',#0,Date],
    ['dt_plan$d','V=1',#0],
    ['dt_end$d',#0],
    ['id_status$i','V=0:400',#0,1],
//    ['cnt$f','V=0:9999999:1',#0],
//    ['time$f','V=0:9999999:1',#0],
    ['comm$s','V=0:4000:0:T',#0],
    ['id_kns$i','V=0:400',#0],
    ['hours$f;0','V=0:9999999:1',#0],
    ['slash$s','V=0:25:0:T',#0]
  ];
  View:='v_j_development';
  Table:='j_development';
  FOpt.UseChbNoClose:= False;
  FOpt.InfoArray := [[
     FCaption + ' - реадктирование записи.'#13#10+
    '¬ид работы может быть выбран только из стандартных вариантов.'#13#10+
    'ѕроект и наименование могут быть любыми, но должны быть об€зательно заданы.'#13#10+
    'ќб€зательно нужно установить статус.'#13#10+
    'ƒата запуска проставл€етс€ автоматически при создании, а дата завершени€ - про установке статуса √отово.'#13#10+
    'ѕол€ є издели€, »сполнитель и  омментарий об€зательными не €вл€ютс€.'#13#10
  ]];
  FWHBounds.X := 610;
  FWHBounds.Y := 400;
  Result := inherited;
  if not Result then
    Exit;
  SetControlsEditable([dedt_Dt_Beg, nedt_Hours], False);
  SetControlsEditable([dedt_Dt_End], (cmb_Id_Status.Value = '100') and (Mode in [fCopy, fEdit, fAdd]));
  if F.GetPropB('id_status') = 100 then
    Cth.SetControlVerification(dedt_dt_end, '1');
end;

procedure TFrmODedtDevel.ControlOnChange(Sender: TObject);
//событие изменени€ данных контрола
begin
  if Sender = cmb_Id_DevelType then begin
    if cmb_Id_DevelType.Value.AsString = '' then
      Cth.SetControlValue(nedt_Hours, null)
    else
      Cth.SetControlValue(nedt_Hours, FHours[A.PosInArray(cmb_Id_DevelType.Value, FHours, 1)][0]);
  end;
  //выход если в процедуре загрузки
  if FInPrepare then
    Exit;
  if Sender = cmb_Id_Status then
    if cmb_Id_Status.Value = '100' then begin
      Cth.SetControlsVerification([dedt_Dt_End], ['1']);
      Cth.SetControlValue(dedt_Dt_End, Date);
      SetControlsEditable([dedt_Dt_End], True);
      Verify(dedt_Dt_End);
    end
    else begin
      Cth.SetControlsVerification([dedt_Dt_End], ['']);
      Cth.SetControlValue(dedt_Dt_End, null);
      SetControlsEditable([dedt_Dt_End], False);
      Verify(dedt_Dt_End);
    end;
  inherited;
end;


end.
