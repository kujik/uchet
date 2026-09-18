unit CustomCells.ProgressBar;

interface

{$SCOPEDENUMS ON}

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, System.Types,
  System.Variants, Data.DB, TypInfo,
  System.Generics.Collections, Rtti,
  FMX.Graphics, System.UITypes,
  FMX.Objects, FMX.StdCtrls,
  EhLibUtils, DBUtilsEh, EhLib.GridTableViews,
  EhLibFmx.Api, EhLibRtl.Api;

type

{ TBaseDataGridInitProgressParamsEh }

  TBaseDataGridInitProgressParamsEh = class(TPersistent)
  private
    FRow: TTableRowViewEh;
    FColumn: TDataGridBaseColumnEh;
    FGrid: TControl;
    FHandled: Boolean;
    FProgressMin: Double;
    FProgressValue: Double;
    FProgressBarVisible: Boolean;
    FFont: TFont;
    FProgressMax: Double;
    FText: String;
    procedure SetFont(const Value: TFont);
    procedure SetProgressValue(const Value: Double);
    procedure UpdateText;
    procedure SetProgressMax(const Value: Double);
    procedure SetProgressMin(const Value: Double);
    function GetPercent: Double;
  public
    procedure Init(AGrid: TControl; AColumn: TDataGridBaseColumnEh; ARow: TTableRowViewEh); virtual;

    property Grid: TControl read FGrid;
    property Column: TDataGridBaseColumnEh read FColumn;
    property Row: TTableRowViewEh read FRow;

    property ProgressMax: Double read FProgressMax write SetProgressMax;
    property ProgressMin: Double read FProgressMin write SetProgressMin;
    property ProgressValue: Double read FProgressValue write SetProgressValue;
    property Percent: Double read GetPercent;
    property ProgressBarVisible: Boolean read FProgressBarVisible write FProgressBarVisible;
    property Text: String read FText write FText;
    property Font: TFont read FFont write SetFont;

    property Handled: Boolean read FHandled write FHandled;
  end;

  TBaseDataGridInitProgressParamsEventEh = procedure(Sender: TObject; Params: TBaseDataGridInitProgressParamsEh) of object;

  TDataGridProgressBarDataCellManagerEh = class(TDataAxisLayoutCellManagerEh)
  private
    FOnInitProgressParams: TBaseDataGridInitProgressParamsEventEh;
  protected
    function CreateDefaultCellContent(ACell: TGridBaseCellEh; AParent: TLaObjectEh): TLaObjectEh; override;
    procedure HandleCreateCustomCellContent(Params: TBaseGridCreateCellContentParamsEh); override;

    function GetProgressParams(AColumn: TDataGridBaseColumnEh; ARow: TTableRowViewEh): TBaseDataGridInitProgressParamsEh; virtual;
    procedure HandleInitProgressParams(Params: TBaseDataGridInitProgressParamsEh); virtual;
  public
    procedure DefaultInitCellContent(Params: TBaseGridInitCellContentParamsEh); override;
    property OnInitProgressParams: TBaseDataGridInitProgressParamsEventEh read FOnInitProgressParams write FOnInitProgressParams;
  end;

implementation

{ TDataGridProgressBarDataCellManagerEh }

function TDataGridProgressBarDataCellManagerEh.CreateDefaultCellContent(ACell: TGridBaseCellEh;
  AParent: TLaObjectEh): TLaObjectEh;
begin
  with TLaLayoutPanelEh.CreateWith(AParent, AParent) do
  begin
    Margins.Rect := TRectF.Create(4, 4, 4, 4);
    with TLaControlsGenericHelper.CreateControlWith<TProgressBar>(RefSelf, RefSelf) do
    begin
      HitTest := False;
      Width := 200;
      Height := 16;
    end;

    with TLaTextBlockEh.CreateWith(RefSelf, RefSelf) do
    begin
      Text := '100%';
      TextAlign := TTextAlign.Center;
    end;

    Result := RefSelf;
  end;
end;

procedure TDataGridProgressBarDataCellManagerEh.HandleCreateCustomCellContent(Params: TBaseGridCreateCellContentParamsEh);
begin
  inherited HandleCreateCustomCellContent(Params);
end;

procedure TDataGridProgressBarDataCellManagerEh.DefaultInitCellContent(Params: TBaseGridInitCellContentParamsEh);
var
  DataParams: TDataAxisGridInitDataCellContentParamsEh;
  ProgressParams: TBaseDataGridInitProgressParamsEh;
  ProgressBar: TProgressBar;
  TextBlock: TLaTextBlockEh;
  Column: TDataGridBaseColumnEh;
  Row: TTableRowViewEh;
begin
  DataParams := Params as TDataAxisGridInitDataCellContentParamsEh;
  if DataParams.ListItemBar = nil then Exit;

  Column := TDataGridBaseColumnEh(DataParams.FieldBar);
  Row := DataParams.ListItemBar;

  ProgressParams := GetProgressParams(Column, Row);

  ProgressBar := Params.CellContent.Children[0] as TProgressBar;
  ProgressBar.Min := ProgressParams.ProgressMin;
  ProgressBar.Max := ProgressParams.ProgressMax;
  ProgressBar.Value := ProgressParams.ProgressValue;

  TextBlock := Params.CellContent.Children[1] as TLaTextBlockEh;
  TextBlock.Text := ProgressParams.Text;
  if ProgressParams.Percent > 50 then
    TextBlock.FontColor := TAlphaColorRec.White
  else
    TextBlock.FontColor := TAlphaColorRec.Black;

  ProgressParams.Free;
end;

function TDataGridProgressBarDataCellManagerEh.GetProgressParams(AColumn: TDataGridBaseColumnEh; ARow: TTableRowViewEh): TBaseDataGridInitProgressParamsEh;
begin
  Result := TBaseDataGridInitProgressParamsEh.Create;
  Result.Init(AColumn.Grid, AColumn, ARow);
  Result.ProgressMin := 0;
  Result.ProgressMax := 100;
  Result.ProgressValue := 0;
  HandleInitProgressParams(Result);
end;

procedure TDataGridProgressBarDataCellManagerEh.HandleInitProgressParams(Params: TBaseDataGridInitProgressParamsEh);
begin
  if Assigned(OnInitProgressParams) then
    OnInitProgressParams(Self, Params);
end;

{ TBaseDataGridInitProgressParamsEh }

procedure TBaseDataGridInitProgressParamsEh.Init(AGrid: TControl; AColumn: TDataGridBaseColumnEh; ARow: TTableRowViewEh);
begin
  FGrid := AGrid;
  FColumn := AColumn;
  FRow := ARow;
end;

procedure TBaseDataGridInitProgressParamsEh.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TBaseDataGridInitProgressParamsEh.SetProgressMax(const Value: Double);
begin
  if FProgressMax <> Value then
  begin
    FProgressMax := Value;
    UpdateText;
  end;
end;

procedure TBaseDataGridInitProgressParamsEh.SetProgressMin(const Value: Double);
begin
  if FProgressMin <> Value then
  begin
    FProgressMin := Value;
    UpdateText;
  end;
end;

procedure TBaseDataGridInitProgressParamsEh.SetProgressValue(const Value: Double);
begin
  if FProgressValue <> Value then
  begin
    FProgressValue := Value;
    UpdateText;
  end;
end;

procedure TBaseDataGridInitProgressParamsEh.UpdateText;
begin
  Text := Percent.ToString + ' %';
end;

function TBaseDataGridInitProgressParamsEh.GetPercent: Double;
begin
  if (ProgressMax - ProgressMin) <> 0 then
    Result := 100 / (ProgressMax - ProgressMin) * FProgressValue
  else
    Result := 0;
end;

end.
