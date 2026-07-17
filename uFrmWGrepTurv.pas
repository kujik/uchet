{
форма просмотра турв по подразделению за произвольный период (не более месяца)
все итоги считаются по данным выбранного периода.
}


unit uFrmWGrepTurv;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls,
  ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls, MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd,
  MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils, Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uNamedArr, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uTurv
  ;

type
  TFrmWGrepTurv = class(TFrmBasicGrid2)
  private
    FTurv: TTurvData;
    FTitle: TNamedArr;
    FDt1, FDt2: TDateTime;
    FIdDepartament: Integer;
    FDepartament: string;
    function  PrepareForm: Boolean; override;
    procedure PushTurvToGrid;
    procedure SetLblCaptionText;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
  public
  end;

var
  FrmWGrepTurv: TFrmWGrepTurv;

implementation

{$R *.dfm}

uses
  uLabelColors2;

const
  cDayColWidth = 35;

function TFrmWGrepTurv.PrepareForm: Boolean;
var
  i, j: Integer;
  va2, va21, flds1, flds2, values2: TVarDynArray2;
  Captions2: TVarDynArray;
begin
  Result := False;
  Caption:='Отчет по ТУРВ';
  FIdDepartament := AddParam[0];
  FDt1 := AddParam[1];
  FDt2 := AddParam[2];
  if (FDt2 < FDt1) or (DaysBetween(FDt2, FDt1) > 31) then begin
    Exit;
  end;
  var ssort := 'job;employee;schedulecode;organization;personnel_number';
  var sgroup := 'schedulecode;job;organization;employee';
  FTurv.Create(null, ssort, sgroup, FDt1, FDt2, FIdDepartament);
  if FTurv.Count = 0 then begin
    MyInfoMessage('В этом табеле нет ни одной записи!');
    Exit;
  end;
  FDepartament := Q.QLoadValue('select name from w_departaments where id = :id$i', [FIdDepartament]);
  for i := 1 to FTurv.DaysCount do begin
    flds1 := flds1 + [[
      'd' + IntToStr(i) + '$s',
      S.IIfStr(IncDay(FTurv.DtBeg, i - 1) > FTurv.DtEnd, '_') +
        IntToStr(DayOf(IncDay(FTurv.DtBeg, i - 1))) + ', '+ DaysOfWeek2[DayOfTheWeek(IncDay(FTurv.DtBeg, i - 1))],
      IntToStr(cDayColWidth) + ';R'
    ]];
  end;

  Frg1.Options := FrDBGridOptionDef + [myogPanelFind] - [myogColoredEven];
  Frg1.Opt.SetFields([
    ['x$s', '*','20'],
    ['name$s','Работник|ФИО','200'],
    ['organization$s','Работник|Организация','90'],
    ['job$s','Работник|Должность','150'],
    ['is_foreman$s','Работник|Бригадир','50','pic','i'],
    ['is_trainee$s','Работник|Ученик','40','pic','i'],
    ['grade$s','Работник|Разряд','40', 'i'],
    ['schedulecode$s','Работник|График','50'],
    ['period_hours_norm$s','Работник|Норма','50']
    ] + flds1 + [
    ['time$f', 'Итоги|Время', '50', 'f=f:'],
    ['overtime$f', 'Итоги|Перера'#13#10'ботка', '50', 'f=f:'],
    ['premium$f', 'Итоги|Премии', '50', 'f=f:'],
    ['penalty$f', 'Итоги|Депреми'#13#10'рование', '50', 'f=f:']
//    ['ids_pers_bonus$s', 'Итоги|Перс.'#13#10'выплата', '50', 'pic=-:0;10']
  ]);
  Frg1.Opt.SetButtons(1,'p');
  Frg1.CreateAddControls('1', cntLabelClr, '', 'lblCaption', '', 4, yrefT, 800);
  Frg1.SetInitData([], '');
  Frg1.InfoArray := [['Итоги по табелю учета рабочего времени по подразделению за выбранный период.']];
  Result := inherited;
  if not Result then
    Exit;
  SetLblCaptionText;
  PushTurvToGrid;
  Frg1.First;
end;

procedure TFrmWGrepTurv.PushTurvToGrid;
var
  i, j: Integer;
  Premium, Penalty, Worktime: Extended;
  na: TNamedArr;
begin
  Frg1.MemTableEh1.EmptyTable;
  FTurv.CalculateTotals;
  for i := 0 to FTurv.Count - 1 do begin
    Frg1.MemTableEh1.Last;
    Frg1.MemTableEh1.Insert;
    Frg1.MemTableEh1.FieldByName('name').Value := FTurv.GetListTitleString(i, 'name');
    Frg1.MemTableEh1.FieldByName('job').Value := FTurv.GetListTitleString(i, 'job');
    Frg1.MemTableEh1.FieldByName('organization').Value := FTurv.GetListTitleString(i, 'organization');
    Frg1.MemTableEh1.FieldByName('is_foreman').Value := FTurv.GetListTitleString(i, 'is_foreman');
    Frg1.MemTableEh1.FieldByName('is_trainee').Value := FTurv.GetListTitleString(i, 'is_trainee');
    Frg1.MemTableEh1.FieldByName('grade').Value := FTurv.GetListTitleString(i, 'grade');
    Frg1.MemTableEh1.FieldByName('schedulecode').Value := FTurv.GetListTitleString(i, 'schedulecode');
    Frg1.MemTableEh1.FieldByName('period_hours_norm').Value := FTurv.GetListTitleString(i, 'period_hours_norm');
    for j := 1 to FTurv.DaysCount do begin
      var Color: Integer;
      var st: string;
      var v := FTurv.GetDayCell(i, j, 0, Color, st, True);
      Frg1.MemTableEh1.FieldByName('d' + IntToStr(j)).Value := v;
    end;
    Frg1.MemTableEh1.Edit;
    Frg1.MemTableEh1.FieldByName('time').Value := FTurv.Rows[i].Totals.G('worktime');
    Frg1.MemTableEh1.FieldByName('premium').Value := FTurv.Rows[i].Totals.G('premium');
    Frg1.MemTableEh1.FieldByName('penalty').Value := FTurv.Rows[i].Totals.G('penalty');
    Frg1.MemTableEh1.FieldByName('overtime').Value := FTurv.Rows[i].Totals.G('overtime');
//    Frg1.MemTableEh1.FieldByName('ids_pers_bonus').Value := FTurv.Rows[i].Totals.G('ids_pers_bonus');
    Frg1.MemTableEh1.Post;
  end;
  Frg1.MemTableEh1.First;
end;

procedure TFrmWGrepTurv.SetLblCaptionText;
begin
  TLabelClr(Frg1.FindComponent('lblCaption')).SetCaptionAr2([
    '$000000', 'Подразделение: ', '$FF0000', FDepartament,
    '$000000', '   Период с ', '$FF0000',  DateToStr(FTurv.DtBeg), '$000000 по $FF0000', DateToStr(FTurv.DtEnd)
    ]);
end;

procedure TFrmWGrepTurv.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if Pos('d', FieldName) <> 1 then begin
    Params.Background := clSkyBlue;
  end;
end;

end.
