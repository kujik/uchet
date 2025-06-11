{
������������ ����� ��� ��-MDI ����
��� ����� ��������� � ����� ������, �� ���������� MDIchild, ������ ���� ��������� �� ���� �����

����� ����� ����������� �� Dlg_ ��� �������� ��������� ������, ����� Form_
������� ������������ ������������ ��������� � ������ �������� ����, ���� ������ POsition<>poMainFormCenter

��� ��������
  ����������� FormDoc �� ����� �����
  ���������� Position �� ��������

��� OnShow
  ������������

FormCanResize
  �������������� �������

}

unit V_Normal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Math, Menus, Comctrls,
  uData
;

type
  TForm_Normal = class(TForm)
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    tmp: TToolButton;
  public
    { Public declarations }
    ModuleId: Integer;
    FormDoc: string;
    Mode: TDialogType;
  protected
    MinWidth, MinHeight: Integer;
    AutoSaveWindowPos: Boolean;
    ParentForm: TComponent;
  end;

var
  Form_Normal: TForm_Normal;

implementation

uses
   uFrmMain,
   uMessages,
   uSettings
   ;

{$R *.dfm}

//���� ����� �� �������� � ������ ����������� �������, �� �� ��������� ����� ������ �����������
procedure TForm_Normal.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  Resize:= True;
  if NewWidth < MinWidth then NewWidth := MinWidth;
  if NewHeight < MinHeight then NewHeight := MinHeight;
end;

//formdoc, ����� �������� ��� ���������� ������� ����� � ���������
procedure TForm_Normal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if AutoSaveWindowPos then Settings.SaveWindowPos(Self, FormDoc);
//  FrmMain.FormsList.Buttons[FrmMain.FormsList.Buttons.Count - 1].Destroy;
//  Tmp.Destroy;
end;

procedure TForm_Normal.FormCreate(Sender: TObject);
begin
  FormDoc:=Self.Name;
  ModuleId:= cMainModule;
  if (Pos('Dlg_', FormDoc) = 1)and(Position<>poMainFormCenter) then Position:=poDefault;
end;

procedure TForm_Normal.FormShow(Sender: TObject);
var
  x,y,i: Integer;
  b:Boolean;
  st: string;
const
  delta = 35;  //???
begin
  if AutoSaveWindowPos then Settings.RestoreWindowPos(Self, FormDoc);
  ParentForm:=TComponent(Screen.ActiveForm);
  if (Pos('Dlg_', FormDoc) = 1)and(ParentForm<>nil)and(ParentForm is TForm) then begin
    //��� ���������� ������������ ������������ ������������ ����� (� ������ ������ ������������ �������� ����� ����������)
    x:=TForm(ParentForm).Left + TForm(ParentForm).Width div 2 - Self.Width div 2;
    if x + Self.Width > FrmMain.Width - 25 then x := FrmMain.Width - Self.Width-25;
    Self.Left:=max(x, 0);
    i:=TForm(ParentForm).Top + delta;
    if TForm(Parentform).FormStyle=fsMDIChild then i:=i+FrmMain.Lb_GetTop.Top;
    x:=i + TForm(ParentForm).Height div 2 - Self.Height div 2;
    if x + Self.Height > FrmMain.FormsList.Top - 10 + delta then x := FrmMain.FormsList.Top - Self.Height- 10 + delta;
    Self.Top:=max(x, 0);
  end;
  if False then begin
    //������� ������ � �������
    tmp := TToolButton.Create(FrmMain.FormsList);
    tmp.Parent:= FrmMain.FormsList;
    tmp.Visible:=True;
    tmp.Height:=24;
    tmp.AutoSize:=True;
    tmp.Style:=tbsTextButton; //tbsCheck; //
    tmp.Down:=True;
    tmp.ImageIndex:=3;
    //�����, ����� ������ ����������� ������ ������������ - ��� ����� ��������� ������, � ������� ����� �������
    tmp.Left:= 10000;
    //���������
    tmp.Caption:= Caption;
  end;
end;



end.
