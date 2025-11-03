inherited FrmBasicDbDialog: TFrmBasicDbDialog
  Caption = 'FrmBasicDbDialog'
  ClientHeight = 118
  ClientWidth = 249
  ExplicitWidth = 261
  ExplicitHeight = 156
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 249
    Height = 102
    ExplicitWidth = 848
    ExplicitHeight = 400
    inherited pnlFrmClient: TPanel
      Width = 239
      Height = 53
      ExplicitWidth = 838
      ExplicitHeight = 351
    end
    inherited pnlFrmBtns: TPanel
      Top = 58
      Width = 239
      ExplicitTop = 356
      ExplicitWidth = 838
      inherited bvlFrmBtnsTl: TBevel
        Width = 237
        ExplicitWidth = 848
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 237
        ExplicitWidth = 848
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 237
        ExplicitWidth = 836
        inherited pnlFrmBtnsMain: TPanel
          Left = 138
          ExplicitLeft = 737
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = -90
          ExplicitLeft = 509
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 39
          ExplicitLeft = 638
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 6
          ExplicitWidth = 369
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 102
    Width = 249
    ExplicitTop = 400
    ExplicitWidth = 848
    inherited lblStatusBarR: TLabel
      Left = 176
      Height = 14
      ExplicitLeft = 768
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
