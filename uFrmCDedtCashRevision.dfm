inherited FrmCDedtCashRevision: TFrmCDedtCashRevision
  Caption = 'FrmCDedtCashRevision'
  ClientHeight = 183
  ClientWidth = 191
  ExplicitWidth = 207
  ExplicitHeight = 222
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 191
    Height = 167
    ExplicitWidth = 191
    ExplicitHeight = 167
    inherited pnlFrmClient: TPanel
      Width = 181
      Height = 118
      ExplicitWidth = 181
      ExplicitHeight = 118
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
      Top = 123
      Width = 181
      ExplicitTop = 123
      ExplicitWidth = 181
      inherited bvlFrmBtnsTl: TBevel
        Width = 179
        ExplicitWidth = 179
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 179
        ExplicitWidth = 179
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 179
        ExplicitWidth = 179
        inherited pnlFrmBtnsMain: TPanel
          Left = 80
          ExplicitLeft = 80
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = -148
          ExplicitLeft = -148
        end
        inherited pnlFrmBtnsR: TPanel
          Left = -19
          ExplicitLeft = -19
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 26
          ExplicitWidth = 26
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 167
    Width = 191
    ExplicitTop = 167
    ExplicitWidth = 191
    inherited lblStatusBarR: TLabel
      Left = 99
      Height = 13
      ExplicitLeft = 99
    end
    inherited lblStatusBarL: TLabel
      Height = 13
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 216
    Top = 352
  end
end
