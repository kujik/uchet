unit uMailingInterface;

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
//  EhLibVCL, DBCtrlsEH;

type
  TMailingInterface = class
  private
    Parent: TForm;
    procedure EditButtons0Click(Sender: TObject; var Handled: Boolean);
    procedure EditButtons1Click(Sender: TObject; var Handled: Boolean);
    procedure SetEditText;
  public
    MailingNum: Integer;
    UserIDs: string;
    Names: string;
    Addresses: string;
    UserIDsOld: string;
    AddressesOld: string;
    UseCustomAddr: Boolean;
    Comm: string;
    Caption: string;
    Edit:TDBEditEh;
    Constructor Create(aParent: TForm; aEdit: TDBEditEh; aMailingNum: Integer = 0; aCaption: string = ''; aUseCustomAddr: Boolean = True);
    procedure SetAddresses(aUserIDs: string; aAddResses: string);
    procedure Load;
    procedure Save;
    function  IsChanged: Boolean;
  end;


implementation

uses
  D_SelectUsers,
  uMessages,
  D_MailingCustomAddr,
  uDBOra
  ;

Constructor TMailingInterface.Create(aParent: TForm; aEdit: TDBEditEh; aMailingNum: Integer = 0; aCaption: string = ''; aUseCustomAddr: Boolean = True);
begin
  inherited Create;
  Parent:=aParent;
  Edit:=aEdit;
  Edit.EditButtons.Clear;
  Edit.EditButtons.Add;
  Edit.EditButtons[0].OnClick:=EditButtons0Click;
  UseCustomAddr:=aUseCustomAddr;
  MailingNum:=aMailingNum;
  Caption:=aCaption;
  if aUseCustomAddr then begin
    Edit.EditButtons.Add;
    Edit.EditButtons[1].OnClick:=EditButtons1Click;
  end;
end;

procedure TMailingInterface.Load;
var
  v:TVarDynArray;
  vn:TVarDynArray2;
  i:Integer;
begin
  if MailingNum <=0 then Exit;
  v:=Q.QSelectOneRow('select id, userids, customemail, comm from adm_mailing where id = :id$i', [MailingNum]);
  if v[0] = null then begin
    MailingNum:=0;
    MyWarningMessage('Неверно задан код рассылки!');
    UserIDs:='';
    Addresses:='';
    Comm:='Такой рассылки нет!';
  end
  else begin
    UserIDs:=S.NSt(v[1]);
    vn:=Q.QLoadToVarDynArray2('select name from adm_users where id in (' + S.IIFStr(UserIds = '', '-999', UserIDs) + ') order by name', []);
    Names:='';
    for i:=0 to High(vn) do
      S.ConcatStP(Names, vn[i][0], ';');
    Addresses:=S.IIf(UseCustomAddr, S.NSt(v[2]), '');
    Comm:=S.NSt(v[3]);
  end;
  UserIDsOld:=UserIds;
  AddressesOld:=Addresses;
  SetEditText;
end;

procedure TMailingInterface.Save;
begin
// if (MailingNum <=0)or(UserIDsOld + AddressesOld = UserIDs + Addresses)
  if not IsChanged
    then Exit;
  Q.QExecSql(
    'update adm_mailing set userids = :userids$s, customemail = :customemail$s where id = :id$i',
    [UserIDs, Addresses, MailingNum]
  );
end;

function TMailingInterface.IsChanged: Boolean;
begin
  Result:=(MailingNum > 0)and(UserIDsOld + AddressesOld <> UserIDs + Addresses);
end;

procedure TMailingInterface.SetAddresses(aUserIDs: string; aAddResses: string);
begin
  UserIDs:=aUserIDs;
  Addresses:=aAddResses;
  UserIDsOld:=UserIds;
  AddressesOld:=Addresses;
  SetEditText;
end;


procedure TMailingInterface.EditButtons0Click(Sender: TObject; var Handled: Boolean);
var
  NewIds, NewNames: string;
begin
  if Dlg_SelectUsers.ShowDialog('_mailing',  UserIds, True, NewIds, NewNames) <> mrOk then exit;
  UserIds:=NewIds;
  Names:=NewNames;
  SetEditText;
end;

procedure TMailingInterface.EditButtons1Click(Sender: TObject; var Handled: Boolean);
begin
  if Dlg_MailingCustomAddr.ShowDialog(Addresses) then begin
    SetEditText;
  end;
end;

procedure TMailingInterface.SetEditText;
begin
  Edit.Value:=A.ImplodeNotEmpty([Names, Addresses], ',');
  if Caption = '*'
    then Edit.ControlLabel.Caption:=Comm;
end;


end.
