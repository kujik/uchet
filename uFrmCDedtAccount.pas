unit uFrmCDedtAccount;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh, Math, Types,
  uFrMyPanelCaption, uFrmBasicMdi, uFrmBasicDbDialog, uData, uFrDBGridEh, uSys,
  Data.Bind.EngExt, Vcl.Bind.DBEngExt, Data.Bind.Components, Vcl.Buttons
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
    FrgRoute: TFrDBGridEh;
    pnlBasis: TPanel;
    frmpcBasis: TFrMyPanelCaption;
    FrgBasis: TFrDBGridEh;
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
    cmb_CarType: TDBComboBoxEh;
    cmb_Flight: TDBComboBoxEh;
    nedt_Kilometrage: TDBNumberEditEh;
    dedt_FlightDt: TDBDateTimeEditEh;
    nedt_Idle: TDBNumberEditEh;
    nedt_PriceKm: TDBNumberEditEh;
    nedt_PriceIdle: TDBNumberEditEh;
    nedt_SumOther: TDBNumberEditEh;
    chb_AccountFile: TDBCheckBoxEh;
    chb_RequestFile: TDBCheckBoxEh;
  private
    function  Prepare: Boolean; override;
    function  LoadComboBoxes: Boolean; override;
    procedure ControlOnExit(Sender: TObject); override;
    procedure ControlOnEnter(Sender: TObject); override;
    procedure ControlOnChange(Sender: TObject); override;
    procedure EdtPaymentOnChaange(Sender: TObject);
    function  Save: Boolean; override;
    function IsFilesLoaded: Boolean;

    procedure CreatePaymentsEdts;
  public
  end;

var
  FrmCDedtAccount: TFrmCDedtAccount;

implementation

uses
  uForms,
  uDBOra,
  uString,
  uMessages,
  uFields,
  uTasks
;


{$R *.dfm}

procedure TFrmCDedtAccount.CreatePaymentsEdts;
var
  i, j: Integer;
  dedt1: TDBDateTimeEditEh;
  nedt1: TDBNumberEditEh;
  w: Integer;
begin
  pnlPaymentsD.Visible := False;
  w := nedt_1.Left + nedt_1.Width + 25;
  for i := 1 to 10 do
    for j := S.IIf(i = 1, 2, 1) to 3 do begin
      dedt1 := TDBDateTimeEditEh.Create(Self);
      dedt1.Parent := pnlPaymentsD;
      dedt1.Name := 'dedt_' + IntToStr((i - 1) * 3 + j);
      dedt1.Visible := (i = 1) and (j = 1);
      dedt1.Left := (j - 1) * w  + dedt_1.Left;
      dedt1.Width := dedt_1.Width;
      dedt1.Top := (i - 1) * (dedt_1.Height + 4) + dedt_1.Top;
      dedt1.ControlLabelLocation.Position := lpLeftCenterEh;
      dedt1.ControlLabel.Visible := True;
      dedt1.ControlLabel.Caption := IntToStr((i - 1) * 3 + j);
      nedt1 := TDBNumberEditEh.Create(Self);
      nedt1.Parent := pnlPaymentsD;
      nedt1.Name := 'nedt_' + IntToStr((i - 1) * 3 + j);
      nedt1.Visible := (i = 1) and (j = 1);
      nedt1.Left := (j - 1) * w  + nedt_1.Left;
      nedt1.Width := nedt_1.Width;
      nedt1.Top := dedt1.Top;
    end;
  pnlPaymentsD.Visible := True;
end;

procedure TFrmCDedtAccount.EdtPaymentOnChaange(Sender: TObject);
var
  i, j: Integer;
  b: Boolean;
begin
  i := 30;
  while (i > 1) and ((GetControlValue('dedt_' + IntToStr(i), True) = null) and (GetControlValue('nedt_' + IntToStr(i), True) = null)) do
    dec(i);
  b := False;
  for j := i downto 1 do
    if (GetControlValue('dedt_' + IntToStr(j), True) = null) and (GetControlValue('nedt_' + IntToStr(j), True) = null) then begin
       b := True;
       Break;
    end;
  if (not b) and (i < 30) then begin
    TControl(FindComponent('dedt_' + IntToStr(i + 1))).Visible := True;
    TControl(FindComponent('nedt_' + IntToStr(i + 1))).Visible := True;
  end;
  i := 30;
  while (i > 1) and not TControl(FindComponent('dedt_' + IntToStr(i))).Visible do
    dec(i);
  pnlPaymentsD.Height := TControl(FindComponent('nedt_' + IntToStr(i))).Top + TControl(FindComponent('nedt_' + IntToStr(i))).Height + 8;
  scrlbxPaymentsM.Height := Min(pnlPaymentsD.Height + 4, (dedt_1.Height + 4) * 3 + 4 + 4);
  pnlPayments.Height := frmpcPayments.Height + scrlbxPaymentsM.Height;
end;



function TFrmCDedtAccount.Prepare: Boolean;
begin
  Result := False;

  Caption := 'Счет';
  FOpt.RefreshParent := True;
  FOpt.DlgPanelStyle := dpsBottomRight;
  FOpt.StatusBarMode := stbmDialog;

  Cth.MakePanelsFlat(pnlFrmClient, []);

  //FWHCorrected := Cth.AlignControls(pnlFrmClient, FOpt.ControlsWoAligment, False);

  frmpcGeneral.SetParameters(True, 'Основное', [['Данные счета.']], True);
  Cth.AlignControls(pnlGeneralM, FOpt.ControlsWoAligment, True);
  pnlGeneral.Height := frmpcGeneral.Height + pnlGeneralM.Height;

  frmpcRoute.SetParameters(True, 'Транспорт', [['1']], False);
  Cth.AlignControls(pnlRouteM, FOpt.ControlsWoAligment, True);

  frmpcBasis.SetParameters(True, 'Основание', [['1']], False);

  frmpcPayments.SetParameters(True, 'Платежи', [['1']], False);
  CreatePaymentsEdts;

  frmpcAdd.SetParameters(True, 'Дополнительно', [], False);
  Cth.AlignControls(pnlAddM, FOpt.ControlsWoAligment, False);

  Cth.SetBtn(btnFileAttach, mybtAttach, True, 'Прикрепить файл счета');
  Cth.SetBtn(btnReqestFileAttach, mybtAttach, True, 'Прикрепить файл заявки');
  Cth.SetBtn(btnFileOpen, mybtView, True, 'Просмотреть файл счета');
  Cth.SetBtn(btnReqestFileOpen, mybtView, True, 'Просмотреть файл заявки');
//  Cth.SetBtn(Bt_RefreshSuppliers, mybtRefresh, True, 'Обновить список поставщиков');
//  Cth.SetBtn(Bt_SelectSupplier, mybtSelectFromList, True, 'Выбрать поставщика из списка');


  F.DefineFields:=[
    ['id$i'],
    ['type$i'],
    ['accounttype$i','V=1:400'],
    ['account$s','V=1:400::T'],
    ['accountdt$d','V=:'],
    ['dt$d','V=:',#0,Date],
    ['id_supplier$i','V=1:400'],
    ['id_org$i','V=1:400'],
    ['id_expenseitem$i','V=1:400'],
    ['id_user$i','V=1:400',#0,User.GetId],
    ['sum$f','V=0:10000000000:2:N'],
    ['nds$f','V=0:99:2:N'],
    ['comm$s','V:0:4000'],
    ['filename$s','',#0,FormatDateTime('yyyy-mm-dd hh.mm.ss.zzz', Now)],
    ['agreed1$i',''],
    ['agreed2$i',''],
    ['id_whoagreed1$i',''],
    ['accountfile;0;0','V=1:1']
  ];

  View := 'sn_calendar_accounts';
  Table := 'sn_calendar_accounts';


  //pnlGeneralT.BevelEdges := [beTop];

{ // FOpt.AutoAlignControls := True;

  //проверим блокировку, выйдем если нельзя взять (при попытке редактирования уйдет в просмотр, при удалении - выход)
  if FormDbLock = fNone then
    Exit;


  Cth.MakePanelsFlat(pnlFrmClient, []);
  F.PrepareDefineFieldsAdd;
  if Table = '' then
    Table := View;
  if Mode <> fAdd then
    if not Load then
      Exit;
  //загрузим комбобоксы и сделаем другие кастомные действия
//  if not LoadComboBoxes then
//    Exit;
  F.SetPropsControls;
  SetControlsEditable([], Mode in [fEdit, fCopy, fAdd]);      }
  Result := Inherited;
  IsFilesLoaded;
  SetControlsEditable([cmb_id_user{, chb_AccountFile, chb_RequestFile}], False);
end;

function TFrmCDedtAccount.LoadComboBoxes: Boolean;
begin
  Result := False;
  Q.QLoadToDBComboBoxEh('select legalname, id from ref_suppliers where active = 1 or id = :id$i order by legalname', [F.GetPropB('id_supplier')], cmb_id_supplier, cntComboLK);
  //Q.QLoadToTStringList('select agreed, id from ref_expenseitems', [], ExpAgreed);
  if User.Role(rPC_A_ChAll)
    then begin
      Q.QLoadToDBComboBoxEh('select name, id from ref_expenseitems where (accounttype = :accmode$i and active = 1) or id = :id_expenseitem$i order by name',
        [F.GetPropB('accounttype'), F.GetPropB('id_expenseitem')], cmb_id_expenseitem, cntComboLK);
{      Q.QLoadToDBComboBoxEh('select recvreceipt, id from ref_expenseitems where (accounttype = :accmode$i and active = 1) or id = :id_expenseitem$i order by name',
        [F.GetPropB('accounttype'), F.GetPropB('id_expenseitem'], cmb_RecReceipt, cntComboLK);}
    end
    else begin
      //загрузим только статьи расходов, по которым можно редактировать (в итоге если открыть на редактирование счет не  по своей статье, то его не сохранить тк стаья будет пустая)
      Q.QLoadToDBComboBoxEh('select name, id from ref_expenseitems where (anyinstr(useravail, :id_user$i)=1 and accounttype = :accmode$i) or id = :id_expenseitem$i order by name',
        [User.GetId ,F.GetPropB('accounttype'), F.GetPropB('id_expenseitem')], cmb_id_expenseitem, cntComboLK);
{      Q.QLoadToDBComboBoxEh('select recvreceipt, id from ref_expenseitems where (anyinstr(useravail, :id_user$i)=1 and accounttype = :accmode$i) or id = :id_expenseitem$i order by name',
        [User.GetId, AccMode, v[5]], cmb_RecReceipt, cntComboLK);}
    end;
  Q.QLoadToDBComboBoxEh(
    'select name, id from ref_sn_organizations where (active = 1 and is_buyer = 1) or id = :id$i order by name',
    [F.GetPropB('id_org')], cmb_id_org, cntComboLK
  );
  Q.QLoadToDBComboBoxEh('select name, id from adm_users order by name', [], cmb_id_user, cntComboLK);
  Cth.AddToComboBoxEh(cmb_nds, [['без НДС', '0'], ['5%','5'], ['7%','7'], ['10%','10'], ['20%','20'], ['22%','22']]);
  Result := True;
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
  if ((Pos('dedt_', Name) = 1) or (Pos('nedt_', Name) = 1)) and  S.IsNumber(Copy(Name, 6, 2), 1, 99)  then
    EdtPaymentOnChaange(Sender);
  if (Name = 'chb_accountfile') or  (Name = 'chb_requestfile') then
    TDBCheckBoxEh(Sender).Checked := Pos(' не ', TDBCheckBoxEh(Sender).Caption) = 0;
end;

function TFrmCDedtAccount.Save: Boolean;
begin

end;

function TFrmCDedtAccount.IsFilesLoaded: Boolean;
var
  a: TStringDynArray;
  b1, b2: Boolean;
begin
  a:=Sys.GetFileInDirectoryOnly(Module.GetPath_Accounts_A(F.GetProp('filename')));
  chb_AccountFile.Checked := Length(a) > 0;
  chb_AccountFile.Caption := 'Файл счета ' + S.IIf(chb_AccountFile.Checked, 'загружен', 'не загружен');
  Cth.SetErrorMarker(chb_AccountFile, not chb_AccountFile.Checked);
  a:=Sys.GetFileInDirectoryOnly(Module.GetPath_Accounts_Z(F.GetProp('filename')));
  chb_RequestFile.Checked := Length(a) > 0;
  chb_RequestFile.Caption := 'Файл заявки ' + S.IIf(chb_AccountFile.Checked, 'загружен', 'не загружен');
//      if (cmb_id_expenseitem.ItemIndex = -1) //or(cmb_RecReceipt.Items[cmb_ExpenseItem.ItemIndex] = '1')
  Cth.SetErrorMarker(chb_RequestFile, (not chb_AccountFile.Checked) and (nedt_sum.Value > Module.GetCfgVar(mycfgPCsum_need_req)));
end;


end.
