unit uFrmTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, System.IoUtils,
  DBCtrlsEh, Vcl.ExtCtrls, ComObj, Vcl.Grids,
  IdBaseComponent, IdTCPConnection, IdTCPClient, Types,
  IdSMTP//, EASendMailObjLib_TLB
  ,uLabelColors
  ,XlsMemFilesEh
  ,data.sqlexpr, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.Oracle,
  Data.DB, FireDAC.Comp.Client, FireDAC.VCLUI.Wait,

  ADODb, Vcl.DBCtrls, Vcl.Menus, DBGridEh, DBLookupEh,
  Vcl.ComCtrls, ToolCtrlsEh, DBGridEhToolCtrls,
  MemTableDataEh, MemTableEh, EhLibVclUtils, GridsEh, DBAxisGridsEh,
  DBGridEhGrouping, DynVarsEh, IdComponent, IdExplicitTLSClientServerBase,
  IdMessageClient, IdSMTPBase, Vcl.Mask;

type
  TFrmTest = class(TForm)
    BitBtn1: TBitBtn;
    DBComboBoxEh1: TDBComboBoxEh;
    DBCheckBoxEh1: TDBCheckBoxEh;
    DBRadioGroupEh1: TDBRadioGroupEh;
    DBCheckBoxEh2: TDBCheckBoxEh;
    DBCheckBoxEh3: TDBCheckBoxEh;
    DBNumberEditEh1: TDBNumberEditEh;
    DBDateTimeEditEh1: TDBDateTimeEditEh;
    bt_fromxls: TBitBtn;
    StringGrid1: TStringGrid;
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    Button1: TButton;
    IdSMTP1: TIdSMTP;
    Bt_LoadXLSM: TBitBtn;
    LabeledEdit1: TLabeledEdit;
    lbl1: TLabel;
    Bt_Dlg_BasicInput: TBitBtn;
    Bt_LoadXLS: TBitBtn;
    Bt_SaveXLSX: TBitBtn;
    Edit1: TEdit;
    DBDateTimeEditEh2: TDBDateTimeEditEh;
    DataSource1: TDataSource;
    Bt_FastReport: TBitBtn;
    Button2: TButton;
    PopupMenu1: TPopupMenu;
    N11: TMenuItem;
    N21: TMenuItem;
    N31: TMenuItem;
    btn1: TSpeedButton;
    Bt_Tree: TBitBtn;
    DBLookupComboboxEh1: TDBLookupComboboxEh;
    ProgressBar1: TProgressBar;
    pnl_Btns: TPanel;
    CheckBox1: TCheckBox;
    lbl2: TLabel;
    pnl1: TPanel;
    edt_1: TDBEditEh;
    l1: TLabel;
    l2: TLabel;
    bv3: TBevel;
    e4: TDBEditEh;
    chb4: TCheckBox;
    Bt_Align: TBitBtn;
    bt_44: TBitBtn;
    DBEditEh1: TDBEditEh;
    DBEditEh2: TDBEditEh;
    PopupMenu2: TPopupMenu;
    asdasd1: TMenuItem;
    asdadasdsadasdsaf1: TMenuItem;
    FlowPanel2: TFlowPanel;
    Panel2: TPanel;
    Image1: TImage;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    CheckBox2: TCheckBox;
    Image2: TImage;
    SpeedButton2: TSpeedButton;
    DBGridEh1: TDBGridEh;
    MemTableEh1: TMemTableEh;
    BitBtn4: TBitBtn;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure DBNumberEditEh1Change(Sender: TObject);
    procedure bt_fromxlsClick(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Bt_LoadXLSMClick(Sender: TObject);
    procedure lbl1Click(Sender: TObject);
    procedure Bt_Dlg_BasicInputClick(Sender: TObject);
    procedure Bt_LoadXLSClick(Sender: TObject);
    procedure LabeledEdit1Change(Sender: TObject);
    procedure Bt_SaveXLSXClick(Sender: TObject);
    procedure Bt_FastReportClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Bt_TreeClick(Sender: TObject);
    procedure Bt_AlignClick(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
  private
    { Private declarations }
    procedure Change(Sender: TObject);
  public
    { Public declarations }
  end;

var
  FrmTest: TFrmTest;

procedure TestProcedure1;
procedure TestProcedure2;
procedure TestProcedure3;


implementation

uses
  uFrmMain,
  uForms,
  uDBOra,
  uWindows,
  uMessages,
  //~F_D_Turv,
  uData,
  uString,
  uTurv,
  uExcel,
  //D_Grid1,
  //D_CandidatesFromWorkerStatus,
  ZLib,
  uTasks,
  uOrders,




  F_TestTree,
  uSys,
  uErrors,

  uFrmCWAcoountBasis,


  uFrmXDedtMemo,

  idmessage,

  uFrmXWAbout, V_MDI,



  F_Adm_Installer,

  //uFrmRepSgp,
  uFrmTestMdi1,
  //uFrmDlgFindNameInEstimates,



  uFrmBasicInput,


  uFrmOGedtSnMain,

  uFrmCDedtCashRevision,
  uFrmBasicEditabelGrid,
  uFrmOWOrder,

  uFrmWGEdtTurv,
  uFrmOGedtEstimate,
  uFrmCDedtAccount,
  uFrmWWedtWorkSchedule
  ;




{$R *.dfm}

procedure TFrmTest.BitBtn1Click(Sender: TObject);
type
  ttt = (v1=1, v2=190000, v3=3);
var
  st: widestring;
  i,j,k:Integer;
  v:Variant;
  vttr: ttt;
  msg:TIdMessage;
  ar2, ar22: TVarDynArray2;
  va: TVarDynArray;
  dt: TDateTime;
//  oSmtp : TMail;
st1: string;
ch: Char;

  //IdSMTP1.AuthenticationType:=atLogin;

procedure testsql1();
var
  Query: TSQLQuery;
  Con: TSQLConnection;
  Param: TParam;
  v, v1, v2: Variant;
begin
{  v:=QIUD('i', 'test1', '', 'id$i;account', VarArrayOf([-1, '00test10000']));
  v1:=MyData.QOra.Parameters[1].Name;
  v2:=MyData.QOra.Parameters[1].value;
  v2:=QGetReturnValues('id')[0];
  v2:=QGetReturnValues(VarArrayOf(['id$ir']))[0];
  exit;

  QExecSql('insert into test1 (account) values (:account) returning id into :id$ir', VarArrayOf(['00test10000', -1]));
  v1:=MyData.QOra.Parameters[1].Name;
  v2:=MyData.QOra.Parameters[1].value;
  v2:=QGetReturnValues('id')[0];
  v2:=QGetReturnValues(VarArrayOf(['id$ir']))[0];}
  exit;

{
  //через FireDAC
//  FDConnection1.ConnectionString:=ConnectionString;
  FDConnection1.Connected:=True;
  FDQuery1.SQL.text:='insert into test1 (id) values (10000) returning id into :id';
  FDQuery1.ParamByName('id').DataType:=ftInteger;
  FDQuery1.ParamByName('id').ParamType:=ptResult;
  FDQuery1.ExecSQL;
  v1:=FDQuery1.ParamByName('id').Value;
  v2:=FDQuery1.RowsAffected;
//  exit;
}
  //так не работает, возвращает исходное значение параметра
{  MyData.QOra.SQL.Text:='insert into test1 (id) values (10000) returning id into :id';
  MyData.QOra.Parameters.ParamByName('id').value:=1;
  MyData.QOra.Parameters.ParamByName('id').DataType:=ftInteger;
  MyData.QOra.Parameters.ParamByName('id').Direction:=pdReturnValue;
  MyData.QOra.Parameters.ParamByName('id').Attributes:=[paNullable];
  MyData.QOra.ExecSQL;
  v:=MyData.QOra.Parameters.ParamByName('id').value;
  QExecSQL('delete from test1 where id =:id$i', 10000);
  v1:=MyData.QOra.RowsAffected;}
  exit;

  //так описано получение результата вставки ключевым словом returning
//для другого типа соединения нежели использую я
//проверить не удалось, при выполнении execsql ора-03106
{  Query := TSQLQuery.Create( nil);
  Query.SQLConnection := mydata.SQLConnection1;
//  mydata.CnOra.Connected:=False;
  mydata.SQLConnection1.Connected:=True;
  Query.SQL.text:='insert into test1 (id) values (10000) returning id into :id';
  Param := Query.ParamByName('id');
  Param.DataType  := ftString;
  Param.ParamType := ptInput;
  Param.AsString  := '';//Doc.XML.Text;
  Query.ExecSQL;
  v:=Param.Value;
  Query.Close;
  Query.Free;}
end;

procedure Test_RandomValuesIntoOrderStagesTable;
var
  i,j,k:Integer;
  v:Variant;
  ar2, ar22: TVarDynArray2;
  va: TVarDynArray;
begin
  try
  if MyQuestionMessage('Заполнить таблицу этапов заказа?') <> mrYes Then Exit;
{  QBeginTrans;
  Randomize;
  ar2:=QLoadToVarDynArray2('select id, qnt, dt_beg from v_order_items where qnt > 0 and dt_end is null', null);
  QExecSql('delete from order_item_stages', null);
  for i:=0 to High(ar2) do begin
    for j:=1 to 10 do begin
      va:=[];
      for k:=1 to 3 do begin
        if Random(3) < 2 then begin
          if Random(6) = 0
            then dt:= Date
            else dt:= IncDay(VarToDateTime(ar2[i][0]), Random(10));
        end;
        if Ar.InArray(dt, va) then Continue;
        va:=va+[dt];
        QExecSql('insert into order_item_stages (id_stage, id_order_item, qnt, dt) values (:id_stage$i, :id_order_item$i, :qnt$i, :dt$d)',
          VarArrayOf([j, ar2[i][0], Random((ar2[i][1] div 2) +1), dt])
        );
      end;
    end;
  end;
  QCommitTrans;}
  except
  Q.QRollbackTrans;
  end;
end;

procedure Test_Set_Order_Payments;
var
  i,j,k:Integer;
  v:Variant;
  ar2, ar22: TVarDynArray2;
  va, va2, va3: TVarDynArray;
  res: Integer;
begin
{  try
  if MyQuestionMessage('Заполнить таблицу платежей по заказам?') <> mrYes Then Exit;
  QBeginTrans;
  ar2:=QLoadToVarDynArray2('select id_order, dt, sum(sum) from sn_order_payments where dt < :dt$d group by id_order, dt', EncodeDate(2024,05,19));
  QExecSql('delete from or_payments', null);
  //QExecSql('delete from or_payments_n', null);
  repeat
  for i:= 0 to High(ar2) do begin
    res:=QExecSql('insert into or_payments (id_order, dt, sum) values (:id_order$i, :dt$d, :sum$f)', VarArrayOf([ar2[i][0],ar2[i][1],ar2[i][2]]));
    if res < 0 then break;
  end;
  if res < 0 then break;
  ar2:=[];
  ar2:=QLoadToVarDynArray2('select id_order, sum(sum) from or_payments group by id_order', null);
  for i:= 0 to High(ar2) do begin
    res:=QExecSql('update orders set pay = :pay$f where id = :id_order$i', VarArrayOf([ar2[i][1],ar2[i][0]]));
    if res < 0 then break;
  end;
  until True;
  finally
  QCommitOrRollback(res >= 0);
  end;}
end;



procedure Test_SetStages_SGP;
var
  i,j,k:Integer;
  v:Variant;
  ar2, ar22: TVarDynArray2;
  va, va2, va3: TVarDynArray;
begin
{  try
  if MyQuestionMessage('Заполнить таблицу приемки/отгрузки по СГП?') <> mrYes Then Exit;
  QBeginTrans;
  Randomize;
  ar2:=QLoadToVarDynArray2('select id, qnt, dt_end, sgp, id_order, id_organization from v_order_items where id_order > 0 and qnt > 0 and dt_end is not null', null);
  QExecSql('delete from order_item_stages', null);
  va2:=[]; va3:=[];
  for i:=0 to High(ar2) do begin
    if ar2[i][3] <> 1 then begin
      //для всех позиций всех заказов кроме позиций с сгп добавим запаись на дату окончания  = шаг 2
      QExecSql('insert into order_item_stages (id_stage, id_order_item, qnt, dt) values (:id_stage$i, :id_order_item$i, :qnt$f, :dt$d)',
        VarArrayOf([2, ar2[i][0], ar2[i][1], ar2[i][2]])
      );
      //if (High(va2) = -1)or((High(va2) >= 0)and(va2[High(va2)-1]<>ar2[i][4])) then va2:=va2 + [ar2[i][4]];
      va2:=va2 + [ar2[i][4]];
    end;
    if ar2[i][5] <> -1 then begin
      //для всех заказов кроме производственных добавим запись на дату окончания = шаг 3
      QExecSql('insert into order_item_stages (id_stage, id_order_item, qnt, dt) values (:id_stage$i, :id_order_item$i, :qnt$f, :dt$d)',
        VarArrayOf([3, ar2[i][0], ar2[i][1], ar2[i][2]])
      );
      //if (High(va3) = -1)or((High(va3) >= 0)and(va3[High(va3)-1]<>ar2[i][4])) then va3:=va3 + [ar2[i][4]];
      va3:=va3 + [ar2[i][4]];
    end;
  end;
  ar2:=QLoadToVarDynArray2('select id, dt_end, id_organization from v_orders where id > 0 and dt_end is not null', null);
  for i:=0 to High(ar2) do begin
//    QExecSql('update orders set dt_to_sgp = :dt1$d, dt_from_sgp = :dt2$d where id = :id$i',
//      VarArrayOf([ar2[i][1],  S.IIf(ar2[i][2] = -1, null,ar2[i][1]), ar2[i][0]])
//    );
//   QCallStoredProc('pnl_OrderStage_SetMainTable', 'IdOrder$i;IdStage$i', VarArrayOf([ar2[i][0], 2]));
//    QCallStoredProc('pnl_OrderStage_SetMainTable', 'IdOrder$i;IdStage$i', VarArrayOf([ar2[i][0], 3]));
    QExecSql('update orders set dt_to_sgp = :dt1$d, dt_from_sgp = :dt2$d where id = :id$i',
      VarArrayOf([S.IIf(Ar.InArray(ar2[i][0], va2), ar2[i][1], null),  S.IIf(Ar.InArray(ar2[i][0], va3), ar2[i][1], null), ar2[i][0]])
    );
  end;
  QCommitTrans;
  except
  QRollbackTrans;
  Exit;
  end;}
end;

procedure Test_DelResaleStd;
//убрать стандартные Д/К
//меняем им группу в стд изделиях на нестандартные,
//создаем для них в бкад_номенкл записи
//изделия в ордер_итемся меняем на нестандартные и не д/к
//меняем в сметах сслылку на д/к на ссылку на бкад_ном и группу на_удаление
var
  i,j,k:Integer;
  v:Variant;
  ar2, ar22: TVarDynArray2;
  va, va2, va3: TVarDynArray;
  Res:Integer;
begin
  if MyQuestionMessage('Преобразовать Д/К (стд)?') <> mrYes Then Exit;
  ar2:=Q.QLoadToVarDynArray2('select id, name, null from or_std_items where id_or_format_estimates = 1', []);
  Q.QBeginTrans;
  Res:=-1;
  repeat
  if Q.QExecSql('update or_std_items set id_or_format_estimates = 0, resale = 0, price = null, price_pp = null, name =''ДК_'' || name where id_or_format_estimates = 1', [] ) < 0
    then Break;
  for i:=0 to High(ar2) do begin
    ar2[i][2]:=Q.QIUD('i','bcad_nomencl','','id$i;name$s', [-1, ar2[i][1]]);
    Res:=ar2[i][2];
    if Res < 0 then Break;
  end;
  if Res < 0 then Break;
  if Q.QExecSql('update order_items set resale = 0, std = 0, nstd = 1 where std = 1 and resale = 1', []) < 0 then Break;
  for i:=0 to High(ar2) do begin
    Res:=Q.QExecSql('update estimate_items set id_group=109, id_name_resale = null, id_name = :id1$i where id_name_resale = :id0$i', [ar2[i][2], ar2[i][0]]);
    if Res < 0 then Break;
  end;
  for i:=0 to High(ar2) do begin
    Res:=Q.QExecSql('delete from estimates where id_std_item = :id0$i', [ar2[i][0]]);
    if Res < 0 then Break;
  end;
  Res := 0;
  until True;
  Q.QCommitOrRollback(res >= 0);
end;

procedure Test_DelResaleNStd;
//убрать нестандартные Д/К
//получис список нестандартных д.к изделий из ордер_итемс
//создаем для них в бкад_номенкл в группе На удаление записи, рапвные назв изделия + "_"
//в ордер_итемс снимеаем флаг д/к
//меняем в сметах сслылку на д/к на ссылку на бкад_ном и группу на_удаление
var
  i,j,k:Integer;
  v:Variant;
  ar2, ar22: TVarDynArray2;
  va, va2, va3: TVarDynArray;
  Res:Integer;
begin
  if MyQuestionMessage('Преобразовать Д/К (НЕ стд)?') <> mrYes Then Exit;
  ar2:=Q.QLoadToVarDynArray2('select id_std_item, max(itemname), null from v_order_items where nstd = 1 and resale = 1 group by id_std_item', []);
  Q.QBeginTrans;
  Res:=-1;
  repeat
  for i:=0 to High(ar2) do begin
    ar2[i][2]:=Q.QIUD('i','bcad_nomencl','','id$i;name$s', [-1, ar2[i][1] + '_']);
    Res:=ar2[i][2];
    if Res < 0 then Break;
  end;
  if Res < 0 then Break;
  if Q.QExecSql('update order_items set resale = 0 where nstd = 1 and resale = 1', []) < 0 then Break;
  for i:=0 to High(ar2) do begin
    Res:=Q.QExecSql('update estimate_items set id_group=109, id_name_resale = null, id_name = :id1$i where id_name_resale = :id0$i', [ar2[i][2], ar2[i][0]]);
    if Res < 0 then Break;
  end;
  Res := 0;
  until True;
  Q.QCommitOrRollback(res >= 0);
end;

procedure Test_SetMinPart;
//убрать нестандартные Д/К
//получис список нестандартных д.к изделий из ордер_итемс
//создаем для них в бкад_номенкл в группе На удаление записи, рапвные назв изделия + "_"
//в ордер_итемс снимеаем флаг д/к
//меняем в сметах сслылку на д/к на ссылку на бкад_ном и группу на_удаление
var
  i,j,k:Integer;
  v:Variant;
  ar2, ar22: TVarDynArray2;
  va, va2, va3: TVarDynArray;
  Res:Integer;
begin
  if MyQuestionMessage('Задать мин партии?') <> mrYes Then Exit;
  ar2:=Q.QLoadToVarDynArray2('select id_nomencl, max(minpart) minpart_max from dv.namenom_supplier ns group by id_nomencl', []);
  for i:=0 to High(ar2) do begin
    if ar2[i][0] = null then Continue;
    Q.QExecSql('insert into spl_itm_nom_props (id) select :id1$i from dual where not exists (select null from spl_itm_nom_props where id = :id2$i)', [ar2[i][0], ar2[i][0]]);
    Q.QExecSql('update spl_itm_nom_props set qnt_minpart=:qnt_minpart$f where id = :id$i', [ar2[i][1], ar2[i][0]]);
  end;
end;



procedure TestErr;
begin
  try
  Errors.Test;
//  except on E: Exception do begin Application.ShowException(E);
//  MyInfoMessage('TestErr'); end
  finally
    MyInfoMessage('TestErr');
  end;
  MyInfoMessage('TestErr end');
end;

var
  sa : TNamedArr;
begin
  Orders.CalcSplNeedPlanned(0);exit;

  va:=Q.DBLock(True,'ordercreate','-1','');
  va:=Q.DBLock(True,'ordercreate','-1','');
  va:=Q.DBLock(False,'ordercreate','-1','');
  Exit;

  MyQuestionMessage('Паспорта по следующим заказам не могут быть сформированы!'#13#10 +  ',123421342342134 ' + #13#10'Сформировать по остальным заказам?');
  MyQuestionMessage('Паспорта по следующим заказам не могут быть сформированы!'#13#10 +  ',123421342342134 ' + #13#10'Сформировать по остальным заказам?', 1); exit;
  for i := 0 to 100 do
    S.ConcatStP(v, inttostr(i), #13#10);
   myMessageDlg(
   'var'+#13#10+
  'Date1, Date2: TDateTime;'+#13#10+
  'DaysDiff: Integer;'+#13#10+
'begin'+
'  Date1 := EncodeDate(2023, 1, 1) + EncodeTime(15, 0, 0, 0); // 01.01.2023 15:00'+
'  Date2 := EncodeDate(2023, 1, 3) + EncodeTime(12, 0, 0, 0); // 03.01.2023 12:00'+
'  Date2 := EncodeDate(2023, 1, 3) + EncodeTime(12, 0, 0, 0); // 03.01.2023 12:00'+
'  Date2 := EncodeDate(2023, 1, 3) + EncodeTime(12, 0, 0, 0); // 03.01.2023 12:00'+
'  Date2 := EncodeDate(2023, 1, 3) + EncodeTime(12, 0, 0, 0); // 03.01.2023 12:00'+
'  Date2 := EncodeDate(2023, 1, 3) + EncodeTime(12, 0, 0, 0); // 03.01.2023 12:00'+
'  Date2 := EncodeDate(2023, 1, 3) + EncodeTime(12, 0, 0, 0); // 03.01.2023 12:00'+
''+
'  DaysDiff := Trunc(Date2) - Trunc(Date1); // = 2 дня'+#13#10+
'end;' + v
, mtInformation, [mbYes], '', 1);exit;


  //Orders.ExportPassportToXLSX(7963, '111.xlsx', True); exit;
  Orders.SetTaskForCreateOrder(7963);exit;


Cth.CreateButtons(pnl_Btns, [
['sdadsada'],
  [mbtGridSettings, True, -120, 'Tect', 'add'],
  [mbtRefresh, True], [mbtRefresh], [mbtDividorM], [mbtPrint], [mbtPrintPassport], [mbtPrintLabels], [mbtDividorM], [mbtCtlPanel],[mbtdividor],
  [mbtgo,'asdf'],
  [50.0],
  //[mbtSpace, True, 50],
  [1234, True, 120, 'Tect', 'add'],
  [mbtCopy, True, -200], [mbtDelete, True, -200], [mbtEdit, True, -200]
  ], nil, 1, '', 2, 0, False
);
//TSpeedButton(pnl_Btns.Controls[0]).GroupIndex:=1;
//TSpeedButton(pnl_Btns.Controls[0]).AllowAllup:=True;

//TSpeedButton(pnl_Btns.Controls[0]).Down:=True;
Exit;



Orders.SetOrderProperty_SyncWithITM;  Exit;




MyInfoMessage(Module.GetFileVersion(paramstr(0))); exit;

va[10]:=10; exit;
//Dlg_Test2.ShowModal;
Exit;


try
  TestErr;
finally
  MyInfoMessage('next proc');
end;
MyInfoMessage('next proc end');
Exit;


  MyInfoMessage(IntToStr(Q.QExecSql('update test1 set dt = :dt$d where id = :id', [null, '423', ''], True))); exit;


  try
  st:=va[123];   //IntToStr(myDBOra.QExecSql('update test145654 set dt = :dt$d where id = :id', [null, '423'], True));
  except on e: exception do
    begin
      Application.ShowException(e);
      MyInfoMessage('1');
    end;
  end;
  MyInfoMessage('end');
  exit;
  MyInfoMessage(IntToStr(Q.QExecSql('update test1 set dt = :dt$d where id = :id', [null, '**423'], False))); exit;
  MyInfoMessage(IntToStr(Q.QExecSql('update test1 set dt = :dt$d where id = :id', [null, 423]))); exit;
  MyInfoMessage(IntToStr(Q.QExecSql('select count(*) from adm_users where id = :id$i', [date]))); exit;

  //try
 // ar2[1000][100]:=0;
  //ar2:=QLoadToVarDynArray2('select id_group from dv.groups where groupname = ''Номенклатура из CAD''', null);
//  ar2:=QLoadToVarDynArray2('select id_group from dv.groups where groupname = :groupname$i', 'dddd');
  //ar2[1000][100]:=0;
  //finally
 //end;

  exit;


  Test_Set_Order_Payments;
  Exit;

  Wh.ExecReference(myfrm_J_Or_DelayedInProd);
  Exit;


//  ar2:=QLoadToVarDynArray2('select id_group from dv.groups where groupname = :groupname$i', 'dddd'); exit;


  ar2:=Turv.GetDaysFromCalendar(EncodeDate(2024,3,8), EncodeDate(2024,3,15));
  dt:=Turv.GetDaysFromCalendar_Next(EncodeDate(2024,3,8), 1);
  Exit;
  //Test_SetStages_SGP; Exit;

  //Test_RandomValuesIntoOrderStagesTable;
  //Exit;


//  Wh.ExecMDIForm(myfrm_J_Order_Stages1);
  exit;


  st1:='ф?ываasdf';
  ch:=st1[2];
  MyInfoMessage(st1[2]);;
  //Dlg_Memo.ShowDialog('','qqq','sss',st1);
//myxlsLoadSheetToArray('r:\smeta-max.xls', 'Смета печать', 0,0,0,0,10000, 30, ar2);
  Exit;

//  Orders.LoadEstimate(null,85,null);
//  Orders.LoadEstimate(0,0,1);
  exit;

  tasks.createtaskroot(mytskopmail, [['to', 'sprokopenko@fr-mix.ru'], ['subject', 'Тестовое письмо'], ['body', 'Тело письма'], ['user-name', 'Учёт']]);
  exit;

  exit;
{
declare
  IdZakaz number;
begin
  select dv.SyncOrder(1, 1, 'test1', '01.12.2023', '10.12.2023', 'Билайн', 'ООО "Омега"') into idzakaz from dual;
  dbms_output.put_line(idzakaz);
end;
}
//  myinfomessage(vartostr(
//  QSelectOneRow('select dv.SyncOrder(1, 1, ''test1'', ''01.12.2023'', ''10.12.2023'', ''Билайн'', ''ООО "Омега"'') from dual', null)
//  [0]
//  ))
//  ;

  exit;

  MyInfoMessage(S.ValidateInn(Edit1.Text));
  exit;



  //Wh.ExecMDIForm(myfrm_J_Orders);
  exit;

  Turv.LoadParsecData;
  exit;

  //Wh.ExecMDIForm(myfrm_J_Otk);
  exit;



  exit;

  Tasks.TestTurvComplete;
  exit;


  ar2:=Turv.GetWorkersNotInParsec(True);
  exit;

//  turv.Convert20230806;exit;


//  Thunderbird('sprokopenko@fr-mix.ru', '+test', 'учет'#13#10'assafsadfsd', ''); exit;
//  testsql1;  exit;

  Tasks.TestTurvDifferences;
//  Tasks.TestTurvComplete;
  exit;

  tasks.createtaskroot(mytskopmail, [['to', 'sprokopenko@fr-mix.ru'], ['subject', 'Тестовое письмо'], ['body', 'Тело письма'], ['user-name', 'Учёт']]);
  exit;

  Module.MailSendToUsers('mail test Учет', 'Test'#13#10'Учёт', '33,2');// VarArrayOf([33]));
  exit;

  //UpdateIcons('R:\Uchet\Сервер.exe', 'R:\Uchet\Uchet_Icon.ico');
  exit;

  Module.CloseAppTimer(1);
  MyInfoMessage('завершение через 10сек');
  Module.CloseAppTimer(0);
  exit;
//aFieldName: string; aFieldType:TFieldType; aFieldSize: Integer; aCaption: string; aWidth: Integer; aVisible: Boolean)
  //Dlg_Grid1.ShowDialog('Соискатели', 400, 200, [['job', ftString, 400, 'Должность', 150, True], ['job1', ftString, 400, 'Должность 222', 250, True]], [['aaaaaaaa','wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww213423345345345'], ['sdffsdfsdfsd', '3']]);
  exit;

//QIUD('u', 'payroll', 'sq_payroll', 'id;id_method$i', [1, null]);
//exit;

{  oSmtp := TMail.Create(Application);
  oSmtp.LicenseCode := 'TryIt';

  // Set your sender email address
  oSmtp.FromAddr := 'test@emailarchitect.net';
  // Add recipient email address
  oSmtp.AddRecipientEx('support@emailarchitect.net', 0);

  // Set email subject
  oSmtp.Subject := 'simple email from Delphi project';
  // Set email body
  oSmtp.BodyText := 'this is a test email sent from Delphi project, do not reply';

  // Your SMTP server address
  oSmtp.ServerAddr := 'smtp.emailarchitect.net';

  // Set 25 port, if your server uses 587 port, please change 25 to 587
  oSmtp.ServerPort := 25;

  // Set TLS connection
  oSmtp.ConnectType := ConnectSSLAuto;

  // User and password for ESMTP authentication, if your server doesn't require
  // user authentication, please remove the following codes
  oSmtp.UserName := 'test@emailarchitect.net';
  oSmtp.Password := 'testpassword';

  ShowMessage('start to send email ...');
  if oSmtp.SendMail() = 0 then
    ShowMessage('email was sent successfully!')
  else
    ShowMessage('failed to send email with the following error: '
    + oSmtp.GetLastErrDescription());

}
try
  IdSMTP1.Host:='mail.fr-mix.ru';
//  IdSMTP1.Host:='10.1.1.8';
  IdSMTP1.Port:=587;
  IdSMTP1.Username:='itm@fr-mix.ru';
  IdSMTP1.Password:='itm2password';
  IdSMTP1.Connect;
  msg:=TIdMessage.Create(nil);
  msg.Body.Add('test mail');
  msg.Subject:='test mail';
  msg.From.Address:='itm@fr-mix.ru';
  msg.From.Name:='itm';
  msg.Recipients.EMailAddresses:='sprokopenko@fr-mix.ru';
  msg.IsEncoded:=True;
  IdSMTP1.Send(msg);
  msg.Free; IdSMTP1.Disconnect;
except
  on e:Exception do
    begin
      msg.Free;
      IdSMTP1.Disconnect;
    end;
end;



exit;


//qselectonerow('select nameru from adm_modules where id =:id', 14.00);
exit;

//MyData.SetStyleDialog1;
st:='';
//MyInfoMessage(inttostr(Integer(ttt(3)))); //3
//MyInfoMessage(inttostr(Integer(v2)));  //190000
//MyInfoMessage(inttostr(Integer(vttr(3)))); ---


//    v:=QSelectOneRow('select IsModuleAvailableToUser(:id_u, :id_m) from dual', VarArrayOf([33, 0]));

//  for i:=1 to 1000 do st:=st + '1234567890';
//  st:=st+'A';

//form_testgrid.show;

//ExecMDIForm(myfrm_J_Accounts);
//  F.MeFormShow(Application); Exit;
//  F:= TForm_BasicInput.Create(Self);
//  F.InitForm_();
 // F.ShowModal;
//  F:=nil;

//  QExecSql('insert into pas5 (c1) values (:c1)', st);
//  v:=QSelectOneRow('select c1 from pas5', null);
//  myinfomessage(inttostr(length(vartostr(v[0]))));

end;

procedure Xls_Open(XLSFile:string; Grid:TStringGrid);
 const
  xlCellTypeLastCell = $0000000B;
var
  ExlApp, Sheet: OLEVariant;
  i, j, r, c:Integer;

begin
  //создаем объект Excel
  ExlApp := CreateOleObject('Excel.Application');

  //делаем окно Excel невидимым
  ExlApp.Visible := False;

  //открываем файл XLSFile
  ExlApp.Workbooks.Open(XLSFile);

  //создаем объект Sheet(страница) и указываем номер листа (1)
  //в книге, с которого будем осуществлять чтение
  Sheet := ExlApp.Workbooks[ExtractFileName(XLSFile)].WorkSheets['Отчет панели'];

  //активируем последнюю ячейку на листе
//  Sheet.Cells.SpecialCells(xlCellTypeLastCell, EmptyParam).Activate;

    // Возвращает номер последней строки
    r := 26;//ExlApp.ActiveCell.Row;

    // Возвращает номер последнего столбца
    c := 5;//ExlApp.ActiveCell.Column;

    //устанавливаем кол-во столбцов и строк в StringGrid
    Grid.RowCount:=r;
    Grid.ColCount:=c;

    //считываем значение из каждой ячейки и копируем в нашу таблицу
     for j:= 1 to r do
       for i:= 1 to c do
         Grid.Cells[i-1,j-1]:= sheet.cells[j,i];
        //если необходимо прочитать формулы то
       //Grid.Cells[i-1,j-1]:= sheet.cells[j,i].formula;

 //закрываем приложение Excel
 ExlApp.Quit;

 //очищаем выделенную память
 ExlApp := Unassigned;
 Sheet := Unassigned;

end;

procedure TFrmTest.DBNumberEditEh1Change(Sender: TObject);
begin
  tdbediteh(sender).highlightrequired:=True;
end;

procedure TFrmTest.BitBtn2Click(Sender: TObject);
var f: tform;
va: tvardynarray;
ff: Variant;
begin
  ff:=va[10];
  //TDlg_TURV.Create(Self, 'turv', 0,0,0, [], null);
end;

    function ppp:Boolean;
      begin
        Result:=True;
        //Dlg_BasicInput.Bt_Ok.Caption:=Dlg_BasicInput.ExtData[0];
        MyInfoMessage('!!!!');
      end;

procedure TFrmTest.BitBtn3Click(Sender: TObject);
var
  st, st1, st2: string;
  v, v1: tvardynarray2;
begin
//  Dlg_SelectUsers.ShowDialog;
//Dlg_SelectUsers.ShowDialog('test_sel', '33,12,987', False, st1, st2);
//  BasicInputDialog(VarArrayOf(['qqqq']), ppp
//  );
//  v:=Turv.GetTurvArray(1, date );
//  v1:=Turv.GetTurvArray(2, date );

  try
    st:=v[10][0];
  except
  end;
end;


procedure TFrmTest.BitBtn4Click(Sender: TObject);
begin
//  Q.QLoad
end;

procedure TFrmTest.bt_fromxlsClick(Sender: TObject);
begin
 If OpenDialog1.Execute then Xls_Open (OpenDialog1.FileName, StringGrid1);
end;


procedure TFrmTest.Button1Click(Sender: TObject);
var
UnPro : HWND;
PassText: HWND;
OKbutton: HWND;
// CallBack-функция,используемая функцией EnumChildWindows
function ChildWndProc(h : HWND) : BOOL; stdcall;
begin
 //SendMessage(h, WM_SETTEXT, 0, lParam(LPCTSTR('Текст,который надо поместить')));
 Result := True;
end;

var
 SearchedWnd : HWND;

begin
UnPro:= FindWindow(nil, 'Добавление'); //Где меню с вводом пароля
if UnPro<> 0 then begin
  PassText := FindWindowEx(UnPro, 0, 'Edit', nil); // Где само поле на этом меню
end;

 SearchedWnd := FindWindow(nil, 'Добавление');
 EnumChildWindows(SearchedWnd, @ChildWndProc, 0);

 PassText := FindWindowEx(UnPro, 0, 'Edit', nil);

end;




procedure TFrmTest.Change(Sender: TObject);
begin
  Cth.VerifyControl(TControl(Sender));
end;


procedure TFrmTest.FormActivate(Sender: TObject);
var
c: tcontrol;
s: tstrings;
begin


//s:=tstrings.Create;
//s.add;

{
  Cth.CreateControls(Self, cntComboL, 'edit', 'edit1');
  Cth.CreateControls(Self, cntNEditC, 'edit2', 'edit2','-3:3000:2:N::::::');
  c:=Cth.CreateControls(Self, cntComboE, 'combo3', 'combo3','3:10::N::::::');
  tdbediteh(c).OnChange:=change;
  tcontrol(FindComponent('combo3')).left:=200;
}
end;


procedure TFrmTest.lbl1Click(Sender: TObject);
begin
  inherited;
    with lbl1  do begin
    SetCaption('Каждый'+'$0000FFохотник'+'$FF0000желает'+'знать');
{    ColorsPos('Каждый', 255000000);
    ColorsPos('охотник', 42495);
    ColorsPos('желает', 65535);
    ColorsPos('знать', 32768);
    ColorsPos('где', 16760576);
    ColorsPos('сидит', 16711680);
    ColorsPos('фазан', 13828244);}
  end;
end;

procedure TFrmTest.LabeledEdit1Change(Sender: TObject);
begin
  inherited;
//
end;

procedure TFrmTest.SpeedButton1Click(Sender: TObject);
var
  button: TControl;
  lowerLeft: TPoint;
begin
btn1.Width:=80;
btn1.Height:=32;
  Cth.SetSpeedButton(btn1, mybtPrint, False, ''+#$25BC);
  if Sender is TControl then
  begin
    button := TControl(Sender);
    lowerLeft := Point(0, button.Height);
    lowerLeft := button.ClientToScreen(lowerLeft);
    PopupMenu1.Popup(lowerLeft.X, lowerLeft.Y);
  end;
end;


function ttt(var xlsFile: TXlsMemFileEh):Boolean;
begin
  xlsFile:= TXlsMemFileEh.Create;
  XlsFile.LoadFromFile('r:\temp.xlsx');
//  XlsFile.LoadFromFile('r:\temp1.xls');
end;



procedure TFrmTest.Bt_LoadXLSMClick(Sender: TObject);
//тест загрузки данных из хлсх-файла без его открытия в экселе
var
  xlsFile: TXlsMemFileEh;
  st, st1, st2, st3, st4: string;
  cr: IXlsFileCellsRangeEh;
  sh: TXlsWorksheetEh;
  v: Variant;
  i,j,k:Integer;
  dt, dtr, dtobr, dt1, dt2: tdatetime;
  ast: TStringDynArray;
  uv:Boolean;
  sl:tstrings;
  stid:Variant;
  comm, phone:string;
  LInput, LOutput: TFileStream;
  LUnZip: TZDecompressionStream;
  FileStream: TFileStream;
  DecompressionStream: TDecompressionStream;
  Strings: TStringList;
  MS:TMemoryStream;
begin
exit;
//GetProductionCalendar('2023'); exit;

//LoadFileFromWWW('http://xmlcalendar.ru/data/ru/2023/calendar.xml.gz',WinTemp+'\calendar.xml.gz');

  FileStream := TFileStream.Create(Sys.GetWinTemp+'\calendar.xml.gz', fmOpenRead);
{
     windowBits can also be greater than 15 for optional gzip decoding.  Add
   32 to windowBits to enable zlib and gzip decoding with automatic header
   detection, or add 16 to S.Decode only the gzip format (the zlib format will
   return a Z_DATA_ERROR).
}
  DecompressionStream := TDecompressionStream.Create(FileStream, 15 + 16);  // 31 bit wide window = gzip only mode

  Strings := TStringList.Create;
  Strings.LoadFromStream(DecompressionStream);
  Strings.Text:=UTF8Decode(Strings.Text);
//  for i:=0 to Strings.Count-1 do
  ShowMessage(Strings.Text);
  DecompressionStream.Free;
  FileStream.Free;
  Strings.Free;
exit;

  inherited;
  { Create the Input, Output, and Decompressed streams. }
  LInput := TFileStream.Create('r:\calendar.xml.gz', fmOpenRead);
  LOutput := TFileStream.Create('r:\calendar.xml', fmCreate);
  LUnZip := TZDecompressionStream.Create(LInput);

  { Decompress data. }
  LOutput.CopyFrom(LUnZip, 0);

  { Free the streams. }
  LUnZip.Free;
  LInput.Free;
  LOutput.Free;
  exit;



//Dlg_CandidatesFromWorkerStatus.ShowDialog(1, 1, date);
(*
//  xlsFile := TXlsMemFileEh.Create;
//  xlsFile := ttt;
  ttt(xlsFile);
  //файл не откроется, если он открыт в экселе
//  XlsFile.LoadFromFile('r:\TestLoad.xlsm');
  //можно выкрутьться так (копируем во временный, с флагом перезаписи)
 // CopyFile('r:\TestLoad.xlsm', 'r:\temp.xlsx', False);
 // XlsFile.LoadFromFile('r:\temp.xlsx');

  //CreateTXlsMemFileEhFromExists

  sh:=xlsFile.Workbook.Worksheets['Лист2']; //регистр имеет значение!
  st1:=sh.name;
  //читает значение, втч результат формулы
  //col, row с нуля
  v:=sh.cells[2, 0].Value;
  MyInfoMessage(vartostr(v));
  xlsfile.free;
  *)
  {
 id number(11),
  id_vacancy number(11),       --айди вакансии, на которую оформлен соискатель
  id_job number(11),           --айди вакантной должности, если нет вакансии
  id_division number(11),      --айди подразделения, если нет вакансии
  id_head number(11),          --айди руководителя (в таблице работников), если нет вакансии
  f varchar2(25),              --фамилия
  i varchar2(25),              --имя
  o varchar2(25),              --отчество
  dt_birth date,               --дата рождения
  dt date,                     --дата собеседования
  dt1 date,                    --дата приема
  dt2 date,                    --дата увольнения
  id_status number(1),         --статус (резерв, откал ОК...)
  ad varchar(200),             --как нашел данную вакансию, строка
  comm varchar(4000),          --комментарий
  }

(*
  //загрузка соискателей
  EXIT;
  if myquestionmessage('Загрузить соискателей?') <> mrYes then Exit;

  sl:=tstringlist.Create;

  xlsFile := TXlsMemFileEh.Create;
  CopyFile('r:\соискатели.xlsm', 'r:\соискатели1.xlsm', False);
  XlsFile.LoadFromFile('r:\соискатели1.xlsm');
  sh:=xlsFile.Workbook.Worksheets['Соискатели']; //регистр имеет значение!
  //читает значение, втч результат формулы
  //col, row с нуля
  for i:=2 to 5310 do begin
    v:=sh.cells[0, i].Value;
    A.ExplodeP(trim(vartostr(sh.cells[0, i].Value)), ' ', ast);
    st1:=''; st2:=''; st3:='';
    for j:=0 to high(ast) do begin
      if ast[j]<>'' then
        if st1=''
          then st1:=ast[j]
          else if st2 = ''
            then st2:=ast[j]
            else if st3 = ''
              then st3:=ast[j]
              else st3:=st3+' '+ast[j];
    end;
    dt:=S.BadDate;
    try
    v:=sh.cells[1, i].Value;
    if S.IsNumber(v,0,999999999999,0) then dt:=tdatetime(v);
//    v:=tdatetime(sh.cells[1, i].Value);
//    dt:=StrToDateDef(v, S.BadDate);
    except
    dt:=S.BadDate;
    end;
    if dt <> S.BadDate then begin
      dtr:=dt;
    end;
    v:=sh.cells[5, i].Value;
    if S.IsNumber(v,0,999999999999,0) then dtobr:=tdatetime(v) else dtobr:=S.BadDate;
    v:=sh.cells[8, i].Value;
    if S.IsNumber(v,0,999999999999,0) then dt1:=tdatetime(v) else dt1:=S.BadDate;
    v:=sh.cells[9, i].Value;
    uv:=False;
    if S.IsNumber(v,0,999999999999,0)
      then begin uv:=True; dt2:=tdatetime(v) end
      else if vartostr(v)<>''
        then uv:=True
        else dt2:=S.BadDate;
    st:=vartostr(sh.cells[7, i].Value);
    stid:=null;
    if (uv = False) and (dt1 = S.BadDate) then begin
      if st = 'резерв' then stid:=10;
      if st = 'отказ рук-ля' then stid:=11;
      if st = 'отказ мед.' then stid:=12;
      if st = 'отказ СБ' then stid:=13;
      if st = 'отказ ОК' then stid:=13;
//      if st = '' then stid:=;
    end;
    phone:=trim(vartostr(sh.cells[2, i].Value));
    comm:='['+vartostr(sh.cells[3, i].Value)+ ']  '+ vartostr(sh.cells[10, i].Value);

    sl.add(
    inttostr(i) + '|'+
    st1 +'|'+
    st2 +'|'+
    st3 +'|'+
    datetostr(dtr) + '|' +
    datetostr(dtobr) + '|' +
    datetostr(dt1) + '|' +
    datetostr(dt2) + '|' +
    booltostr(uv) + '|' +
    vartostr(stid) + '|' +
    comm
    );

if i < 30000 then begin
      QIUD('i', 'j_candidates', 'sq_j_candidates', 'id;f$s;i$s;o$s;dt_birth$d;dt$d;dt1$d;dt2$d;id_status$i;phone;comm$s',
        [
        -1,
        st1, st2, st3, dtr, dtobr,
        S.IIf(dt1 = S.BadDate, null, dt1),
        S.IIf(uv, dt2, null),
        stid,
        phone,
        comm
        ],
        True
      );
end;

  end;

  myinfomessage(inttostr(i));
//  MyInfoMessage(vartostr(v));
  xlsfile.free;

  sl.SaveToFile('r:\соискатели.txt');

exit;

      QIUD('i', 'j_candidates', 'sq_j_candidates', 'id;f$s;i$s;o$s;dt_birth$d;dt$d;dt1$d;dt2$d;;id_status$i;comm$s',
        [
        -1
        ],
        False
      );
*)
end;


procedure TFrmTest.Bt_LoadXLSClick(Sender: TObject);
var
  i,j,rn,x,y,y1,y2 : Integer;
  Rep: TA7Rep;
  FileName:string;
begin
//  FileName:='Зарплатная ведомость';
//  FileName:=Module.GetReportFileXlsx(FileName);
  FileName:='r:\temp1.xls';
  if FileName = '' then Exit;
  Rep:= TA7Rep.Create;
  try
    Rep.OpenTemplate(FileName,False);
  except
    Rep.Free;
    Exit;
  end;
//  Rep.PasteBand('HEADER');
//  Rep.SetValue('#TITLE#',lbl_Caption1.Caption);
  Rep.TemplateSheet := Rep.Excel.Workbooks[1].Sheets[1];
  MyInfoMessage(Rep.TemplateSheet.Cells[6,2].Value);


//  Rep.DeleteCol1;
//  Rep.Show;
  Rep.CloseExcel;
  Rep.Free;
end;


procedure TFrmTest.Bt_AlignClick(Sender: TObject);


begin
  inherited;
  cth.SetBtn(bt_44,mybtrefresh, True);
  Cth.AlignControls(pnl1, [], True);
exit;
  myinfomessage(inttostr(Self.componentcount) + ' ' + inttostr(pnl1.componentcount) + ' ' + inttostr(Self.controlcount) + ' ' + inttostr(pnl1.controlcount));
  myinfomessage(A.Implode(Cth.GetChildControlNames(pnl1),'; '));
  myinfomessage(A.Implode(Cth.GetChildControlNames(Self),'; '));
  myinfomessage(A.Implode(Cth.GetChildControlNames(Self, False),'; '));
  myinfomessage(booltostr(Cth.IsChildControl(Self, 'DBEditEh2')));
  myinfomessage(booltostr(Cth.IsChildControl(Self, 'dbEditEh2'{, False})));
  myinfomessage(booltostr(Cth.IsChildControl(self, 'Edit1')));
  myinfomessage(booltostr(Cth.IsChildControl(pnl1, 'Edit1')));
end;

procedure TFrmTest.Bt_Dlg_BasicInputClick(Sender: TObject);
var
  dt: extended; //tdatetime;
begin
end;




procedure TFrmTest.Bt_SaveXLSXClick(Sender: TObject);
var
  xlsFile: TXlsMemFileEh;
  cr: IXlsFileCellsRangeEh;
  st, st1, st2, st3, st4: string;
  //cr: IXlsFileCellsRangeEh;
  sh: TXlsWorksheetEh;
  v: Variant;
  i,j,k:Integer;
  va: tvardynarray2;
begin
  xlsFile:= TXlsMemFileEh.Create;
  XlsFile.LoadFromFile('r:\test1.xlsx');
  xlsFile.Workbook.Worksheets[0].Cells[1,1].Value:='Заголовок паспорта';
  for i:=0 to 20 do begin
    if xlsFile.Workbook.Worksheets[0].Cells[0,i].Value='TABLE' then begin
      if i<10
        then xlsFile.Workbook.Worksheets[0].Cells[1,i].Value:='TABLE Заголовок паспорта Наименование изделия ' + IntToStr(i)
        else xlsFile.Workbook.Worksheets[0].Rows[i].Visible:=False;
//xlsFile.Workbook.Worksheets[0].Rows[i].
    end;

  end;
  //cr.
  XlsFile.SaveToFile('r:\test2.xlsx');
  XlsFile.Free;
end;

procedure TFrmTest.Bt_TreeClick(Sender: TObject);
begin
  inherited;
  Form_TestTree.Showmodal;
end;

procedure TFrmTest.Bt_FastReportClick(Sender: TObject);
begin
  inherited;
//  frxReport1.LoadFromFile(PrintReport.GetReportFileFr3('test'), True);
//  frxReport1.DesignReport;
end;


procedure LoadPersonnelNumber;
//загрузка из файла табельных номеров работника
var
  i, j, k, emp: Integer;
  st, st1, st2, w, FileName, err, err2, fio: string;
  v, v1, v2: Variant;
  e, e1, e2, e3: extended;
  rn: Integer;
  b, b2, res: Boolean;
  XlsFile: TXlsMemFileEh;
  cr: IXlsFileCellsRangeEh;
  sh, sh1: TXlsWorksheetEh;
  Files: TStringDynArray;
  ar, ar2: TVarDynArray2;
  orgn, orgid: TVarDynArray;
begin
  MyData.FileOpenDialog1.Options := MyData.FileOpenDialog1.Options + [fdoPickFolders];
  if not MyData.FileOpenDialog1.Execute then
    Exit;
  Files := TDirectory.GetFiles(MyData.FileOpenDialog1.FileName, '*.xlsx');
  err := '';
  for k := 0 to High(Files) do begin
    if not CreateTXlsMemFileEhFromExists(Files[k], True, '$2', XlsFile, st) then
      Continue;
    sh := XlsFile.Workbook.Worksheets[0];
    for i := 1 to 2000 do begin
      if sh.Cells[1 - 1, i].Value = '' then
        Break;
      ar := ar + [[sh.Cells[1 - 1, i].Value, sh.Cells[2 - 1, i].Value, sh.Cells[3 - 1, i].Value]];
    end;
    sh.Free;
    XlsFile.Free;
  end;
  orgn := ['ООО "МЕРКУРИЙ"','ООО "ОМЕГА"','ООО "Промсервис"'];
  orgid := [1,3,6];
  ar2 := Q.QLoadToVarDynArray2('select id, workername from v_ref_workers', []);
  for i := 0 to High(ar) do begin
    for j := 0 to High(ar2) do begin
      if ar[i][0] = ar2[j][1] then begin
        k := A.PosInArray(ar[i][2], orgn);
        if Q.QExecSql('update ref_workers set personnel_number = :n$s, id_organization = :o$i where id = :id$i', [ar[i][1], orgid[k], ar2[j][0]], false) = -1 then
          S.ConcatStP(err2, ar[i][0], #13#10);
        Break;
      end;
    end;
    if j > High(ar2) then
      S.ConcatStP(err, ar[i][0], #13#10);
  end;
  MyInfoMessage('Не удалось загрузить:'#13#10#13#10 + err + #13#10'----------'#13#10 + err2, 1);
end;


procedure ConvertNewOrStdItemRoutes;
//маршруты для стандартных изделий в новом формате (в таблицу)
var
  i, j, k: integer;
  va, RouteFields: TVarDynArray;
  va1, va2: TVarDynArray2;
  st: string;
begin
  RouteFields := ['КС','МТ','СТ','РК','ПГ','ЛК','КМ'];

  va1 := Q.QLoadToVarDynArray2('select id, code from work_cell_types', []);
  for i := 0 to High(RouteFields) do
    if A.PosInArray(RouteFields[i], va1, 1) < 0 then begin
      MyWarningMessage(RouteFields[i]);
      Exit;
    end;
  va2 := Q.QLoadToVarDynArray2('select id, r1,r2,r3,r4,r5,r6,r7 from or_std_items', []);
  Q.QExecSql('delete from or_std_item_route', []);
  for i := 0 to High(va2) do begin
    st := '';
    for j := 1 to High(va2[i]) do begin
      if S.NNum(va2[i][j]) = 0 then
        Continue;
      k := A.PosInArray(RouteFields[j-1], va1, 1);
      S.ConcatStP(st, va1[k][1], ',');
      Q.QExecSql('insert into or_std_item_route (id_or_std_item, id_work_cell_type) values (:v1$i, :v2$i)', [va2[i][0], va1[k][0]]);
    end;
    //Q.QExecSql('update or_std_items set route = :v$s where id = :id$i', [st, va2[i][0]]);
  end;
end;


procedure TestProcedure1;
begin

end;

procedure TestProcedure2;
var
  res: TFrmXWAbout;
  va: TVarDynArray;
//  Form: TFrmMDI;
  i: Integer;
  st: string;
begin
Exit;
//  q.QExecSql('select 1 from www', [1]); exit;

  TFrmOWOrder.Show(Application, myfrm_Dlg_UsersAndRoles, [myfoSizeable, myfoDialog, myfoEnableMaximize], fNone, null, null); exit;

  Exit;
  //Wh.ExecReference(myfrm_Rep_PlannedMaterials); Exit;
//  TFrmGridRef.Show(Self, 'myfrm_R_StdProjects_1', [myfoSizeable], fNone, 10, null); exit;
  TFrmTestMdi1.Show(Application, '123456789', [], fNone, 0, null); exit;
//TfrmDlgRItmSupplier.Create(Self, 'dddddddd', [myfoMultiCopy, myfoDialog, myfoSizeable, myfoModal], fView, 5753, null);   //id 5753
//i:=TFrmDlgRItmSupplier.ShowModal(Self, 'dddddddd', [myfoMultiCopy, myfoDialog{, myfoSizeable}, myfoModal], fView, 5753, '444444444');   //id 5753
//i:=TFrmDlgRItmSupplier.Show(Self, 'dddddddd', [myfoMultiCopy, myfoDialog, myfoSizeable], fView, 5753, null);   //id 5753
//i:=FrmMDI.width;
//st:=TFrmDlgRItmSupplier(FrmMdi).BitBtn1.Caption;
//TFrmDlgRItmSupplier(FrmMdi).btnOk.free;
//st:=TFrmDlgRItmSupplier(FrmMdi).btnOk.Caption;
//st:=TFrmDlgRItmSupplier(FrmMdi).BitBtn1.Caption;
//TFrmDlgRItmSupplier(FrmMdi).btnOk.OnClick(nil);
//st:=TFrmDlgRItmSupplier(FrmMdi).dbediteh1.Text;
//st:=TFrmDlgRItmSupplier(FrmMdi).edt_name_org.text;
exit;

//  TFrmDlgFindNameInEstimates.Show(Self, 'ddd', [myfoSizeable], fNone, null, null);  exit;

//  TFrmAWUsersAndRoles.Show(Self, 'dddddddd', [myfoSizeable], fNone, null, null);
//  Form:= TFrmMDI.Create(Application, 'sdfsdfgdsfgd', [], fNone, 0, null);
exit;

  Wh.ExecReference(myfrm_R_MinRemainsI);
  Exit;
  Wh.ExecDialog(myfrm_Dlg_NewEstimateInput, FrmMain, [myfoModal, myfoSizeable], fAdd, null, null); //myfoModal, myfoSizeable






//TForm_References.Create(Self, myfrm_R_DelayedInprodReasons, [myfoEnableMaximize, myfoMultiCopy, myfoSizeable], fNone, 0, null);
//  res := TFrmXWAbout.Create(Self, False);
//  res.ShowModal;
end;

procedure TestProcedure3;
var
//  res: TFrmXWAbout;
  res: TForm;
  i: Integer;
  st: string;
  va2: tvardynarray2;
  v: TVarDynArray;
begin
  Turv.LoadParsecDataNew; exit;

  ///Tasks.SplMonitorPrices; Exit;
  //q.QExecSql('select 2 / 0 from dual', []); Exit;
  TFrmWWedtWorkSchedule.Show(Application, myfrm_Dlg_Work_Schedule, [myfoDialog], fAdd, 32098, null); exit;

  TFrmCDEdtAccount.Show(Application, '2222212', [myfoDialog, myfoSizeable], fEdit, 32098, null); exit;


  v:=Q.QSelectOneRow('select count(*) from adm_user_cfg', []);
  exit;


  //LoadPersonnelNumber; Exit;

    Orders.LoadEstimate(null, null, 1129); exit;

   TFrmOGedtEstimate.Show(Application, '222221', [myfoDialog, myfoSizeable], fEdit, 32098, null); exit;


  TFrmWGEdtTurv.Show(Application, '22222', [myfoDialog, myfoSizeable], fEdit, 2234, null); exit;

  TFrmBasicEditabelGrid.Show(Application, '2222', [myfoSizeable], fNone, 0, null); exit;

  FrmXDedtMemo.ShowDialog(nil, 'AttachAggregateEstimate', 'Комментарий к общей смете', 'wqewqe', st);exit;


  Wh.ExecReference(myfrm_Rep_Salary);exit; //myfrm_J_Parsec
  TFrmOGedtSnMain.Show(FrmMain, 'dddddddd', [myfoSizeable], fNone, 1, null); exit;



  FrmCWAcoountBasis.ShowDialog(nil, 0, fAdd, 0); exit;
  TFrmCDedtCashRevision.Show(FrmMain, 'dddddddd', [], fNone, 1, null); exit;

  Wh.ExecReference(myfrm_Rep_SnCalendar_AccMontage);exit;

  q.qloadtovardynarray2('select id_act,id_docstate,actnum,actdate,numzakaz,zakazname,itogo,comments,zakazcostend,firm,doc_owner,doc_date from dv.v_acts', []);
  myinfomessage('!!!');exit;


  i:=i div i; Exit;
//  TFrmGMtPspCreate.Show(Self, '1234567890-3', [myfoSizeable], fNone, 10, null); exit;
TFrmBasicInput._TestFunctionDB;
//i:=FrmMDI.width;
//st:=TFrmDlgRItmSupplier(FrmMdi).Edit1.Text;
//st:=TFrmDlgRItmSupplier(FrmMdi).edt_name_org.text;
exit;

//  TFrmDlgRItmSupplier.Create(Self, 'dddddddd', [myfoMultiCopy, myfoSizeable], fAdd, null, null); exit;
//myfoMultiCopyWoID - не реализовано нигде
//myfoMultiCopy - запускает несколько копий всегда в режимах fNone, fAdd, fCopy, иначе только если нет формы с таким ID
  TFrmTestMdi1.Show(FrmMain, 'dddddddd', [myfoMultiCopy, myfoSizeable], fAdd, 1, null);
//  TFrmTestMdi1.Create(Self, 'dddddddd', [myfoMultiCopy, myfoSizeable], fNone, 2, null);
//  TFrmTestMdi1.Create(Self, 'dddddddd', [myfoMultiCopy, myfoSizeable], fEdit, 1, null);
  Exit;


//  TForm_Grid.Show(Self, 'dddddddd', [myfoSizeable], fNone, null, null);
  Exit;


Q.QBeginTrans;
q.qselectonerow('select 1, 45, sysdate from dual where id = :id$s and sysdate = :sysdate$d', [1,date]);
Q.QRollbackTrans;
exit;

  TForm_Adm_Installer.Create(FrmMain, myfrm_Adm_Installer, [myfoOneCopy], fAdd, 0, null);
exit;
MyInfoMessage(Module.GetFileVersion('')); exit;

//Wh.ExecReference(myfrm_R_ComplaintReasons, Self, [myfoOneCopy, myfoEnableMaximize, myfoMultiCopy, myfoModal, myfoAutoShowModal], null);
//TForm_References.Create(FrmMain, myfrm_R_ComplaintReasons, [myfoOneCopy, myfoEnableMaximize, myfoSizeable, myfoMultiCopy, myfoModal], fNone, 0, null);
res:=nil;
//TForm_References.ShowDialogClass(Self, myfrm_R_ComplaintReasons, [myfoOneCopy, myfoEnableMaximize, myfoMultiCopy, myfoModal], null);

//MyQuestionMessage('???');Exit;
//res:=TForm_MDI.ShowDialog(Self, myfrm_R_Bcad_Units, [myfoModal], null);
//res:=TForm_MDI.ShowDialog(Self, myfrm_j_orders, [myfoModal], null);
 // Wh.ExecReference(myfrm_J_Orders);
//res.showmodal;
//TForm_MDI.ShowDialog(Self, myfrm_R_Bcad_Units, [], null);
//   res:=TFrmXWAbout.Create(Self, True);
//   res.Show;
//



end;



end.
