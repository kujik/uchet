unit SolutionFrame.ProgressBars;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Contnrs, FMX.Objects,
  CustomCells.ProgressBar,
  EhLibFmx.Api, EhLibRtl.Api,
  EhLibFmx.DataGrids, EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.DataGrid.Columns, EhLibFmx.ToolControls, EhLibFmx.Grids,
  EhLibFmx.DataAxisGrids, EhLibFmx.CustomDataGrids, FMX.Controls.Presentation,
  EhLibFmx.DataVertGrids, EhLibFmx.DataVertGrid.Rows,
  EhLibFmx.CustomDataVertGrids, FMX.Layouts;

type
  TfrProgressBar = class(TFrame)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Layout1: TLayout;
    DataGridEh1: TDataGridEh;
    DataGridStringColumnEh1: TDataGridStringColumnEh;
    DataGridLayoutColumnEh1: TDataGridLayoutColumnEh;
    DataVertGridEh1: TDataVertGridEh;
    Splitter1: TSplitter;
    DataVertGridStringRowEh1: TDataVertGridStringRowEh;
    DataVertGridLayoutRowEh1: TDataVertGridLayoutRowEh;
    procedure Button1Click(Sender: TObject);
    procedure DataGridLayoutColumnEh1GetDataCellManager(Sender: TObject;
      Params: TDataGridGetDataCellManagerParamsEh);
    procedure Button2Click(Sender: TObject);
    procedure DataVertGridLayoutRowEh1GetDataCellManager(Sender: TObject;
      Params: TDataVertGridGetDataCellManagerParamsEh);
  private
    FProgressCellManager: TDataGridProgressBarDataCellManagerEh;
  public
    FProcessList: TObjectList;
    FPictureTableLink: TListTableLinkEh;
    FExecTimer: TTimer;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ProcessChanged(Sender: TObject);
    procedure InitProgressParams(Sender: TObject; Params: TBaseDataGridInitProgressParamsEh);
    procedure TimerEvent(Sender: TObject);
    procedure UpdateProcessList();
  end;

implementation

{$R *.fmx}

type
  TProcessExecStatus = (WaitingToStart, Execution, Finished);

{ TProcessInfo }

  TProcessInfo = class(TObject)
  private
    FExecPercent: Double;
    FStatus: TProcessExecStatus;
    FProcessName: String;
    FStartTime: Integer;
    FStepTime: Integer;
    FTickCount: Int64;
    FStarted: Boolean;
  protected
  public
    constructor Create;
    destructor Destroy; override;

    procedure Start;
    procedure UpdateState;

    property ProcessName: String read FProcessName write FProcessName;
    property ExecPercent: Double read FExecPercent write FExecPercent;
    property Status: TProcessExecStatus read FStatus write FStatus;
  end;

constructor TProcessInfo.Create;
begin
  FStartTime := Random(4000);
  FStepTime := Random(100);
  ExecPercent := 0;
end;

destructor TProcessInfo.Destroy;
begin
  inherited Destroy;
end;

procedure TProcessInfo.Start;
begin
  ExecPercent := 0;
  FTickCount := TThread.GetTickCount64;
  FStarted := True;
end;

procedure TProcessInfo.UpdateState;
var
  CurTickCount: Int64;
begin
  CurTickCount := TThread.GetTickCount64;
  if ExecPercent = 0 then
  begin
    if CurTickCount - FTickCount > FStartTime then
    begin
      ExecPercent := ExecPercent + 1;
      FTickCount := CurTickCount;
    end;
  end
  else if ExecPercent >= 100 then
  begin
    ExecPercent := 100;
  end else
  begin
    if CurTickCount - FTickCount > FStepTime then
    begin
      ExecPercent := ExecPercent + 1;
      FTickCount := CurTickCount;
    end;
  end;
end;

{ TfrProgressBar }

constructor TfrProgressBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FProgressCellManager := TDataGridProgressBarDataCellManagerEh.Create(Self);
  FProgressCellManager.OnInitProgressParams := InitProgressParams;

  FExecTimer := TTimer.Create(Self);
  FExecTimer.Interval := 10;
  FExecTimer.Enabled := False;
  FExecTimer.OnTimer := TimerEvent;

  Button1Click(nil);
end;

destructor TfrProgressBar.Destroy;
begin
  FreeAndNil(FProcessList);
  inherited Destroy;
end;

procedure TfrProgressBar.ProcessChanged(Sender: TObject);
begin
  DataGridEh1.Invalidate;
end;

procedure TfrProgressBar.InitProgressParams(Sender: TObject;
  Params: TBaseDataGridInitProgressParamsEh);
var
  ProcessInfo: TProcessInfo;
begin
  if Params.Row = nil then Exit;
  ProcessInfo := Params.Row.SourceObjectItem as TProcessInfo;

  Params.ProgressMin := 0;
  Params.ProgressMax := 100;
  Params.ProgressValue := ProcessInfo.ExecPercent;
end;

procedure TfrProgressBar.TimerEvent(Sender: TObject);
begin
  UpdateProcessList();
end;

procedure TfrProgressBar.UpdateProcessList;
var
  ProcessInfo: TProcessInfo;
  HasExecProcess: Boolean;
begin
  HasExecProcess := False;
  for ProcessInfo in FProcessList do
  begin
    ProcessInfo.UpdateState;
    if ProcessInfo.ExecPercent < 100 then
      HasExecProcess := True;
  end;

  if HasExecProcess = False then
    FExecTimer.Enabled := False;

  DataGridEh1.Invalidate;
  DataVertGridEh1.Invalidate;
end;

procedure TfrProgressBar.Button1Click(Sender: TObject);
var
  ProcessInfo: TProcessInfo;
  I: Integer;
begin
  if FProcessList = nil then
  begin
    FProcessList := TObjectList.Create;

    for I := 0 to 16 do
    begin
      ProcessInfo := TProcessInfo.Create;
      ProcessInfo.ProcessName := 'Process - ' + I.ToString();
      FProcessList.Add(ProcessInfo);
    end;

    FPictureTableLink := TListTableLinkEh.Create(Self);
    FPictureTableLink.SetList(FProcessList, TypeInfo(TProcessInfo));

    DataGridEh1.DataSource := FPictureTableLink;
    DataVertGridEh1.DataSource := FPictureTableLink;

    Button1.Enabled := False;
  end;
end;

procedure TfrProgressBar.Button2Click(Sender: TObject);
var
  ProcessInfo: TProcessInfo;
begin
  FExecTimer.Enabled := True;
  for ProcessInfo in FProcessList do
  begin
    ProcessInfo.Start;
  end;
end;

procedure TfrProgressBar.DataGridLayoutColumnEh1GetDataCellManager(
  Sender: TObject; Params: TDataGridGetDataCellManagerParamsEh);
begin
  Params.CellManager := FProgressCellManager;
end;

procedure TfrProgressBar.DataVertGridLayoutRowEh1GetDataCellManager(
  Sender: TObject; Params: TDataVertGridGetDataCellManagerParamsEh);
begin
  Params.CellManager := FProgressCellManager;
end;

end.
