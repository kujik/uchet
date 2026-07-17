{

Экспорт данных в файл XLSX

данные должны быть в формате TNamedArr

релизовано на бызе FrGBGridEh стандартным импортом EhLib

форматирование данных осуществляется передеачей массива параметров по правилам FrGBGridEh

если переданное имя файла содержит путь, то сразу происходит выгрузка в него, в
противном случае файл сохраняется в папку "Мои документы"
и после этого автоматически открывается.

}


unit uExportToXlsx;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh, uNamedArr
  ;

type
  TXlsxCellFormatter = reference to procedure(var Fr: TFrDBGridEh; FieldName: string; Params: TColCellParamsEh);

  TFrmExportToXlsx = class(TFrmBasicGrid2)
  private
    CellFormatter: TXlsxCellFormatter;
    function RunExport(const AFileName: string; const AData: TNamedArr; const AFields: TVarDynArray2; ATopString: string = ''; const ABottomString: string = ''; AExportFormats: Boolean = False): Boolean;
    procedure Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh); override;
  public
  end;

var
  FrmExportToXlsx: TFrmExportToXlsx;

//функция экспорта данных в файл
function ExportToXlsx(const AFileName: string; const AData: TNamedArr; const AFields: TVarDynArray2; ATopString: string = ''; const ABottomString: string = ''; AExportFormats: Boolean = False; ACellFormatter: TXlsxCellFormatter = nil): Boolean;


implementation

uses
  uSys;

{$R *.dfm}

function ExportToXlsx(const AFileName: string; const AData: TNamedArr; const AFields: TVarDynArray2; ATopString: string = ''; const ABottomString: string = ''; AExportFormats: Boolean = False; ACellFormatter: TXlsxCellFormatter = nil): Boolean;
begin
  FrmExportToXlsx.CellFormatter := ACellFormatter;
  Result := FrmExportToXlsx.RunExport(AFileName, AData, AFields, ATopString, ABottomString, AExportFormats);
end;

procedure TFrmExportToXlsx.Frg1ColumnsGetCellParams(var Fr: TFrDBGridEh; const No: Integer; Sender: TObject; FieldName: string; EditMode: Boolean; Params: TColCellParamsEh);
begin
  if Assigned(CellFormatter) then
    CellFormatter(Fr, FieldName, Params);
end;

function TFrmExportToXlsx.RunExport(const AFileName: string; const AData: TNamedArr; const AFields: TVarDynArray2; ATopString: string = ''; const ABottomString: string = ''; AExportFormats: Boolean = False): Boolean;
begin
  Result := True;
  try
    Frg1.OnColumnsGetCellParams := Frg1ColumnsGetCellParams;
    Frg1.Opt.SetFields(AFields);
    Frg1.SetInitData(AData);
    Frg1.Prepare;
    Frg1.RefreshGrid;
    Gh.ExportGridToXlsxNew(Frg1.DBGridEh1, S.IIfStr(Pos('\', AFileName) = 0,  Sys.GetMyDocumentsPath + '\') + AFileName, S.IIf(Pos('\', AFileName) > 0, False, True), ATopString, ABottomString, AExportFormats, True);
  except
    Result := False;
  end;
end;

end.
