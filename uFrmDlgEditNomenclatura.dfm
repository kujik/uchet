inherited FrmDlgEditNomenclatura: TFrmDlgEditNomenclatura
  Caption = 'FrmDlgEditNomenclatura'
  ClientHeight = 173
  ClientWidth = 537
  ExplicitWidth = 553
  ExplicitHeight = 212
  PixelsPerInch = 96
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 537
    Height = 157
    ExplicitWidth = 537
    ExplicitHeight = 157
    inherited PMDIClient: TPanel
      Width = 527
      Height = 111
      ExplicitWidth = 527
      ExplicitHeight = 111
      object E_Name: TDBEditEh
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
        Text = 'E_Name'
        Visible = True
      end
      object Cb_Id_Group: TDBComboBoxEh
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
        Text = 'Cb_Id_Group'
        Visible = True
      end
      object Cb_Id_Unit: TDBComboBoxEh
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
        Text = 'Cb_Id_Unit'
        Visible = True
      end
      object E_Id_Group_Itm: TDBEditEh
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
            OnClick = E_Id_Group_ItmEditButtons0Click
          end>
        MaxLength = 400
        TabOrder = 3
        Text = 'E_Id_Group_Itm'
        Visible = True
      end
    end
    inherited PDlgPanel: TPanel
      Top = 116
      Width = 527
      ExplicitTop = 116
      ExplicitWidth = 527
      inherited BvDlg: TBevel
        Width = 525
        ExplicitWidth = 525
      end
      inherited BvDlgBottom: TBevel
        Width = 525
        ExplicitWidth = 525
      end
      inherited PDlgMain: TPanel
        Width = 525
        ExplicitWidth = 525
        inherited PDlgBtnForm: TPanel
          Left = 426
          ExplicitLeft = 426
        end
        inherited PDlgChb: TPanel
          Left = 198
          ExplicitLeft = 198
        end
        inherited PDlgBtnR: TPanel
          Left = 327
          ExplicitLeft = 327
        end
        inherited PDlgCenter: TPanel
          Width = 58
          ExplicitWidth = 58
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 157
    Width = 537
    ExplicitTop = 157
    ExplicitWidth = 537
    inherited LbStatusBarRight: TLabel
      Left = 445
      ExplicitLeft = 445
    end
  end
end
