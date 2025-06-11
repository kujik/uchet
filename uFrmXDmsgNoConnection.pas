{
 ���������� ��� ����� ������, ���� ��� ���� ����������� � �� Orace ���������.
 �� ����������, ���� ����������� ��� ��� ������ ���������, ��� ���� ������!

 ������� ��������� �� ������ ����������� � ���� ������
 ������� ��������������� �� ������ - ��� ������� ��� ����������
 ��� �������� ����� ��������� ���������� ����������, ��������� Halt -
 ����� �� ���� ������ ��� �������� ��� ��������.
 ���� ���� ����� �� ���������, ���������� ������������� ����������
 ����� 10 ������ (������ �������� ��������, ��� ���� ����������� �� ������
 ����� � ����������)

}

unit uFrmXDmsgNoConnection;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Vcl.Imaging.pngimage;

type
  TFrmXDmsgNoConnection = class(TForm)
    ImgError: TImage;
    LbMessage: TLabel;
    BtClose: TBitBtn;
    Timer1: TTimer;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmXDmsgNoConnection: TFrmXDmsgNoConnection;

implementation

uses
  uFrmMain, uData, uErrors;

{$R *.dfm}

procedure TFrmXDmsgNoConnection.FormActivate(Sender: TObject);
begin
  Caption:=ModuleRecArr[cMainModule].Caption;
  Timer1.Enabled:= True;
end;

procedure TFrmXDmsgNoConnection.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Halt;
end;

procedure TFrmXDmsgNoConnection.Timer1Timer(Sender: TObject);
begin
  Halt;
end;

end.
