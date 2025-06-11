unit D_LoadKBLog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_Normal, DBGridEhGrouping, ToolCtrlsEh,
  DBGridEhToolCtrls, DynVarsEh, MemTableDataEh, Data.DB, MemTableEh,
  Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh,
  uString
  ;

type
  TDlg_LoadKBLog = class(TForm_Normal)
    DBGridEh1: TDBGridEh;
    E_PPComment: TDBEditEh;
    MemTableEh1: TMemTableEh;
    DataSource1: TDataSource;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ShowDialog(va: TVarDynArray2);
  end;

var
  Dlg_LoadKBLog: TDlg_LoadKBLog;

implementation

uses
  uSettings,
  uForms,
  uDBOra,
  uData,
  uWindows,
  uMessages,
  D_Order
  ;

{$R *.dfm}

procedure TDlg_LoadKBLog.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  inherited;
end;

procedure TDlg_LoadKBLog.ShowDialog(va: TVarDynArray2);
var
  i, j: Integer;
begin
  if Length(va) = 0 then begin
    MyInfoMessage('Паспорт КБ еще не импортировался!.');
    Exit;
  end
  else if (Length(va) = 1)and(va[0][0] = #1) then begin
    MyInfoMessage('Импорт паспорта КБ завершнен без ошибок.');
    Exit;
  end;
  if DbGridEh1.Columns.Count = 1 then begin
    DbGridEh1.Columns.Clear;
    MemTableEh1.DataDriver:=nil;
    MemTableEh1.FieldDefs.Clear;
    MemTableEh1.Close;
    Mth.AddTableColumn(DBGridEh1, 'name', ftString, 400, 'Наименование', 300, True);
    Mth.AddTableColumn(DBGridEh1, 'dim', ftString, 400, 'Ед.', 45, True);
    Mth.AddTableColumn(DBGridEh1, 'qnt', ftString, 400, 'Кол-во', 300, True);
    Mth.AddTableColumn(DBGridEh1, 'status', ftString, 400, 'Статус', 300, True);
    MemTableEh1.CreateDataSet;
    DBGridEh1.IndicatorOptions:=DBGridEh1.IndicatorOptions - [gioShowRowSelCheckBoxesEh] + [gioShowRecNoEh];
  //  DbGridEh1.optionseh:=DbGridEh1.optionseh - [dghClearSelection];
  //  DbGridEh1.options:=DbGridEh1.options + [dgRowSelect];
    DBGridEh1.ReadOnly:= True;
    DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh-[dghColumnResize, dghColumnMove] - [dghEnterAsTab] + [dghAutoFitRowHeight];
    DBGridEh1.AutoFitColWidths:=True;
    for i:=0 to DBGridEh1.Columns.Count - 1 do begin
      DBGridEh1.Columns[i].AutoFitColWidth:=DBGridEh1.Columns[i].FieldName <> '' ;//= 'NAME';     //использовать этот столбец для подгонки
    end;
    width:=800;
    height:=500;
  //  Cth.SetBtn(Bt_Ok, mybtOk, False);
  //  Cth.SetBtn(Bt_Cancel, mybtCancel, False);
  end;
  MemTableEh1.DisableControls;
  MemTableEh1.First;
  while not MemTableEh1.Eof do MemTableEh1.Delete;
  for i:=0 to High(va) do begin
    MemTableEh1.Append;
    for j:= 1 to 4 do
      MemTableEh1.Fields[j-1].Value:=VarToStr(va[i][j-1]);
  end;
  MemTableEh1.First;
  MemTableEh1.EnableControls;
  ShowModal;
end;

end.
