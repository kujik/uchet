{
Журнал "Мотивация - Коэффициенты" (27.09.2026, см. !алгоритмы.txt).

Frg1 - общий справочник коэффициентов мотивации (критериев эффективности, w_motivation_coefficients,
вью v_w_motivation_coefficients - SQL/d_motivation.sql). Список отсортирован по pos (позиция только
для визуального упорядочивания этого справочника - по умолчанию = id, меняется кнопками "Выше"/
"Ниже", см. p_ExchangePositions). Добавление/изменение/удаление коэффициента (наименование,
персональный ли, описание, комментарий к выставлению оценки) - через стандартный диалог
(myfrm_Dlg_R_MotivationCoeffs), доступно при наличии rW_Mtvn_Coeffs_Ch.

Frg2 (в RowDetailPanel выбранного коэффициента) - пороговые значения по 4 фиксированным оценкам
(отлично/хорошо/удовлетворительно/зона роста, вью v_w_motivation_coefficients_rates) - строки
создаются автоматически при добавлении коэффициента, добавлять/удалять их нельзя, можно только
редактировать значение (коэффициент премии), диапазон значений производственного показателя
(от/до, оба включительно, пусто - граница не задана), признак "Вне диапазона" (обычно оценке
соответствует показатель ВНУТРИ диапазона, но иногда - как раз наоборот, ВНЕ его, например
"зона роста" = менее 25 или более 40 - это одна строка с диапазоном 25-40 и признаком "Вне
диапазона") и комментарий к градации - редактирование прямо в гриде, доступно при наличии
rW_Mtvn_Coeffs_Ch. Признак "Выбрана" отмечает строку, соответствующую текущей выбранной оценке
коэффициента (w_motivation_coefficients.selected_rating). Диапазоны предназначены для
последующего автоматического подбора оценки по значению показателя (с учетом словесных
исключений) - сам автоподбор пока не реализован, оценка выбирается вручную.

Кнопки Frg1:
- "Выше"/"Ниже" (mbtMoveUp/mbtMoveDown) - меняют позицию коэффициента в списке (pos) - обычный
  плоский справочник, поэтому используется общая p_ExchangePositions (как в uFrmXGlstMain.pas);
  доступно при наличии rW_Mtvn_Coeffs_Ch.
- "Пользователи, которые могут задавать значение" (mbtCustom_MotivationCoeffValueSetters) - выбор
  пользователей (TFrmXGsesUsersChoice, как в uFrmWDedtDivision) с сохранением их айди в
  ids_value_setters; доступно при наличии rW_Mtvn_Coeffs_Ch.
- "Ввести значение коэффициента" (mbtCustom_MotivationCoeffSetValue) - открывает ввод текущего
  значения производственного показателя (fact_value) и выбор одной из 4 оценок (selected_rating);
  сохранение - через хранимую процедуру p_w_motivation_coefficients_set_value (перепроверяет на
  сервере то же бизнес-правило). Доступно, только если коэффициент не персональный и текущий
  пользователь есть в списке ids_value_setters - см. CanSetValue/UpdateSetValueButton.

Персональные коэффициенты (is_personal = 1) считаются индивидуально по каждому сотруднику - здесь
fact_value/selected_rating не задаются (ввод значения для них заблокирован), их значение будет
храниться в расчёте по конкретному сотруднику (отдельно, вне рамок этого экрана).
}
unit uFrmWGjrnMotivationCoefficients;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh
  ;

type
  TFrmWGjrnMotivationCoefficients = class(TFrmBasicGrid2)
  private
    function  PrepareForm: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); override;
    procedure Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); override;
    function  CanSetValue: Boolean;
    procedure UpdateSetValueButton;
    procedure DoSetValueSetters(var Fr: TFrDBGridEh);
    procedure DoSetCoeffValue(var Fr: TFrDBGridEh);
  public
  end;

var
  FrmWGjrnMotivationCoefficients: TFrmWGjrnMotivationCoefficients;

implementation

uses
  uWindows, uFrmBasicInput, uFrmXGsesUsersChoice
  ;

{$R *.dfm}

function TFrmWGjrnMotivationCoefficients.PrepareForm: Boolean;
var
  LChRole: Boolean;
begin
  Caption := 'Мотивация - Коэффициенты';
  LChRole := User.Role(rW_Mtvn_Coeffs_Ch);

  Frg1.Options := Frg1.Options - [myogSorting] + [myogGridLabels];
  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['pos$i','№','40'],
    ['name','Наименование','300;h'],
    ['is_personal$i','Пер-'#13#10'сональ-'#13#10'ный','60','pic'],
    ['fact_value$f','Значение','100'],
    ['selected_rating_name','Оценка','160'],
    ['selected_rating$i','_selected_rating','40'],
    ['id_selected_rate$i','_id_selected_rate','40'],
    ['description$s','Описание','250;h'],
    ['comm_for_eval','Комментарий к оценке','250;h'],
    ['ids_value_setters','_ids_value_setters','40'],
    ['value_setters_names','Кто может задать значение','250;h']
  ]);
  Frg1.Opt.SetTable('v_w_motivation_coefficients', 'w_motivation_coefficients', 'id');
  Frg1.Opt.SetWhere('order by pos');
  Frg1.Opt.DialogFormDoc := myfrm_Dlg_R_MotivationCoeffs;
  Frg1.Opt.SetButtons(1,[[mbtRefresh],[],[mbtView],[mbtAdd,LChRole],[mbtEdit,LChRole],[mbtDelete,LChRole],[],
    [mbtMoveUp,LChRole],[mbtMoveDown,LChRole],[],
    [-mbtCustom_MotivationCoeffValueSetters, LChRole, 'Пользователи, которые могут задавать значение'],[],
    [-mbtCustom_MotivationCoeffSetValue, True, 'Ввести значение коэффициента'],[],
    [mbtGridSettings]]);

  Frg2.Opt.Caption := 'Пороговые значения по оценкам';
  Frg2.Options := Frg2.Options + [myogGridLabels];
  Frg2.Opt.SetFields([
    ['id$i','_id','40'],
    ['id_coefficient$i','_id_coefficient','40'],
    ['rating$i','_rating','40'],
    ['is_selected$i','Выбра-'#13#10'на','60','pic'],
    ['rating_name','Оценка','150'],
    ['value$f','Коэффициент премии','90','f=r','e',LChRole],
    ['range_from$f','Диапазон'#13#10'от','90','f=r','e',LChRole],
    ['range_to$f','Диапазон'#13#10'до','90','f=r','e',LChRole],
    ['is_outside_range$i','Вне'#13#10'диапа-'#13#10'зона','60','chb','e',LChRole],
    ['comm','Комментарий','300;h','','e',LChRole]
  ]);
  Frg2.Opt.SetTable('v_w_motivation_coefficients_rates', 'w_motivation_coefficients_rates', 'id');
  Frg2.Opt.SetWhere('where id_coefficient = :id_coefficient$i order by rating');
  Frg2.Opt.SetButtons(1,[[mbtRefresh],[],[mbtGridSettings]]);

  Frg1.InfoArray:=[[Caption + #13#10#13#10 +
    'Общий справочник коэффициентов мотивации (критериев эффективности), порядок в списке (№) можно'#13#10 +
    'менять кнопками "Выше"/"Ниже" - только для визуального удобства, на расчет не влияет.'#13#10 +
    'В детальной таблице -'#13#10 +
    'пороговые значения коэффициента по 4 фиксированным оценкам (отлично/хорошо/удовлетворительно/'#13#10 +
    'зона роста) - строки создаются автоматически при добавлении коэффициента, добавить или удалить'#13#10 +
    'их отдельно нельзя, можно только редактировать значение, диапазон значений показателя (от/до),'#13#10 +
    'галочка "Вне диапазона" (для оценок, которым соответствуют значения по краям шкалы - например,'#13#10 +
    'менее 25 или более 40) и комментарий (доступно при наличии права на изменение).'#13#10 +
    'Кнопка "Ввести значение коэффициента" доступна, если коэффициент не персональный и текущий'#13#10 +
    'пользователь есть в списке "Кто может задать значение" - открывает ввод текущего значения'#13#10 +
    'производственного показателя и выбор одной из 4 оценок; выбранная оценка отмечается галочкой'#13#10 +
    '"Выбрана" в детальной таблице.'#13#10 +
    'Персональные коэффициенты (галочка "Персональный") считаются индивидуально по каждому'#13#10 +
    'сотруднику - значение и оценка здесь не задаются.'#13#10
  ]];
  Frg2.InfoArray:=[[
    'Данные по оценкам текущего коэффициента.'#13#10 +
    'Здесь вводятся значение коэффициента (с которым он применяется при расчете мотивации),'#13#10 +
    'диапазон значений показателя (от/до), галочка "Вне диапазона" (для оценок, которым соответствуют значения'#13#10 +
    'по краям шкалы - например, менее 25 или более 40) и комментарий.'
  ]];

  Result := Inherited;
  UpdateSetValueButton;
end;

procedure TFrmWGjrnMotivationCoefficients.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
  UpdateSetValueButton;
end;

function TFrmWGjrnMotivationCoefficients.CanSetValue: Boolean;
begin
  Result := (not VarIsNull(Frg1.ID)) and (Frg1.GetValue('is_personal') <> 1) and
    S.InCommaStr(IntToStr(User.GetId), Frg1.GetValueS('ids_value_setters'));
end;

procedure TFrmWGjrnMotivationCoefficients.UpdateSetValueButton;
begin
  Frg1.SetBtnNameEnabled(mbtCustom_MotivationCoeffSetValue, null, CanSetValue);
end;

procedure TFrmWGjrnMotivationCoefficients.Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
  Fr.SetSqlParameters('id_coefficient$i', [Frg1.ID]);
  Fr.Opt.Caption := 'Оценки: ' + Frg1.GetValueS('name');
end;

procedure TFrmWGjrnMotivationCoefficients.DoSetValueSetters(var Fr: TFrDBGridEh);
var
  Ids, Names: string;
begin
  Ids := Frg1.GetValueS('ids_value_setters');
  if TFrmXGsesUsersChoice.ShowDialog(Self, True, Ids, Names) <> mrOk then
    Exit;
  Q.QExecSql('update w_motivation_coefficients set ids_value_setters = :ids$s where id = :id$i', [Ids, Frg1.ID], False);
  Frg1.RefreshGrid;
  UpdateSetValueButton;
end;

procedure TFrmWGjrnMotivationCoefficients.DoSetCoeffValue(var Fr: TFrDBGridEh);
var
  va: TVarDynArray;
  LInitRating: Variant;
  LInitRatingS: string;
begin
  LInitRating := Frg1.GetValue('selected_rating');
  LInitRatingS := S.IIfStr(VarIsNull(LInitRating), '', VarToStr(LInitRating));
  if TFrmBasicInput.ShowDialog(Self, '', [], fEdit,
       '~' + Frg1.GetValueS('name'), 230, 100,
       [[cntNEdit, 'Текущее значение'#13#10'показателя', '0:999999:2:N'],
        [cntComboLK, 'Оценка', '1:30']],
       VarArrayOf([
         Frg1.GetValue('fact_value'),
         VarArrayOf([LInitRatingS, VarArrayOf(['Отлично', 'Хорошо', 'Удовлетворительно', 'Зона роста']), VarArrayOf(['1', '2', '3', '4'])])
       ]),
       va,
       [['Введите фактическое значение показателя работы и выберите соответствующую ему оценку.'#13#10],
       ['Комментарий к выставлению оценки:'#13#10 + Frg1.GetValueS('comm_for_eval'), Frg1.GetValueS('comm_for_eval') <> '']],
       nil
     ) < 0 then Exit;
  Q.QCallStoredProc('p_w_motivation_coefficients_set_value', 'p_id_coefficient$i;p_user_id$i;p_fact_value$f;p_rating$i',
    [Frg1.ID, User.GetId, S.NNum(va[0]), va[1]]);
  Frg1.RefreshGrid;
  Frg1.SetRowDetailPanelSize;
end;

procedure TFrmWGjrnMotivationCoefficients.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
  if VarIsNull(Frg1.ID) then
    Exit;
  if Tag = mbtCustom_MotivationCoeffValueSetters then begin
    DoSetValueSetters(Fr);
    Handled := True;
  end
  else if Tag = mbtCustom_MotivationCoeffSetValue then begin
    DoSetCoeffValue(Fr);
    Handled := True;
  end
  else if (Tag = mbtMoveUp) or (Tag = mbtMoveDown) then begin
    Q.QCallStoredProc('p_ExchangePositions', 'ATable$s;AField$s;APos$i;ADirection$i', [Frg1.Opt.Sql.Table, 'pos', Frg1.GetValue('pos'), S.IIf(Tag = mbtMoveUp, -1, 1)]);
    Frg1.RefreshGrid;
    Handled := True;
  end;
end;

end.
