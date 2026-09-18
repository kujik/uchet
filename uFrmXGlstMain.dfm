inherited FrmXGlstMain: TFrmXGlstMain
  Caption = 'FrmXGlstMain'
  ClientHeight = 355
  ClientWidth = 565
  ExplicitWidth = 577
  ExplicitHeight = 393
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 565
    Height = 339
    ExplicitWidth = 565
    ExplicitHeight = 339
    inherited pnlFrmClient: TPanel
      Width = 555
      Height = 290
      ExplicitWidth = 551
      ExplicitHeight = 289
      inherited pnlTop: TPanel
        Width = 555
        ExplicitWidth = 551
      end
      inherited pnlBottom: TPanel
        Top = 244
        Width = 555
        ExplicitTop = 243
        ExplicitWidth = 551
      end
      inherited pnlLeft: TPanel
        Height = 235
        ExplicitHeight = 234
      end
      inherited pnlGrid1: TPanel
        Width = 545
        Height = 235
        ExplicitWidth = 541
        ExplicitHeight = 234
        inherited Frg1: TFrDBGridEh
          Width = 543
          Height = 233
          ExplicitWidth = 539
          ExplicitHeight = 232
          inherited pnlGrid: TPanel
            Width = 533
            Height = 179
            ExplicitWidth = 529
            ExplicitHeight = 178
            inherited DbGridEh1: TDBGridEh
              Width = 531
              Height = 156
              inherited RowDetailData: TRowDetailPanelControlEh
                inherited PRowDetailPanel: TPanel
                  Height = 114
                  ExplicitHeight = 114
                end
              end
            end
            inherited pnlStatusBar: TPanel
              Top = 157
              Width = 531
              ExplicitTop = 156
              ExplicitWidth = 527
            end
          end
          inherited pnlLeft: TPanel
            Height = 179
            ExplicitHeight = 178
          end
          inherited pnlTop: TPanel
            Width = 543
            ExplicitWidth = 539
          end
          inherited pnlContainer: TPanel
            Width = 543
            ExplicitWidth = 539
          end
          inherited pnlBottom: TPanel
            Top = 233
            Width = 543
            ExplicitTop = 232
            ExplicitWidth = 539
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
        Top = 249
        Width = 555
        ExplicitTop = 248
        ExplicitWidth = 551
        inherited Frg2: TFrDBGridEh
          Width = 553
          ExplicitWidth = 549
          inherited pnlGrid: TPanel
            Width = 543
            ExplicitWidth = 539
            inherited DbGridEh1: TDBGridEh
              Width = 541
            end
            inherited pnlStatusBar: TPanel
              Width = 541
              ExplicitWidth = 537
            end
          end
          inherited pnlTop: TPanel
            Width = 553
            ExplicitWidth = 549
          end
          inherited pnlContainer: TPanel
            Width = 553
            ExplicitWidth = 549
          end
          inherited pnlBottom: TPanel
            Width = 553
            ExplicitWidth = 549
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
        Left = 550
        Height = 235
        ExplicitLeft = 546
        ExplicitHeight = 234
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 295
      Width = 555
      ExplicitTop = 294
      ExplicitWidth = 551
      inherited bvlFrmBtnsTl: TBevel
        Width = 553
        ExplicitWidth = 788
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 553
        ExplicitWidth = 788
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 553
        ExplicitWidth = 549
        inherited pnlFrmBtnsMain: TPanel
          Left = 454
          ExplicitLeft = 450
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 226
          ExplicitLeft = 222
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 355
          ExplicitLeft = 351
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 86
          ExplicitWidth = 82
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 339
    Width = 565
    ExplicitTop = 338
    ExplicitWidth = 561
    inherited lblStatusBarR: TLabel
      Left = 492
      Height = 14
      ExplicitLeft = 492
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
