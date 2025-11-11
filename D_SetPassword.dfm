object Dlg_SetPassword: TDlg_SetPassword
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1055#1072#1088#1086#1083#1100' '#1072#1076#1084#1080#1085#1080#1089#1090#1088#1072#1090#1086#1088#1072
  ClientHeight = 112
  ClientWidth = 222
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  TextHeight = 13
  object lbl_MinLen: TLabel
    Left = 85
    Top = 62
    Width = 112
    Height = 13
    Caption = ' ('#1084#1080#1085#1080#1084#1091#1084' 5 '#1089#1080#1084#1074#1086#1083#1086#1074')'
  end
  object Bt_Ok: TBitBtn
    Left = 34
    Top = 81
    Width = 75
    Height = 25
    Caption = 'Bt_Ok'
    Default = True
    TabOrder = 0
    OnClick = Bt_OkClick
  end
  object Bt_Cancel: TBitBtn
    Left = 118
    Top = 81
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Bt_Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object edt_Pwd1: TDBEditEh
    Left = 85
    Top = 8
    Width = 137
    Height = 21
    ControlLabel.Width = 37
    ControlLabel.Height = 13
    ControlLabel.Caption = #1055#1072#1088#1086#1083#1100
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    MaxLength = 20
    PasswordChar = '*'
    TabOrder = 2
    Visible = True
  end
  object edt_Pwd2: TDBEditEh
    Left = 85
    Top = 35
    Width = 137
    Height = 21
    ControlLabel.Width = 76
    ControlLabel.Height = 13
    ControlLabel.Caption = #1055#1086#1074#1090#1086#1088' '#1087#1072#1088#1086#1083#1103
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    MaxLength = 20
    PasswordChar = '*'
    TabOrder = 3
    Visible = True
  end
end
