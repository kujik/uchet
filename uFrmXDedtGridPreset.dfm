inherited FrmXDedtGridPreset: TFrmXDedtGridPreset
  Caption = 'FrmXDedtGridPreset'
  ClientHeight = 225
  ClientWidth = 592
  ExplicitWidth = 608
  ExplicitHeight = 264
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 592
    Height = 209
    ExplicitWidth = 588
    ExplicitHeight = 208
    inherited pnlFrmClient: TPanel
      Width = 582
      Height = 160
      ExplicitWidth = 578
      ExplicitHeight = 159
      object lblName: TLabel
        Left = 9
        Top = 36
        Width = 67
        Height = 13
        Caption = #1048#1084#1103' '#1087#1088#1077#1089#1077#1090#1072':'
      end
      object pnlCaption: TPanel
        Left = 0
        Top = 0
        Width = 582
        Height = 25
        Align = alTop
        Caption = 'pnlCaption'
        TabOrder = 0
        ExplicitWidth = 578
      end
      object edtName: TEdit
        Left = 9
        Top = 54
        Width = 569
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
      end
      object chbIncludeSort: TCheckBox
        Left = 9
        Top = 85
        Width = 300
        Height = 17
        Caption = #1042#1082#1083#1102#1095#1080#1090#1100' '#1089#1086#1088#1090#1080#1088#1086#1074#1082#1091
        Checked = True
        State = cbChecked
        TabOrder = 2
      end
      object chbIncludeColumnFilters: TCheckBox
        Left = 9
        Top = 108
        Width = 300
        Height = 17
        Caption = #1042#1082#1083#1102#1095#1080#1090#1100' '#1092#1080#1083#1100#1090#1088#1099' '#1089#1090#1086#1083#1073#1094#1086#1074
        Checked = True
        State = cbChecked
        TabOrder = 3
      end
      object chbIncludeGridFilter: TCheckBox
        Left = 9
        Top = 131
        Width = 300
        Height = 17
        Caption = #1042#1082#1083#1102#1095#1080#1090#1100' '#1075#1088#1080#1076#1092#1080#1083#1100#1090#1088
        Checked = True
        State = cbChecked
        TabOrder = 4
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 165
      Width = 582
      ExplicitTop = 164
      ExplicitWidth = 578
      inherited bvlFrmBtnsTl: TBevel
        Width = 580
        ExplicitWidth = 580
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 580
        ExplicitWidth = 580
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 580
        ExplicitWidth = 576
        inherited pnlFrmBtnsMain: TPanel
          Left = 481
          ExplicitLeft = 477
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = 253
          ExplicitLeft = 249
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 382
          ExplicitLeft = 378
        end
        inherited pnlFrmBtnsC: TPanel
          Width = 113
          ExplicitWidth = 109
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 209
    Width = 592
    ExplicitTop = 208
    ExplicitWidth = 588
    inherited lblStatusBarR: TLabel
      Left = 519
      ExplicitLeft = 519
    end
  end
  inherited tmrAfterCreate: TTimer
    Top = 172
  end
end
