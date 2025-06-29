unit D_NewEstimateInput;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, F_MdiGridDialogTemplate, DBGridEhGrouping,
  ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, MemTableDataEh, Data.DB, MemTableEh, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh,
  Vcl.Buttons, uLabelColors, uString;

{
� AddParam ��������:
[IdEstimate, 0(���)/1(���), ������������_������/������]
}

type
  TDlg_NewEstimateInput = class(TForm_MdiGridDialogTemplate)
    lbl_Caption: TLabel;
    Bt_Load: TBitBtn;
    lbl_Type: TLabel;
    Bt_LoadSelf: TBitBtn;
    Bt_PasteEstimate: TBitBtn;
    Bt_CopyEstimate: TBitBtn;
    procedure CellButtonClick(Sender: TObject; var Handled: Boolean); override;
    procedure DBGridEh1ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure Bt_LoadClick(Sender: TObject);
    procedure DBGridEh1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Bt_LoadSelfClick(Sender: TObject);
    procedure DBGridEh1GetCellParams(Sender: TObject; Column: TColumnEh; AFont: TFont; var Background: TColor; State: TGridDrawState);
    procedure Bt_PasteEstimateClick(Sender: TObject);
    procedure Bt_CopyEstimateClick(Sender: TObject);
  private
    { Private declarations }
    Err, Err2: TVarDynArray;
    function Prepare: Boolean; override;
    function InitGrid: Boolean; override;            //������� ���� � �������� (����, ���������...). ���������� � Prepare, ����������� �������������.
    function InitAdd: Boolean; override;             //�������������� �������� �������, ������� ���������� � Prepare.
    function VerifyBeforeSave: string; override;     //
    function IsRowCorrect: Boolean; override;        //
    function VerifyEstimateRow: string;
    //�������� ������������ ����� ����� ��������
    //(�� ����� � � ����� ������)
    procedure VerifyEstimateAfterLoad;
  public
    { Public declarations }
  end;

var
  Dlg_NewEstimateInput: TDlg_NewEstimateInput;

implementation

uses
  DateUtils, uSettings, uForms, uDBOra, uMessages, uData, uOrders, uWindows;


{$R *.dfm}

function TDlg_NewEstimateInput.IsRowCorrect: Boolean;
begin
  Result:=inherited;
  //Result := (MemTableEh1.FieldByName('name').AsString <> '') and (MemTableEh1.FieldByName('idgroup').AsString <> '') and (MemTableEh1.FieldByName('idunit').AsString <> '') and (MemTableEh1.FieldByName('qnt1').AsString <> '');
end;

function TDlg_NewEstimateInput.VerifyEstimateRow: string;
var
  st: string;
begin
  if (MemTableEh1.FieldByName('idgroup').Value = null)or(MemTableEh1.FieldByName('name').Value = null) then Exit;
  st:=Q.QSelectOneRow('select F_TestEstimateItem(:g$i, :n$s) from dual',
    [MemTableEh1.FieldByName('idgroup').Value, MemTableEh1.FieldByName('name').Value]
  )[0];
  if High(Err2) < MemTableEh1.RecNo then SetLength(Err2, MemTableEh1.RecNo + 1);
  Err2[MemTableEh1.RecNo]:=st;
end;


function TDlg_NewEstimateInput.VerifyBeforeSave: string;
var
  rn, i, j, k, m: Integer;
  va1: TVarDynArray;
  st: string;
  b: Boolean;
begin
  Mth.PostAndEdit(MemTableEh1);
  Result := inherited;
  if Result <> '' then
    Exit;
  Result := '';
{  va1 := A.Explode(FieldsNoRepaeted, ';');
  rn := MemTableEh1.RecNo;
  MemTableEh1.RecNo := 1;
  for i := 1 to MemTableEh1.RecordCount do begin
    Result := IsRowCorrect;
    if not Result then
      Break;
  end;}
  st := '';
  Err := [];
  b := True;
{(*}
  for i:=0 to MemTableEh1.RecordsView.MemTableData.RecordsList.Count - 1 do begin
    //��������� ������ ������
    //��������� �� ������ ����, ��������� ���� ��������� �� ���������, �� ����� False ��� � inherited
    if S.NSt(MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['name', dvvValueEh]) = '' then Continue;
    //--�������� ������������ � ������� ������� �������, ������ � ������
    //--1� ������ = 0 ���� ��� ����� ������ � ����������� ������������ ����
    //--2� ������ = 0 - ������ ��� ������������ �� ������ ������� - ��� ������ ������� � v_or_std_items
    //--3� ������ = 0 - ������ ��� ������������ �� ������ ������� ������� ���� - ������������ ������� � ������ �������, ��� ���� ������� ���������� �������� ������
    st:=Q.QSelectOneRow('select F_TestEstimateItem(:g$i, :n$s) from dual',
      [MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['idgroup', dvvValueEh], MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['name', dvvValueEh]]
    )[0];
    if st <> '111' then begin
//      Err:=Err + [st];
      if (st[2] = '0')or(st[3] = '0') then
        b:=False;  //���� ������, � �������� ��������� ����� ������.
      Err:=Err + ['[ ' + MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['name', dvvValueEh] + ' ] - ' +
        S.IIf(st[2] = '0', '��� ������ �������', S.IIf(st[3] = '0', '��� ��������, � ������ ���� ��������', S.IIf(st[1] = '0', '����� �������!', '')))];
    end;
  end;
{*)}
  if Length(Err) = 0 then
    //������ � �������������� ���
    Result := ''
  else if b then begin
    //���� ������ �������������� (����� �������) - �������
    if MyQuestionMessage(A.Implode(Err, #13#10) + #10#13#10#13 + '�������� �����?') = mrYes then
      //��������
      Result := ''
    else begin
      //��������� � �������h
      b := False;
      Result := '-';
    end;
  end
  else    //����������� ������ - �� ����� �����
    Result := A.Implode(Err, #13#10);
  if b then begin
    //������� �����
    //myinfomessage('Save');
//  Mth.LoadGridFromVa2(DBGridEh1, Est, 'group;name;unit;qnt1;comm', '1;0;2;3;4');
    Wh.SelectDialogResult2 := [];
    for i := 0 to MemTableEh1.RecordsView.MemTableData.RecordsList.Count - 1 do begin
      if S.NSt(MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['name', dvvValueEh]) = '' then
        Continue;
      Wh.SelectDialogResult2 := Wh.SelectDialogResult2 + [[MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['name', dvvValueEh], MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['idgroup', dvvValueEh], MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['idunit', dvvValueEh], MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['qnt1', dvvValueEh], MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['comm', dvvValueEh]]];
    end;
    Result := '';
  end;
{*)}
end;

procedure TDlg_NewEstimateInput.VerifyEstimateAfterLoad;
//�������� ������������ ����� ����� ��������
//(�� ����� � � ����� ������)
var
  i, j: Integer;
begin
  MemTableEh1.DisableControls;
  for i := 1 to MemTableEh1.RecordCount do begin
    MemTableEh1.RecNo:=i;
    VerifyEstimateRow;
  end;
  MemTableEh1.First;
  MemTableEh1.EnableControls;
end;

procedure TDlg_NewEstimateInput.Bt_CopyEstimateClick(Sender: TObject);
begin
  if MyQuestionMessage('� ����� ����� ����������� ��� ����������� �����! ���������, ��������� � ���� ���� ��� ���������� �����, ����������� �� �����! ����������?') <> mrYes then
    Exit;
   Orders.CopyEstimateToBuffer(id, null);
end;

procedure TDlg_NewEstimateInput.Bt_LoadClick(Sender: TObject);
var
  i, j: Integer;
  Est: TVarDynArray2;
  FileName: string;
begin
  //[Name, idgr, idunit, cQnt1, cComm];
  FileName := '';
  if not Orders.EstimateFromFile(FileName, Est) then
    Exit;
  MemTableEh1.EmptyTable;
  InPrepare := True;
  Mth.LoadGridFromVa2(DBGridEh1, Est, 'idgroup;name;idunit;qnt1;comm', '1;0;2;3;4');
  VerifyEstimateAfterLoad;
  Mth.PostAndEdit(MemTableEh1);
  InPrepare := False;
end;

procedure TDlg_NewEstimateInput.Bt_LoadSelfClick(Sender: TObject);
begin
  inherited;
  MemTableEh1.Edit;
  Q.QLoadToMemTableEh('select id_group as idgroup, name, id_unit as idunit, qnt1, comm from v_estimate where id_estimate = :id$i order by groupname', [id], MemTableEh1);
  VerifyEstimateAfterLoad;
  Mth.PostAndEdit(MemTableEh1);
end;

procedure TDlg_NewEstimateInput.Bt_PasteEstimateClick(Sender: TObject);
begin
  inherited;
  if MyQuestionMessage('�������� ����� �� ������?') <> mrYes then
    Exit;
  MemTableEh1.Edit;
  Q.QLoadToMemTableEh('select id_group as idgroup, name, id_unit as idunit, qnt1, comm from v_estimate where id_estimate = :id$i order by groupname', [-User.GetID], MemTableEh1);
  VerifyEstimateAfterLoad;
  Mth.PostAndEdit(MemTableEh1);
end;

procedure TDlg_NewEstimateInput.CellButtonClick(Sender: TObject; var Handled: Boolean);
var
  va: TVarDynArray;
  i: Integer;
begin
 // if MemTableEh1.RecordCount = 0 then Exit;
  Wh.SelectDialogResult := [];
  if TCellButtonEh(Sender).Hint =  '������� �� ����������� ������������' then begin
    Wh.ExecReference(myfrm_R_bCAD_Nomencl_SEL, Self, [myfoDialog, myfoModal], null);
    if Length(Wh.SelectDialogResult) = 0 then
      Exit;
    MemTableEh1.Edit;
    MemTableEh1.FieldByName('name').Value := Wh.SelectDialogResult[2];
    va := Q.QLoadToVarDynArrayOneRow('select max(id_group), max(id_unit) from v_bcad_nomencl_add where name = :name$s', [MemTableEh1.FieldByName('name').Value]);
    if Length(va) <> 0 then begin
      MemTableEh1.FieldByName('idgroup').Value := va[0];
      MemTableEh1.FieldByName('idunit').Value := va[1];
    end;
  end
  else begin
    Wh.ExecReference(myfrm_R_OrderStdItems_SEL, Self, [myfoDialog, myfoModal], null);
    if Length(Wh.SelectDialogResult) = 0 then
      Exit;
    MemTableEh1.Edit;
    MemTableEh1.FieldByName('name').Value := Wh.SelectDialogResult[1];
    for i := 0 to DBGridEh1.FindFieldColumn('idgroup').PickList.Count - 1 do
      if DBGridEh1.FindFieldColumn('idgroup').PickList[i] = '������� �������' then begin
        MemTableEh1.FieldByName('idgroup').Value := DBGridEh1.FindFieldColumn('idgroup').KeyList[i];
        Break;
      end;
    for i := 0 to DBGridEh1.FindFieldColumn('idunit').PickList.Count - 1 do
      if DBGridEh1.FindFieldColumn('idunit').PickList[i] = '��.' then begin
        MemTableEh1.FieldByName('idunit').Value := DBGridEh1.FindFieldColumn('idunit').KeyList[i];
        Break;
      end;
  end;
  Mth.PostAndEdit(MemTableEh1);
  VerifyEstimateRow;
end;

procedure TDlg_NewEstimateInput.DBGridEh1ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
  inherited;
  VerifyEstimateRow;
end;

procedure TDlg_NewEstimateInput.DBGridEh1GetCellParams(Sender: TObject;
  Column: TColumnEh; AFont: TFont; var Background: TColor;
  State: TGridDrawState);
begin
  inherited;
  if MemTableEh1.RecNo <= 0 then Exit;
  if (High(Err2) < MemTableEh1.RecNo)or(S.Nst(Err2[MemTableEh1.RecNo])='') then Exit;
  if S.Nst(Err2[MemTableEh1.RecNo])[1] = '0' then Background:=RGB(255,255,150);
  if S.Nst(Err2[MemTableEh1.RecNo])[2] = '0' then Background:=RGB(255,150,150);
  if S.Nst(Err2[MemTableEh1.RecNo])[3] = '0' then Background:=RGB(255,150,150);
end;

procedure TDlg_NewEstimateInput.DBGridEh1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
//��� ����������� ������� �� ������� F2 ������ �������, ������ �������� (��� ���������) ������������ ����� �� ��������
//(�������� ������ ���������������, �������� ������� ������� ������������ �������)
var
  i, j: Integer;
begin
  inherited;
  if (Key = vk_F2) and (TVarDynArray(AddParam)[1] = 0) then begin
    Mth.PostAndEdit(MemTableEh1);
    MemTableEh1.FieldByName('name').Value := TVarDynArray(AddParam)[2];
    for i := 0 to DBGridEh1.FindFieldColumn('idgroup').PickList.Count - 1 do
      if DBGridEh1.FindFieldColumn('idgroup').PickList[i] = '������� �������' then begin
        MemTableEh1.FieldByName('idgroup').Value := DBGridEh1.FindFieldColumn('idgroup').KeyList[i];
        Break;
      end;
    for i := 0 to DBGridEh1.FindFieldColumn('idunit').PickList.Count - 1 do
      if DBGridEh1.FindFieldColumn('idunit').PickList[i] = '��.' then begin
        MemTableEh1.FieldByName('idunit').Value := DBGridEh1.FindFieldColumn('idunit').KeyList[i];
        Break;
      end;
    MemTableEh1.FieldByName('qnt1').Value := 1;
    Mth.PostAndEdit(MemTableEh1);
  end;
end;

function TDlg_NewEstimateInput.InitGrid: Boolean;
var
  i, j: Integer;
  va2: TVarDynArray2;
begin
  {(*}
  Orders.LoadBcadGroups(True);
  Mth.CreateTableGrid(
    DBGridEh1, True, False, False, False,[
    ['idgroup', ftString, 1000, '������', 200, True, False, False],
    ['name', ftString, 1000, '������������', 400, True, True, True],
    ['idunit', ftString, 50, '��.���.', 100, True, False, False],
    ['qnt1', ftFloat, 0, '���-��', 80, True, False, False],
    ['comm', ftString, 1000, '����������', 400, True, True, True]
    ],
    [], '', ''
  );
  {*)}
  ColumnsVerifications := ['1:1000', '1:1000', '1:50:TP', '0:999999:5:N'{����������� ������ ���-��}, '0:1000::TP'];  //TP - ????
  FieldsNoRepaeted := 'name';
//  Gh.SetGridColumnPickList(DBGridEh1, 'group', Q.QLoadToVarDynArrayOneCol('select name from bcad_groups order by name', []), [], True);
//  Gh.SetGridColumnPickList(DBGridEh1, 'unit', Q.QLoadToVarDynArrayOneCol('select name from bcad_units order by name', []), [], True);
  Gh.SetGridColumnPickList(DBGridEh1, 'idgroup', A.VarDynArray2ColToVD1(Orders.BcadGroups, 0), A.VarDynArray2ColToVD1(Orders.BcadGroups, 1), True);
  Gh.SetGridColumnPickList(DBGridEh1, 'idunit', A.VarDynArray2ColToVD1(Orders.BcadUnits, 0), A.VarDynArray2ColToVD1(Orders.BcadUnits, 1), True);
  Gh.SetGridInCellButtons(DBGridEh1, 'name;name', '������� �� ����������� ������������;������� �� ����������� ����������� �������', CellButtonClick);
//  Gh.SetGridInCellButtons(DBGridEh1, 'name;name', '������������;����������� �������', CellButtonClick);
//  Gh.SetGridInCellButtons(DBGridEh1, 'name', '������� �� ����������� ������������', CellButtonClick);

  if id <> null
    then Bt_LoadSelfClick(nil);

  OneRowOnOpen := True;
  AllowEmptyTable := False;
  Result := True;
end;

function TDlg_NewEstimateInput.InitAdd: Boolean;
begin
  Caption := 'C����';
  if (Mode <> fView) and (id <> null)
    then Mode:= fEdit else Mode := fAdd;
  InfoArr := [['���� ����� �����.', id = null], ['�������������� �����.', id <> null], ['www', False]];
  pnl_Top.Visible := True;
  pnl_Bottom.Visible := False;
  lbl_Type.Caption := '';
  lbl_Caption.Caption := '';
  lbl_Type.Caption := S.IIf(TVarDynArray(AddParam)[1] = 0, '����� � ������������ �������:', '����� � ������:');
  lbl_Caption.Caption := TVarDynArray(AddParam)[2];
  //lbl_Caption.SetCaption2('����� � ������������ �������: ''$FF0000  ��.�_����� �������� 100�600');
  //lbl_Caption.WordWrap := True;
  Cth.SetBtn(Bt_Load, mybtExcel, True, '��������� ����� �� �����');
  Cth.SetBtn(Bt_LoadSelf, mybtLoad, True, '��������� ������� ����� �� ��');
  Cth.SetBtn(Bt_PasteEstimate, mybtPasteEstimate, True, '�������� ����� �� ������');
  Cth.SetBtn(Bt_CopyEstimate, mybtLoad, True, '����������� ����� � �����');
  Bt_LoadSelf.Enabled := id <> null;
  Result := True;
end;

function TDlg_NewEstimateInput.Prepare: Boolean;
begin
  Wh.SelectDialogResult2 := [];
  Result := inherited;
end;

end.


(*
��� �������������� ����� ��������� ���������� � ������������ ������ ������ ����� �������.
����� ������ ���������� �� ������� ����������� �� 5 ������, ��������� ��� � �� number(11,5)
� ��� ���� ���������� �� ��� ������� ����������� �� ������ ����� � ������� �������
(��� �������� ���������� � ��)

*)
