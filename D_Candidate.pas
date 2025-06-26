unit D_Candidate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Math,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, Mask, uData, uForms, uDBOra, uString, uMessages, System.Types,
  Vcl.ExtCtrls, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, MemTableDataEh, MemTableEh,
  Data.DB, Vcl.Menus, uSettings, Vcl.Imaging.pngimage, V_MDI, Vcl.ComCtrls
  ;

type
  TDlg_Candidate = class(TForm_MDI)
    Gb_Candidate: TGroupBox;
    E_F: TDBEditEh;
    De_Birth: TDBDateTimeEditEh;
    E_I: TDBEditEh;
    E_Phone: TDBEditEh;
    E_O: TDBEditEh;
    Lb_History: TLabel;
    Gb_Vacancy: TGroupBox;
    P_Vacancy: TPanel;
    Cb_Division: TDBComboBoxEh;
    Cb_Job: TDBComboBoxEh;
    Cb_Head: TDBComboBoxEh;
    Gb_Status: TGroupBox;
    De_Dt: TDBDateTimeEditEh;
    De_Pr: TDBDateTimeEditEh;
    De_Uv: TDBDateTimeEditEh;
    Cb_Status: TDBComboBoxEh;
    Gb_Comment: TGroupBox;
    P_Comment: TPanel;
    M_Comment: TMemo;
    P_Buttons: TPanel;
    Bt_Ok: TBitBtn;
    Bt_Cancel: TBitBtn;
    Lb_StatusError: TLabel;
    Cb_Ad: TDBComboBoxEh;
    Img_Info: TImage;
    Bt_SelectAd: TBitBtn;
    Cb_Vacancy: TDBComboBoxEh;
    Lb_VClosed: TLabel;
    Lb_Dt1: TLabel;
    Lb_Dt2: TLabel;
    Bt_AddWorker: TBitBtn;
    procedure Cb_VacancyChange(Sender: TObject);
    procedure ControlOnChange(Sender: TObject);
    procedure ControlOnExit(Sender: TObject);
    procedure ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean);
    procedure Bt_OkClick(Sender: TObject);
    procedure Bt_CancelClick(Sender: TObject);
    procedure Bt_SelectAdClick(Sender: TObject);
    procedure Lb_HistoryClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Bt_AddWorkerClick(Sender: TObject);
  private
    { Private declarations }
    aControls: array of TControl;
    LastName: string;
    CandidateInfo: TVarDynArray2;
    Ok: Boolean;
    OkStatus: Boolean;
    OkPressed: Boolean;
    function  Prepare: Boolean; override;
    procedure GetCandidateInfo;
    procedure SetStatus;
    procedure Verify(Sender: TObject; onInput: Boolean = False);
  public
    { Public declarations }
    constructor ShowDialog(aOwner: TComponent; aFormDoc: string; aMode: TDialogType; aID: Variant; AMyFormOptions: TMyFormOptions; aAccMode: Variant);
  end;

var
  Dlg_Candidate: TDlg_Candidate;

implementation

{$R *.dfm}

uses
  uWindows,
  D_Grid1
  ;


constructor TDlg_Candidate.ShowDialog(aOwner: TComponent; aFormDoc: string; aMode: TDialogType; aID: Variant; AMyFormOptions: TMyFormOptions; aAccMode: Variant);
begin
  inherited Create(aOwner, aFormDoc, AMyFormOptions + [myfoDialog], aMode, aID, null);
//inherited Create(aOwner, aFormDoc, 0, aMode, aID, [myfoDialog], null);
//  if aAccMode = null then aAccMode:=0;
//AccMode:=aAccMode;
end;


procedure TDlg_Candidate.Cb_VacancyChange(Sender: TObject);
//смена вакансии
var
  v: TVarDynArray;
begin
  inherited;
  //при загрузке меняем тошлько при прямом вызове - чтобы проставить данные, вызываем явно в препаре с нил
  if (InPrepare)and(Sender <> nil) then Exit;
  if Cb_Vacancy.ItemIndex <= 0 then begin
    Cb_Division.Text:='';
    Cb_Division.LimitTextToListValues:=True;
    Cb_Division.Enabled:=True;
    Cb_Job.Text:='';
    Cb_Job.LimitTextToListValues:=True;
    Cb_Job.Enabled:=True;
    Cb_Head.Text:='';
    Cb_Head.LimitTextToListValues:=True;
    Cb_Head.Enabled:=True;
  end
  else begin
    Cb_Division.LimitTextToListValues:=False;
    Cb_Division.Text:=Q.QSelectOneRow('select divisionname from v_j_vacancy where id = :id$i', [StrToInt(Cb_Vacancy.Value)])[0];
    Cb_Division.Enabled:=False;
    Cb_Job.LimitTextToListValues:=False;
    Cb_Job.Text:=Q.QSelectOneRow('select job from v_j_vacancy where id = :id$i', [StrToInt(Cb_Vacancy.Value)])[0];
    Cb_Job.Enabled:=False;
    Cb_Head.LimitTextToListValues:=False;
    Cb_Head.Text:=Q.QSelectOneRow('select headname from v_j_vacancy where id = :id$i', [StrToInt(Cb_Vacancy.Value)])[0];
    Cb_Head.Enabled:=False;
  end;
end;

function TDlg_Candidate.Prepare: Boolean;
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
//  if Self.FormStyle = fsNormal then Wh.ModalResult:=mrNone;
  if FormDbLock = fNone then Exit;

  aControls:=[
    E_F, E_I, E_O,
    De_Birth,
    E_Phone,
    Cb_Ad,
    //статус
    De_Dt,
//    Chb_Pr,
    De_Pr,
 //   Chb_Uv,
    De_Uv,
    Cb_Status,
    M_Comment,
    Cb_Vacancy,
    Cb_Division,
    Cb_Job,
    Cb_Head
  ];

  //вакансии
  Q.QLoadToDBComboBoxEh(
    'select caption1 || ''  -  '' || job, id from v_j_vacancy where dt_end is null or id = (select id_vacancy from j_candidates where id = :id$i) order by caption1',
    [ID], Cb_Vacancy, cntComboLK0);
  //подразделения
  Q.QLoadToDBComboBoxEh('select name, id from ref_divisions order by name', [], Cb_Division, cntComboLK0);
  //профессии
  Q.QLoadToDBComboBoxEh('select name, id from ref_jobs order by name',[], Cb_Job, cntComboLK0);
  //работники  v_j_worker_status
  //!!!неправильно, если подтягивается вакансия, а руководитель, в ней прописанный, уже не работает!!!
  Q.QLoadToDBComboBoxEh(
//    'select workername, id from v_j_worker_status where status <> 3 or id = (select id_head from v_j_candidates where id = :id$i) order by workername',
    'select workername, max(id_worker) from v_j_worker_status where status <> 3 or id_worker = (select id_head from v_j_candidates where id = :id$i) group by workername order by workername',
    [ID], Cb_Head, cntComboLK0);
  //статусы
  Q.QLoadToDBComboBoxEh('select name, id from ref_candidates_status where id >= 10 order by name', [], Cb_Status, cntComboLK);
  //источники информации
  Q.QLoadToDBComboBoxEh('select name, id from ref_candidates_ad order by name', [], Cb_Ad, cntComboLK);
  //получим данные из основной таблицы
//  FieldNames:='id$i;f$s;i$s;o$s;dt_birth$d;phone$s;id_ad$i;dt$d;0,dt1$d;0,dt2$d;id_status$i;comm$s;id_vacancy$i;id_division;id_job;id_head;vacancyclosed';
  FieldNames:='id$i;f$s;i$s;o$s;dt_birth$d;phone$s;id_ad$i;dt$d;dt1$d;dt2$d;id_status$i;comm$s;id_vacancy$i;id_division;id_job;id_head;vacancyclosed';
  FieldNamesCp:='id$i;f$s;i$s;o$s;dt_birth$d;phone$s';
  //дефолтные значения полей
  v:=VarArrayOf([
    -1,
    '','','',  //фио
    null,  //birth
    '',  //телефон
    null,  //ссылка     6

    Date,  //дата обращения   #7
    null, null, //прием-увольнение
    null,  //ид-статус    10
    '',  //коммент
    0,  //айди вакансии
    0, 0, 0,  //айди подразделения, профессии, руководителя
    null   //вакансия закрыта       16
     ]);
  //загрузим существующие, если это не добавление записи
  if Mode <> fAdd
    then begin
      if Mode = fCopy then begin
        //для операции копирования читаем только личную информацию
        vc:=Q.QSelectOneRow(Q.QSIUDSql('s', 'v_j_candidates', FieldNamesCp), [ID]);
        //если не удалось получить то выйдем с сообщением что строка удалена
        if vc[0] = null then begin MsgRecordIsDeleted; Exit; end;
        for i:=1 to High(vc) do v[i]:=vc[i];
      end
      else begin
        v:=Q.QSelectOneRow(Q.QSIUDSql('s', 'v_j_candidates', FieldNames), [ID]);
        //если не удалось получить то выйдем с сообщением что строка удалена
        if v[0] = null then begin MsgRecordIsDeleted; Exit; end;
      end;
    end;
  //сбросим айди, тк он используется при поиске более раннихз записей по тем же фио
  if Mode in [fAdd, fCopy] then ID:= -1;

   //события onCahange и  onExit для всех dbeh контролов
  Cth.SetControlsOnChange(Self, ControlOnChange);
  Cth.SetControlsOnExit(Self, ControlOnExit);
  Cth.SetControlsOnCheckDrawRequired(Self, ControlCheckDrawRequiredState);
  //параметры проверки контролов
  Cth.SetControlsVerification(
    [E_F, E_I, E_O,
     De_Birth,
     E_Phone,
     Cb_Ad,
     De_Dt,
     Cb_Status
    ],
    ['1:25:0:T','1:25:0:T','0:25:0:T',
     '1',
     '1:400:0:T',
     '1:200:0',
     '1',
     '0:200:0:n'
    ]
  );



  //галки принят/уволен
 // v[8] := v[9] <> null;
 // v[10] := v[11] <> null;
  for i:=0 to High(aControls) do begin
    Cth.SetControlValue(aControls[i], v[i+1]);
  end;

  //проставим данные по подразделению и профессии из вакансии
  if Cb_Vacancy.ItemIndex > 0 then Cb_VacancyChange(nil);

  Cth.SetDialogForm(Self, Mode, 'Соискатель.');
  Cth.SetBtn(Bt_SelectAd, mybtSelectFromList, True, 'Справочник источников информации о вакансии.');
  Cth.SetBtn(Bt_AddWorker, mybtAdd, True, 'Добавить/принять работника.');


  Cth.DlgSetControlsEnabled(Self, Mode, [], []);

  //если пришел по закрытой вакансии, то в режете редактирования не дадим менять вакансию и статусы, кроме возможности увольнения
  if (Mode = fEdit) and (v[16] <> null) then begin
    Lb_VClosed.Visible:=True;
    Cb_Division.Enabled:=False;
    Cb_Job.Enabled:=False;
    Cb_Head.Enabled:=False;
    Cb_Vacancy.Enabled:=False;
    De_Dt.Enabled:=False;
    De_Pr.Enabled:=False;
    Cb_Status.Enabled:=False;
  end;

  Bt_AddWorker.Visible:= not(Mode in [fDelete, fView]);

  Verify(nil);

  Info:=
  'Ввод данных по соискателю.'#13#10+
  ''#13#10+
  'Соискатель:'#13#10+
  'Заполните все поля (только поле Отчество не обязательно.)'#13#10+
  'По мере ввода данных будет показано, сколько уж было обращения от лиц с таким же ФИО (и, если заполнено, д/р)'#13#10+
  'Для просмотра этой информации кликните на соответствующую ссылку.'#13#10+
  ''#13#10+
  'Вакансия:'#13#10+
  'Вы можете выбрать вакансию, на которую претендует соискатель, из списка открытых сейчас вакансий.'#13#10+
  'В этом случае соискатель будет привязан к данной вакансии, поля "Подразделение", "Профессия", "Ответственный" будут'#13#10+
  'заполнены из данной вакансии без возможности их изменения.'#13#10+
  'Или же можете оставить поле "Вакансия" пустым, и выбрать остальные поля вручную (в этом случае они не обязательны для ввода).'#13#10+
  ''#13#10+
  'Статус:'#13#10+
  'Отображает статус соискателя.'#13#10+
  'Необходимо заполнить дату обращения, при создании тут будет текущая дата.'#13#10+
  'Если кандидат не принят на работу, можно выбрать статус из списка,'#13#10+
  'Или же можно проставить дату приема (но не ранее даты обращения).'#13#10+
  'В дальнейшем, если работник будет уволен, можно проставить дату увольнения (тоже не больше даты приема на работу).'#13#10+
  ''#13#10+
  'Комментарий:'#13#10+
  'Заполните комментарий к данной позиции в журнале соискателей (не обязательно).'#13#10+
  'В обязательном порядке выберите из списка источники информации соискателя о вакансии.'#13#10+
  'Для того чтобы создать новый элемент данного справочники, нажмите кнопку справа.'#13#10+
  ''#13#10+
  'Нажмите кнопку "+", чтобы создать работника на основании данных соискателя, и внести данные в журнал статусов работника.'#13#10+
  ''#13#10
  ;
  if Mode in [fView, fDelete] then Info:='';
  Cth.SetInfoIcon(Img_Info, Info, 20);
  BorderStyle:=bsDialog;
  PreventResize:=True;
  GetCandidateInfo;
  Verify(nil);

  Result:=True;

  //!!!
  Lb_VClosed.Visible:=False;
end;

procedure TDlg_Candidate.ControlOnChange(Sender: TObject);
begin
  if Sender = Cb_Vacancy then Cb_VacancyChange(Sender);
  //выход если в процедуре загрузки
  if InPrepare then Exit;
  //проверим, признак что в этом событии проверка
  Verify(Sender, True);
end;

procedure TDlg_Candidate.ControlOnExit(Sender: TObject);
var
  st: string;
begin
  //выход если в процедуре загрузки
  if InPrepare then Exit;
  //проверим
  Verify(Sender);
  st:=E_F.Text + '|' + E_I.Text + '|' + E_O.Text + '|' + De_Birth.Text;
  if st <> LastName then begin
    LastName:= st;
    GetCandidateInfo;
  end;
end;

procedure TDlg_Candidate.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  if Self.FormStyle = fsNormal then begin
{    if Self.ModalResult = mrOk
      then Wh.SelectDialogResult:=[1]
      else Wh.SelectDialogResult:=[0];}//++
  end;
end;

procedure TDlg_Candidate.ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean);
begin
  Cth.VerifyVisualise(Self);
end;

procedure TDlg_Candidate.GetCandidateInfo;
var
  st: string;
  param: TVarDynArray;
  sql: TvarDynArray;
begin
  if (E_F.Text = '') or (E_I.Text = '') then begin
    Lb_History.Visible := False;
  end
  else begin
    Param:= VarArrayOf([ID, E_F.Text, E_I.Text, E_O.Text, De_Birth.Value]);
    sql:=['id<>:id$i', 'lower(f)=lower(:f$s)', 'lower(i)=lower(:i$s)', 'lower(o)=lower(:o$s)', 'dt_birth=:d$d'];
    if not(Cth.DteValueIsDate(De_Birth)) then SetLength(Param, 4);
    if (E_O.Text = '')and(not(Cth.DteValueIsDate(De_Birth))) then SetLength(Param, 3);
    SetLength(Sql, Length(Param));
    st:=A.Implode(sql, ' and ');
    CandidateInfo:=Q.QLoadToVarDynArray2(
      'select name, dt_birth, dt, job, statusfull, comm from v_j_candidates where ' + st + ' order by dt asc',
      Param
    );
    Lb_History.Caption:=
      S.IIFStr(Length(CandidateInfo) = 0, 'Обращений не было.', 'Было ' + IntToStr(Length(CandidateInfo)) + ' обращени' + S.GetEnding(Length(CandidateInfo), 'е', 'я', 'й') + '.');
    Lb_History.Visible := True;
    if Length(CandidateInfo) > 0 then begin
      Lb_History.Font.Color:=clBlue;
      Lb_History.Font.Style:=[fsUnderline];
    end
    else begin
      Lb_History.Font.Color:=clBlack;
      Lb_History.Font.Style:=[];
    end;
  end;
end;

procedure TDlg_Candidate.Lb_HistoryClick(Sender: TObject);
begin
  inherited;
//  'select name, dt_birth, dt, job, statusfull, comm from v_j_candidates where ' + st + ' order by dt asc',
  if Length(CandidateInfo) = 0 then Exit;
  Dlg_Grid1.ShowDialog('Обращения', 950, 160,
    [
      ['name', ftString, 400, 'ФИО', 180, True],
      ['dt_birth', ftDate, 0, 'Д/р', 50, True],
      ['dt', ftDate, 0, 'Обращение', 50, True],
      ['job', ftString, 400, 'Профессия', 160, True],
      ['statusfull', ftString, 100, 'Статус', 200, True],
      ['comm', ftString, 4000, 'Комментарий', 300, True]
    ],
    CandidateInfo
  );
end;

//проверка правлильн6ости данных
//передается контрол для проверки, или нил - проверить все
//и признак что проверка при вводе данных в контроле (в событии onChange)
procedure TDlg_Candidate.Verify(Sender: TObject; onInput: Boolean = False);
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
  //проверим данные по статусу и отобразим
  SetStatus;
//  Cth.VerifyControl(Cb_Status, False);
  if Sender = nil
    //проверим все DbEh
    then Cth.VerifyAllDbEhControls(Self)
    //проверим текущий
    else Cth.VerifyControl(TControl(Sender), onInput);
  //получим статус проверки и визуализируем
  Ok:=Cth.VerifyVisualise(Self) and OkStatus;
  //статус кнопки Ок
  Bt_Ok.Enabled := Ok;
end;

procedure TDlg_Candidate.SetStatus;
begin
  Cb_Status.Visible:=not((Cth.DteValueIsDate(De_Pr))or(Cth.DteValueIsDate(De_Uv)));
//  Cth.SetControlsVerification([Cb_Status], [S.IIFStr(Cth.DteValueIsDate(De_Dt), '0:200:0:n', '0:200:0')]);
  OkStatus:=(
    Cth.DteValueIsDate(De_Dt) and (
      (not((Cth.DteValueIsDate(De_Pr))or(Cth.DteValueIsDate(De_Uv))) and (Cb_Status.ItemIndex >=0))
      or
      (Cth.DteValueIsDate(De_Pr)and(De_Pr.Value >= De_Dt.Value)and(not Cth.DteValueIsDate(De_Uv)))
      or
      ((Cth.DteValueIsDate(De_Pr)and(De_Pr.Value >= De_Dt.Value)and(Cth.DteValueIsDate(De_Uv))and(De_Uv.Value >= De_Pr.Value)))
      )
    );
  Lb_StatusError.Visible:= not OkStatus;
end;

procedure TDlg_Candidate.Bt_CancelClick(Sender: TObject);
begin
  inherited;
  Close;
end;

procedure TDlg_Candidate.Bt_OkClick(Sender: TObject);
var
  NewID: Integer;
  b: Integer;
  v: Variant;
begin
  if (Mode = fView) then begin Close; Exit; end;
//v:=Cth.GetControlValue(Cb_Status);
  b:= Q.QIUD(Q.QFModeToIUD(Mode),
    'j_candidates', 'sq_j_candidates', 'id$i;f$s;i$s;o$s;dt_birth$d;phone$s;id_ad$i;dt$d;dt1$d;dt2$d;id_status$i;comm$s;id_vacancy$i;id_division$i;id_job$i;id_head$i',
    VarArrayOf([
      ID,
      Cth.GetControlValue(E_F),
      Cth.GetControlValue(E_I),
      Cth.GetControlValue(E_O),
      Cth.GetControlValue(De_Birth),
      Cth.GetControlValue(E_Phone),
      Cth.GetControlValue(Cb_Ad),
      Cth.GetControlValue(De_Dt),
      Cth.GetControlValue(De_Pr),
      Cth.GetControlValue(De_Uv),
      S.IIfV(Cth.DteValueIsDate(De_Pr) or Cth.DteValueIsDate(De_Uv), null, Cth.GetControlValue(Cb_Status)),
      M_Comment.Text,
      S.IIfV(Cb_Vacancy.ItemIndex <= 0, null,  Cth.GetControlValue(Cb_Vacancy)),
      S.IIfV((Cb_Vacancy.ItemIndex > 0)or(Cb_Division.ItemIndex <= 0), null,  Cth.GetControlValue(Cb_Division)),
      S.IIfV((Cb_Vacancy.ItemIndex > 0)or(Cb_Job.ItemIndex <= 0), null,  Cth.GetControlValue(Cb_Job)),
      S.IIfV((Cb_Vacancy.ItemIndex > 0)or(Cb_Head.ItemIndex <= 0), null,  Cth.GetControlValue(Cb_Head))
    ])
  );
  if b = -1 then Exit;
  RefreshParentForm;
  //признак, что вышли по кнопке Ок, для мди-формы передача через ModalResult не получилась
  //этот флаг проверяем в OnClose и ставим флаг в FE
//  OkPressed:=True;
//  Bt_Ok.ModalResult:=mrOk;
//  Self.ModalResult:=mrOk;
  FormDialogResult:=mrOk;
  Close;
end;


procedure TDlg_Candidate.Bt_SelectAdClick(Sender: TObject);
//кнопка вызова справочники источников информации
begin
{  Wh.SelectDialogResult:=[];
  Wh.ExecMDIForm(myfrm_R_Candidates_Ad_SELCH, True);
  if Length(Wh.SelectDialogResult) = 0 then Exit;
  try
  Q.QLoadToDBComboBoxEh('select name, id from ref_candidates_ad order by name', [], Cb_Ad, cntComboLK);
  Cb_Ad.Text:=Wh.SelectDialogResult[1];
  finally
  end;}//++
end;

procedure TDlg_Candidate.Bt_AddWorkerClick(Sender: TObject);
begin
  inherited;
  if (E_F.Text ='') or (E_I.Text = '') then Exit;
  if Q.QSelectOneRow('select count(id) from ref_workers where f=:f$s and i=:i$s and o=:o$s', [E_F.Text, E_I.Text, E_O.Text])[0] = 0 then
    if MyQuestionMessage('Создать работника "' + E_F.Text + ' ' + E_I.Text + ' ' + E_O.Text + '"') = mrYes then begin
      Q.QIUD(
        'i',
        'ref_workers',
        'sq_ref_workers',
        'id;f;i;o;active',
        [null, E_F.Text, E_I.Text, E_O.Text, 1]
      );
    end
    else Exit;
  Wh.ExecAdd(myfrm_Dlg_WorkerStatus, Self, fAdd, 0, [],
    VarArrayOf([
      E_F.Text + ' ' + E_I.Text + ' ' + E_O.Text,
      Cb_Division.Text,
      Cb_Job.Text,
      S.IIfV(Cth.DteValueIsDate(De_Uv), De_Uv.Value, S.IIfV(Cth.DteValueIsDate(De_Pr), De_Pr.Value, null))
      ]),
    True
  );
end;

end.
