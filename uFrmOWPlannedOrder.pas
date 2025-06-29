(*
Диалог ввода планового заказа или предзаказа.

На данный момент реализован только ввод планового заказа на основе производственного шаблона,
нестандартные плановые заказы и предзаказы не реализованы.

афди шаблона передается в AddParam

сделано на основе новой формы, с использованием массива параметров и нового фрейма для грида, тестируется! будет переделываться!

данные шапки заполняются на основе шаблона, кроме времени действия паспорта и галок плановый и предзаказ
строки таблицы заполняются на сонове шаблона, удалить их нельзя. если шаблон был изменен, строки, которых еще нет в
паспорте, будут добавлены (с сообщением) при его редактировании. если строки в шаблоне были удалены, то в этом ПЗ
они останутся!

ввод данных за предеом диапозона дат невозможен!

*)

unit uFrmOWPlannedOrder;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, DBCtrlsEh, Vcl.Mask,
  DBGridEh, DBAxisGridsEh, DateUtils, Math,
  uFrmBasicMdi, uFrDBGridEh, uFrmBasicDbDialog
  ;

type
  TFrmOWPlannedOrder = class(TFrmBasicDbDialog)
    pnlTop: TPanel;
    pnlCenter: TPanel;
    pnlTopFields: TPanel;
    nedt_num: TDBNumberEditEh;
    dedt_dt: TDBDateTimeEditEh;
    dedt_dt_change: TDBDateTimeEditEh;
    edt_ProjectName: TDBEditEh;
    chb_is_plannedorder: TDBCheckBoxEh;
    chb_is_preorder: TDBCheckBoxEh;
    dedt_dt_start: TDBDateTimeEditEh;
    dedt_dt_end: TDBDateTimeEditEh;
    edt_UserName: TDBEditEh;
    pnlTopFiles: TPanel;
    pnlTopComment: TPanel;
    mem_Comm: TDBMemoEh;
    bvl1: TBevel;
    lblCaptionFiles: TLabel;
    FrgFiles: TFrDBGridEh;
    pnlGrid: TPanel;
    Frg1: TFrDBGridEh;
    edt_TemplateName: TDBEditEh;
    edt_FormatName: TDBEditEh;
    procedure Frg1DbGridEh1Enter(Sender: TObject);
  private
    { Private declarations }
    InControlOnChange : Boolean;
    IsTemplateChanged : Boolean;            //в списке изделий родительского шаблона были изменения по отношению к составу планового заказа
    IsPeriodChanged: Boolean;
    function  Prepare: Boolean; override;
    function  VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean; override;
    function  LoadTable(): Boolean;
    function  SaveTable(): Boolean;
    function  Load: Boolean; override;
    function  Save: Boolean; override;
    procedure AfterStart; override;
    procedure TableRowCalculate(RecNo: Integer);
    function  TableCutOff: Boolean;
    procedure TableSetColumnsEditable;
    procedure ControlOnChange(Sender: TObject); override;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; EditMode: Boolean; Params: TColCellParamsEh);
  public
    { Public declarations }
  end;

var
  FrmOWPlannedOrder: TFrmOWPlannedOrder;

implementation

uses
  uWindows,
  uString,
  uForms,
  uDBOra,
  uMessages,
  uData,
  uErrors,
  uPrintReport,
  uOrders,
  ufields
  ;


{$R *.dfm}

function TFrmOWPlannedOrder.Prepare: Boolean;
var
  crd: TCoord;
  v: Variant;
  va2: TVarDynArray2;
  va: TVarDynArray;
  ca : TControlArray;
  st, st2: string;
  i: Integer;
begin
  Caption:='Плановый заказ';
  F.DefineFields:=[
    ['id$i'],
    ['num$i;0'],   //номер документа, устанавливается в триггере
    ['dt$d', #0, Date],
//    ['dt_change$d',#0,S.IIf(Mode = fEdit, Now, null),0],
    ['dt_change$d'],    //дата изменения документа, устновим в момент редактирования
    ['projectname$s;project$s','V=1:500'],
    ['formatname$s;0'],
    ['templatename$s;0'],
    ['is_plannedorder$i'],
    ['is_preorder$i'],
    ['dt_start$d','V=*'],
    ['dt_end$d','V=*'],
    ['username$s;0',#0,User.GetName],
    ['comm$s'],
    ['id_user$i',#0,User.GetId],
    ['id_template$i'],
    ['id_or_format_estimates$i']
  ];
  View:='v_planned_orders';
  Table:='planned_orders';
  //Opt.RequestWhereClose:= cqYNC;
  FOpt.InfoArray:= [
    [
    'Ввод данных палнового заказа.'#13#10#13#10+
    'Шапка и таблица изделий заполнены на основании выбранного шаблона.'#13#10+
    'В шапке заказа необходимо выбрать период действия заказа'#13#10+
    '(Начальная дата не ранее текущего месяца, и не позднее месяца следующего года,'#13#10+
    'конечная дата не позднее декабря того же года. Число в календаре при выборе даты не имеет значения,'#13#10+
    'можно выбрать любое)'#13#10+
    'Также необходимо выбрать тип заказа (плановый и/или предзаказ).'#13#10+
    '(работа с предзаказами пока не реализована!)'#13#10+
    'В таблице введите количество изготавливаемых изделий в нужных ячейках.'#13#10+
    'Чтобы очистить ячейку, можно ввести 0 или пустую строку.'#13#10+
    'Ввод в ячейки за пределами периода действия заказа невозможен!'#13#10+
    ''#13#10+
    'Внимание! Если заказ (или сметы изделий) были изменены, отчеты автоматически не скорректируются,'#13#10+
    'их надо будет обновить!'#13#10 ,
    Mode in [fAdd, fEdit, fCopy]],
    ['Нажмите "Удалить" для безвозвратного удаления данного планового заказа.', Mode = fDelete],
    ['Просмотр планового заказа. Показыны только изделия, которые будут производиться по данному заказу.', Mode = fView]
  ];

//  if not inherited then Exit;

  F.PrepareDefineFieldsAdd;
  F.SetProps('num;dt;dt_change;projectname;formatname;templatename;username', [[0, fvtDsbl]]);
//  FOpt.DlgPanelStyle := dpsBottomRight;
  FOpt.DlgPanelStyle := dpsTopLeft;
  FOpt.RefreshParent := True;
  FOpt.StatusBarMode := stbmDialog;
  Cth.MakePanelsFlat(pnlFrmClient, []);

  if Mode = fAdd then begin
    if AddParam <> null then begin
      va2:=Q.QLoadToVarDynArray2(
        'select id as id_template, templatename, project as projectname, id_or_format_estimates, (select name from or_formats where id = id_format) as formatname from orders where id = :id$i',
        [AddParam]
      );
     F.SetPropsFromSelect(va2);
     F.SetProp('projectname', False, fvtDsbl);
     F.SetProp('projectname', '', fvtFNameS);
    end
    else begin
      F.SetProp('projectname', 1, fvtDsbl);
      F.SetProp('is_preorder', 1, fvtVBeg);
      F.SetProps('is_preorder;is_plannedorder', [[0, fvtDsbl]]);
    end;
    try
      F.SetProp('num', StrtoInt(Q.QCallStoredProc('p_GetDocumNum', 'd$s;y$i;n$io;ns$i;yp$i;dg$i', ['planned_order', YearOf(Date), -1, 1, 1, 4])[2]), fvtVBeg);
    except
    end;
    F.SetPropsControls;
  end
  else begin
    Load;
    F.SetProp('id', ID);
    if Mode = fEdit then
      F.SetProp('dt_change', Now, fvtVBeg);
    F.SetPropsControls;
    if Mode in [fView, fDelete] then
      SetControlsEditable([], False);
  end;


  if ((Mode = fAdd)and(AddParam = null))or(False) then begin
    FreeAndNil(edt_TemplateName);
    FreeAndNil(edt_FormatName);
  end;

  //pnlTopFiles.Width:=250;
  crd := Cth.AlignControls(pnlTopFields, [], True);
  pnlTop.Height := crd.Y;
  crd := Cth.AlignControls(pnlTopComment, [], False);
//  mem_Comm.Height := mem_Comm.Height - MY_FORMPRM_V_TOP;
  mem_Comm.Height := pnlTopComment.Height - mem_Comm.Top - MY_FORMPRM_V_TOP;
  mem_Comm.Width:=pnlTopComment.Width - MY_FORMPRM_H_EDGES * 2;
  mem_Comm.Tag:=-100;
  FWHBounds.X := pnlTopFields.Width + 300 + pnlTopFiles.Width;
  FWHBounds.Y := 400;
  //настроим фрейм гида
  FrgFiles.Align:=alNone;
  lblCaptionFiles.Top:= mem_Comm.ControlLabel.Top;
  lblCaptionFiles.Left:=MY_FORMPRM_H_EDGES;
  FrgFiles.Top:=mem_Comm.Top;
  FrgFiles.Left:=MY_FORMPRM_H_EDGES;
  FrgFiles.Height:=mem_Comm.Height;
  FrgFiles.Options:=[myogIndicatorColumn, myogColoredTitle, myogHiglightEditableCells, myogHiglightEditableColumns, myogMultiSelect{, myogIndicatorCheckBoxes}];
  FrgFiles.Opt.SetDataMode(myogdmFromArray);
  FrgFiles.Opt.SetFields([['name$s', 'Наименование файла', '300']]);
//  FrgFiles.pnlLeft.Visible:=True;FrgFiles.pnlLeft.width:=26;
//  FrgFiles.Opt.S(gotButtons, 1, [[mbtAdd], [mbtDelete], [mbtView]], 80);//, FrgFiles.pnlLeft, 0, True);//, FrgFiles.pnlLeft, 0, True);
//  FrgFiles.Opt.S(gotButtons, 2, [[mbtAdd], [mbtDelete], [mbtView]], 80, FrgFiles.pnlLeft, 0, True);//, FrgFiles.pnlLeft, 0, True);
//  FrgFiles.Opt.S(gotAllowedOperations, [alopUpdateEh]);
  //подготовим фрейм грида
  FrgFiles.Prepare;
  FrgFiles.DbGridEh1.Left:= FrgFiles.pnlLeft.Width + 1;
  FrgFiles.DbGridEh1.FindFieldColumn('name').TextEditing := False;
  FrgFiles.DbGridEh1.Options:=FrgFiles.DbGridEh1.Options -[ dgTitles];

  Frg1.Options:=[myogIndicatorColumn, myogColoredTitle, myogHiglightEditableCells, myogHiglightEditableColumns{, myogMultiSelect, myogIndicatorCheckBoxes}];
  Frg1.Opt.SetDataMode(myogdmFromArray);
  va2 := [['id$i', '_id'], ['id_std_item$i', '_idi'], ['ch$i', '_ch', '20'], ['name$s', 'Изделие', '400;W;H'], ['price$f', 'Цена', '45']];
  st := 'comm';
  st2 := 'qnt;sum';
  for i:= 1 to 12 do begin
    va2 := va2 + [
      ['qnt' + InttoStr(i) + '$i', MonthsRu[i] + '|Кол.', '35', 'f=#:0'],
      ['sum' + InttoStr(i) + '$i', MonthsRu[i] + '|Сумма', '55', 'f=#:0']
    ];
//    S.ConcatStP(st, 'qnt' + InttoStr(i), ';');
    S.ConcatStP(st2, 'qnt' + InttoStr(i) + ';sum' + InttoStr(i), ';');
  end;
  va2 := va2 + [['qnt$i', 'Кол-во', '50', 'f=#:0'], ['sum$i', 'Сумма', '70', 'f=0:0'], ['comm$s', 'Дополнение', '200;W;H']];
  Frg1.Opt.SetFields(va2);
  Frg1.OnColumnsUpdateData:= Frg1ColumnsUpdateData;
//  Frg1.OnColumnsGetCellParams := Frg1ColumnsGetCellParams;

  TableSetColumnsEditable;
//  Frg1.Opt.S(gotButtons, 2, [[mbtAdd], [-mbtDelete], [mbtView]], 4, Frg1.pnlLeft, 0, True);

//  Frg1.Cprop.Value:='11111';

//  Frg1.OnColumnsGetCellParams:=Frg1ColumnsGetCellParams;
//  Frg1.OnSelectedDataChange:= Frg1ChangeSelectedData;
  Frg1.Prepare;

  if F.GetProp('id_template', fvtVBeg) <> null then
    LoadTable;

  Result:=True;


  ca:=Cth.GetChildControls(Self);
  va:=Cth.GetChildControlNames(Self);
  va:=Cth.GetOwneredControlNames(Self);
  va:=Cth.GetOwneredControlNames(FrgFiles);

  i:=Self.ComponentCount;
  i:=TComponent(Self).ComponentCount;

  if FrgFiles.DbGridEh1.Owner = FrgFiles
    then begin
      st:=Self.name;
    end;

  st := Frg1.DynProps.FindDynVar('vvv').AsString;
    ;
  //Frg1.DbGridEh1.Owner
                             // tframe
end;

function TFrmOWPlannedOrder.VerifyAdd(Sender: TObject; onInput: Boolean = False): Boolean;
var
  PropName: string;
begin
//
//  if Sender = nil then Exit;
//  PropName := GetProp(TControl(Sender).Name, fvtVName);
//  if A.InArray(PropName, ['is_plannedorder', 'is_preorder']) then begin
//    if (GetProp('is_plannedorder') = 0)and(GetProp('is_preorder') =0) then begin
//      SetProp('is_plannedorder', True, fvtErr);
//      SetProp('is_preorder', True, fvtErr);
//    end;
    F.SetProp('is_plannedorder', (F.GetProp('is_plannedorder') = 0)and(F.GetProp('is_preorder') =0) , fvtErr);
    F.SetProp('is_preorder', (F.GetProp('is_plannedorder') = 0)and(F.GetProp('is_preorder') =0) , fvtErr);
//    SetProp('is_plannedorder', True , fvtErr);
end;

procedure TFrmOWPlannedOrder.ControlOnChange(Sender: TObject);
//обработка событий изменения контролов
var
  dt: TDateTime;
begin
  if InControlOnChange then
    Exit;
  InControlOnChange := True;
  repeat
    if Sender = dedt_dt_start then begin
      //начальная дата периода документа
      //исправляем на первое число введенного месяца, не ранее месяц создания заказа и не позднее 31-12-YY+1
      if not S.IsDateTime(S.NSt(dedt_dt_start.Value)) then
        Break;
      dt := Cth.GetControlValue(dedt_dt_start);
      if (dt < F.GetProp('dt')) or (YearOf(dt) > YearOf(F.GetProp('dt')) + 1) then
        dt := F.GetProp('dt');
      dt := EncodeDateTime(YearOf(dt), MonthOf(dt), 1, 0, 0, 0, 0);
      if S.IsDateTime(S.NSt(dedt_dt_end.Value)) and (dedt_dt_end.Value < dt) then begin
        dedt_dt_end.Value := EncodeDateTime(YearOf(dt), 12, 31, 0, 0, 0, 0);
      end;
      dedt_dt_end.SetFocus;
      dedt_dt_start.Value := dt;
      IsPeriodChanged := True;
    end;
    if Sender = dedt_dt_end then begin
      if not S.IsDateTime(S.NSt(dedt_dt_start.Value)) then
        Break;
      if not S.IsDateTime(S.NSt(dedt_dt_end.Value)) then
        Break;
      dt := Cth.GetControlValue(dedt_dt_end);
      dt := EncodeDateTime(YearOf(dt), MonthOf(dt), DaysInMonth(dt), 0, 0, 0, 0);
      if (YearOf(dt) <> YearOf(dedt_dt_start.Value)) or (dedt_dt_start.Value > dt) then
        dt := EncodeDateTime(YearOf(dedt_dt_start.Value), 12, 31, 0, 0, 0, 0);
      dedt_dt_start.SetFocus;
      dedt_dt_end.Value := dt;
      IsPeriodChanged := True;
    end;
  until True;
  inherited;
  InControlOnChange := False;
end;

function TFrmOWPlannedOrder.LoadTable(): Boolean;
var
  va1, va2: TVarDynArray2;
  b: Boolean;
  i, j: Integer;
begin
    va1 := Q.QLoadToVarDynArray2(
      'select null, id_std_item, 0, itemname, price from v_order_items where id_order = :id$i order by pos',
      [F.GetProp('id_template', fvtVBeg)]
    );
    va2 := [];
    if (Mode <> fAdd) then begin
      va2 := Q.QLoadToVarDynArray2(
        'select id, id_std_item, 0, itemname, itemprice, '+
        'qnt1, null, qnt2, null, qnt3, null, qnt4, null, qnt5, null, qnt6, null, '+
        'qnt7, null, qnt8, null, qnt9, null, qnt10, null, qnt11, null, qnt12, null,'+
        'null, null, comm '+
        'from v_planned_order_items where (id_planned_order = :id$i) '+
        S.IIFStr(Mode = fView, 'and (qnt <> 0) ')+
        'order by pos',
        [ID]
      );
    end;
    if Mode in [fEdit] then begin
      IsTemplateChanged := High(va1) <> High(va2);
      for i:=0 to High(va1) do begin
        for j := 0 to High(va2) do begin
          if va1[i][1] = va2[j][1] then Break;
        end;
        if j > High(va2) then begin
          va2 := va2 + [[
            va1[i][0], va1[i][1], va1[i][2], va1[i][3], va1[i][4],
            null,null,null,null,null,null,null,null,null,null,null,null,
            null,null,null,null,null,null,null,null,null,null,null,null,
            null,null,null
          ]];
          IsTemplateChanged := True;
        end;
      end;
      //статус, что грид изменен
      Frg1.SetState(IsTemplateChanged, null, null);
    end
    else if Mode = fAdd then begin
      va2 := va1;
    end;
//    Frg1.LoadSourceDataFromArray(va2, 'id;id_std_item;name;qnt1;qnt2;qnt3;qnt4;qnt5;qnt6;qnt7;qnt8;qnt9;qnt10;qnt11;qnt12;comm');
    Frg1.LoadSourceDataFromArray(va2);
    for i := 0 to Frg1.RecordCount - 1 do
      TableRowCalculate(i);
end;

function TFrmOWPlannedOrder.SaveTable(): Boolean;
var
  i, j: Integer;
  SaveMode : string;
begin
  for i := 0 to Frg1.GetCount - 1 do begin
    SaveMode := '';
    if Frg1.GetValue('id', i) = null
      then SaveMode := 'i'
      else if Frg1.GetValue('ch', i) = 1
        then SaveMode := 'u';
    if SaveMode = '' then Continue;
    if Q.QIUD(
      SaveMode, 'planned_order_items', '',
      'id$i;id_std_item$i;id_planned_order$i;comm$s;qnt1$i;qnt2$i;qnt3$i;qnt4$i;qnt5$i;qnt6$i;qnt7$i;qnt8$i;qnt9$i;qnt10$i;qnt11$i;qnt12$i',
      [Frg1.GetValue('id', i), Frg1.GetValue('id_std_item', i), ID, Frg1.GetValue('comm', i),
       Frg1.GetValue('qnt1', i),Frg1.GetValue('qnt2', i),Frg1.GetValue('qnt3', i),Frg1.GetValue('qnt4', i),Frg1.GetValue('qnt5', i),Frg1.GetValue('qnt6', i),
       Frg1.GetValue('qnt7', i),Frg1.GetValue('qnt8', i),Frg1.GetValue('qnt9', i),Frg1.GetValue('qnt10', i),Frg1.GetValue('qnt11', i),Frg1.GetValue('qnt12', i)
      ]
      ) < 0 then
        Break;
  end;
end;


function TFrmOWPlannedOrder.Load(): Boolean;
//загрузка данных
//по уже подготовленным глобальным переменным, также в глобальную CtrlValues
//результат пока не влияет ни на что, если не был получен массив, далее проверяется и выдается сообщениеоб удаленной строке
var
  FieldsSt: string;
  CtrlValues: TVarDynArray;
  i: Integer;
begin
  for i := 0 to F.Count do
    if F.GetProp(i, fvtFNameL) <> '' then begin
      S.ConcatStP(FieldsSt, F.GetProp(i, fvtFNameL), ';');
    end;
  CtrlValues := Q.QLoadToVarDynArrayOneRow(Q.QSIUDSql('s', View, FieldsSt), [id]);
  for i := 0 to F.Count do
    if F.GetProp(i, fvtFNameL) <> '' then begin
      F.SetPropP(i, CtrlValues[i], fvtVBeg);
    end;
  Result := True;
end;

function TFrmOWPlannedOrder.Save(): Boolean;
//сохранение данных
var
  ChildHandled: Boolean;
  i, res: Integer;
  CtrlValues2: TVarDynArray;
  FieldsSave2: string;
begin
  Result := False;
  //останемся в диалоге заказа, если проверка вернула что есть данные за пределами диапозона дат, и не было подтверждено их удаление
  if TableCutOff then
    Exit;
  FieldsSave2 := '';
  CtrlValues2 := [];
  //получим поля и их значения, по тем для которых указано сохранение
  for i := 0 to F.Count do
    if F.GetProp(i, fvtFNameS) <> '' then begin
      S.ConcatStP(FieldsSave2, F.GetProp(i, fvtFNameS), ';');
      CtrlValues2 := CtrlValues2 + [S.NullIfEmpty(F.GetProp(i, fvtVCurr))];
    end;
  //сохраняем заголовочную часть
  Q.QBeginTrans(True);
  res := Q.QIUD(Q.QFModeToIUD(Mode), Table, Sequence, FieldsSave2, CtrlValues2);
  IdAfterInsert:= res;
  if not (Mode in [fEdit, fDelete]) then
    ID := res;
  if not (Mode in [fDelete]) then
    SaveTable;
  Result := Q.QCommitOrRollback;
end;

procedure TFrmOWPlannedOrder.Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
//событие изменения данных в редактируемых столбцах вручную
var
  v : Variant;
begin
  if Frg1.CurrField = 'comm' then begin
    Frg1.SetValue('', Value);
    Frg1.SetValue('ch', Frg1.RecNo - 1, False, 1);
  end
  else begin
    if not S.IsNumber(S.NSt(Value), 0, 100000000, 0) then
      Value := null;
    Frg1.SetValue('', Value);
    //пометка, что данные строки были изменены
    Frg1.SetValue('ch', Frg1.RecNo - 1, False, 1);
    //посчитаем сумму и кол-во в строке
    //RecNo - 1 так  как в функции ниже используется прямой доступ к записям массива, начиная с 0
    TableRowCalculate(Frg1.RecNo - 1);
    //статус, что грид изменен
    Frg1.SetState(True, null, null);
  end;
  //Verify(nil);
  Handled := True;
end;

procedure TFrmOWPlannedOrder.Frg1DbGridEh1Enter(Sender: TObject);
//переход в таблицу изделий
begin
  inherited;
  if IsPeriodChanged then begin
    //если был изменен период дат
    IsPeriodChanged := False;
    //проверим, есть ли данные за границами диапазона дат, выведем сообщение и их удалим
    TableCutOff;
  end;
end;

procedure TFrmOWPlannedOrder.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; EditMode: Boolean; Params: TColCellParamsEh);
//установка параметров ячейки
var
  m, m1, m2: Integer;
begin
//Params.ReadOnly := False;exit;
  //если не задана начальная либо конечная дата, то запретим ввод данных
  //иначе запретим ввод данных ранее начальной и позднее конечно
  if (Frg1.CurrField = 'qnt') or (Pos('qnt', Frg1.CurrField) = 0) then
    Exit;
  if not S.IsDateTime(S.NSt(dedt_dt_start.Value)) or not S.IsDateTime(S.NSt(dedt_dt_end.Value)) then begin
    Params.ReadOnly := True;
    Exit;
  end;
  m := StrToInt(Copy(Frg1.CurrField, 4));
  m1 := MonthOf(dedt_dt_start.Value);
  m2 := MonthOf(dedt_dt_end.Value);
  if (m < m1) or (m > m2) then
    Params.ReadOnly := True;
end;

procedure TFrmOWPlannedOrder.TableRowCalculate(RecNo: Integer);
//посчитаем суммы в строке (вызывается при загрузке и OnUpdate)
var
  v: Variant;
  e, sm, q, p: Extended;
  i, j: Integer;
begin
  q := 0;
  sm := 0;
  //цена (полная, включая перепродажу)
  p := S.NNum(Frg1.GetValue('price', RecNo));
  for i := 1 to 12 do begin
    v := Frg1.GetValue('qnt' + IntToStr(i), RecNo);
    e := S.NNum(v);
    q := q + e;
    sm := sm + p * e;
    //сумма по данной ячейке
    Frg1.SetValue('sum' + IntToStr(i), RecNo, False, S.IIf(v = null, null, Round(e * p)));
  end;
  //количество и сумма в строке общии
  Frg1.SetValue('qnt', RecNo, False, q);
  Frg1.SetValue('sum', RecNo, False, sm);
  //посчитаем данные в футере (не пересчитываются автоматом из-за использования прямого доступа)
  Frg1.DBGridEh1.SumList.RecalcAll;
end;

procedure TFrmOWPlannedOrder.TableSetColumnsEditable;
//установим редактируемые колонки в соответствии с заданным диапаозоном дат паспорта и режимом открытия документа
var
  i: Integer;
  st: string;
begin
  st := '';
  if S.IsDateTime(S.NSt(dedt_dt_start.Value)) and S.IsDateTime(S.NSt(dedt_dt_end.Value)) then
    for i:= MonthOf(dedt_dt_start.Value) to MonthOf(dedt_dt_end.Value) do
      S.ConcatStP(st, 'qnt' + InttoStr(i), ';');
  Frg1.Opt.SetColFeature(st, 'e', not (Mode in [fView, fDelete]), True);
end;

function TFrmOWPlannedOrder.TableCutOff: Boolean;
var
  i, m, m1, m2: Integer;
  b : Boolean;
begin
  Result := True;
  TableSetColumnsEditable;
  if not S.IsDateTime(S.NSt(dedt_dt_start.Value)) or not S.IsDateTime(S.NSt(dedt_dt_end.Value)) then
    Exit;
  m1 := MonthOf(dedt_dt_start.Value);
  m2 := MonthOf(dedt_dt_end.Value);
  Result := False;
  for i := 0 to Frg1.GetCount - 1 do
    for m := 1 to 12 do
      if ((m < m1) or (m > m2)) and(Frg1.GetValue('qnt' + IntToStr(m), i) <> null)  then begin
        Result := True;
        Break;
      end;
  if not Result then Exit;
  if MyQuestionMessage(
    'В табличной части введены данные за периоды, не входящие в период действия заказа!'#13#10'Эти данные будут очищены.'#13#10'Продолжить?'
  ) <> mrYes then
    Exit;
  for i := 0 to Frg1.GetCount - 1 do begin
    for m := 1 to 12 do
      if ((m < m1) or (m > m2)) and(Frg1.GetValue('qnt' + IntToStr(m), i) <> null)  then begin
         Frg1.SetValue('qnt' + IntToStr(m), i, False, null);
         Frg1.SetValue('ch', i, False, 1);
      end;
    TableRowCalculate(i);
  end;
  Result := False;
end;


procedure TFrmOWPlannedOrder.AfterStart;
//вызывается после отображения формы
begin
  if IsTemplateChanged then
    MyInfoMessage('Родительский шаблон был изменен!'#13#10'Новые позиции добавлены в спецификацию планового заказа.');
end;



end.
