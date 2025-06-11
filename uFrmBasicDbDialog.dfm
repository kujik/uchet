inherited FrmBasicDbDialog: TFrmBasicDbDialog
  Caption = 'FrmBasicDbDialog'
  ClientHeight = 419
  ClientWidth = 860
  ExplicitWidth = 876
  ExplicitHeight = 458
  PixelsPerInch = 96
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 860
    Height = 403
    inherited PMDIClient: TPanel
      Width = 850
      Height = 354
    end
    inherited PDlgPanel: TPanel
      Top = 359
      Width = 850
      inherited BvDlg: TBevel
        Width = 848
      end
      inherited BvDlgBottom: TBevel
        Width = 848
      end
      inherited PDlgMain: TPanel
        Width = 848
        inherited PDlgBtnForm: TPanel
          Left = 749
        end
        inherited PDlgChb: TPanel
          Left = 521
        end
        inherited PDlgBtnR: TPanel
          Left = 650
        end
        inherited PDlgCenter: TPanel
          Width = 381
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 403
    Width = 860
    inherited LbStatusBarRight: TLabel
      Left = 768
      Height = 14
    end
    inherited LbStatusBarLeft: TLabel
      Height = 14
    end
  end
end
