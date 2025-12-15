unit uFrmWWedtWorkSchedule;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ToolCtrlsEh, DBGridEhToolCtrls,
  GridsEh, DBAxisGridsEh, DBGridEh, PropFilerEh, PropStorageEh, Math,
  Types, DBCtrlsEh, ExtCtrls, Vcl.ComCtrls, Vcl.Mask,
  uFrmBasicMdi, uFrmBasicDbDialog, uFrDBGridEh, uFrMyPanelCaption, uString
  ;

type
  TFrmWWedtWorkSchedule = class(TFrmBasicDbDialog)
    pnlPropertiesC: TPanel;
    frmpcProperties: TFrMyPanelCaption;
    pnlProperties: TPanel;
    edt_name: TDBEditEh;
    chb_active: TDBCheckBoxEh;
    edt_code: TDBEditEh;
    edt_comm: TDBEditEh;
    pnlHoursC: TPanel;
    frmpcHours: TFrMyPanelCaption;
    pnlHours: TPanel;
    cbb_year: TDBComboBoxEh;
    FrgHours: TFrDBGridEh;
    pnlTemplateC: TPanel;
    pnlTemplate: TPanel;
    FrgProperties: TFrDBGridEh;
    frmpcTemplate: TFrMyPanelCaption;
    nedt_duration: TDBNumberEditEh;
    chb_is_individual: TDBCheckBoxEh;
  private
    FHolydays: TVarDynArray2;
    function  Prepare: Boolean; override;
    procedure FrgHoursColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
  public
  end;

var
  FrmWWedtWorkSchedule: TFrmWWedtWorkSchedule;

implementation

uses
  uForms,
  DateUtils
  ;


{$R *.dfm}

function TFrmWWedtWorkSchedule.Prepare: Boolean;
var
  i, j: Integer;
  c: TControl;
  va2: TVarDynArray2;
begin
  Result := False;
//  FWHBounds.Y := 500;
//  FWHBounds.X := 550;
  Caption := 'График работы';
  //поля
  F.DefineFields := [
    ['id$i'],
    ['active$i'],
    ['code$s','V=1:50::T'],
    ['name$s','V=1:400::T'],
    ['comm$s','V=1:400::T'],
    ['duration$i;0;0','V=1:31:0']
  ];
  View := 'w_schedules';
  Table := 'w_schedules';
  //выровняем верхнюю панель
  Cth.AlignControls(pnlProperties, []);
  //родительский метод
  Result := inherited;
  if not Result then
    Exit;
  frmpcProperties.SetParameters(True, 'Параметры',
    [['Выберите типы заказов, для которых применим данный регламент. Хотя бы один тип заказа должен быть выбран.'#13#10'Внимание: при изменении отметки в этом списке список "Свойства заказов" будет очищен!']],
    False
  );
  //заголовок
  frmpcTemplate.SetParameters(True, 'Шаблон графика',
    [['']],
    False
  );
  //грид
//  Frg1.Options := [myogIndicatorColumn, myogColoredTitle, myogHiglightEditableCells, myogHiglightEditableColumns, myogHasStatusBar];
  va2 := [['name$s','','70']];
  for i := 1 to 31 do
    va2 := va2 + [['d' + IntToStr(i) + '$s', IntToStr(i), '20']];
  FrgProperties.Opt.SetFields(va2);
  FrgProperties.Opt.SetGridOperations('u');
  //FrgTypes.Opt.SetCaption
//  FrgProperties.OnColumnsUpdateData := FrgPropertiesColumnsUpdateData;
  //загрузим список заказов
//  FrgTypes.SetInitData('select id, pos, name, 0 as used from v_order_types where active = 1 order by pos',[]);
  SetLength(va2, 0);
  SetLength(va2, 1);
  SetLength(va2[0], 32);
  va2[0][0] := 'Дни:';
  FrgProperties.SetInitData(va2);
  FrgProperties.Prepare;
  FrgProperties.RefreshGrid;


  //заголовок
  frmpcHours.SetParameters(True, 'График',
    [['']],
    False
  );
  //грид
  va2 := [['month$s','','70']];
  for i := 1 to 31 do
    va2 := va2 + [['d' + IntToStr(i) + '$s', IntToStr(i), '20']];
  FrgHours.Opt.SetFields(va2);
  FrgHours.Opt.SetGridOperations('u');
  SetLength(va2, 0);
  SetLength(va2, 12);
  SetLength(FHolydays, 12);
  for i := 0 to 11 do begin
    SetLength(va2[i], 32);
    va2[i][0] := MonthsRu[i + 1];
    SetLength(FHolydays[i], 32);
    for j := 1 to 31 do begin
      FHolydays[i][j] := 0;
      if j > DayOf(EndOfTheMonth(EncodeDate(2025, i + 1, 1))) then
        FHolydays[i][j] := -1
      else begin
        if DayOfTheWeek(EncodeDate(2025, i + 1, j)) in [6, 7] then
          FHolydays[i][j] := 1;
      end;
    end;
  end;
  FrgHours.OnColumnsGetCellParams := FrgHoursColumnsGetCellParams;
  FrgHours.SetInitData(va2);
  FrgHours.Prepare;
  FrgHours.RefreshGrid;

(*
  //общая подсказка
  FOpt.InfoArray:=[[
    'Регламент заказа.'#13#10+
    'Введите наименование регламента (отображается в журнале) и количество дней обработки заказа для данного регламента.'#13#10+
    'Важно: количество дней вводится нажатием на кнопку в этом поле справа, и при его вводе таблица регламента будет очищена!'#13#10+
    'Заполните таблицы типов закаа, свойств заказа и регламента прохождения по участкам.'#13#10+
    ''#13#10
  ]];
*)
  //ок
  Result := True;
end;

procedure TFrmWWedtWorkSchedule.FrgHoursColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if FieldName = 'month' then
    Params.Background := clmyGray
  else
  case FHolydays[Fr.RecNo -1][TColumnEh(Sender).Index] of
    -1 : Params.Background := clmyGray;
    1 : Params.Background := clmyPink;
  end;
end;



end.
