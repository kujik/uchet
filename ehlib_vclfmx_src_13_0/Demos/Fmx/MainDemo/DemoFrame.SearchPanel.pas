unit DemoFrame.SearchPanel;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FrameDemoBase, FMX.Objects,
  FMX.Controls.Presentation,
  MemTableDataEh,
  Data.DB,
  MemTableEh,
  EhLibRtl.Api,
  EhLibFmx.Api,
  EhLibFmx.ToolControls, EhLibFmx.Grids, EhLibFmx.DataAxisGrids,
  EhLibFmx.CustomDataGrids, EhLibFmx.DataGrids;

type
  TfrSearchPanel = class(TfrDemoBase)
    Panel1: TPanel;
    Text1: TText;
    SpeedButtonBack: TSpeedButton;
    Panel2: TPanel;
    bFilerOnTyping: TButton;
    DataGridEh1: TDataGridEh;
    MemTableEh1: TMemTableEh;
    procedure SpeedButtonBackClick(Sender: TObject);
    procedure bFilerOnTypingClick(Sender: TObject);
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  frSearchPanel: TfrSearchPanel;

implementation

{$R *.fmx}

constructor TfrSearchPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SpeedButtonBack.Visible := TEhLibFmxSettings.Default.PlatformWindowSizeType = TPlatformWindowSizeTypeEh.FullScreen;
end;

procedure TfrSearchPanel.SpeedButtonBackClick(Sender: TObject);
begin
  BackButtonClicked;
end;

procedure TfrSearchPanel.bFilerOnTypingClick(Sender: TObject);
begin
  DataGridEh1.SearchPanel.FilterOnTyping := not DataGridEh1.SearchPanel.FilterOnTyping;
  if DataGridEh1.SearchPanel.FilterOnTyping
    then bFilerOnTyping.Text := 'FilterOnTyping (Yes)'
    else bFilerOnTyping.Text := 'FilterOnTyping (No)';
end;

end.
