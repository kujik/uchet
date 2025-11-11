unit uFrmCDedtAccount;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, DBCtrlsEh, Math, Types,
  uFrMyPanelCaption, uFrmBasicMdi, uFrmBasicDbDialog, uData, uFrDBGridEh, uSys,
  Data.Bind.EngExt, Vcl.Bind.DBEngExt, Data.Bind.Components, Vcl.Buttons,
  Vcl.Mask
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
    procedure FormResize(Sender: TObject);
  private
    FAccountType: Integer;
    function  Prepare: Boolean; override;
    function  LoadComboBoxes: Boolean; override;
    procedure ControlOnExit(Sender: TObject); override;
    procedure ControlOnEnter(Sender: TObject); override;
    procedure ControlOnChange(Sender: TObject); override;
    procedure EdtPaymentOnChaange(Sender: TObject);
    function  Save: Boolean; override;
    function  IsFilesLoaded: Boolean;
    procedure LoadPayments;
    procedure SetFormAppearance;
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
  uFields
;


{$R *.dfm}

const
  cMaxPaymentsCnt = 5 * 12;

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
    ['sum$f','V=0:100000000:2'],       //!!! допутим ли 0
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
  if Mode <> fAdd then
    FAccountType := F.GetPropB('accounttype').AsInteger;
  LoadPayments;
  IsFilesLoaded;
  SetControlsEditable([cmb_id_user], False);
  SetFormAppearance;
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
  if Name = 'nedt_sum' then
    EdtPaymentOnChaange(nil);
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

procedure TFrmCDedtAccount.LoadPayments;
var
  i, j: Integer;
  va2: TVarDynArray2;
begin
  EdtPaymentOnChaange(nil);
  if Mode in [fAdd, fCopy] then
    Exit;
  va2 := Q.QLoadToVarDynArray2('select id, dt, sum, status from sn_calendar_payments where id_account = :id$i order by status desc, dt, sum', [ID]);
  for i := 0 to High(va2) do begin
    Cth.SetControlValue(Self, 'dedt_' + IntToStr(i + 1), va2[i][1]);
    Cth.SetControlValue(Self, 'nedt_' + IntToStr(i + 1), va2[i][2]);
    if (Mode in [fEdit]) and (va2[i][3] = 1) then begin
      SetControlsEditable([TControl(FindComponent('dedt_' + IntToStr(i + 1))), TControl(FindComponent('nedt_' + IntToStr(i + 1)))], False);
    end;
  end;
  EdtPaymentOnChaange(nil);
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



procedure TFrmCDedtAccount.FormResize(Sender: TObject);
begin
  {Perform(WM_SETREDRAW, 0, 0);
  inherited;
  ClientHeight := FWHCorrected.Y + 35;
  Perform(WM_SETREDRAW, 1, 0);
  Invalidate;
  Repaint;}
  ClientHeight := pnlAdd.Top + pnlAdd.Height + pnlFrmBtnsMain.Height + 30;
end;

end.
