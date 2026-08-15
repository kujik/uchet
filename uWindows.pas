{
работа с окнами приложения

создает и корректирует список открытых окон в нижней строку приложения
(для этого не требуется при вызове форм использовать какой-либо код)
в список включаются как мди-чайлд так и диалоговые окна
по клику на наименовании в тулбаре выбранное окно активируется
}

unit uWindows;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh,
  GridsEh, DBAxisGridsEh, DBGridEh, Math, TypInfo, uData,
  uString, uSys;

type
  TmyWindowsStateChangeMode = (mywscmCreate, mywscmActivate, mywscmDestroy, mywscmChange);

type
  TDlgFunction = function(FSelf: TForm; Mode: Integer): Variant;

type
  //сохраненные при открытии параметры формы
  TWindowRecord = record
    Handle: HWND;
    Form: TForm;
    FormDoc: string;
    Title: string;
    Number: Integer;
  end;

//  TTest = (aa = 1, bb = 255, cc = 4);
  TTest = (aa, bb, cc);

  //список активных окон (только принадлежащих приложению)
  //по индексу синхронизирован с тулбаром окон
  TWindowsArray = array of TWindowRecord;

  TWindowsHelper = class
  private
    //массив открытых форм
    FWindows: TWindowsArray;
    FUseWindowsBar: Boolean;
    //обработка событий изменения состояния форм
    procedure WindowsBarChange(AForm: TForm; AHandle: HWND; Mode: TmyWindowsStateChangeMode);
  public
    //ModalResult, возвращенный формой при показе ее в модальном режиме
    ModalResult: Integer;
    //здесь возвращаются результирующие данные, при показе в модальном режиме
    //возвращается при закрытии формы, дочерней от Form_MDI,
    //Form_MDI.FormDialogResult при создании устанавливается в 0 (mrNone), и должен выставляться явно в потомках, а сюда пишется при закрытии формы ее поле
    FormDialogResult: Integer;
    //как правило строка из memtableeh
    SelectDialogResult: TVarDynArray;
    //как правило набор строк из memtableeh
    SelectDialogResult2: TVarDynArray2;
    //коллекция окон - строка соответствует ТипОкна__НомерОкна, а объект соотв объекту формы (не классу!)
    property Windows: TWindowsArray read FWindows;
    //конструктор
    constructor Create();
    //события изменения состояния форм
    procedure ChildFormCreate(Sender: TObject);
    procedure ChildFormActivate(Sender: TObject);
    procedure ChildFormDestroy(Sender: TObject);
    procedure ActiveFormChange(Sender: TObject);
    //вызываем при нажатии кнопки в тулбаре - окно на передний план
    //наименования кнопок в тулбаре соответствуют строкам коллекции окон
    procedure BringToFrontMDIForm(Sender: TObject);
    //для диалогов
    //проверим, есть ли окно с таким AFormDoc (и AId, если задано не null)
    //если есть, переключим его на передний план и вернем False
    function BringToFrontIfExists(AFormDoc: string; AId: Variant): Boolean;
    //получим количество открытых мди-форм с таким же FormDoc как у переданной
    //(для форм, не являющихся TForm_MDI или TForm_Normal используется заголовок формы)
    //также может учитывать АйДи (только для TForm_MDI), если AId не null
    //форма может не передаваться, тогда ищет по FormDoc и Id
    function GetWindowsCount(var AForm: TForm; AFormDoc: string; AId: Variant; var MaxNum: Integer): Integer; overload;
    function GetWindowsCount(AFormDoc: string; AId: Variant; var MaxNum: Integer): Integer; overload;
    //вызывается при получении фокуса чилд-формой, которая передается в параметре
    //сделаем кнопку, соответствующую активной форме, нажатой
    //НЕ ИСПОЛЬЗУЕМ
    procedure HiglightActiveForm(AForm: TForm);
    //вернет объект формы, если он найден в коллекции открытых окон, иначе nil
    function GetFormFromWindows(AForm: TForm): TForm;
    //проверим, открыта ли в приложении модальная форма
    function IsModalFormOpen: Boolean;
    //открываем фолрму TForm_Reference или ее потомков
    procedure ExecReference(const AFormType: string); overload;
    procedure ExecReference(const AFormType: string; AOwner: TComponent; const AMyFormOptions: TMyFormOptions; const AAddParam: Variant); overload;
//    procedure ExecReferenceAdd(F: string; AOwner: TForm; fMode: TDialogType; AId: Variant; AMyFormOptions: TMyFormOptions; AAddParam: Variant; ShowModal: Boolean = False; TDlgFunction: TDlgFunction = nil);
    //вызывает открытие mdi-формы в режиме диалога
    //если AMyFormOptions передано пустым, то заполняется по дефолту для диалога
    procedure ExecDialog(const AFormType: string; AOwner: TComponent; const AMyFormOptions: TMyFormOptions; const AMode: TDialogType; const AId: Variant; const AAddParam: Variant);
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
  D_J_Montage,
  D_SuppliersMinPart,
  D_Spl_InfoGrid,
  F_Adm_Installer,

  uFrmXGsrvSqlMonitor, uFrmXAdmSqlCommentSync, uFrmXAdmSqlUpdater,

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
  uFrmOWOrder, uFrmOWRepOrderChanges, uFrmOWrepEstimateChanges, uFrmOWedtSetOrderRoute,
  uFrmOWItmInfo,

  uFrmPWedtPlnOps,

  uFrmXGlstMain,
  uFrmBasicInput
  ;

constructor TWindowsHelper.Create();
begin
  inherited;
  FUseWindowsBar := True;
 // FUseWindowsBar := False;
end;

procedure TWindowsHelper.ChildFormCreate(Sender: TObject);
//при создании мди-формы
begin
  //WindowsBarChange(Sender, TForm(Sender).Handle, mywscmCreate);
end;

procedure TWindowsHelper.ChildFormActivate(Sender: TObject);
//при активации мди-формы (сразу после создания),
//и при получении ей фокуса при переключении между формами
begin
//exit;
  WindowsBarChange(TForm(Sender), TForm(Sender).Handle, mywscmActivate);
end;

procedure TWindowsHelper.ChildFormDestroy(Sender: TObject);
//при разрушении мди-формы
begin
//exit;
  WindowsBarChange(TForm(Sender), TForm(Sender).Handle, mywscmDestroy);
end;

procedure TWindowsHelper.ActiveFormChange(Sender: TObject);
//при смене активной формы, не работает при переключении между мди-чайлд, только при диалоговых
var
  st: string;
begin
{
  if Sender = nil
  then Exit;
  st:=TForm(Sender).Name;
  if st = '' then Exit;}
 // if (Sender is TForm_MDI)or(Sender is TForm_Normal) then
//  WindowsBarChange(TForm(Sender), GetForegroundWindow, mywscmChange);
  WindowsBarChange(nil, GetForegroundWindow, mywscmChange);
end;

procedure TWindowsHelper.WindowsBarChange(AForm: TForm; AHandle: HWND; Mode: TmyWindowsStateChangeMode);
//обработка событий изменения состояния форм (создание/активация/уничтожение окон) -
//создание и удаление кнопок в баре окон, обновление их состояния (галки/точки)
var
  st: string;
  Tbt: TToolButton;
  i: Integer;
  ButtonMissing: Boolean;
  IsTargetButton: Boolean;
  WindowsTitle: string;
  WindowsCount, MaxNum: Integer;
  WRec: TWindowRecord;
  fd: string;
const
  cGreenGalka = 1;
  cRedGalka = 3;
  cGreenDot = 10;
  cRedDot = 11;

  function IsParent(Control: HWND): Boolean;
  //проверим (рекурсивно), принадлежит ли окно приложению
  //то есть какой-то предор переденного окна принадлежит главной форме или приложению
  begin
    result := False;
    //для диалоговых форм может быть парент = Application.Handle, для МДИ FrmMain.Handle
    if (GetParent(Control) <> Application.Handle) and (GetParent(Control) <> FrmMain.Handle) then begin
      //если неизвестный рордитель, то рекурсия
      if GetParent(Control) <> 0 then
        result := IsParent(GetParent(Control))
    end
    else
      result := True;
  end;

begin
  if not FUseWindowsBar then
    Exit;
  //выйдем, если нет панели окон (напромер, при завершении программы)
  if FrmMain.FormsList = nil then
    Exit;
  //если перехватилось окно, не относящееся к нашему исполняемому файлу - выход
//  if Sys.GetModuleFileByHandle(AHandle) <> ParamStr(0) then
//    Exit;
//  if not IsParent(AHandle) then
//    Exit;
  //заголовок активного окна
  WindowsTitle := Sys.GetWindowHeader(AHandle);
  //Sys.SaveTextToFile('r:\321', VarToStr(mode) + '   ' + VarToStr(Ahandle) + '   ' + Sys.GetWindowHeader(Ahandle) + '   ' +  Sys.GetModuleFileByHandle(handle) + #13#10, True);

  if (IsParent(AHandle)) or
     ((AForm is TForm_MDI) and (TForm_MDI(AForm).ModuleId = cMainModule)) or
     ((AForm is TFrmBasicMdi) and (TFrmBasicMdi(AForm).ModuleId = cMainModule)) or
     ((AForm is TForm_Normal) and (TForm_Normal(AForm).ModuleId = cMainModule)) then begin
  //все добавления кнопок для окон только если форма принадлежит приложению,
  //либо это один из наших основных типов форм
  //(почему-то не всегда проверка IsParent возвращает для них True, в частности вызов диалога просмотра заказа из уже дималогового окна (отчет по изд в заказах),
  //возможно там родителем передан nil, хотя вроде такого не наблюдал
  //при проверке по типам может еще по идее подхватывать окна других модулей учета, пока оставил проверку на родительский файл, но неясно как она работает
  //можно сделать в онкреате присвоения номера модуля в типовых формах - сделал

  //подменим заголовок для диалоговых окон
  if WindowsTitle = ModuleRecArr[cMainModule].Caption then
    WindowsTitle := 'Диалог';
  ButtonMissing := True;
  //проверим, есть ли переданный хендл окна в списке
  for i := FrmMain.FormsList.ComponentCount - 1 downto 0 do
    if (FrmMain.FormsList.Buttons[i].Tag = AHandle) and (FrmMain.FormsList.Buttons[i].Visible) then begin
      ButtonMissing := False;
      Break
    end;
  //если нет, и это не главное окно - создаем кнопку в тулбаре
  if (ButtonMissing and (AHandle <> FrmMain.Handle)) {and (Sys.GetModuleFileByHandle(AHandle) = ParamStr(0))} then begin
    //получим количество открытых мди-форм и нормал-форм с таким же заголовком как у переданной
    //WindowsCount вылетает по ошибке на получении Form.Captions, если это например окно стандартного диалога,
    //поэтому эта проверка нужна
    if (AForm is TForm_MDI) or (AForm is TForm_Normal) or (AForm is TFrmBasicMdi) then
      WindowsCount := GetWindowsCount(AForm, '', null, MaxNum)
    else
      WindowsCount := 0; //111
    Tbt := TToolButton.Create(FrmMain.FormsList);
    Tbt.Parent := FrmMain.FormsList;
    Tbt.Visible := True;
    Tbt.Height := 24;
    Tbt.AutoSize := True;
    Tbt.Style := tbsTextButton;
    Tbt.Down := True;
    Tbt.ImageIndex := -1; //без картинки //MyData.Il_All16
    Tbt.Tag := AHandle;   //сохраним хендл
    //нужно, чтобы кнопка создавалась правее существующих - без этого создается первой, в крайней левой позиции
    Tbt.Left := 10000;
    //заголовок - капшин окна и его номер, если не перевое окно
//    Tbt.Caption:= WindowsTitle + S.IIf(WindowsCount <= 0, ' ' , '  |' + IntToStr(WindowsCount));
//    Tbt.Caption := WindowsTitle + S.IIf(MaxNum <= 0, ' ', '  |' + IntToStr(MaxNum + 1));
    Tbt.Caption :=
      S.IIf(ParamStr(0) <> Sys.GetModuleFileByHandle(AHandle), Sys.GetModuleFileByHandle(AHandle) + ' - ' , '')+
      WindowsTitle + S.IIf(MaxNum <= 0, ' ', '  |' + IntToStr(MaxNum + 1));
    //событие клика
    FrmMain.SetFormsToolButtonClick;
    //соберем данные для массива окон
    fd := '';
    if (AForm is TForm_Normal) then
      fd := TForm_Normal(AForm).FormDoc;
    if (AForm is TForm_MDI) then
      fd := TForm_MDI(AForm).FormDoc;
    if (AForm is TFrmBasicMdi) then
      fd := TFrmBasicMdi(AForm).FormDoc;
    WRec.Handle := AHandle;
    WRec.Form := AForm;
    WRec.FormDoc := fd;
    WRec.Title := WindowsTitle;
    WRec.Number := MaxNum + 1;
    //в массив
    FWindows := FWindows + [WRec];
  end;


  end;

  //меняем стутусы (картинки) и удаляем кнопки для несуществующих окон при либых изменениях стутуса окон!!!

  //удалим кнопки, к которым уже не привязаны окна
  if ((not IsModalFormOpen) and (Mode = mywscmChange)) or True then  //+++++++++++++++++!!!!!!!!!!!!!!!!!
    for i := FrmMain.FormsList.ComponentCount - 1 downto 0 do begin
      if FrmMain.FormsList.Buttons[i].Caption = '----' then begin
        FrmMain.FormsList.Buttons[i].OnClick := nil;
        try
          Delete(FWindows, i, 1);
          FrmMain.FormsList.Buttons[i].Destroy;
        except
        end;
      end;
    end;
  with FrmMain.FormsList do begin
//    for i:= ComponentCount - 1 downto 0 do Sys.SaveTextToFile('r:\322', VarToStr(mode) + '   ' + VarToStr(Buttons[i].Tag) + ' ' + VarToStr(Ahandle) +#13#10, True);
    //пройдем по бару окон
    for i := ComponentCount - 1 downto 0 do begin
      //это ли это окно, которое сейчас получило событие
      if Trim(Buttons[i].Caption) = '' then begin
        try
          Buttons[i].Destroy;
          Delete(FWindows, i, 1);
          Continue;
        except
        end;
      end;
      IsTargetButton := (AHandle = Buttons[i].Tag);
      if (IsModalFormOpen) or ((AForm is TForm_MDI) and (AForm.FormStyle = fsNormal)) or ((AForm is TFrmBasicMdi) and (AForm.FormStyle = fsNormal)) then begin
        //если модальный режим - переведем галки в точки, на текущую поставим красную галку
        if Buttons[i].ImageIndex = cGreenGalka then
          Buttons[i].ImageIndex := cGreenDot
        else if Buttons[i].ImageIndex = cRedGalka then
          Buttons[i].ImageIndex := cRedDot;
        if IsTargetButton then
          Buttons[i].ImageIndex := cRedGalka;
      end
      else begin
        //если не модальный режим, то при активации мди-формы поставим для нее зеленую галку, а остальные снимем
        //если здесь не проверять на mywscmActivate, то галки просто все снимаются
        if Mode = mywscmActivate then begin
          if IsTargetButton then
            Buttons[i].ImageIndex := cGreenGalka
          else
            Buttons[i].ImageIndex := -1;
        end
        else if Buttons[i].ImageIndex = cGreenDot then
          //а если не активация (закрыли модальную) - зеленую точку заменим на зеленую галку
          Buttons[i].ImageIndex := cGreenGalka;
      end;
    end;
    //пройдем по окнам и удалим кнопки для несуществующих
    for i := ComponentCount - 1 downto 0 do begin
      if ((Buttons[i].Tag > 0) and (Buttons[i].Tag = AHandle) and (Mode = mywscmDestroy)) or ((Buttons[i].Tag <> GetForegroundWindow) and (not IsWindowVisible(Buttons[i].Tag))) then begin
        //удалим и кнопки и инфу в массиве
        //!если запущена форма форммди в модальном режиме, то при ее закрытии валится на Buttons[i].Destroy
        //если удаление проводить сразу после цикла, то результат тот же.
        //вышел из положения, пометив кнопку, и удаляю ее в этой процедуре ПЕРЕД формированием тулбара, она в итоге после закрытия окна исчезает
        if Pos('--', Buttons[i].Caption) = 0 then
          Buttons[i].Caption := '--' + Buttons[i].Caption;
        Buttons[i].Visible := False;
        FWindows[i].Form := nil;
        FWindows[i].FormDoc := '';

//        Buttons[i].Destroy;
//        Delete(FWindows, i, 1);
      end;
    end;
  end;
end;

procedure TWindowsHelper.BringToFrontMDIForm(Sender: TObject);
//вызываем при нажатии кнопки в тулбаре - окно на передний план
var
  i, j: Integer;
  c: TToolButton;
begin
  try
    for i := 0 to High(FWindows) do
      if FWindows[i].Handle = TToolButton(Sender).Tag then begin
      //должен быть объект, и это должна быть форма, тогда пытаемся переключить ее на передний план
        if (IsWindowVisible(TToolButton(Sender).Tag)) and (FWindows[i].Form <> nil) and (FWindows[i].Form is TForm) and (FWindows[i].Form.WindowState = wsMinimized) then
          FWindows[i].Form.WindowState := wsNormal;
        FWindows[i].Form.BringToFront;
      end;
  except
  end;
end;

function TWindowsHelper.BringToFrontIfExists(AFormDoc: string; AId: Variant): Boolean;
//для диалогов
//проверим, есть ли окно с таким AFormDoc (и AId, если задано не null)
//если есть, переключим его на передний план и вернем False
var
  i: Integer;
  id1: Variant;
begin
  Result := True;
  for i := 0 to High(FWindows) do begin
    id1 := #1#2;
    if FWindows[i].Form is TForm_Mdi then
      id1 := TForm_Mdi(FWindows[i].Form).Id;
    if FWindows[i].Form is TFrmBasicMdi then
      id1 := TFrmBasicMdi(FWindows[i].Form).Id;
    if (AFormDoc = FWindows[i].FormDoc) and ((AId = null) or (AId = id1)) then begin
      if (AId = null) or (AId = id1) then begin
        FWindows[i].Form.BringToFront;
        Result := False;
        Exit;
      end;
    end;
  end;
end;

function TWindowsHelper.GetWindowsCount(AFormDoc: string; AId: Variant; var MaxNum: Integer): Integer;
//получим количество открытых мди-форм с таким же FormDoc как у переданной
//также может учитывать АйДи (только для TForm_MDI), если AId не null   -- !!! не рабоотает
var
  i, j: Integer;
  st1, st2: string;
  id1, id2: Variant;
begin
  Result := 0;
  MaxNum := 0;
  for i := 0 to High(FWindows) do begin
    if (AFormDoc = FWindows[i].FormDoc) and ((AId = null) or (AId = id1)) then begin
      inc(Result);
      MaxNum := Max(FWindows[i].Number, MaxNum);
    end;
  end;
end;

function TWindowsHelper.GetWindowsCount(var AForm: TForm; AFormDoc: string; AId: Variant; var MaxNum: Integer): Integer;
//получим количество открытых мди-форм с таким же FormDoc как у переданной
//(для форм, не являющихся TForm_MDI или TForm_Normal используется заголовок формы)
//также может учитывать АйДи (только для TForm_MDI), если AId не null
//форма может не передаваться, тогда ищет по FormDoc и Id
var
  i, j: Integer;
  st1, st2: string;
  id1, id2: Variant;
begin
  Result := 0;
  MaxNum := 0;
  id1 := null;
  st1 := '';
  if AForm is TForm_MDI then begin
    st1 := TForm_MDI(AForm).FormDoc;
    id1 := TForm_MDI(AForm).ID;
  end;
  if AForm is TFrmBasicMdi then begin
    st1 := TFrmBasicMdi(AForm).FormDoc;
    id1 := TFrmBasicMdi(AForm).ID;
  end;
  if AForm is TForm_Normal then
    st1 := TForm_Normal(AForm).FormDoc;
  //WindowsCount вылетает по ошибке на получении Form.Captions, если это например окно стандартного диалога а не наши шаблонные формы
//  if st1 = '' then
//    st1 := AForm.Caption;      //111
  for i := 0 to High(FWindows) do begin
    if (FWindows[i].Form is TForm) then begin
//      st2 := FWindows[i].Form.Caption;    //вызывает ошибку в некоторых случаях даже при проверке FWindows[i].Form is TForm
      if FWindows[i].Form is TForm_MDI then begin
        st2 := TForm_MDI(FWindows[i].Form).FormDoc;
        id1 := TForm_MDI(FWindows[i].Form).id;
      end;
      if FWindows[i].Form is TFrmBasicMdi then begin
        st2 := TFrmBasicMdi(FWindows[i].Form).FormDoc;
        id1 := TFrmBasicMdi(FWindows[i].Form).id;
      end;
      if FWindows[i].Form is TForm_Normal then
        st2 := TForm_Normal(FWindows[i].Form).FormDoc;
    end;
    if (FWindows[i].Form <> nil) and (st1 = st2) and ((AId = null) or (AId = id1)) then begin
      inc(Result);
      MaxNum := Max(FWindows[i].Number, MaxNum);
    end;
  end;
end;

procedure TWindowsHelper.HiglightActiveForm(AForm: TForm);
//вызывается при получении фокуса чилд-формой, которая передается в параметре
//сделаем кнопку, соответствующую активной форме, нажатой
//НЕ ИСПОЛЬЗУЕМ
var
  i, j: Integer;
  c: TToolButton;
  b, IsCurrForm: Boolean;
begin
  for i := 0 to High(FWindows) do begin
    //сделаем кнопку, соответствующую активной форме, нажатой
    with FrmMain.FormsList do
      if AForm <> nil then begin
        IsCurrForm := (AForm.Handle = Buttons[i].Tag);
        Buttons[i].Down := IsCurrForm;
        Buttons[i].ImageIndex := S.IIf(IsCurrForm, 0, -1);
      end;
  end;
end;

function TWindowsHelper.GetFormFromWindows(AForm: TForm): TForm;
//вернет объект формы, если он найден в коллекции открытых окон, иначе nil
var
  i: Integer;
begin
  for i := 0 to High(FWindows) do
    if FWindows[i].Form = AForm then begin
      Result := AForm;
      Exit;
    end;
end;

function TWindowsHelper.IsModalFormOpen: Boolean;
//проверим, открыта ли в приложении модальная форма
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
  else if AFormType = myfrm_Adm_SqlCommentSync then
    TFrmXAdmSqlCommentSync.Show(Application, AFormType, Opt, FNone, 0, Null)
  else if AFormType = myfrm_Adm_SqlUpdater then
    TFrmXAdmSqlUpdater.Show(Application, AFormType, Opt, FNone, 0, Null)
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
       ['phones$s', cntEdit, 'Телефон','0:400::T'],
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
  else if AFormType = myfrm_Rep_OrderChanges then
    TFrmOWRepOrderChanges.Show(AOwner, AFormType, Opt + [myfoSizeable, myfoDialog, myfoEnableMaximize], AMode, AId, AAddParam)
  else if AFormType = myfrm_Rep_EstimateChanges then
    TFrmOWrepEstimateChanges.Show(AOwner, AFormType, Opt + [myfoSizeable, myfoDialog, myfoEnableMaximize], AMode, AId, AAddParam)
  else if AFormType = myfrm_Dlg_SetOrderRoute then
    TFrmOWedtSetOrderRoute.Show(AOwner, AFormType, Opt, AMode, AId, AAddParam)
  else if AFormType = myfrm_Dlg_R_Candidates_Ad then
    TFrmBasicInput.ShowDialogDB(AOwner, AFormType, DefOpts, AMode, AId, 'ref_candidates_ad;;sq_ref_suppliers', 'Источники информации о вакансии', 400, 100,
      [['name$s', cntEdit, 'Наименование','1:100']],
      [['caption dlgedit']])
  else if AFormType = myfrm_Dlg_Or_FindNameInEstimates then
    TFrmOWSearchInEstimates.Show(AOwner, AFormType, Opt + [myfoSizeable], AMode, AId, Null)
  else if AFormType = myfrm_Dlg_Or_ItmInfo then
    //D_ItmInfo.pas удален из проекта - функциональность (проверка номенклатуры ИТМ) перенесена в uFrmOWItmInfo
    TFrmOWItmInfo.Show(AOwner, AFormType, Opt + [myfoSizeable], AMode, AId, Null)
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
    TFrmODedtOrStdItem.Show(AOwner, AFormType, Opt + [myfoSizeable], AMode, AId, AAddParam)
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
       ['is_nonstandard_only$i', cntCheck, 'Только'#13#10'нестандарт'],
       ['is_cash_payment$i', cntCheck, 'Наличные'],
       ['is_launch_by_manager$i', cntCheck, 'Запускает'#13#10'менеджер'],
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
