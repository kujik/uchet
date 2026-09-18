{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{            EhLibFmx.DataGrid.SearchPanels             }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DataGrid.SearchPanels;

{$SCOPEDENUMS ON}

interface

{$REGION 'uses'}
uses
  System.UITypes, SysUtils, Classes,
  Variants, Types,
  Data.DB,
  FMX.Types,
  FMX.StdCtrls,
  FMX.Controls,
  FMX.Menus,
  FMX.Edit,
  EhLibUtils,
  DBUtilsEh,
  EhLibFmx.Platform,
  EhLibFmx.ToolControls,
  EhLibFmx.Grids,
  EhLibFmx.Types,

  EhLibFmx.DataGrid.Columns,
  EhLibFmx.DataGrid.Rows,

  EhLibFmx.SearchPanels
  ;
{$ENDREGION 'uses'}

type

{ TGridSearchPanelCheckColumnValueAcceptParamsEh }

  TDataGridSearchPanelCheckColumnValueAcceptParamsEh = class(TPersistent)
  private
    FColumn: TDataGridBaseColumnEh;
    FAccept: Boolean;
    FRow: TDataGridRowEh;
    FSearchText: String;
    FGrid: TComponent;
  protected

  public
    constructor Create;

    procedure Reset(AGrid: TComponent; AColumn: TDataGridBaseColumnEh; ADataRow: TDataGridRowEh; ASearchText: String); virtual;
    procedure DefaultCheckColumnValueAccept(); virtual;

    property Grid: TComponent read FGrid;
    property Column: TDataGridBaseColumnEh read FColumn;
    property Row: TDataGridRowEh read FRow;
    property SearchText: String read FSearchText;
    property Accept: Boolean read FAccept write FAccept;
  end;

  TGridSearchPanelCheckColumnValueAcceptEventEh = procedure (Sender: TObject; Params: TDataGridSearchPanelCheckColumnValueAcceptParamsEh) of object;

{ TDataGridSearchPanelEh }

  TDataGridSearchPanelOptionMenuItemEh = (SearchScopes, CaseSensitive, WholeWords, BeginsWith);
  TDataGridSearchPanelOptionsMenuItemsEh = set of TDataGridSearchPanelOptionMenuItemEh;

  TDataGridSearchPanelScopeEh = (CurrentColumn, EntireGrid);

  TDataGridSearchPanelEh = class(TComponent)
  private
    FActive: Boolean;
    FCaseSensitive: Boolean;
    FCellBeginsWithMode: Boolean;
    FEnabled: Boolean;
    FDataSetFilterEventNeeded: Boolean;
    FFilterEnabled: Boolean;
    FFilterOnTyping: Boolean;
    FGrid: TCustomGridEh;
    FLocation: TSearchPanelLocationEh;
    FOptionsPopupMenuItems: TDataGridSearchPanelOptionsMenuItemsEh;
    FPersistentShowing: Boolean;
    FPreferSearchToEdit: Boolean;
    FSearchingColumnIndex: Integer;
    FSearchingText: String;
    FSearchScope: TDataGridSearchPanelScopeEh;
    FShortCut: TShortCut;
    FVisible: Boolean;
    FWholeWords: Boolean;
    FFilteringText: String;

    FOnCheckCellHitSearch: TGridSearchPanelCheckColumnValueAcceptEventEh;

    function GetActive: Boolean;

    procedure SetCaseSensitive(const Value: Boolean);
    procedure SetEnabled(const Value: Boolean);
    procedure SetFilterEnabled(const Value: Boolean);
    procedure SetFoundColumnIndex(const Value: Integer);
    procedure SetLocation(const Value: TSearchPanelLocationEh);
    procedure SetPersistentShowing(const Value: Boolean);
    procedure SetSearchingText(const Value: String);
    procedure SetSearchScope(const Value: TDataGridSearchPanelScopeEh);
    procedure SetCellBeginsWithMode(const Value: Boolean);
    procedure SetVisible(const Value: Boolean);
    procedure SetWholeWords(const Value: Boolean);
    function GetSearchingColumnIndex: Integer;
    function GetFilterActive: Boolean;

  protected
    FFoundColumnIndex: Integer;

    function InternalGetActive: Boolean;
    function NormalHighlightBackColor: TAlphaColor; virtual;
    function CurrentFoundItemBackColor: TAlphaColor; virtual;
    function GetCellTextForSearchPanel(Column: TDataGridBaseColumnEh; ADataRow: TDataGridRowEh): String; virtual;

    procedure SetActive(const Value: Boolean);
    procedure InternalSetActive(const Value: Boolean);
    procedure InterSetSearchingText(const Value: String);
    procedure SetOptionsPopupMenuItems(const Value: TDataGridSearchPanelOptionsMenuItemsEh);
    procedure CheckCellHitSearchPanelData(AColumn: TDataGridBaseColumnEh; ARow: TDataGridRowEh; var Accept: Boolean; SearchText: String);
    procedure DefaultCheckCellHitSearchPanelData(AColumn: TDataGridBaseColumnEh; ARow: TDataGridRowEh; var Accept: Boolean; SearchText: String); virtual;
  public
    constructor Create(AGrid: TCustomGridEh); reintroduce;
    destructor Destroy; override;

    function InGridVertCaptureSize: Integer;
    function IsShortCutStored: Boolean; virtual;
    function TryFindText(Text: String): Boolean; virtual;
    function IsRowMatchFilter(ADataRow: TDataGridRowEh): Boolean; virtual;

    procedure FindNext;
    procedure FindPrev;
    procedure RestartFind(TimeOut: LongWord = 0);
    procedure ApplySearchFilter;
    procedure CancelSearchFilter;
    procedure CancelSearchPanelMode;
    procedure CheckCellHitSearchPanelText(Text: String; var Accept: Boolean; SearchText: String);

    property Active: Boolean read GetActive write SetActive default False;
    property DataSetFilterEventNeeded: Boolean read FDataSetFilterEventNeeded;
    property Visible: Boolean read FVisible write SetVisible default False;
    property SearchingText: String read FSearchingText write SetSearchingText;
    property FoundColumnIndex: Integer read FFoundColumnIndex write SetFoundColumnIndex;
    property Grid: TCustomGridEh read FGrid;
    property SearchingColumnIndex: Integer read GetSearchingColumnIndex;
    property FilterActive: Boolean read GetFilterActive;

  published
    property CaseSensitive: Boolean read FCaseSensitive write SetCaseSensitive default False;
    property CellBeginsWithMode: Boolean read FCellBeginsWithMode write SetCellBeginsWithMode default False;
    property Enabled: Boolean read FEnabled write SetEnabled default False;
    property FilterEnabled: Boolean read FFilterEnabled write SetFilterEnabled default True;
    property FilterOnTyping: Boolean read FFilterOnTyping write FFilterOnTyping default False;
    property Location: TSearchPanelLocationEh read FLocation write SetLocation default TSearchPanelLocationEh.GridTop;
    property OptionsPopupMenuItems: TDataGridSearchPanelOptionsMenuItemsEh read FOptionsPopupMenuItems write SetOptionsPopupMenuItems default [TDataGridSearchPanelOptionMenuItemEh.SearchScopes, TDataGridSearchPanelOptionMenuItemEh.CaseSensitive, TDataGridSearchPanelOptionMenuItemEh.WholeWords, TDataGridSearchPanelOptionMenuItemEh.BeginsWith];
    property PersistentShowing: Boolean read FPersistentShowing write SetPersistentShowing default True;
    property PreferSearchToEdit: Boolean read FPreferSearchToEdit write FPreferSearchToEdit default False;
    property SearchScope: TDataGridSearchPanelScopeEh read FSearchScope write SetSearchScope default TDataGridSearchPanelScopeEh.EntireGrid;
    property ShortCut: TShortCut read FShortCut write FShortCut stored IsShortCutStored;
    property WholeWords: Boolean read FWholeWords write SetWholeWords default False;

    property OnCheckCellHitSearch: TGridSearchPanelCheckColumnValueAcceptEventEh read FOnCheckCellHitSearch write FOnCheckCellHitSearch;
  end;

{ TDataGridSearchPanelTextEditEh }

  TDataGridSearchPanelTextEditEh = class(TSearchPanelTextEditEh)
  end;

{ TDataGridSearchPanelControlEh }

  TDataGridSearchPanelControlEh = class(TSearchPanelControlEh)
  private
    FoundCells: Integer;
    FSearchResultThread: TThread;
    FSearchResultFinished: Boolean;
  protected
    function CalcSearchInfoBoxWidth: Integer; override;
    function CancelSearchFilterEnable: Boolean; override;
    function CreateSearchPanelTextEdit: TSearchPanelTextEditEh; override;
    function GetMasterControlSearchEditMode: Boolean; override;
    function GetSearchInfoBoxText: String; override;
    function IsOptionsButtonVisible: Boolean; override;
    function MasterControlFilterEnabled: Boolean; override;

    procedure AcquireMasterControlFocus; override;
    procedure BuildOptionsPopupMenu(var PopupMenu: TPopupMenu); override;
    procedure MasterControlApplySearchFilter; override;
    procedure MasterControlCancelSearchEditorMode; override;
    procedure MasterControlFindNext; override;
    procedure MasterControlFindPrev; override;
    procedure MasterControlProcessFindEditorKeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MasterControlProcessFindEditorKeyPress(var Key: Char); override;
    procedure MasterControlProcessFindEditorKeyUp(var Key: Word; Shift: TShiftState); override;
    procedure MasterControlRestartFind; override;

    procedure MenuSearchScopesClick(Sender: TObject); virtual;
    procedure SearchResultThreadDone(Sender: TObject); virtual;
    procedure SearchResultThreadUpdateHitCount(Sender: TObject); virtual;
    procedure SetGetMasterControlSearchEditMode(Value: Boolean); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function CanPerformSearchActionInMasterControl: Boolean; override;
    function FilterEnabled: Boolean; override;
    function FilterOnTyping: Boolean; override;
    function GetBorderColor: TAlphaColor; override;
    function GetFindEditorBorderColor: TAlphaColor; override;
    function GetHitCountAt(ARowIndex, AColIndex: Integer): Integer; virtual;

    procedure ClearSearchFilter; override;
    procedure FindEditorUserChanged; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Single); override;
    procedure UpdateFoundInfo;
    procedure UpdateFoundInfoInThread;
    procedure UpdateFoundInfoNoThread;

    procedure GetPaintColors(var FromColor, ToColor, HighlightColor: TAlphaColor); override;
  end;

implementation

{$REGION 'uses'}
uses System.StrUtils,
     EhLibFmx.CustomDataGrids;
{$ENDREGION 'uses'}

type
  TCustomDataGridEhCrack = class(TCustomDataGridEh);
  TDataGridSearchPanelTextEditEhCrack = class(TDataGridSearchPanelTextEditEh);
  TDataGridSearchPanelEhCrack = class(TDataGridSearchPanelEh);

{$REGION 'TDataGridSearchPanelEh'}

{ TDataGridSearchPanelEh }

constructor TDataGridSearchPanelEh.Create(AGrid: TCustomGridEh);
begin
  inherited Create(AGrid);
  SetSubComponent(True);
  FGrid := AGrid;
  FPersistentShowing := True;
  FFilterEnabled := True;
  FOptionsPopupMenuItems := [TDataGridSearchPanelOptionMenuItemEh.SearchScopes,
                             TDataGridSearchPanelOptionMenuItemEh.CaseSensitive,
                             TDataGridSearchPanelOptionMenuItemEh.WholeWords,
                             TDataGridSearchPanelOptionMenuItemEh.BeginsWith];
  FSearchScope := TDataGridSearchPanelScopeEh.EntireGrid;
  FCaseSensitive := False;
  FWholeWords := False;
  FSearchingColumnIndex := -1;
end;

destructor TDataGridSearchPanelEh.Destroy;
begin
  inherited Destroy;
end;

function TDataGridSearchPanelEh.TryFindText(Text: String): Boolean;
var
  TextMatching: TLocateTextMatchingEh;
  Options: TLocateTextOptionsEh;
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if Text = '' then
    TextMatching := TLocateTextMatchingEh.ltmWholeEh
  else if CellBeginsWithMode then
    TextMatching := TLocateTextMatchingEh.ltmFromBeginningEh
  else
    TextMatching := TLocateTextMatchingEh.ltmAnyPartEh;
  Options := [TLocateTextOptionEh.ltoCaseInsensitiveEh,
              TLocateTextOptionEh.ltoIgnoreCurrentPosEh, {ltoInsideSelection, }
              TLocateTextOptionEh.ltoRestartAfterLastHitEh,
              TLocateTextOptionEh.ltoStopOnEscapeEh,
              TLocateTextOptionEh.ltoStopKeyMessageEh];
  if SearchScope = TDataGridSearchPanelScopeEh.EntireGrid then
    Options := Options + [TLocateTextOptionEh.ltoAllFieldsEh];
  if WholeWords = True then
    Options := Options + [TLocateTextOptionEh.ltoWholeWordsEh];

  Result := Grid.LocateText(Grid, '', Text, Options, ltdAllEh, TextMatching,
    lttInAllNodesEh, 0, Grid.CheckCellHitSearchPanelData);
end;

procedure TDataGridSearchPanelEh.FindNext;
var
  TextMatching: TLocateTextMatchingEh;
  Options: TLocateTextOptionsEh;
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if SearchingText = ''
    then TextMatching := ltmWholeEh
    else TextMatching := ltmAnyPartEh;
  Options := [ltoCaseInsensitiveEh, ltoIgnoreCurrentPosEh, {ltoInsideSelection, }
    ltoRestartAfterLastHitEh, ltoStopOnEscapeEh, ltoStopKeyMessageEh];
  if SearchScope = TDataGridSearchPanelScopeEh.EntireGrid then
    Options := Options + [ltoAllFieldsEh];
  if WholeWords = True then
    Options := Options + [ltoWholeWordsEh];
  Grid.LocateText(Grid, '', SearchingText, Options, ltdDownEh, TextMatching,
    lttInAllNodesEh, 0, Grid.CheckCellHitSearchPanelData);
end;

procedure TDataGridSearchPanelEh.FindPrev;
var
  TextMatching: TLocateTextMatchingEh;
  Options: TLocateTextOptionsEh;
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if SearchingText = ''
    then TextMatching := ltmWholeEh
    else TextMatching := ltmAnyPartEh;
  Options := [ltoCaseInsensitiveEh, ltoIgnoreCurrentPosEh, {ltoInsideSelection, }
    ltoRestartAfterLastHitEh, ltoStopOnEscapeEh, ltoStopKeyMessageEh];
  if SearchScope = TDataGridSearchPanelScopeEh.EntireGrid then
    Options := Options + [ltoAllFieldsEh];
  Grid.LocateText(Grid, '', SearchingText, Options, ltdUpEh, TextMatching,
    lttInAllNodesEh, 0, Grid.CheckCellHitSearchPanelData);
end;

procedure TDataGridSearchPanelEh.RestartFind(TimeOut: LongWord = 0);
var
  TextMatching: TLocateTextMatchingEh;
  Options: TLocateTextOptionsEh;
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if SearchingText = '' then
    TextMatching := ltmWholeEh
  else
  begin
    TextMatching := ltmAnyPartEh;

  end;
  Options := [ltoCaseInsensitiveEh, ltoIgnoreCurrentPosEh, {ltoInsideSelection, }
    ltoRestartAfterLastHitEh, ltoStopOnEscapeEh, ltoStopKeyMessageEh];
  if SearchScope = TDataGridSearchPanelScopeEh.EntireGrid then
    Options := Options + [ltoAllFieldsEh];
  Grid.LocateText(Grid, '', SearchingText, Options, ltdAllEh, TextMatching,
    lttInAllNodesEh, TimeOut, Grid.CheckCellHitSearchPanelData);
end;

function TDataGridSearchPanelEh.InGridVertCaptureSize: Integer;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if Visible and (Location = TSearchPanelLocationEh.GridTop)
    then Result := Round(Grid.SearchPanelControl.Height)
    else Result := 0;
end;

function TDataGridSearchPanelEh.GetActive: Boolean;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if Location = TSearchPanelLocationEh.TheExternal then
    Result := FActive
  else
    Result := Grid.SearchPanelMode;
end;

procedure TDataGridSearchPanelEh.SetSearchScope(const Value: TDataGridSearchPanelScopeEh);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if FSearchScope <> Value then
  begin
    FSearchScope := Value;
    Grid.Invalidate;
  end;
end;

procedure TDataGridSearchPanelEh.SetActive(const Value: Boolean);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if Location = TSearchPanelLocationEh.TheExternal then
    InternalSetActive(Value)
  else
    Grid.SearchPanelMode := Value;
end;

function TDataGridSearchPanelEh.InternalGetActive: Boolean;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if (Location = TSearchPanelLocationEh.TheExternal) or (Location = TSearchPanelLocationEh.CellInplace) then
    Result := FActive
  else if Grid.SearchPanelControl.FindEditor.Visible then
    Result := Grid.SearchPanelControl.FindEditor.IsFocused
  else
    Result := False;
end;

procedure TDataGridSearchPanelEh.InternalSetActive(const Value: Boolean);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if Value and not InternalGetActive then
  begin
    if Location <> TSearchPanelLocationEh.TheExternal then
    begin
      if not Visible then
        Visible := True;
      if {Grid.SearchPanelControl.Showing and}
         Grid.SearchPanelControl.Visible then
      begin
        Grid.SearchPanelControl.FindEditor.SetFocus;
      end;
      if Location = TSearchPanelLocationEh.CellInplace then
        Grid.UpdateEditorMode;
    end;
    FActive := True;
    Grid.Invalidate;
  end else if not Value and InternalGetActive then
  begin
    if Location <> TSearchPanelLocationEh.TheExternal then
    begin
      if Grid.IsCanvasEnabled then
        Grid.SetFocus;
      if not PersistentShowing and (SearchingText = '') then
        Visible := False;
      if Location = TSearchPanelLocationEh.CellInplace then
        Grid.UpdateEditorMode;
    end;
    FActive := False;
    Grid.Invalidate;
  end;
end;

procedure TDataGridSearchPanelEh.SetEnabled(const Value: Boolean);
begin
  if FEnabled <> Value then
  begin
    FEnabled := Value;
    if (PersistentShowing or (SearchingText <> '')) and Enabled then
      Visible := True
    else
      Visible := False;
  end;
end;

procedure TDataGridSearchPanelEh.SetLocation(const Value: TSearchPanelLocationEh);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if FLocation <> Value then
  begin
    FLocation := Value;
    Grid.UpdateSearchPanel;
  end;
end;

procedure TDataGridSearchPanelEh.SetPersistentShowing(const Value: Boolean);
begin
  if FPersistentShowing <> Value then
  begin
    FPersistentShowing := Value;
    if (FPersistentShowing or (SearchingText <> '')) and Enabled then
      Visible := True
    else if not FPersistentShowing and not Active then
      Visible := False;
  end;
end;

procedure TDataGridSearchPanelEh.SetSearchingText(const Value: String);
var
  FindEdit: TDataGridSearchPanelTextEditEhCrack;
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if FSearchingText <> Value then
  begin
    FSearchingText := Value;
    if Location <> TSearchPanelLocationEh.TheExternal then
    begin
      FindEdit := TDataGridSearchPanelTextEditEhCrack(Grid.SearchPanelControl.FindEditor);
      FindEdit.Text := Value;
      if Value = ''
        then FindEdit.IsEmptyState := True
        else FindEdit.IsEmptyState := False;
    end;

    if PersistentShowing or (SearchingText <> '') then
      Visible := True;

    if (SearchingText = '') then
      FSearchingColumnIndex := -1
    else if (SearchingText <> '') and
            (SearchScope = TDataGridSearchPanelScopeEh.CurrentColumn) and
            (FSearchingColumnIndex = -1)
    then
      FSearchingColumnIndex := Grid.CurrentColIndex;

    Grid.Invalidate();
    Grid.UpdateHighlightingTexts();
  end;
end;

procedure TDataGridSearchPanelEh.InterSetSearchingText(const Value: String);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  FSearchingText := Value;
  if (FSearchingText = '') then
    FSearchingColumnIndex := -1;
  Grid.UpdateHighlightingTexts();
end;

function TDataGridSearchPanelEh.IsShortCutStored: Boolean;
begin
  Result := False;
end;

procedure TDataGridSearchPanelEh.SetVisible(const Value: Boolean);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if FVisible <> Value then
  begin
    FVisible := Value;
    Grid.UpdateSearchPanel;
  end;
end;

procedure TDataGridSearchPanelEh.ApplySearchFilter;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  FFilteringText := SearchingText;
  Grid.RefreshFilteredRows;
end;

procedure TDataGridSearchPanelEh.CancelSearchFilter;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  FFilteringText := '';
  Grid.RefreshFilteredRows;
end;

procedure TDataGridSearchPanelEh.SetFilterEnabled(const Value: Boolean);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if FFilterEnabled <> Value then
  begin
    FFilterEnabled := Value;
    Grid.UpdateSearchPanel;
  end;
end;

procedure TDataGridSearchPanelEh.SetFoundColumnIndex(const Value: Integer);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if FFoundColumnIndex <> Value then
  begin
    if (Grid.SelectionOptions.RowSelect = False) then
      Grid.CurrentColIndex := Value
    else
      Grid.ClampInView(GridCoord(Grid.DataToRawColumn(Value), Grid.CurRowIndex), True, False);
    FFoundColumnIndex := Value;
    Grid.InvalidateRow(Grid.CurRowIndex);
  end;
end;

procedure TDataGridSearchPanelEh.SetOptionsPopupMenuItems(
  const Value: TDataGridSearchPanelOptionsMenuItemsEh);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if Value <> FOptionsPopupMenuItems then
  begin
    FOptionsPopupMenuItems := Value;
    Grid.SearchPanelControl.ResetVisibleControls;
  end;
end;

function TDataGridSearchPanelEh.CurrentFoundItemBackColor: TAlphaColor;
begin
  Result := TAlphaColorRec.Black;
end;

function TDataGridSearchPanelEh.NormalHighlightBackColor: TAlphaColor;
begin
  Result := TAlphaColorRec.Black;
end;

procedure TDataGridSearchPanelEh.SetCaseSensitive(const Value: Boolean);
begin
  if FCaseSensitive <> Value then
  begin
    FCaseSensitive := Value;
    Grid.Invalidate;
  end;
end;

procedure TDataGridSearchPanelEh.SetWholeWords(const Value: Boolean);
begin
  if FWholeWords <> Value then
  begin
    FWholeWords := Value;
    Grid.Invalidate;
  end;
end;

procedure TDataGridSearchPanelEh.SetCellBeginsWithMode(const Value: Boolean);
begin
  if FCellBeginsWithMode <> Value then
  begin
    FCellBeginsWithMode := Value;
    Grid.Invalidate;
  end;
end;

procedure TDataGridSearchPanelEh.CancelSearchPanelMode;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  Grid.SearchPanelControl.CancelSearchEditorMode;
end;

function TDataGridSearchPanelEh.GetSearchingColumnIndex: Integer;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(FGrid);
  if (FSearchingColumnIndex = -1) then
    Result := Grid.CurrentColIndex
  else
    Result := FSearchingColumnIndex;
end;

function TDataGridSearchPanelEh.GetFilterActive: Boolean;
begin
  Result := (FFilteringText <> '') and (Enabled = True);
end;

function TDataGridSearchPanelEh.IsRowMatchFilter(ADataRow: TDataGridRowEh): Boolean;
var
  i: Integer;
  Grid: TCustomDataGridEhCrack;
  Column: TDataGridBaseColumnEh;
begin
  Grid := TCustomDataGridEhCrack(FGrid);

  if (SearchScope = TDataGridSearchPanelScopeEh.CurrentColumn) and
     (SearchingColumnIndex <> -1) then
  begin
    Result := False;
    CheckCellHitSearchPanelData(Grid.VisibleColumns[SearchingColumnIndex], ADataRow, Result, FFilteringText);
  end else
  begin
    for i := 0 to Grid.VisibleColumns.Count - 1 do
    begin
      Column := Grid.VisibleColumns[i];
      Result := False;
      CheckCellHitSearchPanelData(Column, ADataRow, Result, FFilteringText);
      if Result then
        Break;
    end;
  end;
end;

procedure TDataGridSearchPanelEh.CheckCellHitSearchPanelData(AColumn: TDataGridBaseColumnEh; ARow: TDataGridRowEh;
  var Accept: Boolean; SearchText: String);
var
  AcceptParams: TDataGridSearchPanelCheckColumnValueAcceptParamsEh;
begin
  if Assigned(OnCheckCellHitSearch) then
  begin
    AcceptParams := TDataGridSearchPanelCheckColumnValueAcceptParamsEh.Create;
    AcceptParams.Reset(AColumn.Grid, AColumn, ARow, SearchText);
    Accept := AcceptParams.Accept;
  end
  else
  begin
    DefaultCheckCellHitSearchPanelData(AColumn, ARow, Accept, SearchText);
  end;
end;

procedure TDataGridSearchPanelEh.DefaultCheckCellHitSearchPanelData(
  AColumn: TDataGridBaseColumnEh; ARow: TDataGridRowEh; var Accept: Boolean; SearchText: String);
var
  S: String;
begin
  Accept := False;
  if SearchText = '' then
  begin
    Accept := True;
    Exit;
  end;

  S := GetCellTextForSearchPanel(AColumn, ARow);

  CheckCellHitSearchPanelText(S, Accept, SearchText);
end;

function TDataGridSearchPanelEh.GetCellTextForSearchPanel(Column: TDataGridBaseColumnEh; ADataRow: TDataGridRowEh): String;
begin
  Result := Column.GetRowDisplayText(ADataRow);
end;

procedure TDataGridSearchPanelEh.CheckCellHitSearchPanelText(Text: String; var Accept: Boolean; SearchText: String);
var
  S, SubStr: String;
  Pos: Integer;
begin
  Accept := False;
  SubStr := SearchText;
  S := Text;

  if (S = '') and (SubStr <> '') then
    Exit;

  if not CaseSensitive then
  begin
    SubStr := NlsUpperCase(SubStr);
    S := NlsUpperCase(S);
  end;

  if (SubStr = '') and (S = '') then
    Accept := True
  else
  begin
    if WholeWords then
    begin
      if CaseSensitive
        then Pos := StringSearch(SubStr, S, False, True)
        else Pos := RoughStringSearchProcEh(SubStr, S, False, True);
      if Pos > 0 then
        Accept := True;
    end else
    begin
      if CaseSensitive
        then Pos := PosEx(SubStr, S, 1)
        else Pos := RoughStringPosProcEh(SubStr, S, 1);
      if Pos > 0 then
        Accept := True;
    end;
    if CellBeginsWithMode and (Pos <> 1) then
      Accept := False;
  end;
end;

{$ENDREGION 'TDataGridSearchPanelEh'}

{$REGION 'TDataGridSearchPanelControlEh'}

{ TDataGridSearchPanelControlEh }

constructor TDataGridSearchPanelControlEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSearchResultFinished := True;
  FoundCells := -1;
end;

destructor TDataGridSearchPanelControlEh.Destroy;
begin
  FreeAndNil(FSearchResultThread);
  inherited Destroy;
end;

function TDataGridSearchPanelControlEh.CreateSearchPanelTextEdit: TSearchPanelTextEditEh;
begin
  Result := TSearchPanelTextEditEh.Create(Self);
end;

procedure TDataGridSearchPanelControlEh.BuildOptionsPopupMenu(var PopupMenu: TPopupMenu);
var
  Grid: TCustomDataGridEhCrack;
  i: Integer;
begin
  Grid := TCustomDataGridEhCrack(Owner);

  inherited BuildOptionsPopupMenu(PopupMenu);

  for i := PopupMenu.ItemsCount - 1 downto 0 do
    PopupMenu.RemoveObject(i);

  Grid.Center.BuildSearchPanelOptionsPopupMenu(Grid, PopupMenu);
end;

procedure TDataGridSearchPanelControlEh.MenuSearchScopesClick(
  Sender: TObject);
begin
end;

function TDataGridSearchPanelControlEh.CancelSearchFilterEnable: Boolean;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Owner);
  Result := Grid.SearchPanelMode {or (Grid.FFilterObj <> nil)};
end;

function TDataGridSearchPanelControlEh.GetMasterControlSearchEditMode: Boolean;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Owner);
  Result := Grid.SearchPanelMode;
end;

procedure TDataGridSearchPanelControlEh.SetBounds(ALeft, ATop, AWidth, AHeight: Single);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
end;

procedure TDataGridSearchPanelControlEh.SetGetMasterControlSearchEditMode(Value: Boolean);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Owner);
  Grid.SearchPanelMode := Value;
end;

procedure TDataGridSearchPanelControlEh.FindEditorUserChanged;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Owner);
  inherited FindEditorUserChanged;
  TDataGridSearchPanelEhCrack(Grid.SearchPanel).InterSetSearchingText(FindEditor.Text);

  if FindEditor.Text = '' then
  begin
    if FilterEnabled and FilterOnTyping then
      ClearSearchFilter;
    UpdateFoundInfo;
  end else
  begin
    FindEditor.Repaint;
    if FilterEnabled and FilterOnTyping then
      ApplySearchFilter;
    Grid.SearchPanel.RestartFind(0);
    UpdateFoundInfo;
  end;
end;

procedure TDataGridSearchPanelControlEh.UpdateFoundInfo;
begin
  UpdateFoundInfoInThread;
end;

procedure TDataGridSearchPanelControlEh.UpdateFoundInfoNoThread;
begin
end;

procedure TDataGridSearchPanelControlEh.UpdateFoundInfoInThread;
begin
end;

procedure TDataGridSearchPanelControlEh.SearchResultThreadDone(Sender: TObject);
begin
end;

procedure TDataGridSearchPanelControlEh.SearchResultThreadUpdateHitCount(Sender: TObject);
begin
end;

function TDataGridSearchPanelControlEh.GetHitCountAt(ARowIndex, AColIndex: Integer): Integer;
begin
  Result := 0;
end;

procedure TDataGridSearchPanelControlEh.GetPaintColors(var FromColor, ToColor,
  HighlightColor: TAlphaColor);
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Owner);
  Grid.SetPaintColors;
  FromColor := Grid.FInternalColor;
  ToColor := Grid.FInternalFixedColor;
  if FindEditor.IsFocused then
  begin
  end;
end;

procedure TDataGridSearchPanelControlEh.MasterControlCancelSearchEditorMode;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Owner);
  TDataGridSearchPanelEhCrack(Grid.SearchPanel).InterSetSearchingText(FindEditor.Text);
  MasterControlSearchEditMode := False;
  ClearSearchFilter;
end;

function TDataGridSearchPanelControlEh.MasterControlFilterEnabled: Boolean;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Owner);
  Result := Grid.SearchPanel.FilterEnabled;
end;

procedure TDataGridSearchPanelControlEh.MasterControlFindNext;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Owner);
  Grid.SearchPanel.FindNext;
end;

procedure TDataGridSearchPanelControlEh.MasterControlFindPrev;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Owner);
  Grid.SearchPanel.FindPrev;
end;

procedure TDataGridSearchPanelControlEh.MasterControlRestartFind;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Owner);
  Grid.SearchPanel.RestartFind(0);
end;

procedure TDataGridSearchPanelControlEh.MasterControlProcessFindEditorKeyDown(
  var Key: Word; Shift: TShiftState);
begin
end;

procedure TDataGridSearchPanelControlEh.MasterControlProcessFindEditorKeyPress(
  var Key: Char);
begin
end;

procedure TDataGridSearchPanelControlEh.MasterControlProcessFindEditorKeyUp(
  var Key: Word; Shift: TShiftState);
begin
end;

procedure TDataGridSearchPanelControlEh.MasterControlApplySearchFilter;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Owner);
  Grid.SearchPanel.ApplySearchFilter;
end;

procedure TDataGridSearchPanelControlEh.ClearSearchFilter;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Owner);
  Grid.SearchPanel.CancelSearchFilter;
  UpdateFoundInfo;
end;

function TDataGridSearchPanelControlEh.GetBorderColor: TAlphaColor;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Owner);
  Result := Grid.GridLineParams.DarkColor;
end;

function TDataGridSearchPanelControlEh.GetFindEditorBorderColor: TAlphaColor;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Owner);
  Result := Grid.GridLineParams.DarkColor;
end;

procedure TDataGridSearchPanelControlEh.AcquireMasterControlFocus;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Owner);
  Grid.AcquireFocus;
end;

function TDataGridSearchPanelControlEh.CanPerformSearchActionInMasterControl: Boolean;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Owner);
  Result := (Grid.TableView.Active);
end;

function TDataGridSearchPanelControlEh.FilterEnabled: Boolean;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Owner);
  Result := Grid.SearchPanel.FilterEnabled;
end;

function TDataGridSearchPanelControlEh.FilterOnTyping: Boolean;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Owner);
  Result := Grid.SearchPanel.FilterOnTyping;
end;

function TDataGridSearchPanelControlEh.IsOptionsButtonVisible: Boolean;
var
  Grid: TCustomDataGridEhCrack;
begin
  Grid := TCustomDataGridEhCrack(Owner);
  Result := (Grid.SearchPanel.OptionsPopupMenuItems <> []);
end;

function TDataGridSearchPanelControlEh.CalcSearchInfoBoxWidth: Integer;
begin
  Result := 10;
end;

function TDataGridSearchPanelControlEh.GetSearchInfoBoxText: String;
var
  resS: String;
begin
  if FSearchResultFinished then
    resS := IntToStr(FoundCells)
  else
    resS := '(' + IntToStr(FoundCells) + ')';

  if FoundCells = -1 then
    Result := ''
  else
    Result := resS;
end;

{$ENDREGION 'TDataGridSearchPanelControlEh'}

{$REGION 'TGridSearchPanelCheckColumnValueAcceptParamsEh'}

{ TGridSearchPanelCheckColumnValueAcceptParamsEh }

constructor TDataGridSearchPanelCheckColumnValueAcceptParamsEh.Create;
begin
end;

procedure TDataGridSearchPanelCheckColumnValueAcceptParamsEh.DefaultCheckColumnValueAccept();
var
  VAccept: Boolean;
begin
  VAccept := Accept;
  TCustomDataGridEhCrack(FColumn.Grid).SearchPanel.DefaultCheckCellHitSearchPanelData(Column, Row, VAccept, SearchText);
  Accept := VAccept;
end;

procedure TDataGridSearchPanelCheckColumnValueAcceptParamsEh.Reset(AGrid: TComponent;
  AColumn: TDataGridBaseColumnEh; ADataRow: TDataGridRowEh; ASearchText: String);
begin
  FGrid := AGrid;
  FColumn := AColumn;
  FRow := ADataRow;
  FSearchText := ASearchText;
  Accept := False;
end;

{$ENDREGION 'TGridSearchPanelCheckColumnValueAcceptParamsEh'}

end.
