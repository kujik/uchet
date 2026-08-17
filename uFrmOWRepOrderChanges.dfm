inherited FrmOWRepOrderChanges: TFrmOWRepOrderChanges
  Caption = 'FrmOWRepOrderChanges'
  ClientHeight = 559
  ClientWidth = 696
  ExplicitWidth = 712
  ExplicitHeight = 598
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 696
    Height = 543
    ExplicitWidth = 696
    ExplicitHeight = 543
    inherited pnlFrmClient: TPanel
      Width = 690
      Height = 495
      ExplicitWidth = 686
      ExplicitHeight = 494
      object Splitter1: TSplitter
        Left = 0
        Top = 289
        Width = 690
        Height = 5
        Cursor = crVSplit
        Align = alTop
        ExplicitTop = 288
        ExplicitWidth = 700
      end
      object pnlTop: TPanel
        Left = 0
        Top = 0
        Width = 690
        Height = 89
        Align = alTop
        TabOrder = 0
        ExplicitWidth = 686
        object lblOrder: TLabel
          Left = 12
          Top = 8
          Width = 38
          Height = 13
          Caption = 'lblOrder'
        end
        object lblDateTime: TLabel
          Left = 12
          Top = 27
          Width = 55
          Height = 13
          Caption = 'lblDateTime'
        end
        object lblUser: TLabel
          Left = 12
          Top = 46
          Width = 32
          Height = 13
          Caption = 'lblUser'
        end
        object lblOperation: TLabel
          Left = 12
          Top = 65
          Width = 58
          Height = 13
          Caption = 'lblOperation'
        end
      end
      object mmoTitle: TDBMemoEh
        Left = 0
        Top = 89
        Width = 690
        Height = 200
        ScrollBars = ssVertical
        Align = alTop
        AutoSize = False
        DynProps = <>
        EditButtons = <>
        TabOrder = 1
        Visible = True
        WantReturns = True
        ExplicitWidth = 686
      end
      object mmoItems: TDBMemoEh
        Left = 0
        Top = 294
        Width = 690
        Height = 201
        ScrollBars = ssVertical
        Align = alClient
        AutoSize = False
        DynProps = <>
        EditButtons = <>
        TabOrder = 2
        Visible = True
        WantReturns = True
        ExplicitWidth = 686
        ExplicitHeight = 200
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 500
      Width = 690
      ExplicitTop = 500
      ExplicitWidth = 690
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 543
    Width = 696
    ExplicitTop = 543
    ExplicitWidth = 696
    inherited lblStatusBarR: TLabel
      Left = 627
      Height = 13
      ExplicitLeft = 627
    end
    inherited lblStatusBarL: TLabel
      Height = 13
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 4
    Top = 132
  end
end
