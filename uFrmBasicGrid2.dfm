inherited FrmBasicGrid2: TFrmBasicGrid2
  Caption = 'FrmBasicGrid2'
  ClientHeight = 535
  ClientWidth = 792
  ExplicitWidth = 804
  ExplicitHeight = 573
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 792
    Height = 519
    ExplicitWidth = 792
    ExplicitHeight = 519
    inherited pnlFrmClient: TPanel
      Width = 782
      Height = 470
      ExplicitWidth = 778
      ExplicitHeight = 469
      object pnlTop: TPanel
        Left = 0
        Top = 0
        Width = 782
        Height = 9
        Align = alTop
        Caption = 'pnlTop'
        TabOrder = 0
        ExplicitWidth = 778
      end
      object pnlBottom: TPanel
        Left = 0
        Top = 424
        Width = 782
        Height = 5
        Align = alBottom
        Caption = 'pnlBottom'
        TabOrder = 1
        ExplicitTop = 423
        ExplicitWidth = 778
      end
      object pnlLeft: TPanel
        Left = 0
        Top = 9
        Width = 5
        Height = 415
        Align = alLeft
        Caption = 'pnlLeft'
        TabOrder = 2
        ExplicitHeight = 414
      end
      object pnlGrid1: TPanel
        Left = 5
        Top = 9
        Width = 772
        Height = 415
        Align = alClient
        Caption = 'pnlGrid1'
        TabOrder = 3
        ExplicitWidth = 768
        ExplicitHeight = 414
        object imgTemp: TImage
          Left = 720
          Top = 2
          Width = 24
          Height = 24
        end
        inline Frg1: TFrDBGridEh
          Left = 1
          Top = 1
          Width = 770
          Height = 413
          Align = alClient
          TabOrder = 0
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 766
          ExplicitHeight = 412
          inherited pnlGrid: TPanel
            Width = 760
            Height = 359
            ExplicitWidth = 756
            ExplicitHeight = 358
            inherited DbGridEh1: TDBGridEh
              Width = 758
              Height = 336
              OnGetCellParams = Frg1DbGridEh1GetCellParams
              Columns = <
                item
                  CellButtons = <>
                  DynProps = <>
                  EditButtons = <>
                  FieldName = 'iii'
                  Footers = <>
                end>
              inherited RowDetailData: TRowDetailPanelControlEh
                ExplicitTop = 35
                ExplicitWidth = 46
                inherited PRowDetailPanel: TPanel
                  Width = 44
                  ExplicitWidth = 44
                end
              end
            end
            inherited pnlStatusBar: TPanel
              Top = 337
              Width = 758
              ExplicitTop = 336
              ExplicitWidth = 754
              inherited lblStatusBarL: TLabel
                Height = 13
                ExplicitHeight = 13
              end
            end
            inherited CProp: TDBEditEh
              Height = 21
              ExplicitHeight = 21
            end
          end
          inherited pnlLeft: TPanel
            Height = 359
            ExplicitHeight = 358
          end
          inherited pnlTop: TPanel
            Width = 770
            ExplicitWidth = 766
          end
          inherited pnlContainer: TPanel
            Width = 770
            ExplicitWidth = 766
          end
          inherited pnlBottom: TPanel
            Top = 413
            Width = 770
            ExplicitTop = 412
            ExplicitWidth = 766
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
      object pnlFrg2: TPanel
        Left = 0
        Top = 429
        Width = 782
        Height = 41
        Align = alBottom
        Caption = 'pnlFrg2'
        TabOrder = 4
        ExplicitTop = 428
        ExplicitWidth = 778
        inline Frg2: TFrDBGridEh
          Left = 1
          Top = 1
          Width = 780
          Height = 39
          Align = alClient
          TabOrder = 0
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 776
          ExplicitHeight = 39
          inherited pnlGrid: TPanel
            Top = 34
            Width = 770
            Height = 5
            ExplicitTop = 34
            ExplicitWidth = 766
            ExplicitHeight = 5
            inherited DbGridEh1: TDBGridEh
              Width = 768
              Height = 41
              OnGetCellParams = Frg2DbGridEh1GetCellParams
              Columns = <
                item
                  CellButtons = <>
                  DynProps = <>
                  EditButtons = <>
                  Footers = <>
                end>
              inherited RowDetailData: TRowDetailPanelControlEh
                ExplicitTop = 35
                ExplicitHeight = 2
                inherited PRowDetailPanel: TPanel
                  Height = 0
                  ExplicitHeight = 0
                end
              end
            end
            inherited pnlStatusBar: TPanel
              Top = -17
              Width = 768
              ExplicitTop = -17
              ExplicitWidth = 764
              inherited lblStatusBarL: TLabel
                Height = 13
                ExplicitHeight = 13
              end
            end
            inherited CProp: TDBEditEh
              Height = 21
              ExplicitHeight = 21
            end
          end
          inherited pnlLeft: TPanel
            Top = 34
            Height = 5
            ExplicitTop = 34
            ExplicitHeight = 5
          end
          inherited pnlTop: TPanel
            Top = 29
            Width = 780
            ExplicitTop = 29
            ExplicitWidth = 776
          end
          inherited pnlContainer: TPanel
            Width = 780
            Height = 29
            ExplicitWidth = 776
            ExplicitHeight = 29
          end
          inherited pnlBottom: TPanel
            Top = 39
            Width = 780
            ExplicitTop = 39
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
      object pnlRight: TPanel
        Left = 777
        Top = 9
        Width = 5
        Height = 415
        Align = alRight
        Caption = 'pnlLeft'
        TabOrder = 5
        ExplicitLeft = 773
        ExplicitHeight = 414
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 475
      Width = 782
      ExplicitTop = 474
      ExplicitWidth = 778
      inherited bvlFrmBtnsTl: TBevel
        Width = 780
        ExplicitWidth = 506
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 780
        ExplicitWidth = 506
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 780
        ExplicitWidth = 776
        inherited pnlFrmBtnsMain: TPanel
          Left = 681
          ExplicitLeft = 677
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 453
          ExplicitLeft = 449
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 582
          ExplicitLeft = 578
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 313
          ExplicitWidth = 309
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 519
    Width = 792
    ExplicitTop = 518
    ExplicitWidth = 788
    inherited lblStatusBarR: TLabel
      Left = 719
      Height = 14
      ExplicitLeft = 719
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
end
