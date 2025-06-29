inherited FrmOWrepItmInfo: TFrmOWrepItmInfo
  Caption = 'FrmOWrepItmInfo'
  ClientHeight = 395
  ClientWidth = 745
  ExplicitWidth = 757
  ExplicitHeight = 433
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 745
    Height = 379
    ExplicitWidth = 270
    ExplicitHeight = 82
    inherited pnlFrmClient: TPanel
      Width = 735
      Height = 330
      ExplicitWidth = 260
      ExplicitHeight = 33
    end
    inherited pnlFrmBtns: TPanel
      Top = 335
      Width = 735
      ExplicitTop = 38
      ExplicitWidth = 260
      inherited bvlFrmBtnsTl: TBevel
        Width = 733
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 733
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 733
        ExplicitWidth = 258
        inherited pnlFrmBtnsMain: TPanel
          Left = 634
          ExplicitLeft = 159
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 406
          ExplicitLeft = -69
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 535
          ExplicitLeft = 60
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 266
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 379
    Width = 745
    ExplicitTop = 82
    ExplicitWidth = 270
    inherited lblStatusBarR: TLabel
      Left = 653
      Height = 14
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
