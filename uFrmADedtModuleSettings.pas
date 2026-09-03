unit uFrmADedtModuleSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmBasicMdi, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.StdCtrls,
  DBCtrlsEh, DateUtils,
  ToolCtrlsEh, DBGridEhToolCtrls,
  GridsEh, DBAxisGridsEh, DBGridEh, MemTableDataEh, Data.DB,
  Data.Win.ADODB, DataDriverEh, VCL.ClipBrd, PrnDbgEh,



  DBGridEhImpExp, uString, Vcl.Mask
;

type
  TFrmADedtModuleSettings = class(TFrmBasicMdi)
    pgc_1: TPageControl;
    ts_SN: TTabSheet;
    nedt_Sum_AutoAgreed: TDBNumberEditEh;
    nedt_Sum_Need_Req: TDBNumberEditEh;
    nedt_Transport_MaxIdle: TDBNumberEditEh;
    ts_Workers: TTabSheet;
    nedt_W_Time_AutoAggreed: TDBNumberEditEh;
    nedt_W_Time_Dinne_1: TDBNumberEditEh;
    nedt_W_Time_Dinner_2: TDBNumberEditEh;
    nedt_W_Time_Beg_Diff_2: TDBNumberEditEh;
    dedt_W_Time_Beg_2: TDBDateTimeEditEh;
    pnl1: TPanel;
    lbl_Warning: TLabel;
  private
    { Private declarations }
    VA: TVarDynArray2;
    FChangedSn, FChangedWorkers: Boolean;
    function Prepare: Boolean; override;
    procedure VerifyBeforeSave; override;
    function Save: Boolean; override;
  public
    { Public declarations }
  end;

var
  FrmADedtModuleSettings: TFrmADedtModuleSettings;

implementation

uses
  uDBOra
  ;

{$R *.dfm}

function TFrmADedtModuleSettings.Prepare: Boolean;
//загрузка текущих значений из sn_calendar_cfg и workers_cfg (см. также аналогичный перенос логики из
//бывшего TDlg_ModuleSettings.ShowDialog); VA запоминает исходные значения - используется в VerifyBeforeSave
//для определения, что именно изменилось
var
  v: TVarDynArray;
begin
  Result := True;
  Caption := '~Настройки модулей';
  FOpt.DlgPanelStyle := dpsBottomRight;
  FOpt.StatusBarMode :=stbmDialog;
  SetLength(VA, 2);

  v := Q.QLoadRow('select sum_autoagreed, sum_need_req, transport_maxidle from sn_calendar_cfg', []);
  nedt_Sum_AutoAgreed.Value := v[0];
  nedt_Sum_Need_Req.Value := v[1];
  nedt_Transport_MaxIdle.Value := v[2];
  VA[0] := [v[0], v[1], v[2]];

  v := Q.QLoadRow('select time_autoagreed, time_dinner_1, time_dinner_2, time_beg_2, time_beg_diff_2 from workers_cfg', []);
  nedt_W_Time_AutoAggreed.Value := v[0];
  nedt_W_Time_Dinne_1.Value := v[1];
  nedt_W_Time_Dinner_2.Value := v[2];
  v[3] := EncodeTime(Trunc(v[3]), Trunc(Frac(v[3]) * 100), 0, 0);
  dedt_W_Time_Beg_2.Value := v[3];
  nedt_W_Time_Beg_Diff_2.Value := v[4];
  VA[1] := [v[0], v[1], v[2], v[3], v[4]];

  pgc_1.ActivePageIndex := 0;
end;

procedure TFrmADedtModuleSettings.VerifyBeforeSave;
//проверка перед сохранением (см. TFrmBasicMdi.btnOkClick): если FErrorMessage начинается с '?' - показывается
//вопрос (Да - сохраняем), иначе - предупреждение (сохранение блокируется)
begin
  if (nedt_Sum_AutoAgreed.Value = Null) or
     (nedt_Sum_Need_Req.Value = Null) or
     (nedt_Transport_MaxIdle.Value = Null) or
     (nedt_W_Time_AutoAggreed.Value = Null) or
     (nedt_W_Time_Dinne_1.Value = Null) or
     (nedt_W_Time_Dinner_2.Value = Null) or
     (dedt_W_Time_Beg_2.Value = Null) or
     (nedt_W_Time_Beg_Diff_2.Value = Null)
  then begin
    FErrorMessage := 'Введены некорректные данные!';
    Exit;
  end;

  FChangedSn :=
    (VA[0][0] <> nedt_Sum_AutoAgreed.Value) or
    (VA[0][1] <> nedt_Sum_Need_Req.Value) or
    (VA[0][2] <> nedt_Transport_MaxIdle.Value);
  FChangedWorkers :=
    (VA[1][0] <> nedt_W_Time_AutoAggreed.Value) or
    (VA[1][1] <> nedt_W_Time_Dinne_1.Value) or
    (VA[1][2] <> nedt_W_Time_Dinner_2.Value) or
    (VA[1][3] <> dedt_W_Time_Beg_2.Value) or
    (VA[1][4] <> nedt_W_Time_Beg_Diff_2.Value);

  if not (FChangedSn or FChangedWorkers) then begin
    FErrorMessage := 'Данные не были изменены!';
    Exit;
  end;

  FErrorMessage := '?Данные были изменены. Сохранить?';
end;

function TFrmADedtModuleSettings.Save: Boolean;
var
  e1: Extended;
begin
  if FChangedSn then
    Q.QExecSql('update sn_calendar_cfg set sum_autoagreed = :sum_autoagreed, sum_need_req = :sum_need_req, transport_maxidle = :transport_maxidle',
      [nedt_Sum_AutoAgreed.Value, nedt_Sum_Need_Req.Value, nedt_Transport_MaxIdle.Value]);
  if FChangedWorkers then begin
    e1 := HourOf(dedt_W_Time_Beg_2.Value) + MinuteOf(dedt_W_Time_Beg_2.Value) / 100;
    Q.QExecSql('update workers_cfg set time_autoagreed = :1$f, time_dinner_1 = :2$f, time_dinner_2 = :3$f, time_beg_2 = :4$f, time_beg_diff_2 = :5$f',
      [nedt_W_Time_AutoAggreed.Value, nedt_W_Time_Dinne_1.Value, nedt_W_Time_Dinner_2.Value, e1, nedt_W_Time_Beg_Diff_2.Value]);
  end;
  Result := True;
end;

end.
