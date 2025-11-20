inherited FrmWGEdtTurv: TFrmWGEdtTurv
  Caption = 'FrmWGEdtTurv'
  ClientHeight = 425
  ClientWidth = 749
  ExplicitWidth = 761
  ExplicitHeight = 463
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 749
    Height = 409
    ExplicitWidth = 749
    ExplicitHeight = 409
    inherited pnlFrmClient: TPanel
      Width = 739
      Height = 360
      ExplicitWidth = 735
      ExplicitHeight = 359
      inherited pnlTop: TPanel
        Width = 739
        ExplicitWidth = 735
      end
      inherited pnlBottom: TPanel
        Top = 314
        Width = 739
        ExplicitTop = 313
        ExplicitWidth = 735
      end
      inherited pnlLeft: TPanel
        Height = 305
        ExplicitHeight = 304
      end
      inherited pnlGrid1: TPanel
        Width = 729
        Height = 305
        ExplicitWidth = 725
        ExplicitHeight = 304
        inherited Frg1: TFrDBGridEh
          Width = 727
          Height = 303
          ExplicitWidth = 723
          ExplicitHeight = 302
          inherited pnlGrid: TPanel
            Width = 717
            Height = 249
            ExplicitWidth = 713
            ExplicitHeight = 248
            inherited DbGridEh1: TDBGridEh
              Width = 715
              Height = 226
              OnAdvDrawDataCell = Frg1DbGridEh1AdvDrawDataCell
              OnDataHintShow = Frg1DbGridEh1DataHintShow
              OnRowDetailPanelShow = Frg1DbGridEh1RowDetailPanelShow
            end
            inherited pnlStatusBar: TPanel
              Top = 227
              Width = 715
              ExplicitTop = 226
              ExplicitWidth = 711
            end
          end
          inherited pnlLeft: TPanel
            Height = 249
            ExplicitHeight = 248
          end
          inherited pnlTop: TPanel
            Width = 727
            ExplicitWidth = 723
          end
          inherited pnlContainer: TPanel
            Width = 727
            ExplicitWidth = 723
          end
          inherited pnlBottom: TPanel
            Top = 303
            Width = 727
            ExplicitTop = 302
            ExplicitWidth = 723
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
        Top = 319
        Width = 739
        ExplicitTop = 318
        ExplicitWidth = 735
        inherited Frg2: TFrDBGridEh
          Width = 737
          ExplicitWidth = 733
          inherited pnlGrid: TPanel
            Width = 727
            ExplicitWidth = 723
            inherited DbGridEh1: TDBGridEh
              Width = 725
              OnAdvDrawDataCell = Frg2DbGridEh1AdvDrawDataCell
              OnDataHintShow = Frg2DbGridEh1DataHintShow
            end
            inherited pnlStatusBar: TPanel
              Width = 725
              ExplicitWidth = 721
            end
          end
          inherited pnlTop: TPanel
            Width = 737
            ExplicitWidth = 733
          end
          inherited pnlContainer: TPanel
            Width = 737
            ExplicitWidth = 733
          end
          inherited pnlBottom: TPanel
            Width = 737
            ExplicitWidth = 733
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
        Left = 734
        Height = 305
        ExplicitLeft = 730
        ExplicitHeight = 304
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 365
      Width = 739
      ExplicitTop = 364
      ExplicitWidth = 735
      inherited bvlFrmBtnsTl: TBevel
        Width = 737
        ExplicitWidth = 741
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 737
        ExplicitWidth = 741
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 737
        ExplicitWidth = 733
        inherited pnlFrmBtnsMain: TPanel
          Left = 638
          ExplicitLeft = 634
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 410
          ExplicitLeft = 406
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 539
          ExplicitLeft = 535
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 270
          ExplicitWidth = 266
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 409
    Width = 749
    ExplicitTop = 408
    ExplicitWidth = 745
    inherited lblStatusBarR: TLabel
      Left = 676
      Height = 14
      ExplicitLeft = 676
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
