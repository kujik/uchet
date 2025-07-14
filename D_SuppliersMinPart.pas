unit D_SuppliersMinPart;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, F_MdiGridDialogTemplate,
  DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, MemTableDataEh,
  Data.DB, MemTableEh, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh,
  GridsEh, DBAxisGridsEh, DBGridEh, Vcl.Buttons, EhLibVclUtils;

type
  TDlg_SuppliersMinPart = class(TForm_MdiGridDialogTemplate)
    lbl_Caption: TLabel;
    procedure DBGridEh1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    BaseUnit: string;                                //��. ���. �������� ������������ (������� � ���� nomenclatura)
    IsDefaultChanged: Boolean;                       //���� ��������� �� ��������
    function  Prepare: Boolean; override;
    function  InitGrid: Boolean; override;            //������� ���� � �������� (����, ���������...). ���������� � Prepare, ����������� �������������.
    function  InitAdd: Boolean; override;             //�������������� �������� �������, ������� ���������� � Prepare.
    procedure DBGridEh1ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure SetCellEditable; override;
    function  SetPickLists: Boolean;
    function  Save: Boolean; override;
    procedure CellLinkClick(Grid: TCustomDBGridEh; Column: TColumnEh);
    procedure CellButtonClick(Sender: TObject; var Handled: Boolean);
  public
    { Public declarations }
  end;

var
  Dlg_SuppliersMinPart: TDlg_SuppliersMinPart;

implementation

uses
  DateUtils, uSettings, uForms, uDBOra, uString, uMessages, uData, uWindows, ShellApi
  ;

{$R *.dfm}

procedure TDlg_SuppliersMinPart.CellButtonClick(Sender: TObject; var Handled: Boolean);
//��������� ������ � ������� �����
begin
  //if MemTableEh1.RecordCount = 0 then Exit;
  if TCellButtonEh(Sender).Hint = '���������' then begin
    //������� ���� ������ � �������� �����������
    Wh.SelectDialogResult:=[];
    Wh.ExecReference(myfrm_R_Itm_Suppliers, Self, [myfoDialog, myfoModal], id);
    //�� ��������, ��� �� ������ ���������, �� ����� �������� ������ ���������� �� �� �������� ���
    SetPickLists;
    if Length(Wh.SelectDialogResult) = 0 then Exit;
    MemTableEh1.Edit;
    MemTableEh1.FieldByName('id_supplier').Value:= Wh.SelectDialogResult[0];
    Mth.PostAndEdit(MemTableEh1);
  end
  else if TCellButtonEh(Sender).Hint = '������� ���������' then begin
    //������� ���� ������ � �������� ������ ���������
    Wh.SelectDialogResult:=[];
    Wh.ExecReference(myfrm_R_Itm_Units, Self, [myfoDialog, myfoModal], id);
    SetPickLists;
    if Length(Wh.SelectDialogResult) = 0 then Exit;
    MemTableEh1.Edit;
    MemTableEh1.FieldByName('id_unit').Value:= Wh.SelectDialogResult[0];
    Mth.PostAndEdit(MemTableEh1);
  end;
end;


procedure TDlg_SuppliersMinPart.CellLinkClick(Grid: TCustomDBGridEh; Column: TColumnEh);
begin
  if (Column.FieldName = 'httplink')and(MemTableEh1.FieldByName('httplink').AsString <> '') then
    ShellExecute(Application.Handle, 'Open',
      PChar(MemTableEh1.FieldByName('httplink').AsString), nil, nil, SW_SHOWNORMAL)
end;


function TDlg_SuppliersMinPart.Save: Boolean;
var
  i, j: Integer;
  qmode: string;
begin
  Q.QBeginTrans(True);
  for i:= 0 to High(DeletedIds) do begin
    Q.QExecSql('delete from dv.namenom_supplier where id_pos_supplier = :id$i', [DeletedIds[i]]);
  end;
  //if IsDefaultChanged then
  Q.QExecSql('update dv.namenom_supplier set is_default = 0 where id_nomencl = :id$i', [id]);
  for i:=1 to MemTableEh1.RecordCount do begin
    MemTableEh1.RecNo:=i;
    qmode:=S.IIf(
      //����� ������, �������
      MemTableEh1.FieldByName('id').Value = null, 'i',
      //��������, ��� ��� ��������� ��������� - ������� (�� ���������� ���������, �� ����� �� ��� �������, � ���� �� �� �������, �� ������� ��������� ����������)
      S.IIf(A.InArray(MemTableEh1.FieldByName('id').Value, ChangedIds) or (MemTableEh1.FieldByName('is_default').AsInteger = 1), 'u',
      '')
    );
    if qmode <> '' then
      Q.QIUD(qmode, 'dv.namenom_supplier', '',
        'id_pos_supplier;id_nomencl;id_supplier;name_pos;artikul_sp;id_base_unit;base_unit_k;is_default;addcomment;httplink',
        [ MemTableEh1.FieldByName('id').Value,
          id,
          MemTableEh1.FieldByName('id_supplier').Value,
          MemTableEh1.FieldByName('name').Value,
          MemTableEh1.FieldByName('artikul_sp').Value,
          MemTableEh1.FieldByName('id_unit').Value,
          MemTableEh1.FieldByName('base_unit_k').Value,
          MemTableEh1.FieldByName('is_default').Value,
          MemTableEh1.FieldByName('addcomment').Value,
          MemTableEh1.FieldByName('httplink').Value
        ]
        );
  end;
  Result:=Q.PackageMode <> -1;
  Q.QCommitTrans;
end;

procedure TDlg_SuppliersMinPart.SetCellEditable;
//���������� ��� ��������� ������� ������ � �������� ����������� �������������� �����
//��������� ������� ReadOnly ��� ���� �������
begin
  if (Mode in [fView, fDelete])or(not MemTableEh1.Active) then Exit;
  DBGridEh1.Readonly:=(S.NNum(MemTableEh1.FieldByName('usedcnt').Value) > 0)and (FieldNameCurr<>'is_default');
end;

procedure TDlg_SuppliersMinPart.DBGridEh1ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
var
  i, j: Integer;
begin
  inherited;
  if (TColumnEh(Sender).Field.FieldName = 'is_default') and (TColumnEh(Sender).Field.Value = 1) then begin
    IsDefaultChanged:=True;
    for i := 0 to MemTableEh1.RecordsView.MemTableData.RecordsList.Count - 1 do
      if (MemTableEh1.RecNo <> i + 1)
        then MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['is_default', dvvValueEh] := 0
  end;
  MemTableEh1.RecordsView.MemTableData.RecordsList[MemTableEh1.RecNo-1].DataValues['baseunit', dvvValueEh] := AddParam[1];
end;


function TDlg_SuppliersMinPart.SetPickLists: Boolean;
begin
  Gh.SetGridColumnPickList(DBGridEh1, 'id_supplier',
    Q.QLoadToVarDynArray2(
      'select k.name_org, k.id_kontragent '+  //k.name_org
      'from dv.kontragent k, dv.kontragent_pri_kon_post kp '+
      'where k.id_kontragent = kp.id_kontragent (+) /*and kp.id_type = 1*/ '+
      'order by k.name_org', [])
      , 0, 1, True
  );
  Gh.SetGridColumnPickList(DBGridEh1, 'id_unit',
    Q.QLoadToVarDynArray2('select name_unit, id_unit from dv.unit order by name_unit', [])
    , 0, 1, True
  );
end;

function TDlg_SuppliersMinPart.InitGrid: Boolean;
var
  i, j: Integer;
  va2: TVarDynArray2;
begin
{  va2:=Q.QLoadToVarDynArray(
    'select id_supplier, id_supplier, name_pos, baseunitname, supplierunitname, base_unit_k from v_spl_namenom where id_nomencl = :id$i',
     [id]
    );}
  Mth.CreateTableGrid(
    DBGridEh1, True, False, False, False,[
    ['id', ftInteger, 0, 'id', 20, False, False, False],
    ['id_supplier', ftString, 1000, '���������', 200, True, True, True],
    ['name', ftString, 1000, '������������', 400, True, True, True],
    ['artikul_sp', ftString, 50, '�������', 100, True, True, True],
    ['baseunit', ftString, 50, '���. ��. ���.', 70, True, False, False],
    ['id_unit', ftString, 50, '��. ���.', 100, True, False, False],
    ['base_unit_k', ftFloat, 0, '�����.', 70, True, False, False],
    ['httplink', ftString, 4000, '������', 100, True, True, True],
    ['addcomment', ftString, 4000, '����������', 200, True, True, True],
    ['is_default', ftInteger, 0, '���.', 50, True, False, False],
    ['usedcnt', ftInteger, 0, '������������', 50, False, False, False]
    ],
    [], '', ''
  );
   //��������� ������ � ������ �����
  if Mode = fEdit then
    Gh.SetGridInCellButtons(DBGridEh1, 'id_supplier;id_unit', '���������;������� ���������', CellButtonClick);
  SetPickLists;
  Q.QLoadToMemTableEh(
    'select id_pos_supplier, id_supplier, name_pos, artikul_sp, baseunitname, id_base_unit, base_unit_k, httplink, addcomment, is_default, usedcnt '+
    'from v_spl_namenom where id_nomencl = :id$i',
    [id], MemTableEh1, '-');
  DBGridEh1.FindFieldColumn('httplink').CellDataIsLink:=True;
  DBGridEh1.FindFieldColumn('httplink').OnCellDataLinkClick:=CellLinkClick;
  FieldsReadOnly:='id;baseunit';
  FieldsNoRepaeted := 'id_supplier';   //!!!
  Gh.SetGridInCellCheckBoxes(DBGridEh1, 'is_default', '0;1');
  ColumnsVerifications:=['', '1:1000', '0:1000', '0:50', '', '1:50', '0.000000:1000000:5:N', '', '', '', ''];
  Result := True;
end;

procedure TDlg_SuppliersMinPart.DBGridEh1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;
  if MemTableEh1.RecordCount = 0 then Exit;
///  if (FieldNameCurr = 'name')and(Key = VK_F3) then begin
    //MemTableEh1.RecordsView.MemTableData.RecordsList[0].DataValues['baseunit', dvvValueEh] := AddParam[0];
{  if (FieldNameCurr = 'name')and(Key = VK_SPACE)and(MemTableEh1.FieldByName('name').AsString='') then begin
    Key:=0;
    MemTableEh1.Edit;
    MemTableEh1.FieldByName('name').Value:=AddParam[0];
    DBGridEh1.InplaceEditor.Text:=AddParam[0];

  end;}
end;

function TDlg_SuppliersMinPart.InitAdd: Boolean;
begin
  Caption := '��������� ��� ������������';
  InfoArr := [
    ['�������� ����������� �� ������� �������������� ��������.', Mode = fView],
    ['�������������� ����������� �� ������� �������������� ��������.'#13#10#13#10+
     '�� ������ ������� ����������� ��� ���� ������������ � ������ ���������.'#13#10+
     '��� ����� ������������ ��� ��������� �� ������ ������ � ��������������� ������� �������.'#13#10+
     '� ���� ��������� � ��.���. ����� ������ ������, �� ������� ��������� ��������������� ����������,'#13#10+
     '��� �� ������ ��������������� ������ ��� �������� ����� �������.'#13#10+
     ''#13#10+
     '��� ���������� ��� �������� ����� ����������� ������ ����� ����.'#13#10+
     '(������ �� ���������, ���� ���� � ����� ������ ������ ���� ������!)'#13#10+
     ''#13#10+
     '������ ����� ��������� (���� ��� ���������) ��� ������� ������ "��".'#13#10
    , Mode = fEdit]
  ];
  pnl_Top.Visible:=True;
  pnl_Bottom.Visible:=False;
  lbl_Caption.Caption := AddParam[0];
  Result := True;
end;

function TDlg_SuppliersMinPart.Prepare: Boolean;
begin
  Result := inherited;
  Cth.SetBtn(Bt_Cancel, mybtViewClose, False);
end;


end.


