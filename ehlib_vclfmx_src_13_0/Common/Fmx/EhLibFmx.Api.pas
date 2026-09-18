{*******************************************************}
{                                                       }
{                    EhLib.Fmx 12.1                     }
{                     EhLibFmx.Api                      }
{                                                       }
{    Copyright (c) 2024-2025 by Dmitry V. Bolshakov     }
{                                                       }
{*******************************************************}

unit EhLibFmx.Api;

interface

uses
  EhLibFmx.Types,
  EhLibFmx.Styles,
  EhLibFmx.DataGrids,
  EhLibFmx.Grid.Types,
  EhLibFmx.CustomDataGrids,

  EhLibFmx.Canvas.D2D,
  EhLibFmx.CustomizeColumnsDialog,

  EhLibFmx.DataAxisGrid.FieldBars,
  EhLibFmx.DataAxisGrid.ToolControls,
  EhLibFmx.DataAxisGrid.DataCells,
  EhLibFmx.DataAxisGrid.ComboDataCells,
  EhLibFmx.DataAxisGrids,

  EhLibFmx.DataGrid.Columns,
  EhLibFmx.DataGrid.ComplexTitles,
  EhLibFmx.DataGrid.DataCells,
  EhLibFmx.DataGrid.FilterForm,
  EhLibFmx.DataGrid.Footers,
  EhLibFmx.DataGrid.GridManagers,
  EhLibFmx.DataGrid.ImpExp,
  EhLibFmx.DataGrid.IndicatorColumns,
  EhLibFmx.DataGrid.IndicatorTitles,
  EhLibFmx.DataGrid.Rows,
  EhLibFmx.DataGrid.SearchPanels,
  EhLibFmx.DataGrid.SimpleFilterDialog,
  EhLibFmx.DataGrid.TitleFilters,
  EhLibFmx.DataGrid.Titles,
  EhLibFmx.DataGrid.ToolControls,
  EhLibFmx.DataGrid.DataGrouping,

  EhLibFmx.DataVertGrids,
  EhLibFmx.DataVertGrid.RowsHeader,
  EhLibFmx.CustomDataVertGrids,

  EhLibFmx.DropDownForms,
  EhLibFmx.FormElementsViewer,
  EhLibFmx.Grid.CellManagers,
  EhLibFmx.Grid.InplaceEditors,
  EhLibFmx.Grid.ToolControls,
  EhLibFmx.GridAxisData,
  EhLibFmx.Grids,
  EhLibFmx.ImageReses,
  EhLibFmx.LaControls,
  EhLibFmx.LaGridPanels,
  EhLibFmx.LaHostVirtualPanels,
  EhLibFmx.LaObjects,
  EhLibFmx.LaPanels,
  EhLibFmx.ObjectInspectors,
  EhLibFmx.Platform.Android,
  EhLibFmx.Platform.Linux,
  EhLibFmx.Platform.Mac,
  EhLibFmx.Platform,
  EhLibFmx.Platform.Win,
  EhLibFmx.SearchPanels,
  EhLibFmx.ToolControls;

type

  TScrollStepTypeEh = EhLibFmx.Types.TScrollStepTypeEh;
  TCheckBoxStateEh = EhLibFmx.Types.TCheckBoxStateEh;
  TRectangleEdgeEh = EhLibFmx.Types.TRectangleEdgeEh;
  TRectangleEdgesEh = EhLibFmx.Types.TRectangleEdgesEh;
  TGridCellFillStyleEh = EhLibFmx.Types.TGridCellFillStyleEh;
  TDrawButtonControlStyleEh = EhLibFmx.Types.TDrawButtonControlStyleEh;
  TEditButtonStyleEh = EhLibFmx.Types.TEditButtonStyleEh;
  TImagePlacementEh = EhLibFmx.Types.TImagePlacementEh;
  TBorderStyle = EhLibFmx.Types.TBorderStyle;
  TScrollCode = EhLibFmx.Types.TScrollCode;
  TTreeElementEh = EhLibFmx.Types.TTreeElementEh;
  TInteractiveActionSourceEh = EhLibFmx.Types.TInteractiveActionSourceEh;
  TPropListArray = EhLibFmx.Types.TPropListArray;
  TWinControl = EhLibFmx.Types.TWinControl;
  TPopupMenuBuildingMode = EhLibFmx.Types.TPopupMenuBuildingMode;
  TFormClass = EhLibFmx.Types.TFormClass;
  TPlatformWindowSizeTypeEh = EhLibFmx.Types.TPlatformWindowSizeTypeEh;
  TEhLibFmxSettings = EhLibFmx.Types.TEhLibFmxSettings;
  TTreeSignStateEh = EhLibFmx.Types.TTreeSignStateEh;
  TStyleOriginEh = EhLibFmx.Types.TStyleOriginEh;
  TStyleColorModeEh = EhLibFmx.Types.TStyleColorModeEh;

  TVPBaseCellHolderEh = EhLibFmx.LaHostVirtualPanels.TVPBaseCellHolderEh;
  TVPBaseCellManagerEh = EhLibFmx.LaHostVirtualPanels.TVPBaseCellManagerEh;

  TDataGridEventParamsEh = EhLibFmx.DataGrids.TDataGridEventParamsEh;
  TDataGridColumnWidthChangedParamsEh = EhLibFmx.DataGrids.TDataGridColumnWidthChangedParamsEh;
  TDataGridDataCellGetValueParamsEh = EhLibFmx.DataGrids.TDataGridDataCellGetValueParamsEh;
  TDataGridDataCellSetValueParamsEh = EhLibFmx.DataGrids.TDataGridDataCellSetValueParamsEh;
  TDataGridDataCellGetDisplayTextParamsEh = EhLibFmx.DataGrids.TDataGridDataCellGetDisplayTextParamsEh;
  TDataGridDataCellStyleParamsEh = EhLibFmx.DataGrids.TDataGridDataCellStyleParamsEh;
  TDataGridStringDataCellStyleParamsEh = EhLibFmx.DataGrids.TDataGridStringDataCellStyleParamsEh;
  TDataGridDataCellKeyDownParamsEh = EhLibFmx.DataGrids.TDataGridDataCellKeyDownParamsEh;
  TDataGridDataCellMouseButtonParamsEh = EhLibFmx.DataGrids.TDataGridDataCellMouseButtonParamsEh;
  TDataGridFooterCalcInitDataParamsEh = EhLibFmx.DataGrids.TDataGridFooterCalcInitDataParamsEh;
  TDataGridFooterCalcStepDataParamsEh = EhLibFmx.DataGrids.TDataGridFooterCalcStepDataParamsEh;
  TDataGridFooterCalcFinalDataParamsEh = EhLibFmx.DataGrids.TDataGridFooterCalcFinalDataParamsEh;
  TDataGridFooterGetDisplayTextParamsEh = EhLibFmx.DataGrids.TDataGridFooterGetDisplayTextParamsEh;
  TDataGridCanSelectRowParamsEh = EhLibFmx.DataGrids.TDataGridCanSelectRowParamsEh;
  TDataGridGetDataCellManagerParamsEh = EhLibFmx.DataGrids.TDataGridGetDataCellManagerParamsEh;
  TDataGridInitDataCellContentParamsEh = EhLibFmx.DataGrids.TDataGridInitDataCellContentParamsEh;
  TDataGridCreateDataCellContentParamsEh = EhLibFmx.DataGrids.TDataGridCreateDataCellContentParamsEh;
  TDataGridFilterRowParamsEh = EhLibFmx.DataGrids.TDataGridFilterRowParamsEh;
  TDataGridGetDataRowManagerParamsEh = EhLibFmx.DataGrids.TDataGridGetDataRowManagerParamsEh;
  TDataGridGetDataRowSplitWayParamsEh = EhLibFmx.DataGrids.TDataGridGetDataRowSplitWayParamsEh;

  TDataGridEventEh = EhLibFmx.DataGrids.TDataGridEventEh;
  TDataGridColumnWidthChangedEventEh = EhLibFmx.DataGrids.TDataGridColumnWidthChangedEventEh;
  TDataGridDataCellGetValueEventEh = EhLibFmx.DataGrids.TDataGridDataCellGetValueEventEh;
  TDataGridDataCellSetValueEventEh = EhLibFmx.DataGrids.TDataGridDataCellSetValueEventEh;
  TDataGridDataCellGetDisplayTextEventEh = EhLibFmx.DataGrids.TDataGridDataCellGetDisplayTextEventEh;
  TDataGridDataCellGetStyleParamsEventEh = EhLibFmx.DataGrids.TDataGridDataCellGetStyleParamsEventEh;
  TDataGridStringDataCellGetStyleParamsEventEh = EhLibFmx.DataGrids.TDataGridStringDataCellGetStyleParamsEventEh;
  TDataGridDataCellMouseButtonEventEh = EhLibFmx.DataGrids.TDataGridDataCellMouseButtonEventEh;
  TDataGridDataCellMouseDownEventEh = EhLibFmx.DataGrids.TDataGridDataCellMouseDownEventEh;
  TDataGridDataCellKeyDownEventEh = EhLibFmx.DataGrids.TDataGridDataCellKeyDownEventEh;
  TBaseEventEh = EhLibFmx.DataGrids.TBaseEventEh;
  TDataGridFooterCalcFinalDataEventEh = EhLibFmx.DataGrids.TDataGridFooterCalcFinalDataEventEh;
  TDataGridFooterCalcInitDataEventEh = EhLibFmx.DataGrids.TDataGridFooterCalcInitDataEventEh;
  TDataGridFooterCalcStepDataEventEh = EhLibFmx.DataGrids.TDataGridFooterCalcStepDataEventEh;
  TDataGridFooterGetDisplayTextEventEh = EhLibFmx.DataGrids.TDataGridFooterGetDisplayTextEventEh;
  TDataGridCanUserSelectCurrentRowEventEh = EhLibFmx.DataGrids.TDataGridCanUserSelectCurrentRowEventEh;
  TDataGridGetDataCellManagerEventEh = EhLibFmx.DataGrids.TDataGridGetDataCellManagerEventEh;
  TDataGridInitDataCellContentEventEh = EhLibFmx.DataGrids.TDataGridInitDataCellContentEventEh;
  TDataGridCreateDataCellContentEventEh = EhLibFmx.DataGrids.TDataGridCreateDataCellContentEventEh;
  TDataGridFilterRowParamsEventEh = EhLibFmx.DataGrids.TDataGridFilterRowParamsEventEh;
  TDataGridColumnFooterEh = EhLibFmx.DataGrids.TDataGridColumnFooterEh;
  TDataGridColumnFootersEh = EhLibFmx.DataGrids.TDataGridColumnFootersEh;
  TDataGridColumnEh = EhLibFmx.DataGrids.TDataGridColumnEh;
  TDataGridStringColumnEh = EhLibFmx.DataGrids.TDataGridStringColumnEh;
  TDataGridComboboxColumnEh = EhLibFmx.DataGrids.TDataGridComboboxColumnEh;
  TDataGridCheckboxColumnEh = EhLibFmx.DataGrids.TDataGridCheckboxColumnEh;
  TDataGridGraphicColumnEh = EhLibFmx.DataGrids.TDataGridGraphicColumnEh;
  TDataGridLayoutColumnEh = EhLibFmx.DataGrids.TDataGridLayoutColumnEh;
  TDataGridEh = EhLibFmx.DataGrids.TDataGridEh;

  TDataGridRowEh = EhLibFmx.DataGrid.Rows.TDataGridRowEh;
  TDataGridDataRowEh = EhLibFmx.DataGrid.Rows.TDataGridDataRowEh;
  TDataGridTableRowEh = EhLibFmx.DataGrid.Rows.TDataGridTableRowEh;
  TDataGridBaseColumnEh = EhLibFmx.DataGrid.Columns.TDataGridBaseColumnEh;
  TColumnTitleEh = EhLibFmx.DataGrid.Columns.TColumnTitleEh;

  TGridDrawState = EhLibFmx.Grid.Types.TGridDrawState;
  TGridOptionEh = EhLibFmx.Grid.Types.TGridOptionEh;
  TGridOptionsEh = EhLibFmx.Grid.Types.TGridOptionsEh;
  TGridScrollDirection = EhLibFmx.Grid.Types.TGridScrollDirection;
  TGridScrollDirections = EhLibFmx.Grid.Types.TGridScrollDirections;
  TEditStyle = EhLibFmx.Grid.Types.TEditStyle;
  TGridColSizeUnitEh = EhLibFmx.Grid.Types.TGridColSizeUnitEh;

  TDataGridMouseStateEh = EhLibFmx.CustomDataGrids.TDataGridMouseStateEh;
  TDataGridCalcDataRowHeightEventEh = EhLibFmx.CustomDataGrids.TDataGridCalcDataRowHeightEventEh;
  TDataGridLocateFunction = EhLibFmx.CustomDataGrids.TDataGridLocateFunction;
  TCustomDataGridEh = EhLibFmx.CustomDataGrids.TCustomDataGridEh;
  TDataGridStylePainterEh = EhLibFmx.CustomDataGrids.TDataGridStylePainterEh;

  TFooterAggregateFunction = EhLibFmx.DataGrid.Footers.TFooterAggregateFunction;
  TBaseDataGridFooterCalcInitDataParamsEh = EhLibFmx.DataGrid.Footers.TBaseDataGridFooterCalcInitDataParamsEh;
  TBaseDataGridFooterCalcStepDataParamsEh = EhLibFmx.DataGrid.Footers.TBaseDataGridFooterCalcStepDataParamsEh;
  TBaseDataGridFooterCalcFinalDataParamsEh = EhLibFmx.DataGrid.Footers.TBaseDataGridFooterCalcFinalDataParamsEh;
  TBaseDataGridFooterGetDisplayTextParamsEh = EhLibFmx.DataGrid.Footers.TBaseDataGridFooterGetDisplayTextParamsEh;
  TDataGridFooterGetCellManagerParamsEh = EhLibFmx.DataGrid.Footers.TDataGridFooterGetCellManagerParamsEh;
  TDataGridFooterInitCellParamsEh = EhLibFmx.DataGrid.Footers.TDataGridFooterInitCellParamsEh;
  TDataGridFooterCreateCellContentParamsEh = EhLibFmx.DataGrid.Footers.TDataGridFooterCreateCellContentParamsEh;
  TDataGridFooterInitCellContentParamsEh = EhLibFmx.DataGrid.Footers.TDataGridFooterInitCellContentParamsEh;
  TDataGridFooterCreateCellContentEventEh = EhLibFmx.DataGrid.Footers.TDataGridFooterCreateCellContentEventEh;
  TDataGridFooterInitCellContentEventEh = EhLibFmx.DataGrid.Footers.TDataGridFooterInitCellContentEventEh;
  TDataGridFooterGetCellManagerEventEh = EhLibFmx.DataGrid.Footers.TDataGridFooterGetCellManagerEventEh;
  TDataGridFooterRowEh = EhLibFmx.DataGrid.Footers.TDataGridFooterRowEh;
  TDataGridFooterRowsEh = EhLibFmx.DataGrid.Footers.TDataGridFooterRowsEh;
  TDataGridFooterEh = EhLibFmx.DataGrid.Footers.TDataGridFooterEh;
  TBaseColumnFooterEh = EhLibFmx.DataGrid.Footers.TDataGridBaseColumnFooterEh;
  TBaseColumnFootersEh = EhLibFmx.DataGrid.Footers.TDataGridBaseColumnFootersEh;
  TDataGridFooterCellManagerEh = EhLibFmx.DataGrid.Footers.TDataGridFooterCellManagerEh;
  TDataGridFooterCellEh = EhLibFmx.DataGrid.Footers.TDataGridFooterCellEh;
  TDataGridFixedFooterCellVirtualPanelEh = EhLibFmx.DataGrid.Footers.TDataGridFixedFooterCellVirtualPanelEh;
  TDataGridFixedFooterCellManagerEh = EhLibFmx.DataGrid.Footers.TDataGridFixedFooterCellManagerEh;
  TDataGridFixedFooterCellEh = EhLibFmx.DataGrid.Footers.TDataGridFixedFooterCellEh;

  TDataGridCalcDataRowHeightParamsEh = EhLibFmx.DataGrid.ToolControls.TDataGridCalcDataRowHeightParamsEh;
  TDataGridSelectionTypeEh = EhLibFmx.DataGrid.ToolControls.TDataGridSelectionTypeEh;
  TDataCellSelectionTimeEh = EhLibFmx.DataGrid.ToolControls.TDataCellSelectionTimeEh;
  TDataGridRowSplitWayEh = EhLibFmx.DataGrid.ToolControls.TDataGridRowSplitWayEh;

  TDataGridCompoundTitleTreeNodeTypeEh = EhLibFmx.DataGrid.ComplexTitles.TDataGridCompoundTitleTreeNodeTypeEh;
  TDataGridComplexTitleTreeNodeEh = EhLibFmx.DataGrid.ComplexTitles.TDataGridComplexTitleTreeNodeEh;
  TDataGridComplexTitleNodeClass = EhLibFmx.DataGrid.ComplexTitles.TDataGridComplexTitleNodeClass;
  TDataGridComplexTitleTreeListEh = EhLibFmx.DataGrid.ComplexTitles.TDataGridComplexTitleTreeListEh;
  TDataGridSuperTitleEh = EhLibFmx.DataGrid.ComplexTitles.TDataGridSuperTitleEh;
  TDataGridComplexTitleCellManagerEh = EhLibFmx.DataGrid.ComplexTitles.TDataGridComplexTitleCellManagerEh;
  TDataGridSuperTitleCellManagerEh = EhLibFmx.DataGrid.ComplexTitles.TDataGridSuperTitleCellManagerEh;
  TDataGridSuperTitleCellEh = EhLibFmx.DataGrid.ComplexTitles.TDataGridSuperTitleCellEh;

  TDataGridGroupHeaderRowEh = EhLibFmx.DataGrid.DataGrouping.TDataGridGroupHeaderRowEh;
  TDataGridGroupFooterRowEh = EhLibFmx.DataGrid.DataGrouping.TDataGridGroupFooterRowEh;
  TDataGridGroupingTreeListEh = EhLibFmx.DataGrid.DataGrouping.TDataGridGroupingTreeListEh;
  TDataGridDataGroupingEh = EhLibFmx.DataGrid.DataGrouping.TDataGridDataGroupingEh;
  TDataGridGroupDescriptionEh = EhLibFmx.DataGrid.DataGrouping.TDataGridGroupDescriptionEh;
  TDataGridGroupHeaderBandManagerEh = EhLibFmx.DataGrid.DataGrouping.TDataGridGroupHeaderBandManagerEh;
  TDataGridGroupHeaderBandEh = EhLibFmx.DataGrid.DataGrouping.TDataGridGroupHeaderBandEh;
  TDataGridGroupFootersEh = EhLibFmx.DataGrid.DataGrouping.TDataGridGroupFootersEh;

  TDataGridObjectInspectorEh = EhLibFmx.ObjectInspectors.TDataGridObjectInspectorEh;

  TFormEh = EhLibFmx.ToolControls.TFormEh;
  TControlMouseButtonParamsEh = EhLibFmx.ToolControls.TControlMouseButtonParamsEh;
  TControlMouseEventEh = EhLibFmx.ToolControls.TControlMouseEventEh;
  TControlMouseButtonEventEh = EhLibFmx.ToolControls.TControlMouseButtonEventEh;

  TStyleManagerEh = EhLibFmx.Styles.TStyleManagerEh;

  TLaHorzAlignmentEh = EhLibFmx.LaObjects.TLaHorzAlignmentEh;
  TLaVertAlignmentEh = EhLibFmx.LaObjects.TLaVertAlignmentEh;
  TLaOrientationEh = EhLibFmx.LaObjects.TLaOrientationEh;
  TLaObjectEh = EhLibFmx.LaObjects.TLaObjectEh;

  TLaControlBorderEh = EhLibFmx.LaControls.TLaControlBorderEh;
  TLaControlBordersEh = EhLibFmx.LaControls.TLaControlBordersEh;
  TLaControlEh = EhLibFmx.LaControls.TLaControlEh;
  TLaTextBlockEh = EhLibFmx.LaControls.TLaTextBlockEh;
  TLaFormattedTextRangeEh = EhLibFmx.LaControls.TLaFormattedTextRangeEh;
  TLaButtonEh = EhLibFmx.LaControls.TLaButtonEh;
  TLaButtonBackEh = EhLibFmx.LaControls.TLaButtonBackEh;
  TLaImageEh = EhLibFmx.LaControls.TLaImageEh;
  TInTextUrlClickParamsEh = EhLibFmx.LaControls.TInTextLinkClickParamsEh;

  TLaLayoutPanelEh = EhLibFmx.LaPanels.TLaLayoutPanelEh;
  TLaStackPanelEh = EhLibFmx.LaPanels.TLaStackPanelEh;
  TLaControlsGenericHelper = EhLibFmx.LaPanels.TLaControlsGenericHelper;
  TControlHelper = EhLibFmx.LaPanels.TControlHelper;

  TLaGridPanelEh = EhLibFmx.LaGridPanels.TLaGridPanelEh;
  TLaGridPanelSizeStyleEh = EhLibFmx.LaGridPanels.TLaGridPanelSizeStyleEh;

  TLaObjectTreeViewForm = EhLibFmx.FormElementsViewer.TLaObjectTreeViewForm;

  TDataGridTitleInitCellParamsEh = EhLibFmx.DataGrid.Titles.TDataGridTitleInitCellParamsEh;
  TDataGridTitleInitCellContentParamsEh = EhLibFmx.DataGrid.Titles.TDataGridTitleInitCellContentParamsEh;
  TDataGridTitleCreateCellContentParamsEh = EhLibFmx.DataGrid.Titles.TDataGridTitleCreateCellContentParamsEh;
  TDataGridTitleCellContextMenuParamsEh = EhLibFmx.DataGrid.Titles.TDataGridTitleCellContextMenuParamsEh;
  TDataGridTitleCellComposeContextMenuParamsEh = EhLibFmx.DataGrid.Titles.TDataGridTitleCellComposeContextMenuParamsEh;
  TDataGridTitleGetCellManagerParamsEh = EhLibFmx.DataGrid.Titles.TDataGridTitleGetCellManagerParamsEh;
  TDataGridTitleCreateCellContentEventEh = EhLibFmx.DataGrid.Titles.TDataGridTitleCreateCellContentEventEh;
  TDataGridTitleInitCellContentEventEh = EhLibFmx.DataGrid.Titles.TDataGridTitleInitCellContentEventEh;
  TDataGridTitleGetCellManagerEventEh = EhLibFmx.DataGrid.Titles.TDataGridTitleGetCellManagerEventEh;
  TDataGridTitleBarEh = EhLibFmx.DataGrid.Titles.TDataGridTitleBarEh;
  TDataGridSortItemEh = EhLibFmx.DataGrid.Titles.TDataGridSortItemEh;
  TDataGridTitleSortMarkingEh = EhLibFmx.DataGrid.Titles.TDataGridTitleSortMarkingEh;
  TDataGridTitleVirtualPanelEh = EhLibFmx.DataGrid.Titles.TDataGridTitleVirtualPanelEh;
  TDataGridTitleCellManagerEh = EhLibFmx.DataGrid.Titles.TDataGridTitleCellManagerEh;
  TDataGridTitleCellEh = EhLibFmx.DataGrid.Titles.TDataGridTitleCellEh;
  TDataGridInteractiveSortMarkersChangedParamsEh = EhLibFmx.DataGrid.Titles.TDataGridInteractiveSortMarkersChangedParamsEh;

  TGridCellMouseParamsEh = EhLibFmx.Grid.CellManagers.TGridCellMouseParamsEh;
  TGridCellMouseButtonParamsEh = EhLibFmx.Grid.CellManagers.TGridCellMouseButtonParamsEh;
  TBaseGridCellBaseParamsEh = EhLibFmx.Grid.CellManagers.TBaseGridCellBaseParamsEh;
  TBaseGridCellValueParamsEh = EhLibFmx.Grid.CellManagers.TBaseGridCellValueParamsEh;
  TBaseGridCellContextMenuParamsEh = EhLibFmx.Grid.CellManagers.TBaseGridCellContextMenuParamsEh;
  TBaseGridCellKeyDownParamsEh = EhLibFmx.Grid.CellManagers.TBaseGridCellKeyDownParamsEh;
  TBaseGridCellShowContextMenuParamsEh = EhLibFmx.Grid.CellManagers.TBaseGridCellShowContextMenuParamsEh;
  TBaseGridCellComposeContextMenuParamsEh = EhLibFmx.Grid.CellManagers.TBaseGridCellComposeContextMenuParamsEh;
  TBaseGridInitCellParamsEh = EhLibFmx.Grid.CellManagers.TBaseGridInitCellParamsEh;
  TBaseGridCreateCellContentParamsEh = EhLibFmx.Grid.CellManagers.TBaseGridCreateCellContentParamsEh;
  TBaseGridInitCellContentParamsEh = EhLibFmx.Grid.CellManagers.TBaseGridInitCellContentParamsEh;
  TBaseGridCellManagerEh = EhLibFmx.Grid.CellManagers.TBaseGridCellManagerEh;
  TGridBaseCellEh = EhLibFmx.Grid.CellManagers.TGridBaseCellEh;
  TGridBaseTextCellEh = EhLibFmx.Grid.CellManagers.TGridBaseTextCellEh;
  TGridBaseCellHolderEh = EhLibFmx.Grid.CellManagers.TGridBaseCellHolderEh;

  TDataGridIndicatorColumnGetCellManagerParamsEh = EhLibFmx.DataGrid.IndicatorColumns.TDataGridIndicatorColumnGetCellManagerParamsEh;
  TDataGridIndicatorColumnInitCellParamsEh = EhLibFmx.DataGrid.IndicatorColumns.TDataGridIndicatorColumnInitCellParamsEh;
  TDataGridIndicatorColumnCreateCellContentParamsEh = EhLibFmx.DataGrid.IndicatorColumns.TDataGridIndicatorColumnCreateCellContentParamsEh;
  TDataGridIndicatorColumnInitCellContentParamsEh = EhLibFmx.DataGrid.IndicatorColumns.TDataGridIndicatorColumnInitCellContentParamsEh;
  TDataGridIndicatorColumnGetCellManagerEventEh = EhLibFmx.DataGrid.IndicatorColumns.TDataGridIndicatorColumnGetCellManagerEventEh;
  TDataGridIndicatorColumnInitCellContentEventEh = EhLibFmx.DataGrid.IndicatorColumns.TDataGridIndicatorColumnInitCellContentEventEh;
  TDataGridIndicatorColumnCreateCellContentEventEh = EhLibFmx.DataGrid.IndicatorColumns.TDataGridIndicatorColumnCreateCellContentEventEh;
  TDataGridIndicatorColumnEh = EhLibFmx.DataGrid.IndicatorColumns.TDataGridIndicatorColumnEh;
  TDataGridIndicatorCellManagerEh = EhLibFmx.DataGrid.IndicatorColumns.TDataGridIndicatorCellManagerEh;
  TDataGridIndicatorCellEh = EhLibFmx.DataGrid.IndicatorColumns.TDataGridIndicatorCellEh;
  TDataGridIndicatorCellContentEh = EhLibFmx.DataGrid.IndicatorColumns.TDataGridIndicatorCellContentEh;
  TDataGridCalcIndicatorCalcColumnWidthParamsEh = EhLibFmx.DataGrid.IndicatorColumns.TDataGridIndicatorColumnCalcWidthParamsEh;

  TDataAxisCellManagerEh = EhLibFmx.DataAxisGrid.DataCells.TDataAxisCellManagerEh;
  TDataAxisCellEh = EhLibFmx.DataAxisGrid.DataCells.TDataAxisCellEh;

  TDataGridDataRowBandEh = EhLibFmx.DataGrid.DataCells.TDataGridDataRowBandEh;
  TDataGridDataRowBandManagerEh = EhLibFmx.DataGrid.DataCells.TDataGridDataRowBandManagerEh;

  TDataAxisTextCellManagerEh = EhLibFmx.DataAxisGrid.DataCells.TDataAxisTextCellManagerEh;
  TDataAxisTextDataCellBlockEh = EhLibFmx.DataAxisGrid.DataCells.TDataAxisTextCellBlockEh;
  TDataAxisTextCellContentEh = EhLibFmx.DataAxisGrid.DataCells.TDataAxisTextCellContentEh;
  TDataAxisTextCellEh = EhLibFmx.DataAxisGrid.DataCells.TDataAxisTextCellEh;
  TDataAxisCheckboxCellManagerEh = EhLibFmx.DataAxisGrid.DataCells.TDataAxisCheckboxCellManagerEh;
  TDataAxisCheckboxCellEh = EhLibFmx.DataAxisGrid.DataCells.TDataAxisCheckboxCellEh;
  TDataAxisGraphicCellManagerEh = EhLibFmx.DataAxisGrid.DataCells.TDataAxisGraphicCellManagerEh;
  TDataAxisGraphicCellEh = EhLibFmx.DataAxisGrid.DataCells.TDataAxisGraphicCellEh;
  TDataAxisLayoutCellManagerEh = EhLibFmx.DataAxisGrid.DataCells.TDataAxisLayoutCellManagerEh;
  TDataAxisLayoutCellEh = EhLibFmx.DataAxisGrid.DataCells.TDataAxisLayoutCellEh;
  TDataAxisCreateCellContentParamsEh = EhLibFmx.DataAxisGrid.DataCells.TDataAxisCreateCellContentParamsEh;
  TDataAxisGridInitDataCellContentParamsEh = EhLibFmx.DataAxisGrid.DataCells.TDataAxisInitCellContentParamsEh;

  TDataAxisGridComboboxCellManagerEh = EhLibFmx.DataAxisGrid.ComboDataCells.TDataAxisGridComboboxCellManagerEh;

  TBaseDataGridSetDataTreeSignStateParamsEh = EhLibFmx.DataAxisGrid.DataCells.TDataAxisCellTreeSignStateParamsEh;
  TBaseDataGridDataTreeViewAreaParamsEh = EhLibFmx.DataAxisGrid.DataCells.TDataAxisCellTreeViewAreaParamsEh;
  TDataAxisInitCellContentParamsEh = EhLibFmx.DataAxisGrid.DataCells.TDataAxisInitCellContentParamsEh;

  TDataGridIndicatorTitleMouseDownEventEh = EhLibFmx.DataGrid.IndicatorTitles.TDataGridIndicatorTitleMouseDownEventEh;
  TDataGridIndicatorTitleMouseClickEventEh = EhLibFmx.DataGrid.IndicatorTitles.TDataGridIndicatorTitleMouseClickEventEh;
  TDataGridIndicatorTitleCreateCellContentEventEh = EhLibFmx.DataGrid.IndicatorTitles.TDataGridIndicatorTitleCreateCellContentEventEh;
  TDataGridIndicatorTitleEh = EhLibFmx.DataGrid.IndicatorTitles.TDataGridIndicatorTitleEh;
  TDataGridIndicatorTitleCellManagerEh = EhLibFmx.DataGrid.IndicatorTitles.TDataGridIndicatorTitleCellManagerEh;
  TDataGridIndicatorTitleCellEh = EhLibFmx.DataGrid.IndicatorTitles.TDataGridIndicatorTitleCellEh;

  TDataGridSearchPanelCheckColumnValueAcceptParamsEh = EhLibFmx.DataGrid.SearchPanels.TDataGridSearchPanelCheckColumnValueAcceptParamsEh;
  TGridSearchPanelCheckColumnValueAcceptEventEh = EhLibFmx.DataGrid.SearchPanels.TGridSearchPanelCheckColumnValueAcceptEventEh;

  TDataVertGridEh = EhLibFmx.DataVertGrids.TDataVertGridEh;
  TDataVertGridStringRowEh = EhLibFmx.DataVertGrids.TDataVertGridStringRowEh;
  TDataVertGridComboboxRowEh = EhLibFmx.DataVertGrids.TDataVertGridComboboxRowEh;
  TDataVertGridCheckboxRowEh = EhLibFmx.DataVertGrids.TDataVertGridCheckboxRowEh;
  TDataVertGridGraphicRowEh = EhLibFmx.DataVertGrids.TDataVertGridGraphicRowEh;
  TDataVertGridLayoutRowEh = EhLibFmx.DataVertGrids.TDataVertGridLayoutRowEh;
  TCustomDataVertGridEh = EhLibFmx.CustomDataVertGrids.TCustomDataVertGridEh;

  TDataVertGridRowHeaderCreateCellContentParamsEh = EhLibFmx.DataVertGrid.RowsHeader.TDataVertGridRowHeaderCreateCellContentParamsEh;
  TDataVertGridRowHeaderInitCellContentParamsEh = EhLibFmx.DataVertGrid.RowsHeader.TDataVertGridRowHeaderInitCellContentParamsEh;

implementation

end.
