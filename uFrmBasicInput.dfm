inherited FrmBasicInput: TFrmBasicInput
  Caption = 'FrmBasicInput'
  ClientHeight = 153
  ClientWidth = 150
  ExplicitWidth = 166
  ExplicitHeight = 192
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 150
    Height = 137
    ExplicitWidth = 150
    ExplicitHeight = 137
    inherited pnlFrmClient: TPanel
      Width = 144
      Height = 89
      ExplicitWidth = 140
      ExplicitHeight = 88
    end
    inherited pnlFrmBtns: TPanel
      Top = 94
      Width = 144
      ExplicitTop = 93
      ExplicitWidth = 140
      inherited bvlFrmBtnsTl: TBevel
        Width = 142
        ExplicitWidth = 389
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 142
        ExplicitWidth = 389
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 142
        ExplicitWidth = 138
        inherited pnlFrmBtnsMain: TPanel
          Left = 43
          ExplicitLeft = 39
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = -185
          ExplicitLeft = -189
        end
        inherited pnlFrmBtnsR: TPanel
          Left = -56
          ExplicitLeft = -60
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 137
    Width = 150
    ExplicitTop = 137
    ExplicitWidth = 150
    inherited lblStatusBarR: TLabel
      Left = 81
      ExplicitLeft = 81
    end
  end
end
