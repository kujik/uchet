unit uFrmDlgRItmSupplier;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh,
  uFrmBasicMdi, uFrmBasicDbDialog, uData
  ;

type
  TFrmDlgRItmSupplier = class(TFrmBasicDbDialog)
    E_Name_Org: TDBEditEh;
    E_Full_Name: TDBEditEh;
    E_E_Mail: TDBEditEh;
    E_Inn: TDBEditEh;
  private
    { Private declarations }
    FullName: string;
    function  Prepare: Boolean; override;
    function  VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean; override;
    procedure VerifyBeforeSave; override;
    procedure ControlOnChange(Sender: TObject); override;
    function  Save: Boolean;  override;

  public
    { Public declarations }
    class function ShowModal2(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant; AAddParam: Variant): TMDIResult; override;
  end;

var
  FrmDlgRItmSupplier: TFrmDlgRItmSupplier;

implementation

uses
  uForms,
  uDBOra,
  uString,
  uMessages
;

{$R *.dfm}


class function TFrmDlgRItmSupplier.ShowModal2(AOwner: TComponent; ADoc: string; AMyFormOptions: TMyFormOptions; AMode: TDialogType; AID: Variant; AAddParam: Variant): TMDIResult;
var
  F: TForm;
  va: TVarDynArray;
procedure PSetControlsProc(ASelf: TObject; AControlValues: TVarDynArray);
var
  a: string;
  i: Integer;
begin
//a:='111' + adoc;
//  TFrmDlgRItmSupplier(ASelf).E_Inn.ControlLabel.Caption:=va[0];
  TFrmDlgRItmSupplier(ASelf).E_Inn.ControlLabel.Caption:=AControlValues[0];
end;
begin
  va:=[AAddParam];
  F:= Create(AOwner, ADoc, AMyFormOptions + [myfoModal], AMode, AID, null, [AAddParam], @PSetControlsProc);
//Application.CreateForm(TFrmDlgRItmSupplier, F);
//TForm(F).ShowModal;exit;
  Result.ModalResult := TFrmBasicMdi(F).ModalResult;
  AfterFormClose(F);
end;


procedure TFrmDlgRItmSupplier.ControlOnChange(Sender: TObject);
//������� ��������� ������ ��������
begin
  if FInPrepare then  Exit;
  //���� ������ ��� ��������� � ������� (�� ���� ���������), �� ��� ����� �������� ����� ������ ���������� ����� ��
  if Sender = E_Name_Org then begin
    if FullName = E_Full_Name.Text then begin
      E_Full_Name.Text:= E_Name_Org.Text;
      FullName:=E_Full_Name.Text;
    end;
  end;
  inherited;
end;


function TFrmDlgRItmSupplier.VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean;
begin
  if Mode = fDelete then Exit;
  Cth.SetErrorMarker(E_E_Mail, (E_E_Mail.Text <> '') and not S.IsValidEmail(E_E_Mail.Text));
  Cth.SetErrorMarker(E_Inn, (E_Inn.Text <> '') and (S.ValidateInn(E_Inn.Text) <> ''));
end;


procedure TFrmDlgRItmSupplier.VerifyBeforeSave;
//��������, ��� �� �������� ���������� (�� ������������ �����������)
var
  va: TVarDynArray;
  i: Integer;
  st1, st2: string;
function StRep(st: string): string;
begin
  Result:=S.ToUpper(st);
  Result:=StringReplace(StringReplace(Result, '''', ' ', [rfReplaceAll]), '"', ' ', [rfReplaceAll]);
  Result:=StringReplace(StringReplace(Result, '�� ', '', []), '��� ', '', []);
  Result:=S.ToUpper(StringReplace(StringReplace(Result, ' ', '', [rfReplaceAll]), '.', '', [rfReplaceAll]));
end;
begin
  if Mode = fDelete then
    Exit;
  FErrorMessage:= '';
  {if (E_E_Mail.Text <> '') and not S.IsValidEmail(E_E_Mail.Text) then begin
    ErrorMessage:= '�������� ����� ����������� �����!';
  end
  else if E_Inn.Text <> '' then begin
    st1 := S.ValidateInn(E_Inn.Text);
    if st1 <> '' then
      ErrorMessage:= '������ � ���:'#13#10 + st1;
  end
  else begin}
  st1 := StRep(E_Name_Org.Text);
  //������� ������������ ���� ����������� (��� �������������� - ����� ��������)
  va := Q.QLoadToVarDynArrayOneCol('select name_org from dv.kontragent where id_kontragent <> :id$i', [S.IIf(Mode = fEdit, id, -100000)]);
  for i := 0 to High(va) do begin
    //�������� �� ����� �� �������� (� �� ������� ������������ ���!)
    if E_Name_Org.Text = S.NSt(va[i]) then begin
      FErrorMessage:= '��������� � ����� ��������� ��� ����������!';
      Exit;
    end;
    //�������� �� ������� ��������
    if st1 = StRep(S.NSt(va[i]))
      then Break;
  end;
  if i <= High(va) then
    FErrorMessage:= '?��������� � ������� ��������� ��� ����������:'#13#10 + va[i] + #13#10'��� ����� �������?';
end;

{function Dlg_R_Itm_Supplier.LoadComboBoxes: Boolean;
begin
  Q.QLoadToDBComboBoxEh('select name, id_measuregroup from dv.groups_measure order by name', [], Cb_Id_MeasureGroup, cntComboLK);
  Result:=True;
end;}

function TFrmDlgRItmSupplier.Save: Boolean;
var
  res: Boolean;
begin
//Result:= True; Exit;
  repeat
    Q.QBeginTrans;
    //������ � �������� �������
    Result:=  inherited;
    if not Result then break;
    if not (Mode in [fAdd, fCopy]) then Break;
    //��������� ������� ����������� "���������" � ������������� �������
    //��� �������������� �� �����, � ��� �������� ��� on delete cascade
    Result:=  Q.QExecSql('insert into dv.kontragent_pri_kon_post (id_kontragent, id_type) values (:id_kontragent$i, :id_type$i)', [IdAfterInsert, 1]) <> -1;
  until True;
  Q.QCommitOrRollback(Result);
  if not Result
    then MyWarningMessage('�� ������� ��������� ������!');
end;


function TFrmDlgRItmSupplier.Prepare: Boolean;
begin
  Caption:='���������';
  F.DefineFields:=[
    ['id_kontragent$i',#0,-1], ['name_org$s','V=1:255::T'], ['full_name$s','V=1:1000::T'], ['inn$s','V=0:12::T'], ['e_mail$s','V=0:50::T']
  ];
  View:='v_itm_suppliers';
  Table:='dv.kontragent';
  FOpt.UseChbNoClose:= True;
  //Opt.RequestWhereClose:= cqYNC;
  FOpt.InfoArray:= [
    ['���� ������ ����������.'#13#10+
    '������� � ������ ������������ �����������!'#13#10+
    '����� ����������� ����� � ���, ���� ��� �������, ����������� �� ������������.'#13#10+
    '���� ����� ������������ ����� ������ ��������� � ������� ������� �������������, �� ����� ������ ��������������!'#13#10+
    ''#13#10
    ,not A.InArray(Mode, [fView, fDelete])],
    ['������ ����������'
    ,A.InArray(Mode, [fView, fDelete])]
  ];
  //S.DeleteRepSpaces
  //AutoSaveWindowPos:= True;
//  MinWidth:=350;
//  MinHeight:=200;
//  MaxHeight:=200;
  FWHBounds.Y2:= -1;
  Result:=inherited;
  //�������� ��� ������������� ����� �������� � ������� ������������
  FullName:=E_Full_Name.Text;
//  FormResult:= 10;
//  ModalResult:= mrYes;
//  frmmdi:=self;
//sleep(3000);
//result:=False;
end;

end.
