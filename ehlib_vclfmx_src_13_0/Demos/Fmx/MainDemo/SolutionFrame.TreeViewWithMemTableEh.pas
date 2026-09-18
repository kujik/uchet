unit SolutionFrame.TreeViewWithMemTableEh;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  EhLibFmx.Api, EhLibRtl.Api,
  EhLibFmx.ToolControls, EhLibFmx.Grids, EhLibFmx.DataAxisGrids, EhLibFmx.CustomDataGrids, EhLibFmx.DataGrids,
  FMX.Controls.Presentation, MemTableDataEh, Data.DB, EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.DataGrid.Columns, MemTableEh;

type
  TfrTreeViewWithMemTableEh = class(TFrame)
    Panel1: TPanel;
    DataGridEh1: TDataGridEh;
    MemTableEh1: TMemTableEh;
    MemTableEh1ExpCount: TAggregateField;
    DataGridEh1IDColumn1: TDataGridStringColumnEh;
    DataGridEh1ID_PARENTColumn1: TDataGridStringColumnEh;
    DataGridEh1NODNAMEColumn1: TDataGridStringColumnEh;
    DataGridEh1ExpandedColumn1: TDataGridStringColumnEh;
    DataGridEh1VisibleColumn1: TDataGridStringColumnEh;
    procedure DataGridEh1GetDataTreeViewAreaParams(Sender: TObject;
      Params: TDataGridDataTreeViewAreaParamsEh);
    procedure DataGridEh1SetDataTreeSignState(Sender: TObject; Params: TDataGridSetDataTreeSignStateParamsEh);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

procedure TfrTreeViewWithMemTableEh.DataGridEh1GetDataTreeViewAreaParams(Sender: TObject;
  Params: TDataGridDataTreeViewAreaParamsEh);
var
  Bookmark: TBookmark;
  RecView: TMemRecViewEh;
begin
  if Params.Row = nil then Exit;
  if Params.Column.VisibleIndex > 0 then Exit;

  Bookmark := TDataSetRecLinkEh(Params.Row.SourceRowLink).DataBookmark;
  RecView := MemTableEh1.BookmarkToRecView(Bookmark);

  Params.TreeAreaVisible := True;
  Params.Level := RecView.NodeLevel - 1;
  Params.SignVisible := RecView.NodeHasChildren;
  if RecView.NodeExpanded then
    Params.SignState := TTreeSignStateEh.Expanded
  else
    Params.SignState := TTreeSignStateEh.Collapsed;
end;

procedure TfrTreeViewWithMemTableEh.DataGridEh1SetDataTreeSignState(Sender: TObject;
  Params: TDataGridSetDataTreeSignStateParamsEh);
var
  Bookmark: TBookmark;
  RecView: TMemRecViewEh;
begin
  if Params.Row = nil then Exit;
  if Params.Column.VisibleIndex > 0 then Exit;

  Bookmark := TDataSetRecLinkEh(Params.Row.SourceRowLink).DataBookmark;
  RecView := MemTableEh1.BookmarkToRecView(Bookmark);

  if Params.SignState = TTreeSignStateEh.Expanded then
    RecView.NodeExpanded := True
  else
    RecView.NodeExpanded := False;
end;

end.
