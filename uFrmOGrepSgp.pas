unit uFrmOGrepSgp;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2, uFrmBasicInput
  ;

type
  TFrmOGrepSgp = class(TFrmBasicGrid2)
  private
    FFormats: TVarDynArray2;          //������ �������� ��������� ��� ����������� ������ ���
    FIdFormat: Variant;
    function  PrepareForm: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);  override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    procedure Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
  public
  end;

var
  FrmOGrepSgp: TFrmOGrepSgp;

implementation

uses
  uWindows,
  uFrmOGinfSgp
  ;

{$R *.dfm}

function TFrmOGrepSgp.PrepareForm: Boolean;
begin
  Caption:= '��������� ��� (����������� �������)';
  Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['slash','����','110'],
    ['name','�������','300;h'],
    ['qnt_psp_sell','�������� �����','80'],
    ['qnt_psp_prod','�������� � ������������','80'],
    ['qnt_sgp_registered','������� �� ��� �����','80'],
    ['qnt_shipped','��������� �����','80'],
    ['qnt','������� �������','80'],
    ['qnt_in_prod','� ������������','80'],
    ['qnt_to_shipped','�������� ����','80'],
    ['qnt_min','����������� �������','80','e=0:9999999:0',User.Role(rOr_Rep_Sgp_Ch1)], //������ ���������
    ['qnt_need','������� / �����������','80'],
    ['price','���� �������','80','f=r','i',not User.Role(rOr_Rep_Sgp_ViewPrice)],
    ['summ','����� �������','80','f=r:','i',not User.Role(rOr_Rep_Sgp_ViewPrice)],
    ['priceraw','���� �� �����','80','f=r','i',not User.Role(rOr_Rep_Sgp_ViewPrice)],
    ['sumraw','����� �� �����','80','f=r:','i',not User.Role(rOr_Rep_Sgp_ViewPrice)]
  ]);
  Frg1.Opt.SetTable('v_sgp_items');
  Frg1.Opt.SetWhere('where id_format_est = :id_format_est$i');
  Frg1.Opt.SetButtons(1,[[mbtRefresh],[],[-mbtCustom_Revision,User.Role(rOr_Rep_Sgp_Rev),'�������'],[-mbtCustom_JRevisions,1,'������ �������'],[],[mbtGridSettings],[],[mbtCtlPanel]]);
  Frg1.Opt.SetButtonsIfEmpty([mbtCustom_JRevisions]);
  Frg1.CreateAddControls('1', cntComboLK, '������:', 'CbFormat', '', 50, yrefC, 400);
  FFormats:=Q.QLoadToVarDynArray2('select name, id from v_sgp_sell_formats order by name', []);
  Cth.AddToComboBoxEh(TDBComboBoxEh(Frg1.FindComponent('CbFormat')), FFormats);
  TDBComboBoxEh(Frg1.FindComponent('CbFormat')).ItemIndex := 0;
  FIdFormat:= Frg1.GetControlValue('CbFormat');
  Frg1.InfoArray:=[
    [Caption + '.'#13#10#13#10],[
      '� ������� ������������ � �� ��� �������������� ��������� ������ ������� ��������� � ������� '#13#10+
      '���������� ������� ��������� (����������� �������, ��� �� ��).'#13#10+
      '����� ������� � ������� ����� ������������ � ������ �������, ���������� ��������.'#13#10+
      ''#13#10+
      '��� ����������� ������� ��� ������� �������� ��� � ���������� ������ ������.'#13#10+
      '�� ��������� � ���� ���� ����� � �� ������������� ��������� ����, � ���� ������� ��������� ����� ������� ���������!'#13#10+
      '������� ����������� �������, ������ ������ �������� ������, � �������� �� ���.'#13#10+
      ''#13#10+
      '������ ����������� �� ��������� �������� ������� (�� ������� �������), ������� ������� �� ���, ������� �������� � ���,'#13#10+
      '� ����� ���������� �������� ������.'#13#10+
      ''#13#10+
      '������ �� ����� ����������� ��� ��������� ������ ������� �� ����� ��� �� ���������������� �������, ������ �� ���������������� ���������.'#13#10+
      '������, ���������� �������, �� ����������� �������� � ������� ��������� �������, �� ������� �������� � ���.'#13#10+
      '������������� ������� ����� ����������������� � ������������ ���������� ������������ �� �� ������������!'#13#10+
      '(������� �� �����������)'#13#10+
      ''#13#10+
      '�������������� ������ � ������� ������������ ��������� '#13#10+
      '"�������� �����", "�������� � ������������", "� ������������", "�������� ����.", "���. �������"'#13#10+
      '����������� ����� "�����������" ���������� ������� �������� ������� ���� �������� "� ������������" �� �������'#13#10+
      '����������� ��������. ��� ����� �������������, ���� �� ������ ��������� ����� ��� �������� ��� ���� ��������, ���� �� ��� �� �������, '#13#10+
      '�������� ����� ������������� � ��������� ������� ������.'#13#10+
      ''#13#10+
      '�������� � ����� "����������� �������" �������� � ���� �� ������� ������� � �������� ����������.'#13#10+
      ''#13#10+
      '����� �������� ������� ������, �������������� ��������������� ������� ����������� ���� � �������.'#13#10+
      '����� ����� ���� ����� ����������� � ������ �������.'#13#10+
      ''#13#10+
      '������� ���� ������ �� ������, ��� �������, ��������� ���� ����������� �� ������� ��� ������� �� ������� ������, �� ���������, ������� ����������� �������.'#13#10
    ]];
  Frg1.Opt.ColumnsInfo:=[
    ['slash', '���� �������, ���������� �� ������ ������ ������� ��������, ���� ������� ������ ��� ������� �������. '+
     '���� ����� �� �������, ��� ������� ������� ��� � ���� �������, �� ���� ��������� ������.'],
    ['name', '������������ �������, ��� ��� ������ � ������ ����������� �������, ��� �������� ���� �������. ��� ������������� ����������� � ���������������� ��������� ������������ �� ������������.'],
    ['qnt_psp_sell', '����������, ������� ����� ������� ���� �������� �� ����������� ��������� (�.�. �� ���������� � ���� ��������) �� ���� �������� ������'],
    ['qnt_psp_prod', '����������, ������� ����� ������� ���� �������� �� ���������������� ��������� �� ���� �������� ������'],
    ['qnt_sgp_registered', '������� ������� ������� �� ��� �� ��������������� ���������'],
    ['qnt_shipped', '������� ������� ��������� �� ���������������� ���������'],
    ['qnt', '������� ��������� ���������� ������� �� ������.'#13#10'�������� �������� �������� �� ��� �� ���������������� � ����������� � ��� �� ����������� ���������'#13#10+
    '����� ����� ����������� ��������� �� ��������� ������� ���� ������� � �������� ��/� ���.'#13#10'�� ��������� �� ������ ���������� �������� �� ������ ��� � ������� ������� �������.'+
    ''],
    ['qnt_in_prod', '���������� �������, ����������� ������ � ������������ (��� ���������� � ������� �� ���������� ���������������� ��������� �� ��������, ������� ��� �� ���� ������������ �� ���.)'],
    ['qnt_to_shipped', '�������� ����. ���������� ������� �� ����������� ���������, ������� ��� �� ���� ��������� � ���'],
    ['qnt_min', '����������� ����������, ������� ��������� ������������ �� ������. �������� ���������������� � ������ �������. ����� ���������� �������, �� ������ ������ �� ������.'],
    ['qnt_need', '������ �������� ���������� �� ������, � ��������� ���������� "� ������������", � �� ������� ���������� "� ��������".'+
    '������������� ����� �������, ������������� �������� (��������������) ��������, ��� ���������� �� ������ � ������� ���������� � ������������ �� ������� ��� ��������������� ��������.'],
    ['price', '���� ������� �� ����������� ����������� ������� (�� ��������).'],
    ['summ', '��������� �������� ������� ������� �� ���. ���� ������� �� ����������� ����������� ������� (�� ��������).'],
    ['priceraw', '���� �� ����� ��������������� ������� �� ������ ���������������� �������, ������ �� ���.'],
    ['sumraw', '��������� �� ����� �������� ������� ������� �� ���.']
  ];
  Result := inherited;
end;

procedure TFrmOGrepSgp.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if Tag = mbtCustom_Revision then begin
    //������� ��� �� �������
    Wh.ExecDialog(myfrm_Dlg_Sgp_Revision, Self, [], fEdit, FIdFormat, null);
  end
  else if Tag = mbtCustom_JRevisions then begin
    //������ ����� ��������/������������� �� ������� �������
    Wh.ExecReference(myfrm_J_Sgp_Acts, Self, [], FIdFormat);
  end
  else inherited;
end;

procedure TFrmOGrepSgp.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
  if Fr.IsPrepared then
    Fr.RefreshGrid;
end;

procedure TFrmOGrepSgp.Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  FIdFormat:= Fr.GetControlValue('CbFormat');
  Fr.SetSqlParameters('id_format_est$i', [FIdFormat]);
end;

procedure TFrmOGrepSgp.Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
begin
  Q.QCallStoredProc('p_SetSgpItemAdd', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([Fr.ID, 1, S.NullIfEmpty(Value)]));
end;

procedure TFrmOGrepSgp.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if FieldName = 'qnt_need' then begin
    if (Fr.GetValueF('qnt_need') < 0) then
      Params.Background :=clmyPink;  //�������
  end;
end;

procedure TFrmOGrepSgp.Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
  if Fr.CurrField = 'qnt_psp_sell' then
    TFrmOGinfSgp.Show(Self, myfrm_Dlg_Sgp_InfoGrid_PspSell, [myfoMultiCopy, myfoSizeable, myfoDialog], fView, Fr.ID, null)
  else if Fr.CurrField = 'qnt_psp_prod' then
    TFrmOGinfSgp.Show(Self, myfrm_Dlg_Sgp_InfoGrid_PspProd, [myfoMultiCopy, myfoSizeable, myfoDialog], fView, Fr.ID, null)
  else if Fr.CurrField = 'qnt_shipped' then
    TFrmOGinfSgp.Show(Self, myfrm_Dlg_Sgp_InfoGrid_Shipped, [myfoMultiCopy, myfoSizeable, myfoDialog], fView, Fr.ID, null)
  else if Fr.CurrField = 'qnt_sgp_registered' then
    TFrmOGinfSgp.Show(Self, myfrm_Dlg_Sgp_InfoGrid_Registered, [myfoMultiCopy, myfoSizeable, myfoDialog], fView, Fr.ID, null)
  else if Fr.CurrField = 'qnt_to_shipped' then
    TFrmOGinfSgp.Show(Self, myfrm_Dlg_Sgp_InfoGrid_Shipped_Plan, [myfoMultiCopy, myfoSizeable, myfoDialog], fView, Fr.ID, null)
  else if Fr.CurrField = 'qnt_in_prod' then
    TFrmOGinfSgp.Show(Self, myfrm_Dlg_Sgp_InfoGrid_In_Prod, [myfoMultiCopy, myfoSizeable, myfoDialog], fView, Fr.ID, null)
  else if Fr.CurrField = 'qnt' then
    TFrmOGinfSgp.Show(Self, myfrm_Dlg_Sgp_InfoGrid_Move, [myfoMultiCopy, myfoSizeable, myfoDialog], fView, Fr.ID, null);
end;


end.
