{
���������� ����������� �������
���������� ����������� ������� �� ������, ��������� � ���������� � �����
��������� ����������� ��� ������� �� ������ ������
��������� ������� ��������������, ��������, ��������, ��������� � �������� �����
� ������� ��������� ������������� ����
}
unit uFrmOGrefOrStdItems;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2, uFrmBasicInput
  ;

type
  TFrmOGrefOrStdItems = class(TFrmBasicGrid2)
    procedure FormDestroy(Sender: TObject);
    procedure Timer_AfterStartTimer(Sender: TObject);
  private
    //���� �������, � �������� ����� �������������� �������
    ItemId: Integer;
    function  PrepareForm: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);  override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    procedure Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure SetCbEstimate;
    procedure CopyAllItems;
  public
    //�������� �����������, ���� �� �� ������, �� �������� ��� ������� ������� � ������� � ��� ������
    class procedure GoToItem(AId: integer);
  end;

var
  FrmOGrefOrStdItems: TFrmOGrefOrStdItems;

implementation

uses
  uWindows,
  uOrders,
  uFrmODedtOrStdItems
  ;

{$R *.dfm}

function TFrmOGrefOrStdItems.PrepareForm: Boolean;
begin
  FrmOGrefOrStdItems := Self;
  Caption:='���������� ����������� �������';
  Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['id_or_format_estimates','_id_format_est',''],
    ['wo_estimate','_wo_estimate',''],
    ['name','������������','500;h'],
    ['price$f','����','70','f=r','e=0:999999999:2',User.Role(rOr_R_StdItems_Ch)],
    ['price_pp$f','�����������','70','f=r','e=0:999999999:2',User.Role(rOr_R_StdItems_Ch)],
    ['priceraw$f','���� �� �����','70','f=r'],
    ['route2','���������������� �������','120'],
    ['dt_estimate','�����','75'],
    ['by_sgp','���� �� ���','40','pic']
  ]);
  Frg1.Opt.SetTable('v_or_std_items');
  Frg1.Opt.SetWhere('where id_or_format_estimates = :id_or_format_estimates$i');
  Frg1.Opt.SetButtons(1,[[btnRefresh],[],[btnView],[btnEdit,User.Role(rOr_R_StdItems_Ch)],[btnAdd,1],[btnCopy,1],[btnDelete,1],[],
    [btnViewEstimate],[btnLoadEstimate,User.Role(rOr_R_StdItems_Estimate)],[-btnCopyEstimate,1,'����������� �����'],[-btnDeleteEstimate,1],[],
    [-btnCustom_RepOrStDItemsErr, True, '����� ������'],[],[btnGridSettings],[],[btnCtlPanel],[],[1000, User.Role(rOr_R_StdItems_Ch), '����������� ������� ��...', 'copy']]
  );
  Frg1.CreateAddControls('1', cntComboLK, '������:', 'CbEstimate', '', 80, yrefC, 400);
  SetCbEstimate;
  Frg1.InfoArray:=[
    [Caption + '.'#13#10+
    '� ������� ����� � ���������� ������ �������� ������, ��� �������� �� ������ ����������� ��� ������������� ����������� ������� '#13#10+
    '(��� ������� ������ ���� �������������� ��������� � ����������� ����������� ������� ���������).'#13#10+
    '� ������� ������ ��� ���� ��� �������� ������ ��� ��������, ���������, ����������� ����������� �������,'#13#10+
    '� ������� �� ������������ � ���������.'#13#10+
    '���� ������� ������� � ���� ����������� � ��� ������� �� ����� ������������ �� �������� �������, �'#13#10+
    '��������������� ������� �������� ���� � ������ �������'#13#10+
    '(���� ����������� �� ����� ���� ����� ���� �������, � � ������ �������������� ������������, ��� ���� �����).'#13#10+
    '���� �� ����� �������������� �� ������ ��� (���� � ����� ���� �������, ��� �� ���������������).'#13#10+
    '������������ ������� �� ����� ��������� � �������������� �������������� ������������, � �� ����� ����������� ������ ������ �������.'#13#10+
    '� ��� ������� ������������ � �������� ������� ������, � � ��� ����������� ��������, ����������� ����� � ���������� ����������� ������� ���������.'#13#10+
    '��� �������������� �������, � ����� ������� �� ���� ����� ��������� ������� ����� ���������,'#13#10+
    '����� ��������� � ���� ������ �������� ������������� ������ �������������� ������� � � ���.'#13#10
    ]
  ];
  Result := inherited;
end;

procedure TFrmOGrefOrStdItems.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if fMode <> fNone then begin
    if (S.NNum(Fr.GetControlValue('CbEstimate')) < 0)  then
      Exit;
    if Fr.IsEmpty and (fMode <> fAdd) then
      Exit;
if Fr.GetControlValue('CbEstimate') = 35 then                                             //!!!
TFrmODedtOrStdItems.Show(Self, 'dddd', [myfoDialog], fMode, Fr.ID, Fr.GetControlValue('CbEstimate'))
else
    Wh.ExecDialog(myfrm_Dlg_R_OrderStdItems, Self, [], fMode, Fr.ID, Fr.GetControlValue('CbEstimate'));
  end
  else if Tag = btnCustom_RepOrStDItemsErr then begin
    Wh.ExecReference(myfrm_Rep_OrderStdItems_Err)
  end
  else if Tag = btnCopyEstimate then begin
    Orders.CopyEstimateToBuffer(Fr.ID, null);
  end
  else if (Tag = btnViewEstimate) then begin
    //� ����������� ����������� ������� ������� ����� (���� ��� �� ������ ����� �������)
    if (Fr.GetCol > 0)and(Fr.GetValueI('id_or_format_estimates') > 0) then
      Wh.ExecReference(myfrm_R_Estimate, Self, [myfoDialog, myfoMultiCopyWoId, myfoSizeable, myfoEnableMaximize], VarArrayOf([null, Fr.ID]));
  end
  else if (Tag = btnLoadEstimate) then begin
    //� ����������� ����������� ������� �������� ����� (���� ��� �� ������ ����� �������)
    if (Fr.GetCol > 0)and(Fr.GetValueI('id_or_format_estimates') > 0) then begin
      Orders.LoadBcadGroups(True);
      Orders.LoadEstimate(null, null, Fr.ID);
      Fr.RefreshGrid;
    end;
  end
  else if (Tag = btnDeleteEstimate) then begin
    //� ����������� ����������� ������� ������ ����� (���� ��� �� ������ ����� �������)
    if (Fr.GetCol > 0)and(Fr.GetValueI('id_or_format_estimates') > 0) then begin
      Orders.RemoveEstimateForStdItem(Fr.ID);
      Fr.RefreshGrid;
    end;
  end
  else if Tag = 1000 then begin
    CopyAllItems;
  end
  else
    inherited;
end;

procedure TFrmOGrefOrStdItems.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
  if Fr.IsPrepared then
    Fr.RefreshGrid;
end;

procedure TFrmOGrefOrStdItems.Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  Fr.SetSqlParameters('id_or_format_estimates$i', [Cth.GetControlValue(Fr, 'CbEstimate')]);
end;

procedure TFrmOGrefOrStdItems.FormDestroy(Sender: TObject);
begin
  inherited;
  FrmOGrefOrStdItems := nil;
end;

procedure TFrmOGrefOrStdItems.Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
begin
  //������� ���� (���� 'price', 'price_pp')
  Q.QCallStoredProc('P_SetStdItemPrice', 'IdStdItem$i;PriceNew$f;PriceType$i',
    [Fr.ID, S.NNum(Value), S.Decode([FieldName, 'price', 1, 2])]
  );
end;

procedure TFrmOGrefOrStdItems.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if (Fr.IsEmpty) or (Fr.GetControlValue('CbEstimate') = -1) then
    Exit;
  if Fr.GetControlValue('CbEstimate') = 0 then begin
    if FieldName <> 'name' then
      Params.Background := RGB(255, 150, 150);
    Exit;
  end;
  if (FieldName = 'dt_estimate') then
    if (Fr.GetValue('dt_estimate') = null)
      then Params.Background := clmyPink  //������� - �� ���������� �����
      else if (Fr.GetValueI('wo_estimate') = 1)
        then Params.Background := clmyYelow;  //������ - ����� ������ (�� �����)
end;

procedure TFrmOGrefOrStdItems.SetCbEstimate;
var
  i: Integer;
  st: string;
begin
  //��������� �������� � ���� ������ - ���������; 0 - ����� ������
  Q.QLoadToDBComboBoxEh(
    'select f.name || '' ['' || e.name || '']'' as estimate, e.id as id '+
    'from or_formats f, or_format_estimates e '+
    'where e.id_format = f.id and e.active = 1 and f.active = 1 and ((e.id_format > 1)or(e.id_format = 0))'+
    'order by 1 asc',
    [], TDBComboBoxEh(Frg1.FindComponent('CbEstimate')), cntComboLK
  );
  TDBComboBoxEh(Frg1.FindComponent('CbEstimate')).ItemIndex:=0;  //����� � ������ ������� ������� � ������������, ���� �������� ���������� �� ������� �� ��, ��� �� ��� ������ ����� ��������� �������
end;

procedure TFrmOGrefOrStdItems.Timer_AfterStartTimer(Sender: TObject);
begin
  inherited;
  if ItemId = 0 then
    Exit;
  FrmOGrefOrStdItems.Frg1.DbGridEh1.SetFocus;
  FrmOGrefOrStdItems.Frg1.MemTableEh1.Locate('id', ItemId, []);
end;

class procedure TFrmOGrefOrStdItems.GoToItem(AId: integer);
//�������� �����������, ���� �� �� ������, �� �������� ��� ������� ������� � ������� � ��� ������
var
  va: TVarDynArray;
begin
  if AID = null then
    Exit;
  //������� ������ ��� ������� �� ��� ����, ���� �� ������� ��� ��� ���������� (0) - ������
  va := Q.QSelectOneRow('select id_or_format_estimates from or_std_items where id = :id$i', [AId]);
  if S.NNum(va[0]) = 0 then
    Exit;
  if FrmOGrefOrStdItems = nil then
    Wh.ExecReference(myfrm_R_OrderStdItems);
  FrmOGrefOrStdItems.Frg1.SetControlValue('CbEstimate', va[0]);
  FrmOGrefOrStdItems.ItemId := AId;
  FrmOGrefOrStdItems.Frg1.DbGridEh1.SetFocus;
  FrmOGrefOrStdItems.Frg1.MemTableEh1.Locate('id', AID, []);
end;

procedure TFrmOGrefOrStdItems.CopyAllItems;
var
  va, vak, vav: TVarDynArray;
  va2, va3: TVarDynArray2;
  i, j, gr: Integer;
  Fields: string;
begin
  gr := S.NInt(Frg1.GetControlValue('CbEstimate'));
  if gr <= 1 then
    Exit;  //��� ������������ ������� (������ �����) � ��� ������������ ����������� �����������
  va2 := Q.QLoadToVarDynArray2('select f.name || '' ['' || e.name || '']'' as estimate, e.id as id ' + 'from or_formats f, or_format_estimates e ' + 'where e.id_format > 1 and e.id_format = f.id and e.active = 1 and f.active = 1 ' + 'and e.id <>:id$i ' + 'order by 1 asc', [gr]);
  va := [];
  vak := [];
  vav := [];
  for i := 0 to High(va2) do begin
    vav := vav + [va2[i][0]];
    vak := vak + [va2[i][1]];
  end;
  if Length(vav) = 0 then
    Exit;
  if TFrmBasicInput.ShowDialog(Self, '', [], fAdd, '~����������� ����������� �������', 300, 80,
   [[cntComboLK, '��������', '1:400:0', 210]], [VarArrayOf([vak[0], VarArrayOf(vav), VarArrayOf(vak)])], va, [['']], nil) >= 0 then begin
    Fields := 'id$i;id_or_format_estimates$i;name$s;r1$i;r2$i;r3$i;r4$i;r5$i;r6$i;r7$i;r8$i;r9$i;resale$i;price$f;price_pp$f;setofpan$i';
    if MyQuestionMessage('����� ����������� ������� �� �����������'#13#10 + '"' + vav[A.PosInArray(va[0], vak)] + '"'#13#10 + '(����� ���, ��� ��� ����������).'#13#10'����������?') <> mrYes then
      Exit;
    va2 := Q.QLoadToVarDynArray2(Q.QSIUDSql('A', 'or_std_items', Fields) + ' where id_or_format_estimates = :ide$i', [va[0]]);
    for i := 0 to High(va2) do begin
      j := Q.QSelectOneRow('select count(*) from or_std_items where lower(name) = lower(:name$s) and id_or_format_estimates = :ide$i', [va2[i][2], gr])[0];
      if j > 0 then
        Continue;
      va2[i][1] := gr;
      Q.QIUD('i', 'or_std_items', '', Fields, TVarDynArray(va2[i]));
      Frg1.RefreshGrid;
    end;
  end;
end;


end.
