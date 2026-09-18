object Form1: TForm1
  Left = 375
  Top = 124
  Caption = 'Form1'
  ClientHeight = 380
  ClientWidth = 513
  Color = clBtnFace
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = True
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 28
    Top = 7
    Width = 208
    Height = 56
    Caption = 'Print To Pdf - Text'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 277
    Top = 7
    Width = 208
    Height = 56
    Caption = 'Print Preview - Text'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 28
    Top = 97
    Width = 208
    Height = 56
    Caption = 'Print To Pdf - Graphic'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 277
    Top = 97
    Width = 208
    Height = 56
    Caption = 'Print Preview - Graphic'
    TabOrder = 3
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 28
    Top = 187
    Width = 208
    Height = 57
    Caption = 'Print To Pdf - Rtf Text'
    TabOrder = 4
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 277
    Top = 187
    Width = 208
    Height = 57
    Caption = 'Print Preview - Rtf Text'
    TabOrder = 5
    OnClick = Button6Click
  end
end
