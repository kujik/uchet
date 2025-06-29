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
    pnlRight: TPanel;
    pnlUserData: TPanel;
    pnlRTop: TPanel;
    FrgUserRoles: TFrDBGridEh;
    edtname: TDBEditEh;
    edtLogin: TDBEditEh;
    edtPwd: TDBEditEh;
    edtPwd2: TDBEditEh;
    cmbJob: TDBComboBoxEh;
    edtEMail: TDBEditEh;
    chbEMailAuto: TDBCheckBoxEh;
    chbAutoLogin: TDBCheckBoxEh;
    chbActive: TDBCheckBoxEh;
    edtJobComm: TDBEditEh;
    nedtIdle: TDBNumberEditEh;
    chbChPwd: TDBCheckBoxEh;
    FrgRoles: TFrDBGridEh;
    pnl1: TPanel;
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
  if A.InArray(TControl(Sender).Name, ['chbEMailAuto', 'edtLogin']) then
    SetEmailAddr;
  if TControl(Sender).Name = 'chbChPwd' then begin
    if chbChPwd.Checked then
      Exit;
    edtPwd.Enabled := True;
    edtPwd2.Enabled := True;
    edtPwd.Text := '';
    edtPwd2.Text := '';
  end;
end;

procedure TFrmAWUsersAndRoles.SetEmailAddr;
begin
  if chbEMailAuto.Checked then begin
    edtEMail.Text:= edtLogin.Text + '@' + EmailDomain;
  end
  else begin
  end;
  edtEMail.Readonly:= chbEMailAuto.Checked;
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
  edtname.Value:=v[0];
  edtLogin.Value:=v[1];
  edtPwd.Value:=v[2];
  edtPwd2.Value:=v[2];
  Cth.SetControlValue(chbActive, v[3]);
  Cth.SetControlValue(chbAutoLogin, v[4]);
  cmbJob.ItemIndex:=S.IIf(v[5] = null, -1, v[5]);
  Cth.SetControlValue(edtEMail, v[6]);
  Cth.SetControlValue(chbEMailAuto, v[7]);
  Cth.SetControlValue(edtJobComm, v[8]);
  Cth.SetControlValue(nedtIdle, v[9]);
  chbChPwd.Checked := UMode in [fAdd, fCopy];
  edtPwd.Enabled := chbChPwd.Checked;
  edtPwd2.Enabled := chbChPwd.Checked;
  SetEmailAddr;
  va2 := Q.QLoadToVarDynArray2('select id_role from adm_user_roles where id_user = :id$i', [S.IIf(UMode = fAdd, -9999, FrgUsers.Id)]);
  for i := 0 to FrgUserRoles.GetCount(False) - 1 do
    FrgUserRoles.SetValue('value', i, False, S.IIf(A.PosInArray(FrgUserRoles.GetValue('id', i, False), va2, 0) >= 0, 1, 0));
  FrgUserRoles.DbGridEh1.Repaint;
end;

procedure TFrmAWUsersAndRoles.BtUserSaveClick(Sender: TObject);
begin
  if TButton(Sender).Tag = mbtCancel then begin
  end
  else if not SaveUser(UMode) then
    Exit;
  pnlUserData.Enabled := False;
  FrgUserRoles.Opt.SetColFeature('value', 'e', False, True);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(FrgUsers, mbtEdit, null, True);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(FrgUsers, mbtAdd, null, True);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(FrgUsers, mbtCopy, null, True);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(FrgUsers, mbtDelete, null, True);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Self, mbtOk, 'Сохранить', False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Self, mbtCancel, null, False);
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
  if edtname.value = '' then st := st + 'Имя должно быть задано'#10#13;
  if edtLogin.value = '' then st := st + 'Логин должен быть задан'#10#13;
  if edtPwd.value <> edtPwd2.value then st := st + 'Пароли не совпадают'#10#13;
  if (edtEMail.Text = '') or not S.IsValidEmail(edtEMail.Text) then st := st + 'Некорретный почтовый адрес'#10#13;
  if St <> '' then begin
    myWarningMessage(st);
    Exit;
  end;

  Q.QBeginTrans(True);
  id:= FrgUsers.ID;
  email := edtEMail.Text;
  emailauto := S.IIf(chbEMailAuto.Checked, 1, 0);
  if edtEMail.Text = edtLogin.Text + '@' + EmailDomain then begin
    email := '';
    emailauto := 1;
  end;
  res := Q.QIUD(VartoStr(S.IIf(UMode = fEdit, 'u', S.IIf((UMode = fAdd) or (UMode = fCopy), 'i', 'd')))[1],
    'adm_users', 'sq_adm_users', 'id;name;login;active;autologin;job;email;emailauto;job_comm;idletime',
    [id, edtname.value, edtlogin.value, Cth.GetControlValue(chbActive), Cth.GetControlValue(chbAutoLogin),
    cmbJob.ItemIndex, email, emailauto, Cth.GetControlValue(edtJobComm), Cth.GetControlValue(nedtIdle)
    ], True
  );
  if (UMode = fAdd) or (UMode = fCopy) then id:= Res;
  if chbChPwd.Checked then
    Q.QExecSql('update adm_users set pwd = get_hash_val(:pwd$s) where id = :id', [edtPwd.value, ID]);
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
//  Cth.SetButtonsAndPopupMenuCaptionEnabled(FrgRights, mbtOk, null, False);
//  Cth.SetButtonsAndPopupMenuCaptionEnabled(FrgRights, mbtCancel, null, False);
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
  if Tag in [mbtEdit, mbtAdd, mbtCopy, mbtDelete] then begin
    pnlUserData.Enabled := Tag <> mbtDelete;
    FrgUserRoles.Opt.SetColFeature('value', 'e', True, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(FrgUsers, mbtEdit, null, False);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(FrgUsers, mbtAdd, null, False);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(FrgUsers, mbtCopy, null, False);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(FrgUsers, mbtDelete, null, False);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Self, mbtOk, S.Decode([Tag, mbtEdit, 'Изменить', mbtAdd, 'Добавить', mbtCopy, 'Скопировать', mbtDelete, 'Удалить']), True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Self, mbtCancel, null, True);
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
  if Tag = mbtCopy then begin
    va2 := Q.QLoadToVarDynArray2('select id, name, rights from adm_roles where id = :id$i', [FrgRoles.ID]);
    idr := Q.QIUD('i', 'adm_roles', 'sq_adm_roles', 'id$i;name$s;rights$s', [-100, va2[0][1] + ' (копия)', va2[0][2]]);
    b := True;
  end;
  if Tag = mbtAdd then begin
    idr := Q.QIUD('i', 'adm_roles', 'sq_adm_roles', 'id$i;name$s;rights$s', [-100, 'Новая роль', '']);
    b := True;
  end;
  if Tag = mbtDelete then begin
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
  if Tag = mbtOk then
    SaveRole;
  if Tag = mbtCancel then
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
//  Cth.SetButtonsAndPopupMenuCaptionEnabled(FrgRights, mbtOk, null, IsRightsChanged);
//  Cth.SetButtonsAndPopupMenuCaptionEnabled(FrgRights, mbtCancel, null, IsRightsChanged);
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
  Cth.MakePanelsFlat(pnlFrmClient, []);
  for i:=0 to High(MyJobNames) do
    cmbJob.Items.Add(MyJobNames[i]);

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
  FrgUsers.Opt.SetButtons(1,[[mbtEdit],[mbtAdd],[mbtCopy],[mbtDelete]]);
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

  pnlRTop.Height := FrgUsers.pnlTop.Height;
  Cth.CreateButtons(pnlRTop, [[mbtToAlRight],[mbtOk, True, False, 130, 'Сохранить'],[mbtCancel, True, False, 130, 'Отменить']], BtUserSaveClick);

  Cth.AlignControls(pnlUserData, [], True);

  FrgUsers.RefreshGrid;
  pnlUserData.Enabled := False;

  FrgRoles.Options:= FrDBGridOptionDef + FrDBGridOptionRefDef + [myogGridLabels];
  FrgRoles.OnButtonClick := FrgRolesButtonClick;
  FrgRoles.OnCellValueSave := FrgRolesCellValueSave;
  FrgRoles.Opt.SetFields([
    ['id$i','_id','20'],
    ['name$s','Роль','180;w','e'],
    ['rights$s','_Права','180']
  ]);
  FrgRoles.Opt.Caption := 'Роли';
  FrgRoles.Opt.SetButtons(1,[[mbtEdit],[mbtAdd],[mbtCopy],[mbtDelete]]);
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
    [1000, True, -90, 'Группировка', 'grouping'], [1001, True, 'Раскрыть все', 'expand'], [1002, True, 'Схлопнуть все', 'collapse'], [], [mbtCtlPanel],
    [mbtToAlRight],[mbtOk, True, False, 130, 'Сохранить'],[mbtCancel, True, False, 130, 'Отменить']]
  );
  FrgRights.Opt.SetButtonsIfEmpty([mbtOk, mbtCancel]);
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
