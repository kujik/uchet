inherited FrmXWViewFile: TFrmXWViewFile
  Caption = 'FrmXWViewFile'
  ClientHeight = 480
  ClientWidth = 700
  ExplicitWidth = 716
  ExplicitHeight = 519
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 700
    Height = 464
    ExplicitWidth = 700
    ExplicitHeight = 464
    inherited pnlFrmClient: TPanel
      Width = 690
      Height = 415
      ExplicitWidth = 690
      ExplicitHeight = 415
      object memMain: TMemo
        Left = 0
        Top = 29
        Width = 690
        Height = 386
        Align = alClient
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 1
        WordWrap = False
      end
      object pnlTop: TPanel
        Left = 0
        Top = 0
        Width = 690
        Height = 29
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object chkEditable: TCheckBox
          Left = 8
          Top = 6
          Width = 200
          Height = 17
          Caption = #1056#1072#1079#1088#1077#1096#1080#1090#1100' '#1088#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077
          TabOrder = 0
          OnClick = chkEditableClick
        end
        object btnSave: TButton
          Left = 220
          Top = 2
          Width = 100
          Height = 23
          Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
          TabOrder = 1
          Visible = False
          OnClick = btnSaveClick
        end
      end
    end
  end
end
