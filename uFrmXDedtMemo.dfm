inherited FrmXDedtMemo: TFrmXDedtMemo
  Caption = 'FrmXDedtMemo'
  ClientHeight = 304
  ClientWidth = 604
  ExplicitWidth = 620
  ExplicitHeight = 343
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 604
    Height = 288
    ExplicitWidth = 604
    ExplicitHeight = 288
    inherited pnlFrmClient: TPanel
      Width = 594
      Height = 239
      ExplicitWidth = 594
      ExplicitHeight = 239
      object pnlCaption: TPanel
        Left = 0
        Top = 0
        Width = 594
        Height = 25
        Align = alTop
        Caption = 'pnlCaption'
        TabOrder = 0
        object lblCaption: TLabel
          Left = 9
          Top = 6
          Width = 48
          Height = 13
          Caption = 'lblCaption'
        end
      end
      object memMain: TDBMemoEh
        Left = 0
        Top = 25
        Width = 594
        Height = 214
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
      Top = 244
      Width = 594
      ExplicitTop = 244
      ExplicitWidth = 594
      inherited bvlFrmBtnsTl: TBevel
        Width = 592
        ExplicitWidth = 592
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 592
        ExplicitWidth = 592
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 592
        ExplicitWidth = 592
        inherited pnlFrmBtnsMain: TPanel
          Left = 493
          ExplicitLeft = 493
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 265
          ExplicitLeft = 265
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 394
          ExplicitLeft = 394
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 125
          ExplicitWidth = 125
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 288
    Width = 604
    ExplicitTop = 288
    ExplicitWidth = 604
    inherited lblStatusBarR: TLabel
      Left = 512
      Height = 14
      ExplicitLeft = 512
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Top = 248
  end
end
