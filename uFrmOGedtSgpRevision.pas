{
Ревизия СГП - как для стандартных, так и для нестандартных изделий
}
unit uFrmOGedtSgpRevision;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uFrmBasicEditabelGrid, uLabelColors
  ;

type
  TFrmOGedtSgpRevision = class(TFrmBasicEditabelGrid)
  private
    function  PrepareForm: Boolean; override;
    procedure Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string); override;
    procedure VerifyBeforeSave; override;
    function  Save: Boolean; override;
  public
  end;

var
  FrmOGedtSgpRevision: TFrmOGedtSgpRevision;

implementation

{$R *.dfm}

function TFrmOGedtSgpRevision.PrepareForm: Boolean;
begin
  Caption:= 'Ревизия СГП';
  if ID = 0
    then FTitleTexts := ['$FF0000Нестандартные изделия']
    else FTitleTexts := ['Изделие:$FF0000 ' + S.NSt(Q.QSelectOneRow('select name from v_sgp_sell_formats where id = :id$i', [ID])[0])];
  Frg1.Opt.Caption := 'Изделия';
  Frg1.Opt.SetFields([
    ['id$i','_id','40'],
    ['slash$s','Слеш','110'],
    ['name$s','Наименование','300;w'],
    ['qnt$i','Кол-во','60'],
    ['null as qnt_fact$i','Кол-во факт.','60','e=0.000000:1000000:0'], //проверка, null допустимо
    ['null as qnt_diff$i','Разница','60']
  ]);
  Frg1.Opt.SetGridOperations('u');
  Frg1.Opt.SetTable(S.IIf(ID = 0, 'v_sgp2', 'v_sgp_items'));
  Frg1.Opt.SetWhere(S.IIf(ID = 0, 'order by slash, name', 'where id_format_est = :id$i order by slash, name'));
  Frg1.SetInitData('*',[ID]);
  FOpt.InfoArray:= [[
  'Ревизия склада готовой продукции по выбранному типу паспортов.'#13#10+
  'В таблице представлены все стандартные изделия данного типа, подлежащие учету по СГП.'#13#10+
  'В поле "Кол-во" отображается количество, которое должно находиться на СГП по документам'#13#10+
  '(производственные паспорта как приход, отгрузочные как расход, и созданные ранее акты оприходования или списания).'#13#10+
  ''#13#10+
  'Введите в графу "Кол-во факт." значение (целое число), полученное при пересчете на складе.'#13#10+
  '(не огбязательно вводить данные по каждой позиции, оставленные пустыми просто не будут обработаны.)'#13#10+
  ''#13#10+
  'При нажатии кнопки "Ок", после подтверждения, будут сформированы'#13#10+
  '(если есть соответствующие расхождения в количестве)'#13#10+
  'акт оприходования и акт списания, в которые попадут данные из графы "Разница",'#13#10+
  'положительные и отрицательные соответственно.'#13#10+
  'Номера актов и их даты будут проставлены автоматически.'#13#10+
  'Данные из этих актов являются корректирующими к приходу и расходу при получении остатков изделий на СГП,'#13#10+
  'они отобразятся в движении номенклатуры (двойной клик мышкой в графе "Текущий остаток" в таблице текущего состояни я СГП)'#13#10+
  ''#13#10+
  'Скорректировать либо отменить ревизию и созданные по ней акты нельзя!'#13#10+
  ''
  ]];
  Result := inherited;
end;

procedure TFrmOGedtSgpRevision.Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string);
begin
  if Mode <> dbgvCell then Exit;
  Fr.SetValue('qnt_diff', Row - 1, True, Fr.GetValueF('qnt_fact', Row - 1) - Fr.GetValueF('qnt', Row - 1));
end;

procedure TFrmOGedtSgpRevision.VerifyBeforeSave;
var
  i, cntin, cntout: Integer;
begin
  FErrorMessage := '';
  cntin := 0;
  cntout := 0;
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    if Frg1.GetValue('qnt_fact', i, False) = null then
      Continue
    else if Frg1.GetValue('qnt_fact', i, False) > Frg1.GetValueF('qnt', i, False) then
      inc(cntin)
    else if Frg1.GetValue('qnt_fact', i, False) < Frg1.GetValueF('qnt', i, False) then
      inc(cntout);
  end;
  if (cntin = 0) and (cntout = 0) then begin
    FErrorMessage := 'Нет расхождения или данные не введены. Акты оприходования и списания сформированы не будут!';
    Exit;
  end;
  if cntin > 0 then
    FErrorMessage := '?Будет сформирован акт оприходования из ' + S.GetEndingFull(cntin, 'позици', 'и', 'й', 'й') + '.';
  if cntout > 0 then
    FErrorMessage := '?Будет сформирован акт сисания из ' + S.GetEndingFull(cntout, 'позици', 'и', 'й', 'й') + '.';
end;

function TFrmOGedtSgpRevision.Save: Boolean;
var
  i, idi: Integer;
  qnt: Extended;
  va1, va2: TVarDynArray2;
  fld: string;
begin
  va1 := [];
  va2 := [];
  for i := 0 to Frg1.GetCount(False) - 1 do begin
    if Frg1.GetValue('qnt_fact', i, False) = null then
      Continue;
    idi := Frg1.GetValueI('id', i, False);
    qnt := Frg1.GetValueF('qnt_fact', i, False) - Frg1.GetValueF('qnt', i, False);
    if qnt > 0 then
      va1 := va1 + [[idi, qnt]]
    else
      va2 := va2 + [[idi, qnt]];
  end;
  Q.QBeginTrans(True);
  if Length(va1) > 0 then begin
    idi := Q.QIUD('i', 'sgp_act_in', '', 'id$i;id_format$i;id_user$i;dt$d;comm$s', [-1, id, User.GetId, Now, '']);
    for i := 0 to High(va1) do
      Q.QIUD('i', 'sgp_act_in_items', '-', 'id_act_in$i;' + S.IIf(ID = 0, 'id_or_item$i', 'id_std_item$i') + ';qnt$f',
       [idi, va1[i][0], va1[i][1]]
      );
  end;
  if Length(va2) > 0 then begin
    idi := Q.QIUD('i', 'sgp_act_out', '', 'id$i;id_format$i;id_user$i;dt$d;comm$s', [-1, id, User.GetId, Now, '']);
    for i := 0 to High(va2) do
      Q.QIUD('i', 'sgp_act_out_items', '-', 'id_act_out$i;' + S.IIf(ID = 0, 'id_or_item$i', 'id_std_item$i') + ';qnt$f',
        [idi, va2[i][0], va2[i][1]]
      );
  end;
  Result := Q.QCommitOrRollback;
end;


end.
