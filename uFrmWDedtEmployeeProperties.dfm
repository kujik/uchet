inherited FrmWDedtEmployeeProperties: TFrmWDedtEmployeeProperties
  Caption = 'FrmWDedtEmployeeProperties'
  ClientHeight = 339
  ClientWidth = 498
  ExplicitWidth = 510
  ExplicitHeight = 377
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 498
    Height = 323
    inherited pnlFrmClient: TPanel
      Width = 488
      Height = 274
      ExplicitWidth = 235
      ExplicitHeight = 52
      object cmb_type: TDBComboBoxEh
        Left = 86
        Top = 8
        Width = 115
        Height = 21
        ControlLabel.Width = 58
        ControlLabel.Height = 13
        ControlLabel.Caption = #1042#1080#1076' '#1079#1072#1076#1072#1095#1080
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 0
        Text = 'cmb_type'
        Visible = True
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 279
      Width = 488
      inherited bvlFrmBtnsTl: TBevel
        Width = 486
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 486
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 486
        inherited pnlFrmBtnsMain: TPanel
          Left = 387
          ExplicitLeft = 134
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 159
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 288
          ExplicitLeft = 35
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 19
          ExplicitWidth = 6
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 323
    Width = 498
    ExplicitTop = 101
    ExplicitWidth = 245
    inherited lblStatusBarR: TLabel
      Left = 425
      Height = 14
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
