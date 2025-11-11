{
Таблица контроля минимальных остатков отдельно для каждого участка
(на данный момент два участка, нужный выбирается исходя из foformDoc)
количество получается по всех складам, относящихся к участку, кроме Производства

Контролируемые наименования добавляются через меню (необходимо вставить строку наименования, как она прописана в ИТМ)

Список наименований общий для всех площадок
(данные хранятся в одной таблице, по строке на наименование, количества хранятся
в отдльных столбцах с суффиксом, соответствующим номеру плозадки)

Имеется возможность ввода минимального остатка для контроля,
а также ввода количества "К заказу" (по LShift или Space быстрый ввод числа, дополняющего до мин. остатка)
и галочки "В заявку", и передачи этих данных в таблицу Формирования заявок СН
(в последней будут проставлены количества и галки к заказу у позиций, которые отмечены здесь, а отальные галки по категории Снабжение буудут сняты)
}

unit uFrmOGedtSnByAreas;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2
  ;

type
  TFrmOGedtSnByAreas = class(TFrmBasicGrid2)
  private
    FIdArea: Integer;
    FAreaSuffix: string;
    FAreaName: string;
    function  PrepareForm: Boolean; override;
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); override;
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); override;
    function CreateDemand: Boolean;
  public
  end;

var
  FrmOGedtSnByAreas: TFrmOGedtSnByAreas;

implementation

uses
  RegularExpressions,
  uWindows,






  uFrmBasicInput
  ;


{$R *.dfm}

function TFrmOGedtSnByAreas.PrepareForm: Boolean;
var
  IsNstd: Boolean;
  va, va1: TVarDynArray;
  va2: TVarDynArray2;
  i, j: Integer;
begin
  FIdArea:= 0;
  if FormDoc = myfrm_R_MinRemainsI then FIdArea:= 1;
  if FormDoc = myfrm_R_MinRemainsD then FIdArea:= 2;
  FAreaSuffix:='_' + IntToStr(FIdArea);
  FAreaName:= Q.QSelectOneRow('select name from ref_production_areas where id = :id$i', [FIdArea])[0];
  Caption := 'Потребность по участку "' + FAreaName + '"';
  Frg1.Options := Frg1.Options + [myogGridLabels];
  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['artikul','Артикул','100'],
    ['name','Наименование','400;h'],
    ['qnt'+FAreaSuffix,'Текущий остаток','80'],
    ['qnt_min'+FAreaSuffix,'Минимальный остаток','80','e',User.Role(rOr_Other_R_MinRemainsI_ChAll)],
    ['qnt_order'+FAreaSuffix,'К заказу','80','e',User.Role(rOr_Other_R_MinRemainsI_ChAll)],
    ['to_order'+FAreaSuffix,'В заявку','60','chb','e',User.Role(rOr_Other_R_MinRemainsI_ChAll)]
  ]);
  Frg1.Opt.SetTable('v_spl_minremains_byareas');
  Frg1.Opt.SetWhere('');
  Frg1.Opt.SetButtons(1,[[mbtRefresh],[],[mbtAdd, User.Role(rOr_Other_R_MinRemainsI_ChAll)],[mbtDelete,1],[],[mbtGridSettings],[],[mbtGo,User.Role(rOr_Other_R_MinRemainsI_ChAll)]]);
  Frg1.InfoArray:=[
    [Caption + '.'#13#10#13#10],
    ['Добавьте через меню ПКМ наименования, остатки по которым на складах площадки нужно контролировать.'#13#10, User.Role(rOr_Other_R_MinRemainsIAdd_Ch)],
    ['В графе "Текущий остаток" вы увидите остаток только на складах этой площадки.'#13#10],
    ['Задайте минимальный остаток по позициям (введя данные прямо в таблице), по которым будет контролироваться количество.'#13#10+
    'Вы можете перенести данные к заказу выбранных позиций в таблицу формирования заявок на снабжение.'#13#10+
    'Для этого заполните поле "К заказу" и проставьте галочку в нужных позициях "В заявку", а после нажмите кнопку "Старт"'#13#10+
    '(для быстрого ввода в графу "К заказу" количества, дополняющего остаток до минимального, нажмите в этой ячейке пробел или левый шифт.)'#13#10, User.Role(rOr_Other_R_MinRemainsIAdd_Ch)]
  ];
  Frg1.Opt.ColumnsInfo:=[
    ['tomin', 'Если галочки проставлены, то можно отметить галочку "Только выбранные" в заголовке, и в таблице будут отображаться только эти записи'],
    ['','']
  ];
  Result := inherited;
end;

procedure TFrmOGedtSnByAreas.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
var
  i, j: Integer;
  idi: Variant;
  va, va1, va2: TVarDynArray;
  b: Boolean;
begin
  if Tag = mbtGo then begin
    CreateDemand;
  end
  else if Tag in [mbtAdd] then begin
    va1:=['', 0];
    while True do begin
      if TFrmBasicInput.ShowDialog(Self, '', [], CtH.BtnModeToFMode(Tag), S.Decode([Tag, mbtAdd, 'Добавить', mbtEdit, 'Изменить', mbtDelete, 'Удалить']), 700, 85,
        [[cntEdit, 'Наименование', '1:400:T', 600], [cntCheck, 'не закрывать окно', '', 200]],
        va1, va2, [['Введите наименование номенклатуры, которая есть в ИТМ.'#13#10]], nil
      ) >= 0
      then begin
        if Q.QSelectOneRow('select count(*) from v_spl_minremains_byareas where name = :name$s', [va2[0]])[0] > 0
          then begin MyWarningMessage('Это наименование уже есть в списке!'); Continue; end;
        idi:=Q.QSelectOneRow('select id_nomencl from dv.nomenclatura where name = :name$s', [va2[0]])[0];
        if idi = null
          then begin MyWarningMessage('Такого наименования нет в ИТМ!'); Continue; end;
        Q.QExecSql('insert into spl_minremains_byareas (id) values (:id$i)', [idi]);
        Refresh;
        if va2[1] = 1 then Continue;
      end;
      Break;
    end;
  end
  else if Tag = mbtDelete then begin
    if MyQuestionMessage('Удалить позицию из списка?') <> mrYes then Exit;
    Q.QExecSql('delete from spl_minremains_byareas where id = :id$i', [id]);
    Refresh;
  end
  else
    inherited;
end;

procedure TFrmOGedtSnByAreas.Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
var
  i: Integer;
  e: extended;
begin
  if TRegEx.IsMatch(FieldName, '^to_order_[0-9]{1}$')
    then Q.QExecSql('update spl_minremains_byareas set ' + FieldName + ' = :to_order$i where id = :id$i', [Value, Fr.ID])
    else if TRegEx.IsMatch(FieldName, '^qnt_min_[0-9]{1}$') or TRegEx.IsMatch(FieldName, '^qnt_order_[0-9]{1}$')
      then Q.QExecSql('update spl_minremains_byareas set ' + FieldName + ' = :qnt$f where id = :id$i', [S.NullIfEmpty(Value), Fr.ID]);
end;


function TFrmOGedtSnByAreas.CreateDemand: Boolean;
//создадим заявку на снабжение
//заявка создается только по позициям, для которых категория соответствует текущей
//перед созданием возможно сохранение всей таблицы (со снятым фильтром) в экселе в специальном каталоге
//в заявку выгрузятся только позиции по текущей категории, для которых задана и не нулевое количество к заказу и стоит галка В заказ
var
  i, j: Integer;
  e: extended;
  idd, res: Integer;
  gf: TVarDynArray2;
  id_category, idi: Integer;
begin
  //количество, которое попадет в заявку
  i := Q.QSelectOneRow('select count(*) from spl_minremains_byareas where nvl(qnt_order'+FAreaSuffix+', 0) > 0 and to_order'+FAreaSuffix+' = 1', [])[0];
  //если ничего нет, то выйдем
  if i = 0 then begin
    MyInfoMessage('Нет ни одной позиции к заказу!');
    Result := False;
    Exit;
  end;
  //количество, отмеченных по снабжению в основной таблице
  j := Q.QSelectOneRow('select count(*) from spl_itm_nom_props where nvl(qnt_order, 0) > 0 and to_order = 1 and id_category = :id_category$i', [1])[0];
  //переспросим
  if MyQuestionMessage(
    'Внести данные в таблицу формирования заявок на снабжение по ' + S.GetEndingFull(i, 'позици', 'и', 'ям', 'ям') + '"?'#13#10+
    S.IIfStr(i > 0, '(' + S.GetEndingFull(j, 'позици', 'я', 'и' ,'й') + ' в ней сейчас отмечен' + S.GetEnding(j, 'а', 'ы' ,'ы') + ', отметка будет снята!)'#13#10)+
    #13#10+
    'Если основная таблица у вас открыта, ообновите данные!'
    ) <> mrYes then  Exit;
  Q.QBeginTrans(True);
  Q.QExecSql('update spl_itm_nom_props set to_order = 0 where to_order = 1 and id_category = :id_category$i', [1]);
  for i:=0 to Frg1.MemTableEh1.RecordsView.MemTableData.RecordsList.Count - 1 do begin
    if S.NInt(Frg1.MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['to_order'+FAreaSuffix, dvvValueEh]) <> 1 then Continue;
    e:=S.NNum(Frg1.MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['qnt_order'+FAreaSuffix, dvvValueEh]);
    idi:= Frg1.MemTableEh1.RecordsView.MemTableData.RecordsList[i].DataValues['id', dvvValueEh];
    if e = 0 then Continue;
    //to_order
    Q.QCallStoredProc('p_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([idi, 5, 1]));
    //qnt_order
    Q.QCallStoredProc('p_SetSplDemandValue', 'IdNomencl$i;PMode$i;PValue$f', VarArrayOf([idi, 4, e]));
  end;
  Q.QExecSql('update spl_minremains_byareas set to_order'+FAreaSuffix+' = 0', []);
  Q.QCommitOrRollback();
  //если завершилось неудачно, сообщим и выйдем
  if Q.PackageMode <> 1 then begin
    MyWarningMessage('Ошибка выгрузки!');
    Exit;
  end;
  Refresh;
  MyInfoMessage('Готово.');
  Close;
end;

end.
