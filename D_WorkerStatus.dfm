inherited Dlg_WorkerStatus: TDlg_WorkerStatus
  Caption = #1057#1090#1072#1090#1091#1089' '#1088#1072#1073#1086#1090#1085#1080#1082#1072
  ClientHeight = 184
  ClientWidth = 600
  ExplicitWidth = 616
  ExplicitHeight = 223
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bt_Cancel: TBitBtn
    Left = 517
    Top = 151
    ExplicitLeft = 517
    ExplicitTop = 151
  end
  inherited Bt_OK: TBitBtn
    Left = 436
    Top = 151
    ExplicitLeft = 436
    ExplicitTop = 151
  end
  object Cb_Worker: TDBComboBoxEh
    Left = 87
    Top = 14
    Width = 508
    Height = 21
    ControlLabel.Width = 48
    ControlLabel.Height = 13
    ControlLabel.Caption = #1056#1072#1073#1086#1090#1085#1080#1082
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    TabOrder = 2
    Visible = True
  end
  object De_Date: TDBDateTimeEditEh
    Left = 87
    Top = 41
    Width = 121
    Height = 21
    ControlLabel.Width = 26
    ControlLabel.Height = 13
    ControlLabel.Caption = #1044#1072#1090#1072
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    Kind = dtkDateEh
    TabOrder = 3
    Visible = True
  end
  object Cb_Status: TDBComboBoxEh
    Left = 87
    Top = 68
    Width = 121
    Height = 21
    ControlLabel.Width = 36
    ControlLabel.Height = 13
    ControlLabel.Caption = #1057#1090#1072#1090#1091#1089
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    TabOrder = 4
    Visible = True
    OnChange = Cb_StatusChange
  end
  object Cb_Division: TDBComboBoxEh
    Left = 87
    Top = 95
    Width = 508
    Height = 21
    ControlLabel.Width = 80
    ControlLabel.Height = 13
    ControlLabel.Caption = #1055#1086#1076#1088#1072#1079#1076#1077#1083#1077#1085#1080#1077
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    TabOrder = 5
    Visible = True
  end
  object Cb_Job: TDBComboBoxEh
    Left = 87
    Top = 122
    Width = 508
    Height = 21
    ControlLabel.Width = 57
    ControlLabel.Height = 13
    ControlLabel.Caption = #1044#1086#1083#1078#1085#1086#1089#1090#1100
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    TabOrder = 6
    Visible = True
  end
end
