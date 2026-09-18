{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{           EhLibFmx.CustomizeColumnsDialog             }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.CustomizeColumnsDialog;

interface

{$SCOPEDENUMS ON}

{$REGION 'uses'}
uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  Contnrs, Data.DB, FMX.Objects, System.Math,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.DialogService,
  Generics.Collections, Rtti,
  MemTableDataEh, MemTableEh,
  EhLibUtils, DBUtilsEh,
  EhLib.TableLink.Db,
  EhLib.TableLink.TypedLists,
  EhLibFmx.Types,
  EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.LaPanels,
  EhLibFmx.LaObjects,
  EhLibFmx.LaControls,
  EhLibFmx.LaGridPanels,
  EhLibFmx.ImageReses,

  EhLibFmx.DataAxisGrid.CustomizeFieldBarsDialog,

  EhLibFmx.Grids,
  EhLibFmx.Grid.Types,
  EhLibFmx.DataAxisGrids,
  EhLibFmx.CustomDataGrids,
  EhLibFmx.DataGrid.Columns,
  EhLibFmx.DataGrid.Rows,
  EhLibFmx.DataGrid.ComplexTitles,
  EhLibFmx.DataGrid.DataCells,
  EhLibFmx.DataGrid.Footers,
  EhLibFmx.DataGrids,

  EhLibFmx.ToolControls, EhLibFmx.DataGrid.SearchPanels
  ;
{$ENDREGION 'uses'}

type
  TDataGridEhCustomizeColumnsDialog = class(TCustomizeFieldBarsDialogEh)
  private
    function GetDataGrid: TCustomDataGridEh;

  protected

  public
    constructor Create(AOwner: TComponent); override;

    function AllowResize(): Boolean; override;
    function AllowMove(): Boolean; override;

    procedure GetInitColumnsList(ADataGrid: TCustomDataAxisGridEh; AColInfoRoot: TColInfoEh); override;
    procedure AssignBackColumnSettings(AxisGrid: TCustomDataAxisGridEh); override;

    property DataGrid: TCustomDataGridEh read GetDataGrid;
  end;

function ShowDataGridEhCustomizeColumnsDialog(DataGrid: TCustomDataGridEh; var FormSize: TSize; CustomizeColumnsDialogClass: TFormClass = nil): Boolean;

implementation

function ShowDataGridEhCustomizeColumnsDialog(DataGrid: TCustomDataGridEh;
  var FormSize: TSize; CustomizeColumnsDialogClass: TFormClass = nil): Boolean;
var
  CustomizeColumnsDialog: TDataGridEhCustomizeColumnsDialog;
begin
  if (CustomizeColumnsDialogClass = nil) then
    CustomizeColumnsDialogClass := TDataGridEhCustomizeColumnsDialog;

  CustomizeColumnsDialog := CustomizeColumnsDialogClass.Create(Application) as TDataGridEhCustomizeColumnsDialog;

  CustomizeColumnsDialog.InitDialog(DataGrid, FormSize);
  Result := CustomizeColumnsDialog.ShowModal = mrOk;
  FormSize := CustomizeColumnsDialog.FormSize;

  CustomizeColumnsDialog.Free;
end;

{ TDataGridEhCustomizeColumnsDialog }

constructor TDataGridEhCustomizeColumnsDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

function TDataGridEhCustomizeColumnsDialog.GetDataGrid: TCustomDataGridEh;
begin
  Result := TCustomDataGridEh(inherited DataGrid);
end;

procedure TDataGridEhCustomizeColumnsDialog.GetInitColumnsList(ADataGrid: TCustomDataAxisGridEh;
  AColInfoRoot: TColInfoEh);
var
  I: Integer;
  ColInfo: TColInfoEh;
  Column: TDataGridBaseColumnEh;

  procedure FillColInfoFromComplexTitleNode(ParentNode: TDataGridComplexTitleTreeNodeEh; ParentColInfo: TColInfoEh);
  var
    I: Integer;
    ChildNode: TDataGridComplexTitleTreeNodeEh;
    Column: TDataGridBaseColumnEh;
  begin
    for I := 0 to ParentNode.Count - 1 do
    begin
      ChildNode := ParentNode.Items[I];

      ColInfo := TColInfoEh.Create(ParentColInfo);
      ColInfo.RefCol := ChildNode.NodeObject;
      if ColInfo.RefCol is TDataGridBaseColumnEh then
      begin
        Column := TDataGridBaseColumnEh(ColInfo.RefCol);
        ColInfo.ColWidth := Round(Column.Width);
        ColInfo.ColVisible := Column.Visible;
      end;
      ParentColInfo.AddObject(ColInfo);

      if ChildNode.Count > 0 then
        FillColInfoFromComplexTitleNode(ChildNode, ColInfo);
    end;
  end;

begin
  ColInfoRoot.DeleteChildren;

  if DataGrid.Title.IsComplexTitle = True then
  begin
    FillColInfoFromComplexTitleNode(DataGrid.Title.ComplexTitleTree.RootNode, ColInfoRoot);
  end else
  begin
    for I := 0 to DataGrid.DisplayColumns.Count-1 do
    begin
      Column := DataGrid.DisplayColumns[I];
      ColInfo := TColInfoEh.Create(ColInfoRoot);
      ColInfo.RefCol := Column;
      ColInfo.ColWidth := Round(Column.Width);
      ColInfo.ColVisible := Column.Visible;
      ColInfoRoot.AddObject(ColInfo);
    end;
  end;
end;

procedure TDataGridEhCustomizeColumnsDialog.AssignBackColumnSettings(AxisGrid: TCustomDataAxisGridEh);

  procedure SetColInfoChildren(ColInfo: TColInfoEh);
  var
    I: Integer;
    ColInfoChild: TColInfoEh;
    Col: TDataGridBaseColumnEh;
  begin
    for I := 0 to ColInfo.ChildrenCount - 1 do
    begin
      ColInfoChild := ColInfo.Children[I] as TColInfoEh;
      if ColInfoChild.RefCol is TDataGridBaseColumnEh then
      begin
        Col := TDataGridBaseColumnEh(ColInfoChild.RefCol);
        Col.Visible := ColInfoChild.ColVisible;
        Col.Width := ColInfoChild.ColWidth;
      end else
      begin
        SetColInfoChildren(ColInfoChild);
      end;
    end;
  end;

  procedure SetColOrders(TitleNode: TDataGridComplexTitleTreeNodeEh; ColInfo: TColInfoEh);
  var
    ColOrderList: TList<TDataGridBaseColumnEh>;
    TitleNodeList: TList<TDataGridComplexTitleTreeNodeEh>;
    I: Integer;
    ColInfoChild: TColInfoEh;
    ChildTitleNode: TDataGridComplexTitleTreeNodeEh;
  begin
    if (DataGrid.Title.IsComplexTitle = False) and (ColInfo = ColInfoRoot) then
    begin
      ColOrderList := TList<TDataGridBaseColumnEh>.Create();
      try
        for I := 0 to ColInfo.ChildrenCount - 1 do
        begin
          ColInfoChild := ColInfo.Children[I] as TColInfoEh;
          if ColInfoChild.RefCol is TDataGridBaseColumnEh then
            ColOrderList.Add(TDataGridBaseColumnEh(ColInfoChild.RefCol));
        end;

        DataGrid.DisplayColumns.SetColumnsOrder(ColOrderList);
      finally
        ColOrderList.Free;
      end;
    end else
    begin

      TitleNodeList := TList<TDataGridComplexTitleTreeNodeEh>.Create();
      try

        for I := 0 to ColInfo.ChildrenCount - 1 do
        begin
          ColInfoChild := ColInfo.Children[I] as TColInfoEh;
          if ColInfoChild.RefCol is TDataGridBaseColumnEh then
          begin
            ChildTitleNode := TDataGridBaseColumnEh(ColInfoChild.RefCol).Title.ComplexTitleNode;
            TitleNodeList.Add(ChildTitleNode);
          end else if ColInfoChild.RefCol is TDataGridSuperTitleEh then
          begin
            ChildTitleNode := TDataGridSuperTitleEh(ColInfoChild.RefCol).ComplexTitleNode;
            TitleNodeList.Add(ChildTitleNode);
            SetColOrders(ChildTitleNode, ColInfoChild);
          end
          else
            raise Exception.Create('TDataGridEhCustomizeColumnsDialog.AssignBackColumnSettings: Unexpected type of ColInfoChild.RefCol');
        end;

        TitleNode.SetItemsOrder(TitleNodeList.ToArray);
      finally
        TitleNodeList.Free;
      end;
    end;
  end;

var
  ADataGrid: TCustomDataGridEh;
begin
  ADataGrid := AxisGrid as TCustomDataGridEh;

  ADataGrid.Columns.BeginUpdate;
  try
    SetColInfoChildren(ColInfoRoot);
    SetColOrders(DataGrid.Title.ComplexTitleTree.RootNode, ColInfoRoot);
  finally
    ADataGrid.Columns.EndUpdate;
  end;

end;

function TDataGridEhCustomizeColumnsDialog.AllowResize: Boolean;
begin
  Result := DataGrid.ColumnOptions.AllowResize;
end;

function TDataGridEhCustomizeColumnsDialog.AllowMove: Boolean;
begin
  Result := DataGrid.ColumnOptions.AllowMove;
end;

end.
