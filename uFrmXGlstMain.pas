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
    {����������� �������, ������������ � ������ ������. � �������� ������ ���� ����������� � ���� �� ������}
    //� ���� ������� � �������� ������������ ����� � ��� �����; � �������� ����������� �������� inherited
    procedure Frg1DbGridEh1GetCellParams(Sender: TObject; Column: TColumnEh; AFont: TFont; var Background: TColor; State: TGridDrawState); override;
    procedure Frg2DbGridEh1GetCellParams(Sender: TObject; Column: TColumnEh; AFont: TFont; var Background: TColor; State: TGridDrawState); override;
    procedure Timer_AfterStartTimer(Sender: TObject);
    procedure DbGridEh1Columns0AdvDrawDataCell(Sender: TCustomDBGridEh; Cell, AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect; var Params: TColCellParamsEh; var Processed: Boolean);
  private
  protected
    //�������� ������� �����
    function  PrepareForm: Boolean; override;

    //������� ������� (���������) ������ �����
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    function  Frg1OnFilterExecute(var Fr: TFrDBGridEh; const No: Integer; var Handled: Boolean): string; override;
    //����� ������������� ���������� where-����� ������� � �������������� ��������� � �������
    //(���������� ������, ������ ��� ��� ��������������� �������, ����� ������������ ��������� � ��� �������� �������, ������ �� ��������� ������ � ������ ��������
    procedure Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    //����� ������ ������������� ��������� ������ (����� ��������, readonly) � ����������� �� ������ � ������� ������
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    //������� ���� � �������
    //�� ��������� �������� �������������� ��� �������� ������
    procedure Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); override;
    procedure Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string); override;
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;


    //������� ������� (� rorowDetailPanel) ������ �����
    procedure Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg2CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg2SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    function  Frg2OnFilterExecute(var Fr: TFrDBGridEh; const No: Integer; var Handled: Boolean): string; override;
    //����� ������������� ���������� where-����� ������� � �������������� ��������� � �������
    //(���������� ������, ������ ��� ��� ��������������� �������, ����� ������������ ��������� � ��� �������� �������, ������ �� ��������� ������ � ������ ��������
    procedure Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure Frg2ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure Frg2AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    //����� ������ ������������� ��������� ������ (����� ��������, readonly) � ����������� �� ������ � ������� ������
    procedure Frg2ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    //������� ���� � �������
    //�� ��������� �������� �������������� ��� �������� ������
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
������:
���� ��� ������� 70-80
����� 40
����� �� 10���� � ���. - 100
}
  Result := False;
//  Q.QSelectOneRow('select count(*) as s from dual',[]);
//  Q.QExecSql('selet 1 from', [], False);

  if FormDoc = myfrm_R_Test then begin
    Caption:='������� �������';
    Frg1.Options := Frg1.Options + [myogIndicatorCheckBoxes, myogMultiSelect, myogGridLabels, myogRowDetailPanel];
    Frg1.Opt.SetFields([
      ['id$i','id'],
      ['name$s as name','������������ �������','300','bt=������ 1::l;������ 2:ud:l:h'],
      ['active','������������','120', true, 'chb']]);
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
    Frg1.CreateAddControls('1', cntCheck, '������ �������������', 'Chb1', '', 4, yrefT, 200);
    Frg1.CreateAddControls('1', cntCheck, '�������� ��������������', 'Chb2', '', 4, yrefB, 200);
    Frg1.CreateAddControls('1', cntCheck, 'yyyyyy', 'Chb4', '', 210+40, yreft, 60);
    Frg1.CreateAddControls('1', cntEdit, '�����', 'Chb3', '', 210+40, yrefB, 60);
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
      ['name$s','������������ �������','300','bt=������ 1;������ 2','null'],
      ['active','������������','120', true, 'chb']
    ]);
    Frg2.Opt.SetWhere('where id > :id$i');
    Frg2.Opt.SetTable('ref_test2');
    Frg2.DbGridEh1.RowDetailPanel.Active := False;
  end

  {�����������������}

  else if FormDoc = myfrm_Adm_Db_Log then begin
    Caption:='��� ������� � ��';
    Frg1.Options := Frg1.Options + [myogGridLabels];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['dt','����� �������','150'],
      ['itemname','��������','250'],
      ['comm','�����������','250']
    ]);
    Frg1.Opt.SetTable('adm_db_log');
    Frg1.Opt.FilterRules := [[], ['dt']];
    Frg1.Opt.SetButtons(1, 'rfs');
  end
  else if FormDoc = myfrm_J_Error_Log then begin
    Caption:='��� ������';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['dt','����� �������','150','bt=�����������'],
      ['modulename','������','120'],
      ['userloginandname','������������','150'],
      ['message','��������� �� ������','300'],
      ['sql','SQL-������','200']
    ]);
    Frg1.Opt.SetTable('v_adm_error_log');
    Frg1.Opt.SetWhere('where userlogin like :userlogin$s and ide <= :ide$i /*ANDWHERE*/');
    Frg1.Opt.FilterRules := [[], ['dt']];
    Frg1.Opt.SetButtons(1, 'rvdfsp', User.IsDeveloper);
    Frg1.CreateAddControls('1', cntCheck, '������ ���� ������', 'ChbMy', '', 50, yrefC, 150);
    Frg1.CreateAddControls('1', cntCheck, '���������� ����������', 'ChbDebug', '', -1, yrefC, 150);
  end
  else if FormDoc = myfrm_R_Organizations then begin
    Caption:='���������� ����� �����������';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name','������������','200'],
      ['requisites','���������','200'],
      ['active','������������','80','pic']
    ]);
    Frg1.Opt.SetTable('ref_sn_organizations');
    Frg1.Opt.SetButtons(1, 'readsp');
  end
  else if FormDoc = myfrm_R_Locations then begin
    Caption:='���������� ����� �������';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name','�����','300'],
      ['active','������������','80','pic']
    ]);
    Frg1.Opt.SetTable('ref_sn_locations');
    Frg1.Opt.SetButtons(1, 'readsp');
  end
  else if FormDoc = myfrm_R_CarTypes then begin
    Caption:='���������� ����� ������������ �������';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name','������������','300'],
      ['active','������������','80','pic']
    ]);
    Frg1.Opt.SetTable('ref_sn_cartypes');
    Frg1.Opt.SetButtons(1, 'readsp');
  end



  {��������� ���������}

   //��������� ��������� - �����
  else if FormDoc = myfrm_J_Accounts then begin

    Caption:='�����';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id'],
      ['filename$i','_File','40'],
      ['useragreed$s','_�������������','40'],
      ['agreed2dt$d','_����������� ����������, ����','80'],
      ['anyinstr(useravail,'+IntToStr(User.GetId)+') as useravail$s','_EditableForUser','80'],
      ['to_char(id_whoagreed1) as id_whoagreed1$s','_id_whoagreed1','40'],
      ['username$s','��������','100'],
      ['organization$s','����������','100'],
      ['expenseitem$s','������ ��������','120'],
      ['supplier$s','����������','120'],
      ['account$s','����','120','bt=�������� ����:;�������� ������:'],
      ['accountdt$d','���� �����','80'],
      ['acctype$s','����� ������','80'],
      ['dt$d','���� �����������','80'],
      ['regdays$f','����� �����������','80'],
      ['accsum$f','����� �� �����','80','f=r:'],
      ['paidsum$f','��������','80','f=r:'],
      ['debt$f','�������������','80','f=r:'],
      ['comm$s','����������','150;w'],
      ['paimentstatus$s','������ ������',''],
      ['agreed1$i','�����������','80','chb=+','e',User.Roles([], [rPC_A_AgrSelfCat])],
      ['agreed2$i','��������','80','chb=+','e',User.Roles([], [rPC_A_AgrDir])],
      ['receiptdt$d','�����������','80',S.IIFStr(User.Role(rPC_A_Receipt),'bt=���� �������������')],
      ['receiptdays$i','�����������, ����','80']
    ]);
    Frg1.Opt.SetTable('v_sn_calendar_accounts');
    Frg1.Opt.FilterRules := [[], ['accountdt;dt']];
    b0:=User.Role(rPC_A_ChAll)  //����� ������� �� ���������� � �����������
      or (User.Roles([],[rPC_A_ChSelf, rPC_A_ChSelfCat]) and
      (Q.QSelectOneRow('select count(id) from ref_expenseitems where anyinstr(useravail, :id_user$i)=1 and accounttype = :accmode$i', [User.GetId, 0])[0] > 0));
    b1:=User.Role(rPC_A_ChAll)  //��������� ��������
      or (User.Roles([],[rPC_A_ChSelf, rPC_A_ChSelfCat]) and
      (Q.QSelectOneRow('select count(id) from ref_expenseitems where anyinstr(useravail, :id_user$i)=1 and accounttype = :accmode$i', [User.GetId, 1])[0] > 0));
    b2:=User.Role(rPC_A_ChAll)  //���������
      or (User.Roles([],[rPC_A_ChSelf, rPC_A_ChSelfCat]) and
      (Q.QSelectOneRow('select count(id) from ref_expenseitems where anyinstr(useravail, :id_user$i)=1 and accounttype = :accmode$i', [User.GetId, 2])[0] > 0));
    b3:=User.Role(rPC_A_ChAll)  //������
      or (User.Roles([],[rPC_A_ChSelf, rPC_A_ChSelfCat]) and
      (Q.QSelectOneRow('select count(id) from ref_expenseitems where anyinstr(useravail, :id_user$i)=1 and accounttype = :accmode$i', [User.GetId, 3])[0] > 0));
    Frg1.Opt.SetButtons(1,[[btnRefresh],[], [btnView], [btnEdit,User.Roles([],[rPC_A_ChAll, rPC_A_ChSelf, rPC_A_ChSelfCat])], [btnAdd, b0],
      [btnAdd_Account_TO,b1], [btnAdd_Account_TS,b2], [btnAdd_Account_M,b3], [btnCopy,b0], [btnDelete,1], [], [-btnCustom_AccountToClipboard], [], [btnGridFilter], [], [btnGridSettings]]);
    Frg1.Opt.SetButtonsIfEmpty([btnAdd_Account_TO, btnAdd_Account_TS, btnAdd_Account_M]);
  end
  //��������� ��������� - �������
  else if FormDoc = myfrm_J_Payments then begin
    Caption:='�������';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['to_char(pid) as pid$i','_id','40'],
      ['id as aid$i','_aid','40'],
      ['filename$s','_����','40'],
      ['anyinstr(useravail,'+IntToStr(User.GetId)+') as useravail$i','_EditableForUser','40'],
      ['agreed2auto$i','_ag2a','25'],
      ['username$s','��������','120'],
      ['organization$s','����������','120'],
      ['expenseitem$s','������ ��������','120'],
      ['supplier$s','����������','150'],
      ['account$s','����','100','bt=�������� ����;�������� ������'],
      ['accountdt$d','���� �����','80'],
      ['dt$d','���� ����������� �����','80'],
      ['acctype$s','����� ������','80'],
      ['accsum$f','����� �� �����','80','f=r:'],
      ['pdtpaid$d','���� ����������','80'],
      ['comm$s','����������','150'],
      ['agreed1$i','�����������','60','pic'],
      ['agreed2$i','��������','60','pic'],
      ['pdt$d','���� �������','80'],
      ['psum$f','����� �������','80','f=r:'],
      ['pstatus$i','������ ��������','60','chb=+','e',User.Role(rPC_P_Payment)]
    ]);
    Frg1.Opt.SetTable('v_sn_calendar_payments');
    Frg1.Opt.FilterRules := [[], ['accountdt;dt;pdt']];
    Frg1.Opt.SetButtons(1, 'rveacds', User.Role(rPC_R_GrExp_Ch));
    Frg1.Opt.SetButtons(1,[[btnRefresh],[], [btnView], [btnEdit,User.Roles([],[rPC_A_ChSelfCat, rPC_A_ChAll])], [btnAdd, 1],
      [btnCopy,1], [btnDelete,1], [], [-btnCustom_AccountToClipboard],[],[-btnCustom_RunPayments],[],[btnGridFilter], [], [btnGridSettings]]);
    Frg1.Opt.SetButtonsIfEmpty([btnAdd_Account_TO, btnAdd_Account_TS, btnAdd_Account_M]);
  end
  //��������� ��������� - ������ ������ ��������
  else if FormDoc = myfrm_R_GrExpenseItems then begin
    Caption:='������ ������ ��������';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name$s','������������','300']
    ]);
    Frg1.Opt.SetTable('ref_grexpenseitems');
    Frg1.Opt.SetButtons(1, 'rveacds', User.Role(rPC_R_GrExp_Ch));
  end
   //��������� ��������� - ������ ��������
  else if FormDoc = myfrm_R_ExpenseItems then begin
    Caption:='������ ��������';
    Frg1.Opt.SetFields([
      ['id$i','_id'],
      ['name$s','������������','200'],
      ['groupname$s','������','150'],
      ['usernames$s','������','300'],
      ['agreednames$s','������������','200'],
      ['active$i','������������','60','pic']
    ]);
    Frg1.Opt.SetTable('v_ref_expenseitems');
    Frg1.Opt.SetButtons(1, 'rveacds', User.Role(rPC_R_Exp_Change));
  end
  //��������� ��������� - ����������
  else if FormDoc = myfrm_R_Suppliers then begin
    Caption:='���������� �����������';
    Frg1.Opt.SetFields([
      ['id$i','_id'],
      ['legalname$s','������������','300'],
      ['active$i','������������','60','pic']
    ]);
    Frg1.Opt.SetTable('ref_suppliers');
    Frg1.Opt.SetButtons(1, 'rveacds', User.Role(rPC_R_Sp_Change));
  end
  //��������� ��������� - ���������� - ����� �� ������
  else if FormDoc = myfrm_R_Suppliers_SELCH then begin
    Caption:='���������� �����������';
    Frg1.Opt.SetFields([
      ['id$i','_id'],
      ['legalname$s','������������','300'],
      ['active$i','������������','60','pic']
    ]);
    Frg1.Opt.SetTable('ref_suppliers');
    Frg1.Opt.SetButtons(1,[[btnSelectFromList],[],[btnRefresh],[],[btnView],[btnEdit,User.Role(rPC_R_Sp_Change)],[btnAdd,1],[btnCopy,1],[btnDelete,1],[],[btnGridSettings]]);
    Frg1.InfoArray:=[[Caption + '.'#13#10],
      ['����� ����������.'#10#13'�������� ���������� � ������� � ������� ������ "�������" ��� ������ �������� ����� �� ������.'#10#13],
      ['�� ������ ����� ������� ����������, ���� ������� ��� ���, ��� ��������������� ������������ ������.', User.Role(rPC_R_Sp_Change)]
    ];
  end
  //��������� ��������� - ����� �� �������� �� �����
  else if FormDoc = myfrm_Rep_SnCalendarByDate then begin
    Caption:='������� �� �����';
    Frg1.Opt.SetFields([
      ['to_char(rownum) as ID','_id'],
      ['pdt','����','80'],
      ['sum','����� �������','100','f=r:'],
      ['paidsum','���������� �����','100','f=r:']
    ]);
    Frg1.Opt.SetTable('v_sn_calendar_datereport');
    Frg1.Opt.SetButtons(1, 'rsfp');
    Frg1.Opt.FilterRules := [[], ['pdt']];
    va:=Q.QSelectOneRow('select sum(case when status = 0 then round(sum) else 0 end) as debtsum from sn_calendar_payments', []);
    Frg1.CreateAddControls('1', cntLabelClr,
      S.IIf(va[0] = 0, '������������� ���.', '������������� �� �������: $FF0000 ' + FormatCurr('#,##0', S.NNum(va[0])) + ' $000000�.'),
      'Lb1', '', -1, yrefC, 300
    );
  end
  else if FormDoc = myfrm_J_Accounts_SEL then begin //!!!
    Caption:='�����';
    Frg1.Opt.SetFields([
      ['id$i','_id'],
      ['expenseitem$s','������ ��������','150;w'],
      ['supplier$s','����������','150;w'],
      ['account$s','����','100;w'],
      ['accountdt$d','���� �����','80'],
      ['accsum$f','����� �� �����','80','f=r:']
    ]);
    Frg1.Opt.SetTable('v_sn_calendar_accounts');
    Frg1.Opt.SetButtons(1,[[btnSelectFromList],[btnGridFilter],[-btnGridSettings]]);
    Frg1.Opt.FilterRules := [[], ['accountdt']];
    Frg1.InfoArray:=[
      ['����� �����.'#10#13'�������� ����������� ���� � ������� � ������� ������ "�������" ��� ������ �������� ����� �� ������.'#10#13],
      ['����������� ������ "������", ����� ������� ������, �� ������� ��������� �����.']
    ];
  end
  else if FormDoc = myfrm_J_OrPayments then begin
    Caption:='������� �� �������';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['path$i','_File',''],
      ['year$i','_���',''],
      ['ornum$s','� ������','80'],
      ['dt_beg$d','���� ����������','80'],
      ['dt_end$d','���� ��������','80'],
      ['project$s','������','150'],
      ['customer$s','����������','150'],
      ['account$s','� �����','140','e',User.Roles([],[rOr_J_OrPayments_Ch, rPC_J_OrPayments_Ch])],
      ['cost$f','����� ������','80','f=r:'],
      ['cashtypename$s','����� ������','90'],
      ['paidsum$f','��������','80','f=r:'],
      ['restsum$f','�������','80','f=r:'],
      ['receivables$f','����������� �������������','80','f=r:'],
      ['paimentstatus$i','������','50','pic=���������;��������;�� �������;���������:1;2;3;4'],
      ['comm$s','���������� � ������','200']
    ]);
    Frg1.Opt.SetTable('v_or_payments');
    Frg1.Opt.FilterRules := [[], ['dt_beg;dt_end'], ['�������� ��������', 'Closed', ';dt_end is null', True], ['�������� � ������� ������', 'NullSum', ',cost > 0', True]];
    Frg1.Opt.SetButtons(1, 'rafs', User.Roles([],[rOr_J_OrPayments_Ch, rPC_J_OrPayments_Ch]));
    Frg1.InfoArray:=[
      [Caption+ #13#10],
      [
      '����� ��������� ������ �� ������ ���� �������. ������ ����� ����� ���� ������� �������, ��'#13#10 +
      '�� ������ ���� ����� ���� ������ ���� ������ (��������� ������ �� ��� ����).'#13#10 +
      '����������� ������ "��������", ����� ������ �������� ������ �� ������'#13#10 +
      '(��� ����������, ���� ��� ���� ������ �� ��� ����, �� ��������� ����� ����� ���������� � ����),'#13#10 +
      '��� �� ��������� ������ ����� �� ������, ����� + � ������ �������, � �������������� (��������/��������/�������) ������.'#13#10 +
      '� �������� ������� ����� ����� �������� ����� �����, ������ �������������� ��� � ������.'#13#10 +
      '����������� ������ �������, ����� �������� ����������� ������ � ������ � �������� �������.'#13#10 +
      ''#13#10
      ,User.Roles([],[rOr_J_OrPayments_Ch])
      ]
    ];
    Frg2.Opt.SetFields([
      ['id$i','_id','40'],
      ['dt$d','����','80'],
      ['sum$f','�����','80','f=r:']
    ]);
    Frg2.Opt.SetTable('or_payments');
    Frg2.Opt.SetWhere('where id_order = :id_order$i order by dt');
    Frg2.Opt.SetButtons(1, 'aed', User.Roles([],[rOr_J_OrPayments_Ch, rPC_J_OrPayments_Ch]));
  end
  else if FormDoc = myfrm_Rep_SnCalendar_Transport then begin
    Caption:='����� �� ������������ ������';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['filename$s','_����','40'],
      ['accounttype$i','_accounttype','40'],
      ['expenseitem$s','������ ��������','120'],
      ['username$s','��������','100'],
      ['organization$s','����������','100'],
      ['supplier$s','����������','120'],
      ['dt_payment$d','���� ������','80'],
      ['cartype$s','���������','80'],
      ['flighttype$s','��� �����','80'],
      ['location1$s','����� ��������','120'],
      ['location2$s','����� ����������','120'],
      ['strings$s','���������� ����','80'],
      ['kilometrage$f','����������, ��.','80'],
      ['sumkm$f','����������, ���.','80','f=r:'],
      ['idle$f','�������, �.','80','f=r'],
      ['sumidle$f','�������, ���.','80','f=r:'],
      ['sumother$f','������, ���.','80','f=r:'],
      ['sum_wo_nds as sum$f','� ������, �����','80','f=r:'],
      ['basissum$f','���� ����� �����','80','f=r:'],
      ['percent$f','���� ������������ ������, %','80','f=f'],
      ['pricekm$f','���� �� ��.','80','f=r'],
      ['sum_m$f','���� �������','80','f=r:'],
      ['sum_d$f','���� ��������','80','f=r:']
    ]);
    Frg1.Opt.SetTable('v_sn_calendar_accounts_t_rep');
    Frg1.Opt.SetWhere('where dt_payment >= :dt_beg and dt_payment <= :dt_end and 1 = :i');
    Frg1.Opt.SetButtons(1,[[btnRefresh],[],[btnView],[],[btnExcel],[btnPrintGrid],[],[btnGridSettings],[],[btnCtlPanel]]);
    Frg1.CreateAddControls('1', cntDEdit, '���� �:', 'DeBeg', '', 4, yrefC, 100);
    Frg1.CreateAddControls('1', cntDEdit, '��: ', 'DeEnd', '', -1, yrefC, 100);
    Frg1.InfoArray:=[[
      '����� �� ������������ ������ �� ��������� ������.'#13#10+
      '��� ��������� ����� �������� ������� ���� �� ������ ������� ��� ������� ��������������� ������.'#13#10+
      '�� ������ ����������� ������� ��� ��������� �� � Excel.'#13#10
    ]];
  end
  else if FormDoc = myfrm_Rep_SnCalendar_AccMontage then begin
    Caption:='����� �� ������ ����������� �� �������.';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['filename$s','_����','40'],
      ['expenseitem$s','������ ��������','120'],
      ['username$s','��������','100'],
      ['organization$s','����������','100'],
      ['supplier$s','����������','120'],
      ['sum$f','� ������, �����','80','f=r:'],
      ['basissum$f','�������� ������� (���. � �/�)','80','f=r:'],
      ['sum_m$f','���� �������','80','f=r:'],
      ['sum_d$f','���� ��������','80','f=r:']
    ]);
    Frg1.Opt.SetTable('v_sn_calendar_accounts_m_rep');
    Frg1.Opt.SetWhere('where accountdt >= :dt_beg and accountdt <= :dt_end and 1 = :i');
    Frg1.Opt.SetButtons(1,[[btnRefresh],[],[btnView],[],[btnExcel],[btnPrintGrid],[],[btnGridSettings],[],[btnCtlPanel]]);
    Frg1.CreateAddControls('1', cntDEdit, '���� �:', 'DeBeg', '', 4, yrefC, 100);
    Frg1.CreateAddControls('1', cntDEdit, '��: ', 'DeEnd', '', -1, yrefC, 100);
    Frg1.InfoArray:=[[
      '����� �� ������ ����������� �� ������� �� ��������� ������.'#13#10+
      '��� ��������� ����� �������� ������� ���� �� ������ ������� ��� ������� ��������������� ������.'#13#10+
      '�� ������ ����������� ������� ��� ��������� �� � Excel.'#13#10
    ]];
  end

  {���������}

  else if FormDoc = myfrm_R_Workers then begin
    Caption:='���������� ����������';
    Frg1.Options := Frg1.Options + [myogGridLabels];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['f','�������','120'],
      ['i','���','120'],
      ['o','��������','120'],
      ['statusname','������','100'],
      ['dt','����','75'],
      ['divisionname','�������������','150'],
      ['job','���������','150']
    ]);
    Frg1.Opt.SetTable('v_ref_workers');
    Frg1.Opt.SetButtons(1, 'rveacds', User.Role(rW_R_Workers_Ch));
  end
  else if FormDoc = myfrm_J_WorkerStatus then begin
    Caption:='������� ����������';
    Frg1.Options := Frg1.Options + [myogGridLabels];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['workername','���','200'],
      ['dt','����','75'],
      ['statusname','������','100'],
      ['divisionname','�������������','150'],
      ['job','���������','150']
    ]);
    Frg1.Opt.SetTable('v_j_worker_status');
    Frg1.Opt.SetButtons(1, 'rads', User.Role(rW_J_WorkerStatus_Ch));
  end
  else if FormDoc = myfrm_R_Jobs then begin
    Caption:='���������� ���������';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name','���������','300']
    ]);
    Frg1.Opt.SetTable('ref_jobs');
    Frg1.Opt.SetButtons(1, 'rveacds', User.Role(rW_R_Jobs_Ch));
  end
  else if FormDoc = myfrm_R_TurvCodes then begin
    Caption:='����������� ����';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['���','���','60'],
      ['name','�����������','150']
    ]);
    Frg1.Opt.SetTable('ref_turvcodes');
    Frg1.Opt.SetButtons(1, 'rveacds', User.Role(rW_R_TurvCode_Ch));
  end
  else if FormDoc = myfrm_R_Divisions then begin
    Caption:='���������� �������������';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['code','���','80'],
      ['name','������������','150'],
      ['isoffice','����/���','80'],
      ['head','������������','150'],
      ['editusernames','��������� ����','300'],
      ['active','������������','70','pic']
    ]);
    Frg1.Opt.SetTable('v_ref_divisions');
    Frg1.Opt.SetButtons(1, 'rveacds', User.Role(rW_R_Divisions_Ch));
  end
  else if FormDoc = myfrm_R_Candidates_Ad_SELCH then begin      //!!!
    Caption:='���������� - ��������� ���������� �� ���������';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name','������������','300']
    ]);
    Frg1.Opt.SetTable('ref_candidates_ad');
    Frg1.Opt.SetButtons(1, 'rlveacds', User.Role(rW_J_Candidates_Ch));
    Frg1.InfoArray:=[
    ['����� ��������� ����������.'#10#13'�������� ������ �������� � ������� � ������� ������ "�������" ��� ������ �������� ����� �� ������.'#10#13],
    ['�� ������ ����� ������� ������, ���� ������ ��� ���, ��� ��������������� ������������ ������.', User.Role(rW_J_Candidates_Ch)]
    ];
  end
  else if FormDoc = myfrm_J_Candidates then begin
    Caption:='������ �����������';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name','���','200'],
      ['dt_birth','���� ��������','75'],
      ['phone','�������','120'],
      ['ad','��������� ����������','150'],
      ['vacancy','��������','150'],
      ['job','���������','150'],
      ['divisionname','�������������','150'],
      ['dt','���� ���������','75'],
      ['headname','�������������','120'],
      ['statusname','������','100'],
      ['dt1','������','75'],
      ['dt2','������','75'],
      ['comm','�����������','200;h']
    ]);
    Frg1.Opt.SetTable('v_sn_calendar_accounts');
    Frg1.Opt.FilterRules := [[], ['dt;dt1;dt2;dt_birth']];
    Frg1.Opt.SetButtons(1, 'rveacdfs', User.Role(rW_J_Candidates_Ch));
    Frg1.CreateAddControls('1', cntComboLK, '��������:', 'CbArea', '', 80, yrefC, 80);
    Frg1.InfoArray:=[
      ['������ �����������.'#13#10],
      ['��� ������ ������, �������� ���������� � ����������� �� ��������� ���������.'],
      ['���� ���� � ��� �� ������� ���������� � �� ��������� ��� (� ������ �����, �� ������ ��������), �� ��������� ��������� ������ ��� ������� ���������!'#13#10+
       '������ ������ �� ������ �� ������������ ���������� � �������� "������� ����������", ������������� � "�����������" �� ������ �� ������ � ���� ����������!'#13#10
      ]
    ];
  end
  else if FormDoc = myfrm_J_Turv then begin
    Caption:='������ ����';
    Frg1.Options := Frg1.Options + [myogGridLabels];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['commit','_Commit','40'],
      ['editusers','_EditUsers','40'],
      ['code','���','50'],
      ['name','�������������','200'],
      ['dt1','���. ����','75'],
      ['dt2','���. ����','75'],
      ['committxt','�������','60','pic=������:13'], //!!!
      ['status','������','60','pic=0;1;2:1;2;3']   //!!!
    ]);
    Frg1.Opt.SetTable('v_turv_period');
    v:=User.Roles([], [rW_J_Turv_TP, rW_J_Turv_TS]);
    v:=v or (Q.QSelectOneRow('select max(IsStInCommaSt(:id$i, editusers)) from ref_divisions', [User.GetId])[0] = 1);
    Frg1.Opt.SetButtons(1,[[btnRefresh],[],[btnEdit, v],[btnAdd, 1],[btnDelete, v and (User.IsDeveloper or User.IsDataEditor)],[],[btnGridFilter],[],[btnGridSettings],[],[btnCtlPanel]]);
    Frg1.Opt.FilterRules := [[], ['dt1']];
    Frg1.CreateAddControls('1', cntCheck, '������� ������', 'ChbCurrent', '', 4, yrefT, 100);
    Frg1.CreateAddControls('1', cntCheck, '������� ������', 'ChbPrevious', '', 4, yrefT, 100);
    Frg1.CreateAddControls('1', cntCheck, '������ ���� ����', 'ChbSelf', '', -1, yrefT, 150);
    Frg1.InfoArray:=[
    ['caption'],
    ['� ������� �������� ������������ ������ �������� ���� (���� ��� ���� �������, �� ��� ������ ������.'#13#10+
     '� ������� ������ ������� ������� �������� ��� �� ������� ��� ������� ������������ ����� ������������, ���� ������� �����, �� ������� �������� �� �������� Parsec, � ���� ������� - ��� ������� ���������.'#13#10
    ],
    ['������� ������ ����������� ��� ��������� ����, ���� � ��� ��� ���� �� ��� ���������.'#13#10, not v],
    ['������� ������ �������� ��� �������� ������ � ����.'#13#10, v],
    ['���� ����, ������� �� ������ �������������, �� ��������� ������ ������������, ������� ������ �������� � �������� ���.'#13#10, v],
    [
      '����������� ������� ����� � ��������, ����� ���������� �� ���� ������, � ������ ����������� ����.'#13#10+
      '(�� ������ ������� ����������� ������ ��� �������, ������� �� ����������.'#13#10'������, ���� �������� ������� ��������, ��'+
      '������������ ���� �� ��� �������, � ����� ��� ����.)'#13#10
    ],
    ['refoptions']
    ];
  end
  else if FormDoc = myfrm_J_Payrolls then begin
    Caption:='������ ���������� ����������';
    Frg1.Options := Frg1.Options + [myogGridLabels];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['code','���','50'],
      ['divisionname','�������������','200'],
      ['dt1','���. ����','75'],
      ['dt2','���. ����','75'],
      ['committxt','�������','60','pic=������:13']
    ]);
    Frg1.Opt.SetTable('');
    Frg1.Opt.SetButtons(1,[[btnRefresh],[],[btnView],[btnEdit],[btnAdd, 1],[btnDelete, 1],[],[btnGridFilter],[],[btnGridSettings],[],[btnCtlPanel]]);
    Frg1.Opt.FilterRules := [[], ['dt1']];
    Frg1.CreateAddControls('1', cntCheck, '������� ������', 'ChbCurrent', '', 4, yrefT, 100);
    Frg1.CreateAddControls('1', cntCheck, '������� ������', 'ChbPrevious', '', 4, yrefT, 100);
    Frg1.CreateAddControls('1', cntCheck, '������ �������������', 'ChbDivisions', '', -1, yrefT, 150);
    Frg1.InfoArray:=[
      ['������ ���������� ����������.'#13#10+
      '��� ��������� ���������� ������ �� ��������� (� ������� - �� ���������) ������ ��������� ��������������� �������.'#13#10+
      '���� �� �� ������ ������ ��������� �� ��������� ����������, ��������� ��������������� �������.'#13#10],
      ['��� �������� ��������� ���������� �� ��������� ������ �� ���� ��������������,'#13#10+
      '���� ��� �������� ���������� �� ��������� � ������� ������� ����������, ������� ��������������� ������.'#13#10 , User.Role(rW_J_Payroll_Ch)],
      ['������ �������� �� ������, ��� ������� ������ "��������" ��� �������������� ���������.'#13#10, User.Role(rW_J_Payroll_Ch)]
    ];
  end
  else if FormDoc = myfrm_R_Holideys then begin
    Caption:='���������������� ���������';
    Frg1.Opt.SetFields([
      ['dt as id$i','_id','40'],
      ['dt','����','75'],
      ['typetxt','���','90'],
      ['descr','��������','150;h']
    ]);
    Frg1.Opt.SetTable('v_ref_holidays');
    Frg1.Opt.SetWhere('where extract(year from dt) = :year$i');
    Frg1.Opt.SetButtons(1,[[btnRefresh],[],[btnCustom_LoadFromInet, User.IsDeveloper or User.Role(rW_R_Holideys_Ch)],[],[btnGridSettings],[],[btnCtlPanel]]);
    Frg1.Opt.SetButtonsIfEmpty([btnCustom_LoadFromInet]);
    Frg1.CreateAddControls('1', cntComboL, '���:', 'CbYear', '', 40, yrefC, 50);
    for i:=2013 to YearOf(Date)+1 do
      TDBComboBoxEh(Frg1.FindComponent('CbYear')).Items.Add(IntToStr(i));
    TDBComboBoxEh(Frg1.FindComponent('CbYear')).Text:=IntToStr(YearOf(Date));
    Frg1.InfoArray:=[];
  end
  else if FormDoc = myfrm_Rep_W_Payroll then begin
    Caption:='���� �� ���������� ����������';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['rownum as id$i','_id','40'],
      ['code','���','60'],
      ['dn','�������������','250;h'],
      ['itog1','���������','80','f=r:'],
      ['ud','��������','80','f=r:'],
      ['ndfl','����','80','f=r:'],
      ['fss','���','80','f=r:'],
      ['pvkarta','����. �������','80','f=r:'],
      ['karta','�����','80','f=r:'],
      ['itog','� ���������','80','f=r:'],
      ['null','�������','80']
    ]);
    Frg1.Opt.SetTable('v_payroll_sum');
    Frg1.Opt.SetWhere('where dt1 = :dt1$d');
    Frg1.Opt.SetButtons(1,[[btnGo, False],[],[btnExcel],[btnPrintGrid],[],[btnGridSettings],[],[btnCtlPanel]]);
    Frg1.Opt.SetButtonsIfEmpty([btnGo]);
    Frg1.CreateAddControls('1', cntComboLK, '������:', 'CbPeriod', '', 60, yrefC, 150);
    Q.QLoadToDBComboBoxEh('select to_char(dt1, ''dd-mm-yyyy'') || '' - '' || to_char(max(dt2), ''dd-mm-yyyy'') as dt from v_payroll group by dt1 order by dt1 desc', [],
      TDBComboBoxEh(Frg1.FindComponent('CbPeriod')), cntComboL
    );
    TDBComboBoxEh(Frg1.FindComponent('CbPeriod')).ItemIndex := 0;
  end
  else if FormDoc = myfrm_J_Vacancy then begin
    Caption:='������ ��������';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['job','���������','150;h'],
      ['qnt','���-��','75'],
      ['qntopen','�������','75'],
      ['dt_beg','���� ��������','75'],
      ['statusname','������','80'],
      ['divisionname','�������������',''],
      ['headname','�������������','120'],
      ['workers','��������','200;h'],
      ['candidates','���������','200;h'],
      ['dt_end','���� ��������','75'],
      ['reasonname','������� ��������','100']
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
    Frg1.CreateAddControls('1', cntComboLK, '��������:', 'CbArea', '', 80, yrefC, 80);
    Frg1.InfoArray:=[
    ];
 }



  else if FormDoc = myfrm_R_StdProjects then begin
    Caption:='������� �������';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name$s','������������ �������','300'],
      ['active$i','������������','80','pic']
    ]);
    Frg1.Opt.SetTable('or_projects');
    Frg1.Opt.SetButtons(1, 'rveacds');
    Frg1.Opt.DialogFormDoc := myfrm_Dlg_R_StdProjects;
    Frg1.InfoArray:=[[Caption + '.'#13#10]];
  end
  else if FormDoc = myfrm_R_Bcad_Groups then begin
    Caption:='������ bCAD';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name$s','������','300']
    ]);
    Frg1.Opt.SetTable('bcad_groups');
    Frg1.Opt.SetButtons(1, 'rveads', User.Role(rOr_R_BCad_Groups_Ch));
    Frg1.InfoArray:=[[Caption + '.'#13#10]];
//Frg1.setinitdata('*',[]);
  end
  else if FormDoc = myfrm_R_Bcad_Units then begin
    Caption:='������� ��������� bCAD';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name$s','������� ���������','300']
    ]);
    Frg1.Opt.SetTable('bcad_units');
    Frg1.Opt.SetButtons(1, 'rveads', User.Role(rOr_R_BCad_Units_Ch));
    Frg1.InfoArray:=[[Caption + '.'#13#10]];
  end
  else if FormDoc = myfrm_R_Bcad_Nomencl then begin
    Frg1.Options := Frg1.Options + [myogLoadAfterVisible];
    Caption:='������� �������';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['id_itm$i','_id_itm','40'],
      ['groupname$s','������','120'],
      ['artikul$s','������� ���','100'],
      ['name$s','������������','300;w'],
      ['unitname$s','��.���.','60'],
      ['bcadcomment$s','�����������','300;w']
    ]);
    Frg1.Opt.SetTable('v_bcad_nomencl_add');
    Frg1.Opt.SetButtons(1,[[btnRefresh],[],[btnAdd,User.Role(rOr_R_ITM_U_Nomencl_Add)],
      [btnCustom_findInEstimates,User.Role(rOr_Other_Order_FindEstimate)],[],[btnGridSettings],[],[btnCtlPanel]]);
    Frg1.CreateAddControls('1', cntCheck, '�������� �� �������', 'ChbGrouping', '', -1, yrefC, 150);
    Frg1.CreateAddControls('1', cntCheck, '������ �� ���', 'ChbFromItm', '', 154, yrefT, 200);
    Frg1.CreateAddControls('1', cntCheck, '�������� ������� ���', 'ChbArtikul', '', 154, yrefB, 200);
    Frg1.ReadControlValues;
    Frg1.Opt.SetGrouping(['groupname'], [], [clGradientActiveCaption], Cth.GetControlValue(Frg1, 'ChbGrouping') = 1);
    Frg1.InfoArray:=[
      [Caption + '.'#13#10],
      ['����� ������������ ��� �������, �����-���� ����������� � ������.'#13#10+
      '��������� ������������ �������.'#13#10+
      '��� ��� ������, ��.���, ����������� �� ����� � ����� ��� ������ � ���� �� ������������ ����� ���� ����������,'#13#10+
      '�� ����� ������������ ������ ���� �� ��������� ���� ������ (���� �� ���������).'#13#10+
      '��� �������� �������� ����������� ������������ �� ������ �� ����� (�� ����� �������).'#13#10+
      '���� ���������� ������ ������� ������� �� ���, �������� ��������������� �������.'#13#10+
      '����� �� ������ ���������� ������ ������ ��� �������������, ������� ���� � ���� ���.'#13#10],
      ['���� ����������� ������ ������� ������� � ������ ����������� ������� � ������� (�� ��������������� ������).'  ,User.Role(rOr_Other_Order_FindEstimate)]
    ];
  end
  else if FormDoc = myfrm_R_OrderTemplates then begin
    Caption:='������� �������';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['dt_beg$d','���� ��������','80'],
      ['templatename$s','������','180'],
      ['format$s','������ ��������','130'],
      ['project$s','������','200']
    ]);
    Frg1.Opt.SetTable('v_orders');
    Frg1.Opt.SetWhere('where id < 0');
    Frg1.Opt.SetButtons(1, 'rveacds', User.Role(rOr_R_Or_Templates_Ch));
  end
  //������ - ���������� ������ ����������
  else if FormDoc = myfrm_R_ComplaintReasons then begin
    Caption:='������� ����������';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name$s','������������','300'],
      ['active$s','������������','100','pic']
    ]);
    Frg1.Opt.SetTable('ref_complaint_reasons');
    Frg1.Opt.SetButtons(1, 'rveacds', User.Role(rOr_R_ComplaintReasons_Ch));
  end
  else if FormDoc = myfrm_R_DelayedInprodReasons then begin
    Caption:='������� �������� � ������������';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name$s','������������','200'],
      ['active$i','������������','80','pic']
    ]);
    Frg1.Opt.SetTable('ref_delayed_prod_reasons');
    Frg1.Opt.SetButtons(1, 'reacdsp', User.Role(rOr_R_DelayedInprodReasons_Ch));
  end
  else if FormDoc = myfrm_R_RejectionOtkReasons then begin
    Caption:='������� ��������� ���';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name$s','������������','200'],
      ['active$i','������������','80','pic']
    ]);
    Frg1.Opt.SetTable('ref_otk_reject_reasons');
    Frg1.Opt.SetButtons(1, 'reacdsp', User.Role(rOr_R_RejectionOtkReasons_Ch));
  end
  else if FormDoc = myfrm_Rep_Order_Complaints then begin
    Caption:='����� �� �����������';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['ornum$s','� ������','100'],
      ['dt_beg$dt','���� ��������','80'],
      ['project$s','������','180;h'],
      ['customer$s','����������','180;h'],
      ['complaints$s','������� ����������','220;h']
    ]);
    Frg1.Opt.SetTable('v_orders');
    Frg1.Opt.SetButtons(1, 'rvfs');
    Frg1.Opt.FilterRules := [[], ['dt_beg']];
    Frg1.InfoArray:=[[
       Caption + ' (������� ����������).'#13#10 +
      '����� �������� ��� ������, ���������� ������������.'#13#10 +
      '������� ���������� �������� � ����� ������, ����� ����� � �������, ���� �� ���������.'#13#10 +
      '��� ������ ������� ����������� ������� ����������� ������ �������.'#13#10 +
      '����� ���� ����������� ����������� ������� ������, ��� ���� ����������� ������ ��������.'#13#10 +
      '��� ������ ����������� ������� ��� �� �������� � Excel ������� ������ ������ ����.'
    ]];
  end
  else if FormDoc = myfrm_J_InvoiceToSgp then begin
    Caption:='��������� ����������� �� ���';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['num$i','�','40'],
      ['dt1_m$d','����','80'],
      ['state$i','������','50','pic=0;1;2:3;2;1'],
      ['ornum$s','�����','80'],
      ['project$s','������','150'],
      ['user_m$s','������','130'],
      ['user_s$s','���������','130'],
      ['items$s','�������','200']
    ]);
    Frg1.Opt.SetTable('v_invoice_to_sgp');
    Frg1.Opt.SetWhere('where area = :area$i');
    Frg1.Opt.SetButtons(1,[[btnRefresh],[],[btnView],[btnAdd,User.Role(rOr_J_InvoiceToSgp_Ch_M)],[btnEdit,User.Role(rOr_J_InvoiceToSgp_Ch_S)],[],[btnGridFilter],[],[btnGridSettings],[],[btnCtlPanel]]);
    Frg1.Opt.FilterRules := [[], ['dt1_m']];
    Frg1.CreateAddControls('1', cntComboLK, '��������:', 'CbArea', '', 80, yrefC, 80);
    Q.QLoadToDBComboBoxEh('select shortname, id from ref_production_areas order by id', [], TDBComboBoxEh(Frg1.FindComponent('CbArea')), cntComboLK);
    Frg1.InfoArray:=[[
      Caption + #13#10 + #13#10+
      '������� ������ "��������" ��� �������� ����� ��������� � ���������� ������ �� �������.'#13#10+
      '���������, ����������� ��������, �� �� �������������� �� ���, �������� � ����� "������" ������� �������.'#13#10+
      '��������� ����� ������������ ����� ���������, ����� ������ "��������", ��� ������ ������� �� ��������� � ������� ������.'#13#10+
      '����� ����� ������ ����� ������� �� ����� ��� ������� ����� - � ����������� �� ����, ��� '#13#10+
      '�� ���������� �������� ����������� ������� �� ���.'#13#10+
      '����� ����� ������, ������ ���������� � �������������� ��������� ����������, �������� ������ ��������.'#13#10+
      '����������� ��������� �����, ������ �� � ������ ���������.'#13#10+
      ''#13#10
    ]];
  end
  else if FormDoc = myfrm_R_Or_ItmExtNomencl then begin
    Caption:='����������� ���������� ������������ ���';
    Frg1.Options := Frg1.Options + [myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['rownum as id$i','_id','40'],
      ['id_nomencl','_id_nomencl','40'],
      ['nomencltype','nomencltype','80'],
      ['artikul','artikul','100'],
      ['skladname','skladname','100'],
      ['name','name','200;h','bt=�������� ������������;����������� �� �������'],
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
    Caption:='���������� ������������';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['id_old$i','_id_old','50'],
      ['oldartikul','�������� ������������|�������','100'],
      ['oldname','�������� ������������|������������','300;h'],
      ['id_new','_id_new','50'],
      ['newartikul','����� ������������|�������','100'],
      ['newname','����� ������������|������������','300;h']
    ]);
    Frg1.Opt.SetTable('v_ref_estimate_replace');
    Frg1.Opt.FilterRules := [[], ['accountdt',User.Role(rOr_R_BCad_Replace_Ch)]];
    Frg1.Opt.SetButtons(1, 'reads');
    Frg1.InfoArray:=[
      [Caption+#13#10#13#10],
      ['������� ������������ ��� ���������� ������� ������� ��� �������� ���� � ���.'#13#10],
      ['�������� ������������ ����� �������� � ����� �� ����� ������������, � ������� �������� ��������� � �����������.'#13#10],
      ['���� ������� ������������ ��� ���� � �����, �� ���������� ����� ��������������.'#13#10],
      ['���� �������� ������������ �� ����������� �������, �� ������ ������� ������� ����� �������.'#13#10],
      ['��������! ������ ������������ ���������� � ������ �������� ���� � ����.'#13#10],
      ['� ����� ����� ����������� ��� �������� �����, ��� ��������, ��� � � �����������, �� � ��� ������ ���������.'#13#10],
      ['����������� ������ �������������� ��� ���������� ������� � ������, ���� �� ��������� � ��������.', User.Role(rOr_R_BCad_Replace_Ch)]
    ];
  end
  else if FormDoc = myfrm_R_Spl_Categoryes then begin
    Caption:='��������� ���������';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name','������������',''],
      ['usernames','������������','']
    ]);
    Frg1.Opt.SetTable('v_spl_categoryes');
    Frg1.Opt.SetButtons(1, 'reacds', User.Role(rOr_R_Spl_Categoryes_Ch));
    Frg1.InfoArray:=[
      [Caption+#13#10],
      ['�������� ��������� ��� ������ ��� �������� �� ���������.'#13#10+
       '���������� ����� ������ �������� ��������� � ������� �������������,'#13#10+
       '������� ����� ��������� �� ��� ������.'#13#10, User.Role(rOr_R_Spl_Categoryes_Ch)]
    ];
  end
  else if FormDoc = myfrm_R_Itm_Units then begin      //!!!
    Caption:='���������� ������ ���������';
    Frg1.Options := Frg1.Options + [myogGridLabels];
    Frg1.Opt.SetFields([
      ['to_char(id_unit) as id$i','_id','40'],
      ['id_measuregroup','_id_group','40'],
      ['groupname','������','100'],
      ['name_unit','������������','80'],
      ['full_name','������ ������������','100'],
      ['pression','��������','70'],
      ['is_bcad_unit','��. bCAD','40','pic']
    ]);
    Frg1.Opt.SetTable('v_itm_units');
    Frg1.Opt.SetButtons(1,[[btnSelectFromList],[],[btnRefresh],[],[btnEdit,User.Role(rOr_R_Itm_Units_Ch)],[btnAdd,1],[btnCopy,1],[btnDelete,User.Role(rOr_R_Itm_Units_Del)],[],[btnGridSettings]]);
    Frg1.InfoArray:=[['���������� ������ ��������� ���'#13#10]];
  end
  else if FormDoc = myfrm_R_Itm_Suppliers then begin
    Caption:='���������� �����������';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];  //!!!
    Frg1.Opt.SetFields([
      ['id_kontragent$i','_id','40'],
      ['name_org','������������','200'],
      ['full_name','������ ������������','200'],
      ['e_mail','EMail','120'],
      ['inn','���','100']
    ]);
    Frg1.Opt.SetTable('v_itm_suppliers', '', 'id_kontragent');
    Frg1.Opt.SetButtons(1,[[btnSelectFromList],[],[btnRefresh],[],[btnEdit,User.Role(rOr_R_Itm_Suppliers_Ch)],[btnAdd,1],[btnCopy,1],[btnDelete,User.Role(rOr_R_Itm_Suppliers_Del)],[],[btnGridSettings]]);
    Frg1.InfoArray:=[['���������� �����������']];
  end
  else if FormDoc = myfrm_R_Itm_InGroup_Nomencl then begin
    Caption:='��� - ������������ � ������';
    Frg1.Opt.SetFields([
      ['id_nomencl$i','_id','40'],
      ['artikul','�������','150'],
      ['name','������������','400']
    ]);
    Frg1.Opt.SetTable('dv.nomenclatura');
    Frg1.Opt.SetWhere('where id_group = :id_group$i');
    Frg1.InfoArray:=[['������������ � ��������� ������'#13#10'������������ � �������� ������� ���� �� ����������!']];
  end
  else if FormDoc = myfrm_J_Orders_SEL_1 then begin  //!!!
    Caption:='����� �������';
    Frg1.Options := Frg1.Options + [myogIndicatorCheckBoxes, myogMultiSelect];
    Frg1.Opt.SetFields([
      ['id_order as id$i','_id','40'],
      ['path','_File','40'],
      ['ordernum','� ������','120','pic=�������� ������� ������'],
      ['year','���','40'],
      ['dt_beg','���� ����������','80'],
      ['dt_end','���� �����','80'],
      ['customer','��������','180'],
      ['project'+S.IIfStr(Length(AddParam[2]) > 2, ';'+AddParam[2]),'������'+S.IIfStr(Length(AddParam[2]) > 2, ';'+AddParam[3]),'200']
    ]);
    Frg1.Opt.SetTable('v_sn_orders');
    Frg1.Opt.SetWhere('where upper(project) like :proekt and id > 0');
    Frg1.Opt.SetButtons(1,[[btnSelectFromList],[],[btnGridFilter],[btnGridSettings]]);
    Frg1.Opt.FilterRules := [[], ['dt_beg;dt_end']];
    Frg1.InfoArray:=[[
      '�������� ���� ��� ��������� ��������� ������.'#13#10+
      '��������� ������ �������� � ����� �������, ��� ������� ����, �������� ��� ������ ������� ����������� ������ ������ ����.'#13#10+
      '�� ������ ����������� ������� ������, ����� ������ � ������� ������ ������.'#13#10+
      '��������� ������� ��� �������, ����� ��������������� ������.'
    ]];
  end
  else if FormDoc = myfrm_R_StdPspFormats then begin
    Caption:='����������� ������� ���������';
    Frg1.Options := Frg1.Options + [myogGridLabels];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['name','������������ �������','300'],
      ['active','������������','80','pic']
    ]);
    Frg1.Opt.SetTable('or_formats');
    Frg1.Opt.SetWhere(S.IIfStr(not User.IsDataEditor, ' where id > 0'));
    Frg1.Opt.SetButtons(1, 'reacds', User.Role(rOr_R_StdPspFormats_Ch));

    Frg2.Opt.SetFields([
      ['id$i','_id','40'],
      ['name','������������','200'],
      ['prefix','������� ��� ��������','120'],
      ['prefix_prod','������� ��� ������������','120'],
      ['is_semiproduct','�������������','80','pic'],
      ['active','������������','80','pic']
    ]);
    Frg2.Opt.SetTable('or_format_estimates');
    Frg2.Opt.SetWhere('where id_format = :id_format$i order by name');
    Frg2.Opt.SetButtons(1, 'reacds',User.Role(rOr_R_StdPspFormats_Ch));
  end
  else if FormDoc = myfrm_Rep_PlannedMaterials then begin
    //����� '������� ����������� � ����������'
    //��������� ������� ����������� � AfterRefresh
    va:=Q.QSelectOneRow('select dt from properties where prop = ''planned_order_estimate12'' and subprop = ''dt_beg''', []);
    va1:=Q.QSelectOneRow('select dt from properties where prop = ''planned_order_estimate12'' and subprop = ''dt_calc''', []);
    if va1[0] = null then
      va1[0] := Date;
    Caption:='������� ����������� � ����������';
    for i := 1 to 12 do
      va2 := va2 + [['qnt' + IntToStr(i), MonthsRu[MonthOf(IncMonth(TDateTime(va[0]), i - 1))], 65]];
    Frg1.Opt.SetFields(
      [['rownum as id$i','_id','40'], ['name','������������','450;h']] + va2 + [['qnt_all','�����','60']]
    );
    Frg1.Opt.SetTable('v_planned_order_estimate12');
    Frg1.Opt.SetButtons(1,[[btnRefresh, User.Role(rOr_Rep_PlannedMaterials_Calc)],[],[btnGridSettings],[],[btnCtlPanel]]);
    Caption:='������� ����������� � ����������';
    if User.Role(rOr_Rep_PlannedMaterials_Calc) then
      Frg1.CreateAddControls('1', cntDEdit, '����������: ', 'DeBeg', '', 70, yrefC, 100);
    Frg1.CreateAddControls('1', cntLabelClr, S.IIf(va[0] = null, '��� ������',
      '���� ������ �������: $FF0000 ' + S.NSt(va[0])+ ' $000000  (���������$FF0000 ' + DateTimeToStr(va1[0]) + '$000000 )'),
      'LbBeg', '', 200, yrefC, 300
    );
    Frg1.InfoArray:=[
      [Caption + '.'#13#10],
      ['����������� � ���������� �� ������ �������� �������, �� �������, �� 12 ������� ������� � ��������� ����.'#13#10+
       '�� �������� ����� � ������ ����� ����������� ������ �������� �������, �� ������� ��������� ������ ��������, '#13+#10+
       '����� ����� ������� � ��� ���� ����� � ������ ���������.'#13#10],
      ['��� ��������� ������� � ���� ������ � ������ ������������� �� �����������!'#13#10+
       '�� ������ �������� ��, ����� ��������������� ������, ���� � ��� ���� ����� �������.'#13#10+
       '��� ���� ����� ������� � ���� ����� ��������� ����� ���������� ������� (����� ������ �������� �� �����).'#13#10+
       '���������� ������ ����� ������ ������������ �����!'
      ]
    ];
  end
  else if FormDoc = myfrm_J_Devel then begin
    Caption:='������ ����������';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['develtype','��� ����������','100'],
      ['project','������','200;h'],
      ['slash','� �������','140'],
      ['name','�������� �������','300;h'],
      ['constr','�����������','120'],
      ['dt_beg','���� �������','80'],
      ['dt_plan','����. ���� �����','80'],
      ['dt_end','���� �����','80'],
      ['status','������','80'],
      ['cnt','������','80','f=f:'],
      ['time','����','80','f=f:'],
      ['comm','�����������','300;h']
    ]);
    Frg1.Opt.SetTable('v_j_development');
    Frg1.Opt.SetButtons(1,[[btnRefresh],[],[btnView],[btnEdit,User.Role(rOr_J_Devel_Ch)],[btnAdd,1],[btnCopy,1],[btnDelete,User.Role(rOr_J_Devel_Del)],[],[btnGridFilter],[],[btnGridSettings],[],[btnCtlPanel]]);
    Frg1.Opt.FilterRules := [[], ['dt_beg;dt_plan;dt_end']];
  end
  else if FormDoc = myfrm_R_Itm_Nomencl then begin
    Caption:='���������� ������������ ���';
    Frg1.Options := Frg1.Options + [myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id_nomencl$i','_id_nomencl','40'],
      ['groupname','������','100'],
      ['artikul','�������','100'],
      ['name','������������ ������������','300;h','bt=�������� �� ������������'],
      ['name_unit','��. ���.','80'],
      ['supplier','�������� ���������','120','bt=����������'],
      ['name_pos','������������ ��������� ����������','300;h'],
      ['price_main','��������� ����','80','f=r','bt=��������� ���������'],
      ['price_check','����������� ����','80','f=r'],
      ['has_files','�����','50','pic','bt=�����']
    ]);
    Frg1.Opt.SetTable('v_itm_nomencl_1');
    Frg1.Opt.SetButtons(1,[[btnRefresh],[],[btnEdit,User.Role(rOr_R_Itm_Nomencl_Rename)],[btnAdd,User.Role(rOr_R_ITM_U_Nomencl_Add)],[],[btnGridSettings]]);
    Frg1.InfoArray:=[
      [Caption+#13#10],
      ['���������� �������������� �������, ��������� � ���� ���'#13#10+
       '������������ ��� �������, �������� �� ������ ����� ���� ���.'#13#10+
       '������������ �������� ��������� ������������.'#13#10+
       '� ���� "������" ������������ ������������ ������� � ������ ������ ��� ������ ������������.'#13#10+
       '�� ������ � ������ "������������" ����� ���������� ����������� �������� �� ������ ������������.'#13#10+
       '� ������� "���������" ��������� �������� ��������� ��� ������ ������� (��� ������������). �� ������ ����� ����������'#13#10+
       '(� ��� ������� ���� ���������������) ������ ����������� ��� ������ �������.'#13#10+
       '� ������� "��������� ����" ������������ ���� ���������� ������� ������ (�� ��������� ����������!), ����� ������ ����� �����������'#13#10+
       '������ ��������� �������� �� ������. ��� ����� ��������������, � ����������� �� ����, �������� � ��� ������ ��� ������ ����������� ����.'#13#10+
       '� ������� "����������� ����" ������������ ������������� ����, �������� ��� ������� �������, ���� � ��� ���� ����� �������,'#13#10+
       '�� �� ������ ������������� ��� ����, ������ � ����� ������� ���� ������.'#13#10+
       ''#13#10],
      ['�� ������ ������������� �������������� �������, ��� ���� ������������ ��������� �� ���� ������������ � ���������� ��� � �����, ��� � � ���.'#13#10, User.Role(rOr_R_Itm_Nomencl_Rename)]
    ];
  end
  else if FormDoc = myfrm_R_bCAD_Nomencl_SEL then begin
    //����� �� ������ ������� �������, � ������ ��� ��� ����������� � ���� �� ����, ������� ������� �� ���� ���
    Caption:='���������� ������������';
    Frg1.Options := Frg1.Options + [myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['artikul','�������','120'],
      ['name','������������','300;h'],
      ['id_itm','_id_itm','40']
    ]);
    Frg1.Opt.SetTable('v_bcad_nomencl_add');
    Frg1.Opt.SetWhere('where id_itm is not null');
    Frg1.Opt.SetButtons(1, 'lrs');
    Frg1.InfoArray:=[
      ['����� ������������ bCAD.'#10#13'�������� ������������ � ������� � ������� ������ "�������" ��� ������ �������� ����� �� ������.'#10#13]
    ];
  end
  else if FormDoc = myfrm_R_Itm_Schet then begin
    //���� �� ���������� �� ���
    Caption:='���� �� ����������';
    Frg1.Opt.SetFields([
      ['id_shet_spec$i','_id','40'],
      ['articul','�������','120'],
      ['name','������������','300;h'],
      ['unit','��. ���','80'],
      ['quantity','���-��','70'],
      ['price','����','80','f=r'],
      ['sum_rur','�����','80','f=r:']
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
      MyInfoMessage('�������� �� ������!');
      Exit;
    end;
    st1 := '[� ��������� $FF0000' + VarToStr(va1[0]) + '$000000 �� $FF0000' + DateTimeToStr(va1[1]) + '$000000]    [$FF0000' +
      VarToStr(va1[2]) + '$000000]    ���������: $FF0000' + VarToStr(va1[3]) + '$000000 ';
    st2 := '���������: $FF0000' + VarToStr(va1[4]) + '$000000 ';
    Frg1.CreateAddControls('1', cntLabelClr, st1, 'LbCapt1', '', 5, yrefT, 800);
    Frg1.CreateAddControls('1', cntLabelClr, st2, 'LbCapt2', '', 5, yrefB, 800);
    Frg1.InfoArray := [['���� �� ���������� (�� ���).'#13#10'(������ ��������.)']];
  end
  else if FormDoc = myfrm_R_Itm_InBill then begin
    //��������� ��������� �� ���
    Caption:='��������� ���������';
    Frg1.Opt.SetFields([
      ['id_ibspec$i','_id','40'],
      ['artikul','�������','120'],
      ['name','������������','300;h'],
      ['name_unit','��. ���','80'],
      ['ibquantity','���-��','70'],
      ['price','����','80','f=r'],
      ['price_itogo','���� � ���','80','f=r'],
      ['itogo','�����','80','f=r:']
    ]);
    Frg1.Opt.SetTable('v_spl_nom_inbills');
    Frg1.Opt.SetWhere('where id_inbill = :id_inbill$i');
    Frg1.Opt.SetButtons(1, 'sp');
    va1:=Q.QSelectOneRow(
      'select inbillnum, inbilldate, id_docstate, '+  //�����, ���� �����������, ������ 3=���������
      'name_org, sclad, '+  //���������, �����
      'npost_num, npost_date, npost_sum, docstr '+  //��������� ��������� ���������, ���������
      'from dv.v_in_bills '+
      'where id_inbill = :id_inbill$i',
      [VarToStr(AddParam)]
    );
    if va1[0] = null then begin
      MyInfoMessage('�������� �� ������!');
      Exit;
    end;
    st1 :=
     '[� $FF0000' + VarToStr(va1[0]) + '$000000 �� $FF0000' + DateTimeToStr(va1[1]) + '$000000]    '+
     S.IIfStr(va1[2] <> 3, ' ($0000FF�� ���������$000000)   ') +
     '$000000[�����: $FF0000' + VarToStr(va1[4]) + '$000000]    ' +
     '$000000[���������: $FF0000' + VarToStr(va1[3]) + '$000000]';
    if va1[5] <> null then
      st2 := '[� ���������� $FF0000' + VarToStr(va1[5]) + '$000000 �� $FF0000' + DateTimeToStr(va1[6]) + '$000000]    ';
    st2 := st2 +
      '[�����: $FF0000' + FormatFloat( '# ###.00', S.NNum(va1[7])) + '$000000]    '+
      '[���������: $FF0000' + S.NSt(va1[8]) + '$000000]';
    Frg1.CreateAddControls('1', cntLabelClr, st1, 'LbCapt1', '', 5, yrefT, 800);
    Frg1.CreateAddControls('1', cntLabelClr, st2, 'LbCapt2', '', 5, yrefB, 800);
    Frg1.InfoArray := [['��������� ��������� (�� ���).'#13#10'(������ ��������.)']];
  end
  else if FormDoc = myfrm_R_Itm_MoveBill then begin
    Caption:='��������� �����������';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['id_doc$i','_id','40'],
      ['artikul','�������','120'],
      ['name','������������','300;h'],
      ['name_unit','��. ���','80'],
      ['quantity','���-��','70']
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
      MyInfoMessage('�������� �� ������!');
      Exit;
    end;
    st1 :=
     '[� $FF0000' + VarToStr(va1[0]) + '$000000 �� $FF0000' + DateTimeToStr(va1[1]) + '$000000]    '+
     S.IIfStr(va1[3] <> 0,  ' ($0000FF�������$000000)   ', S.IIfStr(va1[2] <> 3, ' ($0000FF�� ���������$000000)   ')) +
     '$000000[�� ������: $FF0000' + VarToStr(va1[4]) + '$000000 �� �����: $FF0000' + VarToStr(va1[5]) + '$000000]    ' +
     '$000000[�����: $FF0000' + VarToStr(va1[6]) + '$000000]';
    Frg1.CreateAddControls('1', cntLabelClr, st1, 'LbCapt1', '', 5, yrefC, 800);
    Frg1.InfoArray := [['��������� ����������� (�� ���).'#13#10'(������ ��������.)']];
  end
  else if FormDoc = myfrm_R_Itm_OffMinus then begin
    Caption:='��� ��������';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['id_doc$i','_id','40'],
      ['name','������������','300;h'],
      ['name_unit','��. ���','80'],
      ['quantity','���-��','70']
    ]);
    Frg1.Opt.SetTable('v_spl_nom_offminuses');
    Frg1.Opt.SetWhere('where id_doc = :id_doc$i');
    Frg1.Opt.SetButtons(1, 'sp');
    va1:=Q.QSelectOneRow('select numdoc, dt, id_docstate, null, skladname, basis, comments from v_spl_nom_offminuses where id_doc = :id_doc$i', [VarToStr(AddParam)]);
    if va1[0] = null then begin
      MyInfoMessage('�������� �� ������!');
      Exit;
    end;
    st1 :=
     '[� $FF0000' + VarToStr(va1[0]) + '$000000 �� $FF0000' + DateTimeToStr(va1[1]) + '$000000]    '+
     S.IIfStr(va1[2] <> 3, ' ($0000FF�� ��������$000000)   ') +
     '$000000[�� c�����: $FF0000' + VarToStr(va1[4]) + '$000000]    ' +
     '$000000[���������: $FF0000' + VarToStr(va1[5]) + ' $000000]';
    Frg1.CreateAddControls('1', cntLabelClr, st1, 'LbCapt1', '', 5, yrefT, 800);
    Frg1.CreateAddControls('1', cntLabelClr, '$000000[�����������: $FF0000' + VarToStr(va1[5]) + ' $000000]', 'LbCapt2', '', 5, yrefB, 800);
    Frg1.InfoArray := [['��� �������� (�� ���).'#13#10'(������ ��������.)']];
  end
  else if FormDoc = myfrm_R_Itm_PostPlus then begin
    Caption:='��� �������������';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['id_doc$i','_id','40'],
      ['name','������������','300;h'],
      ['name_unit','��. ���','80'],
      ['quantity','���-��','70']
    ]);
    Frg1.Opt.SetTable('v_spl_nom_postpluses');
    Frg1.Opt.SetWhere('where id_doc = :id_doc$i');
    Frg1.Opt.SetButtons(1, 'sp');
    va1:=Q.QSelectOneRow('select numdoc, dt, id_docstate, null, skladname, basis, comments from v_spl_nom_postpluses where id_doc = :id_doc$i', [VarToStr(AddParam)]);
    if va1[0] = null then begin
      MyInfoMessage('�������� �� ������!');
      Exit;
    end;
    st1 :=
     '[� $FF0000' + VarToStr(va1[0]) + '$000000 �� $FF0000' + DateTimeToStr(va1[1]) + '$000000]    '+
     S.IIfStr(va1[2] <> 3, ' ($0000FF�� ��������$000000)   ') +
     '$000000[�� c�����: $FF0000' + VarToStr(va1[4]) + '$000000]    ' +
     '$000000[���������: $FF0000' + VarToStr(va1[5]) + ' $000000]';
    Frg1.CreateAddControls('1', cntLabelClr, st1, 'LbCapt1', '', 5, yrefT, 800);
    Frg1.CreateAddControls('1', cntLabelClr, '$000000[�����������: $FF0000' + VarToStr(va1[5]) + ' $000000]', 'LbCapt2', '', 5, yrefB, 800);
    Frg1.InfoArray := [['��� ������������� (�� ���).'#13#10'(������ ��������.)']];
  end
  else if FormDoc = myfrm_R_Itm_Act then begin
    Caption:='���';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['id_doc$i','_id','40'],
      ['artikul','�������','120'],
      ['name','������������','300;h'],
      ['skladname','�� ������','80'],
      ['quantity','���-��','70']
    ]);
    Frg1.Opt.SetTable('v_spl_nom_acts');
    Frg1.Opt.SetWhere('where id_doc = :id_doc$i');
    Frg1.Opt.SetButtons(1, 'sp');
    va1:=Q.QSelectOneRow('select numdoc, dt, id_docstate, null, null, basis, comments from v_spl_nom_acts where id_doc = :id_doc$i', [VarToStr(AddParam)]);
    if va1[0] = null then begin
      MyInfoMessage('�������� �� ������!');
      Exit;
    end;
    st1 :=
     '[� $FF0000' + VarToStr(va1[0]) + '$000000 �� $FF0000' + DateTimeToStr(va1[1]) + '$000000]    '+
     S.IIfStr(va1[2] <> 3, ' ($0000FF�� ��������$000000)   ') +
     //'$000000[�����: $FF0000' + VarToStr(va1[4]) + '$000000]    ' +
     '$000000[���������: $FF0000' + VarToStr(va1[5]) + ' $000000]';
    Frg1.CreateAddControls('1', cntLabelClr, st1, 'LbCapt1', '', 5, yrefT, 800);
    Frg1.CreateAddControls('1', cntLabelClr, '$000000[�����������: $FF0000' + VarToStr(va1[5]) + ' $000000]', 'LbCapt2', '', 5, yrefB, 800);
    Frg1.InfoArray := [['��� (�� ���).'#13#10'(������ ��������.)']];
  end
  else if FormDoc = myfrm_R_OrderStdItems_SEL then begin  //!!!
    Caption:='����� ������������� �������';
     Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['fullname','������������','']
    ]);
    Frg1.Opt.SetTable('v_or_std_items');
    Frg1.Opt.SetWhere('where id_or_format_estimates > 0');
    Frg1.Opt.SetButtons(1, 'ls');
  end






  else if FormDoc = myfrm_Rep_Sgp2 then begin
    Caption:='��������� ��� (������������� �������)';
    Frg1.Opt.SetFields([
      ['id$i','_id'],
      ['slash','�','80'],
      ['name','������������','300'],
      ['dt_beg','���� ����������','80'],
      ['dt_otgr','�������� ���� ��������','80'],
      ['qnt_psp','��������','80','f=:'],
      ['qnt_in_prod','� ������������','80'],
      ['sum_in_prod','����� � ������������','80','f=r:'],
      ['qnt_sgp_registered','������� �� ���','80','f=:'],
      ['qnt_shipped','���������','80','f=:'],
      ['qnt','������� �������','80','f=:'],
      ['price','����','80', 'f=r'],
      ['sum','�����','80','f=r:']
    ]);
    Frg1.Opt.SetTable('v_sgp2');
    //Frg1.Opt.SetButtons(1, 'rfsp');
    Frg1.Opt.SetButtons(1,[[btnRefresh],[],[btnGridFilter],[-btnCustom_Revision, User.Role(rOr_Rep_Sgp_Rev),'�������'],[-btnCustom_JRevisions, 1,'������ �������'],[],[btnGridSettings]]);
    Frg1.CreateAddControls('1', cntCheck, '������ � ������� �� ���', 'ChbNot0', '', 4, yrefC, 200);
    Frg1.Opt.FilterRules := [[], ['dt_beg;dt_otgr']];
    Frg1.InfoArray:=[[Caption + '.'#13#10], [
      '� ������� ������������ � �� ��� �������������� ��������� ������ ������� ��������� '#13#10+
      '������ �� ������������� ��������.'#13#10+
      '������ ������� � �� � �������� "����������" ��������� ���������� ��������, ���� �'#13#10+
      '������ ��������� ���� ������� � ������ �� ��������������, �� ��� ������ ���������� �������� � �������.'#13#10+
      '������ � ������ ����������� �� ����� ����������� � �������� � ��� ������� �����.'#13#10+
      '��� ��������� �������� �������� �������� ������� ���, �������� ���� ����� � ����������� ����.'#13#10+
      '������� ���� �� ������� "������� �������" ������� ���� �������� �� ������ ������������.'#13#10
    ]];

  end
  else if FormDoc = myfrm_J_Sgp_Acts then begin
    Caption:='������� ���';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','�','40'],
      ['doctype','��� ���������','160'],
      ['dt','����','70'],
      ['formatname','������ �������','140'],
      ['username','������������','140']
    ]);
    Frg1.Opt.SetTable('v_sgp_revisions');
    Frg1.Opt.FilterRules := [[], ['dt']];
    Frg1.Opt.SetButtons(1, 'rfsp');
    Frg1.CreateAddControls('1', cntCheck, '��� �������', 'ChbAllFormats', '', 4, yrefC, 200);
    Frg2.Opt.SetFields([
      ['id$i','_id','40'],
      ['slash','_����','120'], //���� �� ����� �������� ����� ����, �� �� ����
      ['name','������������','300;h'],
      ['qnt','���-��','50']
    ]);
    Frg2.Opt.SetTable('v_sgp_move_list');
    Frg2.Opt.SetButtons(1,[[-btnGridSettings]]);
    Frg2.Opt.SetWhere('where id_order = :id$i and doctype = :doctype$s order by slash');
    Frg1.InfoArray:=[
      [Caption+ #13#10],
      ['������������ ������ ����� ������������� � ��������, �������������� �� ��������� ������� ���.'#13#10+
       '���� ��������� ������� "��� �������" � ��������� ����, �� ����� �������� ����, ��������� ���'#13#10+
       '���� �������� �������, ����� �� ������ ���� �� ���� �������, ������� ����� � ���� ������ �� ���.'#13#10+
       '����� �� ������ ���������� ������, �� ������� ������������ ���������, ��� ����� ����������� ����� ������ � ���������.'#13#10+
       ''#13#10+
       '������� "+" � ����� �������, ����� ���������� ������ ���������� ���� ������������� ��� ��������.'#13#10
      ]
    ];
  end

  //������ �������� �������
  else if FormDoc = myfrm_J_PlannedOrders then begin
    Caption:='�������� ������';
    Frg1.Options := Frg1.Options + [myogGridLabels];
    va2 := [
      ['id','_id'],['id_template','_id_template'],['dt','���� ��������','80'],['num','�'],['dt_start','������ ��������','80'],['dt_end','��������� ��������','80'],
      ['dt_change','���� ���������'],['std','���','40','pic'],['templatename','������','200'],['projectname','������','200'],['sum_all','�����','100','f=r:']
    ];
    for i := 1 to 12 do
      va2 := va2 + [['sum'+IntToStr(i), MonthsRu[i], '100','f=r:','t=1']];
    Frg1.Opt.SetFields(va2);
    Frg1.Opt.SetTable('v_planned_orders_w_sum');
    Frg1.Opt.SetButtons(1,[
      [btnRefresh],[],[btnView],[btnEdit,User.Role(rOr_J_PlannedOrders_Ch)],[btnCustom_OrderFromTemplate,1],[btnDelete,1],[],[btnGridFilter],[],[btnGridSettings],[],[btnCtlPanel]
    ]);
    Frg1.Opt.SetButtonsIfEmpty([btnCustom_OrderFromTemplate]);
    Frg1.CreateAddControls('1', cntCheck, '�� �������', 'ChbMonthsSum', '', 4, yrefC, 130);
    Frg1.Opt.FilterRules := [[], ['dt;dt_start;dt_end;dt_change']];
    Frg1.InfoArray:=[[Caption + '.'#13#10],
      ['������������ �� ��������� �������� �������.'#13#10+
       '��������� ������� "�� �������", ����� ������� ����� �� ������� �� ������ ����� �������� ����.'#13#10+
       '���� � ��� ���� �������������� �����, �� ������ ���������, �������������, � ������� �������� ������,'#13#10+
       '��������� ��������������� ������.'#13#10+
       '��� ���������� �������� ����������� ������� ����������� ������ �������.'#13#10]
    ];
  end
  else if FormDoc = myfrm_Rep_OrderStdItems_Err then begin
    Caption:='������ � ����������� ����������� �������';
    Frg1.Opt.SetFields([
      ['id$i','_id'],
      ['name_format','������','d=200;h'],
      ['name_otgr','������������ ��������','d=200;h'],
      ['name_prod','������������ ������������','d=200;h'],
      ['name_est','������������ � �����','d=200;h'],
      ['err_otgr$i','������ � ��������', '80', 'pic=1:3'],
      ['err_prod$i','������ � ������������', '80', 'pic=1:3']
    ]);
    Frg1.Opt.SetTable('v_std_items_errors');
    Frg1.Opt.SetButtons(1, 'r');
  end
  else if FormDoc = myfrm_J_Tasks then begin
    Frg1.Options := Frg1.Options + [myogGridLabels];
    Caption:='������ �����';
    Frg1.Opt.SetFields([
      ['id$i','_id'],
      ['id_user1$i','_id_user1'],
      ['id_user2$i','_id_user2'],
      ['type$s','��� ������','150'],
      ['name$s','������','200'],
      ['user1$s','���������','120'],
      ['user2$s','�����������','120'],
      ['dt$d','���� ���������� ������','80'],
      ['dt_beg$d','���� ������','80'],
      ['dt_planned$d','�������� ���� �����','80'],
      ['dt_end$d','���� �����','80'],
      ['state$s','������','100'],
      ['confirmed$1','������������','100','pic'],
      ['orcaption$s','�����','200;h'],
      ['itemcaption$s','�������','200;h'],
      ['comm1$s','����������� ����������','d=200;h'],
      ['comm2$s','����������� �����������','d=200;h']
    ]);
    Frg1.Opt.SetTable('v_j_tasks');
    Frg1.Opt.SetButtons(1, [[btnRefresh],[],[btnView],[btnEdit],[btnAdd {, User.Role(rOr_J_Tasks_Ch)}],[btnCopy],[btnDelete],[btnGridFilter],[],[btnGridSettings],[],[btnCtlPanel]]);
//    Frg1.CreateAddControls('1', cntCheck, '��� ������', 'ChbFromMy', '', -1, yrefC, S.IIf(User.Role(rOr_J_Tasks_Ch), 90, 0));
//    Frg1.CreateAddControls('1', cntCheck, '������ ��� ����', 'ChbForMy', '', -1, yrefC, S.IIf(User.Roles([], [rOr_J_Tasks_Ch, rOr_J_Tasks_VAll]),115,0));
    Frg1.CreateAddControls('1', cntCheck, '��� ������', 'ChbFromMy', '', -1, yrefC, 90, -1);
    Frg1.CreateAddControls('1', cntCheck, '������ ��� ����', 'ChbForMy', '', -1, yrefC, 115, -1);
    Frg1.CreateAddControls('1', cntCheck, '���', 'ChbAll', '', -1, yrefC, 45, -1);
    Frg1.CreateAddControls('1', cntCheck, '������ �� ��������������', 'ChbNotConfirmed', '', -1, yrefC, 160);
    //Frg1.ReadControlValues;
{    if not(User.Roles([], [rOr_J_Tasks_Ch, rOr_J_Tasks_VAll])) then begin
      TDBCheckBoxEh(Frg1.FindComponent('ChbForMy')).Checked := True;
      TDBCheckBoxEh(Frg1.FindComponent('ChbForMy')).Enabled := False;
    end;}
    Frg1.InfoArray:=[[Caption + '.'#13#10],
      ['�� ������ ��������� ������ ������� ���������� ��� ����, ����� ������ "��������" � �������� �����,'#13#10+
       '� ����� �������� ������ � ����������� ����������� � �������, ������������ ���, ��� ���� ������� ������ ��������������.'#13#10
       ,User.Role(rOr_J_Tasks_Ch) or True
      ],
      ['�� ������ �������� ������ � ����������� ����������� � �������, ������������ ���, ��� ���� ������� ������ ��������������.'#13#10
       ,not User.Role(rOr_J_Tasks_Ch) or True
      ],
      ['���������� ������� ������������ �����, ��������� ������� � ������ ������, ������ �������, ��� ������ � �������� �������.'#13#10
      ]
    ];
  end
  else if FormDoc = myfrm_Rep_ItmNomOverEstimate then begin
    Caption:='������������ ����� ����';
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['id_nomencl$i','_id_nomencl','40'],
      ['name$s','������������','200;w'],
      ['dt$d','����','80'],
      ['qnt$f','���-��','60']
    ]);
    Frg1.Opt.SetTable('v_itm_acts_over_estimate');
    Frg1.Opt.FilterRules := [[], ['dt']];
    Frg1.Opt.SetButtons(1, 'rfs');
    Frg1.InfoArray:=[
      ['������ ������������, �������� ����� ���� (�� ����� �������� � ������������ "�3")'#13#10],
      ['���� � ��� ������� ������� "������������ ������ �� ���������", �� ������� ���� ������ �� ������������ ��������� ������ � ��� �� ��� �� �������������� �������.']
    ];
  end
  else if FormDoc = myfrm_R_OrderTypes then begin
    Caption:='���� �������';
    Frg1.Options := Frg1.Options - [myogSorting];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['pos$i','�','40'],
      ['name$s','������������','200'],
      ['need_ref$i','��������� �� �����','80','pic'],
      ['active$i','������������','80','pic']
    ]);
    Frg1.Opt.SetWhere('where id >= 100 order by pos');
    Frg1.Opt.SetTable('order_types');
    Frg1.Opt.DialogFormDoc := myfrm_Dlg_R_OrderTypes;
    Frg1.Opt.SetButtons(1,[[btnRefresh],[], [btnEdit],[btnAdd,1],[btnDelete,1],[],[1001, '����', 'arrow_up'],[1002, '����', 'arrow_down'],[],[btnGridSettings]]);
    Frg1.InfoArray:=[
    ];
  end
  else if FormDoc = myfrm_R_WorkCellTypes then begin
    Caption:='���� ���������������� ��������';
    Frg1.Options := Frg1.Options - [myogSorting];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['pos$i','�','40'],
      ['code$s','���','60'],
      ['name$s','������������','200'],
      ['active$i','������������','80','pic']
    ]);
    Frg1.Opt.SetWhere('where id >= 100 order by pos');
    Frg1.Opt.SetTable('work_cell_types');
    Frg1.Opt.DialogFormDoc := myfrm_Dlg_R_WorkCellTypes;
    Frg1.Opt.SetButtons(1,[[btnRefresh],[], [btnEdit],[btnAdd,1],[btnDelete,1],[],[1001, '����', 'arrow_up'],[1002, '����', 'arrow_down'],[],[btnGridSettings]]);
    Frg1.InfoArray:=[
    ];
  end
  else if FormDoc = myfrm_J_OrItemsInProd then begin
    Caption:='������� � ������������';
    Frg1.Options := Frg1.Options + [myogGridLabels];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['id_order$i','_id_order','40'],
      ['area_short$s','��������','80'],
      ['slash','�','120','bt=������� ������'],
      ['itemname','�������','450;h'],
      ['dt_beg','���� �������','75'],
      ['dt_otgr','���� ��������','75'],
      ['project','������','180;h'],
      ['qnt','���-��','80'],
      ['qnt2','���-�� �������������','80'],
      ['qnt_inprod','���-�� � ������������','80'],
      ['qnt_rest','���-�� ����������','80']
    ]);
    Frg1.Opt.SetTable('v_oritms_all_in_prod_detail');
    Frg1.Opt.SetButtons(1, 'rs');
    Frg1.InfoArray:=[[
      Caption+''#13#10+
      '��� �������, ������� �������� � ������������, �� �� ������� �� ��� � ������ �������.'#13#10
    ]];
  end
  else if FormDoc = myfrm_J_ItmLog then begin
    Caption:='������ �������� ������������� ���';
    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['id_doc','_id_doc','40'],
      ['act','_act','40'],
      ['aud','_aud','100'],
      ['log_dates','����','75'],
      ['data_time','�����','150'],
      ['name','������������','120'],
      ['user_windows','�����','120'],
      ['doctype','��� ���������', '160','bt=����������� ��������'],
      ['comments','�����������','300;h'],
      ['addinfo','����������','300;h'],
      ['commentsfull','_����������� ����������','300;h']
    ]);
    Frg1.Opt.SetTable('v_itm_log');
    Frg1.Opt.FilterRules := [[], ['log_dates']];
    Frg1.Opt.SetButtons(1, 'rfsp');
    Frg1.InfoArray:=[
    ];
  end
  else if FormDoc = myfrm_J_SnHistory then begin
    Caption := '��������� �� �� ����';
    va2 := [
      ['id$i','_id','40'],
      ['dt$d','����','120'],
      ['state$s','������','120'],
      ['supplierinfo$s','�������� ���������','150'],
      ['qnta0$f','������� �������|��','60'],
      ['qnta1$f','������� �������|�','60'],
      ['qnta2$f','������� �������|��','60'],
      ['qnt$f','������� �������|�����','60'],
      ['rezerva0$f','������� ������|��','40'],
      ['rezerva1$f','������� ������|�','40'],
      ['rezerva2$f','������� ������|��','40'],
      ['rezerv$f','������� ������|�����','40'],
      ['qnt_onway$f','� ����','40'],
      ['qnt_in_processing$f','� ���������','40'],
      ['planned_need_days$i','������ �������','40','t=3'],
      ['qnt_order$f','�����|���-��','60','t=3'],
      ['to_order$i','�����|� ������','40', 'chb','t=3'],
      ['need$f','�����������|���.','60'],
      ['need_p$f','�����������|��������','60'],
      ['price_check$f','���������|����������� ����','60'],
      ['price_main$f','���������|����','60'],
      ['qnt_pl1$f','�������� ������|1''60'],
      ['qnt_pl2$f','�������� ������|2''60'],
      ['qnt_pl3$f','�������� ������|3''60'],
      ['qnt_pl$f', '�������� ������|�����','60']
    ];
    Frg1.Opt.SetFields([['name','������������','300;h']] + va2);
    Frg1.Opt.SetTable('v_spl_history', '', 'id');
    Frg2.Opt.SetFields(va2);
    Frg2.Opt.SetTable('spl_history');
    Frg2.Opt.SetWhere('where id = :id$i');
    Frg2.Opt.Caption := '������� �� ������������';
    //01-02-2025 00:10:25 �����
    Q.QSetContextValue('spl_history_date', IncSecond(EncodeDateTime(
      StrToInt(Copy(AddParam, 7, 4)), StrToInt(Copy(AddParam, 4, 2)), StrToInt(Copy(AddParam, 1, 2)),
      StrToInt(Copy(AddParam, 12, 2)), StrToInt(Copy(AddParam, 15, 2)), StrToInt(Copy(AddParam, 18, 2)), 0
    )));
  end;
  ;

  //--------------------------------------------------
  if Length(Frg1.Opt.Sql.FieldsDef) = 0 then begin
    MyWarningMessage('������! FormDoc �� ������ ��� �������� ���� �� �����!');
    Exit;
  end;
  if Length(Frg2.Opt.Sql.FieldsDef) > 0 then
    Frg2.Prepare;
  Frg1.Grid2 := Frg2;
  Frg1.Prepare;

  if (FormDoc = myfrm_J_Orders_SEL_1) then begin
    //���� ������ ������, ������ ���������� � AddParam �������� ������ ���� ����� ;, ������� ���� ��������
    //!!!������� ���������� ����������� �� ������� �� ��
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

{=========================  ������� ������� ����� =============================}

procedure TFrmXGlstMain.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
var
  i, j: Integer;
  v: Variant;
  sta: TStringDynArray;
  va: TVarDynArray;
  b: Boolean;
begin
  if fMode <> fNone then begin
    //������ ��������, ��������������, ����������, �����������
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
       //��� ������� - ������ �� ������ Add - �������� ������ � ������� ������ �� ����� �������
       if TFrmBasicInput.ShowDialog(Self, '', [], fAdd, '~�����', 150, 60,
          [[cntDEdit, '����', ':'],[cntNEdit, '�����', '1:1000000000:2']],
          [Date, Frg1.GetValue('restsum')],
          va, [['']], nil
        ) < 0 then Exit;
      Q.QCallStoredProc('p_Or_Payment' + S.IIfStr(FormDoc = myfrm_J_OrPayments_N, '_n'), 'IdOrder$i;PSum$f;PDt$d;PAdd$i', [Fr.ID, va[1], va[0], 1]);
      if Pos('�', Frg1.GetValueS('ornum')) = 1 then
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
        '����� ������� ���������� ���������'#13#10 +
        S.IIFStr(Fr.GeTValueS('workername') = '',
          '�� ������������� "' + Fr.GeTValueS('divisionname') + '"'#13#10,
          '�� ��������� "' + Fr.GeTValueS('workername') +  '"'#13#10 + '(������������� "' + Fr.GeTValueS('divisionname') + '"'#13#10
          ) +
        '�� ������ � ' + Fr.GeTValueS('dt1') +  ' �� ' + Fr.GeTValueS('dt2') + #13#10 + #13#10 + '.' +
        '����������?'
      ) = mrYes)
      and
      (MyQuestionMessage(
        '������� ���������?'
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
  //��� ��������� ������
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
    //� �� � ������ � �������� - ���������� � ����� ������ ��� ����� �����; ���� ����� ��� ��� �� �� ����, �� ����� ���������
    Clipboard.AsText :='';
    try
    sta:=TDirectory.GetFiles(Module.GetPath_Accounts_A(Fr.GetValue('filename')));
    if High(sta) = 0 then Clipboard.AsText :=sta[0];
    except
    end;
  end
  else if (FormDoc = myfrm_J_Payments)and(Tag = btnCustom_RunPayments) then begin
    //��� �������� (��������� ���������) - �������� ��� ������� �����������
    j:= 0;
    b:= False;
    //��������� ������� ������������ � ������������� � ��������������� ������� (�� ���������, ������� �� ������ �����)
    for i:=0 to Fr.GetCount - 1 do
      begin
        if S.NNum(Fr.GetValue('pstatus', i)) = 0
           //2024-01-10 - ����� ��������� ���������������!!!
           //and
           //(MemTableEh1.RecordsView.Rec[i].DataValues['agreed1', dvvValueEh] = 1)and
           //(MemTableEh1.RecordsView.Rec[i].DataValues['agreed2', dvvValueEh] = 1)
         then inc(j);
      end;
    if j = 0
      then MyInfoMessage('��� ������������� ��������')
      else b:= myMessageDlg('�������� ' + IntTostr(j) + ' ��������?', mtconfirmation, [mbYes, mbNo]) = mrYes;
    //���� ���� ������������ � ����������� ���������� �������
    if b then begin
      //������ �� ���������������
      for i:=0 to Fr.GetCount - 1 do
        begin
          if S.NNum(Fr.GetValue('pstatus', i)) = 0
           //2024-01-10 - ����� ��������� ���������������!!!
             {and
             (MemTableEh1.RecordsView.Rec[i].DataValues['agreed1', dvvValueEh] = 1)and
             (MemTableEh1.RecordsView.Rec[i].DataValues['agreed2', dvvValueEh] = 1)}
           then begin                                                                                        //and agreed1=1 and agreed2=1
             //���� �� ��������� � �����������, �� �������� ������
             Q.QExecSql('update sn_calendar_payments set status=1, dtpaid=:pdtpaid$d where id=:id$i and status <> 1',
               [Date, Fr.GetValue('pid', i)]);
           end;
        end;
      //�������.
      Fr.RefreshGrid;
    end;
  end
  else if (FormDoc = myfrm_R_Holideys) and (Tag = btnCustom_LoadFromInet) and (S.Nst(Fr.GetControlValue('CbYear')) <> '') and
    (MyQuestionMessage('��������� ���������������� ��������� �� ���� ��������'#13#10'(� ����� http://xmlcalendar.ru)?'#13#10'��� ���� ������ ����� ��������.') = mrYes) then begin
     case Tasks.GetProductionCalendar(S.NInt(Fr.GetControlValue('CbYear'))) of
       1: begin
           Fr.RefreshGrid;
           MyInfoMessage('��������� ������� ��������.')
         end;
       0: MyInfoMessage('��������� � ��������� �� ����.')
       else MyInfoMessage('������ �������� ���������!');
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

  //��������� ��������� - �����
  if (FormDoc = myfrm_J_Accounts) or (FormDoc = myfrm_J_Payments) then begin
    if TCellButtonEh(Sender).Hint = '�������� ����'
      then Sys.OpenFileOrDirectory(Module.GetPath_Accounts_A(Fr.GetValue('filename')), '���� ����� �� ������!');
    if TCellButtonEh(Sender).Hint = '�������� ������'
      then Sys.OpenFileOrDirectory(Module.GetPath_Accounts_Z(Fr.GetValue('filename')), '���� ������ �� ������!');
    if TCellButtonEh(Sender).Hint = '���� �������������' then begin
      if not Fr.RefreshRecord then
        Exit;
      if MyQuestionMessage(S.IIf(Fr.GetValue = null, '������������?', '�������� �������������?')) <> mrYes then
        Exit;
      Q.QExecSql('update sn_calendar_accounts set receiptdt = :receiptdt$d where id=:id$i',
        [S.IIf(Fr.GetValue = null, Date, null), Fr.GetValue('aid')], False
      );
      Fr.RefreshRecord;
    end;
  end;
  if (FormDoc = myfrm_J_Orders_SEL_1)or(FormDoc = myfrm_J_OrPayments)or(FormDoc = myfrm_J_OrPayments_N) then begin
    //������� ������� ������
    Wh.ExecDialog(myfrm_Dlg_Order, Self, [], fView, Fr.ID, null);
  end;
  if (FormDoc = myfrm_R_Itm_Nomencl) then begin
    //��� �� ����������� ������ ������������ ��� ����������� � ��������, �� �� �� ��������� � ���������� � ��� �� �����������
    if TCellButtonEh(Sender).Hint = '�������� �� ������������' then
      TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_MoveNomencl, [myfoSizeable, myfoDialog], fView, Fr.ID, VarArrayOf([Fr.GetValueS('name'), Fr.GetValueS('name_unit')]));
    if TCellButtonEh(Sender).Hint = '����������' then begin
      Wh.ExecDialog(myfrm_Dlg_SupplierMinPart, Self, [myfoSizeable], S.IIf(User.Role(rOr_Other_R_MinRemains_Ch_Suppl), fEdit, fView), Fr.ID, VarArrayOf([Fr.GetValueS('name'), Fr.GetValueS('name_unit')]));
    end;
    if TCellButtonEh(Sender).Hint = '��������� ���������' then
      TDlg_Spl_InfoGrid.Create(Self, myfrm_Dlg_Spl_InfoGrid_InBillList, [myfoSizeable, myfoDialog], fView, Fr.ID, VarArrayOf([Fr.GetValueS('name'), Fr.GetValueS('name_unit')]));
    if TCellButtonEh(Sender).Hint = '�����' then begin
      TFrmODedtNomenclFiles.ShowDialog(Self, Fr.ID);
    end;
  end;

  if (FormDoc = myfrm_J_ItmLog) then begin
    Orders.ViewItmDocumentFromLog(Self, Fr.ID);
  end;
  if (FormDoc = myfrm_R_Or_ItmExtNomencl)and(TCellButtonEh(Sender).Hint = '�������� ������������') then begin
    Wh.ExecDialog(myfrm_Dlg_Spl_InfoGrid_MoveNomencl, Self, [myfoModal, myfoSizeable], S.IIf(User.Role(rOr_Other_R_MinRemains_Ch_Suppl), fEdit, fView),
      Fr.GetValue('id_nomencl'), VararrayOf([Fr.GetValueS('name'), ''])
    );
  end;
  if (FormDoc = myfrm_R_Or_ItmExtNomencl)and(TCellButtonEh(Sender).Hint = '����������� �� �������') then begin
    Wh.ExecDialog(myfrm_Dlg_Spl_InfoGrid_DiffInOrder, Self, [myfoModal, myfoSizeable], S.IIf(User.Role(rOr_Other_R_MinRemains_Ch_Suppl), fEdit, fView),
      Fr.GetValue('id_nomencl'), VararrayOf([Fr.GetValueS('name'), ''])
    );
  end;
  if A.InArray(FormDoc, [myfrm_J_OrItemsInProd]) then begin
    //������ ��������� ������
    Wh.ExecDialog(myfrm_Dlg_Order, Self, [], fView, Fr.GetValue('id_order'), null);
  end;
end;

procedure TFrmXGlstMain.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
var
  b1, b2, b3: Boolean;
begin
  if ((FormDoc = myfrm_J_Accounts)or(FormDoc = myfrm_J_Payments)) and Fr.IsNotEmpty then begin
//    (rPC_A_ChSelf,'������ "��������� ���������"','�����','�������� ����� �� ��������� ����������, �������������� � �������� ����� ������'),
//    (rPC_A_ChSelfCat,'������ "��������� ���������"','�����','��������/��������������/�������� ����� �� ��������� ����������'),
    b1:= False; b2:= False; b3:= False;
    //�������� ����� - ����� ����� �� ��������/��������������
    if (User.Roles([], [rPC_A_ChSelf, rPC_A_ChSelfCat, rPC_A_ChAll])) then b1:= True;
    //�������������� ����
    if (User.Roles([], [rPC_A_ChAll])) then b2:= True;
    //�������������� �� ���������
    if (not b2) and (User.Roles([], [rPC_A_ChSelfCat])) and (S.NNum(Fr.GetValue('useravail')) = 1) then b2:= True;
    //�������������� ������ �����
    if (not b2) and (User.Roles([], [rPC_A_ChSelf])) and (S.NSt(Fr.GetValue('username')) = User.GetName) then b2:= True;
    //�������� ������ ��������������� � �� ����������
    if b2 then b3 := (S.NNum(Fr.GetValue('agreed1')) = 0)and(S.NNum(Fr.GetValue('agreed2')) = 0)
      and(S.NNum(Fr.GetValue(S.IIf(FormDoc = myfrm_J_Accounts, 'paidsum', 'psum'))) = 0);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, btnEdit, null, b2);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, btnCopy, null, b2);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, btnDelete, null, b3);
  end;

  if (FormDoc = myfrm_J_Turv) and Fr.IsNotEmpty then
    //��� ����, �� �������������� ������ ��������� ������������� � ������ ���� ������ �� ������
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
    //�������� ����������
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
      //������ ��������� ������!!! (� ������ ������ ���������)
      //������� ������, ������ � ���������� ���� ��� ���� �������
      bbb:=true;
      if not Fr.RefreshRecord then Exit;
      bbb:=true;
      //��������, �� ����� �� ������� ������ ���������������, ���������� ���������� ������ ������� ������ �� ��
      Frg1GetCellReadOnly(Fr, No, Sender, ReadOnly);
      if ReadOnly then begin
        //���� ������������� ������, ������� (Cancel ������ �� ����������� ���� ������ Handled)
        Handled := True;
        bbb:=false;
        Exit;
      end;
  //    if TColumnEh(Sender).ReadOnly then MyInfoMessage('!!!');
      //��������� �������� � �������. ��� �� �����, ���� ����� ������������ ������.
      //�� ���������� ��������������� ������� (�����: Fr.RecNo - 1 !). ��� ����, ������ � ������� ��� ���������
      //�� ���������, ���� ���� ������� DefaultApplyFilter (�� ��������� ���  RefreshRecord))
  //    Fr.SetValue('active', Fr.RecNo - 1, True, Value);
      //��� � ������� ������, �� ��������� ������ Post (������ � ������� ���������)
      Fr.SetValue('active', Value);
      //������� �������� � �� (������ � ������ ��������� �� �����������)
      Q.QExecSql('update ref_test2 set active = :active$i where id = :id$i', [Value, Fr.ID]);
      //���� �� ���������, �� ��������� ��������� ����
  //  Fr.RefreshRecord;
      bbb:=false;
      //�����������
      Handled := True;
    end
    else FHandled := False;
  end;

  if not FHandled then begin
    {��������� ��� ������, �����  ��� ��������� �����, ���������� ������ ������������ � �� � ����� ������}
    repeat
    FHandled := True;
    if FormDoc = myfrm_J_Accounts then begin
      //�� - �����. ������������� ���� ��� ������� ���� �� ����
      b:= User.Roles([], [rPC_A_AgrAll]);
      b:= b or User.Roles([], [rPC_A_AgrSelfCat]) and S.InCommaStr(IntToStr(User.GetId), S.NSt(Fr.GetValue('useragreed'))) ;
      if ((Fr.CurrField = 'agreed1') and b) or ((Fr.CurrField = 'agreed2') and User.Roles([], [rPC_A_AgrDir])) then begin
        if (Fr.CurrField = 'agreed1')
          then st:='������������'
          else st:='��������';
        if Fr.RefreshRecord then begin
          i:= S.NInt(Fr.GetValue(Fr.CurrField));
          if MyQuestionMessage(S.IIf(i = 0, '����������� ����'#10#13'('+st+') ?', '�������� ������������ �����'#10#13'('+st+') ?')) = mrYes then begin
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
        if MyQuestionMessage(S.IIf(i = 0, '�������� �����?', '�������� ���������� �������?')) = mrYes then begin
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
      //�������� ��������������� �������
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
    //������ ����� - ��� ���� ��������� ����� ���� ������� ������ ����, � ������ ������� ������� (�������� ��� �����������)
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

  //�������� ����� ��� ���� ���������� ��� ������ ��������
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
    //��������� ������ ��� ������ ���� ��������� ��������, �� ������� ����� �� ����� ������ ��� ����� ��������, ������������� � �������� (� ������ ���)
    if (Fr.GetValue('sum_d') <> null) and (Fr.GetValue('accounttype') = 1) and (Fr.GetValue('sum') > Fr.GetValue('sum_d')) then
      Params.Background := clmyPink;
  end
  else if FormDoc = myfrm_Rep_SnCalendar_AccMontage then begin
      //��������� ������ ��� ������ �� �������, �� ������� ����� �� ����� ������ ��� ����� �������, ������������� � �������� (� ������ ���)
    if (Fr.GetValue('sum') > Fr.GetValue('sum_m')) then
      Params.Background := clmyPink;
  end

  else if (FormDoc = myfrm_R_Itm_Nomencl) and (FieldName = 'price_main') then begin
      //��������� ��������� ���� ��������� ����������, ���� �������� ����� ���������� ���� �� �� �����, ������������� ������� ��� �������
    if Trunc(Fr.GetValueF('price_main')) < Trunc(Fr.GetValueF('price_check')) then
      Params.Background := RGB(180, 255, 180);  //�����������
    if Trunc(Fr.GetValueF('price_main')) > Trunc(Fr.GetValueF('price_check')) then
      Params.Background := RGB(255, 180, 180);  //�������
  end
  else if FormDoc = myfrm_J_Tasks then begin
    //��������� ������� �������� ���� � ������� �����, ���� ���� ����� ����������
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
      ReadOnly := ((Fr.GetValue('dt_end') <> null) or (Fr.GetValue('cashtypename') <> '������'))
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
    if TFrmBasicInput.ShowDialog(Self, '', [], fEdit, '����������� ����', 200, 100,
      [[cntNEdit, '����������� ����', '0:100000000:2:+', 80]],  //� ������� 3 �� ������ N, �� �� ����� ��������� �������� ��������
      va, va, [['����������� ����']], nil
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


{=========================  ������� ������� ����� =============================}

procedure TFrmXGlstMain.Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
var
  va: TVarDynArray;
begin
  if fMode <> fNone then begin
    if ((FormDoc = myfrm_J_OrPayments)or(FormDoc = myfrm_J_OrPayments_N)) then begin
      //����� ������� ����� ������� �� ������ � ������� �������� �� �������
       if TFrmBasicInput.ShowDialog(Self, '', [], fMode, '~�����', 150, 60,
          [[cntDEdit, '����', ':'],[cntNEdit, '�����', '1:1000000000:2']],
          [S.IIf(fMode = fAdd, Date, Fr.GetValue('dt')), S.IIf(fMode <> fAdd, Fr.GetValue('sum'), Frg1.GetValue('restsum'))],
          va, [['']], nil
        ) < 0 then Exit;
      Q.QCallStoredProc('p_Or_Payment' + S.IIfStr(FormDoc = myfrm_J_OrPayments_N, '_n'), 'IdOrder$i;PSum$f;PDt$d;PAdd$i',
        [Frg1.ID, S.IIf(fMode = fDelete, 0, va[1]), va[0], S.IIf(fMode = fAdd, 1, 0)]
      );
      if Pos('�', Frg1.GetValueS('ornum')) = 1 then
        Orders.FinalizeOrder(Frg1.ID, myOrFinalizePay);
      Fr.RefreshGrid;
      Frg1.SetRowDetailPanelSize;
      Frg1.RefreshRecord;
    end;
  //������ ����������� �������� ���������
    if (FormDoc = myfrm_R_StdPspFormats) then begin
      //������� ���� ��� ����������� ��������� ������ (����� ������ �������)
      if Frg1.ID <= 1 then
        Exit; //��� ����� � ���.�����. ������ ��������� / ������������� ������
      if Fr.IsNotEmpty and (fMode <> fAdd)
        then va := [Fr.GetValueS('name'), Fr.GetValueS('prefix'), Fr.GetValueS('prefix_prod'), S.IIf(Fr.GetValueI('is_semiproduct') = 1 , True, False), S.IIf(Fr.GetValueI('active') = 1 , True, False)]
        else va := ['', '', True];
      if TFrmBasicInput.ShowDialog(FrmMain, '', [], fMode, '��������� �����', 300, 80, [
        [cntEdit,'������������','1:400:0', 210],
        [cntEdit,'������� ���'#13#10'��������','1:20:0', 100],
        [cntEdit,'������� ���'#13#10'������������','1:20:0', 100],
        [cntCheck,'���������������','', 100],
        [cntCheckX,'������������','', 100]
       ], va, va, [['']], nil) < 0
      then Exit;
      if Q.QIUD(Q.QFModeToIUD(fMode), 'or_format_estimates', '', 'id$i;id_format$i;name$s;prefix$s;prefix_prod$s;is_semiproduct$i;active$i',
        [Fr.ID, Frg1.ID, va[0], va[1], va[2], va[3], va[4]]) < 0 then
        MyWarningMessage('�� ������� �������� ������!');
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
  //����� ����� ����� �������� ��������� ���������� �����
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

    Caption:='�������� ������';
    Frg1.Options := Frg1.Options + [myogGridLabels];
    //����, ��� ������ � ������������� ����� ��������� 'id', ��� �������� �� ������� ����������� 'id$i'
    va2 := [
      ['id','_id'],['id_template','_id_template'],['dt','���� ��������','80'],['num','�'],['dt_start','������ ��������','80'],['dt_end','��������� ��������','80'],
      ['dt_change','���� ���������'],['std','���','40','pic'],['templatename','������','200'],['projectname','������','200'],['sum_all','�����','100','f=r:']
    ];
    //������� �����������
    for i := 1 to 1 do
      va2 := va2 + [['sum'+IntToStr(i), MonthsRu[i], '100','f=r:','t=1']];
    //��������� ����, ��� ��������� ������ ����� �����!!!
    Frg1.Opt.SetFields(va2);
    //�������, ������ ����� ���, �� ����� �������� � ������� � ���� ����
    Frg1.Opt.SetTable('v_planned_orders_w_sum');
    //������, � ������������ �����. ���� ���� ��� ��������, ����������� ������� btnCtlPanel, �� ����� �� ��������� ���������� ��� ��������
    Frg1.Opt.SetButtons(1,[
      [btnRefresh],[],[btnView],[btnEdit,User.Role(rOr_J_PlannedOrders_Ch)],[btnCustom_OrderFromTemplate,1],[btnDelete,1],[],[btnGridFilter],[],[btnGridSettings],[btnCtlPanel{, True, 140}]
    ]);
    //���, ���� �� �� ���� ������������� ������, ����� ������� ���, ������ �� ������ ������, �������, ���������/��������������,������,���������,
    //������, ����� ����� �� ��� ����������� � ��������� ��������, � ���� ��� ����� ��������������, �� ��������� ����
     //Frg1.Opt.SetButtons(1, 'rveacdfsp'? ARight);
    Frg1.Opt.SetButtonsIfEmpty([btnCustom_OrderFromTemplate]);
    //������� ��������
    Frg1.CreateAddControls('1', cntCheck, '�� �������', 'ChbMonthsSum', '', 4, yrefC, 130);
    //���� ���� ���� ���������� �������� �����, �� ����������, ����� ���������� �� ��������, � ������� ��������� ��������� �����
    //� ������� ������� ����� �� ������, �������� ����������� � Frg1.Prepare, ����� �������� ��������, ����� ���� ��������� ������� �� ���������
    //(���� ���� �������� ���������� � ����������), ��� ����������� ������
    //(���� ���������� Fr.InPrepare � � ���� ������ �������� �� ������ Refresh ��� SelcolumnsVisible
    Frg1.ReadControlValues;
    if not (User.Role(rOr_J_Orders_Sum)or(User.Role(rOr_J_Orders_PrimeCost))) then begin
      Cth.SetControlValue(TDBCheckBoxEh(Frg1.FindComponent('ChbViewSum')), 0);
      Frg2.Opt.SetColFeature('1', 'null', True, False);
    end;
    Frg2.Opt.SetColFeature('1', 'i', Cth.GetControlValue(Frg1, 'ChbViewSum') = 0, False);
    //������ (help, ���� ��� ���� �� ����, �������� � �������
    Frg1.Opt.FilterRules := [[], ['dt;dt_start;dt_end;dt_change']];
    //Frg1.Opt.FilterRules := [[], ['dt_beg;dt_otgr;dt_end'], ['�������� �������������', 'Sum0', User.Role(rOr_J_Orders_Sum)]];
    //��������� � ������ ������ ������
    Frg1.InfoArray:=[
      [Caption + '.'#13#10]
    ];

{    FOpt.StatusBarMode := stbmDialog;
    FOpt.DlgPanelStyle := dpsBottomRight;
    Frg1.Opt.SetButtons(1, [[btnAdd]], 4, PDlgBtnR);
    FMode := fView;}

      //��������, � ������ ����� ":"
      //1 - �������� �����, ����� ����� � �������
      //2 - ��������������� �� ������� ��������
      //3 - ���� +, �� ����������� � �����
      //���� ������ �� ������, �� ����� ����� ��� �������� "1", ���� ����� ������ ���� ��������, �� ����� ����� ��� ����


  //��� ���������� ��������� � �������, ������� onChange �� ����������!
  //�������� � ����� -1..-10 ���������� ��� ������������, � -11..-20 ��� ��, �� � ������������ ������

*)


�������� ����������� ���������� �������� ������ (�� ������) - ����� �� ���������� myfrm_Rep_SnCalendar_Transport

{$R *.dfm}

end.
