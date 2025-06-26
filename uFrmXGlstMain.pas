unit uFrmXGlstMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh
  ;

type
  TFrmXGlstMain = class(TFrmBasicGrid2)
  private
    {обработчики событий, определенные в данном классе. в потомках должны бьть расположены в этой же секции}
    //в этом событии в основном раскрашиваем текст и фон ячеек; в потомках обязательно вызывает inherited
    procedure Frg1DbGridEh1GetCellParams(Sender: TObject; Column: TColumnEh; AFont: TFont; var Background: TColor; State: TGridDrawState); override;
    procedure Frg2DbGridEh1GetCellParams(Sender: TObject; Column: TColumnEh; AFont: TFont; var Background: TColor; State: TGridDrawState); override;
    procedure Timer_AfterStartTimer(Sender: TObject);
    procedure DbGridEh1Columns0AdvDrawDataCell(Sender: TCustomDBGridEh; Cell, AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean);
  private
  protected
    //основная функция формы
    function  PrepareForm: Boolean; override;

    //события первого (основного) фрейма грида
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    function  Frg1OnFilterExecute(var Fr: TFrDBGridEh; const No: Integer; var Handled: Boolean): string; override;
    //здесь устанавливаем переменную where-часть запроса и инициализируем параметры в запросе
    //(вызывается дважды, первый раз для конструирования запроса, затем утанавливает параметры в уже готьовом запросе, потому их установку делать с флагом пропуска
    procedure Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    //здесь мождем устанавливать параметры ячейки (номер картинки, readonly) в зависимости от данных в текущей записи
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    //двойной клик в таблице
    //по умолчанию вызывает редактирование или просмотр записи
    procedure Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); override;
    procedure Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string); override;
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;


    //события второго (в rorowDetailPanel) фрейма грида
    procedure Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg2CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg2SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    function  Frg2OnFilterExecute(var Fr: TFrDBGridEh; const No: Integer; var Handled: Boolean): string; override;
    //здесь устанавливаем переменную where-часть запроса и инициализируем параметры в запросе
    //(вызывается дважды, первый раз для конструирования запроса, затем утанавливает параметры в уже готьовом запросе, потому их установку делать с флагом пропуска
    procedure Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure Frg2ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure Frg2AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    //здесь мождем устанавливать параметры ячейки (номер картинки, readonly) в зависимости от данных в текущей записи
    procedure Frg2ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    //двойной клик в таблице
    //по умолчанию вызывает редактирование или просмотр записи
    procedure Frg2OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg2GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); override;
    procedure Frg2VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string); override;
    procedure Frg2CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;
  end;

var
  FrmXGlstMain: TFrmXGlstMain;

implementation

uses
  uFrmMain,
  uSys,
  uTasks,
  uErrors,
  uFrmBasicInput,
  uPrintReport,
  uLabelColors2,
  uWindows,
  uOrders,
  uTurv,

  D_Sn_Calendar,
  D_ExpenseItems,
  D_SnOrder,
  D_Order,
  D_OrderPrintLabels,
  D_R_EstimateReplace,
  D_J_Error_Log,
  D_Spl_InfoGrid,
  //~D_CreatePayroll,

  uFrmOGedtSnMain,
  uFrmDlgRItmSupplier,
  uFrmODedtNomenclFiles,
  uFrmOWPlannedOrder,
  uFrmXWGridAdminOptions,
  uFrmOGinfSgp
  ;


{$R *.dfm}


function TFrmXGlstMain.PrepareForm: Boolean;
var
  p: TPanel;
  i, j: Integer;
  st, st1, st2: string;
  v: Variant;
  va, va1: TVarDynArray;
  va2: TVarDynArray2;
  b, b0, b1, b2, b3 : Boolean;
begin
{
ширина:
дата без времени 70-80
галка 40
сумма до 10млрд с коп. - 100
}
  Result := False;
//  Q.QSelectOneRow('select count(*) as s from dual',[]);
//  Q.QExecSql('selet 1 from', [], False);

  if FormDoc = myfrm_R_Test then begin
    Caption:='Типовые проекты';
    Frg1.Options := Frg1.Options + [myogIndicatorCheckBoxes, myogMultiSelect, myogGridLabels, myogRowDetailPanel];
    Frg1.Opt.SetFields([
      ['id$i','id'],
      ['name$s as name','Наименование проекта','300','bt=кнопка 1::l;кнопка 2:ud:l:h'],
      ['active','Используется','120', true, 'chb']]);
    Frg1.Opt.SetTable('ref_test2');
    Frg1.Opt.SetWhere('where active = :active$i or active = 1');
    //Frg1.Opt.S(gotColPictures, [['active']]);
//    Frg1.Opt.S(gotColEditable, [['active']]);
    Frg1.Opt.SetGridOperations('ua');
    Frg1.Opt.SetColFeature('active', 'e', Cth.GetControlValue(Frg1, 'Chb1') = 1, True);
//    Frg1.Opt.SetButtons(1,'rveasp');
    Frg1.Opt.SetButtons(1,'+p', False);
//    Frg1.Opt.SetButtons(1,
//      [[btnRefresh], [btnDividor], [btnView], [btnEdit], [btnAdd], [btnCopy], [btnDelete], [btnDividor], [btnCtlPanel], [btnDividor], [btnGridSettings]{, [btnCtlPanel, True, 140]}]);
//    P:=TPanel.Create(Frg1);P.Name := 'PTopBtnsCtl1'; P.Width := 140; P.Height := 32;
    Frg1.CreateAddControls('1', cntCheck, 'Задать использование', 'Chb1', '', 4, yrefT, 200);
    Frg1.CreateAddControls('1', cntCheck, 'Показать неиспользуемые', 'Chb2', '', 4, yrefB, 200);
    Frg1.CreateAddControls('1', cntCheck, 'yyyyyy', 'Chb4', '', 210+40, yreft, 60);
    Frg1.CreateAddControls('1', cntEdit, 'Текст', 'Chb3', '', 210+40, yrefB, 60);
//    Frg1.Opt.SetPanelsSaved(['PTopBtnsCtl1']);
    Frg1.ReadControlValues;
    Frg1.InfoArray:=[
      [Caption + '.'#13#10]
    ];

//i:=i div i;

   // Frg1.DbGridEh1.RowDetailPanel.Active := True;
   // Frg1.Options := Frg1.Options + [myogRowDetailPanel];
    Frg2.Opt.SetFields([
      ['id$i','id'],
      ['name$s','Наименование проекта','300','bt=кнопка 1;кнопка 2','null'],
      ['active','Используется','120', true, 'chb']
    ]);
    Frg2.Opt.SetWhere('where id > :id$i');
    Frg2.Opt.SetTable('ref_test2');
    Frg2.DbGridEh1.RowDetailPanel.Active := False;
  end

  {АДМИНИСТРИРОВАНИЕ}

  else if FormDoc = myfrm_Adm_Db_Log then begin
    Caption:='Лог событий в БД';
    Frg1.Options := Frg1.Options + [myogGridLabels];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['dt','Время события','150'],
      ['itemname','Действие','250'],
      ['comm','Комментарий','250']
    ]);
    Frg1.Opt.SetTable('adm_db_log');
    Frg1.Opt.FilterRules := [[], ['dt']];
    Frg1.Opt.SetButtons(1, 'rfs');
  end
  else if FormDoc = myfrm_J_Error_Log then begin
    Caption:='Лог ошибок';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['dt','Время события','150','bt=Подробности'],
      ['modulename','Модуль','120'],
      ['userloginandname','Пользователь','150'],
      ['message','Сообщение об ошибке','300'],
      ['sql','SQL-запрос','200']
    ]);
    Frg1.Opt.SetTable('v_adm_error_log');
    Frg1.Opt.SetWhere('where userlogin like :userlogin$s and ide <= :ide$i /*ANDWHERE*/');
    Frg1.Opt.FilterRules := [[], ['dt']];
    Frg1.Opt.SetButtons(1, 'rvdfsp', User.IsDeveloper);
    Frg1.CreateAddControls('1', cntCheck, 'Только свои записи', 'ChbMy', '', 50, yrefC, 150);
    Frg1.CreateAddControls('1', cntCheck, 'Показывать отладочные', 'ChbDebug', '', -1, yrefC, 150);
  end
  else if FormDoc = myfrm_R_Organizations then begin
    Caption:='Справочник своих организаций';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name','Наименование','200'],
      ['requisites','Реквизиты','200'],
      ['active','Используется','80','pic']
    ]);
    Frg1.Opt.SetTable('ref_sn_organizations');
    Frg1.Opt.SetButtons(1, 'readsp');
  end
  else if FormDoc = myfrm_R_Locations then begin
    Caption:='Справочник своих адресов';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name','Адрес','300'],
      ['active','Используется','80','pic']
    ]);
    Frg1.Opt.SetTable('ref_sn_locations');
    Frg1.Opt.SetButtons(1, 'readsp');
  end
  else if FormDoc = myfrm_R_CarTypes then begin
    Caption:='Справочник видов транспортных средств';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name','Наименование','300'],
      ['active','Используется','80','pic']
    ]);
    Frg1.Opt.SetTable('ref_sn_cartypes');
    Frg1.Opt.SetButtons(1, 'readsp');
  end



  {ПЛАТЕЖНЫЙ КАЛЕНДАРЬ}

   //платежный календарь - счета
  else if FormDoc = myfrm_J_Accounts then begin

    Caption:='Счета';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id'],
      ['filename$i','_File','40'],
      ['useragreed$s','_Согласовывает','40'],
      ['agreed2dt$d','_Согласовано директором, дата','80'],
      ['anyinstr(useravail,'+IntToStr(User.GetId)+') as useravail$s','_EditableForUser','80'],
      ['to_char(id_whoagreed1) as id_whoagreed1$s','_id_whoagreed1','40'],
      ['username$s','Менеджер','100'],
      ['organization$s','Плательщик','100'],
      ['expenseitem$s','Статья расходов','120'],
      ['supplier$s','Получатель','120'],
      ['account$s','Счет','120','bt=Показать счет:;Показать заявку:'],
      ['accountdt$d','Дата счета','80'],
      ['acctype$s','Форма оплаты','80'],
      ['dt$d','Дата регистрации','80'],
      ['regdays$f','Время регистрации','80'],
      ['accsum$f','Сумма по счету','80','f=r:'],
      ['paidsum$f','Оплачено','80','f=r:'],
      ['debt$f','Задолженность','80','f=r:'],
      ['comm$s','Примечание','150;w'],
      ['paimentstatus$s','Статус оплаты',''],
      ['agreed1$i','Согласовано','80','chb=+','e',User.Roles([], [rPC_A_AgrSelfCat])],
      ['agreed2$i','Директор','80','chb=+','e',User.Roles([], [rPC_A_AgrDir])],
      ['receiptdt$d','Оприходован','80',S.IIFStr(User.Role(rPC_A_Receipt),'bt=Дата оприходования')],
      ['receiptdays$i','Оприходован, дней','80']
    ]);
    Frg1.Opt.SetTable('v_sn_calendar_accounts');
    Frg1.Opt.FilterRules := [[], ['accountdt;dt']];
    b0:=User.Role(rPC_A_ChAll)  //право доступа на добавление и копирование
      or (User.Roles([],[rPC_A_ChSelf, rPC_A_ChSelfCat]) and
      (Q.QSelectOneRow('select count(id) from ref_expenseitems where anyinstr(useravail, :id_user$i)=1 and accounttype = :accmode$i', [User.GetId, 0])[0] > 0));
    b1:=User.Role(rPC_A_ChAll)  //транспорт отгрузки
      or (User.Roles([],[rPC_A_ChSelf, rPC_A_ChSelfCat]) and
      (Q.QSelectOneRow('select count(id) from ref_expenseitems where anyinstr(useravail, :id_user$i)=1 and accounttype = :accmode$i', [User.GetId, 1])[0] > 0));
    b2:=User.Role(rPC_A_ChAll)  //снабжения
      or (User.Roles([],[rPC_A_ChSelf, rPC_A_ChSelfCat]) and
      (Q.QSelectOneRow('select count(id) from ref_expenseitems where anyinstr(useravail, :id_user$i)=1 and accounttype = :accmode$i', [User.GetId, 2])[0] > 0));
    b3:=User.Role(rPC_A_ChAll)  //монтаж
      or (User.Roles([],[rPC_A_ChSelf, rPC_A_ChSelfCat]) and
      (Q.QSelectOneRow('select count(id) from ref_expenseitems where anyinstr(useravail, :id_user$i)=1 and accounttype = :accmode$i', [User.GetId, 3])[0] > 0));
    Frg1.Opt.SetButtons(1,[[btnRefresh],[], [btnView], [btnEdit,User.Roles([],[rPC_A_ChAll, rPC_A_ChSelf, rPC_A_ChSelfCat])], [btnAdd, b0],
      [btnAdd_Account_TO,b1], [btnAdd_Account_TS,b2], [btnAdd_Account_M,b3], [btnCopy,b0], [btnDelete,1], [], [-btnCustom_AccountToClipboard], [], [btnGridFilter], [], [btnGridSettings]]);
    Frg1.Opt.SetButtonsIfEmpty([btnAdd_Account_TO, btnAdd_Account_TS, btnAdd_Account_M]);
  end
  //платежный календарь - платежи
  else if FormDoc = myfrm_J_Payments then begin
    Caption:='Платежи';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['to_char(pid) as pid$i','_id','40'],
      ['id as aid$i','_aid','40'],
      ['filename$s','_Файл','40'],
      ['anyinstr(useravail,'+IntToStr(User.GetId)+') as useravail$i','_EditableForUser','40'],
      ['agreed2auto$i','_ag2a','25'],
      ['username$s','Менеджер','120'],
      ['organization$s','Плательщик','120'],
      ['expenseitem$s','Статья расходов','120'],
      ['supplier$s','Получатель','150'],
      ['account$s','Счет','100','bt=Показать счет;Показать заявку'],
      ['accountdt$d','Дата счета','80'],
      ['dt$d','Дата регистрации счета','80'],
      ['acctype$s','Форма оплаты','80'],
      ['accsum$f','Сумма по счету','80','f=r:'],
      ['pdtpaid$d','Дата проведения','80'],
      ['comm$s','Примечание','150'],
      ['agreed1$i','Согласовано','60','pic'],
      ['agreed2$i','Директор','60','pic'],
      ['pdt$d','Дата платежа','80'],
      ['psum$f','Сумма платежа','80','f=r:'],
      ['pstatus$i','Платеж проведен','60','chb=+','e',User.Role(rPC_P_Payment)]
    ]);
    Frg1.Opt.SetTable('v_sn_calendar_payments');
    Frg1.Opt.FilterRules := [[], ['accountdt;dt;pdt']];
    Frg1.Opt.SetButtons(1, 'rveacds', User.Role(rPC_R_GrExp_Ch));
    Frg1.Opt.SetButtons(1,[[btnRefresh],[], [btnView], [btnEdit,User.Roles([],[rPC_A_ChSelfCat, rPC_A_ChAll])], [btnAdd, 1],
      [btnCopy,1], [btnDelete,1], [], [-btnCustom_AccountToClipboard],[],[-btnCustom_RunPayments],[],[btnGridFilter], [], [btnGridSettings]]);
    Frg1.Opt.SetButtonsIfEmpty([btnAdd_Account_TO, btnAdd_Account_TS, btnAdd_Account_M]);
  end
  //платежный календарь - группы статей расходов
  else if FormDoc = myfrm_R_GrExpenseItems then begin
    Caption:='Группы статей расходов';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name$s','Наименование','300']
    ]);
    Frg1.Opt.SetTable('ref_grexpenseitems');
    Frg1.Opt.SetButtons(1, 'rveacds', User.Role(rPC_R_GrExp_Ch));
  end
   //платежный календарь - статьи расходов
  else if FormDoc = myfrm_R_ExpenseItems then begin
    Caption:='Статьи расходов';
    Frg1.Opt.SetFields([
      ['id$i','_id'],
      ['name$s','Наименование','200'],
      ['groupname$s','Группа','150'],
      ['usernames$s','Доступ','300'],
      ['agreednames$s','Согласование','200'],
      ['active$i','Используется','60','pic']
    ]);
    Frg1.Opt.SetTable('v_ref_expenseitems');
    Frg1.Opt.SetButtons(1, 'rveacds', User.Role(rPC_R_Exp_Change));
  end
  //платежный календарь - поставщики
  else if FormDoc = myfrm_R_Suppliers then begin
    Caption:='Справочник поставщиков';
    Frg1.Opt.SetFields([
      ['id$i','_id'],
      ['legalname$s','Наименование','300'],
      ['active$i','Используется','60','pic']
    ]);
    Frg1.Opt.SetTable('ref_suppliers');
    Frg1.Opt.SetButtons(1, 'rveacds', User.Role(rPC_R_Sp_Change));
  end
  //платежный календарь - поставщики - выбор из списка
  else if FormDoc = myfrm_R_Suppliers_SELCH then begin
    Caption:='Справочник поставщиков';
    Frg1.Opt.SetFields([
      ['id$i','_id'],
      ['legalname$s','Наименование','300'],
      ['active$i','Используется','60','pic']
    ]);
    Frg1.Opt.SetTable('ref_suppliers');
    Frg1.Opt.SetButtons(1,[[btnSelectFromList],[],[btnRefresh],[],[btnView],[btnEdit,User.Role(rPC_R_Sp_Change)],[btnAdd,1],[btnCopy,1],[btnDelete,1],[],[btnGridSettings]]);
    Frg1.InfoArray:=[[Caption + '.'#13#10],
      ['Выбор поставщика.'#10#13'Выберите поставщика в таблице и нажмите кнопку "выбрать" или дважды кликните мышью на запись.'#10#13],
      ['Вы можете также создать поставщика, если нужного еще нет, или отредактировать существующую запись.', User.Role(rPC_R_Sp_Change)]
    ];
  end
  //платежный календарь - отчет по платежам по датам
  else if FormDoc = myfrm_Rep_SnCalendarByDate then begin
    Caption:='Платежи по датам';
    Frg1.Opt.SetFields([
      ['to_char(rownum) as ID','_id'],
      ['pdt','Дата','80'],
      ['sum','Сумма платежа','100','f=r:'],
      ['paidsum','Оплаченная сумма','100','f=r:']
    ]);
    Frg1.Opt.SetTable('v_sn_calendar_datereport');
    Frg1.Opt.SetButtons(1, 'rsfp');
    Frg1.Opt.FilterRules := [[], ['pdt']];
    va:=Q.QSelectOneRow('select sum(case when status = 0 then round(sum) else 0 end) as debtsum from sn_calendar_payments', []);
    Frg1.CreateAddControls('1', cntLabelClr,
      S.IIf(va[0] = 0, 'Задолженности нет.', 'Задолженность на сегодня: $FF0000 ' + FormatCurr('#,##0', S.NNum(va[0])) + ' $000000р.'),
      'Lb1', '', -1, yrefC, 300
    );
  end
  else if FormDoc = myfrm_J_Accounts_SEL then begin //!!!
    Caption:='Счета';
    Frg1.Opt.SetFields([
      ['id$i','_id'],
      ['expenseitem$s','Статья расходов','150;w'],
      ['supplier$s','Получатель','150;w'],
      ['account$s','Счет','100;w'],
      ['accountdt$d','Дата счета','80'],
      ['accsum$f','Сумма по счету','80','f=r:']
    ]);
    Frg1.Opt.SetTable('v_sn_calendar_accounts');
    Frg1.Opt.SetButtons(1,[[btnSelectFromList],[btnGridFilter],[-btnGridSettings]]);
    Frg1.Opt.FilterRules := [[], ['accountdt']];
    Frg1.InfoArray:=[
      ['Выбор счета.'#10#13'Выберите необходимый счет в таблице и нажмите кнопку "выбрать" или дважды кликните мышью на запись.'#10#13],
      ['Используйте кнопку "Фильтр", чтобы выбрать период, за который выводятся счета.']
    ];
  end
  else if FormDoc = myfrm_J_OrPayments then begin
    Caption:='Платежи по заказам';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['path$i','_File',''],
      ['year$i','_Год',''],
      ['ornum$s','№ заказа','80'],
      ['dt_beg$d','Дата оформления','80'],
      ['dt_end$d','Дата закрытия','80'],
      ['project$s','Проект','150'],
      ['customer$s','Плательщик','150'],
      ['account$s','№ счета','140','e',User.Roles([],[rOr_J_OrPayments_Ch, rPC_J_OrPayments_Ch])],
      ['cost$f','Сумма заказа','80','f=r:'],
      ['cashtypename$s','Форма оплаты','90'],
      ['paidsum$f','Оплачено','80','f=r:'],
      ['restsum$f','Остаток','80','f=r:'],
      ['receivables$f','Дебиторская задолженность','80','f=r:'],
      ['paimentstatus$i','Статус','50','pic=полностью;частично;не оплачен;переплата:1;2;3;4'],
      ['comm$s','Примечание к заказу','200']
    ]);
    Frg1.Opt.SetTable('v_or_payments');
    Frg1.Opt.FilterRules := [[], ['dt_beg;dt_end'], ['Показать закрытые', 'Closed', ';dt_end is null', True], ['Показать с нулевой суммой', 'NullSum', ',cost > 0', True]];
    Frg1.Opt.SetButtons(1, 'rafs', User.Roles([],[rOr_J_OrPayments_Ch, rPC_J_OrPayments_Ch]));
    Frg1.InfoArray:=[
      [Caption+ #13#10],
      [
      'Здесь заносятся данные по оплате всех заказов. Каждый заказ может быть оплачен частями, но'#13#10 +
      'на каждую дату может быть только одна строка (суммарная оплата за эту дату).'#13#10 +
      'Используйте кнопку "Добавить", чтобы быстро добавить запись об оплате'#13#10 +
      '(при добавлении, если уже есть платеж за эту дату, то введенная сумма будет прибавлена к нему),'#13#10 +
      'или же раскройте список оплат по заказу, нажав + в первой колонке, и отредактируйте (добавьте/измените/удалите) данные.'#13#10 +
      'В основной таблице также можно изменить номер счета, просто отредактируйте его в ячейке.'#13#10 +
      'Используйте кнопку фильтра, чтобы показать завершенные заказы и заказы с нулевыми суммами.'#13#10 +
      ''#13#10
      ,User.Roles([],[rOr_J_OrPayments_Ch])
      ]
    ];
    Frg2.Opt.SetFields([
      ['id$i','_id','40'],
      ['dt$d','Дата','80'],
      ['sum$f','Сумма','80','f=r:']
    ]);
    Frg2.Opt.SetTable('or_payments');
    Frg2.Opt.SetWhere('where id_order = :id_order$i order by dt');
    Frg2.Opt.SetButtons(1, 'aed', User.Roles([],[rOr_J_OrPayments_Ch, rPC_J_OrPayments_Ch]));
  end
  else if FormDoc = myfrm_Rep_SnCalendar_Transport then begin
    Caption:='Отчет по транспортным счетам';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['filename$s','_Счет','40'],
      ['accounttype$i','_accounttype','40'],
      ['expenseitem$s','Статья расходов','120'],
      ['username$s','Менеджер','100'],
      ['organization$s','Плательщик','100'],
      ['supplier$s','Контрагент','120'],
      ['dt_payment$d','Дата оплаты','80'],
      ['cartype$s','Транспорт','80'],
      ['flighttype$s','Тип рейса','80'],
      ['location1$s','Пункт отправки','120'],
      ['location2$s','Пункт назначения','120'],
      ['strings$s','Количество мест','80'],
      ['kilometrage$f','Километраж, км.','80'],
      ['sumkm$f','Километраж, руб.','80','f=r:'],
      ['idle$f','Простой, ч.','80','f=r'],
      ['sumidle$f','Простой, руб.','80','f=r:'],
      ['sumother$f','Прочее, руб.','80','f=r:'],
      ['sum_wo_nds as sum$f','К оплате, всего','80','f=r:'],
      ['basissum$f','Цена груза общая','80','f=r:'],
      ['percent$f','Доля транспортных затрат, %','80','f=f'],
      ['pricekm$f','Цена за км.','80','f=r'],
      ['sum_m$f','Цена монтажа','80','f=r:'],
      ['sum_d$f','Цена доставки','80','f=r:']
    ]);
    Frg1.Opt.SetTable('v_sn_calendar_accounts_t_rep');
    Frg1.Opt.SetWhere('where dt_payment >= :dt_beg and dt_payment <= :dt_end and 1 = :i');
    Frg1.Opt.SetButtons(1,[[btnRefresh],[],[btnView],[],[btnExcel],[btnPrintGrid],[],[btnGridSettings],[],[btnCtlPanel]]);
    Frg1.CreateAddControls('1', cntDEdit, 'Дата с:', 'DeBeg', '', 4, yrefC, 100);
    Frg1.CreateAddControls('1', cntDEdit, 'по: ', 'DeEnd', '', -1, yrefC, 100);
    Frg1.InfoArray:=[[
      'Отчет по транспортным счетам за указанный период.'#13#10+
      'Для просмотра счета сделайте двойной клик на строке таблицы или нажмите соответствующую кнопку.'#13#10+
      'Вы можете распечатать таблицу или выгрузить ее в Excel.'#13#10
    ]];
  end
  else if FormDoc = myfrm_Rep_SnCalendar_AccMontage then begin
    Caption:='Отчет по счетам подрядчиков по монтажу.';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['filename$s','_Счет','40'],
      ['expenseitem$s','Статья расходов','120'],
      ['username$s','Менеджер','100'],
      ['organization$s','Плательщик','100'],
      ['supplier$s','Контрагент','120'],
      ['sum$f','К оплате, всего','80','f=r:'],
      ['basissum$f','Стомость заказов (изд. и д/к)','80','f=r:'],
      ['sum_m$f','Цена монтажа','80','f=r:'],
      ['sum_d$f','Цена доставки','80','f=r:']
    ]);
    Frg1.Opt.SetTable('v_sn_calendar_accounts_m_rep');
    Frg1.Opt.SetWhere('where accountdt >= :dt_beg and accountdt <= :dt_end and 1 = :i');
    Frg1.Opt.SetButtons(1,[[btnRefresh],[],[btnView],[],[btnExcel],[btnPrintGrid],[],[btnGridSettings],[],[btnCtlPanel]]);
    Frg1.CreateAddControls('1', cntDEdit, 'Дата с:', 'DeBeg', '', 4, yrefC, 100);
    Frg1.CreateAddControls('1', cntDEdit, 'по: ', 'DeEnd', '', -1, yrefC, 100);
    Frg1.InfoArray:=[[
      'Отчет по счетам подрядчиков по монтажу за указанный период.'#13#10+
      'Для просмотра счета сделайте двойной клик на строке таблицы или нажмите соответствующую кнопку.'#13#10+
      'Вы можете распечатать таблицу или выгрузить ее в Excel.'#13#10
    ]];
  end

  {РАБОТНИКИ}

  else if FormDoc = myfrm_R_Workers then begin
    Caption:='Справочник работников';
    Frg1.Options := Frg1.Options + [myogGridLabels];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['f','Фамилия','120'],
      ['i','Имя','120'],
      ['o','Отчество','120'],
      ['statusname','Статус','100'],
      ['dt','Дата','75'],
      ['divisionname','Подразделение','150'],
      ['job','Профессия','150']
    ]);
    Frg1.Opt.SetTable('v_ref_workers');
    Frg1.Opt.SetButtons(1, 'rveacds', User.Role(rW_R_Workers_Ch));
  end
  else if FormDoc = myfrm_J_WorkerStatus then begin
    Caption:='Статусы работников';
    Frg1.Options := Frg1.Options + [myogGridLabels];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['workername','ФИО','200'],
      ['dt','Дата','75'],
      ['statusname','Статус','100'],
      ['divisionname','Подразделение','150'],
      ['job','Профессия','150']
    ]);
    Frg1.Opt.SetTable('v_j_worker_status');
    Frg1.Opt.SetButtons(1, 'rads', User.Role(rW_J_WorkerStatus_Ch));
  end
  else if FormDoc = myfrm_R_Jobs then begin
    Caption:='Справочник профессий';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name','Профессия','300']
    ]);
    Frg1.Opt.SetTable('ref_jobs');
    Frg1.Opt.SetButtons(1, 'rveacds', User.Role(rW_R_Jobs_Ch));
  end
  else if FormDoc = myfrm_R_TurvCodes then begin
    Caption:='Обозначения ТУРВ';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['Код','Код','60'],
      ['name','Расшифровка','150']
    ]);
    Frg1.Opt.SetTable('ref_turvcodes');
    Frg1.Opt.SetButtons(1, 'rveacds', User.Role(rW_R_TurvCode_Ch));
  end
  else if FormDoc = myfrm_R_Divisions then begin
    Caption:='Справочник подразделений';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['code','Код','80'],
      ['name','Наименование','150'],
      ['isoffice','Офис/Цех','80'],
      ['head','Руководитель','150'],
      ['editusernames','Заполняют ТУРВ','300'],
      ['active','Используется','70','pic']
    ]);
    Frg1.Opt.SetTable('v_ref_divisions');
    Frg1.Opt.SetButtons(1, 'rveacds', User.Role(rW_R_Divisions_Ch));
  end
  else if FormDoc = myfrm_R_Candidates_Ad_SELCH then begin      //!!!
    Caption:='Справочник - источники информации по вакансиям';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name','Наименование','300']
    ]);
    Frg1.Opt.SetTable('ref_candidates_ad');
    Frg1.Opt.SetButtons(1, 'rlveacds', User.Role(rW_J_Candidates_Ch));
    Frg1.InfoArray:=[
    ['Выбор источники информации.'#10#13'Выберите нужное значение в таблице и нажмите кнопку "выбрать" или дважды кликните мышью на запись.'#10#13],
    ['Вы можете также создать запись, если нужной еще нет, или отредактировать существующую запись.', User.Role(rW_J_Candidates_Ch)]
    ];
  end
  else if FormDoc = myfrm_J_Candidates then begin
    Caption:='Журнал соискателей';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name','ФИО','200'],
      ['dt_birth','Дата рождения','75'],
      ['phone','Телефон','120'],
      ['ad','Источники информации','150'],
      ['vacancy','Вакансия','150'],
      ['job','Должность','150'],
      ['divisionname','Подразделение','150'],
      ['dt','Дата обращения','75'],
      ['headname','Ответственный','120'],
      ['statusname','Статус','100'],
      ['dt1','Принят','75'],
      ['dt2','Уволен','75'],
      ['comm','Комментарий','200;h']
    ]);
    Frg1.Opt.SetTable('v_sn_calendar_accounts');
    Frg1.Opt.FilterRules := [[], ['dt;dt1;dt2;dt_birth']];
    Frg1.Opt.SetButtons(1, 'rveacdfs', User.Role(rW_J_Candidates_Ch));
    Frg1.CreateAddControls('1', cntComboLK, 'Площадка:', 'CbArea', '', 80, yrefC, 80);
    Frg1.InfoArray:=[
      ['Журнал соискателей.'#13#10],
      ['Для отдела кадров, содержит информацию о соискателях на вакантные должности.'],
      ['Если один и тот же человек обращается в ОК несколько раз (в разное время, на разные вакансии), то создается отдельная запись для каждого обращения!'#13#10+
       'Данный журнал не связан со справочников работников и журналом "Статусы работников", корректировки в "Соискателях" не влияют на записи в этих документах!'#13#10
      ]
    ];
  end
  else if FormDoc = myfrm_J_Turv then begin
    Caption:='Журнал ТУРВ';
    Frg1.Options := Frg1.Options + [myogGridLabels];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['commit','_Commit','40'],
      ['editusers','_EditUsers','40'],
      ['code','Код','50'],
      ['name','Подразделение','200'],
      ['dt1','Нач. дата','75'],
      ['dt2','Кон. дата','75'],
      ['committxt','Закрыта','60','pic=закрыт:13'], //!!!
      ['status','Статус','60','pic=0;1;2:1;2;3']   //!!!
    ]);
    Frg1.Opt.SetTable('v_turv_period');
    v:=User.Roles([], [rW_J_Turv_TP, rW_J_Turv_TS]);
    v:=v or (Q.QSelectOneRow('select max(IsStInCommaSt(:id$i, editusers)) from ref_divisions', [User.GetId])[0] = 1);
    Frg1.Opt.SetButtons(1,[[btnRefresh],[],[btnEdit, v],[btnAdd, 1],[btnDelete, v and (User.IsDeveloper or User.IsDataEditor)],[],[btnGridFilter],[],[btnGridSettings],[],[btnCtlPanel]]);
    Frg1.Opt.FilterRules := [[], ['dt1']];
    Frg1.CreateAddControls('1', cntCheck, 'Текущий период', 'ChbCurrent', '', 4, yrefT, 100);
    Frg1.CreateAddControls('1', cntCheck, 'Прошлый период', 'ChbPrevious', '', 4, yrefT, 100);
    Frg1.CreateAddControls('1', cntCheck, 'Только свои ТУРВ', 'ChbSelf', '', -1, yrefT, 150);
    Frg1.InfoArray:=[
    ['caption'],
    ['В колонке Завершен отображается статус закрытия ТУРВ (если там есть галочка, то его нельзя менять.'#13#10+
     'В колонке Статус красная галочка означает что не введено или введено некорректное время руководителя, если галочка синяя, то имеются различия со временам Parsec, а если зеленая - все времена совпадают.'#13#10
    ],
    ['Нажмите кнопку Просмотреть для просмотра ТУРВ, если у Вас нет прав на его изменение.'#13#10, not v],
    ['Нажмите кнопку Изменить для внесения данных в ТУРВ.'#13#10, v],
    ['Если ТУРВ, который Вы должны редактировать, за выбранный период отстутствует, нажмите кнопку Добавить и создайте его.'#13#10, v],
    [
      'Используйте галочки рядом с кнопками, чтобы показывать не весь журнал, а только необходимые ТУРВ.'#13#10+
      '(Вы можете выбрать отображение только тех табелей, которые Вы заполняете.'#13#10'Таксже, если отмечены галочки периодов, то'+
      'отображаются ТУРВ за эти периоды, а иначе все ТУРВ.)'#13#10
    ],
    ['refoptions']
    ];
  end
  else if FormDoc = myfrm_J_Payrolls then begin
    Caption:='Журнал зарплатных ведомостей';
    Frg1.Options := Frg1.Options + [myogGridLabels];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['code','Код','50'],
      ['divisionname','Подразделение','200'],
      ['dt1','Нач. дата','75'],
      ['dt2','Кон. дата','75'],
      ['committxt','Закрыта','60','pic=закрыт:13']
    ]);
    Frg1.Opt.SetTable('');
    Frg1.Opt.SetButtons(1,[[btnRefresh],[],[btnView],[btnEdit],[btnAdd, 1],[btnDelete, 1],[],[btnGridFilter],[],[btnGridSettings],[],[btnCtlPanel]]);
    Frg1.Opt.FilterRules := [[], ['dt1']];
    Frg1.CreateAddControls('1', cntCheck, 'Текущий период', 'ChbCurrent', '', 4, yrefT, 100);
    Frg1.CreateAddControls('1', cntCheck, 'Прошлый период', 'ChbPrevious', '', 4, yrefT, 100);
    Frg1.CreateAddControls('1', cntCheck, 'Только подразделения', 'ChbDivisions', '', -1, yrefT, 150);
    Frg1.InfoArray:=[
      ['Журнал зарплатных ведомостей.'#13#10+
      'Для просмотра ведомостей только за прошедший (и текущий - по уволенным) период поставьте соответствующую галочку.'#13#10+
      'Если Вы не хотите видеть ведомости по уволенным работникам, поставьте соответствующую галочку.'#13#10],
      ['Для создания платежных ведомостей за прошедший период по всем подразделениям,'#13#10+
      'либо для создания ведомостей по уволенным в текущем периоде работникам, нажмите соответствующую кнопку.'#13#10 , User.Role(rW_J_Payroll_Ch)],
      ['Дважды кликните на записи, или нажмите кнопку "Изменить" для редактирования ведомости.'#13#10, User.Role(rW_J_Payroll_Ch)]
    ];
  end
  else if FormDoc = myfrm_R_Holideys then begin
    Caption:='Производственный календарь';
    Frg1.Opt.SetFields([
      ['dt as id$i','_id','40'],
      ['dt','Дата','75'],
      ['typetxt','Тип','90'],
      ['descr','Праздник','150;h']
    ]);
    Frg1.Opt.SetTable('v_ref_holidays');
    Frg1.Opt.SetWhere('where extract(year from dt) = :year$i');
    Frg1.Opt.SetButtons(1,[[btnRefresh],[],[btnCustom_LoadFromInet, User.IsDeveloper or User.Role(rW_R_Holideys_Ch)],[],[btnGridSettings],[],[btnCtlPanel]]);
    Frg1.Opt.SetButtonsIfEmpty([btnCustom_LoadFromInet]);
    Frg1.CreateAddControls('1', cntComboL, 'Год:', 'CbYear', '', 40, yrefC, 50);
    for i:=2013 to YearOf(Date)+1 do
      TDBComboBoxEh(Frg1.FindComponent('CbYear')).Items.Add(IntToStr(i));
    TDBComboBoxEh(Frg1.FindComponent('CbYear')).Text:=IntToStr(YearOf(Date));
    Frg1.InfoArray:=[];
  end
  else if FormDoc = myfrm_Rep_W_Payroll then begin
    Caption:='Свод по зарплатным ведомостям';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['rownum as id$i','_id','40'],
      ['code','Код','60'],
      ['dn','Подразделение','250;h'],
      ['itog1','Начислено','80','f=r:'],
      ['ud','Удержано','80','f=r:'],
      ['ndfl','НДФЛ','80','f=r:'],
      ['fss','ФСС','80','f=r:'],
      ['pvkarta','Пром. выплата','80','f=r:'],
      ['karta','Карта','80','f=r:'],
      ['itog','К получению','80','f=r:'],
      ['null','Подпись','80']
    ]);
    Frg1.Opt.SetTable('v_payroll_sum');
    Frg1.Opt.SetWhere('where dt1 = :dt1$d');
    Frg1.Opt.SetButtons(1,[[btnGo, False],[],[btnExcel],[btnPrintGrid],[],[btnGridSettings],[],[btnCtlPanel]]);
    Frg1.Opt.SetButtonsIfEmpty([btnGo]);
    Frg1.CreateAddControls('1', cntComboLK, 'Период:', 'CbPeriod', '', 60, yrefC, 150);
    Q.QLoadToDBComboBoxEh('select to_char(dt1, ''dd-mm-yyyy'') || '' - '' || to_char(max(dt2), ''dd-mm-yyyy'') as dt from v_payroll group by dt1 order by dt1 desc', [],
      TDBComboBoxEh(Frg1.FindComponent('CbPeriod')), cntComboL
    );
    TDBComboBoxEh(Frg1.FindComponent('CbPeriod')).ItemIndex := 0;
  end
  else if FormDoc = myfrm_J_Vacancy then begin
    Caption:='Журнал вакансий';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['job','Должность','150;h'],
      ['qnt','Кол-во','75'],
      ['qntopen','Открыто','75'],
      ['dt_beg','Дата открытия','75'],
      ['statusname','Статус','80'],
      ['divisionname','Подразделение',''],
      ['headname','Ответственный','120'],
      ['workers','Принятые','200;h'],
      ['candidates','Кандидаты','200;h'],
      ['dt_end','Дата закрытия','75'],
      ['reasonname','Причина закрытия','100']
    ]);
    Frg1.Opt.SetTable('v_j_vacancy');
    Frg1.Opt.SetButtons(1, 'rveacdfs', User.Role(rW_J_Vacancy_Ch));
    Frg1.Opt.FilterRules := [[], ['dt_beg;dt_end']];
    Frg1.Opt.DialogFormDoc := myfrm_Dlg_Vacancy;
  end



{ 'pic=0;1;2:1;2;3'

    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['','',''],
    ]);
    Frg1.Opt.SetTable('v_sn_calendar_accounts');
    Frg1.Opt.SetWhere('');
    Frg1.Opt.SetButtons(1,[[btnSelectFromList],[btnGridFilter],[-btnGridSettings]]);
    Frg1.Opt.SetButtons(1,[[btnSelectFromList],[],[btnRefresh],[],[btnEdit],[btnAdd],[btnCopy],[btnDelete],[],[btnGridFilter],[],[btnGridSettings],[],[btnCtlPanel]]);
    Frg1.Opt.SetButtonsIfEmpty([btnGo]);
    Frg1.Opt.FilterRules := [[], ['accountdt']];
    Frg1.Opt.SetButtons(1, 'rveacdfsp');
    Frg1.Opt.DialogFormDoc := myfrm_Dlg_Vacancy;
    Frg1.CreateAddControls('1', cntComboLK, 'Площадка:', 'CbArea', '', 80, yrefC, 80);
    Frg1.InfoArray:=[
    ];
 }



  else if FormDoc = myfrm_R_StdProjects then begin
    Caption:='Типовые проекты';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name$s','Наименование проекта','300'],
      ['active$i','Используется','80','pic']
    ]);
    Frg1.Opt.SetTable('or_projects');
    Frg1.Opt.SetButtons(1, 'rveacds');
    Frg1.Opt.DialogFormDoc := myfrm_Dlg_R_StdProjects;
    Frg1.InfoArray:=[[Caption + '.'#13#10]];
  end
  else if FormDoc = myfrm_R_Bcad_Groups then begin
    Caption:='Группы bCAD';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name$s','Группа','300']
    ]);
    Frg1.Opt.SetTable('bcad_groups');
    Frg1.Opt.SetButtons(1, 'rveads', User.Role(rOr_R_BCad_Groups_Ch));
    Frg1.InfoArray:=[[Caption + '.'#13#10]];
//Frg1.setinitdata('*',[]);
  end
  else if FormDoc = myfrm_R_Bcad_Units then begin
    Caption:='Единицы измерения bCAD';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name$s','Единица измерения','300']
    ]);
    Frg1.Opt.SetTable('bcad_units');
    Frg1.Opt.SetButtons(1, 'rveads', User.Role(rOr_R_BCad_Units_Ch));
    Frg1.InfoArray:=[[Caption + '.'#13#10]];
  end
  else if FormDoc = myfrm_R_Bcad_Nomencl then begin
    Frg1.Options := Frg1.Options + [myogLoadAfterVisible];
    Caption:='Сметные позиции';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['id_itm$i','_id_itm','40'],
      ['groupname$s','Группа','120'],
      ['artikul$s','Артикул ИТМ','100'],
      ['name$s','Наименование','300;w'],
      ['unitname$s','Ед.изм.','60'],
      ['bcadcomment$s','Комментарий','300;w']
    ]);
    Frg1.Opt.SetTable('v_bcad_nomencl_add');
    Frg1.Opt.SetButtons(1,[[btnRefresh],[],[btnAdd,User.Role(rOr_R_ITM_U_Nomencl_Add)],
      [btnCustom_findInEstimates,User.Role(rOr_Other_Order_FindEstimate)],[],[btnGridSettings],[],[btnCtlPanel]]);
    Frg1.CreateAddControls('1', cntCheck, 'Показать по группам', 'ChbGrouping', '', -1, yrefC, 150);
    Frg1.CreateAddControls('1', cntCheck, 'Только из ИТМ', 'ChbFromItm', '', 154, yrefT, 200);
    Frg1.CreateAddControls('1', cntCheck, 'Показать артикул ИТМ', 'ChbArtikul', '', 154, yrefB, 200);
    Frg1.ReadControlValues;
    Frg1.Opt.SetGrouping(['groupname'], [], [clGradientActiveCaption], Cth.GetControlValue(Frg1, 'ChbGrouping') = 1);
    Frg1.InfoArray:=[
      [Caption + '.'#13#10],
      ['Здесь отображаются все позиции, когда-либо проведенные в сметах.'#13#10+
      'Уникально наименование позиции.'#13#10+
      'Так как группа, ед.изм, комментарий от смете к смете для одного и того же наименования могут быть различными,'#13#10+
      'то здесь отображается только один из вариантов этих данных (если их несколько).'#13#10+
      'Для удобства доступна группировка наименований по группе из сметы (по клику галочки).'#13#10+
      'Если необходимо видеть артикул позиции из ИТМ, включите соответствующую галочку.'#13#10+
      'Также вы можете ограничить список только той номенклатурой, которая есть в базе ИТМ.'#13#10],
      ['Есть возможность поиска сметной позиции в сметах станадртных изделий и заказов (по соответствующей кнопке).'  ,User.Role(rOr_Other_Order_FindEstimate)]
    ];
  end
  else if FormDoc = myfrm_R_OrderTemplates then begin
    Caption:='Шаблоны заказов';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['dt_beg$d','Дата создания','80'],
      ['templatename$s','Шаблон','180'],
      ['format$s','Формат паспорта','130'],
      ['project$s','Проект','200']
    ]);
    Frg1.Opt.SetTable('v_orders');
    Frg1.Opt.SetWhere('where id < 0');
    Frg1.Opt.SetButtons(1, 'rveacds', User.Role(rOr_R_Or_Templates_Ch));
  end
  //заказы - справочник причин рекламаций
  else if FormDoc = myfrm_R_ComplaintReasons then begin
    Caption:='Причины рекламаций';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name$s','Наименование','300'],
      ['active$s','Используется','100','pic']
    ]);
    Frg1.Opt.SetTable('ref_complaint_reasons');
    Frg1.Opt.SetButtons(1, 'rveacds', User.Role(rOr_R_ComplaintReasons_Ch));
  end
  else if FormDoc = myfrm_R_DelayedInprodReasons then begin
    Caption:='Причины задержки в производстве';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name$s','Наименование','200'],
      ['active$i','Используется','80','pic']
    ]);
    Frg1.Opt.SetTable('ref_delayed_prod_reasons');
    Frg1.Opt.SetButtons(1, 'reacdsp', User.Role(rOr_R_DelayedInprodReasons_Ch));
  end
  else if FormDoc = myfrm_R_RejectionOtkReasons then begin
    Caption:='Причины неприемки ОТК';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name$s','Наименование','200'],
      ['active$i','Используется','80','pic']
    ]);
    Frg1.Opt.SetTable('ref_otk_reject_reasons');
    Frg1.Opt.SetButtons(1, 'reacdsp', User.Role(rOr_R_RejectionOtkReasons_Ch));
  end
  else if FormDoc = myfrm_Rep_Order_Complaints then begin
    Caption:='Отчет по рекламациям';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['ornum$s','№ заказа','100'],
      ['dt_beg$dt','Дата создания','80'],
      ['project$s','Проект','180;h'],
      ['customer$s','Покупатель','180;h'],
      ['complaints$s','Причины рекламации','220;h']
    ]);
    Frg1.Opt.SetTable('v_orders');
    Frg1.Opt.SetButtons(1, 'rvfs');
    Frg1.Opt.FilterRules := [[], ['dt_beg']];
    Frg1.InfoArray:=[[
       Caption + ' (причины рекламаций).'#13#10 +
      'Здесь показаны все заказы, являющиеся рекламациями.'#13#10 +
      'Причины рекламаций показаны в одном слобце, через точку с запятой, если их несколько.'#13#10 +
      'Для выбора периода отображения заказов используйте кнопку фильтра.'#13#10 +
      'Также есть возможность просмотреть паспорт заказа, для чего используйте кнопку Просмотр.'#13#10 +
      'Для печати показаннгой таблицы или ее экспорта в Excel нажмите правую кнопку мыши.'
    ]];
  end
  else if FormDoc = myfrm_J_InvoiceToSgp then begin
    Caption:='Накладные перемещения на СГП';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['num$i','№','40'],
      ['dt1_m$d','Дата','80'],
      ['state$i','Статус','50','pic=0;1;2:3;2;1'],
      ['ornum$s','Заказ','80'],
      ['project$s','Проект','150'],
      ['user_m$s','Мастер','130'],
      ['user_s$s','Кладовщик','130'],
      ['items$s','Изделия','200']
    ]);
    Frg1.Opt.SetTable('v_invoice_to_sgp');
    Frg1.Opt.SetWhere('where area = :area$i');
    Frg1.Opt.SetButtons(1,[[btnRefresh],[],[btnView],[btnAdd,User.Role(rOr_J_InvoiceToSgp_Ch_M)],[btnEdit,User.Role(rOr_J_InvoiceToSgp_Ch_S)],[],[btnGridFilter],[],[btnGridSettings],[],[btnCtlPanel]]);
    Frg1.Opt.FilterRules := [[], ['dt1_m']];
    Frg1.CreateAddControls('1', cntComboLK, 'Площадка:', 'CbArea', '', 80, yrefC, 80);
    Q.QLoadToDBComboBoxEh('select shortname, id from ref_production_areas order by id', [], TDBComboBoxEh(Frg1.FindComponent('CbArea')), cntComboLK);
    Frg1.InfoArray:=[[
      Caption + #13#10 + #13#10+
      'Нажмите кнопку "Добавить" для создания новой накладной и заполнения данных от мастера.'#13#10+
      'Накладные, заполненные мастером, но не оприходованные на СГП, получают в графе "Статус" красную галочку.'#13#10+
      'Кладовщик может оприходовать такую накладную, нажав кнопку "Изменить", или дважды щелкнув по накладной с красной галкой.'#13#10+
      'После этого статус будет изменен на синюю или зеленую галку - в зависимости от того, все '#13#10+
      'ли переданные мастером изделиябыли приняты на СГП.'#13#10+
      'После ввода данных, отмена проведения и редактирование накладной невозможно, доступен только просмотр.'#13#10+
      'Распечатать накладную можно, открыв ее в режиме просмотра.'#13#10+
      ''#13#10
    ]];
  end
  else if FormDoc = myfrm_R_Or_ItmExtNomencl then begin
    Caption:='Расширенный справочник номенклатуры ИТМ';
    Frg1.Options := Frg1.Options + [myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['rownum as id$i','_id','40'],
      ['id_nomencl','_id_nomencl','40'],
      ['nomencltype','nomencltype','80'],
      ['artikul','artikul','100'],
      ['skladname','skladname','100'],
      ['name','name','200;h','bt=Движение номенклатуры;Расхождения по заказам'],
      ['name_unit','name_unit','70'],
      ['qnt','qnt','70'],
      ['rezerv','rezerv','50'],
      ['ras','ras','50'],
      ['catalog','catalog','60']
    ]);
    Frg1.Opt.SetTable('v_itm_ext_nomencl');
    Frg1.Opt.SetButtons(1, 'rs');
  end
  else if FormDoc = myfrm_R_EstimatesReplace then begin
    Caption:='Автозамена номенклатуры';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['id_old$i','_id_old','50'],
      ['oldartikul','Исходная номенклатура|Артикул','100'],
      ['oldname','Исходная номенклатура|Наименование','300;h'],
      ['id_new','_id_new','50'],
      ['newartikul','Новая номенклатура|Артикул','100'],
      ['newname','Новая номенклатура|Наименование','300;h']
    ]);
    Frg1.Opt.SetTable('v_ref_estimate_replace');
    Frg1.Opt.FilterRules := [[], ['accountdt',User.Role(rOr_R_BCad_Replace_Ch)]];
    Frg1.Opt.SetButtons(1, 'reads');
    Frg1.InfoArray:=[
      [Caption+#13#10#13#10],
      ['Таблица номенклатуры для автозамены сметных позиций при выгрузке смет в ИТМ.'#13#10],
      ['Исходная номенклатура будет заменена в смете на новую номенклатуру, с прежней единицей измерения и количеством.'#13#10],
      ['Если целевая номенклатура уже есть в смете, то количества будут просуммированы.'#13#10],
      ['Если исходной номенклатуре не сооставлена целевая, то данная сметная позиция будет удалена.'#13#10],
      ['Внимание! Замена номенклатыры происходит в момент загрузки смет в Учет.'#13#10],
      ['В Учете можно просмотреть оба варианта сметы, как исходную, так и с изменениями, но в ИТМ придет последняя.'#13#10],
      ['Используйте кнопки редактирования для добавления позиций в список, либо их изменения и удаления.', User.Role(rOr_R_BCad_Replace_Ch)]
    ];
  end
  else if FormDoc = myfrm_R_Spl_Categoryes then begin
    Caption:='Категории снабжения';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name','Наименование',''],
      ['usernames','Пользователи','']
    ]);
    Frg1.Opt.SetTable('v_spl_categoryes');
    Frg1.Opt.SetButtons(1, 'reacds', User.Role(rOr_R_Spl_Categoryes_Ch));
    Frg1.InfoArray:=[
      [Caption+#13#10],
      ['Создайте категорию для заявок или измените ее параметры.'#13#10+
       'Необходимо будет задать название категории и выбрать пользователей,'#13#10+
       'которые могут создавать по ней заявки.'#13#10, User.Role(rOr_R_Spl_Categoryes_Ch)]
    ];
  end
  else if FormDoc = myfrm_R_Itm_Units then begin      //!!!
    Caption:='Справочник единиц измерения';
    Frg1.Options := Frg1.Options + [myogGridLabels];
    Frg1.Opt.SetFields([
      ['to_char(id_unit) as id$i','_id','40'],
      ['id_measuregroup','_id_group','40'],
      ['groupname','Группа','100'],
      ['name_unit','Наименование','80'],
      ['full_name','Полное наименование','100'],
      ['pression','Точность','70'],
      ['is_bcad_unit','Ед. bCAD','40','pic']
    ]);
    Frg1.Opt.SetTable('v_itm_units');
    Frg1.Opt.SetButtons(1,[[btnSelectFromList],[],[btnRefresh],[],[btnEdit,User.Role(rOr_R_Itm_Units_Ch)],[btnAdd,1],[btnCopy,1],[btnDelete,User.Role(rOr_R_Itm_Units_Del)],[],[btnGridSettings]]);
    Frg1.InfoArray:=[['Справочник единиц измерения ИТМ'#13#10]];
  end
  else if FormDoc = myfrm_R_Itm_Suppliers then begin
    Caption:='Справочник поставщиков';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];  //!!!
    Frg1.Opt.SetFields([
      ['id_kontragent$i','_id','40'],
      ['name_org','Наименование','200'],
      ['full_name','Полное наименование','200'],
      ['e_mail','EMail','120'],
      ['inn','ИНН','100']
    ]);
    Frg1.Opt.SetTable('v_itm_suppliers', '', 'id_kontragent');
    Frg1.Opt.SetButtons(1,[[btnSelectFromList],[],[btnRefresh],[],[btnEdit,User.Role(rOr_R_Itm_Suppliers_Ch)],[btnAdd,1],[btnCopy,1],[btnDelete,User.Role(rOr_R_Itm_Suppliers_Del)],[],[btnGridSettings]]);
    Frg1.InfoArray:=[['Справочник поставщиков']];
  end
  else if FormDoc = myfrm_R_Itm_InGroup_Nomencl then begin
    Caption:='ИТМ - номенклатура в группе';
    Frg1.Opt.SetFields([
      ['id_nomencl$i','_id','40'],
      ['artikul','Артикул','150'],
      ['name','Наименование','400']
    ]);
    Frg1.Opt.SetTable('dv.nomenclatura');
    Frg1.Opt.SetWhere('where id_group = :id_group$i');
    Frg1.InfoArray:=[['Номенклатура в выбранное группе'#13#10'Номенклатура в дочерних группах сюда не включается!']];
  end
  else if FormDoc = myfrm_J_Orders_SEL_1 then begin  //!!!
    Caption:='Выбор заказов';
    Frg1.Options := Frg1.Options + [myogIndicatorCheckBoxes, myogMultiSelect];
    Frg1.Opt.SetFields([
      ['id_order as id$i','_id','40'],
      ['path','_File','40'],
      ['ordernum','№ заказа','120','pic=Показать паспорт заказа'],
      ['year','Год','40'],
      ['dt_beg','Дата оформления','80'],
      ['dt_end','Дата сдачи','80'],
      ['customer','Заказчик','180'],
      ['project'+S.IIfStr(Length(AddParam[2]) > 2, ';'+AddParam[2]),'Проект'+S.IIfStr(Length(AddParam[2]) > 2, ';'+AddParam[3]),'200']
    ]);
    Frg1.Opt.SetTable('v_sn_orders');
    Frg1.Opt.SetWhere('where upper(project) like :proekt and id > 0');
    Frg1.Opt.SetButtons(1,[[btnSelectFromList],[],[btnGridFilter],[btnGridSettings]]);
    Frg1.Opt.FilterRules := [[], ['dt_beg;dt_end']];
    Frg1.InfoArray:=[[
      'Выберите один или несколько паспортов заказа.'#13#10+
      'Отмечайте нужные паспорта в левой колонке, дла отметки всех, инверсии или снятия отметки используйте правую кнопку мыши.'#13#10+
      'Вы можете просмотреть паспорт заказа, нажав кнопку в колонке номера заказа.'#13#10+
      'Настройте внешний вид таблицы, нажав соответствующую кнопку.'
    ]];
  end
  else if FormDoc = myfrm_R_StdPspFormats then begin
    Caption:='Стандартные форматы паспортов';
    Frg1.Options := Frg1.Options + [myogGridLabels];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name','Наименование формата','300'],
      ['active','Используется','80','pic']
    ]);
    Frg1.Opt.SetTable('or_formats');
    Frg1.Opt.SetWhere(S.IIfStr(not User.IsDataEditor, ' where id > 0'));
    Frg1.Opt.SetButtons(1, 'reacds', User.Role(rOr_R_StdPspFormats_Ch));

    Frg2.Opt.SetFields([
      ['id$i','_id','40'],
      ['name','Наименование','200'],
      ['prefix','Префикс для отгрузки','120'],
      ['prefix_prod','Префикс для производства','120'],
      ['is_semiproduct','Полуфабрикаты','80','pic'],
      ['active','Используется','80','pic']
    ]);
    Frg2.Opt.SetTable('or_format_estimates');
    Frg2.Opt.SetWhere('where id_format = :id_format$i order by name');
    Frg2.Opt.SetButtons(1, 'reacds',User.Role(rOr_R_StdPspFormats_Ch));
  end
  else if FormDoc = myfrm_Rep_PlannedMaterials then begin
    //отчет 'Годовая потребность в материалах'
    //заголовки месяцев формируются в AfterRefresh
    va:=Q.QSelectOneRow('select dt from properties where prop = ''planned_order_estimate12'' and subprop = ''dt_beg''', []);
    va1:=Q.QSelectOneRow('select dt from properties where prop = ''planned_order_estimate12'' and subprop = ''dt_calc''', []);
    if va1[0] = null then
      va1[0] := Date;
    Caption:='Годовая потребность в материалах';
    for i := 1 to 12 do
      va2 := va2 + [['qnt' + IntToStr(i), MonthsRu[MonthOf(IncMonth(TDateTime(va[0]), i - 1))], 65]];
    Frg1.Opt.SetFields(
      [['rownum as id$i','_id','40'], ['name','Наименование','450;h']] + va2 + [['qnt_all','Всего','60']]
    );
    Frg1.Opt.SetTable('v_planned_order_estimate12');
    Frg1.Opt.SetButtons(1,[[btnRefresh, User.Role(rOr_Rep_PlannedMaterials_Calc)],[],[btnGridSettings],[],[btnCtlPanel]]);
    Caption:='Годовая потребность в материалах';
    if User.Role(rOr_Rep_PlannedMaterials_Calc) then
      Frg1.CreateAddControls('1', cntDEdit, 'Рассчитать: ', 'DeBeg', '', 70, yrefC, 100);
    Frg1.CreateAddControls('1', cntLabelClr, S.IIf(va[0] = null, 'нет данных',
      'Дата начала периода: $FF0000 ' + S.NSt(va[0])+ ' $000000  (обновлено$FF0000 ' + DateTimeToStr(va1[0]) + '$000000 )'),
      'LbBeg', '', 200, yrefC, 300
    );
    Frg1.InfoArray:=[
      [Caption + '.'#13#10],
      ['Потребность в материялах по данным плановых заказов, по месяцам, на 12 месяцев начиная с указанной даты.'#13#10+
       'По двойному клику в ячейке можно просмотреть список плановых заказов, по которым требуется данный материал, '#13+#10+
       'также можно открыть и сам этот заказ в режиме просмотра.'#13#10],
      ['При изменении заказов и смет данные в отчете автоматически не обновляются!'#13#10+
       'Вы можете обновить их, нажав соответствующую кнопку, если у вас есть права доступа.'#13#10+
       'При этом нужно выбрать в поле рядом начальный месяц расчетного периода (число месяца значения не имеет).'#13#10+
       'Перерасчет данных может занять определенное время!'
      ]
    ];
  end
  else if FormDoc = myfrm_J_Devel then begin
    Caption:='Журнал разработки';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['develtype','Вид разработки','100'],
      ['project','Проект','200;h'],
      ['slash','№ изделия','140'],
      ['name','Название изделия','300;h'],
      ['constr','Конструктор','120'],
      ['dt_beg','Дата запуска','80'],
      ['dt_plan','План. дата сдачи','80'],
      ['dt_end','Дата сдачи','80'],
      ['status','Статус','80'],
      ['cnt','Сделка','80','f=f:'],
      ['time','Часы','80','f=f:'],
      ['comm','Комментарий','300;h']
    ]);
    Frg1.Opt.SetTable('v_j_development');
    Frg1.Opt.SetButtons(1,[[btnRefresh],[],[btnView],[btnEdit,User.Role(rOr_J_Devel_Ch)],[btnAdd,1],[btnCopy,1],[btnDelete,User.Role(rOr_J_Devel_Del)],[],[btnGridFilter],[],[btnGridSettings],[],[btnCtlPanel]]);
    Frg1.Opt.FilterRules := [[], ['dt_beg;dt_plan;dt_end']];
  end
  else if FormDoc = myfrm_R_Itm_Nomencl then begin
    Caption:='Справочник номенклатуры ИТМ';
    Frg1.Options := Frg1.Options + [myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id_nomencl$i','_id_nomencl','40'],
      ['groupname','Группа','100'],
      ['artikul','Артикул','100'],
      ['name','Наименование номенклатуры','300;h','bt=Движение по номенклатуре'],
      ['name_unit','Ед. изм.','80'],
      ['supplier','Основной поставщик','120','bt=Поставщики'],
      ['name_pos','Номенклатура основного поставщика','300;h'],
      ['price_main','Последняя цена','80','f=r','bt=Приходные накладные'],
      ['price_check','Контрольная цена','80','f=r'],
      ['has_files','Файлы','50','pic','bt=Файлы']
    ]);
    Frg1.Opt.SetTable('v_itm_nomencl_1');
    Frg1.Opt.SetButtons(1,[[btnRefresh],[],[btnEdit,User.Role(rOr_R_Itm_Nomencl_Rename)],[btnAdd,User.Role(rOr_R_ITM_U_Nomencl_Add)],[],[btnGridSettings]]);
    Frg1.InfoArray:=[
      [Caption+#13#10],
      ['Справочник номенклатурных позиций, имеющихся в базе ИТМ'#13#10+
       'Отображаются все позиции, перехода по дереву групп пока нет.'#13#10+
       'Показываются основные параметры номенклатуры.'#13#10+
       'В поле "Группа" отображается наименование крайней в дереве группы для данной номенклатуры.'#13#10+
       'По кнопке в ячейке "Наименование" можно посмотреть детализацию движения по данной номенклатуре.'#13#10+
       'В колонке "Поставщик" выводится основной поставщик для данной позиции (или единственный). По кнопке можно посмотреть'#13#10+
       '(и при наличии прав отредактировать) список поставщиков для данной позиции.'#13#10+
       'В колонке "Последняя цена" отображается цена последнего прихода товара (по основному поставщику!), нажав кнопку можно просмотреть'#13#10+
       'список приходных накладнх по товару. Эта графа подсвечивается, в зависимсоти от того, значение в ней больше или меньше контрольной цены.'#13#10+
       'В колонке "Контрольная цена" отображается соответсвенно цена, заданная для котроля закупок, если у вас есть права доступа,'#13#10+
       'то вы можете редактировать эту цену, сделав в ячеке двойной клик мышкой.'#13#10+
       ''#13#10],
      ['Вы можете переименовать номенклатурную позицию, при этом наименование изменится во всех справочниках и документах как в Учете, так и в ИТМ.'#13#10, User.Role(rOr_R_Itm_Nomencl_Rename)]
    ];
  end
  else if FormDoc = myfrm_R_bCAD_Nomencl_SEL then begin
    //выбор из списка сметной позиции, в списке все что загружалось в учет из смет, артикул берется из базы ИТМ
    Caption:='Справочник номенклатуры';
    Frg1.Options := Frg1.Options + [myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['artikul','Артикул','120'],
      ['name','Наименование','300;h'],
      ['id_itm','_id_itm','40']
    ]);
    Frg1.Opt.SetTable('v_bcad_nomencl_add');
    Frg1.Opt.SetWhere('where id_itm is not null');
    Frg1.Opt.SetButtons(1, 'lrs');
    Frg1.InfoArray:=[
      ['Выбор номенклатуры bCAD.'#10#13'Выберите номенклатуру в таблице и нажмите кнопку "выбрать" или дважды кликните мышью на запись.'#10#13]
    ];
  end
  else if FormDoc = myfrm_R_Itm_Schet then begin
    //счет от поставщика из итм
    Caption:='Счет от поставщика';
    Frg1.Opt.SetFields([
      ['id_shet_spec$i','_id','40'],
      ['articul','Артикул','120'],
      ['name','Наименование','300;h'],
      ['unit','Ед. изм','80'],
      ['quantity','Кол-во','70'],
      ['price','Цена','80','f=r'],
      ['sum_rur','Сумма','80','f=r:']
    ]);
    Frg1.Opt.SetTable('dv.v_spschetspec');
    Frg1.Opt.SetWhere('where id_schet = :id_schet$i');
    Frg1.Opt.SetButtons(1, 'sp');
    va1:=Q.QSelectOneRow(
      'select s.num, s.date_registr, s.states, k.name_org, s.docstr '+
      'from dv.sp_schet s, dv.kontragent k '+
      'where k.id_kontragent = s.id_kontragent2 and id_schet = :id_schet$i',
      [VarToStr(AddParam)]
    );
    if va1[0] = null then begin
      MyInfoMessage('Документ не найден!');
      Exit;
    end;
    st1 := '[№ документа $FF0000' + VarToStr(va1[0]) + '$000000 от $FF0000' + DateTimeToStr(va1[1]) + '$000000]    [$FF0000' +
      VarToStr(va1[2]) + '$000000]    Поставщик: $FF0000' + VarToStr(va1[3]) + '$000000 ';
    st2 := 'Основание: $FF0000' + VarToStr(va1[4]) + '$000000 ';
    Frg1.CreateAddControls('1', cntLabelClr, st1, 'LbCapt1', '', 5, yrefT, 800);
    Frg1.CreateAddControls('1', cntLabelClr, st2, 'LbCapt2', '', 5, yrefB, 800);
    Frg1.InfoArray := [['Счет от поставщика (из ИТМ).'#13#10'(Только просмотр.)']];
  end
  else if FormDoc = myfrm_R_Itm_InBill then begin
    //приходная накладная из итм
    Caption:='Приходная накладная';
    Frg1.Opt.SetFields([
      ['id_ibspec$i','_id','40'],
      ['artikul','Артикул','120'],
      ['name','Наименование','300;h'],
      ['name_unit','Ед. изм','80'],
      ['ibquantity','Кол-во','70'],
      ['price','Цена','80','f=r'],
      ['price_itogo','Цена с НДС','80','f=r'],
      ['itogo','Сумма','80','f=r:']
    ]);
    Frg1.Opt.SetTable('v_spl_nom_inbills');
    Frg1.Opt.SetWhere('where id_inbill = :id_inbill$i');
    Frg1.Opt.SetButtons(1, 'sp');
    va1:=Q.QSelectOneRow(
      'select inbillnum, inbilldate, id_docstate, '+  //номер, дата регистрации, статус 3=проведена
      'name_org, sclad, '+  //поставщик, склад
      'npost_num, npost_date, npost_sum, docstr '+  //параметры исходного документа, основание
      'from dv.v_in_bills '+
      'where id_inbill = :id_inbill$i',
      [VarToStr(AddParam)]
    );
    if va1[0] = null then begin
      MyInfoMessage('Документ не найден!');
      Exit;
    end;
    st1 :=
     '[№ $FF0000' + VarToStr(va1[0]) + '$000000 от $FF0000' + DateTimeToStr(va1[1]) + '$000000]    '+
     S.IIfStr(va1[2] <> 3, ' ($0000FFНе проведена$000000)   ') +
     '$000000[Склад: $FF0000' + VarToStr(va1[4]) + '$000000]    ' +
     '$000000[Поставщик: $FF0000' + VarToStr(va1[3]) + '$000000]';
    if va1[5] <> null then
      st2 := '[№ поставщика $FF0000' + VarToStr(va1[5]) + '$000000 от $FF0000' + DateTimeToStr(va1[6]) + '$000000]    ';
    st2 := st2 +
      '[Сумма: $FF0000' + FormatFloat( '# ###.00', S.NNum(va1[7])) + '$000000]    '+
      '[Основание: $FF0000' + S.NSt(va1[8]) + '$000000]';
    Frg1.CreateAddControls('1', cntLabelClr, st1, 'LbCapt1', '', 5, yrefT, 800);
    Frg1.CreateAddControls('1', cntLabelClr, st2, 'LbCapt2', '', 5, yrefB, 800);
    Frg1.InfoArray := [['Приходная накладная (из ИТМ).'#13#10'(Только просмотр.)']];
  end
  else if FormDoc = myfrm_R_Itm_MoveBill then begin
    Caption:='Накладная перемещения';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['id_doc$i','_id','40'],
      ['artikul','Артикул','120'],
      ['name','Наименование','300;h'],
      ['name_unit','Ед. изм','80'],
      ['quantity','Кол-во','70']
    ]);
    Frg1.Opt.SetTable('v_spl_nom_movebills');
    Frg1.Opt.SetWhere('where id_doc = :id_doc$i');
    Frg1.Opt.SetButtons(1, 'sp');
    va1:=Q.QSelectOneRow(
      'select numdoc, dt, id_docstate, is_delete, sourceskladname, destskladname, basis '+
      'from v_spl_nom_movebills '+
      'where id_doc = :id_doc$i',
      [VarToStr(AddParam)]
    );
    if va1[0] = null then begin
      MyInfoMessage('Документ не найден!');
      Exit;
    end;
    st1 :=
     '[№ $FF0000' + VarToStr(va1[0]) + '$000000 от $FF0000' + DateTimeToStr(va1[1]) + '$000000]    '+
     S.IIfStr(va1[3] <> 0,  ' ($0000FFУдалена$000000)   ', S.IIfStr(va1[2] <> 3, ' ($0000FFНе проведена$000000)   ')) +
     '$000000[Со склада: $FF0000' + VarToStr(va1[4]) + '$000000 на склад: $FF0000' + VarToStr(va1[5]) + '$000000]    ' +
     '$000000[Заказ: $FF0000' + VarToStr(va1[6]) + '$000000]';
    Frg1.CreateAddControls('1', cntLabelClr, st1, 'LbCapt1', '', 5, yrefC, 800);
    Frg1.InfoArray := [['Накладная перемещения (из ИТМ).'#13#10'(Только просмотр.)']];
  end
  else if FormDoc = myfrm_R_Itm_OffMinus then begin
    Caption:='Акт списания';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['id_doc$i','_id','40'],
      ['name','Наименование','300;h'],
      ['name_unit','Ед. изм','80'],
      ['quantity','Кол-во','70']
    ]);
    Frg1.Opt.SetTable('v_spl_nom_offminuses');
    Frg1.Opt.SetWhere('where id_doc = :id_doc$i');
    Frg1.Opt.SetButtons(1, 'sp');
    va1:=Q.QSelectOneRow('select numdoc, dt, id_docstate, null, skladname, basis, comments from v_spl_nom_offminuses where id_doc = :id_doc$i', [VarToStr(AddParam)]);
    if va1[0] = null then begin
      MyInfoMessage('Документ не найден!');
      Exit;
    end;
    st1 :=
     '[№ $FF0000' + VarToStr(va1[0]) + '$000000 от $FF0000' + DateTimeToStr(va1[1]) + '$000000]    '+
     S.IIfStr(va1[2] <> 3, ' ($0000FFНе проведен$000000)   ') +
     '$000000[Со cклада: $FF0000' + VarToStr(va1[4]) + '$000000]    ' +
     '$000000[Основание: $FF0000' + VarToStr(va1[5]) + ' $000000]';
    Frg1.CreateAddControls('1', cntLabelClr, st1, 'LbCapt1', '', 5, yrefT, 800);
    Frg1.CreateAddControls('1', cntLabelClr, '$000000[Комментарий: $FF0000' + VarToStr(va1[5]) + ' $000000]', 'LbCapt2', '', 5, yrefB, 800);
    Frg1.InfoArray := [['Акт списания (из ИТМ).'#13#10'(Только просмотр.)']];
  end
  else if FormDoc = myfrm_R_Itm_PostPlus then begin
    Caption:='Акт оприходования';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['id_doc$i','_id','40'],
      ['name','Наименование','300;h'],
      ['name_unit','Ед. изм','80'],
      ['quantity','Кол-во','70']
    ]);
    Frg1.Opt.SetTable('v_spl_nom_postpluses');
    Frg1.Opt.SetWhere('where id_doc = :id_doc$i');
    Frg1.Opt.SetButtons(1, 'sp');
    va1:=Q.QSelectOneRow('select numdoc, dt, id_docstate, null, skladname, basis, comments from v_spl_nom_postpluses where id_doc = :id_doc$i', [VarToStr(AddParam)]);
    if va1[0] = null then begin
      MyInfoMessage('Документ не найден!');
      Exit;
    end;
    st1 :=
     '[№ $FF0000' + VarToStr(va1[0]) + '$000000 от $FF0000' + DateTimeToStr(va1[1]) + '$000000]    '+
     S.IIfStr(va1[2] <> 3, ' ($0000FFНе проведен$000000)   ') +
     '$000000[Со cклада: $FF0000' + VarToStr(va1[4]) + '$000000]    ' +
     '$000000[Основание: $FF0000' + VarToStr(va1[5]) + ' $000000]';
    Frg1.CreateAddControls('1', cntLabelClr, st1, 'LbCapt1', '', 5, yrefT, 800);
    Frg1.CreateAddControls('1', cntLabelClr, '$000000[Комментарий: $FF0000' + VarToStr(va1[5]) + ' $000000]', 'LbCapt2', '', 5, yrefB, 800);
    Frg1.InfoArray := [['Акт оприходования (из ИТМ).'#13#10'(Только просмотр.)']];
  end
  else if FormDoc = myfrm_R_Itm_Act then begin
    Caption:='АВР';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['id_doc$i','_id','40'],
      ['artikul','Артикул','120'],
      ['name','Наименование','300;h'],
      ['skladname','Со склада','80'],
      ['quantity','Кол-во','70']
    ]);
    Frg1.Opt.SetTable('v_spl_nom_acts');
    Frg1.Opt.SetWhere('where id_doc = :id_doc$i');
    Frg1.Opt.SetButtons(1, 'sp');
    va1:=Q.QSelectOneRow('select numdoc, dt, id_docstate, null, null, basis, comments from v_spl_nom_acts where id_doc = :id_doc$i', [VarToStr(AddParam)]);
    if va1[0] = null then begin
      MyInfoMessage('Документ не найден!');
      Exit;
    end;
    st1 :=
     '[№ $FF0000' + VarToStr(va1[0]) + '$000000 от $FF0000' + DateTimeToStr(va1[1]) + '$000000]    '+
     S.IIfStr(va1[2] <> 3, ' ($0000FFНе проведен$000000)   ') +
     //'$000000[Склад: $FF0000' + VarToStr(va1[4]) + '$000000]    ' +
     '$000000[Основание: $FF0000' + VarToStr(va1[5]) + ' $000000]';
    Frg1.CreateAddControls('1', cntLabelClr, st1, 'LbCapt1', '', 5, yrefT, 800);
    Frg1.CreateAddControls('1', cntLabelClr, '$000000[Комментарий: $FF0000' + VarToStr(va1[5]) + ' $000000]', 'LbCapt2', '', 5, yrefB, 800);
    Frg1.InfoArray := [['АВР (из ИТМ).'#13#10'(Только просмотр.)']];
  end
  else if FormDoc = myfrm_R_OrderStdItems_SEL then begin  //!!!
    Caption:='Выбор стандартныого изделия';
     Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['fullname','Наименование','']
    ]);
    Frg1.Opt.SetTable('v_or_std_items');
    Frg1.Opt.SetWhere('where id_or_format_estimates > 0');
    Frg1.Opt.SetButtons(1, 'ls');
  end






  else if FormDoc = myfrm_Rep_Sgp2 then begin
    Caption:='Состояние СГП (нестандартные изделия)';
    Frg1.Opt.SetFields([
      ['id$i','_id'],
      ['slash','№','80'],
      ['name','Наименование','300'],
      ['dt_beg','Дата оформления','80'],
      ['dt_otgr','Плановая дата отгрузки','80'],
      ['qnt_psp','Заказано','80','f=:'],
      ['qnt_in_prod','В производстве','80'],
      ['sum_in_prod','Сумма в производстве','80','f=r:'],
      ['qnt_sgp_registered','Принято на СГП','80','f=:'],
      ['qnt_shipped','Отгружено','80','f=:'],
      ['qnt','Текущий остаток','80','f=:'],
      ['price','Цена','80', 'f=r'],
      ['sum','Сумма','80','f=r:']
    ]);
    Frg1.Opt.SetTable('v_sgp2');
    //Frg1.Opt.SetButtons(1, 'rfsp');
    Frg1.Opt.SetButtons(1,[[btnRefresh],[],[btnGridFilter],[-btnCustom_Revision, User.Role(rOr_Rep_Sgp_Rev),'Ревизия'],[-btnCustom_JRevisions, 1,'Журнал ревизий'],[],[btnGridSettings]]);
    Frg1.CreateAddControls('1', cntCheck, 'Только в наличии на СГП', 'ChbNot0', '', 4, yrefC, 200);
    Frg1.Opt.FilterRules := [[], ['dt_beg;dt_otgr']];
    Frg1.InfoArray:=[[Caption + '.'#13#10], [
      'В таблице отображается и по ней контролируется состояние склада готовой продукции '#13#10+
      'только по нестандартным изделиям.'#13#10+
      'Каждое изделия в ПЗ с пометкой "Нестандарт" считается уникальным изделием, если в'#13#10+
      'других паспортах были изделия с такими же наименованиями, то они пойдут отдельными строками в таблице.'#13#10+
      'Приход и расход учитывается по факту поступления и отгрузки с СГП данного слеша.'#13#10+
      'Для коррекции остатков возможно сдделать ревизию СГП, выберите этот пункт в контекстном меню.'#13#10+
      'Двойной клик на столбце "Текущий остаток" откроет окно движения по данной номенклатуре.'#13#10
    ]];

  end
  else if FormDoc = myfrm_J_Sgp_Acts then begin
    Caption:='Ревизии СГП';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','№','40'],
      ['doctype','Вид документа','160'],
      ['dt','Дата','70'],
      ['formatname','Формат изделий','140'],
      ['username','Пользователь','140']
    ]);
    Frg1.Opt.SetTable('v_sgp_revisions');
    Frg1.Opt.FilterRules := [[], ['dt']];
    Frg1.Opt.SetButtons(1, 'rfsp');
    Frg1.CreateAddControls('1', cntCheck, 'Все форматы', 'ChbAllFormats', '', 4, yrefC, 200);
    Frg2.Opt.SetFields([
      ['id$i','_id','40'],
      ['slash','_Слеш','120'], //сюда во вьюхе попадает номер акта, он же айдм
      ['name','Наименование','300;h'],
      ['qnt','Кол-во','50']
    ]);
    Frg2.Opt.SetTable('v_sgp_move_list');
    Frg2.Opt.SetButtons(1,[[-btnGridSettings]]);
    Frg2.Opt.SetWhere('where id_order = :id$i and doctype = :doctype$s order by slash');
    Frg1.InfoArray:=[
      [Caption+ #13#10],
      ['Отображается список актов оприходования и списания, сформированных на основании ревизий СГП.'#13#10+
       'Если поставить галочку "Все форматы" в заголовке окна, то будут ображены акты, созданные для'#13#10+
       'всех форматов изделий, иначе же только акты по тому формату, который выбра в окне отчета по СГП.'#13#10+
       'Также вы можете ограничить период, за который показываются документы, для этого используйте кноку Фильтр в заголовке.'#13#10+
       ''#13#10+
       'Нажмите "+" в левой колонке, чтобы посмотреть состав выбранного акта оприходования или списания.'#13#10
      ]
    ];
  end

  //журнал плановых заказов
  else if FormDoc = myfrm_J_PlannedOrders then begin
    Caption:='Плановые заказы';
    Frg1.Options := Frg1.Options + [myogGridLabels];
    va2 := [
      ['id','_id'],['id_template','_id_template'],['dt','Дата создания','80'],['num','№'],['dt_start','Начало действия','80'],['dt_end','Окончание действия','80'],
      ['dt_change','Дата изменения'],['std','Стд','40','pic'],['templatename','Шаблон','200'],['projectname','Проект','200'],['sum_all','Сумма','100','f=r:']
    ];
    for i := 1 to 12 do
      va2 := va2 + [['sum'+IntToStr(i), MonthsRu[i], '100','f=r:','t=1']];
    Frg1.Opt.SetFields(va2);
    Frg1.Opt.SetTable('v_planned_orders_w_sum');
    Frg1.Opt.SetButtons(1,[
      [btnRefresh],[],[btnView],[btnEdit,User.Role(rOr_J_PlannedOrders_Ch)],[btnCustom_OrderFromTemplate,1],[btnDelete,1],[],[btnGridFilter],[],[btnGridSettings],[],[btnCtlPanel]
    ]);
    Frg1.Opt.SetButtonsIfEmpty([btnCustom_OrderFromTemplate]);
    Frg1.CreateAddControls('1', cntCheck, 'По месяцам', 'ChbMonthsSum', '', 4, yrefC, 130);
    Frg1.Opt.FilterRules := [[], ['dt;dt_start;dt_end;dt_change']];
    Frg1.InfoArray:=[[Caption + '.'#13#10],
      ['Ининформация по имеющимся плановым заказам.'#13#10+
       'Поставьте галочку "По месяцам", чтобы увидеть суммы по заказам за каждый месяц текущего года.'#13#10+
       'Если у вас есть соотвествующие права, вы можете создавать, редактировать, и удалять плановые заказы,'#13#10+
       'используя соответсквующие кнопки.'#13#10+
       'Для управления периодом отображения заказов используйте кнопку фильтра.'#13#10]
    ];
  end
  else if FormDoc = myfrm_Rep_OrderStdItems_Err then begin
    Caption:='Ошибки в справочнике стандартных изделий';
    Frg1.Opt.SetFields([
      ['id$i','_id'],
      ['name_format','Формат','d=200;h'],
      ['name_otgr','Наименование отгрузки','d=200;h'],
      ['name_prod','Наименование производства','d=200;h'],
      ['name_est','Наименование в смете','d=200;h'],
      ['err_otgr$i','Ошибка в отгрузке', '80', 'pic=1:3'],
      ['err_prod$i','Ошибка в производстве', '80', 'pic=1:3']
    ]);
    Frg1.Opt.SetTable('v_std_items_errors');
    Frg1.Opt.SetButtons(1, 'r');
  end
  else if FormDoc = myfrm_J_Tasks then begin
    Frg1.Options := Frg1.Options + [myogGridLabels];
    Caption:='Журнал задач';
    Frg1.Opt.SetFields([
      ['id$i','_id'],
      ['id_user1$i','_id_user1'],
      ['id_user2$i','_id_user2'],
      ['type$s','Вид задачи','150'],
      ['name$s','Задача','200'],
      ['user1$s','Инициатор','120'],
      ['user2$s','Исполнитель','120'],
      ['dt$d','Дата постановки задачи','80'],
      ['dt_beg$d','Дата начала','80'],
      ['dt_planned$d','Плановая дата сдачи','80'],
      ['dt_end$d','Дата сдачи','80'],
      ['state$s','Статус','100'],
      ['confirmed$1','Подтверждена','100','pic'],
      ['orcaption$s','Заказ','200;h'],
      ['itemcaption$s','Изделие','200;h'],
      ['comm1$s','Комментарий инициатора','d=200;h'],
      ['comm2$s','Комментарий исполнителя','d=200;h']
    ]);
    Frg1.Opt.SetTable('v_j_tasks');
    Frg1.Opt.SetButtons(1, [[btnRefresh],[],[btnView],[btnEdit],[btnAdd {, User.Role(rOr_J_Tasks_Ch)}],[btnCopy],[btnDelete],[btnGridFilter],[],[btnGridSettings],[],[btnCtlPanel]]);
//    Frg1.CreateAddControls('1', cntCheck, 'Мои задачи', 'ChbFromMy', '', -1, yrefC, S.IIf(User.Role(rOr_J_Tasks_Ch), 90, 0));
//    Frg1.CreateAddControls('1', cntCheck, 'Задачи для меня', 'ChbForMy', '', -1, yrefC, S.IIf(User.Roles([], [rOr_J_Tasks_Ch, rOr_J_Tasks_VAll]),115,0));
    Frg1.CreateAddControls('1', cntCheck, 'Мои задачи', 'ChbFromMy', '', -1, yrefC, 90, -1);
    Frg1.CreateAddControls('1', cntCheck, 'Задачи для меня', 'ChbForMy', '', -1, yrefC, 115, -1);
    Frg1.CreateAddControls('1', cntCheck, 'Все', 'ChbAll', '', -1, yrefC, 45, -1);
    Frg1.CreateAddControls('1', cntCheck, 'Только не подтвержденные', 'ChbNotConfirmed', '', -1, yrefC, 160);
    //Frg1.ReadControlValues;
{    if not(User.Roles([], [rOr_J_Tasks_Ch, rOr_J_Tasks_VAll])) then begin
      TDBCheckBoxEh(Frg1.FindComponent('ChbForMy')).Checked := True;
      TDBCheckBoxEh(Frg1.FindComponent('ChbForMy')).Enabled := False;
    end;}
    Frg1.InfoArray:=[[Caption + '.'#13#10],
      ['Вы можете поставить задачу другому сотруднику или себе, нажав кнопку "Добавить" и заполнив форму,'#13#10+
       'а также изменять статус и комментарий исполнителя в задачах, поставленных вам, для чего нажмите кнопку редактирования.'#13#10
       ,User.Role(rOr_J_Tasks_Ch) or True
      ],
      ['Вы можете изменять статус и комментарий исполнителя в задачах, поставленных вам, для чего нажмите кнопку редактирования.'#13#10
       ,not User.Role(rOr_J_Tasks_Ch) or True
      ],
      ['Управляйте списком отображаемых задач, используя галочки в панели кнопок, кнопку фильтра, или фильтр в столбцах таблицы.'#13#10
      ]
    ];
  end
  else if FormDoc = myfrm_Rep_ItmNomOverEstimate then begin
    Caption:='Номенклатура сверх смет';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['id_nomencl$i','_id_nomencl','40'],
      ['name$s','Наименование','200;w'],
      ['dt$d','Дата','80'],
      ['qnt$f','Кол-во','60']
    ]);
    Frg1.Opt.SetTable('v_itm_acts_over_estimate');
    Frg1.Opt.FilterRules := [[], ['dt']];
    Frg1.Opt.SetButtons(1, 'rfs');
    Frg1.InfoArray:=[
      ['Список номенклатуры, выданной сверх смет (по актам списания с комментарием "№3")'#13#10],
      ['Если у вас открыта таблифа "Формирование заявок на снабжение", то двойной клик мышкой по номенклатуре установит курсор в ней на той же номенклатурной позиции.']
    ];
  end
  else if FormDoc = myfrm_R_OrderTypes then begin
    Caption:='Типы заказов';
    Frg1.Options := Frg1.Options - [myogSorting];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['pos$i','№','40'],
      ['name$s','Наименование','200'],
      ['need_ref$i','Ссылается на заказ','80','pic'],
      ['active$i','Используется','80','pic']
    ]);
    Frg1.Opt.SetWhere('where id >= 100 order by pos');
    Frg1.Opt.SetTable('order_types');
    Frg1.Opt.DialogFormDoc := myfrm_Dlg_R_OrderTypes;
    Frg1.Opt.SetButtons(1,[[btnRefresh],[], [btnEdit],[btnAdd,1],[btnDelete,1],[],[1001, 'Выше', 'arrow_up'],[1002, 'Ниже', 'arrow_down'],[],[btnGridSettings]]);
    Frg1.InfoArray:=[
    ];
  end
  else if FormDoc = myfrm_R_WorkCellTypes then begin
    Caption:='Типы производственных участков';
    Frg1.Options := Frg1.Options - [myogSorting];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['pos$i','№','40'],
      ['code$s','Код','60'],
      ['name$s','Наименование','200'],
      ['active$i','Используется','80','pic']
    ]);
    Frg1.Opt.SetWhere('where id >= 100 order by pos');
    Frg1.Opt.SetTable('work_cell_types');
    Frg1.Opt.DialogFormDoc := myfrm_Dlg_R_WorkCellTypes;
    Frg1.Opt.SetButtons(1,[[btnRefresh],[], [btnEdit],[btnAdd,1],[btnDelete,1],[],[1001, 'Выше', 'arrow_up'],[1002, 'Ниже', 'arrow_down'],[],[btnGridSettings]]);
    Frg1.InfoArray:=[
    ];
  end
  else if FormDoc = myfrm_J_OrItemsInProd then begin
    Caption:='Изделия в производстве';
    Frg1.Options := Frg1.Options + [myogGridLabels];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['id_order$i','_id_order','40'],
      ['area_short$s','Площадка','80'],
      ['slash','№','120','bt=Паспорт заказа'],
      ['itemname','Изделие','450;h'],
      ['dt_beg','Дата запуска','75'],
      ['dt_otgr','Дата отгрузки','75'],
      ['project','Проект','180;h'],
      ['qnt','Кол-во','80'],
      ['qnt2','Кол-во произведенное','80'],
      ['qnt_inprod','Кол-во в производстве','80'],
      ['qnt_rest','Кол-во оставшееся','80']
    ]);
    Frg1.Opt.SetTable('v_oritms_all_in_prod_detail');
    Frg1.Opt.SetButtons(1, 'rs');
    Frg1.InfoArray:=[[
      Caption+''#13#10+
      'Все изделия, которые запущены в производство, не не приняты на СГП в полном составе.'#13#10
    ]];
  end
  else if FormDoc = myfrm_J_ItmLog then begin
    Caption:='Журнал действий пользователей ИТМ';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['id_doc','_id_doc','40'],
      ['act','_act','40'],
      ['aud','_aud','100'],
      ['log_dates','Дата','75'],
      ['data_time','Время','150'],
      ['name','Пользователь','120'],
      ['user_windows','Логин','120'],
      ['doctype','Вид документа', '160','bt=Просмотреть документ'],
      ['comments','Комментарий','300;h'],
      ['addinfo','Дополнение','300;h'],
      ['commentsfull','_Комментарий слукжебный','300;h']
    ]);
    Frg1.Opt.SetTable('v_itm_log');
    Frg1.Opt.FilterRules := [[], ['log_dates']];
    Frg1.Opt.SetButtons(1, 'rfsp');
    Frg1.InfoArray:=[
    ];
  end
  else if FormDoc = myfrm_J_SnHistory then begin
    Caption := 'Состояние СН на дату';
    va2 := [
      ['id$i','_id','40'],
      ['dt$d','Дата','120'],
      ['state$s','Статус','120'],
      ['supplierinfo$s','Основной поставщик','150'],
      ['qnta0$f','Текущий остаток|ПЩ','60'],
      ['qnta1$f','Текущий остаток|И','60'],
      ['qnta2$f','Текущий остаток|ДМ','60'],
      ['qnt$f','Текущий остаток|Всего','60'],
      ['rezerva0$f','Текущий резерв|ПЩ','40'],
      ['rezerva1$f','Текущий резерв|И','40'],
      ['rezerva2$f','Текущий резерв|ДМ','40'],
      ['rezerv$f','Текущий резерв|Всего','40'],
      ['qnt_onway$f','В пути','40'],
      ['qnt_in_processing$f','В обработке','40'],
      ['planned_need_days$i','Период закупки','40','t=3'],
      ['qnt_order$f','Заказ|Кол-ко','60','t=3'],
      ['to_order$i','Заказ|В заявку','40', 'chb','t=3'],
      ['need$f','Потребность|Мин.','60'],
      ['need_p$f','Потребность|Плановая','60'],
      ['price_check$f','Стоимость|Контрольная цена','60'],
      ['price_main$f','Стоимость|Цена','60'],
      ['qnt_pl1$f','Плановый резерв|1''60'],
      ['qnt_pl2$f','Плановый резерв|2''60'],
      ['qnt_pl3$f','Плановый резерв|3''60'],
      ['qnt_pl$f', 'Плановый резерв|Всего','60']
    ];
    Frg1.Opt.SetFields([['name','Наименование','300;h']] + va2);
    Frg1.Opt.SetTable('v_spl_history', '', 'id');
    Frg2.Opt.SetFields(va2);
    Frg2.Opt.SetTable('spl_history');
    Frg2.Opt.SetWhere('where id = :id$i');
    Frg2.Opt.Caption := 'История по номенклатуре';
    //01-02-2025 00:10:25 Заказ
    Q.QSetContextValue('spl_history_date', IncSecond(EncodeDateTime(
      StrToInt(Copy(AddParam, 7, 4)), StrToInt(Copy(AddParam, 4, 2)), StrToInt(Copy(AddParam, 1, 2)),
      StrToInt(Copy(AddParam, 12, 2)), StrToInt(Copy(AddParam, 15, 2)), StrToInt(Copy(AddParam, 18, 2)), 0
    )));
  end;
  ;

  //--------------------------------------------------
  if Length(Frg1.Opt.Sql.FieldsDef) = 0 then begin
    MyWarningMessage('Ошибка! FormDoc не найден или основной грид не задан!');
    Exit;
  end;
  if Length(Frg2.Opt.Sql.FieldsDef) > 0 then
    Frg2.Prepare;
  Frg1.Grid2 := Frg2;
  Frg1.Prepare;

  if (FormDoc = myfrm_J_Orders_SEL_1) then begin
    //окно выбора заказа, второй переменной в AddParam передаем строку айди через ;, которые надо отметить
    //!!!сделать заполнение комбобоксов из массива по ИД
    if Length(AddParam[1]) > 0 then begin
      Frg1.MemTableEh1.DisableControls;
      Frg1.MemTableEh1.First;
      while not Frg1.MemTableEh1.Eof do begin
        if Pos(';'+Frg1.DBGridEh1.SelectedRows.DataSet.FieldByName('id').AsString+';', ';'+AddParam[1]+';') > 0
          then Frg1.DBGridEh1.SelectedRows.CurrentRowSelected := True;
        Frg1.MemTableEh1.Next;
      end;
      Frg1.MemTableEh1.First;
      Frg1.MemTableEh1.EnableControls;
    end;
  end;


  Frg1.RefreshGrid;
  Result := True;
end;


procedure TFrmXGlstMain.Timer_AfterStartTimer(Sender: TObject);
begin
  inherited;
//  Frg1.Opt.SetWhere('');
//  Frg1.RefreshGrid;
end;

{=========================  СОБЫТИЯ ПЕРВОГО ГРИДА =============================}

procedure TFrmXGlstMain.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
var
  i, j: Integer;
  v: Variant;
  sta: TStringDynArray;
  va: TVarDynArray;
  b: Boolean;
begin
  if fMode <> fNone then begin
    //кнопки Просмотр, Редактирование, Дабавление, копирование
    if FormDoc = myfrm_R_Test then
      Wh.ExecDialog(myfrm_Dlg_R_StdProjects, Self, [], fMode, Fr.ID, null);

    if (FormDoc = myfrm_J_Error_Log) and (fMode = fDelete) then begin
      Q.QExecSql('delete from adm_error_log where id = :id$i', [Fr.ID]);
      Fr.RefreshGrid;
    end;
    if (FormDoc = myfrm_J_Error_Log) and (fMode = fView) then
      TDlg_J_Error_Log.Create(Self, myfrm_Dlg_J_Error_Log, [myfoSizeable], fNone, Fr.ID, null);
    if FormDoc = myfrm_R_Organizations then
      Wh.ExecDialog(myfrm_Dlg_R_Organizations, Self, [], fMode, Fr.ID, null);
    if FormDoc = myfrm_R_Locations then
      Wh.ExecDialog(myfrm_Dlg_R_Locations, Self, [], fMode, Fr.ID, null);
    if FormDoc = myfrm_R_CarTypes then
      Wh.ExecDialog(myfrm_Dlg_R_CarTypes, Self, [], fMode, Fr.ID, null);



    if FormDoc = myfrm_J_Accounts then
      Wh.ExecDialog(myfrm_Dlg_SnCalendar, Self, [], fMode, Fr.ID, null);
    if FormDoc = myfrm_J_Payments then
      Wh.ExecDialog(myfrm_Dlg_SnCalendar, Self, [], fMode, Fr.GetValue('aid'), null{AddInfo});
    if FormDoc = myfrm_R_GrExpenseItems then
      Wh.ExecDialog(myfrm_Dlg_R_GrExpenseItems, Self, [], fMode, Fr.ID, null);
    if FormDoc = myfrm_R_ExpenseItems then
      Wh.ExecDialog(myfrm_Dlg_RefExpenseItems, Self, [], fMode, Fr.ID, null);
    if FormDoc = myfrm_R_Suppliers then
      Wh.ExecDialog(myfrm_Dlg_RefSuppliers, Self, [], fMode, Fr.ID, null);
    if FormDoc = myfrm_R_Suppliers_SELCH then
      Wh.ExecDialog(myfrm_Dlg_RefSuppliers, Self, [], fMode, Fr.ID, null);
    if FormDoc = myfrm_Rep_SnCalendar_Transport then
      Wh.ExecDialog(myfrm_Dlg_SnCalendar, Self, [], fView, ID, null);
    if FormDoc = myfrm_Rep_SnCalendar_AccMontage then
      Wh.ExecDialog(myfrm_Dlg_SnCalendar, Self, [], fView, ID, null);
    if FormDoc = myfrm_R_Bcad_Units then
      Wh.ExecDialog(myfrm_Dlg_Bcad_Units, Self, [], fMode, Fr.ID, null);
    if ((FormDoc = myfrm_J_OrPayments) or (FormDoc = myfrm_J_OrPayments_N)) and (Tag = btnAdd) then begin
       //для заказов - заказы по кнопке Add - добавить платеж к текущей записи на сумму остатка
       if TFrmBasicInput.ShowDialog(Self, '', [], fAdd, '~Платёж', 150, 60,
          [[cntDEdit, 'Дата', ':'],[cntNEdit, 'Сумма', '1:1000000000:2']],
          [Date, Frg1.GetValue('restsum')],
          va, [['']], nil
        ) < 0 then Exit;
      Q.QCallStoredProc('p_Or_Payment' + S.IIfStr(FormDoc = myfrm_J_OrPayments_N, '_n'), 'IdOrder$i;PSum$f;PDt$d;PAdd$i', [Fr.ID, va[1], va[0], 1]);
      if Pos('Н', Frg1.GetValueS('ornum')) = 1 then
        Orders.FinalizeOrder(Fr.ID, myOrFinalizePay);
      Fr.RefreshRecord;
      if Fr.DBGridEh1.RowDetailPanel.Visible then
        Frg2.RefreshGrid;
    end;



    if FormDoc = myfrm_R_Workers then
      Wh.ExecDialog(myfrm_Dlg_R_Workers, Self, [], fMode, Fr.ID, null);
    if FormDoc = myfrm_J_WorkerStatus then
      Wh.ExecDialog(myfrm_Dlg_WorkerStatus, Self, [], fMode, Fr.ID, VarArrayOf([Fr.GetValueS('workername'), '', '', null]));
    if FormDoc = myfrm_R_Jobs then
      Wh.ExecDialog(myfrm_Dlg_R_Jobs, Self, [], fMode, Fr.ID, null);
    if FormDoc = myfrm_R_TurvCodes then
      Wh.ExecDialog(myfrm_Dlg_R_TurvCodes, Self, [], fMode, Fr.ID, null);
    if FormDoc = myfrm_R_Divisions then
      Wh.ExecDialog(myfrm_Dlg_R_Divisions, Self, [], fMode, Fr.ID, null);
    if FormDoc = myfrm_R_Candidates_Ad_SELCH then
      Wh.ExecDialog(myfrm_Dlg_R_Candidates_Ad, Self, [], fMode, Fr.ID, null);
    if FormDoc = myfrm_J_Candidates then
      Wh.ExecDialog(myfrm_Dlg_Candidate, Self, [], fMode, Fr.ID, null);
    if (FormDoc = myfrm_J_Turv) and (fMode in [fEdit, fView]) then
      Wh.ExecDialog(myfrm_Dlg_Turv, Self, [], fMode, Fr.ID, null);
    if (FormDoc = myfrm_J_Turv) and (fMode in [fAdd]) then
      Wh.ExecDialog(myfrm_Dlg_AddTurv, Self, [], fMode, Fr.ID, null);
    if (FormDoc = myfrm_J_Turv) and (fMode in [fDelete]) then
      if Turv.DeleteTURV(Fr.ID) then
        Refresh;
    if (FormDoc = myfrm_J_Payrolls) and (fMode in [fEdit, fView]) then
      Wh.ExecDialog(myfrm_Dlg_Payroll, Self, [], fMode, Fr.ID, null);
    if (FormDoc = myfrm_J_Payrolls) and (fMode = fAdd) then
      //~Dlg_CreatePayroll.ShowDialog(Self, 1);
    if (FormDoc = myfrm_J_Payrolls) and (fMode = fDelete) then begin
      if Q.DBLock(True, myfrm_Dlg_Payroll, Fr.ID)[0] <> True  then
        Exit;
      if (MyQuestionMessage(
        'Будет удалена зарплатная ведомость'#13#10 +
        S.IIFStr(Fr.GeTValueS('workername') = '',
          'по подразделению "' + Fr.GeTValueS('divisionname') + '"'#13#10,
          'по работнику "' + Fr.GeTValueS('workername') +  '"'#13#10 + '(подразделение "' + Fr.GeTValueS('divisionname') + '"'#13#10
          ) +
        'за период с ' + Fr.GeTValueS('dt1') +  ' по ' + Fr.GeTValueS('dt2') + #13#10 + #13#10 + '.' +
        'Продолжить?'
      ) = mrYes)
      and
      (MyQuestionMessage(
        'Удалить ведомость?'
      ) = mrYes)
        then begin
          Q.QExecSql('delete from payroll where id = :id$i', [Fr.ID], True);
          Refresh;
        end;
      Q.DBLock(False, myfrm_Dlg_Payroll, Fr.ID);
    end;



    if FormDoc = myfrm_R_StdProjects then
      Wh.ExecDialog(myfrm_Dlg_R_StdProjects, Self, [], fMode, Fr.ID, null);
    if FormDoc = myfrm_R_Bcad_Groups then
      Wh.ExecDialog(myfrm_Dlg_Bcad_Groups, Self, [], fMode, Fr.ID, null);
    if FormDoc = myfrm_R_Bcad_Units then
      Wh.ExecDialog(myfrm_Dlg_Bcad_Units, Self, [], fMode, Fr.ID, null);
    if FormDoc = myfrm_R_Bcad_Nomencl then
      Wh.ExecDialog(myfrm_Dlg_EditNomenclatura, Self, [], fMode, Fr.ID, null);
    if FormDoc = myfrm_R_OrderTemplates then
      Wh.ExecDialog(myfrm_Dlg_Order, Self, [], fMode, Fr.ID, 1);
    if FormDoc = myfrm_R_ComplaintReasons then
      Wh.ExecDialog(myfrm_Dlg_R_ComplaintReasons, Self, [], fMode, Fr.ID, null);
    if FormDoc = myfrm_R_DelayedInprodReasons then
      Wh.ExecDialog(myfrm_Dlg_R_DelayedInprodReasons, Self, [], fMode, Fr.ID, null);
    if FormDoc = myfrm_R_RejectionOtkReasons then
      Wh.ExecDialog(myfrm_Dlg_R_RejectionOtkReasons, Self, [], fMode, Fr.ID, null);
    if FormDoc = myfrm_Rep_Order_Complaints then
      Wh.ExecDialog(myfrm_Dlg_Order, Self, [], fView, Fr.ID, null);
    if FormDoc = myfrm_J_InvoiceToSgp then
      Wh.ExecDialog(myfrm_Dlg_InvoiceToSgp, Self, [], fMode, Fr.ID,
        VarArrayOf([S.IIf(fMode = fAdd, 0, Fr.GetValue('state')), Fr.GetControlValue('CbArea'), Fr.GetValue('ornum')])
      );
    if FormDoc = myfrm_R_EstimatesReplace then
      Dlg_R_EstimateReplace.ShowDialog(Fr.GetValue('id_old'), fMode);
    if FormDoc = myfrm_R_Spl_Categoryes then
      Wh.ExecDialog(myfrm_Dlg_R_Spl_Categoryes, Self, [], fMode, Fr.ID, null);
    if FormDoc = myfrm_R_Itm_Units then
      Wh.ExecDialog(myfrm_Dlg_R_Itm_Units, Self, [], fMode, Fr.ID, null);
    if FormDoc = myfrm_R_Itm_Suppliers then  //!!!
      TFrmDlgRItmSupplier.Show(Self, myfrm_Dlg_R_Itm_Suppliers, [myfoMultiCopy, myfoDialog, myfoSizeable], fMode, Fr.ID, null);
    if (FormDoc = myfrm_J_Orders) and (Fr.CurrField = 'ornum') then
      Sys.ExecFile(Module.GetPath_Order(IntToStr(YearOf(Fr.GetValueD('dt_beg'))), Fr.GetValue('in_archive')) + '\' + Fr.GetValueS('path'));
    if (FormDoc = myfrm_R_StdPspFormats) and ((fMode in [fAdd, fCopy]) or (Fr.ID > 1)) then
      Wh.ExecDialog(myfrm_Dlg_R_StdPspFormats, Self, [], fMode, Fr.ID, null);
    if FormDoc = myfrm_J_Devel then
      Wh.ExecDialog(myfrm_Dlg_J_Devel, Self, [], fMode, Fr.ID, null);
    if (FormDoc = myfrm_R_Itm_Nomencl) and (fMode = fAdd) then
      Wh.ExecDialog(myfrm_Dlg_EditNomenclatura, Self, [], fMode, Fr.ID, null);
    if (formDoc = myfrm_R_Itm_Nomencl) and (fMode = fEdit) then
      if Orders.RenameNomenclGlobal(null, Fr.ID) then
        Refresh;

    if (FormDoc = myfrm_J_PlannedOrders) then
      TFrmOWPlannedOrder.Show(Self, myfrm_Dlg_PlannedOrder, [myfoSizeable, myfoMultiCopy], fMode, Fr.ID, null);
    if FormDoc = myfrm_J_Tasks then
      Wh.ExecDialog(myfrm_Dlg_J_Tasks, Self, [], fMode, Fr.ID, null);
{    if FormDoc = myfrm_R_OrderTypes then
      Wh.ExecDialog(myfrm_Dlg_R_OrderTypes, Self, [], fMode, Fr.ID, null);
    if FormDoc = myfrm_R_WorkCellTypes then
      Wh.ExecDialog(myfrm_Dlg_R_OrderTypes, Self, [], fMode, Fr.ID, null);}
  end
  //все остальные кнопки
  else if (FormDoc = myfrm_J_Accounts)and(Tag = btnAdd_Account_TO) then begin
    Wh.ExecDialog(myfrm_Dlg_SnCalendar, Self, [], fAdd, -1, 1);
  end
  else if (FormDoc = myfrm_J_Accounts)and(Tag = btnAdd_Account_TS) then begin
    Wh.ExecDialog(myfrm_Dlg_SnCalendar, Self, [], fAdd, -1, 2);
  end
  else if (FormDoc = myfrm_J_Accounts)and(Tag = btnAdd_Account_M) then begin
    Wh.ExecDialog(myfrm_Dlg_SnCalendar, Self, [], fAdd, -1, 3);
  end
  else if ((FormDoc = myfrm_J_Accounts)or(FormDoc = myfrm_J_Payments))and(Tag = btnCustom_AccountToClipboard) then begin
    //в ПК в счетах и платежах - скоировать в буфер обмена имя файла счета; если счета нет или он не один, то буфер очистится
    Clipboard.AsText :='';
    try
    sta:=TDirectory.GetFiles(Module.GetPath_Accounts_A(Fr.GetValue('filename')));
    if High(sta) = 0 then Clipboard.AsText :=sta[0];
    except
    end;
  end
  else if (FormDoc = myfrm_J_Payments)and(Tag = btnCustom_RunPayments) then begin
    //для платежей (платежный календарь) - отметить все видимые оплаченными
    j:= 0;
    b:= False;
    //посчитаем сколько неоплаченных и согласованных в отфильтрованных записях (не обновляем, считаем по данным грида)
    for i:=0 to Fr.GetCount - 1 do
      begin
        if S.NNum(Fr.GetValue('pstatus', i)) = 0
           //2024-01-10 - можно проводить несогласованные!!!
           //and
           //(MemTableEh1.RecordsView.Rec[i].DataValues['agreed1', dvvValueEh] = 1)and
           //(MemTableEh1.RecordsView.Rec[i].DataValues['agreed2', dvvValueEh] = 1)
         then inc(j);
      end;
    if j = 0
      then MyInfoMessage('Нет непроведенных платежей')
      else b:= myMessageDlg('Провести ' + IntTostr(j) + ' платежей?', mtconfirmation, [mbYes, mbNo]) = mrYes;
    //если есть неоплаченные и подтвердили проведение платежа
    if b then begin
      //проход по отфильтрованным
      for i:=0 to Fr.GetCount - 1 do
        begin
          if S.NNum(Fr.GetValue('pstatus', i)) = 0
           //2024-01-10 - можно проводить несогласованные!!!
             {and
             (MemTableEh1.RecordsView.Rec[i].DataValues['agreed1', dvvValueEh] = 1)and
             (MemTableEh1.RecordsView.Rec[i].DataValues['agreed2', dvvValueEh] = 1)}
           then begin                                                                                        //and agreed1=1 and agreed2=1
             //если не оплаечено и согласовано, то проведем оплату
             Q.QExecSql('update sn_calendar_payments set status=1, dtpaid=:pdtpaid$d where id=:id$i and status <> 1',
               [Date, Fr.GetValue('pid', i)]);
           end;
        end;
      //обновим.
      Fr.RefreshGrid;
    end;
  end
  else if (FormDoc = myfrm_R_Holideys) and (Tag = btnCustom_LoadFromInet) and (S.Nst(Fr.GetControlValue('CbYear')) <> '') and
    (MyQuestionMessage('Загрузить производственный календарь из сети Интернет'#13#10'(с сайта http://xmlcalendar.ru)?'#13#10'При этом данные будут заменены.') = mrYes) then begin
     case Tasks.GetProductionCalendar(S.NInt(Fr.GetControlValue('CbYear'))) of
       1: begin
           Fr.RefreshGrid;
           MyInfoMessage('Календарь успешно загружен.')
         end;
       0: MyInfoMessage('Изменений в календаре не было.')
       else MyInfoMessage('Ошибка загрузки календаря!');
     end;
  end
  else if (FormDoc = myfrm_Rep_W_Payroll) and (Tag = btnGo) then
    Fr.RefreshGrid


  else if (FormDoc = myfrm_R_BCad_Nomencl) and (Tag = btnCustom_FindInEstimates) then begin
    Wh.ExecDialog(myfrm_Dlg_Or_FindNameInEstimates, Self, [], fNone, Fr.ID, null);
  end
  else if FormDoc = myfrm_Rep_Sgp2 then begin
    if Tag = btnCustom_Revision then begin
      Wh.ExecDialog(myfrm_Dlg_Sgp_Revision, Self, [], fEdit, 0, null);
    end
    else if Tag = btnCustom_JRevisions then begin
      Wh.ExecReference(myfrm_J_Sgp_Acts, Self, [], 0);
    end
  end
  else if (formDoc = myfrm_J_PlannedOrders)and(Tag = btnCustom_OrderFromTemplate) then begin
    if Orders.OpenFromTemplate(Self, False, v) then
      TFrmOWPlannedOrder.Show(Self, myfrm_Dlg_PlannedOrder, [{myfoDialog, }myfoSizeable, myfoMultiCopy], fAdd, null, S.NullIfEmpty(v));
  end
  else if (formDoc = myfrm_Rep_PlannedMaterials) and (Tag = btnRefresh) then begin
    if not S.IsDateTime(S.NSt(Fr.GetControlValue('DeBeg'))) then
      Exit;
    Orders.CrealeEstimateOnPlannesOrders(Fr.GetControlValue('DeBeg'));
    Fr.RefreshGrid;
  end
  else if A.InArray(FormDoc, [myfrm_R_OrderTypes, myfrm_R_WorkCellTypes]) then begin
    if (Tag = 1001) or (Tag = 1002) then begin
//      if (FormDoc = myfrm_R_WorkCellTypes) and (Fr.GetValue('posstd') <> null) then
//        Exit;
      Q.QCallStoredProc('P_ExchangePositions', 't$s;f$s;p$i;d$i', [Fr.Opt.Sql.Table, 'pos', Fr.GetValue('pos'), S.IIf(Tag = 1001, -1, 1)]);
      Fr.RefreshGrid;
    end;
  end
  else inherited;

end;

procedure TFrmXGlstMain.Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
  if FormDoc = myfrm_J_Error_Log then
     TDlg_J_Error_Log.Create(Self, myfrm_Dlg_J_Error_Log, [myfoSizeable], fNone, Fr.ID, null);

  //платежный календарь - счета
  if (FormDoc = myfrm_J_Accounts) or (FormDoc = myfrm_J_Payments) then begin
    if TCellButtonEh(Sender).Hint = 'Показать счет'
      then Sys.OpenFileOrDirectory(Module.GetPath_Accounts_A(Fr.GetValue('filename')), 'Файл счета не найден!');
    if TCellButtonEh(Sender).Hint = 'Показать заявку'
      then Sys.OpenFileOrDirectory(Module.GetPath_Accounts_Z(Fr.GetValue('filename')), 'Файл заявки не найден!');
    if TCellButtonEh(Sender).Hint = 'Дата оприходования' then begin
      if not Fr.RefreshRecord then
        Exit;
      if MyQuestionMessage(S.IIf(Fr.GetValue = null, 'Оприходовать?', 'Отменить оприходование?')) <> mrYes then
        Exit;
      Q.QExecSql('update sn_calendar_accounts set receiptdt = :receiptdt$d where id=:id$i',
        [S.IIf(Fr.GetValue = null, Date, null), Fr.GetValue('aid')], False
      );
      Fr.RefreshRecord;
    end;
  end;
  if (FormDoc = myfrm_J_Orders_SEL_1)or(FormDoc = myfrm_J_OrPayments)or(FormDoc = myfrm_J_OrPayments_N) then begin
    //покажем паспорт заказа
    Wh.ExecDialog(myfrm_Dlg_Order, Self, [], fView, Fr.ID, null);
  end;
  if (FormDoc = myfrm_R_Itm_Nomencl) then begin
    //тут не обновляется список номенклатуры при ищзменениях в диаллоге, тк он не модальный и обновление в нем не реализовано
    if TCellButtonEh(Sender).Hint = 'Движение по номенклатуре' then
      TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_MoveNomencl, [myfoSizeable, myfoDialog], fView, Fr.ID, VarArrayOf([Fr.GetValueS('name'), Fr.GetValueS('name_unit')]));
    if TCellButtonEh(Sender).Hint = 'Поставщики' then begin
      Wh.ExecDialog(myfrm_Dlg_SupplierMinPart, Self, [myfoSizeable], S.IIf(User.Role(rOr_Other_R_MinRemains_Ch_Suppl), fEdit, fView), Fr.ID, VarArrayOf([Fr.GetValueS('name'), Fr.GetValueS('name_unit')]));
    end;
    if TCellButtonEh(Sender).Hint = 'Приходные накладные' then
      TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_InBillList, [myfoSizeable, myfoDialog], fView, Fr.ID, VarArrayOf([Fr.GetValueS('name'), Fr.GetValueS('name_unit')]));
    if TCellButtonEh(Sender).Hint = 'Файлы' then begin
      TFrmODedtNomenclFiles.ShowDialog(Self, Fr.ID);
    end;
  end;

  if (FormDoc = myfrm_J_ItmLog) then begin
    Orders.ViewItmDocumentFromLog(Self, Fr.ID);
  end;
  if (FormDoc = myfrm_R_Or_ItmExtNomencl)and(TCellButtonEh(Sender).Hint = 'Движение номенклатуры') then begin
    Wh.ExecDialog(myfrm_Dlg_Spl_InfoGrid_MoveNomencl, Self, [myfoModal, myfoSizeable], S.IIf(User.Role(rOr_Other_R_MinRemains_Ch_Suppl), fEdit, fView),
      Fr.GetValue('id_nomencl'), VararrayOf([Fr.GetValueS('name'), ''])
    );
  end;
  if (FormDoc = myfrm_R_Or_ItmExtNomencl)and(TCellButtonEh(Sender).Hint = 'Расхождения по заказам') then begin
    Wh.ExecDialog(myfrm_Dlg_Spl_InfoGrid_DiffInOrder, Self, [myfoModal, myfoSizeable], S.IIf(User.Role(rOr_Other_R_MinRemains_Ch_Suppl), fEdit, fView),
      Fr.GetValue('id_nomencl'), VararrayOf([Fr.GetValueS('name'), ''])
    );
  end;
  if A.InArray(FormDoc, [myfrm_J_OrItemsInProd]) then begin
    //диалог просмотра заказа
    Wh.ExecDialog(myfrm_Dlg_Order, Self, [], fView, Fr.GetValue('id_order'), null);
  end;
end;

procedure TFrmXGlstMain.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
var
  b1, b2, b3: Boolean;
begin
  if ((FormDoc = myfrm_J_Accounts)or(FormDoc = myfrm_J_Payments)) and Fr.IsNotEmpty then begin
//    (rPC_A_ChSelf,'Модуль "Платежный календарь"','Счета','Создание счета по доступным категориям, редактирование и удаление своих счетов'),
//    (rPC_A_ChSelfCat,'Модуль "Платежный календарь"','Счета','Создание/Редактирование/удаление счета по доступным категориям'),
    b1:= False; b2:= False; b3:= False;
    //создание счета - любые права на создание/редактирование
    if (User.Roles([], [rPC_A_ChSelf, rPC_A_ChSelfCat, rPC_A_ChAll])) then b1:= True;
    //редактирование всех
    if (User.Roles([], [rPC_A_ChAll])) then b2:= True;
    //редактирование по категории
    if (not b2) and (User.Roles([], [rPC_A_ChSelfCat])) and (S.NNum(Fr.GetValue('useravail')) = 1) then b2:= True;
    //редактирование только своих
    if (not b2) and (User.Roles([], [rPC_A_ChSelf])) and (S.NSt(Fr.GetValue('username')) = User.GetName) then b2:= True;
    //удаление только несогласованных и не оплеченных
    if b2 then b3 := (S.NNum(Fr.GetValue('agreed1')) = 0)and(S.NNum(Fr.GetValue('agreed2')) = 0)
      and(S.NNum(Fr.GetValue(S.IIf(FormDoc = myfrm_J_Accounts, 'paidsum', 'psum'))) = 0);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, btnEdit, null, b2);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, btnCopy, null, b2);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, btnDelete, null, b3);
  end;

  if (FormDoc = myfrm_J_Turv) and Fr.IsNotEmpty then
    //для турв, на редактирование только указанным пользователям и только если период не закрыт
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, btnEdit, null,
      (Fr.GetValueI('commit') <> 1) and (User.Roles([], [rW_J_Turv_TP, rW_J_Turv_TS]) or S.InCommaStr(IntToStr(User.GetId), Fr.GetValueS('editusers')))
    );

  if FormDoc = myfrm_J_Tasks then begin
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, btnView, null,
      (Fr.GetValue('id_user2') = User.GetId) or (Fr.GetValue('id_user1') = User.GetId) or User.Role(rOr_J_Tasks_VAll));
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, btnCopy, null, Fr.GetValue('id_user1') = User.GetId);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, btnDelete, null, Fr.GetValue('id_user1') = User.GetId);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, btnEdit, null, (Fr.GetValue('id_user2') =
      User.GetId) or (Fr.GetValue('id_user1') = User.GetId));
  end;

  if FormDoc = myfrm_J_InvoiceToSgp then begin
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, btnAdd, null, User.Role(rOr_J_InvoiceToSgp_Ch_M) and (Fr.GetControlValue('CbArea') <> ''));
  end;

end;

function  TFrmXGlstMain.Frg1OnFilterExecute(var Fr: TFrDBGridEh; const No: Integer; var Handled: Boolean): string;
begin
end;

procedure TFrmXGlstMain.Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
var
  st: string;
  dt: TDateTime;
begin
  if (FormDoc = myfrm_R_Test) then begin
    //показать неактивные
    Fr.SetSqlParameters('active$i;nouseparam', [S.IIf(Cth.GetControlValue(Fr, 'Chb2') = 1, 0, 1), 0]);
//    Fr.SetSqlParameters('active$i', [S.IIf(Cth.GetControlValue(Fr, 'Chb2') = 1, 0, 1)]);
  end

  else if FormDoc = myfrm_J_Error_Log then
    Fr.SetSqlParameters('ide$i;userlogin$s', [
      S.IIf(TDBCheckBoxEh(Fr.FindComponent('ChbDebug')).Checked, 1, 0), S.IIf(TDBCheckBoxEh(Fr.FindComponent('ChbMy')).Checked, User.GetLogin, '%')
    ])


  else if FormDoc = myfrm_J_Accounts then
    SqlWhere := A.ImplodeNotEmpty([SqlWhere, S.IIfStr(User.Roles([],  [rPC_A_VSelfCat], [rPC_A_VAll]), 'anyinstr(useravail, ' + IntToStr(User.GetID) + ')=1')], ' and ')
  else if A.InArray(FormDoc, [myfrm_Rep_SnCalendar_Transport, myfrm_Rep_SnCalendar_AccMontage]) then
    Fr.SetSqlParameters('dt_beg;dt_end;i', [
        S.IIf(Cth.DteValueIsDate(TDBDateTimeEditEh(Fr.FindComponent('DeBeg'))), TDBDateTimeEditEh(Fr.FindComponent('DeBeg')).Value, IncMonth(Date, +1000)),
        S.IIf(Cth.DteValueIsDate(TDBDateTimeEditEh(Fr.FindComponent('DeEnd'))), TDBDateTimeEditEh(Fr.FindComponent('DeEnd')).Value, IncMonth(Date, +1000)),
        1])

  else if (FormDoc = myfrm_J_Turv) then begin
    SqlWhere:= A.ImplodeNotEmpty([SqlWhere, S.IIfStr(Fr.GetControlValue('ChbSelf') = 1, 'IsStInCommaSt(' + IntToStr(User.GetId) + ', editusers) = 1'),
      S.IIfStr(A.ImplodeNotEmpty([
        S.IIfStr(Fr.GetControlValue('ChbCurrent') = 1, 'dt1 = ''' + S.SQLdate(Turv.GetTurvBegDate(Date)) + ''''),
        S.IIfStr(Fr.GetControlValue('ChbPrevious') = 1, 'dt1 = ''' + S.SQLdate(Turv.GetTurvBegDate(IncDay(Turv.GetTurvBegDate(Date), -1))) + '''')],
        ' or '), '('#0')')], ' and '
    );
  end
  else if (FormDoc = myfrm_J_Payrolls) then begin
    SqlWhere:= A.ImplodeNotEmpty([SqlWhere, S.IIfStr(Fr.GetControlValue('ChbDivisions') = 1, 'id_worker is null'),
      S.IIfStr(A.ImplodeNotEmpty([
        S.IIfStr(Fr.GetControlValue('ChbCurrent') = 1, 'dt1 = ''' + S.SQLdate(Turv.GetTurvBegDate(Date)) + ''''),
        S.IIfStr(Fr.GetControlValue('ChbPrevious') = 1, 'dt1 = ''' + S.SQLdate(Turv.GetTurvBegDate(IncDay(Turv.GetTurvBegDate(Date), -1))) + '''')],
        ' or '), '('#0')')], ' and '
    );
  end
  else if FormDoc = myfrm_R_Holideys then
    Fr.SetSqlParameters('year$i', [Cth.GetControlValue(Fr, 'CbYear')])
  else if FormDoc = myfrm_Rep_W_Payroll then begin
    st := Fr.GetControlValue('CbPeriod');
    if st =''
      then dt := Date
      else dt := EncodeDate(StrToInt(Copy(st,7,4)), StrToInt(Copy(st,4,2)), StrToInt(Copy(st,1,2)));
    Fr.SetSqlParameters('dt1$d', [dt]);
  end



  else if FormDoc = myfrm_R_Bcad_Nomencl then
    SqlWhere := S.IIfStr(Cth.GetControlValue(Fr, 'ChbFromItm') = 1, 'id_itm is not null')
  else if FormDoc = myfrm_Rep_Order_Complaints then
    SqlWhere := A.ImplodeNotEmpty([SqlWhere, 'id_type = 2', 'id > 0'], ' and ')
  else if FormDoc = myfrm_J_InvoiceToSgp then
    Fr.SetSqlParameters('area$i', [S.NNum(Fr.GetControlValue('CbArea'))])
  else if FormDoc = myfrm_R_Itm_InGroup_Nomencl then
    Fr.SetSqlParameters('id_group$i', [AddParam])
  else if FormDoc = myfrm_J_Orders_SEL_1 then
    Fr.SetSqlParameters('proekt', [AddParam[0]])
  else if FormDoc = myfrm_Rep_Sgp2 then
    SqlWhere := A.ImplodeNotEmpty([SqlWhere, S.IIfStr(Cth.GetControlValue(Fr, 'ChbNot0') = 1, 'qnt <> 0')], ' and ')
  else if FormDoc = myfrm_J_Sgp_Acts  then
    SqlWhere:= A.ImplodeNotEmpty([SqlWhere, S.IIf(Fr.GetControlValue('ChbAllFormats') = 0, 'id_format = ' + IntToStr(AddParam), '')], ' and ')
  else if FormDoc = myfrm_J_Tasks then begin
    SqlWhere := A.ImplodeNotEmpty(
      [SqlWhere,
       S.IIfStr(Cth.GetControlValue(Fr, 'ChbNotConfirmed') = 1, 'confirmed <> 1'),
       S.IIfStr(Cth.GetControlValue(Fr, 'ChbFromMy') = 1, 'id_user1 = :id_user1$i'),
       S.IIfStr(Cth.GetControlValue(Fr, 'ChbForMy') = 1, 'id_user2 = :id_user2$i')
      ],
      ' and '
    );
    Fr.SetSqlParameters('id_user1$i;id_user2$i', [User.GetId, User.GetId]);
  end
  else if FormDoc = myfrm_R_Itm_Schet then
    Fr.SetSqlParameters('id_schet$i', [AddParam])
  else if FormDoc = myfrm_R_Itm_InBill then
    Fr.SetSqlParameters('id_inbill$i', [AddParam])
  else if A.InArray(FormDoc, [myfrm_R_Itm_MoveBill, myfrm_R_Itm_OffMinus, myfrm_R_Itm_PostPlus, myfrm_R_Itm_Act]) then
    Fr.SetSqlParameters('id_doc$i', [AddParam])
  ;
end;

procedure TFrmXGlstMain.Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
var
  ReadOnly, b: Boolean;
  st: string;
  i: Integer;
  FHandled: Boolean;
  Updated: Boolean;
begin

  FHandled := True;
  if True then begin
    if (FormDoc = myfrm_R_Test) then begin
      //пример изменения данных!!! (в данном случае чекбоксса)
      //обновим запись, выйдем с сообщением если она была удалена
      bbb:=true;
      if not Fr.RefreshRecord then Exit;
      bbb:=true;
      //проверим, не стала ли текущая ячейка нередактируемой, вследствви обновления данных текущей строки из бд
      Frg1GetCellReadOnly(Fr, No, Sender, ReadOnly);
      if ReadOnly then begin
        //если редактировать нельзя, выходим (Cancel делать не обязательно если ставим Handled)
        Handled := True;
        bbb:=false;
        Exit;
      end;
  //    if TColumnEh(Sender).ReadOnly then MyInfoMessage('!!!');
      //установим значение в таблице. это не нужно, если потом перечитываем запись.
      //во внутреннем отфильтрованном массиве (важно: Fr.RecNo - 1 !). при этом, фильтр в столбце при изменении
      //не сработает, даже если сделать DefaultApplyFilter (но сработает при  RefreshRecord))
  //    Fr.SetValue('active', Fr.RecNo - 1, True, Value);
      //или в текущей строке, по умолчанию делаем Post (фильтр в столбце сработает)
      Fr.SetValue('active', Value);
      //изменим значение в бд (строки к числам приводить не обязательно)
      Q.QExecSql('update ref_test2 set active = :active$i where id = :id$i', [Value, Fr.ID]);
      //если не обновлять, не изменятся зависимые поля
  //  Fr.RefreshRecord;
      bbb:=false;
      //обязательно
      Handled := True;
    end
    else FHandled := False;
  end;

  if not FHandled then begin
    {обработка для случая, когда  все прописано здесь, обновление строки производится и до и после записи}
    repeat
    FHandled := True;
    if FormDoc = myfrm_J_Accounts then begin
      //ПК - счета. Согласовываем счет при наличии прав на него
      b:= User.Roles([], [rPC_A_AgrAll]);
      b:= b or User.Roles([], [rPC_A_AgrSelfCat]) and S.InCommaStr(IntToStr(User.GetId), S.NSt(Fr.GetValue('useragreed'))) ;
      if ((Fr.CurrField = 'agreed1') and b) or ((Fr.CurrField = 'agreed2') and User.Roles([], [rPC_A_AgrDir])) then begin
        if (Fr.CurrField = 'agreed1')
          then st:='руководитель'
          else st:='директор';
        if Fr.RefreshRecord then begin
          i:= S.NInt(Fr.GetValue(Fr.CurrField));
          if MyQuestionMessage(S.IIf(i = 0, 'Согласовать счет'#10#13'('+st+') ?', 'Отменить согласование счета'#10#13'('+st+') ?')) = mrYes then begin
            if myMessageDlg(st, mtconfirmation, [mbYes, mbNo]) = mrYes then begin
              if Fr.CurrField = 'agreed1'
                then
                Q.QExecSql(
                  'update sn_calendar_accounts set agreed1=:agreed1$i, id_whoagreed1 = :id_whoagreed1$i where id=:id$i',
                  [S.IIf(i = 1, 0, 1), S.IIf(i = 1, null, User.GetId), Fr.ID], False
                )
                else
                Q.QExecSql(
                  'update sn_calendar_accounts set agreed2=:agreed2$i where id=:id$i',
                  [S.IIf(i = 1, 0, 1), Fr.ID], False
                );
                Fr.RefreshRecord;
            end;
          end;
        end;
      end;
    end

    else if FormDoc = myfrm_J_Payments then begin
      if (Fr.CurrField = 'pstatus') and (User.Role(rPC_P_Payment)) and Fr.RefreshRecord then begin
        i := S.NInt(Fr.GetValue(Fr.CurrField));
        if MyQuestionMessage(S.IIf(i = 0, 'Провести платёж?', 'Отменить проведение платежа?')) = mrYes then begin
          Q.QExecSql(
            'update sn_calendar_payments set status=:pstatus$i, dtpaid=:pdtpaid$d where id=:id$i',
            [S.IIf(i = 1, 0, 1), S.IIf(i = 1, null, Date), Fr.ID], False
          );
          Fr.RefreshRecord;
        end;
      end;
    end
    else FHandled := False;
    until True;
    if FHandled then begin
      Fr.MemTableEh1.Cancel;
      Handled := True;
    end;
  end;
end;

procedure TFrmXGlstMain.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
//  if Fr.InAddControlChange then
//    Exit;
  try
//  Fr.InAddControlChange := True;
  if (FormDoc = myfrm_R_Test) then begin
    if TControl(Sender).Name = 'Chb1' then begin
      //изменить редактируемость столбца
//      Frg1.Opt.S(gotColEditable, [[S.IIfStr(Cth.GetControlValue(Fr, 'Chb1') = 1, 'active')]], True);
//      Frg1.Opt.S(gotColEditable, [[S.IIfStr(Cth.GetControlValue(Sender) = 1, 'active')]], True);
    Frg1.Opt.SetColFeature('active', 'e', Cth.GetControlValue(Frg1, 'Chb1') = 1, True);
      Fr.DbGridEh1.Repaint;
    end;
    if TControl(Sender).Name = 'Chb2'
      then Fr.RefreshGrid;
  end


  else if FormDoc = myfrm_R_Bcad_Nomencl then begin
    if TControl(Sender).Name = 'ChbGrouping'
      then Fr.DbGridEh1.DataGrouping.Active := Cth.GetControlValue(Fr, 'ChbGrouping') = 1
      else if TControl(Sender).Name = 'ChbArtikul' then begin
        Fr.Opt.SetColFeature('artikul', 'null', Cth.GetControlValue(Fr, 'ChbArtikul') = 0, False);
        Frg1.Opt.SetColFeature('artikul', 'i', Cth.GetControlValue(Fr, 'ChbArtikul') = 0, False);
        Frg1.SetColumnsVisible;
        if Fr.IsPrepared then
          Fr.RefreshGrid;
      end
      else if Fr.IsPrepared then
        Fr.RefreshGrid;
  end
  else if (FormDoc = myfrm_J_PlannedOrders) then begin
    Frg1.Opt.SetColFeature('1', 'i', Cth.GetControlValue(Fr, 'ChbMonthsSum') = 0, False);
    if Fr.IsPrepared then
      Frg1.SetColumnsVisible;
  end
  else if (FormDoc = myfrm_J_Tasks) and (Fr.IsPrepared) then begin
    //журнал задач - для этих контролов может быть отмечен только один, и нельзя снимать отметку (работают как радиобаттон)
{    if A.InArray(TControl(Sender).Name, ['ChbFromMy', 'ChbForMy', 'ChbAll']) then begin
      if not TDBCheckBoxEh(Sender).Checked then
        TDBCheckBoxEh(Sender).Checked := True;
      if TControl(Sender).Name <> 'ChbFromMy' then
        TDBCheckBoxEh(Fr.FindComponent('ChbFromMy')).Checked := False;
      if TControl(Sender).Name <> 'ChbForMy' then
        TDBCheckBoxEh(Fr.FindComponent('ChbForMy')).Checked := False;
      if TControl(Sender).Name <> 'ChbAll' then
        TDBCheckBoxEh(Fr.FindComponent('ChbAll')).Checked := False;
    end;}
  end;

  //обновить грида для этих документов для любого контрола
  if Fr.IsPrepared and A.InArray(FormDoc, [
    myfrm_J_Error_Log,

    myfrm_J_Turv,
    myfrm_J_Payrolls,
    myfrm_R_Holideys,
    myfrm_Rep_W_Payroll,

    myfrm_Rep_Sgp2,
    myfrm_J_Sgp_Acts,
    myfrm_J_InvoiceToSgp,
    myfrm_J_Tasks
    ])
  then Fr.RefreshGrid;
  except on E: Exception do Application.ShowException(E);
  end;
//  Fr.InAddControlChange := False;
end;

procedure TFrmXGlstMain.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if (FormDoc = myfrm_R_Test)and(Fr.CurrField = 'active') then begin
//    Params.ReadOnly := Cth.GetControlValue(Fr, 'Chb1') <> 1;
//    if bbb then Params.ReadOnly:=true;
//    Params.ReadOnly := random(2) = 1;
  end
  else if FormDoc = myfrm_Rep_SnCalendar_Transport then begin
    //подсветим строки для счетов типа Транспорт отгрузки, по которым сумма по счету больше чем сумма доставки, проставленная в паспорте (с учетом ндс)
    if (Fr.GetValue('sum_d') <> null) and (Fr.GetValue('accounttype') = 1) and (Fr.GetValue('sum') > Fr.GetValue('sum_d')) then
      Params.Background := clmyPink;
  end
  else if FormDoc = myfrm_Rep_SnCalendar_AccMontage then begin
      //подсветим строки для счетов по монтажу, по которым сумма по счету больше чем сумма монтажа, проставленная в паспорте (с учетом ндс)
    if (Fr.GetValue('sum') > Fr.GetValue('sum_m')) then
      Params.Background := clmyPink;
  end

  else if (FormDoc = myfrm_R_Itm_Nomencl) and (FieldName = 'price_main') then begin
      //подсветим последнюю цену основного поставщика, если рублевая часть отличается хотя бы на рубль, соотвественно зеленым или розовым
    if Trunc(Fr.GetValueF('price_main')) < Trunc(Fr.GetValueF('price_check')) then
      Params.Background := RGB(180, 255, 180);  //зеленоватый
    if Trunc(Fr.GetValueF('price_main')) > Trunc(Fr.GetValueF('price_check')) then
      Params.Background := RGB(255, 180, 180);  //розовый
  end
  else if FormDoc = myfrm_J_Tasks then begin
    //подсветим красным плановую дату в журнале задач, если дата сдачи просрочена
    if (FieldName ='dt_planned') and (Fr.GetValue('dt_planned') <> null) and
      (((Fr.GetValue('dt_end') = null) and (Date > Fr.GetValue('dt_planned'))) or ((Fr.GetValue('dt_end') > Fr.GetValue('dt_planned')))) then
    Params.Background := clmyPink;
  end;
end;

procedure TFrmXGlstMain.Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
  if (FormDoc = myfrm_R_Test)and(Fr.CurrField = 'active') then begin
    ReadOnly := ((Fr.RecNo > 10) and bbb);
  end
  else if FormDoc = myfrm_J_OrPayments then begin
    if (Fr.CurrField = 'account') then
      ReadOnly := ((Fr.GetValue('dt_end') <> null) or (Fr.GetValue('cashtypename') <> 'безнал'))
  end;
end;

procedure TFrmXGlstMain.Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string);
begin

end;

procedure TFrmXGlstMain.Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
begin
  if (FormDoc = myfrm_J_OrPayments) and (FieldName = 'account') then begin
    Q.QExecSQL('update orders set account = :account where id = :id$i', [Value, Fr.ID]);
  end;
end;



procedure TFrmXGlstMain.Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
var
  v : Variant;
  va: TVarDynArray;
begin
  if (FormDoc = myfrm_R_Itm_Nomencl)and(Fr.CurrField = 'price_check') and User.Role(rOr_Other_R_MinRemains_chPriceCheck) then begin
    va := Q.QSelectOneRow('select max(price_check) from spl_itm_nom_props where id = :id$i', [Fr.ID]);
    if TFrmBasicInput.ShowDialog(Self, '', [], fEdit, 'Контрольная цена', 200, 100,
      [[cntNEdit, 'Контрольная цена', '0:100000000:2:+', 80]],  //в позиции 3 не ставим N, тк не нужно требовать непустго значения
      va, va, [['Контрольная цена']], nil
    ) < 0 then Exit;
    Q.QCallStoredProc('P_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', [Fr.ID, 7, S.NullIfEmpty(va[0])]);
    Fr.RefreshRecord;
    Handled := True;
  end
  else if (FormDoc = myfrm_Rep_Sgp2) then begin
    if Fr.CurrField = 'qnt' then begin
      TFrmOGinfSgp.Show(Self, myfrm_Dlg_Sgp_InfoGrid_Move, [myfoMultiCopy, myfoSizeable, myfoDialog], fView, fr.ID, 1);
      Handled := True;
    end;
  end
  else if FormDoc = myfrm_Rep_ItmNomOverEstimate then begin
    try
    if FrmOGedtSnMain <> nil then
      FrmOGedtSnMain.Frg1.MemTableEh1.Locate('id', Fr.GetValue('id_nomencl'), []);
    except
    end;
  end
  else if (FormDoc = myfrm_Rep_PlannedMaterials)and(TRegEx.IsMatch(Fr.CurrField, '^qnt[0-9]{1,2}$')) then begin
    v:= VararrayOf([Fr.GetValueS('name'), S.NNum(Copy(Fr.CurrField, 4, 2))]);
    TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_PlanneDOrders, [myfoModal, myfoSizeable, myfoDialog], fView, id, v);
    Handled := True;
  end;

end;

procedure TFrmXGlstMain.DbGridEh1Columns0AdvDrawDataCell(Sender: TCustomDBGridEh;
  Cell, AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect;
  var Params: TColCellParamsEh; var Processed: Boolean);
begin
  inherited;
//
end;

procedure TFrmXGlstMain.Frg1DbGridEh1GetCellParams(Sender: TObject; Column: TColumnEh; AFont: TFont; var Background: TColor; State: TGridDrawState);
begin
  inherited;
  Frg1.DbGridEh1GetCellParams(Sender, Column, AFont, Background, State);
end;


{=========================  СОБЫТИЯ ВТОРОГО ГРИДА =============================}

procedure TFrmXGlstMain.Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
var
  va: TVarDynArray;
begin
  if fMode <> fNone then begin
    if ((FormDoc = myfrm_J_OrPayments)or(FormDoc = myfrm_J_OrPayments_N)) then begin
      //вызов диалога ввода платежа по заказу в Журнале платежей по заказам
       if TFrmBasicInput.ShowDialog(Self, '', [], fMode, '~Платёж', 150, 60,
          [[cntDEdit, 'Дата', ':'],[cntNEdit, 'Сумма', '1:1000000000:2']],
          [S.IIf(fMode = fAdd, Date, Fr.GetValue('dt')), S.IIf(fMode <> fAdd, Fr.GetValue('sum'), Frg1.GetValue('restsum'))],
          va, [['']], nil
        ) < 0 then Exit;
      Q.QCallStoredProc('p_Or_Payment' + S.IIfStr(FormDoc = myfrm_J_OrPayments_N, '_n'), 'IdOrder$i;PSum$f;PDt$d;PAdd$i',
        [Frg1.ID, S.IIf(fMode = fDelete, 0, va[1]), va[0], S.IIf(fMode = fAdd, 1, 0)]
      );
      if Pos('Н', Frg1.GetValueS('ornum')) = 1 then
        Orders.FinalizeOrder(Frg1.ID, myOrFinalizePay);
      Fr.RefreshGrid;
      Frg1.SetRowDetailPanelSize;
      Frg1.RefreshRecord;
    end;
  //журнал стандартных форматов паспортов
    if (FormDoc = myfrm_R_StdPspFormats) then begin
      //форматы смет для стандартных паспортов заказа (иначе группы изделий)
      if Frg1.ID <= 1 then
        Exit; //для общих и доп.компл. нельзя создавать / редактировать группы
      if Fr.IsNotEmpty and (fMode <> fAdd)
        then va := [Fr.GetValueS('name'), Fr.GetValueS('prefix'), Fr.GetValueS('prefix_prod'), S.IIf(Fr.GetValueI('is_semiproduct') = 1 , True, False), S.IIf(Fr.GetValueI('active') = 1 , True, False)]
        else va := ['', '', True];
      if TFrmBasicInput.ShowDialog(FrmMain, '', [], fMode, 'Параметры сметы', 300, 80, [
        [cntEdit,'Наименование','1:400:0', 210],
        [cntEdit,'Префикс для'#13#10'отгрузки','1:20:0', 100],
        [cntEdit,'Префикс для'#13#10'производства','1:20:0', 100],
        [cntCheck,'Поплоуфабрикаты','', 100],
        [cntCheckX,'Используется','', 100]
       ], va, va, [['']], nil) < 0
      then Exit;
      if Q.QIUD(Q.QFModeToIUD(fMode), 'or_format_estimates', '', 'id$i;id_format$i;name$s;prefix$s;prefix_prod$s;is_semiproduct$i;active$i',
        [Fr.ID, Frg1.ID, va[0], va[1], va[2], va[3], va[4]]) < 0 then
        MyWarningMessage('Не удалось изменить данные!');
      if fMode in [fAdd, fDelete]
        then Fr.RefreshGrid
        else Fr.RefreshRecord;
    end;
    Exit;
  end;
end;

procedure TFrmXGlstMain.Frg2CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
end;

procedure TFrmXGlstMain.Frg2SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
end;

function  TFrmXGlstMain.Frg2OnFilterExecute(var Fr: TFrDBGridEh; const No: Integer; var Handled: Boolean): string;
begin
end;

procedure TFrmXGlstMain.Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  //здесь можно также добавить заголовок детального грида
  if (FormDoc = myfrm_R_Test) then
    Fr.SetSqlParameters('id$i', [Frg1.ID]);
  if (FormDoc = myfrm_J_OrPayments) or (FormDoc = myfrm_J_OrPayments_N) then
    Fr.SetSqlParameters('id_order$i', [Frg1.ID]);
  if FormDoc = myfrm_R_StdPspFormats then
    Fr.SetSqlParameters('id_format$i', [Frg1.ID]);
  if (FormDoc =  myfrm_J_Sgp_Acts) then
    Fr.SetSqlParameters('id$i;doctype$s', [Frg1.ID, Frg1.GetValueS('doctype')]);
  if FormDoc = myfrm_J_SnHistory then
    Fr.SetSqlParameters('id$i', [Frg1.ID]);
end;

procedure TFrmXGlstMain.Frg2ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
var
  ReadOnly: Boolean;
begin
  if (FormDoc = myfrm_R_Test) then begin
  end;
end;

procedure TFrmXGlstMain.Frg2DbGridEh1GetCellParams(Sender: TObject;
  Column: TColumnEh; AFont: TFont; var Background: TColor;
  State: TGridDrawState);
begin
  inherited;
  Frg2.DbGridEh1GetCellParams(Sender, Column, AFont, Background, State);
end;

procedure TFrmXGlstMain.Frg2AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
end;

procedure TFrmXGlstMain.Frg2ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if (FormDoc = myfrm_R_Test)and(Fr.CurrField = 'active') then begin
//    Params.ReadOnly := Cth.GetControlValue(Fr, 'Chb1') <> 1;
//    if bbb then Params.ReadOnly:=true;
//    Params.ReadOnly := random(2) = 1;
  end;
end;

procedure TFrmXGlstMain.Frg2GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
end;

procedure TFrmXGlstMain.Frg2OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
end;

procedure TFrmXGlstMain.Frg2VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string);
begin
end;

procedure TFrmXGlstMain.Frg2CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
begin
end;

end.

(*

    Caption:='Плановые заказы';
    Frg1.Options := Frg1.Options + [myogGridLabels];
    //поля, для работы с датадрайвером можно указывать 'id', для загрузки из массива обязательно 'id$i'
    va2 := [
      ['id','_id'],['id_template','_id_template'],['dt','Дата создания','80'],['num','№'],['dt_start','Начало действия','80'],['dt_end','Окончание действия','80'],
      ['dt_change','Дата изменения'],['std','Стд','40','pic'],['templatename','Шаблон','200'],['projectname','Проект','200'],['sum_all','Сумма','100','f=r:']
    ];
    //добавим динамически
    for i := 1 to 1 do
      va2 := va2 + [['sum'+IntToStr(i), MonthsRu[i], '100','f=r:','t=1']];
    //установим поля, все остальное делать после этого!!!
    Frg1.Opt.SetFields(va2);
    //таблица, точнее здесь вью, но можно передать и таблицу и поле айди
    Frg1.Opt.SetTable('v_planned_orders_w_sum');
    //кнопки, в произвольном месте. если есть доп контролы, обязательно создать btnCtlPanel, ее длина по умолчанию подгонится под контролы
    Frg1.Opt.SetButtons(1,[
      [btnRefresh],[],[btnView],[btnEdit,User.Role(rOr_J_PlannedOrders_Ch)],[btnCustom_OrderFromTemplate,1],[btnDelete,1],[],[btnGridFilter],[],[btnGridSettings],[btnCtlPanel{, True, 140}]
    ]);
    //или, если бы не было нестандартных кнопок, можно указать так, кнопки по первым буквам, ревереш, просмотра/редактирования,фильтр,настройки,
    //панель, всега будут те что перечислены в дефолтном фарианте, и роль для всего редактирования, по умолчанию труе
     //Frg1.Opt.SetButtons(1, 'rveacdfsp'? ARight);
    Frg1.Opt.SetButtonsIfEmpty([btnCustom_OrderFromTemplate]);
    //создаем контролы
    Frg1.CreateAddControls('1', cntCheck, 'По месяцам', 'ChbMonthsSum', '', 4, yrefC, 130);
    //если надо явно обработать контролы сразу, то перечитаем, можем установить их значения, и сделаем зависимые настройки полей
    //в простых случаях можно не делать, контролы прочитаются в Frg1.Prepare, ранее открытия датазета, после чего вызовется событие их изменения
    //(даже если значения контроловн е изменились), где реализуется логика
    //(надо обработать Fr.InPrepare и в этом случае например не делать Refresh или SelcolumnsVisible
    Frg1.ReadControlValues;
    if not (User.Role(rOr_J_Orders_Sum)or(User.Role(rOr_J_Orders_PrimeCost))) then begin
      Cth.SetControlValue(TDBCheckBoxEh(Frg1.FindComponent('ChbViewSum')), 0);
      Frg2.Opt.SetColFeature('1', 'null', True, False);
    end;
    Frg2.Opt.SetColFeature('1', 'i', Cth.GetControlValue(Frg1, 'ChbViewSum') = 0, False);
    //фильтр (help, поля дат если по дате, чевбоксы и правила
    Frg1.Opt.FilterRules := [[], ['dt;dt_start;dt_end;dt_change']];
    //Frg1.Opt.FilterRules := [[], ['dt_beg;dt_otgr;dt_end'], ['Показать себестоимость', 'Sum0', User.Role(rOr_J_Orders_Sum)]];
    //подсказка в строке кнопок сверху
    Frg1.InfoArray:=[
      [Caption + '.'#13#10]
    ];

{    FOpt.StatusBarMode := stbmDialog;
    FOpt.DlgPanelStyle := dpsBottomRight;
    Frg1.Opt.SetButtons(1, [[btnAdd]], 4, PDlgBtnR);
    FMode := fView;}

      //картинка, в строке через ":"
      //1 - значения полей, через точку с запятой
      //2 - соответствующие им индексы картинок
      //3 - если +, то выводитяяся и текст
      //если ничего не задано, то будет галка для значения "1", если задан только один параметр, то будет галка для него


  //при изменениии контролов в событии, событие onChange не вызывается!
  //чекбоксы с тегом -1..-10 обработаем как радиобаттоны, а -11..-20 так же, но с возможностью снятия

*)


доделать возможность отложенной загрузки данных (по кнопке) - отчет по транспорту myfrm_Rep_SnCalendar_Transport

{$R *.dfm}

end.
