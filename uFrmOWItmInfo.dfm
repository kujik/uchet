inherited FrmOWItmInfo: TFrmOWItmInfo
  Caption = 'FrmOWItmInfo'
  ClientHeight = 460
  ClientWidth = 650
  ExplicitWidth = 662
  ExplicitHeight = 498
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 650
    Height = 444
    ExplicitWidth = 650
    ExplicitHeight = 444
    inherited pnlFrmClient: TPanel
      Width = 640
      Height = 395
      ExplicitWidth = 636
      ExplicitHeight = 394
      object pnlTop: TPanel
        Left = 0
        Top = 0
        Width = 640
        Height = 89
        Align = alTop
        TabOrder = 0
        ExplicitWidth = 636
        DesignSize = (
          640
          89)
        object lblArtikul: TLabel
          Left = 12
          Top = 8
          Width = 40
          Height = 13
          Caption = 'lblArtikul'
        end
        object lblNomencl: TLabel
          Left = 12
          Top = 27
          Width = 50
          Height = 13
          Caption = 'lblNomencl'
        end
        object lblFromCAD: TLabel
          Left = 12
          Top = 46
          Width = 55
          Height = 13
          Caption = 'lblFromCAD'
        end
        object lblToDel: TLabel
          Left = 12
          Top = 65
          Width = 37
          Height = 13
          Caption = 'lblToDel'
        end
        object btnGo: TSpeedButton
          Left = 580
          Top = 8
          Width = 32
          Height = 32
          Anchors = [akTop, akRight]
          OnClick = btnGoClick
          ExplicitLeft = 584
        end
      end
      object pgcMain: TPageControl
        Left = 0
        Top = 89
        Width = 640
        Height = 306
        ActivePage = tsFromCAD
        Align = alClient
        TabOrder = 1
        ExplicitWidth = 636
        ExplicitHeight = 305
        object tsArtikul: TTabSheet
          Caption = #1040#1088#1090#1080#1082#1091#1083#1099
          inline FrgArtikul: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 632
            Height = 278
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 628
            ExplicitHeight = 277
            inherited pnlGrid: TPanel
              Width = 622
              Height = 224
              inherited DbGridEh1: TDBGridEh
                inherited RowDetailData: TRowDetailPanelControlEh
                  ExplicitLeft = 0
                  ExplicitTop = 0
                  ExplicitWidth = 0
                  ExplicitHeight = 0
                end
              end
              inherited pnlStatusBar: TPanel
                inherited lblStatusBarL: TLabel
                  Height = 13
                  ExplicitHeight = 13
                end
              end
            end
            inherited pnlLeft: TPanel
              Height = 224
            end
            inherited pnlTop: TPanel
              Width = 632
            end
            inherited pnlContainer: TPanel
              Width = 632
            end
            inherited pnlBottom: TPanel
              Top = 278
              Width = 632
            end
            inherited PrintDBGridEh1: TPrintDBGridEh
              BeforeGridText_Data = {
                7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
                7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
                305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
                666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
                6E657261746F722052696368656432302031302E302E32363130307D5C766965
                776B696E64345C756331200D0A5C706172645C66305C667331362027255B446F
                63756D656E745C66315C6C616E6731303333205D205C66305C6C616E67313034
                3920255B546F6461795D20255B557365724E616D655D5C66315C6C616E673130
                333320205C66305C6C616E67313034395C7061720D0A7D0D0A00}
            end
          end
        end
        object tsNomencl: TTabSheet
          Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1103
          ImageIndex = 2
          inline FrgNomencl: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 632
            Height = 278
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 628
            ExplicitHeight = 277
            inherited pnlGrid: TPanel
              Width = 622
              Height = 224
              inherited DbGridEh1: TDBGridEh
                inherited RowDetailData: TRowDetailPanelControlEh
                  ExplicitLeft = 0
                  ExplicitTop = 0
                  ExplicitWidth = 0
                  ExplicitHeight = 0
                end
              end
              inherited pnlStatusBar: TPanel
                inherited lblStatusBarL: TLabel
                  Height = 13
                  ExplicitHeight = 13
                end
              end
            end
            inherited pnlLeft: TPanel
              Height = 224
            end
            inherited pnlTop: TPanel
              Width = 632
            end
            inherited pnlContainer: TPanel
              Width = 632
            end
            inherited pnlBottom: TPanel
              Top = 278
              Width = 632
            end
            inherited PrintDBGridEh1: TPrintDBGridEh
              BeforeGridText_Data = {
                7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
                7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
                305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
                666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
                6E657261746F722052696368656432302031302E302E32363130307D5C766965
                776B696E64345C756331200D0A5C706172645C66305C667331362027255B446F
                63756D656E745C66315C6C616E6731303333205D205C66305C6C616E67313034
                3920255B546F6461795D20255B557365724E616D655D5C66315C6C616E673130
                333320205C66305C6C616E67313034395C7061720D0A7D0D0A00}
            end
          end
        end
        object tsFromCAD: TTabSheet
          Caption = #1053#1086#1084#1077#1085#1082#1083#1072#1090#1091#1088#1072' '#1080#1079' CAD'
          ImageIndex = 2
          inline FrgFromCAD: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 632
            Height = 278
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 628
            ExplicitHeight = 277
            inherited pnlGrid: TPanel
              Width = 622
              Height = 224
              ExplicitWidth = 618
              ExplicitHeight = 223
              inherited DbGridEh1: TDBGridEh
                Width = 620
                Height = 201
                inherited RowDetailData: TRowDetailPanelControlEh
                  ExplicitTop = 35
                end
              end
              inherited pnlStatusBar: TPanel
                Top = 202
                Width = 620
                ExplicitTop = 201
                ExplicitWidth = 616
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
              Height = 224
              ExplicitHeight = 223
            end
            inherited pnlTop: TPanel
              Width = 632
              ExplicitWidth = 628
            end
            inherited pnlContainer: TPanel
              Width = 632
              ExplicitWidth = 628
            end
            inherited pnlBottom: TPanel
              Top = 278
              Width = 632
              ExplicitTop = 277
              ExplicitWidth = 628
            end
            inherited PrintDBGridEh1: TPrintDBGridEh
              BeforeGridText_Data = {
                7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
                7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
                305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
                666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
                6E657261746F722052696368656432302031302E302E32363130307D5C766965
                776B696E64345C756331200D0A5C706172645C66305C667331362027255B446F
                63756D656E745C66315C6C616E6731303333205D205C66305C6C616E67313034
                3920255B546F6461795D20255B557365724E616D655D5C66315C6C616E673130
                333320205C66305C6C616E67313034395C7061720D0A7D0D0A00}
            end
          end
        end
        object tsToDel: TTabSheet
          Caption = #1053#1072' '#1091#1076#1072#1083#1077#1085#1080#1077
          ImageIndex = 3
          inline FrgToDel: TFrDBGridEh
            Left = 0
            Top = 0
            Width = 632
            Height = 278
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 628
            ExplicitHeight = 277
            inherited pnlGrid: TPanel
              Width = 622
              Height = 224
              inherited DbGridEh1: TDBGridEh
                inherited RowDetailData: TRowDetailPanelControlEh
                  ExplicitLeft = 0
                  ExplicitTop = 0
                  ExplicitWidth = 0
                  ExplicitHeight = 0
                end
              end
              inherited pnlStatusBar: TPanel
                inherited lblStatusBarL: TLabel
                  Height = 13
                  ExplicitHeight = 13
                end
              end
            end
            inherited pnlLeft: TPanel
              Height = 224
            end
            inherited pnlTop: TPanel
              Width = 632
            end
            inherited pnlContainer: TPanel
              Width = 632
            end
            inherited pnlBottom: TPanel
              Top = 278
              Width = 632
            end
            inherited PrintDBGridEh1: TPrintDBGridEh
              BeforeGridText_Data = {
                7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
                7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
                305C666E696C5C6663686172736574323034205461686F6D613B7D7B5C66315C
                666E696C5C666368617273657430205461686F6D613B7D7D0D0A7B5C2A5C6765
                6E657261746F722052696368656432302031302E302E32363130307D5C766965
                776B696E64345C756331200D0A5C706172645C66305C667331362027255B446F
                63756D656E745C66315C6C616E6731303333205D205C66305C6C616E67313034
                3920255B546F6461795D20255B557365724E616D655D5C66315C6C616E673130
                333320205C66305C6C616E67313034395C7061720D0A7D0D0A00}
            end
          end
        end
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 400
      Width = 640
      inherited bvlFrmBtnsTl: TBevel
        Width = 638
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 638
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 638
        inherited pnlFrmBtnsMain: TPanel
          Left = 311
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 410
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 539
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 171
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 444
    Width = 650
    ExplicitTop = 443
    ExplicitWidth = 646
    inherited lblStatusBarR: TLabel
      Left = 577
      Height = 14
      ExplicitLeft = 577
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 4
    Top = 132
  end
end
