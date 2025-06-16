inherited FrmOWOrder: TFrmOWOrder
  Caption = 'FrmOWOrder'
  ClientHeight = 707
  ClientWidth = 1295
  OnResize = FormResize
  ExplicitWidth = 1307
  ExplicitHeight = 745
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 1295
    Height = 691
    ExplicitWidth = 1295
    ExplicitHeight = 691
    inherited PMDIClient: TPanel
      Width = 1285
      Height = 642
      ExplicitWidth = 1281
      ExplicitHeight = 641
      object PDividor1: TPanel
        Left = 0
        Top = 324
        Width = 1285
        Height = 20
        Align = alTop
        Caption = 'PDividor1'
        TabOrder = 0
        ExplicitWidth = 1281
        object Bevel1: TBevel
          Left = 1064
          Top = 8
          Width = 50
          Height = 3
        end
      end
      object PHeader2: TPanel
        Left = 0
        Top = 344
        Width = 1285
        Height = 120
        Align = alTop
        Caption = 'PHeader2'
        TabOrder = 1
        ExplicitWidth = 1281
        object PHAddDocs: TPanel
          Left = 984
          Top = 1
          Width = 300
          Height = 118
          Align = alRight
          TabOrder = 0
          ExplicitLeft = 980
          object PHAddDocsCaption: TPanel
            Left = 1
            Top = 1
            Width = 72
            Height = 116
            Align = alLeft
            TabOrder = 0
            object Label5: TLabel
              Left = 9
              Top = 41
              Width = 57
              Height = 26
              Caption = #1042#1085#1077#1096#1085#1080#1077#13#10#1076#1086#1082#1091#1084#1077#1085#1090#1099
            end
          end
          object PHFilesButtons: TPanel
            Left = 272
            Top = 1
            Width = 27
            Height = 116
            Align = alRight
            Caption = 'PHFilesButtons'
            TabOrder = 1
          end
          inline FrgFiles: TFrDBGridEh
            Left = 73
            Top = 1
            Width = 199
            Height = 116
            Margins.Top = 6
            Margins.Bottom = 6
            Align = alClient
            TabOrder = 2
            ExplicitLeft = 73
            ExplicitTop = 1
            ExplicitWidth = 199
            ExplicitHeight = 116
            inherited PGrid: TPanel
              Width = 189
              Height = 62
              ExplicitWidth = 189
              ExplicitHeight = 62
              inherited DbGridEh1: TDBGridEh
                Width = 187
                Height = 39
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
              inherited PStatus: TPanel
                Top = 40
                Width = 187
                ExplicitTop = 40
                ExplicitWidth = 187
                inherited LbStatusBarLeft: TLabel
                  Height = 13
                  ExplicitHeight = 13
                end
              end
            end
            inherited PLeft: TPanel
              Height = 62
              ExplicitHeight = 62
            end
            inherited PTop: TPanel
              Width = 199
              ExplicitWidth = 199
            end
            inherited PContainer: TPanel
              Width = 199
              ExplicitWidth = 199
            end
            inherited PBottom: TPanel
              Top = 116
              Width = 199
              ExplicitTop = 116
              ExplicitWidth = 199
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
        object PHRelatedDocs: TPanel
          Left = 583
          Top = 1
          Width = 401
          Height = 118
          Align = alRight
          Caption = 'PHRelatedDocs'
          TabOrder = 1
          ExplicitLeft = 579
          object PHRelatedDocsCaption: TPanel
            Left = 1
            Top = 1
            Width = 72
            Height = 116
            Align = alLeft
            TabOrder = 0
            object Label1: TLabel
              Left = 9
              Top = 41
              Width = 57
              Height = 26
              Caption = #1057#1074#1103#1079#1072#1085#1085#1099#1077#13#10#1076#1086#1082#1091#1084#1077#1085#1090#1099
            end
          end
          inline FrgReclamations: TFrDBGridEh
            Left = 223
            Top = 1
            Width = 150
            Height = 116
            Margins.Top = 6
            Margins.Bottom = 6
            Align = alLeft
            TabOrder = 1
            ExplicitLeft = 223
            ExplicitTop = 1
            ExplicitWidth = 150
            ExplicitHeight = 116
            inherited PGrid: TPanel
              Width = 140
              Height = 62
              ExplicitWidth = 140
              ExplicitHeight = 62
              inherited DbGridEh1: TDBGridEh
                Width = 138
                Height = 39
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
              inherited PStatus: TPanel
                Top = 40
                Width = 138
                ExplicitTop = 40
                ExplicitWidth = 138
                inherited LbStatusBarLeft: TLabel
                  Height = 13
                  ExplicitHeight = 13
                end
              end
            end
            inherited PLeft: TPanel
              Height = 62
              ExplicitHeight = 62
            end
            inherited PTop: TPanel
              Width = 150
              ExplicitWidth = 150
            end
            inherited PContainer: TPanel
              Width = 150
              ExplicitWidth = 150
            end
            inherited PBottom: TPanel
              Top = 116
              Width = 150
              ExplicitTop = 116
              ExplicitWidth = 150
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
          inline FrgSemiproducts: TFrDBGridEh
            Left = 73
            Top = 1
            Width = 150
            Height = 116
            Margins.Top = 6
            Margins.Bottom = 6
            Align = alLeft
            TabOrder = 2
            ExplicitLeft = 73
            ExplicitTop = 1
            ExplicitWidth = 150
            ExplicitHeight = 116
            inherited PGrid: TPanel
              Width = 140
              Height = 62
              ExplicitWidth = 140
              ExplicitHeight = 62
              inherited DbGridEh1: TDBGridEh
                Width = 138
                Height = 39
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
              inherited PStatus: TPanel
                Top = 40
                Width = 138
                ExplicitTop = 40
                ExplicitWidth = 138
                inherited LbStatusBarLeft: TLabel
                  Height = 13
                  ExplicitHeight = 13
                end
              end
            end
            inherited PLeft: TPanel
              Height = 62
              ExplicitHeight = 62
            end
            inherited PTop: TPanel
              Width = 150
              ExplicitWidth = 150
            end
            inherited PContainer: TPanel
              Width = 150
              ExplicitWidth = 150
            end
            inherited PBottom: TPanel
              Top = 116
              Width = 150
              ExplicitTop = 116
              ExplicitWidth = 150
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
        object PHCommentsLeft: TPanel
          Left = 1
          Top = 1
          Width = 582
          Height = 118
          Align = alClient
          Caption = 'Panel1'
          TabOrder = 2
          ExplicitWidth = 578
          DesignSize = (
            582
            118)
          object DBEditEh1: TDBEditEh
            Left = 65
            Top = 0
            Width = 1041
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            ControlLabel.Width = 60
            ControlLabel.Height = 26
            ControlLabel.Caption = '  '#1055#1088#1080#1095#1080#1085#1099#13#10#1088#1077#1082#1083#1072#1084#1072#1094#1080#1080
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <
              item
                DropDownFormParams.Align = daRight
              end>
            MaxLength = 400
            TabOrder = 0
            Visible = True
            ExplicitWidth = 1037
          end
          object DBMemoEh1: TDBMemoEh
            Left = 65
            Top = 27
            Width = 1042
            Height = 89
            ControlLabel.Width = 62
            ControlLabel.Height = 13
            ControlLabel.Caption = #1044#1086#1087#1086#1083#1085#1077#1085#1080#1077
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            Anchors = [akLeft, akTop, akRight]
            AutoSize = False
            DynProps = <>
            EditButtons = <>
            MaxLength = 4000
            TabOrder = 1
            Visible = True
            WantReturns = True
            ExplicitWidth = 1038
          end
        end
      end
      object PBottom: TPanel
        Left = 0
        Top = 612
        Width = 1285
        Height = 30
        Align = alBottom
        Caption = 'Panel1'
        TabOrder = 2
        ExplicitTop = 611
        ExplicitWidth = 1281
      end
      object PTop: TPanel
        Left = 0
        Top = 0
        Width = 1285
        Height = 88
        Align = alTop
        Caption = 'PTop'
        TabOrder = 3
        ExplicitWidth = 1281
      end
      object PHeaderTop: TPanel
        Left = 0
        Top = 88
        Width = 1285
        Height = 236
        Align = alTop
        TabOrder = 4
        ExplicitWidth = 1281
        object PHDates: TPanel
          Left = 697
          Top = 1
          Width = 193
          Height = 234
          Align = alLeft
          TabOrder = 0
          object De_dt: TDBDateTimeEditEh
            Left = 72
            Top = 9
            Width = 115
            Height = 21
            ControlLabel.Width = 62
            ControlLabel.Height = 26
            ControlLabel.Caption = #1044#1072#1090#1072#13#10#1086#1092#1086#1088#1084#1083#1077#1085#1080#1103
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            Kind = dtkDateEh
            TabOrder = 0
            Visible = True
          end
          object De_dt_otgr: TDBDateTimeEditEh
            Left = 72
            Top = 95
            Width = 115
            Height = 21
            ControlLabel.Width = 64
            ControlLabel.Height = 26
            ControlLabel.Caption = #1044#1072#1090#1072'            '#13#10#1086#1090#1075#1088#1091#1079#1082#1080'      '
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            Kind = dtkDateEh
            TabOrder = 2
            Visible = True
          end
          object De_dt_change: TDBDateTimeEditEh
            Left = 72
            Top = 36
            Width = 115
            Height = 21
            ControlLabel.Width = 62
            ControlLabel.Height = 26
            ControlLabel.Caption = #1044#1072#1090#1072#13#10#1080#1079#1084#1077#1085#1077#1085#1080#1103'   '
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            Enabled = False
            EditButton.Visible = False
            EditButtons = <>
            Kind = dtkDateTimeEh
            TabOrder = 1
            Visible = True
          end
          object De_dt_montage_beg: TDBDateTimeEditEh
            Left = 72
            Top = 122
            Width = 115
            Height = 21
            ControlLabel.Width = 65
            ControlLabel.Height = 26
            ControlLabel.Caption = #1044#1072#1090#1072' '#1085#1072#1095#1072#1083#1072#13#10#1084#1086#1085#1090#1072#1078#1072'       '
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            Kind = dtkDateEh
            TabOrder = 3
            Visible = True
          end
          object De_dt_montage_end: TDBDateTimeEditEh
            Left = 72
            Top = 149
            Width = 115
            Height = 21
            ControlLabel.Width = 65
            ControlLabel.Height = 26
            ControlLabel.Caption = #1044#1072#1090#1072' '#1086#1082#1086#1085#1095'.'#13#10#1084#1086#1085#1090#1072#1078#1072'       '
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            Kind = dtkDateEh
            TabOrder = 4
            Visible = True
          end
          object De_dt_beg: TDBDateTimeEditEh
            Left = 72
            Top = 63
            Width = 115
            Height = 21
            ControlLabel.Width = 64
            ControlLabel.Height = 26
            ControlLabel.Caption = #1055#1083#1072#1085'. '#1076#1072#1090#1072#13#10#1079#1072#1087#1091#1089#1082#1072'        '
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            Kind = dtkDateEh
            TabOrder = 5
            Visible = True
          end
        end
        object PHCustomer: TPanel
          Left = 341
          Top = 1
          Width = 356
          Height = 234
          Align = alLeft
          TabOrder = 1
          DesignSize = (
            356
            234)
          object DBComboBoxEh1: TDBComboBoxEh
            Left = 86
            Top = 11
            Width = 262
            Height = 21
            ControlLabel.Width = 47
            ControlLabel.Height = 13
            ControlLabel.Caption = #1047#1072#1082#1072#1079#1095#1080#1082
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            Anchors = [akLeft, akTop, akRight]
            DynProps = <>
            EditButtons = <>
            MaxLength = 400
            TabOrder = 0
            Visible = True
          end
          object DBComboBoxEh2: TDBComboBoxEh
            Left = 86
            Top = 38
            Width = 262
            Height = 21
            ControlLabel.Width = 61
            ControlLabel.Height = 26
            ControlLabel.Caption = #1050#1086#1085#1090#1072#1082#1090#1085#1086#1077#13#10#1083#1080#1094#1086
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            Anchors = [akLeft, akTop, akRight]
            DynProps = <>
            EditButtons = <>
            MaxLength = 400
            TabOrder = 1
            Visible = True
          end
          object DBEditEh2: TDBEditEh
            Left = 86
            Top = 65
            Width = 262
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            ControlLabel.Width = 51
            ControlLabel.Height = 13
            ControlLabel.Caption = #1050#1086#1085#1090#1072#1082#1090#1099
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            MaxLength = 400
            TabOrder = 2
            Visible = True
          end
          object Cb_legalname: TDBComboBoxEh
            Left = 86
            Top = 92
            Width = 186
            Height = 21
            ControlLabel.Width = 72
            ControlLabel.Height = 26
            ControlLabel.Caption = #1070#1088#1080#1076#1080#1095#1077#1089#1082#1086#1077#13#10#1085#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            Anchors = [akLeft, akTop, akRight]
            DynProps = <>
            EditButtons = <>
            MaxLength = 400
            TabOrder = 3
            Visible = True
          end
          object E_account: TDBEditEh
            Left = 271
            Top = 92
            Width = 79
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            ControlLabel.Caption = #1048#1053#1053
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            MaxLength = 12
            TabOrder = 4
            Text = '123456789023'
            Visible = True
          end
          object DBEditEh4: TDBEditEh
            Left = 232
            Top = 118
            Width = 116
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            ControlLabel.Width = 31
            ControlLabel.Height = 26
            ControlLabel.Caption = #1053#1086#1084#1077#1088#13#10#1089#1095#1077#1090#1072
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            MaxLength = 400
            TabOrder = 6
            Visible = True
          end
          object Cb_CashType: TDBComboBoxEh
            Left = 88
            Top = 119
            Width = 105
            Height = 21
            ControlLabel.Width = 60
            ControlLabel.Height = 13
            ControlLabel.Caption = #1042#1080#1076' '#1086#1087#1083#1072#1090#1099
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 5
            Text = #1073'/'#1085' ('#1085#1077#1090' '#1089#1095#1077#1090#1072')'
            Visible = True
          end
          object E_address: TDBEditEh
            Left = 88
            Top = 145
            Width = 260
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            ControlLabel.Width = 46
            ControlLabel.Height = 26
            ControlLabel.Caption = #1040#1076#1088#1077#1089#13#10#1086#1090#1075#1088#1091#1079#1082#1080
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            MaxLength = 400
            TabOrder = 7
            Visible = True
          end
        end
        object PHOrder: TPanel
          Left = 1
          Top = 1
          Width = 340
          Height = 234
          Align = alLeft
          TabOrder = 2
          DesignSize = (
            340
            234)
          object Cb_id_organization: TDBComboBoxEh
            Left = 66
            Top = 65
            Width = 143
            Height = 21
            ControlLabel.Width = 48
            ControlLabel.Height = 13
            ControlLabel.Caption = #1070#1088'. '#1051#1080#1094#1086
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            Anchors = [akLeft, akTop, akRight]
            DynProps = <>
            EditButtons = <>
            TabOrder = 0
            Visible = True
          end
          object E_ornum: TDBEditEh
            Left = 65
            Top = 38
            Width = 70
            Height = 21
            ControlLabel.Width = 29
            ControlLabel.Height = 13
            ControlLabel.Caption = #1047#1072#1082#1072#1079
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            Enabled = False
            TabOrder = 2
            Visible = True
          end
          object Cb_id_or_format_estimates: TDBComboBoxEh
            Left = 65
            Top = 92
            Width = 269
            Height = 21
            ControlLabel.Width = 42
            ControlLabel.Height = 26
            ControlLabel.Caption = #1060#1086#1088#1084#1072#1090#13#10#1080#1079#1076#1077#1083#1080#1081
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            Anchors = [akLeft, akTop, akRight]
            DynProps = <>
            EditButtons = <>
            MaxLength = 400
            TabOrder = 4
            Visible = True
          end
          object Cb_project: TDBComboBoxEh
            Left = 65
            Top = 119
            Width = 269
            Height = 21
            ControlLabel.Width = 37
            ControlLabel.Height = 13
            ControlLabel.Caption = #1055#1088#1086#1077#1082#1090
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            Anchors = [akLeft, akTop, akRight]
            DynProps = <>
            EditButtons = <>
            MaxLength = 400
            TabOrder = 5
            Visible = True
          end
          object E_managername: TDBEditEh
            Left = 66
            Top = 146
            Width = 88
            Height = 21
            ControlLabel.Width = 53
            ControlLabel.Height = 13
            ControlLabel.Caption = #1052#1077#1085#1077#1076#1078#1077#1088
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 6
            Text = #1055#1088#1086#1082#1086#1087#1077#1085#1082#1086' '#1057'.'#1042'.'
            Visible = True
          end
          object Cb_main: TDBComboBoxEh
            Left = 152
            Top = 38
            Width = 100
            Height = 21
            ControlLabel.Width = 6
            ControlLabel.Height = 13
            ControlLabel.Caption = #1082
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <
              item
                Style = ebsEllipsisEh
              end>
            MaxLength = 400
            TabOrder = 3
            Visible = True
          end
          object Cb_Area: TDBComboBoxEh
            Left = 280
            Top = 65
            Width = 54
            Height = 21
            ControlLabel.Width = 53
            ControlLabel.Height = 13
            ControlLabel.Caption = #1055#1083#1086#1097#1072#1076#1082#1072
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            Anchors = [akTop, akRight]
            DynProps = <>
            EditButtons = <>
            TabOrder = 1
            Visible = True
          end
          object Cb_id_ordertype: TDBComboBoxEh
            Left = 65
            Top = 11
            Width = 269
            Height = 21
            ControlLabel.Width = 34
            ControlLabel.Height = 26
            ControlLabel.Caption = #1058#1080#1087#13#10#1079#1072#1082#1072#1079#1072
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            Anchors = [akLeft, akTop, akRight]
            DynProps = <>
            EditButtons = <>
            MaxLength = 400
            TabOrder = 7
            Visible = True
          end
          object E_planningname: TDBEditEh
            Left = 246
            Top = 146
            Width = 88
            Height = 21
            Anchors = [akTop, akRight]
            ControlLabel.Width = 45
            ControlLabel.Height = 26
            ControlLabel.Caption = #1048#1085#1078#1077#1085#1077#1088#13#10#1087#1086' '#1087#1083#1072#1085'.'
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 8
            Text = #1055#1088#1086#1082#1086#1087#1077#1085#1082#1086' '#1057'.'#1042'.'
            Visible = True
          end
        end
        object PHFin: TPanel
          Left = 890
          Top = 1
          Width = 391
          Height = 234
          Align = alLeft
          Caption = 'PHFin'
          TabOrder = 3
          object PHSum: TPanel
            Left = 1
            Top = 26
            Width = 389
            Height = 144
            Align = alTop
            TabOrder = 0
            object DBNumberEditEh26: TDBNumberEditEh
              Left = 64
              Top = 117
              Width = 95
              Height = 21
              ControlLabel.Width = 54
              ControlLabel.Height = 26
              ControlLabel.Caption = #1057#1090#1086#1080#1084#1086#1089#1090#1100#13#10#1076#1086#1089#1090#1072#1074#1082#1080
              ControlLabel.Visible = True
              ControlLabelLocation.Position = lpLeftCenterEh
              currency = True
              DynProps = <>
              EditButton.DefaultAction = True
              EditButton.Visible = True
              EditButtons = <>
              TabOrder = 12
              Value = 12235123.050000000000000000
              Visible = True
            end
            object DBNumberEditEh27: TDBNumberEditEh
              Left = 64
              Top = 90
              Width = 95
              Height = 21
              ControlLabel.Width = 54
              ControlLabel.Height = 26
              ControlLabel.Caption = #1057#1090#1086#1080#1084#1086#1089#1090#1100#13#10#1084#1086#1085#1090#1072#1078#1072
              ControlLabel.Visible = True
              ControlLabelLocation.Position = lpLeftCenterEh
              currency = True
              DynProps = <>
              EditButton.DefaultAction = True
              EditButton.Visible = True
              EditButtons = <>
              TabOrder = 8
              Value = 12235123.050000000000000000
              Visible = True
            end
            object DBNumberEditEh28: TDBNumberEditEh
              Left = 63
              Top = 63
              Width = 95
              Height = 21
              ControlLabel.Width = 55
              ControlLabel.Height = 26
              ControlLabel.Caption = #1044#1086#1087'.'#13#10#1082#1086#1084#1087#1083'.       '
              ControlLabel.Visible = True
              ControlLabelLocation.Position = lpLeftCenterEh
              currency = True
              DynProps = <>
              Enabled = False
              EditButton.DefaultAction = True
              EditButtons = <>
              TabOrder = 4
              Value = 12235123.050000000000000000
              Visible = True
            end
            object Ne_sum_i: TDBNumberEditEh
              Left = 64
              Top = 36
              Width = 95
              Height = 21
              ControlLabel.Width = 55
              ControlLabel.Height = 13
              ControlLabel.Caption = #1048#1079#1076#1077#1083#1080#1103'    '
              ControlLabel.Visible = True
              ControlLabelLocation.Position = lpLeftCenterEh
              currency = True
              DynProps = <>
              Enabled = False
              EditButton.DefaultAction = True
              EditButtons = <>
              TabOrder = 0
              Value = 12235123.050000000000000000
              Visible = True
            end
            object DBNumberEditEh30: TDBNumberEditEh
              Left = 172
              Top = 36
              Width = 41
              Height = 21
              ControlLabel.Width = 8
              ControlLabel.Height = 13
              ControlLabel.Caption = '+'
              ControlLabel.Visible = True
              ControlLabelLocation.Position = lpLeftCenterEh
              currency = False
              DynProps = <>
              EditButton.DefaultAction = True
              EditButtons = <>
              MaxValue = 500.000000000000000000
              TabOrder = 1
              Value = 12235123.050000000000000000
              Visible = True
            end
            object DBNumberEditEh31: TDBNumberEditEh
              Left = 228
              Top = 36
              Width = 41
              Height = 21
              ControlLabel.Width = 4
              ControlLabel.Height = 13
              ControlLabel.Caption = '-'
              ControlLabel.Visible = True
              ControlLabelLocation.Position = lpLeftCenterEh
              currency = False
              DynProps = <>
              EditButton.DefaultAction = True
              EditButtons = <>
              MaxValue = 100.000000000000000000
              TabOrder = 2
              Value = 12235123.050000000000000000
              Visible = True
            end
            object DBNumberEditEh32: TDBNumberEditEh
              Left = 284
              Top = 36
              Width = 95
              Height = 21
              ControlLabel.Width = 8
              ControlLabel.Height = 13
              ControlLabel.Caption = '='
              ControlLabel.Visible = True
              ControlLabelLocation.Position = lpLeftCenterEh
              currency = True
              DynProps = <>
              Enabled = False
              EditButton.DefaultAction = True
              EditButtons = <>
              TabOrder = 3
              Value = 12235123.050000000000000000
              Visible = True
            end
            object DBNumberEditEh33: TDBNumberEditEh
              Left = 172
              Top = 63
              Width = 41
              Height = 21
              ControlLabel.Width = 8
              ControlLabel.Height = 13
              ControlLabel.Caption = '+'
              ControlLabel.Visible = True
              ControlLabelLocation.Position = lpLeftCenterEh
              currency = False
              DynProps = <>
              EditButton.DefaultAction = True
              EditButtons = <>
              MaxValue = 500.000000000000000000
              TabOrder = 5
              Value = 12235123.050000000000000000
              Visible = True
            end
            object DBNumberEditEh34: TDBNumberEditEh
              Left = 229
              Top = 63
              Width = 41
              Height = 21
              ControlLabel.Width = 4
              ControlLabel.Height = 13
              ControlLabel.Caption = '-'
              ControlLabel.Visible = True
              ControlLabelLocation.Position = lpLeftCenterEh
              currency = False
              DynProps = <>
              EditButton.DefaultAction = True
              EditButtons = <>
              MaxValue = 100.000000000000000000
              TabOrder = 6
              Value = 12235123.050000000000000000
              Visible = True
            end
            object DBNumberEditEh35: TDBNumberEditEh
              Left = 284
              Top = 63
              Width = 95
              Height = 21
              ControlLabel.Width = 8
              ControlLabel.Height = 13
              ControlLabel.Caption = '='
              ControlLabel.Visible = True
              ControlLabelLocation.Position = lpLeftCenterEh
              currency = True
              DynProps = <>
              Enabled = False
              EditButton.DefaultAction = True
              EditButtons = <>
              TabOrder = 7
              Value = 12235123.050000000000000000
              Visible = True
            end
            object DBNumberEditEh36: TDBNumberEditEh
              Left = 172
              Top = 90
              Width = 41
              Height = 21
              ControlLabel.Width = 8
              ControlLabel.Height = 13
              ControlLabel.Caption = '+'
              ControlLabel.Visible = True
              ControlLabelLocation.Position = lpLeftCenterEh
              currency = False
              DynProps = <>
              EditButton.DefaultAction = True
              EditButtons = <>
              MaxValue = 500.000000000000000000
              TabOrder = 9
              Value = 12235123.050000000000000000
              Visible = True
            end
            object DBNumberEditEh37: TDBNumberEditEh
              Left = 228
              Top = 90
              Width = 41
              Height = 21
              ControlLabel.Width = 4
              ControlLabel.Height = 13
              ControlLabel.Caption = '-'
              ControlLabel.Visible = True
              ControlLabelLocation.Position = lpLeftCenterEh
              currency = False
              DynProps = <>
              EditButton.DefaultAction = True
              EditButtons = <>
              MaxValue = 100.000000000000000000
              TabOrder = 10
              Value = 12235123.050000000000000000
              Visible = True
            end
            object DBNumberEditEh38: TDBNumberEditEh
              Left = 284
              Top = 90
              Width = 95
              Height = 21
              ControlLabel.Width = 8
              ControlLabel.Height = 13
              ControlLabel.Caption = '='
              ControlLabel.Visible = True
              ControlLabelLocation.Position = lpLeftCenterEh
              currency = True
              DynProps = <>
              Enabled = False
              EditButton.DefaultAction = True
              EditButtons = <>
              TabOrder = 11
              Value = 12235123.050000000000000000
              Visible = True
            end
            object DBNumberEditEh39: TDBNumberEditEh
              Left = 172
              Top = 117
              Width = 41
              Height = 21
              ControlLabel.Width = 8
              ControlLabel.Height = 13
              ControlLabel.Caption = '+'
              ControlLabel.Visible = True
              ControlLabelLocation.Position = lpLeftCenterEh
              currency = False
              DynProps = <>
              EditButton.DefaultAction = True
              EditButtons = <>
              MaxValue = 500.000000000000000000
              TabOrder = 13
              Value = 12235123.050000000000000000
              Visible = True
            end
            object DBNumberEditEh40: TDBNumberEditEh
              Left = 228
              Top = 117
              Width = 41
              Height = 21
              ControlLabel.Width = 4
              ControlLabel.Height = 13
              ControlLabel.Caption = '-'
              ControlLabel.Visible = True
              ControlLabelLocation.Position = lpLeftCenterEh
              currency = False
              DynProps = <>
              EditButton.DefaultAction = True
              EditButtons = <>
              MaxValue = 100.000000000000000000
              TabOrder = 14
              Value = 12235123.050000000000000000
              Visible = True
            end
            object DBNumberEditEh41: TDBNumberEditEh
              Left = 284
              Top = 117
              Width = 95
              Height = 21
              ControlLabel.Width = 8
              ControlLabel.Height = 13
              ControlLabel.Caption = '='
              ControlLabel.Visible = True
              ControlLabelLocation.Position = lpLeftCenterEh
              currency = True
              DynProps = <>
              Enabled = False
              EditButton.DefaultAction = True
              EditButtons = <>
              TabOrder = 15
              Value = 12235123.050000000000000000
              Visible = True
            end
          end
          object PHTotalSum: TPanel
            Left = 1
            Top = 170
            Width = 389
            Height = 41
            Align = alTop
            Caption = 'PHTotalSum'
            TabOrder = 1
            object DBNumberEditEh42: TDBNumberEditEh
              Left = 64
              Top = 6
              Width = 89
              Height = 21
              ControlLabel.Width = 30
              ControlLabel.Height = 13
              ControlLabel.Caption = #1048#1090#1086#1075#1086
              ControlLabel.Visible = True
              ControlLabelLocation.Position = lpLeftCenterEh
              currency = True
              DynProps = <>
              Enabled = False
              EditButton.DefaultAction = True
              EditButtons = <>
              TabOrder = 0
              Value = 12235123.050000000000000000
              Visible = True
            end
            object DBNumberEditEh43: TDBNumberEditEh
              Left = 185
              Top = 6
              Width = 80
              Height = 21
              ControlLabel.Width = 22
              ControlLabel.Height = 26
              ControlLabel.Caption = #1041#1077#1079#13#10#1053#1044#1057
              ControlLabel.Visible = True
              ControlLabelLocation.Position = lpLeftCenterEh
              currency = True
              DynProps = <>
              Enabled = False
              EditButton.DefaultAction = True
              EditButtons = <>
              TabOrder = 1
              Value = 12235123.050000000000000000
              Visible = True
            end
            object DBNumberEditEh44: TDBNumberEditEh
              Left = 300
              Top = 6
              Width = 77
              Height = 21
              ControlLabel.Width = 30
              ControlLabel.Height = 13
              ControlLabel.Caption = #1040#1074#1072#1085#1089
              ControlLabel.Visible = True
              ControlLabelLocation.Position = lpLeftCenterEh
              currency = True
              DynProps = <>
              Enabled = False
              EditButton.DefaultAction = True
              EditButtons = <>
              TabOrder = 2
              Value = 12235123.050000000000000000
              Visible = True
            end
          end
          object PHFinCaptions: TPanel
            Left = 1
            Top = 1
            Width = 389
            Height = 25
            Align = alTop
            TabOrder = 2
            object Label10: TLabel
              Left = 64
              Top = 4
              Width = 90
              Height = 13
              Caption = #1057#1091#1084#1084#1072' '#1073#1077#1079' '#1089#1082#1080#1076#1082#1080
            end
            object Label11: TLabel
              Left = 172
              Top = 4
              Width = 43
              Height = 13
              Caption = #1053#1072#1094#1077#1085#1082#1072
            end
            object Label12: TLabel
              Left = 229
              Top = 4
              Width = 38
              Height = 13
              Caption = #1057#1082#1080#1076#1082#1072
            end
            object Label13: TLabel
              Left = 284
              Top = 4
              Width = 30
              Height = 13
              Caption = #1048#1090#1086#1075#1086
            end
          end
        end
      end
      object PGrid: TPanel
        Left = 0
        Top = 464
        Width = 1285
        Height = 148
        Align = alClient
        Caption = 'PGrid'
        TabOrder = 5
        ExplicitWidth = 1281
        ExplicitHeight = 147
        inline FrgItems: TFrDBGridEh
          Left = 1
          Top = 1
          Width = 1283
          Height = 146
          Align = alClient
          TabOrder = 0
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 1279
          ExplicitHeight = 145
          inherited PGrid: TPanel
            Width = 1273
            Height = 92
            ExplicitWidth = 1269
            ExplicitHeight = 91
            inherited DbGridEh1: TDBGridEh
              Width = 1271
              Height = 69
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
                ExplicitHeight = 29
                inherited PRowDetailPanel: TPanel
                  Width = 44
                  Height = 27
                  ExplicitWidth = 44
                  ExplicitHeight = 27
                end
              end
            end
            inherited PStatus: TPanel
              Top = 70
              Width = 1271
              ExplicitTop = 69
              ExplicitWidth = 1267
              inherited LbStatusBarLeft: TLabel
                Height = 13
                ExplicitHeight = 13
              end
            end
          end
          inherited PLeft: TPanel
            Height = 92
            ExplicitHeight = 91
          end
          inherited PTop: TPanel
            Width = 1283
            ExplicitWidth = 1279
          end
          inherited PContainer: TPanel
            Width = 1283
            ExplicitWidth = 1279
          end
          inherited PBottom: TPanel
            Top = 146
            Width = 1283
            ExplicitTop = 145
            ExplicitWidth = 1279
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
    inherited PDlgPanel: TPanel
      Top = 647
      Width = 1285
      ExplicitTop = 646
      ExplicitWidth = 1281
      inherited BvDlg: TBevel
        Width = 1283
        ExplicitWidth = 1812
      end
      inherited BvDlgBottom: TBevel
        Width = 1283
        ExplicitWidth = 1812
      end
      inherited PDlgMain: TPanel
        Width = 1283
        ExplicitWidth = 1279
        inherited PDlgBtnForm: TPanel
          Left = 1184
          ExplicitLeft = 1180
        end
        inherited PDlgChb: TPanel
          Left = 956
          ExplicitLeft = 952
        end
        inherited PDlgBtnR: TPanel
          Left = 1085
          ExplicitLeft = 1081
        end
        inherited PDlgCenter: TPanel
          Width = 816
          ExplicitWidth = 812
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 691
    Width = 1295
    ExplicitTop = 690
    ExplicitWidth = 1291
    inherited LbStatusBarRight: TLabel
      Left = 1203
      Height = 14
      ExplicitLeft = 1203
    end
    inherited LbStatusBarLeft: TLabel
      Height = 14
    end
  end
  inherited Timer_AfterStart: TTimer
    Left = 224
    Top = 784
  end
end
