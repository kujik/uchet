{
Отчет о кадровом составе и движении кадров за указанный период
}

unit uFrmWGrepPersonal1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2, uFrmBasicInput
  ;

type
  TFrmWGrepPersonal1 = class(TFrmBasicGrid2)
  private
    function  PrepareForm: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    function  GetData: TVarDynArray2;
  public
  end;

var
  FrmWGrepPersonal1: TFrmWGrepPersonal1;

implementation

uses
  uTurv;

{$R *.dfm}

function TFrmWGrepPersonal1.PrepareForm: Boolean;
begin
  Caption:='Отчет о кадровом составе';
  Frg1.Options := Frg1.Options + [myogGridLabels, myogLoadAfterVisible];
  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['job$s','Наименование должности','250;h'],
    ['workersqnt$i','Количество работников, человек','120','f=#,##0:'],
    ['qnt1$i','Принято, чел.','80','f=#,##0:'],
    ['qnt2$i','Уволено, чел.','80','f=#,##0:'],
    ['qntvac$i','Потребность, чел.','120','f=#,##0:'],
    ['dtvac$d','Дата размещения вакансии','120']
  ]);
  Frg1.Opt.SetButtons(1,[[mbtGo],[],[mbtExcel],[mbtPrintGrid],[],[mbtGridSettings],[],[mbtCtlPanel]]);
  Frg1.Opt.SetButtonsIfEmpty([mbtGo]);
  Frg1.CreateAddControls('1', cntDTEdit, 'Период с ', 'edtd1', ':', 70, yrefC, 85);
  Frg1.CreateAddControls('1', cntDTEdit, 'по ', 'edtd2', ':', 180, yrefC, 85);
  Frg1.InfoArray:=[[
    'Отчет о кадровом составе за указанный период.'#13#10+
    'Выводится информация о количестве работающих по каждой должности (на дату окончания период отчета),'#13#10+
    'Количество принятых, уволенных за данный период в данной должности, а также'#13#10+
    'потребность в кадрах (по вакансиям, которые были открыты хотя бы один день в рассматриваемый период),'#13#10+
    'при этом если вакансий было несколько, то дата открытия проставляется последняя.'#13#10+
    'Доступна печать таблицы и выгрузка ее в Excel.'#13#10+
    ''
  ]];
  //данные из массива
  Frg1.SetInitData([]);
  Result := Inherited;
end;

procedure TFrmWGrepPersonal1.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if Tag = mbtGo then begin
    GetData;
    Fr.RefreshGrid;
  end
  else
    inherited;
end;

function TFrmWGrepPersonal1.GetData: TVarDynArray2;
var
  dt: TDateTime;
  i, j, k: Integer;
  dt1, dt2: TDateTime;
  st, st1, st2, w: string;
  v, v1, v2, jobs, vac: TVarDynArray2;
  buf: Variant;
  changed: Boolean;
  size: Integer;
begin
  Result := [];
  //выйдем, если не введены обе даты, с пустой таблицей
  if not (Cth.DteValueIsDate(Frg1.FindComponent('edtd1')) and Cth.DteValueIsDate(Frg1.FindComponent('edtd2')) and (Frg1.GetControlValue('edtd2') >= Frg1.GetControlValue('edtd1'))) then begin
    MyWarningMessage('Задайте корректный период для отчета!');
    Exit;
  end;
 dt1 := Frg1.GetControlValue('edtd1');
  dt2 := Frg1.GetControlValue('edtd2');
  //профессии   0-айди, 1-наименование, 2-количество, 3-приняты, 4-уволены, 5-потребность, 6-дата размещенияя заявки
  jobs := Q.QLoadToVarDynArray2('select id, name, 0, 0, 0, 0, null from ref_jobs order by name', []);
  //запрос. сортировка принципиальна
  v := Q.QLoadToVarDynArray2('select id_division, id_worker, workername, id_job, job, status, dt from v_j_worker_status order by workername, dt, job, id_division', []);
  //проходим по массиву статусов, отсортирован по работнику, потом по дате
  for i := 0 to High(v) do begin
    //только до второй даты - тк мы получаем состав подразделений на конечную дату, а движение кадров за период между датами
    if v[i][6] <= dt2 then begin
      //если принят или переведен
      if Integer(v[i][5]) in [1, 2] then begin
        //найдем должность в массиве
        for j := 0 to high(jobs) do
          if jobs[j][0] = v[i, 3] then begin
            //увеличим количество работающих по данной должности
            inc(jobs[j][2]);
            //если больше начальной даты, и это прием а не перевод то увеличим количество принятых
            if (v[i][6] >= dt1) and (v[i][5] = 1) then
              inc(jobs[j][3]);
            break;
          end;
      end;
      if Integer(v[i][5]) in [2, 3] then begin
        for j := 0 to high(jobs) do
          if jobs[j][0] = v[i - 1][3] then begin
            dec(jobs[j][2]);
            if (v[i][6] >= dt1) and (v[i][5] = 3) then
              inc(jobs[j][4]);
            break;
          end;
      end;
    end;
  end;
  //получим все вакансии
  vac := Q.QLoadToVarDynArray2('select id_job, qnt, dt_beg, dt_end from j_vacancy order by id_job, dt_beg', []);
  for i := 0 to High(vac) do begin
    //не вносим, если конечная дата раньше начала периода, или же начальная после конца периода
    if not ((vac[i][2] > dt2) or (vac[i][3] <> null) and (vac[i][3] < dt1)) then begin
      for j := 0 to High(jobs) do begin
        if jobs[j][0] = vac[i][0] then begin
          //просцуммируем потребность, а дату поставим последнюю из найденнных
          jobs[j][5] := jobs[j][5] + vac[i][1];
          jobs[j][6] := vac[i][2];
        end;
      end;
    end;
  end;
  //заполним поля из массива
  Frg1.SetInitData(jobs);
end;




end.


