unit uFrmWDAddTurv;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh,
  uFrmBasicMdi, uFrmBasicDbDialog, DateUtils,
  uData, uForms, uDBOra, uString, uMessages, uFields
  ;

type
  TFrmWDAddTurv = class(TFrmBasicDbDialog)
    Lb_AllCreated: TLabel;
    Cb_Division: TDBComboBoxEh;
    Cb_Period: TDBComboBoxEh;
    procedure Cb_PeriodChange(Sender: TObject);
  private
    FDtBeg: TDateTime;
    function  Prepare: Boolean; override;
    function  LoadComboBoxes: Boolean; override;
    function  Load: Boolean; override;
    function  Save: Boolean; override;
    procedure BtOKClick;
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
 { F.DefineFields:=[
    ['id$i'],
    ['office$i','v=1:400'],
    ['name$s','v=1:400:0:T'],
    ['id_head$i','v=1:40000'],
    ['editusers$s',''],
    ['editusernames$s;0','v=1:4000:0', True],
    ['code$s','v=0:5:0:T'],
    ['active$i','']
  ];
  View := 'v_ref_divisions';
  Table := 'ref_divisions';
  FOpt.UseChbNoClose := False;
  FOpt.InfoArray:= [[
    'Данные подразделения.'#13#10+
    'Введите название подразделения, выберите относится ли оно к офису или цеху.'#13#10+
    'Выберите руководителя из списка работников.'#13#10+
    'Введите код подразделения (используется в бухгалтерии).'#13#10+
    'Выберите одного или нескольких пользователей, которые будут заполнять ТУРВ'#13#10+
    'для данного подразделения, нажав на кнопку спава в поле ввода и отметив нужные фамилии.'#13#10+
    'Если подразделение существуует сейчас и в него требуется прием работников '#13#10+
    'и учет рабочего времени, то отметьте галку "Используется"'#13#10
    ,not (Mode in [fView, fDelete])
  ]];    }
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
  if Cth.GetControlValue(Cb_Period) = null then
    Exit;
  FDtBeg := StrToDateTimeDef(Cth.GetControlValue(Cb_Period), Turv.GetTurvBegDate(Date));
end;

function TFrmWDAddTurv.Load: Boolean;
var
  v,v1: Variant;
  i: Integer;
  dt: TDateTime;
begin
  Result := False;
  dt := Turv.GetTurvBegDate(Date);
  Cb_Period.Items.Clear;
  Cb_Period.KeyItems.Clear;
  for i := 1 to 12 do begin
    Cb_Period.Items.Add(Copy(MonthsRu[MonthOf(dt)] + '-' + S.IIf(DayOf(dt) = 1, '1', '2') + '        ', 1, 15) + ': с ' + DateTimeToStr(dt) + ' по ' + DateTimeToStr(Turv.GetTurvEndDate(dt)));
    Cb_Period.KeyItems.Add(DateTimeToStr(dt));
    dt := Turv.GetTurvBegDate(IncDay(dt, -1));
  end;
  Cb_Period.ItemIndex := 0;
  LoadCbDivision;
  Cb_Division.ItemIndex := S.IIf(User.IsDataEditor or User.Roles([], [rW_J_Turv_TP, rW_J_Turv_TS]), 0, 1);
  Cth.SetControlsVerification([Cb_Division, Cb_Period], ['1:400', '1:400']);
  Result := True;
end;

function TFrmWDAddTurv.LoadCbDivision: Boolean;
begin
  GetDtBeg;
  Cth.AddToComboBoxEh(Cb_Division, [
    ['[Все подразделения]', '-1', User.IsDataEditor or User.Roles([], [rW_J_Turv_TP, rW_J_Turv_TS])],
    ['[Свои подразделения]', '-2']
  ]);
  if User.IsDataEditor or User.Roles([], [rW_J_Turv_TP, rW_J_Turv_TS])
    then Q.QLoadToDBComboBoxEh('select name, id from ref_divisions d where (select count(1) from turv_period where id_division = d.id and dt1 = :dt1$d) = 0 and active >= :a$i order by name',
           [FDtBeg, S.IIf(User.IsDataEditor, 0, 1)], Cb_Division, cntComboLK, 1)
    else Q.QLoadToDBComboBoxEh(
           'select name, id from ref_divisions d where (select count(1) from turv_period where id_division = d.id and dt1 = :dt1$d) = 0 and IsStInCommaSt(:id$i, editusers) = 1 and active = 1 order by name',
           [FDtBeg, User.GetId], Cb_Division, cntComboLK, 1);
  Cb_Division.ItemIndex := 0;
  Lb_AllCreated.Visible := Cb_Division.Items.Count = S.IIf(Cb_Division.Items[0] = '[Все подразделения]', 2, 1);
  Cth.SetErrorMarker(Cb_Division, Lb_AllCreated.Visible);
  Cb_Division.Enabled := Cb_Division.Items.Count > 1;
  HasError := not Lb_AllCreated.Visible;
end;

function TFrmWDAddTurv.Save: Boolean;
var
  i, j: Integer;
begin
  Result:=False;
  GetDtBeg;
  i:=Turv.CreateTURV(
    Cth.GetControlValue(Cb_Division),
    S.IIf(Cb_Division.Text = '[Все подразделения]', 1, S.IIf(Cb_Division.Text = '[Свои подразделения]', 2, 0)),
    User.IsDataEditor,
    FDtBeg,
    (Cb_Division.Text = '[Все подразделения]') or (Cb_Division.Text = '[Свои подразделения]')
    );
  MyInfoMessage(S.Decode([i, -1, 'При создании ТУРВ произошла ошибка!.', 0, 'ТУРВ не созданы.', 'Создан ' + IntToStr(i) + ' ТУРВ.']));
  result:=True;
end;

procedure TFrmWDAddTurv.BtOKClick;
begin
{  Verify(nil);
  if not Bt_Ok.Enabled then Exit;
  if not Save then Exit;
  RefreshParentForm;
  Close;}
end;


procedure TFrmWDAddTurv.Cb_PeriodChange(Sender: TObject);
begin
  inherited;
  if FInPrepare then
    Exit;
  LoadCbDivision;
end;

end.


end.
