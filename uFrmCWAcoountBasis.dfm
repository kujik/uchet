inherited FrmCWAcoountBasis: TFrmCWAcoountBasis
  Caption = 'FrmCWAcoountBasis'
  ClientHeight = 426
  ClientWidth = 792
  ExplicitWidth = 808
  ExplicitHeight = 465
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 792
    Height = 410
    ExplicitWidth = 796
    ExplicitHeight = 411
    inherited pnlFrmClient: TPanel
      Width = 782
      Height = 361
      ExplicitWidth = 782
      ExplicitHeight = 361
      object pnlBottom: TPanel
        Left = 0
        Top = 320
        Width = 782
        Height = 41
        Align = alBottom
        TabOrder = 0
        ExplicitLeft = 1
        ExplicitTop = 306
        ExplicitWidth = 842
        DesignSize = (
          782
          41)
        object btn1: TSpeedButton
          Left = 414
          Top = 9
          Width = 23
          Height = 22
        end
        object imgInfomain: TImage
          Left = 4
          Top = 8
          Width = 21
          Height = 20
          Anchors = []
          ExplicitLeft = 5
        end
        object edtBasis: TEdit
          Left = 32
          Top = 9
          Width = 607
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          ReadOnly = True
          TabOrder = 0
          ExplicitWidth = 671
        end
        object nedtPrc: TDBNumberEditEh
          Left = 656
          Top = 9
          Width = 49
          Height = 21
          ControlLabel.Width = 11
          ControlLabel.Height = 13
          ControlLabel.Caption = '%'
          ControlLabel.Visible = True
          ControlLabelLocation.Position = lpLeftCenterEh
          Anchors = [akTop, akRight]
          DecimalPlaces = 0
          DynProps = <>
          EditButtons = <>
          MaxValue = 100.000000000000000000
          TabOrder = 1
          Visible = True
          ExplicitLeft = 720
        end
        object btnOk: TBitBtn
          Left = 731
          Top = 6
          Width = 42
          Height = 25
          Anchors = [akTop, akRight]
          Caption = '>>>'
          TabOrder = 2
          OnClick = btnOkClick
          ExplicitLeft = 739
        end
      end
      object pgcMain: TPageControl
        Left = 0
        Top = 0
        Width = 782
        Height = 320
        ActivePage = tsOrders
        Align = alClient
        TabOrder = 1
        OnChange = pgcMainChange
        object tsOrders: TTabSheet
          Caption = #1047#1072#1082#1072#1079#1099
          inline Frg1: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 774
            Height = 292
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 774
            ExplicitHeight = 292
            inherited pnlGrid: TPanel
              Width = 764
              Height = 238
              ExplicitWidth = 768
              ExplicitHeight = 361
              inherited DbGridEh1: TDBGridEh
                Width = 766
                Height = 216
                Columns = <
                  item
                    CellButtons = <>
                    DynProps = <>
                    EditButtons = <>
                    FieldName = 'iii'
                    Footers = <>
                  end>
                inherited RowDetailData: TRowDetailPanelControlEh
                  ExplicitWidth = 46
                  inherited PRowDetailPanel: TPanel
                    Width = 44
                    ExplicitWidth = 44
                  end
                end
              end
              inherited pnlStatusBar: TPanel
                Top = 217
                Width = 766
                ExplicitTop = 339
                ExplicitWidth = 766
                inherited lblStatusBarL: TLabel
                  Height = 13
                  ExplicitHeight = 13
                end
              end
            end
            inherited pnlLeft: TPanel
              Height = 238
              ExplicitHeight = 361
            end
            inherited pnlTop: TPanel
              Width = 774
              ExplicitWidth = 778
            end
            inherited pnlContainer: TPanel
              Width = 774
              ExplicitWidth = 778
            end
            inherited pnlBottom: TPanel
              Top = 292
              Width = 774
              ExplicitTop = 415
              ExplicitWidth = 778
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
        object tsAccounts: TTabSheet
          Caption = #1057#1095#1077#1090#1072
          ImageIndex = 1
          inline Frg2: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 774
            Height = 292
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 774
            ExplicitHeight = 292
            inherited pnlGrid: TPanel
              Width = 764
              Height = 238
              ExplicitWidth = 768
              ExplicitHeight = 361
              inherited DbGridEh1: TDBGridEh
                Width = 766
                Height = 216
                Columns = <
                  item
                    CellButtons = <>
                    DynProps = <>
                    EditButtons = <>
                    FieldName = 'iii'
                    Footers = <>
                  end>
                inherited RowDetailData: TRowDetailPanelControlEh
                  ExplicitWidth = 46
                  inherited PRowDetailPanel: TPanel
                    Width = 44
                    ExplicitWidth = 44
                  end
                end
              end
              inherited pnlStatusBar: TPanel
                Top = 217
                Width = 766
                ExplicitTop = 339
                ExplicitWidth = 766
                inherited lblStatusBarL: TLabel
                  Height = 13
                  ExplicitHeight = 13
                end
              end
            end
            inherited pnlLeft: TPanel
              Height = 238
              ExplicitHeight = 361
            end
            inherited pnlTop: TPanel
              Width = 774
              ExplicitWidth = 778
            end
            inherited pnlContainer: TPanel
              Width = 774
              ExplicitWidth = 778
            end
            inherited pnlBottom: TPanel
              Top = 292
              Width = 774
              ExplicitTop = 415
              ExplicitWidth = 778
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
    end
    inherited pnlFrmBtns: TPanel
      Top = 366
      Width = 782
      ExplicitTop = 367
      ExplicitWidth = 786
      inherited bvlFrmBtnsTl: TBevel
        Width = 784
        ExplicitWidth = 784
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 784
        ExplicitWidth = 784
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 784
        ExplicitWidth = 784
        inherited pnlFrmBtnsMain: TPanel
          Left = 685
          ExplicitLeft = 685
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 457
          ExplicitLeft = 457
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 586
          ExplicitLeft = 586
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 317
          ExplicitWidth = 317
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 410
    Width = 792
    ExplicitTop = 411
    ExplicitWidth = 796
    inherited lblStatusBarR: TLabel
      Left = 704
      ExplicitLeft = 704
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 264
    Top = 360
  end
end
