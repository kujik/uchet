unit F_MdiDialogTemplate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, Mask, Vcl.ExtCtrls, Vcl.ComCtrls,
  uData, uForms, uDBOra, uString, uMessages, V_MDI, uLabelColors;

type
  TForm_MdiDialogTemplate = class(TForm_MDI)
    pnl_Bottom: TPanel;
    Bt_OK: TBitBtn;
    Bt_Cancel: TBitBtn;
    Img_Info: TImage;
    chb_NoClose: TCheckBox;
    bvl1: TBevel;
    procedure ControlOnChange(Sender: TObject); virtual;
    procedure ControlOnExit(Sender: TObject); virtual;
    procedure ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean); virtual;
    procedure Bt_OKClick(Sender: TObject); virtual;
    procedure Bt_CancelClick(Sender: TObject); virtual;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    //������������ ���� ���������, ��� ��������, ���� �� ���������
    //������ ����������� ��� ������ �� �����, ���� ��� �� ���������� � ���������� ������,
    //�� ��� ��������� ��������, ��� ����������� Serialize ��� ��������� ����� ������
    CtrlBegValuesStr, CtrlCurrValuesStr: string;
  protected
    Fields: string;                         //������ ����� ����� ;
    FieldsSave: string;                     //������ ����� ��� �������� ������ ����� ;. ���� �� �������� �� ��������� � Fields
                                            //���� � ������� ���� ���������� �� ��� ��� �� ��� �� ����� ���� ��������
                                            //���� ���� ���� ��������� �� ������, �� � ��� ������� ��������� 0
    FieldsArr: TVarDynArray;                //������ ���� ����� (��� ������� � �������������). ��������� �������������.
    Ctrls: array of TControl;               //��������, ������������ ������ �����, ����� ���� nil
                                            //������������� ��������� �� ��������� ����� ��������
    CtrlNames: TVarDynArray;
    CtrlValues: TVarDynArray;               //������ ��������; ����������� �� �� ��� ������ �����,
                                            //����������� �� ��������� ��� ������� ������
                                            //��� �����, ��� ������� �������� �� ������� � �� ������, ��������� �������� ������,
                                            //��� ������������� ����� ������� ������ �������
    CtrlValuesDefault: TVarDynArray;        //������ ��������� �������� ��������� (��� ����� ��� ���������� ��������) (� ������ fAdd)
    CtrlVerifications: TVarDynArray;        //������ ������ �������� �������� ���������
    View: string;                           //�������/��� �� ������� ��������� ������
    Table: string;                          //�������, � ������� ���������� ������
    Sequence: string;                       //���������, ���� �����
    Info, InfoView, InfoDelete: string;     //���������, ��� ��������� � �������� ���������� (������ ������),
                                            //��� ��������� ������� Info. ���� � ������� �� �� ������, �� ������ �� �����
    NoCloseIfAdd: Boolean;                  //������������ ����� �� ��������� ���� ��� ������ ����������
    NoSerializeCtrls: Boolean;              //���� ������, �� ������ ���������� '' ��� ��������

    Ok: Boolean;                            //������ ��������

    InChange: Boolean;                      //��������� � ������� ControlOnChange (��������������� � ��������)
    InChControlName: string;                //�������� �������� �������� � ������� ���������
    InChControlValue: Variant;              //�������� �������� �������� � ������� ���������

    IdAfterInsert: Variant;                 //� ��������� Save ���� ������������ ����, ���������� ��� ������� ������ (�����, ���� ��������� ���. �������� � ������� ����� ����������� ������)

    function Prepare: Boolean; override;

    //��������� �������� �������� ������
    //��������� ������ �� ������� ������� ��������
    //���� Sender = nil �� ��������� ��� ��������, ����� ����������
    //onInput ��������� ��� �������� ������������ � ������ ��������� �������� ��������
    //���� ���� �� ���� ������� �� �������, ������������ ��� ���� ������ Error
    //����� �������, ��� ����������� �������� ������ ���� ���� Eh
    //����� ������ �� ������������ �� ������ ���������� �������� Eh - ���������,
    //���� �� �� True, �� ������ �� ����������
    //�������� ����� ���������� � �������� ��������� � ������ ������ ��� ��������, � ������ ��������
    //��� ������ ���� � ��� ������� ��
    procedure Verify(Sender: TObject; onInput: Boolean = False); virtual;
    //�������������� ��������, ������ ���������� � �������� ����� ���� �� ��������
    //������ ��������������� ������ Error � ��������� �� ����� ������� ����������, ���� ��� �����
    function VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean; virtual;
    //��������� �������������� �������� ����� �������, ���� Verify ������� �� = True (� ����� ������ �� ����������)
    //������ ��������������� ��, ���� ���-�� �� � �������
    //���� ������ � Result True, �� ����� ������ ��������� "������ �� ���������!", �����
    //���� ����� ������ ���������
    //����� �������������� ��� �������������� �������� ��� ������� ���������� ����� �������� ������
    //���������� ����� � ��� ��������, �� �� ��� ���������
    function VerifyBeforeSave: Boolean; virtual;
    //��������� ������ CtrlValues, ����� �� Fields
    function Load(): Boolean; virtual;
    //��������� �������
    //���� �� ����������� ��� ���������
    //�� ����� ������� ������ � ������� �������� �� ������� Ctrls,
    //� ������� ������ ����� ����������� �� ��������� ��� ��������������� ����� ���������
    function Save: Boolean; virtual;
    function LoadComboBoxes: Boolean; virtual;
    //������������� �������������� ��� ��� (Editable) ��� �������� �� ������� AConrols;
    //���� ��������� ������, �� ��� �������� ����� (������ � ������� ������� ������ ����������� �� ���� ���������)
    procedure SetControlsEditable(AConrols: array of TControl; Editable: Boolean = True);
    //������������� �������� ��������� ����� (����, ����� ����� ������� �����)
    //���� ������ NoSerializeCtrls, �� ������ ���������� '' ��� ��������
    procedure Serialize; virtual;
    //������ ��� �����������, ���� ������� ���������:
    ///����� ��������������
    //��� ������� �� �����
    //��� ������ �������� (����������� ��� ����� ������)
    //���� ��������� �� �����, ������� � ������� SetStatusBar('','',False);
    procedure SetStatusBarText(VisibleStatusBar: Boolean; Text: string); virtual;
  public
    { Public declarations }
  end;

var
  Form_MdiDialogTemplate: TForm_MdiDialogTemplate;

implementation

  Uses
    uErrors
    ;

{$R *.dfm}

procedure TForm_MdiDialogTemplate.Bt_CancelClick(Sender: TObject);
begin
  inherited;
  Close;
end;

procedure TForm_MdiDialogTemplate.Bt_OKClick(Sender: TObject);
begin
  if (Mode = fView) then begin
    Close;
    Exit;
  end;
  if Mode <> fDelete then begin
    if not Ok then
      Exit;
  end;
  if Mode <> fView then begin
    if VerifyBeforeSave then
      MyWarningMessage('������ �� ���������!');
    if not Ok then begin
      Ok := True;  //���� �� �������, �� � ������ ������, ���� � VerifyBeforeSave ok ��������� � Folse, ��� �� ������ �������� ������ ����� �������� �����������
      Exit;
    end;
  end;
  if not Save then
    Exit;
  RefreshParentForm;
  if DefFocusedControl <> nil then
    DefFocusedControl.SetFocus;
  if (not chb_NoClose.Visible) or (not chb_NoClose.Checked) then begin
    Close;
  end;
end;

function TForm_MdiDialogTemplate.VerifyBeforeSave: Boolean;
//��������� �������������� �������� ����� �������, ���� Verify ������� �� = True
//������ ��������������� ��, ���� ���-�� �� � �������: ���� ������ � Result True,
//�� ����� ������ ��������� "������ �� ���������!"
begin
  Result := False;
end;

procedure TForm_MdiDialogTemplate.SetStatusBarText(VisibleStatusBar: Boolean; Text: string);
var
  st: string;
begin
  if not Ok then
    st := '  $0000FF ������������ ������!  '
  else if CtrlCurrValuesStr <> CtrlBegValuesStr then
    st := ' $FF00FF ������ ' + S.Iif(Mode = fAdd, '�������.', '��������.')
  else
    st := '';
  if pnl_StatusBar.Visible then begin
    SetStatusBar(Cth.FModeToCaption(Mode), st, True);
  end;
end;

procedure TForm_MdiDialogTemplate.SetControlsEditable(AConrols: array of TControl; Editable: Boolean = True);
var
  i, j: Integer;
  c: TControl;
  va: TVarDynArray;
begin
  va := [];
  for i := 0 to High(AConrols) do
    va := va + [AConrols[i].Name];
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TControl then begin
      c := TControl(Components[i]);
      if A.PosInArray(c.Name, ['pnl_statusbar', 'lbl_StatusBar_Left', 'lbl_StatusBar_Right', 'pnl_bottom', 'bt_ok', 'bt_cancel', 'chb_NoClose'], True) >= 0 then
        Continue;
      if (Length(AConrols) = 0) or (A.PosInArray(c.Name, va, True) >= 0) then begin
        Cth.SetControlNoTEditable(c, not Editable, False, True);
        if c is TCustomdbeditEh then
          Cth.SetEhControlEditButtonState(c, Editable, Editable);
      end;
    end;
end;

function TForm_MdiDialogTemplate.Load(): Boolean;
//�������� ������
//�� ��� �������������� ���������� ����������, ����� � ���������� CtrlValues
//��������� ���� �� ������ �� �� ���, ���� �� ��� ������� ������, ����� ����������� � �������� ����������� ��������� ������
begin
  CtrlValues := Q.QLoadToVarDynArrayOneRow(Q.QSIUDSql('s', View, Fields), [id]);
  Result := True;
end;

function TForm_MdiDialogTemplate.Save(): Boolean;
//���������� ������
//���������� ������ �������� ����������
//����� ���� ���������, � ��� ��� ������ inherited
var
  ChildHandled: Boolean;
  i, res: Integer;
  FieldsSave2, CtrlValues2: TVarDynArray;
  FieldsSaveNew: string;
begin
  Result := False;
  try
    for i := 0 to High(Ctrls) do
      if Ctrls[i] <> nil then
        CtrlValues[i] := S.NullIfEmpty(Cth.GetControlValue(Ctrls[i]));
  except
    on E: Exception do begin
      Application.ShowException(E);
      Exit;
    end;
  end;
  CtrlValues2:= Copy(CtrlValues);
  FieldsSave2:= A.Explode(FieldsSave, ';');
  for i:= high(FieldsSave2) downto 0 do
    if FieldsSave2[i] = '0' then begin
      Delete(FieldsSave2, i, 1);
      Delete(CtrlValues2, i, 1);
    end;
  FieldsSaveNew:= A.Implode(FieldsSave2, ';');
  res := Q.QIUD(Q.QFModeToIUD(Mode), Table, Sequence, FieldsSaveNew, CtrlValues2);
  IdAfterInsert:= res;
  Result := res <> -1;
end;

function TForm_MdiDialogTemplate.LoadComboBoxes: Boolean;
//����������� ��� �������� �������������� ������, �������� �����������
//���������� ����� �������� �������� ������
begin
  Result := True;
end;

procedure TForm_MdiDialogTemplate.Serialize;
//
begin
  if NoSerializeCtrls then begin
    CtrlCurrValuesStr := '';
    Exit;
  end;
  CtrlCurrValuesStr := Cth.SerializeControlValuesArr2(Cth.GetControlValuesArr2(Self, nil, [], ['chb_NoClose']))
end;

procedure TForm_MdiDialogTemplate.ControlOnChange(Sender: TObject);
//������� ��������� ������ ��������
begin
  //����� ���� � ��������� ��������
  if InPrepare then
    Exit;
  //��������, ������� ��� � ���� ������� ��������
  Serialize;
  Verify(Sender, True);
end;

//���� ������ � ��������
procedure TForm_MdiDialogTemplate.ControlOnExit(Sender: TObject);
begin
  //����� ���� � ��������� ��������
  if InPrepare then
    Exit;
  //��������
  Verify(Sender);
end;

procedure TForm_MdiDialogTemplate.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil(lbl_StatusBar_Left);
  FreeAndNil(lbl_StatusBar_Right);
  inherited;
end;

procedure TForm_MdiDialogTemplate.FormShow(Sender: TObject);
begin
  inherited;
  pnl_Bottom.Width := Self.ClientWidth;
  Bt_Cancel.Left := pnl_Bottom.Width - Bt_Cancel.Width - 5;
  Bt_Ok.Left := pnl_Bottom.Width - Bt_Cancel.Width - 5 - Bt_Ok.Width - 5;
  Bt_Cancel.Top := 2;
  Bt_Ok.Top := 2;
  Img_Info.Left := 5;
  Img_Info.Top := 2;
  //���������� �������� ����
  //���� ����� ���������� ������, �� ��� ������ �� Prepare ���������� ����������� ������� ������, ��� ������ �������������� ��� ���������
  //� ��� ������� ������ ��� ��������� �����
  SetStatusBarText(True, '');
end;

{
procedure TForm_MdiDialogTemplate.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  Settings.SaveWindowPos(Self, FormDoc);
end;}

procedure TForm_MdiDialogTemplate.ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean);
begin
  Cth.VerifyVisualise(Self);
end;

function TForm_MdiDialogTemplate.VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean;
begin
  Result := True;
end;

procedure TForm_MdiDialogTemplate.Verify(Sender: TObject; onInput: Boolean = False);
//�������� ������������ ������
//���������� ������� ��� ��������, ��� ��� - ��������� ���
//� ������� ��� �������� ��� ����� ������ � �������� (� ������� onChange)
var
  i, j, s: Integer;
  c: TControl;
  ok1: Boolean;
begin
  //� ��������� � �������� ������ ��
  if (Mode = fView) or (Mode = fDelete) then begin
    Ok := True;
    Bt_Ok.Enabled := Ok;
    Exit;
  end;
  if Sender = nil then //�������� ��� DbEh
    Cth.VerifyAllDbEhControls(Self)
  else //�������� �������
    Cth.VerifyControl(TControl(Sender), onInput);
  //�������������� �������� (��� ����, ��� �� ����������� ��������� �������� � �������)
  //������ �������� SetErrorMarker ��� ��������� �� ����� ������� ����������, �� ������������ �������� �������� � �������
  VerifyAdd(Sender, onInput);
  //������� ������ �������� � �������������
  Ok := Cth.VerifyVisualise(Self);
  //������ ������ ��
  Bt_Ok.Enabled := Ok;
  if not InPrepare then
    SetStatusBarText(True, '');
end;

function TForm_MdiDialogTemplate.Prepare: Boolean;
var
  i, j: Integer;
  c: TControl;
begin
  Result := False;
  //�������� ����������, ������ ���� ������ ����� (��� ������� �������������� ����� � ��������, ��� �������� - �����)
  if FormDbLock = fNone then
    Exit;
  //����� ������� ��������� ���� ������, ��������� ��������, ��������� ��������, ��������� ���������� � �������������� ������.
  //���� ��� ������ �� ��������� �� �� ��� ��� ������
  if Length(FieldsSave) = 0 then
    FieldsSave := Fields;
  if Table = '' then
    Table := View;
  //�������� ������ ����� ��� ������������� � ��������
  FieldsArr := A.ExplodeV(Fields, ';');
  //�������� ������ ���������, ���� �� �� ��� ������ ����� �������
  if Length(Ctrls) = 0 then begin
    SetLength(Ctrls, Length(FieldsArr));
    for i := 0 to High(FieldsArr) do
      Ctrls[i] := nil;
  end;
  //�������� ������ ��������� (������� �� ������ nil), ����������, ����������������� �������� ����
  for i := 0 to High(FieldsArr) do begin
    FieldsArr[i] := s.GetDBFieldNameFromSt(FieldsArr[i]);
    if (Ctrls[i] = nil) then
      Ctrls[i] := Cth.FindControlByFieldName(Self, FieldsArr[i]);
  end;
  CtrlNames := [];
  for i := 0 to High(Ctrls) do
    if (Ctrls[i] <> nil) then
      CtrlNames := CtrlNames + [Ctrls[i].Name];
  //��������� ������ �� ��, ���, ���� ����� ����������, ������� ��������� ��������


  if Mode = fAdd then
    CtrlValues := CtrlValuesDefault
  else    //������ ������:     CtrlValues := Q.QLoadToVarDynArrayOneRow(Q.QSIUDSql('s', View, Fields), [id]);
    Load;
  //���� ������ �� �������, ������� ��������� � ������
  if Length(CtrlValues) = 0 then begin
    MsgRecordIsDeleted;
    Exit;
  end;

  //� ����� ������� (� CtrlNames �� ����� ��� ����� ��, ��� ������� ��� ���������)
  i:=Length(FieldsArr);
  if (i <> Length(Ctrls)){or(i <> Length(CtrlNames))}or(i <> Length(CtrlValues))or(i <> Length(CtrlValuesDefault))  then begin
    raise Exception.Create('TForm_MdiDialogTemplate.Prepare - �� ��������� ����� �������� ������� ����������');
    Exit;
  end;

  //�������� ���������� � ������� ������ ��������� ��������
  if not LoadComboBoxes then
    Exit;
  try
  for i := 0 to High(Ctrls) do
    Cth.SetControlValue(Ctrls[i], CtrlValues[i]);
  except
    on E: Exception do begin
      Errors.SetParam('', '��� ��������� �������� '+ InttoStr(i) + ' - *');
      Application.ShowException(E);
      Exit;
    end;
  end;
  //��������� �������� ��������� ��������� ��� ���
  Cth.SetControlsVerification(Ctrls, CtrlVerifications);
   //������� onCahange �  onExit ��� ���� dbeh ���������  (True - + onclick ��� chbeh)
  Cth.SetControlsOnChange(Self, ControlOnChange, True);
  Cth.SetControlsOnExit(Self, ControlOnExit);
  Cth.SetControlsOnCheckDrawRequired(Self, ControlCheckDrawRequiredState);
  //��������� ����� � ������ � ����������� �� ������
  Cth.SetDialogForm(Self, Mode, Caption);
  //����������� ���������, � ����������� �� ������, ����� ��� ������/��������� - ������ �������
  SetControlsEditable([], Mode in [fEdit, fCopy, fAdd]);
  //Cth.DlgSetControlsEnabled(Self, Mode, [], []);
  Cth.SetInfoIcon(Img_Info, s.Decode([Mode, fView, InfoView, fDelete, InfoDelete, Info]), 20);
  //�� ��������, ������ ������������� �� �������� ����
  {Img_Info.Align:=alNone;
  Img_Info.Top:=5;
  Img_Info.Left:=3;}
  Serialize;
  CtrlBegValuesStr:= CtrlCurrValuesStr;
  SetStatusBar('', '', True);
  Verify(nil);
  pnl_Bottom.Align := alNone;
//  pnl_Bottom.Top:=Self.ClientHeight - StatusBar.Height - pnl_Bottom.Height;
  pnl_Bottom.Align := alBottom;
  chb_NoClose.Visible := NoCloseIfAdd and (Mode in [fAdd, fCopy]);
  Result := True;
end;

end.

