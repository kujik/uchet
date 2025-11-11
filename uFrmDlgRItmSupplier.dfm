inherited FrmDlgRItmSupplier: TFrmDlgRItmSupplier
  Caption = 'FrmDlgRItmSupplier'
  ClientHeight = 270
  ClientWidth = 539
  ExplicitWidth = 555
  ExplicitHeight = 309
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 539
    Height = 254
    ExplicitWidth = 539
    ExplicitHeight = 254
    inherited pnlFrmClient: TPanel
      Width = 533
      Height = 206
      ExplicitWidth = 529
      ExplicitHeight = 205
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
      object mem_comments: TDBMemoEh
        Left = 84
        Top = 113
        Width = 441
        Height = 89
        ControlLabel.Width = 67
        ControlLabel.Height = 13
        ControlLabel.Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        Lines.Strings = (
          'mem_comments')
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        DynProps = <>
        EditButtons = <>
        TabOrder = 4
        Visible = True
        WantReturns = True
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 210
      Width = 529
      ExplicitTop = 210
      ExplicitWidth = 529
      inherited bvlFrmBtnsTl: TBevel
        Width = 531
        ExplicitWidth = 527
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 531
        ExplicitWidth = 527
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 531
        ExplicitWidth = 527
        inherited pnlFrmBtnsMain: TPanel
          Left = 432
          ExplicitLeft = 428
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 204
          ExplicitLeft = 200
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 333
          ExplicitLeft = 329
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 64
          ExplicitWidth = 60
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 254
    Width = 539
    ExplicitTop = 254
    ExplicitWidth = 539
    inherited lblStatusBarR: TLabel
      Left = 470
      ExplicitLeft = 470
    end
  end
end
