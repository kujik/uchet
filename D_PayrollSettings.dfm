inherited Dlg_PayrollSettings: TDlg_PayrollSettings
  BorderStyle = bsDialog
  Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099
  ClientHeight = 127
  ClientWidth = 335
  ExplicitWidth = 341
  ExplicitHeight = 156
  PixelsPerInch = 96
  TextHeight = 13
  object Lb_Norm: TLabel
    Left = 8
    Top = 8
    Width = 297
    Height = 13
    Caption = #1053#1086#1088#1084#1072' ('#1073#1072#1083#1083#1086#1074' '#1074' '#1084#1077#1089#1103#1094') - '#1076#1083#1103' '#1042#1057#1045#1061' '#1074#1077#1076#1086#1084#1086#1089#1090#1077#1081' '#1079#1072' '#1087#1077#1088#1080#1086#1076'.'
  end
  object Bt_OK: TBitBtn
    Left = 175
    Top = 98
    Width = 75
    Height = 25
    Caption = 'Bt_OK'
    TabOrder = 0
    OnClick = Bt_OKClick
  end
  object Bt_Cancel: TBitBtn
    Left = 252
    Top = 98
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Bt_Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object Ne_Norm0: TDBNumberEditEh
    Left = 30
    Top = 23
    Width = 55
    Height = 21
    ControlLabel.Width = 20
    ControlLabel.Height = 13
    ControlLabel.Caption = #1062#1077#1093
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButton.Style = ebsEllipsisEh
    EditButtons = <>
    HighlightRequired = True
    MaxValue = 8.000000000000000000
    MinValue = 744.000000000000000000
    TabOrder = 2
    Visible = True
  end
  object Cb_Method: TDBComboBoxEh
    Left = 8
    Top = 71
    Width = 320
    Height = 21
    ControlLabel.Width = 317
    ControlLabel.Height = 13
    ControlLabel.Caption = #1052#1077#1090#1086#1076' '#1088#1072#1089#1095#1077#1090#1072' '#1079#1072#1088#1072#1073#1086#1090#1085#1086#1081' '#1087#1083#1072#1090#1099' ('#1076#1083#1103' '#1101#1090#1086#1075#1086' '#1087#1086#1076#1088#1072#1079#1076#1077#1083#1077#1085#1080#1103')'
    ControlLabel.Visible = True
    DynProps = <>
    EditButtons = <>
    HighlightRequired = True
    LimitTextToListValues = True
    TabOrder = 3
    Visible = True
  end
  object Ne_Norm1: TDBNumberEditEh
    Left = 123
    Top = 23
    Width = 55
    Height = 21
    ControlLabel.Width = 27
    ControlLabel.Height = 13
    ControlLabel.Caption = #1054#1092#1080#1089
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButton.Style = ebsEllipsisEh
    EditButtons = <>
    HighlightRequired = True
    MaxValue = 8.000000000000000000
    MinValue = 744.000000000000000000
    TabOrder = 4
    Visible = True
  end
end
