unit uFrmWGedtPayrollCash;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls,
  ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls, MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd,
  MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils, Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uFrmBasicGrid2, uFrDBGridEh, uFrmBasicMdi
  ;

type
  TFrmWGedtPayrollCash = class(TFrmBasicGrid2)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FPayrollParams: TNamedArr;
    FIsEditable: Boolean;
    FDeletedWorkers: TVarDynArray;
    FColWidth: Integer;
    FIsChanged: Boolean;
    FIsEditableAdd, FIsEditableAll: Boolean;
    function  PrepareForm: Boolean; override;
    function  GetDataFromDb: Integer;
    function  GetCaption(Colored: Boolean = False): string;
    procedure SetButtons;
    procedure SetColumns;
    procedure SavePayroll;
    function  GetDataFromCalc: Integer;
    procedure CommitPayroll;
    procedure CalculateAll;
    procedure CalculateRow(Row:Integer);
//    procedure PrintGrid;
//    procedure ExportToXlsxA7;
    procedure SetEditableAll;

    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); override;
    procedure Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string); override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
  public
  end;

var
  FrmWGedtPayrollCash: TFrmWGedtPayrollCash;

implementation

{$R *.dfm}

uses
  uMessages,
  uForms,
  uDBOra,
  uTurv,
  uFrmBasicInput,
  uExcel,
  uPrintReport,
  XlsMemFilesEh,
  Printers,
  PrViewEH,
  uModule,
  uSys,
  uFrmMain,
  uFrmWDedtPayrollCalcMethod
  ;

const

  cFieldsS =
    'id$i;id_employee$i;id_jobn$i;' +
    'pay_cash$f;banknotes$s';
  cFieldsL =
    'employee$s;job$s;changed$i;temp$i';

  cmbtDeduction = 1001;
  cmbtCard = 1002;
  cmbt1C = 1003;
  cmbtEditAll = 1004;


function TFrmWGedtPayrollCash.PrepareForm: Boolean;
var
  i, j, w1: Integer;
  v: Variant;
  wcol, fcol: string;
begin
  Result:=False;

  Caption:='Ведомость к выдаче';
  FOpt.RefreshParent := True;

  if FormDbLock = fNone then Exit;

  Q.QLoadFromQuery('select id, id_employee, id_departament, dt1, dt2, employee, departament, from v_w_payroll_cash where id = :id$i', [ID], FPayrollParams);
  if FPayrollParams.Count = 0 then begin
    MsgRecordIsDeleted;
    Exit;
  end;

  FDeletedWorkers := [];
  Frg1.Options := FrDBGridOptionDef + [myogPanelFind, myogColumnResize, myogPanelfind] - [myogColumnFilter];

  //определим поля
  FColWidth := 45;
  wcol := IntToStr(FColWidth) + ';r';
  Frg1.Opt.SetFields([
    ['id$i', '_id','40'],
    ['id_employee$i', '_id_employee', wcol],
    ['id_job$i', '_id_job', wcol],
    ['changed$i', '_changed', wcol],
    ['temp$i', '_temp', wcol],
    ['employee$s', 'ФИО', '200;h'],
    ['jobe$s', 'Должность', '200;h'],
    ['pay_cash$f', 'Итого к'#13#10' получению', 100, 'f=###,###,###:'],
    ['banknotes$s', 'Купюры', 200],
    ['sign$i', 'Подпись', '55', 'i']
  ]);
  Frg1.Opt.SetGridOperations('u');
  Frg1.Opt.SetButtons(1, [
    [mbtRefresh, Mode = fEdit, 'Обновить данные'],[],
{    [mbtDividorM],
    [cmbt1C, True, True, 'Загрузка данных из 1С', '1c'],
    [cmbtCard, True, True, 'Загрузить НДФЛ и карты', 'card'],
    [cmbtDeduction, True, True, 'Загрузить удержания', 'r_minus'],
    [mbtDividorM],
    //[mbtDividorM],[mbtPrint],[mbtPrintGrid],[mbtDividorM],
    [],[mbtLock],
    [], [-mbtExcel, True],
    [],[-cmbtEditAll, True, 'Разрешить редактирование всех полей'],}
    [],[mbtCtlPanel]
  ]);
  Frg1.Opt.ButtonsNoAutoState := [0];

  Frg1.CreateAddControls('1', cntLabelClr, GetCaption(True), 'lblDivision', '', 4, yrefT, 800);
  Frg1.CreateAddControls('1', cntLabelClr, '', 'lblInfo', '', 4, yrefB, 800);
  Frg1.SetInitData([], '');

  Frg1.InfoArray := [[
    'Ведомость к перечислению.'#13#10#13#10
  ]];
  Result := inherited;
  if not Result then
    Exit;

  //ширина окна по ширине грида
  Self.Width := Frg1.GetTableWidth + 75;

  //прочитаем из БД ведомость
  GetDataFromDb;
  //если ведомость пуста- выполним первоначальную загрузка по данным турв
  if Frg1.GetCount(False) = 0 then
    GetDataFromCalc;
  SetButtons;

  Result:=True;
end;

procedure TFrmWGedtPayrollCash.FormClose(Sender: TObject; var Action: TCloseAction);
var
  rn, i, res: Integer;
  changed: Boolean;
begin
  inherited;
{  //выйдем, если закрытие происходит при подготовке данных, например, из-за нарушения блокировки
  if FInPrepare then
   Exit;
  if FIsChanged then begin
    res:=myMessageDlg('Ведомость была изменена!'#13#10'Сохранить данные?', mtConfirmation, mbYesNoCancel);
    if res = mrYes then begin
      SavePayroll;
      RefreshParentForm;
    end
    else if res = mrCancel then begin
      Action:=caNone;
      Exit;
    end;
  end;}
end;



function TFrmWGedtPayrollCash.GetDataFromDb: Integer;
//прочитаем ведомость (все данные) из БД и заполним ими сетку
var
  na : TNamedArr;
begin
  Q.QLoadFromQuery(Q.QSIUDSql('a', 'v_w_payroll_cash_item', cFieldsS + ';' + cFieldsL) + ' where id_payroll_cash = :id$i order by employee, job',
    [ID], na
  );
  Frg1.LoadData(na);
end;

function TFrmWGedtPayrollCash.GetCaption(Colored: Boolean = False): string;
begin
  Result := S.IIFStr(Colored, '$FF0000') + S.IIf(FPayrollParams.G('employee') <> null, FPayrollParams.G('employee'), 'Все работники') +
    S.IIFStr(Colored, '$000000') + ' с' + S.IIFStr(Colored, '$FF00FF') +' ' + DateToStr(FPayrollParams.G('dt1')) +
    S.IIFStr(Colored, '$000000') + ' по ' + S.IIFStr(Colored,  '$FF00FF') + DateToStr(FPayrollParams.G('dt2'));
end;

procedure TFrmWGedtPayrollCash.SavePayroll;
var
  i, j: Integer;
  f, fn, va: TVarDynArray;
begin
  //запишем метод расчета
  Q.QBeginTrans(True);
  Q.QExecSql('update w_payroll_cash set is_finalized = :p3$i where id = :id$i', [FPayrollParams.G('is_finalized'), ID]);
  //удалим из БД всех, кого удаляли из списка при нажатии кнопки ТУРВ
  if Length(FDeletedWorkers) > 0 then
    Q.QExecSql('delete from w_payroll_Cash_item where id in (' + A.Implode(FDeletedWorkers, ',') + ')', []);
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    if Frg1.GetValueI('id', i, False) = 0 then begin
      var idn := Q.QIUD('i', 'w_payroll_Cash_item', '', 'id$i;id_payroll_cash$i', [-1, ID]);
      Frg1.SetValue('id', i, False, idn);
    end;
    f := A.Explode(cFieldsS, ';');
    va := [];
    for j := 0 to High(f) do
    fn := A.Explode(f[j],'$') ;
    for j := 0 to High(f) do begin
      va := va + [Frg1.GetValue(A.Explode(f[j],'$')[0], i, False)];
    end;
    Q.QIUD('u', 'w_payroll_cash_item', '', cFieldsS, va);
  end;
  Q.QCommitOrRollback(True);
end;

procedure TFrmWGedtPayrollCash.SetButtons;
var
  i: Integer;
  NoNorms: Boolean;
begin
{
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtRefresh, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtDeduction, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtCard, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtLock, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbt1C, null, False);
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtEditAll, null, False);
  Frg1.DbGridEh1.ReadOnly := True;
  if Mode = fView then begin
    Frg1.SetControlValue('lblInfo', '$000000Только просмотр.');
  end
  else if FPayrollParams.G('is_finalized') = 1 then begin
    Frg1.SetControlValue('lblInfo', '$00FF00Ведомость закрыта, только просмотр.');
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtLock, null, True);
  end
  else begin
    Frg1.SetControlValue('lblInfo', '$FF00FFВвод данных.');
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtRefresh, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtDeduction, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtCard, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtLock, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbt1C, null, True);
    Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, cmbtEditAll, null, True);
    Frg1.DbGridEh1.ReadOnly := False;
  end;
  Cth.SetButtonsAndPopupMenuCaptionEnabled(Frg1, mbtLock, S.IIf(FPayrollParams.G('is_finalized') = 1, 'Отменить закрытие ведомости', 'Закрыть ведомость'), null);
  SetColumns;
  Frg1.DbGridEh1.Invalidate;    }
end;


procedure TFrmWGedtPayrollCash.SetColumns;
begin
{  Frg1.Opt.SetColFeature('*', 'e', False, False);
  Frg1.Opt.SetColFeature('1', 'e', True, False);
  if FIsEditableAll then
    Frg1.Opt.SetColFeature('*', 'e', True, False);
  Frg1.SetColumnsVisible;}
end;

procedure TFrmWGedtPayrollCash.CommitPayroll;
begin
{  if MyQuestionMessage(S.IIf(S.NInt(FPayrollParams.G('is_finalized')) = 1, 'Снять статус "Закрыта" для ведомости?', 'Поставить статус "Закрыта" для ведомости?')) <> mrYes then
    Exit;
  FPayrollParams.SetValue(0, 'is_finalized', IIf(S.NInt(FPayrollParams.G('is_finalized')) = 1, 0, 1));
  FIsChanged := True;
  SetButtons;}
end;


procedure TFrmWGedtPayrollCash.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if A.InArray(FieldName, ['employee', 'job']) then
      Params.Background := clmyGray;
  if A.InArray(FieldName, ['pay_cash']) then
      Params.Background := RGB(220, 255, 190);
  if A.InArray(FieldName, ['pay_cash']) and (Frg2.GetValueF(FieldName) < 0) then
      Params.Background := clRed;
end;

procedure TFrmWGedtPayrollCash.Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
  FIsChanged := True;
  Frg1.SetValue('changed', 1);
end;

procedure TFrmWGedtPayrollCash.Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string);
begin
  if Mode <> dbgvCell then
    Exit;
  CalculateRow(Row - 1);
end;


procedure TFrmWGedtPayrollCash.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  Handled := True;
  case Tag of
    mbtRefresh:
      if MyQuestionMessage('Загрузить данные из ТУРВ?') = mrYes then
        GetDataFromCalc;
{    cmbtCard:
      if MyQuestionMessage('Загрузить НДФЛ и карты?') = mrYes then
        GetNdflFromExcel;
    cmbtDeduction:
      if MyQuestionMessage('Загрузить удержания?') = mrYes then
        GetDeductionsFromExcel;}
//    mbtExcel:
//      ExportToXlsxA7;
//    mbtPrintGrid:
//      PrintGrid;
    mbtLock:
      CommitPayroll;
  else
    Handled := False;
  end;
  if Handled then
    SetButtons;
end;


function TFrmWGedtPayrollCash.GetDataFromCalc: Integer;
//читаем данные из по нажатию соотв кнопки
var
  i, j, k: Integer;
  st1, st2, st3: string;
  v1, v2: Variant;
  b: Boolean;
  NoData: Boolean;
  na, na1, na2: TNamedArr;

  MsgDel, MsgIns, MsgChg: string;
  flds: TVarDynArray2;
  flds1, flds2: TVarDynArray;

begin
  //загружаем данные только в режиме редактирования
  if Mode <> fEdit then
    Exit;

  //поля, по кторым сравниваем для сопоставления данных в турв и гшриде
  flds1 := ['id_employee', 'id_organization', 'personnel_number'];
  //поля для заголовка сообщания об изменениях
  flds2 := ['employee', 'organization', 'personnel_number'];

  if FPayrollParams.G('id_employee') <> null then
    Q.QLoadFromQuery(
      'select id_employee, id_organization, personnel_number, employee, organization, total_pay, null as temp ' +
      'from v_w_payroll_calc_item where id_employee = :p1$i and id_organization = :p2$i and personnel_number = :p3$i and dt1 = :dt1$d and id_target_employee is not null ' +
      'order by employee',
      [FPayrollParams.G('id_employee'), FPayrollParams.G('id_organization'), FPayrollParams.G('personnel_number'),  FPayrollParams.G('dt1')],
      na1
    )
  else
    Q.QLoadFromQuery(
      'select id_employee, id_organization, personnel_number, ' +
      'max(employee) as employee, max(organization) as organization, sum(total_pay) as total_pay, null as temp ' +
      'from v_w_payroll_calc_item where dt1 = :dt1$d and id_target_employee is null ' +
      'group by id_employee, id_organization, personnel_number order by employee',
      [FPayrollParams.G('dt1')],
      na1
    );

  NoData := Frg1.GetCount = 0;

  //заполним то что загружается из турв, остальные данные ранее загруженными из бд, удалим строки из ведомости, которых в турв теперь нет

  //получим для удобства работы данные из грида - они там сейчас те, что загрузились из БД
  na := Frg1.ExportToNa('', False);
  MsgDel := '';
  MsgIns := '';
  MsgChg := '';
  //найдем те строки в гриде, которых более нет в турв
  for i := 0 to na.Count - 1 do begin
    na.SetValue(i, 'temp', -1);
    st1 := '';
    for k := 0 to High(flds1) do
      S.ConcatStP(st1, na.G(i, flds1[k]).AsString, '|');
    b := False;
    for j := 0 to na1.Count - 1 do begin
      st2 := '';
      for k := 0 to High(flds1) do
        S.ConcatStP(st2, na1.G(j, flds1[k]).AsString, '|');
      if st1 = st2 then begin
        b := True;
        //сохраним во временной поле массива турв позицию из грида (из загруженной расчетной ведомости)
        na1.SetValue(j, 'temp', i);
        na.SetValue(i, 'temp', j);
        Break;
      end;
    end;
    //если не нашли в гриде - айди в массив, и данные в сообщение
    if not b then begin
      //данные строки для сообщения
      st1 := '';
      for k := 0 to High(flds2) do
        S.ConcatStP(st1, na.G(i, flds2[k]).AsString, ' | ');
      S.ConcatStP(MsgDel, st1, #13#10);
      //в массив удаленных - только те, которые загружены из БД
      if na.G(i, 'id') <> null then
        FDeletedWorkers := FDeletedWorkers + [na.G(i, 'id')];
      FIsChanged := True;
    end;
  end;

  //пройдем по данным, загруженным из турв
  for i := 0 to na1.Count - 1 do begin
    //если строки, которая есть в турв, нет в ведомости
    if na1.G(i, 'temp').AsIntegerM = -1 then begin
      //данные строки для сообщения
      st1 := '';
      for k := 0 to High(flds2) do
        S.ConcatStP(st1, na1.G(i, flds2[k]).AsString, ' | ');
      S.ConcatStP(MsgIns, st1, #13#10);
      //добавим строку
      na.IncLength;
      na.SetNull(na.High);
      //установим поля и итоговые данные из турв
      for k := 0 to High(na1.F) do
        na.SetValue(na.High, na1.F[k], na1.G(i, na1.F[k]));
    end;
  end;

  //удалим позиции в ведомости, которые пропали из турв
  for i := na.High downto 0 do
    if na.G(i, 'temp') = -1 then begin
      Delete(na.V, i ,1);
    end;

  //пройдем по массиву ведомости, по тем строкам, для которых есть данные турв (а значит могли быть изменения)
  for i := na.High downto 0 do begin
    j := na.G(i, 'temp').AsIntegerM;
    if j <> -1 then begin
      if na.G(i, 'total_pay') <> na1.G(j, 'total_pay') then begin
        st2 :=  ':   "' + na.G(i, 'total_pay')  + '" -> "' + na1.G(j, 'total_pay') + '""';
        na.SetValue(i, 'total_pay', na1.G(j, 'total_pay'));
      end
      else
        st2 := '';
      if st2 <> '' then begin
        st1 := '';
        for k := 0 to High(flds2) do
          S.ConcatStP(st1, na.G(i, flds2[k]).AsString, ' | ');
        S.ConcatStP(MsgChg, st1 + st2);
      end;
    end;
  end;

  //загрузим данные в грид
  Frg1.LoadData(na);
//!!!  CalculateAll;

  if MsgIns + MsgDel + MsgChg = '' then begin
    MyInfoMessage('Изменений в ведомости не было.');
  end
  else begin
    FIsChanged := True;
    MyInfoMessage(
      'Данные обновлены.'#13#10#13#10 +
      S.IIFStr(MsgIns <> '', 'Внесены записи:'#13#10 + MsgIns + #13#10#13#10) +
      S.IIFStr(MsgDel <> '', 'Удалены записи:'#13#10 + MsgDel + #13#10#13#10) +
      S.IIFStr(MsgChg <> '', 'Изменены записи:'#13#10 + MsgChg),
      1
    );
  end;

end;

procedure TFrmWGedtPayrollCash.SetEditableAll;
begin
  if Frg1.DbGridEh1.ReadOnly then
    Exit;
  if User.IsDeveloper then
    FIsEditableAll := not FIsEditableAll;
  SetColumns;
end;

procedure TFrmWGedtPayrollCash.CalculateAll;
var
  i: Integer;
begin
  for i := 0 to Frg1.GetCount(False) - 1 do
    CalculateRow(i);
end;

procedure TFrmWGedtPayrollCash.CalculateRow(Row: Integer);
begin
{  if Row = -1 then
    Row := Frg1.MemTableEh1.RecNo - 1;
  Frg1.SetValue('pay_cash', Row, False, Round(
    Frg1.GetValueF('total_pay', Row, False) - Frg1.GetValueF('deduct_enf', Row, False) - Frg1.GetValueF('deduct_ndfl', Row, False) - Frg1.GetValueF('pay_fss', Row, False) - Frg1.GetValueF('pay_adv', Row, False) - Frg1.GetValueF('pay_card', Row, False)
  ));}
end;




end.
