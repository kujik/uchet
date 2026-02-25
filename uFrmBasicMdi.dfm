object FrmBasicMdi: TFrmBasicMdi
  Left = 0
  Top = 0
  Caption = 'FrmBasicMdi'
  ClientHeight = 97
  ClientWidth = 266
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
  object pnlFrmMain: TPanel
    Left = 0
    Top = 0
    Width = 266
    Height = 81
    Align = alClient
    AutoSize = True
    Padding.Left = 4
    Padding.Top = 4
    Padding.Right = 4
    TabOrder = 0
    ExplicitWidth = 270
    ExplicitHeight = 82
    object pnlFrmClient: TPanel
      Left = 5
      Top = 5
      Width = 260
      Height = 33
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      ExplicitWidth = 256
      ExplicitHeight = 32
    end
    object pnlFrmBtns: TPanel
      Left = 5
      Top = 38
      Width = 260
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
      object bvlFrmBtnsTl: TBevel
        Left = 1
        Top = 1
        Width = 258
        Height = 3
        Align = alTop
        ExplicitWidth = 782
      end
      object bvlFrmBtnsB: TBevel
        Left = 1
        Top = 39
        Width = 258
        Height = 3
        Align = alBottom
        ExplicitLeft = 7
        ExplicitTop = 104
        ExplicitWidth = 770
      end
      object pnlFrmBtnsContainer: TPanel
        Left = 1
        Top = 4
        Width = 258
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
        object pnlFrmBtnsMain: TPanel
          Tag = -1
          Left = 159
          Top = 4
          Width = 99
          Height = 27
          Align = alRight
          Caption = 'pnlFrmBtnsMain'
          TabOrder = 0
          ExplicitLeft = 155
        end
        object pnlFrmBtnsChb: TPanel
          Tag = -2
          Left = -69
          Top = 4
          Width = 129
          Height = 27
          Align = alRight
          Caption = 'pnlFrmBtnsChb'
          TabOrder = 1
          DesignSize = (
            129
            27)
          object chbNoclose: TCheckBox
            Left = 6
            Top = -60
            Width = 121
            Height = 16
            Anchors = [akRight, akBottom]
            Caption = #1053#1077' '#1079#1072#1082#1088#1099#1074#1072#1090#1100' '#1086#1082#1085#1086
            TabOrder = 0
          end
        end
        object pnlFrmBtnsR: TPanel
          Tag = -3
          Left = 56
          Top = 4
          Width = 99
          Height = 27
          Align = alRight
          Caption = 'pnlFrmBtnsR'
          TabOrder = 2
        end
        object pnlFrmBtnsInfo: TPanel
          Tag = 1
          Left = 0
          Top = 4
          Width = 41
          Height = 27
          Align = alLeft
          Caption = 'pnlFrmBtnsInfo'
          TabOrder = 3
          object imgFrmInfo: TImage
            Left = 8
            Top = -1
            Width = 20
            Height = 20
          end
        end
        object pnlFrmBtnsL: TPanel
          Tag = 2
          Left = 41
          Top = 4
          Width = 99
          Height = 27
          Align = alLeft
          Caption = 'pnlFrmBtnsL'
          TabOrder = 4
        end
        object pnlFrmBtnsC: TPanel
          Left = 140
          Top = 4
          Width = 11
          Height = 27
          Align = alClient
          Caption = 'pnlFrmBtnsC'
          TabOrder = 5
        end
      end
    end
  end
  object pnlStatusBar: TPanel
    Left = 0
    Top = 81
    Width = 266
    Height = 16
    Align = alBottom
    Color = cl3DLight
    Padding.Left = 8
    Padding.Right = 8
    ParentBackground = False
    TabOrder = 1
    object lblStatusBarR: TLabel
      Left = 197
      Top = 1
      Width = 64
      Height = 13
      Align = alRight
      Caption = 'lblStatusBarR'
    end
    object lblStatusBarL: TLabel
      Left = 9
      Top = 1
      Width = 62
      Height = 13
      Align = alLeft
      Caption = 'lblStatusBarL'
    end
  end
  object tmrAfterCreate: TTimer
    Interval = 1
    Left = 8
    Top = 96
  end
end
