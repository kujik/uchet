inherited FrmCWAcoountBasis: TFrmCWAcoountBasis
  Caption = 'FrmCWAcoountBasis'
  ClientHeight = 423
  ClientWidth = 780
  ExplicitWidth = 792
  ExplicitHeight = 461
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 780
    Height = 407
    ExplicitWidth = 780
    ExplicitHeight = 407
    inherited pnlFrmClient: TPanel
      Width = 770
      Height = 358
      ExplicitWidth = 766
      ExplicitHeight = 357
      object pnlBottom: TPanel
        Left = 0
        Top = 317
        Width = 770
        Height = 41
        Align = alBottom
        TabOrder = 0
        ExplicitTop = 316
        ExplicitWidth = 766
        DesignSize = (
          770
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
          Width = 579
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          ReadOnly = True
          TabOrder = 0
          ExplicitWidth = 575
        end
        object nedtPrc: TDBNumberEditEh
          Left = 628
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
          ExplicitLeft = 624
        end
        object btnOk: TBitBtn
          Left = 703
          Top = 6
          Width = 42
          Height = 25
          Anchors = [akTop, akRight]
          Caption = '>>>'
          TabOrder = 2
          OnClick = btnOkClick
          ExplicitLeft = 699
        end
      end
      object pgcMain: TPageControl
        Left = 0
        Top = 0
        Width = 770
        Height = 317
        ActivePage = tsOrders
        Align = alClient
        TabOrder = 1
        OnChange = pgcMainChange
        ExplicitWidth = 766
        ExplicitHeight = 316
        object tsOrders: TTabSheet
          Caption = #1047#1072#1082#1072#1079#1099
          inline Frg1: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 762
            Height = 289
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 758
            ExplicitHeight = 288
            inherited pnlGrid: TPanel
              Width = 752
              Height = 235
              ExplicitWidth = 748
              ExplicitHeight = 234
              inherited DbGridEh1: TDBGridEh
                Width = 750
                Height = 212
                Columns = <
                  item
                    CellButtons = <>
                    DynProps = <>
                    EditButtons = <>
                    FieldName = 'iii'
                    Footers = <>
                  end>
                inherited RowDetailData: TRowDetailPanelControlEh
                  ExplicitLeft = 30
                  ExplicitTop = 35
                  ExplicitWidth = 46
                  ExplicitHeight = 120
                  inherited PRowDetailPanel: TPanel
                    Width = 44
                    ExplicitWidth = 44
                  end
                end
              end
              inherited pnlStatusBar: TPanel
                Top = 213
                Width = 750
                ExplicitTop = 212
                ExplicitWidth = 746
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
              Height = 235
              ExplicitHeight = 234
            end
            inherited pnlTop: TPanel
              Width = 762
              ExplicitWidth = 758
            end
            inherited pnlContainer: TPanel
              Width = 762
              ExplicitWidth = 758
            end
            inherited pnlBottom: TPanel
              Top = 289
              Width = 762
              ExplicitTop = 288
              ExplicitWidth = 758
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
        object tsAccounts: TTabSheet
          Caption = #1057#1095#1077#1090#1072
          ImageIndex = 1
          inline Frg2: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 762
            Height = 289
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 758
            ExplicitHeight = 288
            inherited pnlGrid: TPanel
              Width = 752
              Height = 235
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
              Height = 235
              ExplicitHeight = 361
            end
            inherited pnlTop: TPanel
              Width = 762
              ExplicitWidth = 778
            end
            inherited pnlContainer: TPanel
              Width = 762
              ExplicitWidth = 778
            end
            inherited pnlBottom: TPanel
              Top = 289
              Width = 762
              ExplicitTop = 415
              ExplicitWidth = 778
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
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 363
      Width = 770
      ExplicitTop = 362
      ExplicitWidth = 766
      inherited bvlFrmBtnsTl: TBevel
        Width = 768
        ExplicitWidth = 784
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 768
        ExplicitWidth = 784
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 768
        ExplicitWidth = 764
        inherited pnlFrmBtnsMain: TPanel
          Left = 669
          ExplicitLeft = 665
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 441
          ExplicitLeft = 437
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 570
          ExplicitLeft = 566
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 301
          ExplicitWidth = 297
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 407
    Width = 780
    ExplicitTop = 406
    ExplicitWidth = 776
    inherited lblStatusBarR: TLabel
      Left = 707
      Height = 14
      ExplicitLeft = 707
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 264
    Top = 360
  end
end
