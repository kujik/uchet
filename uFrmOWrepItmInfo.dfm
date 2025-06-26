inherited FrmOWrepItmInfo: TFrmOWrepItmInfo
  Caption = 'FrmOWrepItmInfo'
  ClientHeight = 395
  ClientWidth = 745
  ExplicitWidth = 757
  ExplicitHeight = 433
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 745
    Height = 379
    ExplicitWidth = 270
    ExplicitHeight = 82
    inherited PMDIClient: TPanel
      Width = 735
      Height = 330
      ExplicitWidth = 260
      ExplicitHeight = 33
    end
    inherited PDlgPanel: TPanel
      Top = 335
      Width = 735
      ExplicitTop = 38
      ExplicitWidth = 260
      inherited BvDlg: TBevel
        Width = 733
      end
      inherited BvDlgBottom: TBevel
        Width = 733
      end
      inherited PDlgMain: TPanel
        Width = 733
        ExplicitWidth = 258
        inherited PDlgBtnForm: TPanel
          Left = 634
          ExplicitLeft = 159
        end
        inherited PDlgChb: TPanel
          Left = 406
          ExplicitLeft = -69
        end
        inherited PDlgBtnR: TPanel
          Left = 535
          ExplicitLeft = 60
        end
        inherited PDlgCenter: TPanel
          Width = 266
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 379
    Width = 745
    ExplicitTop = 82
    ExplicitWidth = 270
    inherited LbStatusBarRight: TLabel
      Left = 653
      Height = 14
    end
    inherited LbStatusBarLeft: TLabel
      Height = 14
    end
  end
end
