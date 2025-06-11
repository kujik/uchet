inherited FrmDlgRItmSupplier: TFrmDlgRItmSupplier
  Caption = 'FrmDlgRItmSupplier'
  ClientHeight = 177
  ClientWidth = 539
  ExplicitWidth = 555
  ExplicitHeight = 216
  PixelsPerInch = 96
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 539
    Height = 161
    ExplicitWidth = 539
    ExplicitHeight = 161
    inherited PMDIClient: TPanel
      Width = 529
      Height = 115
      ExplicitWidth = 529
      ExplicitHeight = 115
      object E_Name_Org: TDBEditEh
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
        Text = 'E_Name_Org'
        Visible = True
      end
      object E_Full_Name: TDBEditEh
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
        Text = 'E_Name_Unit'
        Visible = True
      end
      object E_E_Mail: TDBEditEh
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
        Text = 'E_Name_E_Mail'
        Visible = True
      end
      object E_Inn: TDBEditEh
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
        Text = 'E_Name_E_Mail'
        Visible = True
      end
    end
    inherited PDlgPanel: TPanel
      Top = 120
      Width = 529
      ExplicitTop = 120
      ExplicitWidth = 529
      inherited BvDlg: TBevel
        Width = 527
        ExplicitWidth = 527
      end
      inherited BvDlgBottom: TBevel
        Width = 527
        ExplicitWidth = 527
      end
      inherited PDlgMain: TPanel
        Width = 527
        ExplicitWidth = 527
        inherited PDlgBtnForm: TPanel
          Left = 428
          ExplicitLeft = 428
        end
        inherited PDlgChb: TPanel
          Left = 200
          ExplicitLeft = 200
        end
        inherited PDlgBtnR: TPanel
          Left = 329
          ExplicitLeft = 329
        end
        inherited PDlgCenter: TPanel
          Width = 60
          ExplicitWidth = 60
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 161
    Width = 539
    ExplicitTop = 161
    ExplicitWidth = 539
    inherited LbStatusBarRight: TLabel
      Left = 447
      Height = 14
      ExplicitLeft = 447
    end
    inherited LbStatusBarLeft: TLabel
      Height = 14
    end
  end
end
