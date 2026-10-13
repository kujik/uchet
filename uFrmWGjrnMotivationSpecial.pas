{
Журналы специальных коэффициентов мотивации (05.10.2026, см. !алгоритмы.txt, п. 6.66): "Культура производства"
(kind = 1) и "Качество работы по специальности" (kind = 2). Один класс обслуживает три FormDoc:

1) myfrm_J_MotivationSpecItems - "Специальные коэффициенты - позиции по должностям". Frg1 - внутренние должности
   (v_w_motivation_special_jobs): по каждому виду - число позиций, сумма весов и состояние диапазонов. Frg2 -
   позиции выбранной должности (w_motivation_special_items, вью v_w_motivation_special_items) обоих видов,
   отсортированные по виду и pos: наименование, вес, ЛИЧНАЯ ли позиция (оценка по каждому сотруднику) или ПО
   ОТДЕЛУ (одна оценка на специальность), кто может вводить оценку (ids_value_setters). Кнопки (rW_Mtvn_Coeffs_Ch):
   добавить / изменить / удалить / выше / ниже (в рамках должности и вида) / пользователи, вводящие оценку.
   Вид после добавления не меняется.

2) myfrm_J_MotivationSpecRanges - "Специальные коэффициенты - диапазоны по должностям". Frg1 - те же должности,
   Frg2 - 4 оценки (отлично/хорошо/удовлетворительно/зона роста) каждого вида, по которому у должности есть
   позиции (строки создаются триггером при добавлении первой позиции вида): множитель к премии, диапазон
   ИТОГОВЫХ БАЛЛОВ от/до, признак "Вне диапазона", комментарий - редактируются прямо в гриде. Маркер состояния
   диапазона ("Не задан"/"Некорректен"/"Пересекается") - как у обычных коэффициентов.

3) myfrm_J_MotivationSpecValues - "Специальные коэффициенты - оценки по сотрудникам". Frg1 - работающие
   сотрудники, у чьей внутренней должности есть позиции (v_w_motivation_special_emp): итоговые баллы и ВЫЧИСЛЯЕМАЯ
   оценка по каждому виду. Frg2 - позиции его должности с введённой "Оценкой показателя" (вручную), баллами
   (оценка * вес) и признаком "личная/по отделу". Кнопка "Ввести оценку показателя" (или двойной щелчок):
   для личной позиции значение хранится по сотруднику, для позиции по отделу - по специальности (одно на всех
   сотрудников должности). Пустое значение удаляет оценку. Право ввода: если у позиции задан список
   пользователей - только они, если список пуст - только имеющие rW_Mtvn_Coeffs_Ch (на сервере список
   перепроверяет p_w_motivation_special_set_value).

Даты (месяца) нигде нет - значение просто перезаписывается (вся мотивация считается за прошедший месяц).
Итоговая оценка (1-4) и множитель в БД не хранятся - вычисляются вью v_w_motivation_spec_grades по итогу баллов
и текущим диапазонам должности, и только если введены оценки по ВСЕМ позициям и диапазоны в порядке.
"Проработка вкладки Культура пр-ва" (подсказки по пороговым значениям каждой позиции) пока не реализована.
}

unit uFrmWGjrnMotivationSpecial;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils, Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uNamedArr, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh
  ;

type
  TFrmWGjrnMotivationSpecial = class(TFrmBasicGrid2)
  private
    function  PrepareForm: Boolean; override;
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    procedure Frg2SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    procedure Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure Frg2OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); override;
    procedure PrepareItems;
    procedure PrepareRanges;
    procedure PrepareValues;
    function  IsItems: Boolean;
    function  IsRanges: Boolean;
    function  IsValues: Boolean;
    function  CanSetValue: Boolean;
    procedure UpdateSetValueButton;
    procedure RefreshAll;
    procedure DoItemDialog(var Fr: TFrDBGridEh; AMode: TDialogType);
    procedure DoDeleteItem(var Fr: TFrDBGridEh);
    procedure DoMoveItem(var Fr: TFrDBGridEh; ADirection: Integer);
    procedure DoItemSetters(var Fr: TFrDBGridEh);
    procedure DoSetValue(var Fr: TFrDBGridEh);
  public
  end;

var
  FrmWGjrnMotivationSpecial: TFrmWGjrnMotivationSpecial;

implementation

uses
  uWindows, uFrmBasicInput, uFrmXGsesUsersChoice
  ;

{$R *.dfm}

function IsChecked(const v: Variant): Boolean;
//значение контрола-галочки из диалога (0/1/False/True/пусто)
var
  s: string;
begin
  s := VarToStr(v);
  Result := not ((s = '') or (s = '0') or SameText(s, 'False'));
end;

function TFrmWGjrnMotivationSpecial.IsItems: Boolean;
begin
  Result := FormDoc = myfrm_J_MotivationSpecItems;
end;

function TFrmWGjrnMotivationSpecial.IsRanges: Boolean;
begin
  Result := FormDoc = myfrm_J_MotivationSpecRanges;
end;

function TFrmWGjrnMotivationSpecial.IsValues: Boolean;
begin
  Result := FormDoc = myfrm_J_MotivationSpecValues;
end;

procedure TFrmWGjrnMotivationSpecial.PrepareItems;
var
  LChRole: Boolean;
begin
  LChRole := User.Role(rW_Mtvn_Coeffs_Ch);
  Caption := 'Специальные коэффициенты - позиции по должностям';

  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['name','Должность','300'],
    ['c_cnt$i','Культура:'#13#10'позиций','70'],
    ['c_weights$f','Культура:'#13#10'сумма весов','80','f=r'],
    ['q_cnt$i','Качество:'#13#10'позиций','70'],
    ['q_weights$f','Качество:'#13#10'сумма весов','80','f=r'],
    ['comm','Комментарий','300;h']
  ]);
  Frg1.Opt.SetTable('v_w_motivation_special_jobs');
  Frg1.Opt.SetWhere('where active = 1 order by name');
  Frg1.Opt.SetButtons(1,[[mbtRefresh],[],[mbtGridSettings]]);

  Frg2.Opt.Caption := 'Позиции';
  Frg2.Options := Frg2.Options + [myogGridLabels];
  Frg2.Opt.SetFields([
    ['id$i','_id','40'],
    ['id_job_internal$i','_id_job_internal','40'],
    ['kind$i','_kind','40'],
    ['pos$i','_pos','40'],
    ['is_personal$i','_is_personal','40'],
    ['ids_value_setters','_ids_value_setters','40'],
    ['kind_name','Вид','160'],
    ['name','Позиция','350'],
    ['weight$f','Вес','70','f=r'],
    ['scope_name','Оценка','80'],
    ['value_setters_names','Кто может вводить оценку','250;h'],
    ['comm','Комментарий','300;h']
  ]);
  Frg2.Opt.SetTable('v_w_motivation_special_items', 'w_motivation_special_items', 'id');
  Frg2.Opt.SetWhere('where id_job_internal = :id_job_internal$i order by kind, pos, id');
  Frg2.Opt.SetButtons(1,[[mbtRefresh],[],
    [mbtAdd, LChRole],[mbtEdit, LChRole],[mbtDelete, LChRole],[],
    [mbtMoveUp, LChRole],[mbtMoveDown, LChRole],[],
    [-mbtCustom_MotivationSpecSetters, LChRole, 'Кто может вводить оценку'],[],
    [mbtGridSettings]]);

  Frg1.InfoArray:=[[Caption + #13#10#13#10 +
    'Слева - внутренние должности, справа - позиции (показатели) двух специальных коэффициентов:'#13#10 +
    '"Культура производства" и "Качество работы по специальности". Позиции и их веса свои у каждой должности.'#13#10 +
    'Позиция ЛИЧНАЯ - оценка вводится по каждому сотруднику отдельно; позиция ПО ОТДЕЛУ - одна оценка на'#13#10 +
    'всю специальность (на всех сотрудников этой должности). Баллы позиции = оценка * вес, итог = сумма баллов.'#13#10 +
    'Диапазоны итоговых баллов по оценкам и множители к премии задаются в журнале'#13#10 +
    '"Специальные коэффициенты - диапазоны по должностям".'#13#10 +
    'Кнопка "Кто может вводить оценку" - пользователи, которым разрешён ввод оценки по позиции (если список'#13#10 +
    'пуст - только имеющие право на изменение справочника коэффициентов).'#13#10
  ]];
end;

procedure TFrmWGjrnMotivationSpecial.PrepareRanges;
var
  LChRole: Boolean;
begin
  LChRole := User.Role(rW_Mtvn_Coeffs_Ch);
  Caption := 'Специальные коэффициенты - диапазоны по должностям';

  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['name','Должность','300'],
    ['c_cnt$i','Культура:'#13#10'позиций','70'],
    ['c_ranges_name','Культура:'#13#10'диапазоны','90'],
    ['q_cnt$i','Качество:'#13#10'позиций','70'],
    ['q_ranges_name','Качество:'#13#10'диапазоны','90'],
    ['comm','Комментарий','300;h']
  ]);
  Frg1.Opt.SetTable('v_w_motivation_special_jobs');
  Frg1.Opt.SetWhere('where active = 1 order by name');
  Frg1.Opt.SetButtons(1,[[mbtRefresh],[],[mbtGridSettings]]);

  Frg2.Opt.Caption := 'Диапазоны итоговых баллов';
  Frg2.Options := Frg2.Options + [myogGridLabels];
  Frg2.Opt.SetFields([
    ['id$i','_id','40'],
    ['id_job_internal$i','_id_job_internal','40'],
    ['kind$i','_kind','40'],
    ['rating$i','_rating','40'],
    ['kind_name','Вид','160'],
    ['rating_name','Оценка','150'],
    ['value$f','Множитель'#13#10'к премии','90','f=r','e',LChRole],
    ['range_from$f','Итог баллов'#13#10'от','90','f=r','e',LChRole],
    ['range_to$f','Итог баллов'#13#10'до','90','f=r','e',LChRole],
    ['is_outside_range$i','Вне'#13#10'диапа-'#13#10'зона','60','chb','e',LChRole],
    ['range_state_name','Состояние'#13#10'диапазона','100'],
    ['comm','Комментарий','300;h','','e',LChRole]
  ]);
  Frg2.Opt.SetTable('v_w_motivation_spec_rates', 'w_motivation_special_rates', 'id');
  Frg2.Opt.SetWhere('where id_job_internal = :id_job_internal$i order by kind, rating');
  Frg2.Opt.SetButtons(1,[[mbtRefresh],[],[mbtGridSettings]]);

  Frg1.InfoArray:=[[Caption + #13#10#13#10 +
    'Слева - внутренние должности, справа - 4 оценки (отлично/хорошо/удовлетворительно/зона роста) для каждого'#13#10 +
    'из двух специальных коэффициентов, по которым у должности есть позиции (строки создаются автоматически'#13#10 +
    'при добавлении первой позиции вида). Для каждой оценки задаются множитель к премии, диапазон ИТОГОВЫХ'#13#10 +
    'БАЛЛОВ (сумма оценка * вес по всем позициям) от/до включительно (пусто - граница не задана), признак'#13#10 +
    '"Вне диапазона" (итог меньше "от" или больше "до") и комментарий. Диапазон обязателен для каждой оценки;'#13#10 +
    'маркер в колонке "Состояние диапазона": "Не задан", "Некорректен" (от больше до) или "Пересекается".'#13#10 +
    'Оценка сотрудника определяется автоматически по его итогу баллов - только когда введены оценки по всем'#13#10 +
    'позициям и диапазоны всех 4 оценок в порядке.'#13#10
  ]];
end;

procedure TFrmWGjrnMotivationSpecial.PrepareValues;
begin
  Caption := 'Специальные коэффициенты - оценки по сотрудникам';

  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['name','Сотрудник','250'],
    ['job_internal_name','Должность','250'],
    ['c_total$f','Культура:'#13#10'итог баллов','80','f=r'],
    ['c_state_name','Культура:'#13#10'оценка','150'],
    ['c_rate_value$f','Культура:'#13#10'множитель','80','f=r'],
    ['q_total$f','Качество:'#13#10'итог баллов','80','f=r'],
    ['q_state_name','Качество:'#13#10'оценка','150'],
    ['q_rate_value$f','Качество:'#13#10'множитель','80','f=r']
  ]);
  Frg1.Opt.SetTable('v_w_motivation_special_emp');
  Frg1.Opt.SetWhere('where items_total > 0 order by name');
  Frg1.Opt.SetButtons(1,[[mbtRefresh],[],[mbtGridSettings]]);

  Frg2.Opt.Caption := 'Оценки показателей';
  Frg2.Options := Frg2.Options + [myogGridLabels];
  Frg2.Opt.SetFields([
    ['id$i','_id','40'],
    ['id_employee$i','_id_employee','40'],
    ['kind$i','_kind','40'],
    ['pos$i','_pos','40'],
    ['is_personal$i','_is_personal','40'],
    ['ids_value_setters','_ids_value_setters','40'],
    ['kind_name','Вид','160'],
    ['name','Позиция','350'],
    ['weight$f','Вес','70','f=r'],
    ['scope_name','Оценка','80'],
    ['value$f','Оценка'#13#10'показателя','90','f=r'],
    ['points$f','Баллы','80','f=r'],
    ['value_comm','Комментарий','300;h'],
    ['value_setters_names','Кто может вводить оценку','250;h']
  ]);
  Frg2.Opt.SetTable('v_w_motivation_spec_emp_items');
  Frg2.Opt.SetWhere('where id_employee = :id_employee$i order by kind, pos, id');
  Frg2.Opt.SetButtons(1,[[mbtRefresh],[],
    [-mbtCustom_MotivationSpecSetValue, True, 'Ввести оценку показателя'],[],
    [mbtGridSettings]]);

  Frg1.InfoArray:=[[Caption + #13#10#13#10 +
    'Слева - работающие сотрудники, у чьей должности есть позиции специальных коэффициентов ("Культура'#13#10 +
    'производства" и "Качество работы по специальности"), с итогом баллов и ВЫЧИСЛЯЕМОЙ оценкой по каждому.'#13#10 +
    'Справа - позиции его должности. Оценка показателя вводится вручную (кнопка "Ввести оценку показателя"'#13#10 +
    'или двойной щелчок): для ЛИЧНОЙ позиции она относится к сотруднику, для позиции ПО ОТДЕЛУ - к специальности'#13#10 +
    '(одна оценка на всех сотрудников этой должности). Пустое значение удаляет оценку. Даты нет - значение'#13#10 +
    'просто перезаписывается. Оценка сотрудника определяется, когда введены оценки по всем позициям и'#13#10 +
    'диапазоны должности заданы корректно (иначе в колонке указана причина).'#13#10
  ]];
end;

function TFrmWGjrnMotivationSpecial.PrepareForm: Boolean;
begin
  if IsItems then PrepareItems
  else if IsRanges then PrepareRanges
  else PrepareValues;
  Result := Inherited;
  if IsValues then UpdateSetValueButton;
end;

function TFrmWGjrnMotivationSpecial.CanSetValue: Boolean;
//ввод оценки: у позиции задан список - только пользователи из него, список пуст - только rW_Mtvn_Coeffs_Ch
var
  LSetters: string;
begin
  Result := False;
  if (not IsValues) or VarIsNull(Frg2.ID) then Exit;
  LSetters := Frg2.GetValueS('ids_value_setters');
  if LSetters = ''
    then Result := User.Role(rW_Mtvn_Coeffs_Ch)
    else Result := S.InCommaStr(IntToStr(User.GetId), LSetters);
end;

procedure TFrmWGjrnMotivationSpecial.UpdateSetValueButton;
begin
  if IsValues then
    Frg2.SetBtnNameEnabled(mbtCustom_MotivationSpecSetValue, null, CanSetValue);
end;

procedure TFrmWGjrnMotivationSpecial.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
  Inherited;
  UpdateSetValueButton;
end;

procedure TFrmWGjrnMotivationSpecial.Frg2SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
  Inherited;
  UpdateSetValueButton;
end;

procedure TFrmWGjrnMotivationSpecial.RefreshAll;
//после любого изменения обновляем и список слева (сводные колонки), и детальную таблицу
begin
  Frg1.RefreshGrid;
  Frg1.SetRowDetailPanelSize;
end;

procedure TFrmWGjrnMotivationSpecial.Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
var
  vr: Variant;
  st: string;
begin
  if IsValues then
    Fr.SetSqlParameters('id_employee$i', [Frg1.ID])
  else
    Fr.SetSqlParameters('id_job_internal$i', [Frg1.ID]);
  if IsItems then
    Fr.Opt.Caption := 'Позиции: ' + Frg1.GetValueS('name')
  else if IsRanges then
    Fr.Opt.Caption := 'Диапазоны: ' + Frg1.GetValueS('name')
  else begin
    Fr.Opt.Caption := 'Оценки: ' + Frg1.GetValueS('name');
    if VarIsNull(Frg1.ID) then Exit;
    vr := Q.QLoadRow('select c_items, c_total, c_state_name, q_items, q_total, q_state_name, id ' +
      'from v_w_motivation_special_emp where id = :id$i', [Frg1.ID]);
    if VarIsNull(vr[6]) then Exit;
    st := '';
    if S.NNum(vr[0]) > 0 then
      st := st + 'Культура: ' + FormatFloat('0.##', S.NNum(vr[1])) + ' - ' + VarToStr(vr[2]);
    if S.NNum(vr[3]) > 0 then
      st := st + S.IIfStr(st <> '', '; ', '') + 'Качество: ' + FormatFloat('0.##', S.NNum(vr[4])) + ' - ' + VarToStr(vr[5]);
    if st <> '' then Fr.Opt.Caption := Fr.Opt.Caption + '. ' + st;
  end;
end;

procedure TFrmWGjrnMotivationSpecial.DoItemDialog(var Fr: TFrDBGridEh; AMode: TDialogType);
//добавление/изменение позиции. Вид задаётся только при добавлении (при изменении поле только для чтения)
var
  va: TVarDynArray;
  LName, LComm: string;
  LWeight: Double;
  LPersonal: Integer;
  LNewPos: Variant;
  LKind: Integer;
begin
  if (AMode = fEdit) and VarIsNull(Fr.ID) then Exit;
  if AMode = fAdd then begin
    if TFrmBasicInput.ShowDialog(Self, '', [], fAdd,
         '~Добавить позицию: ' + Frg1.GetValueS('name'), 560, 160,
         [[cntComboLK, 'Вид', '1:300'],
          [cntEdit, 'Позиция', '1:300::T'],
          [cntNEdit, 'Вес позиции', '0:100000:2:N'],
          [cntCheckX, 'Личная позиция (оценка по каждому сотруднику; иначе - по отделу)', ''],
          [cntEdit, 'Комментарий', '0:1000::T']],
         [VarArrayOf(['', VarArrayOf(['Культура производства', 'Качество работы по специальности']), VarArrayOf([1, 2])]),
          '', 1, 1, ''],
         va,
         [['Баллы позиции = оценка показателя * вес. Личная позиция: оценка вводится по каждому сотруднику;'#13#10 +
           'не личная: одна оценка на специальность (на всех сотрудников этой должности).']],
         nil
       ) < 0 then Exit;
    if VarToStr(va[0]) = '' then Exit;
    LKind := Round(S.NNum(va[0]));
    LName := Trim(VarToStr(va[1]));
    LWeight := S.NNum(va[2]);
    LPersonal := S.IIf(IsChecked(va[3]), 1, 0);
    LComm := Trim(VarToStr(va[4]));
    if LName = '' then Exit;
    if LWeight <= 0 then begin
      MyWarningMessage('Вес позиции должен быть больше нуля.');
      Exit;
    end;
    LNewPos := Q.QLoadValue('select nvl(max(pos), 0) + 1 from w_motivation_special_items ' +
      'where id_job_internal = :ij$i and kind = :k$i', [Frg1.ID, LKind]);
    if VarIsNull(LNewPos) then LNewPos := 1;
    if Q.QSave('I', 'w_motivation_special_items', '',
         'id$i;kind$i;id_job_internal$i;name$s;weight$f;is_personal$i;pos$i;comm$s',
         [Null, LKind, Frg1.ID, LName, LWeight, LPersonal, LNewPos, LComm], False) < 0 then
      MyWarningMessage('Не удалось добавить позицию - возможно, такая позиция уже есть у этой должности.');
  end
  else begin
    if TFrmBasicInput.ShowDialog(Self, '', [], fEdit,
         '~' + Fr.GetValueS('name'), 560, 160,
         [[cntEdit, ' Вид', '0:300::T'],
          [cntEdit, 'Позиция', '1:300::T'],
          [cntNEdit, 'Вес позиции', '0:100000:2:N'],
          [cntCheckX, 'Личная позиция (оценка по каждому сотруднику; иначе - по отделу)', ''],
          [cntEdit, 'Комментарий', '0:1000::T']],
         [Fr.GetValueS('kind_name'), Fr.GetValueS('name'), Fr.GetValue('weight'), Fr.GetValue('is_personal'),
          Fr.GetValueS('comm')],
         va,
         [['Если изменить признак "Личная позиция", уже введённые оценки по ней перестанут учитываться'#13#10 +
           '(личные оценки привязаны к сотрудникам, оценка по отделу - к специальности).']],
         nil
       ) < 0 then Exit;
    LName := Trim(VarToStr(va[1]));
    if LName = '' then Exit;
    if S.NNum(va[2]) <= 0 then begin
      MyWarningMessage('Вес позиции должен быть больше нуля.');
      Exit;
    end;
    Q.QExecSql('update w_motivation_special_items set name = :n$s, weight = :w$f, is_personal = :p$i, comm = :c$s ' +
      'where id = :id$i',
      [LName, S.NNum(va[2]), S.IIf(IsChecked(va[3]), 1, 0), Trim(VarToStr(va[4])), Fr.ID], False);
  end;
  RefreshAll;
end;

procedure TFrmWGjrnMotivationSpecial.DoDeleteItem(var Fr: TFrDBGridEh);
begin
  if VarIsNull(Fr.ID) then Exit;
  if MyQuestionMessage('Удалить позицию "' + Fr.GetValueS('name') + '"?'#13#10 +
       '(введённые по ней оценки тоже будут удалены)') <> mrYes then Exit;
  Q.QExecSql('delete from w_motivation_special_items where id = :id$i', [Fr.ID], False);
  RefreshAll;
end;

procedure TFrmWGjrnMotivationSpecial.DoMoveItem(var Fr: TFrDBGridEh; ADirection: Integer);
//перестановка в рамках текущей должности И вида - сосед по pos меняется значениями pos с текущей позицией
var
  LCurId, LCurPos, LKind, LOtherId, LOtherPos: Variant;
begin
  LCurId := Fr.GetValue('id');
  LCurPos := Fr.GetValue('pos');
  LKind := Fr.GetValue('kind');
  if ADirection < 0
    then LOtherId := Q.QLoadValue('select id from w_motivation_special_items where id_job_internal = :ij$i and kind = :k$i and pos < :p$i order by pos desc', [Frg1.ID, LKind, LCurPos])
    else LOtherId := Q.QLoadValue('select id from w_motivation_special_items where id_job_internal = :ij$i and kind = :k$i and pos > :p$i order by pos asc', [Frg1.ID, LKind, LCurPos]);
  if VarIsNull(LOtherId) then Exit;
  LOtherPos := Q.QLoadValue('select pos from w_motivation_special_items where id = :id$i', [LOtherId]);
  Q.QExecSql('update w_motivation_special_items set pos = :p$i where id = :id$i', [LOtherPos, LCurId], False);
  Q.QExecSql('update w_motivation_special_items set pos = :p$i where id = :id$i', [LCurPos, LOtherId], False);
  Fr.RefreshGrid;
end;

procedure TFrmWGjrnMotivationSpecial.DoItemSetters(var Fr: TFrDBGridEh);
var
  Ids, Names: string;
begin
  if VarIsNull(Fr.ID) then Exit;
  Ids := Fr.GetValueS('ids_value_setters');
  if TFrmXGsesUsersChoice.ShowDialog(Self, True, Ids, Names) <> mrOk then Exit;
  Q.QExecSql('update w_motivation_special_items set ids_value_setters = :ids$s where id = :id$i', [Ids, Fr.ID], False);
  Fr.RefreshGrid;
end;

procedure TFrmWGjrnMotivationSpecial.DoSetValue(var Fr: TFrDBGridEh);
//ввод оценки показателя по позиции для выбранного сотрудника (для позиции по отделу - по специальности)
var
  va: TVarDynArray;
  vr: Variant;
  LCaption: string;
  LVal: Variant;
begin
  if VarIsNull(Fr.ID) or VarIsNull(Frg1.ID) then Exit;
  if not CanSetValue then begin
    MyWarningMessage('Нет права вводить оценку по этой позиции.');
    Exit;
  end;
  //актуальное значение из бд - его мог поменять другой пользователь
  vr := Q.QLoadRow('select value, value_comm, id from v_w_motivation_spec_emp_items where id = :id$i and id_employee = :ie$i',
    [Fr.ID, Frg1.ID]);
  if VarIsNull(vr[2]) then begin
    MsgRecordIsDeleted;
    Exit;
  end;
  LCaption := Fr.GetValueS('name');
  if TFrmBasicInput.ShowDialog(Self, '', [], fEdit,
       '~' + LCaption, 520, 110,
       [[cntNEdit, 'Оценка показателя', '0:999999:2:N'],
        [cntEdit, 'Комментарий', '0:400::T']],
       [vr[0], VarToStr(vr[1])],
       va,
       [[S.IIfStr(Fr.GetValue('is_personal') = 1,
           'Личная позиция: оценка относится к сотруднику ' + Frg1.GetValueS('name') + '.',
           'Позиция по отделу: оценка относится к специальности "' + Frg1.GetValueS('job_internal_name') +
           '" и действует для всех её сотрудников.') + #13#10 +
         'Вес позиции: ' + FormatFloat('0.##', S.NNum(Fr.GetValue('weight'))) + '. Пустое значение удаляет оценку.']],
       nil
     ) < 0 then Exit;
  if VarToStr(va[0]) = '' then LVal := Null else LVal := S.NNum(va[0]);
  Q.QCallStoredProc('p_w_motivation_special_set_value',
    'p_id_item$i;p_id_employee$i;p_user_id$i;p_value$f;p_comm$s',
    [Fr.ID, Frg1.ID, User.GetId, LVal, VarToStr(va[1])]);
  RefreshAll;
end;

procedure TFrmWGjrnMotivationSpecial.Frg2OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
  if IsValues and CanSetValue then begin
    DoSetValue(Fr);
    Handled := True;
  end;
end;

procedure TFrmWGjrnMotivationSpecial.Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if VarIsNull(Frg1.ID) then Exit;
  if IsItems then begin
    if Tag = mbtAdd then begin
      DoItemDialog(Fr, fAdd);
      Handled := True;
    end
    else if Tag = mbtEdit then begin
      DoItemDialog(Fr, fEdit);
      Handled := True;
    end
    else if Tag = mbtDelete then begin
      DoDeleteItem(Fr);
      Handled := True;
    end
    else if (Tag = mbtMoveUp) or (Tag = mbtMoveDown) then begin
      if VarIsNull(Fr.ID) then Exit;
      DoMoveItem(Fr, S.IIf(Tag = mbtMoveUp, -1, 1));
      Handled := True;
    end
    else if Tag = mbtCustom_MotivationSpecSetters then begin
      DoItemSetters(Fr);
      Handled := True;
    end;
  end
  else if IsValues then begin
    if Tag = mbtCustom_MotivationSpecSetValue then begin
      DoSetValue(Fr);
      Handled := True;
    end;
  end;
end;

end.
