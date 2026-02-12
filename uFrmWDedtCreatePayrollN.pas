unit uFrmWDedtCreatePayrollN;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmBasicMdi, Vcl.ExtCtrls, Vcl.StdCtrls,
  DBCtrlsEh, Vcl.ComCtrls, DateUtils, Vcl.Mask;

type
  TFrmWDedtCreatePayrollN = class(TFrmBasicMdi)
    pgcMain: TPageControl;
    ts_Divisions: TTabSheet;
    lbl1: TLabel;
    ts_Worker: TTabSheet;
    lbl2: TLabel;
    cmbWorker: TDBComboBoxEh;
    cmbPeriodD: TDBComboBoxEh;
    cmbPeriodW: TDBComboBoxEh;
    procedure cmbPeriodWChange(Sender: TObject);
  private
    Mode: Integer;
    OwnerForm: TForm;
    procedure btnOkclick(Sender: TObject); override;
    function  VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean; override;
    function  Prepare: Boolean; override;
    procedure FillWorkers;
  public
  end;

var
  FrmWDedtCreatePayrollN: TFrmWDedtCreatePayrollN;

implementation

{$R *.dfm}

uses
  uTurv,
  uMessages,
  uDBOra,
  uData,
  uString,
  uForms
  ;

procedure TFrmWDedtCreatePayrollN.cmbPeriodWChange(Sender: TObject);
begin
  if cmbPeriodD.Text <> '' then
    FillWorkers;
end;

procedure TFrmWDedtCreatePayrollN.FillWorkers;
var
  dt1, dt2: TDateTime;
begin
  S.GetDatesFromPeriodString(cmbPeriodW.Text, dt1, dt2);
  Q.QLoadToDBComboBoxEh('select distinct employee_st from v_w_employee_properties where is_terminated = 1 and dt_beg >= :dt1$d and dt_beg <= :dt2$d order by employee_st', [dt1, Turv.GetTurvEndDate(IncDay(dt2, 1))], cmbWorker, cntComboL);
  cmbWorker.ItemIndex := 0;
end;

function TFrmWDedtCreatePayrollN.VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean;
begin
  Result := (pgcMain.ActivePageIndex = 0) and (cmbPeriodD.Text = '') or (pgcMain.ActivePageIndex = 1) and ((cmbPeriodW.Text = '') or (cmbWorker.Text = ''));
end;

procedure TFrmWDedtCreatePayrollN.btnOkclick(Sender: TObject);
var
  dt1, dt2: TDateTime;
  i, j: Integer;
  va1, va2, va3: TVarDynArray2;
  va: TVarDynArray;
  Cnt: Integer;
  Msg: string;
  IdEmpl, IdDep, IdOrg: Variant;
  EmplInfo: TNamedArr;
begin
  //inherited;
  Cnt := 0;
  Msg := '';
  //для создания по всем подразделениям
  if pgcMain.ActivePageIndex = 0 then begin
    S.GetDatesFromPeriodString(cmbPeriodD.Text, dt1, dt2);
    if MyQuestionMessage('Создать расчетные ведомости за период ' + DateToStr(dt1) + ' - ' + DateToStr(dt2) + '?') <> mrYes then
      Exit;
    //получим список созданных турв за период
    va1 := Q.QLoadToVarDynArray2('select id_departament, departament, is_finalized from v_w_turv_period where dt1 = :dt1$d', [dt1]);
    //получим список ведомостей по зп, по полным подразделениям за этот период
    va2 := Q.QLoadToVarDynArray2('select id_departament from v_w_payroll_calc where dt1 = :dt1$d and id_employee is null', [dt1]);
    for i := 0 to High(va1) do begin
      if A.PosInArray(va1[i][0], va2, 0) = -1 then begin
        //если ведомость еще не создана
        if va1[i][2] <> 1 then
          //уведомление о незакрытых ТУРВ
          S.ConcatStP(Msg, va1[i][1], #13#10);
        //создаем зарплатную ведомость, если все же во время между проверками уже такая была создана, то будет ошибка уникального индекса, здесь ее не выводим
        //if Integer(va1[i, 0]) in [4,5] then  //!!! ИТ, бухгалтерия
        if Q.QIUD('i', 'w_payroll_calc', '', 'id$i;id_departament$i;dt1$d;dt2$d', [0, Integer(va1[i, 0]), dt1, dt2], False) <> -1 then
          inc(Cnt);  //увеличим количество созданных
      end;
    end;
    //сообщение
    if Msg <> '' then
      Msg := #13#10#13#10'По следующим подразделениям не закрыты ТУРВ:'#13#10 + Msg;
  end
  //для создания по выбранному работнику
  else begin
    S.GetDatesFromPeriodString(cmbPeriodW.Text, dt1, dt2);
    if MyQuestionMessage('Создать расчетные ведомости за период ' + DateToStr(dt1) + ' - ' + DateToStr(dt2) + #13#10'для работник "' + cmbWorker.Text + '"?') <> mrYes then
      Exit;
    //получм список ведомостей по уволенным, которые нужно создать
    //для каждого периода прием-увольнение будет создано не меньше одной ведомости, едина ведомость на несколько таких периодов никогда не создается.
    //(если были переходы в пределах такого периода в разныве подразделдения, то создастся по каждому подразделению)
    //!!! не совсем корректно!
{    var ide := Q.QSelectOneRow('select distinct id_employee from v_w_employee_properties where employee_st = :p$s', [cmbWorker.Text])[0];
    Q.QLoadFromQuery(
      'select id_departament, id_employee, id_organization, personnel_number from v_w_employee_properties ' +
      'where id_employee = :id_employee$i and dt_beg >= :dt1$d and dt_beg <= :dt2$d ' +
      'group by id_departament, id_employee, id_organization, personnel_number' ,
      [ide, dt1, dt2], va1
    );}
    //получим список нужных ведомостей (сгруппированных по подразделению и статусу работника)
    Q.QLoadFromQuery(
      'select id_departament, id_employee, id_organization, personnel_number from v_w_employee_properties ' +
      'where employee_st = :employee_st$s and dt_beg >= :dt1$d and dt_beg <= :dt2$d ' +
      'group by id_departament, id_employee, id_organization, personnel_number' ,
      [cmbWorker.Text, dt1, Turv.GetTurvEndDate(IncDay(dt2, 1))], va1
    );
    //получим список всех ведомостей по зп, по уволенным за этот период
    va2 := Q.QLoadToVarDynArray2('select id_departament, id_employee, id_organization, personnel_number from v_w_payroll_calc where dt1 = :dt1$d and id_employee is not null', [dt1]);
    var b := False;
    for i := 0 to High(va1) do
      if A.PosRowInArray(va1, va2, i) = -1 then
        b := True;
    if b then begin
      //получим ведомости по полным подразделениям, в которых присутствует работник с данным статусом
      Q.QLoadFromQuery(
        'select id, id_target_departament, is_finalized from v_w_payroll_calc_item where id_target_employee is null and id_employee = :id_employee$i and  dt1 = :dt1$d ' +
        'and nvl(id_organization, -100) = nvl(:id_organization$i, -100) and nvl(personnel_number, -100) = nvl(:personnel_number$s, -100)',
        [dt1, va1[1], va1[2], va1[3]], va3
      );
      b := True;
      if Length(va3) > 0 then begin
        if A.PosInArray(1, va3, 2) >= 0 then begin
          //если среди найденных ведомостей есть закрытые, то не будем создвать вообще, выдадим сообщение
          MyInfoMessage('Ведомость не будет создана, так как запись работника с этим статусом присутствует в ведомсти по подразделению со статусом "Закрыта"');
          b := False;
        end
        else begin
          //если есть незакрыте - спроим что делать
          b := MyQuestionMessage('Запись работника с этим статусом присутствует в ведомсти по подразделению и будет из нее удалена!'#13#10'Продолжить?') = mrYes;
          //если продолжаем - удалим из ведомостей по подразделениям найденные строки
          if b then
            for j := 0 to High(va3) do
              Q.QExecSql('delete from w_payroll_calc_item where id = :id$i', [va3[j, 0]]);
        end;
      end;
      //если нужно, создадим ведомости
      if b then
        for i := 0 to High(va1) do begin
          //проверим, нет ли уже такой ведомсти
          if A.PosRowInArray(va1, va2, i) = -1 then begin
            //создаем
            if Q.QIUD('i', 'w_payroll_calc', '', 'id$i;id_departament$i;id_employee$i;id_organization$i;personnel_number$s;dt1$d;dt2$d', [0, va1[i][0], va1[i][1], va1[i][2], va1[i][3], dt1, dt2], False) <> -1 then
              inc(Cnt);  //увеличим количество созданных
          end;
        end;
    end;
  end;
  //сообщение
  if Cnt = 0 then
    Msg := 'Ни одна ведомость не создана!' + Msg
  else
    Msg := 'Создан' + S.GetEnding(cnt, 'а', 'о', 'о') + ' ' + IntToStr(cnt) + ' ведомост' + S.GetEnding(cnt, 'ь', 'и', 'ей') + '.' + Msg;
  MyInfoMessage(Msg, 1);
  //обновим форму журнала
  if Cnt > 0 then
    RefreshParentForm;
  Close;
end;

function TFrmWDedtCreatePayrollN.Prepare: Boolean;
begin
  Result := False;
  Caption := '~Добавить расчетные ведомости';
  FOpt.RefreshParent := True;
  FOpt.DlgPanelStyle := dpsBottomRight;
  FOpt.StatusBarMode := stbmNone;
  FOpt.AutoAlignControls := True;
  Cth.FillComboBoxWithBiweeklyPeriods(cmbPeriodD, Date, S.IIf(User.IsDeveloper, 12, 2));
  cmbPeriodD.ItemIndex := 0;
  Cth.FillComboBoxWithBiweeklyPeriods(cmbPeriodW, Date, S.IIf(User.IsDeveloper, 12, 2));
  cmbPeriodW.ItemIndex := 0;
  Result := True;
end;


end.
