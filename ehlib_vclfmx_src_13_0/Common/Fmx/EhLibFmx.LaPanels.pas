{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{                   EhLibFmx.LaPanels                   }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

{$I ..\Incl\EhLib.Inc}
{$SCOPEDENUMS ON}

unit EhLibFmx.LaPanels;

interface

{$REGION 'uses'}
uses
  Types, Classes,
  SysUtils, Variants,
  {$IFDEF EH_LIB_17} System.UITypes, {$ENDIF}
  Generics.Collections, DB,
  EhLibFmx.LaObjects, EhLibFmx.LaControls,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics
  ;
{$ENDREGION 'uses'}

type
  TLaLayoutPanelEh = class;
  TLaStackPanelEh = class;

{ TLaContentPanelEh }

  TLaLayoutPanelEh = class(TLaControlEh)
  private
  protected
    procedure DoAddObject(const AObject: TFmxObject); override;
    procedure KeyDownEventHandler(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    function DoQueryLayoutClientArea(const QuerySize: TSizeF; ACanvas: TCanvas): TSizeF; overload; override;
    function DoPerformLayoutClientArea(const ClientRect: TRectF; ACanvas: TCanvas): TSizeF; overload; override;
  published
  end;

{ TLaStackPanelEh }

  TLaStackPanelEh = class(TLaControlEh)
  private
    FOrientation: TLaOrientationEh;
    procedure SetOrientation(const Value: TLaOrientationEh);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    function DoQueryLayoutClientArea(const QuerySize: TSizeF; ACanvas: TCanvas): TSizeF; overload; override;
    function DoPerformLayoutClientArea(const ClientRect: TRectF; ACanvas: TCanvas): TSizeF; overload; override;

  published
    property Orientation: TLaOrientationEh read FOrientation write SetOrientation default TLaOrientationEh.Vertical;
  end;

{ TLaControlsGenericHelper }

  TLaControlsGenericHelper = class
    class function CreateControlWith<T: TControl>(AOwner: TComponent; AParentObject: TLaObjectEh): T; overload;
    class function CreateControlWith<T: TControl>(AOwner: TComponent; AParentObject: TFmxObject): T; overload;
  end;

{ TControlHelper }

  TControlHelper = class helper for TControl
    function RefSelf: TControl;
  end;


implementation

class function TLaControlsGenericHelper.CreateControlWith<T>(AOwner: TComponent; AParentObject: TLaObjectEh): T;
begin
  Result := T.Create(AOwner);
  Result.Parent := AParentObject;
end;

class function TLaControlsGenericHelper.CreateControlWith<T>(AOwner: TComponent; AParentObject: TFmxObject): T;
begin
  Result := T.Create(AOwner);
  Result.Parent := AParentObject;
end;

{ TLaContentPanelEh }

constructor TLaLayoutPanelEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TLaLayoutPanelEh.Destroy;
begin
  inherited Destroy;
end;

procedure TLaLayoutPanelEh.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
end;

function TLaLayoutPanelEh.DoQueryLayoutClientArea(const QuerySize: TSizeF; ACanvas: TCanvas): TSizeF;
var
  FmxObject: TFmxObject;
  FmxControl: TControl;
  LaObject: TLaObjectEh;
  ASize: TSizeF;
  I: Integer;
begin
  Result := TSizeF.Create(0, 0);
  ASize := TSizeF.Create(0, 0);

  for I := 0 to ChildrenCount - 1 do
  begin
    FmxObject := Children[I];
    FmxControl := nil;
    LaObject := nil;

    if FmxObject is TControl then
      FmxControl := TControl(FmxObject);
    if FmxObject is TLaObjectEh then
      LaObject := TLaObjectEh(FmxObject);

    if (LaObject <> nil) and
       (LaObject.Visible = True) then
    begin
      ASize := LaObject.QueryLayout(QuerySize, ACanvas);
    end
    else if (FmxControl <> nil) and
            (FmxControl.Visible = True) then
    begin
//      if (FmxControl.Align = TAlignLayout.None) then
//        ASize := FmxControl.Size.Size
//      else
//      ASize := FmxControl.Size.DefaultValue;
      ASize := TSizeF.Create(0, 0);
    end;

    if (ASize.cx > Result.cx) then
      Result.cx := ASize.cx;
    if (ASize.cy > Result.cy) then
      Result.cy := ASize.cy;
  end;
end;

function TLaLayoutPanelEh.DoPerformLayoutClientArea(const ClientRect: TRectF; ACanvas: TCanvas): TSizeF;
var
  FmxObject: TFmxObject;
  FmxControl: TControl;
  FmxControlRect: TRectF;
  LaObject: TLaObjectEh;
  ASize: TSizeF;
  I: Integer;
begin
  Result := TSizeF.Create(0, 0);

  for I := 0 to ChildrenCount - 1 do
  begin
    FmxObject := Children[I];
    FmxControl := nil;
    LaObject := nil;

    if FmxObject is TControl then
      FmxControl := TControl(FmxObject);
    if FmxObject is TLaObjectEh then
      LaObject := TLaObjectEh(FmxObject);

    if (LaObject <> nil) then
    begin
      ASize := LaObject.PerformLayout(ClientRect, ACanvas, UnlimitedRect);
    end
    else if (FmxControl <> nil) then
    begin
//      if (FmxControl.Align = TAlignLayout.None) then
      FmxControlRect := FmxControl.Margins.PaddingRect(ClientRect);
      FmxControl.SetBounds(FmxControlRect.Left, FmxControlRect.Top, FmxControlRect.Width, FmxControlRect.Height);
      ASize := ClientRect.Size;
    end;

    if (ASize.cx > Result.cx) then
      Result.cx := ASize.cx;
    if (ASize.cy > Result.cy) then
      Result.cy := ASize.cy;
  end;

  if (Result.Width > ClientRect.Width) then
    Result.Width := ClientRect.Width;
  if (Result.Height > ClientRect.Height) then
    Result.Height := ClientRect.Height;
end;

procedure TLaLayoutPanelEh.DoAddObject(const AObject: TFmxObject);
var
  FmxControl: TControl;
begin
  inherited DoAddObject(AObject);
  if AObject is TLaObjectEh then
  begin
  end else if AObject is TControl then
  begin
    FmxControl := TControl(AObject);
    FmxControl.OnKeyDown := KeyDownEventHandler;
  end;
end;

procedure TLaLayoutPanelEh.KeyDownEventHandler(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
var
  KeyParams: TLaObjectKeyEventParamsEh;
begin
  KeyParams := TLaObjectKeyEventParamsEh.Create;
  KeyParams.Init(Key, KeyChar, Shift, Sender);
  try
    InternalProcessKeyDown(KeyParams);
  finally
    KeyParams.Free;
  end;
end;

{ TLaStackPanelEh }

constructor TLaStackPanelEh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOrientation := TLaOrientationEh.Vertical;
end;

destructor TLaStackPanelEh.Destroy;
begin
  inherited Destroy;
end;

procedure TLaStackPanelEh.SetOrientation(const Value: TLaOrientationEh);
begin
  FOrientation := Value;
end;

function TLaStackPanelEh.DoQueryLayoutClientArea(const QuerySize: TSizeF; ACanvas: TCanvas): TSizeF;
var
  I: Integer;
  LaObject: TLaObjectEh;
  ASize: TSizeF;
  LaQuerySize: TSizeF;
begin
  Result := TSizeF.Create(0, 0);

  if (Orientation = TLaOrientationEh.Vertical) then
  begin
    LaQuerySize.cx := QuerySize.cx;

{$IFDEF EH_LIB_18} 
    LaQuerySize.cy := Int32.MaxValue - 10000;
{$ELSE}
    LaQuerySize.cy := High(Integer) - 10000;
{$ENDIF}
  end
  else
  begin
{$IFDEF EH_LIB_18} 
    LaQuerySize.cx := Int32.MaxValue - 10000;
{$ELSE}
    LaQuerySize.cx := High(Integer) - 10000;
{$ENDIF}
    LaQuerySize.cy := QuerySize.cy;
  end;

  for I := 0 to ChildrenCount - 1 do
  begin
    LaObject := TLaObjectEh(Children[I]);
    ASize := LaObject.QueryLayout(LaQuerySize, ACanvas);

    if (Orientation = TLaOrientationEh.Vertical) then
    begin
      Result.cy := Result.cy + ASize.cy;
      if (Result.cx < ASize.cx ) then
        Result.cx := ASize.cx;
    end else
    begin
      Result.cx := Result.cx + ASize.cx;
      if (Result.cy < ASize.cy ) then
        Result.cy := ASize.cy;
    end;
  end;
end;

function TLaStackPanelEh.DoPerformLayoutClientArea(const ClientRect: TRectF; ACanvas: TCanvas): TSizeF;
var
  I: Integer;
  LaObject: TLaObjectEh;
  ASize: TSizeF;
  PerfRect: TRectF;
  CurPos: TPointF;
begin
  CurPos.X := ClientRect.Left;
  CurPos.Y := ClientRect.Top;

  Result := TSizeF.Create(0, 0);
  for I := 0 to ChildrenCount - 1 do
  begin
    LaObject := TLaObjectEh(Children[I]);
    if (Orientation = TLaOrientationEh.Vertical) then
    begin
      PerfRect := RectF(CurPos.X,
                       CurPos.Y,
                       CurPos.X + RectWidth(ClientRect),
                       CurPos.Y + LaObject.NeededSize.cy + LaObject.Margins.Top + LaObject.Margins.Bottom);
      ASize := LaObject.PerformLayout(PerfRect, ACanvas, UnlimitedRect);
      CurPos.Y := CurPos.Y + ASize.cy;
      if (Result.cx < ASize.cx) then
        Result.cx := ASize.cx;
      Result.cy := CurPos.Y;
    end else
    begin
      PerfRect := RectF(CurPos.X,
                       CurPos.Y,
                       CurPos.X + LaObject.NeededSize.cx + LaObject.Margins.Left + LaObject.Margins.Right,
                       CurPos.Y + ClientRect.Height);
      ASize := LaObject.PerformLayout(PerfRect, ACanvas, UnlimitedRect);
      CurPos.X := CurPos.X + ASize.cx;
      if (Result.cy < ASize.cy) then
        Result.cy := ASize.cy;
      Result.cx := CurPos.X;
    end;
  end;
end;

procedure TLaStackPanelEh.Assign(Source: TPersistent);
begin
  inherited Assign(Source);

  if (Source is TLaStackPanelEh) then
  begin
    Orientation := TLaStackPanelEh(Source).Orientation;
  end;
end;

{ TControlHelper }

function TControlHelper.RefSelf: TControl;
begin
  Result := Self;
end;

end.
