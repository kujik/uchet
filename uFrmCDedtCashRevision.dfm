inherited FrmCDedtCashRevision: TFrmCDedtCashRevision
  Caption = 'FrmCDedtCashRevision'
  ClientHeight = 181
  ClientWidth = 183
  ExplicitWidth = 199
  ExplicitHeight = 220
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 183
    Height = 165
    ExplicitWidth = 183
    ExplicitHeight = 165
    inherited pnlFrmClient: TPanel
      Width = 177
      Height = 117
      ExplicitWidth = 173
      ExplicitHeight = 116
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
      Top = 122
      Width = 177
      ExplicitTop = 121
      ExplicitWidth = 173
      inherited bvlFrmBtnsTl: TBevel
        Width = 175
        ExplicitWidth = 179
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 175
        ExplicitWidth = 179
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 175
        ExplicitWidth = 171
        inherited pnlFrmBtnsMain: TPanel
          Left = 76
          ExplicitLeft = 72
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = -152
          ExplicitLeft = -156
        end
        inherited pnlFrmBtnsR: TPanel
          Left = -23
          ExplicitLeft = -27
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 26
          ExplicitWidth = 26
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 165
    Width = 183
    ExplicitTop = 165
    ExplicitWidth = 183
    inherited lblStatusBarR: TLabel
      Left = 114
      ExplicitLeft = 114
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 216
    Top = 352
  end
end
