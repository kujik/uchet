unit D_CandidatesFromWorkerStatus;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_Normal, DBGridEhGrouping, ToolCtrlsEh,
  DBGridEhToolCtrls, DynVarsEh, Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh, EhLibVCL,
  GridsEh, DBAxisGridsEh, DBGridEh, MemTableDataEh, Data.DB, MemTableEh,
  Vcl.Buttons
  ;

type
  TDlg_CandidatesFromWorkerStatus = class(TForm_Normal)
    DBGridEh1: TDBGridEh;
    edt_PPComment: TDBEditEh;
    MemTableEh1: TMemTableEh;
    DataSource1: TDataSource;
    Bt_Cancel: TBitBtn;
    Bt_Ok: TBitBtn;
    lbl1: TLabel;
    procedure Bt_CancelClick(Sender: TObject);
    procedure Bt_OkClick(Sender: TObject);
    procedure DBGridEh1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    IdWorker: Integer;
    WorkerStatus: Integer;     //1-принят, 3-уволен
    ID: Integer;               //айди выбранного в гриде
    Dt: TDateTime;
  public
    { Public declarations }
    procedure ShowDialog(aIdWorker: Integer; aWorkerStatus: Integer; aDt: TDateTime);
  end;

var
  Dlg_CandidatesFromWorkerStatus: TDlg_CandidatesFromWorkerStatus;

implementation

uses
  uSettings,
  uForms,
  uDBOra,
  uString,
  uData,
  uWindows,
  uMessages
  ;

{$R *.dfm}

//class
procedure TDlg_CandidatesFromWorkerStatus.Bt_CancelClick(Sender: TObject);
begin
  inherited;
  ModalResult:=mrCancel;
  Close;
end;

procedure TDlg_CandidatesFromWorkerStatus.Bt_OkClick(Sender: TObject);
begin
  inherited;
  ModalResult:=mrNone;
  if DBGridEh1.SelectedRows.Count = 0 then begin
    MyInfoMessage('Выберите запись в таблице!');
    Exit;
  end;
  ModalResult:=mrOk;
end;

procedure TDlg_CandidatesFromWorkerStatus.DBGridEh1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
//при клике мышкой на области чекбокса, сбросим выделение, проставим галку для текущей строки и сохраним айди
begin
  inherited;
  if x > 35 then exit;
  DBGridEh1.SelectedRows.Clear;
  DBGridEh1.SelectedRows.CurrentRowSelected := True;
  id:=MemTableEh1.FieldByName('id').AsInteger;
end;


procedure TDlg_CandidatesFromWorkerStatus.ShowDialog(aIdWorker: Integer; aWorkerStatus: Integer; aDt: TDateTime);
var
  Res, i: Integer;
begin
  IdWorker:=aIdWorker;
  WorkerStatus:=aWorkerStatus;

//  IdWorker:=75;

  if IdWorker = null then Exit;

  if DBGridEh1.Columns.Count = 1 then begin
    MemTableEh1.DataDriver:=nil;
    MemTableEh1.FieldDefs.Clear;
    MemTableEh1.close;
    Mth.AddTableColumn(DBGridEh1, 'id', ftInteger, 0, 'ID', 20, True);
    Mth.AddTableColumn(DBGridEh1, 'name', ftString, 400, 'ФИО', 200, False);
    Mth.AddTableColumn(DBGridEh1, 'dt_birth', ftDate, 0, 'Д/р', 70, True);
    Mth.AddTableColumn(DBGridEh1, 'dt', ftDate, 0, 'Д/обр', 70, True);
    Mth.AddTableColumn(DBGridEh1, 'job', ftString, 400, 'Должность', 200, True);
    Mth.AddTableColumn(DBGridEh1, 'statusfull', ftString, 300, 'Статус', 300, True);
    //создаем датасет
    MemTableEh1.CreateDataSet;
  end;

  MemTableEh1.ReadOnly:=False;
  //получим записи,
  //про приеме все записи соискателей с таким же фио,
  //а при увольнении только тех, кто был принят и не был еще ууволен
  Q.QLoadToMemTableEh(
    'select c.id,c.name,c.dt_birth,c.dt,c.job,c.statusfull from v_j_candidates c, ref_workers w where c.f = w.f and c.i = w.i and c.o = w.o and w.id = :id$i' +
    S.IIFStr(WorkerStatus<>1, ' and c.dt1 is not null and c.dt2 is null', ''),
    [IdWorker],
    MemTableEh1,
    'id;name;dt_birth;dt;job;statusfull'
  );
  MemTableEh1.First;
  MemTableEh1.ReadOnly:=True;

  DBGridEh1.IndicatorOptions:=DBGridEh1.IndicatorOptions + [gioShowRowSelCheckBoxesEh];
  DbGridEh1.options:=DbGridEh1.options - [dgMultiSelect];
  DbGridEh1.options:=DbGridEh1.options + [dgRowSelect];

  if MemTableEh1.RecordCount = 0 then exit;

  Caption:='Соискатели - ' + MemTableEh1.FieldByName('name').AsString;

  //если строка всего одна, то сразу отметим ее галочкой
  DBGridEh1.SelectedRows.Clear;
  if MemTableEh1.RecordCount = 1 then begin
    DBGridEh1.SelectedRows.CurrentRowSelected := True;
    id:=MemTableEh1.FieldByName('id').AsInteger;
  end;

  Cth.SetBtn(Bt_Ok, mybtOk, False, S.IIFStr(WorkerStatus = 1, 'Принять', 'Уволить'));
  Cth.SetBtn(Bt_Cancel, mybtCancel, False, 'Отмена');

  if ShowModal = mrOk then begin

//не смог понять, как получить строку, в которой установлен чекбокс. !!!!!!!!!
//если перемещаться по гриду стрелками, то можно уйти со строки с галкой без ее снятия, и в этом случае получает не галку, а текущую строку
{
//  MyInfoMessage(inttostr(id));
//  MyInfoMessage(inttostr(DBGridEh1.SelectedRows.Count));
//MyInfoMessage(DBGridEh1.Datasource.DataSet.FieldByName('id').AsString);
        for i:=0 to DBGridEh1.SelectedRows.Count -1 do begin
          if not DBGridEh1.DataSource.DataSet.BookmarkValid(DBGridEh1.SelectedRows[i]) then Continue;
          try
//          DBGridEh1.DataSource.DataSet.Bookmark := DBGridEh1.SelectedRows[i];          //ошибка при фильтре здесь, BookmarkValid не помогает
//          SetLength(Wh.SelectDialogResult2, Length(Wh.SelectDialogResult2)+1);
//          SetLength(Wh.SelectDialogResult2[i], DBGridEh1.DataSource.DataSet.Fields.Count);
//          for j:=0 to DBGridEh1.DataSource.DataSet.Fields.Count -1 do
//            Wh.SelectDialogResult2[i][j]:=DBGridEh1.DataSource.DataSet.Fields[j].AsVariant;
//if DBGridEh1.SelectedRows.CurrentRowSelected then
//MyInfoMessage(DBGridEh1.DataSource.DataSet.Fields[0].Asstring);
          finally
          end;
        end;
        }
    if WorkerStatus = 1
      then Res:= Q.QExecSql('update j_candidates set id_status = null, dt1 = :dt$d, dt2 = null where id = :id$i', [aDt, id])
      else Res:= Q.QExecSql('update j_candidates set id_status = null, dt2 = :dt$d where id = :id$i', [aDt, id]);
    if Res >= 0 then MyInfoMessage('Статус соискателя установлен.');
  end;;

end;


end.
