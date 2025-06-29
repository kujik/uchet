unit D_NewEstimateInput;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, F_MdiGridDialogTemplate, DBGridEhGrouping,
  ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, MemTableDataEh, Data.DB, MemTableEh, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh,
  Vcl.Buttons, uLabelColors, uString;

{
в AddParam передаем:
[IdEstimate, 0(изд)/1(зак), наименование_издели/заказа]
}

type
  TDlg_NewEstimateInput = class(TForm_MdiGridDialogTemplate)
    lbl_Caption: TLabel;
    Bt_Load: TBitBtn;
    lbl_Type: TLabel;
    Bt_LoadSelf: TBitBtn;
    Bt_PasteEstimate: TBitBtn;
    Bt_CopyEstimate: TBitBtn;
    procedure CellButtonClick(Sender: TObject; var Handled: Boolean); override;
    procedure DBGridEh1ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure Bt_LoadClick(Sender: TObject);
    procedure DBGridEh1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Bt_LoadSelfClick(Sender: TObject);
    procedure DBGridEh1GetCellParams(Sender: TObject; Column: TColumnEh; AFont: TFont; var Background: TColor; State: TGridDrawState);
    procedure Bt_PasteEstimateClick(Sender: TObject);
    procedure Bt_CopyEstimateClick(Sender: TObject);
  private
    { Private declarations }
    Err, Err2: TVarDynArray;
    function Prepare: Boolean; override;
    function InitGrid: Boolean; override;            //создаем грид и мемтейбл (поля, настройки...). вызывается в Prepare, обязательно перекрывается.
    function InitAdd: Boolean; override;             //Дополнительные действия потомка, которые вызывается в Prepare.
    function VerifyBeforeSave: string; override;     //
    function IsRowCorrect: Boolean; override;        //
    function VerifyEstimateRow: string;
    //проверка корректности сметы после загрузки
    //(но можно и в любой момент)
    procedure VerifyEstimateAfterLoad;
  public
    { Public declarations }
  end;

var
  Dlg_NewEstimateInput: TDlg_NewEstimateInput;

implementation

uses
  DateUtils, uSettings, uForms, uDBOra, uMessages, uData, uOrders, uWindows;


{$R *.dfm}

function TDlg_NewEstimateInput.IsRowCorrect: Boolean;
begin
  Result:=inherited;
  //Result := (MemTableEh1.FieldByName('name').AsString <> '') and (MemTableEh1.FieldByName('idgroup').AsString <> '') and (MemTableEh1.FieldByName('idunit').AsString <> '') and (MemTableEh1.FieldByName('qnt1').AsString <> '');
end;

function TDlg_NewEstimateInput.VerifyEstimateRow: string;
var
  st: string;
begin
  if (MemTableEh1.FieldByName('idgroup').Value = null)or(MemTableEh1.FieldByName('name').Value = null) then Exit;
  st:=Q.QSelectOneRow('select F_TestEstimateItem(:g$i, :n$s) from dual',
    [MemTableEh1.FieldByName('idgroup').Value, MemTableEh1.FieldByName('name').Value]
  )[0];
  if High(Err2) < MemTableEh1.RecNo then SetLength(Err2, MemTableEh1.RecNo + 1);
  Err2[MemTableEh1.RecNo]:=st;
end;


function TDlg_NewEstimateInput.VerifyBeforeSave: string;
var
  rn, i, j, k, m: Integer;
  va1: TVarDynArray;
  st: string;
  b: Boolean;
begin
  Mth.PostAndEdit(MemTableEh1);
  Result := inherited;
  if Result <> '' then
    Exit;
  Result := '';
{  va1 := A.Explode(FieldsNoRepaeted, ';');
  rn := MemTableEh1.RecNo;
  MemTableEh1.RecNo := 1;
  for i := 1 to MemTableEh1.RecordCount do begin
    Result := IsRowCorrect;
    if not Result then
      Break;
  end;}
  st := '';
  Err := [];
  b := True;
{(*}
  for i:=0 to MemTableEh1.RecordsView.MemTableData.RecordsList.Count - 1 do begin
    //пропустим пустые строки
    //проверяем по одному полю, поскольку если заполнены не полностью, то будет False еще в inherited
    if S.NSt(MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['name', dvvValueEh]) = '' then Continue;
    //--проверим правильность и новизну сметной позиции, вернем в строке
    //--1й символ = 0 если нет такой позция в справочнике номенклатуры бкад
    //--2й символ = 0 - ошибка для номенклатуры из группы Изделий - нет такого изделия в v_or_std_items
    //--3й символ = 0 - ошибка для номенклатуры из группы сметных позиций бкад - номенклатура найдена в списке изделий, при этом являясь материалом согласно группе
    st:=Q.QSelectOneRow('select F_TestEstimateItem(:g$i, :n$s) from dual',
      [MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['idgroup', dvvValueEh], MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['name', dvvValueEh]]
    )[0];
    if st <> '111' then begin
//      Err:=Err + [st];
      if (st[2] = '0')or(st[3] = '0') then
        b:=False;  //были ошибки, с которыми сохранять смету нельзя.
      Err:=Err + ['[ ' + MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['name', dvvValueEh] + ' ] - ' +
        S.IIf(st[2] = '0', 'Нет такого изделия', S.IIf(st[3] = '0', 'Это изщделие, а должен быть материал', S.IIf(st[1] = '0', 'Новая позиция!', '')))];
    end;
  end;
{*)}
  if Length(Err) = 0 then
    //ошибок и предупреждения нет
    Result := ''
  else if b then begin
    //есть только предупреждения (новые позиции) - спросим
    if MyQuestionMessage(A.Implode(Err, #13#10) + #10#13#10#13 + 'Записать смету?') = mrYes then
      //записать
      Result := ''
    else begin
      //вернуться в редактоh
      b := False;
      Result := '-';
    end;
  end
  else    //критические ошибки - не пишем смету
    Result := A.Implode(Err, #13#10);
  if b then begin
    //запишем смету
    //myinfomessage('Save');
//  Mth.LoadGridFromVa2(DBGridEh1, Est, 'group;name;unit;qnt1;comm', '1;0;2;3;4');
    Wh.SelectDialogResult2 := [];
    for i := 0 to MemTableEh1.RecordsView.MemTableData.RecordsList.Count - 1 do begin
      if S.NSt(MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['name', dvvValueEh]) = '' then
        Continue;
      Wh.SelectDialogResult2 := Wh.SelectDialogResult2 + [[MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['name', dvvValueEh], MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['idgroup', dvvValueEh], MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['idunit', dvvValueEh], MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['qnt1', dvvValueEh], MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['comm', dvvValueEh]]];
    end;
    Result := '';
  end;
{*)}
end;

procedure TDlg_NewEstimateInput.VerifyEstimateAfterLoad;
//проверка корректности сметы после загрузки
//(но можно и в любой момент)
var
  i, j: Integer;
begin
  MemTableEh1.DisableControls;
  for i := 1 to MemTableEh1.RecordCount do begin
    MemTableEh1.RecNo:=i;
    VerifyEstimateRow;
  end;
  MemTableEh1.First;
  MemTableEh1.EnableControls;
end;

procedure TDlg_NewEstimateInput.Bt_CopyEstimateClick(Sender: TObject);
begin
  if MyQuestionMessage('В буфер будет скопирована уже сохраненная смета! Изменения, сделанные в этом окне без сохранения сметы, скопированы не будут! Продолжить?') <> mrYes then
    Exit;
   Orders.CopyEstimateToBuffer(id, null);
end;

procedure TDlg_NewEstimateInput.Bt_LoadClick(Sender: TObject);
var
  i, j: Integer;
  Est: TVarDynArray2;
  FileName: string;
begin
  //[Name, idgr, idunit, cQnt1, cComm];
  FileName := '';
  if not Orders.EstimateFromFile(FileName, Est) then
    Exit;
  MemTableEh1.EmptyTable;
  InPrepare := True;
  Mth.LoadGridFromVa2(DBGridEh1, Est, 'idgroup;name;idunit;qnt1;comm', '1;0;2;3;4');
  VerifyEstimateAfterLoad;
  Mth.PostAndEdit(MemTableEh1);
  InPrepare := False;
end;

procedure TDlg_NewEstimateInput.Bt_LoadSelfClick(Sender: TObject);
begin
  inherited;
  MemTableEh1.Edit;
  Q.QLoadToMemTableEh('select id_group as idgroup, name, id_unit as idunit, qnt1, comm from v_estimate where id_estimate = :id$i order by groupname', [id], MemTableEh1);
  VerifyEstimateAfterLoad;
  Mth.PostAndEdit(MemTableEh1);
end;

procedure TDlg_NewEstimateInput.Bt_PasteEstimateClick(Sender: TObject);
begin
  inherited;
  if MyQuestionMessage('Вставить смету из буфера?') <> mrYes then
    Exit;
  MemTableEh1.Edit;
  Q.QLoadToMemTableEh('select id_group as idgroup, name, id_unit as idunit, qnt1, comm from v_estimate where id_estimate = :id$i order by groupname', [-User.GetID], MemTableEh1);
  VerifyEstimateAfterLoad;
  Mth.PostAndEdit(MemTableEh1);
end;

procedure TDlg_NewEstimateInput.CellButtonClick(Sender: TObject; var Handled: Boolean);
var
  va: TVarDynArray;
  i: Integer;
begin
 // if MemTableEh1.RecordCount = 0 then Exit;
  Wh.SelectDialogResult := [];
  if TCellButtonEh(Sender).Hint =  'Выбрать из справочника номенклатуры' then begin
    Wh.ExecReference(myfrm_R_bCAD_Nomencl_SEL, Self, [myfoDialog, myfoModal], null);
    if Length(Wh.SelectDialogResult) = 0 then
      Exit;
    MemTableEh1.Edit;
    MemTableEh1.FieldByName('name').Value := Wh.SelectDialogResult[2];
    va := Q.QLoadToVarDynArrayOneRow('select max(id_group), max(id_unit) from v_bcad_nomencl_add where name = :name$s', [MemTableEh1.FieldByName('name').Value]);
    if Length(va) <> 0 then begin
      MemTableEh1.FieldByName('idgroup').Value := va[0];
      MemTableEh1.FieldByName('idunit').Value := va[1];
    end;
  end
  else begin
    Wh.ExecReference(myfrm_R_OrderStdItems_SEL, Self, [myfoDialog, myfoModal], null);
    if Length(Wh.SelectDialogResult) = 0 then
      Exit;
    MemTableEh1.Edit;
    MemTableEh1.FieldByName('name').Value := Wh.SelectDialogResult[1];
    for i := 0 to DBGridEh1.FindFieldColumn('idgroup').PickList.Count - 1 do
      if DBGridEh1.FindFieldColumn('idgroup').PickList[i] = 'Готовые изделия' then begin
        MemTableEh1.FieldByName('idgroup').Value := DBGridEh1.FindFieldColumn('idgroup').KeyList[i];
        Break;
      end;
    for i := 0 to DBGridEh1.FindFieldColumn('idunit').PickList.Count - 1 do
      if DBGridEh1.FindFieldColumn('idunit').PickList[i] = 'шт.' then begin
        MemTableEh1.FieldByName('idunit').Value := DBGridEh1.FindFieldColumn('idunit').KeyList[i];
        Break;
      end;
  end;
  Mth.PostAndEdit(MemTableEh1);
  VerifyEstimateRow;
end;

procedure TDlg_NewEstimateInput.DBGridEh1ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
  inherited;
  VerifyEstimateRow;
end;

procedure TDlg_NewEstimateInput.DBGridEh1GetCellParams(Sender: TObject;
  Column: TColumnEh; AFont: TFont; var Background: TColor;
  State: TGridDrawState);
begin
  inherited;
  if MemTableEh1.RecNo <= 0 then Exit;
  if (High(Err2) < MemTableEh1.RecNo)or(S.Nst(Err2[MemTableEh1.RecNo])='') then Exit;
  if S.Nst(Err2[MemTableEh1.RecNo])[1] = '0' then Background:=RGB(255,255,150);
  if S.Nst(Err2[MemTableEh1.RecNo])[2] = '0' then Background:=RGB(255,150,150);
  if S.Nst(Err2[MemTableEh1.RecNo])[3] = '0' then Background:=RGB(255,150,150);
end;

procedure TDlg_NewEstimateInput.DBGridEh1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
//для стандартных изделия по нажатии F2 внесем позицию, равную краткому (без префиксов) наименованию этого же изеделия
//(менеджер должен отредактировать, поставив префикс другого стандартного формата)
var
  i, j: Integer;
begin
  inherited;
  if (Key = vk_F2) and (TVarDynArray(AddParam)[1] = 0) then begin
    Mth.PostAndEdit(MemTableEh1);
    MemTableEh1.FieldByName('name').Value := TVarDynArray(AddParam)[2];
    for i := 0 to DBGridEh1.FindFieldColumn('idgroup').PickList.Count - 1 do
      if DBGridEh1.FindFieldColumn('idgroup').PickList[i] = 'Готовые изделия' then begin
        MemTableEh1.FieldByName('idgroup').Value := DBGridEh1.FindFieldColumn('idgroup').KeyList[i];
        Break;
      end;
    for i := 0 to DBGridEh1.FindFieldColumn('idunit').PickList.Count - 1 do
      if DBGridEh1.FindFieldColumn('idunit').PickList[i] = 'шт.' then begin
        MemTableEh1.FieldByName('idunit').Value := DBGridEh1.FindFieldColumn('idunit').KeyList[i];
        Break;
      end;
    MemTableEh1.FieldByName('qnt1').Value := 1;
    Mth.PostAndEdit(MemTableEh1);
  end;
end;

function TDlg_NewEstimateInput.InitGrid: Boolean;
var
  i, j: Integer;
  va2: TVarDynArray2;
begin
  {(*}
  Orders.LoadBcadGroups(True);
  Mth.CreateTableGrid(
    DBGridEh1, True, False, False, False,[
    ['idgroup', ftString, 1000, 'Группа', 200, True, False, False],
    ['name', ftString, 1000, 'Наименование', 400, True, True, True],
    ['idunit', ftString, 50, 'Ед.изм.', 100, True, False, False],
    ['qnt1', ftFloat, 0, 'Кол-во', 80, True, False, False],
    ['comm', ftString, 1000, 'Дополнение', 400, True, True, True]
    ],
    [], '', ''
  );
  {*)}
  ColumnsVerifications := ['1:1000', '1:1000', '1:50:TP', '0:999999:5:N'{недопустимо пустое кол-во}, '0:1000::TP'];  //TP - ????
  FieldsNoRepaeted := 'name';
//  Gh.SetGridColumnPickList(DBGridEh1, 'group', Q.QLoadToVarDynArrayOneCol('select name from bcad_groups order by name', []), [], True);
//  Gh.SetGridColumnPickList(DBGridEh1, 'unit', Q.QLoadToVarDynArrayOneCol('select name from bcad_units order by name', []), [], True);
  Gh.SetGridColumnPickList(DBGridEh1, 'idgroup', A.VarDynArray2ColToVD1(Orders.BcadGroups, 0), A.VarDynArray2ColToVD1(Orders.BcadGroups, 1), True);
  Gh.SetGridColumnPickList(DBGridEh1, 'idunit', A.VarDynArray2ColToVD1(Orders.BcadUnits, 0), A.VarDynArray2ColToVD1(Orders.BcadUnits, 1), True);
  Gh.SetGridInCellButtons(DBGridEh1, 'name;name', 'Выбрать из справочника номенклатуры;Выбрать из справочника стандартных изделий', CellButtonClick);
//  Gh.SetGridInCellButtons(DBGridEh1, 'name;name', 'номенклатуры;стандартных изделий', CellButtonClick);
//  Gh.SetGridInCellButtons(DBGridEh1, 'name', 'Выбрать из справочника номенклатуры', CellButtonClick);

  if id <> null
    then Bt_LoadSelfClick(nil);

  OneRowOnOpen := True;
  AllowEmptyTable := False;
  Result := True;
end;

function TDlg_NewEstimateInput.InitAdd: Boolean;
begin
  Caption := 'Cмета';
  if (Mode <> fView) and (id <> null)
    then Mode:= fEdit else Mode := fAdd;
  InfoArr := [['Ввод новой сметы.', id = null], ['Редактирование сметы.', id <> null], ['www', False]];
  pnl_Top.Visible := True;
  pnl_Bottom.Visible := False;
  lbl_Type.Caption := '';
  lbl_Caption.Caption := '';
  lbl_Type.Caption := S.IIf(TVarDynArray(AddParam)[1] = 0, 'Смета к стандартному изделию:', 'Смета к заказу:');
  lbl_Caption.Caption := TVarDynArray(AddParam)[2];
  //lbl_Caption.SetCaption2('Смета к стандартному изделию: ''$FF0000  КП.П_Стока кассовая 100х600');
  //lbl_Caption.WordWrap := True;
  Cth.SetBtn(Bt_Load, mybtExcel, True, 'Загрузить смету из файла');
  Cth.SetBtn(Bt_LoadSelf, mybtLoad, True, 'Загрузить текущую смету из БД');
  Cth.SetBtn(Bt_PasteEstimate, mybtPasteEstimate, True, 'Вставить смету из буфера');
  Cth.SetBtn(Bt_CopyEstimate, mybtLoad, True, 'Скопировать смету в буфер');
  Bt_LoadSelf.Enabled := id <> null;
  Result := True;
end;

function TDlg_NewEstimateInput.Prepare: Boolean;
begin
  Wh.SelectDialogResult2 := [];
  Result := inherited;
end;

end.


(*
при редактировании сметы разрешаем количество с произвольным числом знаков после запятой.
после записи количество на единицу округляется до 5 знаков, поскольку тип в бд number(11,5)
а при этом количесвто на все изделия округляется до одного знака в большую сторону
(это делается процедурой в БД)

*)
