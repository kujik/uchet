{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{                EhLibFmx.SearchPanels                  }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.SearchPanels;

interface

{$SCOPEDENUMS ON}

{$REGION 'uses'}
uses
  System.UITypes, SysUtils, Classes,
  Variants, Types,
  FMX.Types,
  FMX.StdCtrls,
  FMX.Controls,
  FMX.Menus,
  FMX.Edit,
  FMX.Platform,
  FMX.Graphics,

  EhLibUtils,
  EhLibFmx.Platform,
  EhLibFmx.ToolControls,
  EhLibFmx.ImageReses,
  EhLibFmx.Types
  ;
{$ENDREGION 'uses'}

type
  TSearchPanelControlEh = class;

  TDataGridNavigatorFindBtnEh = (SearchInfoBox, CancelSearchFilter, FindNext, FindPrev, Options);
  TDataGridNavigatorFindBtnsEh = set of TDataGridNavigatorFindBtnEh;

  TSearchPanelLocationEh = (GridTop, HorzScrollBarExtraPanel, TheExternal, CellInplace);

{ TNavFindButtonEh }

  TNavFindButtonEh = class(TCustomSpeedButtonEh)
  private
    FIndex: TDataGridNavigatorFindBtnEh;
    FOnPostMouseDown: TMouseEvent;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure Paint; override;

    procedure DrawInfoText;
  public
    property Index: TDataGridNavigatorFindBtnEh read FIndex write FIndex;
    property OnPostMouseDown: TMouseEvent read FOnPostMouseDown write FOnPostMouseDown;
  end;

{ TSearchPanelTextEditEh }

  TSearchPanelTextEditEh = class(TEdit)
  private
    FInternalChanging: Boolean;
    FIsEmptyState: Boolean;
    FMiniHeight: Boolean;
    FOnUpdateModified: TNotifyEvent;
    FTextAppliedAsFilter: Boolean;
    FAutoHeight: Single;

    function GetSearchPanelControl: TSearchPanelControlEh;

    procedure SetIsEmptyState(const Value: Boolean);
    procedure SetTextAppliedAsFilter(const Value: Boolean);

  protected
    function GetDefaultStyleLookupName: string; override;
    procedure ApplyStyle; override;

    function CalcAutoHeight: Integer;
    function GetBorderColor: TAlphaColor; virtual;
    function GetHeightFromStyle: Integer; virtual;

    procedure ChangeTracking(Sender: TObject); virtual;

    procedure CheckAddTextToList;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure DoChangeAction; virtual;
    procedure DrawNonClientBorder; virtual;
    procedure KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure SpecInternalSetText(const AText: String);
    procedure UpdateModified;

    procedure MRUListActiveChanged(Sender: TObject); virtual;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ApplySearchFilter;
    procedure ClearSearchFilter;
    procedure CancelSearchEditorMode;
    procedure CancelFilter;
    procedure CheckAddTextToMRUList; virtual;

    property IsEmptyState: Boolean read FIsEmptyState write SetIsEmptyState;
    property SearchPanelControl: TSearchPanelControlEh read GetSearchPanelControl;
    property MiniHeight: Boolean read FMiniHeight write FMiniHeight;
    property OnUpdateModified: TNotifyEvent read FOnUpdateModified write FOnUpdateModified;
    property TextAppliedAsFilter: Boolean read FTextAppliedAsFilter write SetTextAppliedAsFilter;
  end;

{ TSearchPanelControlEh }

  TSearchPanelControlEh = class(TControl)
  private
    ButtonWidth: Single;
    FFindEditor: TSearchPanelTextEditEh;
    FLocation: TSearchPanelLocationEh;
    MinBtnSize: TPoint;

    function GetFindButtons(FindBtn: TDataGridNavigatorFindBtnEh): TNavFindButtonEh;
    function GetGrid: TControl;

    procedure SetLocation(const Value: TSearchPanelLocationEh);
  protected
    FFindButtons: array[TDataGridNavigatorFindBtnEh] of TNavFindButtonEh;

    function CalcSearchInfoBoxWidth: Integer; virtual;
    function CancelSearchFilterEnable: Boolean; virtual;
    function CreateSearchPanelTextEdit: TSearchPanelTextEditEh; virtual;
    function GetMasterControlSearchEditMode: Boolean; virtual;
    function GetSearchInfoBoxText: String; virtual;
    function IsOptionsButtonVisible: Boolean; virtual;
    function MasterControlFilterEnabled: Boolean; virtual;
    function IsDrawButtonBorder: Boolean; virtual;
    function IsDrawRightBorder: Boolean; virtual;

    procedure AcquireMasterControlFocus; virtual;
    procedure BtnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single); virtual;
    procedure BuildOptionsPopupMenu(var PopupMenu: TPopupMenu); virtual;
    procedure ClickHandler(Sender: TObject); virtual;
    procedure DrawNonClientBorder; virtual;
    procedure FindBtnClick(Index: TDataGridNavigatorFindBtnEh); virtual;
    procedure FindEditorKeyDown(var Key: Word; Shift: TShiftState); virtual;
    procedure FindEditorKeyPress(var Key: Char); virtual;
    procedure FindEditorKeyUp(var Key: Word; Shift: TShiftState); virtual;
    procedure FindEditorUpdateModified(Sender: TObject);
    procedure FindEditorUserChanged; virtual;
    procedure FindNext;
    procedure FindPrev;
    procedure MasterControlApplySearchFilter; virtual;
    procedure MasterControlCancelSearchEditorMode; virtual;
    procedure MasterControlFindNext; virtual;
    procedure MasterControlFindPrev; virtual;
    procedure MasterControlProcessFindEditorKeyDown(var Key: Word; Shift: TShiftState); virtual;
    procedure MasterControlProcessFindEditorKeyPress(var Key: Char); virtual;
    procedure MasterControlProcessFindEditorKeyUp(var Key: Word; Shift: TShiftState); virtual;
    procedure MasterControlRestartFind; virtual;
    procedure OptionsButtonMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single); virtual;
    procedure Paint; override;
    procedure Resize; override;
    procedure RestartFind;
    procedure SetGetMasterControlSearchEditMode(Value: Boolean); virtual;
    procedure SetSize(var W: Single; var H: Single);

  public

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function CalcAutoHeight: Integer;
    function CalcAutoWidthForHeight(ANewHeight: Integer): Integer;
    function CanPerformSearchActionInMasterControl: Boolean; virtual;
    function GetSearchingText: String;
    function GetFindEditorBorderColor: TAlphaColor; virtual;
    function GetBorderColor: TAlphaColor; virtual;
    function IsSearchingState: Boolean;
    function FilterOnTyping: Boolean; virtual;
    function FilterEnabled: Boolean; virtual;

    procedure CancelSearchEditorMode; virtual;
    procedure ClearSearchFilter; virtual;
    procedure ApplySearchFilter; virtual;
    procedure GetPaintColors(var FromColor, ToColor, HighlightColor: TAlphaColor); virtual;

    procedure InitItems;
    procedure ResetVisibleControls;
    procedure RealignControls; virtual;
    procedure UpdateLanguageVars; virtual;

    property FindButtons[FindBtn: TDataGridNavigatorFindBtnEh]: TNavFindButtonEh read GetFindButtons;
    property FindEditor: TSearchPanelTextEditEh read FFindEditor;
    property Location: TSearchPanelLocationEh read FLocation write SetLocation default TSearchPanelLocationEh.GridTop;
    property MasterControlSearchEditMode: Boolean read GetMasterControlSearchEditMode write SetGetMasterControlSearchEditMode;
    property Grid: TControl read GetGrid;
  end;

implementation

{$REGION 'uses'}
uses Math,
     EhLibLangConsts,
     EhLibFmx.Grids;
{$ENDREGION 'uses'}

type
  TControlCrack = class(TControl);
  TCustomGridEhCrack = class(TCustomGridEh);

var
  SearchPanelOptionsPopupMenu: TPopupMenu;

procedure InitRes;
begin
end;

procedure FinRes;
var
  i: Integer;
begin

  if SearchPanelOptionsPopupMenu <> nil then
  begin
    for i := SearchPanelOptionsPopupMenu.ChildrenCount - 1 downto 0 do
      SearchPanelOptionsPopupMenu.RemoveObject(i);
    FreeAndNil(SearchPanelOptionsPopupMenu);
  end;
end;

{$REGION 'TNavFindButtonEh'}

{ TNavFindButtonEh }

procedure TNavFindButtonEh.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if Assigned(FOnPostMouseDown) then
    FOnPostMouseDown(Self, Button, Shift, X, Y);
end;

procedure TNavFindButtonEh.Paint;
begin
  if FIndex = TDataGridNavigatorFindBtnEh.SearchInfoBox
    then DrawInfoText
    else inherited Paint;
end;

procedure TNavFindButtonEh.DrawInfoText;
begin
end;

{$ENDREGION 'TNavFindButtonEh'}

{$REGION 'TSearchPanelTextEditEh'}

{ TDataGridSearchPanelTextEditEh }

constructor TSearchPanelTextEditEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  TextAppliedAsFilter := False;
  Model.OnChangeTracking := ChangeTracking;
  FAutoHeight := Size.Height;
end;

destructor TSearchPanelTextEditEh.Destroy;
begin
  inherited Destroy;
end;

function TSearchPanelTextEditEh.GetDefaultStyleLookupName: string;
begin
  Result := 'EditStyle';
end;

procedure TSearchPanelTextEditEh.DoChangeAction;
begin
  SearchPanelControl.FindEditorUserChanged;
  if not (SearchPanelControl.FilterEnabled and
          SearchPanelControl.FilterOnTyping) then
  begin
    TextAppliedAsFilter := False;
  end;
  UpdateModified;
end;

procedure TSearchPanelTextEditEh.ChangeTracking(Sender: TObject);
begin
  if FInternalChanging then Exit;
  DoChangeAction;
end;

procedure TSearchPanelTextEditEh.DoEnter;
begin
  SearchPanelControl.SetGetMasterControlSearchEditMode(True);
  inherited DoEnter;
end;

procedure TSearchPanelTextEditEh.DoExit;
begin
  SearchPanelControl.SetGetMasterControlSearchEditMode(False);
  inherited DoExit;
end;

function TSearchPanelTextEditEh.GetBorderColor: TAlphaColor;
begin
  Result := SearchPanelControl.GetFindEditorBorderColor;
end;

procedure TSearchPanelTextEditEh.DrawNonClientBorder;
begin
end;

procedure TSearchPanelTextEditEh.SetIsEmptyState(const Value: Boolean);
begin
  FIsEmptyState := Value;
  if FIsEmptyState then
  begin
  end;
end;

procedure TSearchPanelTextEditEh.KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key <> 0 then
  begin
    SearchPanelControl.FindEditorKeyDown(Key, Shift);
    if Key <> 0 then
      inherited KeyDown(Key, KeyChar, Shift);
  end else
  begin
    inherited KeyDown(Key, KeyChar, Shift);
  end;
end;

procedure TSearchPanelTextEditEh.KeyUp(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key <> 0 then
  begin
    SearchPanelControl.FindEditorKeyUp(Key, Shift);
    if Key <> 0 then
      inherited KeyUp(Key, KeyChar, Shift);
  end else
  begin
    inherited KeyUp(Key, KeyChar, Shift);
  end;
end;

procedure TSearchPanelTextEditEh.SpecInternalSetText(const AText: String);
begin
  FInternalChanging := True;
  try
    Text := AText;
    UpdateModified;
  finally
    FInternalChanging := False;
  end;
end;

procedure TSearchPanelTextEditEh.CancelSearchEditorMode;
begin
  SearchPanelControl.CancelSearchEditorMode;
end;

procedure TSearchPanelTextEditEh.CancelFilter;
begin
  SpecInternalSetText('');
  TextAppliedAsFilter := True;
  UpdateModified;
end;

procedure TSearchPanelTextEditEh.ApplySearchFilter;
begin
  SearchPanelControl.ApplySearchFilter;
end;

procedure TSearchPanelTextEditEh.ClearSearchFilter;
begin
  SearchPanelControl.ClearSearchFilter;
end;

procedure TSearchPanelTextEditEh.UpdateModified;
begin
  if Assigned(OnUpdateModified) then
    OnUpdateModified(Self);
end;

function TSearchPanelTextEditEh.GetHeightFromStyle: Integer;
var
  Control: TControl;
  StyleElement: TFmxObject;
begin
  Result := 0;
  StyleElement := LookupStyleObject(Self, Self.GetStyleContext,
    Self.Scene, 'EditStyle', 'EditStyle', '', False);
  if StyleElement is TControl then
  begin
    Control := TControl(StyleElement);
    if Control.FixedSize.Height <> 0 then
      Result := Round(Control.FixedSize.Height)
    else
      Result := Round(GetDefaultSize.Height);
  end;
end;

procedure TSearchPanelTextEditEh.ApplyStyle;
begin
  inherited ApplyStyle;
  if SearchPanelControl <> nil then
  begin
    FAutoHeight := GetHeightFromStyle;
    if FAutoHeight = 0 then
      FAutoHeight := Size.Height;
    TCustomGridEhCrack(SearchPanelControl.Grid).UpdateScrollBars();
  end;
end;

function TSearchPanelTextEditEh.CalcAutoHeight: Integer;
begin
  Result := Round(FAutoHeight);
end;

procedure TSearchPanelTextEditEh.CheckAddTextToList;
begin
end;

function TSearchPanelTextEditEh.GetSearchPanelControl: TSearchPanelControlEh;
begin
  Result := TSearchPanelControlEh(Owner);
end;

procedure TSearchPanelTextEditEh.SetTextAppliedAsFilter(const Value: Boolean);
begin
  FTextAppliedAsFilter := Value;
end;

procedure TSearchPanelTextEditEh.CheckAddTextToMRUList;
begin
end;

procedure TSearchPanelTextEditEh.MRUListActiveChanged(Sender: TObject);
begin
end;

{$ENDREGION 'TSearchPanelTextEditEh'}

{$REGION 'TSearchPanelControlEh'}

{ TSearchPanelControlEh }

constructor TSearchPanelControlEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  InitItems;
end;

destructor TSearchPanelControlEh.Destroy;
begin
  inherited Destroy;
end;

function TSearchPanelControlEh.IsDrawButtonBorder: Boolean;
begin
  Result := True;
end;

function TSearchPanelControlEh.IsDrawRightBorder: Boolean;
begin
  Result := False;
end;

procedure TSearchPanelControlEh.BtnMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  AcquireMasterControlFocus;
  if TabStop and (IsFocused = False {GetFocus <> Handle}) and CanFocus then
  begin
    SetFocus;
    if (IsFocused = False) then
      Exit;
  end;
  if Sender = FFindButtons[TDataGridNavigatorFindBtnEh.Options] then
  begin
    OptionsButtonMouseDown(Sender, Button, Shift, X, Y);
  end;
end;

procedure TSearchPanelControlEh.OptionsButtonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  DropdownMenu: TPopupMenu;
  P: TPointF;
begin
  if FFindButtons[TDataGridNavigatorFindBtnEh.Options].StaysPressed then
  begin
    FFindButtons[TDataGridNavigatorFindBtnEh.Options].StaysPressed := False;
  end
  else
  begin
    BuildOptionsPopupMenu(DropdownMenu);
    if (DropdownMenu <> nil) and (DropdownMenu.ItemsCount > 0) then
    begin
      FFindButtons[TDataGridNavigatorFindBtnEh.Options].StaysPressed := True;
      DropdownMenu.PopupComponent := FFindButtons[TDataGridNavigatorFindBtnEh.Options];
      P := TPointF.Create(0, TControl(Sender).Height);
      P := TControlCrack(Sender).LocalToScreen(P);
      DropdownMenu.Popup(P.X, P.Y);
      FFindButtons[TDataGridNavigatorFindBtnEh.Options].StaysPressed := False;
    end;
  end;
end;

procedure TSearchPanelControlEh.BuildOptionsPopupMenu(var PopupMenu: TPopupMenu);
var
  i: Integer;
begin
  if SearchPanelOptionsPopupMenu = nil then
    SearchPanelOptionsPopupMenu := TPopupMenu.Create(nil);

  for i := SearchPanelOptionsPopupMenu.ItemsCount - 1 downto 0 do
    SearchPanelOptionsPopupMenu.RemoveObject(i);
  PopupMenu := SearchPanelOptionsPopupMenu;
end;

procedure TSearchPanelControlEh.AcquireMasterControlFocus;
begin
  raise Exception.Create('Method TSearchPanelControlEh.AcquireMasterControlFocus is not implemented.');
end;

function TSearchPanelControlEh.CalcAutoHeight: Integer;
begin
  Result := FindEditor.CalcAutoHeight + 6 + 1;
end;

function TSearchPanelControlEh.CalcAutoWidthForHeight(ANewHeight: Integer): Integer;
begin
  Result := 120 + ANewHeight + ANewHeight + ANewHeight + ANewHeight;
end;

procedure TSearchPanelControlEh.ClickHandler(Sender: TObject);
begin
  if Sender is TNavFindButtonEh then
    FindBtnClick(TNavFindButtonEh(Sender).Index);
end;

procedure TSearchPanelControlEh.DrawNonClientBorder;
begin
end;

procedure TSearchPanelControlEh.FindBtnClick(Index: TDataGridNavigatorFindBtnEh);
begin
  if CanPerformSearchActionInMasterControl then
  begin
    if MasterControlSearchEditMode = False then
      MasterControlSearchEditMode := True;
    case Index of
      TDataGridNavigatorFindBtnEh.CancelSearchFilter:
        if not FFindEditor.TextAppliedAsFilter
          then FFindEditor.ApplySearchFilter
          else FFindEditor.CancelSearchEditorMode;
      TDataGridNavigatorFindBtnEh.FindNext:
        FindNext;
      TDataGridNavigatorFindBtnEh.FindPrev:
        FindPrev;
      TDataGridNavigatorFindBtnEh.Options: ;
    end;
  end;
end;

function TSearchPanelControlEh.CanPerformSearchActionInMasterControl: Boolean;
begin
  raise Exception.Create('Method TSearchPanelControlEh.AcquireMasterControlFocus is not implemented.');
end;

procedure TSearchPanelControlEh.SetGetMasterControlSearchEditMode(Value: Boolean);
begin
  raise Exception.Create('Method TSearchPanelControlEh.SetGetMasterControlSearchEditMode is not implemented.');
end;

function TSearchPanelControlEh.GetMasterControlSearchEditMode: Boolean;
begin
  raise Exception.Create('Method TSearchPanelControlEh.GetMasterControlSearchEditMode is not implemented.');
end;

procedure TSearchPanelControlEh.FindEditorUpdateModified(Sender: TObject);
begin
  if Parent = nil then Exit;
  if not FFindEditor.TextAppliedAsFilter then
  begin
    FFindButtons[TDataGridNavigatorFindBtnEh.CancelSearchFilter].ResourceImageItem := EhLibImageResources.SearchPanelFilterImageItem;
    FFindButtons[TDataGridNavigatorFindBtnEh.CancelSearchFilter].Enabled := True;
    FFindButtons[TDataGridNavigatorFindBtnEh.CancelSearchFilter].Hint := EhLibLanguageConsts.SearchPanelApplyFilterEh;
  end else
  begin
    FFindButtons[TDataGridNavigatorFindBtnEh.CancelSearchFilter].ResourceImageItem := EhLibImageResources.SearchPanelCancelSearchImageItem;
    FFindButtons[TDataGridNavigatorFindBtnEh.CancelSearchFilter].Enabled := CancelSearchFilterEnable;
    FFindButtons[TDataGridNavigatorFindBtnEh.CancelSearchFilter].Hint := EhLibLanguageConsts.SearchPanelCancelFilterEh;
  end;

  FFindButtons[TDataGridNavigatorFindBtnEh.FindNext].Visible := True;
  FFindButtons[TDataGridNavigatorFindBtnEh.FindNext].Enabled := (FindEditor.Text <> '');
  FFindButtons[TDataGridNavigatorFindBtnEh.FindPrev].Visible := True;
  FFindButtons[TDataGridNavigatorFindBtnEh.FindPrev].Enabled := (FindEditor.Text <> '');
end;

function TSearchPanelControlEh.CancelSearchFilterEnable: Boolean;
begin
  raise Exception.Create('Method TSearchPanelControlEh.CancelSearchFilterEnable is not implemented.');
end;

procedure TSearchPanelControlEh.FindNext;
begin
  MasterControlFindNext;
end;

procedure TSearchPanelControlEh.MasterControlFindNext;
begin
  raise Exception.Create('Method TSearchPanelControlEh.MasterControlFindNext is not implemented.');
end;

procedure TSearchPanelControlEh.FindPrev;
begin
  MasterControlFindPrev;
end;

procedure TSearchPanelControlEh.MasterControlFindPrev;
begin
  raise Exception.Create('Method TSearchPanelControlEh.MasterControlFindPrev is not implemented.');
end;

procedure TSearchPanelControlEh.RestartFind;
begin
  MasterControlRestartFind;
end;

procedure TSearchPanelControlEh.MasterControlRestartFind;
begin
end;

function TSearchPanelControlEh.GetSearchingText: String;
begin
  Result := FFindEditor.Text;
end;

function TSearchPanelControlEh.CreateSearchPanelTextEdit: TSearchPanelTextEditEh;
begin
  Result := TSearchPanelTextEditEh.Create(Self);
end;

procedure TSearchPanelControlEh.InitItems;
var
  FI: TDataGridNavigatorFindBtnEh;
  FindBtn: TNavFindButtonEh;
  X: Integer;
  NavigatorFindImageItems: array[TDataGridNavigatorFindBtnEh] of TResourceImageItemEh;
begin
  MinBtnSize := Point(10, 10);
  X := 0;

  FFindEditor := CreateSearchPanelTextEdit;
  FFindEditor.SetBounds(X, 1, 100, MinBtnSize.Y-1);
  FFindEditor.TabStop := False;
  FFindEditor.Parent := Self;
  FFindEditor.IsEmptyState := True;
  FFindEditor.OnUpdateModified := FindEditorUpdateModified;

  X := X + 85;

  NavigatorFindImageItems[TDataGridNavigatorFindBtnEh.SearchInfoBox] := nil;
  NavigatorFindImageItems[TDataGridNavigatorFindBtnEh.CancelSearchFilter] := EhLibImageResources.SearchPanelFilterImageItem;
  NavigatorFindImageItems[TDataGridNavigatorFindBtnEh.FindNext] := EhLibImageResources.SearchPanelFindNextImageItem;
  NavigatorFindImageItems[TDataGridNavigatorFindBtnEh.FindPrev] := EhLibImageResources.SearchPanelFindPriorImageItem;
  NavigatorFindImageItems[TDataGridNavigatorFindBtnEh.Options] := EhLibImageResources.SearchPanelMenuImageItem;

  for FI := Low(FFindButtons) to High(FFindButtons) do
  begin
    FindBtn := TNavFindButtonEh.Create(Self);
    FindBtn.Index := FI;
    FindBtn.ResourceImageItem := NavigatorFindImageItems[FI];

    FindBtn.Enabled := True;
    FindBtn.SetBounds(X, 0, MinBtnSize.X, MinBtnSize.Y);
    FindBtn.Enabled := False;
    FindBtn.Enabled := True; 
    FindBtn.OnClick := ClickHandler;
    FindBtn.OnMouseDown := BtnMouseDown;
    FindBtn.Parent := Self;
    FFindButtons[FI] := FindBtn;
    X := X + MinBtnSize.X;
  end;

  UpdateLanguageVars;
end;

function TSearchPanelControlEh.IsSearchingState: Boolean;
begin
  if FFindEditor.IsFocused and (FFindEditor.Text <> '')
    then Result := True
    else Result := False;
end;

procedure TSearchPanelControlEh.Paint;
begin
  Canvas.Stroke.Color := GetBorderColor();
  Canvas.Stroke.Kind := TBrushKind.Solid;
  if IsDrawButtonBorder then
    Canvas.DrawLine(TPointF.Create(0.5, Height - 0.5), TPointF.Create(Width - 0.5, Height - 0.5), 1);
  if IsDrawRightBorder then
    Canvas.DrawLine(TPointF.Create(Width - 0.5, Height - 0.5), TPointF.Create(Width - 0.5, 0.5), 1);
end;

procedure TSearchPanelControlEh.MasterControlProcessFindEditorKeyDown(
  var Key: Word; Shift: TShiftState);
begin
  raise Exception.Create('Method TSearchPanelControlEh.MasterControlProcessFindEditorKeyDown is not implemented.');
end;

procedure TSearchPanelControlEh.MasterControlProcessFindEditorKeyUp(
  var Key: Word; Shift: TShiftState);
begin

end;

procedure TSearchPanelControlEh.MasterControlProcessFindEditorKeyPress(var Key: Char);
begin
  raise Exception.Create('Method TSearchPanelControlEh.ProcessMasterControlSearchPanelFindEditorKeyPress is not implemented.');
end;

function TSearchPanelControlEh.GetFindEditorBorderColor: TAlphaColor;
var
  ColorsService: IGridSystemColorsService;
begin
  TPlatformServices.Current.SupportsPlatformService(IGridSystemColorsService, ColorsService);
  Result := ColorsService.GEt3DDkShadowColor;
end;

function TSearchPanelControlEh.GetBorderColor: TAlphaColor;
var
  ColorsService: IGridSystemColorsService;
begin
  TPlatformServices.Current.SupportsPlatformService(IGridSystemColorsService, ColorsService);
  Result := ColorsService.GEt3DDkShadowColor;
end;

procedure TSearchPanelControlEh.GetPaintColors(var FromColor, ToColor, HighlightColor: TAlphaColor);
begin
  raise Exception.Create('Method TSearchPanelControlEh.GetPaintColors is not implemented.');
end;

procedure TSearchPanelControlEh.RealignControls;
var
  NewW, NewH: Single;
begin
  NewW := Width;
  NewH := Height;
  SetSize(NewW, NewH);
end;

procedure TSearchPanelControlEh.ResetVisibleControls;
var
  W, H: Single;
begin
  if FFindButtons[TDataGridNavigatorFindBtnEh.CancelSearchFilter].Visible <> MasterControlFilterEnabled then
  begin
    FFindButtons[TDataGridNavigatorFindBtnEh.CancelSearchFilter].Visible := MasterControlFilterEnabled;
    W := Width;
    H := Height;
    SetSize(W, H);
  end;

  FFindButtons[TDataGridNavigatorFindBtnEh.Options].Visible := IsOptionsButtonVisible;
  FFindButtons[TDataGridNavigatorFindBtnEh.CancelSearchFilter].Hint := EhLibLanguageConsts.SearchPanelApplyFilterEh;
  FFindButtons[TDataGridNavigatorFindBtnEh.FindNext].Hint := EhLibLanguageConsts.SearchPanelFindNextEh;
  FFindButtons[TDataGridNavigatorFindBtnEh.FindPrev].Hint := EhLibLanguageConsts.SearchPanelFindPrevEh;
  FFindButtons[TDataGridNavigatorFindBtnEh.Options].Hint := EhLibLanguageConsts.SearchPanelOptionsEh;

  RealignControls;
end;

procedure TSearchPanelControlEh.MasterControlApplySearchFilter;
begin
  raise Exception.Create('Method TSearchPanelControlEh.MasterControlApplySearchFilter is not implemented.');
end;

procedure TSearchPanelControlEh.MasterControlCancelSearchEditorMode;
begin
  raise Exception.Create('Method TSearchPanelControlEh.MasterControlCancelSearchEditorMode is not implemented.');
end;

function TSearchPanelControlEh.MasterControlFilterEnabled: Boolean;
begin
  Result := False;
end;

procedure TSearchPanelControlEh.SetLocation(const Value: TSearchPanelLocationEh);
begin
  if FLocation <> Value then
  begin
    FLocation := Value;
    FindEditor.MiniHeight := (FLocation = TSearchPanelLocationEh.HorzScrollBarExtraPanel);
  end;
end;

procedure TSearchPanelControlEh.Resize;
begin
  inherited Resize;
  RealignControls;
end;

procedure TSearchPanelControlEh.SetSize(var W, H: Single);
var
  X: Single;
  FI: TDataGridNavigatorFindBtnEh;
  EditorHeight, EditorTop: Single;
  EditorBound: TRectF;
  ThisButtonWidth: Single;
  SearchInfoBoxWidth: Integer;
begin
  if (csLoading in ComponentState) then Exit;

  ButtonWidth := H - 1;

  X := Width - 3;

  SearchInfoBoxWidth := CalcSearchInfoBoxWidth;

  for FI := High(FFindButtons) downto Low(FFindButtons) do
  begin
    if FFindButtons[FI].Visible then
    begin
      if FI = TDataGridNavigatorFindBtnEh.SearchInfoBox
        then ThisButtonWidth := SearchInfoBoxWidth
        else ThisButtonWidth := ButtonWidth;
      FFindButtons[FI].SetBounds(X-ThisButtonWidth, 0, ThisButtonWidth, ButtonWidth);
      X := X - ThisButtonWidth;
    end else
      FFindButtons[FI].SetBounds(0, 0, 0, 0);
  end;

  begin
    EditorHeight := H - 7;
    EditorTop := 3;
  end;

  begin
    begin
      EditorBound := RectF(3, EditorTop, X-4, EditorHeight)
    end
  end;

  if EditorBound.Right < 0 then EditorBound.Right := 0;
  if EditorBound.Bottom < 0 then EditorBound.Bottom := 0;

  FFindEditor.SetBounds(EditorBound.Left, EditorBound.Top, EditorBound.Right, EditorBound.Bottom);
end;

function TSearchPanelControlEh.CalcSearchInfoBoxWidth: Integer;
begin
  Result := 0;
end;

function TSearchPanelControlEh.FilterOnTyping: Boolean;
begin
  raise Exception.Create('Method TSearchPanelControlEh.FilterOnTyping is not implemented ');
end;

function TSearchPanelControlEh.FilterEnabled: Boolean;
begin
  raise Exception.Create('Method TSearchPanelControlEh.FilterEnabled is not implemented ');
end;

procedure TSearchPanelControlEh.ClearSearchFilter;
begin

end;

procedure TSearchPanelControlEh.ApplySearchFilter;
begin
  MasterControlApplySearchFilter;
  FindEditor.TextAppliedAsFilter := True;
  FindEditor.UpdateModified;
  FindEditor.CheckAddTextToMRUList;
end;

procedure TSearchPanelControlEh.FindEditorUserChanged;
begin

end;

function TSearchPanelControlEh.IsOptionsButtonVisible: Boolean;
begin
  Result := False;
end;

procedure TSearchPanelControlEh.FindEditorKeyPress(var Key: Char);
begin
  MasterControlProcessFindEditorKeyPress(Key);
  if (Key = #27) {and not FindEditor.ListVisible} then
  begin
  end else if (Key = #13) {and not FindEditor.ListVisible} then
  begin
  end;
end;

procedure TSearchPanelControlEh.FindEditorKeyDown(var Key: Word; Shift: TShiftState);
begin
  MasterControlProcessFindEditorKeyDown(Key, Shift);
  if (Shift = []) and (Key = vkDown) then
  begin
    FindNext;
    Key := 0;
  end else if (Shift = []) and (Key = vkUp) then
  begin
    FindPrev;
    Key := 0;
  end else if (Shift = []) and (Key = vkTab) then
  begin
    MasterControlSearchEditMode := False;
    Key := 0;
  end else if (Shift = []) and (Key = vkReturn) then
  begin
    if FindEditor.Text = '' then
      CancelSearchEditorMode
    else if MasterControlFilterEnabled then
      ApplySearchFilter
    else
    begin
      if ssShift in Shift
        then FindPrev
        else FindNext;
    end;
    Key := 0;
  end else if (Shift = []) and (Key = vkEscape) then
  begin
    CancelSearchEditorMode;
    Key := 0;
  end;
end;

procedure TSearchPanelControlEh.FindEditorKeyUp(var Key: Word; Shift: TShiftState);
begin
  MasterControlProcessFindEditorKeyUp(Key, Shift);
end;

procedure TSearchPanelControlEh.CancelSearchEditorMode;
begin
  FindEditor.SpecInternalSetText('');
  MasterControlCancelSearchEditorMode;
  FindEditor.TextAppliedAsFilter := False;
  FindEditor.UpdateModified;
end;

function TSearchPanelControlEh.GetSearchInfoBoxText: String;
begin
  Result := '';
end;

procedure TSearchPanelControlEh.UpdateLanguageVars;
begin
  ResetVisibleControls;
end;

function TSearchPanelControlEh.GetFindButtons(FindBtn: TDataGridNavigatorFindBtnEh): TNavFindButtonEh;
begin
  Result := FFindButtons[FindBtn];
end;

function TSearchPanelControlEh.GetGrid: TControl;
begin
  Result := (Owner as TCustomGridEh);
end;

{$ENDREGION 'TSearchPanelControlEh'}

initialization
  InitRes;
finalization
  FinRes;
end.
