{
���� ������ ������������ � ������ ����� � ����
}

unit D_TURV_Comment;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Math
  ;

type
  TDlg_TURV_Comment = class(TForm)
    Bt_Close: TBitBtn;
    Lb_Ruk: TLabel;
    Label1: TLabel;
    Timer1: TTimer;
    Lb_Par: TLabel;
    Lb_Sogl: TLabel;
    procedure Timer1Timer(Sender: TObject);
    procedure Bt_CloseClick(Sender: TObject);
  private
    { Private declarations }
    Owner: TForm;
    X, Y: Integer;
  public
    { Public declarations }
//    procedure ShowDialog(AOwner: TForm; X: Integer; Y: Integer; v1, v2, v3: string);
//    procedure ShowDialog(AOwner: TForm; AX: Integer; AY: Integer; v1, v2, v3: Variant);
    procedure ShowDialog(AOwner: TForm; AX: Integer; AY: Integer; v1, v2, v3, v4: Variant);
  end;

var
  Dlg_TURV_Comment: TDlg_TURV_Comment;

implementation

uses
  uForms,
  uData,
  uFrmMain
  ;

{$R *.dfm}

procedure TDlg_TURV_Comment.Bt_CloseClick(Sender: TObject);
begin
  Close;
end;

procedure TDlg_TURV_Comment.Timer1Timer(Sender: TObject);
begin
  Close;
end;

procedure TDlg_TURV_Comment.ShowDialog(AOwner: TForm; AX: Integer; AY: Integer; v1, v2, v3, v4: Variant);
var
  h: Integer;
  T: Tpoint;
begin
  //���� �� ������ �������� ���, �� ������� �� ������ �����
  v1:=VarToStr(v1); v2:=VarToStr(v2); v3:=VarToStr(v3); v4:=VarToStr(v4);
  if v1 + v2 + v3 + v4 = '' then Exit;
  if v4 <> '' then begin
    v1:='����� ������ ����� ' + v4 + '�.';
    v4:='';
    Label1.Caption:='';
  end
  else Label1.Caption:='�����������:';
  //��� ��������� �� �����, ������ ��� Visible �������� ������� ��� ����� ���� �����, ����� ����� �� ����� �������� (����������)
  //if Visible then Exit;
  //� ��� ������ ����� ��� ������
  //��������� ������������� ����������, ��� ��������� ���� ��������� �� ������ ������, � ����� ���������� �� ��������� ��������
  if (Bt_Close.Focused)and(X=AX)and(Y=AY) then Exit;
  Width:=300;
  Owner:=AOwner;
  X:=AX;
  Y:=AY;

  //������ ����� �����, ������������ �� �������� �� ������ (�� ������ � ���� �� ����������, �� �� ������� �������)
  Lb_Ruk.AutoSize:=True;
  Lb_Ruk.Caption:=VarToStr(v1);
//  if Lb_Ruk.Width < 350 then begin
    Lb_Ruk.AutoSize:=False;
    Lb_Ruk.WordWrap:=True;
//    Width:=210;
    Lb_Ruk.Width:=290;
    Lb_Ruk.AutoSize:=True;
  Lb_Ruk.Visible:=Lb_Ruk.Caption <> '';
//  end;

  Lb_Par.AutoSize:=True;
  Lb_Par.Caption:=VarToStr(v2);
  Lb_Par.AutoSize:=False;
  Lb_Par.WordWrap:=True;
  Lb_Par.Width:=290;
  Lb_Par.AutoSize:=True;
  Lb_Par.Visible:=Lb_Par.Caption <> '';

  Lb_Sogl.AutoSize:=True;
  Lb_Sogl.Caption:=VarToStr(v3);
  Lb_Sogl.AutoSize:=False;
  Lb_Sogl.WordWrap:=True;
  Lb_Sogl.Width:=290;
  Lb_Sogl.AutoSize:=True;
  Lb_Sogl.Visible:=Lb_Sogl.Caption <> '';

  //�������� ������ �����
  Height:=Lb_Sogl.Top + Lb_Sogl.Height + Bt_Close.Height + 20;

  //�������� ���������� �����, ������ ���� ���� � ������ ����������-�����, �� ����� �� �������� �� ������� ������������� ����
  //(������� �����!)
//  Left:=Max(5, Min(Owner.Left+X+20, Owner.Left + Owner.Width - Width -15));
//  Top:=Max(5, min(Owner.Top+50+Y+95, Owner.Top + Owner.Height - Height - 15));

//Lb_Ruk.Caption:=inttostr(Mouse.CursorPos.y)+' '+inttostr(FrmMain.top);

  //���� ���� ���� � ������ ������� �����, �� ���� �������� �� ��������� �������� ���� ����������, �� �������� ����� �� �������� �� �������
  //������� ������� ����� ������������ ������������ ������ � �� �������� ����!
  Top:=Max(Min(FrmMain.Top + FrmMain.Height - Height - 15, Max(10, Mouse.CursorPos.Y + 15)),0);
  Left:=Max(Min(FrmMain.Left + FrmMain.Width - Width - 15, Max(10, Mouse.CursorPos.X + 15)),0);

  //������
  Cth.SetBtn(Bt_Close, mybtClose);

  //������� �����, ��� ���-���������� ����� ����� ����� ���� ������ �������� � ����, ��� ��� ����� ���� �����, ��� ��������
  Show;
end;

{
���� ��������� AutoSize, ���������� ������ ������ � �������� ������� AutoSize, �� TLabel ������������� ���� � ������ �������� ����, � �� ���� ��� ����� ����� ������������ ������� ������.
��� ������ ������ ������������. ��� ������ OK ���������� ����� ��� ���������� �������, � ������� ���������� �������� (���� ������ ��� ��������� ������� �������).
LabelText.Caption := params.text;
if LabelText.Width > maxTextWidth then begin
  LabelText.AutoSize := False;
  LabelText.WordWrap := True;
  LabelText.Width := maxTextWidth;
  LabelText.AutoSize := True;
end;
ButtonOk.Top := LabelText.BoundsRect.Bottom + BorderWidth * 2;
}

end.
