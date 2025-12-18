inherited FrmWWedtWorkSchedule: TFrmWWedtWorkSchedule
  Caption = 'FrmWWedtWorkSchedule'
  ClientHeight = 444
  ClientWidth = 709
  ExplicitWidth = 721
  ExplicitHeight = 482
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 709
    Height = 428
    ExplicitWidth = 709
    ExplicitHeight = 428
    inherited pnlFrmClient: TPanel
      Width = 699
      Height = 379
      ExplicitWidth = 695
      ExplicitHeight = 378
      object pnlPropertiesC: TPanel
        Left = 0
        Top = 0
        Width = 699
        Height = 135
        Align = alTop
        Caption = 'pnlPropertiesC'
        TabOrder = 0
        ExplicitWidth = 695
        inline frmpcProperties: TFrMyPanelCaption
          Left = 1
          Top = 1
          Width = 697
          Height = 18
          Align = alTop
          TabOrder = 0
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 693
          inherited bvl1: TBevel
            Width = 697
            ExplicitWidth = 707
          end
        end
        object pnlProperties: TPanel
          Left = 1
          Top = 19
          Width = 697
          Height = 114
          Align = alTop
          Caption = 'pnlProperties'
          TabOrder = 1
          ExplicitWidth = 693
          object edt_name: TDBEditEh
            Left = 304
            Top = 10
            Width = 385
            Height = 21
            ControlLabel.Width = 79
            ControlLabel.Height = 13
            ControlLabel.Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1082#1077
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 0
            Text = 'edt_name'
            Visible = True
          end
          object chb_active: TDBCheckBoxEh
            Left = 74
            Top = 87
            Width = 97
            Height = 17
            Caption = #1048#1089#1087#1086#1083#1100#1079#1091#1077#1090#1089#1103
            DynProps = <>
            TabOrder = 1
          end
          object edt_code: TDBEditEh
            Left = 74
            Top = 10
            Width = 143
            Height = 21
            ControlLabel.Width = 20
            ControlLabel.Height = 13
            ControlLabel.Caption = #1050#1086#1076
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 2
            Text = 'edt_name'
            Visible = True
          end
          object edt_comm: TDBEditEh
            Left = 74
            Top = 37
            Width = 615
            Height = 21
            ControlLabel.Width = 67
            ControlLabel.Height = 13
            ControlLabel.Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 3
            Text = 'edt_name'
            Visible = True
          end
          object chb_is_individual: TDBCheckBoxEh
            Left = 74
            Top = 64
            Width = 159
            Height = 17
            Caption = #1048#1085#1076#1080#1074#1080#1076#1091#1072#1083#1100#1085#1099#1081' '#1075#1088#1072#1092#1080#1082
            DynProps = <>
            TabOrder = 4
          end
        end
      end
      object pnlHoursC: TPanel
        Left = 0
        Top = 247
        Width = 699
        Height = 358
        Align = alTop
        Caption = 'pnlHoursC'
        TabOrder = 1
        ExplicitWidth = 695
        inline frmpcHours: TFrMyPanelCaption
          Left = 1
          Top = 1
          Width = 697
          Height = 18
          Align = alTop
          TabOrder = 0
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 693
          inherited bvl1: TBevel
            Top = 6
            Width = 697
            ExplicitTop = 6
            ExplicitWidth = 1030
          end
        end
        object pnlHours: TPanel
          Left = 1
          Top = 19
          Width = 697
          Height = 286
          Align = alTop
          Caption = 'pnlHours'
          TabOrder = 1
          ExplicitWidth = 693
          object cbb_year: TDBComboBoxEh
            Left = 36
            Top = 7
            Width = 49
            Height = 21
            ControlLabel.Width = 19
            ControlLabel.Height = 13
            ControlLabel.Caption = #1043#1086#1076
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 0
            Text = 'DBComboBoxEh1'
            Visible = True
          end
          inline FrgHours: TFrDBGridEh
            Left = 1
            Top = 34
            Width = 695
            Height = 251
            Align = alBottom
            TabOrder = 1
            ExplicitLeft = 1
            ExplicitTop = 34
            ExplicitWidth = 691
            ExplicitHeight = 251
            inherited pnlGrid: TPanel
              Width = 685
              Height = 197
              ExplicitWidth = 681
              ExplicitHeight = 197
              inherited DbGridEh1: TDBGridEh
                Width = 683
                Height = 174
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
                Top = 175
                Width = 683
                ExplicitTop = 175
                ExplicitWidth = 679
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
              Height = 197
              ExplicitHeight = 197
            end
            inherited pnlTop: TPanel
              Width = 695
              ExplicitWidth = 691
            end
            inherited pnlContainer: TPanel
              Width = 695
              ExplicitWidth = 691
            end
            inherited pnlBottom: TPanel
              Top = 251
              Width = 695
              ExplicitTop = 251
              ExplicitWidth = 691
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
      object pnlTemplateC: TPanel
        Left = 0
        Top = 135
        Width = 699
        Height = 112
        Align = alTop
        Caption = 'pnlTemplateC'
        TabOrder = 2
        ExplicitWidth = 695
        object pnlTemplate: TPanel
          Left = 1
          Top = 19
          Width = 697
          Height = 78
          Align = alTop
          Caption = 'pnlTemplate'
          TabOrder = 0
          ExplicitWidth = 693
          inline FrgTemplate: TFrDBGridEh
            Left = 1
            Top = 32
            Width = 695
            Height = 45
            Align = alBottom
            TabOrder = 0
            ExplicitLeft = 1
            ExplicitTop = 32
            ExplicitWidth = 691
            ExplicitHeight = 45
            inherited pnlGrid: TPanel
              Width = 685
              Height = 22
              ExplicitWidth = 681
              ExplicitHeight = 22
              inherited DbGridEh1: TDBGridEh
                Width = 683
                Height = 303
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
                Top = 0
                Width = 683
                ExplicitTop = 0
                ExplicitWidth = 679
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
              Height = 22
              ExplicitHeight = 22
            end
            inherited pnlTop: TPanel
              Width = 695
              ExplicitWidth = 691
            end
            inherited pnlContainer: TPanel
              Width = 695
              ExplicitWidth = 691
            end
            inherited pnlBottom: TPanel
              Top = 45
              Width = 695
              ExplicitTop = 45
              ExplicitWidth = 691
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
          object nedt_duration: TDBNumberEditEh
            Left = 120
            Top = 3
            Width = 60
            Height = 21
            ControlLabel.Width = 105
            ControlLabel.Height = 13
            ControlLabel.Caption = #1055#1088#1086#1076#1086#1083#1078#1080#1090#1077#1083#1100#1085#1086#1089#1090#1100
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DecimalPlaces = 0
            DynProps = <>
            EditButton.DefaultAction = True
            EditButton.Style = ebsAltDropDownEh
            EditButtons = <>
            HighlightRequired = True
            MaxValue = 365.000000000000000000
            MinValue = 1.000000000000000000
            TabOrder = 1
            Visible = True
          end
        end
        inline frmpcTemplate: TFrMyPanelCaption
          Left = 1
          Top = 1
          Width = 697
          Height = 18
          Align = alTop
          TabOrder = 1
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 693
          inherited bvl1: TBevel
            Top = 6
            Width = 697
            ExplicitTop = 6
            ExplicitWidth = 1030
          end
        end
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 384
      Width = 699
      ExplicitTop = 383
      ExplicitWidth = 695
      inherited bvlFrmBtnsTl: TBevel
        Width = 697
        ExplicitWidth = 697
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 697
        ExplicitWidth = 697
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 697
        ExplicitWidth = 693
        inherited pnlFrmBtnsMain: TPanel
          Left = 598
          ExplicitLeft = 594
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 370
          ExplicitLeft = 366
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 499
          ExplicitLeft = 495
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 230
          ExplicitWidth = 226
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 428
    Width = 709
    ExplicitTop = 427
    ExplicitWidth = 705
    inherited lblStatusBarR: TLabel
      Left = 636
      Height = 14
      ExplicitLeft = 636
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 360
    Top = 840
  end
end
