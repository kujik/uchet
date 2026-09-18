unit SolutionFrame.TreeViewWithTreeListEh;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  EhLibFmx.Api, EhLibRtl.Api,
  MemTreeEh, Contnrs,
  EhLibFmx.DataAxisGrid.FieldBars, EhLibFmx.DataGrid.Columns, EhLibFmx.DataGrids, EhLibFmx.ToolControls,
  EhLibFmx.Grids, EhLibFmx.DataAxisGrids, EhLibFmx.CustomDataGrids, FMX.Controls.Presentation;

type
  TMyTreeListEh = class;
  TMyNodeEh = class;

  TfrTreeViewWithTreeListEh = class(TFrame)
    Panel1: TPanel;
    DataGridEh1: TDataGridEh;
    DataGridEh1NODNAMEColumn1: TDataGridStringColumnEh;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure DataGridEh1GetDataTreeViewAreaParams(Sender: TObject;
      Params: TDataGridDataTreeViewAreaParamsEh);
    procedure DataGridEh1SetDataTreeSignState(Sender: TObject; Params: TDataGridSetDataTreeSignStateParamsEh);
  private
    procedure RefreshVisibleList;
  public
    TreeList: TMyTreeListEh;
    ListTableLink: TListTableLinkEh;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure FillTreeView;
  end;

{ TMyTreeListEh }

  TMyTreeListEh = class(TTreeListEh)
  private
    FVisibleExpandedItems: TObjectList;
    FVisibleItemsObsolete: Boolean;

    function GetVisibleExpandedItems: TObjectList;
    procedure BuildVisibleItems;

  protected
    procedure TreeChanged(Node: TBaseTreeNodeEh; Operation: TTreeListNotificationEh; OldIndex: Integer; OldParentNode: TBaseTreeNodeEh); override;
    procedure ExpandedChanged(Node: TBaseTreeNodeEh); override;

    procedure VisibleItemsBecomeObsolete;

  public
    constructor Create(); reintroduce;
    destructor Destroy; override;

    function AddChild(AParent: TBaseTreeNodeEh; NODNAME, Prop2, Prop3: String; IsExpanded: Boolean): TMyNodeEh;

    property VisibleExpandedItems: TObjectList read GetVisibleExpandedItems;
  end;

{ TMyNodeEh }

  TMyNodeEh = class(TBaseTreeNodeEh)
  private
    FNODNAME: String;
    FProp2: String;
    FProp3: String;
    function GetRefSelf: TMyNodeEh;
  protected
  public
    constructor Create; override;
    destructor Destroy; override;

    property RefSelf: TMyNodeEh read GetRefSelf;
  published
    property NODNAME: String read FNODNAME write FNODNAME;
    property Prop2: String read FProp2 write FProp2;
    property Prop3: String read FProp3 write FProp3;
  end;

implementation

{$R *.fmx}

{ TMyNodeEh }

constructor TMyNodeEh.Create;
begin
  inherited;
end;

destructor TMyNodeEh.Destroy;
begin
  inherited;
end;

function TMyNodeEh.GetRefSelf: TMyNodeEh;
begin
  Result := Self;
end;

{ TMyTreeListEh }

constructor TMyTreeListEh.Create;
begin
  inherited Create(TMyNodeEh);
  FVisibleExpandedItems := TObjectListEh.Create;
end;

destructor TMyTreeListEh.Destroy;
begin
  FreeAndNil(FVisibleExpandedItems);
  inherited Destroy;
end;

procedure TMyTreeListEh.ExpandedChanged(Node: TBaseTreeNodeEh);
begin
  inherited ExpandedChanged(Node);
  VisibleItemsBecomeObsolete;
end;

function TMyTreeListEh.AddChild(AParent: TBaseTreeNodeEh; NODNAME, Prop2, Prop3: String; IsExpanded: Boolean): TMyNodeEh;
begin
  Result := CreateNodeApart('', nil) as TMyNodeEh;

  Result.NODNAME := NODNAME;
  Result.Prop2 := Prop2;
  Result.Prop3 := Prop3;
  Result.Expanded := IsExpanded;

  AddNode(Result, AParent, TNodeAttachModeEh.naAddChildEh, False);
end;

function TMyTreeListEh.GetVisibleExpandedItems: TObjectList;
begin
  if FVisibleItemsObsolete then
    BuildVisibleItems;
  Result := FVisibleExpandedItems;
end;

procedure TMyTreeListEh.TreeChanged(Node: TBaseTreeNodeEh; Operation: TTreeListNotificationEh;
  OldIndex: Integer; OldParentNode: TBaseTreeNodeEh);
begin
  inherited TreeChanged(Node, Operation, OldIndex, OldParentNode);
  VisibleItemsBecomeObsolete;
end;

procedure TMyTreeListEh.VisibleItemsBecomeObsolete;
begin
  FVisibleItemsObsolete := True;
end;

procedure TMyTreeListEh.BuildVisibleItems;
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

{ TfrTreeViewWithTreeListEh }

constructor TfrTreeViewWithTreeListEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Button1Click(nil);
  Button1.Visible := False;
end;

destructor TfrTreeViewWithTreeListEh.Destroy;
begin
  FreeAndNil(TreeList);
  inherited;
end;

procedure TfrTreeViewWithTreeListEh.Button1Click(Sender: TObject);
begin
  ListTableLink := TListTableLinkEh.Create(Self);
  TreeList := TMyTreeListEh.Create();

  FillTreeView;

  ListTableLink.SetList(TreeList.VisibleExpandedItems, TypeInfo(TMyNodeEh), ['NODNAME', 'Prop2', 'Prop3']);
  DataGridEh1.DataSource := ListTableLink;
end;

procedure TfrTreeViewWithTreeListEh.FillTreeView;
begin
  TreeList.Clear;

  with TreeList.AddChild(nil, 'ROOT1', 'Val1', 'Val1', True) do
  begin
    Self.TreeList.AddChild(RefSelf, 'CHILD1', 'Val11', 'Val13', True);
    with Self.TreeList.AddChild(RefSelf, 'CHILD2', 'Val11', 'Val13', True) do
    begin
      Self.TreeList.AddChild(RefSelf, 'SUBCH1', 'Val111', 'Val113', True);
      Self.TreeList.AddChild(RefSelf, 'SUBCH2', 'Val111', 'Val113', True);
      Self.TreeList.AddChild(RefSelf, 'SUBCH3', 'Val111', 'Val113', True);
      Self.TreeList.AddChild(RefSelf, 'SUBCH4', 'Val111', 'Val113', True);
    end;
    Self.TreeList.AddChild(RefSelf, 'CHILD3', 'Val11', 'Val13', True);
    Self.TreeList.AddChild(RefSelf, 'CHILD10', 'Val11', 'Val13', True);
    Self.TreeList.AddChild(RefSelf, 'CHILD11', 'Val11', 'Val13', True);
    Self.TreeList.AddChild(RefSelf, 'CHILD12', 'Val11', 'Val13', True);
  end;

  with TreeList.AddChild(nil, 'ROOT2', 'Val2', 'Val2', False) do
  begin
    Self.TreeList.AddChild(RefSelf, 'CHILD4', 'Val21', 'Val23', True);
    Self.TreeList.AddChild(RefSelf, 'CHILD5', 'Val21', 'Val23', True);
    Self.TreeList.AddChild(RefSelf, 'CHILD6', 'Val21', 'Val23', True);
  end;

  with TreeList.AddChild(nil, 'ROOT3', 'Val3', 'Val3', False) do
  begin
    Self.TreeList.AddChild(RefSelf, 'CHILD7', 'Val31', 'Val33', True);
    Self.TreeList.AddChild(RefSelf, 'CHILD8', 'Val31', 'Val33', True);
    Self.TreeList.AddChild(RefSelf, 'CHILD9', 'Val31', 'Val33', True);
    Self.TreeList.AddChild(RefSelf, 'CHILD16', 'Val31', 'Val33', True);
  end;
end;

procedure TfrTreeViewWithTreeListEh.DataGridEh1GetDataTreeViewAreaParams(Sender: TObject;
  Params: TDataGridDataTreeViewAreaParamsEh);
var
  ItemNode: TMyNodeEh;
begin
  if Params.Column.VisibleIndex > 0 then Exit;
  if Params.Row = nil then Exit;

  ItemNode := TMyNodeEh(Params.Row.SourceObjectItem);
  Params.TreeAreaVisible := True;
  Params.SignVisible := ItemNode.HasChildren;
  if ItemNode.Expanded = True
    then Params.SignState := TTreeSignStateEh.Expanded
    else Params.SignState := TTreeSignStateEh.Collapsed;
  Params.Level := ItemNode.Level - 1;
end;

procedure TfrTreeViewWithTreeListEh.DataGridEh1SetDataTreeSignState(Sender: TObject;
  Params: TDataGridSetDataTreeSignStateParamsEh);
var
  PropTreeNode: TMyNodeEh;
  FormItemNodeParent: TMyNodeEh;
  I: Integer;
  IsExpanded: Boolean;
begin
  if Params.Row = nil then Exit;

  PropTreeNode := TMyNodeEh(Params.Row.SourceObjectItem);

  if ssCtrl in Params.ShiftState then
  begin
    IsExpanded := PropTreeNode.Expanded;
    if PropTreeNode.Parent <> nil then
    begin
      FormItemNodeParent := PropTreeNode.Parent as TMyNodeEh;
      for I := 0 to FormItemNodeParent.VisibleItems.Count - 1 do
      begin
        if IsExpanded = True
          then TMyNodeEh(FormItemNodeParent.VisibleItems[I]).Expanded := False
          else TMyNodeEh(FormItemNodeParent.VisibleItems[I]).Expanded := True
      end;
    end;
  end else
  begin
    if PropTreeNode.Expanded
      then PropTreeNode.Expanded := False
      else PropTreeNode.Expanded := True;
  end;

  RefreshVisibleList;
end;

procedure TfrTreeViewWithTreeListEh.RefreshVisibleList;
var
  LastPropTreeNode: TMyNodeEh;
  LastVertRollPos: Int64;
begin
  if DataGridEh1.CurrentRow <> nil then
    LastPropTreeNode := TMyNodeEh(DataGridEh1.CurrentRow.SourceObjectItem)
  else
    LastPropTreeNode := nil;

  LastVertRollPos := DataGridEh1.VertAxis.RollStartVisPos;
  TreeList.BuildVisibleItems;
  ListTableLink.SetList(TreeList.VisibleExpandedItems, TypeInfo(TMyNodeEh), ['NODNAME', 'Prop2', 'Prop3']);

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

end.
