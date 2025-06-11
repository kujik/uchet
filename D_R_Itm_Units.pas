{
���� (��������������, ����������) ������� ��������� � ���� ������ ���
�������� ��������� (���, �������, ���..), ������� ������������, ������ ������������, ���������� ������ �� ����������
��� ���� �����������
� ��� ���� ��� ������� ������� � ����������� �����������, �� �� ��� �� ����������, ��� �� ��������
����� ������� ������������ �������� �� ��������� ��������� ������� � �������������, ��������
�������������� ���� �������, �� ������� ����� ��� �����, ���� � ����� ����� �� ��������� (� ��� �������� ���)
}

unit D_R_Itm_Units;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, F_MdiDialogTemplate, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Buttons, DBCtrlsEh, Vcl.Mask;

type
  TDlg_R_Itm_Units = class(TForm_MdiDialogTemplate)
    Cb_Id_MeasureGroup: TDBComboBoxEh;
    E_Name_Unit: TDBEditEh;
    Ne_Full_Name: TDBEditEh;
    Ne_Pression: TDBNumberEditEh;
  private
    { Private declarations }
    function  Prepare: Boolean; override;
    function  LoadComboBoxes: Boolean; override;
    function  VerifyBeforeSave: Boolean; override;
  public
    { Public declarations }
  end;

var
  Dlg_R_Itm_Units: TDlg_R_Itm_Units;

implementation

uses
  uData,
  uForms,
  uDBOra,
  uString,
  uMessages
;

{$R *.dfm}

function TDlg_R_Itm_Units.VerifyBeforeSave: Boolean;
//��������, ��� �� ������� ������� ��������� (�� �������� ������������)
//��� ����� �������� � �������� �������� � ������ �� ������������ ����� � �������
//� ��� ��� ���� ������������ ������� �� ����� ��.���.
//���� ������ � Result True, �� ����� ������ ��������� "������ �� ���������!"
var
  va: TVarDynArray;
  i: Integer;
  st1, st2: string;
begin
  Result:=False;
  if Mode = fDelete then Exit;
//  ok:=False;
  st1:=S.ToUpper(StringReplace(StringReplace(E_Name_Unit.Text, ' ', '', [rfReplaceAll]), '.', '', [rfReplaceAll]));
  va:=Q.QLoadToVarDynArrayOneCol('select name_unit from dv.unit where id_unit <> :id$i', [id]);
  for i:=0 to High(va) do
    if st1 = S.ToUpper(StringReplace(StringReplace(va[i], ' ', '', [rfReplaceAll]), '.', '', [rfReplaceAll]))
      then Break;
  if i <= High(va) then begin
    if MyQuestionMessage('������� ��������� � ������� ��������� ��� ����������:'#13#10 + va[i] + #13#10'��� ����� �������?') = mrYes
      then Exit;
  end
  else Exit;
  //����� ����������� ������, ���� ���������� ��� ����������.
  ok:=False;
end;

function TDlg_R_Itm_Units.LoadComboBoxes: Boolean;
begin
  Q.QLoadToDBComboBoxEh('select name, id_measuregroup from dv.groups_measure order by name', [], Cb_Id_MeasureGroup, cntComboLK);
  Result:=True;
end;

function TDlg_R_Itm_Units.Prepare: Boolean;
begin
  Caption:='������� ���������';
  Fields:='id_unit$i;id_measuregroup$i;name_unit$s;full_name$s;pression$i';
  View:='v_itm_units';
  Table:='dv.unit';
  CtrlVerifications:=['','1:200','1:50:0:T','1:200:0:T','0:5:0:N'];
  CtrlValuesDefault:=[-1, 0, '', '', 1];
  Info:=
    '���� ������� ���������.'#13#10+
    '���� ����� ������� ������� ������� ���������, �� ����� ������ ��������������!'#13#10+
    ''#13#10
  ;
  AutoSaveWindowPos:= True;
  MinWidth:=295;
  MinHeight:=200;
  Result:=inherited;
end;


end.
