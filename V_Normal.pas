{
родительская форма для не-MDI форм
все формы просмотра и ввода данных, не являющиеся MDIchild, должны быть порождены от этой формы

имена формы присваивать по Dlg_ для диалогов изменения данных, иначе Form_
диалоги центрируются относительно активного в момент открытия окна, если только POsition<>poMainFormCenter

при создании
  присваивает FormDoc по имени формы
  сбрасывает Position дя диалогов

при OnShow
  центрируется

FormCanResize
  контролируются размеры

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

//если метод не перекрыт и заданы минимальные размеры, то не уменьшеть форму меньше минимальных
procedure TForm_Normal.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  Resize:= True;
  if NewWidth < MinWidth then NewWidth := MinWidth;
  if NewHeight < MinHeight then NewHeight := MinHeight;
end;

//formdoc, нужен например для сохранения свойств формы и контролов
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
    //для диалоговых отцентрируем относительно родительской формы (в данном случае относительно активной формы приложения)
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
    //создаем кнопку в тулбаре
    tmp := TToolButton.Create(FrmMain.FormsList);
    tmp.Parent:= FrmMain.FormsList;
    tmp.Visible:=True;
    tmp.Height:=24;
    tmp.AutoSize:=True;
    tmp.Style:=tbsTextButton; //tbsCheck; //
    tmp.Down:=True;
    tmp.ImageIndex:=3;
    //нужно, чтобы кнопка создавалась правее существующих - без этого создается первой, в крайней левой позиции
    tmp.Left:= 10000;
    //заголовок
    tmp.Caption:= Caption;
  end;
end;



end.
