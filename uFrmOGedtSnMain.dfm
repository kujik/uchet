inherited FrmOGedtSnMain: TFrmOGedtSnMain
  Caption = 'FrmOGedtSnMain'
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    inherited pnlFrmClient: TPanel
      inherited pnlTop: TPanel
        Height = 73
        ExplicitWidth = 790
        ExplicitHeight = 73
        object pnlName: TPanel
          Left = 1
          Top = 1
          Width = 788
          Height = 20
          Align = alTop
          TabOrder = 0
          ExplicitWidth = 780
          object lblName: TLabel
            Left = 16
            Top = 3
            Width = 12
            Height = 13
            Caption = '...'
          end
        end
        inline Frg3: TFrDBGridEh
          Left = 1
          Top = 21
          Width = 788
          Height = 51
          Align = alClient
          TabOrder = 1
          ExplicitLeft = 1
          ExplicitTop = 21
          ExplicitWidth = 788
          ExplicitHeight = 51
          inherited pnlGrid: TPanel
            Width = 778
            Height = 297
            ExplicitWidth = 770
            ExplicitHeight = 297
            inherited DbGridEh1: TDBGridEh
              Width = 772
              Height = 274
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
              Top = 275
              Width = 772
              ExplicitTop = 275
              ExplicitWidth = 768
              inherited lblStatusBarL: TLabel
                Height = 13
                ExplicitHeight = 13
              end
            end
          end
          inherited pnlLeft: TPanel
            Height = 297
            ExplicitHeight = 297
          end
          inherited pnlTop: TPanel
            Width = 788
            ExplicitWidth = 780
          end
          inherited pnlContainer: TPanel
            Width = 788
            ExplicitWidth = 780
          end
          inherited pnlBottom: TPanel
            Top = 51
            Width = 788
            ExplicitTop = 51
            ExplicitWidth = 780
          end
          inherited PrintDBGridEh1: TPrintDBGridEh
            BeforeGridText_Data = {
              7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
              7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
              305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
              666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
              6E657261746F722052696368656432302031302E302E31393034317D5C766965
              776B696E64345C756331200D0A5C706172645C66305C667331365C2763665C27
              66305C2765655C2765355C2765615C2766323A20255B50726F656B745D5C7061
              720D0A5C2763665C2765355C2766305C2765385C2765655C276534205C276631
              205C66315C6C616E67313033332020255B4474315D205C66305C6C616E673130
              34395C2765665C2765655C66315C6C616E67313033332020255B4474325D5C66
              305C6C616E67313034395C7061720D0A5C7061720D0A7D0D0A00}
          end
        end
      end
      inherited pnlLeft: TPanel
        Top = 73
        Height = 353
        ExplicitTop = 73
        ExplicitHeight = 351
      end
      inherited pnlGrid1: TPanel
        Top = 73
        Height = 353
        ExplicitTop = 73
        ExplicitHeight = 353
        inherited Frg1: TFrDBGridEh
          Height = 351
          ExplicitHeight = 351
          inherited pnlGrid: TPanel
            Height = 297
            ExplicitHeight = 295
            inherited DbGridEh1: TDBGridEh
              Width = 762
              Height = 273
            end
            inherited pnlStatusBar: TPanel
              Top = 274
              Width = 762
              ExplicitTop = 274
            end
          end
          inherited pnlLeft: TPanel
            Height = 297
            ExplicitHeight = 295
          end
          inherited pnlBottom: TPanel
            Top = 351
            ExplicitTop = 349
          end
          inherited PrintDBGridEh1: TPrintDBGridEh
            BeforeGridText_Data = {
              7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
              7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
              305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
              666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
              6E657261746F722052696368656432302031302E302E31393034317D5C766965
              776B696E64345C756331200D0A5C706172645C66305C667331365C2763665C27
              66305C2765655C2765355C2765615C2766323A20255B50726F656B745D5C7061
              720D0A5C2763665C2765355C2766305C2765385C2765655C276534205C276631
              205C66315C6C616E67313033332020255B4474315D205C66305C6C616E673130
              34395C2765665C2765655C66315C6C616E67313033332020255B4474325D5C66
              305C6C616E67313034395C7061720D0A5C7061720D0A7D0D0A00}
          end
        end
      end
      inherited pnlFrg2: TPanel
        inherited Frg2: TFrDBGridEh
          inherited pnlGrid: TPanel
            inherited DbGridEh1: TDBGridEh
              Width = 772
            end
            inherited pnlStatusBar: TPanel
              Width = 772
            end
          end
          inherited PrintDBGridEh1: TPrintDBGridEh
            BeforeGridText_Data = {
              7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
              7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
              305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
              666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
              6E657261746F722052696368656432302031302E302E31393034317D5C766965
              776B696E64345C756331200D0A5C706172645C66305C667331365C2763665C27
              66305C2765655C2765355C2765615C2766323A20255B50726F656B745D5C7061
              720D0A5C2763665C2765355C2766305C2765385C2765655C276534205C276631
              205C66315C6C616E67313033332020255B4474315D205C66305C6C616E673130
              34395C2765665C2765655C66315C6C616E67313033332020255B4474325D5C66
              305C6C616E67313034395C7061720D0A5C7061720D0A7D0D0A00}
          end
        end
      end
      inherited pnlRight: TPanel
        Top = 73
        Height = 353
        ExplicitTop = 73
        ExplicitHeight = 351
      end
    end
  end
  inherited pnlStatusBar: TPanel
    inherited lblStatusBarR: TLabel
      Left = 704
      ExplicitLeft = 704
    end
  end
  inherited tmrAfterCreate: TTimer
    OnTimer = tmrAfterCreateTimer
  end
end
