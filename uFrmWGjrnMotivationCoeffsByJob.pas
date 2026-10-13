{
Журнал "Коэффициенты по должностям" (04.10.2026, см. !алгоритмы.txt) - по образцу "Грубые замечания по
должностям" (uFrmWGjrnMotivationRemarks.pas), но для коэффициентов (критериев эффективности) из общего
справочника "Мотивация - Коэффициенты" (uFrmWGjrnMotivationCoefficients.pas).

Frg1 - список активных (внутренних) должностей (w_jobs_internal, вью v_w_motivation_jobs_coeffs) с
количеством привязанных критериев, СУММОЙ ДОЛЕЙ вознаграждения по ним и состоянием суммы
("Ок" / "Не хватает до 100%" / "Больше 100%" / "Нет критериев") - сразу видно, у каких должностей доли
не сходятся.

Frg2 (в RowDetailPanel выбранной должности) - критерии этой должности (w_motivation_coefficient_for_job,
вью v_w_motivation_coefficient_for_job, см. SQL/d_motivation.sql), отсортированные по pos (порядок
отображения критериев для данной должности, свой у каждой должности). У каждого критерия задана доля
вознаграждения (weight - доля 0..1, на экране в процентах).

ДОЛИ ВСЕХ КРИТЕРИЕВ ДОЛЖНОСТИ ВМЕСТЕ ДОЛЖНЫ ДАВАТЬ РОВНО 100%. Так как критерии добавляются и правятся по
одному, форма поддерживает это правило так:
- сумма никогда не может стать БОЛЬШЕ 100% - при добавлении/изменении доли значение, при котором сумма
  превысила бы 100%, не принимается (сообщение с указанием, сколько свободно);
- сумма МЕНЬШЕ 100% допускается (пока набор критериев не доделан), но явно помечена: в заголовке
  детальной таблицы ("Сумма долей: X% (Не хватает до 100%)") и в списке должностей слева; то же
  предупреждение выводится в "Мотивация - Тест" (uFrmWMotivationTest.pas);
- при добавлении критерия в диалоге по умолчанию предлагается остаток до 100%;
- кнопка "Привести к 100%" - пропорционально пересчитывает текущие доли так, чтобы сумма стала 100%
  (если все доли пусты - то же, что "Поровну"); кнопка "Поровну" - делит 100% поровну между всеми
  критериями. Обе работают через хранимую процедуру p_w_motivation_job_weights_fix (остаток от
  округления до 4 знаков достаётся критерию с наибольшей долей, сумма получается ровно 100%).

Кнопки Frg2 (доступны при наличии rW_Mtvn_Coeffs_Ch - те же права, что у справочника коэффициентов):
- "Добавить" - выбор коэффициента из общего справочника (еще не привязанного к этой должности) и доли
  вознаграждения; новый критерий встаёт в конец списка (pos = max + 1);
- "Изменить" - изменение доли вознаграждения выбранного критерия;
- "Удалить" - удаляет только привязку к должности (сам коэффициент в общем справочнике остаётся),
  доли остальных автоматически НЕ пересчитываются (сумма станет меньше 100% - см. выше);
- "Выше"/"Ниже" - меняют порядок (pos) критерия в рамках ТЕКУЩЕЙ должности; pos задан отдельно для каждой
  должности (одно и то же значение параллельно существует у разных должностей), поэтому общая
  p_ExchangePositions здесь не подходит - перестановка отдельным запросом с учётом id_job_internal
  (как в uFrmWGjrnMotivationRemarks.pas, DoMovePos).
}

unit uFrmWGjrnMotivationCoeffsByJob;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils, Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uNamedArr, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh
  ;

type
  TFrmWGjrnMotivationCoeffsByJob = class(TFrmBasicGrid2)
  private
    function  PrepareForm: Boolean; override;
    procedure Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    function  GetWeightsSumPct(AExcludeId: Variant): Double;
    procedure RefreshAll;
    procedure DoAdd(var Fr: TFrDBGridEh);
    procedure DoEditWeight(var Fr: TFrDBGridEh);
    procedure DoDelete(var Fr: TFrDBGridEh);
    procedure DoMovePos(var Fr: TFrDBGridEh; ADirection: Integer);
    procedure DoFixWeights(var Fr: TFrDBGridEh; AMode: Integer);
  public
  end;

var
  FrmWGjrnMotivationCoeffsByJob: TFrmWGjrnMotivationCoeffsByJob;

implementation

uses
  uWindows, uFrmBasicInput
  ;

{$R *.dfm}

const
  cWeightsEps = 0.005; //допуск при сравнении сумм долей в процентах (доли хранятся с точностью до 0.01%)

function TFrmWGjrnMotivationCoeffsByJob.PrepareForm: Boolean;
var
  LChRole: Boolean;
begin
  Caption := 'Коэффициенты по должностям';
  LChRole := User.Role(rW_Mtvn_Coeffs_Ch);

  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['name','Должность','300'],
    ['coeffs_count$i','Крите-'#13#10'риев','60'],
    ['weights_pct$f','Сумма долей,'#13#10'%','90','f=r'],
    ['weights_state_name','Состояние суммы','160'],
    ['comm','Комментарий','300;h']
  ]);
  Frg1.Opt.SetTable('v_w_motivation_jobs_coeffs');
  Frg1.Opt.SetWhere('where active = 1 order by name');
  Frg1.Opt.SetButtons(1,[[mbtRefresh],[],[mbtGridSettings]]);

  Frg2.Opt.Caption := 'Критерии';
  Frg2.Options := Frg2.Options + [myogGridLabels];
  Frg2.Opt.SetFields([
    ['id$i','_id','40'],
    ['id_job_internal$i','_id_job_internal','40'],
    ['id_coefficient$i','_id_coefficient','40'],
    ['pos$i','_pos','40'],
    ['name','Критерий','300'],
    ['is_personal$i','Пер-'#13#10'сональ-'#13#10'ный','60','pic'],
    ['weight_pct$f','Доля возна-'#13#10'граждения, %','100','f=r'],
    ['description$s','Описание','400;h']
  ]);
  Frg2.Opt.SetTable('v_w_motivation_coefficient_for_job', 'w_motivation_coefficient_for_job', 'id');
  Frg2.Opt.SetWhere('where id_job_internal = :id_job_internal$i order by pos, id');
  Frg2.Opt.SetButtons(1,[[mbtRefresh],[],
    [mbtAdd, LChRole],[mbtEdit, LChRole],[mbtDelete, LChRole],[],
    [mbtMoveUp, LChRole],[mbtMoveDown, LChRole],[],
    [-mbtCustom_MotivationWeightsNormalize, LChRole, 'Привести к 100%'],
    [-mbtCustom_MotivationWeightsEqual, LChRole, 'Поровну'],[],
    [mbtGridSettings]]);

  Frg1.InfoArray:=[[Caption + #13#10#13#10 +
    'Список (внутренних) должностей слева, справа для выбранной должности - привязанные к ней'#13#10 +
    'коэффициенты (критерии эффективности) из общего справочника ("Мотивация - Коэффициенты") с долей'#13#10 +
    'вознаграждения у каждого и порядком отображения (кнопки "Выше"/"Ниже").'#13#10 +
    'Доли всех критериев должности вместе должны давать ровно 100%. Сумма больше 100% не принимается;'#13#10 +
    'сумма меньше 100% допускается, пока набор критериев не доделан, но помечена в списке должностей и'#13#10 +
    'в заголовке критериев. Кнопка "Привести к 100%" пропорционально пересчитывает текущие доли,'#13#10 +
    'кнопка "Поровну" делит 100% поровну между всеми критериями должности. При добавлении критерия'#13#10 +
    'по умолчанию предлагается остаток до 100%.'#13#10 +
    'Удаление критерия убирает только привязку к должности (в общем справочнике он остаётся) - доли'#13#10 +
    'остальных критериев при этом не пересчитываются.'#13#10
  ]];

  Result := Inherited;
end;

function TFrmWGjrnMotivationCoeffsByJob.GetWeightsSumPct(AExcludeId: Variant): Double;
//сумма долей критериев текущей должности в процентах (без критерия с заданным id, если он указан)
var
  v: Variant;
begin
  if VarIsNull(AExcludeId) then
    v := Q.QLoadValue('select round(nvl(sum(weight), 0) * 100, 2) from w_motivation_coefficient_for_job ' +
      'where id_job_internal = :ij$i', [Frg1.ID])
  else
    v := Q.QLoadValue('select round(nvl(sum(weight), 0) * 100, 2) from w_motivation_coefficient_for_job ' +
      'where id_job_internal = :ij$i and id <> :id$i', [Frg1.ID, AExcludeId]);
  if VarIsNull(v) then
    Result := 0
  else
    Result := v;
end;

procedure TFrmWGjrnMotivationCoeffsByJob.RefreshAll;
//после любого изменения обновляем и список должностей (колонки суммы/состояния), и детальную таблицу
begin
  Frg1.RefreshGrid;
  Frg1.SetRowDetailPanelSize;
end;

procedure TFrmWGjrnMotivationCoeffsByJob.Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
var
  vr: Variant;
begin
  Fr.SetSqlParameters('id_job_internal$i', [Frg1.ID]);
  Fr.Opt.Caption := 'Критерии: ' + Frg1.GetValueS('name');
  if VarIsNull(Frg1.ID) then Exit;
  //QLoadRow: массив по числу полей, при отсутствии записи - все элементы Null
  vr := Q.QLoadRow('select weights_pct, weights_state_name from v_w_motivation_jobs_coeffs where id = :id$i', [Frg1.ID]);
  if not VarIsNull(vr[0]) then
    Fr.Opt.Caption := Fr.Opt.Caption + '. Сумма долей: ' + FormatFloat('0.##', S.NNum(vr[0])) + '% (' + VarToStr(vr[1]) + ')';
end;

procedure TFrmWGjrnMotivationCoeffsByJob.DoAdd(var Fr: TFrDBGridEh);
var
  na: TNamedArr;
  Names, Ids: TVarDynArray;
  va: TVarDynArray;
  i: Integer;
  LSum, LRemain, LShare: Double;
  LNewPos: Variant;
begin
  LSum := GetWeightsSumPct(Null);
  LRemain := Max(0, 100 - LSum);
  //коэффициенты общего справочника, ещё не привязанные к этой должности
  Q.QLoad('select c.id, c.name from w_motivation_coefficients c ' +
    'where not exists (select 1 from w_motivation_coefficient_for_job f ' +
    'where f.id_job_internal = :id_job$i and f.id_coefficient = c.id) order by c.pos',
    [Frg1.ID], na);
  if na.Count = 0 then begin
    MyInfoMessage('Все коэффициенты общего справочника уже привязаны к этой должности.');
    Exit;
  end;
  SetLength(Names, na.Count);
  SetLength(Ids, na.Count);
  for i := 0 to na.Count - 1 do begin
    Names[i] := na.GetValue(i, 'name');
    Ids[i] := na.GetValue(i, 'id');
  end;

  if TFrmBasicInput.ShowDialog(Self, '', [], fAdd,
       '~Добавить критерий должности', 450, 160,
       [[cntComboLK, 'Коэффициент', '1:300'],
        [cntNEdit, 'Доля вознаграждения, %', '0:100:2:N']],
       [VarArrayOf(['', VarArrayOf(Names), VarArrayOf(Ids)]), LRemain],
       va,
       [['Сумма долей уже привязанных критериев: ' + FormatFloat('0.##', LSum) + '%.'#13#10 +
         'Доля по умолчанию - остаток до 100%. Сумма долей не может быть больше 100%.']],
       nil
     ) < 0 then Exit;
  if VarToStr(va[0]) = '' then Exit;

  LShare := S.NNum(va[1]);
  if LSum + LShare > 100 + cWeightsEps then begin
    MyWarningMessage('Сумма долей критериев не может быть больше 100%.'#13#10 +
      'Сейчас распределено ' + FormatFloat('0.##', LSum) + '%, свободно ' + FormatFloat('0.##', LRemain) + '%.'#13#10 +
      'Уменьшите долю или освободите её у других критериев.');
    Exit;
  end;

  LNewPos := Q.QLoadValue('select nvl(max(pos), 0) + 1 from w_motivation_coefficient_for_job where id_job_internal = :id$i', [Frg1.ID]);
  if VarIsNull(LNewPos) then LNewPos := 1;
  if Q.QSave('I', 'w_motivation_coefficient_for_job', '', 'id$i;id_job_internal$i;id_coefficient$i;pos$i;weight$f',
       [Null, Frg1.ID, va[0], LNewPos, RoundTo(LShare / 100, -4)], False) < 0 then
    MyWarningMessage('Не удалось добавить критерий - возможно, он уже привязан к этой должности.');
  RefreshAll;
end;

procedure TFrmWGjrnMotivationCoeffsByJob.DoEditWeight(var Fr: TFrDBGridEh);
var
  va: TVarDynArray;
  LOthers, LShare, LMax: Double;
  LCur: Variant;
begin
  if VarIsNull(Fr.ID) then Exit;
  LOthers := GetWeightsSumPct(Fr.ID);
  LMax := Max(0, 100 - LOthers);
  LCur := Fr.GetValue('weight_pct');
  if VarIsNull(LCur) then LCur := 0;
  if TFrmBasicInput.ShowDialog(Self, '', [], fEdit,
       '~' + Fr.GetValueS('name'), 400, 160,
       [[cntNEdit, 'Доля вознаграждения, %', '0:100:2:N']],
       [LCur],
       va,
       [['Сумма долей остальных критериев: ' + FormatFloat('0.##', LOthers) + '%.'#13#10 +
         'Максимум для этого критерия: ' + FormatFloat('0.##', LMax) + '%.']],
       nil
     ) < 0 then Exit;

  LShare := S.NNum(va[0]);
  if LOthers + LShare > 100 + cWeightsEps then begin
    MyWarningMessage('Сумма долей критериев не может быть больше 100%.'#13#10 +
      'У остальных критериев распределено ' + FormatFloat('0.##', LOthers) + '%, для этого критерия доступно не более ' +
      FormatFloat('0.##', LMax) + '%.'#13#10'Сначала уменьшите долю другого критерия.');
    Exit;
  end;
  Q.QExecSql('update w_motivation_coefficient_for_job set weight = :w$f where id = :id$i',
    [RoundTo(LShare / 100, -4), Fr.ID], False);
  RefreshAll;
end;

procedure TFrmWGjrnMotivationCoeffsByJob.DoDelete(var Fr: TFrDBGridEh);
begin
  if VarIsNull(Fr.ID) then Exit;
  if MyQuestionMessage('Убрать критерий из списка этой должности?'#13#10 +
       '(в общем справочнике коэффициент останется; доли остальных критериев не пересчитываются)') <> mrYes then Exit;
  Q.QExecSql('delete from w_motivation_coefficient_for_job where id = :id$i', [Fr.ID], False);
  RefreshAll;
end;

procedure TFrmWGjrnMotivationCoeffsByJob.DoMovePos(var Fr: TFrDBGridEh; ADirection: Integer);
//перестановка порядка в рамках текущей должности (id_job_internal) - соседний по pos критерий этой же
//должности меняется с текущим значениями pos
var
  LCurId, LCurPos, LOtherId, LOtherPos: Variant;
begin
  LCurId := Fr.GetValue('id');
  LCurPos := Fr.GetValue('pos');
  if ADirection < 0
    then LOtherId := Q.QLoadValue('select id from w_motivation_coefficient_for_job where id_job_internal = :ij$i and pos < :p$i order by pos desc', [Frg1.ID, LCurPos])
    else LOtherId := Q.QLoadValue('select id from w_motivation_coefficient_for_job where id_job_internal = :ij$i and pos > :p$i order by pos asc', [Frg1.ID, LCurPos]);
  if VarIsNull(LOtherId) then Exit;
  LOtherPos := Q.QLoadValue('select pos from w_motivation_coefficient_for_job where id = :id$i', [LOtherId]);
  Q.QExecSql('update w_motivation_coefficient_for_job set pos = :p$i where id = :id$i', [LOtherPos, LCurId], False);
  Q.QExecSql('update w_motivation_coefficient_for_job set pos = :p$i where id = :id$i', [LCurPos, LOtherId], False);
  Fr.RefreshGrid;
end;

procedure TFrmWGjrnMotivationCoeffsByJob.DoFixWeights(var Fr: TFrDBGridEh; AMode: Integer);
//AMode: 1 - пропорционально текущим долям, 2 - поровну (см. p_w_motivation_job_weights_fix в d_motivation.sql)
begin
  if Fr.RecordCount = 0 then begin
    MyInfoMessage('У этой должности нет критериев.');
    Exit;
  end;
  if MyQuestionMessage(S.IIfStr(AMode = 1,
       'Пересчитать доли критериев этой должности пропорционально текущим, чтобы сумма стала 100%?',
       'Разделить 100% поровну между всеми критериями этой должности?'#13#10'(текущие доли будут заменены)')) <> mrYes then Exit;
  Q.QCallStoredProc('p_w_motivation_job_weights_fix', 'p_id_job_internal$i;p_mode$i', [Frg1.ID, AMode]);
  RefreshAll;
end;

procedure TFrmWGjrnMotivationCoeffsByJob.Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if VarIsNull(Frg1.ID) then
    Exit;
  if Tag = mbtAdd then begin
    DoAdd(Fr);
    Handled := True;
  end
  else if Tag = mbtEdit then begin
    DoEditWeight(Fr);
    Handled := True;
  end
  else if Tag = mbtDelete then begin
    DoDelete(Fr);
    Handled := True;
  end
  else if (Tag = mbtMoveUp) or (Tag = mbtMoveDown) then begin
    if VarIsNull(Fr.ID) then Exit;
    DoMovePos(Fr, S.IIf(Tag = mbtMoveUp, -1, 1));
    Handled := True;
  end
  else if Tag = mbtCustom_MotivationWeightsNormalize then begin
    DoFixWeights(Fr, 1);
    Handled := True;
  end
  else if Tag = mbtCustom_MotivationWeightsEqual then begin
    DoFixWeights(Fr, 2);
    Handled := True;
  end;
end;

end.
