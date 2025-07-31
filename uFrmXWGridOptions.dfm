inherited FrmXWGridOptions: TFrmXWGridOptions
  Caption = 'FrmXWGridOptions'
  ClientHeight = 306
  ClientWidth = 885
  ExplicitWidth = 897
  ExplicitHeight = 344
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 885
    Height = 290
    ExplicitWidth = 885
    ExplicitHeight = 290
    inherited pnlFrmClient: TPanel
      Width = 875
      Height = 241
      ExplicitWidth = 871
      ExplicitHeight = 240
      object pnlLeft: TPanel
        Left = 0
        Top = 0
        Width = 225
        Height = 241
        Align = alLeft
        Caption = 'pnlLeft'
        TabOrder = 0
        ExplicitHeight = 240
        object pnlLeftTop: TPanel
          Left = 1
          Top = 1
          Width = 223
          Height = 25
          Align = alTop
          TabOrder = 0
          object lbl1: TLabel
            Left = 4
            Top = 4
            Width = 103
            Height = 13
            Caption = #1048#1085#1090#1077#1088#1092#1077#1081#1089' '#1090#1072#1073#1083#1080#1094#1099
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsUnderline]
            ParentFont = False
          end
        end
      end
      object pnlRight: TPanel
        Left = 225
        Top = 0
        Width = 650
        Height = 241
        Align = alClient
        Caption = 'pnlRight'
        TabOrder = 1
        ExplicitWidth = 646
        ExplicitHeight = 240
        object pnlRightTop: TPanel
          Left = 1
          Top = 1
          Width = 648
          Height = 25
          Align = alTop
          TabOrder = 0
          ExplicitWidth = 644
          object lbl2: TLabel
            Left = 4
            Top = 4
            Width = 133
            Height = 13
            Caption = #1057#1087#1080#1089#1086#1082' '#1089#1090#1086#1083#1073#1094#1086#1074' '#1090#1072#1073#1083#1080#1094#1099
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsUnderline]
            ParentFont = False
          end
        end
        inline Frg1: TFrDBGridEh
          Left = 1
          Top = 26
          Width = 648
          Height = 214
          Align = alClient
          TabOrder = 1
          ExplicitLeft = 1
          ExplicitTop = 26
          ExplicitWidth = 644
          ExplicitHeight = 213
          inherited pnlGrid: TPanel
            Width = 638
            Height = 160
            ExplicitWidth = 634
            ExplicitHeight = 159
            inherited DbGridEh1: TDBGridEh
              Width = 636
              Height = 137
              Columns = <
                item
                  CellButtons = <>
                  DynProps = <>
                  EditButtons = <>
                  Footers = <>
                end>
              inherited RowDetailData: TRowDetailPanelControlEh
                ExplicitLeft = 30
                ExplicitTop = 35
                ExplicitWidth = 32
                ExplicitHeight = 97
                inherited PRowDetailPanel: TPanel
                  Align = alNone
                end
              end
            end
            inherited pnlStatusBar: TPanel
              Top = 138
              Width = 636
              ExplicitTop = 137
              ExplicitWidth = 632
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
            Height = 160
            ExplicitHeight = 159
          end
          inherited pnlTop: TPanel
            Width = 648
            ExplicitWidth = 644
          end
          inherited pnlContainer: TPanel
            Width = 648
            ExplicitWidth = 644
          end
          inherited pnlBottom: TPanel
            Top = 214
            Width = 648
            ExplicitTop = 213
            ExplicitWidth = 644
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
    inherited pnlFrmBtns: TPanel
      Top = 246
      Width = 875
      ExplicitTop = 245
      ExplicitWidth = 871
      inherited bvlFrmBtnsTl: TBevel
        Width = 873
        ExplicitWidth = 803
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 873
        ExplicitWidth = 803
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 873
        ExplicitWidth = 869
        inherited pnlFrmBtnsMain: TPanel
          Left = 774
          ExplicitLeft = 770
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 546
          ExplicitLeft = 542
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 675
          ExplicitLeft = 671
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 406
          ExplicitWidth = 402
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 290
    Width = 885
    ExplicitTop = 289
    ExplicitWidth = 881
    inherited lblStatusBarR: TLabel
      Left = 812
      Height = 14
      ExplicitLeft = 812
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
