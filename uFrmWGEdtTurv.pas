unit uFrmWGEdtTurv;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh
  ;

type
  TFrmWGEdtTurv = class(TFrmBasicGrid2)
  private
    FPeriodStartDate: TDateTime;
    FPeriodEndDate: TDateTime;
    FDayColWidth: Integer;
    function  PrepareForm: Boolean; override;
  public
  end;

var
  FrmWGEdtTurv: TFrmWGEdtTurv;

implementation

uses
  uTurv;

{$R *.dfm}

function TFrmWGEdtTurv.PrepareForm: Boolean;
var
  i, j: Integer;
  va2: TVarDynArray2;
begin
  Result := False;

  Mode := fEdit;

  FPeriodStartDate :=  EncodeDate(2025, 06, 01);
  FPeriodStartDate :=  EncodeDate(2025, 06, 15);
  FDayColWidth := 30;

  Caption:='~����';

  //��������� 16 ������� ��� ������� ������
  //��������� ������������ ��� �� ����
  //���� ������������� ������� � �������
  //������ �������, ������� ���� ����� �������
  for i := 1 to 16 do begin
    va2 := va2 + [[
      'd' + IntToStr(i) + '$f',
      '������|' + IntToStr(DayOf(IncDay(FPeriodStartDate, i - 1))) + ', '+ DaysOfWeek2[DayOfTheWeek(IncDay(FPeriodStartDate, i - 1))],
      IntToStr(FDayColWidth) + S.IIfStr(IncDay(FPeriodStartDate, i - 1) > FPeriodEndDate, ';i')
    ]];
  end;

  Frg1.Opt.SetFields([
//  ['id$i','_id','40'],
    ['x$s', '*','20'],
    ['worker$s','��������|���','200'],
    ['job$s','��������|���������','100'],
    ['r$i','��������|������','0']
    ] + va2 + [
    ['premium_p', '�����|�����', '40'] ,
    ['time', '�����|������ �� ������', '40'],
    ['premium', '�����|������', '40'],
    ['penalty', '�����|������', '40'],
    ['comm', '�����|�����������', '100']
  ]);
  Frg1.Opt.SetGridOperations('u');
  Frg1.SetInitData([], '');
//  Frg1.Opt.SetTable('v_ref_work_schedules');

  Result := inherited;
end;


end.
