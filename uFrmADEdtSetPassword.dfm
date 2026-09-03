inherited FrmADEdtSetPassword: TFrmADEdtSetPassword
  Caption = 'FrmADEdtSetPassword'
  ClientHeight = 155
  ClientWidth = 250
  ExplicitWidth = 262
  ExplicitHeight = 193
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 250
    Height = 139
    ExplicitWidth = 246
    ExplicitHeight = 138
    inherited pnlFrmClient: TPanel
      Width = 240
      Height = 90
      ExplicitWidth = 236
      ExplicitHeight = 89
      object edt_Pwd1: TDBEditEh
        Left = 85
        Top = 8
        Width = 137
        Height = 21
        ControlLabel.Width = 37
        ControlLabel.Height = 13
        ControlLabel.Caption = #1055#1072#1088#1086#1083#1100
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        MaxLength = 20
        PasswordChar = '*'
        TabOrder = 0
        Visible = True
      end
      object edt_Pwd2: TDBEditEh
        Left = 85
        Top = 35
        Width = 137
        Height = 21
        ControlLabel.Width = 76
        ControlLabel.Height = 13
        ControlLabel.Caption = #1055#1086#1074#1090#1086#1088' '#1087#1072#1088#1086#1083#1103
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        MaxLength = 20
        PasswordChar = '*'
        TabOrder = 1
        Visible = True
      end
      object lbl_MinLen: TLabel
        Left = 85
        Top = 62
        Width = 112
        Height = 13
        Caption = ' ('#1084#1080#1085#1080#1084#1091#1084' 5 '#1089#1080#1084#1074#1086#1083#1086#1074')'
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 95
      Width = 240
      ExplicitTop = 94
      ExplicitWidth = 236
      inherited bvlFrmBtnsTl: TBevel
        Width = 238
        ExplicitWidth = 238
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 238
        ExplicitWidth = 238
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 238
        ExplicitWidth = 234
        inherited pnlFrmBtnsMain: TPanel
          Left = 139
          ExplicitLeft = 135
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 139
    Width = 250
    ExplicitTop = 138
    ExplicitWidth = 246
    inherited lblStatusBarR: TLabel
      Left = 177
      Height = 14
      ExplicitLeft = 177
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Top = 100
  end
end
