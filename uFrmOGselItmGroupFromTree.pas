{
Выбор группы номенклатуры (изделий) из иерархического дерева групп (dv.groups). Двойной клик по узлу открывает
список номенклатуры этой группы (myfrm_R_Itm_InGroup_Nomencl). Кнопка "Выбрать" возвращает выбранную группу,
только если это лист дерева (нет дочерних групп) - для промежуточных узлов клик по "Выбрать" ничего не делает.
Чекбокс "Материалы" переключает корень дерева (группа 1 - обычная номенклатура, группа 4 - материалы).
Единственный вызывающий код - uFrmOWItmInfo.pas.
}
unit uFrmOGselItmGroupFromTree;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, MemTableDataEh, Data.DB,
  ToolCtrlsEh, DBGridEhToolCtrls, Vcl.StdCtrls,
  Vcl.Buttons, DBCtrlsEh, GridsEh, DBAxisGridsEh, DBGridEh,
  MemTableEh, Data.Win.ADODB, DataDriverEh, ADODataDriverEh,
  EhLibVclUtils, DBGridEhGrouping, DynVarsEh, Vcl.Mask,
  uFrmBasicMdi, uData
  ;

const
  cBtnSelect = 1001;
  cBtnCollapse = 1002;
  cBtnExpand = 1003;

type
  TFrmOGselItmGroupFromTree = class(TFrmBasicMdi)
    DataSource1: TDataSource;
    MemTableEh1: TMemTableEh;
    DBGridEh1: TDBGridEh;
    ADODataDriverEh1: TADODataDriverEh;
    chb_Materials: TDBCheckBoxEh;
    procedure DBGridEh1DblClick(Sender: TObject);
    procedure chb_MaterialsClick(Sender: TObject);
  private
    { Private declarations }
    procedure SetQuery;
    procedure AfterFormActivate; override;
    procedure btnClick(Sender: TObject); override;
  public
    { Public declarations }
    function ShowDialog(AOwner: TObject; AIdGroup: Variant): Integer;
  end;

var
  FrmOGselItmGroupFromTree: TFrmOGselItmGroupFromTree;

implementation

{$R *.dfm}

uses
  uSettings,
  uForms,
  uString,
  uWindows
  ;

{--------------------------------------------------------------------}
{ Сохранение открытых веток и текущей ветки дерева                   }
{--------------------------------------------------------------------}
function SavePositionTreeStr(oMemTableEh: TMemTableEh): string;
var
  cItems: string;
  cSelected: string;
  nCount: Integer;
  nCou: Integer;
begin
  cItems := '';
  cSelected := '';
  with oMemTableEh, oMemTableEh.RecordsView.MemoryTreeList do begin
    cSelected := FieldByName(TreeList.KeyFieldName).AsString;
    nCount := AccountableCount;
    for nCou := 0 to nCount - 1 do
      if (AccountableItem[nCou].NodeExpanded) and (AccountableItem[nCou].NodeHasChildren) then
        cItems := cItems + VarToStr(AccountableItem[nCou].Rec.DataValues[TreeList.KeyFieldName, dvvValueEh]) + ',';
  end; { with }
  Delete(cItems, Length(cItems), 1);
  Result := '#' + cSelected + '#' + cItems + '#';
end;

procedure RestorePositionTree(oMemTableEh: TMemTableEh; cTreeState: string);
var
  nCou: Integer;
  nCount: Integer;
  cValue: string;
  cItems: string;
  cSelected: string;
begin
  cSelected := ExtractWord(1, cTreeState, ['#']);
  cItems := ExtractWord(2, cTreeState, ['#']);
  with oMemTableEh, oMemTableEh.RecordsView.MemoryTreeList do begin
    TreeList.FullCollapse();
    nCount := AccountableCount;
    for nCou := 0 to nCount - 1 do begin
      cValue := VarToStr(AccountableItem[nCou].Rec.DataValues[TreeList.KeyFieldName, dvvValueEh]);
      if S.InCommaStr(cValue, cItems, ',') and (AccountableItem[nCou].NodeHasChildren) then
        AccountableItem[nCou].NodeExpanded := True;
    end; { for }
    if cSelected <> '' then
      Locate(TreeList.KeyFieldName, StrToInt(cSelected), []);
  end; { with }
end;

procedure TFrmOGselItmGroupFromTree.AfterFormActivate;
//фокус на грид: без этого не видна подсветка значения, найденного перед открытием методом MemTableEh1.TreeList.Locate
//(см. также исходный TForm_TestTree.FormShow)
begin
  inherited;
  DBGridEh1.SetFocus;
end;

procedure TFrmOGselItmGroupFromTree.btnClick(Sender: TObject);
//см. также исходные Bt_OkClick/Bt_CollapseClick/Bt_ExpandClick
begin
  case TControl(Sender).Tag of
    cBtnSelect:
      if not MemTableEh1.TreeNodeHasChildren then
        Self.ModalResult := mrOk;
    cBtnCollapse:
      MemTableEh1.TreeList.FullCollapse;
    cBtnExpand:
      MemTableEh1.TreeList.FullExpand;
  else
    inherited;
  end;
end;

procedure TFrmOGselItmGroupFromTree.chb_MaterialsClick(Sender: TObject);
var
  st: string;
begin
  st := SavePositionTreeStr(MemTableEh1);
  MemTableEh1.Close;
  SetQuery;
  MemTableEh1.Active := True;
  MemTableEh1.Refresh;
  RestorePositionTree(MemTableEh1, st);
end;

procedure TFrmOGselItmGroupFromTree.DBGridEh1DblClick(Sender: TObject);
var
  id_group: Variant;
begin
  if MemTableEh1.RecordCount = 0 then Exit;
  id_group := MemTableEh1.FieldByName('id_group').Value;
  Wh.ExecReference(myfrm_R_Itm_InGroup_Nomencl, Self, [myfoModal, myfoSizeable], id_group);
end;

procedure TFrmOGselItmGroupFromTree.SetQuery;
begin
  ADODataDriverEh1.SelectCommand.CommandText.Text :=
    'select id_group, id_parentgroup, groupname from dv.groups g1 ' +
    'connect by prior g1.id_group = g1.id_parentgroup ' +
    'start with g1.id_group = ' +
    S.IIfStr(chb_Materials.Checked, '4', '1') +
    ' order by groupname'
    ;
end;

function TFrmOGselItmGroupFromTree.ShowDialog(AOwner: TObject; AIdGroup: Variant): Integer;
//см. также аналогичный исходный TForm_TestTree.ShowDialog
var
  st: string;
begin
  Result := -1;
  PrepareCreatedForm(AOwner, Self.Name, '~Выбор группы', fNone, Null, [], [myfoModal, myfoDialog, myfoDialogButtonsB, myfoSizeable], False);
  FOpt.DlgButtonsM := [
    [cBtnSelect, True, 'Выбрать'],
    [cBtnCollapse, True, 'Свернуть'],
    [cBtnExpand, True, 'Раскрыть']
  ];

  if DBGridEh1.Columns.Count = 1 then begin
    MemTableEh1.DataDriver := nil;
    MemTableEh1.FieldDefs.Clear;
    MemTableEh1.Close;
    Mth.AddTableColumn(DBGridEh1, 'id_group', ftInteger, 0, 'id_group', 100, False);
    Mth.AddTableColumn(DBGridEh1, 'id_parentgroup', ftInteger, 0, 'id_parentgroup', 100, False);
    Mth.AddTableColumn(DBGridEh1, 'groupname', ftString, 400, 'Наименование', 300, True);
    MemTableEh1.CreateDataSet;
    MemTableEh1.TreeList.Active := True;
    MemTableEh1.TreeList.KeyFieldName := 'id_group';
    MemTableEh1.TreeList.RefParentFieldName := 'id_parentgroup';
    DBGridEh1.Columns[1].AutoFitColWidth := False;
    DBGridEh1.OptionsEh := DBGridEh1.OptionsEh - [dghColumnResize, dghColumnMove] + [dghEnterAsTab] + [dghAutoFitRowHeight];
    DBGridEh1.AutoFitColWidths := True;
    DBGridEh1.AllowedOperations := [alopUpdateEh];
    DBGridEh1.IndicatorOptions := [gioShowRowIndicatorEh];
    DBGridEh1.IndicatorParams.VertLines := True;
    DBGridEh1.Options := [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgTabs, dgConfirmDelete, dgCancelOnExit, dgMultiSelect];
    DBGridEh1.OptionsEh := [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDblClickOptimizeColWidth, dghDialogFind, dghRecordMoving, dghColumnResize, dghColumnMove];
    DBGridEh1.STFilter.Local := True;
    DBGridEh1.STFilter.Visible := True;
    DBGridEh1.TreeViewParams.GlyphStyle := tvgsExplorerThemedEh;
    DBGridEh1.TreeViewParams.ShowTreeLines := True;
    MemTableEh1.DataDriver := ADODataDriverEh1;
    MemTableEh1.FetchAllOnOpen := True;

    DBGridEh1.Options := DBGridEh1.Options - [dgTitles, dgIndicator];
    ADODataDriverEh1.SelectCommand.CommandText.Text := 'select id_group, id_parentgroup, groupname from test_groups';

    SetQuery;

    DBGridEh1.ReadOnly := True;
  end;
  MemTableEh1.ReadOnly := False;

  st := Settings.ReadProperty(FormDoc, 'position_tree');
  Cth.SetControlValue(chb_Materials, S.IIf(Settings.ReadProperty(FormDoc, 'materials_only') = '1', 1, 0));

  SetQuery;

  MemTableEh1.Close;
  MemTableEh1.Active := True;
  MemTableEh1.Refresh;

  if (S.VarIsClear(AIdGroup)) or (S.NNum(AIdGroup) = -1) then
    RestorePositionTree(MemTableEh1, st)
  else begin
    RestorePositionTree(MemTableEh1, st);
    MemTableEh1.TreeList.Locate('id_group', AIdGroup, []);
  end;

  ShowModal;
  //сохраняем состояние дерева и чекбокса вне зависимости от того, как закрыт диалог (см. также исходный FormClose)
  Settings.WriteProperty(FormDoc, 'position_tree', SavePositionTreeStr(MemTableEh1));
  Settings.WriteProperty(FormDoc, 'materials_only', Cth.GetControlValue(chb_Materials));
  if ModalResult <> mrOk then Exit;
  Result := MemTableEh1.FieldByName('id_group').AsInteger;
end;

end.
