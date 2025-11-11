inherited Dlg_J_Error_Log: TDlg_J_Error_Log
  Caption = 'Dlg_J_Error_Log'
  ClientHeight = 175
  ClientWidth = 321
  ExplicitWidth = 337
  ExplicitHeight = 214
  TextHeight = 13
  inherited pnl_StatusBar: TPanel
    Top = 156
    Width = 321
  end
  object PageControl1: TPageControl [1]
    Left = 0
    Top = 0
    Width = 321
    Height = 156
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 1
    object TabSheet1: TTabSheet
      Caption = 'Information'
      DesignSize = (
        313
        128)
      object lbl_Module: TLabel
        Left = 16
        Top = 3
        Width = 41
        Height = 13
        Caption = #1052#1086#1076#1091#1083#1100':'
      end
      object lbl_User: TLabel
        Left = 16
        Top = 86
        Width = 79
        Height = 13
        Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100'::'
      end
      object lbl_Ver: TLabel
        Left = 16
        Top = 22
        Width = 40
        Height = 13
        Caption = #1042#1077#1088#1089#1080#1103':'
      end
      object lbl_Compile: TLabel
        Left = 152
        Top = 22
        Width = 94
        Height = 13
        Caption = #1044#1072#1090#1072' '#1082#1086#1084#1087#1080#1083#1103#1094#1080#1080':'
      end
      object lbl_ErrDt: TLabel
        Left = 16
        Top = 54
        Width = 158
        Height = 13
        Caption = #1042#1088#1077#1084#1103' '#1074#1086#1079#1085#1080#1082#1085#1086#1074#1077#1085#1080#1103' '#1086#1096#1080#1073#1082#1080':'
      end
      object mem_ErrorText: TDBMemoEh
        Left = 16
        Top = 128
        Width = 737
        Height = 89
        ControlLabel.Width = 117
        ControlLabel.Height = 13
        ControlLabel.Caption = #1057#1086#1086#1073#1097#1077#1085#1080#1077' '#1086#1073' '#1086#1096#1080#1073#1082#1077':'
        ControlLabel.Visible = True
        Lines.Strings = (
          'mem_ErrorText')
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        DynProps = <>
        EditButtons = <>
        TabOrder = 0
        Visible = True
        WantReturns = True
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'General'
      ImageIndex = 1
      object DBGridEh1: TDBGridEh
        Left = 0
        Top = 0
        Width = 786
        Height = 424
        Align = alClient
        DataSource = DataSource1
        DynProps = <>
        Options = [dgEditing, dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
        OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDialogFind, dghExtendVertLines]
        RowDetailPanel.Height = 250
        TabOrder = 0
        object RowDetailData: TRowDetailPanelControlEh
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
            TabOrder = 0
            Text = 'edt_PPComment'
            Visible = False
          end
        end
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Call stack'
      ImageIndex = 2
      object DBGridEh2: TDBGridEh
        Left = 0
        Top = 0
        Width = 786
        Height = 424
        Align = alClient
        DynProps = <>
        TabOrder = 0
        OnDblClick = DBGridEh2DblClick
        object RowDetailData: TRowDetailPanelControlEh
        end
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'Sourde code'
      ImageIndex = 3
      object pnl1: TPanel
        Left = 0
        Top = 0
        Width = 313
        Height = 41
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        ExplicitWidth = 786
        object lbl_SrcPath: TLabel
          Left = 8
          Top = 3
          Width = 27
          Height = 13
          Caption = #1055#1091#1090#1100':'
        end
        object lbl_FileName: TLabel
          Left = 8
          Top = 22
          Width = 32
          Height = 13
          Caption = #1060#1072#1081#1083':'
        end
        object lbl_ErrorInfo: TLabel
          Left = 200
          Top = 22
          Width = 76
          Height = 13
          Caption = #1052#1077#1089#1090#1086' '#1074#1099#1079#1086#1074#1072':'
        end
      end
      object mem_SourceFile: TfsSyntaxMemo
        Left = 0
        Top = 41
        Width = 313
        Height = 87
        Cursor = crIBeam
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        TabOrder = 1
        TabStop = True
        BlockColor = clHighlight
        BlockFontColor = clHighlightText
        CommentAttr.Charset = DEFAULT_CHARSET
        CommentAttr.Color = clNavy
        CommentAttr.Height = -13
        CommentAttr.Name = 'Courier New'
        CommentAttr.Style = [fsItalic]
        KeywordAttr.Charset = DEFAULT_CHARSET
        KeywordAttr.Color = clWindowText
        KeywordAttr.Height = -13
        KeywordAttr.Name = 'Courier New'
        KeywordAttr.Style = [fsBold]
        StringAttr.Charset = DEFAULT_CHARSET
        StringAttr.Color = clNavy
        StringAttr.Height = -13
        StringAttr.Name = 'Courier New'
        StringAttr.Style = []
        TextAttr.Charset = DEFAULT_CHARSET
        TextAttr.Color = clWindowText
        TextAttr.Height = -13
        TextAttr.Name = 'Courier New'
        TextAttr.Style = []
        Lines.Strings = (
          '')
        ReadOnly = False
        SyntaxType = stPascal
        ShowFooter = True
        ShowGutter = True
        ExplicitTop = 0
        ExplicitWidth = 794
        ExplicitHeight = 452
      end
    end
    object TabSheet5: TTabSheet
      Caption = 'Oracle'
      ImageIndex = 4
      object Panel2: TPanel
        Left = 0
        Top = 88
        Width = 317
        Height = 41
        Align = alBottom
        TabOrder = 0
        ExplicitTop = 383
        ExplicitWidth = 786
      end
      object mem_OraParams: TDBMemoEh
        Left = 0
        Top = -15
        Width = 317
        Height = 103
        ControlLabel.Width = 104
        ControlLabel.Height = 13
        ControlLabel.Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1079#1072#1087#1088#1086#1089#1072
        ControlLabel.Visible = True
        Lines.Strings = (
          '')
        Align = alBottom
        AutoSize = False
        DynProps = <>
        EditButtons = <>
        TabOrder = 1
        Visible = True
        WantReturns = True
      end
      object Panel3: TPanel
        Left = 0
        Top = 0
        Width = 313
        Height = 73
        Align = alTop
        TabOrder = 2
        ExplicitWidth = 325
        object mem_OraError: TDBMemoEh
          Left = 1
          Top = 16
          Width = 315
          Height = 56
          ControlLabel.Width = 71
          ControlLabel.Height = 13
          ControlLabel.Caption = #1058#1077#1082#1089#1090' '#1086#1096#1080#1073#1082#1080
          ControlLabel.Visible = True
          Lines.Strings = (
            '')
          Align = alBottom
          AutoSize = False
          DynProps = <>
          EditButtons = <>
          TabOrder = 0
          Visible = True
          WantReturns = True
        end
      end
      object Panel4: TPanel
        Left = 0
        Top = 73
        Width = 313
        Height = 177
        Align = alClient
        TabOrder = 3
        ExplicitWidth = 325
        DesignSize = (
          313
          177)
        object mem_OraSQL: TDBMemoEh
          Left = 1
          Top = 23
          Width = 768
          Height = 162
          ControlLabel.Width = 60
          ControlLabel.Height = 13
          ControlLabel.Caption = 'SQL-'#1079#1072#1087#1088#1086#1089
          ControlLabel.Visible = True
          Lines.Strings = (
            '')
          Anchors = [akLeft, akTop, akRight, akBottom]
          AutoSize = False
          DynProps = <>
          EditButtons = <>
          TabOrder = 0
          Visible = True
          WantReturns = True
        end
      end
    end
    object TabSheet6: TTabSheet
      Caption = 'Screenshot'
      ImageIndex = 5
      OnShow = TabSheet6Show
      object Im_Pict: TImage
        Left = 0
        Top = 0
        Width = 786
        Height = 424
        Align = alClient
        Proportional = True
        ExplicitLeft = 104
        ExplicitTop = 72
        ExplicitWidth = 369
        ExplicitHeight = 305
      end
    end
    object TabSheet7: TTabSheet
      Caption = 'Full report'
      ImageIndex = 6
      object mem_FullReport: TfsSyntaxMemo
        Left = 0
        Top = 0
        Width = 313
        Height = 128
        Cursor = crIBeam
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        TabOrder = 0
        TabStop = True
        BlockColor = clHighlight
        BlockFontColor = clHighlightText
        CommentAttr.Charset = DEFAULT_CHARSET
        CommentAttr.Color = clNavy
        CommentAttr.Height = -13
        CommentAttr.Name = 'Courier New'
        CommentAttr.Style = [fsItalic]
        KeywordAttr.Charset = DEFAULT_CHARSET
        KeywordAttr.Color = clWindowText
        KeywordAttr.Height = -13
        KeywordAttr.Name = 'Courier New'
        KeywordAttr.Style = [fsBold]
        StringAttr.Charset = DEFAULT_CHARSET
        StringAttr.Color = clNavy
        StringAttr.Height = -13
        StringAttr.Name = 'Courier New'
        StringAttr.Style = []
        TextAttr.Charset = DEFAULT_CHARSET
        TextAttr.Color = clWindowText
        TextAttr.Height = -13
        TextAttr.Name = 'Courier New'
        TextAttr.Style = []
        Lines.Strings = (
          '')
        ReadOnly = False
        SyntaxType = stPascal
        ShowFooter = True
        ShowGutter = True
        ExplicitLeft = 324
        ExplicitTop = 184
        ExplicitWidth = 200
        ExplicitHeight = 200
      end
    end
  end
  inherited tmrAfterCreate: TTimer
    Left = 136
    Top = 432
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    Left = 659
    Top = 443
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Left = 588
    Top = 440
  end
end
