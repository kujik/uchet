{
ïëàòåæè ïî 12 ìåñÿöàì çà âûáğàííûé ãîä, ñãğóïïèğîâàííûå èëè ïî ñòàòüÿì ğàõîäîâ, èëè ïî èõ ãğóïïàì.
òàêæå âûâîäèòñÿ äèàãğàììà è îáùàÿ çàäîëæåííîñòü.
}

unit uFrmCGrepPaymentsByMonth;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmBasicGrid2, Vcl.ExtCtrls, Vcl.StdCtrls,
  uFrDBGridEh, VCLTee.Series, VCLTee.TeEngine, MemTableDataEh,
  VCLTee.Chart, DBCtrlsEh, uData, VclTee.TeeGDIPlus, Vcl.Mask, VCLTee.TeeProcs;

type
  TFrmCGrepPaymentsByMonth = class(TFrmBasicGrid2)
    Chart1: TChart;
    Series1: TLineSeries;
    Series2: TPieSeries;
    procedure Frg1DbGridEh1ColEnter(Sender: TObject);
  private
    function  PrepareForm: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); override;
    procedure SetChart;
    procedure LoadData;
  public
  end;

var
  FrmCGrepPaymentsByMonth: TFrmCGrepPaymentsByMonth;

implementation
uses

  uWindows,
  uString,
  uDBOra
  ;

{$R *.dfm}

function  TFrmCGrepPaymentsByMonth.PrepareForm: Boolean;
var
  i, j: Integer;
  va: TVarDynArray;
  va2, data: TVarDynArray2;
begin
  Caption:='Ïëàòåæè ïî ìåñÿöàì';
  Frg1.Options := Frg1.Options - [myogSaveOptions, myogSorting, myogPanelFilter, myogColumnFilter];
  va2 := [['name$s', 'Íàèìåíîâàíèå','300']];
  for i := 1 to 12 do
    va2 := va2 + [['s' + IntToStr(i) + '$i', MonthsRu[i], '70', 'f=f:']];
  va2 := va2 + [['sall$i', 'Âñåãî', '80', 'f=f:']];
  Frg1.Opt.SetFields(va2);
  Frg1.Opt.SetButtons(1, [[mbtRefresh],[],[mbtCtlPanel]]);
  Frg1.CreateAddControls('1', cntComboL, 'Çà ãîä', 'CbYear', '', 4, yrefC, 60);
  Frg1.CreateAddControls('1', cntCheck, 'Ïî ñòàòüÿì ğàñõîäîâ', 'ChbItems', '', 68, yrefT, 220);
  Frg1.CreateAddControls('1', cntCheck, 'Ïî ãğóïïàì ñòàòåé', 'ChbGroups', '', 68, yrefB, 220);
  Frg1.CreateAddControls('1', cntNEdit, 'Îò÷å÷êà', 'NeSplice', '', 220 + 40,  yrefC, 60);
  Frg1.CreateAddControls('1', cntNEdit, 'Íà÷àëüíàÿ çàäîëæåííîñòü', 'NeInitialDebt', '', 220 + 50 + 200, yrefC, 60);

  Q.QLoadToDBComboBoxEh(
    'select y from ('+
    '  (select extract(year from dtpaid) y from sn_calendar_payments) '+
    '  union '+
    '  (select extract(year from dt) y from sn_cash_payments c where c.receiver = 1) '+
    ') where y is not null group by y order by y desc',
    [], TDBComboBoxEh(Frg1.FindComponent('CbYear')), cntComboL);
  Frg1.SetControlValue('NeInitialDebt', S.NNum(Q.QSelectOneRow('select sum from sn_initialdebt', [])[0]));

  Frg1.Opt.SetDataMode(myogdmFromArray);
  Result := Inherited;
  Frg1.LoadSourceDataFromArray([]);
end;

procedure TFrmCGrepPaymentsByMonth.Frg1DbGridEh1ColEnter(Sender: TObject);
begin
  inherited;
  SetChart;
end;

procedure TFrmCGrepPaymentsByMonth.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if Tag = mbtRefresh then begin
    LoadData;
    Q.QExecSql('update sn_initialdebt set sum = :sum', [Frg1.GetControlValue('NeInitialDebt')]);
    Exit;
  end
  else inherited;
end;

procedure TFrmCGrepPaymentsByMonth.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
  if Frg1.InAddControlChange then
    Exit;
  Frg1.InAddControlChange := True;
  if A.InArray(TControl(Sender).Name, ['ChbGroups', 'ChbItems']) then begin
     TDBCheckBoxEh(Sender).Checked := True;
     if TControl(Sender).Name ='ChbGroups'
       then Frg1.SetControlValue('ChbItems', 0)
       else Frg1.SetControlValue('ChbGroups', 0)
  end;
  Frg1.InAddControlChange := False;
end;

procedure TFrmCGrepPaymentsByMonth.SetChart;
var
  i,j: Integer;
  v: Variant;
  st: string;
begin
  Chart1.Series[0].Visible:=False;
  Chart1.Series[1].Visible:=True; //not ChartType;
{  if ChartType then begin
    Chart1.Series[0].Clear;
    Chart1.Series[0].AddXY(1, MemTableEh1.FieldByName('s1').AsFloat);
    Chart1.Series[0].AddXY(2, MemTableEh1.FieldByName('s2').AsFloat);
    Chart1.Series[0].AddXY(3, MemTableEh1.FieldByName('s3').AsFloat);
    Chart1.Series[0].AddXY(4, MemTableEh1.FieldByName('s4').AsFloat);
    Chart1.Series[0].AddXY(5, MemTableEh1.FieldByName('s5').AsFloat);
    Chart1.Series[0].AddXY(6, MemTableEh1.FieldByName('s6').AsFloat);
    Chart1.Series[0].AddXY(7, MemTableEh1.FieldByName('s7').AsFloat);
    Chart1.Series[0].AddXY(8, MemTableEh1.FieldByName('s8').AsFloat);
    Chart1.Series[0].AddXY(9, MemTableEh1.FieldByName('s9').AsFloat);
    Chart1.Series[0].AddXY(10, MemTableEh1.FieldByName('s10').AsFloat);
    Chart1.Series[0].AddXY(11, MemTableEh1.FieldByName('s11').AsFloat);
    Chart1.Series[0].AddXY(12, MemTableEh1.FieldByName('s12').AsFloat);
  end
  else begin}
  j := Frg1.DBGridEh1.Col;
  if (j > 1) and (j < 14) then
    st := 's' + IntToStr(j - 1)
  else
    st := 'sall';
  Chart1.Series[1].Clear;
  for i := 0 to Frg1.MemTableEh1.RecordsView.MemTableData.RecordsList.Count - 1 do begin
    v := Frg1.MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues[st, dvvValueEh];
    if v = null then
      v := 0;
    Chart1.Series[1].Add(v, Frg1.MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['name', dvvValueEh]);
  end;
  TPieSeries(Chart1.Series[1]).OtherSlice.Value :=  S.NNum(Frg1.GetControlValue('NeSplice'));
//  end;
end;

procedure TFrmCGrepPaymentsByMonth.LoadData;
var
  i, j: Integer;
  y: Variant;
  va: TVarDynArray;
  va2, data: TVarDynArray2;
  sql: string;
begin
  if Frg1.GetControlValue('ChbItems') = 1
  then
  sql :=
  'select'+
  '  ie_name as name, max(s1) as s1, max(s2) as s2, max(s3) as s3, max(s4) as s4, max(s5) as s5, max(s6) as s6, max(s7) as s7, '+
  ' max(s8) as s8, max(s9) as s9, max(s10) as s10, max(s11) as s11, max(s12) as s12, sum(sumall) as sall '+
  'from '+
  '('     +
  'select ' +
  'a.ie_name as ie_name,'+
  '(case when a.month = 1 then a.sum end) as s1,'+
  '(case when a.month = 2 then a.sum end) as s2,'+
  '(case when a.month = 3 then a.sum end) as s3,'+
  '(case when a.month = 4 then a.sum end) as s4,'+
  '(case when a.month = 5 then a.sum end) as s5,'+
  '(case when a.month = 6 then a.sum end) as s6,'+
  '(case when a.month = 7 then a.sum end) as s7,'+
  '(case when a.month = 8 then a.sum end) as s8,'+
  '(case when a.month = 9 then a.sum end) as s9,'+
  '(case when a.month = 10 then a.sum end) as s10,'+
  '(case when a.month = 11 then a.sum end) as s11,'+
  '(case when a.month = 12 then a.sum end) as s12,'+
  'a.sum as sumall '+
  'from '+
  '( '+
  '(select to_char(p.dtpaid, ''mm'') month, sum(p.sum) sum1, sum(round(p.sum/((a.nds+100)/100))) sum, max(i.name) as ie_name'+
  '  from'+
  '    sn_calendar_payments p, sn_calendar_accounts a, ref_expenseitems i'+
  '  where'+
  '    p.id_account = a.id and i.id = a.id_expenseitem and to_char(p.dtpaid,''yyyy'') = :year'+
  '  group by i.name, to_char(p.dtpaid, ''mm'')) '+
  'union '+
  '(select to_char(c.dt, ''mm'') month, sum(c.sum) sum1, sum(c.sum) sum, ''Ïğî÷èå ğàñõîäû'' as ie_name '+
  '  from'+
  '    sn_cash_payments c'+
  '  where'+
  '    c.receiver = 1 and  to_char(c.dt, ''yyyy'') = :year2'+
  '  group by to_char(c.dt, ''mm'')) '+
  ') a'+
  ')'+
  'group by ie_name'
  else
  sql:=
  'select'+
  '  ie_name as name, sum(s1) as s1, max(s2) as s2, max(s3) as s3, max(s4) as s4, max(s5) as s5, max(s6) as s6, max(s7) as s7, '+
  ' max(s8) as s8, max(s9) as s9, max(s10) as s10, max(s11) as s11, max(s12) as s12, sum(sumall) as sall '+
  'from '+
  '('     +
  'select ' +
  'a.ie_name as ie_name,'+
  '(case when a.month = 1 then a.sum end) as s1,'+
  '(case when a.month = 2 then a.sum end) as s2,'+
  '(case when a.month = 3 then a.sum end) as s3,'+
  '(case when a.month = 4 then a.sum end) as s4,'+
  '(case when a.month = 5 then a.sum end) as s5,'+
  '(case when a.month = 6 then a.sum end) as s6,'+
  '(case when a.month = 7 then a.sum end) as s7,'+
  '(case when a.month = 8 then a.sum end) as s8,'+
  '(case when a.month = 9 then a.sum end) as s9,'+
  '(case when a.month = 10 then a.sum end) as s10,'+
  '(case when a.month = 11 then a.sum end) as s11,'+
  '(case when a.month = 12 then a.sum end) as s12,'+
  'a.sum as sumall '+
  'from '+
  '( '+
  '(select to_char(p.dtpaid, ''mm'') month, sum(p.sum) sum1, sum(round(p.sum/((a.nds+100)/100))) sum, max(g.name) as ie_name'+             //RoundTo(nedt_Sum.Value / ((nds + 100) /100), -2);
  '  from'+
  '    sn_calendar_payments p, sn_calendar_accounts a, ref_expenseitems i, ref_grexpenseitems g'+
  '  where'+
  '    p.id_account = a.id and i.id = a.id_expenseitem and to_char(p.dtpaid,''yyyy'') = :year and g.id = i.id_group'+
  '  group by g.name, to_char(p.dtpaid, ''mm'')) '+
  'union '+
  '(select to_char(c.dt, ''mm'') month, sum(c.sum) sum1, sum(c.sum) sum,''Ïğî÷èå ğàñõîäû'' as ie_name '+
  '  from'+
  '    sn_cash_payments c'+
  '  where'+
  '    c.receiver = 1 and  to_char(c.dt, ''yyyy'') = :year2'+
  '  group by to_char(c.dt, ''mm'')) '+
  ') a'+
  ')'+
  'group by ie_name'
  ;
  y := Frg1.GetControlValue('CbYear');
  if y = null then
    Exit;
  va2 := Q.QLoadToVarDynArray2(sql, [y, y]);
  Frg1.LoadSourceDataFromArray(va2);
  Frg1.Repaint;
  Frg1.SetStatusBarCaption('Çàäîëæåííîñòü íà ñåãîäíÿ: ' + FormatFloat('###,###,####,##0', S.NNum(
    Q.QSelectOneRow('select sum(case when status = 0 then round(sum) else 0 end) as debtsum from sn_calendar_payments', [])[0])+
    S.NNum(Frg1.GetControlValue('NeInitialDebt')))
  );
  SetChart;
end;

end.
