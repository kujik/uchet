{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{            EhLibFmx.DataGrid.ComplexTitles            } 
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataGrid.ComplexTitles;

interface

{$SCOPEDENUMS ON}

{$REGION 'uses'}
uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, System.Types,
  FMX.Graphics, System.UITypes, System.Math, FMX.Forms, System.Contnrs,
  FMX.Platform, Data.DB, System.Variants, System.UIConsts,
  System.Generics.Collections,
  EhLibUtils,
  DBUtilsEh,
  MemTreeEh,
  EhLibFmx.Utils,
  EhLibFmx.ToolControls,
  EhLibFmx.Grid.ToolControls,

  EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.DataAxisGrids,
  EhLibFmx.DataAxisGrid.ToolControls,

  EhLibFmx.DataGrid.Footers,
  EhLibFmx.DataGrid.ToolControls,

  EhLibFmx.Grid.CellManagers,
  EhLibFmx.LaHostVirtualPanels,
  EhLibFmx.LaControls,
  EhLibFmx.LaGridPanels,
  EhLibFmx.LaPanels,
  EhLibFmx.LaObjects,
  EhLibFmx.Grids;
{$ENDREGION 'uses'}

type
  TDataGridComplexTitleTreeNodeEh = class;
  TDataGridComplexTitleTreeListEh = class;
  TDataGridSuperTitleEh = class;
  TDataGridSuperTitleCellManagerEh = class;
  TDataGridSuperTitleCellHolderEh = class;

  TDataGridCompoundTitleTreeNodeTypeEh = (RootNode, SuperTitleNode, ColumnNode);

{ TDataGridCompoundTitleTreeNodeEh }

  TDataGridComplexTitleTreeNodeEh = class(TBaseTreeNodeEh)
  private
    FChildrenHeight: Integer;
    FColumn: TFieldBarEh;
    FDisplayRect: TRect;
    FNodeType: TDataGridCompoundTitleTreeNodeTypeEh;
    FSuperTitle: TDataGridSuperTitleEh;

    function GetCount: Integer;
    function GetItem(const Index: Integer): TDataGridComplexTitleTreeNodeEh;
    function GetNodeObject: TComponent;
    function GetParent: TDataGridComplexTitleTreeNodeEh;
    function GetText: String;
    function GetTreeList: TDataGridComplexTitleTreeListEh;
    function GetVisibleItem(const Index: Integer): TDataGridComplexTitleTreeNodeEh;

  protected
    function GetGrid: TCustomDataAxisGridEh;
    procedure ParentChanged; override;
    procedure RegetNewParentState;

  public
    constructor Create(ASuperTitle: TDataGridSuperTitleEh); reintroduce; overload;
    constructor Create(AColumn: TFieldBarEh); reintroduce; overload;
    destructor Destroy; override;

    function CalcCellHolderRectHeight(ARectWidth: Integer): Integer;
    function CalcCellRectHeight(ARectWidth: Integer): Integer;

    procedure MoveChild(Child: TComponent; AIndex: Integer = -1);
    procedure SetDisplayRectVertMetric(ATop, AHeight: Integer);
    procedure SetItemsOrder(ChildNodes: TArray<TDataGridComplexTitleTreeNodeEh>);

    property ChildrenHeight: Integer read FChildrenHeight;
    property Column: TFieldBarEh read FColumn;
    property Count: Integer read GetCount;
    property DisplayRect: TRect read FDisplayRect write FDisplayRect;
    property Index;
    property Items[const Index: Integer]: TDataGridComplexTitleTreeNodeEh read GetItem;
    property Level;
    property NodeObject: TComponent read GetNodeObject;
    property NodeType: TDataGridCompoundTitleTreeNodeTypeEh read FNodeType write FNodeType;
    property Parent: TDataGridComplexTitleTreeNodeEh read GetParent;
    property SuperTitle: TDataGridSuperTitleEh read FSuperTitle;
    property Text: String read GetText;
    property TreeList: TDataGridComplexTitleTreeListEh read GetTreeList;
    property VisibleCount;
    property VisibleIndex;
    property VisibleItem[const Index: Integer]: TDataGridComplexTitleTreeNodeEh read GetVisibleItem;
  end;

  TDataGridComplexTitleNodeClass = class of TDataGridComplexTitleTreeNodeEh;

  TForNodeMethod = procedure(Node: TDataGridComplexTitleTreeNodeEh) of object;
  TForNodeProcedure = reference to procedure(Node: TDataGridComplexTitleTreeNodeEh);

{ TDataGridCompoundTitleTreeListEh }

  TDataGridComplexTitleTreeListEh = class(TTreeListEh)
  private
    FGridTitle: TAxisGridTitleBarEh;
    FTitleSize: TSize;
    FUpdateCount: Integer;

    function GetRootNode: TDataGridComplexTitleTreeNodeEh;

  protected
    FCellManager: TDataGridSuperTitleCellManagerEh;

    procedure CheckTreeConsistent;
    procedure ExtractNode(Node: TDataGridComplexTitleTreeNodeEh);
    procedure TreeChanged(Node: TBaseTreeNodeEh; Operation: TTreeListNotificationEh; OldIndex: Integer; OldParentNode: TBaseTreeNodeEh); override;
    procedure UpdateVisibleNodes();

  public
    constructor Create(AGridTitle: TAxisGridTitleBarEh; ItemClass: TTreeNodeClassEh);
    destructor Destroy; override;

    function CalcGetSize(): TSize;
    function CreateColumnTitleNode(AColumn: TFieldBarEh): TDataGridComplexTitleTreeNodeEh;
    function CreateNodeApart(): TDataGridComplexTitleTreeNodeEh;
    function CreateSuperTitleNode(ASuperTitle: TDataGridSuperTitleEh): TDataGridComplexTitleTreeNodeEh;
    function IsUpdating: Boolean;

    procedure AddColumn(Parent: TDataGridSuperTitleEh; ChildColumn: TFieldBarEh; Index: Integer = -1);
    procedure AddSuperTitle(Parent: TDataGridSuperTitleEh; ChildSuperTitle: TDataGridSuperTitleEh; Index: Integer = -1);
    procedure ExtractSuperTitle(SuperTitle: TDataGridSuperTitleEh);
    procedure MoveColumn(Parent: TDataGridSuperTitleEh; ChildColumn: TFieldBarEh; Index: Integer = -1);
    procedure MoveColumnObject(Parent: TComponent; Child: TComponent; Index: Integer = -1);
    procedure MoveSuperTitle(Parent: TDataGridSuperTitleEh; ChildSuperTitle: TDataGridSuperTitleEh; Index: Integer = -1);

    procedure BeginUpdate;
    procedure BuildTreeFromColumns;
    procedure CalcTitleSize;
    procedure DestructTree;
    procedure EndUpdate;
    procedure EnsureRevokeCellInPanel(Panel: TDataGridVirtualPanelEh; const FullTitleRect, ViewPortRect: TRectF);
    procedure ForAllNodes(NodeMethod: TForNodeProcedure);
    procedure GetColumnsList(AList: TList<TFieldBarEh>);
    procedure InsertNode(Node: TBaseTreeNodeEh); overload;
    procedure InsertNode(Node: TBaseTreeNodeEh; Index: Integer); overload;
    procedure MoveVisibleNode(ANode, AMoveToParent: TDataGridComplexTitleTreeNodeEh; AMoveToIndex: Integer);
    procedure UpdateCellsLayout(Panel: TDataGridVirtualPanelEh; const FullTitleRect, ViewPortRect: TRectF);
    procedure UpdateCellsProps(Panel: TDataGridVirtualPanelEh);

    property CellManager: TDataGridSuperTitleCellManagerEh read FCellManager;
    property RootNode: TDataGridComplexTitleTreeNodeEh read GetRootNode;
    property TitleSize: TSize read FTitleSize;
  end;

{ TDataGridSuperTitleEh }

  TDataGridSuperTitleEh = class(TComponent, IFreeNotification)
  private
    FFill: TBrush;
    FFillStored: Boolean;
    FFont: TFont;
    FFontColor: TAlphaColor;
    FFontColorStored: Boolean;
    FFontStored: Boolean;
    FGridCell: TDataGridSuperTitleCellHolderEh;
    FHeightAutoExpand: Boolean;
    FHeightAutoExpandStored: Boolean;
    FHorzAlign: TTextAlign;
    FHorzAlignStored: Boolean;
    FPadding: TBounds;
    FPaddingStored: Boolean;
    FText: String;
    FTextStored: Boolean;
    FVertAlign: TTextAlign;
    FVertAlignStored: Boolean;
    FWordWrap: Boolean;
    FWordWrapStored: Boolean;

    function GetFontColor: TAlphaColor;
    function GetHeightAutoExpand: Boolean;
    function GetHorzAlign: TTextAlign;
    function GetPadding: TBounds;
    function GetRefSelf: TDataGridSuperTitleEh;
    function GetText: string;
    function GetVertAlign: TTextAlign;
    function GetWidth: Integer;
    function GetWordWrap: Boolean;
    function IsFillStored: Boolean;
    function IsFontColorStored: Boolean;
    function IsFontStored: Boolean;
    function IsHeightAutoExpandStored: Boolean;
    function IsHorzAlignStored: Boolean;
    function IsPaddingStored: Boolean;
    function IsTextStored: Boolean;
    function IsVertAlignStored: Boolean;
    function IsWordWrapStored: Boolean;
    procedure FillChanged(Sender: TObject);
    procedure FontChanged(Sender: TObject);
    procedure PaddingChangedHandler(Sender: TObject);
    procedure SetFill(const Value: TBrush);
    procedure SetFillStored(const Value: Boolean);
    procedure SetFont(const Value: TFont);
    procedure SetFontColor(const Value: TAlphaColor);
    procedure SetFontColorStored(const Value: Boolean);
    procedure SetFontStored(const Value: Boolean);
    procedure SetHeightAutoExpand(const Value: Boolean);
    procedure SetHeightAutoExpandStored(const Value: Boolean);
    procedure SetHorzAlign(const Value: TTextAlign);
    procedure SetHorzAlignStored(const Value: Boolean);
    procedure SetPadding(const Value: TBounds);
    procedure SetPaddingStored(const Value: Boolean);
    procedure SetText(const Value: String);
    procedure SetTextStored(const Value: Boolean);
    procedure SetVertAlign(const Value: TTextAlign);
    procedure SetVertAlignStored(const Value: Boolean);
    procedure SetWordWrap(const Value: Boolean);
    procedure SetWordWrapStored(const Value: Boolean);
    procedure SetGridCell(const Value: TDataGridSuperTitleCellHolderEh);

  protected
    FGrid: TCustomDataAxisGridEh;
    FComplexTitleNode: TDataGridComplexTitleTreeNodeEh;

    function GetChildParent: TComponent; override;

    function DefaultFill: TBrush; virtual;
    function DefaultFont: TFont; virtual;
    function DefaultFontColor(): TAlphaColor; virtual;
    function DefaultHeightAutoExpand(): Boolean; virtual;
    function DefaultHorzAlign(): TTextAlign; virtual;
    function DefaultPadding(): TBounds; virtual;
    function DefaultText(): string; virtual;
    function DefaultVertAlign(): TTextAlign; virtual;
    function DefaultWordWrap(): Boolean; virtual;
    function GetComplexTitleNode: TDataGridComplexTitleTreeNodeEh;

    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    procedure SetParentComponent(Value: TComponent); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    { IFreeNotification }
    procedure FreeNotification(AObject: TObject); virtual;

    procedure AddChildComponent(const Element: TComponent); virtual;
    procedure GridChanged(); virtual;
    procedure InitCell(GridCell: TGridBaseCellHolderEh); virtual;
    procedure NotifyChanges;
    procedure RefreshDefaultFill();
    procedure RefreshDefaultFont();
    procedure RefreshDefaultPadding();
    procedure RefreshDefaults(); virtual;
    procedure SetGrid(AGrid: TCustomDataAxisGridEh);

  public
    constructor Create(AOwner: TComponent); overload; override;
    constructor CreateWithTitleTreeNode(AOwner: TComponent; AParent: TDataGridComplexTitleTreeNodeEh); overload;
    constructor CreateWithSuperTitle(AOwner: TComponent; AParent: TDataGridSuperTitleEh); overload;
    constructor CreateWith(AOwner: TComponent; AParent: TComponent); overload;
    destructor Destroy; override;

    function CalcCellHeight(ACanvas: TCanvas; ACellWidth: Integer): Integer;
    function GetParentComponent: TComponent; override;
    function HasParent: Boolean; override;

    procedure AddChild(Child: TComponent; AIndex: Integer = -1);
    procedure InsertNode(ANode: TBaseTreeNodeEh); overload;
    procedure InsertNode(ANode: TBaseTreeNodeEh; Index: Integer); overload;
    procedure MoveChild(Child: TComponent; AIndex: Integer = -1);

    property ComplexTitleNode: TDataGridComplexTitleTreeNodeEh read GetComplexTitleNode;
    property Grid: TCustomDataAxisGridEh read FGrid;
    property GridCell: TDataGridSuperTitleCellHolderEh read FGridCell write SetGridCell;
    property RefSelf: TDataGridSuperTitleEh read GetRefSelf;
    property Width: Integer read GetWidth;

  published

    property Fill: TBrush read FFill write SetFill stored IsFillStored;
    property FillStored: Boolean read FFillStored write SetFillStored default False;
    property Font: TFont read FFont write SetFont stored IsFontStored;
    property FontColor: TAlphaColor read GetFontColor write SetFontColor stored IsFontColorStored;
    property FontColorStored: Boolean read FFontColorStored write SetFontColorStored default False;
    property FontStored: Boolean read FFontStored write SetFontStored default False;
    property HeightAutoExpand: Boolean read GetHeightAutoExpand write SetHeightAutoExpand stored IsHeightAutoExpandStored;
    property HeightAutoExpandStored: Boolean read IsHeightAutoExpandStored write SetHeightAutoExpandStored default False;
    property HorzAlign: TTextAlign read GetHorzAlign write SetHorzAlign stored IsHorzAlignStored;
    property HorzAlignStored: Boolean read IsHorzAlignStored write SetHorzAlignStored default False;
    property Padding: TBounds read GetPadding write SetPadding stored IsPaddingStored;
    property PaddingStored: Boolean read FPaddingStored write SetPaddingStored default False;
    property Text: string read GetText write SetText stored IsTextStored;
    property TextStored: Boolean read IsTextStored write SetTextStored default False;
    property VertAlign: TTextAlign read GetVertAlign write SetVertAlign stored IsVertAlignStored;
    property VertAlignStored: Boolean read IsVertAlignStored write SetVertAlignStored default False;
    property WordWrap: Boolean read GetWordWrap write SetWordWrap stored IsWordWrapStored;
    property WordWrapStored: Boolean read IsWordWrapStored write SetWordWrapStored default False;
  end;

{ TDataGridComplexTitleCellManagerEh }

  TDataGridComplexTitleCellManagerEh = class(TBaseGridCellManagerEh)
  private
  protected
  public
  end;

{ TDataGridSuperTitleCellManagerEh }

  TDataGridSuperTitleCellManagerEh = class(TBaseGridCellManagerEh)
  private
  protected
  public
    function CreateCellHolder(): TVPBaseCellHolderEh; override;
    function CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh; override;
    function GetBackgroundStyle(AParams: TBaseGridInitCellParamsEh): TControl; override;
    function CreateDefaultCellContent(ACell: TGridBaseCellEh; AParent: TLaObjectEh): TLaObjectEh; override;

    procedure DefaultInitCell(Params: TBaseGridInitCellParamsEh); override;
  end;

{ TDataGridSuperTitleCellHolderEh }

  TDataGridSuperTitleCellHolderEh = class(TGridBaseCellHolderEh)
  private
    FMouseDownPos: TPoint;
    FTitleTreeNode: TDataGridComplexTitleTreeNodeEh;

  protected
    procedure CreateControls(AParent: TLaObjectEh); override;
    procedure ProcessMouseDown(Params: TControlMouseButtonParamsEh); override;
    procedure ProcessMouseMove(Params: TControlMouseParamsEh); override;

  public
    constructor Create(AOwner: TComponent; ACellManager: TVPBaseCellManagerEh); override;
    destructor Destroy; override;

    property TitleTreeNode: TDataGridComplexTitleTreeNodeEh read FTitleTreeNode;
  end;

{ TDataGridSuperTitleCellEh }

  TDataGridSuperTitleCellEh = class(TGridBaseCellEh)
  private
    FText: TLaTextBlockEh;

    function GetText: String;
    procedure SetText(const Value: String);
    function GetTitleTreeNode: TDataGridComplexTitleTreeNodeEh;
  protected
    function CreateCellClientControls(AParent: TLaObjectEh): TLaObjectEh; override;

  public
    constructor Create(ACellHolder: TGridBaseCellHolderEh);
    destructor Destroy; override;

    property Text: String read GetText write SetText;
    property TextControl: TLaTextBlockEh read FText;

    property TitleTreeNode: TDataGridComplexTitleTreeNodeEh read GetTitleTreeNode;
  end;

implementation

uses
  EhLibFmx.CustomDataGrids,
  EhLibFmx.DataGrid.Columns,
  EhLibFmx.DataGrid.Titles;

type
  TCustomDataGridEhCrack = class(TCustomDataGridEh);
  TDataGridTitleBarEhCrack = class(TDataGridTitleBarEh);
  TColumnEhCrack = class(TDataGridBaseColumnEh);
  TColumnTitleEhCrack = class(TColumnTitleEh);
  TBaseTreeNodeEhCrack = class(TBaseTreeNodeEh);

{$REGION 'TDataGridComplexTitleTreeNodeEh'}

{ TDataGridCompoundTitleTreeNodeEh }

constructor TDataGridComplexTitleTreeNodeEh.Create(ASuperTitle: TDataGridSuperTitleEh);
begin
  inherited Create;
  FNodeType := TDataGridCompoundTitleTreeNodeTypeEh.SuperTitleNode;
  FSuperTitle := ASuperTitle;
  FColumn := nil;
end;

constructor TDataGridComplexTitleTreeNodeEh.Create(AColumn: TFieldBarEh);
begin
  inherited Create;
  FNodeType := TDataGridCompoundTitleTreeNodeTypeEh.ColumnNode;
  FSuperTitle := nil;
  FColumn := AColumn;
end;

destructor TDataGridComplexTitleTreeNodeEh.Destroy;
begin
  inherited Destroy;
  if FColumn <> nil then
  begin
  end;
end;

function TDataGridComplexTitleTreeNodeEh.CalcCellRectHeight(ARectWidth: Integer): Integer;
var
  ColumnTitle: TColumnTitleEh;
  AColumn: TDataGridBaseColumnEh;
begin
  AColumn := TDataGridBaseColumnEh(Column);
  if NodeType = TDataGridCompoundTitleTreeNodeTypeEh.ColumnNode then
  begin
    ColumnTitle := (AColumn).Title;
    Result := ColumnTitle.CalcCellHeight(AColumn.Grid.Canvas, Round(ARectWidth));
  end else if NodeType = TDataGridCompoundTitleTreeNodeTypeEh.SuperTitleNode then
  begin
    Result := SuperTitle.CalcCellHeight(SuperTitle.FGrid.Canvas, Round(ARectWidth));
  end else
  begin
    Result := 0;
  end;
end;

function TDataGridComplexTitleTreeNodeEh.CalcCellHolderRectHeight(ARectWidth: Integer): Integer;
var
  Grid: TCustomDataGridEhCrack;
begin
  if NodeType = TDataGridCompoundTitleTreeNodeTypeEh.RootNode then
  begin
    Result := 0;
  end else
  begin
    Result := CalcCellRectHeight(ARectWidth);
    Grid := TCustomDataGridEhCrack(GetGrid());
    if Grid.GridLineParams.HorzLinesVisible then
      Result := Result + 1;
  end;
end;

function TDataGridComplexTitleTreeNodeEh.GetCount: Integer;
begin
  Result := inherited Count;
end;

function TDataGridComplexTitleTreeNodeEh.GetItem(const Index: Integer): TDataGridComplexTitleTreeNodeEh;
begin
  Result := TDataGridComplexTitleTreeNodeEh(inherited Items[Index]);
end;

function TDataGridComplexTitleTreeNodeEh.GetVisibleItem(const Index: Integer): TDataGridComplexTitleTreeNodeEh;
begin
  Result := TDataGridComplexTitleTreeNodeEh(inherited VisibleItem[Index]);
end;

function TDataGridComplexTitleTreeNodeEh.GetParent: TDataGridComplexTitleTreeNodeEh;
begin
  Result := TDataGridComplexTitleTreeNodeEh(inherited Parent);
end;

procedure TDataGridComplexTitleTreeNodeEh.SetDisplayRectVertMetric(ATop, AHeight: Integer);
begin
  FDisplayRect.Top := ATop;
  FDisplayRect.Height := AHeight - ChildrenHeight;
end;

procedure TDataGridComplexTitleTreeNodeEh.SetItemsOrder(ChildNodes: TArray<TDataGridComplexTitleTreeNodeEh>);
var
  I: Integer;
  BaseNodes: TArray<TBaseTreeNodeEh>;
  Grid: TCustomDataGridEhCrack;
begin
  SetLength(BaseNodes, Length(ChildNodes));
  for I := 0 to Length(ChildNodes) - 1 do
    BaseNodes[I] := ChildNodes[I];
  inherited SetItemsOrder(BaseNodes);

  Grid := TCustomDataGridEhCrack(GetGrid);
  Grid.FullFieldBarListChanged();
end;

procedure TDataGridComplexTitleTreeNodeEh.ParentChanged;
begin
  inherited ParentChanged;
  RegetNewParentState;
end;

procedure TDataGridComplexTitleTreeNodeEh.RegetNewParentState;
begin
  if NodeType = TDataGridCompoundTitleTreeNodeTypeEh.SuperTitleNode then
  begin
    FSuperTitle.SetGrid(GetGrid);
  end;
end;

function TDataGridComplexTitleTreeNodeEh.GetGrid: TCustomDataAxisGridEh;
var
  TreeList: TDataGridComplexTitleTreeListEh;
begin
  TreeList := TDataGridComplexTitleTreeListEh(GetTreeList);
  if TreeList <> nil then
    Result := TCustomDataAxisGridEh(TreeList.FGridTitle.Grid)
  else
    Result := nil;
end;

function TDataGridComplexTitleTreeNodeEh.GetText: String;
var
  AColumn: TDataGridBaseColumnEh;
begin
  AColumn := TDataGridBaseColumnEh(Column);
  if NodeType = TDataGridCompoundTitleTreeNodeTypeEh.ColumnNode then
  begin
    Result := AColumn.Title.Text;
  end else if NodeType = TDataGridCompoundTitleTreeNodeTypeEh.SuperTitleNode then
  begin
    Result := SuperTitle.Text;
  end else
  begin
    Result := '<Root>';
  end;
end;

function TDataGridComplexTitleTreeNodeEh.GetTreeList: TDataGridComplexTitleTreeListEh;
begin
  Result := TDataGridComplexTitleTreeListEh(inherited TreeList);
end;

procedure TDataGridComplexTitleTreeNodeEh.MoveChild(Child: TComponent; AIndex: Integer);
var
  TreeList: TDataGridComplexTitleTreeListEh;
  ChildNode: TDataGridComplexTitleTreeNodeEh;
begin
  TreeList := TDataGridComplexTitleTreeListEh(GetTreeList);
  if Child is TDataGridBaseColumnEh then
  begin
    ChildNode := TDataGridBaseColumnEh(Child).Title.ComplexTitleNode;
  end
  else if Child is TDataGridSuperTitleEh then
  begin
    ChildNode := TDataGridComplexTitleTreeNodeEh(TDataGridSuperTitleEh(Child).ComplexTitleNode);
  end else
  begin
    raise Exception.Create('TDataGridSuperTitleEh.AddChild: Child type should be T ColumnEh or TDataGridSuperTitleEh');
  end;

  if ChildNode.Parent = nil  then
    TreeList.InsertNode(ChildNode, AIndex)
  else
    TreeList.MoveTo(ChildNode, Self, TNodeAttachModeEh.naAddChildEh,  True);
end;

function TDataGridComplexTitleTreeNodeEh.GetNodeObject: TComponent;
begin
  if NodeType = TDataGridCompoundTitleTreeNodeTypeEh.ColumnNode then
  begin
    Result := Column;
  end else if NodeType = TDataGridCompoundTitleTreeNodeTypeEh.SuperTitleNode then
  begin
    Result := SuperTitle;
  end else
  begin
    Result := nil;
  end;
end;

{$ENDREGION 'TDataGridComplexTitleTreeNodeEh'}

{$REGION 'TDataGridCompoundTitleTreeListEh'}

{ TDataGridCompoundTitleTreeListEh }

constructor TDataGridComplexTitleTreeListEh.Create(AGridTitle: TAxisGridTitleBarEh; ItemClass: TTreeNodeClassEh);
begin
  inherited Create(ItemClass);
  FGridTitle := AGridTitle;
  TDataGridComplexTitleTreeNodeEh(RootNode).NodeType := TDataGridCompoundTitleTreeNodeTypeEh.RootNode;
  FCellManager := TDataGridSuperTitleCellManagerEh.Create(Self);
end;

destructor TDataGridComplexTitleTreeListEh.Destroy;
begin
  inherited Destroy;
end;

procedure TDataGridComplexTitleTreeListEh.ExtractNode(Node: TDataGridComplexTitleTreeNodeEh);
begin
  inherited ExtractNode(Node, True);
end;

procedure TDataGridComplexTitleTreeListEh.ExtractSuperTitle(SuperTitle: TDataGridSuperTitleEh);
var
  Node: TDataGridComplexTitleTreeNodeEh;
  I: Integer;
  ChildNode: TDataGridComplexTitleTreeNodeEh;
begin
  if (SuperTitle.FComplexTitleNode = nil) then
    raise Exception.Create('SuperTitle + "' + SuperTitle.Text + '" is not in the Tree');
  if (SuperTitle.FComplexTitleNode.TreeList <> Self) then
    raise Exception.Create('SuperTitle + "' + SuperTitle.Text + '" is not in this Tree');

  Node := SuperTitle.FComplexTitleNode;
  for I := Node.Count - 1 downto 0 do
  begin
    ChildNode := Node.Items[I];
    MoveTo(ChildNode, Node.Parent, TNodeAttachModeEh.naAddChildEh, False);
  end;

  ExtractNode(Node);
end;

procedure TDataGridComplexTitleTreeListEh.DestructTree;

  procedure DestructNode(Node: TDataGridComplexTitleTreeNodeEh);
  var
    I: Integer;
    ChildNode: TDataGridComplexTitleTreeNodeEh;
  begin
    for I := Node.Count - 1  downto 0 do
    begin
      ChildNode := TDataGridComplexTitleTreeNodeEh(Node.Items[I]);
      DestructNode(ChildNode);
    end;

    if (Node.NodeType = TDataGridCompoundTitleTreeNodeTypeEh.SuperTitleNode) then
    begin
      ExtractNode(Node);
      Node.FSuperTitle.Free;
    end
    else if (Node.NodeType = TDataGridCompoundTitleTreeNodeTypeEh.ColumnNode) then
    begin
      TColumnTitleEhCrack(TColumnEhCrack(Node.Column).Title).FComplexTitleNode := nil;
      Node.FColumn := nil;
      DeleteNode(Node, False);
    end;
  end;

begin
  BeginUpdate();
  try
    DestructNode(RootNode);
  finally
    EndUpdate();
  end;
end;

function TDataGridComplexTitleTreeListEh.GetRootNode: TDataGridComplexTitleTreeNodeEh;
begin
  Result := TDataGridComplexTitleTreeNodeEh(inherited Root);
end;

function TDataGridComplexTitleTreeListEh.CreateNodeApart: TDataGridComplexTitleTreeNodeEh;
begin
  Result := TDataGridComplexTitleTreeNodeEh(inherited CreateNodeApart('', nil));
end;

function TDataGridComplexTitleTreeListEh.CreateColumnTitleNode(AColumn: TFieldBarEh): TDataGridComplexTitleTreeNodeEh;
begin
  Result := CreateNodeApart();
  Result.NodeType := TDataGridCompoundTitleTreeNodeTypeEh.ColumnNode;
  Result.FColumn := AColumn;
end;

function TDataGridComplexTitleTreeListEh.CreateSuperTitleNode(ASuperTitle: TDataGridSuperTitleEh): TDataGridComplexTitleTreeNodeEh;
begin
  Result := CreateNodeApart();
  Result.NodeType := TDataGridCompoundTitleTreeNodeTypeEh.SuperTitleNode;
  Result.FSuperTitle := ASuperTitle;
end;

function TDataGridComplexTitleTreeListEh.CalcGetSize: TSize;

  function CalcGetNodeWidths(StartPos: Integer; Node: TDataGridComplexTitleTreeNodeEh): Integer;
  var
    I: Integer;
    ChildNode: TDataGridComplexTitleTreeNodeEh;
    ChildNodeWidth: Integer;
    ChildStartPos: Integer;
  begin
    Result := 0;
    if (Node.NodeType = TDataGridCompoundTitleTreeNodeTypeEh.RootNode) or
       (Node.NodeType = TDataGridCompoundTitleTreeNodeTypeEh.SuperTitleNode) then
    begin
      for I := 0 to Node.VisibleCount - 1 do
      begin
        ChildNode := TDataGridComplexTitleTreeNodeEh(Node.VisibleItem[I]);
        ChildStartPos := Result + StartPos;
        ChildNodeWidth := CalcGetNodeWidths(ChildStartPos, ChildNode);
        Result := Result + ChildNodeWidth;
      end;
      Node.FDisplayRect.Left := StartPos;
      Node.FDisplayRect.Width := Result;
    end else
    begin
      Result := Result + TDataGridBaseColumnEh(Node.Column).ActualWidth;
      Node.FDisplayRect.Left := StartPos;
      Node.FDisplayRect.Width := Result;
    end;
  end;

  function CalcGetNodeHeights(Node: TDataGridComplexTitleTreeNodeEh): Integer;
  var
    I: Integer;
    ChildNode: TDataGridComplexTitleTreeNodeEh;
    CellHeight: Integer;
    MaxChildHeight: Integer;
    ChildHeight: Integer;
  begin
    CellHeight := Node.CalcCellHolderRectHeight(Node.DisplayRect.Width);
    MaxChildHeight := 0;

    if (Node.NodeType = TDataGridCompoundTitleTreeNodeTypeEh.RootNode) or
       (Node.NodeType = TDataGridCompoundTitleTreeNodeTypeEh.SuperTitleNode) then
    begin

      for I := 0 to Node.VisibleCount - 1 do
      begin
        ChildNode := TDataGridComplexTitleTreeNodeEh(Node.VisibleItem[I]);
        ChildHeight := CalcGetNodeHeights(ChildNode);
        if ChildHeight > MaxChildHeight then
          MaxChildHeight := ChildHeight;
      end;

      Node.FChildrenHeight := MaxChildHeight;
      for I := 0 to Node.VisibleCount - 1 do
      begin
        ChildNode := TDataGridComplexTitleTreeNodeEh(Node.VisibleItem[I]);
        ChildNode.FDisplayRect.Top := 0;
        ChildNode.FDisplayRect.Height := MaxChildHeight - ChildNode.ChildrenHeight;
      end;

    end else
    begin
      Node.FChildrenHeight := 0;
    end;

    if Node.NodeType = TDataGridCompoundTitleTreeNodeTypeEh.RootNode then
    begin
    end;

    Result := MaxChildHeight + CellHeight;
  end;

  procedure SetNodeTops(StartPos: Integer; Node: TDataGridComplexTitleTreeNodeEh);
  var
    I: Integer;
    ChildNode: TDataGridComplexTitleTreeNodeEh;
  begin
    Node.FDisplayRect.SetLocation(Node.FDisplayRect.Left, StartPos);

    for I := 0 to Node.VisibleCount - 1 do
    begin
      ChildNode := TDataGridComplexTitleTreeNodeEh(Node.VisibleItem[I]);
      SetNodeTops(StartPos + Node.DisplayRect.Height, ChildNode);
    end;
  end;

begin
  Result.Width := CalcGetNodeWidths(0, RootNode);
  Result.Height := CalcGetNodeHeights(RootNode);
  SetNodeTops(0, RootNode);
end;

procedure TDataGridComplexTitleTreeListEh.CalcTitleSize;
begin
  if (FGridTitle.Grid.Canvas = nil) then Exit;
  FTitleSize := CalcGetSize();
end;

procedure TDataGridComplexTitleTreeListEh.BuildTreeFromColumns;
var
  Grid: TCustomDataGridEhCrack;
  I: Integer;
  Column: TDataGridBaseColumnEh;
begin
  Grid := TCustomDataGridEhCrack(FGridTitle.Grid);

  BeginUpdate();
  try
    for I := 0 to Grid.Columns.Count - 1 do
    begin
      Column := Grid.Columns[I];
      AddNode(Column.Title.ComplexTitleNode, RootNode, naAddChildEh, True);
    end;
  finally
    EndUpdate();
  end;
end;

procedure TDataGridComplexTitleTreeListEh.BeginUpdate;
begin
  FUpdateCount := FUpdateCount + 1;
end;

procedure TDataGridComplexTitleTreeListEh.EndUpdate;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGridTitle.Grid);

  Assert(FUpdateCount >= 0, 'TDataGridComplexTitleTreeListEh.EndUpdate; FUpdateCount >= 0 condition failed.');
  FUpdateCount := FUpdateCount - 1;
  if FUpdateCount = 0 then
  begin
    CheckTreeConsistent;
    Grid.LayoutChanged;
    Grid.FullFieldBarListChanged;
  end;
end;

function TDataGridComplexTitleTreeListEh.IsUpdating: Boolean;
begin
  Result := (FUpdateCount > 0);
end;

procedure TDataGridComplexTitleTreeListEh.TreeChanged(Node: TBaseTreeNodeEh;
  Operation: TTreeListNotificationEh; OldIndex: Integer;
  OldParentNode: TBaseTreeNodeEh);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGridTitle.Grid);

  inherited TreeChanged(Node, Operation, OldIndex, OldParentNode);

  if (csLoading in Grid.ComponentState) or
     (IsUpdating = True)
  then
    DoNothing()
  else
    Grid.FullFieldBarListChanged;
end;

procedure TDataGridComplexTitleTreeListEh.CheckTreeConsistent;
begin

end;

procedure TDataGridComplexTitleTreeListEh.InsertNode(Node: TBaseTreeNodeEh);
begin
  InsertNode(Node, RootNode.Count);
end;

procedure TDataGridComplexTitleTreeListEh.MoveVisibleNode(ANode, AMoveToParent: TDataGridComplexTitleTreeNodeEh;
  AMoveToIndex: Integer);
var
  AToNode: TDataGridComplexTitleTreeNodeEh;
begin
  if AMoveToIndex = 0 then
    MoveTo(ANode, AMoveToParent, TNodeAttachModeEh.naAddChildFirstEh, True)
  else if AMoveToIndex >= AMoveToParent.VisibleCount then
    MoveTo(ANode, AMoveToParent, TNodeAttachModeEh.naAddChildEh, True)
  else
  begin
    AToNode := AMoveToParent.VisibleItem[AMoveToIndex];
    if ANode <> AToNode then
      MoveTo(ANode, AToNode, TNodeAttachModeEh.naInsertEh, True);
  end;
end;

procedure TDataGridComplexTitleTreeListEh.InsertNode(Node: TBaseTreeNodeEh; Index: Integer);
begin
  AddNode(Node, RootNode, naAddChildEh, True);
end;

procedure TDataGridComplexTitleTreeListEh.EnsureRevokeCellInPanel(Panel: TDataGridVirtualPanelEh; const FullTitleRect, ViewPortRect: TRectF);
var
  Grid: TCustomDataGridEhCrack;

  procedure EnsureSuperTitleCells(Node: TDataGridComplexTitleTreeNodeEh);
  var
    ChildNode: TDataGridComplexTitleTreeNodeEh;
    I: Integer;
    AGridCell: TDataGridSuperTitleCellHolderEh;
  begin
    if (Node.NodeType = TDataGridCompoundTitleTreeNodeTypeEh.RootNode) or
       (Node.NodeType = TDataGridCompoundTitleTreeNodeTypeEh.SuperTitleNode) then
    begin
      if Node.NodeType = TDataGridCompoundTitleTreeNodeTypeEh.SuperTitleNode then
      begin
        AGridCell := Node.SuperTitle.GridCell;
        if Node.SuperTitle.GridCell = nil then
        begin
          Node.SuperTitle.GridCell := Grid.Title.ComplexTitleTree.CellManager.CreateCellHolder() as TDataGridSuperTitleCellHolderEh;
          AGridCell := Node.SuperTitle.GridCell;
          Panel.AddObject(AGridCell);
        end;

        AGridCell.Visible := True;
      end;

      for I := 0 to Node.VisibleCount - 1 do
      begin
        ChildNode := TDataGridComplexTitleTreeNodeEh(Node.VisibleItem[I]);
        EnsureSuperTitleCells(ChildNode);
      end;
    end else
    begin
    end;
  end;

begin
  Grid := TCustomDataGridEhCrack(FGridTitle.Grid);
  EnsureSuperTitleCells(RootNode);
end;

procedure TDataGridComplexTitleTreeListEh.ForAllNodes(NodeMethod: TForNodeProcedure);

  procedure DoForAllNodes(Node: TDataGridComplexTitleTreeNodeEh);
  var
    ChildNode: TDataGridComplexTitleTreeNodeEh;
    I: Integer;
  begin
    NodeMethod(Node);
    for I := 0 to Node.Count - 1 do
    begin
      ChildNode := TDataGridComplexTitleTreeNodeEh(Node.Items[I]);
      DoForAllNodes(ChildNode);
    end;
  end;

begin
  DoForAllNodes(RootNode);
end;

procedure TDataGridComplexTitleTreeListEh.UpdateCellsProps(Panel: TDataGridVirtualPanelEh);
begin
  ForAllNodes(
    procedure(Node: TDataGridComplexTitleTreeNodeEh)
    begin
      if Node.NodeType = TDataGridCompoundTitleTreeNodeTypeEh.SuperTitleNode then
      begin
        Node.SuperTitle.InitCell(Node.SuperTitle.GridCell);
      end;
    end
  );
end;

procedure TDataGridComplexTitleTreeListEh.UpdateVisibleNodes;
var
  Grid: TCustomDataGridEhCrack;
  I: Integer;
  Column: TDataGridBaseColumnEh;
begin
  Grid := TCustomDataGridEhCrack(FGridTitle.Grid);
  for I := 0 to Grid.Columns.Count - 1 do
  begin
    Column := Grid.Columns[I];
    if TColumnTitleEhCrack(Column.Title).FComplexTitleNode <> nil then
      TColumnTitleEhCrack(Column.Title).FComplexTitleNode.Visible := Column.Visible;
  end;
end;

procedure TDataGridComplexTitleTreeListEh.UpdateCellsLayout(Panel: TDataGridVirtualPanelEh;
  const FullTitleRect, ViewPortRect: TRectF);
var
  FullTitleRect1: TRectF;
begin
  FullTitleRect1 := FullTitleRect;

  ForAllNodes(
    procedure(Node: TDataGridComplexTitleTreeNodeEh)
    var
      VCellRect: TRectF;
      ACell: TGridBaseCellHolderEh;
    begin
      if Node.NodeType = TDataGridCompoundTitleTreeNodeTypeEh.SuperTitleNode then
      begin
        ACell := Node.SuperTitle.GridCell;
        VCellRect := Node.DisplayRect;
        OffsetRect(VCellRect, FullTitleRect1.Left, FullTitleRect1.Top);
        ACell.QueryLayout(VCellRect.Size, Panel.Canvas);
        ACell.PerformLayout(VCellRect, Panel.Canvas, TLaObjectEh.UnlimitedRect);
      end;
    end
  );
end;

procedure TDataGridComplexTitleTreeListEh.GetColumnsList(AList: TList<TFieldBarEh>);

  procedure AddChild(AParent: TDataGridComplexTitleTreeNodeEh);
  var
    AChild: TDataGridComplexTitleTreeNodeEh;
    I: Integer;
  begin
    for I := 0 to AParent.Count - 1 do
    begin
      AChild := AParent.Items[I];
      if AChild.NodeType = TDataGridCompoundTitleTreeNodeTypeEh.SuperTitleNode then
      begin
        AddChild(AChild);
      end else if AChild.NodeType = TDataGridCompoundTitleTreeNodeTypeEh.ColumnNode then
      begin
        AList.Add(AChild.Column);
      end;
    end;
  end;

begin
  AddChild(RootNode);
end;

procedure TDataGridComplexTitleTreeListEh.AddColumn(Parent: TDataGridSuperTitleEh; ChildColumn: TFieldBarEh; Index: Integer);
var
  Grid: TCustomDataGridEhCrack;
  AChildColumn: TColumnEhCrack;
  AParentNode: TDataGridComplexTitleTreeNodeEh;
begin
  Grid := TCustomDataGridEhCrack(FGridTitle.Grid);
  AChildColumn := TColumnEhCrack(ChildColumn);
  if Parent = nil  then
    AParentNode := RootNode
  else
    AParentNode := Parent.ComplexTitleNode;

  Grid.StaticColumns.Add(AChildColumn);
  AddNode(AChildColumn.Title.ComplexTitleNode, AParentNode, naAddChildEh, True);
end;

procedure TDataGridComplexTitleTreeListEh.AddSuperTitle(Parent, ChildSuperTitle: TDataGridSuperTitleEh; Index: Integer);
var
  AParentNode: TDataGridComplexTitleTreeNodeEh;
begin
  if Parent = nil  then
    AParentNode := RootNode
  else
    AParentNode := Parent.ComplexTitleNode;

  AddNode(ChildSuperTitle.ComplexTitleNode, AParentNode, naAddChildEh, True);
end;

procedure TDataGridComplexTitleTreeListEh.MoveColumn(Parent: TDataGridSuperTitleEh; ChildColumn: TFieldBarEh; Index: Integer);
var
  AParentNode: TDataGridComplexTitleTreeNodeEh;
  AChildBeforeNode: TDataGridComplexTitleTreeNodeEh;
  AChildColumn: TColumnEhCrack;
begin
  AChildColumn := TColumnEhCrack(ChildColumn);

  if Parent = nil  then
    AParentNode := RootNode
  else
    AParentNode := Parent.ComplexTitleNode;

  if (Index >= 0) and (Index < AParentNode.Count) then
  begin
    AChildBeforeNode := AParentNode.Items[Index];
    MoveTo(AChildBeforeNode, AParentNode, TNodeAttachModeEh.naInsertEh, True);
  end else
  begin
    MoveTo(AChildColumn.Title.ComplexTitleNode, AParentNode, TNodeAttachModeEh.naAddChildEh, True);
  end;
end;

procedure TDataGridComplexTitleTreeListEh.MoveSuperTitle(Parent, ChildSuperTitle: TDataGridSuperTitleEh; Index: Integer);
var
  AParentNode: TDataGridComplexTitleTreeNodeEh;
  AChildBeforeNode: TDataGridComplexTitleTreeNodeEh;
begin
  if Parent = nil  then
    AParentNode := RootNode
  else
    AParentNode := Parent.ComplexTitleNode;

  if (Index >= 0) and (Index < AParentNode.Count) then
  begin
    AChildBeforeNode := AParentNode.Items[Index];
    MoveTo(AChildBeforeNode, AParentNode, TNodeAttachModeEh.naInsertEh, True);
  end else
  begin
    MoveTo(ChildSuperTitle.ComplexTitleNode, AParentNode, TNodeAttachModeEh.naAddChildEh, True);
  end;
end;

/// <summary>
///   Move Child element to a new Parent with Index position
/// </summary>
procedure TDataGridComplexTitleTreeListEh.MoveColumnObject(Parent, Child: TComponent; Index: Integer);
var
  AParentNode: TDataGridComplexTitleTreeNodeEh;
  AChildNode: TDataGridComplexTitleTreeNodeEh;
  AChildBeforeNode: TDataGridComplexTitleTreeNodeEh;
begin
  if Parent is TDataGridBaseColumnEh then
    raise Exception.Create('TDataGridComplexTitleTreeListEh.MoveColumnObject: Parent object can''t have TDataGridBaseColumnEh type');

  if Parent is TCustomDataGridEh then
    AParentNode := RootNode
  else
    AParentNode := (Parent as TDataGridSuperTitleEh).ComplexTitleNode;

  if Child is TDataGridBaseColumnEh then
    AChildNode := TDataGridBaseColumnEh(Child).Title.ComplexTitleNode
  else if Child is TDataGridSuperTitleEh then
    AChildNode := TDataGridSuperTitleEh(Child).ComplexTitleNode
  else
    raise Exception.Create('TDataGridComplexTitleTreeListEh.MoveColumnObject: Child of ' + Child.ClassName + ' type is not supported');

  if (AChildNode.Parent = AParentNode) and
     (Index > AChildNode.Index)
  then
    Index := Index + 1;

  if (Index >= 0) and (Index < AParentNode.Count) then
  begin
    AChildBeforeNode := AParentNode.Items[Index];
    if AChildBeforeNode <> AChildNode then
      MoveTo(AChildNode, AChildBeforeNode, TNodeAttachModeEh.naInsertEh, True);
  end else
  begin
    MoveTo(AChildNode, AParentNode, TNodeAttachModeEh.naAddChildEh, True);
  end;
end;

{$ENDREGION  'TDataGridCompoundTitleTreeListEh'}

{$REGION 'TDataGridSuperTitleEh'}

{ TDataGridSuperTitleEh }

constructor TDataGridSuperTitleEh.Create(AOwner: TComponent);
begin
  CreateWithTitleTreeNode(AOwner, TDataGridComplexTitleTreeNodeEh(nil));
end;

constructor TDataGridSuperTitleEh.CreateWithTitleTreeNode(AOwner: TComponent; AParent: TDataGridComplexTitleTreeNodeEh);
var
  TreeListOwner: TDataGridComplexTitleTreeListEh;
begin
  inherited Create(AOwner);

  FFont := TFont.Create();
  FFont.Assign(DefaultFont());
  FFont.OnChanged := FontChanged;
  FFontStored := False;

  FFill := TBrush.Create(TBrushKind.None, TAlphaColorRec.Null);
  FFill.Assign(DefaultFill());
  FFill.OnChanged := FillChanged;
  FFillStored := False;

  FPadding := TBounds.Create(TRectF.Empty);
  FPadding.OnChange := PaddingChangedHandler;

  FComplexTitleNode := TDataGridComplexTitleTreeNodeEh.Create(Self);
  if (AParent <> nil) then
  begin
    TreeListOwner := TDataGridComplexTitleTreeListEh(AParent.GetTreeList);
    TreeListOwner.AddNode(ComplexTitleNode, AParent, naAddChildEh, True);
  end;
end;

constructor TDataGridSuperTitleEh.CreateWithSuperTitle(AOwner: TComponent; AParent: TDataGridSuperTitleEh);
begin
  CreateWithTitleTreeNode(AOwner, TDataGridComplexTitleTreeNodeEh(nil));
  AParent.AddChild(Self, -1);
end;

constructor TDataGridSuperTitleEh.CreateWith(AOwner: TComponent; AParent: TComponent);
var
  Grid: TCustomDataGridEhCrack;
begin
  if AParent is TDataGridSuperTitleEh then
  begin
    CreateWithSuperTitle(AOwner, TDataGridSuperTitleEh(AParent));
    SetGrid(TDataGridSuperTitleEh(AParent).Grid);
  end else if AParent is TDataGridTitleBarEh then
  begin
    Grid := TCustomDataGridEhCrack(TDataGridTitleBarEh(AParent).Grid);
    CreateWithTitleTreeNode(AOwner, Grid.Title.ComplexTitleTree.RootNode);
  end else
    raise Exception.Create('AParent of "' + AParent.ClassName + '" type is not supported.');
end;

destructor TDataGridSuperTitleEh.Destroy;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if Grid <> nil then
    Grid.Title.ComplexTitleTree.ExtractSuperTitle(Self);

  FreeAndNil(FComplexTitleNode);
  FreeAndNil(FPadding);
  FreeAndNil(FFont);
  FreeAndNil(FFill);
  FreeAndNil(FGridCell);
  inherited Destroy;
end;

function TDataGridSuperTitleEh.GetRefSelf: TDataGridSuperTitleEh;
begin
  Result := Self;
end;

procedure TDataGridSuperTitleEh.SetGrid(AGrid: TCustomDataAxisGridEh);
begin
  if FGrid <> AGrid then
  begin
    FGrid := AGrid as TCustomDataGridEh;
    GridChanged();
  end;
end;

procedure TDataGridSuperTitleEh.FreeNotification(AObject: TObject);
begin
  if AObject is TComponent then
    Notification(TComponent(AObject), opRemove);
end;

procedure TDataGridSuperTitleEh.SetGridCell(const Value: TDataGridSuperTitleCellHolderEh);
begin
  if (FGridCell <> Value) then
  begin
//    if FGridCell <> nil then
//      FGridCell.RemoveFreeNotify(Self);
    FGridCell := Value;
    if FGridCell <> nil then
      FGridCell.AddFreeNotify(Self);
  end;
end;

procedure TDataGridSuperTitleEh.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation =  opRemove then
  begin
    if AComponent = FGridCell then
      FGridCell := nil;
  end;
end;

procedure TDataGridSuperTitleEh.GridChanged();
begin
  RefreshDefaults();
end;

procedure TDataGridSuperTitleEh.RefreshDefaults();
begin
  RefreshDefaultPadding();
  RefreshDefaultFont();
  RefreshDefaultFill();
end;

function TDataGridSuperTitleEh.GetComplexTitleNode: TDataGridComplexTitleTreeNodeEh;
begin
  Result := FComplexTitleNode;
end;

function TDataGridSuperTitleEh.CalcCellHeight(ACanvas: TCanvas;
  ACellWidth: Integer): Integer;
var
  Height: Single;
  ARect: TRectF;
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  ACanvas.Font.Assign(Grid.Font);
  if WordWrap and HeightAutoExpand then
  begin
    ARect := TRectF.Empty;
    ARect.Width := Width - Padding.Left - Padding.Right;
    ARect.Height := 100000;
    ACanvas.MeasureText(ARect, Text, WordWrap, [], TTextAlign.Leading, TTextAlign.Leading);
    Height := ARect.Height + Padding.Top + Padding.Bottom;
  end else
  begin
    Height := ACanvas.TextHeight('Wg') + Padding.Top + Padding.Bottom;
  end;

  Result := Round(Height);
end;

procedure TDataGridSuperTitleEh.InsertNode(ANode: TBaseTreeNodeEh);
begin
  InsertNode(ANode, TDataGridComplexTitleTreeNodeEh(ComplexTitleNode).Count);
end;

procedure TDataGridSuperTitleEh.InsertNode(ANode: TBaseTreeNodeEh; Index: Integer);
var
  SelfNode: TDataGridComplexTitleTreeNodeEh;
  Node: TDataGridComplexTitleTreeNodeEh;
  TreeListOwner: TDataGridComplexTitleTreeListEh;
begin
  Node := TDataGridComplexTitleTreeNodeEh(ANode);
  SelfNode := TDataGridComplexTitleTreeNodeEh(ComplexTitleNode);
  TreeListOwner := TDataGridComplexTitleTreeListEh(SelfNode.GetTreeList);
  if (Node.Parent <> nil) then
    TreeListOwner.MoveTo(Node, ComplexTitleNode, naAddChildEh, True)
  else
    TreeListOwner.AddNode(Node, ComplexTitleNode, naAddChildEh, True);
end;

procedure TDataGridSuperTitleEh.AddChild(Child: TComponent; AIndex: Integer);
begin
  if Child is TDataGridBaseColumnEh then
  begin
    InsertNode(TDataGridBaseColumnEh(Child).Title.ComplexTitleNode, AIndex);
  end
  else if Child is TDataGridSuperTitleEh then
  begin
    InsertNode(TDataGridSuperTitleEh(Child).ComplexTitleNode, AIndex);
  end else
  begin
    raise Exception.Create('TDataGridSuperTitleEh.AddChild: Child type should be TDataGridColumnEh or TDataGridSuperTitleEh');
  end;
end;

procedure TDataGridSuperTitleEh.MoveChild(Child: TComponent; AIndex: Integer = -1);
begin
  if Child is TDataGridBaseColumnEh then
  begin
    InsertNode(TDataGridBaseColumnEh(Child).Title.ComplexTitleNode, AIndex);
  end
  else if Child is TDataGridSuperTitleEh then
  begin
    InsertNode(TDataGridSuperTitleEh(Child).ComplexTitleNode, AIndex);
  end else
  begin
    raise Exception.Create('TDataGridSuperTitleEh.AddChild: Child type should be TDataGridColumnEh or TDataGridSuperTitleEh');
  end;
end;

procedure TDataGridSuperTitleEh.NotifyChanges;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if Grid <> nil then
    Grid.LayoutChanged;
end;

{$REGION 'Text'}
function TDataGridSuperTitleEh.GetText: string;
begin
  if TextStored
    then Result := FText
    else Result := DefaultText;
end;

procedure TDataGridSuperTitleEh.SetText(const Value: string);
begin
  if (IsTextStored = False) or (Value <> FText) then
  begin
    FText := Value;
    FTextStored := True;
    NotifyChanges();
  end;
end;

function TDataGridSuperTitleEh.DefaultText: string;
begin
  Result := Name;
end;

function TDataGridSuperTitleEh.IsTextStored: Boolean;
begin
  Result := FTextStored;
end;

procedure TDataGridSuperTitleEh.SetTextStored(const Value: Boolean);
begin
  if FTextStored <> Value then
  begin
    FTextStored := Value;
    NotifyChanges();
  end;
end;
{$ENDREGION 'Text'}

function TDataGridSuperTitleEh.GetWidth: Integer;
var
  SelfNode: TDataGridComplexTitleTreeNodeEh;
begin
  SelfNode := TDataGridComplexTitleTreeNodeEh(ComplexTitleNode);
  Result := SelfNode.DisplayRect.Width;
end;

{$REGION 'Font'}
procedure TDataGridSuperTitleEh.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

function TDataGridSuperTitleEh.DefaultFont: TFont;
begin
  if (FGrid <> nil)
    then Result := TCustomDataAxisGridEh(FGrid).Title.Font
    else Result := SystemFont;
end;

procedure TDataGridSuperTitleEh.FontChanged(Sender: TObject);
begin
  FFontStored := True;
  NotifyChanges;
end;

procedure TDataGridSuperTitleEh.SetFontStored(const Value: Boolean);
begin
  if FFontStored <> Value then
  begin
    FFontStored := Value;
    RefreshDefaultFont;
  end;
end;

procedure TDataGridSuperTitleEh.RefreshDefaultFont;
var
  Save: TNotifyEvent;
begin
  if FontStored then Exit;
  Save := FFont.OnChanged;
  FFont.OnChanged := nil;
  try
    FFont.Assign(DefaultFont);
  finally
    FFont.OnChanged := Save;
  end;
end;

function TDataGridSuperTitleEh.IsFontStored: Boolean;
begin
  Result := FFontStored;
end;
{$ENDREGION 'Font'}

{$REGION 'FontColor'}
function TDataGridSuperTitleEh.GetFontColor: TAlphaColor;
begin
  if FontColorStored
    then Result := FFontColor
    else Result := DefaultFontColor();
end;

procedure TDataGridSuperTitleEh.SetFontColor(const Value: TAlphaColor);
begin
  if FFontColor <> Value then
  begin
    FFontColor := Value;
    FFontColorStored := True;
    NotifyChanges();
  end;
end;

function TDataGridSuperTitleEh.DefaultFontColor: TAlphaColor;
begin
  if (FGrid <> nil)
    then Result := TCustomDataGridEh(FGrid).Title.FontColor
    else Result := SystemFontColor;
end;

procedure TDataGridSuperTitleEh.SetFontColorStored(const Value: Boolean);
begin
  if FFontColorStored <> Value then
  begin
    FFontColorStored := Value;
    NotifyChanges();
  end;
end;

function TDataGridSuperTitleEh.IsFontColorStored: Boolean;
begin
  Result := FFontColorStored;
end;
{$ENDREGION 'FontColor'}

{$REGION 'Fill'}
procedure TDataGridSuperTitleEh.SetFill(const Value: TBrush);
begin
  FFill.Assign(Value);
end;

procedure TDataGridSuperTitleEh.SetFillStored(const Value: Boolean);
begin
  if FFillStored <> Value then
  begin
    FFillStored := Value;
    RefreshDefaultFill;
  end;
end;

function TDataGridSuperTitleEh.IsFillStored: Boolean;
begin
  Result := FFillStored;
end;

function TDataGridSuperTitleEh.DefaultFill: TBrush;
begin
  if (FGrid <> nil)
    then Result := TCustomDataGridEh(FGrid).Title.Fill
    else Result := SystemFill;
end;

procedure TDataGridSuperTitleEh.RefreshDefaultFill;
var
  Save: TNotifyEvent;
begin
  if FFillStored then Exit;
  Save := FFill.OnChanged;
  FFill.OnChanged := nil;
  try
    FFill.Assign(DefaultFill);
  finally
    FFill.OnChanged := Save;
  end;
end;

procedure TDataGridSuperTitleEh.FillChanged(Sender: TObject);
begin
  FFillStored := True;
  NotifyChanges;
end;
{$ENDREGION 'Fill'}

{$REGION 'Padding'}
function TDataGridSuperTitleEh.GetPadding: TBounds;
begin
  Result := FPadding;
end;

procedure TDataGridSuperTitleEh.SetPadding(const Value: TBounds);
begin
  FPadding.Assign(Value);
end;

function TDataGridSuperTitleEh.IsPaddingStored: Boolean;
begin
  Result := FPaddingStored;
end;

function TDataGridSuperTitleEh.DefaultPadding: TBounds;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if (Grid <> nil)
    then Result := Grid.Title.Padding
    else Result := EmptyBounds;
end;

procedure TDataGridSuperTitleEh.RefreshDefaultPadding;
var
  Save: TNotifyEvent;
begin
  if PaddingStored then Exit;
  Save := FPadding.OnChange;
  FPadding.OnChange := nil;
  try
    FPadding.Assign(DefaultPadding);
    FPadding.DefaultValue := DefaultPadding.Rect;
  finally
    FPadding.OnChange := Save;
  end;
end;

procedure TDataGridSuperTitleEh.SetPaddingStored(const Value: Boolean);
begin
  if FPaddingStored <> Value then
  begin
    FPaddingStored := Value;
    RefreshDefaultPadding;
    NotifyChanges();
  end;
end;

procedure TDataGridSuperTitleEh.PaddingChangedHandler(Sender: TObject);
begin
  NotifyChanges;
end;
{$ENDREGION 'Padding'}

{$REGION 'WordWrap'}
function TDataGridSuperTitleEh.GetWordWrap: Boolean;
begin
  if IsWordWrapStored
    then Result := FWordWrap
    else Result := DefaultWordWrap;
end;

procedure TDataGridSuperTitleEh.SetWordWrap(const Value: Boolean);
begin
  if (IsWordWrapStored = False) or (Value <> FWordWrap) then
  begin
    FWordWrap := Value;
    FWordWrapStored := True;
    NotifyChanges();
  end;
end;

function TDataGridSuperTitleEh.DefaultWordWrap: Boolean;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if (Grid <> nil)
    then Result := Grid.Title.WordWrap
    else Result := False;
end;

function TDataGridSuperTitleEh.IsWordWrapStored: Boolean;
begin
  Result := FWordWrapStored;
end;

procedure TDataGridSuperTitleEh.SetWordWrapStored(const Value: Boolean);
begin
  if FWordWrapStored <> Value then
  begin
    FWordWrapStored := Value;
    NotifyChanges();
  end;
end;
{$ENDREGION 'WordWrap'}

{$REGION 'HeightAutoExpand'}
function TDataGridSuperTitleEh.GetHeightAutoExpand: Boolean;
begin
  if IsHeightAutoExpandStored
    then Result := FHeightAutoExpand
    else Result := DefaultHeightAutoExpand;
end;

function TDataGridSuperTitleEh.DefaultHeightAutoExpand: Boolean;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if (Grid <> nil)
    then Result := Grid.Title.HeightAutoExpand
    else Result := False;
end;

procedure TDataGridSuperTitleEh.SetHeightAutoExpand(const Value: Boolean);
begin
  if (IsHeightAutoExpandStored = False) or (Value <> FHeightAutoExpand) then
  begin
    FHeightAutoExpand := Value;
    FHeightAutoExpandStored := True;
    NotifyChanges();
  end;
end;

procedure TDataGridSuperTitleEh.SetHeightAutoExpandStored(const Value: Boolean);
begin
  if FHeightAutoExpandStored <> Value then
  begin
    FHeightAutoExpandStored := Value;
    NotifyChanges();
  end;
end;

function TDataGridSuperTitleEh.IsHeightAutoExpandStored: Boolean;
begin
  Result := FHeightAutoExpandStored;
end;
{$ENDREGION 'HeightAutoExpand'}

procedure TDataGridSuperTitleEh.InitCell(GridCell: TGridBaseCellHolderEh);
var
  Grid: TCustomDataGridEhCrack;
  SuperCell: TDataGridSuperTitleCellHolderEh;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  SuperCell := TDataGridSuperTitleCellHolderEh(GridCell);

  SuperCell.FTitleTreeNode := ComplexTitleNode;

  SuperCell.FGrid := Grid;
  SuperCell.FColIndex := -1;
  SuperCell.FRowIndex := -1;
  SuperCell.FAreaColIndex := -1;
  SuperCell.FAreaRowIndex := -1;
  TDataGridSuperTitleCellManagerEh(SuperCell.CellManager).InitCellHolderPositionProps(SuperCell);

  SuperCell.CellManager.InternalInitCellHolder(GridCell);
end;

procedure TDataGridSuperTitleEh.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  I: Integer;
  TitleNode: TDataGridComplexTitleTreeNodeEh;
begin
  for I := 0 to  ComplexTitleNode.Count - 1 do
  begin
    TitleNode := ComplexTitleNode.Items[I];
    if TitleNode.NodeType = TDataGridCompoundTitleTreeNodeTypeEh.SuperTitleNode then
    begin
      Proc(TitleNode.SuperTitle);
    end else
    begin
      Proc(TitleNode.Column);
    end;
  end;
end;

procedure TDataGridSuperTitleEh.SetParentComponent(Value: TComponent);
begin
  if Value is TCustomDataGridEh then
    TCustomDataGridEhCrack(Value).AddChildComponent(Self)
  else if Value is TDataGridSuperTitleEh then
    TDataGridSuperTitleEh(Value).AddChildComponent(Self)
  else if Value <> nil then
    raise Exception.Create('TDataGridSuperTitleEh.SetParentComponent: Unexpected data type for Value: ' + Value.ClassName);
end;

function TDataGridSuperTitleEh.GetParentComponent: TComponent;
begin
  if (FComplexTitleNode.Parent = nil) or (FComplexTitleNode.TreeList = nil) then
    Result := nil
  else if FComplexTitleNode.Parent = TDataGridComplexTitleTreeListEh(FComplexTitleNode.TreeList).RootNode then
    Result := FGrid
  else if FComplexTitleNode.Parent.NodeType = TDataGridCompoundTitleTreeNodeTypeEh.SuperTitleNode then
    Result := FComplexTitleNode.Parent.SuperTitle
  else
    raise Exception.Create('TDataGridSuperTitleEh.GetParentComponent: Unable to determine parent component. SuperTitle: "' + Text + '"');
end;

function TDataGridSuperTitleEh.GetChildParent: TComponent;
begin
  Result := inherited GetChildParent;
end;

function TDataGridSuperTitleEh.HasParent: Boolean;
begin
  Result := True;
end;

procedure TDataGridSuperTitleEh.AddChildComponent(const Element: TComponent);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if (Element is TDataGridBaseColumnEh) then
    Grid.Title.ComplexTitleTree.AddColumn(Self, TDataGridBaseColumnEh(Element))
  else if (Element is TDataGridSuperTitleEh) then
    Grid.Title.ComplexTitleTree.AddSuperTitle(Self, TDataGridSuperTitleEh(Element));
end;

{$REGION 'HorzAlign'}
function TDataGridSuperTitleEh.GetHorzAlign: TTextAlign;
begin
  if HorzAlignStored
    then Result := FHorzAlign
    else Result := DefaultHorzAlign();
end;

procedure TDataGridSuperTitleEh.SetHorzAlign(const Value: TTextAlign);
begin
  if (IsHorzAlignStored = False) or (Value <> FHorzAlign) then
  begin
    FHorzAlign := Value;
    FHorzAlignStored := True;
    NotifyChanges();
  end;
end;

function TDataGridSuperTitleEh.DefaultHorzAlign: TTextAlign;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if (Grid <> nil)
    then Result := TCustomDataAxisGridEh(Grid).Title.HorzAlign
    else Result := TTextAlign.Center;
end;

function TDataGridSuperTitleEh.IsHorzAlignStored: Boolean;
begin
  Result := FHorzAlignStored;
end;

procedure TDataGridSuperTitleEh.SetHorzAlignStored(const Value: Boolean);
begin
  if FHorzAlignStored <> Value then
  begin
    FHorzAlignStored := Value;
    NotifyChanges();
  end;
end;
{$ENDREGION 'HorzAlign'}

  {$REGION 'VertAlign'}
function TDataGridSuperTitleEh.GetVertAlign: TTextAlign;
begin
  if VertAlignStored
    then Result := FVertAlign
    else Result := DefaultVertAlign();
end;

procedure TDataGridSuperTitleEh.SetVertAlign(const Value: TTextAlign);
begin
  if (IsVertAlignStored = False) or (Value <> FVertAlign) then
  begin
    FVertAlign := Value;
    FVertAlignStored := True;
    NotifyChanges();
  end;
end;

function TDataGridSuperTitleEh.DefaultVertAlign: TTextAlign;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if (Grid <> nil)
    then Result := TCustomDataAxisGridEh(Grid).Title.VertAlign
    else Result := TTextAlign.Center;
end;

function TDataGridSuperTitleEh.IsVertAlignStored: Boolean;
begin
  Result := FVertAlignStored;
end;

procedure TDataGridSuperTitleEh.SetVertAlignStored(const Value: Boolean);
begin
  if FVertAlignStored <> Value then
  begin
    FVertAlignStored := Value;
    NotifyChanges();
  end;
end;
  {$ENDREGION 'VertAlign'}

{$ENDREGION 'TDataGridSuperTitleEh'}

{$REGION 'TDataGridSuperTitleCellHolderEh'}

{ TDataGridSuperTitleCellHolderEh }

constructor TDataGridSuperTitleCellHolderEh.Create(AOwner: TComponent; ACellManager: TVPBaseCellManagerEh);
begin
  inherited Create(AOwner, ACellManager);
  HitTest := True;
end;

destructor TDataGridSuperTitleCellHolderEh.Destroy;
begin
  inherited Destroy;
end;

procedure TDataGridSuperTitleCellHolderEh.CreateControls(AParent: TLaObjectEh);
begin
  inherited CreateControls(AParent);
end;

procedure TDataGridSuperTitleCellHolderEh.ProcessMouseDown(Params: TControlMouseButtonParamsEh);
var
  AGrid: TCustomDataGridEhCrack;
begin
  AGrid := TCustomDataGridEhCrack(FGrid);
  inherited ProcessMouseDown(Params);
  FMouseDownPos := PointF(Params.X, Params.Y).Round;
  if AGrid.GridMouseState = AGrid.GridMouseStateManage.NormalState then
    Capture;
end;

procedure TDataGridSuperTitleCellHolderEh.ProcessMouseMove(Params: TControlMouseParamsEh);
var
  AGrid: TCustomDataGridEhCrack;
  ScreenPos: TPointF;
begin
  AGrid := TCustomDataGridEhCrack(FGrid);
  inherited ProcessMouseMove(Params);

  if (AGrid.FDataGridMouseState = TDataGridMouseStateEh.Normal) and
     (Self.IsMouseCaptured = True) and
     (ssLeft in Params.Shift) then
  begin
    ScreenPos := LocalToScreen(FMouseDownPos);
    AGrid.Capture;
    AGrid.StartComplexTitleColMoving(TitleTreeNode, ScreenPos);
  end;
end;

{$ENDREGION 'TDataGridSuperTitleCellHolderEh'}

{$REGION 'TDataGridSuperTitleCellManagerEh'}

{ TDataGridSuperTitleCellManagerEh }

function TDataGridSuperTitleCellManagerEh.CreateCellHolder: TVPBaseCellHolderEh;
begin
  Result := TDataGridSuperTitleCellHolderEh.Create(nil, Self);
end;

function TDataGridSuperTitleCellManagerEh.CreateDefaultCellContent(ACell: TGridBaseCellEh;
  AParent: TLaObjectEh): TLaObjectEh;
begin
  Result := nil;
end;

function TDataGridSuperTitleCellManagerEh.CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh;
begin
  Result := TDataGridSuperTitleCellEh.Create(ACellHolder);
end;

procedure TDataGridSuperTitleCellManagerEh.DefaultInitCell(Params: TBaseGridInitCellParamsEh);
const
  LaVertAlignments: array [TTextAlign] of TLaVertAlignmentEh = (TLaVertAlignmentEh.Center, TLaVertAlignmentEh.Top, TLaVertAlignmentEh.Bottom);
var
  SuperCell: TDataGridSuperTitleCellEh;
  TitleTreeNode: TDataGridComplexTitleTreeNodeEh;
//  VGrid: TCustomDataGridEhCrack;
begin
  inherited DefaultInitCell(Params);

//  VGrid := TCustomDataGridEhCrack(Params.Grid);
  SuperCell := Params.Cell as TDataGridSuperTitleCellEh;
  TitleTreeNode := SuperCell.TitleTreeNode;

  SuperCell.Text := TitleTreeNode.SuperTitle.Text;

  SuperCell.TextControl.HorzAlignment := TLaHorzAlignmentEh.Stretch;
  SuperCell.TextControl.TextAlign := TitleTreeNode.SuperTitle.HorzAlign;
  SuperCell.TextControl.VertAlignment := LaVertAlignments[TitleTreeNode.SuperTitle.VertAlign];
  SuperCell.TextControl.WordWrap := TitleTreeNode.SuperTitle.WordWrap;
  SuperCell.TextControl.Font := TitleTreeNode.SuperTitle.Font;
  SuperCell.TextControl.FontColor := TitleTreeNode.SuperTitle.FontColor;
end;

function TDataGridSuperTitleCellManagerEh.GetBackgroundStyle(AParams: TBaseGridInitCellParamsEh): TControl;
var
  VGrid: TCustomDataGridEhCrack;
begin
  VGrid := TCustomDataGridEhCrack(AParams.Grid);
  Result := VGrid.StylePainter.TopFixedCellBackground;
end;

{$ENDREGION 'TDataGridSuperTitleCellManagerEh'}

{$REGION 'TDataGridSuperTitleCellEh'}

{ TDataGridSuperTitleCellEh }

constructor TDataGridSuperTitleCellEh.Create(ACellHolder: TGridBaseCellHolderEh);
begin
  inherited Create(ACellHolder);
end;

destructor TDataGridSuperTitleCellEh.Destroy;
begin
  inherited Destroy;
end;

function TDataGridSuperTitleCellEh.CreateCellClientControls(AParent: TLaObjectEh): TLaObjectEh;
begin
  with TLaGridPanelEh.CreateWith(AParent, AParent) do
  begin
    Result := RefSelf;
    Margins.Rect := TRectF.Create(1, 0, 1, 0);

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Weight;
      Value := 1;
    end;

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Auto;
    end;

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Auto;
    end;

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Auto;
    end;

    
    with TLaLayoutPanelEh.CreateWith(Self, RefSelf) do
    begin
      ControlCollection.AddControl(RefSelf, 0, -1);

      FText := TLaTextBlockEh.CreateWith(Self, RefSelf);
      FText.Padding.Rect := RectF(2, 0, 2, 0);
      FText.VertAlignment := TLaVertAlignmentEh.Center;
      FText.HorzAlignment := TLaHorzAlignmentEh.Right;
    end;
  end;
end;

function TDataGridSuperTitleCellEh.GetText: String;
begin
  Result := FText.Text;
end;

function TDataGridSuperTitleCellEh.GetTitleTreeNode: TDataGridComplexTitleTreeNodeEh;
begin
  Result := TDataGridSuperTitleCellHolderEh(CellHolder).TitleTreeNode;
end;

procedure TDataGridSuperTitleCellEh.SetText(const Value: String);
begin
  FText.Text := Value;
end;

{$ENDREGION 'TDataGridSuperTitleCellEh'}

end.
