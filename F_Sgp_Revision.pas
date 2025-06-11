{
  ������� ������ ������� ��������� �� ���������� ���� ���������.
}

unit F_Sgp_Revision;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, F_MdiGridDialogTemplate,
  DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, MemTableDataEh,
  Data.DB, MemTableEh, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh,
  EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Vcl.Buttons;

type
  TForm_Sgp_Revision = class(TForm_MdiGridDialogTemplate)
    Lb_Caption: TLabel;
  private
    { Private declarations }
    procedure DBGridEh1ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    function  Prepare: Boolean; override;
    function  InitGrid: Boolean; override;            //������� ���� � �������� (����, ���������...). ���������� � Prepare, ����������� �������������.
    procedure AddRow; virtual;
    function  VerifyBeforeSave: string; override;
    function  Save: Boolean; override;
  public
    { Public declarations }
  end;

var
  Form_Sgp_Revision: TForm_Sgp_Revision;

implementation

uses
  DateUtils, uSettings, uForms, uDBOra, uString, uMessages, uData, uWindows, ShellApi
  ;

{$R *.dfm}

procedure TForm_Sgp_Revision.DBGridEh1ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
var
  rn: Integer;
begin
  inherited;
  rn:= MemTableEh1.RecNo - 1;
  MemTableEh1.RecordsView.MemTableData.RecordsList[rn].DataValues['qnt_diff', dvvValueEh] :=
    S.NNum(MemTableEh1.RecordsView.MemTableData.RecordsList[rn].DataValues['qnt_fact', dvvValueEh]) -
    S.NNum(MemTableEh1.RecordsView.MemTableData.RecordsList[rn].DataValues['qnt', dvvValueEh])
end;

procedure TForm_Sgp_Revision.AddRow;
begin
  Exit;
end;

function TForm_Sgp_Revision.VerifyBeforeSave: string;
var
  st1, st2: string;
  i, cntin, cntout: Integer;
begin
  Mth.PostAndEdit(MemTableEh1);
  Result := inherited;
  if Result <> '' then Exit;
  Result := '';
  cntin:= 0; cntout:= 0;
  for i:=0 to MemTableEh1.RecordsView.MemTableData.RecordsList.Count - 1 do begin
    if MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['qnt_fact', dvvValueEh] = null
      then Continue
      else if
        MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['qnt_fact', dvvValueEh] >
        S.NNum(MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['qnt', dvvValueEh])
        then inc(cntin)
          else if
            MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['qnt_fact', dvvValueEh] <
            S.NNum(MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['qnt', dvvValueEh])
            then inc(cntout);
  end;
  if (cntin = 0) and (cntout = 0) then begin
    Result:='��� ����������� ��� ������ �� �������. ���� ������������� � �������� ������������ �� �����!';
    Exit;
  end;
  if cntin > 0
    then st1:= '����� ����������� ��� ������������� �� ' + S.GetEndingFull(cntin, '������', '�', '�', '�') + '.';
  if cntout > 0
    then st2:= '����� ����������� ��� ������� �� ' + S.GetEndingFull(cntout, '������', '�', '�', '�') + '.';
  if MyQuestionMessage(A.ImplodeNotEmpty([st1, st2], #13#10) + #13#10'����������?') <> mrYes
    then Result := '-';
end;

function TForm_Sgp_Revision.Save: Boolean;
var
  i, idi: Integer;
  qnt: Extended;
  va1, va2: TVarDynArray2;
  fld: string;
begin
  va1:= []; va2:= [];
  //������ �� ���� �������
  for i:=0 to MemTableEh1.RecordsView.MemTableData.RecordsList.Count - 1 do begin
    if MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['qnt_fact', dvvValueEh] = null
      then Continue;
    idi:= MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['id', dvvValueEh];
    qnt:= MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['qnt_fact', dvvValueEh] -
      S.NNum(MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['qnt', dvvValueEh]);
    if qnt > 0
      then va1:= va1 + [[idi, qnt]]
      else va2:= va2 + [[idi, qnt]];
  end;
  Q.QBeginTrans(True);
  if Length(va1) > 0 then begin
    idi:=Q.QIUD(
      'i', 'sgp_act_in', '', 'id$i;id_format$i;id_user$i;dt$d;comm$s', [-1, id, User.GetId, Now, '']
    );
    for i:=0 to High(va1) do
      Q.QIUD('i', 'sgp_act_in_items', '-', 'id_act_in$i;'+S.IIf(ID = 0, 'id_or_item$i', 'id_std_item$i')+';qnt$f', [idi, va1[i][0], va1[i][1]]);
  end;
  if Length(va2) > 0 then begin
    idi:=Q.QIUD(
      'i', 'sgp_act_out', '', 'id$i;id_format$i;id_user$i;dt$d;comm$s', [-1, id, User.GetId, Now, '']
    );
    for i:=0 to High(va2) do
      Q.QIUD('i', 'sgp_act_out_items', '-', 'id_act_out$i;'+S.IIf(ID = 0, 'id_or_item$i', 'id_std_item$i')+';qnt$f', [idi, va2[i][0], va2[i][1]]);
  end;
  Result:=Q.QCommitOrRollback;
end;

function TForm_Sgp_Revision.InitGrid: Boolean;
var
  i, j: Integer;
  va2: TVarDynArray2;
begin
  if ID = 0
    then Lb_Caption.Caption := '������������� �������'
    else Lb_Caption.Caption := S.NSt(Q.QSelectOneRow('select name from v_sgp_sell_formats where id = :id$i', [ID])[0]);
  Mth.CreateTableGrid(
    DBGridEh1, True, True, False, False,[
    ['id', ftInteger, 0, 'id', 20, False, False, False],
    ['slash', ftString, 100, '����', 80, True, False, False],
    ['name', ftString, 1000, '������������', 400, True, True, True],
    ['qnt', ftInteger, 0, '���-��', 50, True, False, False],
    ['qnt_fact', ftInteger, 0, '���-�� ����.', 50, True, False, False],
    ['qnt_diff', ftInteger, 0, '�������', 50, True, False, False]
    ],
    [], '', ''
  );
  if ID = 0
    then Q.QLoadToMemTableEh('select id, slash, name, qnt, null, null from v_sgp2 order by slash, name', [id], MemTableEh1, '-')
    else Q.QLoadToMemTableEh('select id, slash, name, qnt, null, null from v_sgp_items where id_format_est = :id$i order by slash, name', [id], MemTableEh1, '-');
  FieldsReadOnly:='id;slash;name;qnt;qnt_diff';
  ColumnsVerifications:=['', '', '', '', '0.000000:1000000:0', '']; //��������, null ���������
  MemTableEh1.First;
  Result := True;
end;

function TForm_Sgp_Revision.Prepare: Boolean;
begin
  InfoArr:= [[
  '������� ������ ������� ��������� �� ���������� ���� ���������.'#13#10+
  '� ������� ������������ ��� ����������� ������� ������� ����, ���������� ����� �� ���.'#13#10+
  '� ���� "���-��" ������������ ����������, ������� ������ ���������� �� ��� �� ����������'#13#10+
  '(���������������� �������� ��� ������, ����������� ��� ������, � ��������� ����� ���� ������������� ��� ��������).'#13#10+
  ''#13#10+
  '������� � ����� "���-�� ����." �������� (����� �����), ���������� ��� ��������� �� ������.'#13#10+
  '(�� ������������ ������� ������ �� ������ �������, ����������� ������� ������ �� ����� ����������.)'#13#10+
  ''#13#10+
  '��� ������� ������ "��", ����� �������������, ����� ������������'#13#10+
  '(���� ���� ��������������� ����������� � ����������)'#13#10+
  '��� ������������� � ��� ��������, � ������� ������� ������ �� ����� "�������",'#13#10+
  '������������� � ������������� ��������������.'#13#10+
  '������ ����� � �� ���� ����� ����������� �������������.'#13#10+
  '������ �� ���� ����� �������� ��������������� � ������� � ������� ��� ��������� �������� ������� �� ���,'#13#10+
  '��� ����������� � �������� ������������ (������� ���� ������ � ����� "������� �������" � ������� �������� �������� � ���)'#13#10+
  ''#13#10+
  '��������������� ���� �������� ������� � ��������� �� ��� ���� ������!'#13#10+
  ''
  ]];
  Result := inherited;
  Caption:= '������� ���';
  Bt_Add.Visible:= False;
  Bt_Del.Visible:= False;
  Bev_Buttons.Hide;
end;


end.
