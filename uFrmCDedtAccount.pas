unit uFrmCDedtAccount;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, DBCtrlsEh, Math, Types,
  Vcl.Mask, Vcl.AppEvnts, Data.Bind.EngExt, Vcl.Bind.DBEngExt, Data.Bind.Components, Vcl.Buttons,
  uFrMyPanelCaption, uFrmBasicMdi, uFrmBasicDbDialog, uFrDBGridEh, uString, uData, uSys
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
    tmr1: TTimer;
    ApplicationEvents1: TApplicationEvents;
    lbl_Info: TLabel;
    procedure FormResize(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure edt_accountEditButtons0Click(Sender: TObject;
      var Handled: Boolean);
  private
    FAccountType: Integer;
    FExpenseItemsAgreed: TVarDynArray2;
    FExpenseItemsNeedReceipt: TVarDynArray2;
    //счет оплачен (частично или полностью)
    FIsPaid: Boolean;
    //Можно редактировать только платежи
    FEdtPaymentsOnly: Boolean;
    function  Prepare: Boolean; override;
    function  LoadComboBoxes: Boolean; override;
    procedure ControlOnExit(Sender: TObject); override;
    procedure ControlOnEnter(Sender: TObject); override;
    procedure ControlOnChange(Sender: TObject); override;
    procedure EditButtonsClick(Sender: TObject; var Handled: Boolean); override;
    procedure btnClientClick(Sender: TObject); override;
    procedure EdtPaymentOnChaange(Sender: TObject);
    function  Save: Boolean; override;
    procedure LoadPayments;
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
  public
  end;

var
  FrmCDedtAccount: TFrmCDedtAccount;

implementation

uses
  ToolCtrlsEh,
  uForms,
  uDBOra,
  uMessages,
  uWindows,
  uFields
;


{$R *.dfm}

const
  cMaxPaymentsCnt = 5 * 12;
  cPaymentsCntSt = 5;

function TFrmCDedtAccount.Prepare: Boolean;
begin
  Result := False;

  FAccountType := AddParam.AsInteger;

  Caption := 'Счет';
  FOpt.RefreshParent := True;
  FOpt.DlgPanelStyle := dpsBottomRight;
  FOpt.StatusBarMode := stbmDialog;

  Cth.MakePanelsFlat(pnlFrmClient, []);

  //FWHCorrected := Cth.AlignControls(pnlFrmClient, FOpt.ControlsWoAligment, False);

  frmpcGeneral.SetParameters(True, 'Основное', [['Данные счета.']], False);
  Cth.AlignControls(pnlGeneralM, FOpt.ControlsWoAligment, True);
  pnlGeneral.Height := frmpcGeneral.Height + pnlGeneralM.Height;

  frmpcRoute.SetParameters(True, 'Транспорт', [['1']], False);
  Cth.AlignControls(pnlRouteM, FOpt.ControlsWoAligment, True);

  frmpcBasis.SetParameters(True, 'Основание', [['1']], False);

  frmpcPayments.SetParameters(True, 'Платежи', [['1']], False);
  CreatePaymentsEdts;

  frmpcAdd.SetParameters(True, 'Дополнительно', [], False);
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
    ['accounttype$i','V=1:400',#0,AddParam],
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
//  Cth.SetDoubleBuffered(Self, True);
  Self.DoubleBuffered := True;
  Result := Inherited;
  if Result = False then
    Exit;
  if Mode <> fAdd then
    FAccountType := F.GetPropB('accounttype').AsInteger;
  CalculateNds;
  LoadPayments;
  SetAgreed1(False);
  IsFilesLoaded;
  SetEditable;
  SetFormAppearance;
end;

function TFrmCDedtAccount.LoadComboBoxes: Boolean;
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

function TFrmCDedtAccount.Save: Boolean;
begin

end;


procedure TFrmCDedtAccount.LoadPayments;
var
  i, j: Integer;
  va2: TVarDynArray2;
begin
  EdtPaymentOnChaange(nil);
  if Mode in [fAdd, fCopy] then
    Exit;
  va2 := Q.QLoadToVarDynArray2('select id, dt, sum, status from sn_calendar_payments where id_account = :id$i order by status desc, dt, sum', [ID]);
  FIsPaid := False;
  for i := 0 to High(va2) do begin
    Cth.SetControlValue(Self, 'dedt_' + IntToStr(i + 1), va2[i][1]);
    Cth.SetControlValue(Self, 'nedt_' + IntToStr(i + 1), va2[i][2]);
    if (Mode in [fEdit]) and (va2[i][3] = 1) then begin
      FIsPaid := True;
      SetControlsEditable([TControl(FindComponent('dedt_' + IntToStr(i + 1))), TControl(FindComponent('nedt_' + IntToStr(i + 1)))], False);
    end;
  end;
  EdtPaymentOnChaange(nil);
//  EdtPaymentOnChaange(TControl(FindComponent('dedt_1')));
end;

procedure TFrmCDedtAccount.SetFormAppearance;
var
  h : Integer;
begin
  pnlRoute.Visible := a.InArray(FAccountType, [1, 2]);      //маршрут, для транспортных
  pnlBasis.Visible := a.InArray(FAccountType, [1, 2, 3]);    //основания, для транспортных и монтажа
  h := pnlAdd.Top + pnlAdd.Height;
  FWHCorrected.Y := h;
  FWHCorrected.Y2 := h;
  //FWHBounds := FWHCorrected;   //ведет к блокировке изменения размера и неверному размеру
{ //возьмем размеры формы из настроек
  Self.Width:= StrtoInt(Settings.ReadProperty(FormDoc, 'Width_' + IntToStr(AccMode), '0'));
  Self.Height:= StrtoInt(Settings.ReadProperty(FormDoc, 'Height_' + IntToStr(AccMode), '0'));
  Self.Resize;}
end;

procedure TFrmCDedtAccount.tmr1Timer(Sender: TObject);
begin
  inherited;
  //UnLockDrawing;
end;

procedure TFrmCDedtAccount.CreatePaymentsEdts;
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
      nedt1.Name := 'nedt_' + IntToStr((i - 1) * cPaymentsCntSt + j);
      nedt1.Visible := (i = 1) and (j = 1);
      nedt1.Left := (j - 1) * w  + nedt_1.Left;
      nedt1.Width := nedt_1.Width;
      nedt1.Top := dedt1.Top;
    end;
  pnlPaymentsD.Visible := True;
end;
(*
procedure TFrmCDedtAccount.CreatePaymentsEdts;
var
  i, j: Integer;
  dedt1: TDBDateTimeEditEh;
  nedt1: TDBNumberEditEh;
  w: Integer;
begin
  pnlPaymentsD.Visible := False;
  w := nedt_1.Left + nedt_1.Width + 25;
  for i := 1 to cMaxPaymentsCnt div 3  do
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
*)

procedure TFrmCDedtAccount.EdtPaymentOnChaange(Sender: TObject);
var
  i, j, t: Integer;
  b: Boolean;
  sum: Extended;
begin
  //if not FInPrepare then
    //Perform(WM_SETREDRAW, 0, 0);
  try
  i := cMaxPaymentsCnt;
  while (i > 1) and not TControl(FindComponent('dedt_' + IntToStr(i))).Visible do
    dec(i);
  t := TControl(FindComponent('dedt_' + IntToStr(i))).Top;
  sum:= 0;
  for i := 1 to cMaxPaymentsCnt do begin
    Cth.SetErrorMarker(TControl(FindComponent('dedt_' + IntToStr(i))), False);
    Cth.SetErrorMarker(TControl(FindComponent('nedt_' + IntToStr(i))), False);
  end;
  i := cMaxPaymentsCnt;
  while (i > 1) and ((GetControlValue('dedt_' + IntToStr(i), True) = null) and (GetControlValue('nedt_' + IntToStr(i), True) = null)) do
    dec(i);
  b := False;
  for j := i downto 1 do  begin
    sum := sum + GetControlValue('nedt_' + IntToStr(j)).AsFloat;
    if (GetControlValue('dedt_' + IntToStr(j), True) = null) and (GetControlValue('nedt_' + IntToStr(j), True) = null) then begin
       b := True;
    end
    else if (GetControlValue('dedt_' + IntToStr(j), True) <> null) and (GetControlValue('nedt_' + IntToStr(j), True) = null) then begin
      Cth.SetErrorMarker(TControl(FindComponent('nedt_' + IntToStr(j))), True);
    end
    else if (GetControlValue('dedt_' + IntToStr(j), True) = null) and (GetControlValue('nedt_' + IntToStr(j), True) <> null) then begin
      Cth.SetErrorMarker(TControl(FindComponent('dedt_' + IntToStr(j))), True);
    end;
  end;
//Exit;
  if (not b) and (i < cMaxPaymentsCnt) then begin
    TControl(FindComponent('dedt_' + IntToStr(i + 1))).Visible := True;
    TControl(FindComponent('nedt_' + IntToStr(i + 1))).Visible := True;
  end;
  for i := 0 to cMaxPaymentsCnt - 1 do
    if not ((GetControlValue('dedt_' + IntToStr(i), True) = null) and (GetControlValue('nedt_' + IntToStr(i), True) = null)) then begin
      TControl(FindComponent('dedt_' + IntToStr(i + 1))).Visible := True;
      TControl(FindComponent('nedt_' + IntToStr(i + 1))).Visible := True;
    end;
  i := cMaxPaymentsCnt;
  while (i > 1) and not TControl(FindComponent('dedt_' + IntToStr(i))).Visible do
    dec(i);
  if sum <> GetControlValue('nedt_sum').AsFloat then
    for j := i downto 1 do
      if (GetControlValue('nedt_' + IntToStr(j), True) <> null) or (j = 1) then begin
        Cth.SetErrorMarker(TControl(FindComponent('nedt_' + IntToStr(j))), True);
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

procedure TFrmCDedtAccount.edt_accountEditButtons0Click(Sender: TObject; var Handled: Boolean);
begin
  inherited;
  var s := TEditButtonControlEh(Sender).Hint;
//  if Sender  is TDBEditEh then
  MyInfoMessage(Sender.classname);
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
    lbl_Info.Caption := 'Счет ' + st + '!' + S.IIFStr(not User.IsDataEditor, #13#10'Возможно только редактирование запланированных платежей!');
  //поле - признак блокировки
  FEdtPaymentsOnly := (st <> '') and not User.IsDataEditor;      //!!!
  if FEdtPaymentsOnly then begin
    //делаем контролы ридонли
    SetControlsEditable([], False, False, pnlGeneral);
    SetControlsEditable([btnFileAttach, btnReqestFileAttach, edt_comm], False, False, pnlAdd);
    btnFileAttach.Enabled := False;
    btnReqestFileAttach.Enabled := False;
    chb_Agreed1.Enabled := IsAgreed1Enabled;
    chb_Agreed2.Enabled := User.Role(rPC_A_AgrDir);
  end;
  //эти ридонли всегда
  SetControlsEditable([cmb_id_user, nedt_SumWoNds], False, False, pnlGeneral);
 end;

end.
