{
����� �� ������� ��������� ��� ����� (��� ��� �����, ��� ������ ����) �
������� ��� � ������� ��������� � ������� �������������� �����
}

unit uFrmCWAcoountBasis;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmBasicMdi, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.Buttons, Vcl.Mask, DBCtrlsEh, DateUtils, Math,
  uData, D_Sn_Calendar, uFrDBGridEh
  ;

type
  TFrmCWAcoountBasis = class(TFrmBasicMdi)
    PBottom: TPanel;
    SpeedButton1: TSpeedButton;
    ImgInfomain: TImage;
    EBasis: TEdit;
    NePrc: TDBNumberEditEh;
    BtOk: TBitBtn;
    PgMain: TPageControl;
    TsOrders: TTabSheet;
    TsAccounts: TTabSheet;
    Frg1: TFrDBGridEh;
    Frg2: TFrDBGridEh;
    procedure PgMainChange(Sender: TObject);
    procedure BtOkClick(Sender: TObject);
  private
    Sn_Calendar: TDlg_Sn_Calendar;
    IdAccount: Integer;
    AccMode:Integer;  //1-���������� ���������, 2-��������� ��������, 3-������
    procedure InsertToAccount;
    procedure FrgOnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); virtual;
    procedure FrgAddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); virtual;
    procedure FrgSelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); virtual;
  public
    procedure ShowDialog(aSn_Calendar:TDlg_Sn_Calendar; aIdAccount: Integer; Mode: TDialogType; aAccMode:Integer);
  end;

var
  FrmCWAcoountBasis: TFrmCWAcoountBasis;

implementation

uses
  uString,
  uForms,
  uMessages,
  uDBOra
  ;

{$R *.dfm}

procedure TFrmCWAcoountBasis.InsertToAccount;
var
  i, j, id: Integer;
  st, tp, nm, actst: string;
  sum: extended;
  prc, maxprc: Integer;
  b: Boolean;
  va2: TVarDynArray2;
begin
  nm := EBasis.Text;
  if PgMain.ActivePage = TsOrders then begin
    if Frg1.IsEmpty then
      Exit;
    tp := '�����';
    id := Frg1.GetValueI('id_order');
    sum := Frg1.GetValueF('sum');
  end
  else begin
    if Frg2.IsEmpty then
      Exit;
    tp := '����';
    id := Frg2.GetValueI('id');
    sum := Frg2.GetValueF('sum');
  end;
  //��������, ���� �� ��� ����� ��������� � ����� � ������� �����, � �� ���� ������� ���� ����
  b:=True;
  for i := 1 to Sn_Calendar.MemTableEh2.RecordCount do begin
    Sn_Calendar.MemTableEh2.RecNo := i;
    if (Sn_Calendar.MemTableEh2.Fields[0].AsInteger = id) and (Sn_Calendar.MemTableEh2.Fields[1].AsString = tp) then begin
      b := False;
      Break;
    end;
  end;
  if b then begin
    //������� ������� ��� ���������� � ������������ ����� ��������� (�� ����� ����� ������)
    //��� ���� ��� ���������� � ��������� � �������� ��������� ��������� ������ - ������� �����������,
    //� ��� ������� ��������� ������ �� ������ �������
    {
    //(��� ����� �� ������������ ������, ��� ��� � ������� �� ��������)
    MaxPrc :=QSelectOneRow(
    'select nvl(sum(prc),0) ' + S.IIf((Pg_Main.ActivePage = Ts_Orders), 'id_order', 'id_acc') + ' '+
    'from '+
    'sn_calendar_t_basis b, sn_calendar_accounts a '+
    'where '+
    'a.id = b.id_account and '+
    'id_account <> :id and '+
    S.IIf(AccMode = 3, 'a.accounttype = 3', 'a.accounttype in (1,2)') + ' and '+
    S.IIf((Pg_Main.ActivePage = Ts_Orders), 'id_order', 'id_acc') + ' = :id_basis',
    VarArrayOf([IDAccount, id])
    )[0];
    }
    va2 := Q.QLoadToVarDynArray2(//      'select nvl(prc,0) ' + S.IIf((Pg_Main.ActivePage = Ts_Orders), 'id_order', 'id_acc') + ', '+
//      'select nvl(prc,0) ' + S.IIf((Pg_Main.ActivePage = Ts_Orders), 'id_order', 'id_acc') + ', '+
      'select nvl(prc,0), a.dt, a.account, a.supplier ' +
      'from '+
      'sn_calendar_t_basis b, v_sn_calendar_accounts a '+
      'where '+
      'a.id = b.id_account and '+
      'id_account <> :id and '+
      S.IIf(AccMode = 3, 'a.accounttype = 3', 'a.accounttype in (1,2)') + ' and '+
      S.IIf((PgMain.ActivePage = TsOrders), 'id_order', 'id_acc') + ' = :id_basis',
      [IDAccount, id]
    );
    maxprc := 0;
    st := '';
    for i := 0 to High(va2) do begin
      maxprc := maxprc + va2[i][0];
      S.ConcatStP(st, '���� �� ' + S.NSt(va2[i][3]) + ' �' + S.NSt(va2[i][2]) + '  ��������������� ' + VartoStr(va2[i][1]), #13#10);
    end;
    st := #13#10'� �������� ��������� �:'#13#10 + st;
    if maxprc >= 100 then begin
      MyInfoMessage('��� ������ �� ����� ���� ������� � ���� � �������� ���������, ��� ��� ��� ��������� ������� � ������ �����!' + st);
      b := False;
    end
    else if (maxprc > 0) and (prc > 100 - maxprc) then begin
      MyInfoMessage('��� ������ ����� ���� ������� � ���� � �������� ���������, ��� ������� ����������� �������� �� �����' + IntToStr(100 - maxprc) + '!' + st);
      b := False;
      NePrc.Value := Min(100, maxprc);
      NePrc.MaxValue := maxprc;
    end;
//    MaxPrc:=100-MaxPrc;
  end;
  if b then begin
    prc := NePrc.Value;
    Sn_Calendar.MemTableEh2.Append;
    Sn_Calendar.MemTableEh2.Fields[0].AsInteger := id;
    Sn_Calendar.MemTableEh2.Fields[1].AsString := tp;
    Sn_Calendar.MemTableEh2.Fields[2].AsString := nm;
    Sn_Calendar.MemTableEh2.Fields[3].AsInteger := prc;
    Sn_Calendar.MemTableEh2.Fields[4].AsFloat := round(sum / 100 * prc);
    Sn_Calendar.MemTableEh2.Post;
    Sn_Calendar.BasisTableGetSum;
    Sn_Calendar.isBasisGridEdited := True;
  end;
end;

procedure TFrmCWAcoountBasis.FrgOnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
var
  dt: TDatetime;
begin
  if not Cth.DteValueIsDate(TDBDateTimeEditEh(Fr.FindComponent('DeDt')))
    then dt := IncMonth(Date, -1)
    else dt := Fr.GetControlValue('DeDt');
  Fr.SetSqlParameters('dt$d', [dt]);
end;

procedure TFrmCWAcoountBasis.BtOkClick(Sender: TObject);
begin
  InsertToAccount;
end;

procedure TFrmCWAcoountBasis.FrgAddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
  if (TControl(Sender).Name = 'ChbWeek') and (Fr.GetControlValue('ChbWeek') = 1) then
    TDBDateTimeEditEh(Fr.FindComponent('DeDt')).Value := IncWeek(Date, -1);
  if (TControl(Sender).Name = 'ChbMonth') and (Fr.GetControlValue('ChbMonth') = 1) then
    TDBDateTimeEditEh(Fr.FindComponent('DeDt')).Value := IncMonth(Date, -1);
  if Fr.IsPrepared then
    Fr.RefreshGrid;
end;

procedure TFrmCWAcoountBasis.FrgSelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
  EBasis.Text := '';
  if Fr.IsEmpty then
    Exit;
  if Fr.Name = 'Frg1'
    then EBasis.Text := Fr.GetValueS('ordernum') + ' | ' + Fr.GetValueS('dt_beg') + ' | ' + Fr.GetValueS('customer')
    else EBasis.Text := Fr.GetValueS('supplier') + ' | ' + Fr.GetValueS('accountdt') + ' | ' + Fr.GetValueS('account');
  NePrc.Value:=100;
end;

procedure TFrmCWAcoountBasis.PgMainChange(Sender: TObject);
begin
  inherited;
  if (PgMain.ActivePage = TsOrders) and not Frg1.IsPrepared then begin
    Frg1.RefreshGrid;
    Frg1.Align := alNone;
    Frg1.Align := alClient;
  end;
  if (PgMain.ActivePage = TsAccounts) and not Frg2.IsPrepared then begin
    Frg2.RefreshGrid;
  end;
end;

procedure TFrmCWAcoountBasis.ShowDialog(aSn_Calendar:TDlg_Sn_Calendar; aIdAccount: Integer; Mode: TDialogType; aAccMode:Integer);
var
  b: Boolean;
begin
  Sn_Calendar:=aSn_Calendar;
  IdAccount:=aIdAccount;
  AccMode:=aAccMode;
  FormDoc := Self.Name;
  Cth.MakePanelsFlat(Self, []);
  MyFormOptions := [myfoModal, myfoDialog, myfoSizeable];
  if Length(Frg1.Opt.Sql.Fields) = 0 then begin
    Frg1.Options := FrDBGridOptionDef + [myogSaveOptions, myogSorting, myogPanelFilter];
    Frg1.Opt.SetFields([
      ['id_order','_id','40'],
      ['path','_path','40'],
      ['year','_year','40'],
      ['dt_beg','����','70'],
      ['ordernum','�����','100'],
      ['customer','��������','120;w;h'],
      ['sum','�����','80']
    ]);
    Frg1.Opt.SetTable('v_sn_orders');
    Frg1.Opt.SetWhere('where dt_beg >= :dt$d');
    Frg1.Opt.SetButtons(1, 'p');
    Frg1.CreateAddControls('1', cntDTEdit, '�:', 'DeDt', '', 25, yrefC, 80);
    Frg1.CreateAddControls('1', cntCheck, '�� ������', 'ChbWeek', '', -1, yrefC, 80, -1);
    Frg1.CreateAddControls('1', cntCheck, '�� �����', 'ChbMonth', '', -1, yrefC, 80, -1);
    Frg1.ReadControlValues;
    Frg1.OnSetSqlParams := FrgOnSetSqlParams;
    Frg1.OnAddControlChange := FrgAddControlChange;
    Frg1.OnSelectedDataChange := FrgSelectedDataChange;
    Frg1.Prepare;
  end;

  if Length(Frg2.Opt.Sql.Fields) = 0 then begin
    Frg2.Options := FrDBGridOptionDef + [myogSaveOptions, myogSorting, myogPanelFilter];
    Frg2.Opt.SetFields([
      ['id','_id','40'],
      ['filename','_filename','40'],
      ['supplier','���������','120;w;h'],
      ['accountdt','����','70'],
      ['account','����','120;w;h'],
      ['sum','�����','80']
    ]);
    Frg2.Opt.SetTable('v_sn_calendar_accounts');
    Frg2.Opt.SetWhere('where accountdt >= :dt$d');
    Frg2.Opt.SetButtons(1, 'p');
    Frg2.CreateAddControls('1', cntDTEdit, '�:', 'DeDt', '', 25, yrefC, 80);
    Frg2.CreateAddControls('1', cntCheck, '�� ������', 'ChbWeek', '', -1, yrefC, 80);
    Frg2.CreateAddControls('1', cntCheck, '�� �����', 'ChbMonth', '', -1, yrefC, 80);
    Frg2.ReadControlValues;
    Frg2.OnSetSqlParams := FrgOnSetSqlParams;
    Frg2.OnAddControlChange := FrgAddControlChange;
    Frg2.OnSelectedDataChange := FrgSelectedDataChange;
    Frg2.Prepare;
  end;

  PgMain.ActivePage := TsOrders;
  PgMainChange(nil);

  Cth.SetControlVerification(NePrc, '0:100:0');

  //��� ����� ������� �� ����� ������ ������
  TsAccounts.TabVisible:=AccMode <> 3;

  FOpt.InfoArray := [[
   '�������� ���������-��������� ��� �����.'#13#10+
   ''#13#10+
   '�������� ����� �������� ������ � ������ �����. ��� ������������ �� ��������������� ��������.'#13#10+
   '��� �������� ������ � �������� ������ �� ������ ���������� ���� ������ ������ ������,'#13#10+
   '������ ������ �������� ������ ��� ����� ��� ������ ���������, ��������� ��� ����� �����.'#13#10+
   '���� ������ � ��� �� ������������ � ��� ����������, �������� ������ ������� ����� � �������� � ���� ��������� ���.'#13#10+
   ''#13#10+
   '��� �������� � ���� ���������� ���������, ������� ������� ��� ������������� (� ������ ������ ����, �� ��������� 100%),'#13#10+
   '� �������� ������ ">>>".'#13#10+
   '������ � ���� ���������, ������� ��� ���� � ������ ������ � ������ ������ ���� �� ����, ������!'#13#10+
   ''#13#10
  ]];
  Self.ShowModal;
end;


end.
