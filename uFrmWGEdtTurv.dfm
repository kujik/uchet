inherited FrmWGEdtTurv: TFrmWGEdtTurv
  Caption = 'FrmWGEdtTurv'
  ClientHeight = 426
  ClientWidth = 753
  ExplicitWidth = 765
  ExplicitHeight = 464
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 753
    Height = 410
    ExplicitWidth = 753
    ExplicitHeight = 410
    inherited pnlFrmClient: TPanel
      Width = 743
      Height = 361
      ExplicitWidth = 739
      ExplicitHeight = 360
      inherited pnlTop: TPanel
        Width = 743
        ExplicitWidth = 739
      end
      inherited pnlBottom: TPanel
        Top = 315
        Width = 743
        ExplicitTop = 314
        ExplicitWidth = 739
      end
      inherited pnlLeft: TPanel
        Height = 306
        ExplicitHeight = 305
      end
      inherited pnlGrid1: TPanel
        Width = 733
        Height = 306
        ExplicitWidth = 729
        ExplicitHeight = 305
        inherited Frg1: TFrDBGridEh
          Width = 731
          Height = 304
          ExplicitWidth = 727
          ExplicitHeight = 303
          inherited pnlGrid: TPanel
            Width = 721
            Height = 250
            ExplicitWidth = 717
            ExplicitHeight = 249
            inherited DbGridEh1: TDBGridEh
              Width = 719
              Height = 227
              OnAdvDrawDataCell = Frg1DbGridEh1AdvDrawDataCell
              OnRowDetailPanelShow = Frg1DbGridEh1RowDetailPanelShow
              inherited RowDetailData: TRowDetailPanelControlEh
                ExplicitLeft = 30
                ExplicitHeight = 120
              end
            end
            inherited pnlStatusBar: TPanel
              Top = 228
              Width = 719
              ExplicitTop = 227
              ExplicitWidth = 715
            end
          end
          inherited pnlLeft: TPanel
            Height = 250
            ExplicitHeight = 249
          end
          inherited pnlTop: TPanel
            Width = 731
            ExplicitWidth = 727
          end
          inherited pnlContainer: TPanel
            Width = 731
            ExplicitWidth = 727
          end
          inherited pnlBottom: TPanel
            Top = 304
            Width = 731
            ExplicitTop = 303
            ExplicitWidth = 727
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
      inherited pnlFrg2: TPanel
        Top = 320
        Width = 743
        ExplicitTop = 319
        ExplicitWidth = 739
        inherited Frg2: TFrDBGridEh
          Width = 741
          ExplicitWidth = 737
          inherited pnlGrid: TPanel
            Width = 731
            ExplicitWidth = 727
            inherited DbGridEh1: TDBGridEh
              Width = 729
              OnAdvDrawDataCell = Frg2DbGridEh1AdvDrawDataCell
              inherited RowDetailData: TRowDetailPanelControlEh
                ExplicitLeft = 30
                ExplicitWidth = 32
              end
            end
            inherited pnlStatusBar: TPanel
              Width = 729
              ExplicitWidth = 725
            end
          end
          inherited pnlTop: TPanel
            Width = 741
            ExplicitWidth = 737
          end
          inherited pnlContainer: TPanel
            Width = 741
            ExplicitWidth = 737
          end
          inherited pnlBottom: TPanel
            Width = 741
            ExplicitWidth = 737
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
      inherited pnlRight: TPanel
        Left = 738
        Height = 306
        ExplicitLeft = 734
        ExplicitHeight = 305
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 366
      Width = 743
      ExplicitTop = 365
      ExplicitWidth = 739
      inherited bvlFrmBtnsTl: TBevel
        Width = 741
        ExplicitWidth = 741
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 741
        ExplicitWidth = 741
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 741
        ExplicitWidth = 737
        inherited pnlFrmBtnsMain: TPanel
          Left = 642
          ExplicitLeft = 638
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 414
          ExplicitLeft = 410
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 543
          ExplicitLeft = 539
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 274
          ExplicitWidth = 270
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 410
    Width = 753
    ExplicitTop = 409
    ExplicitWidth = 749
    inherited lblStatusBarR: TLabel
      Left = 680
      Height = 14
      ExplicitLeft = 680
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
