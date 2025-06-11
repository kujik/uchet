{
����� ������� ������� � ������ ����������� ������� � ������������� ������� (����������)
}
unit D_Or_FindNameInEstimates;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_MDI, Vcl.ExtCtrls, Vcl.ComCtrls, System.Types,
  Vcl.Buttons, Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh, DBGridEhGrouping, ToolCtrlsEh,
  DBGridEhToolCtrls, DynVarsEh, MemTableDataEh, Data.DB, MemTableEh, EhLibVCL,
  GridsEh, DBAxisGridsEh, DBGridEh, Data.Win.ADODB, DataDriverEh,
  ADODataDriverEh, Vcl.DBCtrls;

type
  TDlg_Or_FindNameInEstimates = class(TForm_MDI)
    P_Top: TPanel;
    E_Name: TDBEditEh;
    Bt_Go: TSpeedButton;
    Pc_1: TPageControl;
    Ts_Items: TTabSheet;
    Ts_Orders: TTabSheet;
    DBGridEh1: TDBGridEh;
    E_PPComment: TDBEditEh;
    MemTableEh1: TMemTableEh;
    DataSource1: TDataSource;
    ADODataDriverEh1: TADODataDriverEh;
    DBGridEh2: TDBGridEh;
    DBEditEh1: TDBEditEh;
    ADODataDriverEh2: TADODataDriverEh;
    DataSource2: TDataSource;
    MemTableEh2: TMemTableEh;
    Chb_InclosedOrders: TCheckBox;
    Chb_Like: TCheckBox;
    Img_Info: TImage;
    procedure Bt_GoClick(Sender: TObject);
    procedure DBGridEh1DblClick(Sender: TObject);
    procedure DBGridEh2DblClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Chb_InClosedOrdersClick(Sender: TObject);
  private
    { Private declarations }
    function Prepare: Boolean; override;
    procedure EstimateDialog(Mt: TMemTableEh);
  public
    { Public declarations }
  end;

var
  Dlg_Or_FindNameInEstimates: TDlg_Or_FindNameInEstimates;

implementation

{$R *.dfm}

uses
  DateUtils,
  uSettings,
  uForms,
  uDBOra,
  uString,
  uData,
  uMessages,
  uWindows,
  uOrders
  ;


procedure TDlg_Or_FindNameInEstimates.Bt_GoClick(Sender: TObject);
var
  wherest: string;
begin
  inherited;
  if E_Name.Text = '' then Exit;
  wherest:= S.IIf(Chb_Like.Checked, 'upper(bcadname) like upper(:name)', 'bcadname = :name');
  ADODataDriverEh1.SelectSQL.Text:=
    'select id_std_item, id_estimate, formatname, stdname from v_findinestimate_std where ' + wherest + ' order by formatname, stdname';
  ADODataDriverEh1.SelectCommand.Parameters.ParamByName('name').Value:=E_Name.Text;
  ADODataDriverEh1.SelectCommand.Parameters.ParamByName('name').DataType:=ftString;
  MemTableEh1.Active:=False;
  MemTableEh1.Active:=True;
  DBGridEh1.AutoFitColWidths:=True;
  DBGridEh1.Columns[0].Visible:=False;
  DBGridEh1.Columns[1].Visible:=False;
  Gh.SetGridColumnsProperty(DBGridEh1, cptCaption,'formatname;stdname','������;����������� �������');
  DBGridEh1.AutoFitColWidths:=False;
  Gh.SetGridColumnsProperty(DBGridEh1, cptWidth, 'formatname;stdname', '200;200');
  DBGridEh1.AutoFitColWidths:=True;
  DbGridEh1.Enabled:=True;

  ADODataDriverEh2.SelectSQL.Text:=
    'select id_order_item, id_estimate, slash, itemname, std, nvl2(dt_end, 1, 0) as end from v_findinestimate_inorders where ' +
    wherest +
    S.IIf(not Chb_InClosedOrders.Checked, ' and dt_end is null ', ' ') +
    ' order by slash, itemname';
  ADODataDriverEh2.SelectCommand.Parameters.ParamByName('name').Value:=E_Name.Text;
  ADODataDriverEh2.SelectCommand.Parameters.ParamByName('name').DataType:=ftString;
  MemTableEh2.Active:=False;
  MemTableEh2.Active:=True;
  DBGridEh2.AutoFitColWidths:=True;
  DBGridEh2.Columns[0].Visible:=False;
  DBGridEh2.Columns[1].Visible:=False;
  Gh.SetGridColumnsProperty(DBGridEh2, cptCaption, 'slash;itemname;std;end', '�����;�������;���.;����.');
  Gh.SetGridInCellCheckBoxes(DBGridEh2, 'std;end', '0;1');
  DBGridEh2.AutoFitColWidths:=False;
  Gh.SetGridColumnsProperty(DBGridEh2, cptWidth,'slash;itemname;std;end', '100;300;25;35');
  DBGridEh2.AutoFitColWidths:=True;
  DbGridEh2.Enabled:=True;
end;

procedure TDlg_Or_FindNameInEstimates.Chb_InClosedOrdersClick(Sender: TObject);
begin
  inherited;
  //
end;

procedure TDlg_Or_FindNameInEstimates.EstimateDialog(Mt: TMemTableEh);
//������� �������� (���, ���� ���� ����� - ��������) ����� ��� ��������� �� ���� ������������
//��� ����� �� ������ ����� ������� �������� �����
begin
  if Mt = MemTableEh1 then begin
    //��� ������������ �������
    if (DBGridEh1.Columns[DBGridEh1.Col - 1].Field.FieldName = 'STDNAME') and User.Role(rOr_R_StdItems_Estimate)
      then begin
         Orders.LoadBcadGroups(True);
         Orders.LoadEstimate(null, null, MemTableEh1.FieldByName('id_std_item').AsInteger)
      end
      else
        Wh.ExecReference(
          myfrm_R_Estimate, Self, [myfoDialog, myfoMultiCopyWoId, myfoSizeable, myfoEnableMaximize],
          VarArrayOf([null, MemTableEh1.FieldByName('id_std_item').AsInteger])
        );
  end
  else begin
    //��� ������� � ������ (�������� ������ ��� �������������� �������)
    if (DBGridEh2.Columns[DBGridEh2.Col - 1].Field.FieldName = 'ITEMNAME') and User.Role(rOr_D_Order_Estimate)
 //      and (MemTableEh2.FieldByName('std').AsInteger = 0) and (MemTableEh2.FieldByName('end').AsInteger = 0)
      then begin
         Orders.LoadBcadGroups(True);
         Orders.LoadEstimate(null, MemTableEh2.FieldByName('id_order_item').AsInteger, null)
      end
      else
        Wh.ExecReference(
          myfrm_R_Estimate, Self, [myfoDialog, myfoMultiCopyWoId, myfoSizeable, myfoEnableMaximize],
          VarArrayOf([MemTableEh2.FieldByName('id_order_item').AsInteger, null])
        );
  end;
end;


procedure TDlg_Or_FindNameInEstimates.DBGridEh1DblClick(Sender: TObject);
begin
  EstimateDialog(MemTableEh1);
end;

procedure TDlg_Or_FindNameInEstimates.DBGridEh2DblClick(Sender: TObject);
begin
  EstimateDialog(MemTableEh2);
end;

procedure TDlg_Or_FindNameInEstimates.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  Settings.SaveWindowPos(Self, FormDoc);
end;

procedure TDlg_Or_FindNameInEstimates.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Key = VK_ESCAPE then Close;
end;

function TDlg_Or_FindNameInEstimates.Prepare: Boolean;
//����� �� �������� ��������, ������������ �����, � ��������� ����� ����������� BorderStyle:=bsDialog;
//����� ��� ���� ��� ����� �������������
//���� ����� �� ����, � Prepare ����������� PreventResize:=True;
//�� ���-����� �������� �� ������ ���������, ���� � ���� ��������� �� ��������� BorderStyle:=bsSizeable;
var
  i: Integer;
  sda: TStringDynArray;
begin
  Result:=False;
  KeyPreview:=True;
  Caption:='����� ������� �������';
  Cth.SetSpeedButton(Bt_Go, mybtGo, True);
  BorderStyle:=bsSizeable;
  MemTableEh1.FetchAllOnOpen:=True;
  DbGridEh1.ReadOnly:=True;
  DbGridEh1.Enabled:=False;
  Gh.SetGridOptionsDefault(DbGridEh1);
  Gh.SetGridOptionsMain(DbGridEh1, True, True, True);
  MemTableEh2.FetchAllOnOpen:=True;
  DbGridEh2.ReadOnly:=True;
  DbGridEh2.Enabled:=False;
  Gh.SetGridOptionsDefault(DbGridEh2);
  Gh.SetGridOptionsMain(DbGridEh2, True, True, True);
  E_Name.Text:='';
  if Id <> null then begin
    E_Name.Text:=S.NSt(Q.QSelectOneRow('select name from bcad_nomencl where id = :id$i', [id])[0]);
  end;
  Pc_1.ActivePageIndex:=0;
  //E_Name.Text:='!�������� �������������/�������� ������������� D14 �����';
  Cth.SetInfoIcon(Img_Info,
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
    '�� �������� ����� � � ������ �������� ��������� �������� �����.'#13#10+
    ''#13#10
    , 20
  );
  Result:=True;
end;


end.
