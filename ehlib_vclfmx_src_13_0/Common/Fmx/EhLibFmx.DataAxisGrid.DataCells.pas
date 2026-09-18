{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{           EhLibFmx.CustomizeColumnsDialog             }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataAxisGrid.DataCells;

interface

{$SCOPEDENUMS ON}

{$REGION 'uses'}
uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, System.Types,
  System.Variants, Data.DB, TypInfo,
  System.Generics.Collections, Rtti,
  FMX.Graphics, System.UITypes, FMX.StdCtrls, FMX.TextLayout, FMX.ImgList,
  FMX.Objects,
  EhLib.GridTableViews,
  EhLibUtils, DBUtilsEh,
  EhLibFmx.ToolControls,
  EhLibFmx.ImageReses,

  EhLibFmx.Grids,
  EhLibFmx.Grid.Types,
  EhLibFmx.Grid.CellManagers,
  EhLibFmx.Grid.InplaceEditors,

  EhLibFmx.DataAxisGrid.FieldBars,

  EhLibFmx.Platform,
  EhLibFmx.Types,
  EhLibFmx.LaHostVirtualPanels,
  EhLibFmx.LaObjects,
  EhLibFmx.LaControls,
  EhLibFmx.LaGridPanels,
  EhLibFmx.LaPanels,
  EhLibFmx.Grid.ToolControls;
{$ENDREGION 'uses'}

type
  TDataAxisTextCellEh = class;
  TDataAxisCellEh = class;
  TDataAxisCheckboxCellEh = class;
  TDataAxisInitCellParamsEh = class;

{ TDataAxisCreateCellContentParamsEh }

  TDataAxisCreateCellContentParamsEh = class(TBaseGridCreateCellContentParamsEh)
  private
  public
  end;

{ TDataAxisCellMouseButtonParamsEh }

  TDataAxisCellMouseButtonParamsEh = class(TGridCellMouseButtonParamsEh)
  private
    FFieldBar: TFieldBarEh;
    FListItemBar: TTableRowViewEh;
  public
    procedure Init(AGrid: TControl; ACell: TGridBaseCellEh; Params: TControlMouseButtonParamsEh); override;

    property FieldBar: TFieldBarEh read FFieldBar;
    property ListItemBar: TTableRowViewEh read FListItemBar;
  end;

{ TDataAxisCellEditParamsEh }

  TDataAxisCellEditParamsEh = class(TBaseGridCellEditParamsEh)
  private
    FFieldBar: TFieldBarEh;
    FListItemBar: TTableRowViewEh;

  public
    procedure Init(AGrid: TControl; ACellManager: TBaseGridCellManagerEh; AColIndex: Integer; ARowIndex: Integer; AAreaColIndex: Integer; AAreaRowIndex: Integer); override;

    property FieldBar: TFieldBarEh read FFieldBar;
    property ListItemBar: TTableRowViewEh read FListItemBar;
  end;

{ TDataAxisCellInitEditorParamsEh }

  TDataAxisCellInitEditorParamsEh = class(TBaseGridInitEditorParamsEh)
  private
    function GetFieldBar: TFieldBarEh;
    function GetListItemBar: TTableRowViewEh;

  public
    property FieldBar: TFieldBarEh read GetFieldBar;
    property ListItemBar: TTableRowViewEh read GetListItemBar;
  end;

{ TDataAxisStringCellEditParamsEh }

  TDataAxisStringCellEditParamsEh = class(TDataAxisCellEditParamsEh)
  private
    FEditorWordWrap: Boolean;

  public
    property EditorWordWrap: Boolean read FEditorWordWrap write FEditorWordWrap;
  end;

{ TDataAxisInitCellParamsEh }

  TDataAxisInitCellParamsEh = class(TBaseGridInitCellParamsEh)
  private
    FFieldBar: TFieldBarEh;
    FListItemBar: TTableRowViewEh;
    FStyleParams: TDataAxisCellStyleParamsEh;

  public
    procedure Init(AGrid: TControl; ACellManager: TBaseGridCellManagerEh; ACell: TGridBaseCellEh); override;
    destructor Destroy; override;

    property FieldBar: TFieldBarEh read FFieldBar;
    property ListItemBar: TTableRowViewEh read FListItemBar;
    property StyleParams: TDataAxisCellStyleParamsEh read FStyleParams;
  end;

{ TDataAxisInitCellContentParamsEh }

  TDataAxisInitCellContentParamsEh = class(TBaseGridInitCellContentParamsEh)
  private
    function GetFieldBar: TFieldBarEh;
    function GetListItemBar: TTableRowViewEh;
    function GetInitDataCellParams: TDataAxisInitCellParamsEh;
    function GetStyleParams: TDataAxisCellStyleParamsEh;

  public
    procedure Init(ACell: TGridBaseCellEh; ACellContent: TLaObjectEh; InitCellParams: TBaseGridInitCellParamsEh); override;

    property FieldBar: TFieldBarEh read GetFieldBar;
    property ListItemBar: TTableRowViewEh read GetListItemBar;
    property InitDataCellParams: TDataAxisInitCellParamsEh read GetInitDataCellParams;
    property StyleParams: TDataAxisCellStyleParamsEh read GetStyleParams;
  end;

{ TDataAxisStringCellStyleParamsEh }

  TDataAxisStringCellStyleParamsEh = class(TDataAxisCellStyleParamsEh)
  private
    FTrimming: TTextTrimming;
    FWordWrap: Boolean;
    FFormattedRanges: TList<TLaFormattedTextRangeEh>;
    FHighlightHyperlinks: Boolean;
  public
    constructor Create();
    destructor Destroy; override;

    procedure Init(AGrid: TControl; AFieldBar: TFieldBarEh; AListItemBar: TTableRowViewEh; ADataRowIndex: Integer); override;

    property WordWrap: Boolean read FWordWrap write FWordWrap;
    property Trimming: TTextTrimming read FTrimming write FTrimming;
    property HighlightHyperlinks: Boolean read FHighlightHyperlinks write FHighlightHyperlinks;
    property FormattedRanges: TList<TLaFormattedTextRangeEh> read FFormattedRanges;
  end;

{ TDataAxisCellKeyDownParamsEh }

  TDataAxisCellKeyDownParamsEh = class(TBaseGridCellKeyDownParamsEh)
  private
    FFieldBar: TFieldBarEh;
    FListItemBar: TTableRowViewEh;

  protected
    procedure Reset(AGrid: TControl; ACellManager: TBaseGridCellManagerEh; AColIndex: Integer; ARowIndex: Integer; AAreaColIndex: Integer; AAreaRowIndex: Integer; AKey: Word; AKeyChar: WideChar; AShift: TShiftState); override;

  public

    property FieldBar: TFieldBarEh read FFieldBar;
    property ListItemBar: TTableRowViewEh read FListItemBar;
  end;

{ TDataAxisCellTreeViewAreaParamsEh }

  TDataAxisCellTreeViewAreaParamsEh = class(TPersistent)
  private
    FFieldBar: TFieldBarEh;
    FListItemBar: TTableRowViewEh;
    FLevel: Integer;
    FLevelWidth: Integer;
    FTreeAreaVisible: Boolean;
    FSignState: TTreeSignStateEh;
    FSignVisible: Boolean;
    FGrid: TControl;
    FHandled: Boolean;
  public
    procedure Init(AGrid: TControl; AFieldBar: TFieldBarEh; AListItemBar: TTableRowViewEh; ATreeAreaVisible: Boolean; ALevelWidth: Integer; ALevel: Integer; ASignState: TTreeSignStateEh; ASignVisible: Boolean); virtual;

    property Grid: TControl read FGrid;
    property FieldBar: TFieldBarEh read FFieldBar;
    property ListItemBar: TTableRowViewEh read FListItemBar;

    property TreeAreaVisible: Boolean read FTreeAreaVisible write FTreeAreaVisible;
    property LevelWidth: Integer read FLevelWidth write FLevelWidth;
    property Level: Integer read FLevel write FLevel;
    property SignState: TTreeSignStateEh read FSignState write FSignState;
    property SignVisible: Boolean read FSignVisible write FSignVisible;
    property Handled: Boolean read FHandled write FHandled;
  end;

{ TBaseDataGridSetDataTreeSignStateParamsEh }

  TDataAxisCellTreeSignStateParamsEh = class(TPersistent)
  private
    FFieldBar: TFieldBarEh;
    FListItemBar: TTableRowViewEh;
    FGrid: TControl;
    FSignState: TTreeSignStateEh;
    FShiftState: TShiftState;
    FHandled: Boolean;
  public
    procedure Init(AGrid: TControl; AFieldBar: TFieldBarEh; AListItemBar: TTableRowViewEh; ASignState: TTreeSignStateEh; AShiftState: TShiftState); virtual;

    property Grid: TControl read FGrid;
    property FieldBar: TFieldBarEh read FFieldBar;
    property ListItemBar: TTableRowViewEh read FListItemBar;

    property SignState: TTreeSignStateEh read FSignState;
    property ShiftState: TShiftState read FShiftState;
    property Handled: Boolean read FHandled write FHandled;
  end;

{ TDataAxisCellComposeContextMenuParamsEh }

  TDataAxisCellComposeContextMenuParamsEh = class(TBaseGridCellComposeContextMenuParamsEh)
  private
    FFieldBar: TFieldBarEh;
    FListItemBar: TTableRowViewEh;

  public
    procedure Init(AGrid: TControl; ACell: TGridBaseCellEh; AControlParams: TControlShowContextMenuParamsEh); override;
  public
    property FieldBar: TFieldBarEh read FFieldBar;
    property ListItemBar: TTableRowViewEh read FListItemBar;
  end;

{ TDataAxisCellStartEditParamsEh }

  TDataAxisCellStartEditParamsEh = class(TPersistent)
  private
    FEditingActive: Boolean;
    FHandled: Boolean;
    FCell: TDataAxisCellEh;
    FGrid: TControl;
    function GetFieldBar: TFieldBarEh;
    function GetListItemBar: TTableRowViewEh;

  public
    procedure Init(AGrid: TControl; ACell: TDataAxisCellEh); virtual;

    property Grid: TControl read FGrid;
    property Cell: TDataAxisCellEh read FCell;
    property FieldBar: TFieldBarEh read GetFieldBar;
    property ListItemBar: TTableRowViewEh read GetListItemBar;
    property EditingActive: Boolean read FEditingActive write FEditingActive;
    property Handled: Boolean  read FHandled write FHandled;
  end;

  TDataAxisCreateCellContentEventEh = procedure(Sender: TObject; Params: TDataAxisCreateCellContentParamsEh) of object;
  TDataAxisInitCellContentEventEh = procedure(Sender: TObject; Params: TDataAxisInitCellContentParamsEh) of object;

{ TDataAxisCellManagerEh }

  TDataAxisCellManagerEh = class(TBaseGridCellManagerEh)
  private
    FBoundFieldBar: TFieldBarEh;
    FOnCreateCellContent: TDataAxisCreateCellContentEventEh;
    FOnInitCellContent: TDataAxisInitCellContentEventEh;

    procedure ProcessCellStartEdit(Params: TDataAxisCellStartEditParamsEh);
  protected
    function CreateStyleParams(): TDataAxisCellStyleParamsEh; virtual;
    function CreateInitCellParams: TBaseGridInitCellParamsEh; override;
    function CreateInitCellContentParams: TBaseGridInitCellContentParamsEh; override;

    function CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh; override;
    function CreateCellContentParams(): TBaseGridCreateCellContentParamsEh; override;

    procedure ComposeContextMenu(ACellParams: TBaseGridCellComposeContextMenuParamsEh); override;
    procedure InitCellHolderPositionProps(ACellHolder: TVPBaseCellHolderEh); override;

    procedure CreateBoundColumnState(ABoundFieldBar: TFieldBarEh); virtual;
    procedure ProcessGetStyleParams(Params: TDataAxisCellStyleParamsEh); virtual;
    procedure InitStyleParams(Params: TDataAxisCellStyleParamsEh); virtual;
    procedure Changed(CellLayoutAffects: Boolean = False); virtual;
    procedure DefaultCellStartEdit(Params: TDataAxisCellStartEditParamsEh); virtual;

    procedure HandleCreateCustomCellContent(Params: TBaseGridCreateCellContentParamsEh); override;
    procedure HandleInitCellContent(Params: TBaseGridInitCellContentParamsEh); override;
    procedure HandleMouseDownEvent(Params: TGridCellMouseButtonParamsEh); override;
    procedure HandleMouseClickEvent(Params: TGridCellMouseButtonParamsEh); override;
    procedure HandleInitCellEditor(AParams: TBaseGridInitEditorParamsEh); override;
    procedure InitCellEditParams(AParams: TBaseGridCellEditParamsEh); override;

    procedure CellTreeSignMouseDown(Sender: TObject; Params: TControlMouseButtonParamsEh);
    procedure DefaultInitEditParams(AParams: TDataAxisCellEditParamsEh); virtual;
    procedure InitTreeViewArea(ACell: TDataAxisCellEh; TreeViewAreaParams: TDataAxisCellTreeViewAreaParamsEh); virtual;
    procedure ProcessGetTreeViewAreaParams(Params: TDataAxisCellTreeViewAreaParamsEh); virtual;
    procedure ProcessSetTreeSignState(Params: TDataAxisCellTreeSignStateParamsEh); virtual;
    procedure HandleKeyDownEvent(Params: TBaseGridCellKeyDownParamsEh); virtual;

  public
    constructor Create(AOwner: TComponent); overload; override;
    constructor Create(AOwner: TComponent; ABoundFieldBar: TFieldBarEh); reintroduce; overload;

    function CreateCellHolder(): TVPBaseCellHolderEh; override;
    function CreateCellKeyDownParams(AGrid: TControl; AColIndex, ARowIndex, AAreaColIndex, AAreaRowIndex: Integer): TBaseGridCellKeyDownParamsEh; override;
    function CreateComposeContextMenuParams(): TBaseGridCellComposeContextMenuParamsEh; override;
    function CreateMouseButtonParams(ACell: TGridBaseCellEh): TGridCellMouseButtonParamsEh; override;
    function GetCellContentTextValue(Params: TBaseGridInitCellContentParamsEh): String; override;
    function CreateInitEditorParams(): TBaseGridInitEditorParamsEh; override;
    function IsShowFocusLayer(AGrid: TControl; ACell: TGridBaseCellEh): Boolean; override;
    function IsShowSelectionLayer(AGrid: TControl; ACell: TGridBaseCellEh): Boolean; override;

    procedure InitCellSideBorder(ACellHolder: TGridBaseCellHolderEh; BorderType: TGridCellBorderTypeEh; IsDraw: Boolean; BorderColor: TAlphaColor; IsExtent: Boolean); override;

    procedure DefaultInitCellProps(Params: TBaseGridInitCellParamsEh); override;
    procedure InitCell(ACell: TGridBaseCellEh); override;
    procedure InitCellPositionProps(ACell: TGridBaseCellEh); override;
    procedure ProcessKeyDown(Params: TBaseGridCellKeyDownParamsEh); override;

    function GetStyleParams(ACell: TDataAxisCellEh): TDataAxisCellStyleParamsEh; virtual;
    function GetDataTreeViewAreaParams(ACell: TDataAxisCellEh): TDataAxisCellTreeViewAreaParamsEh; virtual;
    function GetDefaultDisplayText(const VarValue: TValue): String; virtual;
    function CellStartEdit(ACell: TDataAxisCellEh): Boolean; virtual;

    procedure DefaultGetTreeViewAreaParams(Params: TDataAxisCellTreeViewAreaParamsEh); virtual;
    procedure DefaultSetTreeSignState(Params: TDataAxisCellTreeSignStateParamsEh); virtual;
    procedure InitCellTreeViewArea(ACell: TDataAxisCellEh); virtual;

    procedure DefaultInitCellContent(Params: TBaseGridInitCellContentParamsEh); overload; override;
    procedure DefaultInitCellContent(Params: TDataAxisInitCellContentParamsEh); reintroduce; overload; virtual;

    property BoundFieldBar: TFieldBarEh read FBoundFieldBar;

    property OnCreateCellContent: TDataAxisCreateCellContentEventEh read FOnCreateCellContent write FOnCreateCellContent;
    property OnInitCellContent: TDataAxisInitCellContentEventEh read FOnInitCellContent write FOnInitCellContent;
  end;

{ TDataAxisCellHolderEh }

  TDataAxisCellHolderEh = class(TGridBaseCellHolderEh)
  private
    FFieldBar: TFieldBarEh;
    FListItemBar: TTableRowViewEh;

    FBottomLine: TLaControlEh;
    FTreeViewArea: TGridCellTreeViewAreaControlEh;
    FIsPriorRecordValueSame: Boolean;
    FIsNextRecordValueSame: Boolean;
//    FDataValue: TValue;
  protected
    procedure CreateControls(AParent: TLaObjectEh); override;
    procedure TreeSignMouseDown(Sender: TObject; Params: TControlMouseButtonParamsEh);

    property TreeViewArea: TGridCellTreeViewAreaControlEh read FTreeViewArea;

  public
    procedure InitPositionProps(); override;

    property FieldBar: TFieldBarEh read FFieldBar;
    property ListItemBar: TTableRowViewEh read FListItemBar;
    property IsPriorRecordValueSame: Boolean read FIsPriorRecordValueSame write FIsPriorRecordValueSame;
    property IsNextRecordValueSame: Boolean read FIsNextRecordValueSame write FIsNextRecordValueSame;
//    property DataValue: TValue read FDataValue;
  end;

{ TDataAxisCellEh }

  TDataAxisCellEh = class(TGridBaseCellEh)
  private
    FEditMode: Boolean;
    FMousePressedButton: TMouseButton;
    FReadOnly: Boolean;
    FCellContent: TLaObjectEh;
    FRightStackPanel: TLaStackPanelEh;

    procedure SetEditMode(const Value: Boolean);
    procedure SetReadOnly(const Value: Boolean);
    function GetTreeViewArea: TGridCellTreeViewAreaControlEh;
    function GetFieldBar: TFieldBarEh;
    function GetListItemBar: TTableRowViewEh;
  protected
    function CreateDefaultCellContentControls(AParentObject: TLaObjectEh): TLaObjectEh; override;
    function CreateCellClientControls(AParent: TLaObjectEh): TLaObjectEh; override;
    function CreateFocusLayerControls(AParent: TLaObjectEh): TLaControlEh; override;

    procedure CreateRightStackControls(AStackPanel: TLaStackPanelEh); virtual;

    function CanEditMode: Boolean; virtual;

    procedure ProcessMouseDown(Params: TControlMouseButtonParamsEh); override;
    procedure ProcessMouseMove(Params: TControlMouseParamsEh); override;

    procedure UpdateEditor; virtual;

  public
    constructor Create(ACellHolder: TGridBaseCellHolderEh);
    destructor Destroy; override;

    function StartEdit(): Boolean;

    property FieldBar: TFieldBarEh read GetFieldBar;
    property ListItemBar: TTableRowViewEh read GetListItemBar;

    property EditMode: Boolean read FEditMode write SetEditMode;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly;

//    property SelectionLayerActive: Boolean read FSelectionLayerActive write SetSelectionLayerActive;
//    property ShowSelectionLayer: Boolean read GetShowSelectionLayer write SetShowSelectionLayer;
    property TreeViewArea: TGridCellTreeViewAreaControlEh read GetTreeViewArea;
  end;

{ TDataAxisTextCellManagerEh }

  TDataAxisTextCellManagerEh = class(TDataAxisCellManagerEh)
  private
    FDisplayFormat: String;
    FDisplayFormatStored: Boolean;

    function DefaultDisplayFormat: String;
    function GetDisplayFormat: String;
    function IsDisplayFormatStored: Boolean;

    procedure SetDisplayFormat(const Value: String);
    procedure SetDisplayFormatStored(const Value: Boolean);

  protected
    function CreateStyleParams(): TDataAxisCellStyleParamsEh; override;
    function CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh; override;

    procedure InitCellEditParams(AParams: TBaseGridCellEditParamsEh); override;

    procedure InTextLinkClick(ACell: TGridBaseCellEh; Sender: TObject; Params: TInTextLinkClickParamsEh); virtual;
    procedure ProcessInTextLinkClick(Params: TDataAxisCellInTextLinkClickParamsEh); virtual;

  public
    function CreateCellEditParams(): TBaseGridCellEditParamsEh; override;
    function GetDefaultDisplayText(const Value: TValue): String; override;

    procedure DefaultInitCellEditor(AInitEditorParams: TBaseGridInitEditorParamsEh); override;
    procedure DefaultInitCellContent(Params: TBaseGridInitCellContentParamsEh); override;

    property DisplayFormat: String read GetDisplayFormat write SetDisplayFormat stored IsDisplayFormatStored;
    property DisplayFormatStored: Boolean read FDisplayFormatStored write SetDisplayFormatStored default False;
  end;

{ TDataAxisTextCellBlockEh }

  TDataAxisTextCellBlockEh = class(TLaTextBlockEh)
  protected
    function HasHint: Boolean; override;
    function GetHintString: string; override;
  end;

{ TDataAxisTextCellContentEh }

  TDataAxisTextCellContentEh = class(TLaLayoutPanelEh)
  private
    FEditBlock: TLaInplaceTextEdit;
    FText: String;
    FTextBlock: TLaTextBlockEh;
    FTextDataCell: TDataAxisTextCellEh;
    FTextEditArea: TLaLayoutPanelEh;
    FCustomFormattedRanges: TList<TLaFormattedTextRangeEh>;
    FHighlightHyperlinks: Boolean;

    function GetEditorText: String;
    function GetText: String;
    procedure SetEditorText(const Value: String);
    procedure SetHighlightText(const Value: String);
    procedure SetText(const Value: String);
    procedure UpdateTextBlockFormattedRanges();
    procedure SetHighlightHyperlinks(const Value: Boolean);

  protected
    function CreateLaInplaceTextEdit(AOwner: TComponent; AParentObject: TLaObjectEh): TLaInplaceTextEdit; virtual;
    procedure InTextLinkClick(Sender: TObject; Params: TInTextLinkClickParamsEh);

  public
    constructor Create(ATextDataCell: TDataAxisTextCellEh; AParentObject: TLaObjectEh);
    destructor Destroy; override;

    procedure CreateControls(AParentObject: TLaObjectEh);
    procedure UpdateEditor();
    procedure UpdateHighlightRegions();
    procedure SetFormattedRanges(AFormattedRanges: TList<TLaFormattedTextRangeEh>);

    property EditorText: String read GetEditorText write SetEditorText;
    property HighlightText: String read FText write SetHighlightText;
    property HighlightHyperlinks: Boolean read FHighlightHyperlinks write SetHighlightHyperlinks;
    property Text: String read GetText write SetText;
    property TextBlock: TLaTextBlockEh read FTextBlock;
    property TextDataCell: TDataAxisTextCellEh read FTextDataCell;
  end;

{ TDataAxisTextCellEh }

  TDataAxisTextCellEh = class(TDataAxisCellEh)
  private
    FTextCellContent: TDataAxisTextCellContentEh;

    function GetText: String;
    function GetTextBlock: TLaTextBlockEh;
    procedure SetText(const Value: String);
    function GetEditorText: String;

  protected
    function CanEditMode: Boolean; override;
    function CreateDefaultCellContentControls(AParentObject: TLaObjectEh): TLaObjectEh; override;
    function GetHintString: string; override;
    function HasHint: Boolean; override;

    procedure ShowFocusLayerChanged; override;
    procedure UpdateEditor(); override;
    procedure InTextLinkClick(Sender: TObject; Params: TInTextLinkClickParamsEh);

  public
    constructor Create(ACellHolder: TGridBaseCellHolderEh);
    destructor Destroy; override;

    function GetInplaceEditClass: TInplaceEditClass; virtual;
    function CanMouseDownShowEditor(CellHitCoord: TGridCoord; ACell: TGridBaseCellEh; MouseParams: TControlMouseButtonParamsEh): Boolean; override;

    property EditorText: String read GetEditorText;
    property Text: String read GetText write SetText;
    property TextBlock: TLaTextBlockEh read GetTextBlock;
    property TextCellContent: TDataAxisTextCellContentEh read FTextCellContent;
  end;

{ TDataAxisCheckboxCellManagerEh }

  TDataAxisCheckboxCellManagerEh = class(TDataAxisCellManagerEh)
  private
    FCheckedValue: TValue;
    FUncheckedValue: TValue;

//    class function CreateBitmap(ParentControl: TFmxObject; const IsChecked: Boolean): TBitmap; static;

    function GetCheckedValue: TValue;
    function GetIsChecked(AFieldBar: TFieldBarEh; AListItemBar: TTableRowViewEh): Boolean;
    function GetUncheckedValue: TValue;
    procedure SetCheckedValue(const Value: TValue);
    procedure SetUncheckedValue(const Value: TValue);

  protected
//    class var FCheckboxBitmaps: array [Boolean] of TBitmap;
//    class procedure UpdateCheckboxBitmaps(ParentControl: TFmxObject);

  protected
    function CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh; override;

    procedure ToggleCellValue(AGrid: TControl; AFieldBar: TFieldBarEh; AListItemBar: TTableRowViewEh); virtual;
  public
    constructor Create(AOwner: TComponent); override;

    function CanShowEditor(AGrid: TControl): Boolean; override;
    function CreateCellKeyDownParams(AGrid: TControl; AColIndex, ARowIndex, AAreaColIndex, AAreaRowIndex: Integer): TBaseGridCellKeyDownParamsEh; override;

    procedure DefaultInitCellContent(Params: TBaseGridInitCellContentParamsEh); override;
    procedure ProcessKeyDown(Params: TBaseGridCellKeyDownParamsEh); override;

    property CheckedValue: TValue read GetCheckedValue write SetCheckedValue;
    property IsChecked[AFieldBar: TFieldBarEh; AListItemBar: TTableRowViewEh]: Boolean read GetIsChecked;
    property UncheckedValue: TValue read GetUncheckedValue write SetUncheckedValue;
  end;

{ TDataAxisCheckboxCellEh }

  TDataAxisCheckboxCellEh = class(TDataAxisCellEh)
  private
    FMousePressed: Boolean;
    FCheckBox: TSimpleCheckBoxEh;

    procedure SetIsChecked(const Value: Boolean);
    function GetIsChecked: Boolean;

  protected
    function CreateDefaultCellContentControls(AParentObject: TLaObjectEh): TLaObjectEh; override;

    procedure MouseClick(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure ProcessMouseDown(Params: TControlMouseButtonParamsEh); override;

  public
    constructor Create(ACellHolder: TGridBaseCellHolderEh);
    destructor Destroy; override;

    procedure Toggle;

    property IsChecked: Boolean read GetIsChecked write SetIsChecked;
  end;

{ TDataAxisGraphicCellManagerEh }

  TDataAxisGraphicCellManagerEh = class(TDataAxisCellManagerEh)
  private
    FImageList: TCustomImageList;
    procedure SetImageList(const Value: TCustomImageList);

  protected
    function CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh; override;

  public
    procedure DefaultInitCellContent(Params: TBaseGridInitCellContentParamsEh); override;

  published
    property ImageList: TCustomImageList read FImageList write SetImageList;
  end;

{ TDataAxisGraphicCellEh }

  TDataAxisGraphicCellEh = class(TDataAxisCellEh)
  private
    FImageControl: TLaImageEh;
  protected
    function CanEditMode: Boolean; override;
    function CreateDefaultCellContentControls(AParentObject: TLaObjectEh): TLaObjectEh; override;

  public
    constructor Create(ACellHolder: TGridBaseCellHolderEh);
    destructor Destroy; override;

    property ImageControl: TLaImageEh read FImageControl;
  end;

{ TDataAxisLayoutCellManagerEh }

  TDataAxisLayoutCellManagerEh = class(TDataAxisCellManagerEh)
  private
  protected
    function CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh; override;

  public
    procedure InitCell(ACell: TGridBaseCellEh); override;

  end;

{ TDataAxisLayoutCellEh }

  TDataAxisLayoutCellEh = class(TDataAxisCellEh)
  private
  protected
    function CanEditMode: Boolean; override;

  public
    constructor Create(ACellHolder: TGridBaseCellHolderEh);
    destructor Destroy; override;
  end;

implementation

uses EhLibFmx.DataAxisGrids;

type
  TCustomDataAxisGridEhCrack = class(TCustomDataAxisGridEh);
  TFieldBarEhCrack = class(TFieldBarEh);
  TVPBaseCellHolderEhCrack = class(TVPBaseCellHolderEh);

{$REGION 'TDataAxisCellManagerEh'}

{ TDataAxisCellManagerEh }

constructor TDataAxisCellManagerEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

constructor TDataAxisCellManagerEh.Create(AOwner: TComponent; ABoundFieldBar: TFieldBarEh);
begin
  FBoundFieldBar := ABoundFieldBar;
  Create(AOwner);
end;

procedure TDataAxisCellManagerEh.Changed(CellLayoutAffects: Boolean);
begin
end;

procedure TDataAxisCellManagerEh.CreateBoundColumnState(ABoundFieldBar: TFieldBarEh);
begin

end;

function TDataAxisCellManagerEh.CreateCellHolder: TVPBaseCellHolderEh;
begin
  Result := TDataAxisCellHolderEh.Create(nil, Self);
end;

procedure TDataAxisCellManagerEh.InitCellSideBorder(
  ACellHolder: TGridBaseCellHolderEh; BorderType: TGridCellBorderTypeEh;
  IsDraw: Boolean; BorderColor: TAlphaColor; IsExtent: Boolean);

  function GetTreeViewAreaParamsForRowIndex(AGridColIndex, AGridRowIndex: Integer): TDataAxisCellTreeViewAreaParamsEh;
  var
    VGrid: TCustomDataAxisGridEhCrack;
    AFieldBar: TFieldBarEh;
    AListItemBar: TTableRowViewEh;
  begin
    Result := nil;
    VGrid := TCustomDataAxisGridEhCrack(ACellHolder.Grid);
    VGrid.GetFieldBarListItemBarAtPos(AGridColIndex, AGridRowIndex, AFieldBar, AListItemBar);
    if (AFieldBar <> nil) and (AListItemBar <> nil) then
    begin
      Result := VGrid.GetAxisDataTreeViewAreaParams(AFieldBar, AListItemBar);
      if Result.Handled = False then
        ProcessGetTreeViewAreaParams(Result);
    end;
  end;

var
  AxisCellHolder: TDataAxisCellHolderEh;
  TreeViewAreaParams: TDataAxisCellTreeViewAreaParamsEh;
  TreeViewAreaParamsNextRow: TDataAxisCellTreeViewAreaParamsEh;
  TreeViewWidth: Single;
  LineMarginsLeft: Single;
  TreeDrawLevel: Integer;
begin
  TreeViewAreaParamsNextRow := nil;
  AxisCellHolder := TDataAxisCellHolderEh(ACellHolder);
  if BorderType = TGridCellBorderTypeEh.Bottom then
  begin
    if (AxisCellHolder.FieldBar <> nil) and
       (AxisCellHolder.FieldBar.MergeDuplicates = True) and
       (AxisCellHolder.IsNextRecordValueSame = True)
    then
      IsDraw := False;

    AxisCellHolder.FBottomLine.Fill.Kind := TBrushKind.Solid;
    AxisCellHolder.FBottomLine.Fill.Color := BorderColor;
    if IsDraw
      then AxisCellHolder.FBottomLine.Height := 1
      else AxisCellHolder.FBottomLine.Height := 0;

    LineMarginsLeft := 0;
    TreeViewAreaParams := GetDataTreeViewAreaParams(TDataAxisCellEh(ACellHolder.CellClient));
    if TreeViewAreaParams = nil then Exit;
    try
      if TreeViewAreaParams.Handled = False then
        ProcessGetTreeViewAreaParams(TreeViewAreaParams);
      TreeDrawLevel := TreeViewAreaParams.Level;

      TreeViewAreaParamsNextRow := GetTreeViewAreaParamsForRowIndex(ACellHolder.ColIndex, ACellHolder.RowIndex + 1);
      if TreeViewAreaParamsNextRow <> nil then
      begin
        if (TreeViewAreaParamsNextRow.TreeAreaVisible = True) and
           (TreeViewAreaParamsNextRow.Level < TreeDrawLevel)
        then
          TreeDrawLevel := TreeViewAreaParamsNextRow.Level;
      end;

      if TreeViewAreaParams.TreeAreaVisible then
      begin
        TreeViewWidth := (TreeDrawLevel + 1) * TreeViewAreaParams.LevelWidth;
        LineMarginsLeft := TreeViewWidth;
      end;
    finally
      TreeViewAreaParams.Free;
      TreeViewAreaParamsNextRow.Free;
    end;

    AxisCellHolder.FBottomLine.Margins.Left := LineMarginsLeft;
  end else
    inherited InitCellSideBorder(ACellHolder, BorderType, IsDraw, BorderColor, IsExtent);
end;

function TDataAxisCellManagerEh.CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh;
begin
  Result := TDataAxisCellEh.Create(ACellHolder);
end;

function TDataAxisCellManagerEh.CreateInitCellParams: TBaseGridInitCellParamsEh;
begin
  Result := TDataAxisInitCellParamsEh.Create;
end;

procedure TDataAxisCellManagerEh.DefaultInitCellProps(Params: TBaseGridInitCellParamsEh);
var
  DataParams: TDataAxisInitCellParamsEh;
begin
  inherited DefaultInitCellProps(Params);
  DataParams := TDataAxisInitCellParamsEh(Params);
  if DataParams.FieldBar <> nil then
    DataParams.FieldBar.InitCell(Params.Cell, DataParams.StyleParams);
end;

procedure TDataAxisCellManagerEh.InitCell(ACell: TGridBaseCellEh);
var
  DataCell: TDataAxisCellEh;
  VGrid: TCustomDataAxisGridEhCrack;
  AEditMode: Boolean;
begin
  VGrid := TCustomDataAxisGridEhCrack(ACell.Grid);
  if ACell is TDataAxisCellEh then
  begin
    DataCell := (ACell as TDataAxisCellEh);
    AEditMode := False;
    if DataCell.CellHolder.CellIsInGridCellPos then
    begin
      if (DataCell.FieldBar <> nil) and (DataCell.ListItemBar <> nil) then
      begin
        if (VGrid.CurColIndex = ACell.ColIndex) and (VGrid.CurRowIndex = ACell.RowIndex) then
          AEditMode := VGrid.EditorMode;
      end;
    end;
    DataCell.EditMode := AEditMode;
  end;

  inherited InitCell(ACell);

  if ACell is TDataAxisCellEh then
    InitCellTreeViewArea(TDataAxisCellEh(ACell));
end;

procedure TDataAxisCellManagerEh.InitCellPositionProps(ACell: TGridBaseCellEh);
begin
  inherited InitCellPositionProps(ACell);
end;

procedure TDataAxisCellManagerEh.InitCellHolderPositionProps(ACellHolder: TVPBaseCellHolderEh);
var
  VGrid: TCustomDataAxisGridEhCrack;
  AFieldBar: TFieldBarEh;
  AListItemBar: TTableRowViewEh;
  ADataCellHolder: TDataAxisCellHolderEh;
  PriorListItemBar, NextListItemBar: TTableRowViewEh;
  DataValue, PriorDataValue, NextDataValue: TValue;
begin
  inherited InitCellHolderPositionProps(ACellHolder);
  VGrid := TCustomDataAxisGridEhCrack(ACellHolder.Grid);
  ADataCellHolder := ACellHolder as TDataAxisCellHolderEh;

  VGrid.GetFieldBarListItemBarAtPos(ACellHolder.ColIndex, ACellHolder.RowIndex, AFieldBar, AListItemBar);
  ADataCellHolder.FFieldBar := AFieldBar;
  ADataCellHolder.FListItemBar := AListItemBar;
  ADataCellHolder.FIsPriorRecordValueSame := False;
  ADataCellHolder.FIsNextRecordValueSame := False;

  if (AFieldBar <> nil) and (AListItemBar <> nil) then
  begin
    if (AListItemBar.SourceRowLink <> nil)
      then ADataCellHolder.DataContext := AListItemBar.SourceRowLink as IDataContextEh
      else ADataCellHolder.DataContext := nil;
    //ADataCellHolder.FDataValue := AFieldBar.GetListItemValue(AListItemBar);

    if AFieldBar.IsCalcNextPriorRecordValue then
    begin
      if VGrid.GetListItemDirection = TGridListItemDirectionEh.Vertical then
      begin
        DataValue := AFieldBar.GetListItemValue(AListItemBar);
        if ACellHolder.RowIndex > VGrid.VertAxis.RollStartVisCel + VGrid.VertAxis.FixedCelCount then
        begin
          VGrid.GetFieldBarListItemBarAtPos(ACellHolder.ColIndex, ACellHolder.RowIndex - 1, AFieldBar, PriorListItemBar);
          PriorDataValue := AFieldBar.GetListItemValue(PriorListItemBar);
          ADataCellHolder.FIsPriorRecordValueSame := SameValue(DataValue, PriorDataValue);
        end;
        if ACellHolder.RowIndex < VGrid.VertAxis.RollLastVisCel + VGrid.VertAxis.FixedCelCount then
        begin
          VGrid.GetFieldBarListItemBarAtPos(ACellHolder.ColIndex, ACellHolder.RowIndex + 1, AFieldBar, NextListItemBar);
          NextDataValue := AFieldBar.GetListItemValue(NextListItemBar);
          ADataCellHolder.FIsNextRecordValueSame := SameValue(DataValue, NextDataValue);
        end;
      end else
      begin
        VGrid.GetFieldBarListItemBarAtPos(ACellHolder.ColIndex - 1, ACellHolder.RowIndex, AFieldBar, AListItemBar);
      end;
    end;
  end
  else
  begin
    ADataCellHolder.DataContext := nil;
    //ADataCellHolder.FDataValue := TValue.Empty;
  end;
end;

function TDataAxisCellManagerEh.GetCellContentTextValue(Params: TBaseGridInitCellContentParamsEh): String;
begin
  Result := '';
end;

function TDataAxisCellManagerEh.CreateStyleParams(): TDataAxisCellStyleParamsEh;
begin
  Result := TDataAxisCellStyleParamsEh.Create;
end;

function TDataAxisCellManagerEh.GetStyleParams(ACell: TDataAxisCellEh): TDataAxisCellStyleParamsEh;
begin
  Result := CreateStyleParams();
  Result.Init(ACell.Grid, ACell.FieldBar,  ACell.ListItemBar, ACell.AreaRowIndex);
  ProcessGetStyleParams(Result);
end;

procedure TDataAxisCellManagerEh.ProcessGetStyleParams(Params: TDataAxisCellStyleParamsEh);
begin
  if Params.FieldBar <> nil then
    Params.FieldBar.InitStyleParams(Params);
  InitStyleParams(Params);
  if Params.FieldBar <> nil then
    TFieldBarEhCrack(Params.FieldBar).ProcessGetFieldBarStyleParams(Params);
end;

procedure TDataAxisCellManagerEh.InitStyleParams(Params: TDataAxisCellStyleParamsEh);
begin

end;

function TDataAxisCellManagerEh.CreateCellContentParams: TBaseGridCreateCellContentParamsEh;
begin
  Result := TDataAxisCreateCellContentParamsEh.Create;
end;

procedure TDataAxisCellManagerEh.HandleCreateCustomCellContent(Params: TBaseGridCreateCellContentParamsEh);
var
  DataParams: TDataAxisCreateCellContentParamsEh;
begin
  DataParams := TDataAxisCreateCellContentParamsEh(Params);
  if Assigned(OnCreateCellContent) then
    OnCreateCellContent(Self, DataParams);
  if (Params.CellContent = nil) and
     (BoundFieldBar <> nil)
  then
    TFieldBarEhCrack(BoundFieldBar).HandleCreateCellContent(DataParams);
end;

function TDataAxisCellManagerEh.CreateInitCellContentParams: TBaseGridInitCellContentParamsEh;
begin
  Result := TDataAxisInitCellContentParamsEh.Create;
end;

procedure TDataAxisCellManagerEh.HandleInitCellContent(Params: TBaseGridInitCellContentParamsEh);
var
  DataParams: TDataAxisInitCellContentParamsEh;
begin
  DataParams := TDataAxisInitCellContentParamsEh(Params);
  if Assigned(OnInitCellContent) then
    OnInitCellContent(Self, DataParams);
  if (DataParams.Handled = False) and (BoundFieldBar <> nil) then
    TFieldBarEhCrack(BoundFieldBar).HandleDataCellInitContent(DataParams);
end;

function TDataAxisCellManagerEh.IsShowFocusLayer(AGrid: TControl; ACell: TGridBaseCellEh): Boolean;
var
  DataCell: TDataAxisCellEh;
begin
  DataCell := (ACell as TDataAxisCellEh);
  if DataCell.EditMode = True then
    Result := False
  else
    Result := inherited IsShowFocusLayer(AGrid, ACell);
end;

function TDataAxisCellManagerEh.CreateComposeContextMenuParams: TBaseGridCellComposeContextMenuParamsEh;
begin
  Result := TDataAxisCellComposeContextMenuParamsEh.Create;
end;

procedure TDataAxisCellManagerEh.ComposeContextMenu(ACellParams: TBaseGridCellComposeContextMenuParamsEh);
var
  VGrid: TCustomDataAxisGridEhCrack;
begin
  VGrid := TCustomDataAxisGridEhCrack(ACellParams.Grid);
  VGrid.ComposeDataCellMenu(ACellParams as TDataAxisCellComposeContextMenuParamsEh);
end;

function TDataAxisCellManagerEh.CreateMouseButtonParams(ACell: TGridBaseCellEh): TGridCellMouseButtonParamsEh;
begin
  Result := TDataAxisCellMouseButtonParamsEh.Create;
end;

procedure TDataAxisCellManagerEh.HandleMouseDownEvent(Params: TGridCellMouseButtonParamsEh);
var
  AGrid: TCustomDataAxisGridEhCrack;
  DataCellParams: TDataAxisCellMouseButtonParamsEh;
begin
  inherited HandleMouseDownEvent(Params);

  DataCellParams := TDataAxisCellMouseButtonParamsEh(Params);
  AGrid := TCustomDataAxisGridEhCrack(Params.Grid);
  AGrid.HandleDataCellMouseDownEvent(DataCellParams);

  if (Assigned(DataCellParams.FieldBar)) then
    TFieldBarEhCrack(DataCellParams.FieldBar).HandleDataCellMouseDownEvent(DataCellParams);
end;

procedure TDataAxisCellManagerEh.HandleMouseClickEvent(Params: TGridCellMouseButtonParamsEh);
var
  AGrid: TCustomDataAxisGridEhCrack;
  DataCellParams: TDataAxisCellMouseButtonParamsEh;
begin
  inherited HandleMouseClickEvent(Params);

  DataCellParams := TDataAxisCellMouseButtonParamsEh(Params);
  AGrid := TCustomDataAxisGridEhCrack(Params.Grid);
  AGrid.HandleDataCellMouseClickEvent(DataCellParams);

  if (Assigned(DataCellParams.FieldBar)) then
    TFieldBarEhCrack(DataCellParams.FieldBar).HandleDataCellMouseClickEvent(DataCellParams);
end;

procedure TDataAxisCellManagerEh.InitCellEditParams(AParams: TBaseGridCellEditParamsEh);
var
  DataParams: TDataAxisCellEditParamsEh;
  AGrid: TCustomDataAxisGridEhCrack;
begin
  inherited InitCellEditParams(AParams);

  DataParams := AParams as TDataAxisCellEditParamsEh;
  DataParams.FieldBar.DefaultInitEditParams(DataParams);
  DefaultInitEditParams(DataParams);

  AGrid := TCustomDataAxisGridEhCrack(DataParams.Grid);
  AGrid.HandleDataCellInitEditParams(DataParams);
  TFieldBarEhCrack(DataParams.FieldBar).HandleDataCellInitEditParams(DataParams);
end;

procedure TDataAxisCellManagerEh.DefaultInitEditParams(AParams: TDataAxisCellEditParamsEh);
begin

end;

function TDataAxisCellManagerEh.CreateInitEditorParams: TBaseGridInitEditorParamsEh;
begin
  Result := TDataAxisCellInitEditorParamsEh.Create;
end;

procedure TDataAxisCellManagerEh.HandleInitCellEditor(AParams: TBaseGridInitEditorParamsEh);
var
  DataParams: TDataAxisCellInitEditorParamsEh;
begin
  inherited HandleInitCellEditor(AParams);
  DataParams := TDataAxisCellInitEditorParamsEh(AParams);
  if DataParams.FieldBar <> nil then
    TFieldBarEhCrack(DataParams.FieldBar).HandleInitCellEditor(AParams);
end;

function TDataAxisCellManagerEh.GetDefaultDisplayText(const VarValue: TValue): String;
var
  LowIdx: Integer;
  VarItem: TValue;
  VarItemTypeStr: String;
begin
  try
    if ValueIsArrayOfValues(VarValue) then
    begin
      LowIdx := VarValue.GetArrayLength;
      VarItem := VarValue.GetArrayElement(LowIdx);
      VarItemTypeStr := String(VarItem.TypeInfo.Name);
      Result := '[Array of ' + VarItemTypeStr + ']';
    end else
    begin
      Result := ValueToString(VarValue);
    end;
  except
    on EVariantTypeCastError do
      Result := 'VarToStr: EVariantTypeCastError';
    else
      raise;
  end;
end;

{$REGION ' KeyDown'}
function TDataAxisCellManagerEh.CreateCellKeyDownParams(AGrid: TControl; AColIndex, ARowIndex,
  AAreaColIndex, AAreaRowIndex: Integer): TBaseGridCellKeyDownParamsEh;
begin
  Result := TDataAxisCellKeyDownParamsEh.Create;
end;

procedure TDataAxisCellManagerEh.ProcessKeyDown(Params: TBaseGridCellKeyDownParamsEh);
begin
  inherited ProcessKeyDown(Params);
  HandleKeyDownEvent(Params);
end;

procedure TDataAxisCellManagerEh.HandleKeyDownEvent(Params: TBaseGridCellKeyDownParamsEh);
var
  AGrid: TCustomDataAxisGridEhCrack;
begin
  AGrid := TCustomDataAxisGridEhCrack(Params.Grid);
  AGrid.HandleDataCellKeyDownEvent(Params);

  if (Params is TDataAxisCellKeyDownParamsEh) then
  begin
    if (TDataAxisCellKeyDownParamsEh(Params).FieldBar <> nil) then
      TFieldBarEhCrack(TDataAxisCellKeyDownParamsEh(Params).FieldBar).HandleDataCellKeyDownEvent(Params);
  end;
end;

{$ENDREGION KeyDown}

function TDataAxisCellManagerEh.GetDataTreeViewAreaParams(ACell: TDataAxisCellEh): TDataAxisCellTreeViewAreaParamsEh;
var
  VGrid: TCustomDataAxisGridEhCrack;
begin
  VGrid := TCustomDataAxisGridEhCrack(ACell.Grid);
  Result := VGrid.GetAxisDataTreeViewAreaParams(ACell.FieldBar, ACell.ListItemBar);
end;

procedure TDataAxisCellManagerEh.InitCellTreeViewArea(ACell: TDataAxisCellEh);
var
  TreeViewAreaParams: TDataAxisCellTreeViewAreaParamsEh;
begin
  TreeViewAreaParams := GetDataTreeViewAreaParams(ACell);
  if TreeViewAreaParams = nil then Exit;
  try
    if TreeViewAreaParams.Handled = False then
      ProcessGetTreeViewAreaParams(TreeViewAreaParams);
    InitTreeViewArea(ACell, TreeViewAreaParams);
  finally
    TreeViewAreaParams.Free;
  end;
end;

procedure TDataAxisCellManagerEh.ProcessGetTreeViewAreaParams(Params: TDataAxisCellTreeViewAreaParamsEh);
var
  VGrid: TCustomDataAxisGridEhCrack;
begin
  VGrid := TCustomDataAxisGridEhCrack(Params.Grid);
  VGrid.ProcessGetDataTreeViewAreaParams(Params);

  if Params.Handled = False then
    DefaultGetTreeViewAreaParams(Params);
end;

procedure TDataAxisCellManagerEh.DefaultGetTreeViewAreaParams(Params: TDataAxisCellTreeViewAreaParamsEh);
begin

end;

procedure TDataAxisCellManagerEh.InitTreeViewArea(ACell: TDataAxisCellEh; TreeViewAreaParams: TDataAxisCellTreeViewAreaParamsEh);
var
  VGrid: TCustomDataAxisGridEhCrack;
  IsBorderDraw: Boolean;
  BorderColor: TAlphaColor;
  IsBorderExtent: Boolean;
begin
  if TreeViewAreaParams.TreeAreaVisible then
  begin
    ACell.TreeViewArea.Visible := True;
    ACell.TreeViewArea.CheckCreateControls;
    ACell.TreeViewArea.LevelWidth := TreeViewAreaParams.LevelWidth;
    ACell.TreeViewArea.Level := TreeViewAreaParams.Level;
    ACell.TreeViewArea.SignState := TreeViewAreaParams.SignState;
    ACell.TreeViewArea.SignVisible := TreeViewAreaParams.SignVisible;

    VGrid := TCustomDataAxisGridEhCrack(ACell.Grid);

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
  end else
  begin
    ACell.TreeViewArea.Visible := False;
  end;
end;

procedure TDataAxisCellManagerEh.CellTreeSignMouseDown(Sender: TObject; Params: TControlMouseButtonParamsEh);
var
  TreeSignStateSetParams: TDataAxisCellTreeSignStateParamsEh;
  ACell: TDataAxisCellEh;
  TreeSignState: TTreeSignStateEh;
  TreeViewAreaParams: TDataAxisCellTreeViewAreaParamsEh;
begin
  ACell := TDataAxisCellEh((Sender as TDataAxisCellHolderEh).CellClient);

  TreeViewAreaParams := TCustomDataAxisGridEhCrack(ACell.Grid).GetAxisDataTreeViewAreaParams(ACell.FieldBar, ACell.ListItemBar);
  try
    if TreeViewAreaParams.TreeAreaVisible then
    begin
      TreeSignState := TreeViewAreaParams.SignState;
      if TreeSignState = TTreeSignStateEh.Expanded
        then TreeSignState := TTreeSignStateEh.Collapsed
        else TreeSignState := TTreeSignStateEh.Expanded;

      TreeSignStateSetParams := TDataAxisCellTreeSignStateParamsEh.Create;
      TreeSignStateSetParams.Init(ACell.Grid, ACell.FieldBar, ACell.ListItemBar, TreeSignState, Params.Shift);
      try
        ProcessSetTreeSignState(TreeSignStateSetParams);
      finally
        TreeSignStateSetParams.Free;
      end;
    end;
  finally
    TreeViewAreaParams.Free;
  end;
end;

procedure TDataAxisCellManagerEh.ProcessSetTreeSignState(Params: TDataAxisCellTreeSignStateParamsEh);
var
  VGrid: TCustomDataAxisGridEhCrack;
begin
  VGrid := TCustomDataAxisGridEhCrack(Params.Grid);
  VGrid.ProcessSetDataTreeSignState(Params);

  DefaultSetTreeSignState(Params);
end;

procedure TDataAxisCellManagerEh.DefaultSetTreeSignState(Params: TDataAxisCellTreeSignStateParamsEh);
begin

end;

function TDataAxisCellManagerEh.CellStartEdit(ACell: TDataAxisCellEh): Boolean;
var
  StartEditParams: TDataAxisCellStartEditParamsEh;
begin
  StartEditParams := TDataAxisCellStartEditParamsEh.Create;
  StartEditParams.Init(ACell.Grid, ACell);
  ProcessCellStartEdit(StartEditParams);
  Result := StartEditParams.EditingActive;
  StartEditParams.Free;
end;

procedure TDataAxisCellManagerEh.ProcessCellStartEdit(Params: TDataAxisCellStartEditParamsEh);
var
  VGrid: TCustomDataAxisGridEhCrack;
begin
  VGrid := TCustomDataAxisGridEhCrack(Params.Grid);
  VGrid.HandleDataCellStartEdit(Params);
  if Params.Handled = False then
    TFieldBarEhCrack(Params.FieldBar).HandleDataCellStartEdit(Params);
  if Params.Handled = False then
    DefaultCellStartEdit(Params);
end;

procedure TDataAxisCellManagerEh.DefaultCellStartEdit(Params: TDataAxisCellStartEditParamsEh);
var
  VGrid: TCustomDataAxisGridEhCrack;
begin
  VGrid := TCustomDataAxisGridEhCrack(Params.Grid);
  Params.EditingActive := VGrid.TableView.EditCurrentRow();
end;

procedure TDataAxisCellManagerEh.DefaultInitCellContent(Params: TBaseGridInitCellContentParamsEh);
begin
  if Params is TDataAxisInitCellContentParamsEh then
  begin
    DefaultInitCellContent(TDataAxisInitCellContentParamsEh(Params));
  end;
end;

procedure TDataAxisCellManagerEh.DefaultInitCellContent(Params: TDataAxisInitCellContentParamsEh);
begin
  inherited DefaultInitCellContent(Params);
end;

function TDataAxisCellManagerEh.IsShowSelectionLayer(AGrid: TControl; ACell: TGridBaseCellEh): Boolean;
var
  DataCell: TDataAxisCellEh;
begin
  DataCell := (ACell as TDataAxisCellEh);
  if DataCell.FieldBar <> nil then
    Result := TFieldBarEhCrack(DataCell.FieldBar).IsShowSelectionLayer(DataCell)
  else
    Result := False;
end;

{$ENDREGION 'TDataAxisCellManagerEh'}

{$REGION 'TDataAxisCellEh'}

{ TDataAxisCellEh }

constructor TDataAxisCellEh.Create(ACellHolder: TGridBaseCellHolderEh);
begin
  inherited Create(ACellHolder);
  HitTest := True;
end;

destructor TDataAxisCellEh.Destroy;
begin
  inherited Destroy;
end;

function TDataAxisCellEh.CreateDefaultCellContentControls(AParentObject: TLaObjectEh): TLaObjectEh;
begin
  Result := inherited CreateDefaultCellContentControls(AParentObject);
end;

function TDataAxisCellEh.CreateFocusLayerControls(AParent: TLaObjectEh): TLaControlEh;
begin
  Result := inherited CreateFocusLayerControls(AParent);
end;

function TDataAxisCellEh.CreateCellClientControls(AParent: TLaObjectEh): TLaObjectEh;
begin
  with TLaGridPanelEh.CreateWith(AParent, AParent) do
  begin
    Result := RefSelf;

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Weight;
      Value := 1;
    end;

    with ColumnCollection.Add do
    begin
      SizeStyle := TLaGridPanelSizeStyleEh.Auto;
      Value := 0;
    end;

    FCellContent := CreateCellContent(RefSelf);
    if FCellContent <> nil then
    begin
      if CellContent.Name = '' then
        CellContent.Name := 'CellContent';
      ControlCollection.AddControl(FCellContent, 0, -1);
    end;

    with TLaStackPanelEh.CreateWith(RefSelf, RefSelf) do
    begin
      FRightStackPanel := TLaStackPanelEh(RefSelf);
      Name := 'RightStackPanel';
      ControlCollection.AddControl(FRightStackPanel, 1, -1);

      CreateRightStackControls(FRightStackPanel);
    end;
  end;
end;

procedure TDataAxisCellEh.CreateRightStackControls(AStackPanel: TLaStackPanelEh);
begin
end;

procedure TDataAxisCellEh.ProcessMouseDown(Params: TControlMouseButtonParamsEh);
begin
  FMousePressedButton := Params.Button;
  inherited ProcessMouseDown(Params);
end;

procedure TDataAxisCellEh.ProcessMouseMove(Params: TControlMouseParamsEh);
begin
  inherited ProcessMouseMove(Params);
end;

function TDataAxisCellEh.CanEditMode: Boolean;
begin
  Result := False;
end;

procedure TDataAxisCellEh.SetEditMode(const Value: Boolean);
begin
  if FEditMode <> Value then
  begin
    FEditMode := Value;
    UpdateEditor;
  end;
end;

procedure TDataAxisCellEh.SetReadOnly(const Value: Boolean);
begin
  FReadOnly := Value;
end;

procedure TDataAxisCellEh.UpdateEditor;
begin
end;

function TDataAxisCellEh.GetTreeViewArea: TGridCellTreeViewAreaControlEh;
begin
  Result := TDataAxisCellHolderEh(CellHolder).FTreeViewArea;
end;

function TDataAxisCellEh.StartEdit: Boolean;
begin
  Result := TDataAxisCellManagerEh(CellManager).CellStartEdit(Self);
end;

function TDataAxisCellEh.GetFieldBar: TFieldBarEh;
begin
  Result := TDataAxisCellHolderEh(CellHolder).FieldBar;
end;

function TDataAxisCellEh.GetListItemBar: TTableRowViewEh;
begin
  Result := TDataAxisCellHolderEh(CellHolder).ListItemBar;
end;

{$ENDREGION 'TDataAxisCellEh'}

{$REGION 'TDataAxisTextCellManagerEh'}

{ TDataAxisTextCellManagerEh }

function TDataAxisTextCellManagerEh.CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh;
begin
  Result := TDataAxisTextCellEh.Create(ACellHolder);
end;

function TDataAxisTextCellManagerEh.CreateStyleParams: TDataAxisCellStyleParamsEh;
begin
  Result := TDataAxisStringCellStyleParamsEh.Create;
end;

function TDataAxisTextCellManagerEh.CreateCellEditParams(): TBaseGridCellEditParamsEh;
begin
  Result := TDataAxisStringCellEditParamsEh.Create();
end;

procedure TDataAxisTextCellManagerEh.DefaultInitCellContent(Params: TBaseGridInitCellContentParamsEh);
const
  LaVertAlignments: array [TTextAlign] of TLaVertAlignmentEh = (TLaVertAlignmentEh.Center, TLaVertAlignmentEh.Top, TLaVertAlignmentEh.Bottom);
var
  TextDataCell: TDataAxisTextCellEh;
  Grid: TCustomDataAxisGridEhCrack;
  DataParams: TDataAxisInitCellContentParamsEh;
  CellHighlightingText: String;
  StyleParams: TDataAxisStringCellStyleParamsEh;
begin
  inherited DefaultInitCellContent(Params);

  DataParams := (Params as TDataAxisInitCellContentParamsEh);
  TextDataCell := (Params.Cell as TDataAxisTextCellEh);
  Grid := TCustomDataAxisGridEhCrack(Params.Grid);

  if (DataParams.ListItemBar <> nil) and (DataParams.FieldBar <> nil) then
  begin
    TextDataCell.Text := DataParams.FieldBar.GetListItemDisplayText(DataParams.ListItemBar);
  end else
    TextDataCell.Text := '';

  if (TextDataCell.TextBlock <> nil) and
     (DataParams.StyleParams <> nil)
  then
  begin
    TextDataCell.TextBlock.TextAlign := DataParams.StyleParams.HorzAlign;
    TextDataCell.TextBlock.VertAlignment := LaVertAlignments[DataParams.StyleParams.VertAlign];
  end;

  CellHighlightingText := Grid.GetDataCellHighlightingText;
  if CellHighlightingText <> ''
    then TextDataCell.TextCellContent.HighlightText := CellHighlightingText
    else TextDataCell.TextCellContent.HighlightText := '';

  StyleParams := DataParams.StyleParams as TDataAxisStringCellStyleParamsEh;
  TextDataCell.TextCellContent.SetFormattedRanges(StyleParams.FormattedRanges);
end;

procedure TDataAxisTextCellManagerEh.InitCellEditParams(AParams: TBaseGridCellEditParamsEh);
begin
  inherited InitCellEditParams(AParams);
end;

{$REGION 'DisplayFormat'}

function TDataAxisTextCellManagerEh.GetDisplayFormat: String;
begin
  if IsDisplayFormatStored then
    Result := FDisplayFormat
  else
    Result := DefaultDisplayFormat();
end;

procedure TDataAxisTextCellManagerEh.SetDisplayFormat(const Value: String);
begin
  if (FDisplayFormatStored = False) or (FDisplayFormat <> Value) then
  begin
    FDisplayFormat := Value;
    FDisplayFormatStored := True;
    Changed;
  end;
end;

function TDataAxisTextCellManagerEh.DefaultDisplayFormat: String;
begin
  if (BoundFieldBar <> nil) and (BoundFieldBar.Field <> nil) then
    Result := BoundFieldBar.Field.DisplayFormat
  else
    Result := '';
end;

procedure TDataAxisTextCellManagerEh.SetDisplayFormatStored(const Value: Boolean);
begin
  if FDisplayFormatStored <> Value then
  begin
    FDisplayFormatStored := Value;
    if FDisplayFormatStored = False then
      FDisplayFormat := DefaultDisplayFormat;
    Changed;
  end;
end;

function TDataAxisTextCellManagerEh.IsDisplayFormatStored: Boolean;
begin
  Result := FDisplayFormatStored;
end;

{$ENDREGION 'DisplayFormat'}

procedure TDataAxisTextCellManagerEh.DefaultInitCellEditor(AInitEditorParams: TBaseGridInitEditorParamsEh);
var
  LaTextEdit: TLaInplaceTextEdit;
begin
  inherited DefaultInitCellEditor(AInitEditorParams);
  if AInitEditorParams.Editor is TLaInplaceTextEdit then
  begin
    LaTextEdit := TLaInplaceTextEdit(AInitEditorParams.Editor);
    LaTextEdit.TextSettings.WordWrap := TDataAxisStringCellEditParamsEh(AInitEditorParams.EditorParams).EditorWordWrap;
  end;
end;

function TDataAxisTextCellManagerEh.GetDefaultDisplayText(const Value: TValue): String;
var
  LowIdx: Integer;
  VarItem: TValue;
  VarItemTypeStr: String;
begin
  try
    if ValueIsArrayOfValues(Value) then
    begin
      LowIdx := Value.GetArrayLength;
      VarItem := Value.GetArrayElement(LowIdx);
      VarItemTypeStr := String(VarItem.TypeInfo.Name);
      Result := '[Array of ' + VarItemTypeStr + ']';
    end else
    begin
      if DisplayFormat <> '' then
        Result := FormatValue(DisplayFormat, Value)
      else
        Result := ValueToString(Value);
    end;
  except
    on EVariantTypeCastError do
      Result := 'VarToStr: EVariantTypeCastError';
    else
      raise;
  end;
end;

procedure TDataAxisTextCellManagerEh.InTextLinkClick(ACell: TGridBaseCellEh; Sender: TObject;
  Params: TInTextLinkClickParamsEh);
var
  CellParams: TDataAxisCellInTextLinkClickParamsEh;
begin
  CellParams := TDataAxisCellInTextLinkClickParamsEh.Create;
  CellParams.Init(ACell.Grid, ACell, Params);
  ProcessInTextLinkClick(CellParams);
  CellParams.Free;
end;

procedure TDataAxisTextCellManagerEh.ProcessInTextLinkClick(Params: TDataAxisCellInTextLinkClickParamsEh);
var
  AGrid: TCustomDataAxisGridEhCrack;
begin
  AGrid := TCustomDataAxisGridEhCrack(Params.Grid);
  AGrid.HandleDataCellInTextLinkClick(Params);

  if (Assigned(Params.FieldBar)) then
    TFieldBarEhCrack(Params.FieldBar).HandleDataCellInTextLinkClick(Params);
end;

{$ENDREGION 'TDataAxisTextCellManagerEh'}

{$REGION 'TDataAxisTextCellBlockEh'}

{ TDataAxisTextCellBlockEh }

function TDataAxisTextCellBlockEh.HasHint: Boolean;
begin
  Result := inherited HasHint;
end;

function TDataAxisTextCellBlockEh.GetHintString: string;
begin
  Result := inherited GetHintString;
end;

{$ENDREGION}

{$REGION 'TDataAxisTextCellContentEh'}

constructor TDataAxisTextCellContentEh.Create(ATextDataCell: TDataAxisTextCellEh; AParentObject: TLaObjectEh);
begin
  inherited Create(ATextDataCell);
  FTextDataCell := ATextDataCell;
  Parent := AParentObject;
  FCustomFormattedRanges := TList<TLaFormattedTextRangeEh>.Create;
  CreateControls(Self);
end;

destructor TDataAxisTextCellContentEh.Destroy;
begin
  FreeAndNil(FCustomFormattedRanges);
  inherited Destroy;
end;

procedure TDataAxisTextCellContentEh.CreateControls(AParentObject: TLaObjectEh);
begin
  with TLaLayoutPanelEh.CreateWith(Self, AParentObject) do
  begin
    FTextEditArea := TLaLayoutPanelEh(RefSelf);

    FTextBlock := TDataAxisTextCellBlockEh.CreateWith(Self, RefSelf);
    FTextBlock.Margins.Rect := RectF(2, 2, 2, 2);
    FTextBlock.VertAlignment := TLaVertAlignmentEh.Center;
    FTextBlock.HorzAlignment := TLaHorzAlignmentEh.Stretch;
    FTextBlock.Text := '1';
    FTextBlock.OnInTextLinkClick := InTextLinkClick;
  end;
end;

procedure TDataAxisTextCellContentEh.InTextLinkClick(Sender: TObject; Params: TInTextLinkClickParamsEh);
begin
  FTextDataCell.InTextLinkClick(Sender, Params);
end;

function TDataAxisTextCellContentEh.GetText: String;
begin
  Result := FTextBlock.Text;
end;

procedure TDataAxisTextCellContentEh.SetText(const Value: String);
begin
  if (TextBlock <> nil) and (TextBlock.Text <> Value) then
  begin
    TextBlock.Text := Value;
    UpdateHighlightRegions();
    UpdateTextBlockFormattedRanges();
  end;
end;

function TDataAxisTextCellContentEh.GetEditorText: String;
begin
  if (FEditBlock <> nil) and (FEditBlock.Visible = True) then
    Result := FEditBlock.Text;
end;

procedure TDataAxisTextCellContentEh.SetEditorText(const Value: String);
begin
  if (FEditBlock <> nil) and (FEditBlock.Visible = True) then
  begin
    FEditBlock.Text := Value;
    FEditBlock.SelectAll();
  end;
end;

procedure TDataAxisTextCellContentEh.SetFormattedRanges(AFormattedRanges: TList<TLaFormattedTextRangeEh>);
var
  RangeChanged: Boolean;
  I: Integer;
begin
  RangeChanged := False;
  if AFormattedRanges.Count <> FCustomFormattedRanges.Count then
    RangeChanged := True
  else
  begin
    for I := 0 to AFormattedRanges.Count - 1 do
    begin
      RangeChanged := AFormattedRanges[I].Equals(FCustomFormattedRanges[I]) = False;
      if RangeChanged = True then
        Break;
    end;
  end;


  if RangeChanged = True then
  begin
    FCustomFormattedRanges.Clear;
    FCustomFormattedRanges.AddRange(AFormattedRanges);
    AFormattedRanges.Clear;
    UpdateTextBlockFormattedRanges();
  end;
end;

procedure TDataAxisTextCellContentEh.UpdateTextBlockFormattedRanges();
var
  UrlRanges: TArray<TTextRange>;
  Range: TTextRange;
  FormattedRange: TLaFormattedTextRangeEh;
  I: Integer;
begin
  TextBlock.FormattedTextRanges.Clear;

  if HighlightHyperlinks = True then
  begin
    UrlRanges := TLaTextBlockEh.GetURLDetectedRanges(Text);
    for Range in UrlRanges do
    begin
      FormattedRange := TLaFormattedTextRangeEh.Create;
      FormattedRange.TextPos := Range.Pos;
      FormattedRange.TextLength := Range.Length;
      FormattedRange.IsHyperLink := True;
      TextBlock.FormattedTextRanges.Add(FormattedRange);
    end;
  end;

  for I := 0 to FCustomFormattedRanges.Count - 1 do
    TextBlock.FormattedTextRanges.Add(FCustomFormattedRanges[I]);
  FCustomFormattedRanges.Clear;
end;

procedure TDataAxisTextCellContentEh.UpdateHighlightRegions;
var
  Tl: Integer;
  StartPoses: TIntegerDynArray;
  I: Integer;
  HiTextReg: THighlightTextRegion;
  HiColor: TAlphaColor;
begin
  if TextBlock = nil then Exit;

  TextBlock.HighlightRegions.Clear;

  if TextDataCell.ShowFocusLayer
    then HiColor := TAlphaColorRec.Orange
    else HiColor := TAlphaColorRec.Yellow;

  if HighlightText <> '' then
  begin
    GetAllStrEntry(Text, HighlightText, StartPoses, True, False, False);
    Tl := Length(HighlightText);

    for I := 0 to Length(StartPoses) - 1 do
    begin
      HiTextReg.Range.Pos := StartPoses[I];
      HiTextReg.Range.Length := Tl;
      HiTextReg.Color := HiColor;

      TextBlock.HighlightRegions.Add(HiTextReg);
    end;
  end;
end;

procedure TDataAxisTextCellContentEh.SetHighlightHyperlinks(const Value: Boolean);
begin
  if FHighlightHyperlinks <> Value then
  begin
    FHighlightHyperlinks := Value;
    UpdateTextBlockFormattedRanges();
  end;
end;

procedure TDataAxisTextCellContentEh.SetHighlightText(const Value: String);
begin
  if FText <> Value then
  begin
    FText := Value;
    UpdateHighlightRegions();
  end;
end;

function TDataAxisTextCellContentEh.CreateLaInplaceTextEdit(AOwner: TComponent; AParentObject: TLaObjectEh): TLaInplaceTextEdit;
var
  InplaceEditClass: TInplaceEditClass;
begin
  InplaceEditClass := TextDataCell.GetInplaceEditClass;
  Result := TDBAxisGridLaInplaceTextEdit.CreateWith(AOwner, AParentObject, InplaceEditClass);
end;

procedure TDataAxisTextCellContentEh.UpdateEditor;
var
  EditBlockHadFocus: Boolean;
  CellEditParams: TBaseGridCellEditParamsEh;
  InitEditorParams: TBaseGridInitEditorParamsEh;
begin
  if FEditBlock <> nil then
    EditBlockHadFocus := FEditBlock.ContainsFocus
  else
    EditBlockHadFocus := False;

  if TextDataCell.EditMode = True then
  begin
    FTextBlock.Visible := False;

    if FEditBlock = nil then
    begin
      FEditBlock := CreateLaInplaceTextEdit(FTextEditArea, FTextEditArea);
    end;

    TCustomDataAxisGridEhCrack(TextDataCell.Grid).SetCellEditor(FEditBlock);
    CellEditParams := TextDataCell.CellManager.GetCellEditParams(TextDataCell.Grid, TextDataCell);
    InitEditorParams := TextDataCell.CellManager.GetInitEditorParams(TextDataCell.Grid, TextDataCell, FEditBlock, CellEditParams);
//    TextDataCell.CellManager.InitEditor(InitEditorParams);
    try
      TextDataCell.CellManager.InitCellEditor(InitEditorParams);
      FEditBlock.UpdateContents;
    finally
      CellEditParams.Free;
      InitEditorParams.Free;
    end;

    FEditBlock.Visible := True;
    FEditBlock.SelectAll;
    FEditBlock.SetFocus;
  end else
  begin
    TCustomDataAxisGridEhCrack(TextDataCell.Grid).SetCellEditor(nil);
    FEditBlock.Visible := False;
    FEditBlock.Free;
    FEditBlock := nil;

    FTextBlock.Visible := True;
    if EditBlockHadFocus then
      TextDataCell.Grid.SetFocus;
  end;
end;

{$ENDREGION 'TDataAxisTextCellContentEh'}

{$REGION 'TDataAxisTextCellEh'}

{ TDataAxisTextCellEh }

constructor TDataAxisTextCellEh.Create(ACellHolder: TGridBaseCellHolderEh);
begin
  inherited Create(ACellHolder);
end;

destructor TDataAxisTextCellEh.Destroy;
begin
  inherited Destroy;
end;

function TDataAxisTextCellEh.CanMouseDownShowEditor(CellHitCoord: TGridCoord; ACell: TGridBaseCellEh;
  MouseParams: TControlMouseButtonParamsEh): Boolean;
begin
  Result := inherited CanMouseDownShowEditor(CellHitCoord, ACell, MouseParams);
end;

function TDataAxisTextCellEh.CreateDefaultCellContentControls(AParentObject: TLaObjectEh): TLaObjectEh;
begin
  FTextCellContent := TDataAxisTextCellContentEh.Create(Self, AParentObject);
  Result := FTextCellContent;
end;

function TDataAxisTextCellEh.GetText: String;
begin
  Result := TextBlock.Text;
end;

procedure TDataAxisTextCellEh.SetText(const Value: String);
begin
  TextCellContent.Text := Value;
end;

function TDataAxisTextCellEh.GetTextBlock: TLaTextBlockEh;
begin
  Result := TextCellContent.TextBlock;
end;

function TDataAxisTextCellEh.GetEditorText: String;
begin
  Result := TextCellContent.EditorText;
end;

procedure TDataAxisTextCellEh.ShowFocusLayerChanged;
begin
  inherited ShowFocusLayerChanged;
  TextCellContent.UpdateHighlightRegions();
end;

function TDataAxisTextCellEh.CanEditMode: Boolean;
begin
  Result := True;
end;

procedure TDataAxisTextCellEh.UpdateEditor();
begin
  TextCellContent.UpdateEditor();
end;

function TDataAxisTextCellEh.HasHint: Boolean;
begin
  Result := inherited HasHint;
  if (Result = False) and (FieldBar <> nil) and (FieldBar.Tooltips = True) then
  begin
    if TextBlock.NeededSize.Width > TextBlock.ActualWidth then
      Result := True;
  end;
end;

function TDataAxisTextCellEh.GetHintString: string;
begin
  Result := inherited GetHintString;
  if Result = '' then
  begin
    Result := TextBlock.Text;
  end;
end;

function TDataAxisTextCellEh.GetInplaceEditClass: TInplaceEditClass;
begin
  Result := TDBAxisGridInplaceEdit;
end;

procedure TDataAxisTextCellEh.InTextLinkClick(Sender: TObject; Params: TInTextLinkClickParamsEh);
begin
  TDataAxisTextCellManagerEh(CellManager).InTextLinkClick(Self, Sender, Params);
end;

{$ENDREGION 'TDataAxisTextCellEh'}

{$REGION 'TDataGridCheckboxDataCellManagerEh'}

{ TDataGridCheckboxDataCellManagerEh }

procedure TDataGridCheckboxDataCellManagerEhDestroy;
begin
end;

function TDataAxisCheckboxCellManagerEh.CanShowEditor(AGrid: TControl): Boolean;
begin
  Result := False;
end;

constructor TDataAxisCheckboxCellManagerEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCheckedValue := True;
  FUncheckedValue := False;
end;

function TDataAxisCheckboxCellManagerEh.CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh;
begin
  Result := TDataAxisCheckboxCellEh.Create(ACellHolder);
end;

function TDataAxisCheckboxCellManagerEh.GetIsChecked(AFieldBar: TFieldBarEh; AListItemBar: TTableRowViewEh): Boolean;
var
  VarResult: TValue;
  BoolResult: Variant;
begin
  VarResult := AFieldBar.GetListItemValue(AListItemBar);
  if ValueIsNullOrEmpty(VarResult) then
  begin
    Result := False;
  end
  else if VarResult.IsType<Variant>() = True then
  begin
    VarCast(BoolResult, VarResult.AsVariant, varBoolean);
    Result := BoolResult;
  end else if VarResult.IsType<Boolean>() = True then
  begin
    Result := VarResult.AsBoolean;
  end else
  begin
    Result := False;
  end;
end;

function TDataAxisCheckboxCellManagerEh.GetCheckedValue: TValue;
begin
  Result := FCheckedValue;
end;

procedure TDataAxisCheckboxCellManagerEh.SetCheckedValue(const Value: TValue);
begin
  if (FCheckedValue.TypeInfo <> Value.TypeInfo) or
     (SameValue(Value, FCheckedValue) = False) then
  begin
    FCheckedValue := Value;
    Changed();
  end;
end;

function TDataAxisCheckboxCellManagerEh.GetUncheckedValue: TValue;
begin
  Result := FUncheckedValue;
end;

procedure TDataAxisCheckboxCellManagerEh.ProcessKeyDown(Params: TBaseGridCellKeyDownParamsEh);
var
  DataParams: TDataAxisCellKeyDownParamsEh;
begin
  inherited ProcessKeyDown(Params);
  if Params is TDataAxisCellKeyDownParamsEh then
  begin
    DataParams := TDataAxisCellKeyDownParamsEh(Params);
    if (Params.KeyChar = ' ') then
    begin
      if DataParams.FieldBar.CanModifyCellValue(DataParams.ListItemBar) then
        ToggleCellValue(Params.Grid, DataParams.FieldBar, DataParams.ListItemBar);
    end;
  end;
end;

procedure TDataAxisCheckboxCellManagerEh.SetUncheckedValue(const Value: TValue);
begin
  if (FUncheckedValue.TypeInfo <> Value.TypeInfo) or
     (SameValue(Value, FUncheckedValue) = False) then
  begin
    FUncheckedValue := Value;
    Changed();
  end;
end;

procedure TDataAxisCheckboxCellManagerEh.DefaultInitCellContent(Params: TBaseGridInitCellContentParamsEh);
var
  CheckDataCell: TDataAxisCheckboxCellEh;
begin
  inherited DefaultInitCellContent(Params);

  CheckDataCell := TDataAxisCheckboxCellEh(Params.Cell);
  if CheckDataCell.ListItemBar <> nil then
    CheckDataCell.IsChecked := IsChecked[CheckDataCell.FieldBar, CheckDataCell.ListItemBar]
  else
    CheckDataCell.IsChecked := False;
end;

function TDataAxisCheckboxCellManagerEh.CreateCellKeyDownParams(AGrid: TControl; AColIndex,
  ARowIndex, AAreaColIndex, AAreaRowIndex: Integer): TBaseGridCellKeyDownParamsEh;
begin
  Result := inherited CreateCellKeyDownParams(AGrid, AColIndex, ARowIndex, AAreaColIndex, AAreaRowIndex);
end;

procedure TDataAxisCheckboxCellManagerEh.ToggleCellValue(AGrid: TControl; AFieldBar: TFieldBarEh; AListItemBar: TTableRowViewEh);
var
  Grid: TCustomDataAxisGridEhCrack;
  CurValue: TValue;
begin
  Grid := TCustomDataAxisGridEhCrack(AGrid);
  if (AListItemBar = Grid.CurrentListItemBar) then
  begin
    Grid.TableView.EditCurrentRow;
    CurValue := AFieldBar.GetListItemValue(AListItemBar);
    if SameValue(CurValue, CheckedValue)
      then AFieldBar.SetCurrentListItemValue(UncheckedValue)
      else AFieldBar.SetCurrentListItemValue(CheckedValue);
  end;
end;

{$ENDREGION}

{$REGION 'TDataGridCheckboxDataCellEh'}

{ TDataGridCheckboxDataCellEh }

constructor TDataAxisCheckboxCellEh.Create(ACellHolder: TGridBaseCellHolderEh);
begin
  inherited Create(ACellHolder);
end;

function TDataAxisCheckboxCellEh.CreateDefaultCellContentControls(AParentObject: TLaObjectEh): TLaObjectEh;
begin
  with TLaLayoutPanelEh.CreateWith(Self, AParentObject) do
  begin
    Result := TLaControlEh(RefSelf) ;
    FCheckBox := TSimpleCheckBoxEh.Create(RefSelf);
    FCheckBox.Parent := RefSelf;
    FCheckBox.HitTest := False;
    FCheckBox.Locked := True;
  end;
end;

destructor TDataAxisCheckboxCellEh.Destroy;
begin
  inherited Destroy;
end;

procedure TDataAxisCheckboxCellEh.MouseClick(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited MouseClick(Button, Shift, X, Y);
  if (Button = TMouseButton.mbLeft) and
     (FieldBar.CanModifyCellValue(ListItemBar))
  then
    Toggle;
end;

procedure TDataAxisCheckboxCellEh.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  FMousePressed := True;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TDataAxisCheckboxCellEh.ProcessMouseDown(Params: TControlMouseButtonParamsEh);
begin
  inherited ProcessMouseDown(Params);
end;

function TDataAxisCheckboxCellEh.GetIsChecked: Boolean;
begin
  Result := FCheckBox.IsChecked;
end;

procedure TDataAxisCheckboxCellEh.SetIsChecked(const Value: Boolean);
begin
  if FCheckBox.IsChecked <> Value then
  begin
    FCheckBox.IsChecked := Value;
  end;
end;

procedure TDataAxisCheckboxCellEh.Toggle;
begin
  TDataAxisCheckboxCellManagerEh(CellManager).ToggleCellValue(Grid, FieldBar, ListItemBar);
end;

{$ENDREGION}

{$REGION 'TDataGridGraphicDataCellManagerEh'}

{ TDataGridGraphicDataCellManagerEh }

function TDataAxisGraphicCellManagerEh.CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh;
begin
  Result := TDataAxisGraphicCellEh.Create(ACellHolder);
end;

procedure TDataAxisGraphicCellManagerEh.DefaultInitCellContent(Params: TBaseGridInitCellContentParamsEh);
var
  GraphicCell: TDataAxisGraphicCellEh;
  Value: TValue;
  VarValue: Variant;
  ImgStream: IImageStream;
  ImageIdx: Integer;
begin
  GraphicCell := TDataAxisGraphicCellEh(Params.Cell);
  if  (GraphicCell.ListItemBar <> nil) then
  begin
    Value := GraphicCell.FieldBar.GetListItemValue(GraphicCell.ListItemBar);

    if Value.IsType<Variant> then
      VarValue := Value.AsVariant
    else
      VarValue := Null;

    if ImageList <> nil then
    begin
      if not VarIsNullEh(VarValue)
        then ImageIdx := Integer(VarValue)
        else ImageIdx := -1;
      GraphicCell.ImageControl.ImageList := ImageList;
      if (ImageIdx >= 0) and (ImageIdx < ImageList.Source.Count) then
        GraphicCell.ImageControl.ImageIndex := ImageIdx
      else
        GraphicCell.ImageControl.ImageIndex := -1;
    end
    else if  (VarType(VarValue) in [varDispatch, varUnknown]) and
             Supports(VarValue, IImageStream, ImgStream) then
    begin
      GraphicCell.ImageControl.Bitmap.Assign(ImgStream.GetObject);
    end;
  end else
  begin
    GraphicCell.ImageControl.Bitmap.SetSize(0, 0);
  end;
end;

procedure TDataAxisGraphicCellManagerEh.SetImageList(const Value: TCustomImageList);
begin
  if FImageList <> Value then
  begin
    FImageList := Value;
    Changed();
  end;
end;

{$ENDREGION}

{$REGION 'TDataGridGraphicDataCellEh'}

{ TDataGridGraphicDataCellEh }

constructor TDataAxisGraphicCellEh.Create(ACellHolder: TGridBaseCellHolderEh);
begin
  inherited Create(ACellHolder);
end;

destructor TDataAxisGraphicCellEh.Destroy;
begin
  inherited Destroy;
end;

function TDataAxisGraphicCellEh.CanEditMode: Boolean;
begin
  Result := False;
end;

function TDataAxisGraphicCellEh.CreateDefaultCellContentControls(AParentObject: TLaObjectEh): TLaObjectEh;
begin
  with TLaImageEh.CreateWith(Self, AParentObject) do
  begin
    Result := TLaControlEh(RefSelf) ;
    FImageControl := TLaImageEh(RefSelf);
  end;
end;

{$ENDREGION}

{$REGION 'TDataGridLayoutDataCellManagerEh'}

{ TDataGridLayoutDataCellManagerEh }

function TDataAxisLayoutCellManagerEh.CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh;
begin
  Result := TDataAxisLayoutCellEh.Create(ACellHolder);
end;

procedure TDataAxisLayoutCellManagerEh.InitCell(ACell: TGridBaseCellEh);
begin
  inherited InitCell(ACell);
end;

{$ENDREGION 'TDataGridLayoutDataCellManagerEh'}

{$REGION 'TDataGridLayoutDataCellEh'}

{ TDataGridLayoutDataCellEh }

function TDataAxisLayoutCellEh.CanEditMode: Boolean;
begin
  Result := False;
end;

constructor TDataAxisLayoutCellEh.Create(ACellHolder: TGridBaseCellHolderEh);
begin
  inherited Create(ACellHolder);
end;

destructor TDataAxisLayoutCellEh.Destroy;
begin
  inherited Destroy;
end;

{$ENDREGION}

{$REGION 'TDataAxisCellEditParamsEh'}

procedure TDataAxisCellEditParamsEh.Init(AGrid: TControl; ACellManager: TBaseGridCellManagerEh; AColIndex,
  ARowIndex, AAreaColIndex, AAreaRowIndex: Integer);
begin
  inherited Init(AGrid, ACellManager, AColIndex, ARowIndex, AAreaColIndex, AAreaRowIndex);
  TCustomDataAxisGridEhCrack(AGrid).GetFieldBarListItemBarAtPos(AColIndex, ARowIndex, FFieldBar, FListItemBar);
end;

{$ENDREGION 'TDataAxisCellEditParamsEh'}

{$REGION 'TDataAxisCellInitEditorParamsEh'}

function TDataAxisCellInitEditorParamsEh.GetFieldBar: TFieldBarEh;
begin
  Result := TDataAxisCellEh(Cell).FieldBar;
end;

function TDataAxisCellInitEditorParamsEh.GetListItemBar: TTableRowViewEh;
begin
  Result := TDataAxisCellEh(Cell).ListItemBar;
end;

{$ENDREGION 'TDataAxisCellInitEditorParamsEh'}

{$REGION 'TDataAxisInitCellParamsEh'}

destructor TDataAxisInitCellParamsEh.Destroy;
begin
  FreeAndNil(FStyleParams);
  inherited Destroy;
end;

procedure TDataAxisInitCellParamsEh.Init(AGrid: TControl;
  ACellManager: TBaseGridCellManagerEh; ACell: TGridBaseCellEh);
var
  DataCell: TDataAxisCellEh;
  DataCellManager: TDataAxisCellManagerEh;
begin
  inherited Init(AGrid, ACellManager, ACell);

  DataCell := (ACell as TDataAxisCellEh);
  FFieldBar := DataCell.FieldBar;
  FListItemBar := DataCell.ListItemBar;
  DataCellManager := ACellManager as TDataAxisCellManagerEh;
  FStyleParams := DataCellManager.GetStyleParams(DataCell);
end;

{$ENDREGION 'TDataAxisInitCellParamsEh'}

{$REGION 'TDataAxisInitCellContentParamsEh'}

{ TDataAxisInitCellContentParamsEh }

procedure TDataAxisInitCellContentParamsEh.Init(ACell: TGridBaseCellEh; ACellContent: TLaObjectEh;
  InitCellParams: TBaseGridInitCellParamsEh);
begin
  inherited Init(ACell, ACellContent, InitCellParams);
end;

function TDataAxisInitCellContentParamsEh.GetInitDataCellParams: TDataAxisInitCellParamsEh;
begin
  Result := TDataAxisInitCellParamsEh(InitCellParams);
end;

function TDataAxisInitCellContentParamsEh.GetFieldBar: TFieldBarEh;
begin
  Result := InitDataCellParams.FieldBar;
end;

function TDataAxisInitCellContentParamsEh.GetListItemBar: TTableRowViewEh;
begin
  Result := InitDataCellParams.ListItemBar;
end;

function TDataAxisInitCellContentParamsEh.GetStyleParams: TDataAxisCellStyleParamsEh;
begin
  Result := InitDataCellParams.StyleParams;
end;

{$ENDREGION}

{$REGION 'TDataAxisStringCellStyleParamsEh'}

constructor TDataAxisStringCellStyleParamsEh.Create;
begin
  inherited Create;
  FFormattedRanges := TList<TLaFormattedTextRangeEh>.Create;
end;

destructor TDataAxisStringCellStyleParamsEh.Destroy;
var
  FmtRange: TLaFormattedTextRangeEh;
begin
  for FmtRange in FFormattedRanges do
    FmtRange.Free;
  FreeAndNil(FFormattedRanges);
  inherited Destroy;
end;

procedure TDataAxisStringCellStyleParamsEh.Init(AGrid: TControl; AFieldBar: TFieldBarEh; AListItemBar: TTableRowViewEh;
  ADataRowIndex: Integer);
begin
  inherited Init(AGrid, AFieldBar, AListItemBar, ADataRowIndex);
end;

{$ENDREGION 'TDataAxisStringCellStyleParamsEh'}

{$REGION 'TDataAxisCellKeyDownParamsEh'}

procedure TDataAxisCellKeyDownParamsEh.Reset(AGrid: TControl;
  ACellManager: TBaseGridCellManagerEh; AColIndex, ARowIndex, AAreaColIndex,
  AAreaRowIndex: Integer; AKey: Word; AKeyChar: WideChar; AShift: TShiftState);
var
  VGrid: TCustomDataAxisGridEhCrack;
  AFieldBar: TFieldBarEh;
  AListItemBar: TTableRowViewEh;
begin
  inherited Reset(AGrid, ACellManager, AColIndex, ARowIndex, AAreaColIndex, AAreaRowIndex, AKey, AKeyChar, AShift);

  VGrid := TCustomDataAxisGridEhCrack(AGrid);
  VGrid.GetFieldBarListItemBarAtPos(AColIndex, ARowIndex, AFieldBar, AListItemBar);
  FFieldBar := AFieldBar;
  FListItemBar := AListItemBar;
end;

{$ENDREGION 'TDataAxisCellKeyDownParamsEh'}

{$REGION 'TDataAxisCellTreeViewAreaParamsEh'}

procedure TDataAxisCellTreeViewAreaParamsEh.Init(AGrid: TControl;
  AFieldBar: TFieldBarEh; AListItemBar: TTableRowViewEh;
  ATreeAreaVisible: Boolean; ALevelWidth, ALevel: Integer;
  ASignState: TTreeSignStateEh; ASignVisible: Boolean);
begin
  FGrid := AGrid;

  FFieldBar := AFieldBar;
  FListItemBar := AListItemBar;

  FTreeAreaVisible := ATreeAreaVisible;
  FLevel := ALevel;
  FLevelWidth := ALevelWidth;
  FSignState := ASignState;
  FSignVisible := ASignVisible;
end;

{$ENDREGION 'TDataAxisCellTreeViewAreaParamsEh'}

{$REGION 'TDataAxisCellTreeSignStateParamsEh'}

procedure TDataAxisCellTreeSignStateParamsEh.Init(AGrid: TControl;
  AFieldBar: TFieldBarEh; AListItemBar: TTableRowViewEh;
  ASignState: TTreeSignStateEh; AShiftState: TShiftState);
begin
  FGrid := AGrid;

  FFieldBar := AFieldBar;
  FListItemBar := AListItemBar;

  FSignState := ASignState;
  FShiftState := AShiftState;
end;

{$ENDREGION 'TDataAxisCellTreeSignStateParamsEh'}

{$REGION 'TDataAxisCellComposeContextMenuParamsEh'}

procedure TDataAxisCellComposeContextMenuParamsEh.Init(AGrid: TControl; ACell: TGridBaseCellEh;
  AControlParams: TControlShowContextMenuParamsEh);
begin
  inherited Init(AGrid, ACell, AControlParams);
  if ACell is TDataAxisCellEh then
  begin
    FFieldBar := TDataAxisCellEh(Cell).FieldBar;
    FListItemBar := TDataAxisCellEh(Cell).ListItemBar;
  end;
end;

{$ENDREGION 'TDataAxisCellComposeContextMenuParamsEh'}

{$REGION 'TDataAxisCellMouseButtonParamsEh'}

procedure TDataAxisCellMouseButtonParamsEh.Init(AGrid: TControl; ACell: TGridBaseCellEh;
  Params: TControlMouseButtonParamsEh);
begin
  inherited Init(AGrid, ACell, Params);
  if ACell is TDataAxisCellEh then
  begin
    FFieldBar := TDataAxisCellEh(Cell).FieldBar;
    FListItemBar := TDataAxisCellEh(Cell).ListItemBar;
  end;
end;

{$ENDREGION 'TDataAxisCellMouseButtonParamsEh'}

{$REGION 'TDataAxisCellStartEditParamsEh'}

procedure TDataAxisCellStartEditParamsEh.Init(AGrid: TControl; ACell: TDataAxisCellEh);
begin
  FGrid := AGrid;
  FCell := ACell;
end;

function TDataAxisCellStartEditParamsEh.GetFieldBar: TFieldBarEh;
begin
  Result := Cell.FieldBar;
end;

function TDataAxisCellStartEditParamsEh.GetListItemBar: TTableRowViewEh;
begin
  Result := Cell.ListItemBar;
end;

{$ENDREGION 'TDataAxisCellStartEditParamsEh'}

{$REGION 'TDataAxisCellHolderEh'}

{ TDataAxisCellHolderEh }

procedure TDataAxisCellHolderEh.CreateControls(AParent: TLaObjectEh);
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

//    ControlCollection.AddControl(FBottomLine, 1, -1);
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

procedure TDataAxisCellHolderEh.InitPositionProps;
begin
  inherited InitPositionProps;
end;

procedure TDataAxisCellHolderEh.TreeSignMouseDown(Sender: TObject; Params: TControlMouseButtonParamsEh);
begin
  if (TreeViewArea.Visible = True) and (TreeViewArea.SignVisible = True) then
    TDataAxisCellManagerEh(CellManager).CellTreeSignMouseDown(Self, Params);
end;

{$ENDREGION 'TDataAxisCellHolderEh'}

end.
