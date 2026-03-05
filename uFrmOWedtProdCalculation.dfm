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
    inherited pnlFrmClient: TPanel
      Width = 1116
      Height = 526
      ExplicitWidth = 219
      ExplicitHeight = 48
      object pnlTop: TPanel
        Left = 0
        Top = 0
        Width = 1116
        Height = 73
        Align = alTop
        Caption = 'pnlTop'
        TabOrder = 0
        ExplicitWidth = 219
        DesignSize = (
          1116
          73)
        object edt_name: TDBEditEh
          Left = 57
          Top = 14
          Width = 897
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          ControlLabel.Width = 49
          ControlLabel.Height = 13
          ControlLabel.Caption = #1054#1087#1080#1089#1072#1085#1080#1077
          ControlLabel.Visible = True
          ControlLabelLocation.Position = lpLeftCenterEh
          DynProps = <>
          EditButtons = <>
          TabOrder = 0
          Text = 'edt_name'
          Visible = True
          ExplicitWidth = 0
        end
      end
      object pgcMain: TPageControl
        Left = 0
        Top = 73
        Width = 1116
        Height = 453
        ActivePage = ts4
        Align = alClient
        TabOrder = 1
        ExplicitWidth = 219
        ExplicitHeight = 445
        object ts1: TTabSheet
          Caption = #1058#1072#1081#1084#1083#1072#1081#1085
          ImageIndex = 1
          inline Frg1: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 1108
            Height = 425
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 211
            ExplicitHeight = 417
            inherited pnlGrid: TPanel
              Width = 1098
              Height = 371
              ExplicitWidth = 1075
              ExplicitHeight = 345
              inherited DbGridEh1: TDBGridEh
                Width = 1073
                Height = 340
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
                Top = 341
                Width = 1073
                ExplicitTop = 323
                ExplicitWidth = 1073
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
              Height = 371
              ExplicitHeight = 345
            end
            inherited pnlTop: TPanel
              Width = 1108
              ExplicitWidth = 1085
            end
            inherited pnlContainer: TPanel
              Width = 1108
              ExplicitWidth = 1085
            end
            inherited pnlBottom: TPanel
              Top = 425
              Width = 1108
              ExplicitTop = 399
              ExplicitWidth = 1085
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
          ImageIndex = 1
          inline Frg2: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 1108
            Height = 425
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 211
            ExplicitHeight = 417
            inherited pnlGrid: TPanel
              Width = 1098
              Height = 371
              ExplicitWidth = 1075
              ExplicitHeight = 345
              inherited DbGridEh1: TDBGridEh
                Width = 1073
                Height = 340
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
                Top = 341
                Width = 1073
                ExplicitTop = 323
                ExplicitWidth = 1073
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
              Height = 371
              ExplicitHeight = 345
            end
            inherited pnlTop: TPanel
              Width = 1108
              ExplicitWidth = 1085
            end
            inherited pnlContainer: TPanel
              Width = 1108
              ExplicitWidth = 1085
            end
            inherited pnlBottom: TPanel
              Top = 425
              Width = 1108
              ExplicitTop = 399
              ExplicitWidth = 1085
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
          ImageIndex = 2
          inline Frg3: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 1108
            Height = 425
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 211
            ExplicitHeight = 417
            inherited pnlGrid: TPanel
              Width = 1098
              Height = 371
              ExplicitWidth = 1075
              ExplicitHeight = 345
              inherited DbGridEh1: TDBGridEh
                Width = 1073
                Height = 340
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
                Top = 341
                Width = 1073
                ExplicitTop = 323
                ExplicitWidth = 1073
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
              Height = 371
              ExplicitHeight = 345
            end
            inherited pnlTop: TPanel
              Width = 1108
              ExplicitWidth = 1085
            end
            inherited pnlContainer: TPanel
              Width = 1108
              ExplicitWidth = 1085
            end
            inherited pnlBottom: TPanel
              Top = 425
              Width = 1108
              ExplicitTop = 399
              ExplicitWidth = 1085
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
          ImageIndex = 4
          inline Frg5: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 1108
            Height = 425
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 211
            ExplicitHeight = 417
            inherited pnlGrid: TPanel
              Width = 1098
              Height = 371
              ExplicitWidth = 1075
              ExplicitHeight = 345
              inherited DbGridEh1: TDBGridEh
                Width = 1073
                Height = 340
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
                Top = 341
                Width = 1073
                ExplicitTop = 323
                ExplicitWidth = 1073
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
              Height = 371
              ExplicitHeight = 345
            end
            inherited pnlTop: TPanel
              Width = 1108
              ExplicitWidth = 1085
            end
            inherited pnlContainer: TPanel
              Width = 1108
              ExplicitWidth = 1085
            end
            inherited pnlBottom: TPanel
              Top = 425
              Width = 1108
              ExplicitTop = 399
              ExplicitWidth = 1085
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
        object ts6: TTabSheet
          Caption = 'ts6'
          ImageIndex = 5
          inline Frg6: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 1108
            Height = 425
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 211
            ExplicitHeight = 417
            inherited pnlGrid: TPanel
              Width = 1098
              Height = 371
              ExplicitWidth = 1075
              ExplicitHeight = 345
              inherited DbGridEh1: TDBGridEh
                Width = 1073
                Height = 340
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
                Top = 341
                Width = 1073
                ExplicitTop = 323
                ExplicitWidth = 1073
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
              Height = 371
              ExplicitHeight = 345
            end
            inherited pnlTop: TPanel
              Width = 1108
              ExplicitWidth = 1085
            end
            inherited pnlContainer: TPanel
              Width = 1108
              ExplicitWidth = 1085
            end
            inherited pnlBottom: TPanel
              Top = 425
              Width = 1108
              ExplicitTop = 399
              ExplicitWidth = 1085
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
            Height = 425
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 211
            ExplicitHeight = 417
            inherited pnlGrid: TPanel
              Width = 1098
              Height = 371
              ExplicitWidth = 201
              ExplicitHeight = 363
              inherited DbGridEh1: TDBGridEh
                Width = 1096
                Height = 348
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
                Top = 349
                Width = 1096
                ExplicitTop = 341
                ExplicitWidth = 199
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
              Height = 371
              ExplicitHeight = 363
            end
            inherited pnlTop: TPanel
              Width = 1108
              ExplicitWidth = 211
            end
            inherited pnlContainer: TPanel
              Width = 1108
              ExplicitWidth = 211
            end
            inherited pnlBottom: TPanel
              Top = 425
              Width = 1108
              ExplicitTop = 417
              ExplicitWidth = 211
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
    end
    inherited pnlFrmBtns: TPanel
      Top = 531
      Width = 1116
      ExplicitTop = 53
      ExplicitWidth = 219
      inherited bvlFrmBtnsTl: TBevel
        Width = 1114
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 1114
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 1114
        ExplicitWidth = 217
        inherited pnlFrmBtnsMain: TPanel
          Left = 1015
          ExplicitLeft = 118
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 787
          ExplicitLeft = -110
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 916
          ExplicitLeft = 19
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 647
          ExplicitWidth = 624
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 575
    Width = 1126
    ExplicitTop = 97
    ExplicitWidth = 229
    inherited lblStatusBarR: TLabel
      Left = 1053
      Height = 14
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
