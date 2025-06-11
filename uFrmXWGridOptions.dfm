inherited FrmXWGridOptions: TFrmXWGridOptions
  Caption = 'FrmXWGridOptions'
  ClientHeight = 307
  ClientWidth = 889
  ExplicitWidth = 905
  ExplicitHeight = 345
  PixelsPerInch = 96
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 889
    Height = 291
    ExplicitWidth = 889
    ExplicitHeight = 291
    inherited PMDIClient: TPanel
      Width = 879
      Height = 242
      ExplicitWidth = 879
      ExplicitHeight = 242
      object PLeft: TPanel
        Left = 0
        Top = 0
        Width = 225
        Height = 242
        Align = alLeft
        Caption = 'PLeft'
        TabOrder = 0
        object PLefttTop: TPanel
          Left = 1
          Top = 1
          Width = 223
          Height = 25
          Align = alTop
          TabOrder = 0
          object Label1: TLabel
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
      object PRight: TPanel
        Left = 225
        Top = 0
        Width = 654
        Height = 242
        Align = alClient
        Caption = 'PRight'
        TabOrder = 1
        object PRightTop: TPanel
          Left = 1
          Top = 1
          Width = 652
          Height = 25
          Align = alTop
          TabOrder = 0
          object Label2: TLabel
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
          Width = 652
          Height = 215
          Align = alClient
          TabOrder = 1
          ExplicitLeft = 1
          ExplicitTop = 26
          ExplicitWidth = 652
          ExplicitHeight = 215
          inherited PGrid: TPanel
            Width = 642
            Height = 161
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
            inherited PStatus: TPanel
              Top = 139
              Width = 640
              ExplicitTop = 139
              ExplicitWidth = 640
            end
          end
          inherited PLeft: TPanel
            Height = 161
            ExplicitHeight = 161
          end
          inherited PTop: TPanel
            Width = 652
            ExplicitWidth = 652
          end
          inherited PContainer: TPanel
            Width = 652
            ExplicitWidth = 652
          end
          inherited PBottom: TPanel
            Top = 215
            Width = 652
            ExplicitTop = 215
            ExplicitWidth = 652
          end
          inherited PrintDBGridEh1: TPrintDBGridEh
            BeforeGridText_Data = {
              7B5C727466315C616E73695C616E7369637067313235315C64656666305C6465
              666C616E67313034397B5C666F6E7474626C7B5C66305C666E696C5C66636861
              72736574323034205461686F6D613B7D7B5C66315C666E696C5C666368617273
              657430205461686F6D613B7D7D0D0A5C766965776B696E64345C7563315C7061
              72645C66305C667331365C2763665C2766305C2765655C2765355C2765615C27
              66323A20255B50726F656B745D5C7061720D0A5C2763665C2765355C2766305C
              2765385C2765655C276534205C276631205C6C616E67313033335C6631202025
              5B4474315D205C6C616E67313034395C66305C2765665C2765655C6C616E6731
              3033335C66312020255B4474325D5C6C616E67313034395C66305C7061720D0A
              5C7061720D0A7D0D0A00}
          end
        end
      end
    end
    inherited PDlgPanel: TPanel
      Top = 247
      Width = 879
      ExplicitTop = 247
      ExplicitWidth = 879
      inherited BvDlg: TBevel
        Width = 877
        ExplicitWidth = 803
      end
      inherited BvDlgBottom: TBevel
        Width = 877
        ExplicitWidth = 803
      end
      inherited PDlgMain: TPanel
        Width = 877
        ExplicitWidth = 877
        inherited PDlgBtnForm: TPanel
          Left = 778
          ExplicitLeft = 778
        end
        inherited PDlgChb: TPanel
          Left = 550
          ExplicitLeft = 550
        end
        inherited PDlgBtnR: TPanel
          Left = 679
          ExplicitLeft = 679
        end
        inherited PDlgCenter: TPanel
          Width = 410
          ExplicitWidth = 410
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 291
    Width = 889
    ExplicitTop = 291
    ExplicitWidth = 889
    inherited LbStatusBarRight: TLabel
      Left = 797
      Height = 13
      ExplicitLeft = 797
    end
    inherited LbStatusBarLeft: TLabel
      Height = 13
    end
  end
end
