unit D_R_OrStdItems;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  F_MdiDialogTemplate, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, DBCtrlsEh,
  Vcl.Mask, uData, uLabelColors;

type
  TDlg_R_OrStdItems = class(TForm_MdiDialogTemplate)
    E_Name: TDBEditEh;
    Chb_R1: TDBCheckBoxEh;
    Chb_R2: TDBCheckBoxEh;
    Chb_R3: TDBCheckBoxEh;
    Chb_R4: TDBCheckBoxEh;
    Chb_R5: TDBCheckBoxEh;
    Chb_R6: TDBCheckBoxEh;
    Chb_R0: TDBCheckBoxEh;
    Chb_Wo_Estimate: TDBCheckBoxEh;
    Ne_Price: TDBNumberEditEh;
    Ne_Price_PP: TDBNumberEditEh;
    Lb_Route: TLabel;
    Chb_by_sgp: TDBCheckBoxEh;
    Chb_R7: TDBCheckBoxEh;
    procedure ControlOnChange(Sender: TObject); override;
  private
    { Private declarations }
    ID_Estimate: Variant;
    Prefix: string;
    Name_Old: string;
    Wo_Estimate_Old: Integer;
    NewEmptyEstimate: Boolean;
    function Prepare: Boolean; override;
    function VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean; override;
    function VerifyBeforeSave: Boolean; override;
    function Save: Boolean; override;
    procedure SetRoute;
  public
    { Public declarations }
  end;

var
  Dlg_R_OrStdItems: TDlg_R_OrStdItems;

implementation

{$R *.dfm}
uses
  DateUtils, uSettings, uForms, uDBOra, uString, uMessages, uOrders;


{$R *.dfm}

(*

function TDlg_OrStdItem.Load: Boolean;
var
  i, res: Integer;
  va: TVarDynArray;
  b: Boolean;
begin
  Result:= False;
  //����, ���� �������, ��������, ���.�����., ������� �� 6, ����
  va:=[0,0,   '', 0,  0,0,0,0,0,0,  null, 0,0];
  //��� ��� ����� ������ �����
  if ID_Estimate = 1 then va[3]:=1;
  //������ �� ��
  if Mode <> fAdd then begin
    va:=Q.QSelectOneRow(Q.QSIUDSql('s', 'or_std_items', Fields), [ID]);
    if va[0] = null then begin
      MsgRecordIsDeleted;
      Exit;
    end;
  end;
  //������ ������������
  Name_Old:= va[2];
  //����� ���������� ��� ���������� �������� /��������, ���� �� �� � �� ����������/
  b:=not(Mode in [fView, fDelete])and(ID_Estimate <> 0)and(ID_Estimate <> 1);
  //������������
  Cth.SetControlValue(E_Name, va[2]);
  E_Name.HighlightRequired:=True;
  E_Name.MaxLength:=400;
  //����� ����������� - ������ ���������
//  Cth.SetControlValue(Chb_Resale, va[3]);
//  Chb_Resale.Enabled:= False;
  //�������, ��������� ��� ����������� �������, �� �� ��� ��� ������������ � �������������
  Cth.SetControlValue(Chb_R_1, va[4]);
  Chb_R_1.Enabled:=b;
  Cth.SetControlValue(Chb_R_2, va[5]);
  Chb_R_2.Enabled:=b;
  Cth.SetControlValue(Chb_R_3, va[6]);
  Chb_R_3.Enabled:=b;
  Cth.SetControlValue(Chb_R_4, va[7]);
  Chb_R_4.Enabled:=b;
  Cth.SetControlValue(Chb_R_5, va[8]);
  Chb_R_5.Enabled:=b;
  Cth.SetControlValue(Chb_R_6, va[9]);
  Chb_R_6.Enabled:=b;
  //����� �������� �������  /��������, ���� �� �� � �� ����������/
//  Chb_SetOfPan.Enabled:= not(Mode in [fView, fDelete])and(ID_Estimate <> 0)and(ID_Estimate <> 1);
//  Cth.SetControlValue(Chb_SetOfPan, va[12]);
  //���� - ��� ����������� � �/�
  Cth.SetControlValue(Ne_Price, va[10]);
  //���� - ������� ������, ����� �����������
  Ne_Price.Enabled:= not(Mode in [fView, fDelete])and(ID_Estimate <> 0);
  //���� ����������� � ���� �������  /��������, ���� �� �� � �� ����������/
  Cth.SetControlValue(Ne_PricePP, va[11]);
  Ne_PricePP.Enabled:= not(Mode in [fView, fDelete])and(ID_Estimate <> 0)and(ID_Estimate <> 1);
  Result:=True;
end;




procedure TDlg_OrStdItem.Bt_OkClick(Sender: TObject);
var
  i: Integer;
  ok: Boolean;
begin
  ok:= False;
  ModalResult:= mrNone;
  repeat
  //������������ ������ ���� ������
  if Trim(E_Name.Text) = '' then Break;
  //���� �� �/� ��� �����, �� ������ ���� ���� �� ���� ����� � ��������
  if (Mode <> fDelete)and(ID_Estimate > 1)and(S.IIf(Chb_R_1.Checked, 1, 0)+S.IIf(Chb_R_2.Checked, 1, 0)+S.IIf(Chb_R_3.Checked, 1, 0)+
      S.IIf(Chb_R_4.Checked, 1, 0)+S.IIf(Chb_R_5.Checked, 1, 0)+S.IIf(Chb_R_6.Checked, 1, 0) = 0) then Break;
  //������ �������� ������� ��� ����������� � �/�
  if (ID_Estimate <= 1)and(Chb_SetOfPan.Checked) then Break;
  //���� ����������� �� ������ ���� ������ ����� ����
  if Ne_PricePP.Value > Ne_Price.Value then Break;
  //��� �/�, ���� ����������� ������ ���� ����� ����
  if Chb_Resale.Checked and (Ne_PricePP.Value <> Ne_Price.Value) then Break;
  ok:= True;
  until (True);
  if not ok then begin
    MyWarningMessage('������ �����������!');
    Exit;
  end
  else begin
    if not Save
      then begin
        MyWarningMessage('�� ������� ��������� ������!');
        Exit;
      end;
    TForm_MDI_Grid1(ParentForm).Refresh;
    E_Name.SetFocus;
    if (not Chb_NoClose.Visible)or(not Chb_NoClose.Checked) then begin
      ModalResult:=mrOk;
      Close;
    end;
    if Mode = fAdd then begin
      InLoad:=True;
      if not Load then Exit;
      InLoad:=False;
    end;
  end;
end;

procedure TDlg_OrStdItem.ControlOnChange(Sender: TObject);
var
  i: Integer;
begin
  if InChange then Exit;
  InChange:=True;
  //������ ���� �������� ��� ������ �/� ��� ���� �� ���� �� ����� ��������, ��� ������� ��� ���� ��� ���� ������� ������������
  //������ �� ���������, �� � ������� ��� ��� ��� �/�, ��� � � �������������, � � ������ ���. ������������ ������ �/�
  if (Sender = Chb_Resale)and(TDBCheckBoxEh(Sender).Checked) then
    for i:=0 to High(RouteFields) do begin
      TDBCheckBoxEh(Self.FindComponent('chb_r_' + IntToStr(i + 1))).Checked := False;
    end;
  if Pos('Chb_R_', TComponent(Sender).Name) = 1 then begin
    Chb_Resale.Checked:=False;
  end;
  if (Sender = Chb_Resale)or(Sender = Ne_Price) then begin
    if Cth.GetControlValue(Chb_Resale)
      then Ne_PricePP.Value:=Ne_Price.Value;
  end;
  if (Sender = Ne_Price)or(Sender = Ne_PricePP) then begin
    if S.NNum(Ne_PricePP.Value) > S.NNum(Ne_Price.Value)
      then Ne_PricePP.Value:=Ne_Price.Value;
  end;
  InChange:=False;
end;


procedure TDlg_OrStdItem.FormShow(Sender: TObject);
begin
  inherited;
  E_Name.SetFocus;
end;

function TDlg_OrStdItem.ShowDialog(AParentForm: TForm; aMode: TDialogType; aID: Variant; aID_Estimate: Variant): Boolean;
var
  i, j:Integer;
begin
  Mode:= aMode;
  ID:= aID;
  ID_Estimate:= aID_Estimate;
  ParentForm:= aParentForm;
  for i:=0 to High(RouteFields) do begin
    TDBCheckBoxEh(Self.FindComponent('chb_r_' + IntToStr(i + 1))).Caption:=RouteFields[i];
  end;
  Fields:= 'id$i;id_or_format_estimates$i;name$s;resale$i;r1$i;r2$i;r3$i;r4$i;r5$i;r6$i;price$f;price_pp$f;setofpan$i';
  Cth.SetControlsOnChange(Self, ControlOnChange, True);
  Cth.SetDialogForm(Self, Mode, '�������');
  Chb_NoClose.Visible:= Mode in [fAdd, fCopy];
  InLoad:=True;
  if not Load then Exit;
  InLoad:=False;
  Result:=ShowModal = mrOk;
end;
*)

(*
function TDlg_OrStdItem.Save: Boolean;
//�������� � ��
var
  i, res: Integer;
  prefix, name, nameold: string;
begin
  Result:= False;
  //��������, ��� �� ������ ������������
  if (Mode <> fDelete)and(ID_Estimate > 1)
    //���� ��� ��� ���, �� ������� � ��� �� ������ � ����� ���.�����
    then res:=Q.QSelectOneRow(
            'select count(1) from or_std_items where id <> :id$i and (id_or_format_estimates = :idf$i or id_or_format_estimates = 1) and name = :name$s',
            [ID, ID_Estimate, Trim(E_Name.Text)]
          )[0]
    //���� ��� ��� ����� �� ������� � ���.����� � ���� �����������
    else if (ID_Estimate = 1) then
      res:=Q.QSelectOneRow(
        'select count(1) from or_std_items where id <> :id$i and id_or_format_estimates >= 1 and name = :name$s',
        [ID, Trim(E_Name.Text)]
      )[0];
  //� ����� ������ ����� ���� �������������� � ����� ������������� �������, � ������ � ���� ������, ���� ������� ���� ���������������,
  //��� ��������� �������� ��� ����� ������� � ��������� � �����������
  //� � ������� ������������� ����� ������������� �� ������������
  if Res > 0 then begin
    MyWarningMessage('����� ������������ ��� ����������, ��� �����������!');
    Exit;
  end;
  //�������� ������� � �������
  res:= Q.QIUD(Q.QFModeToIUD(Mode), 'or_std_items', '', Fields,
    [ID, ID_Estimate, Trim(E_Name.Text), Cth.GetControlValue(Chb_Resale),
    Cth.GetControlValue(Chb_R_1), Cth.GetControlValue(Chb_R_2), Cth.GetControlValue(Chb_R_3), Cth.GetControlValue(Chb_R_4), Cth.GetControlValue(Chb_R_5), Cth.GetControlValue(Chb_R_6),
    Cth.GetControlValue(Ne_Price), Cth.GetControlValue(Ne_PricePP), Cth.GetControlValue(Chb_SetOfPan)]
  );
  if Res = -1 then Exit;
  if (Mode = fEdit)and(Name_Old <> Trim(E_Name.Text)) then begin
    //���� ����� �������������� � ���������� ������������
    prefix:='';
    if ID_Estimate > 0 then
      //������� ������� ������
      prefix:=Q.QSelectOneRow('select prefix from or_format_estimates where id = :id$i', [ID_Estimate])[0];
      //������ � ����� ���
      name:=S.IIFStr(prefix <> '', prefix + '_', '') + Trim(E_Name.Text);
      nameold:=S.IIFStr(prefix <> '', prefix + '_', '') + Name_Old;
      //��������, ���� �� ��� � ��� � ��������� ������ ��������������� ������ �����
      Res:=Q.QSelectOneRow(
        'select count(1) from dv.nomenclatura where id_group = :ig_group$i and name = :name$s',
        [ItmGroups_Production_ID, name]
      )[0];
    if Res = 0 then begin
      //���� ���, �� ����������� ������ �� ������ ������ � ����� (���� ��� ����������� ����)
      Q.QExecSql(
        'update dv.nomenclatura set name = :name$s, fullname = :fullname$s where id_group = :ig_group$i and name = :nameold$s',
        [name, name, ItmGroups_Production_ID, nameold]
      );
    end;
  end;
  Result:=True;
end;
*)


function TDlg_R_OrStdItems.Save: Boolean;
//������ ����������� � ��
//��� ��������� �������� �������� ��� ����� � ������ �������������� ��� ���� ���������� ����� ����� ������ �������� �������
//(���� ����� ���� �����, �� ��������� ������ �����, ���� �� ����� ����������, �� ����� ������ ������� - ����� ��������� ����� � ���������)
var
  name, nameold, prefix: string;
  Res: Integer;
begin
  Q.QBeginTrans;
  repeat
  //�������� �������� ������
  Result:=inherited;
  if not Result then Break;
  if (Mode = fEdit) and (E_Name.Text <> Name_Old) then begin
    //���� ��� �������������� � ������������ ���������� - ��������� �������� ��� � � �� ��� (� ������ ��������)
    //������� ������� ������
    prefix:='';
    if ID_Estimate > 0
      then prefix:=Q.QSelectOneRow('select prefix from or_format_estimates where id = :id$i', [ID_Estimate])[0];
    //������ � ����� ���
    name:=S.IIFStr(prefix <> '', prefix + '_', '') + Trim(E_Name.Text);
    nameold:=S.IIFStr(prefix <> '', prefix + '_', '') + Name_Old;
    //��������, ���� �� ��� � ��� � ��������� ������ ��������������� ������ �����
    Res:=Q.QSelectOneRow(
      'select count(1) from dv.nomenclatura where id_group = :ig_group$i and name = :name$s',
      [ItmGroups_Production_ID, name]
    )[0];
    if Res = 0 then begin
      //���� ���, �� ����������� ������ �� ������ ������ � ����� (���� ��� ����������� ����)
      Result:= Q.QExecSql(
        'update dv.nomenclatura set name = :name$s, fullname = :fullname$s where id_group = :ig_group$i and name = :nameold$s',
        [name, name, ItmGroups_Production_ID, nameold]
      ) >= 0;
    end;
  end;
  if not Result then Break;
  if (Mode = fEdit) and (Cth.GetControlValue(Chb_Wo_Estimate) <> Wo_Estimate_Old) then begin
    //���� ��������� ������� "��� �����", �� ������� �����
    //(� �������� ����� ������� �������, ���� ��� ���� ���� ���������� �������� �����)
    Result:=Orders.RemoveEstimateForStdItem(id, True);
  end;
  if (Mode = fEdit) then begin
    //��������� � �������� ���� � ������� �������, ��������������� �������
      Result:= Q.QExecSql(
        'update order_items set '+
        'price = :price$f, price_pp = :price_pp$f '+
        'where id_order < 0 and id_std_item = :id_std_item$i',
        [Ne_Price.Value, Ne_Price_PP.Value,
         ID
        ]
      ) >= 0;
      if Result then
      Result:= Q.QExecSql(
        'update order_items set '+
        'r0 = :r0$i, r1 = :r1$i, r2 = :r2$i, r3 = :r3$i, r4 = :r4$i, r5 = :r5$i, r6 = :r6$i, r7 = :r7$i '+
        'where id_order < 0 and id_std_item = :id_std_item$i and nvl(sgp, 0) <> 1',
        [Cth.GetControlValue(Chb_R0),Cth.GetControlValue(Chb_R1),Cth.GetControlValue(Chb_R2),Cth.GetControlValue(Chb_R3),
         Cth.GetControlValue(Chb_R4),Cth.GetControlValue(Chb_R5),Cth.GetControlValue(Chb_R6),Cth.GetControlValue(Chb_R7),
         ID
        ]
      ) >= 0;
  end;
  until True;
  Q.QCommitOrRollback(Result);
end;


function TDlg_R_OrStdItems.VerifyBeforeSave: Boolean;
var
  i, res1, res2, res3: Integer;
begin
  Result := False;
  //�������� ��� �������������� ��� ���������� ������ (������ ���� ����������� ������������)
  //��������, ��� �� ������ ������������ ����� ����������� ������� ���� �� ���� ��������
  //����� ������������ � �������� �� ������ ���� � ���� ������� ������������ �����    //!!!
  //� ����� � � ���� ��� � ����� "��������� � �������������"
  if (Mode <> fDelete) and (ID_Estimate > 1) and (E_Name.Text <> Name_Old) then begin
    res1 := Q.QSelectOneRow('select count(1) from or_std_items where id <> :id$i and (id_or_format_estimates = :idf$i) and name = :name$s', [ID, ID_Estimate, E_Name.Text])[0];
    //res2 := Q.QSelectOneRow('select count(1) from bcad_nomencl where name = :name$s', [Prefix + '_' + E_Name.Text])[0];
    res3 := Q.QSelectOneRow('select count(1) from dv.nomenclatura where id_nomencltype = 0 and name = :name$s', [Prefix + '_' + E_Name.Text])[0];
    if res1 + res2 + res3 > 0 then begin
      MyWarningMessage(
        S.IIf(res1 > 0, '����� ������������ ��� ���������� � ���� ������ ����������� ������� �����!'#13#10, '') +
          //S.IIf(res2 > 0, '����� ������������ (� ������ ��������) ��� ���������� � ����������� ������� ������� �����!'#13#10, '') +
            S.IIf(res3 > 0, '����� ������������ (� ������ ��������) ��� ���� � ��� ����� ������������ ���� "��������� � �������������"!'#13#10, '')
              + #13#10'������ �� ����� ���� ���������!'
        );
      ok := False;
      Exit;
    end;
  end;
  if (Mode = fEdit) and (Chb_Wo_Estimate.Checked) then begin
    NewEmptyEstimate:=Q.QSelectOneRow('select count(1) from estimates where id_std_item = :id$i and isempty = 0', [id])[0] > 0;
    if NewEmptyEstimate then
      if MyQuestionMessage('��� ����� ������� ������ ��� "��� �����", �� ������ � ���� ��� ���������� �������� �����.'#13#10'��� ����� �������.'#13#10'����������?') <> mrYes then begin
        ok := False;
        Exit;
      end;
   end;
end;

function TDlg_R_OrStdItems.VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean;
//�������� ����� �������:
//���� �� ����� �������, ����� �� ������ ����
//���� ���� ����������� ������ �����
var
  i, j: Integer;
  ok: Boolean;
begin
  j := 0;
  for i := 1 to 9 do
    if FindComponent('Chb_R' + IntToStr(i)) <> nil then
      if TDBCheckBoxEh(FindComponent('Chb_R' + IntToStr(i))).Checked then
        j := j + 1;
  for i := 1 to 9 do
    if FindComponent('Chb_R' + IntToStr(i)) <> nil then
      Cth.SetErrorMarker(TDBCheckBoxEh(FindComponent('Chb_R' + IntToStr(i))), Chb_R1.Enabled and (j = 0));
  //���� ����������� �� ������ ���� ������ ����� ����
  Cth.SetErrorMarker(Ne_Price_PP, (Ne_Price_PP.Value > Ne_Price.Value) or (Ne_Price_PP.Value = null));
end;

procedure TDlg_R_OrStdItems.SetRoute;
var
  i: Integer;
begin
  if Mode in [fDelete, fView] then Exit;
  if (Cth.GetControlValue(Chb_Wo_Estimate) = 1) or (Cth.GetControlValue(Chb_R0) = 1) then
    for i := 1 to 9 do
      if FindComponent('Chb_R' + IntToStr(i)) <> nil then begin
        TDBCheckBoxEh(FindComponent('Chb_R' + IntToStr(i))).Checked := False;
        TDBCheckBoxEh(FindComponent('Chb_R' + IntToStr(i))).Enabled := False;
      end;
  if (Cth.GetControlValue(Chb_Wo_Estimate) = 0) and (Cth.GetControlValue(Chb_R0) = 0) then
    for i := 1 to 9 do
      if FindComponent('Chb_R' + IntToStr(i)) <> nil then
        TDBCheckBoxEh(FindComponent('Chb_R' + IntToStr(i))).Enabled := True;
end;

procedure TDlg_R_OrStdItems.ControlOnChange(Sender: TObject);
var
  i: Integer;
  v: Variant;
  n: string;
begin
  if InChange then
    Exit;
  InChange := True;
  n := TControl(Sender).Name;
  v := Cth.GetControlValue(TControl(Sender));
  if (n = 'Chb_R0') or (n = 'Chb_Wo_Estimate') then
    SetRoute;
  InChange := False;
  inherited;
end;

function TDlg_R_OrStdItems.Prepare: Boolean;
var
  i: Integer;
begin
  Caption := '����������� �������';
  Fields := 'id$i;id_or_format_estimates$i;name$s;price$f;price_pp$f;wo_estimate$i;r0$i;r1$i;r2$i;r3$i;r4$i;r5$i;r6$i;r7$i;by_sgp$i';
  View := 'or_std_items';
  Table := 'or_std_items';
  CtrlVerifications := ['', '', '1:400:0:T', '0:9999999:2:n', '0:9999999:2:n', '', '', '', '', '', '', '', '', '', ''];
  CtrlValuesDefault := [0, AddParam, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  Info := '������� ������� ������������ �������.'#13#10;
  DefFocusedControl := E_Name;
  NoCloseIfAdd := True;
  AutoSaveWindowPos := True;
  MinWidth := 600;
  MinHeight := 400;
  Result := inherited;
  for i := 0 to High(RouteFields) do begin
    TDBCheckBoxEh(Self.FindComponent('chb_r' + IntToStr(i + 1))).Caption := RouteFields[i];
  end;
  Name_Old := CtrlValues[2];
  Wo_Estimate_Old:=CtrlValues[5];
  ID_Estimate := AddParam;//CtrlValues[1];
  Prefix := Q.QSelectOneRow('select prefix from or_format_estimates where id = :id$i', [ID_Estimate])[0];
  SetRoute;
  Verify(nil);
end;

end.
