unit D_OrderPrintLabels;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_Normal, DBGridEhGrouping, ToolCtrlsEh,
  DBGridEhToolCtrls, DynVarsEh, MemTableDataEh, Data.DB, MemTableEh,
  Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh, GridsEh, DBAxisGridsEh, DBGridEh,
  Vcl.Buttons, uString, EhLibVclUtils;

type
  TDlg_OrderPrintLabels = class(TForm_Normal)
    DBGridEh1: TDBGridEh;
    edt_PPComment: TDBEditEh;
    MemTableEh1: TMemTableEh;
    DataSource1: TDataSource;
    Bt_Print: TBitBtn;
    procedure Bt_PrintClick(Sender: TObject);
    procedure DBGridEh1ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
  private
    { Private declarations }
    OrderFields: TVarDynArray;
  public
    { Public declarations }
    function ShowDialog(ID: Variant): Boolean;
  end;

var
  Dlg_OrderPrintLabels: TDlg_OrderPrintLabels;

implementation

{$R *.dfm}

uses
  uSettings,
  uForms,
  uDBOra,
  uData,
  uMessages,
  uPrintReport
  ;



procedure TDlg_OrderPrintLabels.Bt_PrintClick(Sender: TObject);
begin
  inherited;
  PrintReport.pnl_OrderLabels(0, MemTableEh1, OrderFields);
end;

procedure TDlg_OrderPrintLabels.DBGridEh1ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
  MemTableEh1.FieldByName('qnt_p').Value:= S.IIfV(UseText, Text, Value);
  if MemTableEh1.FieldByName('qnt_p').AsString = ''
    then MemTableEh1.FieldByName('qnt_p').Value:=0;
  Handled:=True;
  Mth.PostAndEdit(MemTableEh1);
end;


function TDlg_OrderPrintLabels.ShowDialog(ID: Variant): Boolean;
var
  i, j: Integer;
begin
  if ID = null then Exit;
  if DbGridEh1.Columns.Count = 1 then begin
    DbGridEh1.Columns.Clear;
    MemTableEh1.DataDriver:=nil;
    MemTableEh1.FieldDefs.Clear;
    MemTableEh1.Close;
    Mth.AddTableColumn(DBGridEh1, 'slash', ftString, 100, '№', 100, True);
    Mth.AddTableColumn(DBGridEh1, 'itemname', ftString, 400, 'Изделие', 200, True);
    Mth.AddTableColumn(DBGridEh1, 'qnt', ftFloat, 0, 'Кол-во', 50, True);
    Mth.AddTableColumn(DBGridEh1, 'qnt_p', ftFloat, 0, 'На печать', 50, True);         //!!!поправить Integer
    MemTableEh1.CreateDataSet;
  //  DbGridEh1.optionseh:=DbGridEh1.optionseh - [dghClearSelection];
  //  DbGridEh1.options:=DbGridEh1.options + [dgRowSelect];
    DBGridEh1.AutoFitColWidths:=True;
    DBGridEh1.ReadOnly:= False;
    DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh-[dghColumnResize, dghColumnMove] - [dghEnterAsTab] + [dghAutoFitRowHeight];
    DBGridEh1.IndicatorOptions:=DBGridEh1.IndicatorOptions - [gioShowRowSelCheckBoxesEh] + [gioShowRecNoEh];
    DBGridEh1.AutoFitColWidths:=True;
    for i:=0 to DBGridEh1.Columns.Count - 1 do begin
      DBGridEh1.Columns[i].AutoFitColWidth:=DBGridEh1.Columns[i].FieldName = 'itemname';
      DBGridEh1.Columns[i].ReadOnly:=DBGridEh1.Columns[i].FieldName <> 'qnt_p';
    end;
    Gh.GetGridColumn(DBGridEh1, 'qnt_p').OnUpdateData:= DBGridEh1ColumnsUpdateData;
    minwidth:=400;
    minheight:=200;
    width:=600;
    height:=400;
    DBGridEh1.OptimizeAllColsWidth(-1, 2);
    Caption:='Печать этикеток';
    Cth.SetBtn(Bt_Print, mybtPrint, False);
  end;
  Resize;
  MemTableEh1.DisableControls;
  OrderFields:=Q.QSelectOneRow('select project from v_orders where id = :id$i', [ID]);
  Q.QLoadToMemTableEh('select slash, itemname, qnt, qnt as qnt_p from v_order_items where id_order = :id_order$i and qnt > 0', [ID],  MemTableEh1, 'slash;itemname;qnt;qnt_p', 0);
  DBGridEh1.Columns[0].Width:=100;
  MemTableEh1.First;
  Mth.PostAndEdit(MemTableEh1);
  MemTableEh1.EnableControls;
  ShowModal;
end;


end.
