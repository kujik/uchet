unit D_Order_Stages_Otk2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_Normal, MemTableDataEh, Data.DB,
  DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.Mask, DBCtrlsEh, EhLibVCL, GridsEh,
  DBAxisGridsEh, DBGridEh, MemTableEh, uLabelColors, Math,
  uData
  ;

type
  TDlg_Order_Stages_Otk2 = class(TForm_Normal)
    DataSource1: TDataSource;
    MemTableEh1: TMemTableEh;
    lbl_Caption: TLabel;
    DBGridEh1: TDBGridEh;
    edt_PPComment: TDBEditEh;
    Bt_Cancel: TBitBtn;
    Bt_Ok: TBitBtn;
    Img_Info: TImage;
    Bt_Add: TBitBtn;
    Bt_Del: TBitBtn;
    bvl1: TBevel;
    tmr1: TTimer;
    procedure DBGridEh1SumListAfterRecalcAll(Sender: TObject);
    procedure MemTableEh1AfterPost(DataSet: TDataSet);
    procedure MemTableEh1AfterScroll(DataSet: TDataSet);
    procedure DBGridEh1KeyPress(Sender: TObject; var Key: Char);
    procedure DBGridEh1ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
    procedure Bt_OkClick(Sender: TObject);
    procedure Bt_DelClick(Sender: TObject);
    procedure Bt_AddClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
  private
    { Private declarations }
    ID_Order, ID_Order_Item: Integer;
    Qnt: Extended;
    DtEditMin: TDateTime; //�������������� ������� � ���� ��� �������� ����� ���� ����
    DtEditCurr: TDateTime; //���� �� ���������, �� ������� �������� �����
    Changed: Boolean;
    InLoad: Boolean;
    DeletedItems: TVariantDynArray;
    procedure SetCaptionLabel;
    procedure AddRow;
    procedure DelRow;
    procedure RowDisable;
  public
    { Public declarations }
    function ShowDialog(aMode: TDialogType; aID_Order_Item, aID_Stage: Integer; aDtEditMin: TDateTime; aDtEditCurr: TDateTime): Boolean;
  end;

var
  Dlg_Order_Stages_Otk2: TDlg_Order_Stages_Otk2;

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

procedure TDlg_Order_Stages_Otk2.RowDisable;
begin
  //��������� ��������� ����� �� �����, ��� ������� (������ ����� � ������ �������) ����������� ������� �������
  MemTableEh1.ReadOnly:=(Mode <> fEdit)or
    (MemTableEh1.RecordCount >0)and(MemTableEh1.FieldByName('dt').Value <> null)and(MemTableEh1.FieldByName('dt').Value < DtEditMin);
end;

procedure TDlg_Order_Stages_Otk2.Bt_AddClick(Sender: TObject);
begin
  inherited;
  AddRow;
end;

procedure TDlg_Order_Stages_Otk2.Bt_DelClick(Sender: TObject);
begin
  inherited;
  DelRow;
end;

procedure TDlg_Order_Stages_Otk2.Bt_OkClick(Sender: TObject);
var
  i, r: Integer;
  qnt: extended;
  d, erra: TVarDynArray;
  err: Boolean;
  res: Integer;
  smode: Char;
begin
  Mth.Post(MemTableEh1);
  if not Changed then begin
//    MyWarningMessage('������ �� ��������!');
    ModalResult:=mrCancel;
    Exit;
  end;
  d:=[];
  qnt:=0;
  //�������� ������
  //����� ������ ������ ���� ��������� ���, ����� �����������, � ���������� �� ���� �������������
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
    qnt:=qnt+MemTableEh1.FieldByName('qnt').AsFloat;
    if MemTableEh1.FieldByName('reason').AsString = ''
      then begin err:=True; Break; end;
  end;
  MemTableEh1.RecNo:=r;
  if err then begin
    MyWarningMessage('������ �����������!');
    ModalResult:=mrNone;
    Exit;
  end;
  //�������� ��������� (� ����������)
  //���� ������������� ��� ������ (�� ������ ����������) - ���� ���������
  res:=0;
  Q.QBeginTrans;
  MemTableEh1.DisableControls;
  //������ �� ��� ������� �� ������
  for i:=0 to High(DeletedItems) do begin
    res:=Q.QIUD('d', 'or_otk_rejected', '', 'id$i', [DeletedItems[i]]);
    if res < 0 then Break;
  end;
  if res >= 0 then
    //������� �� �������
    for i:=1 to MemTableEh1.RecordCount do begin
      MemTableEh1.RecNo:=i;
      smode:=#0;
      //� ������� �����������, ���� ��� ������ ������ - ������
      if (MemTableEh1.FieldByName('id').Value <> null)and(MemTableEh1.FieldByName('qnt').AsFloat = 0) then smode:= 'd';
      //������ � ��������� - ������
      if (MemTableEh1.FieldByName('id').Value <> null)and(MemTableEh1.FieldByName('qnt').AsFloat <> 0) then smode:= 'u';
      //����� � ��������� - ������
      if (MemTableEh1.FieldByName('id').Value = null)and(MemTableEh1.FieldByName('qnt').AsFloat <> 0) then smode:= 'i';
      res:=Q.QIUD(smode, 'or_otk_rejected', '', 'id$i;id_order_item$i;dt$d;qnt$f;id_reason$i;comm$s',
        [
          MemTableEh1.FieldByName('id').AsInteger,
          id_order_item,
          MemTableEh1.FieldByName('dt').AsDateTime,
          MemTableEh1.FieldByName('qnt').AsFloat,
          MemTableEh1.FieldByName('reason').Value,
          MemTableEh1.FieldByName('comm').AsString
        ]);
      if res < 0 then Break;
    end;
  Q.QCommitOrRollback(res >= 0);
  MemTableEh1.EnableControls;
  //���� ������
  if res < 0 then begin
    MyWarningMessage('�� ������� ��������� ������!');
    ModalResult:=mrNone;
    Exit;
  end;
  ModalResult:=mrOk;
//  ModalResult:=mrnone;
end;

procedure TDlg_Order_Stages_Otk2.DBGridEh1ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
//��� ���������� ������ ���������������
var
  NoErr:Boolean;
  i,j,i1: Integer;
  FieldName: string;
  dt: TDateTime;
  v:Variant;
  procedure SetFieldValue;
  begin
    if UseText then TColumnEh(Sender).Field.AsString := S.NSt(Value) else TColumnEh(Sender).Field.AsVariant := Value;
  end;
begin
  FieldName:= LowerCase(DBGridEh1.Columns[DBGridEh1.Col-1].Field.FieldName);
  if UseText then Value := Text else Value := Value;
  IF S.NSt(Value) = '' then Exit;
  //������� ����, ���� ������� � ������������ ���������
  //�������� �� �������� ���, ������������ ������� �������
  if (FieldName = 'dt') and ((VarToDateTime(Value) > Date)or(VarToDateTime(Value) < DtEditMin))
    then Value:=null;
  //������ ������� ��� ����� ������ ����������, ����� ������ ���������� ������� � �����
  if (FieldName = 'qnt') and (S.NNum(Value) > Qnt)
    then Value:=null;
  SetFieldValue; //��������� ����
  //TColumnEh(Sender).Field.AsVariant := Value;
  Mth.PostAndEdit(MemTableEh1);
//  Handled:=True;     //������� �� ������!!!????
end;

procedure TDlg_Order_Stages_Otk2.AddRow;
begin
  MemTableEh1.Last;
  //������� ������ ���� ��������� ������ ���������
  if (MemTableEh1.RecordCount > 0) and
     ((MemTableEh1.FieldByName('dt').AsVariant=null)or
     (MemTableEh1.FieldByName('qnt').AsVariant=null)or
     (MemTableEh1.FieldByName('reason').AsVariant=null))
    then Exit;
  MemTableEh1.ReadOnly:=False;
  MemTableEh1.Append;
  MemTableEh1.FieldByName('dt').Value:=DtEditCurr;
end;


procedure TDlg_Order_Stages_Otk2.DelRow;
var
  oldid: Variant;
begin
  if MemTableEh1.RecordCount = 0 then Exit;
  //���� ���������� �� ��������������, �� �� �������
  RowDisable;
  if MemTableEh1.ReadOnly then Exit;
  if (MemTableEh1.FieldByName('id').Value <> null)and(VarToDateTime(MemTableEh1.FieldByName('id').Value) < DtEditMin) then Exit;
  oldid:=MemTableEh1.FieldByName('id').Value;
  if not((oldid = null)or(MyQuestionMessage('������� ������?') = mrYes)) then Exit;
  if oldid <> null then begin
    DeletedItems:=DeletedItems + [MemTableEh1.FieldByName('id').Value];
    Changed:=True;
  end;
  MemTableEh1.ReadOnly:=False;
  MemTableEh1.Delete;
  RowDisable;
end;


procedure TDlg_Order_Stages_Otk2.FormShow(Sender: TObject);
begin
  //���� �� �������������� �����, �� ������ ������ �����
  //���� ��������������� ��� �� � ShowDialog ��
  //��� ������ ������� ������ ������ �����, ��� ����������� (����� ����� ��� �������� - ��� ���������, �������� �� ����)
  //� ��������� ����� ��������� ��������
  inherited;
  Img_Info.top:=bt_ok.top+4;
end;

procedure TDlg_Order_Stages_Otk2.DBGridEh1KeyPress(Sender: TObject;
  var Key: Char);
begin
  //�� ������� ������� + ������� � ����� ������ ������
  //� DBGridEh1KeyDown ������ ��� ��������, ��� ������ ���� ��������� � �������������, �������� ����� �� ��������, ����� ��� � ������ ��� ��� ����� ��������� � ���
  //(�� ����� ������� ��� ���� �� F2, ������� � ������ �� �����)
  inherited;
  if Mode = fView then Exit;
  //�� ���������� ����� ���������, ��� �� ������ ��������������
  //��� ���������, ��� ��� ����� � ��������� ��� �������, ��� ������ � ��������� �� � ����� ������ ������
  if (DBGridEh1.InplaceEditor.SelStart <> 0)or(DBGridEh1.InplaceEditor.Modified) then Exit;
  if key = '+' then begin
    AddRow;
    Key:=#0;
  end;
  if ((key = '=')or(key = ' ')) and (not MemTableEh1.ReadOnly) then begin
    Key:=#0;  //��� �����������, ����� � ��������� �������� ����� =
    //� ���� ���� �������� �������
    if DBGridEh1.Columns[DBGridEh1.Col-1].FieldName = 'dt' then MemTableEh1.FieldByName('dt').Value:=Date;
    //� ���� ���������� �������� �� �������
    if DBGridEh1.Columns[DBGridEh1.Col-1].FieldName = 'qnt'
      then MemTableEh1.FieldByName('qnt').Value:= Max(0, Qnt - (S.NNum(Gh.GetGridColumn(DBGridEh1, 'qnt').Footer.SumValue) - S.NNum(MemTableEh1.FieldByName('qnt').Value)));
    Mth.PostAndEdit(MemTableEh1);
  end;
end;

procedure TDlg_Order_Stages_Otk2.DBGridEh1SumListAfterRecalcAll(
  Sender: TObject);
begin
  inherited;
  SetCaptionLabel;
end;

procedure TDlg_Order_Stages_Otk2.MemTableEh1AfterPost(DataSet: TDataSet);
begin
  inherited;
  Changed:=True;
end;

procedure TDlg_Order_Stages_Otk2.MemTableEh1AfterScroll(DataSet: TDataSet);
begin
  inherited;
  if (InLoad)or(Mode = fView) then Exit;
  RowDisable;
end;


procedure TDlg_Order_Stages_Otk2.SetCaptionLabel;
var
  q: Extended;
begin
  TLabel(lbl_Caption).ResetColors;
  q:=Qnt - S.NNum(Gh.GetGridColumn(DBGridEh1, 'qnt').Footer.SumValue);
  if q  < 0 then q:=-1;
  if q  > 0 then q:= 1;
  TLabel(lbl_Caption).SetCaptionAr([
//  '$000000', '����� ����������: ', S.Decode([q, 0, '$00FF00', 1, '$FF0000', -1, '$0000FF']), FloatToStr(Qnt) + ' ��.'
  '$000000', '����� ����������: ', '$FF0000', FloatToStr(Qnt) + ' ��.'
]);
end;

procedure TDlg_Order_Stages_Otk2.tmr1Timer(Sender: TObject);
begin
  inherited;
  //���� ������� �������� (������, ��� ������ ���� ������) � �������, � ������� ��� �� ����� ������, ��
  //������������ ����� ��������������, � � ��� ������ ����� ������ ������
  //������ ���� �����
  if (not InLoad)and(MemTableEh1.Active)and(MemTableEh1.RecordCount = 0)and(Mode = fEdit)
    then MemTableEh1.Edit;
end;

function TDlg_Order_Stages_Otk2.ShowDialog(aMode: TDialogType; aID_Order_Item, aID_Stage: Integer; aDtEditMin: TDateTime; aDtEditCurr: TDateTime): Boolean;
var
  va: TVarDynArray;
  va2: TVarDynArray2;
  i,j: Integer;
begin
  InLoad:=True;
  Mode:=aMode;
  ID_Order_Item:= aID_Order_Item;
  DtEditMin:=aDtEditMin;
  DtEditCurr:=aDtEditCurr;
  DeletedItems:=[];

  Cth.SetInfoIcon(Img_Info,Cth.SetInfoIconText(Self, [
   ['��������� ������ �� �� �������� ��� �������� � ���� �������.'#13#10+
    '���� ����� ������ ����� ���� ����������� � ����������� �� ���� ������� (�� ������ ����).'#13#10+
    '��� ���������� ������ � ����� ������ �� ����� ����, ������� ��������������� ������, ��� ������� "+".'#13#10+
    '��� �������� ������ ������� ������ �������, ��� �� ��������� ������� ���������� ��� ���� ����.'#13#10+
    '������� ������� "=" ��� ������ ��� ����� ����������� ����, � � ���� ���������� ����� ������� ��� ���������� ���������� ���������� �� ������.'#13#10+
    '��� ����� ���� �������� ���������, �� ����� � ������� ���� ������, � ��� ������� ������ ��� ��� ���� ������� ������ ������.'#13#10+
    '��� ����, ����� �����������, ����������� ��� ����������.'#13#10+
    '���� ������ �� �����, �� ��������� �� �������� �� ���������.'#13#10,
   Mode<>fView]
  ]), 20);

  //��� ������ ������� ����� �������������� ����
  if DBGridEh1.Columns.Count = 1 then begin
    MemTableEh1.DataDriver:=nil;
    MemTableEh1.FieldDefs.Clear;
    MemTableEh1.close;
    Mth.AddTableColumn(DBGridEh1, 'id', ftInteger, 0, '_id', 20, True);
    Mth.AddTableColumn(DBGridEh1, 'id_reason', ftInteger, 0, '_id_reason', 20, True);
    Mth.AddTableColumn(DBGridEh1, 'dt', ftDate, 0, '����', 85, True);
    Mth.AddTableColumn(DBGridEh1, 'qnt', ftFloat, 0, '���-��', 85, True);
    Mth.AddTableColumn(DBGridEh1, 'reason', ftString, 400, '������� ���������', 250, True);
    Mth.AddTableColumn(DBGridEh1, 'comm', ftString, 4000, '�����������', 200, True);
    MemTableEh1.CreateDataSet;
    DBGridEh1.Columns[2].AutoFitColWidth:=False;
    DBGridEh1.Columns[3].AutoFitColWidth:=False;
    DBGridEh1.Columns[4].AutoFitColWidth:=False;
    DBGridEh1.Columns[2].AlwaysShowEditButton:=True;
    DBGridEh1.Columns[4].AlwaysShowEditButton:=True;
    DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh-[dghColumnResize, dghColumnMove] + [dghEnterAsTab] + [dghAutoFitRowHeight];
    DBGridEh1.AutoFitColWidths:=True;
    DBGridEh1.AllowedOperations:=[alopUpdateEh];
    //������ ����
    DBGridEh1.Columns[0].Visible:=False;
    DBGridEh1.Columns[1].Visible:=DBGridEh1.Columns[0].Visible;
    for i:=0 to DBGridEh1.Columns.Count - 1 do
      if DBGridEh1.Columns[i].Visible
        then DBGridEh1.Columns[i].onUpdateData:=DBGridEh1ColumnsUpdateData;
    //Gh._SetDBGridEhSumFooter(DBGridEh1, 'qnt', '0');
    Gh.SetGridColumnsProperty(DBGridEh1, cptSumFooter, 'qnt', '0');
    MinWidth:=700;
    MinHeight:=300;
  end;
  MemTableEh1.ReadOnly:=False;
  //������� ������ ������ ������ -��� ��������, � �� ����������, �� ������� ���� ��� ������ ��� ������� ������� ������
  Gh.GetGridColumn(DBGridEh1, 'reason').LimitTextToListValues:=False;
  va2:=Q.QLoadToVarDynArray2(
    'select name, id from ref_otk_reject_reasons where '+
    'active = 1 or (id in (select id_reason from or_otk_rejected where id_order_item = :id_order_item$i)) '+
    'order by name',
    [ID_Order_Item]
  );
  //�������� ���������� ������
  Gh.GetGridColumn(DBGridEh1, 'reason').PickList.Clear;
  Gh.GetGridColumn(DBGridEh1, 'reason').KeyList.Clear;
  for i:=0 to High(va2) do begin
    Gh.GetGridColumn(DBGridEh1, 'reason').PickList.Add(S.NSt(va2[i][0]));
    Gh.GetGridColumn(DBGridEh1, 'reason').KeyList.Add(S.NSt(va2[i][1]));
  end;
  Gh.GetGridColumn(DBGridEh1, 'reason').LimitTextToListValues:=True;

  //������ ������ � �������
  Q.QLoadToMemTableEh(
    'select id, dt, qnt, id_reason as reason, comm '+
    'from or_otk_rejected where id_order_item = :id_order_item$i order by dt',
    [ID_Order_Item],
    MemTableEh1,
    ''
  );
  MemTableEh1.Last;
  //if Mode <> fView then MemTableEh1.Append;
  //������� ������ �� �������, � ������� ��������
  va:= Q.QSelectOneRow('select nvl(qnt,0), id_order, dt_end from v_order_items where id = :id_order_item$i', [ID_Order_Item]);
  if va[0] = null then Exit;
  Qnt:=va[0];
  ID_Order:=va[1];
  //������ ������������� ����������� �����
  if va[2] <> null then Mode:=fView;
  Cth.SetDialogForm(Self, Mode, '�������, �� �������� ���');
  SetCaptionLabel;
  Bt_Cancel.Cancel:=False;
  DBGridEh1.ReadOnly:=Mode <> fEdit;
  InLoad:=False;
  RowDisable;
  Changed:=False;
  if not MemTableEh1.ReadOnly then MemTableEh1.Edit;
  KeyPreview:=True;
  BorderStyle:=bsSizeable;
  //��� �������������� ��������� � �������� �����
  AutoSaveWindowPos:=True;
  //���. ������
  Cth.SetBtn(Bt_Add, mybtAdd, True);
  Cth.SetBtn(Bt_Del, mybtDelete, True);
  Bt_Add.Visible:=Mode = fEdit;
  Bt_Del.Visible:=Mode = fEdit;
  bvl1.Visible:=Bt_Add.Visible;
  Result:=ShowModal = mrOk;
end;



end.
