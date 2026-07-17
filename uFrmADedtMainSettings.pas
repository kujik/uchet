unit uFrmADedtMainSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, DBCtrlsEh,
  uFrmBasicMdi, uFrmBasicDbDialog, ToolCtrlsEh, Vcl.Mask, Vcl.ComCtrls,
  uData, uForms, uDBOra, uString, uMessages, uFields, uMailingInterface
  ;

type
  TFrmADedtMainSettings = class(TFrmBasicDbDialog)
    pnlMessage: TPanel;
    lbl_Warning: TLabel;
    pgcMain: TPageControl;
    tsPaths: TTabSheet;
    lbl1: TLabel;
    lbl2: TLabel;
    edt_filespath: TDBEditEh;
    edt_ordercurrentpath: TDBEditEh;
    edt_orderarchivepath: TDBEditEh;
    tsMail: TTabSheet;
    edt_MailingOrdersCh: TDBEditEh;
    edt_MailingAttachSmeta: TDBEditEh;
    edt_MailingReportSmeta: TDBEditEh;
    edt_MailingAttachTHN: TDBEditEh;
    tsDeleteOld: TTabSheet;
    nedt_or_to_archive: TDBNumberEditEh;
    nedt_orders_n: TDBNumberEditEh;
    nedt_accounts_n: TDBNumberEditEh;
    nedt_turv: TDBNumberEditEh;
    nedt_payrolls: TDBNumberEditEh;
    edt_mailing_order_fin: TDBEditEh;
    edt_mailing_sn: TDBEditEh;
    edt_mailing_early_acts: TDBEditEh;
  private
    MI1, MI2, MI3, MI4, MI5, MI6, MI7, MI8: TMailingInterface;
    function Prepare: Boolean; override;
    function LoadComboBoxes: Boolean; override;
    procedure VerifyBeforeSave; override;
    function Save: Boolean; override;
  public
  end;

var
  FrmADedtMainSettings: TFrmADedtMainSettings;

implementation

{$R *.dfm}


function TFrmADedtMainSettings.LoadComboBoxes: Boolean;
begin
  MI1:=TMailingInterface.Create(Self, edt_MailingOrdersCh, 1, '*', True);
  MI1.Load;
  MI3:=TMailingInterface.Create(Self, edt_MailingAttachSmeta, 3, '*', True);
  MI3.Load;
  MI4:=TMailingInterface.Create(Self, edt_MailingReportSmeta, 4, '*', True);
  MI4.Load;
  MI5:=TMailingInterface.Create(Self, edt_MailingAttachTHN, 5, '*', True);
  MI5.Load;
  MI6:=TMailingInterface.Create(Self, edt_mailing_order_fin, 6, '*', True);
  MI6.Load;
  MI7:=TMailingInterface.Create(Self, edt_mailing_sn, 7, '*', True);
  MI7.Load;
  MI8:=TMailingInterface.Create(Self, edt_mailing_early_acts, 8, '*', True);
  MI8.Load;
  Result := True;
end;

function TFrmADedtMainSettings.Prepare: Boolean;
begin
  Result := False;
  Caption := '~Основные настройки программы';
  ID := 1;
  F.DefineFields:=[
    ['id$i'],
    ['filespath$s','v=1:500:0:T'],
    ['ordercurrentpath$s','v=1:500:0:T'],
    ['orderarchivepath$s','v=1:500:0:T'],
    ['or_to_archive$i','v=7:99999:N'],
    ['orders_n$i','v=7:99999:N'],
    ['accounts_n$i','v=14:99999:N'],
    ['turv$i','v=14:99999:N'],
    ['payrolls$i','v=3:99999:N']
 ];
  View := 'v_adm_all_settings';
  FOpt.InfoArray:= [];
  FWHBounds.Y2:= -1;
  Result := inherited;
  pgcMain.TabIndex := 0;
  if not Result then
    Exit;
end;

function TFrmADedtMainSettings.Save: Boolean;
begin
  Result := False;
  Q.QBeginTrans(True);
  Q.QExecSql(Q.QGetSql('q','adm_delete_old','or_to_archive;orders_n;accounts_n;turv;payrolls'),
    [nedt_or_to_archive.Value, nedt_orders_n.Value, nedt_accounts_n.Value, nedt_turv.Value, nedt_payrolls.Value]
  );
  Q.QExecSql(Q.QGetSql('q','adm_main_settings','filespath;ordercurrentpath;orderarchivepath'),
    [edt_filespath.Value, edt_ordercurrentpath.Value, edt_orderarchivepath.Value]
  );
  MI1.Save;
  MI3.Save;
  MI4.Save;
  MI5.Save;
  MI6.Save;
  MI7.Save;
  MI8.Save;
  Q.QCommitTrans;
  Result := Q.CommitSuccess;
end;

procedure TFrmADedtMainSettings.VerifyBeforeSave;
begin
  if FIsDataChanged then
    FErrorMessage := '?Данные были изменены!'#13#10'Сохранить?'
  else
    FErrorMessage := 'Изменений не было.';
end;

end.

