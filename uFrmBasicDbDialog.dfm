inherited FrmBasicDbDialog: TFrmBasicDbDialog
  Caption = 'FrmBasicDbDialog'
  ClientHeight = 115
  ClientWidth = 237
  ExplicitWidth = 253
  ExplicitHeight = 154
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 237
    Height = 99
    ExplicitWidth = 241
    ExplicitHeight = 100
    inherited pnlFrmClient: TPanel
      Width = 231
      Height = 51
      ExplicitWidth = 838
      ExplicitHeight = 351
    end
    inherited pnlFrmBtns: TPanel
      Top = 56
      Width = 231
      ExplicitTop = 56
      ExplicitWidth = 231
      inherited bvlFrmBtnsTl: TBevel
        Width = 229
        ExplicitWidth = 848
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 229
        ExplicitWidth = 848
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 229
        ExplicitWidth = 229
        inherited pnlFrmBtnsMain: TPanel
          Left = 130
          ExplicitLeft = 737
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = -98
          ExplicitLeft = -98
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 31
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
    Top = 99
    Width = 237
    ExplicitTop = 400
    ExplicitWidth = 848
    inherited lblStatusBarR: TLabel
      Left = 176
      ExplicitLeft = 176
    end
  end
end
