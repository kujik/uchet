{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{           EhLibFmx.DataGrid.GridManagers              }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataVertGrid.GridManagers;

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

  EhLibFmx.DataVertGrid.Rows,
  EhLibFmx.DataVertGrid.RowsHeader
  ;

type
  TDataVertGridCenterEh = class;

{ TDataVertGridEhMenuItem }

  TDataVertGridEhMenuItem = class(TMenuItem)
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

{ TDataVertGridCenterEh }

  TDataVertGridCenterEh = class(TComponent)
  private
    FTryUseViewScroll: Boolean;
    FGrids: TObjectListEh;
    FStyleResource: TDictionary<string, TControl>;
    FGridPopupMenu: TPopupMenu;

    FHideColumnMenuItem: TMenuItem;
    FCustomizeColumnsMenuItem: TMenuItem;
    FCustomizeColumnsDialogFormClass: TFormClass;
    FDataGridCustomizeColumnsDialogSize: TSize;

    function GetBitmapStyleResource(ResourceName: String): TControl;
    function LoadBitmapStyleResource(ResourceName: String): TControl;

    procedure AddHideColumnsMenuItem(PopupMenu: TComposedPopupMenu; Column: TDataVertGridBaseRowEh);
    procedure AddCustomizeColumnsMenuItem(PopupMenu: TComposedPopupMenu; Column: TDataVertGridBaseRowEh);
    procedure MenuItemCustomizeColumnsClick(Sender: TObject);

  protected

    function GridInChangeNotification(Grid: TCustomGridEh): Boolean;

    procedure HideColumnMenuItemClick(Sender: TObject);

    procedure Changed;

    procedure AddItemsFromPopupMenu(SourcePopupMenu: TPopupMenu; TargetPopupMenu: TPopupMenu);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    class function DefaultGridManager: TDataVertGridCenterEh;

    procedure AddChangeNotification(Grid: TCustomGridEh);
    procedure RemoveChangeNotification(Grid: TCustomGridEh);

    function ShowCustomizeColumnsDialog(Sender: TCustomGridEh): Boolean; virtual;

    procedure BuildTitleCellPopupMenu(Params: TDataVertGridRowHeaderCellComposeContextMenuParamsEh); virtual;

    property CustomizeColumnsDialogFormClass: TFormClass read FCustomizeColumnsDialogFormClass write FCustomizeColumnsDialogFormClass;
    property DataGridCustomizeColumnsDialogSize: TSize read FDataGridCustomizeColumnsDialogSize write FDataGridCustomizeColumnsDialogSize;

    property BitmapResource[ResourceName: String]: TControl read GetBitmapStyleResource;

  end;

function SetDataGridCenterEh(NewGridCenter: TDataVertGridCenterEh): TDataVertGridCenterEh;

implementation

uses
  System.StrUtils,
  EhLibLangConsts,
  EhLibFmx.CustomDataVertGrids,
  EhLibFmx.DataVertGrid.CustomizeRowsDialog;

type
  TCustomDataVertGridEhCrack = class(TCustomDataVertGridEh);

{ TDataGridEhCenter }

var
  FDataGridEhCenter: TDataVertGridCenterEh = nil;

function SetDataGridCenterEh(NewGridCenter: TDataVertGridCenterEh): TDataVertGridCenterEh;
begin
  Result := FDataGridEhCenter;
  FDataGridEhCenter := NewGridCenter;
  FDataGridEhCenter.Changed;
end;

constructor TDataVertGridCenterEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FGrids := TObjectListEh.Create;
  FTryUseViewScroll := True;
  FStyleResource := TDictionary<string, TControl>.Create;
end;

destructor TDataVertGridCenterEh.Destroy;
var
  i: Integer;
  Pair: TPair<string, TControl>;
begin
  for i := FGrids.Count-1 downto 0 do
    TCustomDataVertGridEh(FGrids[i]).Center := nil;

  for Pair in FStyleResource do
    Pair.Value.Free;
  FreeAndNil(FStyleResource);

  FreeAndNil(FGridPopupMenu);
  FreeAndNil(FGrids);
  inherited Destroy;
end;

class function TDataVertGridCenterEh.DefaultGridManager: TDataVertGridCenterEh;
begin
  Result := FDataGridEhCenter;
end;

procedure TDataVertGridCenterEh.Changed;
begin
end;

function TDataVertGridCenterEh.GridInChangeNotification(Grid: TCustomGridEh): Boolean;
begin
  Result := (FGrids.IndexOf(Grid) >= 0);
end;

procedure TDataVertGridCenterEh.AddChangeNotification(Grid: TCustomGridEh);
begin
  if not GridInChangeNotification(Grid) then
    FGrids.Add(Grid);
end;

procedure TDataVertGridCenterEh.RemoveChangeNotification(Grid: TCustomGridEh);
begin
  FGrids.Remove(Grid);
end;

procedure TDataVertGridCenterEh.AddItemsFromPopupMenu(SourcePopupMenu: TPopupMenu; TargetPopupMenu: TPopupMenu);
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

procedure TDataVertGridCenterEh.MenuItemCustomizeColumnsClick(Sender: TObject);
var
  Grid: TCustomDataVertGridEhCrack;
  Column: TDataVertGridBaseRowEh;
begin
  Column := (Sender as TMenuItem).TagObject as TDataVertGridBaseRowEh;
  Grid := TCustomDataVertGridEhCrack(Column.Grid);
  Grid.ShowCustomizeRowsDialog();
end;

procedure TDataVertGridCenterEh.BuildTitleCellPopupMenu(Params: TDataVertGridRowHeaderCellComposeContextMenuParamsEh);
var
  Grid: TCustomDataVertGridEh;
  Mi: TMenuItem;
  AColumnTitle: TDataVertGridRowHeaderEh;
begin
  Grid := TCustomDataVertGridEh(Params.Grid);
  AColumnTitle := Params.Row.Header;
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
    AddHideColumnsMenuItem(Params.ComposedPopupMenu, AColumnTitle.Row);
    AddCustomizeColumnsMenuItem(Params.ComposedPopupMenu, AColumnTitle.Row);
  end
end;

function TDataVertGridCenterEh.ShowCustomizeColumnsDialog(Sender: TCustomGridEh): Boolean;
begin
  Result := ShowDataVertGridEhCustomizeRowsDialog(TCustomDataVertGridEh(Sender),
    FDataGridCustomizeColumnsDialogSize, CustomizeColumnsDialogFormClass);
end;

procedure TDataVertGridCenterEh.AddCustomizeColumnsMenuItem(PopupMenu: TComposedPopupMenu; Column: TDataVertGridBaseRowEh);
var
  Cmi: TMenuItem;
begin
  if (FCustomizeColumnsMenuItem = nil) then
  begin
    FCustomizeColumnsMenuItem := TMenuItem.Create(Self);
    FCustomizeColumnsMenuItem.OnClick := MenuItemCustomizeColumnsClick;
  end;
  Cmi := FCustomizeColumnsMenuItem;
  if (Cmi.Parent <> nil) then
    Cmi.Parent.RemoveObject(Cmi);
  Cmi.Text := 'Customize rows ...';
  Cmi.Enabled := True;
  Cmi.TagObject := Column;
  PopupMenu.AddItem(Cmi);
end;

procedure TDataVertGridCenterEh.AddHideColumnsMenuItem(PopupMenu: TComposedPopupMenu; Column: TDataVertGridBaseRowEh);
var
  Cmi: TMenuItem;
begin
  if (FHideColumnMenuItem = nil) then
  begin
    FHideColumnMenuItem := TMenuItem.Create(Self);
    FHideColumnMenuItem.OnClick := HideColumnMenuItemClick;
  end;
  Cmi := FHideColumnMenuItem;
  if (Cmi.Parent <> nil) then
    Cmi.Parent.RemoveObject(Cmi);
    Cmi.Text := 'Hide row';
  Cmi.Enabled := True;
  Cmi.TagObject := Column;
  PopupMenu.AddItem(Cmi);
end;

procedure TDataVertGridCenterEh.HideColumnMenuItemClick(Sender: TObject);
var
  MenuItem: TMenuItem;
  Column: TDataVertGridBaseRowEh;
begin
  MenuItem := Sender as TMenuItem;
  Column := MenuItem.TagObject as TDataVertGridBaseRowEh;
  Column.Visible := False;
end;

function TDataVertGridCenterEh.GetBitmapStyleResource(ResourceName: String): TControl;
begin
  if not FStyleResource.TryGetValue(ResourceName, Result) then
  begin
    Result := LoadBitmapStyleResource(ResourceName);
  end;
end;

function TDataVertGridCenterEh.LoadBitmapStyleResource(ResourceName: String): TControl;
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

procedure InitModule;
begin
  FDataGridEhCenter := TDataVertGridCenterEh.Create(nil);
end;

procedure FinalizeModule;
begin
  FreeAndNil(FDataGridEhCenter);
end;

{ TDataVertGridEhMenuItem }

constructor TDataVertGridEhMenuItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TDataVertGridEhMenuItem.Destroy;
begin
  inherited Destroy;
end;

initialization
  InitModule;
finalization
  FinalizeModule;
end.
