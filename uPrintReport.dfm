object PrintReport: TPrintReport
  Height = 457
  Width = 116
  object frxReportTableObject1: TfrxReportTableObject
    Left = 44
    Top = 16
  end
  object frxUserDataSet1: TfrxUserDataSet
    RangeEndCount = 2
    UserName = 'frxUserDataSet1'
    Left = 44
    Top = 73
  end
  object frxDsT: TfrxDBDataset
    UserName = 'DsT'
    CloseDataSource = False
    DataSet = frxQT
    BCDToCurrency = False
    DataSetOptions = []
    Left = 44
    Top = 128
  end
  object frxQT: TADOQuery
    Connection = myDBOra.AdoConnection
    Parameters = <>
    Left = 44
    Top = 192
  end
  object frxDsB: TfrxDBDataset
    UserName = 'DsB'
    CloseDataSource = False
    DataSet = frxQB
    BCDToCurrency = False
    DataSetOptions = []
    Left = 44
    Top = 356
  end
  object frxQB: TADOQuery
    Connection = myDBOra.AdoConnection
    Parameters = <>
    Left = 44
    Top = 304
  end
  object frxReport1: TfrxReport
    Version = '2022.1.3'
    DotMatrixReport = False
    IniFile = '\Software\Fast Reports'
    PreviewOptions.Buttons = [pbPrint, pbLoad, pbSave, pbExport, pbZoom, pbFind, pbOutline, pbPageSetup, pbTools, pbEdit, pbNavigator, pbExportQuick]
    PreviewOptions.Zoom = 1.000000000000000000
    PrintOptions.Printer = 'Default'
    PrintOptions.PrintOnSheet = 0
    ReportOptions.CreateDate = 44679.509329560180000000
    ReportOptions.LastChange = 44679.509329560180000000
    ScriptLanguage = 'PascalScript'
    ScriptText.Strings = (
      'begin'
      ''
      'end.')
    Left = 44
    Top = 248
    Datasets = <>
    Variables = <>
    Style = <>
  end
  object frxMtB: TMemTableEh
    Params = <>
    Left = 40
    Top = 408
  end
end
