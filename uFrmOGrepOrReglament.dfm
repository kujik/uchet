inherited FrmOGrepOrReglament: TFrmOGrepOrReglament
  Caption = 'FrmOGrepOrReglament'
  ClientHeight = 448
  ClientWidth = 565
  ExplicitWidth = 577
  ExplicitHeight = 486
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 565
    Height = 432
    ExplicitWidth = 565
    ExplicitHeight = 432
    inherited pnlFrmClient: TPanel
      Width = 555
      Height = 383
      ExplicitWidth = 551
      ExplicitHeight = 382
      inherited pnlTop: TPanel
        Width = 555
        Height = 35
        ExplicitWidth = 551
        ExplicitHeight = 35
        object lblDeadline: TLabel
          Left = 522
          Top = 6
          Width = 22
          Height = 24
          Anchors = [akTop, akRight]
          Caption = '34'
          Color = clBtnFace
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlue
          Font.Height = 24
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentColor = False
          ParentFont = False
        end
        object lblName: TLabel
          Left = 11
          Top = 16
          Width = 37
          Height = 13
          Caption = 'lblName'
        end
        object lblOrder: TLabel
          Left = 13
          Top = 4
          Width = 37
          Height = 13
          Caption = 'lblName'
          Color = clBtnFace
          ParentColor = False
        end
      end
      inherited pnlBottom: TPanel
        Top = 337
        Width = 555
        ExplicitTop = 336
        ExplicitWidth = 551
      end
      inherited pnlLeft: TPanel
        Top = 35
        Height = 302
        ExplicitTop = 35
        ExplicitHeight = 301
      end
      inherited pnlGrid1: TPanel
        Top = 35
        Width = 545
        Height = 302
        ExplicitTop = 35
        ExplicitWidth = 541
        ExplicitHeight = 301
        inherited Frg1: TFrDBGridEh
          Width = 543
          Height = 300
          ExplicitWidth = 539
          ExplicitHeight = 299
          inherited pnlGrid: TPanel
            Width = 533
            Height = 246
            ExplicitWidth = 529
            ExplicitHeight = 245
            inherited DbGridEh1: TDBGridEh
              Width = 531
              Height = 223
              HorzScrollBar.VisibleMode = sbNeverShowEh
              VertScrollBar.VisibleMode = sbNeverShowEh
            end
            inherited pnlStatusBar: TPanel
              Top = 224
              Width = 531
              ExplicitTop = 223
              ExplicitWidth = 527
            end
          end
          inherited pnlLeft: TPanel
            Height = 246
            ExplicitHeight = 245
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
            Top = 300
            Width = 543
            ExplicitTop = 299
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
        Top = 342
        Width = 555
        ExplicitTop = 341
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
        Left = 550
        Top = 35
        Height = 302
        ExplicitLeft = 546
        ExplicitTop = 35
        ExplicitHeight = 301
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 388
      Width = 555
      ExplicitTop = 387
      ExplicitWidth = 551
      inherited bvlFrmBtnsTl: TBevel
        Width = 553
        ExplicitWidth = 553
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 553
        ExplicitWidth = 553
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
    Top = 432
    Width = 565
    ExplicitTop = 431
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
