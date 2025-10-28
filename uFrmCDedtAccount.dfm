inherited FrmCDedtAccount: TFrmCDedtAccount
  Caption = 'FrmCDedtAccount'
  ClientHeight = 820
  ExplicitWidth = 864
  ExplicitHeight = 858
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Height = 804
    ExplicitHeight = 695
    inherited pnlFrmClient: TPanel
      Height = 755
      ExplicitTop = 6
      ExplicitWidth = 842
      ExplicitHeight = 755
      object pnlGeneral: TPanel
        Left = 0
        Top = 0
        Width = 842
        Height = 161
        Align = alTop
        Caption = 'pnlGeneral'
        TabOrder = 0
        ExplicitWidth = 838
        object pnlGeneralM: TPanel
          Left = 1
          Top = 19
          Width = 840
          Height = 134
          Align = alTop
          Caption = 'pnlGeneralM'
          TabOrder = 0
          ExplicitWidth = 836
          DesignSize = (
            840
            134)
          object cmb_Cash: TDBComboBoxEh
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
          object edt_Account: TDBEditEh
            Left = 270
            Top = 6
            Width = 184
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            ControlLabel.Width = 45
            ControlLabel.Height = 13
            ControlLabel.Caption = #8470' '#1089#1095#1077#1090#1072
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 1
            Text = 'edt_Account'
            Visible = True
            ExplicitWidth = 180
          end
          object cmb_Supplier: TDBComboBoxEh
            Left = 104
            Top = 33
            Width = 350
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
            ExplicitWidth = 346
          end
          object Dt_Account: TDBDateTimeEditEh
            Left = 530
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
            ExplicitLeft = 526
          end
          object cmb_Org: TDBComboBoxEh
            Left = 530
            Top = 33
            Width = 298
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
            ExplicitLeft = 526
          end
          object cmb_User: TDBComboBoxEh
            Left = 529
            Top = 60
            Width = 299
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
            ExplicitLeft = 525
          end
          object cmb_ExpenseItem: TDBComboBoxEh
            Left = 104
            Top = 59
            Width = 350
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
            ExplicitWidth = 346
          end
          object nedt_Sum: TDBNumberEditEh
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
            Left = 530
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
            ExplicitLeft = 526
          end
          object cmb_Nds: TDBComboBoxEh
            Left = 347
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
            ExplicitLeft = 343
          end
        end
        inline frmpcGeneral: TFrMyPanelCaption
          Left = 1
          Top = 1
          Width = 840
          Height = 18
          Align = alTop
          AutoSize = True
          TabOrder = 1
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 836
          inherited bvl1: TBevel
            Width = 840
            ExplicitWidth = 840
          end
        end
      end
      object pnlRoute: TPanel
        Left = 0
        Top = 161
        Width = 842
        Height = 200
        Align = alTop
        Caption = 'pnlRoute'
        TabOrder = 1
        ExplicitWidth = 838
        inline frmpcRoute: TFrMyPanelCaption
          Left = 1
          Top = 1
          Width = 840
          Height = 18
          Align = alTop
          TabOrder = 0
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 836
          inherited bvl1: TBevel
            Width = 840
            ExplicitWidth = 840
          end
        end
        object pnl_Route: TPanel
          Left = 1
          Top = 19
          Width = 840
          Height = 58
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 1
          ExplicitWidth = 836
          object cmb_CarType: TDBComboBoxEh
            Left = 85
            Top = 4
            Width = 178
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
        inline FrgRoute: TFrDBGridEh
          Left = 1
          Top = 77
          Width = 840
          Height = 122
          Align = alClient
          TabOrder = 2
          ExplicitLeft = 1
          ExplicitTop = 77
          ExplicitWidth = 836
          ExplicitHeight = 122
          inherited pnlGrid: TPanel
            Width = 830
            Height = 68
            ExplicitWidth = 826
            ExplicitHeight = 68
            inherited DbGridEh1: TDBGridEh
              Width = 828
              Height = 45
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
                ExplicitHeight = 6
                inherited PRowDetailPanel: TPanel
                  Width = 44
                  Height = 4
                  ExplicitWidth = 44
                  ExplicitHeight = 4
                end
              end
            end
            inherited pnlStatusBar: TPanel
              Top = 46
              Width = 828
              ExplicitTop = 46
              ExplicitWidth = 824
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
            Height = 68
            ExplicitHeight = 68
          end
          inherited pnlTop: TPanel
            Width = 840
            ExplicitWidth = 836
          end
          inherited pnlContainer: TPanel
            Width = 840
            ExplicitWidth = 836
          end
          inherited pnlBottom: TPanel
            Top = 122
            Width = 840
            ExplicitTop = 122
            ExplicitWidth = 836
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
      object pnlBasis: TPanel
        Left = 0
        Top = 361
        Width = 842
        Height = 120
        Align = alTop
        Caption = 'pnlBasis'
        TabOrder = 2
        ExplicitWidth = 838
        inline frmpcBasis: TFrMyPanelCaption
          Left = 1
          Top = 1
          Width = 840
          Height = 18
          Align = alTop
          TabOrder = 0
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 836
          inherited bvl1: TBevel
            Width = 840
            ExplicitWidth = 840
          end
        end
        inline FrgBasis: TFrDBGridEh
          Left = 1
          Top = 19
          Width = 840
          Height = 100
          Align = alClient
          TabOrder = 1
          ExplicitLeft = 1
          ExplicitTop = 19
          ExplicitWidth = 836
          ExplicitHeight = 100
          inherited pnlGrid: TPanel
            Width = 830
            Height = 46
            ExplicitWidth = 826
            ExplicitHeight = 46
            inherited DbGridEh1: TDBGridEh
              Width = 828
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
                ExplicitLeft = 30
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
              Width = 828
              ExplicitTop = 24
              ExplicitWidth = 824
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
            Width = 840
            ExplicitWidth = 836
          end
          inherited pnlContainer: TPanel
            Width = 840
            ExplicitWidth = 836
          end
          inherited pnlBottom: TPanel
            Top = 100
            Width = 840
            ExplicitTop = 100
            ExplicitWidth = 836
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
        Width = 842
        Height = 80
        Align = alTop
        Caption = 'pnlPayments'
        TabOrder = 3
        object scrlbxPaymentsM: TScrollBox
          Left = 1
          Top = 19
          Width = 840
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
          ExplicitTop = 1
          object pnlPaymentsD: TPanel
            Left = 0
            Top = 0
            Width = 840
            Height = 54
            Align = alClient
            Caption = 'pnlPaymentsD'
            TabOrder = 0
            ExplicitLeft = -3
            ExplicitTop = 42
            ExplicitWidth = 823
            ExplicitHeight = 38
            object dedt_1: TDBDateTimeEditEh
              Left = 19
              Top = 6
              Width = 121
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
              Left = 146
              Top = 6
              Width = 121
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
          Width = 840
          Height = 18
          Align = alTop
          TabOrder = 1
          ExplicitLeft = 2
          ExplicitTop = 9
          ExplicitWidth = 840
          inherited bvl1: TBevel
            Width = 840
            ExplicitWidth = 840
          end
        end
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 760
      ExplicitTop = 650
      ExplicitWidth = 838
      inherited pnlFrmBtnsContainer: TPanel
        ExplicitWidth = 836
        inherited pnlFrmBtnsMain: TPanel
          ExplicitLeft = 737
        end
        inherited pnlFrmBtnsChb: TPanel
          ExplicitLeft = 509
        end
        inherited pnlFrmBtnsR: TPanel
          ExplicitLeft = 638
        end
        inherited pnlFrmBtnsC: TPanel
          ExplicitWidth = 369
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 804
    ExplicitTop = 694
    ExplicitWidth = 848
    inherited lblStatusBarR: TLabel
      Left = 779
      Height = 14
      ExplicitLeft = 779
    end
    inherited lblStatusBarL: TLabel
      Height = 14
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
end
