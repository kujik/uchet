unit uFrmOGrepOrReglament;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  GridsEh, DBAxisGridsEh, DBGridEh, PropFilerEh, PropStorageEh, Math,
  Mask, Types, DBCtrlsEh, ExtCtrls, DateUtils, Vcl.ComCtrls,
  uLabelColors, uFrmBasicMdi, uFrmBasicDbDialog, uFrDBGridEh, uFrMyPanelCaption, uString, uData,
  uFrmBasicEditabelGrid
  ;

type
  TFrmOGrepOrReglament = class(TFrmBasicEditabelGrid)
    lblDeadline: TLabel;
    lblName: TLabel;
    lblOrder: TLabel;
  private
    FReglament: TNamedArr;
    function  PrepareForm: Boolean; override;
    procedure LoadReglament;
    procedure SetDaysGrid;
    procedure LoadDaysGrid;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
  public
  end;

var
  FrmOGrepOrReglament: TFrmOGrepOrReglament;

implementation

uses
  uDBOra, uOrders;

{$R *.dfm}

function TFrmOGrepOrReglament.PrepareForm: Boolean;
begin
  Mode := fNone;
  Result := False;
  Caption := '–егламент';
  LoadReglament;
  if FReglament.Count = 0 then
    Exit;
  SetDaysGrid;
  Result := inherited;
  if not Result then
    Exit;
  LoadDaysGrid;
  pnlTop.Height := 35;
end;

procedure TFrmOGrepOrReglament.LoadReglament;
begin
  Q.QLoadFromQuery('select r.id, r.name, r.deadline, r.sn_1, r.sn_2, r.sn_3, r.sn_4, o.ornum, o.dt_beg, o.dt_otgr from order_reglaments r, v_orders o where r.id = o.id_reglament and o.id = :id$i', [ID], FReglament);
  if FReglament.Count = 0 then
    Exit;
  lblOrder.Caption := FReglament.G(0, 'ornum').AsString + ' (' + FReglament.G(0, 'dt_beg').AsString + ' - ' + FReglament.G(0, 'dt_otgr').AsString + ')';
  lblName.Caption := FReglament.G(0, 'name').AsString;
  lblDeadline.Caption := FReglament.G(0, 'deadline').AsString;
end;

procedure TFrmOGrepOrReglament.SetDaysGrid;
//установи пол€  и загрузим строки (кроме значений сохраненных дл€ регламентап) грида таймлайна
//вызываетс€ при загрузке и при изменении длительности регламента
var
  i, j: Integer;
  va: TVarDynArray;
  va2: TVarDynArray2;
  st, st2: string;
begin
  Frg1.Options := [myogNoTextEditing];
  va2 := [
    ['id$i','_id','100'],
    ['posstd$i','_posstd','100'],
    ['posall$i','_posall','100'],
    ['color$i','_color','60'],
    ['name$s','”часток','300;w;h;r']
  ];
  //добавим пол€ дл€ €чеек дней (центрируем)
  for i := 1 to  FReglament.G(0, 'deadline').AsInteger do
    va2 := va2 + [['d' + InttoStr(i) + '$i', InttoStr(DayOf(IncDay(FReglament.G(0, 'dt_beg'), i - 1))), '25;c']];
  Frg1.Opt.SetFields(va2);
  Frg1.Opt.SetGridOperations('');
  //строка дл€ вставки в запрос дл€ инициализацтт пустыми значени€ми €чеек по дн€м
  st := '';
  for i := 1 to FReglament.G(0, 'deadline').AsInteger do
    st := st + ',null as d' + IntToStr(i);
  st2 := '';
  //строка дл€   вставки в запрос дл€ загрузки через юнион значений по снабжению, наименовани€ сохранены в массиве-константе в коде, значени€ последнего дн€ дл€ них хран€тс€ в основной таблице регламента
  for i := 1 to High(cOrderReglamentSnTypes) do
    if  FReglament.G(0, 'sn_' + IntToStr(i)).AsInteger > 0 then
      st2 := st2 + ' union all select 100000' + IntToStr(i) + ', 0, 100000' + IntToStr(i) + ' as posall, null,''' +  cOrderReglamentSnTypes[i] + '''' + st +  ' from dual ';
  Frg1.SetInitData('select t.id, t.posstd, t.posall, r.color, t.name' + st + ' from v_work_cell_types t, order_reglament_items r where r.id_reglament = :id$i and t.id = r.id_work_cell_type' + st2 + ' order by posall',[100]);
end;

procedure TFrmOGrepOrReglament.LoadDaysGrid;
//загрузка введенных данныых по дн€м в грид таймлайна из таблиц по данному регламенту
var
  i, j, k: Integer;
  va2: TVarDynArray2;
begin
  //читаем всю таблицу по участкам дл€ данного регламента
  va2 := Q.QLoadToVarDynArray2('select id_work_cell_type, day_beg, day_end, color from order_reglament_items where id_reglament = :id_reglament$i', [FReglament.G(0, 'id')]);
  //установим дни и цвета дл€ участков
  for i := 0 to High(va2) do
    for j := 0 to Frg1.GetCount(False) - 1 do
      if (Frg1.GetValue('id', j, False) < 1000000) and (va2[i][0] = Frg1.GetValue('id', j, False)) then begin
        for k := va2[i][1] to Min(FReglament.G(0, 'deadline').AsInteger, va2[i][2].AsInteger) do
          Frg1.SetValue('d' + IntToStr(k), j, False, InttoStr(DayOf(IncDay(FReglament.G(0, 'dt_beg'), k - 1))));
        Frg1.SetValue('color', j, False, va2[i][3]);
        Break;
      end;
  //установим в последних строках дни дл€ снабжени€
  for i := 0 to Frg1.GetCount(False) - 1 do
    if (Frg1.GetValue('id', i, False) >= 1000000) then begin
      for j := 1 to Min(FReglament.G(0, 'deadline').AsInteger, FReglament.G(0, 'sn_' + IntToStr(Frg1.GetValue('id', i, False) - 1000000)).AsInteger) do
        Frg1.SetValue('d' + IntToStr(j), i, False, InttoStr(DayOf(IncDay(FReglament.G(0, 'dt_beg'), j - 1))));
        //светло-жельтый цвет дл€ заполненных €чеек снабжени€
      Frg1.SetValue('color', i, False, 10354687);
    end;
  //обновим
//  for i := 0 to Frg1.DbGridEh1.Columns.Count - 1 do
//    Frg1.DbGridEh1.Columns[i].TextEditing := False;
  Frg1.Invalidate;
end;

procedure TFrmOGrepOrReglament.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  //раскрасим грид
  //подсветка всего фона дл€ участков офиса перед производством, и дл€ снабжени€
  if Fr.GetValue('posstd') = null then
  else if Fr.GetValueI('posstd') > 0 then
    Params.Background := RGB(240, 240, 255)
  else if Fr.GetValueI('posstd') = 0 then
    Params.Background := RGB(240, 255, 240);
  //подсветка фона рабочих дней
  if (Pos('d', FieldName) = 1) then begin
    if (Fr.GetValueI('color') <> 0) and (Fr.GetValueI(FieldName) <> 0) then
      Params.Background := Fr.GetValueI('color');
    if DaysBetween(Date, FReglament.G(0, 'dt_beg')) + 1 = StrtoInt(Copy(FieldName, 2)) then
      Params.Background := clFuchsia;
  end;
end;

end.
