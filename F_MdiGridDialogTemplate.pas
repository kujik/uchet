unit F_MdiGridDialogTemplate;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, MemTableDataEh, Data.DB,
  DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, Vcl.Mask,
  DBCtrlsEh, GridsEh, DBAxisGridsEh, DBGridEh, MemTableEh, uData,
  uForms, uDBOra, uString, uMessages, V_MDI, uLabelColors, EhLibVclUtils;

type
  TForm_MdiGridDialogTemplate = class(TForm_MDI)
    pnl_Buttons: TPanel;
    Img_Info: TImage;
    Bt_OK: TBitBtn;
    Bt_Cancel: TBitBtn;
    chb_NoClose: TCheckBox;
    Bt_Add: TBitBtn;
    Bt_Del: TBitBtn;
    Bev_Buttons: TBevel;
    pnl_Bottom: TPanel;
    pnl_Top: TPanel;
    pnl_Client: TPanel;
    MemTableEh1: TMemTableEh;
    DataSource1: TDataSource;
    DBGridEh1: TDBGridEh;
    edt_PPComment: TDBEditEh;
    //MemTableEh
    procedure MemTableEh1AfterScroll(DataSet: TDataSet);
    procedure MemTableEh1AfterPost(DataSet: TDataSet);
    //DbGridEh
    procedure DBGridEh1ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); virtual;
    procedure CellButtonClick(Sender: TObject; var Handled: Boolean); virtual;
    //Buttons
    procedure Bt_OKClick(Sender: TObject);
    procedure Bt_CancelClick(Sender: TObject);
    procedure Bt_DelClick(Sender: TObject);
    procedure Bt_AddClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DBGridEh1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell,
      AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect;
      var Params: TColCellParamsEh; var Processed: Boolean);
    procedure MemTableEh1AfterOpen(DataSet: TDataSet);
    procedure MemTableEh1AfterRefresh(DataSet: TDataSet);
    procedure DBGridEh1ColEnter(Sender: TObject);
  private
    { Private declarations }
  protected
    Ok: Boolean;                            //������ ��������
    InfoArr: TVarDynArray2;                 //������ �������� [[test1{False|True}],[text2...],]
    AddLast: Boolean;                       //�� ������ �������� ��������� ������ � ����� ������� (����� � ������� �������)
    AddIfNotempty: Boolean;                 //��������� ������ ������ ���� ������� (��� AddLast ���������) ��������� ���������� (����� ���� id)
    OneRowOnOpen: Boolean;                  //���� ���� ����������� ������ � ������ ������������� ��� ����������, �� ����� �������� ������ ������
    AddRowIfFAddOnOpen: Boolean;            //���� fAdd �� ����� ������� ������ � �����
    AllowEmptyTable: Boolean;               //��� ������� �� ������� ������ ������� ���������� �����������
    FieldsEmpty: string;                    //����� ����� ����� �������, ������� ����������� ������� ������  /�� ������������
    FieldsService: string;                  //��������� ���� (������ �������) �� ��������� ��� "id"
    FieldsReadOnly: string;
    ColumnsVerifications: TVarDynArray;     //������ ������ �������� �������� ��������
    FieldsNoRepaeted: string;               //������ ����� ����� ;, �������� ������� � ������� ����� ���� �� ������ (����������� � IsTableCorrect)
    IdFieldName: string;

    IdFieldPos: Integer;                    //����� ���� ID � MemTable, -1 ���� ��� ���

    FieldNameCurr: string;
    RowId: Variant;


    DeletedIds: TVarDynArray;               //���� � ������� ���� ���� 'id', �� ��� �������� ������ ��� ���������� � ���� ������
                                            //� ��� ����� ���� � ���� ������������ ��������� �����
    ChangedIds: TVarDynArray;               //���� � ������ ������ ��� ������ ����, �� ���� ���������� �������� ���� 'id' ���� ������
                                            //�� ���������� ��������� ����� � �� ����, �� ��� ������ �������� ������ ��, �� �����������.

    IncorrectRowNo: Integer;
    IncorrectRowColumn: Integer;
    IncorrectRowMsg: string;



    function Prepare: Boolean; override;
    //��������� ��� ��������� ������ � ����
    //���� AddLast �� ������� � �����, ����� �������
    //������� ������ ���� ������� ������ ��������� ���� �� �������� (��� AddIfNotempty)
    //� ������� ������ ��������� (������ ��������� ������������� � �� ��������� ���������� True:
    //��� ���� ����� ��� ����������� ����������� �� �������� ������, ����� ��������� �� ��� ������ �����)
    procedure AddRow; virtual;
    //������� ������ �� �����
    procedure DelRow; virtual;
    procedure RowDisable; virtual;
    //������� ���� � �������� (����, ���������...). ���������� � Prepare, ����������� �������������.
    //���� �� ������ True, ����� �� ����� ��������
    function InitGrid: Boolean; virtual;
    //�������������� �������� �������, ������� ���������� � Prepare.
    //���� �� ������ True, ����� �� ����� ��������
    function InitAdd: Boolean; virtual;
    //���������� ������� ��� ����� ������ � ������ ����� �������.
    procedure SetDBGridEh1ColumnsUpdateData;
    //������ True, ���� � ������ ���� ���� �� ��������� ���� �� null (��� ����� ������� ����� True)
    function IsRowNotEmpty: Boolean; virtual;
    //������ ����, ���� ������ ��������� ���������
    //�� ��������� ��������� � ����������� � ColumnsVerify (���� ��������� �� ����� �� ������ True)
    //������ ������ ����������
    function IsRowCorrect: Boolean; virtual;
    //������ ����, ���� � ������� ��� ������ ������
    //��� ���� ������ ������ ��������� �������
    function IsTableCorrect: Boolean;
    //������ ����, ���� � ������� ��� ����� ���� ��� ��������� ���� ������ ������
    function IsTableEmpty: Boolean;
    //������ ��������� ������ ���������� ������������ ������ � ������� ���������,
    //������� ���������� ���� ��� ������� ������ �� ����� ��������, ���� ���� ������;
    //���� ��������� �����, �� ��� ������� �������� ������
    //���� ��� ����� "-", �� ������ �������, �� ������ �� ���������,
    //���� "*" ��������� "������ �� ���������!"
    //�� ��������� ��������� ������������� IsTableCorrect, � ���� �� AllowEmptyTable �� IsTableEmpty
    function  VerifyBeforeSave: string; virtual;
    //���������� ��� ��������� ������� ������ � �������� ��� �������� �������, ��� ��� ���������� ������ ������/�������
    procedure ChangeSelectedData; virtual;
    //���������� ��� ��������� ������� ������ � �������� ����������� �������������� �����
    //��������� ������� ReadOnly ��� ���� �������
    procedure SetCellEditable; virtual;
    //���������� True, ���� � ������� ���� ����������� ������.
    function  IsTableAdded: Boolean;
    //��������� �������. ������ ���� ��������� ��� ������������� ���������� ��� ������� ��
    //��������� ���� � ������� ��� ��������� ������ (����� VerifyBeforeSave)
    function  Save: Boolean; virtual;
  public
    { Public declarations }
  end;

var
  Form_MdiGridDialogTemplate: TForm_MdiGridDialogTemplate;

implementation

{$R *.dfm}

//Buttons///////////////////////////////////////////////////////////////////////

procedure TForm_MdiGridDialogTemplate.Bt_OKClick(Sender: TObject);
//���� �� ��, ������������ ���������� ������ ������� ����� ��������
var
  Msg: string;
begin
  inherited;
  //�������� �������
  Msg := VerifyBeforeSave;
  if Msg <> '' then begin
    MyWarningMessage(Msg, ['*������ �� ���������!', '-']);
    Exit;
  end;
  if not Save then begin
    MyWarningMessage('�� ������� ��������� ������!');
    Exit;
  end;
  Close;
end;

procedure TForm_MdiGridDialogTemplate.Bt_CancelClick(Sender: TObject);
begin
  inherited;
  Close;
end;

procedure TForm_MdiGridDialogTemplate.Bt_AddClick(Sender: TObject);
begin
  inherited;
  AddRow;
end;

procedure TForm_MdiGridDialogTemplate.Bt_DelClick(Sender: TObject);
begin
  inherited;
  DelRow;
end;


//MemTableEh///////////////////////////////////////////////////////////////////

procedure TForm_MdiGridDialogTemplate.MemTableEh1AfterOpen(DataSet: TDataSet);
begin
  inherited;
  ChangeSelectedData;
end;

procedure TForm_MdiGridDialogTemplate.MemTableEh1AfterPost(DataSet: TDataSet);
begin
  inherited;
  ChangeSelectedData;
end;

procedure TForm_MdiGridDialogTemplate.MemTableEh1AfterRefresh(
  DataSet: TDataSet);
begin
  inherited;
  ChangeSelectedData;
end;

procedure TForm_MdiGridDialogTemplate.MemTableEh1AfterScroll(DataSet: TDataSet);
begin
  inherited;
  ChangeSelectedData;
end;

procedure TForm_MdiGridDialogTemplate.DBGridEh1AdvDrawDataCell(
  Sender: TCustomDBGridEh; Cell, AreaCell: TGridCoord; Column: TColumnEh;
  const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean);
begin
  //inherited;
  Gh.DBGridEhAdvDrawDataCellDefault(Sender, Cell, AreaCell, Column, ARect, Params, Processed);
end;

procedure TForm_MdiGridDialogTemplate.DBGridEh1ColEnter(Sender: TObject);
begin
  inherited;
  ChangeSelectedData;
end;

procedure TForm_MdiGridDialogTemplate.DBGridEh1ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
//��� ���������� ������ ���������������
var
  NoErr: Boolean;
  i, j, i1: Integer;
  FieldName: string;
  dt: TDateTime;
  v: Variant;
  NewValue: Variant;
  b: Boolean;

  procedure SetFieldValue;
  begin
    if UseText then
      TColumnEh(Sender).Field.AsString := S.NSt(Value)
    else
      TColumnEh(Sender).Field.AsVariant := Value;
  end;

begin
  FieldName := LowerCase(DBGridEh1.Columns[DBGridEh1.Col - 1].Field.FieldName);
  Value := S.IIf(UseText, Text, Value);
  NewValue := Value;
  b := Gh.VeryfyCoumnEhValue(TColumnEh(Sender), Value, NewValue);
  if not b then
    NewValue := null;
  if NewValue = '' then
    NewValue := null;
  TColumnEh(Sender).Field.AsVariant := NewValue;
//  SetFieldValue; //��������� ����
  Mth.PostAndEdit(MemTableEh1);
  if (IdFieldPos >= 0)and(MemTableEh1.FieldByName('id').Value <> null)and(not A.InArray(MemTableEh1.FieldByName('id').Value, ChangedIds))
    then ChangedIds:=ChangedIds + [MemTableEh1.FieldByName('id').Value];
  Handled := True;     //������� �� ������!!!????
end;

procedure TForm_MdiGridDialogTemplate.CellButtonClick(Sender: TObject; var Handled: Boolean);
begin
 //
end;


//Subroutines///////////////////////////////////////////////////////////////////

procedure TForm_MdiGridDialogTemplate.ChangeSelectedData;
//����� ������������ ��������� �������� ������, �������� �������, � ������ ���������� ������ � ������ �����\
//��������� ������� �������
//��������� ������� ����
//��������� ����������� ������ � ������� ����
//��������� ��������������� ����
var
  i: Integer;
  va: TmybtArr;
begin
  if not MemTableEh1.Active then
    Exit;
  //������� �������
  FieldNameCurr := LowerCase(DBGridEh1.Columns[DBGridEh1.Col - 1].Field.FieldName);
  //������� ���� ������� ������
  if (IdFieldPos >= 0) then
    RowId := MemTableEh1.Fields[IdFieldPos].AsVariant;
  SetCellEditable;
end;

procedure TForm_MdiGridDialogTemplate.SetCellEditable;
//���������� ��� ��������� ������� ������ � �������� ����������� �������������� �����
//��������� ������� ReadOnly ��� ���� �������
begin
  if Mode in [fView, fDelete] then Exit;
end;

function TForm_MdiGridDialogTemplate.Save: Boolean;
begin
  Result:=True;
end;

procedure TForm_MdiGridDialogTemplate.AddRow;
var
  i: Integer;
  b: Boolean;
begin
  //���� ��������� � ����� - �������� �� �������� ������
  if AddLast then
    MemTableEh1.Last;
  //������� ������ ���� ������� ������ ��������� ���� �� �������� (��� AddIfNotempty)
  //� ������� ������ ��������� (������ ��������� ������������� � �� ��������� ���������� True:
  //��� ���� ����� ��� ����������� ����������� �� �������� ������, ����� ��������� �� ��� ������ �����)
  if not ((not AddIfNotempty or IsRowNotEmpty) and IsRowCorrect) then
    Exit;
  MemTableEh1.ReadOnly := False;
  MemTableEh1.Append;
end;

procedure TForm_MdiGridDialogTemplate.DelRow;
var
  oldid: Variant;
begin
//  MemTableEh1.ReadOnly := False;
{  if MemTableEh1.RecordCount = 0 then Exit;
  //���� ���������� �� ��������������, �� �� �������
  RowDisable;
  if MemTableEh1.ReadOnly then Exit;
  if (MemTableEh1.FieldByName('id').Value <> null)and(VarToDateTime(MemTableEh1.FieldByName('id').Value) < DtEditMin) then Exit;
  oldid:=MemTableEh1.FieldByName('id').Value;
  if not((oldid = null)or(MyQuestionMessage('������� ������?') = mrYes)) then Exit;
  if oldid <> null then begin
    DeletedItems:=DeletedItems + [MemTableEh1.FieldByName('id').Value];
    Changed:=True;
  end;         }
  if (IdFieldPos >= 0)and(MemTableEh1.FieldByName('id').Value <> null)and(not A.InArray(MemTableEh1.FieldByName('id').Value, DeletedIds))
    then DeletedIds:=DeletedIds + [MemTableEh1.FieldByName('id').Value];
  Mth.PostAndEdit(MemTableEh1);
  MemTableEh1.ReadOnly:=False;
  MemTableEh1.Delete;
  //RowDisable;
end;

procedure TForm_MdiGridDialogTemplate.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  ///
end;

procedure TForm_MdiGridDialogTemplate.RowDisable;
begin
  {(*}
  //��������� ��������� ����� �� �����, ��� ������� (������ ����� � ������ �������) ����������� ������� �������
  MemTableEh1.ReadOnly := (not (Mode in [fView, fDelete]));
  {*)}
end;

function  TForm_MdiGridDialogTemplate.IsTableAdded: Boolean;
begin

end;

function TForm_MdiGridDialogTemplate.IsRowNotEmpty: Boolean;
//������ True, ���� � ������ ���� ���� �� ��������� ���� �� null (��� ����� ������� ����� True)
var
  i: Integer;
begin
  Result := True;
  if (MemTableEh1.RecordCount = 0) then
    Exit;
  for i := 0 to MemTableEh1.Fields.Count - 1 do
    if not s.InCommaStrI(MemTableEh1.Fields[i].FieldName, FieldsService) and (MemTableEh1.Fields[i].Value <> null) then
      Exit;
  Result := False;
end;

function TForm_MdiGridDialogTemplate.IsRowCorrect: Boolean;
//������ ����, ���� ������ ��������� ���������
//�� ��������� ��������� � ����������� � ColumnsVerify (���� ��������� �� ����� �� ������ True)
//������ ������ ����������
var
  i: Integer;
  v: Variant;
begin
  Result := True;
  if not IsRowNotEmpty then
    Exit;
  for i := 0 to DBGridEh1.Columns.Count - 1 do
    if not Gh.VeryfyCoumnEhValue(DBGridEh1.Columns[i], DBGridEh1.Columns[i].Field.Value, v) then begin
      Result := False;
      IncorrectRowNo:=MemTableEh1.RecNo;
      IncorrectRowColumn:=i;
      IncorrectRowMsg:='��������� �������� ������ ' + InttoStr(MemTableEh1.RecNo) + ' � ������ "' + DBGridEh1.Columns[i].Title.Caption + '"';
      Exit;
    end;
end;

function TForm_MdiGridDialogTemplate.IsTableEmpty: Boolean;
//������ ����, ���� � ������� ��� ����� ���� ��� ��������� ���� ������ ������
var
  rn, i: Integer;
begin
  Result := True;
  rn := MemTableEh1.RecNo;
  MemTableEh1.RecNo := 1;
  for i := 1 to MemTableEh1.RecordCount do begin
    Result := not IsRowNotEmpty;
    if not Result then
      Break;
  end;
  MemTableEh1.RecNo := rn;
end;

function TForm_MdiGridDialogTemplate.IsTableCorrect: Boolean;
//������ ����, ���� � ������� ��� ������ ������
//��� ���� ������ ������ ��������� �������
var
  rn, i, j, k, m: Integer;
  va1: TVarDynArray;
begin
  Result := True;
  va1 := A.Explode(FieldsNoRepaeted, ';', True);
  rn := MemTableEh1.RecNo;
  MemTableEh1.RecNo := 1;
  for i := 1 to MemTableEh1.RecordCount do begin
    MemTableEh1.RecNo := i;
    if not IsRowNotEmpty then Continue;  //������ ������ ����������
    Result := IsRowCorrect;
    if not Result then
      Break;
  end;
  if Result then
    for j := 0 to High(va1) do begin
      for k := 0 to MemTableEh1.RecordsView.MemTableData.RecordsList.Count - 2 do
        for m := k + 1 to MemTableEh1.RecordsView.MemTableData.RecordsList.Count - 1 do
          if MemTableEh1.RecordsView.MemTableData.RecordsList[k].DataValues[va1[j], dvvValueEh] = MemTableEh1.RecordsView.MemTableData.RecordsList[m].DataValues[va1[j], dvvValueEh] then begin
            Result := False;
            IncorrectRowMsg:='������������� �������� � ������� ' + InttoStr(k + 1) + ' � ' + InttoStr(m + 1) + ' � ������� "' + DBGridEh1.FindFieldColumn(va1[j]).Title .Caption+ '"';
            break
          end;
    end;
  MemTableEh1.RecNo := rn;
end;

function TForm_MdiGridDialogTemplate.VerifyBeforeSave: string;
//������ ��������� ������ ���������� ������������ ������ � ������� ���������,
//������� ���������� ���� ��� ������� ������ �� ����� ��������, ���� ���� ������;
//���� ��������� �����, �� ���� ������� �������� ������
//���� ��� ����� "-", �� ������ �������, �� ������ �� ���������,
//���� "*" ��������� "������ �� ���������!"
//�� ��������� ��������� ������������� IsTableCorrect, � ���� �� AllowEmptyTable �� IsTableEmpty
begin
  if (AllowEmptyTable and IsTableEmpty) or (not IsTableEmpty and IsTableCorrect) then
    Result := ''
  else
    Result := IncorrectRowMsg; //'*';
end;

procedure TForm_MdiGridDialogTemplate.SetDBGridEh1ColumnsUpdateData;
var
  i: Integer;
begin
  for i := 0 to DBGridEh1.Columns.Count - 1 do
    if DBGridEh1.Columns[i].Visible then
      DBGridEh1.Columns[i].onUpdateData := DBGridEh1ColumnsUpdateData;
end;



//Prepare///////////////////////////////////////////////////////////////////////

function TForm_MdiGridDialogTemplate.InitGrid: Boolean;
//������� ���� � �������� (����, ���������...). ���������� � Prepare, ����������� �������������.
//���� �� ������ True, ����� �� ����� ��������
begin
  Result := True;
end;

function TForm_MdiGridDialogTemplate.InitAdd: Boolean;
//�������������� �������� �������, ������� ���������� � Prepare.
//���� �� ������ True, ����� �� ����� ��������
begin
  Result := True;
end;

function TForm_MdiGridDialogTemplate.Prepare: Boolean;
var
  i, j: Integer;
  c: TControl;
begin
  Result := False;
  //�������� ����������, ������ ���� ������ ����� (��� ������� �������������� ����� � ��������, ��� �������� - �����)
  if FormDbLock = fNone then Exit;
  //����������� ���������, � ����������� �� ������, ����� ��� ������/��������� - ������ �������
//  SetControlsEditable([], Mode in [fEdit, fCopy, fAdd]);
  //Cth.DlgSetControlsEnabled(Self, Mode, [], []);
  AutoSaveWindowPos := True;
  FieldsService := 'id';
  //�������������� � ��� ������������� �������� ���� (�������� ��������)
  if not InitGrid then
    Exit;
  //������� ������� ���� ���� � ��������, ���� ��� ����
  IdFieldPos:=-1;
  if DBGridEh1.FindFieldColumn('id') <> nil
    then IdFieldPos:=MemTableEh1.FieldByName('id').FieldNo;
  //�������������� ��� ���������� (���� �����, �������� ��������)
  if not InitAdd then
    Exit;
  if OneRowOnOpen and (MemTableEh1.RecordCount = 0) then
    MemTableEh1.Append;
  if AddRowIfFAddOnOpen and (Mode = fAdd) then
    MemTableEh1.Append;
  //��������� ������� ��� ��������������� � ������
  SetDBGridEh1ColumnsUpdateData;
  for i := 0 to High(ColumnsVerifications) do
    Gh.SetVeryfyCoumnEhRule(DBGridEh1.Columns[i], ColumnsVerifications[i]);
  for i := 0 to DBGridEh1.Columns.Count - 1 do
    if S.InCommaStrI(DBGridEh1.Columns[i].FieldName, FieldsReadOnly, ';') then
      DBGridEh1.Columns[i].ReadOnly := True
    else
      DBGridEh1.Columns[i].ReadOnly := not (Mode in [fAdd, fEdit, fCopy]);
  DBGridEh1.ReadOnly := Mode in [fView, fDelete];
  //��������� ����� � ������ � ����������� �� ������
  Cth.SetDialogForm(Self, Mode, Caption);
  //������ ���������
  Cth.SetInfoIcon(Img_Info, Cth.SetInfoIconText(Self, InfoArr), 20);
  ChangeSelectedData;
//  Serialize;
//  CtrlBegValuesStr:= CtrlCurrValuesStr;
  SetStatusBar('', '', False);
//  Verify(nil);
//  pnl_Bottom.Align := alNone;
//  pnl_Bottom.Top:=Self.ClientHeight - StatusBar.Height - pnl_Bottom.Height;
//  pnl_Bottom.Align := alBottom;
  //���. ������
  Cth.SetBtn(Bt_Add, mybtAdd, True);
  Cth.SetBtn(Bt_Del, mybtDelete, True);
  Bt_Add.Visible := Mode in [fEdit, fAdd, fCopy];
  Bt_Del.Visible := Bt_Add.Visible;
  Bev_Buttons.Visible := Bt_Add.Visible;
  chb_NoClose.Visible := False;
  Result := True;
end;

end.

