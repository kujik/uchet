inherited FrmOWedtOrReglament: TFrmOWedtOrReglament
  Caption = 'FrmOWedtOrReglament'
  ClientHeight = 534
  ClientWidth = 1052
  ExplicitWidth = 1064
  ExplicitHeight = 572
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 1052
    Height = 518
    ExplicitWidth = 1052
    ExplicitHeight = 518
    inherited pnlFrmClient: TPanel
      Width = 1042
      Height = 469
      ExplicitWidth = 1038
      ExplicitHeight = 468
      object pnlTop: TPanel
        Left = 0
        Top = 0
        Width = 1042
        Height = 41
        Align = alTop
        Caption = 'pnlTop'
        TabOrder = 0
        ExplicitWidth = 1038
        DesignSize = (
          1042
          41)
        object nedt_deadline: TDBNumberEditEh
          Left = 974
          Top = 14
          Width = 49
          Height = 21
          ControlLabel.Width = 90
          ControlLabel.Height = 13
          ControlLabel.Caption = #1057#1088#1086#1082' '#1074#1099#1087#1086#1083#1085#1077#1085#1080#1103
          ControlLabel.Visible = True
          ControlLabelLocation.Position = lpLeftCenterEh
          Anchors = [akTop, akRight]
          DecimalPlaces = 0
          DynProps = <>
          EditButton.DefaultAction = True
          EditButton.Style = ebsAltDropDownEh
          EditButtons = <>
          HighlightRequired = True
          MaxValue = 365.000000000000000000
          MinValue = 1.000000000000000000
          TabOrder = 0
          Visible = True
          OnButtonClick = nedt_deadlineButtonClick
        end
        object edt_name: TDBEditEh
          Left = 57
          Top = 14
          Width = 713
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          ControlLabel.Width = 49
          ControlLabel.Height = 13
          ControlLabel.Caption = #1054#1087#1080#1089#1072#1085#1080#1077
          ControlLabel.Visible = True
          ControlLabelLocation.Position = lpLeftCenterEh
          DynProps = <>
          EditButtons = <>
          TabOrder = 1
          Text = 'edt_name'
          Visible = True
          ExplicitWidth = 709
        end
        object chb_active: TDBCheckBoxEh
          Left = 776
          Top = 18
          Width = 97
          Height = 17
          Anchors = [akTop, akRight]
          Caption = #1048#1089#1087#1086#1083#1100#1079#1091#1077#1090#1089#1103
          DynProps = <>
          TabOrder = 2
          ExplicitLeft = 772
        end
      end
      object pgcMain: TPageControl
        Left = 0
        Top = 41
        Width = 1042
        Height = 428
        ActivePage = tsPrioperties
        Align = alClient
        TabOrder = 1
        ExplicitWidth = 1038
        ExplicitHeight = 427
        object tsPrioperties: TTabSheet
          Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099
          object pnlTypes: TPanel
            Left = 0
            Top = 0
            Width = 329
            Height = 400
            Align = alLeft
            Caption = 'pnlTypes'
            TabOrder = 0
            ExplicitHeight = 399
            inline frmpcTypes: TFrMyPanelCaption
              Left = 1
              Top = 1
              Width = 327
              Height = 18
              Align = alTop
              TabOrder = 0
              ExplicitLeft = 1
              ExplicitTop = 1
              ExplicitWidth = 327
              inherited bvl1: TBevel
                Width = 327
                ExplicitWidth = 709
              end
            end
            inline FrgTypes: TFrDBGridEh
              Left = 1
              Top = 19
              Width = 327
              Height = 380
              Align = alClient
              TabOrder = 1
              ExplicitLeft = 1
              ExplicitTop = 19
              ExplicitWidth = 327
              ExplicitHeight = 379
              inherited pnlGrid: TPanel
                Width = 317
                Height = 326
                ExplicitWidth = 317
                ExplicitHeight = 325
                inherited DbGridEh1: TDBGridEh
                  Width = 315
                  Height = 303
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
                  Top = 304
                  Width = 315
                  ExplicitTop = 303
                  ExplicitWidth = 315
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
                Height = 326
                ExplicitHeight = 325
              end
              inherited pnlTop: TPanel
                Width = 327
                ExplicitWidth = 327
              end
              inherited pnlContainer: TPanel
                Width = 327
                ExplicitWidth = 327
              end
              inherited pnlBottom: TPanel
                Top = 380
                Width = 327
                ExplicitTop = 379
                ExplicitWidth = 327
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
          object pnlProperties: TPanel
            Left = 329
            Top = 0
            Width = 705
            Height = 400
            Align = alClient
            Caption = 'pnlProperties'
            TabOrder = 1
            ExplicitWidth = 701
            ExplicitHeight = 399
            inline frmpcProperties: TFrMyPanelCaption
              Left = 1
              Top = 1
              Width = 703
              Height = 18
              Align = alTop
              TabOrder = 0
              ExplicitLeft = 1
              ExplicitTop = 1
              ExplicitWidth = 699
              inherited bvl1: TBevel
                Width = 707
                ExplicitWidth = 707
              end
            end
            inline FrgProperties: TFrDBGridEh
              Left = 1
              Top = 19
              Width = 703
              Height = 380
              Align = alClient
              TabOrder = 1
              ExplicitLeft = 1
              ExplicitTop = 19
              ExplicitWidth = 699
              ExplicitHeight = 379
              inherited pnlGrid: TPanel
                Width = 693
                Height = 326
                ExplicitWidth = 689
                ExplicitHeight = 325
                inherited DbGridEh1: TDBGridEh
                  Width = 691
                  Height = 303
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
                  Top = 304
                  Width = 691
                  ExplicitTop = 303
                  ExplicitWidth = 687
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
                Height = 326
                ExplicitHeight = 325
              end
              inherited pnlTop: TPanel
                Width = 703
                ExplicitWidth = 699
              end
              inherited pnlContainer: TPanel
                Width = 703
                ExplicitWidth = 699
              end
              inherited pnlBottom: TPanel
                Top = 380
                Width = 703
                ExplicitTop = 379
                ExplicitWidth = 699
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
        end
        object tsDays: TTabSheet
          Caption = #1058#1072#1081#1084#1083#1072#1081#1085
          ImageIndex = 1
          inline FrgDays: TFrDBGridEh
            Left = 0
            Top = 18
            Width = 1034
            Height = 382
            Align = alClient
            TabOrder = 0
            ExplicitTop = 18
            ExplicitWidth = 1030
            ExplicitHeight = 381
            inherited pnlGrid: TPanel
              Width = 1024
              Height = 328
              ExplicitWidth = 1024
              ExplicitHeight = 328
              inherited DbGridEh1: TDBGridEh
                Width = 1022
                Height = 305
                OnCellClick = FrgDaysDbGridEh1CellClick
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
                Top = 306
                Width = 1022
                ExplicitTop = 306
                ExplicitWidth = 1022
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
              Height = 328
              ExplicitHeight = 328
            end
            inherited pnlTop: TPanel
              Width = 1034
              ExplicitWidth = 1034
            end
            inherited pnlContainer: TPanel
              Width = 1034
              ExplicitWidth = 1034
            end
            inherited pnlBottom: TPanel
              Top = 382
              Width = 1034
              ExplicitTop = 382
              ExplicitWidth = 1034
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
          inline frmpcDays: TFrMyPanelCaption
            Left = 0
            Top = 0
            Width = 1034
            Height = 18
            Align = alTop
            TabOrder = 1
            ExplicitWidth = 1034
            inherited bvl1: TBevel
              Width = 570
              ExplicitWidth = 707
            end
          end
        end
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 474
      Width = 1042
      ExplicitTop = 473
      ExplicitWidth = 1038
      inherited bvlFrmBtnsTl: TBevel
        Width = 1040
        ExplicitWidth = 1044
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 1040
        ExplicitWidth = 1044
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 1040
        ExplicitWidth = 1036
        inherited pnlFrmBtnsMain: TPanel
          Left = 941
          ExplicitLeft = 937
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 713
          ExplicitLeft = 709
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 842
          ExplicitLeft = 838
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 573
          ExplicitWidth = 569
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 518
    Width = 1052
    ExplicitTop = 517
    ExplicitWidth = 1048
    inherited lblStatusBarR: TLabel
      Left = 979
      Height = 14
      ExplicitLeft = 979
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 264
    Top = 520
  end
  object dlgColor1: TColorDialog
    Left = 530
    Top = 499
  end
end
