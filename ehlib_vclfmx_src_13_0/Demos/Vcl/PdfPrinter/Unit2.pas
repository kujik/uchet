unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, pngimage, ExtCtrls,
  ImgList, StdCtrls, ComCtrls, DBCtrlsEh;

type
  TForm2 = class(TForm)
    Image1: TImage;
    ImageList16: TImageList;
    ImageList24: TImageList;
    ImageList32: TImageList;
    DBRichEditEh1: TDBRichEditEh;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

end.
