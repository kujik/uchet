{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{            EhLibFmx.DataGrid.TitleFilters             }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataGrid.TitleFilters;

interface

{$SCOPEDENUMS ON}

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, System.Types,
  System.Generics.Defaults,
  System.Generics.Collections, Db, FMX.Graphics, System.UITypes,
  Variants, Rtti, SqlTimSt,
  EhLibUtils, DBUtilsEh, DynVarsEh,
  EhLib.TableLinks,
  EhLib.GridTableView.Filters,
  FMX.Forms,
  EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.Types,
  EhLibFmx.DataGrid.Rows
  ;

type

{ TSTColumnFilterEh }

  TSTColumnFilterEh = class(TPersistent)
  private
    FColumnTitle: TPersistent;
    FVisible: Boolean;
    FExpression: TSTValueFilterExpressionEh;

    function GetExpression: TSTValueFilterExpressionEh;
    procedure SetVisible(const Value: Boolean);
    function GetHasValue: Boolean;

  protected
    FFieldValueList: IMemTableDataFieldValueListEh;

  public
    constructor Create(AColumnTitle: TPersistent);
    destructor Destroy; override;

    function GetOperandAsString(AOperator: TSTFilterOperatorEh; Operand: TValue): String;
    function ParseOperandFromString(Operator: TSTFilterOperatorEh; OperandStr: String): TValue;
    function IsShowFilterButton: Boolean; virtual;

    procedure SetExpression(Operator1: TSTFilterOperatorEh; Operand1: TValue; Relation: TSTFilterOperatorEh; Operator2: TSTFilterOperatorEh; Operand2: TValue);
    procedure UpdateExpressionType;
    procedure Clear;
    procedure FillSTFilterListValues(Items: TStrings);

    property ColumnTitle: TPersistent read FColumnTitle;
    property Expression: TSTValueFilterExpressionEh read GetExpression;
    property HasValue: Boolean read GetHasValue;
    property FieldValueList: IMemTableDataFieldValueListEh read FFieldValueList;

  published
    property Visible: Boolean read FVisible write SetVisible default True;
  end;

{ TDataGridTitleFilterEh }

  TDataGridTitleFilterEh = class(TPersistent)
  private
    FEnabled: Boolean;
    FGridTitle: TPersistent;
    procedure SetEnabled(const Value: Boolean);

  public
    constructor Create(AGridTitle: TPersistent);
    destructor Destroy; override;

    function GetFilterForColumnFilterList(AColumn: TFieldBarEh): TRowFilterEh;

    procedure ApplyFilter;
    procedure ClearFilter;
    procedure FillSTFilterListValues(ASTFilter: TSTColumnFilterEh; Items: TStrings); virtual;
    procedure DefaultFillSTFilterListValues(AColumn: TFieldBarEh; Items: TStrings); virtual;
    procedure DefaultFillSTFilterListDataValues(AColumn: TFieldBarEh; Items: TStrings); virtual;

  published
    property Enabled: Boolean read FEnabled write SetEnabled default True;
  end;


implementation

uses EhLibFmx.CustomDataGrids,
     EhLibFmx.DataGrid.Titles,
     EhLibFmx.DataGrid.Columns,
     EhLibFmx.DataGrid.FilterForm
     ;

type
  TCustomDataGridEhCrack = class(TCustomDataGridEh);
  TColumnTitleEhCrack = class(TColumnTitleEh);
  TDataGridTitleBarEhCrack = class(TDataGridTitleBarEh);
  TColumnEhCrack = class(TDataGridBaseColumnEh);

{ TSTColumnFilterEh }

constructor TSTColumnFilterEh.Create(AColumnTitle: TPersistent);
begin
  inherited Create;
  FColumnTitle := AColumnTitle;
  FVisible := True;
end;

destructor TSTColumnFilterEh.Destroy;
begin
  inherited Destroy;
end;

function TSTColumnFilterEh.GetExpression: TSTValueFilterExpressionEh;
begin
  Result := FExpression;
end;

procedure TSTColumnFilterEh.SetExpression(Operator1: TSTFilterOperatorEh;
  Operand1: TValue; Relation, Operator2: TSTFilterOperatorEh;
  Operand2: TValue);
begin
  FExpression.Operator1 := Operator1;
  FExpression.Operand1 := Operand1;
  FExpression.Relation := Relation;
  FExpression.Operator2 := Operator2;
  FExpression.Operand2 := Operand2;
end;

procedure TSTColumnFilterEh.SetVisible(const Value: Boolean);
begin
  FVisible := Value;
end;

function TSTColumnFilterEh.GetOperandAsString(AOperator: TSTFilterOperatorEh; Operand: TValue): String;
var
  i: Integer;

  function OperandVarToStr(v1: TValue): String;
  var
    DoQuote: Boolean;
  begin
    Result := ValueToString(v1);
    DoQuote := False;
    if (AOperator in [foIn, foNotIn]) and (AnsiPos(',', Result) > 0) then
      DoQuote := True;
    if (CharAtPos(Result,1) = ' ') or (CharAtPos(Result,1) = '''') then
      DoQuote := True;
    if CharAtPos(Result, Length(Result)) = ' ' then
      DoQuote := True;
    if UpperCase(Copy(Result, Length(Result)-2, 3)) = ' OR' then
      DoQuote := True;
    if UpperCase(Copy(Result, Length(Result)-3, 4)) = ' AND' then
      DoQuote := True;
    if (UpperCase(Result) = 'OR') or (UpperCase(Result) = 'AND') then
      DoQuote := True;
    if DoQuote = True then
    begin
      Result := StringReplace(Result, '''', '''''',[rfReplaceAll]);
      Result := '''' + Result + '''';
    end;
  end;

  function VarToFilterString(v1: TValue): String;
  begin
    Result := OperandVarToStr(v1);
  end;

begin
  Result := '';
  if ValueIsArrayOfValues(Operand) then
  begin
    for i := 0 to Operand.GetArrayLength - 1 do
    begin
      if Result <> '' then Result := Result + ',';
      Result := Result + VarToFilterString(Operand.AsType<TArray<TValue>>[i]);
    end
  end else
  begin
    Result := VarToFilterString(Operand);
  end;
end;

function TSTColumnFilterEh.ParseOperandFromString(Operator: TSTFilterOperatorEh; OperandStr: String): TValue;
var
  ot: TSTOperandTypeEh;
  i: Integer;
  sl: TStringList;
  ValList: TList<TValue>;
begin
  ValList := TList<TValue>.Create;
  if Operator in [foIn, foNotIn] then
  begin
    sl := TStringList.Create;
    sl.CommaText := OperandStr;
    for I := 0 to sl.Count - 1 do
      ValList.Add(TValue.From<String>(sl[i]));
    sl.Free;
  end;

  ot := Expression.ExpressionType;
  if Operator = TSTFilterOperatorEh.foNon then
  begin
    Result := TValue.Empty;
  end else if ot = botNumber then
  begin
    if ValList.Count > 0 then
    begin
      for i := 0 to ValList.Count - 1 do
      begin
        if ValueIsNullOrEmpty(ValList[i]) = False then
          ValList[i] := ValList[i].Cast(TypeInfo(Double));
      end;
      Result := TValue.FromArray(TypeInfo(TValue), ValList.ToArray);
    end else
    begin
      Result := TValue.From<Double>(StrToFloat(OperandStr));
    end;
  end
  else if ot = botDateTime then
  begin
    if ValList.Count > 0 then
    begin
      for i := 0 to ValList.Count - 1 do
      begin
        if ValueIsNullOrEmpty(ValList[i]) = False then
          ValList[i] := ValList[i].Cast(TypeInfo(TDateTime));
      end;
      Result := TValue.FromArray(TypeInfo(TValue), ValList.ToArray);
    end else
    begin
      Result := TValue.From<TDateTime>(StrToDateTime(OperandStr));
    end;
  end
  else if ot = botBoolean then
  begin
    if ValList.Count > 0 then
    begin
      for i := 0 to ValList.Count - 1 do
      begin
        if ValueIsNullOrEmpty(ValList[i]) = False then
          ValList[i] := ValList[i].Cast(TypeInfo(Boolean));
      end;
      Result := TValue.FromArray(TypeInfo(TValue), ValList.ToArray);
    end
    else
    begin
      Result := TValue.From<Boolean>(StrToBool(OperandStr));
    end;
  end else if ot = botString then
  begin
    if ValList.Count > 0 then
    begin
      for i := 0 to ValList.Count - 1 do
      begin
        if ValueIsNullOrEmpty(ValList[i]) = False then
          ValList[i] := ValList[i].Cast(TypeInfo(String));
      end;
      Result := TValue.FromArray(TypeInfo(TValue), ValList.ToArray);
    end
    else
    begin
      Result := TValue.From<String>(OperandStr);
    end;
  end;
  ValList.Free;
end;

procedure TSTColumnFilterEh.UpdateExpressionType;
var
  Field: TTableFieldLinkEh;
begin
  Field := TColumnTitleEhCrack(ColumnTitle).Column.Field;
  if Field <> nil then
  begin
    if IsVarTypeNumeric(Field.DataVarSubtype) then
      FExpression.ExpressionType := TSTOperandTypeEh.botNumber
    else if (Field.DataVarSubtype in [varDate]) or (Field.DataVarSubtype = VarSQLTimeStamp) then
      FExpression.ExpressionType := TSTOperandTypeEh.botDateTime
    else
      FExpression.ExpressionType := TSTOperandTypeEh.botString;
  end else
  begin
    FExpression.ExpressionType := TSTOperandTypeEh.botNon;
  end;
end;

procedure TSTColumnFilterEh.Clear;
begin
  FExpression.Operator1 := TSTFilterOperatorEh.foNon;
  FExpression.Operand1 := TValue.Empty;
  FExpression.Relation := TSTFilterOperatorEh.foNon;
  FExpression.Operator2 := TSTFilterOperatorEh.foNon;
  FExpression.Operand2 := TValue.Empty;
end;

function TSTColumnFilterEh.GetHasValue: Boolean;
begin
  if FExpression.Operator1 <> TSTFilterOperatorEh.foNon
    then Result := True
    else Result := False;
end;

procedure TSTColumnFilterEh.FillSTFilterListValues(Items: TStrings);
var
  ColumnTitle: TColumnTitleEhCrack;
  VGrid: TCustomDataGridEhCrack;
begin
  ColumnTitle := TColumnTitleEhCrack(FColumnTitle);
  VGrid := TCustomDataGridEhCrack(ColumnTitle.Column.Grid);
  VGrid.Title.Filter.FillSTFilterListValues(ColumnTitle.FilterItem, Items);
end;

function TSTColumnFilterEh.IsShowFilterButton: Boolean;
var
  ColumnTitle: TColumnTitleEhCrack;
  VGrid: TCustomDataGridEhCrack;
begin
  ColumnTitle := TColumnTitleEhCrack(FColumnTitle);
  VGrid := TCustomDataGridEhCrack(ColumnTitle.Column.Grid);
  Result := (Visible = True) and
            (VGrid.Title.Filter.Enabled = True) and
            (TEhLibFmxSettings.Default.PlatformWindowSizeType = TPlatformWindowSizeTypeEh.Sizable);
end;

{ TDataGridTitleTitleFilterEh }

constructor TDataGridTitleFilterEh.Create(AGridTitle: TPersistent);
begin
  inherited Create();
  FGridTitle := AGridTitle;
  FEnabled := True;
end;

destructor TDataGridTitleFilterEh.Destroy;
begin
  inherited Destroy;
end;

procedure TDataGridTitleFilterEh.SetEnabled(const Value: Boolean);
var
  VGrid: TCustomDataGridEhCrack;
  GridTitle: TDataGridTitleBarEhCrack;
begin
  GridTitle := TDataGridTitleBarEhCrack(FGridTitle);
  VGrid := TCustomDataGridEhCrack(GridTitle.Grid);

  if FEnabled <> Value then
  begin
    FEnabled := Value;
    VGrid.LayoutChanged;
  end;
end;

procedure TDataGridTitleFilterEh.ApplyFilter;
var
  VGrid: TCustomDataGridEhCrack;
  GridTitle: TDataGridTitleBarEhCrack;
begin
  GridTitle := TDataGridTitleBarEhCrack(FGridTitle);
  VGrid := TCustomDataGridEhCrack(GridTitle.Grid);
  VGrid.Center.ApplyTitleFilter(VGrid);
end;

procedure TDataGridTitleFilterEh.ClearFilter;
var
  i: Integer;
  VGrid: TCustomDataGridEhCrack;
  GridTitle: TDataGridTitleBarEhCrack;
begin
  GridTitle := TDataGridTitleBarEhCrack(FGridTitle);
  VGrid := TCustomDataGridEhCrack(GridTitle.Grid);
  for i := 0 to VGrid.Columns.Count - 1 do
    VGrid.Columns[i].Title.FilterItem.Clear;
end;

procedure TDataGridTitleFilterEh.FillSTFilterListValues(
  ASTFilter: TSTColumnFilterEh; Items: TStrings);
var
  ColumnTitle: TColumnTitleEhCrack;
begin
  ColumnTitle := TColumnTitleEhCrack(ASTFilter.ColumnTitle);
  DefaultFillSTFilterListValues(ColumnTitle.Column, Items);
end;

procedure TDataGridTitleFilterEh.DefaultFillSTFilterListValues(
  AColumn: TFieldBarEh; Items: TStrings);
begin
  DefaultFillSTFilterListDataValues(AColumn, Items);
end;

function TDataGridTitleFilterEh.GetFilterForColumnFilterList(AColumn: TFieldBarEh): TRowFilterEh;
var
  I: Integer;
  ADataGrid: TCustomDataGridEhCrack;
  FilterItem: TSTColumnFilterEh;
  BinOperNode: TTableViewBinaryOperationFilterNodeEh;

  ListOperation: TTableViewListOperationFilterNodeEh;
begin
  ADataGrid := TCustomDataGridEhCrack(AColumn.Grid);

  ListOperation := nil;

  for I := 0 to ADataGrid.Columns.Count - 1 do
  begin
    if ADataGrid.Columns[I] <> AColumn then
    begin
      FilterItem := ADataGrid.Columns[I].Title.FilterItem;
      if FilterItem.HasValue then
      begin
        if ListOperation = nil  then
          ListOperation := TTableViewListOperationFilterNodeEh.Create(TTableViewLogicalOperationEh.opAND);

        BinOperNode := ADataGrid.Center.CreateFilterItemBinOperNode(ADataGrid, FilterItem);
        ListOperation.AddNode(BinOperNode);
      end;
    end;
  end;

  Result := TRowFilterEh.Create;
  Result.RootNode := ListOperation;
  Result.Prepare(ADataGrid.TableView.TableDataLink.Fields);
end;

procedure TDataGridTitleFilterEh.DefaultFillSTFilterListDataValues(AColumn: TFieldBarEh; Items: TStrings);
var
  GridTitle: TDataGridTitleBarEhCrack;
  Grid: TCustomDataGridEhCrack;
  SrcList: TList<TValue>;
  TableView: TDataGridTableRowsViewEh;
  TableViewSource: TBaseTableDataLinkEh;
  I: Integer;
  RowViewIndex: Integer;
  Val: TValue;
  ResultList: TList<TValue>;
  CurVal: TValue;
  ForColumnFilter: TRowFilterEh;
  RowView: TTableRowLinkEh;
  Str: String;
begin
  GridTitle := TDataGridTitleBarEhCrack(FGridTitle);
  Grid := TCustomDataGridEhCrack(GridTitle.Grid);
  TableView := Grid.TableView;
  TableViewSource := TableView.TableDataLink;
  if TableViewSource = nil then Exit;

  RowViewIndex := TableViewSource.Fields.IndexOf(AColumn.Field);
  if RowViewIndex < 0 then Exit;

  SrcList := TList<TValue>.Create;
  ResultList := TList<TValue>.Create;

  ForColumnFilter := GetFilterForColumnFilterList(AColumn);

  for I := 0 to TableViewSource.Rows.Count - 1 do
  begin
    RowView := TableViewSource.Rows[I];
    if ForColumnFilter.IsListItemMatchFilter(RowView) then
    begin
      Val := RowView.Value[RowViewIndex];
      SrcList.Add(Val);
    end;
  end;

  ForColumnFilter.Free;

  if SrcList.Count = 0 then Exit;
  
  SrcList.Sort(TComparer<TValue>.Construct(
    function (const L, R: TValue): Integer
    var
      VarRel: TVariantRelationship;

    begin
      Result := 0;
      VarRel := CompareValue(L, R);
      case VarRel of
        TVariantRelationship.vrLessThan: Result := -1;
        TVariantRelationship.vrGreaterThan: Result := 1;
      end;
    end
  ));

  CurVal := SrcList[0];
  ResultList.Add(CurVal);
  for I := 1 to SrcList.Count - 1 do
  begin
    if SameValue(CurVal, SrcList[I]) then
    begin
      Continue;
    end else
    begin
      CurVal := SrcList[I];
      ResultList.Add(CurVal);
    end;
  end;

  for I := 0 to ResultList.Count - 1 do
  begin
    if ResultList[I].IsType<String> = True then
      Str := ResultList[I].AsString
    else if ValueIsNullOrEmpty(ResultList[I]) then
      Str := ''
    else
      Str := ResultList[I].ToString;
    Items.Add(Str)
  end;

  ResultList.Free;
  SrcList.Free;
end;

end.
