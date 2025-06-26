{
ВВОД данных в ТУРВ по отделу за период
период или с 1 по 15е или с 16го до конца месяца

внутренний массив содержит всегда 16 колонок
имена полей соответствуют колонкам, а не дням месяца!
}

unit F_D_Turv;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, V_MDI, DBGridEhGrouping, ToolCtrlsEh,
  DBGridEhToolCtrls, DynVarsEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh,
  Vcl.ExtCtrls, Vcl.ComCtrls, MemTableDataEh, Data.DB, MemTableEh,
  uString, Vcl.StdCtrls, Math, uDBOra, Vcl.Buttons, DateUtils, Vcl.Mask,
  DBCtrlsEh, uWindows, uData, uLabelColors, Vcl.Menus, Types
 ;

type
  TDlg_TURV = class(TForm_MDI)
    Panel1: TPanel;
    DBGridEh1: TDBGridEh;
    MemTableEh1: TMemTableEh;
    DataSource1: TDataSource;
    DataSource2: TDataSource;
    MemTableEh2: TMemTableEh;
    DBGridEh2: TDBGridEh;
    MemTableEh3: TMemTableEh;
    DataSource3: TDataSource;
    Lb_Title_Worker: TLabel;
    Label2: TLabel;
    P_Left: TPanel;
    P_Center: TPanel;
    Lb_Division: TLabel;
    Timer_AfterUpdate: TTimer;
    Lb_Worker: TLabel;
    PM_2: TPopupMenu;
    N_Comment: TMenuItem;
    N_Premium: TMenuItem;
    N_Penalty: TMenuItem;
    PM_1: TPopupMenu;
    N_Komment_1: TMenuItem;
    N_Premium_1: TMenuItem;
    N_Penelty_1: TMenuItem;
    Bt_Comment: TBitBtn;
    Bt_Premium: TBitBtn;
    Lb_Comment: TLabel;
    Lb_Premium: TLabel;
    P_Right: TPanel;
    Img_Info: TImage;
    N_Night: TMenuItem;
    //основной grid
    procedure DBGridEh1RowDetailPanelShow(Sender: TCustomDBGridEh;
      var CanShow: Boolean);
    procedure DBGridEh1RowDetailPanelHide(Sender: TCustomDBGridEh;
      var CanHide: Boolean);
    procedure DBGridEh1Columns0GetCellParams(Sender: TObject; EditMode: Boolean;
      Params: TColCellParamsEh);
    procedure DBGridEh1CellClick(Column: TColumnEh);
    procedure DBGridEh1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DBGridEh1DataHintShow(Sender: TCustomDBGridEh; CursorPos: TPoint;
      Cell: TGridCoord; InCellCursorPos: TPoint; Column: TColumnEh;
      var Params: TDBGridEhDataHintParams; var Processed: Boolean);
    procedure DBGridEh1HintShowPause(Sender: TCustomDBGridEh; CursorPos: TPoint;
      Cell: TGridCoord; InCellCursorPos: TPoint; Column: TColumnEh;
      var HintPause: Integer; var Processed: Boolean);
    procedure DBGridEh1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell,
      AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect;
      var Params: TColCellParamsEh; var Processed: Boolean);
    procedure DBGridEh1CellMouseClick(Grid: TCustomGridEh; Cell: TGridCoord;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      var Processed: Boolean);
    procedure DBGridEh1ColEnter(Sender: TObject);
    procedure DBGridEh1KeyPress(Sender: TObject; var Key: Char);
    //grid2 rowdetail
    procedure DBGridEh2ColEnter(Sender: TObject);
    procedure DBGridEh2DblClick(Sender: TObject);
    procedure DBGridEh2Columns0GetCellParams(Sender: TObject;
      EditMode: Boolean; Params: TColCellParamsEh);
    procedure DBGridEh2Columns0UpdateData(Sender: TObject; var Text: string;
      var Value: Variant; var UseText, Handled: Boolean);
    procedure DBGridEh2Columns1GetCellParams(Sender: TObject; EditMode: Boolean;
      Params: TColCellParamsEh);
    procedure DBGridEh2Columns1UpdateData(Sender: TObject; var Text: string;
      var Value: Variant; var UseText, Handled: Boolean);
    procedure DBGridEh2AdvDrawDataCell(Sender: TCustomDBGridEh; Cell,
      AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect;
      var Params: TColCellParamsEh; var Processed: Boolean);
    procedure DBGridEh2DataHintShow(Sender: TCustomDBGridEh; CursorPos: TPoint;
      Cell: TGridCoord; InCellCursorPos: TPoint; Column: TColumnEh;
      var Params: TDBGridEhDataHintParams; var Processed: Boolean);
    procedure DBGridEh2CellMouseClick(Grid: TCustomGridEh; Cell: TGridCoord;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      var Processed: Boolean);
    procedure DBGridEh2CellClick(Column: TColumnEh);
    //MemTableEh1
    procedure MemTableEh1AfterScroll(DataSet: TDataSet);
    //MemTableEh2
    procedure MemTableEh2AfterScroll(DataSet: TDataSet);
    procedure MemTableEh2AfterEdit(DataSet: TDataSet);
    //прочие контролы
    procedure Bt_Click(Sender: TObject);
    procedure Timer_AfterUpdateTimer(Sender: TObject);
    procedure N_PremiumClick(Sender: TObject);
    procedure N_PenaltyClick(Sender: TObject);
    procedure N_CommentClick(Sender: TObject);
    procedure N_Komment_1Click(Sender: TObject);
    procedure N_Premium_1Click(Sender: TObject);
    procedure N_Penelty_1Click(Sender: TObject);
    procedure N_NightClick(Sender: TObject);
    procedure Bt_CommentClick(Sender: TObject);
    procedure Bt_PremiumClick(Sender: TObject);
    //форма
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
 private
    { Private declarations }
    DayColWidth: Integer;
    RowHeight: Integer;
    TurvCodes, TurvCodesIds, TurvCodesSt: TStrings;
    ViewMode: Integer;
    IsCommited:Boolean;    //период закрыт
    InEditMode: Boolean;   //можно вводить данные
    EditInGrid1: Boolean;  //ввод данных времени руководителя в основной сетке
    RgsCommit, RgsEdit1, RgsEdit2, RgsEdit3: Boolean;  //права
    ArrTitle: TVarDynArray2;
    ArrTurv: array of array of array of Variant;
    InLoad: Boolean;
    PeriodStartDate, PeriodEndDate: TDateTime;
    DayColumnsCount: byte; //Сколько колонок отображено из 16-ти
    ID_Division: Integer;
    DivisionName: string;
    EditUsers: string;         //кто редактирует турв, айди пользователей через запятую
    IsDetailGridUpd: Boolean;  //устанавливается в событии апдейт данных грида, указывает какой грид обновлен
    Buttons: TmybtArr;             //массив кнопок TmybnRec
    ButtonsState: TVarDynArray;    //массив статусов видимости кнопок
    TurvCodeVyh: Integer;
    IsOffice: Boolean;
    Status, StatusOld: Integer;
    DbLockSet: Boolean;        //флаг что блокировка получена
    function  Prepare: Boolean; override;
    procedure LoadTurvCodes;
    function  GetTurvCode(v: Variant): Variant;
    function  GetTurvCell(r,d,n:Integer): Variant;
    procedure SetBtns;
    procedure SetView;
    function  LoadTurv: Boolean;
    procedure SetTurvAllDay(r, d: Integer);
    procedure SetTurvRowDetail(r, d: Integer);
    procedure SaveDayToDB(r, d: Integer; Mode: Integer);
    procedure SaveWorkerToDB(r: Integer);
    procedure PrintCurrentWorker;
    function  FormatTurvCell(v: Variant): string;
    procedure InputPremium(IsDetailGrid: Boolean; Mode: Integer);
    procedure InputComment(IsDetailGrid: Boolean; Mode: Integer);
    procedure SetRowDetailCaptions;
    function  GetDayNo(IsDetailGrid: Boolean): Integer;
    procedure ExportToXlsxA7(Doc: Integer; Date1, Date2: Variant; AutoOpen: Boolean);
    procedure ImporFromParsec(FileeName: string);
    procedure SundaysToTurv;
    procedure SendEMailToHead;
  public
    { Public declarations }
//    procedure MyShowHint(var HintStr: string; var CanShow: Boolean; var HintInfo: THintInfo);
    constructor ShowDialog(aOwner: TComponent; aFormDoc: string; aMode: TDialogType; aID: Variant; AMyFormOptions: TMyFormOptions);
  end;

var
  Dlg_TURV: TDlg_TURV;

implementation

uses
  uTurv,
  uForms,
  uMessages,
  uSettings,
  D_TURV_Comment,
  D_TURV_FromParsec,
  uExcel,
  XlsMemFilesEh,
  uPrintReport,
  uFrmBasicInput
  ;

const
  atExists = 0;
  atTRuk = 1;               //время от мастеров
  atTPar =2;                //время парсек
  atTSogl = 3;              //время согласованное
  atCRuk = 4;               //код руководителя
  atCPar = 5;               //код парсек
  atCSog = 6;               //код согласованный
  atSumPr = 7;              //сумма премии
  atComPr = 8;              //комментарий к премии
  atSumSct = 9;             //сумма штрафа
  atComSct = 10;            //комментарий к штрафу
  atVyr = 11;               //сдана ли выработка
  atColor = 12;             //цвет фона
  atColorF = 13;            //цвет шрифта
  atComRuk = 14;            //комментарий руководителя
  atComPar = 15;            //комментарий парсека
  atComSogl = 16;           //ко мментрий по согласованному
  atBegTime = 17;           //время прихода по парсеку
  atEndTime = 18;           //время ухода по парсеку
  atSetTime = 19;           //если 1, то ячейка подсвечивается. устанавливается в 1 если нет одного из времен или работник по цеху вышел раньше. сбрасывается при вводе значения в парсек вручную          нет!!! - 1, когда время по парсеку worktime2 установлено
  atNight = 20 ;            //время в часах в ночную смену
  atItog = 21;              //итоговая строка, которая отображается


{$R *.dfm}

function TDlg_TURV.LoadTurv: Boolean;
var
  i,j,k:Integer;
  v, vs: TVarDynArray2;
  v2: TVarDynArray;
  v1: Variant;
  dt, dt1, dtbeg, dtend: TDateTime;
  y, m: Integer;
  res: Integer;
  st: string;
begin
  //получим список работников для данного турв
//  v1:=Turv.GetTurvArray(id_division, PeriodStartDate);
  v:=[]; vs:=[]; v2:=[];
  ArrTitle:=[];
  ArrTurv:=[];
  v:=Turv.GetTurvArrayFromDb(id_division, PeriodStartDate);
  Result:=Length(v) > 0;
  if not Result then Exit;
  //проходим по списку
  for i:= 0 to High(v) do begin
   //v:  0-дата1, 1-дата2, 2-айди работника, 3-имя работника, 4-фйди профессии, 5-назавание профессии, 6-после периода: 1=переведен 2=уволен
    SetLength(ArrTitle, i+1, 7);
    SetLength(ArrTurv, i+1, 31, atItog + 1);
    //массив заголовков (работник, должность...)
    ArrTitle[i][0]:=v[i][2];  //id worker
    ArrTitle[i][1]:=v[i][4];  //id job
    ArrTitle[i][2]:=v[i][3];  //workername
    ArrTitle[i][3]:=v[i][5];  //job
    ArrTitle[i][4]:='';       //category
    ArrTitle[i][5]:=0;        //премия за отчетный период
    ArrTitle[i][6]:='';       //комментатрий, общий для работника
    //читаем турв_дей в для данного работника в промежутке, в котором он в этом ТУРВ, сортируем по дате
    vs:=Q.QLoadToVarDynArray2('select '+
      'dt, worktime1, worktime2, worktime3, id_turvcode1, id_turvcode2, id_turvcode3, premium, premium_comm, penalty, penalty_comm, production, '+
      'null, null, comm1, comm2, comm3, begtime, endtime, settime3, nighttime '+
      ' from turv_day where id_worker = :id_worker$i and dt >= :dtbeg$d and dt <= :dtend$d order by dt',
    [ArrTitle[i][0], v[i][0], v[i][1]]);
    //проход по массиву турв
    for j:=1 to 16 do begin
      //заполним нулл
      for k:=0 to atItog do ArrTurv[i][j][k] := null;
      if (IncDay(PeriodStartDate, j-1) < v[i][0]) or (IncDay(PeriodStartDate, j-1) > v[i][1])
        //если меньше начально или больше конечной даты, то признак что данной клетки в турв нет
        then ArrTurv[i][j][0] := -1
        else begin
          //клетка есть в турв, но нет в бд /передлка 2023-08 - теперь не нужно, всегда есть в бд/
          ArrTurv[i][j][atExists] := 0;
          for k:=0 to High(vs) do
            if DayOf(vs[k][0]) = DayOf(PeriodStartDate) + j - 1 then begin
              //клетка есть в турв и бд
              ArrTurv[i][j][atExists]:=1;    //id
              ArrTurv[i][j][atTRuk]:=vs[k][1];    //время от мастеров
              ArrTurv[i][j][atTPar]:=vs[k][2];    //время парсек
              ArrTurv[i][j][atTSogl]:=vs[k][3];    //время согласованное
              ArrTurv[i][j][atCRuk]:=vs[k][4];    //код от мастеров
              ArrTurv[i][j][atCPar]:=vs[k][5];    //код от парсек
              ArrTurv[i][j][atCSog]:=vs[k][6];    //код согласованное
              ArrTurv[i][j][atSumPr]:=vs[k][7];    //сумма премии
              ArrTurv[i][j][atComPr]:=vs[k][8];     //комментарий к премии
              ArrTurv[i][j][atSumSct]:=vs[k][9];    //сумма штрафа
              ArrTurv[i][j][atComSct]:=vs[k][10];     //комментарий к штрафу
              ArrTurv[i][j][atVyr]:=vs[k][11];    //сдана ли выработка
              ArrTurv[i][j][atComRuk]:=vs[k][14];    //комментарий руководителя
              ArrTurv[i][j][atComPar]:=vs[k][15];    //комментрий по парсеку
              ArrTurv[i][j][atComSogl]:=vs[k][16];    //комментрий по согласованному
              ArrTurv[i][j][atBegTime]:=vs[k][17];    // время прихода по парсеку
              ArrTurv[i][j][atEndTime]:=vs[k][18];    //время ухода по парсеку
              ArrTurv[i][j][atSetTime]:=vs[k][19];    //1, когда время по парсеку worktime2 установлено
              ArrTurv[i][j][atNight]:= vs[k][20];    //время в ночную смену
            end;
//          if ArrTurv[i][j][atExists] = 0
//            then k:=0;
        end;
    end;
    //прочитаем из БД премии и штрафы
{    vs:=QLoadToVarDynArray2('select premium, comm from turv_worker1 where '+
      'id_worker = :id_worker1$i and id_division = :id_division1$i and id_job = :id_job1$i and dt = :dt1$d',
      VarArrayOf([ArrTitle[i][0], ID_Division, ArrTitle[i][1], PeriodStartDate])
    );}
    vs:=Q.QLoadToVarDynArray2('select premium, comm from turv_worker where '+
      'id_worker = :id_worker$i and id_division = :id_division$i and id_job = :id_job$i and dt1 = :dt1$d',
      [ArrTitle[i][0], ID_Division, ArrTitle[i][1], PeriodStartDate]
    );
    if Length(vs) > 0 then begin
      ArrTitle[i][5]:=vs[0][0];
      ArrTitle[i][6]:=vs[0][1];
    end;
  end;
end;


procedure TDlg_TURV.SaveDayToDB(r, d: Integer; Mode: Integer);
//сохраняем в бд переданную ячейку
//при режиме 0 сохраняем все, иначе atTRuk - данные руководителя, и так же парсек, согласованное
//передается номер столбца!! а не день месяца!
var
  v: TVarDynArray;
  res, i: Integer;
  dt: TDateTime;
  fields, st: string;
begin
  //ячейки нет в этом турв - выход
  if ArrTurv[r][d][0] = -1 then Exit;
  //занесем данные
  fields:='';
  v:=[];
  if (Mode in [atTRuk, 0]) then begin
    v:=[
      ArrTurv[r][d][atTRuk],
      ArrTurv[r][d][atCRuk],
      ArrTurv[r][d][atComRuk],
      ArrTurv[r][d][atVyr],
      ArrTurv[r][d][atSumPr],
      ArrTurv[r][d][atComPr],
      ArrTurv[r][d][atSumSct],
      ArrTurv[r][d][atComSct]
    ];
    S.ConcatStP(fields, 'worktime1$f;id_turvcode1$i;comm1$s;production$i;premium$f;premium_comm$s;penalty$f;penalty_comm$s', ';');
  end;
  if (Mode in [atTPar, 0]) then begin
    v:=v + [
      ArrTurv[r][d][atTPar],
      ArrTurv[r][d][atCPar],
      ArrTurv[r][d][atComPar],
      ArrTurv[r][d][atBegTime],
      ArrTurv[r][d][atEndTime],
      ArrTurv[r][d][atSetTime],
      ArrTurv[r][d][atNight]
    ];
    S.ConcatStP(fields, 'worktime2$f;id_turvcode2$i;comm2$s;begtime$f;endtime$f;settime3$i;nighttime$f', ';');
  end;
  if (Mode in [atTSogl, 0]) then begin
    v:=v + [
      ArrTurv[r][d][atTSogl],
      ArrTurv[r][d][atCSog],
      ArrTurv[r][d][atComSogl]
    ];
    S.ConcatStP(fields, 'worktime3$f;id_turvcode3$i;comm3$s', ';');
  end;
{  if (Mode in [atSumPr, 0]) then begin
    v:=v + [
      ArrTurv[r][d][atSumPr],
      ArrTurv[r][d][atComPr]
    ];
    S.ConcatStP(fields, 'premium$f;premium_comm$s', ';');
  end;
  if (Mode in [atSumSct, 0]) then begin
    v:=v + [
      ArrTurv[r][d][atSumSct],
      ArrTurv[r][d][atComSct]
    ];
    S.ConcatStP(fields, 'penalty$f;penalty_comm$s', ';');
  end;}
  v:=v + [
    ArrTitle[r][0],
    IncDay(PeriodStartDate, d-1)
  ];
  //запишем данные в основную таблицу
  st:=Q.QSIUDSql('Q', 'turv_day', fields) + ' where id_worker = :id_worker$i and dt = :dt$d';
  Res:=Q.QExecSQL(st, v);
  //запишем статус в таблицу периодов - сейчас некорректно тк в турв может изменять данные несколько человек
  if StatusOld<>Status then begin
    Res:=Q.QExecSQL(
      'update turv_period set status = :status$i where id_division = :id$i and dt1 = :dt1$d',
      [Status, ID_Division, PeriodStartDate]
    );
    StatusOld:= Status;
  end;

  {
  if ArrTurv[r][d][0] <> 1 then begin
    //ячейка не была прочитана из БД - создадим запись
    v:=[
      ArrTitle[r][0],
      IncDay(PeriodStartDate, d-1)
    ];
    Res:=QExecSQL('insert into turv_day (id_worker, dt) values (:id_worker$i, :dt$d)', v, False);
    ArrTurv[r][d][0] := 1;
  end;
  //занесем данные
  v:=[
    ID_Division,
    ArrTurv[r][d][atTRuk],
    ArrTurv[r][d][atCRuk],
    ArrTurv[r][d][atTPar],
    ArrTurv[r][d][atCPar],
    ArrTurv[r][d][atTSogl],
    ArrTurv[r][d][atCSog],
    ArrTurv[r][d][atSumPr],
    ArrTurv[r][d][atComPr],
    ArrTurv[r][d][atSumSct],
    ArrTurv[r][d][atComSct],
    ArrTurv[r][d][atVyr],
    ArrTurv[r][d][atComRuk],
    ArrTurv[r][d][atComPar],
    ArrTurv[r][d][atComSogl],
    ArrTurv[r][d][atBegTime],
    ArrTurv[r][d][atEndTime],
    ArrTurv[r][d][atSetTime],

    ArrTitle[r][0],
    IncDay(PeriodStartDate, d-1)
  ];
  Res:=QExecSQL('update turv_day set '+
    'id_division = :id_division$i, '+
    'worktime1 = :worktime1$f, '+
    'id_turvcode1 = :id_turvcode1$f, '+
    'worktime2 = :worktime2$f, '+
    'id_turvcode2 = :id_turvcode2$f, '+
    'worktime3 = :worktime3$f, '+
    'id_turvcode3 = :id_turvcode3$f, '+
    'premium = :premium$f, '+
    'premium_comm = :premium_comm$s, '+
    'penalty = :penalty$f, '+
    'penalty_comm = :penalty_comm$s, '+
    'production = :prodaction$i, '+
    'comm1 = :comm1$s, '+
    'comm2 = :comm2$s, '+
    'comm3 = :comm3$s, '+
    'begtime = :begtime$f, '+
    'endtime = :endtime$f, '+
    'settime3 = :settime3$i '+
    'where id_worker = :id_worker$i and dt = :dt$d',
  v);
  }
end;


procedure TDlg_TURV.SaveWorkerToDB(r: Integer);
//сохраним данные по строке турв (для данной строки работника) - пока премия и комментарий
var
  i: Integer;
begin
{  QExecSql('insert into turv_worker1 (id_worker, id_division, id_job, dt) '+
    'select :id_worker$i, :id_division$i, :id_job$i, :dt$d from dual where not exists '+
    '(select 1 from turv_worker1 where '+
    'id_worker = :id_worker1$i and id_division = :id_division1$i and id_job = :id_job1$i and dt = :dt1$d)',
    VarArrayOf([ArrTitle[r][0], ID_Division, ArrTitle[r][1], PeriodStartDate, ArrTitle[r][0], ID_Division, ArrTitle[r][1], PeriodStartDate])
  );
  QExecSql('update turv_worker1 set premium = :premium$f, comm = :comm$s '+
    'where id_worker = :id_worker$i and id_division = :id_division$i and id_job = :id_job$i and dt = :dt$d',
    VarArrayOf([ArrTitle[r][5], ArrTitle[r][6], ArrTitle[r][0], ID_Division, ArrTitle[r][1], PeriodStartDate])
  );}
  Q.QExecSql('update turv_worker set premium = :premium$f, comm = :comm$s '+
    'where id_worker = :id_worker$i and id_division = :id_division$i and id_job = :id_job$i and dt1 = :dt$d',
    [ArrTitle[r][5], ArrTitle[r][6], ArrTitle[r][0], ID_Division, ArrTitle[r][1], PeriodStartDate]
  );
end;



//отобразим ячейку в общем гриде на основании массива данных
procedure TDlg_TURV.SetTurvAllDay(r, d: Integer);
var
  st:string;
  v,v0,v1,v2,v3,v4: Variant;
  color: Integer;
  i,j: Integer;
  sum: TVarDynArray;
  e: extended;
  b: Boolean;
{
   если протавлено любое значение в проверенных, то выводится оно, независимо от значения и наличия данных от мастера и парсек
   в противном случае, значение от мастера обязательно должно быть проставлено
   при этом, если не проставлено значение парсек, выводится значение от мастера и жетый фон
   если проставлено время парсек, и разница во времени парсек и мастера менее часа, то выводится время парсек
   если проставлен код парсек, то выводится код парсек, перекрывая значение мастера
   но если протавлены данные и мастера и парсек, при этом одно из них время а другое код, или оба времена, но отличаются болле часа,
   то хоть выводится парсек, но цвет красный, требует согласования
}
begin
//exit;
//  можно делать так или так, но таблица должна находиться в состоянии изменения
//  DbGridEh1.FieldColumns['d'+ IntToStr(d)].Field.Value:=ArrTurv[DBGridEh1.Row][d][1];
//  MemTableEh1.FieldByName('d'+ IntToStr(d)).Value:=ArrTurv[r][d][1];
v:=ArrTurv[r][d][0];
  //получим автоматически номер активной строки грида
  if r = -1 then r:=MemTableEh1.RecNo-1;

//  if ArrTurv[r][d][0] <> 1 then begin //иначе данные не загружены в ячейку, и не могут быть изменены

    v0:=GetTurvCell(r,d,3);  //проверенное время или код
    v1:=GetTurvCell(r,d,1);  //время или код от мастеров
    v2:=GetTurvCell(r,d,2);  //время или код парсек
    color:=0;
    //если задано проверенное время/код, то выводим его, иначе выводим от мастеров
    if v0 = null then begin
      if (v1 = null)and(v2 = null)
        then begin
          color:=0;
        end
        else if (v1<>null)and(v2=null)
        then begin
          color:=2;   //жетлтый
          v0:=v1;
        end
        else if (v1 = null)and(v2 <> null)
        then begin
          color:=1;   //красный
          v0:=v2;
        end
        else if (not S.IsNumber(S.NSt(v1),0,24)) and (not S.IsNumber(S.NSt(v2),0,24))
        then begin
          v0:=v2;
        end
        else if S.IsNumber(S.NSt(v1),0,24) and S.IsNumber(S.NSt(v2),0,24) and (abs(StrToFloat(S.NSt(v1)) - StrToFloat(S.NSt(v2))) <= Module.GetCfgVar(mycfgWtime_autoagreed))
        then begin
          v0:=v2;
          if v1 <> v2 then color:=-1; //красный цвет шрифта
        end
        else begin
          v0:=v2;
          color := 1;
        end;
    end;
{
if v1 = '5,5' then begin
  b:= S.IsNumber(S.NSt(v1),0,24) ;
  st:= VarToStr(S.NSt(v1));
  v4:=GetTurvCell(r,d,1);
end;
}
    ArrTurv[r][d][atColor]:=color;
    //при редактировании в основном гриде будем отображать в нем время от мастеров/руководителя
    if (EditInGrid1)and(InEditMode) then v0:=v1;
    //форматируем строку, если число
    if S.IsNumber(S.NSt(v0),0,24) then st:=FormatFloat('0.00', S.VarToFloat(v0)) else st:=S.NSt(v0);
    //изменим напрямую во внутреннем массиве данных
    //при этом на экране отображения только после получения гридом фокуса, переключение фокуса оставляем за вызывающим
    MemTableEh1.RecordsView.MemTableData.RecordsList[r].DataValues['d'+ IntToStr(d),dvvValueEh]:=st;
//end;
//exit;

  //итоги в правой части таблицы
  Setlength(sum, 3);
  b:=True;
  //цикл по дням
  for i:=1 to DayColumnsCount do
    begin
      //время - от мастеров, если установлено парсек то парсек, если установлено согласованное то оно
      e:= S.NNum(ArrTurv[r][i][1]);
      if (ArrTurv[r][i][2] <> null) or (ArrTurv[r][i][5] <> null) then e := S.NNum(ArrTurv[r][i][2]);
      if (ArrTurv[r][i][3] <> null) or (ArrTurv[r][i][6] <> null) then e := S.NNum(ArrTurv[r][i][3]);
      sum[0] := sum[0] + e;
      sum[1] := sum[1] + S.NNum(ArrTurv[r][i][7]);
      sum[2] := sum[2] + S.NNum(ArrTurv[r][i][9]);
      //ячейки красные и желтые, или пустые итоговые и при этом не серые - не даем возможности закрыть турв
      if (S.NNum(ArrTurv[r][i][12]) = 1)or(S.NNum(ArrTurv[r][i][12]) = 2)or
         ((ArrTurv[r][i][0] <> -1) and (ArrTurv[r][i][1]) = null)
        then b:=False;
    end;
  //заполним итоговые ячейки мемтейбл
  MemTableEh1.RecordsView.MemTableData.RecordsList[r].DataValues['time', dvvValueEh]:=FormatFloat('0.00', S.NNum(sum[0]));
  MemTableEh1.RecordsView.MemTableData.RecordsList[r].DataValues['premium_p', dvvValueEh]:=FormatFloat('0.00', S.NNum(ArrTitle[r][5]));
  MemTableEh1.RecordsView.MemTableData.RecordsList[r].DataValues['premium', dvvValueEh]:=FormatFloat('0.00', S.NNum(sum[1]));
  MemTableEh1.RecordsView.MemTableData.RecordsList[r].DataValues['penalty', dvvValueEh]:=FormatFloat('0.00', S.NNum(sum[2]));
  //кнопка Закрыть период
  Status:=1;
  for j:= 0 to High(ArrTurv) do begin
    for i:=1 to DayColumnsCount do
      begin
        if (ArrTurv[j][i][atColor] = -1)and(Status = 1) then Status:=2;
        if ArrTurv[j][i][atColor] = 1 then Status:=3;
        if Status = 3 then break
      end;
    if Status = 3 then break
  end
  //Bt_Commit.Enabled:=b; //!!!
end;


//отобразим ячейку в общем гриде на основании массива данных
procedure TDlg_TURV.SetTurvRowDetail(r, d: Integer);
var
  st:string;
  v,v1,v2,v3: Variant;
  color, i: Integer;
begin
  //получим автоматически номер активной строки грида
  if r = -1 then r:=MemTableEh1.RecNo-1;
  //клетка не входит в данный турв
//  if VarType(ArrTurv[r][d][0]) <> varInteger then exit;
  if ArrTurv[r][d][0] = -1 then begin
    //сделаем все пустые и выйдем
    for i:=0 to 4 do
      MemTableEh2.RecordsView.MemTableData.RecordsList[i].DataValues['d'+ IntToStr(d),dvvValueEh]:=null;
    exit;
  end;
  //изменим напрямую во внутреннем массиве данных
  //при этом на экране отображения только после получения гридом фокуса, переключение фокуса оставляем за вызывающим
  v1:=GetTurvCell(r,d,1);
  v2:=GetTurvCell(r,d,2);
  v3:=GetTurvCell(r,d,3);
  //форматируем строку, если число
  if S.IsNumber(S.NSt(v1),0,24) then st:=FormatFloat('0.00', S.VarToFloat(v1)) else st:=S.NSt(v1);
  MemTableEh2.RecordsView.MemTableData.RecordsList[0].DataValues['d'+ IntToStr(d),dvvValueEh]:=st;
  if S.IsNumber(S.NSt(v2),0,24) then st:=FormatFloat('0.00', S.VarToFloat(v2)) else st:=S.NSt(v2);
  MemTableEh2.RecordsView.MemTableData.RecordsList[1].DataValues['d'+ IntToStr(d),dvvValueEh]:=st;
  if S.IsNumber(S.NSt(v3),0,24) then st:=FormatFloat('0.00', S.VarToFloat(v3)) else st:=S.NSt(v3);
  MemTableEh2.RecordsView.MemTableData.RecordsList[2].DataValues['d'+ IntToStr(d),dvvValueEh]:=st;
  //премии и штрафы
  if (ArrTurv[r][d][atSumPr] <> null) then begin
    st:= FormatFloat('0', S.NNum(ArrTurv[r][d][atSumPr]));// + '    ' + S.NSt(ArrTurv[r][d][8]);
    MemTableEh2.RecordsView.MemTableData.RecordsList[3].DataValues['d'+ IntToStr(d),dvvValueEh]:=st;
  end
  else MemTableEh2.RecordsView.MemTableData.RecordsList[3].DataValues['d'+ IntToStr(d),dvvValueEh]:=null;
  if (ArrTurv[r][d][atSumSct] <> null) then begin
    st:= FormatFloat('0', S.NNum(ArrTurv[r][d][atSumSct]));// + '    ' + S.NSt(ArrTurv[r][d][10]);
    MemTableEh2.RecordsView.MemTableData.RecordsList[4].DataValues['d'+ IntToStr(d),dvvValueEh]:=st;
  end
  else MemTableEh2.RecordsView.MemTableData.RecordsList[4].DataValues['d'+ IntToStr(d),dvvValueEh]:=null;
  //выработка
//  if ArrTurv[r][d][11] = 1 then st:='есть' else st:='';
//  MemTableEh2.RecordsView.MemTableData.RecordsList[5].DataValues['d'+ IntToStr(d),dvvValueEh]:=st;
end;

//установим отображение всего турва или первой/второй половины
procedure TDlg_TURV.SetView;
var
  i, j: Integer;
begin
exit;
  j:=4;
  for i:=1 to 31 do
    begin
      DBGridEh1.Columns[i+j-1].Visible:=(ViewMode = 0) or ((ViewMode = 1) and (i <= 15)) or ((ViewMode = 2) and (i > 15));
    end;
  DBGridEh1.Columns[4+31+0].Visible:= (ViewMode = 0) or (ViewMode = 1);
  DBGridEh1.Columns[4+31+1].Visible:= (ViewMode = 0) or (ViewMode = 1);
  DBGridEh1.Columns[4+31+2].Visible:= (ViewMode = 0) or (ViewMode = 1);
  DBGridEh1.Columns[4+31+3].Visible:= (ViewMode = 0) or (ViewMode = 2);
  DBGridEh1.Columns[4+31+4].Visible:= (ViewMode = 0) or (ViewMode = 2);
  DBGridEh1.Columns[4+31+5].Visible:= (ViewMode = 0) or (ViewMode = 2);
  j:=1;
  for i:=1 to 31 do
    begin
      DBGridEh2.Columns[i+j-1].Visible:=(ViewMode = 0) or ((ViewMode = 1) and (i <= 15)) or ((ViewMode = 2) and (i > 15));
//      DBGridEh3.Columns[i+j-1].Visible:=(ViewMode = 0) or ((ViewMode = 1) and (i <= 15)) or ((ViewMode = 2) and (i > 15));
    end;
  SetBtns;
end;

//установим стутусы, подписи кнопок и заголовок
procedure TDlg_TURV.SetBtns;
var
  st, stc: string;
begin
  Self.Caption:='ТУРВ';
  //если турв был открыт на реадктирование, то редактируемость установим = не закрыт, и блокировок не делаем, ту она уже взята при открытии турв
  //если же был в режиме просмотра, то в режим редактирования не переходим
  InEditMode:=(Mode = fEdit) and (not IsCommited);
  //если не редактирование, и не права на ввод времени руководителя - сбросим режим ввода в основной сетке.
  if not(InEditMode and RgsEdit1) then EditInGrid1:=False;
  DBGridEh1.ReadOnly:=not (InEditMode and EditInGrid1);
  Cth.GetSpeedBtn(P_Left, btnView).Hint:='Итоговое время';
  Cth.GetSpeedBtn(P_Left, btnView).Enabled:=EditInGrid1 and InEditMode;
  Cth.GetSpeedBtn(P_Left, btnEdit).Hint:='Ввод времени руководителя';
  Cth.GetSpeedBtn(P_Left, btnEdit).Enabled:=not EditInGrid1 and InEditMode and RgsEdit1;
  Cth.GetSpeedBtn(P_Left, btnCustom_FromParsec).Hint:='Загрузить данные парсек';
  Cth.GetSpeedBtn(P_Left, btnCustom_FromParsec).Enabled:= RgsEdit2 and InEditMode;
  Cth.GetSpeedBtn(P_Left, btnSendEMail).Enabled:= RgsEdit2 and InEditMode;
  Cth.GetSpeedBtn(P_Left, btnCustom_SundaysToTurv).Enabled:= InEditMode;
  //видимость кнопки Завершить период (она одна и завершает и отменяет завершение)
  //должны быть права
  //а также или режим редактирования исходный, или видна только в случае уже Завершенного периода, те позволит при просмотре только снять завершение, но не выставить
  //(так как тогда надо делать блокировку при установке завершения, ведь при просмотре может быть турв открыта у кого-то на редактирование!)
  Cth.GetSpeedBtn(P_Left, btnLock).Enabled:=RgsCommit and (IsCommited or (Mode = fEdit));
  Cth.GetSpeedBtn(P_Left, btnLock).Hint:=S.IIFStr(IsCommited, 'Отменить закрытие периода', 'Закрыть период');
  if (InEditMode)and(EditInGrid1) then begin
    st:='Ввод времени руководителя';
    stc:='$FF0060';
  end
  else if (InEditMode)and(not EditInGrid1) then begin
    st:='Ввод данных';
    stc:='$FF00FF';
  end
  else if IsCommited then begin
    st:='Только просмотр, период закрыт';
    stc:='$0000FF';
  end
  else begin
    st:='Только просмотр';
    stc:='$009000';
  end;
  Lb_Division.ResetColors;
  Lb_Division.SetCaptionAr([
    '$000000', 'Подразделение: ', '$FF0000', DivisionName,
    '$000000', '   Период с ', '$FF0000',  DateToStr(PeriodStartDate), '$000000 по $FF0000', DateToStr(PeriodEndDate),
    '$000000      [', stc, st, '$000000]'
    ]);
end;


//загрузим справочник кодов турв
procedure TDlg_TURV.LoadTurvCodes;
begin
  TurvCodes:=TStringList.Create;
  TurvCodesIds:=TStringList.Create;
  TurvCodesSt:=TStringList.Create;
  Q.QOpen('select id, code, name from ref_turvcodes order by code', []);
  TurvCodeVyh:=-1;
  while not Q.AdoQuery.EOF do
    begin
      //id
      TurvCodesIds.Add(Q.AdoQuery.Fields[0].AsString);
      //коды
      TurvCodes.Add(Q.AdoQuery.Fields[1].AsString);
      if Q.AdoQuery.Fields[1].AsString = 'В' then TurvCodeVyh:=Q.AdoQuery.Fields[0].AsInteger;
      //стороки код - расшифровка
      TurvCodesSt.Add(Q.AdoQuery.Fields[1].AsString + ' - ' + Q.AdoQuery.Fields[2].AsString);
      Q.AdoQuery.Next;
    end;
  Q.QClose;
end;

//нажатие на кнопку
procedure TDlg_TURV.Bt_Click(Sender: TObject);
var
  bt, rn, i, j: Integer;
  dt: TDateTime;
  b: Boolean;
  va: TVarDynArray;
  st, st1, st2, st3: string;
begin
  inherited;
  //получим тэг кнопки
  bt:=TBitBtn(Sender).Tag;
  //кнопки ввода времни руководителя/ввода итогов
  if bt = btnEdit then EditInGrid1:=True;
  if bt = btnView then EditInGrid1:=False;
  if bt in [btnView, btnEdit] then begin
    rn:=MemTableEh1.RecNo;
    for i := 1 to MemTableEh1.RecordCount do begin
      MemTableEh1.RecNo:=i;
      for j:=1 to 16 do begin
        SetTurvAllDay(i-1, j);
      end;
    end;
    MemTableEh1.RecNo:=rn;
    DBGridEh1.Refresh;
  end;
  //кнопка закрытия периода
  if bt = btnLock then begin
    if Not IsCommited then
      //если период не закрыть, то проверим, можно ли его закрыть
      if Turv.GetStatus(ID_Division, PeriodStartDate) = -1
        then begin MyInfoMessage('В этом ТУРВ введены не все данные, закрыть его нельзя!'); Exit; end;
    if MyQuestionMessage(S.IIFStr(IsCommited,
      'Вы уверены, что хотите снять статус "Закрыт" с этого ТУРВ?',
      'Вы уверены, что хотите отметить этот ТУРВ как "Закрыт"?'#13#10'В этом случае ввод данных в него будет невозможен!')
    ) <> mrYes then Exit;
    //пробуем заблокировать турв для каждого типа доступа отдельно
    st1:=Q.DBLock(True, FormDoc, VarToStr(id) + '-1', '', fNone)[1];
    st2:=Q.DBLock(True, FormDoc, VarToStr(id) + '-2', '', fNone)[1];
    st3:=Q.DBLock(True, FormDoc, VarToStr(id) + '-3', '', fNone)[1];
    if (st1 = User.GetName) then st1:='';
    if (st2 = User.GetName) then st2:='';
    if (st3 = User.GetName) then st3:='';
    st:=A.ImplodeNotEmpty([st1, st2, st3], #13#10);
    if st<>'' then begin
      MyWarningMessage('Этот турв сейчас открыт на редактирование у'#13#10 + st + #13#10'Установка статуса невозможна!');
      Exit;
    end;
    IsCommited:=not IsCommited;
    Q.QExecSql('update turv_period set commit = :commit$i where id_division = :id$i and dt1 = :dt1$d and dt2 = :dt2$d', [S.IIf(IsCommited, 1, 0), ID_Division, PeriodStartDate, PeriodEndDate]);
    RefreshParentForm;
    Exit;
    //  Timer_AfterUpdate.Enabled:=False;
//LoadTurv;
//Timer_AfterUpdate.Enabled:=True;
//sleep(2000);
//exit;
    if Not IsCommited then begin
       //если период не закрыть, то проверим, можно ли его закрыть
       b:=True;
       for j:=0 to High(ArrTurv) do begin
          if not b then Break;
          for i:=1 to DayColumnsCount do begin
            //ячейки красные и желтые, или не введено время/код руководителя, и при этом не серые - не даем возможности закрыть турв
            if (S.NNum(ArrTurv[j][i][atColor]) = 1)or(S.NNum(ArrTurv[j][i][atColor]) = 2)or
               ((ArrTurv[j][i][atExists] <> -1) and (ArrTurv[j][i][atTRuk] = null) and (ArrTurv[j][i][atCRuk] = null))
              then begin
                b:=False;
                Break;
              end;
          end;
       end;
      if not b then
        begin MyInfoMessage('В этом ТУРВ введены не все данные, закрыть его нельзя!'); Exit; end;
    end;
    if MyQuestionMessage(S.IIFStr(IsCommited,
      'Вы уверены, что хотите снять статус "Закрыт" с этого ТУРВ?',
      'Вы уверены, что хотите отметить этот ТУРВ как "Закрыт"?'#13#10'В этом случае ввод данных в него будет невозможен!')
    ) <> mrYes then Exit;
    IsCommited:=not IsCommited;
    Q.QExecSql('update turv_period set commit = :commit$i where id_division = :id$i and dt1 = :dt1$d and dt2 = :dt2$d', [S.IIf(IsCommited, 1, 0), ID_Division, PeriodStartDate, PeriodEndDate]);
    RefreshParentForm;
  end;
  if bt = btnSendEmail then begin
    SendEMailToHead;
  end;
  if bt = btnCustom_FromParsec then begin
    if Dlg_Turv_FromParsec.ShowDialog(PeriodStartDate, PeriodEndDate) then begin
      ImporFromParsec(Dlg_Turv_FromParsec.FileName);
    end;
  end;
  if bt = btnCustom_SundaysToTurv then begin
    SundaysToTurv;
  end;
  if bt = btnPrint then begin
    if RgsEdit2 then begin
      if TFrmBasicInput.ShowDialog(Self, '', [], fAdd, 'Экспорт в Excel', 270, 50,
//      if Dlg_BasicInput.ShowDialog(Self, 'Экспорт в Excel', 270, 50, fAdd, [
       [
        [cntComboLK,'Шаблон','1:500:0', 210],
        [cntDTEdit,'Дата с','' + S.DateTimeToIntStr(PeriodStartDate) + ':' + S.DateTimeToIntStr(PeriodEndDate), 90],
        [cntDTEdit,'по ','' + S.DateTimeToIntStr(PeriodStartDate) + ':' + S.DateTimeToIntStr(PeriodEndDate), 170, 90]
       ],
       [
         VarArrayOf(['0', VarArrayOf(['ТУРВ по Parsec']), VarArrayOf(['0'])]),
         PeriodStartDate, PeriodEndDate
       ],
       va,
       [['']],
       nil
      ) >=0
      then ExportToXlsxA7(Integer(va[0]), va[1], va[2], True);
//    if User.IsDeveloper then PrintReport.D_Turvl;
    end;
  end;
  //перерисуем кнопки и заголовки
  SetBtns;
  //Cth.GetSpeedBtn(P_Left)
//  TMyHint.Create(BitBtn1);
end;


procedure TDlg_TURV.PrintCurrentWorker;
//выведем данные по работнику и времни, на которого установлена позиция в основном гриде.
//вызываем из события изменения столбца детального грида и изменения столбца основного, а также афтерскролл мемтейбл1
//!если открыт детальнфй грид, и в из ячейки основного ткнуться в детальный и там сразу откроется редактирование, и обратно,
//то сюда не попадает - не вызывается события ни colEnter, ни Cellclick, ни CellMouseClick, если ячейки уже в режиме редактирования!
var
  i,j:Integer;
begin
  //выйдем во время загрузки данных
  //а первоначальный показ в итоге прихождится делать в form.onshow
  if InPrepare then Exit;
  //позиции в массиве данных
  i:=DBGridEh1.Row - 1;
  //если видна детальная панель, то получим из нее, иначе из основной
//  if DBGridEh1.RowDetailPanel.Visible
  if DBGridEh2.Focused
    then j:=DBGridEh2.Col - 1
    else j:=DBGridEh1.Col - 4;
  Lb_Worker.ResetColors;
  if (j<1)or(j>16)or(ArrTurv[i][j][atExists] = - 1)
    //не колонки дней - только фио
    then Lb_Worker.SetCaptionAr(['$000000Работник: $FF00FF', ArrTitle[i][2]])
    //колонки дней - данные по текущей ячейке
    //два цвета не могут в лейбле сейчас идти подряд без промежутков!
    else Lb_Worker.SetCaptionAr([
      '$000000Работник: $FF00FF', ArrTitle[i][2],
      '$000000', '   Дата: ', '$FF0000', DateToStr(IncDay(PeriodStartDate, j-1)) +
      '$000000', '   Время: ', '$FF0000',
      FormatTurvCell(GetTurvCell(i, j, 1)), ' $000000/$FF0000', FormatTurvCell(GetTurvCell(i, j, 2)), ' $000000/$FF0000', FormatTurvCell(GetTurvCell(i, j, 3)),
      S.IIf(ArrTurv[i][j][atSumPr] > 0, ' $000000   Премия: $FF0000 ' + VarToStr(ArrTurv[i][j][atSumPr]), ''),
      S.IIf(ArrTurv[i][j][atSumSct] > 0, ' $000000   Штраф: $FF0000 ' + VarToStr(ArrTurv[i][j][atSumSct]), ''),
      S.IIf(S.NSt(ArrTurv[i][j][atBegTime]) = '', '', ' $000000   Приход: $FF0000 ' + S.IIf(ArrTurv[i][j][atBegTime] = '-1', '-',
        StringReplace(FormatFloat('00.00', S.VarToFloat(ArrTurv[i][j][atBegTime])), FormatSettings.DecimalSeparator, ':', []))),
      S.IIf(S.NSt(ArrTurv[i][j][atEndTime]) = '', '', ' $000000   Уход: $FF0000 ' + S.IIf(ArrTurv[i][j][atEndTime] = '-1', '-',
        StringReplace(FormatFloat('00.00', S.VarToFloat(ArrTurv[i][j][atEndTime])), FormatSettings.DecimalSeparator, ':', []))),
      S.IIf(S.NSt(ArrTurv[i][j][atNight]) = '', '', ' $000000   Ночью: $FF0000 ' + VarToStr(ArrTurv[i][j][atNight]))
      //,'=='+vartostr(ArrTurv[i][j][atEndTime]) +'=='

    ]);
end;

function TDlg_TURV.FormatTurvCell(v: Variant): string;
begin
  if S.IsNumber(S.NSt(v),0,24) then Result:=FormatFloat('0.00', S.VarToFloat(v)) else Result:=S.NSt(v);
end;

function TDlg_TURV.GetTurvCode(v: Variant): Variant;
var
  i: Integer;
begin
  Result:=null;
  if v <> null
    then begin
      for i:=0 to TurvCodesIds.Count-1 do
        if TurvCodesIds[i] = v
          then begin Result:= TurvCodes[i]; Exit; end;
    end;
end;

function TDlg_TURV.GetTurvCell(r,d,n:Integer): Variant;
var
  i,j: Integer;
begin
  if ArrTurv[r][d][n] <> null
    then Result:=ArrTurv[r][d][n]
    else Result:=GetTurvCode(ArrTurv[r][d][n+3]);
end;

//изменяем параметры ячеек детального грида
procedure TDlg_TURV.DBGridEh2Columns0GetCellParams(Sender: TObject;
  EditMode: Boolean; Params: TColCellParamsEh);
var
  st: string;
  color, r, d: Integer;
  dt: TDateTime;
  b: Boolean;
begin
  //по умолчанию только просмотр, редактора нет
  Params.ReadOnly:=True;
  Params.TextEditing:=False;
  inherited;
  //не в области дневных данных - выход
  if (Params.col <= 1)or(Params.col > 1+DayOf(PeriodEndDate)) then Exit;   ///!!! правильно высчитать
  //если нет рабочего дня работника, закрасим серым и выйдем
  if (ArrTurv[DBGridEh1.Row-1][Params.col-1][0] = -1) then begin
    Params.Background:=clGray;
    Exit;
  end;
  //весь шрифт черный, но вторую строку при флаге недостаточности данных парсек рисуем синим
  if (ArrTurv[DBGridEh1.Row-1][Params.col-1][atSetTime] = 1)and(RgsEdit2)and(Params.Row = 2)
    then Params.Font.Color:=clBlue
    else Params.Font.Color:=clWindowText;
  dt:=EncodeDate(YearOf(PeriodStartDate), MonthOf(PeriodStartDate), Params.col - 1);
  //вычислим возможность редактирования
  Params.ReadOnly:= not(
    (Params.col > 1) and
    InEditMode and
    ((((Params.Row = 1)or(Params.Row >=4)) and RgsEdit1) or ((Params.Row = 2) and RgsEdit2) or ((Params.Row = 3) and RgsEdit3))
  );
  //разрешим редактор, если ячейка доступна для редактирования
  Params.TextEditing:=not Params.ReadOnly;


//  if Params.Row >=4 Params.Alignment
//  b:=Params.ReadOnly;

//  if ArrTurv[DBGridEh1.Row-1][Params.Col-1][atExists] = null
//    then Params.Background:=clGray;

  {  if EditMode then exit;
  //получим номер дня (позицию в массиве)
  d:=0;
  if (Params.Col > 4) and (Params.Col <= 31+5) then d:=Params.Col - 4;
  if d > 0 then begin
    //если коду цвета в массиве присвоено целове значение, то изменим фон в соответствии с ним
    if VarType(ArrTurv[Params.Row-1][d][12]) = varInteger then begin
      color:=ArrTurv[Params.Row-1][d][12];
      case color of
        1: Params.Background:=clRed;
        2: Params.Background:=clYellow;
      end;
    end;
  end;  }
end;


//отрисуем ячейку
procedure TDlg_TURV.DBGridEh1AdvDrawDataCell(Sender: TCustomDBGridEh; Cell,
  AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect;
  var Params: TColCellParamsEh; var Processed: Boolean);
var
  v1, v2, v3, v4: Variant;
  r, c: Integer;
begin
  inherited;
  //рисуем только столбцы с днями
  if (Params.Col<5)or(Params.Col>5+16-1) then Exit;
//  v:=MemTableEh1.RecordsView.MemTableData.RecordsList[Params.row-1].DataValues['d'+ IntToStr(Params.Col-4),dvvValueEh];
  //получим комментарии
  v1:=ArrTurv[Params.row-1][Params.Col-4][atComRuk];
  v2:=ArrTurv[Params.row-1][Params.Col-4][atComPar];
  v3:=ArrTurv[Params.row-1][Params.Col-4][atComSogl];
  v4:=ArrTurv[Params.row-1][Params.Col-4][atNight];
  //если выйдем, то будет стандартная отрисовка
//  if (v<>'8.00')and(v<>'8,00')  then exit;
  //выйдем, если нет никакого комментария
  if (((VarIsEmpty(v1))or(S.NSt(v1) = '')) and ((VarIsEmpty(v2))or(S.NSt(v2) = '')) and ((VarIsEmpty(v3))or(S.NSt(v3) = '')) and ((VarIsEmpty(v4))or(S.NNum(v4) = 0))) then Exit;
  //стандартная отрисовка
  TDBGridEh(Sender).DefaultDrawColumnDataCell(Cell, AreaCell, Column, ARect, Params);
  if S.NSt(v1) + S.NSt(v2) + S.NSt(v3) <> '' then begin
    //и поверху квадратик комментария
    TDBGridEh(Sender).Canvas.Pen.Width:=1;
    //если есть комментарии проверенное/согласованное, то подсветим бирюзовым, если только мастер, то синим
    if (VarToStr(v2) <> '')or(VarToStr(v3) <> '')
      then TDBGridEh(Sender).Canvas.Brush.Color:=RGB(255,0,255)
      else TDBGridEh(Sender).Canvas.Brush.Color:=clBlue;
    //нарисуем прямоугольник в верхнем левом углу ячейки
    TDBGridEh(Sender).Canvas.Rectangle(ARect.Left, ARect.Top , ARect.Left+7, ARect.Top+7);
  end;
  if S.NNum(v4) <> 0 then begin
    TDBGridEh(Sender).Canvas.Pen.Width:=1;
    TDBGridEh(Sender).Canvas.Brush.Color:=clBlack;
    //нарисуем прямоугольник в левом нижнем углу ячейки
    TDBGridEh(Sender).Canvas.Rectangle(ARect.Left, ARect.Bottom - 7 , ARect.Left+7, ARect.Bottom);
  end;
  //флаг что обработати, если не поставить то будет стандартная отрисовка
  Processed:=True;
end;

procedure TDlg_TURV.DBGridEh1CellClick(Column: TColumnEh);
begin
  inherited;
  PrintCurrentWorker;
end;

procedure TDlg_TURV.DBGridEh1CellMouseClick(Grid: TCustomGridEh;
  Cell: TGridCoord; Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  var Processed: Boolean);
begin
  inherited;
//  PrintCurrentWorker;
  //только по правой кнопке
  if Button <> mbRight then Exit;
  //для первого столбца не надо
  if (Cell.X < 4)or(Cell.X > 4+16) then Exit;
  //покажем меню
  PM_1.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TDlg_TURV.DBGridEh1ColEnter(Sender: TObject);
begin
  inherited;
  PrintCurrentWorker;
end;

procedure TDlg_TURV.DBGridEh1Columns0GetCellParams(Sender: TObject;
  EditMode: Boolean; Params: TColCellParamsEh);
var
  st: string;
  color, d: Integer;
  b: Boolean;
begin
  inherited;
  //выйдем если это событие вызвано редактированием ячейки
  if EditMode then exit;
  //по умолчанию только просмотр, редактора нет
  Params.ReadOnly:=True;
  //получим номер дня (позицию в массиве)
  d:=0;
  if (Params.Col > 4) and (Params.Col <= 16+5) then d:=Params.Col - 4;
  if d > 0 then begin
    //old - если коду цвета в массиве присвоено целове значение, то изменим фон в соответствии с ним
    //если заполнена данная ячейка турв
//    if VarType(ArrTurv[Params.Row-1][d][atExists]) <> -1 then begin
    if ArrTurv[Params.Row-1][d][atExists] <> -1 then begin
      color:=ArrTurv[Params.Row-1][d][atColor];
      case color of
        1: Params.Background:=clRed;
        2: Params.Background:=clYellow;
       -1: Params.Font.Color:=clRed;
      end;
    end
    else Params.Background:=clGray;
  end;
  Params.TextEditing:=False;
  //если режим ввода в основной сетке, то снимим ридонли
  if (d > 0)and(EditInGrid1)and(InEditMode)and(ArrTurv[Params.Row-1][d][atExists] <> -1) then begin
    Params.ReadOnly:=False;
  end;
  //разрешим редактор, если ячейка доступна для редактирования
  Params.TextEditing:=not Params.ReadOnly;
end;

//параметры вывода подсказки
//работает, только если задано DBGridEh1.ShowHint:=True;
//почему-то подсказка работает НЕКОРРЕКТНО, практически никогда не отрисовывается, поэтому используем свое окно подсказки
procedure TDlg_TURV.DBGridEh1DataHintShow(Sender: TCustomDBGridEh;
  CursorPos: TPoint; Cell: TGridCoord; InCellCursorPos: TPoint;
  Column: TColumnEh; var Params: TDBGridEhDataHintParams;
  var Processed: Boolean);
var
  H: THintWindow;
  v1, v2, v3, v4: Variant;
  i: Integer;
begin
  inherited;
  //только столбцы с днями
  if (Cell.X<5)or(Cell.X>5+16-1) then Exit;
  //получим комментарии
  v1:=ArrTurv[Cell.Y-1][Cell.X-4][atComRuk];
  v2:=ArrTurv[Cell.Y-1][Cell.X-4][atComPar];
  v3:=ArrTurv[Cell.Y-1][Cell.X-4][atComSogl];
  v4:=ArrTurv[Cell.Y-1][Cell.X-4][atNight];
  //если мышка в верхнем лефом углу, вызовем метод формы посказки, а он уже покажет форму, если комментарий непустой,
  //также передаются координаты чтобы форма была помещена в нужном месте.
  if ((InCellCursorPos.X <= 7)and(InCellCursorPos.Y <= 7))
    then begin
      Dlg_TURV_Comment.ShowDialog(Self, CursorPos.X, CursorPos.Y, v1, v2, v3, null);
    end;
  if ((InCellCursorPos.X <= 7)and(InCellCursorPos.Y >= DBGridEh1.CellRect(Cell.X, Cell.Y).Bottom - DBGridEh1.CellRect(Cell.X, Cell.Y).Top - 7))
    then begin
      Dlg_TURV_Comment.ShowDialog(Self, CursorPos.X, CursorPos.Y, null, null, null, v4);
    end;
  //пробовал, ничего не получается сделать
{
//exit;
//  DBGridEh1.ColumnDefValues.ToolTips:=True;
//  DBGridEh1.showHint:=False;
//  Params.HintStr:='wertfertr5yryrtyrturtyuiuyitiouiouyoyui'#13#10'подсказка';
//  Params.ReshowTimeout:=1;
//  Params.HintPos.X:=20;;
//  Params.HintPos.Y:=20;;
//  DBGridEh1.Hint:=Column.Field.AsString;
//  'wqerfwertferer';
//  DBGridEh1.ShowHint:=True;
//  Column.ToolTips:=True;
//  BitBtn1.Hint:=DBGridEh1.Hint;
//  BitBtn1.ShowHint:=True;
//  Column.To
  Application.Hint:='wertfertr5yryrtyrturtyuiuyitiouiouyoyui'#13#10'подсказка';
  Application.ShowHint:=False;
  Application.ShowHint:=True;
 // if h<> nil then H.ReleaseHandle;  //если чей-то хинт yже был, то его погасить
//   H:=THintWindow.Create(DBGridEh1) ;
//  H.ActivateHint(H.CalcHintRect(200,'qwerty',nil) , 'hint hint S.NInt') ;
}
end;

procedure TDlg_TURV.DBGridEh1HintShowPause(Sender: TCustomDBGridEh;
  CursorPos: TPoint; Cell: TGridCoord; InCellCursorPos: TPoint;
  Column: TColumnEh; var HintPause: Integer; var Processed: Boolean);
begin
  inherited;
//  HintPause:=5;
//  Processed:=True;
end;

procedure TDlg_TURV.DBGridEh1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  Coord: TGridCoord;
  st: string;

begin
exit;
  Coord:=DBGridEh1.MouseCoord(x,y);
  if (Coord.Y=0) and (Coord.X>0) then begin
//    DBGridEh1.Hint:=Format('Колонка %s и прочая чепуха',[DBGridEh1.Columns.Items[Coord.X-1].Title.Caption]);
//    DBGridEh1.ShowHint:=True;
    st:=DBGridEh1.Columns.Items[Coord.X-1].Field.AsString;
    MyInfoMessage(st);
  end;
//  else DBGridEh1.ShowHint:=False;
end;

procedure TDlg_TURV.DBGridEh1RowDetailPanelHide(Sender: TCustomDBGridEh;
  var CanHide: Boolean);
begin
  inherited;
  SetBtns;
end;

//открытие rowdetailpanel
procedure TDlg_TURV.DBGridEh1RowDetailPanelShow(Sender: TCustomDBGridEh; var CanShow: Boolean);
var
  j:Integer;
begin
  inherited;
  //имя работника
//  Lb_Title_Worker.Caption:=MemTableEh1.FieldByName('name').AsString;
  SetRowDetailCaptions;
  //заполним сетки
  for j:=1 to 16 do begin
    SetTurvRowDetail(-1, j);
  end;
  SetBtns;
end;

//таймер вызывается после изменения ячейки детального грида, путем Enabled:=True
//нужен для того, чтобы переключить фокус ввода для отображения изменений в датасете и в том и в другом гридах
//если таймер для этого не использовать а вместо его старта переключать там фокус, то при нажатии Ентер не выходит из режима редактирования,
//нукжно повторное нажатие
procedure TDlg_TURV.Timer_AfterUpdateTimer(Sender: TObject);
begin
  inherited;
  Timer_AfterUpdate.Enabled:=False;
  DBGridEh1.SetFocus;
  if (DBGridEh1.RowDetailPanel.Visible) Then DBGridEh2.SetFocus;
  if not(IsDetailGridUpd) Then DBGridEh1.SetFocus;
end;


//отрисуем ячейку детального грида (нужно чтобы показывать маркеры комментариев)
procedure TDlg_TURV.DBGridEh2AdvDrawDataCell(Sender: TCustomDBGridEh; Cell,
  AreaCell: TGridCoord; Column: TColumnEh; const ARect: TRect;
  var Params: TColCellParamsEh; var Processed: Boolean);
var
  v1, v2, v3: Variant;
  r, c: Integer;
begin
  inherited;
  //рисуем только столбцы с днями
  if (Params.Col<=1)or(Params.Col>1+16-1) then Exit;
  //получим комментарии
  case Params.Row of
    1..3: v1:=ArrTurv[DBGridEh1.Row-1][Params.Col-1][atComRuk+Params.row-1];
    4: v1:=ArrTurv[DBGridEh1.Row-1][Params.Col-1][atComPr];
    5: v1:=ArrTurv[DBGridEh1.Row-1][Params.Col-1][atComSct];
  end;
  v2:=null;
  if Params.Row= 2 then v2:=ArrTurv[DBGridEh1.Row-1][Params.Col-1][atNight];
  //если выйдем, то будет стандартная отрисовка
  //выйдем, если нет никакого комментария
  if (VarToStr(v1) = '')and(VarToStr(v2) = '') then Exit;
  //стандартная отрисовка
  TDBGridEh(Sender).DefaultDrawColumnDataCell(Cell, AreaCell, Column, ARect, Params);
  //и поверху квадратик комментария
  TDBGridEh(Sender).Canvas.Pen.Width:=1;
  if (VarToStr(v1) <> '') then begin
    if (Params.Row in [2,3])
      then TDBGridEh(Sender).Canvas.Brush.Color:=RGB(255,0,255)
      else TDBGridEh(Sender).Canvas.Brush.Color:=clBlue;
    //нарисуем прямоугольник в верхнем левом углу ячейки
    TDBGridEh(Sender).Canvas.Rectangle(ARect.Left, ARect.Top , ARect.Left+7, ARect.Top+7);
  end;
  if S.NNum(v2) <> 0 then begin
    TDBGridEh(Sender).Canvas.Pen.Width:=1;
    TDBGridEh(Sender).Canvas.Brush.Color:=clBlack;
    //нарисуем прямоугольник в левом нижнем углу ячейки
    TDBGridEh(Sender).Canvas.Rectangle(ARect.Left, ARect.Bottom - 7 , ARect.Left+7, ARect.Bottom);
  end;
  //флаг что обработати, если не поставить то будет стандартная отрисовка
  Processed:=True;
end;

//клик правой кнопкой мышки на детальной таблице
procedure TDlg_TURV.DBGridEh2CellClick(Column: TColumnEh);
begin
  inherited;
  PrintCurrentWorker;
end;

procedure TDlg_TURV.DBGridEh2CellMouseClick(Grid: TCustomGridEh;
  Cell: TGridCoord; Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  var Processed: Boolean);
begin
  inherited;
//  PrintCurrentWorker;
  //только по правой кнопке
  if Button <> mbRight then Exit;
  //для первого столбца не надо
  if (Cell.X < 2) then Exit;
//  if (not InEditMode) then Exit;
  //видимость пунктов
  N_Comment.Visible:= Cell.Y < 4;
  N_Premium.Visible:= Cell.Y = 4;
  N_Penalty.Visible:= Cell.Y = 5;
  N_Night.Visible:= (Cell.Y = 2) and RgsEdit2;
//  PM_2.AutoPopup:=True;
  //покажем меню
  PM_2.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TDlg_TURV.DBGridEh2ColEnter(Sender: TObject);
//перемещение по столбцам - когда выбран столбец
begin
  inherited;
  if InLoad then Exit;
  PrintCurrentWorker;
end;

procedure TDlg_TURV.DBGridEh2Columns0UpdateData(Sender: TObject;
  var Text: string; var Value: Variant; var UseText, Handled: Boolean);
var
  st, st1, stc: string;
  v: Variant;
  rsd: TVarDynArray;
  e,e1: extended;
  i,j,r,d,rd: Integer;
  dt : TDateTime;
  sa1: TStringDynArray;
begin
     inherited;

  IsDetailGridUpd:= TDBGridColumnEh(Sender).Grid = DBGridEh2;

  if UseText
    then st:=Text
    else st:=VarToStr(Value);

  r:=DBGridEh1.Row-1;

  if IsDetailGridUpd
    then begin
      d:=DBGridEh2.Col-1;
      rd:=DBGridEh2.Row-1;
    end
    else begin
      d:=DBGridEh1.Col-4;
      rd:=0;
    end;
  dt := IncDay(PeriodStartDate, d-1);
  if d < 1 then exit;
  if rd < 3 then begin
    UseText:=True;
    //выделим комментарий - часть введенной строки после прямого слэша
    //!!! работает неправильно если есть слэши в коде турв или его описании, если в коде то он вообще не будет введен!!!
    stc:='~'; //признак что комменатрий не изменился
    sa1:=A.ExplodeS(st, '/');
    st:=sa1[0];
    if High(sa1) > 0
      then begin
        stc:=sa1[1];
        for i:=2 to High(sa1) do stc:=stc + '/' + sa1[i];
        stc:=trim(stc);
      end;
    if not S.IsNumber(st,0.01,24,2)
      then begin
        //не число, пытаемся вытащить код
        ArrTurv[r][d][atTRuk+rd]:=null;
        ArrTurv[r][d][atCRuk+rd]:=null;
        i:=pos(' - ', st);
        if i > 0 then st1:=copy(st,1,i - 1) else st1:=st;
        st:= '';
        for i:= 0 to TurvCodes.Count-1 do
          if UpperCase(st1) = UpperCase(TurvCodes[i])
            then begin
              st:= TurvCodes[i];
              ArrTurv[r][d][atTRuk+rd]:=null;
              ArrTurv[r][d][atCRuk+rd]:=TurvCodesIds[i];
            end;
      end
      else if dt > Date then begin
        //чиисло, но дата больше текущей
        ArrTurv[r][d][atTRuk-1+DBGridEh2.Row]:=null;
        ArrTurv[r][d][atCRuk-1+DBGridEh2.Row]:=null;
      end
      else begin
        //если число от 0 до 24
        //округляем до четверти часа, не менее 0.25
        e:=StrToFloat(st);
{        if e<0.13 then e1:=0.25
          else if frac(e)<0.13
          then e1:=round(e)
          else if frac(e)<0.26
          then e1:=trunc(e)+0.25
          else if frac(e)<0.51
          then e1:=trunc(e)+0.5
          else if frac(e)<0.76
          then e1:=trunc(e)+0.75
          else e1:=round(e);}
        e1:=e;
        //форматируем до двух знаков после запятой
        st:=FormatFloat('0.00', e1);
        ArrTurv[r][d][atTRuk+rd]:=e1;
        ArrTurv[r][d][atCRuk+rd]:=null;
      end;
    //комментарий
    if stc <> '~'
      then ArrTurv[r][d][atComRuk+rd]:=stc;
    //сбросим подсветку синим при отсутствии одного из времен парсек
    if rd = 1
      then ArrTurv[r][d][atSetTime]:=null;
  end;
{  //выработка
  else if DBGridEh2.Row = 6 then begin
    if ArrTurv[r][d][atVyr] = null
      then ArrTurv[r][d][atVyr] := 1
      else ArrTurv[r][d][atVyr] := null;
  end;}
  //событие обработано
  Handled:=True;
  //отобразим данные в основной таблице
  SetTurvAllDay(r,StrToInt(Copy(TDBGridColumnEh(Sender).FieldName, 2,2)));
  //отобразим данные в детальной таблице
  SetTurvRowDetail(r,StrToInt(Copy(TDBGridColumnEh(Sender).FieldName, 2,2)));
  //сменим фокус чтобы отобразить изменения в таблицах на экране
//  DBGridEh1.SetFocus;
//  DBGridEh2.SetFocus;
  Timer_AfterUpdate.Enabled:=True;
  //сохраним в бд
  rsd:=[atTRuk, atTPar, atTSogl, atTRuk, atTRuk];
  SaveDayToDB(r, StrToInt(Copy(TDBGridColumnEh(Sender).FieldName, 2, 2)), rsd[rd]);
end;

procedure TDlg_TURV.DBGridEh2Columns1GetCellParams(Sender: TObject;
  EditMode: Boolean; Params: TColCellParamsEh);
begin
  inherited;
{
  //выйдем если это событие вызвано редактированием ячейки
  if EditMode then exit;
  //закрасим серым клетки, в которых нет работающего сотрудника
  if ArrTurv[DBGridEh1.Row-1][Params.Col-1][atExists] = null
    then Params.Background:=clGray;
//  if EditMode then begin
//     if DBGridEh2.Row = 3 then Params.ReadOnly:=True;
//  end;}
end;

procedure TDlg_TURV.DBGridEh2Columns1UpdateData(Sender: TObject;
  var Text: string; var Value: Variant; var UseText, Handled: Boolean);
begin
  inherited;
  if DBGridEh2.Row = 1 then Handled:=True;
end;


procedure TDlg_TURV.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
//  if InLoad then Exit;
  if not InLoad then Settings.SaveWindowPos(Self, FormDoc +'_' + IntToStr(ID_Division));
  //выйдем, если из-за блокировки завершаем в конструкторе (флаг будет установлен после взятия блокировки)
  if not DbLockSet then Exit;
  if RgsEdit1 then Q.DBLock(False, FormDoc, VarToStr(id) + '-1', '', fNone);
  if RgsEdit2 then Q.DBLock(False, FormDoc, VarToStr(id) + '-2', '', fNone);
  if RgsEdit3 then Q.DBLock(False, FormDoc, VarToStr(id) + '-3', '', fNone);
end;


procedure TDlg_TURV.FormShow(Sender: TObject);
begin
  inherited;
  if InLoad then Exit;
  //восстанавливаем размеры и положение окна, если таковые сохранены в бд
  //так как в базовом классе чтение данных окна происходит по formdoc
  Settings.RestoreWindowPos(Self, FormDoc +'_' + IntToStr(ID_Division));
  //выведем инфо по текущему работнику (делаем здесь, тк в событиях грида и мемтейбл не вызываем при inprepere= True)
  PrintCurrentWorker;
end;


function TDlg_TURV.Prepare: Boolean;
var
  i, j: Integer;
  dt :TDateTime;
  st, st1, st2, st3: string;
  v: Variant;
  w1, w2, w3, wcol: Integer;
begin
  Result:=False;
  InLoad:=True;
  DbLockSet:=False;

//  st1:=Ah..ExplodeV(ID, ' ')[0];
//  st2:=Ah..ExplodeV(ID, ' ')[1];
//  st3:=Ah..ExplodeV(ID, ' ')[2];
  v:=Q.QSelectOneRow('select id_division, dt1, dt2 from v_turv_period where id = :id$i', [id]);
  if v[0] = null then begin MsgRecordIsDeleted; {ExitDialog;} Exit; end;
  ID_Division:=v[0];
  PeriodStartDate:=v[1];
  PeriodEndDate:=v[2];
{  ID_Division:=StrToInt(st1);
  PeriodStartDate:=EncodeDate(StrToInt(copy(st2,1,4)),StrToInt(copy(st2,5,2)),StrtoInt(copy(st2,7,2)));
  PeriodEndDate:=EncodeDate(StrToInt(copy(st3,1,4)),StrToInt(copy(st3,5,2)),StrToInt(copy(st3,7,2)));}
  DayColumnsCount:=DayOf(PeriodEndDate) - DayOf(PeriodStartDate) + 1;

  //MyInfoMessage('!!!');

  ///!!!!!if FormDbLock = fNone then Exit;

  v:=Q.QSelectOneRow('select name, IsStInCommaSt(:id_user$i, editusers), editusers from ref_divisions where id = :id$i', [User.GetId, ID_Division]);
  if v[0] = null then begin MsgRecordIsDeleted; {ExitDialog;} Exit; end;
  DivisionName:=v[0];

  RgsCommit:=User.Role(rW_J_Turv_Commit);;
  RgsEdit1:=v[1]=1;
  RgsEdit2:=User.Role(rW_J_Turv_TP);
  RgsEdit3:=User.Role(rW_J_Turv_TS);;
  EditUsers:=v[2];

  v:=Q.QSelectOneRow('select commit from turv_period where id_division = :id$i and dt1 = :dt1$d and dt2 = :dt2$d', [ID_Division, PeriodStartDate, PeriodEndDate]);
  IsCommited:=v[0]=1;

  //блокировки
  //нужны только в режиме редактирования и если период еще не закрыт
  if (Mode = fEdit)and not IsCommited then begin
    st:=''; st1:=''; st2:=''; st3:='';
    //пробуем заблокировать турв для каждого типа доступа отдельно
    if RgsEdit1 then st1:=Q.DBLock(True, FormDoc, VarToStr(id) + '-1', '', fNone)[1];
    if RgsEdit2 then st2:=Q.DBLock(True, FormDoc, VarToStr(id) + '-2', '', fNone)[1];
    if RgsEdit3 then st3:=Q.DBLock(True, FormDoc, VarToStr(id) + '-3', '', fNone)[1];
    if (st1 = User.GetName)or(st2 = User.GetName)or(st3 = User.GetName) then begin
      //если хотя бы одна блокировка своя, то скажем что мы уже редактируем
      st:='Вы уже открыли этот ТУРВ для редактирования!';
      MyWarningMessage(st);
      LockInDB:=fNone;
      Mode:=fNone;
      Exit;
    end
    else if byte(RgsEdit1)+byte(RgsEdit2)+byte(RgsEdit3) = 1 then begin
      //если только одно право, например время руководителя, то не пишем подробно, просто что уже редактируется други
      if st1+st2+st3 <> ''
        then begin
          st:='Этот ТУРВ уже редактируется пользователем ' + A.ImplodeNotEmpty([st1, st2, st3], ',') + ' и будет открыт только для просмотра!';
          MyWarningMessage(st);
          Mode:=fView;
        end;
    end
    else begin
      //если нескольо прав, то распишем подробно что заблокировано
      if st1<>'' then begin st1:='Ввод времени руководителя невозможен, так как этот ТУРВ редактирует ' + st1; RgsEdit1:= False; end;
      if st2<>'' then begin st2:='Ввод времени по Parsec невозможен, так как этот ТУРВ редактирует ' + st2; RgsEdit2:= False; end;
      if st3<>'' then begin st3:='Ввод согласованного времени невозможен, так как этот ТУРВ редактирует ' + st3; RgsEdit3:= False; end;
      if not(RgsEdit1 or RgsEdit2 or RgsEdit3) then Mode:=fView;
      st:=A.ImplodeNotEmpty([st1, st2, st3], #13#10);
      if st<>'' then MyWarningMessage(st);
    end;
  end;
  DbLockSet:=True;


  IsOffice:=Q.QSelectOneRow('select office from ref_divisions where id = :id$i', [ID_Division])[0] = 1;

  LoadTurvCodes;

  if not LoadTurv then begin
    MyWarningMessage('Не удалось загрузить ТУРВ!');
    Exit;
  end;
{
  v:=QSelectOneRow('select time_autoagreed, time_dinner_1, time_dinner_2 from workers_cfg');
  Time_Autoagreed:=v[0];
  Time_dinner_1:=v[1];
  Time_dinner_2:=v[2];}

  DayColWidth:=51;
  RowHeight:=20;

  DBGridEh1.TitleParams.MultiTitle:=True;

  //добавим столбцы в основную таблицу
  //перед созданием датасета
  DBGridEh1.Columns[0].Title.Caption:='*';
  DBGridEh1.Columns[0].Width:=20;
  DBGridEh1.Columns[1].Title.Caption:='Работник|ФИО';
  DBGridEh1.Columns[1].Width:=200;
  DBGridEh1.Columns[2].Title.Caption:='Работник|Должность';
  DBGridEh1.Columns[2].Width:=150;
  DBGridEh1.Columns[3].Title.Caption:='Работник|Разряд';
  DBGridEh1.Columns[3].Width:=0;
  DBGridEh1.Columns[3].Visible:=False; //не используем разряд, но убирать не стал

  //добавляем 16 колонок для дневных данных
  for j:=1 to 16 do begin
    DBGridEh1.Columns.Add.Title.Caption;
    //заголовок соотвествует дню из даты
    DBGridEh1.Columns[DBGridEh1.Columns.Count-1].Title.Caption:='Период|' + IntToStr(DayOf(IncDay(PeriodStartDate, j-1))) + ', '+ DaysOfWeek2[DayOfTheWeek(IncDay(PeriodStartDate, j-1))];
    //поле соответствует позиции в массиве
    DBGridEh1.Columns[DBGridEh1.Columns.Count-1].FieldName:='d' + IntToStr(j);
    DBGridEh1.Columns[DBGridEh1.Columns.Count-1].Width:=DayColWidth;
    //скроем столбцы, большие даты конца периода
    DBGridEh1.Columns[DBGridEh1.Columns.Count-1].Visible:=(IncDay(PeriodStartDate, j-1) <= PeriodEndDate);
  end;

  DBGridEh1.Columns.Add.Title.Caption;
  DBGridEh1.Columns[DBGridEh1.Columns.Count-1].Title.Caption:='Итоги|Время';
  DBGridEh1.Columns[DBGridEh1.Columns.Count-1].FieldName:='time';
  DBGridEh1.Columns.Add.Title.Caption;
  DBGridEh1.Columns[DBGridEh1.Columns.Count-1].Title.Caption:='Итоги|Премия за период';
  DBGridEh1.Columns[DBGridEh1.Columns.Count-1].FieldName:='premium_p';
  DBGridEh1.Columns.Add.Title.Caption;
  DBGridEh1.Columns[DBGridEh1.Columns.Count-1].Title.Caption:='Итоги|Премии';
  DBGridEh1.Columns[DBGridEh1.Columns.Count-1].FieldName:='premium';
  DBGridEh1.Columns.Add.Title.Caption;
  DBGridEh1.Columns[DBGridEh1.Columns.Count-1].Title.Caption:='Итоги|Штрафы';
  DBGridEh1.Columns[DBGridEh1.Columns.Count-1].FieldName:='penalty';
  DBGridEh1.Columns.Add.Title.Caption;
  DBGridEh1.Columns[DBGridEh1.Columns.Count-1].Title.Caption:='Комментарий';
  DBGridEh1.Columns[DBGridEh1.Columns.Count-1].Visible:=False;

  for i:=1 to DBGridEh1.Columns.Count-1 do begin
    if (i <= 3) or (i > 3+16) then DBGridEh1.Columns[i].Color:=RGB(200,200,200);
    if (i > 3) then DBGridEh1.Columns[i].Alignment:=taRightJustify;
    DBGridEh1.Columns[i].OnGetCellParams:= DBGridEh1Columns0GetCellParams;
  end;

  for i:=4 to 4+16-1 do begin
    DBGridEh1.Columns[i].OnUpdateData:=DBGridEh2Columns0UpdateData;
  end;

  DBGridEh1.ShowHint:=True;
//  DBGridEh1.ReadOnly:=True;

  //закроем таблицу, тк если она активна из дизайн-тайма то будет ошибка
  MemTableEh1.Close;
  //очистим определение полей
  MemTableEh1.FieldDefs.Clear;
  //определяем поля
  MemTableEh1.FieldDefs.Add('name', ftString, 50, False);
  MemTableEh1.FieldDefs.Add('job', ftString, 50, False);
  MemTableEh1.FieldDefs.Add('category', ftInteger, 0, False);
  for i:=1 to 16 do begin
    MemTableEh1.FieldDefs.Add('d' + IntToStr(i), ftString, 5, False);
  end;
  MemTableEh1.FieldDefs.Add('time', ftString, 10, False);
  MemTableEh1.FieldDefs.Add('premium_p', ftString, 10, False);
  MemTableEh1.FieldDefs.Add('premium', ftString, 10, False);
  MemTableEh1.FieldDefs.Add('penalty', ftString, 10, False);
 //создаем датасет
  MemTableEh1.CreateDataSet;
  //заполним поля из массива
  MemTableEh1.First;
  for i := 0 to High(ArrTitle) do begin
    MemTableEh1.Last;
    MemTableEh1.Insert;
    MemTableEh1.FieldByName('name').Value := ArrTitle[i][2];
    MemTableEh1.FieldByName('job').Value := ArrTitle[i][3];
    MemTableEh1.FieldByName('category').Value := null; //ArrTitle[i][4];
    MemTableEh1.Post;
    for j:=1 to 16 do begin
      SetTurvAllDay(i, j);
    end;
  end;

  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh-[dghShowRecNo];
  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh+[dghEnterAsTab];
  DBGridEh1.ShowHint:=True;
//!!!  DBGridEh1.ColumnDefValues.ToolTips:=True;
  DBGridEh1.TitleParams.FillStyle:=cfstGradientEh;
  //DBGridEh1.TitleParams.MultiTitle:=True;
  DBGridEh1.TitleParams.SecondColor:=clSkyBlue;
  DBGridEh1.TitleParams.Color:=clWindow;
 //перемещение столбцов
  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh-[dghColumnMove];
  //изменение ширины столбцов
  DBGridEh1.OptionsEh:=DBGridEh1.OptionsEh-[dghColumnResize];
  DBGridEh1.FixedColor:=RGB(200,200,200);

//  DBGridEh1.ReadOnly:=not (InEditMode and EditInGrid1);


//  DBGridEh1.FrozenCols:=5;

  //закроем таблицу, тк если она активна из дизайн-тайма то будет ошибка
  MemTableEh2.Close;
  //очистим определение полей
  MemTableEh2.FieldDefs.Clear;
  //определяем поля
  MemTableEh2.FieldDefs.Add('value', ftString, 50, False);
  for i:=1 to 16 do begin
    MemTableEh2.FieldDefs.Add('d' + IntToStr(i), ftString, 400, False); //!!!5
  end;
 //создаем датасет
  MemTableEh2.CreateDataSet;
  //заполним поля из массива
  MemTableEh2.First;
  for i := 1 to 5 do begin
    MemTableEh2.Last;
    MemTableEh2.Insert;
    case i of
      1: MemTableEh2.FieldByName('value').Value :='Время (руководитель)';
      2: MemTableEh2.FieldByName('value').Value :='Время (парсек)';
      3: MemTableEh2.FieldByName('value').Value :='Время (согласованное)';
      4: MemTableEh2.FieldByName('value').Value :='Премия';
      5: MemTableEh2.FieldByName('value').Value :='Штраф';
//      6: MemTableEh2.FieldByName('value').Value :='Выработка';
    end;
//    for j:=1 to 8 do begin
//      MemTableEh2.FieldByName('d'+inttostr(j)).Value := '8.0';
//    end;
    MemTableEh2.Post;
{    for j:=1 to 31 do begin
      SetTurvRowDetail(i, j);
    end;}
  end;

// exit;
  DBGridEh2.Columns[DBGridEh2.Columns.Count-1].Title.Caption:='Значение';
  for j:=1 to 16 do begin
    //добавим столбец
    DBGridEh2.Columns.Add.Title.Caption;
    //соответстви полю мемтейбл
    DBGridEh2.Columns[DBGridEh2.Columns.Count-1].FieldName:='d' + IntToStr(j);
    //заголовок
    DBGridEh2.Columns[DBGridEh2.Columns.Count-1].Title.Caption:=''+IntToStr(DayOf(IncDay(PeriodStartDate, j-1))) + ', '+ DaysOfWeek2[DayOfTheWeek(IncDay(PeriodStartDate, j-1))];;
    //ширина
    DBGridEh2.Columns[DBGridEh2.Columns.Count-1].Width:=DaycolWidth;
    //добавить ваыпадающий список в грид в столбец
//    DBGridEh2.Columns[DBGridEh2.Columns.Count-1].PickList.AddStrings(TurvCodesSt);
    DBGridEh2.Columns[DBGridEh2.Columns.Count-1].ToolTips:=True;
    //скроем столбцы, большие даты конца периода
    DBGridEh2.Columns[DBGridEh2.Columns.Count-1].Visible:=(IncDay(PeriodStartDate, j-1) <= PeriodEndDate);
  end;
//  DBGridEh2.Height:=(DBGridEh2.RowHeight+DBGridEh2.RowLines)*4;
  for i:=0 to 16 do begin
    DBGridEh2.Columns[i].OnGetCellParams:= DBGridEh2Columns0GetCellParams;
  end;
  for i:=1 to 16 do begin
    DBGridEh2.Columns[i].OnUpdateData:=DBGridEh2Columns0UpdateData;
  end;

  DBGridEh2.OptionsEh:=DBGridEh2.OptionsEh-[dghShowRecNo];
  DBGridEh2.OptionsEh:=DBGridEh2.OptionsEh-[dghEnterAsTab];
  DBGridEh2.ShowHint:=True;
  DBGridEh2.ColumnDefValues.ToolTips:=True;
  DBGridEh2.TitleParams.FillStyle:=cfstGradientEh;
  DBGridEh2.TitleParams.MultiTitle:=True;   //это позволяет выровнять заголовки по центру столбцов
  DBGridEh2.TitleParams.SecondColor:=clSkyBlue;
  DBGridEh2.TitleParams.Color:=clWindow;
 //перемещение столбцов
  DBGridEh2.OptionsEh:=DBGridEh2.OptionsEh-[dghColumnMove];
  //изменение ширины столбцов
  DBGridEh2.OptionsEh:=DBGridEh2.OptionsEh-[dghColumnResize];

  for i:=0 to DBGridEh2.Columns.Count-1 do begin
    if (i = 0) or (i > 1+16) then DBGridEh2.Columns[i].Color:=RGB(200,200,200);
    if (i > 0) then DBGridEh2.Columns[i].Alignment:=taRightJustify;
  end;

  wcol:=45;
  w1:=55;
  w2:=-39;
  w3:=w2;
  for i:=0 to DBGridEh1.Columns.Count-1 do begin
    if (i>=4)and(i<=4+15) then DBGridEh1.Columns[i].Width := wcol;
    if DBGridEh1.Columns[i].Visible then w1:=w1+DBGridEh1.Columns[i].Width;
    if DBGridEh1.Columns[i].Visible and (i<4) then w2:=w2+DBGridEh1.Columns[i].Width;
    if DBGridEh1.Columns[i].Visible and (i<=4+15) then w3:=w3+DBGridEh1.Columns[i].Width;
  end;
  //ширина окна по ширине грида
  Self.Width:=w1;
  //подгоним ширину первого столбца детального грида так, чтобы столбцы дней находились по тому же месту что и в основном гриде
  DBGridEh2.Columns[0].Width:=w2;
  for i:=1 to DBGridEh2.Columns.Count-1 do
    DBGridEh2.Columns[i].Width := wcol;

  DBGridEh2.Height:=RowHeight*6+5;
  DBGridEh2.FrozenCols:=1;
  DBGridEh2.Width:=Min(Width-50, DBGridEh1.Width-50);
  DBGridEh2.ShowHint:=True;

  DBGridEh1.RowDetailPanel.Height:=DBGridEh2.Top + DBGridEh2.Height+10;
  DBGridEh1.RowDetailPanel.Width:=0;

  Bt_Comment.Left:=w2 + 20;
  Cth.SetBtn(Bt_Comment, mybtEdit, True, 'Ввести комментарий');
  Lb_Comment.Left:=Bt_Comment.Left + Bt_Comment.Width + 5;

  Bt_Premium.Left:=w3 + 38;
  Cth.SetBtn(Bt_Premium, mybtEdit, True, 'Ввести премию');
  Lb_Premium.Left:=Bt_Premium.Left + Bt_Premium.Width + 5;
  Lb_Comment.Width:= Bt_Premium.Left - Lb_Comment.Left - 15;

  SetRowDetailCaptions;

  DBGridEh2.OptionsEh:=DBGridEh2.OptionsEh + [dghEnterAsTab];

  DBGridEh1.ShowHint:=True;

  //установим на первую строку в основном гриде
  MemTableEh1.First;
  MemTableEh1AfterScroll(nil);

//DBGridEh1.OnDataHintShow:= nil; //DBGridEh1DataHintShow;
//DBGridEh1.Columns[0].Visible:=True;
//DBGridEh1.Columns[2].OnDataHintShow:= DBGridEh1DataHintShow;
//DBGridEh1.ColumnDefValues.ToolTips:=True;
//DBGridEh1.Columns[1].ToolTips:=True;
//DBGridEh1.Columns[10].ToolTips:=True;


//Application.OnShowHint := MyShowHint;
//Application.HintPause := 250;
//Application.HintHidePause := -1;

  Buttons:=[mybtView, mybtEdit, mybtDividor, mybtCustom_SundaysToTurv, mybtDividor, mybtSendEmail, mybtCustom_FromParsec, mybtPrint, mybtLock];
  ButtonsState:=[True, True, True, True, True, True, True, True, True];
  P_Left.Width:=Cth.CreateGridBtns(Self, P_Left, Buttons, ButtonsState, Bt_Click) + 5;

  //начальный режим ввода в сетке, будет сброшен в SetBtns если нет прав
  EditInGrid1:=True;

  SetBtns;


  Cth.SetInfoIcon(Img_Info, Cth.SetInfoIconText(Self, [
  ['Табель учета рабочего времени.'#13#10#13#10],
  [
  'При открытии в сетке отображается время от руководителя, и Вы можете вводить данные непосредственно в основной таблице.'#13#10+
  'Для отображения итогового времени нажмите соответствующую кнопку (в этом случае вводить данные в основной таблице будет нельзя!)'#13#10
  , InEditMode and RgsEdit1],
  [
  'Вы можете нажать "+" слева от имени работника, и открыть таблицу со всеми данными'#13#10+
  '(времена от руководителя, парксек, согласованное, премии), и редактировать данные уже в ней, в соответствии со своим доступом.'#13#10+
  'Нажмите (в любой таблице) правую кнопку мыши для ввода премии или комментария.'#13#10+
  'Подведите мышку к синему квадратику, для того чтобы увидеть комментарий.'#13#10+
  'Также для удобства над таблицей отображается информация по работнику по той ячекй, которая сейчас активна.'+
  ''#13#10#13#10
  , InEditMode],
  [
  'Ввод данных в ячекй начинается автоматически при вводе символа, а для редактирования надо дважды кликнуть мышкой по ячейке или нажать F2.'#13#10+
  'Нажатие Enter завершает ввод и перемещает фокус на ячейку вправо, стрелки Вверх и Вниз также завершают ввод и перемещают в предыдущую или следуующую строку таблицы.'#13#10+
  'Клавиша Esc отменяет ввод.'#13#10#13#10
  , InEditMode],
  [
  'Желтым в таблице отображается отсутствие времени, введенного по системе контроля доступа, а при расхождении'#13#10+
  'его со временем руководителя более чем на час, ячейка становится красной. Серым отображаются дни, в которые работник не числится в подразделении.'#13#10+
  ''#13#10
  ],
  [
  'Данные при вводе сохраняются сразу, сохранять документ дополнительно не нужно.'#13#10
  , InEditMode]

  ]), 32);


  InLoad:=False;

  Result:=True;

end;

procedure TDlg_TURV.MemTableEh1AfterScroll(DataSet: TDataSet);
//перемещение по строкам грида
var
  i: Integer;
begin
  inherited;
  //при загрузке отработаем только при явном вызове (с нил)
  if InLoad and (DataSet <> nil) then exit;
  //выпадающий список
  for i:=4 to 16+3 do begin
    if (DBGridEh1.Columns[i].PickList.Count = 0)
      then DBGridEh1.Columns[i].PickList.AddStrings(TurvCodesSt);
//      else if (not(DBGridEh1.Row in [1, 2, 3])) and (DBGridEh1.Columns[i].PickList.Count > 0)
//      then DBGridEh1.Columns[i].PickList.Clear;
  end;
  PrintCurrentWorker;
end;

procedure TDlg_TURV.MemTableEh2AfterEdit(DataSet: TDataSet);
//событие, если данные в гриде были изменены
begin
  inherited;
//  Label1.Caption:='Changed';
end;

procedure TDlg_TURV.MemTableEh2AfterScroll(DataSet: TDataSet);
//перемещение по строкам детального грида
var
  i: Integer;
begin
  inherited;
  //блокировка ввода данных в строку
  //DBGridEh2.ReadOnly:=not (MemTableEh2.FieldByName('value').Value = 'парсек');
  DBGridEh2.ReadOnly:=DBGridEh2.Row > 3;
  if InLoad then exit;
  //выпадающий список будет только для первой и третьей строк (время)
//exit; //!!!
  for i:=1 to 16 do begin
    if (DBGridEh2.Row in [1, 2, 3]) and (DBGridEh2.Columns[i].PickList.Count = 0)
      then DBGridEh2.Columns[i].PickList.AddStrings(TurvCodesSt)
      else if (not(DBGridEh2.Row in [1, 2, 3])) and (DBGridEh2.Columns[i].PickList.Count > 0)
      then DBGridEh2.Columns[i].PickList.Clear;
  end;
end;


procedure TDlg_TURV.N_CommentClick(Sender: TObject);
//клик на райтменю детального грида, ввод комментария
begin
  inherited;
  InputComment(True, 0);
end;

procedure TDlg_TURV.N_Komment_1Click(Sender: TObject);
//райтменю основного грида, комментарий
begin
  inherited;
  InputComment(False, 1);
end;

procedure TDlg_TURV.N_NightClick(Sender: TObject);
var
  r, rr, d, i: Integer;
  v: array of string;
  vvv : Variant;
begin
  d:=DBGridEh2.Col-1;
  if ArrTurv[r][d][0] = -1 then exit;
  v:=[S.NSt(ArrTurv[r][d][atNight])];
  if (InEditMode and RgsEdit2) then begin
    repeat
    //окно ввода
    if not InputQuery('Ночная смена', ['Время, ч.'], v, nil) then Exit;
    //нужно ввести обязательно число, если не число то повторим ввод, если 0 или пустая строка то ночное время удалится
    if S.IsNumber(v[0], 0, 24, 2)or(v[0]='') then begin
      if (v[0]='0')or(v[0]='')
        then begin
          ArrTurv[r][d][atNight] := null;
        end
        else begin
          ArrTurv[r][d][atNight] := v[0];
        end;
        //??? почему так?
       { MemTableEh2.Edit;
        DBGridEh2.Columns[d].SetValueAsText('');
        MemTableEh2.Cancel;}
        Break;
    end;
    until False;
  end
  else if (v[0]<>'') then begin
    //окно отображения
    MyInfoMessage('Ночная смена' + v[0] +'ч.');
  end;
end;

procedure TDlg_TURV.N_PenaltyClick(Sender: TObject);
//клик на райтменю детального грида, ввод штрафа
begin
  inherited;
  InputPremium(True, 2);
end;

procedure TDlg_TURV.N_Penelty_1Click(Sender: TObject);
//райтменю основного грида, штраф
begin
  inherited;
  InputPremium(False, 2);
end;

procedure TDlg_TURV.N_PremiumClick(Sender: TObject);
//клик на райтменю детального грида, ввод премии
begin
  inherited;
  InputPremium(True, 1);
end;

procedure TDlg_TURV.N_Premium_1Click(Sender: TObject);
//райтменю основного грида, премия
begin
  inherited;
  InputPremium(False, 1);
end;

//параметры вывода подсказки детального гридва - покажем комментарии
procedure TDlg_TURV.DBGridEh2DataHintShow(Sender: TCustomDBGridEh;
  CursorPos: TPoint; Cell: TGridCoord; InCellCursorPos: TPoint;
  Column: TColumnEh; var Params: TDBGridEhDataHintParams;
  var Processed: Boolean);
var
  v1, v2, v3, v4: Variant;
begin
  inherited;
  if (Cell.X<=1)or(Cell.X>=1+16-1) then Exit;
  //получим комментарии
  v1:=''; v2:=''; v3:=''; v4:='';
  case Cell.Y of
    1: v1:=ArrTurv[DBGridEh1.Row-1][Cell.X-1][atComRuk];
    2: begin v2:=ArrTurv[DBGridEh1.Row-1][Cell.X-1][atComPar];  v4:=ArrTurv[DBGridEh1.Row-1][Cell.X-1][atNight]; end;
    3: v3:=ArrTurv[DBGridEh1.Row-1][Cell.X-1][atComSogl];
    4: v1:=ArrTurv[DBGridEh1.Row-1][Cell.X-1][atComPr];
    5: v1:=ArrTurv[DBGridEh1.Row-1][Cell.X-1][atComSct];
  end;
  //если мышка в верхнем лефом углу, вызовем метод формы посказки, а он уже покажет форму, если комментарий непустой,
  //также передаются координаты чтобы форма была помещена в нужном месте.
  if (InCellCursorPos.X <= 7)and(InCellCursorPos.Y <= 7)  then
    begin
      Dlg_TURV_Comment.ShowDialog(Self, CursorPos.X, CursorPos.Y + DBGridEh1.Row * DBGridEh1.RowHeight, v1, v2, v3, null);
    end;
  if ((InCellCursorPos.X <= 7)and(InCellCursorPos.Y >= DBGridEh2.CellRect(Cell.X, Cell.Y).Bottom - DBGridEh2.CellRect(Cell.X, Cell.Y).Top - 7))
    then begin
      Dlg_TURV_Comment.ShowDialog(Self, CursorPos.X, CursorPos.Y, null, null, null, v4);
    end;
end;


//двойной клик на детальной таблице
procedure TDlg_TURV.DBGridEh2DblClick(Sender: TObject);
var
  r, rr, d, i: Integer;
  v: array of string;
  vvv : Variant;
begin
  inherited;
  //вводим премию или штраф (тип данных определим автоматом на основе строки)
  if DBGridEh2.Col > 1 then InputPremium(True, 0)
end;


//ввод премии (сумма и коммент)
 //в какой сетке и режи - 0 авто, 1- премия, 2 - штраф
procedure TDlg_TURV.InputPremium(IsDetailGrid: Boolean; Mode: Integer);
var
  r, rr, d, i: Integer;
  v: array of string;
  vvv : Variant;
begin
  r:=DBGridEh1.Row-1;
  //строка в детальной, иначе 3-премия, 4 штраф
  rr:=S.IIf(Mode = 0, DBGridEh2.Row-1, S.IIf(Mode = 1, 3 ,4));
  //день турв
  if IsDetailGrid then d:=DBGridEh2.Col-1 else d:=DBGridEh1.Col-4;
  if ArrTurv[r][d][0] = -1 then exit;
{    //для последней строки - выработка
    if rr = 5 then begin
      if ArrTurv[r][d][0] = -1 then exit;
      //переводим мемтейбл в режим редактирования, иначе будет ошибка
      MemTableEh2.Edit;
      //изменяем данные в гриде, для того чтобы произошло событие изменения ячейки, в котором осуществляется ввод данных в массив.
      //так как данные здесь вводятся на основании значений массива, то мемтейбл можно тут испортить
      DBGridEh2.Columns[d].SetValueAsText('');
      //можно не делать пост, в событие попадем все равно
      MemTableEh2.Cancel;
    end
    //премии и штрафы
    else}
  //номер строки детального грида, 3-0 премии, 4 - штрафы
  if (rr =3) or (rr = 4) then begin
    if rr = 3 then i:= 0 else i:= 2; //смещение штрафа отн премии
    v:=[S.NSt(ArrTurv[r][d][atSumPr+i]), S.NSt(ArrTurv[r][d][atComPr+i])];
    if InEditMode and RgsEdit1 then begin
      //окно ввода
      if not InputQuery(S.IIf(rr = 3, 'Премия', 'Штраф'), ['Сумма', 'Комментарий'], v, nil) then Exit;
      //нужно ввести обязательно число, если не число то ничего не изменится, если 0 то премия удалится
      if S.IsNumber(v[0], 0, 99999, 0) then begin
        if v[0]='0'
          then begin
            ArrTurv[r][d][atSumPr+i] := null;
            ArrTurv[r][d][atComPr+i] := null;
          end
          else begin
            ArrTurv[r][d][atSumPr+i] := v[0];
            ArrTurv[r][d][atComPr+i] := v[1];
          end;
          //??? почему так?
          MemTableEh2.Edit;
          DBGridEh2.Columns[d].SetValueAsText('');
          MemTableEh2.Cancel;
      end;
    end
    else if (v[0]<>'')or(v[1]<>'') then begin
      //окно отображения премии, если она есть
      MyInfoMessage(S.IIf(rr = 3, 'Премия', 'Штраф')+#13#10#13#10'Сумма: '+v[0]+#13#10'Комментарий: '+v[1]);
    end;
  end;
end;

//ввод комментария
//в какой сетке, вид коммента - 0 авто, 1 - от мастеров/руководителя
procedure TDlg_TURV.InputComment(IsDetailGrid: Boolean; Mode: Integer);
var
  r, rr, rrr, d, i: Integer;
  v: array of string;
  st: string;
  ra, rsd: TVarDynArray;
begin
  r:=DBGridEh1.Row-1;
  rr:=S.IIf(Mode = 0, DBGridEh2.Row-1, 0);
  if IsDetailGrid then d:=DBGridEh2.Col-1 else d:=DBGridEh1.Col-4;
  if ArrTurv[r][d][0] = -1 then exit;
  ra:=[atComRuk, atComPar, atComSogl, atComPr, atComSct];
  rsd:=[atTRuk, atTPar, atTSogl, atTRuk, atTRuk];
  rrr:=ra[rr];
  //получим комментарии
  v:=[S.NSt(ArrTurv[r][d][rrr])];
  st:=v[0];
  if
    InEditMode and (
   ((rrr = atComRuk) and RgsEdit1) or
   ((rrr = atComPar) and RgsEdit2) or
   ((rrr = atComSogl) and RgsEdit3))
    then begin
      //окно ввода
      if not InputQuery('Комментарий', ['Комментарий'], v, nil) then Exit;
      if v[0] = st then Exit;
      ArrTurv[DBGridEh1.Row-1][d][rrr]:=v[0];
      //отобразим данные в основной таблице
      //(если это изменение в деатльной делается, то в основной значки комментов перерисуются при наведении мышки на ячейку!)
      SetTurvAllDay(r, d);
      //отобразим данные в детальной таблице
      SetTurvRowDetail(r, d);
      //запишем в БД
      SaveDayToDB(r, d, rsd[rr]);
    end
    else
      if v[0]<>'' then MyInfoMessage('Комментарий:'#13#10 + v[0]);
end;


procedure TDlg_TURV.Bt_CommentClick(Sender: TObject);
//кнопка на ровдетейлпанель - ввод комментария для работника, для всей строки турв
var
  r, d: Integer;
  v: array of string;
  st: string;
begin
  inherited;
  r:=DBGridEh1.Row-1;
  v:=[S.NSt(ArrTitle[r][6])];
  if (not InputQuery('Комментарий', ['Комментарий'], v, nil)) or (v[0]=S.NSt(ArrTitle[r][6])) then Exit;
  ArrTitle[r][6]:=v[0];
  SaveWorkerToDB(r);
  SetRowDetailCaptions;
  SetTurvAllDay(r, 1);
  Timer_AfterUpdate.Enabled:=True;
end;

procedure TDlg_TURV.Bt_PremiumClick(Sender: TObject);
//кнопка на ровдетейлпанель - ввод суммы премии за отчетный период для работника
var
  r, d: Integer;
  v: array of string;
  st: string;
begin
  inherited;
  r:=DBGridEh1.Row-1;
  v:=[S.NSt(ArrTitle[r][5])];
  if (not InputQuery('Премия', ['Сумма премии'], v, nil)) or (v[0]=S.NSt(ArrTitle[r][6])) or not S.IsNumber(v[0], 0, 99999999, 0)
    then Exit;
  ArrTitle[r][5]:=S.IIf(v[0] = '0', null, v[0]);
  SaveWorkerToDB(r);
  SetRowDetailCaptions;
  SetTurvAllDay(r, 1);
  Timer_AfterUpdate.Enabled:=True;
end;

{
procedure TDlg_TURV.MyShowHint(var HintStr: string; var CanShow: Boolean;
                                              var HintInfo: THintInfo);
var
        i : Integer;
begin
        for i := 0 to Application.ComponentCount - 1 do
        if Application.Components[i] is THintWindow then
            with THintWindow(Application.Components[i]).Canvas do
              begin
              Font.Name:= 'Arial';
              Font.Size:= 12;
              Font.Style:= [fsBold];
              // HintInfo.HintColor:= clWhite;
                        end;
end;
}

//no use
function  TDlg_TURV.GetDayNo(IsDetailGrid: Boolean): Integer;
begin
  if IsDetailGrid
    then Result:=DBGridEh2.Col-1
    else Result:=DBGridEh1.Col-4;
end;

procedure TDlg_TURV.SetRowDetailCaptions;
//показать в детальной панеле премию и комментарий пользователя, кнопки редактирования
begin
  if InLoad then Exit;
  Lb_Title_Worker.ResetColors;
  Lb_Title_Worker.SetCaptionAr(['$FF0000', ArrTitle[DBGridEh1.Row-1][2]]);
  Bt_Comment.Visible:=InEditMode;
  Bt_Comment.Width:=S.IIf(InEditMode, Bt_Comment.Height, 1);;
  Lb_Comment.Left:=Bt_Comment.Left + Bt_Comment.Width + 5;
  Bt_Premium.Visible:=InEditMode and RgsEdit1;
  Bt_Premium.Width:=S.IIf(InEditMode, Bt_Premium.Height, 1);;
  Lb_Premium.Left:=Bt_Premium.Left + Bt_Premium.Width + 5;
  Lb_Comment.Width:= Bt_Premium.Left - Lb_Comment.Left - 15;
  Lb_Comment.AutoSize:=False;
  Lb_Comment.ResetColors;
  Lb_Comment.SetCaptionAr(['Комментарий:$FF0000 ', S.IIf(S.NSt(ArrTitle[DBGridEh1.Row-1][6])<>'', ArrTitle[DBGridEh1.Row-1][6], 'нет')]);
  Lb_Comment.ShowHint:=Length(VarToStr(ArrTitle[DBGridEh1.Row-1][6])) > 150;
  Lb_Comment.Hint:=VarToStr(ArrTitle[DBGridEh1.Row-1][6]);
  Lb_Premium.ResetColors;
  Lb_Premium.SetCaptionAr(['Премия за период:$FF0000 ', FormatFloat('0.00', S.NNum(ArrTitle[DBGridEh1.Row-1][5]))]);
end;



constructor TDlg_TURV.ShowDialog(aOwner: TComponent; aFormDoc: string; aMode: TDialogType; aID: Variant; AMyFormOptions: TMyFormOptions);
begin
  inherited Create(aOwner, aFormDoc, [myfoDialog, myfoRefreshParent, myfoEnableMaximize], aMode, aID, null);
end;


procedure TDlg_TURV.DBGridEh1KeyPress(Sender: TObject; var Key: Char);
//нажатие клавишь на гриде
//вызывается и в инплейседитор
//но не вызывается на стрелки, потому перемещение по стрелкам сделать никак
//однако если поставить ЕнтерАсТаб, то при редактировании по энтер будет уходить вправо, а по стрелкам ввверх/вних и так уходит
var
  i: Integer;
  shift: Integer;
begin
  inherited;
  exit;
  //если бы перехватывались клавиши, можно было бы делат как-то так
  shift:=0;
  if DBGridEh1.InplaceEditor.Visible then begin
  //стрелки вверх и вниз работают и так!
//    if Key = #40 then shift:=+10;  //стрелка вниз
//    if Key = #38 then shift:=-10;  //стрелка вверх
    if Key = #39 then shift:=+1;  //стрелка вправо
    if Key = #37 then shift:=-1;  //стрелка влево
    if Key = #32 then shift:=+1;  //пробел
    //здесь нужно посылать энтер для завершения ввода, вычислять новую ячеку, а перемещать в таймере
    if shift <> 0
      then begin
        case shift of
          +10:  MemTableEh1.Next;
          -10:  MemTableEh1.Prior;
          //так как сделано здесь вводит данные уже в новом столбце
          //а если не менять столбец, то данные вводятся но грил не перересовывается, надо переключать фокус, для чего нужен доп элемент куда перейти
          +1:   begin Key:= #13; DBGridEh1.Col:=DBGridEh1.Col + 1; end;
          -1:   MemTableEh1.Next;
        end;
        Timer_AfterUpdate.Enabled:=True;
      end;
  end;
//
end;

procedure TDlg_TURV.ImporFromParsec(FileeName: string);
//импорт данных из парсек
//в парсек выгружается отчет приход/уход за месяц, снимается ОБЯЗАТЕЛЬНО выгрузка по одному подразделению на лист
//экспорт отчета осуществляется в формат эксель2007, ставится галка data only
//файл нужно открыть в эксель, будет ошибка и восстановление, и пресохранить
var
  XlsFile:TXlsMemFileEh;
  cr: IXlsFileCellsRangeEh;
  sh: TXlsWorksheetEh;
  v: Variant;
  st: string;
  dt, dt1, dt2, dt3, dt4: TDateTime;
  res: Boolean;
  d1, d2, d1p, cnt, i, j, k, m, cemp: Integer;
  va, va31: TVarDynArray;
  t1, t2, t3, t4, tp: extended;
  vt: TStringDynArray;
const
  rTitle = 8;
  cDtSost = 29;
  cDt1 = 33;
  cDt2 = 36;
  cFio = 1;
  cT = 3;
begin
  if not CreateTXlsMemFileEhFromExists(FileeName, False, '', XlsFile, st) then Exit;
  sh:=xlsFile.Workbook.Worksheets[0]; //регистр имеет значение!
  res:= False;
  repeat
//  st1:=sh.name;
  //читает значение, втч результат формулы
  //col, row с нуля
  v:=sh.cells[0, rTitle].Value;
  if VarToStr(v)<>'ТАБЕЛЬ'#13#10'учета рабочего времени'
    then begin
      MyWarningMessage('Этот файл не является выгрузкой из Parsec!');
      Break;
    end;
  //период за который выбираем данные
  dt1:=Dlg_Turv_FromParsec.De_1.Value;
  dt2:=Dlg_Turv_FromParsec.De_2.Value;
  //начало и конец месяца
  dt3:=EncodeDate(YearOf(PeriodStartDate), MonthOf(PeriodStartDate), 1);
  dt4:=IncDay(IncMonth(dt3, 1), -1);
  //в файле первая дата должна быть на начало месяца, а вторая не ранее введенной в форме импорта
  if (dt3 <> sh.Cells[cDt1, rTitle].value)or(dt2 > sh.Cells[cDt2, rTitle].value)
    then begin
      MyWarningMessage('Этот файл не является выгрузкой данных за нужный период!');
      Break;
    end;
//  v:=sh.cells[cDtSost, rTitle].Value;
  if MyQuestionMessage('Это выгрузка из Parsec от ' + VartoStr(sh.Cells[cDtSost, rTitle].Value) + #13#10'Продолжить?') <> mrYes
    then Break;
  DBGridEh1.RowDetailPanel.Visible:=False;
  //номер начального столбца в таблице парсек, с единицы, не учитывая смещения
  d1p:=trunc(dt1 - dt3 + 1);
  //номер начального столбца в турв
  d1:= trunc(dt1 - PeriodStartDate + 1);
  //количество затрагиваемых столбцов
  cnt:=trunc(dt2 - dt1 + 1);
  //время начала рабочего дня, из настроек модуля, там оно в часах и минутах - целые это часы, а дробная часть вминута, напр 8.30!
//  t3:=trunc(S.VarToFloat(S.IIf(IsOffice, 0, Module.W_Dinner_Time_Beg_2))) + frac(S.VarToFloat(S.IIf(IsOffice, 0, Module.W_Dinner_Time_Beg_Diff_2)))/60*100;
  t3:=trunc(Module.GetCfgVar(mycfgWtime_beg_2)) + frac(Module.GetCfgVar(mycfgWtime_beg_2))/60*100;
  //время, если раньше него началась работа, подсветим  ..то учитываем весь период и подсветим
  t4:=Max(t3 - S.VarToFloat(Module.GetCfgVar(mycfgWtime_beg_diff_2)), 0);

  SetLength(va31, 32);
  //проходим по турв
  for i:= 0 to High(ArrTurv) do begin
    cemp:=0;
    k:=0;
    //пока не накопилось двадцать пустых клеток по вертикали подряд, ищем данные
    while (cemp < 20) do begin
      v:=Sh.Cells[cFio, k].Value;
      if S.NSt(v) = ''
        then inc(cemp)
        else begin
          if UpperCase(S.NSt(v)) = UpperCase(ArrTitle[i, 2])
            then begin
              //совпадают ФИО в турв и отчете парсек
              m:=ct;
              //выгрузим всю строку по дням подряд
              //тк нет возможности получить заголовок с числами, а есть пустые столбцы, то делаем так
              for j:=1 to 31 do begin
                while S.NSt(Sh.Cells[m, k].Value) = '' do inc(m);
                va31[j]:=S.NSt(Sh.Cells[m, k].Value);
                m:=m + 1;
              end;
              //проходим начиная с первого требуемого дня требуемое количество дней
              for j:=d1 to d1 + cnt - 1 do begin
                //проставляем только для не серых, при времени порасеку либо коду еще не проставленному, но переписываем, если код по парсеку В
                //так как выходные могут быть проставлены заранее из производственного календаря
                if (ArrTurv[i][j][atExists] <> -1) and((ArrTurv[i][j][atTPar] = null)and((ArrTurv[i][j][atCPar] = null)or(ArrTurv[i][j][atCPar] = TurvCodeVyh))) then begin
                  //в ячейке временя прихода и ухода, разделенные переводом строки, часы и минуты через двоеточие
                  vt:=A.ExplodeS(StringReplace(va31[j + DayOf(PeriodStartDate) - 1], ':', FormatSettings.DecimalSeparator, [rfReplaceAll]) , #13#10);
                  //сохраним времена
                  if S.IsNumber(vt[0],0,23.59)
                    then ArrTurv[i][j][atBegTime]:=StrToFloat(vt[0])
                    else ArrTurv[i][j][atBegTime]:=-1;
                  if S.IsNumber(vt[1],0,23.59)
                    then ArrTurv[i][j][atEndTime]:=StrToFloat(vt[1])
                    else ArrTurv[i][j][atEndTime]:=-1;
                  t1:=ArrTurv[i][j][atBegTime];
                  t2:=ArrTurv[i][j][atEndTime];
                  if (t1 = -1)and(t2 = -1) then begin
                    //нет ни прихода ни ухода - поставим выходной
                    ArrTurv[i][j][atTPar]:=null;
                    ArrTurv[i][j][atCPar]:=TurvCodeVyh;
                  end
                  else if (t1 = -1)or(t2 = -1) then begin
                    //нет одного времени - поставим 8.00
                    ArrTurv[i][j][atTPar]:=8;
                    ArrTurv[i][j][atCPar]:=null;
                    ArrTurv[i][j][atSetTime]:=1;
                  end
                  else begin
                    //есть оба времени - посчитаем интервал
                    //17:42 = 17.7    7:12 = 7.2    10.5 - 0/5 = 10             8.80 * 4 = 35.2 = 36 / 4 = 9
                    //7.14 - 17.07    7.23 -  17.12 - 0.5 = 9.39 * 4 =  37.56 = 38 = 38/4 = 9.5
                    t1:=trunc(t1) + frac(t1)/60*100;
                    t2:=trunc(t2) + frac(t2)/60*100;
                    {//учтем начало рабочего дня
                    //берем после 8ч, но если начало ранее чем 8ч - 1ч, то берем по парсеку
                    if not IsOffice then
                      if t1 < t4 then begin
                        t1:=Max(t1, t3);
                        ArrTurv[i][j][atSetTime]:=1;
                      end;}
                    //для всех, начало работы принимаем в 8ч (из настроек)
                    t1:=Max(t1, t3);
                    tp:=abs(t2-t1);
                    tp:=Max(0, tp - S.VarToFloat(S.IIf(IsOffice, Module.GetCfgVar(mycfgWtime_dinner_1), Module.GetCfgVar(mycfgWtime_dinner_2))));
                    //округляем до сотых
//                    tp:=RoundTo(tp, -2);
                    if frac(tp) <= 0.33
                      then tp:=trunc(tp)
                      else if frac(tp) <= 0.83
                      then tp:=trunc(tp) + 0.5
                        else tp:=trunc(tp) + 1;
                    //так было бы округление до 15мин всегда в большую сторону
                    //tp:=SimpleRoundTo(tp * 4, 0);
                    //tp:=tp / 4;
                    ArrTurv[i][j][atTPar]:=tp;
                    ArrTurv[i][j][atCPar]:=null;
                    //подсветим (по цеху) кто вышел на час раньше начала рабочего дня
                    ArrTurv[i][j][atSetTime]:=S.IIf((t1<t4) and not IsOffice, 1, null);
                  end;
                  //запишем в датасет для грида
                  SetTurvAllDay(i, j);
                  //запишем в бд
                  SaveDayToDB(i, j, atTPar);
                end;
              end;
              Break;
            end;
          cemp:=0;
        end;
      inc(k);
    end;
  end;
  //обновим грид
  Timer_AfterUpdate.Enabled:=True;
  res:=True;
  until True;
  sh.Free;
  xlsfile.free;
end;

procedure TDlg_TURV.ExportToXlsxA7(Doc: Integer; Date1, Date2: Variant; AutoOpen: Boolean);
var
  i,j,d1,d2,x,y : Integer;
  sm, sum, sumall : Double;
  v: Variant;
  Rep: TA7Rep;
  FileName:string;
  dt1, dt2: TDateTime;
  b: Boolean;
  Range: Variant;
begin
  if Date2 < Date1 then Exit;
  if Doc = 0 then FileName:='ТУРВ по Parsec';
  FileName:=Module.GetReportFileXlsx(FileName);
  if FileName = '' then Exit;
  Rep:= TA7Rep.Create;
  try
    Rep.OpenTemplate(FileName);
  except
    Rep.Free;
    Exit;
  end;
//  dt1:=PeriodStartDate;
//  dt2:=PeriodEndDate;
  dt1:=Date1;
  dt2:=Date2;
  d1:=trunc(dt1 - PeriodStartDate + 1);
  d2:=trunc(dt2 - PeriodStartDate + 1);
  Rep.PasteBand('HEADER');
  Rep.SetValue('#MONTH#',DateToStr(PeriodStartDate) + ' - ' + DateToStr(PeriodEndDate));
  for j:= 1 to 16 do begin
    b:= (j >= d1) and (j<= d2);
    Rep.ExcelFind('#d' + IntToStr(j) + '#', x, y, xlValues);
    Rep.TemplateSheet.Columns[x].Hidden:=not b;
    if b then Rep.SetValue('#d' + IntToStr(j) + '#', IntToStr(DayOf(PeriodStartDate + j - 1)));
  end;
  for i:=0 to high(ArrTitle) do begin
     Rep.PasteBand('TABLE');
     Rep.SetValue('#N#',i + 1);
     Rep.SetValue('#FIO#',ArrTitle[i][2]);
     Rep.SetValue('#JOB#',ArrTitle[i][3]);
     sum:=0;
     for j:= d1 to d2 do begin
       v:=S.NSt(GetTurvCell(i, j, atTPar));
       if S.IsNumber(v, 0, 24) then sum:=sum + v;
       Rep.SetValue('#d' + IntToStr(j) + '#', v);
     end;
     Rep.SetValue('#ITOG#', sum);
     sumall:=0;
     for j:= 1 to 16 do begin
       v:=S.NSt(GetTurvCell(i, j, atTPar));
       if S.IsNumber(v, 0, 24) then sumall:=sumall + v;
     end;
     Rep.SetValue('#ITOGA#', sumall);
  end;
//  Rep.PasteBand('FOOTER');
//  Rep.SetValue('#дополнение#',M_Comm.Text);
  Rep.DeleteCol1;
  Rep.Show;
  Rep.Free;
  Exit;
end;

procedure TDlg_TURV.SundaysToTurv;
var
  v: Variant;
  st: string;
  dt, dt1: TDateTime;
  res: Boolean;
  i, j, k, m, d, rn: Integer;
  va, va1: TVarDynArray;
  va2: TVarDynArray2;
  b: Boolean;
begin
  //если в списке кодов нет буквы В то выход
  if TurvCodeVyh = -1 then Exit;
  //массив доступных типов данных
  va1:=[];
  if RgsEdit1 then va1:=va1 + ['Время руководителя'];
  if RgsEdit2 then va1:=va1 + ['Время по Parsec'];
  if RgsEdit3 then va1:=va1 + ['Согласованное время'];
  if Length(va1) = 0 then Exit;
  b:=False;
  if Length(va1) = 1 then begin
    b:=MyQuestionMessage('Проставить выходные и праздничные дни из Производственного календаря'#13#10'(' + VarToStr(va1[0] + ')'#13#10'?')) = mrYes;
    va:=[va1[0]];
  end
  else begin
    b:=TFrmBasicInput.ShowDialog(Self, '', [], fAdd, 'Выходные', 420, 210, [
//    b:=Dlg_BasicInput.ShowDialog(Self, 'Выходные', 420, 210, fAdd, [
        [cntComboL,'Проставить выходные и праздники для','1:500:0', 200]
       ],
       [
         VarArrayOf([va1[0], va1])
       ],
       va,
       [['']],
       nil
      ) >=0
  end;
  //выход, если действие было отменено
  if not b then Exit;
  //получим смещение в массиве
  k:=-1;
  if va[0] = 'Время руководителя' then k:= atTRuk;
  if va[0] = 'Время по Parsec' then k:= atTPar;
  if va[0] = 'Согласованное время' then k:= atTSogl;
  if k = -1 then Exit;
  //спрятать детальную панель - так как она не обновится
  DBGridEh1.RowDetailPanel.Visible:=False;
  //получим календарь за этот месяц
  va2:=Q.QLoadToVarDynArray2(
    'select dt, type, descr from ref_holidays where extract(year from dt) = :year$i and extract(month from dt) = :month$i order by dt',
    [YearOf(PeriodStartDate), MonthOf(PeriodStartDate)]
  );
  //проход по строкам турв
  for i:= 0 to High(ArrTurv) do begin
    //проход по столбцам
    for j:=1 to 16 do begin
      dt:=IncDay(PeriodStartDate, j - 1);
      if dt > PeriodEndDate then Break;
      //если ячейка не заполнена
      if (ArrTurv[i][j][atExists] <> -1)and(ArrTurv[i][j][k] = null)and(ArrTurv[i][j][k+3] = null) then begin
        //получим тип дня из календаря
        d:=0;
        for m:=0 to High(va2) do begin
          if dt = va2[m][0] then begin
            d:=Trunc(S.NNum(va2[m][1]));
          end;
        end;
        //отметим выходным, если праздник, или (сб,вс и при это не проставлен сокращенным или рабочим)
        if
          (d = 1)
          or
          ((DayOfTheWeek(dt) >= 6)and(d <> 2)and(d <> 3))
          then begin
            ArrTurv[i][j][k+3] := TurvCodeVyh;
            //запишем в датасет для грида
            SetTurvAllDay(i, j);
            //запишем в бд
            SaveDayToDB(i, j, k);
          end;
      end;
    end;
  end;
  //выведем данные из массива в таблицу - так надо делать если не ставить при изменениях SetTurvAllDay(i, j);
{  rn:=MemTableEh1.RecNo;
  for i := 1 to MemTableEh1.RecordCount do begin
    MemTableEh1.RecNo:=i;
    for j:=1 to 16 do begin
      SetTurvAllDay(i-1, j);
    end;
  end;
  MemTableEh1.RecNo:=rn;
  DBGridEh1.Refresh;}
  Timer_AfterUpdate.Enabled:=True;
end;

procedure TDlg_TURV.SendEMailToHead;
//сформируем письмо для руководителей отдела ТУРВ (тех, кто заполняет), с информацией о незаполненных ячейках и ячейках с расхождениями
//времн от руководителя и по парсеку, с указанием работников, чисел и времен
//и откроем сформированное письмо в Thunderbird
var
  i,j,k : Integer;
  v: Variant;
  st, st1: string;
  b, b1, b2: Boolean;
  va1: TVarDynArray;
  va11: TVarDynArray2;
begin
  b:=True; va1:=[]; va11:=[];
  //проверим что не все времена по парсеку введены
  for j:=0 to High(ArrTurv) do
    for i:=1 to DayColumnsCount do
      if (ArrTurv[j][i][atExists] <> -1) and (ArrTurv[j][i][atTPar] = null) and (ArrTurv[j][i][atCPar] = null)
        then begin
          b:=False;
          Break;
        end;
  if (not b) and (MyQuestionMessage('В этом ТУРВ еще не введены все данные по Parsec. Все равно продолжить?') <> mrYes) then Exit;
  //получим список работников по которым критические ошибки (красные ячейки) или не запонены данные от руководителя
  for j:=0 to High(ArrTurv) do
    for i:=1 to DayColumnsCount do
      if (ArrTurv[j][i][atExists] <> -1) and
         ((ArrTurv[j][i][atTRuk] = null) and (ArrTurv[j][i][atCRuk] = null) or (S.NNum(ArrTurv[j][i][atColor]) = 1))
        then begin
          va1:=va1 + [ArrTitle[j,2]];
          Break;
        end;
  //получим список работников и для них даты и времена, по которым есть расхождения с парсеком
  for j:=0 to High(ArrTurv) do begin
    st:='';
    for i:=1 to DayColumnsCount do
      if (ArrTurv[j][i][atExists] <> -1) and
         (ArrTurv[j][i][atCRuk] = null) and (ArrTurv[j][i][atCPar] = null) and
         (ArrTurv[j][i][atTRuk] <> null) and (ArrTurv[j][i][atTPar] <> null) and
         (ArrTurv[j][i][atTRuk] <> ArrTurv[j][i][atTPar])
        then S.ConcatStP(st, IntToStr(DayOf(PeriodStartDate) + i - 1) + ':' + VarToStr(ArrTurv[j][i][atTRuk]) + '/' + VarToStr(ArrTurv[j][i][atTPar]), ', ');
    if st <> '' then va11:=va11+ [[ArrTitle[j,2], st]];
  end;
  if (Length(va1) = 0)and(Length(va11) = 0)and
    (MyQuestionMessage('В этом ТУРВ, похоже, введены и согласованы все данные. Все равно сформировать письмо?') <> mrYes) then Exit;
  st:=
  'Внимание!'#13#10+
  'В этом ТУРВ есть недопустимые или несогласованные данные!'#13#10#13#10;
  if Length(va1) > 0 then
    st:=st +
      'Вы совсем не ввели данные, или же по ним имеются недопустимый расхождения (эти ячейки выделаны красным фоном) по следующим работникам:'#13#10 +
      A.Implode(va1, #13#10) +
      #13#10#13#10;
  if Length(va11) > 0 then begin
    st:=st +
      'Времена по следующим работникам, введенные руководителем, и по Parsec, различаются:'#13#10;
    for i:=0 to High(va11) do
      st:=st + va11[i][0] + ':.... ' + va11[i][1] + #13#10;
  end;
  if not b then
    st:=st + #13#10 + 'Важно: для этого ТУРВ еще заполнены не все времена по Parsec!!!';
  Module.MailSendWithThunderBird(
    S.NSt(Q.QSelectOneRow('select GetUsersEmail(:editusers$s) from dual', [EditUsers])[0]),
    'Необходимо поправить ТУРВ "' + DivisionName + '"',
    st,
    ''
    );
end;


end.
