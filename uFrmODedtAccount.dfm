inherited FrmODedtAccount: TFrmODedtAccount
  Caption = 'FrmODedtAccount'
  ClientHeight = 881
  ClientWidth = 1108
  ExplicitWidth = 1120
  ExplicitHeight = 919
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 1108
    Height = 865
    ExplicitWidth = 848
    ExplicitHeight = 400
    inherited pnlFrmClient: TPanel
      Width = 1098
      Height = 816
      ExplicitWidth = 838
      ExplicitHeight = 351
    end
    inherited pnlFrmBtns: TPanel
      Top = 821
      Width = 1098
      ExplicitTop = 356
      ExplicitWidth = 838
      inherited bvlFrmBtnsTl: TBevel
        Width = 1096
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 1096
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 1096
        ExplicitWidth = 836
        inherited pnlFrmBtnsMain: TPanel
          Left = 997
          ExplicitLeft = 737
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 769
          ExplicitLeft = 509
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 898
          ExplicitLeft = 638
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 629
          ExplicitWidth = 369
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 865
    Width = 1108
    ExplicitTop = 400
    ExplicitWidth = 848
    inherited lblStatusBarR: TLabel
      Left = 1035
      Height = 14
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
