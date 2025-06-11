{
журнал кассы (есть первая и вторая)
отображение и ввод платежей и перемещения с кассы на кассу
}
unit uFrmCWCash;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uSettings, uString, uData, uMessages, uForms, uDBOra, V_MDI, uFrmBasicMdi, uFrDBGridEh,
  Vcl.Mask
  ;

type
  TFrmCWCash = class(TFrmBasicMdi)
    PTop: TPanel;
    BtRefresh: TSpeedButton;
    Lb_Caption: TLabel;
    PGalka: TPanel;
    ChbViewAll: TCheckBox;
    PItog1: TPanel;
    DBEditEh1: TDBEditEh;
    PItog2: TPanel;
    DBEditEh2: TDBEditEh;
    DBEditEh3: TDBEditEh;
    DBEditEh4: TDBEditEh;
    DBEditEh5: TDBEditEh;
    DBEditEh6: TDBEditEh;
    DBEditEh7: TDBEditEh;
    Frg1: TFrDBGridEh;
    Frg2: TFrDBGridEh;
    LbCaptL: TLabel;
    LbCaptR: TLabel;
    procedure FormResize(Sender: TObject);
    procedure BtRefreshClick(Sender: TObject);
    procedure ChbViewAllClick(Sender: TObject);
  private
    CashNo: Integer;
    IsCashEditable: Boolean;
    function  Prepare: Boolean; override;
    procedure ControlOnEnter(Sender: TObject); override;
    procedure ControlOnExit(Sender: TObject); override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
    procedure Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
    procedure Frg2SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
    procedure Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
    procedure Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
    function  PrepareGrids: Boolean;
    procedure SetAmounts;
    function  EditRecord(Fr: TFrDBGridEh; CashNo: Integer; Mode: TDialogType): Boolean;
  public
    Amounts: array[1..7] of Extended;
  end;

var
  FrmCWCash: TFrmCWCash;

implementation

uses
  uFrmBasicInput
  ;

{$R *.dfm}

function TFrmCWCash.PrepareGrids: Boolean;
begin
  Result := False;
  Frg1.Options := FrDBGridOptionDef + [myogSaveOptions, myogPrintGrid];// + FrDBGridOptionRefDef + [];
  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['id_$i','_id_','40'],
    ['source$s','_SOURCE','40'],
    ['receiver$s','_RECEIVER','40'],
    ['dt$d','Дата','70'],
    ['sum$f','Сумма','85', 'f=r:'],
    ['grp$s','Группа','100;w'],
    ['comm$s','Комментарий','150;w']
  ]);
  Frg1.Opt.SetTable('v_sn_cash_list');
  Frg1.Opt.SetButtons(1, 'eads', IsCashEditable);
  Frg1.InfoArray:=[];
  Frg1.OnButtonClick := Frg1ButtonClick;
  Frg1.OnSelectedDataChange := Frg1SelectedDataChange;
  Frg1.OnSetSqlParams := Frg1OnSetSqlParams;
  Frg1.Prepare;

  Frg2.Options := FrDBGridOptionDef + [myogSaveOptions, myogPrintGrid];// + FrDBGridOptionRefDef + [];
  Frg2.Opt.SetFields([
    ['id$i','_id','40'],
    ['id_$i','_id_','40'],
    ['source$s','_SOURCE','40'],
    ['receiver$s','_RECEIVER','40'],
    ['dt$d','Дата','70'],
    ['sum$f','Сумма','85', 'f=r:'],
    ['grp$s','Группа','100;w'],
    ['comm$s','Комментарий','150;w']
  ]);
  Frg2.Opt.SetTable('v_sn_cash_list');
  Frg2.Opt.SetButtons(1, 'eads', IsCashEditable);
  Frg2.InfoArray:=[];
  Frg2.OnButtonClick := Frg2ButtonClick;
  Frg2.OnSelectedDataChange := Frg2SelectedDataChange;
  Frg2.OnSetSqlParams := Frg2OnSetSqlParams;
  Frg2.Prepare;

  Frg1.RefreshGrid;
  Frg2.RefreshGrid;
  SetAmounts;
  Result := True;
end;

procedure TFrmCWCash.BtRefreshClick(Sender: TObject);
begin
  Frg1.RefreshGrid;
  Frg2.RefreshGrid;
  SetAmounts;
end;

procedure TFrmCWCash.ChbViewAllClick(Sender: TObject);
begin
  inherited;
  if FInPrepare then
    Exit;
  BtRefreshClick(nil);
end;

procedure TFrmCWCash.ControlOnEnter(Sender: TObject);
begin
  if Sender is TDBEditEh then
    TDBEditEh(Sender).Text:=FormatFloat('########0.00', Amounts[StrToInt(S.Right(TControl(Sender).Name))]);
end;

procedure TFrmCWCash.ControlOnExit(Sender: TObject);
begin
  if Sender is TDBEditEh then
    TDBEditEh(Sender).Text:=FormatFloat('#,##0.00', Amounts[StrToInt(S.Right(TControl(Sender).Name))]);
end;

procedure TFrmCWCash.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if fMode <> fNone
    then EditRecord(Fr, CashNo, fMode)
    else inherited;
end;

procedure TFrmCWCash.Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if fMode <> fNone
    then EditRecord(Fr, CashNo, fMode)
    else inherited;
end;

procedure TFrmCWCash.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
var
  IsCurrDate: Boolean;
  sr, cs: Integer;
begin
  //касса-источник для приходов и наоборот, касса-приемник для расходов, по которой возможны операции изменения
  //можно заменить на проверку на отрицательное значение кроме текущей кассы (не обязательно) и если нужно, что не депозит -9
  cs := S.IIf(CashNo = 1, -2, -1);
  //для приходов
  if Fr.IsNotEmpty then
    IsCurrDate := User.IsDataEditor or (Fr.GetValue('dt') = Date);
  if Fr.IsNotEmpty then
    sr := S.NInt(Fr.GetValue('source'));
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Fr, btnEdit, null, Fr.IsNotEmpty and IsCurrDate and ((sr = 11) or (sr = -9) or (sr = cs)));
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Fr, btnDelete, null, Fr.IsNotEmpty and IsCurrDate and ((sr = 11) or (sr = -9) or (sr = cs)));
{    TSpeedButton(P_L_Buttons.FindComponent('Bt_L_'+IntToStr(btnEdit))).Enabled:=
      P_L_Buttons.Visible and IsNotEmpty and IsCurrDate and ((sr=11)or(sr=-9)or(sr=cs));}
end;

procedure TFrmCWCash.Frg2SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
var
  IsCurrDate: Boolean;
  sr, cs: Integer;
begin
  cs:=S.IIf(CashNo = 1, -2, -1);
  if Fr.IsNotEmpty then
    IsCurrDate := User.IsDataEditor or (Fr.GetValue('dt') = Date);
  if Fr.IsNotEmpty then
    sr := S.NInt(Fr.GetValue('receiver'));
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Fr, btnEdit, null, Fr.IsNotEmpty and IsCurrDate and ((sr = 1) or (sr = -9) or (sr = cs)));
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Fr, btnDelete, null, Fr.IsNotEmpty and IsCurrDate and ((sr = 1) or (sr = -9) or (sr = cs)));
{    TSpeedButton(P_R_Buttons.FindComponent('Bt_R_'+IntToStr(btnEdit))).Enabled:=
      P_L_Buttons.Visible and IsNotEmpty and IsCurrDate and ((sr=1)or(sr=-9)or(sr=cs));}
end;

procedure TFrmCWCash.Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  SqlWhere := 'receiver = -' + IntToStr(CashNo) + S.IIFStr(not ChbViewAll.Checked, ' and source >= 0');
end;

procedure TFrmCWCash.Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  SqlWhere := 'source = -' + IntToStr(CashNo) + S.IIFStr(not ChbViewAll.Checked, ' and receiver >= 0');
end;


procedure TFrmCWCash.SetAmounts;
var
  i: Integer;
  v: Variant;
begin
  v:=Q.QSelectOneRow('select dt from sn_cash_revision_dt', []);
  Lb_Caption.Caption:='Журнал Кассы' + IntToStr(CashNo) + ' с ' + DateToStr(v[0]) + ' по '  + DateToStr(Date);
  v:=Q.QSelectOneRow('select sum1, sum1+sum2+sum9, sum1, sum2, sum9, arrivalday, spendingday from v_sn_cash_sum', []);
  for i:=1 to 7 do
    Amounts[i]:=v[i-1];
  for i:=Low(Amounts) to High(Amounts) do
    TDBEditEh(FindComponent('DBEditEh'+IntToStr(i))).Text:=formatFloat('#,##0.00', Amounts[i]);
end;

procedure TFrmCWCash.FormResize(Sender: TObject);
begin
  inherited;
  Frg1.Width := PMDIClient.ClientWidth div 2;
  LbCaptR.Left := Frg1.Width + 4;
end;

function TFrmCWCash.Prepare: Boolean;
begin
  Result := False;
  //получим номер кассы (строковая константа заканчивается соотв числом)
  CashNo := StrToInt(FormDoc[Length(FormDoc)]);
  //получим признак возможности внесения данных
  Caption := '~Журнал Кассы' + IntToStr(CashNo);
  //если открываем на редактирование, то получим блокировку
  if FormDbLock = fNone then
    Exit;
  IsCashEditable := User.Role(S.IIf(CashNo = 1, rPC_J_Cash_1_Ch, rPC_J_Cash_2_Ch)) and (Mode = fEdit);
  Cth.SetSpeedButton(BtRefresh, mybtRefresh, True);
  Cth.MakePanelsFlat(PMDIClient, []);
  Cth.AlignControls(PTop, [], True);
  Cth.AlignControls(PGalka, [], True);
  Cth.AlignControls(PItog1, [], True);
  Cth.AlignControls(PItog2, [], True);
  PItog1.Visible := (CashNo = 1);
  PItog2.Visible := (CashNo = 2);
  if not PrepareGrids then
    Exit;
  Result := True;
end;

function TFrmCWCash.EditRecord(Fr: TFrDBGridEh; CashNo: Integer; Mode: TDialogType): Boolean;
var
  va1, va2, cv, ck: TVarDynArray;
begin
  cv := [];
  ck := [];
  if CashNo = 1 then begin
    cv := cv + ['Касса2'];
    ck := ck + ['-2'];
  end
  else begin
    cv := cv + ['Касса1'];
    ck := ck + ['-1'];
  end;
  cv := cv + ['Депозит'];
  ck := ck + ['-3'];
  if Fr.Name = 'Frg1' then begin
    cv := cv + ['Прочие приходы'];
    ck := ck + ['11'];
  end
  else begin
    cv := cv + ['Прочие расходы'];
    ck := ck + ['1'];
  end;
  if Mode <> fAdd then begin
    va1 := [Fr.GetValue('dt'), VarArrayOf([Fr.GetValue(S.IIf(Fr.Name = 'Frg1', 'source', 'receiver')), VarArrayOf(cv), VarArrayOf(ck)]),
      Fr.GetValue('sum'), Fr.GetValue('comm')];
  end
  else begin
    va1 := [Date, VarArrayOf(['', VarArrayOf(cv), VarArrayOf(ck)]), null, null];
  end;
  if TFrmBasicInput.ShowDialog(Self, '', [], Mode, S.IIf(Fr.Name = 'Frg1', 'Приход', 'Расход'), 600, 100, [
    [cntDEdit, S.IIfStr(not User.IsDataEditor, ' ') + 'Дата',':'],
    [cntComboLK, S.IIfStr(Mode <> fAdd, ' ') + S.IIf(Fr.Name = 'Frg1', 'Источник', 'Назначение'),'1:400', 150],
    [cntNEdit, 'Сумма','1:4000000000:2:N'],
    [cntEdit, 'Примечание','0:400',0]],
    va1, va2, [['']], nil
  ) <= 0 then Exit;
  va1 := [Fr.GetValue('id_'), S.IIf(Fr.Name = 'Frg2', -CashNo, va2[1]), S.IIf(Fr.Name = 'Frg1', -CashNo, va2[1]), va2[0], va2[2], va2[3]];
  if Q.QIUD(Q.QFModeToIUD(Mode), 'sn_cash_payments', 'sq_sn_cash_payments', 'id$i;source$i;receiver$i;dt$d;sum$f;comm$s', va1) <> -1 then begin
    Fr.RefreshGrid;
    SetAmounts;
  end;

end;

end.
