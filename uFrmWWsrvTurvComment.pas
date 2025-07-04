{
окно вывода комментариев к ячейке грида в турв
}

unit uFrmWWsrvTurvComment;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Math;

type
  TFrmWWsrvTurvComment = class(TForm)
    lbl1: TLabel;
    lblRuk: TLabel;
    lblPar: TLabel;
    lblSogl: TLabel;
    tmr1: TTimer;
    btnClose: TBitBtn;
    procedure btnCloseClick(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
  private
    Owner: TForm;
    X, Y: Integer;
  public
    procedure ShowDialog(AOwner: TForm; AX: Integer; AY: Integer; v1, v2, v3, v4: Variant);
  end;

var
  FrmWWsrvTurvComment: TFrmWWsrvTurvComment;

implementation
uses
  uForms,
  uData,
  uFrmMain
  ;

{$R *.dfm}


procedure TFrmWWsrvTurvComment.tmr1Timer(Sender: TObject);
begin
  Close;
end;

procedure TFrmWWsrvTurvComment.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmWWsrvTurvComment.ShowDialog(AOwner: TForm; AX: Integer; AY: Integer; v1, v2, v3, v4: Variant);
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
    lbl1.Caption:='';
  end
  else lbl1.Caption:='Комментарий:';
  //так проверять не стоит, потому что Visible остается истиной при клике мимо формы, когда форма по факту исчезает (скрывается)
  //if Visible then Exit;
  //а вот баттон фокус уже теряет
  //проверяем дополнительно координатя, они изменятся если переведут на другую ячейку, и тогда перерисуем не дожидаясь закрытия
  if (btnClose.Focused)and(X=AX)and(Y=AY) then Exit;
  Width:=300;
  Owner:=AOwner;
  X:=AX;
  Y:=AY;

  //задаем текст меток, обеспечиваем их растяжку по высоте (по ширине у меня не получилось, но не слишком пытался)
  lblRuk.AutoSize:=True;
  lblRuk.Caption:=VarToStr(v1);
//  if lblRuk.Width < 350 then begin
    lblRuk.AutoSize:=False;
    lblRuk.WordWrap:=True;
//    Width:=210;
    lblRuk.Width:=290;
    lblRuk.AutoSize:=True;
  lblRuk.Visible:=lblRuk.Caption <> '';
//  end;

  lblPar.AutoSize:=True;
  lblPar.Caption:=VarToStr(v2);
  lblPar.AutoSize:=False;
  lblPar.WordWrap:=True;
  lblPar.Width:=290;
  lblPar.AutoSize:=True;
  lblPar.Visible:=lblPar.Caption <> '';

  lblSogl.AutoSize:=True;
  lblSogl.Caption:=VarToStr(v3);
  lblSogl.AutoSize:=False;
  lblSogl.WordWrap:=True;
  lblSogl.Width:=290;
  lblSogl.AutoSize:=True;
  lblSogl.Visible:=lblSogl.Caption <> '';

  //подгоним высоту формы
  Height:=lblSogl.Top + lblSogl.Height + btnClose.Height + 20;

  //подгоним координаты формы, делаем чуть ниже и правее квадратика-метки, но чтобы не выходило за границы родительского окна
  //(сделано криво!)
//  Left:=Max(5, Min(Owner.Left+X+20, Owner.Left + Owner.Width - Width -15));
//  Top:=Max(5, min(Owner.Top+50+Y+95, Owner.Top + Owner.Height - Height - 15));

//lblRuk.Caption:=inttostr(Mouse.CursorPos.y)+' '+inttostr(FrmMain.top);

  //окно чуть ниже и правее курсора мышки, но если окажется за границами главного окна приложения, то подгоним чтобы не выходило за границы
  //позиция курсора мышки определяется относительно экрана а не главного окна!
  Top:=Max(Min(FrmMain.Top + FrmMain.Height - Height - 15, Max(10, Mouse.CursorPos.Y + 15)),0);
  Left:=Max(Min(FrmMain.Left + FrmMain.Width - Width - 15, Max(10, Mouse.CursorPos.X + 15)),0);

  //кнопка
  Cth.SetBtn(btnClose, mybtClose);

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

