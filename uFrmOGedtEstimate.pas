unit uFrmOGedtEstimate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uFrmBasicEditabelGrid, uLabelColors
  ;

type
  TFrmOGedtEstimate = class(TFrmBasicEditabelGrid)
  private
    Err, Err2: TVarDynArray;
    IdSemiproduct, IdProduct,  IdStuff: Integer;
    function  PrepareForm: Boolean; override;
    function  PrepareFormAdd: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string); override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); override;
    procedure btnClick(Sender: TObject); override;
    procedure VerifyRow(Row: Integer);
    procedure VerifyBeforeSave; override;
    function  Save: Boolean; override;
    procedure LoadFromDB;
    procedure LoadFromXls;
    procedure LoadItemFromDB(Row: Integer);
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

function TFrmOGedtEstimate.PrepareForm: Boolean;
var
  i: Integer;
begin
  Caption:= '�����';
  FTitleTexts := [S.IIf(TVarDynArray(AddParam)[1] = 0, '����� � ������������ �������:', '����� � ������:'),  {'$FF0000' + }TVarDynArray(AddParam)[2]];
  pnlTop.Height := 50;

  Orders.LoadBcadGroups(True);

  IdSemiproduct := 2;
  IdProduct := 104;
  IdStuff := 1;


  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['id_or_std_item$i','_id_or_std_item','40'],
    ['id_group$i','������','250;w;L','e=0:100000::TP'],
    ['name$s','������������','400;w;h','e=1:1000','bt=������� �� ����������� ������������;������� �� ����������� ����������� �������'], //:dd
    ['id_unit$i','��.���.','100;L','e=0:1000000::TP'],
    ['qnt1$f','���-��','80','e=0:999999:5:N'], {����������� ������ ���-��}
    ['null as purchase$i','�������','80','chb','e'],
    ['comm$s','����������','300;w;h','e=0:1000::TP']
  ]);
  Frg1.Opt.SetTable('v_estimate', 'estimate_items');
  Frg1.Opt.SetGridOperations('uaid');
  Frg1.Opt.SetWhere('where id_estimate = :id$i order by id_group');
  Frg1.SetInitData('*', [ID]);
  Frg1.Opt.Caption := '������� �������';

  Frg1.Opt.SetPick('id_group', A.VarDynArray2ColToVD1(Orders.BcadGroups, 0), A.VarDynArray2ColToVD1(Orders.BcadGroups, 1), True);
  Frg1.Opt.SetPick('id_unit', A.VarDynArray2ColToVD1(Orders.BcadUnits, 0), A.VarDynArray2ColToVD1(Orders.BcadUnits, 1), True);
  Frg1.Opt.SetPick('type', ['��������','�������','������������'], [0,1,2], True);

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
    [mbtDividorA],[-4]],
    cbttBSmall, pnlFrmBtnsR
  );
  Result := True;
end;

procedure TFrmOGedtEstimate.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  Handled := True;
  if Tag = mbtLoad then
    Frg1.LoadData('*', [ID])
  else if Tag = mbtExcel then
    LoadFromXls
{

  else if Tag = mbtAdd then
    Frg1.AddRow
  else if Tag = mbtInsert then
    Frg1.InsertRow
  else if Tag = mbtDelete then
    Frg1.DeleteRow}
  else begin
    Handled := False;
    inherited;
  end;
end;

procedure TFrmOGedtEstimate.Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
var
  va: TVarDynArray;
  i: Integer;
begin
  Wh.SelectDialogResult := [];
  if TCellButtonEh(Sender).Hint = '������� �� ����������� ������������' then begin
    Wh.ExecReference(myfrm_R_bCAD_Nomencl_SelMaterials, Self, [myfoDialog, myfoModal], null);
    if Length(Wh.SelectDialogResult) = 0 then
      Exit;
    Frg1.SetValue('name', Wh.SelectDialogResult[2]);
    LoadItemFromDB(Frg1.RecNo - 1);
 {    va := Q.QLoadToVarDynArrayOneRow('select max(id_group), max(id_unit) from v_bcad_nomencl_add where name = :name$s', [Frg1.GetValue('name')]);
    if Length(va) <> 0 then begin
      Frg1.SetValue('id_group', va[0]);
      Frg1.SetValue('id_unit', va[1]);
    end;}
  end
  else begin
    Wh.ExecReference(myfrm_R_OrderStdItems_SelSemiproduct, Self, [myfoDialog, myfoModal], null);
//    Wh.ExecReference(myfrm_R_OrderStdItems_SEL, Self, [myfoDialog, myfoModal], null);
    if Length(Wh.SelectDialogResult) = 0 then
      Exit;
    Frg1.SetValue('name', Wh.SelectDialogResult[1]);
    LoadItemFromDB(Frg1.RecNo - 1);
{    for i := 0 to Frg1.DBGridEh1.FindFieldColumn('id_group').PickList.Count - 1 do
      if Frg1.DBGridEh1.FindFieldColumn('id_group').PickList[i] = '������� �������' then begin
        Frg1.MemTableEh1.FieldByName('id_group').Value := Frg1.DBGridEh1.FindFieldColumn('id_group').KeyList[i];
        Break;
      end;
    for i := 0 to Frg1.DBGridEh1.FindFieldColumn('id_unit').PickList.Count - 1 do
      if Frg1.DBGridEh1.FindFieldColumn('id_unit').PickList[i] = '��.' then begin
        Frg1.MemTableEh1.FieldByName('id_unit').Value := Frg1.DBGridEh1.FindFieldColumn('id_unit').KeyList[i];
        Break;
      end;}
  end;
//  Mth.PostAndEdit(MemTableEh1);
//  VerifyEstimateRow;
//  Frg1.VerifyTable;
end;


procedure TFrmOGedtEstimate.Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string);
begin
  if Mode <> dbgvCell then
    Exit;
  if (Fr.GetValue('id_group') = null) or (Fr.GetValue('name') = null) then
    Exit;
  if A.InArray(FieldName, ['name', '--id_group']) then
    LoadItemFromDB(Row - 1);
  VerifyRow(Row - 1);
end;

procedure TFrmOGedtEstimate.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if Frg1.RecNo <= 0 then
    Exit;
  if (High(Err2) < Frg1.RecNo) or (S.Nst(Err2[Frg1.RecNo]) = '') then
    Exit;
  if S.Nst(Err2[Frg1.RecNo])[1] = '0' then
    Params.Background := RGB(255, 255, 150);
  if S.Nst(Err2[Frg1.RecNo])[2] = '0' then
    Params.Background := RGB(255, 150, 150);
  if S.Nst(Err2[Frg1.RecNo])[3] = '0' then
    Params.Background := RGB(255, 150, 150);
end;

procedure TFrmOGedtEstimate.Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
  //�������� ������ ��.���. � ������� ������� � ��
  if ((Fr.GetValueI('id_group') = IdProduct) or (Fr.GetValueI('id_group') = IdSemiproduct)) and ({(Fr.CurrField = 'id_group') or }(Fr.CurrField = 'id_unit')) then
    ReadOnly := True;
  //��������� ������� ����� ��������, ���� ��� �� ��
  if (Fr.GetValueI('id_group') <> IdSemiproduct) and (Fr.CurrField =  'purchase') then
    ReadOnly := True;
end;

procedure TFrmOGedtEstimate.btnClick(Sender: TObject);
var
  Tag: Integer;
begin
  Tag := TControl(Self).Tag;
end;

procedure TFrmOGedtEstimate.VerifyRow(Row: Integer);
var
  st: string;
begin
  st := Q.QSelectOneRow('select F_TestEstimateItem(:g$i, :n$s) from dual', [Frg1.GetValue('id_group', Row, False), Frg1.GetValue('name', Row, False)])[0];
  if High(Err2) < Row then
    SetLength(Err2, Row + 2);
  Err2[Row + 1] := st;
end;


procedure TFrmOGedtEstimate.VerifyBeforeSave;
var
  rn, i, j, k, m: Integer;
  Names: TVarDynArray;
  st: string;
  b: Boolean;
begin
  Err := [];
  Err2 := [];
  Names := [];
  b := True;
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    //��������� ������ ������
    //��������� �� ������ ����, ��������� ���� ��������� �� ���������, �� ����� False ��� � inherited
    if Frg1.GetValueS('name', i, False) = '' then
      Continue;
    //--�������� ������������ � ������� ������� �������, ������ � ������
    //--1� ������ = 0 ���� ��� ����� ������ � ����������� ������������ ����
    //--2� ������ = 0 - ������ ��� ������������ �� ������ ������� - ��� ������ ������� � v_or_std_items
    //--3� ������ = 0 - ������ ��� ������������ �� ������ ������� ������� ���� - ������������ ������� � ������ �������, ��� ���� ������� ���������� �������� ������
    st := Q.QSelectOneRow('select F_TestEstimateItem(:g$i, :n$s) from dual', [Frg1.GetValueS('id_group', i, False), Frg1.GetValueS('name', i, False)])[0];
    if st <> '111' then begin
      if (st[2] = '0') or (st[3] = '0') then
        b := False;  //���� ������, � �������� ��������� ����� ������.
      Err := Err + ['[ ' + Frg1.GetValueS('name', i, False) + ' ] - ' + S.IIf(st[2] = '0', '��� ������ �������', S.IIf(st[3] = '0', '��� ��������, � ������ ���� ��������', S.IIf(st[1] = '0', '����� �������!', '')))];
    end;
    if A.PosInArray(Frg1.GetValueS('name', i, False), Names) >= 0 then begin
      b := False;
      Err := Err + ['[ ' + Frg1.GetValueS('name', i, False) + ' ] - ����������� ��������� ���!'];
    end;
    Names := Names + [Frg1.GetValueS('name', i, False)];
  end;
  FErrorMessage := S.IIFStr(Length(Err) > 0, S.IIFStr(b, '?' + A.Implode(Err, #13#10) + #10#13#10#13 + '�������� �����?', A.Implode(Err, #13#10)));
  Frg1.SetState(null, False, A.Implode(Err, #13#10));
end;

function  TFrmOGedtEstimate.Save: Boolean;
var
  i: Integer;
begin
  Result := False;
  Wh.SelectDialogResult2 := [];
  for i := 0 to Frg1.GetCount - 1 do begin
    if Frg1.GetValueS('name', i, False) <> '' then
      Wh.SelectDialogResult2 := Wh.SelectDialogResult2 + [[Frg1.GetValue('name'), Frg1.GetValue('id_group'), Frg1.GetValue('id_unit'), Frg1.GetValue('qnt1'), Frg1.GetValue('comm')]];
  end;
  Result := True;
end;

procedure TFrmOGedtEstimate.LoadFromDB;
begin
  Frg1.SetInitData('*',[]);
  VerifyBeforeSave;
end;

procedure TFrmOGedtEstimate.LoadFromXls;
var
  i, j: Integer;
  Est: TVarDynArray2;
  FileName: string;
begin
  FileName := '';
  if not Orders.EstimateFromFile(FileName, Est) then
    Exit;
  Frg1.LoadSourceDataFromArray(Est, 'name;id_group;id_unit;qnt1;comm', '');//, '3;2;4;5;7');
  VerifyBeforeSave;

  {  Frg1.SetInitData(Est, '');
  Frg1.RefreshGrid;
  VerifyBeforeSave;
}
{  MemTableEh1.EmptyTable;
  InPrepare := True;
  Mth.LoadGridFromVa2(DBGridEh1, Est, 'idgroup;name;idunit;qnt1;comm', '1;0;2;3;4');
  VerifyEstimateAfterLoad;
  Mth.PostAndEdit(MemTableEh1);
  InPrepare := False;}
end;

procedure TFrmOGedtEstimate.LoadItemFromDB(Row: Integer);
var
  i, j: Integer;
  va: TVarDynArray;
begin
  va := Q.QSelectOneRow('select id, is_semiproduct from v_or_std_items where fullname = :fullname$s', [Frg1.GetValue('name', Row, False)]);
  if va[0] <> null then begin
    Frg1.SetValue('id_group', S.IIf(va[1] = 1, IdSemiproduct, IdProduct));
    Frg1.SetValue('id_unit', IdStuff);
  end
  else begin
    va := Q.QSelectOneRow('select id, id_group, id_unit from v_estimate where name = :name$s', [Frg1.GetValue('name', Row, False)]);
    if va[0] <> null then begin
      Frg1.SetValue('id_group', va[1]);
      Frg1.SetValue('id_unit', va[2]);
    end;
  end;
  if Frg1.GetValue('id_group') <> Group_Semiproducts_Id then
    Frg1.SetValue('purchase', 0);
end;




end.
