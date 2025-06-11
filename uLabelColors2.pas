unit uLabelColors2;

interface
uses  SysUtils, StrUtils, StdCtrls, Classes, Variants, uString;

type
  TLabelClr = class(StdCtrls.TLabel)
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
      destructor Destroy; override;
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

destructor TLabelClr.Destroy;
begin
  inherited;
end;

procedure TLabelClr.ResetColors;
begin
  self.DestroyComponents;
end;

procedure TLabelClr.Colors(s, e, colorr: Integer);
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

procedure TLabelClr.ColorsPos(txt: string; colorr: Integer);
var p:Integer;
begin
  p:=pos(txt,Caption);
  while p>0 do begin
    self.Colors(p,length(txt),colorr);
    p:=posEx(txt,Caption,p+1);
  end;
end;

procedure TLabelClr.SetCaption(ACaption:string);
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

procedure TLabelClr.SetCaption2(ACaption:string);
begin
  Resetcolors;
  SetCaption(ACaption);
end;


procedure TLabelClr.SetCaptionAr(ACaption:TVarDynArray);
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

procedure TLabelClr.SetCaptionAr2(ACaption:TVarDynArray);
begin
  Resetcolors;
  SetCaptionAr(ACaption);
end;


end.
