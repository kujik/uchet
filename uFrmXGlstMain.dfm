inherited FrmXGlstMain: TFrmXGlstMain
  Caption = 'FrmXGlstMain'
  ClientHeight = 357
  ClientWidth = 573
  ExplicitWidth = 585
  ExplicitHeight = 395
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 573
    Height = 341
    ExplicitWidth = 573
    ExplicitHeight = 341
    inherited pnlFrmClient: TPanel
      Width = 563
      Height = 292
      ExplicitWidth = 559
      ExplicitHeight = 291
      inherited pnlTop: TPanel
        Width = 563
        ExplicitWidth = 559
      end
      inherited pnlBottom: TPanel
        Top = 246
        Width = 563
        ExplicitTop = 245
        ExplicitWidth = 559
      end
      inherited pnlLeft: TPanel
        Height = 237
        ExplicitHeight = 236
      end
      inherited pnlGrid1: TPanel
        Width = 553
        Height = 237
        ExplicitWidth = 549
        ExplicitHeight = 236
        inherited Frg1: TFrDBGridEh
          Width = 551
          Height = 235
          ExplicitWidth = 547
          ExplicitHeight = 234
          inherited pnlGrid: TPanel
            Width = 541
            Height = 181
            ExplicitWidth = 537
            ExplicitHeight = 180
            inherited DbGridEh1: TDBGridEh
              Width = 539
              Height = 158
              inherited RowDetailData: TRowDetailPanelControlEh
                inherited PRowDetailPanel: TPanel
                  Height = 116
                  ExplicitHeight = 116
                end
              end
            end
            inherited pnlStatusBar: TPanel
              Top = 159
              Width = 539
              ExplicitTop = 158
              ExplicitWidth = 535
            end
          end
          inherited pnlLeft: TPanel
            Height = 181
            ExplicitHeight = 180
          end
          inherited pnlTop: TPanel
            Width = 551
            ExplicitWidth = 547
          end
          inherited pnlContainer: TPanel
            Width = 551
            ExplicitWidth = 547
          end
          inherited pnlBottom: TPanel
            Top = 235
            Width = 551
            ExplicitTop = 234
            ExplicitWidth = 547
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
        Top = 251
        Width = 563
        ExplicitTop = 250
        ExplicitWidth = 559
        inherited Frg2: TFrDBGridEh
          Width = 561
          ExplicitWidth = 557
          inherited pnlGrid: TPanel
            Width = 551
            ExplicitWidth = 547
            inherited DbGridEh1: TDBGridEh
              Width = 549
            end
            inherited pnlStatusBar: TPanel
              Width = 549
              ExplicitWidth = 545
            end
          end
          inherited pnlTop: TPanel
            Width = 561
            ExplicitWidth = 557
          end
          inherited pnlContainer: TPanel
            Width = 561
            ExplicitWidth = 557
          end
          inherited pnlBottom: TPanel
            Width = 561
            ExplicitWidth = 557
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
      inherited pnlRight: TPanel
        Left = 558
        Height = 237
        ExplicitLeft = 554
        ExplicitHeight = 236
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 297
      Width = 563
      ExplicitTop = 296
      ExplicitWidth = 559
      inherited bvlFrmBtnsTl: TBevel
        Width = 561
        ExplicitWidth = 788
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 561
        ExplicitWidth = 788
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 561
        ExplicitWidth = 557
        inherited pnlFrmBtnsMain: TPanel
          Left = 462
          ExplicitLeft = 458
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 234
          ExplicitLeft = 230
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 363
          ExplicitLeft = 359
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 94
          ExplicitWidth = 90
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 341
    Width = 573
    ExplicitTop = 340
    ExplicitWidth = 569
    inherited lblStatusBarR: TLabel
      Left = 500
      Height = 14
      ExplicitLeft = 500
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
