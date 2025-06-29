inherited FrmDlgRItmSupplier: TFrmDlgRItmSupplier
  Caption = 'FrmDlgRItmSupplier'
  ClientHeight = 177
  ClientWidth = 539
  ExplicitWidth = 551
  ExplicitHeight = 215
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 539
    Height = 161
    ExplicitWidth = 535
    ExplicitHeight = 160
    inherited pnlFrmClient: TPanel
      Width = 529
      Height = 112
      ExplicitWidth = 525
      ExplicitHeight = 111
      object edt_name_org: TDBEditEh
        Left = 84
        Top = 3
        Width = 441
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 73
        ControlLabel.Height = 13
        ControlLabel.Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        MaxLength = 400
        TabOrder = 1
        Text = 'edt_name_org'
        Visible = True
        ExplicitWidth = 437
      end
      object edt_full_name: TDBEditEh
        Left = 84
        Top = 30
        Width = 441
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 72
        ControlLabel.Height = 26
        ControlLabel.Caption = #1055#1086#1083#1085#1086#1077#13#10#1085#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        MaxLength = 400
        TabOrder = 2
        Text = 'edt_Name_Unit'
        Visible = True
        ExplicitWidth = 437
      end
      object edt_e_mail: TDBEditEh
        Left = 84
        Top = 57
        Width = 441
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 24
        ControlLabel.Height = 13
        ControlLabel.Caption = 'Email'
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        MaxLength = 400
        TabOrder = 3
        Text = 'edt_Name_E_Mail'
        Visible = True
        ExplicitWidth = 437
      end
      object edt_inn: TDBEditEh
        Left = 84
        Top = 86
        Width = 101
        Height = 21
        ControlLabel.Width = 21
        ControlLabel.Height = 13
        ControlLabel.Caption = #1048#1053#1053
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        MaxLength = 400
        TabOrder = 0
        Text = 'edt_Name_E_Mail'
        Visible = True
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 117
      Width = 529
      ExplicitTop = 116
      ExplicitWidth = 525
      inherited bvlFrmBtnsTl: TBevel
        Width = 527
        ExplicitWidth = 527
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 527
        ExplicitWidth = 527
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 527
        ExplicitWidth = 523
        inherited pnlFrmBtnsMain: TPanel
          Left = 428
          ExplicitLeft = 424
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 200
          ExplicitLeft = 196
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 329
          ExplicitLeft = 325
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 60
          ExplicitWidth = 56
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 161
    Width = 539
    ExplicitTop = 160
    ExplicitWidth = 535
    inherited lblStatusBarR: TLabel
      Left = 466
      Height = 14
      ExplicitLeft = 466
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
