inherited FrmXDedtMemo: TFrmXDedtMemo
  Caption = 'FrmXDedtMemo'
  ClientHeight = 301
  ClientWidth = 592
  ExplicitWidth = 604
  ExplicitHeight = 339
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 592
    Height = 285
    ExplicitWidth = 588
    ExplicitHeight = 284
    inherited pnlFrmClient: TPanel
      Width = 582
      Height = 236
      ExplicitWidth = 578
      ExplicitHeight = 235
      object pnlCaption: TPanel
        Left = 0
        Top = 0
        Width = 582
        Height = 25
        Align = alTop
        Caption = 'pnlCaption'
        TabOrder = 0
        ExplicitWidth = 578
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
        Width = 582
        Height = 211
        Lines.Strings = (
          'mem_Main')
        Align = alClient
        AutoSize = False
        DynProps = <>
        EditButtons = <>
        TabOrder = 1
        Visible = True
        WantReturns = True
        ExplicitWidth = 578
        ExplicitHeight = 210
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 241
      Width = 582
      ExplicitTop = 240
      ExplicitWidth = 578
      inherited bvlFrmBtnsTl: TBevel
        Width = 580
        ExplicitWidth = 592
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 580
        ExplicitWidth = 592
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 580
        ExplicitWidth = 576
        inherited pnlFrmBtnsMain: TPanel
          Left = 481
          ExplicitLeft = 477
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 253
          ExplicitLeft = 249
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 382
          ExplicitLeft = 378
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 113
          ExplicitWidth = 109
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 285
    Width = 592
    ExplicitTop = 284
    ExplicitWidth = 588
    inherited lblStatusBarR: TLabel
      Left = 519
      Height = 14
      ExplicitLeft = 519
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Top = 248
  end
end
