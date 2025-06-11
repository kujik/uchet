inherited FrmAWUsersAndRoles: TFrmAWUsersAndRoles
  Caption = 'FrmAWUsersAndRoles'
  ClientHeight = 738
  ClientWidth = 1196
  ExplicitWidth = 1212
  ExplicitHeight = 776
  PixelsPerInch = 96
  TextHeight = 13
  inherited PMDIMain: TPanel
    Width = 1196
    Height = 722
    ExplicitWidth = 1196
    ExplicitHeight = 722
    inherited PMDIClient: TPanel
      Width = 1186
      Height = 673
      ExplicitWidth = 1186
      ExplicitHeight = 673
      object PageControl1: TPageControl
        Left = 0
        Top = 0
        Width = 1186
        Height = 673
        ActivePage = TsRoles
        Align = alClient
        TabOrder = 0
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
            inherited PGrid: TPanel
              Width = 290
              Height = 591
              ExplicitWidth = 290
              ExplicitHeight = 591
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
                  ExplicitWidth = 46
                  inherited PRowDetailPanel: TPanel
                    Width = 44
                    ExplicitWidth = 44
                  end
                end
              end
              inherited PStatus: TPanel
                Top = 569
                Width = 288
                ExplicitTop = 569
                ExplicitWidth = 288
              end
            end
            inherited PLeft: TPanel
              Height = 591
              ExplicitHeight = 591
            end
            inherited PTop: TPanel
              Width = 300
              ExplicitWidth = 300
            end
            inherited PContainer: TPanel
              Width = 300
              ExplicitWidth = 300
            end
            inherited PBottom: TPanel
              Top = 645
              Width = 300
              ExplicitTop = 645
              ExplicitWidth = 300
            end
            inherited MemTableEh1: TMemTableEh
              AfterScroll = FrgRolesMemTableEh1AfterScroll
            end
            inherited PrintDBGridEh1: TPrintDBGridEh
              BeforeGridText_Data = {
                7B5C727466315C616E73695C616E7369637067313235315C64656666305C6465
                666C616E67313034397B5C666F6E7474626C7B5C66305C666E696C5C66636861
                72736574323034205461686F6D613B7D7B5C66315C666E696C5C666368617273
                657430205461686F6D613B7D7D0D0A5C766965776B696E64345C7563315C7061
                72645C66305C667331365C2763665C2766305C2765655C2765355C2765615C27
                66323A20255B50726F656B745D5C7061720D0A5C2763665C2765355C2766305C
                2765385C2765655C276534205C276631205C6C616E67313033335C6631202025
                5B4474315D205C6C616E67313034395C66305C2765665C2765655C6C616E6731
                3033335C66312020255B4474325D5C6C616E67313034395C66305C7061720D0A
                5C7061720D0A7D0D0A00}
            end
          end
          object Panel1: TPanel
            Left = 300
            Top = 0
            Width = 878
            Height = 645
            Align = alClient
            Caption = 'Panel1'
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
              inherited PGrid: TPanel
                Left = 18
                Width = 858
                Height = 589
                ExplicitLeft = 18
                ExplicitWidth = 858
                ExplicitHeight = 589
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
                    ExplicitWidth = 46
                    inherited PRowDetailPanel: TPanel
                      Width = 44
                      ExplicitWidth = 44
                    end
                  end
                end
                inherited PStatus: TPanel
                  Top = 567
                  Width = 856
                  ExplicitTop = 567
                  ExplicitWidth = 856
                end
              end
              inherited PLeft: TPanel
                Left = 8
                Height = 589
                ExplicitLeft = 8
                ExplicitHeight = 589
              end
              inherited PTop: TPanel
                Left = 8
                Width = 868
                ExplicitLeft = 8
                ExplicitWidth = 868
              end
              inherited PContainer: TPanel
                Left = 8
                Width = 868
                ExplicitLeft = 8
                ExplicitWidth = 868
              end
              inherited PBottom: TPanel
                Left = 8
                Top = 643
                Width = 868
                ExplicitLeft = 8
                ExplicitTop = 643
                ExplicitWidth = 868
              end
              inherited PrintDBGridEh1: TPrintDBGridEh
                BeforeGridText_Data = {
                  7B5C727466315C616E73695C616E7369637067313235315C64656666305C6465
                  666C616E67313034397B5C666F6E7474626C7B5C66305C666E696C5C66636861
                  72736574323034205461686F6D613B7D7B5C66315C666E696C5C666368617273
                  657430205461686F6D613B7D7D0D0A5C766965776B696E64345C7563315C7061
                  72645C66305C667331365C2763665C2766305C2765655C2765355C2765615C27
                  66323A20255B50726F656B745D5C7061720D0A5C2763665C2765355C2766305C
                  2765385C2765655C276534205C276631205C6C616E67313033335C6631202025
                  5B4474315D205C6C616E67313034395C66305C2765665C2765655C6C616E6731
                  3033335C66312020255B4474325D5C6C616E67313034395C66305C7061720D0A
                  5C7061720D0A7D0D0A00}
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
            inherited PGrid: TPanel
              Width = 726
              Height = 591
              ExplicitWidth = 734
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
                  ExplicitWidth = 46
                  inherited PRowDetailPanel: TPanel
                    Width = 44
                    ExplicitWidth = 44
                  end
                end
              end
              inherited PStatus: TPanel
                Top = 569
                Width = 724
                ExplicitTop = 569
                ExplicitWidth = 732
              end
            end
            inherited PLeft: TPanel
              Height = 591
              ExplicitHeight = 591
            end
            inherited PTop: TPanel
              Width = 736
              ExplicitWidth = 744
            end
            inherited PContainer: TPanel
              Width = 736
              ExplicitWidth = 744
            end
            inherited PBottom: TPanel
              Top = 645
              Width = 736
              ExplicitTop = 645
              ExplicitWidth = 744
            end
            inherited MemTableEh1: TMemTableEh
              AfterScroll = FrgUsersMemTableEh1AfterScroll
            end
            inherited PrintDBGridEh1: TPrintDBGridEh
              BeforeGridText_Data = {
                7B5C727466315C616E73695C616E7369637067313235315C64656666305C6465
                666C616E67313034397B5C666F6E7474626C7B5C66305C666E696C5C66636861
                72736574323034205461686F6D613B7D7B5C66315C666E696C5C666368617273
                657430205461686F6D613B7D7D0D0A5C766965776B696E64345C7563315C7061
                72645C66305C667331365C2763665C2766305C2765655C2765355C2765615C27
                66323A20255B50726F656B745D5C7061720D0A5C2763665C2765355C2766305C
                2765385C2765655C276534205C276631205C6C616E67313033335C6631202025
                5B4474315D205C6C616E67313034395C66305C2765665C2765655C6C616E6731
                3033335C66312020255B4474325D5C6C616E67313034395C66305C7061720D0A
                5C7061720D0A7D0D0A00}
            end
          end
          object PRight: TPanel
            Left = 744
            Top = 0
            Width = 434
            Height = 645
            Align = alRight
            Caption = 'PRight'
            TabOrder = 1
            object PUserData: TPanel
              Left = 1
              Top = 42
              Width = 432
              Height = 287
              Align = alTop
              Caption = 'PLTop'
              TabOrder = 0
              object E_Name: TDBEditEh
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
                Text = 'E_Name'
                Visible = True
              end
              object E_Login: TDBEditEh
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
              object E_Pwd: TDBEditEh
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
              object E_Pwd2: TDBEditEh
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
              object Cb_Job: TDBComboBoxEh
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
              object E_EMail: TDBEditEh
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
                Text = 'E_Name'
                Visible = True
              end
              object Chb_EMailAuto: TDBCheckBoxEh
                Left = 327
                Top = 186
                Width = 98
                Height = 17
                Caption = #1040#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082#1080
                DynProps = <>
                TabOrder = 6
              end
              object Chb_AutoLogin: TDBCheckBoxEh
                Left = 136
                Top = 233
                Width = 266
                Height = 17
                Caption = #1040#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082#1080#1081' '#1074#1093#1086#1076' '#1085#1072' '#1089#1074#1086#1077#1084' '#1082#1086#1084#1087#1100#1102#1090#1077#1088#1077
                DynProps = <>
                TabOrder = 7
              end
              object Chb_Active: TDBCheckBoxEh
                Left = 133
                Top = 256
                Width = 69
                Height = 17
                Caption = #1056#1072#1073#1086#1090#1072#1077#1090
                DynProps = <>
                TabOrder = 8
              end
              object E_JobComm: TDBEditEh
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
                Text = 'E_JobComm'
                Visible = True
              end
              object Ne_Idle: TDBNumberEditEh
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
              object Chb_ChPwd: TDBCheckBoxEh
                Left = 335
                Top = 80
                Width = 69
                Height = 17
                Caption = #1057#1084#1077#1085#1080#1090#1100
                DynProps = <>
                TabOrder = 11
              end
            end
            object PRTop: TPanel
              Left = 1
              Top = 1
              Width = 432
              Height = 41
              Align = alTop
              Caption = 'PRTop'
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
              inherited PGrid: TPanel
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
                    ExplicitWidth = 46
                    inherited PRowDetailPanel: TPanel
                      Width = 44
                      ExplicitWidth = 44
                    end
                  end
                end
                inherited PStatus: TPanel
                  Top = 239
                  Width = 420
                  ExplicitTop = 239
                  ExplicitWidth = 420
                end
              end
              inherited PLeft: TPanel
                Height = 261
                ExplicitHeight = 261
              end
              inherited PTop: TPanel
                Width = 432
                ExplicitWidth = 432
              end
              inherited PContainer: TPanel
                Width = 432
                ExplicitWidth = 432
              end
              inherited PBottom: TPanel
                Top = 315
                Width = 432
                ExplicitTop = 315
                ExplicitWidth = 432
              end
              inherited PrintDBGridEh1: TPrintDBGridEh
                BeforeGridText_Data = {
                  7B5C727466315C616E73695C616E7369637067313235315C64656666305C6465
                  666C616E67313034397B5C666F6E7474626C7B5C66305C666E696C5C66636861
                  72736574323034205461686F6D613B7D7B5C66315C666E696C5C666368617273
                  657430205461686F6D613B7D7D0D0A5C766965776B696E64345C7563315C7061
                  72645C66305C667331365C2763665C2766305C2765655C2765355C2765615C27
                  66323A20255B50726F656B745D5C7061720D0A5C2763665C2765355C2766305C
                  2765385C2765655C276534205C276631205C6C616E67313033335C6631202025
                  5B4474315D205C6C616E67313034395C66305C2765665C2765655C6C616E6731
                  3033335C66312020255B4474325D5C6C616E67313034395C66305C7061720D0A
                  5C7061720D0A7D0D0A00}
              end
            end
          end
        end
      end
    end
    inherited PDlgPanel: TPanel
      Top = 678
      Width = 1186
      ExplicitTop = 678
      ExplicitWidth = 1186
      inherited BvDlg: TBevel
        Width = 1184
        ExplicitWidth = 1184
      end
      inherited BvDlgBottom: TBevel
        Width = 1184
        ExplicitWidth = 1184
      end
      inherited PDlgMain: TPanel
        Width = 1184
        ExplicitWidth = 1184
        inherited PDlgBtnForm: TPanel
          Left = 1085
          ExplicitLeft = 1085
        end
        inherited PDlgChb: TPanel
          Left = 857
          ExplicitLeft = 857
        end
        inherited PDlgBtnR: TPanel
          Left = 986
          ExplicitLeft = 986
        end
        inherited PDlgCenter: TPanel
          Width = 717
          ExplicitWidth = 717
        end
      end
    end
  end
  inherited PStatusBar: TPanel
    Top = 722
    Width = 1196
    ExplicitTop = 722
    ExplicitWidth = 1196
    inherited LbStatusBarRight: TLabel
      Left = 1104
      Height = 13
      ExplicitLeft = 1104
    end
    inherited LbStatusBarLeft: TLabel
      Height = 13
    end
  end
  inherited Timer_AfterStart: TTimer
    Left = 256
    Top = 688
  end
end
