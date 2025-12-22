inherited FrmXGlstMain: TFrmXGlstMain
  Caption = 'FrmXGlstMain'
  ClientHeight = 359
  ClientWidth = 581
  ExplicitWidth = 593
  ExplicitHeight = 397
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 581
    Height = 343
    ExplicitWidth = 581
    ExplicitHeight = 343
    inherited pnlFrmClient: TPanel
      Width = 571
      Height = 294
      ExplicitWidth = 567
      ExplicitHeight = 293
      inherited pnlTop: TPanel
        Width = 571
        ExplicitWidth = 567
      end
      inherited pnlBottom: TPanel
        Top = 248
        Width = 571
        ExplicitTop = 247
        ExplicitWidth = 567
      end
      inherited pnlLeft: TPanel
        Height = 239
        ExplicitHeight = 238
      end
      inherited pnlGrid1: TPanel
        Width = 561
        Height = 239
        ExplicitWidth = 557
        ExplicitHeight = 238
        inherited Frg1: TFrDBGridEh
          Width = 559
          Height = 237
          ExplicitWidth = 555
          ExplicitHeight = 236
          inherited pnlGrid: TPanel
            Width = 549
            Height = 183
            ExplicitWidth = 545
            ExplicitHeight = 182
            inherited DbGridEh1: TDBGridEh
              Width = 547
              Height = 160
            end
            inherited pnlStatusBar: TPanel
              Top = 161
              Width = 547
              ExplicitTop = 160
              ExplicitWidth = 543
            end
          end
          inherited pnlLeft: TPanel
            Height = 183
            ExplicitHeight = 182
          end
          inherited pnlTop: TPanel
            Width = 559
            ExplicitWidth = 555
          end
          inherited pnlContainer: TPanel
            Width = 559
            ExplicitWidth = 555
          end
          inherited pnlBottom: TPanel
            Top = 237
            Width = 559
            ExplicitTop = 236
            ExplicitWidth = 555
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
        Top = 253
        Width = 571
        ExplicitTop = 252
        ExplicitWidth = 567
        inherited Frg2: TFrDBGridEh
          Width = 569
          ExplicitWidth = 565
          inherited pnlGrid: TPanel
            Width = 559
            ExplicitWidth = 555
            inherited DbGridEh1: TDBGridEh
              Width = 557
            end
            inherited pnlStatusBar: TPanel
              Width = 557
              ExplicitWidth = 553
            end
          end
          inherited pnlTop: TPanel
            Width = 569
            ExplicitWidth = 565
          end
          inherited pnlContainer: TPanel
            Width = 569
            ExplicitWidth = 565
          end
          inherited pnlBottom: TPanel
            Width = 569
            ExplicitWidth = 565
          end
          inherited PrintDBGridEh1: TPrintDBGridEh
            BeforeGridText_Data = {
              7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
              7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
              305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
              666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
              6E657261746F722052696368656432302031302E302E31393034317D5C766965
              776B696E64345C756331200D0A5C706172645C66305C667331362027255B446F
              63756D656E745C66315C6C616E6731303333205D205C66305C6C616E67313034
              3920255B546F6461795D20255B557365724E616D655D5C66315C6C616E673130
              333320205C66305C6C616E67313034395C7061720D0A7D0D0A00}
          end
        end
      end
      inherited pnlRight: TPanel
        Left = 566
        Height = 239
        ExplicitLeft = 562
        ExplicitHeight = 238
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 299
      Width = 571
      ExplicitTop = 298
      ExplicitWidth = 567
      inherited bvlFrmBtnsTl: TBevel
        Width = 569
        ExplicitWidth = 788
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 569
        ExplicitWidth = 788
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 569
        ExplicitWidth = 565
        inherited pnlFrmBtnsMain: TPanel
          Left = 470
          ExplicitLeft = 466
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 242
          ExplicitLeft = 238
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 371
          ExplicitLeft = 367
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 102
          ExplicitWidth = 98
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 343
    Width = 581
    ExplicitTop = 342
    ExplicitWidth = 577
    inherited lblStatusBarR: TLabel
      Left = 508
      Height = 14
      ExplicitLeft = 508
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
