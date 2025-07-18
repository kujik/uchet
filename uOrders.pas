{
������ � ������ ���������� � ��������
(�������� ���� �� ������� � �� ������ ���� ������������ ����������� ����������)
}
unit uOrders;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Jpeg, MemTableDataEh, Db, ADODB,
  DataDriverEh, ADODataDriverEh, MemTableEh, GridsEh, DBGridEh, PropStorageEh,
  DBAxisGridsEh, ImgList, PngImage, uString, IniFiles, DBCtrlsEh, ShellApi,
  IOUtils, Types, System.ImageList, frxClass, frxDesgn, Vcl.Themes, Vcl.Styles,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, Xml.xmldom,
  Xml.XMLIntf, Xml.XMLDoc, IdExplicitTLSClientServerBase, IdMessageClient,
  IdSMTPBase, IdSMTP, iDMessage, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL, Data.DBXOracle, Data.SqlExpr, ComObj,
  Math, DateUtils, ShlObj, FileCtrl, StrUtils;

const
  cOrItmStatus_Completed = 30;
  cOrItmStatus_OnExecution = 28;
  cOrUchetStatus_Completed = 99;


type
  TOrders = class
  private
    FBcadGroups: TVarDynArray2;
    FBcadUnits: TVarDynArray2;
    LastThnDocsDirectory: string;
  public
    //����, � ������� ������� ���� ������ �� ���� ����������
    //������������ ��� �������� ������� ���������� ������
    //�������� � ������������
    fDtToSgpMin, fDtFromSgpMin, fDtMontageMin, fDtUpdMin, ftDtManagerMin: TDateTime;
    //������������ ������ � ������� ����, � ������� ������ ����� �������/������������� ������ ������ ������.
    //���������� ������� ����, �� ������ �������, ������� ���� ���������/������ � ������� ����
    fDaysToSgp, fDaysFromSgp, fDaysMontage, fDaysOtk: Integer;
    property BcadGroups: TVarDynArray2 read FBcadGroups;
    property BcadUnits: TVarDynArray2 read FBcadUnits;
    constructor Create;
    procedure LoadBcadGroups(Force: Boolean = False);
    procedure Test;
    //��������� ������ ������ � ����� � ���.
    //���������� ������ ���, 99 ���� �������� � �����, 100 ���� ����� �� ������
    //�����������, ������� ��������
    function IsOrderFinalized(IdOrder: Variant; ShowMsg: Boolean = True; MinState: Integer = cOrItmStatus_Completed): Integer;
    function LoadSmetaOld(IdOrder: Integer): Integer;
    function EstimateFromFile(var FileName: string; var Est: TVarDynArray2): Boolean;
    function SetEstimateQnt(IdEstimate: Integer; Qnt: extended): Boolean;
    function LoadEstimate(IdOrder, IdOrderItem, IdStdItem: Variant; OneItem: Boolean = True; QntChanged: Boolean = False; Silent: Boolean = False): Integer;
    //������� ����� ��� ����������� ������������ �������. ���� �� Silent, �� ����� ���� �������.
    //������ True, ����� ������ ������ ��� ����������� ������� ��������
    function RemoveEstimateForStdItem(IdStdItem: Variant; Silent: Boolean = False): Boolean;
    //������������� ������ � ��� � ������� � �����, � ���������� � ���� ����
    //�� �� ��� � SyncOrderWithITM, �� � ���������� � � ������� ���������
    function RefreshEstimatesAndSyncWithITM(IdOrder: Integer; OrderItems: TVarDynArray; LoadOrderAllItems: Boolean = True): Boolean;
    //������������� ������ � ��� � ������� � �����
    //� ��� ����������� ����� � ��������� ����������� � ��� �������� ��� �����, � ����� �� ����������� ��, � ������� � ���������� ���������� ��� ������� ���
    //������ ������ ������ ����������� ��� ��� �������� � ������ �������, ��������� �� LoadOrderAllItems, �������� ������ ������ ����������
    //�� ��������� ���� � ���, ������������ ��� ���, ��� ���������� � OrderItems ������
    function SyncOrderWithITM(IdOrder: Integer; OrderItems: TVarDynArray; LoadOrderAllItems: Boolean = True): Boolean;
    function RefreshEstimatesToOrder(IdOrder: Integer; OrderItems: TVarDynArray; LoadOrderAllItems: Boolean = True): Boolean;
    function CreateAggregateEstimate(IdOrder: Integer; Mode: Integer): Boolean;
    procedure TaskForSendEstimate(IdOrder, IdOrItem: Variant; FileName: string; AddFiles: TStringDynArray; MailTo: Boolean = True; TextToSend: string = '');
    function TaskForSendSnDocuments(IdOrder, IdOrItem: Variant): Boolean;
    function TaskForSendThnDocuments(IdOrItem: Variant): Boolean;
    function GetSubject(Subject: string; OrderName: string; IdOrder, IdOrderItem: Variant): string;
    function OrderItemsToDevel(IdOrder, IdOrItem: Variant): Boolean;
    function FinalizeOrder(IdOrder: Variant; OpMode: Integer; Mode: Integer = 1; Silent: Boolean = True): Integer;
    function FinalizeOrderM(IdOrder: Variant): Integer;
    //�������������� �������������� ������� � ����� ����� � ���
    //�� ������ ������ �������� �������� ���� ������������ � ���
    //���������������, ������ ���� ��� ������������ ���������, � ���� ������� ������������
    //��� �� � ���, �� � �����
    function RenameNomenclGlobal(Id, IdItm: Variant): Boolean;
    procedure SetOrderProperty_SyncWithITM;
    //����� ������� �� ������ ��� �������� ������ (Mode = True) ��� ��������� ������ �� ������ �������
    function OpenFromTemplate(Parent: TComponent; Mode: Boolean; var Id: Variant): Boolean;
    function CrealeEstimateOnPlannesOrders(DtBeg: TDateTime; ForSn: Boolean = False): Boolean;
    //��������� �������� ����������� � ���������� ������������ ��� ���������, ��� ����� ������� ��� �� ���
    //���� ������� � ���� ������� (spl_itm_nom_props)
    function CalcSplNeedPlanned(IdNomencl: Integer): Boolean;
    function SetTaskForCreateOrder(AIdOrder: Integer): Boolean;
    function ExportPassportToXLSX(AIdOrder: Integer; OrderPath: string; Open: Boolean = False; OnlyNot0: Boolean = False): Boolean;
    procedure CopyEstimateToBuffer(IdStdItem, IdOrItem: Variant);
    procedure ViewItmDocumentFromLog(AParent: TForm; AId: Variant);
  end;

var
  Orders: TOrders;

const
  SyncWithITM = True;   //���� False - ������ �������� ��� ������������� ���� ������� ������� � ���
  Group_NomFromCAD_Name: ansistring = '������������ �� CAD';
  Group_NomFromCAD_Id = 802;
  Group_NomToDel_Name: ansistring = '�� ��������';
  Group_NomToDel_Id = 2671;
  Group_Production_Id = 3;

  Group_Semiproducts_Id = 2;

  myOrFinalizePay = 0;
  myOrFinalizeFromSgp = 2;
  myOrFinalizeToSgp = 3;
  myOrFinalizeManager = 4;
  myOrFinalizeManual = 5;
  myOrFinalizeCancel = 6;
  myOrFinalizeUpd = 7;
  myOrFinalizeMontage = 8;

implementation

uses
  uSettings, uForms, uDBOra, uData, uWindows, uMessages, uExcel, uExcel2,
  LibXL, uFrmMain, uTasks, uSys, uFrmBasicInput, uFrmXDedtMemo;

constructor TOrders.Create;
begin
  inherited;
  fDtToSgpMin := EncodeDate(2024, 01, 17);
  fDtFromSgpMin := EncodeDate(2024, 01, 17);
  fDtMontageMin := EncodeDate(2024, 04, 25);
  fDtUpdMin := EncodeDate(2024, 05, 15);
  ftDtManagerMin := EncodeDate(2024, 05, 15);
  fDaysToSgp := 4;
  fDaysFromSgp := 4;
  fDaysMontage := 4;
  fDaysOtk := 1;
end;

procedure TOrders.Test;
var
  SDAFiles: TStringDynArray;
begin
  SDAFiles := TDirectory.GetFiles('r:\z\2023', '*.xls', TSearchOption.soAllDirectories);
  Sys.SaveTextToFile('r:\1', A.Implode(SDAFiles, #13#10));
end;

function TOrders.IsOrderFinalized(IdOrder: Variant; ShowMsg: Boolean = True; MinState: Integer = cOrItmStatus_Completed): Integer;
//���������, ��� ����� �������� (� �����), ���� � ������� �������� (���)
//���������� 0, ���� ��� �� ���, 1 ���� ��������, 2 ���� ��������, 100 ���� ����� �� ������
//�����������, ������� ��������
var
  va: TVarDynArray2;
  arst: TVarDynArray2;
begin
  Result:= 100;
  va:= Q.QLoadToVarDynArray2('select dt_end, id_status_itm, status_itm from v_orders where id = :id$i', [IdOrder]);
  if Length(va) = 0 then Exit;
  Result:= 0;
  if va[0][0] <> null
    then Result := cOrUchetStatus_Completed
    else Result := S.NInt(va[0][1]);
  if (Result >= MinState) and ShowMsg then
    MyWarningMessage(
      S.Decode([Result, 1, '���� ����� ��� ������, �������� � ��� ����������!', '���� ����� � ������� "' + S.NSt(va[0][2]) + '", �������� � ��� ����������!'])
    )
  else
    Result := 0;
end;


procedure TOrders.LoadBcadGroups(Force: Boolean = False);
begin
  if (Force) or (Length(BcadGroups) = 0) or (Length(BcadUnits) = 0) then begin
    FBcadGroups := Q.QLoadToVarDynArray2('select name, id, is_production from bcad_groups order by name', []);
    FBcadUnits := Q.QLoadToVarDynArray2('select name, id from bcad_units order by name', []);
  end;
end;

function TOrders.EstimateFromFile(var FileName: string; var Est: TVarDynArray2): Boolean;
//�������� ����� �� ����� xls � ������
//[Name, idgr, idunit, cQnt1, cComm];
//���� �������� ��� �����, �� �� ���������� ������ ������ � �� ������ ��������� �� ������
//����� ��������� ����� ���� ����������, ����������� �������� LoadBcadGroups(True);
type
  TRColumns = record
    cGr: Integer;
    cNo: Integer;
    cName: Integer;
    cUnit: Integer;
    cQnt1: Integer;    //������ (������) ������� ���-�� � �����
    cComm: Integer;
    rBeg: Integer;
  end;
var
  va: TVarDynArray2;
  i, j, k, idgr, idunit, errqnt, estqnt: Integer;
  nm, gr, err, erri, st, st1, st2: string;
  Silent: Boolean;
  EstimateFormat: Integer;
  Columns: TRcolumns;
const
  //��� ����� �� ������ bCAD ��� ���������
  cr1: TRcolumns = (
    cGr: 0;
    cNo: 0;
    cName: 1;
    cUnit: 3;
    cQnt1: 6;    //������ (������) ������� ���-�� � �����
    cComm: 13;
    rBeg: 1;
  );
  //��� ������ ����� (���� ����� ������) �� ���� �������
  cr2: TRcolumns = (
    cGr: 17;
    cNo: 17;
    cName: 18;
    cUnit: 20;
    cQnt1: 21;    //������ ������� ���-�� � �����
    cComm: 30;
    rBeg: 20;
  );
begin
  Result := False;
  Silent := FileName <> '';
  //������ ������, ����� ���������
//  FileName:='r:\�����1.xlsx';
  if not Silent then begin
    MyData.OpenDialog1.Options := [ofFileMustExist];
    MyData.OpenDialog1.Filter := '����� �����|*.xls; *.xlsx; *.xlsm';
    //����� �� ������ � ������
    if not MyData.OpenDialog1.Execute then
      Exit;
    FileName := MyData.OpenDialog1.Files[0];
  end;
  EstimateFormat := 0;
  //��������� ������ �� ���-�����, �� ����� 10000 �����
  va := [];
  if myxlsLoadSheetToArray(FileName, '��������� � �������������', 0, 0, 0, 0, 10000, 13, va) then
    EstimateFormat := 1;
  if (EstimateFormat = 0) and (myxlsLoadSheetToArray(FileName, '����� ������', 0, 0, 0, 0, 10000, 30, va)) then
    EstimateFormat := 2;
//  Sys.SaveArray2ToFile(va, 'd:\smeta.txt', False);  //!!!!

  if (EstimateFormat = 0) then begin
    if not Silent then
      MyWarningMessage('��������� ���� �� �������� ������!');
    Exit;
  end;
  if EstimateFormat = 1 then
    Columns := cr1
  else
    Columns := cr2;
  if not ((High(va) >= 2) and (High(va[0]) >= Columns.cComm) and ((EstimateFormat = 1) and (S.NSt(va[0][0]) = '�') and (S.NSt(va[0][1]) = '��������') and (S.NSt(va[0][2]) = '���') and (S.NSt(va[0][3]) = '��. ���.') and (S.NSt(va[0][13]) = '�����������')) or ((EstimateFormat = 2) and (S.NSt(va[Columns.rBeg - 1][Columns.cNo]) = '�') and (S.NSt(va[Columns.rBeg - 1][Columns.cName]) = '������������') and (S.NSt(va[Columns.rBeg - 1][Columns.cUnit]) = '��. ���.') and (S.NSt(va[Columns.rBeg - 1][Columns.cComm]) = '����������'))) then begin
//MyInfoMessage(S.NSt(va[Columns.rBeg-1][Columns.cNo]));
    MyWarningMessage('��������� ���� �� �������� ������!');
    Exit;
  end;
  Est := [];
  err := '';
  errqnt := 0;
  gr := #1;
  for i := Columns.rBeg to High(va) do begin
    erri := '';
    if S.NSt(va[i][Columns.cGr]) = '' then begin
      //������ ������� ������ - ��� ������� ����� �� ���� ��������� ���������
      if EstimateFormat = 1 then
        Break;
      //� ��� ������� ������� (�����) - ������� ���� � ������������ ������
      if S.NSt(va[i][Columns.cName]) = '' then
        Break;
      //��� ��������� ���������� ��������� - ������� ����������� �����
      va[i][Columns.cGr] := 1;
    end;
    if S.IsNumber(va[i][Columns.cGr], 1, 999999, 0) then begin
      if gr = #1 then
        S.ConcatStP(erri, '����� ������ ���������� � ������', '; ');
      if VarToStr(va[i][Columns.cName]) = '' then
        S.ConcatStP(erri, '�� ������ ������������', '; ');
      if not S.IsNumber(va[i][Columns.cQnt1], 0, 999999999, 50) then
        S.ConcatStP(erri, '�������� ����������', '; ');
      idunit := A.PosInArray(va[i][Columns.cUnit], BcadUnits, 0);
      if idunit <> -1 then
        idunit := BcadUnits[idunit][1];
      if idunit = -1 then
        S.ConcatStP(erri, '�� ������� ������� ���������', '; ');
      if erri <> '' then
        S.ConcatStP(err, '������ ' + IntToStr(i + 1) + ': ' + erri, #13#10)
      else if err = ''          //���������� ��������� �� ������ �����, � �� ���������� �������� ������ � ���������� ����������� � ������� ������� �� ������� ����� ���
        then
        Est := Est + [[va[i][Columns.cName], idgr, idunit, RoundTo(va[i][Columns.cQnt1], -5), va[i][Columns.cComm]]];
      if erri <> '' then
        inc(errqnt);
      if errqnt > 15 then
        Break;
    end
    else begin
      gr := va[i][Columns.cGr];
      idgr := A.PosInArray(va[i][Columns.cGr], BcadGroups, 0);
      if idgr <> -1 then
        idgr := BcadGroups[idgr][1];
      if idgr = -1 then begin
        S.ConcatStP(err, '������ ' + IntToStr(i + 1) + ': ' + '������ "' + VarToStr(va[i][Columns.cGr]) + '" ��� � �����������.', #13#10);
        inc(errqnt);
        if errqnt > 15 then
          Break;
      end;
    end;
  end;
  if err <> '' then begin
    if not Silent then
      MyInfoMessage('����� �� ���������!'#13#10#13#10 + err);
    Exit;
  end;
  Result := True;
end;


function TOrders.RefreshEstimatesAndSyncWithITM(IdOrder: Integer; OrderItems: TVarDynArray; LoadOrderAllItems: Boolean = True): Boolean;
//������������� ������ � ��� � ������� � �����, � ���������� � ���� ����
//�� �� ��� � SyncOrderWithITM, �� � ���������� � � ������� ���������
begin
  RefreshEstimatesToOrder(IdOrder, OrderItems, LoadOrderAllItems);
  Q.QBeginTrans(True);
  SyncOrderWithITM(IdOrder, OrderItems, LoadOrderAllItems);
  Q.QCommitOrRollback;
  if not Q.CommitSuccess
    then MyWarningMessage('��������� ������ ��� �������� ������ � ���!');
end;


function TOrders.SyncOrderWithITM(IdOrder: Integer; OrderItems: TVarDynArray; LoadOrderAllItems: Boolean = True): Boolean;
//������������� ������ � ��� � ������� � �����
//� ��� ����������� ����� � ��������� ����������� � ��� �������� ��� �����, � ����� �� ����������� ��, � ������� � ���������� ���������� ��� ������� ���
//������ ������ ������ ����������� ��� ��� �������� � ������ �������, ��������� �� LoadOrderAllItems, �������� ������ ������ ����������
//�� �������� ���� � ���, ������������ ��� ���, ��� ���������� � OrderItems ������, ����� ����� �� �����������
//�� ����� �����������������, ��� �������� �������������� ����
//� pnl_SyncOrderWithITM ���� ������ �������������� ��������, ���� �� �� 0, �� ������������� ������������ � ��� ������ ������� ����� ���, ������ ��������
//���� � ��� ����� ����� ����, � � ���� ������ >= ��������, �� � ��������� ����� ����� � ������������� �� ���������� (����� �������� ������)!
var
  st: string;
begin
  Result:= False;
  //������� ������ �� ������� ������������ ����, � ������� 0, ����� ��� ������ ������������� ����������� �������
  st:=A.Implode(OrderItems, ',', True) + S.IIFStr(not LoadOrderAllItems, ',0');
 // if SyncWithITM then begin  //!!!����. ��� ������ �� ����������� �������, ���� ��������� SyncWithITM = True !!!
  if Length(Q.QCallStoredProc('p_SyncOrderWithITM', 'AIdOrder$i;AOrItems$s', [IdOrder, st])) = 0 then Exit;
//  end;
  Result:= True;
end;

function TOrders.RefreshEstimatesToOrder(IdOrder: Integer; OrderItems: TVarDynArray; LoadOrderAllItems: Boolean = True): Boolean;
//������� (������������) ��� ����� ��� ������� ������
//��� ���� ����� �� ����������� ������� � ����� �/� ����� �����������
//(�� ����������� ������������ ����������� �����, ���� ����), ��� �/� �� ����� �������
//� �� ����� �� ������������� �� �������� ������� ����� �������� ���������� ������� � ������������ � ����������� ������� � ������
//
//���� LoadOrderAllItems, �� ������� ���������� ��� �����, � ����� ������ ��� ��� ������� ������, ���� ������� �������� � OrderItems
//
//���������� ����������� � ����������� ��� ������ ����� � LoadEstimate !
var
  va1, va2: TVarDynArray2;
  va: TVarDynArray;
  i, j: Integer;
  IdOrderItem: Integer;
  IdEstimate: Variant;
  HasestimateUpload: Boolean;
begin
  //������� ������ ������� � ������
  va1 := Q.QLoadToVarDynArray2('select id, nstd, 0 as resale, id_std_item, id_order_itm, sync_with_itm from v_order_items where id_order = :id_order$i', [IdOrder]);
//  exit;
  if Length(va1) = 0 then
    Exit;
  LoadBcadGroups(True);
  HasestimateUpload := False;
  //������� �� �������
  for i := 0 to High(va1) do begin
    if (not LoadOrderAllItems) and (not A.InArray(va1[i][0], OrderItems)) then
      Continue;
    if (va1[i][1] = 1) and (va1[i][2] <> 1)
      //��� ������������� � ��� ���� �� �������� (�� �/�) - ������� ���������� ������� ������������ �������
      then  LoadEstimate(null, va1[i][0], null, False, True, True)
      //����� ������� ����� �� ����������� ���� �� ��������� ������������ �/�
      else  LoadEstimate(null, va1[i][0], null, False, False, True);
    HasestimateUpload := True;
  end;
(*
  //������ �� �� ���������� �� ��������, � ���������� ������ ��
  //���������� ���� � ����� ����, ���� ������ ����� ��� �� �������� (��� ��� ����_���, ��� ������������ ��� �� �� ����������������), �� � �� ��������� ��� �������� ���������� ���
  if (SyncWithITM) and (va1[0][5] = 1) and (va1[0][4] <> null) then begin
    //�������� ��������� �� ������ ���������� ������ � ������ ��������� � ������� ������ ��� ����
    //������ ������� ���� ���� ���� ����� ��������� � ��������� ����� ������, ��� �� ���������� ����
    if HasestimateUpload then begin
      va := Q.QCallStoredProc('DV.p_SyncOrder_Finish', 'id_dv$i', [IdOrder]);
      Q.QExecSql('insert into adm_db_log (itemname, comm) values (:itemname$s, :comm$s)', ['pnl_SyncOrder_Finish', 'id_order ' + VarToStr(IdOrder)]);
    end
    else begin
      Q.QExecSql('insert into adm_db_log (itemname, comm) values (:itemname$s, :comm$s)', ['Order finished', 'id_order ' + VarToStr(IdOrder)]);
    end;
  end;
//  Res:=S.IIf(Length(va1) = 0, -1, 1);
*)
end;

function TOrders.SetEstimateQnt(IdEstimate: Integer; Qnt: extended): Boolean;
begin
  Q.QExecSql('update estimate_items set qnt = round(qnt1 * :qnt_or$f, 1) where id_estimate = :id_estimate$i', [Qnt, IdEstimate]);
end;

function TOrders.LoadEstimate(IdOrder, IdOrderItem, IdStdItem: Variant; OneItem: Boolean = True; QntChanged: Boolean = False; Silent: Boolean = False): Integer;
//��������� ����� ��� ������� � ������ ���� ������������ �������
//����� �������� �� ����� ��� ������������ �������, �� ��������� ������������ ������� ��� ���. ������������ (����������� � ���),
//�� ��������� �����, ��� ����������� ��� ������� � �����������, � ������ ������ ��� ������������ ������� � ������
//� ������ ������� � ������ ����������� ��� ���-�� �� �������, ��� � �����
//
//���������� - ���� ������ (�� �����������), ���� ����������� ������� ��� �������� ����� � ����������� � ����, ��� ����, �� ������� � ������ ��� ����
//OneItem - �������� ������ ����� �������, � ���� ������ ����������� ����������� ����� � ������, � �������������� ����� � ���, ����� ��� �������� ���� ��������� �������
//QntChanged - ������������ �� �������� �����, � �������� ���������� ��� ��� ������������ �� ��������� ���-�� ������
// ��� ���-�� � ������ = 0, ����� ���������.
//Silent - �� ����������� ������ � �� �������� ����������

//������� ��� ����� �� �������� ���������� ����� � ����
//������ � estimates ����, ������ �������/����������� ���� � ������� IsEmpty
//�� ������� � estimate_items ��� ����� ������ � estimates ��� �� �����!

var
  FileName: string;
  va, Est: TVarDynArray2;
  i, j, k, idgr, idunit, errqnt, estqnt: Integer;
  nm, gr, err, erri, st, st1, st2: string;
  OrNum, OrSlashCnt: Integer;
  Res: Integer;
  IdEstimate, ParentIdStdItem, ParentIdEstimate: Variant;
  dt1: Variant;
  OrName: string;
  va1: TVarDynArray;
  IsOrItemStd: Boolean;
  OrQnt: Variant;
  OrItemIdItm, OrItemName, OrFullItemName, OrderIdItm, OrderIdUchet, IsEstimateEmpty, OrSyncWithITM: Variant;
  b: Boolean;
  InputType: Integer;
  v: Variant;
  vatest: TVarDynArray;
  OpenEditEstimateDialog: Boolean;
begin
{(*}
  InputType:= mrYes;
  OpenEditEstimateDialog:= False;
  if IdStdItem <> null then begin
    //��� ������������ �������
    dt1 := null;
    va1 := Q.QSelectOneRow('select id, dt from estimates where id_std_item = :id_std_item$i', [IdStdItem]);
    IdEstimate := va1[0];
    if IdEstimate <> null then
      dt1 := S.NSt(va1[1]);
    if S.IsDateTime(S.NSt(dt1)) then
      dt1 := DateTimeToStr(VarToDateTime(dt1));
    va1 := Q.QSelectOneRow('select name, wo_estimate from or_std_items where id = :id$i', [IdStdItem]);
    OrName := va1[0];
    IsEstimateEmpty := va1[1];
    IsOrItemStd := False;
    if not Silent then begin
      if IdEstimate = null then begin
        //��� �� ���������
        if IsEstimateEmpty then begin
          if MyQuestionMessage('��������� ������� "��� �����" ��� ������������ �������'#13#10'"' + OrName + '" ?') <> mrYes
            then Exit;
        end
        else
          OpenEditEstimateDialog:= True;
//          st := '��������� ����� ��� ������������ �������'#13#10'"' + OrName + '" ?';
      end
      else begin
        //��� ���������
        if IsEstimateEmpty then begin
          MyWarningMessage('����� ��� ������������ �������'#13#10'"' + OrName + '"'#13#10'�� �������������!');
          Exit;
        end
        else
          OpenEditEstimateDialog:= True;
        //st := '����� ��� ������������ �������'#13#10'"' + OrName + '"'#13#10'��� ���������' + S.IIFStr(dt1 = '', '', ' (' + dt1 + ')') + '.'#13#10'�������� �����?';
      end;
  {    InputType := myMessageDlg(st, mtConfirmation, [mbYes, mbNo, mbCancel], '�� �����;�������;������');
      if InputType = mrCancel then
        Exit;
//      (MyQuestionMessage('��������� ����� ��� ������������ �������'#13#10'"' + OrName + '" ?') <> mrYes) or (IdEstimate <> null) and (MyQuestionMessage('����� ��� ������������ �������'#13#10'"' + OrName + '"'#13#10'��� ���������' + S.IIFStr(dt1 = '', '', ' (' + dt1 + ')') + '.'#13#10'�������� �����?') <> mrYes) then
   //     Exit;}
    end;
  end
  else if (IdOrderItem <> null) then begin
    //�������� �� ������� (�����) � ������
    dt1 := null;
    va1 := Q.QSelectOneRow('select id, dt from estimates where id_order_item = :id_order_item$i', [IdOrderItem]);
    IdEstimate := va1[0];
    if IdEstimate <> null then
      dt1 := S.NSt(va1[1]);
    if S.IsDateTime(S.NSt(dt1)) then
      dt1 := DateTimeToStr(VarToDateTime(dt1));
    va1 := Q.QSelectOneRow('select itemname, slash, wo_estimate, std, id_std_item, qnt, id_itm, id_order_itm, id_order, fullitemname, sync_with_itm from v_order_items where id = :id$i', [IdOrderItem]);
    OrName := va1[1] + ' - ' + va1[0];
    IsEstimateEmpty := va1[2];
    IsOrItemStd := va1[3] = 1;
    ParentIdStdItem := va1[4];
    OrItemIdItm := va1[6];
    OrItemName := va1[0];
    OrderIdItm := va1[7];
    OrderIdUchet := va1[8];
    OrFullItemName := va1[9];
    OrSyncWithITM := va1[10];  //������ ����� ���������������� � ���
    OrQnt := va1[5];
    //����� �������� ��� �������� (� ���) - ������� ��������� � ������.
    if Orders.IsOrderFinalized(OrderIdUchet, not Silent) > 0 then Exit;
    if IsOrItemStd then begin
      ParentIdEstimate := Q.QSelectOneRow('select id from estimates where id_std_item = :id_std_item$i', [ParentIdStdItem])[0];
      if not Silent then
        if ParentIdEstimate = null then begin
          MyWarningMessage('����� � ������������ ������� � ���� ������� ������ ��� �� ���������!');
          Exit;
        end;
      if not Silent then
        if (IdEstimate = null) and
           (MyQuestionMessage(
             '��������� ����� ��� ������� � ������'#13#10'"' + OrName + '"'#13#10'�� ����������� ����������� �������?'
           ) <> mrYes)
             or
           (IdEstimate <> null) and (MyQuestionMessage(
             '����� ��� ������� � ������'#13#10'"' + OrName + '"'#13#10'��� ���������' +
             S.IIFStr(dt1 = '', '', ' (' + dt1 + ')') + '.'#13#10'�������� ����� �� ����������� ����������� �������?'
           ) <> mrYes) then
          Exit;
    end
    else begin
      if not Silent then begin
//        if (IdEstimate = null) and (MyQuestionMessage('��������� ����� ��� ������� � ������'#13#10'"' + OrName + '" ?') <> mrYes) or
//           (IdEstimate <> null) and (MyQuestionMessage('����� ��� ������� � ������'#13#10'"' + OrName + '"'#13#10'��� ���������' + S.IIFStr(dt1 = '', '', ' (' + dt1 + ')') + '.'#13#10'�������� �����?') <> mrYes) then
//          Exit;
        if IsEstimateEmpty then begin
          MyWarningMessage('����� ��� ������� � ������'#13#10'"' + OrName + '"'#13#10'�� �������������!');
          Exit;
        end
        else
          OpenEditEstimateDialog:= True;
{        if (IdEstimate = null)
          then st := '��������� ����� ��� ������� � ������'#13#10'"' + OrName + '" ?'
          else st := '����� ��� ������� � ������'#13#10'"' + OrName + '"'#13#10'��� ���������' + S.IIFStr(dt1 = '', '', ' (' + dt1 + ')') + '.'#13#10'�������� �����?';
        InputType := myMessageDlg(st, mtConfirmation, [mbYes, mbNo, mbCancel], '�� �����;�������;������');
        if InputType = mrCancel then
          Exit;}
      end;
    end;
  end;

  if not ((IsEstimateEmpty = 1) or IsOrItemStd or QntChanged) then begin
    //�������������� �������� ������ � ������� ���� - ���� �������� ���� �����, �� ������������, ����� ������ ������ ���� ��� �� ��������
    LoadBcadGroups(OneItem);
    //���� ��� �� ����������� � �� �������� ������� �� ������, � �� ����� ��������� ����������, �������� ����� �� �����
    FileName := '';
 //   if InputType <> mrNo then begin
{    if not EstimateFromFile(FileName, Est) then
      Exit;
    end
    else begin}
    if OpenEditEstimateDialog then begin
      //������-����� ��� ����� �����
      Wh.ExecDialog(myfrm_Dlg_NewEstimateInput, FrmMain, [myfoModal, myfoSizeable],
        fAdd, IdEstimate, VararrayOf([IdEstimate, S.IIf(IdStdItem <> null, 0, 1), OrName])
      );
      //�����������! ����� ������ �� ��������� ���������� ����!
      Application.ProcessMessages;
      if Length(Wh.SelectDialogResult2) = 0 then
        Exit;
      Est:=Wh.SelectDialogResult2;
    end;
  end
  else if ((IsEstimateEmpty = 1) and not IsOrItemStd) then begin
    //��� ������ ����� �������� ������ ������, ���� ����� ������ �������� �����, �� ������� ������� �� �����
    //(����� � ��������� isempty �� �������� ������� ������� (estimate_items))
    Est := [];
  end;

  Q.QBeginTrans(True);
  repeat
    Res := 1;
    if (IdOrderItem <> null) and (S.NNum(OrQnt) = 0) then begin
    //���� ��� ����� �� ������� ������, � �� ��� ���������� ����� ����, �� ����� �� �������, � ���� ��� ��� ���� - �������
      if IdEstimate = null then
        Break
      else
        Res := Q.QIUD('d', 'estimates', '', 'id$i', [IdEstimate]);
      if Res = -1 then
        Break;
    end
    else begin
    //�� ���� ��������� �������
    //�������� �����
      Res := Q.QIUD(S.IIFStr(IdEstimate = null, 'i', 'u')[1], 'estimates', '',
       'id$i;id_std_item$i;id_order_item$i;isempty$i;dt$d',
       [IdEstimate, IdStdItem, IdOrderItem, IsEstimateEmpty, Date]);
      if Res = -1 then Break;
      if IdEstimate = null then
        IdEstimate := Res
      else
        //���� ��������� ������ ����� (������� ������ ��� �����), �� ������ ��� ������� ���� ��� ����
        if IsEstimateEmpty
          then Q.QExecSql('delete from estimate_items where id_estimate = :id_estimate$i', [IdEstimate]);
        //���� ��� ���� ����� �������, �� ��� ������� ������� �� ��������
        Res := Q.QExecSql('update estimate_items set deleted = 1 where id_estimate = :id_estimate$i', [IdEstimate]);
      if Res = -1 then
        Break;
      if QntChanged then begin
      //��������� ���������� � �����, ���������� ���� ������, ��������� ���� ������� ���������� � ������
        va1 := Q.QCallStoredProc('p_CorrectEstimateQnt', 'idorderitem$i', [IdOrderItem]);
        if Length(va1) = 0 then
          Res := -1;
      end
      else if IsOrItemStd then begin
      //�������� �� ����������� �����
        va1 := Q.QCallStoredProc('p_copyestimate', 'idestimate$i;idstdestimate$i;pqntinor$f', [IdEstimate, ParentIdEstimate, OrQnt]);
        if Length(va1) = 0 then
          Res := -1;
      end
      else begin
      //������� ��� ������������� �����
        for i := 0 to High(Est) do begin
          try
            va1 := Q.QCallStoredProc('p_createestimateitem',
            'pid_estimate$i;pid_group$i;pname$s;pid_unit$i;pcomment$s;pqnt1$f;pqnt$f',
             [IdEstimate, Est[i][1], Est[i][0], Est[i][2], Est[i][4], Est[i][3], Est[i][3]]
             );
            if Length(va1) = 0 then
              Res := -1;
            if Res = -1 then
              MyWarningMessage('������ ��� �������� ������� "' + VartoStr(Est[i][0]) + '"!');
          except

            Res := -1;
          end;
          if Res = -1 then
            Break;
        end;
      end;
    //������ �������, ������� �������� �������� �� ��������
      if Res = -1 then
        Break;
      Res := Q.QExecSql('delete from estimate_items where deleted = 1 and id_estimate = :id_estimate$i', [IdEstimate]);
      if Res = -1 then
        Break;
    //++
    //������������� ����� � ������ ����������, ��������� ���������� ��� ���
      if Length(Q.QCallStoredProc('p_CorrectEstimateWithReplace', 'id_estimate$i', [IdEstimate])) = 0 then
        Break;
    //������ �����, ���� � ��� ��� �� ������ ��������
      Q.QCallStoredProc('p_DeleteFreeEstimate', 'id_estimate$i', [IdEstimate]);
    end;
    //�������������� � ���, � ������ ���� ����������� ����� ������ �� ������ ������� ������
    if (IdOrderItem <> null) and (OneItem)
      then SyncOrderWithITM(OrderIdUchet, [IdOrderItem], False);
  until True;
  Q.QCommitOrRollback(Res <> -1);
  if not Q.CommitSuccess then begin
    if (IdOrderItem <> null)
      then MyWarningMessage('����� ' + S.IIfStr(IdOrderItem <> null, '� ������� "' + OrName + '" ') + '�� ���������!')
  end
  else if not Silent then begin
    //������ ��� ��������� ������������� ����� �� ������ - ���������� �������� ����� � ������� ������ � �� �����
    if not ((IsEstimateEmpty = 1) or IsOrItemStd or QntChanged or (IdStdItem <> null) or not OneItem) then begin
      st2 := '';
      b := False;
      if Q.QSelectOneRow('select dt_aggr_estimate from orders where id =:id$i', [OrderIdUchet])[0] <> null then begin
        FrmXDedtMemo.ShowDialog(nil, 'AttachEstimate', '����������� � �����', '', st2);
        b := True;
      end;
      TaskForSendEstimate(OrderIdUchet, IdOrderItem, FileName, [], b, st2);
    end;
    if Length(Est) > 0 then
      MyInfoMessage('����� �� ' + IntToStr(Length(Est)) + ' ������' + S.GetEnding(Length(Est), '�', '�', '�') + ' ������� ���������.')
    else
      MyInfoMessage('����� ������� ���������.');
  end;
  Result := Res;
{*)}
end;

function TOrders.RemoveEstimateForStdItem(IdStdItem: Variant; Silent: Boolean = False): Boolean;
//������� ����� ��� ����������� ������������ �������. ���� �� Silent, �� ����� ���� �������.
//������ True, ����� ������ ������ ��� ����������� ������� ��������
var
  va1, va2: TVarDynArray;
begin
  Result:= True;
  va1 := Q.QSelectOneRow('select id, dt from estimates where id_std_item = :id_std_item$i', [IdStdItem]);
  if va1[0] = null then Exit;
  if not Silent then begin
    va2:= Q.QSelectOneRow('select name, wo_estimate from or_std_items where id = :id$i', [IdStdItem]);
    if MyQuestionMessage('������� ����� ��� ������������ �������'#13#10'"' + va2[0] + '" ?') <> mrYes
      then Exit;
  end;
  Result:=Q.QExecSql('delete from estimates where id_std_item = :id_std_item$i', [IdStdItem]) >= 0;
end;


function TOrders.LoadSmetaOld(IdOrder: Integer): Integer;
var
  i, j, k, sti, irow, f1, i1, i2, i3: Integer;
  dtype, doctype: Integer;
  nm, gr, st, st1, st2: string;
  Excel, Sh: Variant;
  ExcelExecute: Boolean;
  FileName: string;
  a1: TVarDynArray2;
  OrList, OrSlashUchet: TVarDynArray2;
  Groups, Materials: TVarDynArray2;
  OrNum, OrSlashCnt: Integer;
  FilesArr: TStringDynArray;
  FilesArr1: TVarDynArray2;
  FilesArrDB: TVarDynArray2;
  LogSt, OrdersPath, OrderPath: string;
  FilesChanged: Boolean;
  Res: Integer;
  SmetaArr: array[1..2] of array[0..999] of TVarDynArray2;
  SmetaArrH: array[0..999] of TVarDynArray;
const
  cGr = 0;
  cNo = 1;
  cName = 2;
  cCode = 3;
  cEd = 4;
  cQnt1 = 5;
  cQntA = 6;
  cComm = 7;

  procedure LoadMaterials;
  begin
    Groups := Q.QLoadToVarDynArray2('select id, name_bcad from material_groups order by name', []);
    Materials := Q.QLoadToVarDynArray2('select id, id_group, name, dim from materials order by name', []);
  end;

  function SetGroup(Name: string): Integer;
//������ ������ � ������� �����, ���� �� ��� ����,
//����� ������� � �� � ������� � ����� �������
//������ ���� ������
  var
    i: Integer;
  begin
    for i := 0 to High(Groups) do begin
      if Name = Groups[i][1] then begin
        Result := Groups[i][0];
        Break;
      end;
    end;
    if i > High(Groups) then begin
      Result := Q.QIUD('i', 'material_groups', '', 'id$i;name_bcad$s', [0, Name]);
      if Result = -1 then
        Exit;
      SetLength(Groups, Length(Groups) + 1);
      Groups[High(Groups)] := [Result, Name];
    end;
  end;

  function SetMaterial(Name: string; dim: string; ID_Group: Integer): Integer;
//������ �������� � �������, ���� �� ��� ����,
//����� ������� � �� � ������� � ����� �������
//������ ���� ���������
  var
    i: Integer;
  begin
    for i := 0 to High(Materials) do begin
      if Name = Materials[i][2] then begin
        Result := Materials[i][0];
        Break;
      end;
    end;
    if i > High(Materials) then begin
      Result := Q.QIUD('i', 'materials', '', 'id$i;id_group$i;name$s;dim$s', [0, ID_Group, Name, dim]);
      if Result = -1 then
        Exit;
      SetLength(Materials, Length(Materials) + 1);
      Materials[High(Materials)] := [Result, ID_Group, Name, dim];
    end;
  end;

  procedure SetSmetaMaterial(Slash: Integer; Id: Integer; Qnt: Variant; DocType: Integer = 4);
//��������/�������� �������� � ������� ����� �� �����
//SmetaArr[Slash] = [id, id_material, qnt, deleted, state]
  var
    i, d: Integer;
  begin
  //1-������ ���� ��� ����� ��, 2 - ��� ��������� ����������
    if DocType = 4 then
      d := 1
    else
      d := 2;
    if not S.IsNumber(Qnt, 0, 9999999) then
      Qnt := 0
    else
      Qnt := S.VarToFloat(Qnt);
    for i := 0 to High(SmetaArr[d][Slash]) do begin
      if Id = SmetaArr[d][Slash][i][1] then begin
        if (Qnt <> SmetaArr[d][Slash][i][2]) or (SmetaArr[d][Slash][i][3] = 1) then begin
        //���� �� ��������� ����������, ��� ������� ��������� - ������� �� ������
          SmetaArr[d][Slash][i][2] := Qnt;
          SmetaArr[d][Slash][i][3] := null;
          SmetaArr[d][Slash][i][4] := 2;
        end      //� ���� ��������� ���, �� ������� ��� (��� �� �������)
        else
          SmetaArr[d][Slash][i][4] := 1;
        Break;
      end;
    end;
    if i > High(SmetaArr[d][Slash]) then begin
    //���� ��� � ����� ���� - �������
      SmetaArr[d][Slash] := SmetaArr[d][Slash] + [[0, Id, Qnt, null, 3]];
    end;
  end;

  function SetSmetaUsed(SlashNo: Integer; DocType: Integer): Boolean;
//�������, ������������ �� ����� ��� ���������� �� ������� ���� ��������� � �� ������� �����
//���������� ����, ���� �� ������� ��������� ��� ��������� ����� �� ������� �����
//����������� �������� �� ����� ��, ���� ���� ��������� ����� �� ����������
  var
    i, d: Integer;
  begin
    Result := False;
    if SlashNo <= 0 then
      Exit;
    if DocType = 4 then
      d := 1
    else
      d := 2;
    inc(SmetaArrH[SlashNo][d]);
    Result := (SmetaArrH[SlashNo][d] = 1) and ((d = 1) or (SmetaArrH[SlashNo][1] = 0));
  end;

  function ProcessFile(FileName: string): Integer;
  var
    i, j, k, sti, irow, f1: Integer;
    dtype, doctype: Integer;
    nm, gr, gr_old, dim, st, st1, st2: string;
    isGroup: Boolean;
    ID_Material, ID_Group: Integer;
    Slash: Integer;
    Qnt: Variant;
    Slashes: array[0..999] of Integer;
  begin
    if not ExcelExecute then begin
      Excel := CreateOleObject('Excel.Application');
      ExcelExecute := True;
    end;
    Excel.Workbooks.Open(FileName, True, True);
    Excel.DisplayAlerts := False; // for prevent error in SetValue procedure, where VarName not fount for replace
    Excel.Visible := False;
    dtype := 0;
    for i := 1 to Excel.Workbooks[1].WorkSheets.Count do begin
      if Excel.Workbooks[1].WorkSheets[i].Name = '��' then begin
        dtype := 1;
        Break;
      end
      else if Excel.Workbooks[1].WorkSheets[i].Name = '����� ������' then begin
        dtype := 2;
        Break;
      end;
    end;
//MyInfoMessage(inttostr(dtype));
    doctype := 0;
    if dtype > 0 then begin
      Sh := Excel.Workbooks[1].WorkSheets[i];
      if S.NSt(Sh.Cells[3, 1].Value) = '��������' then begin
      //����� ������� �������
        if (S.NSt(Sh.Cells[4, 1].Value) = '������������ �������') and (S.NSt(Sh.Cells[5, 1].Value) = '� �������� ������ ��') and (S.NSt(Sh.Cells[16, 1].Value) = '����� �� ���������') and (S.NSt(Sh.Cells[17, 1].Value) = '�') then begin
          doctype := 1;
          sti := 18;
          Slash := -1;
        end;
      end
      else if S.NSt(Sh.Cells[13, 1].Value) = '��������:' then begin
      //����� ������ �������
        if (S.NSt(Sh.Cells[14, 1].Value) = '������������ �������:') and (S.NSt(Sh.Cells[19, 1].Value) = '����� �� ���������') and (S.NSt(Sh.Cells[20, 1].Value) = '�') then begin
          doctype := 2;
          sti := 21;
          st := S.NSt(Sh.Cells[2, 1].Value);
          if pos('_', st) > 0 then
            Slash := StrToIntDef(Trim(Copy(st, pos('_', st) + 1)), -1)
          else
            Slash := -1;
        end;
      end
      else if Trim(S.NSt(Sh.Cells[1, 1].Value)) = '����� ������ �� ���������' then begin
      //������ ��
        if (Trim(S.NSt(Sh.Cells[2, 1].Value)) = '����� ������:') and (Trim(S.NSt(Sh.Cells[3, 1].Value)) = '��������:') and (Trim(S.NSt(Sh.Cells[4, 1].Value)) = '�������') then begin
          doctype := 3;
          sti := 7;
          st := S.NSt(Sh.Cells[2, 4].Value);
          if pos('_', st) > 0 then
            Slash := StrToIntDef(Trim(Copy(st, pos('_', st) + 1)), -1)
          else
            Slash := -1;
        end;
      end
      else if Trim(S.NSt(Sh.Cells[2, 2].Value)) = '��������' then begin
      //������������ ������ ��
        if (Trim(S.NSt(Sh.Cells[6, 6].Value)) = '�����:') and (Trim(S.NSt(Sh.Cells[6, 7].Value)) = '����������') and (Trim(S.NSt(Sh.Cells[9, 2].Value)) = '������������') then begin
          doctype := 4;
          sti := 10;
          Slash := 0;
          //������� �� �������� �����, ������� ������ ������ � �������� ����� �� �� ��� �������� ����������, �������� ��� � �������
          for j := 0 to 999 do begin
            st := S.NSt(Sh.Cells[8, 8 + j].Value);
            if st = '' then
              Break;
            if pos('_', st) > 0 then
              Slashes[j] := StrToIntDef(Trim(Copy(st, pos('_', st) + 1)), -1)
            else
              Slashes[j] := -1;
            if not SetSmetaUsed(Slashes[j], doctype) then
              Slashes[j] := -1
          end;
        end;
      end;
    end;
    Result := doctype;
    if (Result = 0) or ((doctype <> 4) and (SetSmetaUsed(Slash, doctype))) then begin
      Excel.Workbooks[1].Close;
      Result := 0;
      Exit;
    end;

    irow := Sh.UsedRange.Row + Sh.UsedRange.Rows.Count + 3; //!
    gr := '��������� ��� �����';
    gr_old := '';
    for i := sti to sti + 10000 do begin
//    Application.ProcessMessages;
      try
        isGroup := False;
        if (doctype in [1, 3]) then begin
      //������ ����� � ������ �� �����
      //'��������� ���������, ������ ����������� (�� ������) - ����� � ������ �������
      //���������� ��������� ����� �� ������� �������� � ��� (��� �������� �� ��� ������), � �� ���������
          if not (((S.NSt(Sh.Cells[i, 1].Value) = '') and (S.NSt(Sh.Cells[i, 2].Value) = '')) or ((S.NSt(Sh.Cells[i, 1].Value) = '0') and (S.NSt(Sh.Cells[i, 2].Value) = '0'))) then begin
            if (S.NSt(Sh.Cells[i, 2].Value) <> '') and (S.NSt(Sh.Cells[i, 2].Value) <> '0') then begin
              nm := Sh.cells[i, 2].Value;
              dim := Sh.cells[i, 4].Value;
              Qnt := Sh.Cells[i, 9].Value;
{          for j:=0 to High(a1) - 1 do
            if (High(a1[j]) = -1) or (S.NSt(a1[j, 1]) = nm)
              then Break;
          st:=S.IIFStr(doctype = 1, Sh.Cells[i, 16].Value, Sh.Cells[i, 10].Value);
          if High(a1[j]) = -1
            then a1[j] := [gr, nm, Sh.Cells[i, 3].Value, Sh.Cells[i, 4].Value, S.NNum(Sh.Cells[i, 9].Value), st]
            else begin
              a1[j][4]:=a1[j][4] + S.NNum(Sh.Cells[i, 9].Value);
              if st <> '' then a1[j][5]:=a1[j][5] + '|' + st;
            end;}
            end
            else begin
              gr := S.NSt(Sh.Cells[i, 1].Value);
              isGroup := True;
            end;
          end
          else if i > irow then
            Break;
{          k = k + 1
          sh.Cells(j, 1) = k 'no
          sh.Cells(j, 2) = arr(i, 2) '������������
          sh.Cells(j, 3) = arr(i, 3) '���
          If sh.Cells(j, 3) = "0" Then sh.Cells(j, 3) = ""
          sh.Cells(j, 4) = arr(i, 4) '�� ���
          sh.Cells(j, 5) = arr(i, 5) '���� �����
          sh.Cells(j, 9) = arr(i, 9) '�������� � ���
          If doctype = 1 Then sh.Cells(j, 10) = arr(i, 16) Else sh.Cells(j, 10) = arr(i, 11) '����������
          If sh.Cells(j, 10) = "0" Then sh.Cells(j, 10) = ""
          If sh.Cells(j, 10) = "0" Then sh.Cells(j, 10) = ""
          j = j + 1
        Else
          sh.Cells(j, 1) = ""
          sh.Cells(j, 2) = arr(i, 1) '������
          j = j + 1
        End If
      End If}
        end;
        if (doctype in [2]) then begin
      //����� �����
      //������ ��������� - ������ ������ �������, ������ ��� � �������� � ���������
          if not (((S.NSt(Sh.Cells[i, 1].Value) = '') and (S.NSt(Sh.Cells[i, 4].Value) = '')) or ((S.NSt(Sh.Cells[i, 1].Value) = '0') and (S.NSt(Sh.Cells[i, 4].Value) = '0'))) then begin
            if (S.NSt(Sh.Cells[i, 1].Value) <> '') and (S.NSt(Sh.Cells[i, 1].Value) <> '0') then begin
              nm := Sh.cells[i, 4].Value;
              dim := Sh.cells[i, 8].Value;
              Qnt := Sh.Cells[i, 11].Value;
{st2:=Sh.Cells[i, 11].Value;
S.NNum(Sh.Cells[i, 11].Value);
          for j:=0 to High(a1) - 1 do
            if (High(a1[j]) = -1) or (S.NSt(a1[j, 1]) = nm)
              then Break;
          //st:=S.IIFStr(doctype = 1, Sh.Cells[i, 16].Value, Sh.Cells[i, 10].Value);
          st:=S.NSt(Sh.Cells[i, 12].Value);
          if High(a1[j]) = -1
            then a1[j] := [gr, nm, Sh.Cells[i, 6].Value, Sh.Cells[i, 8].Value, S.NNum(Sh.Cells[i, 11].Value), st]
            else begin
              a1[j][4]:=a1[j][4] + S.NNum(Sh.Cells[i, 11].Value);
              if st <> '' then a1[j][5]:=a1[j][5] + '|' + st;
            end;}
            end
            else begin
              gr := S.NSt(Sh.Cells[i, 4].Value);
              isGroup := True;
            end;
{      If Not (((CStr(arr(i, 1)) = "") And (CStr(arr(i, 4)) = "")) Or ((CStr(arr(i, 1)) = "0") And (CStr(arr(i, 4)) = "0"))) Then
        If (arr(i, 1) <> "") And (arr(i, 1) <> 0) Then
          k = k + 1
          sh.Cells(j, 1) = k 'no
          sh.Cells(j, 1) = arr(i, 1) 'no
          sh.Cells(j, 2) = arr(i, 4) '������������
          sh.Cells(j, 3) = arr(i, 6) '���
          If sh.Cells(j, 3) = "0" Then sh.Cells(j, 3) = ""
          sh.Cells(j, 4) = arr(i, 8) '�� ���
          sh.Cells(j, 5) = arr(i, 9) '���� �����
          sh.Cells(j, 9) = arr(i, 11) '�������� � ���
          sh.Cells(j, 10) = arr(i, 12)
          If sh.Cells(j, 10) = "0" Then sh.Cells(j, 10) = ""
          j = j + 1
        Else
          sh.Cells(j, 1) = ""
          sh.Cells(j, 2) = arr(i, 4) '������
          j = j + 1
        End If
      end;}
          end
          else if i > irow then
            Break;
        end;
        if (doctype in [4]) then begin
      //������ �� �����
      //������ ��������� - ������ ������� �������� ������, � ������ �� ������, ������ � ������ �������
          if (S.NSt(Sh.Cells[i, 1].Value) <> '') or (S.NSt(Sh.Cells[i, 2].Value) <> '') then begin
            if S.IsNumber(S.NSt(Sh.Cells[i, 1].Value), 1, 10000) and (S.NSt(Sh.Cells[i, 1].Value) <> '') then begin
              nm := Sh.cells[i, 2].Value;
              dim := Sh.cells[i, 4].Value;
{          for j:=0 to High(a1) - 1 do
            if (High(a1[j]) = -1) or (S.NSt(a1[j, 1]) = nm)
              then Break;
if nm = '���������/������/D25 ������' then begin

end;
          //st:=S.IIFStr(doctype = 1, Sh.Cells[i, 16].Value, Sh.Cells[i, 10].Value);
          st:=S.NSt(Sh.Cells[i, 7].Value);
          if High(a1[j]) = -1
            then a1[j] := [gr, nm, Sh.Cells[i, 5].Value, Sh.Cells[i, 4].Value, S.NNum(Sh.Cells[i, 6].Value), st]
            else begin
              a1[j][4]:=a1[j][4] + S.NNum(Sh.Cells[i, 6].Value);
              if st <> '' then a1[j][5]:=a1[j][5] + '|' + st;
            end;     }
            end
            else begin
              gr := S.NSt(Sh.Cells[i, 1].Value);
              isGroup := True;
            end;
          end
          else if i > irow then
            Break;
        end;
    //���� ��������� ������ - ������� ���� ������ � ����� ���� ������� �� � ������ �����
        if (gr <> gr_old) and (gr <> '') then begin
          gr_old := gr;
          ID_Group := SetGroup(gr);
        end;
    //��� ���������
        if (not isGroup) and (nm <> '') then begin
      //������� ��� ����, ���� ���� ������� � ������
          ID_Material := SetMaterial(nm, dim, ID_Group);
          if doctype <> 4        //��� ��������� ���������� - ������� � ������ ���� ��������
            then
            SetSmetaMaterial(Slash, ID_Material, Qnt)        //��� ����� ��
          else begin
          //������� �� �������� (������ ���� - ������� �������)
            for j := 0 to 999 do begin
              st := S.NSt(Sh.Cells[8, 8 + j].Value);
              if st = '' then
                Break;
            //������� ����� �����, ���� �������� ���� ��� ����� �� ���� ��� ��������� �� ������� ���������, ����� -1
              Slash := Slashes[j];
              if Slash = -1 then
                Continue;
            //������� � ������ ���������� �� ������
              if (Slash >= 1) and (Trim(S.NSt(Sh.Cells[i, 8 + j].Value)) <> '') then
                SetSmetaMaterial(Slash, ID_Material, Trim(S.NSt(Sh.Cells[i, 8 + j].Value)));
            end;
          end;
        end;
      except
      end;
    end;
    Excel.Workbooks[1].Close;
    Sh := Unassigned;
  end;

begin
  LoadMaterials;

  SetLength(OrList, 0);
  if IdOrder > 0 then begin
    //���� ����� ���������� �����, �� ������� ������ �� ����
    OrList := Q.QLoadToVarDynArray2('select id_order, org, num, year, path from uchet.to_orders where dt_end is null and dt_smeta is not null and extract(year from dt_smeta) <> 2000 and id_order = :id$i order by id_order', [IdOrder]);
  end
  else begin
    //���� ������� 0, �� ������� ������ ���� ������������� �������
    OrList := Q.QLoadToVarDynArray2('select id_order, org, num, year, path from uchet.to_orders where dt_end is null and dt_smeta is not null and extract(year from dt_smeta) <> 2000 order by id_order', []);
  end;
  //������� �� ����� �������
  for OrNum := 0 to High(OrList) do begin
    if not (A.InArray(OrList[OrNum][0], [4669, 4678])) then
      Continue;
    LogSt := LogSt + #13#10 + VarToStr(OrList[OrNum][0]) + '     ' + VarToStr(OrList[OrNum][1]) + VarToStr(OrList[OrNum][2]) + ' --- ';
    Sys.SaveTextToFile('r:\0', LogSt);
    if not DirectoryExists('r:\z\2023\' + OrList[OrNum][4] + '') then
      Continue;
    //������� ������ ������ �� ������ �� ��
    OrSlashUchet := Q.QLoadToVarDynArray2('select pos, name, qnt, 0 ' + 'from uchet.v_to_passport_items ' + 'where id_beg <= 999999 and id_beg_i <= 999999 and id_end >= 999999 and id_end_i >= 999999 and qnt > -1 and id_order = :id$i ' + 'order by pos', [OrList[OrNum, 0]]);
    OrSlashCnt := 0;
    for i := 0 to High(OrSlashUchet) do
      if OrSlashUchet[i][2] > 0 then
        inc(OrSlashCnt);
    LogSt := LogSt + ' ������ ' + IntToStr(OrSlashCnt) + ';  ';
    if not DirectoryExists('r:\z\2023\' + OrList[OrNum][4] + '\��') then begin
      LogSt := LogSt + '��� �������� ��';
      Continue;
    end
    else
      LogSt := LogSt + '��\';
    FilesArrDB := Q.QLoadToVarDynArray2('select id, filename, filedt, 0 from order_files where id_order = :id_order$i', [OrList[OrNum, 0]]);
//    OrdersPath:='r:\z\2023\';
    OrderPath := OrdersPath + '\' + OrList[OrNum][4] + '\';
//    OrderPathLength:=Length(OrdersPath) + Length(OrList[OrNum][4]) + 2;
    FilesArr := TDirectory.GetFiles(OrderPath + '��', '*.xls', TSearchOption.soAllDirectories);
    SetLength(FilesArr1, Length(FilesArr));
    //������� �� ���� ��������� ������
    for f1 := 0 to High(FilesArr) do begin
      FilesArr1[f1] := [-1, -1, -1, -1];
      i1 := pos(UpperCase('\��\'), UpperCase(FilesArr[f1]));
      i2 := pos(' ' + VarToStr(OrList[OrNum][2]), copy(FilesArr[f1], i1));
      //���, ������ �����, ����� ������ ��
      if pos(UpperCase('\��\������ �� �����'), UpperCase(FilesArr[f1])) > 0 then begin
        LogSt := LogSt + '����� ��, ';
        //������� � ������ - ��� ����� - �� ���, ������ ����� � ����� ������������ ������ � ������ ��������, ���� �����������, �������������� �����
        FilesArr1[f1] := [3, LowerCase(Copy(FilesArr[f1], Length(OrderPath) + 1)), FileDateToDateTime(FileAge(FilesArr[f1])), 0, 0];
      end
      else begin
        //���� ������������ � ������ � �����
        if ((pos(UpperCase('\��\�����'), UpperCase(FilesArr[f1])) > 0) or (pos(UpperCase('\��\������'), UpperCase(FilesArr[f1])) > 0)) and (i2 > 0) then begin
          i3 := i1 + i2 + Length(OrList[OrNum][2]);
          st := '';
          //���� ����� ����� ������� � �������������
          while FilesArr[f1][i3] in [' ', '_'] do
            inc(i3);
          //�������� �������� ����� �����
          while FilesArr[f1][i3] in ['0'..'9'] do begin
            st := st + FilesArr[f1][i3];
            inc(i3);
          end;
          if st <> '' then begin
            LogSt := LogSt + st + ', ';
            FilesArr1[f1] := [4, LowerCase(Copy(FilesArr[f1], Length(OrderPath) + 1)), FileDateToDateTime(FileAge(FilesArr[f1])), StrToInt(st), 0];
          end
          else begin
            FilesArr1[f1] := [1, LowerCase(Copy(FilesArr[f1], Length(OrderPath) + 1)), FileDateToDateTime(FileAge(FilesArr[f1])), 100000, 0];
          end;
        end;
      end;
      if FilesArr1[f1][3] = 100000 then
        LogSt := LogSt + ExtractFileName(FilesArr[f1]) + ', ';
//      if FilesArr1[f1][3] <> -1
//        then ProcessFile(FilesArr[f1]);
    end;
    //����� �� ���� ��������
    FilesChanged := False;
    //������� �� ������ � ��������� ���� �� ���������, � ������� ������ �� ���� � ������ FilesArrDb
    for i := 0 to High(FilesArr1) do begin
      for j := 0 to High(FilesArrDB) do begin
        FilesArr1[i][2] := Now;
        //���� ������ ��� �� ������ � ������� ������ � �����
        if FilesArrDB[j][3] = 0 then
          //���� ����� ���������
          if FilesArrDB[j][1] = FilesArr1[i][1] then
            if FilesArrDB[j][2] = FilesArr1[i][2]              //����� ����������� ���������
              then begin
              FilesArrDB[j][3] := 1;
              Break;
            end              //�� ���������, ������ ����� ��� ��������
            else begin
              FilesArrDB[j][2] := FilesArr1[i][2];
              FilesArrDB[j][3] := 2;
              FilesChanged := True;
              Break;
            end;
      end;
      //����� ��� � ������� �� ����, ����� ��� ����������
      if j > High(FilesArrDB) then begin
        FilesArrDB := FilesArrDB + [[0, FilesArr1[i][1], FilesArr1[i][2], 3]];
        FilesChanged := True;
      end;
    end;
    Sys.SaveTextToFile('r:\0', LogSt);

//FilesChanged:=True;

    if FilesChanged then begin
      Q.QBeginTrans;
      Res := 0;
      //������� �� ������� ������, � �� ��� ������� ���� ��������� �������� � ��
      for i := 0 to High(FilesArrDB) do begin
        if FilesArrDB[i][3] <> 1 then begin
          Res := Q.QIUD(VarToStr(S.Decode([FilesArrDB[i][3], 0, 'd', 2, 'u', 3, 'i']))[1], 'order_files', '', 'id$i;id_order$i;filename$s;filedt$d;filetype$i', [FilesArrDB[i][0], OrList[OrNum, 0], FilesArrDB[i][1], FilesArrDB[i][2], 0]);
          if Res = -1 then
            Break;
        end;
      end;
      Q.QCommitOrRollback(Res <> -1);

      for i := 0 to High(SmetaArrH) do begin
        SmetaArrH[i] := [];
        SmetaArr[1][i] := [];
        SmetaArr[2][i] := [];
      end;
      //�������� ������ ���� ���� �� ������
      a1 := Q.QLoadToVarDynArray2('select id, or_slash from order_smeta where id_order = :id_order$i', [OrList[OrNum, 0]]);
      for i := 0 to High(a1) do        //� ������ ���� �����, ������� �������� �� ����� ��, ������� �������� �� ���������
        SmetaArrH[S.VarToInt(a1[i][0])] := [a1[i][0], 0, 0];
      //�������� �� ������� ���������� ���� ��� ��������� �� ���� ������ �� ������� ������
      a1 := Q.QLoadToVarDynArray2('select m.id, s.or_slash, m.id_material, m.qnt, m.deleted from order_smeta_materials m, order_smeta s where m.id_smeta = s.id and s.id_order = :id_order$i', [OrList[OrNum, 0]]);
      //�������� ������ �������� ����
      //� ������ ����������� ����� ��� ����� ��, �� ������� ��� ���������, ��� ����� ��� ���
      //����� ����������� ������������ � �� � ������ ����� �� ������ �����, � ���� ������ ����� �� ����������� �������
      //� ������ ����������� �� �� ������ ���������
      for i := 0 to High(a1) do begin
        SetLength(SmetaArr[1][S.VarToInt(a1[i][1])], Length(SmetaArr[1][S.VarToInt(a1[i][1])]) + 1);
        SmetaArr[1][High(SmetaArr[1][S.VarToInt(a1[i][1])])] := [a1[i][0], a1[i][2], a1[i][3], a1[i][4], 0];
      end;
      SmetaArr[2] := SmetaArr[1];

      //���������� �����, ������������ �� �������� ��� �����
      for f1 := 0 to High(FilesArr1) do begin
        if FilesArr1[f1][0] <> -1 then
          ProcessFile(FilesArr[f1]);
      end;

    end;

  end;
  Excel := Unassigned;
end;

function TOrders.CreateAggregateEstimate(IdOrder: Integer; Mode: Integer): Boolean;
//������� ����� ����� �� ��������� ��� ������������� ���� � �������� ������,
//������������ � ���� ����� ������ ��, �������� �� �����
//Mode - ������� �������� �����
//0 - ��� ���������, ���� ��� ���� �� ���������� �����������, � ����� �� �����
//1 - ��� ������ - �� ���� � ������� � ����������� �� ����������
var
  i, j, k, p, slash: Integer;
  cntest: Integer;  //������������ ����� ������� � ������� ������,
  vor, voritems, vest, vres: TVarDynArray2;  //��������� ������, ����� � ������, ����� �� ����� � �����, �������� ������, ������ ������ �� ������� ��������� �����
  vslash: array of Integer;
  Book: TBook;
  BookTempl: TBook;
  Sheet0, Sheet1: TSheet;
  IsXML: Boolean;
  gr: string;
  st1, st2, fn: string;
  vexclitems: TVarDynArray;
  EstFiles: TStringDynArray;
const
  caGr = 0;
  caName = 1;
  caUnit = 2;
  caQntAll = 3;
  caComm = 4;
  caSlashQnt1 = 5;
  caSlashQnt = 6;
  caSlash = 7;
begin
  Result := False;
  vor := Q.QLoadToVarDynArray2('select ornum, customer, dt_otgr, dt_aggr_estimate, id_or_format_estimates from v_orders where id = :id_order$i', [IdOrder]);
  if Length(vor) = 0 then
    exit;
  if MyQuestionMessage(S.IIFStr(vor[0][3] = null, '�������', '��������') + ' ����� ����� ��� ������ ' + vor[0][0] + '?') <> mrYes then
    Exit;
  vres := [];
  vslash := [];
  cntest := -1;
  voritems := Q.QLoadToVarDynArray2('select id, pos, slash, qnt, nstd, itemname from v_order_items where id_order = :id_order$i and qnt <> 0 order by pos', [IdOrder]);
  vexclitems := [];
  EstFiles := [];
  for i := 0 to High(voritems) do begin
    //�������� �� ���� �������� ������
    vest := Q.QLoadToVarDynArray2('select id, groupname, name, unit, qnt1, qnt, comm from v_estimate where deleted = 0 and id_order_item = :id$i', [voritems[i][0]]);
    if Length(vest) = 0 then begin
      //���� ��� ����� - ��������� � ������ ������������� � ����������
      vexclitems := vexclitems + [voritems[i][1]];
      Continue;
    end;
    //������ ������� ����������� ���� � ������� ������� ������
    vslash := vslash + [i];
    inc(cntest);
    for j := 0 to High(vest) do begin
      //������� �� �����
      p := A.PosInArray(vest[j][2], vres, 1);
      if p = -1 then begin
        //�� ������� ������������ � ��� ����������� ����� ����� ����� - ������� ������
        SetLength(vres, Length(vres) + 1);
        p := High(vres);
        SetLength(vres[p], caSlashQnt + 1);
        //������� ��� ���������� ��� ������
        vres[p][caSlashQnt1] := VarArrayCreate([0, High(voritems)], varVariant);
        vres[p][caSlashQnt] := VarArrayCreate([0, High(voritems)], varVariant);
      end;
      vres[p][caGr] := vest[j][1];
      vres[p][caName] := vest[j][2];
      vres[p][caUnit] := vest[j][3];
      vres[p][caComm] := vest[j][6];
      vres[p][caQntAll] := S.NNum(vres[p][caQntAll]) + S.NNum(vest[j][5]);
      vres[p][caSlashQnt1][cntest] := vest[j][4];
      vres[p][caSlashQnt][cntest] := vest[j][5];
    end;
  end;
  if Length(vres) = 0 then begin
    MyInfoMessage('��� ������� ������ �� ������� �� ����� �����.'#13#10'����� ����� �� ������������!');
    Exit;
  end;
  //������������ �� ������������, ����� �� ������
  A.VarDynArray2Sort(vres, caName + 1);
  A.VarDynArray2Sort(vres, caGr + 1);
//  Sys.SaveArray2ToFile(vres, 'r:\smetaall');
//exit;
  //�������� ����� ����� �����
  try
    BookCreateAndLoad(Book, Module.GetPath_ReportsBase + '\������ �� ����� (���  ������).xls', IsXML);
    myxlsGetSheet(Book, '����� ���', Sheet0);
    myxlsGetSheet(Book, '��', Sheet1);
  except
    MyWarningMessage('�� ������� ��������� ������ ����� �����!');
    Exit;
  end;
  try
    Sheet0.WriteStr(0, 2, S.StringToPAnsiChar(VarToStr(vor[0][1])));
    Sheet1.WriteStr(1, 3, S.StringToPAnsiChar(VarToStr(vor[0][1])));
    Sheet0.WriteStr(1, 2, S.StringToPAnsiChar(VarToStr(vor[0][0])));
    Sheet1.WriteStr(2, 3, S.StringToPAnsiChar(VarToStr(vor[0][0])));
    Sheet1.writeStr(3, 3, S.StringToPAnsiChar(VarToStr(vor[0][2])));
    for k := 0 to cntest do begin
      Sheet1.WriteStr(7, 7 + k, S.StringToPAnsiChar(voritems[vslash[k]][2]));
    end;
    gr := '';
    j := 0;
    for i := 0 to High(vres) do begin
      if vres[i][caGr] <> gr then begin
        gr := vres[i][caGr];
        Sheet0.WriteStr(3 + j, 0, S.StringToPAnsiChar(gr));
        Sheet1.WriteStr(9 + j, 0, S.StringToPAnsiChar(gr));
        inc(j);
      end;
      Sheet0.WriteNum(3 + j, 0, i + 1);
      Sheet1.WriteNum(9 + j, 0, i + 1);
      Sheet0.WriteStr(3 + j, 1, S.StringToPAnsiChar(vres[i][caName]));
      Sheet1.WriteStr(9 + j, 1, S.StringToPAnsiChar(vres[i][caName]));
      Sheet0.WriteStr(3 + j, 3, S.StringToPAnsiChar(vres[i][caUnit]));
      Sheet1.WriteStr(9 + j, 3, S.StringToPAnsiChar(vres[i][caUnit]));
      Sheet0.WriteNum(3 + j, 6, vres[i][caQntAll]);
      Sheet0.WriteNum(3 + j, 4, vres[i][caQntAll]);
      Sheet1.WriteNum(9 + j, 5, vres[i][caQntAll]);
      Sheet1.WriteStr(9 + j, 6, S.StringToPAnsiChar(VartoStr(vres[i][caComm])));
      for k := 0 to cntest do begin
        if S.NNum(vres[i][caSlashQnt][k]) <> 0 then
          Sheet1.WriteNum(9 + j, 7 + k, vres[i][caSlashQnt][k]);
      end;
      inc(j);
    end;
    Book.save(S.StringToPAnsiChar(Sys.GetWinTemp + '\������ �� ����� (���  ������).xls'));
  except
    MyWarningMessage('������ �������� ����� �����!');
    Exit;
  end;
  Sheet0.free;
  Sheet1.free;
  Book.Free;
  //�������� ������ ���� �� ������������� �������� ��� �� ��
  if vor[0][4] = 11 then  //   id_or_format_estimates = 11 //��.��
    for slash := 0 to cntest do begin
    //������ ��� ������������� ������
      if voritems[vslash[slash]][4] = null then
        Continue;
      try
        BookCreateAndLoad(Book, Module.GetPath_ReportsBase + '\����� ��� �����������.xls', IsXML);
        myxlsGetSheet(Book, 0, Sheet0);
      except
        MyWarningMessage('�� ������� ��������� ������ ����� ��� �����������!');
        Exit;
      end;
      try
        Sheet0.WriteStr(0, 2, S.StringToPAnsiChar(VarToStr(vor[0][1])));
        Sheet0.WriteStr(1, 2, S.StringToPAnsiChar(VarToStr(voritems[slash][2] + ' ' + voritems[slash][5])));
        Sheet0.WriteStr(0, 6, S.StringToPAnsiChar(VarToStr(voritems[slash][3])));
        gr := '';
        j := 0;
        for i := 0 to High(vres) do begin
          if S.NNum(vres[i][caSlashQnt][slash]) = 0 then
            Continue;
          if vres[i][caGr] <> gr then begin
            gr := vres[i][caGr];
            Sheet0.WriteStr(3 + j, 0, S.StringToPAnsiChar(gr));
            inc(j);
          end;
          Sheet0.WriteNum(3 + j, 0, i + 1);
          Sheet0.WriteStr(3 + j, 1, S.StringToPAnsiChar(vres[i][caName]));
          Sheet0.WriteStr(3 + j, 3, S.StringToPAnsiChar(vres[i][caUnit]));
          Sheet0.WriteNum(3 + j, 6, vres[i][caSlashQnt][slash]);
          Sheet0.WriteNum(3 + j, 4, vres[i][caSlashQnt1][slash]);
          inc(j);
        end;
        fn := Sys.GetWinTemp + '\����� ' + voritems[slash][2] + '.xls';
        Book.save(S.StringToPAnsiChar(fn));
        EstFiles := EstFiles + [fn];
      except
        MyWarningMessage('������ �������� ����� �� �����!');
        Exit;
      end;
      Sheet0.free;
      Book.Free;
    end;
  //�������� � ������� ������� ���� �������� ����� �����
  if Mode = 0 then
    Q.QExecSql('update orders set dt_aggr_estimate = :dt$d where id = :id$i', [Date, IdOrder])
  else
    Q.QExecSql('update orders set dt_complete_estimate = :dt$d where id = :id$i', [Date, IdOrder]);
  //���� ��� ���������, � �� ����� ��������, �������� �����������
  if High(vexclitems) = High(voritems) then
    st1 := '����� ����� �� ���� �������� ������ (' + IntToStr(Length(voritems)) + ')'
  else begin
    st1 := '����� ����� �� ' + IntToStr(cntest + 1) + ' ������' + S.GetEnding(cntest + 1, '�', '��', '��') + ' �� ' + IntToStr(Length(voritems)) + #13#10 + S.IIFStr(Length(vexclitems) = 0, '', '(����� ' + A.Implode(vexclitems, ', ') + ')') + #13#10#13#10;
  end;
  st2 := '';
  if (Mode = 0) and (vor[0][3] <> null) then begin
    FrmXDedtMemo.ShowDialog(nil, 'AttachAggregateEstimate', '����������� � ����� �����', vor[0][0], st2);
  end;
  TaskForSendEstimate(IdOrder, null, Sys.GetWinTemp + '\������ �� ����� (���  ������).xls', EstFiles, S.IIf(Mode = 0, True, False), st1 + st2);
  MyInfoMessage('��� ������ ' + vor[0][0] + ' ������������ ' + st1);
  Result := True;
end;

procedure TOrders.TaskForSendEstimate(IdOrder, IdOrItem: Variant; FileName: string; AddFiles: TStringDynArray; MailTo: Boolean = True; TextToSend: string = '');
//������ ��� ���������� �������� �� ������������ �����
//(���� �����, ���� �� ��������)
//���� �������� IdOrItem, �� ��������������� ��� ��� ����� �� �������, ����� ����� �����
//� FileName ��� ����� �����, ������� ���, ����� ������������ �� �����, �
//AddFiles ���������� �������������� �����, ������� �������� � ����� �� (������ ��� �� ��)
//����� ���������� MailTo �� ������������ ������ � ������� � ������, ����� ������ ���������� ����� � ����� ������
var
  st, st1, filesadd, filesdelete, TaskDir, Slashes, Addr, Subj: string;
  i, j, RecNo: Integer;
  OrderNum, Slash, OrderPath: string;
  Dt_Beg: TDateTime;
  va1, va2, vatask: TVarDynArray2;
  FilesToSend, FilesToCopy: string;
  InArchive: Variant;
begin
  va1 := Q.QLoadToVarDynArray2('select ornum, path, dt_beg, in_archive from v_orders where id = :id$i', [IdOrder]);
  OrderNum := va1[0][0];
  OrderPath := va1[0][1];
  Dt_Beg := va1[0][2];
  InArchive := va1[0][3];
  if IdOrItem <> null then begin
    va2 := Q.QLoadToVarDynArray2('select slash from v_order_items where id = :id$i', [IdOrItem]);
    Slash := va2[0][0];
  end;
  FilesToSend := S.IIf(IdOrItem = null, '������ �� ����� ' + OrderNum, '����� ' + Slash) + ExtractFileExt(FileName);
  Addr := S.NSt(Q.QSelectOneRow('select addresses from adm_mailing where id = :i$i', [3])[0]);
  if IdOrItem <> null then
    Subj := GetSubject('�����', '', null, IdOrItem)
  else
    Subj := GetSubject('����� �����', '', IdOrder, null);
  FilesToCopy := '';
  for i := 0 to High(AddFiles) do
    S.ConcatStP(FilesToCopy, ExtractFileName(AddFiles[i]), #13#10);
  vatask := [
    ['directory', OrderPath],
    ['year', YearOf(Dt_Beg)],
    ['in_archive', VarToStr(InArchive)],
    ['files-to-copy', FilesToSend + S.IIFStr(FilesToCopy <> '', #13#10 + FilesToCopy, '')]
  ];
  if MailTo then
    vatask := vatask + [
      ['subject', Subj],
      ['to', Addr],
      ['body', Subj + #13#10 + TextToSend],
      ['files-to-send', FilesToSend]
    ];
  TaskDir := Tasks.CreateTaskRoot(mytskopToEstimates, vatask, False, False);
  //��������� �������� �������� (�����, ������ ��) �� ���������� ����� � ������� ������
  CopyFile(pWideChar(FileName), pWideChar(Module.GetPath_Tasks + '\' + TaskDir + '\Files\' + FilesToSend), True);
  //��������� � ������� ������ �����, ������� ���� ����������� � �������� ������� ����������
  for i := 0 to High(AddFiles) do begin
    CopyFile(pWideChar(AddFiles[i]), pWideChar(Module.GetPath_Tasks + '\' + TaskDir + '\Files\' + ExtractFileName(AddFiles[i])), True);
  end;
  //�������� ������ �� ����������
  Tasks.FinalizeTaskDir(Module.GetPath_Tasks + '\' + TaskDir);
end;

function TOrders.TaskForSendSnDocuments(IdOrder, IdOrItem: Variant): Boolean;
var
  st, st1, filesadd, filesdelete, TaskDir, Slashes, Addr, Subj: string;
  i, j, RecNo: Integer;
  OrderNum, Slash, OrderPath: string;
  Dt_Beg: TDateTime;
  va1, va2: TVarDynArray2;
  FilesToSend, BigFiles, FileName: string;
  AllSize: Integer;
  fs: TFileStream;
  InArchive: Variant;
const
  MaxSize = 20971520; //20*1024*1024
begin
//  va1:=QLoadToVarDynArray2('select slash, id_order from v_order_items where id = :id$i', IdOrItem);
  va2 := Q.QLoadToVarDynArray2('select ornum, path, dt_beg, in_archive from v_orders where id = :id$i', [IdOrder]);
  //������ ������, ����� ���������
  MyData.OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist];
  MyData.OpenDialog1.Filter := '';
  //����� �� ������ � ������
  if (not MyData.OpenDialog1.Execute) or (MyData.OpenDialog1.Files.Count = 0) then
    Exit;
  FilesToSend := '';
  BigFiles := '';
  AllSize := 0;
  FileName := '';
  try
  for i := 0 to MyData.OpenDialog1.Files.Count - 1 do begin
    S.ConcatStP(FilesToSend, ExtractFileName(MyData.OpenDialog1.Files[i]), #13#10);
    fs := TFileStream.Create(MyData.OpenDialog1.Files[i], fmOpenRead);
    if fs.Size > MaxSize then
      S.ConcatStP(BigFiles, ExtractFileName(MyData.OpenDialog1.Files[i]), #13#10);
    AllSize := AllSize + fs.Size;
    fs.Free;
  end;
  except
    if fileName <> '' then
      MyWarningMessage(
        '��������� ������!'#13#10+
        '��������� ���� ������ � �� ����� ���� ����������:'#13#10+
        FileName+
        ''#13#10+
        '������� �� ����������� ��������!'#13#10
      )
    else
      MyWarningMessage('��������� ������ ��� ����������� ������!');
    Exit;
  end;
  if BigFiles <> '' then begin
    MyWarningMessage('��������� ����� �� ����� ���� ����������, ��� ��� ��������� �� ��� ������� �������:'#13#10#13#10 + BigFiles);
    Exit;
  end;
  if AllSize > MaxSize then begin
    MyWarningMessage('��������� ����� �� ����� ���� ����������, ��� ��� �� ��������� ������ ��������� ' + IntToStr(Round(MaxSize / 1024 / 1024)) + '��.');
    Exit;
  end;
  try
    Addr := S.NSt(Q.QSelectOneRow('select addresses from adm_mailing where id = :i$i', [3])[0]);
    Subj := GetSubject('��������� ��� ���������', '', IdOrder, null);
    TaskDir := Tasks.CreateTaskRoot(mytskopToSnDocuments, [
      ['directory', va2[0][1]],
      ['year', YearOf(va2[0][2])],
      ['in_archive', VarToStr(va2[0][3])],
      ['subject', Subj],
      ['to', Addr],
      ['body', Subj + #13#10#13#10 + FilesToSend],
      ['files-to-send', FilesToSend],
      ['files-to-copy', FilesToSend]]
      , False, False
    );
    //��������� ����� � ������� ������
    for i := 0 to MyData.OpenDialog1.Files.Count - 1 do begin
      S.ConcatStP(FilesToSend, ExtractFileName(MyData.OpenDialog1.Files[i]), #13#10);
      CopyFile(pWideChar(MyData.OpenDialog1.Files[i]), pWideChar(Module.GetPath_Tasks + '\' + TaskDir + '\Files\' + ExtractFileName(MyData.OpenDialog1.Files[i])), True);
    end;
    //�������� ������ �� ����������
    Tasks.FinalizeTaskDir(Module.GetPath_Tasks + '\' + TaskDir);
      MyInfoMessage('������ ���������� �� ������.');
    Result := True;
  except
    MyWarningMessage('��������� ������ ��� ����������� ������!');
  end;
end;

function TOrders.GetSubject(Subject: string; OrderName: string; IdOrder, IdOrderItem: Variant): string;
var
  Area: string;
  va, va1: TVarDynArray2;
begin
  Result := '';
  if OrderName = '' then begin
    if IdOrderItem <> null then
      va := Q.QLoadToVarDynArray2('select slash, customer, project, area from v_order_items where id = :id$i', [IdOrderItem])
    else
      va := Q.QLoadToVarDynArray2('select ornum, customer, project, area from v_orders where id = :id$i', [IdOrder]);
    if Length(va) = 0 then
      Exit;
    Area:= '';
    if va[0][3] > 0 then
      Area:= S.NSt(Q.QSelectOneRow('select name from ref_production_areas where id = :id$i', [va[0][3]])[0]);
    OrderName := va[0][0] + ' ' + S.IIf(va[0][1] = null, '������������', va[0][1]) + ' ' + va[0][2];
  end;
  Result := Subject + S.IfEl(Area, '',  ' (' + Area + ')')  + ' - ' + OrderName;
end;

function TOrders.TaskForSendThnDocuments(IdOrItem: Variant): Boolean;
var
  st, st1, filesadd, filesdelete, TaskDir, Slashes, Addr, Subj, Dir: string;
  i, j, RecNo: Integer;
  OrderNum, Slash, OrderPath: string;
  Dt_Beg: TDateTime;
  va1, va2: TVarDynArray2;
  sa: TStringDynArray;
  FilesToSend, BigFiles: string;
  AllSize: Integer;
  fs: TFileStream;
  FilesSize, FilesCount: Integer;
  FileName: string;
  InArchive: Variant;
const
  SELDIRHELP = 1000;
  MaxFilesSize = 300 * 1024 * 1024;
  MaxFilesCount = 50;
  MaxFilesSize_ = 1000 * 1024 * 1024;
  MaxFilesCount_ = 200;
begin
  Result := False;
  Dir := '';

  {if Win32MajorVersion >= 6 then
  with TFileOpenDialog.Create(nil) do
    try
      Title := 'Select Directory';
      Options := [fdoPickFolders, fdoPathMustExist, fdoForceFileSystem]; // YMMV
      OkButtonLabel := 'Select';
  //    DefaultFolder := FDir;
  //    FileName := FDir;
      if Execute then
        Dir:=FileName;
    finally
      Free;
    end
  else}
  va1 := Q.QLoadToVarDynArray2('select pos, slash, path, dt_beg, dt_end, fullitemname, id_thn, qnt, dt_thn in_archive from v_order_items where id = :id$i', [IdOrItem]);
  if (va1[0][6] = null) or (va1[0][6] = -100) or (S.NNum(va1[0][7]) = 0) then
    Exit;
  if DirectoryExists(LastThnDocsDirectory) then
    Dir := LastThnDocsDirectory;
  if not SelectDirectory('�������� �����', ''{ExtractFileDrive(Dir)}, Dir, [])   //sdNewFolder  sdNewUI
    then
    Exit;
//  i:=Max(Pos('\\', Dir), Pos(':\', Dir));
//  i:=Pos('\', Copy(Dir, i + 2));
  LastThnDocsDirectory := Dir;
{  i:=Pos('\', Copy(Dir, Length(TDirectory.GetDirectoryRoot(Dir)) + 1));
  if i = 0 then begin
    MyWarningMessage('������ ������� ������� �������� ������!');
    Exit;
  end;}
  if Dir = TDirectory.GetDirectoryRoot(Dir) then begin
    MyWarningMessage('������ ������� �������� �����!');
    Exit;
  end;
  FilesSize := 0;
  FilesCount := 0;
  FileName:= '';
  try
    for FileName in TDirectory.GetFileSystemEntries(Dir, TSearchOption.soAllDirectories, nil) do begin
      if DirectoryExists(FileName) then
        Continue;
      fs := TFileStream.Create(FileName, fmOpenRead);   //������ ������, ���� ���� ������!
      FilesSize := FilesSize + fs.Size;
      fs.Free;
      if FilesSize > MaxFilesSize then
        Break;
      if FilesCount > MaxFilesCount then
        Break;
      Inc(FilesCount);
    end;
  except
    if fileName <> '' then
      MyWarningMessage(
        '��������� ������!'#13#10+
        '��������� ���� ������ � �� ����� ���� ����������:'#13#10+
        FileName+
        ''#13#10+
        '������� �� ����������� ��������!'#13#10
      )
    else
      MyWarningMessage('��������� ������ ��� ����������� ������!');
    Exit;
  end;
  if (FilesSize > MaxFilesSize_) or (FilesCount > MaxFilesCount_) then begin
    MyWarningMessage('����� ������ ������� �������! ����� �� ����� ���������!');
    Exit;
  end
  else if (FilesSize > MaxFilesSize) or (FilesCount > MaxFilesCount) then begin
    if MyQuestionMessage('����� ������ ������� �������!'#13#10 + '(' + FloatToStr(RoundTo(FilesSize / 1024 / 1024, -1)) + 'Mb � ' + IntToStr(FilesCount) + ' ����' + S.GetEnding(FilesCount, '�', '��', '��') + ')'#13#10 + '��� ����� ����������?') <> mrYes then
      Exit;
  end
  else begin
    if MyQuestionMessage('���������� ������������ ���������� � �������?'#13#10 + '(' + FloatToStr(RoundTo(FilesSize / 1024 / 1024, -1)) + 'Mb � ' + IntToStr(FilesCount) + ' ����' + S.GetEnding(FilesCount, '�', '��', '��') + ')') <> mrYes then
      Exit;
  end;
//  TDirectory.Copy(Dir, 'R:\111');
  try
// pos, slash, path, dt_beg, dt_end, fullname
    Addr := S.NSt(Q.QSelectOneRow('select addresses from adm_mailing where id = :i$i', [5])[0]);
    Subj := GetSubject('��������� ��������� ���', '', null, IdOrItem);
    TaskDir := Tasks.CreateTaskRoot(mytskopToThnDocuments, [
      ['directory', va1[0][2]],
      ['year', YearOf(va1[0][3])],
      ['in_archive', VarToStr(va1[0][8])],
      ['slash', RightStr('0000' + IntToStr(va1[0][0]), 3) + ' ' + S.CorrectFileName(va1[0][5])],
      ['subject', Subj],
      ['to', Addr],
      ['body', Subj]
      ], False, False
    );
  //��������� ����� � ������� ������
    TDirectory.Copy(Dir, Module.GetPath_Tasks + '\' + TaskDir + '\FOLDER');
  //�������� ������ �� ����������
    Tasks.FinalizeTaskDir(Module.GetPath_Tasks + '\' + TaskDir);
  //���� ��� �� ���� ���� �������� ��������� ��� ��� �����, �� �������� ��� ������� ����
    if va1[0][8] = null then
      Q.QExecSql('update order_items set dt_thn = :dt$d where id = :id$i', [Date, IdOrItem]);
    MyInfoMessage('������ ���������� �� ������.');
    Result := True;
  except
    MyWarningMessage('��������� ������ ��� ����������� ������!');
  end;
end;

function TOrders.OrderItemsToDevel(IdOrder, IdOrItem: Variant): Boolean;
var
  i, j, k: Integer;
  OrItems: TVardynArray2;
  DevItems: TVarDynArray;
begin
  OrItems := [];
  if IdOrItem <> null then begin
    OrItems := Q.QLoadToVarDynArray2('select 1, id, slash, fullitemname, dt_beg, customer, project, kns from v_order_items where id = :id$i', [IdOrItem]);
  end
  else if IdOrder <> null then begin
    OrItems := Q.QLoadToVarDynArray2('select 1, id, slash, fullitemname, dt_beg, customer, project, kns ' + 'from v_order_items ' + 'where id_order = :id$i and id_kns <> -100 and qnt > 0', [IdOrder]);
  end;
  if Length(OrItems) = 0 then begin
    MyInfoMessage('��� ������� ��� �������� � ������ ����������.');
    Exit;
  end;
  DevItems := A.VarDynArray2ColToVD1(Q.QLoadToVarDynArray2('select slash from j_development where id_develtype = 5 and slash is not null', []), 0);
  k := 0;
  for i := 0 to High(OrItems) do
    if A.InArray(OrItems[i][2], DevItems) then
      OrItems[i][0] := 0
    else
      inc(k);
  if k = 0 then begin
    MyInfoMessage('��� ������� ��� �������� � ������ ����������.' + S.IIFStr(High(OrItems) - k + 1 = 0, '', #13#10'(' + IntToStr(High(OrItems) - k + 1) + ' ��� ������' + S.GetEnding(High(OrItems) - k + 1, '�', '�', '�') + '.)'));
    Exit;
  end;
  if MyQuestionMessage('������ � ������ ���������� ' + inttostr(k) + ' �����' + S.GetEnding(k, '�', '�', '��') + '?') <> mrYes then
    Exit;
  for i := 0 to High(OrItems) do
    if OrItems[i][0] = 1 then begin
      Q.QIUD('i', 'j_development', '', 'id$i;id_develtype$i;slash$s;name$s;project$s;dt_beg$d;id_status$i', [-1, 5, OrItems[i][2], OrItems[i][3], OrItems[i][5] + ' [' + OrItems[i][6] + ']', OrItems[i][4], 1]);
    end;
  MyInfoMessage('������!'#13#10'�������� ������ ����������.');
end;

function TOrders.FinalizeOrderM(IdOrder: Variant): Integer;
//����������� ������� ���������� ������ ����������
//��� ���� ��������� ����� ������� � ��� ������, � ����� �����������
//����������:
// -2 = ������, -1 = ����� �� ����� ���� ��������, 0 = ����� ��� ��������, 1 = ����� ������� ��������
var
  va2, va3: TVarDynArray;
  Mode: Boolean;
  IsRecl: Boolean;
begin
  Result := -2;
  if not User.Roles([], [rOr_D_Order_SetCompletedM, rOr_D_Order_SetCompletedMA]) then
    Exit;
  va2 := Q.QSelectOneRow('select id, prefix, ornum, dt_beg, dt_end, dt_to_sgp, dt_from_sgp, dt_upd, dt_end_manager, dt_montage_beg, id_type, id_manager from orders where id = :id$i', [IdOrder]);
  //�������� ������ ������� �������� ��������� ������ �����������, ���������� ������,
  //��� � �������������� ������, ��� � ������� �������������� ������
  if (User.GetId <> va2[11]) and not User.IsDataEditor and not User.Role(rOr_D_Order_SetCompletedMA) then
    Exit;
  //������ ������ ������ � ��� ��������� ������
  //����� ������ � �������, '�','�','�' (���������), � '�' (���� �������� ���������)
  //� �� ���������� ����������� ������ ������ �������
  if (va2[0] = null) or (va2[4] <> null) or not (A.InArray(va2[1], ['�', '�', '�']) or ((va2[1] = '�') and (va2[10] = 2))) then
    Exit;
  //�����
  Mode := va2[8] = null;
  Result := -1;
  if va2[10] <> 2 then begin
    //��� �������� ������ ��� ����� �������
    //���������� ������������� ��� ��������
    //!������ ��� ��������� ������ ���� �����������, ��������, ���� ���� �� ������
    if Mode and (va2[6] = null) then begin
      MyWarningMessage('���� ����� ��� �� ��������!'#13#10'���������� ����������!');
      Exit;
    end;
    //��� ���, �� ���� ���������� �����������, �� ����� �����
    //�� ��� ���������� ��� �� ���������
    if Mode and (va2[7] = null) and (va2[10] <> 2) then begin
      MyWarningMessage('�� ����� ������ ��� �� ������� ���!'#13#10'���������� ����������!');
      Exit;
    end;
    //��������������, ���� �� ������� ������
    if Mode and (va2[9] <> null) and (va2[10] <> 2) then begin
      va3 := Q.QSelectOneRow('select dt_end from or_montage where id = :id$i', [IdOrder]);
      if (va3[0] = null) then begin
        MyWarningMessage('������ ����� ������ ��� �� ��������!'#13#10'���������� ����������!');
        Exit;
      end;
    end;
  end;
  Result := -2;
  if MyQuestionMessage(S.IIFStr(Mode, '���������', '�����') + ' ������� ���������� ������ ����������?') <> mrYes then
    Exit;
  //������ ������� ����������
  if Q.QExecSql('update orders set dt_end_manager = :dt_end$d where id = :id$i', [S.IIf(Mode, Date, null), IdOrder]) = -1 then
    Exit;
  //������������� ��������� ��������� �����
  if Mode then
    FinalizeOrder(IdOrder, myOrFinalizeManager, 1, True);
  Result := 1;
end;

function TOrders.FinalizeOrder(IdOrder: Variant; OpMode: Integer; Mode: Integer = 1; Silent: Boolean = True): Integer;
//��������� (��� ������� ������� ����������) ��������� �����
//OpMode - ��� ����, ��� ����� ������� �����������
//���� = 0 - ������� ����������, 1 ���������, 2 �����������
//����������:
// -2 = ������, -1 = ����� �� ����� ���� ��������, 0 = ����� ��� ��������, 1 = ����� ������� ��������
//� ������ �� ����������� ������, ��������� ����� ������������ �� ��������� �������
var
  va, va2: TVarDynArray;
  to_complete: Boolean;
  res: Integer;
  dtp: TDateTime;
  err: TVarDynArray;
  st: string;
  IsRecl: Boolean;
begin
  Result := -2;
  to_complete := False;
  va2 := Q.QSelectOneRow('select ' + 'o.id, o.prefix, o.ornum, o.dt_beg, o.dt_end, o.dt_to_sgp, o.dt_from_sgp, o.dt_upd, ' +  //�� 7
    'o.dt_end_manager, o.dt_end_copy, o.cost, o.pay, o.dt_montage_end, m.dt_end as dt_montage_end_fact, ' +  //�� 8 �� 13
    'o.dt_cancel, o.id_type ' + 'from ' + 'orders o, or_montage m ' + 'where ' + 'o.id = :id$i and m.id(+) = o.id', [IdOrder]);  //�� 14          id_type 2-���������� 3-�����������
  if va2[0] = null then
    Exit;
  //���� ��� �������� ������� �������� (��������, ��������� ��� � ��) -
  //������ ��� ������� ����������, � ����� �� ��� ������������ (���� ��� ��������, � �� ����� ����� ��� ����� ������� ������ � ���������������)
  //����� ��� ��� ���� ���� ����� ���������� ����������, � ������ ����������� ����� ����� ������ ����� �������
  //�� ����� ��������� ������������ ���� ���������� ��� ��������, �� ����� �����?
  EncodeDate(2024, 01, 01);
  dtp := EncodeDate(2040, 01, 01);
  //��� ����������
  IsRecl := (va2[15] = 2);
  if not (Silent or User.IsDeveloper) then
    dtp := va2[3];
  Result := 0;
  //���� �������������� �������, �� ������� ���������� �����
  if Mode = 2 then
    Mode := S.IIf(va2[4] = null, 1, 0);
  //����� ������ �������� ������
  if Mode = 0 then begin
    if va2[4] = null then
      Exit; //��� ������� ����������
    Result := -2;
    if (not User.Role(rOr_D_Order_SetUnCompleted)) and (not Silent) then
      Exit;
    if not Silent then
      if MyQuestionMessage('����� ������� �������� ������?') <> mrYes then
        Exit;
    if Q.QExecSql('update orders set dt_end = null, dt_end_copy = dt_end where id = :id$i', [IdOrder]) = -1 then
      Exit;
    Q.QLog('FinalizeOrderCancel', VartoStr(va2[2]) + ' ' + User.GetName + '  [�������� ����� �������]');
    Result := 1;
    Exit;
  end;
  //����� �������� ������
  if va2[4] <> null then
    Exit;  //��� ��������
  if va2[14] <> null then begin
    //����� ������� - ����������� ������������� ��� ������ ������
    to_complete := True;
  end
  else if va2[1] = '�' then begin
    //��������� ������ �� ���
    to_complete := (va2[5] <> null) or ((dtp < fDtToSgpMin) and (not Silent));
    err := err + ['������ ��� �� ������ �� ��� � ������ ������.'];
  end
  else if va2[1] = '�' then begin
    //����� ������� ����� ����� ������ (�� ����� ��� ����������), � ��������� �������� � ���
    to_complete := ((va2[10] = va2[11]) or IsRecl) and ((va2[6] <> null) or ((dtp < fDtFromSgpMin) and (not Silent)));
    if (va2[10] <> va2[11]) and not IsRecl then
      err := err + ['����� ��� �� �������.'];
    if ((va2[6] <> null) or ((dtp < fDtFromSgpMin) and (not Silent))) then
      err := err + ['����� ��� �� ��������.'];
  end
  else if A.InArray(va2[1], ['�', '�', '�']) then begin
    //��������� ���, ��������� �������� � ���, ������������ ���� ���� ������, � ���������� ���������� ����������
    to_complete := True;
    if not IsRecl then begin
      if not ((va2[7] <> null) or ((dtp < fDtUpdMin) and (not Silent))) then begin
        err := err + ['�� ������ ��� �� ������� ���.'];
        to_complete := False;
      end;
      if not ((va2[6] <> null) or ((dtp < fDtFromSgpMin) and (not Silent))) then begin
        err := err + ['����� ��� �� ��������.'];
        to_complete := False;
      end;
      if not ((va2[12] = null) or (va2[13] <> null) or ((dtp < fDtMontageMin) and (not Silent))) then begin
        err := err + ['����� ��� �� �����������.'];
        to_complete := False;
      end;
    end;
    if not ((va2[8] <> null) or ((dtp < ftDtManagerMin) and (not Silent))) then begin
      err := err + ['����� ��� �� �������� ����������.'];
      to_complete := False;
    end;

{    to_complete:=
      ((va2[7] <> null)or((dtp < fDtUpdMin))and(not Silent))and
      ((va2[6] <> null)or((dtp < fDtFromSgpMin)and(not Silent)))and
      ((va2[13] <> null)or(va2[12] = null)or((dtp < fDtMontageMin)and(not Silent)))and
      ((va2[8] <> null)or((dtp < ftDtManagerMin)and(not Silent)));
      }
  end;
  Result := -1;
  if (not User.Role(rOr_D_Order_SetCompleted)) and (not Silent) then
    Exit;
  if (not to_complete) and (not Silent) then
    MyWarningMessage('���� ����� ��� �� ����� ���� ������!'#13#10#13#10 + A.Implode(err, #13#10));
  //����������� ������ ����� ������� ����� ������� (�� � ���������������!)
  if not (Silent) and (User.IsDeveloper or User.IsDataEditor {or (va2[3] < EncodeDate(2024,05,15))}) then
    to_complete := True;
  if not to_complete then
    Exit; //������ ���������
  Result := -2;
  if not Silent then begin
    //���� �� ���������� �����, �� ������� ������� ��.
    //��� ������ ���� - ������� �� �������
    if (va2[9] = null) then
      if MyQuestionMessage('������� �����?') <> mrYes then
        Exit;
    if (va2[9] <> null) then begin
      //���� ������ ����, ���������� ������ � ����� ��������. ��� �������� �� ������ �����������, �� ���� ��������, ��� ������
      res := myMessageDlg('������� ����� �� ���� "' + DateToStr(va2[9]) + '"?', mtConfirmation, [mbYes, mbNo, mbCancel], '��;����;������');
      if res = mrNo then begin
        //�� ������ ���� �������� ����
        if TFrmBasicInput.ShowDialog(FrmMain, '', [], fAdd, '~�������� ������������', 10, 90,
          [[cntDTEdit, 80, '���� ��������', S.DateTimeToIntStr(va2[3]) + ':' + S.DateTimeToIntStr(Date)]],
          [va2[9]], va, [['']], nil) < 0 then
          Exit;
//!!!!!//
//      if Dlg_BasicInput.ShowDialog2(nil, '', 180, 90, fAdd, [[cntDTEdit, 80, '���� ��������', S.DateTimeToIntStr(va2[3]) + ':' + S.DateTimeToIntStr(Date)]], [va2[9]], va, [['']], nil) < 0 then
//        Exit;
        va2[9] := va[0];
      end;
      if not ((res = mrNo) or (res = mrYes)) then
        Exit;
    end;
  end;
//MyInfoMessage(DateToStr(S.IIf(va2[9] = null, Date, va2[9])));
//    Exit;
  if Q.QExecSql('update orders set dt_end = :dt_end$d where id = :id$i', [S.IIf(va2[9] = null, Date, va2[9]), IdOrder]) = -1 then
    Exit;
  case OpMode of
    myOrFinalizePay:
      st := '������ ������';
    myOrFinalizeFromSgp:
      st := '��������';
    myOrFinalizeToSgp:
      st := '������ �� ���';
    myOrFinalizeManager:
      st := '�������� ����������';
    myOrFinalizeManual:
      st := '������ �������';
    myOrFinalizeCancel:
      st := '������ ��������';
    myOrFinalizeUpd:
      st := '������ ���';
    myOrFinalizeMontage:
      st := '�����������';
  end;
  Q.QLog('FinalizeOrder', VartoStr(va2[2]) + ' ' + User.GetName + '  [' + st + ']');
  Result := 1;
end;

procedure TOrders.SetOrderProperty_SyncWithITM;
//������� ������������������� ��� ������, ������� ��� � �� ���
var
  i, j, c1, c2: Integer;
  va1, va2: TVarDynArray2;
begin
  c1:=Q.QSelectOneRow('select count(*) from dv.zakaz', [])[0];
  c2:=Q.QSelectOneRow('select count(*) from orders', [])[0];
  if MyQuestionMessage(
    '� ��� ������� ' + IntToStr(c1) + '��., � � ����� ' + IntToStr(c2) + '��.'#13#10 +
    '���������� ������� ������������� �������� � ��� ������ �� �� ������� � ���� ���?'
  ) <> mrYes then Exit;
  va1:=Q.QLoadToVarDynArray2('select id_zakaz from dv.zakaz', []);
  va2:=Q.QLoadToVarDynArray2('select id, nvl(id_itm, 0) from orders', []);
  //Q.QExecSql('update orders set sync_with_itm = 0 where not (nvl(id_itm, 0) in (' + A.Implode(va, ',') + ')', []); //��� ������, �������� � ������������ 1000��
  for i:=0 to High(va2) do
    if A.PosInArray(va2[i][1], va1, 0) = -1
      then Q.QExecSql('update orders set sync_with_itm = 0 where id = :id$i', [va2[i][0]]);
  MyInfoMessage('������!');
end;

function TOrders.RenameNomenclGlobal(Id, IdItm: Variant): Boolean;
//�������������� �������������� ������� � ����� ����� � ���
//�� ������ ������ �������� �������� ���� ������������ � ���
//���������������, ������ ���� ��� ������������ ���������, � ���� ������� ������������
//��� �� � ���, �� � �����
var
  va1, va2: TVarDynArray;
  vau, vai: TVarDynArray;
begin
  Result:= False;
  if IdItm = null then Exit;
  vai:= Q.QSelectOneRow('select name, id_group, id_nomencltype from dv.nomenclatura where id_nomencl = :id$i', [IdItm]);
  if S.NSt(vai[0]) = '' then Exit;
  if (vai[2]) <> 0 then begin
    MyWarningMessage('��� ������������ �������� ��������, �� ������ �������������!');
    Exit;
  end;
  va1:= [vai[0], vai[0]];
  if TFrmBasicInput.ShowDialog(
    FrmMain, '', [], fEdit, '~�������� ������������', 780, 160,
    [
      [cntEdit, '������� ������������', '1:400:T', 600],
      [cntEdit, '����� ������������', '1:400:T', 600]
    ],
    va1,
    va2,
    [['������� ����� ������������ ������������.'#13#10+
      '������������ ����� �������� �� ���� ��������, ��� � ���, ��� � � �����.'
    ]],
    nil
  ) <= 0
  then Exit;
  if Q.QSelectOneRow('select count(*) from dv.nomenclatura where name = :name$s', [va2[1]])[0] <> 0 then begin
    MyWarningMessage('��������� ������������ ��� ���� � ���� ������������ ���!'#13#10'�������������� ����������!');
    Exit;
  end;
  if Q.QSelectOneRow('select count(*) from bcad_nomencl where name = :name$s', [va2[1]])[0] <> 0 then begin
    MyWarningMessage('��������� ������������ ��� ���� � ���� ������������ �����!'#13#10'�������������� ����������!');
    Exit;
  end;
  Q.QBeginTrans(True);
  Q.QExecSql('update dv.nomenclatura set name = :name$s where id_nomencl = :id$i', [va2[1], IdItm]);
  Q.QExecSql('update bcad_nomencl set name = :name$s where name = :nameold$s', [va2[1], vai[0]]);
  Q.QCommitOrRollback;
  Result:= Q.CommitSuccess;
  if not Result
    then MyWarningMessage('������!');
end;

function TOrders.OpenFromTemplate(Parent: TComponent; Mode: Boolean; var Id: Variant): Boolean;
//����� ������� �� ������ ��� �������� ������ (Mode = True, ���� �� �����������) ��� ��������� ������ �� ������ �������
//���� �� ������ ������������� �������� �����, � ������ ���� ������� �������� ������!
var
  va: TvarDynArray;
  van, vaid: TvarDynArray;
  va2: TVarDynArray2;
  i: Integer;
begin
//mode:=True;
  Result := False;
  if not Mode then begin
    van:=Q.QLoadToVarDynArrayOneCol('select templatename from v_orders where id <= -1 and id_organization = -1 order by templatename asc', []);
    vaid:=Q.QLoadToVarDynArrayOneCol('select id from v_orders where id <= -1 and id_organization = -1 order by templatename asc', []);
    if TFrmBasicInput.ShowDialog(Parent, 'Dbi_SeletOrderTemplate', [dbioSizeable], fAdd, '~����� ������� ������', 320, 85,
//      [[cntComboLK, '������ ������','0:500']],
      [[cntComboLK, '������ ������','1:500']],
      [VarArrayOf(['', VarArrayOf(van), VarArrayOf(vaid)])],
      va,
//      [['�������� ������ ������ �� ������'#13#10'(�������� ������ ���������������� �������),'#13#10'��� �������� ���� ������ ���'#13#10'�������� �������������� ��������� ������']],
      [['�������� ������ ������ �� ������'#13#10'(�������� ������ ���������������� �������).']],
      nil
    ) < 0 then
      Exit;
    Result := True;
    Id := va[0];
  end;
  Exit;
  va2:= Q.QLoadToVarDynArray2('select templatename from v_orders where id <= -1 order by templatename asc', []);
  if Length(va2) = 0
    then begin MyInfoMessage('�� ������� �� ������ �������!'); Exit; end;
  van:=A.VarDynArray2ColToVD1(va2, 0);
  vaid:=A.VarDynArray2ColToVD1(Q.QLoadToVarDynArray2('select id from v_orders where id <= -1 order by templatename asc', []), 0);
  if TFrmBasicInput.ShowDialog(Parent, '', [{dbioSizeable}], fAdd, '~����� ������� ������', 470, 150, [
    [cntComboLK, '������ ������','1:500:0',150],
    [cntnedit, '������ ������','1:5000:0',1],
    [],
    [cntnedit, '������ ������','1:5000:0',100],
    [],
    [cntnedit, '������ ������','1:5000:0',1]
   ],
   [
     VarArrayOf(['0', VarArrayOf(van), VarArrayOf(vaid)]),
     2,3,4
   ],
   va,
   [['�������� ������ ������ �� ������'#13#10'(�������� ������ ���������������� �������),'#13#10'��� �������� ���� ������ ���'#13#10'�������� �������������� ��������� ������']],
   nil
  ) < 0
  then Exit;
end;


function TOrders.CrealeEstimateOnPlannesOrders(DtBeg: TDateTime; ForSn: Boolean = False): Boolean;
(*
1. ��������� ��� ������ �� �������, ��������� ���� ������� �� ����� �������, � ������ (�� �������, ��1, ��2...)
2. �������� �� �������, ��� ������ ��������� ����� �� ������� (����� ��������� � ����������, ����� ����� ����� �� ������� ���������)
3. ������� ������� ��� ������ �������
4. �������� �� ����� ������, � ��� �� ������� �������, ������� � ������� ����. ��������� ������� ������� � ������, ���� �� ��� ���.
   ������� ��������� � ����� * ���-�� � ������ ����� �� �������, ��������� � ������ ��������� ��� ������ ������� ������� �� ������ �����
5. ��������� ���������� �� ������ �������� ������� �� ��� 12 ���������

-------------------
select to_char(id) as id, groupname, name, unit, qnt1_itm as qnt1, qnt_itm as qnt, comm, price, sum1, 0 as chb
  from v_estimate_prices where deleted = 0 and id_std_item = :id$i  and (qnt1_itm is not null)

����������� ������ �� 12 ������� ������, ������� � ��������� ����
�� ���� ������ ������� �������� ����� ���� ��������� ���� ��� ��� ������
(���, ���� �������� ���� ��� �������� � ��������� ��� �����������)

*)
var
  i, j, k, m, n, y: Integer;
  m11, m12, m21, m22: Integer;
  e: Extended;
  b: Boolean;
  va: TVarDynArray;
  OrItems: TVarDynArray2;
  EstimatesMonth : array of TVarDynArray2;
  Estimate12: TVarDynArray2;
  IdStdItem: Variant;
  DtEnd: TDateTime;
const
  cYears = 3;
  cEsMonth = 3;
  cEs12 = 3;
begin
  //��������� ����, �������� � ������� ����� ������
  DtBeg := EncodeDate(YearOf(DtBeg), MonthOf(DtBeg), 1);
//  DtEnd := IncDay(IncMonth(DtBeg, 12), -1);
  //�������� ����, �������� � ������� ����� ������
  DtEnd := IncMonth(DtBeg, S.IIf(ForSn, 2, 11));
  //������� ������ � ����, ����������� � ��������� �����
  m11 := MonthOf(DtBeg);
  m12 := 12;
  //������� ������ � ��������� ����
  m21 := 0;
  m22 := 0;
  if YearOf(DtBeg) = YearOf(DtEnd) then
    //�������� ������� �����, ���� ������� ���� � ��� �� ���� ��� � ���������
    m12 := MonthOf(DtEnd);
  if YearOf(DtBeg) < YearOf(DtEnd) then begin
    //������� ���� � ���������  �� ��������� ���� ����
    m21 := 1;
    m22 := MonthOf(DtEnd);
  end;

  //������ �� �������� ���������, ������ �� ����� ���������� � �� ������� ��������� ����
  OrItems := Q.QLoadToVarDynArray2(
    'select id_std_item, dt_start, dt_end, o.id, '+
    'qnt1, qnt2, qnt3, qnt4, qnt5, qnt6, qnt7, qnt8, qnt9, qnt10, qnt11, qnt12 '+
    'from planned_orders o, planned_order_items i '+
    'where o.id = i.id_planned_order and to_char(dt_start, ''YYYY'') >= :dt_start$i and to_char(dt_end, ''YYYY'') <= :dt_end$i',
    [YearOf(DtBeg), YearOf(DtEnd)]
  );
  //������� �� ������� �������
  for i := High(OrItems) downto 0 do begin
    y := YearOf(OrItems[i][1]);
    b := False;
    //��������� ���-��=���� � �������, �� ���������� � ��������� ������, ��� �������� ���������
    //��������� ����, ���� ���� ��������� ���-�� � ������� ���������
    if y = YearOf(DtBeg) then begin
      //�� ����, ������������ � ����� ��������� ����
      for j := 1 to 12 do
        if (j < m11) or (j > m12) then
          OrItems[i][j + cYears] := null
        else if S.NNum(OrItems[i][j + cYears]) > 0 then
          b := True;
    end
    else begin
      //� �� ������������ - ��������� ���
      for j := 1 to 12 do
        if (j < m21) or (j > m22) then
          OrItems[i][j + cYears] := null
        else if S.NNum(OrItems[i][j + cYears]) > 0 then
          b := True;
    end;
    if not b then begin
      //������ �� ������� ������, ���� ��� ���������� � ������� ��������� ���
      Delete(OrItems, i, 1);
    end;
  end;
  //�����������, ����� ���������� ������� ��� ���������������
  A.VarDynArraySort(OrItems, 0);
  SetLength(EstimatesMonth, Length(OrItems));
//  SetLength(EstimateMonth, Length(OrItems));
//  EstimateMonth := [];
  IdStdItem := null;

  //�������� ����� �� �������� �������� �������
  for i := 0 to High(OrItems) do begin
    if (i > 0) and (OrItems[i][0] = OrItems[i - 1][0]) then
      //���� ���������� ������ �������� ��� �� �������� ��� � �������, �� ��������� ����� �� ��, ������ �������� ������
      EstimatesMonth[i] := Copy(EstimatesMonth[i - 1])
    else
    //�������� ������ �� ��
    EstimatesMonth[i] := Q.QLoadToVarDynArray2(
      'select name, unit, qnt1_itm, '+
      'null, '+
      '0,0,0,0,0,0,0,0,0,0,0,0, '+                                        //����������
      'null,null,null,null,null,null,null,null,null,null,null,null '+     //���� ������� ����� ���
      'from v_estimate where deleted = 0 and id_std_item = :id$i  and (qnt1_itm is not null)',
      [OrItems[i][0]]
    );
    //��������� � ����� ���������� �� �������, ��� ���������� ���������� ���-�� �� ������� ��� ���
    for j := 1 to 12 do
      if S.NNum(OrItems[i][j + cYears]) > 0    then begin
        for k:= 0 to High(EstimatesMonth[i]) do begin
          e := S.NNum(EstimatesMonth[i][k][2]) * OrItems[i][j + cYears];
          //���� ���������� � ���� ������ ���������
          if e <> 0 then begin
            //� ����� ������� ��������
            if YearOf(OrItems[i][1]) = YearOf(DtBeg)
              then n := j + cEsMonth - m11 + 1
              else n := j + cEsMonth - m11 + 12 + 1;
            //��������� ����������
            EstimatesMonth[i][k][n] := e;
            //��������� ���� ������ ����� �������, ���� ��� ��� � ������
            if not S.InCommaStr(VarToStr(OrItems[i][3]), S.Nst(EstimatesMonth[i][k][n + 12])) then
              S.ConcatStP(EstimatesMonth[i][k][n + 12], OrItems[i][3], ',', True);
          end;
        end;
      end;
  end;


  Estimate12 := [];
  for i := 0 to High(OrItems) do begin
    //�� ������� �������� � ����� �� ������� ��������� ������
    for j := 0 to High(EstimatesMonth[i]) do begin
      //�� ������� �������� �������� �����
      k := 0;  //����� � ����� ��������, ���� �� ����������� �� ����� ��������
      for k := 0 to High(Estimate12) do
        if Estimate12[k][0] = EstimatesMonth[i][j][0] then Break;
      if k > High(Estimate12) then begin
        Estimate12 := Estimate12 + [[EstimatesMonth[i][j][0], EstimatesMonth[i][j][1], null, null, 0,0,0,0,0,0,0,0,0,0,0,0, '','','','','','','','','','','','']];
      end;
      for m:= 1 to 12 do begin
        Estimate12[k][m + cEs12] := Estimate12[k][m + cEs12] + EstimatesMonth[i][j][m + cEsMonth];
        //��������� ��������� ���������� �������� �������
        va := A.Explode(EstimatesMonth[i][j][m + cEsMonth + 12], ',');
        for n := 0 to High(va) do
          if not S.InCommaStr(VarToStr(va[n]), VarToStr(Estimate12[k][m + cEs12 + 12]), ',') then
            S.ConcatStP(Estimate12[k][m + cEs12 + 12], va[n], ',', True);
      end;
    end;
  end;

  //Sys.SaveArray2ToFile(Estimate12, 'r:\vvv');
  if ForSn then begin
    //��� ������������� � ������� ��, �� ��� ������ �� ����
    Q.QBeginTrans(True);
    Q.QExecSql('delete from planned_order_estimate3', []);
    for i := 0 to High(Estimate12) do begin
      Q.QIUD(
        'i', 'planned_order_estimate3' , '-' , 'id_nomencl$i;name$s;qnt1$f;qnt2$f;qnt3$f;or1$s;or2$s;or3$s',
        [0, Estimate12[i][0],
         Estimate12[i][cEs12 + 1], Estimate12[i][cEs12 + 2], Estimate12[i][cEs12 + 3],
         Estimate12[i][cEs12 + 12 + 1], Estimate12[i][cEs12 + 12 + 2], Estimate12[i][cEs12 + 12 + 3]
        ]
      );
    end;
    //��������� ���� ������������ �� ���
    Q.QExecSql('update planned_order_estimate3 p set id_nomencl = (select id_nomencl from dv.nomenclatura d where d.name = p.name)', []);
    //��������� ���� � ���������� ������� �� (��� �������)
    Q.QExecSql('update spl_minremains_params set planned_dt = :dt$d', [DtBeg]);
    //��������� �������� �����������
    CalcSplNeedPlanned(0);
    Q.QCommitOrRollback;
  end
  else begin
    //��� ������ ������� ����������� � ����������
    Q.QBeginTrans(True);
    Q.QExecSql('delete from planned_order_estimate12', []);
    for i := 0 to High(Estimate12) do begin
      va := [0 ,Estimate12[i][0]];
      for j := cEs12 + 1 to cEs12 + 0 + 12 + 12 do
        va := va + [Estimate12[i][j]];
      Q.QIUD(
        'i', 'planned_order_estimate12' , '-' ,
        'id$i;name$s;'+
        'qnt1$f;qnt2$f;qnt3$f;qnt4$f;qnt5$f;qnt6$f;qnt7$f;qnt8$f;qnt9$f;qnt10$f;qnt11$f;qnt12$f;'+
        'or1$s;or2$s;or3$s;or4$s;or5$s;or6$s;or7$s;or8$s;or9$s;or10$s;or11$s;or12$s'
        ,
        va
      );
    end;
    //�������� � ������� ����� ���������� ���� ������ ������� � ���� �������
    Q.QCallStoredProc('p_SetProp', 'p$s;sp$s;st$s;dt$d;i$i;f$f', ['planned_order_estimate12', 'dt_beg', '', DtBeg, null, null]);
    Q.QCallStoredProc('p_SetProp', 'p$s;sp$s;st$s;dt$d;i$i;f$f', ['planned_order_estimate12', 'dt_calc', '', Now, null, null]);
    Q.QCommitOrRollback;
  end;
end;

function TOrders.CalcSplNeedPlanned(IdNomencl: Integer): Boolean;
//��������� �������� ����������� � ���������� ������������ ��� ���������, ��� ����� ������� ��� �� ���
//���� ������� � ���� ������� (spl_itm_nom_props)
var
  va2 : TVarDynArray2;
  i, j, k, d: Integer;
  qnt: Variant;
  dt, dt2: TDateTime;
begin
  va2 := Q.QLoadToVarDynArray2(
    'select '+
    'p.id, e.qnt1, e.qnt2, e.qnt3, 0, p.planned_need_days '+
    'from spl_itm_nom_props p, planned_order_estimate3 e '+
    'where p.id = e.id_nomencl (+) '+
    S.IIfStr(IdNomencl <> 0, 'and e.id_nomencl = :id_nomencl$i'),
    [IdNomencl]
  );
  qnt := null;
  for i := 0 to High(va2) do begin;
    if ((va2[i][1] = null) and (va2[i][2] = null) and (va2[i][3] = null)) or (va2[i][5] = null) then begin
      Q.QExecSql('update planned_order_estimate3 set qnt0 = :qnt$i where id_nomencl = :id_nomencl$i', [null, va2[i][0]]);
      Continue;
    end;
    dt := IncDay(Date, (va2[i][5] - 1));
    if dt > EndOfTheMonth(Date)
      then dt2 := EndOfTheMonth(Date)
      else dt2 := dt;
    qnt := Round(va2[i][1] / DaysInMonth(Date) * (DaysBetween(dt2, date) + 1));
    for j := 1 to 2 do begin
      if dt < EncodeDate(YearOf(IncMonth(Date, j)), MonthOf(IncMonth(Date, j)), 1) then
        Break;
      if dt > EndOfTheMonth(IncMonth(Date, j))
        then k := DaysInMonth(IncMonth(Date, j))
        else k := DayOf(dt);
      qnt := qnt + Round(va2[i][j + 1] / DaysInMonth(IncMonth(Date, j)) * k);
    end;
    Q.QExecSql('update planned_order_estimate3 set qnt0 = :qnt$i where id_nomencl = :id_nomencl$i', [qnt, va2[i][0]]);
  end;
end;

function TOrders.SetTaskForCreateOrder(AIdOrder: Integer): Boolean;
//�������� ������ ��� ���������� ��������
//� ������ �������� ������ ������ ������ ��������, �� ���������� ���� Z
var
  st, st1, filesadd, filesdelete, TaskDir, Slashes, Addr, Subj, PspName, PspNameOld: string;
  i, j, RecNo: Integer;
  SaO, SaOI: TNamedArr;
begin
  Result := False;
  try
    SaO := Q.QLoadToRec('select id, dt_beg, path, area from orders where id = :id$i',  [AIdOrder]);
    //������� ������ ���� ����� �� 0, �� � ���, � �� �/�
    SaOI := Q.QLoadToRec('select id, prefix, fullitemname, pos from v_order_items where id_order = :id_order$i and qnt > 0 and nvl(sgp, 0) = 0', [SaO.G('id')]);
    Slashes := '';
    for i := 0 to SaOI.Count - 1 do begin
      S.ConcatStP(Slashes, RightStr('0000' + VarToStr(SaOI.G(i, 'pos')), 3) + ' ' + S.CorrectFileName(Trim(SaOI.G(i, 'fullitemname'))), #13#10);
    end;
    Addr := S.NSt(Q.QSelectOneRow('select addresses from adm_mailing where id = :i$i', [1])[0]);
    Subj := Orders.GetSubject('������ �����', '', SaO.G('id'), null);
    st:= S.NSt(Q.QSelectOneRow('select order_prefix from ref_production_areas where id = :id$i', [SaO.G(0, 'area')])[0]);
    PspName:= SaO.G('path');
    Delete(PspName, 1, length(st));
    if not ExportPassportToXLSX(SaO.G('id'), PspName, False, True) then
      Exit;
    PspName := PspName + '.xlsx';
    //�������� �������
    TaskDir := Tasks.CreateTaskRoot(mytskopToPassportChange, [
      ['directory', SaO.G('path')],
      ['old-directory', ''],
      ['in_archive', 0],
      ['year', YearOf(SaO.G('dt_beg'))],
      ['passport', PspName],
      ['old-passport', ''],
      ['subject', Subj],
      ['to', Addr],
      ['body', Subj],
      ['files-to-send', PspName],
      ['files-to-copy', ''],
      ['files-to-delete', ''],
      ['slashes', Slashes]  //    ['', ],
      ],
      False, False
    );
    //��������� ������� ������ �� ���������� ����� � ������� ������
    CopyFile(pWideChar(Sys.GetWinTemp + '\' + PspName), pWideChar(Module.GetPath_Tasks + '\' + TaskDir + '\Files\' + PspName), True);
    //������ ��������� ���� ��������
    DeleteFile(Sys.GetWinTemp + '\' + PspName);
    //�������� ������ �� ����������
    Tasks.FinalizeTaskDir(Module.GetPath_Tasks + '\' + TaskDir);
    Result := True;
  except on E: Exception do Application.ShowException(E);
  end;
end;

function TOrders.ExportPassportToXLSX(AIdOrder: Integer; OrderPath: string; Open: Boolean = False; OnlyNot0: Boolean = False): Boolean;
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
  SaO, SaOI: TNamedArr;
begin
  Result := False;
  try
  FileName := Module.GetReportFileXlsx('��');
  if FileName = '' then
    Exit;
  Rep := TA7Rep.Create;
  try
    Rep.OpenTemplate(FileName, False, False);
  except
    Rep.Free;
    Exit;
  end;
  SaO := Q.QLoadToRec(
    'select id, ornum, area_short as area, typename as id_type, or_reference, project, customer, customerlegal, '+
    'customerman, customercontact, address, address, account, organization as id_organization, dt_beg, '+
    'dt_otgr, dt_montage_beg, managername, comm, '+
    'ch, path, area '+
    'from v_orders where id = :id$i',
    [AIdOrder]
  );
  SaOI := Q.QLoadToRec(
    'select pos, slash, fullitemname as fullname, qnt, std, nstd, sgp, r1, r2, r3, r4, r5, r6, r7, kns, thn, comm '+
    'from v_order_items where id_order = :id_order$i and qnt > 0 order by pos',
    [SaO.G('id')]
  );
//  va := A.ExplodeV(SaO.G('ch'), ',');
  Rep.PasteBand('HEADER');
  for j := 0 to High(SaO.F) do begin
    st := SaO.F[j];
    Rep.ExcelFind('#' + st + '#', x, y, xlValues);
    if x = -1 then
      Continue;
    Rep.SetValue('#' + st + '#', VarToStr(SaO.V[0][j]));
{    if A.InArray(FieldsArr[j][cControl], va) then begin
      Rep.TemplateSheet.Cells[y, x].Interior.Color := GetDiffColor; //RGB(255, 170, 170);
    end;}
  end;
  //� ������� ����� ������������� ����� �������, ����� �������������� - fullname
  for i := 0 to SaOI.Count - 1 do begin
    Rep.PasteBand('TABLE');
    for j := 0 to High(SaOI.F) do begin
      st := SaOI.F[j];
      Rep.ExcelFind('#' + st + '#', x, y, xlValues);
      if x = -1 then
        Continue;
      st1 := VarToStr(SaOI.V[i][j]);
      if st = 'POS' then
        st1 := IntToStr(i + 1);
      if A.PosInArray(st, ['std', 'nstd', 'sgp', 'resale', 'r1', 'r2', 'r3', 'r4', 'r5', 'r6', 'r7'], True) >= 0 then
        if (st1 = '0') or (st1 = '') then
          st1 := ''
        else
          st1 := 'X';
      if (st = 'COMM') then begin
        //���� ��� ����������� ������ ������ �����������
        Rep.SetValueAsText('#comm#', st1);
        Rep.TemplateSheet.Cells[y, x].NumberFormat := '';
      end
      else
        Rep.SetValue('#' + st + '#', st1);
    end;
  end;
  Rep.PasteBand('FOOTER');
  Rep.ExcelFind('#comm#', x, y, xlValues);
  //���� ����� ������, �� SetValue � ����� ������, ���������� SetValueAsText
  Rep.SetValueAsText('#comm#', VarToStr(SaO.G('comm')));
  //�� ��� ��������� ������ ������ � ����������, � � ���� �������, ���� ����� �� ���������� � ������ (�� ����� ��� �������� ������� �� ������),
  //�� ������������� � ����� ������� ####################
  //��� ���������� �������� ��������� ������ General (NumberFormat := '';)
  Rep.TemplateSheet.Cells[y, x].NumberFormat := '';
{ if (nedt_Attention.Value = 1) then begin
    Rep.TemplateSheet.Cells[y, x].Font.Underline := 2; //xlUnderlineStyleSingle;
    Rep.TemplateSheet.Cells[y, x].Font.FontStyle := 'Bold';
  end;}
  Rep.DeleteCol1;
  if Open then begin
    Rep.Show;
    Rep.Free;
    Result := True;
  end
  else begin
    //������������ ������ .Save, � �� .SaveAs !
    Rep.Save(Sys.GetWinTemp + '\' + OrderPath + '.xlsx');
    if not FileExists(Sys.GetWinTemp + '\' + OrderPath + '.xlsx') then
      Exit;
    Result := True;
  end;
  except on E: Exception do Application.ShowException(E);
  end;
end;

procedure TOrders.CopyEstimateToBuffer(IdStdItem, IdOrItem: Variant);
begin
  Q.QCallStoredProc(
    'p_CopyEstimateToUserTemp',
    'id_user$i;id_std_item$i;id_or_item$i',
     [User.GetId, IdStdItem, IdOrItem]
  );
end;

procedure TOrders.ViewItmDocumentFromLog(AParent: TForm; AId: Variant);
var
  i, j: Integer;
  va: TVarDynArray;
  va2: TVarDynArray2;
  st, st2: string;
  DocId: Variant;
  DocType: string;
  procedure GetDocNum(st: string);
  var
    i: integer;
  begin
    DocId := '';
    i := Pos('�', st);
    if i > 0 then
      while (i <= Length(st)) and (st[i] in ['0'..'9']) do begin
        DocId := DocId + st[i];
        inc(i);
      end;
  end;
begin
  va := Q.QSelectOneRow('select id, doctype, id_doc, commentsfull, name, user_windows from v_itm_log where id = :id$i', [AId]);
  DocId := '';
  if (va[0] = null) or (va[1] = null) then
    Exit;
  if va[2] <> null then
    DocId := va[2]
  else
    GetDocNum(va[3]);
  DocType := S.Decode([
    va[1], null, '',
    '��������� ���������', myfrm_R_Itm_InBill,
    '��������� �����������', myfrm_R_Itm_MoveBill,
    '��� ��������', myfrm_R_Itm_OffMinus,
    '��� �������������', myfrm_R_Itm_PostPlus,
    '���', myfrm_R_Itm_Act,
    '���� ����������', myfrm_R_Itm_Schet,
    '?'
  ]);
{'��������� ���������' '������ ����������'}
  if (DocType = '') then
    Exit;
  if S.NSt(DocId) = '' then begin
    va2 := Q.QLoadToVarDynArray2(
      'select id, doctype, id_doc, commentsfull, user_windows from v_itm_log where id < :id$i and  id > :id0$i and doctype = :dt$s and name = :nm$s ' +
      'and (id_doc is not null or commentsfull is not null) and comments = ''�������� �����'' order by id desc',
      [va[0], va[0] - 100, va[1], va[4]]
    );
  end;
  if (Length(va2) > 0) then begin
    if va2[0][2] <> null then
      DocId := va2[0][2]
    else
      GetDocNum(va2[0][3]);
  end;
  if (DocType = '') or (S.NSt(DocId) = '') then
    Exit;
  if DocType = '?' then
    MyInfoMessage('�������� � id = ' + VarToStr(DocId))
  else
    Wh.ExecReference(DocType, AParent, [myfoDialog, myfoSizeable, myfoEnableMaximize], DocId);
end;




begin
  Orders := TOrders.Create;
end.
