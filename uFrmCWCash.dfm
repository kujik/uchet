inherited FrmCWCash: TFrmCWCash
  Caption = 'FrmCWCash'
  ClientHeight = 646
  ClientWidth = 1012
  OnResize = FormResize
  ExplicitWidth = 1028
  ExplicitHeight = 685
  PixelsPerInch = 96
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 1012
    Height = 630
    ExplicitWidth = 1012
    ExplicitHeight = 630
    inherited PMDIClient: TPanel
      Width = 1002
      Height = 581
      ExplicitWidth = 1002
      ExplicitHeight = 581
      object PTop: TPanel
        Left = 0
        Top = 0
        Width = 1002
        Height = 49
        Align = alTop
        Caption = 'PTop'
        TabOrder = 0
        object BtRefresh: TSpeedButton
          Left = 9
          Top = 11
          Width = 32
          Height = 32
          OnClick = BtRefreshClick
        end
        object Lb_Caption: TLabel
          Left = 47
          Top = 20
          Width = 261
          Height = 16
          Caption = #1046#1091#1088#1085#1072#1083' '#1050#1072#1089#1089#1099'1 '#1089' 01.01.2022 '#1087#1086' 29.09.2022'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
      end
      object PGalka: TPanel
        Left = 0
        Top = 49
        Width = 1002
        Height = 40
        Align = alTop
        Caption = 'PGalka'
        TabOrder = 1
        object LbCaptL: TLabel
          Left = 12
          Top = 21
          Width = 46
          Height = 13
          Caption = #1055#1088#1080#1093#1086#1076#1099
        end
        object LbCaptR: TLabel
          Left = 512
          Top = 21
          Width = 44
          Height = 13
          Caption = #1056#1072#1089#1093#1086#1076#1099
        end
        object ChbViewAll: TCheckBox
          Left = 12
          Top = 0
          Width = 399
          Height = 17
          Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1087#1077#1088#1077#1084#1077#1097#1077#1085#1080#1077' '#1076#1077#1085#1077#1078#1085#1099#1093' '#1089#1088#1077#1076#1089#1090#1074
          TabOrder = 0
          OnClick = ChbViewAllClick
        end
      end
      object PItog1: TPanel
        Left = 0
        Top = 485
        Width = 1002
        Height = 35
        Align = alBottom
        Caption = 'PItog1'
        TabOrder = 2
        object DBEditEh1: TDBEditEh
          Left = 96
          Top = 4
          Width = 121
          Height = 21
          Alignment = taRightJustify
          ControlLabel.Width = 31
          ControlLabel.Height = 13
          ControlLabel.Caption = #1057#1091#1084#1084#1072
          ControlLabel.Visible = True
          ControlLabelLocation.Position = lpLeftCenterEh
          DynProps = <>
          EditButtons = <>
          ReadOnly = True
          TabOrder = 0
          Text = 'DBEditEh1'
          Visible = True
        end
      end
      object PItog2: TPanel
        Left = 0
        Top = 520
        Width = 1002
        Height = 61
        Align = alBottom
        Caption = 'PItog2'
        TabOrder = 3
        object DBEditEh2: TDBEditEh
          Left = 96
          Top = 6
          Width = 121
          Height = 21
          Alignment = taRightJustify
          ControlLabel.Width = 31
          ControlLabel.Height = 13
          ControlLabel.Caption = #1057#1091#1084#1084#1072
          ControlLabel.Visible = True
          ControlLabelLocation.Position = lpLeftCenterEh
          DynProps = <>
          EditButtons = <>
          ReadOnly = True
          TabOrder = 0
          Text = 'DBEditEh1'
          Visible = True
        end
        object DBEditEh3: TDBEditEh
          Left = 328
          Top = 6
          Width = 121
          Height = 21
          Alignment = taRightJustify
          ControlLabel.Width = 35
          ControlLabel.Height = 13
          ControlLabel.Caption = #1050#1072#1089#1089#1072'1'
          ControlLabel.Visible = True
          ControlLabelLocation.Position = lpLeftCenterEh
          DynProps = <>
          EditButtons = <>
          ReadOnly = True
          TabOrder = 1
          Text = 'DBEditEh1'
          Visible = True
        end
        object DBEditEh4: TDBEditEh
          Left = 568
          Top = 6
          Width = 121
          Height = 21
          Alignment = taRightJustify
          ControlLabel.Width = 35
          ControlLabel.Height = 13
          ControlLabel.Caption = #1050#1072#1089#1089#1072'2'
          ControlLabel.Visible = True
          ControlLabelLocation.Position = lpLeftCenterEh
          DynProps = <>
          EditButtons = <>
          ReadOnly = True
          TabOrder = 2
          Text = 'DBEditEh1'
          Visible = True
        end
        object DBEditEh5: TDBEditEh
          Left = 808
          Top = 6
          Width = 121
          Height = 21
          Alignment = taRightJustify
          ControlLabel.Width = 43
          ControlLabel.Height = 13
          ControlLabel.Caption = #1044#1077#1087#1086#1079#1080#1090
          ControlLabel.Visible = True
          ControlLabelLocation.Position = lpLeftCenterEh
          DynProps = <>
          EditButtons = <>
          ReadOnly = True
          TabOrder = 3
          Text = 'DBEditEh1'
          Visible = True
        end
        object DBEditEh6: TDBEditEh
          Left = 96
          Top = 33
          Width = 121
          Height = 21
          Alignment = taRightJustify
          ControlLabel.Width = 88
          ControlLabel.Height = 13
          ControlLabel.Caption = #1055#1088#1080#1093#1086#1076#1099' '#1079#1072' '#1076#1077#1085#1100
          ControlLabel.Visible = True
          ControlLabelLocation.Position = lpLeftCenterEh
          DynProps = <>
          EditButtons = <>
          ReadOnly = True
          TabOrder = 4
          Text = 'DBEditEh1'
          Visible = True
        end
        object DBEditEh7: TDBEditEh
          Left = 328
          Top = 33
          Width = 121
          Height = 21
          Alignment = taRightJustify
          ControlLabel.Width = 86
          ControlLabel.Height = 13
          ControlLabel.Caption = #1056#1072#1089#1093#1086#1076#1099' '#1079#1072' '#1076#1077#1085#1100
          ControlLabel.Visible = True
          ControlLabelLocation.Position = lpLeftCenterEh
          DynProps = <>
          EditButtons = <>
          ReadOnly = True
          TabOrder = 5
          Text = 'DBEditEh1'
          Visible = True
        end
      end
      inline Frg1: TFrDBGridEh
        Left = 0
        Top = 89
        Width = 500
        Height = 396
        Align = alLeft
        TabOrder = 4
        ExplicitTop = 89
        ExplicitWidth = 500
        ExplicitHeight = 396
        inherited PGrid: TPanel
          Width = 490
          Height = 342
          ExplicitWidth = 490
          ExplicitHeight = 342
          inherited DbGridEh1: TDBGridEh
            Width = 488
            Height = 319
            Columns = <
              item
                CellButtons = <>
                DynProps = <>
                EditButtons = <>
                FieldName = 'iii'
                Footers = <>
              end>
            inherited RowDetailData: TRowDetailPanelControlEh
              ExplicitLeft = 30
              ExplicitTop = 35
              ExplicitWidth = 46
              ExplicitHeight = 120
              inherited PRowDetailPanel: TPanel
                Width = 44
                ExplicitWidth = 44
                ExplicitHeight = 118
              end
            end
          end
          inherited PStatus: TPanel
            Top = 320
            Width = 488
            ExplicitTop = 320
            ExplicitWidth = 488
          end
        end
        inherited PLeft: TPanel
          Height = 342
          ExplicitHeight = 342
        end
        inherited PTop: TPanel
          Width = 500
          ExplicitWidth = 500
        end
        inherited PContainer: TPanel
          Width = 500
          ExplicitWidth = 500
        end
        inherited PBottom: TPanel
          Top = 396
          Width = 500
          ExplicitTop = 396
          ExplicitWidth = 500
        end
        inherited PrintDBGridEh1: TPrintDBGridEh
          BeforeGridText_Data = {
            7B5C727466315C616E73695C616E7369637067313235315C64656666305C6465
            666C616E67313034397B5C666F6E7474626C7B5C66305C666E696C5C66636861
            72736574323034205461686F6D613B7D7B5C66315C666E696C5C666368617273
            657430205461686F6D613B7D7D0D0A5C766965776B696E64345C7563315C7061
            72645C66305C667331365C2763665C2766305C2765655C2765355C2765615C27
            66323A20255B50726F656B745D5C7061720D0A5C2763665C2765355C2766305C
            2765385C2765655C276534205C276631205C6C616E67313033335C6631202025
            5B4474315D205C6C616E67313034395C66305C2765665C2765655C6C616E6731
            3033335C66312020255B4474325D5C6C616E67313034395C66305C7061720D0A
            5C7061720D0A7D0D0A00}
        end
      end
      inline Frg2: TFrDBGridEh
        Left = 500
        Top = 89
        Width = 502
        Height = 396
        Align = alClient
        TabOrder = 5
        ExplicitLeft = 500
        ExplicitTop = 89
        ExplicitWidth = 502
        ExplicitHeight = 396
        inherited PGrid: TPanel
          Width = 492
          Height = 342
          ExplicitWidth = 492
          ExplicitHeight = 342
          inherited DbGridEh1: TDBGridEh
            Width = 490
            Height = 319
            Columns = <
              item
                CellButtons = <>
                DynProps = <>
                EditButtons = <>
                FieldName = 'iii'
                Footers = <>
              end>
            inherited RowDetailData: TRowDetailPanelControlEh
              ExplicitLeft = 30
              ExplicitTop = 35
              ExplicitWidth = 46
              ExplicitHeight = 120
              inherited PRowDetailPanel: TPanel
                Width = 44
                ExplicitWidth = 44
                ExplicitHeight = 118
              end
            end
          end
          inherited PStatus: TPanel
            Top = 320
            Width = 490
            ExplicitTop = 320
            ExplicitWidth = 490
          end
        end
        inherited PLeft: TPanel
          Height = 342
          ExplicitHeight = 342
        end
        inherited PTop: TPanel
          Width = 502
          ExplicitWidth = 502
        end
        inherited PContainer: TPanel
          Width = 502
          ExplicitWidth = 502
        end
        inherited PBottom: TPanel
          Top = 396
          Width = 502
          ExplicitTop = 396
          ExplicitWidth = 502
        end
        inherited PrintDBGridEh1: TPrintDBGridEh
          BeforeGridText_Data = {
            7B5C727466315C616E73695C616E7369637067313235315C64656666305C6465
            666C616E67313034397B5C666F6E7474626C7B5C66305C666E696C5C66636861
            72736574323034205461686F6D613B7D7B5C66315C666E696C5C666368617273
            657430205461686F6D613B7D7D0D0A5C766965776B696E64345C7563315C7061
            72645C66305C667331365C2763665C2766305C2765655C2765355C2765615C27
            66323A20255B50726F656B745D5C7061720D0A5C2763665C2765355C2766305C
            2765385C2765655C276534205C276631205C6C616E67313033335C6631202025
            5B4474315D205C6C616E67313034395C66305C2765665C2765655C6C616E6731
            3033335C66312020255B4474325D5C6C616E67313034395C66305C7061720D0A
            5C7061720D0A7D0D0A00}
        end
      end
    end
    inherited PDlgPanel: TPanel
      Top = 586
      Width = 1002
      ExplicitTop = 586
      ExplicitWidth = 1002
      inherited BvDlg: TBevel
        Width = 1000
        ExplicitWidth = 1000
      end
      inherited BvDlgBottom: TBevel
        Width = 1000
        ExplicitWidth = 1000
      end
      inherited PDlgMain: TPanel
        Width = 1000
        ExplicitWidth = 1000
        inherited PDlgBtnForm: TPanel
          Left = 901
          ExplicitLeft = 901
        end
        inherited PDlgChb: TPanel
          Left = 673
          ExplicitLeft = 673
        end
        inherited PDlgBtnR: TPanel
          Left = 802
          ExplicitLeft = 802
        end
        inherited PDlgCenter: TPanel
          Width = 533
          ExplicitWidth = 533
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 630
    Width = 1012
    ExplicitTop = 630
    ExplicitWidth = 1012
    inherited LbStatusBarRight: TLabel
      Left = 920
      Height = 14
      ExplicitLeft = 920
    end
    inherited LbStatusBarLeft: TLabel
      Height = 14
    end
  end
end
