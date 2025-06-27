unit uFrmODedtTasks;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh,
  uFrmBasicMdi, uFrmBasicDbDialog, uData
  ;

type
  TFrmODedtTasks = class(TFrmBasicDbDialog)
    Cb_type: TDBComboBoxEh;
    Cb_id_order: TDBComboBoxEh;
    Cb_id_order_item: TDBComboBoxEh;
    E_user1: TDBEditEh;
    Cb_id_user2: TDBComboBoxEh;
    M_Comm1: TDBMemoEh;
    De_dt: TDBDateTimeEditEh;
    De_dt_planned: TDBDateTimeEditEh;
    Cb_id_state: TDBComboBoxEh;
    De_dt_beg: TDBDateTimeEditEh;
    De_dt_end: TDBDateTimeEditEh;
    M_Comm2: TDBMemoEh;
    Chb_confirmed: TDBCheckBoxEh;
    E_name: TDBEditEh;
  private
    IsStateChanged: Boolean;
    OldState: string;
    OldOrder: string;
    function  Prepare: Boolean; override;
    function  LoadComboBoxes: Boolean; override;
    procedure ControlOnExit(Sender: TObject); override;
    procedure ControlOnChange(Sender: TObject); override;
  public
  end;

var
  FrmODedtTasks: TFrmODedtTasks;

implementation

uses
  uForms,
  uDBOra,
  uString,
  uMessages,
  uFields
;

{$R *.dfm}

procedure TFrmODedtTasks.ControlOnExit(Sender: TObject);
var
  i: Integer;
begin
  inherited;
  if (Sender = Cb_id_order) and (Cb_id_order.Text <> '') and (Cb_id_order.Text <> OldOrder) then begin
    Q.QLoadToDBComboBoxEh('select slash || '' '' || itemname, id from v_order_items where id_order = :id$i and qnt > 0 and dt_end is null or id = :id_old$i order by slash',
    [Cb_id_order.Value, F.GetProp('id_order_item')], Cb_id_order_item, cntComboLK);
    Cb_id_order_item.ItemIndex := 0;
    OldOrder := Cb_id_order.Text;
  end;

  if (Sender = Cb_id_state) and (IsStateChanged) and (Cb_id_state.Value <> OldState) then begin
    i := S.NInt(Cb_id_state.Value);
    if i = 0 then
      Exit;
    if (i = 1) and Cth.DteValueIsDate(De_dt_beg) and (De_dt_beg.Value <> Date) then
      if MyQuestionMessage('���� ������ ������ ����� �������. ���������� ����� �� �� ������� ������ ������ ������� ����. ����������?') = mrYes
        then De_dt_beg.Value := null
        else Cb_id_state.Value := OldState;
    if (i < 99) and Cth.DteValueIsDate(De_dt_end) and (De_dt_end.Value <> Date) then
      if MyQuestionMessage('���� ����� ������ ����� �������. ���������� ����� �� �� ������� ������ ������ ������� ����. ����������?') = mrYes
        then De_dt_end.Value := null
        else Cb_id_state.Value := OldState;
    OldState := Cb_id_state.Value;
  end;
end;

procedure TFrmODedtTasks.ControlOnChange(Sender: TObject);
var
  i: Integer;
begin
  inherited;
  if (Sender = Cb_id_order) then begin
    Cth.AddToComboBoxEh(Cb_id_order_item, [['','']]);
  end;
  if Sender = Cb_id_state then begin
    IsStateChanged := True;
    i := S.NInt(Cb_id_state.Value);
    if i = 0 then
      Exit;
    if (i > 1) and (not Cth.DteValueIsDate(De_dt_beg)) then
      De_dt_beg.Value := Date;
    if (i = 1) and Cth.DteValueIsDate(De_dt_beg) and (De_dt_beg.Value = Date) then
      De_dt_beg.Value := null;
    if (i = 99) and (not Cth.DteValueIsDate(De_dt_end)) then
      De_dt_end.Value := Date;
    if (i < 99) and Cth.DteValueIsDate(De_dt_end) and (De_dt_end.Value = Date) then
      De_dt_end.Value := null;
    //������������ ���������� ��������� ��� ������� ������
    SetControlsEditable([Chb_confirmed], (User.GetId = S.NInt(F.GetProp('id_user1'))) and (S.NInt(Cb_id_state.Value) = 99));
  end;
end;

function TFrmODedtTasks.LoadComboBoxes: Boolean;
begin
  //��������� ����������
  if (Mode = fAdd) or (Mode = fCopy) or ((Mode = fEdit) and (User.GetId = S.NInt(F.GetPropB('id_user1'))))then begin
    //��� ����������
    Q.QLoadToDBComboBoxEh('select distinct type from j_tasks where id_user1 = :id$i order by type', [User.GetId], Cb_type, cntComboE);
    Q.QLoadToDBComboBoxEh('select ornum || '' '' || project, id from v_orders where id > 0 and dt_end is null or id = :id_old$i order by 1',
      [F.GetProp('id_order', fvtVBeg)], Cb_id_order, cntComboLK);
    Q.QLoadToDBComboBoxEh('select slash || '' '' || itemname, id from v_order_items where id_order = :id$i and qnt > 0 and dt_end is null or id = :id_old$i order by slash',
      [F.GetProp('id_order', fvtVBeg), F.GetProp('id_order_item', fvtVBeg)], Cb_id_order_item, cntComboLK);
    Q.QLoadToDBComboBoxEh('select name, id from adm_users where active = 1 and id > 0 or id = :id_old$i order by name asc',
      [F.GetProp('id_user2', fvtVBeg)], Cb_Id_user2, cntComboLK);
  end
  else begin
    //��� ��������� ��� �������������� ������������
    Q.QLoadToDBComboBoxEh('select distinct type from j_tasks order by type', [], Cb_type, cntComboE);
    Q.QLoadToDBComboBoxEh('select ornum || '' '' || project, id from v_orders where id = :id_old$i',
      [F.GetProp('id_order', fvtVBeg)], Cb_id_order, cntComboLK);
    Q.QLoadToDBComboBoxEh('select slash || '' '' || itemname, id from v_order_items where id = :id_old$i',
      [F.GetProp('id_order_item', fvtVBeg)], Cb_id_order_item, cntComboLK);
    Q.QLoadToDBComboBoxEh('select name, id from adm_users where id = :id_old$i',
      [F.GetPropB('id_user2')], Cb_Id_user2, cntComboLK);
  end;
  //��������� ������� ������ ��������
  Cth.AddToComboBoxEh(Cb_Id_State, [
    ['�����', '1'],
    ['� ������', '2'],
    ['�����������', '3'],
    ['�� ������������', '4'],
    ['�������', '5'],
    ['������', '99']
  ]);
  Result:=True;
end;


function TFrmODedtTasks.Prepare: Boolean;
begin
  Caption := '������';
  F.DefineFields:=[
    ['id$i'],
    ['type$s','V=1:100::TL'],
    ['name$s','V=1:400::T'],
    ['id_user1$i',#0,User.GetId,'id_user1$i'],
    ['user1$i;0',#0,User.GetName],
    ['id_user2$i','V=1:400'],
    ['id_order$i'],
    ['id_order_item$i'],
    ['comm1$s','V=0:4000::T'],
    ['dt$d',#0,Date],
    ['dt_planned$d','V='+S.DateTimeToIntStr(Date)],
    ['id_state$i','V=1:400',1],
    ['dt_beg$d'],
    ['dt_end$d'],
    ['comm2$s','V=0:4000::T'],
    ['confirmed$i']
  ];

  View := 'v_j_tasks';
  Table := 'j_tasks';
  FOpt.UseChbNoClose := True;
  //Opt.RequestWhereClose:= cqYNC;
  FOpt.InfoArray:= [
    ['���� ������ ������.'#13#10+
     ''#13#10+
     '���� �� ���������, ������� ��� ������ � �� ������� ������������.'#13#10+
     '��� ������������� �������� ����� �� ������ (������������ ������ ����������),'#13#10+
     '� ����� �����, ���� ����������, �������� ������� ������� ������.'#13#10+
     '���������� �������� ���� ���������� � �����������.'#13#10+
     '����� �� ������ ���������� ������������ �����������.'#13#10+
     '� ������ ������ "������" ��������� ������� "��������������".'#13#10+
     '����� ��������� ����� ������� � ������������� ������ �����������.'#13#10+
     ''#13#10
     ,not A.InArray(Mode, [fView, fDelete]) {and (User.GetId = S.NInt(CtrlValues[3]))}
    ],
    [
     '���� �� �����������, ��������� ������� ������ ������, �, ���� �����, ����������� � ���.'#13#10+
     ''#13#10+
     '���� ������ ������ � ����������� ����� ������������� ������, ��� ������������� ������������� ��� ����� �������.'#13#10+
     ''#13#10
    ,not A.InArray(Mode, [fView, fDelete])],
    ['������ ������'
    ,A.InArray(Mode, [fView, fDelete])]
  ];
  FWHBounds.X2 := -1;
  FWHBounds.Y2 := -1;
  Result := inherited;
  if not Result then
    Exit;
  SetControlsEditable([], True);
  //���� � ��������� ������� �� �����������
  SetControlsEditable([E_user1, De_dt, De_dt_beg, De_dt_end], False);
  //������������ ���������� ��������� ��� ������� ������
  SetControlsEditable([Chb_confirmed], (User.GetId = S.NInt(F.GetPropB('id_user1'))) and (S.NInt(F.GetPropB('id_state')) = 99));
  if (Mode in [fCopy, fAdd, fEdit]) and not ((User.GetId = S.NNum(F.GetPropB('id_user2'))) or (User.GetId = S.NInt(F.GetPropB('id_user1')))) then begin
    //������� ���� �����������, ���� ��������� �� ����������� (��� �� ���������, ��� ��� �������!)
    SetControlsEditable([Cb_id_state, M_comm2], False);
  end
  else if (Mode in [fEdit]) and (User.GetId <> S.NInt(F.GetPropB('id_user1'))) then begin
    //������� ���� ����������, ���� ��������� �� ��������� (��� ��������������)
    SetControlsEditable([Cb_type, E_name, Cb_id_user2, Cb_id_order, Cb_id_order_item, M_comm1, De_dt_planned, Chb_confirmed], False);
  end
  else if Mode in [fDelete, fView] then
    SetControlsEditable([], False);
  Cth.SetControlVerification(De_dt_planned, S.DateTimeToIntStr(F.GetPropB('dt')));
  OldState := Cb_id_state.Value;
  OldOrder := Cb_id_order.Text;
end;


end.
