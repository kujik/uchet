{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{           EhLibFmx.CustomizeColumnsDialog             }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataAxisGrid.CustomizeFieldBarsDialog;

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

type
  TColInfoEh = class;

  TCustomizeFieldBarsDialogEh = class(TForm)
    MemTableEh1: TMemTableEh;
    DataSource1: TDataSource;
    MemTableEh2: TMemTableEh;
    DataSource2: TDataSource;
    Panel1: TPanel;
    PanelVisibleColumns: TPanel;
    PanelButtons: TPanel;
    PanelHiddenColumns: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    bCancel: TButton;
    bOk: TButton;
    bSetWidth: TSpeedButton;
    bMoveUp: TSpeedButton;
    bMoveDown: TSpeedButton;
    bHide: TSpeedButton;
    bShow: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure bSetWidthClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure bHideClick(Sender: TObject);
    procedure bShowClick(Sender: TObject);
    procedure bMoveDownClick(Sender: TObject);
    procedure bMoveUpClick(Sender: TObject);
    procedure DataGridLayoutColumnEh1CreateLayoutContent(Sender: TObject;
      Params: TDataGridCreateDataCellContentParamsEh);
    procedure DataGridLayoutColumnEh1InitCellContent(Sender: TObject; Params: TDataGridInitDataCellContentParamsEh);
    procedure DataGridStringColumnEh2DataCellGetValue(Sender: TObject; Params: TDataGridDataCellGetValueParamsEh);
  private
    FDataGrid: TCustomDataAxisGridEh;
  protected
    procedure ResourceLanguageChanged; virtual;
    procedure SetNewColsWidth(NewColsWidth: Integer); virtual;

    procedure GetInitColumnsList(ADataGrid: TCustomDataAxisGridEh; AColInfoRoot: TColInfoEh); virtual;
    function GetColumnName(Col: TFieldBarEh): String; virtual;
  public
    ChildrenRightToLeft: Boolean;
    FormSize: TSize;
    Activated: Boolean;

    ColInfoRoot: TColInfoEh;

    VisibleColumnsTableLink: TListTableLinkEh;
    VisibleColumnsList: TList<TColInfoEh>;
    HiddenColumnsTableLink: TListTableLinkEh;
    HiddenColumnsList: TList<TColInfoEh>;

    GridVisibleColumns: TDataGridEh;
    DataGridStringColumnEh1: TDataGridStringColumnEh;
    DataGridLayoutColumnEh1: TDataGridLayoutColumnEh;
    VisGridColumnWidth: TDataGridStringColumnEh;

    GridHiddenColumns: TDataGridEh;
    DataGridStringColumnEh3: TDataGridStringColumnEh;
    DataGridLayoutColumnEh2: TDataGridLayoutColumnEh;

    function AllowResize(): Boolean; virtual;
    function AllowMove(): Boolean; virtual;

    procedure InitDialog(ADataGrid: TCustomDataAxisGridEh; AFormSize: TSize); virtual;
    procedure AssignBackColumnSettings(AxisGrid: TCustomDataAxisGridEh); virtual;

    procedure FillVisibleColumnsList();
    procedure FillHiddenColumnsList();

    property DataGrid: TCustomDataAxisGridEh read FDataGrid;
  end;

{ TColInfoEh }

  TColInfoEh = class(TFmxObject)
  private
    FRefCol: TComponent;
    FColWidth: Integer;
    FColVisible: Boolean;
  published
    property RefCol: TComponent read FRefCol write FRefCol;
    property ColWidth: Integer read FColWidth write FColWidth;
    property ColVisible: Boolean read FColVisible write FColVisible;
  end;

var
  CustomizeFieldBarsDialogEh: TCustomizeFieldBarsDialogEh;

implementation

{$R *.fmx}

type
  TFieldBarEhCrack = class(TFieldBarEh);

type
 { TLaPropNameCellEh }

  TLaPropNameCellEh = class(TLaLayoutPanelEh)
  private
    FTreeSignExpanded: Boolean;
    FTreeSignVisible: Boolean;
    FTreeSignImage: TImage;
    FTreeSignPanel: TLaObjectEh;
    FIndentPanel: TLaObjectEh;
    FIndentLevel: Integer;
    FTextBlock: TLaTextBlockEh;
    procedure SetTreeSignExpanded(const Value: Boolean);
    procedure SetTreeSignVisible(const Value: Boolean);
    function GetOnTreeSignMouseDown: TControlMouseButtonEventEh;
    procedure SetOnTreeSignMouseDown(const Value: TControlMouseButtonEventEh);
    procedure SetIndentLevel(const Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure CreateLaPropNameControls();

    property TreeSignExpanded: Boolean read FTreeSignExpanded write SetTreeSignExpanded;
    property TreeSignVisible: Boolean read FTreeSignVisible write SetTreeSignVisible;
    property IndentLevel: Integer read FIndentLevel write SetIndentLevel;
    property OnTreeSignMouseDown: TControlMouseButtonEventEh read GetOnTreeSignMouseDown write SetOnTreeSignMouseDown;
    property TextBlock: TLaTextBlockEh read FTextBlock;
  end;

constructor TLaPropNameCellEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CreateLaPropNameControls();
end;

destructor TLaPropNameCellEh.Destroy;
begin

  inherited Destroy;
end;

function TLaPropNameCellEh.GetOnTreeSignMouseDown: TControlMouseButtonEventEh;
begin
  Result := FTreeSignPanel.OnMouseDown;
end;

procedure TLaPropNameCellEh.SetOnTreeSignMouseDown(const Value: TControlMouseButtonEventEh);
begin
  FTreeSignPanel.OnMouseDown := Value;
end;

procedure TLaPropNameCellEh.SetTreeSignExpanded(const Value: Boolean);
begin
  if FTreeSignExpanded <> Value then
  begin
    FTreeSignExpanded := Value;
    if FTreeSignExpanded then
      FTreeSignImage.MultiResBitmap := EhLibImageResources.ExpanderSignExpanded
    else
      FTreeSignImage.MultiResBitmap := EhLibImageResources.ExpanderSignCollapsed;
  end;
end;

procedure TLaPropNameCellEh.SetTreeSignVisible(const Value: Boolean);
begin
  if FTreeSignVisible <> Value then
  begin
    FTreeSignVisible := Value;
    FTreeSignImage.Visible := FTreeSignVisible;
  end;
end;

procedure TLaPropNameCellEh.SetIndentLevel(const Value: Integer);
begin
  if FIndentLevel <> Value then
  begin
    FIndentLevel := Value;
    FIndentPanel.Width := FIndentLevel * 14;
  end;
end;

procedure TLaPropNameCellEh.CreateLaPropNameControls();
begin
  with TLaGridPanelEh.CreateWith(Self, Self) do
  begin
    Margins.Rect := TRectF.Create(1, 2, 1, 2);

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Auto;
      Value := 0;
    end;

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Auto;
      Value := 0;
    end;

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Weight;
      Value := 1;
    end;

    
    with TLaLayoutPanelEh.CreateWith(RefSelf, RefSelf) do
    begin
      ControlCollection.AddControl(RefSelf, 0, -1);
      Width := 0;
      FIndentPanel := RefSelf;
    end;

    
    with TLaLayoutPanelEh.CreateWith(RefSelf, RefSelf) do
    begin
      ControlCollection.AddControl(RefSelf, 1, -1);
      Margins.Rect := TRectF.Create(2, 1, 2, 1);
      VertAlignment := TLaVertAlignmentEh.Center;
      Width := 10;
      Height := 14;
      FTreeSignPanel := RefSelf;
      HitTest := True;

      with TLaControlsGenericHelper.CreateControlWith<TImage>(RefSelf, RefSelf) do
      begin
        WrapMode := TImageWrapMode.Center;
        MultiResBitmap := nil;
        HitTest := False;
        Locked := True;
        MultiResBitmap := EhLibImageResources.ExpanderSignCollapsed;
        FTreeSignImage := TImage(RefSelf);
        FTreeSignImage.Visible := FTreeSignVisible;
      end;
    end;

    
    with TLaLayoutPanelEh.CreateWith(RefSelf, RefSelf) do
    begin
      ControlCollection.AddControl(RefSelf, 2, -1);

      FTextBlock := TLaTextBlockEh.CreateWith(RefSelf, RefSelf);
      FTextBlock.Padding.Rect := RectF(2, 0, 2, 1);
      FTextBlock.VertAlignment := TLaVertAlignmentEh.Center;
      FTextBlock.HorzAlignment := TLaHorzAlignmentEh.Left;
    end;
  end;
end;

{ TDataGridEhCustomizeColumnsDialog }

procedure TCustomizeFieldBarsDialogEh.AssignBackColumnSettings(AxisGrid: TCustomDataAxisGridEh);
begin
end;

procedure TCustomizeFieldBarsDialogEh.InitDialog(ADataGrid: TCustomDataAxisGridEh; AFormSize: TSize);
begin
  FDataGrid := ADataGrid;
  FormSize := AFormSize;
  if (FormSize.cx <> 0) and (FormSize.cy <> 0) then
  begin
    Width := FormSize.cx;
    Height := FormSize.cy;
  end;

  GetInitColumnsList(ADataGrid, ColInfoRoot);

  FillVisibleColumnsList();
  FillHiddenColumnsList();

  bSetWidth.Enabled := AllowResize();
  bMoveDown.Enabled := AllowMove();
  bMoveUp.Enabled := AllowMove();

  if bSetWidth.Enabled = False then
    VisGridColumnWidth.Visible := False
  else
    VisGridColumnWidth.Visible := True;
end;

function TCustomizeFieldBarsDialogEh.AllowResize: Boolean;
begin
  Result := False;
end;

function TCustomizeFieldBarsDialogEh.AllowMove: Boolean;
begin
  Result := False;
end;

procedure TCustomizeFieldBarsDialogEh.FillVisibleColumnsList();

  function IsColInfoHasVisibleCol(ColInfo: TColInfoEh): Boolean;
  var
    I: Integer;
    ChildColInfo: TColInfoEh;
  begin
    Result := False;
    if ColInfo.RefCol is TFieldBarEh then
    begin
      Result := ColInfo.ColVisible = True;
    end else
    begin
      for I := 0 to ColInfo.ChildrenCount - 1 do
      begin
        ChildColInfo := ColInfo.Children[I] as TColInfoEh;
        if IsColInfoHasVisibleCol(ChildColInfo) = True then
        begin
          Result := True;
          Break;
        end;
      end;
    end;
  end;

  procedure AddColInfoChildren(ColInfo: TColInfoEh);
  var
    I: Integer;
    ChildColInfo: TColInfoEh;
    IsColInfoInList: Boolean;
  begin

    for I := 0 to ColInfo.ChildrenCount - 1 do
    begin
      ChildColInfo := ColInfo.Children[I] as TColInfoEh;

      IsColInfoInList := IsColInfoHasVisibleCol(ChildColInfo);
      if IsColInfoInList = True then
        VisibleColumnsList.Add(ChildColInfo);

      if ChildColInfo.ChildrenCount > 0 then
        AddColInfoChildren(ChildColInfo);
    end;
  end;

var
  SrcColObject: TColInfoEh;
  SrcColObjectFound: Boolean;
  SrcRowIndex: Integer;
begin
  if GridVisibleColumns.CurrentRow <> nil then
  begin
    SrcColObject := GridVisibleColumns.CurrentRow.SourceObjectItem as TColInfoEh;
    SrcRowIndex := GridVisibleColumns.TableView.CurrentRowViewIndex;
  end else
  begin
    SrcColObject := nil;
    SrcRowIndex := GridVisibleColumns.TableView.CurrentRowViewIndex;
  end;

  VisibleColumnsList.Clear;
  AddColInfoChildren(ColInfoRoot);
  VisibleColumnsTableLink.SetList<TColInfoEh>(VisibleColumnsList);

  if SrcColObject <> nil then
  begin
    SrcColObjectFound := GridVisibleColumns.LocateRow(
      function(ADataRow: TDataGridRowEh): Boolean
      begin
        if ADataRow.SourceObjectItem = SrcColObject then
          Result := True
        else
          Result := False;
      end
    );

    if SrcColObjectFound = False then
    begin
      SrcRowIndex := System.Math.Min(SrcRowIndex, GridVisibleColumns.TableView.Rows.Count - 1);
      if SrcRowIndex >= 0 then
        GridVisibleColumns.TableView.CurrentRowViewIndex := SrcRowIndex;
    end;
  end;
end;

procedure TCustomizeFieldBarsDialogEh.FillHiddenColumnsList();

  function IsColInfoHasHiddenCol(ColInfo: TColInfoEh): Boolean;
  var
    I: Integer;
    ChildColInfo: TColInfoEh;
  begin
    Result := False;
    if ColInfo.RefCol is TFieldBarEh then
    begin
      Result := ColInfo.ColVisible = False;
    end else
    begin
      for I := 0 to ColInfo.ChildrenCount - 1 do
      begin
        ChildColInfo := ColInfo.Children[I] as TColInfoEh;
        if IsColInfoHasHiddenCol(ChildColInfo) = True then
        begin
          Result := True;
          Break;
        end;
      end;
    end;
  end;

  procedure AddColInfoChildren(ColInfo: TColInfoEh);
  var
    I: Integer;
    ChildColInfo: TColInfoEh;
    IsColInfoInList: Boolean;
  begin

    for I := 0 to ColInfo.ChildrenCount - 1 do
    begin
      ChildColInfo := ColInfo.Children[I] as TColInfoEh;

      IsColInfoInList := IsColInfoHasHiddenCol(ChildColInfo);
      if IsColInfoInList = True then
        HiddenColumnsList.Add(ChildColInfo);

      if ChildColInfo.ChildrenCount > 0 then
        AddColInfoChildren(ChildColInfo);
    end;
  end;

var
  SrcColObject: TColInfoEh;
  SrcColObjectFound: Boolean;
  SrcRowIndex: Integer;
begin
  if GridHiddenColumns.CurrentRow <> nil then
  begin
    SrcColObject := GridHiddenColumns.CurrentRow.SourceObjectItem as TColInfoEh;
    SrcRowIndex := GridHiddenColumns.TableView.CurrentRowViewIndex;
  end else
  begin
    SrcColObject := nil;
    SrcRowIndex := GridHiddenColumns.TableView.CurrentRowViewIndex;
  end;

  HiddenColumnsList.Clear;
  AddColInfoChildren(ColInfoRoot);
  HiddenColumnsTableLink.SetList<TColInfoEh>(HiddenColumnsList);

  if SrcColObject <> nil then
  begin
    SrcColObjectFound := GridHiddenColumns.LocateRow(
      function(ADataRow: TDataGridRowEh): Boolean
      begin
        if ADataRow.SourceObjectItem = SrcColObject then
          Result := True
        else
          Result := False;
      end
    );

    if SrcColObjectFound = False then
    begin
      SrcRowIndex := System.Math.Min(SrcRowIndex, GridHiddenColumns.TableView.Rows.Count - 1);
      if SrcRowIndex >= 0 then
        GridHiddenColumns.TableView.CurrentRowViewIndex := SrcRowIndex;
    end;
  end;
end;

function TCustomizeFieldBarsDialogEh.GetColumnName(Col: TFieldBarEh): String;
begin
  Result := TFieldBarEhCrack(Col).Title.Text;
  Result := StringReplace(Result, '|', ' - ', [rfReplaceAll]);
end;

procedure TCustomizeFieldBarsDialogEh.GetInitColumnsList(ADataGrid: TCustomDataAxisGridEh; AColInfoRoot: TColInfoEh);
begin
end;

procedure TCustomizeFieldBarsDialogEh.ResourceLanguageChanged;
begin
  Caption := 'Columns setup';
  Label1.Text := 'Visible columns';
  Label2.Text := 'Hidden columns';

end;

procedure TCustomizeFieldBarsDialogEh.SetNewColsWidth(NewColsWidth: Integer);
var
  SrcColObject: TColInfoEh;
  I: Integer;
begin
  if GridVisibleColumns.Selection.Rows.Count > 0 then
  begin
    for I := 0 to GridVisibleColumns.Selection.Rows.Count - 1 do
    begin
      SrcColObject := GridVisibleColumns.Selection.Rows[I].SourceObjectItem as TColInfoEh;
      if SrcColObject.RefCol is TDataGridBaseColumnEh then
      begin
        SrcColObject.ColWidth := NewColsWidth;
        GridVisibleColumns.Invalidate;
      end;
    end;
  end
  else if GridVisibleColumns.CurrentRow <> nil then
  begin
    SrcColObject := GridVisibleColumns.CurrentRow.SourceObjectItem as TColInfoEh;
    if SrcColObject.RefCol is TDataGridBaseColumnEh then
    begin
      SrcColObject.ColWidth := NewColsWidth;
      GridVisibleColumns.Invalidate;
    end;
  end;
end;


procedure TCustomizeFieldBarsDialogEh.FormCreate(Sender: TObject);
begin

  GridVisibleColumns := TDataGridEh.Create(Self);
  with GridVisibleColumns do
  begin
    DataSource := DataSource2;
    IndicatorColumn.Visible := False;
    Title.Filter.Enabled := False;
    AutoGenerateColumns := False;
    ColumnOptions.ColSizeUnit := TGridColSizeUnitEh.Weight;
    ColumnOptions.VertAlign := TTextAlign.Center;
    ColumnOptions.HorzLinesVisible := False;
    ColumnOptions.HorzLinesVisibleStored := True;
    SelectionOptions.RowSelect := True;
    SearchPanel.Enabled := True;
    SearchPanel.FilterOnTyping := True;
    Align := TAlignLayout.Client;
    Size.Width := 232;
    Size.Height := 329;
    Size.PlatformDefault := False;
    TabOrder := 1;
    Parent := PanelVisibleColumns;
  end;

  with TDataGridStringColumnEh.Create(Self) do
  begin
    DataGridStringColumnEh1 := TDataGridStringColumnEh(RefSelf);
    FieldName := 'ColumnName';
    with Footers.Add do
    begin
      AggregateFunction := TFooterAggregateFunction.Count;
      HorzAlign := TTextAlign.Center;
    end;
    Title.Text := 'Name';
    Visible := False;
    Width := 100;
  end;
  GridVisibleColumns.StaticColumns.Add(DataGridStringColumnEh1);

  with TDataGridLayoutColumnEh.Create(Self) do
  begin
    DataGridLayoutColumnEh1 := TDataGridLayoutColumnEh(RefSelf);
    Title.Text := 'Name';
    Width := 200;
    OnCreateDataCellContent := DataGridLayoutColumnEh1CreateLayoutContent;
    OnDataCellInitContent := DataGridLayoutColumnEh1InitCellContent;
  end;
  GridVisibleColumns.StaticColumns.Add(DataGridLayoutColumnEh1);

  with TDataGridStringColumnEh.Create(Self) do
  begin
    VisGridColumnWidth := TDataGridStringColumnEh(RefSelf);
    FieldName := 'Width';
    Title.Text := 'Width';
    OnDataCellGetValue := DataGridStringColumnEh2DataCellGetValue;
  end;
  GridVisibleColumns.StaticColumns.Add(VisGridColumnWidth);


  GridHiddenColumns := TDataGridEh.Create(Self);
  with GridHiddenColumns do
  begin
    DataSource := DataSource2;
    IndicatorColumn.Visible := False;
    Title.Filter.Enabled := False;
    AutoGenerateColumns := False;
    ColumnOptions.ColSizeUnit := TGridColSizeUnitEh.Weight;
    ColumnOptions.VertAlign := TTextAlign.Center;
    ColumnOptions.HorzLinesVisible := False;
    ColumnOptions.HorzLinesVisibleStored := True;
    SelectionOptions.RowSelect := True;
    SearchPanel.Enabled := True;
    SearchPanel.FilterOnTyping := True;
    Align := TAlignLayout.Client;
    Size.Width := 232;
    Size.Height := 329;
    Size.PlatformDefault := False;
    TabOrder := 1;
    Parent := PanelHiddenColumns;
  end;

  with TDataGridStringColumnEh.Create(Self) do
  begin
    DataGridStringColumnEh3 := TDataGridStringColumnEh(RefSelf);
    FieldName := 'ColumnName';
    with Footers.Add do
    begin
      AggregateFunction := TFooterAggregateFunction.Count;
      HorzAlign := TTextAlign.Center;
    end;
    Title.Text := 'Column Name';
    Visible := False;
    Width := 100;
  end;
  GridHiddenColumns.StaticColumns.Add(DataGridStringColumnEh3);

  with TDataGridLayoutColumnEh.Create(Self) do
  begin
    DataGridLayoutColumnEh2 := TDataGridLayoutColumnEh(RefSelf);
    Title.Text := 'Column Name';
    OnCreateDataCellContent := DataGridLayoutColumnEh1CreateLayoutContent;
    OnDataCellInitContent := DataGridLayoutColumnEh1InitCellContent;
  end;
  GridHiddenColumns.StaticColumns.Add(DataGridLayoutColumnEh2);

  ColInfoRoot := TColInfoEh.Create(nil);

  VisibleColumnsList := TList<TColInfoEh>.Create;
  VisibleColumnsTableLink := TListTableLinkEh.Create(nil);
  GridVisibleColumns.DataSource := VisibleColumnsTableLink;

  HiddenColumnsList := TList<TColInfoEh>.Create;
  HiddenColumnsTableLink := TListTableLinkEh.Create(nil);
  GridHiddenColumns.DataSource := HiddenColumnsTableLink;

  MemTableEh1.Filter := '[Visible] = True';
  MemTableEh2.Filter := '[Visible] = False';


  ResourceLanguageChanged;
end;

procedure TCustomizeFieldBarsDialogEh.FormDestroy(Sender: TObject);
begin
  GridVisibleColumns.DataSource := nil;
  FreeAndNil(VisibleColumnsTableLink);
  FreeAndNil(VisibleColumnsList);

  GridHiddenColumns.DataSource := nil;
  FreeAndNil(HiddenColumnsTableLink);
  FreeAndNil(HiddenColumnsList);

  FreeAndNil(ColInfoRoot);
end;

procedure TCustomizeFieldBarsDialogEh.bSetWidthClick(Sender: TObject);
var
  NewWidthAsStr: String;
  SrcColObject: TColInfoEh;
begin
  NewWidthAsStr := '';
  if GridVisibleColumns.CurrentRow <> nil then
  begin
    SrcColObject := GridVisibleColumns.CurrentRow.SourceObjectItem as TColInfoEh;
    if SrcColObject.RefCol is TDataGridBaseColumnEh then
      NewWidthAsStr := IntToStr(SrcColObject.ColWidth);
  end;

  if NewWidthAsStr <> '' then
  begin
    TDialogService.InputQuery('Enter Numerical Value',
                    ['Enter Column Width'], [NewWidthAsStr],
                    procedure(const AResult: TModalResult; const AValues: array of string)
                    begin
                      if AResult = mrOk  then
                        SetNewColsWidth(StrToInt(AValues[0]))
                    end
    );
  end;
end;

procedure TCustomizeFieldBarsDialogEh.bHideClick(Sender: TObject);
var
  SrcColObject: TColInfoEh;
begin
  if GridVisibleColumns.CurrentRow <> nil then
  begin
    SrcColObject := GridVisibleColumns.CurrentRow.SourceObjectItem as TColInfoEh;
    if SrcColObject.RefCol is TFieldBarEh then
    begin
      SrcColObject.ColVisible := False;
      FillVisibleColumnsList();
      FillHiddenColumnsList();
    end;
  end;
end;

procedure TCustomizeFieldBarsDialogEh.bShowClick(Sender: TObject);
var
  SrcColObject: TColInfoEh;
begin
  if GridHiddenColumns.CurrentRow <> nil then
  begin
    SrcColObject := GridHiddenColumns.CurrentRow.SourceObjectItem as TColInfoEh;
    if SrcColObject.RefCol is TFieldBarEh then
    begin
      SrcColObject.ColVisible := True;
      FillVisibleColumnsList();
      FillHiddenColumnsList();
    end;
  end;
end;

procedure TCustomizeFieldBarsDialogEh.DataGridLayoutColumnEh1CreateLayoutContent(
  Sender: TObject; Params: TDataGridCreateDataCellContentParamsEh);
var
  LaPropNameCell: TLaPropNameCellEh;
begin
  LaPropNameCell := TLaPropNameCellEh.CreateWith(Params.ContentParent, Params.ContentParent);
  Params.CellContent := LaPropNameCell;
end;

procedure TCustomizeFieldBarsDialogEh.DataGridLayoutColumnEh1InitCellContent(
  Sender: TObject; Params: TDataGridInitDataCellContentParamsEh);
var
  SrcFmxObject: TColInfoEh;
  Col: TFieldBarEh;
  LaPropNameCell: TLaPropNameCellEh;
  Text: String;
  SuperTitle: TDataGridSuperTitleEh;
begin
  if (Params.Row <> nil) and (Params.CellContent <> nil) then
  begin
    SrcFmxObject := TColInfoEh(Params.Row.SourceObjectItem);

    if SrcFmxObject.RefCol is TFieldBarEh then
    begin
      Col := SrcFmxObject.RefCol as TFieldBarEh;
      LaPropNameCell := Params.CellContent as TLaPropNameCellEh;
      LaPropNameCell.TreeSignVisible := False;
      LaPropNameCell.TreeSignExpanded := True;
      LaPropNameCell.IndentLevel := 0;

      if TFieldBarEhCrack(Col).Title.Text <> '' then
        Text := TFieldBarEhCrack(Col).Title.Text
      else if Col.FieldName <> '' then
        Text := Col.FieldName
      else
        Text := Col.Name;

      LaPropNameCell.TextBlock.Text := Text;
    end
    else if SrcFmxObject.RefCol is TDataGridSuperTitleEh then
    begin
      SuperTitle := SrcFmxObject.RefCol as TDataGridSuperTitleEh;

      LaPropNameCell := Params.CellContent as TLaPropNameCellEh;
      LaPropNameCell.TreeSignVisible := True;
      LaPropNameCell.TreeSignExpanded := True;
      LaPropNameCell.IndentLevel := SuperTitle.ComplexTitleNode.Level - 1;

      LaPropNameCell.TextBlock.Text := SuperTitle.Text;
    end;
  end
  else if (Params.CellContent <> nil) then
  begin
    LaPropNameCell := Params.CellContent as TLaPropNameCellEh;
    LaPropNameCell.TextBlock.Text := '';
  end;
end;

procedure TCustomizeFieldBarsDialogEh.DataGridStringColumnEh2DataCellGetValue(
  Sender: TObject; Params: TDataGridDataCellGetValueParamsEh);
var
  SrcFmxObject: TColInfoEh;
begin
  if (Params.Row <> nil) then
  begin
    SrcFmxObject := TColInfoEh(Params.Row.SourceObjectItem);
    if SrcFmxObject.RefCol is TFieldBarEh then
      Params.Value := SrcFmxObject.ColWidth
    else
      Params.Value := TValue.From<Variant>(Null);
  end else
  begin
    Params.Value := TValue.From<Variant>(Null);
  end;
  Params.Handled := True;
end;

procedure TCustomizeFieldBarsDialogEh.bMoveDownClick(Sender: TObject);
var
  SrcColObject: TColInfoEh;
begin
  if GridVisibleColumns.CurrentRow <> nil then
  begin
    SrcColObject := GridVisibleColumns.CurrentRow.SourceObjectItem as TColInfoEh;
    if SrcColObject.Index < SrcColObject.Parent.ChildrenCount - 1  then
    begin
      SrcColObject.Index := SrcColObject.Index + 1;
      FillVisibleColumnsList();
      FillHiddenColumnsList();
    end;
  end;
end;

procedure TCustomizeFieldBarsDialogEh.bMoveUpClick(Sender: TObject);
var
  SrcColObject: TColInfoEh;
begin
  if GridVisibleColumns.CurrentRow <> nil then
  begin
    SrcColObject := GridVisibleColumns.CurrentRow.SourceObjectItem as TColInfoEh;
    if SrcColObject.Index > 0 then
    begin
      SrcColObject.Index := SrcColObject.Index - 1;
      FillVisibleColumnsList();
      FillHiddenColumnsList();
    end;
  end;
end;

procedure TCustomizeFieldBarsDialogEh.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if (ModalResult = mrOk) then
  begin
    AssignBackColumnSettings(DataGrid);
  end;
end;

procedure TCustomizeFieldBarsDialogEh.FormResize(Sender: TObject);
var
  SidePanelWidth: Integer;
begin
  SidePanelWidth := Round((Panel1.Width - PanelButtons.Width)) div 2;
  PanelVisibleColumns.Width := SidePanelWidth;
  PanelHiddenColumns.Width := SidePanelWidth;
  if (Activated) then
  begin
    FormSize.cx := Width;
    FormSize.cy := Height;
  end;
end;

end.
