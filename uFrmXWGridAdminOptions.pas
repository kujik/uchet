{
Сервисное окно для администратора для отладки фрейма TFrDBGridEh

На данный момент выводит список всех наших опций грида и чекбоксы, обозначающие установлена
ли конкретная опция. Список опций можно изменить и при нажатии Ок он будет применен.

}

unit uFrmXWGridAdminOptions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  F_MdiGridDialogTemplate, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls,
  DynVarsEh, MemTableDataEh, Data.DB, MemTableEh, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Mask, DBCtrlsEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Vcl.Buttons,
  uFrDBGridEh, V_Normal
  ;

type
  TFrmXWGridAdminOptions = class(TForm_Normal)
    BitBtn1: TBitBtn;
    pnl1: TPanel;
    DBGridEh1: TDBGridEh;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    OptionsAll: TFrDBGridOptions;
  public
    { Public declarations }
    function ShowDialog(var FrDBg: TFrDBGridEh): Boolean;
  end;

var
  FrmXWGridAdminOptions: TFrmXWGridAdminOptions;

implementation

uses
  TypInfo,
  uString,
  uForms
  ,uData
;

{$R *.dfm}

procedure TFrmXWGridAdminOptions.FormCreate(Sender: TObject);
begin
  inherited;
  Mth.CreateTableGrid(
    DBGridEh1, True, True, True, False,[
    ['name', ftString, 200, 'Свойство', 150, True, True, False],
    ['caption', ftString, 600, 'Описание', 400, True, True, True],
    ['checked', ftInteger, 0, 'Вкл.', 40, True, True, False]
    ],
    [], '', ''
  );
  Gh.SetGridColumnsProperty(DBGridEh1, cptReadOnly, 'name;caption', 1);
  Gh.SetGridInCellCheckBoxes(DBGridEh1, 'checked', '1;0');
end;

function TFrmXWGridAdminOptions.ShowDialog(var FrDBg: TFrDBGridEh): Boolean;
var
  i, j: Integer;
  st: string;
  va2: TVarDynArray2;
  c: TFrDBGridOption;
  Options: TFrDBGridOptions;
begin
  va2:=[];
  for c:= Low(TFrDBGridOption) to High(TFrDBGridOption) do begin
    va2:= va2 + [[GetEnumName(TypeInfo(TFrDBGridOption), ord(c)), FrDBGridOptionDesc[ord(c)], S.IIf(c in FrDBg.Options, 1, 0)]];
  end;
  Mth.LoadGridFromVa2(DBGridEh1, va2, '', '');

  if ShowModal <> mrOk then Exit;
  Options:= [];
  TMemTableEh(DBGridEh1.DataSource.DataSet).Post;
  TMemTableEh(DBGridEh1.DataSource.DataSet).First;
  i:= 0;
  for c:= Low(TFrDBGridOption) to High(TFrDBGridOption) do begin
    if TMemTableEh(DBGridEh1.DataSource.DataSet).RecordsView.MemTableData.RecordsList[i].DataValues['checked', dvvValueEh] = 1
      then begin
        Options:= Options + [c];
      end;
    inc(i);
  end;
  FrDBg.Options:= Options;
end;


end.
