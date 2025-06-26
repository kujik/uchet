{
добавление ТУРВ - запись в таблице турв_период
период жестко задан - только текущий
список подразделений - только свои для руководителей, все для тех кто ставит согласованное и по парсеку
и при этом только те подразделения, по которым турв не созданы

отдельно для датаедитор
можно выбирать дату, надо поставить первую дату в диапозоне нужного периода, вторая некритична
также всегда полный список подразделений
при попытки создать турв который уже есть будент ошибка уникальности
}

unit D_AddTurv;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, Mask, uData, uForms, uDBOra, uString, uMessages, F_MDIDlg1, DateUtils;

type
  TDlg_AddTurv = class(TForm_MDIDlg1)
    Cb_Division: TDBComboBoxEh;
    Cb_Period: TDBComboBoxEh;
    Lb_AllCreated: TLabel;
    procedure Cb_PeriodChange(Sender: TObject);
  private
    { Private declarations }
    dt_beg: TDateTime;
    function Load: Boolean; override;
    function Save: Boolean; override;
    procedure BtOKClick; override;
    function LoadCbDivision: Boolean;
    procedure GetDtBeg;
    function AfterPrepare: Boolean; override;
  public
    { Public declarations }
  end;

var
  Dlg_AddTurv: TDlg_AddTurv;

implementation

uses
  uTurv
  ;

{$R *.dfm}
procedure TDlg_AddTurv.GetDtBeg;
begin
  dt_beg:=StrToDateTimeDef(Cth.GetControlValue(Cb_Period), Turv.GetTurvBegDate(Date));
end;


procedure TDlg_AddTurv.Cb_PeriodChange(Sender: TObject);
begin
  inherited;
  if InPrepare then Exit;
  LoadCbDivision;
end;

function TDlg_AddTurv.Load: Boolean;
var
  v,v1: Variant;
  i: Integer;
  dt: TDateTime;
begin
  Result:=False;
  dt:=Turv.GetTurvBegDate(Date);
  Cb_Period.Items.Clear;
  Cb_Period.KeyItems.Clear;
  for i:= 1 to 12 do begin
    Cb_Period.Items.Add(Copy(MonthsRu[MonthOf(dt)] + '-' + S.IIf(DayOf(dt) = 1, '1', '2') + '        ', 1, 15) +
      ': с ' + DateTimeToStr(dt) + ' по ' + DateTimeToStr(Turv.GetTurvEndDate(Dt)));
    Cb_Period.KeyItems.Add(DateTimeToStr(dt));
    dt:=Turv.GetTurvBegDate(IncDay(dt, -1));
  end;
  Cb_Period.ItemIndex:=0;
  //Cb_Period.Enabled:=User.IsDataEditor or User.Roles([], [rW_J_Turv_TP, rW_J_Turv_TS]);
  LoadCbDivision;
  Cb_Division.ItemIndex:=S.IIf(User.IsDataEditor or User.Roles([], [rW_J_Turv_TP, rW_J_Turv_TS]), 0, 1);
//  Cb_Division.Enabled:=User.IsDataEditor or User.Roles([], [rW_J_Turv_TP, rW_J_Turv_TS]);
  Cth.SetControlsVerification(
    [Cb_Division, Cb_Period],
    ['1:400', '1:400']
  );
  Result:=True;
end;

function TDlg_AddTurv.LoadCbDivision: Boolean;
begin
  GetDtBeg;
{  Cb_Division.Items.Clear;
  Cb_Division.KeyItems.Clear;
  if User.IsDataEditor or User.Roles([], [rW_J_Turv_TP, rW_J_Turv_TS])
    then begin Cb_Division.Items.Add('[Все подразделения]'); Cb_Division.KeyItems.Add('-1'); end;
  Cb_Division.KeyItems.Add('-2');
  Cb_Division.Items.Add('[Свои подразделения]');}
  Cth.AddToComboBoxEh(Cb_Division, [
    ['[Все подразделения]', '-1', User.IsDataEditor or User.Roles([], [rW_J_Turv_TP, rW_J_Turv_TS])],
    ['[Свои подразделения]', '-2']
  ]);
  if User.IsDataEditor or User.Roles([], [rW_J_Turv_TP, rW_J_Turv_TS])
    then Q.QLoadToDBComboBoxEh('select name, id from ref_divisions d where (select count(1) from turv_period where id_division = d.id and dt1 = :dt1$d) = 0 and active >= :a$i order by name',
           [dt_beg, S.IIf(User.IsDataEditor, 0, 1)], Cb_Division, cntComboLK, 1)
    else Q.QLoadToDBComboBoxEh(
           'select name, id from ref_divisions d where (select count(1) from turv_period where id_division = d.id and dt1 = :dt1$d) = 0 and IsStInCommaSt(:id$i, editusers) = 1 and active = 1 order by name',
           [dt_beg, User.GetId], Cb_Division, cntComboLK, 1);
  Cb_Division.ItemIndex:=0;
  Lb_AllCreated.Visible:=Cb_Division.Items.Count = S.IIf(Cb_Division.Items[0] = '[Все подразделения]', 2, 1);
  Cth.SetErrorMarker(Cb_Division, Lb_AllCreated.Visible);
  Cb_Division.Enabled:=Cb_Division.Items.Count > 1;
//  Bt_OK.Enabled:=not Lb_AllCreated.Visible;
end;

function TDlg_AddTurv.AfterPrepare: Boolean;
begin
  Cb_Period.OnChange:=Cb_PeriodChange;
  LoadCbDivision;
  Result:=True;
end;

function TDlg_AddTurv.Save: Boolean;
var
  i, j: Integer;
begin
  Result:=False;
  GetDtBeg;
  i:=Turv.CreateTURV(
    Cth.GetControlValue(Cb_Division),
    S.IIf(Cb_Division.Text = '[Все подразделения]', 1, S.IIf(Cb_Division.Text = '[Свои подразделения]', 2, 0)),
    User.IsDataEditor,
    dt_beg,
    (Cb_Division.Text = '[Все подразделения]') or (Cb_Division.Text = '[Свои подразделения]')
    );
  MyInfoMessage(S.Decode([i, -1, 'При создании ТУРВ произошла ошибка!.', 0, 'ТУРВ не созданы.', 'Создан ' + IntToStr(i) + ' ТУРВ.']));
  result:=True;
end;

procedure TDlg_AddTurv.BtOKClick;
begin
  Verify(nil);
  if not Bt_Ok.Enabled then Exit;
  if not Save then Exit;
  RefreshParentForm;
  Close;
end;


end.
