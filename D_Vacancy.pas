unit D_Vacancy;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Math,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, Mask, uData, uForms, uDBOra, uString, uMessages, System.Types,
  Vcl.ExtCtrls, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  GridsEh, DBAxisGridsEh, DBGridEh, MemTableDataEh, MemTableEh,
  Data.DB, Vcl.Menus, uSettings, Vcl.Imaging.pngimage, V_MDI, Vcl.ComCtrls,
  EhLibVclUtils
  ;

type
  TDlg_Vacancy = class(TForm_MDI)
    pnl_Top: TPanel;
    pnl_Grid: TPanel;
    pnl_Bottom: TPanel;
    pnl_Buttons: TPanel;
    cmb_Division: TDBComboBoxEh;
    cmb_Job: TDBComboBoxEh;
    cmb_Head: TDBComboBoxEh;
    dedt_Dt: TDBDateTimeEditEh;
    cmb_Status: TDBComboBoxEh;
    nedt_Qnt: TDBNumberEditEh;
    nedt_QntOpen: TDBNumberEditEh;
    DBGridEh1: TDBGridEh;
    edt_PPComment: TDBEditEh;
    DataSource1: TDataSource;
    MemTableEh1: TMemTableEh;
    dedt_DtEnd: TDBDateTimeEditEh;
    cmb_Reason: TDBComboBoxEh;
    Bt_Ok: TBitBtn;
    Bt_Cancel: TBitBtn;
    mem_Comm: TMemo;
    lbl_comm: TLabel;
    Img_Info: TImage;
    chb_Close: TCheckBox;
    Bt_Refresh: TBitBtn;
    Bt_Add: TBitBtn;
    Bt_Edit: TBitBtn;
    lbl_Candidates: TLabel;
    procedure ControlOnChange(Sender: TObject);
    procedure ControlOnExit(Sender: TObject);
    procedure ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean);
    procedure chb_CloseClick(Sender: TObject);
    procedure Bt_CancelClick(Sender: TObject);
    procedure Bt_OkClick(Sender: TObject);
    procedure Bt_RefreshClick(Sender: TObject);
    procedure Bt_AddClick(Sender: TObject);
    procedure Bt_EditClick(Sender: TObject);
    procedure DBGridEh1DblClick(Sender: TObject);
  private
    { Private declarations }
    aControls: array of TControl;
    Ok: Boolean;
    InClose: Boolean;
    function  Prepare: Boolean; override;
    procedure SetControlsVer;
    procedure SetControlsEnabled;
    procedure SetGrid;
    procedure LoadGrid;
    procedure Verify(Sender: TObject; onInput: Boolean = False);
  public
    { Public declarations }
    constructor ShowDialog(aOwner: TComponent; aFormDoc: string; aMode: TDialogType; aID: Variant; AMyFormOptions: TMyFormOptions; aAccMode: Variant);
  end;

var
  Dlg_Vacancy: TDlg_Vacancy;

implementation

{$R *.dfm}

uses
  uWindows,
  D_Grid1
  ;


constructor TDlg_Vacancy.ShowDialog(aOwner: TComponent; aFormDoc: string; aMode: TDialogType; aID: Variant; AMyFormOptions: TMyFormOptions; aAccMode: Variant);
begin
  inherited Create(aOwner, aFormDoc, AMyFormOptions + [myfoDialog], aMode, aID, null);
end;

function TDlg_Vacancy.Prepare: Boolean;
var
  v, vc, vt: TVarDynArray;
  i: Integer;
  e: Extended;
  b, e1, e2: Boolean;
  ws: TWindowState;
  FieldNames, FieldNamesCp: string;
  Info: string;
begin
  Result:=False;
  if FormDbLock = fNone then Exit;

  aControls:=[
    cmb_Division,
    cmb_Job,
    cmb_Head,
    dedt_Dt,
    cmb_Status,
    nedt_Qnt,
    nedt_QntOpen,

    dedt_DtEnd,
    cmb_Reason,
    mem_Comm,
    chb_Close
  ];


  cmb_Status.Items.Add('Плановая');
  cmb_Status.KeyItems.Add('0');
  cmb_Status.Items.Add('Срочная');
  cmb_Status.KeyItems.Add('1');
  cmb_Status.Items.Add('Резерв');
  cmb_Status.KeyItems.Add('2');

  cmb_Reason.Items.Add('Вакансия закрыта');
  cmb_Reason.KeyItems.Add('1');
  cmb_Reason.Items.Add('Решение руководителя');
  cmb_Reason.KeyItems.Add('2');

  //подразделения
  Q.QLoadToDBComboBoxEh('select name, id from ref_divisions order by name', [], cmb_Division, cntComboLK);
  //профессии
  Q.QLoadToDBComboBoxEh('select name, id from ref_jobs order by name',[], cmb_Job, cntComboLK);
  //работники
  Q.QLoadToDBComboBoxEh(
    'select workername, max(id_worker) from v_j_worker_status where status <> 3 or id_worker = (select id_head from v_j_vacancy where id = :id$i) group by workername order by workername',
    [ID], cmb_Head, cntComboLK);
  //получим данные из основной таблицы
  FieldNames:='id$i;id_division$i;id_job$i;id_head$i;dt_beg$d;status$i;qnt$i;qntopen$i;dt_end$d;reason$i;comm$s';
//  FieldNamesCp:='id$i;f$s;i$s;o$s;dt_birth$d;phone$s';
  //дефолтные значения полей
  v:=VarArrayOf([
    -1,
    null,
    null,
    null,
    Date,
    null,
    null,
    null, //QndOpen
    null,
    null,
    '',
    0
  ]);
  //загрузим существующие, если это не добавление записи
  if Mode <> fAdd
    then begin
{      if Mode = fCopy then begin
        //для операции копирования читаем только личную информацию
        vc:=QSelectOneRow(QSIUDSql('s', 'v_j_candidates', FieldNamesCp), ID);
        //если не удалось получить то выйдем с сообщением что строка удалена
        if vc[0] = null then begin MsgRecordIsDeleted; Exit; end;
        for i:=1 to High(vc) do v[i]:=vc[i];
      end
      else}
      begin
        v:=Q.QSelectOneRow(Q.QSIUDSql('s', 'v_j_vacancy', FieldNames), [ID]);
        //если не удалось получить то выйдем с сообщением что строка удалена
        if v[0] = null then begin MsgRecordIsDeleted; Exit; end;
      end;
    end;
  //сбросим айди, тк он используется при поиске более раннихз записей по тем же фио
  if Mode in [fAdd, fCopy] then ID:= -1;

  //поля и внешний вид грида
  SetGrid;

   //события onCahange и  onExit для всех dbeh контролов
  Cth.SetControlsOnChange(Self, ControlOnChange);
  Cth.SetControlsOnExit(Self, ControlOnExit);
  Cth.SetControlsOnCheckDrawRequired(Self, ControlCheckDrawRequiredState);
  //чекбокс Вакансия снята
  v[11]:=S.IIf(v[8] <> null, 1, 0);
  //проставим контролы
  for i:=0 to High(aControls) do begin
    Cth.SetControlValue(aControls[i], v[i+1]);
  end;
  LoadGrid;

  Cth.SetDialogForm(Self, Mode, 'Вакансия.');
  Cth.SetBtn(Bt_Refresh, mybtRefresh, False, 'Обновить');
  Cth.SetBtn(Bt_Add, mybtAdd, False, 'Добавить');
  Cth.SetBtn(Bt_Edit, mybtEdit, False, 'Изменить');

  Info:=
  S.IIFStr(Mode = fDelete,
  'Нажмите Ок, чтобы удалить вакансию'+
  '(запись не будет удалена, пока есть соискатели по данной вакансии.'#13#10+
  'Если список соискателей не пустой, Вам нужно изменить вакнсию - выбрать другую, или пустую - для каждого человека в списке!)'#13#10
  ,
  S.IIFStr(Mode = fAdd,
  'Добавление новой вакансии.'#13#10+
  'Заполоните заголовчные данные.'#13#10+
  'Чтобы ввести остальные данные вакансии, и соискателей по ним, закройте это окно, нажав Ок,'#13#10+
  'после чего вакансия появится в журнале. Теперь вы можете отредактировать ее для внесения изменений.'#13#10
  ,
  'Введите данные по вакансии. Также, при необходимости, добавьте или измените данные соискателей для этой вакансии.'#13#10+
  ''#13#10
  )
  )
  ;

  if Mode in [fView, fDelete] then Info:='';
  Cth.SetInfoIcon(Img_Info, Info, 20);

  SetControlsVer;
  SetControlsEnabled;
  Verify(nil);

  if Mode = fAdd then begin
    pnl_Grid.Visible:=False;
    pnl_Bottom.Visible:=False;
    Self.ClientHeight:=pnl_Buttons.Top + pnl_Buttons.Height;
//    Self.Height:=Self.ClientHeight + 15;
  end;

  BorderStyle:=bsDialog;
  PreventResize:=True;

  Result:=True;

end;

procedure TDlg_Vacancy.SetControlsVer;
begin
  Cth.SetControlsVerification(
    [
      cmb_Division,
      cmb_Job,
      cmb_Head,
      dedt_Dt,
      cmb_Status,
      nedt_Qnt,
      dedt_DtEnd,
      cmb_Reason
    ],
    ['1:400','1:400','0:400',
     '1',
     '1:400',
     '1:200:0',
     S.IIFStr(chb_Close.Checked, '1', ''),
     S.IIFStr(chb_Close.Checked, '1:400', '0:400:0:n')
    ]
  );
end;


procedure TDlg_Vacancy.SetControlsEnabled;
//доступность контролов
//в заголовке задисаблены, если стоит галка закрытия вакансии
var
  i:Integer;
  c: TVarDynArray;
  b: Boolean;
begin
  b:=not chb_Close.Checked and not (Mode in [fView, fDelete]);
  Cth.DlgSetControlsEnabled(Self, Mode, [], []);
  cmb_Division.Enabled:=b;
  cmb_Job.Enabled:=b;
  cmb_Head.Enabled:=b;
  cmb_Status.Enabled:=b;
  dedt_Dt.Enabled:=b;
  nedt_Qnt.Enabled:=b;
  nedt_QntOpen.Enabled:=False;
  Bt_Add.Enabled:=b;
  Bt_Edit.Enabled:=b;
  //дата и статус закрытия видны только при установке галки
  dedt_DtEnd.Visible:=chb_Close.Checked;
  cmb_Reason.Visible:=chb_Close.Checked;
end;


procedure TDlg_Vacancy.Verify(Sender: TObject; onInput: Boolean = False);
var
  i,j,s:Integer;
  c: TControl;
begin
  //я просмотра и удаления всегда Ок
  if (Mode = fView) or (Mode = fDelete)
    then begin
      Ok:=True;
      Bt_Ok.enabled := Ok;
      Exit;
    end;
//  Cth.VerifyControl(cmb_Status, False);
  if Sender = nil
    //проверим все DbEh
    then Cth.VerifyAllDbEhControls(Self)
    //проверим текущий
    else Cth.VerifyControl(TControl(Sender), onInput);
  //получим статус проверки и визуализируем
  Ok:=Cth.VerifyVisualise(Self);
  //статус кнопки Ок
  Bt_Ok.Enabled := Ok;
end;

procedure TDlg_Vacancy.ControlOnChange(Sender: TObject);
begin
  //выход если в процедуре загрузки
  if InPrepare then Exit;
  //проверим, признак что в этом событии проверка
  Verify(Sender, True);
end;

procedure TDlg_Vacancy.ControlOnExit(Sender: TObject);
var
  st: string;
begin
  //выход если в процедуре загрузки
  if InPrepare then Exit;
  //проверим
  Verify(Sender);
end;


procedure TDlg_Vacancy.DBGridEh1DblClick(Sender: TObject);
begin
  inherited;
  if Bt_Edit.Enabled then Bt_EditClick(nil);
end;

procedure TDlg_Vacancy.Bt_CancelClick(Sender: TObject);
begin
  inherited;
  Close;
end;


procedure TDlg_Vacancy.chb_CloseClick(Sender: TObject);
//клик на чекбоксе Вакансия снята
begin
  inherited;
  if InClose or InPrepare then Exit;
  InClose:=True;
  //если поставили галку, проверим все ли введено в режиме БЕЗ галки, и если не все то снимем
  if (chb_Close.Checked) then begin
    chb_Close.Checked:=False;
    SetControlsVer;
    if (not Ok) then begin
      MyWarningMessage('Не все данные по вакансии введены!');
    end
    else chb_Close.Checked:=True;
  end;
  SetControlsVer;
  SetControlsEnabled;
  Verify(nil);
  InClose:=False;
end;

procedure TDlg_Vacancy.ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean);
begin
  Cth.VerifyVisualise(Self);
end;

procedure TDlg_Vacancy.Bt_OkClick(Sender: TObject);
var
  NewID: Integer;
  b: Integer;
  v: Variant;
begin
  if (Mode = fView) then begin Close; Exit; end;
//v:=Cth.GetControlValue(cmb_Status);
  b:= Q.QIUD(Q.QFModeToIUD(Mode),
    'j_vacancy', 'sq_j_vacancy',
    'id$i;id_division$i;id_job$i;id_head$i;dt_beg$d;status$i;qnt$i;dt_end$d;reason$i;comm$s',
    VarArrayOf([
      ID,
      Cth.GetControlValue(cmb_Division),
      Cth.GetControlValue(cmb_Job),
      Cth.GetControlValue(cmb_Head),
      Cth.GetControlValue(dedt_Dt),
      Cth.GetControlValue(cmb_Status),
      Cth.GetControlValue(nedt_Qnt),
      S.IIfV(chb_Close.Checked, Cth.GetControlValue(dedt_DtEnd), null),
      S.IIfV(chb_Close.Checked, Cth.GetControlValue(cmb_Reason), null),
      mem_Comm.Text
    ])
  );
  if b = -1 then Exit;
  RefreshParentForm;
  Close;
end;

procedure TDlg_Vacancy.Bt_RefreshClick(Sender: TObject);
begin
  inherited;
  LoadGrid;
end;

procedure TDlg_Vacancy.SetGrid;
begin
  MemTableEh1.FieldDefs.Clear;
  Mth.AddTableColumn(DBGridEh1, 'id', ftInteger, 0, '_id', 20, False);
  Mth.AddTableColumn(DBGridEh1, 'name', ftString, 400, 'ФИО', 200, True);
  Mth.AddTableColumn(DBGridEh1, 'dt', ftDate, 0, 'Обращение', 50, True);
  Mth.AddTableColumn(DBGridEh1, 'statusfull', ftString, 400, 'Статус', 200, True);
  //создаем датасет
  MemTableEh1.CreateDataSet;
  //заполним поля из массива
  MemTableEh1.First;
{  for i := 0 to High(Data) do begin
    MemTableEh1.Last;
    MemTableEh1.Insert;
    for j:=0 to High(Data[i]) do
      MemTableEh1.Fields[j].Value := Data[i][j];
    MemTableEh1.Post;
  end;
  MemTableEh1.First;}

//  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh+[dghShowRecNo];
//  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh+[dghEnterAsTab];
//  DBGridEh1.ShowHint:=True;
//  Gh.SetGridOptionsTitleAppearance(DBGridEh1);
  Gh.SetGridOptionsDefault(DBGridEh1);
  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh-[dghColumnMove];
  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh-[dghColumnResize];
  DBGridEh1.ReadOnly:=True;
end;

procedure TDlg_Vacancy.LoadGrid;
begin
  Q.QLoadToMemTableEh('select id, name, dt, statusfull from v_j_candidates where id_vacancy = :id$i order by dt', [ID], MemTableEh1);
  MemTableEh1.First;
  if ID>0 then
    Cth.SetControlValue(nedt_QntOpen, Q.QSelectOneRow('select qntopen from v_j_vacancy where id = :id$i', [ID])[0]);
end;

procedure TDlg_Vacancy.Bt_AddClick(Sender: TObject);
begin
  inherited;
  Wh.ExecAdd(myfrm_Dlg_Candidate, Self, fAdd, -1, [], null, True);
//  if Wh.FormDialogResult = mrOk then LoadGrid; //++
end;

procedure TDlg_Vacancy.Bt_EditClick(Sender: TObject);
begin
  inherited;
  if MemTableEh1.RecNo <= 0 then Exit;
  Wh.ExecAdd(myfrm_Dlg_Candidate, Self, fEdit, MemTableEh1.FieldByName('id').Value, [], null, True);
//  if Wh.FormDialogResult = mrOk then LoadGrid;
end;

end.
