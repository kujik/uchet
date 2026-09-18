{*******************************************************}
{                                                       }
{                      EhLib 12.1                       }
{               EhLib.GridTableView.Filters             }
{                                                       }
{     Copyright (c) 2024-2025 by Dmitry V. Bolshakov    }
{                                                       }
{*******************************************************}

unit EhLib.GridTableView.Filters;

{$I ..\Incl\EhLib.Inc}
{$SCOPEDENUMS ON}

interface

uses
  SysUtils, Classes, TypInfo, Generics.Collections,
  Variants, Rtti,
  EhLib.TableLinks,
  DBUtilsEh, EhLibUtils;

type
  TTableViewBaseFilterNodeEh = class;
  TTableViewFilterNodesEh = class;
  TTableViewFilterEh = class;

  TTableViewLogicalOperationEh = (opAND, opOR);
  TTableViewComparisonOperatorEh = (opEqual, opNotEqual,
                                    opGreaterThan, opLessThan, opGreaterOrEqual, opLessOrEqual,
                                    opLike, noNotLike,
                                    opInList, opNotInList,
                                    opIsNull, opIsNotNull,
                                    opEqualToNull, opNotEqualToNull);

  TTableViewBaseFilterNodeTypeEh = (ntConstValue, ntFieldValue, ntFunction, ntExpression);

{ TTableViewFilterNodesEh }

  TTableViewFilterNodesEh = class(TPersistent)
  private
    FList: TList<TTableViewBaseFilterNodeEh>;
    function GetItem(AIndex: Integer): TTableViewBaseFilterNodeEh;
    function GetItemCount: Integer;
  protected
     procedure AddNode(ANode: TTableViewBaseFilterNodeEh);
  public
    constructor Create();
    destructor Destroy; override;

    property Item[AIndex: Integer]: TTableViewBaseFilterNodeEh read GetItem; default;
    property Count: Integer read GetItemCount;
  end;

{ TTableViewBaseFilterNodeEh }

  TTableViewBaseFilterNodeEh = class(TPersistent)
  private
    FNodeType: TTableViewBaseFilterNodeTypeEh;
  protected
    function GetResult(AListItem: TObject): TValue; virtual;
  public
    constructor Create(ANodeType: TTableViewBaseFilterNodeTypeEh);
    destructor Destroy; override;

    procedure Prepare(AFieldList: TEnumerable<TTableFieldLinkEh>); virtual;

    property NodeType: TTableViewBaseFilterNodeTypeEh read FNodeType;
  end;

{ TTableViewValueFilterNodeEh }

  TTableViewConstValueFilterNodeEh = class(TTableViewBaseFilterNodeEh)
  private
    FValue: TValue;

  protected
    function GetResult(AListItem: TObject): TValue; override;

  public
    constructor Create(const AValue: TValue);
    destructor Destroy; override;

    property Value: TValue read FValue;
  end;

{ TTableViewFieldValueFilterNodeEh }

  TTableViewFieldValueFilterNodeEh = class(TTableViewBaseFilterNodeEh)
  private
    FFieldName: String;
    FField: TObject;

  protected
    function GetResult(AListItem: TObject): TValue; override;

  public
    constructor Create(const AFieldName: String);
    destructor Destroy; override;

    procedure Prepare(AFieldList: TEnumerable<TTableFieldLinkEh>); override;

    property FieldValue: String read FFieldName;
    property Field: TObject read FField;
  end;

{ TTableViewBaseFilterNodeEh }

  TTableViewBaseListFilterNodeEh = class(TTableViewBaseFilterNodeEh)
  private
  protected
    FChildNodes: TTableViewFilterNodesEh;
    property ChildNodes: TTableViewFilterNodesEh read FChildNodes;
  public
    constructor Create(ANodeType: TTableViewBaseFilterNodeTypeEh);
    destructor Destroy; override;

    procedure Prepare(AFieldList: TEnumerable<TTableFieldLinkEh>); override;
  end;


  TTableViewBinaryOperationFilterNodeEh = class(TTableViewBaseListFilterNodeEh)
  private
    FOperator: TTableViewComparisonOperatorEh;
    function GetOperand1: TTableViewBaseFilterNodeEh;
    function GetOperand2: TTableViewBaseFilterNodeEh;

  protected
    function GetExpressionResult(const Od1: TValue; const Od2: TValue; AOperator: TTableViewComparisonOperatorEh): TValue;
    function GetResult(AListItem: TObject): TValue; override;

  public
    constructor Create(AOperand1: TTableViewBaseFilterNodeEh; AOperand2: TTableViewBaseFilterNodeEh; AOperator: TTableViewComparisonOperatorEh);
    destructor Destroy; override;

    property Operand1: TTableViewBaseFilterNodeEh read GetOperand1;
    property Operand2: TTableViewBaseFilterNodeEh read GetOperand2;
    property TheOperator: TTableViewComparisonOperatorEh read FOperator;
  end;


{ TTableViewListOperationFilterNodeEh }

  TTableViewListOperationFilterNodeEh = class(TTableViewBaseListFilterNodeEh)
  private
    FOperator: TTableViewLogicalOperationEh;

  protected
    function GetResult(AListItem: TObject): TValue; override;

  public
    constructor Create(AOperator: TTableViewLogicalOperationEh);
    destructor Destroy; override;

    procedure AddNode(AFilterNode: TTableViewBaseFilterNodeEh);

    property TheOperator: TTableViewLogicalOperationEh read FOperator;
    property ChildNodes;
  end;

{ TRowFilterEh }

  TRowFilterEh = class(TPersistent)
  private
    FRootNode: TTableViewBaseFilterNodeEh;

    procedure SetRootNode(const Value: TTableViewBaseFilterNodeEh);
  public
    constructor Create();
    destructor Destroy; override;

    procedure Prepare(AFieldList: TEnumerable<TTableFieldLinkEh>);
    function IsListItemMatchFilter(AListItem: TObject): Boolean;
    property RootNode: TTableViewBaseFilterNodeEh read FRootNode write SetRootNode;
  end;


{ TTableViewFilterEh }

  TTableViewFilterEh = class(TPersistent)
  private
    FRootNode: TTableViewBaseFilterNodeEh;
    FFieldList: TEnumerable<TTableFieldLinkEh>;
    FFilteredList: TPersistent;
    procedure SetRootNode(const Value: TTableViewBaseFilterNodeEh);
    function GetRootNode: TTableViewBaseFilterNodeEh;
  public
    constructor Create(AFilteredList: TPersistent);
    destructor Destroy; override;

    procedure Prepare(AFieldList: TEnumerable<TTableFieldLinkEh>);
    function IsListItemMatchFilter(AListItem: TObject): Boolean;
    property RootNode: TTableViewBaseFilterNodeEh read GetRootNode write SetRootNode;
  end;

implementation

uses EhLib.GridTableViews;

type
  TDataAxisFilteredItemListEhCrack = class(TTableRowViewFilteredListEh);

{ TTableViewFilterEh }

constructor TTableViewFilterEh.Create(AFilteredList: TPersistent);
begin
  inherited Create();
  FFilteredList := AFilteredList;
end;

destructor TTableViewFilterEh.Destroy;
begin
  FreeAndNil(FRootNode);
  inherited Destroy;
end;

function TTableViewFilterEh.GetRootNode: TTableViewBaseFilterNodeEh;
begin
  Result := FRootNode;
end;

procedure TTableViewFilterEh.SetRootNode(const Value: TTableViewBaseFilterNodeEh);
begin
  if FRootNode <> Value then
  begin
    FRootNode.Free;
    FRootNode := Value;
    TDataAxisFilteredItemListEhCrack(FFilteredList).FilterChanged();
  end;
end;

function TTableViewFilterEh.IsListItemMatchFilter(AListItem: TObject): Boolean;
var
  ValueResult: TValue;
begin
  if FRootNode <> nil then
  begin
    ValueResult := FRootNode.GetResult(AListItem);
    if ValueResult.TypeInfo = TypeInfo(Boolean) then
      Result := ValueResult.AsBoolean
    else
      Result := False;
  end else
    Result := True;
end;

procedure TTableViewFilterEh.Prepare(AFieldList: TEnumerable<TTableFieldLinkEh>);
begin
  FFieldList := AFieldList;
  if RootNode <> nil then
    RootNode.Prepare(AFieldList);
end;

{ TTableViewFilterNodesEh }

constructor TTableViewFilterNodesEh.Create;
begin
  inherited Create;
  FList := TList<TTableViewBaseFilterNodeEh>.Create;
end;

destructor TTableViewFilterNodesEh.Destroy;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    FList[I].Free;
  FreeAndNil(FList);
  inherited Destroy;
end;

procedure TTableViewFilterNodesEh.AddNode(ANode: TTableViewBaseFilterNodeEh);
begin
  FList.Add(ANode);
end;

function TTableViewFilterNodesEh.GetItem(AIndex: Integer): TTableViewBaseFilterNodeEh;
begin
  Result := FList[AIndex];
end;

function TTableViewFilterNodesEh.GetItemCount: Integer;
begin
  Result := FList.Count;
end;

{ TTableViewListOperationFilterNodeEh }

constructor TTableViewListOperationFilterNodeEh.Create(AOperator: TTableViewLogicalOperationEh);
begin
  inherited Create(TTableViewBaseFilterNodeTypeEh.ntExpression);
  FOperator := AOperator;
end;

destructor TTableViewListOperationFilterNodeEh.Destroy;
begin
  inherited Destroy;
end;

function TTableViewListOperationFilterNodeEh.GetResult(AListItem: TObject): TValue;
var
  I: Integer;
  VarValue: TValue;
  BoolResult, VarBoolResult: Boolean;
begin
  BoolResult := False;

  if ChildNodes.Count > 0 then
  begin
    VarValue := ChildNodes[0].GetResult(AListItem);
    if (VarValue.TypeInfo = TypeInfo(Boolean)) then
      BoolResult := VarValue.AsBoolean;
  end;

  for I := 1 to ChildNodes.Count - 1 do
  begin
    VarValue := ChildNodes[I].GetResult(AListItem);
    if (VarValue.TypeInfo = TypeInfo(Boolean)) then
      VarBoolResult := VarValue.AsBoolean
    else
      VarBoolResult := False;
    if FOperator = TTableViewLogicalOperationEh.opAND then
    begin
      BoolResult := BoolResult and VarBoolResult;
      if BoolResult = False then
        Break;
    end
    else
    begin
      BoolResult := BoolResult or VarBoolResult;
      if BoolResult = True then
        Break;
    end;
  end;

  Result := TValue.From<Boolean>(BoolResult);
end;

procedure TTableViewListOperationFilterNodeEh.AddNode(AFilterNode: TTableViewBaseFilterNodeEh);
begin
  ChildNodes.AddNode(AFilterNode);
end;

{ TTableViewBinaryOperationFilterNodeEh }

constructor TTableViewBinaryOperationFilterNodeEh.Create(AOperand1, AOperand2: TTableViewBaseFilterNodeEh;
  AOperator: TTableViewComparisonOperatorEh);
begin
  inherited Create(TTableViewBaseFilterNodeTypeEh.ntExpression);
  FChildNodes.AddNode(AOperand1);
  FChildNodes.AddNode(AOperand2);
  FOperator := AOperator;
end;

destructor TTableViewBinaryOperationFilterNodeEh.Destroy;
begin
  inherited Destroy;
end;

function TTableViewBinaryOperationFilterNodeEh.GetOperand1: TTableViewBaseFilterNodeEh;
begin
  Result := ChildNodes[0];
end;

function TTableViewBinaryOperationFilterNodeEh.GetOperand2: TTableViewBaseFilterNodeEh;
begin
  Result := ChildNodes[1];
end;

function TTableViewBinaryOperationFilterNodeEh.GetExpressionResult(const Od1: TValue; const Od2: TValue;
  AOperator: TTableViewComparisonOperatorEh): TValue;
var
  Od1IsNull: Boolean;
  Od2IsNull: Boolean;
  I: Integer;
  Vi: TValue;
begin
  Result := False;
  Od1IsNull := ValueIsNullOrEmpty(Od1);
  Od2IsNull := ValueIsNullOrEmpty(Od2);

  case AOperator of
    TTableViewComparisonOperatorEh.opEqual:
      Result := SameValue(Od1, Od2);

    TTableViewComparisonOperatorEh.opNotEqual:
      Result := not SameValue(Od1, Od2);

    TTableViewComparisonOperatorEh.opGreaterThan:
      if (Od1IsNull = True) and (Od2IsNull = True) then
        Result := False
      else if (Od1IsNull = True) and (Od2IsNull = False) then
        Result := False
      else if (Od1IsNull = False) and (Od2IsNull = True) then
        Result := True
      else
        Result := CompareValue(Od1, Od2) = TVariantRelationship.vrGreaterThan;

    TTableViewComparisonOperatorEh.opLessThan:
      if (Od1IsNull = True) and (Od2IsNull = True) then
        Result := False
      else if (Od1IsNull = True) and (Od2IsNull = False) then
        Result := True
      else if (Od1IsNull = False) and (Od2IsNull = True) then
        Result := False
      else
        Result := CompareValue(Od1, Od2) = TVariantRelationship.vrLessThan;

    TTableViewComparisonOperatorEh.opGreaterOrEqual:
      if (Od1IsNull = True) and (Od2IsNull = True) then
        Result := True
      else if (Od1IsNull = True) and (Od2IsNull = False) then
        Result := False
      else if (Od1IsNull = False) and (Od2IsNull = True) then
        Result := True
      else
        Result := CompareValue(Od1, Od2) in [TVariantRelationship.vrGreaterThan, TVariantRelationship.vrEqual];

    TTableViewComparisonOperatorEh.opLessOrEqual:
      if (Od1IsNull = True) and (Od2IsNull = True) then
        Result := True
      else if (Od1IsNull = True) and (Od2IsNull = False) then
        Result := True
      else if (Od1IsNull = False) and (Od2IsNull = True) then
        Result := False
      else
        Result := CompareValue(Od1, Od2) in [TVariantRelationship.vrLessThan, TVariantRelationship.vrEqual];

    TTableViewComparisonOperatorEh.opLike:
      Result := False;

    TTableViewComparisonOperatorEh.noNotLike:
      begin
        Result := GetExpressionResult(Od1, Od2, TTableViewComparisonOperatorEh.opLike);
        if Result.TypeInfo = TypeInfo(Boolean) then
          Result := TValue.From<Boolean>(not Result.AsBoolean);
      end;

    TTableViewComparisonOperatorEh.opInList:
      begin
        if ValueIsArrayOfValues(Od2) then
        begin
          {$IFDEF FPC}
          
          {$ELSE}
          for i := 0 to Od2.GetArrayLength - 1 do
          begin
            Vi := Od2.AsType<TArray<TValue>>[i];
            if  CastSameValue(Od1, Vi) then
            begin
              Result := True;
              Break;
            end;
          end;
          {$ENDIF}
        end else
        begin
          Result := CastSameValue(Od1, Od2);
        end;
      end;

    TTableViewComparisonOperatorEh.opNotInList:
      begin
        Result := GetExpressionResult(Od1, Od2, TTableViewComparisonOperatorEh.opInList);
        if Result.TypeInfo = TypeInfo(Boolean) then
          Result := TValue.From<Boolean>(not Result.AsBoolean);
      end;

    TTableViewComparisonOperatorEh.opIsNull:
      Result := SameValue(Od1, TValue.From<Variant>(Null));

    TTableViewComparisonOperatorEh.opIsNotNull:
      begin
        Result := GetExpressionResult(Od1, Od2, TTableViewComparisonOperatorEh.opIsNull);
        if Result.TypeInfo = TypeInfo(Boolean) then
          Result := TValue.From<Boolean>(not Result.AsBoolean);
      end;

    TTableViewComparisonOperatorEh.opEqualToNull:
      Result := SameValue(Od1, TValue.From<Variant>(Null));

    TTableViewComparisonOperatorEh.opNotEqualToNull:
      begin
        Result := GetExpressionResult(Od1, Od2, TTableViewComparisonOperatorEh.opEqualToNull);
        if Result.TypeInfo = TypeInfo(Boolean) then
          Result := TValue.From<Boolean>(not Result.AsBoolean);
      end;
  end;
end;

function TTableViewBinaryOperationFilterNodeEh.GetResult(AListItem: TObject): TValue;
var
  Od1: TValue;
  Od2: TValue;
begin
  Od1 := Operand1.GetResult(AListItem);
  Od2 := Operand2.GetResult(AListItem);
  Result := GetExpressionResult(Od1,  Od2,  TheOperator);
end;

{ TTableViewBaseListFilterNodeEh }

constructor TTableViewBaseListFilterNodeEh.Create(ANodeType: TTableViewBaseFilterNodeTypeEh);
begin
  inherited Create(ANodeType);
  FChildNodes := TTableViewFilterNodesEh.Create;
end;

destructor TTableViewBaseListFilterNodeEh.Destroy;
begin
  FreeAndNil(FChildNodes);
  inherited Destroy;
end;

procedure TTableViewBaseListFilterNodeEh.Prepare(AFieldList: TEnumerable<TTableFieldLinkEh>);
var
  I: Integer;
begin
  inherited Prepare(AFieldList);
  for I := 0 to FChildNodes.Count - 1 do
    FChildNodes[I].Prepare(AFieldList);
end;

{ TTableViewFieldValueFilterNodeEh }

constructor TTableViewFieldValueFilterNodeEh.Create(const AFieldName: String);
begin
  inherited Create(TTableViewBaseFilterNodeTypeEh.ntFieldValue);
  FFieldName := AFieldName;
end;

destructor TTableViewFieldValueFilterNodeEh.Destroy;
begin
  inherited Destroy;
end;

function TTableViewFieldValueFilterNodeEh.GetResult(AListItem: TObject): TValue;
begin
  Result := TTableRowLinkEh(AListItem).FieldValue[TTableFieldLinkEh(Field)];
end;

procedure TTableViewFieldValueFilterNodeEh.Prepare(AFieldList: TEnumerable<TTableFieldLinkEh>);
var
  FieldView: TTableFieldLinkEh;
begin
  FField := nil;
  for FieldView in AFieldList do
  begin
    if FieldView.FieldName = FieldValue then
    begin
      FField := FieldView;
      Break;
    end;
  end;
end;

{ TTableViewConstValueFilterNodeEh }

constructor TTableViewConstValueFilterNodeEh.Create(const AValue: TValue);
begin
  inherited Create(TTableViewBaseFilterNodeTypeEh.ntConstValue);
  FValue := AValue;
end;

destructor TTableViewConstValueFilterNodeEh.Destroy;
begin
  inherited Destroy;
end;

function TTableViewConstValueFilterNodeEh.GetResult(AListItem: TObject): TValue;
begin
  Result := Value;
end;

{ TTableViewBaseFilterNodeEh }

constructor TTableViewBaseFilterNodeEh.Create(ANodeType: TTableViewBaseFilterNodeTypeEh);
begin
  inherited Create();
  FNodeType := ANodeType;
end;

destructor TTableViewBaseFilterNodeEh.Destroy;
begin
  inherited Destroy;
end;

function TTableViewBaseFilterNodeEh.GetResult(AListItem: TObject): TValue;
begin
  raise Exception.Create('function TTableViewBaseFilterNodeEh.GetResult is not implemented');
end;

procedure TTableViewBaseFilterNodeEh.Prepare(AFieldList: TEnumerable<TTableFieldLinkEh>);
begin
end;

{ TRowFilterEh }

constructor TRowFilterEh.Create;
begin
  inherited Create;
end;

destructor TRowFilterEh.Destroy;
begin
  FreeAndNil(FRootNode);
  inherited Destroy;
end;

function TRowFilterEh.IsListItemMatchFilter(AListItem: TObject): Boolean;
var
  ValueResult: TValue;
begin
  if FRootNode <> nil then
  begin
    ValueResult := FRootNode.GetResult(AListItem);
    if ValueResult.TypeInfo = TypeInfo(Boolean) then
      Result := ValueResult.AsBoolean
    else
      Result := False;
  end else
    Result := True;
end;

procedure TRowFilterEh.Prepare(AFieldList: TEnumerable<TTableFieldLinkEh>);
begin
  if RootNode <> nil then
    RootNode.Prepare(AFieldList);
end;

procedure TRowFilterEh.SetRootNode(const Value: TTableViewBaseFilterNodeEh);
begin
  if FRootNode <> Value then
  begin
    FRootNode.Free;
    FRootNode := Value;
  end;
end;

end.
