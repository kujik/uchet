{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{                EhLibFmx.DropDownForms                 }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.DropDownForms;

interface

{$SCOPEDENUMS ON}

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  DynVarsEh,
  EhLibFmx.Utils,
  EhLibFmx.ToolControls;

type
  TInitDropDownFormEventEh = procedure(Sender: TForm; DynParams: TDynVarsEh) of object;
  TPutBackFormParamsEventEh = procedure(Sender: TForm; DynParams: TDynVarsEh) of object;

  TDropDownFormElementEh = (LeftGrip, RightGrip, CloseButton, SizingBar);
  TDropDownFormElementsEh = set of TDropDownFormElementEh;

  TDropDownFormEh = class(TForm, IDropDownFormEh)
  private
    FOnReturnParams: TPutBackFormParamsEventEh;
    FOnInitForm: TInitDropDownFormEventEh;
    FReadOnly: Boolean;
    FDropDownMode: Boolean;
    FSizeGrip: TSizeGripEh;
    FSizeGrip2: TSizeGripEh;
    FFormElements: TDropDownFormElementsEh;
    FAutoClose: Boolean;

  protected
    FModalMode: Boolean;
    FDynParams: TDynVarsEh;
    FSysParams: TDropDownFormSysParams;
    FDropLayout: TDropLayoutEh;
    FMasterForm: TCommonCustomForm;
    FMasterFocusControl: IControl;
    FActivateShowing: Boolean;
    FCallbackProc: TDropDownFormCallbackProcEh;
    FTimer: TTimer;
    FTimedCloseIsNeeded: Boolean;
    FRealigning: Boolean;

    procedure DoHide; override;
    procedure DoClose(var CloseAction: TCloseAction); override;
    procedure DoShow; override;

    procedure Realign; override;

    function GetReadOnly: Boolean;
    procedure Close;
    procedure SetReadOnly(const Value: Boolean);
    procedure SetReturnParams(Host: TComponent; DynParams: TDynVarsEh; SysParams: TDropDownFormSysParams); virtual;
    procedure InitElements; virtual;
    procedure DeactivateHandler(Sender: TObject);
    procedure ActivateHandler(Sender: TObject);
    procedure TimerElapsed(Sender: TObject);
    procedure UpdateSizeGrips;

  public
    constructor CreateNew(AOwner: TComponent; Dummy: NativeInt = 0); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure InitializeNewForm; override;

    function Execute(RelativePosControl: TControl; DownStateControl: TControl; Align: TDropDownAlign; DynParams: TDynVarsEh): Boolean;
    procedure ExecuteNoModal(ParentControl: TControl; RelativePosRect: TRect; DownStateControl: TControl; Align: TDropDownAlign; DynParams: TDynVarsEh; SysParams: TDropDownFormSysParams; CallbackProc: TDropDownFormCallbackProcEh);
    procedure InitForm(Host: TComponent; DynParams: TDynVarsEh); virtual;
    procedure PostClose;
    procedure CallCloseProc(Accept: Boolean);

    property DropDownMode: Boolean read FDropDownMode;

    property OnInitForm: TInitDropDownFormEventEh read FOnInitForm write FOnInitForm;
    property OnReturnParams: TPutBackFormParamsEventEh read FOnReturnParams write FOnReturnParams;
    property FormElements: TDropDownFormElementsEh read FFormElements write FFormElements default [TDropDownFormElementEh.LeftGrip, TDropDownFormElementEh.RightGrip, TDropDownFormElementEh.CloseButton, TDropDownFormElementEh.SizingBar];
    property AutoClose: Boolean read FAutoClose write FAutoClose;
  end;

var
  DropDownFormEh: TDropDownFormEh;

implementation

{$R *.fmx}

function AdjustDropDownForm(AControl: TCommonCustomForm; HostRect: TRect; Align: TDropDownAlign): TDropLayoutEh;
var
  WorkArea: TRectF;
  HostP: TPoint;
begin

  Result := TDropLayoutEh.UnderControl;
  WorkArea := Screen.DisplayFromRect(HostRect).WorkareaRect;

  HostP := HostRect.TopLeft;

  AControl.Left := HostP.x;
  AControl.Top := HostP.y + (HostRect.Bottom - HostRect.Top) + 1;

  case Align of
    TDropDownAlign.Right: AControl.Left := AControl.Left - (AControl.Width - (HostRect.Right - HostRect.Left) );
    TDropDownAlign.Center: AControl.Left := AControl.Left - ((AControl.Width - (HostRect.Right - HostRect.Left)) div 2);
  end;

  if (AControl.Width > WorkArea.Right - WorkArea.Left) then
    AControl.Width := Round(WorkArea.Right - WorkArea.Left);

  if (AControl.Left + AControl.Width > WorkArea.Right) then
    AControl.Left := Round(WorkArea.Right - AControl.Width);
  if (AControl.Left < WorkArea.Left) then
    AControl.Left := Round(WorkArea.Left);

  if (AControl.Top + AControl.Height > WorkArea.Bottom) then
  begin
    if (HostP.y - WorkArea.Top > WorkArea.Bottom - HostP.y - (HostRect.Bottom - HostRect.Top)) then
    begin
      Result := TDropLayoutEh.AboveControl;
      AControl.Top := HostP.y - AControl.Height;
    end;
  end;

  if (AControl.Top < WorkArea.Top) then
  begin
    AControl.Height := AControl.Height - Round(WorkArea.Top - AControl.Top);
    AControl.Top := Round(WorkArea.Top);
  end;
  if (AControl.Top + AControl.Height > WorkArea.Bottom) then
  begin
    AControl.Height := Round(WorkArea.Bottom - AControl.Top);
  end;
end;

constructor TDropDownFormEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FTimer := TTimer.Create(nil);
  FTimer.Interval := 1;
  FTimer.OnTimer := TimerElapsed;
  FTimer.Enabled := False;
  FTimedCloseIsNeeded := False;

  FAutoClose := True;

  FormStyle := TFormStyle.StayOnTop;
  OnActivate := ActivateHandler;
end;

constructor TDropDownFormEh.CreateNew(AOwner: TComponent;
  Dummy: NativeInt);
begin
  inherited CreateNew(AOwner, Dummy);
end;

procedure TDropDownFormEh.InitializeNewForm;
begin
  inherited InitializeNewForm;

  FSizeGrip := TSizeGripEh.Create(nil);
  FSizeGrip.Parent := Self;
  FSizeGrip.TriangleWindow := True;
  FSizeGrip.Visible := False;

  FSizeGrip2 := TSizeGripEh.Create(nil);
  FSizeGrip2.Parent := Self;
  FSizeGrip2.TriangleWindow := True;
  FSizeGrip2.Position := TSizeGripPosition.BottomLeft;
  FSizeGrip2.Visible := False;

  FFormElements := [TDropDownFormElementEh.LeftGrip,
                    TDropDownFormElementEh.RightGrip,
                    TDropDownFormElementEh.CloseButton,
                    TDropDownFormElementEh.SizingBar];
end;

destructor TDropDownFormEh.Destroy;
begin
  FreeAndNil(FTimer);
  FreeAndNil(FSizeGrip);
  FreeAndNil(FSizeGrip2);
  inherited Destroy;
end;

procedure TDropDownFormEh.DoClose(var CloseAction: TCloseAction);
begin
  inherited DoClose(CloseAction);
  CallCloseProc(ModalResult = mrOk);
end;

procedure TDropDownFormEh.DoHide;
begin
  FTimedCloseIsNeeded := False;
  FTimer.Enabled := False;
  inherited DoHide;
end;

procedure TDropDownFormEh.DoShow;
begin
  inherited DoShow;

  FSizeGrip.BringToFront;
  FSizeGrip2.BringToFront;
end;

procedure TDropDownFormEh.CallCloseProc(Accept: Boolean);
begin
  if Accept then
  begin
    SetReturnParams(nil, FDynParams, FSysParams);
  end;

  if (@FCallbackProc <> nil) then
  begin
    FCallbackProc(Self, Accept, FDynParams, FSysParams)
  end;
end;

procedure TDropDownFormEh.Close;
begin
  if FWinService <> nil then
    inherited Close
  else
    CallCloseProc(False);
end;

procedure TDropDownFormEh.DeactivateHandler(Sender: TObject);
begin
  if AutoClose then
    PostClose;
end;

procedure TDropDownFormEh.ActivateHandler(Sender: TObject);
begin
  OnDeactivate := DeactivateHandler;
end;

function TDropDownFormEh.Execute(RelativePosControl,
  DownStateControl: TControl; Align: TDropDownAlign;
  DynParams: TDynVarsEh): Boolean;
var
  SelfPos, RelPos: TPoint;
begin
  FModalMode := True;
  FDynParams := DynParams;

  if Visible then
    Visible := False;

  FDropLayout := AdjustDropDownForm(Self, ControlRectClientToScreen(RelativePosControl), Align);
  SelfPos := ControlClientToScreen(Self, Point(0,0));
  RelPos := ControlClientToScreen(RelativePosControl, Point(0,0));
  if SelfPos.Y < RelPos.Y then
  begin
    FSizeGrip.Position := TSizeGripPosition.TopRight;
    FSizeGrip2.Position := TSizeGripPosition.TopLeft;
  end else
  begin
    FSizeGrip.Position := TSizeGripPosition.BottomRight;
    FSizeGrip2.Position := TSizeGripPosition.BottomLeft;
  end;

  InitForm(nil, DynParams);

  ModalResult := mrNone;
  Visible := True;

  while Active and (ModalResult = mrNone) do
    Application.HandleMessage;

  Visible := False;
  Result := False;
  if ModalResult = mrOk then
  begin
    Result := True;
    SetReturnParams(nil, DynParams, FSysParams);
  end;
end;

procedure TDropDownFormEh.ExecuteNoModal(ParentControl: TControl;
  RelativePosRect: TRect;
  DownStateControl: TControl; Align: TDropDownAlign; DynParams: TDynVarsEh;
  SysParams: TDropDownFormSysParams; CallbackProc: TDropDownFormCallbackProcEh);
begin
  OnDeactivate := nil;
  FDropDownMode := True;
  FModalMode := False;
  FDynParams := DynParams;
  FSysParams := SysParams;
  FMasterForm := Screen.ActiveForm;
  FMasterFocusControl := Screen.FocusControl;

  if Visible then
    Visible := False;

  FDropLayout := AdjustDropDownForm(Self, RelativePosRect, Align);
  if FDropLayout = TDropLayoutEh.AboveControl then
  begin
    FSizeGrip.Position := TSizeGripPosition.TopRight;
    FSizeGrip2.Position := TSizeGripPosition.TopLeft;
  end else
  begin
    FSizeGrip.Position := TSizeGripPosition.BottomRight;
    FSizeGrip2.Position := TSizeGripPosition.BottomLeft;
  end;

  InitElements;
  InitForm(nil, DynParams);

  ModalResult := mrNone;

  FActivateShowing := True;
  try
    Visible := True;
  finally
    FActivateShowing := False;
  end;


  FCallbackProc := CallbackProc;
end;

function TDropDownFormEh.GetReadOnly: Boolean;
begin
  Result := FReadOnly;
end;

procedure TDropDownFormEh.InitElements;
begin

end;

procedure TDropDownFormEh.InitForm(Host: TComponent;
  DynParams: TDynVarsEh);
begin
  if Assigned(OnInitForm) then
    OnInitForm(Self, DynParams);
end;

procedure TDropDownFormEh.Realign;
begin
  inherited Realign;
  if FRealigning = False then
  begin
    FRealigning := True;
    try
      UpdateSizeGrips;
    finally
      FRealigning := False;
    end;
  end;
end;

procedure TDropDownFormEh.UpdateSizeGrips;
begin
  FSizeGrip.Visible := TDropDownFormElementEh.RightGrip in FormElements;
  if FSizeGrip.Visible then
  begin
    FSizeGrip.UpdatePosition;
  end;

  FSizeGrip2.Visible := TDropDownFormElementEh.LeftGrip in FormElements;
  if FSizeGrip2.Visible then
  begin
    FSizeGrip2.UpdatePosition;
  end;
end;

procedure TDropDownFormEh.SetReturnParams(Host: TComponent; DynParams: TDynVarsEh; SysParams: TDropDownFormSysParams);
begin
  if Assigned(OnReturnParams) then
    OnReturnParams(Self, DynParams);
end;

procedure TDropDownFormEh.SetReadOnly(const Value: Boolean);
begin
  FReadOnly := Value;
end;

procedure TDropDownFormEh.TimerElapsed(Sender: TObject);
begin
  if FTimedCloseIsNeeded then
  begin
    FTimedCloseIsNeeded := False;
    FTimer.Enabled := False;
    Close;
  end;
end;

procedure TDropDownFormEh.PostClose;
begin
  FTimedCloseIsNeeded := True;
  FTimer.Enabled := True;
end;


end.
