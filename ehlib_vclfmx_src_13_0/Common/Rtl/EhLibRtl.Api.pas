{*******************************************************}
{                                                       }
{                       EhLib 12.1                      }
{                      EhLibRtl.Api                     }
{                                                       }
{   Copyright (c) 2024-2025 by Dmitry V. Bolshakov      }
{                                                       }
{*******************************************************}

unit EhLibRtl.Api;

interface

uses
  EhLibUtils,
  DBUtilsEh,

  EhLib.TableLinks,
  EhLib.TableLink.Db,
  EhLib.TableLink.TypedLists,

  EhLib.GridTableView.Filters,
  EhLib.GridTableViews,
  EhLib.MathAggregators,

  DefaultDataSourcesEh,

  MemTreeEh,
  MemTableDataEh,
  MemTableEh,
  DataDriverEh,

  DataSetImpExpEh,
  DBSumLst,
  DynVarsEh,
  EhLibEmbeddedLangConsts,
  EhLibLangConsts,
  EhLibXmlConsts,
  LanguageResManEh,
  SettingsKeepersEh,
  XlsFileReadersEh,
  XlsFileWritersEh,
  XlsMemFilesEh,
  XmlDocsEh,
  XmlReaderWriterEh,
  XMLSpreadsheetFormatEh;

type
  TBaseTableDataLinkEh = EhLib.TableLinks.TBaseTableDataLinkEh;
  TTableRowLinkEh = EhLib.TableLinks.TTableRowLinkEh;
  TTableRowLinkListEh = EhLib.TableLinks.TTableRowLinkListEh;
  TTableFieldLinkEh = EhLib.TableLinks.TTableFieldLinkEh;
  TTableFieldLinkListEh = EhLib.TableLinks.TTableFieldLinkListEh;
  TTableLinkEventTypeEh = EhLib.TableLinks.TTableLinkEventTypeEh;
  TRowLinkEditStateEh = EhLib.TableLinks.TRowLinkEditStateEh;
  TTableDataChangedEventEh = EhLib.TableLinks.TTableDataChangedEventEh;

  TDataSetTableLinkDataLinkEh = EhLib.TableLink.Db.TDataSetTableLinkDataLinkEh;
  TDataSetFieldLinkEh = EhLib.TableLink.Db.TDataSetFieldLinkEh;
  TDataSetFieldLinkListEh = EhLib.TableLink.Db.TDataSetFieldLinkListEh;
  TRowLinkDataValuesEh = EhLib.TableLink.Db.TRowLinkDataValuesEh;
  TDataSetRecLinkEh = EhLib.TableLink.Db.TDataSetRecLinkEh;
  TDataSetRecLinkListEh = EhLib.TableLink.Db.TDataSetRecLinkListEh;
  TDataSetTableLinkEh = EhLib.TableLink.Db.TDataSetTableLinkEh;
  TDefaultTableDataLinkListEh = EhLib.TableLink.Db.TDefaultTableDataLinkListEh;

  TTypedListFieldLinkEh = EhLib.TableLink.TypedLists.TTypedListFieldLinkEh;
  TListFieldLinkListEh = EhLib.TableLink.TypedLists.TListFieldLinkListEh;
  TTypedListItemLinkEh = EhLib.TableLink.TypedLists.TTypedListItemLinkEh;
  TListRecLinkListEh = EhLib.TableLink.TypedLists.TListRecLinkListEh;
  TListTableLinkEh = EhLib.TableLink.TypedLists.TListTableLinkEh;

  TListFieldLinkListEh<T: class, constructor> = class(EhLib.TableLink.TypedLists.TListFieldLinkListEh<T>);
  TTypedListItemLinkEh<T: class, constructor> = class(EhLib.TableLink.TypedLists.TTypedListItemLinkEh<T>);
  TListRecLinkListEh<T: class, constructor> = class(EhLib.TableLink.TypedLists.TListRecLinkListEh<T>);
  TListTableLinkEh<T: class, constructor> = class(EhLib.TableLink.TypedLists.TListTableLinkEh<T>);

  TObjectListTableLinkEh = EhLib.TableLink.TypedLists.TObjectListTableLinkEh;
  TTypedObjectListItemLinkEh = EhLib.TableLink.TypedLists.TTypedObjectListItemLinkEh;

  TDefaultDataSourceListEh = DefaultDataSourcesEh.TDefaultDataSourceListEh;

  TMemTableEh = MemTableEh.TMemTableEh;
  TRefObjectField = MemTableEh.TRefObjectField;

  TDataDriverEh = DataDriverEh.TDataDriverEh;
  TDataSetDriverEh = DataDriverEh.TDataSetDriverEh;
  TSQLDataDriverEh = DataDriverEh.TSQLDataDriverEh;
  TSQLCommandEh = DataDriverEh.TSQLCommandEh;

  TXlsFileCellLineStyleEh = XlsMemFilesEh.TXlsFileCellLineStyleEh;
  TXlsFileCellHorzAlign = XlsMemFilesEh.TXlsFileCellHorzAlign;
  TXlsFileCellVertAlign = XlsMemFilesEh.TXlsFileCellVertAlign;
  TXlsFileCharsFlowDirectionEh = XlsMemFilesEh.TXlsFileCharsFlowDirectionEh;
  TXlsFilePrintScalingModeEh = XlsMemFilesEh.TXlsFilePrintScalingModeEh;
  TXlsMemFileEh = XlsMemFilesEh.TXlsMemFileEh;
  TXlsWorkbookEh = XlsMemFilesEh.TXlsWorkbookEh;
  TXlsWorksheetEh = XlsMemFilesEh.TXlsWorksheetEh;
  TXlsFileColumnsEh = XlsMemFilesEh.TXlsFileColumnsEh;
  TXlsFileColumnEh = XlsMemFilesEh.TXlsFileColumnEh;
  TXlsFileRowsEh = XlsMemFilesEh.TXlsFileRowsEh;
  TXlsFileRowEh = XlsMemFilesEh.TXlsFileRowEh;
  TXlsFileStyleFont = XlsMemFilesEh.TXlsFileStyleFont;
  TXlsFileStyleFillPatternTypeEh = XlsMemFilesEh.TXlsFileStyleFillPatternTypeEh;
  TXlsFileStyleFill = XlsMemFilesEh.TXlsFileStyleFill;
  TXlsFileStyleLineEh = XlsMemFilesEh.TXlsFileStyleLineEh;
  TXlsFileStyleLinesEh = XlsMemFilesEh.TXlsFileStyleLinesEh;
  TXlsFileStyleNumberFormatEh = XlsMemFilesEh.TXlsFileStyleNumberFormatEh;
  TXlsFileCellStyle = XlsMemFilesEh.TXlsFileCellStyle;
  TXlsFileStylesEh = XlsMemFilesEh.TXlsFileStylesEh;
  TXlsFileCellMergeRangeEh = XlsMemFilesEh.TXlsFileCellMergeRangeEh;
  TCellValueType = XlsMemFilesEh.TCellValueType;
  TXlsFileCellEh = XlsMemFilesEh.TXlsFileCellEh;
  TXlsFileWorksheetCellsRectEh = XlsMemFilesEh.TXlsFileWorksheetCellsRectEh;
  TXlsFileWorksheetDimensionEh = XlsMemFilesEh.TXlsFileWorksheetDimensionEh;
  TXlsFileWorksheetPrintParamsEh = XlsMemFilesEh.TXlsFileWorksheetPrintParamsEh;
  TXlsFileWorksheetPrintPageMarginsEh = XlsMemFilesEh.TXlsFileWorksheetPrintPageMarginsEh;
  TXlsFileCellsRangeFontEh = XlsMemFilesEh.TXlsFileCellsRangeFontEh;
  TXlsFileCellsRangeFillEh = XlsMemFilesEh.TXlsFileCellsRangeFillEh;
  TXlsFileCellsRangeLineEh = XlsMemFilesEh.TXlsFileCellsRangeLineEh;
  TXlsFileCellsRangeLinesEh = XlsMemFilesEh.TXlsFileCellsRangeLinesEh;
  IXlsFileCellsRangeEh = XlsMemFilesEh.IXlsFileCellsRangeEh;
  TXlsFileBaseFormattingRangeEh = XlsMemFilesEh.TXlsFileBaseFormattingRangeEh;
  TXlsFileCellsRangeEh = XlsMemFilesEh.TXlsFileCellsRangeEh;
  TXlsFileColumnsRangeEh = XlsMemFilesEh.TXlsFileColumnsRangeEh;

implementation

end.
