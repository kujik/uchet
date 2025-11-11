unit D_Sn_Calendar;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Math,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, uData, uForms, uDBOra, uString, uMessages, System.Types,
  Vcl.ExtCtrls, ToolCtrlsEh, DBGridEhToolCtrls,
  GridsEh, DBAxisGridsEh, DBGridEh, MemTableDataEh, MemTableEh,
  Data.DB, Vcl.Menus, uSettings, Vcl.Imaging.pngimage, V_MDI, DateUtils,
  EhLibVclUtils, DBGridEhGrouping, DynVarsEh, Vcl.Mask  ;

const
  SumAutoAgree = 1500;

type
  TDlg_Sn_Calendar = class(TForm_MDI)
    gb_Payments: TGroupBox;
    Dt_1: TDBDateTimeEditEh;
    Dt_2: TDBDateTimeEditEh;
    Dt_3: TDBDateTimeEditEh;
    Dt_4: TDBDateTimeEditEh;
    Dt_5: TDBDateTimeEditEh;
    nedt_1: TDBNumberEditEh;
    nedt_2: TDBNumberEditEh;
    nedt_3: TDBNumberEditEh;
    nedt_4: TDBNumberEditEh;
    nedt_5: TDBNumberEditEh;
    Dt_6: TDBDateTimeEditEh;
    Dt_7: TDBDateTimeEditEh;
    Dt_8: TDBDateTimeEditEh;
    Dt_9: TDBDateTimeEditEh;
    Dt_10: TDBDateTimeEditEh;
    nedt_6: TDBNumberEditEh;
    nedt_7: TDBNumberEditEh;
    nedt_8: TDBNumberEditEh;
    nedt_9: TDBNumberEditEh;
    nedt_10: TDBNumberEditEh;
    gb_General: TGroupBox;
    cmb_Cash: TDBComboBoxEh;
    edt_Account: TDBEditEh;
    Dt_Account: TDBDateTimeEditEh;
    cmb_Org: TDBComboBoxEh;
    Bt_RefreshSuppliers: TBitBtn;
    cmb_Supplier: TDBComboBoxEh;
    cmb_ExpenseItem: TDBComboBoxEh;
    nedt_Sum: TDBNumberEditEh;
    cmb_User: TDBComboBoxEh;
    gb_Additional: TGroupBox;
    pnl_Buttons: TPanel;
    lbl_Payments: TLabel;
    OpenDialog1: TOpenDialog;
    cmb_RecReceipt: TDBComboBoxEh;
    edt_File: TDBEditEh;
    Bt_OK: TBitBtn;
    Bt_Cancel: TBitBtn;
    edt_Comm: TDBEditEh;
    Bt_FileAttach: TBitBtn;
    Bt_FileOpen: TBitBtn;
    lbl_AccountFile: TLabel;
    Bt_ReqestFileAttach: TBitBtn;
    Bt_ReqestFileOpen: TBitBtn;
    lbl_RequestFile: TLabel;
    lbl1: TLabel;
    chb_Agreed1: TDBCheckBoxEh;
    chb_Agreed2: TDBCheckBoxEh;
    gb_Route: TGroupBox;
    gb_Payments_T: TGroupBox;
    gb_Basis: TGroupBox;
    Dt_T1: TDBDateTimeEditEh;
    nedt_T1: TDBNumberEditEh;
    Dt_T2: TDBDateTimeEditEh;
    nedt_T2: TDBNumberEditEh;
    pnl_Route: TPanel;
    pnl_Basis: TPanel;
    cmb_CarType: TDBComboBoxEh;
    cmb_Flight: TDBComboBoxEh;
    nedt_Kilometrage: TDBNumberEditEh;
    DBGridEh1: TDBGridEh;
    DBGridEh2: TDBGridEh;
    MemTableEh1: TMemTableEh;
    DataSource1: TDataSource;
    tmr1: TTimer;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    dedt_FlightDt: TDBDateTimeEditEh;
    nedt_Idle: TDBNumberEditEh;
    lbl_Payments_Error: TLabel;
    lbl_Route_Error: TLabel;
    lbl_Basis_Error: TLabel;
    lbl_Payments_T_Error: TLabel;
    MemTableEh2: TMemTableEh;
    DataSource2: TDataSource;
    PopupMenu2: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    nedt_BasisSum: TDBNumberEditEh;
    Img_H_Payments: TImage;
    Img_H_General: TImage;
    Img_H_Routes: TImage;
    Img_H_Basis: TImage;
    Img_H_PaymentsT: TImage;
    Img_H_Additional: TImage;
    lbl_General_Error: TLabel;
    Bt_SelectSupplier: TBitBtn;
    nedt_PriceKm: TDBNumberEditEh;
    nedt_PriceIdle: TDBNumberEditEh;
    nedt_SumOther: TDBNumberEditEh;
    cmb_Nds: TDBComboBoxEh;
    nedt_SumWoNds: TDBNumberEditEh;
    chbAccountFile: TDBCheckBoxEh;
    procedure Bt_OKClick(Sender: TObject);
    procedure nedt_1Change(Sender: TObject);
    procedure Dt1_KeyPress(Sender: TObject; var Key: Char);
    procedure control_Exit(Sender: TObject);
    procedure nedt_1KeyPress(Sender: TObject; var Key: Char);
    procedure Bt_FileAttachClick(Sender: TObject);
    procedure Bt_FileOpenClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Bt_ReqestFileAttachClick(Sender: TObject);
    procedure Bt_ReqestFileOpenClick(Sender: TObject);
    procedure Bt_CancelClick(Sender: TObject);
    procedure Bt_RefreshSuppliersClick(Sender: TObject);
    procedure cmb_FlightChange(Sender: TObject);
    procedure DBGridEh1KeyPress(Sender: TObject; var Key: Char);
    procedure DBGridEh1ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
    procedure DBGridEh1ColEnter(Sender: TObject);
    procedure MemTableEh1AfterScroll(DataSet: TDataSet);
    procedure MemTableEh1AfterEdit(DataSet: TDataSet);
    procedure ControlExit(Sender: TObject);
    procedure DBGridEh1Exit(Sender: TObject);
    procedure DBGridEh1ColExit(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure FormResize(Sender: TObject);
    procedure Dt_T1Change(Sender: TObject);
    procedure Dt_T2Change(Sender: TObject);
    procedure nedt_T1Change(Sender: TObject);
    procedure nedt_T2Change(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure DBGridEh1Enter(Sender: TObject);
    procedure Image1MouseEnter(Sender: TObject);
    procedure Image1MouseLeave(Sender: TObject);
    procedure cmb_ExpenseItemChange(Sender: TObject);
    procedure Bt_SelectSupplierClick(Sender: TObject);
    procedure chb_Agreed1Click(Sender: TObject);
    procedure DBGridEh2DblClick(Sender: TObject);
  private
    { Private declarations }
//    Form: TComponent;
//    FormDoc: string;
//    Mode: Integer;
//    ID: Variant;
    AccMode:Variant; //тип счета, 0-обычный,1-транспорт отгр, 2-транспорт сн
    FieldNames: string;
    Ok: Boolean;
    aModalResult: Integer;
    Payments: TVarDynArray;
    PaymentsCount: Integer;
    Paid: Boolean;
    Dt: TDateTime;
    ID_Curr_Supplier: Integer;
    ExpAgreed: TStringList;
    IsAgreed: Boolean;
    WhoAgreed: Variant;
    OldFlight: string;
    InLoadData: Boolean;
    InRouteGridEdit: Boolean;
    InRouteGridEdit1:Boolean;
    IsRouteGridChanged:Boolean;
    Points0: TStringList;   //свои месторасположения
    Points1: TStringList;   //месторасположения по маршруту
    MaxIdle: Variant;       //максимальное неоплачиваемое время ожидания, из настроек модуля
    procedure SetRouteGrid;
    procedure SetRouteGridType;
    procedure SetRouteGridEditable;
    procedure MemTableEh1AfterEditCorrectData;
    procedure SetBasisGrid;
    procedure FileAttach(Files:Tstrings; Mode: Boolean);
    function GetSum(Sender: TObject): Extended;
    function PointInLocations(st: string): Integer;
    function IfFilesLoaded: Boolean;
    function IsAgreed1Enabled: Boolean;
    procedure Verify;
   // procedure ExitDialog;
    function  Prepare: Boolean; override;
  public
    { Public declarations }
    IsRouteGridEdited: Boolean;  //был отредактирован вручную
    IsBasisGridEdited: Boolean;
    constructor ShowDialog(aOwner: TComponent; aFormDoc: string; aMode: TDialogType; aID: Variant; AMyFormOptions: TMyFormOptions; aAccMode: Variant);
    procedure BasisTableGetSum;
    procedure CalculateSumWoNds;
 end;

var
  Dlg_Sn_Calendar: TDlg_Sn_Calendar;

implementation


uses
  uWindows,
  uSys,
  uFrmCWAcoountBasis
  ;

{$R *.dfm}

constructor TDlg_Sn_Calendar.ShowDialog(aOwner: TComponent; aFormDoc: string; aMode: TDialogType; aID: Variant; AMyFormOptions: TMyFormOptions; aAccMode: Variant);
begin
  inherited Create(aOwner, aFormDoc, AMyFormOptions, aMode, aID, aAccMode);
//  if aAccMode = null then aAccMode:=0;
//  AccMode:=aAccMode;
end;

function TDlg_Sn_Calendar.Prepare: Boolean;
var
  v, vt: TVarDynArray;
  i: Integer;
  e: Extended;
  b, e1, e2: Boolean;
  ws: TWindowState;
  st: string;
begin
  Result:=False;
  if Mode=fEdit then if Q.DBLock(True, 'dlg_sn_calendar', VarToStr(id))[0] <> True  then Exit;
//  if FormDbLock = fNone then Exit;
//  Mode:=DBLock(True, 'dlg_sn_calendar', VarToStr(id), '*|*', Mode)[3];
//  LockInDB:=Mode;
//  if Mode = fNone then Exit;
  AccMode := AddParam;
  InLoadData:=True;

  ExpAgreed:=TStringList.Create;
  //получим данные из основной таблицы
  //ВАЖНО - поля именно в таблице а не вью, по этип же полям происходит запись в таблицу при сохранении
  FieldNames:='id$i;type$i;account$s;id_supplier$i;id_org$i;id_expenseitem$i;id_user$i;sum$f;comm$s;filename$s;agreed1$i;agreed2$i;accountdt$d;dt$d;accounttype$d;id_whoagreed1$i;nds$f';
  if Mode = fAdd
    then v:=VarArrayOf([1,'','', 0, 0, 0, 0, 0{сумма},'','',0,0,DateTimeToStr(Date), Date, AccMode, null{id кто согласовал = 15},null{nds=16}])
    else v:=Q.QSelectOneRow(Q.QSIUDSql('s', 'sn_calendar_accounts', FieldNames), [ID]);
  //если не удалось получить то выйдем с сообщением что строка удалена
  if v[0] = null then begin MsgRecordIsDeleted; Exit; end;
  //режим счета - обычный, транспорт отгрузки, транспорт сн
  AccMode:=v[14];

  Cth.SetInfoIcon(Img_H_General,'Заголовок счета.'+#10#13+'Все поля обязательны для заполнения.'+#10#13+'Можно редактировать только, если счет'+#10#13+'не согласован и по нему нет проведенных платежей.'+#10#13+'');
  Cth.SetInfoIcon(Img_H_Payments,'Распределите платежи по счету.'+#10#13+'Редактировать можно только те платежи, которые не проведены.'+#10#13+'Нажмите пробел в поле суммы, чтобы дополнить ее до суммы счета....'+#10#13+'Нажмите "=" в поле даты, чтобы посмотреть запланированные платежи.'+#10#13+'Для удаления платежа сотрите дату и сумму.');
  Cth.SetInfoIcon(Img_H_PaymentsT,'Распределите платежи по счету.'+#10#13+'Редактировать можно только те платежи, которые не проведены.');
  Cth.SetInfoIcon(Img_H_Routes,'Выберите тип транспортного средства, тип и параметры рейса и задайте маршрут следования....'+#10#13+
    'Введите данные непосредственно в сетке, для перехода на новую строку нажмите стрелку вниз, для вставки или удаления строки нажмите ПКМ.'+#10#13+
    'Для удаления/втавки строки нажмите правую кнопку мыши. Для реадктирования ячейки начните ввод или нажмите F2.'+#10#13+
    'Пункты назаначения можно выбрать из списка, пункт отправления вводится только в первой строке, время простоя считается автоматически.'#10#13+
    'Если километраж и даты вводятся в сетке, то в заголовке они будут проставлены автоматически.'+#10#13+
    'Для прямого рейса по транспорту отгрузки необходимо ввести даты и километраж в сетке. Для ввода даты наберите ее в виде "ДД ММ ГГ ЧЧ ММ",'+#10#13+
    'Если километраж и даты вводятся в сетке, то в заголовке они будут проставлены автоматически, иначе введите их вручную.'+#10#13+'');
  if (AccMode = 1)or(AccMode=2)
    then Cth.SetInfoIcon(Img_H_Basis,'Введите основания для транспортного счета.'+#10#13+'Нажмите ПКМ и выберите Добавить (или Удалить для удаления строки)...'+#10#13+'В открывшемся окне выберите заказы или счета, задайте процент, и нажмите кнопку >>> или ПКМ.'+#10#13+'')
    else if (AccMode = 3)
      then Cth.SetInfoIcon(Img_H_Basis,'Введите основания для счета подрядчика по монтажу.'+#10#13+'Нажмите ПКМ и выберите Добавить (или Удалить для удаления строки)...'+#10#13+'В открывшемся окне выберите необходимые заказы, задайте процент, и нажмите кнопку >>> или ПКМ.'+#10#13+'');
  Cth.SetInfoIcon(Img_H_Additional,'Прикрепите файлы счетов и заявок на снабжение. Файл счета обязателен.'+#10#13+'Прикрепить его можно только для не согласованного и не проплаченного счета.... Проставьте согласование счета, если у Вас есть для этого полномочия. '+#10#13+'');

  //инициируем контролы для режима транспортного счета
  if (AccMode = 1)or(AccMode=2) then begin
    cmb_Flight.Value:=null;
    cmb_Flight.Items.Clear;
    cmb_Flight.Items.Add('Прямой');
    cmb_Flight.Items.Add('Фиксированный');
    cmb_Flight.KeyItems.Add('1');
    cmb_Flight.KeyItems.Add('2');
    //загрузим данные из дополнительной таблицы для транспортного счета
    vt:=VarArrayOf([0, 0]);
    if (Mode = fEdit) or (Mode = fView) or (Mode = fDelete) then begin
      vt:=Q.QSelectOneRow(Q.QSIUDSql('s', 'sn_calendar_accounts_t', 'id;cartype$i;flighttype$i;flightdt;kilometrage;idle;basissum;othersum;priceidle;pricekm;freeidletime'), [ID]);
      Cth.SetControlValue(cmb_Cartype, vt[1]);
      Cth.SetControlValue(cmb_Flight, vt[2]);
      Cth.SetControlValue(dedt_FlightDt, vt[3]);
      Cth.SetControlValue(nedt_Kilometrage, vt[4]);
      Cth.SetControlValue(nedt_SumOther, vt[7]);
      Cth.SetControlValue(nedt_PriceIdle, vt[8]);
      Cth.SetControlValue(nedt_PriceKm, vt[9]);
      MaxIdle:=vt[10];
    end
    else begin
      MaxIdle:=Q.QSelectOneRow('select transport_maxidle from sn_calendar_cfg', [])[0];
    end;
    //типы автомобилей
    Q.QLoadToDBComboBoxEh('select name, id from ref_sn_cartypes where active = 1 or id = :id order by name', [vt[1]], cmb_CarType, cntComboLK);
    //локации
    Points0:=TStringList.Create;
    Points1:=TStringList.Create;
    if (Mode <> fView)and(Mode <> fDelete) then begin
      //свои локации
      Q.QLoadToTStringList('select name from ref_sn_locations where type = 0 and active = 1 order by name', [], Points0);
      //локации маршрута по типу счета
      Q.QLoadToTStringList('select name from ref_sn_locations where type = :type order by name', [AccMode], Points1);
    end;
    InRouteGridEdit:=True;
    SetRouteGrid;
    SetRouteGridType;
    if (Mode<>fAdd)and(Mode<>fCopy) then begin
      Q.QOpen('select (select name from ref_sn_locations where id=point1), dt1, (select name from ref_sn_locations where id=point2), dt2, kilometrage from sn_calendar_t_route where id_account=:id order by pos', [ID]);
      while not Q.AdoQuery.EOF do
        begin
          MemTableEh1.Append;
          MemTableEh1.Fields[0].AsString:=Q.AdoQuery.Fields[0].AsString;
          if Q.AdoQuery.Fields[1].AsVariant<>null then MemTableEh1.Fields[1].AsDateTime:=Q.AdoQuery.Fields[1].AsDateTime;
          MemTableEh1.Fields[2].AsString:=Q.AdoQuery.Fields[2].AsString;
          if Q.AdoQuery.Fields[3].AsVariant<>null then MemTableEh1.Fields[3].AsDateTime:=Q.AdoQuery.Fields[3].AsDateTime;
          if Q.AdoQuery.Fields[4].AsVariant<>null then MemTableEh1.Fields[4].AsInteger:=Q.AdoQuery.Fields[4].AsInteger;
          MemTableEh1.Post;
          Q.AdoQuery.Next;
        end;
      end;
    Q.QClose;
    //перерисуем и пересчитаем грид маршрутов
    IsRouteGridChanged:=True;
    MemTableEh1.Edit;
    MemTableEh1AfterEditCorrectData;
    InRouteGridEdit:=False;
    SetRouteGridEditable;
    isRouteGridEdited:=False;
  end;
  //инициируем контролы для режима транспортных и монтажных счетов (основания)
  if (AccMode = 1)or(AccMode=2)or(AccMode=3) then begin
    //грид оснований
    SetBasisGrid;
    if (Mode<>fAdd)and(Mode<>fCopy) then begin
      Q.QOpen('select id_basis, type, name, prc, sum from v_sn_calendar_t_basis where id_account=:id order by pos', [ID]);
      while not Q.AdoQuery.EOF do
        begin
          MemTableEh2.Append;
          MemTableEh2.Fields[0].AsInteger:=Q.AdoQuery.Fields[0].AsInteger;
          MemTableEh2.Fields[1].AsString:=Q.AdoQuery.Fields[1].AsString;
          MemTableEh2.Fields[2].AsString:=Q.AdoQuery.Fields[2].AsString;
          MemTableEh2.Fields[3].AsInteger:=Q.AdoQuery.Fields[3].AsInteger;
          MemTableEh2.Fields[4].AsFloat:=Q.AdoQuery.Fields[4].AsFloat;
          MemTableEh2.Post;
          Q.AdoQuery.Next;
        end;
      end;
    Q.QClose;
    BasisTableGetSum;
    isBasisGridEdited:=False;
  end;

  ID_Curr_Supplier:=StrToIntDef(v[3],-999);
  Q.QLoadToDBComboBoxEh('select legalname, id from ref_suppliers where active = 1 or id = :id$i order by legalname', [v[3]], cmb_Supplier, cntComboLK);
  Q.QLoadToTStringList('select agreed, id from ref_expenseitems', [], ExpAgreed);
  if User.Role(rPC_A_ChAll)
    then begin
      Q.QLoadToDBComboBoxEh('select name, id from ref_expenseitems where (accounttype = :accmode$i and active = 1) or id = :id_expenseitem$i order by name',
        [AccMode, v[5]], cmb_ExpenseItem, cntComboLK);
      Q.QLoadToDBComboBoxEh('select recvreceipt, id from ref_expenseitems where (accounttype = :accmode$i and active = 1) or id = :id_expenseitem$i order by name',
        [AccMode, v[5]], cmb_RecReceipt, cntComboLK);
    end
    else begin
      //загрузим только статьи расходов, по которым можно редактировать (в итоге если открыть на редактирование счет не  по своей статье, то его не сохранить тк стаья будет пустая)
      Q.QLoadToDBComboBoxEh('select name, id from ref_expenseitems where (anyinstr(useravail, :id_user$i)=1 and accounttype = :accmode$i) or id = :id_expenseitem$i order by name',
        [User.GetId, AccMode, v[5]], cmb_ExpenseItem, cntComboLK);
      Q.QLoadToDBComboBoxEh('select recvreceipt, id from ref_expenseitems where (anyinstr(useravail, :id_user$i)=1 and accounttype = :accmode$i) or id = :id_expenseitem$i order by name',
        [User.GetId, AccMode, v[5]], cmb_RecReceipt, cntComboLK);
    end;
  Q.QLoadToDBComboBoxEh(
    'select name, id from ref_sn_organizations where (active = 1 and is_buyer = 1) or id = :id$i order by name',
    [v[4]], cmb_Org, cntComboLK);
  Q.QLoadToDBComboBoxEh('select name, id from adm_users order by name', [], cmb_User, cntComboLK);
  if Mode=fCopy then begin
    //сбросим согласования и дату регистрации счета
    v[10]:=False;
    v[11]:=False;
    v[13]:=Date;
  end;
  cmb_Cash.Value:=v[1];
  edt_Account.Value:=v[2];
  cmb_Supplier.Value:=v[3];
  cmb_Org.Value:=v[4];
  cmb_ExpenseItem.Value:=v[5];//S.IIf(v[5]>0, v[5], '');
  cmb_User.Value:=v[6];
  nedt_Sum.Value:=v[7];
  edt_Comm.Value:=v[8];
  edt_File.Value:=v[9];
  Cth.SetControlValue(chb_Agreed1, v[10]);
  Cth.SetControlValue(chb_Agreed2, v[11]);
  Cth.SetControlValue(Dt_Account, v[12]);
  Cth.AddToComboBoxEh(cmb_NDS, [
    ['без НДС', '0'],
    ['20%', '20']
  ]);
  Cth.SetControlValue(cmb_Nds, v[16]);
  CalculateSumWoNds;

  Dt:=v[13];
  for i:=1 to 10 do begin
    (Self.FindComponent('Dt_'+IntToStr(i)) as TDBDateTimeEditEh).Clear;
    (Self.FindComponent('nedt_'+IntToStr(i)) as TDBNumberEditEh).Clear;
  end;
  IsAgreed:=chb_Agreed1.Checked;
  //подпись чекбокса - кто согласовал, если согласован, или Руководитель
  if IsAgreed
    then begin
      chb_Agreed1.Caption:=Q.QSelectOneRow('select name from adm_users where id = :id$i', [v[15]])[0];
    end
    else chb_Agreed1.Caption:='Руководитель';
  if (Mode = fAdd) or (Mode = fCopy) then begin
    cmb_User.Value:=User.GetId;
    edt_File.Value:=FormatDateTime('yyyy-mm-dd hh.mm.ss.zzz', Now);
  end;
  PaymentsCount := 0;
  Paid:=False;
  if (Mode<>fAdd)and(Mode<>fCopy) then begin
    Q.QOpen('select id, dt, sum, status from sn_calendar_payments where id_account=:id$i order by status desc, dt, sum', [ID]);
    while not Q.AdoQuery.EOF do
      begin
        PaymentsCount:= PaymentsCount+1;
        SetLength(Payments, PaymentsCount);
        Payments[High(Payments)]:= VarArrayOf([Q.AdoQuery.Fields[0].AsInteger, Q.AdoQuery.Fields[1].AsDateTime, Q.AdoQuery.Fields[2].AsFloat, Q.AdoQuery.Fields[3].AsInteger]);
        if High(Payments) = 9 then Break;
        Q.AdoQuery.Next;
      end;
    end;
  Q.QClose;
  for i:=0 to PaymentsCount-1 do begin
    Cth.SetControlValue(TControl(Self.FindComponent('nedt_'+IntToStr(i+1))), Payments[i][2]);
    Cth.SetControlValue(TControl(Self.FindComponent('Dt_'+IntToStr(i+1))), Payments[i][1]);
    (Self.FindComponent('Dt_'+IntToStr(i+1)) as TDBDateTimeEditEh).enabled:=(Payments[i][3] <> 1);
    (Self.FindComponent('nedt_'+IntToStr(i+1)) as TDBNumberEditEh).Enabled:=(Payments[i][3] <> 1);
    if Payments[i][3] = 1 then Paid:=True;
  end;
  for i:=PaymentsCount to 9 do begin
    (Self.FindComponent('Dt_'+IntToStr(i+1)) as TDBDateTimeEditEh).enabled:=True;
    (Self.FindComponent('nedt_'+IntToStr(i+1)) as TDBNumberEditEh).Enabled:=True;
  end;
  if (Mode = fView)or(Mode=fdelete) then
    for i:=0 to 9 do begin
      (Self.FindComponent('Dt_'+IntToStr(i+1)) as TDBDateTimeEditEh).enabled:=False;
      (Self.FindComponent('nedt_'+IntToStr(i+1)) as TDBNumberEditEh).Enabled:=False;
    end;
  //продублируем значения платежей в групбоксе платежей по транспорту
  if gb_Payments_T.Visible then begin
    Dt_T1.Value:=Dt_1.Value;
    Dt_T1.Enabled:=Dt_1.Enabled;
    Dt_T2.Value:=Dt_2.Value;
    Dt_T2.Enabled:=Dt_2.Enabled;
    nedt_T1.Value:=nedt_1.Value;
    nedt_T1.Enabled:=nedt_1.Enabled;
    nedt_T2.Value:=nedt_2.Value;
    nedt_T2.Enabled:=nedt_2.Enabled;
  end;

  //доступность контролов
  //редактировать заголовок позволяем если не было еще проведено платежей, и не было согласования директора, и не было согласования руководителя либо пользователь имеет право на это согласование
  e1:=(Mode <> fView) and (Mode <> fDelete);
  e2:= e1 and ((Mode<>fEdit) or (((not Paid)or User.IsDataEditor) and (IsAgreed1Enabled or (not IsAgreed)) and (not chb_Agreed2.Checked)));
  cmb_Cash.Enabled:=e2;
  edt_Account.Enabled:=e2;
  Dt_Account.Enabled:=e2;
  cmb_Supplier.Enabled:=e2;
  cmb_Org.Enabled:=e2;
  cmb_ExpenseItem.Enabled:=e2;
  cmb_User.Enabled:=False;
  nedt_Sum.Enabled:=e2;
  edt_Comm.Enabled:=e1;
  Bt_FileAttach.Enabled:=e2;
  Bt_SelectSupplier.Enabled:=e2;
  Bt_RefreshSuppliers.Enabled:=e2;
  chb_Agreed1.Enabled:=IsAgreed1Enabled  and (not chb_Agreed2.Checked) and e1;   //активна, если может согласовывать хотя бы что-то
  chb_Agreed2.Enabled:=User.Roles([], [rPC_A_AgrDir]) and e1;
  cmb_CarType.Enabled:=e2;
  cmb_Flight.Enabled:=e2;
  dedt_FlightDt.Enabled:=e2 and not nedt_Idle.Visible;
  nedt_Kilometrage.Enabled:=e2 and not nedt_Idle.Visible;
  nedt_PriceKm.Enabled:=e2;
  nedt_PriceIdle.Enabled:=e2;
  nedt_SumOther.Enabled:=e2;
  if not e2 then DBGridEh1.Enabled:=False;
  if not e2 then DBGridEh2.Enabled:=False;
  cmb_Nds.Enabled:=e2;
  nedt_SumWoNds.Enabled:=False;
  lbl_Payments.Caption:='';
  if Mode = fEdit then begin
    if (IsAgreed and not IsAgreed1Enabled) or chb_Agreed2.Checked then st:='согласован';
    if Paid and not User.IsDataEditor then st:=S.IIFStr(st<>'', st + ' и ', '(частично) оплачен');
    if st<> '' then lbl_Payments.Caption:='Счет ' + st + '!'+#13#10+'Возможно только редактирование запланированных платежей!';
  end;

  //проверим
  Verify;
{  for i:=0 to Self.ControlCount-1 do
    begin
      TWincontrol(Self.Controls[i]).exOnExit:=control_Exit;
    end;}
  Cth.SetDialogForm(Self, Mode, 'Счёт');
  Bt_OK.ModalResult:=mrNone;
  IfFilesLoaded;
  aModalResult:=mrNone;
  Cth.SetBtn(Bt_FileAttach, mybtAttach, True, 'Прикрепить файл счета');
  Cth.SetBtn(Bt_ReqestFileAttach, mybtAttach, True, 'Прикрепить файл заявки');
  Cth.SetBtn(Bt_FileOpen, mybtView, True, 'Просмотреть файл счета');
  Cth.SetBtn(Bt_ReqestFileOpen, mybtView, True, 'Просмотреть файл заявки');
  Cth.SetBtn(Bt_RefreshSuppliers, mybtRefresh, True, 'Обновить список поставщиков');
  Cth.SetBtn(Bt_SelectSupplier, mybtSelectFromList, True, 'Выбрать поставщика из списка');
//  Position:=poOwnerFormCenter;
  //запретим выходить по Esc при редактировании данных, тк эта клавиша может быть нажата в гриде не при редактировании ячейки, и тогда следует закрыти формы
  Bt_Cancel.Cancel:=not((Mode = fAdd)or(Mode = fEdit)or(Mode = fCopy));
  //покажем нужные групбоксы и подгоним высоту формы
  gb_Route.Visible:=A.InArray(AccMode, [1,2]);      //маршрут, для транспортных
  gb_Basis.Visible:=A.InArray(AccMode, [1,2,3]);    //основания, для транспортных и монтажа
  gb_Payments.Visible:=not A.InArray(AccMode, [1,2,3]);  //грид платежей на 10 штук, для обычных
  gb_Payments_T.Visible:=not gb_Payments.Visible;      //платежа на две штуки, если нет грида на 10
  Self.ClientHeight:=pnl_Buttons.Top + pnl_Buttons.Height;
  //возьмем размеры формы из настроек
  Self.Width:= StrtoInt(Settings.ReadProperty(FormDoc, 'Width_' + IntToStr(AccMode), '0'));
  Self.Height:= StrtoInt(Settings.ReadProperty(FormDoc, 'Height_' + IntToStr(AccMode), '0'));
  Self.Resize;
{  Cth.SetControlsOnExit(Self, ControlExit);
  Cth.SetControlsOnExit(Self.gb_General, ControlExit);
  Cth.SetControlsOnExit(Self.gb_Payments, ControlExit);
  Cth.SetControlsOnExit(Self.gb_Payments_T, ControlExit);
  Cth.SetControlsOnExit(Self.gb_Route, ControlExit);
  Cth.SetControlsOnExit(Self.gb_Basis, ControlExit);
  Cth.SetControlsOnExit(Self.gb_Additional, ControlExit);}
  Verify;
  InLoadData:=False;
  Result:=True;
end;


{
procedure TDlg_Sn_Calendar.ExitDialog;
begin
  WindowState:=wsMinimized;
  Self.Close;
  Tag:=myFormClosed;
end;
}

procedure TDlg_Sn_Calendar.Bt_OKClick(Sender: TObject);
var
  IDpm: Integer;
  v1, v2, v3: Variant;
  i, j, k :Integer;
  st, st1, st2: string;
  NoErr: Boolean;
  ErrSql: Integer;
  b: Boolean;
begin
//   FieldNames:='id;type;account;id_supplier;id_org;id_expenseitem;id_user;sum;comm;filename;agreed1;agreed2';
  if Mode=fView then begin Close; exit; end;
  Verify;
  //если пользователь не имеет права согласования руководителя, то сбросим эту галку в исходное состояние, если не имеет прав согласования на статью расходов
//  if not(User.Roles([], [rPC_A_AgrAll]) or User.Roles([], [rPC_A_AgrSelfCat]) and (IntToStr(User.GetId) =ExpAgreed.Values[Cth.GetControlValue(cmb_ExpenseItem)]))
  //2023-11-26
  //в поле таблицы несколько пользователей через запятую, которые могут согласовывать по данной статье
  if not(User.Roles([], [rPC_A_AgrAll]) or User.Roles([], [rPC_A_AgrSelfCat]) and S.InCommaStr(IntToStr(User.GetId), ExpAgreed.Values[Cth.GetControlValue(cmb_ExpenseItem)]))
    then chb_Agreed1.Checked:= IsAgreed;
  if  (Cth.GetControlValue(edt_Account)<> '')and(Mode<>fDelete) then begin
    //проверим чтобы не было другого счета у того же поставщика с таким же номером при том же годе, взятом из даты выставления счета
    v1:= Q.QSelectOneRow(
      'select account from sn_calendar_accounts where id_supplier = :id_supplier and id <> :id and account = :account and extract (year from accountdt) = :year$i',
      [Cth.GetControlValue(cmb_Supplier), S.IIfInt(Mode = fEdit, ID, -1000), edt_Account.Text, YearOf(S.IIfV(Cth.DteValueIsDate(Dt_Account), Dt_Account.Value, Date))]
    );
    if v1[0] <> null  then begin
      if myQuestionMessage('Счет с таким же номером у этого поставщика уже есть. Вы уверены, что хотите сохранить данные?') <> mrYes then Exit;
    end;
  end;
  if Ok and not IfFilesLoaded then Ok:=False;
  if not Ok then Exit;
  NoErr:=False;
  try
  Q.QBeginTrans(True);
  if Mode = fEdit then begin
    ErrSql:=Q.QExecSql(Q.QSIUDSql('u', 'sn_calendar_accounts', FieldNames),
      [Cth.GetControlValue(cmb_Cash),
       Cth.GetControlValue(edt_Account),
       Cth.GetControlValue(cmb_Supplier),
       Cth.GetControlValue(cmb_Org),
       Cth.GetControlValue(cmb_ExpenseItem),
       Cth.GetControlValue(cmb_User),
       Cth.GetControlValue(nedt_Sum),
       Cth.GetControlValue(edt_Comm),
       Cth.GetControlValue(edt_File),
       Cth.GetControlValue(chb_Agreed1),
       Cth.GetControlValue(chb_Agreed2),
       Cth.GetControlValue(Dt_Account),
       Dt,
       AccMode,
       WhoAgreed,
       Cth.GetControlValue(cmb_NDS),
       ID
      ]);
    if ((AccMode = 1) or (AccMode = 2))and(ErrSql = 0) then begin
      ErrSql:=Q.QExecSql(Q.QSIUDSql('u', 'sn_calendar_accounts_t', 'id;cartype$i;flighttype$i;flightdt$d;kilometrage$f;idle$f;basissum$f;othersum$f;pricekm$f;priceidle$f'), [
        S.NullIfEmpty(Cth.GetControlValue(cmb_CarType)), S.NullIfEmpty(Cth.GetControlValue(cmb_Flight)), S.NullIfEmpty(Cth.GetControlValue(dedt_FlightDt)), S.NullIfEmpty(Cth.GetControlValue(nedt_Kilometrage)),
        S.NullIfEmpty(Cth.GetControlValue(nedt_Idle)), 0 ,S.NullIfEmpty(Cth.GetControlValue(nedt_SumOther)), S.NullIfEmpty(Cth.GetControlValue(nedt_PriceKm)), S.NullIfEmpty(Cth.GetControlValue(nedt_PriceIdle)), ID
      ]);
    end;
  end
  else if (Mode = fAdd) or (Mode = fCopy) then begin
    ID:=Q.QSelectId('sq_sn_calendar_accounts');
    ErrSql:=Q.QExecSql(Q.QSIUDSql('i', 'sn_calendar_accounts', FieldNames),
      [
       ID,
       Cth.GetControlValue(cmb_Cash),
       Cth.GetControlValue(edt_Account),
       Cth.GetControlValue(cmb_Supplier),
       Cth.GetControlValue(cmb_Org),
       Cth.GetControlValue(cmb_ExpenseItem),
       Cth.GetControlValue(cmb_User),
       Cth.GetControlValue(nedt_Sum),
       Cth.GetControlValue(edt_Comm),
       Cth.GetControlValue(edt_File),
       Cth.GetControlValue(chb_Agreed1),
       Cth.GetControlValue(chb_Agreed2),
       Cth.GetControlValue(Dt_Account),
       Dt,
       AccMode,
       WhoAgreed,
       Cth.GetControlValue(cmb_NDS)
   ]);
      ErrSql:=Q.QExecSql(Q.QSIUDSql('i', 'sn_calendar_accounts_t', 'id;cartype$i;flighttype$i;flightdt$d;kilometrage$f;idle$f;basissum$f;othersum$f;pricekm$f;priceidle$f;freeidletime$f'), [
        ID,
        S.NullIfEmpty(Cth.GetControlValue(cmb_CarType)), S.NullIfEmpty(Cth.GetControlValue(cmb_Flight)), S.NullIfEmpty(Cth.GetControlValue(dedt_FlightDt)), S.NullIfEmpty(Cth.GetControlValue(nedt_Kilometrage)),
        S.NullIfEmpty(Cth.GetControlValue(nedt_Idle)), 0 ,S.NullIfEmpty(Cth.GetControlValue(nedt_SumOther)), S.NullIfEmpty(Cth.GetControlValue(nedt_PriceKm)), S.NullIfEmpty(Cth.GetControlValue(nedt_PriceIdle)), MaxIdle
      ]);
  end
  else if Mode = fDelete then begin
    //удаляем счет, платежи удаляются по родительскому ключу в бд
    ErrSql:=Q.QExecSQL('delete from sn_calendar_accounts where id=:id', [ID]);
  end;
  if (Mode = fDelete)or(ErrSql = -1)
  then begin
  end
  else if (Mode<>fCopy)
    then begin
      for i:=0 to PaymentsCount-1 do begin
        //проход по платежам, которые были в прошлой версии счета
        v1:=Cth.GetControlValue(TControl(Self.FindComponent('Dt_'+IntToStr(i+1))));
        v2:=Cth.GetControlValue(TControl(Self.FindComponent('nedt_'+IntToStr(i+1))));
        if v2 = null then v2:=0; //на случай пустого контрола суммы
        if (v2 = 0) then begin
          //если сумма 0 или пустая, то удалим этот платеж
          ErrSql:=Q.QExecSQL('delete from sn_calendar_payments where id=:id', [Payments[i][0]]);
        end
        else if (Payments[i][1]<>v1)or(Payments[i][2]<>v2) then begin
          //иначе, если изменилась сумма или дата, то обновим в бд
          ErrSql:=Q.QExecSQL('update sn_calendar_payments set dt=:dt, sum=:sum where id=:id', [v1, v2, Payments[i][0]]);
        end;
      end;
      for i:=PaymentsCount to 9 do begin
        //занесем в бд вновь добавленные платежи, если они не пустые или не 0
        v1:=Cth.GetControlValue(TControl(Self.FindComponent('Dt_'+IntToStr(i+1))));
        v2:=Cth.GetControlValue(TControl(Self.FindComponent('nedt_'+IntToStr(i+1))));
        if v2 = null then v2:=0;
        if v2 > 0 then begin
          IDpm:=Q.QSelectId('sq_sn_calendar_payments');
          ErrSql:=Q.QExecSQL('insert into sn_calendar_payments (id, id_account, dt, sum, status) values (:id, :id_account, :dt, :sum, 0)', [IDpm, ID, v1, v2]);
        end;
      end;
    end
    else begin
      //в случае копирования занесем все платежи
      for i:=0 to 9 do begin
        v1:=Cth.GetControlValue(TControl(Self.FindComponent('Dt_'+IntToStr(i+1))));
        v2:=Cth.GetControlValue(TControl(Self.FindComponent('nedt_'+IntToStr(i+1))));
        if v2 = null then v2:=0;
        if v2 > 0 then begin
          IDpm:=Q.QSelectId('sq_sn_calendar_payments');
          ErrSql:=Q.QExecSQL('insert into sn_calendar_payments (id, id_account, dt, sum, status) values (:id, :id_account, :dt, :sum, 0)', [IDpm, ID, v1, v2]);
        end;
      end;
    end;
    //по транспортным счетам
    if ((AccMode = 1) or (AccMode = 2))and(ErrSql = 0) then begin
      //по транспортным счетам - локации
      if (Mode<>fDelete)and(Mode<>fView)and(MemTableEh1.RecordCount>0)and(IsRouteGridEdited) then begin
        //сохраним в бд локации, которых нет в ранее загруженных при открытии счета
        MemTableEh1.RecNo:=1;
        st1:=MemTableEh1.FieldByName('point1').AsString;
        if (st1 <> '')and(PointInLocations(st1) < 0)
          then Q.QIUD('i', 'ref_sn_locations', 'sq_ref_sn_locations', 'id;name;type;active', [0, st1, AccMode, 1], False);
        for i:=1 to MemTableEh1.RecordCount do begin
          MemTableEh1.RecNo:=i;
          st1:=MemTableEh1.FieldByName('point2').AsString;
          if (st1 <> '')and(PointInLocations(st1) < 0)
            then Q.QIUD('i', 'ref_sn_locations', 'sq_ref_sn_locations', 'id;name;type;active', [0, st1, AccMode, 1], False);
        end;
      end;
      //сохраним грид маршрута
      if (Mode<>fDelete)and(Mode<>fView)and(MemTableEh1.RecordCount>0)and(IsRouteGridEdited) then begin
        if (Mode<>fAdd)and(Mode<>fCopy) then Q.QExecSQL('delete from sn_calendar_t_route where id_account = :id_account$i', [ID]);
        for i:=1 to MemTableEh1.RecordCount do begin
          MemTableEh1.RecNo:=i;
          if MemTableEh1.FieldByName('point1').AsString = '' then continue;
          v2:=VarArrayOf([
            ID,
            i,
            MemTableEh1.FieldByName('point1').AsString,
            AccMode,
            MemTableEh1.FieldByName('point1').AsString,
            MemTableEh1.FieldByName('point2').AsString,
            AccMode,
            MemTableEh1.FieldByName('point2').AsString,
            null,
            null,
            null
          ]);
          if DBGridEh1.Columns[1].Visible then begin
            v2[8]:=MemTableEh1.FieldByName('time1').AsDateTime;
            v2[9]:=MemTableEh1.FieldByName('time2').AsDateTime;
            v2[10]:=MemTableEh1.FieldByName('length').AsInteger;
          end;
          ErrSql:=Q.QExecSQL(
            'insert into sn_calendar_t_route (id_account, pos, point1, point2, dt1, dt2, kilometrage) '+
            'values (:id_account, :pos, '+
            'nvl('+
              '(select id from ref_sn_locations where name = :point1 and type = :accmode1), '+
              '(select id from ref_sn_locations where name = :point11 and type = 0)), '+
            'nvl('+
              '(select id from ref_sn_locations where name = :point2 and type = :accmode2), '+
              '(select id from ref_sn_locations where name = :point21 and type = 0)), '+
            ':dt1$d, :dt2$d, :kilometrage$i)',
            [v2]
          );
        end;
      end;
    end;
    //по транспортным и монтажным счетам
    if (A.InArray(AccMode, [1,2,3]))and(ErrSql = 0) then begin
      //сохраняем грид оснований
      if (Mode<>fDelete)and(Mode<>fView)and IsBasisGridEdited then begin
        if (Mode<>fAdd)and(Mode<>fCopy) then Q.QExecSQL('delete from sn_calendar_t_basis where id_account = :id_account$i', [ID]);
        for i:=1 to MemTableEh2.RecordCount do begin
          MemTableEh2.RecNo:=i;
          v2:=VarArrayOf([
            ID,
            i,
            S.IIfV(MemTableEh2.FieldByName('type').AsString = 'Заказ', MemTableEh2.FieldByName('id').AsInteger, null),
            S.IIfV(MemTableEh2.FieldByName('type').AsString = 'Счет', MemTableEh2.FieldByName('id').AsInteger, null),
            MemTableEh2.FieldByName('sum').AsFloat,
            MemTableEh2.FieldByName('prc').AsInteger
          ]);
          ErrSql:=Q.QExecSQL(
            'insert into sn_calendar_t_basis (id_account, pos, id_order, id_acc, sum_saved, prc) '+
            'values (:id_account, :pos, :id_order$i, :id_acc$i, :sum_saved, :prc)',
            [v2]
          );
        end;
      end;
    end;

  NoErr:=True;
  finally
  end;

  if NoErr and (ErrSql = 0)
    then Q.QCommitTrans
    else begin
      Q.QRollbackTrans;
      Exit;
    end;
//  Bt_OK.ModalResult:=mrOk;
//  Self.ModalResult:=mrOk;
// aModalResult:=mrOk;
  RefreshParentForm;
  Close;
end;

//когда может быть согласовано руководителем
function TDlg_Sn_Calendar.IsAgreed1Enabled: Boolean;
begin
  Result:=False;
  if Cth.GetControlValue(cmb_ExpenseItem) = null then Exit;
{  Result:=
    (User.IsDataEditor) or ((not chb_Agreed2.Checked) and
      (User.Roles([], [rPC_A_AgrAll]) or User.Roles([], [rPC_A_AgrSelfCat]) and (IntToStr(User.GetId) = S.IIFStr(S.NSt(Cth.GetControlValue(cmb_ExpenseItem)) ='', '', ExpAgreed.Values[Cth.GetControlValue(cmb_ExpenseItem)]))));
      }
  Result:=
    (User.IsDataEditor) or ((not chb_Agreed2.Checked) and
      (User.Roles([], [rPC_A_AgrAll]) or User.Roles([], [rPC_A_AgrSelfCat]) and (S.InCommaStr(IntToStr(User.GetId), ExpAgreed.Values[Cth.GetControlValue(cmb_ExpenseItem)]))));
end;

function TDlg_Sn_Calendar.PointInLocations(st: string): Integer;
var
  i, j:Integer;
  b: Boolean;
  st1: string;
begin
{st1:=Points0[0];
st1:=Points0.Names[0];
st1:=Points0.Values['2'];
  }
  Result:=Points0.IndexOf(st);
  if Result = -1 then Result:=Points1.IndexOf(st);
end;

function TDlg_Sn_Calendar.GetSum(Sender: TObject): Extended;
var
  i, j:Integer;
  b: Boolean;
begin
  Result:=0;
  for i:=1 to 10 do
    begin
      if ((Self.FindComponent('Dt_'+IntToStr(i)) as TDBDateTimeEditEh).text<>'  .  .    ') and
         (Self.FindComponent('nedt_'+IntToStr(i))<>Sender)
        then Result:=Result+(Self.FindComponent('nedt_'+IntToStr(i)) as TDBNumberEditEh).value;
    end;
  Result:= nedt_Sum.Value - Result;
  (Sender as TDBNumberEditEh).Value:= Result;
end;

procedure TDlg_Sn_Calendar.N1Click(Sender: TObject);
//вставка строки, маркер не ставим, автоматом пересчитано не будет, но если будет ввод в строке то пересчитается, а если уйти без ввода то строка удалится тк нет пост
begin
  MemTableEh1.Insert;
end;

procedure TDlg_Sn_Calendar.N2Click(Sender: TObject);
//удалени текущей строки, обязательно надо поставить маркер изменения данных
begin
  MemTableEh1.Delete;
  IsRouteGridChanged := True;
  IsRouteGridEdited:=True;
end;

procedure TDlg_Sn_Calendar.nedt_1Change(Sender: TObject);
var
  i, j:Integer;
begin
end;

procedure TDlg_Sn_Calendar.Verify;
var
  i, j:Integer;
  v1,v2:Variant;
  e:Extended;
  ok1, ok2: Boolean;
begin
//  Ok:=(nedt_Sum.Text<>'');
  Ok:=
    (cmb_Cash.Text<>'') and
    ((edt_Account.Text<>'') or (cmb_Cash.value='2')) and          //должен быть номер счета, или наличный расчет
    (cmb_Nds.Text<>'') and
    (not((cmb_Nds.Value<>'0') and (cmb_Cash.value='2'))) and     //нельзя ненулевое НДС при наличном расчете
    (cmb_Supplier.Text<>'') and
    (cmb_Org.Text<>'') and
    (cmb_User.Text<>'') and
    (cmb_ExpenseItem.Text<>'') and
    (nedt_Sum.Text<>'') and
    (edt_File.Text<>'') and
    (Dt_Account.Text<>'');
  lbl_General_Error.Visible:=not Ok;
  Ok1:=True;
  e:=0;
  for i:=1 to 10 do
    begin
      v1:=(Self.FindComponent('Dt_'+IntToStr(i)) as TDBDateTimeEditEh).text;
      v2:=(Self.FindComponent('nedt_'+IntToStr(i)) as TDBNumberEditEh).text;
      if StrToFloatDef(v2, 0)<0 then Ok1:=False;
      if ((v1<>'  .  .    ')and(v2=''))or((v1='  .  .    ')and(v2<>'')) then Ok1:=False;
      e:= e+StrToFloatDef(v2, 0)
    end;
  ok1:=Ok1 and (e = nedt_Sum.Value);
  lbl_Payments_Error.Visible:=not Ok1;
  lbl_Payments_T_Error.Visible:=lbl_Payments_Error.Visible;
  Ok:=Ok and Ok1;
  if (AccMode = 1)or(AccMode=2) then begin
    //для транспортных счетов
    Ok1:=(not lbl_Route_Error.Visible)and(cmb_CarType.Text<>'')and(cmb_Flight.Text<>'')and(dedt_FlightDt.value<>null);
    if nedt_Idle.visible
      then Ok1:=Ok1 and (nedt_Idle.Text<>'') and (nedt_PriceKm.Text<>'') and (nedt_PriceIdle.Text<>'') and (nedt_SumOther.Text<>'');
    lbl_Basis_Error.Visible:=False;
    Ok:=Ok and Ok1;
  end;
  if (AccMode = 3) then begin
    //для монтажных счетов
    Ok1:=True;
    //грид оснований может быть пустым, а больше дополнительных данных там нет
    lbl_Basis_Error.Visible:=False;
    Ok:=Ok and Ok1;
  end;
end;

procedure TDlg_Sn_Calendar.CalculateSumWoNds;
begin
  if (cmb_Nds.Text = '')or(nedt_Sum.Text = '')
    then nedt_SumWoNds.Value:=null
//    else nedt_SumWoNds.Value:= RoundTo(nedt_Sum.Value - (nedt_Sum.Value * cmb_Nds.Value /100), -2);
    else nedt_SumWoNds.Value:= RoundTo(nedt_Sum.Value / ((cmb_Nds.Value + 100)/100), -2);
end;


procedure TDlg_Sn_Calendar.ControlExit(Sender: TObject);
begin
  if (Sender = nedt_Sum)or(Sender = cmb_Nds) then CalculateSumWoNds;
  Verify;
end;

procedure TDlg_Sn_Calendar.DBGridEh1KeyPress(Sender: TObject; var Key: Char);
begin
//  if Key = #27 then Key:=#0;
end;

procedure TDlg_Sn_Calendar.DBGridEh2DblClick(Sender: TObject);
begin
  inherited;
  if MemTableEh2.RecordCount = 0 then Exit;
  if MemTableEh2.FieldByName('type').AsString <> 'Заказ' then Exit;
  Wh.ExecDialog(myfrm_Dlg_Order, Self, [], fView, MemTableEh2.FieldByName('id').AsInteger, null);
end;

procedure TDlg_Sn_Calendar.Dt1_KeyPress(Sender: TObject; var Key: Char);
var
  v: TVarDynArray;
  v1, v2: Variant;
  id_: Variant;
  i: Integer;
  st: string;
  dt, dt2: TDateTime;
begin
  if Key = ' ' then begin
//по пробелу планировалась текущая дата, но оказалось это неудобно
 //   TDBDateTimeEditEh(Sender).Value:=Now;
    Key:=#0;
  end
  else if Key = '=' then begin
    try
      if (Mode = fAdd) or (Mode = fCopy) then id_ :=0 else id_:=ID;
//      StrToDate(Cth.GetControlValue(TDBDateTimeEditEh(Sender)))
      dt:=TDBDateTimeEditEh(Sender).Value;
      v:=Q.QSelectOneRow('select sum(sum) from sn_calendar_payments where dt=:dt$d and id_account<>:id$i', [dt, id_]);
      if v[0] = Null then v[0]:=0;
      for i:=1 to 10 do
        begin
//          v1:=Cth.GetControlValue(TControl(Self.FindComponent('Dt_'+IntToStr(i))));
          st:=Cth.GetControlValue(TControl(Self.FindComponent('Dt_'+IntToStr(i))));
          if st<>'' then dt2:=StrToDateDef(st, S.BadDate);
          if dt2 = S.BadDate then Continue;
          v2:=(Self.FindComponent('nedt_'+IntToStr(i)) as TDBNumberEditEh).value;
          if v2 = null then Continue;
          if dt2 = dt then begin
            v[0]:=v[0]+v2;
          end;
//          dt2:=Cth.GetControlValue(TDBDateTimeEditEh(Self.FindComponent('Dt_'+IntToStr(i))));
{          if (v1 = null)or(v1 = '') then continue;
          v2:=(Self.FindComponent('nedt_'+IntToStr(i)) as TDBNumberEditEh).value;
          if v2 = null then v2:=0;
          if v1 = dt then begin
            v[0]:=v[0]+v2;
          end;    }
        end;
//      lbl_Payments.Caption
      st:='На ' + DateToStr(dt) + ' запланирована сумма ' + VarToStr(v[0]) + 'р.' + #10#13 + '(включая этот счет)';
      MyInfoMessage(st);
    except
      //lbl_Payments.Caption:='';
    end;
    Key:=#0;
  end;
end;

procedure TDlg_Sn_Calendar.Dt_T1Change(Sender: TObject);
begin
  if InLoadData then Exit;
  Dt_1.Value:=Dt_T1.Value;
end;

procedure TDlg_Sn_Calendar.Dt_T2Change(Sender: TObject);
begin
  if InLoadData then Exit;
  Dt_2.Value:=Dt_T2.Value;
end;

procedure TDlg_Sn_Calendar.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
var
  i, min, max: Integer;
begin
  Resize:=False;
  if AccMode = 0 then begin
    min:=pnl_Buttons.top + pnl_Buttons.Height + 40;
    max:=min;
  end
  else if A.InArray(AccMode, [1,2]) then begin
    min:=gb_Route.Top + gb_Additional.Height + pnl_Buttons.Height + 2*160 + 40 ;
    max:=1080;
  end
  else if A.InArray(AccMode, [3]) then begin
    min:=gb_Basis.Top + gb_Additional.Height + pnl_Buttons.Height + 1*160 + 40 ;
    max:=1080;
  end;
  if InLoadData then begin
    if NewHeight < min then NewHeight:=min;
    if NewWidth < 943 then NewWidth:=943;
  end;
  if NewWidth< 943 then Exit;
  Resize:=(min <= NewHeight)and(max>=NewHeight);
end;

procedure TDlg_Sn_Calendar.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //снимаем блокировку
  Settings.WriteProperty(FormDoc, 'Width_' + IntToStr(AccMode), IntToStr(Width));
  Settings.WriteProperty(FormDoc, 'Height_' + IntToStr(AccMode), IntToStr(Height));
  Q.DBLock(False, 'dlg_sn_calendar', VarToStr(id));
  Action := caFree;
  try
//    Wh.CloseMDIForm(Self);
  except
  end;
end;

procedure TDlg_Sn_Calendar.FormResize(Sender: TObject);
var
  i:Integer;
begin
  if AccMode = 0 then Exit;
  if A.InArray(AccMode, [1,2]) then begin
    i:=ClientHeight - (gb_Route.Top+gb_Payments_T.Height+gb_Additional.Height+pnl_Buttons.Height);
    gb_Route.Height:=i div 2;
    gb_Basis.Height:=i div 2;
  end;
  if A.InArray(AccMode, [3]) then begin
    i:=ClientHeight - (gb_Basis.Top+gb_Payments_T.Height+gb_Additional.Height+pnl_Buttons.Height);
    gb_Basis.Height:=i;
  end;
end;

procedure TDlg_Sn_Calendar.control_Exit(Sender: TObject);
begin
  Verify;
end;

procedure TDlg_Sn_Calendar.nedt_1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = ' ' then begin
    GetSum(Sender);
    Key:=#0;
  end
end;

procedure TDlg_Sn_Calendar.nedt_T1Change(Sender: TObject);
begin
  if InLoadData then Exit;
  nedt_1.Value:=nedt_T1.Value;
end;

procedure TDlg_Sn_Calendar.nedt_T2Change(Sender: TObject);
begin
  if InLoadData then Exit;
  nedt_2.Value:=nedt_T2.Value;
end;

procedure TDlg_Sn_Calendar.Bt_CancelClick(Sender: TObject);
begin
  Close;
end;

procedure TDlg_Sn_Calendar.Bt_FileAttachClick(Sender: TObject);
var
  st, st1, spath, zpath: string;
  b: Boolean;
begin
  OpenDialog1.Options:=[ofAllowMultiSelect, ofFileMustExist];
  if OpenDialog1.Execute then FileAttach(OpenDialog1.Files, True);
end;

procedure TDlg_Sn_Calendar.Bt_RefreshSuppliersClick(Sender: TObject);
var
  res, i, j: Integer;
  FName: string;
begin
  Q.QLoadToDBComboBoxEh('select legalname, id from ref_suppliers where active = 1 or id = :id order by legalname', [ID_Curr_Supplier], cmb_Supplier, cntComboLK);
  exit;

{
  res:= QOpen('select id, filename from sn_calendar_accounts', 0);
  while not MyData.QOra.EOF do
    begin
    try
      renamefile('\\10.1.1.14\all\Uchet\Учет\Files\Платежный календарь\'+mydata.qora.Fields[1].asstring,'\\10.1.1.14\all\Uchet\Учет\Files\Платежный календарь\'+mydata.qora.Fields[0].asstring);
    finally

    end;
      MyData.QOra.Next;
    end;
  QClose;
}
end;

procedure TDlg_Sn_Calendar.Bt_ReqestFileAttachClick(Sender: TObject);
var
  st, st1, spath, zpath: string;
  b: Boolean;
begin
  OpenDialog1.Options:=[ofAllowMultiSelect, ofFileMustExist];
  if OpenDialog1.Execute then FileAttach(OpenDialog1.Files, False);
end;



procedure TDlg_Sn_Calendar.FileAttach(Files:Tstrings; Mode: Boolean);
var
  spath, zpath: string;
  i: Integer;
begin
  try
  for i:=0 to Files.Count-1 do begin
    if FileExists(Files[i]) then begin
      spath:=Module.GetPath_Accounts_A(edt_File.Text);
      zpath:=Module.GetPath_Accounts_Z(edt_File.Text);
      ForceDirectories(spath);
      ForceDirectories(zpath);
      CopyFile(PChar(Files[i]), PChar(S.IIFStr(Mode, SPath, ZPath) + '\' + ExtractFileName(Files[i])), True);
    end
    else myMessageDlg('Файл не найден!', mtWarning, [mbOk]);
  end;
  finally
    IfFilesLoaded;
  end;
end;

function TDlg_Sn_Calendar.IfFilesLoaded: Boolean;
var
  a: TStringDynArray;
  b1, b2: Boolean;
begin
  Result:= True;  b1:=True; b2:=True;
  a:=Sys.GetFileInDirectoryOnly(Module.GetPath_Accounts_A(edt_File.Text));
  if Length(a) = 0
    then begin b1:=False; lbl_AccountFile.Caption:='Файл счета не загружен!'; end
    else lbl_AccountFile.Caption:='Файл счета загружен';
  a:=Sys.GetFileInDirectoryOnly(Module.GetPath_Accounts_Z(edt_File.Text));
  if Length(a) = 0
    then begin
      if (cmb_ExpenseItem.ItemIndex = -1)or(cmb_RecReceipt.Items[cmb_ExpenseItem.ItemIndex] = '1')
        then if nedt_sum.Value > Module.GetCfgVar(mycfgPCsum_need_req) then b2:=False;
      lbl_RequestFile.Caption:='Файл заявки не загружен!';
    end
    else lbl_RequestFile.Caption:='Файл заявки загружен';
  if b1 then lbl_AccountFile.Font.Color:=clWindowText else lbl_AccountFile.Font.Color:=RGB(240,0,0);
  if b2 then lbl_RequestFile.Font.Color:=clWindowText else lbl_RequestFile.Font.Color:=RGB(240,0,0);
  Result:=b1 and b2;
end;

procedure TDlg_Sn_Calendar.Image1MouseEnter(Sender: TObject);
begin
  TImage(Sender).ShowHint:=True;
end;

procedure TDlg_Sn_Calendar.Image1MouseLeave(Sender: TObject);
begin
  TImage(Sender).ShowHint:=False;
end;

procedure TDlg_Sn_Calendar.Bt_FileOpenClick(Sender: TObject);
var
  st: string;
  b: Boolean;
begin
  Sys.OpenFileOrDirectory(Module.GetPath_Accounts_A(edt_File.Text), 'Файл счета не найден!');
end;

procedure TDlg_Sn_Calendar.Bt_ReqestFileOpenClick(Sender: TObject);
begin
  Sys.OpenFileOrDirectory(Module.GetPath_Accounts_Z(edt_File.Text), 'Файл заявки не найден!');
end;

procedure TDlg_Sn_Calendar.Bt_SelectSupplierClick(Sender: TObject);
begin
//++
  Wh.SelectDialogResult:=[];
  Wh.ExecReference(myfrm_R_Suppliers_SELCH);
  if Length(Wh.SelectDialogResult) = 0 then Exit;
  Q.QLoadToDBComboBoxEh('select legalname, id from ref_suppliers where active = 1 or id = :id order by legalname', [ID_Curr_Supplier], cmb_Supplier, cntComboLK);
  cmb_Supplier.Text:=Wh.SelectDialogResult[1];
end;

procedure TDlg_Sn_Calendar.cmb_ExpenseItemChange(Sender: TObject);
//сбросим галку согласовано руководителем и задисаблим для статей для которых нельзя поставить
begin
  if inloaddata then exit;
  chb_Agreed1.Enabled:=IsAgreed1Enabled;
  if not chb_Agreed1.Enabled then chb_Agreed1.Checked:=False;
end;

procedure TDlg_Sn_Calendar.cmb_FlightChange(Sender: TObject);
//при изменении комбобокса
//запретим сбросить значение в пустое
//если же меняется на противоположное, то спросим
begin
//exit;
  if InLoadData then Exit;
  if (cmb_Flight.Text = '')and(OldFlight <> '')
    then begin
      cmb_Flight.Text := OldFlight;
      Exit;
    end;
  if OldFlight <> cmb_Flight.Text then begin
  {
    if (OldFlight = '') or (MyQuestionMessage('Данные маршрута будут частично утеряны! продолжить?') = mrYes)
      then begin
        SetRouteGridType;
      end
      else cmb_Flight.Text := OldFlight;
    }
    IsRouteGridChanged:=True;
    IsRouteGridEdited:=True;
    SetRouteGridType;
    MemTableEh1AfterEditCorrectData;
  end;
  if cmb_Flight.Text<>'' then OldFlight:=cmb_Flight.Text;
end;

procedure TDlg_Sn_Calendar.chb_Agreed1Click(Sender: TObject);
begin
  inherited;
  if chb_Agreed1.Checked
    then begin
      chb_Agreed1.Caption:=User.GetName;
      WhoAgreed:=User.GetId;
    end
    else begin
      chb_Agreed1.Caption:='Руководитель';
      WhoAgreed:=null;
    end;
end;

procedure TDlg_Sn_Calendar.SetBasisGrid;
var
  i: Integer;
begin
  Mth.AddGridColumn(DBGridEh2, 'id', 'id', 60, True);
  Mth.AddGridColumn(DBGridEh2, 'type', 'Тип', 60, True);
  Mth.AddGridColumn(DBGridEh2, 'name', 'Основание', 400, True);
  Mth.AddGridColumn(DBGridEh2, 'prc', '%', 60, True);
  Mth.AddGridColumn(DBGridEh2, 'sum', 'Сумма', 60, True);
//  for i:=0 to DBGridEh2.Columns.Count-1 do DBGridEh1.Columns[i].OnUpdateData:=  DBGridEh1ColumnsUpdateData;
  MemTableEh2.Close;
  MemTableEh2.FieldDefs.Clear;
  MemTableEh2.FieldDefs.Add('id', ftInteger, 0, False);
  MemTableEh2.FieldDefs.Add('type', ftString, 6, False);
  MemTableEh2.FieldDefs.Add('name', ftString, 400, False);
  MemTableEh2.FieldDefs.Add('prc', ftInteger, 0, False);
  MemTableEh2.FieldDefs.Add('sum', ftFloat, 0, False);
  MemTableEh2.CreateDataSet;
  MemTableEh2.Active:=True;
//  DBGridEh1.Columns[5].ReadOnly:=True;
  MemTableEh2.ReadOnly:=False;
  DBGridEh2.OptionsEh:=DBGridEh1.OptionsEh+[dghShowRecNo];
  DBGridEh2.OptionsEh:=DBGridEh1.OptionsEh+[dghEnterAsTab];
  DBGridEh2.ShowHint:=True;
  DBGridEh2.ColumnDefValues.ToolTips:=True;
  DBGridEh2.TitleParams.FillStyle:=cfstGradientEh;
  DBGridEh2.TitleParams.SecondColor:=clSkyBlue;
  DBGridEh2.TitleParams.Color:=clWindow;
  DBGridEh2.TitleParams.MultiTitle:=False;
 //перемещение столбцов
  DBGridEh2.OptionsEh:=DBGridEh1.OptionsEh-[dghColumnMove];
  //изменение ширины столбцов
  DBGridEh2.OptionsEh:=DBGridEh1.OptionsEh-[dghColumnResize];
  //автоподгонка ширины столбцов чтобы они занимали всю ширину видимой области грида, а не выходили за пределы видимой области
  DBGridEh2.AutoFitColWidths:=True;
  //автоподгонка ширины столбцовюю
  for i:=0 to 4 do begin
    DBGridEh2.Columns[i].AutoFitColWidth:=(i in [2]);     //использовать этот столбец для подгонки
  end;
  DBGridEh2.Columns[0].visible:=False;
  DBGridEh2.ReadOnly:=True;
  DBGridEh2.Enabled:=(Mode<>fView)and(Mode<>fDelete);
end;

procedure TDlg_Sn_Calendar.SetRouteGrid;
var
  i: Integer;
  PointsIfTO: Boolean;
begin
  DBGridEh1.TitleParams.MultiTitle:=False;
  Mth.AddGridColumn(DBGridEh1, 'point1', 'Пункт отправки', 100, True);
  Mth.AddGridColumn(DBGridEh1, 'time1', 'Дата и время убытия', 110, True);
  Mth.AddGridColumn(DBGridEh1, 'point2', 'Пункт назначения', 100, True);
  Mth.AddGridColumn(DBGridEh1, 'time2', 'Дата и время прибытия', 110, True);
  Mth.AddGridColumn(DBGridEh1, 'length', 'Расстояние, км', 50, True);
  Mth.AddGridColumn(DBGridEh1, 'idle', 'Время простоя', 50, True);

  for i:=0 to DBGridEh1.Columns.Count-1 do DBGridEh1.Columns[i].OnUpdateData:=  DBGridEh1ColumnsUpdateData;

  MemTableEh1.Close;
  //очистим определение полей
  MemTableEh1.FieldDefs.Clear;
  //определяем поля
  MemTableEh1.FieldDefs.Add('point1', ftString, 400, False);
  MemTableEh1.FieldDefs.Add('time1', ftDateTime, 0, False);
  MemTableEh1.FieldDefs.Add('point2', ftString, 400, False);
  MemTableEh1.FieldDefs.Add('time2', ftDateTime, 0, False);
  MemTableEh1.FieldDefs.Add('length', ftInteger, 0, False);
  MemTableEh1.FieldDefs.Add('idle', ftFloat, 0, False);
  MemTableEh1.CreateDataSet;
  //заполним поля из массива
  InRouteGridEdit1:=True;
  MemTableEh1.Active:=True;
  for i:=1 to 0 do begin
    MemTableEh1.Insert;
    MemTableEh1.Post;
  end;
  MemTableEh1.First;

  //выпадающие списки локаций
  PointsIfTO:=True; //нужен ли список локаций для транспорта ТО
  for i:=0 to Points0.Count - 1 do begin
//    DBGridEh1.Columns[0].PickList.Add(Points0.ValueFromIndex[i]);
    DBGridEh1.Columns[0].PickList.Add(Points0[i]);
    DBGridEh1.Columns[2].PickList.Add(Points0[i]);
  end;
  if PointsIfTO or (AccMode = 2) then
    for i:=0 to Points1.Count - 1 do begin
      DBGridEh1.Columns[0].PickList.Add(Points1[i]);
      DBGridEh1.Columns[2].PickList.Add(Points1[i]);
    end;
  InRouteGridEdit1:=False;
end;

procedure TDlg_Sn_Calendar.SetRouteGridType;
//установим вид грида в зависимости от вида счета и вида рейса
var
  i:Integer;
begin
  DBGridEh1.Enabled:=(cmb_Flight.value <> '')and(Mode<>fView)and(Mode<>fDelete);
  DBGridEh1.Columns[1].Visible:=(cmb_Flight.value = '1')and(AccMode = 1);
  DBGridEh1.Columns[3].Visible:=DBGridEh1.Columns[1].Visible;
  DBGridEh1.Columns[4].Visible:=DBGridEh1.Columns[1].Visible;
  DBGridEh1.Columns[5].Visible:=DBGridEh1.Columns[1].Visible;
  DBGridEh1.Columns[5].ReadOnly:=True;
  MemTableEh1.ReadOnly:=False;
  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh+[dghShowRecNo];
  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh+[dghEnterAsTab];
  DBGridEh1.ShowHint:=True;
  DBGridEh1.ColumnDefValues.ToolTips:=True;
  DBGridEh1.TitleParams.FillStyle:=cfstGradientEh;
  //DBGridEh1.TitleParams.MultiTitle:=True;
  DBGridEh1.TitleParams.SecondColor:=clSkyBlue;
  DBGridEh1.TitleParams.Color:=clWindow;
 //перемещение столбцов
  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh-[dghColumnMove];
  //изменение ширины столбцов
  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh-[dghColumnResize];
  //автоподгонка ширины столбцов чтобы они занимали всю ширину видимой области грида, а не выходили за пределы видимой области
  DBGridEh1.AutoFitColWidths:=True;
  //автоподгонка ширины столбцовюю
  for i:=0 to 5 do begin
    DBGridEh1.Columns[i].AutoFitColWidth:=(i in [0,2]);     //использовать этот столбец для подгонки
  end;
  nedt_Idle.Enabled:=False;
  nedt_Idle.Visible:=DBGridEh1.Columns[1].Visible;
  nedt_Kilometrage.Enabled:=not nedt_Idle.Visible;
  dedt_FlightDt.Enabled:=not nedt_Idle.Visible;
  nedt_PriceKm.Visible:=nedt_Idle.Visible;
  nedt_PriceIdle.Visible:=nedt_Idle.Visible;
  nedt_SumOther.Visible:=nedt_Idle.Visible;
  if not nedt_Idle.Visible then begin
    nedt_Idle.Value:=null;
    nedt_PriceKm.Value:=null;
    nedt_PriceIdle.Value:=null;
    nedt_SumOther.Value:=null;
    pnl_Route.Height:=nedt_Idle.top+nedt_Idle.Height+10;
  end
  else begin
    pnl_Route.Height:=nedt_SumOther.Top+nedt_SumOther.Height+10;
  end;
end;


procedure TDlg_Sn_Calendar.SetRouteGridEditable;
//установим редактируемость грида, в зависимости от положения выбранной ячейки (от столба, и строки)
begin
  //Нужно!!! иначе не будет работать правка в гриде при изменении данных
  MemTableEh1.Edit;
  //по столбцам
  //первй столбец (пунк отправления) редактируемый только на первой строке
  //важно именно MemTableEh1.RecNo <> 1 чтобы редактировать только в первой строке, так как превая строка это 1, и может быть еще и 0 не знаю в каком это случае но он проскакивает
  if not InRouteGridEdit1 then DBGridEh1.Columns[0].ReadOnly:=(MemTableEh1.RecNo <> 1);
  exit;
  {
   MemTableEh1.ReadOnly:=(DBGridEh1.Col in [1,3,6,8]);
  //разрешим редактировать пункт отправки в первой строке
  if (DBGridEh1.Col = 1) and (MemTableEh1.RecNo <= 1)  //в пустом гриде будет RecNo=-1
    then MemTableEh1.ReadOnly:=False;
  //если это изменение не вручную а из кода, то разрешим редактирование в любом случае
  if InRouteGridEdit or InRouteGridEdit1
    then MemTableEh1.ReadOnly:=False;
  if not(InRouteGridEdit or InRouteGridEdit1 or MemTableEh1.ReadOnly) then MemTableEh1.Edit;
  }
end;

procedure TDlg_Sn_Calendar.DBGridEh1ColEnter(Sender: TObject);
//вызывается при изменении текущего столбца (позиция)
begin
  SetRouteGridEditable;
end;

procedure TDlg_Sn_Calendar.MemTableEh1AfterScroll(DataSet: TDataSet);
//вызывается при перемещении по строкам
var
  st: string;
begin
//  if InRouteGridEdit1 then Exit;
  SetRouteGridEditable;
  {
  Exit;
  //при перемещении делаем пост, строки при этом будут добаляться автоматом при перемещении вниз,
  //это нужно из-за того что должны поддерживаться изменения в соседних строках при редактировании
  if not InRouteGridEdit then begin
    if not MemTableEh1.ReadOnly then begin
      Mth.Post(MemTableEh1);
      //MemTableEh1.Edit;
    end;
  end;
  SetRouteGridEditable;
  }
end;


procedure TDlg_Sn_Calendar.MenuItem1Click(Sender: TObject);
//вставить строку для грида оснований
begin
  FrmCWAcoountBasis.ShowDialog(Self, ID, fAdd, AccMode);
end;

procedure TDlg_Sn_Calendar.MenuItem2Click(Sender: TObject);
begin
  if MemTableEh2.RecordCount = 0 then Exit;
  MemTableEh2.Delete;
  BasisTableGetSum;
  isBasisGridEdited:=True;
end;

procedure TDlg_Sn_Calendar.MemTableEh1AfterEdit(DataSet: TDataSet);
begin
//  MemTableEh1AfterEditCorrectData;
end;

procedure TDlg_Sn_Calendar.MemTableEh1AfterEditCorrectData;
var
  rn, i, j, km: Integer;
  tm: extended;
  st1, st2: string;
  point2prev: string;
  time1next: TDateTime;
  f:extended;
  b,b1,b2,b3,err: Boolean;
  ilast, iempty: Integer;
  vmode: Boolean;
  dtflight: TDateTime;
function IsRowEmpty(rn: Integer): Boolean;
var
  i:byte;
begin
  Result:=True;
  for i:=1 to MemTableEh1.FieldCount - 1 do
    if MemTableEh1.Fields[i].AsString <> ''
      then Result:= False;
end;
function IsRowEmpty2: Boolean;
var
  st: string;
begin
  st:= MemTableEh1.Fields[0].AsString + MemTableEh1.Fields[2].AsString;
  if vmode then st:= st + MemTableEh1.Fields[1].AsString + MemTableEh1.Fields[3].AsString + MemTableEh1.Fields[4].AsString;
  Result:=(st = '');
end;
begin
//exit;
  if InRouteGridEdit1 then exit;
  if not IsRouteGridChanged then exit;
  vmode:=DBGridEh1.columns[1].Visible;
  IsRouteGridChanged:=False;
  InRouteGridEdit1:=True;
  MemTableEh1.ReadOnly:=False;
//  Mth.Post(MemTableEh1);
  rn:= MemTableEh1.RecNo;
  for i:=1 to MemTableEh1.RecordCount - 0 do begin
    MemTableEh1.RecNo:=i;
    if (i>1)and(MemTableEh1.FieldByName('point1').AsString <> point2prev) then begin
      if IsRowEmpty2
        then MemTableEh1.FieldByName('point1').AsString := ''
        else MemTableEh1.FieldByName('point1').AsString := point2prev;
      MemTableEh1.Post;
    end;
    point2prev:=MemTableEh1.FieldByName('point2').AsString;
  end;
  for i:=MemTableEh1.RecordCount - 0 downto 1 do begin
    MemTableEh1.RecNo:=i;
    if (i<MemTableEh1.RecordCount) then begin
      st1:='';
      if (MemTableEh1.FieldByName('time2').AsString <> '')and(int(Time1next)<>0)
        then st1:=FloatToStr(SimpleRoundTo((Time1next - MemTableEh1.FieldByName('time2').AsDateTime)*24, -2));
      if MemTableEh1.FieldByName('idle').AsString <> st1 then begin
        MemTableEh1.FieldByName('idle').AsString := st1;
        MemTableEh1.Post;
      end;
    end;
    time1next:=MemTableEh1.FieldByName('time1').AsDateTime;
  end;
  //проверим введены ли все данные и посчитаем итоги
  b1:=False; b2:=False;
  err:=(MemTableEh1.RecordCount = 0);
  km:=0; tm:=0;
  ilast:=MemTableEh1.RecordCount;
  iempty:=ilast;
  dtflight:=EncodeDate(3000,1,1);;
  for i:=MemTableEh1.RecordCount - 0 downto 1 do begin
    MemTableEh1.RecNo:=i;
    //пропустим пустые строки с конца таблицы
    if not IsRowEmpty2 then b1:=True;
    if b1 then begin
      //если не пустая в конце таблицы, то должны быть заполнены все поля ввода
      b2:=(MemTableEh1.Fields[0].AsString <> '') and (MemTableEh1.Fields[2].AsString <> '');
      if vmode then
        b2:=b2 and (MemTableEh1.Fields[1].AsString <> '') and (MemTableEh1.Fields[3].AsString <> '') and (MemTableEh1.Fields[4].AsString <> '');
      if not b2 then begin
        err:=True;
        Break;
      end
      else if vmode then begin
        //посчитаем километраж и простой
        km:=km + MemTableEh1.Fields[4].AsInteger;
        tm:=tm + MemTableEh1.Fields[5].AsFloat;
        if MemTableEh1.Fields[1].AsDateTime<dtflight then dtflight:=MemTableEh1.Fields[1].AsDateTime;
        if MemTableEh1.Fields[3].AsDateTime<dtflight then dtflight:=MemTableEh1.Fields[3].AsDateTime;
      end;
    end;
  end;
  //если вся таблица пуста то тоже ошибка
  err:=err or not b1;  //b1 - таблица пуста
  //итоги километража и простоя
  if vmode then begin
    if err then begin
      nedt_Kilometrage.Value:=null;
      nedt_Idle.Value:=null;
      dedt_FlightDt.Value:=null;
    end
    else begin
      nedt_Kilometrage.Value:=km;
      nedt_Idle.Value:=tm;
      dedt_FlightDt.Value:=int(dtflight);
    end;
  end;
  MemTableEh1.RecNo:=rn;
  DBGridEh1.Columns[0].ReadOnly:=(MemTableEh1.RecNo>1);
  lbl_Route_Error.Visible:=err;
  InRouteGridEdit1:=False;
end;


procedure TDlg_Sn_Calendar.DBGridEh1ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
//вызывается после ввода данных в грида (только при ручном вводе, не в мемтейбл в коде)
//если неверный формат, то сбросим (произойдет откат к ранее введенному значения, даже без cancel)
//строки и столбцы нумеруются с единицы

//если надо как в этом случае при вводе данных в одну ячейку скорректировать другие ячейки, то
//если ячейки в той же строке то можно это сделать здесь
//но если ячеки которые будут изменены находятся в других строках, то получается глюк при попытке навигации по строкам в мемтейбл
//произведенной в этом обработчике (emTableEh1.RecNo:=rn-1; MemTableEh1.Next;)
//(неважно напрямую здесь или же повесить процедупру допустим на пост и делать в обработчике афтередит, или при изменении столбца делать а здесь DBGridEh1.Col:=DBGridEh1.col+1)
//как выход нашел делать это в таймере, при установленном в этом обработчике флаге что было изменение,
//можно также при изменении строки/столбца, но тогда только при их изменениях обработается)
//всегда надо проверять на ошибочные данные ячейки в этой процедуре и в этом случае не выставлять флаг изменения, иначе может зациклиться в процедуре правки значсений, или в ней нужно также проверять тип данных

var
  NoErr:Boolean;
  dt1: TDateTime;
  st, fst: string;
  rn: Integer;
begin
  NoErr:=True;
  InRouteGridEdit:=True;
  //значение, введенное в столбце, в виде строки
  fst:=S.IIFStr(UseText, Text, Value);
  //Дата и время убытия и прибытия
  if pos('time', DBGridEh1.Columns[DBGridEh1.Col-1].Field.FieldName) = 1 then begin
    //проверим что это дата, обязательно со временем
    NoErr:=S.IsDateTime(fst,'DT');
    if not NoErr then begin
      //если это не так, пытаемся преобразовать из строки вида 1 12 23 12 30
      dt1:=S.SpacedStToDate(fst, True);
      NoErr:=(dt1<>S.BadDate);
      if NoErr then begin
        //получислось, подставим дату
        TColumnEh(Sender).Field.AsVariant:=dt1;
        Handled:=True; //обработано
      end
      else begin
        TColumnEh(Sender).Field.AsVariant:=null;
        Handled:=True;
      end;
    end;
    //в любом другом случае остался встроенный обработчик, он выдаст сообщение если дата/время неверная
    {
    if NoErr then begin
      //подставим в столбец даты без времени
      MemTableEh1.FieldByName('date1').AsDateTime:=int(TColumnEh(Sender).Field.AsDateTime);
    end;}
  end;
  //если столбец Пункт назначения, и это не последняя строка, то установим пункт отправки в следующей строке равной пункту назнчения в текущей
  if (DBGridEh1.Columns[DBGridEh1.Col-1].Field.FieldName = 'point2') then begin
  end;
  //были введены данные в ячейку грида
  if NoErr then IsRouteGridChanged:=True;
  IsRouteGridEdited:=True;  //если было любое редактирование, пометим что надо сохранить грид.
  InRouteGridEdit:=False;
end;

procedure TDlg_Sn_Calendar.DBGridEh1Enter(Sender: TObject);
begin
  MemTableEh1.Edit;
end;

procedure TDlg_Sn_Calendar.DBGridEh1Exit(Sender: TObject);
begin
//  if not MemTableEh1.ReadOnly then Mth.Post(MemTableEh1);
  Mth.Post(MemTableEh1);
//  IsRouteGridChanged:=False;
  //MemTableEh1.Edit;
end;

procedure TDlg_Sn_Calendar.DBGridEh1ColExit(Sender: TObject);
begin
//  Mth.Post(MemTableEh1);
//  IsRouteGridChanged:=False;
//  if not MemTableEh1.ReadOnly then MemTableEh1.Edit;
end;

procedure TDlg_Sn_Calendar.tmr1Timer(Sender: TObject);
begin
  if IsRouteGridChanged then begin
    Mth.Post(MemTableEh1);
    MemTableEh1AfterEditCorrectData;
  end;
end;


procedure TDlg_Sn_Calendar.BasisTableGetSum;
var
  rn, i, j: Integer;
  sum : extended;
begin
  rn:= MemTableEh2.RecNo;
  sum:=0;
  for i:=1 to MemTableEh2.RecordCount - 0 do begin
    MemTableEh2.RecNo:=i;
    sum:=sum + StrToFloatDef(MemTableEh2.FieldByName('sum').AsString, 0);
  end;
  MemTableEh1.RecNo:=rn;
  nedt_Basissum.Value:=sum;
end;




end.
