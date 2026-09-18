{*******************************************************}
{                                                       }
{                     EhLib.Fmx 12.1                    }
{              EhLibFmx.Grid.CellManagers                }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

{$I ..\Incl\EhLib.Inc}
{$SCOPEDENUMS ON}

unit EhLibFmx.Grid.CellManagers;

interface

uses
  System.SysUtils, System.Classes, System.Types, FMX.Controls, FMX.Graphics,
  System.Rtti,
  FMX.Controls.Presentation, FMX.StdCtrls, System.UITypes, FMX.Forms,
  FMX.Objects, FMX.Types, FMX.Platform, FMX.Menus,
  EhLibUtils,
  EhLibFmx.Platform,
  EhLibFmx.ToolControls,
  EhLibFmx.ImageReses,
  EhLibFmx.Grid.Types,
  EhLibFmx.LaObjects,
  EhLibFmx.LaControls,
  EhLibFmx.LaPanels,
  EhLibFmx.LaHostVirtualPanels,
  EhLibFmx.Types;

type
  TBaseGridCellValueParamsEh = class;
  TBaseGridCellKeyDownParamsEh = class;
  TGridCellMouseButtonParamsEh = class;
  TGridCellMouseParamsEh = class;
  TBaseGridCellShowContextMenuParamsEh = class;
  TBaseGridCellContextMenuParamsEh = class;
  TBaseGridCellComposeContextMenuParamsEh = class;
  TBaseGridCellBaseParamsEh = class;

  TBaseGridCellManagerEh = class;
  TGridBaseCellHolderEh = class;
  TGridBaseCellEh = class;
  TGridCellTreeViewAreaControlEh = class;

{ TGridCellMouseParamsEh }

  TGridCellMouseParamsEh = class(TPersistent)
  private
    FGrid: TControl;
    FCell: TGridBaseCellEh;
    FBaseParams: TControlMouseParamsEh;
    FColIndex: Integer;
    FRowIndex: Integer;
    FAreaColIndex: Integer;
    FAreaRowIndex: Integer;
    FCellRect: TRect;
    FInCellX: Integer;
    FInCellY: Integer;
    FHandled: Boolean;
  public
    procedure Init(AGrid: TControl; ACell: TGridBaseCellEh; ABaseParams: TControlMouseParamsEh); overload; virtual;
    procedure Init(AGrid: TControl; AColIndex: Integer; ARowIndex: Integer; AAreaColIndex: Integer; AAreaRowIndex: Integer; const ACellRect: TRect; AInCellX, AInCellY: Integer; ABaseParams: TControlMouseParamsEh); overload; virtual;

    property Grid: TControl read FGrid;
    property BaseParams: TControlMouseParamsEh read FBaseParams;

    property Cell: TGridBaseCellEh read FCell;
    property ColIndex: Integer read FColIndex;
    property RowIndex: Integer read FRowIndex;
    property AreaRowIndex: Integer read FAreaRowIndex;
    property AreaColIndex: Integer read FAreaColIndex;
    property CellRect: TRect read FCellRect;

    property InCellX: Integer read FInCellX;
    property InCellY: Integer read FInCellY;
    property Handled: Boolean read FHandled write FHandled;
  end;

{ TGridCellButtonMouseParamsEh }

  TGridCellMouseButtonParamsEh = class(TGridCellMouseParamsEh)
  private
    function GetBaseParams: TControlMouseButtonParamsEh;

  public
    procedure Init(AGrid: TControl; ACell: TGridBaseCellEh; Params: TControlMouseButtonParamsEh); reintroduce; virtual;

    property BaseParams: TControlMouseButtonParamsEh read GetBaseParams;
  end;

{ TBaseGridCellBaseParamsEh }

  TBaseGridCellBaseParamsEh = class(TPersistent)
  private
    FGrid: TControl;
    FCell: TGridBaseCellEh;
    function GetAreaColIndex: Integer;
    function GetAreaRowIndex: Integer;
    function GetCellManager: TBaseGridCellManagerEh;
    function GetColIndex: Integer;
    function GetRowIndex: Integer;

  protected
    procedure Reset(AGrid: TControl; ACell: TGridBaseCellEh); virtual;

  public
    constructor Create;

    procedure Init(AGrid: TControl; ACell: TGridBaseCellEh); virtual;

    property Grid: TControl read FGrid;
    property Cell: TGridBaseCellEh read FCell;
    property CellManager: TBaseGridCellManagerEh read GetCellManager;

    property ColIndex: Integer read GetColIndex;
    property RowIndex: Integer read GetRowIndex;
    property AreaColIndex: Integer read GetAreaColIndex;
    property AreaRowIndex: Integer read GetAreaRowIndex;
  end;

{ TBaseGridCellPosBaseParamsEh }

  TBaseGridCellPosBaseParamsEh = class(TPersistent)
  private
    FGrid: TControl;
    FCellManager: TBaseGridCellManagerEh;
    FColIndex: Integer;
    FRowIndex: Integer;
    FAreaColIndex: Integer;
    FAreaRowIndex: Integer;

  protected
    procedure Reset(AGrid: TControl; ACellManager: TBaseGridCellManagerEh; AColIndex: Integer; ARowIndex: Integer; AAreaColIndex: Integer; AAreaRowIndex: Integer); virtual;

  public
    constructor Create;

    procedure Init(AGrid: TControl; ACellManager: TBaseGridCellManagerEh; AColIndex: Integer; ARowIndex: Integer; AAreaColIndex: Integer; AAreaRowIndex: Integer); virtual;

    property Grid: TControl read FGrid;
    property CellManager: TBaseGridCellManagerEh read FCellManager;

    property ColIndex: Integer read FColIndex;
    property RowIndex: Integer read FRowIndex;
    property AreaColIndex: Integer read FAreaColIndex;
    property AreaRowIndex: Integer read FAreaRowIndex;
  end;

{ TBaseGridCellValueParamsEh }

  TBaseGridCellValueParamsEh = class(TBaseGridCellBaseParamsEh)
  private
    FValue: TValue;

  protected
    procedure Reset(AGrid: TControl; ACell: TGridBaseCellEh); override;

  public
    constructor Create;
    destructor Destroy; override;

    procedure ResetAndInit(AGrid: TControl; ACell: TGridBaseCellEh);

    property Value: TValue read FValue write FValue;
  end;

{  TBaseGridCellContextMenuParamsEh }

  TBaseGridCellContextMenuParamsEh = class(TBaseGridCellBaseParamsEh)
  private
    FPopupMenu: TPopupMenu;
  public
    procedure ResetAndInit(AGrid: TControl; ACell: TGridBaseCellEh);

    property PopupMenu: TPopupMenu read FPopupMenu write FPopupMenu;
  end;

{ TBaseGridCellKeyDownParamsEh }

  TBaseGridCellKeyDownParamsEh = class(TBaseGridCellPosBaseParamsEh)
  private
    FKey: Word;
    FShift: TShiftState;
    FKeyChar: WideChar;

  protected
    procedure Reset(AGrid: TControl; ACellManager: TBaseGridCellManagerEh; AColIndex: Integer; ARowIndex: Integer; AAreaColIndex: Integer; AAreaRowIndex: Integer; AKey: Word; AKeyChar: WideChar; AShift: TShiftState); reintroduce; virtual;

  public
    constructor Create;
    destructor Destroy; override;

    procedure ResetAndInit(AGrid: TControl; ACellManager: TBaseGridCellManagerEh; AColIndex: Integer; ARowIndex: Integer; AAreaColIndex: Integer; AAreaRowIndex: Integer; AKey: Word; AKeyChar: WideChar; AShift: TShiftState);

    property Key: Word read FKey write FKey;
    property KeyChar: WideChar read FKeyChar write FKeyChar;
    property Shift: TShiftState read FShift;
  end;

{ TBaseGridCellShowContextMenuParamsEh }

  TBaseGridCellShowContextMenuParamsEh = class(TPersistent)
  private
    FGrid: TControl;
    FCell: TGridBaseCellEh;
    FControlParams: TControlShowContextMenuParamsEh;
    FHandled: Boolean;
    function GetAreaColIndex: Integer;
    function GetAreaRowIndex: Integer;
    function GetCellManager: TBaseGridCellManagerEh;
    function GetColIndex: Integer;
    function GetRowIndex: Integer;

  protected

  public
    constructor Create;
    procedure Init(AGrid: TControl; ACell: TGridBaseCellEh; AControlParams: TControlShowContextMenuParamsEh); virtual;

    property ControlParams: TControlShowContextMenuParamsEh read FControlParams;
    property Grid: TControl read FGrid;
    property Cell: TGridBaseCellEh read FCell;
    property CellManager: TBaseGridCellManagerEh read GetCellManager;

    property ColIndex: Integer read GetColIndex;
    property RowIndex: Integer read GetRowIndex;
    property AreaColIndex: Integer read GetAreaColIndex;
    property AreaRowIndex: Integer read GetAreaRowIndex;
    property Handled: Boolean read FHandled write FHandled;
  end;

{ TBaseGridCellComposeContextMenuParamsEh }

  TBaseGridCellComposeContextMenuParamsEh = class(TBaseGridCellShowContextMenuParamsEh)
  private
    FPopupMenu: TPopupMenu;
    FComposedPopupMenu: TComposedPopupMenu;
    procedure SetPopupMenu(const Value: TPopupMenu);
  public
    property PopupMenu: TPopupMenu read FPopupMenu write SetPopupMenu;
    property ComposedPopupMenu: TComposedPopupMenu read FComposedPopupMenu;
  end;

{ TBaseGridInitCellParamsEh }

  TBaseGridInitCellParamsEh = class(TPersistent)
  private
    FGrid: TControl;
    FCellManager: TBaseGridCellManagerEh;
    FCell: TGridBaseCellEh;
    FIsShowCellFocus: Boolean;
    FIsFocusActive: Boolean;
    FIsShowSelection: Boolean;
    FIsSelectionActive: Boolean;

    FHandled: Boolean;

  public
    procedure Init(AGrid: TControl; ACellManager: TBaseGridCellManagerEh; ACell: TGridBaseCellEh); virtual;
    procedure DefaultInitCell();

    property Grid: TControl read FGrid;
    property CellManager: TBaseGridCellManagerEh read FCellManager;
    property Cell: TGridBaseCellEh read FCell;
    property Handled: Boolean read FHandled write FHandled;
    property IsShowCellFocus: Boolean read FIsShowCellFocus write FIsShowCellFocus;
    property IsFocusActive: Boolean read FIsFocusActive write FIsFocusActive;
    property IsShowSelection: Boolean read FIsShowSelection write FIsShowSelection;
    property IsSelectionActive: Boolean read FIsSelectionActive write FIsSelectionActive;
  end;

{ TBaseGridCreateCellContentParamsEh }

  TBaseGridCreateCellContentParamsEh = class(TPersistent)
  private
    FCell: TGridBaseCellEh;
    FCellContent: TLaObjectEh;
    FContentParent: TLaObjectEh;
    function GetGrid: TControl;
  public
    procedure Init(ACell: TGridBaseCellEh; AParent: TLaObjectEh); virtual;
    function DefaultCreateCellContent(AContentParent: TLaObjectEh): TLaObjectEh; virtual;

    property Cell: TGridBaseCellEh read FCell;
    property Grid: TControl read GetGrid;
    property CellContent: TLaObjectEh  read FCellContent write FCellContent;
    property ContentParent: TLaObjectEh read FContentParent;
  end;

{ TBaseGridInitCellContentParamsEh }

  TBaseGridInitCellContentParamsEh = class(TPersistent)
  private
    FHandled: Boolean;
    FCell: TGridBaseCellEh;
    FCellContent: TLaObjectEh;
    FInitCellParams: TBaseGridInitCellParamsEh;

    function GetCellContent: TLaObjectEh;
    function GetCell: TGridBaseCellEh;
    function GetCellManager: TVPBaseCellManagerEh;
    function GetGrid: TControl;

  public
    procedure Init(ACell: TGridBaseCellEh; ACellContent: TLaObjectEh; AInitCellParams: TBaseGridInitCellParamsEh); virtual;
    procedure DefaultInitCellContent(); virtual;

    property Grid: TControl read GetGrid;
    property CellManager: TVPBaseCellManagerEh read GetCellManager;
    property Cell: TGridBaseCellEh read GetCell;
    property CellContent: TLaObjectEh  read GetCellContent;
    property InitCellParams: TBaseGridInitCellParamsEh read FInitCellParams;
    property Handled: Boolean read FHandled write FHandled;
  end;

{ TBaseGridCellEditParamsEh }

  TBaseGridCellEditParamsEh = class(TBaseGridCellPosBaseParamsEh)
  private
    FEditorValue: TValue;
    FEditorReadOnly: Boolean;
  public
    procedure Init(AGrid: TControl; ACellManager: TBaseGridCellManagerEh; AColIndex: Integer; ARowIndex: Integer; AAreaColIndex: Integer; AAreaRowIndex: Integer); override;

    property EditorValue: TValue read FEditorValue write FEditorValue;
    property EditorReadOnly: Boolean read FEditorReadOnly write FEditorReadOnly;
  end;

{ TBaseGridInitEditorParamsEh }

  TBaseGridInitEditorParamsEh = class(TBaseGridCellBaseParamsEh)
  private
    FEditor: TLaObjectEh;
    FCell: TGridBaseCellEh;
    FEditorParams: TBaseGridCellEditParamsEh;
    FHandled: Boolean;
  public
    procedure Init(AGrid: TControl; ACell: TGridBaseCellEh; AEditor: TLaObjectEh; AEditorParams: TBaseGridCellEditParamsEh); reintroduce; virtual;

    procedure DefaultInitEditor();

    property Cell: TGridBaseCellEh read FCell;
    property Editor: TLaObjectEh read FEditor;
    property EditorParams: TBaseGridCellEditParamsEh read FEditorParams;
    property Handled: Boolean read FHandled write FHandled;
  end;

{ TBaseGridCellManagerEh }

  TBaseGridCellManagerEh = class(TVPBaseCellManagerEh)
  private
    FIsComposeContextMenu: Boolean;
    FPopupMenu: TCustomPopupMenu;
  protected
    function CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh; virtual;
    function CreateInitCellParams: TBaseGridInitCellParamsEh; virtual;
    function CreateInitCellContentParams: TBaseGridInitCellContentParamsEh; virtual;
    function CreateCustomCellContent(ACell: TGridBaseCellEh; AParent: TLaObjectEh): TLaObjectEh; virtual;
    function CreateDefaultCellContent(ACell: TGridBaseCellEh; AParent: TLaObjectEh): TLaObjectEh; virtual;
    function CreateCellContentParams(): TBaseGridCreateCellContentParamsEh; virtual;

    procedure ComposeContextMenu(Params: TBaseGridCellComposeContextMenuParamsEh); virtual;

    procedure HandleMouseDownEvent(Params: TGridCellMouseButtonParamsEh); virtual;
    procedure HandleMouseClickEvent(Params: TGridCellMouseButtonParamsEh); virtual;
    procedure HandleMouseMoveEvent(Params: TGridCellMouseParamsEh); virtual;
    procedure HandleMouseEnterEvent(Params: TBaseGridCellBaseParamsEh); virtual;
    procedure HandleInitCell(Params: TBaseGridInitCellParamsEh); virtual;
    procedure HandleInitCellContent(Params: TBaseGridInitCellContentParamsEh); virtual;
    procedure HandleCreateCustomCellContent(Params: TBaseGridCreateCellContentParamsEh); virtual;
    procedure HandleInitCellEditor(AInitEditorParams: TBaseGridInitEditorParamsEh); virtual;

    procedure MouseDown(Params: TGridCellMouseButtonParamsEh); virtual;
    procedure MouseMove(Params: TGridCellMouseParamsEh); virtual;
    procedure MouseUp(Params: TGridCellMouseButtonParamsEh); virtual;
    procedure MouseClick(Params: TGridCellMouseButtonParamsEh); virtual;
    procedure MouseEnter(Params: TBaseGridCellBaseParamsEh); virtual;

    procedure ContextMenuNeeded(Params: TBaseGridCellContextMenuParamsEh); virtual;

    procedure ProcessInitCell(Params: TBaseGridInitCellParamsEh); virtual;
    procedure InitCellEditParams(AParams: TBaseGridCellEditParamsEh); virtual;
  public
    constructor Create(AOwner: TComponent); override;

    function CreateCellHolder(): TVPBaseCellHolderEh; override;

    function GetCellValueParams(AGrid: TControl; ACell: TGridBaseCellEh): TBaseGridCellValueParamsEh; virtual;
    function GetCellContextMenuParams(AGrid: TControl; ACell: TGridBaseCellEh): TBaseGridCellContextMenuParamsEh; virtual;
    function GetCellKeyDownParams(AGrid: TControl; AColIndex, ARowIndex, AAreaColIndex, AAreaRowIndex: Integer; AKey: Word; AKeyChar: WideChar; AShift: TShiftState): TBaseGridCellKeyDownParamsEh; virtual;
    function GetCellEditParams(AGrid: TControl; ACell: TGridBaseCellEh): TBaseGridCellEditParamsEh; virtual;
    function GetInitEditorParams(AGrid: TControl; ACell: TGridBaseCellEh; AEditor: TLaObjectEh; AEditParams: TBaseGridCellEditParamsEh): TBaseGridInitEditorParamsEh; virtual;

    function CreateCellValueParams(AGrid: TControl; ACell: TGridBaseCellEh): TBaseGridCellValueParamsEh; virtual;
    function CreateCellContextMenuParams(AGrid: TControl; ACell: TGridBaseCellEh): TBaseGridCellContextMenuParamsEh; virtual;
    function CreateCellKeyDownParams(AGrid: TControl; AColIndex, ARowIndex, AAreaColIndex, AAreaRowIndex: Integer): TBaseGridCellKeyDownParamsEh; virtual;

    function CreateComposeContextMenuParams(): TBaseGridCellComposeContextMenuParamsEh; virtual;
    function CreateCellEditParams(): TBaseGridCellEditParamsEh; virtual;
    function CreateInitEditorParams(): TBaseGridInitEditorParamsEh; virtual;

    function IsShowFocusLayer(AGrid: TControl; ACell: TGridBaseCellEh): Boolean; virtual;
    function IsShowSelectionLayer(AGrid: TControl; ACell: TGridBaseCellEh): Boolean; virtual;

    function GetCellContentTextValue(Params: TBaseGridInitCellContentParamsEh): String; virtual;
    function GetBackgroundStyle(AParams: TBaseGridInitCellParamsEh): TControl; virtual;

    procedure DefaultInitCell(Params: TBaseGridInitCellParamsEh); virtual;
    procedure DefaultInitCellProps(Params: TBaseGridInitCellParamsEh); virtual;
    procedure DefaultInitCellContent(Params: TBaseGridInitCellContentParamsEh); virtual;
    procedure DefaultInitCellEditor(AParams: TBaseGridInitEditorParamsEh); virtual;
    procedure DefaultInitCellStyledBackground(Params: TBaseGridInitCellParamsEh); virtual;
    procedure DefaultInitCellSelection(Params: TBaseGridInitCellParamsEh); virtual;

    procedure InitCellHolder(ACell: TVPBaseCellHolderEh); override;
    procedure InitCell(ACell: TGridBaseCellEh); virtual;
    procedure InitCellPositionProps(ACell: TGridBaseCellEh); virtual;
    procedure InitCellSideBorder(ACellHolder: TGridBaseCellHolderEh; BorderType: TGridCellBorderTypeEh; IsDraw: Boolean; BorderColor: TAlphaColor; IsExtent: Boolean); virtual;

    procedure InitCellValueParams(Params: TBaseGridCellValueParamsEh); virtual;
    procedure InitCellContextMenuParams(Params: TBaseGridCellContextMenuParamsEh); virtual;
    procedure InitCellClient(ACell: TGridBaseCellEh; ACellClient: TLaObjectEh; InitCellParams: TBaseGridInitCellParamsEh); virtual;
    procedure InitCellClientProps(ACell: TGridBaseCellEh; ACellClient: TLaObjectEh; InitCellParams: TBaseGridInitCellParamsEh); virtual;
    procedure InitCellContent(ACell: TGridBaseCellEh; InitCellParams: TBaseGridInitCellParamsEh); virtual;
    procedure InitCellEditor(AParams: TBaseGridInitEditorParamsEh);

    function GetMouseButtonParams(AGrid: TControl; ACell: TGridBaseCellEh; Params: TControlMouseButtonParamsEh): TGridCellMouseButtonParamsEh; virtual;
    function GetMouseParams(AGrid: TControl; ACell: TGridBaseCellEh; Params: TControlMouseParamsEh): TGridCellMouseParamsEh; virtual;
    function GetCellBaseParams(AGrid: TControl; ACell: TGridBaseCellEh; Params: TControlParamsEh): TBaseGridCellBaseParamsEh; virtual;
    function CreateMouseButtonParams(ACell: TGridBaseCellEh): TGridCellMouseButtonParamsEh; virtual;
    function CreateMouseParams(ACell: TGridBaseCellEh): TGridCellMouseParamsEh; virtual;
    function CreateCellBaseParams(ACell: TGridBaseCellEh): TBaseGridCellBaseParamsEh; virtual;

    procedure ProcessControlMouseDown(AGrid: TControl; ACell: TGridBaseCellEh; Params: TControlMouseButtonParamsEh); virtual;
    procedure ProcessControlMouseUp(Params: TGridCellMouseButtonParamsEh); virtual;
    procedure ProcessControlMouseClick(AGrid: TControl; ACell: TGridBaseCellEh; Params: TControlMouseButtonParamsEh); virtual;
    procedure ProcessControlMouseMove(AGrid: TControl; ACell: TGridBaseCellEh; Params: TControlMouseParamsEh); virtual;
    procedure ProcessControlMouseEnter(AGrid: TControl; ACell: TGridBaseCellEh; Params: TControlParamsEh); virtual;
    procedure ProcessControlMouseLeave(AGrid: TControl; ACell: TGridBaseCellEh; Params: TControlParamsEh); virtual;
    procedure ProcessDblClick(AGrid: TControl; ACell: TGridBaseCellEh; Params: TControlParamsEh); virtual;

    function GetMouseMoveParams(AGrid: TControl; ACell: TGridBaseCellEh; Params: TControlMouseParamsEh): TGridCellMouseParamsEh; virtual;
    function CreateMouseMoveParams(ACell: TGridBaseCellEh): TGridCellMouseParamsEh; virtual;
    procedure ProcessMouseMove(Params: TGridCellMouseParamsEh); virtual;

    procedure ProcessKeyDown(Params: TBaseGridCellKeyDownParamsEh); virtual;

    procedure ProcessCellContextMenuNeeded(Params: TBaseGridCellContextMenuParamsEh); virtual;
    procedure ShowContextMenu(ACellParams:  TBaseGridCellShowContextMenuParamsEh);

    function CanShowEditor(AGrid: TControl): Boolean; virtual;

    property IsComposeContextMenu: Boolean read FIsComposeContextMenu write FIsComposeContextMenu;
    property PopupMenu: TCustomPopupMenu read FPopupMenu write FPopupMenu;
  end;

{ TGridBaseCellEh }

  TGridBaseCellEh = class(TLaLayoutPanelEh)
  private
    FCellHolder: TGridBaseCellHolderEh;
    FFocusLayer: TLaControlEh;
    FSelectionLayer: TLaControlEh;
    FFocusLayerActive: Boolean;
    FCellClient: TLaObjectEh;
    FCustomCellContent: TLaObjectEh;
    FDefaultCellContent: TLaObjectEh;
    FIsCellContentCreated: Boolean;
    FStyledBackgroundHolder: TLaLayoutPanelEh;
    FBackgroundStyle: TControl;
    FSelectionLayerActive: Boolean;

    function GetCellManager: TBaseGridCellManagerEh;
    function GetAreaColIndex: Integer;
    function GetAreaRowIndex: Integer;
    function GetColIndex: Integer;
    function GetRowIndex: Integer;
    function GetGrid: TControl;
    function GetShowFocusLayer: Boolean;
    function GetCellContent: TLaObjectEh;

    procedure SetFocusLayerActive(const Value: Boolean);
    procedure SetShowFocusLayer(const Value: Boolean);
    procedure SetBackgroundStyle(const Value: TControl);
    function GetShowSelectionLayer: Boolean;
    procedure SetShowSelectionLayer(const Value: Boolean);
    procedure SetSelectionLayerActive(const Value: Boolean);
  protected
    function CreateDefaultCellContent(AParent: TLaObjectEh): TLaObjectEh;
    function CreateDefaultCellContentControls(AParent: TLaObjectEh): TLaObjectEh; virtual;
    function CreateCellContent(AParent: TLaObjectEh): TLaObjectEh;
    function CreateCustomCellContent(AParent: TLaObjectEh): TLaObjectEh;
    function CreateCustomCellContentControls(AParent: TLaObjectEh): TLaObjectEh; virtual;
    function CreateCellClient(AParent: TLaObjectEh): TLaObjectEh;
    function CreateCellClientControls(AParent: TLaObjectEh): TLaObjectEh; virtual;
    function CreateFocusLayer(AParent: TLaObjectEh): TLaControlEh;
    function CreateFocusLayerControls(AParent: TLaObjectEh): TLaControlEh; virtual;
    function CreateSelectionLayerControls(AParent: TLaObjectEh): TLaControlEh; virtual;
    function CreateStyledBackgroundHolder(AParent: TLaObjectEh): TLaLayoutPanelEh; virtual;

    procedure CreateControls(); virtual;

    procedure MouseEnter(Params: TControlParamsEh); override;
    procedure MouseLeave(Params: TControlParamsEh); override;
    procedure ProcessMouseDown(Params: TControlMouseButtonParamsEh); override;
    procedure ProcessMouseClick(Params: TControlMouseButtonParamsEh); override;
    procedure ProcessMouseMove(Params: TControlMouseParamsEh); override;
    procedure ProcessDblClick(Params: TControlParamsEh); override;
    procedure ShowFocusLayerChanged; virtual;
    procedure ShowSelectionLayerChanged; virtual;

  public
    constructor Create(ACellHolder: TGridBaseCellHolderEh);
    destructor Destroy; override;

    function CanMouseDownShowEditor(CellHitCoord: TGridCoord; ACell: TGridBaseCellEh; MouseParams: TControlMouseButtonParamsEh): Boolean; virtual;

    property CellManager: TBaseGridCellManagerEh read GetCellManager;
    property CellHolder: TGridBaseCellHolderEh read FCellHolder;

    property ColIndex: Integer read GetColIndex;
    property RowIndex: Integer read GetRowIndex;
    property AreaColIndex: Integer read GetAreaColIndex;
    property AreaRowIndex: Integer read GetAreaRowIndex;
    property Grid: TControl read GetGrid;

    property ShowFocusLayer: Boolean read GetShowFocusLayer write SetShowFocusLayer;
    property FocusLayerActive: Boolean read FFocusLayerActive write SetFocusLayerActive;

    property ShowSelectionLayer: Boolean read GetShowSelectionLayer write SetShowSelectionLayer;
    property SelectionLayerActive: Boolean read FSelectionLayerActive write SetSelectionLayerActive;

    property FocusLayer: TLaControlEh read FFocusLayer;
    property SelectionLayer: TLaControlEh read FSelectionLayer;
    property CellClient: TLaObjectEh read  FCellClient;
    property DefaultCellContent: TLaObjectEh read FDefaultCellContent;
    property CustomCellContent: TLaObjectEh read  FCustomCellContent;
    property CellContent: TLaObjectEh read  GetCellContent;
    property BackgroundStyle: TControl read FBackgroundStyle write SetBackgroundStyle;
  published
    property Locked stored False;
  end;

{ TGridBaseTextCellEh }

  TGridBaseTextCellEh = class(TGridBaseCellEh)
  private
    FText: TLaTextBlockEh;
    function GetText: String;
    procedure SetText(const Value: String);
  protected
    function CreateDefaultCellContentControls(AParent: TLaObjectEh): TLaObjectEh; override;

    procedure CreateControls(); override;

  public
    constructor Create(ACellHolder: TGridBaseCellHolderEh);
    destructor Destroy; override;

    property Text: String read GetText write SetText;
    property TextControl: TLaTextBlockEh read FText;
  end;

{ TGridBaseCellHolderEh }

  TGridBaseCellHolderEh = class(TVPBaseCellHolderEh)
  private
    FCellClient: TGridBaseCellEh;

    function GetCellManager: TBaseGridCellManagerEh;
  protected
    procedure CreateControls(AParent: TLaObjectEh); override;

    {$IFDEF EH_LIB_26} 
    function CheckHitTest(const AHitTest: Boolean): Boolean; override;
    {$ENDIF}
    procedure ProcessMouseDown(Params: TControlMouseButtonParamsEh); override;
  public
    constructor Create(AOwner: TComponent; ACellManager: TVPBaseCellManagerEh); override;
    destructor Destroy; override;

    property CellManager: TBaseGridCellManagerEh read GetCellManager;
    property CellClient: TGridBaseCellEh read FCellClient;
  published
    property Locked stored False;
  end;

{ TGridCellTreeViewAreaControlEh }

  TGridCellTreeViewAreaControlEh = class(TLaStackPanelEh)
  private
    FLevelWidth: Integer;
    FLevel: Integer;
    FSignState: TTreeSignStateEh;

    FTreeSignPanel: TLaObjectEh;
    FIndentPanel: TLaObjectEh;
    FTreeSignImage: TImage;
    FControlsCreated: Boolean;
    FOnTreeSignMouseDown: TControlMouseButtonEventEh;
    FRightBorderColor: TAlphaColor;
    FRightBorderVisible: Boolean;

    function GetSignVisible: Boolean;
    procedure SetLevel(const Value: Integer);
    procedure SetLevelWidth(const Value: Integer);
    procedure SetSignState(const Value: TTreeSignStateEh);
    procedure SetSignVisible(const Value: Boolean);
    function GetOnTreeSignMouseDown: TControlMouseButtonEventEh;
    procedure SetOnTreeSignMouseDown(const Value: TControlMouseButtonEventEh);
    procedure SetRightBorderColor(const Value: TAlphaColor);
    procedure SetRightBorderVisible(const Value: Boolean);
  protected
    procedure CreateControls; virtual;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure CheckCreateControls;

    property LevelWidth: Integer read FLevelWidth write SetLevelWidth;
    property Level: Integer read FLevel write SetLevel;
    property SignState: TTreeSignStateEh read FSignState write SetSignState;
    property SignVisible: Boolean read GetSignVisible write SetSignVisible;
    property RightBorderVisible: Boolean read FRightBorderVisible write SetRightBorderVisible;
    property RightBorderColor: TAlphaColor read FRightBorderColor write SetRightBorderColor;

    property OnTreeSignMouseDown: TControlMouseButtonEventEh read GetOnTreeSignMouseDown write SetOnTreeSignMouseDown;
  end;

{ TGridCellTreeViewAreaParamsEh }

  TGridCellTreeViewAreaParamsEh = class(TPersistent)
  private
    FLevel: Integer;
    FLevelWidth: Integer;
    FTreeAreaVisible: Boolean;
    FSignState: TTreeSignStateEh;
    FSignVisible: Boolean;
    FGrid: TControl;
    FHandled: Boolean;
  public
    procedure Init(AGrid: TControl; ATreeAreaVisible: Boolean; ALevelWidth: Integer; ALevel: Integer; ASignState: TTreeSignStateEh; ASignVisible: Boolean); virtual;

    property Grid: TControl read FGrid;

    property TreeAreaVisible: Boolean read FTreeAreaVisible write FTreeAreaVisible;
    property LevelWidth: Integer read FLevelWidth write FLevelWidth;
    property Level: Integer read FLevel write FLevel;
    property SignState: TTreeSignStateEh read FSignState write FSignState;
    property SignVisible: Boolean read FSignVisible write FSignVisible;
    property Handled: Boolean read FHandled write FHandled;
  end;

implementation

uses EhLibFmx.Grids, EhLibFmx.Grid.InplaceEditors;

type
  TCustomGridEhCrack = class(TCustomGridEh);

{ TGridBaseCellHolderEh }

{$REGION 'TGridBaseCellHolderEh'}
{$IFDEF EH_LIB_26} 
function TGridBaseCellHolderEh.CheckHitTest(const AHitTest: Boolean): Boolean;
begin
  if (Grid <> nil) and (csDesigning in Grid.ComponentState) then
    Result := False
  else
    Result := inherited CheckHitTest(AHitTest);
end;
{$ENDIF}

constructor TGridBaseCellHolderEh.Create(AOwner: TComponent; ACellManager: TVPBaseCellManagerEh);
begin
  inherited Create(AOwner, ACellManager);
  Locked := True;
end;

destructor TGridBaseCellHolderEh.Destroy;
begin
  inherited Destroy;
end;

procedure TGridBaseCellHolderEh.CreateControls(AParent: TLaObjectEh);
begin
  FCellClient := CellManager.CreateGridCell(Self);
  FCellClient.Parent := AParent;
  FCellClient.CreateControls;
end;

function TGridBaseCellHolderEh.GetCellManager: TBaseGridCellManagerEh;
begin
  Result := TBaseGridCellManagerEh(inherited CellManager);
end;

procedure TGridBaseCellHolderEh.ProcessMouseDown(Params: TControlMouseButtonParamsEh);
begin
  inherited ProcessMouseDown(Params);
end;
{$ENDREGION 'TGridBaseCellHolderEh'}

{ TGridBaseCellEh }

{$REGION 'TGridBaseCellEh'}
constructor TGridBaseCellEh.Create(ACellHolder: TGridBaseCellHolderEh);
begin
  inherited Create(ACellHolder);
  FCellHolder := ACellHolder;
  AutoCapture := True;
end;

destructor TGridBaseCellEh.Destroy;
begin
  inherited Destroy;
end;

function TGridBaseCellEh.GetAreaColIndex: Integer;
begin
  Result := CellHolder.AreaColIndex;
end;

function TGridBaseCellEh.GetAreaRowIndex: Integer;
begin
  Result := CellHolder.AreaRowIndex;
end;

function TGridBaseCellEh.GetColIndex: Integer;
begin
  Result := CellHolder.ColIndex;
end;

function TGridBaseCellEh.GetRowIndex: Integer;
begin
  Result := CellHolder.RowIndex;
end;

procedure TGridBaseCellEh.ProcessMouseDown(Params: TControlMouseButtonParamsEh);
begin
  if AutoCapture and (IsMouseCaptured = False) and (Root.Captured = nil) then
    Capture;
  inherited ProcessMouseDown(Params);
  if CellManager <> nil then
    CellManager.ProcessControlMouseDown(Grid, Self, Params);
end;

procedure TGridBaseCellEh.ProcessMouseClick(Params: TControlMouseButtonParamsEh);
begin
  inherited ProcessMouseClick(Params);
  if CellManager <> nil then
    CellManager.ProcessControlMouseClick(Grid, Self, Params);
end;

procedure TGridBaseCellEh.ProcessDblClick(Params: TControlParamsEh);
begin
  inherited ProcessDblClick(Params);
  if CellManager <> nil then
    CellManager.ProcessDblClick(Grid, Self, Params);
end;

function TGridBaseCellEh.CanMouseDownShowEditor(CellHitCoord: TGridCoord; ACell: TGridBaseCellEh;
  MouseParams: TControlMouseButtonParamsEh): Boolean;
var
  InContentHitPos: TPointF;
begin
  Result := False;
  if (ACell <> nil) and (ACell.CellContent <> nil) then
  begin
    InContentHitPos := MouseParams.GetPositionRelativeTo(ACell.CellContent);
    if (InContentHitPos.X >= 0) and
       (InContentHitPos.X < ACell.CellContent.ActualWidth) and
       (InContentHitPos.Y >= 0) and
       (InContentHitPos.Y < ACell.CellContent.ActualHeight)
    then
      Result := True;
  end;
end;

procedure TGridBaseCellEh.ProcessMouseMove(Params: TControlMouseParamsEh);
begin
  inherited ProcessMouseMove(Params);
  if CellManager <> nil then
    CellManager.ProcessControlMouseMove(Grid, Self, Params);
end;

procedure TGridBaseCellEh.MouseEnter(Params: TControlParamsEh);
begin
  inherited MouseEnter(Params);
  if CellManager <> nil then
    CellManager.ProcessControlMouseEnter(Grid, Self, Params);
end;

procedure TGridBaseCellEh.MouseLeave(Params: TControlParamsEh);
begin
  inherited MouseLeave(Params);
  if CellManager <> nil then
    CellManager.ProcessControlMouseLeave(Grid, Self, Params);
end;

function TGridBaseCellEh.GetGrid: TControl;
begin
  Result := CellHolder.Grid;
end;

function TGridBaseCellEh.GetCellManager: TBaseGridCellManagerEh;
begin
  Result := CellHolder.CellManager;
end;

procedure TGridBaseCellEh.CreateControls();
begin
  FStyledBackgroundHolder := CreateStyledBackgroundHolder(Self);
  FSelectionLayer := CreateSelectionLayerControls(Self);
  CreateFocusLayer(Self);
  CreateCellClient(Self);
end;

function TGridBaseCellEh.CreateFocusLayer(AParent: TLaObjectEh): TLaControlEh;
begin
  FFocusLayer := CreateFocusLayerControls(AParent);
  Result := FFocusLayer;
end;

function TGridBaseCellEh.CreateSelectionLayerControls(AParent: TLaObjectEh): TLaControlEh;
begin
  Result := TLaControlEh.CreateWith(AParent, AParent);
  //Result.Fill.Kind := TBrushKind.Solid;
  //Result.Fill.Color := $330080FF;
  //Result.Fill.Opacity := 0.2;
  //Result.Opacity := 1;
  Result.Visible := False;
  Result.Name := 'SelectionLayer';
end;

function TGridBaseCellEh.CreateFocusLayerControls(AParent: TLaObjectEh): TLaControlEh;
begin
  Result := TLaControlEh.CreateWith(AParent, AParent);
  Result.Fill.Kind := TBrushKind.None;
//  Result.Fill.Kind := TBrushKind.Solid;
//  Result.Fill.Color := $733399FF;
//  Result.Fill.Color := $FF3399FF;
//  Result.Opacity := 0.45;
  Result.Visible := False;
  Result.Name := 'FocusLayer';
end;

function TGridBaseCellEh.CreateStyledBackgroundHolder(AParent: TLaObjectEh): TLaLayoutPanelEh;
begin
  Result := TLaLayoutPanelEh.CreateWith(AParent, AParent);
  Result.Fill.Kind := TBrushKind.None;
  Result.Visible := True;
  Result.HitTest := False;
  Result.Name := 'StyledBackgroundHolder';
end;

procedure TGridBaseCellEh.SetBackgroundStyle(const Value: TControl);
var
  StyledBackground: TControl;
begin
  if FBackgroundStyle <> Value then
  begin
    FStyledBackgroundHolder.DeleteChildren;
    FStyledBackgroundHolder.TagObject := Value;
    if Value <> nil then
    begin
      StyledBackground := Value.Clone(Self) as TControl;
      StyledBackground.Align := TAlignLayout.None;
      FStyledBackgroundHolder.AddObject(StyledBackground);
    end;
    FBackgroundStyle := Value;
  end;
end;

function TGridBaseCellEh.GetCellContent: TLaObjectEh;
begin
  if FCustomCellContent <> nil then
    Result := FCustomCellContent
  else
    Result := FDefaultCellContent;
end;

function TGridBaseCellEh.CreateCustomCellContent(AParent: TLaObjectEh): TLaObjectEh;
begin
  FCustomCellContent := CreateCustomCellContentControls(AParent);
  Result := FCustomCellContent;
end;

function TGridBaseCellEh.CreateCustomCellContentControls(AParent: TLaObjectEh): TLaObjectEh;
begin
  Result := CellManager.CreateCustomCellContent(Self, AParent);
end;

function TGridBaseCellEh.CreateDefaultCellContent(AParent: TLaObjectEh): TLaObjectEh;
begin
  FDefaultCellContent := CreateDefaultCellContentControls(AParent);
  Result := FDefaultCellContent;
end;

function TGridBaseCellEh.CreateDefaultCellContentControls(AParent: TLaObjectEh): TLaObjectEh;
begin
  Result := CellManager.CreateDefaultCellContent(Self, AParent);
end;

function TGridBaseCellEh.CreateCellContent(AParent: TLaObjectEh): TLaObjectEh;
begin
  if FIsCellContentCreated = True then
  begin
    Result := CellContent
  end else
  begin
    Result := CreateCustomCellContent(AParent);
    if Result = nil then
      Result := CreateDefaultCellContent(AParent);
    FIsCellContentCreated := True;
  end;
end;

function TGridBaseCellEh.CreateCellClient(AParent: TLaObjectEh): TLaObjectEh;
begin
  FCellClient := CreateCellClientControls(AParent);
  Result := FCellClient;
  CreateCellContent(Result);
end;

function TGridBaseCellEh.CreateCellClientControls(AParent: TLaObjectEh): TLaObjectEh;
begin
  Result := AParent;
end;

function TGridBaseCellEh.GetShowFocusLayer: Boolean;
begin
  if FFocusLayer <> nil then
    Result := FFocusLayer.Visible
  else
    Result := False;
end;

procedure TGridBaseCellEh.SetShowFocusLayer(const Value: Boolean);
begin
  if FFocusLayer <> nil then
  begin
    if FFocusLayer.Visible <> Value then
    begin
      FFocusLayer.Visible := Value;
      ShowFocusLayerChanged();
    end;
  end;
end;

procedure TGridBaseCellEh.ShowFocusLayerChanged;
var
  VGrid: TCustomGridEhCrack;
begin
  VGrid := TCustomGridEhCrack(Grid);
  if FFocusLayer <> nil then
  begin
    if FocusLayerActive then
      FFocusLayer.Fill := VGrid.StylePainter.CellFocusFill
    else
      FFocusLayer.Fill := VGrid.StylePainter.CellInactiveFocusFill;
  end;
end;

procedure TGridBaseCellEh.SetFocusLayerActive(const Value: Boolean);
begin
  if FFocusLayerActive <> Value then
  begin
    FFocusLayerActive := Value;
    ShowFocusLayerChanged();
  end;
end;

function TGridBaseCellEh.GetShowSelectionLayer: Boolean;
begin
  if FSelectionLayer <> nil then
    Result := FSelectionLayer.Visible
  else
    Result := False;
end;

procedure TGridBaseCellEh.SetShowSelectionLayer(const Value: Boolean);
begin
  if FSelectionLayer <> nil then
  begin
    if FSelectionLayer.Visible <> Value then
    begin
      FSelectionLayer.Visible := Value;
      ShowSelectionLayerChanged();
    end;
  end;
end;

procedure TGridBaseCellEh.ShowSelectionLayerChanged;
var
  VGrid: TCustomGridEhCrack;
begin
  VGrid := TCustomGridEhCrack(Grid);
  if FSelectionLayer <> nil then
  begin
    if SelectionLayerActive then
      FSelectionLayer.Fill := VGrid.StylePainter.CellSelectionFill
    else
      FSelectionLayer.Fill := VGrid.StylePainter.CellInactiveSelectionFill;
  end;
end;

procedure TGridBaseCellEh.SetSelectionLayerActive(const Value: Boolean);
begin
  if FSelectionLayerActive <> Value then
  begin
    FSelectionLayerActive := Value;
    ShowSelectionLayerChanged();
//    if FSelectionLayer <> nil then
//    begin
//      if FSelectionLayerActive then
//        FSelectionLayer.Fill.Color := $330080FF
//      else
//        FSelectionLayer.Fill.Color := ColorToGray($330080FF);
//    end;
  end;
end;

{$ENDREGION 'TGridBaseCellEh'}

{ TGridBaseTextCellEh }

{$REGION 'TGridBaseTextCellEh'}
constructor TGridBaseTextCellEh.Create(ACellHolder: TGridBaseCellHolderEh);
begin
  inherited Create(ACellHolder);
end;

destructor TGridBaseTextCellEh.Destroy;
begin
  inherited Destroy;
end;

function TGridBaseTextCellEh.CreateDefaultCellContentControls(AParent: TLaObjectEh): TLaObjectEh;
begin
  Result := inherited CreateDefaultCellContentControls(AParent);
  if Result is TLaTextBlockEh then
    FText := TLaTextBlockEh(Result);
end;

procedure TGridBaseTextCellEh.CreateControls;
begin
  inherited CreateControls;
end;

function TGridBaseTextCellEh.GetText: String;
begin
  if FText <> nil
    then Result := FText.Text
    else Result := '';
end;

procedure TGridBaseTextCellEh.SetText(const Value: String);
begin
  if FText <> nil  then
    FText.Text := Value;
end;
{$ENDREGION 'TGridBaseTextCellEh'}

{ TBaseGridCellManagerEh }

{$REGION 'TBaseGridCellManagerEh'}
constructor TBaseGridCellManagerEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FIsComposeContextMenu := True;
end;

function TBaseGridCellManagerEh.CreateCellHolder: TVPBaseCellHolderEh;
begin
  Result := TGridBaseCellHolderEh.Create(nil, Self);
end;

function TBaseGridCellManagerEh.CreateGridCell(ACellHolder: TGridBaseCellHolderEh): TGridBaseCellEh;
begin
  Result := TGridBaseTextCellEh.Create(ACellHolder);
end;

function TBaseGridCellManagerEh.CreateCustomCellContent(ACell: TGridBaseCellEh; AParent: TLaObjectEh): TLaObjectEh;
var
  ContentParams: TBaseGridCreateCellContentParamsEh;
begin
  ContentParams := CreateCellContentParams();
  try
    if ContentParams <> nil then
    begin
      ContentParams.Init(ACell, AParent);
      HandleCreateCustomCellContent(ContentParams);
      Result := ContentParams.CellContent;
    end else
    begin
      Result := nil;
    end;
  finally
    ContentParams.Free;
  end;
end;

function TBaseGridCellManagerEh.CreateDefaultCellContent(ACell: TGridBaseCellEh; AParent: TLaObjectEh): TLaObjectEh;
begin
  Result := TLaTextBlockEh.CreateWith(AParent, AParent);
  Result.Name := 'DefaultCellContent';
end;

function TBaseGridCellManagerEh.CreateCellContentParams: TBaseGridCreateCellContentParamsEh;
begin
  Result := nil;
end;

procedure TBaseGridCellManagerEh.HandleCreateCustomCellContent(Params: TBaseGridCreateCellContentParamsEh);
begin

end;

procedure TBaseGridCellManagerEh.InitCellHolder(ACell: TVPBaseCellHolderEh);
var
  AGridCellHolder: TGridBaseCellHolderEh;
  AGrid: TCustomGridEhCrack;
  IsDraw: Boolean;
  BorderColor: TAlphaColor;
  IsExtent: Boolean;
begin
  if ACell is TGridBaseCellHolderEh then
  begin
    AGrid := TCustomGridEhCrack(ACell.Grid);
    AGridCellHolder := TGridBaseCellHolderEh(ACell);

    InitCellPositionProps(AGridCellHolder.CellClient);

    AGrid.CheckDrawCellBorder(ACell.ColIndex, ACell.RowIndex, TGridCellBorderTypeEh.Right, IsDraw, BorderColor, IsExtent);
    InitCellSideBorder(AGridCellHolder, TGridCellBorderTypeEh.Right, IsDraw, BorderColor, IsExtent);

    AGrid.CheckDrawCellBorder(ACell.ColIndex, ACell.RowIndex, TGridCellBorderTypeEh.Bottom, IsDraw, BorderColor, IsExtent);
    InitCellSideBorder(AGridCellHolder, TGridCellBorderTypeEh.Bottom, IsDraw, BorderColor, IsExtent);

    AGrid.CheckDrawCellBorder(ACell.ColIndex, ACell.RowIndex, TGridCellBorderTypeEh.Left, IsDraw, BorderColor, IsExtent);
    InitCellSideBorder(AGridCellHolder, TGridCellBorderTypeEh.Left, IsDraw, BorderColor, IsExtent);

    AGrid.CheckDrawCellBorder(ACell.ColIndex, ACell.RowIndex, TGridCellBorderTypeEh.Top, IsDraw, BorderColor, IsExtent);
    InitCellSideBorder(AGridCellHolder, TGridCellBorderTypeEh.Top, IsDraw, BorderColor, IsExtent);

    InitCell(AGridCellHolder.CellClient);
  end;
end;

procedure TBaseGridCellManagerEh.InitCellSideBorder(ACellHolder: TGridBaseCellHolderEh; BorderType: TGridCellBorderTypeEh; IsDraw: Boolean; BorderColor: TAlphaColor; IsExtent: Boolean);
var
  Thickness: Single;
begin
  if IsDraw
    then Thickness := 1
    else Thickness := 0;

  if BorderType = TGridCellBorderTypeEh.Top then
  begin
    ACellHolder.Borders.Top.Thickness := Thickness;
    ACellHolder.Borders.Top.Color := BorderColor;
  end
  else if BorderType = TGridCellBorderTypeEh.Left then
  begin
    ACellHolder.Borders.Left.Thickness := Thickness;
    ACellHolder.Borders.Left.Color := BorderColor;
  end
  else if BorderType = TGridCellBorderTypeEh.Bottom then
  begin
    ACellHolder.Borders.Bottom.Thickness := Thickness;
    ACellHolder.Borders.Bottom.Color := BorderColor;
  end
  else if BorderType = TGridCellBorderTypeEh.Right then
  begin
    ACellHolder.Borders.Right.Thickness := Thickness;
    ACellHolder.Borders.Right.Color := BorderColor;
  end;

end;

procedure TBaseGridCellManagerEh.InitCellPositionProps(ACell: TGridBaseCellEh);
begin

end;

procedure TBaseGridCellManagerEh.InitCell(ACell: TGridBaseCellEh);
var
  InitCellParams: TBaseGridInitCellParamsEh;
begin
  InitCellParams := CreateInitCellParams;
  try
    InitCellParams.Init(ACell.Grid, Self, ACell);
//    InitCellProps();
    DefaultInitCellStyledBackground(InitCellParams);
    DefaultInitCellSelection(InitCellParams);
    ProcessInitCell(InitCellParams);
  finally
    InitCellParams.Free;
  end;
end;

function TBaseGridCellManagerEh.CreateInitCellParams: TBaseGridInitCellParamsEh;
begin
  Result := TBaseGridInitCellParamsEh.Create;
end;

procedure TBaseGridCellManagerEh.ProcessInitCell(Params: TBaseGridInitCellParamsEh);
begin
  HandleInitCell(Params);
  if Params.Handled = False then
    DefaultInitCell(Params);
end;

procedure TBaseGridCellManagerEh.HandleInitCell(Params: TBaseGridInitCellParamsEh);
begin
end;

procedure TBaseGridCellManagerEh.DefaultInitCell(Params: TBaseGridInitCellParamsEh);
begin
  DefaultInitCellProps(Params);
  Params.Handled := True;

  InitCellClient(Params.Cell, Params.Cell.CellClient, Params);
end;

procedure TBaseGridCellManagerEh.DefaultInitCellProps(Params: TBaseGridInitCellParamsEh);
var
  AGrid: TCustomGridEhCrack;
begin
  AGrid := TCustomGridEhCrack(Params.Grid);

  Params.Cell.ShowFocusLayer := Params.IsShowCellFocus;
  Params.Cell.FocusLayerActive := AGrid.ContainsFocus;
  Params.Cell.ShowSelectionLayer := Params.IsShowSelection;
  Params.Cell.SelectionLayerActive := AGrid.ContainsFocus;
end;

procedure TBaseGridCellManagerEh.DefaultInitCellStyledBackground(Params: TBaseGridInitCellParamsEh);
var
  StyledControl: TControl;
begin
  StyledControl := GetBackgroundStyle(Params);
  Params.Cell.BackgroundStyle := StyledControl;
end;

function TBaseGridCellManagerEh.GetBackgroundStyle(AParams: TBaseGridInitCellParamsEh): TControl;
var
  VGrid: TCustomGridEhCrack;
begin
  VGrid := TCustomGridEhCrack(AParams.Grid);
  if AParams.Cell.RowIndex < VGrid.FixedRowCount then
    Result := VGrid.StylePainter.TopFixedCellBackground
  else if AParams.Cell.ColIndex < VGrid.FixedColCount then
    Result := VGrid.StylePainter.TopFixedCellBackground
  else
    Result := nil;
end;

procedure TBaseGridCellManagerEh.DefaultInitCellSelection(Params: TBaseGridInitCellParamsEh);
begin

end;

function TBaseGridCellManagerEh.IsShowFocusLayer(AGrid: TControl; ACell: TGridBaseCellEh): Boolean;
var
  VGrid: TCustomGridEhCrack;
begin
  VGrid := TCustomGridEhCrack(AGrid);
  Result := False;

  if ACell.FocusLayer <> nil then
  begin
    Result := VGrid.IsShowFocusLayerForCell(ACell);
  end;
end;

function TBaseGridCellManagerEh.IsShowSelectionLayer(AGrid: TControl; ACell: TGridBaseCellEh): Boolean;
var
  VGrid: TCustomGridEhCrack;
begin
  VGrid := TCustomGridEhCrack(AGrid);
  Result := False;

  if ACell.SelectionLayer <> nil then
  begin
    Result := VGrid.IsShowSelectionLayerForCell(ACell);
  end;
end;

procedure TBaseGridCellManagerEh.InitCellClient(ACell: TGridBaseCellEh; ACellClient: TLaObjectEh;
  InitCellParams: TBaseGridInitCellParamsEh);
begin
  InitCellClientProps(ACell, ACellClient, InitCellParams);
  InitCellContent(ACell, InitCellParams);
end;

procedure TBaseGridCellManagerEh.InitCellClientProps(ACell: TGridBaseCellEh; ACellClient: TLaObjectEh;
  InitCellParams: TBaseGridInitCellParamsEh);
begin

end;

procedure TBaseGridCellManagerEh.InitCellContent(ACell: TGridBaseCellEh; InitCellParams: TBaseGridInitCellParamsEh);
var
  ContentParams: TBaseGridInitCellContentParamsEh;
begin
  ContentParams := CreateInitCellContentParams();
  ContentParams.Init(ACell, ACell.CellContent, InitCellParams);
  try
    HandleInitCellContent(ContentParams);
    if ContentParams.Handled = False then
    begin
      ContentParams.Init(ACell, ACell.DefaultCellContent, InitCellParams);
      DefaultInitCellContent(ContentParams);
    end;
  finally
    ContentParams.Free;
  end;
end;

function TBaseGridCellManagerEh.CreateInitCellContentParams: TBaseGridInitCellContentParamsEh;
begin
  Result := TBaseGridInitCellContentParamsEh.Create;
end;

procedure TBaseGridCellManagerEh.HandleInitCellContent(Params: TBaseGridInitCellContentParamsEh);
begin
end;

procedure TBaseGridCellManagerEh.DefaultInitCellContent(Params: TBaseGridInitCellContentParamsEh);
var
  TextBlock: TLaTextBlockEh;
var
  AGrid: TCustomGridEhCrack;
begin
  AGrid := TCustomGridEhCrack(Params.Grid);
  if Params.CellContent is TLaTextBlockEh then
  begin
    TextBlock := TLaTextBlockEh(Params.CellContent);
    TextBlock.Text := GetCellContentTextValue(Params);
    TextBlock.FontColor := AGrid.StylePainter.TopFixedCellForegroundColor;
  end;
end;

function TBaseGridCellManagerEh.GetCellContentTextValue(Params: TBaseGridInitCellContentParamsEh): String;
begin
  Result := TCustomGridEhCrack(Params.Grid).GetCellContentTextValue(Params);
end;

function TBaseGridCellManagerEh.GetCellValueParams(AGrid: TControl; ACell: TGridBaseCellEh): TBaseGridCellValueParamsEh;
begin
  Result := CreateCellValueParams(AGrid, ACell);
  Result.ResetAndInit(AGrid, ACell);
end;

function TBaseGridCellManagerEh.CreateCellValueParams(AGrid: TControl; ACell: TGridBaseCellEh): TBaseGridCellValueParamsEh;
begin
  Result := TBaseGridCellValueParamsEh.Create;
end;

procedure TBaseGridCellManagerEh.InitCellValueParams(Params: TBaseGridCellValueParamsEh);
begin
end;

procedure TBaseGridCellManagerEh.ShowContextMenu(ACellParams: TBaseGridCellShowContextMenuParamsEh);
var
  APopupMenu: TCustomPopupMenu;
  AComposedPopupMenu: TComposedPopupMenu;
  AComposeParams: TBaseGridCellComposeContextMenuParamsEh;
begin
  if IsComposeContextMenu then
  begin
    AComposedPopupMenu := TContextMenuManageEh.GetGlobalContextMenu;
    if AComposedPopupMenu.IsReleased = False then Exit;

    AComposedPopupMenu.PrepareComposedMenu;
    try
      AComposeParams := CreateComposeContextMenuParams();
      try
        AComposeParams.Init(ACellParams.Grid, ACellParams.Cell, ACellParams.ControlParams);


        AComposeParams.PopupMenu := AComposedPopupMenu;
        ComposeContextMenu(AComposeParams);

        if AComposeParams.PopupMenu <> nil then
        begin
          APopupMenu := AComposeParams.PopupMenu;
          APopupMenu.PopupComponent := ACellParams.Grid;
          APopupMenu.Popup(Round(ACellParams.ControlParams.ScreenPosition.X),
                           Round(ACellParams.ControlParams.ScreenPosition.Y));
          ACellParams.Handled := True;
        end;
      finally
        AComposeParams.Free;
      end;
    finally
      AComposedPopupMenu.ReleaseComposedMenu;
    end;
  end else
  begin
    if FPopupMenu <> nil then
    begin
      FPopupMenu.PopupComponent := Self;
      FPopupMenu.Popup(ACellParams.ControlParams.ScreenPosition.X, ACellParams.ControlParams.ScreenPosition.Y);
      ACellParams.Handled := True;
    end;
  end;
end;

procedure TBaseGridCellManagerEh.ComposeContextMenu(Params: TBaseGridCellComposeContextMenuParamsEh);
begin
end;

function TBaseGridCellManagerEh.GetCellBaseParams(AGrid: TControl; ACell: TGridBaseCellEh; Params: TControlParamsEh):
  TBaseGridCellBaseParamsEh;
begin
  Result := CreateCellBaseParams(ACell);
  Result.Init(AGrid, ACell);
end;

function TBaseGridCellManagerEh.CreateCellBaseParams(ACell: TGridBaseCellEh): TBaseGridCellBaseParamsEh;
begin
  Result := TBaseGridCellBaseParamsEh.Create;
end;

function TBaseGridCellManagerEh.GetCellContextMenuParams(AGrid: TControl; ACell: TGridBaseCellEh): TBaseGridCellContextMenuParamsEh;
begin
  Result := CreateCellContextMenuParams(AGrid, ACell);
  Result.ResetAndInit(AGrid, ACell);
end;

procedure TBaseGridCellManagerEh.InitCellContextMenuParams(Params: TBaseGridCellContextMenuParamsEh);
begin
end;

procedure TBaseGridCellManagerEh.InitCellEditor(AParams: TBaseGridInitEditorParamsEh);
begin
  HandleInitCellEditor(AParams);
  if AParams.Handled = False then
    DefaultInitCellEditor(AParams);
end;

procedure TBaseGridCellManagerEh.DefaultInitCellEditor(AParams: TBaseGridInitEditorParamsEh);
var
  LaTextEdit: TLaInplaceTextEdit;
begin
  if AParams.Editor is TLaInplaceTextEdit then
  begin
    LaTextEdit := TLaInplaceTextEdit(AParams.Editor);
    LaTextEdit.SetCell(AParams.Cell);
    LaTextEdit.ReadOnly := AParams.EditorParams.EditorReadOnly;
  end;
end;

procedure TBaseGridCellManagerEh.HandleInitCellEditor(AInitEditorParams: TBaseGridInitEditorParamsEh);
begin

end;

function TBaseGridCellManagerEh.CreateCellContextMenuParams(AGrid: TControl; ACell: TGridBaseCellEh): TBaseGridCellContextMenuParamsEh;
begin
  Result := TBaseGridCellContextMenuParamsEh.Create;
end;

procedure TBaseGridCellManagerEh.ProcessCellContextMenuNeeded(Params: TBaseGridCellContextMenuParamsEh);
begin
  ContextMenuNeeded(Params);
end;

procedure TBaseGridCellManagerEh.ContextMenuNeeded(Params: TBaseGridCellContextMenuParamsEh);
begin
end;

function TBaseGridCellManagerEh.CreateComposeContextMenuParams(): TBaseGridCellComposeContextMenuParamsEh;
begin
  Result := TBaseGridCellComposeContextMenuParamsEh.Create;
end;

{$REGION Mouse Procedures}
function TBaseGridCellManagerEh.GetMouseButtonParams(AGrid: TControl; ACell: TGridBaseCellEh; Params: TControlMouseButtonParamsEh): TGridCellMouseButtonParamsEh;
begin
  Result := CreateMouseButtonParams(ACell);
  Result.Init(AGrid, ACell, Params);
end;

function TBaseGridCellManagerEh.GetMouseParams(AGrid: TControl;
  ACell: TGridBaseCellEh; Params: TControlMouseParamsEh): TGridCellMouseParamsEh;
begin
  Result := CreateMouseParams(ACell);
  Result.Init(AGrid, ACell, Params);
end;

function TBaseGridCellManagerEh.CreateMouseButtonParams(ACell: TGridBaseCellEh): TGridCellMouseButtonParamsEh;
begin
  Result := TGridCellMouseButtonParamsEh.Create;
end;

function TBaseGridCellManagerEh.CreateMouseParams(ACell: TGridBaseCellEh): TGridCellMouseParamsEh;
begin
  Result := TGridCellMouseParamsEh.Create;
end;

procedure TBaseGridCellManagerEh.ProcessControlMouseDown(AGrid: TControl; ACell: TGridBaseCellEh; Params: TControlMouseButtonParamsEh);
var
  CellMouseParams: TGridCellMouseButtonParamsEh;
begin
  CellMouseParams := GetMouseButtonParams(AGrid, ACell, Params);
  try
    HandleMouseDownEvent(CellMouseParams);
    if not CellMouseParams.Handled then
      MouseDown(CellMouseParams);
    Params.Handled := CellMouseParams.Handled;
  finally
    CellMouseParams.Free;
  end;
end;

procedure TBaseGridCellManagerEh.MouseDown(Params: TGridCellMouseButtonParamsEh);
begin
end;

procedure TBaseGridCellManagerEh.HandleMouseDownEvent(Params: TGridCellMouseButtonParamsEh);
begin
end;

function TBaseGridCellManagerEh.GetMouseMoveParams(AGrid: TControl; ACell: TGridBaseCellEh; Params: TControlMouseParamsEh): TGridCellMouseParamsEh;
begin
  Result := CreateMouseMoveParams(ACell);
end;

function TBaseGridCellManagerEh.CreateMouseMoveParams(ACell: TGridBaseCellEh): TGridCellMouseParamsEh;
begin
  Result := TGridCellMouseParamsEh.Create;
end;

procedure TBaseGridCellManagerEh.ProcessMouseMove(Params: TGridCellMouseParamsEh);
begin
  MouseMove(Params);
end;

procedure TBaseGridCellManagerEh.ProcessControlMouseUp(Params: TGridCellMouseButtonParamsEh);
begin
  MouseUp(Params);
end;

procedure TBaseGridCellManagerEh.MouseUp(Params: TGridCellMouseButtonParamsEh);
begin
end;

procedure TBaseGridCellManagerEh.ProcessControlMouseClick(AGrid: TControl; ACell: TGridBaseCellEh; Params: TControlMouseButtonParamsEh);
var
  CellMouseParams: TGridCellMouseButtonParamsEh;
begin
  CellMouseParams := GetMouseButtonParams(AGrid, ACell, Params);
  try
    HandleMouseClickEvent(CellMouseParams);
    if not CellMouseParams.Handled then
      MouseClick(CellMouseParams);
    Params.Handled := CellMouseParams.Handled;
  finally
    CellMouseParams.Free;
  end;
end;

procedure TBaseGridCellManagerEh.ProcessDblClick(AGrid: TControl;
  ACell: TGridBaseCellEh; Params: TControlParamsEh);
begin

end;

procedure TBaseGridCellManagerEh.HandleMouseClickEvent(Params: TGridCellMouseButtonParamsEh);
begin
end;

procedure TBaseGridCellManagerEh.MouseClick(Params: TGridCellMouseButtonParamsEh);
begin
end;

procedure TBaseGridCellManagerEh.ProcessControlMouseMove(AGrid: TControl;
  ACell: TGridBaseCellEh; Params: TControlMouseParamsEh);
var
  CellMouseParams: TGridCellMouseParamsEh;
begin
  CellMouseParams := GetMouseParams(AGrid, ACell, Params);
  try
    HandleMouseMoveEvent(CellMouseParams);
    if not CellMouseParams.Handled then
      MouseMove(CellMouseParams);
    Params.Handled := CellMouseParams.Handled;
  finally
    CellMouseParams.Free;
  end;
end;

procedure TBaseGridCellManagerEh.HandleMouseMoveEvent(Params: TGridCellMouseParamsEh);
begin

end;

procedure TBaseGridCellManagerEh.MouseMove(Params: TGridCellMouseParamsEh);
begin

end;

procedure TBaseGridCellManagerEh.ProcessControlMouseEnter(AGrid: TControl; ACell: TGridBaseCellEh; Params: TControlParamsEh);
var
  CellBaseParams: TBaseGridCellBaseParamsEh;
begin
  CellBaseParams := GetCellBaseParams(AGrid, ACell, Params);
  try
    HandleMouseEnterEvent(CellBaseParams);
    MouseEnter(CellBaseParams);
  finally
    CellBaseParams.Free;
  end;
end;

procedure TBaseGridCellManagerEh.HandleMouseEnterEvent(Params: TBaseGridCellBaseParamsEh);
begin

end;

procedure TBaseGridCellManagerEh.MouseEnter(Params: TBaseGridCellBaseParamsEh);
begin

end;

procedure TBaseGridCellManagerEh.ProcessControlMouseLeave(AGrid: TControl; ACell: TGridBaseCellEh; Params: TControlParamsEh);
var
  VGrid: TCustomGridEhCrack;
begin
  VGrid := TCustomGridEhCrack(AGrid);
  VGrid.UpdateHotTrackCellPos(-1, -1);
end;

{$ENDREGION Mouse Procedures}

function TBaseGridCellManagerEh.GetCellKeyDownParams(AGrid: TControl;
  AColIndex, ARowIndex, AAreaColIndex, AAreaRowIndex: Integer;
  AKey: Word; AKeyChar: WideChar; AShift: TShiftState): TBaseGridCellKeyDownParamsEh;
begin
  Result := CreateCellKeyDownParams(AGrid, AColIndex, ARowIndex, AAreaColIndex, AAreaRowIndex);
  Result.ResetAndInit(AGrid, Self, AColIndex, ARowIndex, AAreaColIndex, AAreaRowIndex, AKey, AKeyChar, AShift);
end;

function TBaseGridCellManagerEh.CreateCellKeyDownParams(AGrid: TControl; AColIndex,
  ARowIndex, AAreaColIndex, AAreaRowIndex: Integer): TBaseGridCellKeyDownParamsEh;
begin
  Result := TBaseGridCellKeyDownParamsEh.Create;
end;

procedure TBaseGridCellManagerEh.ProcessKeyDown(Params: TBaseGridCellKeyDownParamsEh);
begin

end;

function TBaseGridCellManagerEh.CanShowEditor(AGrid: TControl): Boolean;
begin
  Result := True;
end;

function TBaseGridCellManagerEh.GetCellEditParams(AGrid: TControl; ACell: TGridBaseCellEh): TBaseGridCellEditParamsEh;
begin
  Result := CreateCellEditParams();
  Result.Init(AGrid, Self, ACell.ColIndex, ACell.RowIndex, ACell.AreaColIndex, ACell.AreaRowIndex);
  InitCellEditParams(Result);
end;

procedure TBaseGridCellManagerEh.InitCellEditParams(AParams: TBaseGridCellEditParamsEh);
begin
  AParams.EditorValue := TValue.Empty;
  AParams.EditorReadOnly := False;
end;

function TBaseGridCellManagerEh.CreateCellEditParams(): TBaseGridCellEditParamsEh;
begin
  Result := TBaseGridCellEditParamsEh.Create();
end;

function TBaseGridCellManagerEh.GetInitEditorParams(AGrid: TControl; ACell: TGridBaseCellEh; AEditor: TLaObjectEh; AEditParams: TBaseGridCellEditParamsEh): TBaseGridInitEditorParamsEh;
begin
  Result := CreateInitEditorParams();
  Result.Init(AGrid, ACell, AEditor, AEditParams);
end;

function TBaseGridCellManagerEh.CreateInitEditorParams(): TBaseGridInitEditorParamsEh;
begin
  Result := TBaseGridInitEditorParamsEh.Create();
end;
{$ENDREGION 'TBaseGridCellManagerEh'}

{ TGridCellMouseParamsEh }

{$REGION 'TGridCellMouseParamsEh'}
procedure TGridCellMouseParamsEh.Init(AGrid: TControl; ACell: TGridBaseCellEh; ABaseParams: TControlMouseParamsEh);
begin
  FGrid := AGrid;
  FCell := ACell;
  FColIndex := ACell.ColIndex;
  FRowIndex := ACell.RowIndex;
  FAreaColIndex := ACell.AreaColIndex;
  FAreaRowIndex := ACell.AreaRowIndex;
  FBaseParams := ABaseParams;
end;

procedure TGridCellMouseParamsEh.Init(AGrid: TControl; AColIndex: Integer; ARowIndex: Integer;
  AAreaColIndex: Integer; AAreaRowIndex: Integer; const ACellRect: TRect; AInCellX, AInCellY: Integer;
  ABaseParams: TControlMouseParamsEh);
begin
  FGrid := AGrid;
  FColIndex := AColIndex;
  FRowIndex := ARowIndex;
  FAreaColIndex := AAreaColIndex;
  FAreaRowIndex := AAreaRowIndex;
  FBaseParams := ABaseParams;
  FCellRect := ACellRect;
  FInCellX := AInCellX;
  FInCellY := AInCellY;
end;
{$ENDREGION 'TGridCellMouseParamsEh'}

{ TGridCellMouseButtonParamsEh }

{$REGION 'TGridCellMouseButtonParamsEh'}
procedure TGridCellMouseButtonParamsEh.Init(AGrid: TControl; ACell: TGridBaseCellEh; Params: TControlMouseButtonParamsEh);
begin
  inherited Init(AGrid, ACell, Params);
end;

function TGridCellMouseButtonParamsEh.GetBaseParams: TControlMouseButtonParamsEh;
begin
  Result := TControlMouseButtonParamsEh(inherited BaseParams);
end;
{$ENDREGION 'TGridCellMouseButtonParamsEh'}

{ TBaseGridCellBaseParamsEh }

{$REGION 'TBaseGridCellBaseParamsEh'}
constructor TBaseGridCellBaseParamsEh.Create;
begin
end;

procedure TBaseGridCellBaseParamsEh.Init(AGrid: TControl; ACell: TGridBaseCellEh);
begin
  FGrid := AGrid;
  FCell := ACell;
end;

procedure TBaseGridCellBaseParamsEh.Reset(AGrid: TControl; ACell: TGridBaseCellEh);
begin
  FGrid := AGrid;
  FCell := ACell;
end;

function TBaseGridCellBaseParamsEh.GetAreaColIndex: Integer;
begin
  Result := Cell.AreaColIndex;
end;

function TBaseGridCellBaseParamsEh.GetAreaRowIndex: Integer;
begin
  Result := Cell.AreaRowIndex;
end;

function TBaseGridCellBaseParamsEh.GetCellManager: TBaseGridCellManagerEh;
begin
  Result := Cell.CellManager;
end;

function TBaseGridCellBaseParamsEh.GetColIndex: Integer;
begin
  Result := Cell.ColIndex;
end;

function TBaseGridCellBaseParamsEh.GetRowIndex: Integer;
begin
  Result := Cell.RowIndex;
end;
{$ENDREGION 'TBaseGridCellBaseParamsEh'}

{ TBaseGridCellPosBaseParamsEh }

{$REGION 'TBaseGridCellPosBaseParamsEh'}
constructor TBaseGridCellPosBaseParamsEh.Create;
begin
end;

procedure TBaseGridCellPosBaseParamsEh.Init(AGrid: TControl;
  ACellManager: TBaseGridCellManagerEh; AColIndex, ARowIndex, AAreaColIndex,
  AAreaRowIndex: Integer);
begin
  FGrid := AGrid;
  FCellManager := ACellManager;
  FColIndex := AColIndex;
  FRowIndex := ARowIndex;
  FAreaColIndex := AAreaColIndex;
  FAreaRowIndex := AAreaRowIndex;
end;

procedure TBaseGridCellPosBaseParamsEh.Reset(AGrid: TControl;
  ACellManager: TBaseGridCellManagerEh; AColIndex, ARowIndex, AAreaColIndex,
  AAreaRowIndex: Integer);
begin
  FGrid := AGrid;
  FCellManager := ACellManager;
  FColIndex := AColIndex;
  FRowIndex := ARowIndex;
  FAreaColIndex := AAreaColIndex;
  FAreaRowIndex := AAreaRowIndex;
end;
{$ENDREGION 'TBaseGridCellPosBaseParamsEh'}

{ TBaseGridCellValueParams }

{$REGION 'TBaseGridCellValueParamsEh'}
constructor TBaseGridCellValueParamsEh.Create;
begin
end;

destructor TBaseGridCellValueParamsEh.Destroy;
begin
  inherited Destroy;
end;

procedure TBaseGridCellValueParamsEh.Reset(AGrid: TControl; ACell: TGridBaseCellEh);
begin
  inherited Reset(AGrid, ACell);
end;

procedure TBaseGridCellValueParamsEh.ResetAndInit(AGrid: TControl; ACell: TGridBaseCellEh);
begin
  Reset(AGrid, ACell);
  CellManager.InitCellValueParams(Self);
end;
{$ENDREGION 'TBaseGridCellValueParamsEh'}

{ TBaseGridCellContextMenuParams }

{$REGION 'TBaseGridCellContextMenuParamsEh'}
procedure TBaseGridCellContextMenuParamsEh.ResetAndInit(AGrid: TControl; ACell: TGridBaseCellEh);
begin
  Reset(AGrid, ACell);
  CellManager.InitCellContextMenuParams(Self);
end;
{$ENDREGION 'TBaseGridCellContextMenuParamsEh'}

{ TBaseGridCellKeyDownParams }

{$REGION 'TBaseGridCellKeyDownParamsEh'}
constructor TBaseGridCellKeyDownParamsEh.Create;
begin
end;

destructor TBaseGridCellKeyDownParamsEh.Destroy;
begin
  inherited Destroy;
end;

procedure TBaseGridCellKeyDownParamsEh.Reset(AGrid: TControl;
  ACellManager: TBaseGridCellManagerEh; AColIndex, ARowIndex, AAreaColIndex,
  AAreaRowIndex: Integer;
  AKey: Word; AKeyChar: WideChar; AShift: TShiftState);
begin
  inherited Reset(AGrid, ACellManager, AColIndex, ARowIndex, AAreaColIndex, AAreaRowIndex);
  FKey := AKey;
  FKeyChar := AKeyChar;
  FShift := AShift;
end;

procedure TBaseGridCellKeyDownParamsEh.ResetAndInit(AGrid: TControl;
  ACellManager: TBaseGridCellManagerEh; AColIndex, ARowIndex, AAreaColIndex,
  AAreaRowIndex: Integer;
  AKey: Word; AKeyChar: WideChar; AShift: TShiftState);
begin
  Reset(AGrid, ACellManager, AColIndex, ARowIndex, AAreaColIndex, AAreaRowIndex, AKey, AKeyChar, AShift);
end;
{$ENDREGION 'TBaseGridCellKeyDownParamsEh'}

{ TBaseGridCellShowContextMenuParamsEh }

{$REGION 'TBaseGridCellShowContextMenuParamsEh'}
constructor TBaseGridCellShowContextMenuParamsEh.Create;
begin
  inherited Create;
end;

procedure TBaseGridCellShowContextMenuParamsEh.Init(AGrid: TControl; ACell: TGridBaseCellEh;
  AControlParams: TControlShowContextMenuParamsEh);
begin
  FGrid := AGrid;
  FCell := ACell;
  FControlParams := AControlParams;
end;

function TBaseGridCellShowContextMenuParamsEh.GetAreaColIndex: Integer;
begin
  Result := Cell.AreaColIndex;
end;

function TBaseGridCellShowContextMenuParamsEh.GetAreaRowIndex: Integer;
begin
  Result := Cell.AreaRowIndex;
end;

function TBaseGridCellShowContextMenuParamsEh.GetCellManager: TBaseGridCellManagerEh;
begin
  Result := Cell.CellManager;
end;

function TBaseGridCellShowContextMenuParamsEh.GetColIndex: Integer;
begin
  Result := Cell.ColIndex;
end;

function TBaseGridCellShowContextMenuParamsEh.GetRowIndex: Integer;
begin
  Result := Cell.RowIndex;
end;
{$ENDREGION 'TBaseGridCellShowContextMenuParamsEh'}

{ TBaseGridCellComposeContextMenuParamsEh }

{$REGION 'TBaseGridCellComposeContextMenuParamsEh'}
procedure TBaseGridCellComposeContextMenuParamsEh.SetPopupMenu(const Value: TPopupMenu);
begin
  FPopupMenu := Value;
  if FPopupMenu is TComposedPopupMenu then
    FComposedPopupMenu := TComposedPopupMenu(FPopupMenu)
  else
    FComposedPopupMenu := nil;
end;
{$ENDREGION 'TBaseGridCellComposeContextMenuParamsEh'}

{ TBaseGridInitCellContentParamsEh }

{$REGION 'TBaseGridInitCellContentParamsEh'}
procedure TBaseGridInitCellContentParamsEh.Init(ACell: TGridBaseCellEh; ACellContent: TLaObjectEh;
  AInitCellParams: TBaseGridInitCellParamsEh);
begin
  FCell := ACell;
  FCellContent := ACellContent;
  FInitCellParams := AInitCellParams;
end;

procedure TBaseGridInitCellContentParamsEh.DefaultInitCellContent;
begin
  Init(Cell, Cell.DefaultCellContent, InitCellParams);
  Cell.CellManager.DefaultInitCellContent(Self);
end;

function TBaseGridInitCellContentParamsEh.GetCell: TGridBaseCellEh;
begin
  Result := FCell;
end;

function TBaseGridInitCellContentParamsEh.GetCellManager: TVPBaseCellManagerEh;
begin
  Result := FCell.CellManager;
end;

function TBaseGridInitCellContentParamsEh.GetGrid: TControl;
begin
  Result := FCell.Grid;
end;

function TBaseGridInitCellContentParamsEh.GetCellContent: TLaObjectEh;
begin
  Result := FCellContent;
end;
{$ENDREGION 'TBaseGridInitCellContentParamsEh'}

{ TBaseGridInitCellParamsEh }

{$REGION 'TBaseGridInitCellParamsEh'}
procedure TBaseGridInitCellParamsEh.DefaultInitCell;
begin
  CellManager.DefaultInitCell(Self);
end;

procedure TBaseGridInitCellParamsEh.Init(AGrid: TControl; ACellManager: TBaseGridCellManagerEh; ACell: TGridBaseCellEh);
var
  VGrid: TCustomGridEhCrack;
begin
  VGrid := TCustomGridEhCrack(AGrid);
  FGrid := AGrid;
  FCellManager := ACellManager;
  FCell := ACell;
  FIsShowCellFocus := ACellManager.IsShowFocusLayer(AGrid, ACell);
  FIsFocusActive := VGrid.ContainsFocus();
  FIsShowSelection := ACellManager.IsShowSelectionLayer(AGrid, ACell);
  FIsSelectionActive := VGrid.ContainsFocus();
end;

{$ENDREGION 'TBaseGridInitCellParamsEh'}

{ TBaseGridCreateCellContentParamsEh }

{$REGION 'TBaseGridCreateCellContentParamsEh'}
function TBaseGridCreateCellContentParamsEh.DefaultCreateCellContent(AContentParent: TLaObjectEh): TLaObjectEh;
begin
  Result := Cell.CreateDefaultCellContent(AContentParent);
end;

procedure TBaseGridCreateCellContentParamsEh.Init(ACell: TGridBaseCellEh; AParent: TLaObjectEh);
begin
  FCell := ACell;
  FContentParent := AParent;
end;

function TBaseGridCreateCellContentParamsEh.GetGrid: TControl;
begin
  Result := Cell.Grid;
end;
{$ENDREGION 'TBaseGridCreateCellContentParamsEh'}

{ TBaseGridInitEditorParamsEh }

{$REGION 'TBaseGridInitEditorParamsEh'}
procedure TBaseGridCellEditParamsEh.Init(AGrid: TControl; ACellManager: TBaseGridCellManagerEh;
  AColIndex: Integer; ARowIndex: Integer; AAreaColIndex: Integer; AAreaRowIndex: Integer);
begin
  inherited Init(AGrid, ACellManager, AColIndex, ARowIndex, AAreaColIndex, AAreaRowIndex);
  FEditorValue := TValue.Empty;
  FEditorReadOnly := False;
end;

procedure TBaseGridInitEditorParamsEh.DefaultInitEditor();
begin
  CellManager.DefaultInitCellEditor(Self);
end;
{$ENDREGION 'TBaseGridInitEditorParamsEh'}

{ TBaseGridInitEditorEh }

{$REGION 'TBaseGridInitEditorParamsEh'}
procedure TBaseGridInitEditorParamsEh.Init(AGrid: TControl; ACell: TGridBaseCellEh;
  AEditor: TLaObjectEh; AEditorParams: TBaseGridCellEditParamsEh);
begin
  inherited Init(AGrid, ACell);
  FCell := ACell;
  FEditor := AEditor;
  FEditorParams := AEditorParams;
  FHandled := False;
end;
{$ENDREGION 'TBaseGridInitEditorParamsEh'}

{$REGION 'TGridCellTreeViewAreaControlEh'}

constructor TGridCellTreeViewAreaControlEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLevelWidth := 14;
end;

destructor TGridCellTreeViewAreaControlEh.Destroy;
begin
  inherited Destroy;
end;

function TGridCellTreeViewAreaControlEh.GetSignVisible: Boolean;
begin
  if FTreeSignImage = nil
    then Result := False
    else Result := FTreeSignImage.Visible;
end;

procedure TGridCellTreeViewAreaControlEh.SetSignVisible(const Value: Boolean);
begin
  if FTreeSignImage <> nil then
    FTreeSignImage.Visible := Value;
end;

procedure TGridCellTreeViewAreaControlEh.SetLevel(const Value: Integer);
begin
  if FLevel <> Value then
  begin
    FLevel := Value;
    FIndentPanel.Width := FLevel * FLevelWidth;
    FTreeSignPanel.Width := FLevelWidth;
  end;
end;

procedure TGridCellTreeViewAreaControlEh.SetLevelWidth(const Value: Integer);
begin
  if FLevelWidth <> Value then
  begin
    FLevelWidth := Value;
    if FIndentPanel <> nil then
      FIndentPanel.Width := FLevel * FLevelWidth;
    if FTreeSignPanel <> nil then
      FTreeSignPanel.Width := FLevelWidth;
  end;
end;

procedure TGridCellTreeViewAreaControlEh.SetSignState(const Value: TTreeSignStateEh);
begin
  if FSignState <> Value then
  begin
    FSignState := Value;
    if FTreeSignImage <> nil then
    begin
      if FSignState = TTreeSignStateEh.Expanded then
        FTreeSignImage.MultiResBitmap := EhLibImageResources.ExpanderSignExpanded
      else
        FTreeSignImage.MultiResBitmap := EhLibImageResources.ExpanderSignCollapsed;
    end;
  end;
end;

procedure TGridCellTreeViewAreaControlEh.CheckCreateControls;
begin
  if FControlsCreated = False then
  begin
    CreateControls;
    FControlsCreated := True;
  end;
end;

procedure TGridCellTreeViewAreaControlEh.CreateControls;
begin
  Orientation := TLaOrientationEh.Horizontal;
//  Margins.Rect := TRectF.Create(1, 2, 1, 2);

  with TLaLayoutPanelEh.CreateWith(RefSelf, RefSelf) do
  begin
    Width := 0;
    FIndentPanel := RefSelf;
  end;

  with TLaLayoutPanelEh.CreateWith(RefSelf, RefSelf) do
  begin
//    Margins.Rect := TRectF.Create(2, 1, 2, 1);
    VertAlignment := TLaVertAlignmentEh.Center;
    HorzAlignment := TLaHorzAlignmentEh.Center;
    Width := 16;
    Height := 14;
    FTreeSignPanel := RefSelf;
    FTreeSignPanel.OnMouseDown := FOnTreeSignMouseDown;
    HitTest := True;

    FTreeSignImage := TLaControlsGenericHelper.CreateControlWith<TImage>(RefSelf, RefSelf);
    FTreeSignImage := TImage(FTreeSignImage.RefSelf);
    with FTreeSignImage do
    begin
      WrapMode := TImageWrapMode.Center;
      MultiResBitmap := nil;
      HitTest := False;
      Locked := True;
      MultiResBitmap := EhLibImageResources.ExpanderSignExpanded;
      Visible := True;
    end;
  end;
end;

function TGridCellTreeViewAreaControlEh.GetOnTreeSignMouseDown: TControlMouseButtonEventEh;
begin
  Result := FOnTreeSignMouseDown;
end;

procedure TGridCellTreeViewAreaControlEh.SetOnTreeSignMouseDown(const Value: TControlMouseButtonEventEh);
begin
  FOnTreeSignMouseDown := Value;
  if FTreeSignPanel <> nil then
    FTreeSignPanel.OnMouseDown := Value;
end;

procedure TGridCellTreeViewAreaControlEh.SetRightBorderColor(
  const Value: TAlphaColor);
begin
  if FRightBorderColor <> Value then
  begin
    FRightBorderColor := Value;
    Borders.Right.Color := FRightBorderColor;
  end;
end;

procedure TGridCellTreeViewAreaControlEh.SetRightBorderVisible(
  const Value: Boolean);
begin
  if FRightBorderVisible <> Value then
  begin
    FRightBorderVisible := Value;
    if FRightBorderVisible
      then Borders.Right.Thickness := 1
      else Borders.Right.Thickness := 0;
  end;
end;

{$ENDREGION 'TGridCellTreeViewAreaControlEh'}

{ TGridCellTreeViewAreaParamsEh }

{$REGION 'TGridCellTreeViewAreaParamsEh'}
procedure TGridCellTreeViewAreaParamsEh.Init(AGrid: TControl;
  ATreeAreaVisible: Boolean; ALevelWidth, ALevel: Integer;
  ASignState: TTreeSignStateEh; ASignVisible: Boolean);
begin
  FGrid := AGrid;

  FTreeAreaVisible := ATreeAreaVisible;
  FLevel := ALevel;
  FLevelWidth := ALevelWidth;
  FSignState := ASignState;
  FSignVisible := ASignVisible;
end;
{$ENDREGION 'TGridCellTreeViewAreaParamsEh'}

end.
