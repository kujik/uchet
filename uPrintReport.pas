{$A8,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
{$WARN SYMBOL_DEPRECATED ON}
{$WARN SYMBOL_LIBRARY ON}
{$WARN SYMBOL_PLATFORM ON}
{$WARN SYMBOL_EXPERIMENTAL ON}
{$WARN UNIT_LIBRARY ON}
{$WARN UNIT_PLATFORM ON}
{$WARN UNIT_DEPRECATED ON}
{$WARN UNIT_EXPERIMENTAL ON}
{$WARN HRESULT_COMPAT ON}
{$WARN HIDING_MEMBER ON}
{$WARN HIDDEN_VIRTUAL ON}
{$WARN GARBAGE ON}
{$WARN BOUNDS_ERROR ON}
{$WARN ZERO_NIL_COMPAT ON}
{$WARN STRING_CONST_TRUNCED ON}
{$WARN FOR_LOOP_VAR_VARPAR ON}
{$WARN TYPED_CONST_VARPAR ON}
{$WARN ASG_TO_TYPED_CONST ON}
{$WARN CASE_LABEL_RANGE ON}
{$WARN FOR_VARIABLE ON}
{$WARN CONSTRUCTING_ABSTRACT ON}
{$WARN COMPARISON_FALSE ON}
{$WARN COMPARISON_TRUE ON}
{$WARN COMPARING_SIGNED_UNSIGNED ON}
{$WARN COMBINING_SIGNED_UNSIGNED ON}
{$WARN UNSUPPORTED_CONSTRUCT ON}
{$WARN FILE_OPEN ON}
{$WARN FILE_OPEN_UNITSRC ON}
{$WARN BAD_GLOBAL_SYMBOL ON}
{$WARN DUPLICATE_CTOR_DTOR ON}
{$WARN INVALID_DIRECTIVE ON}
{$WARN PACKAGE_NO_LINK ON}
{$WARN PACKAGED_THREADVAR ON}
{$WARN IMPLICIT_IMPORT ON}
{$WARN HPPEMIT_IGNORED ON}
{$WARN NO_RETVAL ON}
{$WARN USE_BEFORE_DEF ON}
{$WARN FOR_LOOP_VAR_UNDEF ON}
{$WARN UNIT_NAME_MISMATCH ON}
{$WARN NO_CFG_FILE_FOUND ON}
{$WARN IMPLICIT_VARIANTS ON}
{$WARN UNICODE_TO_LOCALE ON}
{$WARN LOCALE_TO_UNICODE ON}
{$WARN IMAGEBASE_MULTIPLE ON}
{$WARN SUSPICIOUS_TYPECAST ON}
{$WARN PRIVATE_PROPACCESSOR ON}
{$WARN UNSAFE_TYPE ON}
{$WARN UNSAFE_CODE ON}
{$WARN UNSAFE_CAST ON}
{$WARN OPTION_TRUNCATED ON}
{$WARN WIDECHAR_REDUCED ON}
{$WARN DUPLICATES_IGNORED ON}
{$WARN UNIT_INIT_SEQ ON}
{$WARN LOCAL_PINVOKE ON}
{$WARN MESSAGE_DIRECTIVE ON}
{$WARN TYPEINFO_IMPLICITLY_ADDED ON}
{$WARN RLINK_WARNING ON}
{$WARN IMPLICIT_STRING_CAST ON}
{$WARN IMPLICIT_STRING_CAST_LOSS ON}
{$WARN EXPLICIT_STRING_CAST OFF}
{$WARN EXPLICIT_STRING_CAST_LOSS OFF}
{$WARN CVT_WCHAR_TO_ACHAR ON}
{$WARN CVT_NARROWING_STRING_LOST ON}
{$WARN CVT_ACHAR_TO_WCHAR ON}
{$WARN CVT_WIDENING_STRING_LOST ON}
{$WARN NON_PORTABLE_TYPECAST ON}
{$WARN XML_WHITESPACE_NOT_ALLOWED ON}
{$WARN XML_UNKNOWN_ENTITY ON}
{$WARN XML_INVALID_NAME_START ON}
{$WARN XML_INVALID_NAME ON}
{$WARN XML_EXPECTED_CHARACTER ON}
{$WARN XML_CREF_NO_RESOLVE ON}
{$WARN XML_NO_PARM ON}
{$WARN XML_NO_MATCHING_PARM ON}
{$WARN IMMUTABLE_STRINGS OFF}
{
класс для работы с FastReport
}

unit uPrintReport;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Math,
  Dialogs, StdCtrls, Buttons, DBCtrlsEh, Mask, uData, uForms, uDBOra, uString, uMessages, System.Types,
  frxClass, frxDesgn, frxPrinter, frxPrintDialog, frxUnicodeUtils, frxCtrls, frxPreviewPageSettings, frxBarcode, frxBarcod,
  MemTableEh, MemTableDataEh, StrUtils, Data.DB, Data.Win.ADODB, frxDBSet,
  frxTableObject
  ;

type
  TPrintReport = class(TDataModule)
    //отчет
    frxReport1: TfrxReport;
    //объект таблицы. если его не добавить на форму, то в отчетах в дизайнере она недоступна
    frxReportTableObject1: TfrxReportTableObject;
    //пользовательский датасет
    frxUserDataSet1: TfrxUserDataSet;
    //датасет и запрос для табличной части, подключен к бд оракле
    frxDsT: TfrxDBDataset;
    frxQT: TADOQuery;
    //татасет и запрос для общей части документа
    frxDsB: TfrxDBDataset;
    frxQB: TADOQuery;
    //мемтейбл для формирования выборки запросами скл из него, данные для отчета должны быть в него внесены вручную
    frxMtB: TMemTableEh;
  private
    FDesignReport: Boolean;
  public
    //если установлено, будем при печати открывать дизайнер отчето, для правки
    //установлено при запуске из дельфи, в противном случае снято
    //установить значение для текущего сеанся работы можно из настроек программы в главном меню
    property DesignReport: Boolean read FDesignReport;
    //конструктор
    constructor Create;
    //получить полное имя файла отчета по его короткому имени; если последнее непередано, возвращает путь к папке отчета
    function  GetReportFileFr3(FileName: string = ''): string;
    function  Ext: string;
    //установим флаг открытия дизайнера отчетов при печати отчета
    procedure SetDesignReport(Value: Boolean);
    //создадим и заполним датасет (мемтейбл) в качестве источника данных для тела отчета
    //принимает: список полей с указанием типа в виде f1$s;f2$i...  и массив значений
    procedure SetReportDataSet(Fields: string; Values: TVarDynArray);
    //установим значение мемо-поля в репорте
    function  SetMemo(Name, Text: string):Boolean;
    //--------------------------------------------------------------------------
    //процедуры для конкретных отчетов
    procedure D_StdItemsAddCompl;
    procedure pnl_StdItemsAddCompl(Name: string; Id: Integer; Copyes: Integer; Prefix: string = '02');
    procedure D_StdItem;
    procedure pnl_StdItem(ID: Integer; Show: Boolean = True);
    procedure D_Turvl;
    procedure pnl_OrderLabels(Id: Integer; MemTableEh1: TMemTableEh; OrderFields: TVarDynArray);
    procedure D_OrderLabels;
    procedure pnl_Order(Id: Integer);
    procedure pnl_PayrollLabels(MemTableEh1:TMemTableEh);
    //печать сметы;  1-смета на стд изделие или позицию заказа; 2 - объединенная смета
    procedure pnl_Estimate(MemTableEh1:TMemTableEh; Mode: Integer);
    procedure pnl_InvoiceToSgp(MemTableEh1:TMemTableEh);
  end;


var
  PrintReport: TPrintReport;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses
  uErrors
  //,
  //Data.DB
  ;

{$R *.dfm}

constructor TPrintReport.Create;
begin
  inherited Create(Application);
  //будем открывать дизайнер отчетов при запуске из ИДЕ, в противном случае - не будем, сразу печатаем
  //чтобы изменить эту настройку (только на время текущего запуска программы), надо выставить галку в настройках интерфейса
  SetDesignReport(Module.RunFromIDE);
end;

procedure TPrintReport.SetDesignReport(Value: Boolean);
//установим флаг открытия дизайнера отчетов при печати отчета
begin
  FDesignReport:=Value;
end;


function TPrintReport.GetReportFileFr3(FileName: string = ''): string;
begin
  Result:= Module.GetPath_ReportsBase + S.IIf(FileName<>'', '\'  + FileName + Ext, '');
end;

function TPrintReport.Ext: string;
begin
  Result:= '.fr3';
end;

function TPrintReport.SetMemo(Name, Text: string):Boolean;
var
  Memo: TfrxMemoView;
begin
  Memo:=frxReport1.FindObject(Name) as TfrxMemoView;
  Memo.Memo.Clear;
  Memo.Memo.Add(Text);
end;


procedure TPrintReport.D_StdItemsAddCompl;
begin
  frxReport1.LoadFromFile(PrintReport.GetReportFileFr3('Pick_AddCompl'), True);
  frxReport1.DesignReport;
end;

procedure TPrintReport.pnl_StdItemsAddCompl(Name: string; Id: Integer; Copyes: Integer; Prefix: string = '02');
var
  BarCode: TfrxBarCodeView;
  Memo: TfrxMemoView;
  st:string;
  i,j,cnt,pages,lastpage:Integer;
  e: extended;
begin
  if (Name='')or(Copyes<1) then Exit;
  try
  frxReport1.LoadFromFile(GetReportFileFr3('Pick_AddCompl'), True);
  //количество элементов на странице отчета
  cnt:=0;
  while frxReport1.FindObject('BarCode'+inttostr(cnt+1)) <> nil do
    begin
      BarCode:=frxReport1.FindObject('BarCode'+inttostr(cnt+1)) as TfrxBarCodeView;
      BarCode.text:=Prefix + '-' + S.NumToString(ID,12,'0');
      Memo:=frxReport1.FindObject('Memo'+inttostr(cnt+1)) as TfrxMemoView;
      Memo.Memo.Clear;
      Memo.Memo.Add(Name);
      inc(cnt);
    end;
  //количество страниц, включая неполные
  e:=Copyes / cnt;
  if e > trunc(e) then pages:=trunc(e)+1 else pages:=trunc(e);
  //количество этикеток на последней странице
  lastpage:=Copyes - (pages-1) * cnt;
  //создаем отчеты
  for i:=1 to pages do begin
    //для последенй страницы - удалим все элементы сверх количества их на последней странице
    if i = pages then
      for j:= lastpage + 1 to cnt do
        begin
          frxReport1.FindObject('BarCode'+inttostr(j)).Destroy;
          frxReport1.FindObject('Memo'+inttostr(j)).Destroy;
        end;
    //подготавливаем отчет, если не первая страница то прибавляем к предыдущему
    frxReport1.PrepareReport(i = 1);
  end;
  //предпросмотр
  frxReport1.ShowPreparedReport;
  finally
  end;
end;

procedure TPrintReport.D_StdItem;
begin
  frxReport1.LoadFromFile(PrintReport.GetReportFileFr3('Pick_Item'), True);
  frxReport1.DesignReport;
end;

procedure TPrintReport.pnl_StdItem(ID: Integer; Show: Boolean = True);
var
  FieldNames: string;
  BarCode: TfrxBarCodeView;
  Img: TfrxPictureView;
  v: TVarDynArray;
begin
  try
  frxReport1.LoadFromFile(PrintReport.GetReportFileFr3('Pick_Item'), True);
  FieldNames:='id;name;article;colorname;description;wi;di;hi;wp;dp;hp;weight;filepath';
  v:=Q.QSelectOneRow(Q.QSIUDSql('s', 'v_pick_items', FieldNames), [ID]);
  if v[0] = null then begin MyWarningMessage('Это изделие не найдено в базе данных!'); exit; end;
  SetMemo('Наименование',v[1]);
  SetMemo('Артикул',v[2]);
  SetMemo('Цвет',v[3]);
  SetMemo('Описание',v[4]);
  SetMemo('Габариты_изделия', VarToStr(v[5]) + '*' + VarToStr(v[6]) + '*' + VarToStr(v[7]));
  SetMemo('Габариты_упаковки', VarToStr(v[8]) + '*' + VarToStr(v[9]) + '*' + VarToStr(v[10]));
  SetMemo('Вес',v[11]);
  SetMemo('Дата',DateToStr(Date));
  BarCode:=frxReport1.FindObject('BarCode') as TfrxBarCodeView;
  BarCode.text:='01-' + S.NumToString(ID,12,'0');
  Img:=frxReport1.FindObject('Picture1') as TfrxPictureView;
  if S.NSt(v[12])<>'' then begin
    //отключим картинки, тк принтер этикеток не может печатать полутона
//    Img.FileLink:=Module.Pick_FilePath + '\' + S.NSt(v[12]) + '\Изображения\img.jpg';
    Img.FileLink:='';
  end
  else begin
    Img.FileLink:='';
  end;
//Img.FileLink:='\\10.1.1.14\Uchet\Учет\Files\Комплектация\2022-05-15 04.42.08.443\Изображения\img.jpg';
  frxReport1.PrepareReport(True);
  frxReport1.PrintOptions.ShowDialog := False;
  if Show then frxReport1.ShowPreparedReport else frxReport1.Print;
  finally
  end;
end;

procedure TPrintReport.D_Turvl;
var
  Band : TfrxDataBand;
begin
  frxUserDataSet1.Fields.Clear;
  frxUserDataSet1.Fields.Add('fio');
  frxUserDataSet1.Fields.Add('job');
//  frxReport1.
  frxReport1.LoadFromFile(PrintReport.GetReportFileFr3('Turv_1'), True);
  Band := frxReport1.FindObject('MasterData1') as TfrxDataBand;
  Band.DataSet := frxUserDataSet1;
  frxReport1.DesignReport;
end;

procedure TPrintReport.D_OrderLabels;
begin
  frxReport1.LoadFromFile(PrintReport.GetReportFileFr3('OrderLabels'), True);
  frxReport1.DesignReport;
end;

procedure TPrintReport.pnl_OrderLabels(Id: Integer; MemTableEh1: TMemTableEh; OrderFields: TVarDynArray);
var
  BarCode: TfrxBarCodeView;
  Memo: TfrxMemoView;
  st:string;
  i,j,Pages,LastPage,Copyes,QntAll,RecNo,rn: Integer;
  CntOnPage, CurrentItem: Integer;
  e: extended;
  va1, va2: TVarDynArray2;
begin
//  if (Name='')or(Copyes<1) then Exit;
  try
  frxReport1.LoadFromFile(GetReportFileFr3('Заказ (маркировка)'), True);
  //количество элементов на странице отчета
  CntOnPage:=0;
  while frxReport1.FindObject('MOrNum_'+inttostr(CntOnPage+1)) <> nil do
    begin
      inc(CntOnPage);
    end;
  if CntOnPage = 0 then Exit;
  RecNo:=MemTableEh1.RecNo;
  Copyes:=0;
  va2:=[];
  for rn:=1 to MemTableeh1.RecordCount do begin
    MemTableEh1.RecNo:=rn;
st:=MemTableEh1.FieldByName('qnt_p').AsString;
    Copyes:=Copyes + S.VarToInt(MemTableEh1.FieldByName('qnt_p').Value, 0);
    for i:= 1 to S.VarToInt(MemTableEh1.FieldByName('qnt_p').Value, 0) do begin
      va2:=va2 + [[MemTableEh1.FieldByName('slash').AsString, MemTableEh1.FieldByName('itemname').AsString]];
    end;
  end;
//  va2:=QLoadToVarDynArray2('select slash, itemname from v_order_items where id_order = :id_order$i', ID);
  //количество страниц, включая неполные
  e:=Copyes / CntOnPage;
  if e > trunc(e) then pages:=trunc(e)+1 else pages:=trunc(e);
  if Pages > 5 then
    if MyQuestionMessage('Будет напечатано ' + InttoStr(Pages) + ' страниц' + S.GetEnding(Pages, 'а','ы','')+ '.'#13#10'продолжить?') <> mrYes
      then begin
        //frxReport1.Free;
        Exit;
      end;
  //количество этикеток на последней странице
  LastPage:=Copyes - (pages-1) * CntOnPage;
  //создаем отчеты
  rn:=-1;
  for i:=1 to Pages do begin
    //подготавливаем отчет, если не первая страница то прибавляем к предыдущему
    for j:= 1 to CntOnPage do begin
      rn:=rn + 1;
      if rn > High(va2) then Break;
      TfrxMemoView(frxReport1.FindObject('MOrNum_'+inttostr(j))).Memo.Text:=VarToStr(va2[rn][0]);
      TfrxMemoView(frxReport1.FindObject('MItem_'+inttostr(j))).Memo.Text:=VarToStr(va2[rn][1]);
      TfrxMemoView(frxReport1.FindObject('MProject_'+inttostr(j))).Memo.Text:=OrderFields[0];
      TfrxMemoView(frxReport1.FindObject('MPackNo_'+inttostr(j))).Memo.Text:=IntToStr(rn+1);
      TfrxMemoView(frxReport1.FindObject('MPackAll_'+inttostr(j))).Memo.Text:=IntToStr(Copyes);
      //номер буквы + номер заказа (без слеша) + номер упаковки
      st:=
        IntToStr(A.PosInArray(LeftStr(VarToStr(va2[rn][0]),1), ['*','С','Н','М','Ф','О'])) +
        LeftStr(RightStr(VarToStr(va2[rn][0]),10),6)+
        RightStr('000' + IntToStr(rn + 1), 3);
      //для barcode по крайней мере EAN13, задавать текст при пустом expression, иначе заданный текст будет проигнорирован
      //в этом случае под штрихами будет значение текста)
      //но я не знаю что читается сканером, текст или же expression
      TfrxBarCodeView(frxReport1.FindObject('BcBarCode_'+inttostr(j))).Expression:='';
      TfrxBarCodeView(frxReport1.FindObject('BcBarCode_'+inttostr(j))).Text:=st;
//      TfrxBarCodeView(frxReport1.FindObject('BcBarCode_'+inttostr(j))).Expression:='0302230102012';
    end;
    for j:= j to CntOnPage do begin
      TfrxMemoView(frxReport1.FindObject('MOrNum_'+inttostr(j))).Memo.Text:='';
      TfrxMemoView(frxReport1.FindObject('MItem_'+inttostr(j))).Memo.Text:='';
      TfrxMemoView(frxReport1.FindObject('MProject_'+inttostr(j))).Memo.Text:='';
      TfrxMemoView(frxReport1.FindObject('MPackNo_'+inttostr(j))).Memo.Text:='';
      TfrxMemoView(frxReport1.FindObject('MPackAll_'+inttostr(j))).Memo.Text:='';
      TfrxBarCodeView(frxReport1.FindObject('BcBarCode_'+inttostr(j))).Expression:='';
      TfrxBarCodeView(frxReport1.FindObject('BcBarCode_'+inttostr(j))).Text:='';
    end;
    frxReport1.PrepareReport(i = 1);
  end;
  //предпросмотр
  frxReport1.ShowPreparedReport;
  finally
  //frxReport1.Free;
  end;
end;

procedure TPrintReport.pnl_Order(Id: Integer);
//печать паспорта заказа, на основе даннх из БД
begin
  try
  frxDsB.DataSet:=frxQB;
  frxDsT.DataSet:=frxQT;
  frxReport1.LoadFromFile(GetReportFileFr3('ПЗ'), True);
  frxQB.Sql.Text:=
    'select '+
    'ornum, area_short, typename, or_reference, project, customer, address, customerlegal, customerman, account, organization, customercontact, dt_beg, dt_otgr, dt_montage_beg, managername, comm '+
    'from v_orders where id = :id';
  frxQB.Parameters.ParamByName('id').Value:=Id;
  frxQT.Sql.Text:='select pos, slash, itemname, qnt, std, nstd, sgp, r1, r2, r3, r4, r5, r6, r7, resale, kns, thn, comm from v_order_items where id_order = :id_order and qnt > 0 order by pos';
  frxQT.Parameters.ParamByName('id_order').Value:=Id;
  if DesignReport
    then frxReport1.DesignReport
    else begin
      frxReport1.PrepareReport(True);
    //  //предпросмотр
    //  frxReport1.ShowPreparedReport;
      frxReport1.Print;
    end;
  finally
  end;
end;


procedure TPrintReport.pnl_PayrollLabels(MemTableEh1:TMemTableEh);
//печать этикеток на конверты, на основе мемтейбл
begin
  try
  frxReport1.LoadFromFile(GetReportFileFr3('ЗП_Конверты'), True);
  frxDsB.DataSet:=MemTableEh1;
  frxDsT.DataSet:=MemTableEh1;
  if DesignReport
    then frxReport1.DesignReport
    else begin
      frxReport1.PrepareReport(True);
      //предпросмотр
  //  frxReport1.ShowPreparedReport;
      frxReport1.Print;
    end;
  finally
  end;
end;

procedure TPrintReport.pnl_Estimate(MemTableEh1:TMemTableEh; Mode: Integer);
//печать сметы;  1-смета на стд изделие или позицию заказа; 2 - объединенная смета
begin
  try
  if Mode = 1 then frxReport1.LoadFromFile(GetReportFileFr3('Смета'), True);
  if Mode = 2 then frxReport1.LoadFromFile(GetReportFileFr3('Смета общая'), True);
  frxDsB.DataSet:=frxMtB;
  frxDsT.DataSet:=MemTableEh1;
  if DesignReport
    then frxReport1.DesignReport
    else begin
      frxReport1.PrepareReport(True);
      //предпросмотр
  //  frxReport1.ShowPreparedReport;
      frxReport1.Print;
    end;
  finally
  end;
end;

procedure TPrintReport.pnl_InvoiceToSgp(MemTableEh1:TMemTableEh);
begin
  try
  frxReport1.LoadFromFile(GetReportFileFr3('Накладная перемещения на СГП'), True);
  frxDsB.DataSet:=frxMtB;
  frxDsT.DataSet:=MemTableEh1;
  if DesignReport
    then frxReport1.DesignReport
    else begin
      frxReport1.PrepareReport(True);
      //предпросмотр
  //  frxReport1.ShowPreparedReport;
      frxReport1.Print;
    end;
  finally
  end;
end;


procedure TPrintReport.SetReportDataset(Fields: string; Values: TVarDynArray);
//создадим и заполним датасет (мемтейбл) в качестве источника данных для тела отчета
//принимает: список полей с указанием типа в виде f1$s;f2$i...  и массив значений
var
  i, j: Integer;
  vaf, vaf2: TVarDynArray;
begin
  frxMtB.Close;
  frxMtB.FieldDefs.Clear;
  vaf:=A.ExplodeV(Fields, ';');
  for i:=0 to High(vaf) do begin
    vaf2:=A.ExplodeV(vaf[i], '$');
    if Length(vaf2) < 2 then vaf2:=vaf2 + ['s'];
    frxMtB.FieldDefs.Add(vaf2[0], S.Decode([vaf2[1], 'i', ftInteger, 'f', ftFloat, 'd', ftDateTime, ftString]), S.Decode([vaf2[1], 's', 4000, 0]), False);
  end;
  frxMtB.CreateDataSet;
  frxMtB.Append;
  for i:=0 to High(Values) do begin
    frxMtB.Fields[i].Value:= Values[i];
  end;
  frxMtB.Post;
end;



begin
//  PrintReport:= TPrintReport.Create;
end.
