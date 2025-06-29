inherited FrmADedtItmCopyRigths: TFrmADedtItmCopyRigths
  Caption = 'FrmADedtItmCopyRigths'
  ClientHeight = 141
  ClientWidth = 314
  ExplicitWidth = 330
  ExplicitHeight = 180
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 314
    Height = 125
    inherited pnlFrmClient: TPanel
      Width = 304
      Height = 76
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
      Top = 81
      Width = 304
      inherited bvlFrmBtnsTl: TBevel
        Width = 302
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 302
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 302
        inherited pnlFrmBtnsMain: TPanel
          Left = 203
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = -25
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 104
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 37
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 125
    Width = 314
    inherited lblStatusBarR: TLabel
      Left = 222
    end
  end
end
