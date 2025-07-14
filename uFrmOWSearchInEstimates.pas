{
����� ������� ������� � ������ ������������ ������� � �������,
������� ��������, ��� �� ����� � ������� ������.
�� ��������� ������� � �����.
}
unit uFrmOWSearchInEstimates;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  GridsEh, DBAxisGridsEh, DBGridEh, PropFilerEh, PropStorageEh, Math,
  Mask, Types, DBCtrlsEh, ExtCtrls, DateUtils, ClipBrd, Vcl.ComCtrls, MemTableEh,
  uLabelColors, uFrmBasicMdi, uFrDBGridEh, uData, uForms, uString
  ;

type
  TFrmOWSearchInEstimates = class(TFrmBasicMdi)
    edt_name: TDBEditEh;
    chbInclosedOrders: TCheckBox;
    chbLike: TCheckBox;
    pgcResults: TPageControl;
    tsStdItems: TTabSheet;
    tsOrderItems: TTabSheet;
    Frg1: TFrDBGridEh;
    Frg2: TFrDBGridEh;
    procedure FormCreate(Sender: TObject);
  private
    function  Prepare: Boolean; override;
    procedure btnClick(Sender: TObject); override;
    procedure Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
    procedure Frg2CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
  public
  end;

var
  FrmOWSearchInEstimates: TFrmOWSearchInEstimates;

implementation

uses
  uOrders,
  uWindows
  ;


{$R *.dfm}

procedure TFrmOWSearchInEstimates.FormCreate(Sender: TObject);
begin
  inherited;
{  //���������� ������������ � ������� (� � ����������� ����� ��������� alNone), ����� �� ������� ��������
  exit;
  Frg1.Align := alNone;
  Frg1.Align := alClient;
  Frg2.Align := alNone;
  Frg2.Align := alClient;}
end;

function  TFrmOWSearchInEstimates.Prepare: Boolean;
begin
  Result := False;
  Mode := fView;
  Caption := '~����� ������� �������';
  FOpt.DlgPanelStyle:= dpsBottomRight;
  Cth.MakePanelsFlat(pnlFrmClient, []);
  FOpt.DlgButtonsR:=[[mbtFind, True, '�����']];
  FOpt.StatusBarMode:=stbmNone;
  //���� ����������� �������
  Frg1.Options := FrDBGridOptionDef + [myogPrintGrid, myogPanelFind];
  Frg1.Opt.SetFields([
    ['id_std_item$i', '_id_std_item', '40'],
    ['id_estimate$i', '_id_estimate', '40'],
    ['formatname$s', '������', '120;w','bt=����������� �����:29'],
    ['stdname$s', '����������� �������', '300;w','bt=��������� �����:28', User.Role(rOr_R_StdItems_Estimate)]
  ]);
  Frg1.SetInitData([], '');
  Frg1.OnCellButtonClick := Frg1CellButtonClick;
  Frg1.Prepare;
  Frg1.RefreshGrid;
  //���� �������
  Frg2.Options := FrDBGridOptionDef + [myogPrintGrid, myogPanelFind];
  Frg2.Opt.SetFields([
    ['id_order_item$i', '_id_order_item', '40'],
    ['id_estimate$i', '_id_estimate', '40'],
    ['slash$s', '�����', '120;w','bt=����������� �����:29'],
    ['itemname$s', '�������', '300;w','bt=��������� �����:28', User.Role(rOr_D_Order_Estimate)],
    ['std$i', '���.', '60', 'pic'],
    ['end$i', '����.', '60', 'pic']
  ]);
  Frg2.SetInitData([], '');
  Frg2.OnCellButtonClick := Frg2CellButtonClick;
  Frg2.Prepare;
  Frg2.RefreshGrid;
  //�� ���� ���������� - ����� ��������, ������ ��� ������ �����
  FOpt.ControlsWoAligment := [Frg1, Frg2];
//  pgcResults.ActivePageIndex := 0;
  //����������� ������� ����� (������ ����, ������ ������������ ������� ������)
  FWHBounds.Y:= 400;
  FWHBounds.X:=500;
  //���������
  FOpt.InfoArray:=[[
    '����� ������������ � ������.'#13#10+
    ''#13#10+
    '������� ������������, ������� �� ������ �����,'#13#10+
    '� ������� ������ "�����" ��� ������.'#13#10+
    ''#13#10+
    '����� ����� ���������� � ������ ������������ �������, � � ������ �� �������� �������,'#13#10+
    '(��� � ������ �����������, ��� � ������������� �������)'#13#10+
    '���������� ����������� � ��������������� ��������.'#13#10+
    ''#13#10+
    '��� ������ ������� � ����� �������, ������� ��� �������, ���������� ��������� �������������� �������'#13#10+
    '(����� ���� ������ � ������������� �������)'#13#10+
    ''#13#10+
    '���� �� ����������� ������� "������ �� �����", �� ������� � ������ ������ �� ������� ���������� �� �������.'#13#10+
    '���� �� ��� ������� �����������, �� ����� ������������ ������� ����������� ��� ������.'#13#10+
    '������� "_" �������� ����� ������ � ������� ������, � "%" - ����� ���������� ����� ��������.'#13#10+
    '�����: ���� �������� ����������� ���, �� ������ ����� ������, � �� ��� ���������!'#13#10+
    '�����, � ���� ������ ����� ������������ ��� ����� �������� ����.'#13#10+
    '(��������, ������ ������ ����� �������� ���: %����% (����� ������� ��� ������ � ���������� "����"), ��� �������__ ) '#13#10+
    '��� ���: �������__  (����� ������� "�������12", "������� S")'#13#10+
    ''#13#10+
    '� ��������� ������ �� �������� ����� � ������� �� ������� "�������" (��� "����������� �������).'#13#10+
    '����� ������ �������� ����� (���� � ��� ���� ����� �������, � ���� �����, � ������� ������� �������, �� ��������).'#13#10+
    '�� �������� ����� � � ������ �������� ��������� �������� �����.'
  ]];
  Result := True;
end;

procedure TFrmOWSearchInEstimates.btnClick(Sender: TObject);
var
  Wherest: string;
begin
  if TControl(Sender).Tag = mbtFind then begin
    if edt_name.Text = '' then
      Exit;
    Wherest:= S.IIf(chbLike.Checked, 'upper(bcadname) like upper(:name)', 'bcadname = :name');
    Frg1.LoadData(
      'select id_std_item, id_estimate, formatname, stdname from v_findinestimate_std where ' + wherest + ' order by formatname, stdname',
      [edt_name.Text]
    );
    Frg2.LoadData(
      'select id_order_item, id_estimate, slash, itemname, std, nvl2(dt_end, 1, 0) as end from v_findinestimate_inorders where ' +
      Wherest +
      S.IIf(not chbInclosedOrders.Checked, ' and dt_end is null ', ' ') +
      ' order by slash, itemname',
      [edt_name.Text]
    );
  end;
end;

procedure TFrmOWSearchInEstimates.Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
  //��� ������������ �������
  if TCellButtonEh(Sender).Hint = '��������� �����'  then begin
    Orders.LoadBcadGroups(True);
    Orders.LoadEstimate(null, null, Frg1.GetValueI('id_std_item'))
  end
  else
    Wh.ExecReference(myfrm_R_Estimate, Self, [myfoDialog, myfoMultiCopyWoId, myfoSizeable, myfoEnableMaximize], VarArrayOf([null, Frg1.GetValueI('id_std_item')]));
end;

procedure TFrmOWSearchInEstimates.Frg2CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
  //��� ������� � ������ (�������� ������ ��� �������������� �������)
  if TCellButtonEh(Sender).Hint = '��������� �����'  then begin
    Orders.LoadBcadGroups(True);
    Orders.LoadEstimate(null, Frg2.GetValueI('id_order_item'), null)
  end
  else
    Wh.ExecReference(myfrm_R_Estimate, Self, [myfoDialog, myfoMultiCopyWoId, myfoSizeable, myfoEnableMaximize], VarArrayOf([Frg2.GetValueI('id_order_item'), null]));
end;

end.

{
������ ����� � ���������� ������ ���� ������ ��� ���������� ���������� �� �������, ����� �������� ������!!!
}