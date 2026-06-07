inherited FrmODedtOrStdItem: TFrmODedtOrStdItem
  Caption = 'FrmODedtOrStdItem'
  ClientHeight = 348
  ClientWidth = 837
  ExplicitWidth = 849
  ExplicitHeight = 386
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 837
    Height = 332
    ExplicitWidth = 776
    ExplicitHeight = 331
    inherited pnlFrmClient: TPanel
      Width = 827
      Height = 283
      ExplicitWidth = 766
      ExplicitHeight = 282
      object nedt_Price: TDBNumberEditEh
        Left = 85
        Top = 101
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
        TabOrder = 0
        Visible = True
      end
      object nedt_Price_PP: TDBNumberEditEh
        Left = 282
        Top = 101
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
        TabOrder = 1
        Visible = True
      end
      object chb_by_sgp: TDBCheckBoxEh
        Left = 86
        Top = 128
        Width = 96
        Height = 17
        Caption = #1059#1095#1077#1090' '#1087#1086' '#1057#1043#1055
        DynProps = <>
        TabOrder = 2
      end
      object chb_R0: TDBCheckBoxEh
        Left = 85
        Top = 78
        Width = 95
        Height = 17
        Caption = #1041#1077#1079' '#1084#1072#1088#1096#1088#1091#1090#1072
        DynProps = <>
        TabOrder = 3
      end
      object chb_Wo_Estimate: TDBCheckBoxEh
        Left = 194
        Top = 78
        Width = 82
        Height = 17
        Caption = #1041#1077#1079' '#1089#1084#1077#1090#1099
        DynProps = <>
        TabOrder = 4
      end
      object edt_name: TDBEditEh
        Left = 82
        Top = 23
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
        TabOrder = 5
        Text = 'edt_name'
        Visible = True
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 288
      Width = 827
      ExplicitTop = 287
      ExplicitWidth = 766
      inherited bvlFrmBtnsTl: TBevel
        Width = 825
        ExplicitWidth = 768
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 825
        ExplicitWidth = 768
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 825
        ExplicitWidth = 764
        inherited pnlFrmBtnsMain: TPanel
          Left = 726
          ExplicitLeft = 665
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 498
          ExplicitLeft = 437
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 627
          ExplicitLeft = 566
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 358
          ExplicitWidth = 297
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 332
    Width = 837
    ExplicitTop = 331
    ExplicitWidth = 776
    inherited lblStatusBarR: TLabel
      Left = 764
      Height = 14
      ExplicitLeft = 707
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 168
    Top = 256
  end
end
