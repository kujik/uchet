object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 329
  ClientWidth = 289
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  DesignSize = (
    289
    329)
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 32
    Top = 32
    Width = 223
    Height = 49
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Form1 - DBGridEh + DBVertGridEh'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 32
    Top = 96
    Width = 223
    Height = 49
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Form2'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 32
    Top = 160
    Width = 223
    Height = 49
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Form3'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 32
    Top = 224
    Width = 223
    Height = 49
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Form4  - DBGridEh with Grouping'
    TabOrder = 3
    OnClick = Button4Click
  end
end
