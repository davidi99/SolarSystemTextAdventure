unit uMainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Memo, FMX.ScrollBox, FMX.Controls.Presentation, FMX.Edit,
  FMX.Objects, FMX.Effects, FMX.Ani, System.Generics.Collections;

type
  TLocation = class
  private
    FName: string;
    FDescription: string;
    FOptions: TStringList;
    FDestinations: TStringList;
    FDiscovered: Boolean;
    FFacts: TStringList;
  public
    constructor Create(const AName, ADescription: string);
    destructor Destroy; override;
    procedure AddOption(const AOption, ADestination: string);
    procedure AddFact(const AFact: string);
    property Name: string read FName;
    property Description: string read FDescription;
    property Options: TStringList read FOptions;
    property Destinations: TStringList read FDestinations;
    property Discovered: Boolean read FDiscovered write FDiscovered;
    property Facts: TStringList read FFacts;
  end;

  TMainForm = class(TForm)
    LayoutMain: TLayout;
    RectBackground: TRectangle;
    LayoutTop: TLayout;
    LabelTitle: TLabel;
    RectTitle: TRectangle;
    LayoutCenter: TLayout;
    MemoStory: TMemo;
    RectStoryBg: TRectangle;
    LayoutBottom: TLayout;
    BtnOption1: TButton;
    BtnOption2: TButton;
    BtnOption3: TButton;
    BtnOption4: TButton;
    RectConsole: TRectangle;
    LabelStats: TLabel;
    GlowEffect1: TGlowEffect;
    ShadowEffect1: TShadowEffect;
    FloatAnimation1: TFloatAnimation;
    StyleBook1: TStyleBook;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnOption1Click(Sender: TObject);
    procedure BtnOption2Click(Sender: TObject);
    procedure BtnOption3Click(Sender: TObject);
    procedure BtnOption4Click(Sender: TObject);
  private
    FLocations: TObjectDictionary<string, TLocation>;
    FCurrentLocation: TLocation;
    FDiscoveredCount: Integer;
    FVisitedLocations: TStringList;
    procedure InitializeLocations;
    procedure UpdateDisplay;
    procedure NavigateTo(const ALocationName: string);
    procedure UpdateStats;
  public
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

{ TLocation }

constructor TLocation.Create(const AName, ADescription: string);
begin
  inherited Create;
  FName := AName;
  FDescription := ADescription;
  FOptions := TStringList.Create;
  FDestinations := TStringList.Create;
  FFacts := TStringList.Create;
  FDiscovered := False;
end;

destructor TLocation.Destroy;
begin
  FOptions.Free;
  FDestinations.Free;
  FFacts.Free;
  inherited;
end;

procedure TLocation.AddOption(const AOption, ADestination: string);
begin
  FOptions.Add(AOption);
  FDestinations.Add(ADestination);
end;

procedure TLocation.AddFact(const AFact: string);
begin
  FFacts.Add(AFact);
end;

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FLocations := TObjectDictionary<string, TLocation>.Create([doOwnsValues]);
  FVisitedLocations := TStringList.Create;
  FDiscoveredCount := 0;
  
  // Debug output
  MemoStory.Lines.Add('Initializing locations...');
  
  InitializeLocations;
  
  // Debug output
  MemoStory.Lines.Add(Format('Loaded %d locations', [FLocations.Count]));
  
  NavigateTo('EARTH_ORBIT');
  
  // Start the pulse animation
  FloatAnimation1.Start;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FLocations.Free;
  FVisitedLocations.Free;
end;

procedure TMainForm.InitializeLocations;
var
  Loc: TLocation;
begin
  // EARTH ORBIT - Starting point
  Loc := TLocation.Create('EARTH_ORBIT', 
    'You are aboard the ISV EXPLORER, humanity''s most advanced interplanetary vessel, currently in low Earth orbit. ' +
    'The blue marble of Earth fills your viewport, its swirling clouds and deep oceans a reminder of home. ' +
    'Your mission: conduct the first comprehensive survey of our solar system. ' + #13#10#13#10 +
    'The ship''s AI announces: "All systems nominal. Navigation computer ready. Where shall we venture first, Commander?"');
  Loc.AddOption('Set course for the Moon', 'MOON');
  Loc.AddOption('Head toward the Inner Planets (Mercury/Venus)', 'INNER_PLANETS');
  Loc.AddOption('Journey to Mars', 'MARS');
  Loc.AddOption('Venture to the Asteroid Belt', 'ASTEROID_BELT');
  FLocations.Add('EARTH_ORBIT', Loc);

  // MOON
  Loc := TLocation.Create('MOON', 
    'The Moon looms large before you, its ancient cratered surface bathed in harsh sunlight. ' +
    'You descend toward the Sea of Tranquility, where humanity first set foot on another world. ' + #13#10#13#10 +
    'Scanning reveals ice deposits in permanently shadowed craters near the poles - crucial resources for future colonies. ' +
    'The Apollo landing sites are visible below, preserved forever in the airless environment.');
  Loc.AddFact('Diameter: 3,474 km');
  Loc.AddFact('Gravity: 16.6% of Earth');
  Loc.AddFact('Distance from Earth: 384,400 km');
  Loc.AddOption('Explore the Tycho Crater', 'MOON_TYCHO');
  Loc.AddOption('Return to Earth Orbit', 'EARTH_ORBIT');
  Loc.AddOption('Continue to Inner Planets', 'INNER_PLANETS');
  Loc.AddOption('Head to Mars', 'MARS');
  FLocations.Add('MOON', Loc);

  // MOON - TYCHO CRATER
  Loc := TLocation.Create('MOON_TYCHO', 
    'Tycho Crater spreads before you - a massive impact basin 85 km across with bright rays extending across the lunar surface. ' +
    'The central peak rises 2 km above the crater floor. Your sensors detect unusual mineral compositions - ' +
    'evidence of the massive impact that created this landmark 108 million years ago.' + #13#10#13#10 +
    'This is one of the youngest major craters on the Moon, and its rays are visible from Earth with the naked eye.');
  Loc.AddFact('Age: 108 million years');
  Loc.AddFact('Depth: 4.8 km');
  Loc.AddFact('Impact energy: Equivalent to billions of megatons');
  Loc.AddOption('Return to Moon orbit', 'MOON');
  Loc.AddOption('Head to Earth Orbit', 'EARTH_ORBIT');
  Loc.AddOption('Journey to Mars', 'MARS');
  FLocations.Add('MOON_TYCHO', Loc);

  // INNER PLANETS HUB
  Loc := TLocation.Create('INNER_PLANETS', 
    'You''ve entered the realm of the inner planets - the rocky worlds closest to the Sun. ' +
    'Mercury and Venus orbit ahead, both hostile environments yet fascinating worlds. ' + #13#10#13#10 +
    'Mercury, the swift messenger, races around the Sun every 88 days. Venus, shrouded in thick clouds, ' +
    'hides a hellish surface beneath. Which world calls to you?');
  Loc.AddOption('Approach Mercury', 'MERCURY');
  Loc.AddOption('Descend toward Venus', 'VENUS');
  Loc.AddOption('Return to Earth Orbit', 'EARTH_ORBIT');
  Loc.AddOption('Head to Mars', 'MARS');
  FLocations.Add('INNER_PLANETS', Loc);

  // MERCURY
  Loc := TLocation.Create('MERCURY', 
    'Mercury rises before you - a world of extremes. The Sun appears three times larger here than from Earth. ' +
    'The surface is a barren landscape of craters and ancient lava plains, scorched by solar radiation. ' + #13#10#13#10 +
    'Temperatures swing from 430°C in sunlight to -180°C in shadow. Despite its proximity to the Sun, ' +
    'ice exists in permanently shadowed craters at the poles. The Caloris Basin, a massive impact crater, ' +
    'dominates one hemisphere.');
  Loc.AddFact('Diameter: 4,879 km (smallest planet)');
  Loc.AddFact('Year: 88 Earth days');
  Loc.AddFact('Day: 59 Earth days');
  Loc.AddFact('Surface temp: -180°C to 430°C');
  Loc.AddOption('Explore Caloris Basin', 'MERCURY_CALORIS');
  Loc.AddOption('Return to Inner Planets hub', 'INNER_PLANETS');
  Loc.AddOption('Continue to Venus', 'VENUS');
  FLocations.Add('MERCURY', Loc);

  // MERCURY - CALORIS BASIN
  Loc := TLocation.Create('MERCURY_CALORIS', 
    'The Caloris Basin stretches 1,550 km across Mercury''s surface - one of the largest impact craters in the solar system. ' +
    'The impact was so violent that it created chaotic terrain on the exact opposite side of the planet. ' + #13#10#13#10 +
    'The basin floor is filled with smooth plains of ancient lava. Spider-like patterns of fractures radiate from its center. ' +
    'This impact literally reshaped the entire planet 3.9 billion years ago.');
  Loc.AddFact('Diameter: 1,550 km');
  Loc.AddFact('Age: 3.9 billion years');
  Loc.AddFact('The impact caused seismic waves that traveled around the planet');
  Loc.AddOption('Return to Mercury orbit', 'MERCURY');
  Loc.AddOption('Journey to Venus', 'VENUS');
  FLocations.Add('MERCURY_CALORIS', Loc);

  // VENUS
  Loc := TLocation.Create('VENUS', 
    'Venus appears through your viewport - Earth''s evil twin. Thick sulfuric acid clouds swirl in the atmosphere, ' +
    'hiding the surface completely. Your sensors penetrate the clouds: the surface pressure is 92 times Earth''s, ' +
    'and the temperature is 465°C - hot enough to melt lead. ' + #13#10#13#10 +
    'A runaway greenhouse effect has turned this world into hell. Yet radar mapping reveals continents, mountains, ' +
    'and thousands of volcanoes. Venus rotates backwards, and its day is longer than its year.');
  Loc.AddFact('Diameter: 12,104 km (almost identical to Earth)');
  Loc.AddFact('Surface pressure: 92 times Earth');
  Loc.AddFact('Surface temp: 465°C (constant day and night)');
  Loc.AddFact('Rotates backwards - sun rises in west');
  Loc.AddOption('Scan Maxwell Montes mountain', 'VENUS_MAXWELL');
  Loc.AddOption('Return to Inner Planets hub', 'INNER_PLANETS');
  Loc.AddOption('Head to Mars', 'MARS');
  FLocations.Add('VENUS', Loc);

  // VENUS - MAXWELL MONTES
  Loc := TLocation.Create('VENUS_MAXWELL', 
    'Your radar pierces the clouds to reveal Maxwell Montes - the highest mountain on Venus at 11 km tall, ' +
    'taller than Mount Everest. Despite the scorching temperatures at lower elevations, the mountain peak is cool enough ' +
    'that metallic "snow" of lead sulfide and bismuth sulfide covers its summit. ' + #13#10#13#10 +
    'This is one of the few features on Venus named after a man (James Clerk Maxwell). ' +
    'The mountain is part of Ishtar Terra, one of two continental regions on Venus.');
  Loc.AddFact('Height: 11 km above mean surface');
  Loc.AddFact('Features metallic "snow" on peak');
  Loc.AddFact('Named after physicist James Clerk Maxwell');
  Loc.AddOption('Return to Venus orbit', 'VENUS');
  Loc.AddOption('Journey to Mars', 'MARS');
  FLocations.Add('VENUS_MAXWELL', Loc);

  // MARS
  Loc := TLocation.Create('MARS', 
    'The Red Planet fills your screen. Mars appears as a rusty orange sphere, its polar ice caps gleaming white. ' +
    'Ancient river valleys scar the surface - evidence that water once flowed here. Olympus Mons, the largest volcano ' +
    'in the solar system, rises from the surface. ' + #13#10#13#10 +
    'Mars has two small moons: Phobos and Deimos. The thin atmosphere glows with a faint red hue. ' +
    'This world may have once harbored life - and might still, deep underground.');
  Loc.AddFact('Diameter: 6,779 km');
  Loc.AddFact('Day: 24.6 hours (similar to Earth)');
  Loc.AddFact('Year: 687 Earth days');
  Loc.AddFact('Atmosphere: 95% CO2, 1% of Earth''s pressure');
  Loc.AddOption('Land near Olympus Mons', 'MARS_OLYMPUS');
  Loc.AddOption('Explore Valles Marineris canyon', 'MARS_VALLES');
  Loc.AddOption('Visit moon Phobos', 'PHOBOS');
  Loc.AddOption('Continue to Asteroid Belt', 'ASTEROID_BELT');
  FLocations.Add('MARS', Loc);

  // MARS - OLYMPUS MONS
  Loc := TLocation.Create('MARS_OLYMPUS', 
    'Olympus Mons dominates the landscape - a shield volcano so massive it would cover the entire state of Arizona. ' +
    'At 21 km tall and 600 km across, it''s the largest volcano in the solar system. The caldera at its summit ' +
    'is 80 km wide and 3 km deep. ' + #13#10#13#10 +
    'The volcano is so large that if you stood on its summit, the slope would extend beyond the horizon in all directions. ' +
    'It formed over billions of years of lava flows in Mars'' lower gravity.');
  Loc.AddFact('Height: 21 km (2.5 times Everest)');
  Loc.AddFact('Base diameter: 600 km');
  Loc.AddFact('Last erupted: ~25 million years ago');
  Loc.AddOption('Return to Mars orbit', 'MARS');
  Loc.AddOption('Explore Valles Marineris', 'MARS_VALLES');
  FLocations.Add('MARS_OLYMPUS', Loc);

  // MARS - VALLES MARINERIS
  Loc := TLocation.Create('MARS_VALLES', 
    'Valles Marineris stretches before you - a canyon system so vast it dwarfs the Grand Canyon. ' +
    'It spans 4,000 km across Mars (one-fifth the planet''s circumference) and plunges 7 km deep in places. ' + #13#10#13#10 +
    'This isn''t a water-carved canyon - it formed as Mars'' crust stretched and cracked billions of years ago. ' +
    'Landslides have created walls that dwarf any cliff on Earth. Morning fogs sometimes fill the canyon floor, ' +
    'and layered rocks tell the story of Mars'' ancient past.');
  Loc.AddFact('Length: 4,000 km');
  Loc.AddFact('Depth: up to 7 km');
  Loc.AddFact('Width: up to 200 km');
  Loc.AddFact('If on Earth, would span USA coast to coast');
  Loc.AddOption('Return to Mars orbit', 'MARS');
  Loc.AddOption('Visit Phobos moon', 'PHOBOS');
  FLocations.Add('MARS_VALLES', Loc);

  // PHOBOS
  Loc := TLocation.Create('PHOBOS', 
    'Phobos, the larger of Mars'' two moons, appears as a dark, potato-shaped rock covered in craters and grooves. ' +
    'It orbits just 6,000 km above Mars - so close that it completes three orbits per Martian day. ' + #13#10#13#10 +
    'Tidal forces are slowly dragging Phobos closer to Mars. In 50 million years, it will either crash into Mars ' +
    'or break apart into a ring. The mysterious grooves covering its surface may be early signs of this breakup. ' +
    'The giant Stickney crater covers nearly half of one side.');
  Loc.AddFact('Dimensions: 27 × 22 × 18 km');
  Loc.AddFact('Orbital period: 7 hours 39 minutes');
  Loc.AddFact('Moving closer to Mars at 1.8 cm per year');
  Loc.AddFact('Named after Greek god of fear');
  Loc.AddOption('Return to Mars', 'MARS');
  Loc.AddOption('Visit Deimos', 'DEIMOS');
  Loc.AddOption('Head to Asteroid Belt', 'ASTEROID_BELT');
  FLocations.Add('PHOBOS', Loc);

  // DEIMOS
  Loc := TLocation.Create('DEIMOS', 
    'Deimos, Mars'' smaller moon, is a tiny, irregularly shaped rock just 15 km across. ' +
    'It orbits farther from Mars than Phobos, taking 30 hours to complete one orbit. ' + #13#10#13#10 +
    'From Mars'' surface, Deimos would appear as a bright star, not a moon. Its surface is smoother than Phobos, ' +
    'covered in a thick layer of regolith (space dust). Named after the Greek god of terror, ' +
    'this peaceful little moon may be a captured asteroid.');
  Loc.AddFact('Dimensions: 15 × 12 × 11 km');
  Loc.AddFact('Orbital period: 30 hours');
  Loc.AddFact('Named after Greek god of terror');
  Loc.AddFact('Likely a captured asteroid');
  Loc.AddOption('Return to Mars', 'MARS');
  Loc.AddOption('Return to Phobos', 'PHOBOS');
  Loc.AddOption('Journey to Asteroid Belt', 'ASTEROID_BELT');
  FLocations.Add('DEIMOS', Loc);

  // ASTEROID BELT
  Loc := TLocation.Create('ASTEROID_BELT', 
    'You''ve entered the asteroid belt - a vast region between Mars and Jupiter filled with millions of rocky bodies. ' +
    'Despite popular depiction, the asteroids are widely spaced. The largest, Ceres, is now classified as a dwarf planet. ' + #13#10#13#10 +
    'These are the building blocks of planets that never formed, prevented by Jupiter''s massive gravity. ' +
    'Some asteroids are solid metal, others are rubble piles, and some even have their own tiny moons.');
  Loc.AddOption('Approach Ceres (dwarf planet)', 'CERES');
  Loc.AddOption('Investigate Vesta', 'VESTA');
  Loc.AddOption('Return to Mars', 'MARS');
  Loc.AddOption('Continue to Jupiter system', 'JUPITER_SYSTEM');
  FLocations.Add('ASTEROID_BELT', Loc);

  // CERES
  Loc := TLocation.Create('CERES', 
    'Ceres, the largest object in the asteroid belt and a dwarf planet, appears as a gray, spherical world. ' +
    'At 940 km across, it contains one-third of the entire asteroid belt''s mass. ' + #13#10#13#10 +
    'Mysterious bright spots gleam from Occator Crater - deposits of sodium carbonate left by ice volcanoes. ' +
    'Beneath the surface, a subsurface ocean may still exist. Ceres is more like an icy moon than a rocky asteroid, ' +
    'perhaps a visitor from the outer solar system.');
  Loc.AddFact('Diameter: 940 km');
  Loc.AddFact('Mass: 1/3 of asteroid belt total');
  Loc.AddFact('Discovered: 1801 (first asteroid found)');
  Loc.AddFact('May have subsurface ocean');
  Loc.AddOption('Return to Asteroid Belt', 'ASTEROID_BELT');
  Loc.AddOption('Visit Vesta', 'VESTA');
  FLocations.Add('CERES', Loc);

  // VESTA
  Loc := TLocation.Create('VESTA', 
    'Vesta appears as a battered, colorful world - the brightest asteroid visible from Earth. ' +
    'A massive impact crater near its south pole is so deep you can see Vesta''s mantle exposed. ' + #13#10#13#10 +
    'Vesta is a protoplanet - it began forming into a planet 4.5 billion years ago, developing a core, mantle, and crust, ' +
    'but never grew larger. It''s the source of many meteorites found on Earth, blasted off by ancient impacts.');
  Loc.AddFact('Diameter: 525 km');
  Loc.AddFact('Has differentiated core, mantle, and crust');
  Loc.AddFact('Source of HED meteorites on Earth');
  Loc.AddFact('South pole impact is 460 km wide, 19 km deep');
  Loc.AddOption('Return to Asteroid Belt', 'ASTEROID_BELT');
  Loc.AddOption('Head to Jupiter system', 'JUPITER_SYSTEM');
  FLocations.Add('VESTA', Loc);

  // JUPITER SYSTEM
  Loc := TLocation.Create('JUPITER_SYSTEM', 
    'Jupiter dominates your view - a massive gas giant with swirling cloud bands and the Great Red Spot, ' +
    'a storm larger than Earth that has raged for centuries. Jupiter has 95 known moons, ' +
    'including the four Galilean moons: Io, Europa, Ganymede, and Callisto. ' + #13#10#13#10 +
    'Jupiter''s magnetic field is 20,000 times stronger than Earth''s, creating intense radiation belts. ' +
    'This giant world contains more mass than all other planets combined.');
  Loc.AddFact('Diameter: 139,820 km (11 times Earth)');
  Loc.AddFact('Mass: 318 times Earth');
  Loc.AddFact('Day: 10 hours (fastest rotation)');
  Loc.AddFact('Has 95 known moons');
  Loc.AddOption('Visit volcanic moon Io', 'IO');
  Loc.AddOption('Explore ocean moon Europa', 'EUROPA');
  Loc.AddOption('Survey giant moon Ganymede', 'GANYMEDE');
  Loc.AddOption('Continue to Saturn system', 'SATURN_SYSTEM');
  FLocations.Add('JUPITER_SYSTEM', Loc);

  // IO
  Loc := TLocation.Create('IO', 
    'Io appears as a sulfur-yellow and orange world - the most volcanically active body in the solar system. ' +
    'Hundreds of volcanoes dot its surface, some shooting plumes of sulfur dioxide 500 km into space. ' + #13#10#13#10 +
    'Jupiter''s intense tidal forces squeeze and flex Io, generating enormous heat. ' +
    'The surface is constantly being resurfaced by lava flows - there are no impact craters because they''re quickly buried. ' +
    'Lakes of molten lava glow on the night side.');
  Loc.AddFact('Diameter: 3,643 km');
  Loc.AddFact('Over 400 active volcanoes');
  Loc.AddFact('Surface temperature: -143°C to 1,600°C');
  Loc.AddFact('Tidally heated by Jupiter');
  Loc.AddOption('Return to Jupiter system', 'JUPITER_SYSTEM');
  Loc.AddOption('Visit Europa', 'EUROPA');
  FLocations.Add('IO', Loc);

  // EUROPA
  Loc := TLocation.Create('EUROPA', 
    'Europa gleams like a cracked ice ball - its surface is one of the smoothest in the solar system. ' +
    'Red-brown cracks crisscross the white ice, filled with salts and sulfur compounds. ' + #13#10#13#10 +
    'Beneath the ice shell, which may be only 15-25 km thick, lies a global ocean of liquid water, ' +
    'possibly 100 km deep - containing twice as much water as all of Earth''s oceans. ' +
    'Geysers may erupt from cracks in the ice. This is one of the most likely places to find life in our solar system.');
  Loc.AddFact('Diameter: 3,122 km');
  Loc.AddFact('Subsurface ocean: ~100 km deep');
  Loc.AddFact('Ice shell: 15-25 km thick');
  Loc.AddFact('Possible hydrothermal vents on ocean floor');
  Loc.AddOption('Return to Jupiter system', 'JUPITER_SYSTEM');
  Loc.AddOption('Visit Ganymede', 'GANYMEDE');
  FLocations.Add('EUROPA', Loc);

  // GANYMEDE
  Loc := TLocation.Create('GANYMEDE', 
    'Ganymede looms before you - the largest moon in the solar system, bigger than the planet Mercury. ' +
    'Its surface shows a patchwork of dark, heavily cratered terrain and bright, younger grooved terrain. ' + #13#10#13#10 +
    'Ganymede is the only moon with its own magnetic field, suggesting it has a liquid iron core. ' +
    'Like Europa, it likely has a subsurface ocean sandwiched between layers of ice. ' +
    'A thin oxygen atmosphere surrounds this remarkable world.');
  Loc.AddFact('Diameter: 5,268 km (larger than Mercury)');
  Loc.AddFact('Only moon with its own magnetic field');
  Loc.AddFact('Has subsurface ocean');
  Loc.AddFact('Surface is mix of old and young terrain');
  Loc.AddOption('Return to Jupiter system', 'JUPITER_SYSTEM');
  Loc.AddOption('Continue to Saturn', 'SATURN_SYSTEM');
  FLocations.Add('GANYMEDE', Loc);

  // SATURN SYSTEM
  Loc := TLocation.Create('SATURN_SYSTEM', 
    'Saturn appears in all its glory - the ringed giant. The magnificent ring system spans 280,000 km but is only ' +
    '10 meters thick in places. Made of billions of ice particles, the rings shimmer and sparkle. ' + #13#10#13#10 +
    'Saturn has 146 known moons. Titan, larger than Mercury, has a thick atmosphere and methane lakes. ' +
    'Enceladus shoots geysers of water into space from a subsurface ocean. ' +
    'Saturn itself is a gas giant made mostly of hydrogen, with winds reaching 1,800 km/h.');
  Loc.AddFact('Diameter: 116,460 km');
  Loc.AddFact('Density: Would float in water');
  Loc.AddFact('Ring span: 280,000 km');
  Loc.AddFact('Has 146 known moons');
  Loc.AddOption('Explore Titan', 'TITAN');
  Loc.AddOption('Visit Enceladus', 'ENCELADUS');
  Loc.AddOption('Study the Rings', 'SATURN_RINGS');
  Loc.AddOption('Journey to Uranus', 'URANUS_SYSTEM');
  FLocations.Add('SATURN_SYSTEM', Loc);

  // TITAN
  Loc := TLocation.Create('TITAN', 
    'Titan emerges from the orange haze - Saturn''s largest moon and the only moon in the solar system with a substantial atmosphere. ' +
    'The thick nitrogen atmosphere (1.5 times Earth''s pressure) creates a greenhouse effect, but it''s still -179°C at the surface. ' + #13#10#13#10 +
    'Methane lakes and seas dot the polar regions - the only other world besides Earth with stable surface liquids. ' +
    'Rivers of liquid methane carve valleys through water-ice bedrock. Cryovolcanoes may erupt liquid water instead of lava. ' +
    'In many ways, Titan is like an early frozen Earth.');
  Loc.AddFact('Diameter: 5,150 km (larger than Mercury)');
  Loc.AddFact('Surface pressure: 1.5 times Earth');
  Loc.AddFact('Surface temp: -179°C');
  Loc.AddFact('Has methane weather cycle like Earth''s water cycle');
  Loc.AddOption('Return to Saturn system', 'SATURN_SYSTEM');
  Loc.AddOption('Visit Enceladus', 'ENCELADUS');
  FLocations.Add('TITAN', Loc);

  // ENCELADUS
  Loc := TLocation.Create('ENCELADUS', 
    'Enceladus shines brilliantly - its icy surface reflects nearly 100% of sunlight. ' +
    'Dramatic geysers erupt from "tiger stripe" fractures near the south pole, shooting water ice particles ' +
    '100 km into space. These particles form Saturn''s E-ring. ' + #13#10#13#10 +
    'The geysers come from a global subsurface ocean. Chemical analysis shows the water contains salts, ' +
    'organic compounds, and molecular hydrogen - all ingredients for life. ' +
    'Tidal heating from Saturn keeps the ocean liquid despite the moon''s small size.');
  Loc.AddFact('Diameter: 504 km');
  Loc.AddFact('Geysers reach 100 km altitude');
  Loc.AddFact('Global subsurface ocean');
  Loc.AddFact('Most reflective body in solar system');
  Loc.AddOption('Return to Saturn system', 'SATURN_SYSTEM');
  Loc.AddOption('Study Saturn''s rings', 'SATURN_RINGS');
  FLocations.Add('ENCELADUS', Loc);

  // SATURN RINGS
  Loc := TLocation.Create('SATURN_RINGS', 
    'You navigate through Saturn''s magnificent ring system. Billions of ice particles orbit in precise bands, ' +
    'from tiny grains to house-sized chunks. The rings span 280,000 km but in places are only 10 meters thick. ' + #13#10#13#10 +
    'Gaps in the rings are carved by "shepherd moons" whose gravity sculpts the particles. ' +
    'The Cassini Division - a 4,800 km gap - is visible even from Earth. ' +
    'The rings may be only 100 million years old - formed when a moon was torn apart by tidal forces.');
  Loc.AddFact('Main rings span: 280,000 km');
  Loc.AddFact('Thickness: 10 meters to 1 km');
  Loc.AddFact('Composition: 99% water ice');
  Loc.AddFact('Age: possibly only 100 million years');
  Loc.AddOption('Return to Saturn system', 'SATURN_SYSTEM');
  Loc.AddOption('Continue to Uranus', 'URANUS_SYSTEM');
  FLocations.Add('SATURN_RINGS', Loc);

  // URANUS SYSTEM
  Loc := TLocation.Create('URANUS_SYSTEM', 
    'Uranus appears as a pale blue-green sphere - the ice giant of the solar system. ' +
    'Its most striking feature is its extreme tilt: Uranus rotates on its side, with its poles taking turns facing the Sun. ' + #13#10#13#10 +
    'The planet has faint rings and 27 known moons, all named after Shakespeare and Pope characters. ' +
    'Made mostly of water, methane, and ammonia ices around a rocky core, Uranus is incredibly cold (-224°C). ' +
    'The methane in its atmosphere absorbs red light, giving it the cyan color.');
  Loc.AddFact('Diameter: 50,724 km');
  Loc.AddFact('Axial tilt: 98° (rotates on its side)');
  Loc.AddFact('Temperature: -224°C');
  Loc.AddFact('Has 27 known moons and 13 rings');
  Loc.AddOption('Visit moon Miranda', 'MIRANDA');
  Loc.AddOption('Explore moon Titania', 'TITANIA');
  Loc.AddOption('Journey to Neptune', 'NEPTUNE_SYSTEM');
  Loc.AddOption('Head to Kuiper Belt', 'KUIPER_BELT');
  FLocations.Add('URANUS_SYSTEM', Loc);

  // MIRANDA
  Loc := TLocation.Create('MIRANDA', 
    'Miranda, the strangest moon of Uranus, displays a chaotic, fractured surface unlike anything else in the solar system. ' +
    'Enormous canyons, cliffs 20 km high (12 times deeper than the Grand Canyon), and a patchwork of different terrains ' +
    'suggest the moon was shattered and reassembled multiple times. ' + #13#10#13#10 +
    'Verona Rupes, the tallest known cliff, plunges 20 km. In Miranda''s low gravity, a rock dropped from the top ' +
    'would take 12 minutes to hit bottom. The moon may have a subsurface ocean.');
  Loc.AddFact('Diameter: 472 km');
  Loc.AddFact('Verona Rupes: tallest known cliff (20 km)');
  Loc.AddFact('Surface shows signs of past tidal heating');
  Loc.AddFact('May have been shattered and reformed');
  Loc.AddOption('Return to Uranus system', 'URANUS_SYSTEM');
  Loc.AddOption('Visit Titania', 'TITANIA');
  FLocations.Add('MIRANDA', Loc);

  // TITANIA
  Loc := TLocation.Create('TITANIA', 
    'Titania, the largest moon of Uranus, presents a heavily cratered icy surface crisscrossed by enormous fault canyons. ' +
    'These rifts stretch hundreds of kilometers - evidence that Titania''s interior once froze and expanded, ' +
    'cracking the surface like an overflowing ice cube tray. ' + #13#10#13#10 +
    'The moon is composed of roughly equal amounts of rock and ice. A reddish material, possibly organic compounds ' +
    'created by radiation, covers parts of the surface.');
  Loc.AddFact('Diameter: 1,578 km');
  Loc.AddFact('Largest moon of Uranus');
  Loc.AddFact('Surface shows extensional faults');
  Loc.AddFact('Named after fairy queen in A Midsummer Night''s Dream');
  Loc.AddOption('Return to Uranus system', 'URANUS_SYSTEM');
  Loc.AddOption('Journey to Neptune', 'NEPTUNE_SYSTEM');
  FLocations.Add('TITANIA', Loc);

  // NEPTUNE SYSTEM
  Loc := TLocation.Create('NEPTUNE_SYSTEM', 
    'Neptune, the deep blue giant, marks the edge of the major planets. Dark blue methane clouds swirl across its surface, ' +
    'driven by the fastest winds in the solar system - up to 2,100 km/h. The Great Dark Spot, a storm system, ' +
    'appears and disappears over the years. ' + #13#10#13#10 +
    'Neptune radiates more heat than it receives from the Sun. It has 16 known moons and faint rings. ' +
    'The largest moon, Triton, orbits backwards and is slowly spiraling toward Neptune.');
  Loc.AddFact('Diameter: 49,244 km');
  Loc.AddFact('Winds: up to 2,100 km/h (fastest in solar system)');
  Loc.AddFact('Temperature: -214°C');
  Loc.AddFact('Has 16 known moons');
  Loc.AddOption('Visit Triton', 'TRITON');
  Loc.AddOption('Journey to Kuiper Belt', 'KUIPER_BELT');
  Loc.AddOption('Return toward inner solar system', 'JOURNEY_END');
  FLocations.Add('NEPTUNE_SYSTEM', Loc);

  // TRITON
  Loc := TLocation.Create('TRITON', 
    'Triton, Neptune''s largest moon, is one of the coldest objects in the solar system at -235°C. ' +
    'Its pinkish surface of frozen nitrogen ice reflects sunlight brilliantly. Dark streaks mark where ' +
    'nitrogen geysers have erupted, carried by winds in the thin atmosphere. ' + #13#10#13#10 +
    'Triton is unique: it orbits Neptune backwards (retrograde), suggesting it''s a captured Kuiper Belt object - ' +
    'perhaps like Pluto. Tidal forces are slowly pulling it closer to Neptune. ' +
    'In 3.6 billion years, it will either crash into Neptune or be torn apart into a spectacular ring system.');
  Loc.AddFact('Diameter: 2,707 km');
  Loc.AddFact('Temperature: -235°C (coldest measured)');
  Loc.AddFact('Orbits Neptune backwards');
  Loc.AddFact('Has nitrogen geysers');
  Loc.AddOption('Return to Neptune system', 'NEPTUNE_SYSTEM');
  Loc.AddOption('Journey to Kuiper Belt', 'KUIPER_BELT');
  FLocations.Add('TRITON', Loc);

  // KUIPER BELT
  Loc := TLocation.Create('KUIPER_BELT', 
    'You''ve reached the Kuiper Belt - a vast region beyond Neptune filled with icy bodies, ' +
    'remnants from the solar system''s formation. This is the realm of dwarf planets and comets. ' + #13#10#13#10 +
    'Pluto, once considered the ninth planet, resides here along with Eris, Makemake, and thousands of smaller objects. ' +
    'These frozen worlds represent pristine samples of the solar system''s early days, ' +
    'preserved in deep freeze for 4.5 billion years.');
  Loc.AddOption('Visit Pluto', 'PLUTO');
  Loc.AddOption('Explore dwarf planet Eris', 'ERIS');
  Loc.AddOption('Return to Neptune', 'NEPTUNE_SYSTEM');
  Loc.AddOption('Conclude your journey', 'JOURNEY_END');
  FLocations.Add('KUIPER_BELT', Loc);

  // PLUTO
  Loc := TLocation.Create('PLUTO', 
    'Pluto emerges from the darkness - a world of surprising complexity. Its heart-shaped Tombaugh Regio glacier ' +
    'of frozen nitrogen gleams. Towering mountains of water ice rise 3.5 km high. Blue atmospheric haze layers ' +
    'extend hundreds of kilometers above the surface. ' + #13#10#13#10 +
    'Pluto has five moons, the largest being Charon - so large that Pluto and Charon orbit a point between them, ' +
    'forming a binary system. Despite being -230°C, Pluto shows geological activity: ' +
    'flowing nitrogen glaciers, possible ice volcanoes, and a remarkably young surface in places.');
  Loc.AddFact('Diameter: 2,377 km');
  Loc.AddFact('Temperature: -230°C');
  Loc.AddFact('Orbit: 248 Earth years');
  Loc.AddFact('Has 5 moons including Charon');
  Loc.AddOption('Visit moon Charon', 'CHARON');
  Loc.AddOption('Return to Kuiper Belt', 'KUIPER_BELT');
  FLocations.Add('PLUTO', Loc);

  // CHARON
  Loc := TLocation.Create('CHARON', 
    'Charon, Pluto''s largest moon, is so massive (half Pluto''s size) that the two worlds form a binary system, ' +
    'orbiting a point between them. Charon''s surface is ancient and heavily cratered, with a mysterious dark red polar cap. ' + #13#10#13#10 +
    'A vast canyon system - deeper than the Grand Canyon - stretches across Charon''s surface, ' +
    'formed when Charon''s interior ocean froze and expanded. Charon is tidally locked to Pluto - ' +
    'they always show each other the same face.');
  Loc.AddFact('Diameter: 1,212 km (half Pluto''s size)');
  Loc.AddFact('Tidally locked with Pluto');
  Loc.AddFact('Has mysterious red polar cap');
  Loc.AddFact('Surface shows signs of past geological activity');
  Loc.AddOption('Return to Pluto', 'PLUTO');
  Loc.AddOption('Return to Kuiper Belt', 'KUIPER_BELT');
  FLocations.Add('CHARON', Loc);

  // ERIS
  Loc := TLocation.Create('ERIS', 
    'Eris appears - a dwarf planet in the scattered disk beyond the Kuiper Belt. ' +
    'Slightly smaller than Pluto but more massive, Eris'' discovery in 2005 led to the reclassification of Pluto. ' +
    'At its current distance of 96 AU from the Sun, Eris is one of the most distant known objects. ' + #13#10#13#10 +
    'Its surface is nearly pure methane ice, making it highly reflective. Eris has one known moon, Dysnomia. ' +
    'The dwarf planet follows a highly elliptical orbit that takes 558 years to complete.');
  Loc.AddFact('Diameter: 2,326 km');
  Loc.AddFact('Orbit: 558 Earth years');
  Loc.AddFact('Current distance: 96 AU from Sun');
  Loc.AddFact('More massive than Pluto');
  Loc.AddOption('Return to Kuiper Belt', 'KUIPER_BELT');
  Loc.AddOption('Conclude journey', 'JOURNEY_END');
  FLocations.Add('ERIS', Loc);

  // JOURNEY END
  Loc := TLocation.Create('JOURNEY_END', 
    'You''ve completed an epic journey across our solar system - from the scorched surface of Mercury ' +
    'to the frozen frontier of the Kuiper Belt. You''ve witnessed active volcanoes on Io, ' +
    'geysers on Enceladus, methane lakes on Titan, and the majestic rings of Saturn. ' + #13#10#13#10 +
    'Each world tells a unique story in the grand narrative of our solar system. ' +
    'From the rocky inner planets to the gas giants and icy outer worlds, ' +
    'you''ve surveyed the incredible diversity of our cosmic neighborhood. ' + #13#10#13#10 +
    'The ISV EXPLORER turns toward home, carrying precious data that will advance humanity''s understanding ' +
    'of these distant worlds. Mission accomplished, Commander. Welcome home.');
  Loc.AddOption('Review journey statistics', 'STATS');
  Loc.AddOption('Start new expedition', 'EARTH_ORBIT');
  FLocations.Add('JOURNEY_END', Loc);

  // STATS
  Loc := TLocation.Create('STATS', 
    'Mission Statistics:' + #13#10#13#10 +
    'Thank you for exploring our solar system! Your discoveries have contributed to humanity''s knowledge ' +
    'of these remarkable worlds. Each location you visited represents a real place in our solar system ' +
    'with its own unique geology, atmosphere, and mysteries waiting to be solved.' + #13#10#13#10 +
    'Perhaps one day, humans will actually visit these distant worlds in person. Until then, ' +
    'spacecraft like Voyager, Cassini, New Horizons, and many others continue to reveal their secrets.');
  Loc.AddOption('Begin new journey', 'EARTH_ORBIT');
  FLocations.Add('STATS', Loc);
end;

procedure TMainForm.UpdateDisplay;
var
  I: Integer;
  Facts: string;
begin
  if not Assigned(FCurrentLocation) then
  begin
    MemoStory.Lines.Add('ERROR: FCurrentLocation is not assigned!');
    Exit;
  end;
    
  // Update story text
  MemoStory.Lines.Clear;
  MemoStory.Lines.Add(FCurrentLocation.Description);
  
  // Debug output
  MemoStory.Lines.Add('');
  MemoStory.Lines.Add(Format('[DEBUG: %d options available]', [FCurrentLocation.Options.Count]));
  
  // Add facts if available
  if FCurrentLocation.Facts.Count > 0 then
  begin
    MemoStory.Lines.Add('');
    MemoStory.Lines.Add('═══════════════════════════════');
    MemoStory.Lines.Add('SCIENTIFIC DATA:');
    for I := 0 to FCurrentLocation.Facts.Count - 1 do
      MemoStory.Lines.Add('• ' + FCurrentLocation.Facts[I]);
    MemoStory.Lines.Add('═══════════════════════════════');
  end;
  
  // Update buttons
  for I := 0 to 3 do
  begin
    case I of
      0: begin
          if I < FCurrentLocation.Options.Count then
          begin
            BtnOption1.Text := FCurrentLocation.Options[I];
            BtnOption1.Visible := True;
          end
          else
            BtnOption1.Visible := False;
         end;
      1: begin
          if I < FCurrentLocation.Options.Count then
          begin
            BtnOption2.Text := FCurrentLocation.Options[I];
            BtnOption2.Visible := True;
          end
          else
            BtnOption2.Visible := False;
         end;
      2: begin
          if I < FCurrentLocation.Options.Count then
          begin
            BtnOption3.Text := FCurrentLocation.Options[I];
            BtnOption3.Visible := True;
          end
          else
            BtnOption3.Visible := False;
         end;
      3: begin
          if I < FCurrentLocation.Options.Count then
          begin
            BtnOption4.Text := FCurrentLocation.Options[I];
            BtnOption4.Visible := True;
          end
          else
            BtnOption4.Visible := False;
         end;
    end;
  end;
  
  UpdateStats;
end;

procedure TMainForm.UpdateStats;
begin
  if not Assigned(FCurrentLocation) then
    Exit;
    
  LabelStats.Text := Format('Locations Discovered: %d | Current: %s', 
    [FDiscoveredCount, FCurrentLocation.Name]);
end;

procedure TMainForm.NavigateTo(const ALocationName: string);
begin
  if FLocations.ContainsKey(ALocationName) then
  begin
    FCurrentLocation := FLocations[ALocationName];
    
    if not FCurrentLocation.Discovered then
    begin
      FCurrentLocation.Discovered := True;
      Inc(FDiscoveredCount);
      FVisitedLocations.Add(ALocationName);
    end;
    
    UpdateDisplay;
  end
  else
  begin
    // Debug: location not found
    MemoStory.Lines.Add(Format('ERROR: Location "%s" not found!', [ALocationName]));
  end;
end;

procedure TMainForm.BtnOption1Click(Sender: TObject);
begin
  if Assigned(FCurrentLocation) and (FCurrentLocation.Destinations.Count > 0) then
    NavigateTo(FCurrentLocation.Destinations[0]);
end;

procedure TMainForm.BtnOption2Click(Sender: TObject);
begin
  if Assigned(FCurrentLocation) and (FCurrentLocation.Destinations.Count > 1) then
    NavigateTo(FCurrentLocation.Destinations[1]);
end;

procedure TMainForm.BtnOption3Click(Sender: TObject);
begin
  if Assigned(FCurrentLocation) and (FCurrentLocation.Destinations.Count > 2) then
    NavigateTo(FCurrentLocation.Destinations[2]);
end;

procedure TMainForm.BtnOption4Click(Sender: TObject);
begin
  if Assigned(FCurrentLocation) and (FCurrentLocation.Destinations.Count > 3) then
    NavigateTo(FCurrentLocation.Destinations[3]);
end;

end.
