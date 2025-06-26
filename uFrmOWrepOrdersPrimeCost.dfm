inherited FrmOWrepOrdersPrimeCost: TFrmOWrepOrdersPrimeCost
  Caption = 'FrmOWrepOrdersPrimeCost'
  ClientHeight = 219
  ClientWidth = 635
  ExplicitWidth = 647
  ExplicitHeight = 257
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 635
    Height = 203
    ExplicitWidth = 270
    ExplicitHeight = 82
    inherited PMDIClient: TPanel
      Width = 625
      Height = 145
      ExplicitWidth = 260
      ExplicitHeight = 33
      object Lb_1_Caption: TLabel
        Left = 0
        Top = 0
        Width = 625
        Height = 13
        Align = alTop
        Caption = 'Lb_1_Caption'
        ExplicitWidth = 66
      end
      object P_Main: TPanel
        Left = 0
        Top = 13
        Width = 625
        Height = 132
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        ExplicitLeft = -4
        ExplicitTop = 22
        ExplicitWidth = 631
        ExplicitHeight = 130
        object Lb_1: TLabel
          Left = 16
          Top = 24
          Width = 50
          Height = 13
          Caption = #1055#1088#1086#1076#1072#1078#1072':'
        end
        object Lb_2: TLabel
          Left = 16
          Top = 64
          Width = 52
          Height = 13
          Caption = #1054#1090#1075#1088#1091#1079#1082#1072':'
        end
        object Lb_3: TLabel
          Left = 16
          Top = 104
          Width = 63
          Height = 13
          Caption = #1056#1077#1072#1083#1080#1079#1072#1094#1080#1103':'
        end
        object Ne_1_R: TDBNumberEditEh
          Left = 190
          Top = 21
          Width = 130
          Height = 21
          ControlLabel.Width = 41
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
          ControlLabel.Width = 20
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
          ControlLabel.Width = 41
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
          ControlLabel.Width = 20
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
          ControlLabel.Width = 41
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
          ControlLabel.Width = 20
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
    end
    inherited PDlgPanel: TPanel
      Top = 150
      Width = 625
      Height = 52
      ExplicitTop = 240
      ExplicitWidth = 858
      ExplicitHeight = 52
      inherited BvDlg: TBevel
        Width = 623
      end
      inherited BvDlgBottom: TBevel
        Top = 48
        Width = 623
      end
      inherited PDlgMain: TPanel
        Width = 623
        Height = 44
        ExplicitWidth = 258
        inherited PDlgBtnForm: TPanel
          Left = 591
          Width = 32
          Height = 36
          ExplicitLeft = 824
          ExplicitWidth = 32
        end
        inherited PDlgChb: TPanel
          Left = 386
          Height = 36
          ExplicitLeft = -69
          inherited ChbDlgNoClose: TCheckBox
            Top = -51
          end
        end
        inherited PDlgBtnR: TPanel
          Left = 515
          Width = 76
          Height = 36
          ExplicitLeft = 1152
          ExplicitWidth = 76
          ExplicitHeight = 36
        end
        inherited PDlgInfo: TPanel
          Height = 36
        end
        inherited PDlgBtnL: TPanel
          Width = 368
          Height = 36
          ExplicitWidth = 368
          ExplicitHeight = 36
          object Cb_DtB: TDBComboBoxEh
            Left = 57
            Top = 6
            Width = 130
            Height = 21
            ControlLabel.Width = 43
            ControlLabel.Height = 26
            ControlLabel.Caption = #1053#1072#1095#1072#1083#1086#13#10#1087#1077#1088#1080#1086#1076#1072
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            LimitTextToListValues = True
            TabOrder = 0
            Visible = True
          end
          object Cb_DtE: TDBComboBoxEh
            Left = 238
            Top = 6
            Width = 130
            Height = 21
            ControlLabel.Width = 43
            ControlLabel.Height = 26
            ControlLabel.Caption = #1050#1086#1085#1077#1094#13#10#1087#1077#1088#1080#1086#1076#1072
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            LimitTextToListValues = True
            TabOrder = 1
            Visible = True
          end
        end
        inherited PDlgCenter: TPanel
          Left = 409
          Width = 2
          Height = 36
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 203
    Width = 635
    ExplicitTop = 82
    ExplicitWidth = 270
    inherited LbStatusBarRight: TLabel
      Left = 543
      Height = 14
    end
    inherited LbStatusBarLeft: TLabel
      Height = 14
    end
  end
end
