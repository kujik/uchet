{
������ ����������� ������ �� ������:
������� ���
������� �� ���
�������� � ���
������
����� - ������ ������������ � ������������

������� �� ��������� � ���������� ����� (����� �������), ����� ����� � ��������� ������
��������� ��� ������ ������, ������ ������������ � ����� �����.
}

unit uFrmOGjrnOrderStages;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2, uFrmBasicInput
  ;

type
  TFrmOGjrnOrderStages = class(TFrmBasicGrid2)
    procedure Frg1DbGridEh1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FDtEdit: TDateTime;    //����, �� ������� ���������� �������� ������� ��� ����� � ������� �����
    FDtEditMin: TDateTime; //����, ����� ������� �������������� ������ ���������
    FDtBeg: TDateTime;     //���� ������ �������
    FDtEnd: TDateTime;     //���� ����� �������
    FOpMode: Byte;         //��� ����� ������ (� ������, ������� �� ���...) - ������������� ����� id_stage � ��
    FEditMode: Integer;    //��������� �� �������������� (0-���)
    function  PrepareForm: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);  override;
    procedure Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    procedure Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string); override;
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; FEditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
    procedure Frg2CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure Frg2CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;
    procedure Frg2ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; FEditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg2GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
    procedure SetAddControls;
    procedure SetCellButtons;
    procedure Add�ontrolClick(Sender: TObject);
  procedure GetMode;
  public
  end;

var
  FrmOGjrnOrderStages: TFrmOGjrnOrderStages;

implementation

uses
  D_Order_Stages1,
  D_Order_Stages_Otk2,
  D_DelayedInProd,
  uLabelColors,
  uTurv,
  uOrders,
  uWindows
  ;

const
  mToProd = 1;
  mToSgp = 2;
  mFromSgp = 3;
  mOtk = 4;
  mDelInProd = 200;
  mMontage = 201;

{$R *.dfm}

{ 'pic=0;1;2:1;2;3'

    Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
    Frg1.Opt.SetFields([
      ['id$i','_id','40'],
      ['','',''],
    ]);
    Frg1.Opt.SetTable('v_sn_calendar_accounts');
    Frg1.Opt.SetWhere('');
    Frg1.Opt.SetButtons(1,[[mbtSelectFromList],[mbtGridFilter],[-mbtGridSettings]]);
    Frg1.Opt.SetButtons(1,[[mbtSelectFromList],[],[mbtRefresh],[],[mbtEdit],[mbtAdd],[mbtCopy],[mbtDelete],[],[mbtGridFilter],[],[mbtGridSettings],[],[mbtCtlPanel]]);
    Frg1.Opt.SetButtonsIfEmpty([mbtGo]);
    Frg1.Opt.FilterRules := [[], ['accountdt']];
    Frg1.Opt.SetButtons(1, 'rveacdfsp');
    Frg1.CreateAddControls('1', cntComboLK, '��������:', 'CbArea', '', 80, yrefC, 80);
    Frg1.InfoArray:=[
    ];
 }


function TFrmOGjrnOrderStages.PrepareForm: Boolean;
var
  i: Integer;
  fdef, fdef2: TVarDynArray2;
  HasLog: Boolean;
begin
  GetMode;
  HasLog := FOpMode in [mToSgp, mFromSgp, mOtk];
  Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
  Frg1.Opt.SetTable('v_order_stages1');
  Frg1.Opt.SetButtons(1, [[mbtRefresh], [], [mbtView, FOpMode = mMontage], [mbtEdit, (FOpMode = mMontage) and User.Role(rOr_J_OrderStages_Montage_Ch)], [],
    [mbtPrint], [], [-mbtUchetlog, HasLog], [mbtGridFilter], [], [mbtGridSettings], [], [mbtCtlPanel]]);
  Frg1.CreateAddControls('1', cntLabel, '���� ��: ', 'LbDateCaption', '', 5, yrefC, 200);
  Frg1.CreateAddControls('1', cntLabel, '���� ��: ', 'LbDate', '', 52, yrefC, 200);
  Frg2.Opt.SetButtons(1, [[-mbtRefresh], [], [-mbtGridSettings], []]);
  Frg2.Opt.SetTable('v_order_item_stages1');
  //����, �� ������� ���������/������������ ������ � ���������� �������
  FDtEdit:=Date;
  FDtEditMin:=IncDay(Date, -31);
  FEditMode:=0;
  fdef := [
    ['id$i','_id','40'],
    ['dt_end','_dt_end','40'],
    ['ornum','� ������','90','bt=������� ������'],
    ['dt_beg','���� ����������','75'],
    ['dt_otgr','�������� ���� ��������','75'],
    ['project','������','500;h']
  ];
  fdef2 := [
    ['id$i','_id','40'],
    ['slash','�','120'],
    ['fullitemname','�������','300;h'],
    ['qnt','����������','80'],
    ['sgp','� ���','40','pic'],
    //nst','����������','40','pic'],
    ['route2','�������','120']
  ];
  Frg1.Opt.FilterRules := [[], ['dt_beg;dedt_otgr'], ['������ �� ��������', 'ViewClosed', 'dt_end is null'{, True}]];
  case FOpMode of
    mToProd: begin
      //�� ����������, ������ ���
      Exit;
    end;
    mToSgp: begin
      Caption:='������ ������ �� ���';
      Frg1.Opt.SetFields(fdef + [
        ['st2','������','50','pic=0;1;2:3;2;1'],
        ['dt2b','���� ���.','75'],
        ['dt2e','���� ���.','80','bt=������� ���:24:r:h'],
        ['dt_otk','���� ���','75'],
        ['period','������','80']
      ]);
      Frg1.Opt.SetTable('v_order_stages1_tosgp');
      Frg1.Opt.SetWhere('where id > 0 and st2 is not null');
      Frg2.Opt.SetFields(fdef2 + [
        ['dt2c','_dt2c','40'],
        ['st2','������','40','pic=0;1;2:3;2;1'],
        ['dt2b','���� ���.','75'],
        ['dt2e','���� ���.','75'],
        ['qnt2','������� �����','60'],
        ['qnt2c','������� �������','80','bt=���������:25:r:h;������� ���:24:r:h'],
        ['dt_otk','���� ���','75'],
        ['period','������','80']
      ]);
      Frg2.Opt.SetTable('v_order_item_stages1_tosgp');
      Frg2.Opt.SetWhere('where id_order = :id_order$i and st2 is not null order by slash asc');
      if User.Role(rOr_J_Orderstages_ToSgp_Ch) then FEditMode:=1;
      Q.QSetContextValue('order_stages_dt2c', FDtEdit);
      FDtEditMin:=Turv.GetDaysFromCalendar_Next(Date, - Orders.fDaysToSgp);
    end;
    mFromSgp: begin
      Caption:='������ �������� � ���';
      Frg1.Opt.SetFields(fdef + [
        ['st3','������','50'],
        ['dt3b','���� ���.','75'],
        ['dt3e','���� ���.','80']
      ]);
      Frg1.Opt.SetWhere('where id > 0 and st3 is not null');
      Frg2.Opt.SetFields(fdef2 + [
        ['qnt2','���-�� ��������','60'],
        ['dt3c','_dt2c','40'],
        ['st3','������','40'],
        ['dt3b','���� ���.','75'],
        ['dt3e','���� ���.','75'],
        ['qnt3','��������� �����','60'],
        ['qnt3c','��������� �������','80']
      ]);
      Frg2.Opt.SetWhere('where id_order = :id_order$i and st3 is not null order by slash asc');
      if User.Role(rOr_J_Orderstages_FromSgp_Ch) then
        FEditMode := 1;
      Q.QSetContextValue('order_stages_dt3c', FDtEdit);
      FDtEditMin:=Turv.GetDaysFromCalendar_Next(Date, - Orders.fDaysFromSgp);
    end;
    mOtk: begin
      Caption:='������ ������ ���';
      Frg1.Opt.SetFields(fdef + [
        ['st4','������','50'],
        ['dt4b','���� ���.','75'],
        ['dt4e','���� ���.','80'],
        ['rej','���������','70']
      ]);
      Frg1.Opt.SetTable('v_order_stages1_otk');
      Frg1.Opt.SetWhere('where id > 0 and st4 is not null');
      Frg2.Opt.SetFields(fdef2 + [
        ['st4','������','40'],
        ['dt4b','���� ���.','75'],
        ['dt4e','���� ���.','75'],
        ['qnt4','������� �����','60'],
        ['qnt4c','������� �������','80'],
        ['rej','���������','70']
      ]);
      Frg2.Opt.SetTable('v_order_item_stages1_otk');
      Frg2.Opt.SetWhere('where id_order = :id_order$i and st4 is not null order by slash asc');
      if User.Role(rOr_J_Orderstages_Otk_Ch) then
        FEditMode := 1;
      Q.QSetContextValue('order_stages_dt4c', FDtEdit);
      FDtEditMin:=Turv.GetDaysFromCalendar_Next(Date, - Orders.fDaysOtk);
    end;
    mDelInProd: begin
      Caption:='������ ��������� ������� � ������������';
      Frg1.Opt.SetFields(fdef + [
        ['customer','����������','150;h'],
        ['dt2e','��������� ���� �������.','80'],
        ['cost_i_nosgp_wo_nds','���������','70','f=r:'],
        ['delreasonname','������� ���������','200;h']
      ]);
      Frg1.Opt.SetTable('v_order_delinprod');
      Frg1.Opt.SetWhere('where id > 0');
      Frg2.Opt.SetFields(fdef2 + [
        ['st2','������','40'],
        ['dt2e','���� ���.','75']
      ]);
      Frg2.Opt.SetTable('v_order_delinprod_items');
      Frg2.Opt.SetWhere('where id_order = :id_order$i order by slash asc');
      if User.Role(rOr_J_Orderstages_Otk_Ch) then
        FEditMode := 1;
      Q.QSetContextValue('order_stages_dt4c', FDtEdit);
      FDtEditMin:=Turv.GetDaysFromCalendar_Next(Date, - Orders.fDaysOtk);
//      Pr[2].EditableFields:='';
      FDtBeg:=EncodeDate(YearOf(Date), MonthOf(Date), 1);
      FDtEnd:=Date;
    end;
    mMontage: begin
      Caption:='������ �������';
      Frg1.Opt.SetFields(fdef + [
        ['customer','����������','150;h'],
        ['dt_montage_beg','�������� ���� �������','80'],
        ['dt_montage_end','�������� ����� �������','80'],
        ['dt_montage_beg_real','����. ���� ������','95','f=DD.MM.YYYY'],
        ['dt_montage_end_real','����. ���� ���������','80'],
        ['rep_customer_txt','��������� ����������','300;h'],
        ['rep_installer_txt','��������� �����������','300;h']
      ]);
      Frg1.Opt.SetTable('v_or_montage');
      Frg1.Opt.SetWhere('where id > 0 and dt_montage_beg is not null');
      if User.Role(rOr_J_Orderstages_Montage_Ch) then
        FEditMode := 1;
      FDtEditMin:=Turv.GetDaysFromCalendar_Next(Date, - Orders.fDaysMontage);
    end;
  end;
  if User.IsDataEditor then
    FEditMode := 0;
  SetCellButtons;
  SetAddControls;
  Result := inherited;
end;

procedure TFrmOGjrnOrderStages.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
var
  fd: string;
begin
  if fMode <> fNone then begin
    if FOpMode = mMontage then
      Wh.ExecDialog(myfrm_Dlg_J_Montage, Self, [], S.IIf(FEditMode <> 1, fView, fMode), Fr.ID, FDtEditMin);
  end
  else if Tag = mbtUchetlog then begin
    fd := S.Decode([FOpMode, mToSgp, myfrm_J_OrderStages_ToSgp_Log, mFromSgp, myfrm_J_OrderStages_FromSgp_Log, mOtk, myfrm_J_OrderStages_Otk_Log, '']);
    if fd <> '' then Wh.ExecReference(fd);
  end
  else Inherited;
end;

procedure TFrmOGjrnOrderStages.Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
//������� ���������� �� �������� �������
var
  v: Variant;
  va: TVarDynArray;
  va2: TVarDynArray2;
  i, j: Integer;
  b: Boolean;
  Changed: Boolean;
begin
  if Fr.IsEmpty then
    Exit;
  Changed := False;
  if Fr.CurrField = 'ornum' then begin
    Wh.ExecDialog(myfrm_Dlg_Order, Self, [], fView, Fr.ID, null);
  end
  else if Fr.CurrField = 'dt_montage_end_real' then begin
    Frg1ButtonClick(Fr, 1, 0, fEdit, b);
  end
  else if Fr.CurrField = 'delreasonname' then begin
    //���� �� ������� ��������� � ������� ��������� � ������������
    if Dlg_DelayedInProd.ShowDialog(S.IIf(FEditMode <> 0, fEdit, fView), Fr.ID) then begin
      Frg1.RefreshRecord;
      Frg2.RefreshGrid;
    end;
  end
  else if TRegEx.IsMatch(Fr.CurrField, '^dt[2,3,4]{1}e$') then begin
    //���� �� ���� ��������� � �������� ������� �� ��� � �������� � ���
    if not (FOpMode in [mToProd, mToSgp, mFromSgp, mOtk]) then
      Exit;
    //�� ����� �������� ����������� ������
    if Fr.GetValue('dt_end') <> null then
      Exit;
    //������ �� ������ ��� �������� �� 1 ��� 2 (���� �� ����� ������ ��� ��� ��� ��������� ���������)
    if not ((Fr.GetValue('st' + IntToStr(FOpMode)) = 0) or (Fr.GetValue('st' + IntToStr(FOpMode)) = 1)) then
      Exit;
    if MyQuestionMessage(S.Decode([FOpMode,
       mToSgp,   '�������� ���� ����� �������� �� ���?',
       mFromSgp, '�������� ���� ����� ����������� � ���?',
       mOtk,     '�������� ���� ����� �������� ���?'
    ])) <> mrYes
      then Exit;
    Q.QBeginTrans(True);
    //��������� ��� ������ ������ �� ��������� 0 � 1
    va2 := Q.QLoadToVarDynArray2('select id, qnt from v_order_item_stages1 where id_order = :id_order$i and st' + IntToStr(FOpMode) + ' in (0,1)', [Fr.ID]);
    for i:=0 to High(va2) do
      //��� ������ ������� �������� ��������� � ����������, ������ ���-�� � ������, ���� ����� ������ - ��� �������������� � �������� ���������
      Q.QCallStoredProc('p_OrderStage_SetItem', 'IdOrderItem$i;IdStage$i;NewDt$d;NewQnt$f;UpdateOrder$i;ResQnt$fo',
        VarArrayOf([va2[i,0], FOpMode, FDtEdit, va2[i,1], 0, -1])
      );
    if FOpMode in [mToProd,mToSgp,mFromSgp] then
      //����������� �������� ������� ������
      Q.QCallStoredProc('p_OrderStage_SetMainTable', 'IdOrder$i;IdStage$i', VarArrayOf([Fr.ID, FOpMode]));
    if (FOpMode in [mToSgp, mFromSgp]) and (Q.PackageMode <> -1) then
      Orders.FinalizeOrder(Fr.ID, S.Decode([FOpMode, mToSgp, myOrFinalizeToSgp, mFromSgp, myOrFinalizeFromSgp]));
    Q.QCommitOrRollback;
    if Q.CommitSuccess then begin
      Frg1.RefreshRecord;
      Frg2.RefreshGrid;
    end
    else MyWarningMessage('��������� ������ ��� ���������� ��������!');
  end
  else inherited;
end;

procedure TFrmOGjrnOrderStages.Frg1DbGridEh1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (User.IsDataEditor)and(Key = Ord('E'))and(Shift = [ssCtrl]) then begin
    if MyQuestionMessage(S.IIf(FEditMode = 0 ,'��������', '���������') + ' ����� ����� ������?') <> mrYes then Exit;
    if FEditMode = 0 then begin
      FDtEditMin:=EncodeDate(2024,01,01);
      FEditMode:=1;
    end
    else FEditMode:=0;
    SetCellButtons;
    SetAddControls;
    Frg1.SetColumnsPropertyes;
    Frg1.DbGridEh1.Repaint;
    if Length(Frg2.Opt.Sql.FieldsDef) > 0 then begin
      Frg2.SetColumnsPropertyes;
      Frg2.DbGridEh1.Repaint;
    end;
  end
  else Frg1.DbGridEh1KeyDown(Sender, Key, Shift);
end;

procedure TFrmOGjrnOrderStages.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin

end;

procedure TFrmOGjrnOrderStages.Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
end;

procedure TFrmOGjrnOrderStages.Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string);
begin
  if Mode <> dbgvBefore then
    Exit;
  if FieldName = 'dt_montage_beg_real' then begin
    //��� ������� ������� - ���� ���� ������ �������
    //�� ����� �������� ����������� ������
    Msg := '-';
    if Fr.GetValue('dt_end') <> null then
      Exit;
    if (Fr.GetValue('dt_end') <> null) or (Fr.GetValue('dt_montage_end_real') <> null) then
      Exit;
    Msg := '*';
    if (Fr.GetValue('dt_montage_beg_real') <> null) and (Fr.GetValue('dt_montage_beg_real') < FDtEditMin) then
      Exit;
    if not ((S.NSt(Value) ='') or S.IsDateTime(Value, 'd')) then
      Exit;
    if (Value < FDtEditMin) or (Value > Date) then
      Exit;
    Msg := '';
  end;
end;

procedure TFrmOGjrnOrderStages.Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
begin
  if FieldName = 'dt_montage_beg_real' then begin
    Q.QBeginTrans(True);
    Q.QExecSql('insert into or_montage (id) select :id$i from dual where not exists (select null from or_montage where id = :id1$i)', [Fr.ID, Fr.ID]);
    Q.QExecSql('update or_montage set dt_beg = :dt_beg$d where id = :id2$i', [Value, Fr.ID]);
    Q.QCommitOrRollback;
  end;
end;

procedure TFrmOGjrnOrderStages.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; FEditMode: Boolean; Params: TColCellParamsEh);
begin
  //��������� �����������
  if (FieldName = 'ornum') and (Fr.GetValue('dt_end') <> null)
    then Params.Background:=clmyPink;
  if FOpMode = mMontage then begin
    //��� ������� �� ������� - ��������� ������ ��������� �� ����� ������ � ��������� �������
    if (FieldName = 'dt_montage_end_real') and (
      (Fr.GetValue('dt_montage_end_real') > Fr.GetValue('dt_montage_end'))or
      ((Fr.GetValue('dt_montage_end_real') = null) and (Date > Fr.GetValue('dt_montage_end')))
      )
      then Params.Background:=RGB(255, 255, 0);
    if (FieldName = 'dt_montage_beg_real') and (
      (Fr.GetValue('dt_montage_beg_real') > Fr.GetValue('dt_montage_beg'))or
      ((Fr.GetValue('dt_montage_beg_real') = null) and (Date > Fr.GetValue('dt_montage_beg')))
      )
      then Params.Background:=RGB(255, 255, 0);
  end;

end;

procedure TFrmOGjrnOrderStages.Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin

end;

procedure TFrmOGjrnOrderStages.Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
  ReadOnly := (FEditMode = 0) or (Frg1.GetValue('dt_end') <> null);
end;


{------------------------------------------------------------------------------}

procedure TFrmOGjrnOrderStages.Frg2CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
//���� �� cellbutton � ��������� ������
var
  Changed: Boolean;
begin
  if Fr.IsEmpty then
    Exit;
  Changed := False;
  if (TCellButtonEh(Sender).Hint = '����������') and (Fr.CurrField = 'rej') then begin
    if Dlg_Order_Stages_Otk2.ShowDialog(S.IIf(FEditMode = 0, fView, fEdit), Fr.ID, FOpMode, FDtEditMin, FDtEdit) then
      Changed := True;
  end
  else if TRegEx.IsMatch(Fr.CurrField, '^qnt[0-9]{1,2}$') then
    //� ������� ������ ��������� ���������� - ������ ��������� �������
    if Dlg_Order_Stages1.ShowDialog(S.IIf(FEditMode = 0, fView, fEdit), Fr.ID, FOpMode, FDtEditMin) then begin
      Changed := True;
      if (FOpMode in [mToSgp, mFromSgp]) then
        Orders.FinalizeOrder(Frg1.ID, S.Decode([FOpMode, mToSgp, myOrFinalizeToSgp, mFromSgp, myOrFinalizeFromSgp]));
    end;
  //� ������� ��������� ������� - �������� ������� ����� ���������� ��� ������� �������
  if TRegEx.IsMatch(Fr.CurrField, '^qnt[0-9]{1,2}c$') then begin
    if Frg1.GetValue('dt_end') <> null then
      Exit;
    Q.QBeginTrans(True);
    Q.QCallStoredProc('p_OrderStage_SetItem', 'IdOrderItem$i;IdStage$i;NewDt$d;NewQnt$f;UpdateOrder$i;ResQnt$fo', [Fr.ID, FOpMode, FDtEdit, Fr.GetValue('qnt'), 1, -1]);
    Q.QCommitOrRollback(True);
    if (FOpMode in [mToSgp, mFromSgp]) then
      Orders.FinalizeOrder(Frg1.ID, S.Decode([FOpMode, mToSgp, myOrFinalizeToSgp, mFromSgp, myOrFinalizeFromSgp]));
    Changed := True;
  end;
  if Changed then begin
    Fr.RefreshRecord;
    Fr.SetState(True, null, null);
  end;
end;

procedure TFrmOGjrnOrderStages.Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  Fr.SetSqlParameters('id_order$i', [Frg1.ID]);
end;

procedure TFrmOGjrnOrderStages.Frg2CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
begin
  Q.QBeginTrans(True);
  Q.QCallStoredProc('p_OrderStage_SetItem', 'IdOrderItem$i;IdStage$i;NewDt$d;NewQnt$f;UpdateOrder$i;ResQnt$fo',
    VarArrayOf([Fr.ID, FOpMode, FDtEdit, S.NNum(Value), 1, -1])
  );
  Q.QCommitOrRollback;
  if (FOpMode in [mToSgp, mFromSgp]) then
    Orders.FinalizeOrder(fr.ID, S.Decode([FOpMode, mToSgp, myOrFinalizeToSgp, mFromSgp, myOrFinalizeFromSgp]));
  Fr.SetState(True, null, null);
end;

procedure TFrmOGjrnOrderStages.Frg2ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; FEditMode: Boolean; Params: TColCellParamsEh);
begin

end;

procedure TFrmOGjrnOrderStages.Frg2GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
  ReadOnly := (FEditMode = 0) or (Frg1.GetValue('dt_end') <> null);
end;
{------------------------------------------------------------------------------}


procedure TFrmOGjrnOrderStages.GetMode;
begin
  if (FormDoc = myfrm_J_OrderStages_ToProd) then
    FOpMode := mToProd;
  if (FormDoc = myfrm_J_OrderStages_ToSgp) then
    FOpMode := mToSgp;
  if (FormDoc = myfrm_J_OrderStages_FromSgp) then
    FOpMode := mFromSgp;
  if (FormDoc = myfrm_J_OrderStages_Otk) then
    FOpMode := mOtk;
  if (FormDoc = myfrm_J_Or_DelayedInProd) then
    FOpMode := mDelInProd;
  if (FormDoc = myfrm_J_Or_Montage) then
    FOpMode := mMontage;
end;

procedure TFrmOGjrnOrderStages.SetAddControls;
//��������� �������� �������������� ��������� ����������
begin
  if FOpMode in [mToProd, mToSgp, mFromSgp, mOtk] then begin
    TLabel(Frg1.FindComponent('LbDate')).Caption:= S.IIf(FDtEdit = Date, '�������', DateToStr(FDtEdit)); //'���� ��: ' +
    TLabel(Frg1.FindComponent('LbDate')).Font.Color:=RGB(0,0,255);
    //�� ���������� ������� �������������� ������, ��������� �������� �������
    TLabel(Frg1.FindComponent('LbDate')).OnClick:= Add�ontrolClick;
  end
  else if FOpMode in [mDelInProd] then begin
    TLabel(Frg1.FindComponent('LbDateCaption')).Caption := '������:';
    TLabel(Frg1.FindComponent('LbDate')).Caption:= S.IIf(MonthOf(FDtBeg) = MonthOf(Date), '������� �����', MonthsRu[MonthOf(FDtBeg)] + ' ' + IntToStr(YearOf(FDtBeg)));
    TLabel(Frg1.FindComponent('LbDate')).Font.Color:=RGB(0,0,255);
    TLabel(Frg1.FindComponent('LbDate')).OnClick:= Add�ontrolClick;
  end
  else begin
    TLabel(Frg1.FindComponent('LbDateCaption')).Caption := '';
    TLabel(Frg1.FindComponent('LbDate')).Caption := '';
  end;
end;

procedure TFrmOGjrnOrderStages.SetCellButtons;
//��������� �������� � �����, ������ � ������� � ������ ��������������� �������
begin
  Frg1.Opt.SetColFeature('st1;st2;st3;st4', 'pic=0;1;2:3;2;1', True);
  Frg1.Opt.SetColFeature('rej;rep_customer_txt;rep_installer_txt', 'pic=� �����������:9;0', True);
  Frg1.Opt.SetColFeature('dt2e;dt3e;dt4e', 'bt=' + S.IIf(FOpMode = mFromSgp, '��������� ���', '������� ���') +':24:r:h', FEditMode > 0, True);
  Frg1.Opt.SetColFeature('ornum', 'bt=������� ������:6');
  Frg1.Opt.SetColFeature('delreasonname', 'bt=������� ���������:e:r:h');
  Frg1.Opt.SetColFeature('dt_montage_end_real', 'bt='+S.IIFStr(FEditMode > 0, '���� ������', '��������')+':e:r:h');
  Frg1.Opt.SetColFeature('dt_montage_beg_real', 'e', FEditMode > 0);
{
  Gh.SetGridInCellButtons(DBGridEh1, 'ornum', '������� ������', CellButtonClick);
  Gh.SetGridInCellButtons(DBGridEh1, 'delreasonname', '������� ���������', CellButtonClick, ebhpRightEh, ebsGlyphEh, 16 ,'', False);
  Gh.SetGridInCellButtons(DBGridEh1, 'dt_montage_end_real', S.IIFStr(FEditMode > 0, '���� ������', '��������'), CellButtonClick, ebhpRightEh, ebsGlyphEh, 16 ,'', False);
  if FOpMode = mOtk then Gh.SetGridInCellImages(DBGridEh1, 'rej', MyData.IL_All16, '0;1;2;3;4;5;6;7;8;� �����������', -1); //�������� � ������ � �������� 3 � ���������� (����������!!! -��� ��� ������� +, ������ ��� ������� �����, ��������, ������ 9)
  if FOpMode = mMontage then Gh.SetGridInCellImages(DBGridEh1, 'rep_customer_txt;rep_installer_txt', MyData.IL_All16, '0;1;2;3;4;5;6;7;8;� �����������', -1); //�������� � ������ � �������� 3 � ����������
  if FEditMode > 0 then
    Gh.SetGridInCellButtons(DBGridEh1, 'dt2e;dt3e;dt4e;delreasonname', '������� ���;��������� ���;������� ���;', CellButtonClick, ebhpRightEh, ebsGlyphEh, 21 ,'', False);
    if FOpMode = mMontage then begin
  //    DBGridEh1.FieldColumns['dt_montage_beg_real'].Field.SetFieldType(ftDate); //������ �� ������, ����� ��� ����� ��������
      DBGridEh1.FieldColumns['dt_montage_beg_real'].DisplayFormat:='DD.MM.YYYY';  //���� ������ �� ������, �� ��� �������������� ����� ������ ���� ����� �������� ������ ������ �������
      //DBGridEh1.FieldColumns['dt_montage_beg_real'].onUpdateData:=DBGridEh1ColumnsUpdateData;
      DBGridEh1.FieldColumns['dt_montage_beg_real'].AlwaysShowEditButton:=True;
    end;}
  if Length(Frg2.Opt.Sql.FieldsDef) = 0 then
    Exit;
  Frg2.Opt.SetColFeature('st1;st2;st3;st4', 'pic=0;1;2;3;2;1', True);
  Frg2.Opt.SetColFeature('rej', 'pic=� �����������:9;0', True);
  Frg2.Opt.SetColFeature('qnt1;qnt2;qnt3;qnt4', 'bt=���������:25:r:+', True, True); //h ��� ������� ������ �� � ������� ������
  Frg2.Opt.SetColFeature('qnt1c;qnt2c;qnt3c;qnt4c', 'bt=' + S.IIf(FOpMode = mFromSgp, '��������� ���', '������� ���') +':24:r:+', FEditMode > 0);
  Frg2.Opt.SetColFeature('rej', 'bt=����������:26:r:+', FOpMode = mOtk);
  Frg2.Opt.SetColFeature('qnt1c;qnt2c;qnt3c;qnt4c', 'e=0:999999:0', FEditMode > 0, True);
end;

procedure TFrmOGjrnOrderStages.Add�ontrolClick(Sender: TObject);
var
  va: TVarDynArray;
  dt1, dt2: TDateTime;
begin
  if TControl(Sender).Name ='LbDate' then begin
    if FOpMode in [mToProd, mFromSgp, mToSgp, mOtk] then begin
      dt1:=FDtEditMin;
      if TFrmBasicInput.ShowDialog(Self, '', [], fEdit, '���� �����', 165, 65,
        [[cntDEdit,'���� �����',S.DateTimeToIntStr(Dt1) + ':' + S.DateTimeToIntStr(Date), 94]],
         [FDtEdit], va, [['']], nil
        ) > 0  //������, ���� ������ ���� ��������
      then begin
        FDtEdit:=va[0];
        Q.QSetContextValue('order_stages_dt' + S.Decode([FOpMode, 1, '1c', 2, '2c', 3, '3c', 4, '4c']), FDtEdit);
        SetAddControls;
        Frg1.RefreshGrid;
      end;
    end
    else if FOpMode in [mDelInProd] then begin
      if TFrmBasicInput.ShowDialog(Self, '', [], fEdit, '������', 165, 65,
        [[cntDEdit,'������',S.DateTimeToIntStr(EncodeDate(2024,01,01)) + ':' + S.DateTimeToIntStr(Date), 94]],
         [FDtBeg], va, [['']], nil
        ) > 0  //������, ���� ������ ���� ��������
      then begin
        FDtBeg:=EncodeDate(YearOf(va[0]), MonthOf(va[0]), 1);
        if MonthOf(va[0]) = MonthOf(Date)
          then FDtEnd:=Date
          else FDtEnd:=IncDay(IncMonth(EncodeDate(YearOf(va[0]), MonthOf(va[0]), 1), 1), -1);
        SetAddControls;
        Frg1.RefreshGrid;
      end;
    end;
  end;
end;


end.
