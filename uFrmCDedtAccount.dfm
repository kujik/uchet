inherited FrmCDedtAccount: TFrmCDedtAccount
  Caption = 'FrmCDedtAccount'
  ClientHeight = 818
  ClientWidth = 1094
  OnResize = FormResize
  ExplicitWidth = 1106
  ExplicitHeight = 856
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 1094
    Height = 802
    ExplicitWidth = 927
    ExplicitHeight = 802
    inherited pnlFrmClient: TPanel
      Width = 1084
      Height = 753
      ExplicitWidth = 913
      ExplicitHeight = 752
      object pnlGeneral: TPanel
        Left = 0
        Top = 0
        Width = 1084
        Height = 161
        Align = alTop
        Caption = 'pnlGeneral'
        TabOrder = 0
        ExplicitWidth = 913
        object pnlGeneralM: TPanel
          Left = 1
          Top = 19
          Width = 1082
          Height = 134
          Align = alTop
          Caption = 'pnlGeneralM'
          TabOrder = 0
          ExplicitWidth = 911
          DesignSize = (
            1082
            134)
          object cmb_type: TDBComboBoxEh
            Left = 104
            Top = 6
            Width = 121
            Height = 21
            ControlLabel.Width = 73
            ControlLabel.Height = 13
            ControlLabel.Caption = #1060#1086#1088#1084#1072' '#1086#1087#1083#1072#1090#1099
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            Items.Strings = (
              #1041#1077#1079#1085#1072#1083#1080#1095#1085#1099#1081' '#1088#1072#1089#1095#1105#1090
              #1053#1072#1083#1080#1095#1085#1099#1077)
            KeyItems.Strings = (
              '1'
              '2')
            TabOrder = 0
            Visible = True
          end
          object edt_account: TDBEditEh
            Left = 278
            Top = 6
            Width = 410
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            ControlLabel.Width = 45
            ControlLabel.Height = 13
            ControlLabel.Caption = #8470' '#1089#1095#1077#1090#1072
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <
              item
                OnClick = edt_accountEditButtons0Click
              end>
            TabOrder = 1
            Text = 'edt_account'
            Visible = True
            ExplicitWidth = 239
          end
          object cmb_id_supplier: TDBComboBoxEh
            Left = 104
            Top = 33
            Width = 584
            Height = 21
            ControlLabel.Width = 60
            ControlLabel.Height = 13
            ControlLabel.Caption = #1050#1086#1085#1090#1088#1072#1075#1077#1085#1090
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            Anchors = [akLeft, akTop, akRight]
            DynProps = <>
            EditButtons = <>
            TabOrder = 2
            Text = 'cmb_Cash'
            Visible = True
            ExplicitWidth = 413
          end
          object dedt_accountdt: TDBDateTimeEditEh
            Left = 764
            Top = 6
            Width = 121
            Height = 21
            ControlLabel.Width = 26
            ControlLabel.Height = 13
            ControlLabel.Caption = #1044#1072#1090#1072
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            Anchors = [akTop, akRight]
            DynProps = <>
            EditButtons = <>
            Kind = dtkDateEh
            TabOrder = 3
            Visible = True
            ExplicitLeft = 593
          end
          object cmb_id_org: TDBComboBoxEh
            Left = 764
            Top = 33
            Width = 312
            Height = 21
            ControlLabel.Width = 64
            ControlLabel.Height = 13
            ControlLabel.Caption = #1055#1083#1072#1090#1077#1083#1100#1097#1080#1082
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            Anchors = [akTop, akRight]
            DynProps = <>
            EditButtons = <>
            TabOrder = 4
            Text = 'cmb_Cash'
            Visible = True
          end
          object cmb_id_user: TDBComboBoxEh
            Left = 763
            Top = 60
            Width = 312
            Height = 21
            ControlLabel.Width = 53
            ControlLabel.Height = 13
            ControlLabel.Caption = #1052#1077#1085#1077#1076#1078#1077#1088
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            Anchors = [akTop, akRight]
            DynProps = <>
            EditButtons = <>
            ReadOnly = True
            TabOrder = 5
            Text = 'cmb_Cash'
            Visible = True
          end
          object cmb_id_expenseitem: TDBComboBoxEh
            Left = 104
            Top = 59
            Width = 584
            Height = 21
            ControlLabel.Width = 88
            ControlLabel.Height = 13
            ControlLabel.Caption = #1057#1090#1072#1090#1100#1103' '#1088#1072#1089#1093#1086#1076#1086#1074
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            Anchors = [akLeft, akTop, akRight]
            DynProps = <>
            EditButtons = <>
            TabOrder = 6
            Text = 'cmb_Cash'
            Visible = True
            ExplicitWidth = 413
          end
          object nedt_sum: TDBNumberEditEh
            Left = 104
            Top = 86
            Width = 121
            Height = 21
            ControlLabel.Width = 31
            ControlLabel.Height = 13
            ControlLabel.Caption = #1057#1091#1084#1084#1072
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButton.Visible = True
            EditButtons = <>
            MaxValue = 999999999.000000000000000000
            MinValue = 1.000000000000000000
            TabOrder = 7
            Visible = True
          end
          object nedt_SumWoNds: TDBNumberEditEh
            Left = 764
            Top = 87
            Width = 121
            Height = 21
            ControlLabel.Width = 76
            ControlLabel.Height = 13
            ControlLabel.Caption = #1057#1091#1084#1084#1072' '#1073#1077#1079' '#1053#1044#1057
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            Anchors = [akTop, akRight]
            DynProps = <>
            EditButtons = <>
            TabOrder = 8
            Visible = True
            ExplicitLeft = 593
          end
          object cmb_nds: TDBComboBoxEh
            Left = 581
            Top = 86
            Width = 107
            Height = 21
            ControlLabel.Width = 62
            ControlLabel.Height = 13
            ControlLabel.Caption = #1057#1090#1072#1074#1082#1072' '#1053#1044#1057
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            Anchors = [akTop, akRight]
            DynProps = <>
            EditButtons = <>
            Items.Strings = (
              #1041#1077#1079#1085#1072#1083#1080#1095#1085#1099#1081' '#1088#1072#1089#1095#1105#1090
              #1053#1072#1083#1080#1095#1085#1099#1077)
            KeyItems.Strings = (
              '1'
              '2')
            TabOrder = 9
            Visible = True
            ExplicitLeft = 410
          end
        end
        inline frmpcGeneral: TFrMyPanelCaption
          Left = 1
          Top = 1
          Width = 1082
          Height = 18
          Align = alTop
          AutoSize = True
          TabOrder = 1
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 911
          inherited bvl1: TBevel
            Width = 1090
            ExplicitWidth = 840
          end
        end
      end
      object pnlRoute: TPanel
        Left = 0
        Top = 161
        Width = 1084
        Height = 200
        Align = alTop
        Caption = 'pnlRoute'
        TabOrder = 1
        ExplicitWidth = 913
        inline frmpcRoute: TFrMyPanelCaption
          Left = 1
          Top = 1
          Width = 1082
          Height = 18
          Align = alTop
          TabOrder = 0
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 911
          inherited bvl1: TBevel
            Width = 1090
            ExplicitWidth = 840
          end
        end
        inline FrgRoute: TFrDBGridEh
          Left = 1
          Top = 112
          Width = 1082
          Height = 87
          Align = alBottom
          TabOrder = 1
          ExplicitLeft = 1
          ExplicitTop = 112
          ExplicitWidth = 911
          ExplicitHeight = 87
          inherited pnlGrid: TPanel
            Top = 48
            Width = 1072
            Height = 39
            ExplicitTop = 48
            ExplicitWidth = 901
            ExplicitHeight = 39
            inherited DbGridEh1: TDBGridEh
              Width = 1070
              Height = 16
              Columns = <
                item
                  CellButtons = <>
                  DynProps = <>
                  EditButtons = <>
                  FieldName = 'iii'
                  Footers = <>
                end>
              inherited RowDetailData: TRowDetailPanelControlEh
                ExplicitLeft = 18
                ExplicitTop = 17
                ExplicitWidth = 58
                inherited PRowDetailPanel: TPanel
                  Width = 56
                  Height = 0
                  ExplicitWidth = 56
                  ExplicitHeight = 0
                end
              end
            end
            inherited pnlStatusBar: TPanel
              Top = 17
              Width = 1070
              ExplicitTop = 17
              ExplicitWidth = 899
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
            Top = 48
            Height = 39
            ExplicitTop = 48
            ExplicitHeight = 39
          end
          inherited pnlTop: TPanel
            Top = 43
            Width = 1082
            ExplicitTop = 43
            ExplicitWidth = 911
          end
          inherited pnlContainer: TPanel
            Width = 1082
            Height = 43
            ExplicitWidth = 911
            ExplicitHeight = 43
          end
          inherited pnlBottom: TPanel
            Top = 87
            Width = 1082
            ExplicitTop = 87
            ExplicitWidth = 911
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
        object pnlRouteM: TPanel
          Left = 1
          Top = 19
          Width = 1082
          Height = 62
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 2
          ExplicitWidth = 911
          object cmb_CarType: TDBComboBoxEh
            Left = 104
            Top = 3
            Width = 156
            Height = 21
            ControlLabel.Width = 53
            ControlLabel.Height = 13
            ControlLabel.Caption = #1058#1088#1072#1085#1089#1087#1086#1088#1090
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            LimitTextToListValues = True
            TabOrder = 0
            Visible = True
          end
          object cmb_Flight: TDBComboBoxEh
            Left = 325
            Top = 4
            Width = 170
            Height = 21
            ControlLabel.Width = 51
            ControlLabel.Height = 13
            ControlLabel.Caption = #1042#1080#1076' '#1088#1077#1081#1089#1072
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            LimitTextToListValues = True
            TabOrder = 1
            Visible = True
          end
          object nedt_Kilometrage: TDBNumberEditEh
            Left = 703
            Top = 4
            Width = 90
            Height = 21
            ControlLabel.Width = 63
            ControlLabel.Height = 13
            ControlLabel.Caption = #1050#1080#1083#1086#1084#1077#1090#1088#1072#1078
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DecimalPlaces = 0
            DynProps = <>
            EditButton.Visible = True
            EditButtons = <>
            MaxValue = 50000.000000000000000000
            TabOrder = 3
            Visible = True
          end
          object dedt_FlightDt: TDBDateTimeEditEh
            Left = 536
            Top = 4
            Width = 87
            Height = 21
            ControlLabel.Width = 26
            ControlLabel.Height = 13
            ControlLabel.Caption = #1044#1072#1090#1072
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            Kind = dtkDateEh
            TabOrder = 2
            Visible = True
          end
          object nedt_Idle: TDBNumberEditEh
            Left = 857
            Top = 4
            Width = 58
            Height = 21
            ControlLabel.Width = 42
            ControlLabel.Height = 13
            ControlLabel.Caption = #1055#1088#1086#1089#1090#1086#1081
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 4
            Visible = True
          end
          object nedt_PriceKm: TDBNumberEditEh
            Left = 325
            Top = 31
            Width = 87
            Height = 21
            ControlLabel.Width = 83
            ControlLabel.Height = 13
            ControlLabel.Caption = #1062#1077#1085#1072' '#1082#1080#1083#1086#1084#1077#1090#1088#1072
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButton.Visible = True
            EditButtons = <>
            MaxValue = 1000000.000000000000000000
            TabOrder = 5
            Visible = True
          end
          object nedt_PriceIdle: TDBNumberEditEh
            Left = 536
            Top = 31
            Width = 87
            Height = 21
            ControlLabel.Width = 96
            ControlLabel.Height = 13
            ControlLabel.Caption = #1062#1077#1085#1072' '#1095#1072#1089#1072' '#1087#1088#1086#1089#1090#1086#1103
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButton.Visible = True
            EditButtons = <>
            MaxValue = 1000000.000000000000000000
            TabOrder = 6
            Visible = True
          end
          object nedt_SumOther: TDBNumberEditEh
            Left = 828
            Top = 31
            Width = 87
            Height = 21
            ControlLabel.Width = 120
            ControlLabel.Height = 13
            ControlLabel.Caption = #1055#1088#1086#1095#1080#1077' '#1088#1072#1089#1093#1086#1076#1099', '#1089#1091#1084#1084#1072
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButton.Visible = True
            EditButtons = <>
            MaxValue = 1000000.000000000000000000
            TabOrder = 7
            Visible = True
          end
        end
      end
      object pnlBasis: TPanel
        Left = 0
        Top = 361
        Width = 1084
        Height = 120
        Align = alTop
        Caption = 'pnlBasis'
        TabOrder = 2
        ExplicitWidth = 913
        inline frmpcBasis: TFrMyPanelCaption
          Left = 1
          Top = 1
          Width = 1082
          Height = 18
          Align = alTop
          TabOrder = 0
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 911
          inherited bvl1: TBevel
            Width = 1090
            ExplicitWidth = 840
          end
        end
        inline FrgBasis: TFrDBGridEh
          Left = 1
          Top = 19
          Width = 1082
          Height = 100
          Align = alClient
          TabOrder = 1
          ExplicitLeft = 1
          ExplicitTop = 19
          ExplicitWidth = 911
          ExplicitHeight = 100
          inherited pnlGrid: TPanel
            Width = 1072
            Height = 46
            ExplicitWidth = 901
            ExplicitHeight = 46
            inherited DbGridEh1: TDBGridEh
              Width = 1070
              Height = 23
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
                inherited PRowDetailPanel: TPanel
                  Width = 44
                  Height = 0
                  ExplicitWidth = 44
                  ExplicitHeight = 0
                end
              end
            end
            inherited pnlStatusBar: TPanel
              Top = 24
              Width = 1070
              ExplicitTop = 24
              ExplicitWidth = 899
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
            Height = 46
            ExplicitHeight = 46
          end
          inherited pnlTop: TPanel
            Width = 1082
            ExplicitWidth = 911
          end
          inherited pnlContainer: TPanel
            Width = 1082
            ExplicitWidth = 911
          end
          inherited pnlBottom: TPanel
            Top = 100
            Width = 1082
            ExplicitTop = 100
            ExplicitWidth = 911
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
      object pnlPayments: TPanel
        Left = 0
        Top = 481
        Width = 1084
        Height = 80
        Align = alTop
        Caption = 'pnlPayments'
        TabOrder = 3
        ExplicitWidth = 913
        object scrlbxPaymentsM: TScrollBox
          Left = 1
          Top = 19
          Width = 1082
          Height = 54
          Margins.Left = 0
          Margins.Top = 0
          Margins.Right = 0
          Margins.Bottom = 0
          HorzScrollBar.Visible = False
          Align = alTop
          BevelInner = bvNone
          BorderStyle = bsNone
          TabOrder = 0
          ExplicitWidth = 911
          object pnlPaymentsD: TPanel
            Left = 0
            Top = 0
            Width = 1082
            Height = 54
            Align = alClient
            Caption = 'pnlPaymentsD'
            TabOrder = 0
            ExplicitWidth = 911
            object dedt_1: TDBDateTimeEditEh
              Left = 19
              Top = 6
              Width = 90
              Height = 21
              ControlLabel.Width = 6
              ControlLabel.Height = 13
              ControlLabel.Caption = '1'
              ControlLabel.Visible = True
              ControlLabelLocation.Position = lpLeftCenterEh
              DynProps = <>
              EditButtons = <>
              Kind = dtkDateEh
              TabOrder = 0
              Visible = True
            end
            object nedt_1: TDBNumberEditEh
              Left = 115
              Top = 6
              Width = 90
              Height = 21
              DynProps = <>
              EditButton.DefaultAction = True
              EditButtons = <>
              TabOrder = 1
              Visible = True
            end
          end
        end
        inline frmpcPayments: TFrMyPanelCaption
          Left = 1
          Top = 1
          Width = 1082
          Height = 18
          Align = alTop
          TabOrder = 1
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 911
          inherited bvl1: TBevel
            Width = 1082
            ExplicitWidth = 840
          end
        end
      end
      object pnlAdd: TPanel
        Left = 0
        Top = 561
        Width = 1084
        Height = 128
        Align = alTop
        Caption = 'pnlAdd'
        TabOrder = 4
        ExplicitWidth = 913
        inline frmpcAdd: TFrMyPanelCaption
          Left = 1
          Top = 1
          Width = 1082
          Height = 18
          Align = alTop
          TabOrder = 0
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 911
          inherited bvl1: TBevel
            Width = 1082
            ExplicitWidth = 840
          end
        end
        object pnlAddM: TPanel
          Left = 1
          Top = 19
          Width = 1082
          Height = 94
          Align = alTop
          Anchors = [akTop]
          Caption = 'pnlAddM'
          TabOrder = 1
          ExplicitWidth = 911
          DesignSize = (
            1082
            94)
          object lbl1: TLabel
            Left = 740
            Top = 54
            Width = 63
            Height = 13
            Anchors = [akTop]
            Caption = #1057#1086#1075#1083#1072#1089#1086#1074#1072#1085':'
          end
          object chb_Agreed2: TDBCheckBoxEh
            Left = 1000
            Top = 48
            Width = 73
            Height = 17
            Anchors = [akTop]
            Caption = #1044#1080#1088#1077#1082#1090#1086#1088
            DynProps = <>
            TabOrder = 0
          end
          object chb_Agreed1: TDBCheckBoxEh
            Left = 810
            Top = 48
            Width = 182
            Height = 17
            Anchors = [akTop]
            Caption = #1056#1091#1082#1086#1074#1086#1076#1080#1090#1077#1083#1100
            DynProps = <>
            TabOrder = 1
          end
          object btnReqestFileOpen: TBitBtn
            Left = 264
            Top = 40
            Width = 25
            Height = 25
            Hint = #1054#1090#1082#1088#1099#1090#1100' '#1092#1072#1081#1083
            ParentShowHint = False
            ShowHint = True
            TabOrder = 2
          end
          object btnReqestFileAttach: TBitBtn
            Left = 233
            Top = 40
            Width = 25
            Height = 25
            Hint = #1055#1088#1080#1082#1088#1077#1087#1080#1090#1100' '#1092#1072#1081#1083
            ParentShowHint = False
            ShowHint = True
            TabOrder = 3
          end
          object btnFileOpen: TBitBtn
            Left = 40
            Top = 40
            Width = 25
            Height = 25
            Hint = #1054#1090#1082#1088#1099#1090#1100' '#1092#1072#1081#1083
            ParentShowHint = False
            ShowHint = True
            TabOrder = 4
          end
          object btnFileAttach: TBitBtn
            Left = 12
            Top = 40
            Width = 25
            Height = 25
            Hint = #1055#1088#1080#1082#1088#1077#1087#1080#1090#1100' '#1092#1072#1081#1083
            ParentShowHint = False
            ShowHint = True
            TabOrder = 5
          end
          object edt_comm: TDBEditEh
            Left = 71
            Top = 13
            Width = 1002
            Height = 21
            Anchors = [akLeft, akRight]
            ControlLabel.Width = 61
            ControlLabel.Height = 13
            ControlLabel.Caption = #1055#1088#1080#1084#1077#1095#1072#1085#1080#1077
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 6
            Text = 'DBEditEh1'
            Visible = True
          end
          object chb_AccountFile: TDBCheckBoxEh
            Left = 71
            Top = 54
            Width = 156
            Height = 17
            Caption = #1060#1072#1081#1083
            DynProps = <>
            TabOrder = 7
          end
          object chb_RequestFile: TDBCheckBoxEh
            Left = 295
            Top = 54
            Width = 154
            Height = 17
            Caption = #1060#1072#1081#1083
            DynProps = <>
            TabOrder = 8
          end
        end
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 758
      Width = 1084
      ExplicitTop = 757
      ExplicitWidth = 913
      inherited bvlFrmBtnsTl: TBevel
        Width = 1082
        ExplicitWidth = 923
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 1082
        ExplicitWidth = 923
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 1082
        ExplicitWidth = 911
        inherited pnlFrmBtnsMain: TPanel
          Left = 983
          ExplicitLeft = 812
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 755
          ExplicitLeft = 584
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 884
          ExplicitLeft = 713
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 615
          ExplicitWidth = 444
          object lbl_Info: TLabel
            Left = 14
            Top = 2
            Width = 36
            Height = 13
            Caption = 'lbl_Info'
          end
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 802
    Width = 1094
    ExplicitTop = 801
    ExplicitWidth = 923
    inherited lblStatusBarR: TLabel
      Left = 1021
      ExplicitLeft = 854
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 232
    Top = 832
  end
  object BindingsList1: TBindingsList
    Methods = <>
    OutputConverters = <>
    Left = 20
    Top = 5
  end
  object tmr1: TTimer
    Interval = 500
    OnTimer = tmr1Timer
    Left = 482
    Top = 774
  end
  object ApplicationEvents1: TApplicationEvents
    Left = 530
    Top = 766
  end
end
