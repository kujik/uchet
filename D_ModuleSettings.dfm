object Dlg_ModuleSettings: TDlg_ModuleSettings
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1084#1086#1076#1091#1083#1077#1081
  ClientHeight = 419
  ClientWidth = 890
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  TextHeight = 13
  object pnl1: TPanel
    Left = 0
    Top = 384
    Width = 890
    Height = 35
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      890
      35)
    object lbl_Warning: TLabel
      Left = 4
      Top = 12
      Width = 499
      Height = 13
      Caption = 
        #1042#1085#1080#1084#1072#1085#1080#1077'! '#1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1087#1088#1080#1084#1077#1085#1103#1090#1089#1103' '#1091' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1077#1081', '#1090#1086#1083#1100#1082#1086' '#1082#1086#1075#1076#1072' '#1086#1085#1080 +
        ' '#1087#1077#1088#1077#1079#1072#1087#1091#1089#1090#1103#1090' '#1087#1088#1080#1083#1086#1078#1077#1085#1080#1077'.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Bt_Ok: TBitBtn
      Left = 722
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Bt_Ok'
      Default = True
      TabOrder = 0
      OnClick = Bt_OkClick
    end
    object Bt_Cancel: TBitBtn
      Left = 803
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Bt_Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object pgc_1: TPageControl
    Left = 0
    Top = 0
    Width = 890
    Height = 384
    ActivePage = ts_Workers
    Align = alClient
    TabOrder = 1
    object ts_SN: TTabSheet
      Caption = #1055#1083#1072#1090#1077#1078#1085#1099#1081' '#1082#1072#1083#1077#1085#1076#1072#1088#1100
      object nedt_Sum_AutoAgreed: TDBNumberEditEh
        Left = 3
        Top = 22
        Width = 121
        Height = 21
        ControlLabel.Width = 392
        ControlLabel.Height = 13
        ControlLabel.Caption = 
          #1057#1091#1084#1084#1072' '#1089#1095#1077#1090#1072', '#1087#1088#1080' '#1087#1088#1080#1074#1099#1096#1077#1085#1080#1080' '#1082#1086#1090#1086#1088#1086#1081' '#1090#1088#1077#1073#1091#1077#1090#1089#1103' '#1089#1086#1075#1083#1072#1089#1086#1074#1072#1085#1080#1077' '#1076#1080#1088#1077#1082 +
          #1090#1086#1088#1086#1084
        ControlLabel.Visible = True
        DynProps = <>
        EditButton.Visible = True
        EditButtons = <>
        MaxValue = 999999999.000000000000000000
        TabOrder = 0
        Visible = True
      end
      object nedt_Sum_Need_Req: TDBNumberEditEh
        Left = 3
        Top = 61
        Width = 121
        Height = 21
        ControlLabel.Width = 442
        ControlLabel.Height = 13
        ControlLabel.Caption = 
          #1057#1091#1084#1084#1072' '#1089#1095#1077#1090#1072', '#1087#1088#1080' '#1087#1088#1080#1074#1099#1096#1077#1085#1080#1080' '#1082#1086#1090#1086#1088#1086#1081' '#1090#1088#1077#1073#1091#1077#1090#1089#1103' '#1087#1088#1080#1082#1088#1077#1087#1083#1077#1085#1080#1077' '#1079#1072#1103#1074#1082 +
          #1080' '#1085#1072' '#1089#1085#1072#1073#1078#1077#1085#1080#1077
        ControlLabel.Visible = True
        DynProps = <>
        EditButton.Visible = True
        EditButtons = <>
        MaxValue = 999999999.000000000000000000
        TabOrder = 1
        Visible = True
      end
      object nedt_Transport_MaxIdle: TDBNumberEditEh
        Left = 3
        Top = 100
        Width = 121
        Height = 21
        ControlLabel.Width = 319
        ControlLabel.Height = 13
        ControlLabel.Caption = #1044#1083#1103' '#1090#1088#1072#1085#1089#1087#1086#1088#1090#1085#1099#1093' '#1089#1095#1077#1090#1086#1074', '#1085#1077#1086#1087#1083#1072#1095#1080#1074#1072#1077#1084#1086#1077' '#1074#1088#1077#1084#1103' '#1087#1088#1086#1089#1090#1086#1103', '#1095'.'
        ControlLabel.Visible = True
        DynProps = <>
        EditButton.Visible = True
        EditButtons = <>
        MaxValue = 99.000000000000000000
        TabOrder = 2
        Visible = True
      end
    end
    object ts_Workers: TTabSheet
      Caption = #1056#1072#1073#1086#1090#1085#1080#1082#1080
      ImageIndex = 1
      object nedt_W_Time_AutoAggreed: TDBNumberEditEh
        Left = 9
        Top = 25
        Width = 121
        Height = 21
        ControlLabel.Width = 653
        ControlLabel.Height = 13
        ControlLabel.Caption = 
          #1052#1072#1082#1089#1080#1084#1072#1083#1100#1085#1086' '#1074#1088#1077#1084#1103' '#1088#1072#1093#1086#1078#1076#1077#1085#1080#1103' '#1076#1072#1085#1085#1099#1093' '#1087#1086' Parsec '#1080' '#1086#1090' '#1088#1091#1082#1086#1074#1086#1076#1080#1090#1077#1083#1103' ' +
          #1074' '#1058#1059#1056#1042', '#1087#1088#1080' '#1082#1086#1090#1086#1088#1086#1084' '#1085#1077' '#1090#1088#1077#1073#1091#1077#1090#1089#1103' '#1089#1086#1075#1083#1072#1089#1086#1074#1072#1085#1080#1077', '#1074' '#1095#1072#1089#1072#1093
        ControlLabel.Visible = True
        DynProps = <>
        EditButton.Visible = True
        EditButtons = <>
        MaxValue = 12.000000000000000000
        TabOrder = 0
        Visible = True
      end
      object nedt_W_Time_Dinne_1: TDBNumberEditEh
        Left = 9
        Top = 64
        Width = 121
        Height = 21
        ControlLabel.Width = 169
        ControlLabel.Height = 13
        ControlLabel.Caption = #1042#1088#1077#1084#1103' '#1086#1073#1077#1076#1072', '#1076#1083#1103' '#1086#1092#1080#1089#1072', '#1074' '#1095#1072#1089#1072#1093
        ControlLabel.Visible = True
        DynProps = <>
        EditButton.Visible = True
        EditButtons = <>
        MaxValue = 12.000000000000000000
        TabOrder = 1
        Visible = True
      end
      object nedt_W_Time_Dinner_2: TDBNumberEditEh
        Left = 9
        Top = 100
        Width = 121
        Height = 21
        ControlLabel.Width = 162
        ControlLabel.Height = 13
        ControlLabel.Caption = #1042#1088#1077#1084#1103' '#1086#1073#1077#1076#1072', '#1076#1083#1103' '#1094#1077#1093#1072', '#1074' '#1095#1072#1089#1072#1093
        ControlLabel.Visible = True
        DynProps = <>
        EditButton.Visible = True
        EditButtons = <>
        MaxValue = 12.000000000000000000
        TabOrder = 2
        Visible = True
      end
      object nedt_W_Time_Beg_Diff_2: TDBNumberEditEh
        Left = 9
        Top = 172
        Width = 121
        Height = 21
        ControlLabel.Width = 849
        ControlLabel.Height = 13
        ControlLabel.Caption = 
          #1056#1072#1079#1085#1080#1094#1072' '#1084#1077#1078#1076#1091' '#1087#1088#1080#1093#1086#1076#1086#1084' '#1088#1072#1073#1086#1090#1085#1080#1082#1080' '#1080' '#1085#1072#1095#1072#1083#1086#1084' '#1088#1072#1073#1086#1095#1077#1075#1086' '#1076#1085#1103', '#1087#1088#1080' '#1087#1088#1077 +
          #1074#1099#1096#1077#1085#1080#1080' '#1082#1086#1090#1086#1088#1086#1075#1086' '#1086#1090#1088#1072#1073#1086#1090#1072#1085#1085#1086#1077' '#1074#1088#1077#1084#1103' '#1089#1095#1080#1090#1072#1077#1090#1089#1103' '#1089' '#1084#1086#1084#1077#1085#1090#1072' '#1087#1088#1080#1093#1086#1076#1072',' +
          ' '#1074' '#1095#1072#1089#1072#1093' '#1080' '#1076#1077#1089#1090#1103#1090#1099#1093' '#1095#1072#1089#1072
        ControlLabel.Visible = True
        DynProps = <>
        EditButton.Visible = True
        EditButtons = <>
        MaxValue = 12.000000000000000000
        TabOrder = 3
        Visible = True
      end
      object dedt_W_Time_Beg_2: TDBDateTimeEditEh
        Left = 9
        Top = 135
        Width = 119
        Height = 21
        ControlLabel.Width = 225
        ControlLabel.Height = 13
        ControlLabel.Caption = #1042#1088#1077#1084#1103' '#1085#1072#1095#1072#1083#1072' '#1088#1072#1073#1086#1095#1077#1075#1086' '#1076#1085#1103' '#1076#1083#1103' '#1094#1077#1093#1072', '#1095#1095'.'#1084#1084
        ControlLabel.Visible = True
        DynProps = <>
        EditButtons = <>
        Kind = dtkTimeEh
        TabOrder = 4
        Visible = True
      end
    end
  end
end
