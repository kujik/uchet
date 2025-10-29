unit D_Spl_InfoGrid;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  F_MdiGridDialogTemplate, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Data.DB, MemTableEh, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Mask, DBCtrlsEh, GridsEh, DBAxisGridsEh, DBGridEh, Vcl.Buttons,
  EhLibVclUtils;

type
  TDlg_Spl_InfoGrid = class(TForm_MdiGridDialogTemplate)
    DataSource2: TDataSource;
    MemTableEh2: TMemTableEh;
    DBGridEh2: TDBGridEh;
    DBEditEh1: TDBEditEh;
    lbl_Caption: TLabel;
    procedure DBGridEh1RowDetailPanelShow(Sender: TCustomDBGridEh; var CanShow: Boolean);
    procedure DBGridEh1DblClick(Sender: TObject);
    procedure CellButtonClick(Sender: TObject; var Handled: Boolean);
    procedure CellButtonClick2(Sender: TObject; var Handled: Boolean);
  private
    { Private declarations }
    function Prepare: Boolean; override;
    function InitGrid: Boolean; override;            //������� ���� � �������� (����, ���������...). ���������� � Prepare, ����������� �������������.
    function InitAdd: Boolean; override;             //�������������� �������� �������, ������� ���������� � Prepare.
    procedure ViewEstimate;
  public
    { Public declarations }
  end;

var
  Dlg_Spl_InfoGrid: TDlg_Spl_InfoGrid;

implementation

uses
  DateUtils, uSettings, uForms, uDBOra, uString, uMessages, uData, uSys, uWindows, uFrmOWPlannedOrder;


{$R *.dfm}

procedure TDlg_Spl_InfoGrid.ViewEstimate;
begin
//  Wh.ExecReference(myfrm_R_AggEstimate, Self, [myfoDialog, myfoMultiCopyWoId, myfoSizeable, myfoEnableMaximize], VarArrayOf([MemTableEh1.FieldByName('id').AsInteger]))
end;

procedure TDlg_Spl_InfoGrid.CellButtonClick(Sender: TObject; var Handled: Boolean);
var
  IdOrder: Variant;
begin
  if MemTableEh1.RecordCount = 0 then Exit;
  //������� ���� ������ � �����
  IdOrder:=null;
  if DBGridEh1.FindFieldColumn('ornum') <> nil
    then IdOrder:=Q.QSelectOneRow('select id from v_orders where ornum = :ornum$s', [MemTableEh1.FieldByName('ornum').Value])[0];
  //������� ������� ������ ��� �����
  if IdOrder <> null
    then if TCellButtonEh(Sender).Hint = '�������'
      then Wh.ExecDialog(myfrm_Dlg_Order, Self, [], fView, IdOrder, null)
      else if TCellButtonEh(Sender).Hint = '�����'
       then Wh.ExecReference(myfrm_R_AggEstimate, Self, [myfoDialog, myfoMultiCopyWoId, myfoSizeable, myfoEnableMaximize], VarArrayOf([IdOrder]));
  //������� ���� �� ���
  if TCellButtonEh(Sender).Hint = '������� ����'
    then Wh.ExecReference(myfrm_R_Itm_Schet, Self, [myfoDialog, myfoSizeable, myfoEnableMaximize], MemTableEh1.FieldByName('id_schet').Value);
  //������� �� �� ���
  if TCellButtonEh(Sender).Hint = '������� ��������� ���������'
    then Wh.ExecReference(myfrm_R_Itm_InBill, Self, [myfoDialog, myfoSizeable, myfoEnableMaximize], MemTableEh1.FieldByName('id_inbill').Value);
  if TCellButtonEh(Sender).Hint = '������� �������� �����'
    then TFrmOWPlannedOrder.Show(Self, myfrm_Dlg_PlannedOrder, [myfoSizeable, myfoMultiCopy], fView, MemTableEh1.FieldByName('id').Value, null);

end;

procedure TDlg_Spl_InfoGrid.CellButtonClick2(Sender: TObject; var Handled: Boolean);
var
  IdOrder: Variant;
begin
  if MemTableEh1.RecordCount = 0 then Exit;
  //������� �� �� ���
  if TCellButtonEh(Sender).Hint = '������� ��������� ���������'
    then Wh.ExecReference(myfrm_R_Itm_InBill, Self, [myfoDialog, myfoSizeable, myfoEnableMaximize], MemTableEh2.FieldByName('id_inbill').Value);
end;

function TDlg_Spl_InfoGrid.InitGrid: Boolean;
var
  i, j: Integer;
  va: TVarDynArray;
  va2, va3: TVarDynArray2;
  st: string;
begin
  {(*}
  DBGridEh1.RowDetailPanel.Active:=False;
  if FormDoc = myfrm_Dlg_Spl_InfoGrid_MinPart then begin
  va2:=Q.QLoadToVarDynArray2(
    'select n.id_supplier, k.full_name, n.name_pos, u.name_unit, n.base_unit_k, n.minpart '+
    'from dv.namenom_supplier n, dv.kontragent k, dv.unit u '+
    'where id_nomencl = :id$i and n.id_supplier = k.id_kontragent and n.id_base_unit = u.id_unit',
     [id]
    );
  Mth.CreateTableGrid(
    DBGridEh1, True, False, False, False,[
    ['id', ftInteger, 0, 'id', 20, False, False, False],
    ['supplier', ftString, 1000, '���������', 400, True, True, True],
    ['name', ftString, 1000, '������������', 400, True, True, True],
    ['unit', ftString, 50, '��.���.', 100, True, False, False],
    ['base_unit_k', ftFloat, 0, '�����.', 80, True, False, False],
    ['minpart', ftFloat, 0, '���. ������', 80, True, False, False]
    ],
    va2, '', ''
  );
  {*)}
    FieldsReadOnly := 'id;supplier;name;unit;base_unit_k';
    ColumnsVerifications := ['', '', '', '', '', '0:1000000:0'];
  end;
  if FormDoc = myfrm_Dlg_Spl_InfoGrid_Rezerv then begin
  va2:=Q.QLoadToVarDynArray2(
      'select /*stockdate, */ numdoc, area_short, project, dt_beg, dt_otgr, rashod from v_spl_rezerv_detail where id_nomencl = :id$i order by stockdate desc',
      [id]
    );
  Mth.CreateTableGrid(
    DBGridEh1, True, False, False, False,[
    //['stockdate', ftDateTime, 0, '����', 80, True, True, False],
    ['ornum', ftString, 15, '� ������', 80, True, True, False],
    ['area_short', ftString, 15, '��������', 80, True, True, False],
    ['project', ftString, 500, '������', 200, True, True, False],
    ['dt_beg', ftDateTime, 0, '���� ����������', 80, True, True, False], //control_date
    ['dt_otgr', ftDateTime, 0, '���� ��������', 80, True, True, False],
    ['rashod', ftFloat, 0, '���-��', 80, True, True, False]
    ],
    va2, '', ''
  );
  Gh.SetGridOptionsMain(DBGridEh1, True, True, True);
  Gh.SetGridColumnsProperty(DBGridEh1, cptDisplayFormat, 'rashod', '0.#');
  Gh.SetGridColumnsProperty(DBGridEh1, cptSumFooter, 'rashod', '0.#');
  {*)}
  end;
  if FormDoc = myfrm_Dlg_Spl_InfoGrid_OnWay then begin
    va2:=Q.QLoadToVarDynArray2(
      'select id, date_registr, num, name_org, quantity_suppl, unit_suppl, nvl(quantity_main,0), nvl(fact_quantity,0), nvl(quantity_main, 0) - nvl(fact_quantity, 0) as rest '+
      'from v_spl_onway_detail where id_n = :id$i order by date_registr',
      [id]
    );
  Mth.CreateTableGrid(
    DBGridEh1, True, False, False, False,[
    ['id_schet', ftInteger, 0, '_id', 80, False, True, False],
    ['date_registr', ftDateTime, 0, '����', 80, True, True, False], //control_date
    ['num', ftString, 50, '� �����', 100, True, True, False],
    ['name_org', ftString, 255, '���������', 250, True, True, False],
    ['quantity_suppl', ftFloat, 0, '���. ����������', 80, True, True, False],
    ['unit_suppl', ftString, 50, '��. ����������', 80, True, True, False],
    ['quantity_main', ftFloat, 0, '�� �����', 80, True, True, False],
    ['fact_quantity', ftFloat, 0, '�� ���������', 80, True, True, False],
    ['rest', ftFloat, 0, '�������', 80, True, True, False]
    ],
    va2, '', ''
  );
  //Gh.SetGridOptionsMain(DBGridEh1, True, True, True);
  Gh.SetGridOptionsMain(DBGridEh1, True, True, True);
  Gh.SetGridColumnsProperty(DBGridEh1, cptDisplayFormat, 'quantity_suppl;quantity_main;fact_quantity;rest', '#.#');
  Gh.SetGridColumnsProperty(DBGridEh1, cptSumFooter, 'quantity_suppl;quantity_main;fact_quantity;rest', '#.#');
  Gh.SetGridInCellButtons(DBGridEh1, 'num', '������� ����', CellButtonClick);
  DBGridEh1.RowDetailPanel.Active:=True;
  Mth.CreateTableGrid(
    DBGridEh2,True, True, True, True,[
    ['id_inbill', ftInteger, 0, '_id', 80, False, True, False],
    ['dt', ftDateTime, 0, '����', 150, True, True, False],
    ['num', ftString, 50, '� ���������', 150, True, True, False],
    ['qnt', ftFloat, 0, '���-��', 80, True, True, False]
    ],
    [], '', ''
  );
  Gh.SetGridInCellButtons(DBGridEh2, 'num', '������� ��������� ���������', CellButtonClick2);
  end;
  if FormDoc = myfrm_Dlg_Spl_InfoGrid_Consumption then begin
  //��������� �� ������� �� ��������� ������
    va2:=Q.QLoadToVarDynArray2(
      'select id, id_doc, doctypename, docnum, dt, scladname, comm, qnt '+
      'from v_spl_consumption '+
      'where id_nomencl = :id$i and dt >= trunc(sysdate) - :d$i + 1 and doctype <> 2 /*05-09-24 ������� ���� ��������*/'+
      'order by dt',
      [id, AddParam[2]]
    );
  Mth.CreateTableGrid(
    DBGridEh1, True, True, True, True,[
    ['id', ftInteger, 0, '_id', 80, False, True, False],
    ['id_doc', ftInteger, 0, '_id_doc', 80, False, True, False],
    ['doctypename', ftString, 50, '��� ���������', 100, True, True, False],
    ['docnum', ftString, 50, '� ���������', 100, True, True, False],
    ['dt', ftDateTime, 0, '����', 80, True, True, False], //control_date
    ['scladname', ftString, 255, '�� ������', 100, True, True, False],
//    ['basedoc', ftString, 0, '���������', 150, True, True, True],
    ['ornum', ftString, 500, '���������', 150, True, True, True],
    ['qnt', ftFloat, 0, '���-��', 80, True, True, False]
//    ['comm', ftString, 1000, '�����������', 150, True, True, True]
    ],
    va2, '', ''
  );
  //Gh.SetGridOptionsMain(DBGridEh1, True, True, True);
  Gh.SetGridColumnsProperty(DBGridEh1, cptDisplayFormat, 'qnt', '0.#');
  Gh.SetGridColumnsProperty(DBGridEh1, cptSumFooter, 'qnt', '0.#');
  end;
  if FormDoc = myfrm_Dlg_Spl_InfoGrid_QntOnStore then begin
  //���������� �� �������
  va2:=Q.QLoadToVarDynArray2(
      'select skladname, qnt from v_itm_qntonstore '+
      'where id_nomencl = :id$i and id_sklad is not null and (not id_sklad in (842, 922)) '+
      'order by skladname',
      [id]
    );
  Mth.CreateTableGrid(
    DBGridEh1, True, True, True, False,[
    ['skladname', ftString, 200, '�����', 200, True, True, False],
    ['qnt', ftFloat, 0, '���-��', 80, True, True, False]
    ],
    va2, '', ''
  );
  Gh.SetGridColumnsProperty(DBGridEh1, cptDisplayFormat, 'qnt', '0.#');
  Gh.SetGridColumnsProperty(DBGridEh1, cptSumFooter, 'qnt', '0.#');
  end;
  if FormDoc = myfrm_Dlg_Spl_InfoGrid_Incoming then begin
  //��������� �� ������� �� ��������� ������ (�� ��������� ���������)
  va2:=Q.QLoadToVarDynArray2(
      'select td, numdoc, stockdate, basis, prihod from v_itm_movenomencl '+
      'where id_nomencl = :id$i and doctype in (1/*, 5*/) and stockdate >= trunc(sysdate) - :d$i + 1 '+
      'order by stockdate desc',
      [id, AddParam[2]]
    );
  Mth.CreateTableGrid(
    DBGridEh1, True, False, False, False,[
    ['td', ftString, 50, '��� ���������', 120, True, True, False],
    ['numdoc', ftString, 50, '� ���������', 80, True, True, False],
    ['stockdate', ftDateTime, 0, '����', 80, True, True, False],
    ['basis', ftString, 500, '���������', 250, True, True, True],
    ['prihod', ftFloat, 0, '���-��', 80, True, True, False]
    ],
    va2, '', ''
  );
  Gh.SetGridOptionsMain(DBGridEh1, True, True, True);
  Gh.SetGridColumnsProperty(DBGridEh1, cptDisplayFormat, 'prihod', '0.#');
  Gh.SetGridColumnsProperty(DBGridEh1, cptSumFooter, 'prihod', '0.#');
  end;
  if FormDoc = myfrm_Dlg_Spl_InfoGrid_MoveNomencl then begin
  //��������� �� �������� �� ������������ �� ���� ������, ��� ��������� ��������� (��������, ���������, ���, ���� ��������, ���������� � ������)
  {
   ��� ������� �� ����������� ������ � ������� "�� ������" ����� ��������� ���������� ��������� ������� � ������� ������, ������ ����� ��������,
   � �������� ����� ������ ������ ��� ������� "�� �����"
  }

    va2:=Q.QLoadToVarDynArray2(
      'select id_stock, id_doc, doctype, td, numdoc, stockdate, skladsrc, skladdest, basis, dt_beg, dt_otgr, project, prihod, rashod, comments '+   //sourcedoc
      'from v_itm_movenomencl where id_nomencl = :id$i and stockdate >= :dt$d order by stockdate',
      [id, EncodeDate(2024, 01, 01)]
    );
  Mth.CreateTableGrid(
    DBGridEh1, True, False, False, False,[
    ['id_stock', ftInteger, 0, '_id', 80, False, True, False],
    ['id_doc', ftInteger, 0, '_id_doc', 80, False, True, False],
    ['doctype', ftInteger, 0, '_id_doc', 80, False, True, False],
    ['td', ftString, 50, '��� ���������', 120, True, True, False],
    ['numdoc', ftString, 50, '� ���������', 80, True, True, False],
    ['stochdate', ftDateTime, 0, '���� ���������', 80, True, True, False],
    ['skladsrc', ftString, 255, '�� ������', 150, True, True, False],
    ['skladdest', ftString, 255, '�� �����', 150, True, True, False],
//    ['basis', ftString, 500, '���������', 500, True, True, True],
    ['ornum', ftString, 500, '���������', 500, True, True, True],
    ['dt_beg', ftDateTime, 0, '���� ����������', 80, True, True, False],
    ['dt_otgr', ftDateTime, 0, '���� ��������', 80, True, True, False],
    ['project', ftString, 500, '������', 200, True, True, False],
    ['prihod', ftFloat, 0, '������', 80, True, True, False],
    ['rashod', ftFloat, 0, '������', 80, True, True, False],
    ['comments', ftString, 1000, '�����������', 400, True, True, True]
    ],
    va2, '', ''
  );
  Gh.SetGridOptionsMain(DBGridEh1, True, True, True);
  Gh.SetGridColumnsProperty(DBGridEh1, cptDisplayFormat, 'prihod;rashod', '0.#');
  Gh.SetGridColumnsProperty(DBGridEh1, cptSumFooter, 'prihod;rashod', '0.#');
  end;
  if FormDoc = myfrm_Dlg_Spl_InfoGrid_DiffInOrder then begin
  //�� ��������!!!
  //��������� �� �������� �� ������������ �� ���� ������, ��� ��������� ��������� (��������, ���������, ���, ���� ��������, ���������� � ������)
    va:=Q.QLoadToVarDynArrayOneCol(
      'select basis from ( '+
      'select sum(prihod + (case when doctype = 3 then 0 else rashod end)) as moves, basis from v_itm_movenomencl ' +
      'where id_nomencl = :id$i and stockdate >= :dt$d and doctype in (-1,2,3,4,-5,-6) and not (doctype = 3 and rashod < 0) ' +
      'group by basis) '+
      'where nvl(moves, 0) <> 0',
      [id, EncodeDate(2024, 01, 01)]
    );
    if Length(va) = 0 then va:= [-1];
    st:= '''' + A.Implode(va, ''',''') + '''';
    va2:=Q.QLoadToVarDynArray2(
      'select id_stock, id_doc, doctype, td, numdoc, stockdate, skladsrc, skladdest, basis, dt_beg, dt_otgr, project, prihod, rashod, comments '+   //sourcedoc
      'from v_itm_movenomencl where id_nomencl = :id$i and stockdate >= :dt$d  and doctype in (-1,2,3,4,-5,-6) and not (doctype = 3 and rashod < 0) '+
      'and basis in (' + st + ') '+
      'order by stockdate',
      [id, EncodeDate(2024, 01, 01)]
    );
  Mth.CreateTableGrid(
    DBGridEh1, True, False, False, False,[
    ['id_stock', ftInteger, 0, '_id', 80, False, True, False],
    ['id_doc', ftInteger, 0, '_id_doc', 80, False, True, False],
    ['doctype', ftInteger, 0, '_id_doc', 80, False, True, False],
    ['td', ftString, 50, '��� ���������', 120, True, True, False],
    ['numdoc', ftString, 50, '� ���������', 80, True, True, False],
    ['stochdate', ftDateTime, 0, '���� ���������', 80, True, True, False],
    ['skladsrc', ftString, 255, '�� ������', 150, True, True, False],
    ['skladdest', ftString, 255, '�� �����', 150, True, True, False],
//    ['basis', ftString, 500, '���������', 500, True, True, True],
    ['ornum', ftString, 500, '���������', 500, True, True, True],
    ['dt_beg', ftDateTime, 0, '���� ����������', 80, True, True, False],
    ['dt_otgr', ftDateTime, 0, '���� ��������', 80, True, True, False],
    ['project', ftString, 500, '������', 200, True, True, False],
    ['prihod', ftFloat, 0, '������', 80, True, True, False],
    ['rashod', ftFloat, 0, '������', 80, True, True, False],
    ['comments', ftString, 1000, '�����������', 400, True, True, True]
    ],
    va2, '', ''
  );
  Gh.SetGridOptionsMain(DBGridEh1, True, True, True);
  Gh.SetGridColumnsProperty(DBGridEh1, cptDisplayFormat, 'prihod;rashod', '0.#');
  Gh.SetGridColumnsProperty(DBGridEh1, cptSumFooter, 'prihod;rashod', '0.#');
  end;
  if FormDoc = myfrm_Dlg_Spl_InfoGrid_SpSchetList then begin
  //������ ������ �� ������ ������������
    va2:=Q.QLoadToVarDynArray2(
      'select id_schet, date_registr, num, name_org, name, quantity, unit, price '+
      'from v_spl_schetbynomencl where id_nomencl = :id$i order by date_registr',
      [id]
    );
  Mth.CreateTableGrid(
    DBGridEh1, True, True, True, False,[
    ['id_schet', ftInteger, 0, '_id', 80, False, True, False],
    ['date_registr', ftDateTime, 0, '����', 80, True, True, False], //control_date
    ['num', ftString, 50, '� �����', 100, True, True, False],
    ['name_org', ftString, 255, '���������', 250, True, True, False],
    ['name', ftString, 255, '������������ � ����������', 250, True, True, False],
    ['quantity', ftFloat, 0, '���. ����������', 80, True, True, False],
    ['unit', ftString, 50, '��. ����������', 80, True, True, False],
    ['price', ftFloat, 0, '����', 80, True, True, False]
    ],
    va2, '', ''
  );
  Gh.SetGridColumnsProperty(DBGridEh1, cptDisplayFormat, 'quantity', '0.#');
  Gh.SetGridColumnsProperty(DBGridEh1, cptDisplayFormat, 'price', '0.00');
  Gh.SetGridColumnsProperty(DBGridEh1, cptSumFooter, 'quantity', '0.#');
  Gh.SetGridInCellButtons(DBGridEh1, 'num', '������� ����', CellButtonClick);
{  DBGridEh1.RowDetailPanel.Active:=True;
  Mth.CreateTableGrid(
    DBGridEh2,True, True, True, True,[
    ['dt', ftDateTime, 0, '����', 150, True, True, False],
    ['num', ftString, 50, '� ���������', 150, True, True, False],
    ['qnt', ftFloat, 0, '���-��', 80, True, True, False]
    ],
    [], '', ''
  );}
  end;
  if FormDoc = myfrm_Dlg_Spl_InfoGrid_InBillList then begin
  //������ ��������� ��������� �� ������ ������������
    va2:=Q.QLoadToVarDynArray2(
      'select id_inbill, inbilldate, inbillnum, name_org, ibquantity, fact_quantity, name_unit, price, price_itogo '+
      'from v_spl_nom_inbills where id_nomencl = :id$i order by inbilldate',
      [id]
    );
  Mth.CreateTableGrid(
    DBGridEh1, True, True, True, False,[
    ['id_inbill', ftInteger, 0, '_id', 80, False, True, False],          //���� � ����� ����, � �� ��������� ���������!
    ['inbilldate', ftDateTime, 0, '����', 80, True, True, False],
    ['inbillnum', ftString, 50, '� ��', 100, True, True, False],
    ['name_org', ftString, 255, '���������', 250, True, True, False],
    ['ibquantity', ftFloat, 0, '���-��', 80, True, True, False],
    ['fact_quantity', ftFloat, 0, '���-�� �� ���.', 80, True, True, False],
    ['unit', ftString, 50, '��. ���', 80, True, True, False],
    ['price', ftFloat, 0, '����', 80, True, True, False],
    ['price_itogo', ftFloat, 0, '���� � ���', 80, True, True, False]
    ],
    va2, '', ''
  );
  Gh.SetGridColumnsProperty(DBGridEh1, cptDisplayFormat, 'ibquantity;fact_quantity', '0.#');
  Gh.SetGridColumnsProperty(DBGridEh1, cptDisplayFormat, 'price;price_itogo', '0.00');
  Gh.SetGridColumnsProperty(DBGridEh1, cptSumFooter, 'ibquantity;fact_quantity', '0.#');
  Gh.SetGridInCellButtons(DBGridEh1, 'inbillnum', '������� ��������� ���������', CellButtonClick);
  end;
  if FormDoc = myfrm_Dlg_Spl_InfoGrid_OnDemand then begin
    va2:=Q.QLoadToVarDynArray2(
      'select id_demand, demand_date, docstate, quantity '+
      'from v_spl_nomencl_on_demand '+
      'where id_nomencl = :id$i and demand_date > sysdate - (select on_demand_days from spl_minremains_params) '+
      'order by demand_date',
      [id]
    );
  Mth.CreateTableGrid(
    DBGridEh1, True, False, False, False,[
    ['id_demand', ftInteger, 0, '_id', 80, False, True, False],
    ['demand_date', ftDateTime, 0, '����', 80, True, True, False], //control_date
    ['docstate', ftString, 20, '������', 80, True, True, False],    //4-����������, 3-�� ���������, 1-� ��������, 2-?
    ['quantity', ftFloat, 0, '���.', 80, True, True, False]
    ],
    va2, '', ''
  );
  Gh.SetGridOptionsMain(DBGridEh1, True, True, True);
  Gh.SetGridColumnsProperty(DBGridEh1, cptDisplayFormat, 'quantity', '0.#');
  Gh.SetGridColumnsProperty(DBGridEh1, cptSumFooter, 'quantity', '0.#');
  end;
  if FormDoc = myfrm_Dlg_Spl_InfoGrid_PlannedOrders then begin
    //������� ������� �������� ������� �� ������ ������������ �� ������ ������
    //������������ ����������� � AddParam[0], ����� � AddParam[1]
    //���� ����� �������������, �� ����� �� ������� ��� ��, ����� �� ����� �� 12 �������
    if AddParam[1] > 0
      then st := S.NSt(Q.QSelectOneRow('select or' + VarToStr(AddParam[1]) + ' from planned_order_estimate12 where name = :name$s', [AddParam[0]])[0])
      else if AddParam[1] < 0
        then st := S.NSt(Q.QSelectOneRow('select or' + VarToStr(-AddParam[1]) + ' from planned_order_estimate3 where name = :name$s', [AddParam[0]])[0]);
    if st = '' then st := '0';
    va2:=Q.QLoadToVarDynArray2(
      'select id, num, projectname, dt_start, dt_end '+
      'from v_planned_orders '+
      'where id in (' + st + ') '+
      'order by num',
      [id]
    );
    Mth.CreateTableGrid(
      DBGridEh1, True, False, False, False,[
      ['id', ftInteger, 0, '_id', 80, False, True, False],
      ['num', ftString, 40, '�', 80, True, True, False],
      ['project', ftString, 400, '������', 250, True, True, True],
      ['dt_sta�t', ftDateTime, 0, '������', 80, True, True, False],
      ['dt_end', ftDateTime, 0, '���������', 80, True, True, False]
      ],
      va2, '', ''
    );
    Gh.SetGridOptionsMain(DBGridEh1, True, True, True);
    Gh.SetGridInCellButtons(DBGridEh1, 'num', '������� �������� �����', CellButtonClick);
  end;
  //��������� ������ � ������ �����
  Gh.SetGridInCellButtons(DBGridEh1, 'ornum;ornum', '�������;�����', CellButtonClick);
  Result := True;
end;

procedure TDlg_Spl_InfoGrid.DBGridEh1DblClick(Sender: TObject);
var
  va: TVarDynArray;
begin
  inherited;
  if (FormDoc = myfrm_Dlg_Spl_InfoGrid_OnWay)and(FieldNameCurr = 'num') then begin
    va:=Q.QLoadToVarDynArrayOneRow(
      'select filename from sn_calendar_accounts where account = :account$s and accountdt = :dt$d',
      [MemTableEh1.FieldByName('num').Value, MemTableEh1.FieldByName('date_registr').Value]
    );
    if (Length(va) > 0)and(va[0] <> null)
      then Sys.OpenFileOrDirectory(Module.GetPath_Accounts_A(VarToStr(va[0])), '���� ����� �� ������!');
  end;
  if FormDoc = myfrm_Dlg_Spl_InfoGrid_Rezerv then begin
    va:=Q.QLoadToVarDynArrayOneRow(
      'select id from v_orders where ornum = :ornum$s',
      [MemTableEh1.FieldByName('ornum').Value]
    );
    if FieldNameCurr = 'ornum' then begin
      //������� ������� ������
      if (Length(va) > 0)and(va[0] <> null)
        then Wh.ExecDialog(myfrm_Dlg_Order, Self, [], fView, va[0], null);
    end;
    if FieldNameCurr = 'rashod' then begin
      //������� ������� ������
      if (Length(va) > 0)and(va[0] <> null)
        then Wh.ExecReference(myfrm_R_AggEstimate, Self, [myfoDialog, myfoMultiCopyWoId, myfoSizeable, myfoEnableMaximize], VarArrayOf([va[0]]));
    end;
  end;
end;

procedure TDlg_Spl_InfoGrid.DBGridEh1RowDetailPanelShow(Sender: TCustomDBGridEh;
  var CanShow: Boolean);
begin
  inherited;
  if FormDoc = myfrm_Dlg_Spl_InfoGrid_OnWay then begin
    DBGridEh1.RowDetailPanel.Width:=DBGridEh1.Width-50;
    Q.QLoadToMemTableEh(
    'select '#13#10+
    'i.id_inbill as id_inbill, i.inbilldate as dt, i.inbillnum as num, ii.fact_quantity as qnt '#13#10+   // fact_quantity ��� ibquantity!!!
    '  from dv.in_bill i, dv.in_bill_spec ii '#13#10+
    '  where '#13#10+
    '    i.id_docstate = 3 and ii.id_inbill = i.id_inbill and ii.id_nomencl = :idn2$i and i.docid = :idd2$i '#13#10+
    '  order by inbilldate desc '#13#10,
    [id, MemTableEh1.FieldByName('id_schet').Value],
    MemTableEh2, '', 0
    )
  end;
end;

function TDlg_Spl_InfoGrid.InitAdd: Boolean;
begin
  Caption := S.Decode([
     FormDoc,
     myfrm_Dlg_Spl_InfoGrid_MinPart, '����������� ������',
     myfrm_Dlg_Spl_InfoGrid_Rezerv, '������',
     myfrm_Dlg_Spl_InfoGrid_OnWay, '� ����',
     myfrm_Dlg_Spl_InfoGrid_Consumption, '������',
     myfrm_Dlg_Spl_InfoGrid_MoveNomencl, '�������� ������',
     myfrm_Dlg_Spl_InfoGrid_QntOnStore, '������� �� �������',
     myfrm_Dlg_Spl_InfoGrid_SpSchetList, '����� �� ������������',
     myfrm_Dlg_Spl_InfoGrid_InBillList, '��������� ���������',
     myfrm_Dlg_Spl_InfoGrid_PlanneDOrders, '�������� ������',
     '����������'
  ]);
  InfoArr := [];
  pnl_Top.Visible := True;
  pnl_Bottom.Visible := False;
  lbl_Caption.Caption := AddParam[0].AsString;
  //lbl_Caption.SetCaption2('����� � ������������ �������: ''$FF0000  ��.�_����� �������� 100�600');
  Result := True;
end;

function TDlg_Spl_InfoGrid.Prepare: Boolean;
begin
  Result := inherited;
  Bt_Add.Hide;
  Bt_Del.Hide;
  Bt_Ok.Hide;
  Mode := fView;
  Cth.SetBtn(Bt_Cancel, mybtViewClose, False);
  Bev_Buttons.Hide;
end;

end.

