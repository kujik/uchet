{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{            EhLibFmx.DataGrid.FilterForm               }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataGrid.FilterForm;

interface

{$SCOPEDENUMS ON}

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  DynVarsEh, MemTableDataEh, Data.DB, MemTableEh, DBUtilsEh,
  System.Generics.Collections, Rtti,
  FMX.Controls.Presentation, FMX.Layouts, FMX.Objects,
  FMX.Menus, FMX.Edit,
  EhLibUtils,

  EhLibFmx.Grids,

  EhLibFmx.DataAxisGrids,
  EhLibFmx.DataAxisGrid.FieldBars,
  EhLib.TableLinks,

  EhLibFmx.CustomDataGrids,
  EhLibFmx.DataGrid.Columns,
  EhLibFmx.DataGrid.Rows,
  EhLibFmx.DataGrid.ToolControls,
  EhLibFmx.DataGrid.DataCells,
  EhLibFmx.DataGrid.SearchPanels,
  EhLibFmx.SearchPanels,
  EhLibFmx.Grid.Types,
  EhLibFmx.DataGrids,

  EhLibFmx.ToolControls,
  EhLibFmx.DropDownForms
  ;

type
  TDataGridFilterFormSysParamsEh = class;

  TDataGridFilterDropDownForm = class(TDropDownFormEh)
    Panel1: TPanel;
    Layout1: TLayout;
    bOk: TButton;
    bCancel: TButton;
    ltGridNEdit: TLayout;
    bClearFilter: TMenuFaceButtonEh;
    bCustomFilter: TMenuFaceButtonEh;
    bClearColumnFilter: TMenuFaceButtonEh;
    ltFilterEdit: TLayout;
    MemTableEh1: TMemTableEh;
    DataSource1: TDataSource;
    bSortByAsc: TMenuFaceButtonEh;
    bSortByDesc: TMenuFaceButtonEh;
    bSeparator: TMenuFaceButtonEh;
    Edit1: TEdit;
    Button1: TButton;
    procedure bOkClick(Sender: TObject);
    procedure bCancelClick(Sender: TObject);
    procedure bClearColumnFilterClick(Sender: TObject);
    procedure bCustomFilterClick(Sender: TObject);
    procedure bClearFilterClick(Sender: TObject);
    procedure DataGridEh1KeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    procedure bSortByAscClick(Sender: TObject);
    procedure bSortByDescClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Edit1ChangeTracking(Sender: TObject);
    procedure DataGridEh1SearchPanelCheckCellHitSearch(Sender: TObject; Params: TDataGridSearchPanelCheckColumnValueAcceptParamsEh);

  private

    FColumn: TDataGridBaseColumnEh;
    DataGridEh1: TDataGridEh;
    DataGridCheckboxColumnEh1: TDataGridCheckboxColumnEh;
    DataGridStringColumnEh1: TDataGridStringColumnEh;

    procedure SetColumn(const Value: TDataGridBaseColumnEh);
    function GetSysParams: TDataGridFilterFormSysParamsEh;

    procedure DataGridCheckboxColumnEhGetCellValue(Sender: TObject; Params: TDataGridDataCellGetValueParamsEh);
    procedure DataGridEh1CanUserSelectRow(Sender: TObject; Params: TDataGridCanSelectRowParamsEh);
    procedure DataGridEh1DataCellMouseDown(Sender: TObject; Params: TDataGridDataCellMouseButtonParamsEh);
    procedure ClearFilter;

  protected
    procedure SetReturnParams(Host: TComponent; DynParams: TDynVarsEh; SysParams: TDropDownFormSysParams); override;

  public
    constructor CreateNew(AOwner: TComponent; Dummy: NativeInt = 0); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure InitializeNewForm; override;

    procedure InitForm(Host: TComponent; DynParams: TDynVarsEh); override;

    property Column: TDataGridBaseColumnEh read FColumn write SetColumn;
    property SysParams: TDataGridFilterFormSysParamsEh read GetSysParams;

  end;

{ TDataGridFilterFormSysParamsEh }

  TDataGridFilterFormSysParamsEh = class(TEditControlDropDownFormSysParams)
  private
    FColumn: TDataGridBaseColumnEh;
    FReturnSelValList: TList<TValue>;
  public
    constructor Create;
    destructor Destroy; override;

    property Column: TDataGridBaseColumnEh read FColumn write FColumn;
    property ReturnSelValList: TList<TValue> read FReturnSelValList;
  end;

var
  DataGridFilterDropDownForm: TDataGridFilterDropDownForm;

  DataGridFilterDropDownFormProc: function : TDataGridFilterDropDownForm = nil;

function GetDefaultDataGridFilterDropDownForm(): TDataGridFilterDropDownForm;
function GetLockDataGridFilterDropDownForm(AColumn: TDataGridBaseColumnEh): TDataGridFilterDropDownForm;
procedure ReleaseLockDataGridFilterDropDownForm(AutoClose: Boolean);

implementation

{$R *.fmx}

uses EhLibFmx.DataGrid.SimpleFilterDialog, EhLibFmx.DataGrid.Titles;

type
  TCustomDataGridEhCrack = class(TCustomDataGridEh);
  TColumnTitleEhCrack = class(TColumnTitleEh);
  TControlCrack = class(TControl);
  TDataGridTitleBarEhCrack = class(TDataGridTitleBarEh);

function GetLockDataGridFilterDropDownForm(AColumn: TDataGridBaseColumnEh): TDataGridFilterDropDownForm;
begin
  Result := DataGridFilterDropDownFormProc();
  if Result.Column <> nil then
  begin
    if Result.Visible then
      Result.Close
    else
      Result.CallCloseProc(False);
  end;

  Result.Column := AColumn;
  TColumnTitleEhCrack(AColumn.Title).FFilterDropDownForm := Result;
end;

procedure ReleaseLockDataGridFilterDropDownForm(AutoClose: Boolean);
var
  Form: TDataGridFilterDropDownForm;
begin
  Form := DataGridFilterDropDownFormProc();
  if (Form.Column = nil) then
    raise Exception.Create('ReleaseLockDataGridFilterDropDownForm: DataGridFilterDropDownForm is not locked');

  if (AutoClose = True) then
  begin
   if (Form.Visible = True) then
     Form.Close
   else if (@Form.FCallbackProc <> nil) then
     Form.CallCloseProc(False);
  end;

  if Form.Column <> nil then
  begin
    TColumnTitleEhCrack(Form.Column.Title).FFilterDropDownForm := nil;
    Form.Column := nil;
    Form.FCallbackProc := nil;
  end;
end;

function GetDefaultDataGridFilterDropDownForm: TDataGridFilterDropDownForm;
begin
  if DataGridFilterDropDownForm = nil then
    DataGridFilterDropDownForm := TDataGridFilterDropDownForm.Create(Application);
  Result := DataGridFilterDropDownForm;
end;

{ TDataGridFilterDropDownForm }

constructor TDataGridFilterDropDownForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  DataGridEh1 := TDataGridEh.Create(Self);
  DataGridEh1.DataSource := DataSource1;
  DataGridEh1.IndicatorColumn.Visible := False;
  DataGridEh1.Title.Visible := False;
  DataGridEh1.AutoGenerateColumns := False;
  DataGridEh1.SelectionOptions.RowSelect := True;
  DataGridEh1.SelectionOptions.KeepSelection := True;
  DataGridEh1.SearchPanel.Enabled := True;
  DataGridEh1.SearchPanel.FilterOnTyping := True;
  DataGridEh1.SearchPanel.Location := TSearchPanelLocationEh.TheExternal;
  DataGridEh1.Align := TAlignLayout.Client;
  DataGridEh1.Margins.Left := 32;
  DataGridEh1.Margins.Top := 8;
  DataGridEh1.Margins.Right := 8;
  DataGridEh1.Margins.Bottom := 8;
  DataGridEh1.Size.Width := 319;
  DataGridEh1.Size.Height := 249;
  DataGridEh1.Size.PlatformDefault := False;
  DataGridEh1.TabOrder := 0;
  DataGridEh1.SelectionOptions.DataCellSelectionTime := TDataCellSelectionTimeEh.OnMouseDown;

  DataGridEh1.OnKeyDown := DataGridEh1KeyDown;
  DataGridEh1.OnCanUserSelectRow := DataGridEh1CanUserSelectRow;
  DataGridEh1.OnDataCellMouseDown := DataGridEh1DataCellMouseDown;

  DataGridEh1.Parent := ltGridNEdit;

  DataGridCheckboxColumnEh1 := TDataGridCheckboxColumnEh.Create(Self);
  DataGridCheckboxColumnEh1.Width := 24;
  DataGridCheckboxColumnEh1.OnDataCellGetValue := DataGridCheckboxColumnEhGetCellValue;
  DataGridEh1.StaticColumns.Add(DataGridCheckboxColumnEh1);

  DataGridStringColumnEh1 := TDataGridStringColumnEh.Create(Self);
  DataGridStringColumnEh1.ColSizeUnit := TGridColSizeUnitEh.Weight;
  DataGridStringColumnEh1.ColSizeUnitStored := True;
  DataGridStringColumnEh1.FieldName := 'DisplayValue';
  DataGridStringColumnEh1.Title.FilterItem.Visible := False;
  DataGridStringColumnEh1.Width := 100;
  DataGridEh1.StaticColumns.Add(DataGridStringColumnEh1);

end;

constructor TDataGridFilterDropDownForm.CreateNew(AOwner: TComponent; Dummy: NativeInt);
begin
  inherited CreateNew(AOwner, Dummy);
end;

destructor TDataGridFilterDropDownForm.Destroy;
begin
  inherited Destroy;
end;

procedure TDataGridFilterDropDownForm.InitForm(Host: TComponent; DynParams: TDynVarsEh);
var
  ColumnTitle: TColumnTitleEhCrack;
  Items: TStrings;
  I: Integer;
  ValsArray: TValue;
  Value: TValue;
  Row: TDataGridRowEh;
  TableRow: TDataGridTableRowEh;
begin
  inherited InitForm(Host, DynParams);
  Assert(Column <> nil);

  DataGridEh1.Selection.Clear;
  ClearFilter;

  ColumnTitle := TColumnTitleEhCrack(Column.Title);
  Items := TStringList.Create;
  try
    ColumnTitle.FilterItem.FillSTFilterListValues(Items);
    MemTableEh1.DisableControls;
    MemTableEh1.EmptyTable;

    MemTableEh1.Append;
    MemTableEh1.Fields[1].AsString := '(Select All)';
    MemTableEh1.Fields[2].AsInteger := 1; 

    try
      for I := 0 to Items.Count - 1 do
      begin
        MemTableEh1.Append;
        MemTableEh1.Fields[1].AsString := Items[I];
        MemTableEh1.Fields[2].AsInteger := 0; 
        MemTableEh1.Post;
      end;
      MemTableEh1.First;
    finally
      MemTableEh1.EnableControls;
    end;
  finally
    Items.Free;
  end;

  if (ColumnTitle.FilterItem.Expression.Operator1 = TSTFilterOperatorEh.foIn) and
     (ValueIsArrayOfValues(ColumnTitle.FilterItem.Expression.Operand1) = True) and
     (ColumnTitle.FilterItem.Expression.Relation = TSTFilterOperatorEh.foNon)
  then
  begin
    ValsArray := ColumnTitle.FilterItem.Expression.Operand1;

    for i := 0 to ValsArray.GetArrayLength - 1 do
    begin
      Value := ValsArray.AsType<TArray<TValue>>[i];
      TableRow := TDataGridTableRowEh(DataGridEh1.TableView.FilteredRowList.FindItem('DisplayValue', Value));
      if (TableRow <> nil) then
      begin
        Row := TDataGridTableRowEh(TableRow).GridDataRow;
        if Row <> nil then
        begin
          Row.IsSelected := True;
        end;
      end;
    end;
  end;

  ActiveControl := DataGridEh1;
end;

procedure TDataGridFilterDropDownForm.InitializeNewForm;
begin
  inherited InitializeNewForm;
end;

procedure TDataGridFilterDropDownForm.DataGridCheckboxColumnEhGetCellValue(Sender: TObject; Params: TDataGridDataCellGetValueParamsEh);
begin
  if Params.Row.IsSelected
    then Params.Value := True
    else Params.Value := False;
  Params.Handled := True;
end;

procedure TDataGridFilterDropDownForm.DataGridEh1CanUserSelectRow(Sender: TObject; Params: TDataGridCanSelectRowParamsEh);
var
  FieldView: TTableFieldLinkEh;
  Value: TValue;
begin
  FieldView := DataGridEh1.TableView.Fields.FindField('RowType');
  if Params.Row is TDataGridDataRowEh
    then Value := TDataGridDataRowEh(Params.Row).TableRow.SourceRowLink.FieldValue[FieldView]
    else Value := TValue.Empty;
  if SameValue(Value, 1) then
  begin
    Params.CanSelectRow := False;
    Params.Handled := True;
  end;
end;

procedure TDataGridFilterDropDownForm.DataGridEh1DataCellMouseDown(Sender: TObject; Params: TDataGridDataCellMouseButtonParamsEh);
var
  RI: Integer;
  FieldView: TTableFieldLinkEh;
  Value: TValue;
begin
  FieldView := DataGridEh1.TableView.Fields.FindField('RowType');
  Value := Params.Row.SourceRowLink.FieldValue[FieldView];
  if SameValue(Value, 1) then
  begin
    if (DataGridEh1.Selection.SelectedRowCount > 0) then
    begin
      DataGridEh1.Selection.Clear;
    end else
    begin
      for RI := 0 to DataGridEh1.VisibleRows.Count - 1 do
      begin
        DataGridEh1.VisibleRows[RI].IsSelected := True;
      end;
    end;
    Params.Handled := True;
  end;
end;

procedure TDataGridFilterDropDownForm.DataGridEh1KeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if (KeyChar = ' ') and (Shift = []) and (DataGridEh1.CurrentRow <> nil) then
  begin
    DataGridEh1.CurrentRow.IsSelected := not DataGridEh1.CurrentRow.IsSelected;
  end;
end;

procedure TDataGridFilterDropDownForm.DataGridEh1SearchPanelCheckCellHitSearch(Sender: TObject;
  Params: TDataGridSearchPanelCheckColumnValueAcceptParamsEh);
begin
  if MemTableEh1.FieldByName('RowType').AsInteger = 1 then
    Params.Accept := True
  else
    Params.DefaultCheckColumnValueAccept();
end;

procedure TDataGridFilterDropDownForm.Edit1ChangeTracking(Sender: TObject);
begin
  DataGridEh1.SearchPanel.SearchingText := Edit1.Text;
  DataGridEh1.SearchPanel.ApplySearchFilter;
end;

procedure TDataGridFilterDropDownForm.Button1Click(Sender: TObject);
begin
  ClearFilter;
end;

procedure TDataGridFilterDropDownForm.bCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
  Close;
end;

procedure TDataGridFilterDropDownForm.bClearColumnFilterClick(Sender: TObject);
begin
  Column.Title.FilterItem.Clear;
  TCustomDataGridEhCrack(Column.Grid).Title.Filter.ApplyFilter;
  ModalResult := mrCancel;
  Close;
end;

procedure TDataGridFilterDropDownForm.bClearFilterClick(Sender: TObject);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Column.Grid);
  Grid.Title.Filter.ClearFilter;
  Grid.Title.Filter.ApplyFilter;
  ModalResult := mrCancel;
  Close;
end;

procedure TDataGridFilterDropDownForm.bCustomFilterClick(Sender: TObject);
var
  AColumn: TDataGridBaseColumnEh;
begin
  AColumn := Column;
  if StartDataGridColumnFilterDialogEh(AColumn) then
  begin
    TCustomDataGridEhCrack(AColumn.Grid).Title.Filter.ApplyFilter;
  end;
end;

procedure TDataGridFilterDropDownForm.bOkClick(Sender: TObject);
begin
  ModalResult := mrOk;
  Close;
end;

procedure TDataGridFilterDropDownForm.bSortByAscClick(Sender: TObject);
var
  GridTitle: TDataGridTitleBarEhCrack;
begin
  GridTitle := TDataGridTitleBarEhCrack(TCustomDataGridEhCrack(Column.Grid).Title);
  GridTitle.SortMarking.SetSortState(Column, TSortOrderEh.soAscEh);
  GridTitle.SortMarking.ApplySortMarkers;
  Close;
end;

procedure TDataGridFilterDropDownForm.bSortByDescClick(Sender: TObject);
var
  GridTitle: TDataGridTitleBarEhCrack;
begin
  GridTitle := TDataGridTitleBarEhCrack(TCustomDataGridEhCrack(Column.Grid).Title);
  GridTitle.SortMarking.SetSortState(Column, TSortOrderEh.soDescEh);
  GridTitle.SortMarking.ApplySortMarkers;
  Close;
end;

function TDataGridFilterDropDownForm.GetSysParams: TDataGridFilterFormSysParamsEh;
begin
  Result := TDataGridFilterFormSysParamsEh(FSysParams);
end;

procedure TDataGridFilterDropDownForm.SetColumn(const Value: TDataGridBaseColumnEh);
begin
  FColumn := Value;
end;

procedure TDataGridFilterDropDownForm.SetReturnParams(Host: TComponent; DynParams: TDynVarsEh; SysParams: TDropDownFormSysParams);
var
  GridSysParams: TDataGridFilterFormSysParamsEh;
  I: Integer;
  Value: TValue;
  RowTypeValue: TValue;
  StrValue: String;
  FieldIndex: Integer;
begin
  inherited SetReturnParams(Host, DynParams, SysParams);

  GridSysParams := TDataGridFilterFormSysParamsEh(SysParams);
  GridSysParams.ReturnSelValList.Clear;

  FieldIndex := 1;
  for I := 0 to DataGridEh1.SelectedRows.Count - 1 do
  begin
    RowTypeValue := DataGridEh1.SelectedRows[I].SourceRowLink.Value[2];
    if SameValue(RowTypeValue, 1) then
    begin
      
    end else
    begin
      Value := DataGridEh1.SelectedRows[I].SourceRowLink.Value[FieldIndex];
      StrValue := Value.AsType<String>;
      GridSysParams.ReturnSelValList.Add(Value);
    end;
  end;
end;

procedure TDataGridFilterDropDownForm.ClearFilter;
begin
  Edit1.Text := '';
  DataGridEh1.SearchPanel.SearchingText := Edit1.Text;
  DataGridEh1.SearchPanel.ApplySearchFilter;
end;

{ TDataGridFilterFormSysParamsEh }

constructor TDataGridFilterFormSysParamsEh.Create;
begin
  inherited Create;
  FReturnSelValList := TList<TValue>.Create();
end;

destructor TDataGridFilterFormSysParamsEh.Destroy;
begin
  FreeAndNil(FReturnSelValList);
  inherited Destroy;
end;

initialization
  DataGridFilterDropDownFormProc := @GetDefaultDataGridFilterDropDownForm;
finalization
end.


