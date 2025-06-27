inherited FrmWDedtWorkerStatus: TFrmWDedtWorkerStatus
  Caption = 'FrmWDedtWorkerStatus'
  ClientHeight = 213
  ClientWidth = 607
  ExplicitWidth = 619
  ExplicitHeight = 251
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 607
    Height = 197
    ExplicitWidth = 852
    ExplicitHeight = 401
    inherited PMDIClient: TPanel
      Width = 597
      Height = 148
      ExplicitWidth = 842
      ExplicitHeight = 352
      object Cb_Job: TDBComboBoxEh
        Left = 87
        Top = 122
        Width = 508
        Height = 21
        ControlLabel.Width = 57
        ControlLabel.Height = 13
        ControlLabel.Caption = #1044#1086#1083#1078#1085#1086#1089#1090#1100
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 0
        Visible = True
      end
      object Cb_Division: TDBComboBoxEh
        Left = 87
        Top = 95
        Width = 508
        Height = 21
        ControlLabel.Width = 80
        ControlLabel.Height = 13
        ControlLabel.Caption = #1055#1086#1076#1088#1072#1079#1076#1077#1083#1077#1085#1080#1077
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 1
        Visible = True
      end
      object Cb_Status: TDBComboBoxEh
        Left = 87
        Top = 68
        Width = 121
        Height = 21
        ControlLabel.Width = 36
        ControlLabel.Height = 13
        ControlLabel.Caption = #1057#1090#1072#1090#1091#1089
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 2
        Visible = True
        OnChange = Cb_StatusChange
      end
      object De_Date: TDBDateTimeEditEh
        Left = 87
        Top = 41
        Width = 121
        Height = 21
        ControlLabel.Width = 26
        ControlLabel.Height = 13
        ControlLabel.Caption = #1044#1072#1090#1072
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        Kind = dtkDateEh
        TabOrder = 3
        Visible = True
      end
      object Cb_Worker: TDBComboBoxEh
        Left = 87
        Top = 14
        Width = 508
        Height = 21
        ControlLabel.Width = 48
        ControlLabel.Height = 13
        ControlLabel.Caption = #1056#1072#1073#1086#1090#1085#1080#1082
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 4
        Visible = True
      end
    end
    inherited PDlgPanel: TPanel
      Top = 153
      Width = 597
      ExplicitTop = 357
      ExplicitWidth = 842
      inherited BvDlg: TBevel
        Width = 595
      end
      inherited BvDlgBottom: TBevel
        Width = 595
      end
      inherited PDlgMain: TPanel
        Width = 595
        ExplicitWidth = 840
        inherited PDlgBtnForm: TPanel
          Left = 496
          ExplicitLeft = 741
        end
        inherited PDlgChb: TPanel
          Left = 268
          ExplicitLeft = 513
        end
        inherited PDlgBtnR: TPanel
          Left = 397
          ExplicitLeft = 642
        end
        inherited PDlgCenter: TPanel
          Width = 128
          ExplicitWidth = 373
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 197
    Width = 607
    ExplicitTop = 401
    ExplicitWidth = 852
    inherited LbStatusBarRight: TLabel
      Left = 515
      Height = 14
    end
    inherited LbStatusBarLeft: TLabel
      Height = 14
    end
  end
end
