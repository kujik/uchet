inherited FrmOWPlannedOrder: TFrmOWPlannedOrder
  Caption = 'FrmOWPlannedOrder'
  ClientWidth = 1076
  ExplicitWidth = 1092
  PixelsPerInch = 96
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 1076
    ExplicitWidth = 1076
    inherited PMDIClient: TPanel
      Width = 1066
      ExplicitWidth = 1066
      object Bevel1: TBevel
        Left = 0
        Top = 153
        Width = 1066
        Height = 3
        Align = alTop
      end
      object PTop: TPanel
        Left = 0
        Top = 0
        Width = 1066
        Height = 153
        Align = alTop
        Caption = 'PTop'
        TabOrder = 0
        object PTopFields: TPanel
          Left = 1
          Top = 1
          Width = 440
          Height = 151
          Align = alLeft
          Caption = 'PTopFields'
          TabOrder = 0
          object Ne_num: TDBNumberEditEh
            Left = 58
            Top = 14
            Width = 90
            Height = 21
            ControlLabel.Width = 45
            ControlLabel.Height = 13
            ControlLabel.Caption = #1047#1072#1082#1072#1079' '#8470
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 0
            Visible = True
          end
          object De_dt: TDBDateTimeEditEh
            Left = 165
            Top = 14
            Width = 90
            Height = 21
            ControlLabel.Width = 12
            ControlLabel.Height = 13
            ControlLabel.Caption = #1086#1090
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            Kind = dtkDateEh
            TabOrder = 1
            Visible = True
          end
          object De_dt_change: TDBDateTimeEditEh
            Left = 309
            Top = 14
            Width = 115
            Height = 21
            ControlLabel.Width = 41
            ControlLabel.Height = 13
            ControlLabel.Caption = #1080#1079#1084#1077#1085#1077#1085
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            Kind = dtkDateTimeEh
            TabOrder = 2
            Visible = True
          end
          object E_ProjectName: TDBEditEh
            Left = 57
            Top = 41
            Width = 369
            Height = 21
            ControlLabel.Width = 37
            ControlLabel.Height = 13
            ControlLabel.Caption = #1055#1088#1086#1077#1082#1090
            ControlLabel.Visible = True
            ControlLabelLocation.Spacing = 10
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 3
            Text = 'E_ProjectName'
            Visible = True
          end
          object Chb_is_plannedorder: TDBCheckBoxEh
            Left = 268
            Top = 95
            Width = 76
            Height = 17
            Caption = #1055#1083#1072#1085#1086#1074#1099#1081
            DynProps = <>
            TabOrder = 4
          end
          object Chb_is_preorder: TDBCheckBoxEh
            Left = 350
            Top = 95
            Width = 76
            Height = 17
            Caption = #1055#1088#1077#1076#1079#1072#1082#1072#1079
            DynProps = <>
            TabOrder = 5
          end
          object De_dt_start: TDBDateTimeEditEh
            Left = 57
            Top = 93
            Width = 90
            Height = 21
            ControlLabel.Width = 46
            ControlLabel.Height = 13
            ControlLabel.Caption = #1055#1077#1088#1080#1086#1076' '#1089
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            Kind = dtkDateEh
            TabOrder = 6
            Visible = True
          end
          object De_dt_end: TDBDateTimeEditEh
            Left = 165
            Top = 93
            Width = 90
            Height = 21
            ControlLabel.Width = 12
            ControlLabel.Height = 13
            ControlLabel.Caption = #1087#1086
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            Kind = dtkDateEh
            TabOrder = 7
            Visible = True
          end
          object E_UserName: TDBEditEh
            Left = 57
            Top = 120
            Width = 198
            Height = 21
            ControlLabel.Width = 53
            ControlLabel.Height = 13
            ControlLabel.Caption = #1052#1077#1085#1077#1076#1078#1077#1088
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 8
            Text = 'E_username'
            Visible = True
          end
          object E_TemplateName: TDBEditEh
            Left = 58
            Top = 66
            Width = 197
            Height = 21
            ControlLabel.Width = 44
            ControlLabel.Height = 26
            ControlLabel.Caption = #1064#1072#1073#1083#1086#1085'/'#13#10#1060#1086#1088#1084#1072#1090
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 9
            Text = 'E_project'
            Visible = True
          end
          object E_FormatName: TDBEditEh
            Left = 268
            Top = 68
            Width = 160
            Height = 21
            ControlLabel.Caption = #1060#1086#1088#1084#1072#1090
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 10
            Text = 'E_project'
            Visible = True
          end
        end
        object PTopFiles: TPanel
          Left = 765
          Top = 1
          Width = 300
          Height = 151
          Align = alRight
          Caption = 'PTopFiles'
          TabOrder = 1
          object LbCaptionFiles: TLabel
            Left = 6
            Top = 0
            Width = 118
            Height = 13
            Caption = #1055#1088#1080#1082#1088#1077#1087#1083#1077#1085#1085#1099#1077' '#1092#1072#1081#1083#1099
          end
          inline FrgFiles: TFrDBGridEh
            Left = 1
            Top = 1
            Width = 298
            Height = 149
            Margins.Left = 4
            Margins.Top = 20
            Margins.Right = 4
            Margins.Bottom = 4
            Align = alClient
            TabOrder = 0
            ExplicitLeft = 1
            ExplicitTop = 1
            ExplicitWidth = 298
            ExplicitHeight = 149
            inherited PGrid: TPanel
              Width = 288
              Height = 95
              ExplicitWidth = 288
              ExplicitHeight = 95
              inherited DbGridEh1: TDBGridEh
                Width = 286
                Height = 72
                inherited RowDetailData: TRowDetailPanelControlEh
                  ExplicitLeft = 30
                  ExplicitTop = 35
                  ExplicitWidth = 32
                  ExplicitHeight = 33
                  inherited PRowDetailPanel: TPanel
                    Height = 31
                    ExplicitHeight = 31
                  end
                end
              end
              inherited PStatus: TPanel
                Top = 73
                Width = 286
                ExplicitTop = 73
                ExplicitWidth = 286
              end
              inherited CProp: TDBEditEh
                Text = 'CProp'
              end
            end
            inherited PLeft: TPanel
              Height = 95
              ExplicitHeight = 95
            end
            inherited PTop: TPanel
              Width = 298
              ExplicitWidth = 298
            end
            inherited PContainer: TPanel
              Width = 298
              ExplicitWidth = 298
            end
            inherited PBottom: TPanel
              Top = 149
              Width = 298
              ExplicitTop = 149
              ExplicitWidth = 298
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
        object PTopComment: TPanel
          Left = 441
          Top = 1
          Width = 324
          Height = 151
          Align = alClient
          Caption = 'PTopFiles'
          TabOrder = 2
          object M_Comm: TDBMemoEh
            Left = 6
            Top = 16
            Width = 323
            Height = 125
            ControlLabel.Width = 67
            ControlLabel.Height = 13
            ControlLabel.Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
            ControlLabel.Visible = True
            Lines.Strings = (
              'M_Comment')
            AutoSize = False
            DynProps = <>
            EditButtons = <>
            TabOrder = 0
            Visible = True
            WantReturns = True
          end
        end
      end
      object PCenter: TPanel
        Left = 0
        Top = 156
        Width = 1066
        Height = 198
        Align = alClient
        Caption = 'PCenter'
        TabOrder = 1
        ExplicitHeight = 190
        object PGrid: TPanel
          Left = 1
          Top = 1
          Width = 1064
          Height = 196
          Align = alClient
          Caption = 'PCenter'
          TabOrder = 0
          ExplicitHeight = 188
          inline Frg1: TFrDBGridEh
            Left = 1
            Top = 1
            Width = 1062
            Height = 194
            Align = alClient
            TabOrder = 0
            ExplicitLeft = 1
            ExplicitTop = 1
            ExplicitWidth = 1062
            ExplicitHeight = 186
            inherited PGrid: TPanel
              Left = 30
              Width = 1032
              Height = 140
              ExplicitLeft = 30
              ExplicitWidth = 1032
              ExplicitHeight = 132
              inherited DbGridEh1: TDBGridEh
                Width = 1030
                Height = 117
                OnEnter = Frg1DbGridEh1Enter
                inherited RowDetailData: TRowDetailPanelControlEh
                  ExplicitLeft = 30
                  ExplicitTop = 35
                  ExplicitWidth = 32
                  ExplicitHeight = 70
                  inherited PRowDetailPanel: TPanel
                    Height = 68
                    ExplicitHeight = 68
                  end
                end
              end
              inherited PStatus: TPanel
                Top = 118
                Width = 1030
                ExplicitTop = 110
                ExplicitWidth = 1030
              end
              inherited CProp: TDBEditEh
                Text = 'CProp'
              end
            end
            inherited PLeft: TPanel
              Width = 30
              Height = 140
              ExplicitWidth = 30
              ExplicitHeight = 132
            end
            inherited PTop: TPanel
              Width = 1062
              ExplicitWidth = 1062
            end
            inherited PContainer: TPanel
              Width = 1062
              ExplicitWidth = 1062
            end
            inherited PBottom: TPanel
              Top = 194
              Width = 1062
              ExplicitTop = 186
              ExplicitWidth = 1062
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
      end
    end
    inherited PDlgPanel: TPanel
      Width = 1066
      ExplicitWidth = 1066
      inherited BvDlg: TBevel
        Width = 1064
        ExplicitWidth = 1064
      end
      inherited BvDlgBottom: TBevel
        Width = 1064
        ExplicitWidth = 1064
      end
      inherited PDlgMain: TPanel
        Width = 1064
        ExplicitWidth = 1064
        inherited PDlgBtnForm: TPanel
          Left = 965
          ExplicitLeft = 965
        end
        inherited PDlgChb: TPanel
          Left = 737
          ExplicitLeft = 737
        end
        inherited PDlgBtnR: TPanel
          Left = 866
          ExplicitLeft = 866
        end
        inherited PDlgCenter: TPanel
          Width = 597
          ExplicitWidth = 597
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Width = 1076
    ExplicitWidth = 1076
    inherited LbStatusBarRight: TLabel
      Left = 984
      ExplicitLeft = 984
    end
  end
end
