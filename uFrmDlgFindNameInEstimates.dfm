inherited FrmDlgFindNameInEstimates: TFrmDlgFindNameInEstimates
  Caption = 'FrmDlgFindNameInEstimates'
  ClientHeight = 358
  ClientWidth = 672
  ExplicitWidth = 678
  ExplicitHeight = 387
  PixelsPerInch = 96
  TextHeight = 13
  inherited PStatusBar: TPanel
    Top = 342
    Width = 672
    ExplicitTop = 339
    ExplicitWidth = 672
    inherited LbStatusBarRight: TLabel
      Left = 580
      Height = 13
      ExplicitLeft = 580
    end
    inherited LbStatusBarLeft: TLabel
      Height = 13
    end
  end
  inherited PMDIMain: TPanel
    Width = 672
    Height = 342
    ExplicitWidth = 672
    ExplicitHeight = 339
    inherited PMDIClient: TPanel
      Width = 662
      Height = 335
      ExplicitWidth = 662
      ExplicitHeight = 332
      object PTop: TPanel
        Left = 0
        Top = 0
        Width = 662
        Height = 85
        Align = alTop
        Caption = 'PTop'
        TabOrder = 0
        DesignSize = (
          662
          85)
        object ChbInClosedOrders: TCheckBox
          Left = 4
          Top = 42
          Width = 173
          Height = 17
          Caption = #1048#1089#1082#1072#1090#1100' '#1074' '#1079#1072#1082#1088#1099#1090#1099#1093' '#1079#1072#1082#1072#1079#1072#1093
          TabOrder = 0
        end
        object ChbLike: TCheckBox
          Left = 183
          Top = 42
          Width = 114
          Height = 17
          Caption = #1048#1089#1082#1072#1090#1100' '#1087#1086' '#1084#1072#1089#1082#1077
          TabOrder = 1
        end
        object EName: TDBEditEh
          Left = 4
          Top = 15
          Width = 606
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          ControlLabel.Width = 167
          ControlLabel.Height = 13
          ControlLabel.Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077' '#1089#1084#1077#1090#1085#1086#1081' '#1087#1086#1079#1080#1094#1080#1080
          ControlLabel.Visible = True
          DynProps = <>
          EditButtons = <>
          TabOrder = 2
          Text = 'EName'
          Visible = True
        end
        object PButtons: TPanel
          Left = 624
          Top = 1
          Width = 37
          Height = 83
          Align = alRight
          Caption = 'PButtons'
          TabOrder = 3
          ExplicitHeight = 119
          DesignSize = (
            37
            83)
          object BtGo: TSpeedButton
            Left = 5
            Top = 3
            Width = 32
            Height = 32
            Anchors = [akTop, akRight]
          end
          object ImgInfoMAIN: TImage
            Left = 5
            Top = 41
            Width = 20
            Height = 20
            Anchors = [akTop, akRight]
          end
        end
      end
      object PClient: TPanel
        Left = 0
        Top = 85
        Width = 662
        Height = 250
        Align = alClient
        Caption = 'PClient'
        TabOrder = 1
        ExplicitLeft = -12
        ExplicitTop = 64
        ExplicitHeight = 360
        object PgcGrid: TPageControl
          Left = 1
          Top = 1
          Width = 660
          Height = 248
          ActivePage = TsStdItems
          Align = alClient
          TabOrder = 0
          ExplicitLeft = 2
          ExplicitTop = 2
          ExplicitWidth = 689
          ExplicitHeight = 358
          object TsStdItems: TTabSheet
            Caption = #1057#1090#1072#1085#1076#1072#1088#1090#1085#1099#1077' '#1080#1079#1076#1077#1083#1080#1103
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 681
            ExplicitHeight = 330
            object DBGridEh1: TDBGridEh
              Left = 0
              Top = 0
              Width = 652
              Height = 217
              Align = alClient
              DynProps = <>
              Options = [dgEditing, dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
              OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDialogFind, dghExtendVertLines]
              RowDetailPanel.Height = 250
              TabOrder = 0
              object RowDetailData: TRowDetailPanelControlEh
                object E_PPComment: TDBEditEh
                  Left = 299
                  Top = 215
                  Width = 494
                  Height = 21
                  ControlLabel.Width = 70
                  ControlLabel.Height = 13
                  ControlLabel.Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
                  ControlLabel.Visible = True
                  ControlLabelLocation.Position = lpLeftCenterEh
                  DynProps = <>
                  EditButtons = <>
                  TabOrder = 0
                  Text = 'E_PPComment'
                  Visible = False
                end
              end
            end
          end
          object TsOrders: TTabSheet
            Caption = #1047#1072#1082#1072#1079#1099
            ImageIndex = 1
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 681
            ExplicitHeight = 330
            object DBGridEh2: TDBGridEh
              Left = 0
              Top = 0
              Width = 652
              Height = 217
              Align = alClient
              DynProps = <>
              Options = [dgEditing, dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
              OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDialogFind, dghExtendVertLines]
              RowDetailPanel.Height = 250
              TabOrder = 0
              object RowDetailData: TRowDetailPanelControlEh
                object DBEditEh1: TDBEditEh
                  Left = 299
                  Top = 215
                  Width = 494
                  Height = 21
                  ControlLabel.Width = 70
                  ControlLabel.Height = 13
                  ControlLabel.Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
                  ControlLabel.Visible = True
                  ControlLabelLocation.Position = lpLeftCenterEh
                  DynProps = <>
                  EditButtons = <>
                  TabOrder = 0
                  Text = 'E_PPComment'
                  Visible = False
                end
              end
            end
          end
        end
      end
    end
    inherited PDlgPanel: TPanel
      Top = 340
      Width = 662
      Height = 1
      ExplicitTop = 513
      ExplicitWidth = 662
      ExplicitHeight = 1
      inherited BvDlg: TBevel
        Width = 660
        ExplicitWidth = 660
      end
      inherited BvDlgBottom: TBevel
        Top = -3
        Width = 660
        ExplicitTop = -3
        ExplicitWidth = 660
      end
      inherited PDlgMain: TPanel
        Width = 660
        ExplicitWidth = 660
        inherited PDlgBtnForm: TPanel
          Left = 561
          ExplicitLeft = 561
        end
        inherited PDlgChb: TPanel
          Left = 432
          ExplicitLeft = 432
        end
        inherited PDlgBtnR: TPanel
          Left = 333
          ExplicitLeft = 333
        end
        inherited PDlgCenter: TPanel
          Width = 193
          ExplicitWidth = 193
        end
      end
    end
  end
  inherited Timer_AfterStart: TTimer
    Left = 104
    Top = 520
  end
end
