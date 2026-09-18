{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{           EhLibFmx.DataAxisGrid.FieldBars             }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataAxisGrid.FieldBars;

interface

{$SCOPEDENUMS ON}

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, System.Types,
  System.Contnrs, System.UITypes, System.Variants, System.Math, Data.DB,
  Data.FmtBcd, Data.SqlTimSt, Rtti, TypInfo,
  FMX.Menus, FMX.Graphics, FMX.Forms,
  FMX.Platform,
  System.Generics.Collections, System.Generics.Defaults,
  EhLibUtils, DBUtilsEh,
  EhLib.TableLinks,
  EhLib.GridTableViews,
  EhLibFmx.Utils,
  EhLibFmx.LaObjects,
  EhLibFmx.LaControls,
  EhLibFmx.ToolControls,
  EhLibFmx.Grid.CellManagers,
  EhLibFmx.Grids;

type
  TFieldBarEh = class;
  TFieldBarTitleEh = class;
  TGridStaticFieldBarsEh = class;
  TFieldBarOptionsEh = class;
  TAxisGridTitleBarEh = class;

  TDataAxisGridSetBarValueParamsEh = class;
  TDataAxisGridGetBarValueParamsEh = class;

  TInListFieldBarStateEh = (Unattached, StaticState, DynamicState);

  TDBAxisGridSetBarValueEventEh = procedure(Sender: TObject; Params: TDataAxisGridSetBarValueParamsEh) of object;
  TDBAxisGridGetBarValueEventEh = procedure(Sender: TObject; Params: TDataAxisGridGetBarValueParamsEh) of object;

  TFieldBarSortCompareEh = reference to function (Left, Right: TFieldBarEh): Integer;

{ TDataAxisGridGetBarValueParamsEh }

  TDataAxisGridGetBarValueParamsEh = class(TPersistent)
  private
    FFieldBar: TFieldBarEh;
    FGrid: TControl;
    FHandled: Boolean;
    FListItemBar: TTableRowViewEh;
    FValue: TValue;

  protected

  public
    constructor Create;
    procedure Init(AGrid: TControl; AFieldBar: TFieldBarEh; AListItemBar: TTableRowViewEh);
    procedure ProcessDefaultGetValue();

    property FieldBar: TFieldBarEh read FFieldBar;
    property Grid: TControl read FGrid;
    property Handled: Boolean read FHandled write FHandled;
    property ListItemBar: TTableRowViewEh read FListItemBar;
    property Value: TValue read FValue write FValue;
  end;

{ TDataAxisGridGetDisplayTextParamsEh }

  TDataAxisGridGetDisplayTextParamsEh = class(TPersistent)
  private
    FDisplayText: String;
    FFieldBar: TFieldBarEh;
    FGrid: TControl;
    FCellManager: TBaseGridCellManagerEh;
    FHandled: Boolean;
    FValue: TValue;
  protected

  public
    constructor Create;
    procedure Init(AGrid: TControl; AFieldBar: TFieldBarEh; ACellManager: TBaseGridCellManagerEh; const AValue: TValue);
    function GetDefaultDisplayText(): String;

    property DisplayText: String read FDisplayText write FDisplayText;
    property FieldBar: TFieldBarEh read FFieldBar;
    property CellManager: TBaseGridCellManagerEh read FCellManager;
    property Grid: TControl read FGrid;
    property Handled: Boolean read FHandled write FHandled;
    property Value: TValue read FValue;
  end;

{ TDataAxisGridSetBarValueParamsEh }

  TDataAxisGridSetBarValueParamsEh = class(TPersistent)
  private
    FFieldBar: TFieldBarEh;
    FGrid: TControl;
    FHandled: Boolean;
    FListItemBar: TTableRowViewEh;
    FValue: TValue;

  protected

  public
    constructor Create;
    procedure Init(AGrid: TControl; AFieldBar: TFieldBarEh; AListItemBar: TTableRowViewEh; const AValue: TValue);
    procedure DefaultSetValue();

    property FieldBar: TFieldBarEh read FFieldBar;
    property Grid: TControl read FGrid;
    property Handled: Boolean read FHandled write FHandled;
    property ListItemBar: TTableRowViewEh read FListItemBar;
    property Value: TValue read FValue write FValue;
  end;

{ TDataAxisCellStyleParamsEh }

  TDataAxisCellStyleParamsEh = class(TPersistent)
  private
    FDataRowIndex: Integer;
    FFieldBar: TFieldBarEh;
    FFill: TBrush;
    FFont: TFont;
    FFontColor: TAlphaColor;
    FGrid: TControl;
    FHandled: Boolean;
    FHorzAlign: TTextAlign;
    FListItemBar: TTableRowViewEh;
    FPadding: TBounds;
    FVertAlign: TTextAlign;

    procedure SetFill(const Value: TBrush);
    procedure SetFont(const Value: TFont);
    procedure SetPadding(const Value: TBounds);

  protected

  public
    constructor Create;
    destructor Destroy; override;

    procedure Init(AGrid: TControl; AFieldBar: TFieldBarEh; AListItemBar: TTableRowViewEh; ADataRowIndex: Integer); virtual;

    property DataRowIndex: Integer read FDataRowIndex;
    property FieldBar: TFieldBarEh read FFieldBar;
    property Grid: TControl read FGrid;
    property Handled: Boolean read FHandled write FHandled;
    property ListItemBar: TTableRowViewEh read FListItemBar;

    property Fill: TBrush read FFill write SetFill;
    property Font: TFont read FFont write SetFont;
    property FontColor: TAlphaColor read FFontColor write FFontColor;
    property HorzAlign: TTextAlign read FHorzAlign write FHorzAlign;
    property Padding: TBounds read FPadding write SetPadding;
    property VertAlign: TTextAlign read FVertAlign write FVertAlign;
  end;

{ TFieldBarDataCellStyleParamsEh }

  TFieldBarDataCellStyleParamsEh = class(TPersistent)
  private
    FDataAxisCellParams: TDataAxisCellStyleParamsEh;

    procedure SetFill(const Value: TBrush);
    procedure SetFont(const Value: TFont);
    procedure SetPadding(const Value: TBounds);
    function GetDataRowIndex: Integer;
    function GetFill: TBrush;
    function GetFont: TFont;
    function GetFontColor: TAlphaColor;
    function GetGrid: TControl;
    function GetHorzAlign: TTextAlign;
    function GetPadding: TBounds;
    function GetVertAlign: TTextAlign;
    procedure SetFontColor(const Value: TAlphaColor);
    procedure SetHorzAlign(const Value: TTextAlign);
    procedure SetVertAlign(const Value: TTextAlign);

  protected

  public
    constructor Create;
    destructor Destroy; override;

    procedure Init(ADataAxisCellParams: TDataAxisCellStyleParamsEh); virtual;

    property DataAxisCellParams: TDataAxisCellStyleParamsEh read FDataAxisCellParams;
    property DataRowIndex: Integer read GetDataRowIndex;
    property Grid: TControl read GetGrid;

    property Fill: TBrush read GetFill write SetFill;
    property Font: TFont read GetFont write SetFont;
    property FontColor: TAlphaColor read GetFontColor write SetFontColor;
    property HorzAlign: TTextAlign read GetHorzAlign write SetHorzAlign;
    property Padding: TBounds read GetPadding write SetPadding;
    property VertAlign: TTextAlign read GetVertAlign write SetVertAlign;
  end;

{ TDataAxisGridTitleInitCellContentParamsEh }

  TDataAxisGridTitleInitCellContentParamsEh = class(TBaseGridInitCellContentParamsEh)
  protected
    function GetFieldBarTitle: TFieldBarTitleEh; virtual;

  public
    procedure Init(ACell: TGridBaseCellEh; ACellContent: TLaObjectEh; InitCellParams: TBaseGridInitCellParamsEh); override;

    property FieldBarTitle: TFieldBarTitleEh read GetFieldBarTitle;
  end;

{ TDataAxisGridTitleCreateCellContentParamsEh }

  TDataAxisGridTitleCreateCellContentParamsEh = class(TBaseGridCreateCellContentParamsEh)
  private
  public
  end;

{ TDataAxisCellCanModifyParamsEh }

  TDataAxisCellCanModifyParamsEh = class(TPersistent)
  private
    FCanModify: Boolean;
    FGrid: TControl;
    FFieldBar: TFieldBarEh;
    FListItemBar: TTableRowViewEh;
    FHandled: Boolean;
  public
    constructor Create;
    procedure Init(AGrid: TControl; AFieldBar: TFieldBarEh; AListItemBar: TTableRowViewEh);
    function DefaultCanModify(): Boolean;

    property Grid: TControl read FGrid;
    property FieldBar: TFieldBarEh read FFieldBar;
    property ListItemBar: TTableRowViewEh read FListItemBar;
    property Handled: Boolean read FHandled write FHandled;
    property CanModify: Boolean read FCanModify write FCanModify;
  end;

{ TDataAxisCellInTextLinkClickParamsEh }

  TDataAxisCellInTextLinkClickParamsEh = class(TPersistent)
  private
    FFieldBar: TFieldBarEh;
    FListItemBar: TTableRowViewEh;
    FCell: TGridBaseCellEh;
    FGrid: TControl;
    FSourceParams: TInTextLinkClickParamsEh;
    function GetHandled: Boolean;
    procedure SetHandled(const Value: Boolean);
  public
    procedure Init(AGrid: TControl; ACell: TGridBaseCellEh; ASourceParams: TInTextLinkClickParamsEh);

    property Grid: TControl read FGrid;
    property Cell: TGridBaseCellEh read FCell;
    property SourceParams: TInTextLinkClickParamsEh read FSourceParams;

    property FieldBar: TFieldBarEh read FFieldBar;
    property ListItemBar: TTableRowViewEh read FListItemBar;
    property Handled: Boolean read GetHandled write SetHandled;
  end;

{ TAxisGridTitleBarEh }

  TAxisGridTitleBarEh = class(TComponent)
  private
    FDefaultFill: TBrush;
    FFill: TBrush;
    FFillStored: Boolean;
    FFont: TFont;
    FFontColor: TAlphaColor;
    FFontColorStored: Boolean;
    FFontStored: Boolean;
    FGrid: TControl;
    FHeightAutoExpand: Boolean;
    FHorzAlign: TTextAlign;
    FHorzAlignStored: Boolean;
    FHorzLinesColor: TAlphaColor;
    FHorzLinesColorStored: Boolean;
    FHorzLinesVisible: Boolean;
    FHorzLinesVisibleStored: Boolean;
    FPadding: TBounds;
    FPopupMenu: TPopupMenu;
    FVertAlign: TTextAlign;
    FVertLinesColor: TAlphaColor;
    FVertLinesColorStored: Boolean;
    FVertLinesVisible: Boolean;
    FVertLinesVisibleStored: Boolean;
    FVisible: Boolean;
    FWordWrap: Boolean;

    function GetFontColor: TAlphaColor;
    function GetHorzAlign: TTextAlign;
    function GetHorzLinesColor: TAlphaColor;
    function GetHorzLinesVisible: Boolean;
    function GetPadding: TBounds;
    function GetVertLinesColor: TAlphaColor;
    function GetVertLinesVisible: Boolean;
    function IsFillStored: Boolean;
    function IsFontColorStored: Boolean;
    function IsFontStored: Boolean;
    function IsHorzAlignStored: Boolean;
    function IsHorzLinesColorStored: Boolean;
    function IsHorzLinesVisibleStored: Boolean;
    function IsVertLinesColorStored: Boolean;
    function IsVertLinesVisibleStored: Boolean;

    procedure FillChanged(Sender: TObject);
    procedure FontChanged(Sender: TObject);
    procedure PaddingChanged(Sender: TObject);
    procedure SetFill(const Value: TBrush);
    procedure SetFillStored(const Value: Boolean);
    procedure SetFont(const Value: TFont);
    procedure SetFontColor(const Value: TAlphaColor);
    procedure SetFontColorStored(const Value: Boolean);
    procedure SetFontStored(const Value: Boolean);
    procedure SetHeightAutoExpand(const Value: Boolean);
    procedure SetHorzAlign(const Value: TTextAlign);
    procedure SetHorzAlignStored(const Value: Boolean);
    procedure SetHorzLinesColor(const Value: TAlphaColor);
    procedure SetHorzLinesColorStored(const Value: Boolean);
    procedure SetHorzLinesVisible(const Value: Boolean);
    procedure SetHorzLinesVisibleStored(const Value: Boolean);
    procedure SetPadding(const Value: TBounds);
    procedure SetVertAlign(const Value: TTextAlign);
    procedure SetVertLinesColor(const Value: TAlphaColor);
    procedure SetVertLinesColorStored(const Value: Boolean);
    procedure SetVertLinesVisible(const Value: Boolean);
    procedure SetVertLinesVisibleStored(const Value: Boolean);
    procedure SetVisible(const Value: Boolean);
    procedure SetWordWrap(const Value: Boolean);

  protected
    procedure RefreshDefaultFill();

    function DefaultHorzAlign(): TTextAlign; virtual;
    function DefaultHorzLinesColor(): TAlphaColor; virtual;
    function DefaultHorzLinesVisible(): Boolean; virtual;
    function DefaultVertLinesColor(): TAlphaColor; virtual;
    function DefaultVertLinesVisible(): Boolean; virtual;

    procedure Changed(CellLayoutAffects: Boolean = False); virtual;

  public
    constructor Create(AGrid: TControl); reintroduce;
    destructor Destroy; override;

    function DefaultFont(): TFont; virtual;
    function DefaultFill(): TBrush; virtual;
    function DefaultFontColor(): TAlphaColor; virtual;

    procedure RefreshDefaultFont;
    procedure TitlePropChange(CellLayoutAffects: Boolean = False); virtual;

    property Grid: TControl read FGrid;

  published
    property Font: TFont read FFont write SetFont stored IsFontStored;
    property FontStored: Boolean read FFontStored write SetFontStored default False;

    property FontColor: TAlphaColor read GetFontColor write SetFontColor stored IsFontColorStored;
    property FontColorStored: Boolean read FFontColorStored write SetFontColorStored default False;

    property Fill: TBrush read FFill write SetFill stored IsFillStored;
    property FillStored: Boolean read FFillStored write SetFillStored default False;

    property HorzAlign: TTextAlign read GetHorzAlign write SetHorzAlign stored IsHorzAlignStored;
    property HorzAlignStored: Boolean read IsHorzAlignStored write SetHorzAlignStored default False;

    property VertAlign: TTextAlign read FVertAlign write SetVertAlign default TTextAlign.Center;

    property Visible: Boolean read FVisible write SetVisible default True;
    property Padding: TBounds read GetPadding write SetPadding;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;
    property HeightAutoExpand: Boolean read FHeightAutoExpand write SetHeightAutoExpand default False;
    property PopupMenu: TPopupMenu read FPopupMenu write FPopupMenu;

    property HorzLinesColor: TAlphaColor read GetHorzLinesColor write SetHorzLinesColor stored IsHorzLinesColorStored;
    property HorzLinesColorStored: Boolean read FHorzLinesColorStored write SetHorzLinesColorStored default False;

    property HorzLinesVisible: Boolean read GetHorzLinesVisible write SetHorzLinesVisible stored IsHorzLinesVisibleStored;
    property HorzLinesVisibleStored: Boolean read FHorzLinesVisibleStored write SetHorzLinesVisibleStored default False;

    property VertLinesColor: TAlphaColor read GetVertLinesColor write SetVertLinesColor stored IsVertLinesColorStored;
    property VertLinesColorStored: Boolean read FVertLinesColorStored write SetVertLinesColorStored default False;

    property VertLinesVisible: Boolean read GetVertLinesVisible write SetVertLinesVisible stored IsVertLinesVisibleStored;
    property VertLinesVisibleStored: Boolean read FVertLinesVisibleStored write SetVertLinesVisibleStored default False;
  end;

{ TFieldBarOptionsEh }

  TFieldBarOptionsEh = class(TPersistent)
  private
    FAllowShowEditor: Boolean;
    FDefaultFill: TBrush;
    FFill: TBrush;
    FFillStored: Boolean;
    FFont: TFont;
    FFontColor: TAlphaColor;
    FFontColorStored: Boolean;
    FFontStored: Boolean;
    FHeightAutoExpand: Boolean;
    FHorzAlign: TTextAlign;
    FHorzLinesColor: TAlphaColor;
    FHorzLinesColorStored: Boolean;
    FHorzLinesVisible: Boolean;
    FHorzLinesVisibleStored: Boolean;
    FPadding: TBounds;
    FPaddingStored: Boolean;
    FTooltips: Boolean;
    FTrimming: TTextTrimming;
    FVertAlign: TTextAlign;
    FVertLinesColor: TAlphaColor;
    FVertLinesColorStored: Boolean;
    FVertLinesVisible: Boolean;
    FVertLinesVisibleStored: Boolean;
    FWordWrap: Boolean;

    function GetFontColor: TAlphaColor;
    function GetHorzLinesColor: TAlphaColor;
    function GetHorzLinesVisible: Boolean;
    function GetPadding: TBounds;
    function GetVertLinesColor: TAlphaColor;
    function GetVertLinesVisible: Boolean;
    function IsFillStored: Boolean;
    function IsFontColorStored: Boolean;
    function IsFontStored: Boolean;
    function IsHorzLinesColorStored: Boolean;
    function IsHorzLinesVisibleStored: Boolean;
    function IsPaddingStored: Boolean;
    function IsVertLinesColorStored: Boolean;
    function IsVertLinesVisibleStored: Boolean;

    procedure FillChanged(Sender: TObject);
    procedure FontChanged(Sender: TObject);
    procedure PaddingChanged(Sender: TObject);
    procedure SetFill(const Value: TBrush);
    procedure SetFillStored(const Value: Boolean);
    procedure SetFont(const Value: TFont);
    procedure SetFontColor(const Value: TAlphaColor);
    procedure SetFontColorStored(const Value: Boolean);
    procedure SetFontStored(const Value: Boolean);
    procedure SetHeightAutoExpand(const Value: Boolean);
    procedure SetHorzAlign(const Value: TTextAlign);
    procedure SetHorzLinesColor(const Value: TAlphaColor);
    procedure SetHorzLinesColorStored(const Value: Boolean);
    procedure SetHorzLinesVisible(const Value: Boolean);
    procedure SetHorzLinesVisibleStored(const Value: Boolean);
    procedure SetPadding(const Value: TBounds);
    procedure SetPaddingStored(const Value: Boolean);
    procedure SetTooltips(const Value: Boolean);
    procedure SetTrimming(const Value: TTextTrimming);
    procedure SetVertAlign(const Value: TTextAlign);
    procedure SetVertLinesColor(const Value: TAlphaColor);
    procedure SetVertLinesColorStored(const Value: Boolean);
    procedure SetVertLinesVisible(const Value: Boolean);
    procedure SetVertLinesVisibleStored(const Value: Boolean);
    procedure SetWordWrap(const Value: Boolean);

  protected
    FGrid: TControl;

    function DefaultFill(): TBrush; virtual;
    function DefaultFont(): TFont; virtual;
    function DefaultFontColor(): TAlphaColor; virtual;
    function DefaultHorzLinesColor(): TAlphaColor; virtual;
    function DefaultHorzLinesVisible(): Boolean; virtual;
    function DefaultPadding: TRectF; virtual;
    function DefaultVertLinesColor(): TAlphaColor; virtual;
    function DefaultVertLinesVisible(): Boolean; virtual;

    procedure Changed(CellLayoutAffects: Boolean = False);
    procedure HeightAutoExpandChanged; virtual;

  public
    constructor Create(AGrid: TControl);
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    procedure RefreshDefaultFont;
    procedure RefreshDefaultPadding;
    procedure RefreshDefaultFill;

    property GridControl: TControl read FGrid;

    property Font: TFont read FFont write SetFont stored IsFontStored;
    property FontStored: Boolean read FFontStored write SetFontStored default False;

    property FontColor: TAlphaColor read GetFontColor write SetFontColor stored IsFontColorStored;
    property FontColorStored: Boolean read FFontColorStored write SetFontColorStored default False;

    property Fill: TBrush read FFill write SetFill stored IsFillStored;
    property FillStored: Boolean read FFillStored write SetFillStored default False;

    property HorzAlign: TTextAlign read FHorzAlign write SetHorzAlign default TTextAlign.Leading;
    property VertAlign: TTextAlign read FVertAlign write SetVertAlign default TTextAlign.Leading;

    property Padding: TBounds read GetPadding write SetPadding stored IsPaddingStored;
    property PaddingStored: Boolean read FPaddingStored write SetPaddingStored default False;

    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;
    property HeightAutoExpand: Boolean read FHeightAutoExpand write SetHeightAutoExpand default False;
    property Trimming: TTextTrimming read FTrimming write SetTrimming default TTextTrimming.Character;
    property Tooltips: Boolean read FTooltips write SetTooltips default True;

    property AllowShowEditor: Boolean read FAllowShowEditor write FAllowShowEditor default True;

    property HorzLinesColor: TAlphaColor read GetHorzLinesColor write SetHorzLinesColor stored IsHorzLinesColorStored;
    property HorzLinesColorStored: Boolean read FHorzLinesColorStored write SetHorzLinesColorStored default False;

    property HorzLinesVisible: Boolean read GetHorzLinesVisible write SetHorzLinesVisible stored IsHorzLinesVisibleStored;
    property HorzLinesVisibleStored: Boolean read FHorzLinesVisibleStored write SetHorzLinesVisibleStored default False;

    property VertLinesColor: TAlphaColor read GetVertLinesColor write SetVertLinesColor stored IsVertLinesColorStored;
    property VertLinesColorStored: Boolean read FVertLinesColorStored write SetVertLinesColorStored default False;

    property VertLinesVisible: Boolean read GetVertLinesVisible write SetVertLinesVisible stored IsVertLinesVisibleStored;
    property VertLinesVisibleStored: Boolean read FVertLinesVisibleStored write SetVertLinesVisibleStored default False;
  end;

{ TFieldBarTitleEh }

  TFieldBarTitleEh = class(TPersistent)
  private
    FFieldBar: TFieldBarEh;
    FFill: TBrush;
    FFillStored: Boolean;
    FFont: TFont;
    FFontColor: TAlphaColor;
    FFontColorStored: Boolean;
    FFontStored: Boolean;
    FHeightAutoExpand: Boolean;
    FHeightAutoExpandStored: Boolean;
    FHorzAlign: TTextAlign;
    FHorzAlignStored: Boolean;
    FPadding: TBounds;
    FPaddingStored: Boolean;
    FPopupMenu: TPopupMenu;
    FText: string;
    FTextStored: Boolean;
    FVertAlign: TTextAlign;
    FVertAlignStored: Boolean;
    FWordWrap: Boolean;
    FWordWrapStored: Boolean;

    function GetFontColor: TAlphaColor;
    function GetHeightAutoExpand: Boolean;
    function GetHorzAlign: TTextAlign;
    function GetPadding: TBounds;
    function GetText: string;
    function GetVertAlign: TTextAlign;
    function GetWordWrap: Boolean;
    function IsFillStored: Boolean;
    function IsFontColorStored: Boolean;
    function IsFontStored: Boolean;
    function IsHeightAutoExpandStored: Boolean;
    function IsHorzAlignStored: Boolean;
    function IsPaddingStored: Boolean;
    function IsTextStored: Boolean;
    function IsVertAlignStored: Boolean;
    function IsWordWrapStored: Boolean;

    procedure FillChanged(Sender: TObject);
    procedure FontChanged(Sender: TObject);
    procedure PaddingChanged(Sender: TObject);
    procedure SetFill(const Value: TBrush);
    procedure SetFillStored(const Value: Boolean);
    procedure SetFont(const Value: TFont);
    procedure SetFontColor(const Value: TAlphaColor);
    procedure SetFontColorStored(const Value: Boolean);
    procedure SetFontStored(const Value: Boolean);
    procedure SetHeightAutoExpand(const Value: Boolean);
    procedure SetHeightAutoExpandStored(const Value: Boolean);
    procedure SetHorzAlign(const Value: TTextAlign);
    procedure SetHorzAlignStored(const Value: Boolean);
    procedure SetPadding(const Value: TBounds);
    procedure SetPaddingStored(const Value: Boolean);
    procedure SetText(const Value: string);
    procedure SetTextStored(const Value: Boolean);
    procedure SetVertAlign(const Value: TTextAlign);
    procedure SetVertAlignStored(const Value: Boolean);
    procedure SetWordWrap(const Value: Boolean);
    procedure SetWordWrapStored(const Value: Boolean);

  protected
    procedure Changed(CellLayoutAffects: Boolean = False);

    procedure UpdateDefaults;
  public
    constructor Create(AFieldBar: TFieldBarEh);
    destructor Destroy; override;

    function DefaultFill(): TBrush; virtual;
    function DefaultFont(): TFont; virtual;
    function DefaultFontColor(): TAlphaColor; virtual;
    function DefaultHeightAutoExpand: Boolean; virtual;
    function DefaultHorzAlign(): TTextAlign; virtual;
    function DefaultPadding(): TBounds; virtual;
    function DefaultText(): string; virtual;
    function DefaultVertAlign(): TTextAlign; virtual;
    function DefaultWordWrap: Boolean; virtual;

    procedure RefreshDefaultFill();
    procedure RefreshDefaultFont();
    procedure RefreshDefaultPadding();

    procedure Assign(Source: TPersistent); override;

    property FieldBar: TFieldBarEh read FFieldBar;

  published
    property HorzAlign: TTextAlign read GetHorzAlign write SetHorzAlign stored IsHorzAlignStored;
    property HorzAlignStored: Boolean read IsHorzAlignStored write SetHorzAlignStored default False;

    property VertAlign: TTextAlign read GetVertAlign write SetVertAlign stored IsVertAlignStored;
    property VertAlignStored: Boolean read IsVertAlignStored write SetVertAlignStored default False;

    property Text: string read GetText write SetText stored IsTextStored;
    property TextStored: Boolean read IsTextStored write SetTextStored default False;

    property Font: TFont read FFont write SetFont stored IsFontStored;
    property FontStored: Boolean read FFontStored write SetFontStored default False;

    property FontColor: TAlphaColor read GetFontColor write SetFontColor stored IsFontColorStored;
    property FontColorStored: Boolean read FFontColorStored write SetFontColorStored default False;

    property Fill: TBrush read FFill write SetFill stored IsFillStored;
    property FillStored: Boolean read FFillStored write SetFillStored default False;

    property Padding: TBounds read GetPadding write SetPadding stored IsPaddingStored;
    property PaddingStored: Boolean read FPaddingStored write SetPaddingStored default False;

    property WordWrap: Boolean read GetWordWrap write SetWordWrap stored IsWordWrapStored;
    property WordWrapStored: Boolean read IsWordWrapStored write SetWordWrapStored default False;

    property HeightAutoExpand: Boolean read GetHeightAutoExpand write SetHeightAutoExpand stored IsHeightAutoExpandStored;
    property HeightAutoExpandStored: Boolean read IsHeightAutoExpandStored write SetHeightAutoExpandStored default False;

    property PopupMenu: TPopupMenu read FPopupMenu write FPopupMenu;
  end;

{ TFieldBarEh }

  TFieldBarEh = class(TComponent)
  private
    FAllowShowEditor: Boolean;
    FAllowShowEditorStored: Boolean;
    FField: TTableFieldLinkEh;
    FFieldName: string;
    FFill: TBrush;
    FFillStored: Boolean;
    FFont: TFont;
    FFontColor: TAlphaColor;
    FFontColorStored: Boolean;
    FFontStored: Boolean;
    FGrid: TCustomGridEh;
    FHeightAutoExpand: Boolean;
    FHeightAutoExpandStored: Boolean;
    FHorzAlign: TTextAlign;
    FHorzAlignStored: Boolean;
    FPadding: TBounds;
    FPaddingStored: Boolean;
    FPopupMenu: TPopupMenu;
    FReadOnly: Boolean;
    FReadOnlyStored: Boolean;
    FStaticIndex: Integer;
    FTitle: TFieldBarTitleEh;
    FTooltips: Boolean;
    FTooltipsStored: Boolean;
    FVertAlign: TTextAlign;
    FVertAlignStored: Boolean;
    FVisible: Boolean;
    FVisibleIndex: Integer;
    FMergeDuplicates: Boolean;

    function GetAllowShowEditor: Boolean;
    function GetDisplayIndex: Integer;
    function GetField: TTableFieldLinkEh;
    function GetFontColor: TAlphaColor;
    function GetHeightAutoExpand: Boolean;
    function GetHorzAlign: TTextAlign;
    function GetPadding: TBounds;
    function GetReadOnly: Boolean;
    function GetRefSelf: TFieldBarEh;
    function GetStaticIndex: Integer;
    function GetTooltips: Boolean;
    function GetVertAlign: TTextAlign;
    function GetVisibleIndex: Integer;
    function IsAllowShowEditorStored(): Boolean;
    function IsFillStored: Boolean;
    function IsFontColorStored: Boolean;
    function IsFontStored: Boolean;
    function IsHeightAutoExpandStored: Boolean;
    function IsHorzAlignStored: Boolean;
    function IsPaddingStored: Boolean;
    function IsReadOnlyStored: Boolean;
    function IsTooltipsStored: Boolean;
    function IsVertAlignStored: Boolean;

    procedure FillChanged(Sender: TObject);
    procedure FontChanged(Sender: TObject);
    procedure NotifyChanges(CellLayoutAffects: Boolean = False);
    procedure PaddingChanged(Sender: TObject);
    procedure RefreshDefaultFill;
    procedure RefreshDefaultFont;
    procedure SetAllowShowEditor(const Value: Boolean);
    procedure SetAllowShowEditorStored(const Value: Boolean);
    procedure SetDisplayIndex(const Value: Integer);
    procedure SetField(const Value: TTableFieldLinkEh);
    procedure SetFieldName(const Value: String);
    procedure SetFill(const Value: TBrush);
    procedure SetFillStored(const Value: Boolean);
    procedure SetFont(const Value: TFont);
    procedure SetFontColor(const Value: TAlphaColor);
    procedure SetFontColorStored(const Value: Boolean);
    procedure SetFontStored(const Value: Boolean);
    procedure SetHeightAutoExpand(const Value: Boolean);
    procedure SetHeightAutoExpandStored(const Value: Boolean);
    procedure SetHorzAlign(const Value: TTextAlign);
    procedure SetHorzAlignStored(const Value: Boolean);
    procedure SetPadding(const Value: TBounds);
    procedure SetPaddingStored(const Value: Boolean);
    procedure SetReadOnly(const Value: Boolean);
    procedure SetStaticIndex(const Value: Integer);
    procedure SetTitle(const Value: TFieldBarTitleEh);
    procedure SetTooltips(const Value: Boolean);
    procedure SetTooltipsStored(const Value: Boolean);
    procedure SetVertAlign(const Value: TTextAlign);
    procedure SetVertAlignStored(const Value: Boolean);
    procedure SetVisible(const Value: Boolean);
    procedure SetMergeDuplicates(const Value: Boolean);

  protected
    FFieldBound: Boolean;
    FInListState: TInListFieldBarStateEh;
    FDisplayIndex: Integer;

    function CreateFieldBarStyleParams(): TFieldBarDataCellStyleParamsEh; virtual;
    function CreateGetBarValueEventParams(): TDataAxisGridGetBarValueParamsEh; virtual;
    function CreateGetDisplayTextParams(): TDataAxisGridGetDisplayTextParamsEh; virtual;
    function CreateSetBarValueEventParams(): TDataAxisGridSetBarValueParamsEh; virtual;
    function CreateTitle: TFieldBarTitleEh; virtual;
    function DefaultAllowShowEditor(): Boolean; virtual;
    function DefaultFill: TBrush; virtual;
    function DefaultFont: TFont; virtual;
    function DefaultFontColor(): TAlphaColor; virtual;
    function DefaultGetDisplayText(const VarValue: TValue; CellManager: TBaseGridCellManagerEh): String; virtual;
    function DefaultGetListItemValue(AListItemBar: TTableRowViewEh): TValue; virtual;
    function DefaultHeightAutoExpand: Boolean; virtual;
    function DefaultHorzAlign(): TTextAlign; virtual;
    function DefaultPadding(): TBounds; virtual;
    function DefaultReadOnly(): Boolean; virtual;
    function DefaultTooltips: Boolean; virtual;
    function DefaultValidChar(const KeyChar: Char): Boolean; virtual;
    function DefaultVertAlign(): TTextAlign; virtual;
    function GetGrid: TCustomGridEh;
    function GetCellManagerAtListItemBar(AListItemBar: TTableRowViewEh): TBaseGridCellManagerEh; virtual;
    function IsShowSelectionLayer(ACell: TGridBaseCellEh): Boolean; virtual;

    procedure Changed(CellLayoutAffects: Boolean = False); virtual;
    procedure CheckBindField;
    procedure ClearBindField;
    procedure DoBeforeFirstDrawing(); virtual;
    procedure FieldChanged; virtual;
    procedure FieldNameChanged; virtual;

    procedure HandleDataCellGetDisplayText(Params: TDataAxisGridGetDisplayTextParamsEh); virtual;
    procedure HandleDataCellGetValue(Params: TDataAxisGridGetBarValueParamsEh); virtual;
    procedure HandleDataCellSetValue(Params: TDataAxisGridSetBarValueParamsEh); virtual;
    procedure HandleGetFieldBarStyleParams(Params: TDataAxisCellStyleParamsEh); virtual;
    procedure HandleCreateCellContent(Params: TBaseGridCreateCellContentParamsEh); virtual;
    procedure HandleDataCellInitContent(Params: TBaseGridInitCellContentParamsEh); virtual;
    procedure HandleDataCellKeyDownEvent(Params: TBaseGridCellKeyDownParamsEh); virtual;
    procedure HandleDataCellMouseDownEvent(Params: TGridCellMouseButtonParamsEh); virtual;
    procedure HandleDataCellMouseClickEvent(Params: TGridCellMouseButtonParamsEh); virtual;
    procedure HandleInitCellEditor(AParams: TBaseGridInitEditorParamsEh); virtual;
    procedure HandleDataCellInitEditParams(AParams: TBaseGridCellEditParamsEh); virtual;
    procedure HandleDataCellStartEdit(Params: TPersistent); virtual;
    procedure HandleCanModifyCellValue(AParams: TDataAxisCellCanModifyParamsEh); virtual;
    procedure HandleDataCellInTextLinkClick(Params: TDataAxisCellInTextLinkClickParamsEh); virtual;

    procedure ProcessCanModifyCellValue(AParams: TDataAxisCellCanModifyParamsEh); virtual;

    procedure HeightAutoExpandChanged(); virtual;
    procedure LinkActiveChanged; virtual;
    procedure ProcessGetCellValue(Params: TDataAxisGridGetBarValueParamsEh); virtual;
    procedure ProcessGetDisplayText(Params: TDataAxisGridGetDisplayTextParamsEh); virtual;
    procedure ProcessGetFieldBarStyleParams(Params: TDataAxisCellStyleParamsEh); virtual;
    procedure RefreshDefaultPadding(); virtual;
    procedure SetGrid(AGrid: TCustomGridEh; AInListState: TInListFieldBarStateEh);
    procedure TitleChanged(CellLayoutAffects: Boolean = False); virtual;
    procedure TooltipsChanged(); virtual;
    procedure UpdateDefaults; virtual;
    procedure UpdateDisplayIndex;

    property Title: TFieldBarTitleEh read FTitle write SetTitle;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function CanEditModify: Boolean; virtual;
    function CanEditShow: Boolean; virtual;
    function CanEditShowListItem(AListItemBar: TTableRowViewEh): Boolean; virtual;
    function CanModifyCellValue(AListItemBar: TTableRowViewEh): Boolean; virtual;
    function FormatValue(const Format: string; const Value: TValue): String; virtual;
    function GetDisplayText(const VarValue: TValue; ACellManager: TBaseGridCellManagerEh): String; virtual;
    function GetListItemDisplayText(AListItemBar: TTableRowViewEh; ACellManager: TBaseGridCellManagerEh): String; overload; virtual;
    function GetListItemDisplayText(AListItemBar: TTableRowViewEh): String; overload; virtual;
    function GetListItemEditText(AListItemBar: TTableRowViewEh): String; virtual;
    function GetListItemValue(AListItemBar: TTableRowViewEh): TValue; virtual;
    function UseRightToLeftAlignment: Boolean; virtual;
    function ValidChar(const KeyChar: Char): Boolean; virtual;
    function DefaultCanModifyCellValue(AListItemBar: TTableRowViewEh): Boolean; virtual;
    function IsCalcNextPriorRecordValue: Boolean; virtual;

    procedure BindField; virtual;
    procedure DefaultSetValue(const Value: TValue); virtual;
    procedure ProcessSetValue(Params: TDataAxisGridSetBarValueParamsEh); virtual;
    procedure SetCurrentListItemValue(const Value: TValue); virtual;
    procedure SetValueAsText(const StrVal: String);
    procedure InitCell(ACell: TGridBaseCellEh; AStyleParams: TDataAxisCellStyleParamsEh); virtual;
    procedure InitStyleParams(Params: TDataAxisCellStyleParamsEh); virtual;
    procedure DefaultInitEditParams(Params: TBaseGridCellEditParamsEh); virtual;

    property Grid: TCustomGridEh read FGrid;
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

    property AllowShowEditor: Boolean read GetAllowShowEditor write SetAllowShowEditor stored IsAllowShowEditorStored;
    property AllowShowEditorStored: Boolean read IsAllowShowEditorStored write SetAllowShowEditorStored stored False;

    property HeightAutoExpand: Boolean read GetHeightAutoExpand write SetHeightAutoExpand stored IsHeightAutoExpandStored;
    property HeightAutoExpandStored: Boolean read IsHeightAutoExpandStored write SetHeightAutoExpandStored default False;

    property Tooltips: Boolean read GetTooltips write SetTooltips stored IsTooltipsStored;
    property TooltipsStored: Boolean read IsTooltipsStored write SetTooltipsStored default False;

    property DisplayIndex: Integer read GetDisplayIndex write SetDisplayIndex;
    property Field: TTableFieldLinkEh read GetField write SetField;
    property FieldName: String read FFieldName write SetFieldName;
    property InListState: TInListFieldBarStateEh read FInListState;
    property PopupMenu: TPopupMenu read FPopupMenu write FPopupMenu;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly stored IsReadOnlyStored;
    property RefSelf: TFieldBarEh read GetRefSelf;
    property StaticIndex: Integer read GetStaticIndex write SetStaticIndex;
    property Visible: Boolean read FVisible write SetVisible default True;
    property VisibleIndex: Integer read GetVisibleIndex;
    property MergeDuplicates: Boolean read FMergeDuplicates write SetMergeDuplicates;
  end;

  TFieldBarEhClass = class of TFieldBarEh;

{ TGridStaticFieldBarsEh }

  TGridStaticFieldBarsEh = class(TPersistent)
  private
    FList: TList<TFieldBarEh>;
    FGrid: TControl;
    FUpdateCount: Integer;

    function GetCount: Integer;
    function GetFieldBar(Index: Integer): TFieldBarEh;

    procedure ListChanged;
    procedure SetFieldBar(Index: Integer; const Value: TFieldBarEh);

  protected
    procedure InternalAdd(AFieldBar: TFieldBarEh);
    procedure InternalRemove(AFieldBar: TFieldBarEh);
    procedure ResetChildrenIndices();
    procedure SetIndexOfFieldBar(const Child: TFieldBarEh; NewIndex: Integer);
    procedure SetOrder(FieldBars: TArray<TFieldBarEh>);
    procedure Sort(Compare: TFieldBarSortCompareEh); virtual;

  public
    constructor Create(AGrid: TControl);
    destructor Destroy; override;

    function IndexOf(AFieldBar: TFieldBarEh): Integer;
    function IndexOfByFieldName(FieldName: String): Integer;

    procedure Add(AFieldBar: TFieldBarEh);

    procedure BeginUpdate();
    procedure EndUpdate();
    procedure ActiveChanged; virtual;
    procedure MoveFieldBar(const OldIndex, NewIndex: Integer);
    procedure Clear();

    property FieldBar[Index: Integer]: TFieldBarEh read GetFieldBar write SetFieldBar; default;
    property Count: Integer read GetCount;
    property UpdateCount: Integer read FUpdateCount;
    property Grid: TControl read FGrid;
  end;

{ TGridFieldBarReadonlyListEh }

  TGridFieldBarReadonlyListEh = class(TReadonlyList<TFieldBarEh>)
  protected
    FGrid: TControl;
  public
    constructor Create(AGrid: TControl; AList: TList<TFieldBarEh>);
    destructor Destroy; override;
  end;

{ TGridAllFieldBarListEh }

  TGridAllFieldBarListEh = class(TGridFieldBarReadonlyListEh)
  private
    FUpdateCount: Integer;
  protected
    procedure LinkActiveChanged();
    procedure DoBeforeFirstDrawing();
  public
    constructor Create(AGrid: TControl; AList: TList<TFieldBarEh>);
    destructor Destroy; override;

    procedure BeginUpdate();
    procedure EndUpdate();
    procedure RefreshDefaultFill; virtual;
    procedure RefreshDefaultFont; virtual;
    procedure RefreshDefaultTitleFont; virtual;
    procedure RefreshDefaultPadding; virtual;
    procedure RefreshTitleDefaultFill; virtual;
    procedure RefreshTitleDefaultFont; virtual;
    procedure RefreshTitleDefaultPadding; virtual;

    property UpdateCount: Integer read FUpdateCount;
  end;

{ TGridDisplayFieldBarsEh }

  TGridDisplayFieldBarsEh = class(TGridFieldBarReadonlyListEh)
  private
    FIndexesIsFixed: Boolean;
  protected
    function CompareFieldBarOrder(const ALeft, ARight: TFieldBarEh): Integer; virtual;

    procedure ResetList(NewList: TList<TFieldBarEh>; ForceReset: Boolean);
    procedure MoveFieldBar(AFieldBar: TFieldBarEh; NewDisplayIndex: Integer);
    procedure MoveFieldBars(BarList: TEnumerable<TFieldBarEh>; NewDisplayIndex: Integer);
    procedure ResetIndexes;
    procedure ReorderList(NewOrderList: TList<TFieldBarEh>); virtual;

    procedure UpdateDisplayOrderFromDisplayIndex;
  public
    constructor Create(AGrid: TControl; AList: TList<TFieldBarEh>);
    destructor Destroy; override;

    procedure SetFieldBarsOrder(AOrderedList: TList<TFieldBarEh>);
  end;

{ TGridVisibleFieldBarsEh }

  TGridVisibleFieldBarsEh = class(TGridFieldBarReadonlyListEh)
  protected
    procedure MoveFieldBar(AFieldBar: TFieldBarEh; NewVisibleIndex: Integer);
    procedure MoveFieldBars(BarList: TEnumerable<TFieldBarEh>; NewVisibleIndex: Integer);
    procedure ResetIndexes;
  public

    constructor Create(AGrid: TControl; AList: TList<TFieldBarEh>);
    destructor Destroy; override;
  end;

{ TGridDynamicFieldBarsEh }

  TGridDynamicFieldBarsEh = class(TGridFieldBarReadonlyListEh)
  protected
  public
    function GetColumnClassByField(AField: TTableFieldLinkEh): TFieldBarEhClass; virtual;
    procedure GetFieldList(AList: TList<TTableFieldLinkEh>); virtual;

    constructor Create(AGrid: TControl; AList: TList<TFieldBarEh>);
    destructor Destroy; override;
  end;

{ TDataAxisGridTitleCellManagerEh }

  TDataAxisGridTitleCellManagerEh = class(TBaseGridCellManagerEh)

  end;

{ TDataAxisGridTitleCellEh }

  TDataAxisGridTitleCellEh = class(TGridBaseCellEh)

  end;

implementation

uses EhLibFmx.Platform,
     EhLibFmx.DataAxisGrids,
     EhLibFmx.DataAxisGrid.DataCells;

type
  TCustomDataAxisGridEhCrack = class(TCustomDataAxisGridEh);

{$REGION 'TFieldBarTitleEh'}

constructor TFieldBarTitleEh.Create(AFieldBar: TFieldBarEh);
begin
  inherited Create;
  FFieldBar := AFieldBar;

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

end;

destructor TFieldBarTitleEh.Destroy;
begin
  FreeAndNil(FFont);
  FreeAndNil(FFill);
  FreeAndNil(FPadding);
  inherited Destroy;
end;

procedure TFieldBarTitleEh.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
end;

procedure TFieldBarTitleEh.Changed(CellLayoutAffects: Boolean = False);
begin
  FFieldBar.TitleChanged(CellLayoutAffects);
end;

procedure TFieldBarTitleEh.UpdateDefaults;
begin
  RefreshDefaultFont();
  RefreshDefaultPadding();
  RefreshDefaultFill();
end;

{$REGION 'TFieldBarTitleEh.Font'}
function TFieldBarTitleEh.DefaultFont: TFont;
begin
  if (FieldBar <> nil) and (FieldBar.GetGrid <> nil)
    then Result := TCustomDataAxisGridEh(FieldBar.GetGrid).Title.Font
    else Result := SystemFont;
end;

procedure TFieldBarTitleEh.FontChanged(Sender: TObject);
begin
  FFontStored := True;
  Changed(True);
end;

procedure TFieldBarTitleEh.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TFieldBarTitleEh.SetFontStored(const Value: Boolean);
begin
  if FFontStored <> Value then
  begin
    FFontStored := Value;
    RefreshDefaultFont;
  end;
end;

procedure TFieldBarTitleEh.RefreshDefaultFont;
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

function TFieldBarTitleEh.IsFontStored: Boolean;
begin
  Result := FFontStored;
end;
{$ENDREGION 'TFieldBarTitleEh.Font'}

{$REGION 'TFieldBarTitleEh.FontColor'}
function TFieldBarTitleEh.GetFontColor: TAlphaColor;
begin
  if FontColorStored
    then Result := FFontColor
    else Result := DefaultFontColor();
end;

procedure TFieldBarTitleEh.SetFontColor(const Value: TAlphaColor);
begin
  if FFontColor <> Value then
  begin
    FFontColor := Value;
    FFontColorStored := True;
    Changed;
  end;
end;

function TFieldBarTitleEh.DefaultFontColor: TAlphaColor;
begin
  if (FieldBar.GetGrid <> nil)
    then Result := TCustomDataAxisGridEh(FieldBar.GetGrid).Title.FontColor
    else Result := SystemFontColor;
end;

procedure TFieldBarTitleEh.SetFontColorStored(const Value: Boolean);
begin
  if FFontColorStored <> Value then
  begin
    FFontColorStored := Value;
    Changed;
  end;
end;

function TFieldBarTitleEh.IsFontColorStored: Boolean;
begin
  Result := FFontColorStored;
end;
{$ENDREGION 'TFieldBarTitleEh.FontColor'}

procedure TFieldBarTitleEh.SetFill(const Value: TBrush);
begin
  FFill.Assign(Value);
end;

procedure TFieldBarTitleEh.SetFillStored(const Value: Boolean);
begin
  if FFillStored <> Value then
  begin
    FFillStored := Value;
    RefreshDefaultFill;
  end;
end;

function TFieldBarTitleEh.DefaultFill: TBrush;
begin
  if (FieldBar <> nil) and (FieldBar.GetGrid <> nil)
    then Result := TCustomDataAxisGridEh(FieldBar.GetGrid).Title.Fill
    else Result := SystemFill;
end;

procedure TFieldBarTitleEh.RefreshDefaultFill;
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

function TFieldBarTitleEh.IsFillStored: Boolean;
begin
  Result := FFillStored;
end;

procedure TFieldBarTitleEh.FillChanged(Sender: TObject);
begin
  FFillStored := True;
  Changed(True);
end;

{$REGION Text}
function TFieldBarTitleEh.GetText: string;
begin
  if TextStored
    then Result := FText
    else Result := DefaultText;
end;

function TFieldBarTitleEh.DefaultText: string;
var
  Field: TTableFieldLinkEh;
begin
  Field := FFieldBar.Field;
  if Assigned(Field)
    then Result := Field.DisplayName
    else Result := FFieldBar.FieldName;
end;

function TFieldBarTitleEh.IsTextStored: Boolean;
begin
  Result := FTextStored;
end;

procedure TFieldBarTitleEh.SetText(const Value: string);
begin
  if (IsTextStored = False) or (Value <> FText) then
  begin
    FText := Value;
    FTextStored := True;
    Changed();
  end;
end;

procedure TFieldBarTitleEh.SetTextStored(const Value: Boolean);
begin
  if FTextStored <> Value then
  begin
    FTextStored := Value;
    Changed();
  end;
end;
{$ENDREGION Text}

{$REGION HorzAlign}
function TFieldBarTitleEh.GetHorzAlign: TTextAlign;
begin
  if HorzAlignStored
    then Result := FHorzAlign
    else Result := DefaultHorzAlign();
end;

procedure TFieldBarTitleEh.SetHorzAlign(const Value: TTextAlign);
begin
  if (IsHorzAlignStored = False) or (Value <> FHorzAlign) then
  begin
    FHorzAlign := Value;
    FHorzAlignStored := True;
    Changed();
  end;
end;

function TFieldBarTitleEh.DefaultHorzAlign: TTextAlign;
begin
  if (FieldBar <> nil) and (FieldBar.GetGrid <> nil)
    then Result := TCustomDataAxisGridEh(FieldBar.GetGrid).Title.HorzAlign
    else Result := TTextAlign.Leading;
end;

function TFieldBarTitleEh.IsHorzAlignStored: Boolean;
begin
  Result := FHorzAlignStored;
end;

procedure TFieldBarTitleEh.SetHorzAlignStored(const Value: Boolean);
begin
  if FHorzAlignStored <> Value then
  begin
    FHorzAlignStored := Value;
    Changed();
  end;
end;
{$ENDREGION HorzAlign}

{$REGION VertAlign}
function TFieldBarTitleEh.GetVertAlign: TTextAlign;
begin
  if VertAlignStored
    then Result := FVertAlign
    else Result := DefaultVertAlign();
end;

procedure TFieldBarTitleEh.SetVertAlign(const Value: TTextAlign);
begin
  if (IsVertAlignStored = False) or (Value <> FVertAlign) then
  begin
    FVertAlign := Value;
    FVertAlignStored := True;
    Changed();
  end;
end;

function TFieldBarTitleEh.DefaultVertAlign: TTextAlign;
begin
  if (FieldBar <> nil) and (FieldBar.GetGrid <> nil)
    then Result := TCustomDataAxisGridEh(FieldBar.GetGrid).Title.VertAlign
    else Result := TTextAlign.Center;
end;

function TFieldBarTitleEh.IsVertAlignStored: Boolean;
begin
  Result := FVertAlignStored;
end;

procedure TFieldBarTitleEh.SetVertAlignStored(const Value: Boolean);
begin
  if FVertAlignStored <> Value then
  begin
    FVertAlignStored := Value;
    Changed();
  end;
end;
{$ENDREGION VertAlign}

procedure TFieldBarTitleEh.PaddingChanged(Sender: TObject);
begin
  FPaddingStored := True;
  Changed(True);
end;

function TFieldBarTitleEh.GetPadding: TBounds;
begin
  Result := FPadding;
end;

procedure TFieldBarTitleEh.SetPadding(const Value: TBounds);
begin
  FPadding.Assign(Value);
end;

function TFieldBarTitleEh.DefaultPadding: TBounds;
begin
  if (FieldBar <> nil) and (FieldBar.GetGrid <> nil)
    then Result := TCustomDataAxisGridEh(FieldBar.GetGrid).Title.Padding
    else Result := EmptyBounds;
end;

procedure TFieldBarTitleEh.RefreshDefaultPadding;
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

procedure TFieldBarTitleEh.SetPaddingStored(const Value: Boolean);
begin
  if FPaddingStored <> Value then
  begin
    FPaddingStored := Value;
    RefreshDefaultPadding;
    Changed(True);
  end;
end;

function TFieldBarTitleEh.IsPaddingStored: Boolean;
begin
  Result := FPaddingStored;
end;

{$REGION 'TFieldBarTitleEh.WordWrap'}
function TFieldBarTitleEh.GetWordWrap: Boolean;
begin
  if IsWordWrapStored
    then Result := FWordWrap
    else Result := DefaultWordWrap;
end;

procedure TFieldBarTitleEh.SetWordWrap(const Value: Boolean);
begin
  if (IsWordWrapStored = False) or (Value <> FWordWrap) then
  begin
    FWordWrap := Value;
    FWordWrapStored := True;
    Changed(True);
  end;
end;

function TFieldBarTitleEh.DefaultWordWrap: Boolean;
begin
  if (FieldBar <> nil) and (FieldBar.GetGrid <> nil)
    then Result := TCustomDataAxisGridEh(FieldBar.GetGrid).Title.WordWrap
    else Result := False;
end;

function TFieldBarTitleEh.IsWordWrapStored: Boolean;
begin
  Result := FWordWrapStored;
end;

procedure TFieldBarTitleEh.SetWordWrapStored(const Value: Boolean);
begin
  if FWordWrapStored <> Value then
  begin
    FWordWrapStored := Value;
    Changed();
  end;
end;
{$ENDREGION 'TFieldBarTitleEh.WordWrap'}

{$REGION 'TFieldBarTitleEh.HeightAutoExpand'}
function TFieldBarTitleEh.GetHeightAutoExpand: Boolean;
begin
  if IsHeightAutoExpandStored
    then Result := FHeightAutoExpand
    else Result := DefaultHeightAutoExpand;
end;

function TFieldBarTitleEh.DefaultHeightAutoExpand: Boolean;
begin
  if (FieldBar <> nil) and (FieldBar.GetGrid <> nil)
    then Result := TCustomDataAxisGridEh(FieldBar.GetGrid).Title.HeightAutoExpand
    else Result := False;
end;

procedure TFieldBarTitleEh.SetHeightAutoExpand(const Value: Boolean);
begin
  if (IsHeightAutoExpandStored = False) or (Value <> FHeightAutoExpand) then
  begin
    FHeightAutoExpand := Value;
    FHeightAutoExpandStored := True;
    Changed(True);
  end;
end;

procedure TFieldBarTitleEh.SetHeightAutoExpandStored(const Value: Boolean);
begin
  if FHeightAutoExpandStored <> Value then
  begin
    FHeightAutoExpandStored := Value;
    Changed();
  end;
end;

function TFieldBarTitleEh.IsHeightAutoExpandStored: Boolean;
begin
  Result := FHeightAutoExpandStored;
end;
{$ENDREGION 'TFieldBarTitleEh.HeightAutoExpand'}

{$ENDREGION 'TFieldBarTitleEh'}

{$REGION 'TGridStaticFieldBarsEh'}

constructor TGridStaticFieldBarsEh.Create(AGrid: TControl);
begin
  inherited Create;
  FGrid := AGrid;
  FList := TList<TFieldBarEh>.Create;
end;

destructor TGridStaticFieldBarsEh.Destroy();
begin
  Clear();
  FreeAndNil(FList);
  inherited Destroy;
end;

procedure TGridStaticFieldBarsEh.Clear();
begin
  BeginUpdate;
  try
    while Count > 0 do
    begin
      FieldBar[Count - 1].Free;
    end;
  finally
    EndUpdate();
  end;
end;

procedure TGridStaticFieldBarsEh.ListChanged();
begin
  if UpdateCount = 0 then
    TCustomDataAxisGridEhCrack(FGrid).StaticBarListChanged;
end;

procedure TGridStaticFieldBarsEh.ActiveChanged;
begin

end;

procedure TGridStaticFieldBarsEh.BeginUpdate;
begin
  FUpdateCount := FUpdateCount + 1;
end;

procedure TGridStaticFieldBarsEh.EndUpdate;
begin
  FUpdateCount := FUpdateCount - 1;
  Assert(FUpdateCount >= 0, 'TGridAllFieldBarListEh.EndUpdate; FUpdateCount >= 0 condition failed.');

  if FUpdateCount = 0 then
    ListChanged;
end;

function TGridStaticFieldBarsEh.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TGridStaticFieldBarsEh.GetFieldBar(Index: Integer): TFieldBarEh;
begin
  Result := FList[Index];
end;

procedure TGridStaticFieldBarsEh.SetFieldBar(Index: Integer; const Value: TFieldBarEh);
begin
  FList[Index] := Value;
end;

procedure TGridStaticFieldBarsEh.Add(AFieldBar: TFieldBarEh);
begin
  InternalAdd(AFieldBar);
end;

procedure TGridStaticFieldBarsEh.InternalAdd(AFieldBar: TFieldBarEh);
begin
  if AFieldBar.InListState <> TInListFieldBarStateEh.Unattached then
    raise Exception.Create('TGridStaticFieldBarsEh.InternalAdd: AFieldBar + "' + AFieldBar.Name + '" already been added to the list.');
  FList.Add(AFieldBar);
  AFieldBar.FStaticIndex := FList.Count - 1;
  AFieldBar.SetGrid(TCustomGridEh(FGrid), TInListFieldBarStateEh.StaticState);
  ListChanged();
end;

procedure TGridStaticFieldBarsEh.InternalRemove(AFieldBar: TFieldBarEh);
var
  RemovedItemIndex: Integer;
  I: Integer;
begin
  RemovedItemIndex := FList.Remove(AFieldBar);
  if RemovedItemIndex >= 0 then
  begin
    for I := RemovedItemIndex to Count - 1 do
      FList[I].FStaticIndex := I;
  end;

  AFieldBar.SetGrid(nil, TInListFieldBarStateEh.Unattached);
  ListChanged();
end;

procedure TGridStaticFieldBarsEh.MoveFieldBar(const OldIndex, NewIndex: Integer);
begin
  FList.Move(OldIndex, NewIndex);
  ListChanged();
end;

function TGridStaticFieldBarsEh.IndexOf(AFieldBar: TFieldBarEh): Integer;
begin
  Result := FList.IndexOf(AFieldBar);
end;

function TGridStaticFieldBarsEh.IndexOfByFieldName(FieldName: String): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if (CompareText(FieldBar[I].FieldName, FieldName) = 0) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

procedure TGridStaticFieldBarsEh.Sort(Compare: TFieldBarSortCompareEh);
var
  Comparer: IComparer<TFieldBarEh>;
  Comparison: TComparison<TFieldBarEh>;
begin
  Comparison := TComparison<TFieldBarEh>(Compare);
  Comparer := TComparer<TFieldBarEh>.Construct(Comparison);
  FList.Sort(Comparer);
  ListChanged();
end;

procedure TGridStaticFieldBarsEh.SetOrder(FieldBars: TArray<TFieldBarEh>);
var
  I: Integer;
begin
  if Length(FieldBars) <> Count then
    raise Exception.Create('TStaticColumnsEh.SetOrder: Invalidate Columns size');
  for I := 0 to Length(FieldBars) - 1 do
  begin
    if IndexOf(FieldBars[I]) < 0 then
      raise Exception.Create('TStaticColumnsEh.SetOrder: Invalidate Column in position ' + I.ToString);
  end;

  FList.Clear;
  for I := 0 to Length(FieldBars) - 1 do
  begin
    FList.Add(FieldBars[I]);
  end;

  ListChanged();
end;

procedure TGridStaticFieldBarsEh.SetIndexOfFieldBar(const Child: TFieldBarEh; NewIndex: Integer);
begin
  if (FList.IndexOf(Child) >= 0) then
  begin
    FList.Remove(Child);
    if NewIndex < 0 then
      NewIndex := 0;
    if NewIndex > FList.Count then
      NewIndex := FList.Count;
    FList.Insert(NewIndex, Child);
    
    ResetChildrenIndices;
    ListChanged();
  end;
end;

procedure TGridStaticFieldBarsEh.ResetChildrenIndices();
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    FList[I].FStaticIndex := I;
end;

{$ENDREGION 'TGridStaticFieldBarsEh'}

{$REGION 'TFieldBarEh'}
constructor TFieldBarEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTitle := CreateTitle;

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

  FVisible := True;
  FVisibleIndex := -1;
  FDisplayIndex := -1;
end;

destructor TFieldBarEh.Destroy;
begin
  Destroying;
  FreeAndNil(FTitle);
  FreeAndNil(FFont);
  FreeAndNil(FFill);
  FreeAndNil(FPadding);
  inherited Destroy;
end;

function TFieldBarEh.CreateTitle: TFieldBarTitleEh;
begin
  Result := TFieldBarTitleEh.Create(Self);
end;

function TFieldBarEh.CreateGetBarValueEventParams(): TDataAxisGridGetBarValueParamsEh;
begin
  Result := TDataAxisGridGetBarValueParamsEh.Create;
end;

function TFieldBarEh.GetCellManagerAtListItemBar(AListItemBar: TTableRowViewEh): TBaseGridCellManagerEh;
begin
  Result := nil;
end;

function TFieldBarEh.GetListItemValue(AListItemBar: TTableRowViewEh): TValue;
var
  Params: TDataAxisGridGetBarValueParamsEh;
begin
  Params := CreateGetBarValueEventParams();
  Params.Init(Grid, Self, AListItemBar);
  ProcessGetCellValue(Params);
  Result := Params.Value;
  Params.Free;
end;

procedure TFieldBarEh.ProcessGetCellValue(Params: TDataAxisGridGetBarValueParamsEh);
var
  Grid: TCustomDataAxisGridEhCrack;
begin
  Grid := TCustomDataAxisGridEhCrack(GetGrid);

  Grid.HandleDataCellGetValue(Params);

  if Params.Handled = False then
    HandleDataCellGetValue(Params);

  if (Params.Handled = False) then
    Params.Value := DefaultGetListItemValue(Params.ListItemBar);
end;

procedure TFieldBarEh.HandleDataCellGetValue(Params: TDataAxisGridGetBarValueParamsEh);
begin
end;

function TFieldBarEh.DefaultGetListItemValue(AListItemBar: TTableRowViewEh): TValue;
begin
  if (Field <> nil) and (AListItemBar <> nil) then
  begin
    Result := AListItemBar.SourceRowLink.Value[Field.Index];
  end else
  begin
    Result := TValue.Empty;
  end;
end;

function TFieldBarEh.FormatValue(const Format: string; const Value: TValue): String;
begin
  Result := EhLibUtils.FormatValue(Format, Value);
end;

function TFieldBarEh.GetListItemDisplayText(AListItemBar: TTableRowViewEh; ACellManager: TBaseGridCellManagerEh): String;
var
  VarResult: TValue;
begin
  VarResult := GetListItemValue(AListItemBar);
  Result := GetDisplayText(VarResult, ACellManager);
end;

function TFieldBarEh.GetListItemDisplayText(AListItemBar: TTableRowViewEh): String;
var
  ACellManager: TBaseGridCellManagerEh;
begin
  ACellManager := GetCellManagerAtListItemBar(AListItemBar);
  Result := GetListItemDisplayText(AListItemBar, ACellManager);
end;

function TFieldBarEh.GetDisplayText(const VarValue: TValue; ACellManager: TBaseGridCellManagerEh): String;
var
  Params: TDataAxisGridGetDisplayTextParamsEh;
begin
  Params := CreateGetDisplayTextParams();
  Params.Init(Grid, Self, ACellManager, VarValue);
  ProcessGetDisplayText(Params);
  Result := Params.DisplayText;
  Params.Free;
end;

function TFieldBarEh.CreateGetDisplayTextParams(): TDataAxisGridGetDisplayTextParamsEh;
begin
  Result := TDataAxisGridGetDisplayTextParamsEh.Create;
end;

procedure TFieldBarEh.ProcessGetDisplayText(Params: TDataAxisGridGetDisplayTextParamsEh);
var
  Grid: TCustomDataAxisGridEhCrack;
begin
  Grid := TCustomDataAxisGridEhCrack(GetGrid);

  Grid.HandleDataCellGetDisplayText(Params);

  if Params.Handled = False then
    HandleDataCellGetDisplayText(Params);

  if (Params.Handled = False) then
    Params.DisplayText := DefaultGetDisplayText(Params.Value, Params.CellManager);
end;

procedure TFieldBarEh.HandleDataCellGetDisplayText(Params: TDataAxisGridGetDisplayTextParamsEh);
begin
end;

function TFieldBarEh.DefaultGetDisplayText(const VarValue: TValue; CellManager: TBaseGridCellManagerEh): String;
begin
  Result := TDataAxisCellManagerEh(CellManager).GetDefaultDisplayText(VarValue);
end;

function TFieldBarEh.CanEditShow: Boolean;
begin
  Result := AllowShowEditor;
end;

function TFieldBarEh.CanEditShowListItem(AListItemBar: TTableRowViewEh): Boolean;
var
  CellManager: TBaseGridCellManagerEh;
begin
  CellManager := GetCellManagerAtListItemBar(AListItemBar);
  Result := CanEditShow and CellManager.CanShowEditor(Grid);
end;

function TFieldBarEh.GetListItemEditText(AListItemBar: TTableRowViewEh): String;
var
  Grid: TCustomDataAxisGridEhCrack;
begin
  Result := '';
  Grid := TCustomDataAxisGridEhCrack(GetGrid);
  if Grid.TableView.Active then
  begin
    Result := GetListItemDisplayText(AListItemBar);
  end;
end;

procedure TFieldBarEh.SetCurrentListItemValue(const Value: TValue);
var
  Params: TDataAxisGridSetBarValueParamsEh;
  Grid: TCustomDataAxisGridEhCrack;
begin
  Grid := TCustomDataAxisGridEhCrack(GetGrid);
  Params := CreateSetBarValueEventParams();
  Params.Init(Grid, Self, Grid.CurrentListItemBar, Value);
  ProcessSetValue(Params);
  Params.Free;
end;

function TFieldBarEh.CreateSetBarValueEventParams(): TDataAxisGridSetBarValueParamsEh;
begin
  Result := TDataAxisGridSetBarValueParamsEh.Create;
end;

procedure TFieldBarEh.ProcessSetValue(Params: TDataAxisGridSetBarValueParamsEh);
var
  Grid: TCustomDataAxisGridEhCrack;
begin
  Grid := TCustomDataAxisGridEhCrack(GetGrid);
  if Grid <> nil then
    Grid.HandleDataCellSetValue(Params);

  if (Params.Handled = False) then
    HandleDataCellSetValue(Params);

  if (Params.Handled = False) then
    DefaultSetValue(Params.Value);
end;

procedure TFieldBarEh.HandleDataCellSetValue(Params: TDataAxisGridSetBarValueParamsEh);
begin
end;

procedure TFieldBarEh.DefaultSetValue(const Value: TValue);
var
  Grid: TCustomDataAxisGridEhCrack;
begin
  Grid := TCustomDataAxisGridEhCrack(GetGrid);
  if (Field <> nil ) then
    Grid.TableView.CurrentRowView.SourceRowLink.FieldValue[Field] := Value
  else
    raise Exception.Create('Field = nil. Can''t assign Value.');
end;

procedure TFieldBarEh.SetValueAsText(const StrVal: String);
var
  Grid: TCustomDataAxisGridEhCrack;
begin
  Grid := TCustomDataAxisGridEhCrack(GetGrid);
  Grid.TableView.CurrentRowView.SourceRowLink.FieldValue[Field] := StrVal;
end;

function TFieldBarEh.GetField: TTableFieldLinkEh;
begin
  CheckBindField();
  Result := FField;
end;

procedure TFieldBarEh.SetField(const Value: TTableFieldLinkEh);
begin
  if (Value <> FField) then
  begin
    FField := Value;
    FieldChanged;
    UpdateDefaults;
    NotifyChanges;
  end;
end;

procedure TFieldBarEh.FieldChanged;
begin
end;

procedure TFieldBarEh.ClearBindField();
begin
  FFieldBound := False;
end;

procedure TFieldBarEh.CheckBindField();
begin
  if FFieldBound = False then
    BindField;
end;

procedure TFieldBarEh.BindField;
var
  AField: TTableFieldLinkEh;
  Grid: TCustomDataAxisGridEhCrack;
begin
  AField := nil;
  Grid := TCustomDataAxisGridEhCrack(GetGrid);
  if Assigned(Grid) and
     Assigned(Grid.TableView) and
     (Grid.TableView.Fields <> nil) and
     not (csLoading in Grid.ComponentState) and
     (FieldName <> '')
  then
    AField := Grid.TableView.Fields.FindField(FieldName); { no exceptions }
  SetField(AField);
  FFieldBound := True;
end;

function TFieldBarEh.GetGrid: TCustomGridEh;
begin
  Result := FGrid;
end;

procedure TFieldBarEh.SetGrid(AGrid: TCustomGridEh; AInListState: TInListFieldBarStateEh);
begin
  FGrid := AGrid;
  FInListState := AInListState;
  if (csDestroying in ComponentState) then Exit;
  UpdateDefaults;
end;

procedure TFieldBarEh.UpdateDefaults;
begin
  RefreshDefaultFont();
  RefreshDefaultFill();
  RefreshDefaultPadding();
  Title.UpdateDefaults();
end;

procedure TFieldBarEh.NotifyChanges(CellLayoutAffects: Boolean = False);
begin
  Changed(CellLayoutAffects);
end;

procedure TFieldBarEh.Changed(CellLayoutAffects: Boolean = False);
var
  Grid: TCustomDataAxisGridEhCrack;
begin
  Grid := TCustomDataAxisGridEhCrack(FGrid);
  if (Grid <> nil) then
    Grid.FieldBarChanged(Self);
end;

function TFieldBarEh.GetVisibleIndex: Integer;
var
  Grid: TCustomDataAxisGridEhCrack;
begin
  Grid := TCustomDataAxisGridEhCrack(FGrid);
  if (FVisibleIndex < 0) and (Grid <> nil) then
    FVisibleIndex := Grid.VisibleFieldBars.IndexOf(Self);
  Result := FVisibleIndex;
end;

procedure TFieldBarEh.UpdateDisplayIndex;
var
  Grid: TCustomDataAxisGridEhCrack;
begin
  Grid := TCustomDataAxisGridEhCrack(FGrid);
  if (FDisplayIndex < 0) and (Grid <> nil) then
    FDisplayIndex := Grid.DisplayFieldBars.IndexOf(Self);
end;

function TFieldBarEh.GetDisplayIndex: Integer;
begin
  UpdateDisplayIndex;
  Result := FDisplayIndex;
end;

procedure TFieldBarEh.SetDisplayIndex(const Value: Integer);
var
  Grid: TCustomDataAxisGridEhCrack;
begin
  Grid := TCustomDataAxisGridEhCrack(FGrid);
  if Grid = nil then
    raise Exception.Create('Assigning DisplayIndex is not allowed if the Grid is not assigned.');

  if Grid.FieldBars.UpdateCount > 0 then
    FDisplayIndex := Value
  else
    Grid.DisplayFieldBars.MoveFieldBar(Self, Value);
end;

{$REGION 'TFieldBarEh.Font'}
procedure TFieldBarEh.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

function TFieldBarEh.DefaultFont: TFont;
begin
  if (GetGrid <> nil)
    then Result := TCustomDataAxisGridEhCrack(GetGrid).FieldBarOptions.Font
    else Result := SystemFont;
end;

procedure TFieldBarEh.FontChanged(Sender: TObject);
begin
  FFontStored := True;
  NotifyChanges;
end;

procedure TFieldBarEh.SetFontStored(const Value: Boolean);
begin
  if FFontStored <> Value then
  begin
    FFontStored := Value;
    RefreshDefaultFont;
  end;
end;

procedure TFieldBarEh.RefreshDefaultFont;
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

function TFieldBarEh.IsFontStored: Boolean;
begin
  Result := FFontStored;
end;
{$ENDREGION 'TFieldBarEh.Font'}

{$REGION 'TFieldBarEh.FontColor'}
function TFieldBarEh.GetFontColor: TAlphaColor;
begin
  if FontColorStored
    then Result := FFontColor
    else Result := DefaultFontColor();
end;

procedure TFieldBarEh.SetFontColor(const Value: TAlphaColor);
begin
  if FFontColor <> Value then
  begin
    FFontColor := Value;
    FFontColorStored := True;
    Changed;
  end;
end;

function TFieldBarEh.DefaultFontColor: TAlphaColor;
begin
  if (GetGrid <> nil)
    then Result := TCustomDataAxisGridEhCrack(GetGrid).FieldBarOptions.FontColor
    else Result := SystemFontColor;
end;

procedure TFieldBarEh.SetFontColorStored(const Value: Boolean);
begin
  if FFontColorStored <> Value then
  begin
    FFontColorStored := Value;
    Changed;
  end;
end;

function TFieldBarEh.IsFontColorStored: Boolean;
begin
  Result := FFontColorStored;
end;
{$ENDREGION 'TFieldBarEh.FontColor'}

{$REGION 'TFieldBarEh.Fill'}

procedure TFieldBarEh.SetFill(const Value: TBrush);
begin
  FFill.Assign(Value);
end;

procedure TFieldBarEh.SetFillStored(const Value: Boolean);
begin
  if FFillStored <> Value then
  begin
    FFillStored := Value;
    RefreshDefaultFill;
  end;
end;

function TFieldBarEh.IsFillStored: Boolean;
begin
  Result := FFillStored;
end;

function TFieldBarEh.DefaultFill: TBrush;
begin
  if (GetGrid <> nil)
    then Result := TCustomDataAxisGridEhCrack(GetGrid).FieldBarOptions.Fill
    else Result := SystemFill;
end;

procedure TFieldBarEh.RefreshDefaultFill;
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

procedure TFieldBarEh.FillChanged(Sender: TObject);
begin
  FFillStored := True;
  NotifyChanges;
end;

{$ENDREGION 'TFieldBarEh.Fill'}

function TFieldBarEh.GetHorzAlign: TTextAlign;
begin
  if HorzAlignStored
    then Result := FHorzAlign
    else Result := DefaultHorzAlign();
end;

procedure TFieldBarEh.SetHorzAlign(const Value: TTextAlign);
begin
  if (IsHorzAlignStored = False) or (Value <> FHorzAlign) then
  begin
    FHorzAlign := Value;
    FHorzAlignStored := True;
    Changed();
  end;
end;

function TFieldBarEh.DefaultHorzAlign: TTextAlign;
const
  AlignmentToTextAlignArr : array[TAlignment] of TTextAlign =
    (TTextAlign.Leading, TTextAlign.Trailing, TTextAlign.Center);
begin
  if (Field <> nil) then
  begin
    if IsTypeNumeric(Field.DataTypeInfo) or
       ((Field.DataTypeInfo = TypeInfo(Variant)) and IsVarTypeNumeric(Field.DataVarSubtype) = True) then
      Result := TTextAlign.Trailing
    else
      Result := TTextAlign.Leading;
  end else if (GetGrid <> nil) then
    Result := TCustomDataAxisGridEhCrack(GetGrid).FieldBarOptions.HorzAlign
  else
    Result := TTextAlign.Leading;
end;

function TFieldBarEh.IsHorzAlignStored: Boolean;
begin
  Result := FHorzAlignStored;
end;

procedure TFieldBarEh.SetHorzAlignStored(const Value: Boolean);
begin
  if FHorzAlignStored <> Value then
  begin
    FHorzAlignStored := Value;
    Changed();
  end;
end;

procedure TFieldBarEh.SetMergeDuplicates(const Value: Boolean);
begin
  if FMergeDuplicates <> Value then
  begin
    FMergeDuplicates := Value;
    NotifyChanges(True);
  end;
end;

function TFieldBarEh.GetVertAlign: TTextAlign;
begin
  if VertAlignStored
    then Result := FVertAlign
    else Result := DefaultVertAlign();
end;

procedure TFieldBarEh.SetVertAlign(const Value: TTextAlign);
begin
  if (IsVertAlignStored = False) or (Value <> FVertAlign) then
  begin
    FVertAlign := Value;
    FVertAlignStored := True;
    Changed();
  end;
end;

function TFieldBarEh.DefaultVertAlign: TTextAlign;
begin
  if (GetGrid <> nil)
    then Result := TCustomDataAxisGridEhCrack(GetGrid).FieldBarOptions.VertAlign
    else Result := TTextAlign.Center;
end;

function TFieldBarEh.IsVertAlignStored: Boolean;
begin
  Result := FVertAlignStored;
end;

procedure TFieldBarEh.SetVertAlignStored(const Value: Boolean);
begin
  if FVertAlignStored <> Value then
  begin
    FVertAlignStored := Value;
    Changed();
  end;
end;

procedure TFieldBarEh.SetVisible(const Value: Boolean);
begin
  if (FVisible <> Value) then
  begin
    FVisible := Value;
    if (GetGrid <> nil) then
      TCustomDataAxisGridEhCrack(GetGrid).FieldBarVisibleStateChanged(Self);
  end;
end;

function TFieldBarEh.GetReadOnly: Boolean;
begin
  if IsReadOnlyStored
    then Result := FReadOnly
    else Result := DefaultReadOnly();
end;

procedure TFieldBarEh.SetReadOnly(const Value: Boolean);
begin
  if (IsReadOnlyStored = False) or (Value <> FReadOnly) then
  begin
    FReadOnly := Value;
    FReadOnlyStored := True;
    Changed();
  end;
end;

procedure TFieldBarEh.SetTitle(const Value: TFieldBarTitleEh);
begin
  FTitle.Assign(Value);
end;

function TFieldBarEh.IsReadOnlyStored: Boolean;
begin
  Result := FReadOnlyStored;
end;

function TFieldBarEh.IsShowSelectionLayer(ACell: TGridBaseCellEh): Boolean;
begin
  Result := False;
end;

function TFieldBarEh.DefaultReadOnly: Boolean;
begin
  Result := False;
end;

procedure TFieldBarEh.SetFieldName(const Value: String);
begin
  if FFieldName <> Value then
  begin
    FFieldName := Value;
    ClearBindField;
    FieldNameChanged;
    Changed;
  end;
end;

procedure TFieldBarEh.FieldNameChanged;
begin
end;

procedure TFieldBarEh.TitleChanged(CellLayoutAffects: Boolean = False);
var
  Grid: TCustomDataAxisGridEhCrack;
begin
  Grid := TCustomDataAxisGridEhCrack(FGrid);
  if Grid <> nil  then
    Grid.Title.TitlePropChange(CellLayoutAffects);
    Changed(CellLayoutAffects);
end;

function TFieldBarEh.UseRightToLeftAlignment: Boolean;
begin
  Result := False;
end;

{$REGION 'TFieldBarEh.Padding'}
function TFieldBarEh.GetPadding: TBounds;
begin
  Result := FPadding;
end;

procedure TFieldBarEh.SetPadding(const Value: TBounds);
begin
  FPadding.Assign(Value);
end;

function TFieldBarEh.DefaultPadding: TBounds;
begin
  if (GetGrid <> nil)
    then Result := TCustomDataAxisGridEhCrack(GetGrid).FieldBarOptions.Padding
    else Result := EmptyBounds;
end;

procedure TFieldBarEh.RefreshDefaultPadding;
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

procedure TFieldBarEh.SetPaddingStored(const Value: Boolean);
begin
  if FPaddingStored <> Value then
  begin
    FPaddingStored := Value;
    RefreshDefaultPadding;
  end;
end;

function TFieldBarEh.IsPaddingStored: Boolean;
begin
  Result := FPaddingStored;
end;

procedure TFieldBarEh.PaddingChanged(Sender: TObject);
begin
  FPaddingStored := True;
  NotifyChanges(True);
end;
{$ENDREGION 'TFieldBarEh.Padding'}

function TFieldBarEh.CanEditModify: Boolean;
var
  VGrid: TCustomDataAxisGridEhCrack;
begin
  VGrid := TCustomDataAxisGridEhCrack(Grid);
  Result := CanModifyCellValue(VGrid.CurrentListItemBar);

  if Result then
  begin
    VGrid.TableView.EditCurrentRow;
    Result := VGrid.TableView.CurrentRowView.Editing;
  end;
end;

function TFieldBarEh.CanModifyCellValue(AListItemBar: TTableRowViewEh): Boolean;
var
  Params: TDataAxisCellCanModifyParamsEh;
  VGrid: TCustomDataAxisGridEhCrack;
begin
  VGrid := TCustomDataAxisGridEhCrack(Grid);
  Params := TDataAxisCellCanModifyParamsEh.Create;
  try
    Params.Init(Grid, Self, AListItemBar);
    VGrid.HandleCanModifyCellValue(Params);
    if Params.Handled = False then
      HandleCanModifyCellValue(Params);
    if Params.Handled = False then
      ProcessCanModifyCellValue(Params);
    Result := Params.CanModify;
  finally
    Params.Free;
  end;
end;

procedure TFieldBarEh.ProcessCanModifyCellValue(AParams: TDataAxisCellCanModifyParamsEh);
begin
  AParams.CanModify := DefaultCanModifyCellValue(AParams.ListItemBar);
end;

procedure TFieldBarEh.HandleCanModifyCellValue(AParams: TDataAxisCellCanModifyParamsEh);
begin
end;

function TFieldBarEh.DefaultCanModifyCellValue(AListItemBar: TTableRowViewEh): Boolean;
var
  AField: TTableFieldLinkEh;
  Grid: TCustomDataAxisGridEhCrack;
begin
  Grid := TCustomDataAxisGridEhCrack(FGrid);

  Result := True;
  if Assigned(Grid) then
    Result := Result and not Grid.ReadOnly
      and Grid.TableView.Active and Grid.TableView.CanModify;
  Result := Result and not ReadOnly;

  AField := Field;

  if AField = nil then
    Result := False
  else if Result then
    Result := Result and AField.CanModify;

  if Result then
    Result := Result and Grid.AllowedOperationUpdate;
end;

function TFieldBarEh.ValidChar(const KeyChar: Char): Boolean;
begin
    Result := DefaultValidChar(KeyChar);
end;

function TFieldBarEh.DefaultValidChar(const KeyChar: Char): Boolean;
begin
  Result := True;
end;

function TFieldBarEh.GetAllowShowEditor: Boolean;
begin
  if IsAllowShowEditorStored
    then Result := FAllowShowEditor
    else Result := DefaultAllowShowEditor();
end;

procedure TFieldBarEh.SetAllowShowEditor(const Value: Boolean);
begin
  if (IsAllowShowEditorStored = False) or (Value <> FAllowShowEditor) then
  begin
    FAllowShowEditor := Value;
    FAllowShowEditorStored := True;
    Changed();
  end;
end;

function TFieldBarEh.DefaultAllowShowEditor: Boolean;
begin
  if (GetGrid <> nil)
    then Result := TCustomDataAxisGridEhCrack(GetGrid).FieldBarOptions.AllowShowEditor
    else Result := True;
end;

procedure TFieldBarEh.SetAllowShowEditorStored(const Value: Boolean);
begin
  if FAllowShowEditorStored <> Value then
  begin
    FAllowShowEditorStored := Value;
    Changed();
  end;
end;

function TFieldBarEh.IsAllowShowEditorStored(): Boolean;
begin
  Result := FAllowShowEditorStored;
end;

function TFieldBarEh.GetHeightAutoExpand: Boolean;
begin
  if IsHeightAutoExpandStored
    then Result := FHeightAutoExpand
    else Result := DefaultHeightAutoExpand;
end;

function TFieldBarEh.DefaultHeightAutoExpand: Boolean;
begin
  if (GetGrid <> nil)
    then Result := TCustomDataAxisGridEhCrack(GetGrid).FieldBarOptions.HeightAutoExpand
    else Result := False;
end;

procedure TFieldBarEh.SetHeightAutoExpand(const Value: Boolean);
begin
  if (IsHeightAutoExpandStored = False) or (Value <> FHeightAutoExpand) then
  begin
    FHeightAutoExpand := Value;
    FHeightAutoExpandStored := True;
    HeightAutoExpandChanged();
    Changed();
  end;
end;

procedure TFieldBarEh.HeightAutoExpandChanged();
begin
end;

procedure TFieldBarEh.SetHeightAutoExpandStored(const Value: Boolean);
begin
  if FHeightAutoExpandStored <> Value then
  begin
    FHeightAutoExpandStored := Value;
    Changed();
  end;
end;

function TFieldBarEh.IsHeightAutoExpandStored: Boolean;
begin
  Result := FHeightAutoExpandStored;
end;

procedure TFieldBarEh.LinkActiveChanged;
begin
end;

procedure TFieldBarEh.DoBeforeFirstDrawing;
begin
end;

function TFieldBarEh.CreateFieldBarStyleParams(): TFieldBarDataCellStyleParamsEh;
begin
  Result := TFieldBarDataCellStyleParamsEh.Create;
end;

procedure TFieldBarEh.ProcessGetFieldBarStyleParams(Params: TDataAxisCellStyleParamsEh);
begin
  TCustomDataAxisGridEhCrack(Params.Grid).HandleDataCellGetStyleParams(Params);
  HandleGetFieldBarStyleParams(Params);
end;

procedure TFieldBarEh.HandleGetFieldBarStyleParams(Params: TDataAxisCellStyleParamsEh);
begin
end;

function TFieldBarEh.GetStaticIndex: Integer;
begin
  Result := FStaticIndex;
end;

procedure TFieldBarEh.SetStaticIndex(const Value: Integer);
var
  Grid: TCustomDataAxisGridEhCrack;
begin
  Grid := TCustomDataAxisGridEhCrack(GetGrid);
  if (Grid <> nil) and
     (InListState = TInListFieldBarStateEh.StaticState) and
     (GetStaticIndex <> Value)
  then
    Grid.StaticFieldBars.SetIndexOfFieldBar(Self, Value);
end;

{$REGION 'TFieldBarEh.Tooltips'}
function TFieldBarEh.GetTooltips: Boolean;
begin
  if IsTooltipsStored
    then Result := FTooltips
    else Result := DefaultTooltips;
end;

procedure TFieldBarEh.SetTooltips(const Value: Boolean);
begin
  if (IsTooltipsStored = False) or (Value <> FTooltips) then
  begin
    FTooltips := Value;
    FTooltipsStored := True;
    TooltipsChanged();
  end;
end;

function TFieldBarEh.DefaultTooltips: Boolean;
begin
  if (GetGrid <> nil)
    then Result := TCustomDataAxisGridEhCrack(GetGrid).FieldBarOptions.Tooltips
    else Result := False;
end;

function TFieldBarEh.IsTooltipsStored: Boolean;
begin
  Result := FTooltipsStored;
end;

procedure TFieldBarEh.SetTooltipsStored(const Value: Boolean);
begin
  if FTooltipsStored <> Value then
  begin
    FTooltipsStored := Value;
    TooltipsChanged();
  end;
end;

procedure TFieldBarEh.TooltipsChanged();
begin

end;

{$ENDREGION 'TFieldBarEh.Tooltips'}

function TFieldBarEh.GetRefSelf: TFieldBarEh;
begin
  Result := Self;
end;

procedure TFieldBarEh.InitCell(ACell: TGridBaseCellEh; AStyleParams: TDataAxisCellStyleParamsEh);
begin
end;

procedure TFieldBarEh.InitStyleParams(Params: TDataAxisCellStyleParamsEh);
begin
  Params.Font := Font;
  Params.FontColor := FontColor;
  Params.Fill := Fill;
  Params.Padding := Padding;
  Params.HorzAlign := HorzAlign;
  Params.VertAlign := VertAlign;
end;

procedure TFieldBarEh.DefaultInitEditParams(Params: TBaseGridCellEditParamsEh);
var
  DataParams: TDataAxisCellEditParamsEh;
begin
  DataParams := Params as TDataAxisCellEditParamsEh;
  Params.EditorReadOnly := CanModifyCellValue(DataParams.ListItemBar) = False;
end;

function TFieldBarEh.IsCalcNextPriorRecordValue: Boolean;
begin
  Result := MergeDuplicates;
end;

procedure TFieldBarEh.HandleDataCellInitEditParams(AParams: TBaseGridCellEditParamsEh);
begin

end;

procedure TFieldBarEh.HandleDataCellInTextLinkClick(Params: TDataAxisCellInTextLinkClickParamsEh);
begin
end;

procedure TFieldBarEh.HandleCreateCellContent(Params: TBaseGridCreateCellContentParamsEh);
begin
end;

procedure TFieldBarEh.HandleDataCellInitContent(Params: TBaseGridInitCellContentParamsEh);
begin
end;

procedure TFieldBarEh.HandleDataCellKeyDownEvent(Params: TBaseGridCellKeyDownParamsEh);
begin
end;

procedure TFieldBarEh.HandleDataCellMouseDownEvent(Params: TGridCellMouseButtonParamsEh);
begin
end;

procedure TFieldBarEh.HandleDataCellMouseClickEvent(Params: TGridCellMouseButtonParamsEh);
begin
end;

procedure TFieldBarEh.HandleInitCellEditor(AParams: TBaseGridInitEditorParamsEh);
begin
end;

procedure TFieldBarEh.HandleDataCellStartEdit(Params: TPersistent);
begin
end;

{$ENDREGION 'TFieldBarEh'}

{$REGION 'TFieldBarOptionsEh'}
constructor TFieldBarOptionsEh.Create(AGrid: TControl);
begin
  inherited Create;
  FGrid := AGrid;
  FHorzAlign := TTextAlign.Leading;
  FVertAlign := TTextAlign.Leading;
  FAllowShowEditor := True;

  FFont := TFont.Create();
  FFont.Assign(DefaultFont());
  FFont.OnChanged := FontChanged;
  FFontStored := False;
  FFontColorStored := False;

  FDefaultFill := TBrush.Create(TBrushKind.None, TAlphaColorRec.Null);

  FFill := TBrush.Create(TBrushKind.None, TAlphaColorRec.Null);
  FFill.Assign(DefaultFill());
  FFill.OnChanged := FillChanged;
  FFillStored := False;

  FPadding := TBounds.Create(RectF(2, 2, 2, 2));
  FPadding.OnChange := PaddingChanged;

  FTrimming := TTextTrimming.Character;
  FTooltips := True;
end;

destructor TFieldBarOptionsEh.Destroy;
begin
  FreeAndNil(FFont);
  FreeAndNil(FDefaultFill);
  FreeAndNil(FFill);
  FreeAndNil(FPadding);

  inherited Destroy;
end;

procedure TFieldBarOptionsEh.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
end;

procedure TFieldBarOptionsEh.Changed(CellLayoutAffects: Boolean = False);
begin
  if (FGrid <> nil) then
    TCustomDataAxisGridEhCrack(FGrid).LayoutChanged(CellLayoutAffects);
end;

{$REGION 'Font'}
procedure TFieldBarOptionsEh.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

function TFieldBarOptionsEh.IsFontStored: Boolean;
begin
  Result := FFontStored;
end;

function TFieldBarOptionsEh.DefaultFont: TFont;
begin
  Result := TCustomDataAxisGridEhCrack(FGrid).Font;
end;

procedure TFieldBarOptionsEh.FontChanged(Sender: TObject);
begin
  FFontStored := True;
  TCustomDataAxisGridEhCrack(FGrid).FieldBars.RefreshDefaultFont;
  Changed(True);
end;

procedure TFieldBarOptionsEh.RefreshDefaultFont;
var
  Save: TNotifyEvent;
begin
  if FontStored then Exit;
  Save := FFont.OnChanged;
  FFont.OnChanged := nil;
  try
    FFont.Assign(DefaultFont);
    TCustomDataAxisGridEhCrack(FGrid).FieldBars.RefreshDefaultFont;
  finally
    FFont.OnChanged := Save;
  end;
end;

procedure TFieldBarOptionsEh.SetFontStored(const Value: Boolean);
begin
  if FFontStored <> Value then
  begin
    FFontStored := Value;
    Changed(True);
  end;
end;
{$ENDREGION 'Font'}

{$REGION 'FontColor'}
function TFieldBarOptionsEh.GetFontColor: TAlphaColor;
begin
  if FontColorStored
    then Result := FFontColor
    else Result := DefaultFontColor();
end;

function TFieldBarOptionsEh.IsFontColorStored: Boolean;
begin
  Result := FFontColorStored;
end;

procedure TFieldBarOptionsEh.SetFontColor(const Value: TAlphaColor);
begin
  if FFontColor <> Value then
  begin
    FFontColor := Value;
    FFontColorStored := True;
    Changed(False);
  end;
end;

procedure TFieldBarOptionsEh.SetFontColorStored(const Value: Boolean);
begin
  if FFontColorStored <> Value then
  begin
    FFontColorStored := Value;
    Changed(False);
  end;
end;

function TFieldBarOptionsEh.DefaultFontColor: TAlphaColor;
begin
  if GridControl <> nil
    then Result := TCustomDataAxisGridEhCrack(GridControl).FInternalFontColor
    else Result := SystemFontColor();
end;

{$ENDREGION 'FontColor'}

{$REGION 'Fill'}
procedure TFieldBarOptionsEh.SetFill(const Value: TBrush);
begin
  FFill.Assign(Value);
end;

procedure TFieldBarOptionsEh.SetFillStored(const Value: Boolean);
begin
  if FFillStored <> Value then
  begin
    FFillStored := Value;
    RefreshDefaultFill;
  end;
end;

procedure TFieldBarOptionsEh.RefreshDefaultFill;
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

  if (GridControl <> nil) then
    TCustomDataAxisGridEhCrack(GridControl).FieldBars.RefreshDefaultFill;
end;

function TFieldBarOptionsEh.DefaultFill: TBrush;
begin
  if FGrid <> nil
    then Result := TCustomDataAxisGridEhCrack(FGrid).StylePainter.BackgroundFill
    else Result := FDefaultFill;
end;

function TFieldBarOptionsEh.IsFillStored: Boolean;
begin
  Result := FFillStored;
end;

procedure TFieldBarOptionsEh.FillChanged(Sender: TObject);
begin
  FFillStored := True;
  TCustomDataAxisGridEhCrack(FGrid).FieldBars.RefreshDefaultFill;
  Changed(False);
end;
{$ENDREGION 'Fill'}

procedure TFieldBarOptionsEh.SetHorzAlign(const Value: TTextAlign);
begin
  if (FHorzAlign <> Value) then
  begin
    FHorzAlign := Value;
    Changed(False);
  end;
end;

procedure TFieldBarOptionsEh.SetVertAlign(const Value: TTextAlign);
begin
  if (FVertAlign <> Value) then
  begin
    FVertAlign := Value;
    Changed(False);
  end;
end;

{$REGION Padding}
function TFieldBarOptionsEh.GetPadding: TBounds;
begin
  Result := FPadding;
end;

procedure TFieldBarOptionsEh.PaddingChanged(Sender: TObject);
begin
  FPaddingStored := True;
  TCustomDataAxisGridEhCrack(FGrid).FieldBars.RefreshDefaultPadding;
  Changed(True);
end;

procedure TFieldBarOptionsEh.SetPadding(const Value: TBounds);
begin
  FPadding.Assign(Value);
end;

function TFieldBarOptionsEh.IsPaddingStored: Boolean;
begin
  Result := FPaddingStored;
end;

procedure TFieldBarOptionsEh.SetPaddingStored(const Value: Boolean);
begin
  if FPaddingStored <> Value then
  begin
    FPaddingStored := Value;
    RefreshDefaultPadding;
    Changed(True);
  end;
end;

procedure TFieldBarOptionsEh.RefreshDefaultPadding;
var
  Save: TNotifyEvent;
begin
  if PaddingStored then Exit;
  Save := FPadding.OnChange;
  FPadding.OnChange := nil;
  try
    FPadding.Rect := DefaultPadding;
    TCustomDataAxisGridEhCrack(FGrid).FieldBars.RefreshDefaultPadding;
  finally
    FPadding.OnChange := Save;
  end;
end;

function TFieldBarOptionsEh.DefaultPadding: TRectF;
begin
  Result := Padding.DefaultValue;
end;
{$ENDREGION Padding}

procedure TFieldBarOptionsEh.SetWordWrap(const Value: Boolean);
begin
  if(FWordWrap <> Value) then
  begin
    FWordWrap := Value;
    Changed(True);
  end;
end;

procedure TFieldBarOptionsEh.SetHeightAutoExpand(const Value: Boolean);
begin
  if(FHeightAutoExpand <> Value) then
  begin
    FHeightAutoExpand := Value;
    HeightAutoExpandChanged();
  end;
end;

procedure TFieldBarOptionsEh.HeightAutoExpandChanged();
begin
  Changed(True);
end;

procedure TFieldBarOptionsEh.SetTooltips(const Value: Boolean);
begin
  if(FTooltips <> Value) then
  begin
    FTooltips := Value;
    Changed(False);
  end;
end;

procedure TFieldBarOptionsEh.SetTrimming(const Value: TTextTrimming);
begin
  if(FTrimming <> Value) then
  begin
    FTrimming := Value;
    Changed(False);
  end;
end;

{$REGION HorzLinesColor}
function TFieldBarOptionsEh.GetHorzLinesColor: TAlphaColor;
begin
  if HorzLinesColorStored
    then Result := FHorzLinesColor
    else Result := DefaultHorzLinesColor();
end;

procedure TFieldBarOptionsEh.SetHorzLinesColor(const Value: TAlphaColor);
begin
  if (FHorzLinesColor <> Value) or (FHorzLinesColorStored = False) then
  begin
    FHorzLinesColor := Value;
    FHorzLinesColorStored := True;
    Changed(False);
  end;
end;

function TFieldBarOptionsEh.IsHorzLinesColorStored: Boolean;
begin
  Result := FHorzLinesColorStored;
end;

procedure TFieldBarOptionsEh.SetHorzLinesColorStored(const Value: Boolean);
begin
  if FHorzLinesColorStored <> Value then
  begin
    FHorzLinesColorStored := Value;
    if FHorzLinesColorStored then
      FHorzLinesColor := DefaultHorzLinesColor;
    Changed(False);
  end;
end;

function TFieldBarOptionsEh.DefaultHorzLinesColor(): TAlphaColor;
begin
  Result := TCustomDataAxisGridEhCrack(FGrid).GridLineOptions.BrightColor;
end;
{$ENDREGION HorzLinesColor}

{$REGION HorzLinesVisible}
function TFieldBarOptionsEh.GetHorzLinesVisible: Boolean;
begin
  if HorzLinesVisibleStored
    then Result := FHorzLinesVisible
    else Result := DefaultHorzLinesVisible();
end;

procedure TFieldBarOptionsEh.SetHorzLinesVisible(const Value: Boolean);
begin
  if (FHorzLinesVisible <> Value) or (FHorzLinesVisibleStored = False) then
  begin
    FHorzLinesVisible := Value;
    FHorzLinesVisibleStored := True;
    Changed(False);
  end;
end;

function TFieldBarOptionsEh.IsHorzLinesVisibleStored: Boolean;
begin
  Result := FHorzLinesVisibleStored;
end;

procedure TFieldBarOptionsEh.SetHorzLinesVisibleStored(const Value: Boolean);
begin
  if FHorzLinesVisibleStored <> Value then
  begin
    FHorzLinesVisibleStored := Value;
    if FHorzLinesVisibleStored then
      FHorzLinesVisible := DefaultHorzLinesVisible;
    Changed(False);
  end;
end;

function TFieldBarOptionsEh.DefaultHorzLinesVisible(): Boolean;
begin
  Result := TCustomDataAxisGridEhCrack(FGrid).GridLineOptions.HorzLinesVisible;
end;

{$ENDREGION HorzLinesColor}

{$REGION VertLinesColor}
function TFieldBarOptionsEh.GetVertLinesColor: TAlphaColor;
begin
  if VertLinesColorStored
    then Result := FVertLinesColor
    else Result := DefaultVertLinesColor();
end;

procedure TFieldBarOptionsEh.SetVertLinesColor(const Value: TAlphaColor);
begin
  if (FVertLinesColor <> Value) or (FVertLinesColorStored = False) then
  begin
    FVertLinesColor := Value;
    FVertLinesColorStored := True;
    Changed(False);
  end;
end;

function TFieldBarOptionsEh.IsVertLinesColorStored: Boolean;
begin
  Result := FVertLinesColorStored;
end;

procedure TFieldBarOptionsEh.SetVertLinesColorStored(const Value: Boolean);
begin
  if FVertLinesColorStored <> Value then
  begin
    FVertLinesColorStored := Value;
    if FVertLinesColorStored then
      FVertLinesColor := DefaultVertLinesColor;
    Changed(False);
  end;
end;

function TFieldBarOptionsEh.DefaultVertLinesColor(): TAlphaColor;
begin
  Result := TCustomDataAxisGridEhCrack(FGrid).GridLineOptions.BrightColor;
end;
{$ENDREGION VertLinesColor}

{$REGION VertLinesVisible}
function TFieldBarOptionsEh.GetVertLinesVisible: Boolean;
begin
  if VertLinesVisibleStored
    then Result := FVertLinesVisible
    else Result := DefaultVertLinesVisible();
end;

procedure TFieldBarOptionsEh.SetVertLinesVisible(const Value: Boolean);
begin
  if (FVertLinesVisible <> Value) or (FVertLinesVisibleStored = False) then
  begin
    FVertLinesVisible := Value;
    FVertLinesVisibleStored := True;
    Changed(True);
  end;
end;

function TFieldBarOptionsEh.IsVertLinesVisibleStored: Boolean;
begin
  Result := FVertLinesVisibleStored;
end;

procedure TFieldBarOptionsEh.SetVertLinesVisibleStored(const Value: Boolean);
begin
  if FVertLinesVisibleStored <> Value then
  begin
    FVertLinesVisibleStored := Value;
    if FVertLinesVisibleStored then
      FVertLinesVisible := DefaultVertLinesVisible;
    Changed(True);
  end;
end;

function TFieldBarOptionsEh.DefaultVertLinesVisible(): Boolean;
begin
  Result := TCustomDataAxisGridEhCrack(FGrid).GridLineOptions.VertLinesVisible;
end;
{$ENDREGION VertLinesVisible}

{$ENDREGION 'TFieldBarOptionsEh'}

{$REGION 'TAxisGridTitleBarEh'}

constructor TAxisGridTitleBarEh.Create(AGrid: TControl);
//var
//  ColorsService: IGridSystemColorsService;
begin
  inherited Create(AGrid);
  SetSubComponent(True);
  FGrid := AGrid;
  FVisible := True;
  FWordWrap := False;

  FHorzAlign := TTextAlign.Leading;
  FVertAlign := TTextAlign.Center;

  FFont := TFont.Create();
  FFont.Assign(DefaultFont());
  FFont.OnChanged := FontChanged;
  FFontStored := False;

//  TPlatformServices.Current.SupportsPlatformService(IGridSystemColorsService, ColorsService);
  FDefaultFill := TBrush.Create(TBrushKind.None, TAlphaColorRec.Null);

  FFill := TBrush.Create(TBrushKind.None, TAlphaColorRec.Null);
  FFill.Assign(DefaultFill());
  FFill.OnChanged := FillChanged;
  FFillStored := False;

  FPadding := TBounds.Create(RectF(2, 2, 2, 2));
  FPadding.OnChange := PaddingChanged;
end;

destructor TAxisGridTitleBarEh.Destroy;
begin
  FreeAndNil(FFont);
  FreeAndNil(FDefaultFill);
  FreeAndNil(FFill);
  FreeAndNil(FPadding);
  inherited Destroy;
end;

procedure TAxisGridTitleBarEh.Changed(CellLayoutAffects: Boolean = False);
begin
  TCustomDataAxisGridEhCrack(FGrid).LayoutChanged;
end;

procedure TAxisGridTitleBarEh.TitlePropChange(CellLayoutAffects: Boolean);
begin
end;

{$REGION ' Font'}
procedure TAxisGridTitleBarEh.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TAxisGridTitleBarEh.RefreshDefaultFont;
var
  Save: TNotifyEvent;
begin
  if FontStored then Exit;
  Save := FFont.OnChanged;
  FFont.OnChanged := nil;
  try
    FFont.Assign(DefaultFont);
    TCustomDataAxisGridEhCrack(FGrid).FieldBars.RefreshDefaultTitleFont;
  finally
    FFont.OnChanged := Save;
  end;
end;

function TAxisGridTitleBarEh.DefaultFont: TFont;
begin
  Result := TCustomDataAxisGridEhCrack(FGrid).Font;
end;

procedure TAxisGridTitleBarEh.FontChanged(Sender: TObject);
begin
  FFontStored := True;
  TCustomDataAxisGridEhCrack(FGrid).FieldBars.RefreshTitleDefaultFont;
  Changed(True);
end;

function TAxisGridTitleBarEh.IsFontStored: Boolean;
begin
  Result := FFontStored;
end;

procedure TAxisGridTitleBarEh.SetFontStored(const Value: Boolean);
begin
  if FFontStored <> Value then
  begin
    FFontStored := Value;
    RefreshDefaultFont;
    TCustomDataAxisGridEhCrack(FGrid).FieldBars.RefreshTitleDefaultFont;
    Changed(True);
  end;
end;
{$ENDREGION ' Font'}

{$REGION ' FontColor'}
function TAxisGridTitleBarEh.GetFontColor: TAlphaColor;
begin
  if FontColorStored
    then Result := FFontColor
    else Result := DefaultFontColor();
end;

function TAxisGridTitleBarEh.IsFontColorStored: Boolean;
begin
  Result := FFontColorStored;
end;

procedure TAxisGridTitleBarEh.SetFontColor(const Value: TAlphaColor);
begin
  if FFontColor <> Value then
  begin
    FFontColor := Value;
    FFontColorStored := True;
    Changed(False);
  end;
end;

procedure TAxisGridTitleBarEh.SetFontColorStored(const Value: Boolean);
begin
  if FFontColorStored <> Value then
  begin
    FFontColorStored := Value;
    Changed(False);
  end;
end;

function TAxisGridTitleBarEh.DefaultFontColor: TAlphaColor;
begin
  if FGrid <> nil
    then Result := TCustomDataAxisGridEhCrack(FGrid).StylePainter.TitleForeColor
    else Result := SystemFontColor();
end;
{$ENDREGION ' FontColor'}

{$REGION ' Fill'}
procedure TAxisGridTitleBarEh.SetFill(const Value: TBrush);
begin
  FFill.Assign(Value);
end;

function TAxisGridTitleBarEh.DefaultFill: TBrush;
begin
  Result := FDefaultFill;
end;

procedure TAxisGridTitleBarEh.FillChanged(Sender: TObject);
begin
  FFillStored := True;
  TCustomDataAxisGridEhCrack(FGrid).FieldBars.RefreshTitleDefaultFill;
  Changed;
end;

function TAxisGridTitleBarEh.IsFillStored: Boolean;
begin
  Result := FFillStored;
end;

procedure TAxisGridTitleBarEh.SetFillStored(const Value: Boolean);
begin
  if FFillStored <> Value then
  begin
    FFillStored := Value;
    RefreshDefaultFill;
    TCustomDataAxisGridEhCrack(FGrid).FieldBars.RefreshTitleDefaultFill;
    Changed(True);
  end;
end;

procedure TAxisGridTitleBarEh.RefreshDefaultFill;
var
  Save: TNotifyEvent;
begin
  if FontStored then Exit;
  Save := FFill.OnChanged;
  FFill.OnChanged := nil;
  try
    FFill.Assign(DefaultFill);
  finally
    FFill.OnChanged := Save;
  end;
end;
{$ENDREGION ' Fill'}

{$REGION ' HorzAlign'}
function TAxisGridTitleBarEh.GetHorzAlign: TTextAlign;
begin
  if HorzAlignStored
    then Result := FHorzAlign
    else Result := DefaultHorzAlign();
end;

procedure TAxisGridTitleBarEh.SetHorzAlign(const Value: TTextAlign);
begin
  if (IsHorzAlignStored = False) or (Value <> FHorzAlign) then
  begin
    FHorzAlign := Value;
    FHorzAlignStored := True;
    Changed();
  end;
end;

function TAxisGridTitleBarEh.DefaultHorzAlign: TTextAlign;
begin
  Result := TTextAlign.Leading;
end;

procedure TAxisGridTitleBarEh.SetHorzAlignStored(const Value: Boolean);
begin
  if FHorzAlignStored <> Value then
  begin
    FHorzAlignStored := Value;
    Changed();
  end;
end;

function TAxisGridTitleBarEh.IsHorzAlignStored: Boolean;
begin
  Result := FHorzAlignStored;
end;
{$ENDREGION ' HorzAlign'}

{$REGION ' VertAlign'}
procedure TAxisGridTitleBarEh.SetVertAlign(const Value: TTextAlign);
begin
  if (FVertAlign <> Value) then
  begin
    FVertAlign := Value;
    Changed();
  end;
end;
{$ENDREGION ' VertAlign'}

{$REGION ' FontPadding'}
function TAxisGridTitleBarEh.GetPadding: TBounds;
begin
  Result := FPadding;
end;

procedure TAxisGridTitleBarEh.PaddingChanged(Sender: TObject);
begin
  TCustomDataAxisGridEhCrack(FGrid).FieldBars.RefreshTitleDefaultPadding;
  Changed(True);
end;

procedure TAxisGridTitleBarEh.SetPadding(const Value: TBounds);
begin
  FPadding.Assign(Value);
end;
{$ENDREGION ' FontPadding'}

{$REGION ' HorzLinesColor'}
function TAxisGridTitleBarEh.GetHorzLinesColor: TAlphaColor;
begin
  if HorzLinesColorStored
    then Result := FHorzLinesColor
    else Result := DefaultHorzLinesColor();
end;

procedure TAxisGridTitleBarEh.SetHorzLinesColor(const Value: TAlphaColor);
begin
  if (FHorzLinesColor <> Value) or (FHorzLinesColorStored = False) then
  begin
    FHorzLinesColor := Value;
    FHorzLinesColorStored := True;
    Changed;
  end;
end;

function TAxisGridTitleBarEh.IsHorzLinesColorStored: Boolean;
begin
  Result := FHorzLinesColorStored;
end;

procedure TAxisGridTitleBarEh.SetHorzLinesColorStored(const Value: Boolean);
begin
  if FHorzLinesColorStored <> Value then
  begin
    FHorzLinesColorStored := Value;
    if FHorzLinesColorStored then
      FHorzLinesColor := DefaultHorzLinesColor;
    Changed;
  end;
end;

function TAxisGridTitleBarEh.DefaultHorzLinesColor(): TAlphaColor;
begin
  Result := TCustomDataAxisGridEhCrack(FGrid).GridLineOptions.DarkColor;
end;
{$ENDREGION ' HorzLinesColor'}

{$REGION ' HorzLinesVisible'}
function TAxisGridTitleBarEh.GetHorzLinesVisible: Boolean;
begin
  if HorzLinesVisibleStored
    then Result := FHorzLinesVisible
    else Result := DefaultHorzLinesVisible();
end;

procedure TAxisGridTitleBarEh.SetHorzLinesVisible(const Value: Boolean);
begin
  if (FHorzLinesVisible <> Value) or (FHorzLinesVisibleStored = False) then
  begin
    FHorzLinesVisible := Value;
    FHorzLinesVisibleStored := True;
    Changed;
  end;
end;

function TAxisGridTitleBarEh.IsHorzLinesVisibleStored: Boolean;
begin
  Result := FHorzLinesVisibleStored;
end;

procedure TAxisGridTitleBarEh.SetHorzLinesVisibleStored(const Value: Boolean);
begin
  if FHorzLinesVisibleStored <> Value then
  begin
    FHorzLinesVisibleStored := Value;
    if FHorzLinesVisibleStored then
      FHorzLinesVisible := DefaultHorzLinesVisible;
    Changed;
  end;
end;

function TAxisGridTitleBarEh.DefaultHorzLinesVisible(): Boolean;
begin
  Result := TCustomDataAxisGridEhCrack(FGrid).GridLineOptions.HorzLinesVisible;
end;
{$ENDREGION ' HorzLinesColor'}

{$REGION ' VertLinesColor'}
function TAxisGridTitleBarEh.GetVertLinesColor: TAlphaColor;
begin
  if VertLinesColorStored
    then Result := FVertLinesColor
    else Result := DefaultVertLinesColor();
end;

procedure TAxisGridTitleBarEh.SetVertLinesColor(const Value: TAlphaColor);
begin
  if (FVertLinesColor <> Value) or (FVertLinesColorStored = False) then
  begin
    FVertLinesColor := Value;
    FVertLinesColorStored := True;
    Changed;
  end;
end;

function TAxisGridTitleBarEh.IsVertLinesColorStored: Boolean;
begin
  Result := FVertLinesColorStored;
end;

procedure TAxisGridTitleBarEh.SetVertLinesColorStored(const Value: Boolean);
begin
  if FVertLinesColorStored <> Value then
  begin
    FVertLinesColorStored := Value;
    if FVertLinesColorStored then
      FVertLinesColor := DefaultVertLinesColor;
    Changed;
  end;
end;

function TAxisGridTitleBarEh.DefaultVertLinesColor(): TAlphaColor;
begin
  Result := TCustomDataAxisGridEhCrack(FGrid).GridLineOptions.DarkColor;
end;
{$ENDREGION ' VertLinesColor'}

{$REGION ' VertLinesVisible'}
function TAxisGridTitleBarEh.GetVertLinesVisible: Boolean;
begin
  if VertLinesVisibleStored
    then Result := FVertLinesVisible
    else Result := DefaultVertLinesVisible();
end;

procedure TAxisGridTitleBarEh.SetVertLinesVisible(const Value: Boolean);
begin
  if (FVertLinesVisible <> Value) or (FVertLinesVisibleStored = False) then
  begin
    FVertLinesVisible := Value;
    FVertLinesVisibleStored := True;
    Changed;
  end;
end;

function TAxisGridTitleBarEh.IsVertLinesVisibleStored: Boolean;
begin
  Result := FVertLinesVisibleStored;
end;

procedure TAxisGridTitleBarEh.SetVertLinesVisibleStored(const Value: Boolean);
begin
  if FVertLinesVisibleStored <> Value then
  begin
    FVertLinesVisibleStored := Value;
    if FVertLinesVisibleStored then
      FVertLinesVisible := DefaultVertLinesVisible;
    Changed;
  end;
end;

function TAxisGridTitleBarEh.DefaultVertLinesVisible(): Boolean;
begin
  Result := TCustomDataAxisGridEhCrack(FGrid).GridLineOptions.VertLinesVisible;
end;
{$ENDREGION ' VertLinesVisible'}

procedure TAxisGridTitleBarEh.SetVisible(const Value: Boolean);
begin
  if(FVisible <> Value) then
  begin
    FVisible := Value;
    Changed();
  end;
end;

procedure TAxisGridTitleBarEh.SetWordWrap(const Value: Boolean);
begin
  if(FWordWrap <> Value) then
  begin
    FWordWrap := Value;
    Changed();
  end;
end;

procedure TAxisGridTitleBarEh.SetHeightAutoExpand(const Value: Boolean);
begin
  if(FHeightAutoExpand <> Value) then
  begin
    FHeightAutoExpand := Value;
    Changed();
  end;
end;

{$ENDREGION TAxisGridTitleBarEh}

{$REGION 'TGridFieldBarReadonlyListEh'}

constructor TGridFieldBarReadonlyListEh.Create(AGrid: TControl;
  AList: TList<TFieldBarEh>);
begin
  inherited Create(AList);
  FGrid := AGrid;
end;

destructor TGridFieldBarReadonlyListEh.Destroy;
begin
  inherited Destroy;
end;
{$ENDREGION TGridFieldBarReadonlyListEh}

{$REGION 'TGridAllFieldBarListEh'}

constructor TGridAllFieldBarListEh.Create(AGrid: TControl; AList: TList<TFieldBarEh>);
begin
  inherited Create(AGrid, AList);
end;

destructor TGridAllFieldBarListEh.Destroy;
begin
  inherited Destroy;
end;

procedure TGridAllFieldBarListEh.BeginUpdate;
begin
  FUpdateCount := FUpdateCount + 1;
end;

procedure TGridAllFieldBarListEh.EndUpdate;
var
  Grid: TCustomDataAxisGridEhCrack;
begin
  Grid := TCustomDataAxisGridEhCrack(FGrid);

  FUpdateCount := FUpdateCount - 1;
  Assert(FUpdateCount >= 0, 'TGridAllFieldBarListEh.EndUpdate; FUpdateCount >= 0 condition failed.');

  if FUpdateCount = 0 then
  begin
    Grid.AllFieldBarPropsEndUpdate;
    Grid.LayoutChanged;
  end;
end;

procedure TGridAllFieldBarListEh.LinkActiveChanged;
var
  FieldBar: TFieldBarEh;
begin
  for FieldBar in Self do
  begin
    FieldBar.LinkActiveChanged;
  end;
end;

procedure TGridAllFieldBarListEh.DoBeforeFirstDrawing();
var
  FieldBar: TFieldBarEh;
begin
  for FieldBar in Self do
  begin
    FieldBar.DoBeforeFirstDrawing();
  end;
end;

procedure TGridAllFieldBarListEh.RefreshDefaultFont;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].RefreshDefaultFont;
end;

procedure TGridAllFieldBarListEh.RefreshDefaultTitleFont;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Title.RefreshDefaultFont;
end;

procedure TGridAllFieldBarListEh.RefreshDefaultFill;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].RefreshDefaultFill;
end;

procedure TGridAllFieldBarListEh.RefreshDefaultPadding;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].RefreshDefaultPadding;
end;

procedure TGridAllFieldBarListEh.RefreshTitleDefaultFill;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Title.RefreshDefaultFill;
end;

procedure TGridAllFieldBarListEh.RefreshTitleDefaultFont;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Title.RefreshDefaultFont;
end;

procedure TGridAllFieldBarListEh.RefreshTitleDefaultPadding;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Title.RefreshDefaultPadding;
end;

{$ENDREGION TGridAllFieldBarListEh}

{$REGION 'TGridDisplayFieldBarsEh'}

constructor TGridDisplayFieldBarsEh.Create(AGrid: TControl;
  AList: TList<TFieldBarEh>);
begin
  inherited Create(AGrid, AList);
  FIndexesIsFixed := False;
end;

destructor TGridDisplayFieldBarsEh.Destroy;
begin
  inherited Destroy;
end;

procedure TGridDisplayFieldBarsEh.MoveFieldBar(AFieldBar: TFieldBarEh; NewDisplayIndex: Integer);
var
  FieldBarIndex: Integer;
  NewList: TList<TFieldBarEh>;
begin
  FieldBarIndex := IndexOf(AFieldBar);
  NewList := TList<TFieldBarEh>.Create(BaseList);
  NewList.Move(FieldBarIndex, NewDisplayIndex);
  FIndexesIsFixed := True;
  ResetList(NewList, False);
  NewList.Free;
end;

procedure TGridDisplayFieldBarsEh.MoveFieldBars(BarList: TEnumerable<TFieldBarEh>; NewDisplayIndex: Integer);
var
  FieldBarIndex: Integer;
  I: Integer;
  FieldBar: TFieldBarEh;
  BarArr: TArray<TFieldBarEh>;
  NewList: TList<TFieldBarEh>;
begin
  BarArr := BarList.ToArray;
  NewList := TList<TFieldBarEh>.Create(BaseList);
  for I := Length(BarArr) - 1 downto 0 do
  begin
    FieldBar := BarArr[I];
    FieldBarIndex := IndexOf(FieldBar);
    NewList.Move(FieldBarIndex, NewDisplayIndex);
  end;
  FIndexesIsFixed := True;
  ResetList(NewList, False);
  NewList.Free;
end;

procedure TGridDisplayFieldBarsEh.ResetList(NewList: TList<TFieldBarEh>; ForceReset: Boolean);
var
  Grid: TCustomDataAxisGridEhCrack;
  I: Integer;
  ListChanged: Boolean;
begin
  Grid := TCustomDataAxisGridEhCrack(FGrid);

  ReorderList(NewList);

  ListChanged := False;
  if ForceReset then
  begin
    ListChanged := True;
  end
  else
  if NewList.Count <> BaseList.Count then
  begin
    ListChanged := True;
  end
  else
  begin
    for I := 0 to NewList.Count - 1 do
    begin
      if NewList[I] <> BaseList[I] then
      begin
        ListChanged := True;
        Break;
      end;
    end;
  end;

  if ListChanged = True then
  begin
    BaseList.Clear;
    BaseList.AddRange(NewList);

    ResetIndexes;
    Grid.DisplayFieldBarListChanged;
    Grid.VisibleFieldBars.ResetIndexes;
  end;

  Grid.LayoutChanged;
end;

procedure TGridDisplayFieldBarsEh.ReorderList(NewOrderList: TList<TFieldBarEh>);
begin
end;

procedure TGridDisplayFieldBarsEh.ResetIndexes;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Items[I].FDisplayIndex := -1;
  end;
end;

function TGridDisplayFieldBarsEh.CompareFieldBarOrder(const ALeft, ARight: TFieldBarEh): Integer;
begin
  Result := ALeft.DisplayIndex - ARight.DisplayIndex;
end;

procedure TGridDisplayFieldBarsEh.UpdateDisplayOrderFromDisplayIndex;
var
  I: Integer;
  Grid: TCustomDataAxisGridEhCrack;
begin
  Grid := TCustomDataAxisGridEhCrack(FGrid);

  BaseList.Sort(TComparer<TFieldBarEh>.Construct(
    function(const ALeft, ARight: TFieldBarEh): Integer
    begin
      Result := CompareFieldBarOrder(ALeft, ARight);
    end
  ));

  for I := 0 to Count - 1 do
  begin
    Items[I].FDisplayIndex := -1;
  end;

  Grid.DisplayFieldBarListChanged;
end;

procedure TGridDisplayFieldBarsEh.SetFieldBarsOrder(AOrderedList: TList<TFieldBarEh>);
var
  I: Integer;
  ColIndex: Integer;
  Grid: TCustomDataAxisGridEhCrack;
begin
  if (Count <> AOrderedList.Count) then
    raise Exception.Create('TDataGridDisplayColumnsEh.SetDisplayOrder: AOrderedList.Count <> SelfList.Count');

  Grid := TCustomDataAxisGridEhCrack(FGrid);
  Grid.FieldBars.BeginUpdate;
  for I := 0 to AOrderedList.Count - 1 do
  begin
    ColIndex := IndexOf(AOrderedList[I]);
    if ColIndex < 0 then
      raise Exception.Create('TDataGridDisplayColumnsEh.SetDisplayOrder: ColIndex ' + IntToStr(I) + ' is not found');
    Items[ColIndex].DisplayIndex := I;
  end;
  Grid.FieldBars.EndUpdate;
end;
{$ENDREGION TGridDisplayFieldBarsEh}

{$REGION 'TGridVisibleFieldBarsEh'}

constructor TGridVisibleFieldBarsEh.Create(AGrid: TControl;
  AList: TList<TFieldBarEh>);
begin
  inherited Create(AGrid, AList);
end;

destructor TGridVisibleFieldBarsEh.Destroy;
begin
  inherited Destroy;
end;

procedure TGridVisibleFieldBarsEh.MoveFieldBar(AFieldBar: TFieldBarEh; NewVisibleIndex: Integer);
var
  DisplayIndex: Integer;
  Grid: TCustomDataAxisGridEhCrack;
begin
  Grid := TCustomDataAxisGridEhCrack(FGrid);
  DisplayIndex := Items[NewVisibleIndex].DisplayIndex;
  Grid.DisplayFieldBars.MoveFieldBar(AFieldBar, DisplayIndex);
end;

procedure TGridVisibleFieldBarsEh.MoveFieldBars(BarList: TEnumerable<TFieldBarEh>;
  NewVisibleIndex: Integer);
var
  DisplayIndex: Integer;
  Grid: TCustomDataAxisGridEhCrack;
begin
  Grid := TCustomDataAxisGridEhCrack(FGrid);
  DisplayIndex := Items[NewVisibleIndex].DisplayIndex;
  Grid.DisplayFieldBars.MoveFieldBars(BarList, DisplayIndex);
end;

procedure TGridVisibleFieldBarsEh.ResetIndexes;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Items[I].FVisibleIndex := -1;
  end;
end;
{$ENDREGION TGridVisibleFieldBarsEh}

{$REGION 'TGridDynamicFieldBarsEh'}

constructor TGridDynamicFieldBarsEh.Create(AGrid: TControl;
  AList: TList<TFieldBarEh>);
begin
  inherited Create(AGrid, AList);
end;

destructor TGridDynamicFieldBarsEh.Destroy;
begin
  inherited Destroy;
end;

function TGridDynamicFieldBarsEh.GetColumnClassByField(AField: TTableFieldLinkEh): TFieldBarEhClass;
var
  Grid: TCustomDataAxisGridEhCrack;
begin
  Grid := TCustomDataAxisGridEhCrack(FGrid);
  Result := Grid.GetDynaFieldBarClassByField(AField);
end;

procedure TGridDynamicFieldBarsEh.GetFieldList(AList: TList<TTableFieldLinkEh>);
var
  Grid: TCustomDataAxisGridEhCrack;
  I: Integer;
  Fields: TTableFieldLinkListEh;
begin
  Grid := TCustomDataAxisGridEhCrack(FGrid);
  if Grid.TableView.Fields = nil then Exit;

  if (Grid.TableView.Fields.Count > 0) then
  begin
    Fields := Grid.TableView.Fields;
    for I := 0 to Fields.Count - 1 do
    begin
      AList.Add(Fields[I]);
    end;
  end;
end;
{$ENDREGION TGridDynamicFieldBarsEh}

{$REGION 'TDataAxisGridSetBarValueParamsEh'}

constructor TDataAxisGridSetBarValueParamsEh.Create;
begin
end;

procedure TDataAxisGridSetBarValueParamsEh.DefaultSetValue;
begin
  FFieldBar.DefaultSetValue(Value);
end;

procedure TDataAxisGridSetBarValueParamsEh.Init(AGrid: TControl; AFieldBar: TFieldBarEh; AListItemBar: TTableRowViewEh; const AValue: TValue);
begin
  FGrid := AGrid;
  FFieldBar := AFieldBar;
  FListItemBar := AListItemBar;
  FValue := AValue;
end;
{$ENDREGION TDataAxisGridSetBarValueParamsEh}

{$REGION 'TDataAxisGridGetBarValueParamsEh'}

constructor TDataAxisGridGetBarValueParamsEh.Create;
begin
end;

procedure TDataAxisGridGetBarValueParamsEh.Init(AGrid: TControl; AFieldBar: TFieldBarEh; AListItemBar: TTableRowViewEh);
begin
  FGrid := AGrid;
  FFieldBar := AFieldBar;
  FListItemBar := AListItemBar;
end;

procedure TDataAxisGridGetBarValueParamsEh.ProcessDefaultGetValue;
begin
  Value := FieldBar.DefaultGetListItemValue(ListItemBar);
end;

{$ENDREGION TDataAxisGridGetBarValueParamsEh}

{$REGION 'TDataAxisGridGetDisplayTextParamsEh'}

constructor TDataAxisGridGetDisplayTextParamsEh.Create;
begin
end;

procedure TDataAxisGridGetDisplayTextParamsEh.Init(AGrid: TControl; AFieldBar: TFieldBarEh; ACellManager: TBaseGridCellManagerEh; const AValue: TValue);
begin
  FGrid := AGrid;
  FFieldBar := AFieldBar;
  FValue := AValue;
  FCellManager := ACellManager;
end;

function TDataAxisGridGetDisplayTextParamsEh.GetDefaultDisplayText: String;
begin
  if FieldBar <> nil then
    Result := FieldBar.DefaultGetDisplayText(Value, CellManager)
  else
    Result := '';
end;
{$ENDREGION TDataAxisGridGetDisplayTextParamsEh}

{$REGION 'TDataAxisCellStyleParamsEh'}

constructor TDataAxisCellStyleParamsEh.Create;
begin
  inherited Create;
  FPadding := TBounds.Create(TRectF.Empty);
  FFont := TFont.Create;
  FFill := TBrush.Create(TBrushKind.None, TAlphaColorRec.Null);
end;

destructor TDataAxisCellStyleParamsEh.Destroy;
begin
  FreeAndNil(FPadding);
  FreeAndNil(FFont);
  FreeAndNil(FFill);
  inherited Destroy;
end;

procedure TDataAxisCellStyleParamsEh.Init(AGrid: TControl; AFieldBar: TFieldBarEh;
  AListItemBar: TTableRowViewEh; ADataRowIndex: Integer);
begin
  FGrid := AGrid;
  FFieldBar := AFieldBar;
  FListItemBar := AListItemBar;
  FDataRowIndex := ADataRowIndex;
end;

procedure TDataAxisCellStyleParamsEh.SetFill(const Value: TBrush);
begin
  FFill.Assign(Value);
end;

procedure TDataAxisCellStyleParamsEh.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TDataAxisCellStyleParamsEh.SetPadding(const Value: TBounds);
begin
  FPadding.Assign(Value);
end;
{$ENDREGION TDataAxisGridDataCellStyleParamsEh}

{$REGION 'TFieldBarDataCellStyleParamsEh'}

constructor TFieldBarDataCellStyleParamsEh.Create;
begin
  inherited Create;
end;

destructor TFieldBarDataCellStyleParamsEh.Destroy;
begin
  inherited Destroy;
end;

procedure TFieldBarDataCellStyleParamsEh.Init(ADataAxisCellParams: TDataAxisCellStyleParamsEh);
begin
  FDataAxisCellParams := ADataAxisCellParams;
end;

function TFieldBarDataCellStyleParamsEh.GetDataRowIndex: Integer;
begin
  Result := FDataAxisCellParams.DataRowIndex;
end;

function TFieldBarDataCellStyleParamsEh.GetFill: TBrush;
begin
  Result := DataAxisCellParams.Fill;
end;

procedure TFieldBarDataCellStyleParamsEh.SetFill(const Value: TBrush);
begin
  DataAxisCellParams.Fill := Value;
end;

function TFieldBarDataCellStyleParamsEh.GetFont: TFont;
begin
  Result := DataAxisCellParams.Font;
end;

procedure TFieldBarDataCellStyleParamsEh.SetFont(const Value: TFont);
begin
  DataAxisCellParams.Font := Font;
end;

function TFieldBarDataCellStyleParamsEh.GetFontColor: TAlphaColor;
begin
  Result := DataAxisCellParams.FontColor;
end;

procedure TFieldBarDataCellStyleParamsEh.SetFontColor(const Value: TAlphaColor);
begin
  DataAxisCellParams.FontColor := Value;
end;

function TFieldBarDataCellStyleParamsEh.GetGrid: TControl;
begin
  Result := FDataAxisCellParams.Grid;
end;

function TFieldBarDataCellStyleParamsEh.GetHorzAlign: TTextAlign;
begin
  Result := FDataAxisCellParams.HorzAlign;
end;

procedure TFieldBarDataCellStyleParamsEh.SetHorzAlign(const Value: TTextAlign);
begin
  DataAxisCellParams.HorzAlign := Value;
end;

function TFieldBarDataCellStyleParamsEh.GetPadding: TBounds;
begin
  Result := DataAxisCellParams.Padding;
end;

procedure TFieldBarDataCellStyleParamsEh.SetPadding(const Value: TBounds);
begin
  DataAxisCellParams.Padding := Value;
end;

function TFieldBarDataCellStyleParamsEh.GetVertAlign: TTextAlign;
begin
  Result := DataAxisCellParams.VertAlign;
end;

procedure TFieldBarDataCellStyleParamsEh.SetVertAlign(const Value: TTextAlign);
begin
  DataAxisCellParams.VertAlign := Value;
end;

{$ENDREGION 'TFieldBarDataCellStyleParamsEh'}

{$REGION 'TDataAxisGridTitleInitCellContentParamsEh'}

function TDataAxisGridTitleInitCellContentParamsEh.GetFieldBarTitle: TFieldBarTitleEh;
begin
  raise Exception.Create('TDataAxisGridTitleInitCellContentParamsEh.GetFieldBarTitle is not implemented');
end;

procedure TDataAxisGridTitleInitCellContentParamsEh.Init(ACell: TGridBaseCellEh;
  ACellContent: TLaObjectEh; InitCellParams: TBaseGridInitCellParamsEh);
begin
  inherited Init(ACell, ACellContent, InitCellParams);
end;

{$ENDREGION 'TDataAxisGridTitleInitCellContentParamsEh'}

{$REGION 'TDataAxisCellCanModifyParamsEh'}

constructor TDataAxisCellCanModifyParamsEh.Create;
begin
end;

function TDataAxisCellCanModifyParamsEh.DefaultCanModify: Boolean;
begin
  Result := FieldBar.DefaultCanModifyCellValue(ListItemBar);
end;

procedure TDataAxisCellCanModifyParamsEh.Init(AGrid: TControl;
  AFieldBar: TFieldBarEh; AListItemBar: TTableRowViewEh);
begin
  FGrid := AGrid;
  FFieldBar := AFieldBar;
  FListItemBar := AListItemBar;
  FHandled := False;
  FCanModify := False;
end;

{$ENDREGION 'TDataAxisCellCanModifyParamsEh'}

{$REGION 'TDataAxisCellInTextLinkClickParamsEh'}

procedure TDataAxisCellInTextLinkClickParamsEh.Init(AGrid: TControl; ACell: TGridBaseCellEh; ASourceParams: TInTextLinkClickParamsEh);
begin
  FGrid := AGrid;
  FCell := ACell;
  FSourceParams := ASourceParams;
  if ACell is TDataAxisCellEh then
  begin
    FFieldBar := TDataAxisCellEh(ACell).FieldBar;
    FListItemBar := TDataAxisCellEh(ACell).ListItemBar;
  end;
end;

function TDataAxisCellInTextLinkClickParamsEh.GetHandled: Boolean;
begin
  Result := SourceParams.Handled;
end;

procedure TDataAxisCellInTextLinkClickParamsEh.SetHandled(const Value: Boolean);
begin
  SourceParams.Handled := Value;
end;

{$ENDREGION 'TDataAxisCellInTextLinkClickParamsEh'}

end.
