unit uFrmOWedtOrReglament;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  GridsEh, DBAxisGridsEh, DBGridEh, PropFilerEh, PropStorageEh, Math,
  Mask, Types, DBCtrlsEh, ExtCtrls, DateUtils, Vcl.ComCtrls,
  uLabelColors, uFrmBasicMdi, uFrmBasicDbDialog, uFrDBGridEh, uFrMyPanelCaption, uString
  ;

type
  TFrmOWedtOrReglament = class(TFrmBasicDbDialog)
    pnlTop: TPanel;
    pgcMain: TPageControl;
    tsPrioperties: TTabSheet;
    tsDays: TTabSheet;
    pnlTypes: TPanel;
    pnlProperties: TPanel;
    frmpcProperties: TFrMyPanelCaption;
    frmpcTypes: TFrMyPanelCaption;
    FrgTypes: TFrDBGridEh;
    FrgProperties: TFrDBGridEh;
    FrgDays: TFrDBGridEh;
    edt_name: TDBEditEh;
    nedt_deadline: TDBNumberEditEh;
    dlgColor1: TColorDialog;
    chb_active: TDBCheckBoxEh;
    frmpcDays: TFrMyPanelCaption;
    procedure nedt_deadlineButtonClick(Sender: TObject; var Handled: Boolean);
    procedure FrgDaysDbGridEh1CellClick(Column: TColumnEh);
  private
    FAllProperties: TVarDynArray2;
    function  Prepare: Boolean; override;
    procedure SetGridValues;
    procedure SetDaysGrid;
    procedure LoadDaysGrid;
    procedure LoadProperties;
    procedure GetPropertiesResult;
    function  Save: Boolean; override;
    procedure FrgTypesColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
    procedure FrgPropertiesColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
    procedure FrgDaysColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
    procedure FrgDaysColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
  public
  end;

var
  FrmOWedtOrReglament: TFrmOWedtOrReglament;

implementation

uses
  uWindows,
  uForms,
  uDBOra,
  uMessages,
  uData,
  uErrors,
  uPrintReport,
  uOrders,
  uFrmBasicInput
  ;

{$R *.dfm}


function TFrmOWedtOrReglament.Prepare: Boolean;
//подготовка к открытию формы
//в AddParam:
//[статус, area, FOrNumъ
var
  i, j: Integer;
  c: TControl;
  va2: TVarDynArray2;
begin
  Result := False;
//  FWHBounds.Y := 500;
//  FWHBounds.X := 500;
  Caption := 'Регламент заказа';
  F.DefineFields := [
    ['id$i'],
    ['active$i'],
    ['name$s','V=1:4000::T'],
    ['deadline$i','V=1:365:0:N'],
    ['ids_types$s'],
    ['ids_properties$s'],
    ['types$s'],
    ['properties$s']
  ];
  for i := 1 to Length(cOrderReglamentSnTypes) do
    F.DefineFields := F.DefineFields + [['sn_' + InttoStr(i) + '$i']];

  View := 'order_reglaments';
  Table := 'order_reglaments';

  Cth.AlignControls(pnlTop, []);
  Result := inherited;
  if not Result then
    Exit;
  nedt_deadline.ReadOnly := True;
  //SetControlsEditable([], True);


  frmpcTypes.SetParameters(True, 'Типы заказов',
    [['Выберите типы заказов, для которых применим данный регламент. Хотя бы один тип заказа должен быть выбран.'#13#10'Внимание: при изменении отметки в этом списке список "Свойства заказов" будет очищен!']],
    False
  );
//  Frg1.Options := [myogIndicatorColumn, myogColoredTitle, myogHiglightEditableCells, myogHiglightEditableColumns, myogHasStatusBar];
  FrgTypes.Opt.SetFields([
    ['id$i','_id','100'],
    ['pos$i','№','80'],
    ['name$s','Тип заказа','300;w;h'],
    ['used$i','X','40','chb','e']
  ]);
  FrgTypes.Opt.SetGridOperations('u');
  //FrgTypes.Opt.SetCaption
  FrgTypes.OnColumnsUpdateData := FrgTypesColumnsUpdateData;

  FrgTypes.SetInitData('select id, pos, name, 0 as used from v_order_types order by pos',[]);
  FrgTypes.Prepare;
  FrgTypes.RefreshGrid;

  frmpcProperties.SetParameters(True, 'Свойства заказов',
    [['Выберите свойства заказов, для которых применим данный регламент.']],
    False
  );
  FrgProperties.Opt.SetFields([
    ['id$i','_id','100'],
    ['pos$i','№','80'],
    ['name$s','Свойство заказа','300;w;h'],
    ['used$i','X','40','chb','e']
  ]);
  FrgProperties.Opt.SetGridOperations('u');
  FrgProperties.OnColumnsUpdateData := FrgPropertiesColumnsUpdateData;
  FrgProperties.SetInitData([]);
  FrgProperties.Prepare;
  FrgProperties.RefreshGrid;
  SetGridValues;

  frmpcDays.SetParameters(True, 'Регламент прохождения заказа по участкам и закупки материалов снабжением.',
    [[
      'Заполните временные параметры заказа.'#13#10#13#10+
      'В таблице отображаются участки, по которым перемещается заказ, в порядке их прохождения.'#13#10+
      'Также в нижних строках отображены сроки закупки по типам материалов для снабжения.'#13#10+
      'Для задания дня начала работы по заказу для выбранного участка, нажмите левую клавишу мыши, удерживая левый Ctrl на требуемой ячейке.'#13#10+
      'Для задания дня окончания работы по заказу для выбранного участка, нажмите левую клавишу мыши, удерживая правый Ctrl на требуемой ячейке.'#13#10+
      'Если отмечена только одна ячейка, то при таком нажатии она будет очищена.'#13#10+
      'Ячейки для снабжения всегда выделяются с первого дня!'#13#10+
      'Если для данного типа регламента какой-либо участок или материал снабжения не используется, оставьте эту строку пустой.'#13#10+
      'Для каждой строки можно задать цвет ячеек, для этого нажмите левую клавишу мыши, удерживая Ctrl, на ячейке с наименованием участка.'#13#10+
      ''#13#10+
      'Важно: согласованность введенных данных по времени прохождения участков никак не проверяется, будьте внимательны!'#13#10
    ]],
    False
  );
  SetDaysGrid;
  LoadDaysGrid;

  FOpt.InfoArray:=[[
    'Регламент заказа.'#13#10+
    'Введите наименование регламента (отображается в журнале) и количество дней обработки заказа для данного регламента.'#13#10+
    'Важно: количество дней вводится нажатием на кнопку в этом поле справа, и при его вводе таблица регламента будет очищена!'#13#10+
    'Заполните таблицы типов закаа, свойств заказа и регламента прохождения по участкам.'#13#10+
    ''#13#10
  ]];

  Result := True;
end;

procedure TFrmOWedtOrReglament.LoadProperties;
var
  i, j: Integer;
  st, st2: string;
begin
  st := '';
  st2 := '';
  j := 0;
  for i := 0 to FrgTypes.GetCount(False) - 1 do
    if FrgTypes.GetValueI('used', i, False) = 1 then begin
      S.ConcatStP(st, FrgTypes.GetValueS('id', i, False), ',');
      S.ConcatStP(st2, FrgTypes.GetValueS('name', i, False), '; ');
      Inc(j);
    end;
  if j = 0 then
    FrgProperties.SetInitData([])
  else
    FrgProperties.SetInitData(
      'select id, max(pos) as pos, max(name) as name, 0 as used '+
      'from v_order_properties_for_type '+
      'where id_type in ('+ st + ') and used = 1 ' +
      'group by id '+
      'having count(distinct id_type) = ' + IntToStr(j) + ' '+
      'order by pos',
      []
    );
  FrgProperties.RefreshGrid;
  F.SetProp('ids_types', st);
  F.SetProp('types', st2);
end;

procedure TFrmOWedtOrReglament.nedt_deadlineButtonClick(Sender: TObject; var Handled: Boolean);
var
  va: TVarDynArray;
begin
  va := [nedt_deadline.Value];
  if TFrmBasicInput.ShowDialog(Self, '', [], fAdd, '~Дней по регламенту', 150, 80,
   [[cntNEdit, 'Дней:', '1:365:0:N', 50]], va, va, [['']], nil) >= 0 then begin
    nedt_deadline.Value := va[0].AsInteger;
    SetDaysGrid;
  end;
end;

procedure TFrmOWedtOrReglament.GetPropertiesResult;
var
  i, j: Integer;
  st, st2: string;
begin
  st := '';
  st2 := '';
  j := 0;
  for i := 0 to FrgProperties.GetCount(False) - 1 do
    if FrgProperties.GetValueI('used', i, False) = 1 then begin
      S.ConcatStP(st, FrgProperties.GetValueS('id', i, False), ',');
      S.ConcatStP(st2, FrgProperties.GetValueS('name', i, False), '; ');
      Inc(j);
    end;
  F.SetProp('ids_properties', st);
  F.SetProp('properties', st2);
end;


procedure TFrmOWedtOrReglament.SetGridValues;
var
  i: Integer;
  va: TVarDynArray;
begin
  va := A.Explode(F.GetProp('ids_types'), ',', True);
  for i := 0 to FrgTypes.GetCount(False) - 1 do
    if A.InArray(FrgTypes.GetValueI('id', i, False), va) then
      FrgTypes.SetValue('used', i, False, 1);
  FrgTypes.Invalidate;
  LoadProperties;
  va := A.Explode(F.GetProp('ids_properties'), ',', True);
  for i := 0 to FrgProperties.GetCount(False) - 1 do
    if A.InArray(FrgProperties.GetValueI('id', i, False), va) then
      FrgProperties.SetValue('used', i, False, 1);
  FrgProperties.Invalidate;
end;

procedure TFrmOWedtOrReglament.SetDaysGrid;
var
  i, j: Integer;
  va: TVarDynArray;
  va2: TVarDynArray2;
  st, st2: string;
begin
  //FrgDays.DbGridEh1.OptionsEh := FrgDays.DbGridEh1.OptionsEh - [
  va2 := [
    ['id$i','_id','100'],
    ['posstd$i','_posstd','100'],
    ['posall$i','_posall','100'],
    ['color$i','_color','60'],
    ['name$s','Участок','300;w;h']
  ];
  for i := 1 to  S.NInt(nedt_deadline.Value) do
    va2 := va2 + [['d' + InttoStr(i) + '$i', InttoStr(i), '25']];
  FrgDays.Opt.SetFields(va2);
  FrgDays.Opt.SetGridOperations('u');
  //FrgTypes.Opt.SetCaption
  FrgDays.OnColumnsUpdateData := FrgDaysColumnsUpdateData;
  FrgDays.OnColumnsGetCellParams := FrgDaysColumnsGetCellParams;
  st := '';
  for i := 1 to  S.NInt(nedt_deadline.Value) do
    st := st + ',null as d' + IntToStr(i);
  st2 := '';
  for i := 1 to High(cOrderReglamentSnTypes) do
    st2 := st2 + ' union all select 100000' + IntToStr(i) + ', 0, 100000' + IntToStr(i) + ' as posall, null,''' +  cOrderReglamentSnTypes[i] + '''' + st +  ' from dual ';
  FrgDays.SetInitData('select id, posstd, posall, null as color, name' + st + ' from v_work_cell_types where active = 1 ' + st2 + ' order by posall',[]);
  FrgDays.MemTableEh1.FieldDefs.Clear;  //!!! иначе ошибка, вероятно это должно быть в FrgDays.Prepare
  FrgDays.MemTableEh1.Close;
  FrgDays.Prepare;
  for i := 0 to FrgDays.DbGridEh1.Columns.Count - 1 do
    FrgDays.DbGridEh1.Columns[i].TextEditing := False;
  FrgDays.RefreshGrid;
end;

procedure TFrmOWedtOrReglament.LoadDaysGrid;
var
  i, j, k: Integer;
  va2: TVarDynArray2;
begin
  va2 := [];
  if not (Mode in [fAdd]) then
    va2 := Q.QLoadToVarDynArray2('select id_work_cell_type, day_beg, day_end, color from order_reglament_items where id_reglament = :id_reglament$i', [ID]);
  for i := 0 to High(va2) do
    for j := 0 to FrgDays.GetCount(False) - 1 - Length(cOrderReglamentSnTypes) do
      if va2[i][0] = FrgDays.GetValue('id', j, False) then begin
        for k := va2[i][1] to Min(nedt_deadline.Value, va2[i][2].AsInteger) do
          FrgDays.SetValue('d' + IntToStr(k), j, False, k);
        FrgDays.SetValue('color', j, False, va2[i][3]);
        Break;
      end;
  k := 1;
  for i := FrgDays.GetCount(False) - Length(cOrderReglamentSnTypes) to FrgDays.GetCount(False) - 1 do begin
    if F.GetProp('sn_' + IntToStr(k)).AsInteger <> 0 then
      for j := 1 to Min(nedt_deadline.Value, F.GetProp('sn_' + IntToStr(k)).AsInteger) do
        FrgDays.SetValue('d' + IntToStr(j), i, False, j);
        //светло-жельтый цвет для заполненных ячеек снабжения
        FrgDays.SetValue('color', i, False, 10354687);
    inc(k);
  end;
  FrgDays.Invalidate;
end;


function TFrmOWedtOrReglament.Save: Boolean;
var
  st, st1: string;
  i, j, k, m: Integer;
begin
  Result := inherited;
  if (Mode = fDelete) then
    Exit;
  for m := 0 to FrgDays.GetCount(False) - 1 - Length(cOrderReglamentSnTypes) do begin
    i := 0;
    j := 0;
    for k := 1 to S.NInt(nedt_deadline.Value) do
      if (i = 0) and (FrgDays.GetValueI('d' + IntToStr(k), m, False) <> 0) then
        i := k;
    for k := S.NInt(nedt_deadline.Value) downto 1 do
      if (j = 0) and (FrgDays.GetValueI('d' + IntToStr(k), m, False) <> 0) then
        j := k;
    if i = 0 then
      Q.QExecSql('delete from order_reglament_items where id_reglament = :id_reglament$i and id_work_cell_type = :id_work_cell_type$i', [ID, FrgDays.GetValueI('id', m, False)])
    else
      Q.QExecSql(
        'insert into order_reglament_items (id_reglament, id_work_cell_type) select :id_reglament$i, :id_work_cell_type$i from dual where not exists (' +
        'select 1 from order_reglament_items where id_reglament = :id_reglament1$i and id_work_cell_type = :id_work_cell_type1$i)',
        [ID, FrgDays.GetValueI('id', m, False), ID, FrgDays.GetValueI('id', m, False)]
      );
      Q.QExecSql(
        'update order_reglament_items set day_beg = :day_beg$i, day_end = :day_end$i, color = :color$i where id_reglament = :id_reglament$i and id_work_cell_type = :id_work_cell_type$i',
        [i, j, FrgDays.GetValueI('color', m, False), ID, FrgDays.GetValueI('id', m, False)]
      );
  end;
end;


procedure TFrmOWedtOrReglament.FrgTypesColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
  Fr.SetValue('', Value, True);
  LoadProperties;
end;

procedure TFrmOWedtOrReglament.FrgDaysDbGridEh1CellClick(Column: TColumnEh);
//клик мышкой при нажатом Ctrl на таблице таймлайна
var
  i, j, k, p: Integer;
  rc, lc: Boolean;
begin
  lc := GetAsyncKeyState(VK_LCONTROL) and $8000 <> 0;
  rc := GetAsyncKeyState(VK_RCONTROL) and $8000 <> 0;
  if (Pos('d', Column.FieldName) = 1) and (lc or rc) then begin
    for k := 1 to S.NInt(nedt_deadline.Value) do
       p:=FrgDays.GetValueI('d' + IntToStr(k), FrgDays.RecNo - 1, False);
    p := StrtoInt(Copy(Column.FieldName, 2, 3));
    //найдем левую и правую границу заполненной области
    i := 0;
    j := 0;
    for k := 1 to S.NInt(nedt_deadline.Value) do
      if (i = 0) and (FrgDays.GetValueI('d' + IntToStr(k), FrgDays.RecNo - 1, False) <> 0) then
        i := k;
    for k := S.NInt(nedt_deadline.Value) downto 1 do
      if (j = 0) and (FrgDays.GetValueI('d' + IntToStr(k), FrgDays.RecNo - 1, False) <> 0) then
        j := k;
    if FrgDays.RecNo - 1 <= FrgDays.GetCount(False) - 1 - Length(cOrderReglamentSnTypes) then begin
      if (i = 0) and (j = 0) then begin
        i := p;
        j := p;
      end
      else if (j = i) and (i = p) then  begin
        i := 0;
        j := 0;
      end
      else if lc then begin
        i := p;
        if j < i then
          j := i;
      end
      else if rc then begin
        j := p;
        if i > j then
          i := j;
      end;
    end
    else begin
      if (i = 0) and (j = 0) then begin
        i := 1;
        j := p;
      end
      else if (j = i) and (i = p) then  begin
        i := 0;
        j := 0;
      end
      else begin
        i := 1;
        j := p;
      end;
      F.SetProp('sn_' + IntToStr(Length(cOrderReglamentSnTypes) - (FrgDays.GetCount(False) - FrgDays.RecNo)), p);
    end;
    for k := 1 to S.NInt(nedt_deadline.Value) do
      FrgDays.SetValue('d' + IntToStr(k), FrgDays.RecNo -1, False , S.IIf((k >= i) and (k <= j), k, null));
    FrgDays.DbGridEh1.Invalidate;
  end
  else if (Column.FieldName = 'name') and (lc or rc) then begin
    if dlgColor1.Execute then
      FrgDays.SetValue('color', FrgDays.RecNo -1, False, dlgColor1.Color);
    FrgDays.DbGridEh1.Invalidate;
  end;
end;

procedure TFrmOWedtOrReglament.FrgPropertiesColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
  Fr.SetValue('', Value, True);
  GetPropertiesResult;
end;

procedure TFrmOWedtOrReglament.FrgDaysColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
end;

procedure TFrmOWedtOrReglament.FrgDaysColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if Fr.GetValue('posstd') = null then
  else if Fr.GetValueI('posstd') > 0 then
    Params.Background := RGB(240, 240, 255)
  else if Fr.GetValueI('posstd') = 0 then
    Params.Background := RGB(240, 255, 240);
  if (Pos('d', FieldName) = 1) and (Fr.GetValueI('color') <> 0) and (Fr.GetValueI(FieldName) <> 0) then
    Params.Background := Fr.GetValueI('color');
end;


end.
