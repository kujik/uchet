unit V_MDI;
{
�����-������ ��� ���� ��������-����

���� ����� �������� ����������� �������, �� �� ����-�����������, ������ �� ������ ����������, ��� ������� ���������� �� �����
����� ���������, ����� ������� dfm � ������ � ������� ����� ������ ���� OnCreate = nil, ���� �������������� ������� � ����� ����� � �������� inherited

����� ����� ������� ����� ���� ������, ��� �� ��������� ������� �����, � ����� � ��� ��������� class(TForm) �� class(TForm_MDI)
����� ��������� ����� ���� ������� �� ����� ������� (������ Application.CreateForm(TForm..)

}


{
����� - ������ ��� ���������� ���� ���� (���� ��� ������������� �� �������)
����� ���� ������� ��� � ������ FormStyle = fsMdiChild, ��� � � fsNormal
� ��������� ������� ��� fsNormal, ������� � ������� �� ����� ��� �� ������������ ��� �������� ����� ���������,
� ���� ����������� ��������� ��������� � �������� ����� ��� ������ ����������.
� ��������� ������ ����� ������ ��������� ������� ������, � ������� �������� �������� �������, � � ������ ������
��������� �����. �� � ���� ������ ��������� �������� � �������� ��� �������� � ����� �������������� ����������,
����������� � ���������� �������.
������ �������� � �����. � ����-������� ����� ��� ���������. ������� �� ���� �� �������� ShowModal ������������
��� ������ ����� ������ � ��� ���������� - ��������� �� ����� ���� �����. � ���� �������� showmodal, �� ����� ��������
���������� ����� ��� ����������� ��������, � ����� �����������, ��� ���� ������, ������������ � ������ � ���� � ������


������ ��� �������� ������������
��� ������� �� ����� myfoModal, ���� ���� fs = fsNormal � ����������� showdialog, ����� fsMdiChild � ������ Show;
����������� ��� ������ ��� ����� ���������� ����, ��� ��� ������, ��� ��� ��������� ������ � ���������� �����
���������� � �������� ������������ ����� inherited.
���� ������� � ��������� ������, �� ����� ������������� ������������ �������� ����� ����� � ������ ��������,
��� ��� ������ ������ Show. ����� �� ���� ���������, ��� ��������� ����� � �� ���������� ������ �� ����� �� ���� ������.
�����, ��� �������� � ��������� ������ ���������� ��������� ����������� ����� � ��� �� ����, �� ��� ���� � Prepare �� �������.
����� ������ ���������� ����� ����������� ����� �� ������ � fsMdiChild.


� �������� ��� ���������������� ������������ ������� ������������� ���� � ��������� �������� �������� innherited!
����� innherited �� ������ ������� ��������, ��� ��� ����������� ����� �� ������� ����� � ����������� �� ���������� �����
(��������, �������� ������������ ���������), � ��������� � ����� ������� ������)
��������� ������ � ������� Prepare!

���� � �������� �� ����� ���� ��������� TLabel, �� � ������������ ����� ����������� ���������� ������ uLabelColors,
������ ��������� ������ ��� ���������� �����!!!


���� ����� �������� ���������, �� ��������� ��������� ��� �������� ����� ��-�� ���������� ������ � �������.
}


//��������� ������� �����  �� ��������� ����� �� ������������� �����
//�������� ��������� ������������� ����� ���� ������
//����������� �������� ��������������� ��� ������������� ����� ����� (�������� �� ����, � ��� ������ ������ ���� ������


//��������� ������ SHOWMODAL
//���� ������� ������������ � �������� ����� ����� showmodal, � ���������� ������� �������� ��� ���� ��� �������� ����� � ��������
//����� ������������ ������, � � ����� ����� � onclose action=cafree
//�� ��� ���� ������ �������� ��� ������� ���������� �������, � ���� ����� ��������� � �����
//������� ��������� ��������� FPreventShow � �������

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  MemTableDataEh, Db, ADODB, DataDriverEh, ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Math, uData, Vcl.StdCtrls, uLabelColors;

const
  mycHiddenFormLeft = -10000;

type
  TForm_MDI = class(TForm)
    Timer_AfterStart: TTimer;
    P_StatusBar: TPanel;
    Lb_StatusBar_Right: TLabel;
    Lb_StatusBar_Left: TLabel;
    procedure Timer_AfterStartTimer(Sender: TObject);
    //�� ��������� ���������� ����� ���� ������������ ������� ��� ������ ������������
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
    //��������������� ������� � ��������� ����, ���� ������� ��������� � ��
    //��� ���������� ������� � oncreate � ������ ���� ������ ���������
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    //��������� caFree
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FToLoaddata: Boolean;
    FTextLeft, FTextRight: Variant;
    FStatusBarHeight: Integer;
    FIISetStatusBar: Boolean;
    FIsFormShown: Boolean;
    //� ������ showdialog ����� �������� ������� �� ���������� ��� ���. ������ ���� ��������� ��������� �����.
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
  public
    { Public declarations }
    ModuleId: Integer;
    FPreventShow: Boolean;
//    FormObject: TComponent;
//    bbb: Boolean;
    //�� ���������
    FormDoc: string;
    //������������ �����, ������ ��������������� � �������� � ���������� ������������
    ParentForm: TComponent;
    //����� �����, �� ����� ��� �������
    Mode: TDialogType;
    //���� ������, �� ����� ��� �������.
    id: Variant;
    AddParam: Variant;
    //(myfoModal, myfoDialog, myfoDefault, myfoMultiCopy, myfoMultiCopyWoId, myfoOneCopy, myfoEnableMaximize, myfoSizeable, myfoRefreshParent)
    MyFormOptions: TMyFormOptions;
    //���� ���� ��� ��������� � ��������� �������� ������
    InPrepare: Boolean;
    InFormShow: Boolean;
    //��������� ���������� ������� �������
    PrepareResult: Boolean;
    FormDialogResult: Integer;
    //�������, � ������� ���������� ����� ��� �������� ����, ��� ��� �������� �� ����� ������, ���� NoCloseIfAdd
    DefFocusedControl: TWinControl;
    AutoSaveWindowPos: Boolean;
_noshow: Boolean;
    //�����������
    //���������� �������� (������ ������ ���� �����������), ������������� ���� ���������, ����� ���� ��������� ������ ���� (����� ����� �� �����������)
    constructor Create(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant; AAddParam: Variant); reintroduce; virtual;
    //�������� ��� ������� ��� ������ ����� ������ ������������!!!
    class function ShowDialogClass(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant; AAddParam: Variant): TForm; overload; virtual;
    class function ShowDialogClass(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AAddParam: Variant): TForm; overload; virtual;
    //��������� ����� � ������ ������� � ���������� ���� (�� ����� � ������) � ��� ���������
    //������ �������������� � ��������� ����� ��������� ��� ������ ��� � ������ (������ �� � uLabelColors)
    //���� �������, �� ����� ���������� �������������, ������������� � �������� ������ ���������� = 0 ��� �������� ����� ���� ��������� �� ����
    //� �������� ����� ���� ����������� ����� ������� ����������, ��� ��������� ��������������
    //���� � �������� ������ ����� ����������� ������ SetStatusBar �������� ��� ������ ���������, �� �� �������� ��� ��������, ������ ����� ��������������� (����������/��������� ����)
    //���� ����� ������� �� ����� �������� ��������� ����� ������ - ��� ��������� ������ �� ��������� - �������� ������ �����
    procedure SetStatusBar(TextLeft, TextRight: Variant; AVisible: Boolean);
  protected
    //����������� ������ � ������, ����� ���������� � ������������ ��� �������. �������������� ����� � onCanResize
    MinWidth, MinHeight, MaxWidth, MaxHeight: Integer;
    //��������, ����������� ��� �����������/�������������, ������ ����������� � ��������
    PrevLeft, PrevTop, PrevWidth, PrewHeight: Integer;
    //���� �� ������� ����������, ��������� FormDbLock = Mode, ���� ����� ����� fDelete or FEdit �� ���������� ��������� ��������� ��� �������� �����
    //���� True, �� ��� �������� ����� ��������� ���������, ��������� ��� ����� FormDoc � ID
    LockInDB: TDialogType;
    IsMaximized: Boolean;
    InMaxMin: Boolean;
    //�� ������� ����� ����� �������� ������, �������� �� �� ��� ����� bsDialog, ����? ��� ����������� �������
    PreventResize: Boolean;
    //��������� �������� ������ (Prepare) � � ����������� �� ���������� ���������� ����� ��� ���������
    //���������� �������������� � ������������ ���� RunAfterCreateProc=True ��� �� ������, ���� � ������������ ���� ���������� �������������� ���������,
    //�� ���� ������ ���� ��������� ��� False � AfterCreate
    //������ ���� ����������� ������ � ������������ ������� ����� ������ ������������� ������������ � ������������� ����� (���� ����, �����),
    //��� �� ��� ������� � ������� ����� onCreate ���� ������ ��� ������ �� ����������
    //����� ���� �� ������� ����� onCreate � ���, �� � �������� mdi_grid1 �� ��������� ��� ����������
    //������ ��� ����, ���� �� ��������!
    procedure AfterCreate;
    procedure AfterStart; virtual;
    //������ ���� �������, ���� ���������� ���������� �� ������ �����, � �����������
    procedure ExitWithoutShow; virtual;
    //���������� ����� �������� ����� � ������������,
    //���� ���������� ���� �� ���������� ����� �� ������������ � ��������� ����� ExitWithoutShow
    //(�� ���� False �������� ����������� �����);
    //�������������.
    function  Prepare(): Boolean; reintroduce; virtual;
    procedure AfterPrepare; virtual;
    //������ ���������� ����� ����������� ����� (� ������� ������������� ����� ���������)
    function RefreshParentForm: Boolean;
    //��������� ���������� �� ������� � ����. ���������� ������� � �������, ���������� ����� ����� ����� � ���������� �����, ��� �������� fNone ������ ���� ����� �� Prepere � False
    function FormDbLock(msg: string = '*|*'): TDialogType;
    procedure GetFormLTWH;
    //�������� �������� �������� �� ����� �� ��� �����
    //���� ����������� NullIfEmpty �� ������� null ���� �������� ����� ������ ��� ''
    function GetControlValue(ControlName: string; NullIfEmpty: Boolean = False): Variant;
    function ScrollBarVisible(isVert: Boolean = True): Boolean;
    //����� ��� ������� ����� �����.
    //�������� ����� � ��������� ���� ������ fsNormal!!!
    procedure InitializeNewForm; override;
    //����������� ����� � ����������� �� ������ FormStyle, ���������� � class function �������������
    class procedure ShowForm(AForm: TForm);
    //���������, �������� �� ��� ���������� ����� �����
    //������ True, ���� ����� ��������� �����
    //� ����� ������ ���������� �� �������� ���� �����, ���� ������ � ����� ������� � ����
    //��� myfoMultiCopy, ��� ������� ����������/�����������, fNone - ������� ����� �����
    //�� ���� ������, ���������� �� ����, � ��� myfoMultiCopy, �� �� �������� ������� �����
    class function TestMultiInstances(AFormDoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant): Boolean;
  end;

var
  Form_MDI: TForm_MDI;

implementation

uses
  uWindows, uSettings, uFrmMain, uDBOra, uForms, uMessages, uString, uFrDbGridEh, uFrmBasicMdi
  ;

{$R *.dfm}

class function TForm_MDI.ShowDialogClass(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant; AAddParam: Variant): TForm;
//������� ������. ��� �������� ���� ���������� �������� �� � �� �����������
//���������� ��, ����� ���������, ����� �� ���������� ����� � ����������� �� ������� (��������, ����� ������ ���� ��������� ������ ���� � ��� ��� ����)
//��������� � ������������ ����, �� ��� �������� ����� ��� ������������, � ����� ��� ������ �� ���������.
//����� ��� � ��������� ����� ����� �������� ������� ��������� - ��� MdiChild ��� Modal
//! � �������� ������, ���� � ��� ���������� �������������� ���������, ����� ��������� ���� ������� ������ � ��������� ��� ��� ������ ����,
//��� ��� �� �������� ����������� (�� ������ ������������) �� �� ����� ���������������� �������������� ����, � ��� ��� ����� ��� �����.
//���� �� ��� ���� ��������� �������, ����� ���� �� ������������ ����������� ���� class OK �� ����� ��� ���������� ������ ������ ��� ���� ����������� ������
begin
  if not TestMultiInstances(ADoc, AMyFormOptions, AMode, AID) then
    Result := Create(AOwner, ADoc, AMyFormOptions, AMode, AID, AAddParam);
  Result := Create(AOwner, ADoc, AMyFormOptions, AMode, AID, null);
  ShowForm(Result);
end;

class function TForm_MDI.ShowDialogClass(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AAddParam: Variant): TForm;
begin
{  if not TestMultiInstances(ADoc, AId, AMyFormOptions) then
    Exit;
  if Wh.IsModalFormOpen then
    Include(AMyFormOptions, myfoModal);
  Result := Create(AOwner, ADoc, AMyFormOptions, fNone, null, AAddParam);
  if (myfoModal in AMyFormOptions) then
    TForm_MDI(Result).AfterCreate;
  ShowForm(Result);}
end;

constructor TForm_MDI.Create(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; Aid: Variant; AAddParam: Variant);
//����������� ������
var
  i :Integer;
begin
  ModuleId := cMainModule;
  MyFormOptions := AMyFormOptions;
  FStatusBarHeight := -1;
  //���� ������� ������-���� ��������� �����, ������������� ������� ��� ������������ ��������� �����
  if Wh.IsModalFormOpen then
    Include(MyFormOptions, myfoModal);
  //��������, ����� �� ���� ������� ��������� �����, ���� ��� ����� ���� � AMyFormOptions �� ��������� ������
  if not TestMultiInstances(ADoc, MyFormOptions, AMode, Aid) then
    Exit;
  //�������� ������
  //� ���� ������ �� �����������! ���������� �� ������ �����/���
  inherited Create(Application);
  i:=Self.Width;
//  Self.Width := 500;
  //������� ����� �����, �� ���� ��������� ������, ����� ��� �� ���� �����
  Left := mycHiddenFormLeft;
 // Hide;
{ Application.CreateForm(TForm_MDI, self);
  if myfoAutoShowModal in MyFormOptions then
    Self.FormStyle := fsNormal
  else
    Self.FormStyle := fsNormal;}
  //��������� ���������� ��������
  FormDoc := ADoc;
  Mode := AMode;
  id := Aid;
  ParentForm := AOwner;
  AddParam := AAddParam;
  ModalResult := mrNone;
//  Timer_AfterStart.Enabled := True;
  //Wh.SelectDialogResult := [];
  //Wh.SelectDialogResult2 := [];
  FormDialogResult := mrNone;
  //��������� ������ ����������
  P_StatusBar.Visible := not (myfoDialog in MyFormOptions);
  P_StatusBar.BevelInner:=bvNone;
  P_StatusBar.BevelOuter:=bvNone;
  P_StatusBar.Color:=cl3DLight;
  //������� ��� ����� �� ���
  //++SetStatusBar('', '', P_StatusBar.Visible);
  //�������� ������������� ���� � �������� (���� ��� ��������� �� ��������� �� ���������)
  if (myfoDialog in MyFormOptions) and (not (myfoEnableMaximize in MyFormOptions)) then
    if biMaximize in BorderIcons then
      Self.BorderIcons := Self.BorderIcons - [biMaximize];
  //������� ����� �����, �� ���� ��������� ������, ����� ��� �� ���� �����
  Left := mycHiddenFormLeft;
  //if (myfoModal in AMyFormOptions) then
  //����� ������ ���������������� ������, � ��� ����� � ������ �� ����������� ���� FPreventShow
//  AfterCreate;
  //(����)������� �����

  ShowForm(Self);
end;

procedure TForm_MDI.InitializeNewForm;
//����� ��� ������� ����� �����.
//�������� ����� � ��������� ���� ������ fsNormal!!!
var
  FS: ^TFormStyle;
  v: Variant;
begin
  inherited;
  if not (myfoModal in MyFormOptions) then begin
    FS := @FormStyle;
    FS^ := fsMDIChild;
  end
  else begin
    FS := @FormStyle;
    FS^ := fsNormal;
  end;
end;

class procedure TForm_MDI.ShowForm(AForm: TForm);
//����������� ����� � ����������� �� ������ FormStyle, ���������� � class function �������������
begin
  if AForm.Formstyle = fsnormal then
    AForm.Hide;
  //��������� ����������� ����� � ������ ���������� ������
  if AForm.Formstyle = fsnormal then begin
    TForm_MDI(AForm).FToLoadData := True;
    //�������� ������ � ����� � �������� �� � �������
    TForm_MDI(AForm).AfterCreate;
    //���� ������� Prepare (���������� � AfterCreate) ������� False, �� ���������� ����� �� �����
    if TForm_MDI(AForm).PrepareResult then AForm.ShowModal;
  end
  //��������� ����������� ����� � ������ ������ MDI_Child
  else begin
    //AForm.Left := 200;
    TForm_MDI(AForm).FToLoadData := True;
    //�������� ������ � ����� � �������� �� � �������
    //�����, ��� ��� ��� ��������������� ����� ��������� ������������, � ����� �� ��������,
    //���� �������� ������ ��� �� ����� (��� � ���� �����)
    TForm_MDI(AForm).AfterCreate;
    AForm.Show;
  end;
end;

class function TForm_MDI.TestMultiInstances(AFormDoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant): Boolean;
//���������, �������� �� ��� ���������� ����� �����
//������ True, ���� ����� ��������� �����
//� ����� ������ ���������� �� �������� ���� �����, ���� ������ � ����� ������� � ����
//��� myfoMultiCopy, ��� ������� ����������/�����������, fNone - ������� ����� �����
//�� ���� ������, ���������� �� ����, � ��� myfoMultiCopy, �� �� �������� ������� �����
var
  nm: Integer;
begin
  Result := True;
  //����� ����� �����, � ��� ��� �����������, ��� �� ������ ����������/����������� (����� �� �����) - ������� ����� �����
  if (myfoMultiCopy in AMyFormOptions) and (AMode in [fNone, fAdd, fCopy]) then
    Exit;
  //�����, �� ����� ��������� �� ����� ����� - ����� �� �������� ����
  //���� ����� � ����� ���� ��� ���� - ���������� �� �������� ����
  if (myfoMultiCopy in AMyFormOptions) then
    Result := Wh.BringToFrontIfExists(AFormDoc, AID)
  else
    Result := Wh.BringToFrontIfExists(AFormDoc, null);
end;

procedure TForm_MDI.AfterCreate;
//�������� ����� �������� ����� (������, �������� �� ������������, ����� ������������, ����� ����� ������� �����)
//�������� ������� ������� �������� ������ � �������� Prepare, ������� ��� ������ ����� ���� ��� ������� False
//�������� ������� ������� AfterPrepare, ��� ���������� �������������� ��������
begin
  InPrepare := True;
  Cth.SetWaitCursor;
  PrepareResult:= Prepare;
  if not PrepareResult then begin
  //  InPrepare := False;
    ExitWithoutShow;
  end;
  InPrepare := False;
  AfterPrepare;
  //������������� ����������� ��������� �������� ����� (��������� ����� �����������)
  if myfoSizeable in MyFormOptions then
    BorderStyle := bsSizeable
  else
    BorderStyle := bsDialog;
  ;
end;

procedure TForm_MDI.FormActivate(Sender: TObject);
//������� ������� ��� �������������� � �������� ������ ����
var
  st: string;
begin
  st:=Self.Name;
  Cth.SetWaitCursor(False);
  if FPreventShow then
    exit;
  if Left < 0 then
    Left := 10;
  Wh.ChildFormActivate(Self);
  if DefFocusedControl <> nil then
    DefFocusedControl.SetFocus;
end;

procedure TForm_MDI.FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
//���������, �������� �� ��������� �����
//��������� � ������������ � ����������� ��������
//���� ������������ ����� ������������, �� � ���� ����������� ����� ���������/������ ������
begin
//  Resize := False; exit;
  if not FIsFormShown then begin
    Resize := True;  exit;
  end;
  if FIISetStatusBar then
    Exit;
  //��������� ������������ ��������� �������� ����� �� ����� ���������� ������ � �������
  if InFormShow then
    Exit;
  if InPrepare then
    Exit;
  Resize := False;
  if PreventResize then
    Exit;
  if BorderStyle = bsDialog then
    Exit;
  Resize := True;
  if (NewWidth > MaxWidth) and (MaxWidth > 0) then
    NewWidth := MaxWidth;
  if (NewWidth < MinWidth) and (MinWidth > 0) then
    NewWidth := MinWidth;
  if (NewHeight > MaxHeight) and (MaxHeight > 0) then
    NewHeight := MaxHeight;
  if (NewHeight < MinHeight) and (MinHeight > 0) then
    NewHeight := MinHeight;
  if not InMaxMin then
    GetFormLTWH;
end;

procedure TForm_MDI.FormClose(Sender: TObject; var Action: TCloseAction);
//!!!� ������ ����������� ���� ���� �������� ��� ���� ������-��, �������
//� fsnormal ����� � fsMDIChild
var
  i: Integer;
  pr: Boolean;
begin
//        PreventResize:=True;
  Cth.SetWaitCursor(False);
//  if FPreventShow then begin Exit;
  try
 //   if FormStyle = fsMDIChild then
      Action := caFree;        //!!! ������ ��������� �����

    if (Self.Left > mycHiddenFormLeft) then begin
      if AutoSaveWindowPos then
        Settings.SaveWindowPos(Self, FormDoc);
//    Left:=mycHiddenFormLeft;
    end;
//Self.Left := mycHiddenFormLeft;
    if (not FPreventShow) then begin
      if (LockInDB = fEdit) or (LockInDB = fDelete) then
        Q.DBLock(False, FormDoc, VarToStr(id));
    end;
    FPreventShow:=True;
    Wh.ChildFormDestroy(Sender);
  except
  end;
end;

procedure TForm_MDI.FormCreate(Sender: TObject);
begin
//  close;
//fterCreate;
//bbb:=True;
end;

procedure TForm_MDI.FormShow(Sender: TObject);
var
  x, y, i: Integer;
  b: Boolean;
begin
  if FPreventShow then begin
    Left := mycHiddenFormLeft;
    Exit;
  end;
  InFormShow := True;
  if (myfoDialog in MyFormOptions) and (ParentForm <> nil) and (ParentForm is TForm) then begin
    //��� ���������� ������������ ������������ ������������ �����

    x := FrmMain.Height;
    i := FrmMain.ClientHeight;
    x := FrmMain.lb_GetTop.top;
    i := FrmMain.lb_GetBottom.top;

    x := TForm(ParentForm).Left + TForm(ParentForm).Width div 2 - Self.Width div 2;
//    i:=FrmMain.Width div 2 - Self.Width div 2;
//    x:=min(x, i);
    if x + Self.Width > FrmMain.ClientWidth - 10 then
      x := FrmMain.ClientWidth - Self.Width - 30;
    Self.Left := max(x, 0);

    x := TForm(ParentForm).Top + TForm(ParentForm).Height div 2 - Self.Height div 2;
    if x + Self.Height > FrmMain.FormsList.Top - FrmMain.Lb_GetTop.Top - 10 then
      x := FrmMain.FormsList.Top - FrmMain.Lb_GetTop.Top - Self.Height - 10;
    Self.Top := max(x, 0);

  end;
  Self.Top := Max(FrmMain.Lb_GetTop.Top, Self.Top);

  //��������������� ������� � ��������� ����, ���� ������� ��������� � ��
  //��� ���������� ������� � oncreate � ������ ���� ������ ���������
  Settings.RestoreWindowPos(Self, FormDoc);
  InFormShow := False;
  FIsFormShown := True;
end;

procedure TForm_MDI.Timer_AfterStartTimer(Sender: TObject);
begin
  Timer_AfterStart.Enabled := False;
  AfterStart;
end;

procedure TForm_MDI.AfterStart;
begin
end;

function TForm_MDI.FormDbLock(msg: string = '*|*'): TDialogType;
begin
  Mode := Q.DBLock(True, FormDoc, VarToStr(id), msg, Mode)[3];
  LockInDB := Mode;
  Result := Mode;
end;

procedure TForm_MDI.FormDestroy(Sender: TObject);
begin
  try
    inherited;
  except
  end;
end;

procedure TForm_MDI.ExitWithoutShow;
begin
  //==FPreventShow := True;
  Left := mycHiddenFormLeft;
  FormStyle := fsMDIChild;
  Self.Close;
end;

function TForm_MDI.Prepare: Boolean;
begin
  Result := True;
end;

procedure TForm_MDI.AfterPrepare;
begin
end;

function TForm_MDI.RefreshParentForm: Boolean;
var
  i: Integer;
  Form: TForm;
begin
{ //++ ��������� � ��������
  Form:=Wh.GetFormFromWindows(TForm(ParentForm));
  if form <> nil then myinfomessage('!!!');
Exit;
  For i:=0 to High(Wh.Windows) do

 }
  if ParentForm <> nil then
  try
{    if (ParentForm is TForm_MDI_Grid1) then begin
      TForm_MDI_Grid1(ParentForm).Refresh;
    end;}
    if (ParentForm is TFrmBasicMdi) then begin
      if TFrmBasicMdi(ParentForm).FindComponent('Frg1') <> nil then
        TFrDbGridEh(TFrmBasicMdi(ParentForm).FindComponent('Frg1')).RefreshGrid;
    end;
  except
  end;
end;

procedure TForm_MDI.SetStatusBar(TextLeft, TextRight: Variant; AVisible: Boolean);
//��������� ����� � ������ ������� � ���������� ���� (�� ����� � ������) � ��� ���������
//������ �������������� � ��������� ����� ��������� ��� ������ ��� � ������ (������ �� � uLabelColors)
//���� �������, �� ����� ���������� �������������, ������������� � �������� ������ ���������� = 0 ��� �������� ����� ���� ��������� �� ����
//� �������� ����� ���� ����������� ����� ������� ����������, ��� ��������� ��������������
//���� � �������� ������ ����� ����������� ������ SetStatusBar �������� ��� ������ ���������, �� �� �������� ��� ��������, ������ ����� ��������������� (����������/��������� ����)
//���� ����� ������� �� ����� �������� ��������� ����� ������ - ��� ��������� ������ �� ��������� - �������� ������ �����
var
  b: Boolean;
begin
  //�������� �����������! � mdi_grid1 ������ ���������� � repaint � ���� �� ��������� ����� �������� ��� ��������� �������
  if (P_StatusBar.Visible = AVisible) and (VarToStr(TextLeft) = S.NSt(FTextLeft)) and (VarToStr(TextRight) = S.NSt(FTextRight)) and (FStatusBarHeight = P_StatusBar.Height) then
    Exit;
  FIISetStatusBar := True;
  b := (P_StatusBar.Visible = AVisible) or (FStatusBarHeight = -1);
  if FStatusBarHeight = -1 then
    FStatusBarHeight := P_StatusBar.Height;
  P_StatusBar.Visible := AVisible;
  //������ ���, ����� ��������� ����� ������ � �������� ����� ��� ������� ������� � ������������ alBotoom, alcleent...
  //if P_StatusBar.Visible then
  if not b then
    Self.ClientHeight := Self.ClientHeight + S.IIf(AVisible, FStatusBarHeight, -FStatusBarHeight);
  if InPrepare and not AVisible then
    Self.ClientHeight := Self.ClientHeight - FStatusBarHeight;
  if AVisible then
    P_StatusBar.Height := FStatusBarHeight;
  if not AVisible then
    P_StatusBar.Height := 0;
  if AVisible then
    P_StatusBar.Top := 1000
  else
    P_StatusBar.Top := Self.ClientHeight - P_StatusBar.Height;
//  P_StatusBar.Top:=1000;
//  if AVisible and (P_StatusBar.Height = 0) then Self.ClientHeight:=Self.ClientHeight + FStatusBarHeight;

  Self.ClientHeight := P_StatusBar.Top + P_StatusBar.Height;

//  if not b then Self.ClientHeight:=Self.ClientHeight + S.IIf(AVisible, FStatusBarHeight, -FStatusBarHeight);

  FTextLeft := TextLeft;
  FTextRight := TextRight;

  Lb_StatusBar_Left.ResetColors;
  Lb_StatusBar_Left.Caption := '';
  if VarIsArray(TextLeft) then
    Lb_StatusBar_Left.SetCaptionAr2(TextLeft)
  else
    Lb_StatusBar_Left.SetCaption2(TextLeft);

  Lb_StatusBar_Right.ResetColors;
  Lb_StatusBar_Right.Caption := '';
  if VarIsArray(TextRight) then
    Lb_StatusBar_Right.SetCaptionAr2(TextRight)
  else
    Lb_StatusBar_Right.SetCaption2(TextRight);
  FIISetStatusBar := False;
end;

function TForm_MDI.ScrollBarVisible(isVert: Boolean = True): Boolean; //(WindowHandle: THandle)
begin
  if isVert then
    Result := (GetWindowlong(Handle, GWL_STYLE) and WS_VSCROLL) <> 0
  else
    Result := (GetWindowlong(Handle, GWL_STYLE) and WS_HSCROLL) <> 0;
end;

procedure TForm_MDI.GetFormLTWH;
begin
  PrevLeft := Left;
  PrevTop := Top;
  PrevWidth := Width;
  PrewHeight := Height;
end;

//���������� ���������
procedure TForm_MDI.WMSysCommand(var Msg: TWMSysCommand);
begin
//  DefaultHandler(Msg);Exit;
  if Msg.CmdType = SC_ZOOM then
  //�� ������ ������������/��������
  //��� ��� ���, � ��� ���� ����� ���� � ����� ������� ������������ ������
  //��������� ������ ������������/��������������
  begin
    Self.WindowState := wsNormal;
    if IsMaximized then begin
      //������ ����� ����������� ��������� � ������
      InMaxMin := True;
      Self.Top := PrevTop;
      Self.Left := PrevLeft;
      Self.Width := PrevWidth;
      Self.Height := PrewHeight;
      Msg.Result := 0;
      InMaxMin := False;
      InMaxMin := False;
      IsMaximized := False;
      Exit;
    end
    else begin
      //���������� �� ���� �����
      //������ �� ������ ��������� �������, ������� �������� ������ �� �������� � ������ �� ����/������, ������� ��������
      InMaxMin := True;
      GetFormLTWH;
      Self.Top := 0;
      Self.Left := 0;
      Self.Width := FrmMain.ClientWidth - 5;
      Self.Height := FrmMain.ClientHeight - 45;
      //���� ���-���� ��������� ��������, �� ������ ��� ������� (�� ����, �� ������ ���������, � ���� ��������� ������ ��� ������ ������)
      if ScrollBarVisible(False) then
        Self.Width := Self.Width - 15;
      if ScrollBarVisible(True) then
        Self.Height := Self.Height - 15;
      Msg.Result := 0;
      InMaxMin := False;
      IsMaximized := True;
      Exit;
    end;
  end;
{  if Msg.CmdType = SC_RESTORE then
  begin
    if Self.WindowState = wsMaximized then
    begin
      Self.WindowState:= wsNormal;//  wsMinimized;
      Msg.Result:= 0;
      Exit;
    end;
    if Self.WindowState = wsMinimized then
    begin
      Self.WindowState:= wsNormal; //wsMaximized;
      Msg.Result:= 0;
      Exit;
    end;
  end;}
  //�������� ������ wsMaximize �� �������� (�� ����� ������������� ���� �������� �� ��������� �� ��������� ����)
  DefaultHandler(Msg);
  if WindowState = wsMaximized then
    WindowState := wsNormal;
end;

function TForm_MDI.GetControlValue(ControlName: string; NullIfEmpty: Boolean = False): Variant;
//�������� �������� �������� �� ����� �� ��� �����
//���� ����������� NullIfEmpty �� ������� null ���� �������� ����� ������ ��� ''
begin
  Result:= Cth.GetControlValue(TControl(Self.FindComponent(ControlName)));
  if NullIfEmpty then Result:=S.NullIfEmpty(Result);
end;

initialization

finalization
  {
  if AllocMemCount <> 0 then ShowMessage('!!!');
  if AllocMemCount <> 0 then ShowMessage(IntToStr(AllocMemCount));
  if AllocMemCount <> 0 then  MessageBox(0, pansichar('An unexpected memory leak has occurred.'+intToStr(AllocMemCount)), 'Unexpected Memory Leak', MB_OK or MB_ICONERROR or MB_TASKMODAL);
}
begin
end;

end.


//����� �� �������� ��������, ������������ �����, � ��������� ����� ����������� BorderStyle:=bsDialog;
//����� ��� ���� ��� ����� �������������
//���� ����� �� ����, � Prepare ����������� PreventResize:=True;
//�� ���-����� �������� �� ������ ���������, ���� � ���� ��������� �� ��������� BorderStyle:=bsSizeable;



//��� ����� ������ ����� � �������� �����, ������, ��� ������������ �������� ������ ������ �������
//    PostMessage(Self.Handle, WM_CLOSE, 0, 0);
