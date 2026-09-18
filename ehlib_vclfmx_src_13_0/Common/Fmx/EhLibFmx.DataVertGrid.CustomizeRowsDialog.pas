{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{           EhLibFmx.CustomizeColumnsDialog             }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataVertGrid.CustomizeRowsDialog;

interface

{$SCOPEDENUMS ON}

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
  EhLibFmx.CustomDataVertGrids,
  EhLibFmx.DataVertGrid.Columns,
  EhLibFmx.DataVertGrid.Rows,
  EhLibFmx.DataVertGrids
  ;

type
  TDataVertGridEhCustomizeRowsDialog = class(TCustomizeFieldBarsDialogEh)
  private
    function GetDataGrid: TCustomDataVertGridEh;

  protected
    procedure ResourceLanguageChanged; override;

  public
    constructor Create(AOwner: TComponent); override;

    function AllowResize(): Boolean; override;
    function AllowMove(): Boolean; override;

    procedure GetInitColumnsList(ADataGrid: TCustomDataAxisGridEh; AColInfoRoot: TColInfoEh); override;
    procedure AssignBackColumnSettings(AxisGrid: TCustomDataAxisGridEh); override;

    property DataGrid: TCustomDataVertGridEh read GetDataGrid;
  end;

function ShowDataVertGridEhCustomizeRowsDialog(DataGrid: TCustomDataVertGridEh; var FormSize: TSize; CustomizeColumnsDialogClass: TFormClass = nil): Boolean;

implementation

function ShowDataVertGridEhCustomizeRowsDialog(DataGrid: TCustomDataVertGridEh;
  var FormSize: TSize; CustomizeColumnsDialogClass: TFormClass = nil): Boolean;
var
  CustomizeColumnsDialog: TDataVertGridEhCustomizeRowsDialog;
begin
  if (CustomizeColumnsDialogClass = nil) then
    CustomizeColumnsDialogClass := TDataVertGridEhCustomizeRowsDialog;

  CustomizeColumnsDialog := CustomizeColumnsDialogClass.Create(Application) as TDataVertGridEhCustomizeRowsDialog;

  CustomizeColumnsDialog.InitDialog(DataGrid, FormSize);
  Result := CustomizeColumnsDialog.ShowModal = mrOk;
  FormSize := CustomizeColumnsDialog.FormSize;

  CustomizeColumnsDialog.Free;
end;

{ TDataGridEhCustomizeColumnsDialog }

constructor TDataVertGridEhCustomizeRowsDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

function TDataVertGridEhCustomizeRowsDialog.GetDataGrid: TCustomDataVertGridEh;
begin
  Result := TCustomDataVertGridEh(inherited DataGrid);
end;

procedure TDataVertGridEhCustomizeRowsDialog.ResourceLanguageChanged;
begin
  inherited ResourceLanguageChanged;

  Caption := 'Rows setup';
  Label1.Text := 'Visible rows';
  Label2.Text := 'Hidden rows';
end;

procedure TDataVertGridEhCustomizeRowsDialog.GetInitColumnsList(ADataGrid: TCustomDataAxisGridEh;
  AColInfoRoot: TColInfoEh);
var
  I: Integer;
  ColInfo: TColInfoEh;
  Row: TDataVertGridBaseRowEh;
begin
  ColInfoRoot.DeleteChildren;

  for I := 0 to DataGrid.DisplayRows.Count-1 do
  begin
    Row := DataGrid.DisplayRows[I];
    ColInfo := TColInfoEh.Create(ColInfoRoot);
    ColInfo.RefCol := Row;
    ColInfo.ColWidth := 0;
    ColInfo.ColVisible := Row.Visible;
    ColInfoRoot.AddObject(ColInfo);
  end;
end;

procedure TDataVertGridEhCustomizeRowsDialog.AssignBackColumnSettings(AxisGrid: TCustomDataAxisGridEh);

  procedure SetColInfoChildren(ColInfo: TColInfoEh);
  var
    I: Integer;
    ColInfoChild: TColInfoEh;
    Col: TDataVertGridBaseRowEh;
  begin
    for I := 0 to ColInfo.ChildrenCount - 1 do
    begin
      ColInfoChild := ColInfo.Children[I] as TColInfoEh;
      if ColInfoChild.RefCol is TDataVertGridBaseRowEh then
      begin
        Col := TDataVertGridBaseRowEh(ColInfoChild.RefCol);
        Col.Visible := ColInfoChild.ColVisible;
        Col.Width := ColInfoChild.ColWidth;
      end else
      begin
        SetColInfoChildren(ColInfoChild);
      end;
    end;
  end;

  procedure SetColOrders(ColInfo: TColInfoEh);
  var
    ColOrderList: TList<TDataVertGridBaseRowEh>;
    I: Integer;
    ColInfoChild: TColInfoEh;
  begin
    if ColInfo = ColInfoRoot then
    begin
      ColOrderList := TList<TDataVertGridBaseRowEh>.Create();
      try
        for I := 0 to ColInfo.ChildrenCount - 1 do
        begin
          ColInfoChild := ColInfo.Children[I] as TColInfoEh;
          if ColInfoChild.RefCol is TDataVertGridBaseRowEh then
            ColOrderList.Add(TDataVertGridBaseRowEh(ColInfoChild.RefCol));
        end;

        DataGrid.DisplayRows.SetRowsOrder(ColOrderList);
      finally
        ColOrderList.Free;
      end;
    end
  end;

var
  ADataGrid: TCustomDataVertGridEh;
begin
  ADataGrid := AxisGrid as TCustomDataVertGridEh;

  ADataGrid.Rows.BeginUpdate;
  try
    SetColInfoChildren(ColInfoRoot);
    SetColOrders(ColInfoRoot);
  finally
    ADataGrid.Rows.EndUpdate;
  end;

end;

function TDataVertGridEhCustomizeRowsDialog.AllowResize: Boolean;
begin
  Result := False;
end;

function TDataVertGridEhCustomizeRowsDialog.AllowMove: Boolean;
begin
  Result := True;
end;

end.
