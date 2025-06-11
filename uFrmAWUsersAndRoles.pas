unit uFrmAWUsersAndRoles;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, V_MDI, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, uSettings, uString, PrnDbgEh, DBCtrlsEh, Types, uData, uMessages, uForms, uDBOra, uFrmBasicMdi,
  uFrDBGridEh, Vcl.Mask
  ;

type
  TFrmAWUsersAndRoles = class(TFrmBasicMdi)
    PageControl1: TPageControl;
    TsRoles: TTabSheet;
    TsUsers: TTabSheet;
    FrgUsers: TFrDBGridEh;
    PRight: TPanel;
    PUserData: TPanel;
    PRTop: TPanel;
    FrgUserRoles: TFrDBGridEh;
    E_Name: TDBEditEh;
    E_Login: TDBEditEh;
    E_Pwd: TDBEditEh;
    E_Pwd2: TDBEditEh;
    Cb_Job: TDBComboBoxEh;
    E_EMail: TDBEditEh;
    Chb_EMailAuto: TDBCheckBoxEh;
    Chb_AutoLogin: TDBCheckBoxEh;
    Chb_Active: TDBCheckBoxEh;
    E_JobComm: TDBEditEh;
    Ne_Idle: TDBNumberEditEh;
    Chb_ChPwd: TDBCheckBoxEh;
    FrgRoles: TFrDBGridEh;
    Panel1: TPanel;
    FrgRights: TFrDBGridEh;
    procedure BtUserSaveClick(Sender: TObject);
    procedure ControlOnChange(Sender: TObject); override;
    procedure FrgUsersMemTableEh1AfterScroll(DataSet: TDataSet);
    procedure FrgRolesMemTableEh1AfterScroll(DataSet: TDataSet);
  private
    EmailDomain: string;
    UMode: TDialogType;
    LastUserID: Integer;
    LastRoleID: Integer;
    RightsOld: string;
    IsRightsChanged: Boolean;
    InFrgRolesAfterScroll: Boolean;
    function  Prepare: Boolean; override;
    procedure LoadUser;
    function  SaveUser(AMode: TDialogType): Boolean;
    procedure LoadRole;
    procedure SaveRole;
    function  GetRightsStr: string;
    procedure SetEmailAddr;
  protected
    procedure FrgUsersButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); virtual;
    procedure FrgRolesButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); virtual;
    procedure FrgRolesCellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); virtual;
    procedure FrgRightsButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); virtual;
    procedure FrgRightsColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); virtual;
    procedure FrgRightsSelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); virtual;
  public
  end;

var
  FrmAWUsersAndRoles: TFrmAWUsersAndRoles;

implementation

{$R *.dfm}


procedure TFrmAWUsersAndRoles.ControlOnChange(Sender: TObject);
begin
  if A.InArray(TControl(Sender).Name, ['Chb_EMailAuto', 'E_Login']) then
    SetEmailAddr;
  if TControl(Sender).Name = 'Chb_ChPwd' then begin
    if Chb_ChPwd.Checked then
      Exit;
    E_Pwd.Enabled := True;
    E_Pwd2.Enabled := True;
    E_Pwd.Text := '';
    E_Pwd2.Text := '';
  end;
end;

procedure TFrmAWUsersAndRoles.SetEmailAddr;
begin
  if Chb_EMailAuto.Checked then begin
    E_EMail.Text:= E_Login.Text + '@' + EmailDomain;
  end
  else begin
  end;
  E_EMail.Readonly:= Chb_EMailAuto.Checked;
end;

procedure TFrmAWUsersAndRoles.LoadUser;
var
  v: TVarDynArray;
  va2: TVarDynArray2;
  i, j: integer;
begin
  v:= Q.QSelectOneRow(
    'select name, login, decode(pwd, null, '''', 111), active, autologin, job, email, emailauto, job_comm, idletime from adm_users where id = :id$i',
    [S.IIf(UMode = fAdd, -9999, FrgUsers.Id)]
  );
  E_Name.Value:=v[0];
  E_Login.Value:=v[1];
  E_Pwd.Value:=v[2];
  E_Pwd2.Value:=v[2];
  Cth.SetControlValue(Chb_Active, v[3]);
  Cth.SetControlValue(Chb_AutoLogin, v[4]);
  Cb_Job.ItemIndex:=S.IIf(v[5] = null, -1, v[5]);
  Cth.SetControlValue(E_EMail, v[6]);
  Cth.SetControlValue(Chb_EMailAuto, v[7]);
  Cth.SetControlValue(E_JobComm, v[8]);
  Cth.SetControlValue(Ne_Idle, v[9]);
  Chb_ChPwd.Checked := UMode in [fAdd, fCopy];
  E_Pwd.Enabled := Chb_ChPwd.Checked;
  E_Pwd2.Enabled := Chb_ChPwd.Checked;
  SetEmailAddr;
  va2 := Q.QLoadToVarDynArray2('select id_role from adm_user_roles where id_user = :id$i', [S.IIf(UMode = fAdd, -9999, FrgUsers.Id)]);
  for i := 0 to FrgUserRoles.GetCount(False) - 1 do
    FrgUserRoles.SetValue('value', i, False, S.IIf(A.PosInArray(FrgUserRoles.GetValue('id', i, False), va2, 0) >= 0, 1, 0));
  FrgUserRoles.DbGridEh1.Repaint;
end;

procedure TFrmAWUsersAndRoles.BtUserSaveClick(Sender: TObject);
begin
  if TButton(Sender).Tag = btnCancel then begin
  end
  else if not SaveUser(UMode) then
    Exit;
  PUserData.Enabled := False;
  FrgUserRoles.Opt.SetColFeature('value', 'e', False, True);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(FrgUsers, btnEdit, null, True);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(FrgUsers, btnAdd, null, True);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(FrgUsers, btnCopy, null, True);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(FrgUsers, btnDelete, null, True);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Self, btnOk, 'Сохранить', False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Self, btnCancel, null, False);
  FrgUsers.RefreshGrid;
end;


function TFrmAWUsersAndRoles.SaveUser(AMode: TDialogType): Boolean;
var
  id, id1, res, i, j, emailauto: Integer;
  st, email: string;
  b: Boolean;
begin
  Result:=False;
  st := '';
  if E_Name.value = '' then st := st + 'Имя должно быть задано'#10#13;
  if E_Login.value = '' then st := st + 'Логин должен быть задан'#10#13;
  if E_Pwd.value <> E_Pwd2.value then st := st + 'Пароли не совпадают'#10#13;
  if (E_EMail.Text = '') or not S.IsValidEmail(E_EMail.Text) then st := st + 'Некорретный почтовый адрес'#10#13;
  if St <> '' then begin
    myWarningMessage(st);
    Exit;
  end;

  Q.QBeginTrans(True);
  id:= FrgUsers.ID;
  email := E_EMail.Text;
  emailauto := S.IIf(Chb_EMailAuto.Checked, 1, 0);
  if E_EMail.Text = E_Login.Text + '@' + EmailDomain then begin
    email := '';
    emailauto := 1;
  end;
  res := Q.QIUD(VartoStr(S.IIf(UMode = fEdit, 'u', S.IIf((UMode = fAdd) or (UMode = fCopy), 'i', 'd')))[1],
    'adm_users', 'sq_adm_users', 'id;name;login;active;autologin;job;email;emailauto;job_comm;idletime',
    [id, E_Name.value, E_login.value, Cth.GetControlValue(Chb_Active), Cth.GetControlValue(Chb_AutoLogin),
    Cb_Job.ItemIndex, email, emailauto, Cth.GetControlValue(E_JobComm), Cth.GetControlValue(Ne_Idle)
    ], True
  );
  if (UMode = fAdd) or (UMode = fCopy) then id:= Res;
  if Chb_ChPwd.Checked then
    Q.QExecSql('update adm_users set pwd = get_hash_val(:pwd$s) where id = :id', [E_Pwd.value, ID]);
  Res:=Q.QExecSql('delete from adm_user_roles where id_user = :id', [id]);
  if UMode<> fDelete then
    for i := 0 to FrgUserRoles.GetCount(False) - 1 do begin
      b:= FrgUserRoles.GetValue('value', i, False) = 1;
      j:= FrgUserRoles.GetValue('id', i, False);
      if b then res:=Q.QExecSql('insert into adm_user_roles (id_user, id_role) values (:id_user, :id_role)', [id, j]);
    end;
  Q.QCommitTrans;
  Result := Q.CommitSuccess;
  if Result
    then begin
      FrgUsers.RefreshGrid;
      FrgUsers.MemTableEh1.Locate('id', id, []);
    end
    else MyWarningMessage('Ошибка сохранения данных!');
end;

procedure TFrmAWUsersAndRoles.LoadRole();
var
  i, j: Integer;
  va2: TVarDynArray2;
begin
  if not FrgRights.IsPrepared then
    Exit;
  Cth.SetControlValue(FrgRights, 'LbRoleName', 'Роль: ' + FrgRoles.GetValue('name'));
  LastRoleID := FrgRoles.ID;
  va2 := Q.QLoadToVarDynArray2('select rights from adm_roles where id=:id$i', [LastRoleID]);
  for i := 0 to FrgRights.GetCount(False) - 1 do
    if S.InCommaStr(FrgRights.GetValue('rname', i, False), VarToStr(va2[0][0]))
      then FrgRights.SetValue('value', i, False, 1)
      else FrgRights.SetValue('value', i, False, 0);
  FrgRights.RefreshGrid;
  FrgRights.DbGridEh1.Repaint;
  RightsOld := GetRightsStr;
  IsRightsChanged := False;
//  Cth.SetButtonsAndPopupMenuCaptionEnabled(FrgRights, btnOk, null, False);
//  Cth.SetButtonsAndPopupMenuCaptionEnabled(FrgRights, btnCancel, null, False);
end;

procedure TFrmAWUsersAndRoles.SaveRole();
begin
  Q.QExecSql('update adm_roles set rights = :rights$s where id = :id$i', [GetRightsStr, LastRoleID]);
  FrgRights.RefreshGrid;
  FrgRights.DbGridEh1.Repaint;
  RightsOld := GetRightsStr;
end;

function TFrmAWUsersAndRoles.GetRightsStr: string;
var
  i: Integer;
  va: TVarDynArray;
begin
  va := [];
  Result := '';
  for i := 0 to FrgRights.GetCount(False) - 1 do
    if FrgRights.GetValue('value', i, False) = 1
      then va := va +[FrgRights.GetValue('rname', i, False)];
  A.VarDynArraySort(va);
  Result := A.Implode(va, ',');
end;


procedure TFrmAWUsersAndRoles.FrgRolesMemTableEh1AfterScroll(DataSet: TDataSet);
var
  Res: Integer;
begin
  if not FrgRoles.IsPrepared or not FrgRights.IsPrepared or FrgRoles.InLoadData or InFrgRolesAfterScroll then
    Exit;
  InFrgRolesAfterScroll := True;
  inherited;
  if (GetRightsStr <> RightsOld) then begin
    Res := MyMessageDlg('Права доступа были изменены. Сохранить?', mtConfirmation, [mbYes, mbNo, mbCancel]);
    if Res = mrCancel then begin
       FrgRoles.MemTableEh1.Locate('id', LastRoleID, []);
    end
    else begin
      if Res = mrYes then SaveRole;
      LoadRole;
      LastRoleID := FrgRoles.ID;
    end;
  end
  else
   if LastRoleID <> FrgRoles.ID then begin
    LoadRole;
    LastRoleID := FrgRoles.ID;
  end;
  InFrgRolesAfterScroll := False;
end;

procedure TFrmAWUsersAndRoles.FrgUsersMemTableEh1AfterScroll(DataSet: TDataSet);
begin
  inherited;
  FrgUsers.MemTableEh1AfterScroll(DataSet);
  UMode := fNone;
  LoadUser;
end;

procedure TFrmAWUsersAndRoles.FrgUsersButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
var
  v: Variant;
begin
  if Tag in [btnEdit, btnAdd, btnCopy, btnDelete] then begin
    PUserData.Enabled := Tag <> btnDelete;
    FrgUserRoles.Opt.SetColFeature('value', 'e', True, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(FrgUsers, btnEdit, null, False);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(FrgUsers, btnAdd, null, False);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(FrgUsers, btnCopy, null, False);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(FrgUsers, btnDelete, null, False);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Self, btnOk, S.Decode([Tag, btnEdit, 'Изменить', btnAdd, 'Добавить', btnCopy, 'Скопировать', btnDelete, 'Удалить']), True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Self, btnCancel, null, True);
    UMode := Cth.BtnModeToFMode(Tag);
    LoadUser;
 end;
end;

procedure TFrmAWUsersAndRoles.FrgRolesButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
var
  i, j, k, idr: Integer;
  st: string;
  va2: TVarDynArray2;
  b: Boolean;
begin
  if FrgRoles.ID <= 0 then
    Exit;
  idr := FrgRoles.ID;
  if Tag = btnCopy then begin
    va2 := Q.QLoadToVarDynArray2('select id, name, rights from adm_roles where id = :id$i', [FrgRoles.ID]);
    idr := Q.QIUD('i', 'adm_roles', 'sq_adm_roles', 'id$i;name$s;rights$s', [-100, va2[0][1] + ' (копия)', va2[0][2]]);
    b := True;
  end;
  if Tag = btnAdd then begin
    idr := Q.QIUD('i', 'adm_roles', 'sq_adm_roles', 'id$i;name$s;rights$s', [-100, 'Новая роль', '']);
    b := True;
  end;
  if Tag = btnDelete then begin
    if MyQuestionMessage('Удалить роль?') <> mrYes then
      Exit;
    idr := Q.QIUD('d', 'adm_roles', '', 'id$i', [FrgRoles.ID]);
    b := True;
  end;
  if not b then
    Exit;
  va2 := Q.QLoadToVarDynArray2('select id, name, rights from adm_roles order by name', []);
  FrgRoles.LoadSourceDataFromArray(va2, '', True);
  FrgRoles.RePaint;
  FrgRoles.MemTableEh1.Locate('id', idr, []);
end;

procedure TFrmAWUsersAndRoles.FrgRolesCellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
var
  idr: Integer;
  va2: TVarDynArray2;
begin
  idr := FrgRoles.ID;
  if idr <= 0 then
    Exit;
  Q.QExecSql('update adm_roles set name = :name$s where id = :id$i', [Value, idr]);
  va2 := Q.QLoadToVarDynArray2('select id, name, rights from adm_roles order by name', []);
  FrgRoles.LoadSourceDataFromArray(va2, '', True);
  FrgRoles.RePaint;
  FrgRoles.MemTableEh1.Locate('id', idr, []);
end;

procedure TFrmAWUsersAndRoles.FrgRightsButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if Tag = btnOk then
    SaveRole;
  if Tag = btnCancel then
    LoadRole;
  if Tag = 1000 then begin
    //кнопка группироки, со статусом нажата/отжата (меняется автоматически, им не управляем)
    //инвертируем статус группировки
    Fr.DbGridEh1.DataGrouping.Active := not Fr.DbGridEh1.DataGrouping.Active;
    //разрешгим редактирование только в режиме группировки
    Fr.Opt.SetColFeature('qnt_in_demand', 'e', Fr.DbGridEh1.DataGrouping.Active, True);
    Fr.ChangeSelectedData;
  end;
  if Tag = 1001 then begin
    //схлопнем все группы на всех уровнях
    Gh.AllGroupsExpandCollapse(Fr.DbGridEh1, 1, True);
  end;
  if Tag = 1002 then begin
    //раскроем все группы на всех уровнях
    Gh.AllGroupsExpandCollapse(Fr.DbGridEh1, 1, False);
  end;
end;

procedure TFrmAWUsersAndRoles.FrgRightsColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
var
  b : Boolean;
begin
  Fr.SetValue('value', Value);
  Handled := True;
  IsRightsChanged := RightsOld <> GetRightsStr;
end;

procedure TFrmAWUsersAndRoles.FrgRightsSelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
//  Cth.SetButtonsAndPopupMenuCaptionEnabled(FrgRights, btnOk, null, IsRightsChanged);
//  Cth.SetButtonsAndPopupMenuCaptionEnabled(FrgRights, btnCancel, null, IsRightsChanged);
end;



function TFrmAWUsersAndRoles.Prepare: Boolean;
var
  i, j: Integer;
  st, g1, g2: string;
  va2: TVarDynArray2;
begin
  Result := False;
  Caption := 'Пользователи и роли';
  Mode:= fNone;
  Cth.MakePanelsFlat(PMDIClient, []);
  for i:=0 to High(MyJobNames) do
    Cb_Job.Items.Add(MyJobNames[i]);

  EmailDomain:=Q.QSelectOneRow('select emaildomain from adm_main_settings', [])[0];

  FrgUsers.Options:= FrDBGridOptionDef + FrDBGridOptionRefDef + [myogGridLabels];
  FrgUsers.OnButtonClick := FrgUsersButtonClick;
  FrgUsers.Opt.SetFields([
    ['id$i','_id','20'],
    ['name','Имя','180;w'],
    ['login','Логин','80'],
    ['comm','Примечание','220;w']
  ]);
  FrgUsers.Opt.SetTable('v_users');
  FrgUsers.Opt.SetWhere('where id > 0 order by name');
  FrgUsers.Opt.Caption := 'Пользователи';
  FrgUsers.Opt.SetButtons(1,[[btnEdit],[btnAdd],[btnCopy],[btnDelete]]);
  FrgUsers.Prepare;

  FrgUserRoles.Options:= FrDBGridOptionDef + FrDBGridOptionRefDef;
  FrgUserRoles.Opt.SetFields([
    ['id$i','_id','20'],
    ['name$s','Роль','180;w'],
    ['value$i','х','25','chb']
  ]);
  FrgUserRoles.Opt.Caption := 'Роли пользователя';
  FrgUserRoles.Opt.SetDataMode(myogdmFromArray);
  FrgUserRoles.Prepare;
  va2 := Q.QLoadToVarDynArray2('select id, name, 0 as value from adm_roles order by name', []);
  FrgUserRoles.LoadSourceDataFromArray(va2, '', True);

  PRTop.Height := FrgUsers.PTop.Height;
  Cth.CreateButtons(PRTop, [[btnToAlRight],[btnOk, True, False, 130, 'Сохранить'],[btnCancel, True, False, 130, 'Отменить']], BtUserSaveClick);

  Cth.AlignControls(PUserData, [], True);

  FrgUsers.RefreshGrid;
  PUserData.Enabled := False;

  FrgRoles.Options:= FrDBGridOptionDef + FrDBGridOptionRefDef + [myogGridLabels];
  FrgRoles.OnButtonClick := FrgRolesButtonClick;
  FrgRoles.OnCellValueSave := FrgRolesCellValueSave;
  FrgRoles.Opt.SetFields([
    ['id$i','_id','20'],
    ['name$s','Роль','180;w','e'],
    ['rights$s','_Права','180']
  ]);
  FrgRoles.Opt.Caption := 'Роли';
  FrgRoles.Opt.SetButtons(1,[[btnEdit],[btnAdd],[btnCopy],[btnDelete]]);
  FrgRoles.Opt.SetDataMode(myogdmFromArray);
  FrgRoles.Prepare;
  va2 := Q.QLoadToVarDynArray2('select id, name, rights from adm_roles order by name', []);
  FrgRoles.LoadSourceDataFromArray(va2, '', True);

  FrgRights.Options:= FrDBGridOptionDef + FrDBGridOptionRefDef + [myogGridLabels];
  FrgRights.OnButtonClick := FrgRightsButtonClick;
  FrgRights.OnColumnsUpdateData := FrgRightsColumnsUpdateData;
  FrgRights.OnSelectedDataChange := FrgRightsSelectedDataChange;
  FrgRights.Opt.SetFields([
    ['id$i','_id','20'],
    ['group1$s','Категория','200'],
    ['group2$s','Документ','200'],
    ['name$s','Права','200;w'],
    ['value$i','х','25','e','chb'],
    ['rname$s','_rname','100;w'],
    ['rindex$i','_i','20']
  ]);
  FrgRights.Opt.Caption := 'Права доступа';
  FrgRights.Opt.SetButtons(1, [
    [1000, True, -90, 'Группировка', 'grouping'], [1001, True, 'Раскрыть все', 'expand'], [1002, True, 'Схлопнуть все', 'collapse'], [], [btnCtlPanel],
    [btnToAlRight],[btnOk, True, False, 130, 'Сохранить'],[btnCancel, True, False, 130, 'Отменить']]
  );
  FrgRights.Opt.SetButtonsIfEmpty([btnOk, btnCancel]);
  FrgRights.CreateAddControls('1', cntLabel, 'Текст', 'LbRoleName', '', 4, yrefC, 200);

  FrgRights.Opt.SetGrouping(['group1', 'group2'], [], [clGradientActiveCaption, clGradientInactiveCaption], True);

  FrgRights.Opt.SetDataMode(myogdmFromArray);
  FrgRights.Prepare;
  va2 := [];
  for i := Low(Urights) to High(URights) do begin
    if URights[i][1]<>'' then g1:=URights[i][1];
    if URights[i][2]<>'' then g2:=URights[i][2];
    va2 := va2 + [[i, g1, g2, URights[i][3], 0, URights[i][0], i]];
  end;
  FrgRights.LoadSourceDataFromArray(va2, '', True);

  FrgRoles.MemTableEh1.First;
  LoadRole;

  Result:= True;
end;


end.
