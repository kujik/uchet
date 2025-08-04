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
    //картинка с калькулятором
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

//дефолтное меню в левой верхней ячейке BDGridEh
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
  DBGridEhPrintIndicatorMenuItem.Caption := 'Печать';
  DBGridEhPrintIndicatorMenuItem.OnClick := DBGridEhMenu_PrintClick;
  DBGridEhPrintIndicatorMenuItem.Enabled := True;
  PopupMenu.Items.Add(DBGridEhPrintIndicatorMenuItem);
  DBGridEhPrintIndicatorMenuItem.Grid := Grid;
  if DBGridEhToExcelIndicatorMenuItem = nil then
    DBGridEhToExcelIndicatorMenuItem := TDBGridEhMenuItem.Create(Screen);
  DBGridEhToExcelIndicatorMenuItem.Caption := 'Экспорт в Excel';
  DBGridEhToExcelIndicatorMenuItem.OnClick := DBGridEhMenu_ToExcelClick;
  DBGridEhToExcelIndicatorMenuItem.Enabled := True;
//  DBGridEhPrintIndicatorMenuItem.TitleMenu := itmCut;
  PopupMenu.Items.Add(DBGridEhToExcelIndicatorMenuItem);
  DBGridEhToExcelIndicatorMenuItem.Grid := Grid;
end;

//после создания формы
procedure TFrmMain.FormCreate(Sender: TObject);
var
  FilePath: string;
begin
  Screen.OnActiveFormChange := Wh.ActiveFormChange;
  //назначим таймер для обработки момента реального показа формы на экране
  AfterCreate := True;
  AfterStart := True;
  TimerAfterMainShow.Enabled := True;
  TlbMain.Height := 0;
  //перстроим меню в зависимости от модуля
  //главное меню
  Menu := MainMenu;
  CreateMainMenu;
  //заголовок
  Caption := Application.Title;
  //надпись на десктопе приложения
  Desctop_Label.Caption := Application.Title + '  ';
  if Q.TestDB then begin
    Desctop_Label.Caption := Application.Title + '  (ТЕСТ!!!)';
    Desctop_Label.Font.Color := clBlue;
    Desctop_Label.Font.Style := [fsBold, fsUnderline];
    Color := clMoneyGreen;
  end;
  FrmMain.StatusBar.Panels[0].Text := '';
  //опции дбэхгридов - дефолтное меню гридов
  DBGridEhCenter.OnBuildIndicatorTitleMenu := CreateGridIndicatorTitleMenu;
  //действия после логина пользователя (а форма не будет создана пока нет логина пользователя)
  AfterUserLogged;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  try
  //сохраним пользовательские настройки в БД
  //вызываем здесь, т.к. запись настроек фрейма грида в конфиг происходит при его разрушении, и если вызвать запись в бд при
  //закрытии главной формы, то она пройдет раньше сохранения конфига гридом
  Settings.Save;
  except
  end;
end;


//================================ ТАЙМЕРЫ =======================================

procedure TFrmMain.Timer1minTimer(Sender: TObject);
//выполняется при запуске приложания после показа главной формы, интервал = 1 минута
begin
  //принудительное заверение если была команда в таблице
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
  if (Module.RunFromIDE) and (MyQuestionMessage('Выполнить задачу ' + ParamStr(1) + '?') <> mrYes) then
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
//таймер закрытия приложения
begin
  Close;
end;

procedure TFrmMain.FormsToolButtonClick(Sender: TObject);
//клик по названию окна в толбаре открытых окон - развернет окно и на передний план
begin
  Wh.BringToFrontMDIForm(Sender);
end;

procedure TFrmMain.AfterUserLogged;
begin
  //видимость пунктов меню
  CreateMainMenu;
  //имя пользователя в правой панеле статусбара
  FrmMain.StatusBar.Panels[1].Text := User.GetName + '    ';
  //размеры и координаты главного окна из настроек пользователя
  Settings.RestoreWindowPos(Self, 'uFrmMain');
end;

procedure TFrmMain.WndProc(var Message: TMessage);
//оконная процедура
begin
  if Message.Msg = WM_SYSCOMMAND then
  begin
    case Message.WParam and $FFF0 of
      SC_CLOSE:
        begin
          ApplicationQueryClose := True;
{          if MessageDlg('Закрыть главное окно?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then
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
//Обработчик событий
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
     //обработаем колесико мышки - если под курсором грид, то будет масштабировать с шифтом
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
  //обработчик нажаьтий клавиатуры
  if Msg.Message = WM_KEYDOWN then begin
    CtrlAlShift := (GetKeyState(VK_CONTROL) < 0) and (GetKeyState(VK_SHIFT) < 0) and (GetKeyState(VK_MENU) < 0);
    //переключим режим дополнительных возможностей (возможности девелопера при запуске под любым пользователем)
    //по Ctrl+Shift+Alt+F3
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
    CanClose := MyQuestionMessage('Закрыть приложение?') = mrYes;
  ApplicationQueryClose := True;
end;

procedure TFrmMain.SetFormsToolButtonClick;
var
  i: Integer;
begin
  for i := 0 to FormsList.ButtonCount - 1 do
    FormsList.Buttons[i].OnClick := FormsToolButtonClick;
end;

//дефолтный пункт Печать для DBGridEh
procedure TFrmMain.DBGridEhMenu_PrintClick(Sender: TObject);
var
  st: string;
begin
  //вызвавший грид
  PrintDBGridEh1.DBGridEh := TDBGridEh((Sender as TDBGridEhMenuItem).Grid);
  //подстановка тукущей даты/времени, имени текущего пользователя и документа (заголовка окна-владельца грида)
  st := '';
  if PrintDBGridEh1.DBGridEh.Parent is TForm then
    st := TForm(PrintDBGridEh1.DBGridEh.Parent).Caption;
  PrintDBGridEh1.SetSubstitutes(['%[Today]', DateTimeToStr(Now), '%[UserName]', User.GetName, '%[Document]', Cth.GetParentForm(PrintDBGridEh1.DBGridEh).Caption]);
  PrintDBGridEh1.Preview;
end;

//дефолтный пункт Экспорт в эксель для DBGridEh
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
    if MenuCaption = 'Вход' then
      TFrmXDsrvAuth.Execute(False)
    else if MenuCaption = 'Сброс Oracle' then begin
      if MyQuestionMessage('Если наблюдаются задержки в работе базы данных, попробуйте устранить их, нажав кноку "Да"'#13#10 + 'Закрывать программы не нужно, данные и состояние будут сохранены.') = mrYes then
        q.QExecSql('alter system flush shared_pool', []);
    end
    else if MenuCaption = 'Тест 1' then
      TFrmTest2.Show(Self, 'test', [myfoSizeable], fNone, 0, null)
//      TestProcedure1
//      FrmTest.Create(Self);
    else if MenuCaption = 'Тест 2' then
      TestProcedure2
    else if MenuCaption = 'Тест 3' then
      TestProcedure3
    else if MenuCaption = 'Пароль администратора' then
      Dlg_SetPassword.ShowDialog(1)
    else if MenuCaption = 'Универсальный пароль' then
      Dlg_SetPassword.ShowDialog(1)
    else if MenuCaption = 'Копировать права доступа ИТМ' then
      FrmADedtItmCopyRigths.ShowDialog
    else if MenuCaption = 'Основные настройки' then
      Dlg_MainSettings.ShowDialog
    else if MenuCaption = 'Настройки модулей' then
      Dlg_ModuleSettings.ShowDialog
    else if MenuCaption = 'Отчет по себестоимости заказов' then
      Wh.ExecDialog(myfrm_Dlg_Rep_Order_Primecost2, Self, [], fNone, null, null)
    else if MenuCaption = 'Поиск сметной позиции' then
      Wh.ExecDialog(myfrm_Dlg_Or_FindNameInEstimates, Self, [], fNone, -1, null)
    else if MenuCaption = 'Информация по ИТМ' then
      Wh.ExecDialog(myfrm_Dlg_Or_ItmInfo, Self, [myfoDialog, myfoOneCopy], fNone, -1, null)
    else if MenuCaption = 'Общая смета по выбранным заказам' then
      Dlg_Rep_Smeta.ShowModal
    else if MenuCaption = 'О программе' then
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
    //общее меню
    ['='],
    ['Вход', '_', True],
    [],
    ['Настройки программы', myfrm_Adm_UserInterface, True],
    [],
    ['SQL монитор', myfrm_Srv_SqlMonitor, True],
    ['Сброс Oracle', '_', True],
    [],
    ['Тестовый справочник', myfrm_R_Test, User.IsDeveloper],
    ['Тест 1', '_', User.IsDeveloper],
    ['Тест 2', '_', User.IsDeveloper],
    ['Тест 3', '_', User.IsDeveloper],
    [],
    ['О программе', '_', True],

    //Администрирование
    {$IFDEF  ADMIN}
    ['Справочники'],

    ['Свои организации', myfrm_R_Organizations, User.Role(rAdm_R_Organizations)],
    ['Свои адреса', myfrm_R_Locations, User.Role(rAdm_R_Locations)],
    ['Виды транспортных средств', myfrm_R_CarTypes, User.Role(rAdm_R_Cartypes)],
    [],
    ['Журнал задач', myfrm_J_Tasks, True],

    ['Пользователи и роли'],
    ['Пользователи и роли', myfrm_F_UsersAndRoles, True], //!!!
    [],
    ['Пароль администратора', '_', User.GetId = 0],
    ['Универсальный пароль', '_', User.GetId = 0],
    [],
    ['Копировать права доступа ИТМ', '_', User.Role(rAdm_Itm_CopyUserRights)],

    ['Настройки'],
    ['Основные настройки', '_', User.Role(rAdm_Settings_Main)],
    ['Настройки модулей', '_', User.Role(rAdm_Settings_Modules)],

    ['Сервис'],
    ['Пользователи домена', myfrm_Adm_DomainUsers, User.IsDeveloper],
    [],
    ['Установщик модулей Учета', myfrm_Adm_Installer, User.IsDeveloper],
    [],
    ['Удаление файлов и папок на сервере', myfrm_Adm_DeleteOnServer, User.Role(rAdm_Other_DeleteOnServer)],
    [],
    ['Просмотр сессий', myfrm_Dlg_Adm_Sessions, User.Role(rAdm_Installer)],
    [],
    ['Лог событий БД', myfrm_Adm_Db_Log, User.IsDeveloper],
    ['Журнал ошибок', myfrm_J_Error_Log, User.IsDeveloper],
    [],
    ['Журнал задач', myfrm_J_Tasks, User.IsDeveloper],
    []
    {$ENDIF}

    {$IFDEF  PC}
    ['Справочники'],
    ['Группы статей расходов', myfrm_R_GrExpenseItems, User.Roles([], [rPC_R_GrExp_V, rPC_R_GrExp_Ch])],
    ['Статьи расходов', myfrm_R_ExpenseItems, User.Roles([], [rPC_R_Exp_Access])],
    [],
    ['Поставщики', myfrm_R_Suppliers, User.Roles([], [rPC_R_Sp_Access])],

    ['Журналы'],
    ['Счета', myfrm_J_Accounts, User.Roles([], [rPC_A_VAll, rPC_A_VSelfCat, rPC_A_VSelf])],
    ['Платежи', myfrm_J_Payments, User.Roles([], [rPC_P_VAll, rPC_P_VSelfCat])],
    ['Платежи по заказам', myfrm_J_OrPayments, User.Roles([], [rPC_J_OrPayments_V, rPC_J_OrPayments_Ch])],

    ['Касса'],
    ['Журнал Кассы1', myfrm_J_SnCalendar_Cash_1, User.Roles([], [rPC_J_Cash_1_V, rPC_J_Cash_1_Ch])],
    ['Журнал Кассы2', myfrm_J_SnCalendar_Cash_2, User.Roles([], [rPC_J_Cash_2_V, rPC_J_Cash_2_Ch])],
    ['Ревизия кассы', myfrm_Dlg_CashRevision, User.Roles([], [rPC_A_Cash_Revision_Ch, rPC_J_Cash_1_V, rPC_J_Cash_1_Ch, rPC_J_Cash_2_V, rPC_J_Cash_2_Ch])],

    ['Отчеты'],
    ['Платежи по датам', myfrm_Rep_SnCalendarByDate, False],
    ['Платежи по месяцам', myfrm_Rep_SnCalendarByMonths, User.Role(rPC_Rep_PmByMonths)],
    ['Отчет по транспортным счетам', myfrm_Rep_SnCalendar_Transport, User.Roles([], [rPC_Rep_Transport])],
    ['Отчет по счетам подрядчиков по монтажу', myfrm_Rep_SnCalendar_AccMontage, User.Roles([], [rPC_Rep_AccMontage])],
    []
    {$ENDIF}

    {$IFDEF  TURV}
    ['Справочники'],
    ['Работники', myfrm_R_Workers, User.Role(rW_R_Workers_V)],
    ['Профессии', myfrm_R_Jobs, User.Role(rW_R_Jobs_V)],
    ['Обозначения ТУРВ', myfrm_R_TurvCodes, User.Role(rW_R_TurvCode_V)],
    ['Подразделения', myfrm_R_Divisions, User.Role(rW_R_Divisions_V)],
    ['Графики работы', myfrm_R_Work_Chedules, User.Roles([], [rW_R_Work_Chedules_V, rW_R_Work_Chedules_Ch])],
    [],
    ['Производственный календарь', myfrm_R_Holideys, User.Role(rW_R_Holideys_V)],

    ['Журналы'],
    ['Журнал ТУРВ', myfrm_J_Turv, User.Role(rW_J_Turv)],
    [],
    ['Статусы работников', myfrm_J_WorkerStatus, User.Role(rW_J_WorkerStatus_V)],
    [],
    ['Зарплатные ведомости', myfrm_J_Payrolls, User.Roles([], [rW_J_Payroll_V, rW_J_Payroll_Ch])],
    [],
    ['Вакансии', myfrm_J_Vacancy, User.Roles([], [rW_J_Vacancy_V, rW_J_Vacancy_Ch])],
    ['Соискатели', myfrm_J_Candidates, User.Roles([], [rW_J_Candidates_V, rW_J_Candidates_Ch])],
    [],
    ['Журнал прихода/ухода работников', myfrm_J_Parsec, User.Roles([], [rW_J_Parsec_V, rW_J_Parsec_V_All])],

    ['Отчеты'],
    ['Свод по зарплатным ведомостям', myfrm_Rep_W_Payroll, User.Role(rW_Rep_Payroll)],
    ['Суммы по зарплатным ведомостям', myfrm_Rep_PayrollsSum, User.Role(rW_Rep_PayrollsSum)],
    [],
    ['Штатное расписание', myfrm_Rep_StaffSchedule, User.Roles([], [rW_Rep_StaffSchedule_V, rW_Rep_StaffSchedule_Ch_O, rW_Rep_StaffSchedule_Ch_C])],
    [],
    ['Отчет о кадровом составе', myfrm_Rep_W_Personnel_1, User.Role(rW_Rep_Personnel_1)],
    ['Отчет по подбору персонала', myfrm_Rep_W_Personnel_2, User.Role(rW_Rep_Personnel_2)],
    [],
    ['Отчет по заработной плате', myfrm_Rep_Salary, User.Roles([], [rW_Rep_Salary_V, rW_Rep_Salary_Ch])],
    []
    {$ENDIF}

    {$IFDEF OR}
    ['Справочники'],
    ['Группы bCAD', myfrm_R_Bcad_Groups, User.Roles([], [rOr_R_BCad_Groups_V, rOr_R_BCad_Groups_Ch])],
    ['Единицы измерения bCAD', myfrm_R_Bcad_Units, User.Roles([], [rOr_R_BCad_Units_V, rOr_R_BCad_Units_Ch])],
    ['Единицы измерения ИТМ', myfrm_R_Itm_Units, User.Roles([], [rOr_R_Itm_Units_V, rOr_R_Itm_Units_Ch, rOr_R_Itm_Units_Del])],
    ['Сметные позиции', myfrm_R_BCad_Nomencl, User.Roles([], [rOr_R_BCad_Nomencl_V])],
    ['Номенклатура ИТМ', myfrm_R_Itm_Nomencl, User.Roles([], [rOr_R_Itm_Nomencl_V])],
    ['Автозамена номенклатуры', myfrm_R_EstimatesReplace, User.Roles([], [rOr_R_BCad_Replace_V, rOr_R_BCad_Replace_Ch])],
    [],
    ['Типовые проекты', myfrm_R_StdProjects, User.Roles([], [rOr_R_StdProjects_V, rOr_R_StdProjects_Ch])],
    ['Стандартные форматы паспортов', myfrm_R_StdPspFormats, User.Roles([], [rOr_R_StdPspFormats_V, rOr_R_StdPspFormats_Ch])],
    ['Типы паспортов', myfrm_R_OrderTypes, User.Role(rOr_R_OrderTypes_Ch)],
    ['Типы производственных участков', myfrm_R_WorkCellTypes, User.Role(rOr_R_WorkCellTypes_Ch)],
    [],
    ['Стандартные изделия', myfrm_R_OrderStdItems, User.Roles([], [rOr_R_StdItems_V, rOr_R_StdItems_Ch, rOr_R_StdItems_Estimate])],
    ['Шаблоны заказов', myfrm_R_OrderTemplates, User.Roles([], [rOr_R_Or_Templates_V, rOr_R_Or_Templates_Ch])],
    [],
    ['Поставщики', myfrm_R_Itm_Suppliers, User.Roles([], [rOr_R_Itm_Suppliers_V, rOr_R_Itm_Suppliers_Ch, rOr_R_Itm_Suppliers_Del])],
    ['Покупатели', myfrm_R_Customers, User.Roles([], [rOr_R_Customers_V, rOr_R_Customers_Ch]) and User.IsDeveloper and False], //!!!
    [],
    ['Причины рекламаций', myfrm_R_complaintReasons, User.Roles([], [rOr_R_ComplaintReasons_V, rOr_R_ComplaintReasons_Ch])],
    ['Причины задержки в производстве', myfrm_R_DelayedInprodReasons, User.Roles([], [rOr_R_DelayedInprodReasons_V, rOr_R_DelayedInprodReasons_Ch])],
    ['Причины неприемки ОТК', myfrm_R_RejectionOtkReasons, User.Roles([], [rOr_R_RejectionOtkReasons_V, rOr_R_RejectionOtkReasons_Ch])],
    [],
    ['Категориии заявок на снабжение', myfrm_R_Spl_Categoryes, User.Roles([], [rOr_R_Spl_Categoryes_V, rOr_R_Spl_Categoryes_Ch])],

    ['Журналы'],
    ['Журнал задач', myfrm_J_Tasks, True or User.Roles([], [rOr_J_Tasks_VAll, rOr_J_Tasks_Ch])],
    ['Журнал разработки', myfrm_J_Devel, User.Roles([], [rOr_J_Devel_V, rOr_J_Devel_Ch, rOr_J_Devel_Del])],
    [],
    ['Плановые заказы', myfrm_J_PlannedOrders, User.Roles([], [rOr_J_PlannedOrders_V, rOr_J_PlannedOrders_Ch])],
    ['Заказы на полуфабрикаты', myfrm_J_Semiproducts, User.Roles([], [rOr_J_Semiproducts_V, rOr_J_Semiproducts_Ch])],
    [],
    ['Заказы', myfrm_J_Orders, User.Roles([], [rOr_J_Orders_V, rOr_J_Orders_V_Wo_Prices, rOr_D_Order_Ch])],
    [],
    ['Журнал выдачи в производство', myfrm_J_OrderStages_ToProd, User.Roles([], [rOr_J_OrderStages_ToProd_V, rOr_J_OrderStages_ToProd_Ch])],
    ['Журнал просрочки в производстве', myfrm_J_Or_DelayedInProd, User.Roles([], [rOr_J_DelayedInprod_V, rOr_J_DelayedInprod_Ch])],
    ['Журнал приёмки ОТК', myfrm_J_OrderStages_Otk, User.Roles([], [rOr_J_OrderStages_Otk_V, rOr_J_OrderStages_Otk_Ch])],
    ['Журнал накладных перемещения на СГП', myfrm_J_InvoiceToSgp, User.Roles([], [rOr_J_InvoiceToSGP_V, rOr_J_InvoiceToSgp_Ch_M, rOr_J_InvoiceToSgp_Ch_S])],
    ['Журнал приёмки на СГП', myfrm_J_OrderStages_ToSgp, User.Roles([], [rOr_J_OrderStages_ToSgp_V, rOr_J_OrderStages_ToSgp_Ch])],
    ['Журнал отгрузки с СГП', myfrm_J_OrderStages_FromSgp, User.Roles([], [rOr_J_OrderStages_FromSgp_V, rOr_J_OrderStages_FromSgp_Ch])],
    ['Журнал монтажа', myfrm_J_Or_Montage, User.Roles([], [rOr_J_OrderStages_Montage_V, rOr_J_OrderStages_Montage_Ch])],
    [],
    ['Платежи по заказам', myfrm_J_OrPayments, User.Roles([], [rOr_J_OrPayments_V, rOr_J_OrPayments_Ch])],
    ['Промежуточные платежи по заказам', myfrm_J_OrPayments_N, User.Roles([], [rOr_J_OrPayments_N_V, rOr_J_OrPayments_N_Ch]) and False], //!!!

    ['Отчеты'],
    ['Текущее состояние СГП (стандартные изделия)', myfrm_Rep_Sgp, User.Roles([], [rOr_Rep_Sgp_V])],
    ['Текущее состояние СГП (нестандартные изделия)', myfrm_Rep_Sgp2, User.Roles([], [rOr_Rep_Sgp_V])],
    [],
    ['Годовая потребность в материалах', myfrm_Rep_PlannedMaterials, User.Roles([], [rOr_Rep_PlannedMaterials_V, rOr_Rep_PlannedMaterials_Calc])],
    [],
    ['Финансовый отчет по заказам', myfrm_Dlg_Rep_FinByOrders, User.Roles([], [rOr_Rep_Order_Fin1, rOr_Rep_Order_Fin2, rOr_Rep_Order_Fin3, rOr_Rep_Order_Fin4, rOr_Rep_Order_Fin5])],
    ['Отчет по себестоимости заказов', '_', User.Roles([], [rOr_Rep_Order_Primecost1])],
    ['Отчет по рекламациям', myfrm_Rep_Order_Complaints, User.Roles([], [rOr_Rep_Order_Complaints])],
    ['Отчет по изделиям в производстве', myfrm_J_OrItemSInProd, User.Role(rOr_Rep_OrItemSInProd)],
    ['Отчет по изделиям в заказах', myfrm_Rep_SnCalendar_Orders_QntItems, User.Roles([], [rOr_Rep_Orders_QntItems])],
    ['Общая смета по выбранным заказам', User.Roles([], [rOr_Rep_Orders_QntItems])],

    ['Сервис'],
    ['Формирование заявок на снабжение', myfrm_R_MinRemains, User.Roles([], [rOr_Other_R_MinRemains_V, rOr_Other_R_MinRemains_Ch, rOr_Other_R_MinRemains_Ch_Suppl])],
    ['Потребность по участку "Петра Щербины"', myfrm_R_MinRemainsP, User.Roles([], [rOr_Other_R_MinRemainsI_V, rOr_Other_R_MinRemainsI_Ch1, rOr_Other_R_MinRemainsI_ChAll])],
    ['Потребность по участку "Инженерный"', myfrm_R_MinRemainsI, User.Roles([], [rOr_Other_R_MinRemainsI_V, rOr_Other_R_MinRemainsI_Ch1, rOr_Other_R_MinRemainsI_ChAll])],
    ['Потребность по участку "Деминская"', myfrm_R_MinRemainsD, User.Roles([], [rOr_Other_R_MinRemainsI_V, rOr_Other_R_MinRemainsI_Ch1, rOr_Other_R_MinRemainsI_ChAll])],
    ['Номенклатура, выданная сверх смет', myfrm_Rep_ItmNomOverEstimate, User.Roles([], [rOr_Rep_ItmNomOverEstimate])],
    [],
    ['Поиск сметной позиции', '_', User.Role(rOr_Other_Order_FindEstimate)],
    ['Информация по ИТМ', '_', User.Role(rOr_Other_ItmInfo)],
    ['Журнал действий пользователей ИТМ', myfrm_J_ItmLog, User.Role(rOr_Other_J_ItmLog)],
    ['Расширенный справочник номенклатуры ITM', myfrm_R_Or_ItmExtNomencl, User.Role(rOr_Other_ItmExtNomencl)]
    {$ENDIF}
    {$IFDEF SRV}
    []
    {$ENDIF}
  ];
end;

initialization
end.



