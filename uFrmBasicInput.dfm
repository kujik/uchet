inherited FrmBasicInput: TFrmBasicInput
  Caption = 'FrmBasicInput'
  ClientHeight = 155
  ClientWidth = 158
  ExplicitWidth = 174
  ExplicitHeight = 194
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 158
    Height = 139
    ExplicitWidth = 158
    ExplicitHeight = 139
    inherited pnlFrmClient: TPanel
      Width = 152
      Height = 91
      ExplicitWidth = 148
      ExplicitHeight = 90
    end
    inherited pnlFrmBtns: TPanel
      Top = 96
      Width = 152
      ExplicitTop = 95
      ExplicitWidth = 148
      inherited bvlFrmBtnsTl: TBevel
        Width = 150
        ExplicitWidth = 389
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 150
        ExplicitWidth = 389
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 150
        ExplicitWidth = 146
        inherited pnlFrmBtnsMain: TPanel
          Left = 51
          ExplicitLeft = 47
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = -177
          ExplicitLeft = -181
        end
        inherited pnlFrmBtnsR: TPanel
          Left = -48
          ExplicitLeft = -52
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 139
    Width = 158
    ExplicitTop = 139
    ExplicitWidth = 158
    inherited lblStatusBarR: TLabel
      Left = 89
      Height = 14
      ExplicitLeft = 82
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
