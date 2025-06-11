inherited Dlg_R_Itm_Units: TDlg_R_Itm_Units
  Caption = 'Dlg_R_Itm_Units'
  ClientHeight = 169
  ClientWidth = 288
  ExplicitWidth = 294
  ExplicitHeight = 198
  PixelsPerInch = 96
  TextHeight = 13
  inherited P_StatusBar: TPanel
    Top = 150
    Width = 288
    ExplicitTop = 150
    ExplicitWidth = 288
    inherited Lb_StatusBar_Right: TLabel
      Left = 199
      ExplicitLeft = 199
    end
  end
  inherited P_Bottom: TPanel
    Top = 119
    Width = 288
    ExplicitTop = 119
    ExplicitWidth = 288
    inherited Bevel1: TBevel
      Width = 288
      ExplicitWidth = 288
    end
    inherited Bt_OK: TBitBtn
      Left = 121
      ExplicitLeft = 121
    end
    inherited Bt_Cancel: TBitBtn
      Left = 202
      ExplicitLeft = 202
    end
    inherited Chb_NoClose: TCheckBox
      Left = -6
      ExplicitLeft = -6
    end
  end
  object Cb_Id_MeasureGroup: TDBComboBoxEh [2]
    Left = 84
    Top = 8
    Width = 195
    Height = 21
    ControlLabel.Width = 35
    ControlLabel.Height = 13
    ControlLabel.Caption = #1043#1088#1091#1087#1087#1072
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    TabOrder = 2
    Visible = True
  end
  object E_Name_Unit: TDBEditEh [3]
    Left = 85
    Top = 35
    Width = 195
    Height = 21
    ControlLabel.Width = 76
    ControlLabel.Height = 13
    ControlLabel.Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    MaxLength = 400
    TabOrder = 3
    Text = 'E_Name_Unit'
    Visible = True
  end
  object Ne_Full_Name: TDBEditEh [4]
    Left = 84
    Top = 62
    Width = 195
    Height = 21
    ControlLabel.Width = 74
    ControlLabel.Height = 26
    ControlLabel.Caption = #1055#1086#1083#1085#1086#1077#13#10#1085#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    MaxLength = 400
    TabOrder = 4
    Text = 'E_Name'
    Visible = True
  end
  object Ne_Pression: TDBNumberEditEh [5]
    Left = 84
    Top = 89
    Width = 104
    Height = 21
    ControlLabel.Width = 47
    ControlLabel.Height = 13
    ControlLabel.Caption = #1058#1086#1095#1085#1086#1089#1090#1100
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    currency = False
    DecimalPlaces = 0
    DynProps = <>
    EditButton.Visible = True
    EditButtons = <>
    MaxValue = 999999999.000000000000000000
    TabOrder = 5
    Visible = True
  end
  inherited Timer_AfterStart: TTimer
    Left = 168
    Top = 312
  end
end
