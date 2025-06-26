unit F_MDIDlg1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, Mask, uData, uForms, uDBOra, uString, uMessages,
  V_MDI
  ;

type
  TForm_MDIDlg1 = class(TForm_MDI)
    Bt_Cancel: TBitBtn;
    Bt_OK: TBitBtn;
    procedure Bt_OKClick(Sender: TObject);
    procedure Bt_CancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  protected
    { Private declarations }
//    InLoad: Boolean;
    Ok: Boolean;
    ControlsVerification: TVarDynArray2;
    procedure Verify(Sender: TObject; onInput: Boolean = False);
    function  VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean; virtual;
    procedure ControlOnChange(Sender: TObject);
    procedure ControlOnExit(Sender: TObject);
    procedure ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean);
    function  Load: Boolean; virtual;
    function  Save: Boolean; virtual;
    function  Prepare: Boolean; override;
    function  AfterPrepare: Boolean; virtual;
    procedure BtOKClick; virtual;
  public
    { Public declarations }
    constructor ShowDialog(AOwner: TComponent; aFormDoc: string; aMode: TDialogType; aID: Variant; aAddParam: Variant); virtual;
  end;

var
  Form_MDIDlg1: TForm_MDIDlg1;

implementation

{$R *.dfm}

uses
  uWindows
  ;

procedure TForm_MDIDlg1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
{  DBLock(False, FormDoc, VarToStr(id));
  Action := caFree;
  try
    Wh.CloseMDIForm(Self);
  except
  end;}
end;

//������� ��������� ������ ��������
procedure TForm_MDIDlg1.ControlOnChange(Sender: TObject);
begin
  //����� ���� � ��������� ��������
  if InPrepare then Exit;
  //��������, ������� ��� � ���� ������� ��������
  Verify(Sender, True);
end;

//���� ������ � ��������
procedure TForm_MDIDlg1.ControlOnExit(Sender: TObject);
begin
  //����� ���� � ��������� ��������
  if InPrepare then Exit;
  //��������
  Verify(Sender);
end;

procedure TForm_MDIDlg1.Bt_CancelClick(Sender: TObject);
begin
  Close;
end;

procedure TForm_MDIDlg1.BtOKClick;
begin
  if (Mode = fView) then begin Close; Exit; end;
  Verify(nil);
  if not Bt_Ok.Enabled then Exit;
  if not Save then Exit;
  RefreshParentForm;
  Close;
end;

procedure TForm_MDIDlg1.Bt_OKClick(Sender: TObject);
begin
  BtOKClick;
end;

procedure TForm_MDIDlg1.ControlCheckDrawRequiredState(Sender: TObject;
  var DrawState: Boolean);
begin
  Cth.VerifyVisualise(Self);
end;

//�������� ���������6���� ������
//���������� ������� ��� ��������, ��� ��� - ��������� ���
//� ������� ��� �������� ��� ����� ������ � �������� (� ������� onChange)
procedure TForm_MDIDlg1.Verify(Sender: TObject; onInput: Boolean = False);
var
  i,j,s:Integer;
  c: TControl;
  OkAdd: Variant;
begin
  //� ��������� � �������� ������ ��
  if (Mode = fView) or (Mode = fDelete)
    then begin
      Ok:=True;
      Bt_Ok.enabled := Ok;
      Exit;
    end;
  if Sender = nil
    //�������� ��� DbEh
    then begin
//      OkAdd:= VerifyAdd(Sender, onInput);
      Cth.VerifyAllDbEhControls(Self)
    end
    //�������� �������
    else begin
      Cth.VerifyControl(TControl(Sender), onInput);
//      OkAdd:= VerifyAdd(Sender, onInput);
    end;
  //�������������� �������� ��� ������ �����
  OkAdd:=VerifyAdd(Sender, onInput);
  //������� ������ �������� � �������������
  Ok:=Cth.VerifyVisualise(Self);
  Ok:=Ok and OkAdd;
//  if Ok then Ok:= VerifyAdd(Sender, onInput);
  //������ ������ ��
  Bt_Ok.Enabled := Ok;
end;

//�������������� ��������, ���������� ��� ������ �������� � ������ �� ����������� ��� Verify
//���� ������ False �� ����� �������� �� �������, ���� True �� �� ����� �� ����������� ��������� ��������
//������ ����� ��������� ��� ������� ������ ��� ���������� �� ���������� ������ ��������, ����� ������� ��� ��� ������
//Cth.SetErrorMarker
function TForm_MDIDlg1.VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean;
begin
  Result:=True;
end;


function TForm_MDIDlg1.Load(): Boolean;
begin
  Result:=True;
end;

function TForm_MDIDlg1.Save(): Boolean;
begin
  Result:=True;
end;

function TForm_MDIDlg1.Prepare: Boolean;
begin
  Result:=False;
  if FormDBLock = fNone then Exit;
{
    if DBLock(True, FormDoc, VarToStr(id))[0] <> True
      then Exit;}
//  SetControls;
  ModalResult:= mrCancel;
  if not Load then Exit;
   //������� onCahange �  onExit ��� ���� dbeh ���������
  Cth.SetControlsOnChange(Self, ControlOnChange);
  Cth.SetControlsOnExit(Self, ControlOnExit);
  Cth.SetControlsOnCheckDrawRequired(Self, ControlCheckDrawRequiredState);
//  Cth.DlgSetControlsEnabled(Self, Mode, []);
  //��������� �������� ���������
{  if Length(ControlsVerification)=2 then
    Cth.SetControlsVerification(
      ControlsVerification[0],
      ControlsVerification[1]
    );}
  Cth.SetDialogForm(Self, Mode, Caption);
  if not AfterPrepare then Exit;
  Verify(nil);
  Result:=True;
end;

function TForm_MDIDlg1.AfterPrepare: Boolean;
begin
  Result:=True;
end;

constructor TForm_MDIDlg1.ShowDialog(AOwner: TComponent; aFormDoc: string; aMode: TDialogType; aID: Variant; aAddParam: Variant);
begin
  inherited Create(AOwner, aFormDoc, [myfoDialog], aMode, aID, aAddParam);
end;


end.
