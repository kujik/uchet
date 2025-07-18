unit uFrmOGedtEstimate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uFrmBasicEditabelGrid, uLabelColors
  ;

type
  TFrmOGedtEstimate = class(TFrmBasicEditabelGrid)
  private
    FIdEstimate: Integer;

    Err, Err2: TVarDynArray;
    FIdOfStdItem: Integer;    //���� ������������ �������, � �������� ����� (���������������, ��� �� ������������ ������)
    FGroupOfItem: Integer;    //������ ����������� �������, � ������� ��������� ������� �����
    FTypeOfItem: Integer;     //��� �������, � �������� ���������� ����� (������., ����., �/�)
    FName: string;
    function  PrepareForm: Boolean; override;
    function  PrepareFormAdd: Boolean; override;
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string); override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); override;
    procedure btnClick(Sender: TObject); override;
    procedure VerifyRow(Row: Integer);
    procedure VerifyBeforeSave; override;
    function  Save: Boolean; override;
    procedure VerifyTable(AReloadStatus: boolean = False);
    procedure LoadFromDB;
    procedure LoadFromXls;
    procedure LoadItemFromDB(Row: Integer);
    function  SaveEstimate: Boolean;
  protected
  public
  end;

var
  FrmOGedtEstimate: TFrmOGedtEstimate;

implementation

uses
  uOrders,
  uWindows
  ;

{$R *.dfm}

const
  cIdSemiproduct = 2;
  cIdProduct = 104;
  cIdStuff = 1;
  cIdKrep = 103;


function TFrmOGedtEstimate.PrepareForm: Boolean;
var
  i: Integer;
  o: TFrDBGridEditOptions;
  va: TVarDynArray;
begin
  Caption := '�����';
  //������� ���� ����� �� ���� ������������ ������� ��� ������
  if AddParam = 1 then begin
    FIdOfStdItem := ID;
    FIdEstimate := Q.QSelectOneRow('select id from estimates where id_std_item = :id$i', [ID])[0];
    FName := Q.QSelectOneRow('select name from v_or_std_items where id = :id$i', [ID])[0];
  end
  else begin
    FIdOfStdItem := Q.QSelectOneRow('select id_std_item from order_items where id = :id$i', [ID])[0];
    FIdEstimate := Q.QSelectOneRow('select id from estimates where id_order_item = :id$i', [ID])[0];
    FName := Q.QSelectOneRow('select slash || '' '' || name from v_order_items where id = :id$i', [ID])[0];
  end;
  //���� ����� ��� ���, �� �������� � ����� ����������
  if  FIdEstimate = null then
    Mode := fAdd;
  //������� ���� ������ (�� ����������!) ����������� ������� ��� ������ �������
  FGroupOfItem := Q.QSelectOneRow('select id_format from or_format_estimates where id = (select id_or_format_estimates from or_std_items where id = :id$i)', [FIdOfStdItem])[0];
  //������� ��� ���� ������� - �����������������, �����������, �/�
  FTypeOfItem := Q.QSelectOneRow('select type from or_format_estimates where id = (select id_or_format_estimates from or_std_items where id = :id$i)', [FIdOfStdItem])[0];
  //������������ �����
  FTitleTexts := [S.IIf(AddParam = 1, '����� � ������������ �������:', '����� �������� ������:'),  {'$FF0000' + } FName];
  pnlTop.Height := 50;
  //��������� ������ ����� � ��.���.
  Orders.LoadBcadGroups(True);

  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['id_or_std_item$i','_id_or_std_item','40'],
    ['id_group$i','������','250;w;L','e=1:100000::TP'],
    ['name$s','������������','400;w;h','e=1:1000','bt=������� ��������:�:::090' + S.IIFStr(FTypeOfItem <> 2, ';������� ������������:�:::909') + S.IIFStr(FTypeOfItem = 1, ';������� ���������������� �������:�:::009') ],
    ['id_unit$i','��.���.','100;L','e=0:1000000::TP'],
    ['qnt1$f','���-��','80','e=0:999999:5:N'], {����������� ������ ���-��}
    ['null as purchase$i','�������','80','chb','e'],
    ['comm$s','����������','300;w;h','e=0:1000::TP'],
    ['null as flags$s','_flags','40']
  ]);
  Frg1.Opt.SetTable('v_estimate', 'estimate_items');
  Frg1.Opt.SetGridOperations('uaid');
  Frg1.Opt.SetWhere('where id_estimate = :id$i order by id_group');
  Frg1.SetInitData('*', [FIdEstimate]);
  Frg1.Opt.Caption := '������� �������';

  Frg1.Opt.SetPick('id_group', A.VarDynArray2ColToVD1(Orders.BcadGroups, 0), A.VarDynArray2ColToVD1(Orders.BcadGroups, 1), True);
  Frg1.Opt.SetPick('id_unit', A.VarDynArray2ColToVD1(Orders.BcadUnits, 0), A.VarDynArray2ColToVD1(Orders.BcadUnits, 1), True);
  Frg1.Opt.SetPick('type', ['��������','�������','������������'], [0,1,2], True);

  o.AlwaysVerifyAllTable:= True;
  O.FieldsNoRepaeted:=['name'];
  Frg1.EditOptions := o; //(AlwaysVerifyAllTable: True);

//  .AlwaysVerifyAllTable := True

//  Frg1.Dbgrideh1.Columns[4].CellButtons[0].Caption :='�';
//  Frg1.Dbgrideh1.Columns[3].CellButtons[1].Caption :='�';

  FOpt.InfoArray:= [[
  '���� �����.'#13#10
  ]];
  Result := inherited;
end;

function TFrmOGedtEstimate.PrepareFormAdd: Boolean;
begin
  Frg1.Opt.SetButtons(4, [
    [mbtExcel, True, '��������� ����� �� �����'],
    [mbtLoad, True, '��������� ������� ����� �� ��'],
    [mbtPasteEstimate, True, '�������� ����� �� ������'],
    [mbtInsertRow, alopInsertEh in Frg1.Opt.AllowedOperations],
    [mbtAddRow, alopAppendEh in Frg1.Opt.AllowedOperations],
    [mbtDeleteRow, alopDeleteEh in Frg1.Opt.AllowedOperations],
    [mbtDividorA],[-4],
    [-1001, FTypeOfItem <> 2, '������� ������������'],
    [-1002, FTypeOfItem <> 2, '������������� ����� �������������']],
    cbttBSmall, pnlFrmBtnsR
  );
  Result := True;
end;

procedure TFrmOGedtEstimate.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
//��������� ������� ������ ������
begin
  Handled := True;
  if (Tag = mbtLoad) and (MyQuestionMessage('��������� ������� ����� �� ���� ������?') = mrYes) then
    Frg1.LoadData('*', [FIdEstimate])
  else if Tag = mbtExcel then
    LoadFromXls
  else begin
    Handled := False;
    inherited;
  end;
end;

procedure TFrmOGedtEstimate.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
   Cth.SetButtonState(Fr, 1001, null, null, Fr.GetValue('id_group') = cIdSemiproduct);
   Cth.SetButtonState(Fr, 1002, null, null, Fr.GetValue('id_group') = cIdSemiproduct);
end;


procedure TFrmOGedtEstimate.Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
//��������� ������� ������ � �������
var
  va: TVarDynArray;
  i: Integer;
begin
  Wh.SelectDialogResult := [];
  if TCellButtonEh(Sender).Hint = '������� ��������' then begin
    Wh.ExecReference(myfrm_R_bCAD_Nomencl_SelMaterials, Self, [myfoDialog, myfoModal], null);
    if Length(Wh.SelectDialogResult) = 0 then
      Exit;
    Frg1.SetValue('name', Wh.SelectDialogResult[2]);
    LoadItemFromDB(Frg1.RecNo - 1);
  end
  else if TCellButtonEh(Sender).Hint = '������� ������������' then begin
    Wh.ExecReference(myfrm_R_OrderStdItems_SelSemiproduct, Self, [myfoDialog, myfoModal], FGroupOfItem);
    if Length(Wh.SelectDialogResult) = 0 then
      Exit;
    Frg1.SetValue('name', Wh.SelectDialogResult[1]);
    LoadItemFromDB(Frg1.RecNo - 1);
  end
  else if TCellButtonEh(Sender).Hint = '������� ���������������� �������' then begin
    Wh.ExecReference(myfrm_R_OrderStdItems_SelProdStdItem, Self, [myfoDialog, myfoModal], FGroupOfItem);
    if Length(Wh.SelectDialogResult) = 0 then
      Exit;
    Frg1.SetValue('name', Wh.SelectDialogResult[1]);
    LoadItemFromDB(Frg1.RecNo - 1);
  end;
  VerifyRow(Fr.RecNo - 1);
  VerifyTable;
end;


procedure TFrmOGedtEstimate.Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string);
//��������� �������� ����� ��������� ������ � ������� ������� ������
begin
  if Mode <> dbgvCell then
    Exit;
  //������ ��� ������ � ������������
  if (Fr.GetValue('id_group') = null) or (Fr.GetValue('name') = null) then
    Exit;
  if A.InArray(FieldName, ['name', '--id_group']) then begin
    LoadItemFromDB(Row - 1);
  end;
  VerifyRow(Row - 1);
  VerifyTable;
end;

procedure TFrmOGedtEstimate.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
//��������� ������ � ��������������
begin
  if Fr.GetValueS('flags') = '' then
    Exit;
  if Fr.GetValueS('flags')[1] = '0' then
    Params.Background := clYellow
  else if Fr.GetValueS('flags')[1] = '1' then
    Params.Background := clRed
  else if Fr.GetValueS('flags')[1] = '2' then
    Params.Background := RGB(255, 0, 255)
  else if Fr.GetValueS('flags')[1] = '3' then
    Params.Background := RGB(100, 0, 255);
end;

procedure TFrmOGedtEstimate.Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
  //�������� ������ ��.���. � ������� ������� � ��
  if ((Fr.GetValueI('id_group') = cIdProduct) or (Fr.GetValueI('id_group') = cIdSemiproduct)) and ({(Fr.CurrField = 'id_group') or }(Fr.CurrField = 'id_unit')) then
    ReadOnly := True;
  //��������� ������� ����� ��������, ���� ��� �� ��
  if (Fr.GetValueI('id_group') <> cIdSemiproduct) and (Fr.CurrField =  'purchase') then
    ReadOnly := True;
end;

procedure TFrmOGedtEstimate.btnClick(Sender: TObject);
var
  Tag: Integer;
begin
  Tag := TControl(Self).Tag;
end;

procedure TFrmOGedtEstimate.VerifyRow(Row: Integer);
//�������� �� ������ (����: ��� �� ������ ��������, �� ���� � ����������� ���.���.), �������� ��. �������� ��������� � ��������� �������
var
  st: string;
begin
  Frg1.SetValue('flags', Row, False, S.NSt(Q.QSelectOneRow('select F_TestEstimateItem_New(:g$i, :n$s, :sg$i) from dual', [Frg1.GetValue('id_group', Row, False), Frg1.GetValue('name', Row, False), FGroupOfItem])[0]));
end;

procedure TFrmOGedtEstimate.VerifyBeforeSave;
//����������� ��������� �������� ��� ������� ������ ��
begin
  //�������� ������� � ����������� �������� � �� �� ������� ������
  VerifyTable(True);
end;

procedure TFrmOGedtEstimate.VerifyTable(AReloadStatus: boolean = False);
//��������� �������
//�������� ��� ������ ��������� ������ ��� �������� � �� � ����� ���������, � ����� �������� � ����� ������� - � ���������
var
  i, j, k, m: Integer;
  Err: TVarDynArray;
  st: string;
  b: Boolean;
begin
  Err := [];
  b := True;
  //����������� ������� ������� ������ �� ������������ - �� ������ �������������� � �� ������������� �������� � �������
  Frg1.IsTableCorrect;
  if Frg1.ErrorMessage <> '' then
    b := FaLse;
  //�������������� �������� �� ���� ������
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    //--�������� ������������ � ������� ������� �������, ������ � ������
    //--1� ������ = 0 ���� ��� ����� ������ � ����������� ������������ ����
    //--2� ������ = 0 - ������ ��� ������������ �� ������ ������� - ��� ������ ������� � v_or_std_items
    //--3� ������ = 0 - ������ ��� ������������ �� ������ ������� ������� ���� - ������������ ������� � ������ �������, ��� ���� ������� ���������� �������� ������
    st := Frg1.GetValueS('flags', i, False);
    if AReloadStatus then begin
      st := S.NSt(Q.QSelectOneRow('select F_TestEstimateItem_New(:g$i, :n$s, :sg$i) from dual', [Frg1.GetValueS('id_group', i, False), Frg1.GetValueS('name', i, False), FGroupOfItem])[0]);
      Frg1.SetValue('flags', i, False, st);
    end;
    if st <> '' then begin
      if st[1] <> '0' then
        b := False;  //���� ������, � �������� ��������� ����� ������.
      Err := Err + ['[ ' + Frg1.GetValueS('name', i, False) + ' ] - ' + Copy(Frg1.GetValueS('flags', i, False), 3)];
    end;
  end;
  FErrorMessage := '';
  if (Frg1.ErrorMessage = '') and (Length(Err) = 0) then begin
    Frg1.SetState(null, False, '');
  end
  else begin
    FErrorMessage := S.ConcatSt(Frg1.ErrorMessage, A.Implode(Err, #13#10), #13#10);
    Frg1.SetState(null, not b, FErrorMessage);
    if b then
      FErrorMessage := '?' + FErrorMessage + #10#13#10#13 + '�������� �����?';
  end;
end;

function  TFrmOGedtEstimate.Save: Boolean;
var
  i: Integer;
begin
  Result := SaveEstimate; Exit;
  Result := False;
Exit;
  Wh.SelectDialogResult2 := [];
  for i := 0 to Frg1.GetCount - 1 do begin
    if Frg1.GetValueS('name', i, False) <> '' then
      Wh.SelectDialogResult2 := Wh.SelectDialogResult2 + [[Frg1.GetValue('name'), Frg1.GetValue('id_group'), Frg1.GetValue('id_unit'), Frg1.GetValue('qnt1'), Frg1.GetValue('comm')]];
  end;
  //Result := True;
end;

procedure TFrmOGedtEstimate.LoadFromDB;
begin
  Frg1.SetInitData('*',[]);
  VerifyBeforeSave;
end;

procedure TFrmOGedtEstimate.LoadFromXls;
//�������� ����� �� ����� ������
var
  i, j: Integer;
  Est: TVarDynArray2;
  FileName: string;
  va: TVarDynArray;
  va1, va2: TVarDynArray2;
  st : string;
begin
  FileName := '';
  //����� � ������
  if not Orders.EstimateFromFile(FileName, Est) then
    Exit;
  //������ � ��������
  Frg1.LoadSourceDataFromArray(Est, 'name;id_group;id_unit;qnt1;comm', '');
  st := '';
  //������� �� ������, �������� � ������ ����� �� ��������� �����, ��� �� ���������� � ������ ������������� ��� ������� � ������ ������� ��� ������ �����
  //(����� �������� ����� ��� �������� �� ����, ��� � ��� ������ ���������� �������������, �� ��� ���������)
  //���� ������� ������������� ����� �������, �� �������� ������, �������������� ���� �������, ���� ������� �������� - ������� ������
  for i := 0 to Frg1.GetCount(False) do begin
    if Frg1.GetValueI('id_group', i, False) = cIDKrep then begin  //�����
      va2 := Q.QLoadToVarDynArray2('select fullname, id_format from v_or_std_items where name = :name$s and type = 0 and id_format = :f$i', [Frg1.GetValue('name', i, False), FGroupOfItem]);
      if Length(va2) > 0 then begin
        S.ConcatStP(st, Frg1.GetValue('name', i, False) + ' - �������� ��������!', #13#10);
        Frg1.SetValue('id_group', i, False, IIf(Length(va2) = 1, cIdProduct, null));
      end;
    end
    else begin
      va2 := Q.QLoadToVarDynArray2('select fullname, id_format from v_or_std_items where name = :name$s and type = 2 and (id_format = 0 or id_format = :f$i)', [Frg1.GetValue('name', i, False), FGroupOfItem]);
      if Length(va2) > 0 then begin
        S.ConcatStP(st, Frg1.GetValue('name', i, False) + ' - �������� ��������������!', #13#10);
        Frg1.SetValue('id_group', i, False, IIf(Length(va2) = 1, cIdSemiproduct, null));
      end;
    end;
  end;
  //�������� �������� � ������� ������ �� ��
  VerifyBeforeSave;
  //������� ���������, ���� ���� ������� ������
  if st <> '' then
    MyInfoMessage(st, 1);
end;

procedure TFrmOGedtEstimate.LoadItemFromDB(Row: Integer);
//�������� �� ���� ���������� �� ������� ������������ ������� �������
var
  i, j: Integer;
  va: TVarDynArray;
begin
  va := Q.QSelectOneRow('select id, is_semiproduct from v_or_std_items where fullname = :fullname$s', [Frg1.GetValue('name', Row, False)]);
  if va[0] <> null then begin
    //��� �������
    Frg1.SetValue('id_group', S.IIf(va[1] = 1, cIdSemiproduct, cIdProduct));
    Frg1.SetValue('id_unit', cIdStuff);
  end
  else begin
    //��� ��������
    va := Q.QSelectOneRow('select id, id_group, id_unit from v_estimate where name = :name$s', [Frg1.GetValue('name', Row, False)]);
    if va[0] <> null then begin
      Frg1.SetValue('id_group', va[1]);
      Frg1.SetValue('id_unit', va[2]);
    end;
  end;
  //������� ����� ��������, ���� ��� �� ������������
  if Frg1.GetValue('id_group') <> Group_Semiproducts_Id then
    Frg1.SetValue('purchase', 0);
end;


function TFrmOGedtEstimate.SaveEstimate: Boolean;
var
  Res: Integer;
  i, j: Integer;
begin
  Result := False;
  Q.QBeginTrans(True);
  Q.QIUD(S.IIFStr(FIdEstimate = null, 'i', 'u')[1], 'estimates', '',
   'id$i;id_std_item$i;id_order_item$i;isempty$i;dt$d',
   [FIdEstimate, S.IIf(AddParam = 1, ID, null), S.IIf(AddParam = 0, ID, null), False, Date]);
  for i := 0 to Frg1.GetCount(False) do begin
    if Length(Q.QCallStoredProc('p_createestimateitem',
      'pid_estimate$i;pid_group$i;pname$s;pid_unit$i;pcomment$s;pqnt1$f;pqnt$f',
       [FIdEstimate, Frg1.GetValue('id_group', i, False), Frg1.GetValue('name', i, False), Frg1.GetValue('id_unit', i, False), Frg1.GetValue('comm', i, False), Frg1.GetValue('qnt1', i, False), Frg1.GetValue('qnt1', i, False)]
       )) = 0 then
      Break;
  end;
  Q.QCommitOrRollback(True);
  Result := Q.CommitSuccess;
end;
(*
else begin
    //�� ���� ��������� �������
    //�������� �����
      Res := Q.QIUD(S.IIFStr(IdEstimate = null, 'i', 'u')[1], 'estimates', '',
       'id$i;id_std_item$i;id_order_item$i;isempty$i;dt$d',
       [IdEstimate, IdStdItem, IdOrderItem, IsEstimateEmpty, Date]);
      if Res = -1 then Break;
      if IdEstimate = null then
        IdEstimate := Res
      else
        //���� ��������� ������ ����� (������� ������ ��� �����), �� ������ ��� ������� ���� ��� ����
        if IsEstimateEmpty
          then Q.QExecSql('delete from estimate_items where id_estimate = :id_estimate$i', [IdEstimate]);
        //���� ��� ���� ����� �������, �� ��� ������� ������� �� ��������
        Res := Q.QExecSql('update estimate_items set deleted = 1 where id_estimate = :id_estimate$i', [IdEstimate]);
      if Res = -1 then
        Break;
      if QntChanged then begin
      //��������� ���������� � �����, ���������� ���� ������, ��������� ���� ������� ���������� � ������
        va1 := Q.QCallStoredProc('p_CorrectEstimateQnt', 'idorderitem$i', [IdOrderItem]);
        if Length(va1) = 0 then
          Res := -1;
      end
      else if IsOrItemStd then begin
      //�������� �� ����������� �����
        va1 := Q.QCallStoredProc('p_copyestimate', 'idestimate$i;idstdestimate$i;pqntinor$f', [IdEstimate, ParentIdEstimate, OrQnt]);
        if Length(va1) = 0 then
          Res := -1;
      end
      else begin
      //������� ��� ������������� �����
        for i := 0 to High(Est) do begin
          try
            va1 := Q.QCallStoredProc('p_createestimateitem',
            'pid_estimate$i;pid_group$i;pname$s;pid_unit$i;pcomment$s;pqnt1$f;pqnt$f',
             [IdEstimate, Est[i][1], Est[i][0], Est[i][2], Est[i][4], Est[i][3], Est[i][3]]
             );
            if Length(va1) = 0 then
              Res := -1;
            if Res = -1 then
              MyWarningMessage('������ ��� �������� ������� "' + VartoStr(Est[i][0]) + '"!');
          except

            Res := -1;
          end;
          if Res = -1 then
            Break;
          //Est:=[[va[i][cName], idgr, idunit, va[i][cQnt1], va[i][cComm]]]
        end;
      end;
    //������ �������, ������� �������� �������� �� ��������
      if Res = -1 then
        Break;
      Res := Q.QExecSql('delete from estimate_items where deleted = 1 and id_estimate = :id_estimate$i', [IdEstimate]);
      if Res = -1 then
        Break;
    //++
    //������������� ����� � ������ ����������, ��������� ���������� ��� ���
      if Length(Q.QCallStoredProc('p_CorrectEstimateWithReplace', 'id_estimate$i', [IdEstimate])) = 0 then
        Break;
    //������ �����, ���� � ��� ��� �� ������ ��������
      Q.QCallStoredProc('p_DeleteFreeEstimate', 'id_estimate$i', [IdEstimate]);
    end;
    //�������������� � ���, � ������ ���� ����������� ����� ������ �� ������ ������� ������
    if (IdOrderItem <> null) and (OneItem)
      then SyncOrderWithITM(OrderIdUchet, [IdOrderItem], False);
  until True;
  Q.QCommitOrRollback(Res <> -1);
  if not Q.CommitSuccess then begin
*)



end.
