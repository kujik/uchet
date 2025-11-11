inherited FrmOWrepOrdersPrimeCost: TFrmOWrepOrdersPrimeCost
  Caption = 'FrmOWrepOrdersPrimeCost'
  ClientHeight = 218
  ClientWidth = 631
  ExplicitWidth = 643
  ExplicitHeight = 256
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 631
    Height = 202
    ExplicitWidth = 627
    ExplicitHeight = 201
    inherited pnlFrmClient: TPanel
      Width = 621
      Height = 144
      ExplicitWidth = 617
      ExplicitHeight = 143
      object lbl_1_Caption: TLabel
        Left = 0
        Top = 0
        Width = 621
        Height = 13
        Align = alTop
        Caption = 'lbl_1_Caption'
        ExplicitWidth = 65
      end
      object pnl_Main: TPanel
        Left = 0
        Top = 13
        Width = 621
        Height = 131
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        ExplicitWidth = 617
        ExplicitHeight = 130
        object lbl_1: TLabel
          Left = 16
          Top = 24
          Width = 50
          Height = 13
          Caption = #1055#1088#1086#1076#1072#1078#1072':'
        end
        object lbl_2: TLabel
          Left = 16
          Top = 64
          Width = 52
          Height = 13
          Caption = #1054#1090#1075#1088#1091#1079#1082#1072':'
        end
        object lbl_3: TLabel
          Left = 16
          Top = 104
          Width = 63
          Height = 13
          Caption = #1056#1077#1072#1083#1080#1079#1072#1094#1080#1103':'
        end
        object nedt_1_R: TDBNumberEditEh
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
        object nedt_1_O: TDBNumberEditEh
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
        object nedt_1_I: TDBNumberEditEh
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
        object nedt_2_R: TDBNumberEditEh
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
        object nedt_2_O: TDBNumberEditEh
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
        object nedt_2_I: TDBNumberEditEh
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
        object nedt_3_R: TDBNumberEditEh
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
        object nedt_3_O: TDBNumberEditEh
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
        object nedt_3_I: TDBNumberEditEh
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
    inherited pnlFrmBtns: TPanel
      Top = 149
      Width = 621
      Height = 52
      ExplicitTop = 148
      ExplicitWidth = 617
      ExplicitHeight = 52
      inherited bvlFrmBtnsTl: TBevel
        Width = 619
        ExplicitWidth = 623
      end
      inherited bvlFrmBtnsB: TBevel
        Top = 48
        Width = 619
        ExplicitTop = 48
        ExplicitWidth = 623
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 619
        Height = 44
        ExplicitWidth = 615
        ExplicitHeight = 44
        inherited pnlFrmBtnsMain: TPanel
          Left = 587
          Width = 32
          Height = 36
          ExplicitLeft = 583
          ExplicitWidth = 32
          ExplicitHeight = 36
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 382
          Height = 36
          ExplicitLeft = 378
          ExplicitHeight = 36
          inherited chbNoclose: TCheckBox
            Top = -51
            ExplicitTop = -51
          end
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 511
          Width = 76
          Height = 36
          ExplicitLeft = 507
          ExplicitWidth = 76
          ExplicitHeight = 36
        end
        inherited pnlFrmBtnsInfo: TPanel
          Height = 36
          ExplicitHeight = 36
        end
        inherited pnlFrmBtnsL: TPanel
          Width = 368
          Height = 36
          ExplicitWidth = 368
          ExplicitHeight = 36
          object cmb_DtB: TDBComboBoxEh
            Left = 57
            Top = 6
            Width = 130
            Height = 19
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
          object cmb_DtE: TDBComboBoxEh
            Left = 238
            Top = 6
            Width = 130
            Height = 19
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
        inherited pnlFrmBtnsC: TPanel
          Left = 409
          Width = 2
          Height = 36
          ExplicitLeft = 409
          ExplicitWidth = 2
          ExplicitHeight = 36
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 202
    Width = 631
    ExplicitTop = 201
    ExplicitWidth = 627
    inherited lblStatusBarR: TLabel
      Left = 558
      Height = 14
      ExplicitLeft = 558
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
