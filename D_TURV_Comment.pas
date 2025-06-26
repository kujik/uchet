{
окно вывода комментариев к ячейке грида в турв
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
  //если ни одного коммента нет, то выходим не выводя форму
  v1:=VarToStr(v1); v2:=VarToStr(v2); v3:=VarToStr(v3); v4:=VarToStr(v4);
  if v1 + v2 + v3 + v4 = '' then Exit;
  if v4 <> '' then begin
    v1:='Время работы ночью ' + v4 + 'ч.';
    v4:='';
    Label1.Caption:='';
  end
  else Label1.Caption:='Комментарий:';
  //так проверять не стоит, потому что Visible остается истиной при клике мимо формы, когда форма по факту исчезает (скрывается)
  //if Visible then Exit;
  //а вот баттон фокус уже теряет
  //проверяем дополнительно координатя, они изменятся если переведут на другую ячейку, и тогда перерисуем не дожидаясь закрытия
  if (Bt_Close.Focused)and(X=AX)and(Y=AY) then Exit;
  Width:=300;
  Owner:=AOwner;
  X:=AX;
  Y:=AY;

  //задаем текст меток, обеспечиваем их растяжку по высоте (по ширине у меня не получилось, но не слишком пытался)
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

  //подгоним высоту формы
  Height:=Lb_Sogl.Top + Lb_Sogl.Height + Bt_Close.Height + 20;

  //подгоним координаты формы, делаем чуть ниже и правее квадратика-метки, но чтобы не выходило за границы родительского окна
  //(сделано криво!)
//  Left:=Max(5, Min(Owner.Left+X+20, Owner.Left + Owner.Width - Width -15));
//  Top:=Max(5, min(Owner.Top+50+Y+95, Owner.Top + Owner.Height - Height - 15));

//Lb_Ruk.Caption:=inttostr(Mouse.CursorPos.y)+' '+inttostr(FrmMain.top);

  //окно чуть ниже и правее курсора мышки, но если окажется за границами главного окна приложения, то подгоним чтобы не выходило за границы
  //позиция курсора мышки определяется относительно экрана а не главного окна!
  Top:=Max(Min(FrmMain.Top + FrmMain.Height - Height - 15, Max(10, Mouse.CursorPos.Y + 15)),0);
  Left:=Max(Min(FrmMain.Left + FrmMain.Width - Width - 15, Max(10, Mouse.CursorPos.X + 15)),0);

  //кнопка
  Cth.SetBtn(Bt_Close, mybtClose);

  //покажем форму, для мди-приложения такой показ формы типа нормал приведет к тому, что при клику мимо формы, она скроется
  Show;
end;

{
Если выключить AutoSize, установить нужную ширину и включить обратно AutoSize, то TLabel растягивается вниз с учетом переноса слов, и из него уже можно взять получившиеся размеры текста.
Вот пример своего мессаджбокса. Тут кнопка OK помещается прямо под неизвесным текстом, в котором включаются переносы (если ширина без переносов слишком большая).
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
