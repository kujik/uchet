inherited FrmCDedtCashRevision: TFrmCDedtCashRevision
  Caption = 'FrmCDedtCashRevision'
  ClientHeight = 180
  ClientWidth = 179
  ExplicitWidth = 191
  ExplicitHeight = 218
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 179
    Height = 164
    ExplicitWidth = 175
    ExplicitHeight = 163
    inherited pnlFrmClient: TPanel
      Width = 169
      Height = 115
      ExplicitWidth = 165
      ExplicitHeight = 114
      object dedtDate: TDBDateTimeEditEh
        Left = 56
        Top = 8
        Width = 121
        Height = 21
        ControlLabel.Width = 26
        ControlLabel.Height = 13
        ControlLabel.Caption = #1044#1072#1090#1072
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        HighlightRequired = True
        Kind = dtkDateEh
        TabOrder = 0
        Visible = True
      end
      object nedtCash1: TDBNumberEditEh
        Left = 56
        Top = 35
        Width = 121
        Height = 21
        ControlLabel.Width = 35
        ControlLabel.Height = 13
        ControlLabel.Caption = #1050#1072#1089#1089#1072'1'
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButton.DefaultAction = True
        EditButton.Style = ebsAltDropDownEh
        EditButton.Visible = True
        EditButtons = <>
        HighlightRequired = True
        MaxValue = 9999999999.000000000000000000
        TabOrder = 1
        Visible = True
      end
      object nedtCash2: TDBNumberEditEh
        Left = 56
        Top = 62
        Width = 121
        Height = 21
        ControlLabel.Width = 35
        ControlLabel.Height = 13
        ControlLabel.Caption = #1050#1072#1089#1089#1072'2'
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButton.DefaultAction = True
        EditButton.Style = ebsAltDropDownEh
        EditButton.Visible = True
        EditButtons = <>
        HighlightRequired = True
        MaxValue = 9999999999.000000000000000000
        TabOrder = 2
        Visible = True
      end
      object nedtDeposit: TDBNumberEditEh
        Left = 56
        Top = 89
        Width = 121
        Height = 21
        ControlLabel.Width = 43
        ControlLabel.Height = 13
        ControlLabel.Caption = #1044#1077#1087#1086#1079#1080#1090
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButton.DefaultAction = True
        EditButton.Style = ebsAltDropDownEh
        EditButton.Visible = True
        EditButtons = <>
        HighlightRequired = True
        MaxValue = 9999999999.000000000000000000
        TabOrder = 3
        Visible = True
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 120
      Width = 169
      ExplicitTop = 119
      ExplicitWidth = 165
      inherited bvlFrmBtnsTl: TBevel
        Width = 167
        ExplicitWidth = 179
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 167
        ExplicitWidth = 179
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 167
        ExplicitWidth = 163
        inherited pnlFrmBtnsMain: TPanel
          Left = 68
          ExplicitLeft = 64
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = -160
          ExplicitLeft = -164
        end
        inherited pnlFrmBtnsR: TPanel
          Left = -31
          ExplicitLeft = -35
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 26
          ExplicitWidth = 26
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 164
    Width = 179
    ExplicitTop = 163
    ExplicitWidth = 175
    inherited lblStatusBarR: TLabel
      Left = 106
      Height = 14
      ExplicitLeft = 106
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 216
    Top = 352
  end
end
