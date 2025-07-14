{
������ ������������ ������ ��� ������ � ����� ������.
���������� ��������� �� ������, ����� ������� � �������� ����������.
TODO:
������� ����������� � ����� ������� � �������������� � ���� �����������.
}
unit uFrmXWOracleError;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uSettings, uString, uData, uMessages, uForms, uDBOra, uFrmBasicMdi, uFrDBGridEh, uFrmBasicGrid2, uFrmBasicInput,
  Vcl.Mask, Vcl.Imaging.pngimage
  ;

type
  TFrmXWOracleError = class(TFrmBasicMdi)
    pnlCenter: TPanel;
    pnlLeft: TPanel;
    MError: TDBMemoEh;
    MSql: TDBMemoEh;
    MParams: TDBMemoEh;
    Image1: TImage;
    procedure FormActivate(Sender: TObject);
  private
    procedure btnClick(Sender: TObject); override;
  public
    //������� ���� � �������, �������� � ����������� ������� � ��
    //���� ������ ��������� �������� AError � �.�., �� ����� �������� ���
    //����� ����� ������� ������ �� ���� �� ���������� ������ (��� -1 - ��������)
    procedure ShowDialog(ARow: Integer = -1; AError: string = ''; AQuery: string = ''; AParams: string = '');
  end;

var
  FrmXWOracleError: TFrmXWOracleError;

implementation

uses
  uDB,
  uWindows
  ;


{$R *.dfm}

procedure TFrmXWOracleError.btnClick(Sender: TObject);
begin
  Wh.ExecReference(myfrm_Srv_SqlMonitor);
end;


procedure TFrmXWOracleError.FormActivate(Sender: TObject);
begin
  inherited;
  Top := 200;
end;

procedure TFrmXWOracleError.ShowDialog(ARow: Integer = -1; AError: string = ''; AQuery: string = ''; AParams: string = '');
//������� ���� � �������, �������� � ����������� ������� � ��
//���� ������ ��������� �������� AError � �.�., �� ����� �������� ���
//����� ����� ������� ������ �� ���� �� ���������� ������ (��� -1 - ��������)
begin
  PrepareCreatedForm(Application, myfrm_Dlg_OracleError, '~������ ��� ������ � ��', fView, null, [myfoModal, myfoDialog, myfoDialogButtonsB, myfoSizeable], False);
  FOpt.DlgButtonsR := [[1000, True, True, 120, '������ ��������', 'view']];
  ARow := Min(S.IIf(ARow < 0, MaxInt, ARow), High(Q.LogArray));
  Caption := ModuleRecArr[uData.cMainModule].Caption + ' - ������!';
  Module.SetBitmapFromResource(Image1.Picture.Bitmap, PChar('error64'));
  MError.Text := '';
  MSql.Text := '';
  MParams.Text := '';
  if AError + AQuery + AParams <> '' then begin
    MError.Text := AError;
    MSql.Text := AQuery;
    MParams.Text := AParams;
  end
  else if ARow >= 0 then begin
    MError.Text := Q.LogArray[ARow][cmydbLogError];
    MSql.Text := Q.LogArray[ARow][cmydbLogQuery];
    MParams.Text := Q.LogArray[ARow][cmydbLogParams];
  end;
  Self.ShowModal;
end;

end.
