unit UContent;

interface

type
  TContent = record
    class function SolarJson: string; static;
  end;

implementation

uses System.SysUtils;

class function TContent.SolarJson: string;
const
  S: string =
'{'#13#10+
'  "nodes": ['#13#10+
'    {"id":"intro","title":"Docking at Lagrange Station L1",'#13#10+
'     "body":"Year 2238. You step off the shuttle at Earth-Moon L1...",'#13#10+
'     "choices":['#13#10+
'       {"text":"Launch to Mercury (sun-skimmer)","next":"mercury","requires":"","sets":"scouted_inner"},'#13#10+
'       {"text":"Head to the Moon (Artemis City)","next":"luna","requires":"","sets":""},'#13#10+
'       {"text":"Plot a course to Mars (Aeolis Port)","next":"mars","requires":"","sets":""},'#13#10+
'       {"text":"Open the mission console (help)","next":"console","requires":"","sets":""}'#13#10+
'     ]},'#13#10+
''#13#10+
'    {"id":"console","title":"Mission Console",'#13#10+
'     "body":"Type commands in the bar below. Try: help, scan, status, save, load, go <id>.",'#13#10+
'     "choices":[{"text":"Back to the station concourse","next":"intro","requires":"","sets":""}]},'#13#10+
''#13#10+
'    {"id":"mercury","title":"Mercury – Terminator Ridge",'#13#10+
'     "body":"You skim above craggy scarps where daylight and night meet...",'#13#10+
'     "choices":['#13#10+
'       {"text":"Study solar geology (scan)","next":"mercury_scan","requires":"","sets":"flag_mercury_scan"},'#13#10+
'       {"text":"Slingshot to Venus cloudports","next":"venus","requires":"","sets":""},'#13#10+
'       {"text":"Return to L1","next":"intro","requires":"","sets":""}'#13#10+
'     ]},'#13#10+
''#13#10+
'    {"id":"mercury_scan","title":"Mercury Scan",'#13#10+
'     "body":"Spectrometers flag volatile deposits trapped in polar cold-traps—future propellant banks.",'#13#10+
'     "choices":[{"text":"Continue to Venus","next":"venus","requires":"","sets":""}]},'#13#10+
''#13#10+
'    {"id":"venus","title":"Venus – Cloud City 55 km",'#13#10+
'     "body":"Aerostats drift in an endless peach sky...",'#13#10+
'     "choices":['#13#10+
'       {"text":"Tour greenhouse ringway","next":"venus_green","requires":"","sets":"flag_venus_green"},'#13#10+
'       {"text":"Set course to Earth (Luna)","next":"luna","requires":"","sets":""}'#13#10+
'     ]},'#13#10+
''#13#10+
'    {"id":"venus_green","title":"Venus Greenhouses",'#13#10+
'     "body":"A ribbon of hardy plants thrives in buffered air...",'#13#10+
'     "choices":[{"text":"Jump to Mars","next":"mars","requires":"","sets":""}]},'#13#10+
''#13#10+
'    {"id":"luna","title":"Luna – Artemis City",'#13#10+
'     "body":"A glassed crater reveals blue Earthrise...",'#13#10+
'     "choices":['#13#10+
'       {"text":"Visit Shackleton Rim labs","next":"luna_lab","requires":"","sets":"flag_luna_lab"},'#13#10+
'       {"text":"Transit to Mars","next":"mars","requires":"","sets":""},'#13#10+
'       {"text":"Asteroid transfer: Ceres","next":"ceres","requires":"","sets":""}'#13#10+
'     ]},'#13#10+
''#13#10+
'    {"id":"luna_lab","title":"Shackleton Rim",'#13#10+
'     "body":"Ice cores show ancient solar weather imprinted layer by layer.",'#13#10+
'     "choices":[{"text":"Back to Artemis concourse","next":"luna","requires":"","sets":""}]},'#13#10+
''#13#10+
'    {"id":"mars","title":"Mars – Aeolis Port",'#13#10+
'     "body":"Dust halos the horizon...",'#13#10+
'     "choices":['#13#10+
'       {"text":"Ride a rover to Valles Marineris","next":"valles","requires":"","sets":"flag_mars_rover"},'#13#10+
'       {"text":"Hitch to Phobos yard","next":"phobos","requires":"","sets":""},'#13#10+
'       {"text":"Hitch to Deimos array","next":"deimos","requires":"","sets":""},'#13#10+
'       {"text":"Burn for the Belt (Ceres)","next":"ceres","requires":"","sets":""}'#13#10+
'     ]},'#13#10+
''#13#10+
'    {"id":"valles","title":"Valles Marineris",'#13#10+
'     "body":"A canyon like a planetwide scar...",'#13#10+
'     "choices":[{"text":"Return to Aeolis Port","next":"mars","requires":"","sets":""}]},'#13#10+
''#13#10+
'    {"id":"phobos","title":"Phobos Shipyard",'#13#10+
'     "body":"Tiny moon, big industry...",'#13#10+
'     "choices":['#13#10+
'       {"text":"Catch a tether to Deimos","next":"deimos","requires":"","sets":""},'#13#10+
'       {"text":"Depart for Ceres","next":"ceres","requires":"","sets":""}'#13#10+
'     ]},'#13#10+
''#13#10+
'    {"id":"deimos","title":"Deimos Array",'#13#10+
'     "body":"Solar observatories nestle in regolith berms...",'#13#10+
'     "choices":[{"text":"Depart for Ceres","next":"ceres","requires":"","sets":""}]},'#13#10+
''#13#10+
'    {"id":"ceres","title":"Ceres – The Belt''s Heart",'#13#10+
'     "body":"A briny worldlet with a bright-salt scar...",'#13#10+
'     "choices":['#13#10+
'       {"text":"Excursion to Vesta","next":"vesta","requires":"","sets":""},'#13#10+
'       {"text":"Jovian transfer (Ganymede)","next":"ganymede","requires":"","sets":""}'#13#10+
'     ]},'#13#10+
''#13#10+
'    {"id":"vesta","title":"Vesta – Dawn-lit Craters",'#13#10+
'     "body":"Basalt cliffs shine...",'#13#10+
'     "choices":[{"text":"Back to Ceres","next":"ceres","requires":"","sets":""}]},'#13#10+
''#13#10+
'    {"id":"ganymede","title":"Jupiter – Ganymede Vaults",'#13#10+
'     "body":"Magnetically shielded tunnels hum...",'#13#10+
'     "choices":['#13#10+
'       {"text":"Icebreaker to Europa rifts","next":"europa","requires":"","sets":"flag_jove_science"},'#13#10+
'       {"text":"Hop to Io foundries","next":"io","requires":"","sets":""},'#13#10+
'       {"text":"Saturn transfer (Titan)","next":"titan","requires":"","sets":""}'#13#10+
'     ]},'#13#10+
''#13#10+
'    {"id":"europa","title":"Europa – Lineae",'#13#10+
'     "body":"Red-stained cracks over hidden seas...",'#13#10+
'     "choices":[{"text":"Return to Ganymede","next":"ganymede","requires":"","sets":""}]},'#13#10+
''#13#10+
'    {"id":"io","title":"Io – Foundry Fields",'#13#10+
'     "body":"Volcanic plumes arc into black...",'#13#10+
'     "choices":[{"text":"Back to Ganymede","next":"ganymede","requires":"","sets":""}]},'#13#10+
''#13#10+
'    {"id":"titan","title":"Saturn – Titan Lakes",'#13#10+
'     "body":"Methane seas like ink...",'#13#10+
'     "choices":['#13#10+
'       {"text":"Enceladus geyser flyby","next":"enceladus","requires":"","sets":""},'#13#10+
'       {"text":"Uranus transfer","next":"uranus","requires":"","sets":""}'#13#10+
'     ]},'#13#10+
''#13#10+
'    {"id":"enceladus","title":"Enceladus – Plume Curtain",'#13#10+
'     "body":"Geysers paint space with ice...",'#13#10+
'     "choices":[{"text":"Return to Titan","next":"titan","requires":"","sets":""}]},'#13#10+
''#13#10+
'    {"id":"uranus","title":"Uranus – Cloud Labs",'#13#10+
'     "body":"A sideways world...",'#13#10+
'     "choices":[{"text":"Neptune''s moon Triton","next":"triton","requires":"","sets":""}]},'#13#10+
''#13#10+
'    {"id":"triton","title":"Neptune – Triton Geysers",'#13#10+
'     "body":"Black nitrogen jets stipple pink plains...",'#13#10+
'     "choices":[{"text":"Edge run to Pluto","next":"pluto","requires":"","sets":""},{"text":"Return inward (Ganymede)","next":"ganymede","requires":"","sets":""}]},'#13#10+
''#13#10+
'    {"id":"pluto","title":"Pluto – Sputnik Planitia",'#13#10+
'     "body":"A nitrogen glacier like frozen wind...",'#13#10+
'     "choices":[{"text":"Plot a long cruise back to L1","next":"final","requires":"","sets":"flag_return"}]},'#13#10+
''#13#10+
'    {"id":"final","title":"Homebound – Debrief",'#13#10+
'     "body":"Your log sparkles with worlds...",'#13#10+
'     "choices":[{"text":"Restart at L1","next":"intro","requires":"","sets":""}]}'#13#10+
'  ]'#13#10+
'}';
begin
  Result := S;
end;

end.
