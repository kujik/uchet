inherited FrmAWUsersAndRoles: TFrmAWUsersAndRoles
  Caption = 'FrmAWUsersAndRoles'
  ClientHeight = 738
  ClientWidth = 1196
  ExplicitWidth = 1212
  ExplicitHeight = 777
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 1196
    Height = 722
    ExplicitWidth = 1196
    ExplicitHeight = 722
    inherited pnlFrmClient: TPanel
      Width = 1186
      Height = 673
      ExplicitWidth = 1182
      ExplicitHeight = 672
      object PageControl1: TPageControl
        Left = 0
        Top = 0
        Width = 1186
        Height = 673
        ActivePage = TsUsers
        Align = alClient
        TabOrder = 0
        ExplicitWidth = 1182
        ExplicitHeight = 672
        object TsRoles: TTabSheet
          Caption = #1056#1086#1083#1080
          inline FrgRoles: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 300
            Height = 645
            Align = alLeft
            TabOrder = 0
            ExplicitWidth = 300
            ExplicitHeight = 645
            inherited pnlGrid: TPanel
              Width = 290
              Height = 591
              ExplicitWidth = 290
              ExplicitHeight = 590
              inherited DbGridEh1: TDBGridEh
                Width = 288
                Height = 568
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
                Top = 569
                Width = 288
                ExplicitTop = 568
                ExplicitWidth = 288
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
              Height = 591
              ExplicitHeight = 590
            end
            inherited pnlTop: TPanel
              Width = 300
              ExplicitWidth = 300
            end
            inherited pnlContainer: TPanel
              Width = 300
              ExplicitWidth = 300
            end
            inherited pnlBottom: TPanel
              Top = 645
              Width = 300
              ExplicitTop = 644
              ExplicitWidth = 300
            end
            inherited MemTableEh1: TMemTableEh
              AfterScroll = FrgRolesMemTableEh1AfterScroll
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
          object pnl1: TPanel
            Left = 300
            Top = 0
            Width = 878
            Height = 645
            Align = alClient
            Caption = 'pnl1'
            TabOrder = 1
            inline FrgRights: TFrDBGridEh
              Left = 1
              Top = 1
              Width = 876
              Height = 643
              Align = alClient
              Padding.Left = 8
              TabOrder = 0
              ExplicitLeft = 1
              ExplicitTop = 1
              ExplicitWidth = 876
              ExplicitHeight = 643
              inherited pnlGrid: TPanel
                Left = 18
                Width = 858
                Height = 589
                ExplicitLeft = 18
                ExplicitWidth = 854
                ExplicitHeight = 588
                inherited DbGridEh1: TDBGridEh
                  Width = 856
                  Height = 566
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
                  Top = 567
                  Width = 856
                  ExplicitTop = 566
                  ExplicitWidth = 852
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
                Left = 8
                Height = 589
                ExplicitLeft = 8
                ExplicitHeight = 588
              end
              inherited pnlTop: TPanel
                Left = 8
                Width = 868
                ExplicitLeft = 8
                ExplicitWidth = 864
              end
              inherited pnlContainer: TPanel
                Left = 8
                Width = 868
                ExplicitLeft = 8
                ExplicitWidth = 864
              end
              inherited pnlBottom: TPanel
                Left = 8
                Top = 643
                Width = 868
                ExplicitLeft = 8
                ExplicitTop = 642
                ExplicitWidth = 864
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
        object TsUsers: TTabSheet
          Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1080
          ImageIndex = 1
          inline FrgUsers: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 744
            Height = 645
            Align = alClient
            Padding.Right = 8
            TabOrder = 0
            ExplicitWidth = 744
            ExplicitHeight = 645
            inherited pnlGrid: TPanel
              Width = 726
              Height = 591
              ExplicitWidth = 726
              ExplicitHeight = 591
              inherited DbGridEh1: TDBGridEh
                Width = 724
                Height = 568
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
                Top = 569
                Width = 724
                ExplicitTop = 569
                ExplicitWidth = 724
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
              Height = 591
              ExplicitHeight = 591
            end
            inherited pnlTop: TPanel
              Width = 736
              ExplicitWidth = 736
            end
            inherited pnlContainer: TPanel
              Width = 736
              ExplicitWidth = 736
            end
            inherited pnlBottom: TPanel
              Top = 645
              Width = 736
              ExplicitTop = 645
              ExplicitWidth = 736
            end
            inherited MemTableEh1: TMemTableEh
              AfterScroll = FrgUsersMemTableEh1AfterScroll
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
          object pnlRight: TPanel
            Left = 744
            Top = 0
            Width = 434
            Height = 645
            Align = alRight
            Caption = 'pnlRight'
            TabOrder = 1
            object pnlUserData: TPanel
              Left = 1
              Top = 42
              Width = 432
              Height = 287
              Align = alTop
              Caption = 'PLTop'
              TabOrder = 0
              object edtname: TDBEditEh
                Left = 136
                Top = 24
                Width = 289
                Height = 21
                ControlLabel.Width = 93
                ControlLabel.Height = 13
                ControlLabel.Caption = #1048#1084#1103' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
                ControlLabel.Visible = True
                ControlLabelLocation.Position = lpLeftCenterEh
                DynProps = <>
                EditButtons = <>
                TabOrder = 0
                Text = 'edtname'
                Visible = True
              end
              object edtLogin: TDBEditEh
                Left = 136
                Top = 51
                Width = 185
                Height = 21
                ControlLabel.Width = 30
                ControlLabel.Height = 13
                ControlLabel.Caption = #1051#1086#1075#1080#1085
                ControlLabel.Visible = True
                ControlLabelLocation.Position = lpLeftCenterEh
                DynProps = <>
                EditButtons = <>
                TabOrder = 1
                Text = 'DBEditEh1'
                Visible = True
              end
              object edtPwd: TDBEditEh
                Left = 136
                Top = 78
                Width = 185
                Height = 21
                ControlLabel.Width = 37
                ControlLabel.Height = 13
                ControlLabel.Caption = #1055#1072#1088#1086#1083#1100
                ControlLabel.Visible = True
                ControlLabelLocation.Position = lpLeftCenterEh
                DynProps = <>
                EditButtons = <>
                PasswordChar = '*'
                TabOrder = 2
                Text = 'DBEditEh1'
                Visible = True
              end
              object edtPwd2: TDBEditEh
                Left = 136
                Top = 105
                Width = 185
                Height = 21
                ControlLabel.Width = 122
                ControlLabel.Height = 13
                ControlLabel.Caption = #1055#1086#1076#1090#1074#1077#1088#1078#1076#1077#1085#1080#1077' '#1087#1072#1088#1086#1083#1103
                ControlLabel.Visible = True
                ControlLabelLocation.Position = lpLeftCenterEh
                DynProps = <>
                EditButtons = <>
                PasswordChar = '*'
                TabOrder = 3
                Text = 'DBEditEh1'
                Visible = True
              end
              object cmbJob: TDBComboBoxEh
                Left = 136
                Top = 132
                Width = 288
                Height = 21
                ControlLabel.Width = 57
                ControlLabel.Height = 13
                ControlLabel.Caption = #1044#1086#1083#1078#1085#1086#1089#1090#1100
                ControlLabel.Visible = True
                ControlLabelLocation.Position = lpLeftCenterEh
                DynProps = <>
                EditButtons = <>
                LimitTextToListValues = True
                TabOrder = 4
                Visible = True
              end
              object edtEMail: TDBEditEh
                Left = 136
                Top = 183
                Width = 185
                Height = 21
                ControlLabel.Width = 100
                ControlLabel.Height = 13
                ControlLabel.Caption = #1069#1083#1077#1082#1090#1088#1086#1085#1085#1072#1103' '#1087#1086#1095#1090#1072
                ControlLabel.Visible = True
                ControlLabelLocation.Position = lpLeftCenterEh
                DynProps = <>
                EditButtons = <>
                TabOrder = 5
                Text = 'edtname'
                Visible = True
              end
              object chbEMailAuto: TDBCheckBoxEh
                Left = 327
                Top = 186
                Width = 98
                Height = 17
                Caption = #1040#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082#1080
                DynProps = <>
                TabOrder = 6
              end
              object chbAutoLogin: TDBCheckBoxEh
                Left = 136
                Top = 233
                Width = 266
                Height = 17
                Caption = #1040#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082#1080#1081' '#1074#1093#1086#1076' '#1085#1072' '#1089#1074#1086#1077#1084' '#1082#1086#1084#1087#1100#1102#1090#1077#1088#1077
                DynProps = <>
                TabOrder = 7
              end
              object chbActive: TDBCheckBoxEh
                Left = 133
                Top = 256
                Width = 69
                Height = 17
                Caption = #1056#1072#1073#1086#1090#1072#1077#1090
                DynProps = <>
                TabOrder = 8
              end
              object edtJobComm: TDBEditEh
                Left = 135
                Top = 156
                Width = 289
                Height = 21
                ControlLabel.Width = 61
                ControlLabel.Height = 13
                ControlLabel.Caption = #1055#1088#1080#1084#1077#1095#1072#1085#1080#1077
                ControlLabel.Visible = True
                ControlLabelLocation.Position = lpLeftCenterEh
                DynProps = <>
                EditButtons = <>
                TabOrder = 9
                Text = 'edtJobComm'
                Visible = True
              end
              object nedtIdle: TDBNumberEditEh
                Left = 136
                Top = 210
                Width = 81
                Height = 21
                ControlLabel.Width = 74
                ControlLabel.Height = 13
                ControlLabel.Caption = #1042#1088#1077#1084#1103' '#1087#1088#1086#1089#1090#1086#1103
                ControlLabel.Visible = True
                ControlLabelLocation.Position = lpLeftCenterEh
                DynProps = <>
                EditButtons = <>
                TabOrder = 10
                Visible = True
              end
              object chbChPwd: TDBCheckBoxEh
                Left = 335
                Top = 80
                Width = 69
                Height = 17
                Caption = #1057#1084#1077#1085#1080#1090#1100
                DynProps = <>
                TabOrder = 11
              end
            end
            object pnlRTop: TPanel
              Left = 1
              Top = 1
              Width = 432
              Height = 41
              Align = alTop
              Caption = 'pnlRTop'
              TabOrder = 1
            end
            inline FrgUserRoles: TFrDBGridEh
              Left = 1
              Top = 329
              Width = 432
              Height = 315
              Align = alClient
              TabOrder = 2
              ExplicitLeft = 1
              ExplicitTop = 329
              ExplicitWidth = 432
              ExplicitHeight = 315
              inherited pnlGrid: TPanel
                Width = 422
                Height = 261
                ExplicitWidth = 422
                ExplicitHeight = 261
                inherited DbGridEh1: TDBGridEh
                  Width = 420
                  Height = 238
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
                  Top = 239
                  Width = 420
                  ExplicitTop = 239
                  ExplicitWidth = 420
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
                Height = 261
                ExplicitHeight = 261
              end
              inherited pnlTop: TPanel
                Width = 432
                ExplicitWidth = 432
              end
              inherited pnlContainer: TPanel
                Width = 432
                ExplicitWidth = 432
              end
              inherited pnlBottom: TPanel
                Top = 315
                Width = 432
                ExplicitTop = 315
                ExplicitWidth = 432
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
    end
    inherited pnlFrmBtns: TPanel
      Top = 678
      Width = 1186
      ExplicitTop = 677
      ExplicitWidth = 1182
      inherited bvlFrmBtnsTl: TBevel
        Width = 1184
        ExplicitWidth = 1184
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 1184
        ExplicitWidth = 1184
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 1184
        ExplicitWidth = 1180
        inherited pnlFrmBtnsMain: TPanel
          Left = 1085
          ExplicitLeft = 1081
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 857
          ExplicitLeft = 853
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 986
          ExplicitLeft = 982
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 717
          ExplicitWidth = 713
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 722
    Width = 1196
    ExplicitTop = 721
    ExplicitWidth = 1192
    inherited lblStatusBarR: TLabel
      Left = 1123
      ExplicitLeft = 1123
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 256
    Top = 688
  end
end
