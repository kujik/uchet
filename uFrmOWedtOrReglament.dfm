inherited FrmOWedtOrReglament: TFrmOWedtOrReglament
  Caption = 'FrmOWedtOrReglament'
  ClientHeight = 535
  ClientWidth = 1056
  ExplicitWidth = 1068
  ExplicitHeight = 573
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 1056
    Height = 519
    inherited pnlFrmClient: TPanel
      Width = 1046
      Height = 470
      object pnlTop: TPanel
        Left = 0
        Top = 0
        Width = 1046
        Height = 41
        Align = alTop
        Caption = 'pnlTop'
        TabOrder = 0
        ExplicitWidth = 256
        DesignSize = (
          1046
          41)
        object edt_name: TDBEditEh
          Left = 57
          Top = 14
          Width = 830
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          ControlLabel.Width = 49
          ControlLabel.Height = 13
          ControlLabel.Caption = #1054#1087#1080#1089#1072#1085#1080#1077
          ControlLabel.Visible = True
          ControlLabelLocation.Position = lpLeftCenterEh
          DynProps = <>
          EditButtons = <>
          TabOrder = 0
          Text = 'edt_name'
          Visible = True
          ExplicitWidth = 40
        end
        object nedtDeadline: TDBNumberEditEh
          Left = 992
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
          TabOrder = 1
          Visible = True
          ExplicitLeft = 202
        end
      end
      object pgcMain: TPageControl
        Left = 0
        Top = 41
        Width = 1046
        Height = 429
        ActivePage = tsPrioperties
        Align = alClient
        TabOrder = 1
        ExplicitWidth = 256
        ExplicitHeight = 466
        object tsPrioperties: TTabSheet
          Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099
          object pnlTypes: TPanel
            Left = 0
            Top = 0
            Width = 329
            Height = 401
            Align = alLeft
            Caption = 'pnlTypes'
            TabOrder = 0
            ExplicitHeight = 438
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
              Height = 381
              Align = alClient
              TabOrder = 1
              ExplicitLeft = 1
              ExplicitTop = 19
              ExplicitWidth = 327
              ExplicitHeight = 418
              inherited pnlGrid: TPanel
                Width = 317
                Height = 327
                ExplicitWidth = 317
                ExplicitHeight = 364
                inherited DbGridEh1: TDBGridEh
                  Width = 315
                  Height = 304
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
                  Top = 305
                  Width = 315
                  ExplicitTop = 342
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
                Height = 327
                ExplicitHeight = 364
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
                Top = 381
                Width = 327
                ExplicitTop = 418
                ExplicitWidth = 327
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
          object pnlProperties: TPanel
            Left = 329
            Top = 0
            Width = 709
            Height = 401
            Align = alClient
            Caption = 'pnlProperties'
            TabOrder = 1
            ExplicitWidth = 711
            ExplicitHeight = 438
            inline frmpcProperties: TFrMyPanelCaption
              Left = 1
              Top = 1
              Width = 707
              Height = 18
              Align = alTop
              TabOrder = 0
              ExplicitLeft = 1
              ExplicitTop = 1
              ExplicitWidth = 709
              inherited bvl1: TBevel
                Width = 707
              end
            end
            inline FrgProperties: TFrDBGridEh
              Left = 1
              Top = 19
              Width = 707
              Height = 381
              Align = alClient
              TabOrder = 1
              ExplicitLeft = 1
              ExplicitTop = 19
              ExplicitWidth = 709
              ExplicitHeight = 418
              inherited pnlGrid: TPanel
                Width = 697
                Height = 327
                ExplicitWidth = 699
                ExplicitHeight = 364
                inherited DbGridEh1: TDBGridEh
                  Width = 695
                  Height = 304
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
                  Top = 305
                  Width = 695
                  ExplicitTop = 342
                  ExplicitWidth = 697
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
                Height = 327
                ExplicitHeight = 364
              end
              inherited pnlTop: TPanel
                Width = 707
                ExplicitWidth = 709
              end
              inherited pnlContainer: TPanel
                Width = 707
                ExplicitWidth = 709
              end
              inherited pnlBottom: TPanel
                Top = 381
                Width = 707
                ExplicitTop = 418
                ExplicitWidth = 709
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
        object tsDays: TTabSheet
          Caption = #1058#1072#1081#1084#1083#1072#1081#1085
          ImageIndex = 1
          inline FrgDays: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 1038
            Height = 401
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 248
            ExplicitHeight = 438
            inherited pnlGrid: TPanel
              Width = 1028
              Height = 347
              ExplicitWidth = 545
              ExplicitHeight = 182
              inherited DbGridEh1: TDBGridEh
                Width = 1028
                Height = 361
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
                Top = 362
                Width = 1028
                ExplicitTop = 160
                ExplicitWidth = 543
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
              Height = 347
              ExplicitHeight = 182
            end
            inherited pnlTop: TPanel
              Width = 1038
              ExplicitWidth = 555
            end
            inherited pnlContainer: TPanel
              Width = 1038
              ExplicitWidth = 555
            end
            inherited pnlBottom: TPanel
              Top = 401
              Width = 1038
              ExplicitTop = 236
              ExplicitWidth = 555
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
      Top = 475
      Width = 1046
      ExplicitTop = 37
      ExplicitWidth = 256
      inherited bvlFrmBtnsTl: TBevel
        Width = 1044
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 1044
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 1044
        ExplicitWidth = 254
        inherited pnlFrmBtnsMain: TPanel
          Left = 945
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 717
          ExplicitLeft = -73
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 846
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 577
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 519
    Width = 1056
    inherited lblStatusBarR: TLabel
      Left = 983
      Height = 14
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 264
    Top = 520
  end
end
