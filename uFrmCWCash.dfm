inherited FrmCWCash: TFrmCWCash
  Caption = 'FrmCWCash'
  ClientHeight = 643
  ClientWidth = 1000
  OnResize = FormResize
  ExplicitWidth = 1012
  ExplicitHeight = 681
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 1000
    Height = 627
    ExplicitWidth = 1000
    ExplicitHeight = 627
    inherited pnlFrmClient: TPanel
      Width = 990
      Height = 578
      ExplicitWidth = 986
      ExplicitHeight = 577
      object pnlTop: TPanel
        Left = 0
        Top = 0
        Width = 990
        Height = 49
        Align = alTop
        Caption = 'pnlTop'
        TabOrder = 0
        ExplicitWidth = 986
        object btnRefresh: TSpeedButton
          Left = 9
          Top = 11
          Width = 32
          Height = 32
          OnClick = btnRefreshClick
        end
        object lblCaption: TLabel
          Left = 47
          Top = 20
          Width = 261
          Height = 16
          Caption = #1046#1091#1088#1085#1072#1083' '#1050#1072#1089#1089#1099'1 '#1089' 01.01.2022 '#1087#1086' 29.09.2022'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
      end
      object pnlCheck: TPanel
        Left = 0
        Top = 49
        Width = 990
        Height = 40
        Align = alTop
        Caption = 'pnlCheck'
        TabOrder = 1
        ExplicitWidth = 986
        object lblCaptionL: TLabel
          Left = 12
          Top = 21
          Width = 46
          Height = 13
          Caption = #1055#1088#1080#1093#1086#1076#1099
        end
        object lblCaptionR: TLabel
          Left = 512
          Top = 21
          Width = 44
          Height = 13
          Caption = #1056#1072#1089#1093#1086#1076#1099
        end
        object chbViewAll: TCheckBox
          Left = 12
          Top = 0
          Width = 399
          Height = 17
          Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1087#1077#1088#1077#1084#1077#1097#1077#1085#1080#1077' '#1076#1077#1085#1077#1078#1085#1099#1093' '#1089#1088#1077#1076#1089#1090#1074
          TabOrder = 0
          OnClick = chbViewAllClick
        end
      end
      object pnlTotal1: TPanel
        Left = 0
        Top = 482
        Width = 990
        Height = 35
        Align = alBottom
        Caption = 'pnlTotal1'
        TabOrder = 2
        ExplicitTop = 481
        ExplicitWidth = 986
        object edt1: TDBEditEh
          Left = 96
          Top = 4
          Width = 121
          Height = 21
          Alignment = taRightJustify
          ControlLabel.Width = 31
          ControlLabel.Height = 13
          ControlLabel.Caption = #1057#1091#1084#1084#1072
          ControlLabel.Visible = True
          ControlLabelLocation.Position = lpLeftCenterEh
          DynProps = <>
          EditButtons = <>
          ReadOnly = True
          TabOrder = 0
          Text = 'edt1'
          Visible = True
        end
      end
      object pnlTotal2: TPanel
        Left = 0
        Top = 517
        Width = 990
        Height = 61
        Align = alBottom
        Caption = 'pnlTotal2'
        TabOrder = 3
        ExplicitTop = 516
        ExplicitWidth = 986
        object edt2: TDBEditEh
          Left = 96
          Top = 6
          Width = 121
          Height = 21
          Alignment = taRightJustify
          ControlLabel.Width = 31
          ControlLabel.Height = 13
          ControlLabel.Caption = #1057#1091#1084#1084#1072
          ControlLabel.Visible = True
          ControlLabelLocation.Position = lpLeftCenterEh
          DynProps = <>
          EditButtons = <>
          ReadOnly = True
          TabOrder = 0
          Text = 'edt1'
          Visible = True
        end
        object edt3: TDBEditEh
          Left = 328
          Top = 6
          Width = 121
          Height = 21
          Alignment = taRightJustify
          ControlLabel.Width = 35
          ControlLabel.Height = 13
          ControlLabel.Caption = #1050#1072#1089#1089#1072'1'
          ControlLabel.Visible = True
          ControlLabelLocation.Position = lpLeftCenterEh
          DynProps = <>
          EditButtons = <>
          ReadOnly = True
          TabOrder = 1
          Text = 'edt1'
          Visible = True
        end
        object edt4: TDBEditEh
          Left = 568
          Top = 6
          Width = 121
          Height = 21
          Alignment = taRightJustify
          ControlLabel.Width = 35
          ControlLabel.Height = 13
          ControlLabel.Caption = #1050#1072#1089#1089#1072'2'
          ControlLabel.Visible = True
          ControlLabelLocation.Position = lpLeftCenterEh
          DynProps = <>
          EditButtons = <>
          ReadOnly = True
          TabOrder = 2
          Text = 'edt1'
          Visible = True
        end
        object edt5: TDBEditEh
          Left = 808
          Top = 6
          Width = 121
          Height = 21
          Alignment = taRightJustify
          ControlLabel.Width = 43
          ControlLabel.Height = 13
          ControlLabel.Caption = #1044#1077#1087#1086#1079#1080#1090
          ControlLabel.Visible = True
          ControlLabelLocation.Position = lpLeftCenterEh
          DynProps = <>
          EditButtons = <>
          ReadOnly = True
          TabOrder = 3
          Text = 'edt1'
          Visible = True
        end
        object edt6: TDBEditEh
          Left = 96
          Top = 33
          Width = 121
          Height = 21
          Alignment = taRightJustify
          ControlLabel.Width = 88
          ControlLabel.Height = 13
          ControlLabel.Caption = #1055#1088#1080#1093#1086#1076#1099' '#1079#1072' '#1076#1077#1085#1100
          ControlLabel.Visible = True
          ControlLabelLocation.Position = lpLeftCenterEh
          DynProps = <>
          EditButtons = <>
          ReadOnly = True
          TabOrder = 4
          Text = 'edt1'
          Visible = True
        end
        object edt7: TDBEditEh
          Left = 328
          Top = 33
          Width = 121
          Height = 21
          Alignment = taRightJustify
          ControlLabel.Width = 86
          ControlLabel.Height = 13
          ControlLabel.Caption = #1056#1072#1089#1093#1086#1076#1099' '#1079#1072' '#1076#1077#1085#1100
          ControlLabel.Visible = True
          ControlLabelLocation.Position = lpLeftCenterEh
          DynProps = <>
          EditButtons = <>
          ReadOnly = True
          TabOrder = 5
          Text = 'edt1'
          Visible = True
        end
      end
      inline Frg1: TFrDBGridEh
        Left = 0
        Top = 89
        Width = 500
        Height = 393
        Align = alLeft
        TabOrder = 4
        ExplicitTop = 89
        ExplicitWidth = 500
        ExplicitHeight = 392
        inherited pnlGrid: TPanel
          Width = 490
          Height = 339
          ExplicitWidth = 490
          ExplicitHeight = 338
          inherited DbGridEh1: TDBGridEh
            Width = 488
            Height = 316
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
            Top = 317
            Width = 488
            ExplicitTop = 316
            ExplicitWidth = 488
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
          Height = 339
          ExplicitHeight = 338
        end
        inherited pnlTop: TPanel
          Width = 500
          ExplicitWidth = 500
        end
        inherited pnlContainer: TPanel
          Width = 500
          ExplicitWidth = 500
        end
        inherited pnlBottom: TPanel
          Top = 393
          Width = 500
          ExplicitTop = 392
          ExplicitWidth = 500
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
      inline Frg2: TFrDBGridEh
        Left = 500
        Top = 89
        Width = 490
        Height = 393
        Align = alClient
        TabOrder = 5
        ExplicitLeft = 500
        ExplicitTop = 89
        ExplicitWidth = 486
        ExplicitHeight = 392
        inherited pnlGrid: TPanel
          Width = 480
          Height = 339
          ExplicitWidth = 476
          ExplicitHeight = 338
          inherited DbGridEh1: TDBGridEh
            Width = 478
            Height = 316
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
            Top = 317
            Width = 478
            ExplicitTop = 316
            ExplicitWidth = 474
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
          Height = 339
          ExplicitHeight = 338
        end
        inherited pnlTop: TPanel
          Width = 490
          ExplicitWidth = 486
        end
        inherited pnlContainer: TPanel
          Width = 490
          ExplicitWidth = 486
        end
        inherited pnlBottom: TPanel
          Top = 393
          Width = 490
          ExplicitTop = 392
          ExplicitWidth = 486
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
    inherited pnlFrmBtns: TPanel
      Top = 583
      Width = 990
      ExplicitTop = 582
      ExplicitWidth = 986
      inherited bvlFrmBtnsTl: TBevel
        Width = 988
        ExplicitWidth = 1000
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 988
        ExplicitWidth = 1000
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 988
        ExplicitWidth = 984
        inherited pnlFrmBtnsMain: TPanel
          Left = 889
          ExplicitLeft = 885
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 661
          ExplicitLeft = 657
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 790
          ExplicitLeft = 786
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 521
          ExplicitWidth = 517
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 627
    Width = 1000
    ExplicitTop = 626
    ExplicitWidth = 996
    inherited lblStatusBarR: TLabel
      Left = 927
      ExplicitLeft = 931
    end
  end
end
