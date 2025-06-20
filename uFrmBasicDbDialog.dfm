inherited FrmBasicDbDialog: TFrmBasicDbDialog
  Caption = 'FrmBasicDbDialog'
  ClientHeight = 418
  ClientWidth = 856
  ExplicitWidth = 872
  ExplicitHeight = 457
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 856
    Height = 402
    ExplicitWidth = 860
    ExplicitHeight = 403
    inherited PMDIClient: TPanel
      Width = 850
      Height = 354
      ExplicitWidth = 850
      ExplicitHeight = 354
    end
    inherited PDlgPanel: TPanel
      Top = 359
      Width = 850
      ExplicitTop = 359
      ExplicitWidth = 850
      inherited BvDlg: TBevel
        Width = 848
        ExplicitWidth = 848
      end
      inherited BvDlgBottom: TBevel
        Width = 848
        ExplicitWidth = 848
      end
      inherited PDlgMain: TPanel
        Width = 848
        ExplicitWidth = 848
        inherited PDlgBtnForm: TPanel
          Left = 749
          ExplicitLeft = 749
        end
        inherited PDlgChb: TPanel
          Left = 521
          ExplicitLeft = 521
        end
        inherited PDlgBtnR: TPanel
          Left = 650
          ExplicitLeft = 650
        end
        inherited PDlgCenter: TPanel
          Width = 381
          ExplicitWidth = 381
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 402
    Width = 856
    ExplicitTop = 403
    ExplicitWidth = 860
    inherited LbStatusBarRight: TLabel
      Left = 768
      ExplicitLeft = 768
    end
  end
end
