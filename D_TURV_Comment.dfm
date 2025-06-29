object Dlg_TURV_Comment: TDlg_TURV_Comment
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
  ClientHeight = 148
  ClientWidth = 282
  Color = clInfoBk
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    282
    148)
  PixelsPerInch = 96
  TextHeight = 13
  object lbl_Ruk: TLabel
    Left = 0
    Top = 13
    Width = 282
    Height = 13
    Align = alTop
    AutoSize = False
    Caption = '11111111111111111111111'
    ExplicitLeft = 8
    ExplicitTop = 19
    ExplicitWidth = 138
  end
  object lbl1: TLabel
    Left = 0
    Top = 0
    Width = 282
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
  object lbl_Par: TLabel
    Left = 0
    Top = 26
    Width = 282
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
  object lbl_Sogl: TLabel
    Left = 0
    Top = 39
    Width = 282
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
  object Bt_Close: TBitBtn
    Left = 199
    Top = 115
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Bt_Close'
    Default = True
    ModalResult = 1
    TabOrder = 0
    OnClick = Bt_CloseClick
  end
  object tmr1: TTimer
    Interval = 10000
    OnTimer = tmr1Timer
    Left = 12
    Top = 114
  end
end
