inherited FrmODedtOrdersFinancePlans: TFrmODedtOrdersFinancePlans
  Caption = 'FrmODedtOrdersFinancePlans'
  ClientHeight = 287
  ClientWidth = 632
  ExplicitWidth = 644
  ExplicitHeight = 325
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 632
    Height = 271
    ExplicitWidth = 632
    ExplicitHeight = 271
    inherited pnlFrmClient: TPanel
      Width = 622
      Height = 222
      ExplicitWidth = 618
      ExplicitHeight = 221
      object lbl11: TLabel
        Left = 96
        Top = 13
        Width = 94
        Height = 13
        Caption = #1055#1088#1086#1076#1072#1078#1072', '#1088#1086#1079#1085#1080#1094#1072
      end
      object lbl1: TLabel
        Left = 232
        Top = 13
        Width = 71
        Height = 13
        Caption = #1055#1088#1086#1076#1072#1078#1072', '#1086#1087#1090
      end
      object lbl2: TLabel
        Left = 368
        Top = 13
        Width = 96
        Height = 13
        Caption = #1054#1090#1075#1088#1091#1079#1082#1072', '#1088#1086#1079#1085#1080#1094#1072
      end
      object lbl3: TLabel
        Left = 504
        Top = 13
        Width = 73
        Height = 13
        Caption = #1054#1090#1075#1088#1091#1079#1082#1072', '#1086#1087#1090
      end
      object lbl4: TLabel
        Left = 96
        Top = 167
        Width = 121
        Height = 13
        Caption = #1055#1088#1086#1080#1079#1074#1086#1076#1089#1090#1074#1086', '#1080#1079#1076#1077#1083#1080#1103
      end
      object lbl5: TLabel
        Left = 368
        Top = 167
        Width = 177
        Height = 13
        Caption = #1055#1088#1086#1080#1079#1074#1086#1076#1089#1090#1074#1086', '#1076#1086#1087'. '#1082#1086#1084#1087#1083#1077#1082#1090#1072#1094#1080#1103
      end
      object nedt_Sum1RI: TDBNumberEditEh
        Left = 96
        Top = 32
        Width = 110
        Height = 21
        ControlLabel.Width = 43
        ControlLabel.Height = 13
        ControlLabel.Caption = #1048#1079#1076#1077#1083#1080#1103
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DecimalPlaces = 0
        DynProps = <>
        EditButtons = <>
        TabOrder = 0
        Visible = True
      end
      object nedt_Sum1RA: TDBNumberEditEh
        Left = 96
        Top = 59
        Width = 110
        Height = 21
        ControlLabel.Width = 86
        ControlLabel.Height = 26
        ControlLabel.Caption = #1044#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1072#1103#13#10#1082#1086#1084#1087#1083#1077#1082#1090#1072#1094#1080#1103
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DecimalPlaces = 0
        DynProps = <>
        EditButtons = <>
        TabOrder = 1
        Visible = True
      end
      object nedt_Sum1RD: TDBNumberEditEh
        Left = 96
        Top = 86
        Width = 110
        Height = 21
        ControlLabel.Width = 49
        ControlLabel.Height = 13
        ControlLabel.Caption = #1044#1086#1089#1090#1072#1074#1082#1072
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DecimalPlaces = 0
        DynProps = <>
        EditButtons = <>
        TabOrder = 2
        Visible = True
      end
      object nedt_Sum1RM: TDBNumberEditEh
        Left = 96
        Top = 113
        Width = 110
        Height = 21
        ControlLabel.Width = 40
        ControlLabel.Height = 13
        ControlLabel.Caption = #1052#1086#1085#1090#1072#1078
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DecimalPlaces = 0
        DynProps = <>
        EditButtons = <>
        TabOrder = 3
        Visible = True
      end
      object nedt_Sum1R_: TDBNumberEditEh
        Left = 96
        Top = 140
        Width = 110
        Height = 21
        ControlLabel.Width = 30
        ControlLabel.Height = 13
        ControlLabel.Caption = #1048#1090#1086#1075#1086
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        Color = clCream
        currency = True
        DecimalPlaces = 0
        DynProps = <>
        EditButtons = <>
        ReadOnly = True
        TabOrder = 4
        Visible = True
      end
      object nedt_Sum1OI: TDBNumberEditEh
        Left = 232
        Top = 32
        Width = 110
        Height = 21
        ControlLabel.Caption = #1048#1079#1076#1077#1083#1080#1103
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DecimalPlaces = 0
        DynProps = <>
        EditButtons = <>
        TabOrder = 5
        Visible = True
      end
      object nedt_Sum1OA: TDBNumberEditEh
        Left = 232
        Top = 59
        Width = 110
        Height = 21
        ControlLabel.Caption = #1044#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1072#1103#13#10#1082#1086#1084#1087#1083#1077#1082#1090#1072#1094#1080#1103
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DecimalPlaces = 0
        DynProps = <>
        EditButtons = <>
        TabOrder = 6
        Visible = True
      end
      object nedt_Sum1OD: TDBNumberEditEh
        Left = 232
        Top = 86
        Width = 110
        Height = 21
        ControlLabel.Caption = #1044#1086#1089#1090#1072#1074#1082#1072
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DecimalPlaces = 0
        DynProps = <>
        EditButtons = <>
        TabOrder = 7
        Visible = True
      end
      object nedt_Sum1OM: TDBNumberEditEh
        Left = 232
        Top = 113
        Width = 110
        Height = 21
        ControlLabel.Caption = #1052#1086#1085#1090#1072#1078
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DecimalPlaces = 0
        DynProps = <>
        EditButtons = <>
        TabOrder = 8
        Visible = True
      end
      object nedt_Sum1O_: TDBNumberEditEh
        Left = 232
        Top = 140
        Width = 110
        Height = 21
        ControlLabel.Caption = #1048#1090#1086#1075#1086
        ControlLabelLocation.Position = lpLeftCenterEh
        Color = clCream
        currency = True
        DecimalPlaces = 0
        DynProps = <>
        EditButtons = <>
        ReadOnly = True
        TabOrder = 9
        Visible = True
      end
      object nedt_Sum2RI: TDBNumberEditEh
        Left = 368
        Top = 32
        Width = 110
        Height = 21
        ControlLabel.Caption = #1048#1079#1076#1077#1083#1080#1103
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DecimalPlaces = 0
        DynProps = <>
        EditButtons = <>
        TabOrder = 10
        Visible = True
      end
      object nedt_Sum2RA: TDBNumberEditEh
        Left = 368
        Top = 59
        Width = 110
        Height = 21
        ControlLabel.Caption = #1044#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1072#1103#13#10#1082#1086#1084#1087#1083#1077#1082#1090#1072#1094#1080#1103
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DecimalPlaces = 0
        DynProps = <>
        EditButtons = <>
        TabOrder = 11
        Visible = True
      end
      object nedt_Sum2RD: TDBNumberEditEh
        Left = 368
        Top = 86
        Width = 110
        Height = 21
        ControlLabel.Caption = #1044#1086#1089#1090#1072#1074#1082#1072
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DecimalPlaces = 0
        DynProps = <>
        EditButtons = <>
        TabOrder = 12
        Visible = True
      end
      object nedt_Sum2RM: TDBNumberEditEh
        Left = 368
        Top = 113
        Width = 110
        Height = 21
        ControlLabel.Caption = #1052#1086#1085#1090#1072#1078
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DecimalPlaces = 0
        DynProps = <>
        EditButtons = <>
        TabOrder = 13
        Visible = True
      end
      object nedt_Sum2R_: TDBNumberEditEh
        Left = 368
        Top = 140
        Width = 110
        Height = 21
        ControlLabel.Caption = #1048#1090#1086#1075#1086
        ControlLabelLocation.Position = lpLeftCenterEh
        Color = clCream
        currency = True
        DecimalPlaces = 0
        DynProps = <>
        EditButtons = <>
        ReadOnly = True
        TabOrder = 14
        Visible = True
      end
      object nedt_Sum2OI: TDBNumberEditEh
        Left = 504
        Top = 32
        Width = 110
        Height = 21
        ControlLabel.Caption = #1048#1079#1076#1077#1083#1080#1103
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DecimalPlaces = 0
        DynProps = <>
        EditButtons = <>
        TabOrder = 15
        Visible = True
      end
      object nedt_Sum2OA: TDBNumberEditEh
        Left = 504
        Top = 59
        Width = 110
        Height = 21
        ControlLabel.Caption = #1044#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1072#1103#13#10#1082#1086#1084#1087#1083#1077#1082#1090#1072#1094#1080#1103
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DecimalPlaces = 0
        DynProps = <>
        EditButtons = <>
        TabOrder = 16
        Visible = True
      end
      object nedt_Sum2OD: TDBNumberEditEh
        Left = 504
        Top = 86
        Width = 110
        Height = 21
        ControlLabel.Caption = #1044#1086#1089#1090#1072#1074#1082#1072
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DecimalPlaces = 0
        DynProps = <>
        EditButtons = <>
        TabOrder = 17
        Visible = True
      end
      object nedt_Sum2OM: TDBNumberEditEh
        Left = 505
        Top = 113
        Width = 110
        Height = 21
        ControlLabel.Caption = #1052#1086#1085#1090#1072#1078
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DecimalPlaces = 0
        DynProps = <>
        EditButtons = <>
        TabOrder = 18
        Visible = True
      end
      object nedt_Sum2O_: TDBNumberEditEh
        Left = 504
        Top = 140
        Width = 110
        Height = 21
        ControlLabel.Caption = #1048#1090#1086#1075#1086
        ControlLabelLocation.Position = lpLeftCenterEh
        Color = clCream
        currency = True
        DecimalPlaces = 0
        DynProps = <>
        EditButtons = <>
        ReadOnly = True
        TabOrder = 19
        Visible = True
      end
      object nedt_Prc3i: TDBNumberEditEh
        Left = 232
        Top = 186
        Width = 41
        Height = 21
        ControlLabel.Width = 11
        ControlLabel.Height = 13
        ControlLabel.Caption = '%'
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = False
        DynProps = <>
        EditButtons = <>
        MaxValue = 100.000000000000000000
        TabOrder = 20
        Visible = True
      end
      object nedt_Sum3A: TDBNumberEditEh
        Left = 368
        Top = 186
        Width = 110
        Height = 21
        ControlLabel.Width = 31
        ControlLabel.Height = 13
        ControlLabel.Caption = #1057#1091#1084#1084#1072
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DecimalPlaces = 0
        DynProps = <>
        EditButtons = <>
        TabOrder = 21
        Visible = True
      end
      object nedt_Prc3A: TDBNumberEditEh
        Left = 504
        Top = 186
        Width = 41
        Height = 21
        ControlLabel.Width = 11
        ControlLabel.Height = 13
        ControlLabel.Caption = '%'
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = False
        DynProps = <>
        EditButtons = <>
        MaxValue = 100.000000000000000000
        TabOrder = 22
        Visible = True
      end
      object nedt_Sum3i: TDBNumberEditEh
        Left = 96
        Top = 186
        Width = 110
        Height = 21
        ControlLabel.Width = 31
        ControlLabel.Height = 13
        ControlLabel.Caption = #1057#1091#1084#1084#1072
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = True
        DecimalPlaces = 0
        DynProps = <>
        EditButtons = <>
        TabOrder = 23
        Visible = True
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 227
      Width = 622
      ExplicitTop = 226
      ExplicitWidth = 618
      inherited bvlFrmBtnsTl: TBevel
        Width = 620
        ExplicitWidth = 620
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 620
        ExplicitWidth = 620
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 620
        ExplicitWidth = 616
        inherited pnlFrmBtnsMain: TPanel
          Left = 521
          ExplicitLeft = 517
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 293
          ExplicitLeft = 289
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 422
          ExplicitLeft = 418
        end
        inherited pnlFrmBtnsL: TPanel
          Width = 175
          ExplicitWidth = 175
          object lbl_Caption: TLabel
            Left = 30
            Top = -2
            Width = 116
            Height = 23
            Anchors = [akRight]
            Caption = '2024, '#1071#1085#1074#1072#1088#1100
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -19
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
        end
        inherited pnlFrmBtnsC: TPanel
          Left = 216
          Width = 77
          ExplicitLeft = 216
          ExplicitWidth = 73
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 271
    Width = 632
    ExplicitTop = 270
    ExplicitWidth = 628
    inherited lblStatusBarR: TLabel
      Left = 559
      Height = 14
      ExplicitLeft = 559
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
