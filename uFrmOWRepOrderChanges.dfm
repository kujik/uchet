inherited FrmOWRepOrderChanges: TFrmOWRepOrderChanges
  Caption = 'FrmOWRepOrderChanges'
  ClientHeight = 560
  ClientWidth = 700
  ExplicitWidth = 716
  ExplicitHeight = 599
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 700
    Height = 544
    ExplicitWidth = 700
    ExplicitHeight = 544
    inherited pnlFrmClient: TPanel
      Width = 690
      Height = 495
      ExplicitWidth = 690
      ExplicitHeight = 495
      object pnlTop: TPanel
        Left = 0
        Top = 0
        Width = 690
        Height = 89
        Align = alTop
        TabOrder = 0
        object lblOrder: TLabel
          Left = 12
          Top = 8
          Width = 51
          Height = 13
          Caption = 'lblOrder'
        end
        object lblDateTime: TLabel
          Left = 12
          Top = 27
          Width = 63
          Height = 13
          Caption = 'lblDateTime'
        end
        object lblUser: TLabel
          Left = 12
          Top = 46
          Width = 44
          Height = 13
          Caption = 'lblUser'
        end
        object lblOperation: TLabel
          Left = 12
          Top = 65
          Width = 68
          Height = 13
          Caption = 'lblOperation'
        end
      end
      object mmoTitle: TDBMemoEh
        Left = 0
        Top = 89
        Width = 690
        Height = 200
        Align = alTop
        ScrollBars = ssVertical
        TabOrder = 1
      end
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
      object mmoItems: TDBMemoEh
        Left = 0
        Top = 294
        Width = 690
        Height = 201
        Align = alClient
        ScrollBars = ssVertical
        TabOrder = 2
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 544
    Width = 700
    ExplicitTop = 544
    ExplicitWidth = 700
    inherited lblStatusBarR: TLabel
      Left = 627
      ExplicitLeft = 627
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 4
    Top = 132
  end
end
