unit D_Order_Stages1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_Normal, MemTableDataEh, Data.DB,
  DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.Mask, DBCtrlsEh, EhLibVCL, GridsEh,
  DBAxisGridsEh, DBGridEh, MemTableEh, uLabelColors, Math,
  uDBOra, uData
  ;

type
  TDlg_Order_Stages1 = class(TForm_Normal)
    MemTableEh1: TMemTableEh;
    DBGridEh1: TDBGridEh;
    edt_PPComment: TDBEditEh;
    DataSource1: TDataSource;
    Bt_Ok: TBitBtn;
    Bt_Cancel: TBitBtn;
    Img_Info: TImage;
    lbl_Caption: TLabel;
    Bt_Del: TBitBtn;
    Bt_Add: TBitBtn;
    bvl1: TBevel;
    tmr1: TTimer;
    procedure Bt_OkClick(Sender: TObject);
    procedure MemTableEh1AfterPost(DataSet: TDataSet);
    procedure FormActivate(Sender: TObject);
    procedure MemTableEh1AfterScroll(DataSet: TDataSet);
    procedure DBGridEh1KeyPress(Sender: TObject; var Key: Char);
    procedure DBGridEh1ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
    procedure DBGridEh1SumListAfterRecalcAll(Sender: TObject);
    procedure Bt_AddClick(Sender: TObject);
    procedure Bt_DelClick(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
  private
    { Private declarations }
    ID_Order, ID_Order_Item, ID_Stage: Integer;
    Qnt: Extended;
    DtEditMin: TDateTime; //�������������� ������� � ���� ��� �������� ����� ���� ����
    Changed: Boolean;
    InLoad: Boolean;
    DeletedItems: TVariantDynArray;
    procedure SetCaptionLabel;
    procedure AddRow;
    procedure DelRow;
    procedure RowDisable;
  public
    { Public declarations }
    function ShowDialog(aMode: TDialogType; aID_Order_Item, aID_Stage: Integer; aDtEditMin: TDateTime): Boolean;
  end;

var
  Dlg_Order_Stages1: TDlg_Order_Stages1;

implementation

{$R *.dfm}

uses
  DateUtils,
  uSettings,
  uForms,
  uString,
  uMessages
  ;


procedure TDlg_Order_Stages1.RowDisable;
begin
  //��������� ��������� ����� �� �����, ��� ������� (������ ����� � ������ �������) ����������� ������� �������
  MemTableEh1.ReadOnly:=(Mode <> fEdit)or
    (MemTableEh1.RecordCount >0)and(MemTableEh1.FieldByName('dt').Value <> null)and(MemTableEh1.FieldByName('dt').Value < DtEditMin);
end;


procedure TDlg_Order_Stages1.AddRow;
begin
  if MemTableEh1.RecordCount = 0 then Exit;
  MemTableEh1.Last;
  //������� ������ ���� ��������� ������ ���������
  if (MemTableEh1.FieldByName('dt').AsVariant=null)or(MemTableEh1.FieldByName('qnt').AsVariant=null) then Exit;
  MemTableEh1.ReadOnly:=False;
  MemTableEh1.Append;
end;


procedure TDlg_Order_Stages1.DelRow;
//������ ������
var
  oldid: Variant;
begin
  if MemTableEh1.RecordCount = 0 then Exit;
  //���� ���������� �� ��������������, �� �� �������
  RowDisable;
  if MemTableEh1.ReadOnly then Exit;
  oldid:=MemTableEh1.FieldByName('id').Value;
  //������ ������ ��� �����, ������ ����� �������� ����. ����� ����������� ������� ��� �������
  if not((oldid = null)or(MyQuestionMessage('������� ������?') = mrYes)) then Exit;
  if oldid <> null then begin
    DeletedItems:=DeletedItems + [MemTableEh1.FieldByName('id').Value];
    Changed:=True;
  end;
  MemTableEh1.ReadOnly:=False;
  MemTableEh1.Delete;
  RowDisable;
end;


procedure TDlg_Order_Stages1.Bt_AddClick(Sender: TObject);
begin
  inherited;
  AddRow;
end;

procedure TDlg_Order_Stages1.Bt_DelClick(Sender: TObject);
begin
  inherited;
  DelRow;
end;

procedure TDlg_Order_Stages1.Bt_OkClick(Sender: TObject);
var
  i, r: Integer;
  qq: extended;
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
  qq:=0;
  erra:=[False, False, False];
  err:=False;
  r:=MemTableEh1.RecNo;
  for i:=1 to MemTableEh1.RecordCount do begin
    MemTableEh1.RecNo:=i;
    if MemTableEh1.FieldByName('qnt').AsFloat = 0 then Continue;
    if ((MemTableEh1.FieldByName('dt').AsVariant = null) or (MemTableEh1.FieldByName('dt').AsDateTime > Date))
      then begin err:=True; Break; end;
      d:=d + [MemTableEh1.FieldByName('dt').AsDateTime];
    if MemTableEh1.FieldByName('qnt').AsFloat < 0
      then begin err:=True; Break; end;
    qq:=qq+MemTableEh1.FieldByName('qnt').AsFloat;
  end;
  MemTableEh1.RecNo:=r;
  if not err then err:=qq > Qnt;
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
  res:=0;
  Q.QBeginTrans;
  MemTableEh1.DisableControls;
  for i:=0 to High(DeletedItems) do begin
    res:=Q.QExecSql('delete from order_item_stages where id = :id$i', [DeletedItems[i]]);
    if res < 0 then Break;
  end;
  if res >= 0 then
    for i:=1 to MemTableEh1.RecordCount do begin
      MemTableEh1.RecNo:=i;
      if MemTableEh1.FieldByName('id').Value <> null then begin
        if MemTableEh1.FieldByName('qnt').AsFloat = 0
          then res:=Q.QExecSql('delete from order_item_stages where id = :id$i', [MemTableEh1.FieldByName('id').AsInteger])
          else res:=Q.QExecSql('update order_item_stages set dt = :dt$d, qnt = :qnt$f where id = :id$i',
            [MemTableEh1.FieldByName('dt').AsDateTime, MemTableEh1.FieldByName('qnt').AsFloat, MemTableEh1.FieldByName('id').AsInteger]);
      end
      else begin
        if MemTableEh1.FieldByName('qnt').AsFloat = 0 then continue;
        res:=Q.QExecSql('insert into order_item_stages (id_order_item, id_stage, dt, qnt) values (:id_order_item$i, :id_stage$i, :dt$d, :qnt$f)',
          [ID_Order_Item, ID_Stage, MemTableEh1.FieldByName('dt').AsDateTime, MemTableEh1.FieldByName('qnt').AsFloat], False
        );
      end;
      if res < 0 then Break;
    end;
  if res >= 0 then begin
    res:=Length(Q.QCallStoredProc('p_OrderStage_SetMainTable', 'IdOrder$i;IdStage$i',
        [ID_Order, ID_Stage]
      ))-1;
  end;
  Q.QCommitOrRollback(res >= 0);
  MemTableEh1.EnableControls;
  if res < 0 then begin
    MyWarningMessage('�� ������� ��������� ������!');
    ModalResult:=mrNone;
    Exit;
  end;
  ModalResult:=mrOk;
end;

procedure TDlg_Order_Stages1.DBGridEh1KeyPress(Sender: TObject; var Key: Char);
begin
    //�� ������� ������� + ������� � ����� ������ ������
    //� DBGridEh1KeyDown ������ ��� ��������, ��� ������ ���� ��������� � �������������, �������� ����� �� ��������, ����� ��� � ������ ��� ��� ����� ��������� � ���
    //(�� ����� ������� ��� ���� �� F2, ������� � ������ �� �����)
  inherited;
  if Mode = fView then Exit;
  if key = '+' then begin
    Key:=#0;
    AddRow;
  end;
  if ((key = '=')or(key = ' ')) and (not MemTableEh1.ReadOnly) then begin
    Key:=#0;  //��� �����������, ����� � ��������� �������� ����� =
    //� ���� ���� �������� �������
    if DBGridEh1.Col = 2 then MemTableEh1.FieldByName('dt').Value:=Date;
    //� ���� ���������� �������� �� �������
    if DBGridEh1.Col = 3
      then MemTableEh1.FieldByName('qnt').Value:= Max(0, Qnt - (S.NNum(Gh.GetGridColumn(DBGridEh1, 'qnt').Footer.SumValue) - S.NNum(MemTableEh1.FieldByName('qnt').Value)));
    Mth.PostAndEdit(MemTableEh1);
  end;
end;

procedure TDlg_Order_Stages1.DBGridEh1SumListAfterRecalcAll(Sender: TObject);
begin
  inherited;
  SetCaptionLabel;
end;

procedure TDlg_Order_Stages1.FormActivate(Sender: TObject);
begin
  inherited;
  //�������, ����� �������� ������� ��� ����
  Img_Info.top:=bt_ok.top+4;
end;

procedure TDlg_Order_Stages1.MemTableEh1AfterPost(DataSet: TDataSet);
begin
  inherited;
  Changed:=True;
end;

procedure TDlg_Order_Stages1.MemTableEh1AfterScroll(DataSet: TDataSet);
begin
  inherited;
  if (InLoad)or(Mode = fView) then Exit;
  RowDisable;
end;

procedure TDlg_Order_Stages1.DBGridEh1ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
//��� ���������� ������ ���������������
var
  NoErr:Boolean;
  i,j,i1: Integer;
  FieldName: string;
  dt: TDateTime;
  v:Variant;
  procedure SetFieldValue;
  begin
    if UseText then TColumnEh(Sender).Field.AsString := Text else TColumnEh(Sender).Field.AsVariant := Value;
  end;
begin
  FieldName:= LowerCase(DBGridEh1.Columns[DBGridEh1.Col-1].Field.FieldName);
  if UseText then Value := Text else Value := Value;
  IF S.NSt(Value) = '' then Exit;
  //������� ����, ���� ������� � ������������ ���������
  if (FieldName = 'dt') then
    //�������� �� �������� ���, ������������ �������� �������
    if (VarToDateTime(Value) > Date)or(VarToDateTime(Value) < DtEditMin)
      then Value:=null //�������
      else begin
        //��������� ��� ������� ���� ��� � ������� ������� ������� � ������� ���� ���� ��������
        for i:=0 to MemTableEh1.RecordsView.MemTableData.RecordsList.Count-1 do begin
          if i <> MemTableEh1.RecNo - 1  //��� ��� MemTableEh1.RecNo ��������� � �������, � ������� MemTableEh1.RecordsView.MemTableData.RecordsList � ����
            then if MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['dt',dvvValueEh] = Value
              then begin Value := null; Break; end; //����� ������ - ������� �������� ����
        end;
      end;
  SetFieldValue; //��������� ����
  Mth.PostAndEdit(MemTableEh1);
//  Handled:=True;     //������� �� ������!!!????
end;

procedure TDlg_Order_Stages1.SetCaptionLabel;
var
  q: Extended;
begin
  //���������� ������ ���� �� ���������� �������
  TLabel(lbl_Caption).ResetColors;
  q:=Qnt - S.NNum(Gh.GetGridColumn(DBGridEh1, 'qnt').Footer.SumValue);
  if q  < 0 then q:=-1;
  if q  > 0 then q:= 1;
  //lbl_Caption.Caption:='����� ����������: '+ FloatToStr(Qnt) + ' ��.';
  TLabel(lbl_Caption).SetCaptionAr([
  '$000000', '����� ����������: ', S.Decode([q, 0, '$00FF00', 1, '$FF0000', -1, '$0000FF']), FloatToStr(Qnt) + ' ��.'
]);
end;

procedure TDlg_Order_Stages1.tmr1Timer(Sender: TObject);
begin
  inherited;
  //���� ������� �������� (������, ��� ������ ���� ������) � �������, � ������� ��� �� ����� ������, ��
  //������������ ����� ��������������, � � ��� ������ ����� ������ ������
  //������ ���� �����
  if (not InLoad)and(MemTableEh1.Active)and(MemTableEh1.RecordCount = 0)and(Mode = fEdit)
    then MemTableEh1.Edit;
end;

function TDlg_Order_Stages1.ShowDialog(aMode: TDialogType; aID_Order_Item, aID_Stage: Integer; aDtEditMin: TDateTime): Boolean;
var
  va: TVarDynArray;
  v: Variant;
begin
  InLoad:=True;
  Mode:=aMode;
  ID_Order_Item:= aID_Order_Item;
  ID_Stage:= aID_Stage;
  DtEditMin:=aDtEditMin;
//  DtEditCurr:=aDtEditMinCurr;
  Caption:=S.Decode([id_stage, 1, '������', 2, '������ �� ���', 3, '�������� � ���', 2, '������ ���', '']);
 { Img_Info.Visible:=True;
  Img_Info.left:=1;
  Img_Info.top:=bt_ok.top+4;
  Img_Info.top:=240;}
  DeletedItems:= [];
  if DBGridEh1.Columns.Count = 1 then begin
    MemTableEh1.DataDriver:=nil;
    MemTableEh1.FieldDefs.Clear;
    MemTableEh1.close;
    Mth.AddTableColumn(DBGridEh1, 'id', ftInteger, 0, '_ID', 20, True);
    Mth.AddTableColumn(DBGridEh1, 'dt', ftDate, 0, '����', 85, True);
    Mth.AddTableColumn(DBGridEh1, 'qnt', ftFloat, 0, '���-��', 85, True);
    MemTableEh1.CreateDataSet;
    DBGridEh1.Columns[1].AutoFitColWidth:=False;
    DBGridEh1.Columns[1].AlwaysShowEditButton:=True;
    DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh-[dghColumnResize, dghColumnMove] + [dghEnterAsTab] + [dghAutoFitRowHeight];
    DBGridEh1.AutoFitColWidths:=True;
    //������ ����
    DBGridEh1.Columns[0].Visible:=False;
    //����������� ����� ������ � �����
    DBGridEh1.Columns[1].onUpdateData:=DBGridEh1ColumnsUpdateData;
    DBGridEh1.Columns[2].onUpdateData:=DBGridEh1ColumnsUpdateData;
    //�������� ����� ��������� �� ������� (���������� ������ - ������� +), ���� �������� ����� �� ����������� ��������� ���� ��� ���������� ���������
    DBGridEh1.AllowedOperations:=[alopUpdateEh];
//    Gh._SetDBGridEhSumFooter(DBGridEh1, 'qnt', '0');
    Gh.SetGridColumnsProperty(DBGridEh1, cptSumFooter, 'qnt', '0');
  end;
  MemTableEh1.ReadOnly:=False;
  //������� ������,
  //��� ������ ��� ������ ����������� � ����� �� ���,
  //� ��� ���������� ������ ���, ��� ��� ������ � �� ��� ��� �������
  Q.QLoadToMemTableEh(
    'select id, dt, qnt from order_item_stages where id_order_item = :id_order_item$i and id_stage = :id_stage$i order by dt',
    [ID_Order_Item, ID_Stage],
    MemTableEh1,
    'id;dt;qnt'
  );
  MemTableEh1.Last;
  //if Mode <> fView then MemTableEh1.Append;
  va:= Q.QSelectOneRow('select nvl(qnt,0), id_order, dt_end from v_order_items where id = :id_order_item$i', [ID_Order_Item]);
  if va[0] = null then Exit;
  Qnt:=va[0];
  ID_Order:=va[1];
  //������ ������������� ����������� �����
  if va[2] <> null then Mode:=fView;
  Cth.SetDialogForm(Self, Mode, Caption);
  Cth.SetInfoIcon(Img_Info,Cth.SetInfoIconText(Self, [
   ['��������� ������ �� �������� �������� � ���� �������.'#13#10+
    '���� ����� ������ ����� ���� ����������� � ����������� �� ���� ������� (�� ������ ����).'#13#10+
    '��� ���������� ������ � ����� ������ �� ����� ����, ������� ������ ��� ������� ������� "+".'#13#10+
    '��� �������� ������ ������� ������ ������� ��� ��������� ������� ���������� ��� ���� ����.'#13#10+
    '������� ������� "=" ��� ������ ��� ����� ����������� ����, � � ���� ���������� ����� ������� ��� ���������� ���������� ���������� �� ������.'#13#10+
    '������ ���������� ���� � ������ ������� ������.'#13#10+
    '���� ������ �� �����, �� ��� �� ����������!'#13#10+
    '����������� ����� ���������� � �������, ������� ���������� ��� ������� �������, ����, ������� �������, � ������� ���!'#13#10,
   Mode<>fView]
  ]), 20);
  SetCaptionLabel;
  Bt_Cancel.Cancel:=False;
  DBGridEh1.ReadOnly:=Mode <> fEdit;
  //���. ������
  Cth.SetBtn(Bt_Add, mybtAdd, True);
  Cth.SetBtn(Bt_Del, mybtDelete, True);
  Bt_Add.Visible:=Mode = fEdit;
  Bt_Del.Visible:=Mode = fEdit;
  bvl1.Visible:=Bt_Add.Visible;
  InLoad:=False;
  RowDisable;
  Changed:=False;
  if not MemTableEh1.ReadOnly then MemTableEh1.Edit;
  KeyPreview:=True;
  Result:=ShowModal = mrOk;
end;


end.
