unit uWindows;

{
  Модуль работы с окнами приложения.
  Создаёт и корректирует список открытых окон в нижней панели (тулбаре).
  Список включает как MDI-дочерние, так и диалоговые окна.
  По клику на наименовании в тулбаре выбранное окно активируется.
}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh,
  GridsEh, DBAxisGridsEh, DBGridEh, Math, TypInfo, uData,
  uString, uSys;

type
  TmyWindowsStateChangeMode = (mywscmCreate, mywscmActivate, mywscmDestroy, mywscmChange);
  TDlgFunction = function(FSelf: TForm; Mode: Integer): Variant;

  // Сохранённые при открытии параметры формы
  TWindowRecord = record
    Handle: HWND;
    Form: TForm;
    FormDoc: string;
    Title: string;
    Number: Integer;
  end;

  TWindowsArray = array of TWindowRecord;

  TWindowsHelper = class
  private
    FWindows: TWindowsArray;
    FUseWindowsBar: Boolean;
    // Обработка событий изменения состояния форм
    procedure WindowsBarChange(AForm: TForm; AHandle: HWND; AMode: TmyWindowsStateChangeMode);
    // Вспомогательные методы для получения параметров формы
    function GetFormDoc(AForm: TForm): string;
    function GetFormId(AForm: TForm): Variant;
  public
    // ModalResult, возвращённый формой при показе в модальном режиме
    ModalResult: Integer;
    // Результат диалога (устанавливается в потомках TForm_MDI)
    FormDialogResult: Integer;
    // Результат выбора одной строки
    SelectDialogResult: TVarDynArray;
    // Результат выбора нескольких строк
    SelectDialogResult2: TVarDynArray2;
    // Коллекция окон
    property Windows: TWindowsArray read FWindows;

    constructor Create();
    // События изменения состояния форм
    procedure ChildFormCreate(Sender: TObject);
    procedure ChildFormActivate(Sender: TObject);
    procedure ChildFormDestroy(Sender: TObject);
    procedure ActiveFormChange(Sender: TObject);
    // Вызывается при нажатии кнопки в тулбаре
    procedure BringToFrontMDIForm(Sender: TObject);
    // Для диалогов: проверить наличие окна, при наличии активировать и вернуть False
    function BringToFrontIfExists(const AFormDoc: string; const AId: Variant): Boolean;
    // Получить количество окон с таким же FormDoc (и Id, если задан)
    function GetWindowsCount(var AForm: TForm; const AFormDoc: string; const AId: Variant; var AMaxNum: Integer): Integer; overload;
    function GetWindowsCount(const AFormDoc: string; const AId: Variant; var AMaxNum: Integer): Integer; overload;
    // Подсветить кнопку активной формы (не используется)
    procedure HiglightActiveForm(AForm: TForm);
    // Вернуть объект формы из коллекции, иначе nil
    function GetFormFromWindows(AForm: TForm): TForm;
    // Проверить, открыта ли модальная форма
    function IsModalFormOpen: Boolean;
    // Открыть справочную форму
    procedure ExecReference(const AFormType: string); overload;
    procedure ExecReference(const AFormType: string; AOwner: TComponent; const AMyFormOptions: TMyFormOptions; const AAddParam: Variant); overload;
    // Открыть диалоговую форму
    procedure ExecDialog(const AFormType: string; AOwner: TComponent; const AMyFormOptions: TMyFormOptions; const AMode: TDialogType; const AId: Variant; const AAddParam: Variant);
    // Универсальный метод (в текущей реализации пуст)
    procedure ExecAdd(const AFormType: string; AOwner: TComponent; const AMode: TDialogType; const AId: Variant; const AMyFormOptions: TMyFormOptions; const AAddParam: Variant; const AShowModal: Boolean = False; const ADlgFunction: TDlgFunction = nil);
  end;

var
  Wh: TWindowsHelper;

implementation

uses
  V_MDI, V_Normal, uFrmBasicMdi,
  uFrmMain,
  uTurv,
  uSnCalendar,
  uOrders,
  uFrmAGlstDomainUsers, uFrmAGLstLdapUsers, uFrmADedtMainSettings,
  uFrmCDedtAccount,
  uFrmCDedtExpenseItem,
  uFrmWDedtDivision, uFrmWGrepPersonal1, uFrmWGrepStaffSchedule, uFrmWGjrnEmployees,
  uFrmWGEdtTurvN, uFrmWWedtWorkSchedule, uFrmWGedtPayrollTransfer,
  uFrmWGedtPayrollCash, uFrmWGedtAdvance, uFrmWGedtAdvanceTransfer, uFrmWGedtAdvanceCash, uFrmWGedtPayrollCalc,
  uFrmWGrepTurv,
  D_Order,
  D_ItmInfo, D_J_Montage,
  D_NewEstimateInput,
  D_SuppliersMinPart,
  D_Spl_InfoGrid,
  F_Adm_Installer,
  uFrmXGsrvSqlMonitor,

  uFrmOWOrder,
  uFrmOWInvoiceToSgp, uFrmDlgEditNomenclatura, uFrmOGjrnOrders, uFrmOGjrnSemiproducts,
  uFrmCGrepPaymentsByMonth, uFrmCWCash, uFrmAWOracleSessions, uFrmCDedtCashRevision,
  uFrmAWUsersAndRoles, uFrmWGjrnParsec, uFrmOGjrnUchetLog, uFrmOGrefOrStdItems,
  uFrmOGrepSgp, uFrmWGrepSalary, uFrmOGjrnOrderStages, uFrmOGrepItemsInOrder,
  uFrmODedtTasks, uFrmOGedtSnMain, uFrmODrepFinByOrders, uFrmOGedtSnByAreas,
  uFrmOGlstEstimate, uFrmDlgRItmSupplier, uFrmOGedtSgpRevision, uFrmXWndUserInterface,
  uFrmODedtDevel, uFrmODedtItmUnits, uFrmODedtSplCategoryes, uFrmOWSearchInEstimates,
  uFrmOWrepOrdersPrimeCost, uFrmOGrepSnHistory, uFrmODedtOrStdItem,
  uFrmOWedtOrReglament, uFrmOGrepEstimatePrices, uFrmOGrepOrReglament,
  uFrmOGjrnProdCalculations, uFrmOWedtProdCalculation, uFrmOGrepOrdersFinMonitoring,

  uFrmPWedtPlnOps,
  uFrmXGlstMain,
  uFrmBasicInput;

const
  cGreenGalka = 1;
  cRedGalka   = 3;
  cGreenDot   = 10;
  cRedDot     = 11;

constructor TWindowsHelper.Create();
//инициализация
begin
  inherited;
  FUseWindowsBar := True;
end;

procedure TWindowsHelper.ChildFormCreate(Sender: TObject);
//обработчик создания (не используется)
begin
  // WindowsBarChange(Sender, TForm(Sender).Handle, mywscmCreate);
end;

procedure TWindowsHelper.ChildFormActivate(Sender: TObject);
//обработчик активации
begin
  WindowsBarChange(TForm(Sender), TForm(Sender).Handle, mywscmActivate);
end;

procedure TWindowsHelper.ChildFormDestroy(Sender: TObject);
//обработчик разрушения
begin
  WindowsBarChange(TForm(Sender), TForm(Sender).Handle, mywscmDestroy);
end;

procedure TWindowsHelper.ActiveFormChange(Sender: TObject);
//обработчик смены активной формы (для диалогов)
begin
  WindowsBarChange(nil, GetForegroundWindow, mywscmChange);
end;

function TWindowsHelper.GetFormDoc(AForm: TForm): string;
//возвращает FormDoc для разных типов форм
begin
  Result := '';
  if AForm is TForm_MDI then
    Result := TForm_MDI(AForm).FormDoc
  else if AForm is TFrmBasicMdi then
    Result := TFrmBasicMdi(AForm).FormDoc
  else if AForm is TForm_Normal then
    Result := TForm_Normal(AForm).FormDoc;
end;

function TWindowsHelper.GetFormId(AForm: TForm): Variant;
//возвращает Id для разных типов форм
begin
  if AForm is TForm_MDI then
    Result := TForm_MDI(AForm).ID
  else if AForm is TFrmBasicMdi then
    Result := TFrmBasicMdi(AForm).ID
  else
    Result := Null;
end;

procedure TWindowsHelper.WindowsBarChange(AForm: TForm; AHandle: HWND; AMode: TmyWindowsStateChangeMode);
//обновление тулбара окон
var
  i: Integer;
  b: Boolean;
  st: string;
  Tbt: TToolButton;
  MaxNum: Integer;
  Rec: TWindowRecord;
  fd: string;
begin
  if not FUseWindowsBar then Exit;
  if FrmMain.FormsList = nil then Exit;

  st := Sys.GetWindowHeader(AHandle);

  // проверка принадлежности окна
  b := (GetParent(AHandle) = Application.Handle) or
       (GetParent(AHandle) = FrmMain.Handle) or
       (AForm is TForm_MDI) or (AForm is TFrmBasicMdi) or (AForm is TForm_Normal);
  if not b then Exit;

  // добавление новой кнопки, если окно не в списке
  b := True;
  for i := 0 to FrmMain.FormsList.ComponentCount - 1 do
    if (FrmMain.FormsList.Buttons[i].Tag = AHandle) and FrmMain.FormsList.Buttons[i].Visible then
    begin
      b := False;
      Break;
    end;

  if b and (AHandle <> FrmMain.Handle) then
  begin
    if (AForm is TForm_MDI) or (AForm is TForm_Normal) or (AForm is TFrmBasicMdi) then
      GetWindowsCount(AForm, '', Null, MaxNum)
    else
      MaxNum := 0;

    Tbt := TToolButton.Create(FrmMain.FormsList);
    Tbt.Parent := FrmMain.FormsList;
    Tbt.Visible := True;
    Tbt.Height := 24;
    Tbt.AutoSize := True;
    Tbt.Style := tbsTextButton;
    Tbt.Down := True;
    Tbt.ImageIndex := -1;
    Tbt.Tag := AHandle;
    Tbt.Left := 10000;
    fd := GetFormDoc(AForm);
    Tbt.Caption := st + S.IIfStr(MaxNum > 0, '  |' + IntToStr(MaxNum + 1), '');
    FrmMain.SetFormsToolButtonClick;

    Rec.Handle := AHandle;
    Rec.Form := AForm;
    Rec.FormDoc := fd;
    Rec.Title := st;
    Rec.Number := MaxNum + 1;
    SetLength(FWindows, Length(FWindows) + 1);
    FWindows[High(FWindows)] := Rec;
  end;

  // удаление помеченных кнопок
  for i := FrmMain.FormsList.ComponentCount - 1 downto 0 do
    if FrmMain.FormsList.Buttons[i].Caption = '----' then
    begin
      FrmMain.FormsList.Buttons[i].OnClick := nil;
      try
        Delete(FWindows, i, 1);
        FrmMain.FormsList.Buttons[i].Destroy;
      except
      end;
    end;

  // обновление индексов изображений
  for i := FrmMain.FormsList.ComponentCount - 1 downto 0 do
  begin
    Tbt := FrmMain.FormsList.Buttons[i];
    if Trim(Tbt.Caption) = '' then
    begin
      try
        Tbt.Destroy;
        Delete(FWindows, i, 1);
        Continue;
      except
      end;
    end;
    b := (AHandle = Tbt.Tag);

    if IsModalFormOpen or
       ((AForm is TForm_MDI) and (AForm.FormStyle = fsNormal)) or
       ((AForm is TFrmBasicMdi) and (AForm.FormStyle = fsNormal)) then
    begin
      if Tbt.ImageIndex = cGreenGalka then
        Tbt.ImageIndex := cGreenDot
      else if Tbt.ImageIndex = cRedGalka then
        Tbt.ImageIndex := cRedDot;
      if b then
        Tbt.ImageIndex := cRedGalka;
    end
    else
    begin
      if AMode = mywscmActivate then
      begin
        if b then
          Tbt.ImageIndex := cGreenGalka
        else
          Tbt.ImageIndex := -1;
      end
      else if Tbt.ImageIndex = cGreenDot then
        Tbt.ImageIndex := cGreenGalka;
    end;
  end;

  // удаление кнопок для несуществующих окон
  for i := FrmMain.FormsList.ComponentCount - 1 downto 0 do
  begin
    Tbt := FrmMain.FormsList.Buttons[i];
    if (Tbt.Tag > 0) and (Tbt.Tag = AHandle) and (AMode = mywscmDestroy) then
    begin
      Tbt.Caption := '--' + Tbt.Caption;
      Tbt.Visible := False;
      if i < Length(FWindows) then
      begin
        FWindows[i].Form := nil;
        FWindows[i].FormDoc := '';
      end;
    end;
  end;
end;

procedure TWindowsHelper.BringToFrontMDIForm(Sender: TObject);
//переключение на окно по клику на кнопке
var
  i: Integer;
  Tbt: TToolButton;
begin
  try
    Tbt := TToolButton(Sender);
    for i := 0 to High(FWindows) do
      if FWindows[i].Handle = Tbt.Tag then
      begin
        if IsWindowVisible(Tbt.Tag) and (FWindows[i].Form <> nil) and
           (FWindows[i].Form.WindowState = wsMinimized) then
          FWindows[i].Form.WindowState := wsNormal;
        FWindows[i].Form.BringToFront;
        Break;
      end;
  except
  end;
end;

function TWindowsHelper.BringToFrontIfExists(const AFormDoc: string; const AId: Variant): Boolean;
//активировать существующее окно
var
  i: Integer;
  id1: Variant;
begin
  Result := True;
  for i := 0 to High(FWindows) do
  begin
    id1 := GetFormId(FWindows[i].Form);
    if (AFormDoc = FWindows[i].FormDoc) and ((AId = Null) or (AId = id1)) then
    begin
      FWindows[i].Form.BringToFront;
      Result := False;
      Exit;
    end;
  end;
end;

function TWindowsHelper.GetWindowsCount(var AForm: TForm; const AFormDoc: string; const AId: Variant; var AMaxNum: Integer): Integer;
//подсчёт окон с таким же FormDoc и Id
var
  i: Integer;
  st1, st2: string;
  id1, id2: Variant;
begin
  Result := 0;
  AMaxNum := 0;
  st1 := GetFormDoc(AForm);
  id1 := GetFormId(AForm);
  for i := 0 to High(FWindows) do
  begin
    if (FWindows[i].Form <> nil) and (st1 = FWindows[i].FormDoc) and
       ((AId = Null) or (AId = id1)) then
    begin
      Inc(Result);
      if FWindows[i].Number > AMaxNum then
        AMaxNum := FWindows[i].Number;
    end;
  end;
end;

function TWindowsHelper.GetWindowsCount(const AFormDoc: string; const AId: Variant; var AMaxNum: Integer): Integer;
//перегрузка без формы
var
  i: Integer;
begin
  Result := 0;
  AMaxNum := 0;
  for i := 0 to High(FWindows) do
    if (AFormDoc = FWindows[i].FormDoc) and ((AId = Null) or (AId = GetFormId(FWindows[i].Form))) then
    begin
      Inc(Result);
      if FWindows[i].Number > AMaxNum then
        AMaxNum := FWindows[i].Number;
    end;
end;

procedure TWindowsHelper.HiglightActiveForm(AForm: TForm);
//(не используется)
var
  i: Integer;
  b: Boolean;
begin
  for i := 0 to High(FWindows) do
    with FrmMain.FormsList do
      if AForm <> nil then
      begin
        b := (AForm.Handle = Buttons[i].Tag);
        Buttons[i].Down := b;
        Buttons[i].ImageIndex := IfThen(b, 0, -1);
      end;
end;

function TWindowsHelper.GetFormFromWindows(AForm: TForm): TForm;
//поиск формы в коллекции
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to High(FWindows) do
    if FWindows[i].Form = AForm then
    begin
      Result := AForm;
      Exit;
    end;
end;

function TWindowsHelper.IsModalFormOpen: Boolean;
//проверка, открыта ли модальная форма
var
  ActForm: TCustomForm;
begin
  ActForm := Screen.ActiveForm;
  Result := (ActForm <> nil) and (fsModal in ActForm.FormState);
end;

//==============================================================================
// ExecReference – открытие справочных форм
//==============================================================================

procedure TWindowsHelper.ExecReference(const AFormType: string);
//открытие справочной формы с параметрами по умолчанию
var
  Opt: TMyFormOptions;
begin
  Opt := [myfoOneCopy, myfoSizeable, myfoEnableMaximize];
  ExecReference(AFormType, FrmMain, Opt, Null);
end;

procedure TWindowsHelper.ExecReference(const AFormType: string; AOwner: TComponent; const AMyFormOptions: TMyFormOptions; const AAddParam: Variant);
//открытие справочной формы с указанными опциями
var
  Opt: TMyFormOptions;
begin
  if AMyFormOptions <> [] then
    Opt := AMyFormOptions
  else
    Opt := [myfoOneCopy, myfoSizeable, myfoEnableMaximize];
  if IsModalFormOpen then
    Include(Opt, myfoModal);

  // ---- список зарегистрированных форм ----
  if A.InArray(AFormType, [
    //общие и администрирование
    myfrm_R_Test,
    myfrm_Adm_Db_Log,
    myfrm_J_Error_Log,
    myfrm_R_Organizations,
    myfrm_R_Locations,
    myfrm_R_CarTypes,
    //работники
    myfrm_R_GrExpenseItems,
    myfrm_R_ExpenseItems,
    myfrm_R_Suppliers,
    myfrm_J_Accounts,
    myfrm_J_Payments,
    myfrm_J_Accounts_SEL,
    myfrm_R_Itm_Schet_SELCH,
    myfrm_J_OrPayments,
    myfrm_Rep_SnCalendarByDate,
    myfrm_Rep_SnCalendar_Transport,
    myfrm_Rep_SnCalendar_AccMontage,
    myfrm_Rep_Purchase_Prices,
    myfrm_R_TurvCodes,
    myfrm_R_Jobs,
    myfrm_R_Work_Chedules,
    myfrm_R_Divisions,
    myfrm_J_WorkerStatus,
    myfrm_J_Candidates,
    myfrm_R_Candidates_Ad_SELCH,
    myfrm_J_Turv,
    myfrm_R_Holideys,
    myfrm_Rep_W_Payroll,
    myfrm_Rep_PayrollsSum,
    myfrm_J_Vacancy,
    myfrm_Ref_JobsNeeded,
    myfrm_J_AdvanceCalculations,
    myfrm_J_AdvanceTransfer,
    myfrm_J_AdvanceCash,
    myfrm_J_PayrollCalculations,
    myfrm_J_PayrollTransfer,
    myfrm_J_PayrollCash,
    myfrm_R_PersBonus,
    myfrm_J_PersBonus,
    myfrm_J_PayrollsForWorker,
    rW_J_WorkerStatus_V,
    //заказы
    myfrm_R_StdProjects,
    myfrm_R_Bcad_Groups,
    myfrm_R_Bcad_Units,
    myfrm_R_Bcad_Nomencl,
    myfrm_R_OrderTemplates,
    myfrm_R_ComplaintReasons,
    myfrm_R_DelayedInprodReasons,
    myfrm_R_RejectionOtkReasons,
    myfrm_R_OrderTypes,
    myfrm_R_OrderProperties,
    myfrm_J_PlannedOrders,
    myfrm_J_InvoiceToSgp,
    myfrm_R_Or_ItmExtNomencl,
    myfrm_R_EstimatesReplace,
    myfrm_R_Spl_Categoryes,
    myfrm_R_Itm_Units,
    myfrm_R_Itm_Suppliers,
    myfrm_R_Itm_InGroup_Nomencl,
    myfrm_J_Orders_SEL,
    myfrm_J_Orders_SEL_1,
    myfrm_R_StdPspFormats,
    myfrm_Rep_PlannedMaterials,
    myfrm_J_Tasks,
    myfrm_J_Devel,
    myfrm_J_DevelThn,
    myfrm_J_Devel_Ref,
    myfrm_J_DevelThn_Ref,
    myfrm_R_Itm_Nomencl,
    myfrm_R_Itm_Nomencl_SEL,
    myfrm_R_bCAD_Nomencl_SEL,
    myfrm_R_bCAD_Nomencl_SelMaterials,
    myfrm_R_OrderStdItems_SEL,
    myfrm_R_OrderStdItems_SelSemiproduct,
    myfrm_R_OrderStdItems_SelProdStdItem,
    myfrm_R_Itm_Schet,
    myfrm_R_Itm_DemandSupplier,
    myfrm_R_Itm_InBill,
    myfrm_R_Itm_MoveBill,
    myfrm_R_Itm_OffMinus,
    myfrm_R_Itm_PostPlus,
    myfrm_R_Itm_Act,
    myfrm_Rep_OrderStdItems_Err,
    myfrm_Rep_ItmNomOverEstimate,
    myfrm_Rep_Order_Complaints,
    myfrm_Rep_Sgp2,
    myfrm_J_Sgp_Acts,
    myfrm_R_WorkCellTypes,
    myfrm_J_OrItemsInProd,
    myfrm_J_ItmLog,
    myfrm_R_OrderReglament,
    myfrm_J_SplDealsMonitoring,
    myfrm_J_OrdersBySlashes,
    myfrm_Rep_Orders_Overdue_Kns_Thn,
    myfrm_Rep_Orders_Audit,
    //планирование
    myfrm_R_PnlOpsPainting
  ]) then
    TFrmXGlstMain.Show(AOwner, AFormType, Opt + [], fNone, 0, AAddParam)
  else if A.InArray(AFormType, [myfrm_R_Suppliers_SELCH]) then
    TFrmXGlstMain.Show(AOwner, AFormType, [myfoDialog, myfoModal, myfoSizeable], fNone, 0, AAddParam)
  else if AFormType = myfrm_J_SnHistory then
    TFrmOGrepSnHistory.Show(AOwner, AFormType, Opt + [myfoModal], fNone, 0, AAddParam)
  else if AFormType = myfrm_Srv_SqlMonitor then
    TFrmXGsrvSqlMonitor.Show(Application, AFormType, Opt, FNone, 0, Null)
  else if AFormType = myfrm_Rep_SnCalendarChart then
    // Form := TForm_Rep_SnCalendarChart.Create(...)
  else if AFormType = myfrm_Rep_SnCalendarByMonths then
    TFrmCGrepPaymentsByMonth.Show(Application, AFormType, Opt, fNone, 0, Null)
  else if (AFormType = myfrm_J_SnCalendar_Cash_1) or (AFormType = myfrm_J_SnCalendar_Cash_2) then
    TFrmCWCash.Show(Application, AFormType, Opt, fEdit, 0, Null)
  else if AFormType = myfrm_Rep_SnCalendar_Orders_QntItems then
    TFrmOGrepItemsInOrder.Show(Application, AFormType, Opt, fEdit, 0, Null)
  else if AFormType = myfrm_Adm_UserInterface then
    TFrmXWndUserInterface.Show(Application, AFormType, [myfoDialog], fNone, 0, Null)
  else if AFormType = myfrm_Rep_W_Personnel_1 then
    TFrmWGrepPersonal1.Show(Application, AFormType, Opt, fNone, 0, Null)
  else if AFormType = myfrm_Rep_W_Personnel_2 then
    // Form := TForm_Rep_Personnel_2.Create(...)
  else if AFormType = myfrm_R_Holideys then
    // Form := TForm_R_Holideys.Create(...)
  else if AFormType = myfrm_Rep_Salary then
    TFrmWGrepSalary.Show(Application, AFormType, Opt, fNone, 0, Null)
  else if AFormType = myfrm_J_Parsec then
    TFrmWGjrnParsec.Show(Application, AFormType, Opt, fNone, Null, Null)
  else if AFormType = myfrm_Adm_DeleteOnServer then
    // Form := TForm_Adm_DeleteOnServer.Create(...)
  else if (AFormType = myfrm_J_Orders) or (AFormType = myfrm_J_Pnl_Orders) then
    TFrmOGjrnOrders.Show(Application, AFormType, Opt, fNone, 0, Null)
  else if AFormType = myfrm_J_ProdCalculations then
    TFrmOGjrnProdCalculations.Show(Application, AFormType, Opt, fNone, 0, Null)
  else if (AFormType = myfrm_R_OrderStdItems) or (AFormType = myfrm_R_Pnl_StdItems) then
    TFrmOGrefOrStdItems.Show(Application, AFormType, Opt, fNone, 0, Null)
  else if (AFormType = myfrm_R_Estimate) or (AFormType = myfrm_R_AggEstimate) then
    TFrmOGlstEstimate.Show(Application, AFormType, Opt + [myfoMultiCopy], fNone, 0, AAddParam)
  else if AFormType = myfrm_R_Customers then
    // справочник отключён
  else if A.InArray(AFormType, [myfrm_J_OrderStages_ToProd, myfrm_J_OrderStages_ToSgp, myfrm_J_OrderStages_FromSgp, myfrm_J_OrderStages_Otk, myfrm_J_Or_DelayedInProd, myfrm_J_Or_Montage]) then
    TFrmOGjrnOrderStages.Show(Application, AFormType, Opt, fNone, 0, AAddParam)
  else if AFormType = myfrm_R_MinRemains then
    TFrmOGedtSnMain.Show(Application, AFormType, Opt, fNone, 0, AAddParam)
  else if A.InArray(AFormType, [myfrm_R_MinRemainsP, myfrm_R_MinRemainsI, myfrm_R_MinRemainsD]) then
    TFrmOGedtSnByAreas.Show(Application, AFormType, Opt, fNone, 0, AAddParam)
  else if AFormType = myfrm_Rep_Sgp then
    TFrmOGrepSgp.Show(Application, AFormType, Opt, fNone, 0, AAddParam)
  else if A.InArray(AFormType, [myfrm_J_OrderStages_Full_Log, myfrm_J_OrderStages_ToSgp_Log, myfrm_J_OrderStages_FromSgp_Log, myfrm_J_OrderStages_Otk_Log]) then
    TFrmOGjrnUchetLog.Show(AOwner, AFormType, Opt, fNone, 0, AAddParam)
  else if AFormType = myfrm_J_Semiproducts then
    TFrmOGjrnSemiproducts.Show(Application, AFormType, [], S.IIf(User.Role(rOr_J_Semiproducts_Ch), fEdit, fView), 0, Null)
  else if AFormType = myfrm_Dlg_Adm_Sessions then
    TFrmAWOracleSessions.Show(Application, AFormType, Opt, fNone, 0, Null)
  else if AFormType = myfrm_Dlg_CashRevision then
    TFrmCDedtCashRevision.Show(Application, '', [], fNone, 1, Null)
  else if AFormType = myfrm_Adm_Installer then
    TForm_Adm_Installer.Create(Application, AFormType, [myfoOneCopy], fNone, 0, Null)
  else if AFormType = myfrm_Adm_DomainUsers then
    TFrmAGlstDomainUsers.Show(Application, AFormType, [myfoSizeable], fNone, Null, Null)
  else if AFormType = myfrm_Adm_LdapUsers then
    TFrmAGlstLdapUsers.Show(Application, AFormType, [myfoSizeable], fNone, Null, Null)
  else if AFormType = myfrm_F_UsersAndRoles then
    TFrmAWUsersAndRoles.Show(Application, AFormType, [myfoSizeable, myfoDialog], fNone, Null, Null)
  else if AFormType = myfrm_Dlg_Rep_FinByOrders then
    TFrmODrepFinByOrders.Show(AOwner, AFormType, [myfoDialog], fNone, Null, Null)
  else if AFormType = myfrm_Rep_StaffSchedule then
    TFrmWGrepStaffSchedule.Show(Application, AFormType, Opt, fNone, 0, Null)
  else if AFormType = myfrm_Dlg_Rep_EstimatePrices then
    TFrmOGrepEstimatePrices.Show(AOwner, AFormType, Opt + [myfoSizeable], fNone, Null, Null)
  else if AFormType = myfrm_Rep_Turv then
    TFrmWGrepTurv.Show(AOwner, AFormType, Opt, fView, Null, AAddParam)
  else if AFormType = myfrm_R_Workers then
    TFrmWGjrnEmployees.Show(AOwner, AFormType, Opt + [myfoSizeable], fView, Null, Null)
  else if AFormType = myfrm_Rep_OrdersFinMonitoring then
    TFrmOGrepOrdersFinMonitoring.Show(AOwner, AFormType, Opt, fView, Null, Null)
  else if AFormType = myfrm_Dlg_ExportTurvToXls then
    Turv.SaveAllTurvToExportTable
  else if AFormType = myfrm_Dlg_DeleteOutdatedAccounts then
    SnCalendar.EraseOutdatedAccounts(AOwner)
  else if AFormType = myfrm_Dlg_DeleteOutdatedOrders then
    Orders.EraseOutdatedOrders(AOwner)
  else if AFormType = myfrm_Dlg_MainSettings then
    TFrmADedtMainSettings.Show(AOwner, AFormType, Opt, fEdit, Null, Null)
  else if AFormType = myfrm_Dlg_OrdersFinReport then
    Orders.OrdersFinReport
  else
    raise Exception.Create('Вызвана функция "ExecReference", однако тип "' + AFormType + '" в ней не зарегистрирован!');
end;

//==============================================================================
// ExecDialog – открытие диалоговых форм
//==============================================================================

procedure TWindowsHelper.ExecDialog(const AFormType: string; AOwner: TComponent; const AMyFormOptions: TMyFormOptions; const AMode: TDialogType; const AId: Variant; const AAddParam: Variant);
//открытие диалоговой формы
var
  Opt: TMyFormOptions;
  Form: TForm;
  DefOpts: TDlgBasicInputOptions;
begin
  Opt := AMyFormOptions;
  if Opt = [] then
    Opt := [myfoDialog, myfoRefreshParent, myfoMultiCopy];
  if IsModalFormOpen then
    Include(Opt, myfoModal);

  DefOpts := [dbioStatusBar];

  // ---- список зарегистрированных диалогов ----
  if AFormType = myfrm_Dlg_R_Jobs then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'w_jobs', 'Должность', 400, 100,
      [['name$s', cntEdit, 'Должность','1:400::T'],
       ['comm$s', cntEdit, 'Комментарий','0:400::T'],
       ['has_milk_compensation$i', cntCheck, 'Компенсация'#13#10'за молоко'],
       ['active$i', cntCheckX, 'Используется']],
      [['caption dlgedit dlgactive']])
  else if AFormType = myfrm_Dlg_R_TurvCodes then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'w_turvcodes', 'Обозначение ТУРВ', 450, 130,
      [['code$s', cntEdit, 'Код','1:25::T'],
       ['name$s', cntEdit, 'Расшифровка','1:400::T']],
      [['caption dlgedit']])
  else if AFormType = myfrm_Dlg_R_Divisions then
    TFrmWDedtDivision.Show(AOwner, AFormType, Opt, AMode, AId, Null)
  else if AFormType = myfrm_Dlg_RefExpenseItems then
    TFrmCDedtExpenseItem.Show(AOwner, AFormType, Opt + [myfoSizeable], AMode, AId, Null)
  else if AFormType = myfrm_Dlg_R_Workers then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'w_employees', 'Работник', 600, 70,
      [['f$s', cntEdit, 'Фамилия','1:25::T'],
       ['i$s', cntEdit, 'Имя','1:25::T'],
       ['o$s', cntEdit, 'Отчество','0:25::T'],
       ['birthday$d', cntDEdit, 'Дата'#13#10'рождение',''],
       ['is_concurrent$i', cntCheck, 'Совместитель',''],
       ['comm$s', cntEdit, 'Комментарий','0:400::T']],
      [['caption dlgedit']])
  else if AFormType = myfrm_Dlg_ForemanAllowance then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'w_turv_period', 'Бригадирские', 400, 100,
      [['foreman_allowance$i', cntNEdit, 'Сумма', '0:10000'],
       ['foreman_allowance_comm$s', cntEdit, 'Комментарий','0:400::T']],
      [['caption dlgedit']])
  else if AFormType = myfrm_Dlg_Work_Schedule then
    TFrmWWedtWorkSchedule.Show(Application, AFormType, [myfoDialog, myfoMultiCopy], AMode, AId, Null)
  else if AFormType = myfrm_Dlg_R_StdProjects then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'or_projects', 'Типовой проект', 400, 100,
      [['name$s', cntEdit, 'Наименование','1:400'],
       ['active$i', cntCheckX, 'Используется']],
      [['caption dlgedit dlgactive']])
  else if AFormType = myfrm_Dlg_R_StdPspFormats then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'or_formats', 'Стандартный формат паспорта', 400, 100,
      [['name$s', cntEdit, 'Наименование','1:400'],
       ['active$i', cntCheckX, 'Используется']],
      [['caption dlgedit dlgactive']])
  else if AFormType = myfrm_Dlg_RefSuppliers then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'ref_suppliers;;sq_ref_suppliers', 'Данные поставщика', 400, 100,
      [['legalname$s', cntEdit, 'Наименование','1:400'],
       ['active$i', cntCheckX, 'Используется']],
      [['caption dlgedit dlgactive']])
  else if AFormType = myfrm_Dlg_R_GrExpenseItems then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'ref_grexpenseitems;;sq_ref_grexpenseitems', 'Группа статей расходов', 450, 130,
      [['name$s', cntEdit, 'Наименование','1:400']],
      [['caption dlgedit']])
  else if AFormType = myfrm_Dlg_R_ComplaintReasons then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'ref_complaint_reasons', 'Причина рекламации', 450, 130,
      [['name$s', cntEdit, 'Наименование','1:400'],
       ['active$i', cntCheckX, 'Используется']],
      [['caption dlgedit dlgactive']])
  else if AFormType = myfrm_Dlg_R_DelayedInprodReasons then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'ref_delayed_prod_reasons', 'Причина задержки в производстве', 450, 130,
      [['name$s', cntEdit, 'Наименование','1:400'],
       ['active$i', cntCheckX, 'Используется']],
      [['caption dlgedit dlgactive']])
  else if AFormType = myfrm_Dlg_R_RejectionOtkReasons then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'ref_otk_reject_reasons', 'Причина неприёмки ОТК', 450, 130,
      [['name$s', cntEdit, 'Наименование','1:400'],
       ['active$i', cntCheckX, 'Используется']],
      [['caption dlgedit dlgactive']])
  else if AFormType = myfrm_Dlg_RefColors then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'ref_colors;;sq_ref_colors', 'Цвет', 400, 100,
      [['article$s', cntEdit, 'Артикул','1:20'],
       ['name$s', cntEdit, 'Наименование','1:400']],
      [['caption dlgedit']])
  else if AFormType = myfrm_Dlg_Pick_General_Fittings then
    // Form := ...
  else if AFormType = myfrm_Dlg_Pick_GrItems then
    // Form := ...
  else if AFormType = myfrm_Dlg_PickItem then
    // Form := ...
  else if AFormType = myfrm_Dlg_SnCalendar then
    TFrmCDedtAccount.Show(AOwner, AFormType, [myfoDialog, myfoSizeable, myfoMultiCopy], AMode, AId, AAddParam)
  else if AFormType = myfrm_Dlg_Sn_Defectives then
    // Form := ...
  else if AFormType = myfrm_Dlg_Sn_Defectives_Act then
    // Form := ...
  else if AFormType = myfrm_Dlg_Ref_JobsNeeded then
    TFrmBasicInput.ShowDialogDB3(AOwner, AFormType, DefOpts, AMode, AId, 'ref_workers_needed', 'Работник', 400, 100,
      [['id_job$i', cntComboLK, 'Профессия','1:400'],
       ['id_division$i', cntComboLK, 'Подразделение','1:400']],
      [],
      ['select name, id from ref_jobs where active = 1 order by name',
       'select name, id from ref_divisions where active = 1 order by name'],
      [['caption dlgedit']])
  else if AFormType = myfrm_Dlg_R_Organizations then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'ref_sn_organizations;;sq_ref_sn_organizations', 'Свои организации', 400, 100,
      [['name$s', cntEdit, 'Наименование','1:30'],
       ['name$s', cntEdit, 'Реквизиты','0:100:0:N'],
       ['active$i', cntCheckX, 'Используется']],
      [['caption dlgedit dlgactive']])
  else if AFormType = myfrm_Dlg_R_Locations then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'ref_sn_locations;;sq_ref_sn_locations', 'Свои адреса', 400, 100,
      [['name$s', cntEdit, 'Адрес','1:400'],
       ['active$i', cntCheckX, 'Используется']],
      [['caption dlgedit dlgactive']])
  else if AFormType = myfrm_Dlg_R_CarTypes then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'ref_otk_reject_reasons', 'Типы транспортных средств', 400, 100,
      [['name$s', cntEdit, 'Тип','1:100'],
       ['active$i', cntCheckX, 'Используется']],
      [['caption dlgedit dlgactive']])
  else if AFormType = myfrm_Dlg_Turv then
    TFrmWGEdtTurvN.Show(AOwner, AFormType, [myfoDialog, myfoSizeable, myfoEnableMaximize, myfoMulticopy], AMode, AId, Null)
  else if AFormType = myfrm_Dlg_AddTurv then
    Turv.CreateAllTurvForDate(AOwner, Turv.GetTurvBegDate(Date))
  else if AFormType = myfrm_Dlg_AdvanceCalc then
    TFrmWGedtAdvance.Show(AOwner, AFormType, [myfoDialog, myfoSizeable, myfoMulticopy, myfoEnableMaximize], AMode, AId, AAddParam)
  else if AFormType = myfrm_Dlg_PayrollCalc then
    TFrmWGedtPayrollCalc.Show(AOwner, AFormType, [myfoDialog, myfoSizeable, myfoMulticopy, myfoEnableMaximize], AMode, AId, TVarDynArray(AAddParam)[1])
  else if AFormType = myfrm_Dlg_AdvanceTransfer then
    TFrmWGedtAdvanceTransfer.Show(AOwner, AFormType, [myfoDialog, myfoSizeable, myfoMulticopy, myfoEnableMaximize], AMode, AId, AAddParam)
  else if AFormType = myfrm_Dlg_PayrollTransfer then
    TFrmWGedtPayrollTransfer.Show(AOwner, AFormType, [myfoDialog, myfoSizeable, myfoMulticopy, myfoEnableMaximize], AMode, AId, AAddParam)
  else if AFormType = myfrm_Dlg_AdvanceCash then
    TFrmWGedtAdvanceCash.Show(AOwner, AFormType, [myfoDialog, myfoSizeable, myfoMulticopy, myfoEnableMaximize], AMode, AId, AAddParam)
  else if AFormType = myfrm_Dlg_PayrollCash then
    TFrmWGedtPayrollCash.Show(AOwner, AFormType, [myfoDialog, myfoSizeable, myfoMulticopy, myfoEnableMaximize], AMode, AId, AAddParam)
  else if AFormType = myfrm_Dlg_Candidate then
    // Form := ...
  else if AFormType = myfrm_Dlg_Vacancy then
    // Form := ...
  else if AFormType = myfrm_Dlg_Order then
//    Form := TDlg_Order.ShowDialog(AOwner, AFormType, AMode, AId, Opt, AAddParam)
    TFrmOWOrder.Show(AOwner, AFormType, [myfoSizeable, myfoDialog, myfoEnableMaximize], AMode, AId, AAddParam)
  else if AFormType = myfrm_Dlg_R_Candidates_Ad then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'ref_candidates_ad;;sq_ref_suppliers', 'Источники информации о вакансии', 400, 100,
      [['name$s', cntEdit, 'Наименование','1:100']],
      [['caption dlgedit']])
  else if AFormType = myfrm_Dlg_Or_FindNameInEstimates then
    TFrmOWSearchInEstimates.Show(AOwner, AFormType, Opt + [myfoSizeable], AMode, AId, Null)
  else if AFormType = myfrm_Dlg_Or_ItmInfo then
    Form := TDlg_ItmInfo.Create(AOwner, AFormType, Opt + [myfoSizeable], AMode, AId, Null)
  else if AFormType = myfrm_Dlg_Bcad_Groups then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'bcad_groups', 'Группа bCAD', 450, 90,
      [['name$s', cntEdit, 'Наименование','1:100']],
      [['caption dlgedit']])
  else if AFormType = myfrm_Dlg_Bcad_Units then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'bcad_units', 'Ед. изм. bCAD', 450, 90,
      [['name$s', cntEdit, 'Наименование','1:100']],
      [['caption dlgedit']])
  else if (AFormType = myfrm_Dlg_J_Devel) or (AFormType = myfrm_Dlg_J_DevelThn) then
    TFrmODedtDevel.Show(AOwner, AFormType, Opt + [myfoSizeable], AMode, AId, Null)
  else if AFormType = myfrm_Dlg_R_Customer_Main then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'ref_customers', 'Покупатель', 400, 100,
      [['name$s', cntEdit, 'Наименование','1:100'],
       ['wholesale$i', cntCheck, 'Оптовый'],
       ['active$i', cntCheckX, 'Используется']],
      [['caption dlgedit dlgactive']])
  else if AFormType = myfrm_Dlg_R_Customer_Contact then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'ref_customer_contact', 'Контактная информация', 400, 100,
      [['name$s', cntEdit, 'Контактное лицо','1:100'],
       ['contact$s', cntEdit, 'Контактное лицо','1:400'],
       ['active$i', cntCheckX, 'Используется']],
      [['caption dlgedit dlgactive']])
  else if AFormType = myfrm_Dlg_R_Customer_Legal then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'ref_customer_legal', 'Юридическое наименование', 400, 100,
      [['legalname$s', cntEdit, 'Наименование','1:100'],
       ['inn$s', cntEdit, 'ИНН','10:12'],
       ['active$i', cntCheckX, 'Используется']],
      [['caption dlgedit dlgactive']])
  else if AFormType = myfrm_Dlg_J_Montage then
    Form := TDlg_J_Montage.Create(AOwner, AFormType, Opt, AMode, AId, AAddParam)
  else if AFormType = myfrm_Dlg_Rep_Order_Primecost2 then
    TFrmOWrepOrdersPrimeCost.Show(AOwner, AFormType, Opt, fNone, Null, Null)
  else if AFormType = myfrm_Dlg_R_OrderStdItems then
    TFrmODedtOrStdItem.Show(AOwner, AFormType, Opt, AMode, AId, AAddParam)
  else if AFormType = myfrm_Dlg_NewEstimateInput then
    Form := TDlg_NewEstimateInput.Create(AOwner, AFormType, Opt, AMode, AId, AAddParam)
  else if AFormType = myfrm_Dlg_SupplierMinPart then
    Form := TDlg_SuppliersMinPart.Create(AOwner, AFormType, Opt, AMode, AId, AAddParam)
  else if AFormType = myfrm_Dlg_R_Spl_Categoryes then
    TFrmODedtSplCategoryes.Show(AOwner, AFormType, Opt + [myfoSizeable], AMode, AId, Null)
  else if A.InArray(AFormType, [myfrm_Dlg_Spl_InfoGrid_MoveNomencl, myfrm_Dlg_Spl_InfoGrid_DiffInOrder]) then
    Form := TDlg_Spl_InfoGrid.Create(AOwner, AFormType, [myfoModal, myfoSizeable, myfoDialog], fView, AId, AAddParam)
  else if AFormType = myfrm_Dlg_R_Itm_Units then
    TFrmODedtItmUnits.Show(AOwner, AFormType, Opt + [myfoDialog], AMode, AId, Null)
  else if AFormType = myfrm_Dlg_R_Itm_Suppliers then
    TFrmDlgRItmSupplier.Show(AOwner, AFormType, Opt + [myfoDialog, myfoSizeable], AMode, AId, Null)
  else if AFormType = myfrm_Dlg_Sgp_Revision then
    TFrmOGedtSgpRevision.Show(AOwner, AFormType, Opt + [myfoSizeable, myfoDialog], AMode, AId, AAddParam)
  else if AFormType = myfrm_Dlg_InvoiceToSgp then
    TFrmOWInvoiceToSgp.Show(AOwner, AFormType, Opt + [myfoSizeable, myfoMultiCopy, myfoDialog], AMode, AId, AAddParam)
  else if AFormType = myfrm_Dlg_EditNomenclatura then
    TFrmDlgEditNomenclatura.Show(AOwner, AFormType, Opt + [myfoSizeable, myfoMultiCopy, myfoDialog], AMode, AId, AAddParam)
  else if AFormType = myfrm_Dlg_J_Tasks then
    TFrmODedtTasks.Show(AOwner, AFormType, Opt + [myfoMultiCopy, myfoDialog], AMode, AId, AAddParam)
  else if AFormType = myfrm_Dlg_R_OrderTypes then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'order_types', 'Типы заказов', 400, 100,
      [['name$s', cntEdit, 'Наименование','1:100'],
       ['is_production_order$i', cntCheck, 'Прозводственный'],
       ['is_semiproduct_order$i', cntCheck, 'Полуфабрикат'],
       ['is_shipment_order$i', cntCheck, 'Отгрузочный'],
       ['is_complaint$i', cntCheck, 'Рекламация'],
       ['is_additional_order$i', cntCheck, 'Дозаказ'],
       ['need_ref$i', cntCheck, 'Сcылка'#13#10'на заказ'],
       ['is_nonstandard$i', cntCheck, 'Нестандарт'],
       ['is_cash_payment$i', cntCheck, 'Наличные'],
       ['active$i', cntCheckX, 'Используется']],
      [['caption dlgedit dlgactive']])
  else if AFormType = myfrm_Dlg_R_WorkCellTypes then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'work_cell_types', 'Типы производственных участков', 400, 100,
      [['code$s', cntEdit, 'Код','1:4::TU'],
       ['name$s', cntEdit, 'Наименование','1:100::T'],
       ['active$i', cntCheckX, 'Используется']],
      [['caption dlgedit dlgactive']])
  else if AFormType = myfrm_Dlg_R_OrderProperties then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'order_properties', 'Свойства заказов', 400, 100,
      [['name$s', cntEdit, 'Наименование','1:100'],
       ['grp$i', cntNEdit, 'Группа', '1:99:0'],
       ['active$i', cntCheckX, 'Используется']],
      [['caption dlgedit dlgactive']])
  else if AFormType = myfrm_Dlg_R_OrderReglament then
    TFrmOWedtOrReglament.Show(AOwner, AFormType, Opt + [myfoSizeable, myfoMultiCopy, myfoDialog], AMode, AId, AAddParam)
  else if AFormType = myfrm_Dlg_Rep_OrderReglament then
    TFrmOGrepOrReglament.Show(AOwner, AFormType, Opt + [myfoMultiCopy, myfoDialog], fNone, AId, Null)
  else if AFormType = myfrm_Dlg_ProdCalculation then
    TFrmOWedtProdCalculation.Show(AOwner, AFormType, Opt + [myfoSizeable, myfoMultiCopy, myfoDialog, myfoEnableMaximize], AMode, AId, AAddParam)
  else if AFormType = myfrm_Dlg_R_PnlOpsPainting then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'pnl_ref_ops_painting', 'Производственные операции по лакокраске', 700, 100,
      [['name$s', cntEdit, 'Наименование','1:400::T'],
       ['norm$f', cntNEdit, 'Норма, мин.', '0.06:600:2:N'],
       ['active$i', cntCheckX, 'Используется']],
      [['caption dlgedit dlgactive']])
  else if AFormType = myfrm_Dlg_PnlOpsForItem then
    TFrmPWedtPlnOps.Show(AOwner, AFormType, Opt + [myfoSizeable], AMode, AId, AAddParam)
  else if AFormType = myfrm_Dlg_Test then
    // пусто
  else
    raise Exception.Create('Вызвана функция "ExecDialog", однако тип "' + AFormType + '" в ней не зарегистрирован!');
end;

procedure TWindowsHelper.ExecAdd(const AFormType: string; AOwner: TComponent; const AMode: TDialogType; const AId: Variant; const AMyFormOptions: TMyFormOptions; const AAddParam: Variant; const AShowModal: Boolean = False; const ADlgFunction: TDlgFunction = nil);
//универсальный метод (не используется)
begin
end;

begin
  Wh := TWindowsHelper.Create;
end.
