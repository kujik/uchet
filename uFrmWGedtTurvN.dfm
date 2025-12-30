inherited FrmWGedtTurvN: TFrmWGedtTurvN
  Caption = 'FrmWGedtTurvN'
  ClientHeight = 348
  ClientWidth = 662
  ExplicitWidth = 674
  ExplicitHeight = 386
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 662
    Height = 332
    ExplicitWidth = 662
    ExplicitHeight = 332
    inherited pnlFrmClient: TPanel
      Width = 652
      Height = 283
      ExplicitWidth = 648
      ExplicitHeight = 282
      inherited pnlTop: TPanel
        Width = 652
        ExplicitWidth = 648
      end
      inherited pnlBottom: TPanel
        Top = 237
        Width = 652
        ExplicitTop = 236
        ExplicitWidth = 648
      end
      inherited pnlLeft: TPanel
        Height = 228
        ExplicitHeight = 227
      end
      inherited pnlGrid1: TPanel
        Width = 642
        Height = 228
        ExplicitWidth = 638
        ExplicitHeight = 227
        inherited Frg1: TFrDBGridEh
          Width = 640
          Height = 226
          ExplicitWidth = 636
          ExplicitHeight = 225
          inherited pnlGrid: TPanel
            Width = 630
            Height = 172
            ExplicitWidth = 626
            ExplicitHeight = 171
            inherited DbGridEh1: TDBGridEh
              Width = 628
              Height = 149
              OnAdvDrawDataCell = Frg1DbGridEh1AdvDrawDataCell
              OnDataHintShow = Frg1DbGridEh1DataHintShow
              OnRowDetailPanelShow = Frg1DbGridEh1RowDetailPanelShow
              inherited RowDetailData: TRowDetailPanelControlEh
                inherited PRowDetailPanel: TPanel
                  Height = 107
                  ExplicitHeight = 107
                end
              end
            end
            inherited pnlStatusBar: TPanel
              Top = 150
              Width = 628
              ExplicitTop = 149
              ExplicitWidth = 624
            end
          end
          inherited pnlLeft: TPanel
            Height = 172
            ExplicitHeight = 171
          end
          inherited pnlTop: TPanel
            Width = 640
            ExplicitWidth = 636
          end
          inherited pnlContainer: TPanel
            Width = 640
            ExplicitWidth = 636
          end
          inherited pnlBottom: TPanel
            Top = 226
            Width = 640
            ExplicitTop = 225
            ExplicitWidth = 636
          end
          inherited PrintDBGridEh1: TPrintDBGridEh
            BeforeGridText_Data = {
              7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
              7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
              305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
              666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
              6E657261746F722052696368656432302031302E302E32363130307D5C766965
              776B696E64345C756331200D0A5C706172645C66305C667331362027255B446F
              63756D656E745C66315C6C616E6731303333205D205C66305C6C616E67313034
              3920255B546F6461795D20255B557365724E616D655D5C66315C6C616E673130
              333320205C66305C6C616E67313034395C7061720D0A7D0D0A00}
          end
        end
      end
      inherited pnlFrg2: TPanel
        Top = 242
        Width = 652
        ExplicitTop = 241
        ExplicitWidth = 648
        inherited Frg2: TFrDBGridEh
          Width = 650
          ExplicitWidth = 646
          inherited pnlGrid: TPanel
            Width = 640
            ExplicitWidth = 636
            inherited DbGridEh1: TDBGridEh
              Width = 638
              OnAdvDrawDataCell = Frg2DbGridEh1AdvDrawDataCell
              OnDataHintShow = Frg2DbGridEh1DataHintShow
            end
            inherited pnlStatusBar: TPanel
              Width = 638
              ExplicitWidth = 634
            end
          end
          inherited pnlTop: TPanel
            Width = 650
            ExplicitWidth = 646
          end
          inherited pnlContainer: TPanel
            Width = 650
            ExplicitWidth = 646
          end
          inherited pnlBottom: TPanel
            Width = 650
            ExplicitWidth = 646
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
        Left = 647
        Height = 228
        ExplicitLeft = 643
        ExplicitHeight = 227
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 288
      Width = 652
      ExplicitTop = 287
      ExplicitWidth = 648
      inherited bvlFrmBtnsTl: TBevel
        Width = 650
        ExplicitWidth = 654
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 650
        ExplicitWidth = 654
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 650
        ExplicitWidth = 646
        inherited pnlFrmBtnsMain: TPanel
          Left = 551
          ExplicitLeft = 547
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 323
          ExplicitLeft = 319
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 452
          ExplicitLeft = 448
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 183
          ExplicitWidth = 179
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 332
    Width = 662
    ExplicitTop = 331
    ExplicitWidth = 658
    inherited lblStatusBarR: TLabel
      Left = 589
      Height = 14
      ExplicitLeft = 589
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
