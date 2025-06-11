{
���� � ������������� ������ ��� ���������� ������� Oracle
���������� �� ������ �� ����������� ������
(�������� ����� �� ����)
(�������� ����������� ������� � ����� �� �������� ���������� ��� �������� � ������)

���������� ������� �� ���� ���� �� ���������� ������ ������, ���� �� < 0, �� �� ���������

�������� ����:
���� ������ - �� ���������� �����������
����� ��� - �������� ����� ������� �� ������� ��
�������� ���������� - ��������� �������� ���������� ��� ��������� �� � ������� ��

}


unit D_OraError;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, uData, Jpeg, uString, PngImage, Math;

type
  TDlg_OraError = class(TForm)
    MM_Error: TMemo;
    MM_Sql: TMemo;
    MM_Params: TMemo;
    Bt_Ok: TBitBtn;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Bt_Log: TBitBtn;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure Bt_LogClick(Sender: TObject);
  private
    Err: string;
    { Private declarations }
  public
    { Public declarations }
    //������� ���� � �������, �������� � ����������� ������� � ��
    //���� ������ ��������� �������� AError � �.�., �� ����� �������� ���
    //����� ����� ������� ������ �� ���� �� ���������� ������ (��� -1 - ��������)
    procedure ShowDialog(ARow: Integer = -1; AError: string = ''; AQuery: string = ''; AParams: string = '');
  end;

var
  Dlg_OraError: TDlg_OraError;

implementation

{$R *.dfm}

uses
  uDBOra,
  uDB,
  //F_SQLMonitor,
  uWindows,
  uForms
  ;

procedure TDlg_OraError.Bt_LogClick(Sender: TObject);
begin
  Wh.ExecReference(myfrm_Srv_SqlMonitor)
end;

procedure TDlg_OraError.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;
end;

procedure TDlg_OraError.FormShow(Sender: TObject);
begin
  Bt_Ok.SetFocus;
end;

procedure TDlg_OraError.ShowDialog(ARow: Integer = -1; AError: string = ''; AQuery: string = ''; AParams: string = '');
//������� ���� � �������, �������� � ����������� ������� � ��
//���� ������ ��������� �������� AError � �.�., �� ����� �������� ���
//����� ����� ������� ������ �� ���� �� ���������� ������ (��� -1 - ��������)
begin
  ARow:=Min(S.IIf(ARow < 0, MaxInt, ARow), High(Q.LogArray));
  Caption:= ModuleRecArr[uData.cMainModule].Caption + ' - ������!';
  Module.SetBitmapFromResource(Image1.Picture.Bitmap, PChar('error64'));
  MM_Error.Text:=''; MM_Sql.Text:=''; MM_Params.Text:='';
  if AError+AQuery+AParams <> '' then begin
    MM_Error.Text:= AError;
    MM_Sql.Text:= AQuery;
    MM_Params.Text:= AParams;
  end
  else if ARow >=0 then begin
    MM_Error.Text:=Q.LogArray[ARow][cmydbLogError];
    MM_Sql.Text:=Q.LogArray[ARow][cmydbLogQuery];
    MM_Params.Text:=Q.LogArray[ARow][cmydbLogParams];
  end;
  Cth.SetBtn(Bt_Ok, myBtClose, False);
  Cth.SetBtn(Bt_Log, mybtView, False, '���');
  ShowModal;
end;

end.
