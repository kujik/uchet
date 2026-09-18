{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{                EhLibFmx.DataVertGrids                 }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataVertGrids;

interface

{$SCOPEDENUMS ON}

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, System.Types,
  FMX.Graphics, System.UITypes, System.Math, Rtti, FMX.Forms, System.Contnrs,
  FMX.Grid, FMX.Platform, Data.DB, System.Variants, System.StrUtils,
  FMX.Objects, FMX.Menus, System.Generics.Collections, FMX.ImgList,
  EhLibUtils, DBUtilsEh, TypInfo,
  EhLib.TableLinks,
  EhLibFmx.GridAxisData,
  EhLibFmx.Grids,
  EhLibFmx.Grid.Types,
  EhLibFmx.Grid.CellManagers,
  EhLibFmx.SearchPanels,
  EhLib.GridTableViews,

  EhLibFmx.DataAxisGrids,
  EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.DataAxisGrid.DataCells,
  EhLibFmx.DataAxisGrid.ComboDataCells,

  EhLibFmx.CustomDataVertGrids,
  EhLibFmx.DataVertGrid.Columns,
  EhLibFmx.DataVertGrid.RowsHeader,
  EhLibFmx.DataVertGrid.Rows,

  EhLibFmx.ToolControls,
  EhLibFmx.Grid.InplaceEditors,
  EhLibFmx.Platform,
  EhLibFmx.Types,
  EhLibFmx.LaHostVirtualPanels,
  EhLibFmx.Grid.ToolControls,
  EhLibFmx.LaObjects,
  EhLibFmx.LaControls,
  EhLibFmx.LaPanels
  ;

type
  TDataVertGridEh = class;
  TDataVertGridRowEh = class;

{ TDataVertGridEventParamsEh }

  TDataVertGridEventParamsEh = class(TPersistent)
  private
    FGrid: TDataVertGridEh;
  public
    constructor Create;
    procedure Init(AGrid: TDataVertGridEh);

    property Grid: TDataVertGridEh read FGrid;
  end;

{ TDataVertGridCreateDataCellContentParamsEh }

  TDataVertGridCreateDataCellContentParamsEh = class(TPersistent)
  private
    FAxisCellParams: TDataAxisCreateCellContentParamsEh;
    function GetGrid: TControl;
    function GetCell: TGridBaseCellEh;
    function GetCellContent: TLaObjectEh;
    function GetContentParent: TLaObjectEh;
    procedure SetCellContent(const Value: TLaObjectEh);
  public
    procedure Init(AAxisCellParams: TDataAxisCreateCellContentParamsEh); virtual;
    function DefaultCreateCellContent(AContentParent: TLaObjectEh): TLaObjectEh; virtual;

    property AxisCellParams: TDataAxisCreateCellContentParamsEh read FAxisCellParams;
    property Cell: TGridBaseCellEh read GetCell;
    property Grid: TControl read GetGrid;
    property CellContent: TLaObjectEh  read GetCellContent write SetCellContent;
    property ContentParent: TLaObjectEh read GetContentParent;
  end;

{ TDataGridDataCellStyleParamsEh }

  TDataVertGridDataCellStyleParamsEh = class(TFieldBarDataCellStyleParamsEh)
  private
    function GetGrid: TDataVertGridEh;
    function GetRow: TDataVertGridRowEh;
    function GetColumn: TDataVertGridColumnEh;
  public
    property Row: TDataVertGridRowEh read GetRow;
    property Column: TDataVertGridColumnEh read GetColumn;
    property Grid: TDataVertGridEh read GetGrid;
  end;

{ TDataVertGridStringDataCellStyleParamsEh }

  TDataVertGridStringDataCellStyleParamsEh = class(TDataVertGridDataCellStyleParamsEh)
  private
    function GetTrimming: TTextTrimming;
    function GetWordWrap: Boolean;
    procedure SetTrimming(const Value: TTextTrimming);
    procedure SetWordWrap(const Value: Boolean);
  public
    procedure Init(ADataAxisCellParams: TDataAxisCellStyleParamsEh); override;

    property WordWrap: Boolean read GetWordWrap write SetWordWrap;
    property Trimming: TTextTrimming read GetTrimming write SetTrimming;
  end;

{ TDataVertGridDataCellGetDisplayTextParamsEh }

  TDataVertGridDataCellGetDisplayTextParamsEh = class (TDataAxisGridGetDisplayTextParamsEh)
  private
    function GetGrid: TDataVertGridEh;
    function GetRow: TDataVertGridBaseRowEh;
  public
    property Column: TDataVertGridBaseRowEh read GetRow;
    property Grid: TDataVertGridEh read GetGrid;
  end;

{ TDataGridGetDataCellValueParamsEh }

  TDataVertGridDataCellGetValueParamsEh = class(TDataAxisGridGetBarValueParamsEh)
  private
    function GetGrid: TDataVertGridEh;
    function GetRow: TDataVertGridRowEh;
    function GetColumn: TDataVertGridColumnEh;
  public
    property Row: TDataVertGridRowEh read GetRow;
    property Column: TDataVertGridColumnEh read GetColumn;
    property Grid: TDataVertGridEh read GetGrid;
  end;

{ TDataVertGridDataCellSetValueParamsEh }

  TDataVertGridDataCellSetValueParamsEh = class(TDataAxisGridSetBarValueParamsEh)
  private
    function GetGrid: TDataVertGridEh;
    function GetRow: TDataVertGridRowEh;
    function GetColumn: TDataVertGridColumnEh;
  public
    property Row: TDataVertGridRowEh read GetRow;
    property Column: TDataVertGridColumnEh read GetColumn;
    property Grid: TDataVertGridEh read GetGrid;
  end;

{ TDataVertGridDataCellKeyDownParamsEh }

  TDataVertGridDataCellKeyDownParamsEh = class(TBaseGridCellKeyDownParamsEh)
  private
    FRow: TDataVertGridBaseRowEh;
    FColumn: TDataVertGridColumnEh;

    function GetGrid: TDataVertGridEh;

  protected
    procedure Reset(AGrid: TControl; ACellManager: TBaseGridCellManagerEh; AColIndex: Integer; ARowIndex: Integer; AAreaColIndex: Integer; AAreaRowIndex: Integer; AKey: Word; AKeyChar: WideChar; AShift: TShiftState); override;

  public

    property Row: TDataVertGridBaseRowEh read FRow;
    property Column: TDataVertGridColumnEh read FColumn;
    property Grid: TDataVertGridEh read GetGrid;
  end;

{ TDataVertGridDataCellMouseButtonParamsEh }

  TDataVertGridDataCellMouseButtonParamsEh = class(TPersistent)
  private
    FAxisCellParams: TDataAxisCellMouseButtonParamsEh;
    function GetGrid: TDataVertGridEh;
    function GetColumn: TDataVertGridColumnEh;
    function GetRow: TDataVertGridBaseRowEh;
    function GetCell: TGridBaseCellEh;
    function GetHandled: Boolean;
    function GetButton: TMouseButton;
    function GetShift: TShiftState;

    procedure SetHandled(const Value: Boolean);
  protected
    procedure Init(AAxisCellParams: TDataAxisCellMouseButtonParamsEh); virtual;

  public
    property AxisCellParams: TDataAxisCellMouseButtonParamsEh read FAxisCellParams;
    property Grid: TDataVertGridEh read GetGrid;
    property Row: TDataVertGridBaseRowEh read GetRow;
    property Column: TDataVertGridColumnEh read GetColumn;
    property Button: TMouseButton read GetButton;
    property Shift: TShiftState read GetShift;
    property Cell: TGridBaseCellEh read GetCell;
    property Handled: Boolean read GetHandled write SetHandled;
  end;

{ TDataVertGridInitDataCellContentParamsEh }

  TDataVertGridInitDataCellContentParamsEh = class(TPersistent)
  private
    FAxisCellParams: TDataAxisInitCellContentParamsEh;
    FInitCellParams: TBaseGridInitCellParamsEh;

    function GetGrid: TDataVertGridEh;
    function GetRow: TDataVertGridBaseRowEh;
    function GetColumn: TDataVertGridColumnEh;
    function GetStyleParams: TDataAxisCellStyleParamsEh;
    function GetCell: TGridBaseCellEh;
    function GetCellContent: TLaObjectEh;
    function GetCellManager: TVPBaseCellManagerEh;
    function GetHandled: Boolean;
    procedure SetHandled(const Value: Boolean);
  public
    procedure Init(AAxisCellParams: TDataAxisInitCellContentParamsEh); virtual;

    property Grid: TDataVertGridEh read GetGrid;
    property Row: TDataVertGridBaseRowEh read GetRow;
    property Column: TDataVertGridColumnEh read GetColumn;
    property StyleParams: TDataAxisCellStyleParamsEh read GetStyleParams;

    property CellManager: TVPBaseCellManagerEh read GetCellManager;
    property Cell: TGridBaseCellEh read GetCell;
    property CellContent: TLaObjectEh  read GetCellContent;
    property InitCellParams: TBaseGridInitCellParamsEh read FInitCellParams;
    property Handled: Boolean read GetHandled write SetHandled;
  end;

{ TDataVertGridGetDataCellManagerParamsEh }

  TDataVertGridGetDataCellManagerParamsEh = class(TBaseDataVertGridGetDataCellManagerParamsEh)
  private
    function GetGrid: TDataVertGridEh;
  public
    property Grid: TDataVertGridEh read GetGrid;
  end;

{ TDataVertGridInitEditorParamsEh }

  TDataVertGridInitEditorParamsEh = class(TPersistent)
  private
    FBaseCellParams: TBaseGridInitEditorParamsEh;

    function GetGrid: TDataVertGridEh;
    function GetRow: TDataVertGridBaseRowEh;
    function GetColumn: TDataVertGridColumnEh;

    function GetCell: TGridBaseCellEh;
    function GetEditor: TLaObjectEh;
    function GetEditorParams: TBaseGridCellEditParamsEh;
    function GetHandled: Boolean;

    procedure SetHandled(const Value: Boolean);
  public
    procedure Init(ABaseCellParams: TBaseGridInitEditorParamsEh); virtual;

    property Grid: TDataVertGridEh read GetGrid;
    property Row: TDataVertGridBaseRowEh read GetRow;
    property Column: TDataVertGridColumnEh read GetColumn;

    property Cell: TGridBaseCellEh read GetCell;
    property Editor: TLaObjectEh read GetEditor;
    property EditorParams: TBaseGridCellEditParamsEh read GetEditorParams;
    property Handled: Boolean read GetHandled write SetHandled;
  end;

{ TDataVertGridDataCellInTextLinkClickParamsEh }

  TDataVertGridDataCellInTextLinkClickParamsEh = class(TPersistent)
  private
    FCellParams: TDataAxisCellInTextLinkClickParamsEh;
    function GetRow: TDataVertGridBaseRowEh;
    function GetGrid: TDataVertGridEh;
    function GetHandled: Boolean;
    function GetColumn: TDataVertGridColumnEh;
    procedure SetHandled(const Value: Boolean);
    function GetLinkText: String;

  public
    procedure Init(ACellParams: TDataAxisCellInTextLinkClickParamsEh); virtual;

    property Grid: TDataVertGridEh read GetGrid;
    property Row: TDataVertGridBaseRowEh read GetRow;
    property Column: TDataVertGridColumnEh read GetColumn;
    property LinkText: String read GetLinkText;

    property Handled: Boolean  read GetHandled write SetHandled;
  end;

  TDataVertGridEventEh = procedure(Sender: TObject; Params: TDataVertGridEventParamsEh) of object;

  TDataVertGridDataCellGetValueEventEh = procedure(Sender: TObject; Params: TDataVertGridDataCellGetValueParamsEh) of object;
  TDataVertGridDataCellSetValueEventEh = procedure(Sender: TObject; Params: TDataVertGridDataCellSetValueParamsEh) of object;
  TDataVertGridDataCellGetStyleParamsEventEh = procedure(Sender: TObject; Params: TDataVertGridDataCellStyleParamsEh) of object;
  TDataVertGridCreateDataCellContentEventEh = procedure(Sender: TObject; Params: TDataVertGridCreateDataCellContentParamsEh) of object;
  TDataVertGridDataCellGetDisplayTextEventEh = procedure(Sender: TObject; Params: TDataVertGridDataCellGetDisplayTextParamsEh) of object;
  TDataVertGridDataCellKeyDownEventEh = procedure(Sender: TObject; Params: TDataVertGridDataCellKeyDownParamsEh) of object;
  TDataVertGridDataCellMouseButtonEventEh = procedure(Sender: TObject; Params: TDataVertGridDataCellMouseButtonParamsEh) of object;
  TDataVertGridInitDataCellContentEventEh = procedure(Sender: TObject; Params: TDataVertGridInitDataCellContentParamsEh) of object;
  TDataVertGridGetDataCellManagerEventEh = procedure(Sender: TObject; Params: TDataVertGridGetDataCellManagerParamsEh) of object;
  TDataVertGridDataCellInitEditorEventEh = procedure(Sender: TObject; Params: TDataVertGridInitEditorParamsEh) of object;
  TDataVertGridDataCellInTextLinkClickEventEh = procedure(Sender: TObject; Params: TDataVertGridDataCellInTextLinkClickParamsEh) of object;

  TDataVertGridStringDataCellGetStyleParamsEventEh = procedure(Sender: TObject; Params: TDataVertGridStringDataCellStyleParamsEh) of object;

{ TDataVertGridRowEh }

  TDataVertGridRowEh = class(TDataVertGridBaseRowEh)
  private
    FOnCreateDataCellContent: TDataVertGridCreateDataCellContentEventEh;
    FOnDataCellGetDisplayText: TDataVertGridDataCellGetDisplayTextEventEh;
    FOnDataCellGetStyleParams: TDataVertGridDataCellGetStyleParamsEventEh;
    FOnDataCellGetValue: TDataVertGridDataCellGetValueEventEh;
    FOnDataCellSetValue: TDataVertGridDataCellSetValueEventEh;
    FOnDataCellInitContent: TDataVertGridInitDataCellContentEventEh;
    FOnDataCellMouseDown: TDataVertGridDataCellMouseButtonEventEh;
    FOnGetDataCellManager: TDataVertGridGetDataCellManagerEventEh;
    FOnDataCellInitEditor: TDataVertGridDataCellInitEditorEventEh;
  protected
    function CreateGetDisplayTextParams(): TDataAxisGridGetDisplayTextParamsEh; override;
    function CreateFieldBarStyleParams(): TFieldBarDataCellStyleParamsEh; override;
    function CreateGetBarValueEventParams(): TDataAxisGridGetBarValueParamsEh; override;
    function CreateSetBarValueEventParams(): TDataAxisGridSetBarValueParamsEh; override;
    function CreateGetCellManagerParams(): TBaseDataVertGridGetDataCellManagerParamsEh; override;

    procedure HandleCreateCellContent(Params: TBaseGridCreateCellContentParamsEh); override;
    procedure HandleDataCellGetDisplayText(Params: TDataAxisGridGetDisplayTextParamsEh); override;
    procedure HandleGetFieldBarStyleParams(Params: TDataAxisCellStyleParamsEh); override;
    procedure HandleDataCellGetValue(Params: TDataAxisGridGetBarValueParamsEh); override;
    procedure HandleDataCellSetValue(Params: TDataAxisGridSetBarValueParamsEh); override;
    procedure HandleDataCellInitContent(Params: TBaseGridInitCellContentParamsEh); override;
    procedure HandleDataCellMouseDownEvent(Params: TGridCellMouseButtonParamsEh); override;
    procedure HandleGetDataCellManager(Params: TBaseDataVertGridGetDataCellManagerParamsEh); override;
    procedure HandleInitCellEditor(AParams: TBaseGridInitEditorParamsEh); override;

    property OnDataCellGetDisplayText: TDataVertGridDataCellGetDisplayTextEventEh read FOnDataCellGetDisplayText write FOnDataCellGetDisplayText;
  public

  published
    property AllowShowEditor;

    property OnCreateDataCellContent: TDataVertGridCreateDataCellContentEventEh read FOnCreateDataCellContent write FOnCreateDataCellContent;
    property OnDataCellGetStyleParams: TDataVertGridDataCellGetStyleParamsEventEh read FOnDataCellGetStyleParams write FOnDataCellGetStyleParams;
    property OnDataCellGetValue: TDataVertGridDataCellGetValueEventEh read FOnDataCellGetValue write FOnDataCellGetValue;
    property OnDataCellInitContent: TDataVertGridInitDataCellContentEventEh read FOnDataCellInitContent write FOnDataCellInitContent;
    property OnDataCellMouseDown: TDataVertGridDataCellMouseButtonEventEh read FOnDataCellMouseDown write FOnDataCellMouseDown;
    property OnDataCellSetValue: TDataVertGridDataCellSetValueEventEh read FOnDataCellSetValue write FOnDataCellSetValue;
    property OnGetDataCellManager: TDataVertGridGetDataCellManagerEventEh read FOnGetDataCellManager write FOnGetDataCellManager;
    property OnDataCellInitEditor: TDataVertGridDataCellInitEditorEventEh read FOnDataCellInitEditor write FOnDataCellInitEditor;
  end;

{ TDataVertGridStringRowEh }

  TDataVertGridStringRowEh = class(TDataVertGridRowEh)
  private
    FWordWrap: Boolean;
    FWordWrapStored: Boolean;
    FTrimming: TTextTrimming;
    FTrimmingStored: Boolean;
    FOnDataCellGetStyleParams: TDataVertGridStringDataCellGetStyleParamsEventEh;
    FHighlightHyperlinks: Boolean;
    FOnDataCellInTextLinkClick: TDataVertGridDataCellInTextLinkClickEventEh;

    function GetWordWrap: Boolean;
    function IsWordWrapStored: Boolean;
    function IsTrimmingStored: Boolean;

    procedure SetWordWrap(const Value: Boolean);
    procedure SetWordWrapStored(const Value: Boolean);
    procedure SetTrimmingStored(const Value: Boolean);
    function GetTrimming: TTextTrimming;
    procedure SetTrimming(const Value: TTextTrimming);
    function GetDefaultCellManager: TDataAxisTextCellManagerEh;
    function GetDisplayFormat: String;
    function GetDisplayFormatStored: Boolean;
    function IsDisplayFormatStored: Boolean;
    procedure SetDisplayFormat(const Value: String);
    procedure SetDisplayFormatStored(const Value: Boolean);

  protected
    function CreateFieldBarStyleParams(): TFieldBarDataCellStyleParamsEh; override;
    function CreateCellManager: TBaseGridCellManagerEh; override;

    function DefaultWordWrap: Boolean; virtual;
    function DefaultTrimming: TTextTrimming; virtual;

    procedure HandleGetFieldBarStyleParams(Params: TDataAxisCellStyleParamsEh); override;
    procedure HandleDataCellInTextLinkClick(Params: TDataAxisCellInTextLinkClickParamsEh); override;

  public
    procedure InitCell(ACell: TGridBaseCellEh; AStyleParams: TDataAxisCellStyleParamsEh); override;
    procedure DefaultInitCellEditor(AInitEditorParams: TBaseGridInitEditorParamsEh); override;
    procedure InitStyleParams(Params: TDataAxisCellStyleParamsEh); override;

    property DefaultCellManager: TDataAxisTextCellManagerEh read GetDefaultCellManager;
  published
    property DisplayFormat: String read GetDisplayFormat write SetDisplayFormat stored IsDisplayFormatStored;
    property DisplayFormatStored: Boolean read GetDisplayFormatStored write SetDisplayFormatStored default False;

    property WordWrap: Boolean read GetWordWrap write SetWordWrap stored IsWordWrapStored;
    property WordWrapStored: Boolean read IsWordWrapStored write SetWordWrapStored default False;

    property Trimming: TTextTrimming read GetTrimming write SetTrimming stored IsTrimmingStored;
    property TrimmingStored: Boolean read IsTrimmingStored write SetTrimmingStored default False;

    property HighlightHyperlinks: Boolean read FHighlightHyperlinks write FHighlightHyperlinks default False;

    property OnDataCellGetStyleParams: TDataVertGridStringDataCellGetStyleParamsEventEh read FOnDataCellGetStyleParams write FOnDataCellGetStyleParams;
    property OnDataCellGetDisplayText;
    property OnDataCellInTextLinkClick: TDataVertGridDataCellInTextLinkClickEventEh read FOnDataCellInTextLinkClick write FOnDataCellInTextLinkClick;
  end;

{ TDataVertGridComboDropDownBoxEh }

  TDataVertGridComboDropDownBoxEh = class(TBaseDataAxisGridComboDropDownBoxEh)
  private
    FOnDataCellGetStyleParams: TDataVertGridDataCellGetStyleParamsEventEh;

  protected
    procedure HandleDataCellGetStyleParams(Params: TDataAxisCellStyleParamsEh); override;

  published
    property OnDataCellGetStyleParams: TDataVertGridDataCellGetStyleParamsEventEh read FOnDataCellGetStyleParams write FOnDataCellGetStyleParams;
  end;

{ TDataVertGridComboboxRowEh }

  TDataVertGridComboboxRowEh = class(TDataVertGridStringRowEh)
  private
    FDropDownBox: TDataVertGridComboDropDownBoxEh;
    procedure SetListSource(const Value: TComponent);
    procedure SetListFieldName(const Value: String);
    procedure SetListKeyFieldName(const Value: String);
    function GetDefCellManager: TDataAxisGridComboboxCellManagerEh;
    function GetListFieldName: String;
    function GetListKeyFieldName: String;
    function GetListSource: TComponent;
    function GetIsLookupMode: Boolean;
    function GetDropDownBox: TDataVertGridComboDropDownBoxEh;

  protected
    function CreateCellManager: TBaseGridCellManagerEh; override;

    function DefaultGetLookupDisplayText(const VarValue: TValue): String; virtual;
    function CreateDropDownBox: TBaseDataAxisGridComboDropDownBoxEh; virtual;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure BindField; override;
    procedure DefaultSetValue(const Value: TValue); override;

    property DefCellManager: TDataAxisGridComboboxCellManagerEh read GetDefCellManager;
    property IsLookupMode: Boolean read GetIsLookupMode;

  published
    property ListSource: TComponent read GetListSource write SetListSource;
    property ListFieldName: String read GetListFieldName write SetListFieldName;
    property ListKeyFieldName: String read GetListKeyFieldName write SetListKeyFieldName;
    property DropDownBox: TDataVertGridComboDropDownBoxEh read GetDropDownBox;
  end;

{ TDataGridCheckboxColumnEh }

  TDataVertGridCheckboxRowEh = class(TDataVertGridRowEh)
  private
    function GetIsChecked(ARow: TDataVertGridColumnEh): Boolean;
    function GetCheckedValue: TValue;
    function GetUncheckedValue: TValue;
    procedure SetCheckedValue(const Value: TValue);
    procedure SetUncheckedValue(const Value: TValue);
    function GetDefCellManager: TDataAxisCheckboxCellManagerEh;
    function IsCheckedValueStored: Boolean;
    function IsUncheckedValueStored: Boolean;
  protected
    function CreateCellManager: TBaseGridCellManagerEh; override;
    procedure ProcessDataCellKeyDown(Params: TBaseGridCellKeyDownParamsEh); override;
  public
    function CanEditShow: Boolean; override;

    procedure InitCell(ACell: TGridBaseCellEh; AStyleParams: TDataAxisCellStyleParamsEh); override;

    procedure Toggle;

    property IsChecked[ARow: TDataVertGridColumnEh]: Boolean read GetIsChecked;
    property DefCellManager: TDataAxisCheckboxCellManagerEh read GetDefCellManager;

  public
    property CheckedValue: TValue read GetCheckedValue write SetCheckedValue stored IsCheckedValueStored;
    property UncheckedValue: TValue read GetUncheckedValue write SetUncheckedValue stored IsUncheckedValueStored;
  published
  end;

{ TDataVertGridGraphicRowEh }

  TDataVertGridGraphicRowEh = class(TDataVertGridRowEh)
  private
    procedure SetImageList(const Value: TCustomImageList);
    function GetDefCellManager: TDataAxisGraphicCellManagerEh;
    function GetImageList: TCustomImageList;
  protected
    function CreateCellManager: TBaseGridCellManagerEh; override;
  public
    function CanEditShow: Boolean; override;
    procedure InitCell(ACell: TGridBaseCellEh; AStyleParams: TDataAxisCellStyleParamsEh); override;

    property DefCellManager: TDataAxisGraphicCellManagerEh read GetDefCellManager;

  published
    property ImageList: TCustomImageList read GetImageList write SetImageList;
  end;

{ TDataVertGridLayoutRowEh }

  TDataVertGridLayoutRowEh = class(TDataVertGridRowEh)
  private
  protected
    function CreateCellManager: TBaseGridCellManagerEh; override;
    function DefaultAllowShowEditor(): Boolean; override;

  published
  end;

{ TDataVertGridEh }

  TDataVertGridEh = class(TCustomDataVertGridEh)
  private
    FOnDataCellGetStyleParams: TDataVertGridDataCellGetStyleParamsEventEh;
    FOnCurrentChange: TDataVertGridEventEh;
    FOnDataCellGetDisplayText: TDataVertGridDataCellGetDisplayTextEventEh;
    FOnDataCellGetValue: TDataVertGridDataCellGetValueEventEh;
    FOnDataCellKeyDown: TDataVertGridDataCellKeyDownEventEh;
    FOnDataCellMouseDown: TDataVertGridDataCellMouseButtonEventEh;
    FOnDataCellMouseClick: TDataVertGridDataCellMouseButtonEventEh;
    FOnDataCellSetValue: TDataVertGridDataCellSetValueEventEh;

  protected
    function CreateDataCellKeyDownParams(AGrid: TControl; AColIndex, ARowIndex, AAreaColIndex, AAreaRowIndex: Integer): TBaseGridCellKeyDownParamsEh; override;

    procedure HandleDataCellGetStyleParams(Params: TDataAxisCellStyleParamsEh); override;
    procedure HandleCurrentPosChange(); override;
    procedure HandleDataCellGetDisplayText(Params: TDataAxisGridGetDisplayTextParamsEh); override;
    procedure HandleDataCellGetValue(Params: TDataAxisGridGetBarValueParamsEh); override;
    procedure HandleDataCellKeyDownEvent(Params: TBaseGridCellKeyDownParamsEh); override;
    procedure HandleDataCellMouseClickEvent(Params: TGridCellMouseButtonParamsEh); override;
    procedure HandleDataCellMouseDownEvent(Params: TGridCellMouseButtonParamsEh); override;
    procedure HandleDataCellSetValue(Params: TDataAxisGridSetBarValueParamsEh); override;

  published
    property AutoGenerateRows;
    property RowOptions;
    property DataSource;
    property GridLineOptions;
    property ReadOnly;
    property RowsHeader;
    property StaticRows;

    property Anchors;
    property Align;
    property CanFocus;
    property CanParentFocus;
    property Cursor;
    property DisableFocusEffect;
    property Enabled;
    property Height;
    property Locked;
    property Padding;
    property Opacity;
    property Margins;
    property PopupMenu;
    property Position;
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property Size;
    property TabOrder;
    property TabStop;
    property Visible;
    property Width;

    property OnDataCellGetStyleParams: TDataVertGridDataCellGetStyleParamsEventEh read FOnDataCellGetStyleParams write FOnDataCellGetStyleParams;
    property OnCurrentChange: TDataVertGridEventEh read FOnCurrentChange write FOnCurrentChange;
    property OnDataCellGetDisplayText: TDataVertGridDataCellGetDisplayTextEventEh read FOnDataCellGetDisplayText write FOnDataCellGetDisplayText;
    property OnDataCellGetValue: TDataVertGridDataCellGetValueEventEh read FOnDataCellGetValue write FOnDataCellGetValue;
    property OnDataCellKeyDown: TDataVertGridDataCellKeyDownEventEh read FOnDataCellKeyDown write FOnDataCellKeyDown;
    property OnDataCellMouseClick: TDataVertGridDataCellMouseButtonEventEh read FOnDataCellMouseClick write FOnDataCellMouseClick;
    property OnDataCellMouseDown: TDataVertGridDataCellMouseButtonEventEh read FOnDataCellMouseDown write FOnDataCellMouseDown;
    property OnDataCellSetValue: TDataVertGridDataCellSetValueEventEh read FOnDataCellSetValue write FOnDataCellSetValue;
  end;

implementation

type
  TCustomDataVertGridEhCrack = class(TCustomDataVertGridEh);

{$REGION 'TDataVertGridEh'}

procedure TDataVertGridEh.HandleDataCellGetStyleParams(Params: TDataAxisCellStyleParamsEh);
var
  GridParams: TDataVertGridDataCellStyleParamsEh;
begin
  if Assigned(OnDataCellGetStyleParams) then
  begin
    GridParams := TDataVertGridDataCellStyleParamsEh.Create;
    GridParams.Init(Params);
    try
      OnDataCellGetStyleParams(Self, GridParams);
    finally
      GridParams.Free;
    end;
  end;
end;

procedure TDataVertGridEh.HandleCurrentPosChange;
var
  Params: TDataVertGridEventParamsEh;
begin
  Params := TDataVertGridEventParamsEh.Create;
  Params.Init(Self);
  try
    if Assigned(OnCurrentChange) then
      OnCurrentChange(Self, Params);
  finally
    Params.Free;
  end;
end;

procedure TDataVertGridEh.HandleDataCellGetDisplayText(Params: TDataAxisGridGetDisplayTextParamsEh);
begin
  if Assigned(OnDataCellGetDisplayText) then
    OnDataCellGetDisplayText(Self, TDataVertGridDataCellGetDisplayTextParamsEh(Params));
end;

procedure TDataVertGridEh.HandleDataCellGetValue(Params: TDataAxisGridGetBarValueParamsEh);
begin
  if Assigned(OnDataCellGetValue) then
    OnDataCellGetValue(Self, TDataVertGridDataCellGetValueParamsEh(Params));
end;

function TDataVertGridEh.CreateDataCellKeyDownParams(AGrid: TControl; AColIndex, ARowIndex, AAreaColIndex,
  AAreaRowIndex: Integer): TBaseGridCellKeyDownParamsEh;
begin
  Result := TDataVertGridDataCellKeyDownParamsEh.Create;
end;

procedure TDataVertGridEh.HandleDataCellKeyDownEvent(Params: TBaseGridCellKeyDownParamsEh);
begin
  if Assigned(OnDataCellKeyDown) then
    OnDataCellKeyDown(Self, TDataVertGridDataCellKeyDownParamsEh(Params));
end;

procedure TDataVertGridEh.HandleDataCellMouseClickEvent(Params: TGridCellMouseButtonParamsEh);
var
  GridParams: TDataVertGridDataCellMouseButtonParamsEh;
begin
  if Assigned(OnDataCellMouseClick) then
  begin
    GridParams := TDataVertGridDataCellMouseButtonParamsEh.Create;
    GridParams.Init(Params as TDataAxisCellMouseButtonParamsEh);
    try
      OnDataCellMouseClick(Self, GridParams);
    finally
      GridParams.Free;
    end;
  end;
end;

procedure TDataVertGridEh.HandleDataCellMouseDownEvent(Params: TGridCellMouseButtonParamsEh);
var
  GridParams: TDataVertGridDataCellMouseButtonParamsEh;
begin
  if Assigned(OnDataCellMouseDown) then
  begin
    GridParams := TDataVertGridDataCellMouseButtonParamsEh.Create;
    GridParams.Init(Params as TDataAxisCellMouseButtonParamsEh);
    try
      OnDataCellMouseDown(Self, GridParams);
    finally
      GridParams.Free;
    end;
  end;
end;

procedure TDataVertGridEh.HandleDataCellSetValue(Params: TDataAxisGridSetBarValueParamsEh);
begin
  if Assigned(OnDataCellSetValue) then
    OnDataCellSetValue(Self, TDataVertGridDataCellSetValueParamsEh(Params));
end;

{$ENDREGION 'TDataVertGridEh'}

{$REGION 'TDataVertGridStringRowEh'}

function TDataVertGridStringRowEh.CreateCellManager: TBaseGridCellManagerEh;
begin
  Result := TDataAxisTextCellManagerEh.Create(nil, Self);
end;

procedure TDataVertGridStringRowEh.DefaultInitCellEditor(AInitEditorParams: TBaseGridInitEditorParamsEh);
begin
  inherited DefaultInitCellEditor(AInitEditorParams);
end;

procedure TDataVertGridStringRowEh.InitCell(ACell: TGridBaseCellEh; AStyleParams: TDataAxisCellStyleParamsEh);
var
  TextDataCell: TDataAxisTextCellEh;
  StringStyleParams: TDataAxisStringCellStyleParamsEh;
begin
  inherited InitCell(ACell, AStyleParams);

  if ACell is TDataAxisTextCellEh then
  begin
    TextDataCell := TDataAxisTextCellEh(ACell);
    if AStyleParams is TDataAxisStringCellStyleParamsEh then
    begin
      StringStyleParams := TDataAxisStringCellStyleParamsEh(AStyleParams);
      TextDataCell.TextBlock.WordWrap := StringStyleParams.WordWrap;
      TextDataCell.TextBlock.Trimming := StringStyleParams.Trimming;
      TextDataCell.TextCellContent.HighlightHyperlinks := StringStyleParams.HighlightHyperlinks;
    end else
    begin
      TextDataCell.TextBlock.WordWrap := WordWrap;
      TextDataCell.TextBlock.Trimming := Trimming;
      TextDataCell.TextCellContent.HighlightHyperlinks := HighlightHyperlinks;
    end;

    TextDataCell.TextBlock.Margins := AStyleParams.Padding;
  end;
end;

procedure TDataVertGridStringRowEh.InitStyleParams(Params: TDataAxisCellStyleParamsEh);
var
  StringStyleParams: TDataAxisStringCellStyleParamsEh;
begin
  inherited InitStyleParams(Params);
  if Params is TDataAxisStringCellStyleParamsEh then
  begin
    StringStyleParams := TDataAxisStringCellStyleParamsEh(Params);
    StringStyleParams.WordWrap := WordWrap;
    StringStyleParams.Trimming := Trimming;
    StringStyleParams.HighlightHyperlinks := HighlightHyperlinks;
  end;
end;

function TDataVertGridStringRowEh.CreateFieldBarStyleParams(): TFieldBarDataCellStyleParamsEh;
begin
  Result := TDataVertGridStringDataCellStyleParamsEh.Create;
end;

{$REGION 'DisplayFormat'}

function TDataVertGridStringRowEh.GetDisplayFormat: String;
begin
  Result := DefaultCellManager.DisplayFormat;
end;

procedure TDataVertGridStringRowEh.SetDisplayFormat(const Value: String);
begin
  DefaultCellManager.DisplayFormat := Value;
end;

function TDataVertGridStringRowEh.GetDisplayFormatStored: Boolean;
begin
  Result := DefaultCellManager.DisplayFormatStored;
end;

procedure TDataVertGridStringRowEh.SetDisplayFormatStored(const Value: Boolean);
begin
  DefaultCellManager.DisplayFormatStored := Value;
end;

function TDataVertGridStringRowEh.IsDisplayFormatStored(): Boolean;
begin
  Result := DefaultCellManager.DisplayFormatStored;
end;

{$ENDREGION}

{$REGION 'WordWrap'}

function TDataVertGridStringRowEh.GetWordWrap: Boolean;
begin
  if IsWordWrapStored
    then Result := FWordWrap
    else Result := DefaultWordWrap();
end;

procedure TDataVertGridStringRowEh.SetWordWrap(const Value: Boolean);
begin
  if (IsWordWrapStored = False) or (Value <> FWordWrap) then
  begin
    FWordWrap := Value;
    FWordWrapStored := True;
    Changed();
  end;
end;

function TDataVertGridStringRowEh.DefaultWordWrap: Boolean;
begin
  if (GetGrid <> nil)
    then Result := TCustomDataVertGridEhCrack(GetGrid).FieldBarOptions.WordWrap
    else Result := False;
end;

function TDataVertGridStringRowEh.IsWordWrapStored: Boolean;
begin
  Result := FWordWrapStored;
end;

procedure TDataVertGridStringRowEh.SetWordWrapStored(const Value: Boolean);
begin
  if FWordWrapStored <> Value then
  begin
    FWordWrapStored := Value;
    Changed();
  end;
end;
{$ENDREGION WordWrap}

{$REGION 'Trimming'}
function TDataVertGridStringRowEh.GetTrimming: TTextTrimming;
begin
  if IsTrimmingStored
    then Result := FTrimming
    else Result := DefaultTrimming();
end;

procedure TDataVertGridStringRowEh.SetTrimming(const Value: TTextTrimming);
begin
  if (IsTrimmingStored = False) or (Value <> FTrimming) then
  begin
    FTrimming := Value;
    FTrimmingStored := True;
    Changed();
  end;
end;

function TDataVertGridStringRowEh.DefaultTrimming: TTextTrimming;
begin
  if (GetGrid <> nil)
    then Result := TCustomDataVertGridEhCrack(GetGrid).FieldBarOptions.Trimming
    else Result := TTextTrimming.None;
end;

function TDataVertGridStringRowEh.IsTrimmingStored: Boolean;
begin
  Result := FTrimmingStored;
end;

procedure TDataVertGridStringRowEh.SetTrimmingStored(const Value: Boolean);
begin
  if FTrimmingStored <> Value then
  begin
    FTrimmingStored := Value;
    Changed();
  end;
end;
{$ENDREGION Trimming}

procedure TDataVertGridStringRowEh.HandleGetFieldBarStyleParams(Params: TDataAxisCellStyleParamsEh);
var
  GridParams: TDataVertGridStringDataCellStyleParamsEh;
begin
  if Assigned(OnDataCellGetStyleParams) then
  begin
    GridParams := TDataVertGridStringDataCellStyleParamsEh.Create;
    GridParams.Init(Params);
    try
      OnDataCellGetStyleParams(Self, GridParams);
    finally
      GridParams.Free;
    end;
  end;
end;

function TDataVertGridStringRowEh.GetDefaultCellManager: TDataAxisTextCellManagerEh;
begin
  Result := TDataAxisTextCellManagerEh(FDefCellManager);
end;

procedure TDataVertGridStringRowEh.HandleDataCellInTextLinkClick(Params: TDataAxisCellInTextLinkClickParamsEh);
var
  GridParams: TDataVertGridDataCellInTextLinkClickParamsEh;
begin
  if Assigned(OnDataCellInTextLinkClick) then
  begin
    GridParams := TDataVertGridDataCellInTextLinkClickParamsEh.Create;
    GridParams.Init(Params);
    try
      OnDataCellInTextLinkClick(Self, GridParams);
    finally
      GridParams.Free;
    end;
  end;
end;

{$ENDREGION 'TDataVertGridStringRowEh'}

{ TDataGridCheckboxColumnEh }

function TDataVertGridCheckboxRowEh.CanEditShow: Boolean;
begin
  Result := False;
end;

function TDataVertGridCheckboxRowEh.CreateCellManager: TBaseGridCellManagerEh;
begin
  Result := TDataAxisCheckboxCellManagerEh.Create(nil, Self);
end;

function TDataVertGridCheckboxRowEh.GetIsChecked(ARow: TDataVertGridColumnEh): Boolean;
begin
  Result := DefCellManager.IsChecked[Self, ARow];
end;

procedure TDataVertGridCheckboxRowEh.InitCell(ACell: TGridBaseCellEh; AStyleParams: TDataAxisCellStyleParamsEh);
begin
  inherited InitCell(ACell, AStyleParams);
end;

procedure TDataVertGridCheckboxRowEh.ProcessDataCellKeyDown(Params: TBaseGridCellKeyDownParamsEh);
begin
end;

procedure TDataVertGridCheckboxRowEh.Toggle;
var
  Grid: TDataVertGridEh;
  VarValue: TValue;
  RowView: TTableRowLinkEh;
begin
  if (Field <> nil) then
  begin
    Grid := TDataVertGridEh(GetGrid);
    Grid.TableView.EditCurrentRow;
    RowView := Grid.TableView.CurrentRowView.SourceRowLink;
    VarValue := RowView.FieldValue[Field];
    if SameValue(VarValue, CheckedValue)
      then RowView.FieldValue[Field] := UncheckedValue
      else RowView.FieldValue[Field] := CheckedValue;
  end;
end;

function TDataVertGridCheckboxRowEh.GetDefCellManager: TDataAxisCheckboxCellManagerEh;
begin
  Result := TDataAxisCheckboxCellManagerEh(FDefCellManager);
end;

function TDataVertGridCheckboxRowEh.GetCheckedValue: TValue;
begin
  Result := DefCellManager.CheckedValue;
end;

procedure TDataVertGridCheckboxRowEh.SetCheckedValue(const Value: TValue);
begin
  if (DefCellManager.CheckedValue.TypeInfo <> Value.TypeInfo) or
     (SameValue(DefCellManager.CheckedValue, Value) = False) then
  begin
    DefCellManager.CheckedValue := Value;
    Changed();
  end;
end;

function TDataVertGridCheckboxRowEh.GetUncheckedValue: TValue;
begin
  Result := DefCellManager.UncheckedValue;
end;

procedure TDataVertGridCheckboxRowEh.SetUncheckedValue(const Value: TValue);
begin
  if (DefCellManager.UncheckedValue.TypeInfo <> Value.TypeInfo) or
     (SameValue(DefCellManager.UncheckedValue, Value) = False) then
  begin
    DefCellManager.UncheckedValue := Value;
    Changed();
  end;
end;

function TDataVertGridCheckboxRowEh.IsCheckedValueStored: Boolean;
begin
  if SameValue(CheckedValue, True)
    then Result := False
    else Result := True;
end;

function TDataVertGridCheckboxRowEh.IsUncheckedValueStored: Boolean;
begin
  if SameValue(UncheckedValue, False)
    then Result := False
    else Result := True;
end;

{ TDataGridGraphicColumnEh }

function TDataVertGridGraphicRowEh.CreateCellManager: TBaseGridCellManagerEh;
begin
  Result := TDataAxisGraphicCellManagerEh.Create(nil, Self);
end;

function TDataVertGridGraphicRowEh.GetDefCellManager: TDataAxisGraphicCellManagerEh;
begin
  Result := TDataAxisGraphicCellManagerEh(FDefCellManager);
end;

function TDataVertGridGraphicRowEh.CanEditShow: Boolean;
begin
  Result := False;
end;

procedure TDataVertGridGraphicRowEh.InitCell(ACell: TGridBaseCellEh; AStyleParams: TDataAxisCellStyleParamsEh);
begin
  inherited InitCell(ACell, AStyleParams);
end;

function TDataVertGridGraphicRowEh.GetImageList: TCustomImageList;
begin
  Result := DefCellManager.ImageList;
end;

procedure TDataVertGridGraphicRowEh.SetImageList(const Value: TCustomImageList);
begin
  if DefCellManager.ImageList <> Value then
  begin
    DefCellManager.ImageList := Value;
    Changed();
  end;
end;

{ TDataGridLayoutColumnEh }

function TDataVertGridLayoutRowEh.CreateCellManager: TBaseGridCellManagerEh;
begin
  Result := TDataAxisLayoutCellManagerEh.Create(nil, Self);
end;

function TDataVertGridLayoutRowEh.DefaultAllowShowEditor: Boolean;
begin
  Result := False;
end;

{ TDataVertGridDataCellStyleParamsEh }

function TDataVertGridDataCellStyleParamsEh.GetGrid: TDataVertGridEh;
begin
  Result := TDataVertGridEh(inherited Grid);
end;

function TDataVertGridDataCellStyleParamsEh.GetColumn: TDataVertGridColumnEh;
begin
  Result := TDataVertGridColumnEh(inherited DataAxisCellParams.ListItemBar);
end;

function TDataVertGridDataCellStyleParamsEh.GetRow: TDataVertGridRowEh;
begin
  Result := TDataVertGridRowEh(inherited DataAxisCellParams.FieldBar);
end;

{ TDataVertGridStringDataCellStyleParamsEh }

procedure TDataVertGridStringDataCellStyleParamsEh.Init(ADataAxisCellParams: TDataAxisCellStyleParamsEh);
begin
  inherited Init(ADataAxisCellParams);
end;

function TDataVertGridStringDataCellStyleParamsEh.GetTrimming: TTextTrimming;
begin
  if DataAxisCellParams is TDataAxisStringCellStyleParamsEh then
    Result := TDataAxisStringCellStyleParamsEh(DataAxisCellParams).Trimming
  else
    Result := TTextTrimming.None;
end;

procedure TDataVertGridStringDataCellStyleParamsEh.SetTrimming(const Value: TTextTrimming);
begin
  if DataAxisCellParams is TDataAxisStringCellStyleParamsEh then
    TDataAxisStringCellStyleParamsEh(DataAxisCellParams).Trimming := Value;
end;

function TDataVertGridStringDataCellStyleParamsEh.GetWordWrap: Boolean;
begin
  if DataAxisCellParams is TDataAxisStringCellStyleParamsEh then
    Result := TDataAxisStringCellStyleParamsEh(DataAxisCellParams).WordWrap
  else
    Result := False;
end;

procedure TDataVertGridStringDataCellStyleParamsEh.SetWordWrap(const Value: Boolean);
begin
  if DataAxisCellParams is TDataAxisStringCellStyleParamsEh then
    TDataAxisStringCellStyleParamsEh(DataAxisCellParams).WordWrap := Value;
end;

{ TDataVertGridCreateDataCellContentParamsEh }

procedure TDataVertGridCreateDataCellContentParamsEh.Init(AAxisCellParams: TDataAxisCreateCellContentParamsEh);
begin
  FAxisCellParams := AAxisCellParams;
end;

function TDataVertGridCreateDataCellContentParamsEh.GetCellContent: TLaObjectEh;
begin
  Result := FAxisCellParams.CellContent;
end;

procedure TDataVertGridCreateDataCellContentParamsEh.SetCellContent(const Value: TLaObjectEh);
begin
  FAxisCellParams.CellContent := Value;
end;

function TDataVertGridCreateDataCellContentParamsEh.DefaultCreateCellContent(AContentParent: TLaObjectEh): TLaObjectEh;
begin
  Result := FAxisCellParams.DefaultCreateCellContent(AContentParent);
end;

function TDataVertGridCreateDataCellContentParamsEh.GetCell: TGridBaseCellEh;
begin
  Result := FAxisCellParams.Cell;
end;

function TDataVertGridCreateDataCellContentParamsEh.GetContentParent: TLaObjectEh;
begin
  Result := FAxisCellParams.ContentParent;
end;

function TDataVertGridCreateDataCellContentParamsEh.GetGrid: TControl;
begin
  Result := FAxisCellParams.Grid;
end;

{ TDataVertGridRowEh }

procedure TDataVertGridRowEh.HandleCreateCellContent(Params: TBaseGridCreateCellContentParamsEh);
var
  GridParams: TDataVertGridCreateDataCellContentParamsEh;
begin
  if Assigned(OnCreateDataCellContent) then
  begin
    GridParams := TDataVertGridCreateDataCellContentParamsEh.Create;
    GridParams.Init(Params as TDataAxisCreateCellContentParamsEh);
    try
      OnCreateDataCellContent(Self, GridParams);
    finally
      GridParams.Free;
    end;
  end;
end;

procedure TDataVertGridRowEh.HandleDataCellGetDisplayText(Params: TDataAxisGridGetDisplayTextParamsEh);
begin
  if Assigned(OnDataCellGetDisplayText) then
    OnDataCellGetDisplayText(Self, TDataVertGridDataCellGetDisplayTextParamsEh(Params));
end;

function TDataVertGridRowEh.CreateGetBarValueEventParams: TDataAxisGridGetBarValueParamsEh;
begin
  Result := TDataVertGridDataCellGetValueParamsEh.Create();
end;

procedure TDataVertGridRowEh.HandleDataCellGetValue(Params: TDataAxisGridGetBarValueParamsEh);
begin
  if Assigned(OnDataCellGetValue) then
    OnDataCellGetValue(Self, TDataVertGridDataCellGetValueParamsEh(Params));
end;

procedure TDataVertGridRowEh.HandleDataCellSetValue(Params: TDataAxisGridSetBarValueParamsEh);
begin
  if Assigned(OnDataCellSetValue) then
    OnDataCellSetValue(Self, TDataVertGridDataCellSetValueParamsEh(Params));
end;

procedure TDataVertGridRowEh.HandleGetFieldBarStyleParams(Params: TDataAxisCellStyleParamsEh);
var
  GridParams: TDataVertGridDataCellStyleParamsEh;
begin
  if Assigned(OnDataCellGetStyleParams) then
  begin
    GridParams := TDataVertGridDataCellStyleParamsEh.Create;
    GridParams.Init(Params);
    try
      OnDataCellGetStyleParams(Self, GridParams);
    finally
      GridParams.Free;
    end;
  end;
end;

function TDataVertGridRowEh.CreateFieldBarStyleParams: TFieldBarDataCellStyleParamsEh;
begin
  Result := TDataVertGridDataCellStyleParamsEh.Create();
end;

function TDataVertGridRowEh.CreateGetDisplayTextParams: TDataAxisGridGetDisplayTextParamsEh;
begin
  Result := TDataVertGridDataCellGetDisplayTextParamsEh.Create();
end;

function TDataVertGridRowEh.CreateSetBarValueEventParams: TDataAxisGridSetBarValueParamsEh;
begin
  Result := TDataVertGridDataCellSetValueParamsEh.Create();
end;

procedure TDataVertGridRowEh.HandleDataCellInitContent(Params: TBaseGridInitCellContentParamsEh);
var
  GridParams: TDataVertGridInitDataCellContentParamsEh;
begin
  if Assigned(OnDataCellInitContent) and (Params is TDataAxisInitCellContentParamsEh) then
  begin
    GridParams := TDataVertGridInitDataCellContentParamsEh.Create;
    GridParams.Init(TDataAxisInitCellContentParamsEh(Params));
    try
      OnDataCellInitContent(Self, GridParams);
    finally
      GridParams.Free;
    end;
  end;
end;

procedure TDataVertGridRowEh.HandleDataCellMouseDownEvent(Params: TGridCellMouseButtonParamsEh);
var
  GridParams: TDataVertGridDataCellMouseButtonParamsEh;
begin
  if Assigned(OnDataCellMouseDown) then
  begin
    GridParams := TDataVertGridDataCellMouseButtonParamsEh.Create;
    GridParams.Init(Params as TDataAxisCellMouseButtonParamsEh);
    try
      OnDataCellMouseDown(Self, GridParams);
    finally
      GridParams.Free;
    end;
  end;
end;

function TDataVertGridRowEh.CreateGetCellManagerParams: TBaseDataVertGridGetDataCellManagerParamsEh;
begin
  Result := TDataVertGridGetDataCellManagerParamsEh.Create;
end;

procedure TDataVertGridRowEh.HandleGetDataCellManager(Params: TBaseDataVertGridGetDataCellManagerParamsEh);
begin
  inherited HandleGetDataCellManager(Params);
  if Assigned(OnGetDataCellManager) then
    OnGetDataCellManager(Self, TDataVertGridGetDataCellManagerParamsEh(Params));
end;

procedure TDataVertGridRowEh.HandleInitCellEditor(AParams: TBaseGridInitEditorParamsEh);
var
  GridParams: TDataVertGridInitEditorParamsEh;
begin
  if Assigned(OnDataCellInitEditor) then
  begin
    GridParams := TDataVertGridInitEditorParamsEh.Create;
    GridParams.Init(AParams);
    try
      OnDataCellInitEditor(Self, GridParams);
    finally
      GridParams.Free;
    end;
  end;
end;

{ TDataVertGridComboboxRowEh }

constructor TDataVertGridComboboxRowEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TDataVertGridComboboxRowEh.Destroy;
begin
  inherited Destroy;
end;

function TDataVertGridComboboxRowEh.GetDefCellManager: TDataAxisGridComboboxCellManagerEh;
begin
  Result := TDataAxisGridComboboxCellManagerEh(FDefCellManager);
end;

function TDataVertGridComboboxRowEh.GetIsLookupMode: Boolean;
begin
  Result := DefCellManager.IsLookupMode;
end;

function TDataVertGridComboboxRowEh.CreateCellManager: TBaseGridCellManagerEh;
begin
  FDropDownBox := TDataVertGridComboDropDownBoxEh.Create(Self);
  Result := TDataAxisGridComboboxCellManagerEh.Create(nil, Self, FDropDownBox);
end;

function TDataVertGridComboboxRowEh.CreateDropDownBox: TBaseDataAxisGridComboDropDownBoxEh;
begin
  Result := TDataVertGridComboDropDownBoxEh.Create(Self);
end;

function TDataVertGridComboboxRowEh.GetDropDownBox: TDataVertGridComboDropDownBoxEh;
begin
  Result := FDropDownBox;
end;

function TDataVertGridComboboxRowEh.GetListFieldName: String;
begin
  Result := DefCellManager.ListFieldName;
end;

procedure TDataVertGridComboboxRowEh.SetListFieldName(const Value: String);
begin
  if DefCellManager.ListFieldName <> Value then
  begin
    DefCellManager.ListFieldName := Value;
    Changed(True);
  end;
end;

function TDataVertGridComboboxRowEh.GetListKeyFieldName: String;
begin
  Result := DefCellManager.ListKeyFieldName;
end;

procedure TDataVertGridComboboxRowEh.SetListKeyFieldName(const Value: String);
begin
  if DefCellManager.ListKeyFieldName <> Value then
  begin
    DefCellManager.ListKeyFieldName := Value;
    Changed(True);
  end;
end;

function TDataVertGridComboboxRowEh.GetListSource: TComponent;
begin
  Result := DefCellManager.ListSource;
end;

procedure TDataVertGridComboboxRowEh.SetListSource(const Value: TComponent);
begin
  if DefCellManager.ListSource <> Value then
  begin
    DefCellManager.ListSource := Value;
    Changed(True);
  end;
end;

procedure TDataVertGridComboboxRowEh.BindField;
begin
  inherited BindField;
end;

function TDataVertGridComboboxRowEh.DefaultGetLookupDisplayText(const VarValue: TValue): String;
begin
  Result := DefCellManager.GetLookupDisplayText(VarValue);
end;

procedure TDataVertGridComboboxRowEh.DefaultSetValue(const Value: TValue);
var
  KeyValue: TValue;
begin
  if IsLookupMode then
  begin
    KeyValue := DefCellManager.LookupKeyValueForDisplayValue(Value);
    inherited DefaultSetValue(KeyValue);
  end else
  begin
    inherited DefaultSetValue(Value);
  end;
end;

{ TDataVertGridEventParamsEh }

constructor TDataVertGridEventParamsEh.Create;
begin
  inherited Create;
end;

procedure TDataVertGridEventParamsEh.Init(AGrid: TDataVertGridEh);
begin
  FGrid := AGrid;
end;

{ TDataVertGridDataCellGetDisplayTextParamsEh }

function TDataVertGridDataCellGetDisplayTextParamsEh.GetGrid: TDataVertGridEh;
begin
  Result := TDataVertGridEh(inherited Grid);
end;

function TDataVertGridDataCellGetDisplayTextParamsEh.GetRow: TDataVertGridBaseRowEh;
begin
  Result := TDataVertGridBaseRowEh(FieldBar);
end;

{ TDataVertGridComboDropDownBoxEh }

procedure TDataVertGridComboDropDownBoxEh.HandleDataCellGetStyleParams(Params: TDataAxisCellStyleParamsEh);
begin
end;

{ TDataVertGridDataCellGetValueParamsEh }

function TDataVertGridDataCellGetValueParamsEh.GetGrid: TDataVertGridEh;
begin
  Result := TDataVertGridEh(inherited Grid);
end;

function TDataVertGridDataCellGetValueParamsEh.GetRow: TDataVertGridRowEh;
begin
  Result := TDataVertGridRowEh(FieldBar);
end;

function TDataVertGridDataCellGetValueParamsEh.GetColumn: TDataVertGridColumnEh;
begin
  Result := TDataVertGridColumnEh(ListItemBar);
end;

{ TDataVertGridDataCellSetValueParamsEh }

function TDataVertGridDataCellSetValueParamsEh.GetGrid: TDataVertGridEh;
begin
  Result := TDataVertGridEh(inherited Grid);
end;

function TDataVertGridDataCellSetValueParamsEh.GetRow: TDataVertGridRowEh;
begin
  Result := TDataVertGridRowEh(FieldBar);
end;

function TDataVertGridDataCellSetValueParamsEh.GetColumn: TDataVertGridColumnEh;
begin
  Result := TDataVertGridColumnEh(ListItemBar);
end;

{ TDataVertGridDataCellKeyDownParamsEh }

function TDataVertGridDataCellKeyDownParamsEh.GetGrid: TDataVertGridEh;
begin
  Result := TDataVertGridEh(inherited Grid);
end;

procedure TDataVertGridDataCellKeyDownParamsEh.Reset(AGrid: TControl; ACellManager: TBaseGridCellManagerEh;
  AColIndex, ARowIndex, AAreaColIndex, AAreaRowIndex: Integer; AKey: Word; AKeyChar: WideChar;
  AShift: TShiftState);
var
  VGrid: TCustomDataVertGridEhCrack;
begin
  VGrid := TCustomDataVertGridEhCrack(AGrid);

  inherited Reset(AGrid, ACellManager, AColIndex, ARowIndex, AAreaColIndex, AAreaRowIndex, AKey, AKeyChar, AShift);

  if (AreaRowIndex >= 0) and (AreaRowIndex < VGrid.VisibleRows.Count) then
    FRow := VGrid.VisibleRows[AreaRowIndex]
  else
    FRow := nil;

  if (AreaColIndex >= 0) and (AreaColIndex < VGrid.VisibleColumns.Count) then
    FColumn := VGrid.VisibleColumns[AreaColIndex]
  else
    FColumn := nil;
end;

{ TDataVertGridDataCellMouseButtonParamsEh }

procedure TDataVertGridDataCellMouseButtonParamsEh.Init(
  AAxisCellParams: TDataAxisCellMouseButtonParamsEh);
begin
  FAxisCellParams := AAxisCellParams;
end;

function TDataVertGridDataCellMouseButtonParamsEh.GetGrid: TDataVertGridEh;
begin
  Result := TDataVertGridEh(FAxisCellParams.Grid);
end;

function TDataVertGridDataCellMouseButtonParamsEh.GetCell: TGridBaseCellEh;
begin
  Result := TGridBaseCellEh(FAxisCellParams.Cell);
end;

function TDataVertGridDataCellMouseButtonParamsEh.GetRow: TDataVertGridBaseRowEh;
begin
  Result := TDataVertGridBaseRowEh(FAxisCellParams.FieldBar);
end;

function TDataVertGridDataCellMouseButtonParamsEh.GetColumn: TDataVertGridColumnEh;
begin
  Result := TDataVertGridColumnEh(FAxisCellParams.ListItemBar);
end;

function TDataVertGridDataCellMouseButtonParamsEh.GetShift: TShiftState;
begin
  Result := FAxisCellParams.BaseParams.Shift;
end;

function TDataVertGridDataCellMouseButtonParamsEh.GetButton: TMouseButton;
begin
  Result := FAxisCellParams.BaseParams.Button;
end;

function TDataVertGridDataCellMouseButtonParamsEh.GetHandled: Boolean;
begin
  Result := FAxisCellParams.Handled;
end;

procedure TDataVertGridDataCellMouseButtonParamsEh.SetHandled(const Value: Boolean);
begin
  FAxisCellParams.Handled := Value;
end;

{ TDataVertGridInitDataCellContentParamsEh }

procedure TDataVertGridInitDataCellContentParamsEh.Init(AAxisCellParams: TDataAxisInitCellContentParamsEh);
begin
  FAxisCellParams := AAxisCellParams;
end;

function TDataVertGridInitDataCellContentParamsEh.GetCell: TGridBaseCellEh;
begin
  Result := FAxisCellParams.Cell;
end;

function TDataVertGridInitDataCellContentParamsEh.GetCellContent: TLaObjectEh;
begin
  Result := FAxisCellParams.CellContent;
end;

function TDataVertGridInitDataCellContentParamsEh.GetCellManager: TVPBaseCellManagerEh;
begin
  Result := FAxisCellParams.CellManager;
end;

function TDataVertGridInitDataCellContentParamsEh.GetRow: TDataVertGridBaseRowEh;
begin
  Result := TDataVertGridBaseRowEh(FAxisCellParams.FieldBar);
end;

function TDataVertGridInitDataCellContentParamsEh.GetGrid: TDataVertGridEh;
begin
  Result := TDataVertGridEh(FAxisCellParams.Grid);
end;

function TDataVertGridInitDataCellContentParamsEh.GetColumn: TDataVertGridColumnEh;
begin
  Result := TDataVertGridColumnEh(FAxisCellParams.ListItemBar);
end;

function TDataVertGridInitDataCellContentParamsEh.GetStyleParams: TDataAxisCellStyleParamsEh;
begin
  Result := FAxisCellParams.StyleParams;
end;

function TDataVertGridInitDataCellContentParamsEh.GetHandled: Boolean;
begin
  Result := FAxisCellParams.Handled;
end;

procedure TDataVertGridInitDataCellContentParamsEh.SetHandled(const Value: Boolean);
begin
  FAxisCellParams.Handled := Value;
end;

{ TDataVertGridGetDataCellManagerParamsEh }

function TDataVertGridGetDataCellManagerParamsEh.GetGrid: TDataVertGridEh;
begin
  Result := TDataVertGridEh(inherited Grid);
end;

{$REGION 'TDataVertGridInitEditorParamsEh'}

procedure TDataVertGridInitEditorParamsEh.Init(ABaseCellParams: TBaseGridInitEditorParamsEh);
begin
  FBaseCellParams := ABaseCellParams;
end;

function TDataVertGridInitEditorParamsEh.GetGrid: TDataVertGridEh;
begin
  Result := TDataVertGridEh(FBaseCellParams.Grid);
end;

function TDataVertGridInitEditorParamsEh.GetRow: TDataVertGridBaseRowEh;
begin
  Result := TDataVertGridBaseRowEh(TDataAxisCellEh((FBaseCellParams).Cell).FieldBar);
end;

function TDataVertGridInitEditorParamsEh.GetColumn: TDataVertGridColumnEh;
begin
  Result := TDataVertGridColumnEh(TDataAxisCellEh((FBaseCellParams).Cell).ListItemBar);
end;

function TDataVertGridInitEditorParamsEh.GetCell: TGridBaseCellEh;
begin
  Result := FBaseCellParams.Cell;
end;

function TDataVertGridInitEditorParamsEh.GetEditor: TLaObjectEh;
begin
  Result := FBaseCellParams.Editor;
end;

function TDataVertGridInitEditorParamsEh.GetEditorParams: TBaseGridCellEditParamsEh;
begin
  Result := FBaseCellParams.EditorParams;
end;

function TDataVertGridInitEditorParamsEh.GetHandled: Boolean;
begin
  Result := FBaseCellParams.Handled;
end;

procedure TDataVertGridInitEditorParamsEh.SetHandled(const Value: Boolean);
begin
  FBaseCellParams.Handled := Value;
end;

{$ENDREGION 'TDataVertGridInitEditorParamsEh'}

{$REGION 'TDataVertGridDataCellInTextLinkClickParamsEh'}

procedure TDataVertGridDataCellInTextLinkClickParamsEh.Init(ACellParams: TDataAxisCellInTextLinkClickParamsEh);
begin
  FCellParams := ACellParams;
end;

function TDataVertGridDataCellInTextLinkClickParamsEh.GetGrid: TDataVertGridEh;
begin
  Result := TDataVertGridEh(FCellParams.Grid);
end;

function TDataVertGridDataCellInTextLinkClickParamsEh.GetRow: TDataVertGridBaseRowEh;
begin
  Result := TDataVertGridBaseRowEh(FCellParams.FieldBar);
end;

function TDataVertGridDataCellInTextLinkClickParamsEh.GetColumn: TDataVertGridColumnEh;
begin
  Result := TDataVertGridColumnEh(FCellParams.ListItemBar);
end;

function TDataVertGridDataCellInTextLinkClickParamsEh.GetHandled: Boolean;
begin
  Result := FCellParams.Handled;
end;

procedure TDataVertGridDataCellInTextLinkClickParamsEh.SetHandled(const Value: Boolean);
begin
  FCellParams.Handled := Value;
end;

function TDataVertGridDataCellInTextLinkClickParamsEh.GetLinkText: String;
begin
  Result := FCellParams.SourceParams.LinkText;
end;

{$ENDREGION 'TDataVertGridDataCellInTextLinkClickParamsEh'}

end.
