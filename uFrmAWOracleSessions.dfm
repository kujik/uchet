inherited FrmAWOracleSessions: TFrmAWOracleSessions
  Caption = 'FrmAWOracleSessions'
  ExplicitWidth = 320
  ExplicitHeight = 240
  PixelsPerInch = 96
  TextHeight = 13
  inherited PMDIMain: TPanel
    Height = 536
    ExplicitHeight = 536
    inherited PMDIClient: TPanel
      Height = 529
      ExplicitHeight = 529
      inherited PBottom: TPanel
        Top = 523
        ExplicitTop = 523
      end
      inherited PLeft: TPanel
        Width = 193
        Height = 514
        ExplicitWidth = 193
        ExplicitHeight = 514
        object BtCloseModules: TBitBtn
          Left = 6
          Top = 483
          Width = 181
          Height = 25
          Anchors = [akLeft, akRight, akBottom]
          Caption = 'BtCloseModules'
          TabOrder = 0
          OnClick = BtCloseModulesClick
        end
        object NeIdle: TDBNumberEditEh
          Left = 4
          Top = 456
          Width = 97
          Height = 21
          ControlLabel.Width = 103
          ControlLabel.Height = 13
          ControlLabel.Caption = #1042#1088#1077#1084#1103' '#1087#1088#1086#1089#1090#1086#1103', '#1084#1080#1085'.'
          ControlLabel.Visible = True
          Anchors = [akLeft, akBottom]
          DecimalPlaces = 0
          DynProps = <>
          EditButtons = <>
          MaxValue = 9999.000000000000000000
          MinValue = 5.000000000000000000
          TabOrder = 1
          Visible = True
        end
      end
      inherited PGrid1: TPanel
        Left = 193
        Width = 592
        Height = 514
        ExplicitLeft = 193
        ExplicitWidth = 592
        ExplicitHeight = 514
        inherited Frg1: TFrDBGridEh
          Width = 590
          Height = 512
          ExplicitWidth = 590
          ExplicitHeight = 512
          inherited PGrid: TPanel
            Width = 580
            Height = 458
            ExplicitWidth = 580
            ExplicitHeight = 458
            inherited DbGridEh1: TDBGridEh
              Width = 578
              Height = 435
            end
            inherited PStatus: TPanel
              Top = 436
              Width = 578
              ExplicitTop = 436
              ExplicitWidth = 578
            end
          end
          inherited PLeft: TPanel
            Height = 458
            ExplicitHeight = 458
          end
          inherited PTop: TPanel
            Width = 590
            ExplicitWidth = 590
          end
          inherited PContainer: TPanel
            Width = 590
            ExplicitWidth = 590
          end
          inherited PBottom: TPanel
            Top = 512
            Width = 590
            ExplicitTop = 512
            ExplicitWidth = 590
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
      inherited PFrg2: TPanel
        Top = 528
        Height = 1
        ExplicitTop = 528
        ExplicitHeight = 1
        inherited Frg2: TFrDBGridEh
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
      inherited PRight: TPanel
        Height = 514
        ExplicitHeight = 514
      end
    end
    inherited PDlgPanel: TPanel
      Top = 534
      Height = 1
      ExplicitTop = 534
      ExplicitHeight = 1
      inherited BvDlgBottom: TBevel
        Top = -3
        ExplicitTop = -3
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 536
    Height = 1
    ExplicitTop = 536
    ExplicitHeight = 1
  end
  object Timer1: TTimer
    Interval = 5000
    OnTimer = Timer1Timer
    Left = 630
    Top = 281
  end
end
