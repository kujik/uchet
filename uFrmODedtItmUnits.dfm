inherited FrmODedtItmUnits: TFrmODedtItmUnits
  Caption = 'FrmODedtItmUnits'
  ClientHeight = 184
  ClientWidth = 289
  ExplicitWidth = 301
  ExplicitHeight = 222
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 289
    Height = 168
    ExplicitWidth = 848
    ExplicitHeight = 400
    inherited pnlFrmClient: TPanel
      Width = 279
      Height = 119
      ExplicitWidth = 838
      ExplicitHeight = 351
      object cmb_Id_MeasureGroup: TDBComboBoxEh
        Left = 84
        Top = 8
        Width = 195
        Height = 21
        ControlLabel.Width = 36
        ControlLabel.Height = 13
        ControlLabel.Caption = #1043#1088#1091#1087#1087#1072
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 0
        Visible = True
      end
      object edt_Name_Unit: TDBEditEh
        Left = 85
        Top = 35
        Width = 195
        Height = 21
        ControlLabel.Width = 73
        ControlLabel.Height = 13
        ControlLabel.Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        MaxLength = 400
        TabOrder = 1
        Text = 'edt_Name_Unit'
        Visible = True
      end
      object nedt_Full_Name: TDBEditEh
        Left = 84
        Top = 62
        Width = 195
        Height = 21
        ControlLabel.Width = 72
        ControlLabel.Height = 26
        ControlLabel.Caption = #1055#1086#1083#1085#1086#1077#13#10#1085#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        MaxLength = 400
        TabOrder = 2
        Text = 'edt_name'
        Visible = True
      end
      object nedt_Pression: TDBNumberEditEh
        Left = 84
        Top = 89
        Width = 104
        Height = 21
        ControlLabel.Width = 47
        ControlLabel.Height = 13
        ControlLabel.Caption = #1058#1086#1095#1085#1086#1089#1090#1100
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        currency = False
        DecimalPlaces = 0
        DynProps = <>
        EditButton.Visible = True
        EditButtons = <>
        MaxValue = 999999999.000000000000000000
        TabOrder = 3
        Visible = True
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 124
      Width = 279
      ExplicitTop = 356
      ExplicitWidth = 838
      inherited bvlFrmBtnsTl: TBevel
        Width = 277
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 277
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 277
        ExplicitWidth = 836
        inherited pnlFrmBtnsMain: TPanel
          Left = 178
          ExplicitLeft = 737
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = -50
          ExplicitLeft = 509
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 79
          ExplicitLeft = 638
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 39
          ExplicitWidth = 369
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 168
    Width = 289
    ExplicitTop = 400
    ExplicitWidth = 848
    inherited lblStatusBarR: TLabel
      Left = 197
      Height = 14
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Top = 136
  end
end
