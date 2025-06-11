unit D_MainSettings;

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
  DBGridEhImpExp, V_Normal, uString,
  uMailingInterface

;

type
  TDlg_MainSettings = class(TForm_Normal)
    PageControl1: TPageControl;
    Ts_Paths: TTabSheet;
    Panel1: TPanel;
    Bt_Ok: TBitBtn;
    Bt_Cancel: TBitBtn;
    E_PathToFiles: TDBEditEh;
    E_ZCurrent: TDBEditEh;
    E_ZArchive: TDBEditEh;
    Lb_Warning: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Ts_Mail: TTabSheet;
    E_EMailDomain: TDBEditEh;
    E_EmailUser: TDBEditEh;
    E_EmailServer: TDBEditEh;
    E_EMailLogin: TDBEditEh;
    E_EMailPassword: TDBEditEh;
    E_EMailPassword2: TDBEditEh;
    E_MailingOrdersCh: TDBEditEh;
    Bevel1: TBevel;
    E_MailingOrdersChITM: TDBEditEh;
    E_MailingAttachSmeta: TDBEditEh;
    E_MailingReportSmeta: TDBEditEh;
    Ts_DeleteOld: TTabSheet;
    Ne_MoveToArchive: TDBNumberEditEh;
    Ne_DeleteOrders: TDBNumberEditEh;
    Ne_DeleteAccounts: TDBNumberEditEh;
    Ne_DeleteTurv: TDBNumberEditEh;
    Ne_DeletePayrolls: TDBNumberEditEh;
    E_MailingAttachTHN: TDBEditEh;
    procedure Bt_OkClick(Sender: TObject);
    procedure E_MailingOrdersChEditButtons0Click(Sender: TObject;
      var Handled: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    VA: TVarDynArray2;
    MailingOrdersChValue: string;
    MI1, MI2, MI3, MI4, MI5: TMailingInterface;
  public
    { Public declarations }
    function ShowDialog: Integer;
  end;

var
  Dlg_MainSettings: TDlg_MainSettings;

implementation

{$R *.dfm}

uses
  uForms,
  uMessages,
  uDBOra,
  uData,
  D_SelectUsers
  ;

procedure TDlg_MainSettings.Bt_OkClick(Sender: TObject);
var
  i, j:Integer;
  v: TVarDynArray;
  b, b1, b2, b21, b22, b3: Boolean;
begin
  if
    (Length(E_PathToFiles.text)<3) or
    (Length(E_ZCurrent.text)<3) or
    (Length(E_ZArchive.text)<3)
  then begin MyInfoMessage('Введены некорректные данные на вкладке "Расположение данных"!'); Exit; end;
  if
    (Length(E_EMailDomain.text)<5) or
    (Length(E_EMailUser.text)<1) or
    (Length(E_EMailServer.text)<5) or
    (Length(E_EMailLogin.text)<1)
  then begin MyInfoMessage('Введены некорректные данные на вкладке "Настройки почты"!'); Exit; end;
  if
    (E_EMailPassword.text <> E_EMailPassword2.text)
  then begin MyInfoMessage('Пароли для почтового сервера не совпадают!'); Exit; end;
  b1 :=
    (va[0][0]<>E_PathToFiles.text)or
    (va[0][1]<>E_ZCurrent.text)or
    (va[0][2]<>E_ZArchive.text);
  b21 :=
    (E_EMailUser.Text<>va[1][1])or
    (E_EMailServer.Text<>va[1][2])or
    (E_EMailLogin.Text<>va[1][3])or
    (E_EMailPassword.Text<>va[1][4]);
  b22 :=
    MI1.IsChanged or MI2.IsChanged or MI3.IsChanged or MI4.IsChanged or MI5.IsChanged;
  b2:= b21 or b22;
  b3 :=
    (Ne_MoveToArchive.Value<>va[2][0])or
    (Ne_DeleteOrders.Value<>va[2][1])or
    (Ne_DeleteAccounts.Value<>va[2][2])or
    (Ne_DeleteTurv.Value<>va[2][3])or
    (Ne_DeletePayrolls.Value<>va[2][4]);
  b := b1 or b2 or b3;
  if not b
    then begin MyInfoMessage('Данные не были изменены!'); Exit; end;
  if (MyQuestionMessage('Данные были изменены. Сохранить?') <> mrYes) then Exit;
  if b1 then begin
    Q.QExecSql('update adm_main_settings set filespath = :fp, ordercurrentpath = :ocp, orderarchivepath = :oap', [E_PathToFiles.text, E_ZCurrent.text, E_ZArchive.text]);
  end;
  if b21 then begin
    Q.QExecSql(Q.QSIUDSql('q','adm_main_settings', 'emaildomain;emailuser;emailserver;emaillogin;emailpassword'),
      [E_EMailDomain.Text, E_EMailUser.Text,E_EMailServer.Text,E_EMailLogin.Text,E_EMailPassword.Text]
    );
  end;
  if b22 then begin
    MI1.Save;
    MI2.Save;
    MI3.Save;
    MI4.Save;
    MI5.Save;
  end;
  if b3 then begin
    Q.QExecSql(Q.QSIUDSql('q','adm_delete_old','or_to_archive;orders_n;accounts_n;turv;payrolls'),
      [Ne_MoveToArchive.Value, Ne_DeleteOrders.Value, Ne_DeleteAccounts.Value, Ne_DeleteTurv.Value, Ne_DeletePayrolls.Value]
    );
  end;
  Close;
end;

procedure TDlg_MainSettings.E_MailingOrdersChEditButtons0Click(Sender: TObject;
  var Handled: Boolean);
var
  NewIds, NewNames: string;
begin
{  if Dlg_SelectUsers.ShowDialog(FormDoc + '_A_Tasks',  MailingOrdersChValue, True, NewIds, NewNames) <> mrOk then exit;
  E_MailingOrdersCh.Value:=NewNames;
  MailingOrdersChValue:=NewIds;}
end;

procedure TDlg_MainSettings.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  MI1.Free;
  MI2.Free;
  MI3.Free;
  MI4.Free;
  MI5.Free;
end;

function TDlg_MainSettings.ShowDialog: Integer;
var
  i, j:Integer;
  v1, v2, v3: TVarDynArray;
begin
  Cth.SetBtn(Bt_Ok, mybtOk);
  Cth.SetBtn(Bt_Cancel, mybtCancel);
  v1:=Q.QSelectOneRow('select filespath, ordercurrentpath, orderarchivepath from adm_main_settings', []);
  v2:=Q.QSelectOneRow('select emaildomain, emailuser, emailserver, emaillogin, emailpassword from adm_main_settings',[]);
  v3:=Q.QSelectOneRow('select or_to_archive, orders_n, accounts_n, turv, payrolls from adm_delete_old', []);
  E_PathToFiles.text:=S.NSt(v1[0]);
  E_ZCurrent.text:=S.NSt(v1[1]);
  E_ZArchive.text:=S.NSt(v1[2]);
  E_EMailDomain.Text:=S.NSt(v2[0]);
  E_EMailUser.Text:=S.NSt(v2[1]);
  E_EMailServer.Text:=S.NSt(v2[2]);
  E_EMailLogin.Text:=S.NSt(v2[3]);
  E_EMailPassword.Text:=S.NSt(v2[4]);
  E_EMailPassword2.Text:=S.NSt(v2[4]);
  Ne_MoveToArchive.Value:=S.NNum(v3[0]);
  Ne_DeleteOrders.Value:=S.NNum(v3[1]);
  Ne_DeleteAccounts.Value:=S.NNum(v3[2]);
  Ne_DeleteTurv.Value:=S.NNum(v3[3]);
  Ne_DeletePayrolls.Value:=S.NNum(v3[4]);
  va := [[v1[0], v1[1], v1[2]], [v2[0], v2[1], v2[2], v2[3], v2[4]], [v3[0], v3[1], v3[2], v3[3], v3[4]]];
  PageControl1.ActivePageIndex:=0;

  MI1:=TMailingInterface.Create(Self, E_MailingOrdersCh, 1, '*', True);
  MI1.Load;
  MI2:=TMailingInterface.Create(Self, E_MailingOrdersChITM, 2, '*', True);
  MI2.Load;
  MI3:=TMailingInterface.Create(Self, E_MailingAttachSmeta, 3, '*', True);
  MI3.Load;
  MI4:=TMailingInterface.Create(Self, E_MailingReportSmeta, 4, '*', True);
  MI4.Load;
  MI5:=TMailingInterface.Create(Self, E_MailingAttachTHN, 5, '*', True);
  MI5.Load;
  ShowModal;
end;


end.
