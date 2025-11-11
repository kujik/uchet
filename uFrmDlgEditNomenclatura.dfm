inherited FrmDlgEditNomenclatura: TFrmDlgEditNomenclatura
  Caption = 'FrmDlgEditNomenclatura'
  ClientHeight = 171
  ClientWidth = 529
  ExplicitWidth = 545
  ExplicitHeight = 210
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 529
    Height = 155
    ExplicitWidth = 529
    ExplicitHeight = 155
    inherited pnlFrmClient: TPanel
      Width = 523
      Height = 107
      ExplicitWidth = 519
      ExplicitHeight = 106
      object edt_name: TDBEditEh
        Left = 84
        Top = 3
        Width = 435
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
        TabOrder = 0
        Text = 'edt_name'
        Visible = True
        ExplicitWidth = 431
      end
      object cmb_id_group: TDBComboBoxEh
        Left = 84
        Top = 30
        Width = 437
        Height = 21
        ControlLabel.Width = 77
        ControlLabel.Height = 13
        ControlLabel.Caption = #1043#1088#1091#1087#1087#1072' '#1074' '#1089#1084#1077#1090#1077
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        Anchors = [akLeft, akTop, akRight]
        DynProps = <>
        EditButtons = <>
        TabOrder = 1
        Text = 'cmb_id_group'
        Visible = True
        ExplicitWidth = 433
      end
      object cmb_id_unit: TDBComboBoxEh
        Left = 84
        Top = 84
        Width = 115
        Height = 21
        ControlLabel.Width = 41
        ControlLabel.Height = 13
        ControlLabel.Caption = #1045#1076'. '#1080#1079#1084'.'
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 2
        Text = 'cmb_id_unit'
        Visible = True
      end
      object edt_id_group_itm: TDBEditEh
        Left = 84
        Top = 57
        Width = 435
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 69
        ControlLabel.Height = 13
        ControlLabel.Caption = #1043#1088#1091#1087#1087#1072' '#1074' '#1048#1058#1052
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <
          item
            DefaultAction = True
            Style = ebsPlusEh
            OnClick = edt_id_group_itmEditButtons0click
          end>
        MaxLength = 400
        TabOrder = 3
        Text = 'edt_id_group_itm'
        Visible = True
        ExplicitWidth = 431
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 112
      Width = 523
      ExplicitTop = 111
      ExplicitWidth = 519
      inherited bvlFrmBtnsTl: TBevel
        Width = 521
        ExplicitWidth = 525
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 521
        ExplicitWidth = 525
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 521
        ExplicitWidth = 517
        inherited pnlFrmBtnsMain: TPanel
          Left = 422
          ExplicitLeft = 418
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 194
          ExplicitLeft = 190
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 323
          ExplicitLeft = 319
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 54
          ExplicitWidth = 50
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 155
    Width = 529
    ExplicitTop = 155
    ExplicitWidth = 529
    inherited lblStatusBarR: TLabel
      Left = 460
      ExplicitLeft = 460
    end
  end
end
