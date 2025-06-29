object Form_MDI: TForm_MDI
  Left = 699
  Top = 257
  BorderStyle = bsDialog
  Caption = 'v_md'
  ClientHeight = 176
  ClientWidth = 333
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
    Top = 157
    Width = 333
    Height = 19
    Align = alBottom
    Color = cl3DLight
    ParentBackground = False
    TabOrder = 0
    ExplicitTop = 156
    ExplicitWidth = 329
    object lbl_StatusBar_Right: TLabel
      Left = 244
      Top = 1
      Width = 88
      Height = 17
      Align = alRight
      Caption = 'lbl_StatusBar_Left'
      ExplicitHeight = 13
    end
    object lbl_StatusBar_Left: TLabel
      Left = 1
      Top = 1
      Width = 88
      Height = 17
      Align = alLeft
      Caption = 'lbl_StatusBar_Left'
      ExplicitHeight = 13
    end
  end
  object tmrAfterCreate: TTimer
    Interval = 1
    OnTimer = tmrAfterCreateTimer
    Left = 8
    Top = 96
  end
end
