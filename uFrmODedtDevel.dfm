inherited FrmODedtDevel: TFrmODedtDevel
  Caption = 'FrmODedtDevel'
  ClientHeight = 403
  ClientWidth = 829
  ExplicitWidth = 841
  ExplicitHeight = 441
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 829
    Height = 387
    ExplicitWidth = 825
    ExplicitHeight = 386
    inherited pnlFrmClient: TPanel
      Width = 819
      Height = 338
      ExplicitWidth = 815
      ExplicitHeight = 337
      object mem_Comm: TDBMemoEh
        Left = 84
        Top = 224
        Width = 647
        Height = 71
        ControlLabel.Width = 67
        ControlLabel.Height = 13
        ControlLabel.Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        Anchors = [akLeft, akTop, akRight, akBottom]
        AutoSize = False
        DynProps = <>
        EditButtons = <>
        MaxLength = 4000
        TabOrder = 0
        Visible = True
        WantReturns = True
        ExplicitWidth = 643
        ExplicitHeight = 70
      end
      object nedt_Hours: TDBNumberEditEh
        Left = 84
        Top = 197
        Width = 45
        Height = 21
        ControlLabel.Width = 47
        ControlLabel.Height = 13
        ControlLabel.Caption = #1042#1088#1077#1084#1103', '#1095'.'
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = False
        DynProps = <>
        EditButton.DefaultAction = True
        EditButtons = <>
        MaxValue = 500.000000000000000000
        TabOrder = 1
        Value = 12235123.050000000000000000
        Visible = True
      end
      object cmb_Id_Kns: TDBComboBoxEh
        Left = 84
        Top = 170
        Width = 195
        Height = 21
        ControlLabel.Width = 66
        ControlLabel.Height = 13
        ControlLabel.Caption = #1048#1089#1087#1086#1083#1085#1080#1090#1077#1083#1100
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 2
        Visible = True
      end
      object cmb_Id_Status: TDBComboBoxEh
        Left = 84
        Top = 143
        Width = 195
        Height = 21
        ControlLabel.Width = 36
        ControlLabel.Height = 13
        ControlLabel.Caption = #1057#1090#1072#1090#1091#1089
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        LimitTextToListValues = True
        TabOrder = 3
        Visible = True
      end
      object dedt_Dt_End: TDBDateTimeEditEh
        Left = 476
        Top = 116
        Width = 111
        Height = 21
        ControlLabel.Width = 67
        ControlLabel.Height = 26
        ControlLabel.Caption = #1060#1072#1082#1090#1080#1095#1077#1089#1082#1072#1103#13#10#1076#1072#1090#1072' '#1089#1076#1072#1095#1080
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        Kind = dtkDateEh
        TabOrder = 4
        Visible = True
      end
      object dedt_Dt_Plan: TDBDateTimeEditEh
        Left = 280
        Top = 116
        Width = 111
        Height = 21
        ControlLabel.Width = 58
        ControlLabel.Height = 26
        ControlLabel.Caption = #1055#1083#1072#1085#1086#1074#1072#1103#13#10#1076#1072#1090#1072' '#1089#1076#1072#1095#1080
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        Kind = dtkDateEh
        TabOrder = 5
        Visible = True
      end
      object dedt_Dt_Beg: TDBDateTimeEditEh
        Left = 84
        Top = 116
        Width = 111
        Height = 21
        ControlLabel.Width = 40
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
      object cmb_Name: TDBComboBoxEh
        Left = 84
        Top = 89
        Width = 643
        Height = 21
        ControlLabel.Width = 73
        ControlLabel.Height = 26
        ControlLabel.Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077#13#10#1080#1079#1076#1077#1083#1080#1103
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        Anchors = [akLeft, akTop, akRight]
        DynProps = <>
        EditButtons = <>
        TabOrder = 7
        Visible = True
        ExplicitWidth = 639
      end
      object cmb_Project: TDBComboBoxEh
        Left = 84
        Top = 62
        Width = 643
        Height = 21
        ControlLabel.Width = 37
        ControlLabel.Height = 13
        ControlLabel.Caption = #1055#1088#1086#1077#1082#1090
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        Anchors = [akLeft, akTop, akRight]
        DynProps = <>
        EditButtons = <>
        TabOrder = 8
        Visible = True
        ExplicitWidth = 639
      end
      object cmb_Slash: TDBComboBoxEh
        Left = 84
        Top = 35
        Width = 195
        Height = 21
        ControlLabel.Width = 58
        ControlLabel.Height = 13
        ControlLabel.Caption = #8470' '#1080#1079#1076#1077#1083#1080#1103
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 9
        Visible = True
      end
      object cmb_Id_DevelType: TDBComboBoxEh
        Left = 84
        Top = 8
        Width = 643
        Height = 21
        ControlLabel.Width = 60
        ControlLabel.Height = 13
        ControlLabel.Caption = #1042#1080#1076' '#1088#1072#1073#1086#1090#1099
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 10
        Visible = True
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 343
      Width = 819
      ExplicitTop = 342
      ExplicitWidth = 815
      inherited bvlFrmBtnsTl: TBevel
        Width = 817
        ExplicitWidth = 825
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 817
        ExplicitWidth = 825
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 817
        ExplicitWidth = 813
        inherited pnlFrmBtnsMain: TPanel
          Left = 718
          ExplicitLeft = 714
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 490
          ExplicitLeft = 486
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 619
          ExplicitLeft = 615
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 350
          ExplicitWidth = 346
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 387
    Width = 829
    ExplicitTop = 386
    ExplicitWidth = 825
    inherited lblStatusBarR: TLabel
      Left = 756
      ExplicitLeft = 756
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 192
    Top = 360
  end
end
