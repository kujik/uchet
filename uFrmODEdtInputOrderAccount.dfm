inherited FrmODEdtInputOrderAccount: TFrmODEdtInputOrderAccount
  Caption = 'FrmODEdtInputOrderAccount'
  ClientHeight = 155
  ClientWidth = 214
  ExplicitWidth = 226
  ExplicitHeight = 193
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 214
    Height = 139
    ExplicitWidth = 262
    ExplicitHeight = 80
    inherited pnlFrmClient: TPanel
      Width = 204
      Height = 90
      object dedt_Upd_Reg: TDBDateTimeEditEh
        Left = 72
        Top = 8
        Width = 124
        Height = 21
        ControlLabel.Width = 64
        ControlLabel.Height = 26
        ControlLabel.Caption = #1044#1072#1090#1072#13#10#1088#1077#1075#1080#1089#1090#1088#1072#1094#1080#1080
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        HighlightRequired = True
        Kind = dtkDateEh
        TabOrder = 0
        Visible = True
      end
      object dedt_Upd: TDBDateTimeEditEh
        Left = 72
        Top = 35
        Width = 124
        Height = 21
        ControlLabel.Width = 58
        ControlLabel.Height = 13
        ControlLabel.Caption = #1044#1072#1090#1072' '#1089#1095#1077#1090#1072
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        Kind = dtkDateEh
        TabOrder = 1
        Visible = True
      end
      object edt_Upd: TDBEditEh
        Left = 72
        Top = 62
        Width = 125
        Height = 21
        ControlLabel.Width = 45
        ControlLabel.Height = 13
        ControlLabel.Caption = #8470' '#1089#1095#1077#1090#1072
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 2
        Text = 'edt_Upd'
        Visible = True
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 95
      Width = 204
      ExplicitTop = 36
      ExplicitWidth = 252
      inherited bvlFrmBtnsTl: TBevel
        Width = 202
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 202
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 202
        ExplicitWidth = 250
        inherited pnlFrmBtnsMain: TPanel
          Left = 103
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = -125
          ExplicitLeft = -77
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 4
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 139
    Width = 214
    inherited lblStatusBarR: TLabel
      Left = 141
      Height = 14
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
