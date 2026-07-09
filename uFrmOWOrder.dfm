inherited FrmOWOrder: TFrmOWOrder
  Caption = 'FrmOWOrder'
  ClientHeight = 705
  ClientWidth = 1287
  OnResize = FormResize
  ExplicitWidth = 1299
  ExplicitHeight = 743
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 1287
    Height = 689
    ExplicitWidth = 1287
    ExplicitHeight = 689
    inherited pnlFrmClient: TPanel
      Width = 1277
      Height = 640
      ExplicitWidth = 1273
      ExplicitHeight = 639
      object PDividor1: TPanel
        Left = 0
        Top = 324
        Width = 1277
        Height = 20
        Align = alTop
        Caption = 'PDividor1'
        TabOrder = 0
        ExplicitWidth = 1273
        object bvl1: TBevel
          Left = 1064
          Top = 8
          Width = 50
          Height = 3
        end
      end
      object PHeader2: TPanel
        Left = 0
        Top = 344
        Width = 1277
        Height = 120
        Align = alTop
        Caption = 'PHeader2'
        TabOrder = 1
        ExplicitWidth = 1273
        object PHAddDocs: TPanel
          Left = 663
          Top = 1
          Width = 300
          Height = 118
          Align = alRight
          TabOrder = 0
          ExplicitLeft = 659
          inline FrgFiles: TFrDBGridEh
            Left = 1
            Top = 19
            Width = 298
            Height = 98
            Margins.Top = 6
            Margins.Bottom = 6
            Align = alClient
            TabOrder = 0
            ExplicitLeft = 1
            ExplicitTop = 19
            ExplicitWidth = 298
            ExplicitHeight = 98
            inherited pnlGrid: TPanel
              Width = 288
              Height = 44
              ExplicitWidth = 288
              ExplicitHeight = 44
              inherited DbGridEh1: TDBGridEh
                Width = 286
                Height = 21
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
                Top = 22
                Width = 286
                ExplicitTop = 22
                ExplicitWidth = 286
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
              Height = 44
              ExplicitHeight = 44
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
              Top = 98
              Width = 298
              ExplicitTop = 98
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
          inline frmpcAddDocs: TFrMyPanelCaption
            Left = 1
            Top = 1
            Width = 298
            Height = 18
            Align = alTop
            TabOrder = 1
            ExplicitLeft = 1
            ExplicitTop = 1
            ExplicitWidth = 298
            inherited bvl1: TBevel
              Width = 298
              ExplicitWidth = 707
            end
          end
        end
        object PHRelatedDocs: TPanel
          Left = 963
          Top = 1
          Width = 313
          Height = 118
          Align = alRight
          Caption = 'PHRelatedDocs'
          TabOrder = 1
          ExplicitLeft = 959
          inline frmpcRelatedDocs: TFrMyPanelCaption
            Left = 1
            Top = 1
            Width = 311
            Height = 18
            Align = alTop
            TabOrder = 0
            ExplicitLeft = 1
            ExplicitTop = 1
            ExplicitWidth = 311
            inherited bvl1: TBevel
              Width = 311
              ExplicitWidth = 707
            end
          end
          inline FrgRelatedOrders: TFrDBGridEh
            Left = 1
            Top = 19
            Width = 311
            Height = 98
            Margins.Top = 6
            Margins.Bottom = 6
            Align = alClient
            TabOrder = 1
            ExplicitLeft = 1
            ExplicitTop = 19
            ExplicitWidth = 311
            ExplicitHeight = 98
            inherited pnlGrid: TPanel
              Top = 75
              Width = 301
              Height = 23
              ExplicitTop = 75
              ExplicitWidth = 301
              ExplicitHeight = 23
              inherited DbGridEh1: TDBGridEh
                Width = 299
                Height = 0
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
                Top = 1
                Width = 299
                ExplicitTop = 1
                ExplicitWidth = 299
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
              Top = 75
              Height = 23
              ExplicitTop = 75
              ExplicitHeight = 23
            end
            inherited pnlTop: TPanel
              Top = 70
              Width = 311
              ExplicitTop = 70
              ExplicitWidth = 311
            end
            inherited pnlContainer: TPanel
              Width = 311
              Height = 70
              ExplicitWidth = 311
              ExplicitHeight = 70
            end
            inherited pnlBottom: TPanel
              Top = 98
              Width = 311
              ExplicitTop = 98
              ExplicitWidth = 311
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
        object PHCommentsLeft: TPanel
          Left = 1
          Top = 1
          Width = 344
          Height = 118
          Align = alLeft
          Caption = 'pnl1'
          TabOrder = 2
          object m_comm: TDBMemoEh
            Left = 1
            Top = 41
            Width = 342
            Height = 76
            ControlLabel.Caption = #1044#1086#1087#1086#1083#1085#1077#1085#1080#1077
            ControlLabelLocation.Position = lpLeftCenterEh
            ScrollBars = ssVertical
            Align = alClient
            AutoSize = False
            DynProps = <>
            EditButtons = <>
            MaxLength = 4000
            TabOrder = 0
            Visible = True
            WantReturns = True
          end
          inline frmpcComments: TFrMyPanelCaption
            Left = 1
            Top = 1
            Width = 342
            Height = 18
            Align = alTop
            TabOrder = 1
            ExplicitLeft = 1
            ExplicitTop = 1
            ExplicitWidth = 342
            inherited bvl1: TBevel
              Width = 342
              ExplicitWidth = 707
            end
          end
          object pnlReclamation: TPanel
            Left = 1
            Top = 19
            Width = 342
            Height = 22
            Align = alTop
            Caption = 'pnlReclamation'
            TabOrder = 2
            object ed_reclamation_caption: TDBEditEh
              Left = 1
              Top = 1
              Width = 70
              Height = 20
              Align = alLeft
              DynProps = <>
              EditButtons = <>
              ReadOnly = True
              TabOrder = 0
              Text = #1056#1077#1082#1083#1072#1084#1072#1094#1080#1103':'
              Visible = True
              ExplicitHeight = 21
            end
            object edt_Complaints: TDBEditEh
              Left = 71
              Top = 1
              Width = 270
              Height = 20
              Align = alClient
              ControlLabel.Width = 60
              ControlLabel.Height = 26
              ControlLabel.Caption = #1055#1088#1080#1095#1080#1085#1099#13#10#1088#1077#1082#1083#1072#1084#1072#1094#1080#1080
              ControlLabel.Visible = True
              ControlLabelLocation.Position = lpLeftCenterEh
              DynProps = <>
              EditButtons = <
                item
                  DropDownFormParams.Align = daRight
                end>
              MaxLength = 400
              TabOrder = 1
              Visible = True
              ExplicitHeight = 21
            end
          end
        end
        object PHlBasis: TPanel
          Left = 345
          Top = 1
          Width = 288
          Height = 118
          Align = alLeft
          Caption = 'PHlBasis'
          TabOrder = 3
          object pnlBasisComm: TPanel
            Left = 1
            Top = 19
            Width = 72
            Height = 81
            Align = alLeft
            Caption = 'PHlBasis'
            TabOrder = 0
            object m_basis: TDBMemoEh
              Left = 1
              Top = 1
              Width = 70
              Height = 79
              ControlLabel.Caption = #1044#1086#1087#1086#1083#1085#1077#1085#1080#1077
              ControlLabelLocation.Position = lpLeftCenterEh
              ScrollBars = ssVertical
              Align = alClient
              AutoSize = False
              DynProps = <>
              EditButtons = <>
              MaxLength = 4000
              TabOrder = 0
              Visible = True
              WantReturns = True
            end
          end
          inline FrgBasis: TFrDBGridEh
            Left = 73
            Top = 19
            Width = 214
            Height = 81
            Margins.Top = 6
            Margins.Bottom = 6
            Align = alClient
            TabOrder = 1
            ExplicitLeft = 73
            ExplicitTop = 19
            ExplicitWidth = 214
            ExplicitHeight = 81
            inherited pnlGrid: TPanel
              Width = 204
              Height = 27
              ExplicitWidth = 204
              ExplicitHeight = 27
              inherited DbGridEh1: TDBGridEh
                Width = 202
                Height = 4
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
                Top = 5
                Width = 202
                ExplicitTop = 5
                ExplicitWidth = 202
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
              Height = 27
              ExplicitHeight = 27
            end
            inherited pnlTop: TPanel
              Width = 214
              ExplicitWidth = 214
            end
            inherited pnlContainer: TPanel
              Width = 214
              ExplicitWidth = 214
            end
            inherited pnlBottom: TPanel
              Top = 81
              Width = 214
              ExplicitTop = 81
              ExplicitWidth = 214
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
          inline frmpcBasis: TFrMyPanelCaption
            Left = 1
            Top = 1
            Width = 286
            Height = 18
            Align = alTop
            TabOrder = 2
            ExplicitLeft = 1
            ExplicitTop = 1
            ExplicitWidth = 286
            inherited bvl1: TBevel
              Width = 286
              ExplicitWidth = 707
            end
          end
          object pnlBasisInfo: TPanel
            Left = 1
            Top = 100
            Width = 286
            Height = 17
            Align = alBottom
            Caption = 'pnlBasisInfo'
            Color = clWhite
            ParentBackground = False
            TabOrder = 3
            object lblBasisInfo: TLabel
              Left = 1
              Top = 1
              Width = 284
              Height = 15
              Align = alClient
              Caption = '3 '#1087#1088#1080#1082#1088#1077#1087#1083#1077#1085#1085#1099#1093' '#1092#1072#1081#1083#1072
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = [fsUnderline]
              ParentFont = False
              OnClick = lblBasisInfoClick
              ExplicitWidth = 124
              ExplicitHeight = 13
            end
          end
        end
      end
      object pnlBottom: TPanel
        Left = 0
        Top = 610
        Width = 1277
        Height = 30
        Align = alBottom
        Caption = 'pnl1'
        TabOrder = 2
        ExplicitTop = 609
        ExplicitWidth = 1273
      end
      object pnlTop: TPanel
        Left = 0
        Top = 0
        Width = 1277
        Height = 88
        Align = alTop
        Caption = 'pnlTop'
        TabOrder = 3
        ExplicitWidth = 1273
        object pnlSelectAreas: TPanel
          Left = 1
          Top = 40
          Width = 1275
          Height = 47
          Align = alBottom
          Caption = 'pnlSelectAreas'
          TabOrder = 0
          ExplicitWidth = 1271
        end
        object pnlOrderInfo: TPanel
          Left = 1
          Top = 1
          Width = 1275
          Height = 41
          Align = alTop
          BorderWidth = 2
          BorderStyle = bsSingle
          Caption = 'pnlOrderInfo'
          Color = clBlack
          ParentBackground = False
          TabOrder = 1
          ExplicitWidth = 1271
          object lbl_ITM: TLabel
            Left = 9
            Top = 2
            Width = 54
            Height = 29
            Caption = #1048#1058#1052
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clHotLight
            Font.Height = -24
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
          end
          object lbl_status_itm: TLabel
            Left = 81
            Top = 12
            Width = 66
            Height = 13
            Caption = 'lbl_status_itm'
          end
        end
      end
      object PHeaderTop: TPanel
        Left = 0
        Top = 88
        Width = 1277
        Height = 236
        Align = alTop
        TabOrder = 4
        ExplicitWidth = 1273
        object PHDates: TPanel
          Left = 701
          Top = 1
          Width = 193
          Height = 234
          Align = alLeft
          TabOrder = 0
          object dedt_dt: TDBDateTimeEditEh
            Left = 72
            Top = 25
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
          object dedt_dt_otgr: TDBDateTimeEditEh
            Left = 72
            Top = 111
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
          object dedt_dt_change: TDBDateTimeEditEh
            Left = 72
            Top = 52
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
          object dedt_dt_montage_beg: TDBDateTimeEditEh
            Left = 72
            Top = 138
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
          object dedt_dt_montage_end: TDBDateTimeEditEh
            Left = 72
            Top = 165
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
          object dedt_dt_beg: TDBDateTimeEditEh
            Left = 72
            Top = 79
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
          inline frmpcDates: TFrMyPanelCaption
            Left = 1
            Top = 1
            Width = 191
            Height = 18
            Align = alTop
            TabOrder = 6
            ExplicitLeft = 1
            ExplicitTop = 1
            ExplicitWidth = 191
            inherited bvl1: TBevel
              Width = 191
              ExplicitWidth = 707
            end
          end
        end
        object PHCustomer: TPanel
          Left = 345
          Top = 1
          Width = 356
          Height = 234
          Align = alLeft
          TabOrder = 1
          DesignSize = (
            356
            234)
          object cmb_customer: TDBComboBoxEh
            Left = 78
            Top = 27
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
          object cmb_customerman: TDBComboBoxEh
            Left = 78
            Top = 54
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
          object edt_customercontact: TDBEditEh
            Left = 78
            Top = 81
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
          object cmb_customerlegal: TDBComboBoxEh
            Left = 78
            Top = 108
            Width = 264
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
          object edt_customerinn: TDBEditEh
            Left = 224
            Top = 134
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
            TabOrder = 5
            Visible = True
          end
          object cmb_cashtype: TDBComboBoxEh
            Left = 80
            Top = 135
            Width = 105
            Height = 21
            ControlLabel.Width = 60
            ControlLabel.Height = 13
            ControlLabel.Caption = #1042#1080#1076' '#1086#1087#1083#1072#1090#1099
            ControlLabel.Visible = True
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            TabOrder = 4
            Text = #1073'/'#1085' ('#1085#1077#1090' '#1089#1095#1077#1090#1072')'
            Visible = True
          end
          object edt_address: TDBEditEh
            Left = 80
            Top = 161
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
            TabOrder = 6
            Visible = True
          end
          inline frmpcCustomer: TFrMyPanelCaption
            Left = 1
            Top = 1
            Width = 354
            Height = 18
            Align = alTop
            TabOrder = 7
            ExplicitLeft = 1
            ExplicitTop = 1
            ExplicitWidth = 354
            inherited bvl1: TBevel
              Width = 354
              ExplicitWidth = 707
            end
          end
        end
        object PHOrder: TPanel
          Left = 1
          Top = 1
          Width = 344
          Height = 234
          Align = alLeft
          TabOrder = 2
          DesignSize = (
            344
            234)
          object cmb_id_organization: TDBComboBoxEh
            Left = 66
            Top = 80
            Width = 144
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
          object edt_ornum: TDBEditEh
            Left = 65
            Top = 53
            Width = 66
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
          object cmb_id_or_format_estimates: TDBComboBoxEh
            Left = 65
            Top = 107
            Width = 273
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
          object cmb_project: TDBComboBoxEh
            Left = 65
            Top = 134
            Width = 273
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
          object edt_managername: TDBEditEh
            Left = 66
            Top = 161
            Width = 144
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
          object cmb_or_reference: TDBComboBoxEh
            Left = 142
            Top = 53
            Width = 85
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
          object cmb_Area: TDBComboBoxEh
            Left = 284
            Top = 80
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
          object cmb_id_type2: TDBComboBoxEh
            Left = 65
            Top = 26
            Width = 273
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
          object edt_reglament: TDBEditEh
            Left = 234
            Top = 53
            Width = 104
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            ControlLabel.Caption = #1056#1077#1075#1083#1072#1084#1077#1085#1090
            ControlLabelLocation.Position = lpLeftCenterEh
            DynProps = <>
            EditButtons = <>
            MaxLength = 400
            TabOrder = 8
            Visible = True
          end
          inline frmpcOrder: TFrMyPanelCaption
            Left = 1
            Top = 1
            Width = 342
            Height = 18
            Align = alTop
            TabOrder = 9
            ExplicitLeft = 1
            ExplicitTop = 1
            ExplicitWidth = 342
            inherited bvl1: TBevel
              Width = 342
              ExplicitWidth = 707
            end
          end
        end
        object PHFin: TPanel
          Left = 894
          Top = 1
          Width = 391
          Height = 234
          Align = alLeft
          Caption = 'PHFin'
          TabOrder = 3
          object PHTotalSum: TPanel
            Left = 1
            Top = 157
            Width = 389
            Height = 36
            Align = alTop
            Caption = 'PHTotalSum'
            TabOrder = 0
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
          inline frmpcFinance: TFrMyPanelCaption
            Left = 1
            Top = 1
            Width = 389
            Height = 18
            Align = alTop
            TabOrder = 1
            ExplicitLeft = 1
            ExplicitTop = 1
            ExplicitWidth = 389
            inherited bvl1: TBevel
              Width = 389
              ExplicitWidth = 707
            end
          end
          object PHSum: TPanel
            Left = 1
            Top = 19
            Width = 389
            Height = 138
            Align = alTop
            TabOrder = 2
            object nedt_cost_d_0: TDBNumberEditEh
              Left = 64
              Top = 90
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
              EditButtons = <>
              TabOrder = 8
              Value = 12235123.050000000000000000
              Visible = True
            end
            object nedt_cost_m_0: TDBNumberEditEh
              Left = 64
              Top = 63
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
              EditButtons = <>
              TabOrder = 4
              Value = 12235123.050000000000000000
              Visible = True
            end
            object nedt_cost_i_0: TDBNumberEditEh
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
            object nedt_m_i: TDBNumberEditEh
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
            object nedt_d_i: TDBNumberEditEh
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
            object nedt_cost_i: TDBNumberEditEh
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
            object nedt_m_m: TDBNumberEditEh
              Left = 181
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
            object nedt_d_m: TDBNumberEditEh
              Left = 228
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
            object nedt_cost_m: TDBNumberEditEh
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
            object nedt_m_d: TDBNumberEditEh
              Left = 181
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
            object nedt_d_d: TDBNumberEditEh
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
            object nedt_cost_d: TDBNumberEditEh
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
            object PHFinCaptions: TPanel
              Left = 1
              Top = 1
              Width = 387
              Height = 26
              Align = alTop
              TabOrder = 12
              object lbl10: TLabel
                Left = 64
                Top = 4
                Width = 90
                Height = 13
                Caption = #1057#1091#1084#1084#1072' '#1073#1077#1079' '#1089#1082#1080#1076#1082#1080
              end
              object lbl11: TLabel
                Left = 172
                Top = 4
                Width = 43
                Height = 13
                Caption = #1053#1072#1094#1077#1085#1082#1072
              end
              object lbl12: TLabel
                Left = 229
                Top = 4
                Width = 38
                Height = 13
                Caption = #1057#1082#1080#1076#1082#1072
              end
              object lbl13: TLabel
                Left = 284
                Top = 4
                Width = 30
                Height = 13
                Caption = #1048#1090#1086#1075#1086
              end
            end
          end
        end
        object pnlInvisible: TPanel
          Left = 1248
          Top = 1
          Width = 28
          Height = 234
          Align = alRight
          Caption = 'pnlInvisible'
          TabOrder = 4
          Visible = False
          ExplicitLeft = 1244
        end
      end
      object pnlGrid: TPanel
        Left = 0
        Top = 464
        Width = 1277
        Height = 146
        Align = alClient
        Caption = 'pnlGrid'
        TabOrder = 5
        ExplicitWidth = 1273
        ExplicitHeight = 145
        inline FrgItems: TFrDBGridEh
          Left = 1
          Top = 19
          Width = 1275
          Height = 126
          Align = alClient
          TabOrder = 0
          ExplicitLeft = 1
          ExplicitTop = 19
          ExplicitWidth = 1271
          ExplicitHeight = 125
          inherited pnlGrid: TPanel
            Width = 1265
            Height = 72
            ExplicitWidth = 1261
            ExplicitHeight = 71
            inherited DbGridEh1: TDBGridEh
              Width = 1263
              Height = 49
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
                ExplicitHeight = 9
                inherited PRowDetailPanel: TPanel
                  Width = 44
                  Height = 7
                  ExplicitWidth = 44
                  ExplicitHeight = 7
                end
              end
            end
            inherited pnlStatusBar: TPanel
              Top = 50
              Width = 1263
              ExplicitTop = 49
              ExplicitWidth = 1259
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
            Height = 72
            ExplicitHeight = 71
          end
          inherited pnlTop: TPanel
            Width = 1275
            ExplicitWidth = 1271
          end
          inherited pnlContainer: TPanel
            Width = 1275
            ExplicitWidth = 1271
          end
          inherited pnlBottom: TPanel
            Top = 126
            Width = 1275
            ExplicitTop = 125
            ExplicitWidth = 1271
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
        inline frmpcItems: TFrMyPanelCaption
          Left = 1
          Top = 1
          Width = 1275
          Height = 18
          Align = alTop
          TabOrder = 1
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 1271
          inherited bvl1: TBevel
            Width = 1275
            ExplicitWidth = 707
          end
        end
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 645
      Width = 1277
      ExplicitTop = 644
      ExplicitWidth = 1273
      inherited bvlFrmBtnsTl: TBevel
        Width = 1275
        ExplicitWidth = 1812
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 1275
        ExplicitWidth = 1812
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 1275
        ExplicitWidth = 1271
        inherited pnlFrmBtnsMain: TPanel
          Left = 1176
          ExplicitLeft = 1172
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 948
          ExplicitLeft = 944
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 1077
          ExplicitLeft = 1073
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 808
          ExplicitWidth = 804
          object chbVisCustomer: TDBCheckBoxEh
            Left = 6
            Top = 8
            Width = 81
            Height = 17
            Caption = #1055#1086#1082#1091#1087#1072#1090#1077#1083#1100
            DynProps = <>
            TabOrder = 0
          end
          object chbVisDates: TDBCheckBoxEh
            Left = 94
            Top = 8
            Width = 50
            Height = 17
            Caption = #1044#1072#1090#1099
            DynProps = <>
            TabOrder = 1
          end
          object chbVisFinance: TDBCheckBoxEh
            Left = 150
            Top = 8
            Width = 69
            Height = 17
            Caption = #1060#1080#1085#1072#1085#1089#1099
            DynProps = <>
            TabOrder = 2
          end
          object chbVisAddInfo: TDBCheckBoxEh
            Left = 225
            Top = 8
            Width = 85
            Height = 17
            Caption = #1044#1086#1087#1086#1083#1085#1077#1085#1080#1103
            DynProps = <>
            TabOrder = 3
          end
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 689
    Width = 1287
    ExplicitTop = 688
    ExplicitWidth = 1283
    inherited lblStatusBarR: TLabel
      Left = 1214
      Height = 14
      ExplicitLeft = 1214
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 224
    Top = 784
  end
end
