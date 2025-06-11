inherited Form_Rep_Orders_PrimeCost: TForm_Rep_Orders_PrimeCost
  Caption = #1054#1090#1095#1077#1090' '#1087#1086' '#1089#1077#1073#1077#1089#1090#1086#1080#1084#1086#1089#1090#1080' '#1079#1072#1082#1072#1079#1086#1074
  ClientHeight = 200
  ClientWidth = 629
  OnCloseQuery = FormCloseQuery
  ExplicitWidth = 635
  ExplicitHeight = 228
  PixelsPerInch = 96
  TextHeight = 13
  object Lb_1_Caption: TLabel [0]
    Left = 0
    Top = 0
    Width = 629
    Height = 13
    Align = alTop
    Caption = 'Lb_1_Caption'
    ExplicitWidth = 66
  end
  inherited P_StatusBar: TPanel
    Top = 181
    Width = 629
    ExplicitLeft = -8
    ExplicitTop = 122
    ExplicitWidth = 629
    inherited Lb_StatusBar_Right: TLabel
      Left = 540
      Height = 17
      ExplicitLeft = 540
    end
    inherited Lb_StatusBar_Left: TLabel
      Height = 17
    end
  end
  object P_Bottom: TPanel [2]
    Left = 0
    Top = 146
    Width = 629
    Height = 35
    Align = alBottom
    TabOrder = 1
    ExplicitTop = 94
    DesignSize = (
      629
      35)
    object Bt_Cancel: TBitBtn
      Left = 549
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Bt_Cancel'
      ModalResult = 2
      TabOrder = 0
      OnClick = Bt_CancelClick
    end
    object Bt_Ok: TBitBtn
      Left = 388
      Top = 6
      Width = 155
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Bt_Ok'
      Default = True
      TabOrder = 1
      OnClick = Bt_OkClick
    end
    object Cb_DtB: TDBComboBoxEh
      Left = 57
      Top = 6
      Width = 130
      Height = 21
      ControlLabel.Width = 42
      ControlLabel.Height = 26
      ControlLabel.Caption = #1053#1072#1095#1072#1083#1086#13#10#1087#1077#1088#1080#1086#1076#1072
      ControlLabel.Visible = True
      ControlLabelLocation.Position = lpLeftCenterEh
      DynProps = <>
      EditButtons = <>
      LimitTextToListValues = True
      TabOrder = 2
      Visible = True
    end
    object Cb_DtE: TDBComboBoxEh
      Left = 242
      Top = 6
      Width = 130
      Height = 21
      ControlLabel.Width = 42
      ControlLabel.Height = 26
      ControlLabel.Caption = #1050#1086#1085#1077#1094#13#10#1087#1077#1088#1080#1086#1076#1072
      ControlLabel.Visible = True
      ControlLabelLocation.Position = lpLeftCenterEh
      DynProps = <>
      EditButtons = <>
      LimitTextToListValues = True
      TabOrder = 3
      Visible = True
    end
  end
  object P_Main: TPanel [3]
    Left = 0
    Top = 13
    Width = 629
    Height = 133
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitHeight = 62
    object Lb_1: TLabel
      Left = 16
      Top = 24
      Width = 49
      Height = 13
      Caption = #1055#1088#1086#1076#1072#1078#1072':'
    end
    object Lb_2: TLabel
      Left = 16
      Top = 64
      Width = 50
      Height = 13
      Caption = #1054#1090#1075#1088#1091#1079#1082#1072':'
    end
    object Lb_3: TLabel
      Left = 16
      Top = 104
      Width = 64
      Height = 13
      Caption = #1056#1077#1072#1083#1080#1079#1072#1094#1080#1103':'
    end
    object Ne_1_R: TDBNumberEditEh
      Left = 190
      Top = 21
      Width = 130
      Height = 21
      ControlLabel.Width = 43
      ControlLabel.Height = 13
      ControlLabel.Caption = #1056#1086#1079#1085#1080#1094#1072
      ControlLabel.Visible = True
      currency = True
      DecimalPlaces = 0
      DynProps = <>
      EditButtons = <>
      ReadOnly = True
      TabOrder = 0
      Visible = True
    end
    object Ne_1_O: TDBNumberEditEh
      Left = 342
      Top = 21
      Width = 130
      Height = 21
      ControlLabel.Width = 19
      ControlLabel.Height = 13
      ControlLabel.Caption = #1054#1087#1090
      ControlLabel.Visible = True
      currency = True
      DecimalPlaces = 0
      DynProps = <>
      EditButtons = <>
      ReadOnly = True
      TabOrder = 1
      Visible = True
    end
    object Ne_1_I: TDBNumberEditEh
      Left = 494
      Top = 21
      Width = 130
      Height = 21
      ControlLabel.Width = 30
      ControlLabel.Height = 13
      ControlLabel.Caption = #1048#1090#1086#1075#1086
      ControlLabel.Visible = True
      currency = True
      DecimalPlaces = 0
      DynProps = <>
      EditButtons = <>
      ReadOnly = True
      TabOrder = 2
      Visible = True
    end
    object Ne_2_R: TDBNumberEditEh
      Left = 190
      Top = 61
      Width = 130
      Height = 21
      ControlLabel.Width = 43
      ControlLabel.Height = 13
      ControlLabel.Caption = #1056#1086#1079#1085#1080#1094#1072
      ControlLabel.Visible = True
      currency = True
      DecimalPlaces = 0
      DynProps = <>
      EditButtons = <>
      ReadOnly = True
      TabOrder = 3
      Visible = True
    end
    object Ne_2_O: TDBNumberEditEh
      Left = 342
      Top = 61
      Width = 130
      Height = 21
      ControlLabel.Width = 19
      ControlLabel.Height = 13
      ControlLabel.Caption = #1054#1087#1090
      ControlLabel.Visible = True
      currency = True
      DecimalPlaces = 0
      DynProps = <>
      EditButtons = <>
      ReadOnly = True
      TabOrder = 4
      Visible = True
    end
    object Ne_2_I: TDBNumberEditEh
      Left = 494
      Top = 61
      Width = 130
      Height = 21
      ControlLabel.Width = 30
      ControlLabel.Height = 13
      ControlLabel.Caption = #1048#1090#1086#1075#1086
      ControlLabel.Visible = True
      currency = True
      DecimalPlaces = 0
      DynProps = <>
      EditButtons = <>
      ReadOnly = True
      TabOrder = 5
      Visible = True
    end
    object Ne_3_R: TDBNumberEditEh
      Left = 190
      Top = 101
      Width = 130
      Height = 21
      ControlLabel.Width = 43
      ControlLabel.Height = 13
      ControlLabel.Caption = #1056#1086#1079#1085#1080#1094#1072
      ControlLabel.Visible = True
      currency = True
      DecimalPlaces = 0
      DynProps = <>
      EditButtons = <>
      ReadOnly = True
      TabOrder = 6
      Visible = True
    end
    object Ne_3_O: TDBNumberEditEh
      Left = 342
      Top = 101
      Width = 130
      Height = 21
      ControlLabel.Width = 19
      ControlLabel.Height = 13
      ControlLabel.Caption = #1054#1087#1090
      ControlLabel.Visible = True
      currency = True
      DecimalPlaces = 0
      DynProps = <>
      EditButtons = <>
      ReadOnly = True
      TabOrder = 7
      Visible = True
    end
    object Ne_3_I: TDBNumberEditEh
      Left = 494
      Top = 101
      Width = 130
      Height = 21
      ControlLabel.Width = 30
      ControlLabel.Height = 13
      ControlLabel.Caption = #1048#1090#1086#1075#1086
      ControlLabel.Visible = True
      currency = True
      DecimalPlaces = 0
      DynProps = <>
      EditButtons = <>
      ReadOnly = True
      TabOrder = 8
      Visible = True
    end
  end
  inherited Timer_AfterStart: TTimer
    Left = 120
    Top = 368
  end
end
