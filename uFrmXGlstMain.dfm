inherited FrmXGlstMain: TFrmXGlstMain
  Caption = 'FrmXGlstMain'
  ClientHeight = 356
  ClientWidth = 569
  ExplicitWidth = 585
  ExplicitHeight = 395
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 569
    Height = 340
    ExplicitWidth = 569
    ExplicitHeight = 340
    inherited pnlFrmClient: TPanel
      Width = 559
      Height = 291
      ExplicitWidth = 559
      ExplicitHeight = 291
      inherited pnlTop: TPanel
        Width = 559
        ExplicitWidth = 555
      end
      inherited pnlBottom: TPanel
        Top = 245
        Width = 559
        ExplicitTop = 244
        ExplicitWidth = 555
      end
      inherited pnlLeft: TPanel
        Height = 236
        ExplicitHeight = 235
      end
      inherited pnlGrid1: TPanel
        Width = 549
        Height = 236
        ExplicitWidth = 549
        ExplicitHeight = 236
        inherited Frg1: TFrDBGridEh
          Width = 547
          Height = 234
          ExplicitWidth = 547
          ExplicitHeight = 234
          inherited pnlGrid: TPanel
            Width = 537
            Height = 180
            ExplicitWidth = 533
            ExplicitHeight = 179
            inherited DbGridEh1: TDBGridEh
              Width = 535
              Height = 157
              inherited RowDetailData: TRowDetailPanelControlEh
                inherited PRowDetailPanel: TPanel
                  Height = 115
                  ExplicitHeight = 115
                end
              end
            end
            inherited pnlStatusBar: TPanel
              Top = 158
              Width = 535
              ExplicitTop = 157
              ExplicitWidth = 531
            end
          end
          inherited pnlLeft: TPanel
            Height = 180
            ExplicitHeight = 179
          end
          inherited pnlTop: TPanel
            Width = 547
            ExplicitWidth = 543
          end
          inherited pnlContainer: TPanel
            Width = 547
            ExplicitWidth = 543
          end
          inherited pnlBottom: TPanel
            Top = 234
            Width = 547
            ExplicitTop = 233
            ExplicitWidth = 543
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
        Top = 250
        Width = 559
        ExplicitTop = 250
        ExplicitWidth = 559
        inherited Frg2: TFrDBGridEh
          Width = 557
          ExplicitWidth = 557
          inherited pnlGrid: TPanel
            Width = 547
            ExplicitWidth = 543
            inherited DbGridEh1: TDBGridEh
              Width = 545
            end
            inherited pnlStatusBar: TPanel
              Width = 545
              ExplicitWidth = 541
            end
          end
          inherited pnlTop: TPanel
            Width = 557
            ExplicitWidth = 553
          end
          inherited pnlContainer: TPanel
            Width = 557
            ExplicitWidth = 553
          end
          inherited pnlBottom: TPanel
            Width = 557
            ExplicitWidth = 553
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
        Left = 554
        Height = 236
        ExplicitLeft = 550
        ExplicitHeight = 235
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 296
      Width = 559
      ExplicitTop = 295
      ExplicitWidth = 555
      inherited bvlFrmBtnsTl: TBevel
        Width = 557
        ExplicitWidth = 788
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 557
        ExplicitWidth = 788
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 557
        ExplicitWidth = 553
        inherited pnlFrmBtnsMain: TPanel
          Left = 458
          ExplicitLeft = 454
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 230
          ExplicitLeft = 226
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 359
          ExplicitLeft = 355
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 90
          ExplicitWidth = 86
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 340
    Width = 569
    ExplicitTop = 339
    ExplicitWidth = 565
    inherited lblStatusBarR: TLabel
      Left = 496
      ExplicitLeft = 496
    end
  end
end
