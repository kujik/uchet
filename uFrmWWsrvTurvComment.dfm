object FrmWWsrvTurvComment: TFrmWWsrvTurvComment
  Left = 0
  Top = 0
  Caption = 'FrmWWsrvTurvComment'
  ClientHeight = 126
  ClientWidth = 268
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  DesignSize = (
    268
    126)
  TextHeight = 15
  object lbl1: TLabel
    Left = 0
    Top = 0
    Width = 268
    Height = 13
    Align = alTop
    Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsUnderline]
    ParentFont = False
    ExplicitWidth = 71
  end
  object lblRuk: TLabel
    Left = 0
    Top = 13
    Width = 268
    Height = 13
    Align = alTop
    AutoSize = False
    Caption = '11111111111111111111111'
    ExplicitLeft = 8
    ExplicitTop = 19
    ExplicitWidth = 138
  end
  object lblPar: TLabel
    Left = 0
    Top = 26
    Width = 268
    Height = 13
    Align = alTop
    AutoSize = False
    Caption = '11111111111111111111111'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    WordWrap = True
    ExplicitLeft = 5
    ExplicitTop = 52
    ExplicitWidth = 138
  end
  object lblSogl: TLabel
    Left = 0
    Top = 39
    Width = 268
    Height = 13
    Align = alTop
    AutoSize = False
    Caption = '11111111111111111111111'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clFuchsia
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    WordWrap = True
    ExplicitLeft = 5
    ExplicitTop = 84
    ExplicitWidth = 138
  end
  object btnClose: TBitBtn
    Left = 193
    Top = 102
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'btnClose'
    Default = True
    ModalResult = 1
    TabOrder = 0
    OnClick = btnCloseClick
    ExplicitLeft = 198
    ExplicitTop = 122
  end
  object tmr1: TTimer
    Interval = 10000
    OnTimer = tmr1Timer
    Left = 4
    Top = 90
  end
end
