unit DataModuleUnit;

interface

uses
  System.SysUtils, System.Classes, MemTableDataEh, Data.DB,
  System.UITypes, System.UIConsts, System.Contnrs,
  Generics.Collections, System.DateUtils,
  EhLib.TableLink.TypedLists,
  EhLibRtl.Api, MemTableEh, System.ImageList, FMX.ImgList;

type
  TContactListItemType = (LetterCaption, Data);
  TCountryInfo = class;

  TDataModule1 = class(TDataModule)
    mtFishFacts: TMemTableEh;
    mpPhoneContacts: TMemTableEh;
    mtCountriesThreeTextBlocks: TMemTableEh;
    mtOrders: TMemTableEh;
    imLstPaymentTypes: TImageList;
    mtContinents: TMemTableEh;
    mtCountries: TMemTableEh;
    mtCustOrdersItems: TMemTableEh;

    procedure DataModuleDestroy(Sender: TObject);
  private

    FContactsGroupedByNameLink: TBaseTableDataLinkEh;
    FContactsGroupedByNameList: TList<TPersistent>;

    FCallsHistoryLink: TBaseTableDataLinkEh;
    FCallsHistoryList: TObjectList<TPersistent>;

    FCountryListTableLink: TBaseTableDataLinkEh;
    FCountryList: TObject;

    FCountryGroupedListTableLink: TListTableLinkEh;
    FCountryGroupedList: TObjectList;
  public
    function GetContactsGroupedByName(): TBaseTableDataLinkEh;
    function GetCallsHistory(): TBaseTableDataLinkEh;
    function GetImageIndexByPaymentMethod(PaymentMethod: String): Integer;

    function GetCountriesAsList(): TBaseTableDataLinkEh;
    function GetCountriesGroupedAsList(): TBaseTableDataLinkEh;
    function CreateCountriesArray: TArray<TCountryInfo>;

  end;

{ TContactListItem }

  TContactListItem = class(TPersistent)
  private
    FRowType: TContactListItemType;
    FLastName: String;
    FContactId: Integer;
    FPhone: String;
    FFirstName: String;
    FPictureColor: TAlphaColor;
  public
//    procedure Init();
    constructor Create(ARowType: TContactListItemType;
      AContactId: Integer; AFirstName: String; ALastName: String; APhone: String); overload;
    constructor Create(); overload;
  published
    property RowType: TContactListItemType read FRowType write FRowType;
    property ContactId: Integer read FContactId write FContactId;
    property FirstName: String read FFirstName write FFirstName;
    property LastName: String read FLastName write FLastName;
    property Phone: String read FPhone write FPhone;
    property PictureColor: TAlphaColor read FPictureColor write FPictureColor;
  end;

{ TListGroupCaption }

  TListGroupCaption = class(TPersistent)
  private
    FCaption: String;
  published
    property Caption: String read FCaption write FCaption;
  end;

  TCallType = (Incoming, Outgoing, Missed);

{ TCallHistoryItem }

  TCallHistoryItem = class(TPersistent)
  private
    FCallType: TCallType;
    FPhoneNumber: String;
    FContactCaption: String;
    FSimCardNumber: Integer;
    FCallDateTime: TDateTime;
  public
    constructor Create;
  published
     property CallType: TCallType read FCallType write FCallType; // (incoming, outgoing, missed)
     property CallDateTime: TDateTime read FCallDateTime write FCallDateTime;
     property PhoneNumber: String read FPhoneNumber write FPhoneNumber;
     property ContactCaption: String read FContactCaption write FContactCaption;
     property SimCardNumber: Integer read FSimCardNumber write FSimCardNumber;
  end;

{ TCountryInfo }

  TCountryInfo = class(TPersistent)
  private
    FName: String;
    FCapital: String;
    FContinent: String;
    FArea: Integer;
    FPopulation: Double;
  public
    property Name: String read FName write FName;
    property Capital: String read FCapital write FCapital;
    property Continent: String read FContinent write FContinent;
    property Area: Integer read FArea write FArea;
    property Population: Double read FPopulation write FPopulation;
  end;

var
  DataModule1: TDataModule1;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

{ TDataModule1 }

procedure TDataModule1.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(FContactsGroupedByNameLink);
  FreeAndNil(FContactsGroupedByNameList);

  FreeAndNil(FCallsHistoryLink);
  FreeAndNil(FCallsHistoryList);

  FreeAndNil(FCountryListTableLink);
  FreeAndNil(FCountryList);

  FreeAndNil(FCountryGroupedListTableLink);
  FreeAndNil(FCountryGroupedList);
end;

function TDataModule1.GetCallsHistory: TBaseTableDataLinkEh;
var
  AList: TObjectList<TPersistent>;
  ListItem: TCallHistoryItem;
  CaptionItem: TListGroupCaption;
  I: Integer;
  CurDateTime, NextDateTime: TDateTime;
  SecondsToAdd: Integer;
  ContactId: Integer;
  CallType: Integer;

begin

  if FCallsHistoryLink = nil then
  begin
    AList := TObjectList<TPersistent>.Create;

//    NextDateTime := Now();
    CurDateTime := IncDay(Today());
    for I := 0 to 200 do
    begin
      SecondsToAdd := Random(60*60*24 div 2);
      NextDateTime := IncSecond(CurDateTime, -SecondsToAdd);
      if DateOf(NextDateTime) <> DateOf(CurDateTime) then
      begin
        CaptionItem := TListGroupCaption.Create;
        if DateOf(NextDateTime) = Today() then
          CaptionItem.Caption := 'Today'
        else if DateOf(NextDateTime) = IncDay(Today(), -1) then
          CaptionItem.Caption := 'Yesterday'
        else if YearOf(NextDateTime) = YearOf(Today()) then
          CaptionItem.Caption := FormatDateTime('dddd, d mmmmm', NextDateTime)
        else
          CaptionItem.Caption := FormatDateTime('dddd, d mmmmm yyyy', NextDateTime);

        AList.Add(CaptionItem);
      end;
      CurDateTime := NextDateTime;

      ListItem := TCallHistoryItem.Create;
      CallType := Random(10);
      if CallType < 5 then
        ListItem.CallType := TCallType.Incoming
      else if CallType < 9 then
        ListItem.CallType := TCallType.Outgoing
      else
        ListItem.CallType := TCallType.Missed;

      ListItem.CallDateTime := CurDateTime;

      ContactId := Random(1200) * -1;
      if mpPhoneContacts.Locate('ContactId', ContactId, []) then
      begin
        ListItem.ContactCaption := mpPhoneContacts.FieldByName('FirstName').AsString + ' ' + mpPhoneContacts.FieldByName('LastName').AsString;
        ListItem.PhoneNumber := mpPhoneContacts.FieldByName('Phone').AsString;
      end else
      begin
        ListItem.PhoneNumber := '+555 ' + Random(99999999).ToString;
      end;

      ListItem.SimCardNumber := Random(2) + 1;

      AList.Add(ListItem);
    end;

    FCallsHistoryList := AList;

    FCallsHistoryLink := TListTableLinkEh<TPersistent>.Create(nil);
    TListTableLinkEh<TPersistent>(FCallsHistoryLink).SetList(FCallsHistoryList);
  end;

  Result := FCallsHistoryLink;
end;

function TDataModule1.GetContactsGroupedByName: TBaseTableDataLinkEh;
var
  AList: TObjectList<TPersistent>;
  ListItem: TContactListItem;
  CaptionItem: TListGroupCaption;
  CaptionItemKey: String;
  CaptionItemNextKey: String;
begin
  if FContactsGroupedByNameLink = nil then
  begin
    AList := TObjectList<TPersistent>.Create;

    mpPhoneContacts.Filter := '[BigListItem] = False';
    mpPhoneContacts.Filtered := True;

    mpPhoneContacts.SortByFields('FirstName');
    mpPhoneContacts.DisableControls;
    mpPhoneContacts.First;

    CaptionItem := TListGroupCaption.Create;
    CaptionItemKey := Copy(mpPhoneContacts.FieldByName('FirstName').AsString, 1, 1);
    CaptionItem.Caption := CaptionItemKey;
    AList.Add(CaptionItem);

    while not mpPhoneContacts.Eof do
    begin
      CaptionItemNextKey := Copy(mpPhoneContacts.FieldByName('FirstName').AsString, 1, 1);
      if CaptionItemKey <> CaptionItemNextKey then
      begin
        CaptionItem := TListGroupCaption.Create;
        CaptionItemKey := CaptionItemNextKey;
        CaptionItem.Caption := CaptionItemKey;
        AList.Add(CaptionItem);
      end;

      ListItem := TContactListItem.Create;
      with ListItem do
      begin
        RowType := TContactListItemType.Data;
        ContactId := mpPhoneContacts.FieldByName('ContactId').AsInteger;
        FirstName := mpPhoneContacts.FieldByName('FirstName').AsString;
        LastName := mpPhoneContacts.FieldByName('LastName').AsString;
        Phone := mpPhoneContacts.FieldByName('Phone').AsString;
//        Randomize;
        PictureColor := HSLtoRGB(Random(255)/255, 100/255, 160/255);
      end;
      AList.Add(ListItem);

      mpPhoneContacts.Next;
    end;
    mpPhoneContacts.EnableControls;

    FContactsGroupedByNameList := AList;

    FContactsGroupedByNameLink := TListTableLinkEh<TPersistent>.Create(nil);
    TListTableLinkEh<TPersistent>(FContactsGroupedByNameLink).SetList(FContactsGroupedByNameList);
  end;

  Result := FContactsGroupedByNameLink;
end;

function TDataModule1.GetImageIndexByPaymentMethod(PaymentMethod: String): Integer;
begin
  if PaymentMethod = 'AmEx' then
    Result := 0
  else if PaymentMethod = 'Cash' then
    Result := 1
  else if PaymentMethod = 'Check' then
    Result := 5
  else if PaymentMethod = 'COD' then
    Result := 2
  else if PaymentMethod = 'Credit' then
    Result := -1
  else if PaymentMethod = 'MC' then
    Result := 3
  else if PaymentMethod = 'Visa' then
    Result := 4
  else
    Result := -1
end;

function TDataModule1.GetCountriesAsList: TBaseTableDataLinkEh;
var
  AList: TObjectList<TCountryInfo>;
begin

  if FCountryListTableLink = nil then
  begin
    AList := TObjectList<TCountryInfo>.Create;
    AList.AddRange(CreateCountriesArray);

    FCountryList := AList;

    FCountryListTableLink := TListTableLinkEh<TCountryInfo>.Create(nil);
    TListTableLinkEh<TCountryInfo>(FCountryListTableLink).SetList(AList);
  end;

  Result := FCountryListTableLink;
end;

function TDataModule1.GetCountriesGroupedAsList(): TBaseTableDataLinkEh;
var
  AList: TObjectList;
  AGroupedList: TObjectList;
  ListItem: TCountryInfo;
  Countries: TArray<TCountryInfo>;
  GroupCaptionRow: TListGroupCaption;
  MyElem: TCountryInfo;
  CurGroupKey: String;
begin

  if FCountryGroupedListTableLink = nil then
  begin
    Countries := CreateCountriesArray();
    AList := TObjectList.Create(False);
    for ListItem in Countries do
      AList.Add(ListItem);

    AList.SortList(
      function(ALeft, ARight: Pointer): Integer
      begin
        Result := CompareStr(TCountryInfo(ALeft).Continent, TCountryInfo(ARight).Continent);
      end
    );

    AGroupedList := TObjectList.Create;

    CurGroupKey := '';
    for MyElem in AList do
    begin
      if MyElem.Continent <> CurGroupKey then
      begin
        GroupCaptionRow := TListGroupCaption.Create;
        GroupCaptionRow.Caption := MyElem.Continent;
        AGroupedList.Add(GroupCaptionRow);
        CurGroupKey := MyElem.Continent;
      end;

      AGroupedList.Add(MyElem);
    end;

    FCountryGroupedList := AGroupedList;

    FCountryGroupedListTableLink := TListTableLinkEh.Create(nil);
    FCountryGroupedListTableLink.SetList(FCountryGroupedList, TypeInfo(TCountryInfo));

    AList.Free;
  end;

  Result := FCountryGroupedListTableLink;
end;

function TDataModule1.CreateCountriesArray: TArray<TCountryInfo>;
var
  AList: TList<TCountryInfo>;
  ListItem: TCountryInfo;
begin
  AList := TList<TCountryInfo>.Create;

  ListItem := TCountryInfo.Create;
  with ListItem do
  begin
    Name := 'Argentina'; Capital := 'Buenos Aires';  Continent := 'South America'; Area := 2777815; Population := 32300003;
  end;
  AList.Add(ListItem);

  ListItem := TCountryInfo.Create;
  with ListItem do
  begin
    Name := 'Bolivia'; Capital := 'La Paz';  Continent := 'South America'; Area := 1098575; Population := 7300000;
  end;
  AList.Add(ListItem);

  ListItem := TCountryInfo.Create;
  with ListItem do
  begin
    Name := 'Brazil'; Capital := 'Brasilia';  Continent := 'South America'; Area := 8511196; Population := 150400000;
  end;
  AList.Add(ListItem);

  ListItem := TCountryInfo.Create;
  with ListItem do
  begin
    Name := 'Canada'; Capital := 'Ottawa';  Continent := 'North America'; Area := 9976147; Population := 26500000;
  end;
  AList.Add(ListItem);

  ListItem := TCountryInfo.Create;
  with ListItem do
  begin
    Name := 'Chile'; Capital := 'Santiago';  Continent := 'South America'; Area := 756943; Population := 13200000;
  end;
  AList.Add(ListItem);

  ListItem := TCountryInfo.Create;
  with ListItem do
  begin
    Name := 'Colombia'; Capital := 'Bagota';  Continent := 'South America'; Area := 1138907; Population := 33000000;
  end;
  AList.Add(ListItem);

  ListItem := TCountryInfo.Create;
  with ListItem do
  begin
    Name := 'Cuba'; Capital := 'Havana';  Continent := 'North America'; Area := 114524; Population := 10600000;
  end;
  AList.Add(ListItem);

  Result := AList.ToArray;

  AList.Free;
end;

{ TContactListItem }

constructor TContactListItem.Create(ARowType: TContactListItemType;
  AContactId: Integer; AFirstName, ALastName, APhone: String);
begin
  FRowType := ARowType;
  FLastName := ALastName;
  FFirstName := AFirstName;
  FContactId := AContactId;
  FPhone := APhone;
end;

constructor TContactListItem.Create;
begin
end;

{ TCallHistoryItem }

constructor TCallHistoryItem.Create;
begin
  inherited Create;
end;

end.
