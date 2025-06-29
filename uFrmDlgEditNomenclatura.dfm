inherited FrmDlgEditNomenclatura: TFrmDlgEditNomenclatura
  Caption = 'FrmDlgEditNomenclatura'
  ClientHeight = 173
  ClientWidth = 537
  ExplicitWidth = 549
  ExplicitHeight = 211
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 537
    Height = 157
    ExplicitWidth = 533
    ExplicitHeight = 156
    inherited pnlFrmClient: TPanel
      Width = 527
      Height = 108
      ExplicitWidth = 523
      ExplicitHeight = 107
      object edt_name: TDBEditEh
        Left = 84
        Top = 3
        Width = 439
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
        ExplicitWidth = 435
      end
      object cmb_id_group: TDBComboBoxEh
        Left = 84
        Top = 30
        Width = 441
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
        ExplicitWidth = 437
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
        Width = 439
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
        ExplicitWidth = 435
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 113
      Width = 527
      ExplicitTop = 112
      ExplicitWidth = 523
      inherited bvlFrmBtnsTl: TBevel
        Width = 525
        ExplicitWidth = 525
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 525
        ExplicitWidth = 525
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 525
        ExplicitWidth = 521
        inherited pnlFrmBtnsMain: TPanel
          Left = 426
          ExplicitLeft = 422
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 198
          ExplicitLeft = 194
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 327
          ExplicitLeft = 323
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 58
          ExplicitWidth = 54
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 157
    Width = 537
    ExplicitTop = 156
    ExplicitWidth = 533
    inherited lblStatusBarR: TLabel
      Left = 464
      Height = 14
      ExplicitLeft = 464
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
