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
    ExplicitWidth = 856
    ExplicitHeight = 402
    inherited PMDIClient: TPanel
      Width = 846
      Height = 353
      ExplicitWidth = 850
      ExplicitHeight = 354
    end
    inherited PDlgPanel: TPanel
      Top = 358
      Width = 846
      ExplicitTop = 358
      ExplicitWidth = 846
      inherited BvDlg: TBevel
        Width = 844
        ExplicitWidth = 848
      end
      inherited BvDlgBottom: TBevel
        Width = 844
        ExplicitWidth = 848
      end
      inherited PDlgMain: TPanel
        Width = 844
        ExplicitWidth = 844
        inherited PDlgBtnForm: TPanel
          Left = 745
          ExplicitLeft = 749
        end
        inherited PDlgChb: TPanel
          Left = 517
          ExplicitLeft = 517
        end
        inherited PDlgBtnR: TPanel
          Left = 646
          ExplicitLeft = 650
        end
        inherited PDlgCenter: TPanel
          Width = 377
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
