unit D_J_Devel;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, Mask,Vcl.ExtCtrls, Vcl.ComCtrls, System.StrUtils,
  uData, uForms, uDBOra, uString, uMessages,
  F_MdiDialogTemplate, V_MDI
  ;

type
  TDlg_J_Devel = class(TForm_MdiDialogTemplate)
    Cb_Id_DevelType: TDBComboBoxEh;
    Cb_Project: TDBComboBoxEh;
    Cb_Name: TDBComboBoxEh;
    De_Dt_Beg: TDBDateTimeEditEh;
    De_Dt_Plan: TDBDateTimeEditEh;
    De_Dt_End: TDBDateTimeEditEh;
    Cb_Id_Status: TDBComboBoxEh;
    M_Comm: TDBMemoEh;
    Ne_Cnt: TDBNumberEditEh;
    Cb_Id_Kns: TDBComboBoxEh;
    Ne_Time: TDBNumberEditEh;
    Cb_Slash: TDBComboBoxEh;
    procedure ControlOnChange(Sender: TObject); override;
    //procedure ControlOnExit(Sender: TObject);
    //procedure ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean);
    //procedure Bt_OKClick(Sender: TObject);
    //procedure FormClose(Sender: TObject; var Action: TCloseAction);
    //procedure Bt_CancelClick(Sender: TObject);
  private
    { Private declarations }
    //Fields: string;
    //Ctrls: Array of TControl;
    //CtrlNames: TVarDynArray;
    //CtrlValues: TVarDynArray;
    //CtrlVerifications: TVarDynArray;
    //Ok: Boolean;
    function  Prepare: Boolean; override;
    function  LoadComboBoxes: Boolean; override;
    //procedure Verify(Sender: TObject; onInput: Boolean = False);
  public
    { Public declarations }
  end;

var
  Dlg_J_Devel: TDlg_J_Devel;

implementation

{$R *.dfm}

uses
  uSettings
  ;

procedure TDlg_J_Devel.ControlOnChange(Sender: TObject);
//событие изменения данных контрола
begin
  //выход если в процедуре загрузки
  if InPrepare then
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




(*
//уход фокуса с контрола
procedure TDlg_J_Devel.ControlOnExit(Sender: TObject);
begin
  //выход если в процедуре загрузки
  if InPrepare then Exit;
  //проверим
  Verify(Sender);
end;

procedure TDlg_J_Devel.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  Settings.SaveWindowPos(Self, FormDoc);
end;

procedure TDlg_J_Devel.Bt_CancelClick(Sender: TObject);
begin
  inherited;
  Close;
end;

procedure TDlg_J_Devel.Bt_OKClick(Sender: TObject);
var
  NewID: Integer;
  res, i: Integer;
  v: Variant;
begin
  if (Mode = fView)
    then begin Close; Exit; end;
  if not((Mode = fDelete)or Ok)
    then Exit;
  CtrlValues:=[ID];
  for i:=0 to High(Ctrls) do begin
    v:=S.NullIfEmpty(Cth.GetControlValue(Ctrls[i]));
    //нужно для комбобокса с ключами (конструктор), иначе если текста нет, то возникает ошибка при присвоении значения переменной в запросе к бд
//    if VarToStr(v) = '' then v:=null;
    CtrlValues:=CtrlValues + [v];
  end;
  res:= Q.QIUD(Q.QFModeToIUD(Mode), 'j_development', '', Fields, CtrlValues);
  if res = -1 then Exit;
  RefreshParentForm;
  Close;
end;

procedure TDlg_J_Devel.ControlCheckDrawRequiredState(Sender: TObject;
  var DrawState: Boolean);
begin
  Cth.VerifyVisualise(Self);
//  verify(Sender, False);
end;

//проверка правлильн6ости данных
//передается контрол для проверки, или нил - проверить все
//и признак что проверка при вводе данных в контроле (в событии onChange)
procedure TDlg_J_Devel.Verify(Sender: TObject; onInput: Boolean = False);
var
  i,j,s:Integer;
  c: TControl;
begin
  //я просмотра и удаления всегда Ок
  if (Mode = fView) or (Mode = fDelete)
    then begin
      Ok:=True;
      Bt_Ok.enabled := Ok;
      Exit;
    end;
  if Sender = nil
    //проверим все DbEh
    then Cth.VerifyAllDbEhControls(Self)
    //проверим текущий
    else Cth.VerifyControl(TControl(Sender), onInput);
  //получим статус проверки и визуализируем
  Ok:=Cth.VerifyVisualise(Self);
  //статус кнопки Ок
  Bt_Ok.Enabled := Ok;
end;
*)

function TDlg_J_Devel.LoadComboBoxes: Boolean;
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
  //загрузим комбобокс конструкторов, так как для этого надо знать айди в таблице проектов, чтобы загрузить неактивного но который уже в ней есть
  Q.QLoadToDBComboBoxEh(
    'select name, id from adm_users where (job = :id_job$i and active = 1) or id = :id_old$i order by name asc',
    [myjobKNS, CtrlValues[10]],
    Cb_Id_Kns,
    cntComboLK
  );
  Result:=True;
end;

function TDlg_J_Devel.Prepare: Boolean;
begin
  Caption:='Журнал разработки';
  Fields:='id$i;id_develtype$i;project$s;name$s;dt_beg$d;dt_plan$d;dt_end$d;id_status$i;cnt$f;comm$s;id_kns$i;time$f;slash$s';
  View:='v_j_development';
  Table:='j_development';
  CtrlVerifications:=['','1:400','1:400:0:T','1:400:0:T','1','1','','0:400','0:9999999:1','0:4000:0','0:400','0:9999999:1','0:25:0:T'];
  CtrlValuesDefault:=[0, null, '', '', Date, null ,null, 1, '', '', null, null, null];
  Info:=
  'Реадктирование журнала разработки.'#13#10+
  'Вид работы может быть выбран только из стандартных вариантов.'#13#10+
  'Проект и наименование могут быть любыми, но должны быть обязательно заданы.'#13#10+
  'Обязательно нужно установить статус.'#13#10+
  'Дата запуска проставляется автоматически при создании, а дата завершения - про установке статуса Готово.'#13#10+
  'Поля Сделка, Часы, Конструктор и Комментарий обязательными не являются.'#13#10
  ;
  AutoSaveWindowPos:= True;
  MinWidth:=600;
  MinHeight:=400;
  Result:=inherited;
  SetControlsEditable([De_Dt_Beg], False);
  SetControlsEditable([De_Dt_End], (Cb_Id_Status.Value = '100')and(Mode in [fCopy, fEdit, fAdd]));
  if CtrlValues[7] = '100' then CtrlVerifications[5]:='1';
end;


  (*  Result:= False;
  //проверим блокировку, выйдем если нельзя взять (при попытке редактирования уйдет в просмотр, при удалении - выход)
  if FormDbLock = fNone then Exit;
//  BorderStyle:=bsDialog; //PreventResize:=True;
  MinWidth:=700;
  MinHeight:=320;
  //все поля основной таблицы в бд
  Fields:='id$i;id_develtype$i;project$s;name$s;dt_beg$d;dt_plan$d;dt_end$d;id_status$i;cnt$f;comm$s;id_kns$i;time$f;slash$s';
  //соотвествующий им контролы, кроме левого - id
  Ctrls:=[Cb_DevelType, Cb_Project, Cb_Name, De_Beg, De_Plan, De_End, Cb_Status, Ne_Cnt, M_Comm, Cb_Kns, Ne_Time, Cb_Slash];
  //для добавления инициализация значений полей, для других режимов из запроса в базе
  if Mode = fAdd
    then v:=VarArrayOf([0,null,'','',Date,null,null,1,'','',null,null])
    else v:=Q.QSelectOneRow(Q.QSIUDSql('s', 'v_j_development', Fields), [ID]);
  if Mode = fCopy then v[4]:=Date;
  //не вернуло данных по этому айди - выход с сообщением
  if v[0] = null then begin MsgRecordIsDeleted; Exit; end;
  //загружаем комбобоксы
  Q.QLoadToDBComboBoxEh('select name, id from ref_develtypes order by name', [], Cb_DevelType, cntComboLK);
  Q.QLoadToDBComboBoxEh('select distinct project from j_development order by project', [], Cb_Project, cntComboE);
  Q.QLoadToDBComboBoxEh('select distinct name from j_development order by name', [], Cb_Name, cntComboE);
  Q.QLoadToDBComboBoxEh('select slash from v_order_items where id_order > 0 and qnt > 0 and dt_end is null order by slash', [], Cb_Slash, cntComboE);
  Cb_Slash.MaxLength:=25;
  //комбобокс статуса жестко прописан
  Cth.AddToComboBoxEh(Cb_Status, [
    ['новый', '1'],
    ['в работе', '2'],
    ['остановлен', '3'],
    ['на согласовании', '4'],
    ['завис', '5'],
    ['готово', '100']
  ]);
  //загрузим комбобокс конструкторов, так как для этого надо знать айди в таблице проектов, чтобы загрузить неактивного но который уже в ней есть
  Q.QLoadToDBComboBoxEh(
    'select name, id from adm_users where (job = :id_job$i and active = 1) or id = :id_old$i order by name asc',
    [myjobKNS, v[10]],
    Cb_Kns,
    cntComboLK
  );
  //установим значений контролов
  for i:=0 to High(Ctrls) do
    Cth.SetControlValue(Ctrls[i], v[i+1]);
  //параметры верификации контролов
  CtrlVerifications:=['1:400','1:400:0:T','1:400:0:T','1','1','','0:400','0:9999999:1','0:4000:0','0:400','0:9999999:1','0:25:0:T'];
  if v[7] = '100' then CtrlVerifications[5]:='1';
  //параметры проверки контролов установив для них
  Cth.SetControlsVerification(Ctrls, CtrlVerifications);
   //события onCahange и  onExit для всех dbeh контролов
  Cth.SetControlsOnChange(Self, ControlOnChange);
  Cth.SetControlsOnExit(Self, ControlOnExit);
  Cth.SetControlsOnCheckDrawRequired(Self, ControlCheckDrawRequiredState);
  //заголовок формы и кнопки в зависимости от режима
  Cth.SetDialogForm(Self, Mode, 'Позиция в разработке');
  //доступность контролов, в зависимости от режима, кроме дат начала/окончания - всегда дисейбл
  Cth.DlgSetControlsEnabled(Self, Mode, [De_Beg, De_End], [False, Cb_Status.Value = '100']);
//  De_Beg.Enabled:=False;
//  De_End.Enabled:=False;
  //первоначальная проверка
  Verify(nil);
  //инфо
  Info:=
  'Реадктирование журнала разработки.'#13#10+
  'Вид работы может быть выбран только из стандартных вариантов.'#13#10+
  'Проект и наименование могут быть любыми, но должны быть обязательно заданы.'#13#10+
  'Обязательно нужно установить статус.'#13#10+
  'Дата запуска проставляется автоматически при создании, а дата завершения - про установке статуса Готово.'#13#10+
  'Поля Сделка, Часы, Конструктор и Комментарий обязательными не являются.'#13#10
  ;
  if Mode in [fView, fDelete] then Info:='';
  Cth.SetInfoIcon(Img_Info, Info, 20);
  //чтобы форма не съезжала (расхлопывается при отображении на непонятный размер)
  //в дизайн-тайм ставим BorderStyle:=bsDialog, а для возможность растягивания меняем уже здесь на bsSizeable
  BorderStyle:=bsSizeable;
  StatusBar.Visible:=False;
//  if Cb_DevelType.Enabled then Cb_DevelType.SetFocus;
//  PreventResize:=False;
//  Width:=MinWidth;
//  Height:=MinHeight;)*
  Result:= True;
end;
*)

end.
