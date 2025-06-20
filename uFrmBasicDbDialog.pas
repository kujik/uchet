unit uFrmBasicDbDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, Mask, Vcl.ExtCtrls, Vcl.ComCtrls,
  uData, uForms, uDBOra, uString, uMessages, V_MDI, uLabelColors, uFrmBasicMdi
  ;

type
  TFrmBasicDbDialog = class(TFrmBasicMdi)
  private
  protected
    View: string;                           //�������/��� �� ������� ��������� ������
    Table: string;                          //�������, � ������� ���������� ������
    Sequence: string;                       //���������, ���� �����
    IdAfterInsert: Variant;                 //� ��������� Save ���� ������������ ����, ���������� ��� ������� ������ (�����, ���� ��������� ���. �������� � ������� ����� ����������� ������)
    function  Prepare: Boolean; override;
    function  Load: Boolean; virtual;
    function  Save: Boolean; override;
    function  LoadComboBoxes: Boolean; virtual;
    procedure SetStatusBarText(VisibleStatusBar: Boolean; Text: string); virtual;
  public
  end;

var
  FrmBasicDbDialog: TFrmBasicDbDialog;

implementation

Uses
  uErrors,
  ufields
  ;


{$R *.dfm}


procedure TFrmBasicDbDialog.SetStatusBarText(VisibleStatusBar: Boolean; Text: string);
var
  st: string;
begin
end;

function TFrmBasicDbDialog.Load(): Boolean;
//�������� ������
//�� ��� �������������� ���������� ����������, ����� � ���������� CtrlValues
//��������� ���� �� ������ �� �� ���, ���� �� ��� ������� ������, ����� ����������� � �������� ����������� ��������� ������
var
  FieldsSt: string;
  CtrlValues: TVarDynArray2;
  i: Integer;
begin
  for i := 0 to F.Count do
    if F.GetProp(i, fvtFNameL) <> '' then begin
      S.ConcatStP(FieldsSt, F.GetProp(i, fvtFNameL), ';');
    end;
  CtrlValues := Q.QLoadToVarDynArray2(Q.QSIUDSql('s', View, FieldsSt), [id]);
  if Length(CtrlValues) = 0 then begin
    MsgRecordIsDeleted;
  end;
  for i := 0 to F.Count do
    if F.GetProp(i, fvtFNameL) <> '' then begin
      F.SetPropP(i, CtrlValues[0][i], fvtVBeg);
    end;
  Result := True;
end;

function TFrmBasicDbDialog.Save(): Boolean;
//���������� ������
var
  ChildHandled: Boolean;
  i, res: Integer;
  CtrlValues2: TVarDynArray;
  FieldsSave2: string;
begin
  Result := False;
  FieldsSave2 := '';
  CtrlValues2 := [];
  //������� ���� � �� ��������, �� ��� ��� ������� ������� ����������
  for i := 0 to F.Count do
    if F.GetProp(i, fvtFNameS) <> '' then begin
      S.ConcatStP(FieldsSave2, F.GetProp(i, fvtFNameS), ';');
      CtrlValues2 := CtrlValues2 + [S.NullIfEmpty(F.GetProp(i, fvtVCurr))];
    end;
  //��������� ������������ �����
  Q.QBeginTrans(True);
  res := Q.QIUD(Q.QFModeToIUD(Mode), Table, Sequence, FieldsSave2, CtrlValues2);
  IdAfterInsert:= res;
  if not (Mode in [fEdit, fDelete]) then
    ID := res;
  Result := Q.QCommitOrRollback;
end;

function TFrmBasicDbDialog.LoadComboBoxes: Boolean;
//����������� ��� �������� �������������� ������, �������� �����������
//���������� ����� �������� �������� ������
begin
  Result := True;
end;


function TFrmBasicDbDialog.Prepare: Boolean;
var
  i, j: Integer;
  c: TControl;
begin
  Result := False;
  //�������� ����������, ������ ���� ������ ����� (��� ������� �������������� ����� � ��������, ��� �������� - �����)
  if FormDbLock = fNone then
    Exit;

  FOpt.RefreshParent := True;
  FOpt.DlgPanelStyle := dpsBottomRight;
  FOpt.StatusBarMode := stbmDialog;
  FOpt.AutoAlignControls := True;

  Cth.MakePanelsFlat(PMDIClient, []);
  F.PrepareDefineFieldsAdd;
  if Table = '' then
    Table := View;
  if Mode <> fAdd then
    Load;
  //�������� ���������� � ������� ������ ��������� ��������
  if not LoadComboBoxes then
    Exit;
  F.SetPropsControls;
  SetControlsEditable([], Mode in [fEdit, fCopy, fAdd]);
  Result := True;
end;






end.

(*

������ Props ��������������� � ����������.

���� �� ������ � �������, �� �� ��� ������ ������������ ���������� (���������) ���������.
���� ������ �� ������, �� ��������, �� �������� �� ������ ��������, ������ ��������� PMDIClient

� ���������� ��������� ����� Props, ��������� ������ ���� ����, ������� ��������� �� ���������,
���������� �� �������������� ��������, � ��� ������ - �������� � ���.





�  Props ������������� ��������, �������������� �� ���� �� ��� ������ � ������,
������� �������� ��������, ��������� �������� (� ���� �������� �������� ����� ����������� � Prepere),
������� �������������� ������� �������� ��� ������� ����� � �����, ������� ������������� ��������,
������� ���������� ��������� �������� � ������� ��� �������, ���� �� �������� ������,
������������ ��������, ������ ������, ���� ��� �� �������.

�� ���������� ������������� ���� ��� ������ � ������ - �� �����������, ���� �� ���������� � _
�� ���������� ������������� ��������, ���� ������ ������� � ������ ��_���_��������

�� ���� ��������� ������������ ���������� �����. ��� ����� ��� ������ ���� �������, ��� ��������
� �������� ��������� ��������, ��� �������� ����������� ��� ������, ��� ����� ������� ��� ��������
����� ����� �������� ����� ������.

�� ���� �������� ������������ ������� ��������� ������ � �����, �������� �������� ��� ��������
������������ � ��������� ��� ���������, ����������� ����� ��������� Prepare

����� ���� ��������� ������� �������� ���� ��� ��������� ������� � ��������� �� �����������
��������� �������

����� ���� ��������� � ��������� ��� ������� �������� ������� � ��������� ��� ��� �� ��������� �� ���������


GetProp(PropName: string; PropValueType: TDefFiledcValueType);
GetProp(PropName: string; PropValueType: Integer);

FieldNmesFromSelect(Sql: string; AliasesOnly: Boolean = False);

QLoadToProps(PropNames: string = '')
QSaveToProps(PropNames: string = '')

*)
