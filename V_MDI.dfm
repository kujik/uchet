object Form_MDI: TForm_MDI
  Left = 699
  Top = 257
  BorderStyle = bsDialog
  Caption = 'v_md'
  ClientHeight = 471
  ClientWidth = 794
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnActivate = FormActivate
  OnCanResize = FormCanResize
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object P_StatusBar: TPanel
    Left = 0
    Top = 452
    Width = 794
    Height = 19
    Align = alBottom
    Color = cl3DLight
    ParentBackground = False
    TabOrder = 0
    object Lb_StatusBar_Right: TLabel
      Left = 705
      Top = 1
      Width = 88
      Height = 13
      Align = alRight
      Caption = 'Lb_StatusBar_Left'
    end
    object Lb_StatusBar_Left: TLabel
      Left = 1
      Top = 1
      Width = 88
      Height = 13
      Align = alLeft
      Caption = 'Lb_StatusBar_Left'
    end
  end
  object Timer_AfterStart: TTimer
    Interval = 1
    OnTimer = Timer_AfterStartTimer
    Left = 8
    Top = 96
  end
end
