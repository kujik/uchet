{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{                  EhLibFmx.DataGrids                   }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataGrids;

interface

{$SCOPEDENUMS ON}

{$REGION 'uses'}
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

  EhLibFmx.DataGrid.Titles,
  EhLibFmx.DataGrid.DataCells,

  EhLibFmx.DataGrid.IndicatorColumns,
  EhLibFmx.DataGrid.IndicatorTitles,
  EhLibFmx.DataGrid.Columns,
  EhLibFmx.DataGrid.Footers,
  EhLibFmx.DataGrid.ToolControls,
  EhLibFmx.DataGrid.GridManagers,
  EhLibFmx.DataGrid.ComplexTitles,
  EhLibFmx.DataGrid.SearchPanels,
  EhLibFmx.DataGrid.Rows,

  EhLibFmx.ToolControls,
  EhLibFmx.Grid.InplaceEditors,
  EhLibFmx.Platform,
  EhLibFmx.Types,
  EhLibFmx.LaHostVirtualPanels,
  EhLibFmx.Grid.ToolControls,
  EhLibFmx.CustomDataGrids,
  EhLibFmx.LaObjects,
  EhLibFmx.LaControls,
  EhLibFmx.LaPanels
  ;
{$ENDREGION 'uses'}

type
  TDataGridColumnEh = class;
  TDataGridStringColumnEh = class;
  TDataGridEh = class;
  TDataGridColumnFootersEh = class;

{ TDataGridEventParamsEh }

  TDataGridEventParamsEh = class(TPersistent)
  private
    FGrid: TDataGridEh;
  public
    constructor Create;
    procedure Init(AGrid: TDataGridEh);

    property Grid: TDataGridEh read FGrid;
  end;

{ TDataGridColumnWidthChangedParamsEh  }

  TDataGridColumnWidthChangedParamsEh = class(TDataGridEventParamsEh)
  private
    FColumn: TDataGridBaseColumnEh;
  public
    procedure Init(AGrid: TDataGridEh; AColumn: TDataGridBaseColumnEh);
    property Column: TDataGridBaseColumnEh read FColumn;
  end;

{ TDataGridGetDataCellValueParamsEh }

  TDataGridDataCellGetValueParamsEh = class(TDataAxisGridGetBarValueParamsEh)
  private
    function GetColumn: TDataGridBaseColumnEh;
    function GetRow: TDataGridRowEh;
    function GetGrid: TDataGridEh;
  public
    property Column: TDataGridBaseColumnEh read GetColumn;
    property Row: TDataGridRowEh read GetRow;
    property Grid: TDataGridEh read GetGrid;
  end;

{ TDataGridDataCellSetValueParamsEh }

  TDataGridDataCellSetValueParamsEh = class(TDataAxisGridSetBarValueParamsEh)
  private
    function GetColumn: TDataGridBaseColumnEh;
    function GetRow: TDataGridRowEh;
    function GetGrid: TDataGridEh;
  public
    property Column: TDataGridBaseColumnEh read GetColumn;
    property Row: TDataGridRowEh read GetRow;
    property Grid: TDataGridEh read GetGrid;
  end;

{ TDataGridDataCellGetDisplayTextParamsEh }

  TDataGridDataCellGetDisplayTextParamsEh = class (TDataAxisGridGetDisplayTextParamsEh)
  private
    function GetGrid: TDataGridEh;
    function GetColumn: TDataGridBaseColumnEh;
  public
    property Column: TDataGridBaseColumnEh read GetColumn;
    property Grid: TDataGridEh read GetGrid;
  end;

{ TDataGridDataCellStyleParamsEh }

  TDataGridDataCellStyleParamsEh = class(TBaseDataGridDataCellStyleParamsEh)
  private
    function GetGrid: TDataGridEh;
  public
    property Grid: TDataGridEh read GetGrid;
  end;

{ TDataGridStringDataCellStyleParamsEh }

  TDataGridStringDataCellStyleParamsEh = class(TDataGridDataCellStyleParamsEh)
  private
    function GetTrimming: TTextTrimming;
    function GetWordWrap: Boolean;
    procedure SetTrimming(const Value: TTextTrimming);
    procedure SetWordWrap(const Value: Boolean);
    function GetFormattedRanges: TList<TLaFormattedTextRangeEh>;
  public
    property WordWrap: Boolean read GetWordWrap write SetWordWrap;
    property Trimming: TTextTrimming read GetTrimming write SetTrimming;
    property FormattedRanges: TList<TLaFormattedTextRangeEh> read GetFormattedRanges;
  end;

{ TDataGridDataCellKeyDownParamsEh }

  TDataGridDataCellKeyDownParamsEh = class(TBaseGridCellKeyDownParamsEh)
  private
    FColumn: TDataGridBaseColumnEh;
    FRow: TDataGridRowEh;

    function GetGrid: TDataGridEh;
  protected
    procedure Reset(AGrid: TControl; ACellManager: TBaseGridCellManagerEh; AColIndex: Integer; ARowIndex: Integer; AAreaColIndex: Integer; AAreaRowIndex: Integer; AKey: Word; AKeyChar: WideChar; AShift: TShiftState); override;

  public

    property Column: TDataGridBaseColumnEh read FColumn;
    property Row: TDataGridRowEh read FRow;
    property Grid: TDataGridEh read GetGrid;
  end;

{ TDataGridDataCellMouseButtonParamsEh }

  TDataGridDataCellMouseButtonParamsEh = class(TPersistent)
  private
    FAxisCellParams: TDataAxisCellMouseButtonParamsEh;
    function GetGrid: TDataGridEh;
    function GetColumn: TDataGridBaseColumnEh;
    function GetRow: TDataGridRowEh;
    function GetCell: TGridBaseCellEh;
    function GetHandled: Boolean;
    procedure SetHandled(const Value: Boolean);
    function GetButton: TMouseButton;
    function GetShift: TShiftState;
  protected
    procedure Init(AAxisCellParams: TDataAxisCellMouseButtonParamsEh); virtual;

  public
    property AxisCellParams: TDataAxisCellMouseButtonParamsEh read FAxisCellParams;
    property Grid: TDataGridEh read GetGrid;
    property Column: TDataGridBaseColumnEh read GetColumn;
    property Row: TDataGridRowEh read GetRow;
    property Button: TMouseButton read GetButton;
    property Shift: TShiftState read GetShift;
    property Cell: TGridBaseCellEh read GetCell;
    property Handled: Boolean read GetHandled write SetHandled;
  end;

{ TDataGridFooterCalcInitDataParamsEh }

  TDataGridFooterCalcInitDataParamsEh = class(TBaseDataGridFooterCalcInitDataParamsEh)
  private
    function GetGrid: TDataGridEh;
    function GetColumn: TDataGridColumnEh;
  public
    property Grid: TDataGridEh read GetGrid;
    property Column: TDataGridColumnEh read GetColumn;
  end;

{ TDataGridFooterCalcStepDataParamsEh }

  TDataGridFooterCalcStepDataParamsEh = class(TBaseDataGridFooterCalcStepDataParamsEh)
  private
    function GetGrid: TDataGridEh;
    function GetColumn: TDataGridColumnEh;
  public
    property Grid: TDataGridEh read GetGrid;
    property Column: TDataGridColumnEh read GetColumn;
  end;

{ TDataGridFooterCalcFinalDataParamsEh }

  TDataGridFooterCalcFinalDataParamsEh = class(TBaseDataGridFooterCalcFinalDataParamsEh)
  private
    function GetGrid: TDataGridEh;
    function GetColumn: TDataGridColumnEh;
  public
    property Grid: TDataGridEh read GetGrid;
    property Column: TDataGridColumnEh read GetColumn;
  end;

{ TBaseDataGridFooterGetDisplayTextParamsEh  }

  TDataGridFooterGetDisplayTextParamsEh = class(TBaseDataGridFooterGetDisplayTextParamsEh)
  private
    function GetGrid: TDataGridEh;
    function GetColumn: TDataGridColumnEh;
  public
    property Grid: TDataGridEh read GetGrid;
    property Column: TDataGridColumnEh read GetColumn;
  end;

{ TDataGridCanSelectRowParamsEh }

  TDataGridCanSelectRowParamsEh = class(TCustomDataGridCanSelectRowParamsEh)
  private
    function GetGrid: TDataGridEh;
  public
    property Grid: TDataGridEh read GetGrid;
  end;

{ TDataGridGetDataCellManagerParamsEh }

  TDataGridGetDataCellManagerParamsEh = class(TBaseDataGridGetDataCellManagerParamsEh)
  private
    function GetGrid: TDataGridEh;
  public
    property Grid: TDataGridEh read GetGrid;
  end;

{ TBaseDataGridInitDataCellContentParamsEh }

  TDataGridInitDataCellContentParamsEh = class(TPersistent)
  private
    FAxisCellParams: TDataAxisInitCellContentParamsEh;
    FInitCellParams: TBaseGridInitCellParamsEh;

    function GetGrid: TDataGridEh;
    function GetColumn: TDataGridBaseColumnEh;
    function GetRow: TDataGridRowEh;
    function GetStyleParams: TDataAxisCellStyleParamsEh;
    function GetCell: TGridBaseCellEh;
    function GetCellContent: TLaObjectEh;
    function GetCellManager: TVPBaseCellManagerEh;
    function GetHandled: Boolean;
    procedure SetHandled(const Value: Boolean);
  public
    procedure Init(AAxisCellParams: TDataAxisInitCellContentParamsEh); virtual;

    property Grid: TDataGridEh read GetGrid;
    property Column: TDataGridBaseColumnEh read GetColumn;
    property Row: TDataGridRowEh read GetRow;
    property StyleParams: TDataAxisCellStyleParamsEh read GetStyleParams;

    property CellManager: TVPBaseCellManagerEh read GetCellManager;
    property Cell: TGridBaseCellEh read GetCell;
    property CellContent: TLaObjectEh  read GetCellContent;
    property InitCellParams: TBaseGridInitCellParamsEh read FInitCellParams;
    property Handled: Boolean read GetHandled write SetHandled;
  end;

{ TDataGridCreateDataCellContentParamsEh }

  TDataGridCreateDataCellContentParamsEh = class(TPersistent)
  private
    FAxisCellParams: TDataAxisCreateCellContentParamsEh;
    function GetGrid: TDataGridEh;
    function GetCell: TGridBaseCellEh;
    function GetCellContent: TLaObjectEh;
    function GetContentParent: TLaObjectEh;
    procedure SetCellContent(const Value: TLaObjectEh);
  public
    procedure Init(AAxisCellParams: TDataAxisCreateCellContentParamsEh); virtual;
    function DefaultCreateCellContent(AContentParent: TLaObjectEh): TLaObjectEh; virtual;

    property AxisCellParams: TDataAxisCreateCellContentParamsEh read FAxisCellParams;
    property Cell: TGridBaseCellEh read GetCell;
    property Grid: TDataGridEh read GetGrid;
    property CellContent: TLaObjectEh  read GetCellContent write SetCellContent;
    property ContentParent: TLaObjectEh read GetContentParent;
  end;

{ TDataGridGetDataRowManagerParamsEh }

  TDataGridGetDataRowManagerParamsEh  = class(TBaseDataGridGetDataRowManagerParamsEh)
  private
    function GetGrid: TDataGridEh;
  public
    property Grid: TDataGridEh read GetGrid;
  end;

{ TDataGridGetDataRowSplitWayParamsEh }

  TDataGridGetDataRowSplitWayParamsEh = class(TBaseDataGridGetDataRowSplitWayParamsEh)
  private
    function GetGrid: TDataGridEh;
  public
    property Grid: TDataGridEh read GetGrid;
  end;

{ TDataGridFilterRowParamsEh }

  TDataGridFilterRowParamsEh = class(TBaseDataGridFilterRowParamsEh)
  private
    function GetGrid: TDataGridEh;
  public
    property Grid: TDataGridEh read GetGrid;
  end;

{ TDataGridDataTreeViewAreaParamsEh }

  TDataGridDataTreeViewAreaParamsEh = class(TDataAxisCellTreeViewAreaParamsEh)
  private
    function GetGrid: TDataGridEh;
    function GetColumn: TDataGridBaseColumnEh;
    function GetRow: TDataGridRowEh;
  public
    property Grid: TDataGridEh read GetGrid;
    property Column: TDataGridBaseColumnEh read GetColumn;
    property Row: TDataGridRowEh read GetRow;
  end;

{ TDataGridSetDataTreeSignStateParamsEh }

  TDataGridSetDataTreeSignStateParamsEh = class(TDataAxisCellTreeSignStateParamsEh)
  private
    function GetGrid: TDataGridEh;
    function GetColumn: TDataGridBaseColumnEh;
    function GetRow: TDataGridRowEh;
  public
    property Grid: TDataGridEh read GetGrid;
    property Column: TDataGridBaseColumnEh read GetColumn;
    property Row: TDataGridRowEh read GetRow;
  end;

{ TDataGridInitEditorParamsEh }

  TDataGridInitEditorParamsEh = class(TPersistent)
  private
    FBaseCellParams: TBaseGridInitEditorParamsEh;

    function GetGrid: TDataGridEh;
    function GetColumn: TDataGridBaseColumnEh;
    function GetRow: TDataGridRowEh;
    function GetCell: TGridBaseCellEh;
    function GetEditor: TLaObjectEh;
    function GetEditParams: TBaseGridCellEditParamsEh;
    function GetHandled: Boolean;
    procedure SetHandled(const Value: Boolean);
  public
    procedure Init(ABaseCellParams: TBaseGridInitEditorParamsEh); virtual;

    property Grid: TDataGridEh read GetGrid;
    property Column: TDataGridBaseColumnEh read GetColumn;
    property Row: TDataGridRowEh read GetRow;
    property Cell: TGridBaseCellEh read GetCell;
    property Editor: TLaObjectEh read GetEditor;
    property EditParams: TBaseGridCellEditParamsEh read GetEditParams;
    property Handled: Boolean read GetHandled write SetHandled;
  end;

{ TDataGridDataCellInitEditParamsEh }

  TDataGridDataCellInitEditParamsEh = class(TPersistent)
  private
    FCellParams: TDataAxisCellEditParamsEh;
    function GetColumn: TDataGridBaseColumnEh;
    function GetEditorReadOnly: Boolean;
    function GetGrid: TDataGridEh;
    function GetRow: TDataGridRowEh;
    procedure SetEditorReadOnly(const Value: Boolean);
  public
    procedure Init(ACellParams: TDataAxisCellEditParamsEh); virtual;

    property Grid: TDataGridEh read GetGrid;
    property Column: TDataGridBaseColumnEh read GetColumn;
    property Row: TDataGridRowEh read GetRow;

    property EditorReadOnly: Boolean read GetEditorReadOnly write SetEditorReadOnly;
  end;

{ TDataGridDataCellStartEditParamsEh }

  TDataGridDataCellStartEditParamsEh = class(TPersistent)
  private
    FCellParams: TDataAxisCellStartEditParamsEh;
    function GetColumn: TDataGridBaseColumnEh;
    function GetGrid: TDataGridEh;
    function GetRow: TDataGridRowEh;
    function GetEditingActive: Boolean;
    function GetHandled: Boolean;
    procedure SetEditingActive(const Value: Boolean);
    procedure SetHandled(const Value: Boolean);

  public
    procedure Init(ACellParams: TDataAxisCellStartEditParamsEh); virtual;

    property Grid: TDataGridEh read GetGrid;
    property Column: TDataGridBaseColumnEh read GetColumn;
    property Row: TDataGridRowEh read GetRow;

    property EditingActive: Boolean read GetEditingActive write SetEditingActive;
    property Handled: Boolean  read GetHandled write SetHandled;
  end;

{ TDataGridDataCellCanModifyParamsEh }

  TDataGridDataCellCanModifyParamsEh = class(TPersistent)
  private
    FCellParams: TDataAxisCellCanModifyParamsEh;
    function GetCanModify: Boolean;
    function GetColumn: TDataGridBaseColumnEh;
    function GetGrid: TDataGridEh;
    function GetHandled: Boolean;
    function GetRow: TDataGridRowEh;
    procedure SetCanModify(const Value: Boolean);
    procedure SetHandled(const Value: Boolean);
  public
    procedure Init(ACellParams: TDataAxisCellCanModifyParamsEh); virtual;

    property Grid: TDataGridEh read GetGrid;
    property Column: TDataGridBaseColumnEh read GetColumn;
    property Row: TDataGridRowEh read GetRow;

    property Handled: Boolean  read GetHandled write SetHandled;
    property CanModify: Boolean read GetCanModify write SetCanModify;
  end;

{ TDataGridDataCellInTextLinkClickParamsEh }

  TDataGridDataCellInTextLinkClickParamsEh = class(TPersistent)
  private
    FCellParams: TDataAxisCellInTextLinkClickParamsEh;
    function GetColumn: TDataGridBaseColumnEh;
    function GetGrid: TDataGridEh;
    function GetHandled: Boolean;
    function GetRow: TDataGridRowEh;
    procedure SetHandled(const Value: Boolean);
    function GetLinkText: String;

  public
    procedure Init(ACellParams: TDataAxisCellInTextLinkClickParamsEh); virtual;

    property Grid: TDataGridEh read GetGrid;
    property Column: TDataGridBaseColumnEh read GetColumn;
    property Row: TDataGridRowEh read GetRow;
    property LinkText: String read GetLinkText;

    property Handled: Boolean  read GetHandled write SetHandled;
  end;

  TDataGridEventEh = procedure(Sender: TObject; Params: TDataGridEventParamsEh) of object;
  TDataGridColumnWidthChangedEventEh = procedure(Sender: TObject; Params: TDataGridColumnWidthChangedParamsEh) of object;

  TDataGridDataCellGetValueEventEh = procedure(Sender: TObject; Params: TDataGridDataCellGetValueParamsEh) of object;
  TDataGridDataCellSetValueEventEh = procedure(Sender: TObject; Params: TDataGridDataCellSetValueParamsEh) of object;
  TDataGridDataCellGetDisplayTextEventEh = procedure(Sender: TObject; Params: TDataGridDataCellGetDisplayTextParamsEh) of object;
  TDataGridDataCellGetStyleParamsEventEh = procedure(Sender: TObject; Params: TDataGridDataCellStyleParamsEh) of object;
  TDataGridStringDataCellGetStyleParamsEventEh = procedure(Sender: TObject; Params: TDataGridStringDataCellStyleParamsEh) of object;
  TDataGridDataCellMouseButtonEventEh = procedure(Sender: TObject; Params: TDataGridDataCellMouseButtonParamsEh) of object;
  TDataGridDataCellInitEditorEventEh = procedure(Sender: TObject; Params: TDataGridInitEditorParamsEh) of object;
  TDataGridDataCellInitEditParamsEventEh = procedure(Sender: TObject; Params: TDataGridDataCellInitEditParamsEh) of object;
  TDataGridDataCellStartEditEventEh = procedure(Sender: TObject; Params: TDataGridDataCellStartEditParamsEh) of object;
  TDataGridDataCellCanModifyEventEh = procedure(Sender: TObject; Params: TDataGridDataCellCanModifyParamsEh) of object;
  TDataGridDataCellInTextLinkClickEventEh = procedure(Sender: TObject; Params: TDataGridDataCellInTextLinkClickParamsEh) of object;

  TDataGridDataCellMouseDownEventEh = procedure(Sender: TObject; Params: TDataGridDataCellMouseButtonParamsEh) of object;
  TDataGridDataCellKeyDownEventEh = procedure(Sender: TObject; Params: TDataGridDataCellKeyDownParamsEh) of object;
  TBaseEventEh = procedure(Sender: TObject; Params: TPersistent) of object;

  TDataGridFooterCalcFinalDataEventEh = procedure(Sender: TObject; Params: TDataGridFooterCalcFinalDataParamsEh) of object;
  TDataGridFooterCalcInitDataEventEh = procedure(Sender: TObject; Params: TDataGridFooterCalcInitDataParamsEh) of object;
  TDataGridFooterCalcStepDataEventEh = procedure(Sender: TObject; Params: TDataGridFooterCalcStepDataParamsEh) of object;
  TDataGridFooterGetDisplayTextEventEh = procedure(Sender: TObject; Params: TDataGridFooterGetDisplayTextParamsEh) of object;

  TDataGridCanUserSelectCurrentRowEventEh = procedure(Sender: TObject; Params: TDataGridCanSelectRowParamsEh) of object;
  TDataGridGetDataCellManagerEventEh = procedure(Sender: TObject; Params: TDataGridGetDataCellManagerParamsEh) of object;
  TDataGridInitDataCellContentEventEh = procedure(Sender: TObject; Params: TDataGridInitDataCellContentParamsEh) of object;
  TDataGridCreateDataCellContentEventEh = procedure(Sender: TObject; Params: TDataGridCreateDataCellContentParamsEh) of object;
  TDataGridGetDataRowManagerEventEh = procedure(Sender: TObject; Params: TDataGridGetDataRowManagerParamsEh) of object;
  TDataGridGetDataRowSplitWayEventEh = procedure(Sender: TObject; Params: TDataGridGetDataRowSplitWayParamsEh) of object;

  TDataGridFilterRowParamsEventEh = procedure(Sender: TObject; Params: TDataGridFilterRowParamsEh) of object;
  TDataGridGetDataTreeViewAreaParamsEventEh = procedure(Sender: TObject; Params: TDataGridDataTreeViewAreaParamsEh) of object;
  TDataGridSetDataTreeSignStateEventEh = procedure(Sender: TObject; Params: TDataGridSetDataTreeSignStateParamsEh) of object;

{ TColumnFooterEh }

  TDataGridColumnFooterEh = class(TDataGridBaseColumnFooterEh)
  private
    FOnCalcFinalData: TDataGridFooterCalcFinalDataEventEh;
    FOnCalcInitData: TDataGridFooterCalcInitDataEventEh;
    FOnCalcStepData: TDataGridFooterCalcStepDataEventEh;
    FOnGetDisplayText: TDataGridFooterGetDisplayTextEventEh;

  protected
    function CreateCalcInitDataParams(): TBaseDataGridFooterCalcInitDataParamsEh; override;
    function CreateCalcStepDataParams(): TBaseDataGridFooterCalcStepDataParamsEh; override;
    function CreateCalcFinalDataParams(): TBaseDataGridFooterCalcFinalDataParamsEh; override;
    function CreateGetDisplayTextParams(): TBaseDataGridFooterGetDisplayTextParamsEh; override;

    procedure HandleCalcFinalData(AFinalDataParams: TBaseDataGridFooterCalcFinalDataParamsEh); override;
    procedure HandleCalcInitData(AInitDataParams: TBaseDataGridFooterCalcInitDataParamsEh); override;
    procedure HandleCalcStepData(AStepDataParams: TBaseDataGridFooterCalcStepDataParamsEh); override;
    procedure HandleGetDisplayText(Params: TBaseDataGridFooterGetDisplayTextParamsEh); override;

  published
    property OnCalcInitData: TDataGridFooterCalcInitDataEventEh read FOnCalcInitData write FOnCalcInitData;
    property OnCalcStepData: TDataGridFooterCalcStepDataEventEh read FOnCalcStepData write FOnCalcStepData;
    property OnCalcFinalData: TDataGridFooterCalcFinalDataEventEh read FOnCalcFinalData write FOnCalcFinalData;
    property OnGetDisplayText: TDataGridFooterGetDisplayTextEventEh read FOnGetDisplayText write FOnGetDisplayText;
  end;

{ TColumnFootersEh }

  TDataGridColumnFootersEh = class(TDataGridBaseColumnFootersEh)
  private
    function GetFooter(Index: Integer): TDataGridColumnFooterEh;
    procedure SetFooter(Index: Integer; const Value: TDataGridColumnFooterEh);
  public
    property Items[Index: Integer]: TDataGridColumnFooterEh read GetFooter write SetFooter; default;
  end;

{ TDataGridColumnEh }

  TDataGridColumnEh = class(TDataGridBaseColumnEh)
  private
    FOnDataCellGetDisplayText: TDataGridDataCellGetDisplayTextEventEh;
    FOnDataCellGetStyleParams: TDataGridDataCellGetStyleParamsEventEh;
    FOnDataCellGetValue: TDataGridDataCellGetValueEventEh;
    FOnDataCellMouseDown: TDataGridDataCellMouseDownEventEh;
    FOnDataCellSetValue: TDataGridDataCellSetValueEventEh;
    FOnGetDataCellManager: TDataGridGetDataCellManagerEventEh;
    FOnCreateDataCellContent: TDataGridCreateDataCellContentEventEh;
    FOnDataCellInitContent: TDataGridInitDataCellContentEventEh;
    FOnDataCellInitEditor: TDataGridDataCellInitEditorEventEh;
    FOnDataCellInitEditParams: TDataGridDataCellInitEditParamsEventEh;
    FOnDataCellStartEdit: TDataGridDataCellStartEditEventEh;
    FOnDataCellCanModify: TDataGridDataCellCanModifyEventEh;

    function GetFooters: TDataGridColumnFootersEh;
    procedure SetFooters(const Value: TDataGridColumnFootersEh);

  protected
    function CreateFooters: TDataGridBaseColumnFootersEh; override;
    function CreateGetBarValueEventParams(): TDataAxisGridGetBarValueParamsEh; override;
    function CreateGetCellManagerParams(): TBaseDataGridGetDataCellManagerParamsEh; override;
    function CreateGetDisplayTextParams(): TDataAxisGridGetDisplayTextParamsEh; override;
    function CreateSetBarValueEventParams(): TDataAxisGridSetBarValueParamsEh; override;
    function CreateFieldBarStyleParams(): TFieldBarDataCellStyleParamsEh; override;

    procedure HandleDataCellGetDisplayText(Params: TDataAxisGridGetDisplayTextParamsEh); override;
    procedure HandleGetFieldBarStyleParams(Params: TDataAxisCellStyleParamsEh); override;
    procedure HandleDataCellGetValue(Params: TDataAxisGridGetBarValueParamsEh); override;
    procedure HandleDataCellKeyDownEvent(Params: TBaseGridCellKeyDownParamsEh); override;
    procedure HandleDataCellMouseDownEvent(Params: TGridCellMouseButtonParamsEh); override;
    procedure HandleDataCellSetValue(Params: TDataAxisGridSetBarValueParamsEh); override;
    procedure HandleGetDataCellManager(Params: TBaseDataGridGetDataCellManagerParamsEh); override;
    procedure HandleInitDataCell(Params: TPersistent); override;
    procedure HandleDataCellInitContent(Params: TBaseGridInitCellContentParamsEh); override;
    procedure HandleCreateCellContent(Params: TBaseGridCreateCellContentParamsEh); override;
    procedure HandleInitCellEditor(AParams: TBaseGridInitEditorParamsEh); override;
    procedure HandleDataCellInitEditParams(AParams: TBaseGridCellEditParamsEh); override;
    procedure HandleDataCellStartEdit(Params: TPersistent); override;
    procedure HandleCanModifyCellValue(AParams: TDataAxisCellCanModifyParamsEh); override;

    property OnDataCellGetDisplayText: TDataGridDataCellGetDisplayTextEventEh read FOnDataCellGetDisplayText write FOnDataCellGetDisplayText;

  public
    property Footers: TDataGridColumnFootersEh read GetFooters write SetFooters;

  published
    property AllowShowEditor;

    property OnCreateDataCellContent: TDataGridCreateDataCellContentEventEh read FOnCreateDataCellContent write FOnCreateDataCellContent;
    property OnDataCellGetStyleParams: TDataGridDataCellGetStyleParamsEventEh read FOnDataCellGetStyleParams write FOnDataCellGetStyleParams;
    property OnDataCellGetValue: TDataGridDataCellGetValueEventEh read FOnDataCellGetValue write FOnDataCellGetValue;
    property OnDataCellInitContent: TDataGridInitDataCellContentEventEh read FOnDataCellInitContent write FOnDataCellInitContent;
    property OnDataCellMouseDown: TDataGridDataCellMouseDownEventEh read FOnDataCellMouseDown write FOnDataCellMouseDown;
    property OnDataCellSetValue: TDataGridDataCellSetValueEventEh read FOnDataCellSetValue write FOnDataCellSetValue;
    property OnGetDataCellManager: TDataGridGetDataCellManagerEventEh read FOnGetDataCellManager write FOnGetDataCellManager;
    property OnDataCellInitEditor: TDataGridDataCellInitEditorEventEh read FOnDataCellInitEditor write FOnDataCellInitEditor;
    property OnDataCellInitEditParams: TDataGridDataCellInitEditParamsEventEh read FOnDataCellInitEditParams write FOnDataCellInitEditParams;
    property OnDataCellStartEdit: TDataGridDataCellStartEditEventEh read FOnDataCellStartEdit write FOnDataCellStartEdit;
    property OnDataCellCanModify: TDataGridDataCellCanModifyEventEh read FOnDataCellCanModify write FOnDataCellCanModify;
  end;

{ TDataGridStringColumnEh }

  TDataGridStringColumnEh = class(TDataGridColumnEh)
  private
    FWordWrap: Boolean;
    FWordWrapStored: Boolean;
    FTrimming: TTextTrimming;
    FTrimmingStored: Boolean;
    FDataCellGetStyleParams: TDataGridStringDataCellGetStyleParamsEventEh;
    FOnDataCellInTextLinkClick: TDataGridDataCellInTextLinkClickEventEh;
    FHighlightHyperlinks: Boolean;

    function GetDisplayFormat: String;
    function GetWordWrap: Boolean;
    function IsDisplayFormatStored(): Boolean;
    function IsWordWrapStored: Boolean;
    function IsTrimmingStored: Boolean;

    procedure SetDisplayFormat(const Value: String);
    procedure SetDisplayFormatStored(const Value: Boolean);
    procedure SetWordWrap(const Value: Boolean);
    procedure SetWordWrapStored(const Value: Boolean);
    procedure SetTrimmingStored(const Value: Boolean);
    function GetTrimming: TTextTrimming;
    procedure SetTrimming(const Value: TTextTrimming);
    function GetDisplayFormatStored: Boolean;
    function GetDefaultCellManager: TDataAxisTextCellManagerEh;

  protected
    function DefaultWordWrap: Boolean; virtual;
    function DefaultTrimming: TTextTrimming; virtual;
    function CreateCellManager: TBaseGridCellManagerEh; override;

    procedure HandleGetFieldBarStyleParams(Params: TDataAxisCellStyleParamsEh); override;
    procedure HandleDataCellInTextLinkClick(Params: TDataAxisCellInTextLinkClickParamsEh); override;

  public
    procedure DefaultInitCellEditor(AInitEditorParams: TBaseGridInitEditorParamsEh); override;
    procedure InitCell(ACell: TGridBaseCellEh; AStyleParams: TDataAxisCellStyleParamsEh); override;
    procedure InitStyleParams(Params: TDataAxisCellStyleParamsEh); override;
    procedure DefaultInitEditParams(Params: TBaseGridCellEditParamsEh); override;

    property DefaultCellManager: TDataAxisTextCellManagerEh read GetDefaultCellManager;
  published
    property OnDataCellGetDisplayText;

    property WordWrap: Boolean read GetWordWrap write SetWordWrap stored IsWordWrapStored;
    property WordWrapStored: Boolean read IsWordWrapStored write SetWordWrapStored default False;

    property DisplayFormat: String read GetDisplayFormat write SetDisplayFormat stored IsDisplayFormatStored;
    property DisplayFormatStored: Boolean read GetDisplayFormatStored write SetDisplayFormatStored default False;

    property Trimming: TTextTrimming read GetTrimming write SetTrimming stored IsTrimmingStored;
    property TrimmingStored: Boolean read IsTrimmingStored write SetTrimmingStored default False;

    property HighlightHyperlinks: Boolean read FHighlightHyperlinks write FHighlightHyperlinks default False;

    property OnDataCellGetStyleParams: TDataGridStringDataCellGetStyleParamsEventEh read FDataCellGetStyleParams write FDataCellGetStyleParams;
    property OnDataCellInTextLinkClick: TDataGridDataCellInTextLinkClickEventEh read FOnDataCellInTextLinkClick write FOnDataCellInTextLinkClick;
  end;

{ TDataGridComboDropDownBoxEh }

  TDataGridComboDropDownBoxEh = class(TBaseDataAxisGridComboDropDownBoxEh)
  private
    FOnCreateDataCellContent: TDataGridCreateDataCellContentEventEh;
    FOnDataCellGetStyleParams: TDataGridDataCellGetStyleParamsEventEh;
    FOnDataCellInitContent: TDataGridInitDataCellContentEventEh;
    FOnGetDataCellManager: TDataGridGetDataCellManagerEventEh;

  protected
    procedure HandleDataCellGetStyleParams(Params: TDataAxisCellStyleParamsEh); override;
    procedure HandleCreateCellContent(Params: TBaseGridCreateCellContentParamsEh); override;
    procedure HandleInitDataCellContent(Params: TPersistent); override;
    procedure HandleGetDataCellManager(Params: TPersistent); override;

  published
    property OnCreateDataCellContent: TDataGridCreateDataCellContentEventEh read FOnCreateDataCellContent write FOnCreateDataCellContent;
    property OnDataCellGetStyleParams: TDataGridDataCellGetStyleParamsEventEh read FOnDataCellGetStyleParams write FOnDataCellGetStyleParams;
    property OnDataCellInitContent: TDataGridInitDataCellContentEventEh read FOnDataCellInitContent write FOnDataCellInitContent;
    property OnGetDataCellManager: TDataGridGetDataCellManagerEventEh read FOnGetDataCellManager write FOnGetDataCellManager;
  end;

{ TDataGridComboboxColumnEh }

  TDataGridComboboxColumnEh = class(TDataGridStringColumnEh)
  private
    FDropDownBox: TDataGridComboDropDownBoxEh;
    procedure SetListSource(const Value: TComponent);
    procedure SetListFieldName(const Value: String);
    procedure SetListKeyFieldName(const Value: String);
    function GetDefCellManager: TDataAxisGridComboboxCellManagerEh;
    function GetListFieldName: String;
    function GetListKeyFieldName: String;
    function GetListSource: TComponent;
    function GetIsLookupMode: Boolean;
    function GetDropDownBox: TDataGridComboDropDownBoxEh;
    function GetListItems: TStrings;
    procedure SetListItems(const Value: TStrings);

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

  published
    property DropDownBox: TDataGridComboDropDownBoxEh read GetDropDownBox;
    property IsLookupMode: Boolean read GetIsLookupMode;
    property ListFieldName: String read GetListFieldName write SetListFieldName;
    property ListItems: TStrings read GetListItems write SetListItems;
    property ListKeyFieldName: String read GetListKeyFieldName write SetListKeyFieldName;
    property ListSource: TComponent read GetListSource write SetListSource;
  end;

{ TDataGridCheckboxColumnEh }

  TDataGridCheckboxColumnEh = class(TDataGridColumnEh)
  private
    function GetCheckedValue: TValue;
    function GetDefCellManager: TDataAxisCheckboxCellManagerEh;
    function GetIsChecked(ARow: TDataGridRowEh): Boolean;
    function GetUncheckedValue: TValue;
    function IsCheckedValueStored: Boolean;
    function IsUncheckedValueStored: Boolean;

    procedure SetCheckedValue(const Value: TValue);
    procedure SetUncheckedValue(const Value: TValue);
  protected
    function CreateCellManager: TBaseGridCellManagerEh; override;
  public
    function CanEditShow: Boolean; override;

    procedure InitCell(ACell: TGridBaseCellEh; AStyleParams: TDataAxisCellStyleParamsEh); override;

    procedure Toggle;

    property IsChecked[ARow: TDataGridRowEh]: Boolean read GetIsChecked;
    property DefCellManager: TDataAxisCheckboxCellManagerEh read GetDefCellManager;

  public
    property CheckedValue: TValue read GetCheckedValue write SetCheckedValue stored IsCheckedValueStored;
    property UncheckedValue: TValue read GetUncheckedValue write SetUncheckedValue stored IsUncheckedValueStored;
  published
  end;

{ TDataGridGraphicColumnEh }

  TDataGridGraphicColumnEh = class(TDataGridColumnEh)
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

{ TDataGridLayoutColumnEh }

  TDataGridLayoutColumnEh = class(TDataGridColumnEh)
  private
  protected
    function CreateCellManager: TBaseGridCellManagerEh; override;
    function DefaultAllowShowEditor(): Boolean; override;

  published
  end;

{ TDataGridEh }

  TDataGridEh = class(TCustomDataGridEh)
  private
    FOnCanUserSelectRow: TDataGridCanUserSelectCurrentRowEventEh;
    FOnColEnter: TDataGridEventEh;
    FOnColExit: TDataGridEventEh;
    FOnColumnWidthChanged: TDataGridColumnWidthChangedEventEh;
    FOnCurrentChange: TDataGridEventEh;
    FOnDataCellGetDisplayText: TDataGridDataCellGetDisplayTextEventEh;
    FOnDataCellGetStyleParams: TDataGridDataCellGetStyleParamsEventEh;
    FOnDataCellGetValue: TDataGridDataCellGetValueEventEh;
    FOnDataCellKeyDown: TDataGridDataCellKeyDownEventEh;
    FOnDataCellMouseClick: TDataGridDataCellMouseButtonEventEh;
    FOnDataCellMouseDown: TDataGridDataCellMouseButtonEventEh;
    FOnDataCellSetValue: TDataGridDataCellSetValueEventEh;
    FOnFilterRow: TDataGridFilterRowParamsEventEh;
    FOnGetDataCellManager: TDataGridGetDataCellManagerEventEh;
    FOnSelectionChanged: TDataGridEventEh;
    FOnGetDataRowManager: TDataGridGetDataRowManagerEventEh;
    FOnGetDataRowSplitWay: TDataGridGetDataRowSplitWayEventEh;
    FOnGetDataTreeViewAreaParams: TDataGridGetDataTreeViewAreaParamsEventEh;
    FOnSetDataTreeSignState: TDataGridSetDataTreeSignStateEventEh;
    FOnDataCellCanModify: TDataGridDataCellCanModifyEventEh;

  protected
    function CreateDataCellKeyDownParams(AGrid: TControl; AColIndex, ARowIndex, AAreaColIndex, AAreaRowIndex: Integer): TBaseGridCellKeyDownParamsEh; override;
    function CreateDataGridCanSelectRowParams(AGrid: TControl; ARow: TDataGridRowEh): TCustomDataGridCanSelectRowParamsEh; override;
    function CreateDataGridFilterRowParams: TBaseDataGridFilterRowParamsEh; override;
    function CreateGetDataRowManagerParams(): TBaseDataGridGetDataRowManagerParamsEh; override;
    function CreateGetDataRowSplitWayParams(): TBaseDataGridGetDataRowSplitWayParamsEh; override;
    function CreateDataCellTreeViewAreaParams(): TDataAxisCellTreeViewAreaParamsEh; override;
    function GetDynaFieldBarClassByField(AField: TTableFieldLinkEh): TFieldBarEhClass; override;

    procedure ColEnter; override;
    procedure ColExit; override;
    procedure HandleCanUserSelectCurrentRow(Params: TCustomDataGridCanSelectRowParamsEh); override;
    procedure HandleColumnWidthChanged(Column: TDataGridBaseColumnEh); override;
    procedure HandleCurrentPosChange(); override;
    procedure HandleDataCellGetDisplayText(Params: TDataAxisGridGetDisplayTextParamsEh); override;
    procedure HandleDataCellGetStyleParams(Params: TDataAxisCellStyleParamsEh); override;
    procedure HandleDataCellGetValue(Params: TDataAxisGridGetBarValueParamsEh); override;
    procedure HandleDataCellKeyDownEvent(Params: TBaseGridCellKeyDownParamsEh); override;
    procedure HandleDataCellMouseClickEvent(Params: TGridCellMouseButtonParamsEh); override;
    procedure HandleDataCellMouseDownEvent(Params: TGridCellMouseButtonParamsEh); override;
    procedure HandleDataCellSetValue(Params: TDataAxisGridSetBarValueParamsEh); override;
    procedure HandleGetDataCellManager(Params: TBaseDataGridGetDataCellManagerParamsEh); override;
    procedure HandleGetDataRowManager(Params: TBaseDataGridGetDataRowManagerParamsEh); override;
    procedure HandleCanModifyCellValue(AParams: TDataAxisCellCanModifyParamsEh); override;

    procedure HandleIsRowMatchFilter(Params: TBaseDataGridFilterRowParamsEh); override;
    procedure HandleGetDataRowSplitWay(Params: TBaseDataGridGetDataRowSplitWayParamsEh); override;
    procedure HandleSelectionChanged; override;
    procedure HandleGetDataTreeViewAreaParams(Params: TDataAxisCellTreeViewAreaParamsEh); override;
    procedure HandleSetDataTreeSignState(Params: TDataAxisCellTreeSignStateParamsEh); override;

  published
    property AutoGenerateColumns;
    property ColumnOptions;
    property DataSource;
    property DataGrouping;
    property EditActions;
    property Footer;
    property GridLineOptions;
    property HorzScrollBar;
    property IndicatorColumn;
    property IndicatorTitle;
    property ReadOnly;
    property SearchPanel;
    property SelectionOptions;
    property Title;
    property VertScrollBar;

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
    property StaticColumns;
    property TabOrder;
    property TabStop;
    property Visible;
    property Width;

    property OnCanUserSelectRow: TDataGridCanUserSelectCurrentRowEventEh read FOnCanUserSelectRow write FOnCanUserSelectRow;
    property OnColEnter: TDataGridEventEh read FOnColEnter write FOnColEnter;
    property OnColExit: TDataGridEventEh read FOnColExit write FOnColExit;
    property OnColumnWidthChanged: TDataGridColumnWidthChangedEventEh read FOnColumnWidthChanged write FOnColumnWidthChanged;
    property OnCurrentChange: TDataGridEventEh read FOnCurrentChange write FOnCurrentChange;
    property OnDataCellGetDisplayText: TDataGridDataCellGetDisplayTextEventEh read FOnDataCellGetDisplayText write FOnDataCellGetDisplayText;
    property OnDataCellGetStyleParams: TDataGridDataCellGetStyleParamsEventEh read FOnDataCellGetStyleParams write FOnDataCellGetStyleParams;
    property OnDataCellGetValue: TDataGridDataCellGetValueEventEh read FOnDataCellGetValue write FOnDataCellGetValue;
    property OnDataCellKeyDown: TDataGridDataCellKeyDownEventEh read FOnDataCellKeyDown write FOnDataCellKeyDown;
    property OnDataCellMouseClick: TDataGridDataCellMouseButtonEventEh read FOnDataCellMouseClick write FOnDataCellMouseClick;
    property OnDataCellMouseDown: TDataGridDataCellMouseButtonEventEh read FOnDataCellMouseDown write FOnDataCellMouseDown;
    property OnDataCellSetValue: TDataGridDataCellSetValueEventEh read FOnDataCellSetValue write FOnDataCellSetValue;
    property OnDataCellCanModify: TDataGridDataCellCanModifyEventEh read FOnDataCellCanModify write FOnDataCellCanModify;

    property OnFilterRow: TDataGridFilterRowParamsEventEh read FOnFilterRow write FOnFilterRow;
    property OnGetDataCellManager: TDataGridGetDataCellManagerEventEh read FOnGetDataCellManager write FOnGetDataCellManager;
    property OnGetDataRowManager: TDataGridGetDataRowManagerEventEh read FOnGetDataRowManager write FOnGetDataRowManager;
    property OnGetDataRowSplitWay: TDataGridGetDataRowSplitWayEventEh read FOnGetDataRowSplitWay write FOnGetDataRowSplitWay;
    property OnGetDataTreeViewAreaParams: TDataGridGetDataTreeViewAreaParamsEventEh read FOnGetDataTreeViewAreaParams write FOnGetDataTreeViewAreaParams;
    property OnKeyDown;
    property OnKeyUp;
    property OnSelectionChanged: TDataGridEventEh read FOnSelectionChanged write FOnSelectionChanged;
    property OnSetDataTreeSignState: TDataGridSetDataTreeSignStateEventEh read FOnSetDataTreeSignState write FOnSetDataTreeSignState;

  end;

implementation

uses
  Data.DBConsts,
  EhLibLangConsts,
  EhLibFmx.CustomizeColumnsDialog,
  EhLibFmx.DataGrid.ImpExp,
  EhLibFmx.ImageReses;

type
  TDataGridTitleBarEhCrack = class(TDataGridTitleBarEh);
  TDataGridEhIndicatorColumnCrack = class(TDataGridIndicatorColumnEh);
  TControlCrack = class(TControl);
  TDataGridEhSelectionCrack = class(TDataGridSelectionEh);
  TDataGridSearchPanelEhCrack = class(TDataGridSearchPanelEh);
  TDataGridEhNavigatorPanelCrack = class(TDataGridNavigatorPanelEh);
  TCustomDataGridEhCrack = class(TCustomDataGridEh);

{ InitModule FinalizeModule }

procedure InitModule;
begin
  RegisterFmxClasses([TDataGridColumnEh, TDataGridStringColumnEh, TDataGridCheckboxColumnEh, TDataGridGraphicColumnEh, TDataGridLayoutColumnEh]);
  RegisterFmxClasses([TDataGridSuperTitleEh]);
end;

procedure FinalizeModule;
begin
  UnRegisterClasses([TDataGridColumnEh, TDataGridStringColumnEh, TDataGridCheckboxColumnEh, TDataGridGraphicColumnEh, TDataGridLayoutColumnEh]);
  UnRegisterClasses([TDataGridSuperTitleEh]);
end;

{$REGION 'TDataGridEh'}

procedure TDataGridEh.HandleDataCellGetValue(Params: TDataAxisGridGetBarValueParamsEh);
begin
  if Assigned(OnDataCellGetValue) then
    OnDataCellGetValue(Self, TDataGridDataCellGetValueParamsEh(Params));
end;

procedure TDataGridEh.HandleDataCellSetValue(Params: TDataAxisGridSetBarValueParamsEh);
begin
  if Assigned(OnDataCellSetValue) then
    OnDataCellSetValue(Self, TDataGridDataCellSetValueParamsEh(Params));
end;

procedure TDataGridEh.HandleDataCellGetDisplayText(Params: TDataAxisGridGetDisplayTextParamsEh);
begin
  if Assigned(OnDataCellGetDisplayText) then
    OnDataCellGetDisplayText(Self, TDataGridDataCellGetDisplayTextParamsEh(Params));
end;

procedure TDataGridEh.HandleDataCellGetStyleParams(Params: TDataAxisCellStyleParamsEh);
var
  GridParams: TDataGridDataCellStyleParamsEh;
begin
  if Assigned(OnDataCellGetStyleParams) then
  begin
    GridParams := TDataGridDataCellStyleParamsEh.Create;
    GridParams.Init(Params);
    try
      OnDataCellGetStyleParams(Self, GridParams);
    finally
      GridParams.Free;
    end;
  end;
end;

function TDataGridEh.GetDynaFieldBarClassByField(AField: TTableFieldLinkEh): TFieldBarEhClass;
begin
  Result := inherited GetDynaFieldBarClassByField(AField);
end;

procedure TDataGridEh.HandleDataCellKeyDownEvent(Params: TBaseGridCellKeyDownParamsEh);
begin
  if Assigned(OnDataCellKeyDown) then
    OnDataCellKeyDown(Self, TDataGridDataCellKeyDownParamsEh(Params));
end;

procedure TDataGridEh.HandleDataCellMouseClickEvent(Params: TGridCellMouseButtonParamsEh);
var
  GridParams: TDataGridDataCellMouseButtonParamsEh;
begin
  if Assigned(OnDataCellMouseClick) then
  begin
    GridParams := TDataGridDataCellMouseButtonParamsEh.Create;
    GridParams.Init(Params as TDataAxisCellMouseButtonParamsEh);
    try
      OnDataCellMouseClick(Self, GridParams);
    finally
      GridParams.Free;
    end;
  end;
end;

procedure TDataGridEh.HandleDataCellMouseDownEvent(Params: TGridCellMouseButtonParamsEh);
var
  GridParams: TDataGridDataCellMouseButtonParamsEh;
begin
  if Assigned(OnDataCellMouseDown) then
  begin
    GridParams := TDataGridDataCellMouseButtonParamsEh.Create;
    GridParams.Init(Params as TDataAxisCellMouseButtonParamsEh);
    try
      OnDataCellMouseDown(Self, GridParams);
    finally
      GridParams.Free;
    end;
  end;
end;

procedure TDataGridEh.HandleCanUserSelectCurrentRow(Params: TCustomDataGridCanSelectRowParamsEh);
begin
  if Assigned(OnCanUserSelectRow) then
    OnCanUserSelectRow(Self, TDataGridCanSelectRowParamsEh(Params));
end;

procedure TDataGridEh.HandleCurrentPosChange();
var
  Params: TDataGridEventParamsEh;
begin
  Params := TDataGridEventParamsEh.Create;
  Params.Init(Self);
  try
    if Assigned(OnCurrentChange) then
      OnCurrentChange(Self, Params);
  finally
    Params.Free;
  end;
end;

function TDataGridEh.CreateDataCellKeyDownParams(AGrid: TControl; AColIndex, ARowIndex, AAreaColIndex,
  AAreaRowIndex: Integer): TBaseGridCellKeyDownParamsEh;
begin
  Result := TDataGridDataCellKeyDownParamsEh.Create;
end;

function TDataGridEh.CreateDataGridCanSelectRowParams(AGrid: TControl; ARow: TDataGridRowEh): TCustomDataGridCanSelectRowParamsEh;
begin
  Result := TDataGridCanSelectRowParamsEh.Create(Self, ARow);
end;

procedure TDataGridEh.ColEnter;
var
  Params: TDataGridEventParamsEh;
begin
  inherited ColEnter;

  if Assigned(FOnColEnter) then
  begin
    Params := TDataGridEventParamsEh.Create;
    Params.Init(Self);
    try
      FOnColEnter(Self, Params);
    finally
      Params.Free;
    end;
  end;
end;

procedure TDataGridEh.ColExit;
var
  Params: TDataGridEventParamsEh;
begin
  inherited ColExit;

  if Assigned(FOnColExit) then
  begin
    Params := TDataGridEventParamsEh.Create;
    Params.Init(Self);
    try
      FOnColExit(Self, Params);
    finally
      Params.Free;
    end;
  end;
end;

procedure TDataGridEh.HandleColumnWidthChanged(Column: TDataGridBaseColumnEh);
var
  Params: TDataGridColumnWidthChangedParamsEh;
begin
  inherited HandleColumnWidthChanged(Column);

  if Assigned(OnColumnWidthChanged) then
  begin
    Params := TDataGridColumnWidthChangedParamsEh.Create;
    Params.Init(Self, Column);
    try
      OnColumnWidthChanged(Self, Params);
    finally
      Params.Free;
    end;
  end;
end;

procedure TDataGridEh.HandleSelectionChanged;
var
  Params: TDataGridEventParamsEh;
begin
  inherited HandleSelectionChanged();

  if Assigned(OnSelectionChanged) then
  begin
    Params := TDataGridEventParamsEh.Create;
    Params.Init(Self);
    try
      OnSelectionChanged(Self, Params);
    finally
      Params.Free;
    end;
  end;
end;

procedure TDataGridEh.HandleGetDataCellManager(Params: TBaseDataGridGetDataCellManagerParamsEh);
begin
  if Assigned(OnGetDataCellManager) then
    OnGetDataCellManager(Self, TDataGridGetDataCellManagerParamsEh(Params));
end;

function TDataGridEh.CreateGetDataRowManagerParams(): TBaseDataGridGetDataRowManagerParamsEh;
begin
  Result := TDataGridGetDataRowManagerParamsEh.Create;
end;

procedure TDataGridEh.HandleGetDataRowManager(Params: TBaseDataGridGetDataRowManagerParamsEh);
begin
  if Assigned(OnGetDataRowManager) then
    OnGetDataRowManager(Self, TDataGridGetDataRowManagerParamsEh(Params));
end;

function TDataGridEh.CreateGetDataRowSplitWayParams: TBaseDataGridGetDataRowSplitWayParamsEh;
begin
  Result := TDataGridGetDataRowSplitWayParamsEh.Create;
end;

procedure TDataGridEh.HandleGetDataRowSplitWay(Params: TBaseDataGridGetDataRowSplitWayParamsEh);
begin
  if Assigned(OnGetDataRowSplitWay) then
    OnGetDataRowSplitWay(Self, TDataGridGetDataRowSplitWayParamsEh(Params));
end;

function TDataGridEh.CreateDataGridFilterRowParams: TBaseDataGridFilterRowParamsEh;
begin
  Result := TDataGridFilterRowParamsEh.Create;
end;

procedure TDataGridEh.HandleIsRowMatchFilter(Params: TBaseDataGridFilterRowParamsEh);
begin
  if Assigned(OnFilterRow) then
    OnFilterRow(Self, TDataGridFilterRowParamsEh(Params));
end;

function TDataGridEh.CreateDataCellTreeViewAreaParams: TDataAxisCellTreeViewAreaParamsEh;
begin
  Result := TDataGridDataTreeViewAreaParamsEh.Create();
end;

procedure TDataGridEh.HandleGetDataTreeViewAreaParams(Params: TDataAxisCellTreeViewAreaParamsEh);
begin
  if Assigned(OnGetDataTreeViewAreaParams) then
    OnGetDataTreeViewAreaParams(Self, TDataGridDataTreeViewAreaParamsEh(Params));
end;

procedure TDataGridEh.HandleSetDataTreeSignState(Params: TDataAxisCellTreeSignStateParamsEh);
begin
  if Assigned(OnSetDataTreeSignState) then
    OnSetDataTreeSignState(Self, TDataGridSetDataTreeSignStateParamsEh(Params));
end;

procedure TDataGridEh.HandleCanModifyCellValue(AParams: TDataAxisCellCanModifyParamsEh);
var
  Params: TDataGridDataCellCanModifyParamsEh;
begin
  if Assigned(OnDataCellCanModify) then
  begin
    Params := TDataGridDataCellCanModifyParamsEh.Create;
    Params.Init(AParams);
    try
      OnDataCellCanModify(Self, Params);
    finally
      Params.Free;
    end;
  end;
end;

{$ENDREGION 'TDataGridEh'}

{$REGION 'TDataGridStringColumnEh'}

function TDataGridStringColumnEh.CreateCellManager: TBaseGridCellManagerEh;
begin
  Result := TDataAxisTextCellManagerEh.Create(nil, Self);
end;

function TDataGridStringColumnEh.GetDefaultCellManager: TDataAxisTextCellManagerEh;
begin
  Result := TDataAxisTextCellManagerEh(FDefCellManager);
end;

function TDataGridStringColumnEh.GetDisplayFormat: String;
begin
  Result := DefaultCellManager.DisplayFormat;
end;

procedure TDataGridStringColumnEh.SetDisplayFormat(const Value: String);
begin
  DefaultCellManager.DisplayFormat := Value;
end;

function TDataGridStringColumnEh.GetDisplayFormatStored: Boolean;
begin
  Result := DefaultCellManager.DisplayFormatStored;
end;

procedure TDataGridStringColumnEh.SetDisplayFormatStored(const Value: Boolean);
begin
  DefaultCellManager.DisplayFormatStored := Value;
end;

function TDataGridStringColumnEh.IsDisplayFormatStored(): Boolean;
begin
  Result := DefaultCellManager.DisplayFormatStored;
end;

{$REGION WordWrap}
function TDataGridStringColumnEh.GetWordWrap: Boolean;
begin
  if IsWordWrapStored
    then Result := FWordWrap
    else Result := DefaultWordWrap();
end;

procedure TDataGridStringColumnEh.SetWordWrap(const Value: Boolean);
begin
  if (IsWordWrapStored = False) or (Value <> FWordWrap) then
  begin
    FWordWrap := Value;
    FWordWrapStored := True;
    Changed();
  end;
end;

function TDataGridStringColumnEh.DefaultWordWrap: Boolean;
begin
  if (GetGrid <> nil)
    then Result := TCustomDataGridEhCrack(GetGrid).FieldBarOptions.WordWrap
    else Result := False;
end;

function TDataGridStringColumnEh.IsWordWrapStored: Boolean;
begin
  Result := FWordWrapStored;
end;

procedure TDataGridStringColumnEh.SetWordWrapStored(const Value: Boolean);
begin
  if FWordWrapStored <> Value then
  begin
    FWordWrapStored := Value;
    Changed();
  end;
end;
{$ENDREGION WordWrap}

{$REGION Trimming}
function TDataGridStringColumnEh.GetTrimming: TTextTrimming;
begin
  if IsTrimmingStored
    then Result := FTrimming
    else Result := DefaultTrimming();
end;

procedure TDataGridStringColumnEh.SetTrimming(const Value: TTextTrimming);
begin
  if (IsTrimmingStored = False) or (Value <> FTrimming) then
  begin
    FTrimming := Value;
    FTrimmingStored := True;
    Changed();
  end;
end;

function TDataGridStringColumnEh.DefaultTrimming: TTextTrimming;
begin
  if (GetGrid <> nil)
    then Result := TCustomDataGridEhCrack(GetGrid).FieldBarOptions.Trimming
    else Result := TTextTrimming.None;
end;

function TDataGridStringColumnEh.IsTrimmingStored: Boolean;
begin
  Result := FTrimmingStored;
end;

procedure TDataGridStringColumnEh.SetTrimmingStored(const Value: Boolean);
begin
  if FTrimmingStored <> Value then
  begin
    FTrimmingStored := Value;
    Changed();
  end;
end;
{$ENDREGION Trimming}

procedure TDataGridStringColumnEh.InitCell(ACell: TGridBaseCellEh; AStyleParams: TDataAxisCellStyleParamsEh);
var
  TextDataCell: TDataAxisTextCellEh;
  StringStyleParams: TDataAxisStringCellStyleParamsEh;
const
  LaHorzAlignments: array [TTextAlign] of TLaHorzAlignmentEh =
    (TLaHorzAlignmentEh.Center, TLaHorzAlignmentEh.Left, TLaHorzAlignmentEh.Right);
begin
  inherited InitCell(ACell, AStyleParams);

  if ACell is TDataAxisTextCellEh then
  begin
    TextDataCell := TDataAxisTextCellEh(ACell);
{ TODO : Use AStyleParams TStringDataCellStyleParamsEh from StringDataCellManager}
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

procedure TDataGridStringColumnEh.InitStyleParams(Params: TDataAxisCellStyleParamsEh);
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

procedure TDataGridStringColumnEh.DefaultInitEditParams(Params: TBaseGridCellEditParamsEh);
var
  StringParams: TDataAxisStringCellEditParamsEh;
begin
  inherited DefaultInitEditParams(Params);
  if Params is TDataAxisStringCellEditParamsEh then
  begin
    StringParams:= TDataAxisStringCellEditParamsEh(Params);
    StringParams.EditorWordWrap := WordWrap;
  end;
end;

procedure TDataGridStringColumnEh.DefaultInitCellEditor(AInitEditorParams: TBaseGridInitEditorParamsEh);
var
  InplaceTextEdit: TLaInplaceTextEdit;
begin
  inherited DefaultInitCellEditor(AInitEditorParams);

  if (AInitEditorParams.Editor is TLaInplaceTextEdit) then
  begin
    InplaceTextEdit := TLaInplaceTextEdit(AInitEditorParams.Editor);
    InplaceTextEdit.TextSettings.WordWrap := WordWrap;

    if AInitEditorParams.Cell is TDataAxisCellEh then
    begin
      InplaceTextEdit.ReadOnly := TDataAxisCellEh(AInitEditorParams.Cell).ReadOnly;
    end;
  end;
end;

procedure TDataGridStringColumnEh.HandleGetFieldBarStyleParams(Params: TDataAxisCellStyleParamsEh);
var
  GridParams: TDataGridStringDataCellStyleParamsEh;
begin
  if Assigned(OnDataCellGetStyleParams) then
  begin
    GridParams := TDataGridStringDataCellStyleParamsEh.Create;
    GridParams.Init(Params);
    try
      OnDataCellGetStyleParams(Self, GridParams);
    finally
      GridParams.Free;
    end;
  end;
end;

procedure TDataGridStringColumnEh.HandleDataCellInTextLinkClick(Params: TDataAxisCellInTextLinkClickParamsEh);
var
  GridParams: TDataGridDataCellInTextLinkClickParamsEh;
begin
  if Assigned(OnDataCellInTextLinkClick) then
  begin
    GridParams := TDataGridDataCellInTextLinkClickParamsEh.Create;
    GridParams.Init(Params);
    try
      OnDataCellInTextLinkClick(Self, GridParams);
    finally
      GridParams.Free;
    end;
  end;
end;

{$ENDREGION 'TDataGridStringColumnEh'}

{$REGION 'TDataGridComboboxColumnEh'}

{ TDataGridComboboxColumnEh }

constructor TDataGridComboboxColumnEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TDataGridComboboxColumnEh.Destroy;
begin
  inherited Destroy;
end;

function TDataGridComboboxColumnEh.GetDefCellManager: TDataAxisGridComboboxCellManagerEh;
begin
  Result := TDataAxisGridComboboxCellManagerEh(FDefCellManager);
end;

function TDataGridComboboxColumnEh.GetIsLookupMode: Boolean;
begin
  Result := DefCellManager.IsLookupMode;
end;

function TDataGridComboboxColumnEh.CreateCellManager: TBaseGridCellManagerEh;
begin
  FDropDownBox := TDataGridComboDropDownBoxEh.Create(Self);
  Result := TDataAxisGridComboboxCellManagerEh.Create(nil, Self, FDropDownBox);
end;

function TDataGridComboboxColumnEh.CreateDropDownBox: TBaseDataAxisGridComboDropDownBoxEh;
begin
  Result := TDataGridComboDropDownBoxEh.Create(Self);
end;

function TDataGridComboboxColumnEh.GetListFieldName: String;
begin
  Result := DefCellManager.ListFieldName;
end;

procedure TDataGridComboboxColumnEh.SetListFieldName(const Value: String);
begin
  if DefCellManager.ListFieldName <> Value then
  begin
    DefCellManager.ListFieldName := Value;
    Changed(True);
  end;
end;

function TDataGridComboboxColumnEh.GetListKeyFieldName: String;
begin
  Result := DefCellManager.ListKeyFieldName;
end;

procedure TDataGridComboboxColumnEh.SetListKeyFieldName(const Value: String);
begin
  if DefCellManager.ListKeyFieldName <> Value then
  begin
    DefCellManager.ListKeyFieldName := Value;
    Changed(True);
  end;
end;

function TDataGridComboboxColumnEh.GetListSource: TComponent;
begin
  Result := DefCellManager.ListSource;
end;

procedure TDataGridComboboxColumnEh.SetListSource(const Value: TComponent);
begin
  if DefCellManager.ListSource <> Value then
  begin
    DefCellManager.ListSource := Value;
    Changed(True);
  end;
end;

procedure TDataGridComboboxColumnEh.BindField;
begin
  inherited BindField;
end;

function TDataGridComboboxColumnEh.DefaultGetLookupDisplayText(const VarValue: TValue): String;
begin
  Result := DefCellManager.GetLookupDisplayText(VarValue);
end;

procedure TDataGridComboboxColumnEh.DefaultSetValue(const Value: TValue);
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

function TDataGridComboboxColumnEh.GetDropDownBox: TDataGridComboDropDownBoxEh;
begin
  Result := TDataGridComboDropDownBoxEh(DefCellManager.DropDownBox);
end;

function TDataGridComboboxColumnEh.GetListItems: TStrings;
begin
  Result := DefCellManager.ListItems;
end;

procedure TDataGridComboboxColumnEh.SetListItems(const Value: TStrings);
begin
  DefCellManager.ListItems := Value;
end;

{$ENDREGION}

{$REGION 'TDataGridCheckboxColumnEh'}

function TDataGridCheckboxColumnEh.CanEditShow: Boolean;
begin
  Result := False;
end;

function TDataGridCheckboxColumnEh.CreateCellManager: TBaseGridCellManagerEh;
begin
  Result := TDataAxisCheckboxCellManagerEh.Create(nil, Self);
end;

function TDataGridCheckboxColumnEh.GetIsChecked(ARow: TDataGridRowEh): Boolean;
begin
  if ARow is TDataGridDataRowEh
    then Result := DefCellManager.IsChecked[Self, TDataGridDataRowEh(ARow).TableRow]
    else Result := False;
end;

procedure TDataGridCheckboxColumnEh.InitCell(ACell: TGridBaseCellEh; AStyleParams: TDataAxisCellStyleParamsEh);
begin
  inherited InitCell(ACell, AStyleParams);
end;

procedure TDataGridCheckboxColumnEh.Toggle;
var
  Grid: TCustomDataGridEhCrack;
  VarValue: TValue;
  RowView: TTableRowLinkEh;
begin
  if (Field <> nil) then
  begin
    Grid := TCustomDataGridEhCrack(GetGrid);
    Grid.TableView.EditCurrentRow;
    RowView := Grid.TableView.CurrentRowView.SourceRowLink;
    VarValue := RowView.FieldValue[Field];
    if SameValue(VarValue, CheckedValue)
      then RowView.FieldValue[Field] := UncheckedValue
      else RowView.FieldValue[Field] := CheckedValue;
  end;
end;

function TDataGridCheckboxColumnEh.GetDefCellManager: TDataAxisCheckboxCellManagerEh;
begin
  Result := TDataAxisCheckboxCellManagerEh(FDefCellManager);
end;

function TDataGridCheckboxColumnEh.GetCheckedValue: TValue;
begin
  Result := DefCellManager.CheckedValue;
end;

procedure TDataGridCheckboxColumnEh.SetCheckedValue(const Value: TValue);
begin
  if (DefCellManager.CheckedValue.TypeInfo <> Value.TypeInfo) or
     (SameValue(DefCellManager.CheckedValue, Value) = False) then
  begin
    DefCellManager.CheckedValue := Value;
    Changed();
  end;
end;

function TDataGridCheckboxColumnEh.GetUncheckedValue: TValue;
begin
  Result := DefCellManager.UncheckedValue;
end;

procedure TDataGridCheckboxColumnEh.SetUncheckedValue(const Value: TValue);
begin
  if (DefCellManager.UncheckedValue.TypeInfo <> Value.TypeInfo) or
     (SameValue(DefCellManager.UncheckedValue, Value) = False) then
  begin
    DefCellManager.UncheckedValue := Value;
    Changed();
  end;
end;

function TDataGridCheckboxColumnEh.IsCheckedValueStored: Boolean;
begin
  if SameValue(CheckedValue, True)
    then Result := False
    else Result := True;
end;

function TDataGridCheckboxColumnEh.IsUncheckedValueStored: Boolean;
begin
  if SameValue(UncheckedValue, False)
    then Result := False
    else Result := True;
end;

{$ENDREGION 'TDataGridCheckboxColumnEh'}

{$REGION 'TDataGridGraphicColumnEh'}

{ TDataGridGraphicColumnEh }

function TDataGridGraphicColumnEh.CreateCellManager: TBaseGridCellManagerEh;
begin
  Result := TDataAxisGraphicCellManagerEh.Create(nil, Self);
end;

function TDataGridGraphicColumnEh.GetDefCellManager: TDataAxisGraphicCellManagerEh;
begin
  Result := TDataAxisGraphicCellManagerEh(FDefCellManager);
end;

function TDataGridGraphicColumnEh.CanEditShow: Boolean;
begin
  Result := False;
end;

procedure TDataGridGraphicColumnEh.InitCell(ACell: TGridBaseCellEh; AStyleParams: TDataAxisCellStyleParamsEh);
begin
  inherited InitCell(ACell, AStyleParams);
end;

function TDataGridGraphicColumnEh.GetImageList: TCustomImageList;
begin
  Result := DefCellManager.ImageList;
end;

procedure TDataGridGraphicColumnEh.SetImageList(const Value: TCustomImageList);
begin
  if DefCellManager.ImageList <> Value then
  begin
    DefCellManager.ImageList := Value;
    Changed();
  end;
end;

{$ENDREGION 'TDataGridGraphicColumnEh'}

{$REGION 'TDataGridGetDataCellValueParamsEh'}

{ TDataGridDataCellGetValueParamsEh }

function TDataGridDataCellGetValueParamsEh.GetColumn: TDataGridBaseColumnEh;
begin
  Result := TDataGridBaseColumnEh(FieldBar);
end;

function TDataGridDataCellGetValueParamsEh.GetGrid: TDataGridEh;
begin
  Result := TDataGridEh(inherited Grid);
end;

function TDataGridDataCellGetValueParamsEh.GetRow: TDataGridRowEh;
begin
  if ListItemBar <> nil
    then Result := TDataGridTableRowEh(ListItemBar).GridDataRow
    else Result := nil;
end;

{$ENDREGION 'TDataGridGetDataCellValueParamsEh'}

{$REGION 'TDataGridDataCellGetDisplayTextParamsEh'}

{ TDataGridDataCellGetDisplayTextParamsEh }

function TDataGridDataCellGetDisplayTextParamsEh.GetColumn: TDataGridBaseColumnEh;
begin
  Result := TDataGridBaseColumnEh(FieldBar);
end;

function TDataGridDataCellGetDisplayTextParamsEh.GetGrid: TDataGridEh;
begin
  Result := TDataGridEh(inherited Grid);
end;

{$ENDREGION 'TDataGridDataCellGetDisplayTextParamsEh'}

{$REGION 'TDataGridColumnEh'}

{ TDataGridColumnEh }

function TDataGridColumnEh.CreateFooters: TDataGridBaseColumnFootersEh;
begin
  Result := TDataGridColumnFootersEh.Create(Self, TDataGridColumnFooterEh);
end;

function TDataGridColumnEh.CreateGetBarValueEventParams: TDataAxisGridGetBarValueParamsEh;
begin
  Result := TDataGridDataCellGetValueParamsEh.Create();
end;

function TDataGridColumnEh.CreateGetDisplayTextParams: TDataAxisGridGetDisplayTextParamsEh;
begin
  Result := TDataGridDataCellGetDisplayTextParamsEh.Create();
end;

procedure TDataGridColumnEh.HandleDataCellGetValue(Params: TDataAxisGridGetBarValueParamsEh);
begin
  if Assigned(OnDataCellGetValue) then
    OnDataCellGetValue(Self, TDataGridDataCellGetValueParamsEh(Params));
end;

procedure TDataGridColumnEh.HandleDataCellMouseDownEvent(Params: TGridCellMouseButtonParamsEh);
var
  GridParams: TDataGridDataCellMouseButtonParamsEh;
begin
  if Assigned(OnDataCellMouseDown) then
  begin
    GridParams := TDataGridDataCellMouseButtonParamsEh.Create;
    GridParams.Init(Params as TDataAxisCellMouseButtonParamsEh);
    try
      OnDataCellMouseDown(Self, GridParams);
    finally
      GridParams.Free;
    end;
  end;
end;

function TDataGridColumnEh.CreateSetBarValueEventParams(): TDataAxisGridSetBarValueParamsEh;
begin
  Result := TDataGridDataCellSetValueParamsEh.Create();
end;

procedure TDataGridColumnEh.HandleDataCellSetValue(Params: TDataAxisGridSetBarValueParamsEh);
begin
  if Assigned(OnDataCellSetValue) then
    OnDataCellSetValue(Self, TDataGridDataCellSetValueParamsEh(Params));
end;

procedure TDataGridColumnEh.HandleDataCellGetDisplayText(Params: TDataAxisGridGetDisplayTextParamsEh);
begin
  if Assigned(OnDataCellGetDisplayText) then
    OnDataCellGetDisplayText(Self, TDataGridDataCellGetDisplayTextParamsEh(Params));
end;

procedure TDataGridColumnEh.HandleDataCellKeyDownEvent(Params: TBaseGridCellKeyDownParamsEh);
begin
  inherited HandleDataCellKeyDownEvent(Params);
end;

function TDataGridColumnEh.CreateFieldBarStyleParams: TFieldBarDataCellStyleParamsEh;
begin
  Result := TDataGridDataCellStyleParamsEh.Create;
end;

function TDataGridColumnEh.GetFooters: TDataGridColumnFootersEh;
begin
  Result := TDataGridColumnFootersEh(inherited Footers);
end;

procedure TDataGridColumnEh.SetFooters(const Value: TDataGridColumnFootersEh);
begin
  inherited Footers := Value;
end;

procedure TDataGridColumnEh.HandleGetFieldBarStyleParams(Params: TDataAxisCellStyleParamsEh);
var
  GridParams: TDataGridDataCellStyleParamsEh;
begin
  if Assigned(OnDataCellGetStyleParams) then
  begin
    GridParams := TDataGridDataCellStyleParamsEh.Create;
    GridParams.Init(Params);
    try
      OnDataCellGetStyleParams(Self, GridParams);
    finally
      GridParams.Free;
    end;
  end;
end;

function TDataGridColumnEh.CreateGetCellManagerParams: TBaseDataGridGetDataCellManagerParamsEh;
begin
  Result := TDataGridGetDataCellManagerParamsEh.Create;
end;

procedure TDataGridColumnEh.HandleGetDataCellManager(Params: TBaseDataGridGetDataCellManagerParamsEh);
begin
  inherited HandleGetDataCellManager(Params);
  if Assigned(OnGetDataCellManager) then
    OnGetDataCellManager(Self, TDataGridGetDataCellManagerParamsEh(Params));
end;

procedure TDataGridColumnEh.HandleInitDataCell(Params: TPersistent);
begin
end;

procedure TDataGridColumnEh.HandleCreateCellContent(Params: TBaseGridCreateCellContentParamsEh);
var
  GridParams: TDataGridCreateDataCellContentParamsEh;
begin
  if Assigned(OnCreateDataCellContent) then
  begin
    GridParams := TDataGridCreateDataCellContentParamsEh.Create;
    GridParams.Init(Params as TDataAxisCreateCellContentParamsEh);
    try
      OnCreateDataCellContent(Self, GridParams);
    finally
      GridParams.Free;
    end;
  end;
end;

procedure TDataGridColumnEh.HandleDataCellInitContent(Params: TBaseGridInitCellContentParamsEh);
var
  GridParams: TDataGridInitDataCellContentParamsEh;
begin
  if Assigned(OnDataCellInitContent) and (Params is TDataAxisInitCellContentParamsEh) then
  begin
    GridParams := TDataGridInitDataCellContentParamsEh.Create;
    GridParams.Init(TDataAxisInitCellContentParamsEh(Params));
    try
      OnDataCellInitContent(Self, GridParams);
    finally
      GridParams.Free;
    end;
  end;
end;

procedure TDataGridColumnEh.HandleInitCellEditor(AParams: TBaseGridInitEditorParamsEh);
var
  GridParams: TDataGridInitEditorParamsEh;
begin
  if Assigned(OnDataCellInitEditor) then
  begin
    GridParams := TDataGridInitEditorParamsEh.Create;
    GridParams.Init(AParams);
    try
      OnDataCellInitEditor(Self, GridParams);
    finally
      GridParams.Free;
    end;
  end;
end;

procedure TDataGridColumnEh.HandleDataCellInitEditParams(AParams: TBaseGridCellEditParamsEh);
var
  GridParams: TDataGridDataCellInitEditParamsEh;
begin
  if Assigned(OnDataCellInitEditParams) then
  begin
    GridParams := TDataGridDataCellInitEditParamsEh.Create;
    GridParams.Init(AParams as TDataAxisCellEditParamsEh);
    try
      OnDataCellInitEditParams(Self, GridParams);
    finally
      GridParams.Free;
    end;
  end;
end;

procedure TDataGridColumnEh.HandleDataCellStartEdit(Params: TPersistent);
var
  GridParams: TDataGridDataCellStartEditParamsEh;
begin
  if Assigned(OnDataCellStartEdit) then
  begin
    GridParams := TDataGridDataCellStartEditParamsEh.Create;
    GridParams.Init(Params as TDataAxisCellStartEditParamsEh);
    try
      OnDataCellStartEdit(Self, GridParams);
    finally
      GridParams.Free;
    end;
  end;
end;

procedure TDataGridColumnEh.HandleCanModifyCellValue(AParams: TDataAxisCellCanModifyParamsEh);
var
  Params: TDataGridDataCellCanModifyParamsEh;
begin
  if Assigned(OnDataCellCanModify) then
  begin
    Params := TDataGridDataCellCanModifyParamsEh.Create;
    Params.Init(AParams);
    try
      OnDataCellCanModify(Self, Params);
    finally
      Params.Free;
    end;
  end;
end;

{$ENDREGION 'TDataGridColumnEh'}

{$REGION 'TDataGridLayoutColumnEh'}

{ TDataGridLayoutColumnEh }

function TDataGridLayoutColumnEh.CreateCellManager: TBaseGridCellManagerEh;
begin
  Result := TDataAxisLayoutCellManagerEh.Create(nil, Self);
end;

function TDataGridLayoutColumnEh.DefaultAllowShowEditor: Boolean;
begin
  Result := False;
end;

{$ENDREGION 'TDataGridLayoutColumnEh'}

{$REGION 'TDataGridDataCellSetValueParamsEh'}

{ TDataGridDataCellSetValueParamsEh }

function TDataGridDataCellSetValueParamsEh.GetColumn: TDataGridBaseColumnEh;
begin
  Result := TDataGridBaseColumnEh(FieldBar);
end;

function TDataGridDataCellSetValueParamsEh.GetGrid: TDataGridEh;
begin
  Result := TDataGridEh(inherited Grid);
end;

function TDataGridDataCellSetValueParamsEh.GetRow: TDataGridRowEh;
begin
//  Result := TDataGridRowEh(ListItemBar);
  if ListItemBar = nil
    then Result := nil
    else Result := TDataGridTableRowEh(ListItemBar).GridDataRow;
end;

{$ENDREGION 'TDataGridDataCellSetValueParamsEh'}

{$REGION 'TDataGridDataCellStyleParamsEh'}

{ TDataGridDataCellStyleParamsEh }

function TDataGridDataCellStyleParamsEh.GetGrid: TDataGridEh;
begin
  Result := TDataGridEh(inherited Grid);
end;

{$ENDREGION 'TDataGridDataCellStyleParamsEh'}

{$REGION 'TDataGridDataCellKeyDownParamsEh'}

{ TDataGridDataCellKeyDownParamsEh }

function TDataGridDataCellKeyDownParamsEh.GetGrid: TDataGridEh;
begin
  Result := TDataGridEh(inherited Grid);
end;

procedure TDataGridDataCellKeyDownParamsEh.Reset(AGrid: TControl;
  ACellManager: TBaseGridCellManagerEh; AColIndex: Integer; ARowIndex: Integer;
  AAreaColIndex: Integer; AAreaRowIndex: Integer;
  AKey: Word; AKeyChar: WideChar; AShift: TShiftState);
var
  VGrid: TCustomDataGridEhCrack;
begin
  VGrid := TCustomDataGridEhCrack(AGrid);

  inherited Reset(AGrid, ACellManager, AColIndex, ARowIndex, AAreaColIndex, AAreaRowIndex, AKey, AKeyChar, AShift);

  if (AreaColIndex >= 0) and (AreaColIndex < VGrid.VisibleColumns.Count) then
    FColumn := VGrid.VisibleColumns[AreaColIndex]
  else
    FColumn := nil;

  if (AreaRowIndex >= 0) and (AreaRowIndex < VGrid.VisibleRows.Count) then
    FRow := VGrid.VisibleRows[AreaRowIndex]
  else
    FRow := nil;
end;

{$ENDREGION 'TDataGridDataCellKeyDownParamsEh'}

{$REGION 'TDataGridDataCellMouseButtonParamsEh'}

{ TDataGridDataCellMouseButtonParamsEh }

procedure TDataGridDataCellMouseButtonParamsEh.Init(AAxisCellParams: TDataAxisCellMouseButtonParamsEh);
begin
  FAxisCellParams := AAxisCellParams;
end;

function TDataGridDataCellMouseButtonParamsEh.GetGrid: TDataGridEh;
begin
  Result := TDataGridEh(FAxisCellParams.Grid);
end;

function TDataGridDataCellMouseButtonParamsEh.GetCell: TGridBaseCellEh;
begin
  Result := TGridBaseCellEh(FAxisCellParams.Cell);
end;

function TDataGridDataCellMouseButtonParamsEh.GetColumn: TDataGridBaseColumnEh;
begin
  Result := TDataGridBaseColumnEh(FAxisCellParams.FieldBar);
end;

function TDataGridDataCellMouseButtonParamsEh.GetRow: TDataGridRowEh;
begin
  if FAxisCellParams.ListItemBar <> nil
    then Result := TDataGridTableRowEh(FAxisCellParams.ListItemBar).GridDataRow
    else Result := nil;
end;

function TDataGridDataCellMouseButtonParamsEh.GetShift: TShiftState;
begin
  Result := FAxisCellParams.BaseParams.Shift;
end;

function TDataGridDataCellMouseButtonParamsEh.GetButton: TMouseButton;
begin
  Result := FAxisCellParams.BaseParams.Button;
end;

procedure TDataGridDataCellMouseButtonParamsEh.SetHandled(const Value: Boolean);
begin
  FAxisCellParams.Handled := Value;
end;

function TDataGridDataCellMouseButtonParamsEh.GetHandled: Boolean;
begin
  Result := FAxisCellParams.Handled;
end;

{$ENDREGION 'TDataGridDataCellMouseButtonParamsEh'}

{$REGION 'TDataGridFooterCalcFinalDataParamsEh'}

{ TDataGridFooterCalcFinalDataParamsEh }

function TDataGridFooterCalcFinalDataParamsEh.GetColumn: TDataGridColumnEh;
begin
  Result := TDataGridColumnEh(inherited Column);
end;

function TDataGridFooterCalcFinalDataParamsEh.GetGrid: TDataGridEh;
begin
  Result := TDataGridEh(inherited Grid);
end;
{$ENDREGION 'TDataGridFooterCalcFinalDataParamsEh'}

{$REGION 'TDataGridColumnFootersEh'}

{ TDataGridColumnFootersEh }

function TDataGridColumnFootersEh.GetFooter(Index: Integer): TDataGridColumnFooterEh;
begin
  Result := TDataGridColumnFooterEh(inherited Items[Index]);
end;

procedure TDataGridColumnFootersEh.SetFooter(Index: Integer; const Value: TDataGridColumnFooterEh);
begin
  inherited Items[Index] := Value;
end;

{$ENDREGION 'TDataGridColumnFootersEh'}

{$REGION 'TDataGridColumnFooterEh'}

{ TDataGridColumnFooterEh }

function TDataGridColumnFooterEh.CreateCalcFinalDataParams: TBaseDataGridFooterCalcFinalDataParamsEh;
begin
  Result := TDataGridFooterCalcFinalDataParamsEh.Create;
end;

function TDataGridColumnFooterEh.CreateCalcInitDataParams: TBaseDataGridFooterCalcInitDataParamsEh;
begin
  Result := TDataGridFooterCalcInitDataParamsEh.Create;
end;

function TDataGridColumnFooterEh.CreateCalcStepDataParams: TBaseDataGridFooterCalcStepDataParamsEh;
begin
  Result := TDataGridFooterCalcStepDataParamsEh.Create;
end;

function TDataGridColumnFooterEh.CreateGetDisplayTextParams: TBaseDataGridFooterGetDisplayTextParamsEh;
begin
  Result := TDataGridFooterGetDisplayTextParamsEh.Create;
end;

procedure TDataGridColumnFooterEh.HandleCalcFinalData(AFinalDataParams: TBaseDataGridFooterCalcFinalDataParamsEh);
begin
  if Assigned(OnCalcFinalData) then
    OnCalcFinalData(Self, TDataGridFooterCalcFinalDataParamsEh(AFinalDataParams));
end;

procedure TDataGridColumnFooterEh.HandleCalcInitData(AInitDataParams: TBaseDataGridFooterCalcInitDataParamsEh);
begin
  if Assigned(OnCalcInitData) then
    OnCalcInitData(Self, TDataGridFooterCalcInitDataParamsEh(AInitDataParams));
end;

procedure TDataGridColumnFooterEh.HandleCalcStepData(AStepDataParams: TBaseDataGridFooterCalcStepDataParamsEh);
begin
  if Assigned(OnCalcStepData) then
    OnCalcStepData(Self, TDataGridFooterCalcStepDataParamsEh(AStepDataParams));
end;

procedure TDataGridColumnFooterEh.HandleGetDisplayText(Params: TBaseDataGridFooterGetDisplayTextParamsEh);
begin
  if Assigned(OnGetDisplayText) then
    OnGetDisplayText(Self, TDataGridFooterGetDisplayTextParamsEh(Params));
end;

{$ENDREGION 'TDataGridColumnFooterEh'}

{$REGION 'TDataGridFooterGetDisplayTextParamsEh'}

{ TDataGridFooterGetDisplayTextParamsEh }

function TDataGridFooterGetDisplayTextParamsEh.GetColumn: TDataGridColumnEh;
begin
  Result := TDataGridColumnEh(inherited Column);
end;

function TDataGridFooterGetDisplayTextParamsEh.GetGrid: TDataGridEh;
begin
  Result := TDataGridEh(inherited Grid);
end;

{$ENDREGION 'TDataGridFooterGetDisplayTextParamsEh'}

{$REGION 'TDataGridFooterCalcStepDataParamsEh'}

{ TDataGridFooterCalcStepDataParamsEh }

function TDataGridFooterCalcStepDataParamsEh.GetColumn: TDataGridColumnEh;
begin
  Result := TDataGridColumnEh(inherited Column);
end;

function TDataGridFooterCalcStepDataParamsEh.GetGrid: TDataGridEh;
begin
  Result := TDataGridEh(inherited Grid);
end;

{$ENDREGION 'TDataGridFooterCalcStepDataParamsEh'}

{$REGION 'TDataGridFooterCalcInitDataParamsEh'}

{ TDataGridFooterCalcInitDataParamsEh }

function TDataGridFooterCalcInitDataParamsEh.GetColumn: TDataGridColumnEh;
begin
  Result := TDataGridColumnEh(inherited Column);
end;

function TDataGridFooterCalcInitDataParamsEh.GetGrid: TDataGridEh;
begin
  Result := TDataGridEh(inherited Grid);
end;

{$ENDREGION 'TDataGridFooterCalcInitDataParamsEh'}

{$REGION 'TDataGridCanSelectRowParamsEh'}

{ TDataGridCanSelectRowParamsEh }

function TDataGridCanSelectRowParamsEh.GetGrid: TDataGridEh;
begin
  Result := TDataGridEh(inherited Grid);
end;

{$ENDREGION 'TDataGridCanSelectRowParamsEh'}

{$REGION 'TDataGridEventParamsEh'}

{ TDataGridEventParamsEh }

constructor TDataGridEventParamsEh.Create;
begin
end;

procedure TDataGridEventParamsEh.Init(AGrid: TDataGridEh);
begin
  FGrid := AGrid;
end;
{$ENDREGION 'TDataGridEventParamsEh'}

{$REGION 'TDataGridColumnWidthChangedParamsEh'}

{ TDataGridColumnWidthChangedParamsEh }

procedure TDataGridColumnWidthChangedParamsEh.Init(AGrid: TDataGridEh;
  AColumn: TDataGridBaseColumnEh);
begin
  inherited Init(AGrid);
  FColumn := AColumn;
end;

{$ENDREGION 'TDataGridColumnWidthChangedParamsEh'}

{$REGION 'TDataGridGetDataCellManagerParamsEh'}

{ TDataGridGetDataCellManagerParamsEh }

function TDataGridGetDataCellManagerParamsEh.GetGrid: TDataGridEh;
begin
  Result := TDataGridEh(inherited Grid);
end;

{$ENDREGION 'TDataGridGetDataCellManagerParamsEh'}

{$REGION 'TDataGridInitDataCellContentParamsEh'}

{ TDataGridInitDataCellContentParamsEh }

procedure TDataGridInitDataCellContentParamsEh.Init(AAxisCellParams: TDataAxisInitCellContentParamsEh);
begin
  FAxisCellParams := AAxisCellParams;
end;

function TDataGridInitDataCellContentParamsEh.GetCell: TGridBaseCellEh;
begin
  Result := FAxisCellParams.Cell;
end;

function TDataGridInitDataCellContentParamsEh.GetCellContent: TLaObjectEh;
begin
  Result := FAxisCellParams.CellContent;
end;

function TDataGridInitDataCellContentParamsEh.GetCellManager: TVPBaseCellManagerEh;
begin
  Result := FAxisCellParams.CellManager;
end;

function TDataGridInitDataCellContentParamsEh.GetColumn: TDataGridBaseColumnEh;
begin
  Result := TDataGridBaseColumnEh(FAxisCellParams.FieldBar);
end;

function TDataGridInitDataCellContentParamsEh.GetGrid: TDataGridEh;
begin
  Result := TDataGridEh(FAxisCellParams.Grid);
end;

function TDataGridInitDataCellContentParamsEh.GetRow: TDataGridRowEh;
begin
  if FAxisCellParams.ListItemBar <> nil
    then Result := TDataGridTableRowEh(FAxisCellParams.ListItemBar).GridDataRow
    else Result := nil;
end;

function TDataGridInitDataCellContentParamsEh.GetStyleParams: TDataAxisCellStyleParamsEh;
begin
  Result := FAxisCellParams.StyleParams;
end;

function TDataGridInitDataCellContentParamsEh.GetHandled: Boolean;
begin
  Result := FAxisCellParams.Handled;
end;

procedure TDataGridInitDataCellContentParamsEh.SetHandled(const Value: Boolean);
begin
  FAxisCellParams.Handled := Value;
end;
{$ENDREGION 'TDataGridInitDataCellContentParamsEh'}

{$REGION 'TDataGridFilterRowParamsEh'}

{ TDataGridFilterRowParamsEh }

function TDataGridFilterRowParamsEh.GetGrid: TDataGridEh;
begin
  Result := TDataGridEh(inherited Grid);
end;
{$ENDREGION 'TDataGridFilterRowParamsEh'}

{$REGION 'TDataGridCreateDataCellContentParamsEh'}

{ TDataGridCreateDataCellContentParamsEh }

procedure TDataGridCreateDataCellContentParamsEh.Init(AAxisCellParams: TDataAxisCreateCellContentParamsEh);
begin
  FAxisCellParams := AAxisCellParams;
end;

function TDataGridCreateDataCellContentParamsEh.GetCellContent: TLaObjectEh;
begin
  Result := FAxisCellParams.CellContent;
end;

procedure TDataGridCreateDataCellContentParamsEh.SetCellContent(const Value: TLaObjectEh);
begin
  FAxisCellParams.CellContent := Value;
end;

function TDataGridCreateDataCellContentParamsEh.GetCell: TGridBaseCellEh;
begin
  Result := FAxisCellParams.Cell;
end;

function TDataGridCreateDataCellContentParamsEh.GetContentParent: TLaObjectEh;
begin
  Result := FAxisCellParams.ContentParent;
end;

function TDataGridCreateDataCellContentParamsEh.GetGrid: TDataGridEh;
begin
  Result := TDataGridEh(FAxisCellParams.Grid);
end;

function TDataGridCreateDataCellContentParamsEh.DefaultCreateCellContent(AContentParent: TLaObjectEh): TLaObjectEh;
begin
  Result := FAxisCellParams.DefaultCreateCellContent(AContentParent);
end;
{$ENDREGION 'TDataGridCreateDataCellContentParamsEh'}

{$REGION 'TDataGridGetDataRowManagerParamsEh'}

{ TDataGridGetDataRowManagerParamsEh }

function TDataGridGetDataRowManagerParamsEh.GetGrid: TDataGridEh;
begin
  Result := TDataGridEh(inherited Grid);
end;

{$ENDREGION 'TDataGridGetDataRowManagerParamsEh'}

{$REGION 'TDataGridGetDataRowSplitWayParamsEh'}

{ TDataGridGetDataRowSplitWayParamsEh }

function TDataGridGetDataRowSplitWayParamsEh.GetGrid: TDataGridEh;
begin
  Result := TDataGridEh(inherited Grid);
end;

{$ENDREGION 'TDataGridGetDataRowSplitWayParamsEh'}

{$REGION 'TDataGridDataTreeViewAreaParamsEh'}

{ TDataGridDataTreeViewAreaParamsEh }

function TDataGridDataTreeViewAreaParamsEh.GetGrid: TDataGridEh;
begin
  Result := TDataGridEh(inherited Grid);
end;

function TDataGridDataTreeViewAreaParamsEh.GetRow: TDataGridRowEh;
begin
//  Result := TDataGridRowEh(ListItemBar);
  if ListItemBar = nil
    then Result := nil
    else Result := TDataGridTableRowEh(ListItemBar).GridDataRow;
end;

function TDataGridDataTreeViewAreaParamsEh.GetColumn: TDataGridBaseColumnEh;
begin
  Result := TDataGridBaseColumnEh(FieldBar);
end;

{$ENDREGION 'TDataGridDataTreeViewAreaParamsEh'}

{$REGION 'TDataGridSetDataTreeSignStateParamsEh'}

{ TDataGridSetDataTreeSignStateParamsEh }

function TDataGridSetDataTreeSignStateParamsEh.GetGrid: TDataGridEh;
begin
  Result := TDataGridEh(inherited Grid);
end;

function TDataGridSetDataTreeSignStateParamsEh.GetColumn: TDataGridBaseColumnEh;
begin
  Result := TDataGridBaseColumnEh(FieldBar);
end;

function TDataGridSetDataTreeSignStateParamsEh.GetRow: TDataGridRowEh;
begin
//  Result := TDataGridRowEh(ListItemBar);
  if ListItemBar = nil
    then Result := nil
    else Result := TDataGridTableRowEh(ListItemBar).GridDataRow;
end;

{$ENDREGION 'TDataGridSetDataTreeSignStateParamsEh'}

{$REGION 'TDataGridComboDropDownBoxEh'}

{ TDataGridComboDropDownBoxEh }

procedure TDataGridComboDropDownBoxEh.HandleCreateCellContent(Params: TBaseGridCreateCellContentParamsEh);
var
  GridParams: TDataGridCreateDataCellContentParamsEh;
begin
  if Assigned(OnCreateDataCellContent) then
  begin
    GridParams := TDataGridCreateDataCellContentParamsEh.Create;
    GridParams.Init(Params as TDataAxisCreateCellContentParamsEh);
    try
      OnCreateDataCellContent(Self, GridParams);
    finally
      GridParams.Free;
    end;
  end;
end;

procedure TDataGridComboDropDownBoxEh.HandleDataCellGetStyleParams(Params: TDataAxisCellStyleParamsEh);
var
  GridParams: TDataGridDataCellStyleParamsEh;
begin
  if Assigned(OnDataCellGetStyleParams) then
  begin
    GridParams := TDataGridDataCellStyleParamsEh.Create;
    GridParams.Init(Params);
    try
      OnDataCellGetStyleParams(Self, GridParams);
    finally
      GridParams.Free;
    end;
  end;
end;

procedure TDataGridComboDropDownBoxEh.HandleGetDataCellManager(Params: TPersistent);
begin
  if Assigned(OnGetDataCellManager) then
    OnGetDataCellManager(Self, TDataGridGetDataCellManagerParamsEh(Params));
end;

procedure TDataGridComboDropDownBoxEh.HandleInitDataCellContent(Params: TPersistent);
var
  GridParams: TDataGridInitDataCellContentParamsEh;
begin
  if Assigned(OnDataCellInitContent) and (Params is TDataAxisInitCellContentParamsEh) then
  begin
    GridParams := TDataGridInitDataCellContentParamsEh.Create;
    GridParams.Init(TDataAxisInitCellContentParamsEh(Params));
    try
      OnDataCellInitContent(Self, GridParams);
    finally
      GridParams.Free;
    end;
  end;
end;

{$ENDREGION 'TDataGridComboDropDownBoxEh'}

{$REGION 'TDataGridInitEditorParamsEh'}

{ TDataGridInitEditorParamsEh }

procedure TDataGridInitEditorParamsEh.Init(ABaseCellParams: TBaseGridInitEditorParamsEh);
begin
  FBaseCellParams := ABaseCellParams;
end;

function TDataGridInitEditorParamsEh.GetColumn: TDataGridBaseColumnEh;
begin
  Result := TDataGridBaseColumnEh(TDataAxisCellEh((FBaseCellParams).Cell).FieldBar);
end;

function TDataGridInitEditorParamsEh.GetRow: TDataGridRowEh;
var
  ListItemBar: TTableRowViewEh;
begin
  ListItemBar := TDataAxisCellEh((FBaseCellParams).Cell).ListItemBar;
  if ListItemBar <> nil
    then Result := TDataGridTableRowEh(ListItemBar).GridDataRow
    else Result := nil;
end;

function TDataGridInitEditorParamsEh.GetCell: TGridBaseCellEh;
begin
  Result := FBaseCellParams.Cell;
end;

function TDataGridInitEditorParamsEh.GetEditor: TLaObjectEh;
begin
  Result := FBaseCellParams.Editor;
end;

function TDataGridInitEditorParamsEh.GetEditParams: TBaseGridCellEditParamsEh;
begin
  Result := FBaseCellParams.EditorParams;
end;

function TDataGridInitEditorParamsEh.GetGrid: TDataGridEh;
begin
  Result := TDataGridEh(FBaseCellParams.Grid);
end;

function TDataGridInitEditorParamsEh.GetHandled: Boolean;
begin
  Result := FBaseCellParams.Handled;
end;

procedure TDataGridInitEditorParamsEh.SetHandled(const Value: Boolean);
begin
  FBaseCellParams.Handled := Value;
end;

{$ENDREGION 'TDataGridInitEditorParamsEh'}

{$REGION 'TDataGridStringDataCellStyleParamsEh'}

{ TDataGridStringDataCellStyleParamsEh }

function TDataGridStringDataCellStyleParamsEh.GetTrimming: TTextTrimming;
begin
  Result := (DataAxisCellParams as TDataAxisStringCellStyleParamsEh).Trimming;
end;

procedure TDataGridStringDataCellStyleParamsEh.SetTrimming(const Value: TTextTrimming);
begin
  (DataAxisCellParams as TDataAxisStringCellStyleParamsEh).Trimming := Value;
end;

function TDataGridStringDataCellStyleParamsEh.GetWordWrap: Boolean;
begin
  Result := (DataAxisCellParams as TDataAxisStringCellStyleParamsEh).WordWrap;
end;

procedure TDataGridStringDataCellStyleParamsEh.SetWordWrap(const Value: Boolean);
begin
  (DataAxisCellParams as TDataAxisStringCellStyleParamsEh).WordWrap := Value;
end;

function TDataGridStringDataCellStyleParamsEh.GetFormattedRanges: TList<TLaFormattedTextRangeEh>;
begin
  Result := (DataAxisCellParams as TDataAxisStringCellStyleParamsEh).FormattedRanges;
end;

{$ENDREGION 'TDataGridStringDataCellStyleParamsEh'}

{$REGION 'TDataGridDataCellInitEditParamsEh'}

{ TDataGridDataCellInitEditParamsEh }

procedure TDataGridDataCellInitEditParamsEh.Init(ACellParams: TDataAxisCellEditParamsEh);
begin
  FCellParams := ACellParams;
end;

function TDataGridDataCellInitEditParamsEh.GetGrid: TDataGridEh;
begin
  Result := TDataGridEh(FCellParams.Grid);
end;

function TDataGridDataCellInitEditParamsEh.GetColumn: TDataGridBaseColumnEh;
begin
  Result := TDataGridBaseColumnEh(FCellParams.FieldBar);
end;

function TDataGridDataCellInitEditParamsEh.GetRow: TDataGridRowEh;
begin
  if FCellParams.ListItemBar <> nil
    then Result := TDataGridTableRowEh(FCellParams.ListItemBar).GridDataRow
    else Result := nil;
end;

function TDataGridDataCellInitEditParamsEh.GetEditorReadOnly: Boolean;
begin
  Result := FCellParams.EditorReadOnly;
end;

procedure TDataGridDataCellInitEditParamsEh.SetEditorReadOnly(const Value: Boolean);
begin
  FCellParams.EditorReadOnly := Value;
end;

{$ENDREGION 'TDataGridDataCellInitEditParamsEh'}

{$REGION 'TDataGridDataCellStartEditParamsEh'}

{ TDataGridDataCellStartEditParamsEh }

procedure TDataGridDataCellStartEditParamsEh.Init(ACellParams: TDataAxisCellStartEditParamsEh);
begin
  FCellParams := ACellParams;
end;

function TDataGridDataCellStartEditParamsEh.GetGrid: TDataGridEh;
begin
  Result := TDataGridEh(FCellParams.Grid);
end;

function TDataGridDataCellStartEditParamsEh.GetColumn: TDataGridBaseColumnEh;
begin
  Result := TDataGridBaseColumnEh(FCellParams.FieldBar);
end;

function TDataGridDataCellStartEditParamsEh.GetRow: TDataGridRowEh;
begin
  if FCellParams.ListItemBar <> nil
    then Result := TDataGridTableRowEh(FCellParams.ListItemBar).GridDataRow
    else Result := nil;
end;

function TDataGridDataCellStartEditParamsEh.GetEditingActive: Boolean;
begin
  Result := FCellParams.EditingActive;
end;

procedure TDataGridDataCellStartEditParamsEh.SetEditingActive(const Value: Boolean);
begin
  FCellParams.EditingActive := Value;
end;

function TDataGridDataCellStartEditParamsEh.GetHandled: Boolean;
begin
  Result := FCellParams.Handled;
end;

procedure TDataGridDataCellStartEditParamsEh.SetHandled(const Value: Boolean);
begin
  FCellParams.Handled := Value;
end;

{$ENDREGION 'TDataGridDataCellStartEditParamsEh'}

{$REGION 'TDataGridDataCellCanModifyParamsEh'}

{ TDataGridDataCellCanModifyParamsEh }

procedure TDataGridDataCellCanModifyParamsEh.Init(ACellParams: TDataAxisCellCanModifyParamsEh);
begin
  FCellParams := ACellParams;
end;

function TDataGridDataCellCanModifyParamsEh.GetGrid: TDataGridEh;
begin
  Result := TDataGridEh(FCellParams.Grid);
end;

function TDataGridDataCellCanModifyParamsEh.GetColumn: TDataGridBaseColumnEh;
begin
  Result := TDataGridBaseColumnEh(FCellParams.FieldBar);
end;

function TDataGridDataCellCanModifyParamsEh.GetRow: TDataGridRowEh;
begin
  if FCellParams.ListItemBar <> nil
    then Result := TDataGridTableRowEh(FCellParams.ListItemBar).GridDataRow
    else Result := nil;
end;

function TDataGridDataCellCanModifyParamsEh.GetCanModify: Boolean;
begin
  Result := FCellParams.CanModify;
end;

procedure TDataGridDataCellCanModifyParamsEh.SetCanModify(const Value: Boolean);
begin
  FCellParams.CanModify := Value;
end;

function TDataGridDataCellCanModifyParamsEh.GetHandled: Boolean;
begin
  Result := FCellParams.Handled;
end;

procedure TDataGridDataCellCanModifyParamsEh.SetHandled(const Value: Boolean);
begin
  FCellParams.Handled := Value;
end;

{$ENDREGION 'TDataGridDataCellCanModifyParamsEh'}

{$REGION 'TDataGridDataCellInTextLinkClickParamsEh'}

{ TDataGridDataCellInTextLinkClickParamsEh }

procedure TDataGridDataCellInTextLinkClickParamsEh.Init(ACellParams: TDataAxisCellInTextLinkClickParamsEh);
begin
  FCellParams := ACellParams;
end;

function TDataGridDataCellInTextLinkClickParamsEh.GetGrid: TDataGridEh;
begin
  Result := TDataGridEh(FCellParams.Grid);
end;

function TDataGridDataCellInTextLinkClickParamsEh.GetColumn: TDataGridBaseColumnEh;
begin
  Result := TDataGridBaseColumnEh(FCellParams.FieldBar);
end;

function TDataGridDataCellInTextLinkClickParamsEh.GetRow: TDataGridRowEh;
begin
  if FCellParams.ListItemBar <> nil
    then Result := TDataGridTableRowEh(FCellParams.ListItemBar).GridDataRow
    else Result := nil;
end;

function TDataGridDataCellInTextLinkClickParamsEh.GetHandled: Boolean;
begin
  Result := FCellParams.Handled;
end;

procedure TDataGridDataCellInTextLinkClickParamsEh.SetHandled(const Value: Boolean);
begin
  FCellParams.Handled := Value;
end;

function TDataGridDataCellInTextLinkClickParamsEh.GetLinkText: String;
begin
  Result := FCellParams.SourceParams.LinkText;
end;

{$ENDREGION 'TDataGridDataCellInTextLinkClickParamsEh'}

initialization
  InitModule;
finalization
  FinalizeModule;
end.

