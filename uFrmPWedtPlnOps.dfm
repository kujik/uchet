inherited FrmPWedtPlnOps: TFrmPWedtPlnOps
  Caption = 'FrmPWedtPlnOps'
  ClientHeight = 544
  ClientWidth = 846
  ExplicitWidth = 858
  ExplicitHeight = 582
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 846
    Height = 528
    ExplicitWidth = 846
    ExplicitHeight = 528
    inherited pnlFrmClient: TPanel
      Width = 836
      Height = 479
      ExplicitWidth = 832
      ExplicitHeight = 478
      object pnlTop: TPanel
        Left = 0
        Top = 0
        Width = 836
        Height = 41
        Align = alTop
        Caption = 'pnlTop'
        TabOrder = 0
        ExplicitWidth = 832
        object lblCaption1: TLabel
          Left = 9
          Top = 0
          Width = 53
          Height = 13
          Caption = 'lblCaption1'
        end
        object lblCaption2: TLabel
          Left = 4
          Top = 19
          Width = 53
          Height = 13
          Caption = 'lblCaption2'
        end
      end
      object pnlBottom: TPanel
        Left = 0
        Top = 438
        Width = 836
        Height = 41
        Align = alBottom
        Caption = 'pnlBottom'
        TabOrder = 1
        ExplicitTop = 437
        ExplicitWidth = 832
        object lblAllDataEntered: TLabel
          Left = 14
          Top = 6
          Width = 82
          Height = 13
          Caption = 'lblAllDataEntered'
        end
      end
      object pgcMain: TPageControl
        Left = 0
        Top = 41
        Width = 836
        Height = 397
        ActivePage = tsDrilling
        Align = alClient
        TabOrder = 2
        ExplicitWidth = 832
        ExplicitHeight = 396
        object tsPainting: TTabSheet
          Caption = #1051#1072#1082#1086#1082#1088#1072#1089#1082#1072
          inline frmpcPainting: TFrMyPanelCaption
            Left = 0
            Top = 0
            Width = 828
            Height = 18
            Align = alTop
            TabOrder = 0
            ExplicitWidth = 828
            inherited bvl1: TBevel
              Width = 828
              ExplicitWidth = 707
            end
          end
          object pnlPaintingBottom: TPanel
            Left = 0
            Top = 334
            Width = 828
            Height = 35
            Align = alBottom
            Caption = 'pnlPaintingBottom'
            TabOrder = 1
            object lblPainting: TLabel
              Left = 137
              Top = 6
              Width = 48
              Height = 13
              Caption = 'lblPainting'
            end
            object chbPaintingDataEntered: TDBCheckBoxEh
              Left = 12
              Top = 6
              Width = 114
              Height = 17
              Caption = #1044#1072#1085#1085#1099#1077' '#1074#1074#1077#1076#1077#1085#1099
              DynProps = <>
              TabOrder = 0
            end
          end
          inline FrgPainting: TFrDBGridEh
            Left = 0
            Top = 18
            Width = 828
            Height = 316
            Align = alClient
            TabOrder = 2
            ExplicitTop = 18
            ExplicitWidth = 824
            ExplicitHeight = 315
            inherited pnlGrid: TPanel
              Width = 818
              Height = 262
              ExplicitWidth = 818
              ExplicitHeight = 262
              inherited DbGridEh1: TDBGridEh
                Width = 816
                Height = 239
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
                Top = 240
                Width = 816
                ExplicitTop = 240
                ExplicitWidth = 816
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
              Height = 262
              ExplicitHeight = 262
            end
            inherited pnlTop: TPanel
              Width = 828
              ExplicitWidth = 828
            end
            inherited pnlContainer: TPanel
              Width = 828
              ExplicitWidth = 828
            end
            inherited pnlBottom: TPanel
              Top = 316
              Width = 828
              ExplicitTop = 316
              ExplicitWidth = 828
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
        object tsCnc: TTabSheet
          Caption = #1063#1055#1059
          ImageIndex = 1
          inline FrgCnc: TFrDBGridEh
            Left = 0
            Top = 18
            Width = 828
            Height = 316
            Align = alClient
            TabOrder = 0
            ExplicitTop = 18
            ExplicitWidth = 824
            ExplicitHeight = 315
            inherited pnlGrid: TPanel
              Width = 818
              Height = 262
              ExplicitWidth = 818
              ExplicitHeight = 262
              inherited DbGridEh1: TDBGridEh
                Width = 816
                Height = 239
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
                Top = 240
                Width = 816
                ExplicitTop = 240
                ExplicitWidth = 816
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
              Height = 262
              ExplicitHeight = 262
            end
            inherited pnlTop: TPanel
              Width = 828
              ExplicitWidth = 828
            end
            inherited pnlContainer: TPanel
              Width = 828
              ExplicitWidth = 828
            end
            inherited pnlBottom: TPanel
              Top = 316
              Width = 828
              ExplicitTop = 316
              ExplicitWidth = 828
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
          object pnlCncBottom: TPanel
            Left = 0
            Top = 334
            Width = 828
            Height = 35
            Align = alBottom
            Caption = 'pnlPaintingBottom'
            TabOrder = 1
            object lblCnc: TLabel
              Left = 137
              Top = 6
              Width = 48
              Height = 13
              Caption = 'lblPainting'
            end
            object chbCncDataEntered: TDBCheckBoxEh
              Left = 12
              Top = 6
              Width = 114
              Height = 17
              Caption = #1044#1072#1085#1085#1099#1077' '#1074#1074#1077#1076#1077#1085#1099
              DynProps = <>
              TabOrder = 0
            end
          end
          inline frmpcCnc: TFrMyPanelCaption
            Left = 0
            Top = 0
            Width = 828
            Height = 18
            Align = alTop
            TabOrder = 2
            ExplicitWidth = 828
            inherited bvl1: TBevel
              Width = 828
              ExplicitWidth = 707
            end
          end
        end
        object tsLaser: TTabSheet
          Caption = #1051#1072#1079#1077#1088
          ImageIndex = 2
          inline frmpcLaser: TFrMyPanelCaption
            Left = 0
            Top = 0
            Width = 828
            Height = 18
            Align = alTop
            TabOrder = 0
            ExplicitWidth = 828
            inherited bvl1: TBevel
              Width = 828
              ExplicitWidth = 707
            end
          end
          object pnlLaserBottom: TPanel
            Left = 0
            Top = 334
            Width = 828
            Height = 35
            Align = alBottom
            Caption = 'pnlPaintingBottom'
            TabOrder = 1
            object lblLaser: TLabel
              Left = 137
              Top = 6
              Width = 48
              Height = 13
              Caption = 'lblPainting'
            end
            object chbLaserDataEntered: TDBCheckBoxEh
              Left = 12
              Top = 6
              Width = 114
              Height = 17
              Caption = #1044#1072#1085#1085#1099#1077' '#1074#1074#1077#1076#1077#1085#1099
              DynProps = <>
              TabOrder = 0
            end
          end
          inline FrgLaser: TFrDBGridEh
            Left = 0
            Top = 18
            Width = 828
            Height = 316
            Align = alClient
            TabOrder = 2
            ExplicitTop = 18
            ExplicitWidth = 824
            ExplicitHeight = 315
            inherited pnlGrid: TPanel
              Width = 818
              Height = 262
              ExplicitWidth = 818
              ExplicitHeight = 262
              inherited DbGridEh1: TDBGridEh
                Width = 816
                Height = 239
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
                Top = 240
                Width = 816
                ExplicitTop = 240
                ExplicitWidth = 816
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
              Height = 262
              ExplicitHeight = 262
            end
            inherited pnlTop: TPanel
              Width = 828
              ExplicitWidth = 828
            end
            inherited pnlContainer: TPanel
              Width = 828
              ExplicitWidth = 828
            end
            inherited pnlBottom: TPanel
              Top = 316
              Width = 828
              ExplicitTop = 316
              ExplicitWidth = 828
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
        object tsDrilling: TTabSheet
          Caption = #1057#1074#1077#1088#1083#1086#1074#1082#1072
          ImageIndex = 3
          object nedtDrilling: TDBNumberEditEh
            Left = 12
            Top = 45
            Width = 73
            Height = 21
            ControlLabel.Width = 181
            ControlLabel.Height = 26
            ControlLabel.Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1087#1072#1085#1077#1083#1077#1081' '#1089#1086' '#1089#1074#1077#1088#1083#1086#1074#1082#1086#1081#13#10'('#1085#1072' '#1086#1076#1085#1086' '#1080#1079#1076#1077#1083#1080#1077')'
            ControlLabel.Visible = True
            DecimalPlaces = 0
            DynProps = <>
            EditButtons = <>
            MaxValue = 9999.000000000000000000
            TabOrder = 0
            Visible = True
          end
          inline frmpcDrilling: TFrMyPanelCaption
            Left = 0
            Top = 0
            Width = 828
            Height = 18
            Align = alTop
            TabOrder = 1
            ExplicitWidth = 824
            inherited bvl1: TBevel
              Width = 828
              ExplicitWidth = 707
            end
          end
          object pnlDrillingBottom: TPanel
            Left = 0
            Top = 334
            Width = 828
            Height = 35
            Align = alBottom
            Caption = 'pnlPaintingBottom'
            TabOrder = 2
            ExplicitTop = 333
            ExplicitWidth = 824
            object lblDrilling: TLabel
              Left = 137
              Top = 6
              Width = 48
              Height = 13
              Caption = 'lblPainting'
            end
            object chbDrillingDataEntered: TDBCheckBoxEh
              Left = 12
              Top = 6
              Width = 114
              Height = 17
              Caption = #1044#1072#1085#1085#1099#1077' '#1074#1074#1077#1076#1077#1085#1099
              DynProps = <>
              TabOrder = 0
            end
          end
          object nedtDrillingForAll: TDBNumberEditEh
            Left = 12
            Top = 101
            Width = 73
            Height = 21
            ControlLabel.Width = 181
            ControlLabel.Height = 26
            ControlLabel.Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1087#1072#1085#1077#1083#1077#1081' '#1089#1086' '#1089#1074#1077#1088#1083#1086#1074#1082#1086#1081#13#10'('#1085#1072' '#1074#1089#1077' '#1080#1079#1076#1077#1083#1080#1103')'
            ControlLabel.Visible = True
            DecimalPlaces = 0
            DynProps = <>
            EditButtons = <>
            MaxValue = 9999.000000000000000000
            ReadOnly = True
            TabOrder = 3
            Visible = True
          end
        end
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 484
      Width = 836
      ExplicitTop = 483
      ExplicitWidth = 832
      inherited bvlFrmBtnsTl: TBevel
        Width = 834
        ExplicitWidth = 834
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 834
        ExplicitWidth = 834
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 834
        ExplicitWidth = 830
        inherited pnlFrmBtnsMain: TPanel
          Left = 735
          ExplicitLeft = 731
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 507
          ExplicitLeft = 503
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 636
          ExplicitLeft = 632
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 367
          ExplicitWidth = 363
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 528
    Width = 846
    ExplicitTop = 527
    ExplicitWidth = 842
    inherited lblStatusBarR: TLabel
      Left = 773
      Height = 14
      ExplicitLeft = 773
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 272
    Top = 488
  end
end
