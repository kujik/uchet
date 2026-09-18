{*******************************************************}
{                                                       }
{                       EhLib 12.1                      }
{                     LaHintWindows                     }
{                                                       }
{    Copyright (c) 2022-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

{$I ..\Incl\EhLib.Inc}

unit LaHintWindows;

interface

{$SCOPEDENUMS ON}

uses
  Types, Classes,
  Messages, SysUtils, Variants,
  {$IFDEF FPC}
    EhLibLclUtils,
  {$ELSE}
    EhLibVclUtils, Windows,
  {$ENDIF}
  Generics.Collections, DB,
  LaObjectsEh,
  ToolCtrlsEh, DBAxisGridsEh,
  ImgList, Themes, GraphUtil,
  Graphics, Controls, Forms, Dialogs;

type

  TLaHintWindowEh = class(THintWindowEh)
  private
    FLaHost: TLaHostWinControl;
    procedure PaintBackground;
  protected
    procedure Paint; override;

  public
    constructor Create(AOwner: TComponent); override;

    procedure ActivateHint(Rect: TRect; const AHint: string); override;
    procedure ActivateHintData(Rect: TRect; const AHint: string; AData: TCustomData); override;
    function CalcHintRect(MaxWidth: Integer; const AHint: string; AData: TCustomData): TRect; override;
  end;

implementation

{$IFDEF FPC}
uses DBGridEh;
{$ELSE}
uses DBGridEh;
{$ENDIF}

type
  TCustomDBGridEhCrack = class(TCustomDBGridEh);

type
  TDBGridEhLaHostWinControl = class(TLaHostWinControl)
  protected
    procedure Paint; override;
  public
    DataRowNum: Integer;
    Grid: TCustomDBGridEh;
  end;

{ TDBGridEhLaHostWinControl }

procedure TDBGridEhLaHostWinControl.Paint;
var
  Grid: TCustomDBGridEhCrack;
begin
  if DataRowNum >= 0 then
  begin
    Grid := TCustomDBGridEhCrack(Self.Grid);
    Grid.InstantReadRecordEnter(DataRowNum);
    try
      inherited Paint;
    finally
      Grid.InstantReadRecordLeave;
    end;
  end else
  begin
    inherited Paint;
  end;
end;

{ TLaHintWindow }

constructor TLaHintWindowEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FLaHost := TDBGridEhLaHostWinControl.Create(Self);
  FLaHost.Align := alClient;
  FLaHost.Parent := Self;
end;

procedure TLaHintWindowEh.ActivateHint(Rect: TRect; const AHint: string);
begin
  inherited ActivateHint(Rect, AHint);
end;

procedure TLaHintWindowEh.ActivateHintData(Rect: TRect; const AHint: string; AData: TCustomData);
begin
  inherited ActivateHintData(Rect, AHint, AData);
end;

function TLaHintWindowEh.CalcHintRect(MaxWidth: Integer; const AHint: string; AData: TCustomData): TRect;
var
  DataHintParams: TDBGridEhDataHintParams;
  Grid: TCustomDBGridEhCrack;
begin
  if (AData <> nil) and
     (TObject(AData) is TDBGridEhDataHintParams) and
     (TDBGridEhDataHintParams(AData).LaHintObject <> nil) then
  begin
    DataHintParams := TDBGridEhDataHintParams(AData);
    Grid := TCustomDBGridEhCrack(DataHintParams.Grid);
    FLaHost.Visible := True;
    FLaHost.LaObject := DataHintParams.LaHintObject;
    FLaHost.DataSource := Grid.DBDataSource;

    TDBGridEhLaHostWinControl(FLaHost).DataRowNum := DataHintParams.DataRowNum;
    TDBGridEhLaHostWinControl(FLaHost).Grid := Grid;

    Grid.InstantReadRecordEnter(DataHintParams.DataRowNum);
    try
      FLaHost.LaObject.QueryLayout(RectSize(Screen.WorkAreaRect), Canvas);
    finally
      Grid.InstantReadRecordLeave;
    end;

    Result := Rect(0, 0, FLaHost.LaObject.NeededSize.cx, FLaHost.LaObject.NeededSize.cy);
    Inc(Result.Right, 2);
    Inc(Result.Bottom, 0);
  end
  else
  begin
    FLaHost.LaObject := nil;
    FLaHost.Visible := False;
    Result := inherited CalcHintRect(MaxWidth, AHint, AData);
  end;
end;

procedure TLaHintWindowEh.Paint;
begin
  if (FLaHost.LaObject <> nil) then
    PaintBackground
  else
    inherited Paint;
end;

procedure TLaHintWindowEh.PaintBackground;
var
  R: TRect;
{$IFDEF EH_LIB_16}
  ClipRect: TRect;
  LColor: TColor;
  LStyle: TCustomStyleServices;
  LDetails: TThemedElementDetails;
  LGradientStart, LGradientEnd: TColor;
{$ELSE}
{$ENDIF}
begin
  R := ClientRect;
  {$IFDEF EH_LIB_16}
  LStyle := StyleServices;
  if LStyle.Enabled then
  begin
    ClipRect := R;
    InflateRect(R, 4, 4);
    if TOSVersion.Check(6) and LStyle.IsSystemStyle then
    begin
      
      LStyle.DrawElement(Canvas.Handle, LStyle.GetElementDetails(tttStandardNormal), R, ClipRect);
    end
    else
    begin
      LDetails := LStyle.GetElementDetails(thHintNormal);
      if LStyle.GetElementColor(LDetails, ecGradientColor1, LColor) and (LColor <> clNone) then
        LGradientStart := LColor
      else
        LGradientStart := clInfoBk;
      if LStyle.GetElementColor(LDetails, ecGradientColor2, LColor) and (LColor <> clNone) then
        LGradientEnd := LColor
      else
        LGradientEnd := clInfoBk;
      GradientFillCanvas(Canvas, LGradientStart, LGradientEnd, R, gdVertical);
    end;
    R := ClipRect;
  end;
  {$ELSE}
  {$ENDIF}
end;

end.
