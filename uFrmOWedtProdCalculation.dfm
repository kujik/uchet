inherited FrmOWedtProdCalculation: TFrmOWedtProdCalculation
  Caption = 'FrmOWedtProdCalculation'
  ClientHeight = 591
  ClientWidth = 1126
  ExplicitWidth = 1138
  ExplicitHeight = 629
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 1126
    Height = 575
    ExplicitWidth = 1126
    ExplicitHeight = 575
    inherited pnlFrmClient: TPanel
      Width = 1116
      Height = 526
      ExplicitWidth = 1112
      ExplicitHeight = 525
      object pnlTop: TPanel
        Left = 0
        Top = 0
        Width = 1116
        Height = 49
        Align = alTop
        Caption = 'pnlTop'
        TabOrder = 0
        ExplicitWidth = 1112
        DesignSize = (
          1116
          49)
        object edt_name: TDBEditEh
          Left = 81
          Top = 15
          Width = 1022
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          ControlLabel.Width = 73
          ControlLabel.Height = 13
          ControlLabel.Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
          ControlLabel.Visible = True
          ControlLabelLocation.Position = lpLeftCenterEh
          DynProps = <>
          EditButtons = <>
          TabOrder = 0
          Text = 'edt_name'
          Visible = True
          ExplicitWidth = 1018
        end
      end
      object pgcMain: TPageControl
        Left = 0
        Top = 49
        Width = 1116
        Height = 477
        ActivePage = tsEconomic
        Align = alClient
        TabOrder = 1
        object ts1: TTabSheet
          Caption = 'ts1'
          ImageIndex = 1
          inline Frg1: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 1108
            Height = 449
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 1104
            ExplicitHeight = 448
            inherited pnlGrid: TPanel
              Width = 1098
              Height = 395
              ExplicitWidth = 1098
              ExplicitHeight = 395
              inherited DbGridEh1: TDBGridEh
                Width = 1096
                Height = 372
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
                  end
                end
              end
              inherited pnlStatusBar: TPanel
                Top = 373
                Width = 1096
                ExplicitTop = 373
                ExplicitWidth = 1096
                inherited lblStatusBarL: TLabel
                  Height = 13
                  ExplicitHeight = 13
                end
              end
              inherited CProp: TDBEditEh
                Height = 21
                ExplicitHeight = 21
              end
            end
            inherited pnlLeft: TPanel
              Height = 395
              ExplicitHeight = 395
            end
            inherited pnlTop: TPanel
              Width = 1108
              ExplicitWidth = 1108
            end
            inherited pnlContainer: TPanel
              Width = 1108
              ExplicitWidth = 1108
            end
            inherited pnlBottom: TPanel
              Top = 449
              Width = 1108
              ExplicitTop = 449
              ExplicitWidth = 1108
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
        object ts2: TTabSheet
          Caption = 'ts2'
          ImageIndex = 2
          inline Frg2: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 1108
            Height = 449
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 1104
            ExplicitHeight = 448
            inherited pnlGrid: TPanel
              Width = 1098
              Height = 395
              ExplicitWidth = 1098
              ExplicitHeight = 395
              inherited DbGridEh1: TDBGridEh
                Width = 1096
                Height = 372
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
                  end
                end
              end
              inherited pnlStatusBar: TPanel
                Top = 373
                Width = 1096
                ExplicitTop = 373
                ExplicitWidth = 1096
                inherited lblStatusBarL: TLabel
                  Height = 13
                  ExplicitHeight = 13
                end
              end
              inherited CProp: TDBEditEh
                Height = 21
                ExplicitHeight = 21
              end
            end
            inherited pnlLeft: TPanel
              Height = 395
              ExplicitHeight = 395
            end
            inherited pnlTop: TPanel
              Width = 1108
              ExplicitWidth = 1108
            end
            inherited pnlContainer: TPanel
              Width = 1108
              ExplicitWidth = 1108
            end
            inherited pnlBottom: TPanel
              Top = 449
              Width = 1108
              ExplicitTop = 449
              ExplicitWidth = 1108
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
        object ts3: TTabSheet
          Caption = 'ts3'
          ImageIndex = 4
          inline Frg3: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 1108
            Height = 449
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 1104
            ExplicitHeight = 448
            inherited pnlGrid: TPanel
              Width = 1098
              Height = 395
              ExplicitWidth = 1098
              ExplicitHeight = 395
              inherited DbGridEh1: TDBGridEh
                Width = 1096
                Height = 372
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
                  end
                end
              end
              inherited pnlStatusBar: TPanel
                Top = 373
                Width = 1096
                ExplicitTop = 373
                ExplicitWidth = 1096
                inherited lblStatusBarL: TLabel
                  Height = 13
                  ExplicitHeight = 13
                end
              end
              inherited CProp: TDBEditEh
                Height = 21
                ExplicitHeight = 21
              end
            end
            inherited pnlLeft: TPanel
              Height = 395
              ExplicitHeight = 395
            end
            inherited pnlTop: TPanel
              Width = 1108
              ExplicitWidth = 1108
            end
            inherited pnlContainer: TPanel
              Width = 1108
              ExplicitWidth = 1108
            end
            inherited pnlBottom: TPanel
              Top = 449
              Width = 1108
              ExplicitTop = 449
              ExplicitWidth = 1108
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
        object ts4: TTabSheet
          Caption = 'ts4'
          ImageIndex = 5
          inline Frg4: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 1108
            Height = 449
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 1104
            ExplicitHeight = 448
            inherited pnlGrid: TPanel
              Width = 1098
              Height = 395
              ExplicitWidth = 1098
              ExplicitHeight = 395
              inherited DbGridEh1: TDBGridEh
                Width = 1096
                Height = 372
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
                  end
                end
              end
              inherited pnlStatusBar: TPanel
                Top = 373
                Width = 1096
                ExplicitTop = 373
                ExplicitWidth = 1096
                inherited lblStatusBarL: TLabel
                  Height = 13
                  ExplicitHeight = 13
                end
              end
              inherited CProp: TDBEditEh
                Height = 21
                ExplicitHeight = 21
              end
            end
            inherited pnlLeft: TPanel
              Height = 395
              ExplicitHeight = 395
            end
            inherited pnlTop: TPanel
              Width = 1108
              ExplicitWidth = 1108
            end
            inherited pnlContainer: TPanel
              Width = 1108
              ExplicitWidth = 1108
            end
            inherited pnlBottom: TPanel
              Top = 449
              Width = 1108
              ExplicitTop = 449
              ExplicitWidth = 1108
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
        object ts5: TTabSheet
          Caption = 'ts5'
          ImageIndex = 5
          inline Frg5: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 1108
            Height = 449
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 1104
            ExplicitHeight = 448
            inherited pnlGrid: TPanel
              Width = 1098
              Height = 395
              ExplicitWidth = 1094
              ExplicitHeight = 394
              inherited DbGridEh1: TDBGridEh
                Width = 1096
                Height = 372
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
                  end
                end
              end
              inherited pnlStatusBar: TPanel
                Top = 373
                Width = 1096
                ExplicitTop = 372
                ExplicitWidth = 1092
                inherited lblStatusBarL: TLabel
                  Height = 13
                  ExplicitHeight = 13
                end
              end
              inherited CProp: TDBEditEh
                Height = 21
                ExplicitHeight = 21
              end
            end
            inherited pnlLeft: TPanel
              Height = 395
              ExplicitHeight = 394
            end
            inherited pnlTop: TPanel
              Width = 1108
              ExplicitWidth = 1104
            end
            inherited pnlContainer: TPanel
              Width = 1108
              ExplicitWidth = 1104
            end
            inherited pnlBottom: TPanel
              Top = 449
              Width = 1108
              ExplicitTop = 448
              ExplicitWidth = 1104
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
        object tsEconomic: TTabSheet
          Caption = #1069#1082#1086#1085#1086#1084#1080#1082#1072
          ImageIndex = 5
          object nedt_markup_percent: TDBNumberEditEh
            Left = 160
            Top = 38
            Width = 121
            Height = 21
            ControlLabel.Width = 76
            ControlLabel.Height = 13
            ControlLabel.Caption = #1047#1072#1087#1072#1089' '#1094#1077#1085#1099', %'
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 0
            Visible = True
          end
          object nedt_purchase_sum: TDBNumberEditEh
            Left = 160
            Top = 11
            Width = 121
            Height = 21
            ControlLabel.Width = 111
            ControlLabel.Height = 13
            ControlLabel.Caption = #1054#1073#1097#1072#1103' '#1089#1091#1084#1084#1072' '#1079#1072#1082#1091#1087#1082#1080
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 1
            Visible = True
          end
          object nedt_overall_coeff: TDBNumberEditEh
            Left = 160
            Top = 65
            Width = 121
            Height = 21
            ControlLabel.Width = 107
            ControlLabel.Height = 13
            ControlLabel.Caption = #1054#1073#1097#1080#1081' '#1082#1086#1101#1092#1092#1080#1094#1080#1077#1085#1090
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 2
            Visible = True
          end
          object nedt_sales_sum: TDBNumberEditEh
            Left = 160
            Top = 92
            Width = 121
            Height = 21
            ControlLabel.Width = 79
            ControlLabel.Height = 13
            ControlLabel.Caption = #1057#1091#1084#1084#1072' '#1087#1088#1086#1076#1072#1078#1080
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 3
            Visible = True
          end
          object nedt_sales_sum_from_items: TDBNumberEditEh
            Left = 160
            Top = 119
            Width = 121
            Height = 21
            ControlLabel.Width = 138
            ControlLabel.Height = 13
            ControlLabel.Caption = #1057#1091#1084#1084#1072' '#1087#1088#1086#1076#1072#1078#1080' '#1087#1086' '#1088#1072#1089#1095#1077#1090#1091
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 4
            Visible = True
          end
          object nedt_coeff_from_items: TDBNumberEditEh
            Left = 160
            Top = 146
            Width = 121
            Height = 21
            ControlLabel.Width = 129
            ControlLabel.Height = 13
            ControlLabel.Caption = #1050#1086#1101#1092#1092#1080#1094#1080#1077#1085#1090' '#1087#1086' '#1088#1072#1089#1095#1077#1090#1091
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 5
            Visible = True
          end
        end
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 531
      Width = 1116
      ExplicitTop = 530
      ExplicitWidth = 1112
      inherited bvlFrmBtnsTl: TBevel
        Width = 1114
        ExplicitWidth = 1114
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 1114
        ExplicitWidth = 1114
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 1114
        ExplicitWidth = 1110
        inherited pnlFrmBtnsMain: TPanel
          Left = 1015
          ExplicitLeft = 1011
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 787
          ExplicitLeft = 783
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 916
          ExplicitLeft = 912
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 647
          ExplicitWidth = 643
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 575
    Width = 1126
    ExplicitTop = 574
    ExplicitWidth = 1122
    inherited lblStatusBarR: TLabel
      Left = 1053
      Height = 14
      ExplicitLeft = 1053
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 128
    Top = 536
  end
end
