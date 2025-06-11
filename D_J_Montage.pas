unit D_J_Montage;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, Mask, uData, uForms, uDBOra, uString, uMessages, V_MDI,
  Vcl.ExtCtrls, Vcl.ComCtrls, DateUtils, Types, Math, IOUtils;

type
  TDlg_J_Montage = class(TForm_MDI)
    Bt_OK: TBitBtn;
    Bt_Cancel: TBitBtn;
    De_Beg: TDBDateTimeEditEh;
    De_End: TDBDateTimeEditEh;
    Chb_RC: TDBCheckBoxEh;
    Chb_RI: TDBCheckBoxEh;
    M_Comm: TDBMemoEh;
    Bt_Act: TBitBtn;
    Lb_Act: TLabel;
    Bt_Photos: TBitBtn;
    Lb_Photos: TLabel;
    Img_Info: TImage;
    OpenDialog1: TOpenDialog;
    Lb_Caption: TLabel;
    procedure ControlOnChange(Sender: TObject);
    procedure ControlOnExit(Sender: TObject);
    procedure ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean);
    procedure Bt_OKClick(Sender: TObject);
    procedure Bt_CancelClick(Sender: TObject);
    procedure Bt_ActClick(Sender: TObject);
    procedure Bt_PhotosClick(Sender: TObject);
    procedure Bt_ActExit(Sender: TObject);
    procedure Bt_PhotosExit(Sender: TObject);
  private
    { Private declarations }
    Fields: string;
    BegValues: TVarDynArray;
    Ctrls: Array of TControl;
    CtrlNames: TVarDynArray;
    CtrlValues: TVarDynArray;
    CtrlVerifications: TVarDynArray;
    DtEditMin: TDateTime;
    IsFilesLoaded: Boolean;
    Ok: Boolean;
    OldPath: string;
    OrderIsEnding: Boolean;
    function  Prepare: Boolean; override;
    procedure AfterPrepare; override;
    procedure Verify(Sender: TObject; onInput: Boolean = False);
    procedure OpenDir(Mode: Boolean);
    function  IfFilesLoaded: Boolean;
  public
    { Public declarations }
  end;

var
  Dlg_J_Montage: TDlg_J_Montage;

implementation

uses
  StrUtils,
  uSettings,
  uTasks,
  uSys
  ;

  {$R *.dfm}

//������� ��������� ������ ��������
procedure TDlg_J_Montage.ControlOnChange(Sender: TObject);
begin
  //����� ���� � ��������� ��������
  if InPrepare then Exit;
  if Sender = De_Beg then begin
    //��� ��������� ��������� ����, �������� �������� �������� - �� ������ ���� ����� ��������� � ����� ��� ���� ��������������
    if not Cth.DteValueIsDate(De_Beg)
      then Cth.SetControlsVerification([De_End], [S.DateTimeToIntStr(DtEditMin) + ':' + S.DateTimeToIntStr(IncYear(Date, -30))])
      else Cth.SetControlsVerification([De_End], [S.DateTimeToIntStr(Max(De_Beg.Value, DtEditMin)) + ':' + S.DateTimeToIntStr(Date)]); // +':-' - ��� ���� �����������
//      else Cth.SetControlsVerification([De_End], [S.DateTimeToIntStr(De_Beg.Value) +':' + S.DateTimeToIntStr(Date)+':-']);
    Verify(De_End);
  end;
  //��������, ������� ��� � ���� ������� ��������
  Verify(Sender, True);
end;

//���� ������ � ��������
procedure TDlg_J_Montage.ControlOnExit(Sender: TObject);
begin
  //����� ���� � ��������� ��������
  if InPrepare then Exit;
  //��������
  Verify(Sender);
end;

procedure TDlg_J_Montage.Bt_ActClick(Sender: TObject);
begin
  OpenDir(True);
end;

procedure TDlg_J_Montage.Bt_ActExit(Sender: TObject);
begin
  inherited;
  IfFilesLoaded;
end;

procedure TDlg_J_Montage.Bt_PhotosClick(Sender: TObject);
begin
  inherited;
  OpenDir(False);
end;


procedure TDlg_J_Montage.Bt_PhotosExit(Sender: TObject);
begin
  inherited;
  IfFilesLoaded;
end;

procedure TDlg_J_Montage.Bt_CancelClick(Sender: TObject);
begin
  inherited;
  Close;
end;

procedure TDlg_J_Montage.Bt_OKClick(Sender: TObject);
//���� �� �� - �������� ������
var
  NewID: Integer;
  res, i: Integer;
  v: Variant;
  va: TVarDynArray;
  TaskDir: string;
begin
  if (Mode = fView)
    then begin Close; Exit; end;
  if Mode = fDelete then begin
    Q.QExecSql('delete from or_montage where id = :id$i', [CtrlValues[0]]);
    Close;
  end;
  if not Ok then Exit;
  if not IsFilesLoaded then Exit;
  //������� �������� ���������
  CtrlValues:=[];
  for i:=0 to High(Ctrls) do begin
    if Ctrls[i] = nil
      then v:=BegValues[i]
      else v:=S.NullIfEmpty(Cth.GetControlValue(Ctrls[i]));
    CtrlValues:=CtrlValues + [v];
  end;
  //������� ��� ������� ������
  res:= Q.QIUD(
    S.IIFStr(Q.QSelectOneRow('select count(*) from or_montage where id = :id$i', [CtrlValues[0]])[0]= 0, 'i', 'u')[1],
    'or_montage', 'id', Fields, VarArrayOf(CtrlValues)
    );
  if res = -1 then Exit;
  if (S.NSt(BegValues[6]) <> '')and(BegValues[6] <> OldPath) then begin
    va:=Q.QSelectoneRow('select path, in_archive, year from orders where id = :id$i', [CtrlValues[0]]);
    if va[0] <> null then
      TaskDir:= Tasks.CreateTaskRoot(mytskopLinkMontage, [
        ['directory', va[0]],
        ['in_archive', S.NSt(va[1])],
        ['year', va[2]],
        ['montage', BegValues[6]]
        ],
        False,
        True
      );
  end;
  RefreshParentForm;
  Close;
end;

procedure TDlg_J_Montage.ControlCheckDrawRequiredState(Sender: TObject;
  var DrawState: Boolean);
begin
  Cth.VerifyVisualise(Self);
end;

//�������� ���������6���� ������
//���������� ������� ��� ��������, ��� ��� - ��������� ���
//� ������� ��� �������� ��� ����� ������ � �������� (� ������� onChange)
procedure TDlg_J_Montage.Verify(Sender: TObject; onInput: Boolean = False);
var
  i,j,s:Integer;
  c: TControl;
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
    then Cth.VerifyAllDbEhControls(Self)
    //�������� �������
    else Cth.VerifyControl(TControl(Sender), onInput);
  //������� ������ �������� � �������������
  Ok:=Cth.VerifyVisualise(Self);
  //������ ������ ��
  Bt_Ok.Enabled := Ok;
end;

procedure TDlg_J_Montage.AfterPrepare;
//���������� ����� �������� ��������� ������� Prepare
begin
  //�������� ������ �������� ������� ����
  ControlOnChange(De_Beg);
end;


function TDlg_J_Montage.Prepare: Boolean;
var
  Info: string;
  i, j: Integer;
begin
  Result:= False;
  //�������� ����������, ������ ���� ������ ����� (��� ������� �������������� ����� � ��������, ��� �������� - �����)
  if FormDbLock = fNone then Exit;
  DtEditMin:=VarToDateTime(AddParam); //IncDay(Date, -30);
  BorderStyle:=bsDialog; PreventResize:=True;
  //MinWidth:=700;
  //MinHeight:=320;
  //��� ���� �������� ������� � ��
  Fields:='id$i;dt_beg$d;dt_end$d;rep_customer$i;rep_installer$i;comm$s;path$s';
  //�������������� �� ��������, ����� ������ - id
  Ctrls:=[nil, De_Beg, De_End, Chb_RC, Chb_RI, M_Comm, nil];
  //��� ���������� ������������� �������� �����, ��� ������ ������� �� ������� � ����
  BegValues:=Q.QSelectOneRow(Q.QSIUDSql('s', 'or_montage', Fields), [ID]);
  OrderIsEnding:=Q.QSelectOneRow('select dt_end from v_orders where id = :id$i', [ID])[0] <> null;
  Lb_Caption.Caption:=S.NSt(Q.QSelectOneRow('select ornum from v_orders where id = :id$i', [ID])[0]);
  if BegValues[0] = null
    then BegValues:=VarArrayOf([ID, Date, null, 0, 0, '', null]);
  OldPath:=S.NSt(BegValues[6]);
  if BegValues[6] = null
    then BegValues[6]:= Module.GetPathNewDir;
  //��������� �������� ���������
  for i:=0 to High(Ctrls) do
    if Ctrls[i] <> nil then Cth.SetControlValue(Ctrls[i], BegValues[i]);
   //������� onCahange �  onExit ��� ���� dbeh ���������
  Cth.SetControlsOnChange(Self, ControlOnChange);
  Cth.SetControlsOnExit(Self, ControlOnExit);
  Cth.SetControlsOnCheckDrawRequired(Self, ControlCheckDrawRequiredState);
  //����������� ���������, � ����������� �� ������, ����� ��� ������/��������� - ������ �������
  Cth.DlgSetControlsEnabled(Self, Mode, [], []);
  De_Beg.Enabled:=not OrderIsEnding and De_Beg.Enabled and (not Cth.DteValueIsDate(De_Beg) or (De_Beg.Value >= DtEditMin));
  De_End.Enabled:=not OrderIsEnding and De_End.Enabled and (not Cth.DteValueIsDate(De_End) or (De_End.Value >= DtEditMin));
  //��������� ����������� ���������
  CtrlVerifications:=['', S.IIFStr(De_Beg.Enabled, S.DateTimeToIntStr(DtEditMin) +':' + S.DateTimeToIntStr(Date), ''),':'+S.DateTimeToIntStr(Date)+':-','','','0:4000:0:T',''];
  //��������� �������� ��������� ��������� ��� ���
  Cth.SetControlsVerification(Ctrls, CtrlVerifications);
  //�������� ������� ������ ���� � ����������
  IfFilesLoaded;
  //�������������� ��������
  Verify(nil);
  //����
   Cth.SetInfoIcon(Img_Info,Cth.SetInfoIconText(Self, [
   ['������� ������ �� ������� ������.'#13#10+
    '��������� ���� �����������. ���� ����� ��������, ������� ���� ���������� (�� ����� ��������� � �� ����� �������).'#13#10+
    '���� ���� ��������� ��������� ��� �����������, ��������� ��������������� �������.'#13#10+
    '��� �������������, ������� ������������ �����������.'#13#10+
    '����������� ���������� ��� ����� � ���������. ��� ����� �������� �����,'#13#10+
    '����� �� ������, � ���������� ���� �����.'#13#10+
    ''#13#10
   ,Mode <> fView]
   ]), 20);

  //����� ����� �� �������� (�������������� ��� ����������� �� ���������� ������)
  //� ������-���� ������ BorderStyle:=bsDialog, � ��� ����������� ������������ ������ ��� ����� �� bsSizeable

  BorderStyle:=bsSizeable;
  //StatusBar.Visible:=False;

  //��������� ����� � ������ � ����������� �� ������
  Cth.SetDialogForm(Self, Mode, '������ �� ������� ������');
  //������ ����� ���� � ����
  Cth.SetBtn(Bt_Act, mybtFolder, True, '������� ����� ����');
  Bt_Act.Enabled:=True;
  Cth.SetBtn(Bt_Photos, mybtFolder, True, '������� ����� ����������');
  Bt_Photos.Enabled:=True;

  BorderStyle:=bsDialog;

  Result:= True;
end;


procedure TDlg_J_Montage.OpenDir(Mode: Boolean);
var
  spath, zpath: string;
  i: Integer;
begin
  try
    spath:=Module.GetPath_OrMontage_Act(BegValues[6]);
    zpath:=Module.GetPath_OrMontage_Photos(BegValues[6]);
    ForceDirectories(spath);
    ForceDirectories(zpath);
  finally
    Sys.ExecFile(S.IIFStr(Mode, spath, zpath));
    IfFilesLoaded;
  end;
end;

function TDlg_J_Montage.IfFilesLoaded: Boolean;
var
  a: TStringDynArray;
  b1, b2: Boolean;
begin
  Result:= True;  b1:=True; b2:=True;
  //a:=GetFileListInDirectory(Module.GetPath_OrMontage_Act(BegValues[6]));
  a:=[];
  if DirectoryExists(Module.GetPath_OrMontage_Act(BegValues[6]))
    then a:=TDirectory.GetFiles(Module.GetPath_OrMontage_Act(BegValues[6]), '*', TSearchOption.soAllDirectories);
  if Length(a) = 0
    then begin b1:=False; Lb_Act.Caption:='��� �� ��������!'; end
    else Lb_Act.Caption:='��� ��������';
  a:=[];
  if DirectoryExists(Module.GetPath_OrMontage_Photos(BegValues[6]))
    then a:=TDirectory.GetFiles(Module.GetPath_OrMontage_Photos(BegValues[6]), '*', TSearchOption.soAllDirectories);
  if Length(a) = 0
    then begin b2:=False; Lb_Photos.Caption:='��������� �� ��������!' end
    else Lb_Photos.Caption:='��������� ��������';
  if b1 then Lb_Act.Font.Color:=clWindowText else Lb_Act.Font.Color:=RGB(240,0,0);
  if b2 then Lb_Photos.Font.Color:=clWindowText else Lb_Photos.Font.Color:=RGB(240,0,0);
  Result:=b1 and b2;
  IsFilesLoaded:=Result;
end;


end.
