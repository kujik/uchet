{*******************************************************}
{                                                       }
{                      EhLib.Fmx 12.1                   }
{                EhLibFmx.FormElementsViewer            }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

{$I ..\Incl\EhLib.Inc}
{$SCOPEDENUMS ON}

unit EhLibFmx.FormElementsViewer;

interface

{$REGION 'uses'}
uses
  SysUtils, Variants, Classes, Types, Contnrs,
  Generics.Collections, DB, Math,
  System.UITypes, System.TypInfo, Rtti,
  FMX.Controls.Presentation,
  MemTableDataEh, MemTableEh,
  FMX.Objects,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.StdCtrls,
  FMX.Styles.Objects, FMX.Styles,

  EhLibUtils, MemTreeEh,
  EhLib.TableLink.TypedLists,
  EhLibFmx.Utils,
  EhLibFmx.ToolControls,
  EhLibFmx.Grids,
  EhLibFmx.ObjectInspectors,
  EhLibFmx.ImageReses,
  EhLibFmx.Types,
  EhLibFmx.Styles,

  EhLibFmx.LaObjects,
  EhLibFmx.LaPanels,
  EhLibFmx.LaControls,
  EhLibFmx.LaGridPanels,

  EhLibFmx.Grid.CellManagers,
  EhLibFmx.Grid.Types,

  EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.DataAxisGrids,
  EhLibFmx.DataAxisGrid.DataCells,

  EhLibFmx.CustomDataGrids,
  EhLibFmx.DataGrid.Rows,

  EhLibFmx.DataGrid.DataCells,

  EhLibFmx.DataGrid.Columns,

  EhLibFmx.DataGrids, FMX.Layouts, FMX.Edit, EhLibFmx.DataGrid.SearchPanels, FMX.ImgList
  ;
{$ENDREGION 'uses'}

type
  TFormItemsTreeListEh = class;
  TFormItemNodeEh = class;
  TLaPropNameCellContentEh = class;

  TLaObjectTreeViewForm = class(TFormEh)
    Panel1: TPanel;
    Splitter1: TSplitter;
    ObjInsPanel: TPanel;
    bOnlyVisibleObjects: TButton;
    MemTableEh1: TMemTableEh;
    bTest: TButton;
    TrackPanel: TPanel;
    Layout1: TLayout;
    cbPublished: TCheckBox;
    cbPublic: TCheckBox;
    cbProtected: TCheckBox;
    cbProperties: TCheckBox;
    cbFields: TCheckBox;
    EdPropName: TEdit;
    Label1: TLabel;
    cbVisible: TCheckBox;
    bPropsToDataGrid: TButton;
    Text1: TText;
    FindPromptText: TText;
    ChBoxHighlightFocus: TCheckBox;
    Image2: TImage;
    LayoutPreview: TLayout;
    Button1: TButton;
    PreviewRectangle: TRectangle;
    PreviewTimer: TTimer;
    btnShowStyleData: TButton;
    procedure FormCreate(Sender: TObject);
    procedure DataSource1DataChange(Sender: TObject; Field: TField);
    procedure bOnlyVisibleObjectsClick(Sender: TObject);
    procedure TrackPanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbPublishedChange(Sender: TObject);
    procedure EdPropNameChangeTracking(Sender: TObject);
    procedure bTestClick(Sender: TObject);
    procedure cbVisibleClick(Sender: TObject);
    procedure bPropsToDataGridClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure colTreeDisplayNameGetDataCellManager(Sender: TObject;
      Params: TDataGridGetDataCellManagerParamsEh);
    procedure ChBoxHighlightFocusChange(Sender: TObject);
    procedure PreviewTimerTimer(Sender: TObject);
    procedure btnShowStyleDataClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar;
      Shift: TShiftState);
  private
    FForm: TFmxObject;

    FDataGridObjIns: TDataGridObjectInspectorEh;
    FObjInsInternalUpdating: Boolean;
    FObjInsCurrentPath: TArray<String>;
    FObjInsTopToCurRowGap: Integer;

    FOnlyVisibleObjects: Boolean;
    FControlsSetting: Boolean;
    FSelectedComponent: TObject;
    FPreviewObject: TObject;

    FFormItemsTreeList: TFormItemsTreeListEh;
    ListTableLink: TListTableLinkEh;

    TreeCellManager: TDataAxisCellManagerEh;

    function CreateDataGridObjectInspector: TDataGridObjectInspectorEh;
    function GetMemberVisibilities: TMemberVisibilities;
    function GetObjectMemberKinds: TObjectMemberKinds;
    function GetTypeKinds: TTypeKinds;
    function ObjectAtPointAbs(Form: TCommonCustomForm; AScreenPoint: TPointF): TControl;

    procedure ElementsGridDataCellGetStyleParams(Sender: TObject; Params: TDataGridDataCellStyleParamsEh);
    procedure FillLaObjectTreeViewForParent(Parent: TBaseTreeNodeEh; FmxObject: TFmxObject; Level: Integer);
    procedure GridCurrentChange(Sender: TObject; Params: TDataGridEventParamsEh);
    procedure InitCheckboxes;
    procedure LocateObject(Obj: TFmxObject);
    procedure SetComponent(const Value: TObject);
    procedure SetForm(const Value: TFmxObject);
    procedure SetMemberVisibilities(const Value: TMemberVisibilities);
    procedure SetObjectMemberKind(const Value: TObjectMemberKinds);
    procedure SetPropertiesFromControl;
    procedure SetTypeKinds(const Value: TTypeKinds);
    function GetPropNameFilter: String;
    procedure SetPropNameFilter(const Value: String);
    procedure TreeListViewChanged(Sender: TObject);
    procedure TreeNodeExpandedStateChanged(Sender: TFormItemsTreeListEh; PropTreeNode: TFormItemNodeEh);
    procedure TreeNodePropsChanged(Sender: TFormItemsTreeListEh; PropTreeNode: TFormItemNodeEh);
    procedure InitDataTreeViewAreaParams(Sender: TObject; Params: TDataGridDataTreeViewAreaParamsEh);
    procedure SetDataTreeSignState(Sender: TObject; Params: TDataGridSetDataTreeSignStateParamsEh) ;
    procedure ObjInsCurrentChanged(Sender: TObject; Params: TDataGridEventParamsEh);
    procedure SaveObjInsCurrentPath();
    procedure RestoreObjInsCurrentPath();
    procedure DoPreviewCurrentObject;

  protected
    procedure FreeNotification(AObject: TObject); override;

  public
    DataGridEh1: TDataGridEh;
    colDisplayName: TDataGridStringColumnEh;
    colTreeDisplayName: TDataGridStringColumnEh;

    procedure FillLaObjectTreeView;

    class procedure ShowDefaultForm(AForm: TForm; FormBounds: TRect);
    class procedure ShowNewForm(AForm: TForm; FormBounds: TRect);

    property Form: TFmxObject read FForm write SetForm;
    property SelectedComponent: TObject read FSelectedComponent write SetComponent;
    property PreviewObject: TObject read FPreviewObject;
    property TypeKinds: TTypeKinds read GetTypeKinds write SetTypeKinds;
    property MemberVisibilities: TMemberVisibilities read GetMemberVisibilities write SetMemberVisibilities;
    property ObjectMemberKinds: TObjectMemberKinds read GetObjectMemberKinds write SetObjectMemberKind;
    property PropNameFilter: String read GetPropNameFilter write SetPropNameFilter;
  end;

{ TFormItemNodeEh }

  TTreeNodeExpandedStateChangedEventEh = procedure (Sender: TFormItemsTreeListEh; PropTreeNode: TFormItemNodeEh) of object;

  TFormItemNodeEh = class(TBaseTreeNodeEh)
  private
    FDisplayName: String;
    FFormItem: TObject;
    FIndentedDisplayName: String;
    function GetFormItemTypeName: String;
    function GetItem(const Index: Integer): TFormItemNodeEh; reintroduce;
    function GetNodeOwner: TFormItemsTreeListEh;
    function GetNodeParent: TFormItemNodeEh;
    function GetVisibleItem(const Index: Integer): TFormItemNodeEh;
    procedure SetNodeParent(const Value: TFormItemNodeEh);
    procedure SetFormItem(const Value: TObject);

  protected
    procedure RefreshValue;

  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Collapse;
    procedure Expand;
    procedure ExpandedStateChanged();

    property Expanded;
    property HasChildren;
    property FormItem: TObject read FFormItem write SetFormItem;
    property Items[const Index: Integer]: TFormItemNodeEh read GetItem; default;
    property Owner: TFormItemsTreeListEh read GetNodeOwner;
    property Parent: TFormItemNodeEh read GetNodeParent write SetNodeParent;
    property VisibleItem[const Index: Integer]: TFormItemNodeEh read GetVisibleItem;
  published
    property DisplayName: String read FDisplayName write FDisplayName;
    property IndentedDisplayName: String read FIndentedDisplayName write FIndentedDisplayName;
    property FormItemTypeName: String read GetFormItemTypeName;
  end;

{ TDestructionMonitorEh }

  TDestructionMonitorEh = class(TFmxObject)
  protected
    FTreeList: TFormItemsTreeListEh;
    procedure FreeNotification(AObject: TObject); override;
  public
    constructor Create(AOwner: TFormItemsTreeListEh); reintroduce;
    destructor Destroy; override;
  end;

  TPropTreeNodeClassEh = class of TFormItemNodeEh;

{ TFormItemsTreeListEh }

  TFormItemsTreeListEh = class(TTreeListEh)
  private
    FVisibleExpandedItems: TObjectList;
    FVisibleItemsObsolete: Boolean;
    FOnVisibleListChanged: TNotifyEvent;
    FOnTreeNodeExpandedStateChanged: TTreeNodeExpandedStateChangedEventEh;

    FDestructionMonitor: TDestructionMonitorEh;
    FOnNodePropsChanged: TTreeNodeExpandedStateChangedEventEh;

    function GetRoot: TFormItemNodeEh;
    function GetVisibleExpandedItems: TObjectList;

    procedure ClearDestructionMonitor();
  protected
    function GetVisibleCount: Integer;
    function GetVisibleExpandedItem(const Index: Integer): TFormItemNodeEh; virtual;

    procedure TreeChanged(Node: TBaseTreeNodeEh; Operation: TTreeListNotificationEh; OldIndex: Integer; OldParentNode: TBaseTreeNodeEh); override;

    procedure VisibleListChanged;
    procedure HandleTreeItemFreed(AObject: TObject);
    procedure AddFormItemFreeNotify(AObject: TObject);
  public
    constructor Create(ItemClass: TPropTreeNodeClassEh);
    destructor Destroy; override;

    procedure BuildVisibleItems;
    procedure VisibleItemsBecomeObsolete;
    procedure RefreshAllValues;
    procedure ExpandedStateChanged(PropTreeNode: TFormItemNodeEh);
    procedure NodePropsChanged(PropTreeNode: TFormItemNodeEh);

    property Root: TFormItemNodeEh read GetRoot;
    property VisibleExpandedCount: Integer read GetVisibleCount;
    property VisibleExpandedItem[const Index: Integer]: TFormItemNodeEh read GetVisibleExpandedItem; default;
    property VisibleExpandedItems: TObjectList read GetVisibleExpandedItems;
    property VisibleItemsObsolete: Boolean read FVisibleItemsObsolete;

    property OnVisibleListChanged: TNotifyEvent read FOnVisibleListChanged write FOnVisibleListChanged;
    property OnTreeNodeExpandedStateChanged: TTreeNodeExpandedStateChangedEventEh read FOnTreeNodeExpandedStateChanged write FOnTreeNodeExpandedStateChanged;
    property OnNodePropsChanged: TTreeNodeExpandedStateChangedEventEh read FOnNodePropsChanged write FOnNodePropsChanged;
  end;

{ TDataGridTreeTextDataCellManagerEh }

  TDataGridTreeTextDataCellManagerEh = class(TDataAxisCellManagerEh)
  private
    procedure InitTreeContentState(Params: TBaseGridInitCellContentParamsEh);
  protected
    function CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh; override;
  public
    procedure DefaultInitCellContent(Params: TBaseGridInitCellContentParamsEh); override;
  end;

{ TDataGridTreeTextDataCellEh }

  TDataGridTreeTextDataCellEh = class(TDataAxisCellEh)
  private
    FMasterContent: TLaPropNameCellContentEh;
  protected
    function CreateDefaultCellContentControls(AParentObject: TLaObjectEh): TLaObjectEh; override;
  end;

 { TLaPropNameCellContentEh }

  TLaPropNameCellContentEh = class(TLaLayoutPanelEh)
  private
      FBlackBlock: TLaTextBlockEh;
      FPurpleBlock: TLaTextBlockEh;
      FExtraBlock: TLaTextBlockEh;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure CreateLaPropNameControls();

    property BlackBlock: TLaTextBlockEh read FBlackBlock;
    property PurpleBlock: TLaTextBlockEh read FPurpleBlock;
    property ExtraBlock: TLaTextBlockEh read FExtraBlock;
  end;

var
  LaObjectTreeViewForm: TLaObjectTreeViewForm;

procedure ShowLaObjectTreeViewForm(AForm: TForm; FormBounds: TRect; NewForm: Boolean = False);

implementation

{$R *.fmx}

type
  TDataGridEhCrack = class(TDataGridEh);

procedure ShowLaObjectTreeViewForm(AForm: TForm; FormBounds: TRect; NewForm: Boolean = False);
var
  Form: TLaObjectTreeViewForm;
begin
  if NewForm or (LaObjectTreeViewForm = nil) then
  begin
    Form := TLaObjectTreeViewForm.Create(Application);
    if not NewForm then
      LaObjectTreeViewForm := Form;
  end else
  begin
    Form := LaObjectTreeViewForm;
  end;

  Form.Form := AForm;

  Form.SetBounds(FormBounds.Left, FormBounds.Top,
    FormBounds.Right-FormBounds.Left, FormBounds.Bottom-FormBounds.Top);
  Form.Show;
end;

function ControlBranchIsVisible(AControl: TControl): Boolean;
var
  AParent: TControl;
begin
  Result := True;
  AParent := AControl;
  while (AParent <> nil) do
  begin
    if AParent.Visible = False  then
    begin
      Result := False;
      Exit;
    end;
    if AParent.Parent is TControl then
      AParent := TControl(AParent.Parent)
    else
      AParent := nil;
  end;
end;

function GetObjectHierarchy(AObject: TObject): String;
var
  AClass: TClass;
begin
  Result := '';
  if AObject = nil then Exit;

  AClass := AObject.ClassType;
  while AClass <> nil do
  begin
    if Result = '' then
      Result := AClass.ClassName
    else
      Result := Result + ' -> ' + AClass.ClassName;
    AClass := AClass.ClassParent;
  end;
end;

function GetRefObjectFromRow(Row: TDataGridRowEh): TObject;
var
  FormItemNode: TFormItemNodeEh;
begin
  Result := nil;
  if (Row <> nil) then
  begin
    FormItemNode := TFormItemNodeEh(Row.SourceObjectItem);
    Result := FormItemNode.FormItem;
  end;
end;

function CloneControlWithoutChildren(Src: TControl; AOwner: TComponent): TComponent;
var
  Dest: TComponent;
  CtrlClass: TComponentClass;
begin
  if Src = nil then
    Exit(nil);

  CtrlClass := TComponentClass(Src.ClassType);

  Dest := CtrlClass.Create(AOwner);

  with TRttiContext.Create do
  try
    var SrcType := GetType(Src.ClassType);
    for var Prop in SrcType.GetProperties do
    begin
      if Prop.IsWritable and (Prop.Visibility in [mvPublished, mvPublic]) then
      begin
        try
          Prop.SetValue(Dest, Prop.GetValue(Src));
        except
        end;
      end;
    end;
  finally
    Free;
  end;

  Result := Dest;
end;


{$REGION 'TLaObjectTreeViewForm'}

{ TLaObjectTreeViewForm }

class procedure TLaObjectTreeViewForm.ShowDefaultForm(AForm: TForm;
  FormBounds: TRect);
begin
  ShowLaObjectTreeViewForm(AForm, FormBounds, False);
end;

class procedure TLaObjectTreeViewForm.ShowNewForm(AForm: TForm;
  FormBounds: TRect);
begin
  ShowLaObjectTreeViewForm(AForm, FormBounds, True);
end;

procedure TLaObjectTreeViewForm.FillLaObjectTreeView;
begin
  if FFormItemsTreeList = nil then Exit;

  FFormItemsTreeList.Clear;
  if (Form <> nil) then
    FillLaObjectTreeViewForParent(nil, Form, 0);
  FFormItemsTreeList.VisibleItemsBecomeObsolete;

  ListTableLink.SetList(FFormItemsTreeList.VisibleExpandedItems, TypeInfo(TFormItemNodeEh));

  DataGridEh1.DataSource := ListTableLink;
  DataGridEh1.OptimizeAllColsWidth(1000);
end;

procedure TLaObjectTreeViewForm.FillLaObjectTreeViewForParent(Parent: TBaseTreeNodeEh; FmxObject: TFmxObject; Level: Integer);
var
  I: Integer;
  DisplayName: String;
  IndentedDisplayName: String;
  LaChild: TFmxObject;
  ChildNode: TFormItemNodeEh;
begin

  DisplayName := FmxObject.ClassName;
  if FmxObject.Name <> '' then
    DisplayName := FmxObject.Name + ' : ' + DisplayName;

  IndentedDisplayName := StringOfChar(' ', Level * 4) + DisplayName;

  ChildNode := FFormItemsTreeList.AddChild(DisplayName, Parent, nil) as TFormItemNodeEh;
  ChildNode.IndentedDisplayName := IndentedDisplayName;
  ChildNode.DisplayName := DisplayName;
  ChildNode.FormItem := FmxObject;

  for I := 0 to FmxObject.ChildrenCount - 1 do
  begin
    LaChild := FmxObject.Children[I];
    if (FOnlyVisibleObjects = True) and
       (LaChild is TControl) and
       (TControl(LaChild).Visible = False)
    then
    else
      FillLaObjectTreeViewForParent(ChildNode, LaChild, Level + 1);
  end;
end;

procedure TLaObjectTreeViewForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (Form <> nil) and (Form is TFormEh) then
    TFormEh(Form).FormViewer := nil;
end;

procedure TLaObjectTreeViewForm.FormCreate(Sender: TObject);
begin
  FDataGridObjIns := CreateDataGridObjectInspector;

  TrackPanel.AutoCapture := True;
  InitCheckboxes;

  DataGridEh1 := TDataGridEh.Create(Self);
  DataGridEh1.Parent := Self;
  DataGridEh1.AutoGenerateColumns := False;
  DataGridEh1.Align := TAlignLayout.Client;
  DataGridEh1.Name := 'TreeElementsGrid';

  colDisplayName := TDataGridStringColumnEh.Create(Self);
  colDisplayName.FieldName := 'IndentedDisplayName';
  colDisplayName.Visible := False;
  colDisplayName.Width := 120;
  DataGridEh1.StaticColumns.Add(colDisplayName);

  colTreeDisplayName := TDataGridStringColumnEh.Create(Self);
  colTreeDisplayName.ColSizeUnit := TGridColSizeUnitEh.Weight;
  colTreeDisplayName.FieldName := 'DisplayName';
  colTreeDisplayName.Width := 120;
  colTreeDisplayName.OnGetDataCellManager := colTreeDisplayNameGetDataCellManager;
  DataGridEh1.StaticColumns.Add(colTreeDisplayName);

  DataGridEh1.OnDataCellGetStyleParams := ElementsGridDataCellGetStyleParams;
  DataGridEh1.OnCurrentChange := GridCurrentChange;

  DataGridEh1.OnGetDataTreeViewAreaParams := InitDataTreeViewAreaParams;
  DataGridEh1.OnSetDataTreeSignState := SetDataTreeSignState;

  ListTableLink := TListTableLinkEh.Create(Self);
  FFormItemsTreeList := TFormItemsTreeListEh.Create(TFormItemNodeEh);
  FFormItemsTreeList.OnVisibleListChanged := TreeListViewChanged;
  FFormItemsTreeList.OnTreeNodeExpandedStateChanged := TreeNodeExpandedStateChanged;
  FFormItemsTreeList.OnNodePropsChanged := TreeNodePropsChanged;

  TreeCellManager := TDataGridTreeTextDataCellManagerEh.Create(Self);

  if FOnlyVisibleObjects = True
    then bOnlyVisibleObjects.Text := 'Only Visible Objects = Yes'
    else bOnlyVisibleObjects.Text := 'Only Visible Objects = No';
end;

procedure TLaObjectTreeViewForm.FormDestroy(Sender: TObject);
begin
  SelectedComponent := nil;
  FreeAndNil(FFormItemsTreeList);
end;

procedure TLaObjectTreeViewForm.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key = vkF11 then
  begin
    TLaObjectTreeViewForm.ShowNewForm(Self, Rect(100, 100, 800, 1000));
    Key := 0;
  end;
end;

procedure TLaObjectTreeViewForm.TreeListViewChanged(Sender: TObject);
begin
  ListTableLink.SetList(FFormItemsTreeList.VisibleExpandedItems, TypeInfo(TFormItemNodeEh));
end;

procedure TLaObjectTreeViewForm.TreeNodeExpandedStateChanged(
  Sender: TFormItemsTreeListEh; PropTreeNode: TFormItemNodeEh);
var
  LastPropTreeNode: TFormItemNodeEh;
  LastVertRollPos: Int64;
begin
  if DataGridEh1.CurrentRow <> nil then
    LastPropTreeNode := TFormItemNodeEh(DataGridEh1.CurrentRow.SourceObjectItem)
  else
    LastPropTreeNode := nil;

  LastVertRollPos := DataGridEh1.VertAxis.RollStartVisPos;
  FFormItemsTreeList.BuildVisibleItems;
  ListTableLink.SetList(FFormItemsTreeList.VisibleExpandedItems, TypeInfo(TFormItemNodeEh));

  if LastPropTreeNode <> nil then
  begin
    DataGridEh1.LocateRow(
      function(ADataRow: TDataGridRowEh): Boolean
      begin
        if ADataRow.SourceObjectItem = LastPropTreeNode then
          Result := True
        else
          Result := False;
      end);
  end;

  DataGridEh1.Invalidate;
  DataGridEh1.CheckUpdateViewLayout;
  DataGridEh1.SafeSetTopRollPos(LastVertRollPos);
end;

procedure TLaObjectTreeViewForm.TreeNodePropsChanged(Sender: TFormItemsTreeListEh; PropTreeNode: TFormItemNodeEh);
begin
  DataGridEh1.Invalidate;
end;

procedure TLaObjectTreeViewForm.InitDataTreeViewAreaParams(Sender: TObject; Params: TDataGridDataTreeViewAreaParamsEh);
var
  FormItemNode: TFormItemNodeEh;
begin
  if (Params.Row <> nil) then
  begin
    FormItemNode := TFormItemNodeEh(Params.Row.SourceObjectItem);
    Params.TreeAreaVisible := True;
    Params.SignVisible := FormItemNode.HasChildren;
    if FormItemNode.Expanded = True
      then Params.SignState := TTreeSignStateEh.Expanded
      else Params.SignState := TTreeSignStateEh.Collapsed;
    Params.Level := FormItemNode.Level - 1;
  end;
end;

procedure TLaObjectTreeViewForm.SetDataTreeSignState(Sender: TObject; Params: TDataGridSetDataTreeSignStateParamsEh);
var
  PropTreeNode: TFormItemNodeEh;
  FormItemNodeParent: TFormItemNodeEh;
  I: Integer;
  IsExpanded: Boolean;
begin
  if Params.Row = nil then Exit;

  FObjInsInternalUpdating := True;
  PropTreeNode := TFormItemNodeEh(Params.Row.SourceObjectItem);

  if ssCtrl in Params.ShiftState then
  begin
    IsExpanded := PropTreeNode.Expanded;
    if PropTreeNode.Parent <> nil then
    begin
      FormItemNodeParent := PropTreeNode.Parent;
      for I := 0 to FormItemNodeParent.VisibleItems.Count - 1 do
      begin
        if IsExpanded = True
          then TFormItemNodeEh(FormItemNodeParent.VisibleItems[I]).Collapse
          else TFormItemNodeEh(FormItemNodeParent.VisibleItems[I]).Expand;
      end;
    end;
  end else
  begin
    if PropTreeNode.Expanded
      then PropTreeNode.Collapse
      else PropTreeNode.Expand;
  end;

  FObjInsInternalUpdating := False;
end;

procedure TLaObjectTreeViewForm.GridCurrentChange(Sender: TObject; Params: TDataGridEventParamsEh);
var
  RefObject: TObject;
begin
  if (DataGridEh1.CurrentRow <> nil) then
  begin
    RefObject := GetRefObjectFromRow(DataGridEh1.CurrentRow);
    Label1.Text := GetObjectHierarchy(RefObject);
  end;
  DataSource1DataChange(nil, nil);
end;

procedure TLaObjectTreeViewForm.InitCheckboxes;
begin
  FControlsSetting := True;
  cbPublished.IsChecked := TMemberVisibility.mvPublished in MemberVisibilities;
  cbPublic.IsChecked := TMemberVisibility.mvPublic in MemberVisibilities;
  cbProtected.IsChecked := TMemberVisibility.mvProtected in MemberVisibilities;

  cbProperties.IsChecked := TObjectMemberKind.omkProperty in ObjectMemberKinds;
  cbFields.IsChecked := TObjectMemberKind.omkField in ObjectMemberKinds;
  FControlsSetting := False;
end;

procedure TLaObjectTreeViewForm.SetPropertiesFromControl;
begin
  if cbPublished.IsChecked
    then MemberVisibilities := MemberVisibilities + [TMemberVisibility.mvPublished]
    else MemberVisibilities := MemberVisibilities - [TMemberVisibility.mvPublished];
  if cbPublic.IsChecked
    then MemberVisibilities := MemberVisibilities + [TMemberVisibility.mvPublic]
    else MemberVisibilities := MemberVisibilities - [TMemberVisibility.mvPublic];
  if cbProtected.IsChecked
    then MemberVisibilities := MemberVisibilities + [TMemberVisibility.mvProtected]
    else MemberVisibilities := MemberVisibilities - [TMemberVisibility.mvProtected];

  if cbProperties.IsChecked
    then ObjectMemberKinds := ObjectMemberKinds + [TObjectMemberKind.omkProperty]
    else ObjectMemberKinds := ObjectMemberKinds - [TObjectMemberKind.omkProperty];
  if cbFields.IsChecked
    then ObjectMemberKinds := ObjectMemberKinds + [TObjectMemberKind.omkField]
    else ObjectMemberKinds := ObjectMemberKinds - [TObjectMemberKind.omkField];
end;

procedure TLaObjectTreeViewForm.SetComponent(const Value: TObject);
begin
  FSelectedComponent := Value;
  if FDataGridObjIns.Component <> FSelectedComponent then
  begin
    FObjInsInternalUpdating := True;
    if (FDataGridObjIns.Component <> nil) and (FDataGridObjIns.Component is TFmxObject) then
      TFmxObject(FDataGridObjIns.Component).RemoveFreeNotify(Self);
    FDataGridObjIns.Component := FSelectedComponent;
    FObjInsInternalUpdating := False;
    RestoreObjInsCurrentPath();
    if (FDataGridObjIns.Component <> nil) and (FDataGridObjIns.Component is TFmxObject) then
      TFmxObject(FDataGridObjIns.Component).AddFreeNotify(Self);
  end;

  if (Form <> nil) and (Form is TFormEh) then
  begin
    if (ChBoxHighlightFocus.IsChecked = True) and
       (SelectedComponent <> nil) and
       (SelectedComponent is TFmxObject)
    then
      TFormEh(Form).DesignBacklightObject := TFmxObject(SelectedComponent)
    else
      TFormEh(Form).DesignBacklightObject := nil;
  end;
end;

procedure TLaObjectTreeViewForm.SetForm(const Value: TFmxObject);
begin
  if (FForm <> Value) then
  begin
    if (FForm <> nil) and (FForm is TFormEh) then
      TFormEh(FForm).FormViewer := nil;
    FForm := Value;
    if (FForm <> nil) and (FForm is TFormEh) then
      TFormEh(FForm).FormViewer := Self;
    FillLaObjectTreeView;
  end;
end;

procedure TLaObjectTreeViewForm.LocateObject(Obj: TFmxObject);
var
  ResultObj: TObject;
  CheckingObj: TFmxObject;
  LocateResult: Boolean;
begin
  ResultObj := nil;
  CheckingObj := Obj;
  while ResultObj = nil do
  begin
    LocateResult :=
      DataGridEh1.LocateRow(
        function(ADataRow: TDataGridRowEh): Boolean
        var
          RecObj: TObject;
        begin
          RecObj := GetRefObjectFromRow(ADataRow);
          if RecObj = CheckingObj then
          begin
            Result := True;
            ResultObj := RecObj;
          end else
            Result := False;
        end);
    if LocateResult = False then
    begin
      if CheckingObj.Parent <> nil then
        CheckingObj := CheckingObj.Parent
      else
        Exit;
    end;
  end;
end;

procedure TLaObjectTreeViewForm.TrackPanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
  ScreenPos: TPointF;
  Ctrl: IControl;
begin
  if (Captured <> nil) and
     (Captured.GetObject = TrackPanel) and
     (Form is TFormEh)
  then
  begin
    ScreenPos := TrackPanel.Scene.LocalToScreen(TrackPanel.LocalToAbsolute(TPointF.Create(X, Y)));
    Ctrl := ObjectAtPointAbs(TFormEh(Form), ScreenPos);
    if (Ctrl <> nil) and (Ctrl.GetObject <> nil) then
    begin
      LocateObject(Ctrl.GetObject);
    end;
  end;
end;

function TLaObjectTreeViewForm.ObjectAtPointAbs(Form: TCommonCustomForm; AScreenPoint: TPointF): TControl;

  function GetObjectAtPoint(Control: TFmxObject; LocalPos: TPointF; CheckHitTest: Boolean): TControl;
  var
    I: Integer;
    ControlItfs: IControl;
    Target: TFmxObject;
    TargetControl: TControl;
    TargetPos: TPointF;
    ALocalRect: TRectF;
    Child: TControl;
    CanTestHit: Boolean;
  begin
    Result := nil;
    if Control is TControl then
    begin
      ALocalRect := TControl(Control).LocalRect;
      if CheckHitTest
        then CanTestHit := TControl(Control).HitTest
        else CanTestHit := True;
      if CanTestHit and ALocalRect.Contains(LocalPos) then
        Result := TControl(Control)
      else
        Exit(nil);
    end else if Control is TCommonCustomForm then
    begin
      ALocalRect := TRectF.Create(0, 0, TCommonCustomForm(Control).Width, TCommonCustomForm(Control).Height);
    end;

    for I := Control.ChildrenCount - 1 downto 0 do
    begin
      if Supports(Control.Children[I], IControl, ControlItfs) and ControlItfs.GetVisible then
      begin
        Target := ControlItfs.GetObject;
        if Target is TControl then
        begin
          TargetControl := TControl(Target);
          TargetPos := LocalPos - TargetControl.Position.Point;
          Child := GetObjectAtPoint(Target, TargetPos, CheckHitTest);
          if (Child <> nil) then
            Exit(Child);
        end;
      end;
    end;
  end;

var
  LocalPos: TPointF;
  Ctrl: IControl;
begin
  if Form = nil then Exit(nil);
  if Form.Bounds.Contains(AScreenPoint.Round) = False then Exit(nil);

  LocalPos := Form.ScreenToClient(AScreenPoint);
  Ctrl := Form.ObjectAtPoint(AScreenPoint);
  if (Ctrl <> nil) and (Ctrl.GetObject <> nil) and (Ctrl.GetObject is TControl) then
  begin
    Result := TControl(Ctrl.GetObject);
    LocalPos := Result.AbsoluteToLocal((Result.Scene.ScreenToLocal(AScreenPoint)));
    Result := GetObjectAtPoint(Result, LocalPos, False);
  end else
  begin
    Result := nil;
  end;
end;

procedure TLaObjectTreeViewForm.bPropsToDataGridClick(Sender: TObject);
var
  ATypeKinds: TTypeKinds;
  AMemberVisibilities: TMemberVisibilities;
  AObjectMemberKinds: TObjectMemberKinds;
  APropNameFilter: String;
begin
  if FDataGridObjIns = nil then
  begin
    FDataGridObjIns := CreateDataGridObjectInspector;
    FDataGridObjIns.TypeKinds := ATypeKinds;
    FDataGridObjIns.MemberVisibilities := AMemberVisibilities;
    FDataGridObjIns.ObjectMemberKinds := AObjectMemberKinds;
    FDataGridObjIns.PropNameFilter := APropNameFilter;
    FDataGridObjIns.Component := FSelectedComponent;

  end else
  begin
    ATypeKinds := FDataGridObjIns.TypeKinds;
    AMemberVisibilities := FDataGridObjIns.MemberVisibilities;
    AObjectMemberKinds := FDataGridObjIns.ObjectMemberKinds;
    APropNameFilter := FDataGridObjIns.PropNameFilter;
    FreeAndNil(FDataGridObjIns);
  end;
end;

function TLaObjectTreeViewForm.CreateDataGridObjectInspector: TDataGridObjectInspectorEh;
begin
  Result := TDataGridObjectInspectorEh.Create(Self);
  Result.Parent := ObjInsPanel;
  Result.Align := TAlignLayout.Client;
  Result.Name := 'DataGridObjectInspector';
  Result.MemberVisibilities := [TMemberVisibility.mvPublished, TMemberVisibility.mvPublic];
  Result.ObjectMemberKinds := [TObjectMemberKind.omkProperty];
  Result.OnCurrentChange := ObjInsCurrentChanged;
end;

procedure TLaObjectTreeViewForm.bTestClick(Sender: TObject);
var
  LastCurrentObj: TObject;
  NewCurrentRow: TDataGridRowEh;
begin
  if (DataGridEh1.CurrentRow <> nil) then
  begin
    LastCurrentObj := GetRefObjectFromRow(DataGridEh1.CurrentRow);
    FillLaObjectTreeView;

    if LastCurrentObj <> nil then
    begin
      NewCurrentRow :=
        DataGridEh1.VisibleRows.FindRow(
          function (ARow: TDataGridRowEh): Boolean
          var
            Obj: TObject;
          begin
            Obj := GetRefObjectFromRow(ARow);
            Result := (Obj = LastCurrentObj);
          end
          );
       if NewCurrentRow <> nil then
        DataGridEh1.CurrentRow := NewCurrentRow;
    end;
  end;
end;

procedure TLaObjectTreeViewForm.btnShowStyleDataClick(Sender: TObject);
var
  Form: TLaObjectTreeViewForm;
begin
  Form := TLaObjectTreeViewForm.Create(Application);
  Form.Form := TStyleManager.ActiveStyle(nil);
  Form.Show;
end;

procedure TLaObjectTreeViewForm.bOnlyVisibleObjectsClick(Sender: TObject);
begin
  FOnlyVisibleObjects := not FOnlyVisibleObjects;
  if FOnlyVisibleObjects = True
    then bOnlyVisibleObjects.Text := 'Only Visible Objects = Yes'
    else bOnlyVisibleObjects.Text := 'Only Visible Objects = No';

  FillLaObjectTreeView;
end;

procedure TLaObjectTreeViewForm.cbPublishedChange(Sender: TObject);
begin
  if FControlsSetting then Exit;
  SetPropertiesFromControl;
end;

procedure TLaObjectTreeViewForm.cbVisibleClick(Sender: TObject);
begin
  if (SelectedComponent <> nil) and (SelectedComponent is TControl) then
    TControl(SelectedComponent).Visible := not cbVisible.IsChecked;
end;

procedure TLaObjectTreeViewForm.colTreeDisplayNameGetDataCellManager(
  Sender: TObject; Params: TDataGridGetDataCellManagerParamsEh);
begin
  Params.CellManager := TreeCellManager;
end;

procedure TLaObjectTreeViewForm.ChBoxHighlightFocusChange(Sender: TObject);
begin
  DataSource1DataChange(nil, nil);
end;

procedure TLaObjectTreeViewForm.DataSource1DataChange(Sender: TObject; Field: TField);
begin
  if {(FObjIns = nil) and }(FDataGridObjIns = nil) then Exit;

  SelectedComponent := GetRefObjectFromRow(DataGridEh1.CurrentRow);

  if (SelectedComponent <> nil) and (SelectedComponent is TControl) then
  begin
    cbVisible.IsChecked := TControl(SelectedComponent).Visible;
    cbVisible.Enabled := True;
  end else
  begin
    cbVisible.Enabled := False;
  end;
end;

procedure TLaObjectTreeViewForm.EdPropNameChangeTracking(Sender: TObject);
begin
  PropNameFilter := EdPropName.Text;
  FindPromptText.Visible := (EdPropName.Text = '');
end;

procedure TLaObjectTreeViewForm.ElementsGridDataCellGetStyleParams(Sender: TObject;
  Params: TDataGridDataCellStyleParamsEh);
//var
//  Control: TControl;
//  FormItem: TObject;
begin
  if Params.Row = nil then Exit;

//  FormItem := GetRefObjectFromRow(Params.Row);
//  if FormItem is TControl then
//  begin
//    Control := TControl(FormItem);
//    if ControlBranchIsVisible(Control) = False then
//      Params.FontColor := TAlphaColorRec.Gray;
//  end;
end;

function TLaObjectTreeViewForm.GetMemberVisibilities: TMemberVisibilities;
begin
  Result := FDataGridObjIns.MemberVisibilities;
end;

procedure TLaObjectTreeViewForm.SetMemberVisibilities(const Value: TMemberVisibilities);
begin
  FDataGridObjIns.MemberVisibilities := Value;
end;

function TLaObjectTreeViewForm.GetTypeKinds: TTypeKinds;
begin
  Result := FDataGridObjIns.TypeKinds;
end;

procedure TLaObjectTreeViewForm.SetTypeKinds(const Value: TTypeKinds);
begin
  FDataGridObjIns.TypeKinds := Value;
end;

function TLaObjectTreeViewForm.GetObjectMemberKinds: TObjectMemberKinds;
begin
  Result := FDataGridObjIns.ObjectMemberKinds;
end;

procedure TLaObjectTreeViewForm.SetObjectMemberKind(const Value: TObjectMemberKinds);
begin
  FDataGridObjIns.ObjectMemberKinds := Value;
end;

function TLaObjectTreeViewForm.GetPropNameFilter: String;
begin
  Result := FDataGridObjIns.PropNameFilter;
end;

procedure TLaObjectTreeViewForm.SetPropNameFilter(const Value: String);
begin
  FDataGridObjIns.PropNameFilter := Value;
end;

procedure TLaObjectTreeViewForm.ObjInsCurrentChanged(Sender: TObject;
  Params: TDataGridEventParamsEh);
begin
  if FObjInsInternalUpdating = False then
    SaveObjInsCurrentPath();
end;

procedure TLaObjectTreeViewForm.SaveObjInsCurrentPath();
var
  PropTreeNode: TPropTreeNodeEh;
  CurrentPathAsList: TList<string>;
  DataGridCrack: TDataGridEhCrack;
  RollRowIndex: Integer;
  RollRowPos: Int64;
//  TopToCurRowGap: Int64;
begin
  FObjInsTopToCurRowGap := 0;
  CurrentPathAsList := TList<string>.Create;
  if (FDataGridObjIns.CurrentDataRow <> nil) and
     (FDataGridObjIns.CurrentDataRow.SourceObjectItem <> nil) then
  begin
    PropTreeNode := FDataGridObjIns.CurrentDataRow.SourceObjectItem as TPropTreeNodeEh;
    CurrentPathAsList.Add(PropTreeNode.PropName);
    if PropTreeNode.Expanded
      then CurrentPathAsList.Add('Expanded')
      else CurrentPathAsList.Add('');
//    FObjInsCurrentPath := PropTreeNode.PropName;
  end else
  begin
//    FObjInsCurrentPath := '';
  end;
  FObjInsCurrentPath := CurrentPathAsList.ToArray;
  CurrentPathAsList.Free;

  DataGridCrack := TDataGridEhCrack(FDataGridObjIns.DataGrid);
  RollRowIndex := DataGridCrack.CurRowIndex - DataGridCrack.FixedRowCount;
  if (RollRowIndex >= 0) and (RollRowIndex < DataGridCrack.VertAxis.RollCelCount)
    then RollRowPos := DataGridCrack.VertAxis.RollLocCelPosArr[RollRowIndex]
    else Exit;
  FObjInsTopToCurRowGap := RollRowPos - DataGridCrack.VertAxis.RollStartVisPos;
end;

procedure TLaObjectTreeViewForm.RestoreObjInsCurrentPath;
var
  I: Integer;
  PropTreeNode: TPropTreeNodeEh;
  DataGridCrack: TDataGridEhCrack;
  RollRowIndex: Integer;
  NewRollPos: Integer;
  RollRowPos: Integer;
begin
  if Length(FObjInsCurrentPath) = 0 then Exit;
  FObjInsInternalUpdating := True;
  try
    for I := 0 to FDataGridObjIns.DataGrid.VisibleRows.Count - 1 do
    begin
      if FDataGridObjIns.DataGrid.VisibleRows[I] is TDataGridDataRowEh then
      begin
        PropTreeNode := TDataGridDataRowEh(FDataGridObjIns.DataGrid.VisibleRows[I]).SourceObjectItem as TPropTreeNodeEh;
        if PropTreeNode.PropName = FObjInsCurrentPath[0] then
        begin
          FDataGridObjIns.DataGrid.CurrentRow := FDataGridObjIns.DataGrid.VisibleRows[I];
          if FObjInsCurrentPath[1] = 'Expanded' then
            PropTreeNode.Expand;

          DataGridCrack := TDataGridEhCrack(FDataGridObjIns.DataGrid);
          RollRowIndex := DataGridCrack.CurRowIndex - DataGridCrack.FixedRowCount;
          if (RollRowIndex >= 0) and (RollRowIndex < DataGridCrack.VertAxis.RollCelCount)
            then RollRowPos := DataGridCrack.VertAxis.RollLocCelPosArr[RollRowIndex]
            else Exit;
          NewRollPos := RollRowPos - FObjInsTopToCurRowGap;
          DataGridCrack.SafeSetTopRollPos(NewRollPos);

          Exit;
        end;
      end;
    end;
  finally
    FObjInsInternalUpdating := False;
  end;
end;

procedure TLaObjectTreeViewForm.Button1Click(Sender: TObject);
begin
  if PreviewTimer.Enabled then
  begin
    LayoutPreview.Height := 40;
    FPreviewObject := nil;
    DoPreviewCurrentObject();
    PreviewTimer.Enabled := False;
  end else
  begin
    LayoutPreview.Height := 120;
    DoPreviewCurrentObject();
    PreviewTimer.Enabled := True;
  end;
end;

procedure TLaObjectTreeViewForm.DoPreviewCurrentObject();
var
  Rectangle: TRectangle;
  Glyph: TGlyph;
begin
  PreviewRectangle.ClipChildren := True;
  PreviewRectangle.DeleteChildren();
  if FPreviewObject <> nil then
  begin
    if FPreviewObject is TBrushObject then
    begin
      Rectangle := TRectangle.Create(Self);
      Rectangle.Size.Size := TSizeF.Create(100, 100);
      Rectangle.Align := TAlignLayout.Center;
      Rectangle.Fill.Assign(TBrushObject(FPreviewObject).Brush);
      PreviewRectangle.AddObject(Rectangle);
    end
    else if FPreviewObject is TColorObject then
    begin
      Rectangle := TRectangle.Create(Self);
      Rectangle.Size.Size := TSizeF.Create(100, 100);
      Rectangle.Align := TAlignLayout.Center;
      Rectangle.Fill.Color := TColorObject(FPreviewObject).Color;
      Rectangle.Fill.Kind := TBrushKind.Solid;
      PreviewRectangle.AddObject(Rectangle);
    end
    else if FPreviewObject is TGlyph then
    begin
      Glyph := TFmxObject(FPreviewObject).Clone(Self) as TGlyph;
      Glyph.Align := TAlignLayout.Center;
      Glyph.Visible := True;
      PreviewRectangle.AddObject(Glyph);
    end
    else if FPreviewObject is TImage then
    begin
      var Image := TFmxObject(FPreviewObject).Clone(Self) as TImage;
      Image.Align := TAlignLayout.Center;
      Image.Visible := True;
      PreviewRectangle.AddObject(Image);
    end
    else if FPreviewObject is TShape then
    begin
      //var Shape := TFmxObject(FPreviewObject).Clone(Self) as TShape;
      var Shape := CloneControlWithoutChildren(FPreviewObject as TShape, Self) as TShape;

      Shape.Align := TAlignLayout.Center;
      Shape.Visible := True;
      PreviewRectangle.AddObject(Shape);
    end
    else if FPreviewObject is TCustomStyleObject then
    begin
      var StyleObject := TFmxObject(FPreviewObject).Clone(Self) as TCustomStyleObject;
      StyleObject.Align := TAlignLayout.Center;
      StyleObject.Visible := True;
      if StyleObject.Width > PreviewRectangle.Width  then
        StyleObject.Width := PreviewRectangle.Width - 8;
      if StyleObject.Height > PreviewRectangle.Height then
        StyleObject.Height := PreviewRectangle.Height - 8;
      PreviewRectangle.AddObject(StyleObject);
    end
    else
    begin
      var Text: String;
      if FPreviewObject = nil then
        Text := '<Nothing selected>'
      else
        Text := 'Preview of ' + FPreviewObject.ClassName + ' is not supported';

      var TextObj: TText := TText.Create(Self);
      TextObj.AutoSize := True;
      TextObj.Align := TAlignLayout.Center;
      TextObj.TextSettings.WordWrap := False;
      TextObj.Visible := True;
      TextObj.Text := Text;
      PreviewRectangle.AddObject(TextObj);
    end;

  end;
  PreviewRectangle.Repaint;
end;

procedure TLaObjectTreeViewForm.PreviewTimerTimer(Sender: TObject);
begin
  if PreviewObject <> SelectedComponent then
  begin
    FPreviewObject := SelectedComponent;
    DoPreviewCurrentObject();
  end;
end;

procedure TLaObjectTreeViewForm.FreeNotification(AObject: TObject);
begin
  inherited FreeNotification(AObject);
  if AObject = SelectedComponent then
    SelectedComponent := nil;
end;

{$ENDREGION  'TLaObjectTreeViewForm'}

{$REGION 'TFormItemNodeEh'}

{ TFormItemNodeEh }

constructor TFormItemNodeEh.Create;
begin
  inherited Create;
  Expanded := True;
end;

destructor TFormItemNodeEh.Destroy;
begin
  inherited Destroy;
end;

procedure TFormItemNodeEh.Collapse;
begin
  Expanded := False;
  ExpandedStateChanged();
end;

procedure TFormItemNodeEh.Expand;
begin
  Expanded := True;
  ExpandedStateChanged();
end;

procedure TFormItemNodeEh.ExpandedStateChanged;
begin
  Owner.ExpandedStateChanged(Self);
end;

function TFormItemNodeEh.GetFormItemTypeName: String;
begin
  if FormItem <> nil then
    Result := FormItem.ClassName
  else
    Result := '(nil)';
end;

function TFormItemNodeEh.GetItem(const Index: Integer): TFormItemNodeEh;
begin
  Result := TFormItemNodeEh(inherited Items[Index]);
end;

function TFormItemNodeEh.GetNodeOwner: TFormItemsTreeListEh;
begin
  Result := TFormItemsTreeListEh(inherited TreeList);
end;

function TFormItemNodeEh.GetNodeParent: TFormItemNodeEh;
begin
  Result := TFormItemNodeEh(inherited Parent);
end;

function TFormItemNodeEh.GetVisibleItem(const Index: Integer): TFormItemNodeEh;
begin
  Result := TFormItemNodeEh(inherited VisibleItems[Index])
end;

procedure TFormItemNodeEh.RefreshValue;
begin

end;

procedure TFormItemNodeEh.SetFormItem(const Value: TObject);
begin
  if FFormItem <> Value then
  begin
    FFormItem := Value;
    if FFormItem <> nil then
      TFormItemsTreeListEh(TreeList).AddFormItemFreeNotify(FFormItem);
  end;
end;

procedure TFormItemNodeEh.SetNodeParent(const Value: TFormItemNodeEh);
begin
  inherited Parent := Value;
end;

{$ENDREGION 'TFormItemNodeEh'}

{$REGION 'TFormItemsTreeListEh'}

{ TFormItemsTreeListEh }

constructor TFormItemsTreeListEh.Create(ItemClass: TPropTreeNodeClassEh);
begin
  inherited Create(ItemClass);
  FVisibleExpandedItems := TObjectListEh.Create;
  FDestructionMonitor := TDestructionMonitorEh.Create(Self);
end;

destructor TFormItemsTreeListEh.Destroy;
begin
  FreeAndNil(FVisibleExpandedItems);
  ClearDestructionMonitor();
  FreeAndNil(FDestructionMonitor);
  inherited Destroy;
end;

procedure TFormItemsTreeListEh.ClearDestructionMonitor();
var
  CurNode: TFormItemNodeEh;
begin
  CurNode := TFormItemNodeEh(GetFirst);
  while CurNode <> nil do
  begin
    if (CurNode.FormItem <> nil) and (CurNode.FormItem is TFmxObject) then
      TFmxObject(CurNode.FormItem).RemoveFreeNotify(FDestructionMonitor);
    CurNode := TFormItemNodeEh(GetNext(CurNode));
  end;
end;

procedure TFormItemsTreeListEh.TreeChanged(Node: TBaseTreeNodeEh; Operation: TTreeListNotificationEh; OldIndex: Integer;
  OldParentNode: TBaseTreeNodeEh);
begin
  inherited TreeChanged(Node, Operation, OldIndex, OldParentNode);
end;

procedure TFormItemsTreeListEh.AddFormItemFreeNotify(AObject: TObject);
begin
  if (AObject <> nil) and (AObject is TFmxObject) then
    TFmxObject(AObject).AddFreeNotify(FDestructionMonitor);
end;

procedure TFormItemsTreeListEh.HandleTreeItemFreed(AObject: TObject);
var
  CurNode: TFormItemNodeEh;
begin
  CurNode := TFormItemNodeEh(GetFirst);
  while CurNode <> nil do
  begin
    if (CurNode.FormItem = AObject) then
    begin
      CurNode.FormItem := nil;
      NodePropsChanged(CurNode);
    end;
    CurNode := TFormItemNodeEh(GetNext(CurNode));
  end;
end;

procedure TFormItemsTreeListEh.ExpandedStateChanged(PropTreeNode: TFormItemNodeEh);
begin
  if Assigned(OnTreeNodeExpandedStateChanged) then
    OnTreeNodeExpandedStateChanged(Self, PropTreeNode);
end;

procedure TFormItemsTreeListEh.NodePropsChanged(PropTreeNode: TFormItemNodeEh);
begin
  if Assigned(OnNodePropsChanged) then
    OnNodePropsChanged(Self, PropTreeNode);
end;

procedure TFormItemsTreeListEh.BuildVisibleItems;
var
  CurNode: TBaseTreeNodeEh;
begin
  FVisibleExpandedItems.Clear;
  CurNode := GetFirstVisible;
  while CurNode <> nil do
  begin
    FVisibleExpandedItems.Add(CurNode);
    CurNode := GetNextVisible(CurNode, True);
  end;

  FVisibleItemsObsolete := False;
end;

function TFormItemsTreeListEh.GetVisibleCount: Integer;
begin
  if FVisibleItemsObsolete then
    BuildVisibleItems;
  Result := FVisibleExpandedItems.Count;
end;

function TFormItemsTreeListEh.GetVisibleExpandedItem(const Index: Integer): TFormItemNodeEh;
begin
  if FVisibleItemsObsolete then
    BuildVisibleItems;
  if (Index < 0) or (Index > FVisibleExpandedItems.Count-1) then
  begin
    Result := nil;
    Exit;
  end;
  Result := TFormItemNodeEh(FVisibleExpandedItems.Items[Index]);
end;

function TFormItemsTreeListEh.GetVisibleExpandedItems: TObjectList;
begin
  if FVisibleItemsObsolete then
    BuildVisibleItems;
  Result := FVisibleExpandedItems;
end;

procedure TFormItemsTreeListEh.VisibleItemsBecomeObsolete;
begin
  FVisibleItemsObsolete := True;
end;

procedure TFormItemsTreeListEh.VisibleListChanged;
begin
  if Assigned(OnVisibleListChanged) then
    OnVisibleListChanged(Self);
end;

function TFormItemsTreeListEh.GetRoot: TFormItemNodeEh;
begin
  Result := TFormItemNodeEh(inherited Root);
end;

procedure TFormItemsTreeListEh.RefreshAllValues;
var
  CurNode: TBaseTreeNodeEh;
begin
  CurNode := GetFirst;
  while CurNode <> nil do
  begin
    TFormItemNodeEh(CurNode).RefreshValue;
    CurNode := GetNext(CurNode);
  end;
end;

{$ENDREGION  'TFormItemsTreeListEh'}

{$REGION 'TDataGridTreeTextDataCellManagerEh'}

{ TDataGridTreeTextDataCellManagerEh }

function TDataGridTreeTextDataCellManagerEh.CreateGridCell(
  ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh;
begin
  Result := TDataGridTreeTextDataCellEh.Create(ACellHolder);
end;

procedure TDataGridTreeTextDataCellManagerEh.DefaultInitCellContent(
  Params: TBaseGridInitCellContentParamsEh);
begin
  inherited DefaultInitCellContent(Params);
  if Params.CellContent is TLaPropNameCellContentEh then
    InitTreeContentState(Params);
end;

procedure TDataGridTreeTextDataCellManagerEh.InitTreeContentState(Params: TBaseGridInitCellContentParamsEh);
var
  FormItemNode: TFormItemNodeEh;

  TreeContent: TLaPropNameCellContentEh;
  DataGridParams: TDataAxisInitCellContentParamsEh;
  FmxFormItem: TFmxObject;
begin
  if Params.CellContent is TLaPropNameCellContentEh then
    TreeContent := TLaPropNameCellContentEh(Params.CellContent)
  else
    TreeContent := nil;

  if Params is TDataAxisInitCellContentParamsEh then
    DataGridParams := TDataAxisInitCellContentParamsEh(Params)
  else
    DataGridParams := nil;

  if (DataGridParams <> nil) and
     (TreeContent <> nil) and
     (DataGridParams.FieldBar <> nil) and
     (DataGridParams.ListItemBar <> nil) then
  begin
//    TreeContent.BlackBlock.Text := 'TreeContent.BlackBlock';
//    TreeContent.PurpleBlock.Text := 'TreeContent.PurpleBlock';
    FormItemNode := TFormItemNodeEh(DataGridParams.ListItemBar.SourceObjectItem);

    if FormItemNode.FormItem <> nil then
    begin
      if FormItemNode.FormItem is TFmxObject then
        FmxFormItem := TFmxObject(FormItemNode.FormItem)
      else
        FmxFormItem := nil;

      if (FmxFormItem <> nil) and (FmxFormItem.Name <> '') then
        TreeContent.BlackBlock.Text := FmxFormItem.Name + ': '
      else
        TreeContent.BlackBlock.Text := '';

      TreeContent.PurpleBlock.Text := FormItemNode.FormItem.ClassName;

      if FmxFormItem.StyleName <> '' then
        TreeContent.ExtraBlock.Text := ' (StyleName): ' + FmxFormItem.StyleName
      else
        TreeContent.ExtraBlock.Text := '';

      if FormItemNode.FormItem is TControl then
      begin
        if ControlBranchIsVisible(TControl(FormItemNode.FormItem)) = False then
           Params.CellContent.Opacity := 0.45
        else
           Params.CellContent.Opacity := 1;
      end;

    end else
    begin
      TreeContent.BlackBlock.Text := '<Object Destroyed>';
      TreeContent.PurpleBlock.Text := '';
      TreeContent.ExtraBlock.Text := '';
    end;
  end;
end;

{$ENDREGION 'TDataGridTreeTextDataCellManagerEh'}

{$REGION 'TDataGridTreeTextDataCellEh'}

{ TDataGridTreeTextDataCellEh }

function TDataGridTreeTextDataCellEh.CreateDefaultCellContentControls(
  AParentObject: TLaObjectEh): TLaObjectEh;
begin
  FMasterContent := TLaPropNameCellContentEh.CreateWith(Self, AParentObject);
  FMasterContent.Name := 'MasterContent';
  Result := FMasterContent;
end;

{$ENDREGION 'TDataGridTreeTextDataCellEh'}

{$REGION 'TLaPropNameCellContentEh'}

{ TLaPropNameCellContentEh }

constructor TLaPropNameCellContentEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CreateLaPropNameControls();
end;

destructor TLaPropNameCellContentEh.Destroy;
begin

  inherited Destroy;
end;

procedure TLaPropNameCellContentEh.CreateLaPropNameControls();
begin
  with TLaStackPanelEh.CreateWith(Self, Self) do
  begin
    Orientation := TLaOrientationEh.Horizontal;
    Margins.Rect := TRect.Create(4, 2, 2, 2);

    with TLaTextBlockEh.CreateWith(RefSelf, RefSelf) do
    begin
      Text := 'BlackBlock';
      Name := 'BlackBlock';
      FBlackBlock := TLaTextBlockEh(RefSelf);
    end;

    with TLaTextBlockEh.CreateWith(RefSelf, RefSelf) do
    begin
      FontColor := $FF8A529F; 
      if TStyleManagerEh.Current.StyleColorMode = TStyleColorModeEh.Dark then
        //FontColor := ConvertColorForDarkBackground(FontColor);
        FontColor := AdjustColorForDarkTheme(FontColor);
      Text := 'PurpleBlock';
      Name := 'PurpleBlock';
      FPurpleBlock := TLaTextBlockEh(RefSelf);
    end;

    with TLaTextBlockEh.CreateWith(RefSelf, RefSelf) do
    begin
      FontColor := TAlphaColorRec.Black;
      Font.Size := Font.Size - 1;
      Text := 'ExtraBlock';
      Name := 'ExtraBlock';
      FExtraBlock := TLaTextBlockEh(RefSelf);
    end;
  end;
end;

{$ENDREGION 'TLaPropNameCellContentEh'}

{$REGION 'TDestructionMonitorEh'}

{ TDestructionMonitorEh }

constructor TDestructionMonitorEh.Create(AOwner: TFormItemsTreeListEh);
begin
  inherited Create(nil);
  FTreeList := AOwner;
end;

destructor TDestructionMonitorEh.Destroy;
begin
  inherited Destroy;
end;

procedure TDestructionMonitorEh.FreeNotification(AObject: TObject);
begin
  inherited FreeNotification(AObject);
  FTreeList.HandleTreeItemFreed(AObject);
end;

{$ENDREGION 'TDestructionMonitorEh'}

end.
