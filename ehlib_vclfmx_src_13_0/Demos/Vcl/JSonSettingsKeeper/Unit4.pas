unit Unit4;

{$I EhLib.Inc}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  {$IFDEF FPC}
    Generics.Defaults, Generics.Collections,
  {$ELSE}
   {$IFDEF EH_LIB_17} System.Generics.Defaults, System.Generics.Collections, {$ENDIF}
  {$ENDIF}
  Dialogs, MemTableDataEh, Db, DBGridEhGrouping, ADODB, GridsEh, DBGridEh,
  MemTableEh, ToolCtrlsEh, DBGridEhToolCtrls, StdCtrls, Mask, DBCtrlsEh,
  ObjectInspectorEh, BaseFormUnit, SettingsKeepersEh,
  EhLibVclMTE,
  DBLookupEh, DynVarsEh, DBAxisGridsEh, EhLibVclUtils, Vcl.ExtCtrls, DBVertGridsEh;

type
  TForm4 = class(TBaseForm)
    MemTableEh1: TMemTableEh;
    DBGridEh1: TDBGridEh;
    DataSource1: TDataSource;
    ADOTable1: TADOTable;
    DBVertGridEh1: TDBVertGridEh;
    Splitter1: TSplitter;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  protected
    procedure ReadSettings(Keeper: TSettingsKeeperEh); override;
    procedure WriteSettings(Keeper: TSettingsKeeperEh); override;
  public
    { Public declarations }
    procedure WriteDBGridEhSettings(Keeper: TSettingsKeeperEh);
    procedure ReadDBGridEhSettings(Keeper: TSettingsKeeperEh);
  end;

var
  Form4: TForm4;

implementation

{$R *.dfm}

procedure TForm4.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F11 then
    ShowObjectInspectorForm(ActiveControl, Rect(Left+Width+10, Top, Left+Width+10+300, Top+Height));
end;

procedure TForm4.ReadSettings(Keeper: TSettingsKeeperEh);
var
  IntValue: Integer;
  GridSettings: TSettingsKeeperEh;
begin
  inherited ReadSettings(Keeper);
  if Keeper.TryGetIntegerValue('SplitterPosition', IntValue) then
  begin
    DBVertGridEh1.Width := IntValue;
  end;
  if Keeper.TryGetSubsettingsValue('DBGridEh1', GridSettings) then
  begin
    ReadDBGridEhSettings(GridSettings);
    //DBGridEh1.ReadSettings(GridSettings);
    //DBGridEh1.ApplyFilter;
  end;
  if Keeper.TryGetSubsettingsValue('DBVertGridEh1', GridSettings) then
  begin
    DBVertGridEh1.ReadSettings(GridSettings);
  end;

end;

procedure TForm4.WriteSettings(Keeper: TSettingsKeeperEh);
begin
  inherited WriteSettings(Keeper);

  //Keeper.Add('DBGridEh1', DBGridEh1.WriteSettings(TSettingsKeeperEh.Create));
  WriteDBGridEhSettings(Keeper);
  Keeper.Add('DBVertGridEh1', DBVertGridEh1.WriteSettings(TSettingsKeeperEh.Create));
  Keeper.Add('SplitterPosition', DBVertGridEh1.Width);
end;

procedure TForm4.ReadDBGridEhSettings(Keeper: TSettingsKeeperEh);
var
  DataGroupingSettings: TSettingsKeeperEh;

  KeeperArray: TArray<TPair<String,TObject>>;
  SetPair: TPair<String,TObject>;
  I: Integer;
  GroupLevel: TGridDataGroupLevelEh;
  GroupLevelSettings: TSettingsKeeperEh;
  StrValue: String;
begin
  DBGridEh1.ReadSettings(Keeper);
  DBGridEh1.ApplyFilter;

  if Keeper.TryGetSubsettingsValue('DataGrouping', DataGroupingSettings) then
  begin

    KeeperArray := DataGroupingSettings.ToArray();
    {$IFDEF FPC}
    //TArray.Sort<TPair<String,TObject>>(KeeperArray, TSettingsKeeperEhCollectionByIndexComparer.Ordinal);
    {$ELSE}
    TArray.Sort<TPair<String,TObject>>(KeeperArray, TSettingsKeeperEhCollectionByIndexComparer.Ordinal);
    {$ENDIF}


    DBGridEh1.DataGrouping.GroupLevels.BeginUpdate;
    for i := 0 to Length(KeeperArray)-1 do
    begin
      SetPair := KeeperArray[i];
      GroupLevel := DBGridEh1.DataGrouping.GroupLevels.Add;
      GroupLevel.Column := DBGridEh1.FindFieldColumn(SetPair.Key);
      GroupLevelSettings := SetPair.Value as TSettingsKeeperEh;
      if (GroupLevelSettings <> nil) and
         GroupLevelSettings.TryGetStringValue('SortOrder', StrValue) then
      begin
        SetEnumPropValueAsString(GroupLevel, 'SortOrder', StrValue);
      end;
    end;
    DBGridEh1.DataGrouping.GroupLevels.EndUpdate;

  end;
end;

procedure TForm4.WriteDBGridEhSettings(Keeper: TSettingsKeeperEh);
var
  DBGridEh1Settings: TSettingsKeeperEh;
  DataGroupingSettings: TSettingsKeeperEh;
  ColGroupingSettings: TSettingsKeeperEh;
  GroupLevel: TGridDataGroupLevelEh;
  I: Integer;
begin
  DBGridEh1Settings := TSettingsKeeperEh.Create;
  DBGridEh1.WriteSettings(DBGridEh1Settings);

  if (DBGridEh1.DataGrouping.GroupLevels.Count > 0) then
  begin
    DataGroupingSettings := TSettingsKeeperEh.Create;

    for I := 0 to DBGridEh1.DataGrouping.GroupLevels.Count - 1 do
    begin
      GroupLevel := DBGridEh1.DataGrouping.GroupLevels[i];
      ColGroupingSettings := TSettingsKeeperEh.Create;
      ColGroupingSettings.Add('SortOrder', GetEnumPropValueAsString(GroupLevel, 'SortOrder'));
      DataGroupingSettings.Add(TColumnEh(GroupLevel.Column).FieldName, ColGroupingSettings);
    end;

    DBGridEh1Settings.Add('DataGrouping', DataGroupingSettings);
  end;

  Keeper.Add('DBGridEh1', DBGridEh1Settings);
end;

end.
