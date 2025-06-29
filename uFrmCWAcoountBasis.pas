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
    pnlBottom: TPanel;
    btn1: TSpeedButton;
    imgInfomain: TImage;
    edtBasis: TEdit;
    nedtPrc: TDBNumberEditEh;
    btnOk: TBitBtn;
    pgcMain: TPageControl;
    tsOrders: TTabSheet;
    tsAccounts: TTabSheet;
    Frg1: TFrDBGridEh;
    Frg2: TFrDBGridEh;
    procedure pgcMainChange(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  private
    FSnCalendar: TDlg_Sn_Calendar;
    FIdAccount: Integer;
    FAccMode: Integer;  //1-���������� ���������, 2-��������� ��������, 3-������
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
  nm := edtBasis.Text;
  if pgcMain.ActivePage = tsOrders then begin
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
  for i := 1 to FSnCalendar.MemTableEh2.RecordCount do begin
    FSnCalendar.MemTableEh2.RecNo := i;
    if (FSnCalendar.MemTableEh2.Fields[0].AsInteger = id) and (FSnCalendar.MemTableEh2.Fields[1].AsString = tp) then begin
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
    'select nvl(sum(prc),0) ' + S.IIf((pgc_Main.ActivePage = ts_Orders), 'id_order', 'id_acc') + ' '+
    'from '+
    'sn_calendar_t_basis b, sn_calendar_accounts a '+
    'where '+
    'a.id = b.id_account and '+
    'id_account <> :id and '+
    S.IIf(AccMode = 3, 'a.accounttype = 3', 'a.accounttype in (1,2)') + ' and '+
    S.IIf((pgc_Main.ActivePage = ts_Orders), 'id_order', 'id_acc') + ' = :id_basis',
    VarArrayOf([IDAccount, id])
    )[0];
    }
    va2 := Q.QLoadToVarDynArray2(//      'select nvl(prc,0) ' + S.IIf((pgc_Main.ActivePage = ts_Orders), 'id_order', 'id_acc') + ', '+
//      'select nvl(prc,0) ' + S.IIf((pgc_Main.ActivePage = ts_Orders), 'id_order', 'id_acc') + ', '+
      'select nvl(prc,0), a.dt, a.account, a.supplier ' +
      'from '+
      'sn_calendar_t_basis b, v_sn_calendar_accounts a '+
      'where '+
      'a.id = b.id_account and '+
      'id_account <> :id and '+
      S.IIf(FAccMode = 3, 'a.accounttype = 3', 'a.accounttype in (1,2)') + ' and '+
      S.IIf((pgcMain.ActivePage = tsOrders), 'id_order', 'id_acc') + ' = :id_basis',
      [FIDAccount, id]
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
      nedtPrc.Value := Min(100, maxprc);
      nedtPrc.MaxValue := maxprc;
    end;
//    MaxPrc:=100-MaxPrc;
  end;
  if b then begin
    prc := nedtPrc.Value;
    FSnCalendar.MemTableEh2.Append;
    FSnCalendar.MemTableEh2.Fields[0].AsInteger := id;
    FSnCalendar.MemTableEh2.Fields[1].AsString := tp;
    FSnCalendar.MemTableEh2.Fields[2].AsString := nm;
    FSnCalendar.MemTableEh2.Fields[3].AsInteger := prc;
    FSnCalendar.MemTableEh2.Fields[4].AsFloat := round(sum / 100 * prc);
    FSnCalendar.MemTableEh2.Post;
    FSnCalendar.BasisTableGetSum;
    FSnCalendar.isBasisGridEdited := True;
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

procedure TFrmCWAcoountBasis.btnOkClick(Sender: TObject);
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
  edtBasis.Text := '';
  if Fr.IsEmpty then
    Exit;
  if Fr.Name = 'Frg1'
    then edtBasis.Text := Fr.GetValueS('ordernum') + ' | ' + Fr.GetValueS('dt_beg') + ' | ' + Fr.GetValueS('customer')
    else edtBasis.Text := Fr.GetValueS('supplier') + ' | ' + Fr.GetValueS('accountdt') + ' | ' + Fr.GetValueS('account');
  nedtPrc.Value:=100;
end;

procedure TFrmCWAcoountBasis.pgcMainChange(Sender: TObject);
begin
  inherited;
  if (pgcMain.ActivePage = tsOrders) and not Frg1.IsPrepared then begin
    Frg1.RefreshGrid;
    Frg1.Align := alNone;
    Frg1.Align := alClient;
  end;
  if (pgcMain.ActivePage = tsAccounts) and not Frg2.IsPrepared then begin
    Frg2.RefreshGrid;
  end;
end;

procedure TFrmCWAcoountBasis.ShowDialog(aSn_Calendar:TDlg_Sn_Calendar; aIdAccount: Integer; Mode: TDialogType; aAccMode:Integer);
var
  b: Boolean;
begin
  FSnCalendar:=aSn_Calendar;
  FIdAccount:=aIdAccount;
  FAccMode:=aAccMode;
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

  pgcMain.ActivePage := tsOrders;
  pgcMainChange(nil);

  Cth.SetControlVerification(nedtPrc, '0:100:0');

  //��� ����� ������� �� ����� ������ ������
  tsAccounts.TabVisible := FAccMode <> 3;

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
