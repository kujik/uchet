{
������� ��������� ���������� �� ��������� ���������� ��� ������ ��������� ��� �� ����������� ��������
}
unit uFrmOGinfSgp;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uLabelColors
  ;

type
  TFrmOGinfSgp = class(TFrmBasicGrid2)
    lblCaption: TLabel;
  private
    function  PrepareForm: Boolean; override;
    procedure Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
  public
  end;

var
  FrmOGinfSgp: TFrmOGinfSgp;

implementation

uses
  uWindows
  ;

{$R *.dfm}

function TFrmOGinfSgp.PrepareForm: Boolean;
var
  i, j: integer;
  va: TVarDynArray;
  FldDef: TVarDynArray2;
begin
  Mode := fView;
  FOpt.DlgPanelStyle := dpsBottomRight;
  //��������� �����
  Caption := S.Decode([
     FormDoc,
     myfrm_Dlg_Sgp_InfoGrid_PspSell, '����������� �������� �� �������.',
     myfrm_Dlg_Sgp_InfoGrid_PspProd, '���������������� �������� �� �������.',
     myfrm_Dlg_Sgp_InfoGrid_Shipped, '�������� ������� � ���.',
     myfrm_Dlg_Sgp_InfoGrid_Registered, '������� ������� �� ���.',
     myfrm_Dlg_Sgp_InfoGrid_Shipped_Plan, '�������� �����������.',
     myfrm_Dlg_Sgp_InfoGrid_In_Prod, '� ������������.',
     myfrm_Dlg_Sgp_InfoGrid_Move, '�������� �� �������.',
     '����������'
  ]);
  //������������ ����� - ������������ ���������� ��� ����������� �������
  va:= Q.QSelectOneRow('select slash, name from v_sgp_sell_items where id = :id$i', [ID]);
  lblCaption.SetCaption2('$FF0000 ' + S.NSt(va[0]) + ' $000000 ' + S.NSt(va[1]));

  FldDef := [
    ['id_order','_id','40'],
    ['dt_end','_dt_end','40'],
    ['slash','�����','120;w','bt=�������'],
    ['dt_beg','��������','75'],
    ['dt_otgr','�������� ����','75']
  ];
  Frg1.Opt.SetWhere('where id = :id$i order by dt_beg desc');

  if FormDoc = myfrm_Dlg_Sgp_InfoGrid_PspSell then begin
    //���������� �� ����������� ���������, �����-���� ����������� �� ������ �������
    Frg1.Opt.SetFields(FldDef + [
      ['qnt','���-��','80','f=f:']
    ]);
    Frg1.Opt.SetTable('v_sgp_by_psp_sell_list');
    Frg1.InfoArray:=[];
  end
  else if FormDoc = myfrm_Dlg_Sgp_InfoGrid_PspProd then begin
    //���������� �� ���������������� ���������, �����-���� ����������� �� ������ �������
    Frg1.Opt.SetFields(FldDef + [
      ['qnt','���-��','80','f=f:']
    ]);
    Frg1.Opt.SetTable('v_sgp_by_psp_prod_list');
  end
  else if FormDoc = myfrm_Dlg_Sgp_InfoGrid_Shipped then begin
    //���������� �� �������� � ���
    Frg1.Opt.SetFields(FldDef + [
      ['dt','�������� ����','75'],
      ['qnt','���-��','80','f=f:']
    ]);
    Frg1.Opt.SetTable('v_sgp_shipped_list');
  end
  else if FormDoc = myfrm_Dlg_Sgp_InfoGrid_Registered then begin
    //���������� �� ������� �� ���
    Frg1.Opt.SetFields(FldDef + [
      ['dt','���� �������','75'],
      ['qnt','���-��','80','f=f:']
    ]);
    Frg1.Opt.SetTable('v_sgp_registered_list');
  end
  else if FormDoc = myfrm_Dlg_Sgp_InfoGrid_In_Prod then begin
    //���������� �� �������� � ������������
    Frg1.Opt.SetFields(FldDef + [
      ['qnt_in_order','���-�� �����','75'],
      ['qnt','���-�� � ������������','75','f=f:']
    ]);
    Frg1.Opt.SetTable('v_sgp_in_prod_list');
  end
  else if FormDoc = myfrm_Dlg_Sgp_InfoGrid_Move then begin
    //���������� ����� �� �������� �������
    Frg1.Opt.SetFields([
      ['id_order','_id','40'],
      ['dt_end','_dt_end','40'],
      ['doctype','��� ���������','130;w'],
      ['slash','��������','120;w','bt=�������'],
      ['dt_beg','��������','75'],
      ['dt_otgr','�������� ����','75'],
      ['dt','���� �������','75'],
      ['qnt','���-��','75','f=f:']
    ]);
    Frg1.Opt.SetTable('v_sgp_move_list');
    Frg1.Opt.SetWhere('where id = :id$i order by dt_beg desc, id_order desc');
  end;
  Result := Inherited;
end;

procedure TFrmOGinfSgp.Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
//���� �� ������ � ������
var
  IdOrder: Variant;
begin
  //������ ��� ������ �������
  if Fr.IsEmpty then
    Exit;
  //������� ���� ������ � �����
  IdOrder := null;
  if Fr.DBGridEh1.FindFieldColumn('id_order') <> nil then
    IdOrder := Fr.GetValue('id_order');
  if (Fr.DBGridEh1.FindFieldColumn('doctype') <> nil) and (Pos('�������', Fr.GetValueS('doctype')) = 0) then
    IdOrder := null;
  //������� ������� ������ ��� �����
  if IdOrder <> null then
    if TCellButtonEh(Sender).Hint = '�������' then
      Wh.ExecDialog(myfrm_Dlg_Order, Self, [], fView, IdOrder, null);
end;

procedure TFrmOGinfSgp.Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  Fr.SetSqlParameters('id$i', [ID]);
end;


end.
