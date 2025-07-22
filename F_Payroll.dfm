inherited Form_Payroll: TForm_Payroll
  Caption = #1047#1072#1088#1087#1083#1072#1090#1085#1072#1103' '#1074#1077#1076#1086#1084#1086#1089#1090#1100
  ClientHeight = 383
  ClientWidth = 1284
  ExplicitWidth = 1296
  ExplicitHeight = 421
  TextHeight = 13
  inherited pnl_StatusBar: TPanel
    Top = 364
    Width = 1284
    ExplicitTop = 363
    ExplicitWidth = 1280
    inherited lbl_StatusBar_Right: TLabel
      Left = 1197
      Height = 17
      ExplicitLeft = 1197
    end
    inherited lbl_StatusBar_Left: TLabel
      Height = 17
    end
  end
  object pnl_Top: TPanel [1]
    Left = 0
    Top = 0
    Width = 1284
    Height = 37
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitWidth = 1280
    object pnl_Right: TPanel
      Left = 1221
      Top = 0
      Width = 63
      Height = 37
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      ExplicitLeft = 1217
    end
    object pnl_Left: TPanel
      Left = 0
      Top = 0
      Width = 557
      Height = 37
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 1
    end
    object pnl_Center: TPanel
      Left = 557
      Top = 0
      Width = 664
      Height = 37
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 2
      ExplicitWidth = 660
      object lbl_Caption1: TLabel
        Left = 6
        Top = 5
        Width = 58
        Height = 13
        Caption = 'lbl_Caption1'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object lbl_Info: TLabel
        Left = 6
        Top = 18
        Width = 89
        Height = 13
        Caption = #1058#1086#1083#1100#1082#1086' '#1087#1088#1086#1089#1084#1086#1090#1088
      end
    end
  end
  object DBGridEh1: TDBGridEh [2]
    Left = 0
    Top = 37
    Width = 1284
    Height = 327
    Align = alClient
    DataSource = DataSource1
    DynProps = <>
    Options = [dgEditing, dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
    OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDialogFind, dghExtendVertLines]
    RowDetailPanel.Height = 250
    TabOrder = 2
    OnKeyDown = DBGridEh1KeyDown
    Columns = <
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'pos'
        Footers = <>
        OnUpdateData = DBGridEh1Columns0UpdateData
      end>
    object RowDetailData: TRowDetailPanelControlEh
      object DBGridEh3: TDBGridEh
        Left = 208
        Top = 43
        Width = 537
        Height = 41
        DynProps = <>
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        Visible = False
        object RowDetailData: TRowDetailPanelControlEh
        end
      end
      object edt_PPComment: TDBEditEh
        Left = 299
        Top = 215
        Width = 494
        Height = 21
        ControlLabel.Width = 70
        ControlLabel.Height = 13
        ControlLabel.Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
        ControlLabel.Visible = True
        ControlLabelLocation.Position = lpLeftCenterEh
        DynProps = <>
        EditButtons = <>
        TabOrder = 1
        Text = 'edt_PPComment'
        Visible = False
      end
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 2
    Top = 570
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    AfterScroll = MemTableEh1AfterScroll
    Left = 821
    Top = 93
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Left = 864
    Top = 96
  end
  object Timer_AfterUpdate: TTimer
    Enabled = False
    Interval = 5
    OnTimer = Timer_AfterUpdateTimer
    Left = 54
    Top = 570
  end
  object PrintDBGridEh1: TPrintDBGridEh
    DBGridEh = DBGridEh1
    Options = [pghColored, pghRowAutoStretch]
    PageFooter.Font.Charset = DEFAULT_CHARSET
    PageFooter.Font.Color = clWindowText
    PageFooter.Font.Height = -11
    PageFooter.Font.Name = 'Tahoma'
    PageFooter.Font.Style = []
    PageHeader.Font.Charset = DEFAULT_CHARSET
    PageHeader.Font.Color = clWindowText
    PageHeader.Font.Height = -11
    PageHeader.Font.Name = 'Tahoma'
    PageHeader.Font.Style = []
    Units = MM
    OnAfterPrint = PrintDBGridEh1AfterPrint
    OnBeforePrint = PrintDBGridEh1BeforePrint
    Left = 912
    Top = 99
    BeforeGridText_Data = {
      7B5C727466315C616E73695C616E7369637067313235315C64656666305C6E6F
      7569636F6D7061745C6465666C616E67313034397B5C666F6E7474626C7B5C66
      305C666E696C5C666368617273657430205461686F6D613B7D7B5C66315C666E
      696C5C6663686172736574323034205461686F6D613B7D7D0D0A7B5C2A5C6765
      6E657261746F722052696368656432302031302E302E32323030307D5C766965
      776B696E64345C756331200D0A5C706172645C66305C667332385C6C616E6731
      303333207361736173617361646173615C66315C667331365C6C616E67313034
      395C7061720D0A7D0D0A00}
  end
  object FileOpenDialog1: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders]
    Left = 993
    Top = 105
  end
  object Timer_Print: TTimer
    Enabled = False
    Interval = 200
    OnTimer = Timer_PrintTimer
    Left = 1116
    Top = 108
  end
end
