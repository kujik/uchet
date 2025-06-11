inherited FrmADedtItmCopyRigths: TFrmADedtItmCopyRigths
  Caption = 'FrmADedtItmCopyRigths'
  ClientHeight = 141
  ClientWidth = 314
  ExplicitWidth = 330
  ExplicitHeight = 180
  PixelsPerInch = 96
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 314
    Height = 125
    inherited PMDIClient: TPanel
      Width = 304
      Height = 76
      object CbSrc: TDBComboBoxEh
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
        Text = 'CbSrc'
        Visible = True
      end
      object CbDst: TDBComboBoxEh
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
        Text = 'Cb_Src'
        Visible = True
      end
    end
    inherited PDlgPanel: TPanel
      Top = 81
      Width = 304
      inherited BvDlg: TBevel
        Width = 302
      end
      inherited BvDlgBottom: TBevel
        Width = 302
      end
      inherited PDlgMain: TPanel
        Width = 302
        inherited PDlgBtnForm: TPanel
          Left = 203
        end
        inherited PDlgChb: TPanel
          Left = -25
        end
        inherited PDlgBtnR: TPanel
          Left = 104
        end
        inherited PDlgCenter: TPanel
          Width = 37
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 125
    Width = 314
    inherited LbStatusBarRight: TLabel
      Left = 222
    end
  end
end
