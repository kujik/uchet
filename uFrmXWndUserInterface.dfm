inherited FrmXWndUserInterface: TFrmXWndUserInterface
  Caption = 'FrmXWndUserInterface'
  ClientHeight = 272
  ClientWidth = 804
  ExplicitWidth = 816
  ExplicitHeight = 310
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 804
    Height = 272
    ExplicitWidth = 848
    ExplicitHeight = 410
    inherited PMDIClient: TPanel
      Width = 794
      Height = 266
      ExplicitHeight = 403
      object Bevel1: TBevel
        Left = 241
        Top = 0
        Width = 3
        Height = 266
        Align = alLeft
        ExplicitLeft = 281
        ExplicitHeight = 345
      end
      object Label1: TLabel
        Left = 252
        Top = 240
        Width = 71
        Height = 13
        Caption = #1063#1077#1088#1085#1099#1081' '#1090#1077#1082#1089#1090
      end
      object Label2: TLabel
        Left = 340
        Top = 240
        Width = 76
        Height = 13
        Caption = #1050#1088#1072#1089#1085#1099#1081' '#1090#1077#1082#1089#1090
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object PLeft: TPanel
        Left = 0
        Top = 0
        Width = 241
        Height = 266
        Align = alLeft
        TabOrder = 0
        ExplicitHeight = 403
        object Bt_Def: TBitBtn
          Left = 8
          Top = 228
          Width = 226
          Height = 25
          Caption = #1055#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102
          TabOrder = 0
          OnClick = Bt_DefClick
        end
        object Chb_DesignReports: TCheckBox
          Left = 8
          Top = 196
          Width = 245
          Height = 17
          Caption = #1054#1090#1082#1088#1099#1074#1072#1090#1100' '#1076#1080#1079#1072#1081#1085#1077#1088' '#1086#1090#1095#1077#1090#1086#1074' '#1087#1088#1080' '#1087#1077#1095#1072#1090#1080
          TabOrder = 1
        end
        object Cb_D: TDBComboBoxEh
          Left = 8
          Top = 169
          Width = 226
          Height = 21
          ControlLabel.Width = 161
          ControlLabel.Height = 13
          ControlLabel.Caption = #1054#1082#1085#1072' '#1076#1080#1072#1083#1086#1075#1086#1074' ('#1074#1074#1086#1076#1072' '#1076#1072#1085#1085#1099#1093')'
          ControlLabel.Visible = True
          DynProps = <>
          EditButtons = <>
          LimitTextToListValues = True
          TabOrder = 2
          Text = 'Cb_Styles'
          Visible = True
        end
        object Cb_J: TDBComboBoxEh
          Left = 8
          Top = 127
          Width = 226
          Height = 21
          ControlLabel.Width = 154
          ControlLabel.Height = 13
          ControlLabel.Caption = #1054#1082#1085#1072' '#1078#1091#1088#1085#1072#1083#1086#1074'/'#1089#1087#1088#1072#1074#1086#1095#1085#1080#1082#1086#1074
          ControlLabel.Visible = True
          DynProps = <>
          EditButtons = <>
          LimitTextToListValues = True
          TabOrder = 3
          Text = 'Cb_Styles'
          Visible = True
        end
        object Cb_Q: TDBComboBoxEh
          Left = 8
          Top = 85
          Width = 226
          Height = 21
          ControlLabel.Width = 201
          ControlLabel.Height = 13
          ControlLabel.Caption = #1057#1087#1088#1072#1096#1080#1074#1072#1090#1100' '#1087#1088#1080' '#1079#1072#1082#1088#1099#1090#1080#1080' '#1087#1088#1080#1083#1086#1078#1077#1085#1080#1103
          ControlLabel.Visible = True
          DynProps = <>
          EditButtons = <>
          LimitTextToListValues = True
          TabOrder = 4
          Text = 'Cb_Styles'
          Visible = True
        end
        object Cb_Styles: TDBComboBoxEh
          Left = 8
          Top = 31
          Width = 226
          Height = 21
          ControlLabel.Width = 96
          ControlLabel.Height = 13
          ControlLabel.Caption = #1057#1090#1080#1083#1100' '#1086#1092#1086#1088#1084#1083#1077#1085#1080#1103
          ControlLabel.Visible = True
          DynProps = <>
          EditButtons = <>
          LimitTextToListValues = True
          TabOrder = 5
          Text = 'Cb_Styles'
          Visible = True
        end
      end
      object Bt_1: TBitBtn
        Left = 247
        Top = 204
        Width = 89
        Height = 25
        Caption = 'Bt_1'
        TabOrder = 1
      end
      object RadioButton1: TRadioButton
        Left = 429
        Top = 208
        Width = 113
        Height = 17
        Caption = #1055#1077#1088#1077#1082#1083#1102#1095#1072#1090#1077#1083#1100
        TabOrder = 2
      end
      object CheckBox1: TCheckBox
        Left = 350
        Top = 208
        Width = 73
        Height = 17
        Caption = #1060#1083#1072#1078#1086#1082
        TabOrder = 3
      end
      object DBEditEh1: TDBEditEh
        Left = 615
        Top = 206
        Width = 175
        Height = 21
        ControlLabel.Width = 59
        ControlLabel.Height = 13
        ControlLabel.Caption = #1055#1086#1083#1077' '#1074#1074#1086#1076#1072
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <
          item
          end>
        HighlightRequired = True
        TabOrder = 4
        Visible = True
      end
      inline Frg1: TFrDBGridEh
        Left = 240
        Top = 0
        Width = 550
        Height = 190
        TabOrder = 5
        ExplicitLeft = 240
        ExplicitWidth = 550
        ExplicitHeight = 190
        inherited PGrid: TPanel
          Width = 540
          Height = 136
          ExplicitWidth = 540
          ExplicitHeight = 136
          inherited DbGridEh1: TDBGridEh
            Width = 538
            Height = 113
            Columns = <
              item
                CellButtons = <>
                DynProps = <>
                EditButtons = <>
                FieldName = 'iii'
                Footers = <>
              end>
            inherited RowDetailData: TRowDetailPanelControlEh
              ExplicitTop = 35
              ExplicitWidth = 46
              ExplicitHeight = 74
              inherited PRowDetailPanel: TPanel
                Width = 44
                Height = 72
                ExplicitWidth = 44
                ExplicitHeight = 72
              end
            end
          end
          inherited PStatus: TPanel
            Top = 114
            Width = 538
            ExplicitTop = 114
            ExplicitWidth = 538
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
          Height = 136
          ExplicitHeight = 136
        end
        inherited PTop: TPanel
          Width = 550
          ExplicitWidth = 550
        end
        inherited PContainer: TPanel
          Width = 550
          ExplicitWidth = 550
        end
        inherited PBottom: TPanel
          Top = 190
          Width = 550
          ExplicitTop = 190
          ExplicitWidth = 550
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
    inherited PDlgPanel: TPanel
      Top = 271
      Width = 794
      Height = 0
      ExplicitTop = 408
      ExplicitHeight = 0
      inherited BvDlg: TBevel
        Width = 792
      end
      inherited BvDlgBottom: TBevel
        Top = -4
        Width = 792
      end
      inherited PDlgMain: TPanel
        Width = 792
        inherited PDlgBtnForm: TPanel
          Left = 693
        end
        inherited PDlgChb: TPanel
          Left = 465
        end
        inherited PDlgBtnR: TPanel
          Left = 594
        end
        inherited PDlgCenter: TPanel
          Width = 325
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 272
    Width = 804
    Height = 0
    ExplicitTop = 409
    ExplicitHeight = 0
    inherited LbStatusBarRight: TLabel
      Left = 712
    end
  end
end
