inherited FrmODedtOrStdItems: TFrmODedtOrStdItems
  Caption = 'FrmODedtOrStdItems'
  ClientHeight = 254
  ClientWidth = 835
  ExplicitWidth = 851
  ExplicitHeight = 293
  PixelsPerInch = 96
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 835
    Height = 238
    inherited PMDIClient: TPanel
      Width = 825
      Height = 189
      object E_Name: TDBEditEh
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
        Text = 'E_Name'
        Visible = True
      end
      object Chb_R0: TDBCheckBoxEh
        Left = 97
        Top = 62
        Width = 95
        Height = 17
        Caption = #1041#1077#1079' '#1084#1072#1088#1096#1088#1091#1090#1072
        DynProps = <>
        TabOrder = 1
      end
      object Chb_Wo_Estimate: TDBCheckBoxEh
        Left = 206
        Top = 62
        Width = 82
        Height = 17
        Caption = #1041#1077#1079' '#1089#1084#1077#1090#1099
        DynProps = <>
        TabOrder = 2
      end
      object Ne_Price: TDBNumberEditEh
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
      object Ne_Price_PP: TDBNumberEditEh
        Left = 281
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
      object Chb_by_sgp: TDBCheckBoxEh
        Left = 98
        Top = 112
        Width = 96
        Height = 17
        Caption = #1059#1095#1077#1090' '#1087#1086' '#1057#1043#1055
        DynProps = <>
        TabOrder = 5
      end
    end
    inherited PDlgPanel: TPanel
      Top = 194
      Width = 825
      inherited BvDlg: TBevel
        Width = 823
      end
      inherited BvDlgBottom: TBevel
        Width = 823
      end
      inherited PDlgMain: TPanel
        Width = 823
        inherited PDlgBtnForm: TPanel
          Left = 724
        end
        inherited PDlgChb: TPanel
          Left = 496
        end
        inherited PDlgBtnR: TPanel
          Left = 625
        end
        inherited PDlgCenter: TPanel
          Width = 356
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 238
    Width = 835
    inherited LbStatusBarRight: TLabel
      Left = 743
      Height = 14
    end
    inherited LbStatusBarLeft: TLabel
      Height = 14
    end
  end
end
