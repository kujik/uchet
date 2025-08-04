unit uFrmMain;

{$I EhLib.Inc}

interface

uses
Windows, SysUtils, Classes, Graphics, Forms, Controls, Menus,
{$IFDEF EH_LIB_7} XPMan, {$ENDIF}
StdCtrls, Dialogs, Buttons, Messages, ExtCtrls, ComCtrls, StdActns, ActnList,
ToolWin, ImgList, DB, ADODB{, EhLibMTE}, DataDriverEh, DBGridEh, PrnDbgeh,
ADODataDriverEh, PropFilerEh, PropStorageEh, {EhLibADO, }AppEvnts, uUtils,
uErrors, psAPI, uForms, uMessages, uFrmXDsrvAuth, uSettings, Variants,
Vcl.Imaging.pngimage, System.ImageList, System.Actions, System.StrUtils,
Vcl.ActnMan, Vcl.ActnCtrls, uTasks, uString, uSys, Vcl.DBActns;

type
  TFrmMain = class(TForm)
    TimerSetStyle: TTimer;
    TimerSrvClose: TTimer;
    Timer1min: TTimer;
    TimerAfterMainShow: TTimer;
    StatusBar: TStatusBar;
    PrintDBGridEh1: TPrintDBGridEh;
    MainApplicationEvents: TApplicationEvents;
    TlbMain: TToolBar;
    lbl_GetTop: TLabel;
    lbl_GetBottom: TLabel;
    //�������� � �������������
    Img_Main: TImage;
    Desctop_Label: TLabel;
    MainMenu: TMainMenu;
    MM_Window: TMenuItem;
    MM_Window_Cascade: TMenuItem;
    MM_Window_Tile: TMenuItem;
    MM_Window_Arrange: TMenuItem;
    MM_Window_Minimize: TMenuItem;
    MM_Window_TileIVertical: TMenuItem;
    FormsList: TToolBar;
    AlsWindows: TActionList;
    Action1: TAction;
    DatasetPrior1: TDataSetPrior;
    WindowClose1: TWindowClose;
    WindowCascade1: TWindowCascade;
    WindowTileHorizontal1: TWindowTileHorizontal;
    WindowTileVertical1: TWindowTileVertical;
    WindowMinimizeAll1: TWindowMinimizeAll;
    WindowArrange1: TWindowArrange;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TimerAfterMainShowTimer(Sender: TObject);
    procedure Timer1minTimer(Sender: TObject);
    procedure TimerSetStyleTimer(Sender: TObject);
    procedure TimerSrvCloseTimer(Sender: TObject);
    procedure DBGridEhMenu_PrintClick(Sender: TObject);
    procedure DBGridEhMenu_ToExcelClick(Sender: TObject);
    procedure WndProc(var Message: TMessage); override;
    procedure MainApplicationEventsMessage(var Msg: tagMSG; var Handled: Boolean);
    procedure FormsToolButtonClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    AfterCreate: Boolean;
    AfterStart: Boolean;
    MenuDef : TVarDynArray2;
    procedure CreateGridIndicatorTitleMenu(Grid: TCustomDBGridEh; var PopupMenu: TPopupMenu);
    procedure CreateMainMenu;
    procedure ExecuteMainMenuItem(Sender: TObject);
    procedure DefineMainMenu;
  public
    AutoClose: Boolean;
    ApplicationQueryClose: Boolean;
    InFormClose: Boolean;
    MyMouse: TMouse;
    DeveloperMode: Boolean;
    procedure AfterUserLogged;
    procedure SetFormsToolButtonClick;
  end;

var
  FrmMain: TFrmMain;

var
  MainMemBlocks: Integer = -999999999;

var
  MainMemBlocksAfterStart: Integer;

implementation

{$R *.dfm}

uses
  uFrmXWAbout, uData, uDBOra, V_MDI,
  uFrmXDmsgNoConnection,
  uWindows, D_SetPassword,
  D_MainSettings, D_ModuleSettings, D_Rep_Smeta,
  F_Adm_Installer,

  uFrmADedtItmCopyRigths,

  uFrmTest,
  uFrmTest2,
  madExcept
  ;

var
  DBGridEhPrintIndicatorMenuItem: TDBGridEhMenuItem;
  DBGridEhToExcelIndicatorMenuItem: TDBGridEhMenuItem;
  DBGridEhSelectAllIndicatorMenuItem: TDBGridEhMenuItem;
  DBGridEhSelectNoneIndicatorMenuItem: TDBGridEhMenuItem;
  DBGridEhSelectInvIndicatorMenuItem: TDBGridEhMenuItem;
  DBGridEhSeparatorMenuItem: TDBGridEhMenuItem;

//��������� ���� � ����� ������� ������ BDGridEh
procedure TFrmMain.CreateGridIndicatorTitleMenu(Grid: TCustomDBGridEh; var PopupMenu: TPopupMenu);
begin
  DBGridEhCenter.IndicatorTitleMenus := []; //[itmCut, itmCopy, itmSelectAll];
  DBGridEhCenter.DefaultBuildIndicatorTitleMenu(Grid, PopupMenu);
  if DBGridEhSeparatorMenuItem = nil then
    DBGridEhSeparatorMenuItem := TDBGridEhMenuItem.Create(Screen);
  DBGridEhSeparatorMenuItem.Caption := '-';
  PopupMenu.Items.Add(DBGridEhSeparatorMenuItem);
  if DBGridEhPrintIndicatorMenuItem = nil then
    DBGridEhPrintIndicatorMenuItem := TDBGridEhMenuItem.Create(Screen);
  DBGridEhPrintIndicatorMenuItem.Caption := '������';
  DBGridEhPrintIndicatorMenuItem.OnClick := DBGridEhMenu_PrintClick;
  DBGridEhPrintIndicatorMenuItem.Enabled := True;
  PopupMenu.Items.Add(DBGridEhPrintIndicatorMenuItem);
  DBGridEhPrintIndicatorMenuItem.Grid := Grid;
  if DBGridEhToExcelIndicatorMenuItem = nil then
    DBGridEhToExcelIndicatorMenuItem := TDBGridEhMenuItem.Create(Screen);
  DBGridEhToExcelIndicatorMenuItem.Caption := '������� � Excel';
  DBGridEhToExcelIndicatorMenuItem.OnClick := DBGridEhMenu_ToExcelClick;
  DBGridEhToExcelIndicatorMenuItem.Enabled := True;
//  DBGridEhPrintIndicatorMenuItem.TitleMenu := itmCut;
  PopupMenu.Items.Add(DBGridEhToExcelIndicatorMenuItem);
  DBGridEhToExcelIndicatorMenuItem.Grid := Grid;
end;

//����� �������� �����
procedure TFrmMain.FormCreate(Sender: TObject);
var
  FilePath: string;
begin
  Screen.OnActiveFormChange := Wh.ActiveFormChange;
  //�������� ������ ��� ��������� ������� ��������� ������ ����� �� ������
  AfterCreate := True;
  AfterStart := True;
  TimerAfterMainShow.Enabled := True;
  TlbMain.Height := 0;
  //��������� ���� � ����������� �� ������
  //������� ����
  Menu := MainMenu;
  CreateMainMenu;
  //���������
  Caption := Application.Title;
  //������� �� �������� ����������
  Desctop_Label.Caption := Application.Title + '  ';
  if Q.TestDB then begin
    Desctop_Label.Caption := Application.Title + '  (����!!!)';
    Desctop_Label.Font.Color := clBlue;
    Desctop_Label.Font.Style := [fsBold, fsUnderline];
    Color := clMoneyGreen;
  end;
  FrmMain.StatusBar.Panels[0].Text := '';
  //����� ���������� - ��������� ���� ������
  DBGridEhCenter.OnBuildIndicatorTitleMenu := CreateGridIndicatorTitleMenu;
  //�������� ����� ������ ������������ (� ����� �� ����� ������� ���� ��� ������ ������������)
  AfterUserLogged;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  try
  //�������� ���������������� ��������� � ��
  //�������� �����, �.�. ������ �������� ������ ����� � ������ ���������� ��� ��� ����������, � ���� ������� ������ � �� ���
  //�������� ������� �����, �� ��� ������� ������ ���������� ������� ������
  Settings.Save;
  except
  end;
end;


//================================ ������� =======================================

procedure TFrmMain.Timer1minTimer(Sender: TObject);
//����������� ��� ������� ���������� ����� ������ ������� �����, �������� = 1 ������
begin
  //�������������� ��������� ���� ���� ������� � �������
  Module.CheckAutoexit;
  Module.AutoExitIfIdle;
end;

procedure TFrmMain.TimerAfterMainShowTimer(Sender: TObject);
begin
  TimerAfterMainShow.Enabled := False;
  AfterCreate := False;
  AfterStart := False;
  {$IFDEF SRV}
  if ParamCount <> 1 then
    Exit;
  if (Module.RunFromIDE) and (MyQuestionMessage('��������� ������ ' + ParamStr(1) + '?') <> mrYes) then
    Exit;
  Tasks.Run;
  {$ENDIF}
end;

procedure TFrmMain.TimerSetStyleTimer(Sender: TObject);
begin
  TimerSetStyle.Enabled := False;
  Wh.ExecReference(myfrm_Adm_UserInterface);
end;

procedure TFrmMain.TimerSrvCloseTimer(Sender: TObject);
//������ �������� ����������
begin
  Close;
end;

procedure TFrmMain.FormsToolButtonClick(Sender: TObject);
//���� �� �������� ���� � ������� �������� ���� - ��������� ���� � �� �������� ����
begin
  Wh.BringToFrontMDIForm(Sender);
end;

procedure TFrmMain.AfterUserLogged;
begin
  //��������� ������� ����
  CreateMainMenu;
  //��� ������������ � ������ ������ ����������
  FrmMain.StatusBar.Panels[1].Text := User.GetName + '    ';
  //������� � ���������� �������� ���� �� �������� ������������
  Settings.RestoreWindowPos(Self, 'uFrmMain');
end;

procedure TFrmMain.WndProc(var Message: TMessage);
//������� ���������
begin
  if Message.Msg = WM_SYSCOMMAND then
  begin
    case Message.WParam and $FFF0 of
      SC_CLOSE:
        begin
          ApplicationQueryClose := True;
{          if MessageDlg('������� ������� ����?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then
          begin
            Message.Result := 0;
            Exit;
          end;}
        end;
    end;
  end;
  inherited WndProc(Message);
end;

procedure TFrmMain.MainApplicationEventsMessage(var Msg: tagMSG; var Handled: Boolean);
//���������� �������
var
  DBGridEh: TDBGridEh;
  Step, i, j: Integer;
  CtrlAlShift: Boolean;

  function GET_WHEEL_DELTA_WPARAM(wp: longint): smallint;
  begin
    Result := Smallint(wp shr 16);
  end;

begin
  if (Msg.Message = WM_KEYDOWN) or (Msg.Message = WM_NCMOUSELEAVE) then begin
    Module.UserActivityTime := Now;
    Module.IsUserActive := True;
  end;
  if Msg.Message = WM_MOUSEWHEEL then begin
     //���������� �������� ����� - ���� ��� �������� ����, �� ����� �������������� � ������
    DBGridEh := GetCurrentDBGridEh;
    if (DBGridEh = nil) or not CheckKeyDown(VK_LCONTROL) then
      Exit;
    if GET_WHEEL_DELTA_WPARAM(Msg.wParam) > 0 then
      Step := 1
    else
      Step := -1;
    i := GetFontSize(DBGridEh.Font, Step);
    if i > 0 then begin
      DBGridEh.Font.Size := i;
      DBGridEh.Repaint;
    end;
    Handled := True;
  end;
  //���������� �������� ����������
  if Msg.Message = WM_KEYDOWN then begin
    CtrlAlShift := (GetKeyState(VK_CONTROL) < 0) and (GetKeyState(VK_SHIFT) < 0) and (GetKeyState(VK_MENU) < 0);
    //���������� ����� �������������� ������������ (����������� ���������� ��� ������� ��� ����� �������������)
    //�� Ctrl+Shift+Alt+F3
    if (Byte(msg.wParam) = VK_F3) and CtrlAlShift then begin
      FrmMain.DeveloperMode := not FrmMain.DeveloperMode;
      Handled := True;
    end
    else if (Char(msg.wParam) = 'C') and CtrlAlShift then begin
      Module.StartLeakChecking;
      Handled := True;
    end
    else if (Char(msg.wParam) = 'L') and CtrlAlShift then begin
      Module.SaveLeakReport;
      Handled := True;
    end
    else if (Char(msg.wParam) = 'D') and CtrlAlShift then begin
//      Handled := True;
    end;
  end;
end;

procedure TFrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: Integer;
begin
  InFormClose:= True;
  try
  FormsList.Free;
  FormsList := nil;
  for i := MdiChildCount - 1 downto 0 do
    MDIChildren[i].Close;
  Settings.SaveWindowPos(Self, 'uFrmMain');
  except
  end;
  InFormClose:= False;
end;

procedure TFrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  i: Integer;
  q: Integer;
begin
  q := Settings.InterfaceQuit;
  if AutoClose or not Module.IsUserActive then begin
    CanClose := True;
  end
  else if q = 0 then begin
    CanClose := True;
  end
  else if q = 1 then begin
//    CanClose := Wh.Windows.Count = 0;
  end
  else begin
{    for i := 0 to Wh.Windows.Count - 1 do
      if pos('Dlg_', Wh.Windows[i]) = 1 then
        CanClose := False;} //++
  end;
  if CanClose = False then
    CanClose := MyQuestionMessage('������� ����������?') = mrYes;
  ApplicationQueryClose := True;
end;

procedure TFrmMain.SetFormsToolButtonClick;
var
  i: Integer;
begin
  for i := 0 to FormsList.ButtonCount - 1 do
    FormsList.Buttons[i].OnClick := FormsToolButtonClick;
end;

//��������� ����� ������ ��� DBGridEh
procedure TFrmMain.DBGridEhMenu_PrintClick(Sender: TObject);
var
  st: string;
begin
  //��������� ����
  PrintDBGridEh1.DBGridEh := TDBGridEh((Sender as TDBGridEhMenuItem).Grid);
  //����������� ������� ����/�������, ����� �������� ������������ � ��������� (��������� ����-��������� �����)
  st := '';
  if PrintDBGridEh1.DBGridEh.Parent is TForm then
    st := TForm(PrintDBGridEh1.DBGridEh.Parent).Caption;
  PrintDBGridEh1.SetSubstitutes(['%[Today]', DateTimeToStr(Now), '%[UserName]', User.GetName, '%[Document]', Cth.GetParentForm(PrintDBGridEh1.DBGridEh).Caption]);
  PrintDBGridEh1.Preview;
end;

//��������� ����� ������� � ������ ��� DBGridEh
procedure TFrmMain.DBGridEhMenu_ToExcelClick(Sender: TObject);
var
  st: string;
  FileName: string;
  DBGridEh: TDBGridEh;
begin
  st := '';
  DBGridEh := TDBGridEh((Sender as TDBGridEhMenuItem).Grid);
  if DBGridEh.Parent is TForm then
    st := TForm(DBGridEh.Parent).Caption;
  FileName := Module.RunSaveDialog(stringreplace(st + ' ' + DateTimeToStr(Now), ':', '-', [rfReplaceAll]), 'xlsx');
  if FileName <> '' then
    Gh.ExportGridToXlsxNew(DBGridEh, FileName, True, st + ' ' + DateTimeToStr(Now), '');
end;

procedure TFrmMain.ExecuteMainMenuItem(Sender: TObject);
var
  MenuIndex: Integer;
  MenuIdent: string;
  MenuCaption: string;
begin
  MenuIndex := S.NInt(S.Right(TControl(Sender).Name, 3));
  MenuCaption:= MenuDef[MenuIndex][0];
  MenuIdent := S.IIfStr(S.NSt(MenuDef[MenuIndex][1])[1] = '_', Copy(S.NSt(MenuDef[MenuIndex][1])[1], 2), '-');
  if MenuIdent = '-' then
    Wh.ExecReference(MenuDef[MenuIndex][1])
  else begin
    if MenuCaption = '����' then
      TFrmXDsrvAuth.Execute(False)
    else if MenuCaption = '����� Oracle' then begin
      if MyQuestionMessage('���� ����������� �������� � ������ ���� ������, ���������� ��������� ��, ����� ����� "��"'#13#10 + '��������� ��������� �� �����, ������ � ��������� ����� ���������.') = mrYes then
        q.QExecSql('alter system flush shared_pool', []);
    end
    else if MenuCaption = '���� 1' then
      TFrmTest2.Show(Self, 'test', [myfoSizeable], fNone, 0, null)
//      TestProcedure1
//      FrmTest.Create(Self);
    else if MenuCaption = '���� 2' then
      TestProcedure2
    else if MenuCaption = '���� 3' then
      TestProcedure3
    else if MenuCaption = '������ ��������������' then
      Dlg_SetPassword.ShowDialog(1)
    else if MenuCaption = '������������� ������' then
      Dlg_SetPassword.ShowDialog(1)
    else if MenuCaption = '���������� ����� ������� ���' then
      FrmADedtItmCopyRigths.ShowDialog
    else if MenuCaption = '�������� ���������' then
      Dlg_MainSettings.ShowDialog
    else if MenuCaption = '��������� �������' then
      Dlg_ModuleSettings.ShowDialog
    else if MenuCaption = '����� �� ������������� �������' then
      Wh.ExecDialog(myfrm_Dlg_Rep_Order_Primecost2, Self, [], fNone, null, null)
    else if MenuCaption = '����� ������� �������' then
      Wh.ExecDialog(myfrm_Dlg_Or_FindNameInEstimates, Self, [], fNone, -1, null)
    else if MenuCaption = '���������� �� ���' then
      Wh.ExecDialog(myfrm_Dlg_Or_ItmInfo, Self, [myfoDialog, myfoOneCopy], fNone, -1, null)
    else if MenuCaption = '����� ����� �� ��������� �������' then
      Dlg_Rep_Smeta.ShowModal
    else if MenuCaption = '� ���������' then
      FrmXWAbout.ShowModal
    else if MenuCaption = '' then;
  end;
end;

procedure TFrmMain.CreateMainMenu;
var
  i, j, k : Integer;
  st : string;
  MainMenuItem, SubMenuItem: TMenuItem;
  IsLatItemDividor: Boolean;
  b: Boolean;

function CreateMenuItem(const ACaption, AName: string; AOnClick: TNotifyEvent): TMenuItem;
begin
  Result := TMenuItem.Create(MainMenu);
  Result.Caption := ACaption;
  Result.Name := AName;
  Result.OnClick := AOnClick;
  Result.Visible := True;
end;

begin
  DefineMainMenu;
  for i := MainMenu.Items.Count - 2 downto 0 do
    MainMenu.Items[i].Destroy;
  MainMenuItem := nil;
  SubMenuItem := nil;
  for i := 0 to High(MenuDef) do begin
    st := 'MmI' + S.Right('00' + IntToStr(i), 3);
    if Length(MenuDef[i]) = 1 then begin
      if (SubMenuItem <> nil) and (SubMenuItem.Caption = '-') then
        SubMenuItem.Destroy;
      if (MainMenuItem <> nil) and (MainMenuItem.Count = 0) then
        MainMenuItem.Destroy;
      MainMenuItem := CreateMenuItem(MenuDef[i][0], st, nil);
      MainMenu.Items.Insert(MainMenu.Items.Count - 1, MainMenuItem);
      IsLatItemDividor := True;
    end
    else if (Length(MenuDef[i]) = 0) then begin
      SubMenuItem := CreateMenuItem('-', st, nil);
      MainMenuItem.Add(SubMenuItem);
      IsLatItemDividor := True;
    end
    else begin
      if (High(MenuDef[i]) >= 2) and (MenuDef[i][2] = True) then begin
        SubMenuItem := CreateMenuItem(MenuDef[i][0], st, ExecuteMainMenuItem);
        MainMenuItem.Add(SubMenuItem);
        IsLatItemDividor := False;
      end;
    end;
  end;
  if (SubMenuItem <> nil) and (SubMenuItem.Caption = '-') then
    SubMenuItem.Destroy;
  if (MainMenuItem <> nil) and (MainMenuItem.Count = 0) then
    MainMenuItem.Destroy;
end;


procedure TFrmMain.DefineMainMenu;
begin
  MenuDef := [
    //����� ����
    ['='],
    ['����', '_', True],
    [],
    ['��������� ���������', myfrm_Adm_UserInterface, True],
    [],
    ['SQL �������', myfrm_Srv_SqlMonitor, True],
    ['����� Oracle', '_', True],
    [],
    ['�������� ����������', myfrm_R_Test, User.IsDeveloper],
    ['���� 1', '_', User.IsDeveloper],
    ['���� 2', '_', User.IsDeveloper],
    ['���� 3', '_', User.IsDeveloper],
    [],
    ['� ���������', '_', True],

    //�����������������
    {$IFDEF  ADMIN}
    ['�����������'],

    ['���� �����������', myfrm_R_Organizations, User.Role(rAdm_R_Organizations)],
    ['���� ������', myfrm_R_Locations, User.Role(rAdm_R_Locations)],
    ['���� ������������ �������', myfrm_R_CarTypes, User.Role(rAdm_R_Cartypes)],
    [],
    ['������ �����', myfrm_J_Tasks, True],

    ['������������ � ����'],
    ['������������ � ����', myfrm_F_UsersAndRoles, True], //!!!
    [],
    ['������ ��������������', '_', User.GetId = 0],
    ['������������� ������', '_', User.GetId = 0],
    [],
    ['���������� ����� ������� ���', '_', User.Role(rAdm_Itm_CopyUserRights)],

    ['���������'],
    ['�������� ���������', '_', User.Role(rAdm_Settings_Main)],
    ['��������� �������', '_', User.Role(rAdm_Settings_Modules)],

    ['������'],
    ['������������ ������', myfrm_Adm_DomainUsers, User.IsDeveloper],
    [],
    ['���������� ������� �����', myfrm_Adm_Installer, User.IsDeveloper],
    [],
    ['�������� ������ � ����� �� �������', myfrm_Adm_DeleteOnServer, User.Role(rAdm_Other_DeleteOnServer)],
    [],
    ['�������� ������', myfrm_Dlg_Adm_Sessions, User.Role(rAdm_Installer)],
    [],
    ['��� ������� ��', myfrm_Adm_Db_Log, User.IsDeveloper],
    ['������ ������', myfrm_J_Error_Log, User.IsDeveloper],
    [],
    ['������ �����', myfrm_J_Tasks, User.IsDeveloper],
    []
    {$ENDIF}

    {$IFDEF  PC}
    ['�����������'],
    ['������ ������ ��������', myfrm_R_GrExpenseItems, User.Roles([], [rPC_R_GrExp_V, rPC_R_GrExp_Ch])],
    ['������ ��������', myfrm_R_ExpenseItems, User.Roles([], [rPC_R_Exp_Access])],
    [],
    ['����������', myfrm_R_Suppliers, User.Roles([], [rPC_R_Sp_Access])],

    ['�������'],
    ['�����', myfrm_J_Accounts, User.Roles([], [rPC_A_VAll, rPC_A_VSelfCat, rPC_A_VSelf])],
    ['�������', myfrm_J_Payments, User.Roles([], [rPC_P_VAll, rPC_P_VSelfCat])],
    ['������� �� �������', myfrm_J_OrPayments, User.Roles([], [rPC_J_OrPayments_V, rPC_J_OrPayments_Ch])],

    ['�����'],
    ['������ �����1', myfrm_J_SnCalendar_Cash_1, User.Roles([], [rPC_J_Cash_1_V, rPC_J_Cash_1_Ch])],
    ['������ �����2', myfrm_J_SnCalendar_Cash_2, User.Roles([], [rPC_J_Cash_2_V, rPC_J_Cash_2_Ch])],
    ['������� �����', myfrm_Dlg_CashRevision, User.Roles([], [rPC_A_Cash_Revision_Ch, rPC_J_Cash_1_V, rPC_J_Cash_1_Ch, rPC_J_Cash_2_V, rPC_J_Cash_2_Ch])],

    ['������'],
    ['������� �� �����', myfrm_Rep_SnCalendarByDate, False],
    ['������� �� �������', myfrm_Rep_SnCalendarByMonths, User.Role(rPC_Rep_PmByMonths)],
    ['����� �� ������������ ������', myfrm_Rep_SnCalendar_Transport, User.Roles([], [rPC_Rep_Transport])],
    ['����� �� ������ ����������� �� �������', myfrm_Rep_SnCalendar_AccMontage, User.Roles([], [rPC_Rep_AccMontage])],
    []
    {$ENDIF}

    {$IFDEF  TURV}
    ['�����������'],
    ['���������', myfrm_R_Workers, User.Role(rW_R_Workers_V)],
    ['���������', myfrm_R_Jobs, User.Role(rW_R_Jobs_V)],
    ['����������� ����', myfrm_R_TurvCodes, User.Role(rW_R_TurvCode_V)],
    ['�������������', myfrm_R_Divisions, User.Role(rW_R_Divisions_V)],
    ['������� ������', myfrm_R_Work_Chedules, User.Roles([], [rW_R_Work_Chedules_V, rW_R_Work_Chedules_Ch])],
    [],
    ['���������������� ���������', myfrm_R_Holideys, User.Role(rW_R_Holideys_V)],

    ['�������'],
    ['������ ����', myfrm_J_Turv, User.Role(rW_J_Turv)],
    [],
    ['������� ����������', myfrm_J_WorkerStatus, User.Role(rW_J_WorkerStatus_V)],
    [],
    ['���������� ���������', myfrm_J_Payrolls, User.Roles([], [rW_J_Payroll_V, rW_J_Payroll_Ch])],
    [],
    ['��������', myfrm_J_Vacancy, User.Roles([], [rW_J_Vacancy_V, rW_J_Vacancy_Ch])],
    ['����������', myfrm_J_Candidates, User.Roles([], [rW_J_Candidates_V, rW_J_Candidates_Ch])],
    [],
    ['������ �������/����� ����������', myfrm_J_Parsec, User.Roles([], [rW_J_Parsec_V, rW_J_Parsec_V_All])],

    ['������'],
    ['���� �� ���������� ����������', myfrm_Rep_W_Payroll, User.Role(rW_Rep_Payroll)],
    ['����� �� ���������� ����������', myfrm_Rep_PayrollsSum, User.Role(rW_Rep_PayrollsSum)],
    [],
    ['������� ����������', myfrm_Rep_StaffSchedule, User.Roles([], [rW_Rep_StaffSchedule_V, rW_Rep_StaffSchedule_Ch_O, rW_Rep_StaffSchedule_Ch_C])],
    [],
    ['����� � �������� �������', myfrm_Rep_W_Personnel_1, User.Role(rW_Rep_Personnel_1)],
    ['����� �� ������� ���������', myfrm_Rep_W_Personnel_2, User.Role(rW_Rep_Personnel_2)],
    [],
    ['����� �� ���������� �����', myfrm_Rep_Salary, User.Roles([], [rW_Rep_Salary_V, rW_Rep_Salary_Ch])],
    []
    {$ENDIF}

    {$IFDEF OR}
    ['�����������'],
    ['������ bCAD', myfrm_R_Bcad_Groups, User.Roles([], [rOr_R_BCad_Groups_V, rOr_R_BCad_Groups_Ch])],
    ['������� ��������� bCAD', myfrm_R_Bcad_Units, User.Roles([], [rOr_R_BCad_Units_V, rOr_R_BCad_Units_Ch])],
    ['������� ��������� ���', myfrm_R_Itm_Units, User.Roles([], [rOr_R_Itm_Units_V, rOr_R_Itm_Units_Ch, rOr_R_Itm_Units_Del])],
    ['������� �������', myfrm_R_BCad_Nomencl, User.Roles([], [rOr_R_BCad_Nomencl_V])],
    ['������������ ���', myfrm_R_Itm_Nomencl, User.Roles([], [rOr_R_Itm_Nomencl_V])],
    ['���������� ������������', myfrm_R_EstimatesReplace, User.Roles([], [rOr_R_BCad_Replace_V, rOr_R_BCad_Replace_Ch])],
    [],
    ['������� �������', myfrm_R_StdProjects, User.Roles([], [rOr_R_StdProjects_V, rOr_R_StdProjects_Ch])],
    ['����������� ������� ���������', myfrm_R_StdPspFormats, User.Roles([], [rOr_R_StdPspFormats_V, rOr_R_StdPspFormats_Ch])],
    ['���� ���������', myfrm_R_OrderTypes, User.Role(rOr_R_OrderTypes_Ch)],
    ['���� ���������������� ��������', myfrm_R_WorkCellTypes, User.Role(rOr_R_WorkCellTypes_Ch)],
    [],
    ['����������� �������', myfrm_R_OrderStdItems, User.Roles([], [rOr_R_StdItems_V, rOr_R_StdItems_Ch, rOr_R_StdItems_Estimate])],
    ['������� �������', myfrm_R_OrderTemplates, User.Roles([], [rOr_R_Or_Templates_V, rOr_R_Or_Templates_Ch])],
    [],
    ['����������', myfrm_R_Itm_Suppliers, User.Roles([], [rOr_R_Itm_Suppliers_V, rOr_R_Itm_Suppliers_Ch, rOr_R_Itm_Suppliers_Del])],
    ['����������', myfrm_R_Customers, User.Roles([], [rOr_R_Customers_V, rOr_R_Customers_Ch]) and User.IsDeveloper and False], //!!!
    [],
    ['������� ����������', myfrm_R_complaintReasons, User.Roles([], [rOr_R_ComplaintReasons_V, rOr_R_ComplaintReasons_Ch])],
    ['������� �������� � ������������', myfrm_R_DelayedInprodReasons, User.Roles([], [rOr_R_DelayedInprodReasons_V, rOr_R_DelayedInprodReasons_Ch])],
    ['������� ��������� ���', myfrm_R_RejectionOtkReasons, User.Roles([], [rOr_R_RejectionOtkReasons_V, rOr_R_RejectionOtkReasons_Ch])],
    [],
    ['���������� ������ �� ���������', myfrm_R_Spl_Categoryes, User.Roles([], [rOr_R_Spl_Categoryes_V, rOr_R_Spl_Categoryes_Ch])],

    ['�������'],
    ['������ �����', myfrm_J_Tasks, True or User.Roles([], [rOr_J_Tasks_VAll, rOr_J_Tasks_Ch])],
    ['������ ����������', myfrm_J_Devel, User.Roles([], [rOr_J_Devel_V, rOr_J_Devel_Ch, rOr_J_Devel_Del])],
    [],
    ['�������� ������', myfrm_J_PlannedOrders, User.Roles([], [rOr_J_PlannedOrders_V, rOr_J_PlannedOrders_Ch])],
    ['������ �� �������������', myfrm_J_Semiproducts, User.Roles([], [rOr_J_Semiproducts_V, rOr_J_Semiproducts_Ch])],
    [],
    ['������', myfrm_J_Orders, User.Roles([], [rOr_J_Orders_V, rOr_J_Orders_V_Wo_Prices, rOr_D_Order_Ch])],
    [],
    ['������ ������ � ������������', myfrm_J_OrderStages_ToProd, User.Roles([], [rOr_J_OrderStages_ToProd_V, rOr_J_OrderStages_ToProd_Ch])],
    ['������ ��������� � ������������', myfrm_J_Or_DelayedInProd, User.Roles([], [rOr_J_DelayedInprod_V, rOr_J_DelayedInprod_Ch])],
    ['������ ������ ���', myfrm_J_OrderStages_Otk, User.Roles([], [rOr_J_OrderStages_Otk_V, rOr_J_OrderStages_Otk_Ch])],
    ['������ ��������� ����������� �� ���', myfrm_J_InvoiceToSgp, User.Roles([], [rOr_J_InvoiceToSGP_V, rOr_J_InvoiceToSgp_Ch_M, rOr_J_InvoiceToSgp_Ch_S])],
    ['������ ������ �� ���', myfrm_J_OrderStages_ToSgp, User.Roles([], [rOr_J_OrderStages_ToSgp_V, rOr_J_OrderStages_ToSgp_Ch])],
    ['������ �������� � ���', myfrm_J_OrderStages_FromSgp, User.Roles([], [rOr_J_OrderStages_FromSgp_V, rOr_J_OrderStages_FromSgp_Ch])],
    ['������ �������', myfrm_J_Or_Montage, User.Roles([], [rOr_J_OrderStages_Montage_V, rOr_J_OrderStages_Montage_Ch])],
    [],
    ['������� �� �������', myfrm_J_OrPayments, User.Roles([], [rOr_J_OrPayments_V, rOr_J_OrPayments_Ch])],
    ['������������� ������� �� �������', myfrm_J_OrPayments_N, User.Roles([], [rOr_J_OrPayments_N_V, rOr_J_OrPayments_N_Ch]) and False], //!!!

    ['������'],
    ['������� ��������� ��� (����������� �������)', myfrm_Rep_Sgp, User.Roles([], [rOr_Rep_Sgp_V])],
    ['������� ��������� ��� (������������� �������)', myfrm_Rep_Sgp2, User.Roles([], [rOr_Rep_Sgp_V])],
    [],
    ['������� ����������� � ����������', myfrm_Rep_PlannedMaterials, User.Roles([], [rOr_Rep_PlannedMaterials_V, rOr_Rep_PlannedMaterials_Calc])],
    [],
    ['���������� ����� �� �������', myfrm_Dlg_Rep_FinByOrders, User.Roles([], [rOr_Rep_Order_Fin1, rOr_Rep_Order_Fin2, rOr_Rep_Order_Fin3, rOr_Rep_Order_Fin4, rOr_Rep_Order_Fin5])],
    ['����� �� ������������� �������', '_', User.Roles([], [rOr_Rep_Order_Primecost1])],
    ['����� �� �����������', myfrm_Rep_Order_Complaints, User.Roles([], [rOr_Rep_Order_Complaints])],
    ['����� �� �������� � ������������', myfrm_J_OrItemSInProd, User.Role(rOr_Rep_OrItemSInProd)],
    ['����� �� �������� � �������', myfrm_Rep_SnCalendar_Orders_QntItems, User.Roles([], [rOr_Rep_Orders_QntItems])],
    ['����� ����� �� ��������� �������', User.Roles([], [rOr_Rep_Orders_QntItems])],

    ['������'],
    ['������������ ������ �� ���������', myfrm_R_MinRemains, User.Roles([], [rOr_Other_R_MinRemains_V, rOr_Other_R_MinRemains_Ch, rOr_Other_R_MinRemains_Ch_Suppl])],
    ['����������� �� ������� "����� �������"', myfrm_R_MinRemainsP, User.Roles([], [rOr_Other_R_MinRemainsI_V, rOr_Other_R_MinRemainsI_Ch1, rOr_Other_R_MinRemainsI_ChAll])],
    ['����������� �� ������� "����������"', myfrm_R_MinRemainsI, User.Roles([], [rOr_Other_R_MinRemainsI_V, rOr_Other_R_MinRemainsI_Ch1, rOr_Other_R_MinRemainsI_ChAll])],
    ['����������� �� ������� "���������"', myfrm_R_MinRemainsD, User.Roles([], [rOr_Other_R_MinRemainsI_V, rOr_Other_R_MinRemainsI_Ch1, rOr_Other_R_MinRemainsI_ChAll])],
    ['������������, �������� ����� ����', myfrm_Rep_ItmNomOverEstimate, User.Roles([], [rOr_Rep_ItmNomOverEstimate])],
    [],
    ['����� ������� �������', '_', User.Role(rOr_Other_Order_FindEstimate)],
    ['���������� �� ���', '_', User.Role(rOr_Other_ItmInfo)],
    ['������ �������� ������������� ���', myfrm_J_ItmLog, User.Role(rOr_Other_J_ItmLog)],
    ['����������� ���������� ������������ ITM', myfrm_R_Or_ItmExtNomencl, User.Role(rOr_Other_ItmExtNomencl)]
    {$ENDIF}
    {$IFDEF SRV}
    []
    {$ENDIF}
  ];
end;

initialization
end.



