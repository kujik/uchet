inherited FrmODedtDevel: TFrmODedtDevel
  Caption = 'FrmODedtDevel'
  ClientHeight = 403
  ClientWidth = 829
  ExplicitWidth = 845
  ExplicitHeight = 442
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 829
    Height = 387
    ExplicitWidth = 829
    ExplicitHeight = 387
    inherited pnlFrmClient: TPanel
      Width = 823
      Height = 339
      ExplicitWidth = 819
      ExplicitHeight = 338
      object mem_Comm: TDBMemoEh
        Left = 84
        Top = 224
        Width = 651
        Height = 72
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
      end
      object nedt_Time: TDBNumberEditEh
        Left = 198
        Top = 197
        Width = 80
        Height = 21
        ControlLabel.Width = 26
        ControlLabel.Height = 13
        ControlLabel.Caption = #1063#1072#1089#1099
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
      object nedt_Cnt: TDBNumberEditEh
        Left = 84
        Top = 197
        Width = 80
        Height = 21
        ControlLabel.Width = 38
        ControlLabel.Height = 13
        ControlLabel.Caption = #1057#1076#1077#1083#1082#1072
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = False
        DynProps = <>
        EditButton.DefaultAction = True
        EditButtons = <>
        MaxValue = 500.000000000000000000
        TabOrder = 2
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
        ControlLabel.Caption = #1050#1086#1085#1089#1090#1088#1091#1082#1090#1086#1088
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 3
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
        TabOrder = 4
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
        TabOrder = 5
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
        TabOrder = 6
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
        TabOrder = 7
        Visible = True
      end
      object cmb_Name: TDBComboBoxEh
        Left = 84
        Top = 89
        Width = 647
        Height = 21
        ControlLabel.Width = 73
        ControlLabel.Height = 26
        ControlLabel.Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077#13#10#1080#1079#1076#1077#1083#1080#1103
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        Anchors = [akLeft, akTop, akRight]
        DynProps = <>
        EditButtons = <>
        TabOrder = 8
        Visible = True
      end
      object cmb_Project: TDBComboBoxEh
        Left = 84
        Top = 62
        Width = 647
        Height = 21
        ControlLabel.Width = 37
        ControlLabel.Height = 13
        ControlLabel.Caption = #1055#1088#1086#1077#1082#1090
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        Anchors = [akLeft, akTop, akRight]
        DynProps = <>
        EditButtons = <>
        TabOrder = 9
        Visible = True
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
        TabOrder = 10
        Visible = True
      end
      object cmb_Id_DevelType: TDBComboBoxEh
        Left = 84
        Top = 8
        Width = 195
        Height = 21
        ControlLabel.Width = 60
        ControlLabel.Height = 13
        ControlLabel.Caption = #1042#1080#1076' '#1088#1072#1073#1086#1090#1099
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 11
        Visible = True
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 343
      Width = 819
      ExplicitTop = 343
      ExplicitWidth = 819
      inherited bvlFrmBtnsTl: TBevel
        Width = 821
        ExplicitWidth = 825
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 821
        ExplicitWidth = 825
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 821
        ExplicitWidth = 817
        inherited pnlFrmBtnsMain: TPanel
          Left = 722
          ExplicitLeft = 718
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 494
          ExplicitLeft = 490
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 623
          ExplicitLeft = 619
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 354
          ExplicitWidth = 350
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 387
    Width = 829
    ExplicitTop = 387
    ExplicitWidth = 829
    inherited lblStatusBarR: TLabel
      Left = 760
      ExplicitLeft = 760
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 192
    Top = 360
  end
end
