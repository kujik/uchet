inherited Dlg_AddTurv: TDlg_AddTurv
  Caption = #1058#1059#1056#1042
  ClientHeight = 99
  ClientWidth = 473
  ExplicitWidth = 489
  ExplicitHeight = 138
  PixelsPerInch = 96
  TextHeight = 13
  object Lb_AllCreated: TLabel [0]
    Left = 92
    Top = 62
    Width = 129
    Height = 13
    Caption = #1042#1089#1077' '#1090#1072#1073#1077#1083#1080' '#1091#1078#1077' '#1089#1086#1079#1076#1072#1085#1099'!'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  inherited Bt_Cancel: TBitBtn
    Left = 390
    Top = 66
    ExplicitLeft = 390
    ExplicitTop = 66
  end
  inherited Bt_OK: TBitBtn
    Left = 309
    Top = 66
    ExplicitLeft = 309
    ExplicitTop = 66
  end
  object Cb_Division: TDBComboBoxEh
    Left = 93
    Top = 35
    Width = 373
    Height = 21
    ControlLabel.Width = 80
    ControlLabel.Height = 13
    ControlLabel.Caption = #1055#1086#1076#1088#1072#1079#1076#1077#1083#1077#1085#1080#1077
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    TabOrder = 2
    Visible = True
  end
  object Cb_Period: TDBComboBoxEh
    Left = 92
    Top = 8
    Width = 373
    Height = 21
    ControlLabel.Width = 38
    ControlLabel.Height = 13
    ControlLabel.Caption = #1055#1077#1088#1080#1086#1076
    ControlLabel.Visible = True
    ControlLabelLocation.Position = lpLeftCenterEh
    DynProps = <>
    EditButtons = <>
    TabOrder = 3
    Visible = True
    OnChange = Cb_PeriodChange
  end
end
