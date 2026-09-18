{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{              EhLibFmx.DataGrid.Footers                }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataGrid.Footers;

interface

{$SCOPEDENUMS ON}

{$REGION 'uses'}
uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, System.Types,
  System.Generics.Collections, Data.Db, System.Variants,
  System.Math, Rtti,
  FMX.Graphics, System.UITypes, Data.SqlTimSt, Data.FmtBcd,
  EhLibFmx.Grid.CellManagers,
  EhLibUtils, DBUtilsEh, DBSumLst,
  EhLib.MathAggregators,
  EhLib.TableLinks,
  EhLibFmx.Utils,
  EhLibFmx.ToolControls,
  EhLibFmx.Platform,
  EhLibFmx.Types,
  EhLibFmx.Grid.Types,
  EhLibFmx.Grid.ToolControls,
  EhLibFmx.LaHostVirtualPanels,
  EhLibFmx.LaObjects,
  EhLibFmx.LaControls,
  EhLibFmx.LaGridPanels,
  EhLibFmx.LaPanels,

  EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.DataGrid.Rows,
  EhLibFmx.DataGrid.ToolControls
  ;
{$ENDREGION 'uses'}

type
  TDataGridFooterEh = class;
  TDataGridFooterCellManagerEh = class;
  TDataGridFooterCellEh = class;
  TDataGridFooterRowsEh = class;
  TDataGridFooterRowEh = class;
  TDataGridBaseColumnFootersEh = class;
  TDataGridBaseColumnFooterEh = class;
  TBaseDataGridFooterCalcInitDataParamsEh = class;
  TBaseDataGridFooterCalcStepDataParamsEh = class;
  TBaseDataGridFooterCalcFinalDataParamsEh = class;
  TBaseDataGridFooterGetDisplayTextParamsEh = class;

  TFooterAggregateFunction = (Non, Sum, Avg, Count, CountAll, CountDistinct, Min, Max, Custom);

{ TBaseDataGridFooterCalcInitDataParamsEh }

  TBaseDataGridFooterCalcInitDataParamsEh = class(TPersistent)
  private
    FAggregateFunction: TFooterAggregateFunction;
    FAggregator: TMathBaseAggregatorEhClass;
    FAggrValue: TValue;
    FColumn: TFieldBarEh;
    FColumnFooter: TDataGridBaseColumnFooterEh;
    FGrid: TControl;
    FHandled: Boolean;
    FRowCount: Integer;

  protected

  public
    constructor Create;
    procedure Init(AGrid: TControl; AColumn: TFieldBarEh; AColumnFooter: TDataGridBaseColumnFooterEh; ARowCount: Integer);

    function DefaultCalcInitData(): TValue;

    property AggregateFunction: TFooterAggregateFunction read FAggregateFunction;
    property Aggregator: TMathBaseAggregatorEhClass read FAggregator;
    property AggrValue: TValue read FAggrValue write FAggrValue;
    property Column: TFieldBarEh read FColumn;
    property ColumnFooter: TDataGridBaseColumnFooterEh read FColumnFooter;
    property Grid: TControl read FGrid;
    property Handled: Boolean read FHandled write FHandled;
    property RowCount: Integer read FRowCount;
  end;

{ TBaseDataGridFooterCalcStepDataParamsEh }

  TBaseDataGridFooterCalcStepDataParamsEh = class(TPersistent)
  private
    FAggregateFunction: TFooterAggregateFunction;
    FAggregator: TMathBaseAggregatorEhClass;
    FAggrValue: TValue;
    FColumn: TFieldBarEh;
    FColumnFooter: TDataGridBaseColumnFooterEh;
    FDataRow: TDataGridRowEh;
    FGrid: TControl;
    FHandled: Boolean;
    FStepValue: TValue;
  protected

  public
    constructor Create;
    procedure Init(AGrid: TControl; AColumn: TFieldBarEh; AColumnFooter: TDataGridBaseColumnFooterEh; ADataRow: TDataGridRowEh; const AAggrValue, AStepValue: TValue);

    function DefaultCalcStepData(): TValue;

    property AggregateFunction: TFooterAggregateFunction read FAggregateFunction;
    property Aggregator: TMathBaseAggregatorEhClass read FAggregator;
    property AggrValue: TValue read FAggrValue write FAggrValue;
    property Column: TFieldBarEh read FColumn;
    property ColumnFooter: TDataGridBaseColumnFooterEh read FColumnFooter;
    property DataRow: TDataGridRowEh read FDataRow;
    property Grid: TControl read FGrid;
    property Handled: Boolean read FHandled write FHandled;
    property StepValue: TValue read FStepValue;
  end;

{ TBaseDataGridFooterCalcFinalDataParamsEh }

  TBaseDataGridFooterCalcFinalDataParamsEh = class(TPersistent)
  private
    FAggregateFunction: TFooterAggregateFunction;
    FAggregator: TMathBaseAggregatorEhClass;
    FAggrValue: TValue;
    FColumn: TFieldBarEh;
    FColumnFooter: TDataGridBaseColumnFooterEh;
    FGrid: TControl;
    FHandled: Boolean;

  protected

  public
    constructor Create;
    procedure Init(AGrid: TControl; AColumn: TFieldBarEh; AColumnFooter: TDataGridBaseColumnFooterEh; const AAggrValue: TValue);

    function DefaultCalcFinalData(): TValue;

    property AggregateFunction: TFooterAggregateFunction read FAggregateFunction;
    property Aggregator: TMathBaseAggregatorEhClass read FAggregator;
    property AggrValue: TValue read FAggrValue write FAggrValue;
    property Column: TFieldBarEh read FColumn;
    property ColumnFooter: TDataGridBaseColumnFooterEh read FColumnFooter;
    property Grid: TControl read FGrid;
    property Handled: Boolean read FHandled write FHandled;
  end;

{ TBaseDataGridFooterGetDisplayTextParamsEh }

  TBaseDataGridFooterGetDisplayTextParamsEh = class(TPersistent)
  private
    FAggrValue: TValue;
    FColumn: TFieldBarEh;
    FColumnFooter: TDataGridBaseColumnFooterEh;
    FDisplayText: String;
    FGrid: TControl;
    FHandled: Boolean;

  protected

  public
    constructor Create;
    procedure Init(AGrid: TControl; AColumn: TFieldBarEh; AColumnFooter: TDataGridBaseColumnFooterEh; const AValue: TValue);

    function DefaultGetDisplayText(): String;

    property AggrValue: TValue read FAggrValue;
    property Column: TFieldBarEh read FColumn;
    property ColumnFooter: TDataGridBaseColumnFooterEh read FColumnFooter;
    property DisplayText: String read FDisplayText write FDisplayText;
    property Grid: TControl read FGrid;
    property Handled: Boolean read FHandled write FHandled;
  end;

{ TDataGridFooterGetCellManagerParamsEh }

  TDataGridFooterGetCellManagerParamsEh = class(TPersistent)
  private
    FCellManager: TBaseGridCellManagerEh;
    FColumn: TFieldBarEh;
    FFooter: TDataGridBaseColumnFooterEh;
    FGrid: TControl;
    FRowIndex: Integer;

  public
    procedure Init(AGrid: TControl; AColumn: TFieldBarEh; AFooter: TDataGridBaseColumnFooterEh; ARowIndex: Integer; ADefaultCellManager: TBaseGridCellManagerEh); virtual;

    property CellManager: TBaseGridCellManagerEh read FCellManager write FCellManager;
    property Column: TFieldBarEh read FColumn;
    property Footer: TDataGridBaseColumnFooterEh read FFooter;
    property Grid: TControl read FGrid;
    property RowIndex: Integer read FRowIndex;
  end;

{ TDataGridFooterInitCellParamsEh }

  TDataGridFooterInitCellParamsEh = class(TBaseGridInitCellParamsEh)
  private
    FColumn: TFieldBarEh;
    FFooter: TDataGridBaseColumnFooterEh;
    FRowIndex: Integer;

  public
    procedure Init(AGrid: TControl; ACellManager: TBaseGridCellManagerEh; ACell: TGridBaseCellEh); override;

    property Column: TFieldBarEh read FColumn;
    property Footer: TDataGridBaseColumnFooterEh read FFooter;
    property RowIndex: Integer read FRowIndex;
  end;

{ TDataGridFooterCreateCellContentParamsEh }

  TDataGridFooterCreateCellContentParamsEh = class(TBaseGridCreateCellContentParamsEh)
  private
  public
  end;

{ TDataGridFooterInitCellContentParamsEh }

  TDataGridFooterInitCellContentParamsEh = class(TBaseGridInitCellContentParamsEh)
  private
  public
    procedure Init(ACell: TGridBaseCellEh; ACellContent: TLaObjectEh; InitCellParams: TBaseGridInitCellParamsEh); override;

  end;

  TDataGridFooterCreateCellContentEventEh = procedure(Sender: TObject; Params: TDataGridFooterCreateCellContentParamsEh) of object;
  TDataGridFooterInitCellContentEventEh = procedure(Sender: TObject; Params: TDataGridFooterInitCellContentParamsEh) of object;
  TDataGridFooterGetCellManagerEventEh = procedure(Sender: TObject; Params: TDataGridFooterGetCellManagerParamsEh) of object;

{ TDataGridFooterRowEh }

  TDataGridFooterRowEh = class(TCollectionItem)
  private
    FRowHeight: Integer;
  protected
    function GetGrid: TControl;
  public
    procedure RecalcFooterHeight();
    property RowHeight: Integer read FRowHeight;
  end;

{ TDataGridFooterRowsEh }

  TDataGridFooterRowsEh = class(TCollection)
  private
    FGridFooter: TDataGridFooterEh;

    function GetItem(Index: Integer): TDataGridFooterRowEh;
    procedure SetItem(Index: Integer; const Value: TDataGridFooterRowEh);
  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AGridFooter: TDataGridFooterEh; ItemClass: TCollectionItemClass);
    function Add: TDataGridFooterRowEh;
    property Items[Index: Integer]: TDataGridFooterRowEh read GetItem write SetItem; default;
  end;

{ TDataGridFooterEh }

  TDataGridFooterEh = class(TComponent)
  private
    FDefaultCellManager: TBaseGridCellManagerEh;
    FFill: TBrush;
    FFillStored: Boolean;
    FFont: TFont;
    FFontColor: TAlphaColor;
    FFontColorStored: Boolean;
    FFontStored: Boolean;
    FInternalDefCellManager: TBaseGridCellManagerEh;
    FOnGetCellManager: TDataGridFooterGetCellManagerEventEh;
    FRows: TDataGridFooterRowsEh;
    FUpdateCount: Integer;

    function GetFontColor: TAlphaColor;
    function GetRows: TDataGridFooterRowsEh;
    function IsFillStored: Boolean;
    function IsFontColorStored: Boolean;
    function IsFontStored: Boolean;
    procedure FillChanged(Sender: TObject);
    procedure FontChanged(Sender: TObject);
    procedure SetDefaultCellManager(const Value: TBaseGridCellManagerEh);
    procedure SetFill(const Value: TBrush);
    procedure SetFillStored(const Value: Boolean);
    procedure SetFont(const Value: TFont);
    procedure SetFontColor(const Value: TAlphaColor);
    procedure SetFontColorStored(const Value: Boolean);
    procedure SetFontStored(const Value: Boolean);
    procedure SetRows(const Value: TDataGridFooterRowsEh);

  protected
    FGrid: TControl;

    function GetOwner: TPersistent; override;
    function CreateGetCellManagerParams(): TDataGridFooterGetCellManagerParamsEh; virtual;

    procedure Changed(); virtual;
    procedure HandleGetCellManager(Params: TDataGridFooterGetCellManagerParamsEh); virtual;
    procedure ProcessGetCellManager(Params: TDataGridFooterGetCellManagerParamsEh);
    procedure RowsChanged(); virtual;

  public
    constructor Create(AGrid: TControl); reintroduce;
    destructor Destroy; override;

    function DefaultFill(): TBrush; virtual;
    function DefaultFont(): TFont; virtual;
    function DefaultFontColor(): TAlphaColor; virtual;
    function GetCellManagerAt(ALocalColIndex, ALocalRowIndex: Integer): TBaseGridCellManagerEh; virtual;
    function GetDefaultCellManagerAt(ALocalColIndex, ALocalRowIndex: Integer): TBaseGridCellManagerEh; virtual;

    procedure RefreshDefaultFill;
    procedure RefreshDefaultFont;

    procedure BeginUpdate;
    procedure EndUpdate;
    procedure RecalcFooterHeights();
    procedure RecalcValues();
    procedure CheckRecalcValues();

    property DefaultCellManager: TBaseGridCellManagerEh read FDefaultCellManager write SetDefaultCellManager;

  published
    property Fill: TBrush read FFill write SetFill stored IsFillStored;
    property FillStored: Boolean read FFillStored write SetFillStored default False;
    property Font: TFont read FFont write SetFont stored IsFontStored;
    property FontColor: TAlphaColor read GetFontColor write SetFontColor stored IsFontColorStored;
    property FontColorStored: Boolean read FFontColorStored write SetFontColorStored default False;
    property FontStored: Boolean read FFontStored write SetFontStored stored False;
    property Rows: TDataGridFooterRowsEh read GetRows write SetRows;

    property OnGetCellManager: TDataGridFooterGetCellManagerEventEh read FOnGetCellManager write FOnGetCellManager;
  end;

{ TBaseColumnFooterEh }

  TDataGridBaseColumnFooterEh = class(TCollectionItem)
  private
    FAggregateFunction: TFooterAggregateFunction;
    FAggregator: TMathBaseAggregatorEhClass;
    FAggrValue: TValue;
    FColumn: TFieldBarEh;
    FDisplayFormat: String;
    FDisplayFormatStored: Boolean;
    FFill: TBrush;
    FFillStored: Boolean;
    FFont: TFont;
    FFontColor: TAlphaColor;
    FFontColorStored: Boolean;
    FFontStored: Boolean;
    FHorzAlign: TTextAlign;
    FHorzAlignStored: Boolean;
    FPadding: TBounds;
    FPaddingStored: Boolean;
    FVertAlign: TTextAlign;
    FVertAlignStored: Boolean;

    function GetDisplayFormat: String;
    function GetFontColor: TAlphaColor;
    function GetHorzAlign: TTextAlign;
    function GetPadding: TBounds;
    function GetVertAlign: TTextAlign;
    function IsDisplayFormatStored: Boolean;
    function IsFillStored: Boolean;
    function IsFontColorStored: Boolean;
    function IsFontStored: Boolean;
    function IsHorzAlignStored: Boolean;
    function IsPaddingStored: Boolean;
    function IsVertAlignStored: Boolean;
    function ProcessGetDisplayText(const AValue: TValue): String;

    procedure FillChanged(Sender: TObject);
    procedure FontChanged(Sender: TObject);
    procedure PaddingChanged(Sender: TObject);

    procedure RefreshDefaultFill;
    procedure RefreshDefaultFont;
    procedure RefreshDefaultPadding();
    procedure SetAggregateFunction(const Value: TFooterAggregateFunction);
    procedure SetAggregator(const Value: TMathBaseAggregatorEhClass);
    procedure SetDisplayFormat(const Value: String);
    procedure SetDisplayFormatStored(const Value: Boolean);
    procedure SetFill(const Value: TBrush);
    procedure SetFillStored(const Value: Boolean);
    procedure SetFont(const Value: TFont);
    procedure SetFontColor(const Value: TAlphaColor);
    procedure SetFontColorStored(const Value: Boolean);
    procedure SetFontStored(const Value: Boolean);
    procedure SetHorzAlign(const Value: TTextAlign);
    procedure SetHorzAlignStored(const Value: Boolean);
    procedure SetPadding(const Value: TBounds);
    procedure SetPaddingStored(const Value: Boolean);
    procedure SetVertAlign(const Value: TTextAlign);
    procedure SetVertAlignStored(const Value: Boolean);
    function GetGridFooter: TDataGridFooterEh;

  protected
    function CreateCalcFinalDataParams(): TBaseDataGridFooterCalcFinalDataParamsEh; virtual;
    function CreateCalcInitDataParams(): TBaseDataGridFooterCalcInitDataParamsEh; virtual;
    function CreateCalcStepDataParams(): TBaseDataGridFooterCalcStepDataParamsEh; virtual;
    function CreateGetDisplayTextParams(): TBaseDataGridFooterGetDisplayTextParamsEh; virtual;
    function DefaultDisplayFormat(): String; virtual;
    function DefaultFill: TBrush; virtual;
    function DefaultFont: TFont; virtual;
    function DefaultFontColor(): TAlphaColor; virtual;
    function DefaultHorzAlign(): TTextAlign; virtual;
    function DefaultPadding(): TBounds; virtual;
    function DefaultVertAlign(): TTextAlign; virtual;

    procedure HandleCalcFinalData(AFinalDataParams: TBaseDataGridFooterCalcFinalDataParamsEh); virtual;
    procedure HandleCalcInitData(AInitDataParams: TBaseDataGridFooterCalcInitDataParamsEh); virtual;
    procedure HandleCalcStepData(AStepDataParams: TBaseDataGridFooterCalcStepDataParamsEh); virtual;
    procedure HandleGetDisplayText(Params: TBaseDataGridFooterGetDisplayTextParamsEh); virtual;
    procedure NotifyChanges(CellLayoutAffects: Boolean = False);

  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    function FormatDisplayText(const AValue: TValue): String;
    function GetCellManager: TBaseGridCellManagerEh; virtual;
    function ValueToDisplayText(const AFooterValue: TValue): String;

    procedure Assign(Source: TPersistent); override;
    procedure RecalcAggrValue;

    procedure ProcessCalcFinalData(var AggrValue: TValue; AGrid: TControl; AColumn: TFieldBarEh; AColumnFooter: TDataGridBaseColumnFooterEh);
    procedure ProcessCalcInitData(var AggrValue: TValue; AGrid: TControl; AColumn: TFieldBarEh; AColumnFooter: TDataGridBaseColumnFooterEh; ARowCount: Integer);
    procedure ProcessCalcStepData(var AggrValue: TValue; const StepValue: TValue; AGrid: TControl; AColumn: TFieldBarEh; AColumnFooter: TDataGridBaseColumnFooterEh; ADataRow: TDataGridRowEh);

    property Column: TFieldBarEh read FColumn;
    property AggrValue: TValue read FAggrValue;
//    property DisplayText: String read GetDisplayText;
    property Aggregator: TMathBaseAggregatorEhClass read FAggregator write SetAggregator;
    property GridFooter: TDataGridFooterEh read GetGridFooter;

  published
    property DisplayFormat: String read GetDisplayFormat write SetDisplayFormat stored IsDisplayFormatStored;
    property DisplayFormatStored: Boolean read IsDisplayFormatStored write SetDisplayFormatStored stored False;
    property AggregateFunction: TFooterAggregateFunction read FAggregateFunction write SetAggregateFunction;
    property HorzAlign: TTextAlign read GetHorzAlign write SetHorzAlign stored IsHorzAlignStored;
    property HorzAlignStored: Boolean read IsHorzAlignStored write SetHorzAlignStored stored False;
    property VertAlign: TTextAlign read GetVertAlign write SetVertAlign stored IsVertAlignStored;
    property VertAlignStored: Boolean read IsVertAlignStored write SetVertAlignStored stored False;
    property Font: TFont read FFont write SetFont stored IsFontStored;
    property FontStored: Boolean read FFontStored write SetFontStored default False;
    property FontColor: TAlphaColor read GetFontColor write SetFontColor stored IsFontColorStored;
    property FontColorStored: Boolean read FFontColorStored write SetFontColorStored default False;
    property Fill: TBrush read FFill write SetFill stored IsFillStored;
    property FillStored: Boolean read FFillStored write SetFillStored default False;
    property Padding: TBounds read GetPadding write SetPadding stored IsPaddingStored;
    property PaddingStored: Boolean read FPaddingStored write SetPaddingStored default False;
  end;

  TColumnFooterEhClass = class of TDataGridBaseColumnFooterEh;

 { TBaseColumnFootersEh }

  TDataGridBaseColumnFootersEh = class(TCollection)
  private
    FColumn: TFieldBarEh;

    function GetFooter(Index: Integer): TDataGridBaseColumnFooterEh;
    function GetFooterAtRow(ARowIndex: Integer): TDataGridBaseColumnFooterEh;

    procedure SetFooter(Index: Integer; Value: TDataGridBaseColumnFooterEh);
  protected
    function GetOwner: TPersistent; override;

    procedure Update(Item: TCollectionItem); override;
    procedure RefreshDefaultPadding;
    procedure RefreshDefaultFill;
    procedure RefreshDefaultFont;
  public
    constructor Create(Column: TFieldBarEh; FooterClass: TColumnFooterEhClass);
    function Add: TDataGridBaseColumnFooterEh;

    procedure RecalcFooterValues;
    procedure UpdateDefaults;

    property Column: TFieldBarEh read FColumn;
    property Items[Index: Integer]: TDataGridBaseColumnFooterEh read GetFooter write SetFooter; default;
    property FooterAtRow[ARowIndex: Integer]: TDataGridBaseColumnFooterEh read GetFooterAtRow;
  end;

{ TDataGridFooterCellManagerEh }

  TDataGridFooterCellManagerEh = class(TBaseGridCellManagerEh)
  private
    FOnCreateCellContent: TDataGridFooterCreateCellContentEventEh;
    FOnCellInitContent: TDataGridFooterInitCellContentEventEh;

  protected
    function CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh; override;
    function CreateInitCellParams: TBaseGridInitCellParamsEh; override;

    procedure HandleCreateCustomCellContent(Params: TBaseGridCreateCellContentParamsEh); override;

  public
    function CreateCellHolder(): TVPBaseCellHolderEh; override;
    function IsShowSelectionLayer(AGrid: TControl; ACell: TGridBaseCellEh): Boolean; override;

    procedure InitCell(ACell: TGridBaseCellEh); override;
    procedure InitCellPositionProps(ACell: TGridBaseCellEh); override;
    procedure InitCellSideBorder(ACellHolder: TGridBaseCellHolderEh; BorderType: TGridCellBorderTypeEh; IsDraw: Boolean; BorderColor: TAlphaColor; IsExtent: Boolean); override;

    procedure InitCellTreeViewArea(ACell: TDataGridFooterCellEh); virtual;

    property OnCreateCellContent: TDataGridFooterCreateCellContentEventEh read FOnCreateCellContent write FOnCreateCellContent;
    property OnCellInitContent: TDataGridFooterInitCellContentEventEh read FOnCellInitContent write FOnCellInitContent;
  end;

{ TDataGridFooterCellHolderEh }

  TDataGridFooterCellHolderEh = class(TGridBaseCellHolderEh)
  private
    FBottomLine: TLaControlEh;
    FTreeViewArea: TGridCellTreeViewAreaControlEh;
  protected
    procedure CreateControls(AParent: TLaObjectEh); override;
    procedure TreeSignMouseDown(Sender: TObject; Params: TControlMouseButtonParamsEh);

    property TreeViewArea: TGridCellTreeViewAreaControlEh read FTreeViewArea;
  end;

{ TDataGridFooterCellEh }

  TDataGridFooterCellEh = class(TGridBaseCellEh)
  private
    FText: TLaTextBlockEh;
    FColFooter: TDataGridBaseColumnFooterEh;
    FColumn: TFieldBarEh;
    FTotalFooterRow: TDataGridFooterRowEh;
    FGroupingFooterRow: TDataGridRowEh;
    FValue: TValue;
    FCellContent: TLaObjectEh;
    FGroupingTreeLevel: Integer;

    function GetText: String;

    procedure SetText(const Value: String);
    function GetTreeViewArea: TGridCellTreeViewAreaControlEh;

  protected
    function CreateDefaultCellContentControls(AParentObject: TLaObjectEh): TLaObjectEh; override;
    function CreateCellClientControls(AParent: TLaObjectEh): TLaObjectEh; override;

    procedure CreateControls(); override;

    procedure CellTreeSignMouseDown(Sender: TObject; Params: TControlMouseButtonParamsEh); virtual;

  public
    constructor Create(ACellHolder: TGridBaseCellHolderEh);
    destructor Destroy; override;

    property Text: String read GetText write SetText;
    property TextControl: TLaTextBlockEh read FText;

    property Column: TFieldBarEh read FColumn;
    property ColFooter: TDataGridBaseColumnFooterEh read FColFooter;
    property GroupingFooterRow: TDataGridRowEh read FGroupingFooterRow;
    property TotalFooterRow: TDataGridFooterRowEh read FTotalFooterRow;
    property Value: TValue read FValue;
    property TreeViewArea: TGridCellTreeViewAreaControlEh read GetTreeViewArea;
  end;

{ TDataGridFixedFooterCellVirtualPanelEh }

  TDataGridFixedFooterCellVirtualPanelEh = class(TDataGridVirtualPanelEh)
  protected
  public
    function CreateBaseCellManager: TVPBaseCellManagerEh; override;
  end;

{ TDataGridFixedFooterCellManagerEh }

  TDataGridFixedFooterCellManagerEh = class(TBaseGridCellManagerEh)
  private
  protected
    function CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh; override;
    function CreateDefaultCellContent(ACell: TGridBaseCellEh; AParent: TLaObjectEh): TLaObjectEh; override;
  public
    procedure InitCell(ACell: TGridBaseCellEh); override;
  end;

{ TDataGridFixedFooterCellEh }

  TDataGridFixedFooterCellEh = class(TGridBaseCellEh)
  private

  protected
    procedure CreateControls(); override;

  public
    constructor Create(ACellHolder: TGridBaseCellHolderEh);
    destructor Destroy; override;
  end;

implementation

uses EhLibFmx.CustomDataGrids,
     EhLibFmx.DataGrids,
     EhLibFmx.DataGrid.DataGrouping,
     EhLibFmx.DataGrid.Columns;

type
  TCustomDataGridEhCrack = class(TCustomDataGridEh);
  TColumnEhCrack = class(TDataGridBaseColumnEh);

{$REGION 'TDataGridFooterEh'}

{ TDataGridFooterEh }

constructor TDataGridFooterEh.Create(AGrid: TControl);
begin
  inherited Create(AGrid);
  SetSubComponent(True);
  FGrid := AGrid;

  FRows := TDataGridFooterRowsEh.Create(Self, TDataGridFooterRowEh);

  FFont := TFont.Create();
  FFont.Assign(DefaultFont());
  FFont.OnChanged := FontChanged;
  FFontStored := False;

  FFill := TBrush.Create(TBrushKind.None, TAlphaColorRec.Null);
  FFill.Assign(DefaultFill());
  FFill.OnChanged := FillChanged;
  FFillStored := False;

  FInternalDefCellManager := TDataGridFooterCellManagerEh.Create(FGrid);
  FDefaultCellManager := FInternalDefCellManager;
end;

destructor TDataGridFooterEh.Destroy;
begin
  FreeAndNil(FInternalDefCellManager);
  FreeAndNil(FRows);
  FreeAndNil(FFont);
  FreeAndNil(FFill);
  inherited Destroy;
end;

function TDataGridFooterEh.GetOwner: TPersistent;
begin
  Result := FGrid;
end;

procedure TDataGridFooterEh.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TDataGridFooterEh.EndUpdate;
begin
  if FUpdateCount = 0 then
    RowsChanged;
end;

procedure TDataGridFooterEh.Changed;
begin
  TCustomDataGridEhCrack(FGrid).LayoutChanged;
end;

procedure TDataGridFooterEh.RowsChanged;
begin
  if FUpdateCount = 0 then
  begin
    TCustomDataGridEhCrack(FGrid).DataGrouping.RebuildListView(False);
    TCustomDataGridEhCrack(FGrid).LayoutChanged;
  end;
end;

procedure TDataGridFooterEh.RecalcValues();
begin
  if (FGrid <> nil) then
  begin
    TCustomDataGridEhCrack(FGrid).Columns.RecalcFooterValues();
    TCustomDataGridEhCrack(FGrid).DataGrouping.RecalcFooters();
  end;
end;

procedure TDataGridFooterEh.CheckRecalcValues;
begin
  if (FGrid <> nil) and (FUpdateCount = 0) then
    RecalcValues();
end;

procedure TDataGridFooterEh.RecalcFooterHeights;
var
  I: Integer;
  FooterRow: TDataGridFooterRowEh;
begin
  for I := 0  to Rows.Count - 1 do
  begin
    FooterRow := Rows[I];
    FooterRow.RecalcFooterHeight;
  end;
end;

procedure TDataGridFooterEh.SetDefaultCellManager(const Value: TBaseGridCellManagerEh);
begin
  if FDefaultCellManager <> Value then
  begin
    FDefaultCellManager := Value;
    if FDefaultCellManager = nil then
      FDefaultCellManager := FInternalDefCellManager;
    Changed;
  end;
end;

function TDataGridFooterEh.GetCellManagerAt(ALocalColIndex, ALocalRowIndex: Integer): TBaseGridCellManagerEh;
var
  GetCellManagerParams: TDataGridFooterGetCellManagerParamsEh;
  Grid: TCustomDataGridEhCrack;
  ADefaultCellManager: TBaseGridCellManagerEh;
  Column: TDataGridBaseColumnEh;
  Footer: TDataGridBaseColumnFooterEh;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if ALocalColIndex < TCustomDataGridEhCrack(Grid).VisibleColumns.Count
    then Column := TCustomDataGridEhCrack(Grid).VisibleColumns[ALocalColIndex]
    else Column := nil;

  if (Column <> nil) and (ALocalRowIndex < Column.Footers.Count)
    then Footer := Column.Footers[ALocalRowIndex]
    else Footer := nil;

  ADefaultCellManager := GetDefaultCellManagerAt(ALocalColIndex, ALocalRowIndex);
  GetCellManagerParams := CreateGetCellManagerParams();
  try
    GetCellManagerParams.Init(Grid, Column, Footer, ALocalRowIndex, ADefaultCellManager);
    ProcessGetCellManager(GetCellManagerParams);
    Result := GetCellManagerParams.CellManager;
  finally
    GetCellManagerParams.Free;
  end;
end;

function TDataGridFooterEh.GetDefaultCellManagerAt(ALocalColIndex, ALocalRowIndex: Integer): TBaseGridCellManagerEh;
var
  Column: TDataGridBaseColumnEh;
begin
  if ALocalColIndex < TCustomDataGridEhCrack(FGrid).VisibleColumns.Count
    then Column := TCustomDataGridEhCrack(FGrid).VisibleColumns[ALocalColIndex]
    else Column := nil;

  if (Column <> nil) and (ALocalRowIndex < Column.Footers.Count) then
    Result := Column.Footers[ALocalRowIndex].GetCellManager()
  else
    Result := DefaultCellManager;
end;

function TDataGridFooterEh.CreateGetCellManagerParams: TDataGridFooterGetCellManagerParamsEh;
begin
  Result := TDataGridFooterGetCellManagerParamsEh.Create;
end;

procedure TDataGridFooterEh.ProcessGetCellManager(Params: TDataGridFooterGetCellManagerParamsEh);
begin
  HandleGetCellManager(Params);
end;

procedure TDataGridFooterEh.HandleGetCellManager(Params: TDataGridFooterGetCellManagerParamsEh);
begin
  if Assigned(OnGetCellManager) then
    OnGetCellManager(Self, Params);
end;

{$REGION ' Font'}
procedure TDataGridFooterEh.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TDataGridFooterEh.RefreshDefaultFont;
var
  Save: TNotifyEvent;
begin
  if FontStored then Exit;
  Save := FFont.OnChanged;
  FFont.OnChanged := nil;
  try
    FFont.Assign(DefaultFont);
    TCustomDataGridEhCrack(FGrid).Columns.RefreshFooterDefaultFont;
  finally
    FFont.OnChanged := Save;
  end;
end;

function TDataGridFooterEh.DefaultFont: TFont;
begin
  if (FGrid <> nil)
    then Result := TCustomDataGridEhCrack(FGrid).Font
    else Result := SystemFont;
end;

procedure TDataGridFooterEh.FontChanged(Sender: TObject);
begin
  FFontStored := True;
  TCustomDataGridEhCrack(FGrid).Columns.RefreshFooterDefaultFont;
  Changed;
end;

function TDataGridFooterEh.IsFontStored: Boolean;
begin
  Result := FFontStored;
end;

procedure TDataGridFooterEh.SetFontStored(const Value: Boolean);
begin
  if FFontStored <> Value then
  begin
    FFontStored := Value;
    RefreshDefaultFont;
  end;
end;

{$ENDREGION ' Font'}

{$REGION ' Fill'}
procedure TDataGridFooterEh.SetFill(const Value: TBrush);
begin
  FFill.Assign(Value);
end;

function TDataGridFooterEh.IsFillStored: Boolean;
begin
  Result := FFillStored;
end;

procedure TDataGridFooterEh.SetFillStored(const Value: Boolean);
begin
  if FFillStored <> Value then
  begin
    FFillStored := Value;
    RefreshDefaultFill;
  end;
end;

procedure TDataGridFooterEh.RefreshDefaultFill;
var
  Save: TNotifyEvent;
begin
  if FFillStored then Exit;
  Save := FFill.OnChanged;
  FFill.OnChanged := nil;
  try
    FFill.Assign(DefaultFill);
    TCustomDataGridEhCrack(FGrid).Columns.RefreshFooterDefaultFill;
  finally
    FFill.OnChanged := Save;
  end;
end;

function TDataGridFooterEh.DefaultFill: TBrush;
begin
  if (FGrid <> nil)
    then Result := TCustomDataGridEhCrack(FGrid).StylePainter.BackgroundMiddleFill
    else Result := SystemFill;
//  if (FGrid <> nil)
//    then Result := TCustomDataGridEhCrack(FGrid).FieldBarOptions.Fill
//    else Result := SystemFill;
end;

procedure TDataGridFooterEh.FillChanged(Sender: TObject);
begin
  FFillStored := True;
  TCustomDataGridEhCrack(FGrid).Columns.RefreshFooterDefaultFill;
  Changed;
end;
  {$ENDREGION 'Fill'}

  {$REGION 'FontColor'}
function TDataGridFooterEh.GetFontColor: TAlphaColor;
begin
  if FontColorStored
    then Result := FFontColor
    else Result := DefaultFontColor();
end;

procedure TDataGridFooterEh.SetFontColor(const Value: TAlphaColor);
begin
  if FFontColor <> Value then
  begin
    FFontColor := Value;
    FFontColorStored := True;
    Changed;
  end;
end;

function TDataGridFooterEh.DefaultFontColor: TAlphaColor;
begin
  if (FGrid <> nil)
    then Result := TCustomDataGridEhCrack(FGrid).FieldBarOptions.FontColor
    else Result := SystemFontColor;
end;

procedure TDataGridFooterEh.SetFontColorStored(const Value: Boolean);
begin
  if FFontColorStored <> Value then
  begin
    FFontColorStored := Value;
    Changed;
  end;
end;

function TDataGridFooterEh.IsFontColorStored: Boolean;
begin
  Result := FFontColorStored;
end;
  {$ENDREGION 'FontColor'}

function TDataGridFooterEh.GetRows: TDataGridFooterRowsEh;
begin
  Result := FRows;
end;

procedure TDataGridFooterEh.SetRows(const Value: TDataGridFooterRowsEh);
begin
  FRows.Assign(Value);
end;

{$ENDREGION 'TDataGridFooterEh'}

{$REGION 'TDataGridFooterRowsEh'}

{ TDataGridFooterRowsEh }

constructor TDataGridFooterRowsEh.Create(AGridFooter: TDataGridFooterEh; ItemClass: TCollectionItemClass);
begin
  inherited Create(ItemClass);
  FGridFooter := AGridFooter;
end;

function TDataGridFooterRowsEh.Add: TDataGridFooterRowEh;
begin
  Result := TDataGridFooterRowEh(inherited Add);
end;

function TDataGridFooterRowsEh.GetItem(Index: Integer): TDataGridFooterRowEh;
begin
  Result := TDataGridFooterRowEh(inherited GetItem(Index));
end;

function TDataGridFooterRowsEh.GetOwner: TPersistent;
begin
  Result := FGridFooter;
end;

procedure TDataGridFooterRowsEh.SetItem(Index: Integer; const Value: TDataGridFooterRowEh);
begin
  inherited SetItem(Index, TCollectionItem(Value));
end;

procedure TDataGridFooterRowsEh.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  FGridFooter.RowsChanged();
end;

{$ENDREGION 'TDataGridFooterRowsEh'}

{$REGION 'TBaseColumnFooterEh'}

{ TBaseColumnFooterEh }

constructor TDataGridBaseColumnFooterEh.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  if Assigned(Collection) and (Collection is TDataGridBaseColumnFootersEh) then
    FColumn := TDataGridBaseColumnFootersEh(Collection).Column;

  FFont := TFont.Create();
  FFont.Assign(DefaultFont());
  FFont.OnChanged := FontChanged;
  FFontStored := False;

  FFill := TBrush.Create(TBrushKind.None, TAlphaColorRec.Null);
  FFill.Assign(DefaultFill());
  FFill.OnChanged := FillChanged;
  FFillStored := False;

  FPadding := TBounds.Create(TRectF.Empty);
  FPadding.OnChange := PaddingChanged;
  FPaddingStored := False;
end;

destructor TDataGridBaseColumnFooterEh.Destroy;
begin
  FreeAndNil(FFont);
  FreeAndNil(FFill);
  FreeAndNil(FPadding);

  inherited Destroy;
end;

  {$REGION 'DisplayFormat'}
procedure TDataGridBaseColumnFooterEh.SetDisplayFormat(const Value: String);
begin
  if FDisplayFormat <> Value then
  begin
    FDisplayFormat := Value;
    FDisplayFormatStored := True;
    TColumnEhCrack(FColumn).Changed();
  end;
end;

function TDataGridBaseColumnFooterEh.GetDisplayFormat: String;
begin
  if DisplayFormatStored
    then Result := FDisplayFormat
    else Result := DefaultDisplayFormat();
end;

function TDataGridBaseColumnFooterEh.DefaultDisplayFormat: String;
begin
  if (FColumn <> nil) and (FColumn is TDataGridStringColumnEh) then
    Result := TDataGridStringColumnEh(FColumn).DisplayFormat
  else
    Result := '';
end;

function TDataGridBaseColumnFooterEh.IsDisplayFormatStored: Boolean;
begin
  Result := FDisplayFormatStored;
end;

procedure TDataGridBaseColumnFooterEh.SetDisplayFormatStored(const Value: Boolean);
begin
  if FDisplayFormatStored <> Value then
  begin
    FDisplayFormatStored := Value;
    Changed(False);
  end;
end;
  {$ENDREGION 'DisplayFormat'}

  {$REGION 'Font'}
procedure TDataGridBaseColumnFooterEh.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

function TDataGridBaseColumnFooterEh.DefaultFont: TFont;
begin
  if (FColumn <> nil) and (FColumn.Grid <> nil)
    then Result := TCustomDataGridEhCrack(FColumn.Grid).Footer.Font
    else Result := SystemFont;
end;

procedure TDataGridBaseColumnFooterEh.FontChanged(Sender: TObject);
begin
  FFontStored := True;
  Changed(False);
end;

procedure TDataGridBaseColumnFooterEh.SetFontStored(const Value: Boolean);
begin
  if FFontStored <> Value then
  begin
    FFontStored := Value;
    RefreshDefaultFont;
  end;
end;

procedure TDataGridBaseColumnFooterEh.RefreshDefaultFont;
var
  Save: TNotifyEvent;
begin
  if FontStored then Exit;
  Save := FFont.OnChanged;
  FFont.OnChanged := nil;
  try
    FFont.Assign(DefaultFont);
  finally
    FFont.OnChanged := Save;
  end;
end;

function TDataGridBaseColumnFooterEh.IsFontStored: Boolean;
begin
  Result := FFontStored;
end;
  {$ENDREGION 'Font'}

  {$REGION 'FontColor'}
function TDataGridBaseColumnFooterEh.GetFontColor: TAlphaColor;
begin
  if FontColorStored
    then Result := FFontColor
    else Result := DefaultFontColor();
end;

procedure TDataGridBaseColumnFooterEh.SetFontColor(const Value: TAlphaColor);
begin
  if FFontColor <> Value then
  begin
    FFontColor := Value;
    FFontColorStored := True;
    Changed(False);
  end;
end;

function TDataGridBaseColumnFooterEh.DefaultFontColor: TAlphaColor;
begin
  if (FColumn <> nil) and (FColumn.Grid <> nil)
    then Result := TCustomDataGridEhCrack(FColumn.Grid).Footer.FontColor
    else Result := SystemFontColor;
end;

procedure TDataGridBaseColumnFooterEh.SetFontColorStored(const Value: Boolean);
begin
  if FFontColorStored <> Value then
  begin
    FFontColorStored := Value;
    Changed(False);
  end;
end;

function TDataGridBaseColumnFooterEh.IsFontColorStored: Boolean;
begin
  Result := FFontColorStored;
end;
  {$ENDREGION 'FontColor'}

  {$REGION 'Fill'}
procedure TDataGridBaseColumnFooterEh.SetFill(const Value: TBrush);
begin
  FFill.Assign(Value);
end;

procedure TDataGridBaseColumnFooterEh.SetFillStored(const Value: Boolean);
begin
  if FFillStored <> Value then
  begin
    FFillStored := Value;
    RefreshDefaultFill;
  end;
end;

function TDataGridBaseColumnFooterEh.IsFillStored: Boolean;
begin
  Result := FFillStored;
end;

function TDataGridBaseColumnFooterEh.DefaultFill: TBrush;
begin
  if (FColumn <> nil) and (FColumn.Grid <> nil)
    then Result := TCustomDataGridEhCrack(FColumn.Grid).Footer.Fill
    else Result := SystemFill;
end;

procedure TDataGridBaseColumnFooterEh.RefreshDefaultFill;
var
  Save: TNotifyEvent;
begin
  if FFillStored then Exit;
  Save := FFill.OnChanged;
  FFill.OnChanged := nil;
  try
    FFill.Assign(DefaultFill);
  finally
    FFill.OnChanged := Save;
  end;
end;

procedure TDataGridBaseColumnFooterEh.FillChanged(Sender: TObject);
begin
  FFillStored := True;
  Changed(False);
end;
  {$ENDREGION 'Fill'}

  {$REGION 'Padding'}
function TDataGridBaseColumnFooterEh.GetPadding: TBounds;
begin
  Result := FPadding;
end;

procedure TDataGridBaseColumnFooterEh.SetPadding(const Value: TBounds);
begin
  FPadding.Assign(Value);
end;

function TDataGridBaseColumnFooterEh.DefaultPadding: TBounds;
begin
  if (FColumn <> nil) and (FColumn.Grid <> nil)
    then Result := TCustomDataGridEhCrack(FColumn.Grid).ColumnOptions.Padding
    else Result := EmptyBounds;
end;

procedure TDataGridBaseColumnFooterEh.RefreshDefaultPadding;
var
  Save: TNotifyEvent;
begin
  if PaddingStored then Exit;
  Save := FPadding.OnChange;
  FPadding.OnChange := nil;
  try
    FPadding.Assign(DefaultPadding);
    FPadding.DefaultValue := DefaultPadding.Rect;
  finally
    FPadding.OnChange := Save;
  end;
end;

procedure TDataGridBaseColumnFooterEh.SetPaddingStored(const Value: Boolean);
begin
  if FPaddingStored <> Value then
  begin
    FPaddingStored := Value;
    RefreshDefaultPadding;
    NotifyChanges(True);
  end;
end;

function TDataGridBaseColumnFooterEh.IsPaddingStored: Boolean;
begin
  Result := FPaddingStored;
end;

procedure TDataGridBaseColumnFooterEh.PaddingChanged(Sender: TObject);
begin
  FPaddingStored := True;
  NotifyChanges(True);
end;
  {$ENDREGION 'Padding'}

procedure TDataGridBaseColumnFooterEh.Assign(Source: TPersistent);
begin
  if Source is TDataGridBaseColumnFooterEh then
  begin
    DisplayFormat := TDataGridBaseColumnFooterEh(Source).DisplayFormat;
  end
  else
    inherited Assign(Source);
end;

function TDataGridBaseColumnFooterEh.GetGridFooter: TDataGridFooterEh;
begin
  if (Collection <> nil) and
     (TDataGridBaseColumnFootersEh(Collection).Column.Grid <> nil)
  then
    Result := TCustomDataGridEhCrack(TDataGridBaseColumnFootersEh(Collection).Column.Grid).Footer
  else
    Result := nil;
end;

function TDataGridBaseColumnFooterEh.GetCellManager: TBaseGridCellManagerEh;
var
  AGrid: TCustomDataGridEhCrack;
begin
  AGrid :=  TCustomDataGridEhCrack(FColumn.Grid);

  if AGrid <> nil
    then Result := AGrid.Footer.DefaultCellManager
    else Result := nil;
end;

function TDataGridBaseColumnFooterEh.FormatDisplayText(const AValue: TValue): String;
begin
  if ValueIsNullOrEmpty(AValue) then
  begin
    Result := '';
  end else
  begin
    if (Column <> nil) and (DisplayFormat <> '') then
    begin
      Result := Column.FormatValue(DisplayFormat, AValue)
    end else
    begin
      Result := ValueToString(AValue);
    end;
  end;
end;

function TDataGridBaseColumnFooterEh.CreateGetDisplayTextParams: TBaseDataGridFooterGetDisplayTextParamsEh;
begin
  Result := TBaseDataGridFooterGetDisplayTextParamsEh.Create;
end;

function TDataGridBaseColumnFooterEh.ProcessGetDisplayText(const AValue: TValue): String;
var
  AGrid: TCustomDataGridEhCrack;
  AColumn: TColumnEhCrack;
  DisplayTextParams: TBaseDataGridFooterGetDisplayTextParamsEh;
begin
  AColumn := TColumnEhCrack(FColumn);
  AGrid :=  TCustomDataGridEhCrack(FColumn.Grid);

  DisplayTextParams := CreateGetDisplayTextParams();
  try
    DisplayTextParams.Init(AGrid, AColumn, Self, AValue);

    HandleGetDisplayText(DisplayTextParams);

    if (DisplayTextParams.Handled = False) then
    begin
      Result := FormatDisplayText(AValue);
    end else
    begin
      Result := DisplayTextParams.DisplayText;
    end;
  finally
    DisplayTextParams.Free;
  end;
end;

procedure TDataGridBaseColumnFooterEh.HandleGetDisplayText(Params: TBaseDataGridFooterGetDisplayTextParamsEh);
begin
end;

function TDataGridBaseColumnFooterEh.ValueToDisplayText(
  const AFooterValue: TValue): String;
begin
  Result := ProcessGetDisplayText(AFooterValue);
end;

function TDataGridBaseColumnFooterEh.GetHorzAlign: TTextAlign;
begin
  if HorzAlignStored
    then Result := FHorzAlign
    else Result := DefaultHorzAlign();
end;

procedure TDataGridBaseColumnFooterEh.SetHorzAlign(const Value: TTextAlign);
begin
  if (IsHorzAlignStored = False) or (Value <> FHorzAlign) then
  begin
    FHorzAlign := Value;
    FHorzAlignStored := True;
    Changed(False);
  end;
end;

function TDataGridBaseColumnFooterEh.DefaultHorzAlign: TTextAlign;
const
  AlignmentToTextAlignArr : array[TAlignment] of TTextAlign =
    (TTextAlign.Leading, TTextAlign.Trailing, TTextAlign.Center);
begin
  if FColumn <> nil then
    Result := FColumn.HorzAlign
  else
    Result := TTextAlign.Leading;
end;

function TDataGridBaseColumnFooterEh.IsHorzAlignStored: Boolean;
begin
  Result := FHorzAlignStored;
end;

procedure TDataGridBaseColumnFooterEh.SetHorzAlignStored(const Value: Boolean);
begin
  if FHorzAlignStored <> Value then
  begin
    FHorzAlignStored := Value;
    Changed(False);
  end;
end;

function TDataGridBaseColumnFooterEh.GetVertAlign: TTextAlign;
begin
  if VertAlignStored
    then Result := FVertAlign
    else Result := DefaultVertAlign();
end;

procedure TDataGridBaseColumnFooterEh.SetVertAlign(const Value: TTextAlign);
begin
  if (IsVertAlignStored = False) or (Value <> FVertAlign) then
  begin
    FVertAlign := Value;
    FVertAlignStored := True;
    Changed(False);
  end;
end;

function TDataGridBaseColumnFooterEh.DefaultVertAlign: TTextAlign;
begin
  if FColumn <> nil then
    Result := FColumn.VertAlign
  else
    Result := TTextAlign.Leading;
end;

function TDataGridBaseColumnFooterEh.IsVertAlignStored: Boolean;
begin
  Result := FVertAlignStored;
end;

procedure TDataGridBaseColumnFooterEh.SetVertAlignStored(const Value: Boolean);
begin
  if FVertAlignStored <> Value then
  begin
    FVertAlignStored := Value;
    Changed(False);
  end;
end;

procedure TDataGridBaseColumnFooterEh.SetAggregateFunction(const Value: TFooterAggregateFunction);
begin
  if FAggregateFunction <> Value then
  begin
    FAggregateFunction := Value;
    case FAggregateFunction of
      TFooterAggregateFunction.Non: FAggregator := nil;
      TFooterAggregateFunction.Sum: FAggregator := TMathSumAggregatorEh;
      TFooterAggregateFunction.Avg: FAggregator := TMathAverageAggregatorEh;
      TFooterAggregateFunction.Count: FAggregator := TMathCountAggregatorEh;
      TFooterAggregateFunction.CountAll: FAggregator := TMathCountAllAggregatorEh;
      TFooterAggregateFunction.CountDistinct: FAggregator := TMathCountDistinctAggregatorEh;
      TFooterAggregateFunction.Min: FAggregator := TMathMinimumAggregatorEh;
      TFooterAggregateFunction.Max: FAggregator := TMathMaximumAggregatorEh;
      TFooterAggregateFunction.Custom: FAggregator := nil;
    end;
    if GridFooter <> nil then
      GridFooter.CheckRecalcValues;
    Changed(False);
  end;
end;

procedure TDataGridBaseColumnFooterEh.SetAggregator(const Value: TMathBaseAggregatorEhClass);
begin
  if FAggregator <> Value then
  begin
    FAggregator := Value;
    if FAggregator = nil then
      FAggregateFunction := TFooterAggregateFunction.Non
    else if FAggregator = TMathSumAggregatorEh then
      FAggregateFunction := TFooterAggregateFunction.Sum
    else
      FAggregateFunction := TFooterAggregateFunction.Custom;
    if GridFooter <> nil then
      GridFooter.CheckRecalcValues;
  end;
end;

function TDataGridBaseColumnFooterEh.CreateCalcInitDataParams: TBaseDataGridFooterCalcInitDataParamsEh;
begin
  Result := TBaseDataGridFooterCalcInitDataParamsEh.Create;
end;

procedure TDataGridBaseColumnFooterEh.ProcessCalcInitData(var AggrValue: TValue; AGrid: TControl; AColumn: TFieldBarEh;
  AColumnFooter: TDataGridBaseColumnFooterEh; ARowCount: Integer);
var
  InitDataParams: TBaseDataGridFooterCalcInitDataParamsEh;
begin
  InitDataParams := CreateCalcInitDataParams();
  try
    InitDataParams.Init(AGrid, AColumn, Self, ARowCount);
    HandleCalcInitData(InitDataParams);
    if (InitDataParams.Handled = False) then
    begin
      if (Aggregator <> nil) then
        Aggregator.CalcInitData(AggrValue, ARowCount);
    end else
    begin
      AggrValue := InitDataParams.AggrValue;
    end;
  finally
    InitDataParams.Free;
  end;
end;

procedure TDataGridBaseColumnFooterEh.HandleCalcInitData(AInitDataParams: TBaseDataGridFooterCalcInitDataParamsEh);
begin
end;

function TDataGridBaseColumnFooterEh.CreateCalcStepDataParams: TBaseDataGridFooterCalcStepDataParamsEh;
begin
  Result := TBaseDataGridFooterCalcStepDataParamsEh.Create;
end;

procedure TDataGridBaseColumnFooterEh.ProcessCalcStepData(var AggrValue: TValue; const StepValue: TValue; AGrid: TControl;
  AColumn: TFieldBarEh; AColumnFooter: TDataGridBaseColumnFooterEh; ADataRow: TDataGridRowEh);
var
  StepDataParams: TBaseDataGridFooterCalcStepDataParamsEh;
begin
  StepDataParams := CreateCalcStepDataParams;
  try
    StepDataParams.Init(AGrid, AColumn, Self, ADataRow, AggrValue, StepValue);
    HandleCalcStepData(StepDataParams);
    if (StepDataParams.Handled = False) then
    begin
      if (Aggregator <> nil) then
        Aggregator.CalcStepData(StepValue, AggrValue);
    end else
    begin
      AggrValue := StepDataParams.AggrValue;
    end;
  finally
    StepDataParams.Free;
  end;
end;

procedure TDataGridBaseColumnFooterEh.HandleCalcStepData(AStepDataParams: TBaseDataGridFooterCalcStepDataParamsEh);
begin
end;


function TDataGridBaseColumnFooterEh.CreateCalcFinalDataParams(): TBaseDataGridFooterCalcFinalDataParamsEh;
begin
  Result := TBaseDataGridFooterCalcFinalDataParamsEh.Create;
end;

procedure TDataGridBaseColumnFooterEh.ProcessCalcFinalData(var AggrValue: TValue; AGrid: TControl;
  AColumn: TFieldBarEh; AColumnFooter: TDataGridBaseColumnFooterEh);
var
  FinalDataParams: TBaseDataGridFooterCalcFinalDataParamsEh;
begin
  FinalDataParams := CreateCalcFinalDataParams();
  try
    FinalDataParams.Init(AGrid, AColumn, Self, AggrValue);
    HandleCalcFinalData(FinalDataParams);
    if (FinalDataParams.Handled = False) then
    begin
      if (Aggregator <> nil) then
        AggrValue := Aggregator.CalcFinalData(AggrValue);
    end else
    begin
      AggrValue := FinalDataParams.AggrValue;
    end;
  finally
    FinalDataParams.Free;
  end;
end;

procedure TDataGridBaseColumnFooterEh.HandleCalcFinalData(AFinalDataParams: TBaseDataGridFooterCalcFinalDataParamsEh);
begin
end;

procedure TDataGridBaseColumnFooterEh.RecalcAggrValue;

  procedure FillDataRowsList(AGrid: TCustomDataGridEhCrack; ADataRowsList: TList<TDataGridDataRowEh>);
  begin
    if (AGrid.DataGrouping.Active = True) then
      AGrid.DataGrouping.ForAllRows(
        procedure(ARow: TDataGridRowEh)
        begin
          if (ARow is TDataGridDataRowEh) then
            ADataRowsList.Add(TDataGridDataRowEh(ARow));
        end
      )
    else
      AGrid.VisibleRows.ForAll(
        procedure(const ARow: TDataGridRowEh)
        begin
          if (ARow is TDataGridDataRowEh) then
            ADataRowsList.Add(TDataGridDataRowEh(ARow));
        end
      );
  end;

var
  AGrid: TCustomDataGridEhCrack;
  AColumn: TColumnEhCrack;
  I: Integer;
  Row: TDataGridRowEh;
  Val: TValue;
  VDataRowsList: TList<TDataGridDataRowEh>;
begin
  if (FColumn = nil) or (FColumn.Grid = nil) or (Aggregator = nil) then
    FAggrValue := TValue.Empty
  else
  begin
    AColumn := TColumnEhCrack(FColumn);
    AGrid :=  TCustomDataGridEhCrack(FColumn.Grid);
    VDataRowsList := TList<TDataGridDataRowEh>.Create;

    FillDataRowsList(AGrid, VDataRowsList);

    ProcessCalcInitData(FAggrValue, AGrid, AColumn, Self, AGrid.VisibleRows.Count);
    try
      for I := 0 to VDataRowsList.Count - 1 do
      begin
        Row := VDataRowsList[I];
        Val := AColumn.GetRowValue(Row);
        ProcessCalcStepData(FAggrValue, Val, AGrid, AColumn, Self, Row);
      end;
    finally
      VDataRowsList.Free;
    end;

    ProcessCalcFinalData(FAggrValue, AGrid, AColumn, Self);
  end;
end;

procedure TDataGridBaseColumnFooterEh.NotifyChanges(CellLayoutAffects: Boolean);
begin
  if (FColumn <> nil) and (FColumn.Grid <> nil) then
    TCustomDataGridEhCrack(FColumn.Grid).LayoutChanged(CellLayoutAffects);
end;

{$ENDREGION TBaseColumnFooterEh}

{$REGION 'TBaseColumnFootersEh'}

{ TBaseColumnFootersEh }

constructor TDataGridBaseColumnFootersEh.Create(Column: TFieldBarEh; FooterClass: TColumnFooterEhClass);
begin
  inherited Create(FooterClass);
  FColumn := Column;
end;

function TDataGridBaseColumnFootersEh.Add: TDataGridBaseColumnFooterEh;
begin
  Result := TDataGridBaseColumnFooterEh(inherited Add);
end;

function TDataGridBaseColumnFootersEh.GetFooter(Index: Integer): TDataGridBaseColumnFooterEh;
begin
  Result := TDataGridBaseColumnFooterEh(inherited Items[Index]);
end;

function TDataGridBaseColumnFootersEh.GetOwner: TPersistent;
begin
  Result := FColumn;
end;

procedure TDataGridBaseColumnFootersEh.SetFooter(Index: Integer; Value: TDataGridBaseColumnFooterEh);
begin
  Items[Index].Assign(Value);
end;

procedure TDataGridBaseColumnFootersEh.Update(Item: TCollectionItem);
var
  VGrid: TCustomDataGridEhCrack;
begin
  inherited Update(Item);
  if (FColumn <> nil) and (FColumn.Grid <> nil) then
  begin
    VGrid := TCustomDataGridEhCrack(FColumn.Grid);
    VGrid.LayoutChanged;
  end;
end;

procedure TDataGridBaseColumnFootersEh.RecalcFooterValues;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].RecalcAggrValue;
end;

function TDataGridBaseColumnFootersEh.GetFooterAtRow(ARowIndex: Integer): TDataGridBaseColumnFooterEh;
begin
  if ARowIndex < Count
    then Result := Items[ARowIndex]
    else Result := nil;
end;

procedure TDataGridBaseColumnFootersEh.RefreshDefaultFill;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].RefreshDefaultFill;
end;

procedure TDataGridBaseColumnFootersEh.RefreshDefaultFont;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].RefreshDefaultFont;
end;

procedure TDataGridBaseColumnFootersEh.RefreshDefaultPadding;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].RefreshDefaultPadding;
end;

procedure TDataGridBaseColumnFootersEh.UpdateDefaults;
begin
  RefreshDefaultFill;
  RefreshDefaultFont;
  RefreshDefaultPadding;
end;
{$ENDREGION TBaseColumnFootersEh}

{$REGION 'TDataGridFooterCellManagerEh'}

{ TDataGridFooterCellManagerEh }

function TDataGridFooterCellManagerEh.CreateCellHolder: TVPBaseCellHolderEh;
begin
  Result := TDataGridFooterCellHolderEh.Create(nil, Self);
end;

function TDataGridFooterCellManagerEh.CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh;
begin
  Result := TDataGridFooterCellEh.Create(ACellHolder);
end;

procedure TDataGridFooterCellManagerEh.InitCell(ACell: TGridBaseCellEh);
var
  VGrid: TCustomDataGridEhCrack;
  Column: TDataGridBaseColumnEh;
  ColFooter: TDataGridBaseColumnFooterEh;
  AFooterCell: TDataGridFooterCellEh;
  DisplayText: String;
const
  LaHorzAlignments: array [TTextAlign] of TLaHorzAlignmentEh = (TLaHorzAlignmentEh.Center, TLaHorzAlignmentEh.Left, TLaHorzAlignmentEh.Right);
begin
  inherited InitCell(ACell);

  VGrid := TCustomDataGridEhCrack(ACell.Grid);
  AFooterCell := TDataGridFooterCellEh(ACell);
  ColFooter := AFooterCell.ColFooter;
  Column := TDataGridBaseColumnEh(AFooterCell.Column);

  if AFooterCell.GroupingFooterRow <> nil then
  begin
    if ColFooter <> nil then
      DisplayText := ColFooter.ValueToDisplayText(AFooterCell.FValue)
    else
      DisplayText := '';
  end else
  begin
    if ColFooter <> nil then
      DisplayText := ColFooter.ValueToDisplayText(ColFooter.AggrValue)
    else
      DisplayText := '';
  end;

  if (ColFooter <> nil) then
  begin
    AFooterCell.Text := DisplayText;
    AFooterCell.TextControl.HorzAlignment := LaHorzAlignments[ColFooter.HorzAlign];
    AFooterCell.TextControl.VertAlignment := TLaVertAlignmentEh.Center;
    AFooterCell.TextControl.Margins := ColFooter.Padding;
    AFooterCell.TextControl.Font := ColFooter.Font;
    AFooterCell.TextControl.FontColor := ColFooter.FontColor;
    AFooterCell.Fill := ColFooter.Fill;

  end else
  begin
    AFooterCell.Text := '';
    AFooterCell.TextControl.HorzAlignment := TLaHorzAlignmentEh.Left;
    AFooterCell.TextControl.VertAlignment := TLaVertAlignmentEh.Center;
    AFooterCell.Fill := VGrid.Footer.Fill;
    AFooterCell.TextControl.Font := VGrid.Footer.Font;
    if Column <> nil then
    begin
      AFooterCell.TextControl.Margins := Column.Padding;
    end else
    begin
      AFooterCell.TextControl.Margins := VGrid.ColumnOptions.Padding;
    end;
  end;

   InitCellTreeViewArea(AFooterCell);
end;

procedure TDataGridFooterCellManagerEh.InitCellPositionProps(ACell: TGridBaseCellEh);
var
  VGrid: TCustomDataGridEhCrack;
  AFooterCell: TDataGridFooterCellEh;
  AColumn: TDataGridBaseColumnEh;
  VRow: TDataGridRowEh;
  VGroupingFooterRow: TDataGridGroupFooterRowEh;
begin
  inherited InitCellPositionProps(ACell);

  VGrid := TCustomDataGridEhCrack(ACell.Grid);
  AFooterCell := TDataGridFooterCellEh(ACell);
  if (AFooterCell.AreaColIndex >= 0) and
     (AFooterCell.AreaColIndex < VGrid.VisibleColumns.Count)
  then
    AColumn := VGrid.VisibleColumns[AFooterCell.AreaColIndex]
  else
    AColumn := nil;

  AFooterCell.FColumn := AColumn;
  AFooterCell.FColFooter := nil;

  if AColumn <> nil then
  begin
    if (ACell.RowIndex >= 0) and (ACell.RowIndex < VGrid.RowCount) then
    begin
      if AFooterCell.AreaRowIndex < VGrid.VisibleRows.Count
        then VRow := VGrid.VisibleRows[AFooterCell.AreaRowIndex]
        else VRow := nil;

      if VRow is TDataGridGroupFooterRowEh then
      begin
        VGroupingFooterRow := TDataGridGroupFooterRowEh(VRow);
        AFooterCell.FGroupingFooterRow := VGroupingFooterRow;
        if VGroupingFooterRow.InTotalFootersRowIndex < AColumn.Footers.Count then
        begin
          AFooterCell.FColFooter := AColumn.Footers[VGroupingFooterRow.InTotalFootersRowIndex];
          AFooterCell.FValue := VGroupingFooterRow.GetFooterValue(AColumn);
        end;
      end;
    end else
    begin
      if (AFooterCell.AreaRowIndex >= 0) and
         (AFooterCell.AreaRowIndex < AColumn.Footers.Count) then
      begin
        AFooterCell.FTotalFooterRow := VGrid.Footer.Rows[AFooterCell.AreaRowIndex];
        if AFooterCell.AreaRowIndex < AColumn.Footers.Count then
          AFooterCell.FColFooter := AColumn.Footers[AFooterCell.AreaRowIndex];
      end;
    end;

    if (AFooterCell.FGroupingFooterRow <> nil) and (AColumn.VisibleIndex = 0) then
    begin
      AFooterCell.FGroupingTreeLevel := TDataGridGroupHeaderRowEh(AFooterCell.FGroupingFooterRow.ParentRow).Level + 1;
    end else
    begin
      AFooterCell.FGroupingTreeLevel := 0;
    end;

    if AColumn.IsSelected then
    begin
      AFooterCell.ShowSelectionLayer := True
    end
    else if (VGrid.SelectionOptions.RowHighlight = True) and
             (VGrid.SelectionOptions.RowSelect <> True)
    then
    begin
      AFooterCell.ShowSelectionLayer := (VGrid.CurrentRow = AFooterCell.GroupingFooterRow) and
                                     (VGrid.CurColIndex <> ACell.ColIndex);
    end else
    begin
      AFooterCell.ShowSelectionLayer := False;
    end;
  end;
end;

procedure TDataGridFooterCellManagerEh.InitCellSideBorder(
  ACellHolder: TGridBaseCellHolderEh; BorderType: TGridCellBorderTypeEh;
  IsDraw: Boolean; BorderColor: TAlphaColor; IsExtent: Boolean);

  function GetGridRowGroupingTreeLevel(AGridRowIndex: Integer): Integer;
  var
    VGrid: TCustomDataGridEhCrack;
    ADataRowIndex: Integer;
    ARow: TDataGridRowEh;
  begin
    VGrid := TCustomDataGridEhCrack(ACellHolder.Grid);
    ADataRowIndex := VGrid.RawToDataRowIndex(AGridRowIndex);

    if (ADataRowIndex >= 0) and (ADataRowIndex < VGrid.VisibleRows.Count) then
    begin
      ARow := VGrid.VisibleRows[ADataRowIndex];
      if ARow is TDataGridGroupHeaderRowEh then
        Result := TDataGridGroupHeaderRowEh(ARow).Level
      else if ARow is TDataGridGroupFooterRowEh then
        Result := TDataGridGroupFooterRowEh(ARow).Level
      else
        Result := -1;
    end else
    begin
      Result := -1;
    end;
  end;

var
  VFooterCellArea: TDataGridFooterCellHolderEh;
  VFooterCell: TDataGridFooterCellEh;
  TreeViewLevel: Integer;
  TreeViewNextRowLevel: Integer;
  LineMarginsLeft: Single;
begin
  VFooterCellArea := TDataGridFooterCellHolderEh(ACellHolder);
  VFooterCell := TDataGridFooterCellEh(VFooterCellArea.CellClient);
  if (BorderType = TGridCellBorderTypeEh.Bottom) then
  begin
    VFooterCellArea.FBottomLine.Visible := True;
    VFooterCellArea.FBottomLine.Fill.Kind := TBrushKind.Solid;
    VFooterCellArea.FBottomLine.Fill.Color := BorderColor;
    if IsDraw
      then VFooterCellArea.FBottomLine.Height := 1
      else VFooterCellArea.FBottomLine.Height := 0;

    if (VFooterCell.Column <> nil) and
       (VFooterCell.Column.VisibleIndex = 0) and
       (VFooterCell.GroupingFooterRow <> nil) then
    begin
      TreeViewLevel := TDataGridGroupHeaderRowEh(VFooterCell.GroupingFooterRow.ParentRow).Level + 1;
      TreeViewNextRowLevel := GetGridRowGroupingTreeLevel(ACellHolder.RowIndex + 1);

      if TreeViewNextRowLevel < TreeViewLevel then
        TreeViewLevel := TreeViewNextRowLevel;
      if TreeViewLevel < 0 then
        TreeViewLevel := 0;

      LineMarginsLeft := 16 * TreeViewLevel;
      if LineMarginsLeft > 0 then
        LineMarginsLeft := LineMarginsLeft + 16; //TreeSign
    end else
    begin
      LineMarginsLeft := 0;
    end;

    VFooterCellArea.FBottomLine.Margins.Left := LineMarginsLeft;
  end else
  begin
    inherited InitCellSideBorder(ACellHolder, BorderType, IsDraw, BorderColor, IsExtent);
  end;
end;

procedure TDataGridFooterCellManagerEh.InitCellTreeViewArea(ACell: TDataGridFooterCellEh);
var
  VGrid: TCustomDataGridEhCrack;
  IsBorderDraw: Boolean;
  BorderColor: TAlphaColor;
  IsBorderExtent: Boolean;
begin
  VGrid := TCustomDataGridEhCrack(ACell.Grid);

  if ACell.FGroupingTreeLevel > 0 then
  begin
    ACell.TreeViewArea.Visible := True;
    ACell.TreeViewArea.CheckCreateControls;
    ACell.TreeViewArea.Level := ACell.FGroupingTreeLevel;
  end else
  begin
    ACell.TreeViewArea.Visible := False;
    ACell.TreeViewArea.Level := 0;
  end;
  ACell.TreeViewArea.LevelWidth := 16;
  ACell.TreeViewArea.SignState := TTreeSignStateEh.Collapsed;
  ACell.TreeViewArea.SignVisible := False;

  VGrid.CheckDrawCellBorder(ACell.ColIndex, ACell.RowIndex, TGridCellBorderTypeEh.Right, IsBorderDraw, BorderColor, IsBorderExtent);
  if IsBorderDraw then
    VGrid.CheckDrawCellBorder(ACell.ColIndex, ACell.RowIndex, TGridCellBorderTypeEh.Bottom, IsBorderDraw, BorderColor, IsBorderExtent);
  if ACell.TreeViewArea.Visible and IsBorderDraw then
  begin
    ACell.TreeViewArea.RightBorderVisible := True;
    ACell.TreeViewArea.RightBorderColor := BorderColor;
  end else
  begin
    ACell.TreeViewArea.RightBorderVisible := False;
    ACell.TreeViewArea.RightBorderColor := TAlphaColors.Null;
  end;
end;

function TDataGridFooterCellManagerEh.CreateInitCellParams: TBaseGridInitCellParamsEh;
begin
  Result := TDataGridFooterInitCellParamsEh.Create;
end;

procedure TDataGridFooterCellManagerEh.HandleCreateCustomCellContent(Params: TBaseGridCreateCellContentParamsEh);
var
  TitleContentParams: TDataGridFooterCreateCellContentParamsEh;
begin
  TitleContentParams := TDataGridFooterCreateCellContentParamsEh(Params);

  if Assigned(OnCreateCellContent) then
    OnCreateCellContent(Self, TitleContentParams);
end;

function TDataGridFooterCellManagerEh.IsShowSelectionLayer(AGrid: TControl;
  ACell: TGridBaseCellEh): Boolean;
var
  FooterCell: TDataGridFooterCellEh;
begin
  FooterCell := TDataGridFooterCellEh(ACell);
  if FooterCell.Column <> nil
    then Result := TColumnEhCrack(FooterCell.Column).IsSelected
    else Result := False;
end;

{$ENDREGION 'TDataGridFooterCellManagerEh'}

{$REGION 'TDataGridFooterCellEh'}

{ TDataGridFooterCellEh }

constructor TDataGridFooterCellEh.Create(ACellHolder: TGridBaseCellHolderEh);
begin
  inherited Create(ACellHolder);
end;

destructor TDataGridFooterCellEh.Destroy;
begin
  inherited Destroy;
end;

procedure TDataGridFooterCellEh.CreateControls;
begin
  inherited CreateControls;
end;

function TDataGridFooterCellEh.CreateCellClientControls(AParent: TLaObjectEh): TLaObjectEh;
begin
  with TLaLayoutPanelEh.CreateWith(AParent, AParent) do
  begin
    Result := RefSelf;

    FCellContent := CreateCellContent(RefSelf);
    if FCellContent <> nil then
    begin
      if CellContent.Name = '' then
        CellContent.Name := 'CellContent';
    end;
  end;
end;

function TDataGridFooterCellEh.CreateDefaultCellContentControls(AParentObject: TLaObjectEh): TLaObjectEh;
begin
  with TLaLayoutPanelEh.CreateWith(AParentObject, AParentObject) do
  begin
    FText := TLaTextBlockEh.CreateWith(Self, RefSelf);
    FText.Padding.Rect := RectF(2, 0, 2, 0);
    FText.VertAlignment := TLaVertAlignmentEh.Center;
    FText.HorzAlignment := TLaHorzAlignmentEh.Right;

    Result := RefSelf;
  end;
end;

function TDataGridFooterCellEh.GetText: String;
begin
  Result := FText.Text;
end;

procedure TDataGridFooterCellEh.SetText(const Value: String);
begin
  FText.Text := Value;
end;

function TDataGridFooterCellEh.GetTreeViewArea: TGridCellTreeViewAreaControlEh;
begin
  Result := TDataGridFooterCellHolderEh(CellHolder).TreeViewArea;
end;

procedure TDataGridFooterCellEh.CellTreeSignMouseDown(Sender: TObject; Params: TControlMouseButtonParamsEh);
begin

end;

{$ENDREGION 'TDataGridFooterCellEh'}

{$REGION 'TDataGridFixedFooterCellVirtualPanelEh'}

{ TDataGridFixedFooterCellVirtualPanelEh }

function TDataGridFixedFooterCellVirtualPanelEh.CreateBaseCellManager: TVPBaseCellManagerEh;
begin
  Result := TDataGridFixedFooterCellManagerEh.Create(nil);
end;

{$ENDREGION 'TDataGridFixedFooterCellVirtualPanelEh'}

{$REGION 'TDataGridFixedFooterCellManagerEh'}

{ TDataGridFixedFooterCellManagerEh }

function TDataGridFixedFooterCellManagerEh.CreateDefaultCellContent(ACell: TGridBaseCellEh;
  AParent: TLaObjectEh): TLaObjectEh;
begin
  Result := nil;
end;

function TDataGridFixedFooterCellManagerEh.CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh;
begin
  Result := TDataGridFixedFooterCellEh.Create(ACellHolder);
end;

procedure TDataGridFixedFooterCellManagerEh.InitCell(ACell: TGridBaseCellEh);
var
  VGrid: TCustomDataGridEhCrack;
  FooterCell: TDataGridFixedFooterCellEh;
begin
  inherited InitCell(ACell);

  VGrid := TCustomDataGridEhCrack(ACell.Grid);
  FooterCell := TDataGridFixedFooterCellEh(ACell);
//  FooterCell.Fill.Kind := TBrushKind.Solid;
//  FooterCell.Fill.Color := VGrid.FInternalFixedColor;
  FooterCell.Fill := VGrid.StylePainter.IndicatorFill;

  FooterCell.ShowSelectionLayer := (VGrid.Selection.SelectionType = TDataGridSelectionTypeEh.All);
end;

{$ENDREGION 'TDataGridFixedFooterCellManagerEh'}

{$REGION 'TDataGridFixedFooterCellEh'}

{ TDataGridFixedFooterCellEh }

constructor TDataGridFixedFooterCellEh.Create(ACellHolder: TGridBaseCellHolderEh);
begin
  inherited Create(ACellHolder);
end;

destructor TDataGridFixedFooterCellEh.Destroy;
begin
  inherited Destroy;
end;

procedure TDataGridFixedFooterCellEh.CreateControls;
begin
  inherited CreateControls;
end;

{$ENDREGION 'TDataGridFixedFooterCellEh'}

{$REGION 'TDataGridFooterRowEh'}

{ TDataGridFooterRowEh }

function TDataGridFooterRowEh.GetGrid: TControl;
begin
  Result := TDataGridFooterRowsEh(GetOwner).FGridFooter.FGrid;
end;

procedure TDataGridFooterRowEh.RecalcFooterHeight;
var
  Grid: TCustomDataGridEhCrack;
  I: Integer;
  Column: TDataGridBaseColumnEh;
  Height: Single;
  QrCellSize: TSizeF;
  ResCellSize: TSizeF;
  ACellManager: TVPBaseCellManagerEh;
  CellLaObject: TVPBaseCellHolderEh;
begin
  FRowHeight := 0;
  Grid := TCustomDataGridEhCrack(GetGrid());
  if Grid.Scene = nil then Exit;

  ACellManager := Grid.HDataVFooterPanel.GetCellManagerAt(0, 0);
  CellLaObject := ACellManager.CreateCellHolder;
  try

    for I := 0 to Grid.VisibleColumns.Count - 1 do
    begin
      Column := Grid.VisibleColumns[I];
      QrCellSize := TSizeF.Create(Column.ActualWidth, TLaControlEh.MaxSize.Height);
      ResCellSize := ACellManager.InitAndCaclRenderCellHolder(
        Grid, QrCellSize, CellLaObject, -1, -1, I, Index);

      Height := ResCellSize.Height;
      if Height > FRowHeight then
        FRowHeight := System.Math.Ceil(Height);
    end;

  finally
    CellLaObject.Free;
  end;
end;

{$ENDREGION 'TDataGridFooterRowEh'}

{$REGION 'TBaseDataGridFooterCalcInitDataParamsEh'}

{ TBaseDataGridFooterCalcInitDataParamsEh }

constructor TBaseDataGridFooterCalcInitDataParamsEh.Create;
begin

end;

function TBaseDataGridFooterCalcInitDataParamsEh.DefaultCalcInitData: TValue;
begin
  if FAggregator <> nil then
    FAggregator.CalcInitData(Result, FRowCount);
end;

procedure TBaseDataGridFooterCalcInitDataParamsEh.Init(AGrid: TControl; AColumn: TFieldBarEh;
  AColumnFooter: TDataGridBaseColumnFooterEh; ARowCount: Integer);
begin
  FGrid := AGrid;
  FColumn := AColumn;
  FColumnFooter := AColumnFooter;
  FRowCount := ARowCount;

  FAggrValue := TValue.Empty;
  FAggregator := FColumnFooter.Aggregator;
  FAggregateFunction := FColumnFooter.AggregateFunction;
  FHandled := False;
end;

{$ENDREGION 'TBaseDataGridFooterCalcInitDataParamsEh'}

{$REGION 'TBaseDataGridFooterCalcStepDataParamsEh'}

{ TBaseDataGridFooterCalcStepDataParamsEh }

constructor TBaseDataGridFooterCalcStepDataParamsEh.Create;
begin

end;

function TBaseDataGridFooterCalcStepDataParamsEh.DefaultCalcStepData: TValue;
begin
  if FAggregator <> nil then
  begin
    Result := AggrValue;
    FAggregator.CalcStepData(StepValue, Result);
  end;
end;

procedure TBaseDataGridFooterCalcStepDataParamsEh.Init(AGrid: TControl; AColumn: TFieldBarEh;
  AColumnFooter: TDataGridBaseColumnFooterEh; ADataRow: TDataGridRowEh; const AAggrValue, AStepValue: TValue);
begin
  FGrid := AGrid;
  FColumn := AColumn;
  FColumnFooter := AColumnFooter;
  FDataRow := ADataRow;

  FAggrValue := AAggrValue;
  FStepValue := AStepValue;
  FAggregator := FColumnFooter.Aggregator;
  FAggregateFunction := FColumnFooter.AggregateFunction;
  FHandled := False;
end;

{$ENDREGION 'TBaseDataGridFooterCalcStepDataParamsEh'}

{$REGION 'TBaseDataGridFooterCalcFinalDataParamsEh'}

{ TBaseDataGridFooterCalcFinalDataParamsEh }

constructor TBaseDataGridFooterCalcFinalDataParamsEh.Create;
begin
end;

function TBaseDataGridFooterCalcFinalDataParamsEh.DefaultCalcFinalData: TValue;
begin
  if FAggregator <> nil then
  begin
    Result := FAggregator.CalcFinalData(AggrValue);
  end;
end;

procedure TBaseDataGridFooterCalcFinalDataParamsEh.Init(AGrid: TControl; AColumn: TFieldBarEh;
  AColumnFooter: TDataGridBaseColumnFooterEh; const AAggrValue: TValue);
begin
  FGrid := AGrid;
  FColumn := AColumn;
  FColumnFooter := AColumnFooter;

  FAggrValue := AAggrValue;
  FAggregator := FColumnFooter.Aggregator;
  FAggregateFunction := FColumnFooter.AggregateFunction;
  FHandled := False;
end;

{$ENDREGION 'TBaseDataGridFooterCalcFinalDataParamsEh'}

{$REGION 'TBaseDataGridFooterGetDisplayTextParamsEh'}

{ TBaseDataGridFooterGetDisplayTextParamsEh }

constructor TBaseDataGridFooterGetDisplayTextParamsEh.Create;
begin
end;

function TBaseDataGridFooterGetDisplayTextParamsEh.DefaultGetDisplayText: String;
begin
  Result := ColumnFooter.FormatDisplayText(AggrValue);
end;

procedure TBaseDataGridFooterGetDisplayTextParamsEh.Init(AGrid: TControl; AColumn: TFieldBarEh;
  AColumnFooter: TDataGridBaseColumnFooterEh; const AValue: TValue);
begin
  FGrid := AGrid;
  FColumn := AColumn;
  FColumnFooter := AColumnFooter;

  FAggrValue := AValue;
  FHandled := False;
end;

{$ENDREGION 'TBaseDataGridFooterGetDisplayTextParamsEh'}

{$REGION 'TDataGridFooterGetCellManagerParamsEh'}

{ TDataGridFooterGetCellManagerParamsEh }

procedure TDataGridFooterGetCellManagerParamsEh.Init(AGrid: TControl; AColumn: TFieldBarEh;
  AFooter: TDataGridBaseColumnFooterEh; ARowIndex: Integer; ADefaultCellManager: TBaseGridCellManagerEh);
begin
  FGrid := AGrid;
  FColumn := AColumn;
  FFooter := AFooter;
  FRowIndex := ARowIndex;
  FCellManager := ADefaultCellManager;
end;

{$ENDREGION 'TDataGridFooterGetCellManagerParamsEh'}

{$REGION 'TDataGridFooterInitCellContentParamsEh'}

{ TDataGridFooterInitCellContentParamsEh }

procedure TDataGridFooterInitCellContentParamsEh.Init(ACell: TGridBaseCellEh; ACellContent: TLaObjectEh;
  InitCellParams: TBaseGridInitCellParamsEh);
begin
  inherited Init(ACell, ACellContent, InitCellParams);
end;

{$ENDREGION 'TDataGridFooterInitCellContentParamsEh'}

{$REGION 'TDataGridFooterInitCellParamsEh'}

{ TDataGridFooterInitCellParamsEh }

procedure TDataGridFooterInitCellParamsEh.Init(AGrid: TControl; ACellManager: TBaseGridCellManagerEh;
  ACell: TGridBaseCellEh);
var
  VGrid: TCustomDataGridEhCrack;
begin
  inherited Init(AGrid, ACellManager, ACell);

  VGrid := TCustomDataGridEhCrack(ACell.Grid);

  if (ACell.AreaColIndex >= 0) and (ACell.AreaColIndex < VGrid.VisibleColumns.Count)
    then FColumn := VGrid.VisibleColumns[ACell.AreaColIndex]
    else FColumn := nil;

  if (FColumn <> nil) and (ACell.AreaColIndex < TDataGridBaseColumnEh(FColumn).Footers.Count)
    then FFooter := TDataGridBaseColumnEh(FColumn).Footers[ACell.AreaColIndex]
    else FFooter := nil;

  FRowIndex := ACell.AreaRowIndex;
end;

{$ENDREGION 'TDataGridFooterInitCellParamsEh'}

{$REGION 'TDataGridFooterCellHolderEh'}

{ TDataGridFooterCellHolderEh }

procedure TDataGridFooterCellHolderEh.CreateControls(AParent: TLaObjectEh);
begin
  with TLaGridPanelEh.CreateWith(AParent, AParent) do
  begin
    Name := 'ClientPanel';

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

    //TreeViewArea
    FTreeViewArea := TGridCellTreeViewAreaControlEh.CreateWith(RefSelf, RefSelf);
    FTreeViewArea.Name := 'TreeViewArea';
    FTreeViewArea.OnTreeSignMouseDown := TreeSignMouseDown;
    ControlCollection.AddControl(FTreeViewArea, 0, -1);

    //CellClient
    inherited CreateControls(RefSelf);
    ControlCollection.AddControl(CellClient, 1, -1);
    CellClient.Margins.Bottom := 1;
  end;

  FBottomLine := TLaControlEh.Create(AParent);
  FBottomLine.Parent := AParent;
  FBottomLine.VertAlignment := TLaVertAlignmentEh.Bottom;
  FBottomLine.HorzAlignment := TLaHorzAlignmentEh.Stretch;
  FBottomLine.Fill.Color := TAlphaColorRec.Cadetblue;
  FBottomLine.Fill.Kind := TBrushKind.Solid;
  FBottomLine.Height := 1;
  FBottomLine.Name := 'BottomLine';
end;

procedure TDataGridFooterCellHolderEh.TreeSignMouseDown(Sender: TObject;
  Params: TControlMouseButtonParamsEh);
begin
  if (TreeViewArea.Visible = True) and (TreeViewArea.SignVisible = True) then
    TDataGridFooterCellEh(CellManager).CellTreeSignMouseDown(Self, Params);
end;

{$ENDREGION 'TDataGridFooterCellHolderEh'}

end.
