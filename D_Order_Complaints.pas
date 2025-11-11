unit D_Order_Complaints;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  DropDownFormEh, Dialogs, DynVarsEh, ToolCtrlsEh,
  DBGridEhToolCtrls, MemTableDataEh, Data.DB, MemTableEh, Vcl.StdCtrls,
  DBCtrlsEh, GridsEh, DBAxisGridsEh, DBGridEh, Vcl.Buttons,
  EhLibVclUtils, DBGridEhGrouping, Vcl.Mask;

type
  TDlg_Order_Complaints = class(TCustomDropDownFormEh)
    DBGridEh1: TDBGridEh;
    edt_PPComment: TDBEditEh;
    MemTableEh1: TMemTableEh;
    DataSource1: TDataSource;
    Bt_Ok: TBitBtn;
    Bt_Cancel: TBitBtn;
    procedure CustomDropDownFormEhCreate(Sender: TObject);
    procedure CustomDropDownFormEhInitForm(Sender: TCustomDropDownFormEh;
      DynParams: TDynVarsEh);
    procedure DBGridEh1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CustomDropDownFormEhReturnParams(Sender: TCustomDropDownFormEh;
      DynParams: TDynVarsEh);
    procedure Bt_OkClick(Sender: TObject);
    procedure Bt_CancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Dlg_Order_Complaints: TDlg_Order_Complaints;

implementation

uses

  uForms,

  uString,
  uData,
  uWindows,
  uMessages
  ;


{$R *.dfm}


procedure TDlg_Order_Complaints.Bt_CancelClick(Sender: TObject);
begin
  Close;
end;

procedure TDlg_Order_Complaints.Bt_OkClick(Sender: TObject);
begin
  ModalResult:=mrOk;
  Close;
end;

procedure TDlg_Order_Complaints.CustomDropDownFormEhCreate(Sender: TObject);
begin
  DbGridEh1.Columns.Clear;
  MemTableEh1.DataDriver:=nil;
  MemTableEh1.FieldDefs.Clear;
  MemTableEh1.Close;
  Mth.AddTableColumn(DBGridEh1, 'id', ftInteger, 0, 'ID', 20, False);
  Mth.AddTableColumn(DBGridEh1, 'name', ftString, 400, 'Причина', 300, True);
  MemTableEh1.CreateDataSet;
  DBGridEh1.IndicatorOptions:=DBGridEh1.IndicatorOptions + [gioShowRowSelCheckBoxesEh];
  DbGridEh1.optionseh:=DbGridEh1.optionseh - [dghClearSelection];
  DbGridEh1.options:=DbGridEh1.options + [dgRowSelect];
  DBGridEh1.AutoFitColWidths:=True;
  Self.FormElements:=[ddfeLeftGripEh, ddfeRightGripEh];
  Cth.SetBtn(Bt_Ok, mybtOk, False);
  Cth.SetBtn(Bt_Cancel, mybtCancel, False);
end;


procedure TDlg_Order_Complaints.CustomDropDownFormEhInitForm(
  Sender: TCustomDropDownFormEh; DynParams: TDynVarsEh);
var
  i, j: Integer;
  va1, va2, va3: TVardynArray;
begin
  //MemTableEh1.DisableControls;
  j:=MemTableEh1.RecordCount-1;
  MemTableEh1.First;
  for i:=0 to j do MemTableEh1.Delete;
  va1:=A.ExplodeV(DynParams['names'].AsString, #1);
  va2:=A.ExplodeV(DynParams['ids'].AsString, #1);
  va3:=A.ExplodeV(DynParams['ids_ch'].AsString, #1);
  for i:=0 to High(va1) do begin
    MemTableEh1.Append;
    MemTableEh1.FieldByName('name').Value:=va1[i];
    MemTableEh1.FieldByName('id').Value:=va2[i];
    DBGridEh1.SelectedRows.CurrentRowSelected := A.InArray(va2[i], va3);
  end;
  Mth.Post(MemTableEh1);
  for i:=0 to High(va1) do begin
    MemTableEh1.RecNo:=i+1;
    DBGridEh1.SelectedRows.CurrentRowSelected := A.InArray(va2[i], va3);
  end;
  MemTableEh1.RecNo:=1;
  MemTableEh1.EnableControls;
  DBGridEh1.ReadOnly:=DynParams['readonly'].AsString = '1';
  Bt_Ok.Visible:= not DBGridEh1.ReadOnly;
end;

procedure TDlg_Order_Complaints.CustomDropDownFormEhReturnParams(
  Sender: TCustomDropDownFormEh; DynParams: TDynVarsEh);
var
  i: Integer;
  st: string;
begin
  st:='';
  MemTableEh1.DisableControls;
  MemTableEh1.First;
  while not MemTableEh1.Eof do begin
   if DBGridEh1.SelectedRows.CurrentRowSelected
     then S.ConcatStP(st, MemTableEh1.FieldByName('id').AsString, #1);
    MemTableEh1.Next;
  end;
  MemTableEh1.EnableControls;
  DynParams['ids_ch'].AsString:= st;
end;

procedure TDlg_Order_Complaints.DBGridEh1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (x > 35)or(DBGridEh1.ReadOnly) then Exit;
  DBGridEh1.SelectedRows.CurrentRowSelected := not DBGridEh1.SelectedRows.CurrentRowSelected;
end;

end.