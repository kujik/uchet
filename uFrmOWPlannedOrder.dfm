inherited FrmOWPlannedOrder: TFrmOWPlannedOrder
  Caption = 'FrmOWPlannedOrder'
  ClientHeight = 117
  ClientWidth = 1072
  ExplicitWidth = 1088
  ExplicitHeight = 156
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 1072
    Height = 101
    ExplicitWidth = 1076
    ExplicitHeight = 102
    inherited pnlFrmClient: TPanel
      Width = 1062
      Height = 52
      ExplicitWidth = 1062
      ExplicitHeight = 52
      object bvl1: TBevel
        Left = 0
        Top = 153
        Width = 1062
        Height = 3
        Align = alTop
        ExplicitWidth = 1066
      end
      object pnlTop: TPanel
        Left = 0
        Top = 0
        Width = 1062
        Height = 153
        Align = alTop
        Caption = 'pnlTop'
        TabOrder = 0
        object pnlTopFields: TPanel
          Left = 1
          Top = 1
          Width = 440
          Height = 151
          Align = alLeft
          Caption = 'pnlTopFields'
          TabOrder = 0
          object nedt_num: TDBNumberEditEh
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
          object dedt_dt: TDBDateTimeEditEh
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
          object dedt_dt_change: TDBDateTimeEditEh
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
          object edt_ProjectName: TDBEditEh
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
            Text = 'edt_ProjectName'
            Visible = True
          end
          object chb_is_plannedorder: TDBCheckBoxEh
            Left = 268
            Top = 95
            Width = 76
            Height = 17
            Caption = #1055#1083#1072#1085#1086#1074#1099#1081
            DynProps = <>
            TabOrder = 4
          end
          object chb_is_preorder: TDBCheckBoxEh
            Left = 350
            Top = 95
            Width = 76
            Height = 17
            Caption = #1055#1088#1077#1076#1079#1072#1082#1072#1079
            DynProps = <>
            TabOrder = 5
          end
          object dedt_dt_start: TDBDateTimeEditEh
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
          object dedt_dt_end: TDBDateTimeEditEh
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
          object edt_UserName: TDBEditEh
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
            Text = 'edt_username'
            Visible = True
          end
          object edt_TemplateName: TDBEditEh
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
            Text = 'edt_project'
            Visible = True
          end
          object edt_FormatName: TDBEditEh
            Left = 268
            Top = 68
            Width = 160
            Height = 21
            ControlLabel.Caption = #1060#1086#1088#1084#1072#1090
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 10
            Text = 'edt_project'
            Visible = True
          end
        end
        object pnlTopFiles: TPanel
          Left = 761
          Top = 1
          Width = 300
          Height = 151
          Align = alRight
          Caption = 'pnlTopFiles'
          TabOrder = 1
          object lblCaptionFiles: TLabel
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
            inherited pnlGrid: TPanel
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
              inherited pnlStatusBar: TPanel
                Top = 73
                Width = 286
                ExplicitTop = 73
                ExplicitWidth = 286
                inherited lblStatusBarL: TLabel
                  Height = 13
                  ExplicitHeight = 13
                end
              end
              inherited CProp: TDBEditEh
                Height = 21
                Text = 'CProp'
                ExplicitHeight = 21
              end
            end
            inherited pnlLeft: TPanel
              Height = 95
              ExplicitHeight = 95
            end
            inherited pnlTop: TPanel
              Width = 298
              ExplicitWidth = 298
            end
            inherited pnlContainer: TPanel
              Width = 298
              ExplicitWidth = 298
            end
            inherited pnlBottom: TPanel
              Top = 149
              Width = 298
              ExplicitTop = 149
              ExplicitWidth = 298
            end
            inherited PrintDBGridEh1: TPrintDBGridEh
              BeforeGridText_Data = {
                7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
                7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
                305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
                666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
                6E657261746F722052696368656432302031302E302E32363130307D5C766965
                776B696E64345C756331200D0A5C706172645C66305C667331365C2763665C27
                66305C2765655C2765355C2765615C2766323A20255B50726F656B745D5C7061
                720D0A5C2763665C2765355C2766305C2765385C2765655C276534205C276631
                205C66315C6C616E67313033332020255B4474315D205C66305C6C616E673130
                34395C2765665C2765655C66315C6C616E67313033332020255B4474325D5C66
                305C6C616E67313034395C7061720D0A5C7061720D0A7D0D0A00}
            end
          end
        end
        object pnlTopComment: TPanel
          Left = 441
          Top = 1
          Width = 320
          Height = 151
          Align = alClient
          Caption = 'pnlTopFiles'
          TabOrder = 2
          object mem_Comm: TDBMemoEh
            Left = 6
            Top = 16
            Width = 323
            Height = 125
            ControlLabel.Width = 67
            ControlLabel.Height = 13
            ControlLabel.Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
            ControlLabel.Visible = True
            Lines.Strings = (
              'mem_Comment')
            AutoSize = False
            DynProps = <>
            EditButtons = <>
            TabOrder = 0
            Visible = True
            WantReturns = True
          end
        end
      end
      object pnlCenter: TPanel
        Left = 0
        Top = 156
        Width = 1062
        Height = 220
        Align = alClient
        Caption = 'pnlCenter'
        TabOrder = 1
        object pnlGrid: TPanel
          Left = 1
          Top = 1
          Width = 1060
          Height = 218
          Align = alClient
          Caption = 'pnlCenter'
          TabOrder = 0
          inline Frg1: TFrDBGridEh
            Left = 1
            Top = 1
            Width = 1058
            Height = 216
            Align = alClient
            TabOrder = 0
            ExplicitLeft = 1
            ExplicitTop = 1
            ExplicitWidth = 1058
            ExplicitHeight = 216
            inherited pnlGrid: TPanel
              Left = 30
              Width = 1028
              Height = 162
              ExplicitLeft = 30
              ExplicitWidth = 1028
              ExplicitHeight = 162
              inherited DbGridEh1: TDBGridEh
                Width = 1030
                Height = 139
                OnEnter = Frg1DbGridEh1Enter
                inherited RowDetailData: TRowDetailPanelControlEh
                  ExplicitLeft = 30
                  ExplicitTop = 35
                  ExplicitWidth = 32
                  ExplicitHeight = 100
                  inherited PRowDetailPanel: TPanel
                    Height = 98
                    ExplicitHeight = 98
                  end
                end
              end
              inherited pnlStatusBar: TPanel
                Top = 140
                Width = 1030
                ExplicitTop = 140
                ExplicitWidth = 1026
                inherited lblStatusBarL: TLabel
                  Height = 13
                  ExplicitHeight = 13
                end
              end
              inherited CProp: TDBEditEh
                Height = 21
                Text = 'CProp'
                ExplicitHeight = 21
              end
            end
            inherited pnlLeft: TPanel
              Width = 30
              Height = 162
              ExplicitWidth = 30
              ExplicitHeight = 162
            end
            inherited pnlTop: TPanel
              Width = 1058
              ExplicitWidth = 1058
            end
            inherited pnlContainer: TPanel
              Width = 1058
              ExplicitWidth = 1058
            end
            inherited pnlBottom: TPanel
              Top = 216
              Width = 1058
              ExplicitTop = 216
              ExplicitWidth = 1058
            end
            inherited PrintDBGridEh1: TPrintDBGridEh
              BeforeGridText_Data = {
                7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
                7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
                305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
                666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
                6E657261746F722052696368656432302031302E302E32363130307D5C766965
                776B696E64345C756331200D0A5C706172645C66305C667331365C2763665C27
                66305C2765655C2765355C2765615C2766323A20255B50726F656B745D5C7061
                720D0A5C2763665C2765355C2766305C2765385C2765655C276534205C276631
                205C66315C6C616E67313033332020255B4474315D205C66305C6C616E673130
                34395C2765665C2765655C66315C6C616E67313033332020255B4474325D5C66
                305C6C616E67313034395C7061720D0A5C7061720D0A7D0D0A00}
            end
          end
        end
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 57
      Width = 1062
      ExplicitTop = 57
      ExplicitWidth = 1062
      inherited bvlFrmBtnsTl: TBevel
        Width = 1064
        ExplicitWidth = 1064
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 1064
        ExplicitWidth = 1064
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 1064
        ExplicitWidth = 1060
        inherited pnlFrmBtnsMain: TPanel
          Left = 965
          ExplicitLeft = 961
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 737
          ExplicitLeft = 733
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 866
          ExplicitLeft = 862
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 597
          ExplicitWidth = 593
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 101
    Width = 1072
    ExplicitTop = 101
    ExplicitWidth = 1072
    inherited lblStatusBarR: TLabel
      Left = 1003
      ExplicitLeft = 1003
    end
  end
end
