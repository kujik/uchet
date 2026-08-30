inherited FrmChooseDialogMulti: TFrmChooseDialogMulti
  Caption = 'FrmChooseDialogMulti'
  ClientHeight = 226
  ClientWidth = 379
  ExplicitWidth = 391
  ExplicitHeight = 264
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 379
    Height = 210
    ExplicitWidth = 262
    ExplicitHeight = 80
    inherited pnlFrmClient: TPanel
      Width = 369
      Height = 161
      object clbMain: TCheckListBox
        Left = 0
        Top = 41
        Width = 369
        Height = 120
        Align = alClient
        ItemHeight = 13
        TabOrder = 0
        ExplicitTop = 64
        ExplicitHeight = 97
      end
      object pnlText: TPanel
        Left = 0
        Top = 0
        Width = 369
        Height = 41
        Align = alTop
        TabOrder = 1
        ExplicitLeft = 296
        ExplicitTop = 40
        ExplicitWidth = 185
        object lblText: TLabel
          Left = 1
          Top = 1
          Width = 367
          Height = 39
          Align = alClient
          Caption = 'lblText'
          WordWrap = True
          ExplicitWidth = 32
          ExplicitHeight = 13
        end
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 166
      Width = 369
      ExplicitTop = 36
      ExplicitWidth = 252
      inherited bvlFrmBtnsTl: TBevel
        Width = 367
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 367
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 367
        ExplicitWidth = 250
        inherited pnlFrmBtnsMain: TPanel
          Left = 268
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 40
          ExplicitLeft = -77
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 169
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 210
    Width = 379
    inherited lblStatusBarR: TLabel
      Left = 306
      Height = 14
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
