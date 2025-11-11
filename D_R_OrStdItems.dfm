inherited Dlg_R_OrStdItems: TDlg_R_OrStdItems
  Caption = #1057#1090#1072#1085#1076#1072#1088#1090#1085#1086#1077' '#1080#1079#1076#1077#1083#1080#1077
  ClientHeight = 158
  ClientWidth = 663
  ExplicitWidth = 679
  ExplicitHeight = 197
  TextHeight = 13
  object lbl_Route: TLabel [0]
    Left = 4
    Top = 34
    Width = 88
    Height = 13
    Caption = #1055#1088#1086#1080#1079#1074'. '#1084#1072#1088#1096#1088#1091#1090
  end
  inherited pnl_StatusBar: TPanel
    Top = 139
    Width = 663
    ExplicitTop = 139
    ExplicitWidth = 663
    inherited lbl_StatusBar_Right: TLabel
      Left = 580
      ExplicitLeft = 580
    end
  end
  inherited pnl_Bottom: TPanel
    Top = 108
    Width = 663
    ExplicitTop = 108
    ExplicitWidth = 663
    inherited bvl1: TBevel
      Width = 667
      ExplicitWidth = 672
    end
    inherited Bt_OK: TBitBtn
      Left = 492
      ExplicitLeft = 488
      ExplicitTop = 4
    end
    inherited Bt_Cancel: TBitBtn
      Left = 573
      ExplicitLeft = 569
      ExplicitTop = 4
    end
    inherited chb_NoClose: TCheckBox
      Left = 365
      ExplicitLeft = 361
      ExplicitTop = 9
    end
  end
  object edt_name: TDBEditEh [3]
    Left = 97
    Top = 7
    Width = 568
    Height = 21
    ControlLabel.Width = 76
    ControlLabel.Height = 13
    ControlLabel.Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    MaxLength = 400
    TabOrder = 2
    Text = 'edt_name'
    Visible = True
  end
  object chb_R1: TDBCheckBoxEh [4]
    Left = 96
    Top = 33
    Width = 49
    Height = 17
    Caption = #1057#1043#1055
    DynProps = <>
    TabOrder = 3
  end
  object chb_R2: TDBCheckBoxEh [5]
    Left = 151
    Top = 33
    Width = 49
    Height = 17
    Caption = #1057#1043#1055
    DynProps = <>
    TabOrder = 5
  end
  object chb_R3: TDBCheckBoxEh [6]
    Left = 206
    Top = 33
    Width = 49
    Height = 17
    Caption = #1057#1043#1055
    DynProps = <>
    TabOrder = 4
  end
  object chb_R4: TDBCheckBoxEh [7]
    Left = 261
    Top = 33
    Width = 49
    Height = 17
    Caption = #1057#1043#1055
    DynProps = <>
    TabOrder = 6
  end
  object chb_R5: TDBCheckBoxEh [8]
    Left = 316
    Top = 33
    Width = 49
    Height = 17
    Caption = #1057#1043#1055
    DynProps = <>
    TabOrder = 7
  end
  object chb_R6: TDBCheckBoxEh [9]
    Left = 371
    Top = 33
    Width = 49
    Height = 17
    Caption = #1057#1043#1055
    DynProps = <>
    TabOrder = 8
  end
  object chb_R0: TDBCheckBoxEh [10]
    Left = 481
    Top = 33
    Width = 95
    Height = 17
    Caption = #1041#1077#1079' '#1084#1072#1088#1096#1088#1091#1090#1072
    DynProps = <>
    TabOrder = 10
  end
  object chb_Wo_Estimate: TDBCheckBoxEh [11]
    Left = 590
    Top = 33
    Width = 82
    Height = 17
    Caption = #1041#1077#1079' '#1089#1084#1077#1090#1099
    DynProps = <>
    TabOrder = 11
  end
  object nedt_Price: TDBNumberEditEh [12]
    Left = 96
    Top = 56
    Width = 104
    Height = 21
    ControlLabel.Width = 26
    ControlLabel.Height = 13
    ControlLabel.Caption = #1062#1077#1085#1072
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    currency = True
    DynProps = <>
    EditButton.Visible = True
    EditButtons = <>
    MaxValue = 999999999.000000000000000000
    TabOrder = 12
    Visible = True
  end
  object nedt_Price_PP: TDBNumberEditEh [13]
    Left = 280
    Top = 56
    Width = 104
    Height = 21
    ControlLabel.Width = 70
    ControlLabel.Height = 13
    ControlLabel.Caption = #1055#1077#1088#1077#1087#1088#1086#1076#1072#1078#1072
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    currency = True
    DynProps = <>
    EditButton.Visible = True
    EditButtons = <>
    MaxValue = 999999999.000000000000000000
    TabOrder = 13
    Visible = True
  end
  object chb_by_sgp: TDBCheckBoxEh [14]
    Left = 97
    Top = 83
    Width = 96
    Height = 17
    Caption = #1059#1095#1077#1090' '#1087#1086' '#1057#1043#1055
    DynProps = <>
    TabOrder = 14
  end
  object chb_R7: TDBCheckBoxEh [15]
    Left = 426
    Top = 33
    Width = 49
    Height = 17
    Caption = #1057#1043#1055
    DynProps = <>
    TabOrder = 9
  end
  inherited tmrAfterCreate: TTimer
    Left = 160
    Top = 312
  end
end
