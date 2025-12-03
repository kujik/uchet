inherited FrmDlgRItmSupplier: TFrmDlgRItmSupplier
  Caption = 'FrmDlgRItmSupplier'
  ClientHeight = 357
  ClientWidth = 539
  ExplicitWidth = 551
  ExplicitHeight = 395
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 539
    Height = 341
    ExplicitWidth = 539
    ExplicitHeight = 254
    inherited pnlFrmClient: TPanel
      Width = 529
      Height = 292
      ExplicitWidth = 525
      ExplicitHeight = 204
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
        Top = 138
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
        Top = 165
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
        Top = 192
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
        ExplicitWidth = 437
      end
      object edt_add_address: TDBEditEh
        Left = 84
        Top = 57
        Width = 441
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 31
        ControlLabel.Height = 13
        ControlLabel.Caption = #1040#1076#1088#1077#1089
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        MaxLength = 400
        TabOrder = 5
        Text = 'edt_Name_E_Mail'
        Visible = True
        ExplicitWidth = 437
      end
      object edt_add_contact_name: TDBEditEh
        Left = 84
        Top = 84
        Width = 441
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 61
        ControlLabel.Height = 26
        ControlLabel.Caption = #1050#1086#1085#1090#1072#1082#1090#1085#1086#1077#13#10#1083#1080#1094#1086
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        MaxLength = 400
        TabOrder = 6
        Text = 'edt_Name_E_Mail'
        Visible = True
        ExplicitWidth = 437
      end
      object edt_add_phone: TDBEditEh
        Left = 84
        Top = 111
        Width = 441
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 44
        ControlLabel.Height = 13
        ControlLabel.Caption = #1058#1077#1083#1077#1092#1086#1085
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        MaxLength = 400
        TabOrder = 7
        Text = 'edt_Name_E_Mail'
        Visible = True
        ExplicitWidth = 437
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 297
      Width = 529
      ExplicitTop = 209
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
    Top = 341
    Width = 539
    ExplicitTop = 253
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
