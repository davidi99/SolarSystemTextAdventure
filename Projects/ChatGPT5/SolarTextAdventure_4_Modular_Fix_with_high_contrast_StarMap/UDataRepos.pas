unit UDataRepos;

interface

uses System.Generics.Collections, System.SysUtils;

type
  TAchievement = record
    Id: string;
    Name: string;
    Desc: string;
    Unlocked: Boolean;
  end;

  TCodexEntry = record
    Id: string;
    Title: string;
    Text: string;
    Unlocked: Boolean;
  end;

  TAchievementRepo = class
  public
    Data: TDictionary<string, TAchievement>;
    constructor Create;
    destructor Destroy; override;
    procedure Seed;
    function Unlock(const Id: string): Boolean; // returns True if newly unlocked
  end;

  TCodexRepo = class
  public
    Data: TDictionary<string, TCodexEntry>;
    constructor Create;
    destructor Destroy; override;
    procedure Seed;
    function Unlock(const Id: string): Boolean;
  end;

implementation

{ TAchievementRepo }

constructor TAchievementRepo.Create;
begin
  inherited;
  Data := TDictionary<string, TAchievement>.Create;
end;

destructor TAchievementRepo.Destroy;
begin
  Data.Free;
  inherited;
end;

procedure TAchievementRepo.Seed;
var A: TAchievement;
  procedure Add(const id,name,desc: string);
  begin
    A.Id := id; A.Name := name; A.Desc := desc; A.Unlocked := False;
    Data.AddOrSetValue(A.Id, A);
  end;
begin
  Add('ach_first_jump','First Jump','Leave L1 for the first time');
  Add('ach_inner_scout','Inner Scout','Visit Mercury, Venus and Luna');
  Add('ach_martian','Martian Trails','Ride a rover on Mars');
  Add('ach_beltalowda','Belter Bravo','Dock at Ceres');
  Add('ach_jovian','Jovian Journeys','Unlock Europa or Io');
  Add('ach_titan','Titan Touchdown','Reach Titan');
  Add('ach_edge','Edge of the Sun','Stand on Pluto');
end;

function TAchievementRepo.Unlock(const Id: string): Boolean;
var A: TAchievement;
begin
  Result := False;
  if Data.TryGetValue(Id, A) then
  begin
    if not A.Unlocked then
    begin
      A.Unlocked := True;
      Data[Id] := A;
      Exit(True);
    end;
  end;
end;

{ TCodexRepo }

constructor TCodexRepo.Create;
begin
  inherited;
  Data := TDictionary<string, TCodexEntry>.Create;
end;

destructor TCodexRepo.Destroy;
begin
  Data.Free;
  inherited;
end;

procedure TCodexRepo.Seed;
var E: TCodexEntry;
  procedure Add(const id,title,txt: string);
  begin
    E.Id := id; E.Title := title; E.Text := txt; E.Unlocked := False;
    Data.AddOrSetValue(E.Id, E);
  end;
begin
  Add('mercury','Mercury','A small, airless world with polar cold-traps holding volatiles.');
  Add('venus','Venus','Habitable pressures at ~55 km; sulfuric acid clouds and aerostats.');
  Add('luna','Moon (Luna)','Artemis City thrives near the south pole; ice in shadowed craters.');
  Add('mars','Mars','Thin air, dust storms, and sprawling canyons like Valles Marineris.');
  Add('ceres','Ceres','Dwarf planet with brines and bright salts at Occator crater.');
  Add('ganymede','Ganymede','Largest moon; intrinsic magnetic field; subsurface ocean.');
  Add('europa','Europa','Icy shell over a salty ocean; possible chemistry for life.');
  Add('io','Io','Most volcanic body; tidal heating powers eruptions.');
  Add('titan','Titan','Thick nitrogen atmosphere; methane lakes and dunes.');
  Add('pluto','Pluto','Cold nitrogen glaciers of Sputnik Planitia.');
end;

function TCodexRepo.Unlock(const Id: string): Boolean;
var E: TCodexEntry;
begin
  Result := False;
  if Data.TryGetValue(Id, E) then
  begin
    if not E.Unlocked then
    begin
      E.Unlocked := True;
      Data[Id] := E;
      Exit(True);
    end;
  end;
end;

end.
