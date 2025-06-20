object FrmBasicMdi: TFrmBasicMdi
  Left = 0
  Top = 0
  Caption = 'FrmBasicMdi'
  ClientHeight = 410
  ClientWidth = 848
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnActivate = FormActivate
  OnCanResize = FormCanResize
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object PMDIMain: TPanel
    Left = 0
    Top = 0
    Width = 848
    Height = 394
    Align = alClient
    AutoSize = True
    Padding.Left = 4
    Padding.Top = 4
    Padding.Right = 4
    TabOrder = 0
    object PMDIClient: TPanel
      Left = 5
      Top = 5
      Width = 838
      Height = 345
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      ExplicitWidth = 842
      ExplicitHeight = 346
    end
    object PDlgPanel: TPanel
      Left = 5
      Top = 350
      Width = 838
      Height = 43
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alBottom
      BevelEdges = []
      BevelOuter = bvNone
      BorderWidth = 1
      Ctl3D = True
      ParentCtl3D = False
      TabOrder = 1
      object BvDlg: TBevel
        Left = 1
        Top = 1
        Width = 836
        Height = 3
        Align = alTop
        ExplicitWidth = 782
      end
      object BvDlgBottom: TBevel
        Left = 1
        Top = 39
        Width = 836
        Height = 3
        Align = alBottom
        ExplicitLeft = 7
        ExplicitTop = 104
        ExplicitWidth = 770
      end
      object PDlgMain: TPanel
        Left = 1
        Top = 4
        Width = 836
        Height = 35
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alClient
        BevelEdges = []
        BevelOuter = bvNone
        Ctl3D = False
        Padding.Top = 4
        Padding.Bottom = 4
        ParentCtl3D = False
        TabOrder = 0
        object PDlgBtnForm: TPanel
          Tag = -1
          Left = 737
          Top = 4
          Width = 99
          Height = 27
          Align = alRight
          Caption = 'PDlgBtnForm'
          TabOrder = 0
          ExplicitLeft = 741
        end
        object PDlgChb: TPanel
          Tag = -2
          Left = 509
          Top = 4
          Width = 129
          Height = 27
          Align = alRight
          Caption = 'PDlgChb'
          TabOrder = 1
          DesignSize = (
            129
            27)
          object ChbDlgNoClose: TCheckBox
            Left = 6
            Top = -60
            Width = 121
            Height = 16
            Anchors = [akRight, akBottom]
            Caption = #1053#1077' '#1079#1072#1082#1088#1099#1074#1072#1090#1100' '#1086#1082#1085#1086
            TabOrder = 0
          end
        end
        object PDlgBtnR: TPanel
          Tag = -3
          Left = 638
          Top = 4
          Width = 99
          Height = 27
          Align = alRight
          Caption = 'PDlgBtnR'
          TabOrder = 2
          ExplicitLeft = 642
        end
        object PDlgInfo: TPanel
          Tag = 1
          Left = 0
          Top = 4
          Width = 41
          Height = 27
          Align = alLeft
          Caption = 'PDlgInfo'
          TabOrder = 3
          object ImgFormInfo: TImage
            Left = 8
            Top = -1
            Width = 20
            Height = 20
          end
        end
        object PDlgBtnL: TPanel
          Tag = 2
          Left = 41
          Top = 4
          Width = 99
          Height = 27
          Align = alLeft
          Caption = 'PDlgBtnL'
          TabOrder = 4
        end
        object PDlgCenter: TPanel
          Left = 140
          Top = 4
          Width = 369
          Height = 27
          Align = alClient
          Caption = 'PDlgCenter'
          TabOrder = 5
          ExplicitWidth = 373
        end
      end
    end
  end
  object PStatusBar: TPanel
    Left = 0
    Top = 394
    Width = 848
    Height = 16
    Align = alBottom
    Color = cl3DLight
    Padding.Left = 8
    Padding.Right = 8
    ParentBackground = False
    TabOrder = 1
    ExplicitTop = 395
    ExplicitWidth = 852
    object LbStatusBarRight: TLabel
      Left = 760
      Top = 1
      Width = 83
      Height = 13
      Align = alRight
      Caption = 'LbStatusBarRight'
    end
    object LbStatusBarLeft: TLabel
      Left = 9
      Top = 1
      Width = 77
      Height = 13
      Align = alLeft
      Caption = 'LbStatusBarLeft'
    end
  end
  object Timer_AfterStart: TTimer
    Interval = 1
    Left = 8
    Top = 96
  end
end
