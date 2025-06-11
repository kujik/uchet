inherited Dlg_J_Devel: TDlg_J_Devel
  Caption = 'Dlg_J_Devel'
  ClientHeight = 365
  ClientWidth = 761
  DoubleBuffered = True
  ExplicitWidth = 767
  ExplicitHeight = 393
  PixelsPerInch = 96
  TextHeight = 13
  inherited P_StatusBar: TPanel
    Top = 346
    Width = 761
    ExplicitTop = 346
    ExplicitWidth = 761
    inherited Lb_StatusBar_Right: TLabel
      Left = 672
      Height = 17
      ExplicitLeft = 672
    end
    inherited Lb_StatusBar_Left: TLabel
      Height = 17
    end
  end
  object Cb_Id_DevelType: TDBComboBoxEh [1]
    Left = 84
    Top = 8
    Width = 195
    Height = 21
    ControlLabel.Width = 59
    ControlLabel.Height = 13
    ControlLabel.Caption = #1042#1080#1076' '#1088#1072#1073#1086#1090#1099
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    TabOrder = 2
    Visible = True
  end
  object Cb_Project: TDBComboBoxEh [2]
    Left = 84
    Top = 62
    Width = 669
    Height = 21
    ControlLabel.Width = 37
    ControlLabel.Height = 13
    ControlLabel.Caption = #1055#1088#1086#1077#1082#1090
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    Anchors = [akLeft, akTop, akRight]
    DynProps = <>
    EditButtons = <>
    TabOrder = 4
    Visible = True
  end
  object Cb_Name: TDBComboBoxEh [3]
    Left = 84
    Top = 89
    Width = 669
    Height = 21
    ControlLabel.Width = 76
    ControlLabel.Height = 26
    ControlLabel.Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077#13#10#1080#1079#1076#1077#1083#1080#1103
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    Anchors = [akLeft, akTop, akRight]
    DynProps = <>
    EditButtons = <>
    TabOrder = 5
    Visible = True
  end
  object De_Dt_Beg: TDBDateTimeEditEh [4]
    Left = 84
    Top = 116
    Width = 111
    Height = 21
    ControlLabel.Width = 41
    ControlLabel.Height = 26
    ControlLabel.Caption = #1044#1072#1090#1072#13#10#1079#1072#1087#1091#1089#1082#1072
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    Kind = dtkDateEh
    TabOrder = 6
    Visible = True
  end
  object De_Dt_Plan: TDBDateTimeEditEh [5]
    Left = 280
    Top = 116
    Width = 111
    Height = 21
    ControlLabel.Width = 55
    ControlLabel.Height = 26
    ControlLabel.Caption = #1055#1083#1072#1085#1086#1074#1072#1103#13#10#1076#1072#1090#1072' '#1089#1076#1072#1095#1080
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    Kind = dtkDateEh
    TabOrder = 7
    Visible = True
  end
  object De_Dt_End: TDBDateTimeEditEh [6]
    Left = 476
    Top = 116
    Width = 111
    Height = 21
    ControlLabel.Width = 69
    ControlLabel.Height = 26
    ControlLabel.Caption = #1060#1072#1082#1090#1080#1095#1077#1089#1082#1072#1103#13#10#1076#1072#1090#1072' '#1089#1076#1072#1095#1080
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    Kind = dtkDateEh
    TabOrder = 8
    Visible = True
  end
  object Cb_Id_Status: TDBComboBoxEh [7]
    Left = 84
    Top = 143
    Width = 195
    Height = 21
    ControlLabel.Width = 34
    ControlLabel.Height = 13
    ControlLabel.Caption = #1057#1090#1072#1090#1091#1089
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    LimitTextToListValues = True
    TabOrder = 9
    Visible = True
  end
  object M_Comm: TDBMemoEh [8]
    Left = 84
    Top = 224
    Width = 669
    Height = 73
    ControlLabel.Width = 70
    ControlLabel.Height = 13
    ControlLabel.Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    Anchors = [akLeft, akTop, akRight, akBottom]
    AutoSize = False
    DynProps = <>
    EditButtons = <>
    MaxLength = 4000
    TabOrder = 13
    Visible = True
    WantReturns = True
  end
  object Ne_Cnt: TDBNumberEditEh [9]
    Left = 84
    Top = 197
    Width = 80
    Height = 21
    ControlLabel.Width = 37
    ControlLabel.Height = 13
    ControlLabel.Caption = #1057#1076#1077#1083#1082#1072
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    currency = False
    DynProps = <>
    EditButton.DefaultAction = True
    EditButtons = <>
    MaxValue = 500.000000000000000000
    TabOrder = 11
    Value = 12235123.050000000000000000
    Visible = True
  end
  object Cb_Id_Kns: TDBComboBoxEh [10]
    Left = 84
    Top = 170
    Width = 195
    Height = 21
    ControlLabel.Width = 64
    ControlLabel.Height = 13
    ControlLabel.Caption = #1050#1086#1085#1089#1090#1088#1091#1082#1090#1086#1088
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    TabOrder = 10
    Visible = True
  end
  object Ne_Time: TDBNumberEditEh [11]
    Left = 198
    Top = 197
    Width = 80
    Height = 21
    ControlLabel.Width = 28
    ControlLabel.Height = 13
    ControlLabel.Caption = #1063#1072#1089#1099
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    currency = False
    DynProps = <>
    EditButton.DefaultAction = True
    EditButtons = <>
    MaxValue = 500.000000000000000000
    TabOrder = 12
    Value = 12235123.050000000000000000
    Visible = True
  end
  object Cb_Slash: TDBComboBoxEh [12]
    Left = 84
    Top = 35
    Width = 195
    Height = 21
    ControlLabel.Width = 56
    ControlLabel.Height = 13
    ControlLabel.Caption = #8470' '#1080#1079#1076#1077#1083#1080#1103
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    TabOrder = 3
    Visible = True
  end
  inherited P_Bottom: TPanel
    Top = 316
    Width = 761
    ExplicitTop = 316
    ExplicitWidth = 761
    inherited Bt_OK: TBitBtn
      Left = 532
      ExplicitLeft = 532
    end
    inherited Bt_Cancel: TBitBtn
      Left = 613
      Top = 6
      ExplicitLeft = 613
      ExplicitTop = 6
    end
  end
  inherited Timer_AfterStart: TTimer
    Left = 0
    Top = 408
  end
end
