inherited FrmOGjrnSemiproducts: TFrmOGjrnSemiproducts
  Caption = 'FrmOGjrnSemiproducts'
  ClientHeight = 536
  ExplicitWidth = 804
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Height = 520
    inherited pnlFrmClient: TPanel
      Height = 471
      inherited pnlTop: TPanel
        ExplicitWidth = 778
      end
      inherited pnlBottom: TPanel
        Top = 425
        ExplicitWidth = 782
      end
      inherited pnlLeft: TPanel
        Height = 416
      end
      inherited pnlGrid1: TPanel
        Height = 416
        inherited Frg1: TFrDBGridEh
          Height = 414
          inherited pnlGrid: TPanel
            Height = 360
            ExplicitWidth = 760
            inherited DbGridEh1: TDBGridEh
              Width = 758
              OnApplyFilter = Frg1DbGridEh1ApplyFilter
              OnDataGroupGetRowText = Frg1DbGridEh1DataGroupGetRowText
              OnDataGroupGetRowParams = Frg1DbGridEh1DataGroupGetRowParams
              OnDrawDataCell = Frg1DbGridEh1DrawDataCell
              OnKeyDown = Frg1DbGridEh1KeyDown
              inherited RowDetailData: TRowDetailPanelControlEh
                ExplicitLeft = 0
                ExplicitHeight = 0
              end
            end
            inherited pnlStatusBar: TPanel
              Width = 758
              ExplicitWidth = 754
            end
          end
          inherited pnlLeft: TPanel
            Height = 360
          end
          inherited pnlTop: TPanel
            ExplicitWidth = 766
          end
          inherited pnlContainer: TPanel
            ExplicitWidth = 766
          end
          inherited pnlBottom: TPanel
            Top = 414
            ExplicitWidth = 770
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
        Top = 430
        inherited Frg2: TFrDBGridEh
          ExplicitWidth = 776
          inherited pnlGrid: TPanel
            ExplicitWidth = 766
            inherited DbGridEh1: TDBGridEh
              Width = 768
              inherited RowDetailData: TRowDetailPanelControlEh
                ExplicitLeft = 0
                ExplicitWidth = 0
              end
            end
            inherited pnlStatusBar: TPanel
              Width = 768
              ExplicitWidth = 764
            end
          end
          inherited pnlTop: TPanel
            ExplicitWidth = 776
          end
          inherited pnlContainer: TPanel
            ExplicitWidth = 776
          end
          inherited pnlBottom: TPanel
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
        Height = 416
        ExplicitLeft = 777
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 476
      inherited bvlFrmBtnsTl: TBevel
        ExplicitWidth = 780
      end
      inherited bvlFrmBtnsB: TBevel
        ExplicitWidth = 780
      end
      inherited pnlFrmBtnsContainer: TPanel
        ExplicitWidth = 776
        inherited pnlFrmBtnsMain: TPanel
          ExplicitLeft = 681
        end
        inherited pnlFrmBtnsR: TPanel
          ExplicitLeft = 582
        end
        inherited pnlFrmBtnsC: TPanel
          ExplicitWidth = 313
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 520
    ExplicitWidth = 792
    inherited lblStatusBarR: TLabel
      Left = 719
      ExplicitLeft = 719
    end
  end
end
