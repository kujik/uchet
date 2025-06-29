{
1:
Создание сразу всех зарплатных ведомостей за один период ТУРВ
Вызывается из журнала зарплатных ведомостей (модальный режим окна)
создаем записи только для тех подразделений, для которых в данном периоде созданы ТУРВ
в рабочем режиме делаем только за прошлый период и только по закрытым ТУРВ,
для девелопера за любой период и для незакрытых

2:
Создаем ведомости по конкретному работнику
созданы будут ведомости по всем подразделениям, в которых работник числился за данный период,
и от одного до двух периодов - текущий и прошедший
для девелопера за один, но любой период.
из ведомостей по подразделениям за данный период строки с этим работником будут удалены

создаются только записи в таблице payroll, без наполнения

при создании не проверяем наличие, если есть то не создастся из-за уникальности

выведем инфу сколько создано

}
unit D_CreatePayroll;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_Normal, Vcl.StdCtrls, Vcl.Mask,
  DBCtrlsEh, Vcl.Buttons, DateUtils,
  Vcl.ComCtrls
  ;

type
  TDlg_CreatePayroll = class(TForm_Normal)
    Bt_OK: TBitBtn;
    Bt_Cancel: TBitBtn;
    PageControl1: TPageControl;
    ts_Divisions: TTabSheet;
    ts_Worker: TTabSheet;
    lbl1: TLabel;
    dedt_Dt1: TDBDateTimeEditEh;
    dedt_Dt2: TDBDateTimeEditEh;
    lbl2: TLabel;
    chb_Prev: TDBCheckBoxEh;
    chb_Curr: TDBCheckBoxEh;
    dedt_W: TDBDateTimeEditEh;
    cmb_Worker: TDBComboBoxEh;
    procedure Bt_OKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Mode: Integer;
    OwnerForm: TForm;
    //mode = 1  - создание ведомостей за прошедший период по подразделениям
    function ShowDialog(aOwner: TForm; aMode: Integer): Integer;
  end;

var
  Dlg_CreatePayroll: TDlg_CreatePayroll;

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

procedure TDlg_CreatePayroll.Bt_OKClick(Sender: TObject);
var
  dt1, dt2: TDateTime;
  i, j, periods: Integer;
  v, v1, v2: Variant;
  va1, va2: TVarDynArray2;
  cnt: Integer;
  b, b1: Boolean;
  st: string;
  wid: Integer;
  dep: TVarDynArray;
begin
  inherited;
  cnt:=0;
  st:= '';
  //для создания по всем подразделениям
  if PageControl1.ActivePageIndex = 0 then begin
    //дата начала периода должна быть корректной датой, но произвольной, по ней высчитываем начало турв
    if not Cth.DteValueIsDate(dedt_Dt1) then Exit;
    if MyQuestionMessage('Создать зарплатные ведомости?') <> mrYes then Exit;
    //поставим дату начала и конца периода турв исходя из даты начала
    //используется для отладки, в реальном режиме даты изменять нельзя
    dedt_Dt1.Value:=Turv.GetTurvBegDate(dedt_Dt1.Value);
    dedt_Dt2.Value:=Turv.GetTurvEndDate(dedt_Dt1.Value);
    //получим список созданных турв за период
    va1:=Q.QLoadToVarDynArray2(
      'select id_division, name, commit from v_turv_period where dt1 = :dt1$d',
      [dedt_Dt1.Value]
    );
    //получим список ведомостей по зп, по полным подразделениям за этот период
    va2:=Q.QLoadToVarDynArray2(
      'select id_division from v_payroll where dt1 = :dt1$d and id_worker is null',  //and id_division = :id_division$i
      [dedt_Dt1.Value]
    );
    for i:=0 to High(va1) do begin
      b:=True;
      for j:=0 to High(va2) do
        if va1[i, 0] = va2[j, 0] then
          begin b:=False; Break; end;
      //если не нашли в созданных, то проверим закрыт ли турв
      if b then
        if va1[i,2] <> 1 then begin
          if not User.IsDeveloper then b:=False;                   //не создаем для незакрытого турв
          st:=st +  va1[i,1] + #13#10;  //в собщение
        end;
      if b then begin
  //      if QIUD('i', 'payroll', 'sq_payroll', 'id;id_division$i;dt1$d;dt2$d', [0, va1[i,0], dedt_Dt1.Value, dedt_Dt2.Value], False) <> -1
        //создаем зарплатную ведомость, если все же во время между проверками уже такая была создана, то будет ошибка уникального индекса, здесь ее не выводим
        if Q.QIUD('i', 'payroll', 'sq_payroll', 'id;id_division;dt1;dt2', [0, Integer(va1[i,0]), dedt_Dt1.Value, dedt_Dt2.Value], False) <> -1
          then inc(cnt);  //увеличим количество созданных
      end;
    end;
    //сообщение
    if st<>''
      then st:= #13#10#13#10'По следующим подразделениям не закрыты ТУРВ:'#13#10 + st;
  end
  //для создания по выбранному работнику
  else begin
    if (not Cth.DteValueIsDate(dedt_W))or(not chb_Prev.Checked and not chb_Curr.Checked and not dedt_W.Visible) then Exit;
    //не создаем ведомости по работнику, если хотя бы у кого-то открыты по подразделениям любые ведомости
    //тк создание может привести к удалению из существующей ведомости
    v:=Q.QSelectOneRow('select login, username from adm_locks where lock_docum = :docum$s', [myfrm_Dlg_Payroll]);
    if v[0]<> null Then begin
      MyInfoMessage('Зарплатные ведомости (у Вас или у другого пользователя) открыты для редактирования.'#13#10'Пока они не будут закрыты, создание ведомостей по одному работнику невозможно!');
      Exit;
    end;
    if MyQuestionMessage('Создать зарплатные ведомости?') <> mrYes then Exit;
    wid:=Cth.GetControlValue(cmb_Worker);
    va1:=Turv.GetWorkerStatusArr(wid);
//  Result:=QLoadToVarDynArray2('select dt, status, id_division, id_job from j_worker_status where id_worker = :id$i order by dt desc, id_division, id_job', id);
    for periods:=0 to 1 do begin
      dt1:= MinDateTime;
      //получим дату начала периода
      //если виден ввод даты, то только один период и это значение
      if dedt_W.Visible and (periods = 0) then dt1:= Turv.GetTurvBegDate(dedt_W.Value);
      //иначе, если отмечено галками, прошлый и текущий период
      if not(dedt_W.Visible) and (chb_Prev.Checked) and (periods = 0) then dt1:= dedt_Dt1.Value;
      if not(dedt_W.Visible) and (chb_Curr.Checked) and (periods = 1) then dt1:= Turv.GetTurvBegDate(Date);
      if dt1 = MinDateTime then continue;
      //конец периода
      dt2:=Turv.GetTurvEndDate(dt1);
      //массив затронутых подразделений
      dep:=[];
      //проход по массиву статусов работника
      //в обратном поряядке, тк нам здесь надо проход от старых дат, а массив отсортирован от новых к более старым
      for i:=High(va1) downto 0 do begin
        //после периода, выходим
        if va1[i][0] > dt2 then Break;
        //до начала или в первый день - выбираем последнее подразделение
        if (va1[i][0] <= dt1) and (Integer(va1[i][1]) in [1,2]) then dep:=[va1[i][2]];
        //после начала и до конца периода - добавляем каждое подразделение куда принят/переведен
        if (va1[i][0] > dt1) and (Integer(va1[i][1]) in [1,2]) then dep:=dep + [va1[i][2]];
      end;
      for i:=0 to High(dep) do begin
        //удалим строки с таким работником из ведомостей (только из ведомостей по отделам, а не по работникам!)
        Q.QExecSql('delete from payroll_item i where '+
          'id_division = :id_division$i and id_worker = :id_worker$i and dt = :dt$d ' +
          'and (select id_worker from payroll where i.id_payroll = id) is null'
          ,[dep[i], wid, dt1]);
        //создадим ведомость по работнику в каждом найденном подразделении за данный период
        if Q.QIUD('i', 'payroll', 'sq_payroll', 'id;id_division$i;dt1;dt2;id_worker', [0, dep[i], dt1, dt2, wid], False) <> -1
          then inc(cnt);  //увеличим количество созданных
      end;
    end;
  end;
  //сообщение
  if cnt = 0
    then st:= 'Ни одна ведомость не создана!' + st
    else st:= 'Создан' + S.GetEnding(cnt, 'а', 'о', 'о') + ' ' + IntToStr(cnt) + ' ведомост' + S.GetEnding(cnt, 'ь','и','ей') + '.' + st;
  MyInfoMessage(st);
  //обновим форму журнала
  OwnerForm.Refresh;
  Close;
end;

function TDlg_CreatePayroll.ShowDialog(aOwner: TForm; aMode: Integer): Integer;
begin
  Mode:=AMode;
  OwnerForm:=aOwner;
  Cth.SetBtn(Bt_Ok, mybtOk, False);
  Cth.SetBtn(Bt_Cancel, mybtCancel, False);
  //даты для отделов по текущему периоду
  dedt_Dt1.Value:=Turv.GetTurvBegDate(IncDay(Turv.GetTurvBegDate(Date), -1));
  dedt_Dt2.Value:=Turv.GetTurvEndDate(dedt_Dt1.Value);
  //даты для ведомости по работнику - текущий и предыдущий периоды
//  chb_Prev.Caption:='с ' + DateToStr(Turv.GetTurvBegDate(IncDay(Turv.GetTurvBegDate(dedt_Dt1.Value), -1)))+ ' по ' + DateToStr(IncDay(Turv.GetTurvBegDate(dedt_Dt2.Value), -1));
  chb_Prev.Caption:='с ' + DateToStr(dedt_Dt1.Value) + ' по ' + DateToStr(dedt_Dt2.Value);
  chb_Curr.Caption:='с ' + DateToStr(Turv.GetTurvBegDate(Date)) + ' по ' + DateToStr(Turv.GetTurvEndDate(Date));
  //менять даты для отделов и вводить произвольную для работнику разрешим только разработчику и администратору дянных (для отладки)
  dedt_W.Value:=Turv.GetTurvBegDate(Date);
  dedt_Dt1.Enabled:=User.IsDeveloper or User.IsDataEditor;
  dedt_Dt2.Enabled:=dedt_Dt1.Enabled;
  dedt_W.Visible:=dedt_Dt1.Enabled;
  //список работников
  Q.QLoadToDBComboBoxEh('select w.f || '' '' || w.i || ''  '' || w.o as name, id from ref_workers w order by name', [], cmb_Worker, cntComboLK);


  {  if Mode = 1 then begin
//    lbl1.Caption:='Создать зарплатные ведомости по подразделениям.';
    //даты по прошлому периоду турв
    dedt_Dt1.Value:=Turv.GetTurvBegDate(IncDay(Turv.GetTurvBegDate(Date), -1));
    dedt_Dt2.Value:=Turv.GetTurvEndDate(dedt_Dt1.Value);
    ShowModal;
  end;}
  ShowModal;
end;


end.
