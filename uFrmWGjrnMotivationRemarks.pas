{
Журнал "Грубые замечания / Чрезвычайные ситуации по должностям".

Один класс обслуживает два FormDoc - myfrm_J_MotivationNegRemarksByJob (Грубые замечания) и
myfrm_J_MotivationEmergenciesByJob (Чрезвычайные ситуации) - структура обоих полностью идентична,
различаются только имена таблиц/вью и текст заголовков

Frg1 - список активных (внутренних) должностей (w_jobs_internal), только для просмотра.

Frg2 (в RowDetailPanel выбранной должности) - привязанные к ней замечания/ЧС из общего
справочника (w_motivation_negative_remarks / w_motivation_w_work_emergencies), через связующую
таблицу *_for_job и вью v_w_motivation_..._for_job (id, id_job_internal, id_remark, pos, name,
comm, is_global; см. SQL/d_motivation.sql). Список сортируется "is_global desc, pos" - глобальные
замечания (общие для всех должностей) всегда первыми.

Кнопки Frg2:
- "Добавить" (mbtAdd) - открывает диалог выбора текста из общего справочника или ввода нового
  (TFrmBasicInput.ShowDialog, комбобокс cntComboE - позволяет и выбрать из списка, и напечатать
  произвольный текст). Если введённого текста нет в справочнике - сначала создаётся строка в нём
  (is_global=0). Новая привязка получает pos = greatest(1000, max(pos локальных записей этой же
  должности) + 1) - т.е. всегда встаёт после ВСЕХ глобальных замечаний этой должности.
- "Добавить общие замечания" (mbtCustom_MotivationAddGlobalRemarks) - одной командой привязывает к
  должности все ещё не привязанные глобальные (is_global=1) записи справочника; их начальный порядок
  внутри должности - по порядку в самом справочнике (pos, name), pos им присваивается заново
  (1, 2, 3...) - независимо от должности, к которой их привязывают ранее.
- "Удалить" (mbtDelete) - удаляет только привязку (строку *_for_job), не трогая общий справочник;
  доступно и для глобальных записей (их можно вручную убрать из конкретной должности).
- "Выше"/"Ниже" (mbtMoveUp/mbtMoveDown) - меняют порядок (pos) записи в рамках ТЕКУЩЕЙ должности,
  отдельно среди локальных (не-глобальных) и отдельно среди глобальных записей - глобальная запись
  не может поменяться местами с локальной. В отличие от плоских справочников ("Все замечания"/"Все
  чрезвычайные ситуации", см. uFrmXGlstMain.pas, где порядок вообще не меняется), здесь pos задан
  отдельно для каждой должности - одно и то же значение pos параллельно существует у разных
  должностей, поэтому общая хранимая процедура p_ExchangePositions (используется в плоских
  справочниках) здесь не подходит - перестановка реализована отдельным запросом с учётом
  id_job_internal и is_global (см. DoMovePos).
}

unit uFrmWGjrnMotivationRemarks;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils, Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh
  ;

type
  TFrmWGjrnMotivationRemarks = class(TFrmBasicGrid2)
  private
    function  IsRemarks: Boolean;
    function  RemarksTable: string;
    function  ForJobTable: string;
    function  ForJobView: string;
    function  PrepareForm: Boolean; override;
    procedure Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    procedure DoAddRemark(var Fr: TFrDBGridEh; ARole: Boolean);
    procedure DoAddGlobalRemarks(var Fr: TFrDBGridEh);
    procedure DoMovePos(var Fr: TFrDBGridEh; ADirection: Integer);
  public
  end;

var
  FrmWGjrnMotivationRemarks: TFrmWGjrnMotivationRemarks;

implementation

uses
  uWindows, uFrmBasicInput
  ;

{$R *.dfm}

function TFrmWGjrnMotivationRemarks.IsRemarks: Boolean;
begin
  Result := FormDoc = myfrm_J_MotivationNegRemarksByJob;
end;

function TFrmWGjrnMotivationRemarks.RemarksTable: string;
begin
  Result := S.IIfStr(IsRemarks, 'w_motivation_negative_remarks', 'w_motivation_w_work_emergencies');
end;

function TFrmWGjrnMotivationRemarks.ForJobTable: string;
begin
  Result := S.IIfStr(IsRemarks, 'w_motivation_negative_remarks_for_job', 'w_motivation_w_work_emergencies_for_job');
end;

function TFrmWGjrnMotivationRemarks.ForJobView: string;
begin
  Result := S.IIfStr(IsRemarks, 'v_w_motivation_negative_remarks_for_job', 'v_w_motivation_w_work_emergencies_for_job');
end;

function TFrmWGjrnMotivationRemarks.PrepareForm: Boolean;
var
  LChRole: Boolean;
begin
  Caption := S.IIfStr(IsRemarks, 'Грубые замечания по должностям', 'Чрезвычайные ситуации по должностям');
  LChRole := S.IIf(IsRemarks, User.Role(rW_Mtvn_Remarks_Ch), User.Role(rW_Mtvn_Emerg_Ch));

  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['name','Должность','300'],
    ['comm','Комментарий','300;h']
  ]);
  Frg1.Opt.SetTable('w_jobs_internal');
  Frg1.Opt.SetWhere('where active = 1 order by name');
  Frg1.Opt.SetButtons(1,[[mbtRefresh],[],[mbtGridSettings]]);

  Frg2.Opt.Caption := S.IIfStr(IsRemarks, 'Замечания', 'Чрезвычайные ситуации');
  Frg2.Options := Frg2.Options + [myogGridLabels];
  Frg2.Opt.SetFields([
    ['id$i','_id','40'],
    ['id_job_internal$i','_id_job_internal','40'],
    ['id_remark$i','_id_remark','40'],
    ['pos$i','_pos','40'],
    ['is_global$i','Гло-'#13#10'бальное','60','pic'],
    ['name','Текст','500'],
    ['comm','Комментарий','200;h']
  ]);
  Frg2.Opt.SetTable(ForJobView, ForJobTable, 'id');
  Frg2.Opt.SetWhere('where id_job_internal = :id_job_internal$i order by is_global desc, pos');
  Frg2.Opt.SetButtons(1,[[mbtRefresh],[],
    [mbtAdd, LChRole],[-mbtCustom_MotivationAddGlobalRemarks, LChRole, 'Добавить общие замечания'],[mbtDelete, LChRole],[],
    [mbtMoveUp, LChRole],[mbtMoveDown, LChRole],[],[mbtGridSettings]]);
  Frg2.Opt.SetButtonsIfEmpty([mbtCustom_MotivationAddGlobalRemarks]);

  Frg1.InfoArray:=[[Caption + #13#10#13#10 +
    'Список (внутренних) должностей слева, справа для выбранной должности - привязанные к ней'#13#10 +
    S.IIfStr(IsRemarks, 'грубые замечания' ,'чрезвычайные ситуации') + ' из общего справочника ' +
    '("' + S.IIfStr(IsRemarks, 'Мотивация - Все замечания', 'Мотивация - Все чрезвычайные ситуации') + '").'#13#10 +
    'Глобальные записи (общие для всех должностей) показываются первыми и добавляются сразу все'#13#10 +
    'кнопкой "Добавить общие замечания" - при необходимости их всё равно можно удалить из списка'#13#10 +
    'конкретной должности вручную.'#13#10 +
    'Кнопка "Добавить" позволяет выбрать формулировку из справочника либо ввести свою - в этом'#13#10 +
    'случае она будет также добавлена в общий справочник.'#13#10 +
    'Кнопками "Выше"/"Ниже" можно менять порядок записей - отдельно среди локальных и отдельно'#13#10 +
    'среди глобальных (глобальная и локальная запись местами не меняются).'#13#10
  ]];

  Result := Inherited;
end;

procedure TFrmWGjrnMotivationRemarks.Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  Fr.SetSqlParameters('id_job_internal$i', [Frg1.ID]);
  Fr.Opt.Caption := S.IIfStr(IsRemarks, 'Замечания: ', 'Чрезвычайные ситуации: ') + Frg1.GetValueS('name');
end;

procedure TFrmWGjrnMotivationRemarks.DoAddRemark(var Fr: TFrDBGridEh; ARole: Boolean);
var
  LNames: TVarDynArray;
  va: TVarDynArray;
  LText: string;
  LIdRemark, LNewPos: Variant;
begin
  if not ARole then Exit;
  LNames := Q.QLoadCol('select name from ' + RemarksTable + ' where active = 1 order by is_global desc, pos, name', []);
  if TFrmBasicInput.ShowDialog(Self, '', [], fAdd,
       S.IIfStr(IsRemarks, '~Замечание', '~Чрезвычайная ситуация'), 500, 110,
       [[cntComboE, S.IIfStr(IsRemarks, 'Текст замечания', 'Текст записи'), '1:1000']],
       [VarArrayOf([Null, VarArrayOf(LNames)])],
       va, [['']], nil
     ) < 0 then Exit;
  LText := Trim(VarToStr(va[0]));
  if LText = '' then Exit;
  //ищем без учета регистра - см. уникальный индекс lower(name) в d_motivation.sql
  LIdRemark := Q.QLoadValue('select id from ' + RemarksTable + ' where lower(name) = lower(:name$s)', [LText]);
  if VarIsNull(LIdRemark) then
    //такого текста еще нет в общем справочнике - создадим (не глобальное, обычная запись)
    LIdRemark := Q.QSave('I', RemarksTable, '', 'id$i;name$s;comm$s;is_global$i;active$i', [Null, LText, Null, 0, 1]);
  if VarIsNull(LIdRemark) or (LIdRemark = -1) then begin
    MyWarningMessage('Не удалось создать запись в общем справочнике!');
    Exit;
  end;
  //позиция - всегда после ВСЕХ глобальных (см. !алгоритмы.txt), начиная с 1000, далее по порядку добавления
  LNewPos := Q.QLoadValue('select greatest(1000, nvl(max(pos), 999) + 1) from ' + ForJobTable + ' where id_job_internal = :id_job$i and pos >= 1000', [Frg1.ID]);
  if VarIsNull(LNewPos) then LNewPos := 1000;
  if Q.QSave('I', ForJobTable, '', 'id$i;id_job_internal$i;id_remark$i;pos$i', [Null, Frg1.ID, LIdRemark, LNewPos], False) < 0 then
    MyWarningMessage('Не удалось добавить запись - возможно, такая формулировка уже привязана к этой должности.');
  Fr.RefreshGrid;
  Frg1.SetRowDetailPanelSize;
end;

procedure TFrmWGjrnMotivationRemarks.DoAddGlobalRemarks(var Fr: TFrDBGridEh);
begin
  //замечание: параметр должности передан ДВАЖДЫ под разными именами (:id_job$i / :id_job2$i) -
  //намеренно, чтобы не зависеть от того, объединяет ли QSetParams/TParams.ParseSQL повторное
  //использование ОДНОГО И ТОГО ЖЕ имени параметра в один или считает отдельными параметрами.
  //pos присваивается заново (row_number по порядку в справочнике) - у этой должности он не должен
  //зависеть от pos в самом справочнике (там pos кнопками больше не меняется, см. uFrmXGlstMain.pas),
  //и дальше меняется независимо для каждой должности кнопками "Выше"/"Ниже" (см. DoMovePos).
  Q.QExecSql(
    'insert into ' + ForJobTable + ' (id_job_internal, id_remark, pos) ' +
    'select :id_job$i, r.id, row_number() over (order by r.pos, r.name) from ' + RemarksTable + ' r ' +
    'where r.is_global = 1 and r.active = 1 ' +
    'and not exists (select 1 from ' + ForJobTable + ' f where f.id_job_internal = :id_job2$i and f.id_remark = r.id)',
    [Frg1.ID, Frg1.ID], False
  );
  Fr.RefreshGrid;
  Frg1.SetRowDetailPanelSize;
end;

procedure TFrmWGjrnMotivationRemarks.DoMovePos(var Fr: TFrDBGridEh; ADirection: Integer);
//перестановка позиции в рамках текущей должности (id_job_internal) И в рамках одной группы -
//глобальные и локальные записи переставляются раздельно, соседняя запись ищется среди записей
//с тем же is_global (это поле хранится в справочнике, а не в *_for_job - отсюда join к RemarksTable)
var
  LCurId, LCurPos, LCurIsGlobal, LOtherId, LOtherPos: Variant;
begin
  LCurId := Fr.GetValue('id');
  LCurPos := Fr.GetValue('pos');
  LCurIsGlobal := Fr.GetValue('is_global');
  if ADirection < 0
    then LOtherId := Q.QLoadValue('select f.id from ' + ForJobTable + ' f, ' + RemarksTable + ' r where f.id_remark = r.id and f.id_job_internal = :ij$i and r.is_global = :ig$i and f.pos < :p$i order by f.pos desc', [Frg1.ID, LCurIsGlobal, LCurPos])
    else LOtherId := Q.QLoadValue('select f.id from ' + ForJobTable + ' f, ' + RemarksTable + ' r where f.id_remark = r.id and f.id_job_internal = :ij$i and r.is_global = :ig$i and f.pos > :p$i order by f.pos asc', [Frg1.ID, LCurIsGlobal, LCurPos]);
  if VarIsNull(LOtherId) then Exit;
  LOtherPos := Q.QLoadValue('select pos from ' + ForJobTable + ' where id = :id$i', [LOtherId]);
  Q.QExecSql('update ' + ForJobTable + ' set pos = :p$i where id = :id$i', [LOtherPos, LCurId], False);
  Q.QExecSql('update ' + ForJobTable + ' set pos = :p$i where id = :id$i', [LCurPos, LOtherId], False);
  Fr.RefreshGrid;
end;

procedure TFrmWGjrnMotivationRemarks.Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if VarIsNull(Frg1.ID) then
    Exit;
  if Tag = mbtAdd then begin
    DoAddRemark(Fr, User.Role(S.IIfStr(IsRemarks, rW_Mtvn_Remarks_Ch, rW_Mtvn_Emerg_Ch)));
    Handled := True;
  end
  else if Tag = mbtCustom_MotivationAddGlobalRemarks then begin
    DoAddGlobalRemarks(Fr);
    Handled := True;
  end
  else if Tag = mbtDelete then begin
    if VarIsNull(Fr.ID) then Exit;
    if MyQuestionMessage('Удалить запись из списка этой должности?'#13#10'(в общем справочнике формулировка останется)') <> mrYes then Exit;
    Q.QExecSql('delete from ' + ForJobTable + ' where id = :id$i', [Fr.ID], False);
    Fr.RefreshGrid;
    Frg1.SetRowDetailPanelSize;
    Handled := True;
  end
  else if (Tag = mbtMoveUp) or (Tag = mbtMoveDown) then begin
    if VarIsNull(Fr.ID) then Exit;
    DoMovePos(Fr, S.IIf(Tag = mbtMoveUp, -1, 1));
    Handled := True;
  end;
end;

end.
