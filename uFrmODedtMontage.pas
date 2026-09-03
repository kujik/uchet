{
Данные по монтажу заказа: даты начала/окончания монтажа, отметки о замечаниях заказчика/монтажников, комментарий,
папки с актом сдачи и фотоотчетом (кнопки в панели диалога открывают папку в проводнике, файлы туда копируются
вручную). Данные - таблица or_montage, ключ - id (=id заказа). AddParam при вызове - минимальная дата, ранее
которой редактирование дат запрещено (см. также исходный TDlg_J_Montage/D_J_Montage).
Вызывается только из uFrmOGjrnOrderStages.pas (журнал этапов заказа, режим mMontage).
}
unit uFrmODedtMontage;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask,
  DBCtrlsEh,
  System.DateUtils, System.Math, System.IOUtils, System.Types,
  uFrmBasicMdi, uData, uString, Vcl.ExtCtrls
  ;

const
  cBtnAct = 1001;
  cBtnPhotos = 1002;

type
  TFrmODedtMontage = class(TFrmBasicMdi)
    dedt_Beg: TDBDateTimeEditEh;
    dedt_End: TDBDateTimeEditEh;
    chb_RC: TDBCheckBoxEh;
    chb_RI: TDBCheckBoxEh;
    mem_Comm: TDBMemoEh;
    lbl_Act: TLabel;
    lbl_Photos: TLabel;
  private
    { Private declarations }
    Fields: string;
    BegValues: TVarDynArray;
    Ctrls: Array of TControl;
    CtrlValues: TVarDynArray;
    CtrlVerifications: TVarDynArray;
    DtEditMin: TDateTime;
    IsFilesLoaded: Boolean;
    OldPath: string;
    OrderIsEnding: Boolean;
    function Prepare: Boolean; override;
    procedure AfterPrepare; override;
    procedure ControlOnChange(Sender: TObject); override;
    function Save: Boolean; override;
    procedure btnClick(Sender: TObject); override;
    procedure OpenDir(AMode: Boolean);
    function IfFilesLoaded: Boolean;
  public
    { Public declarations }
  end;

var
  FrmODedtMontage: TFrmODedtMontage;

implementation

{$R *.dfm}

uses
  uDBOra,
  uForms,
  uTasks,
  uSys
  ;

//событие изменения данных контрола (см. также исходный ControlOnChange)
procedure TFrmODedtMontage.ControlOnChange(Sender: TObject);
begin
  inherited;
  if Sender = dedt_Beg then begin
    //при изменении начальной даты, поправим проверку конечной - не должна быть ранее начальной и ранее мин даты редактирования
    if not Cth.DteValueIsDate(dedt_Beg)
      then Cth.SetControlsVerification([dedt_End], [S.DateTimeToIntStr(DtEditMin) + ':' + S.DateTimeToIntStr(IncYear(Date, -30))])
      else Cth.SetControlsVerification([dedt_End], [S.DateTimeToIntStr(Max(dedt_Beg.Value, DtEditMin)) + ':' + S.DateTimeToIntStr(Date)]);
  end;
end;

procedure TFrmODedtMontage.AfterPrepare;
//вызывается после успешной отработки функции Prepare
begin
  inherited;
  //поправим формат проверки конечной даты
  ControlOnChange(dedt_Beg);
end;

procedure TFrmODedtMontage.btnClick(Sender: TObject);
//кнопки открытия папок акта/фотоотчета в панели диалога (см. также исходные Bt_ActClick/Bt_PhotosClick)
begin
  case TControl(Sender).Tag of
    cBtnAct:
      OpenDir(True);
    cBtnPhotos:
      OpenDir(False);
  else
    inherited;
  end;
end;

function TFrmODedtMontage.Prepare: Boolean;
var
  i: Integer;
  OrdNum: string;
begin
  Result := False;
  //проверим блокировку, выйдем если нельзя взять (при попытке редактирования уйдет в просмотр, при удалении - выход)
  if FormDbLock = fNone then Exit;
  DtEditMin := VarToDateTime(AddParam);
  FOpt.DlgPanelStyle := dpsBottomRight;
  FOpt.StatusBarMode := stbmDialog;
  FOpt.AutoAlignControls := True;

  //все поля основной таблицы в бд
  Fields := 'id$i;dt_beg$d;dt_end$d;rep_customer$i;rep_installer$i;comm$s;path$s';
  //соотвествующий им контролы, кроме левого - id
  Ctrls := [nil, dedt_Beg, dedt_End, chb_RC, chb_RI, mem_Comm, nil];
  //для добавления инициализация значений полей, для других режимов из запроса в базе
  BegValues := Q.QLoadRow(Q.QGetSql('s', 'or_montage', Fields), [ID]);
  OrderIsEnding := Q.QLoadRow('select dt_end from v_orders where id = :id$i', [ID])[0] <> null;
  OrdNum := S.NSt(Q.QLoadRow('select ornum from v_orders where id = :id$i', [ID])[0]);
  if BegValues[0] = null
    then BegValues := VarArrayOf([ID, Date, null, 0, 0, '', null]);
  OldPath := S.NSt(BegValues[6]);
  if BegValues[6] = null
    then BegValues[6] := Module.GetPathNewDir;
  //установим значений контролов
  for i := 0 to High(Ctrls) do
    if Ctrls[i] <> nil then Cth.SetControlValue(Ctrls[i], BegValues[i]);
  //доступность контролов, в зависимости от режима, кроме дат начала/окончания - всегда дисейбл
  Cth.DlgSetControlsEnabled(Self, Mode, [], []);
  dedt_Beg.Enabled := not OrderIsEnding and dedt_Beg.Enabled and (not Cth.DteValueIsDate(dedt_Beg) or (dedt_Beg.Value >= DtEditMin));
  dedt_End.Enabled := not OrderIsEnding and dedt_End.Enabled and (not Cth.DteValueIsDate(dedt_End) or (dedt_End.Value >= DtEditMin));
  //параметры верификации контролов
  CtrlVerifications := ['', S.IIFStr(dedt_Beg.Enabled, S.DateTimeToIntStr(DtEditMin) + ':' + S.DateTimeToIntStr(Date), ''), ':' + S.DateTimeToIntStr(Date) + ':-', '', '', '0:4000:0:T', ''];
  //параметры проверки контролов установив для них
  Cth.SetControlsVerification(Ctrls, CtrlVerifications);
  //проверка наличия файлов акта и фотоотчета
  IfFilesLoaded;

  Caption := 'Данные по монтажу заказа №' + OrdNum;

  FOpt.InfoArray := [
   ['Введите данные по монтажу заказа.'#13#10+
    'Начальная дата обязательна. Если заказ завершен, введите дату завершения (не ранее начальной и не позже текущей).'#13#10+
    'Если есть замечания заказчика или монтажников, поставьте соответствующие галочки.'#13#10+
    'При необходимости, задайте произвольный комментарий.'#13#10+
    'Обязательно прикрепите акт сдачи и фотоотчет. Для этого откройте папку,'#13#10+
    'нажав на кнопку, и скопируйте туда файлы.'#13#10+
    ''#13#10
   , Mode <> fView]
  ];

  FOpt.DlgButtonsR := [
    [cBtnAct, True, 100, 'Папка акта'],
    [cBtnPhotos, True, 135, 'Папка фотоотчета']
  ];

  Result := True;
end;

procedure TFrmODedtMontage.OpenDir(AMode: Boolean);
var
  spath, zpath: string;
begin
  try
    spath := Module.GetPath_OrMontage_Act(BegValues[6]);
    zpath := Module.GetPath_OrMontage_Photos(BegValues[6]);
    ForceDirectories(spath);
    ForceDirectories(zpath);
  finally
    Sys.ExecFile(S.IIFStr(AMode, spath, zpath));
    IfFilesLoaded;
  end;
end;

function TFrmODedtMontage.IfFilesLoaded: Boolean;
var
  a: TStringDynArray;
  b1, b2: Boolean;
begin
  Result := True; b1 := True; b2 := True;
  a := [];
  if DirectoryExists(Module.GetPath_OrMontage_Act(BegValues[6]))
    then a := TDirectory.GetFiles(Module.GetPath_OrMontage_Act(BegValues[6]), '*', TSearchOption.soAllDirectories);
  if Length(a) = 0
    then begin b1 := False; lbl_Act.Caption := 'Акт не загружен!'; end
    else lbl_Act.Caption := 'Акт загружен';
  a := [];
  if DirectoryExists(Module.GetPath_OrMontage_Photos(BegValues[6]))
    then a := TDirectory.GetFiles(Module.GetPath_OrMontage_Photos(BegValues[6]), '*', TSearchOption.soAllDirectories);
  if Length(a) = 0
    then begin b2 := False; lbl_Photos.Caption := 'Фотоотчет не загружен!' end
    else lbl_Photos.Caption := 'Фотоотчет загружен';
  if b1 then lbl_Act.Font.Color := clWindowText else lbl_Act.Font.Color := RGB(240,0,0);
  if b2 then lbl_Photos.Font.Color := clWindowText else lbl_Photos.Font.Color := RGB(240,0,0);
  Result := b1 and b2;
  IsFilesLoaded := Result;
end;

function TFrmODedtMontage.Save: Boolean;
//см. также исходный Bt_OkClick
var
  res, i: Integer;
  v: Variant;
  va: TVarDynArray;
  TaskDir: string;
begin
  Result := False;
  //удаление записи. В исходном Bt_OkClick после удаления не было Exit (или Close без Exit - код проваливался
  //дальше и мог тут же заново вставить ту же запись из текущих значений контролов) - здесь это исправлено.
  //также вместо CtrlValues[0] (на момент удаления еще не заполнен, см. код ниже) используется ID.
  if Mode = fDelete then begin
    Q.QExecSql('delete from or_montage where id = :id$i', [ID]);
    Result := True;
    Exit;
  end;
  if not IfFilesLoaded then Exit;
  //получим значения контролов
  CtrlValues := [];
  for i := 0 to High(Ctrls) do begin
    if Ctrls[i] = nil
      then v := BegValues[i]
      else v := S.NullIfEmpty(Cth.GetControlValue(Ctrls[i]));
    CtrlValues := CtrlValues + [v];
  end;
  //вставим или обновим строку
  res := Q.QSave(
    S.IIFStr(Q.QLoadValue('select count(*) from or_montage where id = :id$i', [CtrlValues[0]]) = 0, 'i', 'u')[1],
    'or_montage', 'id', Fields, VarArrayOf(CtrlValues)
    );
  if res = -1 then Exit;
  if (S.NSt(BegValues[6]) <> '') and (BegValues[6] <> OldPath) then begin
    va := Q.QLoadRow('select path, in_archive, year from orders where id = :id$i', [CtrlValues[0]]);
    if va[0] <> null then
      TaskDir := Tasks.CreateTaskRoot(mytskopLinkMontage, [
        ['directory', va[0]],
        ['in_archive', S.NSt(va[1])],
        ['year', va[2]],
        ['montage', BegValues[6]]
        ],
        False,
        True
      );
  end;
  Result := True;
end;

end.
