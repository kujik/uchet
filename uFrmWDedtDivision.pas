unit uFrmWDedtDivision;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh,
  uFrmBasicMdi, uFrmBasicDbDialog,
  uData, uForms, uDBOra, uString, uMessages, uFields
  ;

type
  TFrmWDedtDivision = class(TFrmBasicDbDialog)
    Cb_Office: TDBComboBoxEh;
    E_Code: TDBEditEh;
    E_Name: TDBEditEh;
    Cb_id_head: TDBComboBoxEh;
    E_editusernames: TDBEditEh;
    Chb_Active: TDBCheckBoxEh;
    procedure E_usersEditButtons0Click(Sender: TObject; var Handled: Boolean);
  private
    function  Prepare: Boolean; override;
    function  LoadComboBoxes: Boolean; override;
  public
  end;

var
  FrmWDedtDivision: TFrmWDedtDivision;

implementation

uses
  D_SelectUsers
  ;

{$R *.dfm}

function TFrmWDedtDivision.Prepare: Boolean;
begin
  Caption := '�������������';
  F.DefineFields:=[
    ['id$i'],
    ['office$i','v=1:400'],
    ['name$s','v=1:400:0:T'],
    ['id_head$i','v=1:40000'],
    ['editusers$s',''],
    ['editusernames$s;0','v=1:4000:0', True],
    ['code$s','v=0:5:0:T'],
    ['active$i','']
  ];
  View := 'v_ref_divisions';
  Table := 'ref_divisions';
  FOpt.UseChbNoClose := False;
  FOpt.InfoArray:= [[
    '������ �������������.'#13#10+
    '������� �������� �������������, �������� ��������� �� ��� � ����� ��� ����.'#13#10+
    '�������� ������������ �� ������ ����������.'#13#10+
    '������� ��� ������������� (������������ � �����������).'#13#10+
    '�������� ������ ��� ���������� �������������, ������� ����� ��������� ����'#13#10+
    '��� ������� �������������, ����� �� ������ ����� � ���� ����� � ������� ������ �������.'#13#10+
    '���� ������������� ����������� ������ � � ���� ��������� ����� ���������� '#13#10+
    '� ���� �������� �������, �� �������� ����� "������������"'#13#10
    ,not (Mode in [fView, fDelete])
  ]];
  Result:=inherited;
  if not Result then
    Exit;
  E_editusernames.ReadOnly := True;
end;


function TFrmWDedtDivision.LoadComboBoxes: Boolean;
begin
  Q.QLoadToDBComboBoxEh('select w.f || '' '' || w.i || ''  '' || w.o as name, id from ref_workers w order by name', [], Cb_id_head, cntComboLK);
  Cth.AddToComboBoxEh(Cb_office, [['���',0], ['����',1]]);
  Result := True;
end;

procedure TFrmWDedtDivision.E_usersEditButtons0Click(Sender: TObject; var Handled: Boolean);
var
  NewIds, NewNames: string;
begin
  if Dlg_SelectUsers.ShowDialog(FormDoc + '_1', F.GetProp('editusers'), True, NewIds, NewNames) <> mrOk then
    exit;
  E_editusernames.Value := NewNames;
  F.SetProp('editusers', NewIds);
end;


end.
