unit uFrmODedtDevel;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions, Vcl.Mask,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2, uFrmBasicInput, uFields, uFrmBasicDbDialog
  ;

type
  TFrmODedtDevel = class(TFrmBasicDbDialog)
    M_Comm: TDBMemoEh;
    Ne_Time: TDBNumberEditEh;
    Ne_Cnt: TDBNumberEditEh;
    Cb_Id_Kns: TDBComboBoxEh;
    Cb_Id_Status: TDBComboBoxEh;
    De_Dt_End: TDBDateTimeEditEh;
    De_Dt_Plan: TDBDateTimeEditEh;
    De_Dt_Beg: TDBDateTimeEditEh;
    Cb_Name: TDBComboBoxEh;
    Cb_Project: TDBComboBoxEh;
    Cb_Slash: TDBComboBoxEh;
    Cb_Id_DevelType: TDBComboBoxEh;
  private
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
  Q.QLoadToDBComboBoxEh('select name, id from ref_develtypes order by name', [], Cb_Id_DevelType, cntComboLK);
  Q.QLoadToDBComboBoxEh('select distinct project from j_development order by project', [], Cb_Project, cntComboE);
  Q.QLoadToDBComboBoxEh('select distinct name from j_development order by name', [], Cb_Name, cntComboE);
  Q.QLoadToDBComboBoxEh('select slash from v_order_items where id_order > 0 and qnt > 0 and dt_end is null order by slash', [], Cb_Slash, cntComboE);
  Cb_Slash.MaxLength:=25;
  //комбобокс статуса жестко прописан
  Cth.AddToComboBoxEh(Cb_Id_Status, [
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
    [myjobKNS, F.GetPropB('id_kns')],
    Cb_Id_Kns,
    cntComboLK
  );
  Result:=True;
end;

function TFrmODedtDevel.Prepare: Boolean;
begin
  Caption:='∆урнал разработки';
  Caption:='«адача';
  F.DefineFields:=[
    ['id$i'],
    ['id_develtype$i','V=1:400',#0],
    ['project$s','V=1:400:0:T',#0],
    ['name$s','V=1:400:0:T',#0],
    ['dt_beg$d','V=1',#0,Date],
    ['dt_plan$d','V=1',#0],
    ['dt_end$d',#0],
    ['id_status$i','V=0:400',#0,1],
    ['cnt$f','V=0:9999999:1',#0],
    ['comm$s','V=0:4000:0:T',#0],
    ['id_kns$i','V=0:400',#0],
    ['time$f','V=0:9999999:1',#0],
    ['slash$s','V=0:25:0:T',#0]
  ];
  View:='v_j_development';
  Table:='j_development';
  FOpt.UseChbNoClose:= False;
  FOpt.InfoArray := [[
    '–еадктирование журнала разработки.'#13#10+
    '¬ид работы может быть выбран только из стандартных вариантов.'#13#10+
    'ѕроект и наименование могут быть любыми, но должны быть об€зательно заданы.'#13#10+
    'ќб€зательно нужно установить статус.'#13#10+
    'ƒата запуска проставл€етс€ автоматически при создании, а дата завершени€ - про установке статуса √отово.'#13#10+
    'ѕол€ —делка, „асы,  онструктор и  омментарий об€зательными не €вл€ютс€.'#13#10
  ]];
  FWHBounds.X := 610;
  FWHBounds.Y := 400;
  Result:=inherited;
  SetControlsEditable([De_Dt_Beg], False);
  SetControlsEditable([De_Dt_End], (Cb_Id_Status.Value = '100')and(Mode in [fCopy, fEdit, fAdd]));
  if F.GetPropB('id_status') = 100 then
    Cth.SetControlVerification(De_dt_end, '1');
end;

procedure TFrmODedtDevel.ControlOnChange(Sender: TObject);
//событие изменени€ данных контрола
begin
  //выход если в процедуре загрузки
  if FInPrepare then
    Exit;
  if Sender = Cb_Id_Status then
    if Cb_Id_Status.Value = '100' then begin
      Cth.SetControlsVerification([De_Dt_End], ['1']);
      Cth.SetControlValue(De_Dt_End, Date);
      SetControlsEditable([De_Dt_End], True);
      Verify(De_Dt_End);
    end
    else begin
      Cth.SetControlsVerification([De_Dt_End], ['']);
      Cth.SetControlValue(De_Dt_End, null);
      SetControlsEditable([De_Dt_End], False);
      Verify(De_Dt_End);
    end;
  inherited;
end;


end.
