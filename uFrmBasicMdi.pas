
unit uFrmBasicMdi;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh,
  DBGridEhToolCtrls, DBCtrlsEh, DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh,
  DBAxisGridsEh, DBGridEh, Math, Vcl.StdCtrls, Vcl.Mask, Buttons,
  uLabelColors, uData, uString,
  uFields
  ;



{$R *.dfm}



const
  mycHiddenFormLeft = -10000;

type
  TCustomFormMy = class(TCustomForm);


  //����� ��������� ����� ���� �������� � ������� � ������� ������ �����, ����� ����� � ���������� ����
  //� ���� ������ � ����������� ���������� ��������� �� ��� � ������ ����������,
  //��������������� � ��������� ����������� ��������� �������� �������� ����� �� ��������� �������� �������
  TSetControlsProc= procedure(ASelf: TObject; AControlValues: TVarDynArray);

  //��� ������ ������
  TMDIDlgPanelStyle = (
    dpsNone, dpsBottomRight, dpsBottomLeft, dpsTopRight, dpsTopLeft
  );

  //���������� � ����������
  TMDIStatusMode = (
    stbmNone, stbmCustom, stbmGrid, stbmDialog
  );

  //������� �� �������� ����� �� �������� ��� ��� �������� ����������
  //cqNone - �� ���������, ����������� ��� ����������
  //cqYN - ���� ������ ��������, �������: "������ ��������. ��� ����� �������? (Y/N)"
  //cqYNC - ���� ������ ��������, �������: "������ ��������. ���������? (��/��� ������)"
  TMDICloseQuery = (
    cqNone, cqYN, cqYNC
  );

  TMDIResult = record
    ModalResult: Integer;
    Data: Variant;
    DataA: TVarDynArray2;
  end;

  //����� �����, ��������������� � �������� (� ���������� ������� Prepare)
  TMDIOpt = record
    //������� � ���������� ������ ������
    DlgPanelStyle: TMDIDlgPanelStyle;
    //�������� ���������� (���, ������������,  ���������� ����� (���-�� �����, �������������..),
    //  ���������� ����������� ���� (����� ������, ������, ������ ��������)
    StatusBarMode: TMDIStatusMode;
    //��������� ������ �����
    DlgButtonsL: TVarDynArray2;
    //��������� ������ ������
    DlgButtonsR: TVarDynArray2;
    //������� � ������������ ������� "�� ���������" � ������ ������, ��� ������� fAdd � fCopy
    UseChbNoClose: Boolean;
    //�������������� ������������ ���������, ����� ��������� ���� ��� ��� ������������ � pnlFrmClient; ���������� � �������� �������� �����.
    AutoAlignControls: Boolean;
    ControlsWoAligment: TControlArray;
    AutoControlDataChanged: Boolean;
    //������� �� �������� ����� �� �������� ��� ��� �������� ����������
    RequestWhereClose: TMDICloseQuery;
    //�������, � ������� ���������� ����� ��� �������� ����, ��� ��� �������� �� ����� ������, ���� NoCloseIfAdd
    DefFocusedControl: TWinControl;
    //���� ������, �� ������ ���������� '' ��� ��������
    NoSerializeCtrls: Boolean;
    //��������� ������ � ��������� ����� ��� ������� ��
    RefreshParent: Boolean;
    //����������, �������� �� ����� �� ��������������� ������
    InfoArray: TVarDynArray2;
  end;


  TFrmBasicMdi = class(TForm)
    pnlFrmMain: TPanel;
    pnlFrmClient: TPanel;
    pnlFrmBtns: TPanel;
    bvlFrmBtnsTl: TBevel;
    bvlFrmBtnsB: TBevel;
    pnlFrmBtnsContainer: TPanel;
    pnlFrmBtnsMain: TPanel;
    pnlFrmBtnsChb: TPanel;
    chbNoclose: TCheckBox;
    pnlFrmBtnsR: TPanel;
    pnlFrmBtnsInfo: TPanel;
    imgFrmInfo: TImage;
    pnlFrmBtnsL: TPanel;
    pnlFrmBtnsC: TPanel;
    pnlStatusBar: TPanel;
    lblStatusBarR: TLabel;
    lblStatusBarL: TLabel;
    tmrAfterCreate: TTimer;
    {������� �����}
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tmrAfterCreateTimer(Sender: TObject);
  private
    FFormDoc: string;
    FMode: TDialogType;
    FParentForm: TComponent;
    FParentControl: TComponent;
    FID: Variant;
    FAddParam: Variant;
    FMyFormOptions: TMyFormOptions;


    FModuleId: Integer;
    FTextLeft, FTextRight: Variant;
    FStatusBarHeight: Integer;
    FInSetStatusBar: Boolean;
    FPreventShow: Boolean;
    FToLoadData: Boolean;
    FFormResult: TMDIResult;
    FDlgPanelMinWidth: Integer;
    FWinSizeCorrected: Boolean;
    FCtrlBegValuesStr, FCtrlCurrValuesStr: string;
    //� ������ showdialog ����� �������� ������� �� ���������� ��� ���. ������ ���� ��������� ��������� �����.
    FTab0Control: TWinControl;
    FHasError: Boolean;
    procedure SetError(Value: Boolean);
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
  protected
    //��������� ���������� ������� �������
    FPrepareResult: Boolean;
    //������� �������� ����� �����, ������: ['ControlName1', 'rule1', 'ControlName2', 'rule2', ...]
    FControlVerifycations: TVarDynArray;
    //�������������� ��������� �����, ��� ������� �������� � �������� �� ����� ���������� (� Prepare)
    FOpt: TMDIOpt;
    //��������, ����������� ��� �����������/�������������, ������ ����������� � ��������
    FPrevLeft, FPrevTop, FPrevWidth, FPrewHeight: Integer;
    FIsMaximized: Boolean;
    FInMaxMin: Boolean;
    FInBtOkClick: Boolean;
    FInBtCancelClick: Boolean;
    FInPrepare: Boolean;
    FInControlOnChaange: Boolean;
    FAfterFormShow: Boolean;
    //���� �� ������� ����������, ��������� FormDbLock = Mode, ���� ����� ����� fDelete or FEdit �� ���������� ��������� ��������� ��� �������� �����
    //���� True, �� ��� �������� ����� ��������� ���������, ��������� ��� ����� FormDoc � ID
    FLockInDB: TDialogType;
    //�� ������� ����� ����� �������� ������, �������� �� �� ��� ����� bsDialog, ����? ��� ����������� �������
//    PreventResize: Boolean;
    //������ ������ � ������ - ����. ������ ��������������� � ��������. ���� ����������, ��� ������� �� ����� ������� � ���������� ����, ����� �� ���������
    FErrorMessage: string;
    //�������, ��� ������ ���� ��������. ������ ��������������� � ��������
    FIsDataChanged: Boolean;
    //����������� � ������������ ������ � ������, ����� ���������� � ������������ ��� �������. �������������� ����� � onCanResize
    //���� ������� �� �����������, �� ����� ����������� ������������ �������� ������ ������ (�� ���������� ������) � � ������ �������� �������� WHCorrected
    FWHBounds: TCoord;
    //������ [������, ������], ������ ������� ���������� ����� �����, ��� ������� ����������� � ���� �����, ���� ������ ������ �����
    //����� ��������������� � Prepare, �� ����������� �������� ���������������� ���������
    FWHCorrected: TCoord;
    //���������� ��� ���������� �������� �����
    FDisableClose: Boolean;
    //��������� ��� ������� �������� ���� �� ��������, ���� ��� ���� ���������� ���� IsDataChanged
    FQueryCloseMessage: string;
    //������ ������������� � ������ ������
    btnOk: TBitBtn;
    //������ ������, ���� �� ����������������
    btnCancel: TBitBtn;
    //����
    FAllreadyCreated: Boolean;
    F: TFields;
    FFormNotCreatedByApplication: Boolean;
    //������ ������ � ������. ������ ��������������� � ��������. ���� ����������, ������ �� ���������� �����������
    property HasError: Boolean read FHasError write SetError;
    //������������ ������ ��� �����, ����� ���� ����������� � ����� ����� � ����, �������� �������� ������ Show
    property FormResult: TMDIResult read FFormResult write FFormResult;
    //�����������
    constructor Create(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant; AAddParam: Variant; AControlValues: TVarDynArray; APSetControls: pointer = nil); reintroduce; virtual;
    //��������� �������� ������ (Prepare) � � ����������� �� ���������� ���������� ����� ��� ���������
    //���������� �������������� � ������������ ���� RunAfterCreateProc=True ��� �� ������, ���� � ������������ ���� ���������� �������������� ���������,
    //�� ���� ������ ���� ��������� ��� False � AfterCreate
    //������ ���� ����������� ������ � ������������ ������� ����� ������ ������������� ������������ � ������������� ����� (���� ����, �����),
    //��� �� ��� ������� � ������� ����� onCreate ���� ������ ��� ������ �� ����������
    //����� ���� �� ������� ����� onCreate � ���, �� � �������� mdi_grid1 �� ��������� ��� ����������
    //������ ��� ����, ���� �� ��������!
    procedure AfterCreate;
    //���������� �������� ����� ����������� �����
    procedure AfterStart; virtual;
    //������ ���� �������, ���� ���������� ���������� �� ������ �����, � �����������
    procedure ExitWithoutShow; virtual;
    //���������� ����� �������� ����� � ������������,
    //���� ���������� ���� �� ���������� ����� �� ������������ � ��������� ����� ExitWithoutShow
    //(�� ���� False �������� ����������� �����);
    //�������������.
    function  Prepare(): Boolean; reintroduce; virtual;
    //��������� ��� ��������� �������� ���������� �����, ������������ � ������������ � ������ ����������� ����������� ����,
    //� ����� ���������� ���� � ������� �����, ��������� � uchet.dpr, � ��������� ���������������
    //�� ��������� ���������� ���� � �������� �� ����� fMode ����� ��� ����������
    //AFormDoc = * ������� ��� ������������ ����� �����
    function  PrepareCreatedForm(AOwner: TObject; AFormDoc: string; ACaption: string; AMode: TDialogType;
      AID: Variant; AOptions: TMyFormOptions = [myfoModal, myfoDialog, myfoDialogButtonsB]; AAutoAlign: Boolean = True): Boolean;
    procedure AfterPrepare; virtual;
    //������ ���������� ����� ����������� ����� (� ������� ������������� ����� ���������)
    function  RefreshParentForm: Boolean;
    //������������� �������� ���������� �� ������ WHCorrected, ����, ��������, ���� �������� ���������
    procedure CorrectFormSize;
    //��������� �������� ������ ��������� (ImgInfoMain)
    procedure SetMainInfoIcon;
    //������������� ����� �� ������������
    procedure CenteringByParent;
    //��������� ���������� �� ������� � ����. ���������� ������� � �������, ���������� ����� ����� ����� � ���������� �����, ��� �������� fNone ������ ���� ����� �� Prepere � False
    function  FormDbLock(msg: string = '*|*'): TDialogType;
    //��������� ������ ������
    procedure VerirfyGrids(Sender: TObject; var AHasError: Boolean; var AErrorSt: string; var AIsChanged: Boolean);
    //�������������� �������� (��� ����, ��� �� ����������� ��������� �������� � �������)
    //������ �������� SetErrorMarker ��� ��������� �� ����� ������� ����������, �� ������������ �������� �������� � �������,
    //��� ����� ������� ������ ������ (True) - � ���� ������ ����� ��� ����� ��������� ���������� ���������
    function  VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean; virtual;
    //��������� �������������� �������� ����� �������, ���� Verify ������� �� = True (� ����� ������ �� ����������)
    //����� ��������������� ��, ���� ���-�� �� � �������, �� ��������������� ������ ������� ErrorMessage
    //(���� ��� ��������, �� ����� �������� ��� ������� ��, ���� ���������� �� "?", �� ������, ��� Yes ����� ����������,
    //��� "-" ��������� �� �����, �� � �� ����� ����������, ��� * ����� ����������� ���������
    //����� �������������� ��� �������������� �������� ��� ������� ���������� ����� �������� ������
    //���������� ����� � ��� ��������, �� �� ��� ���������, ���� �������� ��� �������� �� �����, � ��� ��� ����������
    procedure VerifyBeforeSave; virtual;
    //��������� �������. ������ ������������� ��� ��������� ����������
    function  Save: Boolean; virtual;
    //������� ���������� ��� OnCange ��� ��� ��������� OnClick ��� ���� ��������� �� �����, ����� ��������� ������
    procedure ControlOnChangeEvent(Sender: TObject); virtual;
    //������� ���������� ������������ - ���� ��������� �������� �������� ���������� � ���� �������, �� ��� �� ��������� �������� (���������� ����)
    procedure ControlOnChange(Sender: TObject); virtual;
    procedure ControlOnEnter(Sender: TObject); virtual;
    procedure ControlOnExit(Sender: TObject); virtual;
    procedure ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean); virtual;
    procedure btnOkClick(Sender: TObject); virtual;
    procedure btnCancelClick(Sender: TObject); virtual;
    procedure btnClick(Sender: TObject); virtual;
    procedure EditButtonsClick(Sender: TObject; var Handled: Boolean); virtual;
    procedure GetFormLTWH;
    //�������� �������� �������� �� ����� �� ��� �����
    //���� ����������� NullIfEmpty �� ������� null ���� �������� ����� ������ ��� ''
    function  GetControlValue(ControlName: string; NullIfEmpty: Boolean = False): Variant;
    //������������� ������� (���������, ������ ������, ��������� ������� ������),
    //� ����� ������� �������� ���������
    procedure SetControlEvents;
    //������������� �������������� ��� ��� (Editable) ��� �������� �� ������� AConrols;
    //���� ��������� ������, �� ��� �������� ����� (������ � ������� ������� ������ ����������� �� ���� ���������)
    procedure SetControlsEditable(AConrols: array of TControl; Editable: Boolean = True; Disabled: Boolean = False; Parent: TControl = nil);
    //������������� �������� ��������� ����� (����, ����� ����� ������� �����)
    //���� ������ NoSerializeCtrls, �� ������ ���������� '' ��� ��������
    procedure Serialize; virtual;
    //������� ������, �� ���������, � ���������� � ��������� ���������� ������
    procedure RefreshDlgPanel;
    //��������� ����� � ������ ������� � ���������� ���� (�� ����� � ������) � ��� ���������
    //������ �������������� � ��������� ����� ��������� ��� ������ ��� � ������ (������ �� � uLabelColors)
    //���� �������, �� ����� ���������� �������������, ������������� � �������� ������ ���������� = 0 ��� �������� ����� ���� ��������� �� ����
    //� �������� ����� ���� ����������� ����� ������� ����������, ��� ��������� ��������������
    //���� � �������� ������ ����� ����������� ������ SetStatusBar �������� ��� ������ ���������, �� �� �������� ��� ��������, ������ ����� ��������������� (����������/��������� ����)
    //���� ����� ������� �� ����� �������� ��������� ����� ������ - ��� ��������� ������ �� ��������� - �������� ������ �����
    procedure RefreshStatusBar(TextLeft, TextRight: Variant; AVisible: Boolean);
    function  IsScrollBarVisible(isVert: Boolean = True): Boolean;
    //����� ��� ������� ����� �����.
    //�������� ����� � ��������� ���� ������ fsNormal!!!
    procedure InitializeNewForm; override;



    //����������� ����� � ����������� �� ������ FormStyle, ���������� � class function �������������
    class procedure ShowForm(AForm: TForm);
    procedure ShowFormAsMdi;
    //�������� ���� �������� ����� (����� � ������, ���� ����� ���� ������� � ������ fsNormal,
    //��� ���������� � ������ ����� myfoModal ����, ��� ���� ����� �� ���������� ����)
    class procedure AfterFormClose(AForm: TForm);
    //���������, �������� �� ��� ���������� ����� �����
    //������ True, ���� ����� ��������� �����
    //� ����� ������ ���������� �� �������� ���� �����, ���� ������ � ����� ������� � ����
    //��� myfoMultiCopy, ��� ������� ����������/�����������, fNone - ������� ����� �����
    //�� ���� ������, ���������� �� ����, � ��� myfoMultiCopy, �� �� �������� ������� �����
    class function TestMultiInstances(AFormDoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant): Boolean;
    function FindCmp(AParent: TWinControl; AControlName: string; ASuffix: Integer = 0): TComponent;
  public
    { Public declarations }
    //���� ������, ��������� ��� ������ ������ �������� ����
    property ModuleId: Integer read FModuleId;
    //�� ���������
    property FormDoc: string read FFormDoc write FFormDoc;
    //����� �����, �� ����� ��� �������
    property Mode: TDialogType read FMode write  FMode;
    //������������ �����, ������ ��������������� � �������� � ���������� ������������
    property ParentForm: TComponent read FParentForm;
    property ParentControl: TComponent read FParentControl;
    //���� ������, �� ����� ��� �������.
    property ID: Variant read FID write FID;
    //�������������� ��������� ����� (����� �������� ������������ ������ � ������� VarArrayOf)
    property AddParam: Variant read FAddParam;
    //����� ��������� �����, ������������ ��� ������� ��� ������ ������� �� �����������
    //(myfoModal, myfoDialog, myfoDefault, myfoMultiCopy, myfoMultiCopyWoId, myfoOneCopy, myfoEnableMaximize, myfoSizeable, myfoRefreshParent)
    property MyFormOptions: TMyFormOptions read FMyFormOptions write FMyFormOptions;
    //������ ���� ��������
    property IsDataChanged: Boolean read FIsDataChanged;

    //��������� �������� �������� ������
    //��������� ������ �� ������� ������� ��������
    //���� Sender = nil �� ��������� ��� ��������, ����� ����������
    //onInput ��������� ��� �������� ������������ � ������ ��������� �������� ��������
    //���� ���� �� ���� ������� �� �������, ������������ ��� ���� ������ Error
    //����� �������, ��� ����������� �������� ������ ���� ���� Eh
    //����� ������ HasError ������������ �� ������ ���������� �������� Eh - ���������,
    //���� HasError = True, �� ������ �� ����������
    //�������� ����� ���������� � �������� ��������� � ������ ������ ��� ��������, � ������ ��������
    //��� ������ ���� � ��� ������� ��
    procedure Verify(Sender: TObject; onInput: Boolean = False); virtual;

    {--------------------------------------------------------------------------}
    {  ��� ������� ���������� ��� �������� � �������� �����-�������, ��� ���������� ��� ����������� ���-����� ����, � ������� ���������� �����������
     � ��������� ������ � �� ������ � ���� ������ �������������.
       ����� ��� �������� �� ������ ����� �������� ���������� ������� ����� ����� ����� �������������� ������ ������� ��� ������� �����������, �������� ����,
     ��������� � ������ ����������. ����� ����������� ������ (�������� ��������� �� ���������� ����������, ����� ���� � ���������� ������, ������� ��������
     � ���������� ������� ��� � ���-����������, ���������� � class function ���������� ��������� ��������� PSetControlsProc(ASelf: TObject; AControlValues: TVarDynArray),
     ���������� � ����������� ������ �������� ��������� � ��������� �� ������ ���������, � � ��� ����������� ������ �������� ����������� ���������
     (��� ��� ��������� ��������� ��� � ������������ � ����� ����� �������� �������� �����, � �������� ������� ������. PSetControlsProc ��������� � ������������ ����� ����������.
     ����� ������ ������������ ���� ���������������� ������������ ��������� ���������� ���������
     }

    //�������� ����� � ���������� �����������,
    //���������� ��������� ���� Vavariant �� ������� �����, ��������������� � ������������ ����� � ���� ��� �� ������ (����� ����� ��� ������� � ������ ShowModal)
    class function Show(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant; AAddParam: Variant): TMDIResult; virtual;
    //�������� ����� � ���������� �����������, �� ������ � ��������� ������, ���������� MadalResult
    class function ShowModal2(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant; AAddParam: Variant): TMDIResult; virtual;
  end;



var
  FrmBasicMdi: TFrmBasicMdi;

implementation

uses
  uWindows, uSettings, uFrmMain, uDBOra, uForms, uMessages, uFrDbGridEh
  ;

{$R *.dfm}


procedure TFrmBasicMdi.RefreshStatusBar(TextLeft, TextRight: Variant; AVisible: Boolean);
//��������� ����� � ������ ������� � ���������� ���� (�� ����� � ������) � ��� ���������
//������ �������������� � ��������� ����� ��������� ��� ������ ��� � ������ (������ �� � uLabelColors)
//���� �������, �� ����� ���������� �������������, ������������� � �������� ������ ���������� = 0 ��� �������� ����� ���� ��������� �� ����
//� �������� ����� ���� ����������� ����� ������� ����������, ��� ��������� ��������������
//���� � �������� ������ ����� ����������� ������ SetStatusBar �������� ��� ������ ���������, �� �� �������� ��� ��������, ������ ����� ��������������� (����������/��������� ����)
//���� ����� ������� �� ����� �������� ��������� ����� ������ - ��� ��������� ������ �� ��������� - �������� ������ �����
var
  b: Boolean;
  st: string;
begin
  if not pnlStatusBar.Visible then
    Exit;
  FInSetStatusBar := True;
  pnlStatusBar.Visible := (FOpt.StatusBarMode <> stbmNone);
  pnlStatusBar.BevelInner := bvNone;
  pnlStatusBar.BevelOuter := bvNone;
  pnlStatusBar.Color := cl3DLight;

  repeat
    b := (pnlStatusBar.Visible = AVisible) or (FStatusBarHeight = -1);
    if FStatusBarHeight = -1 then
      FStatusBarHeight := pnlStatusBar.Height;
  //������ ���, ����� ��������� ����� ������ � �������� ����� ��� ������� ������� � ������������ alBotoom, alcleent...
    if not b then
      Self.ClientHeight := Self.ClientHeight + S.IIf(AVisible, FStatusBarHeight, -FStatusBarHeight);
    if FInPrepare and not AVisible then
      Self.ClientHeight := Self.ClientHeight - FStatusBarHeight;
    if AVisible then
      pnlStatusBar.Height := FStatusBarHeight;
    if not AVisible then
      pnlStatusBar.Height := 0;
    if AVisible then
      pnlStatusBar.Top := 1000
    else
      pnlStatusBar.Top := Self.ClientHeight - pnlStatusBar.Height;
    if not pnlStatusBar.Visible then
      Break;

    if FAfterFormShow or FInPrepare then begin  //!!!
      ;
      if FOpt.StatusBarMode = stbmDialog then begin
        if HasError then
          TextRight := '$0000FF������������ ������!'
        else if FIsDataChanged then
          TextRight := '$FF00FF������ ' + S.Iif(Mode = fAdd, '�������.', '��������.')
        else
          TextRight := '';
        TextLeft := Cth.FModeToCaption(Mode);
      end;

      if TextLeft = '*' then
        TextLeft := FTextLeft;
      if TextRight = '*' then
        TextRight := FTextRight;

      //�������� �����������! � mdi_grid1 ������ ���������� � repaint � ���� �� ��������� ����� �������� ��� ��������� �������
      if (VarToStr(TextLeft) = S.NSt(FTextLeft)) and (VarToStr(TextRight) = S.NSt(FTextRight)) and (FStatusBarHeight = pnlStatusBar.Height) then
        Break;

      if TextLeft <> '*' then
        FTextLeft := TextLeft;
      if TextRight <> '*' then
        FTextRight := TextRight;

      if VarIsArray(FTextLeft) then
        lblStatusBarL.SetCaptionAr2(FTextLeft)
      else
        lblStatusBarL.SetCaption2(FTextLeft);
      if VarIsArray(FTextRight) then
        lblStatusBarR.SetCaptionAr2(FTextRight)
      else begin
        st := Trim(VarToStr(FTextRight));
        if (st = '') or (st[1] <> '$') then begin
          lblStatusBarR.Font.Color := clBlack;
          lblStatusBarR.Caption := st;
        end
        else begin
          lblStatusBarR.Font.Color := StrToInt(Copy(st, 1, 7));
          lblStatusBarR.Caption := Copy(st, 8);
        end;
      end;
    end;
  until True;
  FInSetStatusBar := False;
end;


function FindControl(AControl: TWinControl; AName: string): TControl;
var
  i, j: Integer;
begin
  Result:= nil;
  for i:= 0 to AControl.ControlCount -1 do
    if S.CompareStI(AControl.Controls[i].Name, AName)
      then begin Result:= AControl.Controls[i]; Exit; end;
  ;
end;

procedure SetPanelsAlign(AParent: TWiNControl; AVertical: Boolean = False);
//������������ ������� � ���������� �� �����������,
//������� ������� ����������� ������, ������������� ������������� �����, ������� � 1,
//������������� �������� alRight, ����� ������ ����� � ����� -1
//� ����� 0 �������� alClient (����� ����� ���� ���� ��� �� �����)
//!!! AVertical ���� �� ��������������
var
  i, j, k, l: Integer;
  p: TPanel;
  va: TVarDynArray2;
  st: string;
begin
  va:=[];
  For i:= AParent.ControlCount - 1 downto 0 do
    if AParent.Controls[i] is TPanel then begin
      p:= TPanel(AParent.Controls[i]);
      va:= va + [[i, p.Tag, p.Name]];
      p.Align:= alNone;
      p.Anchors:=[];
      //p.Caption:=inttostr(p.tag);  //��� ��������
    end;
  A.VarDynArray2Sort(va, 0);
  A.VarDynArraySort(va, 1);
  l:=0;
  k:=0;
  for i:= 0 to High(va) do begin
    if va[i, 1] > 0 then begin
      p:= TPanel(AParent.Controls[va[i][0]]);
      st:=p.Name;
      p.Left:=k;
      p.Align:= alLeft;
      k:=p.Left+p.Width;
    end;
  end;
  l:=k;
  k:=AParent.Width;
  for i:= High(va) downto 0 do begin
    if va[i, 1] < 0 then begin
      p:= TPanel(AParent.Controls[va[i][0]]);
      st:=p.Name;
      p.Left:=k-p.Width - 10;
      p.Align:= alRight;
      k:=p.Left;
    end;
  end;
  for i:= 0 to High(va) do begin
    if va[i, 1] = 0 then begin
      p:= TPanel(AParent.Controls[va[i][0]]);
      st:=p.Name;
      p.Left:=l;
      p.Align:= alClient;
    end;
  end;
end;

procedure VertAlignCtrls(AParent: TWiNControl);
var
  i, j: Integer;
begin
  For i:= AParent.ComponentCount - 1 downto 0 do begin
    if AParent.Components[i] is TBitBtn
      then TBitBtn(AParent.Components[i]).Top:= (AParent.Height - TBitBtn(AParent.Components[i]).Height) div 2;
  end;
  For i:= AParent.ControlCount - 1 downto 0 do
    AParent.Controls[i].Top:= (AParent.Height - AParent.Controls[i].Height) div 2;
end;


procedure TFrmBasicMdi.RefreshDlgPanel;
//������� ��������, ��������� ������ ��� ���������� ������
//(������ ����� ����)
//�������� �������� ������ �������, ������ ������� �� ������ ����� � ������������ �����������, �� ������ btnOk � btnCancel, �������� ����� � ��������
//������ ������ �����, ������, ������ � ��������� ������� �����, � ������ �� ���������� ��������� �����
//���� �������� ������� ������ � ���, �� ����� ������� ��� ������. ���� ������ �� ��������, ������ ����� ������
//���� ������ ���������, �� ����������� �� ������������ ������� ������, ����� ��������� ��� ����.
//����� ������� �������� �������. ������������� ���������, � �������� ������� ������ (� ����������-������), ������������ �� ���������
//������ ����� ����� ����������� ����� � ��������� ������ (�� ���������) ��� �����, ���� ����������� ����� (�� ���������) ��� ������
//���� ����������� ����� ������ ����� ������ ��� ������������ ����������, �� ��� ��������������� ��������� ����� ������ ������
var
  i, j: Integer;
  p: TPanel;
  PTemp: TPanel;
  c: TComponent;
  st: string;
begin
  //���� ����� ������� ��� ������� ���������� � ��� ������������, �� ������
  if FAllreadyCreated then
    Exit;
  if FOpt.DlgPanelStyle = dpsNone then begin
    pnlFrmBtns.Height:= 0;
    pnlFrmBtns.Visible:= False;
    Exit;
  end;
  pnlFrmBtnsContainer.Padding.Top := MY_FORMPRM_BTNPANEL_V_EDGES;
  pnlFrmBtnsContainer.Padding.Bottom := pnlFrmBtnsContainer.Padding.Top;
  pnlFrmBtns.Height:= Max(pnlFrmBtns.Height, MY_FORMPRM_BTN_DEF_H + pnlFrmBtnsContainer.Padding.Top * 2 + 2 * 2 + 4);
  if FOpt.DlgPanelStyle in [dpsTopLeft, dpsTopRight]  then begin
    pnlFrmClient.Align:=alNone;
    pnlFrmBtns.Align:=alTop;
    pnlFrmClient.Align:=alClient;
    pnlFrmBtnsContainer.Top:= 0;
  end;
  bvlFrmBtnsB.Visible:= FOpt.DlgPanelStyle in [dpsTopLeft, dpsTopRight];
  bvlFrmBtnsTl.Visible:= not bvlFrmBtnsB.Visible;
  PTemp:=TPanel.Create(Self);
  i:=pnlFrmBtnsContainer.ControlCount;
  For i:= pnlFrmBtnsContainer.ControlCount - 1 downto 0 do
    if pnlFrmBtnsContainer.Controls[i] is TPanel then begin
      p:= TPanel(pnlFrmBtnsContainer.Controls[i]);
      p.Caption:='';
      p.BevelInner:= bvNone;
      p.BevelOuter:= bvNone;
      p.Height:= pnlFrmBtnsContainer.Height;
    end;
  if FOpt.DlgPanelStyle in [dpsTopLeft, dpsBottomLeft] then begin
    pnlFrmBtnsMain.Tag:= 1;
    pnlFrmBtnsChb.Tag:= 2;
    pnlFrmBtnsL.Tag:= 3;
    pnlFrmBtnsR.Tag:= -2;
    pnlFrmBtnsInfo.Tag:= -1;
  end
  else begin
    pnlFrmBtnsChb.Tag:= -3;
    pnlFrmBtnsR.Tag:= -2;
    pnlFrmBtnsMain.Tag:= -1;
  end;
  SetPanelsAlign(pnlFrmBtnsContainer);
  Cth.CreateButtons(pnlFrmBtnsMain,
    [[mbtOk, Mode in [fEdit, FAdd, fCopy, fDelete], S.Decode([Mode, fDelete, '�������', '��']), S.Decode([Mode, fDelete, 'delete', 'ok'])],
     [mbtCancel, True, S.Decode([Mode, fView, '�������', fNone, '�������', '������']), S.Decode([Mode, fView, 'viewclose', fNone, 'cancel', 'cancel'])]],
    btnCancelClick, cbttBNormal, '', 0, 0, False);
  //���� �� ������� �������� ������ ������, ����� ���������� ������� �������, ���� � �����-���� �� ��� ����������� ������������� ����� �������� ��, ��� � ��������� �����
  //� ����� �������� pnlFrmBtnsMain.AutoSize := True;
  pnlFrmBtnsMain.AutoSize := False;
  pnlFrmBtnsMain.Width := 1024 * 10;
    //�������� ������ �������� ���������� ��� �������� ���� ��� �������� ��� ������ �����, �� ���� ��������� ������� ���������� OK
  if Mode in [fView, fNone]
    then btnCancel := TBitBtn(pnlFrmBtnsMain.Controls[0])
    else begin
      btnOk := TBitBtn(pnlFrmBtnsMain.Controls[0]);
      btnCancel := TBitBtn(pnlFrmBtnsMain.Controls[1]);
    end;
  if btnOk <> nil then begin
    TButton(btnOk).OnClick:= btnOkClick;
    TButton(btnOk).Cancel := False;
    TButton(btnOk).ModalResult := mrNone;
  end;
  if btnCancel <> nil then begin
    TButton(btnCancel).OnClick:= btnCancelClick;
    TButton(btnCancel).Cancel := FMode in [fView, fDelete];
    TButton(btnCancel).ModalResult := mrCancel;
  end;
  Self.ModalResult := mrNone;
  //btnOk.ModalResult:= mrOk;
  //���� ���� ������������� ������ ��� ����� � ������ ������, �� �������� ������ � ������� ������ ������,
  //�����, ���� � ��� ��� ���������, �� �������� ������ = 0, � ���� ���� �� ������� ������� ��� ���������
  if Length(FOpt.DlgButtonsL) > 0
    then Cth.CreateButtons(pnlFrmBtnsL, FOpt.DlgButtonsL, btnClick, cbttBNormal, '', 0, 0, False)
    else if pnlFrmBtnsL.ControlCount = 0
      then pnlFrmBtnsL.Width := 0;
  if Length(FOpt.DlgButtonsR) > 0
    then begin
      Cth.CreateButtons(pnlFrmBtnsR, FOpt.DlgButtonsR, btnClick, cbttBNormal, '', 0, 0, False);
    end
    else if pnlFrmBtnsR.ControlCount = 0
      then pnlFrmBtnsR.Width := 0;
  //���� � ������� ���� ������ �����������, ������ ���
  if (pnlFrmBtnsL.ControlCount = 1) and (pnlFrmBtnsL.Controls[0] is TBevel) then
    pnlFrmBtnsL.Controls[0].Free;
  if (pnlFrmBtnsR.ControlCount = 1) and (pnlFrmBtnsR.Controls[0] is TBevel) then
    pnlFrmBtnsR.Controls[0].Free;
{  for i := 0 to pnlFrmBtnsL.ComponentCount - 1 do
    if (pnlFrmBtnsL.Components[i] is TButton) and not Assigned(TButton(pnlFrmBtnsL.Components[i]).OnClick) then
      TButton(pnlFrmBtnsL.Components[i]).OnClick := BtClick;
  for i := 0 to pnlFrmBtnsR.ComponentCount - 1 do
    if (pnlFrmBtnsL.Components[i] is TButton) and not Assigned(TButton(pnlFrmBtnsL.Components[i]).OnClick) then
      TButton(pnlFrmBtnsL.Components[i]).OnClick := BtClick; }
//  Cth.CreateButtons(pnlFrmBtnsR, FOpt.DlgButtonsR, BtClick, cbttBNormal, '', 0, 0, False);
  pnlFrmBtnsChb.Visible:=FOpt.UseChbNoClose and (Mode in [FAdd, FCopy]);
  //���� �� ����� �� ������� �������� � ������ ImgInfoMain, �� ����������� �������� � ���� ������ � ���, ��� ������ ������� ���������� �����
  //����� ������ ������ ���������
  c:= FindComponent('ImgInfoMain');
  if (c = nil) and (Length(Cth.SetInfoIconText(Self, FOpt.InfoArray)) > 0) then begin
    imgFrmInfo.Left:= 3;
    imgFrmInfo.Name:= 'ImgInfoMain';
  end;
  c:= FindComponent('ImgInfoMain');
  if (c <> nil) and (TControl(c).Parent = pnlFrmBtnsInfo)
    then pnlFrmBtnsInfo.Width := MY_FORMPRM_BTN_DEF_H + 4
    else pnlFrmBtnsInfo.Width := 0;
  For i:= pnlFrmBtnsContainer.ControlCount - 1 downto 0 do begin
    TWinControl(pnlFrmBtnsContainer.Controls[i]).Height:= pnlFrmBtnsContainer.ClientHeight;
    VertAlignCtrls(TWinControl(pnlFrmBtnsContainer.Controls[i]));
  end;
  pnlFrmBtnsMain.AutoSize := True;
  FDlgPanelMinWidth:= Self.Width {- pnlFrmBtnsContainer.ClientWidth} - pnlFrmBtnsC.Width;
end;
























class function TFrmBasicMdi.Show(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant; AAddParam: Variant): TMDIResult;
var
  F: TForm;
begin
  F:= Create(AOwner, ADoc, AMyFormOptions, AMode, AID, AAddParam, []);
  Result := TFrmBasicMdi(F).FFormResult;
  AfterFormClose(F);
end;

class function TFrmBasicMdi.ShowModal2(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant; AAddParam: Variant): TMDIResult;
var
  F: TForm;
begin
  F:= Create(AOwner, ADoc, AMyFormOptions + [myfoModal], AMode, AID, AAddParam, []);
  Result := TFrmBasicMdi(F).FFormResult;
  Result.ModalResult := TFrmBasicMdi(F).ModalResult;
  AfterFormClose(F);
end;

constructor TFrmBasicMdi.Create(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; Aid: Variant; AAddParam: Variant; AControlValues: TVarDynArray; APSetControls: pointer = nil);
//����������� ������
procedure PSetControlsProc;
begin
  TSetControlsProc(APSetControls)(Self, AControlValues);
end;
begin
  FFormNotCreatedByApplication := True;
  if APSetControls <> nil then
    PSetControlsProc;
  //(����)������� �����
  //����� �� ����� ���� ������� �� ������������ � �������� ������
  if not PrepareCreatedForm(AOwner, ADoc, '', AMode, Aid, AMyFormOptions, False) then
    Exit;
  FAddParam := AAddParam;
  ShowForm(Self);
end;

procedure TFrmBasicMdi.InitializeNewForm;
//��������� ����� ��� ������� ����� �����.
var
  FS: ^TFormStyle;
  v: Variant;
begin
  inherited;
  if not FFormNotCreatedByApplication then begin
    FModuleId := cMainModule;
    FStatusBarHeight := -1;
    Exit;
  end;
  if not (myfoModal in MyFormOptions) then begin
    FS := @FormStyle;
    FS^ := fsMDIChild;
  end
  else begin
    FS := @FormStyle;
    FS^ := fsNormal;
  end;
end;

class procedure TFrmBasicMdi.ShowForm(AForm: TForm);
//����������� ����� � ����������� �� ������ FormStyle, ���������� � class function �������������
begin
  if not TFrmBasicMdi(AForm).FFormNotCreatedByApplication then
    Exit;
 //AForm.Formstyle := fsMDIChild;
  if AForm.Formstyle = fsNormal then
    AForm.Hide;
  //��������� ����������� ����� � ������ ���������� ������
  if AForm.Formstyle = fsNormal then begin
    TFrmBasicMdi(AForm).FToLoadData := True;
    //�������� ������ � ����� � �������� �� � �������
    TFrmBasicMdi(AForm).AfterCreate;
    //���� ������� Prepare (���������� � AfterCreate) ������� False, �� ���������� ����� �� �����
    if TFrmBasicMdi(AForm).FPrepareResult then begin
      TFrmBasicMdi(AForm).FFormResult.ModalResult := AForm.ShowModal;
    end;
  end  //��������� ����������� ����� � ������ ������ MDI_Child
  else begin
    TFrmBasicMdi(AForm).FToLoadData := True;
    //�������� ������ � ����� � �������� �� � �������
    //�����, ��� ��� ��� ��������������� ����� ��������� ������������, � ����� �� ��������,
    //���� �������� ������ ��� �� ����� (��� � ���� �����)
    TFrmBasicMdi(AForm).AfterCreate;
    //���� ������� Prepare (���������� � AfterCreate) ������� False, �� ���������� ����� �� �����
    if TFrmBasicMdi(AForm).FPrepareResult then
      AForm.Show;
  end;
end;

procedure TFrmBasicMdi.ShowFormAsMdi;
//�������� ������� mdi-child �����
begin
  Self.Formstyle := fsMDIChild;
  TCustomForm(Self).Show;
  ShowWindow(Handle, SW_SHOW);
  Wh.ChildFormActivate(Self);
end;

class procedure TFrmBasicMdi.AfterFormClose(AForm: TForm);
//�������� ���� �������� ����� (����� � ������, ���� ����� ���� ������� � ������ fsNormal,
//��� ���������� � ������ ����� myfoModal ����, ��� ���� ����� �� ���������� ����)
begin
  //����� �� � ������ ������, ������.
  if TFrmBasicMdi(AForm).FormStyle <> fsNormal
    then Exit;
  //���� ��������� �����, � ����� ��������������� �� ������� ����� ����������, �� ���� �� ���� ��������� ����� ����� (prepare ������� False)
  //�� ������-�� ��� ���������� ������ �����. ��������, ��������� ����� �� ������������ �����, ���� �� �������� �� �� �������.
  if TFrmBasicMdi(AForm).ParentForm = nil
    then FrmMain.SetFocus
    else TForm(TFrmBasicMdi(AForm).ParentForm).SetFocus;
  //��������� ������� �����
  //� ������ fsNormal caFree � FormClose �� ����������� ���� �� �����, ��� ����� � �� ���� ����������� � vcl.Forms
  //���� ������������ Release, �� �������� ����� ������-�� �������� ��������
  //���� ��������� TEdit �� �����, �� ��� �������� ����� ������ ����� � ��������� ������ ��� ����� ��������.
  //����� �������� �������� ��������, ���������� � �������� �����, ��� ���������� ���� �����.
  //����� Free ����� �������� ������ �������� �������� ���� ����� ��� ������ ������, � ����������� �� ��������.
  //������ ��� ��������� ����������� ������ �������� ����� ������������, ���� ���� ����� ������� ���� TFrmBasicMdi(AForm).btnOk.Free;
  //Release �������� ���� �� ��������� CM_RELEASE, � ������ ��������� ���������� �����, �� ��������� ����� ������������ ��
  //����� Free �� ������� ������������ ����� ���������
  //�������� ������� �������� �� ����� ����������� ����� ������� ��� ������ ������ ������������ �����������, ��� ��� �����������
  //��������� ������� ������ ���� ��������� �������������
//  TFrmBasicMdi(AForm).Release;
  TFrmBasicMdi(AForm).Free;
end;


class function TFrmBasicMdi.TestMultiInstances(AFormDoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant): Boolean;
//���������, �������� �� ��� ���������� ����� �����
//������ True, ���� ����� ��������� �����
//� ����� ������ ���������� �� �������� ���� �����, ���� ������ � ����� ������� � ����
//��� myfoMultiCopy, ��� ������� ����������/�����������, fNone - ������� ����� �����
//�� ���� ������, ���������� �� ����, � ��� myfoMultiCopy, �� �� �������� ������� �����
var
  nm: Integer;
begin
  Result := True;
  if AFormDoc = '' then
    Exit;
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

procedure TFrmBasicMdi.AfterCreate;
//�������� ����� �������� ����� (������, �������� �� ������������, ����� ������������, ����� ����� ������� �����)
//�������� ������� ������� �������� ������ � �������� Prepare, ������� ��� ������ ����� ���� ��� ������� False
//�������� ������� ������� AfterPrepare, ��� ���������� �������������� ��������
begin
  FInPrepare := True;
  Cth.SetWaitCursor;
  FPrepareResult := Prepare;
  Cth.SetWaitCursor(False);
  if not FPrepareResult then begin
    //������� �����
    ExitWithoutShow;
  end;
  FInPrepare := False;
  Cth.SetWaitCursor;
//  pnlStatusBar.Visible:= Opt.HasStatusBar;
  AfterPrepare;
  Cth.SetWaitCursor(False);
  //������������� ����������� ��������� �������� ����� (��������� ����� �����������)
  if myfoSizeable in MyFormOptions then
    BorderStyle := bsSizeable
  else
    BorderStyle := bsDialog;
end;


procedure TFrmBasicMdi.CenteringByParent;
//������������� ����� �� ������������
var
  x, y, i: Integer;
  b: Boolean;
  st: string;
begin
  x := FrmMain.Height;
  i := FrmMain.ClientHeight;
  x := FrmMain.lbl_GetTop.top;
  i := FrmMain.lbl_GetBottom.top;
  x := TForm(ParentForm).Left + TForm(ParentForm).Width div 2 - Self.Width div 2;
  if x + Self.Width > FrmMain.ClientWidth - 10 then
    x := FrmMain.ClientWidth - Self.Width - 30;
  Self.Left := max(x, 0);
  x := TForm(ParentForm).Top + TForm(ParentForm).Height div 2 - Self.Height div 2;
  if x + Self.Height > FrmMain.FormsList.Top - FrmMain.lbl_GetTop.Top - 10 then
    x := FrmMain.FormsList.Top - FrmMain.lbl_GetTop.Top - Self.Height - 10;
  Self.Top := max(x, 0);
end;

procedure TFrmBasicMdi.tmrAfterCreateTimer(Sender: TObject);
begin
  tmrAfterCreate.Enabled := False;
  AfterStart;
end;

procedure TFrmBasicMdi.AfterStart;
begin
end;


function TFrmBasicMdi.FormDbLock(msg: string = '*|*'): TDialogType;
//�������� ����� ���������� ��� �����,
//������ � ������ �������� FFormDoc � ID � ������ ��� ������� fNone, fEdit, fDelete
//� ����������, ���� ���������� ����� �� �������, ������� ���������,
//����� ����� ������� �� fView ��� ������������ ���� ��������������, ��� �� fNone � ������ ��������
//� ���������� ������ � ������� ���� ���������� � (������) ����� ��� �����������
begin
  FLockInDB := FMode;
  Result := FMode;
  if (FFormDoc = '')or(FID = null) then Exit;
  FMode := Q.DBLock(True, FFormDoc, VarToStr(FID), msg, FMode)[3];
  FLockInDB := FMode;
  Result := FMode;
end;

procedure TFrmBasicMdi.ExitWithoutShow;
begin
  Left := mycHiddenFormLeft;
  Self.Close;
end;

function TFrmBasicMdi.Prepare: Boolean;
begin
  Result := True;
end;

procedure TFrmBasicMdi.AfterPrepare;
begin
//  RefreshDlgPanel;
//  CorrectFormSize;
//  Cth.SetDialogCaption(Self, Mode, Self.Caption);
//  RefreshStatusBar('','',True);  //��� �������� �������� ����� �������� ������ �����, ��� �� ��������
end;

procedure TFrmBasicMdi.SetMainInfoIcon;
//�������� �������� ����-������ ����������,
//���� ������ ���������-TImage � ������ ImgInfoMain
//��� ���� ������ ����� �������������� � ���������� ���� ��� ��������� �� 'main' � � �������� ���� �� 'MAIN', ����� ������ �� ���������
var
  c: TComponent;
  wh: Integer;
begin
  c:= FindComponent('ImgInfoMain');
  if c = nil then Exit;
  if S.Right(c.Name, 4) = 'main'
    then wh := MY_FORMPRM_BTN_DEF_H
    else if S.Right(c.Name, 4) = 'MAIN'
      then wh := MY_FORMPRM_SPEEDBTN_DEF_H
      else wh := TImage(c).Width;
  if (c = nil)or not (c is TImage) then Exit;
  Cth.SetInfoIcon(TImage(c), Cth.SetInfoIconText(Self, FOpt.InfoArray), wh);  //!!
end;


function TFrmBasicMdi.RefreshParentForm: Boolean;
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
  if not FOpt.RefreshParent then
    Exit;
  if ParentForm <> nil then
  try
//    if (ParentForm is TForm_MDI_Grid1) then begin
//      TForm_MDI_Grid1(ParentForm).Refresh;
//    end;
    if (ParentForm is TFrmBasicMdi) then begin
      if TFrmBasicMdi(ParentForm).FindComponent('Frg1') <> nil then
        TFrDbGridEh(TFrmBasicMdi(ParentForm).FindComponent('Frg1')).RefreshGrid;
    end;
  except
  end;
end;


function TFrmBasicMdi.IsScrollBarVisible(isVert: Boolean = True): Boolean; //(WindowHandle: THandle)
begin
  if isVert then
    Result := (GetWindowlong(Handle, GWL_STYLE) and WS_VSCROLL) <> 0
  else
    Result := (GetWindowlong(Handle, GWL_STYLE) and WS_HSCROLL) <> 0;
end;

procedure TFrmBasicMdi.GetFormLTWH;
begin
  FPrevLeft := Left;
  FPrevTop := Top;
  FPrevWidth := Width;
  FPrewHeight := Height;
end;

procedure TFrmBasicMdi.CorrectFormSize;
//������������� �������� ���������� �� ������ WHCorrected, ����, ��������, ���� �������� ���������
var
  i, j ,r: Integer;
  ar, at: TControlArray;
  c: TComponent;
  st: string;
begin
  //��������/��������� �������� � �������� ������
  if FOpt.AutoAlignControls then
    FWHCorrected := Cth.AlignControls(pnlFrmClient, FOpt.ControlsWoAligment, False);
  if FOpt.AutoAlignControls then
    Cth.MakePanelsFlat(pnlFrmClient, []);
  //�������� ��������, � ������� ����� �� ������� � ������� ����, � ������� ��� �����
  for i := 0 to Self.ComponentCount - 1 do begin
    c := Self.Components[i];
    if c is TControl then begin
      if not Cth.IsChildControl(pnlFrmClient, TControl(c), True) then
        Continue;
      if (akRight in (TControl(c).Anchors)) or (c.Tag = -100) then begin
        ar := ar + [TControl(c)];
        TWinControl(c).Anchors := TControl(c).Anchors - [akRight];

      end;
      if akBottom in (TControl(c).Anchors) then begin
        at := at + [TControl(c)];
        TWinControl(c).Anchors := TControl(c).Anchors - [akBottom];
      end;
    end;
  end;
    //���� ����� ������ ������, ��������� �� ���������� ���������� ������
  //!!! ���� �� ��������� ����������� ������, ������ ������� �������������� alClient
  j:= 0;
  if FOpt.DlgPanelStyle <> dpsNone then begin
    j:=pnlFrmBtnsMain.Width + pnlFrmBtnsL.Width + pnlFrmBtnsR.Width + S.IIf(pnlFrmBtnsChb.Visible, pnlFrmBtnsChb.Width, 0) + S.IIf(pnlFrmBtnsInfo.Visible, pnlFrmBtnsInfo.Width, 0) + 12;
  end;
  //����������� ������ �� ������ ������ ������
//  WHBounds.X:= Max(WHBounds.X, FDlgPanelMinWidth);
//  WHCorrected.X:= Max(Max(WHCorrected.X, FDlgPanelMinWidth), WHBounds.X);
  //���� ���� ������ ��� �������������, �������� ��
  //��������� ������� ���������� �������
  //��������� ����������� ������ � ������
  if (FWHCorrected.X <> 0) then
    ClientWidth := FWHCorrected.X + MY_FORMPRM_H_EDGES + 2;
  if ClientWidth < j then
    ClientWidth := j;
  if (FWHBounds.X = 0) then
    FWHBounds.X := Width;

  if (FWHCorrected.Y <> 0) then
    ClientHeight := FWHCorrected.Y + MY_FORMPRM_V_TOP * 2 + pnlFrmBtns.Height + S.IIf(pnlStatusBar.Visible and (FOpt.StatusBarMode <> stbmNone), pnlStatusBar.Height, 0);
  if (FWHBounds.Y = 0) then
    FWHBounds.Y := Height;

{
  if (FWHCorrected.X <> 0) or (j <> 0) then begin
    ClientWidth := Max(ClientWidth, Max(FWHCorrected.X + MY_FORMPRM_H_EDGES + 2, j));  //������-�� ��� ����������� ��������� ������
    if (FWHBounds.X = 0) then
      FWHBounds.X := Width;
  end;}
{  if (FWHCorrected.Y <> 0) or (FOpt.DlgPanelStyle <> dpsNone) then begin
    ClientHeight := FWHCorrected.Y + MY_FORMPRM_V_TOP * 2 + pnlFrmBtns.Height + S.IIf(pnlStatusBar.Visible, pnlStatusBar.Height, 0);
    if (FWHBounds.Y = 0) then
      FWHBounds.Y := Height;
  end;}
    //����������� �����
  for i:= 0 to High(ar) do
    TControl(ar[i]).Anchors:= TControl(ar[i]).Anchors + [akRight];
  for i:= 0 to High(at) do
    TControl(at[i]).Anchors:= TControl(at[i]).Anchors + [akBottom];
  //���� ������� ������� �������� ����� -1, ��� ������������� (�� �� ����) - ��������� �� ������� ������ ��������
  if (FWHBounds.X2 <> 0) and ((FWHBounds.X2 = -1) or (FWHBounds.X2 < FWHBounds.X))
    then FWHBounds.X2:= FWHBounds.X;
  if (FWHBounds.Y2 <> 0) and ((FWHBounds.Y2 = -1) or (FWHBounds.Y2 < FWHBounds.Y))
    then FWHBounds.Y2:= FWHBounds.Y;
  //����, ��� ������� ����� ��������������� (����� ������� ��������, ���� ����������� ������ ������ ��������� ��� ����������� - � FormCanResize
  FWinSizeCorrected:= True;
end;

//���������� ���������
procedure TFrmBasicMdi.WMSysCommand(var Msg: TWMSysCommand);
begin
//  DefaultHandler(Msg);Exit;
  if Msg.CmdType = SC_ZOOM then
  //�� ������ ������������/��������
  //��� ��� ���, � ��� ���� ����� ���� � ����� ������� ������������ ������
  //��������� ������ ������������/��������������
  begin
    Self.WindowState := wsNormal;
    if FIsMaximized then begin
      //������ ����� ����������� ��������� � ������
      FInMaxMin := True;
      Self.Top := FPrevTop;
      Self.Left := FPrevLeft;
      Self.Width := FPrevWidth;
      Self.Height := FPrewHeight;
      Msg.Result := 0;
      FInMaxMin := False;
      FInMaxMin := False;
      FIsMaximized := False;
      Exit;
    end
    else begin
      //���������� �� ���� �����
      //������ �� ������ ��������� �������, ������� �������� ������ �� �������� � ������ �� ����/������, ������� ��������
      FInMaxMin := True;
      GetFormLTWH;
      Self.Top := 0;
      Self.Left := 0;
      Self.Width := FrmMain.ClientWidth - 5;
      Self.Height := FrmMain.ClientHeight - 45;
      //���� ���-���� ��������� ��������, �� ������ ��� ������� (�� ����, �� ������ ���������, � ���� ��������� ������ ��� ������ ������)
      if IsScrollBarVisible(False) then
        Self.Width := Self.Width - 15;
      if IsScrollBarVisible(True) then
        Self.Height := Self.Height - 15;
      Msg.Result := 0;
      FInMaxMin := False;
      FIsMaximized := True;
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

function TFrmBasicMdi.FindCmp(AParent: TWinControl; AControlName: string; ASuffix: Integer = 0): TComponent;
var
  i: Integer;
  c: TComponent;
begin
  Result:= nil;
  if ASuffix <> 0
    then AControlName := AControlName + 'Sfx' + IntToStr(ASuffix);
  for i:=0 to AParent.ComponentCount - 1 do begin
    c:= AParent.Components[i];
    if S.CompareStI(c.name, AControlName)
      then begin
        Result:= c;
        Exit;
      end
      else if (c is TWinControl) or (c is TFrame)
        then FindCmp(TWinControl(c), AControlName, ASuffix);
  end;
end;

procedure TFrmBasicMdi.SetControlEvents;
//������������� ������� (���������, ������ ������, ��������� ������� ������),
//� ����� ������� �������� ���������
var
  i: Integer;
begin
  //��������� �������� ��������� ��������� ��� ���
  //���������� ������ ���� ��������� � �� ������� �������� [cname1, cver1, cname2, cver2...]
  Cth.SetControlsVerification(Self, FControlVerifycations);
  //��������� ������� ���� ��-��������� �����, ���� ��� �� ���� ��������� ���� � ��������� ����� ��� � Prepare
  Cth.SetControlsEhEvents(pnlFrmClient, False, True, nil, ControlOnExit, ControlOnChangeEvent, ControlCheckDrawRequiredState, EditButtonsClick);
exit;
  Cth.SetControlsOnChange(Self, ControlOnChange, True);
  Cth.SetControlsOnExit(Self, ControlOnExit);
  Cth.SetControlsOnCheckDrawRequired(Self, ControlCheckDrawRequiredState);
end;

procedure TFrmBasicMdi.SetControlsEditable(AConrols: array of TControl; Editable: Boolean = True; Disabled: Boolean = False; Parent: TControl = nil);
//������������� �������������� ��� ��� (Editable) ��� �������� �� ������� AConrols;
//���� ��������� ������, �� ��� �������� ����� (������ � ������� ������� ������ ����������� �� ���� ���������)
var
  i, j: Integer;
  c: TControl;
  va: TVarDynArray;
begin
  va := [];
  for i := 0 to High(AConrols) do
    va := va + [AConrols[i].Name];
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TWinControl then begin
      c := TControl(Components[i]);
      if not Cth.IsChildControl(pnlFrmClient, TWinControl(c), True)
        then Continue;
//      if A.PosInArray(c.Name, ['pnl_statusbar', 'lbl_StatusBar_Left', 'lbl_StatusBar_Right', 'pnl_bottom', 'bt_ok', 'bt_cancel', 'chb_NoClose'], True) >= 0 then
//        Continue;
      if (Length(AConrols) = 0) or (A.PosInArray(c.Name, va, True) >= 0) then begin
        Cth.SetControlNotEditable(c, not Editable, False, True);
        if c is TCustomDBEditEh then
          Cth.SetEhControlEditButtonState(c, Editable, Editable);
      end;
    end;
end;

procedure TFrmBasicMdi.Serialize;
//
begin
  if FOpt.NoSerializeCtrls then begin
    FCtrlCurrValuesStr := '';
    Exit;
  end;
  FCtrlCurrValuesStr := Cth.SerializeControlValuesArr2(Cth.GetControlValuesArr2(Self, nil, [], ['chb_NoClose']))
end;





function TFrmBasicMdi.GetControlValue(ControlName: string; NullIfEmpty: Boolean = False): Variant;
//�������� �������� �������� �� ����� �� ��� �����
//���� ����������� NullIfEmpty �� ������� null ���� �������� ����� ������ ��� ''
begin
  Result:= Cth.GetControlValue(TControl(Self.FindComponent(ControlName)));
//  Result:=FindComponent
  if NullIfEmpty then Result:=S.NullIfEmpty(Result);
end;

procedure TFrmBasicMdi.ControlOnChangeEvent(Sender: TObject);
//������� ��������� ������ ��������
begin
  //����� ���� � ��������� ��������
  if FInPrepare then Exit;
  if not FInControlOnChaange then begin
    FInControlOnChaange := True;
    ControlOnChange(Sender);
  end;
  //��������, ������� ��� � ���� ������� ��������
  Serialize;
  Verify(Sender, True);
  FInControlOnChaange := False;
end;

procedure TFrmBasicMdi.ControlOnChange(Sender: TObject);
begin

end;

procedure TFrmBasicMdi.ControlOnEnter(Sender: TObject);
begin
  //����� ���� � ��������� ��������
  if FInPrepare then Exit;
end;

procedure TFrmBasicMdi.ControlOnExit(Sender: TObject);
begin
  //����� ���� � ��������� ��������
  if FInPrepare then Exit;
  //��������
  Verify(Sender);
end;

procedure TFrmBasicMdi.ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean);
begin
  Cth.VerifyVisualise(Self);
end;

procedure TFrmBasicMdi.VerirfyGrids(Sender: TObject; var AHasError: Boolean; var AErrorSt: string; var AIsChanged: Boolean);
//�������� ����������� TFrDBGridEh ��� �� ���� ������ �� �����, � ��� ����� �������� � RowDetailPanel
var
  i, j: Integer;
begin
  AHasError := False;
  AErrorSt := '';
  AIsChanged := False;
  if Sender = nil then begin
    for i := 0 to ComponentCount - 1 do
      if Components[i] is TFrDBGridEh then begin
        if TFrDBGridEh(Components[i]).HasError then
          AHasError := True;
        if TFrDBGridEh(Components[i]).ErrorMessage <> '' then
          AErrorSt := TFrDBGridEh(Components[i]).ErrorMessage;
        if TFrDBGridEh(Components[i]).IsDataChanged then
          AIsChanged := True;
      end;
  end;
  if Sender is TFrDBGridEh then begin
    if TFrDBGridEh(Sender).HasError then
      AHasError := True;
    if TFrDBGridEh(Sender).ErrorMessage <> '' then
      AErrorSt := TFrDBGridEh(Sender).ErrorMessage;
    if TFrDBGridEh(Sender).IsDataChanged then
      AIsChanged := True;
  end;
  if Sender = nil then
    S.ConcatStP(FErrorMessage, AErrorSt, #13#10);
end;


function TFrmBasicMdi.VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean;
//�������������� �������� (��� ����, ��� �� ����������� ��������� �������� � �������)
//������ �������� SetErrorMarker ��� ��������� �� ����� ������� ����������, �� ������������ �������� �������� � �������,
//��� ����� ������� ������ ������ (True) - � ���� ������ ����� ��� ����� ��������� ����������� ���������
begin
  Result:= False;
end;

procedure TFrmBasicMdi.VerifyBeforeSave;
//��������� �������������� �������� ����� �������, ���� Verify ������� �� = True
//������ ��������������� ��, ���� ���-�� �� � �������: ���� ������ � Result True,
//�� ����� ������ ��������� "������ �� ���������!"
begin
end;

procedure TFrmBasicMdi.Verify(Sender: TObject; onInput: Boolean = False);
//�������� ������������ ������
//���������� ������� ��� ��������, ��� ��� - ��������� ���
//� ������� ��� �������� ��� ����� ������ � �������� (� ������� onChange)
//����������� �� ��������� ��� DbEh-�������� � TFrDBGridEh
//(� ������ TFrDBGridEh �� ��� �������� Verify ������������ �����,
//��� �� ����������� ��� �������� ��� nil
var
  i, j, s: Integer;
  c: TControl;
  ok1: Boolean;
  b: Boolean;
  st: string;
  GridsErr: Boolean;
  GridsErrSt: string;
  GridsCh: Boolean;

begin
  //�� ��������� ��� �������������� �������� ������.
  //��� �������������� �������� ���� � Prepare ���� ������� Verify(nil)
  if FInPrepare and (Sender <> nil) then Exit;
  FErrorMessage := '';
  //��� ��������� � �������� ������ ��
  if (Mode = fView) or (Mode = fDelete) then begin
    HasError := False;
    FIsDataChanged:= False;
    if btnOk <> nil then btnOk.Enabled := not HasError;
    Exit;
  end;
  if Sender = nil then begin
    //�������� ��� DbEh
    Cth.VerifyAllDbEhControls(Self);
    //������-�� ��� ������� ������ ��, ������ �� ������, ����� ������ ���� GridsErr ����������� ����� True!!!
    VerirfyGrids(nil, GridsErr, GridsErrSt, GridsCh);
  end
  else begin
    //�������� �������
    Cth.VerifyControl(TControl(Sender), onInput);
    VerirfyGrids({Sender}nil, GridsErr, GridsErrSt, GridsCh);  //!!! ����� ��������� ��� �����
  end;
  //�������������� �������� (��� ����, ��� �� ����������� ��������� �������� � �������)
  //������ �������� SetErrorMarker ��� ��������� �� ����� ������� ����������, �� ������������ �������� �������� � �������,
  //���� ����� ���������� HasError
  b:= VerifyAdd(Sender, onInput);
  //������� ������ �������� � �������������
  HasError := not Cth.VerifyVisualise(Self) or b or GridsErr;
  if HasError and (Sender <> nil)
    then st:= TControl(Sender).Name;
  if not FInPrepare
    then FIsDataChanged:= (FCtrlCurrValuesStr <> FCtrlBegValuesStr) or (GridsCh);
//  if FOpt.StatusBarMode = stbmDialog then
    RefreshStatusBar('*', '*', True);
end;

procedure TFrmBasicMdi.SetError(Value: Boolean);
var
  b: Boolean;
begin
  b:= FHasError <> Value;
  FHasError := Value;
  //������� ���������� � ����������
//  if FOpt.StatusBarMode = stbmDialog then
    if b then RefreshStatusBar('*', '*', True);
  //������ ������ ��
  if btnOk <> nil then btnOk.Enabled := not HasError;
end;


function TFrmBasicMdi.Save: Boolean;
begin
  Result:= True;
end;

procedure TFrmBasicMdi.btnOkClick(Sender: TObject);
//��������� ������ �������������
//(��������, ������� �������� ���� btnOk)
begin
  FInBtOkClick:= True;
{  TButton(Sender).Cancel := False;
  TButton(Sender).ModalResult := mrNone;
  Self.ModalResult := mrNone;
  Exit;}
  repeat
  if (Mode = fView) then begin
    Self.ModalResult:= mrCancel;
    if Formstyle <> fsNormal then Close;
    Break;
  end;
  Verify(nil);
  if Mode <> fDelete then begin
    if HasError then Break;
  end;
  VerifyBeforeSave;
  if FErrorMessage <> '' then begin
    if Pos('?', FErrorMessage) = 1 then begin
      if MyQuestionMessage(Copy(FErrorMessage, 2)) <> mrYes
        then Break;
    end
    else begin
      MyWarningMessage(FErrorMessage, ['-', '*������ �� ���������!']);
      Break;
    end;
  end;
  if HasError then begin
    //���� �� �������, �� � ������ ������, ���� � VerifyBeforeSave HasError ��������� � True, ��� �� ������ �������� ������ ����� �������� �����������
    HasError := False;
    Break;
  end;
  if not Save then  Break;
  RefreshParentForm;
  if FOpt.DefFocusedControl <> nil then
    FOpt.DefFocusedControl.SetFocus;
  if (not chbNoclose.Visible) or (not chbNoclose.Checked) then begin
    Self.ModalResult:= mrOk;
    if Formstyle <> fsNormal then Close;
    Break;
  end;
  Break;
  until False;
  FInBtOkClick:= False;
end;

procedure TFrmBasicMdi.btnCancelClick(Sender: TObject);
begin
  FInBtCancelClick:= True;
  ModalResult:= mrNone;
  Close;
  FInBtCancelClick:= False;
end;

procedure TFrmBasicMdi.btnClick(Sender: TObject);
begin
end;

procedure TFrmBasicMdi.EditButtonsClick(Sender: TObject; var Handled: Boolean);
begin
end;







procedure TFrmBasicMdi.FormActivate(Sender: TObject);
//������� ������� ��� �������������� � �������� ������ ����
begin
  Cth.SetWaitCursor(False);
  if FPreventShow then Exit;
  if Left < 0 then Left := 10;
  Wh.ChildFormActivate(Self);
end;

procedure TFrmBasicMdi.FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
//���������, �������� �� ��������� �����
//��������� � ������������ � ����������� ��������
//���� ������������ ����� ������������, �� � ���� ����������� ����� ���������/������ ������
begin
  Resize := True;
  //��������� ������������ ��������� �������� �����, ���� ����� ��������� ����������, ��� �� ��������������� ������� �����, � �� ����� ���������� ������ � �������
  if FInSetStatusBar or not FWinSizeCorrected or FInPrepare then
    Exit;
  if BorderStyle = bsDialog then begin
    Resize := False;
    Exit;
  end;
  if (NewWidth > FWHBounds.X2) and (FWHBounds.X2 > 0) then
    NewWidth := FWHBounds.X2;
  if (NewWidth < FWHBounds.X) and (FWHBounds.X > 0) then
    NewWidth := FWHBounds.X;
  if (NewHeight > FWHBounds.Y2) and (FWHBounds.Y2 > 0) then
    NewHeight := FWHBounds.Y2;
  if (NewHeight < FWHBounds.Y) and (FWHBounds.Y > 0) then
    NewHeight := FWHBounds.Y;
  if not FInMaxMin then
    GetFormLTWH;
end;

procedure TFrmBasicMdi.FormClose(Sender: TObject; var Action: TCloseAction);
//!� ������ ����������� ���� ���� �������� ��� ���� ������-��, �������
//� fsnormal ����� � fsMDIChild
var
  i: Integer;
  pr: Boolean;
{procedure TCustomFormMy.VisibleChanging;
begin
  if (FormStyle = fsMDIChild) and Visible and (Parent = nil) then
    raise EInvalidOperation.Create(SMDIChildNotVisible);
end;}
begin
  //������� ������ ��������� ��������
  if (not FFormNotCreatedByApplication) and (FormStyle = fsNormal) then begin
    Settings.SaveWindowPos(Self, FormDoc);
    if (FLockInDB = fEdit) or (FLockInDB = fDelete) then
      Q.DBLock(False, FormDoc, VarToStr(id));
    Wh.ChildFormDestroy(Sender);
    Exit;
  end;
  Cth.SetWaitCursor(False);
  try
    // ������ ��������� �����
    Action := caFree;
    //���� ����� ������������� ���������
    if FormDoc <> '' then begin
      if (Self.Left > mycHiddenFormLeft) then begin
        //�������� ������� � ������� ����
        Settings.SaveWindowPos(Self, FormDoc);
      end;
      if (not FPreventShow) then begin
        //������� ���������� � �� �� ���������
        if (FLockInDB = fEdit) or (FLockInDB = fDelete) then
          Q.DBLock(False, FormDoc, VarToStr(id));
      end;
    end;
    FPreventShow:=True;
    Wh.ChildFormDestroy(Sender);
  except
  end;
end;

procedure TFrmBasicMdi.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
//���������, ����� �� ����� ���������
//�� ��������� � ������ ��������� ����� DisableClose ������� - � ��������� ������ ��� ������ �������,
//��� ������ ������ � ������, ���� ������ ��������, � ���� ����� ������� �� ��������/����������
//����� � ���� ������ ������ ����� ����� � ��� �������� ����������, � � ������ ������ �������� ���� ���������� ����� �� ����������
var
  mr: Integer;
  FQueryCloseMessageSt: string;
  EscPressed: Boolean;
begin
  //��������, ��� �� � ��������� FormClose �������� �����. �����, ��� ��� �����, � ������ ���� ������
  //������� ������ �� ��������, ��� �������� ���������� �� ����� ����� ������ ��� (���� �������� �� ���� ��������)
  if FQueryCloseMessage <> '' then
    FQueryCloseMessageSt := FQueryCloseMessage
  else if FOpt.RequestWhereClose = cqYNC then
    FQueryCloseMessageSt := '������ ���� ��������?'#13#10'���������?'
  else
    FQueryCloseMessageSt := '������ ���� ��������?'#13#10'��� ����� ������� ������?';
  if FrmMain.InFormClose then begin
    CanClose:= True;
    Exit;
  end;
  if FDisableClose then begin
    CanClose:= False;
    Exit;
  end;
  //�� ������ ���������: ���������� ������� ������ �� ��������� Cancel
  //���� ����� �� �� ���� ������ �� ������� ��� ��� ���� ������� Esc
  EscPressed := False;
  if (FMode in [fAdd, fCopy, fEdit, fNone]) and FIsDataChanged and (btnCancel <> nil) and not btnCancel.Focused then begin
    EscPressed := True;
  end;
  EscPressed := False; //!!!
  //��� ������� �� � ����� ������ ��������� ��������
  if FInBtOkClick {or FInBtCancelClick} then begin
    CanClose:= True;
  end
  //���� ���� ������ Esc ��� � ����� ������ ���� ���������� ������ �� �������� �����, �������
  else if (EscPressed or (FOpt.RequestWhereClose = cqYN)) and (FIsDataChanged) then begin
    //������� ��� �������
    CanClose:= MyQuestionMessage(FQueryCloseMessageSt) = mrYes;
  end
  else if (EscPressed or (FOpt.RequestWhereClose = cqYNC)) and (FIsDataChanged) then begin
    //������� ��� ����������, �������� ��� ������� �����
    mr:= MyMessageDlg(FQueryCloseMessageSt, mtConfirmation, [mbYes, mbNo, mbCancel]);
    CanClose:= mr = mrNo;
    if mr = mrYes
      then btnOkClick(btnOk);
  end;
  //��������� �������� �����, ��������� ��� ������ ���������� - �������� ������ ��������
  if (not FFormNotCreatedByApplication) and (FormStyle <> fsNormal) then begin
    Settings.SaveWindowPos(Self, FormDoc);
    if (FLockInDB = fEdit) or (FLockInDB = fDelete) then
      Q.DBLock(False, FormDoc, VarToStr(id));
    //��������
    ShowWindow(Handle, SW_HIDE);
    Wh.ChildFormDestroy(Sender);
    //���� ��� �� �������� ������� �����, �� �������� ��������
    if not FrmMain.ApplicationQueryClose then
      CanClose:= False;
    Exit;
  end;
end;


procedure TFrmBasicMdi.FormCreate(Sender: TObject);
begin
  if F = nil then
    F := TFields.Create(Self);
  if myfoSizeable in MyFormOptions then
    BorderStyle := bsSizeable
  else
    BorderStyle := bsDialog;
end;

procedure TFrmBasicMdi.FormShow(Sender: TObject);
var
  x, y, i: Integer;
  b: Boolean;
  st: string;
begin
  //���� �� ���� ���������� �� ������ - �������� �� ����
  if FPreventShow then begin
    Left := mycHiddenFormLeft;
    Exit;
  end;
  FAfterFormShow:= True;
  //�������� ������ ������
  RefreshDlgPanel;
  //��������������� ������� � ��������� ����, ���� ������� ��������� � ��
  //��� ���������� ������� � oncreate � ������ ���� ������ ���������
  i := Width;
  CorrectFormSize;
  i := Width;
  //���������� ����
  if not F.IsFieldsPrepared then
    F.PrepareDefineFieldsAdd;
  if not F.IsPropControlsSet then
    F.SetPropsControls;
  SetControlEvents;
  Cth.FixTabOrder(Self);
//  FTab0Control:= Cth.GetFirstTabControl(Self);  st:=FTab0Control.name;
  if FOpt.DefFocusedControl = nil then
    FOpt.DefFocusedControl := FTab0Control;   //!!!
  if FOpt.DefFocusedControl <> nil then
    FOpt.DefFocusedControl.SetFocus;
  Cth.SetDialogCaption(Self, Mode, Self.Caption);
  SetMainInfoIcon;
  Serialize;
  FCtrlBegValuesStr := FCtrlCurrValuesStr;
  if FFormDoc <> '' then
    Settings.RestoreWindowPos(Self, FormDoc);
  Self.Top := max(Self.Top, 0);
  Verify(nil);
 // if FOpt.StatusBarMode = stbmDialog then
    RefreshStatusBar('*', '*', True); //����� ����� ��������� ��������, ����� ������ ������� ����� ������
  //��� ���������� ������������ ������������ ������������ �����
  if (myfoDialog in MyFormOptions) and (ParentForm <> nil) and ((ParentForm is TForm) or (ParentForm is TFrDBGridEh)) then
    CenteringByParent;
  if btnOk <> nil then
    btnOk.Focused;
  FAllreadyCreated := True;
end;


function TFrmBasicMdi.PrepareCreatedForm(AOwner: TObject; AFormDoc: string; ACaption: string; AMode: TDialogType;
  AID: Variant; AOptions: TMyFormOptions = [myfoModal, myfoDialog, myfoDialogButtonsB]; AAutoAlign: Boolean = True): Boolean;
//��������� ��� ������ � ������� �����, ��������� � uchet.dpr, � ��������� ���������������
//�� ��������� ���������� ���� � �������� �� ����� fMode ����� ��� ����������
//AFormDoc = * ������� ��� ������������ ����� �����
begin
  Result := False;
  FModuleId := cMainModule;
  FMyFormOptions := AOptions;
  FStatusBarHeight := -1;
  //���� ������� ������-���� ��������� �����, ������������� ������� ��� ������������ ��������� �����
  if wh.IsModalFormOpen then
    Include(FMyFormOptions, myfoModal);
  //��������, ����� �� ���� ������� ��������� �����, ���� ��� ����� ���� � AMyFormOptions �� ��������� ������
  if not TestMultiInstances(AFormDoc, MyFormOptions, AMode, AID) then
    Exit;
  //�������� ������
  //� ���� ������ �� �����������! ���������� �� ������ �����/���
  if FFormNotCreatedByApplication then
    inherited Create(Application);
  F := TFields.Create(Self);
  //������� ����� �����, ���� ���� ��������� ������, ����� ��� �� ���� �����
  if FFormNotCreatedByApplication then
    Left := mycHiddenFormLeft;
  FFormDoc := AFormDoc;
  if FFormDoc = '*' then
    FFormDoc := Self.Name;
  Caption := ACaption;
  FMode := AMode;
  FId := AID;
  if myfoDialogButtonsB in FMyFormOptions then
    FOPt.DlgPanelStyle := dpsBottomRight;
  if myfoDialogButtonsT in FMyFormOptions then
    FOPt.DlgPanelStyle := dpsTopLeft;
  if myfoShowStatusbar in FMyFormOptions then
    FOPt.StatusBarMode := stbmDialog;
  FOPt.AutoAlignControls := AAutoAlign;
  FParentControl := TWincontrol(AOwner);
  if (AOwner is TApplication) or (AOwner = nil) then
    FParentForm := FrmMain
  else if AOwner is TForm then
    FParentForm := TForm(AOwner)
  else
    FParentForm := TWincontrol(AOwner).Owner;
  ModalResult := mrNone;
  //�������� ������������� ���� � �������� (���� ��� ��������� �� ��������� �� ���������)
  if (myfoDialog in MyFormOptions) and (not (myfoEnableMaximize in MyFormOptions)) then
    if biMaximize in BorderIcons then
      Self.BorderIcons := Self.BorderIcons - [biMaximize];
  //������� ����� �����, ���� ���� ��������� ������, ����� ��� �� ���� �����
  if FFormNotCreatedByApplication then
    Left := mycHiddenFormLeft;
  if myfoSizeable in MyFormOptions then
    BorderStyle := bsSizeable
  else
    BorderStyle := bsDialog;
  Result := True;
end;




















































//initialization

//finalization
  {
  if AllocMemCount <> 0 then ShowMessage('!!!');
  if AllocMemCount <> 0 then ShowMessage(IntToStr(AllocMemCount));
  if AllocMemCount <> 0 then  MessageBox(0, pansichar('An unexpected memory leak has occurred.'+intToStr(AllocMemCount)), 'Unexpected Memory Leak', MB_OK or MB_ICONERROR or MB_TASKMODAL);
}
//begin
//end;

end.


//����� �� �������� ��������, ������������ �����, � ��������� ����� ����������� BorderStyle:=bsDialog;
//����� ��� ���� ��� ����� �������������
//���� ����� �� ����, � Prepare ����������� PreventResize:=True;
//�� ���-����� �������� �� ������ ���������, ���� � ���� ��������� �� ��������� BorderStyle:=bsSizeable;

//��� ����� ������ ����� � �������� �����, ������, ��� ������������ �������� ������ ������ �������
//    PostMessage(Self.Handle, WM_CLOSE, 0, 0);


(*

--------------------------------------------------------------------------------
--������� �����, �� ����������� � ���������.
WHCorrected.X, Y - � ���� �������� �������������� ������ ����� ��� ������, ���� ���
������� �� �������. ������������� ����� �������� �� ������ ������������ ���������.
���� �������� ��� �� pnlFrmClient, �� ������� WHCorrected:=Cth.AlignControls(pnlFrmClient, [], False),
���, ��� �� ��, ���������� Opt.AutoAlignControls
�����, ���� ����� ������ ������, �� ������ ����� ��������������� ��� � �� ��������� �� �����������,
� ������ � ��������� ������ ���������.
����� ���� ������ WHBounds, ��� ������ ��� � ������ ���������� �������, WHCorrected ��
����� ��������, ������ ����� �� ������ ������ ������� � �� ������ �������.
���� ����������� ������� �� ����������� ���� ��� ��� AlignControls, �� ��� �����
������� ������� ������� ����� � �����������!
(������� - �� ��������, �� ����������� �� ������ �������, ���� ��� ����)
���� ������� ������� ����������� -1, �� ��� �������� ������ ������.
���� �� ����� ���� ��������, � ������� ������������ �� ������� (�������) ����,
���� ��������� �� � �����������, ��������� �������� ����� � ����� ������� ��� ����
�������������� ���������.
�� ��������� �������� ����� ����� ������ �� ����� �������� ��������� CorrectFormSize

--������ ���������
������ ��������� ����� ����������, ���� ����� ������ Opt.InfoArray � � ������ ��� �������
����������� �����
(������ ���� [['txt1' {, bool}],['txt2' {,bool}],...])
���� �� ����� �������� TImage � ������ ImgInfoMain, �� � ��� ����� �������� ����� ���������
(���� ��� ���, �� �������� ��� ����� ������). ���� ����� ������ ���, �� ����� ������� �
������ ������, ��� ������� ������. ����� �������� ������� ����� �������� -
ImgInfoMAIN ������� ������ �32, imgInfomain - �24, ImgInfoMain - �� �� ������� (������)

--��������� ����
� ��������� ������������� ����������� ��� �������� ����� Caption, ���� ������ �� ��
���������� �� '~'. �������� ��� � AfterPrepare

--����������� ������
�� ��������� ����������� ������ ���������� Verify, ���������� �� ������� OnChange � OnExit
������ ��������, � ����� ��� ���������� �����, � ��� ������� ������ ��. ��� ��������� ������,
��� ������������� ���� HasError, � ����� ������������� ���������� �� ���� ��������� ErrorMessage.
����������� ��� ��������� �� �����.
��� �������������� �������� � ���� ��������, ���� ��������� ��������� VerifyAdd(Sender, onInput)
��������� ������ ���������� ������� ������ � ���������, ���� �� ����� ���������� Result := True
(������� �� ���������� �������� - ��������� if (Sender = C1) or (Sender = nil) then ...
����� ������ ��������� ���������� ��� ����� ������� ������� � ��� ������ ���������� Trcue,
���������� �� ����������� Sender)
� �����, HasError ����� ���������� � ����� �����, � � ����������� �� ����� ��������
��������� ����������� ������ �� � ������� � ����������.
� ������, ���� HasError �� ����������, �� ������ �� �������� ��� �������, � ����� �������
������������� �������� VerifyBeforeSave, ������� ����� ���������� HasError, �� ���������������
����� ��������� ErrorMessage, ���� ��������� �� ������, �� ���������� ������ �� ����� � ������ ��
��������� ��� ��, ����� ��������� ����� ������� � ���������� ���� (�� ���� ���� "*", ����� ���������
"������ �� ���������", ��� "-" - ������ �� ���������, �� ������ �� ����� (��������, ���� ��� �����
�������� ��������� � VerifyBeforeSave � ��������� ������������), ��� ���������� � "?" - ����� �������
������, � ��� Yes ������ � ��������, ����� ������ �� �����������.


*)

(*
��������:

- ������ ��� �������� �����
- ������������� ��� ��������
- ������ �� �������� �����
���� � TFrmMain.FormClose - ��������� ��� ��������
*)



(*
2025-01-08
��������� ����������� �����, �� �������� ��� ��������, ���� ���� �������� � �������� ������:
- � ������, ����� ����������� ��� ������, ��� prepare ���������� False ��� � ���������� ��� � ���, ��� ��� ��������� ��� � ��� ������.
*)



(*
������

{
�����-������ ��� ���� ��������-����

���� ����� �������� ����������� �������, �� �� ����-�����������, ������ �� ������ ����������, ��� ������� ���������� �� �����
����� ���������, ����� ������� dfm � ������ � ������� ����� ������ ���� OnCreate = nil, ���� �������������� ������� � ����� ����� � �������� inherited

����� ����� ������� ����� ���� ������, ��� �� ��������� ������� �����, � ����� � ��� ��������� class(TForm) �� class(TFrmBasicMdi)
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


--------------------------------------------------------------------------------
//������ ������ �����, ��������� � �����������, �������� ������� �� ������ � Uchet.dpr
//��� ������� � ��������� ����� �������������� ��� � � ������ � ���, �� �������� ����� ������ � ��������� ������
//������������ ��������� �����
procedure TFrmADedtItmCopyRigths.ShowDialog;
begin
  //��������� ����������
  PrepareCreatedForm(Application, '', '~����� ������������ ���', fEdit, null, {MyFormOptions=[myfoModal, myfoDialog, myfoDialogButtonsB], AutoAlign});
  F.DefineFields:=[['cmbSrc','V=1:255'], ['cmbDst','V=1:255']];
  //�������� ��� ������� OnCreate ����� ���� ����������, ������� ��� �������
  if not Self.FAllreadyCreated then Frg1.Prepare;
  Q.QLoadToDBComboBoxEh('select name, id from dv.au_user where id not in (-1, 904) order by name', [], cmbSrc, cntComboLK);
 //����� ������ ������ ���� ���������
  Self.ShowModal;
end;
//����� ���������� ��� mdichild - ������� ����� �� ShowWindow(Handle, SW_HIDE);


}


//��������� ������� �����  �� ��������� ����� �� ������������� �����
//�������� ��������� ������������� ����� ���� ������
//����������� �������� ��������������� ��� ������������� ����� ����� (�������� �� ����, � ��� ������ ������ ���� ������


������� ��������������� ������ ���� �� ���������� myfosizeable,
� ���� ���������� �� ����� ������ � ������ �������� ����
fwhbounds.y � y2



!!!!
����������� ����� ���� ������������� ��������
  if (FWHCorrected.X <> 0) or (j <> 0) then begin



