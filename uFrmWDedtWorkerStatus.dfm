inherited FrmWDedtWorkerStatus: TFrmWDedtWorkerStatus
  Caption = 'FrmWDedtWorkerStatus'
  ClientHeight = 211
  ClientWidth = 599
  ExplicitWidth = 615
  ExplicitHeight = 250
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 599
    Height = 195
    ExplicitWidth = 599
    ExplicitHeight = 195
    inherited pnlFrmClient: TPanel
      Width = 593
      Height = 147
      ExplicitWidth = 589
      ExplicitHeight = 146
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
      Top = 152
      Width = 593
      ExplicitTop = 151
      ExplicitWidth = 589
      inherited bvlFrmBtnsTl: TBevel
        Width = 591
        ExplicitWidth = 595
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 591
        ExplicitWidth = 595
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 591
        ExplicitWidth = 587
        inherited pnlFrmBtnsMain: TPanel
          Left = 492
          ExplicitLeft = 488
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 264
          ExplicitLeft = 260
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 393
          ExplicitLeft = 389
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 124
          ExplicitWidth = 120
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 195
    Width = 599
    ExplicitTop = 195
    ExplicitWidth = 599
    inherited lblStatusBarR: TLabel
      Left = 530
      ExplicitLeft = 530
    end
  end
end
