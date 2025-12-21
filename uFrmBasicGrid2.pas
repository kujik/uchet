unit uFrmBasicGrid2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uFrmBasicMdi, uFrDBGridEh
  ;

type
  TFrmBasicGrid2 = class(TFrmBasicMdi)
    pnlTop: TPanel;
    pnlBottom: TPanel;
    pnlLeft: TPanel;
    pnlGrid1: TPanel;
    Frg1: TFrDBGridEh;
    imgTemp: TImage;
    Frg2: TFrDBGridEh;
    pnlFrg2: TPanel;
    pnlRight: TPanel;
    {обработчики событий, определенные в данном классе. в потомках должны бьть расположены в этой же секции}
    //в этом событии в основном раскрашиваем текст и фон ячеек; в потомках обязательно вызывает inherited
    procedure Frg1DbGridEh1GetCellParams(Sender: TObject; Column: TColumnEh; AFont: TFont; var Background: TColor; State: TGridDrawState); virtual;
    procedure Frg2DbGridEh1GetCellParams(Sender: TObject; Column: TColumnEh; AFont: TFont; var Background: TColor; State: TGridDrawState); virtual;
    procedure tmrAfterCreateTimer(Sender: TObject);
  private
    procedure FrgSetEvents(AFrg: TFrDBGridEh);
  protected
    //основная функция формы
    function  Prepare: Boolean; override;
    function  PrepareForm: Boolean; virtual;

    //события первого (основного) фрейма грида
    procedure Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); virtual;
    procedure Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); virtual;
    procedure Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); virtual;
    function  Frg1OnFilterExecute(var Fr: TFrDBGridEh; const No: Integer; var Handled: Boolean): string; virtual;
    //здесь устанавливаем переменную where-часть запроса и инициализируем параметры в запросе
    //(вызывается дважды, первый раз для конструирования запроса, затем утанавливает параметры в уже готьовом запросе, потому их установку делать с флагом пропуска
    procedure Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); virtual;
    procedure Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); virtual;
    procedure Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); virtual;
    //здесь мождем устанавливать параметры ячейки (номер картинки, readonly) в зависимости от данных в текущей записи
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); virtual;
    //двойной клик в таблице
    //по умолчанию вызывает редактирование или просмотр записи
    procedure Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); virtual;
    procedure Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); virtual;
    //dbgvBefore - можно введенное поправить значение или вернуть сообщение об ошибке
    //dbgvCell - после записи введенного значения и обновления строки, передеется отфильтрованная строка в мемтейбл с 1
    procedure Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string); virtual;
    procedure Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); virtual;
    procedure Frg1RowDetailPanelShow(var Fr: TFrDBGridEh; const No: Integer; var Hnadled: Boolean; var CanShow: Boolean); virtual;


    //события второго (в rorowDetailPanel) фрейма грида
    procedure Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean); virtual;
    procedure Frg2CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); virtual;
    procedure Frg2SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer); virtual;
    function  Frg2OnFilterExecute(var Fr: TFrDBGridEh; const No: Integer; var Handled: Boolean): string; virtual;
    //здесь устанавливаем переменную where-часть запроса и инициализируем параметры в запросе
    //(вызывается дважды, первый раз для конструирования запроса, затем утанавливает параметры в уже готьовом запросе, потому их установку делать с флагом пропуска
    procedure Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string); virtual;
    procedure Frg2ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean); virtual;
    procedure Frg2AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject); virtual;
    //здесь мождем устанавливать параметры ячейки (номер картинки, readonly) в зависимости от данных в текущей записи
    procedure Frg2ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); virtual;
    //двойной клик в таблице
    //по умолчанию вызывает редактирование или просмотр записи
    procedure Frg2OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean); virtual;
    procedure Frg2GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean); virtual;
    procedure Frg2VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string); virtual;
    procedure Frg2CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean); virtual;
  public
  end;

var
  FrmBasicGrid2: TFrmBasicGrid2;

  bbb:Boolean;

implementation

uses



  uErrors,

  uWindows
  ;


{$R *.dfm}


function TFrmBasicGrid2.PrepareForm: Boolean;
begin
  if Length(Frg1.Opt.Sql.FieldsDef) = 0 then begin
    MyWarningMessage('Ошибка! FormDoc не найден или основной грид не задан!');
    Exit;
  end;
  if Length(Frg2.Opt.Sql.FieldsDef) > 0 then
    Frg2.Prepare;
  Frg1.Grid2 := Frg2;
  Frg1.Prepare;
  Frg1.RefreshGrid;
  Result := True;
end;


procedure TFrmBasicGrid2.tmrAfterCreateTimer(Sender: TObject);
begin
  inherited;
end;

{=========================  СОБЫТИЯ ПЕРВОГО ГРИДА =============================}

procedure TFrmBasicGrid2.Frg1ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
end;

procedure TFrmBasicGrid2.Frg1CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
end;

procedure TFrmBasicGrid2.Frg1SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
end;

function  TFrmBasicGrid2.Frg1OnFilterExecute(var Fr: TFrDBGridEh; const No: Integer; var Handled: Boolean): string;
begin
end;

procedure TFrmBasicGrid2.Frg1OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
end;

procedure TFrmBasicGrid2.Frg1ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
end;

procedure TFrmBasicGrid2.Frg1AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
end;

procedure TFrmBasicGrid2.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
end;

procedure TFrmBasicGrid2.Frg1GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
end;

procedure TFrmBasicGrid2.Frg1VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string);
begin
end;

procedure TFrmBasicGrid2.Frg1CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
begin
end;

procedure TFrmBasicGrid2.Frg1RowDetailPanelShow(var Fr: TFrDBGridEh; const No: Integer; var Hnadled: Boolean; var CanShow: Boolean);
begin
end;

procedure TFrmBasicGrid2.Frg1OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
end;

procedure TFrmBasicGrid2.Frg1DbGridEh1GetCellParams(Sender: TObject; Column: TColumnEh; AFont: TFont; var Background: TColor; State: TGridDrawState);
begin
  inherited;
  Frg1.DbGridEh1GetCellParams(Sender, Column, AFont, Background, State);
end;


{=========================  СОБЫТИЯ ВТОРОГО ГРИДА =============================}

procedure TFrmBasicGrid2.Frg2ButtonClick(var Fr: TFrDBGridEh; const No: Integer; const Tag: Integer; const fMode: TDialogType; var Handled: Boolean);
begin
end;

procedure TFrmBasicGrid2.Frg2CellButtonClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
end;

procedure TFrmBasicGrid2.Frg2SelectedDataChange(var Fr: TFrDBGridEh; const No: Integer);
begin
end;

function  TFrmBasicGrid2.Frg2OnFilterExecute(var Fr: TFrDBGridEh; const No: Integer; var Handled: Boolean): string;
begin
end;

procedure TFrmBasicGrid2.Frg2OnSetSqlParams(var Fr: TFrDBGridEh; const No: Integer; var SqlWhere: string);
begin
end;

procedure TFrmBasicGrid2.Frg2ColumnsUpdateData(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
end;

procedure TFrmBasicGrid2.Frg2DbGridEh1GetCellParams(Sender: TObject; Column: TColumnEh; AFont: TFont; var Background: TColor; State: TGridDrawState);
begin
  Frg2.DbGridEh1GetCellParams(Sender, Column, AFont, Background, State);
end;

procedure TFrmBasicGrid2.Frg2AddControlChange(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject);
begin
end;

procedure TFrmBasicGrid2.Frg2ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
end;

procedure TFrmBasicGrid2.Frg2GetCellReadOnly(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var ReadOnly: Boolean);
begin
end;

procedure TFrmBasicGrid2.Frg2OnDbClick(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; var Handled: Boolean);
begin
end;

procedure TFrmBasicGrid2.Frg2VeryfyAndCorrect(var Fr: TFrDBGridEh; const No: Integer; Mode: TFrDBGridVerifyMode; Row: Integer; FieldName: string; var Value: Variant; var Msg: string);
begin
end;

procedure TFrmBasicGrid2.Frg2CellValueSave(var Fr: TFrDBGridEh; const No: Integer; FieldName: string; Value: Variant; var Handled: Boolean);
begin
end;



{==============================================================================}

procedure TFrmBasicGrid2.FrgSetEvents(AFrg: TFrDBGridEh);
//установим события переданного фрейма
begin
  AFrg.Options:= FrDBGridOptionDef + FrDBGridOptionRefDef;
  AFrg.Opt.SetDataMode;

  Frg1.Opt.SetPanelsSaved(['*']);

  if AFrg = Frg1 then begin
    AFrg.OnButtonClick := Frg1ButtonClick;
    AFrg.OnCellButtonClick := Frg1CellButtonClick;
    AFrg.OnSelectedDataChange := Frg1SelectedDataChange;
    AFrg.OnSetSqlParams := Frg1OnSetSqlParams;
    AFrg.OnColumnsUpdateData := Frg1ColumnsUpdateData;
    AFrg.OnAddControlChange := Frg1AddControlChange;
    AFrg.OnColumnsGetCellParams := Frg1ColumnsGetCellParams;
    AFrg.OnDbClick := Frg1OnDbClick;
    AFrg.OnGetCellReadOnly := Frg1GetCellReadOnly;
    AFrg.OnVeryfyAndCorrectValues := Frg1VeryfyAndCorrect;
    AFrg.OnCellValueSave := Frg1CellValueSave;
    AFrg.OnRowDetailPanelShow := Frg1RowDetailPanelShow;
  end;

  if AFrg = Frg2 then begin
    AFrg.OnButtonClick := Frg2ButtonClick;
    AFrg.OnCellButtonClick := Frg2CellButtonClick;
    AFrg.OnSelectedDataChange := Frg2SelectedDataChange;
    AFrg.OnSetSqlParams := Frg2OnSetSqlParams;
    AFrg.OnColumnsUpdateData := Frg2ColumnsUpdateData;
    AFrg.OnAddControlChange := Frg2AddControlChange;
    AFrg.OnColumnsGetCellParams := Frg2ColumnsGetCellParams;
    AFrg.OnDbClick := Frg2OnDbClick;
    AFrg.OnGetCellReadOnly := Frg2GetCellReadOnly;
    AFrg.OnVeryfyAndCorrectValues := Frg2VeryfyAndCorrect;
    AFrg.OnCellValueSave := Frg2CellValueSave;
  end;
end;

function TFrmBasicGrid2.Prepare: Boolean;
var
  c: TControl;
begin
  Result := False;
  try
  Cth.MakePanelsFlat(pnlFrmClient, []);
  if pnlTop.Height < 10 then pnlTop.Visible := False;
  if pnlBottom.Height < 10 then pnlBottom.Visible := False;
  if pnlLeft.Width < 10 then pnlLeft.Visible := False;
  if pnlRight.Width < 10 then pnlRight.Visible := False;
  pnlFrg2.Visible := False;

  FrgSetEvents(Frg1);
  FrgSetEvents(Frg2);

  if not PrepareForm then Exit;

  FWHBounds.X := pnlLeft.Width + Frg1.pnlTop.Width + 60;
  FWHBounds.Y := 300;
  Result := True;
  except on E: Exception do begin
    Errors.SetErrorCapt(Self.Name, 'ошибка при обработке FormDoc = ' + FormDoc);
    Application.ShowException(E);
    Errors.SetErrorCapt;
    Cth.SetWaitCursor(False);
    Result := False;
    end;
  end;
end;



end.

(*

    Caption:='Плановые заказы';
    Frg1.Options := Frg1.Options + [myogGridLabels];
    //поля, для работы с датадрайвером можно указывать 'id', для загрузки из массива обязательно 'id$i'
    va2 := [
      ['id','_id'],['id_template','_id_template'],['dt','Дата создания','80'],['num','№'],['dt_start','Начало действия','80'],['dt_end','Окончание действия','80'],
      ['dt_change','Дата изменения'],['std','Стд','40','pic'],['templatename','Шаблон','200'],['projectname','Проект','200'],['sum_all','Сумма','100','f=r:']
    ];
    //добавим динамически
    for i := 1 to 1 do
      va2 := va2 + [['sum'+IntToStr(i), MonthsRu[i], '100','f=r:','t=1']];
    //установим поля, все остальное делать после этого!!!
    Frg1.Opt.SetFields(va2);
    //таблица, точнее здесь вью, но можно передать и таблицу и поле айди
    Frg1.Opt.SetTable('v_planned_orders_w_sum');
    //кнопки, в произвольном месте. если есть доп контролы, обязательно создать btnCtlPanel, ее длина по умолчанию подгонится под контролы
    Frg1.Opt.SetButtons(1,[
      [mbtRefresh],[],[mbtView],[mbtEdit,User.Role(rOr_J_PlannedOrders_Ch)],[mbtCustom_OrderFromTemplate,1],[mbtDelete,1],[],[mbtGridFilter],[],[mbtGridSettings],[mbtCtlPanel{, True, 140}]
    ]);
    //или, если бы не было нестандартных кнопок, можно указать так, кнопки по первым буквам, ревереш, просмотра/редактирования,фильтр,настройки,
    //панель, всега будут те что перечислены в дефолтном фарианте, и роль для всего редактирования, по умолчанию труе
     //Frg1.Opt.SetButtons(1, 'rveacdfsp'? ARight);
    Frg1.Opt.SetButtonsIfEmpty([mbtCustom_OrderFromTemplate]);
    //создаем контролы
    Frg1.CreateAddControls('1', cntCheck, 'По месяцам', 'ChbMonthsSum', '', 4, yrefC, 130);
    //если надо явно обработать контролы сразу, то перечитаем, можем установить их значения, и сделаем зависимые настройки полей
    //в простых случаях можно не делать, контролы прочитаются в Frg1.Prepare, ранее открытия датазета, после чего вызовется событие их изменения
    //(даже если значения контроловн е изменились), где реализуется логика
    //(надо обработать Fr.InPrepare и в этом случае например не делать Refresh или SelcolumnsVisible
    Frg1.ReadControlValues;
    if not (User.Role(rOr_J_Orders_Sum)or(User.Role(rOr_J_Orders_PrimeCost))) then begin
      Cth.SetControlValue(TDBCheckBoxEh(Frg1.FindComponent('ChbViewSum')), 0);
      Frg2.Opt.SetColFeature('1', 'null', True, False);
    end;
    Frg2.Opt.SetColFeature('1', 'i', Cth.GetControlValue(Frg1, 'ChbViewSum') = 0, False);
    //фильтр (help, поля дат если по дате, чевбоксы и правила
    Frg1.Opt.FilterRules := [[], ['dt;dt_start;dt_end;dt_change']];
    //Frg1.Opt.FilterRules := [[], ['dt_beg;dt_otgr;dt_end'], ['Показать себестоимость', 'Sum0', User.Role(rOr_J_Orders_Sum)]];
    //подсказка в строке кнопок сверху
    Frg1.InfoArray:=[
      [Caption + '.'#13#10]
    ];

{    FOpt.StatusBarMode := stbmDialog;
    FOpt.DlgPanelStyle := dpsBottomRight;
    Frg1.Opt.SetButtons(1, [[mbtAdd]], 4, pnlFrmBtnsR);
    FMode := fView;}

      //картинка, в строке через ":"
      //1 - значения полей, через точку с запятой
      //2 - соответствующие им индексы картинок
      //3 - если +, то выводитяяся и текст
      //если ничего не задано, то будет галка для значения "1", если задан только один параметр, то будет галка для него


  //при изменениии контролов в событии, событие onChange не вызывается!
  //чекбоксы с тегом -1..-10 обработаем как радиобаттоны, а -11..-20 так же, но с возможностью снятия

*)


