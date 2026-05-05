inherited FrmOGedtSnMain: TFrmOGedtSnMain
  Caption = 'FrmOGedtSnMain'
  ClientWidth = 792
  ExplicitWidth = 804
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 792
    ExplicitWidth = 792
    inherited pnlFrmClient: TPanel
      Width = 782
      ExplicitWidth = 778
      inherited pnlTop: TPanel
        Width = 782
        Height = 73
        ExplicitWidth = 778
        ExplicitHeight = 73
        object pnlName: TPanel
          Left = 1
          Top = 1
          Width = 780
          Height = 20
          Align = alTop
          TabOrder = 0
          ExplicitWidth = 776
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
          Width = 780
          Height = 51
          Align = alClient
          TabOrder = 1
          ExplicitLeft = 1
          ExplicitTop = 21
          ExplicitWidth = 776
          ExplicitHeight = 51
          inherited pnlGrid: TPanel
            Width = 770
            Height = 297
            ExplicitWidth = 766
            ExplicitHeight = 297
            inherited DbGridEh1: TDBGridEh
              Width = 768
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
              Width = 768
              ExplicitTop = 275
              ExplicitWidth = 764
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
            Height = 297
            ExplicitHeight = 297
          end
          inherited pnlTop: TPanel
            Width = 780
            ExplicitWidth = 776
          end
          inherited pnlContainer: TPanel
            Width = 780
            ExplicitWidth = 776
          end
          inherited pnlBottom: TPanel
            Top = 51
            Width = 780
            ExplicitTop = 51
            ExplicitWidth = 776
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
      inherited pnlBottom: TPanel
        Width = 782
        ExplicitWidth = 778
      end
      inherited pnlLeft: TPanel
        Top = 73
        Height = 353
        ExplicitTop = 73
        ExplicitHeight = 352
      end
      inherited pnlGrid1: TPanel
        Top = 73
        Width = 772
        Height = 353
        ExplicitTop = 73
        ExplicitWidth = 768
        ExplicitHeight = 352
        inherited Frg1: TFrDBGridEh
          Width = 770
          Height = 351
          ExplicitWidth = 766
          ExplicitHeight = 350
          inherited pnlGrid: TPanel
            Width = 760
            Height = 297
            ExplicitWidth = 756
            ExplicitHeight = 296
            inherited DbGridEh1: TDBGridEh
              Width = 758
              Height = 274
            end
            inherited pnlStatusBar: TPanel
              Top = 275
              Width = 758
              ExplicitTop = 274
            end
          end
          inherited pnlLeft: TPanel
            Height = 297
            ExplicitHeight = 296
          end
          inherited pnlTop: TPanel
            Width = 770
            ExplicitWidth = 766
          end
          inherited pnlContainer: TPanel
            Width = 770
            ExplicitWidth = 766
          end
          inherited pnlBottom: TPanel
            Top = 351
            Width = 770
            ExplicitTop = 350
            ExplicitWidth = 766
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
      inherited pnlFrg2: TPanel
        Width = 782
        ExplicitWidth = 778
        inherited Frg2: TFrDBGridEh
          Width = 780
          ExplicitWidth = 776
          inherited pnlGrid: TPanel
            Width = 770
            ExplicitWidth = 766
            inherited DbGridEh1: TDBGridEh
              Width = 768
            end
            inherited pnlStatusBar: TPanel
              Width = 768
            end
          end
          inherited pnlTop: TPanel
            Width = 780
            ExplicitWidth = 776
          end
          inherited pnlContainer: TPanel
            Width = 780
            ExplicitWidth = 776
          end
          inherited pnlBottom: TPanel
            Width = 780
            ExplicitWidth = 776
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
      inherited pnlRight: TPanel
        Left = 777
        Top = 73
        Height = 353
        ExplicitLeft = 773
        ExplicitTop = 73
        ExplicitHeight = 352
      end
    end
    inherited pnlFrmBtns: TPanel
      Width = 782
      ExplicitWidth = 778
      inherited bvlFrmBtnsTl: TBevel
        Width = 780
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 780
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 780
        ExplicitWidth = 780
        inherited pnlFrmBtnsChb: TPanel
          ExplicitLeft = 449
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Width = 792
    ExplicitWidth = 788
    inherited lblStatusBarR: TLabel
      Left = 719
      Height = 14
      ExplicitLeft = 719
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    OnTimer = tmrAfterCreateTimer
  end
end
