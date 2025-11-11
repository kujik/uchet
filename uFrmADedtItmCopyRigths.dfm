inherited FrmADedtItmCopyRigths: TFrmADedtItmCopyRigths
  Caption = 'FrmADedtItmCopyRigths'
  ClientHeight = 139
  ClientWidth = 306
  ExplicitWidth = 322
  ExplicitHeight = 178
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 306
    Height = 123
    ExplicitWidth = 306
    ExplicitHeight = 123
    inherited pnlFrmClient: TPanel
      Width = 300
      Height = 75
      ExplicitWidth = 296
      ExplicitHeight = 74
      object cmbSrc: TDBComboBoxEh
        Left = 8
        Top = 16
        Width = 319
        Height = 21
        ControlLabel.Width = 52
        ControlLabel.Height = 13
        ControlLabel.Caption = #1048#1089#1090#1086#1095#1085#1080#1082':'
        ControlLabel.Visible = True
        DynProps = <>
        EditButtons = <>
        LimitTextToListValues = True
        TabOrder = 0
        Text = 'cmbSrc'
        Visible = True
      end
      object cmbDst: TDBComboBoxEh
        Left = 8
        Top = 56
        Width = 319
        Height = 21
        ControlLabel.Width = 64
        ControlLabel.Height = 13
        ControlLabel.Caption = #1053#1072#1079#1085#1072#1095#1077#1085#1080#1077':'
        ControlLabel.Visible = True
        DynProps = <>
        EditButtons = <>
        LimitTextToListValues = True
        TabOrder = 1
        Text = 'cmb_Src'
        Visible = True
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 80
      Width = 300
      ExplicitTop = 79
      ExplicitWidth = 296
      inherited bvlFrmBtnsTl: TBevel
        Width = 298
        ExplicitWidth = 302
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 298
        ExplicitWidth = 302
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 298
        ExplicitWidth = 294
        inherited pnlFrmBtnsMain: TPanel
          Left = 199
          ExplicitLeft = 195
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = -29
          ExplicitLeft = -33
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 100
          ExplicitLeft = 96
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 37
          ExplicitWidth = 37
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 123
    Width = 306
    ExplicitTop = 123
    ExplicitWidth = 306
    inherited lblStatusBarR: TLabel
      Left = 237
      ExplicitLeft = 237
    end
  end
end
