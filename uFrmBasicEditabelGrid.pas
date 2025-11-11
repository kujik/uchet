{
базовая форма для редактируемого грида.
в потомках обязательно должны быть настроены параметры грида (как минимум поля и способ загрузки)
Frg1.Opt.SetGridOperations('uaid');
Frg1.SetInitData('*',[]) или Frg1.SetInitData(va2, '')
для этого перекрывается PrepareForm, где также настраиваются и параметры формы.

ошибки на этой стадии обрабатываются в базовой форме грида

по умолчанию создает в форме диалоговую панель согласно режима диалога, и
дополнительные кнопки согласно допустимых режимов редактирования грида.

можно передать (несколько) текстов-заголовков, и тогда в верхней панели создаются цветные метки.

верхняя панель прячется если в ней нет ни одного компонента.

сохранение данных всегда должно обрабатываться в потомках полностью путем перекрытия функции Save;

}
unit uFrmBasicEditabelGrid;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, ToolCtrlsEh, StdCtrls, DBGridEhToolCtrls,
  MemTableDataEh, Db, ADODB, DataDriverEh, Clipbrd, GridsEh, DBAxisGridsEh, DBGridEh, Menus, Math,
  Buttons, PrnDbgEh, DBCtrlsEh, Types,
  uString, uData, uMessages, uForms, uFrmBasicMdi, uFrmBasicGrid2, uFrDBGridEh
  ;

type
  TFrmBasicEditabelGrid = class(TFrmBasicGrid2)
  private
    //процедура инициализации тестового грида
    procedure PrepareTestGrid;
  protected
    //массив текстов заголовков для лейблов в верхней панели
    FTitleTexts: TVarDynArray;
    //всегда перекрываем, тут настраиваем параметры грида и формы
    function  PrepareForm: Boolean; override;
    //можно перекрыть для действий перед инициализацией грида;
    //по умолчанию тут настраиваются кнопки в панели формы соответственно допустимым операциям
    function  PrepareFormAdd: Boolean; virtual;
    //вызывается по Ок. можно перекрыть для проверки и установки сообщения об ошибке/запроса и прочих действий
    //по умолчанию вызывается стандартная проверка myFrDBGridEh
    procedure VerifyBeforeSave; override;
  public
  end;

const
  MY_BASICEDITABELGRID_TEST_ID = -9876543210000;

var
  FrmBasicEditabelGrid: TFrmBasicEditabelGrid;

implementation


function TFrmBasicEditabelGrid.PrepareForm: Boolean;
var
  i, j: integer;
  va: TVarDynArray;
  FldDef: TVarDynArray2;
begin
  Result := False;
  FOpt.DlgPanelStyle := dpsBottomRight;
  i := Cth.CreateLabelColors(pnlTop, FTitleTexts);
  if i > 0 then
    pnlTop.Height := i;
  pnlTop.Visible := pnlTop.ControlCount > 0;
  if not PrepareFormAdd then
    Exit;
  Result := Inherited;
  Frg1.IsTableCorrect;
end;

function TFrmBasicEditabelGrid.PrepareFormAdd: Boolean;
begin
  Frg1.Opt.SetButtons(4, [[mbtInsertRow, alopInsertEh in Frg1.Opt.AllowedOperations], [mbtAddRow, alopAppendEh in Frg1.Opt.AllowedOperations],
    [mbtDeleteRow, alopDeleteEh in Frg1.Opt.AllowedOperations],[mbtDividorA],[mbtSpace, True, True, 4]], cbttBSmall, pnlFrmBtnsR
  );
  Result := True;
end;


procedure TFrmBasicEditabelGrid.VerifyBeforeSave;
begin
  Frg1.IsTableCorrect;
end;

procedure TFrmBasicEditabelGrid.PrepareTestGrid;
//процедура инициализации тестового грида
begin
  if ID <> MY_BASICEDITABELGRID_TEST_ID then
    Exit;
  Mode := fEdit;
  Frg1.Opt.SetFields([
    ['null as i$i','_i','40'],
    ['id$i','id','100'],
    ['name$s','Группа','300','e=0:15'],
    ['null as name2$s','Name','100','e=1:20::T']
  ]);
  Frg1.Opt.SetGridOperations('uaid');
  Frg1.Opt.SetTable('bcad_groups');
  Frg1.SetInitData('*',[]);
//  Frg1.EditOptions.;}
end;


{$R *.dfm}

end.
