inherited FrmWGedtTurvN: TFrmWGedtTurvN
  Caption = 'FrmWGedtTurvN'
  ClientHeight = 349
  ClientWidth = 666
  ExplicitWidth = 678
  ExplicitHeight = 387
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 666
    Height = 333
    ExplicitWidth = 666
    ExplicitHeight = 333
    inherited pnlFrmClient: TPanel
      Width = 656
      Height = 284
      ExplicitWidth = 652
      ExplicitHeight = 283
      inherited pnlTop: TPanel
        Width = 656
        ExplicitWidth = 652
      end
      inherited pnlBottom: TPanel
        Top = 238
        Width = 656
        ExplicitTop = 237
        ExplicitWidth = 652
      end
      inherited pnlLeft: TPanel
        Height = 229
        ExplicitHeight = 228
      end
      inherited pnlGrid1: TPanel
        Width = 646
        Height = 229
        ExplicitWidth = 642
        ExplicitHeight = 228
        inherited Frg1: TFrDBGridEh
          Width = 644
          Height = 227
          ExplicitWidth = 640
          ExplicitHeight = 226
          inherited pnlGrid: TPanel
            Width = 634
            Height = 173
            ExplicitWidth = 630
            ExplicitHeight = 172
            inherited DbGridEh1: TDBGridEh
              Width = 632
              Height = 150
              OnAdvDrawDataCell = Frg1DbGridEh1AdvDrawDataCell
              OnDataHintShow = Frg1DbGridEh1DataHintShow
              OnRowDetailPanelShow = Frg1DbGridEh1RowDetailPanelShow
              inherited RowDetailData: TRowDetailPanelControlEh
                inherited PRowDetailPanel: TPanel
                  Height = 108
                  ExplicitHeight = 108
                end
              end
            end
            inherited pnlStatusBar: TPanel
              Top = 151
              Width = 632
              ExplicitTop = 150
              ExplicitWidth = 628
            end
          end
          inherited pnlLeft: TPanel
            Height = 173
            ExplicitHeight = 172
          end
          inherited pnlTop: TPanel
            Width = 644
            ExplicitWidth = 640
          end
          inherited pnlContainer: TPanel
            Width = 644
            ExplicitWidth = 640
          end
          inherited pnlBottom: TPanel
            Top = 227
            Width = 644
            ExplicitTop = 226
            ExplicitWidth = 640
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
        Top = 243
        Width = 656
        ExplicitTop = 242
        ExplicitWidth = 652
        inherited Frg2: TFrDBGridEh
          Width = 654
          ExplicitWidth = 650
          inherited pnlGrid: TPanel
            Width = 644
            ExplicitWidth = 640
            inherited DbGridEh1: TDBGridEh
              Width = 642
              OnAdvDrawDataCell = Frg2DbGridEh1AdvDrawDataCell
              OnDataHintShow = Frg2DbGridEh1DataHintShow
            end
            inherited pnlStatusBar: TPanel
              Width = 642
              ExplicitWidth = 638
            end
          end
          inherited pnlTop: TPanel
            Width = 654
            ExplicitWidth = 650
          end
          inherited pnlContainer: TPanel
            Width = 654
            ExplicitWidth = 650
          end
          inherited pnlBottom: TPanel
            Width = 654
            ExplicitWidth = 650
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
        Left = 651
        Height = 229
        ExplicitLeft = 647
        ExplicitHeight = 228
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 289
      Width = 656
      inherited bvlFrmBtnsTl: TBevel
        Width = 654
        ExplicitWidth = 654
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 654
        ExplicitWidth = 654
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 654
        inherited pnlFrmBtnsMain: TPanel
          Left = 555
          ExplicitLeft = 551
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 327
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 456
          ExplicitLeft = 452
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 187
          ExplicitWidth = 183
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 333
    Width = 666
    ExplicitTop = 332
    ExplicitWidth = 662
    inherited lblStatusBarR: TLabel
      Left = 593
      Height = 14
      ExplicitLeft = 593
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
