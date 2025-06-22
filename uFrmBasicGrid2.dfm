inherited FrmBasicGrid2: TFrmBasicGrid2
  Caption = 'FrmBasicGrid2'
  ClientHeight = 537
  ClientWidth = 800
  ExplicitWidth = 812
  ExplicitHeight = 575
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 800
    Height = 521
    ExplicitWidth = 800
    ExplicitHeight = 521
    inherited PMDIClient: TPanel
      Width = 790
      Height = 472
      ExplicitWidth = 786
      ExplicitHeight = 471
      object PTop: TPanel
        Left = 0
        Top = 0
        Width = 790
        Height = 9
        Align = alTop
        Caption = 'PTop'
        TabOrder = 0
        ExplicitWidth = 786
      end
      object PBottom: TPanel
        Left = 0
        Top = 426
        Width = 790
        Height = 5
        Align = alBottom
        Caption = 'PBottom'
        TabOrder = 1
        ExplicitTop = 425
        ExplicitWidth = 786
      end
      object PLeft: TPanel
        Left = 0
        Top = 9
        Width = 5
        Height = 417
        Align = alLeft
        Caption = 'PLeft'
        TabOrder = 2
        ExplicitHeight = 416
      end
      object PGrid1: TPanel
        Left = 5
        Top = 9
        Width = 780
        Height = 417
        Align = alClient
        Caption = 'PGrid1'
        TabOrder = 3
        ExplicitWidth = 776
        ExplicitHeight = 416
        object ImgTemp: TImage
          Left = 720
          Top = 2
          Width = 24
          Height = 24
        end
        inline Frg1: TFrDBGridEh
          Left = 1
          Top = 1
          Width = 778
          Height = 415
          Align = alClient
          TabOrder = 0
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 774
          ExplicitHeight = 414
          inherited PGrid: TPanel
            Width = 768
            Height = 361
            ExplicitWidth = 764
            ExplicitHeight = 360
            inherited DbGridEh1: TDBGridEh
              Width = 766
              Height = 338
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
            inherited PStatus: TPanel
              Top = 339
              Width = 766
              ExplicitTop = 338
              ExplicitWidth = 762
              inherited LbStatusBarLeft: TLabel
                Height = 13
                ExplicitHeight = 13
              end
            end
            inherited CProp: TDBEditEh
              Height = 21
              ExplicitHeight = 21
            end
          end
          inherited PLeft: TPanel
            Height = 361
            ExplicitHeight = 360
          end
          inherited PTop: TPanel
            Width = 778
            ExplicitWidth = 774
          end
          inherited PContainer: TPanel
            Width = 778
            ExplicitWidth = 774
          end
          inherited PBottom: TPanel
            Top = 415
            Width = 778
            ExplicitTop = 414
            ExplicitWidth = 774
          end
          inherited PrintDBGridEh1: TPrintDBGridEh
            BeforeGridText_Data = {
              7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
              7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
              305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
              666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
              6E657261746F722052696368656432302031302E302E32323030307D5C766965
              776B696E64345C756331200D0A5C706172645C66305C667331365C2763665C27
              66305C2765655C2765355C2765615C2766323A20255B50726F656B745D5C7061
              720D0A5C2763665C2765355C2766305C2765385C2765655C276534205C276631
              205C66315C6C616E67313033332020255B4474315D205C66305C6C616E673130
              34395C2765665C2765655C66315C6C616E67313033332020255B4474325D5C66
              305C6C616E67313034395C7061720D0A5C7061720D0A7D0D0A00}
          end
        end
      end
      object PFrg2: TPanel
        Left = 0
        Top = 431
        Width = 790
        Height = 41
        Align = alBottom
        Caption = 'PFrg2'
        TabOrder = 4
        ExplicitTop = 430
        ExplicitWidth = 786
        inline Frg2: TFrDBGridEh
          Left = 1
          Top = 1
          Width = 788
          Height = 39
          Align = alClient
          TabOrder = 0
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 784
          ExplicitHeight = 39
          inherited PGrid: TPanel
            Top = 34
            Width = 778
            Height = 5
            ExplicitTop = 34
            ExplicitWidth = 774
            ExplicitHeight = 5
            inherited DbGridEh1: TDBGridEh
              Width = 776
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
            inherited PStatus: TPanel
              Top = -17
              Width = 776
              ExplicitTop = -17
              ExplicitWidth = 772
              inherited LbStatusBarLeft: TLabel
                Height = 13
                ExplicitHeight = 13
              end
            end
            inherited CProp: TDBEditEh
              Height = 21
              ExplicitHeight = 21
            end
          end
          inherited PLeft: TPanel
            Top = 34
            Height = 5
            ExplicitTop = 34
            ExplicitHeight = 5
          end
          inherited PTop: TPanel
            Top = 29
            Width = 788
            ExplicitTop = 29
            ExplicitWidth = 784
          end
          inherited PContainer: TPanel
            Width = 788
            Height = 29
            ExplicitWidth = 784
            ExplicitHeight = 29
          end
          inherited PBottom: TPanel
            Top = 39
            Width = 788
            ExplicitTop = 39
            ExplicitWidth = 784
          end
          inherited PrintDBGridEh1: TPrintDBGridEh
            BeforeGridText_Data = {
              7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
              7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
              305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
              666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
              6E657261746F722052696368656432302031302E302E32323030307D5C766965
              776B696E64345C756331200D0A5C706172645C66305C667331365C2763665C27
              66305C2765655C2765355C2765615C2766323A20255B50726F656B745D5C7061
              720D0A5C2763665C2765355C2766305C2765385C2765655C276534205C276631
              205C66315C6C616E67313033332020255B4474315D205C66305C6C616E673130
              34395C2765665C2765655C66315C6C616E67313033332020255B4474325D5C66
              305C6C616E67313034395C7061720D0A5C7061720D0A7D0D0A00}
          end
        end
      end
      object PRight: TPanel
        Left = 785
        Top = 9
        Width = 5
        Height = 417
        Align = alRight
        Caption = 'PLeft'
        TabOrder = 5
        ExplicitLeft = 781
        ExplicitHeight = 416
      end
    end
    inherited PDlgPanel: TPanel
      Top = 477
      Width = 790
      ExplicitTop = 476
      ExplicitWidth = 786
      inherited BvDlg: TBevel
        Width = 788
        ExplicitWidth = 506
      end
      inherited BvDlgBottom: TBevel
        Width = 788
        ExplicitWidth = 506
      end
      inherited PDlgMain: TPanel
        Width = 788
        ExplicitWidth = 784
        inherited PDlgBtnForm: TPanel
          Left = 689
          ExplicitLeft = 685
        end
        inherited PDlgChb: TPanel
          Left = 461
          ExplicitLeft = 457
        end
        inherited PDlgBtnR: TPanel
          Left = 590
          ExplicitLeft = 586
        end
        inherited PDlgCenter: TPanel
          Width = 321
          ExplicitWidth = 317
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 521
    Width = 800
    ExplicitTop = 520
    ExplicitWidth = 796
    inherited LbStatusBarRight: TLabel
      Left = 708
      Height = 14
      ExplicitLeft = 708
    end
    inherited LbStatusBarLeft: TLabel
      Height = 14
    end
  end
end
