{*******************************************************}
{                                                       }
{                       EhLib 12.1                      }
{       Utilities to sort, filter data in DataSet       }
{                                                       }
{      Copyright (c) 2002-2025 by Dmitry V. Bolshakov   }
{                                                       }
{*******************************************************}

{$I ..\Incl\EhLib.Inc}

unit DBUtilsEh;

interface

uses
  Variants, Contnrs,
{$IFDEF MSWINDOWS}
  Windows,
  {$IFDEF FPC}
  {$ELSE}
  WideStrings,
  {$ENDIF}
{$ENDIF}
  Rtti,
  Db, SysUtils, Classes,TypInfo, Generics.Collections,
  EhLibUtils;

type
  TBMListEh = class;
  TFieldsArrEh = array of TField;
  TFieldListEh = TList;

{$IFDEF TBookMarkAsTBytes}
  TUniBookmarkEh = TBookmark;
{$ELSE}

  {$IFDEF EH_LIB_11}
  {$ELSE}
  TBytes = array of Byte;
  {$ENDIF}

  {$WARNINGS OFF}
  TUniBookmarkEh = TBookmarkStr;
  {$WARNINGS ON}
{$ENDIF}

{$IFDEF EH_LIB_16}
  TDataEventInfoTypeEh = NativeInt;
{$ELSE}
  {$IFDEF FPC}
  TDataEventInfoTypeEh = PtrInt;
  {$ELSE}
  TDataEventInfoTypeEh = Integer;
  {$ENDIF}
{$ENDIF}

{$IFNDEF EH_LIB_17}
  TValueBuffer = Pointer;
{$ENDIF}

  TExternalSortDataItemEh = record
    Desc: Boolean;
    DataType: TFieldType;
  end;

  TExternalSortDataArrEh = array of  TExternalSortDataItemEh;

  TMTViewEventTypeEh = (mtRowInsertedEh, mtRowChangedEh, mtRowDeletedEh,
    mtRowMovedEh, mtViewDataChangedEh);

  TDateValueToSQLStringProcEh = function(DataSet: TDataSet; Value: Variant): String;
  TNullComparisonSyntaxEh = (ncsAsIsNullEh, ncsAsEqualToNullEh);
  TLocalFilterApplyingWayEh = (lfawPropertyFilterEh, lfawEventFilterEh);
  TLoadMode = (lmCopy, lmAppend, lmCopyStructureOnly);

  TAggrFunctionEh = (agfSumEh, agfCountEh, agfAvg, agfMin, agfMax);
  TAggrFunctionsEh = set of TAggrFunctionEh;
  TAggrResultArr = array [TAggrFunctionEh] of Variant;

  TLocateTextOptionEh = (ltoCaseInsensitiveEh, ltoAllFieldsEh, ltoMatchFormatEh,
    ltoIgnoreCurrentPosEh, ltoStopOnEscapeEh, ltoInsideSelectionEh, ltoRestartAfterLastHitEh,
    ltoWholeWordsEh, ltoStopKeyMessageEh);
  TLocateTextOptionsEh = set of TLocateTextOptionEh;

  TLocateTextDirectionEh = (ltdUpEh, ltdDownEh, ltdAllEh);

  TLocateTextMatchingEh = (ltmAnyPartEh, ltmWholeEh, ltmFromBeginningEh);

  TLocateTextTreeFindRangeEh = (lttInAllNodesEh, lttInExpandedNodesEh,
    lttInCurrentLevelEh, lttInCurrentNodeEh);

  TSTFilterOperatorEh = (
    foNon, foEqual, foNotEqual,
    foGreaterThan, foLessThan, foGreaterOrEqual, foLessOrEqual,
    foLike, foNotLike,
    foIn, foNotIn,
    foNull, foNotNull,
    foAND, foOR,
    foValue,
    foEqualToNull, foNotEqualToNull);

  IMemTableDataFieldValueListEh = interface
    ['{28F8194C-5FF3-42C4-87A6-8B3E06210FA6}']
    function GetValues: TStrings;
    procedure SetFilter(const Filter: String);
  end;

  IMTEventReceiverEh = interface
    ['{60C6C1A2-A817-4043-885A-BDDC750587BD}']
    procedure MTViewDataEvent(RowNum: Integer; Event: TMTViewEventTypeEh; OldRowNum: Integer);
  end;

  IMemTableEh = interface
    ['{A8C3C87A-E556-4BDB-B8A7-5B33497D1624}']
    function FetchRecords(Count: Integer): Integer;
    function GetInstantReadCurRowNum: Integer;
    function GetTreeNodeExpanded(RowNum: Integer): Boolean; overload;
    function GetTreeNodeExpanded: Boolean; overload;
    function GetTreeNodeHasChields: Boolean;
    function GetTreeNodeLevel: Integer;
    function GetPrevVisibleTreeNodeLevel: Integer;
    function GetNextVisibleTreeNodeLevel: Integer;
    function GetRecObject: TObject;
    function InstantReadIndexOfBookmark(Bookmark: TUniBookmarkEh): Integer;
    function InstantReadRowCount: Integer;
    function InstantReadViewRow: Integer;
    function IsInOperatorSupported: Boolean;
    function MemTableIsTreeList: Boolean;
    function ApplyExtraFilter(const FilterStr: String; FilterProc: TFilterRecordEvent): TObject;
    function ResetExtraFilter(FilterObject: TObject; const FilterStr: String; FilterProc: TFilterRecordEvent): Boolean;
    function RevokeExtraFilter(FilterObject: TObject): Boolean;
    function ParentHasNextSibling(ParenLevel: Integer): Boolean;
    function ParentHasPriorSibling(ParenLevel: Integer): Boolean;
    function SetToRec(Rec: TObject): Boolean;
    function SetTreeNodeExpanded(RowNum: Integer; Value: Boolean): Integer;
    function GetFieldValueList(const FieldName: String): IMemTableDataFieldValueListEh;
    function MoveRecords(BookmarkList: TBMListEh; ToRecNo: Integer; TreeLevel: Integer; CheckOnly: Boolean): Boolean;
    function GetLikeWildcardForOneCharacter: String;
    function GetLikeWildcardForSeveralCharacters: String;
    function BookmarkInVisibleView({$IFDEF CIL}const{$ENDIF} Bookmark: TUniBookmarkEh): Boolean;

    procedure GetAggregatedValuesForRange(FromBM, ToBM: TUniBookmarkEh; const FieldName: String; var FieldNaeResultArr: TAggrResultArr; AggrFuncs: TAggrFunctionsEh);
    procedure MTDisableControls;
    procedure MTEnableControls(ForceUpdateState: Boolean);
    procedure InstantReadEnter(RowNum: Integer);
    procedure InstantReadLeave;
    procedure RegisterEventReceiver(AComponent: TPersistent);
    procedure UnregisterEventReceiver(AComponent: TPersistent);
    procedure FilterAbort;

    property InstantReadCurRowNum: Integer read GetInstantReadCurRowNum;
  end;

  IImageStream = interface
  ['{82AAF05C-3351-41DD-A2B9-42AF30DC0C30}']
    function GetImageStream: TStream;
    function GetObject: TPersistent;
  end;

  TImageStreamPersistentEh = class;

{ TInterfacedImageStreamE }

  TInterfacedImageStreamEh = class(TInterfacedObject, IImageStream)
  private
    FImageStream: TMemoryStream;
    FPersistentObj: TImageStreamPersistentEh;
  public
    constructor Create(); overload;
    destructor Destroy; override;

    function GetImageStream: TStream;
    function GetObject: TPersistent;
  end;

{ TImageStreamPersistentEh }

  TImageStreamPersistentEh = class(TInterfacedPersistent, IStreamPersist)
  private
    FOwner: TInterfacedImageStreamEh;
  protected
    procedure AssignTo(Dest: TPersistent); override;

  public
    constructor Create(AOwner: TInterfacedImageStreamEh); reintroduce;
    destructor Destroy; override;

    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);

    procedure Assign(Source: TPersistent); override;
  end;

{ TBMListEh }

  TBMListSortCompare = function(List: TBMListEh; DataSet: TDataSet; Index1, Index2: Integer): Integer;

  TBMListEh = class(TObject)
  private
    FCache: TUniBookmarkEh;
    FCacheFind: Boolean;
    FCacheIndex: Integer;
    FLinkActive: Boolean;
    FUpdateCount: Integer;
    function GetCount: Integer;
    function GetCurrentRowSelected: Boolean;
    function GetItem(Index: Integer): TUniBookmarkEh;
    procedure QuickSort(DataSet: TDataSet; L, R: Integer; SCompare: TBMListSortCompare);
    procedure SetItem(Index: Integer; Item: TUniBookmarkEh);

  protected
{$IFDEF TBookMarkAsTBytes}
    FList: array of TBookmark;
{$ELSE}
    FList: TStringList;
{$ENDIF}
    function GetDataSet: TDataSet; virtual;
    function IsLinkActive: Boolean; virtual;

    procedure AppendItem(Item: TUniBookmarkEh); virtual;
    procedure CustomSort(DataSet: TDataSet; Compare: TBMListSortCompare); virtual;
    procedure InsertItem(Index: Integer; Item: TUniBookmarkEh); virtual;
    procedure Invalidate; virtual;
    procedure LinkActive(Value: Boolean);
    procedure ListChanged(); virtual;
    procedure ListChangedEventHandler(Sender: TObject);
    procedure RaiseBMListError(const S: string); virtual;
    procedure Resort; virtual;
    procedure SetCurrentRowSelected(Value: Boolean); virtual;
    procedure UpdateState; virtual;

  public
    constructor Create;
    destructor Destroy; override;

    function Compare(const Item1, Item2: TUniBookmarkEh): Integer;
    function CurrentRow: TUniBookmarkEh;
    function DeleteBookmark(Item: TUniBookmarkEh): Boolean; virtual;
    function Find(const Item: TUniBookmarkEh; var Index: Integer): Boolean;
    function IndexOf(const Item: TUniBookmarkEh): Integer;
    function Refresh(DeleteInvalid: Boolean): Boolean;
    function Updating: Boolean;

    procedure AppendBookmark(Item: TUniBookmarkEh); virtual;
    procedure Clear; virtual;
    procedure Delete;
    procedure DeleteItem(Index: Integer); virtual;
    procedure SelectAll; virtual;
    procedure BeginUpdate;
    procedure EndUpdate;

    property Count: Integer read GetCount;
    property CurrentRowSelected: Boolean read GetCurrentRowSelected write SetCurrentRowSelected;
    property DataSet: TDataSet read GetDataSet;
    property Items[Index: Integer]: TUniBookmarkEh read GetItem write SetItem; default;
  end;

  TOneExpressionFilterStringProcEh = function(O: TSTFilterOperatorEh; v: Variant;
    const FieldName: String; DataSet: TDataSet;
    DateValueToSQLStringProc: TDateValueToSQLStringProcEh;
    SupportsLike: Boolean;
    NullComparisonSyntax: TNullComparisonSyntaxEh;
    InOperIsSupported: Boolean = False): String;

  TSTOperandTypeEh = (botNon, botString, botNumber, botDateTime, botBoolean);

  TSTFilterDefaultOperatorEh = (
    fdoAuto, fdoEqual, fdoNotEqual,
    fdoGreaterThan, fdoLessThan, fdoGreaterOrEqual, fdoLessOrEqual,
    fdoLike, fdoNotLike,
    fdoIn, fdoNotIn,
    fdoBeginsWith, fdoDoesntBeginWith,
    fdoEndsWith, fdoDoesntEndWith,
    fdoContains, fdoDoesntContain);

  TSTFilterExpressionEh = record
    ExpressionType: TSTOperandTypeEh;
    Operator1: TSTFilterOperatorEh;
    Operand1: Variant;
    Relation: TSTFilterOperatorEh; 
    Operator2: TSTFilterOperatorEh;
    Operand2: Variant;
  end;

  TSTValueFilterExpressionEh = record
    ExpressionType: TSTOperandTypeEh;
    Operator1: TSTFilterOperatorEh;
    Operand1: TValue;
    Relation: TSTFilterOperatorEh; 
    Operator2: TSTFilterOperatorEh;
    Operand2: TValue;
  end;

{ TSortOrderItemProvEh }

  TSortOrderItemProvEh = class(TPersistent)
  protected
    function GetSortOrder: TSortOrderEh; virtual;
    function GetBaseListItem: TObject; virtual;
    function GetField: TField; virtual;
    function GetFieldName: String; virtual;
  public
    property FieldName: String read GetFieldName;
    property Field: TField read GetField;
    property BaseListItem: TObject read GetBaseListItem;
    property SortOrder: TSortOrderEh read GetSortOrder;
  end;

{ DatasetFeatures }

  TSimpleTextApplyFilterEh = procedure (Sender: TObject; DataSet: TDataSet;
    FieldName: String; Operation: TLSAutoFilterTypeEh; FilterText: String) of object;

  TDataSetClass = class of TDataSet;

{ TDataLinkEh }

{$IFDEF CIL}
  TDataEventEh = procedure (Event: TDataEvent; Info: TObject) of object;
{$ELSE}
  TDataEventEh = procedure (Event: TDataEvent; Info: Integer) of object;
{$ENDIF}

  TDataLinkEh = class(TDataLink)
  private
    FOnDataEvent: TDataEventEh;
  protected
    procedure DataEvent(Event: TDataEvent; Info: TDataEventInfoTypeEh); override;
  public
    property OnDataEvent: TDataEventEh read FOnDataEvent write FOnDataEvent;
  end;

{ TDatasetFieldValueListEh }

  TDatasetFieldValueListEh = class(TInterfacedObject, IMemTableDataFieldValueListEh)
  private
    FDataLink: TDataLinkEh;
    FDataObsoleted: Boolean;
    FDataSource: TDataSource;
    FFieldName: String;
    FValues: TStringList;

    function GetDataSet: TDataSet;
    function GetDataSource: TDataSource;
    function GetValues: TStrings;
    function GetCaseSensitive: Boolean;

    procedure SetDataSet(const Value: TDataSet);
    procedure SetCaseSensitive(const Value: Boolean);
    procedure SetDataSource(const Value: TDataSource);
    procedure SetFieldName(const Value: String);
  protected
    procedure RefreshValues;
{$IFDEF CIL}
    procedure DataSetEvent(Event: TDataEvent; Info: TObject); virtual;
{$ELSE}
    procedure DataSetEvent(Event: TDataEvent; Info: Integer); virtual;
{$ENDIF}
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetFilter(const Filter: String);

    property CaseSensitive: Boolean read GetCaseSensitive write SetCaseSensitive;
    property FieldName: String read FFieldName write SetFieldName;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property DataSet: TDataSet read GetDataSet write SetDataSet;
    property Values: TStrings read GetValues;
  end;

var

  STFilterOperatorsStrMapEh: array[TSTFilterOperatorEh] of String =
  ('', '=', '<>',
    '>', '<', '>=', '<=',
    '~', '!~',
    'In', '!In',
    {=}'Null', {<>}'Null',
    'AND', 'OR',
    '',
    {=}'Null', {<>}'Null');

{$IFDEF FPC}
  LFBr: String = '';
  RFBr: String = '';
{$ELSE}
  LFBr: String = '['; 
  RFBr: String = ']'; 
{$ENDIF}

const
  MemoTypes = [ftMemo, ftWideMemo, ftOraClob];

  STFldTypeMapEh: array[TFieldType] of TSTOperandTypeEh = (
    botNon{ftUnknown}, botString{ftString}, botNumber{ftSmallint}, botNumber{ftInteger}, botNumber{ftWord},
    botBoolean{ftBoolean}, botNumber{ftFloat}, botNumber{ftCurrency}, botNumber{ftBCD}, botDateTime{ftDate}, botDateTime{ftTime}, botDateTime{ftDateTime},
    botNon{ftBytes}, botNon{ftVarBytes}, botNumber{ftAutoInc}, botNon{ftBlob}, botString{ftMemo}, botString{ftGraphic}, botString{ftFmtMemo},
    botString{ftParadoxOle}, botString{ftDBaseOle}, botString{ftTypedBinary}, botString{ftCursor}, botString{ftFixedChar}, botString{ftWideString},
    botNumber{ftLargeint}, botString{ftADT}, botString{ftArray}, botNon{ftReference}, botNon{ftDataSet}
    ,botString{ftOraBlob}, botString{ftOraClob}, botString{ftVariant}, botNon{ftInterface}, botNon{ftIDispatch}, botString{ftGuid}
    , botDateTime{ftTimeStamp}, botNumber{ftFMTBcd}
{$IFDEF FPC}
    ,botString ,botString
{$ENDIF}
{$IFDEF EH_LIB_10}
    ,botString, botString, botNon, botString
{$ENDIF}
{$IFDEF EH_LIB_12}
    ,botNumber, botNumber, botNumber, botNumber, botNon, botNon, botNon
{$ENDIF}
{$IFDEF EH_LIB_13}
    ,botNon, botNon, botNumber
{$ENDIF}
{$IFDEF EH_LIB_37}
    ,botNumber
{$ENDIF}
    );

  STFilterOperatorsSQLStrMapEh: array[TSTFilterOperatorEh] of String =
  ('', '=', '<>',
    '>', '<', '>=', '<=',
    'LIKE', 'NOT LIKE',
    'IN', 'NOT IN',
    'IS NULL', 'IS NOT NULL',
    'AND', 'OR',
    '',
    '= NULL', '<> NULL'
    );

{$IFDEF TBookMarkAsTBytes}
  NilBookmarkEh = nil;
{$ELSE}
  NilBookmarkEh = '';
{$ENDIF}

  function CreateImageStream(StreamPersist: IStreamPersist): IImageStream; overload;
  function CreateImageStream(StreamPersist: TPersistent): IImageStream; overload;

procedure InitSTFilterOperatorsStrMap;

{ FilterExpression }

function ParseSTFilterExpressionEh(Exp: String; var FExpression: TSTFilterExpressionEh; DefaultOperator: TSTFilterDefaultOperatorEh): Boolean;
procedure ClearSTFilterExpression(var FExpression: TSTFilterExpressionEh);

function IsSQLBasedDataSet(DataSet: TDataSet; var SQL: TStrings): Boolean;
function IsDataSetHaveSQLLikeProp(DataSet: TDataSet; const SQLPropName: String; var SQLPropValue: WideString): Boolean;
procedure SetDataSetSQLLikeProp(DataSet: TDataSet; const SQLPropName: String; const SQLPropValue: WideString);

function CharAtPos(const S: String; Pos: Integer): Char;

var
  SQLFilterMarker: String = '/*FILTER*/';

type
  TRoughStringCompareProcEh = function (s1, s2: String): Integer;
  TRoughStringSearchEh = function (const SubStr, S: string;
    CaseInsensitive: Boolean; WholeWord: Boolean; Offset: Integer = 1): Integer;
  TMakeStringRoughEh = function (s: String): String;
  TStringPosProcEh = function (const SubStr, S: string; Offset: Integer): Integer;

var
  RoughStringCompareProcEh: TRoughStringCompareProcEh;
  RoughStringSearchProcEh: TRoughStringSearchEh;
  RoughStringPosProcEh: TStringPosProcEh;
  MakeStringRoughProcEh: TMakeStringRoughEh;

function DefaultRoughStringPosEh(SubStr, S: string; Offset: Integer): Integer;
function DefaultRoughStringCompareEh(s1, s2: String): Integer;
function DefaultCaseInsensitiveStringCompareEh(s1, s2: String): Integer;
function DefaultMakeStringRoughEh(s: String): String;
function DefaultRoughStringSearchEh(SubStr, S: string; CaseInsensitive: Boolean; WholeWord: Boolean; Offset: Integer = 1): Integer;
function StringIsMatchLikePattern(SourceStr: string; LikeExpr: string; IgnoreCase: Boolean; SingleCharWildcard: String; MultipleCharsWildcard: String): Boolean;

{ Useful routines to form filter string for dataset }

function GetOneExpressionAsLocalFilterString(O: TSTFilterOperatorEh;
  v: Variant; const FieldName: String; DataSet: TDataSet;
  DateValueToSQLStringProc: TDateValueToSQLStringProcEh;
  SupportsLike: Boolean;
  NullComparisonSyntax: TNullComparisonSyntaxEh;
  InOperIsSupported: Boolean = False): String;

function GetOneExpressionAsSQLWhereString(O: TSTFilterOperatorEh; v: Variant;
  const FieldName: String; DataSet: TDataSet;
  DateValueToSQLStringProc: TDateValueToSQLStringProcEh; SupportsLike: Boolean;
  NullComparisonSyntax: TNullComparisonSyntaxEh;
  InOperIsSupported: Boolean = False): String;

function DateValueToDataBaseSQLString(DataBaseName: String; v: Variant): String;
function DataSetBookmarkValid(DataSet: TDataSet; Bookmark: TUniBookmarkEh): Boolean;
function DataSetCompareBookmarks(DataSet: TDataSet; Bookmark1, Bookmark2: TUniBookmarkEh): Integer;
function GetFieldDisplayFormat(Field: TField): String;

function GetMasterDataSet(FDataSet: TDataSet; APropInfo: PPropInfo): TDataSet;

procedure GetFieldsProperty(List: Contnrs.TObjectList; DataSet: TDataSet;
  Control: TComponent; const FieldNames: String); overload;

function GetFieldsProperty(DataSet: TDataSet; Control: TComponent;
  const FieldNames: String): TFieldsArrEh; overload;

resourcestring

  SNotOperatorEh = 'Not';
  SAndOperatorEh = 'AND';
  SOrOperatorEh = 'OR';
  SLikePredicateEh = ''; 
  SInPredicateEh = 'In';
  SNullConstEh = 'Null';

implementation

uses
  {$IFDEF FPC}
  DBConst,
  {$ELSE}
  DBConsts,
  {$ENDIF}
  {$IFDEF EH_LIB_12} RTLConsts, {$ENDIF}
  MemTableDataEh,
  MemTableEh,
  StrUtils,
  EhLibLangConsts;

function StringIsMatchLikePattern(SourceStr: string; LikeExpr: string; IgnoreCase: Boolean;
  SingleCharWildcard: String; MultipleCharsWildcard: String): Boolean;
var
  SCWC, MCWC: Char;

  function InStr(const SourceStr: string; const LikeExpr: string): Integer;
  var
   i, j: Integer;
   Diff: Integer;
  begin
    if not UnuseOneCharLikeWildcardEh then
    begin
      i := Pos(SCWC, LikeExpr);
      if i = 0 then
      begin
        Result := Pos(LikeExpr, SourceStr);
        Exit;
      end;
    end;

    Diff := Length(SourceStr) - Length(LikeExpr);
    if Diff < 0 then
    begin
      Result := 0;
      Exit;
    end;

    for i := 0 to Diff do
    begin
      for j := 1 to Length(LikeExpr) do
      begin
        if (SourceStr[i + j] = LikeExpr[j]) or ((not UnuseOneCharLikeWildcardEh) and (LikeExpr[j] = SCWC)) then
        begin
          if j = Length(LikeExpr) then
          begin
            Result := i + 1;
            Exit;
          end;
        end
        else Break;
      end;
    end;

    Result := 0;
  end;

  function RestOfLineHaveStaticChars(Line: String; StartPos: Integer): Boolean;
  var
    i: Integer;
  begin
    Result := False;
    for i := StartPos to Length(Line) do
    begin
      if (Line[i] <> MCWC) and (Line[i] <> SCWC) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;


var
  LikeCurPos, SourceCurPos, SourceLen, LikeLen: Integer;
  i, iTemp: Integer;
  sTemp: string;
  OneCharWildcard: Boolean;
begin
  if SourceStr = LikeExpr then
  begin
    Result := True;
    Exit;
  end;

  if (Length(SingleCharWildcard) > 1) then
    raise Exception.Create('Multi-character value in a SingleCharWildcard variable is not supported.');
  if (Length(MultipleCharsWildcard) > 1) then
    raise Exception.Create('Multi-character value in a MultipleCharsWildcard variable is not supported.');

  SCWC := SingleCharWildcard[1]; 
  MCWC := MultipleCharsWildcard[1]; 

  repeat
    i := Pos(MCWC+MCWC, LikeExpr);
    if i > 0 then
      LikeExpr := Copy(LikeExpr, 1, i - 1) + MCWC + Copy(LikeExpr, i + 2, MaxInt);
  until i = 0;

  if not UnuseOneCharLikeWildcardEh then
  begin
    repeat
      i := Pos(SCWC+MCWC, LikeExpr);
      if i > 0 then
        LikeExpr := Copy(LikeExpr, 1, i - 1) + MCWC + Copy(LikeExpr, i + 2, MaxInt);
    until i = 0;
    repeat
      i := Pos(MCWC+SCWC, LikeExpr);
      if i > 0 then
        LikeExpr := Copy(LikeExpr, 1, i - 1) + MCWC + Copy(LikeExpr, i + 2, MaxInt);
    until i = 0;
  end;

  if LikeExpr = MCWC then
  begin
    Result := True;
    Exit;
  end;

  SourceLen := Length(SourceStr);
  LikeLen   := Length(LikeExpr);

  if (LikeLen = 0) or (SourceLen = 0) then
  begin
    Result := False;
    Exit;
  end;

  if IgnoreCase then
  begin
    SourceStr := AnsiUpperCase(SourceStr);
    LikeExpr  := AnsiUpperCase(LikeExpr);
  end;

  SourceCurPos := 1;
  LikeCurPos   := 1;
  Result := True;

  repeat
    if SourceStr[SourceCurPos] = LikeExpr[LikeCurPos] then
    begin
      Inc(LikeCurPos);
      Inc(SourceCurPos);
      Continue;
    end;

    if (not UnuseOneCharLikeWildcardEh) and (LikeExpr[LikeCurPos] = SCWC) then
    begin
      Inc(LikeCurPos);
      Inc(SourceCurPos);
      Continue;
    end;

    if LikeExpr[LikeCurPos] = MCWC then
    begin
      sTemp := Copy(LikeExpr, LikeCurPos + 1, LikeLen);
      i := Pos(MCWC, sTemp);
      if i > 0 then sTemp := Copy(sTemp, 1, i - 1);
      iTemp := Length(sTemp);

      if i = 0 then
      begin
        
        if iTemp = 0 then Exit;

        for i := 0 to iTemp - 1 do
        begin
          OneCharWildcard := not UnuseOneCharLikeWildcardEh and (sTemp[iTemp - i] = SCWC);
          if (sTemp[iTemp - i] <> SourceStr[SourceLen - i]) and
             not OneCharWildcard then
          begin
            Result := False;
            Exit;
          end;
        end;
        Exit;
      end;
      Inc(LikeCurPos, 1 + iTemp);

      i := InStr(Copy(SourceStr, SourceCurPos, MaxInt), sTemp);
      if i = 0 then
      begin
        Result := False;
        Exit;
      end;
      SourceCurPos := i + iTemp;
      Continue;
    end;

    Result := False;
    Break;
  until (SourceCurPos > SourceLen) or (LikeCurPos > LikeLen);

  if SourceCurPos <= SourceLen then
    Result := False;
  if (LikeCurPos <= LikeLen) and RestOfLineHaveStaticChars(LikeExpr, LikeCurPos) then
    Result := False;
end;

function RemoveDiacritics(s: String): String;
{$IFDEF FPC_CROSSP}
begin
  Result := s;
end;
{$ELSE}

{$IFDEF MSWINDOWS}
var
  Tmp: string;
  Len: integer;
  i: Integer;
{$IFDEF EH_LIB_14}
  sb: TStringBuilder;
{$ELSE}
  sb: String;
{$ENDIF}
begin
  Len := FoldString(MAP_COMPOSITE, PChar(s), -1, nil, 0);
  SetLength(Tmp, Len);
  FoldString(MAP_COMPOSITE, PChar(s), -1, PChar(Tmp), Len);

{$IFDEF EH_LIB_14}
  sb := TStringBuilder.Create('');
{$ELSE}
  sb := '';
{$ENDIF}
  for i := 1 to Length(Tmp) do
    if IsCharAlphaNumeric(Tmp[i]) or
       CharInSetEh(Tmp[i], [' ', '!','>','<','#',';',':','-','+']) or
       CharInSetEh(Tmp[i], ['-','=', '~','"','''','\','/','?','.']) or
       CharInSetEh(Tmp[i], [',',']','[','{','}','&','^','%','$','@'])
    then
{$IFDEF EH_LIB_14}
      sb.Append(Tmp[i]);

  Result := sb.ToString;
  sb.Free;
{$ELSE}
      sb := sb + Tmp[i];
  Result := sb;
{$ENDIF}
end;

{$ELSE}
begin
  Result := s;
end;
{$ENDIF} 

{$ENDIF} 

function GetFieldDisplayFormat(Field: TField): String;
begin
  if Field is TNumericField then
    Result := TNumericField(Field).DisplayFormat
  else if Field is TDateTimeField then
    Result := TDateTimeField(Field).DisplayFormat
{$IFDEF FPC}
{$ELSE}
  else if Field is TSQLTimeStampField then
    Result := TSQLTimeStampField(Field).DisplayFormat
  else if Field is TAggregateField then
    Result := TAggregateField(Field).DisplayFormat
{$ENDIF}
  else
    Result := '';
end;

function DataSetBookmarkValid(DataSet: TDataSet; Bookmark: TUniBookmarkEh): Boolean;
begin
  Result := (Bookmark <> NilBookmarkEh) and DataSet.BookmarkValid(TBookmark(Bookmark));
end;

function DataSetCompareBookmarks(DataSet: TDataSet; Bookmark1, Bookmark2: TUniBookmarkEh): Integer;
begin
  Result := DataSet.CompareBookmarks(TBookmark(Bookmark1), TBookmark(Bookmark2));
end;

function DefaultMakeStringRoughEh(s: String): String;
begin
  Result := RemoveDiacritics(s);
end;

function DefaultRoughStringPosEh(SubStr, S: string; Offset: Integer): Integer;
begin
  if @MakeStringRoughProcEh <> nil then
    SubStr := MakeStringRoughProcEh(SubStr);
  if @MakeStringRoughProcEh <> nil then
    S := MakeStringRoughProcEh(S);
  Result := PosEx(SubStr, S, Offset);
end;

function DefaultRoughStringSearchEh(SubStr, S: string; CaseInsensitive: Boolean;
  WholeWord: Boolean; Offset: Integer = 1): Integer;
begin
  if @MakeStringRoughProcEh <> nil then
    SubStr := MakeStringRoughProcEh(SubStr);
  if @MakeStringRoughProcEh <> nil then
    S := MakeStringRoughProcEh(S);
  Result := StringSearch(SubStr, S, CaseInsensitive, WholeWord, Offset);
end;

function DefaultRoughStringCompareEh(s1, s2: String): Integer;
begin
  if @MakeStringRoughProcEh <> nil then
    s1 := MakeStringRoughProcEh(s1);
  if @MakeStringRoughProcEh <> nil then
    s2 := MakeStringRoughProcEh(s2);
  Result := DefaultCaseInsensitiveStringCompareEh(s1, s2);
end;

function DefaultCaseInsensitiveStringCompareEh(s1, s2: String): Integer;
begin
  Result := AnsiCompareText(s1, s2);
end;

procedure SetDataSetSQLLikeProp(DataSet: TDataSet; const SQLPropName: String; const SQLPropValue: WideString);
var
  FPropInfo: PPropInfo;
begin
  FPropInfo := GetPropInfo(DataSet.ClassInfo, SQLPropName);
  if FPropInfo = nil then Exit;
  if PropType_getKind(PropInfo_getPropType(FPropInfo)) = tkString then
    SetStrProp(DataSet, FPropInfo, String(SQLPropValue))
{$IFDEF EH_LIB_12}
  else if PropType_getKind(PropInfo_getPropType(FPropInfo)) = tkUString then
    SetStrProp(DataSet, FPropInfo, SQLPropValue)
{$ENDIF}

{$IFDEF NEXTGEN}
{$ELSE}
  else if PropType_getKind(PropInfo_getPropType(FPropInfo)) = tkWString then
    SetWideStrProp(DataSet, FPropInfo, SQLPropValue)
{$ENDIF}

  else if PropType_getKind(PropInfo_getPropType(FPropInfo)) = tkClass then
    if TObject(GetOrdProp(DataSet, FPropInfo)) is TStrings then
      (TObject(GetOrdProp(DataSet, FPropInfo)) as TStrings).Text := String(SQLPropValue)
{$IFDEF CIL}
{$ELSE}
{$IFDEF NEXTGEN}
{$ELSE}
  {$IFDEF EH_LIB_9}
      {$IFDEF MSWINDOWS}
    else if TObject(GetOrdProp(DataSet, FPropInfo)) is TWideStrings then
      (TObject(GetOrdProp(DataSet, FPropInfo)) as TWideStrings).Text := SQLPropValue
      {$ELSE}
      {$ENDIF}
  {$ENDIF}
{$ENDIF}
{$ENDIF}
    ;
end;

procedure ClearSTFilterExpression(var FExpression: TSTFilterExpressionEh);
begin
  FExpression.Operator1 := foNon;
  FExpression.Operand1 := Null;
  FExpression.Relation := foNon;
  FExpression.Operator2 := foNon;
  FExpression.Operand2 := Null;
end;

procedure InitSTFilterOperatorsStrMap;
var
  NotOperator: String;
begin
  if SNotOperatorEh <> ''
    then NotOperator := SNotOperatorEh + ' '
    else NotOperator := 'Not ';
  if SLikePredicateEh <> '' then
  begin
    STFilterOperatorsStrMapEh[foLike] := SLikePredicateEh;
    STFilterOperatorsStrMapEh[foNotLike] := NotOperator + SLikePredicateEh;
  end;
  if SInPredicateEh <> '' then
  begin
    STFilterOperatorsStrMapEh[foIn] := SInPredicateEh;
    STFilterOperatorsStrMapEh[foNotIn] := NotOperator + SInPredicateEh;
  end;
  if SNullConstEh <> '' then
  begin
    STFilterOperatorsStrMapEh[foNull] := SNullConstEh;
    STFilterOperatorsStrMapEh[foNotNull] := SNullConstEh;
  end;
  if SAndOperatorEh <> '' then
    STFilterOperatorsStrMapEh[foAND] := SAndOperatorEh;
  if SOrOperatorEh <> '' then
    STFilterOperatorsStrMapEh[foOR] := SOrOperatorEh;
end;

function GetMasterDataSet(FDataSet: TDataSet; APropInfo: PPropInfo): TDataSet;
var
  PropValue: TDataSource;
  ObjectProp: TObject;
begin
  Result := nil;
  if (APropInfo <> nil) then
  begin
    if APropInfo^.PropType^.Kind = tkClass then
    try
      ObjectProp := GetObjectProp(FDataSet, APropInfo);
      if ObjectProp is TDataSource then
      begin
        PropValue := ObjectProp as TDataSource;
        if (PropValue <> nil) then
          Result := PropValue.DataSet;
      end else if ObjectProp is TDataSet then
      begin
        Result := ObjectProp as TDataSet;
      end else
      begin
        Result := nil;
      end;
    except 
    end;
  end;
end;

{$IFDEF FPC}
function NextCharIndex(const S: string; Index: Integer): Integer;
begin
  Result := Index + 1;
  assert((Index > 0) and (Index <= Length(S)));
  if SysLocale.FarEast and (S[Index] in LeadBytes) then
    Result := Index + StrCharLength(PChar(S) + Index - 1);
end;
{$ENDIF}

{ ParseSTFilterExpression }

type
  TOperator = (
    opNon, opEqual, opNotEqual,
    opGreaterThan, opLessThan, opGreaterOrEqual, opLessOrEqual,
    opLike,
    opIn,
    opAND, opOR,
    opValue,
    opNot, opComma, opOpenBracket, opCloseBracket, opQuote, opNullConst);

const
  OperatorAdvFilterOperatorMap: array[TOperator] of TSTFilterOperatorEh = (
    foNon, foEqual, foNotEqual,
    foGreaterThan, foLessThan, foGreaterOrEqual, foLessOrEqual,
    foLike,
    foIn,
    foAND, foOR,
    foValue,
    foNon, foNon, foNon, foNon, foNon, foNull);


function GetLexeme(const S: String; var Pos: Integer;
  var AOperator: TSTFilterOperatorEh;
  PreferCommaForList: Boolean;
  AutoDetectOperator: Boolean): Variant; forward;

function GetOperatorByWord(TheWord: String): TOperator;
begin
  Result := opNon;
  TheWord := AnsiUpperCase(TheWord);
  if (TheWord = 'NOT') or
     ((SNotOperatorEh <> '') and (TheWord = AnsiUpperCase(SNotOperatorEh))) then
    Result := opNot
  else if (TheWord = 'AND') or
          ((SAndOperatorEh <> '') and (TheWord = AnsiUpperCase(SAndOperatorEh))) then
    Result := opAND
  else if (TheWord = 'OR') or
          ((SOrOperatorEh <> '') and (TheWord = AnsiUpperCase(SOrOperatorEh))) then
    Result := opOR
  else if (TheWord = 'LIKE') or
          ((SLikePredicateEh <> '') and (TheWord = AnsiUpperCase(SLikePredicateEh))) then
    Result := opLIKE
  else if (TheWord = 'IN') or
          ((SInPredicateEh <> '') and (TheWord = AnsiUpperCase(SInPredicateEh))) then
    Result := opIN
  else if (TheWord = 'NULL') or
          ((SNullConstEh <> '') and (TheWord = AnsiUpperCase(SNullConstEh))) then
    Result := opNullConst;
end;

procedure ConvertVarStrValues(var v: Variant; ot: TSTOperandTypeEh);
var
  i: Integer;

  function StrToDateTimeEh(const s: String): Variant;
  begin
    if  SameText(s, 'NOW')
      then Result := s
      else Result := StrToDateTime(s);
  end;

begin
  if ot = botNumber then
  begin
    if not VarIsNull(v) then
      if VarIsArray(v) then
        for i := VarArrayLowBound(v, 1) to VarArrayHighBound(v, 1) do
          if VarIsNull(v[i]) then
            v[i] := v[i]
          else if SameText(VarToStr(v[i]), 'Null') then
            v[i] := Null
          else
            v[i] := StrToFloat(v[i])
      else
        v := StrToFloat(v);
  end
  else if ot = botDateTime then
  begin
    if not VarIsNull(v) then
      if VarIsArray(v) then
        for i := VarArrayLowBound(v, 1) to VarArrayHighBound(v, 1) do
          if VarIsNull(v[i]) then
            v[i] := v[i]
          else if SameText(v[i], 'Null') then
            v[i] := Null
          else
            v[i] := StrToDateTimeEh(v[i])
      else
        v := StrToDateTimeEh(v);
  end
  else if ot = botBoolean then
  begin
    if not VarIsNull(v) then
    begin
      if VarIsArray(v) then
      begin
        for i := VarArrayLowBound(v, 1) to VarArrayHighBound(v, 1) do
          if VarIsNull(v[i]) then
            v[i] := v[i]
          else if SameText(v[i], 'Null') then
            v[i] := Null
          else
            v[i] := StrToBool(v[i])
      end
      else
        v := StrToBool(v);
    end;
  end;
end;

function SkipBlanks(const s: String; Pos: Integer): Integer;
var
  i: Integer;
begin
  Result := Pos;
  for i := Pos to Length(s) do
    if s[i] <> ' ' then
    begin
      Result := i;
      Break;
    end
end;

procedure SetOperatorPos(var Pos: Integer; Increment: Integer; var Op: TOperator; NewOp: TOperator);
begin
  Inc(Pos, Increment);
  Op := NewOp;
end;

function CharAtPos(const S: String; Pos: Integer): Char;
begin
  if (Length(S) < Pos) or (Pos <= 0) then
    Result := #0
  else
    Result := S[Pos];
end;

function ReadValue(const S: String; var Pos: Integer; PreferCommaForList: Boolean): Variant;

  function CheckForOperand(const S: String; Pos: Integer): Boolean;
  var
    AOperator: TSTFilterOperatorEh;
  begin
    GetLexeme(S, Pos, AOperator, PreferCommaForList, False);
    if AOperator in [foEqual..foOR] then
      Result := True
    else
      Result := False;
  end;

var
  i: Integer;
  InSpecSign: Boolean;
  sVal: String;
begin
  Result := Unassigned;
  if Pos > Length(S) then
    Exit;
  if S[Pos] = '''' then
  begin
    InSpecSign := False;
    for i := Pos + 1 to Length(S) do
    begin
      if (S[i] = '''') and not InSpecSign then
      begin
        Result := VarToStr(Result) + Copy(S, Pos + 1, i - Pos - 1);
        if CharAtPos(S,i+1) = '''' then
        begin
          Pos := i;
          InSpecSign := True
        end else
        begin
          Pos := i + 1;
          Exit;
        end;
      end else
        InSpecSign := False;
    end;

    raise Exception.Create(EhLibLanguageConsts.QuoteIsAbsentEh + S);
  end
  else
  begin
    for i := Pos to Length(S) do
    begin
      if ( CharInSetEh(S[i], [' ']) and CheckForOperand(S, SkipBlanks(S, i))) or
        ( CharInSetEh(S[i], [')', '(']) ) or
        (PreferCommaForList and (S[i] = ',')) then
      begin
        sVal := Copy(S, Pos, i - Pos);
        if UpperCase(sVal) = 'NULL'
          then Result := Null
          else Result := sVal;
        Pos := i;
        Exit;
      end;
    end;
    Result := Copy(S, Pos, MAXINT);
    Pos := Length(S) + 1;
  end;
end;

function ReadValues(const S: String; var Pos: Integer; PreferCommaForList: Boolean): Variant;
var
  i: Integer;
  vArr: Variant;
begin
  i := 0;
  vArr := VarArrayCreate([0, 0], varVariant);
  while True do
  begin
    vArr[i] := ReadValue(S, Pos, PreferCommaForList);
    if VarIsClear(vArr[i]) then
      Break;
    if PreferCommaForList and (CharAtPos(S, Pos) = ',') then
      Inc(Pos)
    else
      Break;
    Inc(i);
    VarArrayRedimEh(vArr, i);
  end;
  if i = 0 then
    Result := vArr[0]
  else
    Result := vArr;
end;

function GetLexeme(const S: String; var Pos: Integer; var AOperator: TSTFilterOperatorEh;
  PreferCommaForList: Boolean; AutoDetectOperator: Boolean): Variant;
var
  Oper: TOperator;
  Operator1: TSTFilterOperatorEh;
  TheWord: String;

  function ReadWord(const S: String; Pos: Integer): String;
  var
    c: Char;
    NextPos: Integer;
  begin
    Result := '';
    while True do
    begin
      c := CharAtPos(S, Pos);
      if (c < #32) or CharInSetEh(c, [' ','(',')','>','<','=','!','~','&','|','.',',','''','"','+','-']) then
        Exit;
      NextPos := NextCharIndex(S,Pos);
      Result := Result + Copy(S,Pos,NextPos-Pos);
      Pos := NextPos;
    end;
  end;

begin
  if not (AOperator in [foIn, foNotIn]) then
    AOperator := foNon;
  Oper := opNon;
  Result := '';
  if Length(S) < Pos then
    Exit;
  if (S[Pos] = '''') or (AOperator in [foIn, foNotIn]) then
  begin
    Result := ReadValues(S, Pos, PreferCommaForList);
    if VarIsArray(Result)
      then AOperator := foIn
      else AOperator := foValue;
  end
  else
  begin
    case S[Pos] of

      '!':
        if CharAtPos(S, Pos + 1) = '=' then
          SetOperatorPos(Pos, 2, Oper, opNotEqual)
        else
          SetOperatorPos(Pos, 1, Oper, opNot);
      '=':
        SetOperatorPos(Pos, 1, Oper, opEqual);
      '(':
        SetOperatorPos(Pos, 1, Oper, opOpenBracket);

      '>':
        if CharAtPos(S, Pos + 1) = '=' then
          SetOperatorPos(Pos, 2, Oper, opGreaterOrEqual)
        else
          SetOperatorPos(Pos, 1, Oper, opGreaterThan);
      '<':
        if CharAtPos(S, Pos + 1) = '=' then
          SetOperatorPos(Pos, 2, Oper, opLessOrEqual)
        else if CharAtPos(S, Pos + 1) = '>' then
          SetOperatorPos(Pos, 2, Oper, opNotEqual)
        else
          SetOperatorPos(Pos, 1, Oper, opLessThan);
      '~':
        SetOperatorPos(Pos, 1, Oper, opLike);
      '&':
        SetOperatorPos(Pos, 1, Oper, opAnd); 
      '|':
        SetOperatorPos(Pos, 1, Oper, opOr); 
    else
      TheWord := ReadWord(S,Pos);
      Oper := GetOperatorByWord(TheWord);
      if Oper <> opNon then
        Inc(Pos, Length(TheWord));
    end;

    if (Oper = opNon) and AutoDetectOperator then
    begin
      Result := ReadValues(S, Pos, PreferCommaForList);
      if VarIsNull(Result) then
        AOperator := foNon
      else if VarIsArray(Result) then
        AOperator := foIn
      else
        AOperator := foValue;
      Exit;
    end;

    Pos := SkipBlanks(S, Pos);

    if Oper = opNot then
    begin
      GetLexeme(S, Pos, Operator1, PreferCommaForList, True);
      case Operator1 of
        foLike: AOperator := foNotLike;
        foIn: AOperator := foNotIn;
        foNull: AOperator := foNotNull;
      end
    end
    else if Oper = opIn then
    begin
      if CharAtPos(S, Pos) = '(' then
        Inc(Pos)
      else
        raise Exception.Create(EhLibLanguageConsts.LeftBracketExpectedEh + S);
      AOperator := foIn;
    end
    else
      AOperator := OperatorAdvFilterOperatorMap[Oper];
  end;
end;

function ParseSTFilterExpression(Exp: String; var FExpression: TSTFilterExpressionEh): Boolean;

var
  PreferCommaForList: Boolean;

  procedure ResetPreferCommaForList;
  begin
    if (FExpression.ExpressionType = botNumber) and (FormatSettings.DecimalSeparator = ',') then
      PreferCommaForList := False
    else
      PreferCommaForList := True;
  end;

var
  v: Variant;
  op, op1: TSTFilterOperatorEh;
  p: Integer;
begin
  Result := False;

  ResetPreferCommaForList;

  FExpression.Operator1 := foNon;
  FExpression.Operand1 := Null;
  FExpression.Relation := foNon;
  FExpression.Operator2 := foNon;
  FExpression.Operand2 := Null;

  Exp := Trim(Exp);
  if Exp = '' then
    Exit;
  p := SkipBlanks(Exp, 1);
  v := GetLexeme(Exp, p, op, PreferCommaForList, True);
  if op = foValue then
  begin
    if VarIsArray(v) then
      FExpression.Operator1 := foIn
    else if FExpression.ExpressionType = botString then
      FExpression.Operator1 := foLike
    else
      FExpression.Operator1 := foEqual;
    FExpression.Operand1 := v;
  end
  else if (op = foNon) and (Length(Exp) <> 0) then
    raise Exception.Create(EhLibLanguageConsts.ErrorInExpressionEh + Exp)
  else
  begin
    if op in [foIn, foNotIn] then
      PreferCommaForList := True;
    p := SkipBlanks(Exp, p);
    v := GetLexeme(Exp, p, op1, PreferCommaForList, True);
    FExpression.Operator1 := op;
    if op1 = foNull then
      if op = foEqual then
        FExpression.Operator1 := foNull
      else if op = foNotEqual then
        FExpression.Operator1 := foNotNull
      else
        raise Exception.Create(EhLibLanguageConsts.UnexpectedExpressionBeforeNullEh + Exp)
    else if op1 <> foValue then
      raise Exception.Create(EhLibLanguageConsts.UnexpectedExpressionAfterOperatorEh + Exp);
    FExpression.Operand1 := v;
    if op in [foIn, foNotIn] then
    begin
      p := SkipBlanks(Exp, p);
      if CharAtPos(Exp, p) = ')' then
        Inc(p)
      else
        raise Exception.Create(EhLibLanguageConsts.RightBracketExpectedEh + Exp);
      ResetPreferCommaForList;
    end;
  end;

  while True do
  begin
    p := SkipBlanks(Exp, p);
    v := GetLexeme(Exp, p, op, PreferCommaForList, True);
    if op = foNon then
      if p <> Length(Exp) + 1 then
        raise Exception.Create(EhLibLanguageConsts.IncorrectExpressionEh + Exp)
      else
        Break;
    if not (op in [foAND, foOR]) then
      raise Exception.Create(EhLibLanguageConsts.UnexpectedANDorOREh + Exp);
    FExpression.Relation := op;

    p := SkipBlanks(Exp, p);
    v := GetLexeme(Exp, p, op, PreferCommaForList, True);
    if op = foNon then
      if p <> Length(Exp) + 1 then
        raise Exception.Create(EhLibLanguageConsts.IncorrectExpressionEh + Exp)
      else
        Break;
    if op = foValue then
    begin
      if VarIsArray(v) then
        FExpression.Operator2 := foIn
      else if FExpression.ExpressionType = botString then
        FExpression.Operator2 := foLike
      else
        FExpression.Operator2 := foEqual;
      FExpression.Operand2 := v;
    end
    else if (op = foNon) and (Length(Exp) <> 0) then
      raise Exception.Create(EhLibLanguageConsts.ErrorInExpressionEh + Exp)
    else
    begin
      if op in [foIn, foNotIn] then
        PreferCommaForList := True;
      p := SkipBlanks(Exp, p);
      v := GetLexeme(Exp, p, op1, PreferCommaForList, True);
      FExpression.Operator2 := op;
      if op1 = foNull then
        if op = foEqual then
          FExpression.Operator2 := foNull
        else if op = foNotEqual then
          FExpression.Operator2 := foNotNull
        else
          raise Exception.Create(EhLibLanguageConsts.UnexpectedExpressionBeforeNullEh + Exp)
      else if op1 <> foValue then
        raise Exception.Create(EhLibLanguageConsts.UnexpectedExpressionAfterOperatorEh + Exp);
      FExpression.Operand2 := v;
      ResetPreferCommaForList;
    end;
    Result := True;
    Break;
  end;

  if FExpression.Operator1 in [foEqual..foNotIn] then
    ConvertVarStrValues(FExpression.Operand1, FExpression.ExpressionType)
  else
    FExpression.Operand1 := Null;

  if FExpression.Operator2 in [foEqual..foNotIn] then
    ConvertVarStrValues(FExpression.Operand2, FExpression.ExpressionType)
  else
    FExpression.Operand2 := Null;
end;

function ParseSTFilterExpressionEh(Exp: String;
  var FExpression: TSTFilterExpressionEh;
  DefaultOperator: TSTFilterDefaultOperatorEh): Boolean;
var
  PreferCommaForList: Boolean;

  procedure ResetPreferCommaForList;
  begin
    PreferCommaForList := False
  end;

  procedure MakeSimpleLike;
  begin
    FExpression.Operator1 := foLike;
    FExpression.Operand1 := Exp;
    FExpression.Relation := foNon;
    FExpression.Operator2 := foNon;
    FExpression.Operand2 := Null;
  end;

const
  OperatorForDefaultOperators: array[TSTFilterDefaultOperatorEh] of
    TSTFilterOperatorEh = (
      foNon, foEqual, foNotEqual,
      foGreaterThan, foLessThan, foGreaterOrEqual, foLessOrEqual,
      foLike, foNotLike,
      foIn, foNotIn,
      foLike, foNotLike,
      foLike, foNotLike,
      foLike, foNotLike);
var
  v: Variant;
  op, op1: TSTFilterOperatorEh;
  p: Integer;
  NoClosedComma: Boolean;
begin
  Result := False;

  ResetPreferCommaForList;

  FExpression.Operator1 := foNon;
  FExpression.Operand1 := Null;
  FExpression.Relation := foNon;
  FExpression.Operator2 := foNon;
  FExpression.Operand2 := Null;

  Exp := Trim(Exp);
  if Exp = '' then
    Exit;
  p := SkipBlanks(Exp, 1);
  v := GetLexeme(Exp, p, op, PreferCommaForList, True);
  if op = foValue then
  begin
    if DefaultOperator <> fdoAuto then
    begin
      FExpression.Operator1 := OperatorForDefaultOperators[DefaultOperator];
      if DefaultOperator in [fdoBeginsWith, fdoContains, fdoDoesntContain] then
      begin
        v := VarToStr(v);
        if CharAtPos(v, 1) <> '%' then
          v := v + '%';
      end;
      if DefaultOperator in [fdoEndsWith, fdoDoesntEndWith, fdoContains, fdoDoesntContain] then
      begin
        v := VarToStr(v);
        if CharAtPos(v, 1) <> '%' then
          v := '%' + v;
      end;
    end else if VarIsArray(v) then
      FExpression.Operator1 := foIn
    else if FExpression.ExpressionType = botString then
      FExpression.Operator1 := foLike
    else
      FExpression.Operator1 := foEqual;
    FExpression.Operand1 := v;
  end
  else if (op = foNon) and (Length(Exp) <> 0) then
    raise Exception.Create(EhLibLanguageConsts.ErrorInExpressionEh + Exp)
  else
  begin
    if op in [foIn, foNotIn] then
      PreferCommaForList := True;
    p := SkipBlanks(Exp, p);
    FExpression.Operator1 := op;
    NoClosedComma := False;
    op1 := op;
    if VarEquals(v, '') then
    begin
      v := GetLexeme(Exp, p, op1, PreferCommaForList, True);
      if op1 = foNull then
      begin
        if (op in [foIn, foNotIn]) then
          v := Null
        else if op = foEqual then
          FExpression.Operator1 := foNull
        else if op = foNotEqual then
          FExpression.Operator1 := foNotNull
        else
        begin
          MakeSimpleLike;
          Exit;
        end;
      end else if not (op1 in [foValue, foIn]) then
          raise Exception.Create(EhLibLanguageConsts.UnexpectedExpressionAfterOperatorEh + Exp);
    end else
      NoClosedComma := True;
    FExpression.Operand1 := v;
    if op in [foIn, foNotIn] then
    begin
      p := SkipBlanks(Exp, p);
      if CharAtPos(Exp, p) = ')' then
        Inc(p)
      else if not NoClosedComma then
      begin
        MakeSimpleLike;
        Exit;
      end;
      ResetPreferCommaForList;
    end;
  end;

  while True do
  begin
    p := SkipBlanks(Exp, p);
    op := foNon;
    v := GetLexeme(Exp, p, op, PreferCommaForList, True);
    if op = foNon then
      if p <> Length(Exp) + 1 then
      begin
        MakeSimpleLike;
        Exit;
      end else
        Break;
    if not (op in [foAND, foOR]) then
      raise Exception.Create(EhLibLanguageConsts.UnexpectedANDorOREh + Exp);
    FExpression.Relation := op;

    p := SkipBlanks(Exp, p);
    v := GetLexeme(Exp, p, op, PreferCommaForList, True);
    if op = foNon then
      if p <> Length(Exp) + 1 then
        raise Exception.Create(EhLibLanguageConsts.IncorrectExpressionEh + Exp)
      else
        Break;
    if op = foValue then
    begin
      if VarIsArray(v) then
        FExpression.Operator2 := foIn
      else if FExpression.ExpressionType = botString then
        FExpression.Operator2 := foLike
      else
        FExpression.Operator2 := foEqual;
      FExpression.Operand2 := v;
    end
    else if (op = foNon) and (Length(Exp) <> 0) then
      raise Exception.Create(EhLibLanguageConsts.ErrorInExpressionEh + Exp)
    else
    begin
      if op in [foIn, foNotIn] then
        PreferCommaForList := True;
      p := SkipBlanks(Exp, p);
      v := GetLexeme(Exp, p, op1, PreferCommaForList, True);
      FExpression.Operator2 := op;
      if op1 = foNull then
        if op = foEqual then
          FExpression.Operator2 := foNull
        else if op = foNotEqual then
          FExpression.Operator2 := foNotNull
        else
          raise Exception.Create(EhLibLanguageConsts.UnexpectedExpressionBeforeNullEh + Exp)
      else if (op1 <> foValue) and (op1 <> foIn) then
        raise Exception.Create(EhLibLanguageConsts.UnexpectedExpressionAfterOperatorEh + Exp);
      FExpression.Operand2 := v;
      ResetPreferCommaForList;
    end;
    Result := True;
    Break;
  end;

  if (FExpression.Relation in [foAND, foOR]) and (FExpression.Operator2 = foNon) then
    raise Exception.Create(EhLibLanguageConsts.ErrorInExpressionEh + Exp);

  if FExpression.Operator1 in [foEqual..foNotIn] then
    ConvertVarStrValues(FExpression.Operand1, FExpression.ExpressionType)
  else
    FExpression.Operand1 := Null;

  if FExpression.Operator2 in [foEqual..foNotIn] then
    ConvertVarStrValues(FExpression.Operand2, FExpression.ExpressionType)
  else
    FExpression.Operand2 := Null;
end;

function GetOneExpressionAsLocalFilterString(O: TSTFilterOperatorEh; v: Variant;
  const FieldName: String; DataSet: TDataSet;
  DateValueToSQLStringProc: TDateValueToSQLStringProcEh;
  SupportsLike: Boolean;
  NullComparisonSyntax: TNullComparisonSyntaxEh;
  InOperIsSupported: Boolean = False): String;

  function VarValueAsFilterStr(v: Variant): String;
  begin
    if VarType(v) = varDouble then
      Result := FloatToStr(v)
    else if VarType(v) = varDate then
      if @DateValueToSQLStringProc <> nil then
        Result := DateValueToSQLStringProc(Dataset, v)
      else
        Result := '''' + DateTimeToStr(v) + ''''
    else
    begin
      Result := VarToStr(v);
      Result := StringReplace(Result, '''', '''''',[rfReplaceAll]);
      Result := '''' + Result + '''';
    end;
  end;

  function ComposeExpressionForFieldList(FieldNames: String;
    O: TSTFilterOperatorEh; var VarValues: Variant): String;
  var
    Pos, i: Integer;
    FieldName: String;
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
      if not (O in [foNull, foNotNull, foEqualToNull, foNotEqualToNull]) then
        Result := Result + ' ' + VarValueAsFilterStr(VarValues[i]);
      Inc(i);
    end;
    Result := Result + ' )';
  end;

  function GetIsNullExpression(O: TSTFilterOperatorEh): String;
  {$IFDEF FPC}
  var
    ASign: String;
    DataType: TFieldType;
  {$ELSE}
  {$ENDIF}
  begin
    {$IFDEF FPC}
    if O in [foNull, foEqualToNull]
      then ASign := ' = '
      else ASign := ' <> ';
    DataType := DataSet.FieldByName(FieldName).DataType;
    if DataType in
         [ftString, ftMemo, ftFmtMemo,
          ftDate, ftTime, ftDateTime,
          ftFixedChar, ftWideString, ftOraClob, ftGuid, ftFixedWideChar, ftWideMemo
          {$IFDEF EH_LIB_10}, ftOraInterval{$ENDIF}]
    then
    begin
      Result := ASign + '''''';
    end
    else if DataType in [ftSmallint, ftInteger, ftWord, ftBoolean, ftFloat, ftCurrency, ftBCD,
        ftAutoInc, ftLargeint, ftFMTBcd] then
    begin
      Result := ASign + '0';
    end else
      Result := ASign + '''''';
    {$ELSE}
    Result := STFilterOperatorsSQLStrMapEh[O];
    {$ENDIF}
  end;

var
  i: Integer;
  vin: Variant;
  AddIsNull: Boolean;
begin
  Result := '';
  if (O = foNull) and (NullComparisonSyntax = ncsAsEqualToNullEh) then
    O := foEqualToNull;
  if (O = foNotNull) and (NullComparisonSyntax = ncsAsEqualToNullEh) then
    O := foNotEqualToNull;

  if O in [foIn, foNotIn] then
  begin
    AddIsNull := False;
    Result := Result + ' (';
    if InOperIsSupported and VarIsArray(v) then
    begin
      if O = foIn then
        Result := Result +  LFBr + FieldName + RFBr + ' In('
      else
        Result := Result +  LFBr + FieldName + RFBr + ' Not In(';
    end else
    begin
      if O = foNotIn then
        Result := ' NOT' + Result;
    end;
    if VarIsArray(v) then
    begin
      for i := VarArrayLowBound(v, 1) to VarArrayHighBound(v, 1) do
      begin
        if Pos(';', FieldName) <> 0 then
        begin
          vin := v[i];
          Result := Result + ComposeExpressionForFieldList(FieldName, foEqual, vin)  + ' OR '
        end else if InOperIsSupported then
        begin
          if VarIsNull(v[i]) then
            AddIsNull := True
          else
            Result := Result + VarValueAsFilterStr(v[i]) + ' ,  ';
        end else if VarIsNull(v[i]) then
          Result := Result + LFBr + FieldName + RFBr + ' ' + GetIsNullExpression(foNull) + ' OR '
        else
          Result := Result + LFBr + FieldName + RFBr +' = ' + VarValueAsFilterStr(v[i]) + ' OR ';
      end;
    end else
    begin
      if Pos(';', FieldName) <> 0 then
        Result := ComposeExpressionForFieldList(FieldName, foEqual, v)  + ' OR '
      else
        Result := Result + LFBr + FieldName + RFBr +' = ' + VarValueAsFilterStr(v) + ' OR ';
    end;
    Delete(Result, Length(Result) - 3, 4);
    if InOperIsSupported and VarIsArray(v) then
      Result := Result + ') ';
    if AddIsNull then
      Result := Result + ' OR ' + LFBr + FieldName + RFBr +' Is Null ';

    Result := Result + ')';
  end
  else if O in [foLike, foNotLike] then
  begin
    Result := Result +  ' ' + LFBr + FieldName;
    if SupportsLike then
      if O = foLike
        then Result := Result + RFBr + ' Like '
        else Result := ' Not (' + Result + RFBr + ' Like '
    else
      if O = foLike
        then Result := Result + RFBr + ' = '
        else Result := Result + RFBr + ' <> ';
    Result := Result + VarValueAsFilterStr(v);
    if SupportsLike and (O = foNotLike) then
      Result := Result + ')';
  end else
  begin
    if Pos(';', FieldName) <> 0 then
      Result := ComposeExpressionForFieldList(FieldName, O, v)
    else
    begin
      if (O in [foNull, foNotNull, foEqualToNull, foNotEqualToNull]) then
      begin
        Result := Result +  ' ' + LFBr + FieldName + RFBr + GetIsNullExpression(O);
      end
      else
      begin
        Result := Result +  ' ' + LFBr + FieldName + RFBr + ' ' + STFilterOperatorsSQLStrMapEh[O];
        Result := Result + ' ' + VarValueAsFilterStr(v);
      end;
    end;
  end;
end;

function GetOneExpressionAsSQLWhereString(O: TSTFilterOperatorEh; v: Variant;
  const FieldName: String; DataSet: TDataSet;
  DateValueToSQLStringProc: TDateValueToSQLStringProcEh;
  SupportsLike: Boolean;
  NullComparisonSyntax: TNullComparisonSyntaxEh;
  InOperIsSupported: Boolean = False): String;

  function VarValueAsFilterStr(v: Variant): String;
  var
{$IFDEF CIL}
    OldDecimalSeparator: String;
{$ELSE}
    OldDecimalSeparator: Char;
{$ENDIF}
   VType: TVarType;
  begin
    VType := VarType(v);
    if VarIsNumericType(v) then
    begin
      OldDecimalSeparator := FormatSettings.DecimalSeparator;
      FormatSettings.DecimalSeparator := '.';
      try
        Result := FloatToStr(v);
      finally
        FormatSettings.DecimalSeparator := OldDecimalSeparator;
      end;
    end
    else if VType = varDate then
      if @DateValueToSQLStringProc <> nil then
        Result := DateValueToSQLStringProc(DataSet, v)
      else
        Result := '''' + VarToStr(v) + ''''
    else
    begin
      Result := VarToStr(v);
      Result := StringReplace(Result, '''', '''''',[rfReplaceAll]);
      Result := '''' + Result + '''';
    end;
  end;

var
  i: Integer;
  theNOT: String;
begin
  Result := '';
  if (O = foNull) and (NullComparisonSyntax = ncsAsEqualToNullEh) then
    O := foEqualToNull;
  if (O = foNotNull) and (NullComparisonSyntax = ncsAsEqualToNullEh) then
    O := foNotEqualToNull;

  if O in [foIn, foNotIn] then
  begin
    if O = foNotIn then
      theNOT := ' NOT'
    else
      theNOT := '';
    Result := Result + FieldName + theNOT + ' IN (';
    if VarIsArray(v) then
      for i := VarArrayLowBound(v, 1) to VarArrayHighBound(v, 1) do
        Result := Result + VarValueAsFilterStr(v[i]) + ','
    else
      Result := Result + VarValueAsFilterStr(v) + ',';
    Delete(Result, Length(Result), 1);
    Result := Result + ')';
  end else
  begin
    Result := Result + ' ' + FieldName + ' ' + STFilterOperatorsSQLStrMapEh[O];
    if not (O in [foNull, foNotNull, foEqualToNull, foNotEqualToNull]) then
      Result := Result + ' ' + VarValueAsFilterStr(v);
  end;
end;

function DateValueToDataBaseSQLString(DataBaseName: String; v: Variant): String;
var
{$IFDEF CIL}
  OldDateSeparator: String;
{$ELSE}
  OldDateSeparator: Char;
{$ENDIF}
begin
  DataBaseName := UpperCase(DataBaseName);
  if DataBaseName = 'STANDARD' then
    Result := '''' + VarToStr(v) + ''''
  else if DataBaseName = 'ORACLE' then
    Result := 'TO_DATE(''' + FormatDateTime(FormatSettings.ShortDateFormat, v) + ''',''' + FormatSettings.ShortDateFormat + ''')'
  else if DataBaseName = 'INTRBASE' then
    Result := '''' + VarToStr(v) + ''''
  else if DataBaseName = 'INFORMIX' then
    Result := '''' + VarToStr(v) + ''''
  else if DataBaseName = 'MSACCESS' then
  begin
    OldDateSeparator := FormatSettings.DateSeparator;
    try
      FormatSettings.DateSeparator := '/';
      Result := '#' + FormatDateTime('MM/DD/YYYY', v) + '#';
    finally
      FormatSettings.DateSeparator := OldDateSeparator;
    end;
  end
  else if DataBaseName = 'MSSQL' then
    Result := QuotedStr(FormatDateTime('yyyymmdd hh:nn:ss', v))
  else if DataBaseName = 'SYBASE' then
    Result := '''' + VarToStr(v) + ''''
  else if DataBaseName = 'DB2' then
    Result := '''' + VarToStr(v) + ''''
  else
    Result := '''' + VarToStr(v) + '''';
end;

{ Sorting }

function IsSQLBasedDataSet(DataSet: TDataSet; var SQL: TStrings): Boolean;
var
  FPropInfo: PPropInfo;
begin
  Result := False;
  SQL := nil;
  FPropInfo := GetPropInfo(DataSet.ClassInfo, 'SQL');
  if FPropInfo = nil then Exit;
  if PropType_getKind(PropInfo_getPropType(FPropInfo)) = tkClass then
  try
    SQL := (TObject(GetOrdProp(DataSet, FPropInfo)) as TStrings);
  except 
  end;

  if SQL <> nil then
    Result := True;
end;

function IsDataSetHaveSQLLikeProp(DataSet: TDataSet; const SQLPropName: String; var SQLPropValue: WideString): Boolean;
var
  FPropInfo: PPropInfo;
begin
  Result := False;
  SQLPropValue := '';
  FPropInfo := GetPropInfo(DataSet.ClassInfo, SQLPropName);
  if FPropInfo = nil then Exit;
  if PropType_getKind(PropInfo_getPropType(FPropInfo)) = tkString then
    SQLPropValue := WideString(GetStrProp(DataSet, FPropInfo))
{$IFDEF EH_LIB_12}
  else if PropType_getKind(PropInfo_getPropType(FPropInfo)) = tkUString then
    SQLPropValue := GetStrProp(DataSet, FPropInfo)
{$ENDIF}

{$IFDEF NEXTGEN}
{$ELSE}
  else if PropType_getKind(PropInfo_getPropType(FPropInfo)) = tkWString then
    SQLPropValue := GetWideStrProp(DataSet, FPropInfo)
{$ENDIF}

  else if PropType_getKind(PropInfo_getPropType(FPropInfo)) = tkClass then
    try
      if TObject(GetOrdProp(DataSet, FPropInfo)) is TStrings then
        SQLPropValue := WideString((TObject(GetOrdProp(DataSet, FPropInfo)) as TStrings).Text)
{$IFDEF CIL}
{$ELSE}
  {$IFDEF NEXTGEN}
  {$ELSE}
    {$IFDEF EH_LIB_9}
      {$IFDEF MSWINDOWS}
      else if TObject(GetOrdProp(DataSet, FPropInfo)) is TWideStrings then
        SQLPropValue := (TObject(GetOrdProp(DataSet, FPropInfo)) as TWideStrings).Text
      {$ELSE}
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
      else
        Exit;
    except 
    end
  else Exit;
  Result := True;
end;

procedure GetFieldsProperty(List: Contnrs.TObjectList; DataSet: TDataSet;
  Control: TComponent; const FieldNames: String);
var
  Pos: Integer;
  Field: TField;
  FieldName: String;
begin
  Pos := 1;
  while Pos <= Length(FieldNames) do
  begin
    FieldName := ExtractFieldName(FieldNames, Pos);
    Field := DataSet.FindField(FieldName);
    if Field = nil then
      DatabaseErrorFmt(SFieldNotFound, [FieldName], Control);
    if Assigned(List) then List.Add(Field);
  end;
end;

function GetFieldsProperty(DataSet: TDataSet; Control: TComponent;
  const FieldNames: String): TFieldsArrEh;
var
  FieldList: TObjectListEh;
  i: Integer;
begin
  FieldList := TObjectListEh.Create;
  try
    GetFieldsProperty(FieldList, DataSet, Control, FieldNames);
    Result := nil;
    SetLength(Result, FieldList.Count);
    for i := 0 to FieldList.Count - 1 do
      Result[i] := TField(FieldList[i]);
  finally
    FieldList.Free;
  end;
end;

{ Dataset Features }

var
  DatasetFeaturesList: TStringList;

procedure DisposeDatasetFeaturesList;
begin
  if DatasetFeaturesList = nil then Exit;

  while DatasetFeaturesList.Count > 0 do
  begin
    FreeObjectEh(DatasetFeaturesList.Objects[0]);
    DatasetFeaturesList.Delete(0);
  end;
  FreeAndNil(DatasetFeaturesList);
end;

{ TBMListEh }

constructor TBMListEh.Create;
begin
  inherited Create;
{$IFDEF TBookMarkAsTBytes}
  SetLength(FList, 0);
{$ELSE}
  FList := TStringList.Create;
  FList.OnChange := ListChangedEventHandler;
{$ENDIF}
end;

destructor TBMListEh.Destroy;
begin
  Clear;
  UpdateState;
{$IFDEF EH_LIB_12}
{$ELSE}
  FreeAndNil(FList);
{$ENDIF}
  inherited Destroy;
end;

procedure TBMListEh.Delete;
var
  I: Integer;
begin
  Dataset.DisableControls;
  try
{$IFDEF TBookMarkAsTBytes}
    for I := Length(FList) - 1 downto 0 do
{$ELSE}
    for I := FList.Count - 1 downto 0 do
{$ENDIF}
    begin
      Dataset.Bookmark := FList[I];
      Dataset.Delete;
      DeleteItem(I);
    end;
  finally
    Dataset.EnableControls;
  end;
  UpdateState;
end;

function TBMListEh.IndexOf(const Item: TUniBookmarkEh): Integer;
begin
  if not Find(Item, Result) then
    Result := -1;
end;

function TBMListEh.GetCount: Integer;
begin
{$IFDEF TBookMarkAsTBytes}
  Result := Length(FList);
{$ELSE}
  Result := FList.Count;
{$ENDIF}
end;

function TBMListEh.GetCurrentRowSelected: Boolean;
var
  Index: Integer;
begin
  if Count = 0
    then Result := False
    else Result := Find(CurrentRow, Index);
end;

function TBMListEh.GetItem(Index: Integer): TUniBookmarkEh;
begin
  Result := FList[Index];
end;

procedure TBMListEh.SetItem(Index: Integer; Item: TUniBookmarkEh);
begin
  FList[Index] := Item;
end;

function TBMListEh.Refresh(DeleteInvalid: Boolean): Boolean;
var
  I: Integer;
  BeginUpdated: Boolean;
begin
  Result := False;
  BeginUpdated := False;
  try
    Dataset.CheckBrowseMode;
    if GetCount > 0 then
    begin
{$IFDEF TBookMarkAsTBytes}
{$ELSE}
      FList.BeginUpdate;
{$ENDIF}
      BeginUpdated := True;
    end;
    if DeleteInvalid then
    begin
      for I := GetCount - 1 downto 0 do
        if not DatasetBookmarkValid(Dataset, FList[I]) then
        begin
          Result := True;
          DeleteItem(I);
        end;
    end;
    Resort;
  finally
    UpdateState;
    Dataset.UpdateCursorPos;
    if BeginUpdated then
{$IFDEF TBookMarkAsTBytes}
      if Result then
        ListChanged();
{$ELSE}
      FList.EndUpdate;
{$ENDIF}
    if Result then Invalidate;
  end;
end;

procedure TBMListEh.SelectAll;
var
  bm: TUniBookmarkEh;
begin
  if not FLinkActive then Exit;
  Dataset.DisableControls;
  BeginUpdate;
  try
    bm := Dataset.Bookmark;
    Dataset.First;
    while Dataset.EOF = False do
    begin
      SetCurrentRowSelected(True);
      Dataset.Next;
    end;
    Dataset.Bookmark := bm;
  finally
    Dataset.EnableControls;
    EndUpdate;
  end;
end;

procedure TBMListEh.BeginUpdate;
begin
  FUpdateCount := FUpdateCount + 1;
end;

procedure TBMListEh.EndUpdate;
begin
  FUpdateCount := FUpdateCount - 1;
  if FUpdateCount = 0 then
    ListChanged();
end;

function TBMListEh.Updating: Boolean;
begin
  Result := (FUpdateCount > 0);
end;

procedure TBMListEh.ListChanged();
begin
  FCache := NilBookmarkEh;
  FCacheIndex := -1;
end;

procedure TBMListEh.ListChangedEventHandler(Sender: TObject);
begin
  ListChanged();
end;

procedure TBMListEh.SetCurrentRowSelected(Value: Boolean);
var
  Index: Integer;
  Current: TUniBookmarkEh;
begin
  Current := CurrentRow;
  if Find(Current, Index) = Value then
    Exit;
  if Value
    then InsertItem(Index, Current)
    else DeleteItem(Index);
end;

function TBMListEh.CurrentRow: TUniBookmarkEh;
begin
  {$IFDEF FPC}
  if not FLinkActive then RaiseBMListError(SInactiveDataset);
  {$ELSE}
  if not FLinkActive then RaiseBMListError(sDataSetClosed);
  {$ENDIF}
  Result := Dataset.Bookmark;
end;

function TBMListEh.Compare(const Item1, Item2: TUniBookmarkEh): Integer;
begin
  Result := DataSetCompareBookmarks(Dataset, Item1, Item2);
end;

procedure TBMListEh.Clear;
var
  i: Integer;
begin
{$IFDEF TBookMarkAsTBytes}
  if Length(FList) = 0 then Exit;
{$ELSE}
  if FList.Count = 0 then Exit;
{$ENDIF}
  BeginUpdate;
  try
    for i := Count-1 downto 0 do
      DeleteItem(i);
  finally
    EndUpdate;
  end;

  ListChanged();
  Invalidate;
end;

function CompareBookmarkStr(List: TBMListEh; ADataSet: TDataSet; Index1, Index2: Integer): Integer;
begin
  Result := DataSetCompareBookmarks(ADataSet, List[Index1], List[Index2]);
end;

procedure TBMListEh.Resort;
begin
  CustomSort(DataSet, CompareBookmarkStr);
end;

procedure TBMListEh.CustomSort(DataSet: TDataSet; Compare: TBMListSortCompare);
begin
  if (Count > 1) then
    QuickSort(DataSet, 0, Count - 1, Compare);
end;

procedure TBMListEh.QuickSort(DataSet: TDataSet; L, R: Integer; SCompare: TBMListSortCompare);
var
  I, J, P: Integer;
  T: TUniBookmarkEh;
begin
  repeat
    I := L;
    J := R;
    P := (L + R) shr 1;
    repeat
      while SCompare(Self, DataSet, I, P) < 0 do Inc(I);
      while SCompare(Self, DataSet, J, P) > 0 do Dec(J);
      if I <= J then
      begin
        if I <> J then
        begin
          T := FList[I];
          FList[I] := FList[J];
          FList[J] := T;
        end;
        if P = I then
          P := J
        else if P = J then
          P := I;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then QuickSort(DataSet, L, J, SCompare);
    L := I;
  until I >= R;
end;

function TBMListEh.Find(const Item: TUniBookmarkEh; var Index: Integer): Boolean;
var
  L, H, I, C: Integer;
begin
  if (Compare(Item, FCache) = 0) and (FCacheIndex >= 0) then
  begin
    Index := FCacheIndex;
    Result := FCacheFind;
    Exit;
  end;
  Result := False;
  L := 0;
  H := GetCount - 1;
  if H >= 0 then
  begin
    if Compare(FList[L], Item) > 0 then
      L := 0
    else if Compare(FList[H], Item) < 0 then
      L := H + 1
    else
    begin
      while L <= H do
      begin
        I := (L + H) shr 1;
        C := Compare(FList[I], Item);
        if C < 0 then L := I + 1 else
        begin
          H := I - 1;
          if C = 0 then
          begin
            Result := True;
            L := I;
          end;
        end;
      end;
    end;
  end;
  Index := L;
  FCache := Item;
  FCacheIndex := Index;
  FCacheFind := Result;
end;

procedure TBMListEh.RaiseBMListError(const S: string);
begin
  raise Exception.Create(S);
end;

procedure TBMListEh.LinkActive(Value: Boolean);
begin
  Clear;
  UpdateState;
  FLinkActive := Value;
end;

procedure TBMListEh.UpdateState;
begin
end;

procedure TBMListEh.Invalidate;
begin
end;

function TBMListEh.IsLinkActive: Boolean;
begin
  Result := FLinkActive;
end;

function TBMListEh.GetDataSet: TDataSet;
begin
  Result := nil;
end;

procedure TBMListEh.DeleteItem(Index: Integer);
{$IFDEF TBookMarkAsTBytes}
begin
  if (Index < 0) or (Index >= Count) then
  {$IFDEF FPC}
    raise EListError.CreateFmt('SListIndexError', [Index]);
  {$ELSE}
    raise EListError.CreateFmt(SListIndexError, [Index]);
  {$ENDIF}
  FList[Index] := nil;
  if Index < Count-1 then
  begin
    System.Move(FList[Index + 1], FList[Index],
      (Count - Index - 1) * SizeOf(Pointer));
    PPointer(@FList[Count-1])^ := nil;
  end;
  SetLength(FList, Count-1);
  if not Updating then
    ListChanged();
end;
{$ELSE}
begin
  FList.Delete(Index);
end;
{$ENDIF}

procedure TBMListEh.InsertItem(Index: Integer; Item: TUniBookmarkEh);
{$IFDEF TBookMarkAsTBytes}
begin
  if (Index < 0) or (Index > Count) then
  {$IFDEF FPC}
    raise EListError.Create('SListIndexError');
  {$ELSE}
    raise EListError.Create(SListIndexError);
  {$ENDIF}
  SetLength(FList, Count + 1);
  if Index < Count - 1 then
  begin
    Move(FList[Index], FList[Index + 1],
      (Count - Index - 1) * SizeOf(Pointer));
    PPointer(@FList[Index])^ := nil;
  end;
  FList[Index] := Item;
  if not Updating then
    ListChanged();
end;
{$ELSE}
begin
  FList.Insert(Index, Item)
end;
{$ENDIF}

procedure TBMListEh.AppendBookmark(Item: TUniBookmarkEh);
var
  Index: Integer;
begin
  if Find(Item, Index) = True then
    Exit;
  InsertItem(Index, Item);
end;

function TBMListEh.DeleteBookmark(Item: TUniBookmarkEh): Boolean;
var
  Index: Integer;
begin
  if Find(Item, Index) = True then
  begin
    DeleteItem(Index);
    Result := True;
  end else
    Result := False;
end;

procedure TBMListEh.AppendItem(Item: TUniBookmarkEh);
{$IFDEF TBookMarkAsTBytes}
begin
  InsertItem(GetCount, Item);
end;
{$ELSE}
begin
  FList.Add(Item)
end;
{$ENDIF}

{ TDataLinkEh }

procedure TDataLinkEh.DataEvent(Event: TDataEvent; Info: TDataEventInfoTypeEh);
begin
  inherited DataEvent(Event, Info);
  if Assigned(OnDataEvent) then
    OnDataEvent(Event, Info);
end;

{ TDatasetFieldValueListEh }

constructor TDatasetFieldValueListEh.Create;
begin
  inherited Create;
  FValues := TStringList.Create;
  FValues.Sorted := True;
  FValues.Duplicates := dupIgnore;
  FDataSource := TDataSource.Create(nil);
  FDataLink := TDataLinkEh.Create;
  FDataLink.OnDataEvent := DataSetEvent;
end;

destructor TDatasetFieldValueListEh.Destroy;
begin
  FreeAndNil(FValues);
  FDataSource.DataSet := nil;
  FreeAndNil(FDataSource);
  FreeAndNil(FDataLink);
  inherited Destroy;
end;

function TDatasetFieldValueListEh.GetValues: TStrings;
begin
  if FDataObsoleted then
    RefreshValues;
  Result := FValues;
end;

procedure TDatasetFieldValueListEh.SetFieldName(const Value: String);
begin
  if FFieldName <> Value then
  begin
    FDataObsoleted := True;
    FFieldName := Value;
  end;
end;

procedure TDatasetFieldValueListEh.SetDataSet(const Value: TDataSet);
begin
  DataSource := nil;
  FDataLink.DataSource := FDataSource;
  if FDataLink.DataSet <> Value then
  begin
    FDataObsoleted := True;
    FDataSource.DataSet := Value;
  end;
end;

function TDatasetFieldValueListEh.GetDataSet: TDataSet;
begin
  Result := FDataSource.DataSet;
end;

procedure TDatasetFieldValueListEh.SetDataSource(const Value: TDataSource);
begin
  if FDataLink.DataSource <> Value then
  begin
    FDataObsoleted := True;
    FDataLink.DataSource := Value;
  end;
end;

function TDatasetFieldValueListEh.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TDatasetFieldValueListEh.RefreshValues;
var
  Field: TField;
  ABookmark: TUniBookmarkEh;
begin
  FValues.Clear;
  if not FDataLink.Active or (FDataLink.DataSet.FindField(FieldName) = nil) then
    Exit;
  Field := FDataLink.DataSet.FindField(FieldName);
  FDataLink.DataSet.DisableControls;
  try
    ABookmark := FDataLink.DataSet.Bookmark;
    FDataLink.DataSet.First;
    while not FDataLink.DataSet.Eof do
    begin
      FValues.Add(Field.AsString);
      FDataLink.DataSet.Next;
    end;
  finally
    FDataLink.DataSet.Bookmark := ABookmark;
    FDataLink.DataSet.EnableControls;
  end;
  FDataObsoleted := False;
end;

{$IFDEF CIL}
procedure TDatasetFieldValueListEh.DataSetEvent(Event: TDataEvent; Info: TObject);
{$ELSE}
procedure TDatasetFieldValueListEh.DataSetEvent(Event: TDataEvent; Info: Integer);
{$ENDIF}
begin
  if Event in [deDataSetChange, dePropertyChange, deFieldListChange] then
    FDataObsoleted := True;
end;

procedure TDatasetFieldValueListEh.SetFilter(const Filter: String);
begin

end;

function TDatasetFieldValueListEh.GetCaseSensitive: Boolean;
begin
  Result := FValues.CaseSensitive;
end;

procedure TDatasetFieldValueListEh.SetCaseSensitive(const Value: Boolean);
begin
  FValues.CaseSensitive := Value;
end;

{ TSortOrderItemProvEh }

function TSortOrderItemProvEh.GetBaseListItem: TObject;
begin
  raise Exception.Create('function TSortOrderItemProvEh.GetBaseListItem must be implemented');
end;

function TSortOrderItemProvEh.GetField: TField;
begin
  raise Exception.Create('function TSortOrderItemProvEh.GetField must be implemented');
end;

function TSortOrderItemProvEh.GetFieldName: String;
begin
  raise Exception.Create('function TSortOrderItemProvEh.GetFieldName must be implemented');
end;

function TSortOrderItemProvEh.GetSortOrder: TSortOrderEh;
begin
  raise Exception.Create('function TSortOrderItemProvEh.GetSortOrder must be implemented');
end;

function CreateImageStream(StreamPersist: IStreamPersist): IImageStream;
begin
  Result := TInterfacedImageStreamEh.Create;
  StreamPersist.SaveToStream(Result.GetImageStream);
end;

function CreateImageStream(StreamPersist: TPersistent): IImageStream;
begin
  Result := TInterfacedImageStreamEh.Create;
  if StreamPersist <> nil  then
    Result.GetObject.Assign(StreamPersist);
end;

{ TInterfacedImageStreamEh }

constructor TInterfacedImageStreamEh.Create;
begin
  inherited Create;
  FImageStream := TMemoryStream.Create;
  FPersistentObj := TImageStreamPersistentEh.Create(Self);
end;

destructor TInterfacedImageStreamEh.Destroy;
begin
  FreeAndNil(FImageStream);
  FreeAndNil(FPersistentObj);
  inherited Destroy;
end;

function TInterfacedImageStreamEh.GetImageStream: TStream;
begin
  FImageStream.Position := 0;
  Result := FImageStream;
end;

function TInterfacedImageStreamEh.GetObject: TPersistent;
begin
  Result := FPersistentObj;
end;

{ TImageStreamPersistentEh }

procedure TImageStreamPersistentEh.AssignTo(Dest: TPersistent);
var
  AStreamPersist: IStreamPersist;
begin
  if Supports(Dest, IStreamPersist, AStreamPersist) then
    AStreamPersist.LoadFromStream(FOwner.GetImageStream)
  else
    inherited AssignTo(Dest);
end;

constructor TImageStreamPersistentEh.Create(AOwner: TInterfacedImageStreamEh);
begin
  inherited Create();
  FOwner := AOwner;
end;

destructor TImageStreamPersistentEh.Destroy;
begin
  inherited Destroy;
end;

procedure TImageStreamPersistentEh.LoadFromStream(Stream: TStream);
begin
  FOwner.GetImageStream.CopyFrom(Stream, Stream.Size - Stream.Position);
end;

procedure TImageStreamPersistentEh.SaveToStream(Stream: TStream);
begin
  Stream.CopyFrom(FOwner.GetImageStream, 0);
end;

procedure TImageStreamPersistentEh.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
end;


procedure InitUnit;
begin
  RoughStringCompareProcEh := @DefaultRoughStringCompareEh;
  RoughStringSearchProcEh := @DefaultRoughStringSearchEh;
  RoughStringPosProcEh := @DefaultRoughStringPosEh;
  MakeStringRoughProcEh := nil;
end;

procedure FinalUnit;
begin
  DisposeDatasetFeaturesList;
end;

initialization
  InitUnit;
finalization
  FinalUnit;
end.
