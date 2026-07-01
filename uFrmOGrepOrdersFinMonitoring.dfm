inherited FrmOGrepOrdersFinMonitoring: TFrmOGrepOrdersFinMonitoring
  ParentCustomHint = False
  Caption = 'FrmOGrepOrdersFinMonitoring'
  ClientHeight = 423
  ClientWidth = 810
  ExplicitWidth = 822
  ExplicitHeight = 461
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 810
    Height = 407
    ExplicitWidth = 810
    ExplicitHeight = 407
    inherited pnlFrmClient: TPanel
      Width = 800
      Height = 358
      ExplicitWidth = 796
      ExplicitHeight = 357
      object pgcMain: TPageControl
        Left = 0
        Top = 0
        Width = 800
        Height = 358
        ActivePage = tsSelectedOrder
        Align = alClient
        TabOrder = 0
        ExplicitWidth = 796
        ExplicitHeight = 357
        object tsStartedOrders: TTabSheet
          Caption = #1047#1072#1087#1091#1097#1077#1085#1085#1099#1077' '#1079#1072#1082#1072#1079#1099
          inline FrgStartedOrders: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 792
            Height = 330
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 788
            ExplicitHeight = 329
            inherited pnlGrid: TPanel
              Width = 782
              Height = 276
              ExplicitWidth = 760
              ExplicitHeight = 359
              inherited DbGridEh1: TDBGridEh
                Width = 780
                Height = 253
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
                Top = 254
                Width = 780
                ExplicitTop = 337
                ExplicitWidth = 758
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
              Height = 276
              ExplicitHeight = 359
            end
            inherited pnlTop: TPanel
              Width = 792
              ExplicitWidth = 770
            end
            inherited pnlContainer: TPanel
              Width = 792
              ExplicitWidth = 770
            end
            inherited pnlBottom: TPanel
              Top = 330
              Width = 792
              ExplicitTop = 413
              ExplicitWidth = 770
            end
            inherited PrintDBGridEh1: TPrintDBGridEh
              BeforeGridText_Data = {
                7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
                7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
                305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
                666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
                6E657261746F722052696368656432302031302E302E31393034317D5C766965
                776B696E64345C756331200D0A5C706172645C66305C667331362027255B446F
                63756D656E745C66315C6C616E6731303333205D205C66305C6C616E67313034
                3920255B546F6461795D20255B557365724E616D655D5C66315C6C616E673130
                333320205C66305C6C616E67313034395C7061720D0A7D0D0A00}
            end
          end
        end
        object tsAllEstimatesLoaded: TTabSheet
          Caption = #1047#1072#1082#1072#1079#1099', '#1087#1086' '#1082#1086#1090#1086#1088#1099#1084' '#1079#1072#1075#1088#1091#1078#1077#1085#1099' '#1089#1084#1077#1090#1099
          ImageIndex = 1
          inline FrgAllEstimatesLoaded: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 792
            Height = 330
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 788
            ExplicitHeight = 329
            inherited pnlGrid: TPanel
              Width = 782
              Height = 276
              ExplicitWidth = 760
              ExplicitHeight = 359
              inherited DbGridEh1: TDBGridEh
                Width = 780
                Height = 253
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
                Top = 254
                Width = 780
                ExplicitTop = 337
                ExplicitWidth = 758
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
              Height = 276
              ExplicitHeight = 359
            end
            inherited pnlTop: TPanel
              Width = 792
              ExplicitWidth = 770
            end
            inherited pnlContainer: TPanel
              Width = 792
              ExplicitWidth = 770
            end
            inherited pnlBottom: TPanel
              Top = 330
              Width = 792
              ExplicitTop = 413
              ExplicitWidth = 770
            end
            inherited PrintDBGridEh1: TPrintDBGridEh
              BeforeGridText_Data = {
                7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
                7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
                305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
                666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
                6E657261746F722052696368656432302031302E302E31393034317D5C766965
                776B696E64345C756331200D0A5C706172645C66305C667331362027255B446F
                63756D656E745C66315C6C616E6731303333205D205C66305C6C616E67313034
                3920255B546F6461795D20255B557365724E616D655D5C66315C6C616E673130
                333320205C66305C6C616E67313034395C7061720D0A7D0D0A00}
            end
          end
        end
        object tsOrdersInPeriod: TTabSheet
          Caption = #1047#1072#1082#1072#1079#1099' '#1079#1072' '#1087#1077#1088#1080#1086#1076
          ImageIndex = 2
          inline FrgOrdersInPeriod: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 792
            Height = 330
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 788
            ExplicitHeight = 329
            inherited pnlGrid: TPanel
              Width = 782
              Height = 276
              ExplicitWidth = 760
              ExplicitHeight = 359
              inherited DbGridEh1: TDBGridEh
                Width = 780
                Height = 253
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
                Top = 254
                Width = 780
                ExplicitTop = 337
                ExplicitWidth = 758
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
              Height = 276
              ExplicitHeight = 359
            end
            inherited pnlTop: TPanel
              Width = 792
              ExplicitWidth = 770
            end
            inherited pnlContainer: TPanel
              Width = 792
              ExplicitWidth = 770
            end
            inherited pnlBottom: TPanel
              Top = 330
              Width = 792
              ExplicitTop = 413
              ExplicitWidth = 770
            end
            inherited PrintDBGridEh1: TPrintDBGridEh
              BeforeGridText_Data = {
                7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
                7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
                305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
                666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
                6E657261746F722052696368656432302031302E302E31393034317D5C766965
                776B696E64345C756331200D0A5C706172645C66305C667331362027255B446F
                63756D656E745C66315C6C616E6731303333205D205C66305C6C616E67313034
                3920255B546F6461795D20255B557365724E616D655D5C66315C6C616E673130
                333320205C66305C6C616E67313034395C7061720D0A7D0D0A00}
            end
          end
        end
        object tsSelectedOrder: TTabSheet
          Caption = #1042#1099#1073#1088#1072#1085#1085#1099#1081' '#1079#1072#1082#1072#1079
          ImageIndex = 3
          inline FrgSelectedOrder: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 792
            Height = 330
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 788
            ExplicitHeight = 329
            inherited pnlGrid: TPanel
              Width = 782
              Height = 276
              ExplicitWidth = 778
              ExplicitHeight = 275
              inherited DbGridEh1: TDBGridEh
                Width = 780
                Height = 253
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
                Top = 254
                Width = 780
                ExplicitTop = 253
                ExplicitWidth = 776
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
              Height = 276
              ExplicitHeight = 275
            end
            inherited pnlTop: TPanel
              Width = 792
              ExplicitWidth = 788
            end
            inherited pnlContainer: TPanel
              Width = 792
              ExplicitWidth = 788
            end
            inherited pnlBottom: TPanel
              Top = 330
              Width = 792
              ExplicitTop = 329
              ExplicitWidth = 788
            end
            inherited PrintDBGridEh1: TPrintDBGridEh
              BeforeGridText_Data = {
                7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
                7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
                305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
                666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
                6E657261746F722052696368656432302031302E302E31393034317D5C766965
                776B696E64345C756331200D0A5C706172645C66305C667331362027255B446F
                63756D656E745C66315C6C616E6731303333205D205C66305C6C616E67313034
                3920255B546F6461795D20255B557365724E616D655D5C66315C6C616E673130
                333320205C66305C6C616E67313034395C7061720D0A7D0D0A00}
            end
          end
        end
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 363
      Width = 800
      ExplicitTop = 362
      ExplicitWidth = 796
      inherited bvlFrmBtnsTl: TBevel
        Width = 798
        ExplicitWidth = 798
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 798
        ExplicitWidth = 798
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 798
        ExplicitWidth = 794
        inherited pnlFrmBtnsMain: TPanel
          Left = 699
          ExplicitLeft = 695
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 471
          ExplicitLeft = 467
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 600
          ExplicitLeft = 596
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 331
          ExplicitWidth = 327
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 407
    Width = 810
    ExplicitTop = 406
    ExplicitWidth = 806
    inherited lblStatusBarR: TLabel
      Left = 737
      Height = 14
      ExplicitLeft = 737
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 200
    Top = 320
  end
end
