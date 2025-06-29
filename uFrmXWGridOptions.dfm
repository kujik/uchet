inherited FrmXWGridOptions: TFrmXWGridOptions
  Caption = 'FrmXWGridOptions'
  ClientHeight = 306
  ClientWidth = 885
  ExplicitWidth = 901
  ExplicitHeight = 345
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 885
    Height = 290
    ExplicitWidth = 889
    ExplicitHeight = 291
    inherited pnlFrmClient: TPanel
      Width = 875
      Height = 241
      ExplicitWidth = 875
      ExplicitHeight = 241
      object pnlLeft: TPanel
        Left = 0
        Top = 0
        Width = 225
        Height = 241
        Align = alLeft
        Caption = 'pnlLeft'
        TabOrder = 0
        ExplicitHeight = 242
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
        object pnlRightTop: TPanel
          Left = 1
          Top = 1
          Width = 648
          Height = 25
          Align = alTop
          TabOrder = 0
          ExplicitWidth = 652
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
          ExplicitWidth = 648
          ExplicitHeight = 214
          inherited pnlGrid: TPanel
            Width = 638
            Height = 160
            ExplicitWidth = 642
            ExplicitHeight = 161
            inherited DbGridEh1: TDBGridEh
              Width = 640
              Height = 138
              Columns = <
                item
                  CellButtons = <>
                  DynProps = <>
                  EditButtons = <>
                  Footers = <>
                end>
              inherited RowDetailData: TRowDetailPanelControlEh
                ExplicitHeight = 99
                inherited PRowDetailPanel: TPanel
                  Align = alNone
                end
              end
            end
            inherited pnlStatusBar: TPanel
              Top = 139
              Width = 640
              ExplicitTop = 139
              ExplicitWidth = 640
              inherited lblStatusBarL: TLabel
                Height = 13
                ExplicitHeight = 13
              end
            end
          end
          inherited pnlLeft: TPanel
            Height = 160
            ExplicitHeight = 161
          end
          inherited pnlTop: TPanel
            Width = 648
            ExplicitWidth = 652
          end
          inherited pnlContainer: TPanel
            Width = 648
            ExplicitWidth = 652
          end
          inherited pnlBottom: TPanel
            Top = 214
            Width = 648
            ExplicitTop = 215
            ExplicitWidth = 652
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
      ExplicitTop = 247
      ExplicitWidth = 879
      inherited bvlFrmBtnsTl: TBevel
        Width = 877
        ExplicitWidth = 803
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 877
        ExplicitWidth = 803
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 877
        ExplicitWidth = 877
        inherited pnlFrmBtnsMain: TPanel
          Left = 778
          ExplicitLeft = 778
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 550
          ExplicitLeft = 550
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 679
          ExplicitLeft = 679
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 410
          ExplicitWidth = 410
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 290
    Width = 885
    ExplicitTop = 291
    ExplicitWidth = 889
    inherited lblStatusBarR: TLabel
      Left = 797
      ExplicitLeft = 797
    end
  end
end
