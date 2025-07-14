object FrDBGridEh: TFrDBGridEh
  Left = 0
  Top = 0
  Width = 750
  Height = 469
  TabOrder = 0
  OnResize = FrameResize
  object pnlGrid: TPanel
    Left = 10
    Top = 54
    Width = 740
    Height = 415
    Align = alClient
    Caption = 'pnlGrid'
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
    object pnlStatusBar: TPanel
      Left = 1
      Top = 393
      Width = 738
      Height = 21
      Align = alBottom
      Caption = 'pnlStatusBar'
      TabOrder = 1
      OnResize = PStatusResize
      object lblStatusBarL: TLabel
        Left = 1
        Top = 1
        Width = 3
        Height = 15
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
      Height = 23
      DynProps = <>
      EditButtons = <>
      TabOrder = 2
      Visible = False
    end
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 54
    Width = 10
    Height = 415
    Align = alLeft
    TabOrder = 1
  end
  object pnlTop: TPanel
    Left = 0
    Top = 49
    Width = 750
    Height = 5
    Align = alTop
    TabOrder = 2
  end
  object pnlContainer: TPanel
    Left = 0
    Top = 0
    Width = 750
    Height = 49
    Align = alTop
    TabOrder = 3
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 469
    Width = 750
    Height = 0
    Align = alBottom
    Caption = 'pnlBottom'
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
  object tmrAfterCreate: TTimer
    Interval = 1
    OnTimer = tmrAfterCreateTimer
    Left = 234
    Top = 398
  end
end
