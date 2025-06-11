object myDB: TmyDB
  OldCreateOrder = False
  Height = 204
  Width = 582
  object AdoStoredProc: TADOStoredProc
    Connection = AdoConnection
    Parameters = <>
    Left = 244
    Top = 32
  end
  object ADODataDriverEh: TADODataDriverEh
    ConnectionProvider = AdoConnectionProviderEh
    DynaSQLParams.Options = []
    MacroVars.Macros = <>
    SelectCommand.Parameters = <>
    UpdateCommand.Parameters = <>
    InsertCommand.Parameters = <>
    DeleteCommand.Parameters = <>
    GetrecCommand.Parameters = <>
    Left = 200
    Top = 84
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Enabled = False
    Left = 388
    Top = 84
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    DataDriver = ADODataDriverEh
    Left = 300
    Top = 88
  end
  object AdoQuery: TADOQuery
    Connection = AdoConnection
    BeforeOpen = AdoQueryBeforeOpen
    Parameters = <>
    Left = 156
    Top = 28
  end
  object AdoConnectionProviderEh: TADOConnectionProviderEh
    Connection = AdoConnection
    InlineConnection.ConnectionString = 
      'Provider=OraOLEDB.Oracle.1;Password=uchet22;Persist Security Inf' +
      'o=True;User ID=uchet22;Data Source=DV11.COMPANY.KO'
    InlineConnection.Provider = 'OraOLEDB.Oracle.1'
    ServerType = 'Oracle'
    OnExecuteCommand = AdoConnectionProviderEhExecuteCommand
    Left = 60
    Top = 88
  end
  object AdoConnection: TADOConnection
    LoginPrompt = False
    Provider = 'MSDAORA'
    OnWillExecute = AdoConnectionWillExecute
    Left = 56
    Top = 27
  end
  object ADOQueryService: TADOQuery
    Connection = AdoConnection
    BeforeOpen = AdoQueryBeforeOpen
    Parameters = <>
    Left = 396
    Top = 36
  end
end
