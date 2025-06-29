unit F_TestTree;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_Normal, MemTableDataEh, Data.DB,
  DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.Mask, DBCtrlsEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh,
  MemTableEh, Data.Win.ADODB, DataDriverEh, ADODataDriverEh, DateUtils;

type
  TForm_TestTree = class(TForm_Normal)
    DataSource1: TDataSource;
    MemTableEh1: TMemTableEh;
    DBGridEh1: TDBGridEh;
    edt_PPComment: TDBEditEh;
    Bt_Ok: TBitBtn;
    ADODataDriverEh1: TADODataDriverEh;
    Bt_Collapse: TBitBtn;
    Bt_Expand: TBitBtn;
    chb_Materials: TDBCheckBoxEh;
    procedure Bt_OkClick(Sender: TObject);
    procedure Bt_CollapseClick(Sender: TObject);
    procedure Bt_ExpandClick(Sender: TObject);
    procedure DBGridEh1DblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure chb_MaterialsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure SetQuery;
  public
    { Public declarations }
    function  ShowDialog(IdGroup: Variant): Integer;
  end;

var
  Form_TestTree: TForm_TestTree;

implementation

uses
  uSettings,
  uForms,
  uDBOra,
  uString,
  uData,
  uMessages,
  uWindows
  ;

{$R *.dfm}


{--------------------------------------------------------------------}
{ Сохранение открытых веток и текущей ветки дерева                   }
{--------------------------------------------------------------------}
function SavePositionTreeStr(oMemTableEh :TMemTableEh) :string;
var
  cItems    :string;
  cSelected :string;
  nCount    :Integer;
  nCou      :Integer;
begin
cItems    := '';
cSelected := '';
with oMemTableEh, oMemTableEh.RecordsView.MemoryTreeList do begin
   cSelected := FieldByName(TreeList.KeyFieldName).AsString;
   nCount := AccountableCount;
   for nCou := 0 to nCount-1 do
     if (AccountableItem[nCou].NodeExpanded) and (AccountableItem[nCou].NodeHasChildren) then
       cItems := cItems + VarToStr(AccountableItem[nCou].Rec.DataValues[TreeList.KeyFieldName, dvvValueEh])+',';
end; { with }
Delete(cItems, Length(cItems), 1);
Result := '#'+cSelected+'#'+cItems+'#';
end;

procedure RestorePositionTree(oMemTableEh :TMemTableEh; cTreeState :string);
var
  nCou      :Integer;
  nCount    :Integer;
  cValue    :string;
  cItems    :string;
  cSelected :string;
begin
cSelected := ExtractWord(1, cTreeState, ['#']);
cItems    := ExtractWord(2, cTreeState, ['#']);
with oMemTableEh, oMemTableEh.RecordsView.MemoryTreeList do begin
   TreeList.FullCollapse();
   nCount := AccountableCount;
   for nCou := 0 to nCount-1 do begin
     cValue := VarToStr(AccountableItem[nCou].Rec.DataValues[TreeList.KeyFieldName, dvvValueEh]);
//     if IsWordPresent(cValue, cItems, [',']) and (AccountableItem[nCou].NodeHasChildren)then
     if S.InCommaStr(cValue, cItems, ',') and (AccountableItem[nCou].NodeHasChildren)then
       AccountableItem[nCou].NodeExpanded := True;
   end; { for }
   if cSelected <> '' then
     Locate(TreeList.KeyFieldName, StrToInt(cSelected), [])
end; { with }
end;

procedure TForm_TestTree.Bt_CollapseClick(Sender: TObject);
begin
  MemTableEh1.TreeList.FullCollapse;
end;

procedure TForm_TestTree.Bt_ExpandClick(Sender: TObject);
begin
  MemTableEh1.TreeList.FullExpand;
end;

procedure TForm_TestTree.Bt_OkClick(Sender: TObject);
begin
  if MemTableEh1.TreeNodeHasChildren
    then Exit;
  ModalResult:= mrOk;
//  if not MemTableEh1.TreeNodeHasChildren
//    then MyInfoMessage(MemTableEh1.FieldByName('groupname').AsString);
end;

procedure TForm_TestTree.chb_MaterialsClick(Sender: TObject);
var
  st:string;
begin
  st:=SavePositionTreeStr(MemTableEh1);
  MemTableEh1.Close;
  SetQuery;
  Memtableeh1.Active:=True;
  Memtableeh1.Refresh;
  RestorePositionTree(MemTableEh1, st);
end;

procedure TForm_TestTree.DBGridEh1DblClick(Sender: TObject);
var
  id_group: Variant;
begin
  inherited;
  if MemTableEh1.RecordCount = 0 then Exit;
  id_group:= MemTableEh1.FieldByName('id_group').Value;
  Wh.ExecReference(myfrm_R_Itm_InGroup_Nomencl, Self, [myfoModal, myfoSizeable], id_group);
  //MyInfoMessage(MemTableEh1.FieldByName('groupname').AsString);
end;

procedure TForm_TestTree.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  Settings.WriteProperty(FormDoc, 'position_tree', SavePositionTreeStr(MemTableEh1));
  Settings.WriteProperty(FormDoc, 'materials_only', Cth.GetControlValue(chb_Materials));
end;

procedure TForm_TestTree.FormShow(Sender: TObject);
begin
  inherited;
  //фокус на грид
  //если этого не сделать, не видим подсветки значения, найденного перед открытием методом Memtable.TreeList.Locate
  DBGridEh1.SetFocus;
end;

procedure TForm_TestTree.SetQuery;
begin
  Adodatadrivereh1.SelectCommand.CommandText.Text:=
    'select id_group, id_parentgroup, groupname from dv.groups g1 ' +
    'connect by prior g1.id_group = g1.id_parentgroup '+
    'start with g1.id_group = '+
    S.IIfStr(chb_Materials.checked, '4', '1')+
    ' order by groupname'
    ;
end;


function TForm_TestTree.ShowDialog(IdGroup: Variant): Integer;
var
  st:string;
  i: Integer;
begin
  FormDoc:='Dlg_TestTree';
  Caption:='Выбор группы';
  MinWidth:=370;
  MinHeight:=400;
  if DBGridEh1.Columns.Count = 1 then begin
    MemTableEh1.DataDriver:=nil;
    MemTableEh1.FieldDefs.Clear;
    MemTableEh1.close;
    Mth.AddTableColumn(DBGridEh1, 'id_group', ftInteger, 0, 'id_group', 100, False);
    Mth.AddTableColumn(DBGridEh1, 'id_parentgroup', ftInteger, 0, 'id_parentgroup', 100, False);
    Mth.AddTableColumn(DBGridEh1, 'groupname', ftString, 400, 'Наименование', 300, True);
    MemTableEh1.CreateDataSet;
    MemTableEh1.TreeList.Active := True;
    MemTableEh1.TreeList.KeyFieldName := 'id_group';
    MemTableEh1.TreeList.RefParentFieldName := 'id_parentgroup';
    DBGridEh1.Columns[1].AutoFitColWidth:=False;
//    DBGridEh1.Columns[1].AlwaysShowEditButton:=True;
    DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh-[dghColumnResize, dghColumnMove] + [dghEnterAsTab] + [dghAutoFitRowHeight];
    DBGridEh1.AutoFitColWidths:=True;
    //скроем айди
//    DBGridEh1.Columns[0].Visible:=False;
    //обработчики ввода данных в гриде
//    DBGridEh1.Columns[1].onUpdateData:=DBGridEh1ColumnsUpdateData;
//    DBGridEh1.Columns[2].onUpdateData:=DBGridEh1ColumnsUpdateData;
    //операции будем выполнять по кнопкам (добавление строки - нажатие +), здеь отключим чтобы не выполнялись автоматом напр при скроллинге стрелками
    DBGridEh1.AllowedOperations:=[alopUpdateEh];
//    Gh._SetDBGridEhSumFooter(DBGridEh1, 'qnt', '0');
    DBGridEh1.IndicatorOptions := [gioShowRowIndicatorEh];
    DBGridEh1.IndicatorParams.VertLines := True;
    DBGridEh1.Options := [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgTabs, dgConfirmDelete, dgCancelOnExit, dgMultiSelect];
    DBGridEh1.OptionsEh := [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDblClickOptimizeColWidth, dghDialogFind, dghRecordMoving, dghColumnResize, dghColumnMove];
    DBGridEh1.STFilter.Local := True;
    DBGridEh1.STFilter.Visible := True;
    DBGridEh1.TreeViewParams.GlyphStyle := tvgsExplorerThemedEh;
    DBGridEh1.TreeViewParams.ShowTreeLines := True; //False;
    MemTableEh1.DataDriver:=adodatadrivereh1;
    MemTableEh1.FetchAllOnOpen:=True;

    DBGridEh1.Options := DBGridEh1.Options - [dgTitles, dgIndicator];
//    DBGridEh1.Title
//    adodatadrivereh1.SelectCommand.CommandText.Text:='select id_group, id_parentgroup, groupname from test_groups where id_parentgroup = 1 or id_group = 1';// order by groupname';
    Adodatadrivereh1.SelectCommand.CommandText.Text:='select id_group, id_parentgroup, groupname from test_groups';// order by groupname';
//    adodatadrivereh1.UpdateCommand.CommandText.Text:='select id_group, id_parentgroup, groupname from test_groups';// order by groupname';

    SetQuery;

    DBGridEh1.ReadOnly:=True;

  end;
  MemTableEh1.ReadOnly:=False;

  st:=Settings.ReadProperty(FormDoc, 'position_tree');
  Cth.SetControlValue(chb_Materials, S.IIf(Settings.ReadProperty(FormDoc, 'materials_only') = '1', 1, 0));

  SetQuery;

  MemTableEh1.close;
  Memtableeh1.Active:=True;
  Memtableeh1.refresh;

  AutoSaveWindowPos:= True;

  if (S.VarIsClear(IdGroup)) or (S.NNum(IdGroup) = -1) then begin
    //если передено пустое значение, сохраним раскрытые ранее ноды грида
    RestorePositionTree(MemTableEh1, st);
  end
  else begin
    //если передано айди группы, найдем его и откроем этот узел (Locate откроет)
//    MemTableEh1.TreeList.FullCollapse;
    RestorePositionTree(MemTableEh1, st);
    MemTableEh1.TreeList.Locate('id_group', IdGroup, []);
  end;

  ModalResult:=mrNone;
  Result:= -1;
  ShowModal;
  if ModalResult <> mrOk then Exit;
  Result:= MemTableEh1.FieldByName('id_group').AsInteger;
end;


end.




