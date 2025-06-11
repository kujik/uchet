unit D_ExpenseItems;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, Mask, uData, uForms, uDBOra, uString, uMessages, V_MDI,
  Vcl.ExtCtrls;

type
  TDlg_ExpenseItems = class(TForm_MDI)
    E_Name: TDBEditEh;
    Cb_Active: TDBCheckBoxEh;
    Bt_OK: TBitBtn;
    Bt_Cancel: TBitBtn;
    E_users: TDBEditEh;
    E_Agreed: TDBEditEh;
    Cb_Group: TDBComboBoxEh;
    Chb_RecvReceipt: TDBCheckBoxEh;
    Chb_AccountTO: TDBCheckBoxEh;
    Chb_AccountTS: TDBCheckBoxEh;
    Img_Info: TImage;
    Chb_AccountM: TDBCheckBoxEh;
    procedure E_NameChange(Sender: TObject);
    procedure Bt_OKClick(Sender: TObject);
    procedure Cb_ActiveClick(Sender: TObject);
    procedure E_usersEditButtons0Click(Sender: TObject; var Handled: Boolean);
    procedure Bt_CancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure E_AgreedEditButtons0Click(Sender: TObject; var Handled: Boolean);
    procedure ControlOnChange(Sender: TObject);
    procedure ControlOnExit(Sender: TObject);
    procedure ControlCheckDrawRequiredState(Sender: TObject; var DrawState: Boolean);
    procedure Chb_AccountTOClick(Sender: TObject);
    procedure Chb_AccountTSClick(Sender: TObject);
    procedure Chb_AccountMClick(Sender: TObject);
  private
    { Private declarations }
    Agreed: string;
    UserIds: string;
    Ok: Boolean;
    procedure Verify(Sender: TObject; onInput: Boolean = False);
  public
    { Public declarations }
    function  Prepare: Boolean; override;
  end;

var
  Dlg_ExpenseItems: TDlg_ExpenseItems;

implementation

{$R *.dfm}

uses
//  F_R_ExpenseItems,
  uWindows,
  D_SelectUsers
  ;

//событие изменени€ данных контрола
procedure TDlg_ExpenseItems.ControlOnChange(Sender: TObject);
begin
  //выход если в процедуре загрузки
  if InPrepare then Exit;
  //проверим, признак что в этом событии проверка
  Verify(Sender, True);
end;

//уход фокуса с контрола
procedure TDlg_ExpenseItems.ControlOnExit(Sender: TObject);
begin
  //выход если в процедуре загрузки
  if InPrepare then Exit;
  //проверим
  Verify(Sender);
end;

procedure TDlg_ExpenseItems.ControlCheckDrawRequiredState(Sender: TObject;
  var DrawState: Boolean);
begin
  Cth.VerifyVisualise(Self);
//  verify(Sender, False);
end;

//проверка правлильн6ости данных
//передаетс€ контрол дл€ проверки, или нил - проверить все
//и признак что проверка при вводе данных в контроле (в событии onChange)
procedure TDlg_ExpenseItems.Verify(Sender: TObject; onInput: Boolean = False);
var
  i,j,s:Integer;
  c: TControl;
begin
  //€ просмотра и удалени€ всегда ќк
  if (Mode = fView) or (Mode = fDelete)
    then begin
      Ok:=True;
      Bt_Ok.enabled := Ok;
      Exit;
    end;
  if Sender = nil
    //проверим все DbEh
    then Cth.VerifyAllDbEhControls(Self)
    //проверим текущий
    else Cth.VerifyControl(TControl(Sender), onInput);
  //получим статус проверки и визуализируем
  Ok:=Cth.VerifyVisualise(Self);
  //статус кнопки ќк
  Bt_Ok.Enabled := Ok;
end;

function TDlg_ExpenseItems.Prepare: Boolean;
var
  v: TVarDynArray;
  Info: string;
begin
  Result:= False;
  BorderStyle:=bsDialog;
  if (Mode=fEdit)or(Mode=fDelete) then
    if Q.DBLock(True, FormDoc, VarToStr(id))[0] <> True
      then Exit;
  Q.QLoadToDBComboBoxEh('select name, id from ref_grexpenseitems order by name', [], Cb_Group, cntComboLK);
  if Mode = fAdd
    then v:=VarArrayOf([1,'',1,'','','','','',1,0])
    else v:=Q.QSelectOneRow('select id, name, active, usernames, agreednames, useravail, agreed, id_group, recvreceipt, accounttype from v_ref_expenseitems where id = :id', [ID]);
  if v[0] = null then begin MsgRecordIsDeleted; Exit; end;
  E_Name.Value:=v[1];
  Cth.SetControlValue(Cb_Active, v[2]);
  Cth.SetControlValue(E_Users, v[3]);
  Cth.SetControlValue(E_Agreed, v[4]);
  Cth.SetControlValue(Cb_Group, v[7]);
  Cth.SetControlValue(Chb_RecvReceipt, v[8]);
  Cth.SetControlValue(Chb_AccountTO, S.IIf(v[9] = 1, 1, 0));  //тип счета транспорт то
  Cth.SetControlValue(Chb_AccountTS, S.IIf(v[9] = 2, 1, 0));  //тип счета транспорт сн
  Cth.SetControlValue(Chb_AccountM, S.IIf(v[9] = 3, 1, 0));  //тип счета транспорт сн
  UserIds:=S.NSt(v[5]);
  Agreed:=S.NSt(v[6]);
   //событи€ onCahange и  onExit дл€ всех dbeh контролов
  Cth.SetControlsOnChange(Self, ControlOnChange);
  Cth.SetControlsOnExit(Self, ControlOnExit);
  Cth.SetControlsOnCheckDrawRequired(Self, ControlCheckDrawRequiredState);
  //параметры проверки контролов
  Cth.SetControlsVerification(
    [E_Name, Cb_Group],
    ['1:400:0:T','1:400']
  );
  Cth.SetDialogForm(Self, Mode, '—тать€ расходов');
  Cth.DlgSetControlsEnabled(Self, Mode, [], []);
  Verify(nil);
  Info:=
  '–еадктирование статьи расходов.'#13#10+
  '¬ыберите группу из списка существующих, наименование статьи расходов.'#13#10+
  '¬ыберите в открывающемс€ окне пользователей, которые могут создавать счета по данной статье расходов'#13#10+
  '(пользователей может быть несколько).'#13#10+
  '“акже выберите сотрудников, которые став€т согласование дл€ счетов по данной статье.'#13#10+
  '¬ыберите при необходимости тип счета дл€ данной статьи'#13#10+
  '(может быть обычный счет, транспорт снабжени€, транспорт отгрузки, либо счет подр€дчика по монтажу).'#13#10+
  'ѕоставьте галочку, если по этим счетам требуетс€ загружать за€вку на снабжение'#13#10+
  '(за€вка не об€зательна, если сумма счета не превышает значени€, установленного в настройках программы).'#13#10
  ;
  if Mode in [fView, fDelete] then Info:='';
  Cth.SetInfoIcon(Img_Info, Info, 20);
  PreventResize:=True;
  Result:= True;
end;

procedure TDlg_ExpenseItems.Cb_ActiveClick(Sender: TObject);
var
  Canvas: TControlCanvas;
begin
 Exit;
 Canvas := TControlCanvas.Create;
 try
 Canvas.Control := Cb_Active;
 with Canvas, ClipRect do
 begin
//   Pen.Width:=3;
   Pen.Color:=RGB(224,0,0);
   Pen.Style:=psDot;
   MoveTo(Left, Bottom-2);
   LineTo(Right, Bottom-2);
   MoveTo(Left, Bottom-1);
   LineTo(Right, Bottom-1);
   MoveTo(Left, Bottom-0);
   LineTo(Right, top-0);
 end;
 Canvas.Control := E_Name;
 with Canvas, ClipRect do
 begin
   Pen.Color:=RGB(224,0,0);
   Pen.Style:=psDot;
   MoveTo(Left, Bottom-2);
   LineTo(Right, Bottom-2);
   MoveTo(Left, Bottom-1);
   LineTo(Right, Bottom-1);
 end;
finally
  Canvas.Free;
end;
end;


procedure TDlg_ExpenseItems.Chb_AccountMClick(Sender: TObject);
begin
  if Chb_AccountM.Checked then begin
    Chb_AccountTS.Checked:=False;
    Chb_AccountTO.Checked:=False;
  end;
end;

procedure TDlg_ExpenseItems.Chb_AccountTOClick(Sender: TObject);
begin
  if Chb_AccountTO.Checked then begin
    Chb_AccountTS.Checked:=False;
    Chb_AccountM.Checked:=False;
  end;
end;

procedure TDlg_ExpenseItems.Chb_AccountTSClick(Sender: TObject);
begin
  if Chb_AccountTS.Checked then begin
    Chb_AccountTO.Checked:=False;
    Chb_AccountM.Checked:=False;
  end;
end;

procedure TDlg_ExpenseItems.E_AgreedEditButtons0Click(Sender: TObject; var Handled: Boolean);
var
  NewIds, NewNames: string;
begin
//  if Dlg_SelectUsers.ShowDialog(FormDoc + '_2',  Agreed, False, NewIds, NewNames) <> mrOk then exit;
  if Dlg_SelectUsers.ShowDialog(FormDoc + '_2',  Agreed, True, NewIds, NewNames) <> mrOk then exit;
  E_Agreed.Value:=NewNames;
  Agreed:=NewIds;
end;

procedure TDlg_ExpenseItems.E_NameChange(Sender: TObject);
begin
//  E_Name.Text:=TComponent(Sender).Name;
end;

procedure TDlg_ExpenseItems.E_usersEditButtons0Click(Sender: TObject;  var Handled: Boolean);
var
  NewIds, NewNames: string;
begin
  if Dlg_SelectUsers.ShowDialog(FormDoc + '_1',  UserIds, True, NewIds, NewNames) <> mrOk then exit;
  E_users.Value:=NewNames;
  UserIds:=NewIds;
end;

procedure TDlg_ExpenseItems.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Q.DBLock(False, FormDoc, VarToStr(id));
  Action := caFree;
  try
    //Wh.CloseMDIForm(Self);
  except
  end;
end;

procedure TDlg_ExpenseItems.Bt_CancelClick(Sender: TObject);
begin
  Close;
end;

procedure TDlg_ExpenseItems.Bt_OKClick(Sender: TObject);
var
  NewID: Integer;
  b: Integer;
begin
  if (Mode = fView) then begin Close; Exit; end;
  if E_Name.Text = '' then Exit;
  if Cb_Group.Text = '' then Exit;
  b:= Q.QIUD(Q.QFModeToIUD(Mode), 'ref_expenseitems', 'sq_ref_expenseitems', 'id;name;active;useravail;agreed;id_group;recvreceipt;accounttype',
    [ID, Cth.GetControlValue(E_Name), Cth.GetControlValue(Cb_Active), UserIds, Agreed, Cth.GetControlValue(Cb_Group), Cth.GetControlValue(Chb_RecvReceipt), S.IIf(Cth.GetControlValue(Chb_AccountTO), 1, S.IIf(Cth.GetControlValue(Chb_AccountTS), 2, S.IIf(Cth.GetControlValue(Chb_AccountM), 3, 0)))]
  );
  if b = -1 then Exit;
  RefreshParentForm;
  Close;
end;

end.
