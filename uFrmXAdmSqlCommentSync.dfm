inherited FrmXAdmSqlCommentSync: TFrmXAdmSqlCommentSync
  Caption = 'FrmXAdmSqlCommentSync'
  ClientHeight = 480
  ClientWidth = 900
  ExplicitWidth = 916
  ExplicitHeight = 519
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 900
    Height = 464
    ExplicitWidth = 900
    ExplicitHeight = 464
    inherited pnlFrmClient: TPanel
      Width = 890
      Height = 415
      ExplicitWidth = 890
      ExplicitHeight = 415
      inherited pnlTop: TPanel
        Width = 890
        Height = 40
        ExplicitWidth = 890
        ExplicitHeight = 40
        object bt_SelectFile: TButton
          Left = 8
          Top = 8
          Width = 140
          Height = 25
          Caption = #1042#1099#1073#1088#1072#1090#1100' '#1092#1072#1081#1083'...'
          TabOrder = 0
          OnClick = bt_SelectFileClick
        end
        object edt_FileName: TEdit
          Left = 156
          Top = 10
          Width = 430
          Height = 21
          ReadOnly = True
          TabOrder = 1
        end
        object bt_Parse: TButton
          Left = 596
          Top = 8
          Width = 110
          Height = 25
          Caption = #1056#1072#1079#1086#1073#1088#1072#1090#1100
          TabOrder = 2
          OnClick = bt_ParseClick
        end
        object bt_Apply: TButton
          Left = 716
          Top = 8
          Width = 166
          Height = 25
          Caption = #1059#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1082#1086#1084#1084#1077#1085#1090#1072#1088#1080#1080' '#1074' '#1041#1044
          TabOrder = 3
          OnClick = bt_ApplyClick
        end
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 'SQL '#1092#1072#1081#1083#1099' (*.sql)|*.sql|'#1042#1089#1077' '#1092#1072#1081#1083#1099' (*.*)|*.*'
    Left = 40
    Top = 424
  end
end
