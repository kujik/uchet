inherited FrmOWrepStdItemsGroupCheck: TFrmOWrepStdItemsGroupCheck
  Caption = 'FrmOWrepStdItemsGroupCheck'
  ClientHeight = 560
  ClientWidth = 700
  ExplicitWidth = 712
  ExplicitHeight = 598
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 700
    Height = 544
    ExplicitWidth = 696
    ExplicitHeight = 543
    inherited pnlFrmClient: TPanel
      Width = 690
      Height = 495
      ExplicitWidth = 686
      ExplicitHeight = 494
      object pnlTop: TPanel
        Left = 0
        Top = 0
        Width = 690
        Height = 130
        Align = alTop
        TabOrder = 0
        ExplicitWidth = 686
        object lblCapt1: TLabel
          Left = 12
          Top = 8
          Width = 39
          Height = 13
          Caption = 'lblCapt1'
        end
        object lblCapt2: TLabel
          Left = 12
          Top = 27
          Width = 46
          Height = 13
          Caption = 'lblCapt2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblDateTime: TLabel
          Left = 12
          Top = 55
          Width = 55
          Height = 13
          Caption = 'lblDateTime'
        end
        object lblUser: TLabel
          Left = 12
          Top = 74
          Width = 32
          Height = 13
          Caption = 'lblUser'
        end
        object lblWarnings: TLabel
          Left = 12
          Top = 93
          Width = 55
          Height = 13
          Caption = 'lblWarnings'
        end
      end
      object mmoReport: TDBMemoEh
        Left = 0
        Top = 130
        Width = 690
        Height = 365
        ScrollBars = ssVertical
        Align = alClient
        AutoSize = False
        DynProps = <>
        EditButtons = <>
        TabOrder = 1
        Visible = True
        WantReturns = True
        ExplicitWidth = 686
        ExplicitHeight = 364
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 500
      Width = 690
      ExplicitTop = 499
      ExplicitWidth = 686
      inherited bvlFrmBtnsTl: TBevel
        Width = 688
        ExplicitWidth = 688
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 688
        ExplicitWidth = 688
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 688
        ExplicitWidth = 684
        inherited pnlFrmBtnsMain: TPanel
          Left = 361
          ExplicitLeft = 357
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 460
          ExplicitLeft = 456
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 589
          ExplicitLeft = 585
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 221
          ExplicitWidth = 217
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 544
    Width = 700
    ExplicitTop = 543
    ExplicitWidth = 696
    inherited lblStatusBarR: TLabel
      Left = 627
      Height = 14
      ExplicitLeft = 627
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 4
    Top = 132
  end
end
