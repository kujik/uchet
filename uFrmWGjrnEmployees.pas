unit uFrmWGjrnEmployees;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, DBGridEhGrouping, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Db, ADODB, DataDriverEh, IOUtils, Clipbrd, ADODataDriverEh, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math, DateUtils,
  Buttons, PrnDbgEh, DBCtrlsEh, Types, RegularExpressions,
  uData, uSettings, uSys, uForms, uDBOra, uString, uMessages, uWindows, uPrintReport, uFrmBasicInput, uFrDBGridEh, uFrmBasicMdi, uFrmBasicGrid2
  ;

type
  TFrmWGjrnEmployees = class(TFrmBasicGrid2)
  private
  public
  end;

var
  FrmWGjrnEmployees: TFrmWGjrnEmployees;

implementation

{$R *.dfm}

uses
  uTurv
  ;


end.
