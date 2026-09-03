inherited FrmOGselItmGroupFromTree: TFrmOGselItmGroupFromTree
  Caption = 'FrmOGselItmGroupFromTree'
  ClientHeight = 456
  ClientWidth = 341
  ExplicitWidth = 357
  ExplicitHeight = 495
  TextHeight = 13
  inherited pnlFrmMain: TPanel
    Width = 341
    Height = 440
    ExplicitWidth = 389
    ExplicitHeight = 381
    inherited pnlFrmClient: TPanel
      Width = 331
      Height = 391
      object chb_Materials: TDBCheckBoxEh
        Left = 0
        Top = 0
        Width = 331
        Height = 21
        Align = alTop
        Caption = #1052#1072#1090#1077#1088#1080#1072#1083#1099
        DynProps = <>
        TabOrder = 0
        OnClick = chb_MaterialsClick
      end
      object DBGridEh1: TDBGridEh
        Left = 0
        Top = 21
        Width = 331
        Height = 370
        Align = alClient
        AllowedOperations = [alopUpdateEh]
        DataSource = DataSource1
        DynProps = <>
        Options = [dgEditing, dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
        OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDialogFind, dghExtendVertLines]
        RowDetailPanel.Height = 250
        TabOrder = 1
        OnDblClick = DBGridEh1DblClick
      end
    end
    inherited pnlFrmBtns: TPanel
      Top = 396
      Width = 331
      ExplicitTop = 36
      ExplicitWidth = 379
      inherited bvlFrmBtnsTl: TBevel
        Width = 329
      end
      inherited bvlFrmBtnsB: TBevel
        Width = 329
      end
      inherited pnlFrmBtnsContainer: TPanel
        Width = 329
        ExplicitWidth = 377
        inherited pnlFrmBtnsMain: TPanel
          Left = 228
        end
        inherited pnlFrmBtnsChb: TPanel
          Left = -125
          ExplicitLeft = -77
        end
        inherited pnlFrmBtnsR: TPanel
          Left = 4
        end
      end
    end
  end
  inherited pnlStatusBar: TPanel
    Top = 440
    Width = 341
    inherited lblStatusBarR: TLabel
      Left = 268
      Height = 14
    end
    inherited lblStatusBarL: TLabel
      Height = 14
    end
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Left = 31
    Top = 218
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    DataDriver = ADODataDriverEh1
    TreeList.Active = True
    Left = 107
    Top = 203
  end
  object ADODataDriverEh1: TADODataDriverEh
    ADOConnection = myDBOra.AdoConnection
    DynaSQLParams.Options = []
    MacroVars.Macros = <>
    SelectCommand.Parameters = <>
    UpdateCommand.Parameters = <>
    InsertCommand.Parameters = <>
    DeleteCommand.Parameters = <>
    GetrecCommand.Parameters = <>
    Left = 168
    Top = 240
  end
end
