{*******************************************************}
{                                                       }
{                      EhLib 12.1                       }
{            Utilities to sort, filter data             }
{               in DataSet from DBGridEh                }
{                                                       }
{      Copyright (c) 2024-2025 by Dmitry V. Bolshakov   }
{                                                       }
{*******************************************************}

{$I ..\Incl\EhLib.Inc}
{$WARN SYMBOL_DEPRECATED OFF}

unit DBGridEh.DBUtils;

interface

uses
  Variants, Db, SysUtils, Classes, TypInfo, Messages,
  {$IFDEF FPC}
    LCLType, DBGridEh,
    {$IFDEF FPC_CROSSP}
      LCLIntf,
    {$ELSE}
      Windows, Win32Extra,
    {$ENDIF}
  {$ELSE}
    DBGridEh, Contnrs, Windows,
  {$ENDIF}

  {$IFDEF NEXTGEN}
  {$ELSE}
     {$IFDEF EH_LIB_9} WideStrings, {$ENDIF}
  {$ENDIF}
  EhLibUtils, DBUtilsEh, MemTableDataEh, MemTableEh, ToolCtrlsEh;

type

  TDBGridDatasetFeaturesEh = class
  private
    FDataSetClass: TDataSetClass;
  public
    constructor Create; virtual;

    function BuildSortingString(AGrid: TCustomDBGridEh; DataSet: TDataSet): String; virtual;
    function CanFilterField(Field: TField): Boolean; virtual;
    function CheckFieldForSimpleTextFilter(Field: TField): Boolean; virtual;
    function CheckCurrentRecordMatchesGridSTFilter(Grid: TCustomDBGridEh; DataSet: TDataSet): Boolean; virtual;
    function CheckCurrentRecordMatchesGridSTFilterColumn(Column: TColumnEh; Grid: TCustomDBGridEh; DataSet: TDataSet): Boolean; virtual;
    function CheckCurrentRecordMatchesSimpleExpression(Column: TColumnEh; Grid: TCustomDBGridEh; DataSet: TDataSet; AnOperator: TSTFilterOperatorEh; AnOperand: Variant): Boolean; virtual;
    function CreateAndAssignMTDateField(DataStruct: TMTDataStructEh; AField: TField): TMTDataFieldEh; virtual;
    function GetDataSetLikeWildcardForSeveralCharacters: String; virtual;
    function GetLocalFilterApplyingWay: TLocalFilterApplyingWayEh; virtual;
    function LocateText(AGrid: TCustomDBGridEh; const FieldName: string; const Text: String; AOptions: TLocateTextOptionsEh; Direction: TLocateTextDirectionEh; Matching: TLocateTextMatchingEh; TreeFindRange: TLocateTextTreeFindRangeEh; TimeOut: System.LongWord = 0; CheckValueEvent: TCheckColumnValueAcceptEventEh = nil): Boolean; virtual;
    function MoveRecords(Sender: TObject; BookmarkList: TBMListEh; ToRecNo: Integer; CheckOnly: Boolean): Boolean; virtual;
    function NullComparisonSyntax(AGrid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): TNullComparisonSyntaxEh; virtual;
    function CustomFilterSingleCharWildcard: String; virtual;
    function CustomFilterMultipleCharsWildcard: String; virtual;

    procedure ApplyFilter(Sender: TObject; DataSet: TDataSet; IsReopen: Boolean); virtual;

    procedure ApplyGridLocalFilter(Grid: TCustomDBGridEh; DataSet: TDataSet; IsReopen: Boolean); virtual;
    function GetGridFilterAsFilterString(Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String; virtual;
    function GetColumnExpressionAsFilterString(Column: TColumnEh; Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String; virtual;
    function GetBinaryExpressionAsFilterString(FieldName: String; AnOperator: TSTFilterOperatorEh; AnOperand: Variant; Column: TColumnEh; Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String; virtual;
    function GetColumnFilterFieldName(Column: TColumnEh; Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String; virtual;
    function ColumnOperatorValueToFilterStrValue(AnOperator: TSTFilterOperatorEh; AnOperand: Variant; Column: TColumnEh; Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String; virtual;
    function IsInOperatorSupported(Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): Boolean; virtual;
    function IsLikeOperatorSupported(Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): Boolean; virtual;
    function IsFilterUseFieldOrigin(Column: TColumnEh; Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): Boolean; virtual;
    function GetNullComparisonFilterString(AnOperator: TSTFilterOperatorEh; Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String; virtual;
    function GetOperatorFilterStrValue(AnOperator: TSTFilterOperatorEh; Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String; virtual;
    function FilterFieldNameToStrValue(FieldName: String; Column: TColumnEh; Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String; virtual;

    function ExpressionValueToFilterStrValue(AnOperator: TSTFilterOperatorEh; Value: Variant; Column: TColumnEh; Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String; virtual;
    function DateTimeValueToFilterStrValue(AnOperator: TSTFilterOperatorEh; Value: TDateTime; Column: TColumnEh; Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String; virtual;
    function FloatValueToFilterStrValue(AnOperator: TSTFilterOperatorEh; Value: Extended; Column: TColumnEh; Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String; virtual;
    function BooleanValueToFilterStrValue(AnOperator: TSTFilterOperatorEh; Value: Boolean; Column: TColumnEh; Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String; virtual;
    function VarValueToFilterStrValue(AnOperator: TSTFilterOperatorEh; Value: Variant; Column: TColumnEh; Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String; virtual;

    function WriteDataSetToMemTable(DataSet: TDataSet; MemTable: TCustomMemTableEh; RecordCount: Integer; Mode: TLoadMode; UseCachedUpdates: Boolean): Integer; virtual;
    function GetFilterListValuesLimit(Sender: TObject; DataSet: TDataSet): Integer; virtual;

    procedure ApplyGridServerFilter(Grid: TCustomDBGridEh; DataSet: TDataSet; IsReopen: Boolean); virtual;

    procedure ApplySimpleTextFilter(DataSet: TDataSet; const FieldNames: String; Operation: TLSAutoFilterTypeEh; const FilterText: String); virtual;
    procedure ApplySorting(Sender: TObject; DataSet: TDataSet; IsReopen: Boolean); virtual;
    procedure ExecuteFindDialog(Sender: TObject; const Text, FieldName: String; Modal: Boolean); virtual;
    procedure FillSTFilterListDataValues(AGrid: TCustomDBGridEh; Column: TColumnEh; Items: TStrings); virtual;
    procedure FillSTFilterListCommandValues(AGrid: TCustomDBGridEh; Column: TColumnEh; Items: TStrings); virtual;
    procedure FillFieldUniqueValues(Field: TField; Items: TStrings); virtual;
  end;

  TDBGridSQLDatasetFeaturesEh = class(TDBGridDatasetFeaturesEh)
  private
    FSortUsingFieldName: Boolean;
    FSQLPropName: String;
    FDateValueToSQLString: TDateValueToSQLStringProcEh;
    FSupportsLocalLike: Boolean;

  public
    constructor Create; override;

    procedure ApplyFilter(Sender: TObject; DataSet: TDataSet; IsReopen: Boolean); override;
    procedure ApplySorting(Sender: TObject; DataSet: TDataSet; IsReopen: Boolean); override;

    procedure ApplyGridServerFilter(Grid: TCustomDBGridEh; DataSet: TDataSet; IsReopen: Boolean); override;
    function DateTimeValueToFilterStrValue(AnOperator: TSTFilterOperatorEh; Value: TDateTime; Column: TColumnEh; Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String; override;
    function FloatValueToFilterStrValue(AnOperator: TSTFilterOperatorEh; Value: Extended; Column: TColumnEh; Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String; override;
    function VarValueToFilterStrValue(AnOperator: TSTFilterOperatorEh; Value: Variant; Column: TColumnEh; Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String; override;

    function GetSQLFilterMarker(Grid: TCustomDBGridEh; DataSet: TDataSet): String; virtual;
    function GetServerTypeName(Grid: TCustomDBGridEh; DataSet: TDataSet): String; virtual;

    property DateValueToSQLString: TDateValueToSQLStringProcEh read FDateValueToSQLString write FDateValueToSQLString;
    property SortUsingFieldName: Boolean read FSortUsingFieldName write FSortUsingFieldName;
    property SQLPropName: String read FSQLPropName  write FSQLPropName;
    property SupportsLocalLike: Boolean read FSupportsLocalLike write FSupportsLocalLike;
  end;

  TDBGridCommandTextDatasetFeaturesEh = class(TDBGridSQLDatasetFeaturesEh)
  public
    constructor Create; override;
  end;

  TDBGridDatasetFeaturesEhClass = class of TDBGridDatasetFeaturesEh;

procedure RegisterDBGridDatasetFeaturesEh(DatasetFeaturesClass: TDBGridDatasetFeaturesEhClass; DataSetClass: TDataSetClass);
procedure UnregisterDBGridDatasetFeaturesEh(DataSetClass: TDataSetClass);
function GetDBGridDatasetFeaturesForDataSet(DataSet: TDataSet): TDBGridDatasetFeaturesEh;
function GetDBGridDatasetFeaturesForDataSetClass(DataSetClass: TClass): TDBGridDatasetFeaturesEh;

function LocateDatasetTextEh(AGrid: TCustomDBGridEh;
  const FieldName, Text: String; AOptions: TLocateTextOptionsEh;
  Direction: TLocateTextDirectionEh; Matching: TLocateTextMatchingEh;
  TreeFindRange: TLocateTextTreeFindRangeEh;
  CheckValueEvent: TCheckColumnValueAcceptEventEh): Boolean;

function DefaultLocateDatasetTextEh(AGrid: TCustomDBGridEh;
  FieldName, Text: String; AOptions: TLocateTextOptionsEh;
  Direction: TLocateTextDirectionEh; Matching: TLocateTextMatchingEh;
  TimeOut: LongWord = 0;
  CheckValueProc: TCheckColumnValueAcceptEventEh = nil): Boolean;

procedure ApplySortingForSQLBasedDataSet(Grid: TCustomDBGridEh; DataSet: TDataSet;
  UseFieldName: Boolean; IsReopen: Boolean; const SQLPropName: String);

procedure ApplyFilterSQLBasedDataSet(Grid: TCustomDBGridEh; DataSet: TDataSet;
  DateValueToSQLString: TDateValueToSQLStringProcEh; IsReopen: Boolean;
  const SQLPropName: String);

function GetExpressionAsFilterString(AGrid: TCustomDBGridEh;
  OneExpressionProc: TOneExpressionFilterStringProcEh;
  DateValueToSQLStringProc: TDateValueToSQLStringProcEh;
  UseFieldOrigin: Boolean = False;
  SupportsLocalLike: Boolean = False;
  NullComparisonSyntax: TNullComparisonSyntaxEh = ncsAsIsNullEh;
  InOperIsSupported: Boolean = False): String;

implementation

uses
  StrUtils,
  DBGridEhFindDlgs;

type
  TBMListCrackEh = class(TBMListEh);

var
  DatasetFeaturesList: TStringList;

procedure DisposeDatasetFeaturesList;
begin
  while DatasetFeaturesList.Count > 0 do
  begin
    FreeObjectEh(DatasetFeaturesList.Objects[0]);
    DatasetFeaturesList.Delete(0);
  end;
  FreeAndNil(DatasetFeaturesList);
end;

{ InitUnit / FinalUnit }

procedure InitUnit;
begin
  DatasetFeaturesList := TStringList.Create;
  DatasetFeaturesList.Duplicates := dupError;
end;

procedure FinalUnit;
begin
  DisposeDatasetFeaturesList;
end;

{ Dataset Features }

procedure RegisterDBGridDatasetFeaturesEh(DatasetFeaturesClass: TDBGridDatasetFeaturesEhClass;
  DataSetClass: TDataSetClass);
var
  DatasetFeatures: TDBGridDatasetFeaturesEh;
  OldDatasetFeatures: TDBGridDatasetFeaturesEh;
  ClassIndex: Integer;
begin
  DatasetFeatures := DatasetFeaturesClass.Create;
  DatasetFeatures.FDataSetClass := DataSetClass;
  if DatasetFeatures.FDataSetClass = nil then
    Exit;
  ClassIndex := DatasetFeaturesList.IndexOf(DatasetFeatures.FDataSetClass.ClassName);
  if ClassIndex >= 0 then
  begin
    OldDatasetFeatures := TDBGridDatasetFeaturesEh(DatasetFeaturesList.Objects[ClassIndex]);
    DatasetFeaturesList.Objects[ClassIndex] := DatasetFeatures;
    OldDatasetFeatures.Free;
  end else
  begin
    DatasetFeaturesList.AddObject(DatasetFeatures.FDataSetClass.ClassName, DatasetFeatures);
  end;
end;

procedure UnregisterDBGridDatasetFeaturesEh(DataSetClass: TDataSetClass);
var
  idx: Integer;
begin
  idx := DatasetFeaturesList.IndexOf(DataSetClass.ClassName);
  if idx >= 0 then
  begin
    FreeObjectEh(DatasetFeaturesList.Objects[idx]);
    DatasetFeaturesList.Delete(idx);
  end;
end;

function GetDBGridDatasetFeaturesForDataSetClass(DataSetClass: TClass): TDBGridDatasetFeaturesEh;

  function GetDatasetFeaturesDeep(DataSetClass: TClass; DataSetClassName: String): Integer;
  begin
    Result := 0;
    while True do
    begin
      if UpperCase(DataSetClass.ClassName) = UpperCase(DataSetClassName) then
        Exit;
      Inc(Result);
      DataSetClass := DataSetClass.ClassParent;
      if DataSetClass = nil then
      begin
        Result := MAXINT;
        Exit;
      end;
    end;
  end;

var
  Deep, MinDeep, i: Integer;
  ClassName: String;
begin
  Result := nil;
  MinDeep := MAXINT;
  for i := 0 to DatasetFeaturesList.Count - 1 do
  begin
    if DataSetClass.InheritsFrom(TDBGridDatasetFeaturesEh(DatasetFeaturesList.Objects[i]).FDataSetClass) then
    begin
      ClassName := TDBGridDatasetFeaturesEh(DatasetFeaturesList.Objects[i]).FDataSetClass.ClassName;
      Deep := GetDatasetFeaturesDeep(DataSetClass, ClassName);
      if Deep < MinDeep then
      begin
        MinDeep := Deep;
        Result := TDBGridDatasetFeaturesEh(DatasetFeaturesList.Objects[i]);
      end;
    end;
  end;
end;

function GetDBGridDatasetFeaturesForDataSet(DataSet: TDataSet): TDBGridDatasetFeaturesEh;
begin
  Result := GetDBGridDatasetFeaturesForDataSetClass(DataSet.ClassType);
end;

function LocateDatasetTextEh(AGrid: TCustomDBGridEh;
  const FieldName, Text: String; AOptions: TLocateTextOptionsEh;
  Direction: TLocateTextDirectionEh; Matching: TLocateTextMatchingEh;
  TreeFindRange: TLocateTextTreeFindRangeEh;
  CheckValueEvent: TCheckColumnValueAcceptEventEh): Boolean;
var
  DatasetFeatures: TDBGridDatasetFeaturesEh;
begin
  if AGrid.DataSet <> nil then
  begin
    DatasetFeatures := GetDBGridDatasetFeaturesForDataSet(AGrid.DataSet);
    if DatasetFeatures <> nil then
      Result := DatasetFeatures.LocateText(AGrid, FieldName, Text, AOptions, Direction, Matching, TreeFindRange)
    else
      Result := DefaultLocateDatasetTextEh(AGrid, FieldName, Text, AOptions, Direction, Matching);
  end else
    Result := DefaultLocateDatasetTextEh(AGrid, FieldName, Text, AOptions, Direction, Matching);
end;

function DefaultLocateDatasetTextEh(AGrid: TCustomDBGridEh;
  FieldName, Text: String; AOptions: TLocateTextOptionsEh;
  Direction: TLocateTextDirectionEh; Matching: TLocateTextMatchingEh;
  TimeOut: LongWord = 0; CheckValueProc: TCheckColumnValueAcceptEventEh = nil): Boolean;
var
  FCurInListColIndex: Integer;
  FCurRow: Integer;
  FCheckEof: Boolean;
  FCheckBof: Boolean;
  FFindFromStart: Boolean;
  FFindColList: TColumnsEhList;
  ticks: UInt64;
  RecChanged: Boolean;

  function CheckEofBof: Boolean;
  begin
    if (ltoInsideSelectionEh in AOptions) and
        (AGrid.Selection.SelectionType in [gstRecordBookmarks, gstRectangle]) then
      if AGrid.Selection.SelectionType = gstRecordBookmarks then
      begin
        if (Direction = ltdUpEh)
          then Result := FCheckBof
          else Result := FCheckEof;
      end else
      begin
        if (Direction = ltdUpEh)
          then Result := FCheckBof
          else Result := FCheckEof;
      end
    else
      if (Direction = ltdUpEh)
        then Result := AGrid.DataSet.Bof
        else Result := AGrid.DataSet.Eof;
  end;

  function CheckNextCol: Boolean;
  begin
    Result := FCurInListColIndex < FFindColList.Count-1;
    if Result then
      Inc(FCurInListColIndex);
  end;

  function CheckPrevCol: Boolean;
  begin
    Result := FCurInListColIndex > 0;
    if Result then
      Dec(FCurInListColIndex);
  end;

  procedure ResetCol(ToFirstCol: Boolean);
  begin
    if ToFirstCol then
      if ltoInsideSelectionEh in AOptions then
        case AGrid.Selection.SelectionType of
          gstRecordBookmarks: FCurInListColIndex := 0;
          gstRectangle: FCurInListColIndex := 0;
          gstColumns: FCurInListColIndex := 0; 
          gstAll: FCurInListColIndex := 0;
          gstNon: FCurInListColIndex := 0;
        end
      else
        FCurInListColIndex := 0
    else
      if ltoInsideSelectionEh in AOptions then
        case AGrid.Selection.SelectionType of
          gstRecordBookmarks: FCurInListColIndex := FFindColList.Count-1;
          gstRectangle: FCurInListColIndex := FFindColList.Count-1;
          gstColumns: FCurInListColIndex := FFindColList.Count-1;
          gstAll: FCurInListColIndex := FFindColList.Count-1;
          gstNon: FCurInListColIndex := FFindColList.Count-1;
        end
      else
        FCurInListColIndex := FFindColList.Count-1
  end;

  procedure NextRec;
  begin
    if (ltoInsideSelectionEh in AOptions) and
      (AGrid.Selection.SelectionType in [gstRecordBookmarks, gstRectangle]) then
      if AGrid.Selection.SelectionType = gstRecordBookmarks then
      begin
        if FCurRow < AGrid.Selection.Rows.Count-1 then
        begin
          Inc(FCurRow);
          AGrid.DataSet.Bookmark := AGrid.Selection.Rows[FCurRow];
          FCheckEof := False;
        end else
          FCheckEof := True
      end else
      begin
        if DataSetCompareBookmarks(AGrid.DataSet,
            AGrid.DataSet.Bookmark, AGrid.Selection.Rect.BottomRow) <> 0 then
        begin
          AGrid.DataSet.Next;
          FCheckEof := False;
          if AGrid.DataSet.Eof then
            FCheckEof := True;
        end else
          FCheckEof := True;
      end
    else
      AGrid.DataSet.Next;
    RecChanged := True;
  end;

  procedure PriorRec;
  begin
    if (ltoInsideSelectionEh in AOptions) and
      (AGrid.Selection.SelectionType in [gstRecordBookmarks, gstRectangle]) then
      if AGrid.Selection.SelectionType = gstRecordBookmarks then
      begin
        if FCurRow > 0 then
        begin
          Dec(FCurRow);
          AGrid.DataSet.Bookmark := AGrid.Selection.Rows[FCurRow];
          FCheckBof := False;
        end else
          FCheckBof := True;
      end else
      begin
        if DataSetCompareBookmarks(AGrid.DataSet,
            AGrid.DataSet.Bookmark, AGrid.Selection.Rect.TopRow) <> 0 then
        begin
          AGrid.DataSet.Prior;
          FCheckBof := False;
        end else
          FCheckBof := True;
      end
    else
      AGrid.DataSet.Prior;
  end;

  procedure ToNextRec;
  begin
    if ltoAllFieldsEh in AOptions then
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
    else if (Direction = ltdUpEh) then
      PriorRec
    else
      NextRec;
  end;

  procedure ResetRec(ToFirstRec: Boolean);
  begin
    if ToFirstRec then
      if (ltoInsideSelectionEh in AOptions) and
        (AGrid.Selection.SelectionType in [gstRecordBookmarks, gstRectangle]) then
        case AGrid.Selection.SelectionType of
          gstRecordBookmarks: AGrid.DataSet.Bookmark := AGrid.Selection.Rows[0];
          gstRectangle: AGrid.DataSet.Bookmark := AGrid.Selection.Rect.TopRow;
        end
      else
        AGrid.DataSet.First
    else
      if (ltoInsideSelectionEh in AOptions) and
        (AGrid.Selection.SelectionType in [gstRecordBookmarks, gstRectangle]) then
        case AGrid.Selection.SelectionType of
          gstRecordBookmarks: AGrid.DataSet.Bookmark := AGrid.Selection.Rows[AGrid.Selection.Rows.Count-1];
          gstRectangle: AGrid.DataSet.Bookmark := AGrid.Selection.Rect.BottomRow;
        end
      else
        AGrid.DataSet.Last;
    FCurInListColIndex := 0;
  end;

  function ColText(Col: TColumnEh): String;
  begin
    if ltoMatchFormatEh in AOptions then
      Result := Col.DisplayText
    else
      Result := Col.EditText;
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
  var
    Msg: TMsg;
  begin
    Result := False;
    if PeekMessage(Msg, AGrid.Handle, WM_KEYDOWN, WM_KEYDOWN, PM_NOREMOVE) then
    begin
      if Msg.wParam = VK_ESCAPE then
      begin
        PeekMessage(Msg, AGrid.Handle, WM_KEYDOWN, WM_KEYDOWN, PM_REMOVE);
        Result := True;
      end;
    end;
  end;

  function IsAnyKeyPress: Boolean;
  var
    Msg: TMsg;
  begin
    Result := False;
    if PeekMessage(Msg, GetFocus{AGrid.Handle}, WM_KEYDOWN, WM_KEYDOWN, PM_NOREMOVE) then
      Result := True;
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
    FFindFromStart := True;
    FCheckEof := False;
    FCheckBof := False;
  end;

  procedure SetFoundIndex(Index: Integer);
  begin
    if AGrid.SearchPanel.Active
      then AGrid.SearchPanel.FoundColumnIndex := Index
      else AGrid.SelectedIndex := Index;
  end;

  function GetFoundIndex: Integer;
  begin
    if AGrid.SearchPanel.Active
      then Result := AGrid.SearchPanel.FoundColumnIndex
      else Result := AGrid.SelectedIndex;
    if Result < 0 then
      Result := 0;
  end;

  procedure FillFindColList;
  var
    i: Integer;
  begin
    if FieldName <> '' then
      FFindColList.Add(AGrid.FieldColumns[FieldName])
    else if (ltoInsideSelectionEh in AOptions) and
      (AGrid.Selection.SelectionType in [gstRectangle, gstColumns]) then
    begin
      if AGrid.Selection.SelectionType = gstColumns then
      begin
        for i := 0 to AGrid.Selection.Columns.Count-1 do
          if AGrid.Center.CanColumnValueReadAsText(AGrid, AGrid.Selection.Columns[i]) then
            FFindColList.Add(AGrid.Selection.Columns[i])
      end else
      begin
        for i := AGrid.Selection.Rect.LeftCol to AGrid.Selection.Rect.RightCol do
          if AGrid.Columns[i].Visible and
            AGrid.Center.CanColumnValueReadAsText(AGrid, AGrid.Columns[i]) then
            FFindColList.Add(AGrid.Columns[i])
      end;
    end else if ltoAllFieldsEh in AOptions then
    begin
      for i := 0 to AGrid.VisibleColumns.Count-1 do
        if AGrid.Center.CanColumnValueReadAsText(AGrid, AGrid.VisibleColumns[i]) then
          FFindColList.Add(AGrid.VisibleColumns[i])
    end else
      FFindColList.Add(AGrid.Columns[AGrid.SelectedIndex])
  end;

var
  DataText: String;
  PC: PChar;

begin
  Result := False;
  FCheckEof := False;
  FCheckBof := False;
  FFindFromStart := False;
  ticks := GetTickCountEh;
  RecChanged := False;

  FFindColList := TColumnsEhList.Create;
  FillFindColList;
  try

  if Assigned(AGrid) and
     Assigned(AGrid.DataSet) and
     AGrid.DataSet.Active and
     not AGrid.DataSet.IsEmpty
  then
  begin
    FCurInListColIndex := FFindColList.IndexOf(AGrid.Columns[GetFoundIndex]);
    if FCurInListColIndex < 0 then
      FCurInListColIndex := 0;

    if  (ltoInsideSelectionEh in AOptions) and
        (AGrid.Selection.SelectionType = gstRecordBookmarks) then
    begin
      FCurRow := AGrid.Selection.Rows.IndexOf(AGrid.DataSet.Bookmark);
      if FCurRow < 0 then
      begin
        FCurRow := 0;
        AGrid.DataSet.Bookmark := AGrid.Selection.Rows[0];
      end;
    end;

    if not AGrid.SearchPanel.Active and (dgRowSelect in AGrid.Options) and (FieldName = '') then
    begin
      FCurInListColIndex := 0;
    end;

    if (AGrid.VisibleColumns.Count = 0) then Exit;

    AGrid.DataSet.DisableControls;
    try
      AGrid.SaveBookmark;
      if (Direction = ltdAllEh) then
        ResetRec(True)
      else
        ToNextRec;

      while True do
      begin
        if CheckEofBof then
          if FFindFromStart
            then Break
            else ResetAll;

        if @CheckValueProc <> nil then
        begin
          Result := False;
          CheckValueProc(FFindColList[FCurInListColIndex], Result, Text);
          if Result then
          begin
            SetFoundIndex(FFindColList[FCurInListColIndex].Index);
            Break;
          end;
        end else
        begin

          DataText := ColText(FFindColList[FCurInListColIndex]);

          if (ltoWholeWordsEh in AOptions) and
             (Matching = ltmAnyPartEh) then
          begin
            if ltoCaseInsensitiveEh in AOptions then
            begin
              DataText := AnsiUpperCase(Text);
              Text := AnsiUpperCase(Text);
            end;
            PC := SearchBuf(PChar(DataText), Length(DataText), 0, 0, Text, [soDown, soWholeWord]);
            if PC <> nil then
            begin
              Result := True;
              SetFoundIndex(FFindColList[FCurInListColIndex].Index);
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
              SetFoundIndex(FFindColList[FCurInListColIndex].Index);
              Break;
            end
          end else 
          if ( (Matching = ltmAnyPartEh) and (AnsiContainsText(DataText, Text) ))
           or ((Matching = ltmWholeEh) and (AnsiUpperCase(DataText) = AnsiUpperCase(Text)))
           or ((Matching = ltmFromBeginningEh) and
            (AnsiUpperCase(Copy(DataText, 1, Length(Text))) = AnsiUpperCase(Text)) ) then
          begin
            Result := True;
            SetFoundIndex(FFindColList[FCurInListColIndex].Index);
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
      if not Result then
      begin
        try
          AGrid.RestoreBookmark;
        except
          on EDatabaseError do
            ;
        end;
      end;
    finally
      AGrid.DataSet.EnableControls;
    end;
  end;

  finally
    FreeAndNil(FFindColList);
  end;
end;

procedure ApplySortingForSQLBasedDataSet(Grid: TCustomDBGridEh; DataSet: TDataSet;
   UseFieldName: Boolean; IsReopen: Boolean; const SQLPropName: String);

  function GetDataFieldName(LookUpFieldName : String) : String;
  var
    FieldList: TFieldListEh;
    i: Integer;
  begin
    Result := DataSet.FieldByName(LookUpFieldName).KeyFields;
    if UseFieldName then
      Result := StringReplace(Result, ';', ', ', [])
    else
    begin
      FieldList := TFieldListEh.Create;
      try
        DataSet.GetFieldList(FieldList, Result);
        Result := '';
        for i := 0 to FieldList.Count-1 do
        begin
          if i > 0 then
            Result := Result + ', ';
          Result := Result + IntToStr(TField(FieldList[i]).FieldNo);
        end;
      finally
        FreeAndNil(FieldList);
      end;
    end;
  end;

var
  i, OrderLine: Integer;
  s: String;
  SQL: TStrings;
  SQLPropValue: WideString;
  SortOrder: TSortOrderEh;
  Field: TField;
  Fields: String;
begin
  SQLPropValue := '';
  if not IsDataSetHaveSQLLikeProp(DataSet, SQLPropName, SQLPropValue) then
    raise Exception.Create(DataSet.ClassName + ' is not SQL based dataset');

  SQL := TStringList.Create;
  try
    SQL.Text := String(SQLPropValue);

    s := '';
    for i := 0 to Grid.SortMarkedColumns.Count - 1 do
    begin
      Field := Grid.SortMarkedColumns[i].Field;
      if (Field <> nil) and (Field.FieldKind = fkLookup) then
        Fields := GetDataFieldName(Field.FieldName)
      else if UseFieldName then
        Fields := Grid.SortMarkedColumns[i].FieldName
      else if Field <> nil then
        Fields := IntToStr(Grid.SortMarkedColumns[i].Field.FieldNo);

      SortOrder := Grid.Center.GetSortOrderForSortMarker(Grid,
        Grid.SortMarkedColumns[i], Grid.SortMarkedColumns[i].Title.SortMarker);
      if SortOrder = soDescEh
        then s := s + StringReplace(Fields, ',', ' DESC,', []) + ' DESC, '
        else s := s + Fields + ', ';
    end;

    if s <> '' then
      s := 'ORDER BY ' + Copy(s, 1, Length(s) - 2);

    OrderLine := -1;
    for i := 0 to SQL.Count - 1 do
      if UpperCase(Copy(SQL[i], 1, Length('ORDER BY'))) = 'ORDER BY' then
      begin
        OrderLine := i;
        Break;
      end;

    if OrderLine = -1 then
    begin
      if (SQL.Count = 0) or (SQL[SQL.Count-1] <> '') then
        SQL.Add('');
      OrderLine := SQL.Count-1;
    end;

    SQL.Strings[OrderLine] := s;

    DataSet.DisableControls;
    try
      if DataSet.Active then
        DataSet.Close;
      SetDataSetSQLLikeProp(DataSet, SQLPropName, WideString(SQL.Text));
      if IsReopen then
        DataSet.Open;
    finally
      DataSet.EnableControls;
    end;

  finally
    SQL.Free;
  end;
end;

procedure ApplyFilterSQLBasedDataSet(Grid: TCustomDBGridEh; DataSet: TDataSet;
  DateValueToSQLString: TDateValueToSQLStringProcEh; IsReopen: Boolean;
  const SQLPropName: String);
var
  i, OrderLine: Integer;
  s: String;
  SQL: TStrings;
  SQLPropValue: WideString;
begin
  SQLPropValue := '';
  if not IsDataSetHaveSQLLikeProp(DataSet, SQLPropName, SQLPropValue) then
    raise Exception.Create(DataSet.ClassName + ' is not SQL based dataset');

  SQL := TStringList.Create;
  try
    SQL.Text := String(SQLPropValue);

    OrderLine := -1;
    for i := 0 to SQL.Count - 1 do
      if UpperCase(Copy(SQL[i], 1, Length(SQLFilterMarker))) = UpperCase(SQLFilterMarker) then
      begin
        OrderLine := i;
        Break;
      end;
    s := GetExpressionAsFilterString(Grid, GetOneExpressionAsSQLWhereString, DateValueToSQLString, True);
    if s = '' then
      s := '1=1';
    if OrderLine = -1 then
      Exit;
    DataSet.DisableControls;
    try
      if DataSet.Active then
        DataSet.Close;
      SQL.Strings[OrderLine] := SQLFilterMarker + ' (' + s + ')';
      SetDataSetSQLLikeProp(DataSet, SQLPropName, WideString(SQL.Text));
      if IsReopen then
        DataSet.Open;
    finally
      DataSet.EnableControls;
    end;

  finally
    SQL.Free;
  end;
end;

function GetExpressionAsFilterString(AGrid: TCustomDBGridEh;
  OneExpressionProc: TOneExpressionFilterStringProcEh;
  DateValueToSQLStringProc: TDateValueToSQLStringProcEh;
  UseFieldOrigin: Boolean = False;
  SupportsLocalLike: Boolean = False;
  NullComparisonSyntax: TNullComparisonSyntaxEh = ncsAsIsNullEh;
  InOperIsSupported: Boolean = False): String;

  function GetExpressionAsString(Column: TColumnEh): String;
  var
    FieldName: String;
    ADataField: TField;
    stf: TSTColumnFilterEh;
  begin
    if Column.LookupParams.LookupActive
      then ADataField := Column.LookupParams.KeyFields[0]
      else ADataField := Column.Field;

    if ADataField = nil then
      FieldName := ''
    else if UseFieldOrigin and (ADataField.Origin <> '') and (Column.STFilter.DataField = '') then
      FieldName := Column.Field.Origin
    else
      FieldName := Column.STFilter.GetFilterFieldName;
    Result := '';
    stf := Column.STFilter;
    if (stf.Expression.ExpressionType = botNon) or (ADataField = nil) or
       (stf.Expression.Operator1 = foNon) then
      Exit;
    begin
      Result := OneExpressionProc(stf.Expression.Operator1, stf.Expression.Operand1, FieldName,
        AGrid.DataSet, DateValueToSQLStringProc, SupportsLocalLike,
        NullComparisonSyntax, InOperIsSupported);
      if stf.Expression.Relation <> foNon then
      begin
        Result := Result + ' ' + STFilterOperatorsSQLStrMapEh[stf.Expression.Relation];
        Result := Result + OneExpressionProc(stf.Expression.Operator2, stf.Expression.Operand2,
          FieldName, AGrid.DataSet, DateValueToSQLStringProc, SupportsLocalLike, NullComparisonSyntax);
      end
    end;
    if stf.Expression.Relation = foOR then
      Result := '(' + Result + ')';
  end;
var
  i: Integer;
  s: String;
begin
  Result := '';
  if (AGrid.DataSet <> nil) then
  begin
    for i := 0 to AGrid.Columns.Count - 1 do
    begin
      s := GetExpressionAsString(TColumnEh(AGrid.Columns[i]));
      if s <> '' then
        Result := Result + s + ' AND ';
    end;
    Delete(Result, Length(Result) - 3, 4);
  end;
end;

{ TDatasetFeaturesEh }

constructor TDBGridDatasetFeaturesEh.Create;
begin
  inherited Create;
end;

procedure TDBGridDatasetFeaturesEh.ApplyFilter(Sender: TObject; DataSet: TDataSet; IsReopen: Boolean);
var
  Grid: TCustomDBGridEh;
begin
  Grid := Sender as TCustomDBGridEh;
  if (Grid <> nil) then
    ApplyGridLocalFilter(Grid, DataSet, IsReopen);
end;

procedure TDBGridDatasetFeaturesEh.ApplyGridLocalFilter(Grid: TCustomDBGridEh;
  DataSet: TDataSet; IsReopen: Boolean);
var
  FilterWay: TLocalFilterApplyingWayEh;
begin
  FilterWay := GetLocalFilterApplyingWay;
  if (FilterWay = lfawPropertyFilterEh) then
  begin
    Grid.DataSet.Filter := GetGridFilterAsFilterString(Grid, DataSet, True);
    Grid.DataSet.Filtered := True;
  end else
  begin
    Grid.ApplyFilterViaDataSetFilterEvent;
  end;
end;

function TDBGridDatasetFeaturesEh.GetGridFilterAsFilterString(
  Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String;
var
  i: Integer;
  s: String;
begin
  Result := '';
  if (Grid.DataSource <> nil) and (Grid.DataSet <> nil)
  then
  begin
    for i := 0 to Grid.Columns.Count - 1 do
    begin
      s := GetColumnExpressionAsFilterString(Grid.Columns[i], Grid, DataSet, IsLocalFilter);
      if s <> '' then
        Result := Result + s + ' AND ';
    end;
    Delete(Result, Length(Result) - 3, 4);
  end;
end;

function TDBGridDatasetFeaturesEh.GetColumnExpressionAsFilterString(
  Column: TColumnEh; Grid: TCustomDBGridEh; DataSet: TDataSet;
  IsLocalFilter: Boolean): String;
var
  FieldName: String;
  ADataField: TField;
  stf: TSTColumnFilterEh;
begin
  if Column.LookupParams.LookupActive
    then ADataField := Column.LookupParams.KeyFields[0]
    else ADataField := Column.Field;

  FieldName := GetColumnFilterFieldName(Column, Grid, DataSet, IsLocalFilter);

  Result := '';
  stf := Column.STFilter;
  if (stf.Expression.ExpressionType = botNon) or
     (ADataField = nil) or
     (stf.Expression.Operator1 = foNon) then
    Exit;
  begin
    Result := GetBinaryExpressionAsFilterString(FieldName,
      stf.Expression.Operator1, stf.Expression.Operand1, Column, Grid, DataSet, IsLocalFilter);
    if stf.Expression.Relation <> foNon then
    begin
      Result := Result + ' ' + STFilterOperatorsSQLStrMapEh[stf.Expression.Relation];
      Result := Result + GetBinaryExpressionAsFilterString(FieldName,
        stf.Expression.Operator2, stf.Expression.Operand2, Column, Grid, DataSet, IsLocalFilter);
    end
  end;
  if stf.Expression.Relation = foOR then
    Result := '(' + Result + ')';
end;

function TDBGridDatasetFeaturesEh.GetBinaryExpressionAsFilterString(
  FieldName: String; AnOperator: TSTFilterOperatorEh; AnOperand: Variant;
  Column: TColumnEh; Grid: TCustomDBGridEh; DataSet: TDataSet;
  IsLocalFilter: Boolean): String;

  function ComposeExpressionForFieldList(FieldNames: String;
    O: TSTFilterOperatorEh; var VarValues: Variant): String;
  var
    Pos, i: Integer;
    FieldName: String;
    FilterStrValue: String;
  begin
    Result := '( ';
    Pos := 1;
    i := 0;
    while Pos <= Length(FieldNames) do
    begin
      if i > 0 then
        Result := Result + ' AND ';
      FieldName := ExtractFieldName(FieldNames, Pos);
      Result := Result +  ' ' + LFBr + FieldName + RFBr + ' ' + STFilterOperatorsSQLStrMapEh[O];
      FilterStrValue := ExpressionValueToFilterStrValue(
                          O, VarValues[i], Column, Grid, DataSet, IsLocalFilter);
      Result := Result + ' ' + FilterStrValue;
      Inc(i);
    end;
    Result := Result + ' )';
  end;

var
  i: Integer;
  vin: Variant;
  AddIsNull: Boolean;
  InOperIsSupported: Boolean;
  SupportsLike: Boolean;
  FilterStrValue: String;
  FieldNameOperator: String;
begin
  Result := '';

  InOperIsSupported := IsInOperatorSupported(Grid, DataSet, IsLocalFilter);
  SupportsLike := IsLikeOperatorSupported(Grid, DataSet, IsLocalFilter);

  FieldNameOperator := FilterFieldNameToStrValue(FieldName, Column, Grid, DataSet, IsLocalFilter);

  if AnOperator in [foIn, foNotIn] then
  begin
    AddIsNull := False;
    Result := Result + ' (';

    if InOperIsSupported and VarIsArray(AnOperand) then
    begin
      if AnOperator = foIn then
        Result := Result +  FieldNameOperator + ' In('
      else
        Result := Result +  FieldNameOperator + ' Not In(';
    end else
    begin
      if AnOperator = foNotIn then
        Result := ' NOT' + Result;
    end;

    if VarIsArray(AnOperand) then
    begin
      for i := VarArrayLowBound(AnOperand, 1) to VarArrayHighBound(AnOperand, 1) do
      begin
        FilterStrValue := ExpressionValueToFilterStrValue(AnOperator,
          AnOperand[i], Column, Grid, DataSet, IsLocalFilter);
        if Pos(';', FieldName) <> 0 then
        begin
          vin := AnOperand[i];
          Result := Result + ComposeExpressionForFieldList(FieldName, foEqual, vin)  + ' OR '
        end else if InOperIsSupported then
        begin
          if VarIsNull(AnOperand[i]) then
            AddIsNull := True
          else
            Result := Result + FilterStrValue + ' ,  ';
        end else if VarIsNull(AnOperand[i]) then
        begin
          Result := Result + FieldNameOperator + ' ' +
            GetNullComparisonFilterString(foNull, Grid, DataSet, IsLocalFilter) + ' OR ';
        end else
        begin
          Result := Result + FieldNameOperator + ' = ' + FilterStrValue + ' OR ';
        end;
      end;
    end else
    begin
      FilterStrValue := ExpressionValueToFilterStrValue(AnOperator, AnOperand,
        Column, Grid, DataSet, IsLocalFilter);
      if Pos(';', FieldName) <> 0 then
        Result := ComposeExpressionForFieldList(FieldName, foEqual, AnOperand)  + ' OR '
      else
        Result := Result + FieldNameOperator + ' = ' + FilterStrValue + ' OR ';
    end;

    Delete(Result, Length(Result) - 3, 4);
    if InOperIsSupported and VarIsArray(AnOperand) then
      Result := Result + ') ';
    if AddIsNull then
      Result := Result + ' OR ' + FieldNameOperator + ' ' +
        GetNullComparisonFilterString(foNull, Grid, DataSet, IsLocalFilter);

    Result := Result + ')';
  end
  else if AnOperator in [foLike, foNotLike] then
  begin
    if SupportsLike then
    begin
      if AnOperator = foLike
        then Result := ' ' + FieldNameOperator + ' Like '
        else Result := ' Not (' + FieldNameOperator + ' Like '
    end else
    begin
      if AnOperator = foLike
        then Result := ' ' + FieldNameOperator + ' ' +
          GetOperatorFilterStrValue(foEqual, Grid, DataSet, IsLocalFilter) + ' '
        else Result := ' ' + FieldNameOperator + ' ' +
          GetOperatorFilterStrValue(foNotEqual, Grid, DataSet, IsLocalFilter) + ' ';
    end;
    FilterStrValue := ExpressionValueToFilterStrValue(AnOperator, AnOperand,
      Column, Grid, DataSet, IsLocalFilter);
    Result := Result + FilterStrValue;
    if SupportsLike and (AnOperator = foNotLike) then
      Result := Result + ')';
  end else
  begin
    if Pos(';', FieldName) <> 0 then
      Result := ComposeExpressionForFieldList(FieldName, AnOperator, AnOperand)
    else
    begin
      Result := Result +
        ' ' + FieldNameOperator + ' ' +
        ColumnOperatorValueToFilterStrValue(AnOperator, AnOperand, Column, Grid, DataSet, IsLocalFilter);
    end;
  end;
end;

function TDBGridDatasetFeaturesEh.ColumnOperatorValueToFilterStrValue(
  AnOperator: TSTFilterOperatorEh; AnOperand: Variant;
  Column: TColumnEh; Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String;
var
  SupportsLike: Boolean;
  FilterStrValue: String;
begin
  Result := '';
  SupportsLike := IsLikeOperatorSupported(Grid, DataSet, IsLocalFilter);

  if AnOperator in [foIn, foNotIn] then
    raise Exception.Create('Operator "In" should be implemented in the GetBinaryExpressionAsLocalFilterString method');

  if VarIsArray(AnOperand) then
    raise Exception.Create('Operand should not be an Array');

  if AnOperator in [foLike, foNotLike] then
  begin
    if SupportsLike then
      if AnOperator = foLike
        then Result := GetOperatorFilterStrValue(foLike, Grid, DataSet, IsLocalFilter) + ' '
        else Result := GetOperatorFilterStrValue(foNotLike, Grid, DataSet, IsLocalFilter) + ' '
    else
      if AnOperator = foLike
        then Result := GetOperatorFilterStrValue(foEqual, Grid, DataSet, IsLocalFilter) + ' '
        else Result := GetOperatorFilterStrValue(foNotEqual, Grid, DataSet, IsLocalFilter) + ' ';
    FilterStrValue := ExpressionValueToFilterStrValue(AnOperator, AnOperand,
      Column, Grid, DataSet, IsLocalFilter);
    Result := Result + FilterStrValue;
  end else
  begin
    Result := GetOperatorFilterStrValue(AnOperator, Grid, DataSet, IsLocalFilter);
    if not (AnOperator in [foNull, foNotNull, foEqualToNull, foNotEqualToNull]) then
    begin
      FilterStrValue := ExpressionValueToFilterStrValue(AnOperator, AnOperand,
        Column, Grid, DataSet, IsLocalFilter);
      Result := Result + ' ' + FilterStrValue;
    end;
  end;
end;

function TDBGridDatasetFeaturesEh.GetColumnFilterFieldName(
  Column: TColumnEh; Grid: TCustomDBGridEh; DataSet: TDataSet;
  IsLocalFilter: Boolean): String;
var
  ADataField: TField;
  UseFieldOrigin: Boolean;
begin
  if Column.LookupParams.LookupActive
    then ADataField := Column.LookupParams.KeyFields[0]
    else ADataField := Column.Field;

  UseFieldOrigin := IsFilterUseFieldOrigin(Column, Grid, DataSet, IsLocalFilter);
  if ADataField = nil then
    Result := ''
  else if UseFieldOrigin and (ADataField.Origin <> '') and (Column.STFilter.DataField = '') then
    Result := Column.Field.Origin
  else
    Result := Column.STFilter.GetFilterFieldName;
end;

function TDBGridDatasetFeaturesEh.FilterFieldNameToStrValue(
  FieldName: String; Column: TColumnEh; Grid: TCustomDBGridEh;
  DataSet: TDataSet; IsLocalFilter: Boolean): String;
begin
  if (IsLocalFilter) then
    Result := LFBr + FieldName + RFBr
  else
    Result := FieldName;
end;

function TDBGridDatasetFeaturesEh.ExpressionValueToFilterStrValue(
  AnOperator: TSTFilterOperatorEh; Value: Variant;
  Column: TColumnEh; Grid: TCustomDBGridEh; DataSet: TDataSet;
  IsLocalFilter: Boolean): String;
var
  VType: TVarType;
  DateTimeValue: TDateTime;
  FloatValue: Extended;
  BooleanValue: Boolean;
begin
  VType := VarType(Value);
  if VarIsNumericType(Value) then
  begin
    FloatValue := Value;
    Result := FloatValueToFilterStrValue(AnOperator, FloatValue, Column, Grid, DataSet, IsLocalFilter);
  end
  else if VType = varDate then
  begin
    DateTimeValue := VarToDateTime(Value);
    Result := DateTimeValueToFilterStrValue(AnOperator, DateTimeValue, Column, Grid, DataSet, IsLocalFilter);
  end
  else if VType = varBoolean then
  begin
    BooleanValue := Value;
    Result := BooleanValueToFilterStrValue(AnOperator, BooleanValue, Column, Grid, DataSet, IsLocalFilter);
  end
  else
  begin
    Result := VarValueToFilterStrValue(AnOperator, Value, Column, Grid, DataSet, IsLocalFilter);
  end;
end;

function TDBGridDatasetFeaturesEh.DateTimeValueToFilterStrValue(
  AnOperator: TSTFilterOperatorEh; Value: TDateTime; Column: TColumnEh;
  Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String;
begin
  Result := DateTimeToStr(Value)
end;

function TDBGridDatasetFeaturesEh.FloatValueToFilterStrValue(
  AnOperator: TSTFilterOperatorEh; Value: Extended; Column: TColumnEh;
  Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String;
begin
  Result := FloatToStr(Value)
end;

function TDBGridDatasetFeaturesEh.BooleanValueToFilterStrValue(
  AnOperator: TSTFilterOperatorEh; Value: Boolean; Column: TColumnEh;
  Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String;
begin
  if (Value = True) then
    Result := 'True'
  else
    Result := 'False';
end;

function TDBGridDatasetFeaturesEh.VarValueToFilterStrValue(
  AnOperator: TSTFilterOperatorEh; Value: Variant; Column: TColumnEh;
  Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String;
begin
  Result := VarToStr(Value);
  Result := StringReplace(Result, '''', '''''',[rfReplaceAll]);
  Result := '''' + Result + '''';
end;

function TDBGridDatasetFeaturesEh.GetNullComparisonFilterString(
  AnOperator: TSTFilterOperatorEh; Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String;
var
  ncSnx: TNullComparisonSyntaxEh;
begin
  ncSnx := NullComparisonSyntax(Grid, DataSet, IsLocalFilter);
  if (ncSnx = ncsAsIsNullEh) then
  begin
    if AnOperator in [foNull, foEqualToNull] then
      Result := 'Is Null'
    else
      Result := 'Is Not Null';
  end else
  begin
    if AnOperator in [foNull, foEqualToNull] then
      Result := '= Null'
    else
      Result := '<> Null';
  end;
end;

function TDBGridDatasetFeaturesEh.GetOperatorFilterStrValue(
  AnOperator: TSTFilterOperatorEh; Grid: TCustomDBGridEh;
  DataSet: TDataSet; IsLocalFilter: Boolean): String;
begin
  if AnOperator in [foNull, foNotNull, foEqualToNull, foNotEqualToNull] then
    Result := GetNullComparisonFilterString(AnOperator, Grid, DataSet, IsLocalFilter)
  else
    Result := STFilterOperatorsSQLStrMapEh[AnOperator];
end;

function TDBGridDatasetFeaturesEh.IsInOperatorSupported(
  Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): Boolean;
begin
  Result := True;
end;

function TDBGridDatasetFeaturesEh.IsLikeOperatorSupported(
  Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): Boolean;
begin
  Result := True;
end;

function TDBGridDatasetFeaturesEh.IsFilterUseFieldOrigin(
  Column: TColumnEh; Grid: TCustomDBGridEh; DataSet: TDataSet;
  IsLocalFilter: Boolean): Boolean;
begin
  Result := False;
end;

procedure TDBGridDatasetFeaturesEh.ApplyGridServerFilter(Grid: TCustomDBGridEh;
  DataSet: TDataSet; IsReopen: Boolean);
begin

end;

procedure TDBGridDatasetFeaturesEh.ApplySorting(Sender: TObject; DataSet: TDataSet; IsReopen: Boolean);
begin
end;

function TDBGridDatasetFeaturesEh.CreateAndAssignMTDateField(DataStruct: TMTDataStructEh; AField: TField): TMTDataFieldEh;
begin
  Result := DataStruct.BuildAndCopyDataFieldForField(AField);
end;

function TDBGridDatasetFeaturesEh.LocateText(AGrid: TCustomDBGridEh;
  const FieldName, Text: String; AOptions: TLocateTextOptionsEh;
  Direction: TLocateTextDirectionEh; Matching: TLocateTextMatchingEh;
  TreeFindRange: TLocateTextTreeFindRangeEh; TimeOut: System.LongWord = 0;
  CheckValueEvent: TCheckColumnValueAcceptEventEh = nil): Boolean;
begin
  Result := DefaultLocateDatasetTextEh(AGrid, FieldName, Text, AOptions,
    Direction, Matching, TimeOut, CheckValueEvent);
end;

function TDBGridDatasetFeaturesEh.MoveRecords(Sender: TObject; BookmarkList: TBMListEh;
  ToRecNo: Integer; CheckOnly: Boolean): Boolean;
var
  va: array of Variant;
  vs: array of Boolean;
  i, j: Integer;
  IsAppend: Boolean;
  DataSet: TDataSet;
  LocBookmarkList: TBMListEh;
begin
  Result := False;
  LocBookmarkList := nil;
  if (Sender is TDBGridEh)
    then DataSet := TDBGridEh(Sender).DataSet
    else Exit;
  Result := DataSet.CanModify;
  if CheckOnly or not Result then Exit;
  DataSet.DisableControls;
  try
    LocBookmarkList := TBMListEh.Create;
    for I := 0 to BookmarkList.Count - 1 do
      TBMListCrackEh(LocBookmarkList).InsertItem(0, BookmarkList[i]);

    if ToRecNo >= DataSet.RecordCount
      then IsAppend := True
      else IsAppend := False;
    SetLength(va, BookmarkList.Count);
    SetLength(vs, BookmarkList.Count);
    for i := 0 to LocBookmarkList.Count-1 do
    begin
      DataSet.Bookmark := LocBookmarkList[i];
      va[i] := VarArrayCreate([0, DataSet.Fields.Count], varVariant);
      for j := 0 to DataSet.Fields.Count-1 do
        va[i][j] := DataSet.Fields[j].Value;
      if (i > 0) and (ToRecNo > DataSet.RecNo) then
        Dec(ToRecNo);
      vs[i] := TDBGridEh(Sender).SelectedRows.CurrentRowSelected;
      TDBGridEh(Sender).SelectedRows.CurrentRowSelected := False;
    end;
    for i := 0 to LocBookmarkList.Count-1 do
    begin
      DataSet.Bookmark := LocBookmarkList[i];
      DataSet.Delete;
    end;
    for i := Length(va)-1 downto 0 do
    begin
      if IsAppend then
        DataSet.Append
      else
      begin
        if i < Length(va)-1
          then DataSet.Next
          else DataSet.RecNo := ToRecNo;
        DataSet.Insert;
      end;
      for j := 0 to DataSet.Fields.Count-1 do
        if DataSet.Fields[j].CanModify then
          DataSet.Fields[j].Value := va[i][j];
      DataSet.Post;
      TDBGridEh(Sender).SelectedRows.CurrentRowSelected := vs[i];
    end;
  finally
    LocBookmarkList.Free;
    DataSet.EnableControls;
  end;
end;

procedure TDBGridDatasetFeaturesEh.ExecuteFindDialog(Sender: TObject;
  const Text, FieldName: String; Modal: Boolean);
begin
  if (Sender is TDBGridEh) then
    ExecuteDBGridEhFindDialogProc(TDBGridEh(Sender), Text, '', nil, Modal);
end;

procedure TDBGridDatasetFeaturesEh.FillSTFilterListDataValues(AGrid: TCustomDBGridEh; Column: TColumnEh; Items: TStrings);
begin
  if Assigned(AGrid.Center) then
     AGrid.Center.StandardFillSTFilterListDataValues(AGrid, Column, Items);
end;

procedure TDBGridDatasetFeaturesEh.FillSTFilterListCommandValues(
  AGrid: TCustomDBGridEh; Column: TColumnEh; Items: TStrings);
begin
  if Assigned(AGrid.Center) then
     AGrid.Center.StandardFillSTFilterListCommandValues(AGrid, Column, Items, True, True);
end;

procedure TDBGridDatasetFeaturesEh.FillFieldUniqueValues(Field: TField; Items: TStrings);
begin
  raise Exception.Create('A List of Field Values feature is not supported for ' + sLineBreak +
  ' DataSet class: ' + FDataSetClass.ClassName);
end;

procedure TDBGridDatasetFeaturesEh.ApplySimpleTextFilter(DataSet: TDataSet;
  const FieldNames: String; Operation: TLSAutoFilterTypeEh;
  const FilterText: String);
var
  swc1, swc2: String;
  FieldList: TFieldListEh;
  i: Integer;
  FilterStr: String;
begin
  swc2 := GetDataSetLikeWildcardForSeveralCharacters;
  FieldList := TFieldListEh.Create;
  try
  if (FieldNames = '') or (FieldNames = '*') then
  begin
    for i := 0 to DataSet.FieldCount-1 do
      if CanFilterField(DataSet.Fields[i]) then
        FieldList.Add(DataSet.Fields[i])
  end else
    DataSet.GetFieldList(FieldList, FieldNames);

  if Operation = lsftContainsEh
    then swc1 := swc2
    else swc1 := '';
  if DataSet <> nil then
    if FilterText <> '' then
    begin
      FilterStr := '';
      for i := 0 to FieldList.Count-1 do
      begin
        if CheckFieldForSimpleTextFilter(TField(FieldList[i])) then
        begin
          FilterStr := FilterStr + LFBr + TField(FieldList[i]).FieldName + RFBr + ' like ''' + swc1 +
            StringReplace(FilterText, '''', '''''', [rfReplaceAll])
            + swc2 + '''';
          FilterStr := FilterStr + ' OR ';
        end;
      end;
      FilterStr := Copy(FilterStr, 1, Length(FilterStr)-4);
      DataSet.Filter := FilterStr;
      DataSet.Filtered := True;
    end else
      DataSet.Filter := '';
  finally
    FreeAndNil(FieldList);
  end;
end;


/// <summary> Default MultipleChar Wildcard character for 'like' operator in
/// DataSet.Filter property
/// </summary>
function TDBGridDatasetFeaturesEh.GetDataSetLikeWildcardForSeveralCharacters: String;
begin
  Result := '*';
end;

/// <summary> SingleChar Wildcard character for ApplyFilter method
/// when GetLocalFilterApplyingWay = EventFilterEh.
/// Method is used when filtering is done via an DataSet.OnFilterRecord event.
/// </summary>
function TDBGridDatasetFeaturesEh.CustomFilterSingleCharWildcard: String;
begin
  Result := '_';
end;

/// <summary> MultipleChar Wildcard character for ApplyFilter method
/// when GetLocalFilterApplyingWay = EventFilterEh.
/// Method is used when filtering is done via an DataSet.OnFilterRecord event.
/// </summary>
function TDBGridDatasetFeaturesEh.CustomFilterMultipleCharsWildcard: String;
begin
  Result := '%';
end;

function TDBGridDatasetFeaturesEh.CheckFieldForSimpleTextFilter(
  Field: TField): Boolean;
begin
  Result := Field.DataType in [ftString, ftMemo, ftFmtMemo,
    ftFixedChar, ftWideString, ftOraClob, ftGuid, ftFixedWideChar, ftWideMemo
    {$IFDEF EH_LIB_10}, ftOraInterval{$ENDIF}];
end;

function TDBGridDatasetFeaturesEh.CanFilterField(Field: TField): Boolean;
begin
  Result := Field.FieldKind in [fkData, fkInternalCalc];
end;

function TDBGridDatasetFeaturesEh.BuildSortingString(AGrid: TCustomDBGridEh; DataSet: TDataSet): String;
var
  s: String;
  i: Integer;
  SortOrder: TSortOrderEh;
  Field: TField;
  Fields: String;

  function GetDataFieldName(LookUpFieldName : String) : String;
  var
    FieldList: TFieldListEh;
    i: Integer;
  begin
    Result := DataSet.FieldByName(LookUpFieldName).KeyFields;
    begin
      FieldList := TFieldListEh.Create;
      try
        DataSet.GetFieldList(FieldList, Result);
        Result := '';
        for i := 0 to FieldList.Count-1 do
        begin
          if i > 0 then
            Result := Result + ', ';
          Result := '[' + TField(FieldList[i]).FieldName + ']';
        end;
      finally
        FreeAndNil(FieldList);
      end;
    end;
  end;

  begin
  s := '';
  for i := 0 to AGrid.SortMarkedColumns.Count - 1 do
  begin

    Field := AGrid.SortMarkedColumns[i].Field;
    if (Field <> nil) and (Field.FieldKind = fkLookup) then
      Fields := GetDataFieldName(Field.FieldName)
    else
      Fields := '[' + AGrid.SortMarkedColumns[i].FieldName + ']';

    s := s + Fields;

    SortOrder := AGrid.Center.GetSortOrderForSortMarker(AGrid,
      AGrid.SortMarkedColumns[i], AGrid.SortMarkedColumns[i].Title.SortMarker);
    if SortOrder = soDescEh
      then s := s + ' DESC, '
      else s := s + ', ';
  end;
  Result := Copy(s, 1, Length(s) - 2);
end;

function TDBGridDatasetFeaturesEh.NullComparisonSyntax(AGrid: TCustomDBGridEh;
  DataSet: TDataSet; IsLocalFilter: Boolean): TNullComparisonSyntaxEh;
begin
  Result := ncsAsIsNullEh;
end;

function TDBGridDatasetFeaturesEh.WriteDataSetToMemTable(DataSet: TDataSet;
  MemTable: TCustomMemTableEh; RecordCount: Integer;
  Mode: TLoadMode; UseCachedUpdates: Boolean): Integer;
begin
  Result := MemTable.DefaultLoadFromDataSet(DataSet, RecordCount, Mode, UseCachedUpdates);
end;

function TDBGridDatasetFeaturesEh.GetLocalFilterApplyingWay: TLocalFilterApplyingWayEh;
begin
  Result := lfawPropertyFilterEh;
end;

function TDBGridDatasetFeaturesEh.CheckCurrentRecordMatchesGridSTFilter(
  Grid: TCustomDBGridEh; DataSet: TDataSet): Boolean;
var
  i: Integer;
begin
  Result := True;
  for i := 0 to Grid.Columns.Count-1 do
  begin
    Result := Result and CheckCurrentRecordMatchesGridSTFilterColumn(Grid.Columns[i], Grid, DataSet);
  end;
end;

function TDBGridDatasetFeaturesEh.CheckCurrentRecordMatchesGridSTFilterColumn(Column: TColumnEh;
  Grid: TCustomDBGridEh; DataSet: TDataSet): Boolean;
var
  FilterExp: TSTFilterExpressionEh;
  Expression2: Boolean;
begin
  FilterExp := Column.STFilter.Expression;
  if (FilterExp.ExpressionType = botNon) then
  begin
    Result := True;
  end else
  begin
    Result := CheckCurrentRecordMatchesSimpleExpression(Column, Grid, DataSet, FilterExp.Operator1, FilterExp.Operand1);
    if (FilterExp.Relation <> foNon) then
    begin
      Expression2 := CheckCurrentRecordMatchesSimpleExpression(Column, Grid, DataSet, FilterExp.Operator2, FilterExp.Operand2);

      if (FilterExp.Relation = foAND) then
        Result := Result and Expression2
      else
        Result := Result or Expression2;
    end;
  end;
end;

function TDBGridDatasetFeaturesEh.CheckCurrentRecordMatchesSimpleExpression(Column: TColumnEh;
  Grid: TCustomDBGridEh; DataSet: TDataSet; AnOperator: TSTFilterOperatorEh; AnOperand: Variant): Boolean;
var
  colValue: Variant;
  VarCompRel: TVariantRelationship;
  i: Integer;
  SingleWildcard: String;
  MultipleWildcard: String;
  AVarType: TVarType;
  IsTextField: Boolean;

  function FilterVarEquals(FieldValue, Operant2: Variant; IsTextField: Boolean): Boolean;
  begin
    if VarIsNullEh(FieldValue) and (IsTextField = True) then
      FieldValue := '';
    if VarIsNullEh(Operant2) and (IsTextField = True) then
      Operant2 := '';

    Result := VarEquals(FieldValue, Operant2);
  end;

begin
  Result := False;
  if (Column.LookupParams.LookupActive) then
    colValue := Column.LookupParams.GetKeyValue
  else
    colValue := Column.Field.Value;

  IsTextField := CheckFieldForSimpleTextFilter(Column.Field);

  if (AnOperator in [foNull, foEqualToNull, foNotNull, foNotEqualToNull]) then
  begin

    AVarType := VarType(colValue);
    if VarIsNullEh(colValue) then
      Result := True
    else if ( ((AVarType = varOleStr) or
              (AVarType = varString)
{$IFDEF EH_LIB_12}
             or (AVarType = varUString)
{$ENDIF}
            ) and VarEquals(colValue, '')
           )
    then
      Result := True
    else
      Result := False;

    if (AnOperator in [foNotNull, foNotEqualToNull]) then
      Result := not Result;
  end
  else if (AnOperator = foNon) then
  begin
    Result := True;
  end else if (AnOperator in [foEqual, foNotEqual]) then
  begin
    Result := FilterVarEquals(colValue, AnOperand, IsTextField);
    if (AnOperator = foNotEqual) then
      Result := not Result;
  end else if (AnOperator in [foGreaterThan, foLessThan, foGreaterOrEqual, foLessOrEqual]) then
  begin
    VarCompRel := VarCompareValue(colValue, AnOperand);
    if (VarCompRel = vrEqual) and (AnOperator in [foGreaterOrEqual, foLessOrEqual]) then
      Result := True
    else if (VarCompRel = vrLessThan) and (AnOperator in [foLessThan, foLessOrEqual]) then
      Result := True
    else if (VarCompRel = vrGreaterThan) and (AnOperator in [foGreaterThan, foGreaterOrEqual]) then
      Result := True
    else
      Result := False;
  end else if (AnOperator in [foLike, foNotLike]) then
  begin
    SingleWildcard := CustomFilterSingleCharWildcard;
    MultipleWildcard := CustomFilterMultipleCharsWildcard;
    Result := StringIsMatchLikePattern(VarToStrDef(colValue, ''), VarToStrDef(AnOperand, ''), True, SingleWildcard, MultipleWildcard);
    if AnOperator = foNotLike then
      Result := not Result ;
  end else if (AnOperator in [foIn, foNotIn]) then
  begin
    if (VarIsArray(AnOperand)) then
    begin
      for i := VarArrayLowBound(AnOperand, 1) to VarArrayHighBound(AnOperand, 1) do
      begin
        if (FilterVarEquals(colValue, AnOperand[i], IsTextField)) then
        begin
          Result := True;
          Break;
        end;
      end;
    end
    else
    begin
      if (FilterVarEquals(colValue, AnOperand, IsTextField)) then
      begin
        Result := True;
      end;
    end;

    if AnOperator = foNotIn then
      Result := not Result ;
  end;
end;

/// <summary> Limit of selected values in the TDBGridEh SubTitle
/// DropDown Filter Window
/// </summary>
function TDBGridDatasetFeaturesEh.GetFilterListValuesLimit(Sender: TObject;
  DataSet: TDataSet): Integer;
begin
  Result := -1;
end;

{ TSQLDatasetFeaturesEh }

constructor TDBGridSQLDatasetFeaturesEh.Create;
begin
  inherited Create;
  SQLPropName := 'SQL';
end;

function TDBGridSQLDatasetFeaturesEh.DateTimeValueToFilterStrValue(
  AnOperator: TSTFilterOperatorEh; Value: TDateTime; Column: TColumnEh;
  Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String;
var
  ServerTypeName: String;
begin
  if (IsLocalFilter) then
    Result := '''' + DateTimeToStr(Value) + ''''
  else
  begin
    ServerTypeName := GetServerTypeName(Grid, DataSet);
    Result := DateValueToDataBaseSQLString(ServerTypeName, Value);
  end;
end;

function TDBGridSQLDatasetFeaturesEh.FloatValueToFilterStrValue(
  AnOperator: TSTFilterOperatorEh; Value: Extended; Column: TColumnEh;
  Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String;
var
{$IFDEF CIL}
  OldDecimalSeparator: String;
{$ELSE}
  OldDecimalSeparator: Char;
{$ENDIF}
begin
  if (IsLocalFilter) then
    Result := FloatToStr(Value)
  else
  begin
    OldDecimalSeparator := FormatSettings.DecimalSeparator;
    FormatSettings.DecimalSeparator := '.';
    try
      Result := FloatToStr(Value);
    finally
      FormatSettings.DecimalSeparator := OldDecimalSeparator;
    end;
  end;
end;

function TDBGridSQLDatasetFeaturesEh.VarValueToFilterStrValue(
  AnOperator: TSTFilterOperatorEh; Value: Variant; Column: TColumnEh;
  Grid: TCustomDBGridEh; DataSet: TDataSet; IsLocalFilter: Boolean): String;
begin
  Result := VarToStr(Value);
  Result := StringReplace(Result, '''', '''''',[rfReplaceAll]);
  Result := '''' + Result + '''';
end;

procedure TDBGridSQLDatasetFeaturesEh.ApplyFilter(Sender: TObject;
  DataSet: TDataSet; IsReopen: Boolean);
begin
  if TDBGridEh(Sender).STFilter.Local then
    ApplyGridLocalFilter(TDBGridEh(Sender), DataSet, IsReopen)
  else
    ApplyGridServerFilter(TDBGridEh(Sender), DataSet, IsReopen);
end;

procedure TDBGridSQLDatasetFeaturesEh.ApplyGridServerFilter(Grid: TCustomDBGridEh;
  DataSet: TDataSet; IsReopen: Boolean);
var
  i, OrderLine: Integer;
  s: String;
  SQL: TStrings;
  SQLPropValue: WideString;
  {$IFDEF FPC}
  ASQLFilterMarker: String;
  {$ELSE}
  ASQLFilterMarker: WideString;
  {$ENDIF}
begin
  SQLPropValue := '';
  if not IsDataSetHaveSQLLikeProp(DataSet, SQLPropName, SQLPropValue) then
    raise Exception.Create(DataSet.ClassName + ' is not SQL based dataset');

  ASQLFilterMarker := GetSQLFilterMarker(Grid, DataSet);
  SQL := TStringList.Create;
  try
    SQL.Text := String(SQLPropValue);

    OrderLine := -1;
    for i := 0 to SQL.Count - 1 do
      if UpperCase(Copy(SQL[i], 1, Length(ASQLFilterMarker))) = UpperCase(ASQLFilterMarker) then
      begin
        OrderLine := i;
        Break;
      end;
    s := GetGridFilterAsFilterString(Grid, DataSet, False);
    if s = '' then
      s := '1=1';
    if OrderLine = -1 then
      Exit;
    DataSet.DisableControls;
    try
      if DataSet.Active then
        DataSet.Close;
      SQL.Strings[OrderLine] := ASQLFilterMarker + ' (' + s + ')';
      SetDataSetSQLLikeProp(DataSet, SQLPropName, WideString(SQL.Text));
      if IsReopen then
        DataSet.Open;
    finally
      DataSet.EnableControls;
    end;

  finally
    SQL.Free;
  end;
end;

function TDBGridSQLDatasetFeaturesEh.GetSQLFilterMarker(Grid: TCustomDBGridEh;
  DataSet: TDataSet): String;
begin
  Result := DBUtilsEh.SQLFilterMarker;
end;

function TDBGridSQLDatasetFeaturesEh.GetServerTypeName(Grid: TCustomDBGridEh;
  DataSet: TDataSet): String;
begin
  Result := '';
end;

procedure TDBGridSQLDatasetFeaturesEh.ApplySorting(Sender: TObject; DataSet: TDataSet; IsReopen: Boolean);
begin
  if Sender is TCustomDBGridEh then
    if TCustomDBGridEh(Sender).SortLocal then
      raise Exception.Create(Format ('TSQLDatasetFeaturesEh can not sort data ' +
        'in dataset "%s" in local mode', [DataSet.Name]))
    else
      ApplySortingForSQLBasedDataSet(TCustomDBGridEh(Sender), DataSet,
        SortUsingFieldName, IsReopen, SQLPropName);
end;

{ TCommandTextDatasetFeaturesEh }

constructor TDBGridCommandTextDatasetFeaturesEh.Create;
begin
  inherited Create;
  SQLPropName := 'CommandText';
end;

initialization
  InitUnit;
finalization
  FinalUnit;
end.
