inherited FrmBasicInput: TFrmBasicInput
  Caption = 'FrmBasicInput'
  ClientHeight = 151
  ClientWidth = 142
  ExplicitWidth = 154
  ExplicitHeight = 189
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 142
    Height = 135
    ExplicitWidth = 138
    ExplicitHeight = 134
    inherited pnlFrmClient: TPanel
      Width = 132
      Height = 86
      ExplicitWidth = 128
      ExplicitHeight = 85
    end
    inherited pnlFrmBtns: TPanel
      Top = 91
      Width = 132
      ExplicitTop = 90
      ExplicitWidth = 128
      inherited bvlFrmBtnsTl: TBevel
        Width = 130
        ExplicitWidth = 389
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 130
        ExplicitWidth = 389
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 130
        ExplicitWidth = 126
        inherited pnlFrmBtnsMain: TPanel
          Left = 31
          ExplicitLeft = 27
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = -197
          ExplicitLeft = -201
        end
        inherited pnlFrmBtnsR: TPanel
          Left = -68
          ExplicitLeft = -72
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 135
    Width = 142
    ExplicitTop = 134
    ExplicitWidth = 138
    inherited lblStatusBarR: TLabel
      Left = 69
      Height = 14
      ExplicitLeft = 81
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
