unit uMailingInterface;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_MDI,
  Vcl.ExtCtrls, Vcl.ComCtrls, VclTee.TeeGDIPlus, Vcl.StdCtrls, Vcl.Buttons,
  VCLTee.TeEngine, VCLTee.Series, VCLTee.TeeProcs, VCLTee.Chart, Vcl.Mask,
  DBCtrlsEh, DateUtils, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls,
  DynVarsEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, MemTableDataEh, Data.DB,
  MemTableEh, Data.Win.ADODB, DataDriverEh, ADODataDriverEh, VCL.ClipBrd,
  PrnDbgEh, DBGridEhXMLSpreadsheetExp, ShellApi, XlsMemFilesEh,
  DBGridEhXlsMemFileExporters, DBGridEhImpExp, uString, uData;

type
  TMailingInterface = class
  private
    FParent: TForm;
    procedure EditButtons0Click(Sender: TObject; var Handled: Boolean);
    procedure EditButtons1Click(Sender: TObject; var Handled: Boolean);
    procedure SetEditText;
  public
    FMailingNum: Integer;
    FUserIDs: string;
    FNames: string;
    FAddresses: string;
    FUserIDsOld: string;
    FAddressesOld: string;
    FUseCustomAddr: Boolean;
    FComm: string;
    FCaption: string;
    FEdit: TDBEditEh;
    constructor Create(AParent: TForm; AEdit: TDBEditEh; AMailingNum: Integer = 0; ACaption: string = ''; AUseCustomAddr: Boolean = True);
    procedure SetAddresses(aUserIDs: string; aAddResses: string);
    procedure Load;
    procedure Save;
    function  IsChanged: Boolean;
  end;

implementation

uses
  uFrmXGsesUsersChoice, uMessages, uFrmXDedtMailingCustomAddr, uDBOra;

constructor TMailingInterface.Create(AParent: TForm; AEdit: TDBEditEh; AMailingNum: Integer = 0; ACaption: string = ''; AUseCustomAddr: Boolean = True);
begin
  inherited Create;
  FParent := AParent;
  FEdit := AEdit;
  FEdit.EditButtons.Clear;
  FEdit.EditButtons.Add;
  FEdit.EditButtons[0].OnClick := EditButtons0Click;
  FEdit.EditButtons[0].Style := ebsGlyphEh;
  FEdit.EditButtons[0].Images.NormalImages := MyData.IL_CellButtons;
  FEdit.EditButtons[0].Images.NormalIndex := 30;
  FUseCustomAddr := AUseCustomAddr;
  FMailingNum := AMailingNum;
  FCaption := ACaption;
  if AUseCustomAddr then begin
    FEdit.EditButtons.Add;
    FEdit.EditButtons[1].OnClick := EditButtons1Click;
    FEdit.EditButtons[1].Style := ebsGlyphEh;
    FEdit.EditButtons[1].Images.NormalImages := MyData.IL_CellButtons;
    FEdit.EditButtons[1].Images.NormalIndex := 31;
  end;
end;

procedure TMailingInterface.Load;
var
  v: TVarDynArray;
  vn: TVarDynArray2;
  i: Integer;
begin
  if FMailingNum <= 0 then
    Exit;
  v := Q.QSelectOneRow('select id, userids, customemail, comm from adm_mailing where id = :id$i', [FMailingNum]);
  if v[0] = null then begin
    FMailingNum := 0;
    MyWarningMessage('Неверно задан код рассылки!');
    FUserIDs := '';
    FAddresses := '';
    FComm := 'Такой рассылки нет!';
  end
  else begin
    FUserIDs := S.NSt(v[1]);
    vn := Q.QLoadToVarDynArray2('select name from adm_users where id in (' + S.IIFStr(FUserIDs = '', '-999', FUserIDs) + ') order by name', []);
    FNames := '';
    for i := 0 to High(vn) do
      S.ConcatStP(FNames, vn[i][0], ';');
    FAddresses := S.IIf(FUseCustomAddr, S.NSt(v[2]), '');
    FComm := S.NSt(v[3]);
  end;
  FUserIDsOld := FUserIDs;
  FAddressesOld := FAddresses;
  SetEditText;
end;

procedure TMailingInterface.Save;
begin
// if (FMailingNum <=0)or(FUserIDsOld + FAddressesOld = FUserIDs + FAddresses)
  if not IsChanged then
    Exit;
  Q.QExecSql('update adm_mailing set FUserIDs = :FUserIDs$s, customemail = :customemail$s where id = :id$i', [FUserIDs, FAddresses, FMailingNum]);
end;

function TMailingInterface.IsChanged: Boolean;
begin
  Result := (FMailingNum > 0) and (FUserIDsOld + FAddressesOld <> FUserIDs + FAddresses);
end;

procedure TMailingInterface.SetAddresses(aUserIDs: string; aAddResses: string);
begin
  FUserIDs := aUserIDs;
  FAddresses := aAddResses;
  FUserIDsOld := FUserIDs;
  FAddressesOld := FAddresses;
  SetEditText;
end;

procedure TMailingInterface.EditButtons0Click(Sender: TObject; var Handled: Boolean);
var
  NewIds, NewNames: string;
begin
  if TFrmXGsesUsersChoice.ShowDialog(Application, True, FUserIDs, FNames) <> mrOk then
    exit;
  SetEditText;
end;

procedure TMailingInterface.EditButtons1Click(Sender: TObject; var Handled: Boolean);
begin
  if FrmXDedtMailingCustomAddr.ShowDialog(FAddresses) then begin
    SetEditText;
  end;
end;

procedure TMailingInterface.SetEditText;
begin
  FEdit.Value := A.ImplodeNotEmpty([FNames, FAddresses], ',');
  if FCaption = '*' then
    FEdit.ControlLabel.Caption := FComm;
end;

end.

