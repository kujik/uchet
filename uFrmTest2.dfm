inherited FrmTest2: TFrmTest2
  Caption = 'FrmTest2'
  ClientHeight = 540
  ClientWidth = 832
  ExplicitWidth = 844
  ExplicitHeight = 578
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 832
    Height = 524
    ExplicitWidth = 266
    ExplicitHeight = 81
    inherited pnlFrmClient: TPanel
      Width = 822
      Height = 475
      ExplicitWidth = 256
      ExplicitHeight = 32
    end
    inherited pnlFrmBtns: TPanel
      Top = 480
      Width = 822
      ExplicitTop = 37
      ExplicitWidth = 256
      inherited bvlFrmBtnsTl: TBevel
        Width = 820
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 820
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 820
        ExplicitWidth = 254
        inherited pnlFrmBtnsMain: TPanel
          Left = 721
          ExplicitLeft = 155
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 493
          ExplicitLeft = -73
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 622
          ExplicitLeft = 56
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 353
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 524
    Width = 832
    ExplicitTop = 81
    ExplicitWidth = 266
    inherited lblStatusBarR: TLabel
      Left = 759
      Height = 14
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
