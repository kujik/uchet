{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{           EhLibFmx.DataGrid.GridManagers              }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataGrid.GridManagers;

interface

{$SCOPEDENUMS ON}

uses
  System.SysUtils, System.Classes, System.Contnrs,
  System.Variants, Rtti,

  FMX.Types, FMX.Controls, System.Types,
  FMX.Menus, FMX.Graphics, FMX.Objects,
  FMX.Forms, System.Generics.Collections,

  EhLibUtils, DBUtilsEh,

  EhLibFmx.Types,
  EhLibFmx.ToolControls,
  EhLibFmx.Grids,
  EhLib.GridTableViews,
  EhLib.GridTableView.Filters,

  EhLibFmx.DataAxisGrid.DataCells,

  EhLibFmx.DataGrid.Columns,
  EhLibFmx.DataGrid.Rows,
  EhLibFmx.DataGrid.Footers,
  EhLibFmx.DataGrid.ToolControls,
  EhLibFmx.DataGrid.Titles,
  EhLibFmx.DataGrid.TitleFilters,
  EhLibFmx.DataGrid.DataCells
  ;

type
  TDataGridCenterEh = class;

{ TDataGridEhMenuItem }

  TDataGridEhMenuItem = class(TMenuItem)
  public
  private
    FTagObject: TObject;
    FGrid: TCustomGridEh;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Grid: TCustomGridEh read FGrid write FGrid;
    property TagObject: TObject read FTagObject write FTagObject;
  end;

{ TDataGridEhCenter }

  TDataGridCenterEh = class(TComponent)
  private
    FTryUseViewScroll: Boolean;
    FGrids: TObjectListEh;
    FStyleResource: TDictionary<string, TControl>;
    FGridPopupMenu: TPopupMenu;

    FSortAscendingMenuItem: TMenuItem;
    FSortDescendingMenuItem: TMenuItem;
    FHideColumnMenuItem: TMenuItem;
    FUnfreezeColumnMenuItem: TMenuItem;
    FreezeColumnRightMenuItem: TMenuItem;
    FreezeColumnLeftMenuItem: TMenuItem;
    FCustomizeColumnsDialogFormClass: TFormClass;
    FDataGridCustomizeColumnsDialogSize: TSize;

    function GetBitmapStyleResource(ResourceName: String): TControl;
    function LoadBitmapStyleResource(ResourceName: String): TControl;

    procedure SortAscendingMenuItemClick(Sender: TObject);
    procedure SortDescendingMenuItemClick(Sender: TObject);
    procedure AddHideColumnsMenuItem(PopupMenu: TComposedPopupMenu; Column: TDataGridBaseColumnEh);
    procedure AddFreezeColumnsMenuItem(PopupMenu: TComposedPopupMenu; Column: TDataGridBaseColumnEh);
    function CreateCutMenuItem(AGrid: TControl): TMenuItem;
    function CreateCopyMenuItem(AGrid: TControl): TMenuItem;
    function CreatePasteMenuItem(AGrid: TControl): TMenuItem;
    function CreateDeleteMenuItem(AGrid: TControl): TMenuItem;
    function CreateSeparatorMenuItem(AGrid: TControl): TMenuItem;
    function CreateSelectAllMenuItem(AGrid: TControl): TMenuItem;
    function CreateCustomizeColumnsMenuItem(AGrid: TControl): TMenuItem;
    procedure MenuItemCustomizeColumnsClick(Sender: TObject);
    procedure UnfreezeColumnMenuItemClick(Sender: TObject);
    procedure FreezeColumnLeftMenuItemClick(Sender: TObject);
    procedure FreezeColumnRightMenuItemClick(Sender: TObject);

  protected
    DataGridSearchPanelOptionsScopeMenuItem: TDataGridEhMenuItem;
    DataGridSearchPanelScopeCurrentColumnMenuItem: TDataGridEhMenuItem;
    DataGridSearchPanelScopeAllTheGridMenuItem: TDataGridEhMenuItem;
    DataGridSearchPanelCaseSensitiveMenuItem: TDataGridEhMenuItem;
    DataGridSearchPanelWholeWordsMenuItem: TDataGridEhMenuItem;
    DataGridSearchPanelBeginsWithMenuItem: TDataGridEhMenuItem;
    DataGridCloseMenuItem: TDataGridEhMenuItem;

    DataGridCopyMenuItem: TDataGridEhMenuItem;
    DataGridCutMenuItem: TDataGridEhMenuItem;
    DataGridPasteMenuItem: TDataGridEhMenuItem;
    DataGridDeleteMenuItem: TDataGridEhMenuItem;
    DataGridSelectAllMenuItem: TDataGridEhMenuItem;

    DataGridRemoveFilterMenuItem: TDataGridEhMenuItem;
    DataGridEqualToFilterMenuItem: TDataGridEhMenuItem;
    DataGridNotEqualToFilterMenuItem: TDataGridEhMenuItem;

    function GridInChangeNotification(Grid: TCustomGridEh): Boolean;
    function DefaultLocateText(AGrid: TCustomGridEh; const FieldName: string; const Text: String; AOptions: TLocateTextOptionsEh; Direction: TLocateTextDirectionEh; Matching: TLocateTextMatchingEh; TreeFindRange: TLocateTextTreeFindRangeEh; TimeOut: LongWord = 0; CheckValueEvent: TCheckColumnValueAcceptEventEh = nil): Boolean; virtual;

    procedure HideColumnMenuItemClick(Sender: TObject);
    procedure MenuItemCutClick(Sender: TObject);
    procedure MenuItemCopyClick(Sender: TObject);
    procedure MenuItemPasteClick(Sender: TObject);
    procedure MenuItemDeleteClick(Sender: TObject);
    procedure MenuItemSelectAllClick(Sender: TObject);
    procedure MenuItemRemoveFilterClick(Sender: TObject);
    procedure MenuItemEqualToFilterClick(Sender: TObject);
    procedure MenuItemNotEqualToFilterClick(Sender: TObject);

    procedure Changed;
    procedure DefaultApplySorting(AGrid: TCustomGridEh); virtual;

    procedure DefaultApplyTitleFilter(AGrid: TCustomGridEh); virtual;

    procedure AddItemsFromPopupMenu(SourcePopupMenu: TPopupMenu; TargetPopupMenu: TPopupMenu);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddChangeNotification(Grid: TCustomGridEh);
    procedure RemoveChangeNotification(Grid: TCustomGridEh);
    procedure ApplySorting(AGrid: TCustomGridEh); virtual;

    function GetBuildIndicatorTitleCellPopupMenu(AGrid: TControl; AColumnTitle: TColumnTitleEh): TPopupMenu; virtual;
    function ShowCustomizeColumnsDialog(Sender: TCustomGridEh): Boolean; virtual;
    function LocateText(AGrid: TCustomGridEh; const FieldName: string; const Text: String; Options: TLocateTextOptionsEh; Direction: TLocateTextDirectionEh; Matching: TLocateTextMatchingEh; TreeFindRange: TLocateTextTreeFindRangeEh; TimeOut: LongWord = 0; CheckValueEvent: TCheckColumnValueAcceptEventEh = nil): Boolean; virtual;
    function CreateFilterItemBinOperNode(AGrid: TCustomGridEh; AFilterItem: TSTColumnFilterEh): TTableViewBinaryOperationFilterNodeEh; virtual;

    procedure BuildTitleCellPopupMenu(Params: TDataGridTitleCellComposeContextMenuParamsEh); virtual;
    procedure BuildDataCellContextMenu(Params: TDataAxisCellComposeContextMenuParamsEh); virtual;
    procedure AddSortingMenuItems(PopupMenu: TComposedPopupMenu; Column: TDataGridBaseColumnEh); virtual;
    procedure BuildSearchPanelOptionsPopupMenu(AGrid: TCustomGridEh; var PopupMenu: TPopupMenu); virtual;

    procedure MenuSearchPanelOptionsClick(Sender: TObject); virtual;
    procedure ApplyTitleFilter(AGrid: TCustomGridEh); virtual;

    property TryUseViewScroll: Boolean read FTryUseViewScroll write FTryUseViewScroll;
    property CustomizeColumnsDialogFormClass: TFormClass read FCustomizeColumnsDialogFormClass write FCustomizeColumnsDialogFormClass;
    property DataGridCustomizeColumnsDialogSize: TSize read FDataGridCustomizeColumnsDialogSize write FDataGridCustomizeColumnsDialogSize;

    property BitmapResource[ResourceName: String]: TControl read GetBitmapStyleResource;

  end;

function SetDataGridCenterEh(NewGridCenter: TDataGridCenterEh): TDataGridCenterEh;
function DataGridCenterEh: TDataGridCenterEh;

implementation

uses
  System.StrUtils,
  EhLibLangConsts,
  EhLibFmx.CustomDataGrids,
  EhLibFmx.CustomizeColumnsDialog,
  EhLibFmx.DataGrid.SearchPanels;

type
  TCustomDataGridEhCrack = class(TCustomDataGridEh);

{ TDataGridEhCenter }

var
  FDataGridEhCenter: TDataGridCenterEh = nil;

function SetDataGridCenterEh(NewGridCenter: TDataGridCenterEh): TDataGridCenterEh;
begin
  Result := FDataGridEhCenter;
  FDataGridEhCenter := NewGridCenter;
  FDataGridEhCenter.Changed;
end;

function DataGridCenterEh: TDataGridCenterEh;
begin
  Result := FDataGridEhCenter;
end;

procedure TDataGridCenterEh.Changed;
begin
end;

constructor TDataGridCenterEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FGrids := TObjectListEh.Create;
  FTryUseViewScroll := True;
  FStyleResource := TDictionary<string, TControl>.Create;
end;

destructor TDataGridCenterEh.Destroy;
var
  i: Integer;
  Pair: TPair<string, TControl>;
begin
  for i := FGrids.Count-1 downto 0 do
    TCustomDataGridEh(FGrids[i]).Center := nil;

  for Pair in FStyleResource do
    Pair.Value.Free;
  FreeAndNil(FStyleResource);

  FreeAndNil(FGridPopupMenu);
  FreeAndNil(FGrids);
  inherited Destroy;
end;

function TDataGridCenterEh.GridInChangeNotification(Grid: TCustomGridEh): Boolean;
begin
  Result := (FGrids.IndexOf(Grid) >= 0);
end;

procedure TDataGridCenterEh.AddChangeNotification(Grid: TCustomGridEh);
begin
  if not GridInChangeNotification(Grid) then
    FGrids.Add(Grid);
end;

procedure TDataGridCenterEh.RemoveChangeNotification(Grid: TCustomGridEh);
begin
  FGrids.Remove(Grid);
end;

procedure TDataGridCenterEh.ApplySorting(AGrid: TCustomGridEh);
begin
  DefaultApplySorting(AGrid);
end;

procedure TDataGridCenterEh.AddItemsFromPopupMenu(SourcePopupMenu: TPopupMenu; TargetPopupMenu: TPopupMenu);
var
  I: Integer;
  CloneItem: TMenuItem;
begin
  for I := 0 to SourcePopupMenu.ItemsCount - 1 do
  begin
    CloneItem := SourcePopupMenu.Items[I].Clone(nil) as TMenuItem;
    TargetPopupMenu.AddObject(CloneItem);
  end;
end;

procedure TDataGridCenterEh.BuildDataCellContextMenu(Params: TDataAxisCellComposeContextMenuParamsEh);
var
  Grid: TCustomDataGridEh;
  Mi: TMenuItem;
  Column: TDataGridBaseColumnEh;
begin
  Grid := TCustomDataGridEh(Params.Grid);
  Column := TDataGridBaseColumnEh(Params.FieldBar);

  if (Grid.PopupMenuBuildingMode = TPopupMenuBuildingMode.PropertyDefined) then
  begin
    if (Column.PopupMenu <> nil) then
      Params.PopupMenu := Column.PopupMenu
    else if (Grid.PopupMenu <> nil) and (Grid.PopupMenu is TPopupMenu) then
      Params.PopupMenu := TPopupMenu(Grid.PopupMenu);

    Exit;
  end;

  if (Params.ComposedPopupMenu = nil) then
  begin
    raise Exception.Create('TDataGridEhCenter.BuildDataCellContextMenu. Can''t compose menu when Params.ComposedPopupMenu = nil ');
  end;

  if (Grid.PopupMenuBuildingMode = TPopupMenuBuildingMode.LocalMenuCompound) or
     (Grid.PopupMenuBuildingMode = TPopupMenuBuildingMode.LocalAndGlobalMenuCompound) then
  begin

    begin
      if (Column.PopupMenu <> nil) then
      begin
        Params.ComposedPopupMenu.AddItemsFromMenu(Column.PopupMenu);
      end;
    end;

    begin
      if (Grid.PopupMenu <> nil) and (Grid.PopupMenu is TPopupMenu) then
      begin
        Params.ComposedPopupMenu.AddItemsFromMenu(Column.PopupMenu);
      end;
    end;
  end;

  if (Grid.PopupMenuBuildingMode = TPopupMenuBuildingMode.LocalAndGlobalMenuCompound) then
  begin

    if (Params.PopupMenu.ItemsCount > 0) then
    begin
      Mi := Params.ComposedPopupMenu.GetSeparator;
      Params.ComposedPopupMenu.AddItem(Mi);
    end;

    begin
      if DataGridCutMenuItem = nil then
        DataGridCutMenuItem := TDataGridEhMenuItem.Create(Self);
      Mi := DataGridCutMenuItem;
      Mi.OnClick := MenuItemCutClick;
      Mi.Text := 'Cut';
      Mi.Enabled := Grid.EditActions.CanCut();
      Mi.TagObject := Grid;
      Params.ComposedPopupMenu.AddItem(Mi);
    end;

    begin
      if DataGridCopyMenuItem = nil then
        DataGridCopyMenuItem := TDataGridEhMenuItem.Create(Self);
      Mi := DataGridCopyMenuItem;
      Mi.OnClick := MenuItemCopyClick;
      Mi.Text := 'Copy';
      Mi.Enabled := Grid.EditActions.CanCopy();
      Mi.TagObject := Grid;
      Params.ComposedPopupMenu.AddItem(Mi);
    end;

    begin
      if DataGridPasteMenuItem = nil then
        DataGridPasteMenuItem := TDataGridEhMenuItem.Create(Self);
      Mi := DataGridPasteMenuItem;
      Mi.OnClick := MenuItemPasteClick;
      Mi.Text := 'Paste';
      Mi.Enabled := Grid.EditActions.CanPaste();
      Mi.TagObject := Grid;
      Params.ComposedPopupMenu.AddItem(Mi);
    end;

    begin
      if DataGridDeleteMenuItem = nil then
        DataGridDeleteMenuItem := TDataGridEhMenuItem.Create(Self);
      Mi := DataGridDeleteMenuItem;
      Mi.OnClick := MenuItemDeleteClick;
      Mi.Text := 'Delete';
      Mi.Enabled := Grid.EditActions.CanDelete();
      Mi.TagObject := Grid;
      Params.ComposedPopupMenu.AddItem(Mi);
    end;

    begin
      Mi := Params.ComposedPopupMenu.GetSeparator;
      Params.ComposedPopupMenu.AddItem(Mi);
    end;

    begin
      if DataGridSelectAllMenuItem = nil then
        DataGridSelectAllMenuItem := TDataGridEhMenuItem.Create(Self);
      Mi := DataGridSelectAllMenuItem;
      Mi.OnClick := MenuItemSelectAllClick;
      Mi.Text := 'Select All';
      Mi.Enabled := Grid.EditActions.CanSelectAll();
      Mi.TagObject := Grid;
      Params.ComposedPopupMenu.AddItem(Mi);
    end;

    if (Grid.Title.SortMarking.SortMarkable) then
    begin
      AddSortingMenuItems(Params.ComposedPopupMenu, Column);
    end;

    if (Grid.CurrentColumn <> nil) and
       (Grid.CurrentColumn.Title.FilterButtonIsVisible = True) then
    begin
      Mi := Params.ComposedPopupMenu.GetSeparator;
      Params.ComposedPopupMenu.AddItem(Mi);

      if DataGridRemoveFilterMenuItem = nil then
       DataGridRemoveFilterMenuItem := TDataGridEhMenuItem.Create(Self);
      Mi := DataGridRemoveFilterMenuItem;
      Mi.OnClick := MenuItemRemoveFilterClick;
      Mi.Text := 'Remove filter from ' + Grid.CurrentColumn.Title.Text;
      Mi.Enabled := Grid.CurrentColumn.Title.FilterItem.HasValue;
      Mi.TagObject := Grid.CurrentColumn;
      Params.ComposedPopupMenu.AddItem(Mi);

      if DataGridEqualToFilterMenuItem = nil then
       DataGridEqualToFilterMenuItem := TDataGridEhMenuItem.Create(Self);
      Mi := DataGridEqualToFilterMenuItem;
      Mi.OnClick := MenuItemEqualToFilterClick;
      Mi.Text := 'Equal to "' + Grid.CurrentColumn.GetRowDisplayText(Grid.CurrentRow) + '"';
      Mi.Enabled := True;
      Mi.TagObject := Grid.CurrentColumn;
      Params.ComposedPopupMenu.AddItem(Mi);

      if DataGridNotEqualToFilterMenuItem = nil then
       DataGridNotEqualToFilterMenuItem := TDataGridEhMenuItem.Create(Self);
      Mi := DataGridNotEqualToFilterMenuItem;
      Mi.OnClick := MenuItemNotEqualToFilterClick;
      Mi.Text := 'Not equal to "' + Grid.CurrentColumn.GetRowDisplayText(Grid.CurrentRow) + '"';
      Mi.Enabled := True;
      Mi.TagObject := Grid.CurrentColumn;
      Params.ComposedPopupMenu.AddItem(Mi);
    end;
  end
end;

procedure TDataGridCenterEh.MenuItemCustomizeColumnsClick(Sender: TObject);
var
  Grid: TCustomDataGridEh;
begin
  Grid := TCustomDataGridEh((Sender as TMenuItem).TagObject);
  Grid.EditActions.ShowCustomizeColumnsDialog();
end;

procedure TDataGridCenterEh.MenuItemCutClick(Sender: TObject);
var
  Grid: TCustomDataGridEh;
begin
  Grid := TCustomDataGridEh((Sender as TMenuItem).TagObject);
  Grid.EditActions.Cut();
end;

procedure TDataGridCenterEh.MenuItemCopyClick(Sender: TObject);
var
  Grid: TCustomDataGridEh;
begin
  Grid := TCustomDataGridEh((Sender as TMenuItem).TagObject);
  Grid.EditActions.Copy();
end;

procedure TDataGridCenterEh.MenuItemPasteClick(Sender: TObject);
var
  Grid: TCustomDataGridEh;
begin
  Grid := TCustomDataGridEh((Sender as TMenuItem).TagObject);
  Grid.EditActions.Paste();
end;

procedure TDataGridCenterEh.MenuItemRemoveFilterClick(Sender: TObject);
var
  Column: TDataGridBaseColumnEh;
begin
  Column := TDataGridBaseColumnEh((Sender as TMenuItem).TagObject);
  Column.Title.FilterItem.Clear;
  TCustomDataGridEh(Column.Grid).Title.Filter.ApplyFilter();
end;

procedure TDataGridCenterEh.MenuItemEqualToFilterClick(Sender: TObject);
var
  Column: TDataGridBaseColumnEh;
  Grid: TCustomDataGridEh;
begin
  Column := TDataGridBaseColumnEh((Sender as TMenuItem).TagObject);
  Grid := TCustomDataGridEh(Column.Grid);
  Column.Title.FilterItem.SetExpression(foEqual, Column.GetRowValue(Grid.CurrentRow), foNon, foNon, TValue.Empty);
  TCustomDataGridEh(Column.Grid).Title.Filter.ApplyFilter();
end;

procedure TDataGridCenterEh.MenuItemNotEqualToFilterClick(Sender: TObject);
var
  Column: TDataGridBaseColumnEh;
  Grid: TCustomDataGridEh;
begin
  Column := TDataGridBaseColumnEh((Sender as TMenuItem).TagObject);
  Grid := TCustomDataGridEh(Column.Grid);
  Column.Title.FilterItem.SetExpression(foNotEqual, Column.GetRowValue(Grid.CurrentRow), foNon, foNon, TValue.Empty);
  TCustomDataGridEh(Column.Grid).Title.Filter.ApplyFilter();
end;

procedure TDataGridCenterEh.MenuItemDeleteClick(Sender: TObject);
var
  Grid: TCustomDataGridEh;
begin
  Grid := TCustomDataGridEh((Sender as TMenuItem).TagObject);
  Grid.EditActions.Delete();
end;

procedure TDataGridCenterEh.MenuItemSelectAllClick(Sender: TObject);
var
  Grid: TCustomDataGridEh;
begin
  Grid := TCustomDataGridEh((Sender as TMenuItem).TagObject);
  Grid.EditActions.SelectAll();
end;

function TDataGridCenterEh.CreateCustomizeColumnsMenuItem(AGrid: TControl): TMenuItem;
var
  Grid: TCustomDataGridEh;
begin
  Grid := TCustomDataGridEh(AGrid);
  Result := TMenuItem.Create(nil);
  Result.OnClick := MenuItemCustomizeColumnsClick;
  Result.Text := 'Customize columns ...';
  Result.Enabled := True;
  Result.TagObject := Grid;
end;

function TDataGridCenterEh.CreateCutMenuItem(AGrid: TControl): TMenuItem;
var
  Grid: TCustomDataGridEh;
begin
  Grid := TCustomDataGridEh(AGrid);
  Result := TMenuItem.Create(nil);
  Result.OnClick := MenuItemCutClick;
  Result.Text := 'Cut';
  Result.Enabled := Grid.EditActions.CanCut();
  Result.TagObject := Grid;
end;

function TDataGridCenterEh.CreateCopyMenuItem(AGrid: TControl): TMenuItem;
var
  Grid: TCustomDataGridEh;
begin
  Grid := TCustomDataGridEh(AGrid);
  Result := TMenuItem.Create(nil);
  Result.OnClick := MenuItemCopyClick;
  Result.Text := 'Copy';
  Result.Enabled := Grid.EditActions.CanCopy();
  Result.TagObject := Grid;
end;

function TDataGridCenterEh.CreatePasteMenuItem(AGrid: TControl): TMenuItem;
var
  Grid: TCustomDataGridEh;
begin
  Grid := TCustomDataGridEh(AGrid);
  Result := TMenuItem.Create(nil);
  Result.OnClick := MenuItemPasteClick;
  Result.Text := 'Paste';
  Result.Enabled := Grid.EditActions.CanPaste();
  Result.TagObject := Grid;
end;

function TDataGridCenterEh.CreateDeleteMenuItem(AGrid: TControl): TMenuItem;
var
  Grid: TCustomDataGridEh;
begin
  Grid := TCustomDataGridEh(AGrid);
  Result := TMenuItem.Create(nil);
  Result.OnClick := MenuItemDeleteClick;
  Result.Text := 'Delete';
  Result.Enabled := Grid.EditActions.CanDelete();
  Result.TagObject := Grid;
end;

function TDataGridCenterEh.CreateSeparatorMenuItem(AGrid: TControl): TMenuItem;
begin
  Result := TMenuItem.Create(nil);
  Result.Text := '-';
end;

function TDataGridCenterEh.CreateSelectAllMenuItem(AGrid: TControl): TMenuItem;
var
  Grid: TCustomDataGridEh;
begin
  Grid := TCustomDataGridEh(AGrid);
  Result := TMenuItem.Create(nil);
  Result.OnClick := MenuItemSelectAllClick;
  Result.Text := 'Select All';
  Result.Enabled := Grid.EditActions.CanSelectAll();
  Result.TagObject := Grid;
end;

function TDataGridCenterEh.GetBuildIndicatorTitleCellPopupMenu(AGrid: TControl;
  AColumnTitle: TColumnTitleEh): TPopupMenu;
var
  Mi: TMenuItem;
begin
  Result := nil;

  if (Result = nil) then
  begin
    if (FGridPopupMenu = nil) then
    begin
      FGridPopupMenu := TPopupMenu.Create(nil);
    end;

    FGridPopupMenu.Clear();

    Result := FGridPopupMenu;
  end;

  Mi := CreateCustomizeColumnsMenuItem(AGrid);
  Result.AddObject(Mi);

  Mi := CreateSeparatorMenuItem(AGrid);
  Result.AddObject(Mi);

  Mi := CreateCutMenuItem(AGrid);
  Result.AddObject(Mi);

  Mi := CreateCopyMenuItem(AGrid);
  Result.AddObject(Mi);

  Mi := CreatePasteMenuItem(AGrid);
  Result.AddObject(Mi);

  Mi := CreateDeleteMenuItem(AGrid);
  Result.AddObject(Mi);

  Mi := CreateSeparatorMenuItem(AGrid);
  Result.AddObject(Mi);

  Mi := CreateSelectAllMenuItem(AGrid);
  Result.AddObject(Mi);
end;

procedure TDataGridCenterEh.BuildTitleCellPopupMenu(Params: TDataGridTitleCellComposeContextMenuParamsEh);
var
  Grid: TCustomDataGridEh;
  Mi: TMenuItem;
  AColumnTitle: TColumnTitleEh;
begin
  Grid := TCustomDataGridEh(Params.Grid);
  AColumnTitle := Params.Column.Title;
  if (Grid.PopupMenuBuildingMode = TPopupMenuBuildingMode.PropertyDefined) then
  begin
    if (AColumnTitle.PopupMenu <> nil) then
      Params.PopupMenu := AColumnTitle.PopupMenu
    else if (Grid.Title.PopupMenu <> nil) then
      Params.PopupMenu := Grid.Title.PopupMenu
    else if (Grid.PopupMenu <> nil) and (Grid.PopupMenu is TPopupMenu) then
      Params.PopupMenu := TPopupMenu(Grid.PopupMenu);

    Exit;
  end;

  if (Params.ComposedPopupMenu = nil) then
  begin
    raise Exception.Create('TDataGridEhCenter.BuildTitleCellPopupMenu. Can''t compose menu when Params.ComposedPopupMenu = nil ');
  end;

  if (Grid.PopupMenuBuildingMode = TPopupMenuBuildingMode.LocalMenuCompound) or
     (Grid.PopupMenuBuildingMode = TPopupMenuBuildingMode.LocalAndGlobalMenuCompound) then
  begin
    begin
      if (AColumnTitle.PopupMenu <> nil) then
      begin
        if (Params.ComposedPopupMenu.ItemsCount > 0) then
        begin
          Mi := Params.ComposedPopupMenu.GetSeparator;
          Params.ComposedPopupMenu.AddItem(Mi);
        end;
      end;
    end;

    begin
      if (Grid.Title.PopupMenu <> nil) {and (Params.PopupMenu is DataGridContextMenuStrip)} then
      begin
        if (Params.ComposedPopupMenu.ItemsCount > 0) then
        begin
          Mi := Params.ComposedPopupMenu.GetSeparator;
          Params.ComposedPopupMenu.AddItem(Mi);
        end;
      end;
    end;

    begin
      if (Grid.PopupMenu <> nil) and (Grid.PopupMenu is TPopupMenu) then
      begin
        if (Params.ComposedPopupMenu.ItemsCount > 0) then
        begin
          Mi := Params.ComposedPopupMenu.GetSeparator;
          Params.ComposedPopupMenu.AddItem(Mi);
        end;
      end;
    end;
  end;

  if (Grid.PopupMenuBuildingMode = TPopupMenuBuildingMode.LocalAndGlobalMenuCompound) then
  begin

    if (Grid.Title.SortMarking.SortMarkable) then
    begin
      AddSortingMenuItems(Params.ComposedPopupMenu, AColumnTitle.Column);
    end;

    AddHideColumnsMenuItem(Params.ComposedPopupMenu, AColumnTitle.Column);
    AddFreezeColumnsMenuItem(Params.ComposedPopupMenu, AColumnTitle.Column);
  end
end;

procedure TDataGridCenterEh.AddSortingMenuItems(PopupMenu: TComposedPopupMenu; Column: TDataGridBaseColumnEh);
var
  Cmi: TMenuItem;
begin
  begin
    if (PopupMenu.ItemsCount > 0) then
    begin
      Cmi := PopupMenu.GetSeparator;
      PopupMenu.AddItem(Cmi);
    end;
  end;

  begin
    if (FSortAscendingMenuItem = nil) then
    begin
      FSortAscendingMenuItem := TMenuItem.Create(Self);
      FSortAscendingMenuItem.OnClick := SortAscendingMenuItemClick;
    end;
    Cmi := FSortAscendingMenuItem;
    if (Cmi.Parent <> nil) then
      Cmi.Parent.RemoveObject(Cmi);
    Cmi.Text := 'Sorting By Ascend';
    Cmi.Enabled := true;
    Cmi.TagObject := Column;
    PopupMenu.AddItem(Cmi);
  end;

  begin
    if (FSortDescendingMenuItem = nil) then
    begin
      FSortDescendingMenuItem := TMenuItem.Create(Self);
      FSortDescendingMenuItem.OnClick := SortDescendingMenuItemClick;
    end;
    Cmi := FSortDescendingMenuItem;
    if (Cmi.Parent <> nil) then
      Cmi.Parent.RemoveObject(Cmi);
    Cmi.Text := 'Sorting By Descend';
    Cmi.Enabled := true;
    Cmi.TagObject := Column;
    PopupMenu.AddItem(Cmi);
  end;
end;

function TDataGridCenterEh.ShowCustomizeColumnsDialog(Sender: TCustomGridEh): Boolean;
begin
  Result := ShowDataGridEhCustomizeColumnsDialog(TCustomDataGridEh(Sender),
    FDataGridCustomizeColumnsDialogSize, CustomizeColumnsDialogFormClass);
end;

procedure TDataGridCenterEh.SortAscendingMenuItemClick(Sender: TObject);
var
  MenuItem: TMenuItem;
  Column: TDataGridBaseColumnEh;
  Grid: TCustomDataGridEh;
  SortMarking: TDataGridTitleSortMarkingEh;
begin
  MenuItem := Sender as TMenuItem;
  Column := MenuItem.TagObject as TDataGridBaseColumnEh;
  Grid := TCustomDataGridEh(Column.Grid);
  SortMarking := Grid.Title.SortMarking;

  SortMarking.SetSortState(Column, TSortOrderEh.soAscEh);
  SortMarking.ApplySortMarkers();
end;

procedure TDataGridCenterEh.SortDescendingMenuItemClick(Sender: TObject);
var
  MenuItem: TMenuItem;
  Column: TDataGridBaseColumnEh;
  Grid: TCustomDataGridEh;
  SortMarking: TDataGridTitleSortMarkingEh;
begin
  MenuItem := Sender as TMenuItem;
  Column := MenuItem.TagObject as TDataGridBaseColumnEh;
  Grid := TCustomDataGridEh(Column.Grid);
  SortMarking := Grid.Title.SortMarking;

  SortMarking.SetSortState(Column, TSortOrderEh.soDescEh);
  SortMarking.ApplySortMarkers();
end;

procedure TDataGridCenterEh.AddFreezeColumnsMenuItem(PopupMenu: TComposedPopupMenu;
  Column: TDataGridBaseColumnEh);
var
  Cmi: TMenuItem;
  Grid: TCustomDataGridEh;
  FreeSides: Integer;
  UnfrozenColCount: Integer;
begin
  Grid := TCustomDataGridEh(Column.Grid);
//
  FreeSides := 0;
  if Grid.ColumnOptions.AllowFreezeLeft then
    FreeSides := FreeSides + 1;
  if Grid.ColumnOptions.AllowFreezeRight then
    FreeSides := FreeSides + 1;
//
  UnfrozenColCount := Grid.VisibleColumns.Count - Grid.FrozenLeftColCount - Grid.FrozenRightColCount;

  if (FUnfreezeColumnMenuItem = nil) then
  begin
    FUnfreezeColumnMenuItem := TMenuItem.Create(Self);
    FUnfreezeColumnMenuItem.OnClick := UnfreezeColumnMenuItemClick;
  end;
  PopupMenu.AddItem(FUnfreezeColumnMenuItem);

  if (FreezeColumnLeftMenuItem = nil) then
  begin
    FreezeColumnLeftMenuItem := TMenuItem.Create(Self);
    FreezeColumnLeftMenuItem.OnClick := FreezeColumnLeftMenuItemClick;
  end;
  PopupMenu.AddItem(FreezeColumnLeftMenuItem);

  if (FreezeColumnRightMenuItem = nil) then
  begin
    FreezeColumnRightMenuItem := TMenuItem.Create(Self);
    FreezeColumnRightMenuItem.OnClick := FreezeColumnRightMenuItemClick;
  end;
  PopupMenu.AddItem(FreezeColumnRightMenuItem);

  Cmi := FUnfreezeColumnMenuItem;
  Cmi.Text := 'Unfreeze Column';
  Cmi.Enabled := (Column.FrozenPosition <> TColumnFrozenPositionEh.None);
  Cmi.Visible := Grid.ColumnOptions.AllowFreezeLeft = True or
                 Grid.ColumnOptions.AllowFreezeRight = True;
  Cmi.TagObject := Column;

  Cmi := FreezeColumnLeftMenuItem;
  if FreeSides > 1
    then Cmi.Text := 'Freeze Column Left'
    else Cmi.Text := 'Freeze Column';
  Cmi.Enabled := (Column.FrozenPosition = TColumnFrozenPositionEh.None) and (UnfrozenColCount > 1);
  Cmi.Visible := Grid.ColumnOptions.AllowFreezeLeft = True;
  Cmi.TagObject := Column;

  Cmi := FreezeColumnRightMenuItem;
  if FreeSides > 1
    then Cmi.Text := 'Freeze Column Right'
    else Cmi.Text := 'Freeze Column';
  Cmi.Enabled := (Column.FrozenPosition = TColumnFrozenPositionEh.None) and (UnfrozenColCount > 1);
  Cmi.Visible := Grid.ColumnOptions.AllowFreezeRight = True;
  Cmi.TagObject := Column;
end;

procedure TDataGridCenterEh.AddHideColumnsMenuItem(PopupMenu: TComposedPopupMenu; Column: TDataGridBaseColumnEh);
var
  Cmi: TMenuItem;
  Grid: TCustomDataGridEh;
begin
  Grid := TCustomDataGridEh(Column.Grid);
  if (FHideColumnMenuItem = nil) then
  begin
    FHideColumnMenuItem := TMenuItem.Create(Self);
    FHideColumnMenuItem.OnClick := HideColumnMenuItemClick;
  end;
  Cmi := FHideColumnMenuItem;
  if (Cmi.Parent <> nil) then
    Cmi.Parent.RemoveObject(Cmi);
  if (Grid.Selection.Columns.Count > 0) then
    Cmi.Text := 'Hide selected columns'
  else
    Cmi.Text := 'Hide column';
  Cmi.Enabled := True;
  Cmi.TagObject := Column;
  PopupMenu.AddItem(Cmi);
end;

procedure TDataGridCenterEh.HideColumnMenuItemClick(Sender: TObject);
var
  MenuItem: TMenuItem;
  Column: TDataGridBaseColumnEh;
  Grid: TCustomDataGridEh;
  I: Integer;
begin
  MenuItem := Sender as TMenuItem;
  Column := MenuItem.TagObject as TDataGridBaseColumnEh;
  Grid := TCustomDataGridEh(Column.Grid);

  if (Grid.Selection.Columns.Count > 0) then
  begin
    try
      for I := 0 to Grid.Selection.Columns.Count - 1 do
         Grid.Selection.Columns[I].Visible := False;
    finally
    end;
  end
  else
  begin
    Column.Visible := False;
  end;
end;

procedure TDataGridCenterEh.UnfreezeColumnMenuItemClick(Sender: TObject);
var
  MenuItem: TMenuItem;
  Column: TDataGridBaseColumnEh;
begin
  MenuItem := Sender as TMenuItem;
  Column := MenuItem.TagObject as TDataGridBaseColumnEh;
  Column.FrozenPosition := TColumnFrozenPositionEh.None;
end;

procedure TDataGridCenterEh.FreezeColumnLeftMenuItemClick(Sender: TObject);
var
  MenuItem: TMenuItem;
  Column: TDataGridBaseColumnEh;
begin
  MenuItem := Sender as TMenuItem;
  Column := MenuItem.TagObject as TDataGridBaseColumnEh;
  Column.FrozenPosition := TColumnFrozenPositionEh.Left;
end;

procedure TDataGridCenterEh.FreezeColumnRightMenuItemClick(Sender: TObject);
var
  MenuItem: TMenuItem;
  Column: TDataGridBaseColumnEh;
begin
  MenuItem := Sender as TMenuItem;
  Column := MenuItem.TagObject as TDataGridBaseColumnEh;
  Column.FrozenPosition := TColumnFrozenPositionEh.Right;
end;

procedure TDataGridCenterEh.DefaultApplySorting(AGrid: TCustomGridEh);
var
  SortOrderStr: String;
  I: Integer;
  SortItem: TDataGridSortItemEh;
  Grid: TCustomDataGridEhCrack;

  function WrapFieldName(const FieldName: String): String;
  var
    i: Integer;
  begin
    for i := 1 to Length(FieldName) do
    begin
      if CharInSetEh(FieldName[i], [' ', ',', ';', '''']) then
      begin
        Result := '[' + FieldName + ']';
        Exit;
      end;
    end;
    Result := FieldName;
  end;

begin
  Grid := TCustomDataGridEhCrack(AGrid);
  for I := 0 to Grid.Title.SortMarking.SortMarkers.Count - 1 do
  begin
    SortItem := Grid.Title.SortMarking.SortMarkers[I];
    SortOrderStr := SortOrderStr + WrapFieldName(SortItem.Column.FieldName) + ' ';
    if SortItem.SortDirection = soDescEh then
      SortOrderStr := SortOrderStr + ' DESC';
    SortOrderStr := SortOrderStr + ',';
  end;
  Delete(SortOrderStr, Length(SortOrderStr), 1);

  Grid.TableView.SortOrderStr := SortOrderStr;

end;

function TDataGridCenterEh.GetBitmapStyleResource(ResourceName: String): TControl;
begin
  if not FStyleResource.TryGetValue(ResourceName, Result) then
  begin
    Result := LoadBitmapStyleResource(ResourceName);
  end;
end;

function TDataGridCenterEh.LoadBitmapStyleResource(ResourceName: String): TControl;
var
  Stream: TStream;
  Instance: THandle;
  Bitmap: TBitmap;
  Image: TImage;
begin
  Instance := HInstance;
  Bitmap := nil;
  Stream := System.Classes.TResourceStream.Create(Instance, ResourceName, RT_RCDATA);
  try
    Image := TImage.Create(nil);
    Bitmap := TBitmap.Create;
    Bitmap.LoadFromStream(Stream);

    Image.Bitmap := Bitmap;
    Image.Size.Size := Image.Bitmap.Size;

    Result := Image;
    FStyleResource.Add(ResourceName, Image);

  finally
    Stream.Free;
    Bitmap.Free;
  end;

end;

function TDataGridCenterEh.LocateText(AGrid: TCustomGridEh; const FieldName,
  Text: String; Options: TLocateTextOptionsEh;
  Direction: TLocateTextDirectionEh; Matching: TLocateTextMatchingEh;
  TreeFindRange: TLocateTextTreeFindRangeEh; TimeOut: LongWord;
  CheckValueEvent: TCheckColumnValueAcceptEventEh): Boolean;
begin
    Result := DefaultLocateText(AGrid, FieldName, Text, Options, Direction,
      Matching, TreeFindRange, TimeOut, CheckValueEvent);
end;

function TDataGridCenterEh.DefaultLocateText(AGrid: TCustomGridEh;
  const FieldName, Text: String; AOptions: TLocateTextOptionsEh;
  Direction: TLocateTextDirectionEh; Matching: TLocateTextMatchingEh;
  TreeFindRange: TLocateTextTreeFindRangeEh; TimeOut: LongWord;
  CheckValueEvent: TCheckColumnValueAcceptEventEh): Boolean;
var
  ACurInListColIndex: Integer;
  ACheckEof: Boolean;
  ACheckBof: Boolean;
  AFindFromStart: Boolean;
  FindColList: TColumnsListEh;
  ticks: UInt64;
  RecChanged: Boolean;
  ADataGrid: TCustomDataGridEhCrack;
  CurRowPos: Integer;
  CurRow: TDataGridRowEh;
  SearchingText: String;

  function CheckEofBof(): Boolean;
  begin
    if (Direction = ltdUpEh)
      then Result := CurRowPos < 0
      else Result := CurRowPos >= ADataGrid.VisibleRows.Count;
  end;

  function CheckNextCol: Boolean;
  begin
    Result := ACurInListColIndex < FindColList.Count-1;
    if Result then
      Inc(ACurInListColIndex);
  end;

  function CheckPrevCol: Boolean;
  begin
    Result := ACurInListColIndex > 0;
    if Result then
      Dec(ACurInListColIndex);
  end;

  procedure ResetCol(ToFirstCol: Boolean);
  begin
    if ToFirstCol then
      if ltoInsideSelectionEh in AOptions then
        case ADataGrid.Selection.SelectionType of
          TDataGridSelectionTypeEh.RecordBookmarks: ACurInListColIndex := 0;
          TDataGridSelectionTypeEh.Rectangle: ACurInListColIndex := 0;
          TDataGridSelectionTypeEh.Columns: ACurInListColIndex := 0; 
          TDataGridSelectionTypeEh.All: ACurInListColIndex := 0;
          TDataGridSelectionTypeEh.Non: ACurInListColIndex := 0;
        end
      else
        ACurInListColIndex := 0
    else
      if ltoInsideSelectionEh in AOptions then
        case ADataGrid.Selection.SelectionType of
          TDataGridSelectionTypeEh.RecordBookmarks: ACurInListColIndex := FindColList.Count-1;
          TDataGridSelectionTypeEh.Rectangle: ACurInListColIndex := FindColList.Count-1;
          TDataGridSelectionTypeEh.Columns: ACurInListColIndex := FindColList.Count-1;
          TDataGridSelectionTypeEh.All: ACurInListColIndex := FindColList.Count-1;
          TDataGridSelectionTypeEh.Non: ACurInListColIndex := FindColList.Count-1;
        end
      else
        ACurInListColIndex := FindColList.Count-1
  end;

  procedure NextRec;
  begin
    CurRowPos := CurRowPos + 1;
    if (CurRowPos < ADataGrid.VisibleRows.Count) then
      CurRow := ADataGrid.VisibleRows[CurRowPos]
    else
      CurRow := nil;
    RecChanged := True;
  end;

  procedure PriorRec;
  begin
    CurRowPos := CurRowPos - 1;
    if (CurRowPos >= 0) then
      CurRow := ADataGrid.VisibleRows[CurRowPos]
    else
      CurRow := nil;
  end;

  procedure ToNextRec;
  begin
    if ltoAllFieldsEh in AOptions then
    begin
      if (Direction = ltdUpEh) then
      begin
        if CheckPrevCol then
          
        else
        begin
          PriorRec;
          ResetCol(False);
        end;
      end else
      begin
        if CheckNextCol then
          
        else
        begin
          NextRec;
          ResetCol(True);
        end;
      end
    end
    else if (Direction = ltdUpEh) then
      PriorRec
    else
      NextRec;
  end;

  procedure ResetRec(ToFirstRec: Boolean);
  begin
    if ToFirstRec then
      CurRowPos := 0
    else
      CurRowPos := ADataGrid.VisibleRows.Count - 1;

    if (ADataGrid.VisibleRows.Count > 0) then
      CurRow := ADataGrid.VisibleRows[CurRowPos]
    else
      CurRow := nil;

    ACurInListColIndex := 0;
  end;

  function ColText(Col: TDataGridBaseColumnEh; ARow: TDataGridRowEh): String;
  begin
    if ltoMatchFormatEh in AOptions then
      Result := Col.GetRowDisplayText(ARow)
    else
      Result := Col.GetRowEditText(ARow);
  end;

  function AnsiContainsText(const AText, ASubText: string): Boolean;
  begin
    Result := AnsiPos(AnsiUppercase(ASubText), AnsiUppercase(AText)) > 0;
  end;

  function AnsiContainsStr(const AText, ASubText: string): Boolean;
  begin
    Result := AnsiPos(ASubText, AText) > 0;
  end;

  function IsEscapePressed: Boolean;
  begin
    Result := False;
  end;

  function IsAnyKeyPress: Boolean;
  begin
    Result := False;
  end;

  procedure ResetAll;
  begin
    if Direction in [ltdAllEh, ltdDownEh] then
    begin
      ResetRec(True);
      ResetCol(True);
    end else
    begin
      ResetRec(False);
      ResetCol(False);
    end;
    AFindFromStart := True;
    ACheckEof := False;
    ACheckBof := False;
  end;

  procedure SetFoundIndex(Index: Integer);
  begin
    if ADataGrid.SearchPanel.Active
      then ADataGrid.SearchPanel.FoundColumnIndex := Index
      else ADataGrid.CurrentColIndex := Index;
  end;

  function GetFoundIndex: Integer;
  begin
    if ADataGrid.SearchPanel.Active
      then Result := ADataGrid.SearchPanel.FoundColumnIndex
      else Result := ADataGrid.CurrentColIndex;
    if Result < 0 then
      Result := 0;
  end;

  procedure FillFindColList;
  var
    i: Integer;
  begin
    for i := 0 to ADataGrid.VisibleColumns.Count-1 do
      FindColList.Add(ADataGrid.VisibleColumns[i])
  end;

var
  DataText: String;
  PC: PChar;

begin
  ADataGrid := TCustomDataGridEhCrack(AGrid);
  Result := False;
  ACheckEof := False;
  ACheckBof := False;
  AFindFromStart := False;
  ticks := GetTickCountEh;
  RecChanged := False;
  SearchingText := Text;

  FindColList := TColumnsListEh.Create;
  FillFindColList;
  try

  if Assigned(ADataGrid) and
     Assigned(ADataGrid.TableView) and
     (ADataGrid.TableView.Active = True) and
     (ADataGrid.TableView.FilteredRowList.Count > 0)
  then
  begin
    ACurInListColIndex := FindColList.IndexOf(ADataGrid.VisibleColumns[GetFoundIndex]);
    if ACurInListColIndex < 0 then
      ACurInListColIndex := 0;

    if (ADataGrid.SearchPanel.Active = False) and
       (ADataGrid.SelectionOptions.RowSelect = True) and
       (FieldName = '') then
    begin
      ACurInListColIndex := 0;
    end;

    if (ADataGrid.VisibleColumns.Count = 0) then Exit;

    if (Direction = ltdAllEh) then
    begin
      ResetRec(True);
    end else
    begin
      CurRow := ADataGrid.CurrentRow;
      CurRowPos := ADataGrid.CurRowIndex - ADataGrid.StartDataRowIndex;
      ToNextRec;
    end;

    while True do
    begin
      if CheckEofBof then
      begin
        if AFindFromStart
          then Break
          else ResetAll;
      end;

      if CurRow = nil then
        Break;

      if @CheckValueEvent <> nil then
      begin
        Result := False;
        CheckValueEvent(FindColList[ACurInListColIndex], CurRow, Result, Text);
        if Result then
        begin
          SetFoundIndex(FindColList[ACurInListColIndex].VisibleIndex);
          Break;
        end;
      end else
      begin

        DataText := ColText(FindColList[ACurInListColIndex], CurRow);

        if (ltoWholeWordsEh in AOptions) and
           (Matching = ltmAnyPartEh) then
        begin
          if ltoCaseInsensitiveEh in AOptions then
          begin
            DataText := AnsiUpperCase(DataText);
            SearchingText := AnsiUpperCase(SearchingText);
          end;
          PC := SearchBuf(PChar(DataText), Length(DataText), 0, 0, Text, [soDown, soWholeWord]);
          if PC <> nil then
          begin
            Result := True;
            Break;
          end;
        end else
        if not (ltoCaseInsensitiveEh in AOptions) then
        begin
          if ( (Matching = ltmAnyPartEh) and (AnsiContainsStr(DataText, Text) ))
            or ((Matching = ltmWholeEh) and (DataText = Text))
            or ((Matching = ltmFromBeginningEh) and
                 (Copy(DataText, 1, Length(Text)) = Text) )
          then
          begin
            Result := True;
            Break;
          end
        end else 
        if ( (Matching = ltmAnyPartEh) and (AnsiContainsText(DataText, Text) ))
         or ((Matching = ltmWholeEh) and (AnsiUpperCase(DataText) = AnsiUpperCase(Text)))
         or ((Matching = ltmFromBeginningEh) and
          (AnsiUpperCase(Copy(DataText, 1, Length(Text))) = AnsiUpperCase(Text)) ) then
        begin
          Result := True;
          Break;
        end;

      end;

      if RecChanged then
      begin
        if (ltoStopOnEscapeEh in AOptions) and IsEscapePressed then
          Break;

        if (ltoStopKeyMessageEh in AOptions) and IsAnyKeyPress then
          Break;

        if (TimeOut > 0) and ((GetTickCountEh - ticks) > TimeOut) then
          Break;

        RecChanged := False;
      end;

      ToNextRec;
    end;
  end;

  if Result = True then
  begin
    ADataGrid.CurrentRow := CurRow;
    SetFoundIndex(FindColList[ACurInListColIndex].VisibleIndex);
  end;


  finally
    FreeAndNil(FindColList);
  end;
end;

procedure TDataGridCenterEh.BuildSearchPanelOptionsPopupMenu(AGrid: TCustomGridEh; var PopupMenu: TPopupMenu);
var
  mi: TDataGridEhMenuItem;
  i: Integer;
  ADataGrid: TCustomDataGridEhCrack;
begin
  ADataGrid := TCustomDataGridEhCrack(AGrid);
  if TDataGridSearchPanelOptionMenuItemEh.SearchScopes in ADataGrid.SearchPanel.OptionsPopupMenuItems then
  begin
    if DataGridSearchPanelOptionsScopeMenuItem = nil then
      DataGridSearchPanelOptionsScopeMenuItem := TDataGridEhMenuItem.Create(Self);
    if DataGridSearchPanelOptionsScopeMenuItem.Parent <> nil then
      DataGridSearchPanelOptionsScopeMenuItem.Parent.RemoveObject(DataGridSearchPanelOptionsScopeMenuItem);
    for i := DataGridSearchPanelOptionsScopeMenuItem.ChildrenCount - 1 downto 0 do
      DataGridSearchPanelOptionsScopeMenuItem.RemoveObject(i);
    DataGridSearchPanelOptionsScopeMenuItem.Text := EhLibLanguageConsts.SearchScopeEh;
    PopupMenu.AddObject(DataGridSearchPanelOptionsScopeMenuItem);

    if DataGridSearchPanelScopeCurrentColumnMenuItem = nil then
      DataGridSearchPanelScopeCurrentColumnMenuItem := TDataGridEhMenuItem.Create(Screen);

    mi := DataGridSearchPanelScopeCurrentColumnMenuItem;
    mi.Grid := ADataGrid;
    mi.Text := EhLibLanguageConsts.CurrentColumnEh;
    mi.OnClick := MenuSearchPanelOptionsClick;
    mi.Enabled := True;
    mi.Tag := 0;
    DataGridSearchPanelOptionsScopeMenuItem.AddObject(mi);

    if DataGridSearchPanelScopeAllTheGridMenuItem = nil then
      DataGridSearchPanelScopeAllTheGridMenuItem := TDataGridEhMenuItem.Create(Screen);

    mi := DataGridSearchPanelScopeAllTheGridMenuItem;
    mi.Grid := ADataGrid;
    mi.Text := EhLibLanguageConsts.TheEntireGridEh;
    mi.OnClick := MenuSearchPanelOptionsClick;
    mi.Enabled := True;
    mi.Tag := 1;
    DataGridSearchPanelOptionsScopeMenuItem.AddObject(mi);
  end;

  if TDataGridSearchPanelOptionMenuItemEh.CaseSensitive in ADataGrid.SearchPanel.OptionsPopupMenuItems then
  begin
    if DataGridSearchPanelCaseSensitiveMenuItem = nil then
      DataGridSearchPanelCaseSensitiveMenuItem := TDataGridEhMenuItem.Create(Screen);
    mi := DataGridSearchPanelCaseSensitiveMenuItem;
    mi.Grid := ADataGrid;
    mi.Text := EhLibLanguageConsts.CaseSensitiveEh;
    mi.OnClick := MenuSearchPanelOptionsClick;
    mi.Enabled := True;
    mi.Tag := 0;
    PopupMenu.AddObject(mi);
  end;

  if TDataGridSearchPanelOptionMenuItemEh.WholeWords in ADataGrid.SearchPanel.OptionsPopupMenuItems then
  begin
    if DataGridSearchPanelWholeWordsMenuItem = nil then
      DataGridSearchPanelWholeWordsMenuItem := TDataGridEhMenuItem.Create(Screen);
    mi := DataGridSearchPanelWholeWordsMenuItem;
    mi.Grid := ADataGrid;
    mi.Text := EhLibLanguageConsts.WholeWordsEh;
    mi.OnClick := MenuSearchPanelOptionsClick;
    mi.Enabled := True;
    mi.Tag := 1;
    PopupMenu.AddObject(mi);
  end;

  if TDataGridSearchPanelOptionMenuItemEh.BeginsWith in ADataGrid.SearchPanel.OptionsPopupMenuItems then
  begin
    if DataGridSearchPanelBeginsWithMenuItem = nil then
      DataGridSearchPanelBeginsWithMenuItem := TDataGridEhMenuItem.Create(Screen);
    mi := DataGridSearchPanelBeginsWithMenuItem;
    mi.Grid := ADataGrid;
    mi.Text := EhLibLanguageConsts.BeginsWithEh;
    mi.OnClick := MenuSearchPanelOptionsClick;
    mi.Enabled := True;
    mi.Tag := 1;
    PopupMenu.AddObject(mi);
  end;

  if PopupMenu.ChildrenCount > 0 then
  begin
    if DataGridCloseMenuItem = nil then
      DataGridCloseMenuItem := TDataGridEhMenuItem.Create(Screen);
    mi := DataGridCloseMenuItem;
    mi.Grid := ADataGrid;
    mi.Text := EhLibLanguageConsts.CloseInBracketsEh;
    mi.OnClick := MenuSearchPanelOptionsClick;
    mi.Enabled := True;
    mi.Tag := 1;
    PopupMenu.AddObject(mi);
  end;

end;

procedure TDataGridCenterEh.MenuSearchPanelOptionsClick(Sender: TObject);
begin
end;

procedure TDataGridCenterEh.ApplyTitleFilter(AGrid: TCustomGridEh);
begin
  DefaultApplyTitleFilter(AGrid);
end;

function TDataGridCenterEh.CreateFilterItemBinOperNode(AGrid: TCustomGridEh; AFilterItem: TSTColumnFilterEh): TTableViewBinaryOperationFilterNodeEh;

  function GetTableFilterOperatorByGridFilterOperator(AGridOperator: TSTFilterOperatorEh): TTableViewComparisonOperatorEh;
  begin
    case AGridOperator of
      TSTFilterOperatorEh.foEqual:
        Result := TTableViewComparisonOperatorEh.opEqual;
      TSTFilterOperatorEh.foNotEqual:
        Result := TTableViewComparisonOperatorEh.opNotEqual;
      TSTFilterOperatorEh.foGreaterThan:
        Result := TTableViewComparisonOperatorEh.opGreaterThan;
      TSTFilterOperatorEh.foLessThan:
        Result := TTableViewComparisonOperatorEh.opLessThan;
      TSTFilterOperatorEh.foGreaterOrEqual:
        Result := TTableViewComparisonOperatorEh.opGreaterOrEqual;
      TSTFilterOperatorEh.foLessOrEqual:
        Result := TTableViewComparisonOperatorEh.opLessOrEqual;
      TSTFilterOperatorEh.foLike:
        Result := TTableViewComparisonOperatorEh.opLike;
      TSTFilterOperatorEh.foIn:
        Result := TTableViewComparisonOperatorEh.opInList;
      TSTFilterOperatorEh.foNotIn:
        Result := TTableViewComparisonOperatorEh.opNotInList;
      TSTFilterOperatorEh.foNull:
        Result := TTableViewComparisonOperatorEh.opIsNull;
    else
      raise Exception.Create('TDataGridEhCenter.DefaultApplyTitleFilter TSTFilterOperatorEh is not Supported');
    end;
  end;

var
  BinOperator: TTableViewComparisonOperatorEh;
  BinOperandField: String;
  BinOperand2: TValue;
  BinOperand1Node: TTableViewFieldValueFilterNodeEh;
  BinOperand2Node: TTableViewConstValueFilterNodeEh;
begin

  BinOperator := GetTableFilterOperatorByGridFilterOperator(AFilterItem.Expression.Operator1);
  BinOperandField := TColumnTitleEh(AFilterItem.ColumnTitle).Column.FieldName;
  BinOperand2 := AFilterItem.Expression.Operand1;

  BinOperand1Node := TTableViewFieldValueFilterNodeEh.Create(BinOperandField);
  BinOperand2Node :=  TTableViewConstValueFilterNodeEh.Create(BinOperand2);

  Result := TTableViewBinaryOperationFilterNodeEh.Create(BinOperand1Node, BinOperand2Node, BinOperator);
end;

procedure TDataGridCenterEh.DefaultApplyTitleFilter(AGrid: TCustomGridEh);

  function GetTableFilterOperatorByGridFilterOperator(AGridOperator: TSTFilterOperatorEh): TTableViewComparisonOperatorEh;
  begin
    case AGridOperator of
      TSTFilterOperatorEh.foEqual:
        Result := TTableViewComparisonOperatorEh.opEqual;
      TSTFilterOperatorEh.foNotEqual:
        Result := TTableViewComparisonOperatorEh.opNotEqual;
      TSTFilterOperatorEh.foGreaterThan:
        Result := TTableViewComparisonOperatorEh.opGreaterThan;
      TSTFilterOperatorEh.foLessThan:
        Result := TTableViewComparisonOperatorEh.opLessThan;
      TSTFilterOperatorEh.foGreaterOrEqual:
        Result := TTableViewComparisonOperatorEh.opGreaterOrEqual;
      TSTFilterOperatorEh.foLessOrEqual:
        Result := TTableViewComparisonOperatorEh.opLessOrEqual;
      TSTFilterOperatorEh.foLike:
        Result := TTableViewComparisonOperatorEh.opLike;
      TSTFilterOperatorEh.foIn:
        Result := TTableViewComparisonOperatorEh.opInList;
      TSTFilterOperatorEh.foNotIn:
        Result := TTableViewComparisonOperatorEh.opNotInList;
      TSTFilterOperatorEh.foNull:
        Result := TTableViewComparisonOperatorEh.opIsNull;
    else
      raise Exception.Create('TDataGridEhCenter.DefaultApplyTitleFilter TSTFilterOperatorEh is not Supported');
    end;
  end;

var
  I: Integer;
  ADataGrid: TCustomDataGridEhCrack;
  FilterItem: TSTColumnFilterEh;
  BinOperNode: TTableViewBinaryOperationFilterNodeEh;

  ListOperation: TTableViewListOperationFilterNodeEh;
begin
  ADataGrid := TCustomDataGridEhCrack(AGrid);

  ListOperation := nil;

  for I := 0 to ADataGrid.Columns.Count - 1 do
  begin
    FilterItem := ADataGrid.Columns[I].Title.FilterItem;
    if FilterItem.HasValue then
    begin
      if ListOperation = nil  then
        ListOperation := TTableViewListOperationFilterNodeEh.Create(TTableViewLogicalOperationEh.opAND);

      BinOperNode := CreateFilterItemBinOperNode(AGrid, FilterItem);
      ListOperation.AddNode(BinOperNode);
    end;
  end;

  ADataGrid.TableView.FilteredRowList.Filter.RootNode := ListOperation;
end;

procedure InitModule;
begin
  FDataGridEhCenter := TDataGridCenterEh.Create(nil);
end;

procedure FinalizeModule;
begin
  FreeAndNil(FDataGridEhCenter);
end;

{ TDataGridEhMenuItem }

constructor TDataGridEhMenuItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TDataGridEhMenuItem.Destroy;
begin
  inherited Destroy;
end;

initialization
  InitModule;
finalization
  FinalizeModule;
end.
