inherited FrmODedtNomenclFiles: TFrmODedtNomenclFiles
  Caption = 'FrmDlgDrawingAddAndView'
  ClientHeight = 250
  ClientWidth = 772
  ExplicitWidth = 784
  ExplicitHeight = 288
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 772
    Height = 234
    ExplicitWidth = 772
    ExplicitHeight = 234
    inherited PMDIClient: TPanel
      Width = 762
      Height = 185
      ExplicitWidth = 758
      ExplicitHeight = 184
      object PNomencl: TPanel
        Left = 0
        Top = 0
        Width = 762
        Height = 17
        Align = alTop
        Caption = 'PNomencl'
        TabOrder = 0
        ExplicitWidth = 758
        object LbNomencl: TLabel
          Left = 4
          Top = -2
          Width = 51
          Height = 13
          Caption = 'LbNomencl'
        end
      end
      object Panel1: TPanel
        Left = 0
        Top = 17
        Width = 762
        Height = 168
        Align = alClient
        Caption = 'Panel1'
        TabOrder = 1
        ExplicitWidth = 758
        ExplicitHeight = 167
        inline Frg1: TFrDBGridEh
          Left = 1
          Top = 1
          Width = 760
          Height = 166
          Align = alClient
          TabOrder = 0
          ExplicitLeft = 1
          ExplicitTop = 1
          ExplicitWidth = 756
          ExplicitHeight = 165
          inherited PGrid: TPanel
            Top = 22
            Width = 750
            Height = 144
            ExplicitTop = 22
            ExplicitWidth = 746
            ExplicitHeight = 143
            inherited DbGridEh1: TDBGridEh
              Width = 748
              Height = 121
              OnDblClick = Frg1DbGridEh1DblClick
              inherited RowDetailData: TRowDetailPanelControlEh
                ExplicitTop = 35
                ExplicitHeight = 81
                inherited PRowDetailPanel: TPanel
                  Height = 79
                  ExplicitHeight = 79
                end
              end
            end
            inherited PStatus: TPanel
              Top = 122
              Width = 748
              ExplicitTop = 121
              ExplicitWidth = 744
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
            Top = 22
            Height = 144
            ExplicitTop = 22
            ExplicitHeight = 143
          end
          inherited PTop: TPanel
            Top = 17
            Width = 760
            ExplicitTop = 17
            ExplicitWidth = 756
          end
          inherited PContainer: TPanel
            Width = 760
            Height = 17
            ExplicitWidth = 756
            ExplicitHeight = 17
          end
          inherited PBottom: TPanel
            Top = 166
            Width = 760
            ExplicitTop = 165
            ExplicitWidth = 756
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
    end
    inherited PDlgPanel: TPanel
      Top = 190
      Width = 762
      ExplicitTop = 189
      ExplicitWidth = 758
      inherited BvDlg: TBevel
        Width = 760
        ExplicitWidth = 760
      end
      inherited BvDlgBottom: TBevel
        Width = 760
        ExplicitWidth = 760
      end
      inherited PDlgMain: TPanel
        Width = 760
        ExplicitWidth = 756
        inherited PDlgBtnForm: TPanel
          Left = 661
          ExplicitLeft = 657
        end
        inherited PDlgChb: TPanel
          Left = 399
          ExplicitLeft = 395
        end
        inherited PDlgBtnR: TPanel
          Left = 528
          Width = 133
          ExplicitLeft = 524
          ExplicitWidth = 133
        end
        inherited PDlgCenter: TPanel
          Width = 259
          ExplicitWidth = 255
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 234
    Width = 772
    ExplicitTop = 233
    ExplicitWidth = 768
    inherited LbStatusBarRight: TLabel
      Left = 680
      ExplicitLeft = 680
    end
  end
  inherited Timer_AfterStart: TTimer
    Left = 88
    Top = 184
  end
  object OpenDialog1: TOpenDialog
    Left = 139
    Top = 171
  end
end
