inherited FrmXDedtMemo: TFrmXDedtMemo
  Caption = 'FrmXDedtMemo'
  ClientHeight = 302
  ClientWidth = 596
  ExplicitWidth = 612
  ExplicitHeight = 341
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 596
    Height = 286
    ExplicitWidth = 596
    ExplicitHeight = 286
    inherited pnlFrmClient: TPanel
      Width = 590
      Height = 238
      ExplicitWidth = 586
      ExplicitHeight = 237
      object pnlCaption: TPanel
        Left = 0
        Top = 0
        Width = 590
        Height = 25
        Align = alTop
        Caption = 'pnlCaption'
        TabOrder = 0
        ExplicitWidth = 586
        object lblCaption: TLabel
          Left = 9
          Top = 6
          Width = 47
          Height = 13
          Caption = 'lblCaption'
        end
      end
      object memMain: TDBMemoEh
        Left = 0
        Top = 25
        Width = 590
        Height = 213
        Lines.Strings = (
          'mem_Main')
        Align = alClient
        AutoSize = False
        DynProps = <>
        EditButtons = <>
        TabOrder = 1
        Visible = True
        WantReturns = True
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 242
      Width = 586
      ExplicitTop = 242
      ExplicitWidth = 586
      inherited bvlFrmBtnsTl: TBevel
        Width = 588
        ExplicitWidth = 592
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 588
        ExplicitWidth = 592
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 588
        ExplicitWidth = 584
        inherited pnlFrmBtnsMain: TPanel
          Left = 489
          ExplicitLeft = 485
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 261
          ExplicitLeft = 257
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 390
          ExplicitLeft = 386
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 121
          ExplicitWidth = 117
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 286
    Width = 596
    ExplicitTop = 286
    ExplicitWidth = 596
    inherited lblStatusBarR: TLabel
      Left = 527
      ExplicitLeft = 527
    end
  end
  inherited tmrAfterCreate: TTimer
    Top = 248
  end
end
