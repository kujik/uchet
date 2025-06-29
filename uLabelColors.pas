unit uLabelColors;
// модуль цветных TLabel версия 0.1
// [email]Alexpac26@yandex.ru[/email] Тольятти 2011
// переделки GlavMonstr 2023-03-21

{

  Раскрасить подстроки в тексте TLabel
  если посдстрока не найдена, то раскрашена не будет
  with lbl1  do begin
    Caption:='Каждый'+'охотник'+'желает'+'знать';
    ColorsPos('Каждый', 255);
    ColorsPos('охотник', 42495);
    ColorsPos('желает', 65535);
    ColorsPos('знать', 32768);
    ColorsPos('где', 16760576);
    ColorsPos('сидит', 16711680);
    ColorsPos('фазан', 13828244);
  end;

  //задать текст метки с указанием цветов, при этом текст сразу будет установлен и раскрашен
  //цвета задаются последовательностями HEX вида $BBGGRR
  //построки начинающиеся с $ и в которых 6 символов '0'..'F' кодируют цвета и из текста удаляются
  SetCaption('Каждый'+'$0000FFохотник'+'$FF0000желает'+'знать');
  или
  SetCaptionAr(['$000000', 'Отчет за период с ', '$FF0000', DateToStr(DtB) , '$000000' , ' по ', '$FF0000', DateToStr(DtE)]);
  при изменении заголовка метки для корректного отображения надо вызыывать ResetColors,
  либо вызывать методы SetCaption2, SetCaptionAr2 - там цвета перед изменением сбрасываются;

  Перенос по словам при использовании цвета будет некорректным, и также может быть некорректным отображение, если было
  выравнивание или изменение положения контрола после первоначальной отрисовки

  Если надо раскрашивать TLabel на форме, созданный в дизайнтайм, то надо данный модуль uLabelColors подключить в Interface,
  и будут доступна данные методы TLabel,
  при этом порядок модулей должен быть обязательно Vcl.StdCtrls , uLabelColors //uLabelColors ПОСЛЕ Vcl.StdCtrls;

  Если надо создавать TLabel с раскраской динамически, то раскраска работает, но если она была сделана,
  возникает исключение где-то при разрушении этого контрола, поправить не смог.
  В этом случае используем модуль uLabelColors и класс TLabelClr

}

interface
uses  SysUtils, StrUtils, StdCtrls, Classes, Variants, uString;

type
  TLabel = class(StdCtrls.TLabel)
    private
      clr: array of array of Integer;
      b: Boolean;
    public
      //методы с суффиксом 2 уже делают ResetColors перед вызовом отрисовки
      procedure SetCaption(ACaption:string);
      procedure SetCaption2(ACaption:string);
      procedure SetCaptionAr(ACaption:TVarDynArray);
      procedure SetCaptionAr2(ACaption:TVarDynArray);
      procedure Colors(s,e,colorr:Integer);
      procedure ColorsPos(txt:string; colorr: Integer);
      procedure ResetColors;
  end;

implementation

{ TLabel }


function StringToHex_(s: string): string;
var i: Integer;
begin
  Result := '';
  for i := 1 to Length(s) do
    Result := Result+IntToHex(Ord(s[i]),4);
end;

(*
destructor TLabel.Destroy;
begin
{  try
  inherited;
  except
  end;}
  //self.DestroyComponents;
  if b
    then self.Parent:=nil;
inherited;exit;
  if not b
    then inherited;
//    else FreeAndNil(self);
end;
*)

procedure TLabel.ResetColors;
begin
  self.DestroyComponents;
end;

procedure TLabel.Colors(s, e, colorr: Integer);
var realw: Integer;
begin
  with TLabel.Create(self) do begin
    Parent:=self.Parent;
    color:=self.Color;
    Font:=self.Font;
    Top:=self.Top;
    AutoSize:=True;
    Layout:=self.Layout;
    Caption:=self.Caption;
    realw:=width;
    b:= True;
    if self.Alignment=taLeftJustify then begin
      Caption:=copy(self.Caption,1,s-1);
      if s>1 then Left:=self.Left+Width else Left:=self.Left;
    end else if self.Alignment=taRightJustify then begin
      Caption:=copy(self.Caption,s,Length(caption));
      Left:=self.Left+self.width-width;
    end else if self.Alignment=taCenter then begin
      Caption:=self.Caption;
      realw:=width;
      Caption:=copy(self.Caption,1,s-1);
      if s>1 then Left:=self.Left+Width+round((self.Width-realw)/2) else Left:=self.Left+round((self.Width-realw)/2);
    end;
    Caption:=copy(self.Caption,s,e);
    Font.Color:=colorr;
    AutoSize:=False;
    Height:=self.Height;
    //Transparent:=True;
  end;
end;

procedure TLabel.ColorsPos(txt: string; colorr: Integer);
var p:Integer;
begin
  p:=pos(txt,Caption);
  while p>0 do begin
    self.Colors(p,length(txt),colorr);
    p:=posEx(txt,Caption,p+1);
  end;
end;

procedure TLabel.SetCaption(ACaption:string);
var
  i, j: Integer;
  st, st1, st2: string;
  b: Boolean;
begin
  SetLength(Clr, 0);
  st:='';
  i:=1;
  while i <= Length(ACaption) do begin
    if ACaption[i] = '$' then begin
      b:=False;
      j:=i+1;
      st1:='$';
      while (j <= Length(ACaption)) and (ACaption[j] in ['0'..'9', 'A'..'F'])and(j-i < 7) do begin
        st1:=st1+ACaption[j];
        j:=j+1;
      end;
      if (j-i = 6+1) then begin
        SetLength(Clr, Length(Clr)+1);
        Clr[High(Clr)]:=[StrToInt(St1), Length(St)+1];
        i:=j
      end;
    end;
    st:=st+ACaption[i];
    inc(i);
  end;
  Caption:=st;

  for i:=0 to High(Clr) do begin
    if High(Clr) > i
      then j:=Clr[i+1][1]
      else j:=Length(Caption)+1;
    Self.Colors(Clr[i][1],j-Clr[i][1],Clr[i][0]);
  end;
end;

procedure TLabel.SetCaption2(ACaption:string);
begin
  Resetcolors;
  SetCaption(ACaption);
end;


procedure TLabel.SetCaptionAr(ACaption:TVarDynArray);
var
  i, j: Integer;
  st, st1, st2: string;
  b: Boolean;
begin
  st:='';
  for i:=0 to High(ACaption) do begin
    st:=st + VarToStr(ACaption[i]);
  end;
  SetCaption(st);
end;

procedure TLabel.SetCaptionAr2(ACaption:TVarDynArray);
begin
  Resetcolors;
  SetCaptionAr(ACaption);
end;


end.
