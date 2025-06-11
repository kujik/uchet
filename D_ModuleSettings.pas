unit D_ModuleSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_MDI, Vcl.ExtCtrls, Vcl.ComCtrls,
  VclTee.TeeGDIPlus, Vcl.StdCtrls, Vcl.Buttons, VCLTee.TeEngine, VCLTee.Series,
  VCLTee.TeeProcs, VCLTee.Chart, Vcl.Mask, DBCtrlsEh, DateUtils,
  DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, EhLibVCL,
  GridsEh, DBAxisGridsEh, DBGridEh, MemTableDataEh, Data.DB, MemTableEh,
  Data.Win.ADODB, DataDriverEh, ADODataDriverEh, VCL.ClipBrd, PrnDbgEh, DBGridEhXMLSpreadsheetExp,
  ShellApi,
  XlsMemFilesEh,
  DBGridEhXlsMemFileExporters,
  DBGridEhImpExp, V_Normal, uString
;

type
  TDlg_ModuleSettings = class(TForm_Normal)
    Panel1: TPanel;
    Lb_Warning: TLabel;
    Bt_Ok: TBitBtn;
    Bt_Cancel: TBitBtn;
    Pg_1: TPageControl;
    Ts_SN: TTabSheet;
    Ne_Sum_AutoAgreed: TDBNumberEditEh;
    Ne_Sum_Need_Req: TDBNumberEditEh;
    Ne_Transport_MaxIdle: TDBNumberEditEh;
    Ts_Workers: TTabSheet;
    Ne_W_Time_AutoAggreed: TDBNumberEditEh;
    Ne_W_Time_Dinne_1: TDBNumberEditEh;
    Ne_W_Time_Dinner_2: TDBNumberEditEh;
    Ne_W_Time_Beg_Diff_2: TDBNumberEditEh;
    De_W_Time_Beg_2: TDBDateTimeEditEh;
    procedure Bt_OkClick(Sender: TObject);
  private
    { Private declarations }
   VA: TVarDynArray2;
  public
    { Public declarations }
    function ShowDialog: Integer;
  end;

var
  Dlg_ModuleSettings: TDlg_ModuleSettings;

implementation

{$R *.dfm}

uses
  uForms,
  uMessages,
  uDBOra,
  uData
  ;

procedure TDlg_ModuleSettings.Bt_OkClick(Sender: TObject);
var
  i, j:Integer;
  v: TVarDynArray;
  b, b1, b2: Boolean;
  e1: extended;
begin
 if
   (Ne_sum_autoagreed.value = null) or
   (Ne_sum_need_req.value = null) or
   (Ne_transport_maxidle.value = null) or

   (Ne_W_Time_AutoAggreed.value = null) or
   (Ne_W_Time_Dinne_1.value = null) or
   (Ne_W_Time_Dinner_2.value = null) or
   (De_W_Time_Beg_2.value = null) or
   (Ne_W_Time_Beg_Diff_2.value = null)
  then begin MyInfoMessage('Введены некорректные данные!'); Exit; end;
  b1 :=
    (va[0][0]<>Ne_sum_autoagreed.value)or
    (va[0][1]<>Ne_sum_need_req.value)or
    (va[0][2]<>Ne_transport_maxidle.value);
  b2 :=
   (va[1][0]<>Ne_W_Time_AutoAggreed.value) or
   (va[1][1]<>Ne_W_Time_Dinne_1.value ) or
   (va[1][2]<>Ne_W_Time_Dinner_2.value ) or
   (va[1][3]<>De_W_Time_Beg_2.value ) or
   (va[1][4]<>Ne_W_Time_Beg_Diff_2.value )
   ;
  b := b1 or b2;
  if not b
    then begin MyInfoMessage('Данные не были изменены!'); Exit; end;
  if (MyQuestionMessage('Данные были изменены. Сохранить?') <> mrYes) then Exit;
  if b1 then begin
    Q.QExecSql('update sn_calendar_cfg set sum_autoagreed = :sum_autoagreed, sum_need_req = :sum_need_req, transport_maxidle = :transport_maxidle',
      [Ne_sum_autoagreed.value, Ne_sum_need_req.value, Ne_transport_maxidle.value]);
  end;
  if b2 then begin
    e1:=HourOf(De_W_Time_Beg_2.Value) + MinuteOf(De_W_Time_Beg_2.Value)/100;
    Q.QExecSql('update workers_cfg set time_autoagreed = :1$f, time_dinner_1 = :2$f, time_dinner_2 = :3$f, time_beg_2 = :4$f, time_beg_diff_2 = :5$f',
      [Ne_W_Time_AutoAggreed.value, Ne_W_Time_Dinne_1.value, Ne_W_Time_Dinner_2.value, e1, Ne_W_Time_Beg_Diff_2.value]);
  end;

  Close;
end;


function TDlg_ModuleSettings.ShowDialog: Integer;
var
  i, j:Integer;
  v: TVarDynArray;
begin
  SetLength(va, 2);
  Cth.SetBtn(Bt_Ok, mybtOk);
  Cth.SetBtn(Bt_Cancel, mybtCancel);
  v:=Q.QSelectOneRow('select sum_autoagreed, sum_need_req, transport_maxidle from sn_calendar_cfg', []);
  Ne_sum_autoagreed.value:=v[0];
  Ne_sum_need_req.value:=v[1];
  Ne_transport_maxidle.value:=v[2];
  va[0] := [v[0], v[1], v[2]];

  v:=Q.QSelectOneRow('select time_autoagreed, time_dinner_1, time_dinner_2, time_beg_2, time_beg_diff_2 from workers_cfg',[]);
  Ne_W_Time_AutoAggreed.value:=v[0];
  Ne_W_Time_Dinne_1.value:=v[1];
  Ne_W_Time_Dinner_2.value:=v[2];
  v[3]:=EncodeTime(trunc(v[3]), trunc(frac(v[3]) * 100), 0, 0);
  De_W_Time_Beg_2.value:=v[3];
  Ne_W_Time_Beg_Diff_2.value:=v[4];
  va[1] := [v[0], v[1], v[2], v[3], v[4]];
  Pg_1.ActivePageIndex:=0;
  ShowModal;
end;


end.
