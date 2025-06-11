unit uFrmXGsrvSqlMonitor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uLabelColors
  ;

type
  TFrmXGsrvSqlMonitor = class(TFrmBasicGrid2)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    function  PrepareForm: Boolean; override;
    procedure LoadLogToGrid;
  public
    procedure LoadLogRowToGrid(Row: Integer = -1);
  end;

var
  FrmXGsrvSqlMonitor: TFrmXGsrvSqlMonitor;

implementation

{$R *.dfm}

uses
  uDB;


function TFrmXGsrvSqlMonitor.PrepareForm: Boolean;
begin
  Caption := 'SQL Monitor';
  Frg1.Opt.SetFields([
    ['id$i','id','40'],
    ['time$d','Время','110'],
    ['source$s','Источник','80'],
    ['query$s','Текст запроса','400;w;h'],
    ['params$s','Параметры','300;w;h'],
    ['error$s','Статус','100;h']
  ]);
  Frg1.SetInitData([], '');
  Result := inherited;
end;

procedure TFrmXGsrvSqlMonitor.FormCreate(Sender: TObject);
begin
  inherited;
  FrmXGsrvSqlMonitor := Self;
end;

procedure TFrmXGsrvSqlMonitor.FormDestroy(Sender: TObject);
begin
  inherited;
  FrmXGsrvSqlMonitor := nil;
end;

procedure TFrmXGsrvSqlMonitor.LoadLogRowToGrid(Row: Integer = -1);
begin
  if (Row < 0) or (Row > High(Q.LogArray)) then
    Row := High(Q.LogArray);
  Frg1.MemTableEh1.Append;
  Frg1.MemTableEh1.FieldByName('id').Value := VarToStr(Q.LogArray[Row][cmydbLogId]);
  Frg1.MemTableEh1.FieldByName('time').Value := (Q.LogArray[Row][cmydbLogTime]);
  Frg1.MemTableEh1.FieldByName('source').Value := VarToStr(Q.LogArray[Row][cmydbLogSource]);
  Frg1.MemTableEh1.FieldByName('query').Value := VarToStr(Q.LogArray[Row][cmydbLogQuery]);
  Frg1.MemTableEh1.FieldByName('params').Value := VarToStr(Q.LogArray[Row][cmydbLogParams]);
  Frg1.MemTableEh1.FieldByName('error').Value := VarToStr(Q.LogArray[Row][cmydbLogError]);
  Frg1.MemTableEh1.Post;
end;

procedure TFrmXGsrvSqlMonitor.LoadLogToGrid;
var
  i: Integer;
begin
  Frg1.MemTableEh1.EmptyTable;
  for i := 0 to High(Q.LogArray) do begin
    LoadLogRowToGrid(i);
  end;
end;




end.
