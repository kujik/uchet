inherited FrmODedtOrStdItems: TFrmODedtOrStdItems
  Caption = 'FrmODedtOrStdItems'
  ClientHeight = 254
  ClientWidth = 835
  ExplicitWidth = 847
  ExplicitHeight = 292
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 835
    Height = 238
    ExplicitWidth = 831
    ExplicitHeight = 237
    inherited pnlFrmClient: TPanel
      Width = 825
      Height = 189
      ExplicitWidth = 821
      ExplicitHeight = 188
      object edt_name: TDBEditEh
        Left = 97
        Top = 7
        Width = 724
        Height = 21
        ControlLabel.Width = 73
        ControlLabel.Height = 13
        ControlLabel.Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        MaxLength = 400
        TabOrder = 0
        Text = 'edt_name'
        Visible = True
      end
      object chb_R0: TDBCheckBoxEh
        Left = 97
        Top = 62
        Width = 95
        Height = 17
        Caption = #1041#1077#1079' '#1084#1072#1088#1096#1088#1091#1090#1072
        DynProps = <>
        TabOrder = 1
      end
      object chb_Wo_Estimate: TDBCheckBoxEh
        Left = 206
        Top = 62
        Width = 82
        Height = 17
        Caption = #1041#1077#1079' '#1089#1084#1077#1090#1099
        DynProps = <>
        TabOrder = 2
      end
      object nedt_Price: TDBNumberEditEh
        Left = 97
        Top = 85
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
        TabOrder = 3
        Visible = True
      end
      object nedt_Price_PP: TDBNumberEditEh
        Left = 294
        Top = 85
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
        TabOrder = 4
        Visible = True
      end
      object chb_by_sgp: TDBCheckBoxEh
        Left = 98
        Top = 112
        Width = 96
        Height = 17
        Caption = #1059#1095#1077#1090' '#1087#1086' '#1057#1043#1055
        DynProps = <>
        TabOrder = 5
      end
      object cmb_type_of_semiproduct: TDBComboBoxEh
        Left = 97
        Top = 135
        Width = 121
        Height = 21
        ControlLabel.Width = 80
        ControlLabel.Height = 26
        ControlLabel.Caption = #1058#1080#1087#13#10#1087#1086#1083#1091#1092#1072#1073#1088#1080#1082#1072#1090#1072
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftBottomEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 6
        Text = 'cmb_type_of_semiproduct'
        Visible = False
      end
      object cmb_id_or_format_estimates: TDBComboBoxEh
        Left = 98
        Top = 163
        Width = 300
        Height = 21
        ControlLabel.Width = 81
        ControlLabel.Height = 13
        ControlLabel.Caption = #1043#1088#1091#1087#1087#1072' '#1080#1079#1076#1077#1083#1080#1081
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftBottomEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 7
        Text = 'DBComboBoxEh1'
        Visible = True
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 194
      Width = 825
      ExplicitTop = 193
      ExplicitWidth = 821
      inherited bvlFrmBtnsTl: TBevel
        Width = 823
        ExplicitWidth = 823
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 823
        ExplicitWidth = 823
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 823
        ExplicitWidth = 819
        inherited pnlFrmBtnsMain: TPanel
          Left = 724
          ExplicitLeft = 720
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 496
          ExplicitLeft = 492
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 625
          ExplicitLeft = 621
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 356
          ExplicitWidth = 352
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 238
    Width = 835
    ExplicitTop = 237
    ExplicitWidth = 831
    inherited lblStatusBarR: TLabel
      Left = 743
      Height = 14
      ExplicitLeft = 743
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 24
    Top = 56
  end
end
