{
ввод (редактирование, добавление) единицы измерени€ в базу данных итм
ввод€тс€ категори€ (все, штучные, вес..), краткое наименование, полное наименование, количество знаков до округлени€
все пол€ об€зательны
в итм есть еще базова€ единица и коэффициент перерасчета, но мы это не используем, они не задаютс€
перед записью производитс€ проверка на похожесть введенной единицы с существующими, выдаетс€
предупреждение если найдено, но создать можно все равно, даже с точно таким же названием (в »“ћ проверки нет)
}

unit D_R_Itm_Units;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, F_MdiDialogTemplate, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Buttons, DBCtrlsEh, Vcl.Mask;

type
  TDlg_R_Itm_Units = class(TForm_MdiDialogTemplate)
    Cb_Id_MeasureGroup: TDBComboBoxEh;
    E_Name_Unit: TDBEditEh;
    Ne_Full_Name: TDBEditEh;
    Ne_Pression: TDBNumberEditEh;
  private
    { Private declarations }
    function  Prepare: Boolean; override;
    function  LoadComboBoxes: Boolean; override;
    function  VerifyBeforeSave: Boolean; override;
  public
    { Public declarations }
  end;

var
  Dlg_R_Itm_Units: TDlg_R_Itm_Units;

implementation

uses
  uData,
  uForms,
  uDBOra,
  uString,
  uMessages
;

{$R *.dfm}

function TDlg_R_Itm_Units.VerifyBeforeSave: Boolean;
//проверим, нет ли похожей единицы измерени€ (по краткому наименованию)
//дл€ этого приведем к верхнему регистру и уберем из наименований точки и пробелы
//в итм нет даже уникальногшо индекса по имени ед.изм.
//если вернет в Result True, то будет выдано сообщение "ƒанные не корректны!"
var
  va: TVarDynArray;
  i: Integer;
  st1, st2: string;
begin
  Result:=False;
  if Mode = fDelete then Exit;
//  ok:=False;
  st1:=S.ToUpper(StringReplace(StringReplace(E_Name_Unit.Text, ' ', '', [rfReplaceAll]), '.', '', [rfReplaceAll]));
  va:=Q.QLoadToVarDynArrayOneCol('select name_unit from dv.unit where id_unit <> :id$i', [id]);
  for i:=0 to High(va) do
    if st1 = S.ToUpper(StringReplace(StringReplace(va[i], ' ', '', [rfReplaceAll]), '.', '', [rfReplaceAll]))
      then Break;
  if i <= High(va) then begin
    if MyQuestionMessage('≈диница измерени€ с похожим названием уже существует:'#13#10 + va[i] + #13#10'¬се равно создать?') = mrYes
      then Exit;
  end
  else Exit;
  //чтобы блокировать запись, надо установить эту переменную.
  ok:=False;
end;

function TDlg_R_Itm_Units.LoadComboBoxes: Boolean;
begin
  Q.QLoadToDBComboBoxEh('select name, id_measuregroup from dv.groups_measure order by name', [], Cb_Id_MeasureGroup, cntComboLK);
  Result:=True;
end;

function TDlg_R_Itm_Units.Prepare: Boolean;
begin
  Caption:='≈диница измерени€';
  Fields:='id_unit$i;id_measuregroup$i;name_unit$s;full_name$s;pression$i';
  View:='v_itm_units';
  Table:='dv.unit';
  CtrlVerifications:=['','1:200','1:50:0:T','1:200:0:T','0:5:0:N'];
  CtrlValuesDefault:=[-1, 0, '', '', 1];
  Info:=
    '¬вод единицы измерени€.'#13#10+
    '≈сли будет найдена похожа€ единица измерени€, то будет выдыно предупреждение!'#13#10+
    ''#13#10
  ;
  AutoSaveWindowPos:= True;
  MinWidth:=295;
  MinHeight:=200;
  Result:=inherited;
end;


end.
