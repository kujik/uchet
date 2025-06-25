inherited FrmOWSearchInEstimates: TFrmOWSearchInEstimates
  Caption = 'FrmOWSearchInEstimates'
  TextHeight = 13
  inherited PMDIMain: TPanel
    ExplicitWidth = 278
    ExplicitHeight = 84
    inherited PMDIClient: TPanel
      object E_Name: TDBEditEh
        Left = 4
        Top = 15
        Width = 260
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ControlLabel.Width = 161
        ControlLabel.Height = 13
        ControlLabel.Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077' '#1089#1084#1077#1090#1085#1086#1081' '#1087#1086#1079#1080#1094#1080#1080
        ControlLabel.Visible = True
        DynProps = <>
        EditButtons = <>
        TabOrder = 0
        Visible = True
        ExplicitWidth = 256
      end
      object Chb_InclosedOrders: TCheckBox
        Left = 4
        Top = 42
        Width = 173
        Height = 17
        Caption = #1048#1089#1082#1072#1090#1100' '#1074' '#1079#1072#1082#1088#1099#1090#1099#1093' '#1079#1072#1082#1072#1079#1072#1093
        TabOrder = 1
      end
      object Chb_Like: TCheckBox
        Left = 183
        Top = 42
        Width = 114
        Height = 17
        Caption = #1048#1089#1082#1072#1090#1100' '#1087#1086' '#1084#1072#1089#1082#1077
        TabOrder = 2
      end
      object PgcResults: TPageControl
        Left = 4
        Top = 65
        Width = 260
        Height = 1
        ActivePage = TsStdItems
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 3
        ExplicitWidth = 256
        ExplicitHeight = 0
        object TsStdItems: TTabSheet
          Caption = #1057#1090#1072#1085#1076#1072#1088#1090#1085#1099#1077' '#1080#1079#1076#1077#1083#1080#1103
          inline Frg1: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 252
            Height = 89
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 248
            ExplicitHeight = 89
            inherited PGrid: TPanel
              Top = 22
              Width = 242
              Height = 67
              ExplicitTop = 22
              ExplicitWidth = 238
              ExplicitHeight = 67
              inherited DbGridEh1: TDBGridEh
                Width = 240
                Height = 44
                inherited RowDetailData: TRowDetailPanelControlEh
                  ExplicitLeft = 30
                  ExplicitTop = 35
                  ExplicitWidth = 32
                  ExplicitHeight = 5
                  inherited PRowDetailPanel: TPanel
                    Height = 3
                    ExplicitHeight = 3
                  end
                end
              end
              inherited PStatus: TPanel
                Top = 45
                Width = 240
                ExplicitTop = 45
                ExplicitWidth = 236
                inherited LbStatusBarLeft: TLabel
                  Height = 13
                  ExplicitHeight = 13
                end
              end
              inherited CProp: TDBEditEh
                Height = 21
                ExplicitHeight = 21
              end
            end
            inherited PLeft: TPanel
              Top = 22
              Height = 67
              ExplicitTop = 22
              ExplicitHeight = 67
            end
            inherited PTop: TPanel
              Top = 17
              Width = 252
              ExplicitTop = 17
              ExplicitWidth = 248
            end
            inherited PContainer: TPanel
              Width = 252
              Height = 17
              ExplicitWidth = 248
              ExplicitHeight = 17
            end
            inherited PBottom: TPanel
              Top = 89
              Width = 252
              ExplicitTop = 89
              ExplicitWidth = 248
            end
            inherited PrintDBGridEh1: TPrintDBGridEh
              BeforeGridText_Data = {
                7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
                7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
                305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
                666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
                6E657261746F722052696368656432302031302E302E32323030307D5C766965
                776B696E64345C756331200D0A5C706172645C66305C667331365C2763665C27
                66305C2765655C2765355C2765615C2766323A20255B50726F656B745D5C7061
                720D0A5C2763665C2765355C2766305C2765385C2765655C276534205C276631
                205C66315C6C616E67313033332020255B4474315D205C66305C6C616E673130
                34395C2765665C2765655C66315C6C616E67313033332020255B4474325D5C66
                305C6C616E67313034395C7061720D0A5C7061720D0A7D0D0A00}
            end
          end
        end
        object TsOrderItems: TTabSheet
          Caption = #1047#1072#1082#1072#1079#1099
          ImageIndex = 1
          inline Frg2: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 252
            Height = 89
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 248
            ExplicitHeight = 89
            inherited PGrid: TPanel
              Top = 22
              Width = 242
              Height = 67
              ExplicitTop = 22
              ExplicitWidth = 746
              ExplicitHeight = 143
              inherited DbGridEh1: TDBGridEh
                Width = 240
                Height = 44
                inherited RowDetailData: TRowDetailPanelControlEh
                  ExplicitLeft = 30
                  ExplicitTop = 35
                  ExplicitWidth = 32
                  ExplicitHeight = 81
                  inherited PRowDetailPanel: TPanel
                    Height = 79
                    ExplicitHeight = 79
                  end
                end
              end
              inherited PStatus: TPanel
                Top = 45
                Width = 240
                ExplicitTop = 121
                ExplicitWidth = 744
                inherited LbStatusBarLeft: TLabel
                  Height = 13
                  ExplicitHeight = 13
                end
              end
              inherited CProp: TDBEditEh
                Height = 21
                ExplicitHeight = 21
              end
            end
            inherited PLeft: TPanel
              Top = 22
              Height = 67
              ExplicitTop = 22
              ExplicitHeight = 143
            end
            inherited PTop: TPanel
              Top = 17
              Width = 252
              ExplicitTop = 17
              ExplicitWidth = 756
            end
            inherited PContainer: TPanel
              Width = 252
              Height = 17
              ExplicitWidth = 756
              ExplicitHeight = 17
            end
            inherited PBottom: TPanel
              Top = 89
              Width = 252
              ExplicitTop = 165
              ExplicitWidth = 756
            end
            inherited PrintDBGridEh1: TPrintDBGridEh
              BeforeGridText_Data = {
                7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
                7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
                305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
                666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
                6E657261746F722052696368656432302031302E302E32323030307D5C766965
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
    inherited PDlgPanel: TPanel
      inherited PDlgMain: TPanel
        inherited PDlgCenter: TPanel
          Width = 31
          ExplicitWidth = 31
        end
      end
    end
  end
  inherited Timer_AfterStart: TTimer
    Left = 16
    Top = 280
  end
end
