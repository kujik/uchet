unit D_Order;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Math, Dialogs, StdCtrls, Buttons, DBCtrlsEh, uData, uForms, uDBOra,
  uString, uMessages, System.Types, Vcl.ExtCtrls, ToolCtrlsEh,
  DBGridEhToolCtrls, DynVarsEh, GridsEh, DBAxisGridsEh, DBGridEh,
  MemTableDataEh, MemTableEh, Data.DB, Vcl.Menus,
  Vcl.Imaging.pngimage, V_MDI, DateUtils, Vcl.ComCtrls, Data.Win.ADODB,
  System.ImageList, Vcl.ImgList, IOUtils, EhLibVclUtils, DBGridEhGrouping,
  Vcl.Mask;

type
  TDlg_Order = class(TForm_MDI)
    pnl_Top: TPanel;
    Bt_Ok: TBitBtn;
    pnl_Bottom: TPanel;
    pnl_Center: TPanel;
    DataSource1: TDataSource;
    MemTableEh1: TMemTableEh;
    DBGridEh1: TDBGridEh;
    pnl_Header: TPanel;
    pnl_Header_3: TPanel;
    pnl_Header_Bottom: TPanel;
    pnl_Header_2: TPanel;
    pnl_Header_1: TPanel;
    cmb_Organization: TDBComboBoxEh;
    edt_OrderNum: TDBEditEh;
    cmb_OrderType: TDBComboBoxEh;
    cmb_Format: TDBComboBoxEh;
    cmb_Project: TDBComboBoxEh;
    cmb_CustomerName: TDBComboBoxEh;
    cmb_CustomerMan: TDBComboBoxEh;
    edt_CustomerContacts: TDBEditEh;
    cmb_CustomerLegalName: TDBComboBoxEh;
    edt_CustomerINN: TDBEditEh;
    edt_Account: TDBEditEh;
    dedt_Beg: TDBDateTimeEditEh;
    dedt_Otgr: TDBDateTimeEditEh;
    dedt_Change: TDBDateTimeEditEh;
    pnl_Header_5: TPanel;
    nedt_Trans_0: TDBNumberEditEh;
    nedt_Montage_0: TDBNumberEditEh;
    nedt_Sum: TDBNumberEditEh;
    nedt_AC_0: TDBNumberEditEh;
    pnl_Header_11: TPanel;
    mem_Comment: TDBMemoEh;
    pnl_Header_12: TPanel;
    DBGridEh2: TDBGridEh;
    lbl_Files: TLabel;
    Bt_Cancel: TBitBtn;
    pnl_Top_1: TPanel;
    edt_TemplateName: TDBEditEh;
    Il_Item_Status: TImageList;
    BitBtn1: TBitBtn;
    PopupMenu1: TPopupMenu;
    Pmi1_DeleteRow: TMenuItem;
    nedt_Items_0: TDBNumberEditEh;
    nedt_Items_M: TDBNumberEditEh;
    nedt_Items_D: TDBNumberEditEh;
    nedt_Items: TDBNumberEditEh;
    nedt_AC_M: TDBNumberEditEh;
    nedt_AC_D: TDBNumberEditEh;
    nedt_AC: TDBNumberEditEh;
    nedt_Montage_M: TDBNumberEditEh;
    nedt_Montage_D: TDBNumberEditEh;
    nedt_Montage: TDBNumberEditEh;
    nedt_Trans_M: TDBNumberEditEh;
    nedt_Trans_D: TDBNumberEditEh;
    nedt_Trans: TDBNumberEditEh;
    nedt_Discount: TDBNumberEditEh;
    nedt_SumWoNds: TDBNumberEditEh;
    edt_Manager: TDBEditEh;
    dedt_MontageBeg: TDBDateTimeEditEh;
    cmb_CashType: TDBComboBoxEh;
    edt_Address: TDBEditEh;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    Pmi1_ShowColumns: TMenuItem;
    cmb_EstimatePath: TDBComboBoxEh;
    DataSource2: TDataSource;
    MemTableEh2: TMemTableEh;
    Pm_Files: TPopupMenu;
    OpenDialog1: TOpenDialog;
    cmb_OrderReference: TDBComboBoxEh;
    edt_Complaints: TDBEditEh;
    N1: TMenuItem;
    Pmi1_LoadKB: TMenuItem;
    Pm_Format: TPopupMenu;
    Pmi_Format_LoadKB: TMenuItem;
    Pmi_Format_LoadKBLog: TMenuItem;
    Pmi_RecalcPrices: TMenuItem;
    nedt_Sum_Av: TDBNumberEditEh;
    Bt_CreateXLS: TBitBtn;
    nedt_Items_NoSgp: TDBNumberEditEh;
    lbl_OrderSaveStatus: TLabel;
    chb_ViewEmptyItems: TCheckBox;
    lbl_ITM: TLabel;
    Il_ItemsTypes: TImageList;
    Il_Columns: TImageList;
    dedt_MontageEnd: TDBDateTimeEditEh;
    nedt_Attention: TDBNumberEditEh;
    cmb_Area: TDBComboBoxEh;
    lbl_ItmStatus: TLabel;
    procedure BitBtn1Click(Sender: TObject);
    procedure Pm_FilesClick(Sender: TObject);
    procedure Bt_OkClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean);
    procedure ControlOnChange(Sender: TObject);
    procedure ControlOnExit(Sender: TObject);
    procedure Bt_CancelClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure MemTableEh1AfterEdit(DataSet: TDataSet);
    procedure MemTableEh1AfterScroll(DataSet: TDataSet);
    procedure DBGridEh1ColEnter(Sender: TObject);
    procedure DBGridEh1ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
    procedure DBGridEh1Exit(Sender: TObject);
    procedure DBGridEh1GetCellParams(Sender: TObject; Column: TColumnEh; AFont: TFont; var Background: TColor; State: TGridDrawState);
    procedure Pmi1_DeleteRowClick(Sender: TObject);
    procedure pnl_HeaderClick(Sender: TObject);
    procedure Pmi1_ShowColumnsClick(Sender: TObject);
    procedure DBGridEh2GetCellParams(Sender: TObject; Column: TColumnEh; AFont: TFont; var Background: TColor; State: TGridDrawState);
    procedure DBGridEh2DblClick(Sender: TObject);
    procedure DBGridEh1Enter(Sender: TObject);
    procedure edt_ComplaintsOpenDropDownForm(EditControl: TControl; Button: TEditButtonEh; var DropDownForm: TCustomForm; DynParams: TDynVarsEh);
    procedure edt_ComplaintsCloseDropDownForm(EditControl: TControl; Button: TEditButtonEh; Accept: Boolean; DropDownForm: TCustomForm; DynParams: TDynVarsEh);
    procedure Pmi_Format_LoadKBClick(Sender: TObject);
    procedure Pmi_Format_LoadKBLogClick(Sender: TObject);
    procedure Pmi_RecalcPricesClick(Sender: TObject);
    procedure Bt_CreateXLSClick(Sender: TObject);
    procedure chb_ViewEmptyItemsClick(Sender: TObject);
    procedure DBGridEh1Columns0GetCellParams(Sender: TObject; EditMode: Boolean; Params: TColCellParamsEh);
    procedure cmb_CustomerNameGetItemImageIndex(Sender: TObject; ItemIndex: Integer; var ImageIndex: Integer);
    procedure cmb_CustomerManGetItemImageIndex(Sender: TObject; ItemIndex: Integer; var ImageIndex: Integer);
    procedure cmb_CustomerLegalNameGetItemImageIndex(Sender: TObject; ItemIndex: Integer; var ImageIndex: Integer);
    procedure mem_CommentKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DBGridEh1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cmb_OrderTypeEditButtons0Click(Sender: TObject;
      var Handled: Boolean);
  private
    { Private declarations }
    IDOld: Variant;
    FieldsArr: TVarDynArray2;
    Customers: TVarDynArray2;
    CustomerContacts: TVarDynArray2;
    CustomerLegal: TVarDynArray2;
    InLoadData: Boolean;
    HeadDiff: Boolean;
//    RouteFields: TVarDynArray;
    CheckBoxFields: string;
    Ok: Boolean;
    IsTemplate: Boolean;
    Id_Org_Old: Variant;
    OrderSaved: Boolean;
    InMemTableEh1AfterScroll: Boolean;
    StdItems: TVarDynArray2;
    Organizations: TVarDynArray2; //свои организации
    Differences: string;           //различающиеся поля в заголовке, через запятую
    DifferencesText: string;       //все изменения паспорта, в текстовом виде, для отправки в письме
    IsTableOldRowDeleted: Integer;  //устанавливается, если было удаление строки в части таблицы, загруженной ранее (тогда надо сохранять всю таблицу из-за изменения слэшеей, а не только измененные)
    BegItemsCount: Integer;      //сколько строк таблицы изделий загружено первоначально (эти строки в режиме fEdit нельзя удалять)
    Fdb, Fmt: TVarDynArray;      //поля в бд и таблице соответственно, для чтения данных
    Fdbs, Fmts: TVarDynArray;    //поля в бд и таблице соответственно, для записи данных
    OldTableValues: TVarDynArray2;  //массив старых значений заказа, для получения различий в режиме редактирования
    DeletedItems: TVarDynArray2;  //массив айди и наименований для позиций, которые ранее были в заказе но были удалены. вновь созданные и удаленные сюда не попадают
    EnableDeleteItemInEdit: Boolean;  //разрешает удаление слеша, который был загружен ранее при редактировании (только режим редактирования, в для остальных или темплейтов не важен)
    EstimateDirs: TVarDynArray2;      //массив форматов стандартнх смет
    OrNum: string;                //номер заказа, который сохранен, получается в процедуре сохранения заказа
    OrderPath: string;            //имя каталога заказа, получается в процедуре Save;
    Id_Estimate: Integer;         //айди стандартной сметы
    ItemPrefix: string;           //префикс для наименований изделий
    Complaints: TVarDynArray2;     //все причины рекламаций из справочника, айд, наименование, 1 если выбрана на момент открытия заказа, 1 если выбрана на момент записи заказа
    LoadKBLogArr: TVarDynArray2;   //лог загрузки паспорта КБ
    ID_Itm: Variant;               //id заказа в программе ИТМ
    OrSyncWithITM: Boolean;       //если False, то не синхронизируем заказ с ИТМ (даже если у еного есть id_itm и он есть в бд итм), и ограничиваем некоторые други функции
    ItemsToEstimateChange: TVarDynArray;  //айди записей в заказе, для которых после сохранения заказа надо изменить/перезагрузить смету. пападают все добавленнные или измененныые в любых полях записи
    NoChangeItems: Boolean;       //если установлено, то нельзя менять наименования изделий и количества, добавлять строки. устанавливается сейчас, если статус в ИТМ >= Выполнен
    FOrderChanges, FOrderItemChanges: TVarDynArray2;
    FOrderTypes: TVarDynArray2;
    FNewOrderType: Integer;       //1 - новый формат заказа (использует список типов заказа, выбор своййств для расчета даты отгрузки)
    function Prepare: Boolean; override;
    function GetFieldsArrPos(FieldName: string): Integer;
    function GetBegValueFromFieldsArr(FieldName: string): Variant;
    //сохраняет в массиве конечное значение ANewFieldValue
    //запись ищет по любому полю (который задаются константами, напр cFieldName), для его значения AFindValue
    procedure SetFieldsArrValue(AFieldType: Integer; AFindValue: Variant; ANewFieldValue: Variant);
    function GetDiffColor: TColor;
    function PathToOrders: string;
    function GetDifferences: string;
    procedure HighlightDifferences;
    procedure LoadCustomer(DataType: Integer);
    procedure LoadComplaints;
    procedure SetComplaints;
    procedure GetComplaintsString;
    procedure GetEstimateList;
    procedure SetEstimateList(PreserveValue: Boolean = False);
    function Save: Boolean;
    function Save_ItmFinish: Boolean;
    function SaveOrderStages: Boolean;
    procedure EnableControls;
    procedure Verify(Sender: TObject; onInput: Boolean = False);
    procedure SetControlDisabled(c: TComponent; enable: Boolean);
    procedure LockStdFormat;
    procedure GetChangesText;
    function ExportPassportToXLSX(Open: Boolean = False; OnlyNot0: Boolean = False): Boolean;
    function SetTask: Boolean;
    procedure GetAddFiles;
    procedure ViewAddFile;
    function GetItemNum(r: Integer): string;
    function IsRowEmpty(r: Integer): Boolean;
    function IsItemValid(r: Integer): Boolean;
    procedure LoadStdItems;
    procedure LoadKnsThn;
    procedure CalculateTable;
    procedure CalculateTableRow;
    procedure EnableTablePopupMenu;
    procedure LoadTable;
    function VerifyTable: Boolean;
    function RenameSlashes: Boolean;
    procedure CorrectRowIfNameChanged(DisableOnly: Boolean = False);
    function IsTableChanged: Integer;
    function IsAddFilesChanged: Boolean;
    procedure SetTableChanges(fn: string);
    procedure SetSumInHeader;
    function SaveTable: Boolean;
    procedure CreateEstimateToItem(rn, id_item, id_item_itm, id_item_name: Integer);
    procedure LoadKB;
    procedure LoadKBLog;
    procedure SetAddTasksMenu;
    procedure SetOrderSaveStatusText(Text: string);
    procedure HideEmptyItems;
    function VerifyItm: Boolean;
    function  GetOrderTypeOldValue: Variant;
  public
    { Public declarations }
    constructor ShowDialog(aOwner: TComponent; aFormDoc: string; aMode: TDialogType; aID: Variant; AMyFormOptions: TMyFormOptions; aV: Variant);
  end;

var
  Dlg_Order: TDlg_Order;

implementation

uses
  StrUtils, uExcel, uTasks, D_Order_Complaints, uExcel2,
  uFrmOGselOrReglament, uWindows, D_LoadKBLog, uSys, uOrders, uFrmBasicMdi;

const
  cControl = 0;
  cBegValue = 1;
  cFieldName = 2;
  cFieldNameId = 3;
  cVerify = 4;
  cNewValue = 5;
  cEditable = 6;

  //максимальное количество слешей в таблице
  MaxTableRowCount = 998;
  VnDocPath = 'Внешние документы';



{$R *.dfm}

procedure TDlg_Order.BitBtn1Click(Sender: TObject);
var
  v: Variant;
  res, i, j, RecNo: Integer;
begin
  FOrderChanges := [];
    for i := 0 to High(FieldsArr) do
      if FieldsArr[i][cControl] <> '' then begin
        if FieldsArr[i][cControl] = 'dedt_Change' then
          Continue;
        if VarToStr(S.NullIfEmpty(Cth.GetControlValue(TControl(Self.FindComponent(FieldsArr[i][cControl]))))) = VarToStr(S.NullIfEmpty(FieldsArr[i][cBegValue])) then begin
        end
        else begin
        end;
        FOrderChanges := FOrderChanges + [[FieldsArr[i][cControl], TCustomDBEditEh(Self.FindComponent(FieldsArr[i][cControl])).ControlLabel.Caption, 0]];
      end;
  FOrderItemChanges := [['id', 'Добавлено изделие', 0], ['route', 'Производственный маршрут', 0], ['comm', 'Дополнение', 0],
     ['std', 'Стандарт', 0], ['nstd', 'Нестандарт', 0], ['price_pp', 'Цена Д/К в цене изделия', 0]];
  MemTableEh1.DisableControls;
  for i := 0 to MemTableEh1.Fields.Count - 1 do begin
    if Pos('_', Gh.GetGridColumn(DBGridEh1, MemTableEh1.Fields[i].fIELDName).Title.Caption) = 1 then Continue;
    if Pos('r', MemTableEh1.Fields[i].FieldName) = 1 then Continue;
    if A.InArray(MemTableEh1.Fields[i].FieldName, ['comm','std','nstd','price_pp']) then Continue;
    FOrderItemChanges := FOrderItemChanges + [[MemTableEh1.Fields[i].FieldName, Gh.GetGridColumn(DBGridEh1, MemTableEh1.Fields[i].FieldName).Title.Caption, 0]];
  end;
  MyInfoMessage(A.Implode(A.VarDynArray2ColToVD1(FOrderChanges,1), #13#10) + '================'#13#10 + A.Implode(A.VarDynArray2ColToVD1(FOrderiTEMChanges,1), #13#10));

  Exit;


  LoadKB;
  exit;

  ExportPassportToXLSX(True);
  Exit;

  GetDifferences;
  GetChangesText;
  MyInfoMessage(DifferencesText);
  Exit;

  //подготовим (удалим пустые с концы) и проверим таблицу, если VerifyTable не вернет ошибку, то проверим на Пусто/не изменено
  res := S.IIf(VerifyTable, IsTableChanged, -1);
  if res = -2 then begin
    MyInfoMessage('Вы должны заполнить в табличную часть паспорта!');
  end;
  if res = -1 then begin
    MyInfoMessage('Ошибка в табличной части паспорта!');
  end;
  if res = 0 then begin
    MyInfoMessage('Изменений в таблице не было!');
  end;
end;

procedure TDlg_Order.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  //Settings.SaveWindowPos(Self, FormDoc);
end;

function TDlg_Order.GetDiffColor: TColor;
begin
  Result := RGB(255, 255, 100);
end;

procedure TDlg_Order.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
//при закрытии формы, если не был сохранен заказ, для режимов добавления/изменения
//выдадим предупреждение в случае, если были изменены данные
var
  i: Integer;
begin
  if (not Self.Enabled) and (Mode <> fView) then begin
    CanClose := False;
    Exit;
  end;
  CanClose := True;
  //не удалось открыть, например, из-за блокировки
  if InPrepare then
    Exit;
  //заказ был сохранен по кнопке Ок
  if OrderSaved then
    Exit;
  if Mode in [fView, fDelete] then
    Exit;
  //получим, были ли различия в заголовке и теле
  GetDifferences;
  if not HeadDiff then
    i := IsTableChanged;
  //есть изменения заголовка, или таблица изменена и не пуста или были удалены позиции в таблице при редактировании
  //(это учитавает IsTableChanged)
  //сюда поадет еще и если в табличной части ошибка!
  if HeadDiff or not ((i = 0) or (i = -2)) or (Length(DeletedItems) > 0) then
    CanClose := MyQuestionMessage('Данные были изменены!'#13#10'Все равно закрыть документ?') = mrYes;
  if CanClose then
    OrderSaved := True;
  inherited;
end;

procedure TDlg_Order.FormResize(Sender: TObject);
begin
  inherited;
//  pnl_Header_1.Width:= (pnl_Header.Width - pnl_Header_3.Width - pnl_Header_4.Width - pnl_Header_5.Width) div 2;
  pnl_Header_1.Width := (pnl_Header.Width - pnl_Header_3.Width - pnl_Header_5.Width) div 2;
end;

constructor TDlg_Order.ShowDialog(aOwner: TComponent; aFormDoc: string; aMode: TDialogType; aID: Variant; AMyFormOptions: TMyFormOptions; aV: Variant);
begin
  IsTemplate := aV = 1;
  inherited Create(aOwner, aFormDoc, [myfoDialog, myfoRefreshParent, myfoSizeable, myfoEnableMaximize, myfoMultiCopy], aMode, aID, null);
end;

function TDlg_Order.GetFieldsArrPos(FieldName: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to High(FieldsArr) do
    if FieldsArr[i][cFieldName] = FieldName then begin
      Result := i;
      Exit;
    end;
end;

function TDlg_Order.GetBegValueFromFieldsArr(FieldName: string): Variant;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to High(FieldsArr) do
    if FieldsArr[i][cFieldName] = FieldName then begin
      Result := FieldsArr[i][cBegValue];
      Exit;
    end;
end;

procedure TDlg_Order.SetFieldsArrValue(AFieldType: Integer; AFindValue: Variant; ANewFieldValue: Variant);
//сохраняет в массиве конечное значение ANewFieldValue
//запись ищет по любому полю (который задаются константами, напр cFieldName), для его значения AFindValue
var
  i: Integer;
begin
  for i := 0 to High(FieldsArr) do
    if FieldsArr[i][AFieldType] = AFindValue then begin
      FieldsArr[i][cNewValue] := ANewFieldValue;
      Exit;
    end;
end;

procedure TDlg_Order.SetControlDisabled(c: TComponent; enable: Boolean);
begin
  if enable then begin
    TCustomDbEditEh(c).Enabled := True;
//    edt_CustomerINN.Color:=clWindow;  //так не получается, но строка ниже работает даже с датами и косбобоксами
    TDbEditEh(c).Color := clWindow;
  end
  else begin
    TCustomDbEditEh(c).Enabled := False;
    TDbEditEh(c).Color := RGB(220, 220, 220);
  end;
end;

procedure TDlg_Order.EnableControls;
var
  i: Integer;
begin
  for i := 0 to High(FieldsArr) do
    if FieldsArr[i][cControl] <> '' then begin
      if Mode in [fView, fDelete] then
        SetControlDisabled(Self.FindComponent(FieldsArr[i][cControl]), False)
      else begin
        if FieldsArr[i][cEditable] = -1 then
          SetControlDisabled(Self.FindComponent(FieldsArr[i][cControl]), False)
        else if FieldsArr[i][cEditable] = 1 then
          SetControlDisabled(Self.FindComponent(FieldsArr[i][cControl]), cmb_Organization.Value <> '-1');
      end;
    end;
end;

function TDlg_Order.Prepare: Boolean;
var
  i, j: Integer;
  v: Variant;
  FieldsL: string;
  va1, va2: TVarDynArray2;
  st: string;
  ShowPrices: Boolean;
  HasWarn: Boolean;
begin
  Result := False;
  //проверим блокировку, выйдем если нельзя взять (при попытке редактирования уйдет в просмотр, при удалении - выход)
  if FormDbLock = fNone then
    Exit;
  inLoadData := True;
  ;
  //показывать ли цены/суммы
  ShowPrices := (Mode <> fView) or (User.Role(rOr_J_Orders_V));

  //новывй формат данных заказа №1
  FNewOrderType := 0;
  if (cOrderNewTypeID > 0) then begin
    if (Mode in [fAdd, fCopy]) or IsTemplate or (ID >= cOrderNewTypeID) then
      FNewOrderType := 1;
  end;

  //массив
  //имя контрола, соответствующего полю, может быть пустым
  //начальное значение
  //поле по которому значение читается из базы, если пустое то не читается
  //поле, по которому значение контрола, если он есть, или cEndValue, записывается базу, може отстутсвовать
  //блокировка ввода в контроле и проверка
  // 0-любое значение, 1-должно быть, 2-должно быть, если не производственный заказ, 3-очищается в случае производственного заказа
  //значение, которое пишется в базу данных
  //разрешение редактирования
  // -1 - никогда, 0 - всегда кроме удаления/просмотра, 1-если не производство
  FieldsArr := [
    ['', null, 'id', '', -1, null, -1],
    ['', null, 'id_itm', '', -1, null, -1],
    ['', null, 'sync_with_itm', 'sync_with_itm$i', -1, null, -1],
    ['', null, 'year', '', -1, null, -1],
    ['', null, 'num', '', -1, null, -1],
    ['', null, 'ornum', '', -1, null, -1],
    ['', null, 'path', '', -1, null, -1],
    ['', null, 'in_archive', '', -1, null, -1],
    ['', null, 'ch', 'ch$s', -1, null, -1],
    ['', null, 'dt_end', '', -1, null, -1],
    ['', null, 'dt_to_sgp', '', -1, null, -1],
    ['', null, 'dt_from_sgp', '', -1, null, -1],
    ['', null, 'ndsd', 'ndsd$f', -1, null, -1],
    ['', null, 'id_status_itm', '', -1, null, -1],
    ['', null, 'status_itm', '', -1, null, -1],
    ['', null, 'ids_order_properties', 'ids_order_properties$s', -1, null, -1],
    ['', null, 'id_reglament', 'id_reglament$i', -1, null, -1],
    ['cmb_Organization', null, 'id_organization', 'id_organization$i', 1, null, 0],
    ['cmb_Area', null, 'area', 'area$i', 1, null, 0],
    ['edt_OrderNum', null, 'ornum', '', 1, null, 0],
    ['cmb_OrderReference', null, 'or_reference', 'or_reference$s', 1, null, 1],
    ['edt_Complaints', null, 'complaints', '', 1, null, 1],
    ['cmb_Format', null, 'id_format', 'id_format$i', 1, null, 0],
    ['cmb_EstimatePath', null, 'id_or_format_estimates', 'id_or_format_estimates$i', 1, null, 0],
    ['cmb_CustomerName', null, 'customer', '', 2, null, 1],
    ['cmb_CustomerMan', null, 'customerman', '', 2, null, 1],
    ['edt_CustomerContacts',  null, 'customercontact', '', 2, null, 1],
    ['cmb_CustomerLegalName', null, 'customerlegal', '', 0, null, 1],
    ['edt_CustomerINN', null, 'customerinn', '', 0, null, 1],
    ['edt_Account', null, 'account', 'account$s', 2, null, 1],
    ['cmb_OrderType', null, 'id_type', 'id_type$i', 1, null, 0],
    ['edt_Address', null, 'address', 'address$s', 2, null, 1],
    ['dedt_Beg', Date, 'dt_beg', 'dt_beg$d', 1, null, -1],
    ['dedt_Otgr', null, 'dt_otgr', 'dt_otgr$d', S.IIf(User.Role(rOr_D_Order_EditDtOtgr) or (FNewOrderType = 0), 1, -1), null, 0],
    ['dedt_MontageBeg', null, 'dt_montage_beg', 'dt_montage_beg$d', 2, null, 1],
    ['dedt_MontageEnd', null, 'dt_montage_end', 'dt_montage_end$d', 2, null, 1],
    ['dedt_Change', null, 'dt_change', 'dt_change$d', 0, null, -1],
    ['cmb_Project', null, 'project', 'project$s', 1, null, 0],
    ['nedt_Items_0', null, 'cost_i_0', 'cost_i_0$f', 0, null, -1],
    ['nedt_Items_M', null, 'm_i', 'm_i$f', 0, null, 1],
    ['nedt_Items_D', null, 'd_i', 'd_i$f', 0, null, 1],
    ['nedt_Items', null, 'cost_i', 'cost_i$f', 0, null, -1],
    ['nedt_Items_NoSgp', null, 'cost_i_nosgp', 'cost_i_nosgp$f', 0, null, -1],
    ['nedt_AC_0', null, 'cost_a_0', 'cost_a_0$f', 0, null, -1],
    ['nedt_AC_M', null, 'm_a', 'm_a$f', 0, null, 1],
    ['nedt_AC_D', null, 'd_a', 'd_a$f', 0, null, 1],
    ['nedt_AC', null, 'cost_a', 'cost_a$f', 0, null, -1],
    ['nedt_Montage_0', null, 'cost_m_0', 'cost_m_0$f', 0, null, 1],
    ['nedt_Montage_M', null, 'm_m', 'm_m$f', 0, null, 1],
    ['nedt_Montage_D', null, 'd_m', 'd_m$f', 0, null, 1],
    ['nedt_Montage', null, 'cost_m', 'cost_m$f', 0, null, -1],
    ['nedt_Trans_0', null, 'cost_d_0', 'cost_d_0$f', 0, null, 1],
    ['nedt_Trans_M', null, 'm_d', 'm_d$f', 0, null, 1],
    ['nedt_Trans_D', null, 'd_d', 'd_d$f', 0, null, 1],
    ['nedt_Trans', null, 'cost_d', 'cost_d$f', 0, null, -1],
    ['nedt_Sum', null, 'cost', 'cost$f', 0, null, -1],
    ['nedt_SumWoNds', null, 'cost_wo_nds', 'cost_wo_nds$f', 0, null, -1],
    ['nedt_Sum_Av', null, 'cost_av', 'cost_av$f', 0, null, 1],
    ['cmb_CashType', null, 'cashtype_add', 'cashtype$i', 2, null, 1],
    ['edt_Manager', User.GetName, 'managername', '', 0, null, -1],
    ['mem_Comment', null, 'comm', 'comm$s', 0, null, 0],
    ['nedt_Attention', 0, 'attention', 'attention$i', 0, null, -1],
    ['', User.GetID, 'id_manager', 'id_manager$i', 0, null, -1]
  ];
  //для шаблона добавим в массив данные по имени шаблона
  if IsTemplate then
    FieldsArr := FieldsArr + [['edt_TemplateName', null, 'templatename', 'templatename$s', 0, null, 0]];

  FieldsL := '';
  HasWarn := False;
  if (FNewOrderType = 1) then begin
    //подменим поле для типа заказа
    FieldsArr[GetFieldsArrPos('id_type'), cFieldName] := 'id_type2';
    FieldsArr[GetFieldsArrPos('id_type2'), cFieldNameId] := 'id_type2$i';
    FieldsArr := FieldsArr + [['', null, 'id_type', 'id_type$i', -1, null, -1]];
  end;

  if Mode in [fEdit, fCopy, fDelete, fView] then begin
    //создадим запрос
    for i := 0 to High(FieldsArr) do  begin
      if FieldsArr[i][cFieldName] <> '' then
        S.ConcatStP(FieldsL, FieldsArr[i][cFieldName], ', ');
    end;
    //получим данные из основной таблицы
    va1 := Q.QLoadToVarDynArray2('select ' + FieldsL + ' from v_orders where id = :id$i', [ID]);
    //заполним начальные значения полей
    j := 0;
    for i := 0 to High(FieldsArr) do
      if FieldsArr[i][cFieldName] <> '' then begin
        FieldsArr[i][cBegValue] := va1[0][j];
        if (FieldsArr[i][cFieldName] = 'dt_end') and (FieldsArr[i][cBegValue] <> null) and (Mode in [fEdit]) and not HasWarn then begin
          if not User.IsDeveloper then begin
            MyInfoMessage('Внимание! Этот заказ завершен, его редактирование невозможно!');
            HasWarn := True;
            Mode := fView;
          end
          else begin
            if MyQuestionMessage('Внимание! Этот заказ завершен!'#13#10'Вы все равно хотите редактировать его?') <> mrYes then
              Mode := fView;
            HasWarn := True;
          end;
        end
        else if (FieldsArr[i][cFieldName] = 'dt_from_sgp') and (FieldsArr[i][cBegValue] <> null) and (Mode in [fEdit]) and not HasWarn then begin
          if MyQuestionMessage('Внимание! Этот заказ полностью отгружен покупателю!'#13#10'Вы все равно хотите редактировать его?') <> mrYes then
            Mode := fView;
          HasWarn := True;
        end
        else if (FieldsArr[i][cFieldName] = 'dt_to_sgp') and (FieldsArr[i][cBegValue] <> null) and (Mode in [fEdit]) and not HasWarn then begin
          if MyQuestionMessage('Внимание! Этот заказ в полном составе принят на СГП!'#13#10'Вы все равно хотите редактировать его?') <> mrYes then
            Mode := fView;
          HasWarn := True;
        end;
        if not (Mode in [fEdit, fView, fDelete]) then begin
            //очистим поля, если это новый заказа или копия
          if (FieldsArr[i][cFieldName] = 'path') then
            FieldsArr[i][cBegValue] := '';
          if (FieldsArr[i][cFieldName] = 'in_archive') then
            FieldsArr[i][cBegValue] := '';
          if (FieldsArr[i][cFieldName] = 'dt_beg') then
            FieldsArr[i][cBegValue] := Date;
          if (FieldsArr[i][cFieldName] = 'managername') then
            FieldsArr[i][cBegValue] := User.GetName;
          if (FieldsArr[i][cFieldName] = 'id_manager') then
            FieldsArr[i][cBegValue] := User.GetId;
        end;
          //установим дату изменения
        if (FieldsArr[i][cFieldName] = 'dt_change') then
          if Mode = fEdit then
            FieldsArr[i][cBegValue] := Now
          else if not (Mode in [fEdit, fView]) then
            FieldsArr[i][cBegValue] := Null;
        inc(j);
      end;
  end;

  //!!! не разобрался как устанавливаются текущие значения, если были прочитаны начальные, но не было изменения, и это не контролы, сделал так
  FieldsArr[GetFieldsArrPos('id_reglament')][cNewValue] := FieldsArr[GetFieldsArrPos('id_reglament')][cBegValue];
  FieldsArr[GetFieldsArrPos('ids_order_properties')][cNewValue] := FieldsArr[GetFieldsArrPos('ids_order_properties')][cBegValue];

  //Синхронизируем ли заказа с ИТМ
  //для шаблона - всегда нет, для нового заказа или копии - по значению глобальной переменной, при редактировании - как было ранее,
  //но если синхронизация выключена глобально, то и по заказу тоже ваыключим.
  OrSyncWithITM := (GetBegValueFromFieldsArr('sync_with_itm') = 1);
  if IsTemplate
    then OrSyncWithITM := False
    else if Mode in [fAdd, fCopy]
      then OrSyncWithITM := SyncWithITM
        else OrSyncWithITM := OrSyncWithITM and SyncWithITM;
  //Установим в полях значение синхронизации с ИТМ для заказа - оно не может измениться после, и это значение запишется БД
  SetFieldsArrValue(cFieldName, 'sync_with_itm', S.IIf(OrSyncWithITM, 1, 0));
 (*
  //проверим доступность группы Номенклатра из CAD в ИТМ, иначе работать нельзя
  if SyncWithITM and (not IsTemplate) and not ((Mode in [fView, fDelete]) or ((Mode = fEdit) and (GetBegValueFromFieldsArr('id_itm') = null))) then begin
     //проверяем при включенной синхронизации, не шаблоне, не при просмотре и удалении заказа, и, в случае редактирования,
     //не проеряем если айди_итм = нулл - тк в этом случае синхронизация с итм выключится для этого заказа
     //если проверка не прошла, перейдем в режим просмотреа
    if not VerifyItm then Mode := fView;
  end;
*)
  //выведем метку ИТМ рядом с кнопками проведения заказа, если включена синхронизация, но не отключена для конкретного заказа
  lbl_ITM.Visible := OrSyncWithITM; //SyncWithITM and (not IsTemplate) and (not (Mode in [fView, fEdit]) or (GetBegValueFromFieldsArr('id_itm') <> null));
  //покажем статус заказа в ИТМ, подсветим красным если он уже Выполнен или далее
  //(в этом случае не будет полной синхронизации заказа с ИТМ, только заголовок)
  lbl_ITMStatus.Caption:=S.NSt(GetBegValueFromFieldsArr('status_itm'));
  //признак того, что нельзя редактировать состав заказа
  //(добавлять/удалять строки, изменять наименование, количество и галку Без сметы
  NoChangeItems:= (S.NNum(GetBegValueFromFieldsArr('id_status_itm')) >= cOrItmStatus_Completed) and (Mode = fEdit);
  if S.NNum(GetBegValueFromFieldsArr('id_status_itm')) < cOrItmStatus_Completed
    then lbl_ITMStatus.Font.Color:= clBlue
    else lbl_ITMStatus.Font.Color:= clRed;
  lbl_ITMStatus.Visible := OrSyncWithITM and (Mode = fEdit);

  Id_Org_Old := FieldsArr[GetFieldsArrPos('id_organization')][cBegValue];

  if FNewOrderType = 1 then begin
    FOrderTypes := Q.QLoadToVarDynArray2(
      'select id, need_ref, is_complaint, (select count(*) from order_reglaments where instr('','' || ids_types || '','',  '','' || t.id || '','') > 0 and active = 1) '+
      'from v_order_types t '+
      'where (active = 1 or id = :id$i) order by posall',
      [FieldsArr[GetFieldsArrPos('id_type2'), cBegValue]]
    );
    Q.QLoadToDBComboBoxEh('select name, id from v_order_types where (active = 1 or id = :id$i) order by posall', [FieldsArr[GetFieldsArrPos('id_type2'), cBegValue]], cmb_OrderType, cntComboLK);
  end
  else begin
    FOrderTypes := [[1, 0, 0], [2, 1, 1], [3, 0, 0]];
    Cth.AddToComboBoxEh(cmb_OrderType, [['новый', '1'], ['рекламация', '2'], ['эксперимент', '3']]);
  end;
  Cth.AddToComboBoxEh(cmb_CashType, [['наличные', '2'], ['безнал (нет счета)', '0'], ['безнал', '1']]);
  Q.QLoadToDBComboBoxEh('select name, id from or_formats where id = 0', [], cmb_Format, cntComboLK);
  Q.QLoadToDBComboBoxEh('select name, id from or_formats where id > 1 and (active = 1 or id = :id$i) order by name', [FieldsArr[GetFieldsArrPos('id_format'), cBegValue]], cmb_Format, cntComboLK, 1);
  Q.QLoadToDBComboBoxEh('select name, id from ref_sn_organizations where id = -1', [], cmb_Organization, cntComboLK);
  Q.QLoadToDBComboBoxEh('select name, id from ref_sn_organizations where id >= 0 and prefix is not null and (active = 1 or id = :id$i) order by name', [0{//!!!}], cmb_Organization, cntComboLK, 1);
  Organizations := Q.QLoadToVarDynArray2('select id, prefix, or_cashless, nds from ref_sn_organizations where id >= 0 and prefix is not null and (active = 1 or id = :id$i) order by name', [Id_Org_Old]);
  Q.QLoadToDBComboBoxEh('select shortname, id from ref_production_areas where active = 1 or id = :id$i order by id', [S.NInt(FieldsArr[GetFieldsArrPos('area'), cBegValue])], cmb_Area, cntComboLK);
  Q.QLoadToDBComboBoxEh('select name from or_projects where (active = 1 or name = :name$s) order by name', [FieldsArr[GetFieldsArrPos('project'), cBegValue]], cmb_Project, cntComboE);
  Customers := Q.QLoadToVarDynArray2('select name, id from ref_customers where active = 1 or name = :name$s order by name', [FieldsArr[GetFieldsArrPos('customer'), cBegValue]]);
  cmb_CustomerName.Images := Il_Columns;
  cmb_CustomerMan.Images := Il_Columns;
  cmb_CustomerLegalName.Images := Il_Columns;
  for i := 0 to High(Customers) do
    cmb_CustomerName.Items.Add(Customers[i][0]);
  CustomerContacts := Q.QLoadToVarDynArray2('select name, contact, id_customer, id from ref_customer_contact where active = 1 or name = :name$s order by name', [FieldsArr[GetFieldsArrPos('customerman'), cBegValue]]);
  CustomerLegal := Q.QLoadToVarDynArray2('select legalname, inn, id_customer, id from ref_customer_legal where active = 1 or legalname = :name$s order by legalname', [FieldsArr[GetFieldsArrPos('customerlegal'), cBegValue]]);

  //if not(Mode in [fDelete, fView]) then
  GetEstimateList;
  LoadComplaints;

  if Mode = fView then
    Differences := S.NSt(FieldsArr[GetFieldsArrPos('ch'), cBegValue]);

  //установим значения контролова по загруженным из БД данным
  for i := 0 to High(FieldsArr) do
    if FieldsArr[i][cControl] <> '' then
      Cth.SetControlValue(TControl(Self.FindComponent(FieldsArr[i][cControl])), FieldsArr[i][cBegValue]);

  //установим список смет, с сохранением занчения контрола
  SetEstimateList(True);
  //если копирование и организация выбрана, то сгенерируем номер заказа
  if (Mode = fCopy) and (Cth.GetControlValue(cmb_Organization) <> null) then
    edt_OrderNum.Text := Q.QSelectOneRow('select f_order_getnewnum(:dt$d, :id_org$i) from dual', [Date, Cth.GetControlValue(cmb_Organization)])[0];
  //установим данные, зависящие от типа заказа (рекламация)
  SetComplaints;


//  RouteFields:=
//    ['КС','МТ','СТ','РК','ПГ','ЛК'];
  CheckBoxFields := 'std;resale;sgp;nstd;wo_estimate;disassembled;control_assembly';

  if DBGridEh1.Columns.Count = 1 then begin
    Gh.SetGridOptionsDefault(DBGridEh1);
    MemTableEh1.FieldDefs.Clear;
    MemTableEh1.close;
    //заголовок, начинающейся с пробела, пишется вертикально
    Mth.AddTableColumn(DBGridEh1, 'id', ftInteger, 0, '_ID', 20, False);
    Mth.AddTableColumn(DBGridEh1, 'id_std', ftInteger, 0, 'id_std', 20, False);
    Mth.AddTableColumn(DBGridEh1, 'id_itm', ftInteger, 0, 'id_itm', 20, False);
    Mth.AddTableColumn(DBGridEh1, 'chg', ftString, 4000, 'chg', 20, False);
    Mth.AddTableColumn(DBGridEh1, 'status', ftString, 20, '*', 20, True);
    Mth.AddTableColumn(DBGridEh1, 'slash', ftString, 26, 'Паспорт', 90, True);
    Mth.AddTableColumn(DBGridEh1, 'prefix', ftString, 20, 'Префикс', 40, True);
    Mth.AddTableColumn(DBGridEh1, 'name', ftString, 400, 'Изделие', 400, True, True, True);
    Mth.AddTableColumn(DBGridEh1, 'price', ftFloat, 0, 'Цена', 50, ShowPrices);
    Mth.AddTableColumn(DBGridEh1, 'price_pp', ftFloat, 0, 'Втч'#13#10'Д/К', 50, ShowPrices);
    Mth.AddTableColumn(DBGridEh1, 'qnt', ftFloat, 0, 'Кол-во', 40, True);
    Mth.AddTableColumn(DBGridEh1, 'std', ftInteger, 0, 'Стд.', 30, True);
    Mth.AddTableColumn(DBGridEh1, 'nstd', ftInteger, 0, 'Н/стд.', 30, True);
    Mth.AddTableColumn(DBGridEh1, 'sgp', ftInteger, 0, 'С СГП', 30, True);
    Mth.AddTableColumn(DBGridEh1, 'disassembled', ftInteger, 0, 'В разборе', 40, True);
    Mth.AddTableColumn(DBGridEh1, 'control_assembly', ftInteger, 0, 'Контр. сборка', 30, True);
    for i := 0 to High(RouteFields) do begin
      Mth.AddTableColumn(DBGridEh1, 'r' + IntToStr(i + 1), ftInteger, 0, 'Производственный маршрут|' + RouteFields[i], 30, True);
      S.ConcatStP(CheckBoxFields, 'r' + IntToStr(i + 1), ';');
    end;
    Mth.AddTableColumn(DBGridEh1, 'wo_estimate', ftInteger, 0, 'Без'#13#10'сметы', 30, True);
    Mth.AddTableColumn(DBGridEh1, 'resale', ftInteger, 0, 'Доп.'#13#10'компл.', 30, False);
    Mth.AddTableColumn(DBGridEh1, 'kns', ftString, 400, 'Конструктор', 100, True, True, False);
    Mth.AddTableColumn(DBGridEh1, 'thn', ftString, 400, 'Технолог', 100, True, True, False);
    Mth.AddTableColumn(DBGridEh1, 'comm', ftString, 400, 'Дополнение', 200, True, True, True);
    //Mth.AddTableColumn(DBGridEh1, 'discount', ftFloat, 0, 'Скидка', 50, True);
    Mth.AddTableColumn(DBGridEh1, 'sum', ftFloat, 0, 'Сумма', 100, ShowPrices); //ftCurrency
    Mth.AddTableColumn(DBGridEh1, '_sum_resale', ftFloat, 0, 'Стоимость покупных', 50, False);
    Mth.AddTableColumn(DBGridEh1, '_sum_items_nosgp', ftFloat, 0, 'Сумма в производство', 50, False);
    Mth.AddTableColumn(DBGridEh1, 'attention', ftInteger, 0, '_^', 15, False); //ftCurrency
    MemTableEh1.CreateDataSet;

    Gh.SetGridColumnsProperty(DBGridEh1, cptReadOnly, 'chg;status;slash;sum;_sum_resale;_sum_items_nosgp;std;nstd', True);

    if NoChangeItems then
      Gh.SetGridColumnsProperty(DBGridEh1, cptReadOnly, 'name;qnt;wo_estimate', True);

    Gh.SetGridInCellCheckBoxes(DBGridEh1, CheckBoxFields, '1;', -1);

    for i := 0 to DBGridEh1.Columns.Count - 1 do
      DBGridEh1.Columns[i].OnUpdateData := DBGridEh1ColumnsUpdateData;

    Gh.GetGridColumn(DBGridEh1, 'name').AlwaysShowEditButton := True;
    Gh.GetGridColumn(DBGridEh1, 'kns').AlwaysShowEditButton := True;
    Gh.GetGridColumn(DBGridEh1, 'thn').AlwaysShowEditButton := True;

    Gh.GetGridColumn(DBGridEh1, 'price').DisplayFormat := '#,##0.00';
    Gh.GetGridColumn(DBGridEh1, 'price_pp').DisplayFormat := '#,##0.00';
    Gh.GetGridColumn(DBGridEh1, 'sum').DisplayFormat := '#,##0.00';

    Gh.GetGridColumn(DBGridEh1, 'name').OnGetCellParams := DBGridEh1Columns0GetCellParams;

    Gh.SetGridInCellImages(DBGridEh1, 'status', Self.Il_Item_Status, 'E;C;0', -1);

    Gh.SetGridColumnsProperty(DBGridEh1, cptSumFooter, 'sum;_sum_resale;_sum_items_nosgp', '0.00'); //'###,###,###.##'

DBGridEh1.FindFieldColumn('resale').ReadOnly:=True;
  end;
  //реадктрование в гриде кроме режима просмотра и удаления
  DBGridEh1.ReadOnly := Mode in [fView, fDelete];
  //в режиме просмотра меню грида не нужно
  if Mode = fView then
    DBGridEh1.PopupMenu := nil;
  MemTableEh1.ReadOnly := False;
 //перемещение столбцов
//  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh-[dghColumnMove];
  //изменение ширины столбцов
  DBGridEh1.OptionsEh := DBGridEh1.OptionsEh - [dghColumnResize, dghColumnMove] + [dghEnterAsTab] + [dghAutoFitRowHeight];
  //автоподгонка ширины столбцов чтобы они занимали всю ширину видимой области грида, а не выходили за пределы видимой области
  DBGridEh1.AutoFitColWidths := True;
  //автоподгонка ширины столбцовюю
  for i := 0 to DBGridEh1.Columns.Count - 1 do begin
    DBGridEh1.Columns[i].AutoFitColWidth := DBGridEh1.Columns[i].FieldName <> ''; //= 'NAME';     //использовать этот столбец для подгонки
  end;
  //разрешаем изменение данных в гриде
  DBGridEh1.AllowedOperations := [alopInsertEh, alopUpdateEh, alopDeleteEh, alopAppendEh];
//  DBGridEh1.OptionsEh:= DBGridEh1.OptionsEh + [dghAutoFitRowHeight];
  //Gh._SetDBGridEhSumFooter(DBGridEh1, 'qnt', '0');

  MinWidth := 1100;
  MinHeight := 500;
  Self.Resize;

  //события onCahange и  onExit для всех dbeh контролов
  Cth.SetControlsOnCheckDrawRequired(Self, ControlCheckDrawRequiredState);
  //dedt_Otgr.OnCheckDrawRequiredState:=ControlCheckDrawRequiredState;
  Cth.SetControlsOnExit(Self, ControlOnExit);
  Cth.SetControlsOnChange(Self, ControlOnChange);

  edt_TemplateName.Visible := IsTemplate;

  EnableControls;

  Cth.SetDialogForm(Self, Mode, S.IIFStr(IsTemplate, 'Шаблон паспорта заказа', 'Паспорт заказа'));
  if (Mode <> fDelete) and (not IsTemplate) then
    Bt_Ok.Caption := 'Провести';
  if (Mode = fDelete) then
    Cth.SetBtn(Bt_Ok, mybtDelete);
  Cth.SetBtn(Bt_CreateXLS, mybtExcel, True, 'В Excel');
  Bt_CreateXLS.Visible := (not IsTemplate) and (Mode in [fEdit, fAdd, fCopy]);
  if not Bt_Ok.Visible then begin
    Bt_Cancel.Left := Bt_Ok.Left;
    Bt_CreateXLS.Left := Bt_Cancel.Left + Bt_Cancel.Width + 5;
  end;

  Verify(nil);
  //2025-02-07 - запретил в шаблоне менять форматт сметы, иначе если была забита таблица, заказы по шаблону будут кривые
  if (Mode <> fAdd){ and (not IsTemplate) } then
    LockStdFormat;

  if Mode <> fAdd then
    LoadStdItems;
  LoadKnsThn;
  LoadTable;

  GetAddFiles;

  //контролы в подвале формы
  chb_ViewEmptyItems.Checked := not (Mode = fView) or (IsTemplate);
  chb_ViewEmptyItems.Visible := (Mode = fView) and (not IsTemplate);
  lbl_OrderSaveStatus.Visible := (Mode <> fView);
  if not lbl_OrderSaveStatus.Visible then
    chb_ViewEmptyItems.Left := lbl_OrderSaveStatus.Left;

  inLoadData := False;

  LoadCustomer(0);
  ControlOnChange(nedt_Attention);

  SetSumInHeader;
  SetAddTasksMenu;
  if Mode = fView then
    HighlightDifferences;
  SetOrderSaveStatusText('');
  pnl_Bottom.Visible := True;

  pnl_Header_5.Visible := ShowPrices;

  EnableDeleteItemInEdit := False;
  Pmi1_ShowColumns.Visible := User.IsDeveloper;
  SetStatusBar('', '', False);

  //скроем пустые позиции
  HideEmptyItems;

  if NoChangeItems then
    DBGridEh1.AllowedOperations:=[alopUpdateEh];


  Result := True;

  BitBtn1.Visible := User.IsDeveloper;

end;

procedure TDlg_Order.pnl_HeaderClick(Sender: TObject);
begin
  inherited;

end;

(*
procedure TDlg_Order.BitBtn2Click(Sender: TObject);
var
v: tvardynarray;
begin

  myinfomessage(vartostr(QSelectOneRow('select f_order_getnewnum(:dt$d, :id_org$i) from dual', VarArrayOf([Date, Cth.GetControlValue(cmb_Organization)]))[0]));
exit;
  inherited;
v:=QCallStoredProc('p_add_customer', '1;2;3;4;5;id1$io', VarArrayOf(['test2','','','','',-1]));
MyInfoMessage(vartostr(v[5]));
exit;


{  customername varchar2,
  contactname varchar2,
  contact varchar2,
  legalname varchar2,
  inn varchar2,
  id_customer out number}
ADOStoredProc1.ProcedureName := 'pnl_add_customer';
ADOStoredProc1.Parameters.Clear;
ADOStoredProc1.Parameters.CreateParameter('p1',ftString,pdInput,20,null);
ADOStoredProc1.Parameters.CreateParameter('p2',ftString,pdInput,20,null);
ADOStoredProc1.Parameters.CreateParameter('p1',ftString,pdInput,20,null);
ADOStoredProc1.Parameters.CreateParameter('p2',ftString,pdInput,20,null);
ADOStoredProc1.Parameters.CreateParameter('p1',ftString,pdInput,20,null);
ADOStoredProc1.Parameters.CreateParameter('o1',ftString,pdOutput,20,null);
ADOStoredProc1.Parameters[0].Value := 'test1';
ADOStoredProc1.Parameters[1].Value := '';
ADOStoredProc1.Parameters[2].Value := '';
ADOStoredProc1.Parameters[3].Value := '';
ADOStoredProc1.Parameters[4].Value := '';
ADOStoredProc1.ExecProc;
myinfomessage(vartostr(ADOStoredProc1.Parameters[5].Value));
end;

*)
procedure TDlg_Order.Bt_CancelClick(Sender: TObject);
begin
  inherited;
  Close;
end;

procedure TDlg_Order.Bt_CreateXLSClick(Sender: TObject);
begin
  inherited;
  ExportPassportToXLSX(True, True);
end;

procedure TDlg_Order.Bt_OkClick(Sender: TObject);
//по клику на кнопку Провести
var
  i, j: Integer;
  v: Variant;
  st: string;
  res: Integer;
  b, os: Boolean;
  Lock: TVarDynArray;
begin
  inherited;
  //проверка корректности заполнения
  Verify(nil);
  //получим есть ли изменения в паспорте
  GetDifferences;
  //получим текстовое описание изменений в заказе
  GetChangesText;
  //подготовим (удалим пустые с концы) и проверим таблицу, если VerifyTable не вернет ошибку, то проверим на Пусто/не изменено
  res := S.IIf(VerifyTable, IsTableChanged, -1);
  if (Mode = fEdit) and (HeadDiff = False) and (res = 0) then begin
    //для редактирования, если не было изменений, не будем сохранять, вернемся в окно
    MyInfoMessage('Данные не были изменены!');
    Exit;
  end;
  if (Mode <> fDelete) and ((ok = False) or (res = -1)) then begin
    MyWarningMessage('Данные не корректны!');
    Exit;
  end;
  if (Mode <> fDelete) and (res = -2) and (not IsTemplate) then begin
    MyInfoMessage('Вы должны заполнить в табличную часть паспорта!');
    Exit;
  end;
  if (not IsTemplate) and (Mode = fDelete) and (MyQuestionMessage('Удалить заказ?') <> mrYes) then
    Exit;
  if (IsTemplate) and (Mode = fDelete) and (MyQuestionMessage('Удалить шаблон заказа?') <> mrYes) then
    Exit;
  //для шаблона проверим уникальность наименования (но может быть не изменен в случае редактирования)
  if (IsTemplate) and (Mode <> fDelete) then begin
    if Q.QSelectOneRow('select count(*) from orders where id < 0 and id <> nvl(:id$i, 0) and lower(templatename) = lower(:n$s)', [S.IIf(Mode = fEdit, ID, 0), Trim(edt_TemplateName.Text)])[0] > 0 then begin
      MyWarningMessage('Шаблон с таким наименованием уже есть!');
      Exit;
    end;
  end;

  //попытаемся сохранить заказ
  Lock := Q.DBLock(True,'ordercreate', Cth.GetControlValue(cmb_Organization),'');
  if Lock[0] = False then begin
    MyWarningMessage('Сейчас проводится заказ пользователем ' + Lock[1] + #13#10'Попробуйте чуть позже!');
    Exit;
  end;
  Self.Enabled := False;
  Q.QBeginTrans;
  OrderSaved := False;
  try
    os := False;
    os := Save;                                                  //заголовок
    if os then
      os := SaveTable;                          //таблица
    if os then
      os := SaveOrderStages;                    //итоговые даты поэтапам заказа
    if Q.TestDB
      //для тестовой базы данных - спросим, надо ли менять/создавать данные на диске (может понадобиться для отладки)
      then b:= (not IsTemplate) and (MyQuestionMessage('Выгрузить данные на диск?') = mrYes)
      else b:= True;
    if os and b then
      os := ExportPassportToXLSX(False, True);  //создадим файл паспорта
    if os and b then
      os := SetTask;                            //задачу серверному процессу, если это не шаблон
    OrderSaved := os;
    Q.QCommitOrRollback(OrderSaved);  //фиксируем транзакцию
    Q.DBLock(False, 'ordercreate', Cth.GetControlValue(cmb_Organization),'');
  except on E: Exception do
    begin
      Q.QRollbackTrans;  //фиксируем транзакцию
      Q.DBLock(False, 'ordercreate', Cth.GetControlValue(cmb_Organization),'');
      Application.ShowException(E);
    end;
  end;
  if OrderSaved then begin        //если удачно
    //если нам нельзя менять состав заказа, то сброси массив, содержащий слеши для обновления смет,
    //и никакие сметы по заказу обновлены не будут ни в учете, ни в итм!
    //в ItemsToEstimateChange попадают слеши, по которым были любые изменения!
    if NoChangeItems then ItemsToEstimateChange:= [];
    if (not IsTemplate) then begin
      if (Mode <> fDelete) then begin
//          Q.QBeginTrans(True);
        SetOrderSaveStatusText('Обновление смет для изделий');
        Orders.RefreshEstimatesToOrder(ID, ItemsToEstimateChange, False);
//         Q.QCommitOrRollback;
      end;
      Q.QBeginTrans(True);
      SetOrderSaveStatusText('Отправка заказа в ИТМ');
      Orders.SyncOrderWithITM(ID, ItemsToEstimateChange, False);
      Q.QCommitOrRollback;
      if not Q.CommitSuccess
        then MyWarningMessage(
          'Произошла ошибка при отправке заказа в ИТМ!'#13#10'Попробуйте выполнить "Загрузить смету" в журнале заказов.'
        )
        else begin
          if Q.QSelectOneRow('select F_TestOrderEstimatesInItm(:id$i) from dual', [ID])[0] > 0 then begin
            MyWarningMessage('Внимание! Не все сметы были синхронизированы с ИТМ!');
          end;
        end;
    end;
  //оюновим журнадл заказов/шаблонов и закроем окно
//QRollbackTrans;
    SetOrderSaveStatusText('Обновление журнала заказов');
    RefreshParentForm;
    SetOrderSaveStatusText('Закрываем документ');
    Self.Enabled := True;
    Close;
  end
  else begin
  //не удалось выполнить сохранение - выдадим окно
  //это окно будет выдано раньше, чем сообщение об ошибке, если оно было, так как секция finally обрабатыывается перед передачей управлени обработчику ошибки!!!
    SetOrderSaveStatusText('');
    Self.Enabled := True;
    MyWarningMessage('Не удалось сохранить заказ!');
  end;
end;

procedure TDlg_Order.HighlightDifferences;
var
  i, j: Integer;
  st: string;
  va: TVarDynArray;
begin
  //!!!HeadDiff:=False;
  va := A.ExplodeV(Differences, ',');
  for i := 0 to High(FieldsArr) do
    if FieldsArr[i][cControl] <> '' then
      if A.InArray(FieldsArr[i][cControl], va) then begin
        TDBEditEh(Self.FindComponent(FieldsArr[i][cControl])).Color := GetDiffColor;  //RGB(255,150,150);
      end;
  if A.InArray('addfiles', va) then
    lbl_Files.Font.Color := GetDiffColor;
end;

function TDlg_Order.GetDifferences: string;
var
  i, j: Integer;
  st: string;
begin
  HeadDiff := False;
  Differences := '';
  FOrderChanges := [];
  st := '';
  if (Mode = fEdit) then begin
  //and(not IsTemplate) then begin
    for i := 0 to High(FieldsArr) do
      if FieldsArr[i][cControl] <> '' then begin
        if FieldsArr[i][cControl] = 'dedt_Change' then
          Continue;
        if VarToStr(S.NullIfEmpty(Cth.GetControlValue(TControl(Self.FindComponent(FieldsArr[i][cControl]))))) = VarToStr(S.NullIfEmpty(FieldsArr[i][cBegValue])) then begin
          TCustomDBEditEh(Self.FindComponent(FieldsArr[i][cControl])).ControlLabel.Font.Color := RGB(0, 0, 0);
        end
        else begin
          TCustomDBEditEh(Self.FindComponent(FieldsArr[i][cControl])).ControlLabel.Font.Color := RGB(0, 0, 255);
          S.ConcatStP(st, FieldsArr[i][cControl], ',');
        end;
        FOrderChanges := FOrderChanges + [[FieldsArr[i][cControl], TCustomDBEditEh(Self.FindComponent(FieldsArr[i][cControl])).ControlLabel.Caption, 0]];
      end;
  end;
  if IsAddFilesChanged then
    S.ConcatStP(st, 'addfiles', ',');  //изменен состав внешних документов
  Differences := st;
  HeadDiff := Differences <> '';
  SetFieldsArrValue(cFieldName, 'ch', Differences);
end;

procedure TDlg_Order.LoadCustomer(DataType: Integer);
var
  id_customer, i, j: Integer;
begin
  id_customer := -1;
  for i := 0 to High(Customers) do
    if cmb_CustomerName.Text = Customers[i][0] then begin
      id_customer := Customers[i][1];
      Break;
    end;
  cmb_CustomerMan.Items.Clear;
  cmb_CustomerMan.DynProps.Clear;
  cmb_CustomerLegalName.Items.Clear;
  cmb_CustomerLegalName.DynProps.Clear;
  if DataType <> 0 then begin
    cmb_CustomerMan.Text := '';
    edt_CustomerContacts.Text := '';
    cmb_CustomerLegalName.Text := '';
    edt_CustomerInn.Text := '';
  end;
  if id_customer = -1 then
    Exit;
  j := -1;
  //добавим в динпропс значения контактных данных, соответствующие данному человеку
  for i := 0 to High(CustomerContacts) do begin
    if CustomerContacts[i][2] = id_customer then begin
      cmb_CustomerMan.Items.Add(CustomerContacts[i][0]);
      cmb_CustomerMan.DynProps[IntToStr(cmb_CustomerMan.Items.Count - 1)].Value := S.NSt(CustomerContacts[i][1]);
      j := i
    end;
  end;
  if DataType <> 0 then begin
    if (cmb_CustomerMan.Items.Count = 1) then
      cmb_CustomerMan.ItemIndex := 0;
    ControlOnChange(cmb_CustomerMan);
  end;

  j := -1;
  for i := 0 to High(CustomerLegal) do begin
    if CustomerLegal[i][2] = id_customer then begin
      cmb_CustomerLegalName.Items.Add(CustomerLegal[i][0]);
      cmb_CustomerLegalName.DynProps[IntToStr(cmb_CustomerLegalName.Items.Count - 1)].Value := S.NSt(CustomerLegal[i][1]);
      j := i
    end;
  end;
  if DataType <> 0 then begin
    if (cmb_CustomerLegalName.Items.Count = 1) then
      cmb_CustomerLegalName.ItemIndex := 0;
    ControlOnChange(cmb_CustomerLegalName);
  end;
end;

function TDlg_Order.Save_ItmFinish: Boolean;
//вызов финальнов процедуры синхронизации заказа в ИТМ
//удалит все сметы по изменным изделиям, если они не были подгружены
//и вызовет процедуру формирования заявок поставщикам
var
  va: TVarDynArray;
begin
  Result := True;
  if IsTemplate then
    Exit;
{  if ID_Itm <> null then begin
    Result:= True;
    Exit;
  end;}
  Result := False;
  //передается айди в схеме учет
{  va:= QCallStoredProc(
    'dv.p_SyncOrder_Finish',
    'id_dv$i',
    VarArrayOf([ID])
  );}
  if Length(va) = 0 then
    Exit;
  Result := True;
end;

function TDlg_Order.Save: Boolean;
var
  i, j: Integer;
  v: Variant;
  st: string;
  Fields: string;
  Values: TVarDynArray; //array of Variant;
  res: Integer;
  id_customer, id_customer_contact, id_customer_org: Variant;
  Customer, ItmA: TVarDynArray;
  FieldsArrCopy: TVarDynArray2;
  SqlMode: char;
  IsCustomerWholesale: Boolean;
begin
  Result := False;
  SetOrderSaveStatusText('Сохранение заголовка заказа');
  FieldsArrCopy := Copy(FieldsArr);
  repeat
    Fields := 'id$i';
    Values := [ID];
  //пройдем по массиву
    for i := 0 to High(FieldsArr) do begin
//if i = 24 then break;
    //запишем в массив значение контрола, если он для данной позиции задан
      if FieldsArr[i][cControl] <> '' then
        FieldsArr[i][cNewValue] := S.NullIfEmpty(Cth.GetControlValue(TControl(Self.FindComponent(FieldsArr[i][cControl]))));
    //для формы оплаты поправим, для безнал ьез счета ставим просто безнл, тк в бд они не различаются (диффернетовка по значению Счет)
      if (FieldsArr[i][cControl] = 'cmb_CashType') and (FieldsArr[i][cNewValue] <> null) then
        FieldsArr[i][cNewValue] := S.IIf(FieldsArr[i][cNewValue] = 0, 1, FieldsArr[i][cNewValue]);
      if (FieldsArr[i][cFieldName] = 'id_manager') then
        FieldsArr[i][cNewValue] := FieldsArr[i][cBegValue];
      if (FieldsArr[i][cFieldName] = 'ornum') then
        OrNum := S.NSt(FieldsArr[i][cBegValue]);
      if (FieldsArr[i][cFieldName] = 'id_itm') then
        Id_ITM := FieldsArr[i][cBegValue];
      if (FieldsArr[i][cFieldName] = 'ndsd') then begin
        FieldsArr[i][cNewValue] := 1;
        if cmb_Organization.ItemIndex > 0 then
          FieldsArr[i][cNewValue] := S.IIfV(S.NSt(Organizations[cmb_Organization.ItemIndex - 1][3]) <> '', 1.20, 1);
      end;
    end;
    for i := 0 to High(FieldsArr) do
      if FieldsArr[i][cFieldNameId] <> '' then begin
        S.ConcatStP(Fields, FieldsArr[i][cFieldNameId], ';');
        Values := Values + [FieldsArr[i][cNewValue]];
      end;
    if Mode in [fAdd, fCopy] then begin
    end;
  //обновим/добавим покупателя в справочнике (хранимая процедура), и запишем в данных заказа что она вернула
    IsCustomerWholesale := False;
    if Mode <> fDelete then
      if Trim(cmb_CustomerName.Text) = '' then begin
        Customer := [null, null, null, null, null, null, null, null];
      end
      else begin
        Customer := Q.QCallStoredProc('p_add_customer', '1;2;3;4;5;id1$io;id2$io;id3$io', [cmb_CustomerName.Text, cmb_CustomerMan.Text, edt_CustomerContacts.Text, cmb_CustomerLegalName.Text, edt_CustomerINN.Text, -1, -1, -1]);
        if Length(Customer) = 0 then
          Break;
        Fields := Fields + ';id_customer$i;id_customer_contact$i;id_customer_org$i';
        Values := Values + [Customer[5], Customer[6], Customer[7]];
      //получим признак Оптовый покупатель
        IsCustomerWholesale := Q.QSelectOneRow('select wholesale from ref_customers where id = :id$i', [Customer[5]])[0] = 1;
      end;
  //если не шаблон и заказа создается, либо при редактировании была изменена орган6изация, то получим номер заказа
    OrNum := Cth.GetControlValue(edt_OrderNum);
    if (not IsTemplate) and (Mode <> fDelete) and ((Mode in [fAdd, fCopy]) or (Id_Org_Old <> Cth.GetControlValue(cmb_Organization))) then begin
      v := Q.QSelectOneRow('select f_order_getnewnum(:dt$d, :id_org$i) from dual', [Date, Cth.GetControlValue(cmb_Organization)]);
    //значения полей
      Fields := Fields + ';ornum$s;year$i;prefix$s;num$i';
      Values := Values + [v[0], YearOf(Date), Copy(v[0], 1, Length(v[0]) - 6), Copy(v[0], Length(v[0]) - 3, 4)];
    //итоговый номер в переменой, и в контроле, используется в дальнейшем напр при сохранении шаблона паспорта
      OrNum := v[0];
      edt_OrderNum.Text := OrNum;
    end;
    //получим наименование каталога заказа
    OrderPath :=
      S.NSt(Q.QSelectOneRow('select order_prefix from ref_production_areas where id = :id$i', [FieldsArr[GetFieldsArrPos('area'), cNewValue]])[0]) +
      OrNum + ' ' +
      S.CorrectFileName(Trim(S.IIfV(cmb_CustomerName.Text = '', 'Производство', cmb_CustomerName.Text)) + ' ' + Trim(cmb_Project.Text))
    ;
//    S.IIf(cmb_Area.Value = '0', '', cmb_Area.Text) + OrNum + ' ' + S.CorrectFileName(Trim(S.IIfV(cmb_CustomerName.Text = '', 'Производство', cmb_CustomerName.Text)) + ' ' + Trim(cmb_Project.Text));
  //запрос на вставку данных в таблицу заказов
    Fields := Fields + ';path$s';
    Values := Values + [OrderPath];
    SqlMode := Q.QFModeToIUD(Mode);
    res := Q.QIUD(SqlMode, 'orders', '', Fields, Values);
  //если вставка запрос вернул айди
    if SqlMode = 'i' then ID := res;
  //для шаблона айди будет меньше 0, но -1 это признак ошибки, т.е. меньше -1 это нормаs
    if res < -1 then res := 1;
  //проверяем именно на -1, тк у нас используются отрицательные айди для шаблонов
    if res = -1 then Break;
(*
  //синхронизация с ИТМ, при это если это не создание заказа, и создан он
  //ранее без синхронизации с ИТМ (узнаем по наличию ид_итм), то такой заказ и
  //не синхронизируем при выключенной синхронизации для данного заказа независимо от наличия id_itm
    if (not IsTemplate) and (OrSyncWithITM) and ((Mode in [fAdd, fCopy]) or (ID_Itm <> null)) then
      if Mode <> fDelete then begin
        ItmA := Q.QCallStoredProc('dv.pnl_SyncOrder', 'id_dv$i;op$i;ornum$s;dt_beg$d;dt_otgr$d;customer$s;org$s;id_itm$io',
          [ID, S.IIf((SqlMode = 'i') or (ID_Itm = null), 1, 2), ornum, Cth.GetControlValue(dedt_Beg), Cth.GetControlValue(dedt_Otgr), S.IIfV(IsCustomerWholesale, cmb_CustomerName.Text, 'Розница'), cmb_Organization.Text, -1]);
        if Length(ItmA) = 0 then
          Break;
        ID_Itm := ItmA[7];
        Q.QExecSql('insert into adm_db_log (itemname, comm) values (:itemname$s, :comm$s)', ['pnl_SyncOrder', 'id_zakaz ' + VarToStr(Id_ITM) + ', id_order ' + VarToStr(id)]);
        if ID_Itm < 0 then
          Break;
        res := Q.QExecSql('update orders set id_itm = :id_itm$i where id = :id$i', [ID_Itm, ID]);
        if res < 0 then
          Break;
      end
      else begin
        res := Q.QExecSql('delete from dv.zakaz where id_order_dv = :id$i', [ID]);
        if res < 0 then
          Break;
      end;
  //если изменение заказа, и он ранее был синхронизирован с ИТМ, но синхронизации
  //теперь глобально выключена - сбросим ид_итм в заказе
    if (not IsTemplate) and (not SyncWithITM) and (Mode in [fEdit]) and (ID_Itm <> null) then begin
      ID_Itm := null;
      res := Q.QExecSql('update orders set id_itm = :id_itm$i where id = :id$i', [ID_Itm, ID]);
      if res < 0 then
        Break;
    end;
*)
  //сохраним данные по причинам рекламаций
    if GetOrderTypeOldValue = '2' then begin
      for i := 0 to High(Complaints) do begin
        if (S.NNum(Complaints[i][3]) <> 0) and (S.NNum(Complaints[i][2]) = 0)        //вставим если она добавлена
          then
          res := Q.QExecSql('insert into order_complaints (id_order, id_complaint_reason) values (:id_order$i, :id_complaint_reason$i)', [ID, Complaints[i][0]])
        else if (S.NNum(Complaints[i][3]) = 0) and (S.NNum(Complaints[i][2]) <> 0)          //удалим если сняли гаку
          then
          res := Q.QExecSql('delete from order_complaints where id = :id$i', [Complaints[i][2]]);
        if res < 0 then
          Break;
      end;
      if res < 0 then
        Break;
    end
    else begin
    //для редакстирования, если не стоит признак Рекламация, удалим все с таким айди заказа
      if Mode = fEdit then
        res := Q.QExecSql('delete from order_complaints where id_order = :id_order$i', [ID]);
      if res < 0 then
        Break;
    end;
    Result := True;
  until True;
  FieldsArr := Copy(FieldsArrCopy);
end;

function TDlg_Order.SaveOrderStages: Boolean;
//поправим статусы этапов заказа (на данный момент это приемка на сгп и отгрузка с сгп)
//могут меняться при изменении в табличной части количеств, в заголовочной - организации (П или другая)
//пока для простоты запускаем в любом случае при изменении заказа
var
  res: Integer;
begin
  SetOrderSaveStatusText('Обновление статусов заказа');
  Result := True;
  if (Mode <> fEdit) or (IsTemplate) then
    Exit;
  Result := False;
  res := Length(Q.QCallStoredProc('p_OrderStage_SetMainTable', 'IdOrder$i;IdStage$i', [ID, 2]));
  if res = 0 then
    Exit;
  res := Length(Q.QCallStoredProc('p_OrderStage_SetMainTable', 'IdOrder$i;IdStage$i', [ID, 3]));
  if res = 0 then
    Exit;
  Result := True;
end;

procedure TDlg_Order.ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean);
begin
  Cth.VerifyVisualise(Self);
end;

procedure TDlg_Order.ControlOnChange(Sender: TObject);
var
  st: string;
  Canvas: TControlCanvas;
  i, j: Integer;
  b: Boolean;
begin
  if InLoadData then
    Exit;
  if Sender = cmb_CustomerName then
    LoadCustomer(1);
  if Sender = cmb_CustomerMan then begin
    edt_CustomerContacts.Text := '';
    if cmb_CustomerMan.ItemIndex >= 0 then
      edt_CustomerContacts.Text := cmb_CustomerMan.DynProps[IntToStr(cmb_CustomerMan.ItemIndex)].Value;
  end;
  if Sender = cmb_CustomerLegalName then begin
    edt_CustomerInn.Text := '';
    if cmb_CustomerLegalName.ItemIndex >= 0 then
      edt_CustomerInn.Text := cmb_CustomerLegalName.DynProps[IntToStr(cmb_CustomerLegalName.ItemIndex)].Value;
  end;
  //подсветим (подчеркнем) для клиента, если данные из списка
  if (Sender = cmb_CustomerName) or (Sender = cmb_CustomerMan) or (Sender = cmb_CustomerLegalName) and (Mode <> fView) then begin
{    if TDBComboboxEh(Sender).ItemIndex >= 0
      then TDBComboboxEh(Sender).Font.Style:= [fsUnderline]
      else TDBComboboxEh(Sender).Font.Style:= [];}
  end;
  //если это выбор организации, то у нас значения зщависят производство это либо нет
  if (Sender = cmb_Organization) then begin
    //изменим доступность контролов
    EnableControls;
    //получим номер заказа, предварительно, окончательноь будет при записи
    if (Mode = fEdit) and (Cth.GetControlValue(cmb_Organization) = Id_Org_Old) then
      edt_OrderNum.Text := S.NSt(FieldsArr[GetFieldsArrPos('ornum')][cBegValue])
    else
      edt_OrderNum.Text := Q.QSelectOneRow('select f_order_getnewnum(:dt$d, :id_org$i) from dual', [Date, Cth.GetControlValue(cmb_Organization)])[0];
    //если это производство, то очистим поля
    if Cth.GetControlValue(cmb_Organization) = -1 then
      for i := 0 to High(FieldsArr) do          //если выбрано производство, то очистим контролы с призанком 1
        if (FieldsArr[i][cControl] <> '') and (FieldsArr[i][cEditable] = 1) then begin
          EnableControls;
          Cth.SetControlValue(TControl(Self.FindComponent(FieldsArr[i][cControl])), null)
        end;
    //переименуем слеши в таблице
    RenameSlashes;
//    VerifyTable;
//    DBGridEh1.SetFocus;
//    cmb_Organization.SetFocus;
  end;
  if (Sender = dedt_MontageBeg) then begin
    if dedt_MontageBeg.Value = null then
      dedt_MontageEnd.value := null;
    Verify(dedt_MontageEnd);
//    SetControlDisabled(dedt_MontageEnd, dedt_MontageBeg.Value <> null);
  end;
  if (Sender = cmb_OrderType) then begin
    SetComplaints;
    if (GetOrderTypeOldValue= '1') or (GetOrderTypeOldValue = '3') then begin
      cmb_OrderReference.Text := '';
    end;
    if FNewOrderType = 1 then begin
      FieldsArr[GetFieldsArrPos('id_type2'), cNewValue] := GetOrderTypeOldValue;
      FieldsArr[GetFieldsArrPos('ids_order_properties'), cNewValue] := '';
      dedt_Otgr.Value := null;
      //дата отгрузки разрешена для  старого режима, а для нового - если нет регламента для данного типа заказа
      dedt_Otgr.Enabled := (not (Mode in [fView, fDelete])) and (S.NSt(cmb_OrderType.Value) <> '') and
        (FNewOrderType = 0) or User.Role(rOr_D_Order_EditDtOtgr) or (FOrderTypes[cmb_OrderType.ItemIndex][3].AsInteger = 0);
    end;
  end;
  if (Sender = cmb_Organization) or (Sender = cmb_OrderType) then
    Verify(nil)
  else
    Verify(Sender, True);
  if Sender = cmb_Format then begin
    SetEstimateList;
    SetAddTasksMenu;
  end;
  //изменим цвет комментария в зависимости от признака его важности
  if Sender = nedt_Attention then
    if nedt_Attention.Value = 0 then
      mem_Comment.Font.Color := clWindowText
    else
      mem_Comment.Font.Color := clRed;
  //при изменении любого намбередита (для простоты, не перечислать контролы для ввода), или организзации - пересчитать сумму
  if (Sender is TDBNumberEditEh) or (Sender = cmb_Organization) then
    SetSumInHeader;

  DBGridEh1.Enabled := (cmb_EstimatePath.Text <> '') and (cmb_Format.Text <> '');
end;

procedure TDlg_Order.ControlOnExit(Sender: TObject);
//потеря фокуса
var
  st: string;
  i: Integer;
begin
  //уберем пробелы в тедит
  if (Sender is TDBEditEh) then
    TDBEditEh(Sender).Text := Trim(TDBEditEh(Sender).Text);
  //уберем пробелы в комбобокс без списков
  if (Sender is TDBComboBoxEh) and (TDBComboBoxEh(Sender).KeyItems.Count = 0) then
    TDBComboBoxEh(Sender).Text := Trim(TDBComboBoxEh(Sender).Text);
  //верификация
  Verify(nil);
end;



//проверка правлильн6ости данных
//передается контрол для проверки, или нил - проверить все
//и признак что проверка при вводе данных в контроле (в событии onChange)
procedure TDlg_Order.Verify(Sender: TObject; onInput: Boolean = False);
var
  i, j, sm: Integer;
  c: TControl;
  st, n: string;
  b: Boolean;

  procedure SetInvalidIfEmpty(c: TControl; ValidAllways: Boolean = True);
  begin
    if not (c is TCustomDBEditEh) then
      Exit;
    Cth.SetErrorMarker(c, (TCustomDBEditEh(c).Text = '') and not ValidAllways);
  end;

begin
  //при удалении и просмотре всегда Ок
  if (Mode = fView) or (Mode = fDelete) then begin
    Ok := True;
    Exit;
  end;
//  Ok:=Cth.VerifyVisualise(Self);
//exit;
  //пройдем по массиву контролов
  for i := 0 to High(FieldsArr) do begin
    //проверим все если нил, иначе только переданный
    if (FieldsArr[i][cControl] = '') or (TControl(Sender) <> nil) and (TControl(Sender).Name <> FieldsArr[i][cControl]) then
      Continue;
    //получим контрол по названию
    c := TCustomDbEditEh(Self.FindComponent(FieldsArr[i][cControl]));
    //не в режиме темплейта
    if not IsTemplate then begin
      //для занчание проверки 0, валидно в любом случае
      //а также для 2 или 3, в любом случае при типе Производство
      if c = dedt_Otgr then begin  //раньше можно было без даты отгрузки если производство, теперь она нужна всегда
        Cth.SetErrorMarker(c, (not Cth.DteValueIsDate(dedt_Otgr) or (dedt_Otgr.Value < dedt_Beg.value))); //(cmb_Organization.Value <> '-1')and
        Continue;
      end;
      SetInvalidIfEmpty(c, (FieldsArr[i][cVerify] = 0) or ((S.VarToInt(FieldsArr[i][cVerify]) in [2, 3]) and (cmb_Organization.Value = '-1')));
      if c = cmb_OrderType  //тип заказа не может быть пустым, не может рекламация для производства, не может эксперимент не для производства
        then
        Cth.SetErrorMarker(c, (GetOrderTypeOldValue.AsString = '') or ((GetOrderTypeOldValue = '2') and (cmb_Organization.Value = '-1')) or ((GetOrderTypeOldValue = '3') and (cmb_Organization.Value <> '-1')));
      if c = cmb_OrderReference then
        Cth.SetErrorMarker(c, (GetOrderTypeOldValue = '1') and (cmb_OrderReference.Text <> '') or (GetOrderTypeOldValue = '2') and (cmb_OrderReference.Text = ''));
      if c = edt_Complaints then
        Cth.SetErrorMarker(c, (GetOrderTypeOldValue = '2') and (edt_Complaints.Text = ''));
      if c = edt_CustomerINN then
        SetInvalidIfEmpty(c, cmb_CustomerLegalName.Text = '');
      //для сметы - должен быть в списке
      if c = cmb_EstimatePath then
        Cth.SetErrorMarker(cmb_EstimatePath, cmb_EstimatePath.ItemIndex < 0);
      //дата начала монтажа - если разрешена, то или пустая, или больше даты отгрузки
      if c = dedt_MontageBeg then
        Cth.SetErrorMarker(c, c.Enabled and not (dedt_MontageBeg.Value = null) and (dedt_MontageBeg.Value < dedt_Otgr.value));
      //дата окончания монтажа - если разрешана, то при пустой дате начала монтажа тое должна быть пустой,
      //а при заданной дате начала должна быть больше ее
      if c = dedt_MontageEnd then
        Cth.SetErrorMarker(c, c.Enabled and ((dedt_MontageBeg.Value = null) and (dedt_MontageBeg.Value <> null) or (dedt_MontageBeg.Value <> null) and ((dedt_MontageEnd.Value = null) or (dedt_MontageEnd.Value < dedt_MontageBeg.value))));
    end;
    //для шаблона, должно быть заполнено имя шаблона
    if c = edt_TemplateName then
      SetInvalidIfEmpty(c, not IsTemplate);
    //проверим при изменении организации, оплаты, счета - правильность комбобокса оплаты и номера счета
    //только если это не шаблон, и не Производство
    if ((c = edt_Account) or (c = cmb_CashType) or (c = cmb_Organization)) and (not IsTemplate) and (cmb_Organization.ItemIndex > 0) then begin
      b := False;  //True = оплата по безналу
      if (cmb_Organization.ItemIndex > 0) and (cmb_Organization.ItemIndex <= High(Organizations) + 1) then
        b := S.NSt(Organizations[cmb_Organization.ItemIndex - 1][2]) <> '';
      //вид оплаты соотвествует признаку кешлесс в массиве организаций
      Cth.SetErrorMarker(cmb_CashType, (b and (cmb_CashType.Value = '2')) or (not b and (cmb_CashType.Value <> '2')) or (cmb_CashType.ItemIndex = -1));
      //счет только для вырианта Безнал (не б/н без счета!!)
      Cth.SetErrorMarker(edt_Account, (edt_Account.Text = '') and (cmb_CashType.Value = '1') or (edt_Account.Text <> '') and (cmb_CashType.Value <> '1'))
    end;
  end;
//      SetInvalidIfEmpty(dedt_Otgr, False);//(FieldsArr[i][cVerify] = 0) or ((S.VarToInt(FieldsArr[i][cVerify]) in [2, 3]) and (cmb_Organization.Value = '-1')));
//      b:= TDBDateTimeEditEh(dedt_Otgr).DynProps.VarExists('error');
//      Cth.DotRedLine(dedt_Otgr);
//      Cth.DotRedLine(nedt_Trans_0);
//      if b then dedt_Otgr.Color:=RGB(255,0,0) else dedt_Otgr.Color:=RGB(255,255,255);
  Ok := Cth.VerifyVisualise(Self);
  //проверим выбран ли регламент
  //если это не шаблон и не тип заказа Отгрузочный с СГП
  if (not IsTemplate) and Ok and (cmb_OrderType.Value <> '111') and (Cth.GetControlValue(dedt_beg) >= EncodeDate(2025,12,22))) then
    Ok := FieldsArr[GetFieldsArrPos('id_reglament'), cNewValue] <> null;
end;

procedure TDlg_Order.SetComplaints;
//вызывается при изменении типа заказа (навый/рекламация)
var
  i: Integer;
begin
  if S.NSt(GetOrderTypeOldValue) = '2' then begin
  //это рекламация
    //покажем строку причин рекламации
    edt_Complaints.Visible := True;
    //подправим расположение комментария
    mem_Comment.Top := edt_Complaints.Top + edt_Complaints.Height + 4;
    if cmb_OrderReference.Items.Count = 0 then
      Q.QLoadToDBComboBoxEh('select ornum from v_orders where id >= 0 order by ornum', [], cmb_OrderReference, cntComboE, 0);
  end
  else begin
  //это новый заказ
    edt_Complaints.Text := '';
    edt_Complaints.Visible := False;
    mem_Comment.Top := edt_Complaints.Top;
  end;
  mem_Comment.Height := mem_Comment.Parent.Height - mem_Comment.Top - 4;
end;

procedure TDlg_Order.LoadComplaints;
//загрузим в массив справочник причин рекламации, и данные по статьям рекламациии по заказу
var
  i, j: Integer;
  va2: TVarDynArray2;
  st: string;
begin
  //причины рекламаций  по данному заказу
  va2 := Q.QLoadToVarDynArray2('select id, id_complaint_reason from order_complaints where id_order = :id$i', [ID]);
  st := '';
  //строка айди комплайнтов, которые есть по заказу, чтобы загрузить их в случае, если они уже не активны в справочнике
  for i := 0 to High(va2) do
    S.ConcatStP(st, S.NSt(va2[i][1]), ',');
  if st <> '' then
    st := ' or id in (' + st + ')';
  //справочник причин рекламаций
  Complaints := Q.QLoadToVarDynArray2('select id, name, null, null from ref_complaint_reasons ' + 'where active = 1' + st + 'order by name', []                          //:ids$s = "102,102" - нельзя пертедать в виде параметра, происходит ошибка
  );
  for i := 0 to High(Complaints) do begin
    j := A.PosInArray(Complaints[i][0], va2, 1);
    if j > -1 then begin
      //если есть в таблице рекламаций по данному заказу, то проставим начальные айди (№3 - на момент начала заказа)
      Complaints[i][2] := va2[j][0];
      //и на момент сохранения, он пока такой же
      Complaints[i][3] := va2[j][0];
    end;
  end;
  GetComplaintsString;
end;

procedure TDlg_Order.GetComplaintsString;
//строковое представление причин рекламаций по заказу
var
  i: Integer;
  Result, st: string;
begin
  Result := '';
  for i := 0 to High(Complaints) do
    if S.NNum(Complaints[i][3]) <> 0 then
      S.ConcatStP(Result, Complaints[i][1], '; ');
  edt_Complaints.Text := Result;
  edt_Complaints.ReadOnly := True;
  edt_Complaints.Hint := edt_Complaints.Text;
  edt_Complaints.ShowHint := True;
  edt_Complaints.EditButtons[0].DropDownFormParams.DropDownForm := Dlg_Order_Complaints;
//  edt_Complaints.EditButtons[0].DropDownFormParams.Align:=daRight;
end;

procedure TDlg_Order.GetEstimateList;
//получаем список стандартных смет для всех форматов паспортов
//в массиве поучаются в виде "формат паспорта\формат сметы"
var
  i, j, k, l: Integer;
  sa, sa1: TStringDynArray;
  va2: TVarDynArray2;
begin
{  EstimateDirs:=[];
//получаем список каталогов для стандартных смет, сразу список всех возможных,
//уровень вложенности 2 (сметы/формат_паспорта/вариант_смет)
 //это получение из списка существующих каталогов
   sa:=[];
  if not DirectoryExists(Module.OrderEstimateFilePath) then Exit;
  l:=Length(Module.OrderEstimateFilePath);
  sa:=TDirectory.GetDirectories(Module.OrderEstimateFilePath, '*.*', TSearchOption.soTopDirectoryOnly);
  for i:=0 to High(sa) do begin
    sa1:=TDirectory.GetDirectories(sa[i], '*.*', TSearchOption.soTopDirectoryOnly);
    for j:=0 to High(sa1) do begin
      EstimateDirs:=EstimateDirs + [copy(sa1[j], l+2)];
    end;
  end;}
  //загрузим весь массив стандртных смет
  //если новый заказ то только активные (это кривовато но пока так!!!)
  EstimateDirs := Q.QLoadToVarDynArray2('select f.name || ''\'' || e.name || '''' as estimate, e.id as id, e.prefix ' + 'from or_formats f, or_format_estimates e ' + 'where e.id_format = f.id and e.id > 1 ' + S.IIFStr(Mode = fAdd, 'and e.active = 1 and f.active = 1', '') + 'order by 1 asc', []);
end;

procedure TDlg_Order.SetEstimateList(PreserveValue: Boolean = False);
//загружаем в комбобокс список выриантов смет, соотвествующих формату паспорта
//(начинаются напр с ТШ/
var
  i, j, k, l: Integer;
  st: string;
begin
  st := cmb_EstimatePath.Text;
  cmb_EstimatePath.Items.Clear;
  cmb_EstimatePath.KeyItems.Clear;
  if (cmb_Format.Value = '-1') or (cmb_Format.Text = '') then
    Exit;
  cmb_EstimatePath.Items.Add('[нет стандартных смет]');
  cmb_EstimatePath.KeyItems.Add('0');
  for i := 0 to High(EstimateDirs) do
    if Pos(UpperCase(cmb_Format.Text) + '\', UpperCase(EstimateDirs[i][0])) = 1 then begin
      cmb_EstimatePath.Items.Add(EstimateDirs[i][0]);
      cmb_EstimatePath.KeyItems.Add(EstimateDirs[i][1]);
    end;
  if not PreserveValue then
    cmb_EstimatePath.Text := '';
end;



























////////////////////////////////////////////////////////////////////////////////

procedure TDlg_Order.LoadStdItems;
//загрузим стандартнуую номенклатуру
//проба из ИТМ:
//groups id_group=2996
//nomenclatua, id_group, name, id_nomencl
//---
//из своего стправочника, по айди формата сметы, а также всегда с форматом = 1, это доп. комплектация
//вызывается при открытии паспотра, если не новый  паспорт, и при переходе в грид при режиме добавления
var
  i, j: Integer;
  v: Variant;
  bmp: TBitmap;
begin
{  StdItems:=[
  ['name0001', 0,  1,1,1,0,0,0,0,0,0,  0,   null],
  ['name0002sgp', 1,  0,0,0,0,0,0,0,0,0,  0,   1000]
  ];}
{  StdItems:=QLoadToVarDynArray2(
    'select name, id_nomencl from dv.nomenclatura where id_group = 2996 order by name asc',
    null
  );  }
//i:=Cth.GetControlValue(cmb_EstimatePath);
  //адйи, имя, null, 9 участков производства, доп.компл, цена
  StdItems := [];
  v := Cth.GetControlValue(cmb_EstimatePath);
  if S.NSt(v) = '' then Exit;
//  StdItems := Q.QLoadToVarDynArray2('select id, name, null, r1, r2, r3, r4, r5, r6, r7, r8, r9, null, /*resale,*/ price, price_pp ' + 'from or_std_items where ' + '(id_or_format_estimates = :id$i or id_or_format_estimates = 1) and (id_or_format_estimates <> 0) ' + 'order by name asc', [Cth.GetControlValue(cmb_EstimatePath)]);
  StdItems := Q.QLoadToVarDynArray2(
    'select id, name, null, r1, r2, r3, r4, r5, r6, r7, r8, r9, null, /*resale,*/ price, price_pp, wo_estimate ' +
    'from or_std_items '+
    'where ' + '(id_or_format_estimates = :id$i or id_or_format_estimates = 1) and (id_or_format_estimates <> 0) ' +
    'order by name asc',
    [Cth.GetControlValue(cmb_EstimatePath)]
  );
  Gh.GetGridColumn(DBGridEh1, 'name').PickList.Clear;
//  Gh.GetGridColumn(DBGridEh1, 'name').KeyList.Clear;
  Gh.GetGridColumn(DBGridEh1, 'name').ImageList := Il_ItemsTypes;
  Gh.GetGridColumn(DBGridEh1, 'name').ShowImageAndText := True;
  bmp := TBitmap.Create;
  for i := 0 to High(StdItems) do begin
    Gh.GetGridColumn(DBGridEh1, 'name').PickList.Add(S.NSt(StdItems[i][1]));
    if StdItems[i][12] = 1 then begin
      Il_Columns.GetBitmap(1, bmp);
      Il_ItemsTypes.Add(bmp, nil);
//      Gh.GetGridColumn(DBGridEh1, 'name').KeyList.Add(S.NSt(StdItems[i][1]));
    end
    else begin
      Il_Columns.GetBitmap(0, bmp);
//      bmp.Width:=3;
      Il_ItemsTypes.Add(bmp, nil);
  //    Gh.GetGridColumn(DBGridEh1, 'name').KeyList.Add(S.NSt(StdItems[i][1]));
    end;
  end;
//  MyData.IL_Galka_RGB_123.GetBitmap(0,bmp);
//  ImageList1.Add(bmp, nil);
  Gh.GetGridColumn(DBGridEh1, 'name').NotInKeyListIndex := Il_ItemsTypes.Count; // - 1;
  bmp.Free;
end;

procedure TDlg_Order.LoadKnsThn;
//загрузим и создадиим в таблице списки конструкторов и технологов
//добавим в список кроме действующих еще тех, кто есть в данном заказе (или шаблоне идли заказе, который копируется)
//если этих пользователей не добалять, то поле в мемтейбл все равно установится в айди, но в списке такого айди нет и оно будет с виду пустое
var
  i, j: Integer;
  va, va2: TVarDynArray2;
  st: string;
begin
  if Mode <> fAdd then
    va2 := Q.QLoadToVarDynArray2('select distinct id_kns from order_items where id_kns is not null and id_kns >= 0 and id_order = :ID$i', [FieldsArr[0][cBegValue]]);
  st := '';
  for i := 0 to High(va2) do
    S.ConcatStP(st, VarToStr(va2[i][0]), ',');
  if st <> '' then
    st := ' or (id in (' + st + ')) ';
  va := Q.QLoadToVarDynArray2('select name, id from adm_users where (job = :id_job$i and active = 1)' + st + 'order by name asc', [myjobKNS]);
  Gh.GetGridColumn(DBGridEh1, 'kns').PickList.Add('[нет]');
  Gh.GetGridColumn(DBGridEh1, 'kns').KeyList.Add('-100');
  Gh.GetGridColumn(DBGridEh1, 'kns').PickList.Add('[конструктор]');
  Gh.GetGridColumn(DBGridEh1, 'kns').KeyList.Add('-101');
  for i := 0 to High(va) do begin
    Gh.GetGridColumn(DBGridEh1, 'kns').PickList.Add(S.NSt(va[i][0]));
    Gh.GetGridColumn(DBGridEh1, 'kns').KeyList.Add(S.NSt(va[i][1]));
  end;
  if Mode <> fAdd then
    va2 := Q.QLoadToVarDynArray2('select distinct id_thn from order_items where id_thn is not null and id_thn >= 0 and id_order = :ID$i', [FieldsArr[0][cBegValue]]);
  st := '';
  for i := 0 to High(va2) do
    S.ConcatStP(st, VarToStr(va2[i][0]), ',');
  if st <> '' then
    st := ' or (id in (' + st + ')) ';
  va := Q.QLoadToVarDynArray2('select name, id from adm_users where (job = :id_job$i and active = 1)' + st + 'order by name asc', [myjobTHN]);
  Gh.GetGridColumn(DBGridEh1, 'thn').PickList.Add('[нет]');
  Gh.GetGridColumn(DBGridEh1, 'thn').KeyList.Add('-100');
  Gh.GetGridColumn(DBGridEh1, 'thn').PickList.Add('[технолог]');
  Gh.GetGridColumn(DBGridEh1, 'thn').KeyList.Add('-102');
  for i := 0 to High(va) do begin
    Gh.GetGridColumn(DBGridEh1, 'thn').PickList.Add(S.NSt(va[i][0]));
    Gh.GetGridColumn(DBGridEh1, 'thn').KeyList.Add(S.NSt(va[i][1]));
  end;
end;

function TDlg_Order.GetItemNum(r: Integer): string;
begin
  Result := edt_OrderNum.Text + '_' + AnsiRightStr('000' + IntToStr(r), 3);
end;

function TDlg_Order.IsRowEmpty(r: Integer): Boolean;
//проверяем строку таблицы на валидность
var
  i, j: Integer;
  b: Boolean;
begin
  Result := False;
  for i := 0 to MemTableEh1.Fields.Count - 1 do begin
    //по этим полям не проверяем
    if MemTableEh1.Fields[i].FieldName = 'slash' then
      Continue;
    if MemTableEh1.Fields[i].FieldName = 'status' then
      Continue;
    if MemTableEh1.Fields[i].FieldName = 'prefix' then
      Continue;
    //числовые должны быть пустыми или 0
    if ((MemTableEh1.Fields[i].DataType = ftInteger) or (MemTableEh1.Fields[i].DataType = ftFloat)) and (MemTableEh1.Fields[i].AsFloat <> 0) then
      Exit;
    //строки должны быть пустыми
    if (MemTableEh1.Fields[i].DataType = ftString) and (MemTableEh1.Fields[i].AsString <> '') then
      Exit;
  end;
  Result := True;
end;

function TDlg_Order.IsItemValid(r: Integer): Boolean;
//проверяем строку таблицы на валидность
var
  b: Boolean;
  i, j: Integer;
begin
  //сначала статус ошибюки, и если при проверке он есть то выходим
  Result := False;
  //статус ошибки
  if IsRowEmpty(0) then begin
    MemTableEh1.FieldByName('status').Value := 'C';
    Exit;
  end;
  //не допускаются нестандартные позиции в производственно паспорте
  if (Cth.GetControlValue(cmb_Organization) = -1) and (MemTableEh1.FieldByName('nstd').AsInteger = 1) then
    Exit;
  MemTableEh1.FieldByName('status').Value := 'E';
  //нельзя, чтобы одновременно был задан маршрут и галка Перепродажа либо СГП, и нельзя когда не задано ни то ни другое
  b := False;
  for i := 0 to High(RouteFields) do begin
    if (MemTableEh1.FieldByName('r' + IntToStr(i + 1)).AsInteger = 1) then
      b := True;
  end;
  if (MemTableEh1.FieldByName('resale').AsInteger = 1) or (MemTableEh1.FieldByName('sgp').AsInteger = 1) or (MemTableEh1.FieldByName('wo_estimate').AsInteger = 1) then begin
    if b then Exit;
  end
  else begin
    if not b then Exit;
  end;
  //обязательно должна быть отмечена одна и только одна галка из Стд/Нст
  i := 0;
  if MemTableEh1.FieldByName('std').AsInteger = 1 then
    inc(i);
  if MemTableEh1.FieldByName('nstd').AsInteger = 1 then
    inc(i);
  if i <> 1 then
    Exit;
  //конструктор не должен быть пустым
  if MemTableEh1.FieldByName('kns').AsString = '' then
    Exit;
  //технолог не должен быть пустым
  if MemTableEh1.FieldByName('thn').AsString = '' then
    Exit;
  //для стандартных конструктор недопустим
  //ch 2024-08-26 - конструктор допустим и для стандартных изделий
//  if (MemTableEh1.FieldByName('std').AsInteger = 1) and (MemTableEh1.FieldByName('kns').AsInteger <> -100) then
//    Exit;
  //для доп.компл конструктор недопустим
  if (MemTableEh1.FieldByName('resale').AsInteger = 1) and (MemTableEh1.FieldByName('kns').AsInteger <> -100) then
    Exit;
  //для доп.компл технолог недопустим
  if (MemTableEh1.FieldByName('resale').AsInteger = 1) and (MemTableEh1.FieldByName('thn').AsInteger <> -100) then
    Exit;
{    (MemTableEh1.FieldByName('kns').AsInteger = -100) then
    if (MemTableEh1.FieldByName('resale').AsInteger = 1) then begin
      if ((MemTableEh1.FieldByName('thn').AsInteger = -102) or (MemTableEh1.FieldByName('thn').AsInteger > 0)) then Exit;
    end
    else ((MemTableEh1.FieldByName('thn').AsInteger = -102) or (MemTableEh1.FieldByName('thn').AsInteger > 0))) then Exit;}
  //при отгрузке сгп недопустим ни конструктор ни технолог
  if (MemTableEh1.FieldByName('sgp').AsInteger = 1) and ((MemTableEh1.FieldByName('kns').AsInteger <> -100) or (MemTableEh1.FieldByName('thn').AsInteger <> -100))
    then Exit;
  //при типе Без сметы недопустим ни конструктор ни технолог
  if (MemTableEh1.FieldByName('wo_estimate').AsInteger = 1) and ((MemTableEh1.FieldByName('kns').AsInteger <> -100) or (MemTableEh1.FieldByName('thn').AsInteger <> -100))
    then Exit;
  //для нестандартных, но не покупных, и не с сгп, и не без смет - обязателен технолог, но необязателен конструктор
  if (MemTableEh1.FieldByName('nstd').AsInteger = 1) and not (MemTableEh1.FieldByName('resale').AsInteger = 1)
     and not (MemTableEh1.FieldByName('sgp').AsInteger = 1) and not (MemTableEh1.FieldByName('wo_estimate').AsInteger = 1)
     and not (
       //     ((MemTableEh1.FieldByName('kns').AsInteger > 0)or(MemTableEh1.FieldByName('kns').AsInteger = -101)) and
      //изм 2024-01-11 - для нестандартных не обязателен конструктор
      ((MemTableEh1.FieldByName('kns').AsInteger > 0) or (MemTableEh1.FieldByName('kns').AsInteger = -100) or (MemTableEh1.FieldByName('kns').AsInteger = -101)) and
      ((MemTableEh1.FieldByName('thn').AsInteger > 0) or (MemTableEh1.FieldByName('thn').AsInteger = -102)))
    then Exit;
  //наименование не должно быть пустым
  if MemTableEh1.FieldByName('name').AsString = '' then
    Exit;
  //цена обязательна и не отрицательно
  if (MemTableEh1.FieldByName('price').AsString = '') or (MemTableEh1.FieldByName('price').AsFloat < 0) then
    Exit;
  //цена перепродажи обязательна и не больше общей цены, а для д/к обе цены равны
  if (MemTableEh1.FieldByName('price_pp').AsString = '') or (MemTableEh1.FieldByName('price_pp').AsFloat > MemTableEh1.FieldByName('price').AsFloat) or (MemTableEh1.FieldByName('resale').AsInteger = 1) and (MemTableEh1.FieldByName('price_pp').AsFloat <> MemTableEh1.FieldByName('price').AsFloat) then
    Exit;
  //количество обязательно и не отрицательно
  if (MemTableEh1.FieldByName('qnt').AsString = '') or (MemTableEh1.FieldByName('qnt').AsFloat < 0) then
    Exit;
  //СГП путой, или не больше количества
{  if (MemTableEh1.FieldByName('sgp').AsString <> '')
    then if (MemTableEh1.FieldByName('sgp').AsFloat < 0)or(MemTableEh1.FieldByName('sgp').AsFloat > MemTableEh1.FieldByName('qnt').AsFloat) then Exit;}
  //галка СГП недопустима для производственного паспотра
  if (MemTableEh1.FieldByName('sgp').AsInteger = 1) and (Cth.GetControlValue(cmb_Organization) = -1) then
    Exit;
  //не вышли раньше, статус меняем на ОК
  MemTableEh1.FieldByName('status').Value := '';
  Result := True;
  if (MemTableEh1.FieldByName('qnt').AsString = '0') then begin
    MemTableEh1.FieldByName('status').Value := '0';
    ;
    Exit;
  end;
//  Gh.GetGridColumn(DBGridEh1, 'resale').ReadOnly:= MemTableEh1.FieldByName('std').AsInteger = 1;
{  Gh.GetGridColumn(DBGridEh1, 'resale').ReadOnly:= MemTableEh1.FieldByName('std').AsInteger = 1;
  for i:=0 to High(RouteFields) do begin
    if MemTableEh1.FieldByName('resale').AsInteger = 1 then MemTableEh1.FieldByName('r' + IntToStr(i+1)).AsInteger := 0;
    Gh.GetGridColumn(DBGridEh1, 'r' + IntToStr(i+1)).ReadOnly:=MemTableEh1.FieldByName('resale').AsInteger = 1;
  end;}
{  for i:=0 to High(RouteFields) do begin
    if MemTableEh1.FieldByName('r' + IntToStr(i+1)).AsInteger = 1 then MemTableEh1.FieldByName('resale').AsInteger := 0;
  end;}
end;

procedure TDlg_Order.DBGridEh1ColEnter(Sender: TObject);
begin
  inherited;
  if InLoadData then
    Exit;
  Mth.Post(MemTableEh1);
  MemTableEh1.Edit;
end;

procedure TDlg_Order.MemTableEh1AfterEdit(DataSet: TDataSet);
var
  i, j: Integer;
begin
  inherited;
  IsItemValid(0);
  //присвоим значение колонке № заказа
  //это нужно при редактирование заказа, но портит, если при просмотре не выбрано не показывать нулевые - без проверки слеши пересчитываются по видимым строкам
  //!!! если поцию скрать пустые делать и для редактирования, то тут надо переделывать
  if not (Mode in [fView, fDelete]) then
    MemTableEh1.FieldByName('slash').Value := GetItemNum(MemTableEh1.RecNo);
  //присвоим префикс - ДК для любой (стандартной и нет, в любом формате паспорта), или же префикс формата при не Общем формате
  MemTableEh1.FieldByName('prefix').Value := S.IIfV(MemTableEh1.FieldByName('nstd').AsInteger = 1, '', S.IIfV(MemTableEh1.FieldByName('resale').AsInteger = 1, 'ДК', ItemPrefix));
{  //этого здесь делать нельзя, зависание!!!
  Mth.Post(MemTableEh1);
  MemTableEh1.Edit;}
end;

procedure TDlg_Order.EnableTablePopupMenu;
begin
  //меню удаления строки разрешено, кроме режима редактирования при строках не более начальных (которые уже были - удалять нельзя!)
  Pmi1_DeleteRow.Enabled := not ((Mode = fEdit) and (MemTableEh1.FieldByName('id').Value <> null) and not (IsTemplate or EnableDeleteItemInEdit))//  Pmi1_DeleteRow.Enabled:=(Mode <> fEdit) or IsTemplate or (MemTableEh1.RecNo > BegItemsCount);
end;

procedure TDlg_Order.MemTableEh1AfterScroll(DataSet: TDataSet);
begin
  inherited;
  //при переходе на другую сразу постим данные
  Mth.PostAndEdit(MemTableEh1);
  //дальнейшее не выполняем, если контролы заблокированы (просмотр массива записей для обсчета)
  if MemTableEh1.ControlsDisabled then
    Exit;
  //меняем только блокировку ячеек для ввода, без пересчета их значений
  CorrectRowIfNameChanged(True);
  //изменим доступность меню
  EnableTablePopupMenu;
  //ограничим количество добаляемых строк
  if MemTableEh1.RecNo = MaxTableRowCount + 1 then
    MemTableEh1.RecNo := MaxTableRowCount;
//  cmb_Format.Enabled:= MemTableEh1.RecordCount = 0;
//  cmb_EstimatePath.Enabled:=cmb_Format.Enabled;
end;

procedure TDlg_Order.mem_CommentKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
//установим признак важности комментария
begin
  inherited;
  if (Key = Ord('Q')) and (Shift = [ssCtrl]) then begin
    //предотвратим изменение статуса важности на пустом комментарии
    //(иначе только одно изменение статуса, которое невидимо, пройдет как изменени паспорта)
    if Trim(mem_Comment.Text) = '' then Exit;
    nedt_Attention.Value := nedt_Attention.Value xor 1;
  end;
end;

procedure TDlg_Order.Pmi1_ShowColumnsClick(Sender: TObject);
var
  i: Integer;
begin
  inherited;
  for i := 0 to DBGridEh1.Columns.Count - 1 do
    DBGridEh1.Columns[i].Visible := True;
end;

procedure TDlg_Order.CalculateTable;
var
  i, j, k, RecNo: Integer;
  Sum, SumR: Variant;
begin
end;

procedure TDlg_Order.CalculateTableRow;
  //посчитаем сумма по текущей строке таблицы
var
  i, j, k, RecNo: Integer;
  Sum, SumF, SumPP: extended;
  e1: extended;
begin
{
вариант, когда скидки задаютя в таблице, и считаются суммы со скидками
  //сумма без скидки
  SumF:=RoundTo(S.NNum(MemTableEh1.FieldByName('qnt').Value) * S.NNum(MemTableEh1.FieldByName('price').Value), -2);
  //сумма со скидкой
  Sum:=RoundTo(
     S.NNum(MemTableEh1.FieldByName('qnt').Value) *
    (S.NNum(MemTableEh1.FieldByName('price').Value) - (S.NNum(MemTableEh1.FieldByName('discount').Value) /100 * S.NNum(MemTableEh1.FieldByName('price').Value))),
    -2);
  //установим поля таблицы
  MemTableEh1.FieldByName('sum').Value:= Sum;
  MemTableEh1.FieldByName('sum_resale').Value:= S.IIfV(MemTableEh1.FieldByName('resale').AsInteger = 1, Sum, 0);
  MemTableEh1.FieldByName('sum_discount').Value:= SumF - Sum;
}
  //сумма общая без скидки
  SumF := RoundTo(S.NNum(MemTableEh1.FieldByName('qnt').Value) * S.NNum(MemTableEh1.FieldByName('price').Value), -2);
  MemTableEh1.FieldByName('sum').Value := SumF;
//  //сумма покупных позицмй
//  MemTableEh1.FieldByName('_sum_resale').Value:= S.IIfV(MemTableEh1.FieldByName('resale').AsInteger = 1, SumF, 0);
  //сумма перепродажи (д.к) в изделиях
  SumPP := RoundTo(S.NNum(MemTableEh1.FieldByName('qnt').Value) * S.NNum(MemTableEh1.FieldByName('price_pp').Value), -2);
  MemTableEh1.FieldByName('_sum_resale').Value := SumPP;
  //сумма изделий в производство (не с сгп), за исключением доп комплектации
//  MemTableEh1.FieldByName('_sum_items_nosgp').Value:= S.IIfV((MemTableEh1.FieldByName('resale').AsInteger = 1)or(MemTableEh1.FieldByName('sgp').AsInteger = 1), 0, SumF);
  MemTableEh1.FieldByName('_sum_items_nosgp').Value := S.IIfV(MemTableEh1.FieldByName('sgp').AsInteger = 1, 0, SumF - SumPP);
  //пост, чтобы эти значения стали видны
  MemTableEh1.Post;
  MemTableEh1.Edit;
  SetSumInHeader;
end;

procedure TDlg_Order.cmb_CustomerLegalNameGetItemImageIndex(Sender: TObject; ItemIndex: Integer; var ImageIndex: Integer);
begin
  inherited;
  ImageIndex := -1;
  if Mode = fView then
    Exit;
  if ItemIndex >= 0 then
    ImageIndex := 0;
end;

procedure TDlg_Order.cmb_CustomerManGetItemImageIndex(Sender: TObject; ItemIndex: Integer; var ImageIndex: Integer);
begin
  inherited;
  ImageIndex := -1;
  if Mode = fView then
    Exit;
  if ItemIndex >= 0 then
    ImageIndex := 0;
end;

procedure TDlg_Order.cmb_CustomerNameGetItemImageIndex(Sender: TObject; ItemIndex: Integer; var ImageIndex: Integer);
begin
  //если здесь задаем ImageIndex, то картинка отображается в самом комбобоксе и во всех строках выпадающего списка
  //если же просто задать Images для комбобокса, то картинка бедт браться из имиджлиста в соответствии с итеминдекс, при этом и в выпадающем списке они будут разные
  //отличаются, надо разбираться:
  //procedure TDlg_Order.cmb_CustomerManGetImageIndex(Sender: TObject;
  //procedure TDlg_Order.cmb_CustomerManGetItemImageIndex(Sender: TObject;
//  cmb_CustomerName.Images:=nil; //Il_Columns;
//  cmb_CustomerMan.Images:=Il_Columns;
//  cmb_CustomerLegalName.Images:=Il_Columns;
  inherited;
  ImageIndex := -1; //без картинки
  if Mode = fView then
    Exit;
  //если есть в списке, нарисуем зелеую черту
  if ItemIndex >= 0 then begin
    ImageIndex := 0;
  end;
end;

procedure TDlg_Order.cmb_OrderTypeEditButtons0Click(Sender: TObject; var Handled: Boolean);
var
  res: TMDIResult;
begin
  inherited;
  if FNewOrderType <> 1 then
    Exit;
  res := TFrmOGselOrReglament.Show(
    Self, '', MyFormOptions + [myfoDialog, myfoSizeable, myfoModal], S.IIf(not (Mode in [fView, fDelete]), fEdit, fView), Cth.GetControlValue(cmb_OrderType), FieldsArr[GetFieldsArrPos('ids_order_properties'), cNewValue]
  );
  if res.ModalResult <> mrOk then
    Exit;
  if res.DataA[0][0] = -1 then begin
    FieldsArr[GetFieldsArrPos('id_reglament'), cNewValue] := null;
    FieldsArr[GetFieldsArrPos('ids_order_properties'), cNewValue] := '';
    dedt_Otgr.Value := null;
  end
  else begin
    FieldsArr[GetFieldsArrPos('id_reglament'), cNewValue] := res.DataA[0][0];
    FieldsArr[GetFieldsArrPos('ids_order_properties'), cNewValue] := res.DataA[0][1];
    dedt_Otgr.Value := IncDay(dedt_Beg.Value, res.DataA[0][2] - 1);
  end;
end;

procedure TDlg_Order.chb_ViewEmptyItemsClick(Sender: TObject);
begin
  inherited;
  if InLoadData then
    Exit;
  HideEmptyItems;
end;

procedure TDlg_Order.SetSumInHeader;
//расчет сумм по заказу, суммы по изделиям и доп комплектации берутся из футеров таблицы
var
  i: Integer;
  nds, sum_items_nosgp: extended;
begin
  if InLoadData then
    Exit;
  //суммма перепродажи в составе всех изделий
  nedt_AC_0.Value := S.NNum(Gh.GetGridColumn(DBGridEh1, '_sum_resale').Footer.SumValue);
  //сумма изделий, кроме перепродажной части в них, но по изделиям с сгп принимается = 0
  sum_items_nosgp := S.NNum(Gh.GetGridColumn(DBGridEh1, '_sum_items_nosgp').Footer.SumValue);
  //суммма всех изделий, кроме перепродажной части в них
  nedt_Items_0.Value := S.NNum(Gh.GetGridColumn(DBGridEh1, 'sum').Footer.SumValue) - S.NNum(nedt_AC_0.Value);
  nedt_AC.Value := RoundTo(S.NNum(nedt_AC_0.Value) + S.NNum(nedt_AC_0.Value) / 100 * S.NNum(nedt_AC_M.Value) - S.NNum(nedt_AC_0.Value) / 100 * S.NNum(nedt_AC_D.Value), -2);
  nedt_Items.Value := RoundTo(S.NNum(nedt_Items_0.Value) + S.NNum(nedt_Items_0.Value) / 100 * S.NNum(nedt_Items_M.Value) - S.NNum(nedt_Items_0.Value) / 100 * S.NNum(nedt_Items_D.Value), -2);
  nedt_Items_NoSgp.Value := RoundTo(S.NNum(sum_items_nosgp) + S.NNum(sum_items_nosgp) / 100 * S.NNum(nedt_Items_M.Value) - S.NNum(sum_items_nosgp) / 100 * S.NNum(nedt_Items_D.Value), -2);
  nedt_Trans.Value := RoundTo(S.NNum(nedt_Trans_0.Value) + S.NNum(nedt_Trans_0.Value) / 100 * S.NNum(nedt_Trans_M.Value) - S.NNum(nedt_Trans_0.Value) / 100 * S.NNum(nedt_Trans_D.Value), -2);
  nedt_Montage.Value := RoundTo(S.NNum(nedt_Montage_0.Value) + S.NNum(nedt_Montage_0.Value) / 100 * S.NNum(nedt_Montage_M.Value) - S.NNum(nedt_Montage_0.Value) / 100 * S.NNum(nedt_Montage_D.Value), -2);
  nedt_Sum.Value := nedt_Items.Value + nedt_AC.Value + nedt_Trans.Value + nedt_Montage.Value;
  nedt_Discount.Value := nedt_Sum.Value - nedt_Items_0.Value + nedt_AC_0.Value + nedt_Trans_0.Value + nedt_Montage_0.Value;
  //посчитаем сумму без ндс, выделать ли ндс смотрим в массиве организаций
  nds := 0;
  //возьмем ндс из массива ораганизаций, при этом данные в массиве сдвинуты вниз, в нем нет первой строки комбобокса Производство
  if (cmb_Organization.ItemIndex > 0) and (cmb_Organization.ItemIndex <= High(Organizations) + 1) then
    nds := S.IIf(S.NSt(Organizations[cmb_Organization.ItemIndex - 1][3]) <> '', 20, 0);
  nedt_SumWoNds.Value := RoundTo(nedt_Sum.Value / ((nds + 100) / 100), -2);
{  nedt_AddCompl.Value:=Gh.GetGridColumn(DBGridEh1, 'sum_resale').Footer.SumValue;
  nedt_Discount.Value:=Gh.GetGridColumn(DBGridEh1, 'sum_discount').Footer.SumValue;
  nedt_Sum.Value:=Gh.GetGridColumn(DBGridEh1, 'sum').Footer.SumValue + S.NNum(nedt_SumOtgr.Value) + S.NNum(nedt_SumMontage.Value);}
end;

procedure TDlg_Order.DBGridEh1ColumnsUpdateData(Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
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
  NoErr: Boolean;
  val: Variant;
  fn: string;
  dt1: TDateTime;
  st, fst: string;
  rn: Integer;
  i, j: Integer;
  b, IsStd, FromSgp: Boolean;
  RecNo: Integer;
begin
  //имя поля
  fn := DBGridEh1.Columns[DBGridEh1.Col - 1].FieldName;
  //значение
  val := S.IIfV(UseText, Text, Value);
  //уберем пробелы
  if (fn = 'name') or (fn = 'comm') then begin
    val := Trim(val);                //Убрать плохие символы!!!
  end;
  //установим значение из переданного, это обязательно , на нулл проверять обязательно, иначе невозможно ввести пустую строку в числовые поля!
  b := True;
  if S.NSt(Value) = '' then begin
    MemTableEh1.FieldByName(fn).Value := null;
    b := False;
  end
  else begin
    if ((MemTableEh1.FieldByName(fn).DataType = ftFloat) and not S.IsNumber(val, 0, 999999999999, -1)) or ((MemTableEh1.FieldByName(fn).DataType = ftInteger) and not S.IsNumber(val, 0, 999999999999, 0)) then begin
      MemTableEh1.FieldByName(fn).Value := null;
      b := False;
    end;
  end;
if fn = 'resale' then begin
//не изменяем это поле
b:=True;
val:=MemTableEh1.FieldByName(fn).Value;
end;
  if b then
    MemTableEh1.FieldByName(fn).Value := val;
  //чтобы изменения отобразились в строках таблицы, надо их выполнять до Handled и Post
  if (fn = 'name') or (fn = 'sgp') or (fn = 'wo_estimate') then begin
    //пересчитываем данные полей строки, если изменилось однно из этих полей - так как от их значениие много зависимостей в строке
    //также меняем и доступность полей для редактирования
    CorrectRowIfNameChanged;
  end;
  //если меняли цену, то скорректируем цену перепродажи так, чтобы она была не больше полной, а для д/к равной ей
  if (fn = 'price') then begin
    if (MemTableEh1.FieldByName('resale').Value = 1) or (MemTableEh1.FieldByName('price_pp').Value > Value) then
      MemTableEh1.FieldByName('price_pp').Value := Value;
  end;
  //если меняли цену перепродажи, то скорректируем цену перепродажи так, чтобы она была не больше полной, а для д/к равной ей
  if (fn = 'price_pp') then begin
    if (MemTableEh1.FieldByName('resale').Value = 1) or (MemTableEh1.FieldByName('price').Value < Value) then
      MemTableEh1.FieldByName('price_pp').Value := MemTableEh1.FieldByName('price').Value;
  end;
  //при любом русном изменении в гриде зафиксируем тип сметы и префиксы
  LockStdFormat;
  //проставим, какое поле было изменено, процедура проверит изменения по всем полям записи
  SetTableChanges(fn);
  //!!!в процедуре обход таблицы по строкам, но использовать его НЕЛЬЗЯ
  //если ставим здесь, до обработки, то сбрасывается ввод, ввод данных вообще не принимается,
  //если ставить после, то при обходе возвращаются вообще неверные строки
  //обработано
  Handled := True;
  //постим
  Mth.Post(MemTableEh1);
  //в редактирование
  MemTableEh1.Edit;
  //поэтому считаем с помощью задагния футеров и в процедуре берем значения из них
  CalculateTableRow;
  //проверим текущую строку
  IsItemValid(0);
end;

procedure TDlg_Order.CorrectRowIfNameChanged(DisableOnly: Boolean = False);
//проверяем, является ли изделие в поле наименование стандартным - есть ли в списке, и также дествия зависят от галки СГП
//в зависимости от этого или только блокирем изменение зависимых ячеек (это при переходе по записям в мемтейбл),
//либо корректируем еще и их значения (при вызове при изменении значения вручную, и при загрузке таблицы в режиме копирования заказа)
var
  NoErr: Boolean;
  val: Variant;
  fn: string;
  dt1: TDateTime;
  st, fst: string;
  rn: Integer;
  i, j: Integer;
  b, IsStd, FromSgp, WoEstimate: Boolean;
  RecNo: Integer;
begin
  //для названия, проверим есть ли в списке стандартных
  for i := 0 to High(StdItems) do
    if MemTableEh1.FieldByName('name').AsString = StdItems[i][1] then
      Break;
  IsStd := i <= High(StdItems);
  FromSgp := MemTableEh1.FieldByName('sgp').Value = 1;
  WoEstimate := MemTableEh1.FieldByName('wo_estimate').Value = 1;
  //IsStd and (StdItems[i][2] = 1);
{  if IsStd then begin
    LockStdFormat;
  end;}
  //заблокирем изменение зависимых
//  Gh.GetGridColumn(DBGridEh1, 'kns').ReadOnly := IsStd;
//ch 2024-08-26 - конструктор допустим для стандартных изделий, но по-прежнему недопустим при получении с сгп
  Gh.GetGridColumn(DBGridEh1, 'kns').ReadOnly := FromSgp or WoEstimate;
  Gh.GetGridColumn(DBGridEh1, 'thn').ReadOnly := FromSgp or WoEstimate;
  Gh.GetGridColumn(DBGridEh1, 'resale').ReadOnly := True; //IsStd;
  Gh.GetGridColumn(DBGridEh1, 'price_pp').ReadOnly := MemTableEh1.FieldByName('resale').Value = 1;
  Gh.GetGridColumn(DBGridEh1, 'wo_estimate').ReadOnly := IsStd or NoChangeItems;
  for j := 1 to High(RouteFields) + 1 do begin
    Gh.GetGridColumn(DBGridEh1, 'r' + IntToStr(j)).ReadOnly := IsStd or FromSgp or WoEstimate;
  end;
  //выход, если не надо менть значения
  if DisableOnly then Exit;
  //коррекция зависимых значений
  //StdItems  адйи, имя, null, 9 участков производства, доп.компл, цена, цена перепродажи
  if not IsStd then MemTableEh1.FieldByName('id_std').Value := null;
  MemTableEh1.FieldByName('std').Value := S.IIf(IsStd, 1, 0);
  MemTableEh1.FieldByName('nstd').Value := S.IIf(IsStd, 0, 1);
  //MemTableEh1.FieldByName('sgp').Value:= S.IIf(FromSgp, 1, 0);
  if IsStd then begin
    MemTableEh1.FieldByName('id_std').Value := StdItems[i][0];
    for j := 1 to  High(RouteFields) + 1 do begin
      MemTableEh1.FieldByName('r' + IntToStr(j)).Value := S.IIf(StdItems[i][2 + j] = 1, 1, 0);
    end;
    MemTableEh1.FieldByName('resale').Value := S.IIf(StdItems[i][2 + 9 + 1] = 1, 1, 0);
    MemTableEh1.FieldByName('price').Value := StdItems[i][2 + 9 + 1 + 1];
    MemTableEh1.FieldByName('price_pp').Value := StdItems[i][2 + 9 + 1 + 2];
    MemTableEh1.FieldByName('wo_estimate').Value := StdItems[i][2 + 9 + 1 + 2 + 1];
  end;
  //дублируем здесь зависимости от галки Без сметы
  WoEstimate := MemTableEh1.FieldByName('wo_estimate').Value = 1;
  Gh.GetGridColumn(DBGridEh1, 'kns').ReadOnly := FromSgp or WoEstimate;
  Gh.GetGridColumn(DBGridEh1, 'thn').ReadOnly := FromSgp or WoEstimate;
  if (FromSgp) or WoEstimate or (MemTableEh1.FieldByName('resale').Value = 1) then begin
    MemTableEh1.FieldByName('kns').Value := -100;
    MemTableEh1.FieldByName('thn').Value := -100;
    for j := 1 to  High(RouteFields) + 1 do begin
      MemTableEh1.FieldByName('r' + IntToStr(j)).Value := 0;
    end;
  end
  else if IsStd then begin
    //MemTableEh1.FieldByName('kns').Value := -100;   //2024-08-26 убираем проверку - для стандартного изделия может быть выбран конструктор
    if S.NNum(MemTableEh1.FieldByName('thn').AsVariant) <= 0 then
      MemTableEh1.FieldByName('thn').Value := -102;
  end
  else begin
    if S.NNum(MemTableEh1.FieldByName('kns').AsVariant) <= 0 then
      MemTableEh1.FieldByName('kns').Value := -101;
    if S.NNum(MemTableEh1.FieldByName('thn').AsVariant) <= 0 then
      MemTableEh1.FieldByName('thn').Value := -102;
  end;
  if MemTableEh1.FieldByName('resale').Value = 1 then begin
    MemTableEh1.FieldByName('price_pp').Value := MemTableEh1.FieldByName('price').Value;
  end;

end;

procedure TDlg_Order.LockStdFormat;
//заблокируем изменение косбобоксов выбора типа формата/сметы, вернем зависящий от типа сметы айди и префикс для изделий
var
  i, j: Integer;
  v: Variant;
begin
  cmb_Format.Enabled := False;
  cmb_EstimatePath.Enabled := False;
  Id_Estimate := S.NInt(Cth.GetControlValue(cmb_EstimatePath));
  ItemPrefix := '';
  if Id_Estimate = 0 then
    Exit;
  for i := 0 to High(EstimateDirs) do
    if EstimateDirs[i][1] = Id_Estimate then begin
      ItemPrefix := EstimateDirs[i][2];
      Exit;
    end;
end;

procedure TDlg_Order.DBGridEh1Enter(Sender: TObject);
begin
  inherited;
  LoadStdItems;
end;

procedure TDlg_Order.DBGridEh1Exit(Sender: TObject);
begin
  inherited;
  //
end;

procedure TDlg_Order.DBGridEh1GetCellParams(Sender: TObject; Column: TColumnEh; AFont: TFont; var Background: TColor; State: TGridDrawState);
begin
  inherited;
  //подсветим в таблице измененные поля желтым цветом фона
  if Pos(LowerCase(',' + Column.FieldName + ','), LowerCase(',' + MemTableEh1.FieldByName('chg').AsString + ',')) > 0 then
    Background := GetDiffColor; //RGB(255,150,150);
  //подсветим поле наименования по признаку B00000010 цветом фона
  if (Column.FieldName = 'name') and ((MemTableEh1.FieldByName('attention').AsInteger and 2) <> 0) then
    Background := RGB(150, 255, 150);
  //подсветим комментарий красным шрифтом
  if (Column.FieldName = 'comm') and ((MemTableEh1.FieldByName('attention').AsInteger and 1) <> 0) then
    AFont.Color := RGB(255, 0, 0);
end;

procedure TDlg_Order.DBGridEh1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
//установим признак важности комментария или строки шаблона
begin
  inherited;
  if (not DBGridEh1.ReadOnly) then begin
    if (Key = Ord('Q')) and (Shift = [ssCtrl]) and (Trim(MemTableEh1.FieldByName('comm').AsString) <> '') then begin
      //предотвратим изменение статуса важности на пустом комментарии
      //(иначе только одно изменение статуса, которое невидимо, пройдет как изменени паспорта)
      MemTableEh1.FieldByName('attention').Value := MemTableEh1.FieldByName('attention').AsInteger xor 1;
      SetTableChanges('');
    end;
    if (Key = Ord('W')) and (Shift = [ssCtrl]) and (not DBGridEh1.ReadOnly) and (IsTemplate) then begin
      //статус для шаблона
      MemTableEh1.FieldByName('attention').Value := MemTableEh1.FieldByName('attention').AsInteger xor 2;
      SetTableChanges('');
    end;
  end;
end;

procedure TDlg_Order.Pmi1_DeleteRowClick(Sender: TObject);
var
  i, j, k, RecNo: Integer;
begin
//  if not ((Mode <> fEdit) or IsTemplate or (MemTableEh1.RecNo > BegItemsCount))
  inherited;
  if (Mode in [fView, fDelete]) then
    Exit;
  if (Mode = fEdit) and (MemTableEh1.FieldByName('id').Value <> null) and not (IsTemplate or EnableDeleteItemInEdit) then begin
    MyInfoMessage('Эту строку удалить нельзя!');
    Exit;
  end;
  if MyQuestionMessage('Удалить строку?') <> mrYes then
    Exit;
//  if MemTableEh1.RecNo < BegItemsCount
  if MemTableEh1.FieldByName('id').Value <> null then begin
    IsTableOldRowDeleted := Min(S.IIf(IsTableOldRowDeleted = 0, 9999999, IsTableOldRowDeleted), MemTableEh1.RecNo);
    DeletedItems := DeletedItems + [OldTableValues[MemTableEh1.RecNo - 1]];
    Delete(OldTableValues, MemTableEh1.RecNo - 1, 1);
    BegItemsCount := Length(OldTableValues);
  end;
  MemTableEh1.DisableControls;
  MemTableEh1.Delete;
  Mth.PostAndEdit(MemTableEh1);
  RecNo := MemTableEh1.RecNo;
  for i := RecNo to MemTableEh1.RecordCount - 0 do begin
    MemTableEh1.RecNo := i;
    MemTableEh1.FieldByName('slash').Value := GetItemNum(MemTableEh1.RecNo);
    Mth.PostAndEdit(MemTableEh1);
  end;
  MemTableEh1.RecNo := RecNo;
  MemTableEh1.EnableControls;
  SetSumInHeader;
end;

function TDlg_Order.VerifyTable: Boolean;
//перед записью таблицы
//проверим на корректность таблицу, и уберем пустые строки с конца
var
  i, j, RecNo: Integer;
  st: string;
  b, ok: Boolean;
  s1, s2: string;
begin
  MemTableEh1.DisableControls;
  RecNo := MemTableEh1.RecNo;
  b := True;
  ok := True;
  for i := MemTableEh1.RecordCount downto 1 do begin
    MemTableEh1.RecNo := i;
    //проверим текущую строку
    IsItemValid(0);
    //счистем что пустые с конца таблицы это нормально и их просто удаляем
    if (MemTableEh1.FieldByName('status').AsString = 'C') and b then begin
      MemTableEh1.Delete;
    end
    else
      b := False;
    //чтобы вернуть Ок, должны быть без ошибок, или с признаком 0 кол-ва, или не заполненные с конца
    if not (((MemTableEh1.FieldByName('status').AsString = 'C') and b) or (MemTableEh1.FieldByName('status').AsString = '0') or (MemTableEh1.FieldByName('status').AsString = '')) then
      ok := False;
  end;
  MemTableEh1.RecNo := S.IIf(RecNo < MemTableEh1.RecordCount, RecNo, 1);
  MemTableEh1.EnableControls;
  Result := ok;
//  if not Ok
//    then MyWarningMessage('Информация в таблице изделий некорректна!');
end;

function TDlg_Order.RenameSlashes: Boolean;
//переименуем слэши в таблице, соотвественно номеру заказа
//вызывается при изменении организации
var
  i, j, RecNo: Integer;
  s1, s2: string;
begin
  MemTableEh1.DisableControls;
  RecNo := MemTableEh1.RecNo;
  for i := MemTableEh1.RecordCount downto 1 do begin
    MemTableEh1.RecNo := i;
    //проставим слеши, если изменились
    MemTableEh1.FieldByName('slash').Value := GetItemNum(MemTableEh1.RecNo);
    Mth.PostAndEdit(MemTableEh1);
  end;
  MemTableEh1.RecNo := RecNo;
  MemTableEh1.EnableControls;
end;

function TDlg_Order.IsTableChanged: Integer;
//проверим, были ли изменения в таблице  (0 - не было изменнний, 1 - были, -1 - есть ошибки в таблице, -2 - таблица пустая)
var
  i, j, RecNo: Integer;
begin
  Result := -2;
  //если таблица пуста, или
  //есть одна незаполеннная строка (по факту так и будет, она не исчезнет), то вернем признак пустой таблицы
  if MemTableEh1.RecordCount = 0 then
    Exit;
  if (MemTableEh1.RecordCount = 1) and (MemTableEh1.FieldByName('status').AsString = 'C') then
    Exit;
  Result := 0;
  MemTableEh1.DisableControls;
  RecNo := MemTableEh1.RecNo;
  for i := MemTableEh1.RecordCount downto 1 do begin
    MemTableEh1.RecNo := i;
    //если есть ошибка, поставим лаг и завершим цикл
    if (MemTableEh1.FieldByName('status').AsString = 'E') then begin
      Result := -1;
      Break;
    end;
    //если проставлено CHg или айди =0 (то есть была добавлена позиция) - изменения были
    if (MemTableEh1.FieldByName('chg').AsString <> '') or (MemTableEh1.FieldByName('id').Value = null) then begin
      Result := 1;
    end;
  end;
  MemTableEh1.RecNo := RecNo;
  MemTableEh1.EnableControls;
  if Result <> 0 then
    Exit;
  //Если это не редактирование, то считаем что были изменения
  //Если были удаления позиций, то были изменения
  Result := S.IIf((Mode <> fEdit) or (Length(DeletedItems) > 0), 1, 0);
end;

function TDlg_Order.SaveTable: Boolean;
var
  va1: TVarDynArray2;
  va2: TVarDynArray;
  va: array of Variant;
  i, j, RecNo, Res: Integer;
  st, Fields: string;
  b, ok, chgr: Boolean;
  v: Variant;
  id_order: Variant;
  GetIzdNeed: Boolean;
  n: TVarDynArray;
  id_itm_izdel: Variant;
  SyncItemWithItm: Boolean;
begin
//exit;
  SetOrderSaveStatusText('Сохранение табличной части заказа');
  Result := True;
  if Mode = fDelete then
    Exit;
  Result := False;
  RecNo := MemTableEh1.RecNo;
  //сюда будут складиваться айди, для которых после записи меняем смету
  ItemsToEstimateChange := [];
  repeat
    if not VerifyTable then
      Break;
//  if Mode <> fEdit then Exit;
  //поля с СГП, НСТД и СТД не могут стоять одновременно из-за контроля ввода
  //слэш не сохраняется, он получается во вьюхе из позиции и номера заказа
    Fdbs := ['id$i', 'id_order$i', 'id_std_item$i', 'id_itm$i', 'pos$i', 'ch$s', 'std$i', 'nstd$i', 'qnt$f', 'sgp$f', 'r0$i', 'wo_estimate', 'id_kns$i', 'id_thn$i', 'comm$s', 'price$f', 'price_pp$f', 'attention$i', 'disassembled$i', 'control_assembly$i'];
    Fmts := ['id', '', 'id_std', 'id_itm', '', 'chg', 'std', 'nstd', 'qnt', 'sgp', 'resale', 'wo_estimate', 'kns', 'thn', 'comm', 'price', 'price_pp', 'attention', 'disassembled', 'control_assembly'];
  //дополним поля для маршрута, и там и там называются rxx
    for i := 0 to High(RouteFields) do begin
      Fdbs := Fdbs + ['r' + IntToStr(i + 1) + '$i'];
      Fmts := Fmts + ['r' + IntToStr(i + 1)];
    end;
    b := True;
    ok := True;
  //в режиме редактирования удадим строки, дошедшие из старых заказов и удаленные по ПКМ
    if Mode = fEdit then
      for i := 0 to High(DeletedItems) do begin
        Res := Q.QExecSql('delete from order_items where id = :id$i', [DeletedItems[i][0]]);
///!!!втавить удаление из ИТМ
        if Res < 0 then
          Break;
      end;
  //в режиме копирования сбросим все изменения в таблице, тк они там остались со старого сохранения, а в мемтейбл уже могут не быть
  //то же и в режиме редактирования, сбросим сначала все изменения, так как если не было изменения в данной строкке таблицы, то не будуту иначе переписаны и поля изменений
    if (Mode = fCopy) or (Mode = fEdit) then begin
      Res := Q.QExecSql('update order_items set ch = '''' where id_order = :id_order$i', [ID]);
      if Res < 0 then
        Break;
    end;
    Res := 0;
    for i := 1 to MemTableEh1.RecordCount do begin
      MemTableEh1.RecNo := i;
      if (MemTableEh1.FieldByName('status').AsString = 'C') then
        Continue;
      va := [];
      for j := 0 to High(Fdbs) do begin
        Res := 0;
        if (Fdbs[j] = '') and (Fmts[j] = '') then Continue;
        if (Fdbs[j] = 'id_order$i') then v := ID;
        if Fmts[j] <> '' then v := MemTableEh1.FieldByName(Fmts[j]).Value;
      //айди изделия в заказе в ИТМ
      //учитываем только в случае редактирования заказа
        if (Fdbs[j] = 'id_itm$i') then id_itm_izdel := S.IIfV(Mode = fEdit, v, null);
    {  if (Fmts[j] = 'kns')or(Fmts[j] = 'thn')  //было нужно, чтобы сохранить в бд пустое значение, для выбранного значения Нет, сейчас добален [нет] = -100 в список пользователей
        then if v = -1
          then v:= null;}
      //признак, что строку надо писать в БД
      //если не редактирование, то в любом случае, а при редактировании если были изменения, или айди пустой - это добавление (проверим потом)
        if (Fdbs[j] = 'ch$s') then chgr := (Mode <> fEdit) or (S.NSt(v) <> '');
      //если не режим редактирования, то строку изменения изделия не сохраняем в бд
        if (Fdbs[j] = 'ch$s') and (Mode <> fEdit) then v := null;
      //если не режим редактирования, то строки в любом случае вставляются в таблицу с новым ади
        if (Fmts[j] = 'id') and (Mode <> fEdit) then v := null;
      //номер слеша
        if (Fdbs[j] = 'pos$i') then v := i;
        if (Fmts[j] = 'id_std') then begin
          if S.NNum(MemTableEh1.FieldByName('nstd').Value) = 1 then begin
            n := Q.QCallStoredProc('p_CreateOrStdItem_Nstd', 'name$s;newid$io', [MemTableEh1.FieldByName('name').AsString, -1]);
            if Length(n) = 0
              then Res := -1 else v := n[1];
          end;
        end;
        if (Fmts[j] = 'attention') and (not IsTemplate) //снимем бит подсветки строки шаблона при сохраниии готового паспорта
          then v := v and not 2;
        //для записи в базу полей, которые чекбоксами, без вариантов null, только 0 или 1
        if S.InCommaStr(Fmts[j], CheckBoxFields, ';')
          then v:= S.NInt(v);
        va := va + [v];
        if Res < 0 then Break;
      end;
      if Res < 0 then Break;
      Fields := A.Implode(Fdbs, ';');
    //va[0] - id
      if (va[0] = null) or chgr then begin
    //если нет в таблице айди - т.е. это вставка, или были изменения
      //синхронизаций нужна при изменинии названия, количества, признака стд и к/к, в
      //этом же случае будут обновляться сметы
        SyncItemWithItm := (va[0] = null) or (id_itm_izdel = null) or S.InCommaStr('name', MemTableEh1.FieldByName('chg').AsString) or
          S.InCommaStr('qnt', MemTableEh1.FieldByName('chg').AsString) or S.InCommaStr('std', MemTableEh1.FieldByName('chg').AsString) or
          S.InCommaStr('resale', MemTableEh1.FieldByName('chg').AsString);
(*      //если заказа не синхронизирован с ИТМ, то  и изделия не синхронизируем!
        if not OrSyncWithITM or (ID_Itm = null) then SyncItemWithItm := False;
      //вызовем процедуру синхронизации позиции заказа с ИТМ
      //после этого надо обязаетльно загрузить смету, если она есть, так как иначе все сметные позиции по изделию удалятся
        if SyncWithITM and SyncItemWithItm and not IsTemplate then begin
          Q.QExecSql('insert into adm_db_log (itemname, comm) values (:itemname$s, :comm$s)', ['pnl_SyncIzdel', 'id_zakaz ' + VarToStr(Id_ITM) + ', id_izdel ' + VarToStr(id_itm_izdel)]);
          va2 := Q.QCallStoredProc('dv.p_SyncIzdel', 'id_dv$i;typeoperation$i;nameizdel$s;countizdel$f;idparentizdel$i;idaddizdel$io',
          [ID_Itm, S.IIfV(id_itm_izdel = null, 1, 2), S.IIFStr(MemTableEh1.FieldByName('prefix').AsString = '', '', MemTableEh1.FieldByName('prefix').AsString + '_') + MemTableEh1.FieldByName('name').AsString, MemTableEh1.FieldByName('qnt').Value, MemTableEh1.FieldByName('id_itm').Value, -1]);
          Res := S.IIf((Length(va2) = 0) or (va2[5] = -1), -1, 1);
          if Res < 0 then  Break;
        //установим id_itm для изделия и записи в дальнейшем в бд учета
        //(возвращается айди процедурой только при опреации = 1 - вставка
          if id_itm_izdel = null then
            va[3] := va2[5]
          else
            va[3] := id_itm_izdel;
        end;              *)
      //запись строки в таблицу позиций заказа
        Res := Q.QIUD(S.IIFStr(va[0] = null, 'i', 'u')[1], 'order_items', '', Fields, VarArrayOf(va));
        if Res < 0 then  Break;
      //добавим в массив айди этой позиции в списке изделий заказа,
      //для вызова после сохранения заказа процедуру коррекции смет, по данным позициям
        ItemsToEstimateChange := ItemsToEstimateChange + [S.IIfV(va[0] = null, Res, va[0])];
      //CreateEstimateToItem(i, S.IIfV(va[0] = null, Res, MemTableEh1.FieldByName('id').Value), va[2], va[3]);
      end;
    end;
    if Res < 0 then  Break;
    Result := True;
  until True;
  MemTableEh1.RecNo := S.IIf(RecNo < MemTableEh1.RecordCount, RecNo, 0);
  MemTableEh1.EnableControls;
end;

procedure TDlg_Order.CreateEstimateToItem(rn, id_item, id_item_itm, id_item_name: Integer);
var
  chgst: string;
  CreateNew: Boolean;
  IdEstimate: Variant;
begin
(*  Exit;
  IdEstimate := null;
  chgst := MemTableEh1.FieldByName('chg').AsString;
  if MemTableEh1.FieldByName('id').AsString <> '' then
    IdEstimate := Q.QSelectOneRow('select id from estimates where id_order_item = :id_order_item$i', [id_item])[0];
  CreateNew := (IdEstimate = null) or (MemTableEh1.FieldByName('id').AsString = '') or S.InCommaStr('name', chgst) or S.InCommaStr('std', chgst) or S.InCommaStr('resale', chgst);
  if (not CreateNew) and (S.InCommaStr('qnt', chgst)) then begin
    if S.NNum(MemTableEh1.FieldByName('qnt').Value) = 0 then begin
      Q.QExecSql('delete from estimates where id_order_item = :id_order_item$i', [id_item]);
      IdEstimate := null;
      CreateNew := True;
    end
    else
      Q.QExecSql('update estimate_items set qnt = round(qnt1 * :qnt_or$f, 1) where id_estimate = :id_estimate$i', [MemTableEh1.FieldByName('chg').Value, IdEstimate]);
  end;
*)
end;

procedure TDlg_Order.SetTableChanges(fn: string);
//получим список измененных полей (только те что были загружены, а не расчетных), и сохраним его в поле 'chg' через запятую
//вызывается при изменении значения вручную, потому только при ручном редактировании таблице, притом если было изменение значения
var
  va1: TVarDynArray2;
  i, j: Integer;
  st: string;
  va: TVarDynArray;
begin
  //проставлять изменения нам нужно только в режиме редактирования
  if not (Mode in [fEdit]) then Exit;
  va := [];
//  if MemTableEh1.RecNo > BegItemsCount then begin
  if MemTableEh1.FieldByName('id').Value = null then begin
    //для добавленных строк будет поле Slash признаком добавления
    MemTableEh1.FieldByName('chg').Value := 'slash';
    Exit;
  end;
  for i := 0 to MemTableEh1.Fields.Count - 1 do begin
    //пройдем по всем полям, кроме slash
    for j := 0 to High(Fmt) do begin
      if MemTableEh1.Fields[i].FieldName = 'slash' then
        Continue;
      if MemTableEh1.Fields[i].FieldName = 'chg' then
        Continue;
      //если поле есть в массив и изменилось, сохраним в изменениях
      if (Fmt[j] = MemTableEh1.Fields[i].FieldName) and (High(OldTableValues) >= MemTableEh1.RecNo - 1) and (OldTableValues[MemTableEh1.RecNo - 1][j] <> MemTableEh1.Fields[i].Value) then
        va := va + [MemTableEh1.Fields[i].FieldName];
    end;
  end;
  //сформируем строку и запишем в поле таблицы
  //отображение красного фона в ячейке сделано при отрисовке уже из этого поля
  st := A.Implode(va, ',');
  MemTableEh1.FieldByName('chg').Value := st;
end;

procedure TDlg_Order.LoadTable;
var
  va1: TVarDynArray2;
  i, j, k, m: Integer;
  st: string;
  IsStd, IsResale: Integer;
  b : Boolean;
  v: Variant;
begin
  //if Mode <> fEdit then Exit;
  //поля в базе и таблице соответственно, чтобы записывалось в таблицу автоматом, должно быть непустое в обоих массивах
  //наименование читается расчетное, т.е. если изменилось в справочнике, то сразу прочитано будет измененное
  Fdb := ['id', 'id_std_item', 'id_itm', 'slash', 'ch', 'std', 'nstd', 'itemname', 'qnt', 'sgp', 'r0', 'wo_estimate', 'id_kns', 'id_thn', 'comm', 'price', 'price_pp', 'disassembled', 'control_assembly', 'attention'];
  Fmt := ['id', 'id_std', 'id_itm', 'slash', 'chg', 'std', 'nstd', 'name', 'qnt', 'sgp', 'resale', 'wo_estimate', 'kns', 'thn', 'comm', 'price', 'price_pp', 'disassembled', 'control_assembly', 'attention'];
  SetLength(OldTableValues, 0);
  //дополним поля для маршрута, и там и там называются rxx
  for i := 0 to High(RouteFields) do begin
    Fdb := Fdb + ['r' + IntToStr(i + 1)];
    Fmt := Fmt + ['r' + IntToStr(i + 1)];
  end;
  //строка полей для запроса
  st := A.Implode(Fdb, ',');
  //запрос на чтение
  va1 := Q.QLoadToVarDynArray2('select ' + st + ' from v_order_items where id_order = :id_order$i order by pos', [FieldsArr[0][cBegValue]]);
  //массив старых значений, размерности его и загруженного совпадаю, но не делаем присваивание так ка при загрузке в мемтейбл может быть пересчет значений
  SetLength(OldTableValues, Length(va1));
  MemTableEh1.DisableControls;
  //проход по массиву результаттов
  for i := 0 to High(va1) do begin
    SetLength(OldTableValues[i], Length(Fmt));
    //добавляем строку в мемтейбл
    MemTableEh1.Append;
    MemTableEh1.Edit;
    for j := 0 to High(Fdb) do begin
     { //для кнс и тхн нулл в базе соответствует невыбранному конструктору, -1 (надо -100, тк -1 в пользователях - администратор)
      if (Fdb[j] = 'id_kns')or(Fdb[j] = 'id_thn')
        then if va1[i][j] = null
          then va1[i][j] :=  -1
          else begin
          end;}
      //обработаем поле Нестандарт, из бд прочитано поле Стандарт, а для этого в мемтебл инвертируем значение
  //    if (Fmt[j] = 'nstd')
  //      then va1[i][j]:= S.IIf(va1[i][j] = 1, 0, 1);
      //поправим занчений нулл для чекбоксов в 0, оно работает и так, но просто если при загрузке нулл то, то при снятии чекбокса в таблице получится 0
      //может быть, ставить -1 для стандарт например, чтобы обозначить невыбранное значение?
//      if fmt[j] = 'control_assembly' then
//        V := va1[i][j];
      if (Gh.GetGridColumn(DBGridEh1, Fmt[j]).Checkboxes) and (va1[i][j] = null) then
        va1[i][j] := 0;
      //строку изменений для таблицы грузим только для режима просмотра
      if (Fdb[j] = 'ch') and (Mode <> fView) then
        va1[i][j] := null;
      //присвоим значения из массива полям таблицы
      if (Fdb[j] <> '') and (Fmt[j] <> '') then
        MemTableEh1.FieldByName(Fmt[j]).Value := va1[i][j];
       b := True;
      //присвоим значения массиву старых значений
      OldTableValues[i][j] := va1[i][j];
    end;
    MemTableEh1.Post;
    MemTableEh1.Edit;
    //установим номер слэша, он должен пересчитываться так как может быть копия заказа
    MemTableEh1.FieldByName('slash').Value := GetItemNum(MemTableEh1.RecNo);
    //для режима копирования (в том числе и  из шаблона), проверим были ли изменения для наименований в их статусе стандартных,
    //либо, для стандартных, мог измениться статус доп комплектации
    if Mode = fCopy then begin
      for m := 0 to High(StdItems) do
        if MemTableEh1.FieldByName('name').AsString = StdItems[m][1] then
          Break;
      IsStd := S.IIf(m <= High(StdItems), 1, 0);
      if IsStd = 1 then
        IsResale := S.IIf(StdItems[m][2 + 9 + 1] = 1, 1, 0);
      //в этом случае автоматически пересчитываем значения этих строчек, так как
      if (MemTableEh1.FieldByName('std').Value <> IsStd) or ((MemTableEh1.FieldByName('std').Value = 1) and (MemTableEh1.FieldByName('resale').Value <> IsResale)) then
        CorrectRowIfNameChanged;
    end;
    //проверим валидность
    IsItemValid(0);
    //посчитаем суммы
    CalculateTableRow;
    MemTableEh1.Post;
  end;
  MemTableEh1.Edit;
  //количество загруженных строк
  BegItemsCount := High(va1) + 1;
  //в начало таблицы
  MemTableEh1.RecNo := 0;
  //изменим доступность меню
  EnableTablePopupMenu;
  MemTableEh1.EnableControls;
  //проставим сумму в заголовке заказа (она считается в цикле выше, но не отображается из-за DisableControls)
  SetSumInHeader;
end;

procedure TDlg_Order.GetChangesText;
//получим текстовое описание изменений в паспорте
var
  i, j, k, RecNo: Integer;
  st, st1, st2: string;
  va, va1: TVarDynArray;
  c: TComponent;
begin
  DifferencesText := '';
  st1 := '';
  st2 := '';
  //по заголовку паспотра
  va := A.ExplodeV(Differences, ',');
  for i := 0 to High(va) do begin
    c := Self.FindComponent(va[i]);
    if c = nil then
      Continue;
    st := TCustomDBEditEh(c).ControlLabel.Caption;
    st := StringReplace(st, #13#10, ' ', []);
    if st = '-' then
      st := 'Скидка';
    if st = '+' then
      st := 'Наценка';
    if (st = '=') or (st = 'nedt_Items_NoSgp') then
      st := '';
    st := S.DeleteRepSpaces(st);
    if (st <> '') and (Pos(', ' + st + ',', ', ' + st1 + ',') = 0) then
      S.ConcatStP(st1, st, ', ');
  end;
  if A.InArray('addfiles', va) then
    S.ConcatStP(st1, 'Внешние документы', ', ');
  if st1 <> '' then begin
    st1 := 'Шапка паспорта:'#13#10'  ' + st1;
  end;
  //по телу паспотра
  //вариант для простого перечисления всех вариантов изменений без конкретизации конкретно позиции
  va := [];
  MemTableEh1.DisableControls;
  RecNo := MemTableEh1.RecNo;
  for i := MemTableEh1.RecordCount downto 1 do begin
    MemTableEh1.RecNo := i;
    if MemTableEh1.FieldByName('id').AsVariant = null then begin
      va1 := ['id'];
    end
    else if MemTableEh1.FieldByName('chg').AsString <> '' then begin
      va1 := A.ExplodeV(MemTableEh1.FieldByName('chg').AsString, ',');
    end;
    for j := 0 to High(va1) do begin
      if ((VarToStr(va1[j])[1] = 'r') and (VarToStr(va1[j])[2] >= '0') and (VarToStr(va1[j])[2] <= '9')) then
        va1[j] := 'route'        //все галки маршрута будем считать как одну
      else if va1[j] = 'attention' then
        va1[j] := 'comm';      //изменение признака цвета важности считаем изменением дополнения
      //исключим повторы
      if not A.InArray(va1[j], va) then
        va := va + [va1[j]];
    end;
  end;
  MemTableEh1.RecNo := RecNo;
  MemTableEh1.EnableControls;
  if Length(va) > 0 then begin
    for i := 0 to High(va) do begin
      if va[i] = 'route' then
        va[i] := 'Производственный маршрут'
      else if va[i] = 'id' then
        va[i] := 'Добавлено изделие'
      else if va[i] = 'std' then
        va[i] := 'Стандарт'
      else if va[i] = 'nstd' then
        va[i] := 'Нестандарт'
      else if va[i] = 'resale' then
        va[i] := 'Доп. комплектация'
      else if va[i] = 'price_pp' then
        va[i] := 'Цена Д/К в цене изделия'
      else begin
        va[i] := Gh.GetGridColumn(DBGridEh1, va[i]).Title.Caption;
      end;
      S.ConcatStP(st2, va[i], #13#10);
    end;
    st2 := 'Тело паспорта:'#13#10'' + st2;
  end;
  S.ConcatStP(DifferencesText, st1, #13#10#13#10);
  S.ConcatStP(DifferencesText, st2, #13#10#13#10);
end;

function TDlg_Order.ExportPassportToXLSX(Open: Boolean = False; OnlyNot0: Boolean = False): Boolean;
var
  i, j, d1, d2, x, y, k: Integer;
  sm, sum, sumall: Double;
  v: Variant;
  Rep: TA7Rep;
  FileName: string;
  dt1, dt2: TDateTime;
  b: Boolean;
  Range: Variant;
  va: TVarDynArray;
  st, st1: string;
  c: TComponent;
  RecNo: Integer;
begin
  //Cells[Y, X]
  SetOrderSaveStatusText('Экспорт паспорта заказа в файл Excel');
  Result := True;
  if (Mode = fDelete) or (IsTemplate) then
    Exit;
  Result := False;
  FileName := Module.GetReportFileXlsx('ПЗ');
  if FileName = '' then
    Exit;
  Rep := TA7Rep.Create;
  try
    Rep.OpenTemplate(FileName, False, False);
  except
    Rep.Free;
    SetOrderSaveStatusText('');
    Exit;
  end;
  va := A.ExplodeV(Differences, ',');
  Rep.PasteBand('HEADER');
  for j := 0 to High(FieldsArr) do begin
    st := FieldsArr[j][cFieldName];
    if (st = 'id_type2') and (FNewOrderType = 1) then
      st := 'id_type';
    Rep.ExcelFind('#' + st + '#', x, y, xlValues);
    if x = -1 then
      Continue;
    c := Self.FindComponent(FieldsArr[j][cControl]);
    if c = nil then
      Continue;
//    if (st = 'comm')and(nedt_Attention.Value = 1)
//      then Rep.TemplateSheet.Cells[y, x].Font.Underline:= 2; //xlUnderlineStyleSingle;
    Rep.SetValue('#' + st + '#', TCustomDBEditEh(c).Text);
    if A.InArray(FieldsArr[j][cControl], va) then begin
      Rep.TemplateSheet.Cells[y, x].Interior.Color := GetDiffColor; //RGB(255, 170, 170);
    end;
  end;
  MemTableEh1.DisableControls;
  RecNo := MemTableEh1.RecNo;
  //в шаблоне метки соответствуют полям таблицы, кроме дополнительной - fullname
  for i := 1 to MemTableEh1.RecordCount do begin
    MemTableEh1.RecNo := i;
    //в режиме без нулевого количества, такую строку пропустим
    if OnlyNot0 and (S.NNum(MemTableEh1.FieldByName('qnt').Value) = 0) then
      continue;
    //пропустим незаполненную строку
    if MemTableEh1.FieldByName('status').AsString = 'C' then
      Continue;
    Rep.PasteBand('TABLE');
    Rep.SetValue('#pos#', IntToStr(i));
    for j := 0 to MemTableEh1.Fields.count - 0 do begin
      if j < MemTableEh1.Fields.Count then begin
        //для таблицы - значение метки и поля
        st := MemTableEh1.Fields[j].FieldName;
        st1 := S.NSt(MemTableEh1.Fields[j].AsString);
      end
      else begin
        //а после конца таблицы по столбцам обработаем fullname
        st := 'fullname';
        st1 := S.NSt(MemTableEh1.FieldByName('prefix').AsString);
        st1 := st1 + S.IIFStr(st1 <> '', '_', '') + S.NSt(MemTableEh1.FieldByName('name').AsString);
      end;
      Rep.ExcelFind('#' + st + '#', x, y, xlValues);
      if x = -1 then
        Continue;
      if st = 'kns' then
        if st1 = '-100' then
          st1 := ''
        else
          for k := 0 to Gh.GetGridColumn(DBGridEh1, 'kns').PickList.Count - 1 do
            if Gh.GetGridColumn(DBGridEh1, 'kns').KeyList[k] = st1 then begin
              st1 := Gh.GetGridColumn(DBGridEh1, 'kns').PickList[k];
              Break;
            end;
      if st = 'thn' then
        if st1 = '-100' then
          st1 := ''
        else
          for k := 0 to Gh.GetGridColumn(DBGridEh1, 'thn').PickList.Count - 1 do
            if Gh.GetGridColumn(DBGridEh1, 'thn').KeyList[k] = st1 then begin
              st1 := Gh.GetGridColumn(DBGridEh1, 'thn').PickList[k];
              Break;
            end;
      if A.InArray(st, ['std', 'nstd', 'sgp', 'resale', 'r1', 'r2', 'r3', 'r4', 'r5', 'r6', 'r7', 'r8', 'r9']) then
        if (st1 = '0') or (st1 = '') then
          st1 := ''
        else
          st1 := 'X';
      if (st = 'comm') then begin
        //фикс для возможности длиной строки комментария
        Rep.SetValueAsText('#comm#', st1);
        Rep.TemplateSheet.Cells[y, x].NumberFormat := '';
      end
      else Rep.SetValue('#' + st + '#', st1);
      if pos(',' + st + ',', ',' + MemTableEh1.FieldByName('chg').AsString + ',') > 0 then
        Rep.TemplateSheet.Cells[y, x].Interior.Color := GetDiffColor; //RGB(255, 170, 170);
      if (st = 'comm') and (MemTableEh1.FieldByName('attention').AsInteger and 1 = 1) then begin
        Rep.TemplateSheet.Cells[y, x].Font.Underline := 2; //xlUnderlineStyleSingle;
        Rep.TemplateSheet.Cells[y, x].Font.FontStyle := 'Bold';
      end;
    end;
  end;
  MemTableEh1.RecNo := RecNo;
  MemTableEh1.EnableControls;
  Rep.PasteBand('FOOTER');
  st1 := mem_Comment.Text;
  Rep.ExcelFind('#comm#', x, y, xlValues);
  //если текст длиный, то SetValue в ыдает ошибку, используем SetValueAsText
  Rep.SetValueAsText('#comm#', st1);
  //но это установит формат ячейки в Тескстовый, а в этом формате, если текст не помещается в ячейку (не важно что настроен перенос по словам),
  //то отображаеются в ячеке решетки ####################
  //для исправлени истуации установим формат General (NumberFormat := '';)
  Rep.TemplateSheet.Cells[y, x].NumberFormat := '';
  if (nedt_Attention.Value = 1) then begin
    Rep.TemplateSheet.Cells[y, x].Font.Underline := 2; //xlUnderlineStyleSingle;
    Rep.TemplateSheet.Cells[y, x].Font.FontStyle := 'Bold';
  end;
  Rep.DeleteCol1;
  if Open then begin
    Rep.Show;
    Rep.Free;
    Result := True;
  end
  else begin
    try
      //ИСпользовать именно .Save, а не .SaveAs !
      Rep.Save(Sys.GetWinTemp + '\' + OrderPath + '.xlsx');
      if not FileExists(Sys.GetWinTemp + '\' + OrderPath + '.xlsx') then
        Exit;
      Result := True;
    except //если finally то некорректно!
    end;
  end;
  SetOrderSaveStatusText('');
end;

procedure TDlg_Order.edt_ComplaintsCloseDropDownForm(EditControl: TControl; Button: TEditButtonEh; Accept: Boolean; DropDownForm: TCustomForm; DynParams: TDynVarsEh);
//закрытие выпадающей формы причин рекламаций
var
  va: TVarDynArray;
  i: Integer;
begin
  inherited;
  //получим из формы список айди рекламаций, которые отмечены
  va := A.ExplodeV(DynParams['ids_ch'].AsString, #1);
  //проставим в третьей колонки признак что тмечена - 1, а иначе нулл
  for i := 0 to High(Complaints) do begin
    Complaints[i][3] := S.IIfV(A.InArray(S.NSt(Complaints[i][0]), va), 1, null);
  end;
  GetComplaintsString;
end;

procedure TDlg_Order.edt_ComplaintsOpenDropDownForm(EditControl: TControl; Button: TEditButtonEh; var DropDownForm: TCustomForm; DynParams: TDynVarsEh);
//открытие выпадающей формы причин рекламаций
//передаем в выпадающую форму рекламаций произвольные параметры
var
  st1, st2, st3: string;
  i: Integer;
begin
  inherited;
  st1 := '';
  st2 := '';
  st3 := '';
  for i := 0 to High(Complaints) do begin
    S.ConcatStP(st1, Complaints[i][1], #1);
    S.ConcatStP(st2, Complaints[i][0], #1);
    if S.NNum(Complaints[i][3]) > 0 then
      S.ConcatStP(st3, Complaints[i][0], #1);
  end;
  //весь список рекламаций
  DynParams['names'].AsString := st1;
  //все айди причин рекламаций (айди справочника рекламаций а не записей к заказу)
  DynParams['ids'].AsString := st2;
  //они же, но только те которые для которых колонка [3] не пустая - т.е. текущие выбранные
  DynParams['ids_ch'].AsString := st3;
  //режим ридонли для формы, при просмотре и удалении заказа
  DynParams['readonly'].AsString := S.IIfV(Mode in [fDelete, fView], '1', '0');
end;

function TDlg_Order.SetTask: Boolean;
//создадим задачу для серверного процесса
//в случае удаления делаем сейчас просто рассылку, не затрагивая диск Z
var
  st, st1, filesadd, filesdelete, TaskDir, Slashes, Addr, Subj, PspName, PspNameOld: string;
  i, j, RecNo: Integer;
begin
  SetOrderSaveStatusText('Передача данных на сервер');
  if IsTemplate then begin
    Result := True;
    Exit;
  end;
  Result := False;
  try
    Slashes := '';
    filesadd := '';
    filesdelete := '';
    if Mode <> fDelete then begin
    //список слешей для создания каталогов, в формате 001, 005...
    //создаем только если колво не 0, не с СГП, и не д/к
      RecNo := MemTableEh1.RecNo;
      for i := 1 to MemTableEh1.RecordCount do begin
        MemTableEh1.RecNo := i;
        if (S.NNum(MemTableEh1.FieldByName('qnt').Value) <> 0) and (S.NNum(MemTableEh1.FieldByName('sgp').Value) <> 1) and (S.NNum(MemTableEh1.FieldByName('resale').Value) <> 1) then
          S.ConcatStP(Slashes, RightStr('0000' + IntToStr(i), 3) + ' ' + S.CorrectFileName(S.IIFStr(MemTableEh1.FieldByName('prefix').AsString <> '', MemTableEh1.FieldByName('prefix').AsString + '_', '') + Trim(MemTableEh1.FieldByName('name').AsString)), #13#10);
      end;
      MemTableEh1.RecNo := RecNo;
    //получим поля файлов для удаления и копирования на сервер
      RecNo := MemTableEh2.RecNo;
      for i := 1 to MemTableEh2.RecordCount do begin
        MemTableEh2.RecNo := i;
        if MemTableEh2.FieldByName('mode').AsString = 'Удален' then
          S.ConcatStP(filesdelete, MemTableEh2.FieldByName('name').AsString, #13#10)
        else if MemTableEh2.FieldByName('mode').AsString <> '' then
          S.ConcatStP(filesadd, MemTableEh2.FieldByName('name').AsString, #13#10);
      end;
      MemTableEh2.RecNo := RecNo;
    end;
    Addr := S.NSt(Q.QSelectOneRow('select addresses from adm_mailing where id = :i$i', [1])[0]);
    if Mode = fDelete then begin
      Subj := 'Удален заказ ' + OrderPath;
      if MyQuestionMessage('Удалить папку заказа на диске со всем содержимым?') = mrYes then
        TaskDir := Tasks.CreateTaskRoot(mytskopDeleteFromArchive, [['directory', OrderPath], ['in_archive', S.NSt(FieldsArr[GetFieldsArrPos('in_archive'), cBegValue])], ['year', YearOf(dedt_Beg.Value)], ['to', Addr], ['subject', Subj], ['body', Subj]], False, False)
      else
        TaskDir := Tasks.CreateTaskRoot(mytskopmail, [['to', Addr], ['subject', Subj], ['body', Subj]], False, False);
    end
    else begin
      if Mode = fEdit then
        Subj := 'Изменен заказ'
      else
        Subj := 'Создан заказ';
      Subj := Orders.GetSubject(Subj, '', ID, null);
      if Mode = fEdit then begin
        st:= S.NSt(Q.QSelectOneRow('select order_prefix from ref_production_areas where id = :id$i', [FieldsArr[GetFieldsArrPos('area'), cBegValue]])[0]);
        PspNameOld:= FieldsArr[GetFieldsArrPos('path'), cBegValue] + '.xlsx';
        Delete(PspNameOld, 1, length(st));
      end
      else PspNameOld:= '';
      st:= S.NSt(Q.QSelectOneRow('select order_prefix from ref_production_areas where id = :id$i', [FieldsArr[GetFieldsArrPos('area'), cNewValue]])[0]);
      PspName:= OrderPath + '.xlsx';
      Delete(PspName, 1, length(st));
//exit;
    //создадим таскдир
      TaskDir := Tasks.CreateTaskRoot(mytskopToPassportChange, [
        ['directory', OrderPath],
        ['old-directory', S.NSt(FieldsArr[GetFieldsArrPos('path')][cBegValue])],
        ['in_archive', S.NSt(FieldsArr[GetFieldsArrPos('in_archive'), cBegValue])],
        ['year', YearOf(dedt_Beg.Value)],
        ['passport', PspName],
        ['old-passport', PspNameOld],
        ['subject', Subj],
        ['to', Addr],
        ['body', DifferencesText],
        ['files-to-send', PspName],
        ['files-to-copy', filesadd],
        ['files-to-delete', filesdelete],
        ['slashes', Slashes]  //    ['', ],
        ],
        False, False
      );
    //скопируем паспорт заказа из временного файла в каталог задачи
      CopyFile(pWideChar(Sys.GetWinTemp + '\' + OrderPath + '.xlsx'), pWideChar(Module.GetPath_Tasks + '\' + TaskDir + '\Files\' + PspName), True);
    //удалим временный файл паспорта
      DeleteFile(Sys.GetWinTemp + '\' + OrderPath + '.xlsx');
    //скопируем в каталог задачи файлы, которые были прикреплены в качестве внешних документов
      for i := 1 to MemTableEh2.RecordCount do begin
        MemTableEh2.RecNo := i;
        if (MemTableEh2.FieldByName('mode').AsString = 'Добавлен') or (MemTableEh2.FieldByName('mode').AsString = 'Обновлен') then
          if FileExists(MemTableEh2.FieldByName('namenew').AsString) then
            CopyFile(pWideChar(MemTableEh2.FieldByName('namenew').AsString), pWideChar(Module.GetPath_Tasks + '\' + TaskDir + '\Files\' + MemTableEh2.FieldByName('name').AsString), True);
      end;
    end;
  //отправим задачу на выполнение
    Tasks.FinalizeTaskDir(Module.GetPath_Tasks + '\' + TaskDir);
    Result := True;
  except
  end;
end;

function TDlg_Order.PathToOrders: string;
begin
  Result := Module.GetPath_Order(IntToStr(YearOf(Cth.GetControlValue(dedt_Beg))), FieldsArr[GetFieldsArrPos('in_archive'), cBegValue]);
end;

procedure TDlg_Order.ViewAddFile;
var
  st: string;
begin
  //просмотр
  if MemTableEh2.RecordCount = 0 then
    Exit;
  //ищем по новому пути файла (он будет задан если файл был добавлен в этот раз), если он пут то ищем в папке заказа
  st := MemTableEh2.FieldByName('namenew').AsString;
  if st = '' then
    st := PathToOrders + '\' + FieldsArr[GetFieldsArrPos('path')][cBegValue] + '\Внешние документы\' + MemTableEh2.FieldByName('name').AsString;
  Sys.OpenFileOrDirectory(ExtractFilePath(st), 'Файл не найден!', ExtractFileName(st));
end;

procedure TDlg_Order.Pm_FilesClick(Sender: TObject);
//обработка кликов контекстного меню грида внешних документов
//просмотреть - добавить - удалить файл
var
  tag: Integer;
  st: string;
  i, j, RecNo: Integer;
begin
  tag := TMenuItem(Sender).tag;
  if Tag = mbtView then begin
    ViewAddFile;
  end
  else if Tag = mbtDelete then begin
    //удаление
    if MemTableEh2.RecordCount = 0 then
      Exit;
    //если файл уже на сервере, то спросим, и пометим как удаленный
    if MemTableEh2.FieldByName('onserver').AsInteger = 1 then begin
      if MyQuestionMessage('Удалить этот файл?') <> mrYes then
        Exit;
      MemTableEh2.Edit;
      MemTableEh2.FieldByName('mode').Value := 'Удален';
      MemTableEh2.Post;
    end    //если файл еще не на сервере, то просто удалим строку
    else begin
      MemTableEh2.Edit;
      MemTableEh2.Delete;
      Mth.Post(MemTableEh2);
    end;
  end
  else if Tag = mbtAdd then begin
    //добавление файла
    //диалог выбора, можно несколько
    OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist];
    OpenDialog1.Filter := '';
    //вышли по отмене в диалге
    if not OpenDialog1.Execute then
      Exit;
    RecNo := MemTableEh2.RecNo;
    //пройдем по выбранным файлам
    for i := 0 to OpenDialog1.Files.Count - 1 do begin
      //пройдем по строкам грида
      j := 1;  //если MemTableEh2.RecordCount=0 то не будет инициирющего присваивания в цикле j:= 1 !!!
      for j := 1 to MemTableEh2.RecordCount do begin
        MemTableEh2.RecNo := j;
        if MemTableEh2.FieldByName('name').AsString = ExtractFileName(OpenDialog1.Files[i]) then begin
          //если найден в гриде по имени только файла
          MemTableEh2.Edit;
          MemTableEh2.FieldByName('namenew').AsString := OpenDialog1.Files[i];
          //если был на сервере то проставим что обновлен
          //а если не был и был добавлен ранее, то останется Добавлен, но будет заменен полный путь
          if MemTableEh2.FieldByName('onserver').AsInteger = 1 then
            MemTableEh2.FieldByName('mode').AsString := 'Обновлен';
          MemTableEh2.Post;
          Break;
        end;
      end;
      if j > MemTableEh2.RecordCount then begin
        //не найден по короткому имени файла в гриде - добавим
        MemTableEh2.Append;
        MemTableEh2.FieldByName('name').AsString := ExtractFileName(OpenDialog1.Files[i]);
        MemTableEh2.FieldByName('namenew').AsString := OpenDialog1.Files[i];
        MemTableEh2.FieldByName('mode').AsString := 'Добавлен';
        MemTableEh2.Post;
      end;
    end;
    MemTableEh2.RecNo := RecNo;
  end;
end;

procedure TDlg_Order.DBGridEh2DblClick(Sender: TObject);
//даблклик в таблице внешних документов - откроем файл
begin
  inherited;
  ViewAddFile;
end;

procedure TDlg_Order.DBGridEh2GetCellParams(Sender: TObject; Column: TColumnEh; AFont: TFont; var Background: TColor; State: TGridDrawState);
//раскрасим столбец грида внешних документов в зависимости от статуса файла
begin
  inherited;
  if Column.FieldName <> 'mode' then
    Exit;
  if Column.Field.Value = 'Удален' then
    AFont.Color := RGB(255, 0, 0);
  if Column.Field.Value = 'Обновлен' then
    AFont.Color := RGB(0, 0, 255);
  if Column.Field.Value = 'Добавлен' then
    AFont.Color := RGB(0, 155, 0);
end;

function TDlg_Order.IsAddFilesChanged: Boolean;
//вернем статус, были ли изменения в дополнительных файлах
var
  i, j, RecNo: Integer;
begin
  Result := False;
  MemTableEh2.DisableControls;
  RecNo := MemTableEh2.RecNo;
  for i := 1 to MemTableEh2.RecordCount do begin
    MemTableEh2.RecNo := i;
    if (MemTableEh2.FieldByName('mode').AsString <> '') then
      Result := True;
  end;
  MemTableEh2.RecNo := RecNo;
  MemTableEh2.EnableControls;
end;

procedure TDlg_Order.GetAddFiles;
//строим грид внешних документов, и здесь же загрузим файлы из ВД, которые есть в папке заказа
var
  st, st1, TaskDir: string;
  i, j, k, l: Integer;
  sa, sa1: TStringDynArray;
  dir: string;
begin
  if DBGridEh2.Columns.Count = 1 then begin
    Gh.SetGridOptionsDefault(DBGridEh2);
    MemTableEh2.FieldDefs.Clear;
    MemTableEh2.Close;
    Mth.AddTableColumn(DBGridEh2, 'name', ftString, 400, 'Файл', 400, True);    //имя файла без каталога
    Mth.AddTableColumn(DBGridEh2, 'namenew', ftString, 400, 'Новый', 400, False);    //полное имя, только для загруженныых в этот раз через открытие диалога
    Mth.AddTableColumn(DBGridEh2, 'mode', ftString, 20, '*', 60, True);              //текст статуса - добавлен, обновлен, удален
    Mth.AddTableColumn(DBGridEh2, 'onserver', ftInteger, 0, 'S', 30, False);         //файл находится в каталоге на сервере
    MemTableEh2.CreateDataSet;
  end;
  MemTableEh2.ReadOnly := False;
  DBGridEh2.OptionsEh := DBGridEh2.OptionsEh - [dghColumnMove];
  DBGridEh2.OptionsEh := DBGridEh2.OptionsEh - [dghColumnResize];
  DBGridEh2.AllowedOperations := []; //[alopInsertEh,alopUpdateEh,alopDeleteEh,alopAppendEh];
  DBGridEh2.EmptyDataInfo.Active := False;
  DBGridEh2.ReadOnly := True;
  DBGridEh2.Options := DBGridEh2.Options - [dgTitles];
  if IsTemplate then
    Exit;
  Cth.CreateGridMenu(Self, Pm_Files, [mybtView, mybtDividor, mybtAdd, mybtDelete], [True, True, not (Mode in [fView, fDelete]), not (Mode in [fView, fDelete])], Pm_filesClick);
  DBGridEh2.PopupMenu := Pm_Files;
  if not (Mode in [fEdit, fDelete, fView]) then
    Exit;
  dir := FieldsArr[GetFieldsArrPos('path')][cBegValue];
  dir := PathToOrders + '\' + dir + '\Внешние документы';
  if not DirectoryExists(dir) then
    Exit;
  sa := TDirectory.GetFiles(dir, '*.*', TSearchOption.soTopDirectoryOnly);
  MemTableEh2.DisableControls;
  for i := 0 to High(sa) do begin
    //Mth.PostAndEdit(MemTableEh2);
    MemTableEh2.Append;
    MemTableEh2.FieldByName('name').Value := ExtractFileName(sa[i]);
    MemTableEh2.FieldByName('onserver').Value := 1;
    MemTableEh2.Post;
  end;
  MemTableEh2.First;
  MemTableEh2.EnableControls;
end;

procedure TDlg_Order.LoadKBLog;
begin
  Dlg_LoadKBLog.ShowDialog(LoadKBLogArr);
end;

procedure TDlg_Order.Pmi_Format_LoadKBClick(Sender: TObject);
begin
  inherited;
  LoadKB;
end;

procedure TDlg_Order.SetAddTasksMenu;
begin
  if cmb_Format.Text = 'КБ' then
    Pm_Format.AutoPopup := True
  else
    Pm_Format.AutoPopup := False;
end;

procedure TDlg_Order.Pmi_Format_LoadKBLogClick(Sender: TObject);
begin
  inherited;
  LoadKBLog;
end;

procedure TDlg_Order.Pmi_RecalcPricesClick(Sender: TObject);
//пересчитаем цены для всех стандарных изделий
var
  i, j, RecNo, ChCnt: Integer;
  s1, s2: string;
  b: Boolean;
begin
  if (Mode in [fView, fDelete]) then
    Exit;
  if MyQuestionMessage('Обновить цены для стандартных изделий?') <> mrYes then
    Exit;
  ChCnt := 0;
  MemTableEh1.DisableControls;
  RecNo := MemTableEh1.RecNo;
  for i := 1 to MemTableEh1.RecordCount do begin
    MemTableEh1.RecNo := i;
    for j := 0 to High(StdItems) do
      if MemTableEh1.FieldByName('name').AsString = StdItems[j][1] then
        Break;
    if j > High(StdItems) then
      Continue;
    b := False;
    if MemTableEh1.FieldByName('price').Value <> StdItems[j][2 + 9 + 1 + 1] then begin
      MemTableEh1.FieldByName('price').Value := StdItems[j][2 + 9 + 1 + 1];
      b := True;
    end;
    if MemTableEh1.FieldByName('price_pp').Value <> StdItems[j][2 + 9 + 1 + 2] then begin
      MemTableEh1.FieldByName('price_pp').Value := StdItems[j][2 + 9 + 1 + 2];
      b := True;
    end;
    Mth.PostAndEdit(MemTableEh1);
    if b then
      inc(ChCnt);
    //проставим, какое поле было изменено, процедура проверит изменения по всем полям записи
    if b then
      SetTableChanges('');
    CalculateTableRow;
  end;
  MemTableEh1.RecNo := RecNo;
  MemTableEh1.EnableControls;
  SetSumInHeader;
  MyInfoMessage(S.IIFStr(ChCnt = 0, 'Цены не изменились.', 'Цены пересчитаны по ' + IntToStr(ChCnt) + ' позици' + S.GetEnding(ChCnt, 'и', 'ям', 'ям') + '.'));
end;

procedure TDlg_Order.LoadKB;
//формирования заказа по КБ по присланному заказчиком файлу стандартного формата
//выбирается файл, проверяется формат
//изделиям, которые есть в присланном файле и найдены в шаблоне паспорта, присвиваетя количество из файла,
//количество не обязательно число, приходится парсить
var
  i, j, k, CntI, err, rn, i1, i2: Integer;
  ar1: TVarDynArray2;
  va2: TVarDynArray2;
  va, va1: TVarDynArray;
  b: Boolean;
  st, st1, Addr: string;
  q, q1, d: Variant;
  n, n2, FileName: string;
  e: extended;
const
  rBeg = 17;
begin
  //диалог выбора, можно несколько
//  FileName:='r:\kb1.xlsx';
  OpenDialog1.Options := [ofFileMustExist];
  OpenDialog1.Filter := 'Файлы Excel|*.xls; *.xlsx; *.xlsm';
  //вышли по отмене в диалге
  if not OpenDialog1.Execute then
    Exit;
  FileName := OpenDialog1.Files[0];
  //загружаем массив из хлс-файла, не более 2000 строк
  if not (myxlsLoadSheetToArray(FileName, 0, 0, 0, 0, 0, 2000, 12, ar1)) then begin
    MyWarningMessage('Не удалось открыть файл!');
    Exit;
  end;
  if not (((Trim(ar1[7][0]) = 'ЗАКАЗ НА ПОСТАВКУ') or (Trim(ar1[7][0]) = 'ЗАКАЗ НА ПОСТАВКУ И МОНТАЖ')) and (Trim(ar1[13][0]) = 'СПЕЦИФИКАЦИЯ НА ПОСТАВКУ')) then begin
    MyWarningMessage('Выбранный файл не является заказом КБ!');
    Exit;
  end;
  //адрес отгрузки
  Addr := Trim(S.NSt(ar1[10, 1]) + ', ' + S.NSt(ar1[10, 3]));
  //найдем количество элеменотов с документе, проверяем пока в первом столбце не пусто
  for i := rBeg to High(ar1) do begin
    if S.NSt(ar1[i][0]) = '' then
      Break;
  end;
  CntI := i - rBeg;
  if MyQuestionMessage('Сформировать заказ для'#13#10 + Addr + #13#10'из ' + IntToStr(CntI) + ' позиций?') <> mrYes then begin
    MyWarningMessage('Формирование заказа отменено!');
    Exit;
  end;
  LoadKBLogArr := [];
  edt_Address.Text := Addr;
  MemTableEh1.DisableControls;
  //проход по массиву документа
  for i := rBeg to rBeg + CntI - 1 do begin
    q := ar1[i, 7];              //количество
    d := ar1[i, 6];              //ед.изм.
    n := Trim(S.NSt(ar1[i, 1]));   //наименование
    va2 := [];                   //массив даннх для вставки из него в паспорт
    if n = '' then begin
      LoadKBLogArr := LoadKBLogArr + [[n, d, q, 'наименование КБ пустое']];
      Continue;
    end;
    //пробуем перевести количество в число, не разлиая . и ,
    b := S.StrToNumberCommaDot(q, 0, 999999, e);
    if b then begin
      //эту строку в паспорт если число (число уже незавитсимо, быля ли зпт или тчк)
//      va2 := [[n, q, d]];
      va2 := [[n, e, d]];
    end
    else begin
      //не число - парсим строку вида:
      //    48,6 (Ш 1,8хВ 2,7) 10 листов  48,6 (Ш 2,8х1,7) 10 листов
      //где группа в скобках может быть одна, может несколько, разделенных как пробелами так и переносом строк
      //надо взять текст в скобках, привести его к стандарту:
      //убираем все символы кроме точек, запятых, числел и х *, приводим запятые к точке, получим типа, звездочку к х русская (3.6х5.0), и это пойдет к наименованию через пробел
      //далее пытаемся выделить количество из числа после закрывающей скобки, оно может быть только целым (но может его не быть)
      //если несколько групп в скобках, то по одной позиции документа может искатьсяв паспорте несколько наименований
      va2 := [];
      q := S.NSt(q);
      i1 := Pos('(', q);
      i2 := Pos(')', q);
      //есть группа скобок
      b := not ((i1 = 0) or (i2 <= i1));
      if b then begin
        //разобьем по группам
        va := A.ExplodeV(q, '(');
        for j := 1 to High(va) do begin
          //цикл по группам
          st := S.NSt(va[j]);
          i1 := pos(')', st);
          st1 := '';
          //удалим недопустимые символы в тексте между скобками
          for k := 1 to i1 - 1 do
            if A.InArray(Copy(st, k, 1), ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.', ',', '-', 'x', 'X', 'х', 'Х', '*', 'х']) then
              st1 := st1 + Copy(st, k, 1);
          //заменим раздеитель в размерах на русскую х
          for k := 1 to length(st1) do
            if A.InArray(Copy(st1, k, 1), ['-', 'x', 'X', 'х', 'Х', '*', 'х']) then
              st1[k] := 'х'; //русский
          //и запятую на точку
          for k := 1 to length(st1) do
            if st1[k] in [','] then
              st1[k] := '.';
          n2 := n + ' (' + st1 + ')';
          //выделяем цифру после скобок для внесения в паспорт в качестве количества
          st1 := '';
          for k := i1 + 1 to Length(st) do
            if st[k] <> ' ' then
              Break;
          while st[k] in ['0'..'9'] do begin
            st1 := st1 + st[k];
            inc(k);
          end;
          q1 := st1;
          if st1 = '' then
            LoadKBLogArr := LoadKBLogArr + [[n2, d, q, 'не удалось задать количество']]
          else
            va2 := va2 + [[n2, q1, d]];
        end;
      end
      else
        LoadKBLogArr := LoadKBLogArr + [[n, d, q, 'не удалось задать количество']];
    end;
    for j := 0 to High(va2) do begin
      rn := MemTableEh1.RecNo;
      for k := 1 to MemTableEh1.RecordCount do begin
        MemTableEh1.RecNo := k;
        if MemTableEh1.FieldByName('name').Value = va2[j][0] then
          Break;
      end;
      if k <= MemTableEh1.RecordCount then begin
        //нашли наименование - внесем в таблицу количество
        MemTableEh1.Edit;
        MemTableEh1.FieldByName('qnt').AsFloat := va2[j][1];
        //отметим изменения
        SetTableChanges('qnt');
        //посчитаем сумму
        CalculateTableRow;
        Mth.PostAndEdit(MemTableEh1);
      end
      else begin
        LoadKBLogArr := LoadKBLogArr + [[va2[j][0], va2[j][2], va2[j][1], 'не найдено наименование']];
      end;
    end;
  end;
  MemTableEh1.EnableControls;
  //итоговую сумму в шапке
  SetSumInHeader;
  if Length(LoadKBLogArr) = 0 then
    LoadKBLogArr := [[#1]];  //признак, что загржено без ошибок
  Dlg_LoadKBLog.ShowDialog(LoadKBLogArr);
end;

procedure TDlg_Order.SetOrderSaveStatusText(Text: string);
//показываем внизу формы статус сохранения заказа
begin
  Application.ProcessMessages;
{  lbl_OrderSaveStatus.Caption:='....';
  Sleep(5000);
  Application.ProcessMessages;}
  lbl_OrderSaveStatus.Caption := Text;
  Application.ProcessMessages;
end;

procedure TDlg_Order.HideEmptyItems;
//скроем пустые позиции в заказе при просмотре
begin
  DBGridEh1.STFilter.local := True;
  DBGridEh1.STFilter.InstantApply := False;     //не понял пока за что ттвечает
  Gh.GetGridColumn(DBGridEh1, 'qnt').STFilter.ExpressionStr := S.IIfV(chb_ViewEmptyItems.Checked, '', '<>0');
  DBGridEh1.DefaultApplyFilter;
end;

function TDlg_Order.VerifyItm: Boolean;
var
  v: Variant;
  st: string;
  ar2: TVarDynArray2;
begin
  Result := False;
  st := '';
  //так почему-то странная ошибка not BCD value
  //v:=QSelectOneRow('select id_group from dv.groups where groupname = :name$s', Group_NomFromCAD_Name)[0];
  ar2 := q.QLoadToVarDynArray2('select id_group from dv.groups where groupname = :name$s', [Group_NomFromCAD_Name]);
  if ar2[0, 0] = null then
    st := 'Группа ' + Group_NomFromCAD_Name + ' в ИТМ не найдена.'
  else if ar2[0, 0] <> Group_NomFromCAD_Id then
    st := 'Группа ' + Group_NomFromCAD_Name + ' в ИТМ имеет неправильный ID.';
  if st <> '' then begin
    MyWarningMessage(st + #13#10'Проведение заказов невозможно!');
    Exit;
  end;
  Result := True;
end;

procedure TDlg_Order.DBGridEh1Columns0GetCellParams(Sender: TObject; EditMode: Boolean; Params: TColCellParamsEh);
var
  i: Integer;
  IsDK: Boolean;
begin
  inherited;
  Params.ImageIndex := -1;
//  Params.
{  for i:= 0 to High(StdItems) do
    if MemTableEh1.FieldByName('name').AsString = StdItems[i][1] then Break;
  IsDk:=(i <= High(StdItems))and(StdItems[i][12] = 1);
  //if IsDk then Params.Font.Color:=RGB(0,0,255);
//  if StdItems[i][12] = 1 then Params.ImageIndex:=1;
  if IsDk then Params.ImageIndex:=1 else Params.ImageIndex:=2;
  Params.ImageIndex:=-1;

//}
end;



{==============================================================================}
function TDlg_Order.GetOrderTypeOldValue: Variant;
//вернем результат типа заказа в старом формате
//(если для типа признак Рекламация, то "2", иначе "1")
var
  i: Integer;
begin
  Result := Cth.GetControlValue(cmb_OrderType);
  if (FNewOrderType = 0) or (Result.AsString = '') then
    Exit;
  for i := 0 to High(FOrderTypes) do
    if (FOrderTypes[i][0].AsString = Result.AsString) and (FOrderTypes[i][2] = 1) then begin
      Result := '2';
      Exit;
    end;
  Result := '1';
end;


end.





(*


//присваивание слешей при редактировании или переходе вниз так:
//таблица при этом может расти бесконечно
procedure TDlg_Order.MemTableEh1AfterEdit(DataSet: TDataSet);
begin
  inherited;
  MemTableEh1.FieldByName('slash').Value:=GetItemNum(MemTableEh1.RecNo);
end;

procedure TDlg_Order.MemTableEh1AfterScroll(DataSet: TDataSet);
begin
  inherited;
  Mth.Post(MemTableEh1);
  MemTableEh1.Edit;
end;

*)
