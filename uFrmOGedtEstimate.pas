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
    procedure VerifyBeforeSave; override;
    function  Save: Boolean; override;
    procedure LoadFromDB;
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
  Caption:= 'Смета';
  FTitleTexts := [S.IIf(TVarDynArray(AddParam)[1] = 0, 'Смета к стандартному изделию:', 'Смета к заказу:'),  '$FF0000' + TVarDynArray(AddParam)[2]];
  pnlTop.Height := 50;

  Orders.LoadBcadGroups(True);

  IdSemiproduct := 2;
  IdProduct := 104;
  IdStuff := 1;


  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['id_or_std_item$i','_id_or_std_item','40'],
    ['id_group$i','Группа','250;w;L','e=0:100000::TP'],
    ['null as type$i','Тип','110;L','e=0:100000::TP'],
    ['name$s','Наименование','400;w;h','e=1:1000','bt=Выбрать из справочника номенклатуры;Выбрать из справочника стандартных изделий'], //:dd
    ['id_unit$i','Ед.изм.','100;L','e=0:1000000::TP'],
    ['qnt1$f','Кол-во','80','e=0:999999:5:N'], {недопустимо пустое кол-во}
    ['null as purchase$i','Покупка','80','chb','e'],
    ['comm$s','Дополнение','300;w;h','e=0:1000::TP']
  ]);
  Frg1.Opt.SetTable('v_estimate', 'estimate_items');
  Frg1.Opt.SetGridOperations('uaid');
  Frg1.Opt.SetWhere('where id_estimate = :id$i order by id_group');
  Frg1.SetInitData('*', [ID]);
  Frg1.Opt.Caption := 'Сметные позиции';

  Frg1.Opt.SetPick('id_group', A.VarDynArray2ColToVD1(Orders.BcadGroups, 0), A.VarDynArray2ColToVD1(Orders.BcadGroups, 1), True);
  Frg1.Opt.SetPick('id_unit', A.VarDynArray2ColToVD1(Orders.BcadUnits, 0), A.VarDynArray2ColToVD1(Orders.BcadUnits, 1), True);
  Frg1.Opt.SetPick('type', ['Материал','Изделие','Полуфабрикат'], [0,1,2], True);

//  Frg1.Dbgrideh1.Columns[4].CellButtons[0].Caption :='М';
//  Frg1.Dbgrideh1.Columns[3].CellButtons[1].Caption :='И';

  FOpt.InfoArray:= [[
  'Ввод сметы.'#13#10
  ]];
  Result := inherited;
end;

function TFrmOGedtEstimate.PrepareFormAdd: Boolean;
begin
  Frg1.Opt.SetButtons(4, [
    [mbtExcel, True, 'Загрузить смету из файла'],
    [mbtLoad, True, 'Загрузить текущую смету из БД'],
    [mbtPasteEstimate, True, 'Вставить смету из буфера'],
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
  if Tag = mbtLoad then
    Frg1.LoadData('*', [ID])
{  else if Tag = mbtAdd then
    Frg1.AddRow
  else if Tag = mbtInsert then
    Frg1.InsertRow
  else if Tag = mbtDelete then
    Frg1.DeleteRow}
  else
    inherited;
end;

procedure TFrmOGedtEstimate.Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
var
  va: TVarDynArray;
  i: Integer;
begin
  Wh.SelectDialogResult := [];
  if TCellButtonEh(Sender).Hint = 'Выбрать из справочника номенклатуры' then begin
    Wh.ExecReference(myfrm_R_bCAD_Nomencl_SEL, Self, [myfoDialog, myfoModal], null);
    if Length(Wh.SelectDialogResult) = 0 then
      Exit;
    Frg1.SetValue('name', Wh.SelectDialogResult[2]);
    va := Q.QLoadToVarDynArrayOneRow('select max(id_group), max(id_unit) from v_bcad_nomencl_add where name = :name$s', [Frg1.GetValue('name')]);
    if Length(va) <> 0 then begin
      Frg1.SetValue('id_group', va[0]);
      Frg1.SetValue('id_unit', va[1]);
    end;
  end
  else begin
    Wh.ExecReference(myfrm_R_OrderStdItems_SEL, Self, [myfoDialog, myfoModal], null);
    if Length(Wh.SelectDialogResult) = 0 then
      Exit;
    Frg1.SetValue('name', Wh.SelectDialogResult[1]);
    for i := 0 to Frg1.DBGridEh1.FindFieldColumn('id_group').PickList.Count - 1 do
      if Frg1.DBGridEh1.FindFieldColumn('id_group').PickList[i] = 'Готовые изделия' then begin
        Frg1.MemTableEh1.FieldByName('id_group').Value := Frg1.DBGridEh1.FindFieldColumn('id_group').KeyList[i];
        Break;
      end;
    for i := 0 to Frg1.DBGridEh1.FindFieldColumn('id_unit').PickList.Count - 1 do
      if Frg1.DBGridEh1.FindFieldColumn('id_unit').PickList[i] = 'шт.' then begin
        Frg1.MemTableEh1.FieldByName('id_unit').Value := Frg1.DBGridEh1.FindFieldColumn('id_unit').KeyList[i];
        Break;
      end;
  end;
//  Mth.PostAndEdit(MemTableEh1);
//  VerifyEstimateRow;
//  Frg1.VerifyTable;
end;


procedure TFrmOGedtEstimate.Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string);
var
  st: string;
begin
  if (Fr.GetValue('id_group') = null) or (Fr.GetValue('name') = null) then
    Exit;
  st := Q.QSelectOneRow('select F_TestEstimateItem(:g$i, :n$s) from dual', [Fr.GetValue('id_group'), Fr.GetValue('name')])[0];
  if High(Err2) < Row then
    SetLength(Err2, Row + 1);
  Err2[Row] := st;
  LoadItemFromDB(Row - 1);
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
  if ((Fr.GetValueI('id_group') = IdProduct) or (Fr.GetValueI('id_group') = IdSemiproduct)) and ((Fr.CurrField = 'id_group') or (Fr.CurrField = 'id_unit')) then
    ReadOnly := True;
end;



procedure TFrmOGedtEstimate.btnClick(Sender: TObject);
var
  Tag: Integer;
begin
  Tag := TControl(Self).Tag;
end;


procedure TFrmOGedtEstimate.VerifyBeforeSave;
begin

end;

function  TFrmOGedtEstimate.Save: Boolean;
begin

end;

procedure TFrmOGedtEstimate.LoadFromDB;
begin
  Frg1.SetInitData('*',[]);
{  MemTableEh1.Edit;
  Q.QLoadToMemTableEh('select id_group as idgroup, name, id_unit as idunit, qnt1, comm from v_estimate where id_estimate = :id$i order by groupname', [id], MemTableEh1);
  VerifyEstimateAfterLoad;
  Mth.PostAndEdit(MemTableEh1);}
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
end;




end.
