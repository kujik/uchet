unit uFrmWGedtPayroll;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls,
  DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls, DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd,
  ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils, Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh
  ;

type
  TFrmWGedtPayroll = class(TFrmBasicGrid2)
  private
    FPayrollParams: TNamedArr;
    FIsEditable: Boolean;
    FDeletedWorkers: TVarDynArray;
    FColWidth: Integer;
    function  PrepareForm: Boolean; override;
{    function  SetLock: Boolean;
    function  LoadTurv: Boolean;
    function  LoadTurvCodes: Boolean;
    function  GetTurvCode(AValue: Variant): Variant;
    function  GetTurvCell(ARow, ADay, ANum: Integer): Variant;
    procedure PushTurvToGrid;
    procedure PushTurvCellToGrid(ARow, ADay: Integer);
    procedure PushTurvCellToDetailGrid(ARow, ADay: Integer);
    procedure SetLblDivisionText;
    procedure SetLblWorkerText;
    procedure SetLblsDetailText;
    function  FormatTurvCell(v: Variant): string;
    procedure FrgsColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
    procedure InputDialog(Mode : Integer);
    function  GetDay: Integer;
    procedure SaveDayToDB(r, d: Integer; Mode: Integer);
    procedure SaveWorkerToDB(r: Integer);
    procedure ExportToXlsxA7(Doc: Integer; Date1, Date2: Variant; AutoOpen: Boolean);
    procedure SundaysToTurv;
    procedure SendEMailToHead;
    procedure SetGridEditableMode;
}
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
  public
  end;

var
  FrmWGedtPayroll: TFrmWGedtPayroll;

implementation

uses
  uTurv,
  uLabelColors2,
  uFrmBasicInput,
  uExcel,
  uPrintReport
  ;


{$R *.dfm}

function TFrmWGedtPayroll.PrepareForm: Boolean;
var
  i, j, w1: Integer;
  v: Variant;
  wcol, fcol: string;
begin
  Result:=False;

  Caption:='Зарплатная ведомость';
  FOpt.RefreshParent := True;

  if FormDbLock = fNone then Exit;

  Q.QLoadFromQuery('select id, id_division, id_worker, dt1, dt2, divisionname, workername, office, id_method, commit from v_payroll where id = :id$i', [ID], FPayrollParams);
  if FPayrollParams.Count = 0 then begin
    MsgRecordIsDeleted;
    Exit;
  end;
{  ID_Division:=v[1];
  ID_Worker:=v[2];
  PeriodStartDate:=v[3];
  PeriodEndDate:=v[4];
  DivisionName:=S.NSt(v[5]);
  WorkerName:=S.NSt(v[6]);
  IsOffice:=v[7] = 1;;
  CalcMode:=v[8];
  Commit:=v[9] = 1;

  lbl_Caption1.Caption:=S.IIf(WorkerName<>'', WorkerName + ' (' + DivisionName + ')', DivisionName) + ' с ' +DateToStr(PeriodStartDate) + ' по ' +DateToStr(PeriodEndDate);
//  IsEditable:=Mode = fEdit;
//  lbl_ReadOnly.Visible:=IsEditable;

  Norma01:=Q.QSelectOneRow('select norm0, norm1 from payroll_norm where dt = :dt$d', [PeriodStartDate]);
  Norma:=S.IIf(IsOffice, Norma01[1], Norma01[0]);

  FPayrollParams

}

  FDeletedWorkers := [];
  FColWidth := 45;
  wcol := IntToStr(FColWidth) + ';r';
  fcol := 'f=###,###,###:';
  Frg1.Options := FrDBGridOptionDef + [myogPanelFind];
  Frg1.Opt.SetFields([
    ['id$i', '_id','40'],
    ['id_worker$i', '_id_worker', wcol],
    ['id_job$i', '_id_job', wcol],
    ['changed$i', '_changed', wcol],
    ['name$s', 'ФИО', '200;h'],
    ['job$s', 'Должность', '150;h'],
    ['blank$i', '~  № бланка', wcol],
    ['ball_m$i', '~  Оклад', wcol],
    ['turv$f', '~  ТУРВ', wcol, fcol],
    ['ball$i', '~  Расчет' + sLineBreak + '  оклада', wcol, fcol],
    ['premium_m_src$i', '~  Премия ' + sLineBreak + '  (грузчики)', wcol, fcol],
    ['premium$i', '~  Премия' + sLineBreak + '  текущая', wcol, fcol],
    ['premium_p$i', '~  Премия за' + sLineBreak + '  переработки', wcol, fcol],
    ['premium_m$i', '~  Премия' + sLineBreak + '', wcol, fcol],
    ['otpusk$i', '~  ОТ', wcol, fcol],
    ['bl$i', '~  БЛ', wcol, fcol],
    ['penalty$i', '~  Штрафы', wcol, fcol],
    ['itog1$i', '~  Итого' + sLineBreak + '  начислено', wcol, fcol],
    ['ud$i', '~  Удержано', wcol, fcol],
    ['fss$i', '~  Выплачено' + sLineBreak + '  ФСС', wcol, fcol],
    ['pvkarta$i', '~  Промежуточная' + sLineBreak + '  выплата - карта', wcol, fcol],
    ['karta$i', '~  Карта', wcol, fcol],
    ['itog$i', '~  Итого к' + sLineBreak + '  получению', wcol, fcol],
    ['sign$i', '~  Подпись', '55']
  ]);
  Frg1.Opt.SetGridOperations('u');
  Frg1.Opt.SetButtons(1, [
    [mbtSettings],[],[mbtCustom_Turv],[mbtCustom_Payroll],[mbtCard],[],[mbtExcel],
    [mbtDividorM],[mbtPrint],[mbtPrint],[mbtPrintLabels],[mbtDividorM],[],[mbtLock],
    [],
    [mbtCtlPanel]
  ]);


  Frg1.CreateAddControls('1', cntLabelClr, '', 'lblDivision', '', 4, yrefT, 800);
  Frg1.CreateAddControls('1', cntLabelClr, '', 'lblWorker', '', 4, yrefB, 800);
  Frg1.SetInitData([], '');

  Result := inherited;
  if not Result then
    Exit;
  //Frg1.DBGridEh1.TitleParams.RowHeight := 90;
{  DBGridEh1.STFilter.Visible:=True;
  DBGridEh1.STFilter.Location:=stflInTitleFilterEh;
  for i:=0 to DbGridEh1.Columns.Count - 1 do
    DBGridEh1.Columns[i].STFilter.Visible:=False;
  Gh.GetGridColumn(DBGridEh1, 'blank').STFilter.Visible:=True;}
  //ширина окна по ширине грида
  Self.Width := Frg1.GetTableWidth + 75;

  {  Self.MinWidth:=1100;
  Self.MinHeight:=300;
//  lbl_ReadOnly.Left:=Width - pnl_Right.Width - lbl_ReadOnly.Width - 50;

  //если в данной ведомости нет ни одной записи, попробуем их создать
  CreateTurvList;
  //прочитаем из БД ведомость
  GetList;}


(*
  MemTableEh1.FieldDefs.Clear;
  Mth.AddTableColumn(DBGridEh1, 'name', ftString, 400, 'ФИО', 200, True);
  Mth.AddTableColumn(DBGridEh1, 'job', ftString, 400, 'Должность', 150, True);
  Mth.AddTableColumn(DBGridEh1, 'id', ftInteger, 0, '_id', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'id_worker', ftInteger, 0, '_id_worker', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'id_job', ftInteger, 0, '_id_job', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'changed', ftInteger, 0, '_changed', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'blank', ftInteger, 0, '  № бланка', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'ball_m', ftInteger, 0, '  Оклад', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'turv', ftFloat, 0, '  ТУРВ', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'ball', ftInteger, 0, '  Расчет' + sLineBreak + '  оклада', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'premium_m_src', ftInteger, 0, '  Премия ' + sLineBreak + '  (грузчики)', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'premium', ftInteger, 0, '  Премия' + sLineBreak + '  текущая', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'premium_p', ftInteger, 0, '  Премия за' + sLineBreak + '  переработки', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'premium_m', ftInteger, 0, '  Премия' + sLineBreak + '', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'otpusk', ftInteger, 0, '  ОТ', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'bl', ftInteger, 0, '  БЛ', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'penalty', ftInteger, 0, '  Штрафы', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'itog1', ftInteger, 0, '  Итого' + sLineBreak + '  начислено', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'ud', ftInteger, 0, '  Удержано', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'ndfl', ftInteger, 0, '  НДФЛ', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'fss', ftInteger, 0, '  Выплачено' + sLineBreak + '  ФСС', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'pvkarta', ftInteger, 0, '  Промежуточная' + sLineBreak + '  выплата - карта', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'karta', ftInteger, 0, '  Карта', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'itog', ftInteger, 0, '  Итого к' + sLineBreak + '  получению', ColWidth, True);
  Mth.AddTableColumn(DBGridEh1, 'sign', ftInteger, 0, '  Подпись', ColWidth + 10, True);
//  Mth.AddTableColumn(DBGridEh1, '', ftInteger, 0, '', ColWidth, True);
  MemTableEh1.CreateDataSet;

  for i:=0 to DBGridEh1.Columns.Count-1 do begin
    if (i <= 7) then DBGridEh1.Columns[i].Color:=RGB(200,200,200);
    if (i >= 3) then DBGridEh1.Columns[i].Alignment:=taRightJustify;
    if (i >= 3) then DBGridEh1.Columns[i].Title.Orientation:=tohVertical;
    if (i > 7) then DBGridEh1.Columns[i].DisplayFormat:='###,###,###';
    DBGridEh1.Columns[i].Title.Alignment:=taCenter;
    DBGridEh1.Columns[i].OnGetCellParams:= DBGridEh1Columns0GetCellParams;
    DBGridEh1.Columns[i].OnUpdateData:= DBGridEh1Columns0UpdateData;
    if (DBGridEh1.Columns[i].Title.Caption[1] ='_') then DBGridEh1.Columns[i].Visible:=False;
  end;

//  Gh.GetGridColumn(DBGridEh1, 'turv').DisplayFormat:='###,###,###.00';
  Gh.GetGridColumn(DBGridEh1, 'sign').Visible:=False;


  DBGridEh1.Columns[0].Visible:=False;

//  DBGridEh1.Columns[6].Local:=True;

//  Gh._SetDBGridEhDisplayFormat(DBGridEh1, 'ball;itog1;itog', FloatDisplayFormat);
  //Gh._SetDBGridEhSumFooter(DBGridEh1, 'premium_m;premium;premium_p;otpusk;bl;itog1;ud;ndfl;fss;pvkarta;karta;itog', '###,###,##0');
  Gh.SetGridColumnsProperty(DBGridEh1, cptSumFooter, 'premium_m;premium;premium_p;otpusk;bl;itog1;ud;ndfl;fss;pvkarta;karta;itog', '###,###,##0');
  Gh.SetGridOptionsTitleAppearance(DBGridEh1, True);
//  Gh.SetGridOptionsTitleAppearance(DBGridEh1, False);
  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh+[dghShowRecNo];
  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh+[dghEnterAsTab];
  DBGridEh1.ShowHint:=True;
  DBGridEh1.ColumnDefValues.ToolTips:=True;
  DBGridEh1.TitleParams.RowHeight:=90;
  //DBGridEh1.TitleParams.MultiTitle:=True;
 //перемещение столбцов
  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh-[dghColumnMove];
  //изменение ширины столбцов
  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh-[dghColumnResize];
  DBGridEh1.FixedColor:=RGB(200,200,200);
//  DBGridEh1.FrozenCols:=5;
  DBGridEh1.ShowHint:=True;
  DBGridEh1.IndicatorOptions:=[gioShowRowIndicatorEh,gioShowRecNoEh];
  DBGridEh1.ReadOnly:=False;

  DBGridEh1.StFilter.Local:=True;
  DBGridEh1.SortLocal:=True;
  DBGridEh1.STFilter.Visible:=True;
  DBGridEh1.STFilter.Location:=stflInTitleFilterEh;
  for i:=0 to DbGridEh1.Columns.Count - 1 do
    DBGridEh1.Columns[i].STFilter.Visible:=False;
  Gh.GetGridColumn(DBGridEh1, 'blank').STFilter.Visible:=True;
//  DBGridEh1.Columns[7].STFilter.Visible:=True;
//  DBGridEh1.Columns.FindColumnByName('BLANK').STFilter.Visible:=True;


  w1:=75;
  for i:=0 to DBGridEh1.Columns.Count-1 do begin
    if DBGridEh1.Columns[i].Visible then w1:=w1+DBGridEh1.Columns[i].Width;
  end;
  //ширина окна по ширине грида
  Self.Width:=w1;
  Self.MinWidth:=1100;
  Self.MinHeight:=300;
//  lbl_ReadOnly.Left:=Width - pnl_Right.Width - lbl_ReadOnly.Width - 50;

  //если в данной ведомости нет ни одной записи, попробуем их создать
  CreateTurvList;
  //прочитаем из БД ведомость
  GetList;


//norma:=56;
//CalcMode:=0;

  DBGridEh1.AllowedOperations:=[alopUpdateEh];

//  Buttons:=[mybtSettings, mybtDividor, mybtCustom_Turv, mybtCustom_Payroll, mybtCard, mybtDividor, mybtExcel, mybtPrint, mybtPrint, mybtPrintLabel, mybtDividor, mybtLock];
  Buttons:=[mybtSettings, mybtDividor, mybtCustom_Turv, mybtCustom_Payroll, mybtCard, mybtDividor, mybtExcel, mybtDividorM, mybtPrint, mybtPrint, mybtPrintLabels, mybtDividorM, mybtDividor, mybtLock];
  ButtonsState:=[True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True];
  pnl_Left.Width:=Cth.CreateGridBtns(Self, pnl_Left, Buttons, ButtonsState, Bt_Click) + 5;
  Cth.GetSpeedBtn(pnl_Left, mbtCard).Hint:='Загрузить НДФЛ и карты';
  SetButtons;
  CheckEmpty;

  //установим доступность стандартных кнопок в зависимости от наличия данных в таблице
//  Cth.SetBtnAndMenuEnabled(pnl1, Pm_Grid, mbtView, IsNotEmpty);

*)
  Result:=True;
end;

{==============================================================================}

procedure TFrmWGedtPayroll.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
end;

procedure TFrmWGedtPayroll.Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
end;

procedure TFrmWGedtPayroll.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
end;

procedure TFrmWGedtPayroll.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
end;




end.
