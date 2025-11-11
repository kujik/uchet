unit uFrmWDAddTurv;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, DBCtrlsEh,
  uFrmBasicMdi, uFrmBasicDbDialog, DateUtils,
  uData, uForms, uDBOra, uString, uMessages, Vcl.Mask
  ;

type
  TFrmWDAddTurv = class(TFrmBasicDbDialog)
    lbl_AllCreated: TLabel;
    cmb_Division: TDBComboBoxEh;
    cmb_Period: TDBComboBoxEh;
    procedure cmb_PeriodChange(Sender: TObject);
  private
    FDtBeg: TDateTime;
    function  Prepare: Boolean; override;
    function  LoadComboBoxes: Boolean; override;
    function  Load: Boolean; override;
    function  Save: Boolean; override;
    procedure btnOkClick;
    function  LoadCbDivision: Boolean;
    procedure GetDtBeg;
  public
  end;

var
  FrmWDAddTurv: TFrmWDAddTurv;

implementation

uses
  uTurv
  ;

{$R *.dfm}

function TFrmWDAddTurv.Prepare: Boolean;
begin
  Caption := 'Подразделение';
  Mode := fEdit;
  Result:=inherited;
  FOpt.StatusBarMode := stbmNone;
  LoadCbDivision;
end;


function TFrmWDAddTurv.LoadComboBoxes: Boolean;
begin
  Result := True;
end;

procedure TFrmWDAddTurv.GetDtBeg;
begin
  if Cth.GetControlValue(cmb_Period) = null then
    Exit;
  FDtBeg := StrToDateTimeDef(Cth.GetControlValue(cmb_Period), Turv.GetTurvBegDate(Date));
end;

function TFrmWDAddTurv.Load: Boolean;
var
  v,v1: Variant;
  i: Integer;
  dt: TDateTime;
begin
  Result := False;
  dt := Turv.GetTurvBegDate(Date);
  cmb_Period.Items.Clear;
  cmb_Period.KeyItems.Clear;
  for i := 1 to 12 do begin
    cmb_Period.Items.Add(Copy(MonthsRu[MonthOf(dt)] + '-' + S.IIf(DayOf(dt) = 1, '1', '2') + '        ', 1, 15) + ': с ' + DateTimeToStr(dt) + ' по ' + DateTimeToStr(Turv.GetTurvEndDate(dt)));
    cmb_Period.KeyItems.Add(DateTimeToStr(dt));
    dt := Turv.GetTurvBegDate(IncDay(dt, -1));
  end;
  cmb_Period.ItemIndex := 0;
  LoadCbDivision;
  cmb_Division.ItemIndex := S.IIf(User.IsDataEditor or User.Roles([], [rW_J_Turv_TP, rW_J_Turv_TS]), 0, 1);
  Cth.SetControlsVerification([cmb_Division, cmb_Period], ['1:400', '1:400']);
  Result := True;
end;

function TFrmWDAddTurv.LoadCbDivision: Boolean;
begin
  GetDtBeg;
  Cth.AddToComboBoxEh(cmb_Division, [
    ['[Все подразделения]', '-1', User.IsDataEditor or User.Roles([], [rW_J_Turv_TP, rW_J_Turv_TS])],
    ['[Свои подразделения]', '-2']
  ]);
  if User.IsDataEditor or User.Roles([], [rW_J_Turv_TP, rW_J_Turv_TS])
    then Q.QLoadToDBComboBoxEh('select name, id from ref_divisions d where (select count(1) from turv_period where id_division = d.id and dt1 = :dt1$d) = 0 and active >= :a$i order by name',
           [FDtBeg, S.IIf(User.IsDataEditor, 0, 1)], cmb_Division, cntComboLK, 1)
    else Q.QLoadToDBComboBoxEh(
           'select name, id from ref_divisions d where (select count(1) from turv_period where id_division = d.id and dt1 = :dt1$d) = 0 and IsStInCommaSt(:id$i, editusers) = 1 and active = 1 order by name',
           [FDtBeg, User.GetId], cmb_Division, cntComboLK, 1);
  cmb_Division.ItemIndex := 0;
  lbl_AllCreated.Visible := cmb_Division.Items.Count = S.IIf(cmb_Division.Items[0] = '[Все подразделения]', 2, 1);
  Cth.SetErrorMarker(cmb_Division, lbl_AllCreated.Visible);
  cmb_Division.Enabled := cmb_Division.Items.Count > 1;
  HasError := not lbl_AllCreated.Visible;
end;

function TFrmWDAddTurv.Save: Boolean;
var
  i, j: Integer;
begin
  Result:=False;
  GetDtBeg;
  i:=Turv.CreateTURV(
    Cth.GetControlValue(cmb_Division),
    S.IIf(cmb_Division.Text = '[Все подразделения]', 1, S.IIf(cmb_Division.Text = '[Свои подразделения]', 2, 0)),
    User.IsDataEditor,
    FDtBeg,
    (cmb_Division.Text = '[Все подразделения]') or (cmb_Division.Text = '[Свои подразделения]')
    );
  MyInfoMessage(S.Decode([i, -1, 'При создании ТУРВ произошла ошибка!.', 0, 'ТУРВ не созданы.', 'Создан ' + IntToStr(i) + ' ТУРВ.']));
  result:=True;
end;

procedure TFrmWDAddTurv.btnOkClick;
begin
{  Verify(nil);
  if not Bt_Ok.Enabled then Exit;
  if not Save then Exit;
  RefreshParentForm;
  Close;}
end;


procedure TFrmWDAddTurv.cmb_PeriodChange(Sender: TObject);
begin
  inherited;
  if FInPrepare then
    Exit;
  LoadCbDivision;
end;

end.


end.
