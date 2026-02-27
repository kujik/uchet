unit uFrmCDedtAccount;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, DBCtrlsEh, Math, Types,
  Vcl.Mask, Vcl.AppEvnts, Data.Bind.EngExt, Vcl.Bind.DBEngExt, Data.Bind.Components, Vcl.Buttons,
  uFrMyPanelCaption, uFrmBasicMdi, uFrmBasicDbDialog, uFrDBGridEh, uString, uData, uSys, uNamedArr
  ;

type
  TFrmCDedtAccount = class(TFrmBasicDbDialog)
    pnlGeneral: TPanel;
    pnlGeneralM: TPanel;
    cmb_type: TDBComboBoxEh;
    edt_account: TDBEditEh;
    cmb_id_supplier: TDBComboBoxEh;
    dedt_accountdt: TDBDateTimeEditEh;
    cmb_id_org: TDBComboBoxEh;
    cmb_id_user: TDBComboBoxEh;
    cmb_id_expenseitem: TDBComboBoxEh;
    nedt_sum: TDBNumberEditEh;
    nedt_SumWoNds: TDBNumberEditEh;
    frmpcGeneral: TFrMyPanelCaption;
    cmb_nds: TDBComboBoxEh;
    pnlRoute: TPanel;
    frmpcRoute: TFrMyPanelCaption;
    pnlBasis: TPanel;
    frmpcBasis: TFrMyPanelCaption;
    BindingsList1: TBindingsList;
    pnlPayments: TPanel;
    scrlbxPaymentsM: TScrollBox;
    pnlPaymentsD: TPanel;
    dedt_1: TDBDateTimeEditEh;
    nedt_1: TDBNumberEditEh;
    frmpcPayments: TFrMyPanelCaption;
    pnlAdd: TPanel;
    frmpcAdd: TFrMyPanelCaption;
    pnlAddM: TPanel;
    chb_Agreed2: TDBCheckBoxEh;
    chb_Agreed1: TDBCheckBoxEh;
    lbl1: TLabel;
    btnReqestFileOpen: TBitBtn;
    btnReqestFileAttach: TBitBtn;
    btnFileOpen: TBitBtn;
    btnFileAttach: TBitBtn;
    edt_comm: TDBEditEh;
    pnlRouteM: TPanel;
    chb_AccountFile: TDBCheckBoxEh;
    chb_RequestFile: TDBCheckBoxEh;
    tmr1: TTimer;
    ApplicationEvents1: TApplicationEvents;
    lbl_Info: TLabel;
    cmb_CarType: TDBComboBoxEh;
    cmb_FlightType: TDBComboBoxEh;
    dedt_FlightDt: TDBDateTimeEditEh;
    nedt_Kilometrage: TDBNumberEditEh;
    nedt_Idle: TDBNumberEditEh;
    nedt_OtherSum: TDBNumberEditEh;
    nedt_PriceIdle: TDBNumberEditEh;
    nedt_PriceKm: TDBNumberEditEh;
    pnlBasicM: TPanel;
    FrgRoute: TFrDBGridEh;
    FrgBasis: TFrDBGridEh;
    procedure FormResize(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure EdtPaymentKeyPress(Sender: TObject; var Key: Char);
  private
    FAccountType: Integer;
    FExpenseItemsAgreed: TVarDynArray2;
    FExpenseItemsNeedReceipt: TVarDynArray2;
    //счет оплачен (частично или полностью)
    FIsPaid: Boolean;
    //Можно редактировать только платежи
    FEdtPaymentsOnly: Boolean;
    //список платежей, которые были сформированы на момент открытия счета
    FPayments: TNamedArr;
    //маршрутные точки (локации) - свои, и для счетов ТО
    FPoints1, FPoints2: TVarDynArray;
    //режим редактирования всех данных, включается по Ctrl-Shift-E для DateEditor
    FAllEditMode: Boolean;
    //общая сумма платежей
    FPaymentsSum: Extended;
    function  Prepare: Boolean; override;
    procedure AfterFormActivate; override;
    procedure GlobalEvent(AEvent: Integer); override;
    function  Load: Boolean; override;
    function  LoadComboBoxes: Boolean; override;
    procedure ControlOnExit(Sender: TObject); override;
    procedure ControlOnEnter(Sender: TObject); override;
    procedure ControlOnChange(Sender: TObject); override;
    procedure EditButtonsClick(Sender: TObject; var Handled: Boolean); override;
    procedure btnClientClick(Sender: TObject); override;
    function  VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean; override;
    procedure VerifyBeforeSave; override;
    procedure EdtPaymentOnChaange(Sender: TObject);
    function  Save: Boolean; override;
    procedure FrgRouteButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
    procedure FrgRouteGetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
    procedure FrgRouteCellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
    procedure FrgBasisButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
    procedure LoadPayments;
    function  SavePayments: Boolean;
    function  SaveLocations: Boolean;
    function  SaveRoute: Boolean;
    function  SaveBasis: Boolean;
    procedure SetFormAppearance;
    procedure CreatePaymentsEdts;
    procedure CalculateNds;
    procedure LoadSuppliers;
    procedure ChooseSupplier;
    function  IsAgreed1Enabled: Boolean;
    procedure SetAgreed1(AChange: Boolean = True);
    function  IsFilesLoaded: Boolean;
    procedure AttachFiles(AMode: Boolean);
    procedure ViewFiles(AMode: Boolean);
    procedure SetEditable;
    function  TestAccountnumDuplicates: string;
    function  GetRemainingSum(Sender: TObject): Extended;
    procedure SetGrids;
  public
  end;

var
  FrmCDedtAccount: TFrmCDedtAccount;

implementation

uses
  ToolCtrlsEh,
  System.DateUtils,
  uForms,
  uDBOra,
  uMessages,
  uWindows,
  uFields,
  uFrmCWAcoountBasis
;


{$R *.dfm}

const
  cMaxPaymentsCnt = 5 * 12;
  cPaymentsCntSt = 5;

function TFrmCDedtAccount.Prepare: Boolean;
var
  Info: TVarDynArray2;
begin
  Result := False;

  //веременами форма уезжает. если в дизайнтайме раастянута широко, то может при запуске В РЕДАКТОРЕ ФОРМЫ схлопнуться,
  //при этом в программе съезжают элементы, управляемые якорями.
  //вроде все выравнивается если здесь установить ширину формы больше чем она в редакторе формы в дизайнтайме.
  Self.Width := 1116;

  FAccountType := AddParam.AsInteger;

  Caption := 'Счет';
  FOpt.RefreshParent := True;
  FOpt.DlgPanelStyle := dpsBottomRight;
  FOpt.StatusBarMode := stbmDialog;

  Cth.MakePanelsFlat(pnlFrmClient, []);

  Info := [['Основная информация по счету.']];
  frmpcGeneral.SetParameters(True, 'Основное', Info, False);
  Cth.AlignControls(pnlGeneralM, FOpt.ControlsWoAligment, True);
  pnlGeneral.Height := frmpcGeneral.Height + pnlGeneralM.Height;

  Info := [[
    'Данные для транспортных счетов.'#13#10+
    'Укажите тип транспортного средства, дату рейса и километраж.'#13#10+
    'В таблице задайте маршрут рейса.'#13#10+
    '(пункт назначения можно выбирать из выпадающего списка или вводить вручную; пункт отправки будет проставлен автоматически, кроме самой первой ячейки).'#13#10+
    'Если в таблице будут незаполненные ячейки, сохранить счет будет невозможно!'#13#10
  ]];
  frmpcRoute.SetParameters(True, 'Транспорт', Info, False);
  Cth.AlignControls(pnlRouteM, FOpt.ControlsWoAligment, True);

  Info := [[
    'Введите основания для счета.'#10#13+
    'Основанием может быть либо заказ, либо другой счет.'#10#13+
    'Для добавления основания нажмите кнопку слева от таблицы.'#10#13+
    'В открывшемся окне найдите нужный заказ либо счет, введите процент, и нажмите кнопку ">>>".'#10#13+
    'Если выбранное основание уже привязано на 100% к другому счету в этой же категории, то приязать его снова не получится!'#10#13+
    'Основание можно удалить из таблицы, нажав соответствующую кнопку.'#10#13+
    '(это также необходимо сделать в том случае, если вы ввели неверный процент, по-другому его изменить нельзя).'#10#13
  ]];
  frmpcBasis.SetParameters(True, 'Основание', Info, False);

  Info := [[
    'Распределите платежи по счету.'#10#13+
    'Редактировать можно только те платежи, которые не проведены.'#10#13+
    'Нажмите пробел в поле суммы, чтобы дополнить ее до суммы счета'#10#13+
    //'Нажмите "=" в поле даты, чтобы посмотреть запланированные платежи.'#10#13+
    'Для удаления платежа сотрите дату и сумму.'
  ]];
  frmpcPayments.SetParameters(True, 'Платежи', Info, False);
  CreatePaymentsEdts;

  Info := [[
    'Прикрепите к счету файл-документ счета и файлы заявки, нажав соответствующие кнопки.'#13#10+
    '(вы увидите информацию о том, загружены ли файлы, и что это необходимо сделать - будет подчеркнуто красным).'#13#10+
    'Также, по нажатию кнопок, можно просмотреть загруженные файлы.'#13#10+
    'Те пользователи, у которых есть соответствующие права, могут согласовать счет от имени руководителя или директора.'#13#10+
    'Также для счета можно ввести примечание.'
  ]];
  frmpcAdd.SetParameters(True, 'Дополнительно', Info, False);
  Cth.AlignControls(pnlAddM, FOpt.ControlsWoAligment, False);
  pnlAddM.Height := btnFileOpen.Top + btnFileOpen.Height + 4;
  pnlAdd.Height :=  frmpcAdd.Height + pnlAddM.Height;

  Cth.SetBtn(btnFileAttach, mybtAttach, True, 'Прикрепить файл счета');
  Cth.SetBtn(btnReqestFileAttach, mybtAttach, True, 'Прикрепить файл заявки');
  Cth.SetBtn(btnFileOpen, mybtView, True, 'Просмотреть файл счета');
  Cth.SetBtn(btnReqestFileOpen, mybtView, True, 'Просмотреть файл заявки');
//  Cth.SetBtn(Bt_RefreshSuppliers, mybtRefresh, True, 'Обновить список поставщиков');
//  Cth.SetBtn(Bt_SelectSupplier, mybtSelectFromList, True, 'Выбрать поставщика из списка');

  Cth.SetEditButtons(cmb_id_supplier, [[37, 'Обновить'], [39, 'Выбрать из справочника']]);

  F.DefineFields:=[
    ['id$i'],
    ['type$i'],
    ['accounttype$i','',#0,AddParam],
    ['account$s','V=1:400::T'],
    ['accountdt$d','V=:'],
    ['dt$d','V=:',#0,Date],
    ['id_supplier$i','V=1:400'],
    ['id_org$i','V=1:400'],
    ['id_expenseitem$i','V=1:400'],
    ['id_user$i','V=1:400',#0,User.GetId],
    ['sum$f','V=0:100000000:2:N'],       //!!! допутим ли 0
    ['nds$f','V=1:99'],
    ['comm$s','V:0:4000'],
    ['filename$s','',#0,FormatDateTime('yyyy-mm-dd hh.mm.ss.zzz', Now)],
    ['agreed1$i',''],
    ['agreed2$i',''],
    ['id_whoagreed1$i',''],
    ['accountfile;0;0','V=1:1'],
    //для транспортных счетов
    ['idt$i;0;0','V=','T=1'],
    ['cartype$i;0;0','V=1:400','T=1'],
    ['flighttype$i;0;0','V=1:400','T=1', #0, 2],
    ['flightdt$d;0;0','V=*','T=1'],
    ['kilometrage$f;0;0','V=0.5:100000:0','T=1'],  //может нен вводиться!!!
    //для транспортных с прямым видом рейса, сейчас не используем!!!
    ['idle$f;0;0','V=','T=1'],
    ['basissum$f;0;0','V=','T=1'],
    ['othersum$f;0;0','V=','T=1'],
    ['priceidle$f;0;0','V=','T=1'],
    ['pricekm$f;0;0','V=','T=1'],
    ['freeidletime$f;0;0','V=','T=1']
  ];

  View := 'sn_calendar_accounts';
  Table := 'sn_calendar_accounts';

  //буферизация, иначе тормозит ресайз, тк много контролов меняют размер
  Self.DoubleBuffered := True;

  FOpt.InfoArray := [
    ['Редактирование данных счета.'#13#10+
     ''#13#10+
     'Введите или измените данные в полях, доступных для ввода (в поля, закрашенные серым, вводить данные нельзя).'#13#10+
     'Данные, для которых введены недопустимые значения, будут подсвечены красным. Пока такие есть, счет сохранить нельзя!'#13#10+
     'Также, для некоторых видов счетов, должны быть заполнены табличные данные.'#13#10+
     'Обязательно нужно прикрепить файлы счета, и (не всегда обязательно) файлы заявки.'#13#10
    ,Mode in [fAdd, fEdit, fCopy]]
  ];

  //родительский метод
  Result := Inherited;
  if Result = False then
    Exit;


  if Mode <> fAdd then
    FAccountType := F.GetPropB('accounttype').AsInteger;
  CalculateNds;
  LoadPayments;
  SetGrids;
  SetAgreed1(False);
  IsFilesLoaded;
  SetEditable;
  SetFormAppearance;
end;

procedure TFrmCDedtAccount.AfterFormActivate;
begin
  nedt_SumWoNds.Right := edt_account.Right;
  cmb_id_supplier.SetRightKeepLeft(edt_account.Right);
  cmb_id_expenseitem.SetRightKeepLeft(edt_account.Right);
  SetFormAppearance;
end;

procedure TFrmCDedtAccount.GlobalEvent(AEvent: Integer);
begin
  if AEvent = 1 then begin
    if Mode in [fDelete, fView] then
      Exit;
    if not User.IsDataEditor then
      Exit;
    if MyQuestionMessage(S.IIf(FAllEditMode, 'Перейти в обычный режим?', 'Включить расширенный режим редактирования?')) <> mrYes then
      Exit;
    FAllEditMode := not FAllEditMode;
    SetEditable;
  end
  else if (AEvent = 2) and User.IsDeveloper then begin
    MyInfoMessage(Cth.GetControlValue(nedt_Kilometrage).AsString);
  end;
end;


function TFrmCDedtAccount.Load: Boolean;
var
  va2: TVarDynArray2;
begin
  Result := inherited;
  if not Result then
    Exit;
  if A.InArray(F.GetPropB('accounttype'), [1, 2]) then begin
    if Mode in [fEdit, fView, fDelete] then begin
      va2 := Q.QLoadToVarDynArray2(Q.QSIUDSql('s', 'sn_calendar_accounts_t', 'id$i;cartype$i;flighttype$i;flightdt;kilometrage;idle;basissum;othersum;priceidle;pricekm;freeidletime'), [ID]);
      F.SetPropsFromSelect(va2);
    end
    else begin
  //      MaxIdle:=Q.QSelectOneRow('select transport_maxidle from sn_calendar_cfg', [])[0];
    end;
  end;
end;


function TFrmCDedtAccount.LoadComboBoxes: Boolean;
//загрузка списков и других дополнительных данных
begin
  Result := False;
  LoadSuppliers;
  if User.Role(rPC_A_ChAll)
    then begin
      Q.QLoadToDBComboBoxEh('select name, id from ref_expenseitems where (accounttype = :accmode$i and active = 1) or id = :id_expenseitem$i order by name',
        [F.GetPropB('accounttype'), F.GetPropB('id_expenseitem')], cmb_id_expenseitem, cntComboLK);
      FExpenseItemsNeedReceipt := Q.QLoadToVarDynArray2('select recvreceipt, id from ref_expenseitems where (accounttype = :accmode$i and active = 1) or id = :id_expenseitem$i order by name',
        [F.GetPropB('accounttype'), F.GetPropB('id_expenseitem')]);
    end
    else begin
      //загрузим только статьи расходов, по которым можно редактировать (в итоге если открыть на редактирование счет не  по своей статье, то его не сохранить тк стаья будет пустая)
      Q.QLoadToDBComboBoxEh('select name, id from ref_expenseitems where (anyinstr(useravail, :id_user$i)=1 and accounttype = :accmode$i) or id = :id_expenseitem$i order by name',
        [User.GetId ,F.GetPropB('accounttype'), F.GetPropB('id_expenseitem')], cmb_id_expenseitem, cntComboLK);
      FExpenseItemsNeedReceipt := Q.QLoadToVarDynArray2('select recvreceipt, id from ref_expenseitems where (anyinstr(useravail, :id_user$i)=1 and accounttype = :accmode$i) or id = :id_expenseitem$i order by name',
        [User.GetId ,F.GetPropB('accounttype'), F.GetPropB('id_expenseitem')]);
    end;
  Q.QLoadToDBComboBoxEh(
    'select name, id from ref_sn_organizations where (active = 1 and is_buyer = 1) or id = :id$i order by name',
    [F.GetPropB('id_org')], cmb_id_org, cntComboLK
  );
  Q.QLoadToDBComboBoxEh('select name, id from adm_users order by name', [], cmb_id_user, cntComboLK);
  Cth.AddToComboBoxEh(cmb_nds, [['без НДС', '0'], ['5%','5'], ['7%','7'], ['10%','10'], ['20%','20'], ['22%','22']]);
  FExpenseItemsAgreed := Q.QLoadToVarDynArray2('select agreed, id from ref_expenseitems', []);

  if A.InArray(F.GetPropB('accounttype'), [1, 2]) then begin
    Q.QLoadToDBComboBoxEh('select name, id from ref_sn_cartypes where active = 1 or id = :id order by name', [F.GetPropB('cartype')], cmb_CarType, cntComboLK);
    Cth.AddToComboBoxEh(cmb_FlightType, [['Прямой', '1'], ['Фиксированный','2']]);
  if (Mode <> fView) and (Mode <> fDelete) then begin
      //свои локации и локации маршрута по типу счета
      FPoints1 := Q.QLoadToVarDynArrayOneCol('select name from ref_sn_locations where type = 0 and active = 1 order by name', []);
      FPoints2 := Q.QLoadToVarDynArrayOneCol('select name from ref_sn_locations where type = :type order by name', [F.GetPropB('accounttype')]);
    end;
  end;
  Result := True;
end;

function TFrmCDedtAccount.Save: Boolean;
//сохранение данных
begin
  Q.QBeginTrans(True);
  Result := inherited;
  Result := Result and SavePayments and SaveLocations and SaveRoute and SaveBasis;
  Q.QCommitOrRollback(Result);
end;

procedure TFrmCDedtAccount.FrgRouteButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  Handled := True;
  if Tag = mbtDelete then begin
    FrgRoute.DeleteRow;
    FrgRoute.SetState(True, null, null);
  end
  else if Tag = mbtAdd then begin
    FrgRoute.AddRow;
    FrgRoute.SetState(True, null, null);
  end
  else if Tag = mbtInsert then begin
    FrgRoute.InsertRow;
    FrgRoute.SetState(True, null, null);
  end
  else begin
    Handled := False;
    inherited;
  end;
end;

procedure TFrmCDedtAccount.FrgRouteGetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
  ReadOnly := (Cth.GetControlValue(cmb_flighttype) <> '2') or ((Fr.CurrField = 'point1') and (Fr.RecNo <> 1));
end;

procedure TFrmCDedtAccount.FrgRouteCellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
begin
  //установим статус что было изменение
  Fr.SetState(True, null, null);
  if FieldName = 'point1' then
    Exit;
  //установим при изменении ячеки Пункт назначения, если это не первая строка, ячейку Пункт отправки слева от введенной
  if Fr.RecNo > 1 then begin
    Fr.SetValue('point1', Fr.RecNo - 1, False, Fr.GetValue('point2', Fr.RecNo - 2, False));
  end;
  //установим при изменении ячеки Пункт назначения, ячейку Пункт отправки на следующей строке
  if (Fr.RecNo < Fr.GetCount(False)) then begin
    Fr.SetValue('point1', Fr.RecNo, False, Fr.GetValue('point2', Fr.RecNo - 1, False));
  end;
  //проверим на ошибки - ошибка, если хоть одна ячейка пустая, или вообще нет маршрута (пустой грид)
   Fr.SetState(null, Fr.GetCount(False) = 0, null);
  for var i := 0 to Fr.GetCount(False) - 1 do
    if (Fr.GetValueS('point1', i, False) = '') or (Fr.GetValueS('point2', i, False) = '') then begin
      Fr.SetState(null, True, null);
      Break;
    end;
end;

procedure TFrmCDedtAccount.FrgBasisButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  Handled := True;
  if Tag = mbtDelete then begin
    FrgBasis.DeleteRow;
    FrgBasis.SetState(True, null, null);
  end
  else if Tag = mbtAdd then begin
    FrmCWAcoountBasis.ShowDialog(Self, ID, fAdd, FAccountType);
  end
  else begin
    Handled := False;
    inherited;
  end;
end;


procedure TFrmCDedtAccount.ControlOnEnter(Sender: TObject);
begin

end;

procedure TFrmCDedtAccount.ControlOnExit(Sender: TObject);
begin

end;

procedure TFrmCDedtAccount.ControlOnChange(Sender: TObject);
var
  Name: string;
begin
  Name := LowerCase(TControl(Sender).Name);
  if Sender = chb_Agreed1 then
    SetAgreed1(True);
  if Sender = cmb_id_expenseitem then begin
    chb_Agreed1.Enabled := IsAgreed1Enabled;
    if not chb_Agreed1.Enabled then
      chb_Agreed1.Checked := False;
  end;
  if (Name = 'cmb_nds') or (Name = 'nedt_sum') then
    CalculateNds;
  if ((Pos('dedt_', Name) = 1) or (Pos('nedt_', Name) = 1)) and  S.IsNumber(Copy(Name, 6, 2), 1, 99)  then
    EdtPaymentOnChaange(Sender);
  if (Name = 'chb_accountfile') or  (Name = 'chb_requestfile') then
    TDBCheckBoxEh(Sender).Checked := Pos(' не ', TDBCheckBoxEh(Sender).Caption) = 0;
  if Name = 'nedt_sum' then
    EdtPaymentOnChaange(nil);
end;

procedure TFrmCDedtAccount.EditButtonsClick(Sender: TObject; var Handled: Boolean);
var
  Name: string;
begin
  if (TEditButtonControlEh(Sender).Owner = cmb_id_supplier) and (TEditButtonControlEh(Sender).ButtonImages.NormalIndex = 37) then
    LoadSuppliers;
  if (TEditButtonControlEh(Sender).Owner = cmb_id_supplier) and (TEditButtonControlEh(Sender).ButtonImages.NormalIndex = 39) then
    ChooseSupplier;
end;

procedure TFrmCDedtAccount.btnClientClick(Sender: TObject);
begin
  if Sender = btnFileAttach then
    AttachFiles(True);
  if Sender = btnReqestFileAttach then
    AttachFiles(False);
  if Sender = btnFileOpen then
    ViewFiles(True);
  if Sender = btnReqestFileOpen then
    ViewFiles(False);
end;

function TFrmCDedtAccount.VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean;
//дополнительная проверка
//нужна для ввода сумм и дат оплаты, так как:
//при вводе значения контрола, для которого не установлены правила проверки (и которого нет в Props), он все равно проверяется при вводе, по кранйе мере очищается маркер,
//где это происходит, не выяснил!!!
//однако, даже в этом решении, работает для сумм, но не работает для даты, при вводе правильной даты очищается все равно
begin
  //нет общщей ошибки
  Result := False;
  if Sender <> nil then begin
    if ((Pos('dedt_', TControl(Sender).Name) = 1) or (Pos('nedt_', TControl(Sender).Name) = 1)) and  S.IsNumber(Copy(TControl(Sender).Name, 6, 2), 1, 99)  then
      //ддесь выставляются маркеры ошибки, а также отображение контролов
      EdtPaymentOnChaange(Sender);
  end;
end;

procedure TFrmCDedtAccount.VerifyBeforeSave;
begin
  FErrorMessage := TestAccountnumDuplicates;
end;

procedure TFrmCDedtAccount.LoadPayments;
//загружаем список платежей по заказу в поле класса и сразу же в поля редактирования на форме. установим признак наличия проведенных платежей
var
  i: Integer;
begin
  EdtPaymentOnChaange(nil);
  if Mode in [fAdd, fCopy] then
    Exit;
  Q.QLoadFromQuery('select id, dt, sum, status from sn_calendar_payments where id_account = :id$i order by status desc, dt, sum', [ID], FPayments);
  FIsPaid := False;
  for i := 0 to FPayments.High do begin
    Cth.SetControlValue(Self, 'dedt_' + IntToStr(i + 1), FPayments.G(i, 'dt'));
    Cth.SetControlValue(Self, 'nedt_' + IntToStr(i + 1), FPayments.G(i, 'sum'));
    if (Mode in [fEdit]) and (FPayments.G(i, 'status') = 1) then begin
      FIsPaid := True;
      SetControlsEditable([TControl(FindComponent('dedt_' + IntToStr(i + 1))), TControl(FindComponent('nedt_' + IntToStr(i + 1)))], False);
    end;
  end;
  EdtPaymentOnChaange(nil);
end;

function TFrmCDedtAccount.SavePayments: Boolean;
//сохраним платежи по счету
//меняем только те кторые изменились (айди привязан к позиции в сетке), если сумма пуситая или 0 то удаляем
//при копировании - все добавляем в новый счет
var
  i, j: Integer;
  dt, sum : Variant;
begin
  Result := False;
  for i := 0 to cMaxPaymentsCnt - 1 do begin
    dt := Cth.GetControlValue(Self, 'dedt_' + IntToStr(i + 1));
    sum := Cth.GetControlValue(Self, 'nedt_' + IntToStr(i + 1));
    if i <= S.IIf(Mode <> fCopy, FPayments.High, -1) then begin
      if sum.AsFloat = 0 then
        Q.QExecSQL('delete from sn_calendar_payments where id  = :id$i', [FPayments.G(i, 'id')])
      else if (sum <> FPayments.G(i, 'sum')) or (dt <> FPayments.G(i, 'dt')) then
        Q.QExecSQL('update sn_calendar_payments set dt = :dt$d, sum = :sum$f where id = :id$i', [FPayments.G(i, 'dt'), dt, sum]);
    end
    else begin
      Q.QExecSQL('insert into sn_calendar_payments (id_account, dt, sum, status) values (:id_account$i, :dt$d, :sum$f, 0)', [ID, dt, sum]);
    end;
  end;
  Result := True;
end;

function TFrmCDedtAccount.SaveLocations: Boolean;
//сохраним локации
var
  st: string;
  i: Integer;
begin
  Result := True;
  //только для транспортных счетов, если грид маршрута не пустой и в нем были изменения
  if (Mode = fDelete) or not (FAccountType in [1, 2]) or not FrgRoute.IsDataChanged or (FrgRoute.GetCount(False) = 0) then
    Exit;
  Result := False;
  //сохраним первую ячекй грида в качестве наименования производственной площадки
  st := FrgRoute.GetValueS('point1', 1, False);
  if not A.InArray(st, FPoints1) then
    Q.QIUD('i', 'ref_sn_locations', 'sq_ref_sn_locations', 'id;name;type;active', [0, st, 0, 1], False);
  //сохраним ячейки из столбца Пункт назначения в таблице локаций, соотвественно типу счета
  for i := 0 to FrgRoute.GetCount(False) - 1 do begin
    st := FrgRoute.GetValueS('point2', i, False);
    if not A.InArray(st, FPoints2) then
      Q.QIUD('i', 'ref_sn_locations', 'sq_ref_sn_locations', 'id;name;type;active', [0, st, FAccountType, 1], False);
  end;
  Result := True;
end;

function TFrmCDedtAccount.SaveRoute: Boolean;
//сохраним маршрут и основные данные транспортного счета
var
  i: Integer;
begin
var va :=GetControlValues([cmb_CarType, cmb_FlightType, dedt_FlightDt, nedt_Kilometrage], True);
  Result := True;
  if (Mode = fDelete) or not (FAccountType in [1, 2]) then
    Exit;
  Result := False;
  //сохраним значения основных параметров из полей ввода
  Q.QIUD(Q.QFModeToIUD(Mode), 'sn_calendar_accounts_t', '-', 'id;cartype$i;flighttype$i;flightdt$d;kilometrage$f',   //;idle$f;basissum$f;othersum$f;pricekm$f;priceidle$f;freeidletime$f
    [ID] + GetControlValues([cmb_CarType, cmb_FlightType, dedt_FlightDt, nedt_Kilometrage], True)
  );
  if FrgRoute.IsDataChanged then begin
    //перезапишем маршрут из грида
    if (Mode <> fAdd) and (Mode <> fCopy) then
      Q.QExecSQL('delete from sn_calendar_t_route where id_account = :id_account$i', [ID]);
    for i := 0 to FrgRoute.GetCount(False) - 1 do begin
      var st1 := FrgRoute.GetValueS('point1', i, False);
      var st2 := FrgRoute.GetValueS('point2', i, False);
      Q.QExecSQL(
        'insert into sn_calendar_t_route (id_account, pos, point1, point2, dt1, dt2, kilometrage) '+
        'values (:id_account, :pos, '+
        'nvl('+
          '(select id from ref_sn_locations where name = :point1 and type = :accmode1), '+
          '(select id from ref_sn_locations where name = :point11 and type = 0)), '+
        'nvl('+
          '(select id from ref_sn_locations where name = :point2 and type = :accmode2), '+
          '(select id from ref_sn_locations where name = :point21 and type = 0)), '+
        ':dt1$d, :dt2$d, :kilometrage$i)',
        [ID, i + 1, st1, FAccountType, st1, st2, FAccountType, st2, null, null, null]
      );
    end;
  end;
  Result := True;
end;

function TFrmCDedtAccount.SaveBasis: Boolean;
//сохраним данные по основаниям
var
  i: Integer;
begin
  Result := True;
  //только для транспортных и монтажных счетов, если были изменения в гриде
  if (Mode = fDelete) or not (FAccountType in [1, 2, 3]) or not FrgBasis.IsDataChanged then
    Exit;
  Result := False;
  if (Mode <> fAdd) and (Mode <> fCopy) then
    Q.QExecSQL('delete from sn_calendar_t_basis where id_account = :id_account$i', [ID]);
  for i := 0 to FrgBasis.GetCount(False) - 1 do begin
    Q.QExecSQL(
      'insert into sn_calendar_t_basis (id_account, pos, id_order, id_acc, sum_saved, prc) '+
      'values (:id_account, :pos, :id_order$i, :id_acc$i, :sum_saved, :prc)',
      [ID, i + 1, S.IIf(FrgBasis.GetValueS('type', i) = 'Заказ', FrgBasis.GetValueI('id_basis', i), null), S.IIf(FrgBasis.GetValueS('type', i) = 'Счет', FrgBasis.GetValueI('id_basis', i), null), FrgBasis.GetValueI('sum', i), FrgBasis.GetValueI('prc', i)]
    );
  end;
  Result := True;
end;

procedure TFrmCDedtAccount.SetFormAppearance;
var
  h : Integer;
begin
  pnlRoute.Visible := A.InArray(FAccountType, [1, 2]);      //маршрут, для транспортных
  pnlBasis.Visible := A.InArray(FAccountType, [1, 2, 3]);    //основания, для транспортных и монтажа
//  pnlRoute.Visible  := True; pnlBasis.Visible := True;

  pnlRoute.Height := 150;
  pnlBasis.Height := 150;
  pnlRoute.Top := pnlGeneral.Bottom + 1;
  pnlBasis.Top := pnlRoute.Bottom + 1;
  pnlPayments.Top := pnlBasis.Bottom + 1;
  pnlAdd.Top := pnlPayments.Bottom + 1;
  h := 1500; //pnlAdd.Top + pnlAdd.Height;
  FWHCorrected.Y := h;
  FWHCorrected.Y2 := h;
  //FWHBounds := FWHCorrected;   //ведет к блокировке изменения размера и неверному размеру
{ //возьмем размеры формы из настроек
  Self.Width:= StrtoInt(Settings.ReadProperty(FormDoc, 'Width_' + IntToStr(AccMode), '0'));
  Self.Height:= StrtoInt(Settings.ReadProperty(FormDoc, 'Height_' + IntToStr(AccMode), '0'));}
  Self.Height := h;
//  Self.Resize;
end;

procedure TFrmCDedtAccount.tmr1Timer(Sender: TObject);
begin
  inherited;
  //UnLockDrawing;
end;

procedure TFrmCDedtAccount.CreatePaymentsEdts;
//создадим контролы для ввода платежей (метки, даты и суммы)
var
  i, j: Integer;
  dedt1: TDBDateTimeEditEh;
  nedt1: TDBNumberEditEh;
  w: Integer;
begin
  pnlPaymentsD.Visible := False;
  w := nedt_1.Left + nedt_1.Width + 15;
  for i := 1 to cMaxPaymentsCnt div cPaymentsCntSt  do
    for j := S.IIf(i = 1, 2, 1) to cPaymentsCntSt do begin
      dedt1 := TDBDateTimeEditEh.Create(Self);
      dedt1.Parent := pnlPaymentsD;
      dedt1.Name := 'dedt_' + IntToStr((i - 1) * cPaymentsCntSt + j);
      dedt1.Visible := (i = 1) and (j = 1);
      dedt1.Left := (j - 1) * w  + dedt_1.Left;
      dedt1.Width := dedt_1.Width;
      dedt1.Top := (i - 1) * (dedt_1.Height + 4) + dedt_1.Top;
      dedt1.ControlLabelLocation.Position := lpLeftCenterEh;
      dedt1.ControlLabel.Visible := True;
      dedt1.ControlLabel.Caption := IntToStr((i - 1) * cPaymentsCntSt + j);
      nedt1 := TDBNumberEditEh.Create(Self);
      nedt1.Parent := pnlPaymentsD;
      nedt1.OnKeyPress := EdtPaymentKeyPress;
      nedt1.Name := 'nedt_' + IntToStr((i - 1) * cPaymentsCntSt + j);
      nedt1.Visible := (i = 1) and (j = 1);
      nedt1.Left := (j - 1) * w  + nedt_1.Left;
      nedt1.Width := nedt_1.Width;
      nedt1.Top := dedt1.Top;
    end;
  pnlPaymentsD.Visible := True;
end;

procedure TFrmCDedtAccount.EdtPaymentOnChaange(Sender: TObject);
var
  i, j, t: Integer;
  HasEmpty: Boolean;
begin
  //if not FInPrepare then
    //Perform(WM_SETREDRAW, 0, 0);
  try
  i := cMaxPaymentsCnt;
  while (i > 1) and not TControl(FindComponent('dedt_' + IntToStr(i))).Visible do
    dec(i);
  t := TControl(FindComponent('dedt_' + IntToStr(i))).Top;
  FPaymentsSum:= 0;
  //очистим ошибку у всех контролов
  for i := 1 to cMaxPaymentsCnt do begin
    Cth.SetErrorMarker(TControl(FindComponent('dedt_' + IntToStr(i))), False);
    Cth.SetErrorMarker(TControl(FindComponent('nedt_' + IntToStr(i))), False);
  end;
  i := cMaxPaymentsCnt;
  while (i > 1) and ((GetControlValue('dedt_' + IntToStr(i), True) = null) and (GetControlValue('nedt_' + IntToStr(i), True) = null)) do
    dec(i);
  HasEmpty := False;
  for j := i downto 1 do  begin
    FPaymentsSum := FPaymentsSum + GetControlValue('nedt_' + IntToStr(j)).AsFloat;
    if (GetControlValue('dedt_' + IntToStr(j), True) = null) and (GetControlValue('nedt_' + IntToStr(j), True) = null) then begin
       HasEmpty := True;
    end
    //поставим ошибку и подсветим если заполено дата, а сумма пустая, или наоборот
    else if (GetControlValue('dedt_' + IntToStr(j), True) <> null) and (GetControlValue('nedt_' + IntToStr(j), True) = null) then begin
      Cth.SetErrorMarker(TControl(FindComponent('nedt_' + IntToStr(j))), True);
    end
    else if (GetControlValue('dedt_' + IntToStr(j), True) = null) and (GetControlValue('nedt_' + IntToStr(j), True) <> null) then begin
      Cth.SetErrorMarker(TControl(FindComponent('dedt_' + IntToStr(j))), True);
    end;
  end;
  //отобразим все контролы с первого до последнего введенного
  for j := 1 to i do begin
    TControl(FindComponent('dedt_' + IntToStr(j))).Visible := True;
    TControl(FindComponent('nedt_' + IntToStr(j))).Visible := True;
  end;
  //покажем пустое поле ввода после введенныых данных
  if not (Mode in [fView, fDelete]) then
    if (not HasEmpty) and (i < cMaxPaymentsCnt) then begin
      TControl(FindComponent('dedt_' + IntToStr(i + 1))).Visible := True;
      TControl(FindComponent('nedt_' + IntToStr(i + 1))).Visible := True;
    end;
  i := cMaxPaymentsCnt;
  while (i > 1) and not TControl(FindComponent('dedt_' + IntToStr(i))).Visible do
    dec(i);
  //подсветим последнее заполеннное поле суммы, если общая сумма не равна итоговой по счету
  for j := i downto 1 do
    if (GetControlValue('nedt_' + IntToStr(j), True) <> null) or (j = 1) then begin
      if FPaymentsSum <> GetControlValue('nedt_sum').AsFloat then begin
        Cth.SetErrorMarker(TControl(FindComponent('nedt_' + IntToStr(j))), True);
        Cth.SetErrorMarker(TControl(FindComponent('dedt_' + IntToStr(j))), True);
      end;
      Break;
    end;
  finally
    if not FInPrepare then begin
      //Perform(WM_SETREDRAW, 1, 0);
    //  Invalidate;
    end;
  end;
  if (t <> TControl(FindComponent('dedt_' + IntToStr(i))).Top) or (FInPrepare) then begin
    t := TControl(FindComponent('dedt_' + IntToStr(i))).Top + TControl(FindComponent('dedt_' + IntToStr(i))).Height + 8;
    pnlPaymentsD.Height := t;
    scrlbxPaymentsM.Height := t + 4;
{
    if pnlPaymentsD.Height <> TControl(FindComponent('nedt_' + IntToStr(i + 0))).Top + TControl(FindComponent('nedt_' + IntToStr(i + 0))).Height + 8 then
      pnlPaymentsD.Height := TControl(FindComponent('nedt_' + IntToStr(i + 0))).Top + TControl(FindComponent('nedt_' + IntToStr(i + 0))).Height + 8;
    scrlbxPaymentsM.Height := pnlPaymentsD.Height + 4;

    if scrlbxPaymentsM.Height <> Min(pnlPaymentsD.Height + 4, (dedt_1.Height + 4) * 3 + 4 + 4) then
      scrlbxPaymentsM.Height := Min(pnlPaymentsD.Height + 4, (dedt_1.Height + 4) * 3 + 4 + 4);}
    if pnlPayments.Height <> frmpcPayments.Height + scrlbxPaymentsM.Height then
    begin
      pnlPayments.Height := frmpcPayments.Height + scrlbxPaymentsM.Height;
      FormResize(nil);
    end;
  end;
end;

procedure TFrmCDedtAccount.EdtPaymentKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = ' ' then begin
    GetRemainingSum(Sender);
    Key := #0;
  end;
end;

procedure TFrmCDedtAccount.FormResize(Sender: TObject);
begin
  ClientHeight := pnlAdd.Top + pnlAdd.Height + pnlFrmBtnsMain.Height + 30;
end;

procedure TFrmCDedtAccount.CalculateNds;
begin
  //Сумма без НДС = Сумма с НДС / (1 + Ставка_НДС_в_процентах / 100)? ,анковское округление
  nedt_SumWoNds.Value := RoundTo(nedt_Sum.Value.AsFloat / (1 + cmb_Nds.Value.AsFloat / 100), -2);
end;

procedure TFrmCDedtAccount.LoadSuppliers;
begin
  Q.QLoadToDBComboBoxEh('select legalname, id from ref_suppliers where active = 1 or id = :id$i order by legalname', [F.GetPropB('id_supplier')], cmb_id_supplier, cntComboLK);
end;

procedure TFrmCDedtAccount.ChooseSupplier;
//откроем справочник поставщиков в диалоговомрежиме, с установкой позиции в нем = текущему поставщику
begin
  Wh.SelectDialogResult := [];
  Wh.ExecReference(myfrm_R_Suppliers_SELCH, Self, [myfoDialog, myfoModal, myfoSizeable], cmb_id_supplier.Value);
  if Length(Wh.SelectDialogResult) = 0 then
    Exit;
  //перечитаем список поставщиков, так как в справочнике разрешено добавление и редактирование
  Q.QLoadToDBComboBoxEh('select legalname, id from ref_suppliers where active = 1 or id = :id order by legalname', [cmb_id_supplier.Value], cmb_id_supplier, cntComboLK);
  //установим выбранного в справочнике
  cmb_id_supplier.Text := Wh.SelectDialogResult[1];
end;

function TFrmCDedtAccount.IsAgreed1Enabled: Boolean;
//когда может быть согласовано руководителем
begin
  Result := False;
  if Cth.GetControlValue(cmb_id_ExpenseItem) = null then
    Exit;
  //может, если:
  //в любом случае IsDataEditor, иначе только когда не согласован директором, при праве rPC_A_AgrAll для люой или праве rPC_A_AgrSelfCat для своей (есть пользователь в поле Кто согласовывает для категории) категории
  Result:=
    (User.IsDataEditor) or ((not chb_Agreed2.Checked) and
      (User.Roles([], [rPC_A_AgrAll]) or User.Roles([], [rPC_A_AgrSelfCat]) and (S.InCommaStr(IntToStr(User.GetId), FExpenseItemsAgreed[A.PosInArray(Cth.GetControlValue(cmb_id_ExpenseItem), FExpenseItemsAgreed, 1)][0]))));
end;

procedure TFrmCDedtAccount.SetAgreed1(AChange: Boolean = True);
//установит заголовок чекбокаса Согласован руководителем
//если AChange, то установит данные в зависимости от занчения чекбокса
begin
  if AChange then  begin
    F.SetProp('id_whoagreed1', S.IIf(chb_Agreed1.Checked, User.GetId, null));
    chb_Agreed1.Caption := S.IIf(chb_Agreed1.Checked, User.GetName, 'Руководитель');
  end
  else
    chb_Agreed1.Caption := S.IIfStr(F.GetProp('id_whoagreed1') <> null, Q.QSelectOneRow('select name from adm_users where id = :id$i', [F.GetProp('id_whoagreed1')])[0].AsString, 'Руководитель');
end;

function TFrmCDedtAccount.IsFilesLoaded: Boolean;
//проверимм, загружены ли файлы для счета и заявки по счету
//в качестве маркера загруженности установим значение соответсвующего чекбокса
//в качестве маркера ошибки, если требуется загрузка, установим его подчеркивание крачсным (маркер ошибки)
var
  a: TStringDynArray;
  b1, b2: Boolean;
begin
  a := Sys.GetFileInDirectoryOnly(Module.GetPath_Accounts_A(F.GetProp('filename')));
  chb_AccountFile.Checked := Length(a) > 0;
  chb_AccountFile.Caption := 'Файл счета ' + S.IIf(chb_AccountFile.Checked, 'загружен', 'не загружен');
  Cth.SetErrorMarker(chb_AccountFile, not chb_AccountFile.Checked);
  a := Sys.GetFileInDirectoryOnly(Module.GetPath_Accounts_Z(F.GetProp('filename')));
  chb_RequestFile.Checked := Length(a) > 0;
  chb_RequestFile.Caption := 'Файл заявки ' + S.IIf(chb_AccountFile.Checked, 'загружен', 'не загружен');
  Cth.SetErrorMarker(chb_RequestFile, (not chb_AccountFile.Checked) and (nedt_sum.Value > Module.GetCfgVar(mycfgPCsum_need_req)));
end;

procedure TFrmCDedtAccount.AttachFiles(AMode: Boolean);
//выбираем файлы и копируем их в папку на сервере
//режим Труе = счет, Фолс = заявка
var
  SPath, ZPath: string;
  i: Integer;
begin
  MyData.OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist];
  if not MyData.OpenDialog1.Execute then
    Exit;
  try
    for i := 0 to MyData.OpenDialog1.Files.Count - 1 do begin
      if FileExists(MyData.OpenDialog1.Files[i]) then begin
        SPath := Module.GetPath_Accounts_A(F.GetPropB('filename'));
        ZPath := Module.GetPath_Accounts_Z(F.GetPropB('filename'));
        ForceDirectories(SPath);
        ForceDirectories(ZPath);
        CopyFile(PChar(MyData.OpenDialog1.Files[i]), PChar(s.IIFStr(AMode, SPath, ZPath) + '\' + ExtractFileName(MyData.OpenDialog1.Files[i])), True);
      end
      else
        MyWarningMessage('Файл не найден!');
    end;
  finally
    IsFilesLoaded;
  end;
end;

procedure TFrmCDedtAccount.ViewFiles(AMode: Boolean);
begin
  if AMode then
    Sys.OpenFileOrDirectory(Module.GetPath_Accounts_A(F.GetPropB('filename')), 'Файл счета не найден!')
  else
    Sys.OpenFileOrDirectory(Module.GetPath_Accounts_Z(F.GetPropB('filename')), 'Файл заявки не найден!');
end;

procedure TFrmCDedtAccount.SetEditable;
//заблокирем ввод данных, кроме распределения платежей (не проведённые платежи изменить нельзя!),
//в случае, если по счету есть проведенные платежи, или он согласован диретором, либо руководителем
//(в последнем случае исключение - редактирует тот кто может согласовывать его для этой статьи расходов)
//также, разрешается редактирование для DataEditor
var
  st: string;
begin
  lbl_Info.Caption := '';
  if Mode in [fDelete, fView] then
    Exit;
  //сообщение о причинах блокировки, оно же маркер
  st := a.Implode([s.IIfStr((F.GetProp('agreed1').AsInteger = 1) and not IsAgreed1Enabled, 'руководителем'), s.IIfStr(F.GetProp('agreed2').AsInteger = 1, 'деректором')], ' и ', True);
  st := a.Implode([S.IIFStr(st <> '', 'согласован ' + st), s.IIfStr(FIsPaid, '(частично) оплачен')], ' и ', True);
  //выведем сообщение
  if st <> '' then
    lbl_Info.Caption := 'Счет ' + st + '!' + S.IIFStr(not FAllEditMode, #13#10'Возможно только редактирование запланированных платежей!');
  //поле - признак блокировки
  FEdtPaymentsOnly := (st <> '') and not FAllEditMode;      //!!!
  //делаем контролы ридонли
  SetControlsEditable([], not FEdtPaymentsOnly, False, pnlGeneral);
  SetControlsEditable([btnFileAttach, btnReqestFileAttach, edt_comm], not FEdtPaymentsOnly, False, pnlAdd);
  btnFileAttach.Enabled := not FEdtPaymentsOnly;
  btnReqestFileAttach.Enabled := not FEdtPaymentsOnly;
  chb_Agreed1.Enabled := IsAgreed1Enabled and not FEdtPaymentsOnly;
  chb_Agreed2.Enabled := User.Role(rPC_A_AgrDir) and not FEdtPaymentsOnly;
  //эти ридонли всегда
  SetControlsEditable([cmb_id_user, nedt_SumWoNds, cmb_flighttype], False, False, pnlFrmClient);
  //для транспортных счетов типа Прямой, не используем и скроем
  nedt_PriceKm.Visible := False;
  nedt_PriceIdle.Visible := False;
  nedt_OtherSum.Visible := False;
  nedt_Idle.Visible := False;
  pnlRouteM.Height := 32;
  //если счета не транспортные, отключим проверку
  if not (FAccountType in [1, 2]) then
    Cth.SetControlsVerification([cmb_CarType, cmb_FlightType, dedt_FlightDt], ['', '', '']);
end;

function TFrmCDedtAccount.TestAccountnumDuplicates: string;
//проверим чтобы не было другого счета у того же поставщика с таким же номером при том же годе, взятом из даты выставления счета
begin
  Result := '';
  if (Cth.GetControlValue(edt_Account) = '') or (Mode = fDelete) then
    Exit;
  if Q.QSelectOneRow('select account from sn_calendar_accounts where id_supplier = :id_supplier and id <> :id and account = :account and extract (year from accountdt) = :year$i',
    [Cth.GetControlValue(cmb_id_Supplier), s.IIfInt(Mode = fEdit, ID, -1000), edt_Account.Text, YearOf(s.IIfV(Cth.DteValueIsDate(edt_Account), dedt_AccountDt.Value, Date))])[0] = null then
    Exit;
  Result := '?Счет с таким же номером у этого поставщика уже есть.'#13#10'Нажнажмите "Да" чтобы сохранить данные, или "Нет" чтобы продолжить редактирование.';
end;

function TFrmCDedtAccount.GetRemainingSum(Sender: TObject): Extended;
//простави недостающую сумму в поле суммы платежа, в котором нажали пробел
//общая сумма считается при заполнении этих контролов
begin
  if nedt_sum.Value.AsString = '' then
    Exit;
  Result := nedt_sum.Value.AsFloat - FPaymentsSum - (Sender as TDBNumberEditEh).Value.AsFloat;
  (Sender as TDBNumberEditEh).Value := Result;
end;

procedure TFrmCDedtAccount.SetGrids;
//установи вид гридов маршрута и основания счета
//внимание!!! колонки (в везде - логика) для прямого рейсап исключены!!! для старых счетов этого формата не будут отображаться дополнительные данные по нему, и невозможно редактирование!!!
begin
//  if A.InArray(F.GetPropB('accounttype'), [1, 2, 3]) then begin
    FrgRoute.Opt.Caption := 'Маршрут';
    FrgRoute.Opt.Caption := '~';
    FrgRoute.Options := [myogGrayTitle, myogIndicatorColumn, myogHiglightEditableCells, myogHasStatusBar];
    FrgRoute.Opt.SetFields([
      ['point1$s','Пункт отправки','100;w', 'e'],
  //    ['dt1$d','Дата и время убытия','110'],
      ['point2$s','Пункт назначения','100;w', 'e']
  //    ['dt2$d','Дата и время прибытия','110'],
  //    ['kilometrage$i','Расстояние, км','60'],
  //    ['idle$f','Время простоя','50']
    ]);
    FrgRoute.Opt.SetButtons(-3, 'aid', True, cbttSSmall);
    FrgRoute.Opt.SetGridOperations('uaid');
  //  FrgRoute.SetInitData('select (select name from ref_sn_locations where id=point1) as point1, dt1 , (select name from ref_sn_locations where id=point2) as point2, dt2, kilometrage, null as idle from sn_calendar_t_route where id_account=:id order by pos', [ID]);
    FrgRoute.SetInitData([]);
    if not (Mode in [fAdd, fCopy]) and A.InArray(F.GetPropB('accounttype'), [1, 2]) then
      FrgRoute.SetInitData('select (select name from ref_sn_locations where id=point1) as point1, (select name from ref_sn_locations where id=point2) as point2 from sn_calendar_t_route where id_account=:id order by pos', [ID]);
    FrgRoute.Prepare;
    if (Mode <> fView) and (Mode <> fDelete) then begin
      //свои локации и локации маршрута по типу счета
      FrgRoute.Opt.SetPick('point1', FPoints1 + FPoints2, [], False, True);
      FrgRoute.Opt.SetPick('point2', FPoints1 + FPoints2, [], False, True);
      FrgRoute.SetColumnsPropertyes;
    end;
    FrgRoute.RefreshGrid;
    FrgRoute.First;
    FrgRoute.OnButtonClick := FrgRouteButtonClick;
    FrgRoute.OnGetCellReadOnly := FrgRouteGetCellReadOnly;
    FrgRoute.OnCellValueSave := FrgRouteCellValueSave;
//  end;

//  if A.InArray(F.GetPropB('accounttype'), [1, 2, 3]) then begin
    FrgBasis.Opt.Caption := 'Основание';
    FrgBasis.Opt.Caption := '~';
    FrgBasis.Options := [myogGrayTitle, myogIndicatorColumn, myogHasStatusBar];
    FrgBasis.Opt.SetFields([
      ['id_basis$i','_id','60'],
      ['type$s','Тип','60'],
      ['name$s','Основание','200;w'],
      ['prc$i','%','60'],
      ['sum$f','Сумма','60','f=r:r']
    ]);
    FrgBasis.Opt.SetButtons(-3, 'ad', True, cbttSSmall);
    FrgBasis.Opt.SetGridOperations('uad');
    FrgBasis.SetInitData([]);
    if not (Mode in [fAdd, fCopy]) and A.InArray(F.GetPropB('accounttype'), [1, 2, 3]) then
      FrgBasis.SetInitData('select id_basis, type, name, prc, sum from v_sn_calendar_t_basis where id_account=:id order by pos', [ID]);
    FrgBasis.Prepare;
    FrgBasis.RefreshGrid;
    FrgBasis.First;
    FrgBasis.OnButtonClick := FrgBasisButtonClick;
//  end;

    FrgRoute.SetState(False, A.InArray(F.GetPropB('accounttype'), [1, 2]) and (FrgRoute.GetCount(False) = 0), null);
    FrgBasis.SetState(False, False, null);

end;

end.
