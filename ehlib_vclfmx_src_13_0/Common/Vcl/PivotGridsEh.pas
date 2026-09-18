{*******************************************************}
{                                                       }
{                        EhLib 12.1                     }
{                      PivotGridsEh                     }
{                                                       }
{   Copyright (c) 2014-2025 by Dmitry V. Bolshakov      }
{                                                       }
{*******************************************************}

{$I ..\Incl\EhLib.Inc}

unit PivotGridsEh;

interface

uses
{$IFDEF EH_LIB_17} System.Generics.Collections, {$ENDIF}
  SysUtils, Controls, Forms, StdCtrls, Dialogs,
  Contnrs, Variants, Types, Themes, Messages,
{$IFDEF EH_LIB_17} System.UITypes, {$ENDIF}
  {$IFDEF FPC}
    EhLibLclUtils, DBGridEh, LMessages, LCLType, LCLIntf,
    {$IFDEF FPC_CROSSP}
    {$ELSE}
      Windows, Win32Extra,
    {$ENDIF}
  {$ELSE}
    EhLibVclUtils, DBGridEh, PrintUtilsEh, Windows, UxTheme, CommCtrl,
  {$ENDIF}
  Classes, MemTableEh, MemTableDataEh, MemTreeEh, TypInfo, DateUtils,
  GridsEh, GridToolCtrlsEh, DBCtrlsEh, ToolCtrlsEh, EhLibUtils,
  DBAxisGridsEh, DBUtilsEh, FilterDropDownFormsEh, SpreadGridsEh,
{$IFDEF MSWINDOWS}
  Registry,
{$ELSE}
{$ENDIF}
  DBCtrls, Db, Menus, Graphics, IniFiles, ImgList, StdActns,
{$IFDEF MSWINDOWS}
  ComObj,
{$ELSE}
{$ENDIF}
  ActnList, ExtCtrls, DynVarsEh, ToolWin, Comctrls;

type
  TCustomPivotGridEh = class;
  TPivotFieldsEh = class;
  TPivotFieldEh = class;
  TValueFieldsCollectionEh = class;
  TPivotDataSourceEh = class;
  TPivotGridScrollBarPanelControl = class;
  TPivotAxisTreeNodeEh = class;
  TPivotProgressIndicatorPanelEh = class;
  TPivotAxisGroupingTreeEh = class;
  TPivotKeyValueStatesEh = class;
  TPivotCellEh = class;

  TFieldDateTimeSliceLevelEh = (dtslNonEh, dtslYearEh, dtslQuarterEh, dtslMonthEh, dtslWeekEh,
    dtslDayEh, dtslHourEh, dtslMinEh, dtslSecEh, dtslMSecEh);

  TDateTimeSliceLevelsEh = set of TFieldDateTimeSliceLevelEh;

  TPivotValueTypeEh = (svtSumEh, svtCountEh, svtAvgEh,
    svtMaxEh, svtMinEh, svtCountDistinctEh, svtProductEh,
    svtStDevEh, svtStDevpEh, svtVarEh, svtVarpEh, svtCustomEh);

  TPivotValueTypesEh = set of TPivotValueTypeEh;

  TPivotCelTypeEh = (sctEmptyEh,
    sctFieldNameForRowEh, sctFieldNameForColEh,
    sctRowsAxisValueEh, sctColsAxisValueEh,
    sctDataEh, sctHorzAggregateData, sctVertAggregateData,
    sctValCaptionInColsAxisEh, sctValCaptionInRowsAxisEh);

  TPivotAxisDirectionEh = (padVerticalEh, padHorizontalEh);

  TPivotFieldFetchValueEventEh = procedure(DataSource: TPivotDataSourceEh;
    PivotField: TPivotFieldEh; var Value: Variant; var Processed: Boolean) of object;

  IPivotDataSourceNotificationEh = interface
    ['{79ED2D2A-D1EC-4095-80CC-12F6D4D31BC7}']
    function PivotDataChangeProgress(Sender: TObject; ElapsedTime: LongWord; Percent: Integer): Boolean;

    procedure PivotFieldsChanged(Sender: TObject);
    procedure PivotStructureChanged(Sender: TObject);
    procedure PivotDataChanged(Sender: TObject);

    procedure PivotDataStartChanging(Sender: TObject);
    procedure PivotDataChangingCanceled(Sender: TObject);
    procedure PivotDataFinishChanging(Sender: TObject);
  end;

{ TPivotKeyValueStateEh }

  TPivotKeyValueStateEh = class(TCollectionItem)
  private
    FExpanded: Boolean;
    FVisible: Boolean;
    FKeyValue: Variant;
    procedure SetExpanded(const Value: Boolean);
    procedure SetVisible(const Value: Boolean);
    function GetList: TPivotKeyValueStatesEh;
  public
    constructor Create(Collection: TCollection); override;
    constructor CreateApart(const KeyValue: Variant);
    destructor Destroy; override;

    property List: TPivotKeyValueStatesEh read GetList;

    property KeyValue: Variant read FKeyValue;
    property Expanded: Boolean read FExpanded write SetExpanded;
    property Visible: Boolean read FVisible write SetVisible;
  end;

  TPivotKeyValueStateEhClass = class of TPivotKeyValueStateEh;

{ TPivotKeyValueStatesEh }

  TPivotKeyValueStatesEh = class(TCollection)
  private
    FPivotField: TPivotFieldEh;
    FHaveHiddenKeys: Boolean;
    function GetItem(Index: Integer): TPivotKeyValueStateEh;
    function GetPivotField: TPivotFieldEh;
    function GetItemByKeyValue(const KeyValue: Variant): TPivotKeyValueStateEh;

  protected
    function BinarySearch(const KeyValue: Variant): Integer;

    procedure SortData;
    procedure UpdateData(AMemTableEh: TMemTableEh);
    procedure UpdateHaveHiddenKeysProp;

  public
    constructor Create(APivotField: TPivotFieldEh; AClass: TPivotKeyValueStateEhClass);

    function Add: TPivotKeyValueStateEh; overload;
    function Add(const KeyValue: Variant): TPivotKeyValueStateEh; overload;

    function HaveHiddenKeys: Boolean;

    procedure UpdateStateFromSortedList(AList: TObjectList);

    property Items[Index: Integer]: TPivotKeyValueStateEh read GetItem; default;
    property ItemByKeyValue[const KeyValue: Variant]: TPivotKeyValueStateEh read GetItemByKeyValue;
    property PivotField: TPivotFieldEh read GetPivotField;
  end;

{ TPivotGridAggregateFunctionCalculatorEh }

  TPivotGridAggregateFunctionCalculatorEh = class(TPersistent)
  public
    Value: Variant;
    SrvVars: TVariantDynArray;
    SrvObj: TObject;

    constructor Create; virtual;
    destructor Destroy; override;

    procedure ResetAggrHolder; virtual;
    procedure AggrValue(const AValue: Variant); virtual;

    class function DisplayName: String;

    function FinalizeAggregation: Variant; virtual;
  end;

  TPivotGridAggregateFunctionCalculatorEhClass = class of TPivotGridAggregateFunctionCalculatorEh;

{ TPivotGridSumFunctionCalculatorEh }

  TPivotGridSumFunctionCalculatorEh = class(TPivotGridAggregateFunctionCalculatorEh)
  public
    class function DisplayName: String;
    procedure AggrValue(const AValue: Variant); override;
  end;

{ TPivotGridCountFunctionCalculatorEh }

  TPivotGridCountFunctionCalculatorEh = class(TPivotGridAggregateFunctionCalculatorEh)
  public
    class function DisplayName: String;
    procedure AggrValue(const AValue: Variant); override;
  end;

{ TPivotGridAverageFunctionCalculatorEh }

  TPivotGridAverageFunctionCalculatorEh = class(TPivotGridAggregateFunctionCalculatorEh)
  public
    class function DisplayName: String;
    function FinalizeAggregation: Variant; override;

    procedure ResetAggrHolder; override;
    procedure AggrValue(const AValue: Variant); override;
  end;

{ TPivotGridMaxFunctionCalculatorEh }

  TPivotGridMaxFunctionCalculatorEh = class(TPivotGridAggregateFunctionCalculatorEh)
  public
    class function DisplayName: String;
    procedure AggrValue(const AValue: Variant); override;
  end;

{ TPivotGridMinFunctionCalculatorEh }

  TPivotGridMinFunctionCalculatorEh = class(TPivotGridAggregateFunctionCalculatorEh)
  public
    class function DisplayName: String;
    procedure AggrValue(const AValue: Variant); override;
  end;

{ TPivotGridCountDistinctFunctionCalculatorEh }

  TPivotGridCountDistinctFunctionCalculatorEh = class(TPivotGridAggregateFunctionCalculatorEh)
  public
    class function DisplayName: String;
    function FinalizeAggregation: Variant; override;

    procedure ResetAggrHolder; override;
    procedure AggrValue(const AValue: Variant); override;
  end;

{ TPivotGridProductFunctionCalculatorEh }

  TPivotGridProductFunctionCalculatorEh = class(TPivotGridAggregateFunctionCalculatorEh)
  public
    class function DisplayName: String;
    procedure AggrValue(const AValue: Variant); override;
  end;

{ TPivotGridStDevFunctionCalculatorEh }

  TPivotGridStDevFunctionCalculatorEh = class(TPivotGridAggregateFunctionCalculatorEh)
  protected
    Deduction: Integer;
    DoSqrt: Boolean;
  public
    constructor Create; override;

    class function DisplayName: String;
    function FinalizeAggregation: Variant; override;

    procedure ResetAggrHolder; override;
    procedure AggrValue(const AValue: Variant); override;
  end;

{ TPivotGridStDevpFunctionCalculatorEh }

  TPivotGridStDevpFunctionCalculatorEh = class(TPivotGridStDevFunctionCalculatorEh)
  public
    constructor Create; override;
    class function DisplayName: String;
  end;

{ TPivotGridVarFunctionCalculatorEh }

  TPivotGridVarFunctionCalculatorEh = class(TPivotGridStDevFunctionCalculatorEh)
  public
    constructor Create; override;
    class function DisplayName: String;
  end;

{ TPivotGridVarpFunctionCalculatorEh }

  TPivotGridVarpFunctionCalculatorEh = class(TPivotGridStDevFunctionCalculatorEh)
  public
    constructor Create; override;
    class function DisplayName: String;
  end;

  TPivotRectCellEh = record
    Rect: TRect;
    PivotArrayCol: Integer;
    PivotArrayRow: Integer;
  end;

  TPivotRectCellDynArrayEh = array of TPivotRectCellEh;

  TPivotCellDetailsEh = class(TPersistent)
  protected
    function GetDisplayText(APivotCell: TPivotCellEh; AGrid: TCustomPivotGridEh; ACol, ARow: Integer): String; virtual;
    function GetDisplayFont(APivotCell: TPivotCellEh; AGrid: TCustomPivotGridEh; ACol, ARow: Integer): TFont; virtual;
    function GetFillColor(APivotCell: TPivotCellEh; AGrid: TCustomPivotGridEh; ACol, ARow: Integer): TColor; virtual;
  end;

  TPCEmptyDetailsEh = class(TPivotCellDetailsEh)
  end;

  TPCEmptyDetailsEhClass = class of TPCEmptyDetailsEh;

  TPCFieldNameDetailsEh = class(TPivotCellDetailsEh)
  private
    FExpanded: Boolean;
    FDrawFilterButton: Boolean;
    FPivotField: TPivotFieldEh;
  published
    property DrawFilterButton: Boolean read FDrawFilterButton write FDrawFilterButton;
    property Expanded: Boolean read FExpanded write FExpanded;
    property PivotField: TPivotFieldEh read FPivotField write FPivotField;
  end;

  TPCFieldNameForRowDetailsEh = class(TPCFieldNameDetailsEh)
  private
  published
  end;

  TPCFieldNameForColDetailsEh = class(TPCFieldNameDetailsEh)
  private
  published
  end;

  TAxisCellTypeEh = (actUndefinedEh, actGroupCellEh, actTotalCellEh);

  TAxisCellSubTypeEh = (acstUndefinedEh, acstGroupFirstCellEh, acstGroupNextCellEh,
    acstTotalFirstCellEh, acstTotalNextCellEh);

  TPCAxisValueDetailsEh = class(TPivotCellDetailsEh)
  private
    FPivotField: TPivotFieldEh;
    FAxisTreeNode: TPivotAxisTreeNodeEh;
    FShowGroupingSign: Boolean;
    FAxisCellType: TAxisCellTypeEh;
    FAxisCellSubType: TAxisCellSubTypeEh;
  protected
    function GetDisplayFont(APivotCell: TPivotCellEh; AGrid: TCustomPivotGridEh; ACol, ARow: Integer): TFont; override;
    function GetDisplayText(APivotCell: TPivotCellEh; AGrid: TCustomPivotGridEh; ACol, ARow: Integer): String; override;
  published
    property PivotField: TPivotFieldEh read FPivotField write FPivotField;
    property AxisTreeNode: TPivotAxisTreeNodeEh read FAxisTreeNode write FAxisTreeNode;
    property ShowGroupingSign: Boolean read FShowGroupingSign write FShowGroupingSign;
    property AxisCellType: TAxisCellTypeEh read FAxisCellType write FAxisCellType;
    property AxisCellSubType: TAxisCellSubTypeEh read FAxisCellSubType write FAxisCellSubType;
  end;

  TPCRowsAxisValueDetailsEh = class(TPCAxisValueDetailsEh)
  private
  published
  end;

  TPCColsAxisValueDetailsEh = class(TPCAxisValueDetailsEh)
  private
  published
  end;

  TPCValCaptionInAxisDetailsEh = class(TPivotCellDetailsEh)
  private
  protected
    function GetDisplayText(APivotCell: TPivotCellEh; AGrid: TCustomPivotGridEh; ACol, ARow: Integer): String; override;
  published
  end;

  TPivotDataCellDetailsEh = class(TPivotCellDetailsEh)
  protected
    function GetDisplayText(APivotCell: TPivotCellEh; AGrid: TCustomPivotGridEh; ACol, ARow: Integer): String; override;
  end;

{ TPivotCellEh }

  TPivotCellEh = class(TPersistent)
  private
    FCelType: TPivotCelTypeEh;
    FDrawDownLine: Boolean;
    FDrawRightLine: Boolean;
    FHorzAggrLevelCol: Integer;
    FHorzAggrLevelRow: Integer;
    FShowValue: Boolean;
    FValue: Variant;
    FVertAggrLevelCol: Integer;
    FVertAggrLevelRow: Integer;
    FCellDetails: TPivotCellDetailsEh;

    function GetEmptyDetails: TPCEmptyDetailsEh;
    function GetFieldNameForColDetails: TPCFieldNameForColDetailsEh;
    function GetFieldNameForRowDetails: TPCFieldNameForRowDetailsEh;
    function GetCelType: TPivotCelTypeEh;
    function GetColsAxisValueDetails: TPCColsAxisValueDetailsEh;
    function GetRowsAxisValueDetails: TPCRowsAxisValueDetailsEh;
    function GetAxisValueDetails: TPCAxisValueDetailsEh;
    function GetFieldNameDetails: TPCFieldNameDetailsEh;

    procedure SetCelType(const Value: TPivotCelTypeEh);
  protected
    function GetDefaultDisplayText(AGrid: TCustomPivotGridEh; ACol, ARow: Integer): String; virtual;
    function GetDefaultDisplayFont(AGrid: TCustomPivotGridEh; ACol, ARow: Integer): TFont; virtual;
    function GetDefaultFillColor(AGrid: TCustomPivotGridEh; ACol, ARow: Integer): TColor; virtual;
  public
    property DrawDownLine: Boolean read FDrawDownLine write FDrawDownLine;
    property DrawRightLine: Boolean read FDrawRightLine write FDrawRightLine;
    property HorzAggrLevelCol: Integer read FHorzAggrLevelCol write FHorzAggrLevelCol;
    property HorzAggrLevelRow: Integer read FHorzAggrLevelRow write FHorzAggrLevelRow;
    property ShowValue: Boolean read FShowValue write FShowValue;
    property Value: Variant read FValue write FValue;
    property VertAggrLevelCol: Integer read FVertAggrLevelCol write FVertAggrLevelCol;
    property VertAggrLevelRow: Integer read FVertAggrLevelRow write FVertAggrLevelRow;

    constructor Create;
    destructor Destroy; override;

    function GetDisplayText(AGrid: TCustomPivotGridEh; ACol, ARow: Integer): String; virtual;
    function GetDisplayFont(AGrid: TCustomPivotGridEh; ACol, ARow: Integer): TFont; virtual;
    function GetFillColor(AGrid: TCustomPivotGridEh; ACol, ARow: Integer): TColor; virtual;

    procedure Clear;
  published
    property CellDetails: TPivotCellDetailsEh read FCellDetails;

    property EmptyDetails: TPCEmptyDetailsEh read GetEmptyDetails;

    property FieldNameDetails: TPCFieldNameDetailsEh read GetFieldNameDetails;
    property FieldNameForRowDetails: TPCFieldNameForRowDetailsEh read GetFieldNameForRowDetails;
    property FieldNameForColDetails: TPCFieldNameForColDetailsEh read GetFieldNameForColDetails;

    property AxisValueDetails: TPCAxisValueDetailsEh read GetAxisValueDetails;
    property RowsAxisValueDetails: TPCRowsAxisValueDetailsEh read GetRowsAxisValueDetails;
    property ColsAxisValueDetails: TPCColsAxisValueDetailsEh read GetColsAxisValueDetails;

    property CelType: TPivotCelTypeEh read GetCelType write SetCelType;
  end;

  TPivotArrayItem = record
    PivotValue: Variant;
    AggrValue: Variant;
  end;

  TPivotGridArray = array of array of TPivotCellEh;

  TPivotArray = array of TPivotArrayItem;

{ TPivotFieldDataTypeDefEh }

  TPivotFieldDataTypeDefEh = class(TPersistent)
  private
    FPrecision: Integer;
    FDataType: TFieldType;
    FSize: Integer;
    procedure SetDataType(const Value: TFieldType);
    procedure SetPrecision(const Value: Integer);
    procedure SetSize(const Value: Integer);
  published
    property DataType: TFieldType read FDataType write SetDataType default ftUnknown;
    property Precision: Integer read FPrecision write SetPrecision default 0;
    property Size: Integer read FSize write SetSize default 0;
  end;

{ TPivotFieldEh }

  TPivotFieldEh = class(TCollectionItem)
  private
    FDisplayFormat: String;
    FDisplayName: String;
    FExpression: TSTFilterExpressionEh;
    FExpressionStr: String;
    FFieldName: String;
    FFieldValueList: IMemTableDataFieldValueListEh;
    FOnFetchValue: TPivotFieldFetchValueEventEh;
    FSliceLevel: TFieldDateTimeSliceLevelEh;
    FSortOrder: TSortOrderEh;
    FSourceFieldName: String;
    FSumFunction: TPivotValueTypeEh;
    FSumFunctionStored: Boolean;
    FTypeDef: TPivotFieldDataTypeDefEh;
    FDisplayWidth: Integer;
    FKeyValueStates: TPivotKeyValueStatesEh;

    function GetExpression: TSTFilterExpressionEh;
    function GetPivotFields: TPivotFieldsEh;
    function IsDisplayNameStored: Boolean;

    procedure SetDisplayFormat(const Value: String);
    procedure SetDisplayName(const Value: String); reintroduce;
    procedure SetExpression(const Value: TSTFilterExpressionEh);
    procedure SetFieldName(const Value: String);
    procedure SetSortOrder(const Value: TSortOrderEh);
    procedure SetSumFunction(const Value: TPivotValueTypeEh);
    procedure SetTypeDef(const Value: TPivotFieldDataTypeDefEh);
    function GetKeyValueStates: TPivotKeyValueStatesEh;
    function IsSumFunctionStored: Boolean;
    procedure SetSumFunctionStored(const Value: Boolean);
    function GetSumFunction: TPivotValueTypeEh;

  protected
    FListValuesCheckingState: TBooleanDynArray;
    FPopupListboxDownIndex: Integer;

    function ParseExpression(const Exp: String): String;
    function GetDisplayName: string; override;
    function DefaultSumFunction: TPivotValueTypeEh; virtual;

    procedure InternalSetExpressionStr(const Value: String); virtual;
    procedure ClearExpression;
    procedure DisplayDefinitionChanged; virtual;

    property FieldValueList: IMemTableDataFieldValueListEh read FFieldValueList write FFieldValueList;

  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    function GetValueForSource(SourceDataSet: TDataSet; Field: TField): Variant;
    function ProposedSumFunction: TPivotValueTypeEh;
    function ValueAsDisplayText(const Value: Variant): String;
    function StringToDataValue(const StringValue: String): Variant;
    function SysStringToDataValue(const StringValue: String): Variant;
    function GetDataFieldType: TFieldType;
    function GetFilterExpressionAsStr: String;

    procedure FillFilterValues(Items: TStrings);
    procedure SetNextSortOrder;
    procedure UpdateFilterFromValuesCheckingState(ss: TStrings; CheckStates: TBooleanDynArray);
    procedure UpdateValuesCheckingStateFromFilter(ss: TStrings; CheckStates: TBooleanDynArray);
    procedure UpdateKeyValueStates;
    procedure UpdateKeyValueStatesFromFilterCheckedState(AStrList: TStrings; CheckStates: TBooleanDynArray);

    property Expression: TSTFilterExpressionEh read GetExpression write SetExpression;
    property PivotFields: TPivotFieldsEh read GetPivotFields;
    property SortOrder: TSortOrderEh read FSortOrder write SetSortOrder;
    property KeyValueStates: TPivotKeyValueStatesEh read GetKeyValueStates;


  published
    property DisplayFormat: String read FDisplayFormat write SetDisplayFormat;
    property DisplayName: String read GetDisplayName write SetDisplayName stored IsDisplayNameStored;
    property DisplayWidth: Integer read FDisplayWidth write FDisplayWidth default 0;
    property FieldName: String read FFieldName write SetFieldName;
    property SliceLevel: TFieldDateTimeSliceLevelEh read FSliceLevel write FSliceLevel default dtslNonEh;
    property SourceFieldName: String read FSourceFieldName write FSourceFieldName;
    property SumFunction: TPivotValueTypeEh read GetSumFunction write SetSumFunction  stored IsSumFunctionStored;
    property SumFunctionStored: Boolean read IsSumFunctionStored write SetSumFunctionStored default False;
    property TypeDef: TPivotFieldDataTypeDefEh read FTypeDef write SetTypeDef;

    property OnFetchValue: TPivotFieldFetchValueEventEh read FOnFetchValue write FOnFetchValue;
  end;

  TPivotFieldEhClass = class of TPivotFieldEh;

{ TPivotFieldsEh }

  TPivotFieldsEh = class(TCollection)
  private
    FPDSource: TPivotDataSourceEh;
    function GetPivotField(Index: Integer): TPivotFieldEh;
    procedure SetPivotField(Index: Integer; Value: TPivotFieldEh);

  protected
    function GetOwner: TPersistent; override;
    procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); override;
    procedure Update(Item: TCollectionItem); override;
    procedure DisplayDefinitionChanged;

  public
    constructor Create(APDSource: TPivotDataSourceEh; AClass: TPivotFieldEhClass);

    function Add: TPivotFieldEh;
    function FindFieldByName(const PivotFieldName: String): TPivotFieldEh;
    function IndexOf(APivotField: TPivotFieldEh): Integer;
    procedure AddAllPivotFields(DeleteExisting: Boolean);
    procedure Assign(Source: TPersistent); override;
    procedure RebuildPivotFields;

    property PDSource: TPivotDataSourceEh read FPDSource;
    property Items[Index: Integer]: TPivotFieldEh read GetPivotField write SetPivotField; default;
  end;

{ TPivotFieldValueInfoEh }

  TPivotFieldValueInfoEh = class(TCollectionItem)
  private
    FDisplayFormat: String;
    FPivotField: TPivotFieldEh;
    FPivotFieldName: String;
    FSumFunction: TPivotValueTypeEh;

    function GetCollection: TValueFieldsCollectionEh;
    procedure SetDisplayFormat(const Value: String);
    procedure SetPivotField(const Value: TPivotFieldEh);
    procedure SetPivotFieldName(const Value: String);
    procedure SetSumFunction(const Value: TPivotValueTypeEh);

  protected
    function UpdatePivotFieldFromPivotFieldName: TPivotFieldEh;

  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    function DisplayDescription: String;

    procedure Assign(Source: TPersistent); override;

    property Collection: TValueFieldsCollectionEh read GetCollection;
    property DisplayFormat: String read FDisplayFormat write SetDisplayFormat;
    property PivotField: TPivotFieldEh read FPivotField write SetPivotField;
    property PivotFieldName: String read FPivotFieldName write SetPivotFieldName;
    property SumFunction: TPivotValueTypeEh read FSumFunction write SetSumFunction;
  end;

  TPivotFieldValueInfoEhClass = class of TPivotFieldValueInfoEh;

{ TValuePivotFieldsCollectionEh }

  TCollectionChangeEventEh = procedure(Sender: TCollection;
    Item: TCollectionItem; Action: TCollectionNotification) of object;

  TValueFieldsCollectionEh = class(TCollection)
  private
    FOnChangeNotification: TCollectionChangeEventEh;

    function GetPivotFieldValueInfo(Index: Integer): TPivotFieldValueInfoEh;
    procedure SetPivotFieldValueInfo(Index: Integer; Value: TPivotFieldValueInfoEh);
  protected
    FPivotDataSource: TPivotDataSourceEh;

    procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); override;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AClass: TPivotFieldValueInfoEhClass);

    function Add: TPivotFieldValueInfoEh;
    function AddForPivotField(APivotField: TPivotFieldEh; Position: Integer): TPivotFieldValueInfoEh;
    function IndexOf(PivotFieldValueInfo: TPivotFieldValueInfoEh): Integer;
    function IndexByPivotFieldName(const PivotFieldName: String): Integer;
    function DataLines: Integer;

    procedure Move(CurIndex, NewIndex: Integer);
    procedure UpdatePivotFieldsFromPivotFieldNames;

    property Items[Index: Integer]: TPivotFieldValueInfoEh read GetPivotFieldValueInfo write SetPivotFieldValueInfo; default;
    property PivotDataSource: TPivotDataSourceEh read FPivotDataSource;

    property OnChangeNotification: TCollectionChangeEventEh read FOnChangeNotification write FOnChangeNotification;
  end;

{ TPivotMemTableEh }

  TPivotMemTableEh = class(TMemTableEh)
  private
    FOnCallBackProgress: TNotifyEvent;
  protected
    function CreateMemTableData: TMemTableDataEh; override;
  public
    procedure MTCallBackProgress(Sender: TObject);
    property OnCallBackProgress: TNotifyEvent read FOnCallBackProgress write FOnCallBackProgress;
  end;

{ TPivotMemTableDataEh }

  TPivotMemTableDataEh = class(TMemTableDataEh)
  private
    FCallBackProgress: TNotifyEvent;
  protected
    function CreateRecordsList: TRecordsListEh; override;
    procedure CallBackProgress;
  public
    property OnCallBackProgress: TNotifyEvent read FCallBackProgress write FCallBackProgress;
  end;

  {TPivotRecordsListEh}

  TPivotRecordsListEh = class(TRecordsListEh)
  public
    procedure QuickSort(L, R: Integer; Compare: TCompareRecords; ParamSort: TObject); override;
    procedure CallBackProgress;
  end;

{ TPivotDataSourceEh }

  TLogTimeMetricEventEh = procedure(Sender: TObject; MetricName: String; Duration: LongWord) of object;

  TPivotDataSourceEh = class(TComponent)
  private
    FDataSet: TDataSet;
    FDefaultDateTimeSliceLevels: TDateTimeSliceLevelsEh;
    FInternalDefinitionUpdating: Boolean;
    FNotificationConsumers: TInterfaceList;
    FOnLogTimeMetric: TLogTimeMetricEventEh;
    FPivotFields: TPivotFieldsEh;
    FUpdateCount: Integer;

    procedure CreateSourceTableStruct;
    procedure FillSourceTable;
    procedure SetColumnFields(const Value: TStringList);
    procedure SetPivotFields(const Value: TPivotFieldsEh);
    procedure SetRowFields(const Value: TStringList);
    procedure SetValueFieldsInfo(const Value: TValueFieldsCollectionEh);
    procedure UpdateColRowValueFields;
    procedure UpdatePivotFieldFilters;

  protected
    BaseColsTable: TMemTableEh;
    BaseTable: TMemTableEh;
    ColsFieldNames: String;
    ColsTable: TMemTableEh;
    FActualColFields: TStringList;
    FActualRowFields: TStringList;
    FActualValueFields: TValueFieldsCollectionEh;
    FBuildDataProgressTicks: LongWord;
    FCheckCancelRequestTime: LongWord;
    FColumnFields: TStringList;
    FPercent: Integer;
    FRowFields: TStringList;
    FSourceTable: TMemTableEh;
    FullBaseTable: TMemTableEh;
    FValueFieldsInfo: TValueFieldsCollectionEh;
    OldBaseColsTable: TMemTableEh;
    ResultAggrTable: TMemTableEh;
    RowsFieldNames: String;
    RowsTable: TMemTableEh;
    TransResultAggrTable: TMemTableEh;

    function GetSortFieldsFromList(FieldList: TStringList): String;
    function PivotDataChangeProgress(ElapsedTime: LongWord; Percent: Integer): Boolean;

    procedure AggregateBasePivotData;
    procedure BindColsRecsToBaseColsRecs;
    procedure BuildGridData;
    procedure BuildGridDataForBaseTable;
    procedure CallBackProgress(Sender: TObject);
    procedure CopyBaseColsTable(AOldBaseColsTable: TMemTableEh);
    procedure CreateAndFillBaseTable;
    procedure CreateBaseTableStruct;
    procedure FillBaseColsTableDataState(AOldColsTable: TMemTableEh);
    procedure FillBasePivotData;
    procedure FillColsTableData(AColsTable, ABaseTable: TMemTableEh; DataFieldCount: Integer);
    procedure FillInverseGaussMatrixForLevel(ColsLevel: Integer);
    procedure FillRowsTableData(ARowsTable: TMemTableEh; DataFieldCount: Integer);
    procedure LogTimeMetric(const MetricName: String; Duration: LongWord);
    procedure MakeBaseColsTable;
    procedure MakeBaseColsTableStruct(ABaseColsTable: TMemTableEh);
    procedure MakeColsRowsTables;
    procedure MakeColsTable;
    procedure MakeColsTableStruct(AColsTable: TMemTableEh);
    procedure MakeInverseGaussMatrix;
    procedure MakeResultAggrTable;
    procedure MakeRowsTable;
    procedure MakeRowsTableStruct(ARowsTable: TMemTableEh);
    procedure UpdateKeyValueStates;

    procedure ClearSourceData; virtual;
    procedure PivotDataChanged; virtual;
    procedure PivotDataStartChanging; virtual;
    procedure PivotDataFinishChanging; virtual;
    procedure PivotDataChangingCanceled; virtual;

    procedure PivotDataSourceChanged; virtual;
    procedure PivotFieldsChanged; virtual;
    procedure PivotFieldsDisplayChanged; virtual;
    procedure PivotStructureChanged(Sender: TObject);
    procedure SetDataFilter; virtual;
    procedure SetBaseTableFilter;
    procedure ValueFieldsInfoChangeEvent(Sender: TCollection; Item: TCollectionItem; Action: TCollectionNotification);

    property ActualColFields: TStringList read FActualColFields;
    property ActualRowFields: TStringList read FActualRowFields;
    property ActualValueFields: TValueFieldsCollectionEh read FActualValueFields;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function DataIsEmpty: Boolean;
    function StructureIsConsistent: Boolean;

    procedure RegisterChanges(Value: IPivotDataSourceNotificationEh);
    procedure UnRegisterChanges(Value: IPivotDataSourceNotificationEh);
    property SourceTable: TMemTableEh read FSourceTable;

    procedure BuildPivotData;
    procedure CreateAndFillSourceTable;
    procedure LoadAndBuildPivotData;
    procedure PivotDataStructBeginUpdate;
    procedure PivotDataStructEndUpdate;

  published
    property DataSet: TDataSet read FDataSet write FDataSet;
    property PivotFields: TPivotFieldsEh read FPivotFields write SetPivotFields;
    property DefaultDateTimeSliceLevels: TDateTimeSliceLevelsEh read  FDefaultDateTimeSliceLevels write FDefaultDateTimeSliceLevels default [dtslYearEh, dtslMonthEh, dtslDayEh];

    property ColumnFields: TStringList read FColumnFields write SetColumnFields;
    property RowFields: TStringList read FRowFields write SetRowFields;
    property ValueFieldDefs: TValueFieldsCollectionEh read FValueFieldsInfo write SetValueFieldsInfo;

    property OnLogTimeMetric: TLogTimeMetricEventEh read FOnLogTimeMetric write FOnLogTimeMetric;
  end;

{ TPivotAxisTreeNodeEh }

  TPivotTreeNodeIterativeEvent = procedure (Sender: TPivotAxisTreeNodeEh; Param: TObject) of object;

  TPivotAxisTreeNodeEh = class(TBaseTreeNodeEh)
  private
    FInPivotGridArrayIndex: Integer;
    FKeyValue: TVariantDynArray;
    FPivotKeyValueState: TPivotKeyValueStateEh;
    FRefBaseAxisTableRec: TMemoryRecordEh;

    function GetItem(const Index: Integer): TPivotAxisTreeNodeEh;
    function GetOwner: TPivotAxisGroupingTreeEh; reintroduce;
    function GetParent: TPivotAxisTreeNodeEh;
  protected
  public
    constructor Create; override;

    property InPivotGridArrayIndex: Integer read FInPivotGridArrayIndex;
    property Expanded;
    property Items[const Index: Integer]: TPivotAxisTreeNodeEh read GetItem; default;
    property KeyValue: TVariantDynArray read FKeyValue write FKeyValue;
    property Level;
    property Owner: TPivotAxisGroupingTreeEh read GetOwner;
    property Parent: TPivotAxisTreeNodeEh read GetParent;
    property PivotKeyValueState: TPivotKeyValueStateEh read FPivotKeyValueState;
    property RefBaseAxisTableRec: TMemoryRecordEh read FRefBaseAxisTableRec;
    property Text;
  end;

{ TPivotAxisGroupingTreeEh }

  TPivotAxisGroupingTreeEh = class(TTreeListEh)
  private
    FAxisDir: TPivotAxisDirectionEh;
    FCurIncAxisNum: Integer;
    FExpandedStateIterativeLevel: Integer;
    FFlatList: TObjectListEh;
    FGetExpandedCountsResult: Integer;
    FGrid: TCustomPivotGridEh;
    FSortOrder: TSortOrderEh;
    FUpdateCount: Integer;

    function CompareAxisValues(AxisPos1, AxisPos2, OppositeAxisPos: Integer): TVariantRelationship;
    function ComparePivotAxisPoses(Node1, Node2: TBaseTreeNodeEh; ParamSort: TObject): Integer;
    function GetActualAxisFields: TStrings;
    function GetAxisAggrBeforeData: Boolean;
    function GetAxisTable: TMemTableEh;
    function GetFlatList(Index: Integer): TPivotAxisTreeNodeEh;
    function GetFlatListCount: Integer;
    function GetRoot: TPivotAxisTreeNodeEh;

    procedure SetExpandedState(Sender: TPivotAxisTreeNodeEh; Param: TObject);
    procedure SetAxisCellTypeProc(Sender: TBaseTreeNodeEh; Param: TObject);

  protected
    procedure CheckExpanded(Sender: TBaseTreeNodeEh; Param: TObject);
    procedure ExpandedChanged(Node: TBaseTreeNodeEh); override;
    procedure FlatListAddItem(Sender: TBaseTreeNodeEh; Param: TObject);
    procedure SetExpandedStateFromPivotKeyValue(Sender: TBaseTreeNodeEh; Param: TObject);
    procedure UpdateExpandedState;

  public
    constructor Create(AGrid: TCustomPivotGridEh; ItemClass: TTreeNodeClassEh; AAxisDir: TPivotAxisDirectionEh);
    destructor Destroy; override;

    function GetExpandedCounts(ALevel: Integer): Integer;
    function Updating: Boolean; reintroduce;

    procedure BeginUpdate;
    procedure BuildFlatList;
    procedure BuildTree;
    procedure EndUpdate;
    procedure ForAllNode(AProg: TTreeNodeIterativeEvent; Param: TObject; RowAggrBeforeData: Boolean; IncludeCollapsed: Boolean);
    procedure SetAxisCellType;
    procedure SetGridArrayAxisNumbers;
    procedure SetLevelExpanded(ALevel: Integer; IsExpanded: Boolean);
    procedure SetNextColNum(Sender: TPivotAxisTreeNodeEh; Param: TObject);
    procedure SetNextRowNum(Sender: TPivotAxisTreeNodeEh; Param: TObject);
    procedure SortData(Level, PivotGridAxisLine: Integer; ASortOrder: TSortOrderEh); reintroduce; virtual;
    procedure WriteTree(sl: TStrings; AxisAggrBeforeData: Boolean);
    procedure WriteTreeLine(Sender: TBaseTreeNodeEh; Param: TObject);

    property ActualAxisFields: TStrings read GetActualAxisFields;
    property AxisAggrBeforeData: Boolean read GetAxisAggrBeforeData;
    property AxisDir: TPivotAxisDirectionEh read FAxisDir;
    property AxisTable: TMemTableEh read GetAxisTable;
    property FlatList[Index: Integer]: TPivotAxisTreeNodeEh read GetFlatList;
    property FlatListCount: Integer read GetFlatListCount;
    property Grid: TCustomPivotGridEh read FGrid;
    property Root: TPivotAxisTreeNodeEh read GetRoot;
  end;

  TPivotCellSignTypeEh = (pcstNonEh, pcstRectangleEh, pcstCircleEh);

{ TPivotCellDrawParamsEh }

  TPivotCellDrawParamsEh = class(TPersistent)
  private
    FAreaCol: Integer;
    FAreaRow: Integer;
    FCol: Integer;
    FDisplayValue: String;
    FDrawState: TGridDrawState;
    FFillColor: TColor;
    FFont: TFont;
    FRow: Integer;
    FValue: Variant;
    FCellRect: TRect;
    FPivotCell: TPivotCellEh;
    FDrawEvtArg: TDrawSpreadCellArgsEh;

    procedure SetFont(const Value: TFont);

  public
    constructor Create;
    destructor Destroy; override;

    property DrawEvtArg: TDrawSpreadCellArgsEh read FDrawEvtArg;
    property AreaCol: Integer read FAreaCol;
    property AreaRow: Integer read FAreaRow;
    property Col: Integer read FCol;
    property Row: Integer read FRow;
    property DrawState: TGridDrawState read FDrawState;
    property Value: Variant read FValue;
    property CellRect: TRect read FCellRect write FCellRect;
    property DisplayValue: String read FDisplayValue write FDisplayValue;

    property FillColor: TColor read FFillColor write FFillColor;
    property Font: TFont read FFont write SetFont;
    property PivotCell: TPivotCellEh read FPivotCell;
  end;

{ TPivotCellFieldNameDrawParamsEh }

  TPivotCellFieldNameDrawParamsEh = class(TPivotCellDrawParamsEh)
  end;

{ TPivotCellAxisValueDrawParamsEh }

  TPivotCellAxisValueDrawParamsEh = class(TPivotCellDrawParamsEh)
  end;

{ TPivotCellDataValueDrawParamsEh }

  TPivotCellDataValueDrawParamsEh = class(TPivotCellDrawParamsEh)
  private
    FSignFillColor: TColor;
    FSignFrameColor: TColor;
    FSignType: TPivotCellSignTypeEh;
    FColsAxisPos: TVariantDynArray;
    FColsGroupLevel: Integer;
    FRowsAxisPos: TVariantDynArray;
    FRowsGroupLevel: Integer;
  public
    property ColsAxisPos: TVariantDynArray read FColsAxisPos;
    property ColsGroupLevel: Integer read FColsGroupLevel;
    property RowsAxisPos: TVariantDynArray read FRowsAxisPos;
    property RowsGroupLevel: Integer read FRowsGroupLevel;

    property SignFillColor: TColor read FSignFillColor write FSignFillColor;
    property SignFrameColor: TColor read FSignFrameColor write FSignFrameColor;
    property SignType: TPivotCellSignTypeEh read FSignType write FSignType;
  end;

{ TPivotDataCellEditorParamsEh }

  TPivotDataCellEditorParamsEh = class(TPersistent)
  private
    FAreaCol: Integer;
    FAreaRow: Integer;
    FCanModify: Boolean;
    FCol: Integer;
    FColsAxisPos: TVariantDynArray;
    FColsGroupLevel: Integer;
    FEditValue: String;
    FFillColor: TColor;
    FFont: TFont;
    FRow: Integer;
    FRowsAxisPos: TVariantDynArray;
    FRowsGroupLevel: Integer;
    FValue: Variant;

  public
    property AreaCol: Integer read FAreaCol;
    property AreaRow: Integer read FAreaRow;
    property Col: Integer read FCol;
    property ColsAxisPos: TVariantDynArray read FColsAxisPos;
    property ColsGroupLevel: Integer read FColsGroupLevel;
    property Row: Integer read FRow;
    property RowsAxisPos: TVariantDynArray read FRowsAxisPos;
    property RowsGroupLevel: Integer read FRowsGroupLevel;
    property Value: Variant read FValue;

    property CanModify: Boolean read FCanModify write FCanModify;
    property EditValue: String read FEditValue write FEditValue;
    property FillColor: TColor read FFillColor write FFillColor;
    property Font: TFont read FFont write FFont;
  end;

{ TPivotDataCellEditorSetValueParamsEh }

  TPivotDataCellEditorSetValueParamsEh = class(TPersistent)
  private
    FAreaCol: Integer;
    FAreaRow: Integer;
    FCol: Integer;
    FColsAxisPos: TVariantDynArray;
    FColsGroupLevel: Integer;
    FEditValue: String;
    FRow: Integer;
    FRowsAxisPos: TVariantDynArray;
    FRowsGroupLevel: Integer;
    FUpdateInternalTables: Boolean;
    FValuesAxisPos: Integer;

  public
    property AreaCol: Integer read FAreaCol;
    property AreaRow: Integer read FAreaRow;
    property Col: Integer read FCol;
    property ColsAxisPos: TVariantDynArray read FColsAxisPos;
    property ColsGroupLevel: Integer read FColsGroupLevel;
    property Row: Integer read FRow;
    property RowsAxisPos: TVariantDynArray read FRowsAxisPos;
    property RowsGroupLevel: Integer read FRowsGroupLevel;
    property ValuesAxisPos: Integer read FValuesAxisPos;

    property EditValue: String read FEditValue;
    property UpdateInternalTables: Boolean read FUpdateInternalTables write FUpdateInternalTables;
  end;

{ TPivotGridCellParamsEh }

  TPivotGridCellParamsEh = class(TPersistent)
  private
    FAxisAggregateFont: TFont;
    FAxisColor: TColor;
    FAxisFont: TFont;
    FDataAggregateColor: TColor;
    FDataAggregateFont: TFont;
    FDataColor: TColor;
    FDataFont: TFont;
    FFieldNameColor: TColor;
    FFieldNameFont: TFont;
    FGrid: TCustomPivotGridEh;
    FParentAxisAggregateFont: Boolean;
    FParentAxisFont: Boolean;
    FParentDataAggregateFont: Boolean;
    FParentDataFont: Boolean;
    FParentFieldNameFont: Boolean;

    function IsAxisAggregateFontStored: Boolean;
    function IsAxisFontStored: Boolean;
    function IsDataAggregateFontStored: Boolean;
    function IsDataFontStored: Boolean;
    function IsFieldNameFontStored: Boolean;

    procedure SetDataAggregateColor(const Value: TColor);
    procedure SetDataAggregateFont(const Value: TFont);
    procedure SetDataColor(const Value: TColor);
    procedure SetDataFont(const Value: TFont);
    procedure SetFieldNameColor(const Value: TColor);
    procedure SetFieldNameFont(const Value: TFont);
    procedure SetAxisColor(const Value: TColor);
    procedure SetAxisFont(const Value: TFont);
    procedure SetParentDataAggregateFont(const Value: Boolean);
    procedure SetParentDataFont(const Value: Boolean);
    procedure SetParentFieldNameFont(const Value: Boolean);
    procedure SetParentAxisFont(const Value: Boolean);

    procedure RefreshDefaultDataAggregateFont;
    procedure RefreshDefaultDataFont;
    procedure RefreshDefaultFieldNameFont;
    procedure RefreshDefaultAxisFont;
    procedure RefreshDefaultAxisAggregateFont;
    procedure AssignDefaultFontTo(const AFont: TFont);
    procedure FontChanged(Sender: TObject);
    procedure SetAxisAggregateFont(const Value: TFont);
    procedure SetParentAxisAggregateFont(const Value: Boolean);

  public
    constructor Create(AGrid: TCustomPivotGridEh);
    destructor Destroy; override;

    function DefaultFont: TFont; virtual;
    function ActualDataColor: TColor; virtual;
    function ActualDataAggregateColor: TColor; virtual;
    function ActualAxisColor: TColor; virtual;
    function ActualFieldNameColor: TColor; virtual;
    property Grid: TCustomPivotGridEh read FGrid;

  published
    property AxisAggregateFont: TFont read FAxisAggregateFont write SetAxisAggregateFont stored IsAxisAggregateFontStored;
    property AxisColor: TColor read FAxisColor write SetAxisColor default clDefault;
    property AxisFont: TFont read FAxisFont write SetAxisFont stored IsAxisFontStored;
    property DataAggregateColor: TColor read FDataAggregateColor write SetDataAggregateColor default clDefault;
    property DataAggregateFont: TFont read FDataAggregateFont write SetDataAggregateFont stored IsDataAggregateFontStored;
    property DataColor: TColor read FDataColor write SetDataColor default clDefault;
    property DataFont: TFont read FDataFont write SetDataFont stored IsDataFontStored;
    property FieldNameColor: TColor read FFieldNameColor write SetFieldNameColor default clDefault;
    property FieldNameFont: TFont read FFieldNameFont write SetFieldNameFont stored IsFieldNameFontStored;

    property ParentAxisAggregateFont: Boolean read FParentAxisAggregateFont write SetParentAxisAggregateFont default True;
    property ParentAxisFont: Boolean read FParentAxisFont write SetParentAxisFont default True;
    property ParentDataAggregateFont: Boolean read FParentDataAggregateFont write SetParentDataAggregateFont default True;
    property ParentDataFont: Boolean read FParentDataFont write SetParentDataFont default True;
    property ParentFieldNameFont: Boolean read FParentFieldNameFont write SetParentFieldNameFont default True;
  end;

{ TPivotGridLineParamsEh }

  TPivotGridLineParamsEh = class(TGridLineColorsEh)
  published
    property DarkColor;
    property BrightColor;
  end;

{$IFDEF FPC}
{$ELSE}

{ TCustomPivotGridPrintServiceEh }

  TCustomPivotGridPrintServiceEh = class(TBaseGridPrintServiceEh)
  private
    FGrid: TCustomPivotGridEh;
    procedure SetGrid(const Value: TCustomPivotGridEh);
  public
    property Grid: TCustomPivotGridEh read FGrid write SetGrid;
  published
    property Scale;
    property FitToPagesWide;
    property FitToPagesTall;
    property ScalingMode;
    property Orientation;
    property ColorSchema;
    property PageFooter;
    property PageHeader;
    property PageMargins;
    property TextBeforeContent;
    property TextAfterContent;

    property OnBeforePrint;
    property OnBeforePrintPage;
    property OnBeforePrintPageContent;
    property OnPrintDataBeforeGrid;
    property OnCalcLayoutDataBeforeGrid;

    property OnAfterPrint;
    property OnAfterPrintPage;
    property OnAfterPrintPageContent;
    property OnPrintDataAfterGrid;
    property OnCalcLayoutDataAfterGrid;

    property OnPrinterSetupDialog;
  end;

{$ENDIF}

{ TPivotGridRowAxisOptionsEh }

  TPivotGridRowAxisOptionsEh =  class(TPersistent)
  private
    FTotalsBeforeData: Boolean;
    FHeightAutoExpand: Boolean;
    FAutoWordWrap: Boolean;
    FTotalAtParentLevel: Boolean;
    FGrid: TCustomPivotGridEh;
    procedure SetHeightAutoExpand(const Value: Boolean);
    procedure SetTotalAtParentLevel(const Value: Boolean);
    procedure SetTotalsBeforeData(const Value: Boolean);
    procedure SetAutoWordWrap(const Value: Boolean);
  public
    constructor Create(AGrid: TCustomPivotGridEh);
    destructor Destroy; override;
  published
    property AutoWordWrap: Boolean read FAutoWordWrap write SetAutoWordWrap default True;
    property HeightAutoExpand: Boolean read FHeightAutoExpand write SetHeightAutoExpand default False;
    property TotalsBeforeData: Boolean read FTotalsBeforeData write SetTotalsBeforeData default False;
    property TotalAtParentLevel: Boolean read FTotalAtParentLevel write SetTotalAtParentLevel default True;
  end;

{ TCustomPivotGridEh }

  TPivotGridOptionEh = (pgoRowSizingEh, pgoColSizingEh, pgoEditingEh, pgoWantTabEh,
    pgoFieldDraggingEh, pgoGrandTotalColumnEh, pgoGrandTotalRowEh,
    pgoDataSortingEh, pgoDataFiltersEh, pgoMultiValuesInRowsAxisEh);
  TPivotGridOptionsEh = set of TPivotGridOptionEh;

  TSpicGridStateEh = (dgsNormal, dgsFilterButtonDown);
  TDropToPosTypeEh = (dtptFieldColsEh, dtptFieldRowsEh);
  TCellAreaEh = (caUnspecifiedEh, caDropDownButtonEh, caSortMarkerEh, caCellBorderEh, caTreeExpandSignEh);

  TCurrentCellMovedEvent = procedure(Grid: TCustomPivotGridEh; OldCurrent: TGridCoord) of object;
  TGetPivotDataCellDrawParamsEventEh = procedure(Grid: TCustomPivotGridEh;
    ACol, ARow: Integer; var Params: TPivotCellDataValueDrawParamsEh;
    var Processed: Boolean) of object;
  TGetDataCellEditorParamsEventEh = procedure(Grid: TCustomPivotGridEh;
    ACol, ARow: Integer; Params: TPivotDataCellEditorParamsEh) of object;
  TSetDataCellEditorValueEventEh = procedure(Grid: TCustomPivotGridEh;
    ACol, ARow: Integer; Params: TPivotDataCellEditorSetValueParamsEh) of object;

  TCustomPivotGridEh = class(TCustomSpreadGridEh, IPivotDataSourceNotificationEh)
  private
    FColsAxisTree: TPivotAxisGroupingTreeEh;
    FDefaultDateTimeSliceLevels: TDateTimeSliceLevelsEh;
    FDragStarted: Boolean;
    FBaseDrawCellParams: TPivotCellDrawParamsEh;
    FDataValueDrawParams: TPivotCellDataValueDrawParamsEh;
    FFieldNameDrawParams: TPivotCellFieldNameDrawParamsEh;
    FAxisValueDrawParams: TPivotCellAxisValueDrawParamsEh;
    FFinishLoadingStatusRenderDuration: Integer;
    FGridCellParams: TPivotGridCellParamsEh;
    FLoadingModeBitmap: TBitmap;
    FLoadingModeCallCount : Integer;
    FOnCurrentCellMoved: TCurrentCellMovedEvent;
    FOnDrawDataCell: TGetPivotDataCellDrawParamsEventEh;
    FOnGetDataCellEditorParams: TGetDataCellEditorParamsEventEh;
    FOnGridDefinitionChanged: TNotifyEvent;
    FOnGridLayoutChanged: TNotifyEvent;
    FOnSetDataCellEditorValue: TSetDataCellEditorValueEventEh;
    FOptions: TPivotGridOptionsEh;
    FPivotDataSource: TPivotDataSourceEh;
    FProgressPanel: TPivotProgressIndicatorPanelEh;
    FRowHeight: Integer;
    FRowLines: Integer;
    FRowsAxisTree: TPivotAxisGroupingTreeEh;
    FShowDataBuildingProgress: Boolean;
    FShowHint: Boolean;
    FShowingLoadingMode: Boolean;
    FShowToolTips: Boolean;
    FStartLoadingStatusRenderDuration: Integer;
    FRowAxisOptions: TPivotGridRowAxisOptionsEh;
    FColumnAxisOptions: TPivotGridRowAxisOptionsEh;

    {$IFDEF FPC}
    {$ELSE}
    FPrintService: TCustomPivotGridPrintServiceEh;
    {$ENDIF}

    function CalcDefaultRowHeight: Integer;
    function GetActualColFields: TStringList;
    function GetActualRowFields: TStringList;
    function GetActualValueFields: TValueFieldsCollectionEh;
    function GetDefaultColWidth: Integer;
    function GetGridCellParams: TPivotGridCellParamsEh;
    function GetGridLineParams: TPivotGridLineParamsEh;
    function GetOptions: TPivotGridOptionsEh;
    function GetPivotRowSortedGridArray(ACol, ARow: Integer): TPivotCellEh;
    function GetSourcePivotFields: TPivotFieldsEh;
    function GetValueForInheritedOptions: TGridOptionsEh;
    function GetVisPivotGridArray(ACol, ARow: Integer): TPivotCellEh;
    function IsShowHintStored: Boolean;

    procedure AdjustContraData;
    procedure DrawAxisValueCellData(ACol, ARow: Integer; ARect: TRect; AState: TGridDrawState; PivotCel: TPivotCellEh; ShowGroupingSign, ShowValue: Boolean; const DisplayValue: String);
    procedure DrawSortMarker(var ARect: TRect; AState: TGridDrawState; SortOrder: TSortOrderEh);
    procedure PaintLoadingMode(RenderDuration: Integer);
    procedure PivotDataSourceChanged;
    procedure SetDefaultColWidth(const Value: Integer);
    procedure SetGridCellParams(const Value: TPivotGridCellParamsEh);
    procedure SetGridLineParams(const Value: TPivotGridLineParamsEh);
    procedure SetOptions(const Value: TPivotGridOptionsEh);
    procedure SetPivotDataSource(const Value: TPivotDataSourceEh);
    procedure SetRowHeight(const Value: Integer);
    procedure SetRowLines(const Value: Integer);
    procedure SetShowHint(const Value: Boolean);
    procedure SetShowToolTips(const Value: Boolean);
    procedure StartDrag;
    procedure StopPaintLoadingMode(RenderDuration: Integer);

    {$IFDEF FPC}
    {$ELSE}
    procedure CMCancelMode(var Message: TCMCancelMode); message CM_CancelMode;
    {$ENDIF}
    procedure CMHintShow(var Message: TCMHintShow); message CM_HINTSHOW;
    procedure CMHintsShowPause(var Message: TCMHintShowPause); message CM_HINTSHOWPAUSE;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;

    procedure WMCancelMode(var Message: TMessage); message WM_CANCELMODE;
    procedure WMEraseBackground(var Message: TWmEraseBkgnd); message WM_ERASEBKGND;
    procedure WMHScroll(var Message: TWMHScroll); message WM_HSCROLL;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KillFocus;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
    function GetIsMultiValuesInRowsAxis: Boolean;

  protected
    FDataBuildingProgressDelay: Integer;
    FDataSortColNum: Integer;
    FDataSortSortOrder: TSortOrderEh;
    FDragCell: TPivotCellEh;
    FDragPos: Integer;
    FDropToCell: TPivotCellEh;
    FDropToPos: Integer;
    FDummyPivotField: TPivotFieldEh;
    FEditText: Variant;
    FEditUserTextModified: Boolean;
    FFullVisPivotColCount: Integer;
    FHotTrackEditButton: Integer;
    FInternalCellSizeSetting: Boolean;
    FInTitleFilterListboxVisible: Boolean;
    FInTitleFilterPivotField: TPivotFieldEh;
    FMouseDownPos: TPoint;
    FPivotArrayDataColCount: Integer;
    FPivotArrayDataRowCount: Integer;
    FRowsCaptionExpandedState: TBooleanDynArray;
    FShowGrandTotalCols, FShowGrandTotalRows: Boolean;
    FSpicGridState: TSpicGridStateEh;
    FStartDataCol, FStartDataRow: Integer;
    FTrackingStateRect: TRect;
    FVisPivotColCount: Integer;
    FVisPivotColCountAffix: Integer;
    FVisPivotRowCount: Integer;
    PivotGridArray: TPivotGridArray;
    FInValuesCellGroupBorderColor: TColor;
    FInAxisValuesCellGroupBorderColor: TColor;

    function CanEditModify: Boolean; override;
    function CanHotTackCell(X, Y: Integer): Boolean; override;
    function CreateEditor: TInplaceEdit; override;
    function CreateGridLineColors: TGridLineColorsEh; override;
    function CreateHorzScrollBarPanelControl: TGridScrollBarPanelControlEh; override;
    function CreateScrollBar(AKind: TScrollBarKind): TGridScrollBarEh; override;
    function FixedColsSizingAllowed: Boolean; override;
    function FullRedrawOnScroll: Boolean; override;
    function GetEditText(ACol, ARow: Integer): string; override;
    function IsSmoothHorzScroll: Boolean; override;
    function IsSmoothVertScroll: Boolean; override;
    function NeedBufferedPaint: Boolean; override;
    function WMCheckCanSendDoubleClicks(var MouseEvent: TWMMouse): Boolean; override;

    function CanMouseTrackMode: Boolean;
    function CreateGridCellParams: TPivotGridCellParamsEh; virtual;
    function DragDropHitTestInfo(X, Y: Integer; var LinePos: TPoint; var LineSize: Integer; var DropToPos: Integer; var FDragToField: TPivotCellEh): Boolean;
    function GetCellHitArea(PivotCel: TPivotCellEh; const ACellRect: TRect; CellMousePos: TPoint): TCellAreaEh;
    function GetDrawCellParams(DrawEvtArg: TDrawSpreadCellArgsEh; PivotCell: TPivotCellEh): TPivotCellDrawParamsEh; virtual;
    function GetInTitleFilterForm: TFilterDropDownForm; virtual;
    function GetMouseHitCellState(Cell: TGridCoord; MousePos: TPoint; CellRect: TRect; var StateRect: TRect): TSpicGridStateEh;
    function GrandTotalColVisible: Boolean;
    function GrandTotalRowVisible: Boolean;
    function GridTextIsVisible: Boolean;

    procedure CelLenChanged(Axis: TGridAxisDataEh; Index, OldLen: Integer); override;
    procedure CellMouseClick(const Cell: TGridCoord; Button: TMouseButton; Shift: TShiftState; const ACellRect: TRect; const GridMousePos, CellMousePos: TPoint); override;
    procedure CellMouseDown(const Cell: TGridCoord; Button: TMouseButton; Shift: TShiftState; const ACellRect: TRect; const GridMousePos, CellMousePos: TPoint); override;
    procedure ChangeScale(M, D: Integer {$IFDEF EH_LIB_24}; isDpiChange: Boolean {$ENDIF}); override;
    procedure CheckDrawCellBorder(ACol, ARow: Integer; BorderType: TGridCellBorderTypeEh; var IsDraw: Boolean; var BorderColor: TColor; var IsExtent: Boolean); override;
    procedure CreateWnd; override;
    procedure CurrentCellMoved(OldCurrent: TGridCoord); override;
    procedure DoEndDrag(Target: TObject; X, Y: Integer); override;
    procedure DoStartDrag(var DragObject: TDragObject); override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;
    procedure DrawBaseCell(ACol, ARow: Integer; ARect: TRect; State: TGridDrawState); override;
    procedure DrawSpreadCell(EvtArg: TDrawSpreadCellArgsEh); override;
    procedure HideEditor; override;
    procedure InteractiveSetColWidth(ColIndex: Integer; Value: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Paint; override;
    procedure Resize; override;
    procedure SelectionChanged(const OldSel: TGridRect); override;
    procedure SetEditText(ACol, ARow: Integer; const Value: string); override;
    procedure SetPaintColors; override;
    procedure SpreadCellMouseDown(const Cell: TGridCoord; Button: TMouseButton; Shift: TShiftState; const ACellRect: TRect; const GridMousePos, CellMousePos: TPoint); override;
    procedure ShowEditor; override;
    procedure UpdateText(EditorChanged: Boolean); override;
    procedure GetSpreadCellHintShowParams(AParams: TSpreadCellShowHintParamsEh); override;

    procedure AddNodeToList(Sender: TBaseTreeNodeEh; Param: TObject);
    procedure BindAxisTreeToBaseAxisRecs(AxisTree: TPivotAxisGroupingTreeEh; BaseAxisTable: TMemTableEh; AActualAxisFieldCount: Integer);
    procedure BindAxisTreeToPivotKeyValueStates(AxisTree: TPivotAxisGroupingTreeEh; Node: TPivotAxisTreeNodeEh; AAxisFields: TStringList);
    procedure BindNodesListToPivotKeyValueState(NodesList: TObjectList; KeyValueStates: TPivotKeyValueStatesEh; Level: Integer);
    procedure BuildGridArrayColsMeasures;
    procedure BuildGridArrayRowsMeasures;
    procedure BuildGridArrayValuesMeasures;
    procedure CancelEditor;
    procedure ColExpandedChanged(Node: TPivotAxisTreeNodeEh);
    procedure DoCopyAction; virtual;
    procedure DrawSpreadAxisValueCell(ADrawCellAxisValueParams: TPivotCellAxisValueDrawParamsEh); virtual;
    procedure DrawAxisValueCellBack(ACol, ARow: Integer; ARect: TRect; AState: TGridDrawState; PivotCel: TPivotCellEh); virtual;
    procedure DrawCellSign(ACol, ARow: Integer; var ARect: TRect; ADrawDataCellParams: TPivotCellDataValueDrawParamsEh);
    procedure DrawDataCell(ADrawDataCellParams: TPivotCellDataValueDrawParamsEh); virtual;
    procedure DrawEmptyCell(ACellDrawParams: TPivotCellDrawParamsEh); virtual;
    procedure DrawFieldNameCell(ADrawDataCellParams: TPivotCellFieldNameDrawParamsEh); virtual;
    procedure DrawFilterButton(var ARect: TRect; AState: TGridDrawState; FilterHaveValues: Boolean); virtual;
    procedure DrawPivotCell(ACellDrawParams: TPivotCellDrawParamsEh); virtual;
    procedure FillBaseDrawCellParams(ADrawCellParams: TPivotCellDrawParamsEh; ACol, ARow: Integer; PivotCell: TPivotCellEh); virtual;
    procedure FillAxisValueCellParams(ADrawCellParams: TPivotCellAxisValueDrawParamsEh; ACol, ARow: Integer; PivotCell: TPivotCellEh); virtual;

    procedure FillDataCellEditorParams(ACellEditorParams: TPivotDataCellEditorParamsEh; ACol, ARow: Integer);
    procedure FillDataCellEditorSetValueParams(ACellEditorParams: TPivotDataCellEditorSetValueParamsEh; ACol, ARow: Integer);
    procedure FillDataCellParams(ADrawCellParams: TPivotCellDataValueDrawParamsEh; ACol, ARow: Integer; PivotCell: TPivotCellEh); virtual;
    procedure FillDrawCellParams(ADrawCellParams: TPivotCellDrawParamsEh; ACol, ARow: Integer; ARect: TRect; AState: TGridDrawState; PivotCell: TPivotCellEh); virtual;
    procedure FillFieldNameCellParams(ADrawCellParams: TPivotCellFieldNameDrawParamsEh; ACol, ARow: Integer; PivotCell: TPivotCellEh);
    procedure FilterFormCloseUp(Accept: Boolean); virtual;
    procedure FilterFormDropDown(Cell: TGridCoord; const CellRect, ButtonRect: TRect);
    procedure GetFilterButtonRect(const ACellRect: TRect; var AButtonRect, AGrossRect: TRect; ARightToLeftAlignment: Boolean);
    procedure GetVisPivotGridArrayPosByAxisCell(PivotCel: TPivotCellEh; var VisCellCoord: TPoint);
    procedure GetVisPivotGridArrayPosByAxisTreeNode(RowsTreeNode: TPivotAxisTreeNodeEh; var VisCellCoord: TPoint);
    procedure GridCellParamsChanged; virtual;
    procedure GridLayoutChanged; virtual;
    procedure HideProgressPanel;
    procedure InternalSetColWidth(ACol, AWidth: Integer);
    procedure InternalSetRowHeight(ARow, AHeight: Integer);
    procedure InTitleFilterDropDownFormCallbackProc(DropDownForm: TCustomForm; Accept: Boolean; DynParams: TDynVarsEh; SysParams: TDropDownFormSysParams);
    procedure InTitleFilterListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure InTitleFilterListKeyPress(Sender: TObject; var Key: Char);
    procedure InTitleFilterListMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PaintEmptyDataInfo; virtual;
    procedure PaintInplaceButton(Canvas: TCanvas; ButtonStyle: TEditButtonStyleEh; Rect, ClipRect: TRect; DownButton: Integer; Active, Flat, Enabled: Boolean; ParentColor: TColor; Bitmap: TBitmap; TransparencyPercent: Byte; imList: TCustomImageList; ImageIndex: Integer);
    procedure PivotDataSourceChange(Sender: TObject);
    procedure PostEditText(var IsRebuildData: Boolean); virtual;
    procedure RowExpandedChanged(Node: TPivotAxisTreeNodeEh); virtual;
    procedure SetAxisColExpandedState(PivotCel: TPivotCellEh; Expanded: Boolean);
    procedure SetAxisRowExpandedState(PivotCel: TPivotCellEh; Expanded: Boolean); virtual;
    procedure SetColRowAxisPosForDataCell(ADataCol, ADataRow: Integer; var AColsAxisPos: TVariantDynArray; var ARowsAxisPos: TVariantDynArray);
    procedure SetColsCaptionsExpandedState;
    procedure SetPivotGridArrayVars;
    procedure SetRowsCaptionsExpandedState;
    procedure SetRowsColsCaptionsExpandedState;
    procedure ShowProgressPanel(ElapsedTime: LongWord; Percent: Integer);
    procedure UpdateInternalTablesForEditorValue(ACellEditorParams: TPivotDataCellEditorSetValueParamsEh);
    procedure UpdateRowHeightsToFitRowsAxisCells;

    property PivotRowSortedGridArray[ACol, ARow: Integer]: TPivotCellEh read GetPivotRowSortedGridArray;

  protected
    { IPivotDataSourceNotificationEh }
    function PivotDataChangeProgress(Sender: TObject; ElapsedTime: LongWord; Percent: Integer): Boolean;

    procedure PivotFieldsChanged(Sender: TObject);
    procedure PivotStructureChanged(Sender: TObject);
    procedure PivotDataChanged(Sender: TObject);
    procedure PivotDataStartChanging(Sender: TObject);
    procedure PivotDataFinishChanging(Sender: TObject);
    procedure PivotDataChangingCanceled(Sender: TObject);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function ActualColFieldCount: Integer;
    function ActualRowFieldCount: Integer;
    function DataSourceIsEmpty: Boolean; virtual;
    function GetCellContentRect(ACol, ARow: Integer; ACellRect: TRect; PivotCel: TPivotCellEh): TRect; virtual;
    function GrandTotalColCount: Integer;
    function GrandTotalRowCount: Integer;
    function GridIsEmpty: Boolean;
    function InColsAxisValuesCount: Integer;
    function InRowsAxisValuesCount: Integer;

    procedure AggregateGridForColumns;
    procedure AggregateGridForColumnsLevel(ColsLevel: Integer);
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
    procedure EmptyGridData;
    procedure FillGridDataForActualRowFields;
    procedure FinishDragFrom(Source: TObject); virtual;
    procedure FinishLoadingStatus(RenderDuration: Integer = -1);
    procedure GetValueFieldsInfoFromCommaText(const ACommaText: String);
    procedure GridOptionsChanged;
    procedure MakeColSortingTree;
    procedure MakePivotGridArray;
    procedure MakeRowSortingTree;
    procedure MakeVisPivotGridArray;
    procedure MoveAggrRowBeforeData;
    procedure RebuildGrid;
    procedure ResortColSortingTree;
    procedure ResortRowSortingTree;
    procedure SetColLevelExpanded(AColLevel: Integer; IsExpanded: Boolean; const KeyValues: TVariantDynArray);
    procedure SetGridColsRows(AFixedColCount, ADataColCount, AContraColCount, AFixedRowCount, ADataRowCount, AContraRowCount: Integer);
    procedure SetGridMerges;
    procedure SetGridSizes(ForceUpdateBaseData: Boolean);
    procedure SetPivotGridArraySize(AColCount, ARowCount: Integer);
    procedure SetRowHeightsColumnWidths;
    procedure SetRowLevelExpanded(ARowLevel: Integer; IsExpanded: Boolean; const KeyValues: TVariantDynArray);
    procedure StartLoadingStatus(RenderDuration: Integer = -1);
    procedure VisPivotPosToSrcArrayPos(AVisCol, AVisRow: Integer; var ASrcCol, ASrcRow: Integer);

    property ActualColFields: TStringList read GetActualColFields;
    property ActualRowFields: TStringList read GetActualRowFields;
    property ActualValueFields: TValueFieldsCollectionEh read GetActualValueFields;
    property Col;
    property ColsAxisTree: TPivotAxisGroupingTreeEh read FColsAxisTree;
    property DataBuildingProgressDelay: Integer read FDataBuildingProgressDelay write FDataBuildingProgressDelay default 1000;
    property DefaultColWidth: Integer read GetDefaultColWidth write SetDefaultColWidth default 80;
    property DefaultDateTimeSliceLevels: TDateTimeSliceLevelsEh read  FDefaultDateTimeSliceLevels write FDefaultDateTimeSliceLevels default [dtslYearEh, dtslMonthEh, dtslDayEh];
    property GridCellParams: TPivotGridCellParamsEh read GetGridCellParams write SetGridCellParams;
    property GridLineParams: TPivotGridLineParamsEh read GetGridLineParams write SetGridLineParams;
    property Options: TPivotGridOptionsEh read GetOptions write SetOptions default [pgoColSizingEh, pgoEditingEh, pgoWantTabEh, pgoFieldDraggingEh, pgoGrandTotalColumnEh, pgoGrandTotalRowEh, pgoDataSortingEh, pgoDataFiltersEh];
    property PivotDataSource: TPivotDataSourceEh read FPivotDataSource write SetPivotDataSource;
    property PivotFields: TPivotFieldsEh read GetSourcePivotFields;
    property Row;
    property RowHeight: Integer read FRowHeight write SetRowHeight default 0;
    property RowLines: Integer read FRowLines write SetRowLines default 0;
    property RowsAxisTree: TPivotAxisGroupingTreeEh read FRowsAxisTree;
    property ShowDataBuildingProgress: Boolean read FShowDataBuildingProgress write FShowDataBuildingProgress default True;
    property ShowHint: Boolean read FShowHint write SetShowHint stored IsShowHintStored;
    property ShowToolTips: Boolean read FShowToolTips write SetShowToolTips;
    property VisPivotGridArray[ACol, ARow: Integer]: TPivotCellEh read GetVisPivotGridArray;
    {$IFDEF FPC}
    {$ELSE}
    property PrintService: TCustomPivotGridPrintServiceEh read FPrintService;
    {$ENDIF}
    property RowAxisOptions: TPivotGridRowAxisOptionsEh read FRowAxisOptions;
    property ColumnAxisOptions: TPivotGridRowAxisOptionsEh read FColumnAxisOptions;
    property IsMultiValuesInRowsAxis: Boolean read GetIsMultiValuesInRowsAxis;

    property OnCellMouseClick;
    property OnCellMouseDown;
    property OnCurrentCellMoved: TCurrentCellMovedEvent read FOnCurrentCellMoved write FOnCurrentCellMoved;
    property OnDrawDataCell: TGetPivotDataCellDrawParamsEventEh read FOnDrawDataCell write FOnDrawDataCell;
    property OnGetDataCellEditorParams: TGetDataCellEditorParamsEventEh read FOnGetDataCellEditorParams write FOnGetDataCellEditorParams;
    property OnGridDefinitionChanged: TNotifyEvent read FOnGridDefinitionChanged write FOnGridDefinitionChanged;
    property OnGridLayoutChanged: TNotifyEvent read FOnGridLayoutChanged write FOnGridLayoutChanged;
    property OnSetDataCellEditorValue: TSetDataCellEditorValueEventEh read FOnSetDataCellEditorValue write FOnSetDataCellEditorValue;
  end;

{ TPivotGridEh }

  TPivotGridEh = class(TCustomPivotGridEh)
  public
    property Canvas;
    property Col;
    property Row;
    property RowCount;
    property ColCount;
    property ColWidths;
    property RowHeights;
    property FullColCount;
    property FullRowCount;

  published
    property DataBuildingProgressDelay;
    property ColumnAxisOptions;
    property DefaultColWidth;
    property GridCellParams;
    property GridLineParams;
    property Options;
    property PivotDataSource;
    property RowAxisOptions;
    property RowHeight;
    property RowLines;
    property ShowDataBuildingProgress;

    property OnDrawDataCell;
    property OnGetDataCellEditorParams;
    property OnSetDataCellEditorValue;
    property OnGridDefinitionChanged;
    property OnGridLayoutChanged;
    property OnCurrentCellMoved;

    property Align;
    property Anchors;
    property BiDiMode;
    property BorderStyle;
    property Color;
    property Constraints;
    property ContraColCount;
    {$IFDEF FPC}
    {$ELSE}
    property Ctl3D;
    {$ENDIF}
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FixedColor;
    property Flat;
    property Font;
    property HorzScrollBar;
    {$IFDEF FPC}
    {$ELSE}
    property ImeMode;
    property ImeName;
    {$ENDIF}
    property ParentBiDiMode;
    {$IFDEF FPC}
    {$ELSE}
    property ParentCtl3D;
    property PrintService;
    {$ENDIF}
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property SelectionDrawParams;
    property ShowHint;
    property ShowToolTips;
    property TabOrder;
    property TabStop;
{$IFDEF EH_LIB_13}
    property Touch;
{$ENDIF}
    property VertScrollBar;
    property Visible;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
{$IFDEF EH_LIB_13}
    property OnGesture;
{$ENDIF}
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
{$IFDEF EH_LIB_10}
    property OnMouseEnter;
    property OnMouseLeave;
{$ENDIF}
{$IFDEF FPC}
    property OnMouseEnter;
    property OnMouseLeave;
{$ENDIF}
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnStartDock;
    property OnStartDrag;
  end;

{ TPivotGridFilterPopupListboxItemEh }

  TPivotGridFilterPopupListboxItemEh = class(TPopupListboxItemEh)
  protected
    function GetPivotField(Listbox: TCustomListboxEh): TPivotFieldEh;
    function GetGrid(Listbox: TCustomListboxEh): TCustomPivotGridEh;
  end;

{ TPopupListboxItemEhData }

  TPopupListboxItemEhData = class(TPivotGridFilterPopupListboxItemEh)
  protected
    function CanFocus(Sender: TCustomListboxEh; ItemIndex: Integer): Boolean; override;
    procedure DrawItem(Sender: TCustomListboxEh; ItemIndex: Integer; ARect: TRect; State: TGridDrawState); override;
    procedure KeyPress(Sender: TCustomListboxEh; ItemIndex: Integer; var Key: Char; Shift: TShiftState; var IsCloseListbox: Boolean); override;
    procedure MouseDown(Sender: TCustomListboxEh; ItemIndex: Integer; InItemPos: TPoint; Button: TMouseButton; Shift: TShiftState); override;
    procedure MouseMove(Sender: TCustomListboxEh; ItemIndex: Integer; InItemPos: TPoint; Shift: TShiftState); override;
    procedure MouseUp(Sender: TCustomListboxEh; ItemIndex: Integer; InItemPos: TPoint; Button: TMouseButton; Shift: TShiftState; var IsCloseListbox: Boolean); override;

  public
    function CloseOnExecute(Sender: TCustomListboxEh; ItemIndex: Integer): Boolean; override;
    procedure Execute(Sender: TCustomListboxEh; ItemIndex: Integer; InItemPos: TPoint; Shift: TShiftState); override;
  end;

  TPopupListboxItemEhSpecType = (ptFilterSpecSelectAll, ptFilterApply, ptFilterRowLine);

{ TPopupListboxItemEhSpec }

  TPopupListboxItemEhSpec = class(TPivotGridFilterPopupListboxItemEh)
  protected
    FType: TPopupListboxItemEhSpecType;

    function CanFocus(Sender: TCustomListboxEh; ItemIndex: Integer): Boolean; override;
    procedure DrawItem(Sender: TCustomListboxEh; ItemIndex: Integer; ARect: TRect; State: TGridDrawState); override;
    procedure MouseDown(Sender: TCustomListboxEh; ItemIndex: Integer; InItemPos: TPoint; Button: TMouseButton; Shift: TShiftState); override;
    procedure MouseUp(Sender: TCustomListboxEh; ItemIndex: Integer; InItemPos: TPoint; Button: TMouseButton; Shift: TShiftState; var IsCloseListbox: Boolean); override;

  public
    constructor Create(AType: TPopupListboxItemEhSpecType);
    procedure Execute(Sender: TCustomListboxEh; ItemIndex: Integer; InItemPos: TPoint; Shift: TShiftState); override;
  end;

  TPivotGridDrabObj = class(TDragControlObjectEx)
  protected
    function GetDragCursor(Accepted: Boolean; X, Y: Integer): TCursor; override;
  public
    FDragCell: TPivotCellEh;
    FPivotField: TPivotFieldEh;
    FPivotFieldName: String;
    FPivotFieldValueInfo: TPivotFieldValueInfoEh;

    destructor Destroy; override;
  end;

{ TPivotGridSelectionInfoPanel }

  TPivotGridSelectionInfoPanel = class (TCustomControl)
  private
    function GetGrid: TCustomPivotGridEh;
    function InfoWidth: Integer;
    procedure WMEraseBackground(var Message: TWmEraseBkgnd); message WM_ERASEBKGND;

  protected
    FAggrText: String;
    procedure GridSelectionChanged;
    procedure Paint; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function HaveData: Boolean;
    property Grid: TCustomPivotGridEh read GetGrid;
  end;

  { TPivotGridScrollBarPanelControl }

  TPivotGridScrollBarPanelControl = class(TGridScrollBarPanelControlEh)
  private
    FSelInfoPanel: TPivotGridSelectionInfoPanel;

  protected
    procedure Resize; override;
    procedure CreateHandle; override;

  public
    constructor Create(AOwner: TComponent; AKind: TScrollBarKind); reintroduce;
    destructor Destroy; override;
    procedure GridSelectionChanged;
  end;

{ TPivotGridScrollBarEh }

  TPivotGridScrollBarEh = class(TGridScrollBarEh)
  protected
    function CheckScrollBarMustBeShown: Boolean; override;
  end;

{ TPivotProgressBarEh }

  TPivotProgressBarEh = class(TProgressBar)
  private
    FCanvas: TControlCanvas;
    FBufferBitmap: TBitmap;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

{ TPivotProgressIndicatorPanelEh }

  TPivotProgressIndicatorPanelEh = class(TCustomPanel)
  private
    FControlFlipChildren: Boolean;
    procedure CMBiDiModeChanged(var Message: TMessage); message CM_BIDIMODECHANGED;
  protected
    FLabelEsc: TLabel;
    FLabelNote: TLabel;
    FLabelTimePassed: TLabel;
    FProgressBar: TPivotProgressBarEh;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

{ TPivotGridInplaceEditEh }

  TPivotGridInplaceEditEh = class(TInplaceEdit)
  private
    function GetGrid: TCustomPivotGridEh;

  protected
    procedure UpdateContents; override;
    procedure UserChange; virtual;

  public

    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;

    property Grid: TCustomPivotGridEh read GetGrid;
  end;

  TPivotGridExportAsOLEXLSOptionEh = (pgxlsColoredEh, pgxlsDataAsEditText);
  TPivotGridExportAsOLEXLSOptionsEh = set of TPivotGridExportAsOLEXLSOptionEh;

procedure StartWait;
procedure StopWait;

{$IFDEF MSWINDOWS}
function ExportPivotGridEhToOleExcel(Grid: TCustomPivotGridEh;
  Options: TPivotGridExportAsOLEXLSOptionsEh
  ): Variant;
{$ELSE}
{$ENDIF}

function PivotAggrValueDisplayNames(ValueType: TPivotValueTypeEh): String;

var
  hcrDropToGarbageEh: HCursor = 0;
  hcrDropToGarbageIndexEh: TCursor;
  FlatPivotProgressIndicator: Boolean = True;
  SliceDisplayNames: array[TFieldDateTimeSliceLevelEh] of String;

const
  SliceNames: array[TFieldDateTimeSliceLevelEh] of String =
    ('Non', 'Year', 'Quarter', 'Month', 'Week',
     'Day', 'Hour', 'Min', 'Sec', 'MSec');

  SliceNamesDisplayFormat: array[TFieldDateTimeSliceLevelEh] of String =
    ('', 'YYYY', 'YYYY/MM', 'YYYY/MM', 'YYYY/WW',
     'YYYY/MM/DD', 'YYYY/MM/DD HH', 'YYYY/MM/DD HH:NN', 'YYYY/MM/DD HH:NN:SS', '');

  PivotAggrValueTypes: array[TPivotValueTypeEh] of String = ('Sum',
    'Count', 'Average', 'Max', 'Min', 'Count Distinct', 'Product',
    'StDev', 'StDevp', 'Var', 'Varp', 'Custom');

  StandardAggregateFunctionCalculators: array[TPivotValueTypeEh] of TPivotGridAggregateFunctionCalculatorEhClass =
  (TPivotGridSumFunctionCalculatorEh,
   TPivotGridCountFunctionCalculatorEh,
   TPivotGridAverageFunctionCalculatorEh,
   TPivotGridMaxFunctionCalculatorEh,
   TPivotGridMinFunctionCalculatorEh,
   TPivotGridCountDistinctFunctionCalculatorEh,
   TPivotGridProductFunctionCalculatorEh,
   TPivotGridStDevFunctionCalculatorEh,
   TPivotGridStDevpFunctionCalculatorEh,
   TPivotGridVarFunctionCalculatorEh,
   TPivotGridVarpFunctionCalculatorEh,
   nil);

implementation

uses Math, {ComObj, }StrUtils, ClipBrd, DBGridEhToolCtrls,
{$IFDEF FPC}
{$ELSE}
  PrintPivotGridsEh,
{$ENDIF}
  EhLibLangConsts, PivotGridToolsEh;

var
  InplaceBitmap: TBitmap;
  PopupListboxItemEhData: TPopupListboxItemEhData;
  PopupListboxItemEhApplyFilter: TPopupListboxItemEhSpec;
  PopupListboxItemEhSelectAll: TPopupListboxItemEhSpec;
  PopupListboxItemEhRowLine: TPopupListboxItemEhSpec;

var
  WaitCount: Integer = 0;
  SaveCursor: TCursor = crDefault;

const
  WaitCursor: TCursor = crHourGlass;

procedure SetFieldValueAsVariant(AField: TField; const AValue: Variant);
begin
  if AField is TLargeintField then
  begin
    if VarIsNull(AValue)
      then TLargeintField(AField).Clear
      else TLargeintField(AField).AsLargeInt := AValue;
  end else
    AField.Value := AValue;
end;

function GetCanvasFontOneLineHeight(AControl: TWinControl; ACanvas: TCanvas; AFont: TFont): Integer;
var
  tm: TTEXTMETRIC;
  RestoreCanvas: Boolean;
begin
  RestoreCanvas := not AControl.HandleAllocated;
  if RestoreCanvas then
    ACanvas.Handle := GetDC(0);
  try
    ACanvas.Font := AFont;
    GetTextMetrics(ACanvas.Handle, tm);
    Result := tm.tmExternalLeading + tm.tmHeight;
  finally
    if RestoreCanvas then
    begin
      ReleaseDC(0, ACanvas.Handle);
      ACanvas.Handle := 0;
    end;
  end;
end;

function VarToDoubleDef(const Val: Variant; const ADefault: Double): Double;
begin
  if VarIsEmpty(Val) or VarIsNull(Val) then
    Result := ADefault
  else
    Result := Val;
end;

procedure StartWait;
begin
  if WaitCount = 0 then
  begin
    SaveCursor := Screen.Cursor;
    Screen.Cursor := WaitCursor;
  end;
  Inc(WaitCount);
end;

procedure StopWait;
begin
  if WaitCount > 0 then
  begin
    Dec(WaitCount);
    if WaitCount = 0 then
      Screen.Cursor := SaveCursor;
  end;
end;

procedure InitPivotGridEh;
var
  i: Integer;
begin
  PopupListboxItemEhData := TPopupListboxItemEhData.Create;
  PopupListboxItemEhApplyFilter := TPopupListboxItemEhSpec.Create(ptFilterApply);
  PopupListboxItemEhSelectAll := TPopupListboxItemEhSpec.Create(ptFilterSpecSelectAll);
  PopupListboxItemEhRowLine := TPopupListboxItemEhSpec.Create(ptFilterRowLine);

  hcrDropToGarbageEh := LoadCursorEh(hInstance, 'DROPTOGARBAGEEH');

  for i := 1 to MaxInt do
  {$IFDEF FPC}
  if Screen.Cursors[i] = 0 then
  {$ELSE}
  if Screen.Cursors[i] = Screen.Cursors[0] then
  {$ENDIF}
    begin
      Screen.Cursors[i] := hcrDropToGarbageEh;
      hcrDropToGarbageIndexEh := i;
      Break;
    end;

  SliceDisplayNames[dtslNonEh] := EhLibLanguageConsts.PivotSliceNonDisplayNameEh;
  SliceDisplayNames[dtslYearEh] := EhLibLanguageConsts.PivotSliceYearDisplayNameEh;
  SliceDisplayNames[dtslQuarterEh] := EhLibLanguageConsts.PivotSliceQuarterDisplayNameEh;
  SliceDisplayNames[dtslMonthEh] := EhLibLanguageConsts.PivotSliceMonthDisplayNameEh;
  SliceDisplayNames[dtslWeekEh] := EhLibLanguageConsts.PivotSliceWeekDisplayNameEh;
  SliceDisplayNames[dtslDayEh] := EhLibLanguageConsts.PivotSliceDayDisplayNameEh;
  SliceDisplayNames[dtslHourEh] := EhLibLanguageConsts.PivotSliceHourDisplayNameEh;
  SliceDisplayNames[dtslMinEh] := EhLibLanguageConsts.PivotSliceMinDisplayNameEh;
  SliceDisplayNames[dtslSecEh] := EhLibLanguageConsts.PivotSliceSecDisplayNameEh;
  SliceDisplayNames[dtslMSecEh] := EhLibLanguageConsts.PivotSliceMSecDisplayNameEh;

end;

procedure FinallyPivotGridEh;
begin
  FreeAndNil(PopupListboxItemEhData);
  FreeAndNil(PopupListboxItemEhApplyFilter);
  FreeAndNil(PopupListboxItemEhSelectAll);
  FreeAndNil(PopupListboxItemEhRowLine);

  FreeAndNil(InplaceBitmap);
  DestroyCursor(hcrDropToGarbageEh);
end;

function GetInplaceBitmap(Width, Height: Integer): TBitmap;
begin
  if InplaceBitmap = nil then
    InplaceBitmap := TBitmap.Create;
  if InplaceBitmap.Width < Width then
    InplaceBitmap.Width := Width;
  if InplaceBitmap.Height < Height then
    InplaceBitmap.Height := Height;
  Result := InplaceBitmap;
end;

function VarArrayEqualLevelForDepth(const V1, V2: TVariantDynArray; Depth: Integer): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Length(V1)-1 do
  begin
    Result := i+1;
    if i = Depth then
    begin
      Result := i;
      Break
    end else if not VarSameValue(V1[i], V2[i]) then
    begin
      Result := i;
      Break;
    end;
  end
end;

function VarArrayEqual(const V1, V2: TVariantDynArray): Boolean;
begin
  Result := (VarArrayEqualLevelForDepth(V1, V2, Length(V1)) = Length(V1));
end;

function VarEquals(const V1, V2: TVariantDynArray): Boolean;
var
  i: Integer;
  Val1, Val2: Variant;
begin
  Result := False;
  try
    for i := 0 to Length(V1)-1 do
    begin
      Val1 := V1[i];
      Val2 := V2[i];
      Result := Val1 = Val2;
      if not Result then Exit;
    end
  except
  end;
end;

function VarForceCompareValue(const A, B: Variant): TVariantRelationship;
begin
  if VarIsEmpty(A) or VarIsEmpty(B) then
  begin
    if VarIsEmpty(A) and VarIsEmpty(B) then
      Result := vrEqual
    else if VarIsEmpty(A) then
      Result := vrGreaterThan
    else
      Result := vrLessThan;
  end else if VarIsNull(A) or VarIsNull(B) then
  begin
    if VarIsNull(A) and VarIsNull(B) then
      Result := vrEqual
    else if VarIsEmpty(A) then
      Result := vrLessThan
    else
      Result := vrGreaterThan;
  end else
    Result := VarCompareValue(A, B);
end;

function VarArrayForceCompareValue(const V1, V2: TVariantDynArray): TVariantRelationship;
var
  i: Integer;
begin
  Result := vrEqual;
  if Length(V1) <> Length(V2) then
    Result := vrNotEqual
  else
  begin
    for i := 0 to Length(V1)-1 do
    begin
      Result := VarForceCompareValue(V1[i], V2[i]);
      if Result <> vrEqual then
        Break;
    end;
  end;
end;

function PivotAggrValueDisplayNames(ValueType: TPivotValueTypeEh): String;
begin
  case ValueType of
    svtSumEh: Result := EhLibLanguageConsts.PivotSumFunctionSum;
    svtCountEh: Result := EhLibLanguageConsts.PivotSumFunctionCount;
    svtAvgEh: Result := EhLibLanguageConsts.PivotSumFunctionAvg;
    svtMaxEh: Result := EhLibLanguageConsts.PivotSumFunctionMax;
    svtMinEh: Result := EhLibLanguageConsts.PivotSumFunctionMin;
    svtCountDistinctEh: Result := EhLibLanguageConsts.PivotSumFunctionCountDistinct;
    svtProductEh: Result := EhLibLanguageConsts.PivotSumFunctionProduct;
    svtStDevEh: Result := EhLibLanguageConsts.PivotSumFunctionStDev;
    svtStDevpEh: Result := EhLibLanguageConsts.PivotSumFunctionStDevp;
    svtVarEh: Result := EhLibLanguageConsts.PivotSumFunctionVar;
    svtVarpEh: Result := EhLibLanguageConsts.PivotSumFunctionVarp;
    svtCustomEh: Result := EhLibLanguageConsts.PivotSumFunctionCustom;
  end;
end;

function GetDataSetFieldValue(DataSet: TDataSet; Field: TField): Variant;
begin
  if DataSet is TMemTableEh then
    Result := TMemTableEh(DataSet).Rec.Value[Field.FieldNo-1, dvvValueEh]
  else
    Result := Field.Value;
end;

{ TCustomPivotGridEh }

constructor TCustomPivotGridEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  HorzScrollBar.SmoothStep := True;
  VertScrollBar.SmoothStep := True;

  FOptions := [pgoColSizingEh, pgoEditingEh, pgoWantTabEh, pgoFieldDraggingEh,
    pgoGrandTotalColumnEh, pgoGrandTotalRowEh, pgoDataSortingEh, pgoDataFiltersEh];
  inherited Options := GetValueForInheritedOptions;

  FDefaultDateTimeSliceLevels := [dtslYearEh, dtslMonthEh, dtslDayEh];

  FDummyPivotField := TPivotFieldEh.Create(nil);

  EmptyGridData;
  DefaultColWidth := 80;

  FRowsAxisTree := TPivotAxisGroupingTreeEh.Create(Self, TPivotAxisTreeNodeEh, padVerticalEh);
  FColsAxisTree := TPivotAxisGroupingTreeEh.Create(Self, TPivotAxisTreeNodeEh, padHorizontalEh);

  FBaseDrawCellParams := TPivotCellDrawParamsEh.Create;
  FDataValueDrawParams := TPivotCellDataValueDrawParamsEh.Create;
  FFieldNameDrawParams := TPivotCellFieldNameDrawParamsEh.Create;
  FAxisValueDrawParams := TPivotCellAxisValueDrawParamsEh.Create;

  FGridCellParams := CreateGridCellParams;
  FRowAxisOptions := TPivotGridRowAxisOptionsEh.Create(Self);
  FColumnAxisOptions := TPivotGridRowAxisOptionsEh.Create(Self);

  FLoadingModeCallCount := 0;
  FStartLoadingStatusRenderDuration := 300;
  FFinishLoadingStatusRenderDuration := 500;
  FShowingLoadingMode := False;

  FProgressPanel := TPivotProgressIndicatorPanelEh.Create(Self);
  FProgressPanel.Parent := Self;
  FDataBuildingProgressDelay := 1000;
  FShowDataBuildingProgress := True;

  {$IFDEF FPC}
  {$ELSE}
  FPrintService := TPivotGridPrintServiceEh.Create(Self);
  FPrintService.Grid := Self;
  FPrintService.Name := 'PrintService';
  FPrintService.SetSubComponent(True);
  {$ENDIF}
end;

destructor TCustomPivotGridEh.Destroy;
begin
  Destroying;
  PivotDataSource := nil;

  FreeAndNil(FDummyPivotField);
  FreeAndNil(FRowsAxisTree);
  FreeAndNil(FColsAxisTree);
  FreeAndNil(FBaseDrawCellParams);
  FreeAndNil(FDataValueDrawParams);
  FreeAndNil(FFieldNameDrawParams);
  FreeAndNil(FAxisValueDrawParams);
  FreeAndNil(FGridCellParams);
  FreeAndNil(FRowAxisOptions);
  FreeAndNil(FColumnAxisOptions);
  {$IFDEF FPC}
  {$ELSE}
  FreeAndNil(FPrintService);
  {$ENDIF}

  SetPivotGridArraySize(0, 0);

  inherited Destroy;
end;

procedure TCustomPivotGridEh.CreateWnd;
begin
  inherited CreateWnd;
  SetRowHeightsColumnWidths;
end;

function TCustomPivotGridEh.CreateHorzScrollBarPanelControl: TGridScrollBarPanelControlEh;
begin
  Result := TPivotGridScrollBarPanelControl.Create(Self, sbHorizontal);
end;

function TCustomPivotGridEh.CreateScrollBar(AKind: TScrollBarKind): TGridScrollBarEh;
begin
  if AKind = sbVertical
    then Result := inherited CreateScrollBar(AKind)
    else Result := TPivotGridScrollBarEh.Create(Self, AKind);
end;

procedure TCustomPivotGridEh.SetPivotDataSource(const Value: TPivotDataSourceEh);
begin
  if FPivotDataSource <> Value then
  begin
    if Assigned(FPivotDataSource) then
      FPivotDataSource.UnRegisterChanges(Self);
    FPivotDataSource := Value;
    if Assigned(FPivotDataSource) then
    begin
      FPivotDataSource.RegisterChanges(Self);
      FPivotDataSource.FreeNotification(Self);
    end;
    PivotDataSourceChanged;
  end;
end;

procedure TCustomPivotGridEh.PivotDataSourceChange(Sender: TObject);
begin
  PivotDataSourceChanged;
end;

procedure TCustomPivotGridEh.PivotFieldsChanged(Sender: TObject);
begin
  EmptyGridData;
  if Assigned(FOnGridDefinitionChanged) then
    FOnGridDefinitionChanged(Self);
end;

procedure TCustomPivotGridEh.PivotStructureChanged(Sender: TObject);
begin
  if Assigned(FOnGridDefinitionChanged) then
    FOnGridDefinitionChanged(Self);
end;

procedure TCustomPivotGridEh.PivotDataStartChanging(Sender: TObject);
begin
  
end;

function TCustomPivotGridEh.PivotDataChangeProgress(Sender: TObject;
  ElapsedTime: LongWord; Percent: Integer): Boolean;
var
  Msg: TMsg;
begin
  Result := False;

  if ShowDataBuildingProgress and
    (ElapsedTime >= LongWord(FDataBuildingProgressDelay)) then
  begin
    ShowProgressPanel(ElapsedTime, Percent);
    if PeekMessage(Msg, 0{TCustomPivotGridEh(Sender).Handle}, WM_KEYDOWN, WM_KEYDOWN, PM_NOREMOVE) then
      if Msg.wParam = VK_ESCAPE then
        Result := True;
  end;
end;

procedure TCustomPivotGridEh.PivotDataFinishChanging(Sender: TObject);
begin
  HideProgressPanel;
  FinishLoadingStatus;
end;

procedure TCustomPivotGridEh.PivotDataChangingCanceled(Sender: TObject);
begin
  EmptyGridData;
end;

procedure TCustomPivotGridEh.PivotDataChanged(Sender: TObject);
begin
  if DataSourceIsEmpty {or FGridIsEmptyStatus} then
    EmptyGridData
  else
    RebuildGrid;
end;

procedure TCustomPivotGridEh.PivotDataSourceChanged;
begin
end;

procedure TCustomPivotGridEh.SetPivotGridArraySize(AColCount, ARowCount: Integer);
var
  c,r: Integer;
  OldCC, OldRC: Integer;
begin
  if (Length(PivotGridArray) > 0) then
  begin
    OldRC := Length(PivotGridArray[0]);
    OldCC  := Length(PivotGridArray);
    if ARowCount > OldRC then
    begin
      for c := 0 to OldCC-1 do
      begin
        SetLength(PivotGridArray[c], ARowCount);
        for r := OldRC to ARowCount-1 do
          PivotGridArray[c, r] := TPivotCellEh.Create;
      end;
    end else if ARowCount < OldRC then
    begin
      for c := 0 to OldCC-1 do
      begin
        for r := ARowCount to OldRC-1 do
        begin
          PivotGridArray[c, r].Free;
          PivotGridArray[c, r] := nil;
        end;
        SetLength(PivotGridArray[c], ARowCount);
      end;
    end;
  end;

  if AColCount > Length(PivotGridArray) then
  begin
    OldCC  := Length(PivotGridArray);
    SetLength(PivotGridArray, AColCount);
    for c := OldCC to AColCount-1 do
    begin
      SetLength(PivotGridArray[c], ARowCount);
      for r := 0 to ARowCount-1 do
        PivotGridArray[c, r] := TPivotCellEh.Create;
    end;
  end else if AColCount < Length(PivotGridArray) then
  begin
    OldCC  := Length(PivotGridArray);
    for c := AColCount to OldCC-1 do
    begin
      for r := 0 to ARowCount-1 do
      begin
        PivotGridArray[c, r].Free;
        PivotGridArray[c, r] := nil;
      end;
    end;
    SetLength(PivotGridArray, AColCount);
  end;

  for c := 0 to AColCount-1 do
  begin
    for r := 0 to ARowCount-1 do
      PivotGridArray[c, r].Clear;
  end;
end;

procedure TCustomPivotGridEh.SetRowHeightsColumnWidths;
var
  i: Integer;
  w: Integer;
  RolTopLeftPos: TPoint;
begin
  if csLoading in ComponentState then Exit;

  RolTopLeftPos := Classes.Point(RolStartVisPosX, RolStartVisPosY);

  SetGridSizes(True);
  AdjustContraData;

  
  if (RowHeight = 0) and (RowLines = 0) then
    DefaultRowHeight := CalcDefaultRowHeight
  else
    DefaultRowHeight := GetCanvasFontOneLineHeight(Self, Canvas, Font) * RowLines + RowHeight;
  for i := 0 to FullRowCount-1 do
    InternalSetRowHeight(i, DefaultRowHeight);
  UpdateRowHeightsToFitRowsAxisCells();

  
  for i := 0 to FullColCount-1 do
  begin
    if (ActualRowFields <> nil) and
       (i < ActualRowFields.Count) and
       (ActualRowFields.Objects[i] <> nil) and
       (TPivotFieldEh(ActualRowFields.Objects[i]).DisplayWidth > 0)
    then
      InternalSetColWidth(i, TPivotFieldEh(ActualRowFields.Objects[i]).DisplayWidth)
    else if (ColsAxisTree <> nil) and
            (i >= FixedColCount) and
            (i - FixedColCount < ColsAxisTree.FlatListCount) then
    begin
      w := ColsAxisTree.FlatList[i - FixedColCount].RefBaseAxisTableRec.Value[ActualColFieldCount+1, dvvValueEh];
      if w > 0 then
        InternalSetColWidth(i, w)
      else
      InternalSetColWidth(i, DefaultColWidth);
    end else
      InternalSetColWidth(i, DefaultColWidth);
  end;

  SafeScrollDataTo(RolTopLeftPos.X, RolTopLeftPos.Y);
end;

procedure TCustomPivotGridEh.UpdateRowHeightsToFitRowsAxisCells;
var
  RowHeightsArr: array of Integer;

  function CellRectToContentRect(APivotCell: TPivotCellEh; const ACellRect: TRect): TRect;
  begin
    Result := ACellRect;
    Result.Left := Result.Left + 2;
    Result.Top := Result.Top + 2;
    Result.Bottom := Result.Bottom - 2;

    if (APivotCell.AxisValueDetails <> nil) and
       (APivotCell.AxisValueDetails.ShowGroupingSign = True)
    then
      Result.Left := Result.Left + Round(18 * ScaleFactor);
  end;

  function ContentRectToCellRect(APivotCell: TPivotCellEh; const AContentRect: TRect): TRect;
  begin
    Result := AContentRect;
    Result.Left := Result.Left - 2;
    Result.Top := Result.Top - 2;
    Result.Bottom := Result.Bottom + 2;

    if (APivotCell.AxisValueDetails <> nil) and
       (APivotCell.AxisValueDetails.ShowGroupingSign = True)
    then
      Result.Left := Result.Left - Round(18 * ScaleFactor);
  end;

  function GetSpreadCellSizeRect(ACol, ARow: Integer): TRect;
  var
    CMerging: TSpreadGridCellMergingEh;
    CI, RI: Integer;
  begin
    CMerging := CellMerges[ACol, ARow];
    if (CMerging.MasterMergeColOffset > 0) or (CMerging.MasterMergeRowOffset > 0) then
      raise Exception.Create('Can''t get Rect for merged slave cell');
    Result := Rect(0, 0, ColWidths[ACol], RowHeightsArr[ARow]);

    for CI := ACol + 1 to ACol + CMerging.MergeColCount - 1 do
      Result.Right := Result.Right + ColWidths[CI];
    for RI := ARow + 1 to ARow + CMerging.MergeRowCount - 1 do
      Result.Bottom := Result.Bottom + RowHeightsArr[RI];
  end;

  procedure SetNewRowsHeight(ACol, ARow: Integer; ACellMerging: TSpreadGridCellMergingEh; ANewCellHeight: Integer);
  var
    AddHeight: Integer;
    SpreadCellHeight: Integer;
    SpreadCellDeltaHeight: Integer;
    ri: Integer;
  begin
    if ACellMerging.MergeRowCount = 1 then
    begin
      RowHeightsArr[ARow] := ANewCellHeight;
    end else
    begin
      SpreadCellHeight := RectHeight(GetSpreadCellSizeRect(ACol, ARow));
      SpreadCellDeltaHeight := ANewCellHeight - SpreadCellHeight;
      AddHeight := SpreadCellDeltaHeight div ACellMerging.MergeRowCount;

      for ri := 0 to ACellMerging.MergeRowCount - 1 do
        RowHeightsArr[ARow + ri] := RowHeightsArr[ARow + ri] + AddHeight;
    end;
  end;

var
  ci: Integer;
  ri: Integer;
  PivotCell: TPivotCellEh;
  CMerging: TSpreadGridCellMergingEh;
  s: String;
  VCellRect: TRect;
  AContentRect: TRect;
  ANewCellRect: TRect;
  TextSize: TSize;
  NewRowHeight: Integer;
begin
  if (RowAxisOptions = nil) then Exit;
  if (RowAxisOptions.HeightAutoExpand = False) then Exit;

  
  SetLength(RowHeightsArr, FullRowCount);
  for ri := 0 to FullRowCount - 1 do
    RowHeightsArr[ri] := RowHeights[ri];

  for ci := FixedColCount - 1 downto 0 do
  begin
    for ri := FStartDataRow to FullRowCount - 1 do
    begin
      PivotCell := VisPivotGridArray[ci, ri];
      CMerging := CellMerges[ci, ri];
      s := PivotCell.GetDisplayText(Self, ci, ri);
      Canvas.Font := PivotCell.GetDisplayFont(Self, ci, ri);
      if (CMerging.MasterMergeColOffset = 0) and
         (CMerging.MasterMergeRowOffset = 0) and
         (PivotCell.ShowValue) and
         (s <> '') then
      begin
        VCellRect := GetSpreadCellSizeRect(ci, ri);
        AContentRect := CellRectToContentRect(PivotCell, VCellRect);
        MeasureTextEh(Canvas, RectWidth(AContentRect), s, True, TextSize);
        ANewCellRect := ContentRectToCellRect(PivotCell, Rect(0, 0, TextSize.cx, TextSize.cy));
        NewRowHeight := RectHeight(ANewCellRect);
        if RectHeight(VCellRect) < NewRowHeight then
          SetNewRowsHeight(ci, ri, CMerging, NewRowHeight);
      end;
    end;
  end;

  for ri := FStartDataRow to FullRowCount - 1 do
    InternalSetRowHeight(ri, RowHeightsArr[ri]);

  
  SetLength(RowHeightsArr, FStartDataRow);
  for ri := 0 to FStartDataRow - 1 do
    RowHeightsArr[ri] := RowHeights[ri];

  for ci := FStartDataCol to FullColCount - 1 do
  begin
    for ri := FStartDataRow - 1 downto 1 do
    begin
      PivotCell := VisPivotGridArray[ci, ri];
      CMerging := CellMerges[ci, ri];
      s := PivotCell.GetDisplayText(Self, ci, ri);
      Canvas.Font := PivotCell.GetDisplayFont(Self, ci, ri);
      if (CMerging.MasterMergeColOffset = 0) and
         (CMerging.MasterMergeRowOffset = 0) and
         (PivotCell.ShowValue) and
         (s <> '') then
      begin
        VCellRect := GetSpreadCellSizeRect(ci, ri);
        AContentRect := CellRectToContentRect(PivotCell, VCellRect);
        MeasureTextEh(Canvas, RectWidth(AContentRect), s, True, TextSize);
        ANewCellRect := ContentRectToCellRect(PivotCell, Rect(0, 0, TextSize.cx, TextSize.cy));
        NewRowHeight := RectHeight(ANewCellRect);
        if RectHeight(VCellRect) < NewRowHeight then
          SetNewRowsHeight(ci, ri, CMerging, NewRowHeight);
      end;
    end;
  end;

  for ri := 1 to FStartDataRow - 1 do
    InternalSetRowHeight(ri, RowHeightsArr[ri]);

end;

procedure TCustomPivotGridEh.SetRowsColsCaptionsExpandedState;
begin
  SetRowsCaptionsExpandedState;
  SetColsCaptionsExpandedState;
end;

procedure TCustomPivotGridEh.SetRowsCaptionsExpandedState;
var
  i: Integer;
  PivotCell: TPivotCellEh;
begin
  for i := 0 to ActualRowFieldCount-1 do
  begin
    PivotCell := PivotGridArray[i, FStartDataRow - 1];
    PivotCell.FieldNameForRowDetails.Expanded := RowsAxisTree.GetExpandedCounts(i+1) > 0;
  end;
end;

procedure TCustomPivotGridEh.SetColsCaptionsExpandedState;
var
  i: Integer;
begin
  for i := 0 to ActualColFieldCount-1 do
    FRowsCaptionExpandedState[i] := ColsAxisTree.GetExpandedCounts(i+1) > 0;
end;

function TCustomPivotGridEh.CalcDefaultRowHeight: Integer;
begin
  Result := GetCanvasFontOneLineHeight(Self, Canvas, Font) + 4;
end;

procedure TCustomPivotGridEh.RebuildGrid;
var
  ticks: LongWord;
  ColRowPos: TPoint;
  RolTopLeftPos: TPoint;
begin
  ticks := GetTickCountEh;

  RolTopLeftPos := Classes.Point(RolStartVisPosX, RolStartVisPosY);
  ColRowPos := Classes.Point(Col, Row);
  EmptyGridData;

  if (PivotDataSource = nil) or
     (PivotDataSource.BaseTable.Active = False) or
     (PivotDataSource.BaseTable.IsEmpty)
  then
    Exit;

  MakePivotGridArray;
  AggregateGridForColumns;
  MakeRowSortingTree;
  MakeColSortingTree;
  SetRowsColsCaptionsExpandedState;
  MakeVisPivotGridArray;

  if ColRowPos.X >= ColCount then ColRowPos.X := ColCount - 1;
  if ColRowPos.Y >= RowCount then ColRowPos.Y := RowCount - 1;
  if ColRowPos.X < FixedColCount then ColRowPos.X := FixedColCount;
  if ColRowPos.Y < FixedRowCount then ColRowPos.Y := FixedRowCount;
  FocusCell(ColRowPos.X, ColRowPos.Y, True);
  SafeScrollDataTo(RolTopLeftPos.X, RolTopLeftPos.Y);

  InvalidateGrid;

  PivotDataSource.LogTimeMetric('  RebuildGrid', GetTickCountEh-ticks);
end;

procedure TCustomPivotGridEh.GridOptionsChanged;
begin
  if csLoading in ComponentState then Exit;

  RebuildGrid;
end;

procedure TCustomPivotGridEh.MakeRowSortingTree;
begin
  RowsAxisTree.BuildTree;
  BindAxisTreeToPivotKeyValueStates(RowsAxisTree, RowsAxisTree.Root, ActualRowFields);
  RowsAxisTree.UpdateExpandedState;
  RowsAxisTree.SetGridArrayAxisNumbers;
  ResortRowSortingTree;
end;

procedure TCustomPivotGridEh.MakeColSortingTree;
begin
  ColsAxisTree.BuildTree;
  BindAxisTreeToBaseAxisRecs(ColsAxisTree, PivotDataSource.BaseColsTable, ActualColFieldCount);
  BindAxisTreeToPivotKeyValueStates(ColsAxisTree, ColsAxisTree.Root, ActualColFields);
  ColsAxisTree.UpdateExpandedState;
  ColsAxisTree.SetGridArrayAxisNumbers;

  ResortColSortingTree;
end;

procedure TCustomPivotGridEh.ResortRowSortingTree;
var
  i: Integer;
begin
  if FDataSortColNum >= 0 then
  begin
    RowsAxisTree.SortData(-1, FDataSortColNum, FDataSortSortOrder)
  end else if ActualRowFields.Objects[0] <> nil then
  begin
    for i := 0 to ActualRowFields.Count-1 do
      RowsAxisTree.SortData(i+1, i, TPivotFieldEh(ActualRowFields.Objects[i]).SortOrder);
  end;
  RowsAxisTree.SetAxisCellType;
  RowsAxisTree.BuildFlatList;
end;

procedure TCustomPivotGridEh.ResortColSortingTree;
begin
  ColsAxisTree.SetAxisCellType;
  ColsAxisTree.BuildFlatList;
end;

procedure TCustomPivotGridEh.BindAxisTreeToPivotKeyValueStates(
  AxisTree: TPivotAxisGroupingTreeEh; Node: TPivotAxisTreeNodeEh; AAxisFields: TStringList);
var
  NodesList: TObjectListEh;
  i: Integer;
begin
  if Node.Level >= AAxisFields.Count then Exit;

  NodesList := TObjectListEh.Create;
  for i := 0 to Node.Count-1 do
  begin
    BindAxisTreeToPivotKeyValueStates(AxisTree, Node.Items[i], AAxisFields);
    NodesList.Add(Node.Items[i]);
  end;
  if (AAxisFields.Count > 0) and (AAxisFields.Objects[Node.Level] <> nil) then
    BindNodesListToPivotKeyValueState(NodesList, TPivotFieldEh((AAxisFields.Objects[Node.Level])).KeyValueStates, Node.Level);
  NodesList.Free;
end;

procedure TCustomPivotGridEh.BindNodesListToPivotKeyValueState(
  NodesList: TObjectList; KeyValueStates: TPivotKeyValueStatesEh; Level: Integer);
var
  ni, si: Integer;
  nv, sv: Variant;
  cmp: TVariantRelationship;
begin
  if (NodesList.Count = 0) or (KeyValueStates.Count = 0) then Exit;

  ni := 0;
  si := 0;
  while (ni < NodesList.Count) and (si < KeyValueStates.Count) do
  begin
    nv := TPivotAxisTreeNodeEh(NodesList[ni]).KeyValue[Level];
    sv := KeyValueStates[si].KeyValue;
    cmp := DBVarCompareValue(nv, sv);
    if cmp = vrNotEqual then
      raise Exception.Create('TCustomPivotGridEh.BindNodesListToPivotKeyValueState() .. CompareResult = vrNotEqual')
    else if cmp = vrEqual then
    begin
      TPivotAxisTreeNodeEh(NodesList[ni]).FPivotKeyValueState := KeyValueStates[si];

      ni := ni + 1;
      si := si + 1;

    end else
      si := si + 1;
  end;
end;

procedure TCustomPivotGridEh.BindAxisTreeToBaseAxisRecs(
  AxisTree: TPivotAxisGroupingTreeEh; BaseAxisTable: TMemTableEh;
  AActualAxisFieldCount: Integer);
var
  AList: TObjectListEh;
  Node: TPivotAxisTreeNodeEh;
  BaseCompValue: TVariantDynArray;
  iTree: Integer;
  CompareResult: TVariantRelationship;

  procedure SetValue(Table: TMemTableEh; var Value: TVariantDynArray);
  var
    i: Integer;
  begin
    for i := 0 to AActualAxisFieldCount-1 do
      Value[i] := Table.Rec.Value[i, dvvValueEh];
  end;

begin
  AList := TObjectListEh.Create;
  AxisTree.ForAllNode(AddNodeToList, AList, False, True);


  AxisTree.BeginUpdate;
  BaseAxisTable.First;
  iTree := 0;

  if not BaseAxisTable.Eof and (AList.Count > 0) then
  begin
    SetLength(BaseCompValue, AActualAxisFieldCount);

    SetValue(BaseAxisTable, BaseCompValue);
    Node := TPivotAxisTreeNodeEh(AList[iTree]);

    while True do
    begin
      CompareResult :=  VarArrayForceCompareValue(BaseCompValue, Node.KeyValue);
      if CompareResult = vrNotEqual then
        raise Exception.Create('TPivotDataSourceEh.BindAxisTreeToBaseAxisRecs() .. CompareResult = vrNotEqual')
      else if CompareResult = vrEqual then
      begin
        Node.FRefBaseAxisTableRec := BaseAxisTable.Rec;
        Node.Expanded := BaseAxisTable.Rec.Value[AActualAxisFieldCount+1, dvvValueEh];

        BaseAxisTable.Next;
        iTree := iTree + 1;

        SetValue(BaseAxisTable, BaseCompValue);
        if iTree < AList.Count then
          Node := TPivotAxisTreeNodeEh(AList[iTree]);
      end else
      begin
        BaseAxisTable.Next;
        SetValue(BaseAxisTable, BaseCompValue);
      end;
      if BaseAxisTable.Eof or (iTree >= AList.Count) then Break;
    end;
  end;
  AxisTree.EndUpdate;

  AList.Free;
end;

procedure TCustomPivotGridEh.AddNodeToList(Sender: TBaseTreeNodeEh; Param: TObject);
begin
  TObjectList(Param).Add(Sender);
end;

procedure TCustomPivotGridEh.RowExpandedChanged(Node: TPivotAxisTreeNodeEh);
begin
  RowsAxisTree.SetAxisCellType;
  RowsAxisTree.BuildFlatList;
  MakeVisPivotGridArray;
  GridLayoutChanged;
  InvalidateGrid;
end;

procedure TCustomPivotGridEh.ColExpandedChanged(Node: TPivotAxisTreeNodeEh);
begin
  ColsAxisTree.SetAxisCellType;
  ColsAxisTree.BuildFlatList;
  MakeVisPivotGridArray;
  GridLayoutChanged;
  InvalidateGrid;
end;

procedure TCustomPivotGridEh.SetPivotGridArrayVars;
begin
  FStartDataCol := ActualRowFields.Count;
  if InRowsAxisValuesCount > 1 then
    FStartDataCol := FStartDataCol + 1;

  FStartDataRow := ActualColFields.Count + 1;
  if InColsAxisValuesCount > 1 then
    FStartDataRow := FStartDataRow + 1;

  FPivotArrayDataColCount := PivotDataSource.ColsTable.RecordCount * InColsAxisValuesCount;
  FPivotArrayDataRowCount := PivotDataSource.RowsTable.RecordCount * InRowsAxisValuesCount;

  FShowGrandTotalCols := (PivotDataSource.ColsTable.RecordCount > 2) and (pgoGrandTotalColumnEh in Options);
  FShowGrandTotalRows := (PivotDataSource.RowsTable.RecordCount > 2) and (pgoGrandTotalRowEh in Options);

  SetPivotGridArraySize(FPivotArrayDataColCount + FStartDataCol + ActualColFields.Count,
                        FPivotArrayDataRowCount + FStartDataRow);

  FDataSortColNum := -1;
end;

procedure TCustomPivotGridEh.BuildGridArrayColsMeasures;
var
  i, j, k: Integer;
  ip, v: Integer;
  PivotCel: TPivotCellEh;
  RestMVCell: TPivotCellEh;
  AxisKeyValue: Variant;
  AxisCurValue: Variant;
  AggrDeep: Integer;
  ArrayRow: Integer;
begin

  for k := 0 to ActualRowFields.Count-1 do
  begin
    for j := 0 to ActualColFields.Count-1 do
    begin
      PivotCel := PivotGridArray[k, j];
      PivotCel.CelType := sctEmptyEh;
      PivotCel.Value := '';
      PivotCel.DrawDownLine := True;
      PivotCel.DrawRightLine := True;
      PivotCel.VertAggrLevelRow := 0;
    end;
    PivotCel := PivotGridArray[k, FStartDataRow - 1];
    PivotCel.CelType := sctFieldNameForRowEh;
    PivotCel.FieldNameForRowDetails.PivotField := PivotFields.FindFieldByName(PivotDataSource.RowsTable.Fields[k].FieldName);
    if (PivotCel.FieldNameForRowDetails.PivotField <> nil) then
      PivotCel.Value := PivotDataSource.RowsTable.Fields[k].DisplayName;
    PivotCel.DrawDownLine := True;
    PivotCel.DrawRightLine := True;
    PivotCel.VertAggrLevelRow := ActualRowFields.Count-1-k;
    PivotCel.ShowValue := True;
    PivotCel.FieldNameForRowDetails.DrawFilterButton := (PivotCel.FieldNameForRowDetails.PivotField <> nil);
  end;

  AxisKeyValue := VarArrayCreate([0, ActualRowFields.Count-1], varVariant);
  AxisCurValue := VarArrayCreate([0, ActualRowFields.Count-1], varVariant);
  for k := 0 to ActualRowFields.Count-1 do
  begin
    AxisKeyValue[k] := Unassigned;
    AxisCurValue[k] := Unassigned;
  end;

  for i := 0 to PivotDataSource.RowsTable.RecordCount-1 do
  begin
    ip := i * InRowsAxisValuesCount;
    for k := 0 to ActualRowFields.Count-1 do
    begin
      ArrayRow := FStartDataRow + ip;
      PivotCel := PivotGridArray[k, ArrayRow];
      PivotCel.CelType := sctRowsAxisValueEh;
      PivotCel.VertAggrLevelRow := PivotDataSource.RowsTable.RecordsView[i].Value[ActualRowFields.Count, dvvValueEh];
      PivotCel.VertAggrLevelCol := ActualRowFields.Count - 1 - k;
      PivotCel.RowsAxisValueDetails.PivotField := TPivotFieldEh(ActualRowFields.Objects[k]);
      AxisCurValue[k] := PivotDataSource.RowsTable.RecordsView[i].Value[k, dvvValueEh];
      AggrDeep := PivotCel.VertAggrLevelRow;

      if VarArrayEqualLevelForDepth(AxisKeyValue, AxisCurValue, k+1) = k+1 then
      begin
        PivotCel.Value := PivotDataSource.RowsTable.RecordsView[i].Value[k, dvvValueEh];
        if (AggrDeep > 0) and (k = ActualRowFields.Count - AggrDeep - 1) then
          PivotCel.ShowValue := True
        else
        begin
          PivotCel.ShowValue := False;
        end;
        PivotCel.DrawDownLine := True;
        PivotGridArray[k, ip - 1 + FStartDataRow].DrawDownLine := False;
      end else
      begin
        if (PivotCel.RowsAxisValueDetails.PivotField = nil) then
          PivotCel.Value := ActualValueFields[0].DisplayDescription
        else
          PivotCel.Value := PivotDataSource.RowsTable.RecordsView[i].Value[k, dvvValueEh];
        PivotCel.ShowValue := True;
        if (k < ActualRowFields.Count-1) and (AggrDeep = 0) then
          PivotCel.RowsAxisValueDetails.ShowGroupingSign := True;
        PivotCel.DrawDownLine := True;
      end;

      if (AggrDeep > 0) and
         (k >= ActualRowFields.Count - AggrDeep - 1) and
         (k < ActualRowFields.Count-1) then
        PivotCel.DrawRightLine := False
      else
        PivotCel.DrawRightLine := True;

      
      for v := 0 to InRowsAxisValuesCount - 1 do
      begin
        RestMVCell := PivotGridArray[k, FStartDataRow + ip + v];
        if v > 0 then
        begin
          RestMVCell.CelType := sctRowsAxisValueEh;
          RestMVCell.RowsAxisValueDetails.PivotField := TPivotFieldEh(ActualRowFields.Objects[k]);
          RestMVCell.Value := PivotCel.Value;
          RestMVCell.DrawRightLine := PivotCel.DrawRightLine;
        end;
        if v < InRowsAxisValuesCount - 1 then
          RestMVCell.DrawDownLine := False;
      end;

    end;

    for v := 0 to InRowsAxisValuesCount - 1 do
    begin
      PivotCel := PivotGridArray[ActualRowFields.Count, ip + FStartDataRow + v];
      PivotCel.CelType := sctValCaptionInRowsAxisEh;
      PivotCel.Value := ActualValueFields[v].DisplayDescription;
    end;

    for k := 0 to ActualRowFields.Count-1 do
      AxisKeyValue[k] := PivotDataSource.RowsTable.RecordsView[i].Value[k, dvvValueEh];
  end;
end;

procedure TCustomPivotGridEh.BuildGridArrayRowsMeasures;
var
  i, k, ip, v: Integer;
  PivotCel: TPivotCellEh;
  RestMVCell: TPivotCellEh;
  AxisKeyValue: Variant;
  AxisCurValue: Variant;
  AggrDeep: Integer;
begin
  SetLength(FRowsCaptionExpandedState, ActualColFields.Count);
  for k := 0 to ActualColFields.Count-1 do
  begin
    PivotCel := PivotGridArray[k + FStartDataCol, 0];
    PivotCel.CelType := sctFieldNameForColEh;
    PivotCel.Value := PivotDataSource.ColsTable.Fields[k].DisplayName;
    PivotCel.ShowValue := PivotDataSource.ColumnFields.Count > 0;
    PivotCel.DrawDownLine := True;
    PivotCel.DrawRightLine := True;
    PivotCel.HorzAggrLevelCol := ActualColFields.Count-1-k;
    PivotCel.FieldNameForColDetails.PivotField := PivotFields.FindFieldByName(PivotDataSource.ColsTable.Fields[k].FieldName);
    PivotCel.FieldNameForColDetails.DrawFilterButton := (PivotCel.FieldNameForColDetails.PivotField <> nil);
    FRowsCaptionExpandedState[k] := True;
  end;

  AxisKeyValue := VarArrayCreate([0, ActualColFields.Count-1], varVariant);
  AxisCurValue := VarArrayCreate([0, ActualColFields.Count-1], varVariant);
  for k := 0 to ActualColFields.Count - 1 do
  begin
    AxisKeyValue[k] := Unassigned;
    AxisCurValue[k] := Unassigned;
  end;


  for i := 0 to PivotDataSource.ColsTable.RecordCount - 1 do
  begin
    ip := i * InColsAxisValuesCount;
    for k := 0 to ActualColFields.Count - 1 do
    begin
      PivotCel := PivotGridArray[ip + FStartDataCol, k + 1];
      PivotCel.CelType := sctColsAxisValueEh;
      PivotCel.HorzAggrLevelCol := PivotDataSource.ColsTable.RecordsView[i].Value[ActualColFields.Count, dvvValueEh];
      PivotCel.HorzAggrLevelRow := ActualColFields.Count - 1 - k;
      PivotCel.ColsAxisValueDetails.PivotField := TPivotFieldEh(ActualColFields.Objects[k]);
      AxisCurValue[k] := PivotDataSource.ColsTable.RecordsView[i].Value[k, dvvValueEh];
      AggrDeep := PivotDataSource.ColsTable.RecordsView[i].Value[ActualColFields.Count, dvvValueEh];

      if VarArrayEqualLevelForDepth(AxisKeyValue, AxisCurValue, k+1) = k+1 then
      begin
        PivotCel.Value := PivotDataSource.ColsTable.RecordsView[i].Value[k, dvvValueEh];
        PivotCel.ShowValue := True;
        PivotCel.DrawRightLine := True;
        PivotGridArray[ip + FStartDataCol - 1, k + 1].DrawRightLine := False;
      end else
      begin
        if (PivotCel.ColsAxisValueDetails.PivotField = nil) then
          PivotCel.Value := ActualValueFields[0].DisplayDescription
        else
          PivotCel.Value := PivotDataSource.ColsTable.RecordsView[i].Value[k, dvvValueEh];

        if (k < ActualColFields.Count-1) and (AggrDeep = 0) then
          PivotCel.ColsAxisValueDetails.ShowGroupingSign := True;
        PivotCel.ShowValue := True;
        PivotCel.DrawRightLine := True;
      end;

      PivotCel.DrawDownLine := True;

      
      for v := 0 to InColsAxisValuesCount - 1 do
      begin
        RestMVCell := PivotGridArray[ip + FStartDataCol + v, k + 1];
        if v > 0 then
        begin
          RestMVCell.CelType := sctColsAxisValueEh;
          RestMVCell.ColsAxisValueDetails.PivotField := TPivotFieldEh(ActualColFields.Objects[k]);
          RestMVCell.Value := PivotCel.Value;
          RestMVCell.DrawDownLine := PivotCel.DrawDownLine;
        end;
        if v < InColsAxisValuesCount - 1 then
          RestMVCell.DrawRightLine := False;
      end;

    end;

    for v := 0 to InColsAxisValuesCount - 1 do
    begin
      PivotCel := PivotGridArray[ip + FStartDataCol + v, ActualColFields.Count + 1];
      PivotCel.CelType := sctValCaptionInColsAxisEh;
      PivotCel.Value := ActualValueFields[v].DisplayDescription;
    end;

    for k := 0 to ActualColFields.Count-1 do
      AxisKeyValue[k] := PivotDataSource.ColsTable.RecordsView[i].Value[k, dvvValueEh];
  end;
end;

procedure TCustomPivotGridEh.BuildGridArrayValuesMeasures;
var
  ri, ci, k, v, cip, rip: Integer;
  ColKeyValue, RowKeyValue: TVariantDynArray;
  ResultColKeyValue, ResultRowKeyValue: TVariantDynArray;
  KeyLength: Integer;
  PivotCel: TPivotCellEh;
  vc, vr: Integer;

  procedure SetResultColKeyValue;
  var
    i: Integer;
    fNo: Integer;
  begin
    for i := 0 to ActualRowFields.Count-1 do
    begin
      fNo := PivotDataSource.ResultAggrTable.Rec.DataStruct.FieldIndex(ActualRowFields[i]);
      ResultColKeyValue[i] := PivotDataSource.ResultAggrTable.Rec.Value[fNo, dvvValueEh];
    end;
  end;

  procedure SetResultRowKeyValue;
  var
    i: Integer;
    fNo: Integer;
  begin
    for i := 0 to ActualColFields.Count-1 do
    begin
      fNo := PivotDataSource.ResultAggrTable.Rec.DataStruct.FieldIndex(ActualColFields[i]);
      ResultRowKeyValue[i] := PivotDataSource.ResultAggrTable.Rec.Value[fNo, dvvValueEh];
    end;
  end;

begin
  SetLength(ResultColKeyValue, ActualRowFields.Count);
  SetLength(ResultRowKeyValue, ActualColFields.Count);

  PivotDataSource.ResultAggrTable.First;
  if PivotDataSource.ResultAggrTable.Eof then Exit;
  SetResultColKeyValue;
  SetResultRowKeyValue;

  SetLength(ColKeyValue, ActualRowFields.Count);
  SetLength(RowKeyValue, ActualColFields.Count);
  KeyLength := ActualRowFields.Count + ActualColFields.Count;

  for ri := 0 to PivotDataSource.RowsTable.RecordCount-1 do
  begin
    for k := 0 to ActualRowFields.Count-1 do
      ColKeyValue[k] := PivotDataSource.RowsTable.RecordsView[ri].Value[k, dvvValueEh];

    for ci := 0 to PivotDataSource.ColsTable.RecordCount-1 do
    begin

      rip := ri * InRowsAxisValuesCount;
      cip := ci * InColsAxisValuesCount;

      for k := 0 to ActualColFields.Count-1 do
        RowKeyValue[k] := PivotDataSource.ColsTable.RecordsView[ci].Value[k, dvvValueEh];

      if VarArrayEqual(ResultColKeyValue, ColKeyValue) and
         VarArrayEqual(ResultRowKeyValue, RowKeyValue) then
      begin

        for v := 0 to ActualValueFields.Count - 1 do 
        begin

          if pgoMultiValuesInRowsAxisEh in Options then
          begin
            vc := 0;
            vr := v;
          end else
          begin
            vc := v;
            vr := 0;
          end;

          PivotCel := PivotGridArray[
                        cip + FStartDataCol + vc,
                        rip + FStartDataRow + vr];

          if PivotDataSource.ColsTable.RecordsView[ci].Value[ActualColFields.Count, dvvValueEh] <> 0 then
            PivotCel.CelType := sctHorzAggregateData
          else if PivotDataSource.RowsTable.RecordsView[ri].Value[ActualRowFields.Count, dvvValueEh] <> 0 then
            PivotCel.CelType := sctVertAggregateData
          else
            PivotCel.CelType := sctDataEh;

          PivotCel.Value := PivotDataSource.ResultAggrTable.Fields[KeyLength + v].Value;

          PivotCel.ShowValue := True;
          PivotCel.DrawDownLine := True;
          PivotCel.DrawRightLine := True;
        end;

        PivotDataSource.ResultAggrTable.Next;
        SetResultColKeyValue;
        SetResultRowKeyValue;
      end else
      begin
        
        for v := 0 to ActualValueFields.Count - 1 do 
        begin

          if pgoMultiValuesInRowsAxisEh in Options then
          begin
            vc := 0;
            vr := v;
          end else
          begin
            vc := v;
            vr := 0;
          end;

          PivotCel := PivotGridArray[
                       cip + FStartDataCol + vc,
                       rip + FStartDataRow + vr];

          if PivotDataSource.RowsTable.RecordsView[ri].Value[ActualRowFields.Count, dvvValueEh] <> 0 then
            PivotCel.CelType := sctVertAggregateData
          else if PivotDataSource.ColsTable.RecordsView[ci].Value[ActualColFields.Count, dvvValueEh] <> 0 then
            PivotCel.CelType := sctHorzAggregateData
          else
            PivotCel.CelType := sctDataEh;

          PivotCel.Value := Null;
          PivotCel.ShowValue := True;
          PivotCel.DrawDownLine := True;
          PivotCel.DrawRightLine := True;
        end;
      end;
    end;
  end;
end;

procedure TCustomPivotGridEh.MakePivotGridArray;
begin
  SetPivotGridArrayVars;
  BuildGridArrayColsMeasures;
  BuildGridArrayRowsMeasures;
  BuildGridArrayValuesMeasures;
end;

procedure TCustomPivotGridEh.AggregateGridForColumns;
var
  i: Integer;
  AggrLevel: Integer;
begin
  PivotDataSource.TransResultAggrTable.First;
  if PivotDataSource.TransResultAggrTable.Eof then Exit;
  if PivotDataSource.BaseTable.IsEmpty then Exit;

  for i := ActualColFields.Count downto 1 do
  begin
    AggrLevel := PivotDataSource.TransResultAggrTable['ForGridAggrLevel'];
    if AggrLevel <> i then
      raise Exception.Create('Algorithmic error: ' +
        'ForGridAggrLevel='+IntToStr(AggrLevel) +
        ': i='+IntToStr(i));
    AggregateGridForColumnsLevel(i);
  end;
end;

procedure TCustomPivotGridEh.AggregateGridForColumnsLevel(ColsLevel: Integer);
var
  i, j, k, v, ip, jp: Integer;
  ColKeyValue, RowKeyValue: TVariantDynArray;
  ResultColKeyValue, ResultRowKeyValue: TVariantDynArray;
  KeyLength: Integer;
  PivotCell: TPivotCellEh;
  vc, vr: Integer;

  procedure SetResultColKeyValue;
  var
    i: Integer;
    fNo: Integer;
  begin
    for i := 0 to ActualColFields.Count-1 do
    begin
      fNo := PivotDataSource.TransResultAggrTable.Rec.DataStruct.FieldIndex(ActualColFields[i]);
      ResultColKeyValue[i] := PivotDataSource.TransResultAggrTable.Rec.Value[fNo, dvvValueEh];
    end;
  end;

  procedure SetResultRowKeyValue;
  var
    i: Integer;
    fNo: Integer;
  begin
    for i := 0 to ActualRowFields.Count-1 do
    begin
      fNo := PivotDataSource.TransResultAggrTable.Rec.DataStruct.FieldIndex(ActualRowFields[i]);
      ResultRowKeyValue[i] := PivotDataSource.TransResultAggrTable.Rec.Value[fNo, dvvValueEh];
    end;
  end;

begin
  SetLength(ResultColKeyValue, ActualColFields.Count);
  SetLength(ResultRowKeyValue, ActualRowFields.Count);

  SetResultColKeyValue;
  SetResultRowKeyValue;

  SetLength(ColKeyValue, ActualColFields.Count);
  SetLength(RowKeyValue, ActualRowFields.Count);

  KeyLength := ActualRowFields.Count + ActualColFields.Count;

  for i := 0 to PivotDataSource.ColsTable.RecordCount-2 do
  begin
    for k := 0 to ActualColFields.Count-1 do
      ColKeyValue[k] := PivotDataSource.ColsTable.RecordsView[i].Value[k, dvvValueEh];

    ip := i * InColsAxisValuesCount;

    for j := 0 to PivotDataSource.RowsTable.RecordCount-1 do
    begin

      for k := 0 to ActualRowFields.Count-1 do
        RowKeyValue[k] := PivotDataSource.RowsTable.RecordsView[j].Value[k, dvvValueEh];

      jp := j * InRowsAxisValuesCount;

      if VarArrayEqual(ResultColKeyValue, ColKeyValue) and
         VarArrayEqual(ResultRowKeyValue, RowKeyValue)
      then
      begin

        for v := 0 to ActualValueFields.Count - 1 do 
        begin

          if pgoMultiValuesInRowsAxisEh in Options then
          begin
            vc := 0;
            vr := v;
          end else
          begin
            vc := v;
            vr := 0;
          end;

          PivotCell := PivotGridArray[
                       ip + FStartDataCol + vc,
                       jp + FStartDataRow + vr];

          if PivotDataSource.RowsTable.RecordsView[j].Value[ActualRowFields.Count, dvvValueEh] <> 0 then
            PivotCell.CelType := sctHorzAggregateData
          else if PivotDataSource.ColsTable.RecordsView[i].Value[ActualColFields.Count, dvvValueEh] <> 0 then
            PivotCell.CelType := sctVertAggregateData
          else
            PivotCell.CelType := sctDataEh;

          PivotCell.Value := PivotDataSource.TransResultAggrTable.Fields[KeyLength + v].Value;

          PivotCell.ShowValue := True;
          PivotCell.DrawDownLine := True;
          PivotCell.DrawRightLine := True;
        end;

        PivotDataSource.TransResultAggrTable.Next;

        SetResultColKeyValue;
        SetResultRowKeyValue;
      end else
      begin
        
      end;
    end;
  end;
end;

procedure TCustomPivotGridEh.MoveAggrRowBeforeData;
var
  j, k: Integer;
  ColAggrValue: TIntegerDynArray;
  AggrLevel: Integer;

  procedure MoveRowTo(FromRow, ToRow: Integer);
  var
    PivotRow: array of TPivotCellEh;
    i, j: Integer;
  begin
    SetLength(PivotRow, Length(PivotGridArray));
    for i := 0 to Length(PivotGridArray)-1 do
      PivotRow[i] := PivotGridArray[i, FromRow];

    for j := FromRow-1 downto ToRow do
      for i := 0 to Length(PivotGridArray)-1 do
        PivotGridArray[i, j+1] := PivotGridArray[i, j];

    for i := 0 to Length(PivotGridArray)-1 do
      PivotGridArray[i, ToRow] := PivotRow[i];
  end;

begin
  SetLength(ColAggrValue, ActualRowFields.Count);

  for k := 0 to ActualRowFields.Count-1 do
    ColAggrValue[k] := ActualColFields.Count+1;

  for j := ActualColFields.Count+1 to Length(PivotGridArray[0])-2 do
  begin
    AggrLevel := PivotGridArray[0,j].VertAggrLevelRow;
    if AggrLevel > 0 then
    begin
      PivotGridArray[ActualRowFields.Count-AggrLevel-1,j].DrawDownLine := False;
      PivotGridArray[ActualRowFields.Count-AggrLevel-1,j-1].DrawDownLine := True;
      PivotGridArray[ActualRowFields.Count-AggrLevel-1,ColAggrValue[AggrLevel]+AggrLevel-1].ShowValue := False;
      MoveRowTo(j, ColAggrValue[AggrLevel]);
      ColAggrValue[AggrLevel] := -1;
    end else
      for k := 0 to ActualRowFields.Count-1 do
        if ColAggrValue[k] = -1 then
          ColAggrValue[k] := j;
  end;
end;

procedure TCustomPivotGridEh.FillGridDataForActualRowFields;
var
  k: Integer;
  PivotCel: TPivotCellEh;
begin
  if (ActualColFields.Count = 0) or (ActualColFields.Objects[0] = FDummyPivotField) then
  begin
    PivotCel := PivotGridArray[1, 0];
    PivotCel.CelType := sctFieldNameForColEh;
  end else
  begin

    for k := 0 to ActualColFields.Count-1 do
    begin
      PivotCel := VisPivotGridArray[k + FStartDataCol, 0];
      PivotCel.CelType := sctFieldNameForColEh;
      PivotCel.Value := PivotDataSource.ColsTable.Fields[k].DisplayName;
      PivotCel.ShowValue := PivotDataSource.ColumnFields.Count > 0;
      PivotCel.DrawDownLine := True;
      PivotCel.DrawRightLine := True;
      PivotCel.HorzAggrLevelCol := ActualColFields.Count-1-k;
      PivotCel.FieldNameForColDetails.Expanded := FRowsCaptionExpandedState[k];
      PivotCel.FieldNameForColDetails.PivotField := PivotFields.FindFieldByName(PivotDataSource.ColsTable.Fields[k].FieldName);
      PivotCel.FieldNameForColDetails.DrawFilterButton := (PivotCel.FieldNameForColDetails.PivotField <> nil);
    end;

    for k := FStartDataCol + ActualColFields.Count to FVisPivotColCount - 1 do
    begin
      PivotCel := VisPivotGridArray[k, 0];
      PivotCel.Clear;
    end;
  end;
end;

procedure TCustomPivotGridEh.MakeVisPivotGridArray;
begin
  FVisPivotRowCount := RowsAxisTree.FlatListCount * InRowsAxisValuesCount + FStartDataRow + GrandTotalRowCount;
  FVisPivotColCount := ColsAxisTree.FlatListCount * InColsAxisValuesCount + FStartDataCol + GrandTotalColCount;

  if (ActualColFields <> nil) and
     (FVisPivotColCount - FStartDataCol < ActualColFields.Count)
  then
    FVisPivotColCountAffix := ActualColFields.Count - (FVisPivotColCount - FStartDataCol)
  else
    FVisPivotColCountAffix := 0;

  FFullVisPivotColCount := FVisPivotColCount + FVisPivotColCountAffix;

  FillGridDataForActualRowFields;
  SetRowHeightsColumnWidths;
end;

procedure TCustomPivotGridEh.SetColLevelExpanded(AColLevel: Integer;
  IsExpanded: Boolean; const KeyValues: TVariantDynArray);
begin
  RowsAxisTree.SetLevelExpanded(ActualRowFields.Count-AColLevel, IsExpanded);
end;

procedure TCustomPivotGridEh.SetRowLevelExpanded(ARowLevel: Integer;
  IsExpanded: Boolean; const KeyValues: TVariantDynArray);
begin
  FRowsCaptionExpandedState[ActualColFields.Count-ARowLevel-1] := IsExpanded;
  ColsAxisTree.SetLevelExpanded(ActualColFields.Count-ARowLevel, IsExpanded);
end;

procedure TCustomPivotGridEh.DrawSortMarker(var ARect: TRect;
  AState: TGridDrawState; SortOrder: TSortOrderEh);
var
  Style: TDBGridEhStyle;
  smSize: TSize;
  BaseRect, SMRect: TRect;
  FillColor: TColor;
  SortMarker: TSortMarkerEh;
begin
  Style := DBGridEhDefaultStyle;
  smSize := Style.GetSortMarkerSize(Canvas, smstSolidEh);
  SMRect := Rect(0, 0, smSize.cx, smSize.cy);
  BaseRect := Rect(ARect.Right - smSize.cx - 4, ARect.Top, ARect.Right, ARect.Bottom);
  SMRect := CenteredRect(BaseRect, SMRect);
  FillColor := ApproximateColor(FInternalFixedFontColor, FInternalFixedColor, 128);
  FillColor := ApproximateColor(FillColor, StyleServices.GetSystemColor(clSkyBlue), 128);
  if SortOrder = soAscEh
    then SortMarker := smUpEh
    else SortMarker := smDownEh;
  Style.DrawSortMarkerNew(Canvas, smstSolidEh, SortMarker, False, SMRect, clDefault, clDefault, FillColor);
  ARect.Right := BaseRect.Left;
end;

procedure TCustomPivotGridEh.FillFieldNameCellParams(
  ADrawCellParams: TPivotCellFieldNameDrawParamsEh; ACol, ARow: Integer; PivotCell: TPivotCellEh);
var
  dcp: TPivotCellFieldNameDrawParamsEh;
begin
  dcp := ADrawCellParams;
  FillBaseDrawCellParams(dcp, ACol, ARow, PivotCell);
end;

procedure TCustomPivotGridEh.DrawFieldNameCell(ADrawDataCellParams: TPivotCellFieldNameDrawParamsEh);
var
  p: TPivotCellFieldNameDrawParamsEh;
  TreeSignRect: TRect;
  TreeElement: TTreeElementEh;
  s: String;
  Al: TAlignment;
  IsDrawFilterButton: Boolean;
  ARect: TRect;
begin
  p := ADrawDataCellParams;
  ARect := p.DrawEvtArg.CellRect;

  IsDrawFilterButton := False;
  Canvas.Brush.Color := StyleServices.GetSystemColor(GridCellParams.ActualFieldNameColor);
  Canvas.Font := GridCellParams.FieldNameFont;
  Canvas.Font.Color := StyleServices.GetSystemColor(GridCellParams.FieldNameFont.Color);

  Canvas.FillRect(ARect);

  if (p.PivotCell.VertAggrLevelRow > 0) or
     (p.PivotCell.HorzAggrLevelCol > 0) then
  begin
    TreeSignRect := ARect;
    TreeSignRect.Right := TreeSignRect.Left + Round(18 * ScaleFactor);
    if p.PivotCell.FieldNameDetails.Expanded
      then TreeElement := tehMinus
      else TreeElement := tehPlus;
    DrawTreeElement(Canvas, TreeSignRect, TreeElement, False, ScaleFactor, ScaleFactor, False, True,
      tvgsClassicEh);
    ARect.Left := TreeSignRect.Right;
  end;

  if (p.PivotCell.CelType = sctFieldNameForColEh) then
    IsDrawFilterButton := p.PivotCell.FieldNameForColDetails.DrawFilterButton
  else if (p.PivotCell.CelType = sctFieldNameForRowEh) then
    IsDrawFilterButton := p.PivotCell.FieldNameForRowDetails.DrawFilterButton;

  if (IsDrawFilterButton = True) and
     (pgoDataFiltersEh in Options)
  then
    DrawFilterButton(ARect, p.DrawEvtArg.State, p.PivotCell.FieldNameDetails.PivotField.KeyValueStates.HaveHiddenKeys);

  if (p.PivotCell.CelType = sctFieldNameForRowEh) and
     (FDataSortColNum = -1) and
     (p.PivotCell.FieldNameDetails.PivotField <> nil) and
     (pgoDataSortingEh in Options)
  then
    DrawSortMarker(ARect, p.DrawEvtArg.State, p.PivotCell.FieldNameDetails.PivotField.SortOrder);

  if p.PivotCell.ShowValue = True then
    s := VarToStr(p.PivotCell.Value)
  else
    s := '';

  Al := taLeftJustify;
  if p.PivotCell.ShowValue then
    DrawText(Canvas, ARect, False, 2, 2, s, Al, tlTop, False, False, 0, 0,
      False, UseRightToLeftAlignment);
end;

procedure TCustomPivotGridEh.DrawAxisValueCellData(ACol, ARow: Integer; ARect: TRect;
  AState: TGridDrawState; PivotCel: TPivotCellEh;
  ShowGroupingSign, ShowValue: Boolean; const DisplayValue: String);
var
  s: String;
  TreeSignRect: TRect;
  TreeElement: TTreeElementEh;
  Al: TAlignment;
  ASrcCol, ASrcRow: Integer;
  IsWordWrap: Boolean;
  AutoWordWrap: Boolean;
begin
  Al := taLeftJustify;
  if UseRightToLeftAlignment then ChangeBiDiModeAlignment(Al);

  s := DisplayValue;
  if (s = '') and (ShowValue = True) then
  begin
    if (PivotCel.AxisValueDetails <> nil) and
       (PivotCel.AxisValueDetails.PivotField <> nil) then
      s := PivotCel.AxisValueDetails.PivotField.ValueAsDisplayText(PivotCel.Value)
    else
      s := VarToStr(PivotCel.Value);
  end;

  if ShowGroupingSign then
  begin
    TreeSignRect := ARect;
    TreeSignRect.Right := TreeSignRect.Left + Round(18 * ScaleFactor);
    TreeElement := tehMinus;
    if PivotCel.AxisValueDetails.AxisTreeNode <> nil then
    begin
      if PivotCel.AxisValueDetails.AxisTreeNode.Expanded
        then TreeElement := tehMinus
        else TreeElement := tehPlus;
    end;
    Canvas.Pen.Color := GridLineColors.GetDarkColor;
    Canvas.Brush.Color := GridCellParams.ActualAxisColor;
    DrawTreeElement(Canvas, TreeSignRect, TreeElement, False,
      ScaleFactor, ScaleFactor, False, False, tvgsClassicEh);
    ARect.Left := TreeSignRect.Right;
  end;

  VisPivotPosToSrcArrayPos(ACol, ARow, ASrcCol, ASrcRow);
  if {(PivotCel.ColsTreeNode <> nil) and}
     (ActualRowFields <> nil) and
     (ACol >= ActualRowFields.Count) and
     (FDataSortColNum = ASrcCol {PivotCel.ColsTreeNode.AxisPos + FStartDataCol}) and
     (ARow = FStartDataRow-1) then
  begin
    DrawSortMarker(ARect, AState, FDataSortSortOrder);
  end;

  if (PivotCel.CelType = sctRowsAxisValueEh)
    then AutoWordWrap := RowAxisOptions.AutoWordWrap
    else AutoWordWrap := ColumnAxisOptions.AutoWordWrap;


  if (AutoWordWrap = True) and (RectHeight(ARect) > DefaultRowHeight)
    then IsWordWrap := True
    else IsWordWrap := False;

  if ShowValue then
  begin
    DrawText(Canvas, ARect, False, 2, 2, s, Al, tlCenter, IsWordWrap, False, 0, 0,
      False, UseRightToLeftAlignment);
  end;
end;

procedure TCustomPivotGridEh.FillAxisValueCellParams(
  ADrawCellParams: TPivotCellAxisValueDrawParamsEh; ACol, ARow: Integer;
  PivotCell: TPivotCellEh);
var
  dcp: TPivotCellAxisValueDrawParamsEh;
begin
  dcp := ADrawCellParams;
  FillBaseDrawCellParams(dcp, ACol, ARow, PivotCell);

  ADrawCellParams.FillColor := GridCellParams.ActualAxisColor;

  ADrawCellParams.Font := PivotCell.GetDisplayFont(Self, ACol, ARow);
  ADrawCellParams.DisplayValue := PivotCell.GetDisplayText(Self, ACol, ARow);
end;

procedure TCustomPivotGridEh.DrawAxisValueCellBack(ACol, ARow: Integer;
  ARect: TRect; AState: TGridDrawState; PivotCel: TPivotCellEh);
var
  dcp: TPivotCellAxisValueDrawParamsEh;
begin
  dcp := FAxisValueDrawParams;
  dcp.FDrawEvtArg := nil;
  FillAxisValueCellParams(dcp, ACol, ARow, PivotCel);

  Canvas.Brush.Color := dcp.FillColor;

  Canvas.Font := dcp.Font;
  Canvas.Font.Color := StyleServices.GetSystemColor(Canvas.Font.Color);

  if (ARow = Row) or (ACol = Col) then
    Canvas.Brush.Color := ApproximateColor(GridCellParams.ActualAxisColor,
      StyleServices.GetSystemColor(clBtnShadow), 85);

  Canvas.FillRect(ARect);
end;

procedure TCustomPivotGridEh.DrawSpreadAxisValueCell(ADrawCellAxisValueParams: TPivotCellAxisValueDrawParamsEh);
var
  ShowGroupingSign, ShowValue: Boolean;
  p: TPivotCellAxisValueDrawParamsEh;
begin
  p := ADrawCellAxisValueParams;

  Canvas.Brush.Color := p.FillColor;
  Canvas.Font := p.Font;
  Canvas.Font.Color := StyleServices.GetSystemColor(Canvas.Font.Color);

  if (p.DrawEvtArg.ColIndex = Col) or (p.DrawEvtArg.RowIndex = Row) then
    Canvas.Brush.Color := ApproximateColor(GridCellParams.ActualAxisColor,
      StyleServices.GetSystemColor(clBtnShadow), 85);

  begin
    if p.PivotCell.AxisValueDetails <> nil
      then ShowGroupingSign := p.PivotCell.AxisValueDetails.ShowGroupingSign
      else ShowGroupingSign := False;
    ShowValue := True;
  end;

  DrawAxisValueCellData(p.DrawEvtArg.ColIndex, p.DrawEvtArg.RowIndex,
    p.DrawEvtArg.CellVisibleRect, p.DrawEvtArg.State,
    p.PivotCell, ShowGroupingSign, ShowValue, p.DisplayValue);
end;

procedure TCustomPivotGridEh.FillDrawCellParams(ADrawCellParams: TPivotCellDrawParamsEh;
  ACol, ARow: Integer; ARect: TRect; AState: TGridDrawState; PivotCell: TPivotCellEh);
begin
  FillBaseDrawCellParams(ADrawCellParams, ACol, ARow, PivotCell);
end;

procedure TCustomPivotGridEh.DrawCellSign(ACol, ARow: Integer; var ARect: TRect;
  ADrawDataCellParams: TPivotCellDataValueDrawParamsEh);
var
  SignRect: TRect;
  OldFillColor: TColor;
  OldPenColor: TColor;
begin
  if ADrawDataCellParams.SignType in [pcstRectangleEh, pcstCircleEh] then
  begin
    SignRect := ARect;
    ARect.Left := ARect.Left + (ARect.Bottom - ARect.Top) + 1;
    SignRect.Right := ARect.Left;
    if not IsDrawCellSelectionThemed(ACol, ARow, ACol, ARow, ADrawDataCellParams.DrawState) then
      Canvas.FillRect(SignRect);
    SignRect.Right := ARect.Left - 1;
    InflateRect(SignRect, -2, -2);
    OldFillColor := Canvas.Brush.Color;
    OldPenColor := Canvas.Pen.Color;
    Canvas.Brush.Color := ADrawDataCellParams.SignFillColor;
    Canvas.Pen.Color := ADrawDataCellParams.SignFrameColor;
    if ADrawDataCellParams.SignType = pcstRectangleEh
      then Canvas.FillRect(SignRect)
      else Canvas.Ellipse(SignRect.Left, SignRect.Top, SignRect.Right, SignRect.Bottom);
    Canvas.Brush.Color := OldFillColor;
    Canvas.Pen.Color := OldPenColor;
  end;
end;

function TCustomPivotGridEh.GetDrawCellParams(DrawEvtArg: TDrawSpreadCellArgsEh;
  PivotCell: TPivotCellEh): TPivotCellDrawParamsEh;
begin
  if PivotCell.CelType in [sctDataEh, sctHorzAggregateData, sctVertAggregateData] then
  begin
    FDataValueDrawParams.FDrawEvtArg := DrawEvtArg;
    FillDataCellParams(FDataValueDrawParams, DrawEvtArg.ColIndex, DrawEvtArg.RowIndex, PivotCell);
    Result := FDataValueDrawParams;
  end
  else if PivotCell.CelType in [sctRowsAxisValueEh, sctColsAxisValueEh,
                               sctValCaptionInColsAxisEh, sctValCaptionInRowsAxisEh] then
  begin
    FAxisValueDrawParams.FDrawEvtArg := DrawEvtArg;
    FillAxisValueCellParams(FAxisValueDrawParams, DrawEvtArg.ColIndex, DrawEvtArg.RowIndex, PivotCell);
    Result := FAxisValueDrawParams;
  end
  else if PivotCell.CelType in [sctFieldNameForRowEh, sctFieldNameForColEh] then
  begin
    FFieldNameDrawParams.FDrawEvtArg := DrawEvtArg;
    FillFieldNameCellParams(FFieldNameDrawParams, DrawEvtArg.ColIndex, DrawEvtArg.RowIndex, PivotCell);
    Result := FFieldNameDrawParams;
  end else
  begin
    FBaseDrawCellParams.FDrawEvtArg := DrawEvtArg;
    FillBaseDrawCellParams(FBaseDrawCellParams, DrawEvtArg.ColIndex, DrawEvtArg.RowIndex, PivotCell);
    Result := FBaseDrawCellParams;
  end;
end;

procedure TCustomPivotGridEh.DrawPivotCell(ACellDrawParams: TPivotCellDrawParamsEh);
begin
  if ACellDrawParams.PivotCell.CelType in [sctDataEh, sctHorzAggregateData, sctVertAggregateData] then
  begin
    DrawDataCell(ACellDrawParams as TPivotCellDataValueDrawParamsEh);
  end
  else if ACellDrawParams.PivotCell.CelType in [sctRowsAxisValueEh, sctColsAxisValueEh,
                                               sctValCaptionInColsAxisEh, sctValCaptionInRowsAxisEh] then
  begin
    DrawSpreadAxisValueCell(ACellDrawParams as TPivotCellAxisValueDrawParamsEh);
  end
  else if ACellDrawParams.PivotCell.CelType in [sctFieldNameForRowEh, sctFieldNameForColEh] then
  begin
    DrawFieldNameCell(ACellDrawParams as TPivotCellFieldNameDrawParamsEh);
  end else
  begin
    DrawEmptyCell(ACellDrawParams);
  end;
end;

procedure TCustomPivotGridEh.DrawEmptyCell(ACellDrawParams: TPivotCellDrawParamsEh);
begin
  Canvas.Brush.Color := ACellDrawParams.FillColor;
  Canvas.FillRect(ACellDrawParams.DrawEvtArg.CellRect);
end;

procedure TCustomPivotGridEh.FillBaseDrawCellParams(
  ADrawCellParams: TPivotCellDrawParamsEh; ACol, ARow: Integer; PivotCell: TPivotCellEh);
begin
  ADrawCellParams.FCol := ACol;
  ADrawCellParams.FRow := ARow;
  ADrawCellParams.FAreaCol := ACol;
  ADrawCellParams.FAreaRow := ARow;

  ADrawCellParams.FValue := PivotCell.Value;
  ADrawCellParams.FDisplayValue := PivotCell.GetDisplayText(Self, ACol, ARow);
  ADrawCellParams.Font := PivotCell.GetDisplayFont(Self, ACol, ARow);
  ADrawCellParams.FillColor := PivotCell.GetFillColor(Self, ACol, ARow);
  ADrawCellParams.FPivotCell := PivotCell;
end;

procedure TCustomPivotGridEh.FillDataCellParams(ADrawCellParams: TPivotCellDataValueDrawParamsEh;
  ACol, ARow: Integer; PivotCell: TPivotCellEh);

  function GetStrValue(SFValueInfo: TPivotFieldValueInfoEh; const Val: Variant): String;
  begin
    if VarIsNull(Val) then
      Result := ''
    else if (SFValueInfo.DisplayFormat <> '') then
      Result := FormatFloat(SFValueInfo.DisplayFormat, Val)
    else if SFValueInfo.SumFunction = svtCountEh then
      Result := FloatToStr(Val)
    else
      Result := FormatFloat('#,##0.00', Val)
  end;

  function GetDisplayValue: String;
  var
    ls: String;
  begin
    ls := '';
    if PivotCell.ShowValue then
    begin
      if not VarIsNull(PivotCell.Value) then
      begin
        if ActualValueFields.Count > 0 then
          Result := GetStrValue(ActualValueFields[0], PivotCell.Value)
        else
          Result := FormatFloat('#,##0.00', PivotCell.Value);
      end else
        Result := '';
    end else
      Result := '';
  end;

var
  AxisCell: TPivotCellEh;
  dcp: TPivotCellDataValueDrawParamsEh;
begin
  dcp := ADrawCellParams;
  FillBaseDrawCellParams(dcp, ACol, ARow, PivotCell);

  dcp.FAreaCol := ACol - FStartDataCol;
  dcp.FAreaRow := ARow - FStartDataRow;

  if (dcp.PivotCell.CelType in [sctHorzAggregateData, sctVertAggregateData])
     {and not (gdSelected in AState)}
  then
  begin
    dcp.FillColor := GridCellParams.ActualDataAggregateColor;
    dcp.Font := GridCellParams.DataAggregateFont;
    dcp.Font.Color := StyleServices.GetSystemColor(GridCellParams.DataAggregateFont.Color);
  end else
  begin
    dcp.Font := GridCellParams.DataFont;
  end;

  dcp.FValue := PivotCell.Value;
  dcp.DisplayValue := GetDisplayValue;

  AxisCell := VisPivotGridArray[0, ARow];
  ADrawCellParams.FRowsGroupLevel := AxisCell.VertAggrLevelRow;

  AxisCell := VisPivotGridArray[ACol, 1];
  ADrawCellParams.FColsGroupLevel := AxisCell.HorzAggrLevelCol;

  ADrawCellParams.FSignType := pcstNonEh;
  ADrawCellParams.FSignFillColor := clDefault;
  ADrawCellParams.FSignFrameColor := clDefault;
end;

procedure TCustomPivotGridEh.DrawDataCell(ADrawDataCellParams: TPivotCellDataValueDrawParamsEh);
var
  p: TPivotCellDataValueDrawParamsEh;
  AHighlightColor: TColor;
  s: String;
  IsCellFilled: Boolean;
  VCellRect: TRect;
  Al: TAlignment;
  Processed: Boolean;
begin
  Al := taRightJustify;
  p := ADrawDataCellParams;

  if Assigned(OnDrawDataCell) then
  begin
    Processed := False;
    OnDrawDataCell(Self, p.Col, p.Row, p, Processed);
    if Processed then Exit;
  end;

  Canvas.Brush.Color := p.FillColor;
  Canvas.Font := p.Font;

  if (gdSelected in p.DrawEvtArg.State) and
    (not (gdFocused in p.DrawEvtArg.State) or
    ([goDrawFocusSelectedEh, goRowSelectEh] * inherited Options <> [])) then
  begin
    if not IsDrawCellSelectionThemed(p.Col, p.Row, p.Col, p.Row, p.DrawEvtArg.State) then
    begin
      if gdCurrent in p.DrawEvtArg.State then
      begin
        Canvas.Brush.Color := StyleServices.GetSystemColor(clHighlight);
        Canvas.Font.Color := StyleServices.GetSystemColor(clHighlightText);
      end else
      begin
        if Focused
          then AHighlightColor := StyleServices.GetSystemColor(clHighlight)
          else AHighlightColor := ColorToGray(StyleServices.GetSystemColor(clHighlight));
        Canvas.Brush.Color := ApproximateColor(Canvas.Brush.Color, AHighlightColor, 256/3)
      end;
    end;
  end;

  s := p.DisplayValue;

  VCellRect := p.DrawEvtArg.CellRect;

  IsCellFilled := False;
  if IsDrawCellSelectionThemed(p.Col, p.Row, p.Col, p.Row, p.DrawEvtArg.State) then
  begin
    if not IsCellFilled then
    begin
      Canvas.FillRect(VCellRect);
      IsCellFilled := True;
    end;
    DrawCellDataBackground(p.Col, p.Row, VCellRect, p.DrawEvtArg.State);
  end;

  if p.SignType <> pcstNonEh then
    DrawCellSign(p.Col, p.Row, VCellRect, p);

  DrawText(Canvas, VCellRect, not IsCellFilled, 2, 2, s, Al, tlTop, False, False, 0, 0, False, UseRightToLeftAlignment);
end;

procedure TCustomPivotGridEh.DrawSpreadCell(EvtArg: TDrawSpreadCellArgsEh);
var
  PivotCell: TPivotCellEh;
  CellDrawParams: TPivotCellDrawParamsEh;
begin
  if (EvtArg.ColIndex < FFullVisPivotColCount) and (EvtArg.RowIndex < FVisPivotRowCount) then
  begin
    PivotCell := VisPivotGridArray[EvtArg.ColIndex, EvtArg.RowIndex];
    CellDrawParams := GetDrawCellParams(EvtArg, PivotCell);
    DrawPivotCell(CellDrawParams);
  end else
  begin
  end;
end;

procedure TCustomPivotGridEh.DrawBaseCell(ACol, ARow: Integer; ARect: TRect; State: TGridDrawState);
var
  PivotCel: TPivotCellEh;
begin
  if (ACol < FFullVisPivotColCount) and (ARow < FVisPivotRowCount) then
  begin
    PivotCel := VisPivotGridArray[ACol, ARow];

    if PivotCel.CelType in [sctFieldNameForRowEh, sctFieldNameForColEh] then
    begin
    end else if PivotCel.CelType in [sctDataEh, sctHorzAggregateData, sctVertAggregateData] then
    begin
    end
    else if PivotCel.CelType in [sctRowsAxisValueEh, sctColsAxisValueEh,
                                     sctValCaptionInColsAxisEh, sctValCaptionInRowsAxisEh] then
    begin
      DrawAxisValueCellBack(ACol, ARow, ARect, State, PivotCel);
    end else
    begin
    end;
  end else
  begin
  end;

end;

procedure TCustomPivotGridEh.CheckDrawCellBorder(ACol, ARow: Integer;
  BorderType: TGridCellBorderTypeEh; var IsDraw: Boolean;
  var BorderColor: TColor; var IsExtent: Boolean);
var
  PivotCel: TPivotCellEh;
begin
  inherited CheckDrawCellBorder(ACol, ARow, BorderType, IsDraw, BorderColor, IsExtent);

  if (FFullVisPivotColCount > ACol) and (FVisPivotRowCount > ARow) then
  begin
    PivotCel := VisPivotGridArray[ACol, ARow];

    if PivotCel.CelType in [sctDataEh, sctHorzAggregateData, sctVertAggregateData] then
    begin
      if (BorderType = cbtRightEh) then
      begin
        if (InColsAxisValuesCount > 1) and
           ((ACol - FStartDataCol) mod InColsAxisValuesCount < InColsAxisValuesCount - 1)
        then
          BorderColor := FInValuesCellGroupBorderColor;
      end
      else if (BorderType = cbtBottomEh) then
      begin
        if (InRowsAxisValuesCount > 1) and
           ((ARow - FStartDataRow) mod InRowsAxisValuesCount < InRowsAxisValuesCount - 1)
        then
          BorderColor := FInValuesCellGroupBorderColor;
      end;
    end
    else if PivotCel.CelType = sctValCaptionInRowsAxisEh then
    begin
      if (BorderType = cbtBottomEh) then
      begin
        if (InRowsAxisValuesCount > 1) and
           ((ARow - FStartDataRow) mod InRowsAxisValuesCount < InRowsAxisValuesCount - 1)
        then
          BorderColor := FInAxisValuesCellGroupBorderColor;
      end;
    end
    else if PivotCel.CelType = sctValCaptionInColsAxisEh then
    begin
      if (BorderType = cbtRightEh) then
      begin
        if (InColsAxisValuesCount > 1) and
           ((ACol - FStartDataCol) mod InColsAxisValuesCount < InColsAxisValuesCount - 1)
        then
          BorderColor := FInAxisValuesCellGroupBorderColor;
      end;
    end
    else if PivotCel.CelType = sctRowsAxisValueEh then
    begin
      if (BorderType = cbtRightEh) then
      begin
        if RowAxisOptions.TotalAtParentLevel
          then IsDraw := PivotCel.DrawRightLine
          else IsDraw := True;
      end else if BorderType = cbtBottomEh then
      begin
        if (RowAxisOptions.TotalsBeforeData) then
        begin
           if (RowAxisOptions.TotalAtParentLevel) and
              (PivotCel.RowsAxisValueDetails.AxisCellSubType = acstTotalFirstCellEh) and
              (PivotCel.RowsAxisValueDetails.AxisTreeNode <> nil) and
              (PivotCel.RowsAxisValueDetails.AxisTreeNode.Expanded)
           then
            IsDraw := False
          else
            IsDraw := True;
        end else
        begin
          IsDraw := PivotCel.DrawDownLine;
        end;
      end;
    end
    else if PivotCel.CelType = sctColsAxisValueEh then
    begin
      if BorderType = cbtRightEh then
      begin
        if (ColumnAxisOptions.TotalsBeforeData) then
        begin
           if (ColumnAxisOptions.TotalAtParentLevel) and
              (PivotCel.ColsAxisValueDetails.AxisCellSubType = acstTotalFirstCellEh) and
              (PivotCel.ColsAxisValueDetails.AxisTreeNode <> nil) and
              (PivotCel.ColsAxisValueDetails.AxisTreeNode.Expanded)
           then
            IsDraw := False
          else
            IsDraw := True;
        end else
        begin
          IsDraw := PivotCel.DrawRightLine;
        end;
      end else if BorderType = cbtBottomEh then
      begin
        if ColumnAxisOptions.TotalAtParentLevel
          then IsDraw := PivotCel.DrawDownLine
          else IsDraw := True;
      end;
    end;
  end;
end;

function TCustomPivotGridEh.IsSmoothHorzScroll: Boolean;
begin
  Result := True;
end;

function TCustomPivotGridEh.IsSmoothVertScroll: Boolean;
begin
  Result := True;
end;

procedure TCustomPivotGridEh.WMHScroll(var Message: TWMHScroll);
begin
  if Message.ScrollCode = SB_THUMBTRACK then
    Perform(Message.Msg, MakeLong(SB_THUMBPOSITION, Word(Message.Pos)), Message.ScrollBar)
  else
    inherited;
end;

procedure TCustomPivotGridEh.WMVScroll(var Message: TWMVScroll);
begin
  if Message.ScrollCode = SB_THUMBTRACK then
    Perform(Message.Msg, MakeLong(SB_THUMBPOSITION, Word(Message.Pos)), Message.ScrollBar)
  else
    inherited;
end;

procedure TCustomPivotGridEh.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
end;

procedure TCustomPivotGridEh.WMCancelMode(var Message: TMessage);
begin
  inherited;
end;

function TCustomPivotGridEh.WMCheckCanSendDoubleClicks(
  var MouseEvent: TWMMouse): Boolean;
begin
  Result := False;
end;

procedure TCustomPivotGridEh.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
end;

function TCustomPivotGridEh.NeedBufferedPaint: Boolean;
begin
  Result := True;
end;

procedure TCustomPivotGridEh.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if AComponent = PivotDataSource then
    PivotDataSource := nil;
end;

procedure TCustomPivotGridEh.WMEraseBackground(var Message: TWmEraseBkgnd);
begin
  Message.Result := 1;
end;

function TCustomPivotGridEh.GetCellHitArea(PivotCel: TPivotCellEh;
  const ACellRect: TRect; CellMousePos: TPoint): TCellAreaEh;
var
  SpecRect: TRect;
  RestRect: TRect;
  FilterButtonRect, FilterButtonGrossRect: TRect;
  IsDrawFilterButton: Boolean;
begin
  Result := caUnspecifiedEh;
  if (PivotCel.CelType in [sctFieldNameForRowEh, sctFieldNameForColEh]) then
  begin
    RestRect := ACellRect;
    OffsetRect(RestRect, -RestRect.Left, -RestRect.Top);

    if (PivotCel.VertAggrLevelRow > 0) or (PivotCel.HorzAggrLevelCol > 0) then
    begin
      SpecRect := RestRect;
      if UseRightToLeftAlignment
        then SpecRect.Left := SpecRect.Right - Round(18 * ScaleFactor)
        else SpecRect.Right := SpecRect.Left + Round(18 * ScaleFactor);
      if PtInRect(SpecRect, CellMousePos) then
      begin
        Result := caTreeExpandSignEh;
        Exit;
      end;
      if UseRightToLeftAlignment
        then RestRect.Right := SpecRect.Left
        else RestRect.Left := SpecRect.Right;
    end;

    if (PivotCel.CelType = sctFieldNameForColEh) then
      IsDrawFilterButton := PivotCel.FieldNameForColDetails.DrawFilterButton
    else
      IsDrawFilterButton := PivotCel.FieldNameForRowDetails.DrawFilterButton;

    if IsDrawFilterButton then
    begin
      GetFilterButtonRect(RestRect, FilterButtonRect, FilterButtonGrossRect, UseRightToLeftAlignment);
      if PtInRect(FilterButtonGrossRect, CellMousePos) then
      begin
        Result := caDropDownButtonEh;
        Exit;
      end;
    end;
  end;
end;

procedure TCustomPivotGridEh.StartDrag;
begin
  FDragStarted := True;
  BeginDrag(True);
end;

procedure TCustomPivotGridEh.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  if MouseCapture then
    if (FDragCell <> nil) and
       (FGridState = gsNormalEh) and
       ((FMouseDownPos.X <> X) or (FMouseDownPos.Y <> Y))
    then
      StartDrag;
end;

procedure TCustomPivotGridEh.GetVisPivotGridArrayPosByAxisCell(PivotCel: TPivotCellEh; var VisCellCoord: TPoint);
var
  i, j: Integer;
begin
  VisCellCoord.X := -1;
  VisCellCoord.Y := -1;
  for i := 0 to FullColCount-1 do
  begin
    for j := 0 to FullRowCount-1 do
    begin
      if VisPivotGridArray[i, j] = PivotCel then
      begin
        VisCellCoord.X := i;
        VisCellCoord.Y := j;
        Exit;
      end;
    end;
  end;
end;

procedure TCustomPivotGridEh.GetVisPivotGridArrayPosByAxisTreeNode(RowsTreeNode: TPivotAxisTreeNodeEh; var VisCellCoord: TPoint);
var
  i, j: Integer;
  PivotCell: TPivotCellEh;
begin
  VisCellCoord.X := -1;
  VisCellCoord.Y := -1;
  for i := 0 to FullColCount-1 do
  begin
    for j := 0 to FullRowCount-1 do
    begin
      PivotCell := VisPivotGridArray[i, j];
      if (PivotCell.AxisValueDetails <> nil) and
         (PivotCell.AxisValueDetails.AxisTreeNode = RowsTreeNode) then
      begin
        VisCellCoord.X := i;
        VisCellCoord.Y := j;
        Exit;
      end;
    end;
  end;
end;

procedure TCustomPivotGridEh.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FMouseDownPos := Point(X, Y);
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TCustomPivotGridEh.SetAxisRowExpandedState(PivotCel: TPivotCellEh; Expanded: Boolean);
begin
  if PivotCel.AxisValueDetails.AxisTreeNode.PivotKeyValueState <> nil then
  begin
    PivotCel.AxisValueDetails.AxisTreeNode.PivotKeyValueState.Expanded := Expanded;
    RowsAxisTree.UpdateExpandedState;
    RowExpandedChanged(nil);
  end;
end;

procedure TCustomPivotGridEh.SetAxisColExpandedState(PivotCel: TPivotCellEh; Expanded: Boolean);
begin
  if PivotCel.AxisValueDetails.AxisTreeNode.PivotKeyValueState <> nil then
  begin
    PivotCel.AxisValueDetails.AxisTreeNode.PivotKeyValueState.Expanded := Expanded;
    ColsAxisTree.UpdateExpandedState;
    ColExpandedChanged(nil);
  end;
end;

procedure TCustomPivotGridEh.CellMouseDown(const Cell: TGridCoord;
  Button: TMouseButton; Shift: TShiftState; const ACellRect: TRect;
  const GridMousePos, CellMousePos: TPoint);
var
  PivotCel: TPivotCellEh;
  StateRect: TRect;
  GroupingSignRect: TRect;
 begin
  FDragStarted := False;
  FDragCell := nil;
  inherited CellMouseDown(Cell, Button, Shift, ACellRect, GridMousePos, CellMousePos);
  if (Cell.X < 0) or (Cell.Y < 0) then Exit;
  if Sizing(GridMousePos.X, GridMousePos.Y) then Exit;

  GroupingSignRect := ACellRect;
  if UseRightToLeftAlignment
    then GroupingSignRect.Left := GroupingSignRect.Right - Round(18 * ScaleFactor)
    else GroupingSignRect.Right := GroupingSignRect.Left + Round(18 * ScaleFactor);
  if (FVisPivotColCount > Cell.X) and (FVisPivotRowCount > Cell.Y) then
  begin
    PivotCel := VisPivotGridArray[Cell.X, Cell.Y];
    if GetMouseHitCellState(Cell, GridMousePos, ACellRect, StateRect) = dgsFilterButtonDown then
    begin
        if FInTitleFilterListboxVisible
          then FilterFormCloseUp(False)
          else FilterFormDropDown(Cell, ACellRect, StateRect);
    end
    else if (PivotCel.CelType in [sctFieldNameForRowEh, sctFieldNameForColEh]) and
            ((PivotCel.VertAggrLevelRow > 0) or (PivotCel.HorzAggrLevelCol > 0)) and
            PtInRect(GroupingSignRect, GridMousePos)
    then
    begin
      VisPivotGridArray[Cell.X, Cell.Y].FieldNameDetails.Expanded := not PivotCel.FieldNameDetails.Expanded;
      if PivotCel.VertAggrLevelRow > 0
        then SetColLevelExpanded(PivotCel.VertAggrLevelRow, PivotCel.FieldNameDetails.Expanded, nil)
        else SetRowLevelExpanded(PivotCel.HorzAggrLevelCol, PivotCel.FieldNameDetails.Expanded, nil);
      Invalidate;
    end
    else if (PivotCel.CelType in [sctFieldNameForRowEh, sctFieldNameForColEh]) then
    begin
      if PivotCel.FieldNameDetails.PivotField <> nil then
      begin
        FDragCell := PivotCel;
        if PivotCel.CelType = sctFieldNameForRowEh
          then FDragPos := ActualRowFields.IndexOf(PivotCel.FieldNameDetails.PivotField.FieldName)
          else FDragPos := ActualColFields.IndexOf(PivotCel.FieldNameDetails.PivotField.FieldName);
      end;
    end else if (PivotCel.CelType in [sctRowsAxisValueEh, sctColsAxisValueEh]) and
           (PivotCel.AxisValueDetails.ShowGroupingSign = True) and
           PtInRect(GroupingSignRect, GridMousePos) then
    begin
    end;
  end;
end;

procedure TCustomPivotGridEh.SpreadCellMouseDown(const Cell: TGridCoord;
  Button: TMouseButton; Shift: TShiftState; const ACellRect: TRect;
  const GridMousePos, CellMousePos: TPoint);
var
  PivotCel: TPivotCellEh;
  GroupingSignRect: TRect;
begin
  GroupingSignRect := ACellRect;
  if UseRightToLeftAlignment
    then GroupingSignRect.Left := GroupingSignRect.Right - Round(18 * ScaleFactor)
    else GroupingSignRect.Right := GroupingSignRect.Left + Round(18 * ScaleFactor);

   if (FVisPivotColCount > Cell.X) and (FVisPivotRowCount > Cell.Y) then
  begin
    PivotCel := VisPivotGridArray[Cell.X, Cell.Y];
    if (PivotCel.CelType in [sctRowsAxisValueEh, sctColsAxisValueEh]) and
           (PivotCel.AxisValueDetails.ShowGroupingSign = True) and
           PtInRect(GroupingSignRect, GridMousePos) then
    begin
      if Cell.X < ActualRowFields.Count then
        SetAxisRowExpandedState(PivotCel, not PivotCel.AxisValueDetails.AxisTreeNode.Expanded)
      else
        SetAxisColExpandedState(PivotCel, not PivotCel.AxisValueDetails.AxisTreeNode.Expanded);
      Invalidate;
    end;
  end;
end;

procedure TCustomPivotGridEh.CellMouseClick(const Cell: TGridCoord;
  Button: TMouseButton; Shift: TShiftState; const ACellRect: TRect;
  const GridMousePos, CellMousePos: TPoint);
var
  PivotCel: TPivotCellEh;
  CellArea: TCellAreaEh;
  ActualGridArrayIndex: Integer;
  ActualGridArrayRowIndex: Integer;
begin
  inherited CellMouseClick(Cell, Button, Shift, ACellRect, GridMousePos, CellMousePos);
  if ssDouble in Shift then Exit;
  if GridIsEmpty then Exit;

  PivotCel := VisPivotGridArray[Cell.X, Cell.Y];
  if not FDragStarted and
     (Button = mbLeft) and
     (pgoDataSortingEh in Options) then
  begin
    if (PivotCel.CelType in [sctFieldNameForRowEh, sctFieldNameForColEh]) and
       (PivotCel.FieldNameDetails.PivotField <> nil) then
    begin
      CellArea := GetCellHitArea(PivotCel, ACellRect, CellMousePos);
      if CellArea = caUnspecifiedEh then
      begin
        FDataSortColNum := -1;
        PivotCel.FieldNameDetails.PivotField.SetNextSortOrder;
        ResortRowSortingTree;
        MakeVisPivotGridArray;
        InvalidateGrid;
      end;
    end else if Cell.Y = FStartDataRow-1 then
    begin
      VisPivotPosToSrcArrayPos(Cell.X, Cell.Y, ActualGridArrayIndex, ActualGridArrayRowIndex);
      if FDataSortColNum = ActualGridArrayIndex  then
      begin
        if FDataSortSortOrder = soAscEh
          then FDataSortSortOrder := soDescEh
          else FDataSortSortOrder := soAscEh;
      end else
      begin
        FDataSortColNum := ActualGridArrayIndex;
        FDataSortSortOrder := soDescEh;
      end;

      ResortRowSortingTree;
      MakeVisPivotGridArray;
      InvalidateGrid;
    end;
  end;
end;

procedure TCustomPivotGridEh.DoStartDrag(var DragObject: TDragObject);
begin
  inherited DoStartDrag(DragObject);
  DragObject := TPivotGridDrabObj.Create(Self);
  TPivotGridDrabObj(DragObject).FDragCell := FDragCell;
end;

procedure TCustomPivotGridEh.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  Cell: TGridCoord;
  SizeLinePos: TPoint;
  LineSize: Integer;
  ScreenPos: TPoint;
begin
  inherited DragOver(Source, X, Y, State, Accept);

  Accept := False;
  Cell := CalcCoordFromPoint(X, Y);
  if (Cell.X >= 0) and (Cell.Y >= 0) then
  begin
    if DragDropHitTestInfo(X, Y, SizeLinePos, LineSize, FDropToPos, FDropToCell) then
    begin
      Accept := True;
      ScreenPos := ClientToScreen(SizeLinePos);

      if GetMoveLineEh.Visible
        then GetMoveLineEh.MoveToFor(ScreenPos)
        else GetMoveLineEh.StartShow(ScreenPos, True, LineSize, Self);
    end else
      GetMoveLineEh.Hide;
  end
  else if State = dsDragLeave then
    GetMoveLineEh.Hide;
end;

function TCustomPivotGridEh.DragDropHitTestInfo(X, Y: Integer;
  var LinePos: TPoint; var LineSize, DropToPos: Integer;
  var FDragToField: TPivotCellEh): Boolean;
var
  PivotCel: TPivotCellEh;
  ARect: TRect;
  CellMousePos: TPoint;
  OverCell, TargetCell: TGridCoord;
  AxisStringList: TStringList;
begin
  OverCell := MouseCoord(X, Y);
  Result := False;
  if (OverCell.X >= 0) and (OverCell.Y >= 0) then
  begin
    PivotCel := nil;

    if (OverCell.Y = 0) and (OverCell.X >= FixedColCount + ActualColFieldCount) then
    begin
      TargetCell := GridCoord(FixedColCount + ActualColFieldCount - 1, OverCell.Y);
      ARect := CellRect(TargetCell.X, TargetCell.Y);
      CellMousePos := Point(X - ARect.Left, Y - ARect.Top);
      if (TargetCell.X >= 0) and (TargetCell.Y >= 0) then
        PivotCel := VisPivotGridArray[TargetCell.X, TargetCell.Y];
    end else if (OverCell.Y = 0) and (OverCell.X < ActualRowFields.Count) then
    begin
      TargetCell := GridCoord(ActualRowFields.Count, OverCell.Y);
      ARect := CellRect(TargetCell.X, TargetCell.Y);
      CellMousePos := Point(X - ARect.Left, Y - ARect.Top);
      PivotCel := VisPivotGridArray[TargetCell.X, TargetCell.Y];
    end else
    if (OverCell.Y = ActualColFieldCount) and (OverCell.X >= ActualRowFieldCount) then
    begin
      TargetCell := GridCoord(ActualRowFields.Count - 1, OverCell.Y);
      ARect := CellRect(TargetCell.X, TargetCell.Y);
      CellMousePos := Point(X - ARect.Left, Y - ARect.Top);
      PivotCel := VisPivotGridArray[TargetCell.X, TargetCell.Y];
    end else if (OverCell.Y = 0) and (OverCell.X < 0) then
    begin
      TargetCell := GridCoord(0, OverCell.Y);
      ARect := CellRect(TargetCell.X, TargetCell.Y);
      CellMousePos := Point(X - ARect.Left, Y - ARect.Top);
      PivotCel := VisPivotGridArray[TargetCell.X, TargetCell.Y];
    end else
    begin
      TargetCell := OverCell;
      ARect := CellRect(TargetCell.X, TargetCell.Y);
      CellMousePos := Point(X - ARect.Left, Y - ARect.Top);
      PivotCel := VisPivotGridArray[TargetCell.X, TargetCell.Y];
    end;

    if (PivotCel <> nil) and
       (PivotCel.CelType in [sctFieldNameForRowEh, sctFieldNameForColEh]) then
    begin
      AxisStringList := nil;
      if FDragCell <> nil then
        if FDragCell.CelType = sctFieldNameForRowEh
          then AxisStringList := ActualRowFields
          else AxisStringList := ActualColFields;

      if (AxisStringList <> nil) and (AxisStringList.Count = 0)
        then Result := False
        else Result := True;

      if not Result then Exit;

      LinePos.Y := ARect.Top;
      if CellMousePos.X > (ARect.Right - ARect.Left) div 2
        then LinePos.X := ARect.Right
        else LinePos.X := ARect.Left;

      LineSize := ARect.Bottom-ARect.Top;
      FDragToField := PivotCel;
      if TargetCell.X < FixedColCount then
      begin
        if (LinePos.X = ARect.Left) or (PivotDataSource.RowFields.Count = 0)
          then DropToPos := TargetCell.X
          else DropToPos := TargetCell.X + 1;
      end else
      begin
        if (LinePos.X = ARect.Left) or (PivotDataSource.ColumnFields.Count = 0)
          then DropToPos := TargetCell.X - FixedColCount
          else DropToPos := TargetCell.X + 1 - FixedColCount;
      end;
    end;

  end;
end;

procedure TCustomPivotGridEh.DragDrop(Source: TObject; X, Y: Integer);
var
  SizeLinePos: TPoint;
  LineSize: Integer;
  AxisStringList: TStringList;
  AFPivotField: TPivotFieldEh;
  APivotField: TPivotFieldEh;
begin
  inherited DragDrop(Source, X, Y);

  DragDropHitTestInfo(X, Y, SizeLinePos, LineSize, FDropToPos, FDropToCell);

  if (Source is TPivotGridDrabObj) and (TPivotGridDrabObj(Source).FPivotField <> nil) then
  begin
    AFPivotField := TPivotGridDrabObj(Source).FPivotField;
    if FDropToCell.CelType = sctFieldNameForRowEh
      then AxisStringList := PivotDataSource.RowFields
      else AxisStringList := PivotDataSource.ColumnFields;
    if AxisStringList.IndexOfObject(AFPivotField) >= 0 then
      Exit;
    AxisStringList.InsertObject(FDropToPos, AFPivotField.FieldName, AFPivotField);

    StartWait;
    GetMoveLineEh.Hide;
    PivotDataSource.BuildGridData;
    StopWait;

  end else if FDragCell <> FDropToCell then
  begin
    if FDragCell.CelType = FDropToCell.CelType then
    begin
      if FDragCell.CelType = sctFieldNameForRowEh
        then AxisStringList := PivotDataSource.RowFields
        else AxisStringList := PivotDataSource.ColumnFields;

      if FDropToPos < FDragPos then
        AxisStringList.Move(FDragPos, FDropToPos)
      else if FDropToPos > FDragPos then
        AxisStringList.Move(FDragPos, FDropToPos-1);
    end else
    begin
      APivotField := FDragCell.FieldNameDetails.PivotField;
      if FDragCell.CelType = sctFieldNameForRowEh then
      begin
        PivotDataSource.RowFields.Delete(PivotDataSource.RowFields.IndexOf(APivotField.FieldName));
        PivotDataSource.ColumnFields.InsertObject(FDropToPos, APivotField.FieldName, APivotField);
      end else
      begin
        PivotDataSource.ColumnFields.Delete(PivotDataSource.ColumnFields.IndexOf(APivotField.FieldName));
        PivotDataSource.RowFields.InsertObject(FDropToPos, APivotField.FieldName, APivotField);
      end;
    end;

    StartWait;
    GetMoveLineEh.Hide;
    PivotDataSource.BuildGridData;
    StopWait;

  end;
end;

procedure TCustomPivotGridEh.DoCopyAction;
var
  Sb: TStringStream;
  i, j: Integer;
  PivotCel: TPivotCellEh;
begin
  Sb := TStringStream.Create('');
  try
    if IsMultiSelected then
    begin
      for j := Selection.Top to Selection.Bottom do
      begin
        for i := Selection.Left to Selection.Right do
        begin
          PivotCel := VisPivotGridArray[i, j];
          Sb.WriteString(VarToStr(PivotCel.Value));
          if i <> Selection.Right then
            Sb.WriteString(#09);
        end;
        if j <> Selection.Bottom  then
          Sb.WriteString(sLineBreak);
      end;
      ClipBoard.AsText := Sb.DataString;
    end else
      ClipBoard.AsText := VarToStr(VisPivotGridArray[Col, Row].Value);

  finally
    Sb.Free;
  end;
end;

procedure TCustomPivotGridEh.DoEndDrag(Target: TObject; X, Y: Integer);
begin
  GetMoveLineEh.Hide;
  FDragCell := nil;
  inherited DoEndDrag(Target, X, Y);
end;

procedure TCustomPivotGridEh.FinishDragFrom(Source: TObject);
begin
  GetMoveLineEh.Hide;
end;

function TCustomPivotGridEh.FullRedrawOnScroll: Boolean;
begin
  Result := True;
end;

procedure TCustomPivotGridEh.CurrentCellMoved(OldCurrent: TGridCoord);
begin
  inherited CurrentCellMoved(OldCurrent);
  InvalidateCol(OldCurrent.X);
  InvalidateCol(Col);
  InvalidateRow(OldCurrent.Y);
  InvalidateRow(Row);
  if Assigned(OnCurrentCellMoved) then
    OnCurrentCellMoved(Self, OldCurrent);
end;

procedure TCustomPivotGridEh.WMSize(var Message: TWMSize);
begin
  inherited;
end;

procedure TCustomPivotGridEh.AdjustContraData;
var
  ACliW, ACliH: Integer;
  i, w: Integer;
  GridSizeLarger: Boolean;
  NewColCount, NewRowCount: Integer;
  NewContraColCount, NewContraRowCount: Integer;
begin
  if HandleAllocated then
  begin
    ACliW := GridClientWidth;
    ACliH := GridClientHeight;
  end else
  begin
    ACliW := WIdth;
    ACliH := Height;
  end;

  w := 0;
  GridSizeLarger := False;
  for i := 0 to FullColCount-1 do
  begin
    Inc(w, ColWidths[i]);
    if w > ACliW then
    begin
      GridSizeLarger := True;
      Break;
    end;
  end;

  if GridSizeLarger then
  begin
    NewColCount := FFullVisPivotColCount - GrandTotalColCount;
    NewContraColCount := GrandTotalColCount;
  end else
  begin
    NewColCount := FFullVisPivotColCount;
    NewContraColCount := 0;
  end;

  w := 0;
  GridSizeLarger := False;
  for i := 0 to FullRowCount-1 do
  begin
    Inc(w, RowHeights[i]);
    if w > ACliH then
    begin
      GridSizeLarger := True;
      Break;
    end;
  end;

  if GridSizeLarger then
  begin
    NewRowCount := FVisPivotRowCount - GrandTotalRowCount;
    if NewRowCount <= FixedRowCount then
      NewRowCount := FixedRowCount + 1;
    NewContraRowCount := GrandTotalRowCount;
  end else
  begin
    NewRowCount := FVisPivotRowCount;
    if NewRowCount <= FixedRowCount then
      NewRowCount := FixedRowCount + 1;
    NewContraRowCount := 0;
  end;

  if (NewColCount <> ColCount) or
     (NewRowCount <> RowCount) or
     (NewContraColCount <> ContraColCount) or
     (NewContraRowCount <> ContraRowCount)
  then
  begin
    SetGridColsRows(FixedColCount, NewColCount - FixedColCount, NewContraColCount,
                    FixedRowCount, NewRowCount - FixedRowCount, NewContraRowCount);
  end;
end;

procedure TCustomPivotGridEh.SetGridSizes(ForceUpdateBaseData: Boolean);
var
  ACliW, ACliH: Integer;
  i, w: Integer;
  GridSizeLarger: Boolean;
  NewContraCols, NewContraRows: Integer;
  NewRowCount, NewColCount: Integer;
  NewFixedColCount, NewFixedRowCount: Integer;
begin
  if HandleAllocated then
  begin
    ACliW := ClientWidth;
    ACliH := ClientHeight;
  end else
  begin
    ACliW := Width;
    ACliH := Height;
  end;

  if GrandTotalColVisible and not GridIsEmpty then
    NewContraCols := InColsAxisValuesCount
  else
    NewContraCols := 0;

  if GrandTotalRowVisible and not GridIsEmpty then
    NewContraRows := InRowsAxisValuesCount
  else
    NewContraRows := 0;

  w := 0;
  GridSizeLarger := False;
  if ForceUpdateBaseData then
  begin
    NewContraCols := 0;
    ColCount := FFullVisPivotColCount;
  end;

  for i := 0 to FullColCount-1 do
  begin
    Inc(w, ColWidths[i] + GridLineWidth);
    if w > ACliW then
    begin
      GridSizeLarger := True;
      Break;
    end;
  end;

  if GridSizeLarger then
  begin
    NewContraCols := NewContraCols;
    NewColCount := FVisPivotColCount - NewContraCols;
  end else
  begin
    NewContraCols := 0;
    NewColCount := FFullVisPivotColCount;
  end;

  NewFixedColCount := FStartDataCol;

  w := 0;
  GridSizeLarger := False;
  for i := 0 to FullRowCount-1 do
  begin
    Inc(w, RowHeights[i] + GridLineWidth);
    if w > ACliH then
    begin
      GridSizeLarger := True;
      Break;
    end;
  end;

  if GridSizeLarger then
  begin
    NewContraRows := NewContraRows;
    NewRowCount := FVisPivotRowCount - NewContraRows;
  end else
  begin
    NewContraRows := 0;
    NewRowCount := FVisPivotRowCount;
  end;

  if NewRowCount <= FStartDataRow then
    NewRowCount := FStartDataRow + 1;
  NewFixedRowCount := FStartDataRow;

  SetGridColsRows(NewFixedColCount, NewColCount - NewFixedColCount, NewContraCols,
                  NewFixedRowCount, NewRowCount - NewFixedRowCount, NewContraRows);
  SetGridMerges;
end;

procedure TCustomPivotGridEh.SetGridColsRows(AFixedColCount, ADataColCount,
  AContraColCount, AFixedRowCount, ADataRowCount, AContraRowCount: Integer);
begin
  FixedColCount := AFixedColCount;
  FixedRowCount := AFixedRowCount;
  SetGridSize(AFixedColCount + ADataColCount, AContraColCount,
              AFixedRowCount + ADataRowCount, AContraRowCount);
end;

procedure TCustomPivotGridEh.SetGridMerges;
var
  CI, RI, CMI, RMI: Integer;
  VI: Integer;
  CheckCell: TPivotCellEh;
  MultiValCheckCell: TPivotCellEh;
  MergeColCount: Integer;
  PivotCell: TPivotCellEh;
  MergeRowCount: Integer;
  AxisTreeNode: TPivotAxisTreeNodeEh;
  AxisMeetCellTypes: set of TAxisCellTypeEh;
  StartMergeColIndex: Integer;
  StartMergeRowIndex: Integer;

begin
  ClearAllMerges;
  if (ActualColFields = nil) or
     (ActualRowFields = nil) or
     (ActualValueFields = nil)
  then
    Exit;

  
  for CI := 0 to FullColCount - 1 do
  begin
    for RI:= 0 to FullRowCount - 1 do
    begin
      PivotCell := VisPivotGridArray[CI, RI];
      if (PivotCell.AxisValueDetails <> nil) then
      begin
        PivotCell.AxisValueDetails.AxisCellSubType := acstUndefinedEh;
        PivotCell.AxisValueDetails.ShowGroupingSign := False;
      end;
    end;
  end;

  
  MergeColCount := ActualRowFields.Count;
  MergeRowCount := ActualColFields.Count;
  if InColsAxisValuesCount > 1 then MergeRowCount := MergeRowCount + 1;
  if InRowsAxisValuesCount > 1 then MergeColCount := MergeColCount + 1;
  if MergeColCount < 1 then MergeColCount := 1;
  if MergeRowCount < 1 then MergeRowCount := 1;

  MergeCells(0, 0, MergeColCount, MergeRowCount);


  
  for CI := 0 to FullColCount - 1 do
  begin
    for RI:= 0 to FullRowCount - 1 do
    begin
      PivotCell := VisPivotGridArray[CI, RI];

      if (PivotCell.CelType = sctRowsAxisValueEh) and
         (PivotCell.AxisValueDetails.AxisCellType = actTotalCellEh) and
         (PivotCell.AxisValueDetails.AxisCellSubType = acstUndefinedEh)  then
      begin
        if (RowAxisOptions.TotalAtParentLevel = False) and
           (PivotCell.AxisValueDetails.AxisTreeNode.Expanded)
        then
          StartMergeColIndex := CI + 1
        else
          StartMergeColIndex := CI;

        CheckCell := VisPivotGridArray[StartMergeColIndex, RI];
        if CheckCell.AxisValueDetails.AxisCellSubType <> acstUndefinedEh then
          Continue;

        CheckCell.AxisValueDetails.AxisCellSubType := acstTotalFirstCellEh;
        for VI := 1 to InRowsAxisValuesCount - 1 do
        begin
          MultiValCheckCell := VisPivotGridArray[StartMergeColIndex, RI + VI];
          MultiValCheckCell.AxisValueDetails.AxisCellSubType := acstTotalFirstCellEh;
        end;
        if (PivotCell.AxisValueDetails.AxisTreeNode.Expanded = False) and
           (PivotCell.AxisValueDetails.AxisTreeNode.Count > 0)
        then
          PivotCell.AxisValueDetails.ShowGroupingSign := True;

        MergeColCount := 1;
        for CMI := StartMergeColIndex+1 to ActualRowFieldCount-1 do
        begin
          CheckCell := VisPivotGridArray[CMI, RI];
          if (CheckCell.CelType = sctRowsAxisValueEh) then
          begin
            MergeColCount := MergeColCount + 1;
            CheckCell.AxisValueDetails.AxisCellSubType := acstTotalNextCellEh;
            for VI := 1 to InRowsAxisValuesCount - 1 do
            begin
              MultiValCheckCell := VisPivotGridArray[CMI, RI + VI];
              MultiValCheckCell.AxisValueDetails.AxisCellSubType := acstTotalNextCellEh;
            end;
          end else
          begin
            Break;
          end;
        end;

        if (StartMergeColIndex < ActualRowFieldCount) or
           (InRowsAxisValuesCount > 1)
        then
          MergeCells(StartMergeColIndex, RI, MergeColCount, InRowsAxisValuesCount);
      end;
    end;
  end;

  
  for CI := 0 to FullColCount - 1 do
  begin
    for RI:= 0 to FullRowCount - 1 do
    begin
      PivotCell := VisPivotGridArray[CI, RI];
      AxisMeetCellTypes := [actGroupCellEh, actTotalCellEh];

      if (PivotCell.CelType = sctRowsAxisValueEh) and
         (PivotCell.AxisValueDetails.AxisCellType in AxisMeetCellTypes) and
         (PivotCell.AxisValueDetails.AxisCellSubType = acstUndefinedEh)  then
      begin
        AxisTreeNode := PivotCell.AxisValueDetails.AxisTreeNode;
        PivotCell.AxisValueDetails.AxisCellSubType := acstGroupFirstCellEh;
        if PivotCell.AxisValueDetails.AxisTreeNode.Count > 0 then
          PivotCell.AxisValueDetails.ShowGroupingSign := True;

        AxisMeetCellTypes := [actGroupCellEh, actTotalCellEh];

        MergeRowCount := 1;
        for RMI := RI+1 to RowCount - 1 do
        begin
          CheckCell := VisPivotGridArray[CI, RMI];
          if (CheckCell.CelType = sctRowsAxisValueEh) and
             (CheckCell.AxisValueDetails <> nil) and
             (CheckCell.AxisValueDetails.AxisCellType in AxisMeetCellTypes) and
             (AxisTreeNode = CheckCell.AxisValueDetails.AxisTreeNode) and
             (CheckCell.AxisValueDetails.AxisCellSubType = acstUndefinedEh) then
          begin
            MergeRowCount := MergeRowCount + 1;
            CheckCell.AxisValueDetails.AxisCellSubType := acstGroupNextCellEh;
          end else
          begin
            Break;
          end;
        end;

        MergeCells(CI, RI, 1, MergeRowCount);
      end;
    end;
  end;

  
  if (GrandTotalRowCount > 0) then
  begin
    MergeColCount := 1;
    for CI := 0 to FullColCount - 1 do
    begin
      PivotCell := VisPivotGridArray[CI, FullRowCount - GrandTotalRowCount];
      if (PivotCell.CelType = sctRowsAxisValueEh) and
         (PivotCell.AxisValueDetails.AxisCellSubType = acstUndefinedEh) then
      begin
        if (CI = 0) then
          PivotCell.AxisValueDetails.AxisCellSubType := acstTotalFirstCellEh
        else
        begin
          PivotCell.AxisValueDetails.AxisCellSubType := acstTotalNextCellEh;
          MergeColCount := MergeColCount + 1;
        end;
      end;
    end;
    MergeCells(0, FullRowCount - GrandTotalRowCount, MergeColCount, GrandTotalRowCount);
  end;


  
  for CI := 0 to FullColCount - 1 do
  begin
    for RI:= 0 to FullRowCount - 1 do
    begin
      PivotCell := VisPivotGridArray[CI, RI];

      if (PivotCell.CelType = sctColsAxisValueEh) and
         (PivotCell.AxisValueDetails.AxisCellType = actTotalCellEh) and
         (PivotCell.AxisValueDetails.AxisCellSubType = acstUndefinedEh)  then
      begin
        if (ColumnAxisOptions.TotalAtParentLevel = False) and
           (PivotCell.AxisValueDetails.AxisTreeNode.Expanded)
        then
          StartMergeRowIndex := RI + 1
        else
          StartMergeRowIndex := RI;

        CheckCell := VisPivotGridArray[CI, StartMergeRowIndex];
        if CheckCell.AxisValueDetails.AxisCellSubType <> acstUndefinedEh then
          Continue;

        CheckCell.AxisValueDetails.AxisCellSubType := acstTotalFirstCellEh;
        for VI := 1 to InColsAxisValuesCount - 1 do
        begin
          MultiValCheckCell := VisPivotGridArray[CI + VI, StartMergeRowIndex];
          MultiValCheckCell.AxisValueDetails.AxisCellSubType := acstTotalFirstCellEh;
        end;
        if (PivotCell.AxisValueDetails.AxisTreeNode.Expanded = False) and
           (PivotCell.AxisValueDetails.AxisTreeNode.Count > 0)
        then
          PivotCell.AxisValueDetails.ShowGroupingSign := True;

        MergeRowCount := 1;
        for RMI := StartMergeRowIndex+1 to ActualColFieldCount-1+1 do
        begin
          CheckCell := VisPivotGridArray[CI, RMI];
          if (CheckCell.CelType = sctColsAxisValueEh) then
          begin
            MergeRowCount := MergeRowCount + 1;
            CheckCell.AxisValueDetails.AxisCellSubType := acstTotalNextCellEh;
            for VI := 1 to InColsAxisValuesCount - 1 do
            begin
              MultiValCheckCell := VisPivotGridArray[CI + VI, RMI];
              MultiValCheckCell.AxisValueDetails.AxisCellSubType := acstTotalNextCellEh;
            end;
          end else
          begin
            Break;
          end;
        end;

        if (StartMergeRowIndex < ActualColFieldCount) or
           (InColsAxisValuesCount > 1)
        then
          MergeCells(CI, StartMergeRowIndex, InColsAxisValuesCount, MergeRowCount);
      end;
    end;
  end;

  
  for CI := 0 to FullColCount - 1 do
  begin
    for RI:= 0 to FullRowCount - 1 do
    begin
      PivotCell := VisPivotGridArray[CI, RI];
      AxisMeetCellTypes := [actGroupCellEh, actTotalCellEh];

      if (PivotCell.CelType = sctColsAxisValueEh) and
         (PivotCell.AxisValueDetails.AxisCellType in AxisMeetCellTypes) and
         (PivotCell.AxisValueDetails.AxisCellSubType = acstUndefinedEh)  then
      begin
        AxisTreeNode := PivotCell.AxisValueDetails.AxisTreeNode;
        PivotCell.AxisValueDetails.AxisCellSubType := acstGroupFirstCellEh;
        if PivotCell.AxisValueDetails.AxisTreeNode.Count > 0 then
          PivotCell.AxisValueDetails.ShowGroupingSign := True;

        AxisMeetCellTypes := [actGroupCellEh, actTotalCellEh];

        MergeColCount := 1;
        for CMI := CI+1 to ColCount - 1 do
        begin
          CheckCell := VisPivotGridArray[CMI, RI];
          if (CheckCell.CelType = sctColsAxisValueEh) and
             (CheckCell.AxisValueDetails <> nil) and
             (CheckCell.AxisValueDetails.AxisCellType in AxisMeetCellTypes) and
             (AxisTreeNode = CheckCell.AxisValueDetails.AxisTreeNode) and
             (CheckCell.AxisValueDetails.AxisCellSubType = acstUndefinedEh) then
          begin
            MergeColCount := MergeColCount + 1;
            CheckCell.AxisValueDetails.AxisCellSubType := acstGroupNextCellEh;
          end else
          begin
            Break;
          end;
        end;

        MergeCells(CI, RI, MergeColCount, 1);
      end;
    end;
  end;

  
  if (GrandTotalColCount > 0) then
  begin
    MergeRowCount := 1;
    for RI := 0 to FullRowCount - 1 do
    begin
      PivotCell := VisPivotGridArray[FullColCount - GrandTotalColCount, RI];
      if (PivotCell.CelType = sctColsAxisValueEh) and
         (PivotCell.AxisValueDetails.AxisCellSubType = acstUndefinedEh) then
      begin
        if (RI = 1) then
          PivotCell.AxisValueDetails.AxisCellSubType := acstTotalFirstCellEh
        else
        begin
          PivotCell.AxisValueDetails.AxisCellSubType := acstTotalNextCellEh;
          MergeRowCount := MergeRowCount + 1;
        end;
      end;
    end;
    MergeCells(FullColCount - GrandTotalColCount, 1, GrandTotalColCount, MergeRowCount);
  end;

end;

procedure TCustomPivotGridEh.GetFilterButtonRect(const ACellRect: TRect;
  var AButtonRect, AGrossRect: TRect; ARightToLeftAlignment: Boolean);
var
  FilterButtonWidth: Integer;
  InplaceEditorButtonHeight: Integer;
  InplaceEditorButtonWidth: Integer;
  AWidth: Integer;
begin

  if True{Flat} then
  begin
    FilterButtonWidth := DefaultFlatButtonWidth;
    if not ThemesEnabled then
      Inc(FilterButtonWidth);
  end{ else
    FilterButtonWidth := GetSystemMetrics(SM_CXVSCROLL)};

  if (ACellRect.Right - ACellRect.Left) div 2 < FilterButtonWidth then
    FilterButtonWidth := (ACellRect.Right - ACellRect.Left) div 2;

  AGrossRect := ACellRect;
  AGrossRect.Right := ACellRect.Right;
  AGrossRect.Left := AGrossRect.Right - FilterButtonWidth;
  AButtonRect := AGrossRect;

  if True{not AState.The3DRect} then
  begin
    OffsetRect(AButtonRect, -1, 0);
  end;

  if Flat
    then InplaceEditorButtonWidth := DefaultFlatButtonWidth
    else InplaceEditorButtonWidth := GetSystemMetrics(SM_CXVSCROLL);

  if DefaultRowHeight > Round(InplaceEditorButtonWidth * 3 / 2)
    then InplaceEditorButtonHeight := DefaultEditButtonHeight(InplaceEditorButtonWidth,  Flat)
    else InplaceEditorButtonHeight := DefaultRowHeight;

  if AButtonRect.Bottom - AButtonRect.Top > InplaceEditorButtonHeight then
  begin
    AButtonRect.Top := (AButtonRect.Bottom + AButtonRect.Top - InplaceEditorButtonHeight) div 2;
    AButtonRect.Bottom := AButtonRect.Top + InplaceEditorButtonHeight;
  end;

  if ARightToLeftAlignment then
  begin
    AWidth := AButtonRect.Right - AButtonRect.Left;
    AButtonRect.Left := ACellRect.Left + (ACellRect.Right - AButtonRect.Right);
    AButtonRect.Right := AButtonRect.Left + AWidth;

    AWidth := AGrossRect.Right - AGrossRect.Left;
    AGrossRect.Left := ACellRect.Left + (ACellRect.Right - AGrossRect.Right);
    AGrossRect.Right := AGrossRect.Left + AWidth;
  end;
end;

procedure TCustomPivotGridEh.DrawFilterButton(var ARect: TRect;
  AState: TGridDrawState; FilterHaveValues: Boolean);
var
  FilterButtonRect: TRect;
  FilterButtonGrossRect: TRect;
  ButtonActive: Boolean;
  EditButtonTransparency: Integer;
  ADownButton: Integer;
  EditButtonStyle: TEditButtonStyleEh;
  imList: TImageList;
  imListIdx: Integer;
  FlatButton: Boolean;
begin

  FlatButton := True;
  GetFilterButtonRect(ARect, FilterButtonRect, FilterButtonGrossRect, False);

  ARect.Right := FilterButtonRect.Left;

  ButtonActive := False;
  ADownButton := 0;

  if csDesigning in ComponentState then
    EditButtonTransparency := 30
  else if ((gdHotTrack in AState) and (FHotTrackEditButton = 0) and CanMouseTrackMode)
  then
  begin
    EditButtonTransparency := 0;
    ButtonActive := True;
  end else if (gdHotTrack in AState) and CanMouseTrackMode then
    EditButtonTransparency := 30
  else
    EditButtonTransparency := 80;

  if FilterHaveValues then
  begin
    EditButtonStyle := ebsGlyphEh;
    imList := DBGridEhRes.GetIMList10;
    imListIdx := 17;
    EditButtonTransparency := 0;
  end else
  begin
    EditButtonStyle := ebsAltDropDownEh;
    imList := nil;
    imListIdx := -1;
  end;

  PaintInplaceButton(Canvas, EditButtonStyle,
    FilterButtonRect,  FilterButtonRect,
    ADownButton, ButtonActive, FlatButton, True, Canvas.Brush.Color, nil,
    EditButtonTransparency, imList, imListIdx);
end;

procedure TCustomPivotGridEh.EmptyGridData;
var
  PivotCel: TPivotCellEh;
  i: Integer;
begin
  FDataSortColNum := -1;
  FStartDataRow := 2;
  FStartDataCol := 1;
  FShowGrandTotalCols := True;
  FShowGrandTotalRows := True;

  SetPivotGridArraySize(3, 4);

  PivotCel := PivotGridArray[0, 0];
  PivotCel.Clear;

  PivotCel := PivotGridArray[1, 0];
  PivotCel.Clear;
  PivotCel.CelType := sctFieldNameForColEh;

  PivotCel := PivotGridArray[0, 1];
  PivotCel.Clear;
  PivotCel.CelType := sctFieldNameForRowEh;

  PivotCel := PivotGridArray[1, 1];
  PivotCel.Clear;
  PivotCel.CelType := sctColsAxisValueEh;

  PivotCel := PivotGridArray[0, 2];
  PivotCel.Clear;
  PivotCel.CelType := sctRowsAxisValueEh;

  PivotCel := PivotGridArray[1, 2];
  PivotCel.Clear;
  PivotCel.CelType := sctDataEh;
  PivotCel.ShowValue := False;

  FVisPivotColCount := 3;
  FFullVisPivotColCount := 3;
  FVisPivotColCountAffix := 0;
  FVisPivotRowCount := 4;

  ContraColCount := 0;
  ContraRowCount := 0;
  FixedColCount := 1;
  FixedRowCount := 1;
  RolColCount := 2;
  RolRowCount := 3;
  InvalidateGrid;

  if HandleAllocated then
  begin
    Canvas.Font.Size := Font.Size;
    DefaultRowHeight := Canvas.TextHeight('Wg') + 4;
    for i := 0 to FullRowCount-1 do
      InternalSetRowHeight(i, DefaultRowHeight);
    for i := 0 to FullColCount-1 do
      InternalSetColWidth(i, DefaultRowHeight * 3);
  end;
end;

function TCustomPivotGridEh.CanMouseTrackMode: Boolean;
begin
  Result := (FGridState = gsNormalEh);
end;

procedure TCustomPivotGridEh.Paint;
begin
  if FShowingLoadingMode then
    Canvas.Draw(0,0, FLoadingModeBitmap)
  else
  begin
    inherited Paint;
    if (PivotFields = nil) or (PivotFields.Count = 0) then
      PaintEmptyDataInfo;
  end;
end;

procedure TCustomPivotGridEh.SetPaintColors;
begin
  inherited SetPaintColors;
  FInValuesCellGroupBorderColor := ApproximateColor(GridLineParams.GetBrightColor, Color, 170);
  FInAxisValuesCellGroupBorderColor := ApproximateColor(GridLineParams.GetDarkColor, FixedColor, 128);
end;

procedure TCustomPivotGridEh.PaintEmptyDataInfo;
var
  w, h: Integer;
  ts: TSize;
  AText: String;
  ADrawRect: TRect;
begin
  AText :=  EhLibLanguageConsts.PivotDataIsNotLoadedEh;

  w := Width;
  h := Height;

  Canvas.Font := Font;
  Canvas.Font.Color := StyleServices.GetSystemColor(Font.Color);

  ts := Canvas.TextExtent(AText);
  ts.cy := ts.cy + 2;

  ADrawRect := Bounds((w shr 1) - (ts.cx shr 1), (h shr 1) - (ts.cy shr 1), ts.cx, ts.cy);

  InflateRect(ADrawRect, 5, 5);
  Canvas.Brush.Color := StyleServices.GetSystemColor(Color);
  WriteTextEh(Canvas, ADrawRect, True, 6, 6, AText, taCenter, tlCenter,
    False, False, 0, 0, UseRightToLeftAlignment, True);
end;

procedure TCustomPivotGridEh.PaintInplaceButton(Canvas: TCanvas;
  ButtonStyle: TEditButtonStyleEh; Rect, ClipRect: TRect;
  DownButton: Integer; Active, Flat, Enabled: Boolean; ParentColor: TColor;
  Bitmap: TBitmap; TransparencyPercent: Byte; imList: TCustomImageList;
  ImageIndex: Integer);
{$IFDEF FPC_CROSSP}
begin
end;
{$ELSE}
const
  ButtonStyleFlags: array[TEditButtonStyleEh] of TDrawButtonControlStyleEh =
  (bcsDropDownEh, bcsEllipsisEh, bcsUpDownEh, bcsUpDownEh, bcsPlusEh, bcsMinusEh,
   bcsAltDropDownEh, bcsAltUpDownEh);
var
  LineRect: TRect;
  Brush: HBRUSH;
  IsClipRgn: Boolean;
  Rgn, SaveRgn: HRgn;
  r: Integer;
  NewBM: TBitmap;
  bf : BLENDFUNCTION;
  DestCanvas: TCanvas;
  IntersectedRect: TRect;
begin
  NewBM := nil;
  IntersectedRect := EmptyRect;
  DestCanvas := Canvas;
  if TransparencyPercent > 0 then
  begin
    NewBM := GetInplaceBitmap(Width, Height);
    DestCanvas := NewBM.Canvas;
    IntersectRect(IntersectedRect, Rect, ClipRect);
    Canvas.Brush.Color := ParentColor;
    Canvas.FillRect(IntersectedRect);
  end;

  IsClipRgn := (Rect.Left < ClipRect.Left) or (Rect.Right > ClipRect.Right) or
    (Rect.Bottom > ClipRect.Bottom) or (Rect.Top < ClipRect.Top);
  r := 0; SaveRgn := 0;
  if IsClipRgn then
  begin
    SaveRgn := CreateRectRgn(0, 0, 0, 0);
    r := GetClipRgn(DestCanvas.Handle, SaveRgn);
    Rgn := CreateRectRgn(ClipRect.Left, ClipRect.Top, ClipRect.Right, ClipRect.Bottom);
    SelectClipRgn(DestCanvas.Handle, Rgn);
    DeleteObject(Rgn);
  end;

  if Flat and not ThemesEnabled then 
  begin
    LineRect := Rect;
    LineRect.Right := LineRect.Left + 1;
    Inc(Rect.Left, 1);
    if Active then
      FrameRect(DestCanvas.Handle, LineRect, GetSysColorBrush(COLOR_BTNFACE))
    else
    begin
      Brush := CreateSolidBrush(ColorToRGB(ParentColor));
      FrameRect(DestCanvas.Handle, LineRect, Brush);
      DeleteObject(Brush);
    end;
  end;
  if Self.UseRightToLeftAlignment and (DestCanvas = Canvas) then
  begin
    WindowsLPtoDP(DestCanvas.Handle, Rect);
    SwapInt(Rect.Left, Rect.Right);
    ChangeGridOrientation(Canvas, False);
  end;

  if ButtonStyle = ebsGlyphEh then
  begin
    if Flat and not ThemesEnabled then
    begin
      Brush := CreateSolidBrush(ColorToRGB(ParentColor));
      FrameRect(DestCanvas.Handle, Rect, Brush);
      DeleteObject(Brush);
      InflateRect(Rect, -1, -1);
      FillRect(DestCanvas.Handle, Rect, GetSysColorBrush(COLOR_BTNFACE));
    end else
    begin
      DrawUserButtonBackground(DestCanvas, Rect, ParentColor,
        Enabled, Active, Flat, DownButton<>0);
      InflateRect(Rect, -2, -2);
    end;
    if  (imList <> nil) then
      DrawClipped(imList, Bitmap, DestCanvas, Rect, ImageIndex, 0, 0, taCenter, Rect)
    else
      DrawClipped(nil, Bitmap, DestCanvas, Rect, 0, 0, 0, taCenter, Rect);
  end
  else
    PaintButtonControlEh(DestCanvas, Rect, ParentColor, ButtonStyleFlags[ButtonStyle],
      DownButton, Flat, Active, Enabled, cbUnchecked);

  if Self.UseRightToLeftAlignment and (DestCanvas = Canvas) then
    ChangeGridOrientation(Canvas, True);

  if IsClipRgn then
  begin
    if r = 0
      then SelectClipRgn(DestCanvas.Handle, 0)
      else SelectClipRgn(DestCanvas.Handle, SaveRgn);
    DeleteObject(SaveRgn);
  end;

  if TransparencyPercent > 0 then
  begin
    bf.BlendOp := AC_SRC_OVER;
    bf.BlendFlags := 0;
    bf.SourceConstantAlpha := Trunc(255/100*(100-TransparencyPercent));
    bf.AlphaFormat := 0;
    AlphaBlend(Canvas.Handle,
      IntersectedRect.Left, IntersectedRect.Top,
      IntersectedRect.Right-IntersectedRect.Left, IntersectedRect.Bottom-IntersectedRect.Top,
      NewBM.Canvas.Handle,
      IntersectedRect.Left, IntersectedRect.Top,
      IntersectedRect.Right-IntersectedRect.Left, IntersectedRect.Bottom-IntersectedRect.Top,
      bf);
  end;
end;
{$ENDIF} 

procedure TCustomPivotGridEh.Resize;
begin
  inherited Resize;
  if GridTextIsVisible then
    Invalidate;
  if FGridCellParams <> nil then
    AdjustContraData;
end;

procedure TCustomPivotGridEh.StartLoadingStatus(RenderDuration: Integer = -1);
begin
  if FLoadingModeCallCount = 0 then
    FLoadingModeBitmap := TBitmap.Create;

  Inc(FLoadingModeCallCount);

  if RenderDuration = -1 then
    RenderDuration := FStartLoadingStatusRenderDuration;
  PaintLoadingMode(RenderDuration);

  FShowingLoadingMode := True;

  Repaint;
end;

procedure TCustomPivotGridEh.PaintLoadingMode(RenderDuration: Integer);
{$IFDEF FPC_CROSSP}
begin
end;
{$ELSE}
var
  w, h: Integer;
  bf : BLENDFUNCTION;
  CurGridImage, TransGridImage, TmpLoadingModeBitmap: TBitmap;
  t, RenDur, Steps, StepSize, Step, i: LongWord;

  procedure DrawAlphaBlend(Step, Len: Integer);
  var
    Transp: Integer;
  begin
    Transp := Round(Step * 255 / Len);
    TransGridImage.Canvas.Brush.Color := StyleServices.GetSystemColor(clWindow);
    TransGridImage.Canvas.FillRect(Rect(0,0,w, h));

    bf.SourceConstantAlpha := 255 - Transp;
    AlphaBlend(TransGridImage.Canvas.Handle, 0, 0, w, h,
                       CurGridImage.Canvas.Handle, 0, 0, w, h, bf);

    bf.SourceConstantAlpha := Transp;
    AlphaBlend(TransGridImage.Canvas.Handle, 0, 0, w, h,
                       TmpLoadingModeBitmap.Canvas.Handle, 0, 0, w, h, bf);

    Repaint;
   end;

begin
  if not HandleAllocated then Exit;

  w := ClientWidth;
  h := ClientHeight;

  CurGridImage := TBitmap.Create;
  CurGridImage.Width := w;
  CurGridImage.Height := h;

  TransGridImage := TBitmap.Create;
  TransGridImage.Width := w;
  TransGridImage.Height := h;

  FLoadingModeBitmap.Width := w;
  FLoadingModeBitmap.Height := h;

  FLoadingModeBitmap.Canvas.Brush.Color := StyleServices.GetSystemColor(clGray);
  FLoadingModeBitmap.Canvas.FillRect(Rect(0,0,w, h));

  
  bf.BlendOp := AC_SRC_OVER;
  bf.BlendFlags := 0;
  bf.SourceConstantAlpha := Trunc(255/100*40); 
  bf.AlphaFormat := 0;
  AlphaBlend(FLoadingModeBitmap.Canvas.Handle, 0, 0, w, h,
                     Canvas.Handle, 0, 0, w, h, bf);

  CurGridImage.Canvas.Brush.Color := StyleServices.GetSystemColor(clGray);
  CurGridImage.Canvas.FillRect(Rect(0,0,w, h));

  bf.SourceConstantAlpha := 255; 
  AlphaBlend(CurGridImage.Canvas.Handle, 0, 0, w, h,
                     Canvas.Handle, 0, 0, w, h, bf);

  FShowingLoadingMode := True;
  TmpLoadingModeBitmap := FLoadingModeBitmap;
  FLoadingModeBitmap := TransGridImage;

  t := GetTickCountEh;
  Steps := RenderDuration;
  i := 1;
  Step := 1;
  while i < Steps do
  begin
    DrawAlphaBlend(i, Steps);
    RenDur := GetTickCountEh - t;
    if RenDur > 0
      then StepSize := Round(RenDur / Step)
      else StepSize := 1;
    if StepSize = 0 then
      StepSize := 1;
    i := i + StepSize;
    Inc(Step);
  end;

  if t <> 0 then Sleep(1);
  FLoadingModeBitmap := TmpLoadingModeBitmap;

  FreeAndNil(CurGridImage);
  FreeAndNil(TransGridImage);
end;
{$ENDIF} 

procedure TCustomPivotGridEh.FinishLoadingStatus(RenderDuration: Integer = -1);
begin
  if FLoadingModeCallCount = 0 then Exit;
  Dec(FLoadingModeCallCount);

  if FLoadingModeCallCount = 0 then
  begin
    if RenderDuration = -1 then
      RenderDuration := FFinishLoadingStatusRenderDuration;

    StopPaintLoadingMode(RenderDuration);

    FShowingLoadingMode := False;

    FreeAndNil(FLoadingModeBitmap);

    Repaint;
    UpdateScrollBars;
  end;
end;

procedure TCustomPivotGridEh.StopPaintLoadingMode(RenderDuration: Integer);
{$IFDEF FPC_CROSSP}
begin
end;
{$ELSE}
var
  w, h: Integer;
  bf : BLENDFUNCTION;
  TransGridImage, NewGridImage, TmpLoadingModeBitmap: TBitmap;
  i, t, RenDur, Steps, StepSize, Step: LongWord;

  procedure DrawAlphaBlend(Step, Len: Integer);
  var
    Transp: Integer;
  begin
    Transp := Round(Step * 255 / Len);

    TransGridImage.Canvas.Brush.Color := StyleServices.GetSystemColor(clWindow);
    TransGridImage.Canvas.FillRect(Rect(0,0,w, h));

    bf.SourceConstantAlpha := 255 - Transp;
    AlphaBlend(TransGridImage.Canvas.Handle, 0, 0, w, h,
      TmpLoadingModeBitmap.Canvas.Handle, 0, 0, w, h, bf);

    bf.SourceConstantAlpha := Transp;
    AlphaBlend(TransGridImage.Canvas.Handle, 0, 0, w, h,
       NewGridImage.Canvas.Handle, 0, 0, w, h, bf);

    Repaint;
  end;

begin
  w := ClientWidth;
  h := ClientHeight;

  bf.BlendOp := AC_SRC_OVER;
  bf.BlendFlags := 0;
  bf.AlphaFormat := 0;

  NewGridImage := TBitmap.Create;
  NewGridImage.Width := w;
  NewGridImage.Height := h;

  TransGridImage := TBitmap.Create;
  TransGridImage.Width := w;
  TransGridImage.Height := h;

  
  FShowingLoadingMode := False;

  PaintWindow(NewGridImage.Canvas.Handle);

  FShowingLoadingMode := True;
  TmpLoadingModeBitmap := FLoadingModeBitmap;
  FLoadingModeBitmap := TransGridImage;

  t := GetTickCountEh;
  Steps := RenderDuration;
  i := 1;
  Step := 1;
  while i < Steps do
  begin
    DrawAlphaBlend(i, Steps);
    RenDur := GetTickCountEh - t;
    if RenDur > 0
      then StepSize := Round(RenDur / Step)
      else StepSize := 1;
    if StepSize = 0 then
      StepSize := 1;
    i := i + StepSize;
    Inc(Step);
  end;

  FLoadingModeBitmap := TmpLoadingModeBitmap;

  FreeAndNil(NewGridImage);
  FreeAndNil(TransGridImage);
end;
{$ENDIF} 

function TCustomPivotGridEh.DataSourceIsEmpty: Boolean;
begin
  Result := (PivotDataSource = nil) or PivotDataSource.DataIsEmpty;
end;

procedure TCustomPivotGridEh.GridCellParamsChanged;
begin
  SetRowHeightsColumnWidths;
end;

function TCustomPivotGridEh.GridIsEmpty: Boolean;
begin
  Result := DataSourceIsEmpty {or FGridIsEmptyStatus};
end;

procedure TCustomPivotGridEh.GridLayoutChanged;
begin
  if Assigned(OnGridLayoutChanged) then
    OnGridLayoutChanged(Self);
end;

function TCustomPivotGridEh.GridTextIsVisible: Boolean;
begin
  if PivotFields <> nil
    then Result := (PivotFields.Count = 0)
    else Result := False;
end;

function TCustomPivotGridEh.CanHotTackCell(X, Y: Integer): Boolean;
begin
  Result := True;
end;

function TCustomPivotGridEh.GetMouseHitCellState(Cell: TGridCoord;
  MousePos: TPoint; CellRect: TRect;
  var StateRect: TRect): TSpicGridStateEh;
var
  FilterButtonRect: TRect;
  FilterButtonGrossRect: TRect;
  PivotCel: TPivotCellEh;
begin
  Result := dgsNormal;
  PivotCel := VisPivotGridArray[Cell.X, Cell.Y];
  if PivotCel.CelType in [sctFieldNameForRowEh, sctFieldNameForColEh] then
  begin
    GetFilterButtonRect(CellRect, FilterButtonRect, FilterButtonGrossRect, UseRightToLeftAlignment);
    if (pgoDataFiltersEh in Options) and
       PtInRect(FilterButtonRect, MousePos) then
    begin
      Result := dgsFilterButtonDown;
      StateRect := FilterButtonRect;
    end;
  end;
end;

procedure TCustomPivotGridEh.VisPivotPosToSrcArrayPos(AVisCol, AVisRow: Integer;
  var ASrcCol, ASrcRow: Integer);
var
  NewIndex: Integer;
  InVisFlatListIdx: Integer;
begin
  if DataSourceIsEmpty then
  begin
    ASrcCol := AVisCol;
    ASrcRow := AVIsRow;
    Exit;
  end;

  if AVisCol < FStartDataCol then
    ASrcCol := AVisCol
  else if AVisCol >= ColsAxisTree.FlatListCount * InColsAxisValuesCount + FStartDataCol then
  begin
    NewIndex := (AVisCol - (ColsAxisTree.FlatListCount * InColsAxisValuesCount + FStartDataCol));
    ASrcCol := (FPivotArrayDataColCount + FStartDataCol) - GrandTotalColCount + NewIndex;
  end else
  begin
    InVisFlatListIdx := (AVisCol - FStartDataCol) div InColsAxisValuesCount;
    ASrcCol := ColsAxisTree.FlatList[InVisFlatListIdx].InPivotGridArrayIndex +
               (AVisCol - FStartDataCol) mod InColsAxisValuesCount;
  end;

  if AVisRow < FStartDataRow then
    ASrcRow := AVisRow
  else if AVisRow >= RowsAxisTree.FlatListCount * InRowsAxisValuesCount + FStartDataRow then
  begin
    NewIndex := (AVisRow - (RowsAxisTree.FlatListCount * InRowsAxisValuesCount + FStartDataRow));
    ASrcRow := (FPivotArrayDataRowCount + FStartDataRow) - GrandTotalRowCount + NewIndex;
  end else
  begin
    InVisFlatListIdx := (AVisRow - FStartDataRow) div InRowsAxisValuesCount;
    ASrcRow := RowsAxisTree.FlatList[InVisFlatListIdx].InPivotGridArrayIndex +
               (AVisRow - FStartDataRow) mod InRowsAxisValuesCount;
  end;
end;

function TCustomPivotGridEh.GetVisPivotGridArray(ACol, ARow: Integer): TPivotCellEh;
var
  ANewCol: Integer;
  ANewRow: Integer;
begin
  VisPivotPosToSrcArrayPos(ACol, ARow, ANewCol, ANewRow);
  Result := PivotGridArray[ANewCol, ANewRow];
end;

function TCustomPivotGridEh.GetPivotRowSortedGridArray(ACol, ARow: Integer): TPivotCellEh;
var
  ANewRow: Integer;
begin
  if (ARow < FStartDataRow) or
     (ARow = Length(PivotGridArray[0])-1)
  then
    ANewRow := ARow
  else
    ANewRow := RowsAxisTree.FlatList[ARow-FStartDataRow].InPivotGridArrayIndex;
  Result := PivotGridArray[ACol, ANewRow];
end;

function TCustomPivotGridEh.GetSourcePivotFields: TPivotFieldsEh;
begin
  if PivotDataSource <> nil
    then Result := PivotDataSource.PivotFields
    else Result := nil;
end;

function TCustomPivotGridEh.GetActualColFields: TStringList;
begin
  if PivotDataSource <> nil
    then Result := PivotDataSource.ActualColFields
    else Result := nil;
end;

function TCustomPivotGridEh.ActualColFieldCount: Integer;
begin
  if ActualColFields = nil
    then Result := 0
    else Result := ActualColFields.Count;
end;

function TCustomPivotGridEh.GetActualRowFields: TStringList;
begin
  if PivotDataSource <> nil
    then Result := PivotDataSource.ActualRowFields
    else Result := nil;
end;

function TCustomPivotGridEh.ActualRowFieldCount: Integer;
begin
  if ActualRowFields = nil
    then Result := 0
    else Result := ActualRowFields.Count;
end;

function TCustomPivotGridEh.GetActualValueFields: TValueFieldsCollectionEh;
begin
  if PivotDataSource <> nil
    then Result := PivotDataSource.ActualValueFields
    else Result := nil;
end;

function TCustomPivotGridEh.InColsAxisValuesCount: Integer;
begin
  if (ActualValueFields <> nil) and not (pgoMultiValuesInRowsAxisEh in Options)
    then Result := ActualValueFields.Count
    else Result := 1;
end;

function TCustomPivotGridEh.InRowsAxisValuesCount: Integer;
begin
  if (ActualValueFields <> nil) and (pgoMultiValuesInRowsAxisEh in Options)
    then Result := ActualValueFields.Count
    else Result := 1;
end;

procedure TCustomPivotGridEh.InTitleFilterListKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
end;

procedure TCustomPivotGridEh.InTitleFilterListKeyPress(Sender: TObject;
  var Key: Char);
begin
end;

procedure TCustomPivotGridEh.InTitleFilterListMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
end;

function TCustomPivotGridEh.GetInTitleFilterForm: TFilterDropDownForm;
begin
  Result := GetFilterDropDownFormProc();
end;

procedure TCustomPivotGridEh.FilterFormDropDown(Cell: TGridCoord;
  const CellRect, ButtonRect: TRect);
var
  ForRect: TRect;
  PivotCel: TPivotCellEh;
  ADropDownForm: TFilterDropDownForm;
  TheMsg: TMsg;
  DDParams: TDynVarsEh;
  SysParams: TEditControlDropDownFormSysParams;
  IntDropDownForm: IDropDownFormEh;
  DropDownAlign: TDropDownAlign;
begin
  FTrackingStateRect := ButtonRect;
  PivotCel := VisPivotGridArray[Cell.X, Cell.Y];

  if PeekMessage(TheMsg, Handle, WM_USER, WM_USER, PM_NOREMOVE) then
    if (TheMsg.wParam = WPARAM(Handle)) and
       (TheMsg.lParam = LPARAM(PivotCel))
    then
      Exit;

  ADropDownForm := GetInTitleFilterForm;

  if (PivotCel.CelType in [sctFieldNameForRowEh, sctFieldNameForColEh]) and
     (PivotCel.FieldNameDetails.PivotField <> nil) and
     (PivotCel.FieldNameDetails.PivotField <> FDummyPivotField) then
  begin

    ADropDownForm.BaseList.Clear;
    PivotCel.FieldNameDetails.PivotField.FillFilterValues(ADropDownForm.BaseList);
    ADropDownForm.InitDataForBaseList;
    PivotCel.FieldNameDetails.PivotField.UpdateValuesCheckingStateFromFilter(
      ADropDownForm.BaseList, ADropDownForm.ListValuesCheckingState);

    FInTitleFilterPivotField := PivotCel.FieldNameDetails.PivotField;
  end else
    FInTitleFilterPivotField := nil;

  ForRect.TopLeft := Self.ClientToScreen(CellRect.TopLeft);
  ForRect.BottomRight := Self.ClientToScreen(CellRect.BottomRight);

  DDParams := TDynVarsEh.Create(Self);
  SysParams := TEditControlDropDownFormSysParams.Create;

  SysParams.FreeFormOnClose := False;
  SysParams.FEditControl := Self;
  SysParams.FEditButton := nil;
  SysParams.FEditButtonObj := PivotCel;

  if Supports(ADropDownForm, IDropDownFormEh, IntDropDownForm) then
    IntDropDownForm.ReadOnly := False;

  ADropDownForm.BiDiMode := BiDiMode;

  if Supports(ADropDownForm, IDropDownFormEh, IntDropDownForm) then
  begin
    if UseRightToLeftAlignment
      then DropDownAlign := daRight
      else DropDownAlign := daLeft;
    IntDropDownForm.ExecuteNoModal(ForRect, nil, DropDownAlign, DDParams, SysParams,
      InTitleFilterDropDownFormCallbackProc);
  end;

end;

procedure TCustomPivotGridEh.FilterFormCloseUp(Accept: Boolean);
begin

end;

procedure TCustomPivotGridEh.InTitleFilterDropDownFormCallbackProc(
  DropDownForm: TCustomForm; Accept: Boolean; DynParams: TDynVarsEh;
  SysParams: TDropDownFormSysParams);
var
  RefButtonObj: TObject;
  PivotCel: TPivotCellEh;
  FilterDropDownForm: TFilterDropDownForm;
begin
  RefButtonObj := TEditControlDropDownFormSysParams(SysParams).FEditButtonObj;
  if RefButtonObj <> nil then
    PostMessage(Handle, WM_USER, WPARAM(Handle), LPARAM(RefButtonObj));
  DynParams.Free;
  SysParams.Free;
  FInTitleFilterListboxVisible := False;

  if Accept then
  begin
    FilterDropDownForm := TFilterDropDownForm(DropDownForm);
    PivotCel := TPivotCellEh(RefButtonObj);
    PivotCel.FieldNameDetails.PivotField.UpdateFilterFromValuesCheckingState(
      FilterDropDownForm.BaseList, FilterDropDownForm.ListValuesCheckingState);
    FilterDropDownForm.Hide;
    PivotDataSource.SetDataFilter;
  end;

  Invalidate;
end;

{$IFDEF FPC}
{$ELSE}
procedure TCustomPivotGridEh.CMCancelMode(var Message: TCMCancelMode);
begin
  inherited;
end;
{$ENDIF}

procedure TCustomPivotGridEh.CMFontChanged(var Message: TMessage);
begin
  inherited;
  GridCellParams.RefreshDefaultDataAggregateFont;
  GridCellParams.RefreshDefaultDataFont;
  GridCellParams.RefreshDefaultFieldNameFont;
  GridCellParams.RefreshDefaultAxisFont;
  GridCellParams.RefreshDefaultAxisAggregateFont;
  GridCellParamsChanged;
end;

function TCustomPivotGridEh.GrandTotalColCount: Integer;
begin
  if FShowGrandTotalCols then
  begin
    if GridIsEmpty
      then Result := 1
      else Result := InColsAxisValuesCount;
  end else
    Result := 0;
end;

function TCustomPivotGridEh.GrandTotalRowCount: Integer;
begin
  if FShowGrandTotalRows
    then Result := InRowsAxisValuesCount
    else Result := 0;
end;

function TCustomPivotGridEh.GrandTotalColVisible: Boolean;
begin
  Result := FShowGrandTotalCols;
end;

function TCustomPivotGridEh.GrandTotalRowVisible: Boolean;
begin
  Result := FShowGrandTotalRows;
end;

procedure TCustomPivotGridEh.GetValueFieldsInfoFromCommaText(
  const ACommaText: String);
begin
end;

procedure TCustomPivotGridEh.CMHintsShowPause(var Message: TCMHintShowPause);
var
  Cell: TGridCoord;
begin
  Cell := MouseCoord(HitTest.X, HitTest.Y);
  if ShowToolTips and (Cell.X >= 0) and (Cell.Y >= 0) then
    Message.Pause^ := 0
  else
    inherited;
end;

procedure TCustomPivotGridEh.CMHintShow(var Message: TCMHintShow);
begin
  inherited;
end;

procedure TCustomPivotGridEh.GetSpreadCellHintShowParams(
  AParams: TSpreadCellShowHintParamsEh);
var
  PivotCell: TPivotCellEh;
  s: String;
  ATextWidth: Integer;
  AContentRect: TRect;
  LocalHintPos: TPoint;
begin
  if ShowToolTips and (AParams.ColIndex >= 0) and (AParams.RowIndex >= 0) then
  begin
    PivotCell := VisPivotGridArray[AParams.ColIndex, AParams.RowIndex];
    ATextWidth := 0;
    s := '';
    if PivotCell.CelType in [sctFieldNameForRowEh, sctFieldNameForColEh] then
    begin
      if PivotCell.ShowValue = True then
        s := VarToStr(PivotCell.Value)
      else
        s := '';
      Canvas.Font := GridCellParams.FieldNameFont;
      ATextWidth := Canvas.TextWidth(s);
      AContentRect := GetCellContentRect(AParams.ColIndex, AParams.RowIndex, AParams.CellRect, PivotCell);
    end
    else if PivotCell.CelType in [sctDataEh, sctHorzAggregateData, sctVertAggregateData] then
    begin
      FillDrawCellParams(FBaseDrawCellParams, AParams.ColIndex, AParams.RowIndex, AParams.CellRect, [], PivotCell);
      s := FBaseDrawCellParams.DisplayValue;
      Canvas.Font := FBaseDrawCellParams.Font;
      ATextWidth := Canvas.TextWidth(s);
      AContentRect := GetCellContentRect(AParams.ColIndex, AParams.RowIndex, AParams.CellRect, PivotCell);
    end
    else if PivotCell.CelType in [sctRowsAxisValueEh, sctColsAxisValueEh,
                                     sctValCaptionInColsAxisEh, sctValCaptionInRowsAxisEh] then
    begin
      FAxisValueDrawParams.FDrawEvtArg := nil;
      FillAxisValueCellParams(FAxisValueDrawParams, AParams.ColIndex, AParams.RowIndex, PivotCell);
      Canvas.Font := FBaseDrawCellParams.Font;
      s := FBaseDrawCellParams.DisplayValue;
      ATextWidth := Canvas.TextWidth(s);
      AContentRect := GetCellContentRect(AParams.ColIndex, AParams.RowIndex, AParams.CellRect, PivotCell);
    end;

    if (s <> '') and
       PtInRect(AContentRect, HitTest) and
       (ATextWidth > RectWidth(AContentRect)) then
    begin
      AParams.HintStr := s;
      AParams.CursorRect := AContentRect;
      LocalHintPos := Point(AParams.CellRect.Left, AParams.CellRect.Bottom);
      AParams.HintPos := ClientToScreen(LocalHintPos);
    end;
  end;
end;

function TCustomPivotGridEh.GetCellContentRect(ACol, ARow: Integer;
  ACellRect: TRect; PivotCel: TPivotCellEh): TRect;
var
  FilterButtonRect: TRect;
  FilterButtonGrossRect: TRect;
  smSize: TSize;
  IsDrawFilterButton: Boolean;
begin
  Result := ACellRect;
  if PivotCel.CelType in [sctFieldNameForRowEh, sctFieldNameForColEh] then
  begin
    if (PivotCel.VertAggrLevelRow > 0) or (PivotCel.HorzAggrLevelCol > 0) then
      Result.Left := Result.Left + Round(18 * ScaleFactor); 

    if (PivotCel.CelType = sctFieldNameForColEh) then
      IsDrawFilterButton := PivotCel.FieldNameForColDetails.DrawFilterButton
    else
      IsDrawFilterButton := PivotCel.FieldNameForRowDetails.DrawFilterButton;

    if IsDrawFilterButton then 
    begin
      GetFilterButtonRect(Result, FilterButtonRect, FilterButtonGrossRect, False);
      Result.Right := FilterButtonRect.Left;
    end;

    if (PivotCel.CelType = sctFieldNameForRowEh) and
       (FDataSortColNum = -1) and
       (PivotCel.FieldNameDetails.PivotField <> nil)
    then 
    begin
      smSize := DBGridEhDefaultStyle.GetSortMarkerSize(Canvas, smstSolidEh);
      Result.Right := Result.Right - smSize.cx;
    end;

    Result.Left := Result.Left + 2;
    Result.Top := Result.Top + 2;

  end else if PivotCel.CelType in [sctRowsAxisValueEh, sctColsAxisValueEh,
                                   sctValCaptionInColsAxisEh, sctValCaptionInRowsAxisEh] then
  begin
    Result := ACellRect;
    if (PivotCel.AxisValueDetails <> nil) and
       (PivotCel.AxisValueDetails.ShowGroupingSign) then
      Result.Left := Result.Left + Round(18 * ScaleFactor); 

    Result.Left := Result.Left + 2;
    Result.Top := Result.Top + 2;
  end else if PivotCel.CelType in [sctDataEh, sctHorzAggregateData, sctVertAggregateData] then
  begin

    Result.Left := Result.Left + 2;
    Result.Top := Result.Top + 2;
  end;
end;

procedure TCustomPivotGridEh.SelectionChanged(const OldSel: TGridRect);
begin
  inherited SelectionChanged(OldSel);
  TPivotGridScrollBarPanelControl(HorzScrollBarPanelControl).GridSelectionChanged;
end;

function TCustomPivotGridEh.CreateEditor: TInplaceEdit;
begin
  Result := TPivotGridInplaceEditEh.Create(Self);
end;

procedure TCustomPivotGridEh.ShowEditor;
begin
  if not EditorMode then
    FEditText := Unassigned;
  inherited ShowEditor;
end;

procedure TCustomPivotGridEh.HideEditor;
var
  IsRebuildData: Boolean;
begin
  IsRebuildData := False;
  if EditorMode and FEditUserTextModified then
    PostEditText(IsRebuildData);

  inherited HideEditor;

  if IsRebuildData then
  begin
    PivotDataSource.BuildPivotData;
    RebuildGrid;
  end;

  FEditUserTextModified := False;
end;

function TCustomPivotGridEh.GetEditText(ACol, ARow: Integer): string;
var
  PivotCel: TPivotCellEh;
begin
  PivotCel := VisPivotGridArray[ACol, ARow];
  if PivotCel <> nil
    then Result := VarToStrDef(PivotCel.Value, '')
    else Result := '';
end;

procedure TCustomPivotGridEh.FillDataCellEditorParams(
  ACellEditorParams: TPivotDataCellEditorParamsEh; ACol, ARow: Integer);
var
  PivotCel: TPivotCellEh;
  AxisCell: TPivotCellEh;
begin
  if (ACol < FFullVisPivotColCount) and (ARow < FVisPivotRowCount) then
    PivotCel := VisPivotGridArray[ACol, ARow]
  else
    PivotCel := nil;

  ACellEditorParams.FCol := ACol;
  ACellEditorParams.FRow := ARow;
  ACellEditorParams.FAreaCol := ACol - FStartDataCol;
  ACellEditorParams.FAreaRow := ARow - FStartDataRow;

  SetLength(ACellEditorParams.FColsAxisPos, PivotDataSource.ColumnFields.Count);
  SetLength(ACellEditorParams.FRowsAxisPos, PivotDataSource.RowFields.Count);

  SetColRowAxisPosForDataCell(ACellEditorParams.FAreaCol, ACellEditorParams.FAreaRow,
    ACellEditorParams.FColsAxisPos, ACellEditorParams.FRowsAxisPos);

  if (PivotCel <> nil) then
  begin
    if (PivotCel.CelType in [sctHorzAggregateData, sctVertAggregateData])
       {and not (gdSelected in AState)}
    then
    begin
      ACellEditorParams.FFillColor := GridCellParams.ActualDataAggregateColor;
      ACellEditorParams.Font := GridCellParams.DataAggregateFont;
      ACellEditorParams.Font.Color := StyleServices.GetSystemColor(GridCellParams.DataAggregateFont.Color);
    end else
    begin
      ACellEditorParams.Font := GridCellParams.DataFont;
    end;

    ACellEditorParams.FValue := PivotCel.Value;
    ACellEditorParams.FEditValue := VarToStrDef(PivotCel.Value, '');
  end;

  AxisCell := VisPivotGridArray[0, ARow];
  ACellEditorParams.FRowsGroupLevel := AxisCell.VertAggrLevelRow;

  AxisCell := VisPivotGridArray[ACol, 1];
  ACellEditorParams.FColsGroupLevel := AxisCell.HorzAggrLevelCol;

  ACellEditorParams.CanModify := False;

  if Assigned(OnGetDataCellEditorParams) then
    OnGetDataCellEditorParams(Self, ACol, ARow, ACellEditorParams);
end;

procedure TCustomPivotGridEh.SetEditText(ACol, ARow: Integer; const Value: string);
begin
  FEditText := Value;
end;

function TCustomPivotGridEh.CanEditModify: Boolean;
begin
  if (InplaceEditor <> nil) and not InplaceEditor.ReadOnly then
  begin
    FEditUserTextModified := True;
    Result := True;
  end else
  begin
    Result := False;
  end;
end;

procedure TCustomPivotGridEh.UpdateText(EditorChanged: Boolean);
begin
  if EditorChanged then
    inherited UpdateText(EditorChanged);
end;

procedure TCustomPivotGridEh.PostEditText(var IsRebuildData: Boolean);
var
  EditorParams: TPivotDataCellEditorSetValueParamsEh;
begin
  if VarIsEmpty(FEditText) then Exit;

  EditorParams := TPivotDataCellEditorSetValueParamsEh.Create;

  FillDataCellEditorSetValueParams(EditorParams, Col, Row);
  EditorParams.UpdateInternalTables := True;

  if Assigned(OnSetDataCellEditorValue) then
    OnSetDataCellEditorValue(Self, Col, Row, EditorParams);
  if EditorParams.UpdateInternalTables then
  begin
    UpdateInternalTablesForEditorValue(EditorParams);
    IsRebuildData := True;
  end;

  EditorParams.Free;
end;

procedure TCustomPivotGridEh.FillDataCellEditorSetValueParams(
  ACellEditorParams: TPivotDataCellEditorSetValueParamsEh; ACol, ARow: Integer);
var
  AxisCell: TPivotCellEh;
begin
  ACellEditorParams.FCol := ACol;
  ACellEditorParams.FRow := ARow;
  ACellEditorParams.FAreaCol := ACol - FStartDataCol;
  ACellEditorParams.FAreaRow := ARow - FStartDataRow;

  SetLength(ACellEditorParams.FColsAxisPos, PivotDataSource.ColumnFields.Count);
  SetLength(ACellEditorParams.FRowsAxisPos, PivotDataSource.RowFields.Count);

  SetColRowAxisPosForDataCell(ACellEditorParams.FAreaCol, ACellEditorParams.FAreaRow,
    ACellEditorParams.FColsAxisPos, ACellEditorParams.FRowsAxisPos);

  ACellEditorParams.FEditValue := FEditText;

  AxisCell := VisPivotGridArray[0, ARow];
  ACellEditorParams.FRowsGroupLevel := AxisCell.VertAggrLevelRow;

  AxisCell := VisPivotGridArray[ACol, 1];
  ACellEditorParams.FColsGroupLevel := AxisCell.HorzAggrLevelCol;

  ACellEditorParams.FValuesAxisPos := (ACol - FStartDataCol) mod PivotDataSource.ValueFieldDefs.Count;
end;

procedure TCustomPivotGridEh.UpdateInternalTablesForEditorValue(ACellEditorParams: TPivotDataCellEditorSetValueParamsEh);
var
  KeyFields: String;
  i: Integer;
  KeyValue: Variant;
  ValueFieldName: String;
begin
  KeyFields := '';
  KeyValue := VarArrayCreate([0, PivotDataSource.ColumnFields.Count + PivotDataSource.RowFields.Count - 1], varVariant);

  for i := 0 to PivotDataSource.ColumnFields.Count-1 do
  begin
    KeyFields := KeyFields + TPivotFieldEh(PivotDataSource.ColumnFields.Objects[i]).FieldName + ';';
    KeyValue[i] := ACellEditorParams.ColsAxisPos[i];
  end;

  for i := 0 to PivotDataSource.RowFields.Count-1 do
  begin
    KeyFields := KeyFields + TPivotFieldEh(PivotDataSource.RowFields.Objects[i]).FieldName + ';';
    KeyValue[i+PivotDataSource.ColumnFields.Count] := ACellEditorParams.RowsAxisPos[i];
  end;

  Delete(KeyFields, Length(KeyFields), 1);

  if PivotDataSource.SourceTable.Locate(KeyFields, KeyValue, []) then
  begin
    ValueFieldName := PivotDataSource.ValueFieldDefs[ACellEditorParams.ValuesAxisPos].PivotFieldName;
    PivotDataSource.SourceTable.Edit;
    PivotDataSource.SourceTable.FieldByName(ValueFieldName).AsString := ACellEditorParams.EditValue;
    PivotDataSource.SourceTable.Post;
  end;
  { TODO : UpdateInternalTablesForEditorValue }
end;

procedure TCustomPivotGridEh.SetColRowAxisPosForDataCell(ADataCol, ADataRow: Integer;
  var AColsAxisPos: TVariantDynArray; var ARowsAxisPos: TVariantDynArray);
var
  i: Integer;
  AxisPivotCell: TPivotCellEh;
begin

  for i := 0 to PivotDataSource.ColumnFields.Count-1 do
  begin
    AxisPivotCell := VisPivotGridArray[ADataCol + FStartDataCol, 1 + i];
    if PivotDataSource.ColumnFields.Count - i > AxisPivotCell.HorzAggrLevelCol then
      AColsAxisPos[i] := AxisPivotCell.Value
    else
      AColsAxisPos[i] := Unassigned;
  end;

  for i := 0 to PivotDataSource.RowFields.Count-1 do
  begin
    AxisPivotCell := VisPivotGridArray[i, ADataRow + FStartDataRow];
    if PivotDataSource.RowFields.Count - i > AxisPivotCell.VertAggrLevelRow then
      ARowsAxisPos[i] := AxisPivotCell.Value
    else
      ARowsAxisPos[i] := Unassigned;
  end;

end;

procedure TCustomPivotGridEh.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if ([ssShift, ssAlt, ssCtrl] * Shift = [ssCtrl]) and
      (Key in [VK_INSERT, Word('C')]) then
  begin
    DoCopyAction;
  end;
  if Key = VK_ESCAPE then
    CancelEditor;
end;

procedure TCustomPivotGridEh.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
end;

procedure TCustomPivotGridEh.CancelEditor;
begin
  if EditorMode then
  begin
    FEditText := Unassigned;
    FEditUserTextModified := False;
    HideEditor;
  end;
end;

function TCustomPivotGridEh.CreateGridLineColors: TGridLineColorsEh;
begin
  Result := TPivotGridLineParamsEh.Create(Self);
end;

function TCustomPivotGridEh.GetGridLineParams: TPivotGridLineParamsEh;
begin
  Result := TPivotGridLineParamsEh(inherited GridLineColors);
end;

function TCustomPivotGridEh.GetGridCellParams: TPivotGridCellParamsEh;
begin
  Result := FGridCellParams;
end;

procedure TCustomPivotGridEh.SetGridCellParams(const Value: TPivotGridCellParamsEh);
begin
  FGridCellParams.Assign(Value);
end;

function TCustomPivotGridEh.CreateGridCellParams: TPivotGridCellParamsEh;
begin
  Result := TPivotGridCellParamsEh.Create(Self);
end;

procedure TCustomPivotGridEh.SetGridLineParams(const Value: TPivotGridLineParamsEh);
begin
  GridLineColors := Value;
end;

function TCustomPivotGridEh.GetOptions: TPivotGridOptionsEh;
begin
  Result := FOptions;
end;

procedure TCustomPivotGridEh.SetOptions(const Value: TPivotGridOptionsEh);
begin
  if FOptions <> Value then
  begin
    FOptions := Value;
    inherited Options := GetValueForInheritedOptions;
    InvalidateGrid;
  end;
end;

function TCustomPivotGridEh.GetValueForInheritedOptions: TGridOptionsEh;
begin
  Result := [
    goFixedVertLineEh, goFixedHorzLineEh, goVertLineEh, goHorzLineEh,
    goDrawFocusSelectedEh,
    goContraVertBoundaryLineEh, goContraHorzBoundaryLineEh,
    goRangeSelectEh];
  if pgoRowSizingEh in Options then
    Result := Result +[goRowSizingEh];
  if pgoColSizingEh in Options then
    Result := Result +[goColSizingEh];
  if pgoEditingEh in Options then
    Result := Result +[goEditingEh];
  if pgoWantTabEh in Options then
    Result := Result +[goTabsEh];
end;

procedure TCustomPivotGridEh.SetRowLines(const Value: Integer);
begin
  if Value <> FRowLines then
  begin
    FRowLines := Value;
    SetRowHeightsColumnWidths;
  end;
end;

procedure TCustomPivotGridEh.SetRowHeight(const Value: Integer);
begin
  if Value <> FRowHeight then
  begin
    FRowHeight := Value;
    SetRowHeightsColumnWidths;
  end;
end;

function TCustomPivotGridEh.GetDefaultColWidth: Integer;
begin
  Result := inherited DefaultColWidth;
end;

procedure TCustomPivotGridEh.SetDefaultColWidth(const Value: Integer);
begin
  if inherited DefaultColWidth <> Value then
  begin
    inherited DefaultColWidth := Value;
    SetRowHeightsColumnWidths;
  end;
end;

function TCustomPivotGridEh.FixedColsSizingAllowed: Boolean;
begin
  Result := True;
end;

procedure TCustomPivotGridEh.ChangeScale(M, D: Integer {$IFDEF EH_LIB_24}; isDpiChange: Boolean {$ENDIF});
begin
  inherited ChangeScale(M, D{$IFDEF EH_LIB_24}, isDpiChange{$ENDIF});

  if M <> D then
  begin
    if (DefaultColWidth > 0) then
      DefaultColWidth := MulDiv(DefaultColWidth, M, D);
  end;

  GridCellParams.RefreshDefaultDataAggregateFont;
  GridCellParams.RefreshDefaultDataFont;
  GridCellParams.RefreshDefaultFieldNameFont;
  GridCellParams.RefreshDefaultAxisFont;
  GridCellParams.RefreshDefaultAxisAggregateFont;
end;

procedure TCustomPivotGridEh.ShowProgressPanel(ElapsedTime: LongWord; Percent: Integer);
begin
  if not FProgressPanel.Visible then
  begin
    StartLoadingStatus;
    Repaint;
    FProgressPanel.Visible := True;
  end;
  FProgressPanel.FProgressBar.Position := Percent;
  FProgressPanel.FLabelTimePassed.Caption := EhLibLanguageConsts.ElapsedTimeEh + ' - ' + FormatDateTime('NN:SS', ElapsedTime / 86400000);
  FProgressPanel.Repaint;
end;

procedure TCustomPivotGridEh.HideProgressPanel;
begin
  FProgressPanel.Visible := False;
  FProgressPanel.Repaint;
end;

function TCustomPivotGridEh.IsShowHintStored: Boolean;
begin
  Result := not ParentShowHint;
end;

procedure TCustomPivotGridEh.SetShowHint(const Value: Boolean);
begin
  if (FShowHint <> Value) or not IsShowHintStored then
  begin
    FShowHint := Value;
    inherited ShowHint := Value or ShowToolTips;
    ParentShowHint := False;
  end;
end;

procedure TCustomPivotGridEh.SetShowToolTips(const Value: Boolean);
begin
  if FShowToolTips <> Value then
  begin
    FShowToolTips := Value;
    if Value then
    begin
      inherited ShowHint := True;
      ParentShowHint := False;
    end;
  end;
  FShowToolTips := Value;
end;

procedure TCustomPivotGridEh.InternalSetColWidth(ACol, AWidth: Integer);
begin
  FInternalCellSizeSetting := True;
  try
    ColWidths[ACol] := AWidth;
  finally
    FInternalCellSizeSetting := False;
  end;
end;

procedure TCustomPivotGridEh.InternalSetRowHeight(ARow, AHeight: Integer);
begin
  FInternalCellSizeSetting := True;
  try
    RowHeights[ARow] := AHeight;
  finally
    FInternalCellSizeSetting := False;
  end;
end;

procedure TCustomPivotGridEh.CelLenChanged(Axis: TGridAxisDataEh; Index,
  OldLen: Integer);
var
  BaseColRec: TMemoryRecordEh;
begin
  inherited CelLenChanged(Axis, Index, OldLen);
  if (Axis = HorzAxis) and
      not FInternalCellSizeSetting
  then
  begin
    if (Index < ActualRowFields.Count) and
       (ColWidths[Index] > 2)
    then
    begin
      if (ActualRowFields.Objects[Index] <> nil) then
        TPivotFieldEh(ActualRowFields.Objects[Index]).DisplayWidth := ColWidths[Index];
    end else if (Index - FixedColCount >= 0) and
                (Index - FixedColCount < ColsAxisTree.FlatListCount) then
    begin
      BaseColRec := ColsAxisTree.FlatList[Index - FixedColCount].RefBaseAxisTableRec;
      BaseColRec.Value[ActualColFieldCount+1, dvvValueEh] := ColWidths[Index];
    end;
  end;
  GridLayoutChanged;
end;

procedure TCustomPivotGridEh.InteractiveSetColWidth(ColIndex, Value: Integer);
var
  NewColWidth: Integer;
begin
  NewColWidth := ColWidths[ColIndex];
  inherited InteractiveSetColWidth(ColIndex, Value);
  if (NewColWidth <> ColWidths[ColIndex]) then
    AdjustContraData;
end;

function TCustomPivotGridEh.GetIsMultiValuesInRowsAxis: Boolean;
begin
  Result := pgoMultiValuesInRowsAxisEh in Options;
end;

{ TPivotCellDetailsEh }

function TPivotCellDetailsEh.GetDisplayFont(APivotCell: TPivotCellEh;
  AGrid: TCustomPivotGridEh; ACol, ARow: Integer): TFont;
begin
  Result := APivotCell.GetDefaultDisplayFont(AGrid, ACol, ARow);
end;

function TPivotCellDetailsEh.GetDisplayText(APivotCell: TPivotCellEh;
  AGrid: TCustomPivotGridEh; ACol, ARow: Integer): String;
begin
  Result := APivotCell.GetDefaultDisplayText(AGrid, ACol, ARow);
end;

function TPivotCellDetailsEh.GetFillColor(APivotCell: TPivotCellEh;
  AGrid: TCustomPivotGridEh; ACol, ARow: Integer): TColor;
begin
  Result := APivotCell.GetDefaultFillColor(AGrid, ACol, ARow);
end;

{ TPCAxisValueDetailsEh }

function TPCAxisValueDetailsEh.GetDisplayFont(APivotCell: TPivotCellEh;
  AGrid: TCustomPivotGridEh; ACol, ARow: Integer): TFont;
begin
  if (AxisCellSubType in [acstTotalFirstCellEh, acstTotalNextCellEh])
  then
    Result := AGrid.GridCellParams.AxisAggregateFont
  else
    Result := AGrid.GridCellParams.AxisFont;
end;

function TPCAxisValueDetailsEh.GetDisplayText(APivotCell: TPivotCellEh;
  AGrid: TCustomPivotGridEh; ACol, ARow: Integer): String;
begin
  if (AxisCellType = actUndefinedEh) and
     (AxisCellSubType = acstTotalFirstCellEh) then
  begin
    Result := EhLibLanguageConsts.GrandTotalEh;
  end else
  begin
    Result := '';

    if APivotCell.ShowValue and
      (PivotField <> nil) and
      (APivotCell.VertAggrLevelRow < AGrid.ActualRowFields.Count) and
      (APivotCell.HorzAggrLevelCol < AGrid.ActualColFields.Count)
    then
      Result := PivotField.ValueAsDisplayText(APivotCell.Value);

    if (AxisCellSubType = acstTotalFirstCellEh) then
    begin
      if (AxisTreeNode <> nil) and
         (AxisTreeNode.Expanded)
      then
        Result := EhLibLanguageConsts.TotalEh
      else
        Result := Result + ' ' + EhLibLanguageConsts.TotalEh;
    end;
  end;
end;

{ TPCValCaptionInAxisDetailsEh }

function TPCValCaptionInAxisDetailsEh.GetDisplayText(APivotCell: TPivotCellEh;
  AGrid: TCustomPivotGridEh; ACol, ARow: Integer): String;
begin
  Result := inherited GetDisplayText(APivotCell, AGrid, ACol, ARow);
end;

{ TPivotDataCellDetailsEh }

function TPivotDataCellDetailsEh.GetDisplayText(APivotCell: TPivotCellEh;
  AGrid: TCustomPivotGridEh; ACol, ARow: Integer): String;

  function GetStrValue(SFValueInfo: TPivotFieldValueInfoEh; const Val: Variant): String;
  begin
    if VarIsNull(Val) then
      Result := ''
    else if (SFValueInfo.DisplayFormat <> '') then
      Result := FormatFloat(SFValueInfo.DisplayFormat, Val)
    else if SFValueInfo.SumFunction = svtCountEh then
      Result := FloatToStr(Val)
    else
      Result := FormatFloat('#,##0.00', Val)
  end;

var
  ls: String;
begin
  ls := '';
  if APivotCell.ShowValue then
  begin
    if not VarIsNull(APivotCell.Value) then
    begin
      if AGrid.ActualValueFields.Count > 0 then
        Result := GetStrValue(AGrid.ActualValueFields[0], APivotCell.Value)
      else
        Result := FormatFloat('#,##0.00', APivotCell.Value);
    end else
      Result := '';
  end else
    Result := '';
end;

{ TPivotCellEh }

constructor TPivotCellEh.Create;
begin
  inherited Create;
  FCellDetails := TPCEmptyDetailsEh.Create;
end;

destructor TPivotCellEh.Destroy;
begin
  FreeAndNil(FCellDetails);
  inherited Destroy;
end;

function TPivotCellEh.GetCelType: TPivotCelTypeEh;
begin
  Result := FCelType;
end;

procedure TPivotCellEh.SetCelType(const Value: TPivotCelTypeEh);
const
  PivotCelTypeDetailsClass: array [TPivotCelTypeEh] of TClass = (
  
  TPCEmptyDetailsEh, TPCFieldNameForRowDetailsEh, TPCFieldNameForColDetailsEh,
  
  TPCRowsAxisValueDetailsEh, TPCColsAxisValueDetailsEh,
  
  TPivotDataCellDetailsEh, TPivotDataCellDetailsEh, TPivotDataCellDetailsEh,
  
  TPCValCaptionInAxisDetailsEh, TPCValCaptionInAxisDetailsEh
  );
begin
  if (FCelType <> Value) then
  begin
    FCelType := Value;
    FCellDetails.Free;
    FCellDetails := TPCEmptyDetailsEhClass(PivotCelTypeDetailsClass[FCelType]).Create;
  end;
end;

procedure TPivotCellEh.Clear;
begin
  CelType := sctEmptyEh;
  Value := Unassigned;
  DrawDownLine := True;
  DrawRightLine := True;
  HorzAggrLevelCol := 0;
  HorzAggrLevelRow := 0;
  VertAggrLevelCol := 0;
  VertAggrLevelRow := 0;
  ShowValue := True;
end;

function TPivotCellEh.GetEmptyDetails: TPCEmptyDetailsEh;
begin
  if (CelType = sctEmptyEh)
    then Result := TPCEmptyDetailsEh(CellDetails)
    else Result := nil;
end;

function TPivotCellEh.GetFieldNameDetails: TPCFieldNameDetailsEh;
begin
  if (CelType in [sctFieldNameForColEh, sctFieldNameForRowEh] )
    then Result := TPCFieldNameDetailsEh(CellDetails)
    else Result := nil;
end;

function TPivotCellEh.GetFieldNameForColDetails: TPCFieldNameForColDetailsEh;
begin
  if (CelType = sctFieldNameForColEh)
    then Result := TPCFieldNameForColDetailsEh(CellDetails)
    else Result := nil;
end;

function TPivotCellEh.GetFieldNameForRowDetails: TPCFieldNameForRowDetailsEh;
begin
  if (CelType = sctFieldNameForRowEh)
    then Result := TPCFieldNameForRowDetailsEh(CellDetails)
    else Result := nil;
end;

function TPivotCellEh.GetAxisValueDetails: TPCAxisValueDetailsEh;
begin
  if (CelType in [sctRowsAxisValueEh, sctColsAxisValueEh] )
    then Result := TPCAxisValueDetailsEh(CellDetails)
    else Result := nil;
end;

function TPivotCellEh.GetRowsAxisValueDetails: TPCRowsAxisValueDetailsEh;
begin
  if (CelType = sctRowsAxisValueEh)
    then Result := TPCRowsAxisValueDetailsEh(CellDetails)
    else Result := nil;
end;

function TPivotCellEh.GetColsAxisValueDetails: TPCColsAxisValueDetailsEh;
begin
  if (CelType = sctColsAxisValueEh)
    then Result := TPCColsAxisValueDetailsEh(CellDetails)
    else Result := nil;
end;

function TPivotCellEh.GetDefaultDisplayText(AGrid: TCustomPivotGridEh; ACol, ARow: Integer): String;
begin
  if ShowValue then
    Result := VarToStr(Value)
  else
    Result := '';
end;

function TPivotCellEh.GetDisplayText(AGrid: TCustomPivotGridEh; ACol, ARow: Integer): String;
begin
  if CellDetails <> nil then
    Result := CellDetails.GetDisplayText(Self, AGrid, ACol, ARow)
  else
    Result := GetDefaultDisplayText(AGrid, ACol, ARow);
end;

function TPivotCellEh.GetDisplayFont(AGrid: TCustomPivotGridEh; ACol, ARow: Integer): TFont;
begin
  if CellDetails <> nil then
    Result := CellDetails.GetDisplayFont(Self, AGrid, ACol, ARow)
  else
    Result := GetDefaultDisplayFont(AGrid, ACol, ARow);
end;

function TPivotCellEh.GetDefaultDisplayFont(AGrid: TCustomPivotGridEh; ACol, ARow: Integer): TFont;
begin
  Result := AGrid.Font;
end;

function TPivotCellEh.GetFillColor(AGrid: TCustomPivotGridEh; ACol, ARow: Integer): TColor;
begin
  if CellDetails <> nil then
    Result := CellDetails.GetFillColor(Self, AGrid, ACol, ARow)
  else
    Result := GetDefaultFillColor(AGrid, ACol, ARow);
end;

function TPivotCellEh.GetDefaultFillColor(AGrid: TCustomPivotGridEh; ACol, ARow: Integer): TColor;
begin
  if (ACol < AGrid.FixedColCount) or (ARow < AGrid.FixedRowCount)
    then Result := AGrid.FixedColor
    else Result := AGrid.Color;
end;

{ TPivotFieldEh }

constructor TPivotFieldEh.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FTypeDef := TPivotFieldDataTypeDefEh.Create;
  FKeyValueStates := TPivotKeyValueStatesEh.Create(Self, TPivotKeyValueStateEh);
  FSumFunction := svtCountEh;
end;

destructor TPivotFieldEh.Destroy;
begin
  FreeAndNil(FTypeDef);
  FreeAndNil(FKeyValueStates);
  inherited Destroy;
end;

function TPivotFieldEh.GetDisplayName: String;
begin
  if FDisplayName = ''
    then Result := FieldName
    else Result := FDisplayName;
end;

procedure TPivotFieldEh.SetDisplayName(const Value: String);
begin
  if FDisplayName <> Value then
  begin
    FDisplayName := Value;
    DisplayDefinitionChanged;
  end;
end;

function TPivotFieldEh.IsDisplayNameStored: Boolean;
begin
  Result := (FieldName <> DisplayName);
end;

procedure TPivotFieldEh.SetDisplayFormat(const Value: String);
begin
  if FDisplayFormat <> Value then
  begin
    FDisplayFormat := Value;
    Changed(False);
  end;
end;

procedure TPivotFieldEh.SetFieldName(const Value: String);
begin
  if FFieldName <> Value then
  begin
    FFieldName := Value;
    Changed(False);
  end;
end;

function TPivotFieldEh.GetValueForSource(SourceDataSet: TDataSet; Field: TField): Variant;
var
  DataValue: TDateTime;
  AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond: Word;
  AWeekOfYear, ADayOfWeek: Word;
begin
  if Field <> nil then
  begin
    if (SourceDataSet is TMemTableEh) and (Field.FieldNo > 0) then
      Result := TMemTableEh(SourceDataSet).Rec.Value[Field.FieldNo-1, dvvValueEh]
    else
      Result := Field.Value;
  end else
    Result := Null;

  if (SliceLevel <> dtslNonEh) and not VarIsNull(Result) then
  begin
    DataValue := VarToDateTime(Result);

    if SliceLevel = dtslWeekEh  then
    begin
      DecodeDateWeek(DataValue, AYear, AWeekOfYear, ADayOfWeek);
      Result := EncodeDateWeek(AYear, AWeekOfYear, 1);
    end else
    begin
      DecodeDateTime(DataValue, AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond);
      case SliceLevel of
        dtslYearEh:
        begin
          AMonth := 1;
          ADay := 1;
          AHour := 0;
          AMinute := 0;
          ASecond := 0;
          AMilliSecond := 0;
        end;
        dtslMonthEh:
        begin
          ADay := 1;
          AHour := 0;
          AMinute := 0;
          ASecond := 0;
          AMilliSecond := 0;
        end;
        dtslDayEh:
        begin
          AHour := 0;
          AMinute := 0;
          ASecond := 0;
          AMilliSecond := 0;
        end;
        dtslHourEh:
        begin
          AMinute := 0;
          ASecond := 0;
          AMilliSecond := 0;
        end;
        dtslMinEh:
        begin
          ASecond := 0;
          AMilliSecond := 0;
        end;
        dtslMSecEh:
        begin
          AMilliSecond := 0;
        end;
      end;
      Result := EncodeDateTime(AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond);
    end;
  end;
end;

function TPivotFieldEh.StringToDataValue(const StringValue: String): Variant;
var
  ft: TFieldType;
begin
  if StringValue = '' then
    Result := Null
  else
  begin
    ft := GetDataFieldType;
    {$IFDEF FPC}
    VarCast(Result, StringValue, FieldTypeToVariantMap[ft]);
    {$ELSE}
    VarCast(Result, StringValue, FieldTypeVarMap[ft]);
    {$ENDIF}
  end;
end;

function TPivotFieldEh.SysStringToDataValue(const StringValue: String): Variant;
var
  ft: TFieldType;
begin
  if StringValue = '' then
    Result := Null
  else
  begin
    ft := GetDataFieldType;
    {$IFDEF FPC}
    Result := SysStrToVar(StringValue, FieldTypeToVariantMap[ft]);
    {$ELSE}
    Result := SysStrToVar(StringValue, FieldTypeVarMap[ft]);
    {$ENDIF}
  end;
end;

function TPivotFieldEh.GetDataFieldType: TFieldType;
var
  Field: TField;
begin
  if (TypeDef.DataType <> ftUnknown) then
    Result := TypeDef.DataType
  else if (SourceFieldName <> '') and (PivotFields.PDSource.DataSet <> nil) then
  begin
    Field := PivotFields.PDSource.DataSet.FindField(SourceFieldName);
    Result := Field.DataType;
  end else
    raise Exception.Create('GetDataFieldType is not Defined');
end;

function TPivotFieldEh.GetPivotFields: TPivotFieldsEh;
begin
  Result := TPivotFieldsEh(Collection);
end;

procedure TPivotFieldEh.InternalSetExpressionStr(const Value: String);
begin
  ParseExpression(Value);
  FExpressionStr := Value;
end;

function TPivotFieldEh.ParseExpression(const Exp: String): String;
var
  DefaultOperator: TSTFilterDefaultOperatorEh;
begin
  Result := '';
  if FieldName <> ''
    then FExpression.ExpressionType := STFldTypeMapEh[PivotFields.PDSource.BaseTable.FieldByName(FieldName).DataType]
    else FExpression.ExpressionType := botNon;
  DefaultOperator := fdoAuto;

  ParseSTFilterExpressionEh(Exp, FExpression, DefaultOperator);
end;

procedure TPivotFieldEh.ClearExpression();
var
  i: Integer;
begin
  FExpression.ExpressionType := botNon;
  FExpression.Operator1 := foNon;
  FExpression.Operand1 := Null;
  FExpression.Relation := foNon;
  FExpression.Operator2 := foNon;
  FExpression.Operand2 := Null;

  if KeyValueStates.HaveHiddenKeys then
  begin
    KeyValueStates.BeginUpdate;
    try
      for i := 0 to KeyValueStates.Count - 1 do
        KeyValueStates.Items[i].Visible := True;
    finally
      KeyValueStates.EndUpdate;
      KeyValueStates.UpdateHaveHiddenKeysProp;
    end;
  end;
end;

procedure TPivotFieldEh.FillFilterValues(Items: TStrings);
var
  i: Integer;
  IntMemTable: IMemTableEh;
begin
  if not Supports(PivotFields.PDSource.BaseTable, IMemTableEh, IntMemTable) then Exit;
  for i := 0 to KeyValueStates.Count - 1 do
    Items.AddObject(VarToStr(KeyValueStates.Items[i].KeyValue), nil);

  SetLength(FListValuesCheckingState, 0);
  SetLength(FListValuesCheckingState, Items.Count);
end;

procedure TPivotFieldEh.UpdateFilterFromValuesCheckingState(ss: TStrings;
  CheckStates: TBooleanDynArray);
var
  FilterStr: String;
  i,k: Integer;
  DataOpType: TSTOperandTypeEh;
  sv: String;
  IncludeCheckNull: Boolean;
begin
  k := 0;
  FilterStr := '';
  IncludeCheckNull := False;
  if FieldName <> ''
    then DataOpType := STFldTypeMapEh[PivotFields.PDSource.BaseTable.FieldByName(FieldName).DataType]
    else DataOpType := botNon;

  for i := 0 to Length(CheckStates)-1 do
  begin
    if ss.Objects[i] is TDDFormListboxItemEhData then
    begin
      if CheckStates[i] = True then
      begin
        sv := StringReplace(ss[i], '''', '''''',[rfReplaceAll]);
        if (DataOpType in [botNumber, botDateTime, botBoolean]) and (sv = '') then
        begin
          IncludeCheckNull := True;
        end else
        begin
          if FilterStr <> '' then FilterStr := FilterStr + ',';
          FilterStr := FilterStr + '''' + sv + '''';
          Inc(k);
        end;
      end;
    end;
  end;
  if FilterStr <> '' then
    if k = 1
      then FilterStr := '=' + FilterStr
      else FilterStr := 'in (' + FilterStr + ')';
  if IncludeCheckNull then
    if FilterStr = ''
      then FilterStr := '=Null'
      else FilterStr := FilterStr + ' OR =Null ';
  InternalSetExpressionStr(FilterStr);

  UpdateKeyValueStatesFromFilterCheckedState(ss, CheckStates);
end;

procedure TPivotFieldEh.UpdateKeyValueStatesFromFilterCheckedState(AStrList: TStrings;
  CheckStates: TBooleanDynArray);
var
  i: Integer;
  HaveVisible: Boolean;
begin
  KeyValueStates.BeginUpdate;
  try
    HaveVisible := False;
    for i := 0 to AStrList.Count-1 do
    begin
      if CheckStates[i] then
      begin
        HaveVisible := True;
        Break;
      end;
    end;

    if HaveVisible = False then
    begin
      for i := 0 to AStrList.Count-1 do
        KeyValueStates.Items[i].Visible := True
    end else
    begin
      for i := 0 to AStrList.Count-1 do
        KeyValueStates.Items[i].Visible := CheckStates[i];
    end;
  finally
    KeyValueStates.EndUpdate;
    KeyValueStates.UpdateHaveHiddenKeysProp;
  end;
end;

procedure TPivotFieldEh.UpdateValuesCheckingStateFromFilter(ss: TStrings;
  CheckStates: TBooleanDynArray);
var
  i: Integer;
  KeyAsStr: String;
begin
  if KeyValueStates.HaveHiddenKeys then
  begin
    for i := 0 to KeyValueStates.Count-1 do
    begin
      KeyAsStr := VarToStr(KeyValueStates[i].KeyValue);
      if (i < ss.Count) and (KeyAsStr = ss[i]) then
        CheckStates[i] := KeyValueStates[i].Visible;
    end;
  end;
end;

procedure TPivotFieldEh.SetExpression(const Value: TSTFilterExpressionEh);
begin
  FExpression := Value;
end;

function TPivotFieldEh.GetExpression: TSTFilterExpressionEh;
begin
  Result := FExpression;
end;

function TPivotFieldEh.GetFilterExpressionAsStr: String;
var
  i: Integer;
  FilterStr, sv:  String;
  IncludeCheckNull: Boolean;
  k: Integer;
begin
  if not KeyValueStates.HaveHiddenKeys then
  begin
    Result := '';
    Exit;
  end;

  k := 0;
  FilterStr := '';
  IncludeCheckNull := False;
  for i := 0 to KeyValueStates.Count-1 do
  begin
    if KeyValueStates.Items[i].Visible then
    begin
      sv := VarToStr(KeyValueStates.Items[i].KeyValue);
      sv := StringReplace(sv, '''', '''''',[rfReplaceAll]);
      if (sv = '') then
      begin
        IncludeCheckNull := True;
      end else
      begin
        if FilterStr <> '' then FilterStr := FilterStr + ',';
        FilterStr := FilterStr + '''' + sv + '''';
        Inc(k);
      end;
    end;
  end;

  if FilterStr <> '' then
    if k = 1
      then FilterStr := '['+FieldName+']' + ' = ' + FilterStr
      else FilterStr := '['+FieldName+']' + 'in (' + FilterStr + ')';
  if IncludeCheckNull then
    if FilterStr = ''
      then FilterStr := '['+FieldName+'] ' + ' = Null'
      else FilterStr := FilterStr + ' OR ' + '['+FieldName+']' +  ' = Null ';

  Result := FilterStr;
end;

function TPivotFieldEh.ValueAsDisplayText(const Value: Variant): String;
var
  dtValue: TDateTime;
begin
  if (DisplayFormat = '') or VarIsNull(Value) then
    Result := VarToStr(Value)
  else
  begin
    dtValue := VarToDateTime(Value);
    Result := FormatDateTime(DisplayFormat, dtValue);
    if SliceLevel = dtslWeekEh then
      Result := StringReplace(Result, 'WW',
        FormatFloat('00', WeekOfTheYear(dtValue)), [rfReplaceAll, rfIgnoreCase]);
  end;
end;

procedure TPivotFieldEh.SetNextSortOrder;
begin
  if SortOrder = soAscEh
    then SortOrder := soDescEh
    else SortOrder := soAscEh;
end;

procedure TPivotFieldEh.SetSortOrder(const Value: TSortOrderEh);
begin
  if FSortOrder <> Value then
  begin
    FSortOrder := Value;
  end;
end;

function TPivotFieldEh.ProposedSumFunction: TPivotValueTypeEh;
begin
  Result := SumFunction;
end;

function TPivotFieldEh.GetSumFunction: TPivotValueTypeEh;
begin
  if SumFunctionStored
    then Result := FSumFunction
    else Result := DefaultSumFunction;
end;

procedure TPivotFieldEh.SetSumFunction(const Value: TPivotValueTypeEh);
begin
  if SumFunctionStored and (Value = FSumFunction) then Exit;
  SumFunctionStored := True;
  FSumFunction := Value;
end;

function TPivotFieldEh.DefaultSumFunction: TPivotValueTypeEh;
var
  Field: TField;
  Summable: Boolean;
begin
  Result := svtCountEh;
  if TypeDef.DataType <> ftUnknown then
  begin
    Summable := IsFieldTypeNumeric(TypeDef.DataType) or (TypeDef.DataType = ftBoolean);
    if Summable
      then Result := svtSumEh
      else Result := svtCountEh;
  end else if PivotFields.PDSource.DataSet <> nil then
  begin
    Field := PivotFields.PDSource.DataSet.FindField(SourceFieldName);
    Summable := (Field is TNumericField) or (Field is TBooleanField);
    if Summable
      then Result := svtSumEh
      else Result := svtCountEh;
  end;
end;

function TPivotFieldEh.IsSumFunctionStored: Boolean;
begin
  Result := FSumFunctionStored;
end;

procedure TPivotFieldEh.SetSumFunctionStored(const Value: Boolean);
begin
  if FSumFunctionStored <> Value then
  begin
    FSumFunctionStored := Value;
    FSumFunction := DefaultSumFunction;
  end;
end;

procedure TPivotFieldEh.SetTypeDef(const Value: TPivotFieldDataTypeDefEh);
begin
  FTypeDef.Assign(Value);
end;

function TPivotFieldEh.GetKeyValueStates: TPivotKeyValueStatesEh;
begin
  Result := FKeyValueStates;
end;

procedure TPivotFieldEh.UpdateKeyValueStates;
begin
  FKeyValueStates.UpdateData(PivotFields.PDSource.SourceTable);
end;

procedure TPivotFieldEh.DisplayDefinitionChanged;
begin
  PivotFields.DisplayDefinitionChanged;
end;

{ TPivotFieldsEh }

constructor TPivotFieldsEh.Create(APDSource: TPivotDataSourceEh; AClass: TPivotFieldEhClass);
begin
  inherited Create(AClass);
  FPDSource := APDSource;
end;

function TPivotFieldsEh.Add: TPivotFieldEh;
begin
  Result := TPivotFieldEh(inherited Add);
end;

procedure TPivotFieldsEh.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
end;

function TPivotFieldsEh.GetOwner: TPersistent;
begin
  Result := FPDSource;
end;

function TPivotFieldsEh.GetPivotField(Index: Integer): TPivotFieldEh;
begin
  Result := TPivotFieldEh(inherited Items[Index]);
end;

procedure TPivotFieldsEh.SetPivotField(Index: Integer; Value: TPivotFieldEh);
begin
  Items[Index] := Value;
end;

procedure TPivotFieldsEh.Notify(Item: TCollectionItem; Action: TCollectionNotification);
begin
  inherited Notify(Item, Action);
end;

procedure TPivotFieldsEh.AddAllPivotFields(DeleteExisting: Boolean);
var
  i: Integer;
  fList: TStringList;
  APivotField: TPivotFieldEh;
  SliceLevel: TFieldDateTimeSliceLevelEh;
  AField: TField;
begin
  BeginUpdate;
  try
  if DeleteExisting then
    Clear;
  if PDSource.DataSet <> nil then
  begin
    fList := TStringList.Create;
    try
    PDSource.DataSet.GetFieldNames(fList);
    for i := 0 to fList.Count-1 do
    begin
      APivotField := Add;
      APivotField.SourceFieldName := fList[i];
      APivotField.FieldName := fList[i];
      AField := PDSource.DataSet.FieldByName(fList[i]);
      if AField <> nil then
        APivotField.DisplayName := AField.DisplayLabel;
      if (AField <> nil) and (AField.DataType in [ftDate, ftDateTime]) then
      begin
        for SliceLevel := dtslNonEh to dtslMSecEh do
        begin
          if SliceLevel in PDSource.DefaultDateTimeSliceLevels then
          begin
            APivotField := Add;
            APivotField.SourceFieldName := fList[i];
            APivotField.SliceLevel := SliceLevel;
            APivotField.FieldName := APivotField.SourceFieldName + '.' + SliceNames[SliceLevel];
            APivotField.DisplayName := AField.DisplayName + '.' + SliceDisplayNames[SliceLevel];
            APivotField.DisplayFormat := SliceNamesDisplayFormat[SliceLevel];
          end;
        end;
      end;
    end;
    finally
      fList.Free;
    end;
  end;
  finally
    EndUpdate;
  end;
end;

procedure TPivotFieldsEh.RebuildPivotFields;
begin
  AddAllPivotFields(True);
end;

procedure TPivotFieldsEh.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  PDSource.PivotFieldsChanged;
end;

procedure TPivotFieldsEh.DisplayDefinitionChanged;
begin
  if UpdateCount = 0  then
    PDSource.PivotFieldsDisplayChanged;
end;

function TPivotFieldsEh.FindFieldByName(const PivotFieldName: String): TPivotFieldEh;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Count-1 do
  begin
    if AnsiCompareText(Items[i].FieldName, PivotFieldName) = 0 then
    begin
      Result := Items[i];
      Exit;
    end;
  end;
end;

function TPivotFieldsEh.IndexOf(APivotField: TPivotFieldEh): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Count-1 do
  begin
    if APivotField = Items[i] then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

{ TPivotGridFilterPopupListboxItemEh }

function TPivotGridFilterPopupListboxItemEh.GetGrid(
  Listbox: TCustomListboxEh): TCustomPivotGridEh;
begin
  if Listbox.Owner is TCustomPivotGridEh
    then Result := TCustomPivotGridEh(Listbox.Owner)
    else Result := nil;
end;

function TPivotGridFilterPopupListboxItemEh.GetPivotField(
  Listbox: TCustomListboxEh): TPivotFieldEh;
begin
  if Listbox.Owner is TCustomPivotGridEh
    then Result := TCustomPivotGridEh(Listbox.Owner).FInTitleFilterPivotField
    else Result := nil;
end;

{ TPopupListboxItemEhData }

function TPopupListboxItemEhData.CanFocus(Sender: TCustomListboxEh; ItemIndex: Integer): Boolean;
begin
  Result := False;
end;

function TPopupListboxItemEhData.CloseOnExecute(Sender: TCustomListboxEh; ItemIndex: Integer): Boolean;
begin
  Result := False;
end;

procedure TPopupListboxItemEhData.DrawItem(Sender: TCustomListboxEh;
  ItemIndex: Integer; ARect: TRect; State: TGridDrawState);
var
  CBRect: TRect;
  MouseIndex: Integer;
  OldRight: Integer;
  CBState: TCheckBoxState;
  IsActive: Boolean;
  PivotField: TPivotFieldEh;
begin
  MouseIndex := Sender.ItemAtPos(Sender.ScreenToClient(SafeGetMouseCursorPos), True);
  PivotField := GetPivotField(Sender);
  if PivotField.FListValuesCheckingState[ItemIndex] = True
    then CBState := cbChecked
    else CBState := cbUnchecked;
  IsActive := (MouseIndex >= 0) and (MouseIndex = ItemIndex) and (Mouse.Capture = 0);
  CBRect := Rect(ARect.Left, ARect.Top, ARect.Left + Sender.DefaultCheckBoxWidth, ARect.Bottom);
  if Sender.UseRightToLeftAlignment then
  begin
    OldRight := CBRect.Right;
    CBRect.Right := Sender.ClientWidth - CBRect.Left;
    CBRect.Left := Sender.ClientWidth - OldRight;
  end;
  PaintButtonControlEh(Sender.Canvas, CBRect, Sender.Canvas.Brush.Color,
    bcsCheckboxEh, 0, True, IsActive {odFocused in State}, True, CBState);

  if Sender.UseRightToLeftAlignment
    then ARect.Right := ARect.Right - Sender.DefaultCheckBoxWidth - 2
    else ARect.Left := ARect.Left + Sender.DefaultCheckBoxWidth + 2;
  Sender.DefaultDrawItem(ItemIndex, ARect, State);
end;

procedure TPopupListboxItemEhData.Execute(Sender: TCustomListboxEh;
  ItemIndex: Integer; InItemPos: TPoint; Shift: TShiftState);
begin
  Sender.InvalidateIndex(ItemIndex);
end;

procedure TPopupListboxItemEhData.KeyPress(Sender: TCustomListboxEh;
  ItemIndex: Integer; var Key: Char; Shift: TShiftState;
  var IsCloseListbox: Boolean);
begin
  inherited KeyPress(Sender, ItemIndex, Key, Shift, IsCloseListbox);
end;

procedure TPopupListboxItemEhData.MouseDown(Sender: TCustomListboxEh;
  ItemIndex: Integer; InItemPos: TPoint; Button: TMouseButton;
  Shift: TShiftState);
var
  PivotField: TPivotFieldEh;
begin
  PivotField := GetPivotField(Sender);
  PivotField.FPopupListboxDownIndex := ItemIndex;
  Sender.InvalidateIndex(ItemIndex);
end;

procedure TPopupListboxItemEhData.MouseMove(Sender: TCustomListboxEh;
  ItemIndex: Integer; InItemPos: TPoint; Shift: TShiftState);
var
  PivotField: TPivotFieldEh;
begin
  PivotField := GetPivotField(Sender);
  if (PivotField.FPopupListboxDownIndex >= 0) and
     (PivotField.FPopupListboxDownIndex <> ItemIndex) then
  begin
    Sender.InvalidateIndex(PivotField.FPopupListboxDownIndex);
    PivotField.FPopupListboxDownIndex := -1;
  end;
end;

procedure TPopupListboxItemEhData.MouseUp(Sender: TCustomListboxEh;
  ItemIndex: Integer; InItemPos: TPoint; Button: TMouseButton;
  Shift: TShiftState; var IsCloseListbox: Boolean);
var
  MousePos: TPoint;
  Index: Integer;
  PivotField: TPivotFieldEh;
begin
  PivotField := GetPivotField(Sender);
  if PivotField.FPopupListboxDownIndex = ItemIndex then
  begin
    Execute(Sender, ItemIndex, InItemPos, Shift);
    MousePos := Sender.ScreenToClient(SafeGetMouseCursorPos);
    Index := Sender.ItemAtPos(MousePos, True);
    if Index < Sender.Items.Count then Sender.ItemIndex := Index;
  end;
  if PivotField <> nil then
    PivotField.FPopupListboxDownIndex := -1;
  Sender.InvalidateIndex(ItemIndex);
  IsCloseListbox := False;
end;

{ TPopupListboxItemEhSpec }

constructor TPopupListboxItemEhSpec.Create(AType: TPopupListboxItemEhSpecType);
begin
  inherited Create;
  FType := AType;
end;

function TPopupListboxItemEhSpec.CanFocus(Sender: TCustomListboxEh;
  ItemIndex: Integer): Boolean;
begin
  Result := False;
end;

procedure TPopupListboxItemEhSpec.DrawItem(Sender: TCustomListboxEh;
  ItemIndex: Integer; ARect: TRect; State: TGridDrawState);
var
  CBRect: TRect;
  OldColor: TColor;
  OldRight: Integer;
  CBState: TCheckBoxState;
begin
  if FType = ptFilterRowLine then
  begin
    Sender.Canvas.Pen.Color := StyleServices.GetSystemColor(clSilver);
    Sender.Canvas.Polyline([Point(ARect.Left, (ARect.Bottom+ARect.Top) div 2),
                          Point(ARect.Right,(ARect.Bottom+ARect.Top) div 2)]);
  end
  else if FType = ptFilterSpecSelectAll then
  begin
    CBState := cbUnchecked;
    CBRect := Rect(ARect.Left, ARect.Top, ARect.Left + Sender.DefaultCheckBoxWidth, ARect.Bottom);
    if Sender.UseRightToLeftAlignment then
    begin
      OldRight := CBRect.Right;
      CBRect.Right := Sender.ClientWidth - CBRect.Left;
      CBRect.Left := Sender.ClientWidth - OldRight;
    end;
    PaintButtonControlEh(Sender.Canvas, CBRect, Sender.Canvas.Brush.Color,
      bcsCheckboxEh, 0, True, False, True, CBState);

    if Sender.UseRightToLeftAlignment
      then ARect.Right := ARect.Right - Sender.DefaultCheckBoxWidth - 2
      else ARect.Left := ARect.Left + Sender.DefaultCheckBoxWidth + 2;
    Sender.DefaultDrawItem(ItemIndex, ARect, State);
  end else
  begin
    OldColor := Sender.Canvas.Brush.Color;
    Sender.Canvas.FillRect(Rect(ARect.Left, ARect.Top, ARect.Left + Sender.DefaultCheckBoxWidth + 2, ARect.Bottom));
    Sender.Canvas.Brush.Color := OldColor;
    ARect.Left := ARect.Left + Sender.DefaultCheckBoxWidth + 2;
    Sender.DefaultDrawItem(ItemIndex, ARect, State);
  end;

end;

procedure TPopupListboxItemEhSpec.Execute(Sender: TCustomListboxEh;
  ItemIndex: Integer; InItemPos: TPoint; Shift: TShiftState);
var
  PivotField: TPivotFieldEh;
begin
  PivotField := GetPivotField(Sender);
  PivotField.PivotFields.PDSource.SetDataFilter;
end;

procedure TPopupListboxItemEhSpec.MouseDown(Sender: TCustomListboxEh;
  ItemIndex: Integer; InItemPos: TPoint; Button: TMouseButton;
  Shift: TShiftState);
var
  PivotField: TPivotFieldEh;
begin
  PivotField := GetPivotField(Sender);
  PivotField.FPopupListboxDownIndex := ItemIndex;
  Sender.InvalidateIndex(ItemIndex);
end;

procedure TPopupListboxItemEhSpec.MouseUp(Sender: TCustomListboxEh;
  ItemIndex: Integer; InItemPos: TPoint; Button: TMouseButton;
  Shift: TShiftState; var IsCloseListbox: Boolean);
var
  MousePos: TPoint;
  Index: Integer;
  PivotField: TPivotFieldEh;
  AllIsSelected: Boolean;
  i: Integer;
begin
  PivotField := GetPivotField(Sender);
  if FType = ptFilterSpecSelectAll then
  begin
    AllIsSelected := True;
    for i := 0 to Length(PivotField.FListValuesCheckingState)-1 do
      if Sender.Items.Objects[i] is TPopupListboxItemEhData then
        if not PivotField.FListValuesCheckingState[i] then
        begin
          AllIsSelected := False;
          Break;
        end;

    for i := 0 to Length(PivotField.FListValuesCheckingState)-1 do
      if Sender.Items.Objects[i] is TPopupListboxItemEhData then
        PivotField.FListValuesCheckingState[i] := not AllIsSelected;

    Sender.Invalidate;
  end else if FType = ptFilterApply then
  begin
    if PivotField.FPopupListboxDownIndex = ItemIndex then
    begin
      Execute(Sender, ItemIndex, InItemPos, Shift);
      MousePos := Sender.ScreenToClient(SafeGetMouseCursorPos);
      Index := Sender.ItemAtPos(MousePos, True);
      if Index < Sender.Items.Count then Sender.ItemIndex := Index;
    end;
    if PivotField <> nil then
      PivotField.FPopupListboxDownIndex := -1;
    Sender.InvalidateIndex(ItemIndex);
    IsCloseListbox := True;
  end;
end;

{ TPivotGridDrabObj }

destructor TPivotGridDrabObj.Destroy;
begin
  inherited Destroy;
end;

function TPivotGridDrabObj.GetDragCursor(Accepted: Boolean; X,
  Y: Integer): TCursor;
begin
  Result := inherited GetDragCursor(Accepted, X, Y);
  if Accepted and not (TObject(DragTarget) is TCustomPivotGridEh) then
    if {(Control is TCustomPivotGridEh) and}
       (TObject(DragTarget) is TCustomPivotGridFieldsEh) and
       (TCustomPivotGridFieldsEh(DragTarget).ListType = sgftFieldsListEh)
    then
      Result := hcrDropToGarbageIndexEh;
end;

{ TPivotFieldValueInfoEh }

procedure TPivotFieldValueInfoEh.Assign(Source: TPersistent);
begin
  if Source is TPivotFieldValueInfoEh then
  begin
    PivotField := TPivotFieldValueInfoEh(Source).PivotField;
    DisplayFormat := TPivotFieldValueInfoEh(Source).DisplayFormat;
    SumFunction := TPivotFieldValueInfoEh(Source).SumFunction;
  end else
    inherited Assign(Source);
end;

constructor TPivotFieldValueInfoEh.Create(Collection: TCollection);
begin
  inherited Create(Collection);
end;

destructor TPivotFieldValueInfoEh.Destroy;
begin
  inherited Destroy;
end;

function TPivotFieldValueInfoEh.GetCollection: TValueFieldsCollectionEh;
begin
  Result := TValueFieldsCollectionEh(inherited Collection);
end;

procedure TPivotFieldValueInfoEh.SetDisplayFormat(const Value: String);
begin
  if FDisplayFormat <> Value then
  begin
    FDisplayFormat := Value;
  end;
end;

procedure TPivotFieldValueInfoEh.SetPivotField(const Value: TPivotFieldEh);
begin
  if FPivotField <> Value then
  begin
    FPivotField := Value;
    if FPivotField <> nil then
      FPivotFieldName := FPivotField.FieldName;
    Changed(False);
  end;
end;

procedure TPivotFieldValueInfoEh.SetPivotFieldName(const Value: String);
begin
  if FPivotFieldName <> Value then
  begin
    FPivotFieldName := Value;
    Changed(False);
  end;
end;

procedure TPivotFieldValueInfoEh.SetSumFunction(
  const Value: TPivotValueTypeEh);
begin
  if FSumFunction <> Value then
  begin
    Changed(False);
    FSumFunction := Value;
  end;
end;

function TPivotFieldValueInfoEh.UpdatePivotFieldFromPivotFieldName: TPivotFieldEh;
begin
  if (Collection <> nil) and
     (Collection.PivotDataSource <> nil) and
     (Collection.PivotDataSource.PivotFields <> nil)
  then
    FPivotField := Collection.PivotDataSource.PivotFields.FindFieldByName(PivotFieldName)
  else
    FPivotField := nil;
  Result := FPivotField;
end;

function TPivotFieldValueInfoEh.DisplayDescription: String;
begin
  if (PivotField = nil)
    then Result := PivotFieldName
    else Result := PivotFieldName + ' (' + PivotAggrValueDisplayNames(SumFunction) + ')';
end;

{ TValueFieldsCollectionEh }

constructor TValueFieldsCollectionEh.Create(AClass: TPivotFieldValueInfoEhClass);
begin
  inherited Create(AClass);
end;

function TValueFieldsCollectionEh.Add: TPivotFieldValueInfoEh;
begin
  Result := TPivotFieldValueInfoEh(inherited Add);
end;

procedure TValueFieldsCollectionEh.Notify(Item: TCollectionItem;
  Action: TCollectionNotification);
begin
  inherited Notify(Item, Action);
  if UpdateCount > 0 then Exit;
  if Assigned(OnChangeNotification) then
    OnChangeNotification(Self, Item, Action);
end;

function TValueFieldsCollectionEh.GetPivotFieldValueInfo(
  Index: Integer): TPivotFieldValueInfoEh;
begin
  Result := TPivotFieldValueInfoEh(inherited Items[Index]);
end;

procedure TValueFieldsCollectionEh.SetPivotFieldValueInfo(Index: Integer;
  Value: TPivotFieldValueInfoEh);
begin
  inherited Items[Index] := Value;
end;

procedure TValueFieldsCollectionEh.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  Notify(nil, cnAdded);
end;

procedure TValueFieldsCollectionEh.UpdatePivotFieldsFromPivotFieldNames;
var
  i: Integer;
begin
  for i := 0 to Count-1 do
    Items[i].PivotField := Items[i].UpdatePivotFieldFromPivotFieldName;
end;

function TValueFieldsCollectionEh.IndexByPivotFieldName(
  const PivotFieldName: String): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Count-1 do
  begin
    if Items[i].PivotFieldName = PivotFieldName then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

function TValueFieldsCollectionEh.IndexOf(
  PivotFieldValueInfo: TPivotFieldValueInfoEh): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Count-1 do
  begin
    if Items[i] = PivotFieldValueInfo then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

procedure TValueFieldsCollectionEh.Move(CurIndex, NewIndex: Integer);
begin
  Items[CurIndex].Index := NewIndex;
end;

function TValueFieldsCollectionEh.AddForPivotField(
  APivotField: TPivotFieldEh; Position: Integer): TPivotFieldValueInfoEh;
begin
  BeginUpdate;
  Result := Add;
  Result.PivotField := APivotField;
  Result.SumFunction := APivotField.ProposedSumFunction;
  Result.DisplayFormat := APivotField.DisplayFormat;
  Result.Index := Position;
  EndUpdate;
end;

function TValueFieldsCollectionEh.DataLines: Integer;
begin
  if Count <= 1 then
    Result := 1
  else if (Count = 2) and (Items[1].SumFunction = svtCountEh) then
    Result := 1
  else
    Result := Count;
end;

{ TPivotDataSourceEh }

constructor TPivotDataSourceEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDefaultDateTimeSliceLevels := [dtslYearEh, dtslMonthEh, dtslDayEh];

  FPivotFields := TPivotFieldsEh.Create(Self, TPivotFieldEh);
  FNotificationConsumers := TInterfaceList.Create;

  FColumnFields := TStringList.Create;
  FColumnFields.OnChange := PivotStructureChanged;
  FActualColFields := TStringList.Create;

  FRowFields := TStringList.Create;
  FRowFields.OnChange := PivotStructureChanged;
  FActualRowFields := TStringList.Create;

  FValueFieldsInfo := TValueFieldsCollectionEh.Create(TPivotFieldValueInfoEh);
  FValueFieldsInfo.OnChangeNotification := ValueFieldsInfoChangeEvent;
  FValueFieldsInfo.FPivotDataSource := Self;

  FActualValueFields := TValueFieldsCollectionEh.Create(TPivotFieldValueInfoEh);
  FActualValueFields.FPivotDataSource := Self;

  FSourceTable := TPivotMemTableEh.Create(nil);
  BaseTable := TPivotMemTableEh.Create(nil);
  TPivotMemTableEh(BaseTable).OnCallBackProgress := CallBackProgress;
  FullBaseTable := TPivotMemTableEh.Create(nil);
  FullBaseTable.ExternalMemData := BaseTable;

  ColsTable := TPivotMemTableEh.Create(nil);
  RowsTable := TPivotMemTableEh.Create(nil);
  ResultAggrTable := TPivotMemTableEh.Create(nil);
  TransResultAggrTable := TPivotMemTableEh.Create(nil);

  BaseColsTable := TPivotMemTableEh.Create(nil);
  OldBaseColsTable := TPivotMemTableEh.Create(nil);
end;

destructor TPivotDataSourceEh.Destroy;
begin
  FreeAndNil(FNotificationConsumers);
  FreeAndNil(FPivotFields);

  FreeAndNil(FColumnFields);
  FreeAndNil(FActualColFields);
  FreeAndNil(FActualRowFields);
  FreeAndNil(FRowFields);
  FreeAndNil(FValueFieldsInfo);
  FreeAndNil(FActualValueFields);

  FreeAndNil(FSourceTable);
  FreeAndNil(FullBaseTable);
  FreeAndNil(BaseTable);
  FreeAndNil(ColsTable);
  FreeAndNil(RowsTable);
  FreeAndNil(ResultAggrTable);
  FreeAndNil(TransResultAggrTable);

  FreeAndNil(BaseColsTable);
  FreeAndNil(OldBaseColsTable);

  inherited Destroy;
end;

function TPivotDataSourceEh.DataIsEmpty: Boolean;
begin
  Result := ((ActualColFields.Count = 0) and (ActualRowFields.Count = 0) and (ActualValueFields.Count = 0)) or
            (PivotFields.Count = 0) or
            not ColsTable.Active {or (ColsTable.RecordCount = 0)} or
            not RowsTable.Active {or (RowsTable.RecordCount = 0)};
end;

procedure TPivotDataSourceEh.PivotFieldsChanged;
var
  i: Integer;
begin
  UpdateColRowValueFields;
  ClearSourceData;

  if FNotificationConsumers <> nil then
    for I := 0 to FNotificationConsumers.Count - 1 do
      (FNotificationConsumers[I] as IPivotDataSourceNotificationEh).PivotFieldsChanged(Self);
end;

procedure TPivotDataSourceEh.PivotFieldsDisplayChanged;
var
  i: Integer;
begin
  UpdateColRowValueFields;

  if FNotificationConsumers <> nil then
    for I := 0 to FNotificationConsumers.Count - 1 do
      (FNotificationConsumers[I] as IPivotDataSourceNotificationEh).PivotFieldsChanged(Self);
end;

procedure TPivotDataSourceEh.PivotDataChanged;
var
  i: Integer;
begin
  if FNotificationConsumers <> nil then
    for I := 0 to FNotificationConsumers.Count - 1 do
      (FNotificationConsumers[I] as IPivotDataSourceNotificationEh).PivotDataChanged(Self);
end;

procedure TPivotDataSourceEh.PivotDataStartChanging;
var
  i: Integer;
begin
  if FNotificationConsumers <> nil then
    for I := 0 to FNotificationConsumers.Count - 1 do
      (FNotificationConsumers[I] as IPivotDataSourceNotificationEh).PivotDataStartChanging(Self);
end;

procedure TPivotDataSourceEh.CallBackProgress(Sender: TObject);
begin
  PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, FPercent);
end;

function TPivotDataSourceEh.PivotDataChangeProgress(ElapsedTime: LongWord; Percent: Integer): Boolean;
var
  i: Integer;
  IsCancelRequested: Boolean;
begin
  FPercent := Percent;
  IsCancelRequested := False;
  if (FNotificationConsumers <> nil) and ((GetTickCountEh - FCheckCancelRequestTime >= 300) or (Percent = 100))
  then
  begin
    for I := 0 to FNotificationConsumers.Count - 1 do
    begin
      IsCancelRequested := IsCancelRequested or (FNotificationConsumers[I] as IPivotDataSourceNotificationEh).
        PivotDataChangeProgress(Self, ElapsedTime, Percent);
    end;
    FCheckCancelRequestTime := GetTickCountEh;
    if IsCancelRequested then Abort;
  end;
  Result := IsCancelRequested;
end;

procedure TPivotDataSourceEh.PivotDataFinishChanging;
var
  i: Integer;
  ticks: LongWord;
begin
  ticks := GetTickCountEh;
  if FNotificationConsumers <> nil then
    for I := 0 to FNotificationConsumers.Count - 1 do
      (FNotificationConsumers[I] as IPivotDataSourceNotificationEh).PivotDataFinishChanging(Self);
  LogTimeMetric('  PivotDataFinishChanging', GetTickCountEh - ticks);
end;

procedure TPivotDataSourceEh.PivotDataChangingCanceled;
var
  i: Integer;
begin
  if FNotificationConsumers <> nil then
    for I := 0 to FNotificationConsumers.Count - 1 do
      (FNotificationConsumers[I] as IPivotDataSourceNotificationEh).PivotDataChangingCanceled(Self);
end;

procedure TPivotDataSourceEh.PivotStructureChanged(Sender: TObject);
var
  i: Integer;
begin
  if FInternalDefinitionUpdating then Exit;
  UpdateColRowValueFields;
  UpdatePivotFieldFilters;
  if FNotificationConsumers <> nil then
    for I := 0 to FNotificationConsumers.Count - 1 do
      (FNotificationConsumers[I] as IPivotDataSourceNotificationEh).PivotStructureChanged(Self);
end;

procedure TPivotDataSourceEh.PivotDataSourceChanged;
begin
end;

procedure TPivotDataSourceEh.PivotDataStructBeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TPivotDataSourceEh.PivotDataStructEndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount = 0 then PivotStructureChanged(nil);
end;

procedure TPivotDataSourceEh.SetPivotFields(const Value: TPivotFieldsEh);
begin
  FPivotFields.Assign(Value);
end;

procedure TPivotDataSourceEh.RegisterChanges(Value: IPivotDataSourceNotificationEh);
begin
  if FNotificationConsumers.IndexOf(Value) < 0 then
    FNotificationConsumers.Add(Value);
end;

procedure TPivotDataSourceEh.UnRegisterChanges(Value: IPivotDataSourceNotificationEh);
begin
  if (FNotificationConsumers <> nil) then
    FNotificationConsumers.Remove(Value);
end;

procedure TPivotDataSourceEh.ValueFieldsInfoChangeEvent(Sender: TCollection;
  Item: TCollectionItem; Action: TCollectionNotification);
begin
  PivotStructureChanged(Sender);
end;

procedure TPivotDataSourceEh.SetRowFields(const Value: TStringList);
begin
  FRowFields.Assign(Value);
end;

procedure TPivotDataSourceEh.SetColumnFields(const Value: TStringList);
begin
  FColumnFields.Assign(Value)
end;

procedure TPivotDataSourceEh.SetValueFieldsInfo(const Value: TValueFieldsCollectionEh);
begin
  FValueFieldsInfo.Assign(Value);
end;

procedure TPivotDataSourceEh.UpdateColRowValueFields;
var
  i: Integer;
  PivotField: TPivotFieldEh;
begin
  if FInternalDefinitionUpdating then Exit;
  if csDestroying in ComponentState then Exit;

  try
    FInternalDefinitionUpdating := True;

    for i := 0 to RowFields.Count-1 do
    begin
      PivotField := PivotFields.FindFieldByName(RowFields[i]);
      if PivotField <> nil then
        RowFields.Objects[i] := PivotField
      else if PivotFields.Count = 0 then
        RowFields.Objects[i] := nil
      else
        ;
    end;

    for i := 0 to ColumnFields.Count-1 do
    begin
      PivotField := PivotFields.FindFieldByName(ColumnFields[i]);
      if PivotField <> nil then
        ColumnFields.Objects[i] := PivotField
      else if PivotFields.Count = 0 then
        ColumnFields.Objects[i] := nil
      else
       ;
    end;

    ValueFieldDefs.UpdatePivotFieldsFromPivotFieldNames;
  finally
    FInternalDefinitionUpdating := False;
  end;
end;

procedure TPivotDataSourceEh.UpdatePivotFieldFilters;
var
  i: Integer;
  fld: TPivotFieldEh;
begin
  for i := 0 to PivotFields.Count-1 do
  begin
    fld := PivotFields[i];
    if (ColumnFields.IndexOfObject(fld) < 0) and
       (RowFields.IndexOfObject(fld) < 0)
    then
      fld.ClearExpression;
  end;
end;

procedure TPivotDataSourceEh.UpdateKeyValueStates;
var
  i: Integer;
  ticks: LongWord;
begin
  ticks := GetTickCountEh;
  for i := 0 to FPivotFields.Count-1 do
    FPivotFields[i].UpdateKeyValueStates;
  LogTimeMetric('  UpdateKeyValueStates', GetTickCountEh-ticks)
end;

procedure TPivotDataSourceEh.BuildGridData;
begin
  FBuildDataProgressTicks := GetTickCountEh;
  FCheckCancelRequestTime := GetTickCountEh;
  PivotDataStartChanging;

  BaseTable.DisableControls;
  ColsTable.DisableControls;
  RowsTable.DisableControls;
  ResultAggrTable.DisableControls;
  TransResultAggrTable.DisableControls;

  try
    try
      if (ColumnFields.Count = 0) and (RowFields.Count = 0) and (ValueFieldDefs.Count = 0) then
        PivotDataChanged
      else
      begin
        CreateAndFillBaseTable;
        SetBaseTableFilter;
        BuildGridDataForBaseTable;
      end;
    except
      on E: EAbort do
      begin
        PivotDataChangingCanceled;
        BaseTable.EmptyTable;
        ColsTable.EmptyTable;
        RowsTable.EmptyTable;
        ResultAggrTable.EmptyTable;
        TransResultAggrTable.EmptyTable;
      end else
        raise;
    end;
  finally
    BaseTable.EnableControls;
    ColsTable.EnableControls;
    RowsTable.EnableControls;
    ResultAggrTable.EnableControls;
    TransResultAggrTable.EnableControls;
  end;

  PivotDataFinishChanging;

  LogTimeMetric('BuildGridData', GetTickCountEh - FBuildDataProgressTicks)
end;

procedure TPivotDataSourceEh.ClearSourceData;
begin
  SourceTable.DestroyTable;
  ColsTable.DestroyTable;
  RowsTable.DestroyTable;
end;

procedure TPivotDataSourceEh.LoadAndBuildPivotData;
begin
  CreateAndFillSourceTable;
  BuildPivotData;
end;

procedure TPivotDataSourceEh.LogTimeMetric(const MetricName: String;
  Duration: LongWord);
begin
  if Assigned(OnLogTimeMetric) then
    OnLogTimeMetric(Self, MetricName, Duration);
end;

procedure TPivotDataSourceEh.CreateAndFillSourceTable;
var
  ticks: LongWord;
begin
  ticks := GetTickCountEh;
  if DataSet = nil then
    raise Exception.Create(Name+'.DataSet is not assigned');
  SourceTable.DisableControls;
  try
    CreateSourceTableStruct;
    FillSourceTable;
    UpdateKeyValueStates;
  finally
    SourceTable.EnableControls;
  end;
  LogTimeMetric('CreateAndFillSourceTable', GetTickCountEh - ticks)
end;

procedure TPivotDataSourceEh.CreateSourceTableStruct;
var
  i: Integer;
  DataStruct: TMTDataStructEh;
  DataField: TMTDataFieldEh;
  Field: TField;
  PField: TPivotFieldEh;
  ticks: LongWord;
begin
  ticks := GetTickCountEh;
  SourceTable.DestroyTable;
  for i := 0 to PivotFields.Count-1 do
  begin
    DataStruct := SourceTable.RecordsView.MemTableData.DataStruct;
    PField := PivotFields[i];
    if PField.SourceFieldName <> '' then
    begin
      Field := DataSet.FieldByName(PField.SourceFieldName);
      DataField := DataStruct.BuildDataFieldForField(Field);
      if (DataField is TMTNumericDataFieldEh) and (TMTNumericDataFieldEh(DataField).NumericDataType = fdtAutoIncEh) then
        TMTNumericDataFieldEh(DataField).NumericDataType := fdtLargeintEh;
      DataField.FieldName := PField.FieldName;
      DataField.AssignProps(Field);
    end else
    begin
      DataStruct.BuildDataFieldForDef(PField.FieldName,
        PField.TypeDef.DataType, PField.TypeDef.Size, PField.TypeDef.Precision);
    end;
  end;
  SourceTable.Open;
  LogTimeMetric('  CreateSourceTableStruct', GetTickCountEh-ticks)
end;

procedure TPivotDataSourceEh.FillSourceTable;
var
  FieldMap: TIntegerDynArray;
  i: Integer;
  PivotField: TPivotFieldEh;
  Field: TField;
  Value: Variant;
  Processed: Boolean;
  ticks: LongWord;
  RecordsList: TRecordsListEh;
  Rec: TMemoryRecordEh;
begin
  ticks := GetTickCountEh;
  SetLength(FieldMap, SourceTable.Fields.Count);
  for i := 0 to SourceTable.Fields.Count-1 do
  begin
    PivotField := PivotFields.FindFieldByName(SourceTable.Fields[i].FieldName);
    Field := DataSet.FindField(PivotField.SourceFieldName);
    if Field <> nil
      then FieldMap[i] := Field.Index
      else FieldMap[i] := -1;
  end;

  DataSet.DisableControls;
  SourceTable.DisableControls;
  if not DataSet.IsUniDirectional then
    DataSet.First;

  RecordsList := SourceTable.RecordsView.MemTableData.RecordsList;
  try

  RecordsList.BeginUpdate;

  while not DataSet.Eof do
  begin
    Rec := RecordsList.NewRecord;

    for i := 0 to Length(FieldMap)-1 do
    begin
      if FieldMap[i] >= 0
        then Field := DataSet.Fields[FieldMap[i]]
        else Field := nil;

      Value := Null;
      Processed := False;
      if Assigned(PivotFields[i].OnFetchValue) then
        PivotFields[i].OnFetchValue(Self, PivotFields[i], Value, Processed);

      if Processed
        then Rec.Value[i, dvvValueEh] := Value
        else Rec.Value[i, dvvValueEh] := PivotFields[i].GetValueForSource(DataSet, Field);
    end;

    RecordsList.FetchRecord(Rec);
    DataSet.Next;
  end;

  finally
    RecordsList.EndUpdate;
    if not DataSet.IsUniDirectional then
      DataSet.First;
    DataSet.EnableControls;
    SourceTable.EnableControls;
  end;
  LogTimeMetric('  FillSourceTable', GetTickCountEh-ticks)
end;

procedure TPivotDataSourceEh.CreateAndFillBaseTable;
var
  ticks: LongWord;
begin
  ticks := GetTickCountEh;
  BaseTable.DisableControls;
  try
    CreateBaseTableStruct;
    PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 1);
    FillBasePivotData;
    PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 5);
  finally
    BaseTable.EnableControls;
  end;
  LogTimeMetric('  CreateAndFillBaseTable', GetTickCountEh-ticks);
end;

{$IFDEF FPC}
procedure DisableProcessWindowsGhosting;
begin
 { TODO : Make an implementation for Non MSWINDOWS Platform. }
end;
{$ELSE}
  {$IFDEF MSWINDOWS}
procedure DisableProcessWindowsGhosting; external user32 name 'DisableProcessWindowsGhosting';
  {$ELSE}
procedure DisableProcessWindowsGhosting;
begin
 { TODO : Make an implementation for Non MSWINDOWS Platform. }
end;
  {$ENDIF}
{$ENDIF}

procedure TPivotDataSourceEh.BuildPivotData;
begin
  DisableProcessWindowsGhosting;
  FBuildDataProgressTicks := GetTickCountEh;
  FCheckCancelRequestTime := GetTickCountEh;
  PivotDataStartChanging;

  BaseTable.DisableControls;
  ColsTable.DisableControls;
  RowsTable.DisableControls;
  ResultAggrTable.DisableControls;
  TransResultAggrTable.DisableControls;

  try
    try
      CreateAndFillBaseTable;
      SetBaseTableFilter;
      BuildGridDataForBaseTable;
    except
      on E: EAbort do
      begin
        PivotDataChangingCanceled;
        BaseTable.EmptyTable;
        ColsTable.EmptyTable;
        RowsTable.EmptyTable;
        ResultAggrTable.EmptyTable;
        TransResultAggrTable.EmptyTable;
      end else
        raise;
    end;
  finally
    BaseTable.EnableControls;
    ColsTable.EnableControls;
    RowsTable.EnableControls;
    ResultAggrTable.EnableControls;
    TransResultAggrTable.EnableControls;
  end;

  PivotDataFinishChanging;

  LogTimeMetric('BuildPivotData', GetTickCountEh - FBuildDataProgressTicks)
end;

procedure TPivotDataSourceEh.BuildGridDataForBaseTable;
begin
  MakeColsRowsTables;
  MakeResultAggrTable;
  MakeInverseGaussMatrix;
  PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 100);
  PivotDataChanged;
end;

function TPivotDataSourceEh.GetSortFieldsFromList(FieldList: TStringList): String;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to FieldList.Count-1 do
  begin
    if (i > 0) then
      Result := Result + ', [' + FieldList[i] + ']'
    else
      Result := Result + '[' + FieldList[i] + ']';
  end;
end;

procedure TPivotDataSourceEh.MakeColsRowsTables;
var
  SortFields: String;
  ticks: LongWord;
begin
  ticks := GetTickCountEh;

  SortFields := GetSortFieldsFromList(FActualColFields);
  BaseTable.SortByFields(SortFields);
  PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 16);
  MakeBaseColsTable;
  MakeColsTable;
  PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 17);

  SortFields := GetSortFieldsFromList(FActualRowFields) + ', ' +
                GetSortFieldsFromList(FActualColFields);
  BaseTable.SortByFields(SortFields);
  PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 36);
  MakeRowsTable;
  PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 37);

  LogTimeMetric('  MakeColsRowsTables', GetTickCountEh-ticks);
end;

procedure TPivotDataSourceEh.CreateBaseTableStruct;
var
  i: Integer;
  DataField: TMTDataFieldEh;
  NumDataField: TMTNumericDataFieldEh;
  PivotFieldValue: TPivotFieldValueInfoEh;
  BaseStruct: TMTDataStructEh;
  SourceField: TField;
  PivotField: TPivotFieldEh;

  function BuildAndCopyDataFieldForField(AField: TField; NewFieldName: String): TMTDataFieldEh;
  var
    DataFieldClass: TMTDataFieldClassEh;
    ADataType: TFieldType;
  begin
    ADataType := AField.DataType;
    if ADataType = ftAutoInc then
      ADataType := ftInteger;
    DataFieldClass := DefaultDataFieldClasses[ADataType];

    Result := BaseTable.RecordsView.MemTableData.DataStruct.CreateField(DataFieldClass);
    Result.AssignDataType(ADataType);
    Result.FieldName := NewFieldName;
    Result.AssignProps(AField);
    Result.Required := False;
    Result.DisplayLabel := NewFieldName;
  end;

  function CreateNewDataField(NewFieldName: String; ADataType: TFieldType): TMTDataFieldEh;
  var
    DataFieldClass: TMTDataFieldClassEh;
  begin
    DataFieldClass := DefaultDataFieldClasses[ADataType];

    Result := BaseTable.RecordsView.MemTableData.DataStruct.CreateField(DataFieldClass);
    Result.AssignDataType(ADataType);
    Result.FieldName := NewFieldName;
    Result.DisplayLabel := NewFieldName;
  end;

var
  PvtValInfo: TPivotFieldValueInfoEh;
  NewFieldName: String;
begin
  FullBaseTable.Close;
  BaseTable.DestroyTable;
  BaseTable.Filter := '';

  FActualRowFields.Assign(FRowFields);

  BaseStruct := BaseTable.RecordsView.MemTableData.DataStruct;
  if FActualRowFields.Count > 0 then
    for i := 0 to FActualRowFields.Count-1 do
    begin
      PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 0);
      PivotField := TPivotFieldEh(FActualRowFields.Objects[i]);
      SourceField := SourceTable.FieldByName(PivotField.SourceFieldName);
      DataField := BaseStruct.BuildDataFieldForField(SourceField);
      DataField.FieldName := PivotField.FieldName;
      DataField.AssignProps(SourceField);
      DataField.Required := False;
      DataField.DisplayLabel := PivotField.DisplayName;
      if RowsFieldNames <> '' then RowsFieldNames := RowsFieldNames + ';';
      RowsFieldNames := RowsFieldNames + FActualRowFields[i];
    end
  else
  begin
    FActualRowFields.Append('%Value-R');

    NumDataField := TMTNumericDataFieldEh(BaseStruct.CreateField(TMTNumericDataFieldEh));
    NumDataField.FieldName := '%Value-R';
    NumDataField.DisplayLabel := EhLibLanguageConsts.PivotValueFieldDisplayNameEh;
    NumDataField.NumericDataType := fdtIntegerEh;
    RowsFieldNames := FActualRowFields[0];
  end;

  FActualColFields.Assign(FColumnFields);

  if FActualColFields.Count > 0 then
    for i := 0 to FActualColFields.Count-1 do
    begin
      PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 0);
      DataField := BuildAndCopyDataFieldForField(
        SourceTable.FieldByName(TPivotFieldEh(FActualColFields.Objects[i]).SourceFieldName),
        TPivotFieldEh(FActualColFields.Objects[i]).FieldName);
      DataField.DisplayLabel := TPivotFieldEh(FActualColFields.Objects[i]).DisplayName;
      if ColsFieldNames <> '' then ColsFieldNames := ColsFieldNames + ';';
      ColsFieldNames := ColsFieldNames + FActualColFields[i];
    end
  else
  begin
    FActualColFields.Append('%Value-C');

    NumDataField := TMTNumericDataFieldEh(BaseStruct.CreateField(TMTNumericDataFieldEh));
    NumDataField.FieldName := '%Value-C';
    NumDataField.NumericDataType := fdtIntegerEh;
    ColsFieldNames := FActualColFields[0];
  end;

  ActualValueFields.Assign(ValueFieldDefs);

  if ActualValueFields.Count = 0 then
  begin
    PivotFieldValue := ActualValueFields.Add;
    PivotFieldValue.PivotFieldName := 'Count(*)';
    PivotFieldValue.SumFunction := svtCountEh;
    CreateNewDataField('Count(*)', ftInteger);
  end else
  begin
    for i := 0 to ActualValueFields.Count-1 do
    begin
      PvtValInfo := ActualValueFields[i];
      PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 0);
      SourceField := SourceTable.FieldByName(PvtValInfo.PivotField.FieldName);
      NewFieldName := PvtValInfo.PivotField.FieldName + '-' +
                      PivotAggrValueTypes[PvtValInfo.SumFunction];

      if (PvtValInfo.SumFunction  in [svtCountEh, svtCountDistinctEh]) then
      begin
        DataField := CreateNewDataField(NewFieldName, ftInteger);
      end else
      begin
        DataField := BuildAndCopyDataFieldForField(SourceField, NewFieldName);
      end;

      DataField.DisplayLabel :=
        PvtValInfo.PivotField.FieldName + '-' +
        PivotAggrValueDisplayNames(PvtValInfo.SumFunction);
    end;
  end;

  PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 0);
  BaseTable.Open;
  FullBaseTable.Open;
end;

procedure TPivotDataSourceEh.FillBasePivotData;
var
  i: Integer;
  StartPost: Integer;
  RowFieldsMap, ColFieldsMap, ValFieldsMap: TIntegerDynArray;
  Field: TField;
  ValFieldInfo: TPivotFieldValueInfoEh;
begin
  SourceTable.DisableControls;
  SourceTable.First;

  SetLength(RowFieldsMap, FActualRowFields.Count);
  for i := 0 to FActualRowFields.Count-1 do
  begin
    PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 2);
    Field := SourceTable.FindField(FActualRowFields[i]);
    if Field <> nil
      then RowFieldsMap[i] := Field.Index
      else RowFieldsMap[i] := -1;
  end;

  SetLength(ColFieldsMap, FActualColFields.Count);
  for i := 0 to FActualColFields.Count-1 do
  begin
    PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 2);
    Field := SourceTable.FindField(FActualColFields[i]);
    if Field <> nil
      then ColFieldsMap[i] := Field.Index
      else ColFieldsMap[i] := -1;
  end;

  SetLength(ValFieldsMap, ActualValueFields.Count);
  for i := 0 to ActualValueFields.Count-1 do
  begin
    PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 3);
    Field := SourceTable.FindField(ActualValueFields[i].PivotFieldName);
    if Field <> nil
      then ValFieldsMap[i] := Field.Index
      else ValFieldsMap[i] := -1;
  end;

  while (not SourceTable.Eof) do
  begin
    BaseTable.Append;
    BaseTable.Post;

    for i := 0 to FActualRowFields.Count-1 do
    begin
      PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 4);
      if FActualRowFields.Objects[i] = nil then
        BaseTable.Rec.Value[BaseTable.Fields[i].FieldNo-1, dvvValueEh] := 0
      else
        BaseTable.Rec.Value[BaseTable.Fields[i].FieldNo-1, dvvValueEh] :=
          SourceTable.Rec.Value[SourceTable.Fields[RowFieldsMap[i]].FieldNo-1, dvvValueEh];
    end;

    StartPost := FActualRowFields.Count;
    for i := StartPost to StartPost + FActualColFields.Count - 1 do
    begin
      PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 4);
      if FActualColFields.Objects[i-FActualRowFields.Count] = nil then
        BaseTable.Rec.Value[BaseTable.Fields[i].FieldNo-1, dvvValueEh] := 0
      else
        BaseTable.Rec.Value[BaseTable.Fields[i].FieldNo-1, dvvValueEh] :=
          SourceTable.Rec.Value[SourceTable.Fields[ColFieldsMap[i-StartPost]].FieldNo-1, dvvValueEh];
    end;

    StartPost := StartPost + FActualColFields.Count;
    if BaseTable.FieldCount > StartPost then
    begin
      for i := StartPost to StartPost + ActualValueFields.Count - 1 do
      begin
        PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 4);
        ValFieldInfo := ActualValueFields[i-StartPost];
        if (ValFieldInfo.PivotField <> nil) and
           not (ValFieldInfo.SumFunction  in [svtCountEh, svtCountDistinctEh])
        then
          BaseTable.Rec.Value[BaseTable.Fields[i].FieldNo-1, dvvValueEh] :=
            SourceTable.Rec.Value[SourceTable.Fields[ValFieldsMap[i-StartPost]].FieldNo-1, dvvValueEh]
        else
          BaseTable.Rec.Value[BaseTable.Fields[i].FieldNo-1, dvvValueEh] := 0;
      end;
    end;

    SourceTable.Next;
  end;
  SourceTable.EnableControls;
end;

procedure TPivotDataSourceEh.AggregateBasePivotData;
begin

end;

procedure TPivotDataSourceEh.MakeBaseColsTable;
begin
  CopyBaseColsTable(OldBaseColsTable);
  MakeBaseColsTableStruct(BaseColsTable);
  BaseColsTable.Open;
  FillColsTableData(BaseColsTable, FullBaseTable, BaseColsTable.FieldCount-2);
  FillBaseColsTableDataState(OldBaseColsTable);
end;

procedure TPivotDataSourceEh.MakeBaseColsTableStruct(ABaseColsTable: TMemTableEh);
var
  WidthField: TMTNumericDataFieldEh;
begin
  MakeColsTableStruct(ABaseColsTable);

  WidthField := TMTNumericDataFieldEh(ABaseColsTable.RecordsView.MemTableData.DataStruct.CreateField(TMTNumericDataFieldEh));
  WidthField.FieldName := '%Width';
  WidthField.NumericDataType := fdtIntegerEh;
end;

procedure TPivotDataSourceEh.CopyBaseColsTable(AOldBaseColsTable: TMemTableEh);
begin
  AOldBaseColsTable.Close;
  AOldBaseColsTable.DestroyTable;
  MakeBaseColsTableStruct(AOldBaseColsTable);
  AOldBaseColsTable.LoadFromMemTableEh(BaseColsTable, -1, lmAppend, []);
  AOldBaseColsTable.Open;
end;

procedure TPivotDataSourceEh.FillBaseColsTableDataState(AOldColsTable: TMemTableEh);
var
  BaseCompValue, OldBaseCompValue: TVariantDynArray;
  CompareResult: TVariantRelationship;

  procedure SetValue(Table: TMemTableEh; var Value: TVariantDynArray);
  var
    i: Integer;
  begin
    for i := 0 to FActualColFields.Count-1 do
      Value[i] := Table.Rec.Value[i, dvvValueEh];
  end;

begin
  BaseColsTable.First;
  AOldColsTable.First;
  if BaseColsTable.Eof then Exit;

  if not AOldColsTable.Eof then
  begin
    SetLength(BaseCompValue, FActualColFields.Count);
    SetLength(OldBaseCompValue, FActualColFields.Count);

    SetValue(BaseColsTable, BaseCompValue);
    SetValue(AOldColsTable, OldBaseCompValue);

    while True do
    begin
      CompareResult :=  VarArrayForceCompareValue(BaseCompValue, OldBaseCompValue);
      if CompareResult = vrNotEqual then
        raise Exception.Create('TPivotDataSourceEh.FillBaseColsTableDataState() .. CompareResult = vrNotEqual')
      else if CompareResult = vrEqual then
      begin
        BaseColsTable.Rec.Edit;
        BaseColsTable.Rec.Value[FActualColFields.Count+1, dvvValueEh] := AOldColsTable.Rec.Value[FActualColFields.Count+1, dvvValueEh];
        BaseColsTable.Rec.Post;

        BaseColsTable.Next;
        AOldColsTable.Next;

        SetValue(BaseColsTable, BaseCompValue);
        SetValue(AOldColsTable, OldBaseCompValue);
      end else if CompareResult = vrLessThan then
      begin
        BaseColsTable.Rec.Edit;
        BaseColsTable.Rec.Value[FActualColFields.Count+1, dvvValueEh] := -1;
        BaseColsTable.Rec.Post;

        BaseColsTable.Next;
        SetValue(BaseColsTable, BaseCompValue);
      end else if CompareResult = vrGreaterThan then
      begin
        AOldColsTable.Next;
      end;
      if BaseColsTable.Eof or AOldColsTable.Eof then Break;
    end;
  end;

  while not BaseColsTable.Eof do
  begin
    BaseColsTable.Rec.Edit;
    BaseColsTable.Rec.Value[FActualColFields.Count+1, dvvValueEh] := -1;
    BaseColsTable.Rec.Post;

    BaseColsTable.Next;
  end;
end;

procedure TPivotDataSourceEh.BindColsRecsToBaseColsRecs;
var
  BaseCompValue, ColsCompValue: TVariantDynArray;
  CompareResult: TVariantRelationship;
  RefRecIdx: Integer;

  procedure SetValue(Table: TMemTableEh; var Value: TVariantDynArray);
  var
    i: Integer;
  begin
    for i := 0 to FActualColFields.Count-1 do
      Value[i] := Table.Rec.Value[i, dvvValueEh];
  end;

begin
  BaseColsTable.First;
  ColsTable.First;
  RefRecIdx := ColsTable.RecordsView.MemTableData.DataStruct.FieldByName('%RefBaseRec').Index;

  if ColsTable.Eof then Exit;

  if not BaseColsTable.Eof then
  begin
    SetLength(BaseCompValue, FActualColFields.Count);
    SetLength(ColsCompValue, FActualColFields.Count);

    SetValue(BaseColsTable, BaseCompValue);
    SetValue(ColsTable, ColsCompValue);

    while True do
    begin
      CompareResult :=  VarArrayForceCompareValue(BaseCompValue, ColsCompValue);
      if CompareResult = vrNotEqual then
        raise Exception.Create('TPivotDataSourceEh.FillBaseColsTableDataState() .. CompareResult = vrNotEqual')
      else if CompareResult = vrEqual then
      begin
        ColsTable.Rec.Edit;
        ColsTable.Rec.Value[RefRecIdx, dvvValueEh] := RefObjectToVariant(BaseColsTable.Rec);
        ColsTable.Rec.Post;

        BaseColsTable.Next;
        ColsTable.Next;

        SetValue(BaseColsTable, BaseCompValue);
        SetValue(ColsTable, ColsCompValue);
      end else
      begin
        ColsTable.Next;
        SetValue(ColsTable, BaseCompValue);
      end;
      if BaseColsTable.Eof or ColsTable.Eof then Break;
    end;
  end;
end;

procedure TPivotDataSourceEh.MakeColsTable;
begin
  MakeColsTableStruct(ColsTable);
  ColsTable.Open;
  FillColsTableData(ColsTable, BaseTable, FActualColFields.Count {ColsTable.FieldCount-1});
end;

procedure TPivotDataSourceEh.MakeColsTableStruct(AColsTable: TMemTableEh);
var
  DataField: TMTNumericDataFieldEh;
  i: Integer;
begin
  AColsTable.DestroyTable;
  for i := 0 to FActualColFields.Count-1 do
  begin
    PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 16);
    AColsTable.RecordsView.MemTableData.DataStruct.
      BuildAndCopyDataFieldForField(BaseTable.FieldByName(FActualColFields[i]));
  end;

  DataField := TMTNumericDataFieldEh(AColsTable.RecordsView.MemTableData.DataStruct.CreateField(TMTNumericDataFieldEh));
  DataField.FieldName := '%RecType';
  DataField.NumericDataType := fdtIntegerEh;
end;

procedure TPivotDataSourceEh.FillColsTableData(AColsTable, ABaseTable: TMemTableEh; DataFieldCount: Integer);
var
  i, b: Integer;
  CompValue, NewCompValue: TVariantDynArray;
  EqLev: Integer;
  FieldMap: TIntegerDynArray;
begin
  ABaseTable.First;

  if ABaseTable.Eof then Exit;

  SetLength(CompValue, FActualColFields.Count);
  SetLength(NewCompValue, FActualColFields.Count);
  SetLength(FieldMap, DataFieldCount);

  for i := 0 to DataFieldCount-1 do
    FieldMap[i] := ABaseTable.FieldByName(AColsTable.Fields[i].FieldName).Index;

  for i := 0 to DataFieldCount-1 do
  begin
    PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 16);
    NewCompValue[i] := ABaseTable.Rec.Value[ABaseTable.Fields[FieldMap[i]].FieldNo-1, dvvValueEh];
  end;

  while not ABaseTable.Eof do
  begin
    for i := 0 to DataFieldCount-1 do
    begin
      PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 16);
      CompValue[i] := ABaseTable.Rec.Value[ABaseTable.Fields[FieldMap[i]].FieldNo-1, dvvValueEh];
    end;

    EqLev := VarArrayEqualLevelForDepth(NewCompValue, CompValue, FActualColFields.Count);
    if EqLev = FActualColFields.Count then
    begin
      PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 16);
    end else
    begin
      AColsTable.Append;
      for i := 0 to DataFieldCount-1 do
      begin
        PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 16);
        AColsTable.Fields[i].Value := NewCompValue[i];
      end;
      AColsTable.Fields[DataFieldCount].Value := 0;
      AColsTable.Post;

      for b := FActualColFields.Count-2 downto EqLev do
      begin
        AColsTable.Append;
        for i := 0 to b do
        begin
          PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 16);
          AColsTable.Fields[i].Value := NewCompValue[i];
        end;
        AColsTable.Fields[DataFieldCount].Value := FActualColFields.Count-2-b+1;
        AColsTable.Post;
        for i := b+1 to DataFieldCount-1 do
        begin
          PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 16);
          AColsTable.Rec.Value[i, dvvValueEh] := Unassigned;
        end;
     end;

      NewCompValue := Copy(CompValue);
    end;
    ABaseTable.Next;
  end;

  AColsTable.Append;
  for i := 0 to DataFieldCount-1 do
  begin
    PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 16);
    AColsTable.Fields[i].Value := CompValue[i];
  end;
  AColsTable.Fields[DataFieldCount].Value := 0;
  AColsTable.Post;

  for b := FActualColFields.Count-2 downto 0 do
  begin
    AColsTable.Append;
    for i := 0 to b do
    begin
      PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 16);
      AColsTable.Fields[i].Value := NewCompValue[i];
    end;
    AColsTable.Fields[DataFieldCount].Value := FActualColFields.Count-2-b+1;
    AColsTable.Post;
    for i := b+1 to DataFieldCount-1 do
    begin
      PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 16);
      AColsTable.Rec.Value[i, dvvValueEh] := Unassigned;
    end;
  end;

  AColsTable.Append;
  AColsTable.Fields[DataFieldCount].Value := FActualColFields.Count;
  AColsTable.Post;
  for i := 0 to DataFieldCount-1 do
  begin
    PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 16);
    AColsTable.Rec.Value[i, dvvValueEh] := Unassigned;
  end;
end;


procedure TPivotDataSourceEh.MakeRowsTable;
begin
  MakeRowsTableStruct(RowsTable);
  RowsTable.Open;
  FillRowsTableData(RowsTable, FActualRowFields.Count);
end;

procedure TPivotDataSourceEh.MakeRowsTableStruct(ARowsTable: TMemTableEh);
var
  DataField: TMTNumericDataFieldEh;
  i: Integer;
begin
  ARowsTable.DestroyTable;

  for i := 0 to FActualRowFields.Count-1 do
  begin
    PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 36);
    ARowsTable.RecordsView.MemTableData.DataStruct.
      BuildAndCopyDataFieldForField(BaseTable.FieldByName(FActualRowFields[i]));
  end;

  DataField := TMTNumericDataFieldEh(ARowsTable.RecordsView.MemTableData.DataStruct.CreateField(TMTNumericDataFieldEh));
  DataField.FieldName := '%RecType';
  DataField.NumericDataType := fdtIntegerEh;
end;

procedure TPivotDataSourceEh.FillRowsTableData(ARowsTable: TMemTableEh; DataFieldCount: Integer);
var
  i, b: Integer;
  CompValue, NewCompValue: TVariantDynArray;
  EqLev: Integer;
  FieldMap: TIntegerDynArray;
begin
  BaseTable.First;

  if BaseTable.Eof then Exit;

  SetLength(CompValue, FActualRowFields.Count);
  SetLength(NewCompValue, FActualRowFields.Count);
  SetLength(FieldMap, DataFieldCount);

  for i := 0 to DataFieldCount-1 do
    FieldMap[i] := BaseTable.FieldByName(ARowsTable.Fields[i].FieldName).Index;

  for i := 0 to DataFieldCount-1 do
  begin
    PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 36);
    NewCompValue[i] := BaseTable.Rec.Value[BaseTable.Fields[FieldMap[i]].FieldNo-1, dvvValueEh];
  end;

  while not BaseTable.Eof do
  begin

    for i := 0 to DataFieldCount-1 do
    begin
      PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 36);
      CompValue[i] := BaseTable.Rec.Value[BaseTable.Fields[FieldMap[i]].FieldNo-1, dvvValueEh];
    end;

    EqLev := VarArrayEqualLevelForDepth(NewCompValue, CompValue, FActualRowFields.Count);
    if EqLev = FActualRowFields.Count then
    begin
      PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 36);
    end else
    begin
      ARowsTable.Append;
      for i := 0 to DataFieldCount-1 do
      begin
        PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 36);
        ARowsTable.Fields[i].Value := NewCompValue[i];
      end;
      ARowsTable.Fields[DataFieldCount].Value := 0;
      ARowsTable.Post;

      for b := FActualRowFields.Count-2 downto EqLev do
      begin
        ARowsTable.Append;
        for i := 0 to b do
        begin
          PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 36);
          ARowsTable.Fields[i].Value := NewCompValue[i];
        end;
        ARowsTable.Fields[DataFieldCount].Value := FActualRowFields.Count-2-b+1;
        ARowsTable.Post;
        for i := b+1 to DataFieldCount-1 do
        begin
          PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 36);
          ARowsTable.Rec.Value[i, dvvValueEh] := Unassigned;
        end;
      end;

      NewCompValue := Copy(CompValue);
    end;
    BaseTable.Next;

  end;

  ARowsTable.Append;
  ARowsTable.Fields[DataFieldCount].Value := 0;
  ARowsTable.Post;
  for i := 0 to DataFieldCount-1 do
  begin
    PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 36);
    ARowsTable.Rec.Value[i, dvvValueEh] := CompValue[i];
  end;

  for b := FActualRowFields.Count-2 downto 0 do
  begin
    ARowsTable.Append;
    ARowsTable.Fields[DataFieldCount].Value := FActualRowFields.Count-2-b+1;
    ARowsTable.Post;
    for i := 0 to b do
    begin
      PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 36);
      ARowsTable.Rec.Value[i, dvvValueEh] := NewCompValue[i];
    end;
    for i := b+1 to DataFieldCount-1 do
    begin
      PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 36);
      ARowsTable.Rec.Value[i, dvvValueEh] := Unassigned;
    end;
  end;

  ARowsTable.Append;
  ARowsTable.Fields[DataFieldCount].Value := FActualRowFields.Count;
  ARowsTable.Post;
  for i := 0 to DataFieldCount-1 do
  begin
    PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 36);
    ARowsTable.Rec.Value[i, dvvValueEh] := Unassigned;
  end;
end;

procedure TPivotDataSourceEh.MakeResultAggrTable;
var
  DataField: TMTNumericDataFieldEh;
  i,b,k: Integer;
  CompValue, NewCompValue: TVariantDynArray;
  AggrLevelArrValue: array of array of TPivotGridAggregateFunctionCalculatorEh;
  KeyLength, EqualLevel: Integer;
  ticks: LongWord;
  fld: TField;
begin
  ticks := GetTickCountEh;
  ResultAggrTable.DestroyTable;
  ResultAggrTable.RecordsView.MemTableData.DataStruct.Assign(
    BaseTable.RecordsView.MemTableData.DataStruct);
  DataField := TMTNumericDataFieldEh(ResultAggrTable.RecordsView.MemTableData.DataStruct.CreateField(TMTNumericDataFieldEh));
  DataField.FieldName := '%RecType';
  DataField.NumericDataType := fdtIntegerEh;

  ResultAggrTable.Open;
  if not StructureIsConsistent then Exit;

  KeyLength := FActualColFields.Count + FActualRowFields.Count;

  SetLength(CompValue, KeyLength);
  SetLength(NewCompValue, KeyLength);

  SetLength(AggrLevelArrValue, KeyLength+1);

  for i := 0 to KeyLength do
  begin
    SetLength(AggrLevelArrValue[i], ActualValueFields.Count);
    for k := 0 to ActualValueFields.Count-1 do
    begin
      PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 37);
      AggrLevelArrValue[i][k] := StandardAggregateFunctionCalculators[ActualValueFields[k].SumFunction].Create;
      AggrLevelArrValue[i][k].ResetAggrHolder;
    end;
  end;

  BaseTable.First;
  for i := 0 to KeyLength-1 do
    CompValue[i] := BaseTable.Fields[i].Value;

  while not BaseTable.Eof do
  begin

    for i := 0 to KeyLength-1 do
    begin
      PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 38);
      NewCompValue[i] := BaseTable.Fields[i].Value;
    end;

    EqualLevel := VarArrayEqualLevelForDepth(CompValue, NewCompValue, KeyLength);

    if EqualLevel < KeyLength then
    begin
      for b := KeyLength downto EqualLevel+1 do
      begin
        PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 38);
        ResultAggrTable.Append;
        for i := 0 to b-1 do
          ResultAggrTable.Fields[i].Value := CompValue[i];
        for k := 0 to ActualValueFields.Count-1 do
        begin
          fld := ResultAggrTable.Fields[BaseTable.FieldCount-ActualValueFields.Count+k];
          SetFieldValueAsVariant(fld, AggrLevelArrValue[b][k].FinalizeAggregation);
        end;
        ResultAggrTable.Fields[BaseTable.FieldCount].Value := 1;
        for k := 0 to ActualValueFields.Count-1 do
          AggrLevelArrValue[b][k].ResetAggrHolder;
        ResultAggrTable.Post;
        for i := b to KeyLength-1 do
          ResultAggrTable.Rec.Value[i, dvvValueEh] := Unassigned;
      end;
    end;

    for i := 0 to KeyLength do
      for k := 0 to ActualValueFields.Count-1 do
      begin
        PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 38);
        AggrLevelArrValue[i][k].AggrValue(BaseTable.Fields[KeyLength+k].Value);
      end;

    CompValue := Copy(NewCompValue);
    BaseTable.Next;
  end;

  for b := KeyLength downto 1 do
  begin
    PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 39);
    ResultAggrTable.Append;
    for i := 0 to b-1 do
      ResultAggrTable.Fields[i].Value := CompValue[i];
    for k := 0 to ActualValueFields.Count-1 do
    begin
      fld := ResultAggrTable.Fields[BaseTable.FieldCount-ActualValueFields.Count+k];
      SetFieldValueAsVariant(fld, AggrLevelArrValue[b][k].FinalizeAggregation);
    end;
    ResultAggrTable.Fields[BaseTable.FieldCount].Value := 1;
    for k := 0 to ActualValueFields.Count-1 do
      AggrLevelArrValue[b][k].ResetAggrHolder;
    ResultAggrTable.Post;
    for i := b to KeyLength-1 do
      ResultAggrTable.Rec.Value[i, dvvValueEh] := Unassigned;
  end;

  ColsTable.First;

  while not ColsTable.Eof do
  begin

    ResultAggrTable.Append;
    ResultAggrTable.Fields[BaseTable.FieldCount].Value := 1;
    ResultAggrTable.Post;

    for i := 0 to FActualColFields.Count do
    begin
      PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 39);
      ResultAggrTable.Rec.Value[FActualRowFields.Count+i, dvvValueEh] := ColsTable.Rec.Value[i, dvvValueEh];
    end;
    for i := 0 to FActualRowFields.Count-1 do
    begin
      PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 39);
      ResultAggrTable.Rec.Value[i, dvvValueEh] := Unassigned;
    end;

    ColsTable.Next;
  end;

  ResultAggrTable.Edit;
  for i := 0 to ActualValueFields.Count-1 do
  begin
    PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 40);
    fld := ResultAggrTable.Fields[KeyLength+i];
    SetFieldValueAsVariant(fld, AggrLevelArrValue[0][i].FinalizeAggregation);
  end;
  ResultAggrTable.Post;

  for i := 0 to KeyLength do
    for k := 0 to ActualValueFields.Count-1 do
    begin
      PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 40);
      AggrLevelArrValue[i][k].Free;
    end;

  LogTimeMetric('  MakeResultAggrTable', GetTickCountEh - ticks);
end;

procedure TPivotDataSourceEh.FillInverseGaussMatrixForLevel(ColsLevel: Integer);
var
  i,b,k: Integer;
  CompValue, NewCompValue: TVariantDynArray;
  AggrLevelArrValue: array of array of TPivotGridAggregateFunctionCalculatorEh;
  KeyLength, EqualLevel: Integer;
  DataFieldIndex: Integer;
  fld: TField;
begin
  BaseTable.First;

  KeyLength := FActualRowFields.Count + FActualColFields.Count;

  SetLength(CompValue, KeyLength);
  SetLength(NewCompValue, KeyLength);

  SetLength(AggrLevelArrValue, KeyLength+1);
  for i := 0 to KeyLength do
  begin
    SetLength(AggrLevelArrValue[i], ActualValueFields.Count);
    for k := 0 to ActualValueFields.Count-1 do
    begin
      PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 80);
      AggrLevelArrValue[i][k] := StandardAggregateFunctionCalculators[ActualValueFields[k].SumFunction].Create;
      AggrLevelArrValue[i][k].ResetAggrHolder;
    end;
  end;

  for i := 0 to KeyLength-1 do
  begin
    if i >= FActualColFields.Count then
      CompValue[i] := BaseTable.Fields[i].Value
    else if i < ColsLevel then
      CompValue[i] := BaseTable.Fields[i].Value
    else
      CompValue[i] := Unassigned;

    for k := 0 to ActualValueFields.Count-1 do
    begin
      PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 80);
      AggrLevelArrValue[i][k].ResetAggrHolder;
    end;
  end;

  while not BaseTable.Eof do
  begin

    for i := 0 to KeyLength-1 do
    begin
      PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 80);
      if i >= FActualColFields.Count then
        NewCompValue[i] := BaseTable.Fields[i].Value
      else if i < ColsLevel then
        NewCompValue[i] := BaseTable.Fields[i].Value
      else
        NewCompValue[i] := Unassigned;
    end;

    EqualLevel := VarArrayEqualLevelForDepth(CompValue, NewCompValue, KeyLength);

    if EqualLevel <= KeyLength - 2 then
    begin
      for b := KeyLength - 1 downto EqualLevel + 1 do
      begin
        PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 80);
        if (b < FActualColFields.Count) and (b >= ColsLevel) then Continue;

        if (ColsLevel = FActualColFields.Count) or (b > FActualColFields.Count) then 
        begin
          TransResultAggrTable.Append;

          for k := 0 to ActualValueFields.Count-1 do
          begin
            fld := TransResultAggrTable.Fields[BaseTable.FieldCount-ActualValueFields.Count+k];
            SetFieldValueAsVariant(fld, AggrLevelArrValue[b][k].FinalizeAggregation);
          end;
          TransResultAggrTable.Fields[BaseTable.FieldCount].Value := 1;
          TransResultAggrTable['ForGridAggrLevel'] := ColsLevel;

          TransResultAggrTable.Post;

          for i := 0 to b-1 do
          begin
            DataFieldIndex := TransResultAggrTable.Fields[i].FieldNo-1;
            TransResultAggrTable.Rec.Value[DataFieldIndex, dvvValueEh] := CompValue[i];
          end;
          for i := b to KeyLength-1 do
          begin
            DataFieldIndex := TransResultAggrTable.Fields[i].FieldNo-1;
            TransResultAggrTable.Rec.Value[DataFieldIndex, dvvValueEh] := Unassigned;
          end;
        end;

        for k := 0 to ActualValueFields.Count-1 do
          AggrLevelArrValue[b][k].ResetAggrHolder;
      end;
    end;

    for i := 0 to KeyLength-1 do
      for k := 0 to ActualValueFields.Count-1 do
      begin
        PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 80);
        AggrLevelArrValue[i][k].AggrValue(BaseTable.Fields[KeyLength+k].Value);
      end;

    CompValue := Copy(NewCompValue);

    BaseTable.Next;
  end;

  for b := KeyLength - 1 downto 1 do
  begin
    if (b < FActualColFields.Count) and (b >= ColsLevel) then Continue;

    PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 80);
    TransResultAggrTable.Append;

    for k := 0 to ActualValueFields.Count-1 do
    begin
      fld := TransResultAggrTable.Fields[BaseTable.FieldCount-ActualValueFields.Count+k];
      SetFieldValueAsVariant(fld, AggrLevelArrValue[b][k].FinalizeAggregation);
    end;
    TransResultAggrTable.Fields[BaseTable.FieldCount].Value := 1;
    for k := 0 to ActualValueFields.Count-1 do
      AggrLevelArrValue[b][k].ResetAggrHolder;

    TransResultAggrTable['ForGridAggrLevel'] := ColsLevel;
    TransResultAggrTable.Post;

    for i := 0 to b-1 do
    begin
      DataFieldIndex := TransResultAggrTable.Fields[i].FieldNo-1;
      TransResultAggrTable.Rec.Value[DataFieldIndex, dvvValueEh] := CompValue[i];
    end;

    for i := b to KeyLength-1 do
    begin
      DataFieldIndex := TransResultAggrTable.Fields[i].FieldNo-1;
      TransResultAggrTable.Rec.Value[DataFieldIndex, dvvValueEh] := Unassigned;
    end;
  end;

  for i := 0 to KeyLength do
    for k := 0 to ActualValueFields.Count-1 do
      AggrLevelArrValue[i][k].Free;

end;

procedure TPivotDataSourceEh.MakeInverseGaussMatrix;
var
  DataField: TMTNumericDataFieldEh;
  i: Integer;
  TransDataStruct: TMTDataStructEh;
  SortText: String;
  ticks: LongWord;
  SortFields: String;

  function GetColFieldsSortTextForLevel(Level: Integer): String;
  var
    i: Integer;
  begin
    Result := '';
    for i := 0 to Level-1 do
    begin
      Result := Result + '[' + FActualColFields[i] + ']';
      if i <> Level-1 then
        Result := Result + ', ';
    end;
  end;

begin
  ticks := GetTickCountEh;
  PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 40);

  TransResultAggrTable.DestroyTable;
  TransResultAggrTable.RecordsView.MemTableData.DataStruct.Assign(
    BaseTable.RecordsView.MemTableData.DataStruct);

  TransDataStruct := TransResultAggrTable.RecordsView.MemTableData.DataStruct;
  DataField := TMTNumericDataFieldEh(TransDataStruct.CreateField(TMTNumericDataFieldEh));
  DataField.FieldName := '%RecType';
  DataField.NumericDataType := fdtIntegerEh;

  DataField := TMTNumericDataFieldEh(TransDataStruct.CreateField(TMTNumericDataFieldEh));
  DataField.FieldName := 'ForGridAggrLevel';
  DataField.NumericDataType := fdtIntegerEh;

  PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 40);

  TransResultAggrTable.Open;

  if not StructureIsConsistent then Exit;

  for i := 0 to FActualColFields.Count-1 do
  begin
    PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 40);
    TransResultAggrTable.Fields[FActualRowFields.Count + i].Index := i;
  end;

  SortFields := GetSortFieldsFromList(FActualColFields)  + ', ' + GetSortFieldsFromList(FActualRowFields);
  BaseTable.SortByFields(SortFields);
  for i := 0 to FActualColFields.Count-1 do
  begin
    PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 60);
    BaseTable.Fields[FActualRowFields.Count + i].Index := i;
  end;

  for i := ActualColFields.Count downto 1 do
  begin
    SortText := GetColFieldsSortTextForLevel(i) + ',' + GetSortFieldsFromList(FActualRowFields);
    BaseTable.SortByFields(SortText);
    PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 80);
    FillInverseGaussMatrixForLevel(i);
    PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 80);
  end;

  for i := 0 to FActualRowFields.Count-1 do
  begin
    PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 80);
    BaseTable.Fields[FActualColFields.Count + i].Index := i;
  end;

  SortFields := GetSortFieldsFromList(FActualRowFields) + ', ' +
                GetSortFieldsFromList(FActualColFields);
  BaseTable.SortByFields(SortFields);
  PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 99);

  LogTimeMetric('  MakeTransResultAggrTable', GetTickCountEh-ticks);
end;

procedure TPivotDataSourceEh.SetDataFilter;
begin

  FBuildDataProgressTicks := GetTickCountEh;
  FCheckCancelRequestTime := GetTickCountEh;
  PivotDataStartChanging;

  try
    SetBaseTableFilter;
    PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 1);
    BuildGridDataForBaseTable;
    PivotDataChangeProgress(GetTickCountEh - FBuildDataProgressTicks, 100);
  except
    on E: EAbort do
      
    else
      raise;
  end;

  PivotDataFinishChanging;
  LogTimeMetric('SetDataFilter', GetTickCountEh - FBuildDataProgressTicks)
end;

procedure TPivotDataSourceEh.SetBaseTableFilter;
var
  i: Integer;
  s, sv: String;
  PivotField: TPivotFieldEh;
  ConnOp: String;
begin
  s := '';

  for i := 0 to PivotFields.Count-1 do
  begin
    PivotField := PivotFields[i];
    sv := PivotField.GetFilterExpressionAsStr;
    if sv <> '' then
    begin
      if s = ''
        then ConnOp := ''
        else ConnOp := ' AND ';

      s := s + ConnOp + sv;
    end;
  end;

  BaseTable.Filter := s;
  BaseTable.Filtered := True;
end;

function TPivotDataSourceEh.StructureIsConsistent: Boolean;
begin
  Result := True;
end;


{ TPivotGridScrollBarPanelControl }

constructor TPivotGridScrollBarPanelControl.Create(AOwner: TComponent; AKind: TScrollBarKind);
begin
  inherited Create(AOwner, AKind);
  FSelInfoPanel := TPivotGridSelectionInfoPanel.Create(Self);
  FSelInfoPanel.Parent := Self;
end;


destructor TPivotGridScrollBarPanelControl.Destroy;
begin
  FreeAndNil(FSelInfoPanel);
  inherited Destroy;
end;

procedure TPivotGridScrollBarPanelControl.CreateHandle;
begin
  inherited CreateHandle;
end;

procedure TPivotGridScrollBarPanelControl.GridSelectionChanged;
begin
  FSelInfoPanel.GridSelectionChanged;
  Resize;
end;

procedure TPivotGridScrollBarPanelControl.Resize;
begin
  inherited Resize;
  if not HandleAllocated then Exit;

  if FSelInfoPanel.FAggrText <> '' then
  begin
    if UseRightToLeftAlignment then
    begin
      FSelInfoPanel.Width := FSelInfoPanel.InfoWidth;
      ScrollBar.SetBounds(0, ScrollBar.Top, Width - FSelInfoPanel.Width, ScrollBar.Height);
      FSelInfoPanel.SetBounds(Width - FSelInfoPanel.Width, 0, FSelInfoPanel.Width, Height);
    end else
    begin
      FSelInfoPanel.SetBounds(0, 0, FSelInfoPanel.InfoWidth, Height);
      ScrollBar.SetBounds(FSelInfoPanel.Width, ScrollBar.Top, ScrollBar.Width - FSelInfoPanel.Width, ScrollBar.Height);
    end;
    FSelInfoPanel.Visible := True;
  end else
    FSelInfoPanel.Visible := False;
end;

{ TPivotGridSelectionInfoPanel }

constructor TPivotGridSelectionInfoPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

end;

destructor TPivotGridSelectionInfoPanel.Destroy;
begin

  inherited Destroy;
end;

function TPivotGridSelectionInfoPanel.GetGrid: TCustomPivotGridEh;
begin
  Result := TCustomPivotGridEh(Owner.Owner);
end;

procedure TPivotGridSelectionInfoPanel.GridSelectionChanged;
var
  i, j: Integer;
  PivotCel: TPivotCellEh;
  Sel: TGridRect;
  SumVal, CellCountVal, MinVal, MaxVal, AvgVal, CountVal: Variant;
  OldAggrText, DivText: String;
begin
  if not Grid.IsMultiSelected and (FAggrText = '') then
    Exit;

  if Grid.IsMultiSelected then
  begin
    Sel := Grid.Selection;
    SumVal := Null;
    CountVal := Null;
    MinVal := Null;
    MaxVal := Null;
    AvgVal := Null;
    CellCountVal := 0;
    OldAggrText := FAggrText;
    for i := Sel.Left to Sel.Right do
    begin
      for j := Sel.Top to Sel.Bottom do
      begin
        PivotCel := Grid.VisPivotGridArray[i, j];
        CellCountVal := CellCountVal + 1;
        if (PivotCel.ShowValue = True) and
           (VarType(PivotCel.Value) in [varDouble, varSmallint, varInteger, varSingle, varCurrency]) then
        begin
          SumVal := VarToDoubleDef(SumVal, 0) + PivotCel.Value;
          CountVal := VarToDoubleDef(CountVal, 0) + 1;
          if PivotCel.Value >= VarToDoubleDef(MaxVal, PivotCel.Value) then
            MaxVal := PivotCel.Value;
          if PivotCel.Value <= VarToDoubleDef(MinVal, PivotCel.Value) then
            MinVal := PivotCel.Value;
        end;
      end;
    end;
    FAggrText := '';
    DivText := '';
    if not VarIsNull(SumVal) then
    begin
      FAggrText := FAggrText + DivText + EhLibLanguageConsts.GridSelectionInfo_Sum + ': ' + FormatFloat(',#.####', SumVal);
      DivText := '    ';
    end;
    if not VarIsNull(CountVal) then
    begin
      FAggrText := FAggrText + DivText + EhLibLanguageConsts.GridSelectionInfo_Cnt + ': ' + FormatFloat(',#', CountVal);
      DivText := '    ';
      if SumVal <> 0 then
        AvgVal := SumVal / CountVal;
    end;
    if not VarIsNull(MinVal) then
    begin
      FAggrText := FAggrText + DivText + EhLibLanguageConsts.GridSelectionInfo_Min + ': ' + FormatFloat(',#.####', MinVal);
      DivText := '    ';
    end;
    if not VarIsNull(MaxVal) then
    begin
      FAggrText := FAggrText + DivText + EhLibLanguageConsts.GridSelectionInfo_Max + ': ' + FormatFloat(',#.####', MaxVal);
      DivText := '    ';
    end;
    if not VarIsNull(AvgVal) then
    begin
      FAggrText := FAggrText + DivText + EhLibLanguageConsts.GridSelectionInfo_Evg + ': ' + FormatFloat(',#.####', AvgVal);
      DivText := '    ';
    end;
    FAggrText := FAggrText + DivText + EhLibLanguageConsts.CellCountEh + ': ' + FloatToStr(CellCountVal);
    if OldAggrText <> FAggrText then
      Grid.UpdateBoundaries;
  end else
  begin
    FAggrText := '';
    Grid.UpdateBoundaries;
  end;
  Invalidate;
end;

function TPivotGridSelectionInfoPanel.HaveData: Boolean;
begin
  Result := FAggrText <> '';
end;

procedure TPivotGridSelectionInfoPanel.Paint;
begin
  Canvas.Brush.Color := StyleServices.GetSystemColor(Grid.FixedColor);
  Canvas.Font := Grid.Font;
  Canvas.Font.Color := StyleServices.GetSystemColor(Grid.Font.Color);

  Canvas.TextRect(ClientRect, 2, 2, FAggrText);
end;

procedure TPivotGridSelectionInfoPanel.WMEraseBackground(var Message: TWmEraseBkgnd);
begin
  Message.Result := 1;
end;

function TPivotGridSelectionInfoPanel.InfoWidth: Integer;
begin
  if not HandleAllocated or (FAggrText = '') then
  begin
    Result := 0;
    Exit;
  end;

  Canvas.Font := Grid.Font;
  Result := Canvas.TextWidth(FAggrText) + 6;
end;

{ TPivotGridScrollBarEh }

function TPivotGridScrollBarEh.CheckScrollBarMustBeShown: Boolean;
begin
  if TPivotGridScrollBarPanelControl(TCustomPivotGridEh(Grid).HorzScrollBarPanelControl).FSelInfoPanel.HaveData then
    Result := True
  else
    Result := inherited CheckScrollBarMustBeShown;
end;

{ TPivotRowsGroupingTreeEh }

constructor TPivotAxisGroupingTreeEh.Create(AGrid: TCustomPivotGridEh;
  ItemClass: TTreeNodeClassEh; AAxisDir: TPivotAxisDirectionEh);
begin
  inherited Create(ItemClass);
  FGrid := AGrid;
  FFlatList := TObjectListEh.Create;
  FAxisDir := AAxisDir;
end;

destructor TPivotAxisGroupingTreeEh.Destroy;
begin
  FreeAndNil(FFlatList);
  inherited Destroy;
end;

procedure TPivotAxisGroupingTreeEh.ForAllNode(AProg: TTreeNodeIterativeEvent;
  Param: TObject; RowAggrBeforeData: Boolean; IncludeCollapsed: Boolean);

  procedure DoForAllNode(CurNode: TPivotAxisTreeNodeEh);
  var
    i: Integer;
  begin
    for i := 0 to CurNode.Count-1 do
    begin
      if RowAggrBeforeData then
      begin
        AProg(CurNode[i], Param);
        if IncludeCollapsed or CurNode[i].Expanded then
          DoForAllNode(TPivotAxisTreeNodeEh(CurNode[i]))
      end else
      begin
        if IncludeCollapsed or CurNode[i].Expanded then
          DoForAllNode(TPivotAxisTreeNodeEh(CurNode[i]));
        AProg(CurNode[i], Param);
      end;
    end;
  end;

var
  i: Integer;
begin
  for i := 0 to Root.Count-1 do
  begin
    if RowAggrBeforeData then
    begin
      AProg(Root[i], Param);
      if IncludeCollapsed or Root[i].Expanded then
        DoForAllNode(TPivotAxisTreeNodeEh(Root[i]))
    end else
    begin
      if IncludeCollapsed or Root[i].Expanded then
        DoForAllNode(TPivotAxisTreeNodeEh(TPivotAxisTreeNodeEh(Root[i])));
      AProg(Root[i], Param);
    end;
  end;
end;

function TPivotAxisGroupingTreeEh.GetRoot: TPivotAxisTreeNodeEh;
begin
  Result := TPivotAxisTreeNodeEh(inherited Root);
end;

procedure TPivotAxisGroupingTreeEh.SetAxisCellType;
begin
  ForAllNode(SetAxisCellTypeProc, nil, False, False);
end;

procedure TPivotAxisGroupingTreeEh.SetAxisCellTypeProc(Sender: TBaseTreeNodeEh; Param: TObject);
var
  i: Integer;
  PivotCell: TPivotCellEh;
  AxisNode: TPivotAxisTreeNodeEh;
  GridRowIndex: Integer;
  GridColIndex: Integer;
  vi: Integer;
begin
  AxisNode := TPivotAxisTreeNodeEh(Sender);
  if AxisDir = padVerticalEh then
  begin
    GridRowIndex := AxisNode.InPivotGridArrayIndex;
    for i := 0 to ActualAxisFields.Count - 1 do
    begin
      if (AxisNode.Level = ActualAxisFields.Count) or
         (AxisNode.Level - 1 > i) then
      begin
        for vi := 0 to Grid.InRowsAxisValuesCount - 1 do
        begin
          PivotCell := Grid.PivotGridArray[i, GridRowIndex + vi];
          PivotCell.AxisValueDetails.AxisCellType := actGroupCellEh;
        end;
      end else
      begin
        for vi := 0 to Grid.InRowsAxisValuesCount - 1 do
        begin
          PivotCell := Grid.PivotGridArray[i, GridRowIndex + vi];
          PivotCell.AxisValueDetails.AxisCellType := actTotalCellEh;
        end;
      end;
    end;
  end else
  begin
    GridColIndex := AxisNode.InPivotGridArrayIndex;
    for i := 0 to ActualAxisFields.Count - 1 do
    begin
      if (AxisNode.Level = ActualAxisFields.Count) or
         (AxisNode.Level - 1 > i) then
      begin
        for vi := 0 to Grid.InColsAxisValuesCount - 1 do
        begin
          PivotCell := Grid.PivotGridArray[GridColIndex + vi, i + 1];
          PivotCell.AxisValueDetails.AxisCellType := actGroupCellEh;
        end;
      end else
      begin
        for vi := 0 to Grid.InColsAxisValuesCount - 1 do
        begin
          PivotCell := Grid.PivotGridArray[GridColIndex + vi, i + 1];
          PivotCell.AxisValueDetails.AxisCellType := actTotalCellEh;
        end;
      end;
    end;
  end;
end;

procedure TPivotAxisGroupingTreeEh.SetNextRowNum(Sender: TPivotAxisTreeNodeEh; Param: TObject);
var
  i: Integer;
  RowsTreeNode: TPivotAxisTreeNodeEh;
  PivotCell: TPivotCellEh;

  procedure SetAxisNodeForRestValueCells(PivotArrayColIndex, PivotArrayRowIndex: Integer;  AxisNode: TPivotAxisTreeNodeEh);
  var
    ri: Integer;
    ValPivotCel: TPivotCellEh;
  begin
    for ri := 1 to Grid.InRowsAxisValuesCount-1 do
    begin
      ValPivotCel := Grid.PivotGridArray[PivotArrayColIndex, PivotArrayRowIndex + ri];
      ValPivotCel.RowsAxisValueDetails.AxisTreeNode := AxisNode;
    end;
  end;

begin
  Sender.FInPivotGridArrayIndex := FCurIncAxisNum * Grid.InRowsAxisValuesCount + Grid.FStartDataRow;

  for i := Grid.ActualRowFields.Count-1 downto Sender.Level-1 do
  begin
    PivotCell := Grid.PivotGridArray[i, Sender.FInPivotGridArrayIndex];
    PivotCell.AxisValueDetails.AxisTreeNode := Sender;
    SetAxisNodeForRestValueCells(i, Sender.FInPivotGridArrayIndex, Sender);
  end;

  if Sender.Level-2 >= 0 then
  begin
    RowsTreeNode := Sender.Parent;
    for i := Sender.Level-2 downto 0 do
    begin
      PivotCell := Grid.PivotGridArray[i, Sender.FInPivotGridArrayIndex];
      PivotCell.AxisValueDetails.AxisTreeNode := RowsTreeNode;
      SetAxisNodeForRestValueCells(i, Sender.FInPivotGridArrayIndex, RowsTreeNode);
      RowsTreeNode := RowsTreeNode.Parent;
    end;
  end;
  Inc(FCurIncAxisNum);
end;

procedure TPivotAxisGroupingTreeEh.SetNextColNum(Sender: TPivotAxisTreeNodeEh; Param: TObject);
var
  i: Integer;
  ColsTreeNode: TPivotAxisTreeNodeEh;
  PivotCel: TPivotCellEh;

  procedure SetAxisNodeForRestValueCells(PivotArrayColIndex, PivotArrayRowIndex: Integer;  AxisNode: TPivotAxisTreeNodeEh);
  var
    ci: Integer;
    ValPivotCel: TPivotCellEh;
  begin
    for ci := 1 to Grid.InColsAxisValuesCount-1 do
    begin
      ValPivotCel := Grid.PivotGridArray[PivotArrayColIndex + ci, PivotArrayRowIndex];
      ValPivotCel.ColsAxisValueDetails.AxisTreeNode := AxisNode;
    end;
  end;

begin
  Sender.FInPivotGridArrayIndex := FCurIncAxisNum * Grid.InColsAxisValuesCount + Grid.FStartDataCol;

  for i := Grid.ActualColFields.Count-1 downto Sender.Level-1 do
  begin
    PivotCel := Grid.PivotGridArray[Sender.FInPivotGridArrayIndex, i + 1];
    PivotCel.ColsAxisValueDetails.AxisTreeNode := Sender;
    SetAxisNodeForRestValueCells(Sender.FInPivotGridArrayIndex, i + 1, Sender);
  end;

  if Sender.Level-2 >= 0 then
  begin
    ColsTreeNode := Sender.Parent;
    for i := Sender.Level-2 downto 0 do
    begin
      PivotCel := Grid.PivotGridArray[Sender.FInPivotGridArrayIndex, i + 1];
      PivotCel.ColsAxisValueDetails.AxisTreeNode := ColsTreeNode;
      SetAxisNodeForRestValueCells(Sender.FInPivotGridArrayIndex, i + 1, ColsTreeNode);
      ColsTreeNode := ColsTreeNode.Parent;
    end;
  end;

  Inc(FCurIncAxisNum);
end;

procedure TPivotAxisGroupingTreeEh.SetGridArrayAxisNumbers;
var
  SetNextAxisNumMethod: TPivotTreeNodeIterativeEvent;
begin
  if AxisDir = padVerticalEh then
  begin
    FCurIncAxisNum := 0;
    SetNextAxisNumMethod := SetNextRowNum;
  end else
  begin
    FCurIncAxisNum := 0;
    SetNextAxisNumMethod := SetNextColNum;
  end;
  ForAllNode(TTreeNodeIterativeEvent(SetNextAxisNumMethod), nil, False, True);
end;

function TPivotAxisGroupingTreeEh.CompareAxisValues(AxisPos1, AxisPos2, OppositeAxisPos: Integer): TVariantRelationship;
begin
  if AxisDir = padVerticalEh then
    Result := DBVarCompareValue(
      Grid.PivotGridArray[OppositeAxisPos, AxisPos1].Value,
      Grid.PivotGridArray[OppositeAxisPos, AxisPos2].Value
    )
  else
    Result := DBVarCompareValue(
      Grid.PivotGridArray[AxisPos1, OppositeAxisPos].Value,
      Grid.PivotGridArray[AxisPos2, OppositeAxisPos].Value
    );
end;

function TPivotAxisGroupingTreeEh.ComparePivotAxisPoses(Node1,
  Node2: TBaseTreeNodeEh; ParamSort: TObject): Integer;
var
  Col, Row1, Row2: Integer;
  Result1: TVariantRelationship;
  BackSign: Integer;
begin
  Result := 0;
  if FSortOrder = soAscEh
    then BackSign := 1
    else BackSign := -1;
  Col := __Int(ParamSort);
  Row1 := TPivotAxisTreeNodeEh(Node1).InPivotGridArrayIndex;
  Row2 := TPivotAxisTreeNodeEh(Node2).InPivotGridArrayIndex;
  Result1 := CompareAxisValues(Row1, Row2, Col);
  case Result1 of
    vrEqual: Result := 0;
    vrLessThan: Result := -1 * BackSign;
    vrGreaterThan: Result := 1 * BackSign;
    vrNotEqual: raise Exception.Create('Error Message');
  end;
end;

procedure TPivotAxisGroupingTreeEh.SortData(Level, PivotGridAxisLine: Integer; ASortOrder: TSortOrderEh);
var
  CurNode: TPivotAxisTreeNodeEh;
begin
  FSortOrder := ASortOrder;
  if Level = -1 then
    TPivotAxisTreeNodeEh(Root).SortData(ComparePivotAxisPoses, __TObject(PivotGridAxisLine), True)
  else
  begin
    if Level = 1 then
      TPivotAxisTreeNodeEh(Root).SortData(ComparePivotAxisPoses, __TObject(PivotGridAxisLine), False)
    else
    begin
      CurNode := TPivotAxisTreeNodeEh(GetFirst);
      while CurNode <> nil do
      begin
        if Level-1 = CurNode.Level then
          CurNode.SortData(ComparePivotAxisPoses, __TObject(PivotGridAxisLine), False);
        CurNode := TPivotAxisTreeNodeEh(GetNext(CurNode));
      end;
    end;
  end;
end;

procedure TPivotAxisGroupingTreeEh.WriteTree(sl: TStrings; AxisAggrBeforeData: Boolean);
begin
  ForAllNode(WriteTreeLine, sl, AxisAggrBeforeData, True);
end;

procedure TPivotAxisGroupingTreeEh.WriteTreeLine(Sender: TBaseTreeNodeEh; Param: TObject);
var
  Node: TPivotAxisTreeNodeEh;
begin
  Node := TPivotAxisTreeNodeEh(Sender);
  TStrings(Param).Add(DupeString(' ', Node.Level) + Node.Text + ' : ' + IntToStr(Node.InPivotGridArrayIndex));
end;

procedure TPivotAxisGroupingTreeEh.BuildTree;
var
  CompValue: TVariantDynArray;
  UpToLevel: Integer;

  procedure ColsTableNext;
  var
    ct: TDataSet;
  begin
    ct := AxisTable;
    ct.Next;

    while not ct.Eof
      and (ct.Fields[ActualAxisFields.Count].Value <> 0)
    do
      ct.Next;
  end;

  procedure AssignValue(var CompValue: TVariantDynArray);
  var
    i: Integer;
  begin
    for i := 0 to ActualAxisFields.Count-1 do
      CompValue[i] := AxisTable.Fields[i].Value;
  end;

  procedure AssignVarArrToVarArr(var FromValue, ToValue: TVariantDynArray);
  var
    i: Integer;
  begin
    for i := 0 to Length(FromValue)-1 do
      ToValue[i] := FromValue[i];
  end;

  procedure BuildNodeTree(Node: TPivotAxisTreeNodeEh; var KeyValue: TVariantDynArray; var UpToLevel: Integer);
  var
    ChNode: TPivotAxisTreeNodeEh;
    NextVals: TVariantDynArray;
    EqLev: Integer;
    i: Integer;
  begin
    while True do
    begin
      ChNode := TPivotAxisTreeNodeEh(AddChild(VarToStrDef(KeyValue[Node.Level], '<Null>'), Node, nil));

      SetLength(ChNode.FKeyValue, ActualAxisFields.Count);
      for i := 0 to ActualAxisFields.Count-1 do
      begin
        if ChNode.Level-1 >= i then
          ChNode.KeyValue[i] := KeyValue[i]
        else
          ChNode.KeyValue[i] := Unassigned;
      end;

      if ChNode.Level < ActualAxisFields.Count then
      begin
        BuildNodeTree(ChNode, KeyValue, UpToLevel);
        if AxisTable.Eof then
          Exit;
        if UpToLevel < Node.Level then
          Exit;
      end else if ChNode.Level = ActualAxisFields.Count then
      begin
        ColsTableNext;
        if AxisTable.Eof then
          Exit;
        SetLength(NextVals, ActualAxisFields.Count);
        AssignValue(NextVals);
        EqLev := VarArrayEqualLevelForDepth(KeyValue, NextVals, ActualAxisFields.Count-1);
        AssignVarArrToVarArr(NextVals, KeyValue);
        if EqLev = ActualAxisFields.Count-1 then
          Continue
        else
        begin
          UpToLevel := EqLev;
          Exit;
        end;
      end;
    end;
  end;

begin
  Clear;

  SetLength(CompValue, ActualAxisFields.Count);

  AxisTable.First;
  if AxisTable.Eof then Exit;
  AssignValue(CompValue);
  BuildNodeTree(TPivotAxisTreeNodeEh(Root), CompValue, UpToLevel);
end;

procedure TPivotAxisGroupingTreeEh.BuildFlatList;
begin
  FFlatList.Clear;
  ForAllNode(FlatListAddItem, nil, AxisAggrBeforeData, False);
end;

procedure TPivotAxisGroupingTreeEh.FlatListAddItem(Sender: TBaseTreeNodeEh;
  Param: TObject);
begin
  FFlatList.Add(Sender);
end;

function TPivotAxisGroupingTreeEh.GetActualAxisFields: TStrings;
begin
  if AxisDir = padVerticalEh
    then Result := Grid.PivotDataSource.ActualRowFields
    else Result := Grid.PivotDataSource.ActualColFields;
end;

function TPivotAxisGroupingTreeEh.GetAxisAggrBeforeData: Boolean;
begin
  if AxisDir = padVerticalEh
    then Result := Grid.RowAxisOptions.TotalsBeforeData
    else Result := Grid.ColumnAxisOptions.TotalsBeforeData;
end;

function TPivotAxisGroupingTreeEh.GetAxisTable: TMemTableEh;
begin
  if AxisDir = padVerticalEh
    then Result := Grid.PivotDataSource.RowsTable
    else Result := Grid.PivotDataSource.ColsTable;
end;

function TPivotAxisGroupingTreeEh.GetFlatList(Index: Integer): TPivotAxisTreeNodeEh;
begin
  Result := TPivotAxisTreeNodeEh(FFlatList[Index]);
end;

function TPivotAxisGroupingTreeEh.GetFlatListCount: Integer;
begin
  Result := FFlatList.Count;
end;

procedure TPivotAxisGroupingTreeEh.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TPivotAxisGroupingTreeEh.EndUpdate;
begin
  Dec(FUpdateCount);
end;

procedure TPivotAxisGroupingTreeEh.SetExpandedState(Sender: TPivotAxisTreeNodeEh; Param: TObject);
begin
  if Sender.Level = FExpandedStateIterativeLevel then
  begin
    Sender.Expanded := Boolean(__Int(Param));
    Sender.PivotKeyValueState.Expanded := Sender.Expanded;
  end;
end;

procedure TPivotAxisGroupingTreeEh.SetLevelExpanded(ALevel: Integer; IsExpanded: Boolean);
var
  AMethod: TPivotTreeNodeIterativeEvent;
begin
  BeginUpdate;
  try
    FExpandedStateIterativeLevel := ALevel;
    AMethod := SetExpandedState;
    ForAllNode(TTreeNodeIterativeEvent(AMethod), __TObject(Integer(IsExpanded)), AxisAggrBeforeData, True);
  finally
    EndUpdate;
  end;
  ExpandedChanged(nil);
end;

procedure TPivotAxisGroupingTreeEh.ExpandedChanged(Node: TBaseTreeNodeEh);
begin
  inherited ExpandedChanged(Node);
  if not Updating then
    if AxisDir = padVerticalEh
      then Grid.RowExpandedChanged(TPivotAxisTreeNodeEh(Node))
      else Grid.ColExpandedChanged(TPivotAxisTreeNodeEh(Node));
end;

function TPivotAxisGroupingTreeEh.Updating: Boolean;
begin
  Result := FUpdateCount > 0;
end;

function TPivotAxisGroupingTreeEh.GetExpandedCounts(ALevel: Integer): Integer;
begin
  FGetExpandedCountsResult := 0;
  ForAllNode(CheckExpanded, __TObject(ALevel), True, True);
  Result := FGetExpandedCountsResult;
end;

procedure TPivotAxisGroupingTreeEh.CheckExpanded(Sender: TBaseTreeNodeEh; Param: TObject);
begin
  if (TPivotAxisTreeNodeEh(Sender).Level = Integer(Param)) and
      TPivotAxisTreeNodeEh(Sender).Expanded
  then
    FGetExpandedCountsResult := FGetExpandedCountsResult + 1;
end;

procedure TPivotAxisGroupingTreeEh.UpdateExpandedState;
begin
  BeginUpdate;
  ForAllNode(SetExpandedStateFromPivotKeyValue, nil, False, True);
  EndUpdate;
end;

procedure TPivotAxisGroupingTreeEh.SetExpandedStateFromPivotKeyValue(Sender: TBaseTreeNodeEh; Param: TObject);
begin
  if TPivotAxisTreeNodeEh(Sender).PivotKeyValueState <> nil then
    TPivotAxisTreeNodeEh(Sender).Expanded := TPivotAxisTreeNodeEh(Sender).PivotKeyValueState.Expanded;
end;

{ TPivotRowsTreeNodeEh }

constructor TPivotAxisTreeNodeEh.Create;
begin
  inherited Create;
  Expanded := True;
end;

function TPivotAxisTreeNodeEh.GetItem(const Index: Integer): TPivotAxisTreeNodeEh;
begin
  Result := TPivotAxisTreeNodeEh(inherited Items[Index]);
end;

function TPivotAxisTreeNodeEh.GetOwner: TPivotAxisGroupingTreeEh;
begin
  Result := TPivotAxisGroupingTreeEh(inherited TreeList);
end;

function TPivotAxisTreeNodeEh.GetParent: TPivotAxisTreeNodeEh;
begin
  Result := TPivotAxisTreeNodeEh(inherited Parent);
end;

{ TPivotFieldDataTypeDefEh }

procedure TPivotFieldDataTypeDefEh.SetDataType(const Value: TFieldType);
begin
  FDataType := Value;
end;

procedure TPivotFieldDataTypeDefEh.SetPrecision(const Value: Integer);
begin
  FPrecision := Value;
end;

procedure TPivotFieldDataTypeDefEh.SetSize(const Value: Integer);
begin
  FSize := Value;
end;

{ TPivotGridAggregateFunctionCalculatorEh }

constructor TPivotGridAggregateFunctionCalculatorEh.Create;
begin
  inherited Create;
end;

destructor TPivotGridAggregateFunctionCalculatorEh.Destroy;
begin
  inherited Destroy;
end;

class function TPivotGridAggregateFunctionCalculatorEh.DisplayName: String;
begin
  Result := '<AggregateFunction>';
end;

procedure TPivotGridAggregateFunctionCalculatorEh.AggrValue(const AValue: Variant);
begin
end;

function TPivotGridAggregateFunctionCalculatorEh.FinalizeAggregation: Variant;
begin
  Result := Value;
end;

procedure TPivotGridAggregateFunctionCalculatorEh.ResetAggrHolder;
begin
  Value := Null;
  SrvObj := nil;
  SetLength(SrvVars, 0);
end;

{ TPivotGridSumFunctionCalculatorEh }

procedure TPivotGridSumFunctionCalculatorEh.AggrValue(const AValue: Variant);
begin
  if VarIsNull(Value) then
    Value := AValue
  else
  begin
    if not VarIsNull(AValue) then
      Value := Value + AValue;
  end;
end;

class function TPivotGridSumFunctionCalculatorEh.DisplayName: String;
begin
  Result := EhLibLanguageConsts.PivotSumFunctionSum;
end;

{ TPivotGridCountFunctionCalculatorEh }

procedure TPivotGridCountFunctionCalculatorEh.AggrValue(const AValue: Variant);
begin
  if not VarIsNull(AValue) then
  begin
    if VarIsNull(Value)
      then Value := 1
      else Value := Value + 1;
  end;
end;

class function TPivotGridCountFunctionCalculatorEh.DisplayName: String;
begin
  Result := EhLibLanguageConsts.PivotSumFunctionCount;
end;

{ TPivotGridAverageFunctionCalculatorEh }

class function TPivotGridAverageFunctionCalculatorEh.DisplayName: String;
begin
  Result := EhLibLanguageConsts.PivotSumFunctionAvg;
end;

procedure TPivotGridAverageFunctionCalculatorEh.ResetAggrHolder;
begin
  Value := Null;
  SrvObj := nil;

  SetLength(SrvVars, 2);
  SrvVars[0] := 0;
  SrvVars[1] := Null;
end;

procedure TPivotGridAverageFunctionCalculatorEh.AggrValue(const AValue: Variant);
begin
  SrvVars[0] := SrvVars[0] + 1;
  if VarIsNull(SrvVars[1])
    then SrvVars[1] := AValue
    else SrvVars[1] := SrvVars[1] + AValue;
end;

function TPivotGridAverageFunctionCalculatorEh.FinalizeAggregation: Variant;
begin
  if (SrvVars[0] = 0) or VarIsNull(SrvVars[1]) then
    Value := Null
  else
    Value := SrvVars[1] / SrvVars[0];
  Result := Value;
end;

{ TPivotGridMaxFunctionCalculatorEh }

class function TPivotGridMaxFunctionCalculatorEh.DisplayName: String;
begin
  Result := EhLibLanguageConsts.PivotSumFunctionMax;
end;

procedure TPivotGridMaxFunctionCalculatorEh.AggrValue(const AValue: Variant);
begin
  if VarIsNull(Value) then
    Value := AValue
  else if not VarIsNull(AValue) then
  begin
    if AValue > Value then
      Value := AValue;
  end;
end;

{ TPivotGridMinFunctionCalculatorEh }

class function TPivotGridMinFunctionCalculatorEh.DisplayName: String;
begin
  Result := EhLibLanguageConsts.PivotSumFunctionMin;
end;

procedure TPivotGridMinFunctionCalculatorEh.AggrValue(const AValue: Variant);
begin
  if VarIsNull(Value) then
    Value := AValue
  else if not VarIsNull(AValue) then
  begin
    if AValue < Value then
      Value := AValue
  end;
end;

{ TPivotGridCountDistinctFunctionCalculatorEh }

class function TPivotGridCountDistinctFunctionCalculatorEh.DisplayName: String;
begin
  Result := EhLibLanguageConsts.PivotSumFunctionCountDistinct;
end;

procedure TPivotGridCountDistinctFunctionCalculatorEh.ResetAggrHolder;
begin
  Value := Null;
  FreeAndNil(SrvObj);
  SrvObj := TStringList.Create;
  TStringList(SrvObj).CaseSensitive := True;
  SetLength(SrvVars, 0);
end;

procedure TPivotGridCountDistinctFunctionCalculatorEh.AggrValue(const AValue: Variant);
begin
  TStringList(SrvObj).Add(VarToStr(AValue))
end;

function TPivotGridCountDistinctFunctionCalculatorEh.FinalizeAggregation: Variant;
var
  s: String;
  i: Integer;
  DistCnt: Integer;
begin
  TStringList(SrvObj).Sort;
  s := '';
  DistCnt := 0;
  for i := 0 to TStringList(SrvObj).Count-1 do
  begin
    if s <> TStringList(SrvObj)[i] then
    begin
      Inc(DistCnt);
      s := TStringList(SrvObj)[i];
    end;
  end;
  FreeAndNil(SrvObj);
  Value := DistCnt;
  Result := Value;
end;

{ TPivotGridProductFunctionCalculatorEh }

class function TPivotGridProductFunctionCalculatorEh.DisplayName: String;
begin
  Result := EhLibLanguageConsts.PivotSumFunctionProduct;
end;

procedure TPivotGridProductFunctionCalculatorEh.AggrValue(
  const AValue: Variant);
begin
  if VarIsNull(Value) then
    Value := AValue
  else
  begin
    if not VarIsNull(AValue) then
      Value := Value * AValue;
  end;
end;

{ TPivotGridStDevFunctionCalculatorEh }

constructor TPivotGridStDevFunctionCalculatorEh.Create;
begin
  inherited Create;
  Deduction := 1;
  DoSqrt := True;
end;

class function TPivotGridStDevFunctionCalculatorEh.DisplayName: String;
begin
  Result := EhLibLanguageConsts.PivotSumFunctionStDev;
end;

procedure TPivotGridStDevFunctionCalculatorEh.ResetAggrHolder;
begin
  Value := Null;
  SetLength(SrvVars, 0);
end;

procedure TPivotGridStDevFunctionCalculatorEh.AggrValue(const AValue: Variant);
begin
  if not VarIsNull(AValue) then
  begin
    SetLength(SrvVars, Length(SrvVars)+1);
    SrvVars[Length(SrvVars)-1] := AValue;
  end;
end;

function TPivotGridStDevFunctionCalculatorEh.FinalizeAggregation: Variant;
var
  AvrVal, SumVal: Variant;
  CountVal: Integer;
  i: Integer;
  ResVars: TVariantDynArray;
  SquareSum: Variant;
begin
  SumVal := Null;
  CountVal := 0;
  for i := 0 to Length(SrvVars)-1 do
  begin
    if not VarIsNull(SrvVars[i]) then
    begin
      CountVal := CountVal + 1;
      if VarIsNull(SumVal) then
        SumVal := SrvVars[i]
      else
        SumVal := SumVal + SrvVars[i];
    end;
  end;

  if CountVal > 0
    then AvrVal := SumVal / CountVal
    else AvrVal := Null;

  SetLength(ResVars, Length(SrvVars));
  for i := 0 to Length(ResVars)-1 do
    ResVars[i] := SrvVars[i] - AvrVal;
  for i := 0 to Length(ResVars)-1 do
    ResVars[i] := ResVars[i] * ResVars[i];
  SquareSum := 0;
  for i := 0 to Length(ResVars)-1 do
    SquareSum := SquareSum + ResVars[i];
  if Length(ResVars) > Deduction then
  begin
    Result := SquareSum / (Length(ResVars) - Deduction);
    if DoSqrt then
      Result := Sqrt(Result);
  end else if Length(ResVars) > 0 then
    Result := SrvVars[0]
  else
    Result := Null;
end;

{ TPivotGridStDevpFunctionCalculatorEh }

constructor TPivotGridStDevpFunctionCalculatorEh.Create;
begin
  inherited Create;
  Deduction := 0;
  DoSqrt := True;
end;

class function TPivotGridStDevpFunctionCalculatorEh.DisplayName: String;
begin
  Result := EhLibLanguageConsts.PivotSumFunctionStDevp;
end;

{ TPivotGridVarFunctionCalculatorEh }

constructor TPivotGridVarFunctionCalculatorEh.Create;
begin
  inherited Create;
  Deduction := 1;
  DoSqrt := False;
end;

class function TPivotGridVarFunctionCalculatorEh.DisplayName: String;
begin
  Result := EhLibLanguageConsts.PivotSumFunctionVar;
end;

{ TPivotGridVarpFunctionCalculatorEh }

constructor TPivotGridVarpFunctionCalculatorEh.Create;
begin
  inherited Create;
  Deduction := 0;
  DoSqrt := False;
end;

class function TPivotGridVarpFunctionCalculatorEh.DisplayName: String;
begin
  Result := EhLibLanguageConsts.PivotSumFunctionVarp;
end;

{$IFDEF MSWINDOWS}
{ ExportPivotGridEhToOleExcel }

function ExportPivotGridEhToOleExcel(Grid: TCustomPivotGridEh;
  Options: TPivotGridExportAsOLEXLSOptionsEh
  ): Variant;
var
  Workbook: Variant;
  FExcelApp: Variant;
  FActiveSheet: Variant;
  FVarValues: Variant;
  i, j: Integer;
  STopLeft, SBottomRight: Variant;
  ARange: Variant;
  PivotCel: TPivotCellEh;
  DrPar: TPivotCellAxisValueDrawParamsEh;
begin
  FExcelApp := CreateOleObject('Excel.Application');

  FExcelApp.Application.EnableEvents := False;
  FExcelApp.Visible := True;
  Workbook := FExcelApp.WorkBooks.Add;
  FActiveSheet := Workbook.ActiveSheet;
  DrPar := TPivotCellAxisValueDrawParamsEh.Create;
  DrPar.Font := Grid.Canvas.Font;
  try

  FVarValues := VarArrayCreate([0, Grid.FullRowCount-1, 0, Grid.FullColCount-1], varVariant);

  for i := 0 to Grid.FullColCount-1 do
  begin
    for j := 0 to Grid.FullRowCount-1 do
    begin
      PivotCel := Grid.VisPivotGridArray[i, j];
      if PivotCel.CelType in [sctRowsAxisValueEh, sctColsAxisValueEh,
                              sctValCaptionInColsAxisEh, sctValCaptionInRowsAxisEh] then
      begin
        Grid.FillAxisValueCellParams(DrPar, i, j, PivotCel);
        FVarValues[j, i] := DrPar.DisplayValue;
      end else
        FVarValues[j, i] := PivotCel.Value;
    end;
  end;

  STopLeft := 'A1';
  SBottomRight := FActiveSheet.Cells.Item[Grid.FullRowCount, Grid.FullColCount];
  ARange := FActiveSheet.Range[STopLeft, SBottomRight];
  ARange.Value := FVarValues;
  ARange.Borders[1].LineStyle:=1;
  ARange.Borders[2].LineStyle:=1;
  ARange.Borders[3].LineStyle:=1;
  ARange.Borders[4].LineStyle:=1;
  ARange.Borders[9].LineStyle:=1;
  ARange.Borders[10].LineStyle:=1;

  SBottomRight := FActiveSheet.Cells.Item[Grid.FixedRowCount, Grid.FullColCount];
  ARange := FActiveSheet.Range[STopLeft, SBottomRight];
  ARange.Interior.Color := ColorToRGB(Grid.GridCellParams.ActualAxisColor);

  SBottomRight := FActiveSheet.Cells.Item[Grid.FullRowCount, Grid.FixedColCount];
  ARange := FActiveSheet.Range[STopLeft, SBottomRight];
  ARange.Interior.Color := ColorToRGB(Grid.GridCellParams.ActualAxisColor);

  Result := FExcelApp;
  finally
    DrPar.Free;
  end;
end;
{$ELSE}
{$ENDIF}

{ TPivotGridCellParamsEh }

constructor TPivotGridCellParamsEh.Create(AGrid: TCustomPivotGridEh);
begin
  inherited Create;
  FGrid := AGrid;

  FParentAxisFont := True;
  FAxisFont := TFont.Create;
  FAxisFont.OnChange := FontChanged;
  RefreshDefaultAxisFont;
  FAxisColor := clDefault;

  FParentAxisAggregateFont := True;
  FAxisAggregateFont := TFont.Create;
  FAxisAggregateFont.OnChange := FontChanged;
  RefreshDefaultAxisAggregateFont;

  FParentDataFont := True;
  FDataFont := TFont.Create;
  FDataFont.OnChange := FontChanged;
  RefreshDefaultDataFont;
  FDataColor := clDefault;

  FParentDataAggregateFont := True;
  FDataAggregateFont := TFont.Create;
  FDataAggregateFont.OnChange := FontChanged;
  RefreshDefaultDataAggregateFont;
  FDataAggregateColor := clDefault;

  FParentFieldNameFont := True;
  FFieldNameFont := TFont.Create;
  FFieldNameFont.OnChange := FontChanged;
  RefreshDefaultFieldNameFont;
  FFieldNameColor := clDefault;
end;

destructor TPivotGridCellParamsEh.Destroy;
begin
  FreeAndNil(FAxisFont);
  FreeAndNil(FAxisAggregateFont);
  FreeAndNil(FDataFont);
  FreeAndNil(FDataAggregateFont);
  FreeAndNil(FFieldNameFont);
  inherited Destroy;
end;

function TPivotGridCellParamsEh.DefaultFont: TFont;
begin
  Result := Grid.Font;
end;

procedure TPivotGridCellParamsEh.FontChanged(Sender: TObject);
begin
  if Sender = FAxisFont then
      FParentAxisFont := False
  else if Sender = FAxisAggregateFont then
      FParentAxisAggregateFont := False
  else if Sender = FDataFont then
      FParentDataFont := False
  else if Sender = FDataAggregateFont then
      FParentDataAggregateFont := False
  else if Sender = FFieldNameFont then
      FParentFieldNameFont := False;
  Grid.GridCellParamsChanged;
end;

procedure TPivotGridCellParamsEh.AssignDefaultFontTo(const AFont: TFont);
var
  Save: TNotifyEvent;
begin
  Save := AFont.OnChange;
  AFont.OnChange := nil;
  try
    AFont.Assign(DefaultFont);
  finally
    AFont.OnChange := Save;
  end;
end;

procedure TPivotGridCellParamsEh.RefreshDefaultDataAggregateFont;
begin
  if not FParentDataAggregateFont then Exit;
  AssignDefaultFontTo(FDataAggregateFont);
end;

procedure TPivotGridCellParamsEh.RefreshDefaultDataFont;
begin
  if not FParentDataFont then Exit;
  AssignDefaultFontTo(FDataFont);
end;

procedure TPivotGridCellParamsEh.RefreshDefaultFieldNameFont;
begin
  if not FParentFieldNameFont then Exit;
  AssignDefaultFontTo(FFieldNameFont);
end;

procedure TPivotGridCellParamsEh.RefreshDefaultAxisAggregateFont;
var
  Save: TNotifyEvent;
begin
  if not FParentAxisAggregateFont then Exit;
  Save := FAxisAggregateFont.OnChange;
  FAxisAggregateFont.OnChange := nil;
  try
    FAxisAggregateFont.Assign(DefaultFont);
    FAxisAggregateFont.Style := FAxisAggregateFont.Style + [fsBold];
  finally
    FAxisAggregateFont.OnChange := Save;
  end;
end;

procedure TPivotGridCellParamsEh.RefreshDefaultAxisFont;
begin
  if not FParentAxisFont then Exit;
  AssignDefaultFontTo(FAxisFont);
end;

function TPivotGridCellParamsEh.ActualDataColor: TColor;
begin
  if DataColor = clDefault
    then Result := Grid.FInternalColor
    else Result := DataColor;
end;

function TPivotGridCellParamsEh.ActualDataAggregateColor: TColor;
begin
  if DataAggregateColor = clDefault then
    if ColorToRGB(ActualDataColor) = ColorToRGB(clWhite) then
      Result := clCream
    else
      Result := ActualDataColor
  else
    Result := DataAggregateColor;
end;

function TPivotGridCellParamsEh.ActualFieldNameColor: TColor;
begin
  if FieldNameColor = clDefault
    then Result := StyleServices.GetSystemColor(clSkyBlue)
    else Result := FieldNameColor;
end;

function TPivotGridCellParamsEh.ActualAxisColor: TColor;
begin
  if AxisColor = clDefault
    then Result := Grid.FInternalFixedColor
    else Result := AxisColor;
end;

procedure TPivotGridCellParamsEh.SetDataAggregateColor(const Value: TColor);
begin
  if FDataAggregateColor <> Value then
  begin
    FDataAggregateColor := Value;
    Grid.GridCellParamsChanged;
  end;
end;

procedure TPivotGridCellParamsEh.SetDataAggregateFont(const Value: TFont);
begin
  FDataAggregateFont.Assign(Value);
end;

procedure TPivotGridCellParamsEh.SetDataColor(const Value: TColor);
begin
  if FDataColor <> Value then
  begin
    FDataColor := Value;
    Grid.GridCellParamsChanged;
  end;
end;

procedure TPivotGridCellParamsEh.SetDataFont(const Value: TFont);
begin
  FDataFont.Assign(Value);
end;

procedure TPivotGridCellParamsEh.SetFieldNameColor(const Value: TColor);
begin
  if FFieldNameColor <> Value then
  begin
    FFieldNameColor := Value;
    Grid.GridCellParamsChanged;
  end;
end;

procedure TPivotGridCellParamsEh.SetFieldNameFont(const Value: TFont);
begin
  FFieldNameFont.Assign(Value);
end;

procedure TPivotGridCellParamsEh.SetAxisAggregateFont(const Value: TFont);
begin
  FAxisAggregateFont.Assign(Value);
end;

procedure TPivotGridCellParamsEh.SetAxisColor(const Value: TColor);
begin
  if FAxisColor <> Value then
  begin
    FAxisColor := Value;
    Grid.GridCellParamsChanged;
  end;
end;

procedure TPivotGridCellParamsEh.SetAxisFont(const Value: TFont);
begin
  FAxisFont.Assign(Value);
end;

procedure TPivotGridCellParamsEh.SetParentDataAggregateFont(const Value: Boolean);
begin
  if FParentDataAggregateFont <> Value then
  begin
    FParentDataAggregateFont := Value;
    RefreshDefaultDataAggregateFont;
    Grid.GridCellParamsChanged;
  end;
end;

procedure TPivotGridCellParamsEh.SetParentDataFont(const Value: Boolean);
begin
  if FParentDataFont <> Value then
  begin
    FParentDataFont := Value;
    RefreshDefaultDataFont;
    Grid.GridCellParamsChanged;
  end;
end;

procedure TPivotGridCellParamsEh.SetParentFieldNameFont(const Value: Boolean);
begin
  if FParentFieldNameFont <> Value then
  begin
    FParentFieldNameFont := Value;
    RefreshDefaultFieldNameFont;
    Grid.GridCellParamsChanged;
  end;
end;

procedure TPivotGridCellParamsEh.SetParentAxisAggregateFont(const Value: Boolean);
begin
  if FParentAxisAggregateFont <> Value then
  begin
    FParentAxisAggregateFont := Value;
    RefreshDefaultAxisAggregateFont;
    Grid.GridCellParamsChanged;
  end;
end;

procedure TPivotGridCellParamsEh.SetParentAxisFont(const Value: Boolean);
begin
  if FParentAxisFont <> Value then
  begin
    FParentAxisFont := Value;
    RefreshDefaultAxisFont;
    Grid.GridCellParamsChanged;
  end;
end;

function TPivotGridCellParamsEh.IsAxisAggregateFontStored: Boolean;
begin
  Result := not ParentAxisAggregateFont;
end;

function TPivotGridCellParamsEh.IsAxisFontStored: Boolean;
begin
  Result := not ParentAxisFont;
end;

function TPivotGridCellParamsEh.IsDataAggregateFontStored: Boolean;
begin
  Result := not ParentDataAggregateFont;
end;

function TPivotGridCellParamsEh.IsDataFontStored: Boolean;
begin
  Result := not ParentDataFont;
end;

function TPivotGridCellParamsEh.IsFieldNameFontStored: Boolean;
begin
  Result := not ParentFieldNameFont;
end;

{ TPivotProgressIndicatorPanelEh }

constructor TPivotProgressIndicatorPanelEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csNoDesignVisible];
  ControlStyle := ControlStyle - [csAcceptsControls];
  SetBounds(9, 10, 265, 81);
  {$IFDEF FPC}
  {$ELSE}
  BevelKind := bkTile;
  ParentBackground := False;
  {$ENDIF}
  BevelOuter := bvNone;
  Visible := False;

  FProgressBar := TPivotProgressBarEh.Create(Self);
  FProgressBar.Parent := Self;
  FProgressBar.Visible := True;
  FProgressBar.Left := 8;
  FProgressBar.Top := 16;
  FProgressBar.Width := Width - 16;
  FProgressBar.Anchors := [akLeft, akTop, akRight];

  FLabelNote := TLabel.Create(Self);
  FLabelNote.Parent := Self;
  FLabelNote.AutoSize := False;
  FLabelNote.Caption := EhLibLanguageConsts.PivotDataBuildingInProgressEh;
  FLabelNote.Left := 8;
  FLabelNote.Top := 40;
  FLabelNote.Width := Width - 16;

  FLabelEsc := TLabel.Create(Self);
  FLabelEsc.Parent := Self;
  FLabelEsc.Caption := EhLibLanguageConsts.PressESCToCancelEh;
  FLabelEsc.Left := 155;
  FLabelEsc.Top := 60;

  FLabelTimePassed := TLabel.Create(Self);
  FLabelTimePassed.Parent := Self;
  FLabelTimePassed.Caption := EhLibLanguageConsts.ElapsedTimeEh;
  FLabelTimePassed.Left := 8;
  FLabelTimePassed.Top := 60;
end;

destructor TPivotProgressIndicatorPanelEh.Destroy;
begin
  inherited Destroy;
end;

procedure TPivotProgressIndicatorPanelEh.CMBiDiModeChanged(
  var Message: TMessage);
begin
  inherited;
  if UseRightToLeftAlignment and not FControlFlipChildren then
  begin
    FControlFlipChildren := True;
    Left := Parent.Width - Width - 9;
    FLabelEsc.Left := 8;
    FLabelTimePassed.Left := Width - (8 + FLabelTimePassed.Width);
  end else if not UseRightToLeftAlignment and FControlFlipChildren then
  begin
    FControlFlipChildren := False;
    Left := 9;
    FLabelEsc.Left := 155;
    FLabelTimePassed.Left := 8;
  end;
end;

{ TPivotProgressBarEh }

constructor TPivotProgressBarEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TPivotProgressBarEh.Destroy;
begin
  FreeAndNil(FCanvas);
  FreeAndNil(FBufferBitmap);
  inherited Destroy;
end;

procedure TPivotProgressBarEh.WMPaint(var Message: TWMPaint);
begin
  if FlatPivotProgressIndicator and
     not (csDesigning in ComponentState) then
  begin
    if FCanvas = nil then
    begin
      FCanvas := TControlCanvas.Create;
      FCanvas.Control := Self;
      FBufferBitmap := TBitmap.Create;
    end;
    FBufferBitmap.Width := Width;
    FBufferBitmap.Height := Height;
    FBufferBitmap.Canvas.Brush.Color := StyleServices.GetSystemColor(clWindow);
    FBufferBitmap.Canvas.FillRect(Rect(0, 0, Width, Height));
    DrawProgressBarEh(Position, Min, Max,
      FBufferBitmap.Canvas, Rect(0, 0, Width, Height),
      StyleServices.GetSystemColor(clSkyBlue),
      StyleServices.GetSystemColor(cl3DDkShadow), clNone);
    FCanvas.Draw(0, 0, FBufferBitmap);
  end else
    inherited;
end;

{ TPivotMemTableEh }

function TPivotMemTableEh.CreateMemTableData: TMemTableDataEh;
begin
  Result := TPivotMemTableDataEh.Create(Self);
  TPivotMemTableDataEh(Result).OnCallBackProgress := MTCallBackProgress;
end;

procedure TPivotMemTableEh.MTCallBackProgress(Sender: TObject);
begin
  if Assigned(FOnCallBackProgress) then
    FOnCallBackProgress(Self);
end;

{ TPivotMemTableDataEh }

procedure TPivotMemTableDataEh.CallBackProgress;
begin
  if Assigned(FCallBackProgress) then
    FCallBackProgress(Self);
end;

function TPivotMemTableDataEh.CreateRecordsList: TRecordsListEh;
begin
  Result := TPivotRecordsListEh.Create(Self);
end;

{ TPivotRecordsListEh }

procedure TPivotRecordsListEh.CallBackProgress;
begin
  TPivotMemTableDataEh(MemTableData).CallBackProgress;
end;

procedure TPivotRecordsListEh.QuickSort(L, R: Integer; Compare: TCompareRecords;
  ParamSort: TObject);
var
  I, J: Integer;
  P: TMemoryRecordEh;
begin
  repeat
    I := L;
    J := R;
    P := Rec[(L + R) shr 1];
    repeat
      while Compare(Rec[I], P, ParamSort) < 0 do
      begin
        CallBackProgress;
        Inc(I);
      end;
      while Compare(Rec[J], P, ParamSort) > 0 do
      begin
        CallBackProgress;
        Dec(J);
      end;
      if I <= J then
      begin
        RecListExchange(I, J);
        Inc(I);
        Dec(J);
      end;
      CallBackProgress;
    until I > J;
    if L < J then
      QuickSort(L, J, Compare, ParamSort);
    L := I;
  until I >= R;
end;

{$IFDEF FPC}
{$ELSE}
{ TCustomPivotGridPrintServiceEh }

procedure TCustomPivotGridPrintServiceEh.SetGrid(const Value: TCustomPivotGridEh);
begin
  FGrid := Value;
end;
{$ENDIF}

{ TPivotKeyValueStateEh }

constructor TPivotKeyValueStateEh.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FExpanded := True;
  FVisible := True;
  FKeyValue := Unassigned;
end;

constructor TPivotKeyValueStateEh.CreateApart(const KeyValue: Variant);
begin
  Create(nil);
  FKeyValue := KeyValue;
end;

destructor TPivotKeyValueStateEh.Destroy;
begin
  inherited Destroy;
end;

function TPivotKeyValueStateEh.GetList: TPivotKeyValueStatesEh;
begin
  Result := TPivotKeyValueStatesEh(Collection);
end;

procedure TPivotKeyValueStateEh.SetExpanded(const Value: Boolean);
begin
  FExpanded := Value;
end;

procedure TPivotKeyValueStateEh.SetVisible(const Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    if (List <> nil) then
      List.UpdateHaveHiddenKeysProp;
  end;
end;

{ TPivotKeyValueStatesEh }

constructor TPivotKeyValueStatesEh.Create(APivotField: TPivotFieldEh; AClass: TPivotKeyValueStateEhClass);
begin
  inherited Create(AClass);
  FPivotField := APivotField;
end;

function TPivotKeyValueStatesEh.Add: TPivotKeyValueStateEh;
begin
  Result := TPivotKeyValueStateEh(inherited Add)
end;

function TPivotKeyValueStatesEh.Add(const KeyValue: Variant): TPivotKeyValueStateEh;
begin
  Result := Add;
  Result.FKeyValue := KeyValue;
end;

function TPivotKeyValueStatesEh.GetItem(Index: Integer): TPivotKeyValueStateEh;
begin
  Result := TPivotKeyValueStateEh(inherited Items[Index]);
end;

function TPivotKeyValueStatesEh.GetItemByKeyValue(
  const KeyValue: Variant): TPivotKeyValueStateEh;
var
  Idx: Integer;
begin
  Idx := BinarySearch(KeyValue);
  if Idx < 0
    then Result := nil
    else Result := Items[Idx];
end;

function TPivotKeyValueStatesEh.BinarySearch(const KeyValue: Variant): Integer;
var
  L, H: Integer;
  mid: Integer;
  cmp: TVariantRelationship;
begin
  Result := -1;
  if Count = 0 then
    Exit;

  L := 0;
  H := Count - 1;
  while L <= H do
  begin
    mid := L + (H - L) shr 1;
    cmp := VarCompareValue(Items[mid].KeyValue, KeyValue);
    if cmp = vrNotEqual then
      raise Exception.Create('TPivotKeyValueStatesEh.BinarySearch() .. CompareResult = vrNotEqual')
    else if cmp = vrLessThan then
      L := mid + 1
    else
    begin
      H := mid - 1;
      if cmp = vrEqual then
        Result := L;
    end;
  end;
end;


function TPivotKeyValueStatesEh.GetPivotField: TPivotFieldEh;
begin
  Result := FPivotField;
end;

procedure TPivotKeyValueStatesEh.SortData;
begin
end;

function VarDynArrayItemCompare(List: Pointer; ItemIndex1, ItemIndex2: Integer): Integer;
var
  Res: TVariantRelationship;
begin
  Result := 0;
  Res := DBVarCompareValue(TVariantDynArray(List)[ItemIndex1], TVariantDynArray(List)[ItemIndex2]);
  case Res of
    vrLessThan: Result := -1;
    vrGreaterThan: Result := 1;
    vrNotEqual: raise Exception.Create('Compare error in TPivotKeyValueStatesEh.UpdateData');
  end;
end;

procedure VarDynArrayItemExchange(List: Pointer; ItemIndex1, ItemIndex2: Integer);
var
  vTmp: Variant;
begin
  vTmp := TVariantDynArray(List)[ItemIndex2];
  TVariantDynArray(List)[ItemIndex2] := TVariantDynArray(List)[ItemIndex1];
  TVariantDynArray(List)[ItemIndex1] := vTmp;
end;

procedure TPivotKeyValueStatesEh.UpdateData(AMemTableEh: TMemTableEh);
var
  BaseValues: TVariantDynArray;
  Values: TVariantDynArray;

  procedure GetValuesList;
  var
    RecList: TRecordsListEh;
    i: Integer;
    Field: TField;
  begin
    Field := AMemTableEh.FieldByName(PivotField.FieldName);
    RecList := AMemTableEh.RecordsView.MemTableData.RecordsList;
    SetLength(BaseValues, RecList.Count);
    for i := 0 to RecList.Count-1 do
      BaseValues[i] := RecList.Rec[i].Value[Field.FieldNo-1, dvvValueEh];
  end;

  procedure SortValues;
  begin
    AbstractQuickSort(BaseValues, 0, Length(BaseValues)-1, VarDynArrayItemCompare, VarDynArrayItemExchange);
  end;

  procedure DeleteDuplicates;
  var
    i, j: Integer;
  begin
    SetLength(Values, Length(BaseValues));
    if Length(BaseValues) > 0 then
    begin
      Values[0] := BaseValues[0];
      j := 0;
    end else
      j := -1;
    for i := 1 to Length(BaseValues)-1 do
    begin
      if not VarSameValue(Values[j], BaseValues[i]) then
      begin
        j := j + 1;
        Values[j] := BaseValues[i];
      end;
    end;
    SetLength(Values, j+1);
  end;

  procedure ExtractItems(AList: TObjectList);
  var
    i: Integer;
    item: TPivotKeyValueStateEh;
    itm: Pointer;
  begin
    for i := Self.Count-1 downto 0 do
    begin
      item := Items[i];
      item.Collection := nil;
      AList.Add(item);
    end;

    for i := 0 to AList.Count div 2 - 1 do
    begin
      itm := AList[i];
      AList[i] := AList[AList.Count-i-1];
      AList[AList.Count-i-1] := itm;
    end;
  end;

  procedure AddRest(AStart: Integer);
  var
    i: Integer;
    item: TPivotKeyValueStateEh;
  begin
    for i := AStart to Length(Values)-1 do
    begin
      item := Self.Add();
      item.FKeyValue := Values[i];
    end;
  end;

  procedure MergeAddValues(AList: TObjectList; Values: TVariantDynArray);
  var
    li, vi: Integer;
    lv, vv: Variant;
    cmp: TVariantRelationship;
    item: TPivotKeyValueStateEh;
  begin
    li := 0;
    vi := 0;
    if Length(Values) = 0 then Exit;
    if AList.Count = 0 then
    begin
      AddRest(0);
      Exit;
    end;
    while (li < AList.Count) and (vi < Length(Values)) do
    begin
      lv := TPivotKeyValueStateEh(AList[li]).KeyValue;
      vv := Values[vi];
      cmp := DBVarCompareValue(lv, vv);
      if cmp = vrNotEqual then
        raise Exception.Create('TPivotKeyValueStatesEh.UpdateData .. CompareResult = vrNotEqual')
      else if cmp = vrEqual then
      begin
        TPivotKeyValueStateEh(AList[li]).Collection := Self;

        li := li + 1;
        vi := vi + 1;

      end else if cmp = vrLessThan then
      begin
        li := li + 1;
      end else if cmp = vrGreaterThan then
      begin
        item := Self.Add();
        item.FKeyValue := Values[vi];
        vi := vi + 1;
      end;
    end;
    AddRest(vi);
  end;

  procedure DeleteUnusedItems(AList: TObjectList);
  var
    i: Integer;
    CollItem: TPivotKeyValueStateEh;
  begin
    for i := 0 to AList.Count-1 do
    begin
      CollItem := TPivotKeyValueStateEh(AList[i]);
      if CollItem.Collection = nil then
        CollItem.Free;
    end;
  end;

  procedure MergeValues;
  var
    AList: TObjectListEh;
  begin
    AList := TObjectListEh.Create;
    ExtractItems(AList);
    MergeAddValues(AList, Values);
    DeleteUnusedItems(AList);
    AList.Free;
  end;


begin
  GetValuesList;
  SortValues;
  DeleteDuplicates;
  MergeValues;
end;

procedure TPivotKeyValueStatesEh.UpdateStateFromSortedList(AList: TObjectList);
var
  li, vi: Integer;
  lv, vv: Variant;
  cmp: TVariantRelationship;
begin
  BeginUpdate;
  try
  li := 0;
  vi := 0;
  if AList.Count = 0 then Exit;
  while (li < AList.Count) and (vi < Count) do
  begin
    lv := TPivotKeyValueStateEh(AList[li]).KeyValue;
    vv := Items[vi].KeyValue;
    cmp := DBVarCompareValue(lv, vv);
    if cmp = vrNotEqual then
      raise Exception.Create('TPivotKeyValueStatesEh.UpdateData .. CompareResult = vrNotEqual')
    else if cmp = vrEqual then
    begin
      Items[vi].Expanded := TPivotKeyValueStateEh(AList[li]).Expanded;
      Items[vi].Visible := TPivotKeyValueStateEh(AList[li]).Visible;

      li := li + 1;
      vi := vi + 1;

    end else if cmp = vrLessThan then
    begin
      li := li + 1;
    end else if cmp = vrGreaterThan then
    begin
      vi := vi + 1;
    end;
  end;
  finally
    EndUpdate;
    UpdateHaveHiddenKeysProp;
  end;
end;

function TPivotKeyValueStatesEh.HaveHiddenKeys: Boolean;
begin
  Result := FHaveHiddenKeys;
end;

procedure TPivotKeyValueStatesEh.UpdateHaveHiddenKeysProp;
var
  i: Integer;
begin
  if UpdateCount > 0 then Exit;

  FHaveHiddenKeys := False;
  for i:= 0 to Count-1 do
  begin
    if not Items[i].Visible then
    begin
      FHaveHiddenKeys := True;
      Break;
    end;
  end;
end;

{ TPivotGridInplaceEditEh }

constructor TPivotGridInplaceEditEh.Create(Owner: TComponent);
begin
  inherited Create(Owner);
end;

destructor TPivotGridInplaceEditEh.Destroy;
begin
  inherited Destroy;
end;

function TPivotGridInplaceEditEh.GetGrid: TCustomPivotGridEh;
begin
  Result := TCustomPivotGridEh(Owner);
end;

procedure TPivotGridInplaceEditEh.UpdateContents;
var
  EditorParams: TPivotDataCellEditorParamsEh;
begin
  EditorParams := TPivotDataCellEditorParamsEh.Create;
  EditorParams.Font := Font;
  Grid.FillDataCellEditorParams(EditorParams, Grid.Col, Grid.Row);
  Text := EditorParams.EditValue;
  ReadOnly := not EditorParams.CanModify;
  MaxLength := Grid.GetEditLimit;
  EditorParams.Free;
end;

procedure TPivotGridInplaceEditEh.UserChange;
begin
end;

{ TPivotCellDrawParamsEh }

constructor TPivotCellDrawParamsEh.Create;
begin
  FFont := TFont.Create;
end;

destructor TPivotCellDrawParamsEh.Destroy;
begin
  FreeAndNil(FFont);
  inherited Destroy;
end;

procedure TPivotCellDrawParamsEh.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

{ TPivotGridRowAxisOptionsEh }

constructor TPivotGridRowAxisOptionsEh.Create(AGrid: TCustomPivotGridEh);
begin
  inherited Create;
  FGrid := AGrid;
  FAutoWordWrap := True;
  FTotalAtParentLevel := True;
end;

destructor TPivotGridRowAxisOptionsEh.Destroy;
begin
  inherited Destroy;
end;

procedure TPivotGridRowAxisOptionsEh.SetHeightAutoExpand(const Value: Boolean);
begin
  if FHeightAutoExpand <> Value then
  begin
    FHeightAutoExpand := Value;
    FGrid.GridOptionsChanged;
  end;
end;

procedure TPivotGridRowAxisOptionsEh.SetTotalAtParentLevel(
  const Value: Boolean);
begin
  if FTotalAtParentLevel <> Value then
  begin
    FTotalAtParentLevel := Value;
    FGrid.GridOptionsChanged;
  end;
end;

procedure TPivotGridRowAxisOptionsEh.SetTotalsBeforeData(const Value: Boolean);
begin
  if FTotalsBeforeData <> Value then
  begin
    FTotalsBeforeData := Value;
    FGrid.GridOptionsChanged;
  end;
end;

procedure TPivotGridRowAxisOptionsEh.SetAutoWordWrap(const Value: Boolean);
begin
  if FAutoWordWrap <> Value then
  begin
    FAutoWordWrap := Value;
    FGrid.GridOptionsChanged;
  end;
end;

initialization
  InitPivotGridEh;
finalization
  FinallyPivotGridEh;
end.
