{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{            EhLibFmx.Grid.InplaceEditors               }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.Grid.InplaceEditors;

interface

{$SCOPEDENUMS ON}

uses
  System.SysUtils, System.Classes, System.Types, FMX.Controls, FMX.Graphics,
  FMX.Controls.Presentation, FMX.StdCtrls, System.UITypes, FMX.Forms,
  FMX.Presentation.Messages, FMX.Controls.Model, FMX.Edit, FMX.Memo,
  EhLibFmx.Grid.CellManagers,
  EhLibFmx.LaObjects,
  EhLibFmx.LaPanels,
  EhLibFmx.ToolControls,
  EhLibFmx.Styles,
  EhLibFmx.Types;

type
{ TInplaceEdit }

  TInplaceEdit = class(TMemo)
  private
    FCell: TGridBaseCellEh;
    FGrid: TControl;
    FInternalTextAssignment: Boolean;

  protected
    function DefineModelClass: TDataModelClass; override;
    function GetDefaultStyleLookupName: string; override;

    procedure KeyDown(var Key: Word; var KeyChar: Char; Shift: TShiftState); override;

    procedure BoundsChanged; virtual;
    procedure DoChangeTracking; virtual;
    procedure InternalMove(const Loc: TRect; Redraw: Boolean);
    procedure UserTextChanged; virtual;

    property Cell: TGridBaseCellEh read FCell;
    property Grid: TControl read FGrid;
  public
    constructor Create(AOwner: TComponent); override;

    procedure Hide; reintroduce; virtual;
    procedure InternalSetText(AText: String);
    procedure Move(const Loc: TRect); reintroduce;
    procedure SetCell(ACell: TGridBaseCellEh);
    procedure SetGrid(Value: TControl);
    procedure UpdateContents; virtual;
  end;

{ TInplaceEditModel }

  TInplaceEditModel = class(TCustomMemoModel)
  protected
    procedure DoChangeTracking; override;
  end;

  TInplaceEditClass = class of TInplaceEdit;

{ TLaInplaceTextEdit }

  TLaInplaceTextEdit = class(TLaLayoutPanelEh)
  private
    FCell: TGridBaseCellEh;
    FGrid: TControl;
    FOnChangeTracking: TNotifyEvent;

    function CreateInternalEdit: TInplaceEdit;
    function GetReadOnly: Boolean;
    function GetText: String;
    function GetTextSettings: TTextSettings;
    procedure SetReadOnly(const Value: Boolean);
    procedure SetText(const Value: String);
    procedure SetTextSettings(const Value: TTextSettings);

  protected
    FInternalEdit: TInplaceEdit;
    FInternalEditClass: TInplaceEditClass;

    function DefaultCreateInternalEdit: TInplaceEdit; virtual;

    procedure KeyDown(var Key: Word; var KeyChar: Char; Shift: TShiftState); override;

    procedure DoChangeTracking; virtual;

  public
    constructor CreateWith(AOwner: TComponent; AParentObject: TLaObjectEh; AInternalEditClass: TInplaceEditClass); overload; virtual;
    constructor Create(AOwner: TComponent; AInternalEditClass: TInplaceEditClass); overload; virtual;
    constructor Create(AOwner: TComponent); overload; override;
    destructor Destroy; override;

    procedure SelectAll;
    procedure SetCell(ACell: TGridBaseCellEh);
    procedure SetFocus;
    procedure SetGrid(Value: TControl);
    procedure UpdateContents; virtual;

    property Cell: TGridBaseCellEh read FCell;
    property Grid: TControl read FGrid;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly;
    property Text: String read GetText write SetText;
    property TextSettings: TTextSettings read GetTextSettings write SetTextSettings;
    property InternalEdit: TInplaceEdit read FInternalEdit;

    property OnChangeTracking: TNotifyEvent read FOnChangeTracking write FOnChangeTracking;
  end;

implementation

uses EhLibFmx.Grids;

type
  TCustomGridEhCrack = class(TCustomGridEh);

  TInplaceEditHelper = class helper for TInplaceEdit
  private
    function GetGrid: TCustomGridEhCrack;
  public
    property Grid: TCustomGridEhCrack read GetGrid;
  end;

  function TInplaceEditHelper.GetGrid: TCustomGridEhCrack;
  begin
    Result := TCustomGridEhCrack(FGrid);
  end;

{ TInplaceEdit }

constructor TInplaceEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ShowScrollBars := False;
end;

function TInplaceEdit.DefineModelClass: TDataModelClass;
begin
  Result := TInplaceEditModel;
end;

procedure TInplaceEdit.DoChangeTracking;
begin
  if not FInternalTextAssignment then
    UserTextChanged;
  if Owner is TLaInplaceTextEdit then
    TLaInplaceTextEdit(Owner).DoChangeTracking;
end;

procedure TInplaceEdit.UserTextChanged;
begin
end;

function TInplaceEdit.GetDefaultStyleLookupName: string;
begin
  if TStyleManagerEh.Current.FindStyleElement('TransparentEdit') <> nil then
    Result := 'TransparentEdit'
  else
    Result := 'memoStyle';
end;

procedure TInplaceEdit.Hide;
begin
  Visible := False;
end;

procedure TInplaceEdit.InternalMove(const Loc: TRect; Redraw: Boolean);
begin
  if IsRectEmpty(Loc) then
    Visible := False
  else
  begin
    SetBounds(Loc.Left, Loc.Top, Loc.Right - Loc.Left, Loc.Bottom - Loc.Top);
    Visible := True;
    BoundsChanged;
    if Grid.IsFocused then
      Grid.InternalSetFocusedControl(Self);
  end;
end;

procedure TInplaceEdit.KeyDown(var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  inherited KeyDown(Key, KeyChar, Shift);
end;

procedure TInplaceEdit.Move(const Loc: TRect);
begin
  InternalMove(Loc, True);
end;

procedure TInplaceEdit.SetGrid(Value: TControl);
begin
  FGrid := Value;
end;

procedure TInplaceEdit.SetCell(ACell: TGridBaseCellEh);
begin
  FCell := ACell;
end;

procedure TInplaceEdit.UpdateContents;
begin
  Text := Grid.GetEditText(Grid.CurColIndex, Grid.CurRowIndex);
  MaxLength := Grid.GetEditLimit;
end;

procedure TInplaceEdit.BoundsChanged;
begin
end;

procedure TInplaceEdit.InternalSetText(AText: String);
begin
  FInternalTextAssignment := True;
  try
    Text := AText;
  finally
    FInternalTextAssignment := False;
  end;
end;

{ TInplaceEditModel }

procedure TInplaceEditModel.DoChangeTracking;
begin
  inherited DoChangeTracking;
  (Owner as TInplaceEdit).DoChangeTracking;
end;

{ TLaInplaceTextEdit }

constructor TLaInplaceTextEdit.Create(AOwner: TComponent; AInternalEditClass: TInplaceEditClass);
begin
  FInternalEditClass := AInternalEditClass;
  Create(AOwner);
end;

constructor TLaInplaceTextEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FInternalEdit := CreateInternalEdit;
  FInternalEdit.Parent := Self;
end;

constructor TLaInplaceTextEdit.CreateWith(AOwner: TComponent; AParentObject: TLaObjectEh;
  AInternalEditClass: TInplaceEditClass);
begin
  FInternalEditClass := AInternalEditClass;
  inherited CreateWith(AOwner, AParentObject);
end;

destructor TLaInplaceTextEdit.Destroy;
begin
  inherited Destroy;
end;

function TLaInplaceTextEdit.CreateInternalEdit: TInplaceEdit;
begin
  if FInternalEditClass <> nil then
    Result := FInternalEditClass.Create(Self)
  else
    Result := DefaultCreateInternalEdit();
end;

function TLaInplaceTextEdit.DefaultCreateInternalEdit: TInplaceEdit;
begin
  Result := TInplaceEdit.Create(Self);
end;

procedure TLaInplaceTextEdit.KeyDown(var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  FInternalEdit.KeyDown(Key, KeyChar, Shift);
end;

procedure TLaInplaceTextEdit.SetFocus;
begin
  FInternalEdit.SetFocus;
end;

procedure TLaInplaceTextEdit.SetGrid(Value: TControl);
begin
  FGrid := Value;
  FInternalEdit.SetGrid(Value);
end;

procedure TLaInplaceTextEdit.SetCell(ACell: TGridBaseCellEh);
begin
  FCell := ACell;
  FInternalEdit.SetCell(ACell);
end;

function TLaInplaceTextEdit.GetText: String;
begin
  Result := FInternalEdit.Text;
end;

procedure TLaInplaceTextEdit.SetText(const Value: String);
begin
  FInternalEdit.Text := Value;
end;

function TLaInplaceTextEdit.GetTextSettings: TTextSettings;
begin
  Result := FInternalEdit.TextSettings;
end;

procedure TLaInplaceTextEdit.SetTextSettings(const Value: TTextSettings);
begin
  FInternalEdit.TextSettings := Value;
end;

procedure TLaInplaceTextEdit.UpdateContents;
begin
  FInternalEdit.UpdateContents;
end;

procedure TLaInplaceTextEdit.SelectAll;
begin
  FInternalEdit.SelectAll;
end;

function TLaInplaceTextEdit.GetReadOnly: Boolean;
begin
  Result := FInternalEdit.ReadOnly;
end;

procedure TLaInplaceTextEdit.SetReadOnly(const Value: Boolean);
begin
  FInternalEdit.ReadOnly := Value;
end;

procedure TLaInplaceTextEdit.DoChangeTracking;
begin
  if Assigned(FOnChangeTracking) then
    FOnChangeTracking(Self);
end;

end.
