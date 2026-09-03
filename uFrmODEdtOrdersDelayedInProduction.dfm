inherited FrmODEdtOrdersDelayedInProduction: TFrmODEdtOrdersDelayedInProduction
  Caption = 'FrmODEdtOrdersDelayedInProduction'
  ClientHeight = 305
  ClientWidth = 501
  ExplicitWidth = 513
  ExplicitHeight = 343
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 501
    Height = 289
    ExplicitWidth = 549
    ExplicitHeight = 230
    inherited pnlFrmClient: TPanel
      Width = 491
      Height = 240
      object cmb_Reason: TDBComboBoxEh
        Left = 8
        Top = 20
        Width = 487
        Height = 21
        ControlLabel.Width = 103
        ControlLabel.Height = 13
        ControlLabel.Caption = #1055#1088#1080#1095#1080#1085#1072' '#1087#1088#1086#1089#1088#1086#1095#1082#1080':'
        ControlLabel.Visible = True
        DynProps = <>
        EditButtons = <>
        TabOrder = 0
        Text = 'cmb_Reason'
        Visible = True
      end
      object mem_Comment: TDBMemoEh
        Left = 8
        Top = 64
        Width = 487
        Height = 163
        ControlLabel.Width = 71
        ControlLabel.Height = 13
        ControlLabel.Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081':'
        ControlLabel.Visible = True
        Lines.Strings = (
          'mem_Comment')
        AutoSize = False
        DynProps = <>
        EditButtons = <>
        TabOrder = 1
        Visible = True
        WantReturns = True
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 245
      Width = 491
      ExplicitTop = 36
      ExplicitWidth = 539
      inherited bvlFrmBtnsTl: TBevel
        Width = 489
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 489
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 489
        ExplicitWidth = 537
        inherited pnlFrmBtnsMain: TPanel
          Left = 388
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = -125
          ExplicitLeft = -77
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 4
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 289
    Width = 501
    inherited lblStatusBarR: TLabel
      Left = 428
      Height = 14
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
