inherited FrmWDedtWorkerStatus: TFrmWDedtWorkerStatus
  Caption = 'FrmWDedtWorkerStatus'
  ClientHeight = 213
  ClientWidth = 607
  ExplicitWidth = 619
  ExplicitHeight = 251
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 607
    Height = 197
    ExplicitWidth = 603
    ExplicitHeight = 196
    inherited pnlFrmClient: TPanel
      Width = 597
      Height = 148
      ExplicitWidth = 593
      ExplicitHeight = 147
      object cmbJob: TDBComboBoxEh
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
      object cmbDivision: TDBComboBoxEh
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
      object cmbStatus: TDBComboBoxEh
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
        OnChange = cmb_StatusChange
      end
      object dedtDate: TDBDateTimeEditEh
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
      object cmbWorker: TDBComboBoxEh
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
    inherited pnlFrmBtns: TPanel
      Top = 153
      Width = 597
      ExplicitTop = 152
      ExplicitWidth = 593
      inherited bvlFrmBtnsTl: TBevel
        Width = 595
        ExplicitWidth = 595
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 595
        ExplicitWidth = 595
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 595
        ExplicitWidth = 591
        inherited pnlFrmBtnsMain: TPanel
          Left = 496
          ExplicitLeft = 492
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 268
          ExplicitLeft = 264
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 397
          ExplicitLeft = 393
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 128
          ExplicitWidth = 124
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 197
    Width = 607
    ExplicitTop = 196
    ExplicitWidth = 603
    inherited lblStatusBarR: TLabel
      Left = 534
      Height = 14
      ExplicitLeft = 534
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
