unit D_Otk;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_Normal, DBGridEhGrouping, ToolCtrlsEh,
  DBGridEhToolCtrls, DynVarsEh, MemTableDataEh, Data.DB, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Buttons, MemTableEh, Vcl.Mask, DBCtrlsEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh,
  uData
  ;

type
  TDlg_Otk = class(TForm_Normal)
    DBGridEh1: TDBGridEh;
    E_PPComment: TDBEditEh;
    MemTableEh1: TMemTableEh;
    DataSource1: TDataSource;
    Bt_Ok: TBitBtn;
    Bt_Cancel: TBitBtn;
    Img_Info: TImage;
    Lb_Caption: TLabel;
    procedure Bt_OkClick(Sender: TObject);
    procedure MemTableEh1AfterPost(DataSet: TDataSet);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    ID: string;
    ID_Order, Pos, Qnt: Integer;
    Changed: Boolean;
    InLoad: Boolean;
  public
    { Public declarations }
    function ShowDialog(aMode: TDialogType; aID: string; aID_Order, aPos: Integer; aQnt: Integer; aName: string): Boolean;
  end;

var
  Dlg_Otk: TDlg_Otk;

implementation

{$R *.dfm}

uses
  DateUtils,
  uSettings,
  uForms,
  uDBOra,
  uString,
  uMessages
  ;

procedure TDlg_Otk.Bt_OkClick(Sender: TObject);
var
  i, r, qnt_: Integer;
  d, erra: TVarDynArray;
  err: Boolean;
  res: Integer;
begin
  Mth.Post(MemTableEh1);
  if not Changed then begin
//    MyWarningMessage('������ �� ��������!');
    ModalResult:=mrCancel;
    Exit;
  end;
  d:=[];
  qnt_:=0;
  erra:=[False, False, False];
  err:=False;
  r:=MemTableEh1.RecNo;
  for i:=1 to MemTableEh1.RecordCount do begin
    MemTableEh1.RecNo:=i;
    if MemTableEh1.FieldByName('qnt').AsInteger = 0 then Continue;
    if ((MemTableEh1.FieldByName('dt').AsVariant = null) or (MemTableEh1.FieldByName('dt').AsDateTime > Date))
      then begin err:=True; Break; end;
      d:=d + [MemTableEh1.FieldByName('dt').AsDateTime];
    if MemTableEh1.FieldByName('qnt').AsInteger < 0
      then begin err:=True; Break; end;
    qnt_:=qnt_+MemTableEh1.FieldByName('qnt').AsInteger;
  end;
  MemTableEh1.RecNo:=r;
  if not err then err:=qnt_ > Qnt;
  if not err then begin
    A.VarDynArraySort(d);
    for i:=1 to High(d) do
      if d[i] = d[i-1]
        then begin err:=True; Break; end;
  end;
  if err then begin
    MyWarningMessage('������ �����������!');
    ModalResult:=mrNone;
    Exit;
  end;
  Q.QBeginTrans(True);
  res:=Q.QExecSql('delete from order_otk where id_order = :id_order$i and pos = :pos$i', [ID_Order, Pos], False);
  if res >= 0 then begin
    for i:=1 to MemTableEh1.RecordCount do begin
      MemTableEh1.RecNo:=i;
      if MemTableEh1.FieldByName('qnt').AsInteger = 0 then Continue;
      res:=Q.QExecSql('insert into order_otk (id_order, pos, dt, qnt) values (:id_order$i, :pos$i, :dt$d, :qnt$i)',
        [ID_Order, Pos, MemTableEh1.FieldByName('dt').AsDateTime, MemTableEh1.FieldByName('qnt').AsInteger], False
      );
      if res < 0 then Break;
    end;
  end;
  Q.QCommitOrRollback(res >= 0);
  if not Q.CommitSuccess then begin
    MyWarningMessage('�� ������� ��������� ������!');
    ModalResult:=mrNone;
    Exit;
  end;
  ModalResult:=mrOk;
//  ModalResult:=mrnone;
end;

procedure TDlg_Otk.FormActivate(Sender: TObject);
begin
  inherited;
  //�������, ����� �������� ������� ��� ����
  Img_Info.top:=bt_ok.top+4;
end;

procedure TDlg_Otk.FormKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  //����� ������� ����� �� Esc, ���� �� ������ �������� � ������, ��� ��� ����� ������� ����� ��� ������ ��������������
  //��� ����� KeyPreview:=True;
  //�� �� ���������� ������ ������ �� ��������, ���� ������� �� ������� �������
  Exit;
  if DBGridEh1.InplaceEditor.Focused then Exit;
  ModalResult:=mrCancel;
  Hide;
end;

procedure TDlg_Otk.MemTableEh1AfterPost(DataSet: TDataSet);
begin
  inherited;
  Changed:=True;
end;

function TDlg_Otk.ShowDialog(aMode: TDialogType; aID: string; aID_Order, aPos: Integer; aQnt: Integer; aName: string): Boolean;
begin
  InLoad:=True;
  Mode:=aMode;
  ID:=aID; ID_Order:= aID_Order; Pos:= aPos; Qnt:=aQnt;
  Cth.SetDialogForm(Self, Mode, '����� ���');
  Cth.SetInfoIcon(Img_Info,Cth.SetInfoIconText(Self, [
   ['������� ������ �� ������ ��� ��� �������.'#13#10+
    '���������� ������, ��������� ������� "������� ����", ��� ��������� ��������� ����� ������.'#13#10+
    '��� �������� ������ ��������� ������� ����������.'#13#10+
    '���� ������ �� �����, �� ��� �� ����������!'#13#10+
    '����������� ����� ���������� � �������, ������� ���������� ��� ������� �������, ����, ������� �������, � ������� ���!'#13#10,
   Mode<>fView]
  ]), 20);
 { Img_Info.Visible:=True;
  Img_Info.left:=1;
  Img_Info.top:=bt_ok.top+4;
  Img_Info.top:=240;}
  Lb_Caption.Caption:=aName + ' ('+ IntToStr(Qnt) + ' ��.)';
  if DBGridEh1.Columns.Count = 1 then begin
    MemTableEh1.DataDriver:=nil;
    MemTableEh1.FieldDefs.Clear;
    MemTableEh1.close;
//    Mth.AddTableColumn(DBGridEh1, 'id', ftInteger, 0, 'ID', 20, True);
    Mth.AddTableColumn(DBGridEh1, 'dt', ftDate, 0, '����', 85, True);
    Mth.AddTableColumn(DBGridEh1, 'qnt', ftInteger, 0, '���-��', 85, True);
    MemTableEh1.CreateDataSet;
  end;
//  Gh._SetDBGridEhSumFooter(DBGridEh1, 'qnt', '0');
  Gh.SetGridColumnsProperty(DBGridEh1, cptSumFooter, 'qnt', '0');
  MemTableEh1.ReadOnly:=False;
  //������� ������,
  //��� ������ ��� ������ ����������� � ����� �� ���,
  //� ��� ���������� ������ ���, ��� ��� ������ � �� ��� ��� �������
  Q.QLoadToMemTableEh(
    'select dt, qnt from order_otk where id_order = :id_order$i and pos = :pos$i order by dt',
    [ID_Order, Pos],
    MemTableEh1,
    'dt;qnt'
  );
  MemTableEh1.Last;
//  Bt_Ok.Enabled:=False;
  Bt_Cancel.Cancel:=False;
  if Mode <> fView then MemTableEh1.Append;
  InLoad:=False;
  Changed:=False;
  KeyPreview:=True;
  Result:=ShowModal = mrOk;
end;

end.
