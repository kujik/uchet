object Form_MDI: TForm_MDI
  Left = 699
  Top = 257
  BorderStyle = bsDialog
  Caption = 'v_md'
  ClientHeight = 175
  ClientWidth = 329
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poDefault
  Visible = True
  OnActivate = FormActivate
  OnCanResize = FormCanResize
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 13
  object pnl_StatusBar: TPanel
    Left = 0
    Top = 156
    Width = 329
    Height = 19
    Align = alBottom
    Color = cl3DLight
    ParentBackground = False
    TabOrder = 0
    object lbl_StatusBar_Right: TLabel
      Left = 244
      Top = 1
      Width = 86
      Height = 13
      Align = alRight
      Caption = 'lbl_StatusBar_Left'
    end
    object lbl_StatusBar_Left: TLabel
      Left = 1
      Top = 1
      Width = 86
      Height = 13
      Align = alLeft
      Caption = 'lbl_StatusBar_Left'
    end
  end
  object tmrAfterCreate: TTimer
    Interval = 1
    OnTimer = tmrAfterCreateTimer
    Left = 8
    Top = 96
  end
end
