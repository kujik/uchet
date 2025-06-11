{
поиск сметной позиции в сметах стандартных изделий и нестандартных заказов (незакрытых)
}
unit D_Or_FindNameInEstimates;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_MDI, Vcl.ExtCtrls, Vcl.ComCtrls, System.Types,
  Vcl.Buttons, Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh, DBGridEhGrouping, ToolCtrlsEh,
  DBGridEhToolCtrls, DynVarsEh, MemTableDataEh, Data.DB, MemTableEh, EhLibVCL,
  GridsEh, DBAxisGridsEh, DBGridEh, Data.Win.ADODB, DataDriverEh,
  ADODataDriverEh, Vcl.DBCtrls;

type
  TDlg_Or_FindNameInEstimates = class(TForm_MDI)
    P_Top: TPanel;
    E_Name: TDBEditEh;
    Bt_Go: TSpeedButton;
    Pc_1: TPageControl;
    Ts_Items: TTabSheet;
    Ts_Orders: TTabSheet;
    DBGridEh1: TDBGridEh;
    E_PPComment: TDBEditEh;
    MemTableEh1: TMemTableEh;
    DataSource1: TDataSource;
    ADODataDriverEh1: TADODataDriverEh;
    DBGridEh2: TDBGridEh;
    DBEditEh1: TDBEditEh;
    ADODataDriverEh2: TADODataDriverEh;
    DataSource2: TDataSource;
    MemTableEh2: TMemTableEh;
    Chb_InclosedOrders: TCheckBox;
    Chb_Like: TCheckBox;
    Img_Info: TImage;
    procedure Bt_GoClick(Sender: TObject);
    procedure DBGridEh1DblClick(Sender: TObject);
    procedure DBGridEh2DblClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Chb_InClosedOrdersClick(Sender: TObject);
  private
    { Private declarations }
    function Prepare: Boolean; override;
    procedure EstimateDialog(Mt: TMemTableEh);
  public
    { Public declarations }
  end;

var
  Dlg_Or_FindNameInEstimates: TDlg_Or_FindNameInEstimates;

implementation

{$R *.dfm}

uses
  DateUtils,
  uSettings,
  uForms,
  uDBOra,
  uString,
  uData,
  uMessages,
  uWindows,
  uOrders
  ;


procedure TDlg_Or_FindNameInEstimates.Bt_GoClick(Sender: TObject);
var
  wherest: string;
begin
  inherited;
  if E_Name.Text = '' then Exit;
  wherest:= S.IIf(Chb_Like.Checked, 'upper(bcadname) like upper(:name)', 'bcadname = :name');
  ADODataDriverEh1.SelectSQL.Text:=
    'select id_std_item, id_estimate, formatname, stdname from v_findinestimate_std where ' + wherest + ' order by formatname, stdname';
  ADODataDriverEh1.SelectCommand.Parameters.ParamByName('name').Value:=E_Name.Text;
  ADODataDriverEh1.SelectCommand.Parameters.ParamByName('name').DataType:=ftString;
  MemTableEh1.Active:=False;
  MemTableEh1.Active:=True;
  DBGridEh1.AutoFitColWidths:=True;
  DBGridEh1.Columns[0].Visible:=False;
  DBGridEh1.Columns[1].Visible:=False;
  Gh.SetGridColumnsProperty(DBGridEh1, cptCaption,'formatname;stdname','Формат;Стандартное изделие');
  DBGridEh1.AutoFitColWidths:=False;
  Gh.SetGridColumnsProperty(DBGridEh1, cptWidth, 'formatname;stdname', '200;200');
  DBGridEh1.AutoFitColWidths:=True;
  DbGridEh1.Enabled:=True;

  ADODataDriverEh2.SelectSQL.Text:=
    'select id_order_item, id_estimate, slash, itemname, std, nvl2(dt_end, 1, 0) as end from v_findinestimate_inorders where ' +
    wherest +
    S.IIf(not Chb_InClosedOrders.Checked, ' and dt_end is null ', ' ') +
    ' order by slash, itemname';
  ADODataDriverEh2.SelectCommand.Parameters.ParamByName('name').Value:=E_Name.Text;
  ADODataDriverEh2.SelectCommand.Parameters.ParamByName('name').DataType:=ftString;
  MemTableEh2.Active:=False;
  MemTableEh2.Active:=True;
  DBGridEh2.AutoFitColWidths:=True;
  DBGridEh2.Columns[0].Visible:=False;
  DBGridEh2.Columns[1].Visible:=False;
  Gh.SetGridColumnsProperty(DBGridEh2, cptCaption, 'slash;itemname;std;end', 'Заказ;Изделие;Стд.;Закр.');
  Gh.SetGridInCellCheckBoxes(DBGridEh2, 'std;end', '0;1');
  DBGridEh2.AutoFitColWidths:=False;
  Gh.SetGridColumnsProperty(DBGridEh2, cptWidth,'slash;itemname;std;end', '100;300;25;35');
  DBGridEh2.AutoFitColWidths:=True;
  DbGridEh2.Enabled:=True;
end;

procedure TDlg_Or_FindNameInEstimates.Chb_InClosedOrdersClick(Sender: TObject);
begin
  inherited;
  //
end;

procedure TDlg_Or_FindNameInEstimates.EstimateDialog(Mt: TMemTableEh);
//откроем просмотр (или, если есть права - редактор) сметы при даблклике на поле Наименование
//при клике по другим полям откроем просмотр сметы
begin
  if Mt = MemTableEh1 then begin
    //для стандартного изделия
    if (DBGridEh1.Columns[DBGridEh1.Col - 1].Field.FieldName = 'STDNAME') and User.Role(rOr_R_StdItems_Estimate)
      then begin
         Orders.LoadBcadGroups(True);
         Orders.LoadEstimate(null, null, MemTableEh1.FieldByName('id_std_item').AsInteger)
      end
      else
        Wh.ExecReference(
          myfrm_R_Estimate, Self, [myfoDialog, myfoMultiCopyWoId, myfoSizeable, myfoEnableMaximize],
          VarArrayOf([null, MemTableEh1.FieldByName('id_std_item').AsInteger])
        );
  end
  else begin
    //для изделия в заказе (редактор только для нестандартного изделия)
    if (DBGridEh2.Columns[DBGridEh2.Col - 1].Field.FieldName = 'ITEMNAME') and User.Role(rOr_D_Order_Estimate)
 //      and (MemTableEh2.FieldByName('std').AsInteger = 0) and (MemTableEh2.FieldByName('end').AsInteger = 0)
      then begin
         Orders.LoadBcadGroups(True);
         Orders.LoadEstimate(null, MemTableEh2.FieldByName('id_order_item').AsInteger, null)
      end
      else
        Wh.ExecReference(
          myfrm_R_Estimate, Self, [myfoDialog, myfoMultiCopyWoId, myfoSizeable, myfoEnableMaximize],
          VarArrayOf([MemTableEh2.FieldByName('id_order_item').AsInteger, null])
        );
  end;
end;


procedure TDlg_Or_FindNameInEstimates.DBGridEh1DblClick(Sender: TObject);
begin
  EstimateDialog(MemTableEh1);
end;

procedure TDlg_Or_FindNameInEstimates.DBGridEh2DblClick(Sender: TObject);
begin
  EstimateDialog(MemTableEh2);
end;

procedure TDlg_Or_FindNameInEstimates.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  Settings.SaveWindowPos(Self, FormDoc);
end;

procedure TDlg_Or_FindNameInEstimates.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Key = VK_ESCAPE then Close;
end;

function TDlg_Or_FindNameInEstimates.Prepare: Boolean;
//чтобы не съезжали элементы, использующие якоря, в дизайнере формы проставляем BorderStyle:=bsDialog;
//форма при этом все равно растягивается
//если этого не надо, в Prepare проставляем PreventResize:=True;
//но мди-форма работает не совсем корректно, если в этой процедуре не выставить BorderStyle:=bsSizeable;
var
  i: Integer;
  sda: TStringDynArray;
begin
  Result:=False;
  KeyPreview:=True;
  Caption:='Поиск сметной позиции';
  Cth.SetSpeedButton(Bt_Go, mybtGo, True);
  BorderStyle:=bsSizeable;
  MemTableEh1.FetchAllOnOpen:=True;
  DbGridEh1.ReadOnly:=True;
  DbGridEh1.Enabled:=False;
  Gh.SetGridOptionsDefault(DbGridEh1);
  Gh.SetGridOptionsMain(DbGridEh1, True, True, True);
  MemTableEh2.FetchAllOnOpen:=True;
  DbGridEh2.ReadOnly:=True;
  DbGridEh2.Enabled:=False;
  Gh.SetGridOptionsDefault(DbGridEh2);
  Gh.SetGridOptionsMain(DbGridEh2, True, True, True);
  E_Name.Text:='';
  if Id <> null then begin
    E_Name.Text:=S.NSt(Q.QSelectOneRow('select name from bcad_nomencl where id = :id$i', [id])[0]);
  end;
  Pc_1.ActivePageIndex:=0;
  //E_Name.Text:='!Заглушка самоклеящаяся/Заглушка самоклеящаяся D14 Белый';
  Cth.SetInfoIcon(Img_Info,
    'Поиск наименования в сметах.'#13#10+
    ''#13#10+
    'Введите наименование, которое вы хотите найти,'#13#10+
    'и нажмите кнопку "Старт" для поиска.'#13#10+
    ''#13#10+
    'Поиск будет произведен в сметах стандарнтных изделий, и в сметах по изделиям заказов,'#13#10+
    '(как в сметах стандартных, так и нестандартных изделий)'#13#10+
    'результаты отобразатся в соответствующих вкладках.'#13#10+
    ''#13#10+
    'Для поиска позиции в сметх заказов, которые уже закрыты, необходимо поставить соотвествующую галочку'#13#10+
    '(иначе ищет только в незавершенных заказах)'#13#10+
    ''#13#10+
    'Если не установлена галочка "Искать по маске", то позиции в сметах ищутся по полному совпадению со строкой.'#13#10+
    'Если же эта галочка установлена, то можно использовать символы подстановки для поиска.'#13#10+
    'Симовол "_" означает любой символ в искомой строке, а "%" - любое количество либых символов.'#13#10+
    'Важно: если символов подстановки нет, то ищется целая строка, а не эта подстрока!'#13#10+
    'Также, в этом случае поиск производится без учета регистра букв.'#13#10+
    '(например, строку поиска можно записать так: %лдсп% (будут найдены все строки с вхождением "ЛДСП"), или изделие__ ) '#13#10+
    'или так: изделие__  (будут найдены "Изделие12", "изделие S")'#13#10+
    ''#13#10+
    'В найденных данных по двойному клику в таблице на столбце "Изделие" (или "Стандартное изделий).'#13#10+
    'будет открыт редактор сметы (если у вас есть права доступа, и если заказ, в котором найдена позиция, не завершен).'#13#10+
    'По двойному клику в в других столбцах откроется просмотр сметы.'#13#10+
    ''#13#10
    , 20
  );
  Result:=True;
end;


end.
