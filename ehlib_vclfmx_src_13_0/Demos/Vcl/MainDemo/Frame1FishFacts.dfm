object frOneFishFacts: TfrOneFishFacts
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  TabOrder = 0
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 451
    Height = 36
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 667
    object PaintBox1: TPaintBox
      Left = 0
      Top = 0
      Width = 667
      Height = 36
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnPaint = PaintBox1Paint
      ExplicitWidth = 390
    end
    object Label1: TLabel
      Left = 41
      Top = 7
      Width = 95
      Height = 23
      Caption = 'Fish Facts'
      Font.Charset = ANSI_CHARSET
      Font.Color = clNavy
      Font.Height = -19
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object DBGridEh1: TDBGridEh
    Left = 0
    Top = 36
    Width = 451
    Height = 268
    Align = alClient
    AutoFitColWidths = True
    DataSource = DataSource1
    DrawGraphicData = True
    DrawMemoText = True
    DynProps = <>
    HorzScrollBar.ExtraPanel.NavigatorButtons = [nbFirstEh, nbPriorEh, nbNextEh, nbLastEh]
    HorzScrollBar.ExtraPanel.Visible = True
    IndicatorTitle.ShowDropDownSign = True
    IndicatorTitle.TitleButton = True
    OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDialogFind, dghColumnResize, dghColumnMove, dghAutoFitRowHeight, dghExtendVertLines]
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    TreeViewParams.ShowTreeLines = False
    VertScrollBar.SmoothStep = True
    Columns = <
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        Footers = <>
        TextEditing = False
        Title.Caption = 'LaObject'
        Width = 576
      end
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'SpeciesId'
        Footers = <>
      end
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'Graphic'
        Footers = <>
        Visible = False
      end
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'Category'
        Footers = <>
        Visible = False
      end
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'Common_name'
        Footers = <>
        Visible = False
      end
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'Species_Name'
        Footers = <>
        Visible = False
      end
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'Length'
        Footers = <>
        Visible = False
      end
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'ADate'
        Footers = <>
        Visible = False
      end
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'AnmlClass'
        Footers = <>
        Visible = False
      end
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'AnmlFamily'
        Footers = <>
        Visible = False
      end
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'AnmlGenus'
        Footers = <>
        Visible = False
      end
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'AnmlKingdom'
        Footers = <>
        Visible = False
      end
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'AnmlOrder'
        Footers = <>
        Visible = False
      end
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'AnmlPhylum'
        Footers = <>
        Visible = False
      end
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'AnmlSpecies'
        Footers = <>
        Visible = False
      end
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'Ocean'
        Footers = <>
        Visible = False
      end
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'PngGraphic'
        Footers = <>
        Visible = False
      end
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'RichNotes'
        Footers = <>
        Visible = False
      end
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'Notes'
        Footers = <>
        Visible = False
        Width = 82
      end>
    object RowDetailData: TRowDetailPanelControlEh
    end
  end
  object DataSource1: TDataSource
    DataSet = mtQuery1
    Left = 170
    Top = 348
  end
  object mtQuery1: TMemTableEh
    CachedUpdates = True
    Filtered = True
    FetchAllOnOpen = True
    Params = <>
    DataDriver = ddrData1
    Options = [mtoPersistentStructEh]
    Left = 238
    Top = 340
    object MemTableData: TMemTableDataEh
      object DataStruct: TMTDataStructEh
        object SpeciesId: TMTNumericDataFieldEh
          FieldName = 'SpeciesId'
          NumericDataType = fdtAutoIncEh
          AutoIncrement = False
          DisplayLabel = 'SpeciesId'
          DisplayWidth = 10
          currency = False
          Precision = 15
        end
        object Category: TMTStringDataFieldEh
          FieldName = 'Category'
          StringDataType = fdtWideStringEh
          DisplayLabel = 'Category'
          DisplayWidth = 50
          Size = 50
          Transliterate = True
        end
        object Common_name: TMTStringDataFieldEh
          FieldName = 'Common_name'
          StringDataType = fdtWideStringEh
          DisplayLabel = 'Common_name'
          DisplayWidth = 255
          Size = 255
          Transliterate = True
        end
        object Species_Name: TMTStringDataFieldEh
          FieldName = 'Species_Name'
          StringDataType = fdtWideStringEh
          DisplayLabel = 'Species_Name'
          DisplayWidth = 255
          Size = 255
          Transliterate = True
        end
        object Length: TMTNumericDataFieldEh
          FieldName = 'Length'
          NumericDataType = fdtFloatEh
          AutoIncrement = False
          DisplayLabel = 'Length'
          DisplayWidth = 10
          currency = False
          Precision = 15
        end
        object Notes: TMTBlobDataFieldEh
          FieldName = 'Notes'
          DisplayLabel = 'Notes'
          DisplayWidth = 10
          BlobType = ftWideMemo
          Transliterate = False
        end
        object Graphic: TMTBlobDataFieldEh
          FieldName = 'Graphic'
          DisplayLabel = 'Graphic'
          DisplayWidth = 10
          Transliterate = False
        end
        object RichNotes: TMTBlobDataFieldEh
          FieldName = 'RichNotes'
          DisplayLabel = 'RichNotes'
          DisplayWidth = 10
          BlobType = ftWideMemo
          Transliterate = False
        end
        object PngGraphic: TMTBlobDataFieldEh
          FieldName = 'PngGraphic'
          DisplayLabel = 'PngGraphic'
          DisplayWidth = 10
          Transliterate = False
        end
        object Ocean: TMTStringDataFieldEh
          FieldName = 'Ocean'
          StringDataType = fdtWideStringEh
          DisplayLabel = 'Ocean'
          DisplayWidth = 255
          Size = 255
          Transliterate = True
        end
        object AnmlKingdom: TMTStringDataFieldEh
          FieldName = 'AnmlKingdom'
          StringDataType = fdtWideStringEh
          DisplayLabel = 'AnmlKingdom'
          DisplayWidth = 255
          Size = 255
          Transliterate = True
        end
        object AnmlPhylum: TMTStringDataFieldEh
          FieldName = 'AnmlPhylum'
          StringDataType = fdtWideStringEh
          DisplayLabel = 'AnmlPhylum'
          DisplayWidth = 255
          Size = 255
          Transliterate = True
        end
        object AnmlClass: TMTStringDataFieldEh
          FieldName = 'AnmlClass'
          StringDataType = fdtWideStringEh
          DisplayLabel = 'AnmlClass'
          DisplayWidth = 255
          Size = 255
          Transliterate = True
        end
        object AnmlOrder: TMTStringDataFieldEh
          FieldName = 'AnmlOrder'
          StringDataType = fdtWideStringEh
          DisplayLabel = 'AnmlOrder'
          DisplayWidth = 255
          Size = 255
          Transliterate = True
        end
        object AnmlFamily: TMTStringDataFieldEh
          FieldName = 'AnmlFamily'
          StringDataType = fdtWideStringEh
          DisplayLabel = 'AnmlFamily'
          DisplayWidth = 255
          Size = 255
          Transliterate = True
        end
        object AnmlGenus: TMTStringDataFieldEh
          FieldName = 'AnmlGenus'
          StringDataType = fdtWideStringEh
          DisplayLabel = 'AnmlGenus'
          DisplayWidth = 255
          Size = 255
          Transliterate = True
        end
        object AnmlSpecies: TMTStringDataFieldEh
          FieldName = 'AnmlSpecies'
          StringDataType = fdtWideStringEh
          DisplayLabel = 'AnmlSpecies'
          DisplayWidth = 255
          Size = 255
          Transliterate = True
        end
        object ADate: TMTStringDataFieldEh
          FieldName = 'ADate'
          StringDataType = fdtWideStringEh
          DisplayLabel = 'ADate'
          DisplayWidth = 255
          Size = 255
        end
      end
    end
  end
  object ddrData1: TADODataDriverEh
    ConnectionProvider = Form1.ADOConnectionProviderEh2
    DynaSQLParams.Options = []
    MacroVars.Macros = <>
    SelectCommand.CommandText.Strings = (
      'select'
      '*'
      'from'
      '  Biolife2')
    SelectCommand.Parameters = <>
    UpdateCommand.Parameters = <>
    InsertCommand.Parameters = <>
    DeleteCommand.Parameters = <>
    GetrecCommand.Parameters = <>
    Left = 312
    Top = 344
  end
end
