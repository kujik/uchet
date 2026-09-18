unit SolutionFrame.HighlightingLinksFormatTextSections;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  OpenViewUrl,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, EhLibFmx.Api, MemTableDataEh,
  Data.DB, MemTableEh, EhLibFmx.DataGrids, EhLibFmx.DataAxisGrid.FieldBars, EhLibFmx.DataGrid.Columns,
  EhLibFmx.ToolControls, EhLibFmx.Grids, EhLibFmx.DataAxisGrids, EhLibFmx.CustomDataGrids,
  FMX.Controls.Presentation;

type
  TfrHighlightingLinksFormatTextSections = class(TFrame)
    Panel1: TPanel;
    DataGridEh1: TDataGridEh;
    DataGridStringColumnEh1: TDataGridStringColumnEh;
    DataGridStringColumnEh2: TDataGridStringColumnEh;
    cbIsOpenURL: TCheckBox;
    MemTableEh1: TMemTableEh;
    procedure DataGridStringColumnEh2DataCellInTextLinkClick(Sender: TObject;
      Params: TDataGridDataCellInTextLinkClickParamsEh);
    procedure DataGridStringColumnEh2DataCellGetStyleParams(Sender: TObject;
      Params: TDataGridStringDataCellStyleParamsEh);
  private
  public
    CapitalCharFont: TFont;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.fmx}

constructor TfrHighlightingLinksFormatTextSections.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CapitalCharFont := TFont.Create;
  CapitalCharFont.Size := 16;
  CapitalCharFont.Style := [TFontStyle.fsBold];
//  DataGridStringColumnEh2.HighlightHyperlinks := False;
end;

destructor TfrHighlightingLinksFormatTextSections.Destroy;
begin
  CapitalCharFont.Free;
  inherited Destroy;
end;

procedure TfrHighlightingLinksFormatTextSections.DataGridStringColumnEh2DataCellGetStyleParams(
  Sender: TObject; Params: TDataGridStringDataCellStyleParamsEh);
var
  FormattedRange: TLaFormattedTextRangeEh;
begin
  FormattedRange := TLaFormattedTextRangeEh.Create;
  FormattedRange.TextPos := 0;
  FormattedRange.TextLength := 1;
  FormattedRange.IsHyperLink := True;
  FormattedRange.Font := CapitalCharFont;
  FormattedRange.FontColor := TAlphaColorRec.Brown;
  Params.FormattedRanges.Add(FormattedRange);
end;

procedure TfrHighlightingLinksFormatTextSections.DataGridStringColumnEh2DataCellInTextLinkClick(
  Sender: TObject; Params: TDataGridDataCellInTextLinkClickParamsEh);
begin
  if cbIsOpenURL.IsChecked and (Length(Params.LinkText) > 1) then
    OpenURL(Params.LinkText)
  else
    ShowMessage('"' + Params.LinkText + '" Clicked');
end;

end.
