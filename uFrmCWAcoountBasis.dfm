inherited FrmCWAcoountBasis: TFrmCWAcoountBasis
  Caption = 'FrmCWAcoountBasis'
  ClientHeight = 424
  ClientWidth = 784
  ExplicitWidth = 800
  ExplicitHeight = 463
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 784
    Height = 408
    ExplicitWidth = 788
    ExplicitHeight = 409
    inherited pnlFrmClient: TPanel
      Width = 774
      Height = 359
      ExplicitWidth = 774
      ExplicitHeight = 359
      object pnlBottom: TPanel
        Left = 0
        Top = 318
        Width = 774
        Height = 41
        Align = alBottom
        TabOrder = 0
        DesignSize = (
          774
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
          Width = 591
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          ReadOnly = True
          TabOrder = 0
        end
        object nedtPrc: TDBNumberEditEh
          Left = 640
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
        end
        object btnOk: TBitBtn
          Left = 715
          Top = 6
          Width = 42
          Height = 25
          Anchors = [akTop, akRight]
          Caption = '>>>'
          TabOrder = 2
          OnClick = btnOkClick
        end
      end
      object pgcMain: TPageControl
        Left = 0
        Top = 0
        Width = 774
        Height = 318
        ActivePage = tsOrders
        Align = alClient
        TabOrder = 1
        OnChange = pgcMainChange
        object tsOrders: TTabSheet
          Caption = #1047#1072#1082#1072#1079#1099
          inline Frg1: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 766
            Height = 290
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 766
            ExplicitHeight = 290
            inherited pnlGrid: TPanel
              Width = 756
              Height = 236
              ExplicitWidth = 756
              ExplicitHeight = 236
              inherited DbGridEh1: TDBGridEh
                Width = 758
                Height = 214
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
                Top = 215
                Width = 758
                ExplicitTop = 214
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
              Height = 236
              ExplicitHeight = 236
            end
            inherited pnlTop: TPanel
              Width = 766
              ExplicitWidth = 766
            end
            inherited pnlContainer: TPanel
              Width = 766
              ExplicitWidth = 766
            end
            inherited pnlBottom: TPanel
              Top = 290
              Width = 766
              ExplicitTop = 290
              ExplicitWidth = 766
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
            Width = 766
            Height = 290
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 766
            ExplicitHeight = 290
            inherited pnlGrid: TPanel
              Width = 756
              Height = 236
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
              Height = 236
              ExplicitHeight = 361
            end
            inherited pnlTop: TPanel
              Width = 766
              ExplicitWidth = 778
            end
            inherited pnlContainer: TPanel
              Width = 766
              ExplicitWidth = 778
            end
            inherited pnlBottom: TPanel
              Top = 290
              Width = 766
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
      Top = 364
      Width = 774
      ExplicitTop = 364
      ExplicitWidth = 774
      inherited bvlFrmBtnsTl: TBevel
        Width = 776
        ExplicitWidth = 784
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 776
        ExplicitWidth = 784
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 776
        ExplicitWidth = 772
        inherited pnlFrmBtnsMain: TPanel
          Left = 677
          ExplicitLeft = 673
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 449
          ExplicitLeft = 445
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 578
          ExplicitLeft = 574
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 309
          ExplicitWidth = 305
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 408
    Width = 784
    ExplicitTop = 408
    ExplicitWidth = 784
    inherited lblStatusBarR: TLabel
      Left = 715
      ExplicitLeft = 715
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 264
    Top = 360
  end
end
