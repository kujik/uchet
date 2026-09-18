{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit EhLib;

{$warn 5023 off : no warning about unused units}
interface

uses
  DataDriverEh, DataSetImpExpEh, DBSumLst, DBUtilsEh, DefaultDataSourcesEh, 
  DynVarsEh, EhLib.MathAggregators, EhLib.TableLinks, EhLibLangConsts, 
  EhLibUtils, LanguageResManEh, MemTableDataEh, MemTableEh, MemTreeEh, 
  SettingsKeepersEh, XlsFileReadersEh, XlsFileWritersEh, XlsMemFilesEh, 
  XmlDocsEh, XmlReaderWriterEh, XMLSpreadsheetFormatEh, ZipFileProviderEh, 
  EhLibXmlConsts, DataSetImpExpDesignEh, DefaultItemsCollectionEditorsEh, 
  EhLibDesignAbout, EhLibDesignUtils, EhLibRegister, MemTableDesignEh, 
  MemTableDesignFrameEh, MemTableEditEh, ButtonsEh, CalculatorEh, 
  DateTimeCalendarPickersEh, DBAxisGridsEh, DBCtrlsEh, DBGridEh.DBUtils, 
  DBGridEh, DBGridEhCustomizeColumnsDialogs, DBGridEhFindDlgs, 
  DBGridEhGrouping, DBGridEhImpExp, DBGridEhSimpleFilterDlg, 
  DBGridEhToolCtrls, DBGridEhXlsMemFileExporters, DBGridEhXMLSpreadsheetExp, 
  DBGridFilterDropDownFormsEh, DBLookupEh, DBLookupGridsEh, DBLookupUtilsEh, 
  DBVertGridEhImpExp, DBVertGridEhXMLSpreadsheetExp, DBVertGridsEh, 
  DropDownFormEh, EditPivotFieldFormEh, EhLibGIFImage, EhLibImageListRes, 
  EhLibImageReses, EhLibImages, EhLibJPegImage, EhLibLclUtils, EhLibPNGImage, 
  FilterDropDownFormsEh, GridsEh, GridToolCtrlsEh, LaControlsEh, 
  LaFlowRichBlocksEh, LaGridPanelsEh, LaHintWindows, LaObjectsEh, 
  LaObjectTreeViewForms, LaPanelsEh, MemoEditFormsEh, ObjectInspectorEh, 
  PdfDocumentsEh, PdfElementsEh, PdfFontsEh, PdfGraphicsEh, PdfImagesEh, 
  PdfPrintersEh, PdfWritersEh, PictureEditFormsEh, PivotGridsEh, 
  PivotGridToolsEh, PlannerCalendarPickerEh, PlannerDataEh, PlannerItemDialog, 
  PlannersEh, PlannerToolCtrlsEh, PrintUtilsEh, PrnDbgEh, PrnDgDlg, PrntsEh, 
  PropFilerEh, PropStorageEditEh, PropStorageEh, SearchPanelsEh, 
  SpreadGridsEh, ToolCtrlsEh, YearPlannersEh, DBVertGridsDesignEditorEh, 
  EhLibDesignForms, EhLibVclRegister, GridAxisBarsDesignEditFormEh_Laz, 
  GridEhEd, PivotGridPivotFieldsEditors, PivotGridRegEh, 
  PlannerDesignEditorsEh, SQLDBDataDriverEh, EhLibVclMTE,
  EhLib.GridTableView.Filters, EhLib.GridTableViews, EhLib.TableLink.Db, 
  EhLib.TableLink.TypedLists, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('EhLibRegister', @EhLibRegister.Register);
  RegisterUnit('CalculatorEh', @CalculatorEh.Register);
  RegisterUnit('EhLibVclRegister', @EhLibVclRegister.Register);
  RegisterUnit('SQLDBDataDriverEh', @SQLDBDataDriverEh.Register);
end;

initialization
  RegisterPackage('EhLib', @Register);
end.
