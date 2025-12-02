unit uGameEngine;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections;

type
  TLocation = class;
  TGameUIEvent = procedure(LocationName, ImageName: string) of object;

  TLocation = class
  private
    FName: string;
    FDescription: string;
    FImageRes: string;
    FExits: TDictionary<string, TLocation>;
    FItems: TStringList;
  public
    constructor Create(const AName, ADescription, AImageRes: string);
    destructor Destroy; override;
    procedure AddExit(const ACommand: string; ATarget: TLocation);
    function GetExit(const ACommand: string): TLocation;
    property Name: string read FName;
    property Description: string read FDescription;
    property ImageRes: string read FImageRes;
    property Items: TStringList read FItems;
  end;

  TGame = class
  private
    FLocations: TObjectList<TLocation>;
    FCurrentLocation: TLocation;
    FOutputLog: TStrings;
    FInventory: TStringList;
    FOnUpdateUI: TGameUIEvent;
    procedure BuildSolarSystem;
    procedure Look;
    procedure ListInventory;
    procedure TakeItem(const AItemName: string);
  public
    constructor Create;
    destructor Destroy; override;
    function ProcessCommand(const AInput: string): string;
    property OutputLog: TStrings read FOutputLog write FOutputLog;
    property OnUpdateUI: TGameUIEvent read FOnUpdateUI write FOnUpdateUI;
  end;

implementation

{ TLocation }

constructor TLocation.Create(const AName, ADescription, AImageRes: string);
begin
  FName := AName;
  FDescription := ADescription;
  FImageRes := AImageRes;
  FExits := TDictionary<string, TLocation>.Create;
  FItems := TStringList.Create;
end;

destructor TLocation.Destroy;
begin
  FExits.Free;
  FItems.Free;
  inherited;
end;

procedure TLocation.AddExit(const ACommand: string; ATarget: TLocation);
begin
  FExits.Add(ACommand.ToLower, ATarget);
end;

function TLocation.GetExit(const ACommand: string): TLocation;
begin
  if not FExits.TryGetValue(ACommand.ToLower, Result) then
    Result := nil;
end;

{ TGame }

constructor TGame.Create;
begin
  FLocations := TObjectList<TLocation>.Create(True);
  FInventory := TStringList.Create;
  BuildSolarSystem;
end;

destructor TGame.Destroy;
begin
  FInventory.Free;
  FLocations.Free;
  inherited;
end;

procedure TGame.BuildSolarSystem;
var
  ShipBridge, Airlock, MoonBase, MarsColony, CeresStation: TLocation;
begin
  ShipBridge := TLocation.Create('UES Copernicus - Bridge', 
    'You are on the command deck. The "Airlock" is to the South.', 'img_bridge');
  
  Airlock := TLocation.Create('Transporter Room', 
    'The warp drive hums. Navigate to: "warp moon", "warp mars", "warp ceres".', 'img_airlock');
    Airlock.Items.Add('Space Suit'); 

  MoonBase := TLocation.Create('Luna - Armstrong Outpost', 
    'The gray dust of the moon stretches endlessly.', 'img_moon');
    MoonBase.Items.Add('Moon Rock');
    MoonBase.Items.Add('Helium-3 Canister');

  MarsColony := TLocation.Create('Mars - Olympus Mons', 
    'Red dust coats the mag-lev tracks.', 'img_mars');
    MarsColony.Items.Add('Red Sand Sample');

  CeresStation := TLocation.Create('Ceres - The Belt Hub', 
    'A hollowed-out asteroid city.', 'img_ceres');
    CeresStation.Items.Add('Ice Chunk');

  FLocations.AddRange([ShipBridge, Airlock, MoonBase, MarsColony, CeresStation]);

  ShipBridge.AddExit('south', Airlock);
  Airlock.AddExit('north', ShipBridge);
  Airlock.AddExit('warp moon', MoonBase);
  Airlock.AddExit('warp mars', MarsColony);
  Airlock.AddExit('warp ceres', CeresStation);
  
  MoonBase.AddExit('return', Airlock);
  MarsColony.AddExit('return', Airlock);
  CeresStation.AddExit('return', Airlock);

  FCurrentLocation := ShipBridge;
end;

procedure TGame.Look;
var
  I: Integer;
begin
  if Assigned(FOutputLog) then
  begin
    FOutputLog.Add('');
    FOutputLog.Add('--- ' + FCurrentLocation.Name + ' ---');
    FOutputLog.Add(FCurrentLocation.Description);
    if FCurrentLocation.Items.Count > 0 then
    begin
      FOutputLog.Add('Visible Items:');
      for I := 0 to FCurrentLocation.Items.Count - 1 do
        FOutputLog.Add(' - ' + FCurrentLocation.Items[I]);
    end;
    FOutputLog.Add('Exits: ' + string.Join(', ', FCurrentLocation.FExits.Keys.ToArray));
    FOutputLog.Add('');
  end;
  if Assigned(FOnUpdateUI) then
    FOnUpdateUI(FCurrentLocation.Name, FCurrentLocation.ImageRes);
end;

procedure TGame.ListInventory;
begin
  if Assigned(FOutputLog) then
  begin
    FOutputLog.Add('INVENTORY:');
    if FInventory.Count = 0 then FOutputLog.Add(' (Empty)')
    else FOutputLog.Add(FInventory.Text);
  end;
end;

procedure TGame.TakeItem(const AItemName: string);
var
  Idx: Integer;
begin
  Idx := -1;
  for var I := 0 to FCurrentLocation.Items.Count - 1 do
    if SameText(FCurrentLocation.Items[I], AItemName) then
    begin
      Idx := I;
      Break;
    end;

  if Idx <> -1 then
  begin
    FInventory.Add(FCurrentLocation.Items[Idx]);
    FOutputLog.Add('Taken: ' + FCurrentLocation.Items[Idx]);
    FCurrentLocation.Items.Delete(Idx); 
  end
  else
    FOutputLog.Add('Item not found here.');
end;

function TGame.ProcessCommand(const AInput: string): string;
var
  Cmd, Param: string;
  SpacePos: Integer;
  NextLoc: TLocation;
begin
  Cmd := AInput.Trim;
  Param := '';
  SpacePos := Pos(' ', Cmd);
  if SpacePos > 0 then
  begin
    Param := Copy(Cmd, SpacePos + 1, Length(Cmd));
    Cmd := Copy(Cmd, 1, SpacePos - 1);
  end;
  Cmd := Cmd.ToLower;

  if Cmd = 'look' then begin Look; Exit; end;
  if (Cmd = 'inventory') or (Cmd = 'i') then begin ListInventory; Exit; end;
  if Cmd = 'take' then begin TakeItem(Param); Exit; end;

  NextLoc := FCurrentLocation.GetExit(Cmd + ' ' + Param);
  if NextLoc = nil then NextLoc := FCurrentLocation.GetExit(Cmd);

  if Assigned(NextLoc) then
  begin
    FCurrentLocation := NextLoc;
    Look;
  end
  else
    if Assigned(FOutputLog) then FOutputLog.Add('Unknown command.');
end;

end.
