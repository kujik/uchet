{
������ � ������ ����������

������� � ������������ ������ �������� ���� � ������ ������ ����������
(��� ����� �� ��������� ��� ������ ���� ������������ �����-���� ���)
� ������ ���������� ��� ���-����� ��� � ���������� ����
�� ����� �� ������������ � ������� ��������� ���� ������������
}

unit uWindows;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, ADODataDriverEh,
  MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Math, TypInfo, uData,
  uString, uSys;

type
  TmyWindowsStateChangeMode = (mywscmCreate, mywscmActivate, mywscmDestroy, mywscmChange);

type
  TDlgFunction = function(FSelf: TForm; Mode: Integer): Variant;

type
  //����������� ��� �������� ��������� �����
  TWindowRecord = record
    Handle: HWND;
    Form: TForm;
    FormDoc: string;
    Title: string;
    Number: Integer;
  end;

//  TTest = (aa = 1, bb = 255, cc = 4);
  TTest = (aa, bb, cc);

  //������ �������� ���� (������ ������������� ����������)
  //�� ������� ��������������� � �������� ����
  TWindowsArray = array of TWindowRecord;

  TWindowsHelper = class
  private
    //������ �������� ����
    FWindows: TWindowsArray;
    FUseWindowsBar: Boolean;
    //��������� ������� ��������� ��������� ����
    procedure WindowsBarChange(AForm: TForm; AHandle: HWND; Mode: TmyWindowsStateChangeMode);
  public
    //ModalResult, ������������ ������ ��� ������ �� � ��������� ������
    ModalResult: Integer;
    //����� ������������ �������������� ������, ��� ������ � ��������� ������
    //������������ ��� �������� �����, �������� �� Form_MDI,
    //Form_MDI.FormDialogResult ��� �������� ��������������� � 0 (mrNone), � ������ ������������ ���� � ��������, � ���� ������� ��� �������� ����� �� ����
    FormDialogResult: Integer;
    //��� ������� ������ �� memtableeh
    SelectDialogResult: TVarDynArray;
    //��� ������� ����� ����� �� memtableeh
    SelectDialogResult2: TVarDynArray2;
    //��������� ���� - ������ ������������� �������__���������, � ������ ����� ������� ����� (�� ������!)
    property Windows: TWindowsArray read FWindows;
    //�����������
    constructor Create();
    //������� ��������� ��������� ����
    procedure ChildFormCreate(Sender: TObject);
    procedure ChildFormActivate(Sender: TObject);
    procedure ChildFormDestroy(Sender: TObject);
    procedure ActiveFormChange(Sender: TObject);
    //�������� ��� ������� ������ � ������� - ���� �� �������� ����
    //������������ ������ � ������� ������������� ������� ��������� ����
    procedure BringToFrontMDIForm(Sender: TObject);
    //��� ��������
    //��������, ���� �� ���� � ����� AFormDoc (� AId, ���� ������ �� null)
    //���� ����, ���������� ��� �� �������� ���� � ������ False
    function BringToFrontIfExists(AFormDoc: string; AId: Variant): Boolean;
    //������� ���������� �������� ���-���� � ����� �� FormDoc ��� � ����������
    //(��� ����, �� ���������� TForm_MDI ��� TForm_Normal ������������ ��������� �����)
    //����� ����� ��������� ���� (������ ��� TForm_MDI), ���� AId �� null
    //����� ����� �� ������������, ����� ���� �� FormDoc � Id
    function GetWindowsCount(var AForm: TForm; AFormDoc: string; AId: Variant; var MaxNum: Integer): Integer; overload;
    function GetWindowsCount(AFormDoc: string; AId: Variant; var MaxNum: Integer): Integer; overload;
    //���������� ��� ��������� ������ ����-������, ������� ���������� � ���������
    //������� ������, ��������������� �������� �����, �������
    //�� ����������
    procedure HiglightActiveForm(AForm: TForm);
    //������ ������ �����, ���� �� ������ � ��������� �������� ����, ����� nil
    function GetFormFromWindows(AForm: TForm): TForm;
    //��������, ������� �� � ���������� ��������� �����
    function IsModalFormOpen: Boolean;
    //��������� ������ TForm_Reference ��� �� ��������
    procedure ExecReference(F: string); overload;
    procedure ExecReference(F: string; AOwner: TForm; AMyFormOptions: TMyFormOptions; AAddParam: Variant); overload;
//    procedure ExecReferenceAdd(F: string; AOwner: TForm; fMode: TDialogType; AId: Variant; AMyFormOptions: TMyFormOptions; AAddParam: Variant; ShowModal: Boolean = False; TDlgFunction: TDlgFunction = nil);
    //�������� �������� mdi-����� � ������ �������
    //���� AMyFormOptions �������� ������, �� ����������� �� ������� ��� �������
    procedure ExecDialog(F: string; AOwner: TForm; AMyFormOptions: TMyFormOptions; fMode: TDialogType; AId: Variant; AAddParam: Variant);
    procedure ExecAdd(F: string; AOwner: TForm; fMode: TDialogType; AId: Variant; AMyFormOptions: TMyFormOptions; AAddParam: Variant; ShowModal: Boolean = False; TDlgFunction: TDlgFunction = nil);
  end;

var
  Wh: TWindowsHelper;

implementation

uses

  V_MDI, V_Normal, uFrmBasicMdi,
  uFrmMain,

  D_Sn_Calendar,
  D_ExpenseItems,

  D_Candidate, D_Vacancy,

  uFrmWDedtDivision, uFrmWDAddTurv, uFrmWDedtWorkerStatus, uFrmWGEdtTurv, uFrmWGedtPayroll,
  uFrmWGrepPersonal1, uFrmWGrepStaffSchedule,

  D_Order, D_LoadKB,
  D_ItmInfo, D_J_Montage,
  D_R_OrStdItems, D_NewEstimateInput,
  D_SuppliersMinPart, D_Spl_InfoGrid,
  F_Adm_Installer,

  uFrmXGsrvSqlMonitor,

  uFrmOWInvoiceToSgp, uFrmDlgEditNomenclatura, uFrmOGjrnOrders, uFrmOGjrnSemiproducts,
  uFrmCGrepPaymentsByMonth, uFrmCWCash, uFrmAWOracleSessions, uFrmCDedtCashRevision,
  uFrmAWUsersAndRoles, uFrmWGjrnParsec, uFrmOGjrnUchetLog, uFrmOGrefOrStdItems,
  uFrmOGrepSgp, uFrmWGrepSalary, uFrmOGjrnOrderStages, uFrmOGrepItemsInOrder,
  uFrmODedtTasks, uFrmOGedtSnMain, uFrmODrepFinByOrders, uFrmOGedtSnByAreas,
  uFrmOGlstEstimate, uFrmDlgRItmSupplier, uFrmOGedtSgpRevision, uFrmXWndUserInterface,
  uFrmODedtDevel, uFrmODedtItmUnits, uFrmODedtSplCategoryes, uFrmOWSearchInEstimates,
  uFrmOGedtEstimate, uFrmOWrepOrdersPrimeCost, uFrmODedtOrStdItems,

  uFrmOGinfSgp,
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
//��� �������� ���-�����
begin
  //WindowsBarChange(Sender, TForm(Sender).Handle, mywscmCreate);
end;

procedure TWindowsHelper.ChildFormActivate(Sender: TObject);
//��� ��������� ���-����� (����� ����� ��������),
//� ��� ��������� �� ������ ��� ������������ ����� �������
begin
//exit;
  WindowsBarChange(TForm(Sender), TForm(Sender).Handle, mywscmActivate);
end;

procedure TWindowsHelper.ChildFormDestroy(Sender: TObject);
//��� ���������� ���-�����
begin
//exit;
  WindowsBarChange(TForm(Sender), TForm(Sender).Handle, mywscmDestroy);
end;

procedure TWindowsHelper.ActiveFormChange(Sender: TObject);
//��� ����� �������� �����, �� �������� ��� ������������ ����� ���-�����, ������ ��� ����������
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
var
  st: string;
  Tbt: TToolButton;
  i: Integer;
  b: Boolean;
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
  //�������� (����������), ����������� �� ���� ����������
  //�� ���� �����-�� ������ ����������� ���� ����������� ������� ����� ��� ����������
  begin
    result := False;
    //��� ���������� ���� ����� ���� ������ = Application.Handle, ��� ��� FrmMain.Handle
    if (GetParent(Control) <> Application.Handle)and(GetParent(Control) <> FrmMain.Handle) then begin
      //���� ����������� ���������, �� ��������
      if GetParent(Control) <> 0 then
        result := IsParent(GetParent(Control))
    end
    else
      result := True;
  end;

begin
  if not FUseWindowsBar then
    Exit;
  //������, ���� ��� ������ ���� (��������, ��� ���������� ���������)
  if FrmMain.FormsList = nil then
    Exit;
  //���� ������������� ����, �� ����������� � ������ ������������ ����� - �����
//  if Sys.GetModuleFileByHandle(AHandle) <> ParamStr(0) then
//    Exit;
//  if not IsParent(AHandle) then
//    Exit;
  //��������� ��������� ����
  WindowsTitle := Sys.GetWindowHeader(AHandle);
  //Sys.SaveTextToFile('r:\321', VarToStr(mode) + '   ' + VarToStr(Ahandle) + '   ' + Sys.GetWindowHeader(Ahandle) + '   ' +  Sys.GetModuleFileByHandle(handle) + #13#10, True);

  if (IsParent(AHandle)) or
     ((AForm is TForm_MDI)and(TForm_MDI(AForm).ModuleId = cMainModule)) or
     ((AForm is TFrmBasicMdi)and(TFrmBasicMdi(AForm).ModuleId = cMainModule)) or
     ((AForm is TForm_Normal)and(TForm_Normal(AForm).ModuleId = cMainModule)) then begin
  //��� ���������� ������ ��� ���� ������ ���� ����� ����������� ����������,
  //���� ��� ���� �� ����� �������� ����� ����
  //(������-�� �� ������ �������� IsParent ���������� ��� ��� True, � ��������� ����� ������� ��������� ������ �� ��� ������������ ���� (����� �� ��� � �������),
  //�������� ��� ��������� ������� nil, ���� ����� ������ �� ��������
  //��� �������� �� ����� ����� ��� �� ���� ������������ ���� ������ ������� �����, ���� ������� �������� �� ������������ ����, �� ������ ��� ��� ��������
  //����� ������� � �������� ���������� ������ ������ � ������� ������ - ������

  //�������� ��������� ��� ���������� ����
  if WindowsTitle = ModuleRecArr[cMainModule].Caption then
    WindowsTitle := '������';
  b := True;
  //��������, ���� �� ���������� ����� ���� � ������
  for i := FrmMain.FormsList.ComponentCount - 1 downto 0 do
    if (FrmMain.FormsList.Buttons[i].Tag = AHandle) and (FrmMain.FormsList.Buttons[i].Visible) then begin
      b := False;
      Break
    end;
  //���� ���, � ��� �� ������� ���� - ������� ������ � �������
  if (b and (AHandle <> FrmMain.Handle)) {and (Sys.GetModuleFileByHandle(AHandle) = ParamStr(0))} then begin
    //������� ���������� �������� ���-���� � ������-���� � ����� �� ���������� ��� � ����������
    //WindowsCount �������� �� ������ �� ��������� Form.Captions, ���� ��� �������� ���� ������������ �������,
    //������� ��� �������� �����
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
    Tbt.ImageIndex := -1; //��� �������� //MyData.Il_All16
    Tbt.Tag := AHandle;   //�������� �����
    //�����, ����� ������ ����������� ������ ������������ - ��� ����� ��������� ������, � ������� ����� �������
    Tbt.Left := 10000;
    //��������� - ������ ���� � ��� �����, ���� �� ������� ����
//    Tbt.Caption:= WindowsTitle + S.IIf(WindowsCount <= 0, ' ' , '  |' + IntToStr(WindowsCount));
//    Tbt.Caption := WindowsTitle + S.IIf(MaxNum <= 0, ' ', '  |' + IntToStr(MaxNum + 1));
    Tbt.Caption :=
      S.IIf(ParamStr(0) <> Sys.GetModuleFileByHandle(AHandle), Sys.GetModuleFileByHandle(AHandle) + ' - ' , '')+
      WindowsTitle + S.IIf(MaxNum <= 0, ' ', '  |' + IntToStr(MaxNum + 1));
    //������� �����
    FrmMain.SetFormsToolButtonClick;
    //������� ������ ��� ������� ����
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
    //� ������
    FWindows := FWindows + [WRec];
  end;


  end;

  //������ ������� (��������) � ������� ������ ��� �������������� ���� ��� ����� ���������� ������� ����!!!

  //������ ������, � ������� ��� �� ��������� ����
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
    //������� �� ���� ����
    for i := ComponentCount - 1 downto 0 do begin
      //��� �� ��� ����, ������� ������ �������� �������
      if Trim(Buttons[i].Caption) = '' then begin
        try
          Buttons[i].Destroy;
          Delete(FWindows, i, 1);
          Continue;
        except
        end;
      end;
      b := (AHandle = Buttons[i].Tag);
      if (IsModalFormOpen) or ((AForm is TForm_MDI) and (AForm.FormStyle = fsNormal)) or ((AForm is TFrmBasicMdi) and (AForm.FormStyle = fsNormal)) then begin
        //���� ��������� ����� - ��������� ����� � �����, �� ������� �������� ������� �����
        if Buttons[i].ImageIndex = cGreenGalka then
          Buttons[i].ImageIndex := cGreenDot
        else if Buttons[i].ImageIndex = cRedGalka then
          Buttons[i].ImageIndex := cRedDot;
        if b then
          Buttons[i].ImageIndex := cRedGalka;
      end
      else begin
        //���� �� ��������� �����, �� ��� ��������� ���-����� �������� ��� ��� ������� �����, � ��������� ������
        //���� ����� �� ��������� �� mywscmActivate, �� ����� ������ ��� ���������
        if Mode = mywscmActivate then begin
          if b then
            Buttons[i].ImageIndex := cGreenGalka
          else
            Buttons[i].ImageIndex := -1;
        end
        else if Buttons[i].ImageIndex = cGreenDot then
          //� ���� �� ��������� (������� ���������) - ������� ����� ������� �� ������� �����
          Buttons[i].ImageIndex := cGreenGalka;
      end;
    end;
    //������� �� ����� � ������ ������ ��� ��������������
    for i := ComponentCount - 1 downto 0 do begin
      if (Buttons[i].Tag > 0) and (Buttons[i].Tag = AHandle) and (Mode = mywscmDestroy) or (Buttons[i].Tag <> GetForegroundWindow) and (not IsWindowVisible(Buttons[i].Tag)) then begin
        //������ � ������ � ���� � �������
        //!���� �������� ����� ������� � ��������� ������, �� ��� �� �������� ������� �� Buttons[i].Destroy
        //���� �������� ��������� ����� ����� �����, �� ��������� ��� ��.
        //����� �� ���������, ������� ������, � ������ �� � ���� ��������� ����� ������������� �������, ��� � ����� ����� �������� ���� ��������
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
//�������� ��� ������� ������ � ������� - ���� �� �������� ����
var
  i, j: Integer;
  c: TToolButton;
begin
  try
    for i := 0 to High(FWindows) do
      if FWindows[i].Handle = TToolButton(Sender).Tag then begin
      //������ ���� ������, � ��� ������ ���� �����, ����� �������� ����������� �� �� �������� ����
        if IsWindowVisible(TToolButton(Sender).Tag) and (FWindows[i].Form <> nil) and (FWindows[i].Form is TForm) and (FWindows[i].Form.WindowState = wsMinimized) then
          FWindows[i].Form.WindowState := wsNormal;
        FWindows[i].Form.BringToFront;
      end;
  except
  end;
end;

function TWindowsHelper.BringToFrontIfExists(AFormDoc: string; AId: Variant): Boolean;
//��� ��������
//��������, ���� �� ���� � ����� AFormDoc (� AId, ���� ������ �� null)
//���� ����, ���������� ��� �� �������� ���� � ������ False
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
//������� ���������� �������� ���-���� � ����� �� FormDoc ��� � ����������
//����� ����� ��������� ���� (������ ��� TForm_MDI), ���� AId �� null   -- !!! �� ���������
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
//������� ���������� �������� ���-���� � ����� �� FormDoc ��� � ����������
//(��� ����, �� ���������� TForm_MDI ��� TForm_Normal ������������ ��������� �����)
//����� ����� ��������� ���� (������ ��� TForm_MDI), ���� AId �� null
//����� ����� �� ������������, ����� ���� �� FormDoc � Id
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
  //WindowsCount �������� �� ������ �� ��������� Form.Captions, ���� ��� �������� ���� ������������ ������� � �� ���� ��������� �����
//  if st1 = '' then
//    st1 := AForm.Caption;      //111
  for i := 0 to High(FWindows) do begin
    if (FWindows[i].Form is TForm) then begin
//      st2 := FWindows[i].Form.Caption;    //�������� ������ � ��������� ������� ���� ��� �������� FWindows[i].Form is TForm
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
//���������� ��� ��������� ������ ����-������, ������� ���������� � ���������
//������� ������, ��������������� �������� �����, �������
//�� ����������
var
  i, j: Integer;
  c: TToolButton;
  b, IsCurrForm: Boolean;
begin
  for i := 0 to High(FWindows) do begin
    //������� ������, ��������������� �������� �����, �������
    with FrmMain.FormsList do
      if AForm <> nil then begin
        IsCurrForm := (AForm.Handle = Buttons[i].Tag);
        Buttons[i].Down := IsCurrForm;
        Buttons[i].ImageIndex := S.IIf(IsCurrForm, 0, -1);
      end;
  end;
end;

function TWindowsHelper.GetFormFromWindows(AForm: TForm): TForm;
//������ ������ �����, ���� �� ������ � ��������� �������� ����, ����� nil
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
//��������, ������� �� � ���������� ��������� �����
var
  ActForm: TCustomForm;
begin
  ActForm := Screen.ActiveForm;
  Result := (ActForm <> nil) and (fsModal in ActForm.FormState);
end;

procedure TWindowsHelper.ExecReference(F: string);
var
  MyFormOptions: TMyFormOptions;
begin
  MyFormOptions := [myfoOneCopy, myfoSizeable, myfoEnableMaximize];
  ExecReference(F, FrmMain, MyFormOptions, null);
end;

procedure TWindowsHelper.ExecReference(F: string; AOwner: TForm; AMyFormOptions: TMyFormOptions; AAddParam: Variant);
var
  Form: TForm;
  N: Integer;
  MyFormOptions: TMyFormOptions;
begin
  if AMyFormOptions <> [] then
    MyFormOptions := AMyFormOptions
  else
    MyFormOptions := [myfoOneCopy, myfoSizeable, myfoEnableMaximize{, myfoShowStatusbar}]; //myfoModal  //myfoAutoShowModal
  if IsModalFormOpen then
    Include(MyFormOptions, myfoModal);
  if A.InArray(F, [
    myfrm_R_Test,
    {�����������������}
    myfrm_Adm_Db_Log,
    myfrm_J_Error_Log,
    myfrm_R_Organizations,
    myfrm_R_Locations,
    myfrm_R_CarTypes,

    {��������� ���������}
    myfrm_R_GrExpenseItems,
    myfrm_R_ExpenseItems,
    myfrm_R_Suppliers,
    myfrm_J_Accounts,
    myfrm_J_Payments,
    myfrm_J_Accounts_SEL,
    myfrm_J_OrPayments,
    myfrm_Rep_SnCalendarByDate,
    myfrm_Rep_SnCalendar_Transport,
    myfrm_Rep_SnCalendar_AccMontage,

    {���������}
    myfrm_R_Workers,
    myfrm_R_TurvCodes,
    myfrm_R_Jobs,
    myfrm_R_Work_Chedules,
    myfrm_R_Divisions,
    myfrm_J_WorkerStatus,
    myfrm_J_Candidates,
    myfrm_R_Candidates_Ad_SELCH,
    myfrm_J_Turv,
    myfrm_J_Payrolls,
    myfrm_R_Holideys,
    myfrm_Rep_W_Payroll,
    myfrm_J_Vacancy,

    {������}
    myfrm_R_StdProjects,
    myfrm_R_Bcad_Groups,
    myfrm_R_Bcad_Units,
    myfrm_R_Bcad_Nomencl,
    myfrm_R_OrderTemplates,
    myfrm_R_ComplaintReasons,
    myfrm_R_DelayedInprodReasons,
    myfrm_R_RejectionOtkReasons,
    myfrm_R_OrderTypes,
    myfrm_J_PlannedOrders,
    myfrm_J_InvoiceToSgp,
    myfrm_R_Or_ItmExtNomencl,
    myfrm_R_EstimatesReplace,
    myfrm_R_Spl_Categoryes,
    myfrm_R_Itm_Units,
    myfrm_R_Itm_Suppliers,
    myfrm_R_Itm_InGroup_Nomencl,
    myfrm_J_Orders_SEL_1,
    myfrm_R_StdPspFormats,
    myfrm_Rep_PlannedMaterials,
    myfrm_J_Tasks,
    myfrm_J_Devel,
    myfrm_R_Itm_Nomencl,
    myfrm_R_bCAD_Nomencl_SEL,
    myfrm_R_bCAD_Nomencl_SelMaterials,
    myfrm_R_OrderStdItems_SEL,
    myfrm_R_OrderStdItems_SelSemiproduct,
    myfrm_R_OrderStdItems_SelProdStdItem,
    myfrm_R_Itm_Schet,
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
    myfrm_R_OrderTypes,
    myfrm_R_WorkCellTypes,
    myfrm_J_OrItemsInProd,
    myfrm_J_ItmLog,
    myfrm_J_SnHistory
    ])
  then begin
    TFrmXGlstMain.Show(AOwner, F, MyFormOptions + [], fNone, 0, AAddParam);
  end
  else if A.InArray(F, [
    myfrm_R_Suppliers_SELCH
  ]) then begin
    TFrmXGlstMain.Show(AOwner, F, MyFormOptions + [myfoModal], fNone, 0, AAddParam);
  end
  else if F = myfrm_Srv_SqlMonitor then begin
    TFrmXGsrvSqlMonitor.Show(Application, F, MyFormOptions, FNone, 0, null);
  end
  else if F = myfrm_Rep_SnCalendarChart then begin
//    Form := TForm_Rep_SnCalendarChart.Create(Application, F, MyFormOptions, FNone, 0, null);
  end
  else if F = myfrm_Rep_SnCalendarByMonths then begin
    TFrmCGrepPaymentsByMonth.Show(Application, F, MyFormOptions, fNone, 0, null);
  end
  else if (F = myfrm_J_SnCalendar_Cash_1) or (F = myfrm_J_SnCalendar_Cash_2) then begin
    TFrmCWCash.Show(Application, F, MyFormOptions, fEdit, 0, null);
  end
  else if F = myfrm_Rep_SnCalendar_Orders_QntItems then begin
//1    TFrmOGrepItemsInOrder.Show(Application, F, MyFormOptions, fEdit, 0, null);
//    Form := TForm_Rep_Orders_QntItems_2.Create(Application, F, MyFormOptions, FNone, 0, null);
  end
  else if F = myfrm_Adm_UserInterface then begin
//    Form := TForm_UserInterface.Create(Application, F, MyFormOptions, FNone, 0, null);
    TFrmXWndUserInterface.Show(Application, F, [myfoDialog], fNone, 0, null);
  end
  else if F = myfrm_Rep_W_Personnel_1 then begin
    TFrmWGrepPersonal1.Show(Application, F, MyFormOptions, fNone, 0, null);
  end
  else if F = myfrm_Rep_W_Personnel_2 then begin
//!!!    Form := TForm_Rep_Personnel_2.Create(Application, F, MyFormOptions, fNone, 0, null);
  end
  else if F = myfrm_R_Holideys then begin
//    Form := TForm_R_Holideys.Create(Application, F, MyFormOptions, fNone, 0, null);
  end
  else if F = myfrm_Rep_Salary then begin
    TFrmWGrepSalary.Show(Application, F, MyFormOptions, fNone, 0, null);
  end
  else if F = myfrm_J_Parsec then begin
    TFrmWGjrnParsec.Show(Application, F, MyFormOptions, fNone, null, null);
  end
  else if F = myfrm_Adm_DeleteOnServer then begin
//    Form := TForm_Adm_DeleteOnServer.Create(Application, F, MyFormOptions, fNone, 0, null);
  end
  else if F = myfrm_J_Orders then begin
    TFrmOGjrnOrders.Show(Application, F, MyFormOptions, fNone, 0, null);
  end
  else if F = myfrm_R_OrderStdItems then begin
//    Form := TForm_R_OrStdItems.Create(Application, F, MyFormOptions, fNone, 0, null);
    TFrmOGrefOrStdItems.Show(Application, F, MyFormOptions, fNone, 0, null);
  end
  else if F = myfrm_R_Estimate then begin
    TFrmOGlstEstimate.Show(Application, F, MyFormOptions + [myfoMultiCopy], fNone, 0, AAddParam);
//    Form := TForm_R_Estimate.Create(Application, F, MyFormOptions + [myfoMultiCopy], fNone, 0, AAddParam);
  end
  else if F = myfrm_R_AggEstimate then begin
    TFrmOGlstEstimate.Show(Application, F, MyFormOptions + [myfoMultiCopy], fNone, 0, AAddParam);
//    Form := TForm_R_Estimate.Create(Application, F, MyFormOptions + [myfoMultiCopy], fNone, 0, AAddParam);
  end
  else if F = myfrm_R_Customers then begin
    //���������� �������� ��-�� ������������ ������� ����� � ���������� ������ � ��� �������������
//    Form := TForm_R_Customers.Create(Application, F, MyFormOptions, fNone, 0, AAddParam);
  end
  else if A.InArray(F, [myfrm_J_OrderStages_ToProd, myfrm_J_OrderStages_ToSgp, myfrm_J_OrderStages_FromSgp, myfrm_J_OrderStages_Otk, myfrm_J_Or_DelayedInProd, myfrm_J_Or_Montage]) then begin
    TFrmOGjrnOrderStages.Show(Application, F, MyFormOptions, fNone, 0, AAddParam);
  end
  else if F = myfrm_R_MinRemains then begin
    TFrmOGedtSnMain.Show(Application, F, MyFormOptions, fNone, 0, AAddParam);
  end
  else if A.InArray(F, [myfrm_R_MinRemainsP, myfrm_R_MinRemainsI, myfrm_R_MinRemainsD]) then begin
    TFrmOGedtSnByAreas.Show(Application, F, MyFormOptions, fNone, 0, AAddParam);
  end
  else if F = myfrm_Rep_Sgp then begin
    TFrmOGrepSgp.Show(Application, F, MyFormOptions, fNone, 0, AAddParam);
  end
  else if A.InArray(F, [myfrm_J_OrderStages_Full_Log, myfrm_J_OrderStages_ToSgp_Log, myfrm_J_OrderStages_FromSgp_Log, myfrm_J_OrderStages_Otk_Log]) then begin
    TFrmOGjrnUchetLog.Show(AOwner, F, MyFormOptions, fNone, 0, AAddParam);
  end
  else if F = myfrm_J_Semiproducts then begin
    TFrmOGjrnSemiproducts.Show(Application, F, MyFormOptions, S.IIf(User.Role(rOr_J_Semiproducts_Ch), fEdit, fView), 0, null);
  end
  else if F = myfrm_Dlg_Adm_Sessions then begin
    TFrmAWOracleSessions.Show(Application, F, MyFormOptions, fNone, 0, null);
  end
  else if F = myfrm_Dlg_CashRevision then begin
    TFrmCDedtCashRevision.Show(Application, '', [], fNone, 1, null);
  end
  else if F = myfrm_Adm_Installer then begin
    TForm_Adm_Installer.Create(Application, F, [myfoOneCopy], fNone, 0, null);
  end
  else if F = myfrm_F_UsersAndRoles then begin
    TFrmAWUsersAndRoles.Show(Application, F, [myfoSizeable, myfoDialog], fNone, null, null);
  end
  else if F = myfrm_Dlg_Rep_FinByOrders then begin
    TFrmODrepFinByOrders.Show(AOwner, F,[myfoDialog], fNone, null, null);
  end
  else if F = myfrm_Rep_StaffSchedule then begin
    TFrmWGrepStaffSchedule.Show(Application, F, MyFormOptions, fNone, 0, null);
  end
  else
    raise Exception.Create('������� ������� "ExecReference", ������ ��� "' + F + '" � ��� �� ���������������!');
end;

procedure TWindowsHelper.ExecDialog(F: string; AOwner: TForm; AMyFormOptions: TMyFormOptions; fMode: TDialogType; AId: Variant; AAddParam: Variant);
//�������� �������� mdi-����� � ������ �������
//���� AMyFormOptions �������� ������, �� ����������� �� ������� ��� �������
var
  MyFormOptions: TMyFormOptions;
  Form: TForm;
  ResA: TVarDynArray;
  DefBasicInputOpts: TDlgBasicInputOptions;
begin
  MyFormOptions := AMyFormOptions;
  DefBasicInputOpts := [{dbioChbNoClose, }dbioStatusBar];
  if MyFormOptions = [] then
    MyFormOptions := [myfoDialog, myfoRefreshParent, myfoMultiCopy]; //, myfoModal
  if IsModalFormOpen then
    Include(MyFormOptions, myfoModal);
  if F = myfrm_Dlg_R_StdProjects then begin
    TFrmBasicInput.ShowDialogDB(AOwner, F, DefBasicInputOpts, fMode, AId, 'or_projects', '������� ������', 400, 100,
     [['name$s', cntEdit, '������������','1:400'], ['active$i', cntCheckX, '������������']], [['caption dlgedit dlgactive']]);
//    Form := TForm_BasicInput.ShowDialog(AOwner, F, '������� ������', 400, 100, fMode, AId,
//[[cntEdit, 0, '������������', '1:400'], [cntCheck, 0, '������������', '']], [['*', 'select name, active from or_projects where id = :id']], ['or_projects', '', 'id$i;name$s;active$i'], [['caption dlgedit dlgactive']], MyFormOptions);
  end
  else if F = myfrm_Dlg_R_StdPspFormats then begin
    TFrmBasicInput.ShowDialogDB(AOwner, F, DefBasicInputOpts, fMode, AId, 'or_formats', '����������� ������ ��������', 400, 100,
     [['name$s', cntEdit, '������������','1:400'], ['active$i', cntCheckX, '������������']], [['caption dlgedit dlgactive']]);
//    Form := TForm_BasicInput.ShowDialog(AOwner, F, '����������� ������ ��������', 400, 100, fMode, AId, [[cntEdit, 0, '������������', '1:400'], [cntCheck, 0, '������������', '']],
// [['*', 'select name, active from or_formats where id = :id']], ['or_formats', '', 'id$i;name$s;active$i'], [['caption dlgedit dlgactive']], MyFormOptions);
  end
  else if F = myfrm_Dlg_R_StdPspEstimate then begin
    //no use!
//    Form := TForm_BasicInput.ShowDialog(AOwner, F, '������ �����', 400, 100, fMode, AId, [[cntEdit, 0, '������������', '1:400'], [cntEdit, 0, '�������', '1:20'], [cntCheck, 0, '������������', '']], [['*', 'select name, prefix, active from or_format_estimates where id = :id']], ['or_format_estimates', '', 'id$i;name$s;prefix$s;active$i'], [['caption dlgedit dlgactive']], MyFormOptions);
  end
  else if F = myfrm_Dlg_RefSuppliers then begin
    TFrmBasicInput.ShowDialogDB(AOwner, F, DefBasicInputOpts, fMode, AId, 'ref_suppliers;;sq_ref_suppliers', '������ ����������', 400, 100,
     [['legalname$s', cntEdit, '������������','1:400'], ['active$i', cntCheckX, '������������']], [['caption dlgedit dlgactive']]);
//    Form := TForm_BasicInput.ShowDialog(AOwner, F, '������ ����������', 400, 100, fMode, AId, [[cntEdit, 0, '������������', '1:400'],
//    [cntCheck, 0, '������������', '']], [['*', 'select legalname, active from ref_suppliers where id = :id']], ['ref_suppliers', 'sq_ref_suppliers', 'id;legalname;active'], [['caption dlgedit dlgactive']], MyFormOptions);
  end
  else if F = myfrm_Dlg_R_GrExpenseItems then begin
    TFrmBasicInput.ShowDialogDB(AOwner, F, DefBasicInputOpts, fMode, AId, 'ref_grexpenseitems;;sq_ref_grexpenseitems', '������ ������ ��������', 450, 130,
     [['name$s', cntEdit, '������������','1:400']], [['caption dlgedit']]);
//    Form := TForm_BasicInput.ShowDialog(AOwner, F, '������ ������ ��������', 450, 130, fMode, AId, [[cntEdit, 0, '������������', '1:400']],
//    [['*', 'select name from ref_grexpenseitems where id = :id']], ['ref_grexpenseitems', 'sq_ref_grexpenseitems', 'id;name'], [['caption dlgedit']], MyFormOptions);
  end
  else if F = myfrm_Dlg_R_ComplaintReasons then begin
    TFrmBasicInput.ShowDialogDB(AOwner, F, DefBasicInputOpts, fMode, AId, 'ref_complaint_reasons', '������� ����������', 450, 130,
     [['name$s', cntEdit, '������������','1:400'], ['active$i', cntCheckX, '������������']], [['caption dlgedit dlgactive']]);
    //Form := TForm_BasicInput.ShowDialog(AOwner, F, '������� ����������', 450, 130, fMode, AId, [[cntEdit, 0, '������������', '1:400'], [cntCheck, 0, '������������', '']],
    // [['*', 'select name, active from ref_complaint_reasons where id = :id']], ['ref_complaint_reasons', '', 'id$i;name$s;active$i'], [['caption dlgedit']], MyFormOptions);
  end
  else if F = myfrm_Dlg_R_DelayedInprodReasons then begin
    TFrmBasicInput.ShowDialogDB(AOwner, F, DefBasicInputOpts, fMode, AId, 'ref_delayed_prod_reasons', '������� �������� � ������������', 450, 130,
     [['name$s', cntEdit, '������������','1:400'], ['active$i', cntCheckX, '������������']], [['caption dlgedit dlgactive']]);
//    Form := TForm_BasicInput.ShowDialog(AOwner, F, '������� �������� � ������������', 450, 130, fMode, AId, [[cntEdit, 0, '������������', '1:400'], [cntCheck, 0, '������������', '']]
//, [['*', 'select name, active from ref_delayed_prod_reasons where id = :id']], ['ref_delayed_prod_reasons', '', 'id$i;name$s;active$i'], [['caption dlgedit']], MyFormOptions);
  end
  else if F = myfrm_Dlg_R_RejectionOtkReasons then begin
    TFrmBasicInput.ShowDialogDB(AOwner, F, DefBasicInputOpts, fMode, AId, 'ref_otk_reject_reasons', '������� �������� ���', 450, 130,
     [['name$s', cntEdit, '������������','1:400'], ['active$i', cntCheckX, '������������']], [['caption dlgedit dlgactive']]);
//    Form := TForm_BasicInput.ShowDialog(AOwner, F, '������� �������� ���', 450, 130, fMode, AId, [[cntEdit, 0, '������������', '1:400'], [cntCheck, 0, '������������', '']],
//[['*', 'select name, active from ref_otk_reject_reasons where id = :id']], ['ref_otk_reject_reasons', '', 'id$i;name$s;active$i'], [['caption dlgedit']], MyFormOptions);
  end
  else if F = myfrm_Dlg_RefColors then begin
    TFrmBasicInput.ShowDialogDB(AOwner, F, DefBasicInputOpts, fMode, AId, 'ref_colors;;sq_ref_colors', '����', 400, 100,
     [['article$s', cntEdit, '�������','1:20'], ['name$s', cntEdit, '������������','1:400']], [['caption dlgedit']]);
//    Form := TForm_BasicInput.ShowDialog(AOwner, F, '����', 400, 100, fMode, AId, [[cntEdit, 0, '�������', '1:20'], [cntEdit, 0, '������������', '1:400']], [['*', 'select article, name from ref_colors where id = :id']], ['ref_colors', 'sq_ref_colors', 'id;article;name'], [['caption dlgedit']], MyFormOptions);
  end
  else if F = myfrm_Dlg_Pick_General_Fittings then begin
//    Form := TForm_BasicInput.ShowDialog(AOwner, F, '����� ���������', 400, 100, fMode, AId, [[cntEdit, 0, '�������', '1:20'], [cntEdit, 0, '������������', '1:400']], [['*', 'select article, name from pick_general_fittings where id = :id']], ['pick_general_fittings', 'sq_pick_general_fittings', 'id;article;name'], [['caption dlgedit']], MyFormOptions);
  end
  else if F = myfrm_Dlg_Pick_GrItems then begin
//    Form := TForm_BasicInput.ShowDialog(AOwner, F, '����', 400, 100, fMode, AId, [[cntEdit, 0, '������������', '1:400']], [['*', 'select name from pick_item_groups where id = :id']], ['pick_item_groups', 'sq_pick_item_groups', 'id;name'], [['caption dlgedit']], MyFormOptions);
  end
  else if F = myfrm_Dlg_PickItem then begin
//    Form := TDlg_Pick_Item.ShowDialog(AOwner, F, fMode, AId);
  end
  else if F = myfrm_Dlg_SnCalendar then begin
    Form := TDlg_Sn_Calendar.ShowDialog(AOwner, F, fMode, AId, MyFormOptions, AAddParam);
  end
  else if F = myfrm_Dlg_RefExpenseItems then begin
    Form := TDlg_ExpenseItems.Create(AOwner, F, MyFormOptions, fMode, AId, null);
  end
  else if F = myfrm_Dlg_Sn_Defectives then begin
//    Form := TDlg_Sn_Defectives.Create(AOwner, F, MyFormOptions, fMode, AId, null);
  end
  else if F = myfrm_Dlg_Sn_Defectives_Act then begin
//    Form := TDlg_Sn_Defectives_Act.Create(AOwner, F, MyFormOptions, fMode, AId, null);
  end
  else if F = myfrm_Dlg_R_Workers then begin
    TFrmBasicInput.ShowDialogDB(AOwner, F, DefBasicInputOpts, fMode, AId, 'ref_workers;;sq_ref_workers', '��������', 400, 100,
     [['f$s', cntEdit, '�������','1:25'], ['i$s', cntEdit, '���','1:25'], ['o$s', cntEdit, '��������','1:25']], [['caption dlgedit']]);
  end
  else if F = myfrm_Dlg_R_Jobs then begin
    TFrmBasicInput.ShowDialogDB(AOwner, F, DefBasicInputOpts, fMode, AId, 'ref_jobs;;sq_ref_jobs', '���������', 400, 100,
     [['name$s', cntEdit, '���������','1:400']{, ['active$i', cntCheckX, '������������']}], [['caption dlgedit ']]);
  end
  else if F = myfrm_Dlg_R_TurvCodes then begin
    TFrmBasicInput.ShowDialogDB(AOwner, F, DefBasicInputOpts, fMode, AId, 'ref_turvcodes;;sq_ref_turvcodes', '����������� ����', 450, 130,
     [['code$s', cntEdit, '���������','1:400'], ['name$s', cntEdit, '���������','1:400']], [['caption dlgedit']]);
  end
  else if F = myfrm_Dlg_R_Organizations then begin
    TFrmBasicInput.ShowDialogDB(AOwner, F, DefBasicInputOpts, fMode, AId, 'ref_sn_organizations;;sq_ref_sn_organizations', '���� �����������', 400, 100,
     [['name$s', cntEdit, '������������','1:30'], ['name$s', cntEdit, '���������','0:100:0:N'], ['active$i', cntCheckX, '������������']], [['caption dlgedit dlgactive']]);
  end
  else if F = myfrm_Dlg_R_Locations then begin
    TFrmBasicInput.ShowDialogDB(AOwner, F, DefBasicInputOpts, fMode, AId, 'ref_sn_locations;;sq_ref_sn_locations', '���� ������', 400, 100,
     [['name$s', cntEdit, '�����','1:400'], ['active$i', cntCheckX, '������������']], [['caption dlgedit dlgactive']]);
  end
  else if F = myfrm_Dlg_R_CarTypes then begin
    TFrmBasicInput.ShowDialogDB(AOwner, F, DefBasicInputOpts, fMode, AId, 'ref_otk_reject_reasons', '���� ������������ �������', 400, 100,
     [['name$s', cntEdit, '���','1:100'], ['active$i', cntCheckX, '������������']], [['caption dlgedit dlgactive']]);
  end
  else if F = myfrm_Dlg_R_PayrollMethods then begin
//      Form:=TDlg_PayrollMethod.ShowDialog(AOwner, F, fMode, AId);
  end
  else if F = myfrm_Dlg_R_Divisions then begin
//~    Form := TDlg_Division.ShowDialog(AOwner, F, fMode, AId, null);
    TFrmWDedtDivision.Show(AOwner, F, [myfoDialog], fMode, AId, null);
  end
  else if F = myfrm_Dlg_R_DivisionMembers then begin
//      Form:=TDlg_DivisionMembers.ShowDialog(AOwner, F, fMode, AId);
  end
  else if F = myfrm_Dlg_WorkerStatus then begin
//~    Form := TDlg_WorkerStatus.ShowDialog(AOwner, F, fMode, AId, AAddParam);
    TFrmWDedtWorkerStatus.Show(AOwner, F, [myfoDialog], fMode, AId, AAddParam);
  end
  else if F = myfrm_Dlg_Turv then begin
    TFrmWGEdtTurv.Show(AOwner, F, [myfoDialog, myfoSizeable, myfoEnableMaximize], fMode, AID, null);
  end
  else if F = myfrm_Dlg_AddTurv then begin
//~    Form := TDlg_AddTurv.ShowDialog(AOwner, F, fMode, AId, null);
    TFrmWDAddTurv.Show(AOwner, F, [myfoDialog], fMode, AId, null);
  end
  else if F = myfrm_Dlg_Payroll then begin
    TFrmWGedtPayroll.Show(AOwner, F, [myfoDialog, myfoSizeable], fMode, AId, null);
  end
  else if F = myfrm_Dlg_Candidate then begin
//~    Form := TDlg_Candidate.ShowDialog(AOwner, F, fMode, AId, MyFormOptions, AAddParam);
  end
  else if F = myfrm_Dlg_Vacancy then begin
//~    Form := TDlg_Vacancy.ShowDialog(AOwner, F, fMode, AId, MyFormOptions, AAddParam);
  end
  else if F = myfrm_Dlg_Order then begin
    //!����� ������ ����� �����
    Form := TDlg_Order.ShowDialog(AOwner, F, fMode, AId, MyFormOptions, AAddParam);
  end
  else if F = myfrm_Dlg_R_Candidates_Ad then begin
    //!!! ������ - ���������� �� �� ������������������!!!
    TFrmBasicInput.ShowDialogDB(AOwner, F, DefBasicInputOpts, fMode, AId, 'ref_candidates_ad;;sq_ref_suppliers', '��������� ���������� � ��������', 400, 100,
     [['name$s', cntEdit, '������������','1:100']], [['caption dlgedit ']]);
//    Form := TForm_BasicInput.ShowDialog(AOwner, F, '��������� ���������� � ��������', 400, 100, fMode, AId, [[cntEdit, 0, '������������', '1:100']],
//[['*', 'select name from ref_candidates_ad where id = :id']], ['ref_candidates_ad', 'sq_ref_suppliers', 'id;name'], [['caption dlgedit dlgactive']], MyFormOptions);
  end
  else if F = myfrm_Dlg_Or_FindNameInEstimates then begin
//    Form := TDlg_Or_FindNameInEstimates.Create(AOwner, F, MyFormOptions, fMode, AId, null);
    TFrmOWSearchInEstimates.Show(AOwner, F, MyFormOptions + [myfoSizeable], fMode, AId, null);
  end
  else if F = myfrm_Dlg_Or_ItmInfo then begin
    Form := TDlg_ItmInfo.Create(AOwner, F, MyFormOptions, fMode, AId, null);
  end
  else if F = myfrm_Dlg_LoadKB then begin
    Form := TDlg_LoadKB.Create(AOwner, F, MyFormOptions, fMode, AId, null);
  end
  else if F = myfrm_Dlg_Bcad_Groups then begin
    TFrmBasicInput.ShowDialogDB(AOwner, F, DefBasicInputOpts, fMode, AId, 'bcad_groups', '������ bCAD', 450, 90,
     [['name$s', cntEdit, '������������','1:100']], [['caption dlgedit ']]);
//    Form := TForm_BasicInput.ShowDialog(AOwner, F, '������ bCAD', 450, 90, fMode, AId, [[cntEdit, 0, '������������', '1:1000']], [['*', 'select name from bcad_groups where id = :id']], ['bcad_groups', '', 'id$i;name'], [['caption dlgedit']], MyFormOptions);
  end
  else if F = myfrm_Dlg_Bcad_Units then begin
    TFrmBasicInput.ShowDialogDB(AOwner, F, DefBasicInputOpts, fMode, AId, 'bcad_units', '��. ���. bCAD', 450, 90,
     [['name$s', cntEdit, '������������','1:100']], [['caption dlgedit ']]);
//    Form := TForm_BasicInput.ShowDialog(AOwner, F, '��. ���. bCAD', 450, 90, fMode, AId, [[cntEdit, 0, '������������', '1:50']], [['*', 'select name from bcad_units where id = :id']], ['bcad_units', '', 'id$i;name'], [['caption dlgedit']], MyFormOptions);
  end
  else if F = myfrm_Dlg_J_Devel then begin
    TFrmODedtDevel.Show(AOwner, F, MyFormOptions + [myfoSizeable], fMode, AId, null);
  end
  else if F = myfrm_Dlg_R_Customer_Main then begin
    //!!! ���� ����������, �� ������ �� ������!!!
    TFrmBasicInput.ShowDialogDB(AOwner, F, DefBasicInputOpts, fMode, AId, 'ref_customers', '����������', 400, 100,
     [['name$s', cntEdit, '������������','1:100'], ['wholesale$i', cntCheck, '�������'], ['active$i', cntCheckX, '������������']], [['caption dlgedit dlgactive']]);
//    Form := TForm_BasicInput.ShowDialog(AOwner, F, '����������', 400, 100, fMode, AId, [[cntEdit, 0, '������������', '1:400'],
//[cntComboLK, 0, '���������', '1:100', 'A'#1'B'#1'C', 'A'#1'B'#1'C'], [cntCheck, 0, '�������', ''], [cntCheck, 0, '������������', '']],
//[['*', 'select name, priority, wholesale, active from ref_customers where id = :id$i']], ['ref_customers', '', 'id$i;name$s;priority$s;wholesale$i;active$i'], [['caption dlgedit dlgactive']], MyFormOptions);
  end
  else if F = myfrm_Dlg_R_Customer_Contact then begin
    TFrmBasicInput.ShowDialogDB(AOwner, F, DefBasicInputOpts, fMode, AId, 'ref_customer_contact', '���������� ����������', 400, 100,
     [['name$s', cntEdit, '���������� ����','1:100'], ['contact$s', cntEdit, '���������� ����','1:400'], ['active$i', cntCheckX, '������������']], [['caption dlgedit dlgactive']]);
//    Form := TForm_BasicInput.ShowDialog(AOwner, F, '���������� ����������', 400, 100, fMode, AId, [[cntEdit, 0, '���������� ����', '1:400'],
//[cntEdit, 0, '��������', '1:400'], [cntCheck, 0, '������������', '']], [['*', 'select name, contact, active from ref_customer_contact where id = :id$i']], ['ref_customer_contact', '', 'id$i;name$s;contact$s;active$i'], [['caption dlgedit dlgactive']], MyFormOptions);
  end
  else if F = myfrm_Dlg_R_Customer_Legal then begin
    TFrmBasicInput.ShowDialogDB(AOwner, F, DefBasicInputOpts, fMode, AId, 'ref_customer_legal', '����������� ������������', 400, 100,
     [['legalname$s', cntEdit, '������������','1:100'], ['inn$s', cntEdit, '���','10:12'], ['active$i', cntCheckX, '������������']], [['caption dlgedit dlgactive']]);
    //Form := TForm_BasicInput.ShowDialog(AOwner, F, '����������� ������������', 400, 100, fMode, AId, [[cntEdit, 0, '������������', '1:400'], [cntEdit, 0, '���', '10:12'],
    //[cntCheck, 0, '������������', '']], [['*', 'select legalname, inn, active from ref_customer_legal where id = :id$i']], ['ref_customer_legal', '', 'id$i;legalname$s;inn$s;active$i'], [['caption dlgedit dlgactive']], MyFormOptions);
  end
  else if F = myfrm_Dlg_J_Montage then begin
    Form := TDlg_J_Montage.Create(AOwner, F, MyFormOptions, fMode, AId, AAddParam);
  end
  else if F = myfrm_Dlg_Rep_Order_Primecost2 then begin
    TFrmOWrepOrdersPrimeCost.Show(AOwner, F, MyFormOptions, fNone, null, null);
  end
  else if F = myfrm_Dlg_R_OrderStdItems then begin
    //Form := TDlg_R_OrStdItems.Create(AOwner, F, MyFormOptions, fMode, AId, AAddParam);
    TFrmODedtOrStdItems.Show(AOwner, F, MyFormOptions, fMode, AId, AAddParam);
  end
  else if F = myfrm_Dlg_NewEstimateInput then begin
//      Form := TDlg_NewEstimateInput.Create(AOwner, F, MyFormOptions, fMode, AId, AAddParam);  //!!!    32098
    TFrmOGedtEstimate.Show(AOwner, F, MyFormOptions + [myfoSizeable], fMode, AId, AAddParam);    //!!!    32098
  end
  else if F = myfrm_Dlg_SupplierMinPart then begin
    Form := TDlg_SuppliersMinPart.Create(AOwner, F, MyFormOptions, fMode, AId, AAddParam);
  end
  else if F = myfrm_Dlg_R_Spl_Categoryes then begin
//    Form := TDlg_R_Spl_Categoryes.Create(AOwner, F, MyFormOptions + [myfoSizeable], fMode, AId, null);
    TFrmODedtSplCategoryes.Show(AOwner, F, MyFormOptions + [myfoSizeable], fMode, AId, null);
  end
  else if A.InArray(F, [myfrm_Dlg_Spl_InfoGrid_MoveNomencl, myfrm_Dlg_Spl_InfoGrid_DiffInOrder]) then begin
    Form := TDlg_Spl_InfoGrid.Create(AOwner, F, [myfoModal, myfoSizeable, myfoDialog], fView, AId, AAddParam);
  end
  else if F = myfrm_Dlg_R_Itm_Units then begin
//    Form := TDlg_R_Itm_Units.Create(AOwner, F, MyFormOptions + [myfoDialog], fMode, AId, null);
    TFrmODedtItmUnits.Show(AOwner, F, MyFormOptions + [myfoDialog], fMode, AId, null);
  end
  else if F = myfrm_Dlg_R_Itm_Suppliers then begin
    TFrmDlgRItmSupplier.Show(AOwner, F, MyFormOptions + [myfoDialog, myfoSizeable], fMode, AId, null);
  end
  else if F = myfrm_Dlg_Sgp_Revision then begin
    TFrmOGedtSgpRevision.Show(AOwner, F, MyFormOptions + [myfoSizeable, myfoDialog], fMode, AId, AAddParam);
  end
  else if F = myfrm_Dlg_InvoiceToSgp then begin
    TFrmOWInvoiceToSgp.Show(AOwner, F, MyFormOptions + [myfoSizeable, myfoMultiCopy, myfoDialog], fMode, AId, AAddParam);
  end
  else if F = myfrm_Dlg_EditNomenclatura then begin
    TFrmDlgEditNomenclatura.Show(AOwner, F, MyFormOptions + [myfoSizeable, myfoMultiCopy, myfoDialog], fMode, AId, AAddParam);
  end
  else if F = myfrm_Dlg_J_Tasks then begin
    TFrmODedtTasks.Show(AOwner, F, MyFormOptions + [myfoMultiCopy, myfoDialog], fMode, AId, AAddParam);
  end
  else if F = myfrm_Dlg_R_OrderTypes then begin
    TFrmBasicInput.ShowDialogDB(AOwner, F, DefBasicInputOpts, fMode, AId, 'order_types', '���� �������', 400, 100,
      [['name$s', cntEdit, '������������','1:100'], ['need_ref$i', cntCheck, '�c����'#13#10'�� �����'], ['active$i', cntCheckX, '������������']],
      [['caption dlgedit dlgactive']]);
  end
  else if F = myfrm_Dlg_R_WorkCellTypes then begin
    TFrmBasicInput.ShowDialogDB(AOwner, F, DefBasicInputOpts, fMode, AId, 'work_cell_types', '���� ���������������� ��������', 400, 100,
      [['code$s', cntEdit, '���','1:4::TU'], ['name$s', cntEdit, '������������','1:100::T'], ['active$i', cntCheckX, '������������']],
      [['caption dlgedit dlgactive']]);
  end

  else if F = myfrm_Dlg_Test then begin
  end


  else
    raise Exception.Create('������� ������� "ExecDialog", ������ ��� "' + F + '" � ��� �� ���������������!');
end;

procedure TWindowsHelper.ExecAdd(F: string; AOwner: TForm; fMode: TDialogType; AId: Variant; AMyFormOptions: TMyFormOptions; AAddParam: Variant; ShowModal: Boolean = False; TDlgFunction: TDlgFunction = nil);
//!!! ���������� ����� ����� ���� �������!!!
var
  i, j, fc, fp, l: Integer;
  Form: TForm;
  bbExecuteAsDialog: Boolean;
  MyFormOptions: TMyFormOptions;
  N: Integer;
begin
//  Form := TForm_References.ShowDialog(Application, F, MyFormOptions, AAddParam);
  MyFormOptions := AMyFormOptions;
//  Form := TForm_References.Create(Application, F, MyFormOptions, fMode, AId, AAddParam);
end;

//ocedure TWindowsHelper.
//GetEnumName(TypeInfo(TTest), ord(bb));

function Test: string;
//uses TypInfo;
var
  v: TTest;
  i: Integer;
  vv: Variant;
begin
  vv := bb;
//  if i in [135] then exit;
//  if vv in [aa] then exit;
  result := GetEnumName(TypeInfo(TTest), ord(bb));

  case v of
    bb:
      Exit;
  end;
end;

begin
  Wh := TWindowsHelper.Create;
  Test;

end.
