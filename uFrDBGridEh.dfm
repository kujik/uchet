object FrDBGridEh: TFrDBGridEh
  Left = 0
  Top = 0
  Width = 750
  Height = 469
  TabOrder = 0
  OnResize = FrameResize
  object PGrid: TPanel
    Left = 10
    Top = 54
    Width = 740
    Height = 415
    Align = alClient
    Caption = 'PGrid'
    TabOrder = 0
    object DbGridEh1: TDBGridEh
      Left = 1
      Top = 1
      Width = 738
      Height = 392
      Align = alClient
      DataSource = DataSource1
      DynProps = <>
      PopupMenu = PmGrid
      RowDetailPanel.Active = True
      SearchPanel.OnSearchEditChange = DbGridEh1SearchPanelSearchEditChange
      TabOrder = 0
      OnAdvDrawDataCell = DbGridEh1AdvDrawDataCell
      OnApplyFilter = DbGridEh1ApplyFilter
      OnCellClick = DbGridEh1CellClick
      OnCellMouseClick = DbGridEh1CellMouseClick
      OnColEnter = DbGridEh1ColEnter
      OnContextPopup = DbGridEh1ContextPopup
      OnDblClick = DbGridEh1DblClick
      OnFillSTFilterListValues = DbGridEh1FillSTFilterListValues
      OnGetCellParams = DbGridEh1GetCellParams
      OnKeyDown = DbGridEh1KeyDown
      OnMouseDown = DbGridEh1MouseDown
      OnMouseMove = DbGridEh1MouseMove
      OnRowDetailPanelHide = DbGridEh1RowDetailPanelHide
      OnRowDetailPanelShow = DbGridEh1RowDetailPanelShow
      OnSortMarkingChanged = DbGridEh1SortMarkingChanged
      object RowDetailData: TRowDetailPanelControlEh
        object PRowDetailPanel: TPanel
          Left = 0
          Top = 0
          Width = 30
          Height = 118
          Align = alClient
          Caption = 'PRowDetailPanel'
          TabOrder = 0
        end
      end
    end
    object PStatus: TPanel
      Left = 1
      Top = 393
      Width = 738
      Height = 21
      Align = alBottom
      Caption = 'PStatus'
      TabOrder = 1
      OnResize = PStatusResize
      object LbStatusBarLeft: TLabel
        Left = 1
        Top = 1
        Width = 3
        Height = 13
      end
      object ImgState: TImage
        Left = 400
        Top = 1
        Width = 16
        Height = 16
        Stretch = True
        Transparent = True
      end
    end
    object CProp: TDBEditEh
      Left = 352
      Top = 344
      Width = 121
      Height = 21
      DynProps = <>
      EditButtons = <>
      TabOrder = 2
      Visible = False
    end
  end
  object PLeft: TPanel
    Left = 0
    Top = 54
    Width = 10
    Height = 415
    Align = alLeft
    TabOrder = 1
  end
  object PTop: TPanel
    Left = 0
    Top = 49
    Width = 750
    Height = 5
    Align = alTop
    TabOrder = 2
  end
  object PContainer: TPanel
    Left = 0
    Top = 0
    Width = 750
    Height = 49
    Align = alTop
    TabOrder = 3
  end
  object PBottom: TPanel
    Left = 0
    Top = 469
    Width = 750
    Height = 0
    Align = alBottom
    Caption = 'PBottom'
    TabOrder = 4
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    DataDriver = ADODataDriverEh1
    AfterOpen = MemTableEh1AfterOpen
    BeforeClose = MemTableEh1BeforeClose
    BeforeInsert = MemTableEh1BeforeInsert
    AfterInsert = MemTableEh1AfterInsert
    AfterPost = MemTableEh1AfterPost
    AfterDelete = MemTableEh1AfterDelete
    AfterScroll = MemTableEh1AfterScroll
    Left = 56
    Top = 392
    object MemTableEh1Field1: TIntegerField
      FieldName = 'iii'
    end
  end
  object ADODataDriverEh1: TADODataDriverEh
    ConnectionProvider = myDBOra.AdoConnectionProviderEh
    DynaSQLParams.SkipUnchangedFields = True
    DynaSQLParams.Options = []
    MacroVars.Macros = <>
    SelectCommand.Parameters = <>
    UpdateCommand.Parameters = <>
    InsertCommand.Parameters = <>
    DeleteCommand.Parameters = <>
    GetrecCommand.Parameters = <>
    Left = 88
    Top = 392
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Left = 120
    Top = 392
  end
  object PmGrid: TPopupMenu
    Left = 160
    Top = 393
  end
  object PrintDBGridEh1: TPrintDBGridEh
    DBGridEh = DbGridEh1
    Options = []
    Page.BottomMargin = 1.500100000000000000
    Page.LeftMargin = 1.500100000000000000
    Page.RightMargin = 1.500100000000000000
    Page.TopMargin = 1.500100000000000000
    PageFooter.CenterText.Strings = (
      'Page. &[Page]')
    PageFooter.Font.Charset = DEFAULT_CHARSET
    PageFooter.Font.Color = clWindowText
    PageFooter.Font.Height = -11
    PageFooter.Font.Name = 'MS Sans Serif'
    PageFooter.Font.Style = []
    PageFooter.LeftText.Strings = (
      '')
    PageHeader.Font.Charset = DEFAULT_CHARSET
    PageHeader.Font.Color = clWindowText
    PageHeader.Font.Height = -11
    PageHeader.Font.Name = 'MS Sans Serif'
    PageHeader.Font.Style = []
    PageHeader.LeftText.Strings = (
      #1054#1090#1095#1077#1090' '#1087#1086' '#1079#1072#1082#1072#1079#1072#1084)
    PrintFontName = 'Default'
    Units = MM
    Left = 196
    Top = 394
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
  object TimerAfterStart: TTimer
    Interval = 1
    OnTimer = TimerAfterStartTimer
    Left = 234
    Top = 398
  end
end
