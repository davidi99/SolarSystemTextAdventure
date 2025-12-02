unit UContent;

interface

uses System.SysUtils, System.Generics.Collections;

type
  // Basic records for data modules live in other units.
  // Here we host string JSON and seed arrays as plain strings to keep separation.
  TContent = record
    class function SolarJson: string; static;
  end;

{
const
  // Codex and Achievements are seeded in UDataRepos to keep types together.
}

implementation

class function TContent.SolarJson: string;
begin
  Result :=
  '{"nodes": [\' +
  '{"id":"intro","title":"Docking at Lagrange Station L1",' +
  '"body":"Year 2238. You step off the shuttle at Earth-Moon L1, greeted by a wide holo-window of the Inner System. Your mission: scout key worlds and habitats, log scientific curiosities, and return with a story worth telling.",' +
  '"choices":[' +
  '{"text":"Launch to Mercury (sun-skimmer)","next":"mercury","requires":"","sets":"scouted_inner"},' +
  '{"text":"Head to the Moon (Artemis City)","next":"luna","requires":"","sets":""},' +
  '{"text":"Plot a course to Mars (Aeolis Port)","next":"mars","requires":"","sets":""},' +
  '{"text":"Open the mission console (help)","next":"console","requires":"","sets":""}' +
  ']},' +
  '{"id":"console","title":"Mission Console","body":"Type commands in the bar below. Try: help, scan, status, save, load, go <id>.",' +
  '"choices":[{"text":"Back to the station concourse","next":"intro","requires":"","sets":""}]},' +
  '{"id":"mercury","title":"Mercury – Terminator Ridge","body":"You skim above craggy scarps where daylight and night meet. Solar arrays glint; an automated mine hums below.",' +
  '"choices":[{"text":"Study solar geology (scan)","next":"mercury_scan","requires":"","sets":"flag_mercury_scan"},' +
  '{"text":"Slingshot to Venus cloudports","next":"venus","requires":"","sets":""},' +
  '{"text":"Return to L1","next":"intro","requires":"","sets":""}]},' +
  '{"id":"mercury_scan","title":"Mercury Scan","body":"Spectrometers flag volatile deposits trapped in polar cold-traps—future propellant banks.",' +
  '"choices":[{"text":"Continue to Venus","next":"venus","requires":"","sets":""}]},' +
  '{"id":"venus","title":"Venus – Cloud City 55 km","body":"Aerostats drift in an endless peach sky. Outside the hull: Earthlike pressure, acid rain softly hisses on ceramic cladding.",' +
  '"choices":[{"text":"Tour greenhouse ringway","next":"venus_green","requires":"","sets":"flag_venus_green"},' +
  '{"text":"Set course to Earth (Luna)","next":"luna","requires":"","sets":""}]},' +
  '{"id":"venus_green","title":"Venus Greenhouses","body":"A ribbon of hardy plants thrives in buffered air, sustained by solar power beamed from orbit.",' +
  '"choices":[{"text":"Jump to Mars","next":"mars","requires":"","sets":""}]},' +
  '{"id":"luna","title":"Luna – Artemis City","body":"A glassed crater reveals blue Earthrise. Maglevs whisper; regolith gardens glow under LEDs.",' +
  '"choices":[{"text":"Visit Shackleton Rim labs","next":"luna_lab","requires":"","sets":"flag_luna_lab"},' +
  '{"text":"Transit to Mars","next":"mars","requires":"","sets":""},' +
  '{"text":"Asteroid transfer: Ceres","next":"ceres","requires":"","sets":""}]},' +
  '{"id":"luna_lab","title":"Shackleton Rim","body":"Ice cores show ancient solar weather imprinted layer by layer.",' +
  '"choices":[{"text":"Back to Artemis concourse","next":"luna","requires":"","sets":""}]},' +
  '{"id":"mars","title":"Mars – Aeolis Port","body":"Dust halos the horizon. Hab domes sparkle with frost; a rover caravan queues at the airlock.",' +
  '"choices":[{"text":"Ride a rover to Valles Marineris","next":"valles","requires":"","sets":"flag_mars_rover"},' +
  '{"text":"Hitch to Phobos yard","next":"phobos","requires":"","sets":""},' +
  '{"text":"Hitch to Deimos array","next":"deimos","requires":"","sets":""},' +
  '{"text":"Burn for the Belt (Ceres)","next":"ceres","requires":"","sets":""}]},' +
  '{"id":"valles","title":"Valles Marineris","body":"A canyon like a planetwide scar. Thin air, endless grandeur; autonomous kites sample thermals.",' +
  '"choices":[{"text":"Return to Aeolis Port","next":"mars","requires":"","sets":""}]},' +
  '{"id":"phobos","title":"Phobos Shipyard","body":"Tiny moon, big industry. Tethers fling cargo toward Deimos and the Belt.",' +
  '"choices":[{"text":"Catch a tether to Deimos","next":"deimos","requires":"","sets":""},' +
  '{"text":"Depart for Ceres","next":"ceres","requires":"","sets":""}]},' +
  '{"id":"deimos","title":"Deimos Array","body":"Solar observatories nestle in regolith berms, sipping sunlight and silence.",' +
  '"choices":[{"text":"Depart for Ceres","next":"ceres","requires":"","sets":""}]},' +
  '{"id":"ceres","title":"Ceres – The Belt''s Heart","body":"A briny worldlet with a bright-salt scar. Inside the megadome, markets trade water, organics, ideas.",' +
  '"choices":[{"text":"Excursion to Vesta","next":"vesta","requires":"","sets":""},' +
  '{"text":"Jovian transfer (Ganymede)","next":"ganymede","requires":"","sets":""}]},' +
  '{"id":"vesta","title":"Vesta – Dawn-lit Craters","body":"Basalt cliffs shine. A microgravity climb-school teaches kids to dance on walls.",' +
  '"choices":[{"text":"Back to Ceres","next":"ceres","requires":"","sets":""}]},' +
  '{"id":"ganymede","title":"Jupiter – Ganymede Vaults","body":"Magnetically shielded tunnels hum. Briny oceans sleep below, warmed by the giant''s embrace.",' +
  '"choices":[{"text":"Icebreaker to Europa rifts","next":"europa","requires":"","sets":"flag_jove_science"},' +
  '{"text":"Hop to Io foundries","next":"io","requires":"","sets":""},' +
  '{"text":"Saturn transfer (Titan)","next":"titan","requires":"","sets":""}]},' +
  '{"id":"europa","title":"Europa – Lineae","body":"Red-stained cracks over hidden seas. A melt-probe whispers of chemistry almost familiar.",' +
  '"choices":[{"text":"Return to Ganymede","next":"ganymede","requires":"","sets":""}]},' +
  '{"id":"io","title":"Io – Foundry Fields","body":"Volcanic plumes arc into black. Radiations sings in the hull; smart shielding adapts.",' +
  '"choices":[{"text":"Back to Ganymede","next":"ganymede","requires":"","sets":""}]},' +
  '{"id":"titan","title":"Saturn – Titan Lakes","body":"Methane seas like ink. Submarine drones leave silver wakes under golden haze.",' +
  '"choices":[{"text":"Enceladus geyser flyby","next":"enceladus","requires":"","sets":""},' +
  '{"text":"Uranus transfer","next":"uranus","requires":"","sets":""}]},' +
  '{"id":"enceladus","title":"Enceladus – Plume Curtain","body":"Geysers paint space with ice; spectrometers taste organics in the snow.",' +
  '"choices":[{"text":"Return to Titan","next":"titan","requires":"","sets":""}]},' +
  '{"id":"uranus","title":"Uranus – Cloud Labs","body":"A sideways world. Sky labs float over sapphire depths, studying alien weather.",' +
  '"choices":[{"text":"Neptune''s moon Triton","next":"triton","requires":"","sets":""}]},' +
  '{"id":"triton","title":"Neptune – Triton Geysers","body":"Black nitrogen jets stipple pink plains. A captured wanderer dreaming of the Kuiper Belt.",' +
  '"choices":[{"text":"Edge run to Pluto","next":"pluto","requires":"","sets":""},' +
  '{"text":"Return inward (Ganymede)","next":"ganymede","requires":"","sets":""}]},' +
  '{"id":"pluto","title":"Pluto – Sputnik Planitia","body":"A nitrogen glacier like frozen wind. Far, quiet, exquisite.",' +
  '"choices":[{"text":"Plot a long cruise back to L1","next":"final","requires":"","sets":"flag_return"}]},' +
  '{"id":"final","title":"Homebound – Debrief","body":"Your log sparkles with worlds. Some secrets you unlocked, others await. Space is big; your story just began.",' +
  '"choices":[{"text":"Restart at L1","next":"intro","requires":"","sets":""}]}' +
  ']}';
end;

end.
