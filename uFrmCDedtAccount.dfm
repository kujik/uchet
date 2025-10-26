inherited FrmCDedtAccount: TFrmCDedtAccount
  Caption = 'FrmCDedtAccount'
  ExplicitWidth = 864
  ExplicitHeight = 455
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    inherited pnlFrmClient: TPanel
      ExplicitWidth = 838
      ExplicitHeight = 351
      object pnlGeneral: TPanel
        Left = 0
        Top = 112
        Width = 842
        Height = 201
        Align = alTop
        Caption = 'pnlGeneral'
        TabOrder = 0
        ExplicitWidth = 838
        object pnlGeneralM: TPanel
          Left = 1
          Top = 56
          Width = 840
          Height = 144
          Align = alBottom
          Caption = 'pnlGeneralM'
          TabOrder = 0
          ExplicitWidth = 836
          DesignSize = (
            840
            144)
          object cmb_Cash: TDBComboBoxEh
            Left = 104
            Top = 25
            Width = 121
            Height = 21
            ControlLabel.Width = 73
            ControlLabel.Height = 13
            ControlLabel.Caption = #1060#1086#1088#1084#1072' '#1086#1087#1083#1072#1090#1099
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            Items.Strings = (
              #1041#1077#1079#1085#1072#1083#1080#1095#1085#1099#1081' '#1088#1072#1089#1095#1105#1090
              #1053#1072#1083#1080#1095#1085#1099#1077)
            KeyItems.Strings = (
              '1'
              '2')
            TabOrder = 0
            Visible = True
          end
          object edt_Account: TDBEditEh
            Left = 270
            Top = 25
            Width = 223
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            ControlLabel.Width = 45
            ControlLabel.Height = 13
            ControlLabel.Caption = #8470' '#1089#1095#1077#1090#1072
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 1
            Text = 'edt_Account'
            Visible = True
            ExplicitWidth = 219
          end
          object cmb_Supplier: TDBComboBoxEh
            Left = 104
            Top = 52
            Width = 350
            Height = 21
            ControlLabel.Width = 60
            ControlLabel.Height = 13
            ControlLabel.Caption = #1050#1086#1085#1090#1088#1072#1075#1077#1085#1090
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 2
            Text = 'cmb_Cash'
            Visible = True
          end
          object Dt_Account: TDBDateTimeEditEh
            Left = 529
            Top = 25
            Width = 121
            Height = 21
            ControlLabel.Width = 26
            ControlLabel.Height = 13
            ControlLabel.Caption = #1044#1072#1090#1072
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            Anchors = [akRight]
            DynProps = <>
            EditButtons = <>
            Kind = dtkDateEh
            TabOrder = 3
            Visible = True
            ExplicitLeft = 525
          end
          object cmb_Org: TDBComboBoxEh
            Left = 579
            Top = 52
            Width = 71
            Height = 21
            ControlLabel.Width = 64
            ControlLabel.Height = 13
            ControlLabel.Caption = #1055#1083#1072#1090#1077#1083#1100#1097#1080#1082
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            Anchors = [akLeft, akTop, akRight]
            DynProps = <>
            EditButtons = <>
            TabOrder = 4
            Text = 'cmb_Cash'
            Visible = True
            ExplicitWidth = 67
          end
          object cmb_User: TDBComboBoxEh
            Left = 579
            Top = 79
            Width = 71
            Height = 21
            ControlLabel.Width = 53
            ControlLabel.Height = 13
            ControlLabel.Caption = #1052#1077#1085#1077#1076#1078#1077#1088
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            Anchors = [akLeft, akRight]
            DynProps = <>
            EditButtons = <>
            ReadOnly = True
            TabOrder = 5
            Text = 'cmb_Cash'
            Visible = True
            ExplicitWidth = 67
          end
          object cmb_ExpenseItem: TDBComboBoxEh
            Left = 104
            Top = 78
            Width = 350
            Height = 21
            ControlLabel.Width = 88
            ControlLabel.Height = 13
            ControlLabel.Caption = #1057#1090#1072#1090#1100#1103' '#1088#1072#1089#1093#1086#1076#1086#1074
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 6
            Text = 'cmb_Cash'
            Visible = True
          end
          object nedt_Sum: TDBNumberEditEh
            Left = 104
            Top = 105
            Width = 121
            Height = 21
            ControlLabel.Width = 31
            ControlLabel.Height = 13
            ControlLabel.Caption = #1057#1091#1084#1084#1072
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButton.Visible = True
            EditButtons = <>
            MaxValue = 999999999.000000000000000000
            MinValue = 1.000000000000000000
            TabOrder = 7
            Visible = True
          end
          object nedt_SumWoNds: TDBNumberEditEh
            Left = 480
            Top = 105
            Width = 121
            Height = 21
            ControlLabel.Width = 76
            ControlLabel.Height = 13
            ControlLabel.Caption = #1057#1091#1084#1084#1072' '#1073#1077#1079' '#1053#1044#1057
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 8
            Visible = True
          end
        end
        inline frmpcGeneral: TFrMyPanelCaption
          Left = 1
          Top = 1
          Width = 840
          Height = 18
          Align = alTop
          TabOrder = 1
          ExplicitLeft = 1
          ExplicitTop = 1
          inherited bvl1: TBevel
            Width = 840
          end
        end
      end
      object pnlPayments: TPanel
        Left = 0
        Top = 0
        Width = 842
        Height = 112
        Align = alTop
        Caption = 'pnlPayments'
        TabOrder = 1
        ExplicitWidth = 838
      end
    end
    inherited pnlFrmBtns: TPanel
      ExplicitTop = 356
      ExplicitWidth = 838
      inherited pnlFrmBtnsContainer: TPanel
        ExplicitWidth = 836
        inherited pnlFrmBtnsMain: TPanel
          ExplicitLeft = 737
        end
        inherited pnlFrmBtnsChb: TPanel
          ExplicitLeft = 509
        end
        inherited pnlFrmBtnsR: TPanel
          ExplicitLeft = 638
        end
        inherited pnlFrmBtnsC: TPanel
          ExplicitWidth = 369
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    ExplicitTop = 400
    ExplicitWidth = 848
    inherited lblStatusBarR: TLabel
      Left = 779
      Height = 14
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 232
    Top = 832
  end
end
