unit D_SelectUsers;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DBGridEhGrouping, ToolCtrlsEh,
  DBGridEhToolCtrls, DynVarsEh, Vcl.StdCtrls, Vcl.Buttons, EhLibVCL, GridsEh, V_Normal,
  DBAxisGridsEh, DBGridEh, MemTableDataEh, Data.DB, MemTableEh, Vcl.ExtCtrls;

type
  TDlg_SelectUsers = class(TForm_Normal)
    DBGridEh1: TDBGridEh;
    Bt_Ok: TBitBtn;
    Bt_Cancel: TBitBtn;
    DataSource1: TDataSource;
    MemTableEh1: TMemTableEh;
    Bt_Repeat: TBitBtn;
    Img_Info: TImage;
    procedure DBGridEh1SelectionChanged(Sender: TObject);
    procedure DBGridEh1CellClick(Column: TColumnEh);
    procedure DBGridEh1Columns1GetCellParams(Sender: TObject; EditMode: Boolean;
      Params: TColCellParamsEh);
    procedure DBGridEh1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Bt_OkClick(Sender: TObject);
    procedure Bt_RepeatClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    MultiSelect: Boolean;
    Ids: string;
    FormDoc1: string;
    NewIds_, NewNames_: string;
    History: TStringList;
    procedure GetResult;
    function LoadData: Boolean;
  public
    { Public declarations }
    function ShowDialog(AFormDoc1: string; AIds: string; AMultiSelect: Boolean; var NewIds: string; var NewNames: string): Integer;
  end;

var
  Dlg_SelectUsers: TDlg_SelectUsers;

implementation

{$R *.dfm}

uses
  uData, uForms, uDBOra, uString, uMessages, System.Types, uSettings;

//����� ���������� �������� ������ ��� ��������� � ������� ����� dgMultiSelect



procedure TDlg_SelectUsers.DBGridEh1Columns1GetCellParams(Sender: TObject;
  EditMode: Boolean; Params: TColCellParamsEh);
begin
exit;
  if MultiSelect then Exit;
  //���� ����� �� ������ �� ��� ����� �� ������� ��������� ������� � ����������
  if DBGridEh1.SelectedRows.CurrentRowSelected then
    Params.CheckboxState := cbChecked
  else
    Params.CheckboxState := cbUnchecked;
end;

//���� ������
procedure TDlg_SelectUsers.DBGridEh1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  //������ ����� ���� ���� � ��������� ����� ����� �����
  //�� ����� ��� ���������� ������ ������� ����������, ������ ������ ����������
  if MultiSelect then Exit;
  if x > 35 then exit;
  DBGridEh1.SelectedRows.Clear;
  DBGridEh1.SelectedRows.CurrentRowSelected := True;
end;

procedure TDlg_SelectUsers.DBGridEh1SelectionChanged(Sender: TObject);
var i: Integer;
begin
end;

procedure TDlg_SelectUsers.FormCreate(Sender: TObject);
begin
  inherited;
  History:=TStringList.Create;
end;

procedure TDlg_SelectUsers.Bt_OkClick(Sender: TObject);
begin
  if DBGridEh1.SelectedRows.Count = 0 then exit;
  ModalResult:=mrOk;
  Hide;
end;

procedure TDlg_SelectUsers.Bt_RepeatClick(Sender: TObject);
begin
  IDs:=History.Values[FormDoc1];
  LoadData;
end;

procedure TDlg_SelectUsers.DBGridEh1CellClick(Column: TColumnEh);
begin
{DBGridEh1.SelectedRows.Clear;
DBGridEh1.SelectedRows.CurrentRowSelected := True;
exit;}
//  if Column.FieldName = 'name' then
  begin
//  DBGridEh1.Datasource.Dataset.GetBookmark;
{    if DBGridEh1.SelectedRows.Count = 0 then
      DBGridEh1.SelectedRows.CurrentRowSelected := True
    else if DBGridEh1.SelectedRows.CurrentRowSelected then
      DBGridEh1.SelectedRows.CurrentRowSelected := False;}
  end;
end;

procedure TDlg_SelectUsers.GetResult;
begin
  NewIds_:='';
  NewNames_:='';
  MemTableEh1.DisableControls;
  MemTableEh1.First;
  while not MemTableEh1.Eof do
    begin
    if DBGridEh1.SelectedRows.CurrentRowSelected then
      begin
        S.ConcatStP(NewIds_, MemTableEh1.FieldByName('id').AsString, ',');
        S.ConcatStP(NewNames_, MemTableEh1.FieldByName('name').AsString, '; ');
      end;
    MemTableEh1.Next;
  end;
  MemTableEh1.EnableControls;
end;

function TDlg_SelectUsers.LoadData: Boolean;
begin
  Q.QLoadToMemTableEh('select (select count(*) from adm_users u2 where u2.id in (' + S.IIf(Ids<>'', Ids, '-123456789') + ') and u2.id = u1.id) as value, name, id from adm_users u1 where id>0 order by name', [], MemTableEh1, 'value;name;id');
  MemTableEh1.First;
  while not MemTableEh1.Eof do
    begin
      DBGridEh1.SelectedRows.CurrentRowSelected := MemTableEh1.FieldByName('value').AsBoolean;
      MemTableEh1.Next;
    end;
  MemTableEh1.First;
end;


function TDlg_SelectUsers.ShowDialog(AFormDoc1: string; AIds: string; AMultiSelect: Boolean; var NewIds: string; var NewNames: string): Integer;
var
  i: Integer;
begin
  FormDoc1:=AFormDoc1;
  Ids:=AIds;
  MultiSelect:=AMultiSelect;
  MemTableEh1.Close;
  //������� ����������� �����
  MemTableEh1.FieldDefs.Clear;
  //���������� ����
  MemTableEh1.FieldDefs.Add('value', ftBoolean, 0, False);
  MemTableEh1.FieldDefs.Add('name', ftString, 100, False);
  MemTableEh1.FieldDefs.Add('id', ftInteger, 0, False);
 //������� �������
  MemTableEh1.CreateDataSet;
  if MultiSelect
    then DbGridEh1.options:=DbGridEh1.options + [dgMultiSelect]
    else DbGridEh1.options:=DbGridEh1.options - [dgMultiSelect];
//  QLoadToMemTableEh('select 0 as value, name, id from adm_users order by name', null, MemTableEh1, 'value;name;id');
  LoadData;
  Cth.SetDialogForm(Self, fNone, '����� �������������');
  Cth.SetInfoIcon(Img_Info,Cth.SetInfoIconText(Self, [
   ['����� �������������.'#13#10],
   ['�������� �������� ������� ������������.'#13#10, not MultiSelect],
   ['�������� �������� ������ ��� ���������� �������������.'#13#10, MultiSelect],
   ['����������� ������ "���������" ��� ���������� ������, ���������� � ������� ��� � ���� ����.'#13#10]
  ]), 20);
  //Self.Width:=572;
  //Self.Height:=500;
  MinWidth:=400;
  MinHeight:=400;
  BorderStyle:=bsSizeable;
  Settings.RestoreWindowPos(Self, FormDoc);
  Result:=ShowModal;
  Settings.SaveWindowPos(Self, FormDoc);
  GetResult;
  NewIds:=NewIds_;
  NewNames:=NewNames_;
  Dlg_SelectUsers.History.Add(Formdoc1 + '=' + NewIds);
end;


end.













while not Table1.Eof do
begin
if DBGrid1.SelectedRows.CurrentRowSelected then
//�� �� ���-�� ������ - ���������� ���������� ������-�� ���� ������ � ��������� �������
ShowMessage(Table1.FieldByName('Numb').AsString);
Table1.Next;
Application.ProcessMessages;
end;


if Grid.SelectedRows.Count >= 0 then   // ���� ���� �������� ������ - ���� �� ���,
   begin
        ABSQuery.DisableControls;// ���� ��������� ����� �������� ����� - ��� �������� �������� ������� �� ���...
        for i := 0 to Grid.SelectedRows.Count-1 do
          begin
          ...
          ABSQuery.GotoBookmark(TBookmark(Grid.SelectedRows[i]));  // ������ �� ������� "���������" ������ �����, �.�. ��������������� ������
          ... ����� ���-�� ������ � ��������������� �������
          ...
          end;
        ABSQuery.EnableControls;






        ..��������� ����������
� ����� � ������� ���:
ExpandedWrap disabled
    if DBGridEh1.SelectedRows.Count>0 then
      begin
        for i:=0 to DBGridEh1.SelectedRows.Count-1 do
          if pointer(DBGridEh1.SelectedRows.Items[i])<>nil then
            begin
              MainForm.ClientDataSet1.GotoBookmark(pointer(DBGridEh1.SelectedRows.Items[i]));
              MainForm.ClientDataSet1.Delete;
            end;
      end;

� ���� ��� ����� ��� ������� �� ����� ������� delete ��� �������� �� ����������. ������� ������, �� ������ ��������� �� ����