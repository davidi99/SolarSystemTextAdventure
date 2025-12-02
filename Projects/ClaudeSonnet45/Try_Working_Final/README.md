# Solar System Explorer - Text Adventure Game

A futuristic multi-device text adventure application built with Delphi 13 and FireMonkey (FMX).

## Description

Embark on an epic journey through our solar system aboard the ISV EXPLORER! Visit planets, moons, and asteroids while learning fascinating scientific facts about each celestial body.

## Features

- **40+ Locations**: Explore planets, moons, and major asteroids throughout the solar system
- **Educational Content**: Learn real scientific facts about each location
- **Futuristic UI**: Sleek space-themed interface with glowing effects
- **Multi-Device Support**: FMX framework allows compilation for Windows, macOS, iOS, and Android
- **Progress Tracking**: Keep track of discovered locations
- **Branching Navigation**: Choose your own path through the solar system

## Locations Include

### Inner Solar System
- Earth Orbit (starting point)
- The Moon & Tycho Crater
- Mercury & Caloris Basin
- Venus & Maxwell Montes
- Mars, Olympus Mons, & Valles Marineris
- Phobos & Deimos (Mars' moons)

### Asteroid Belt
- Ceres (dwarf planet)
- Vesta (protoplanet)

### Outer Solar System
- Jupiter System: Io, Europa, Ganymede
- Saturn System: Titan, Enceladus, Saturn's Rings
- Uranus System: Miranda, Titania
- Neptune System: Triton

### Kuiper Belt
- Pluto & Charon
- Eris

## Project Files

- `SolarSystemAdventure.dpr` - Main project file
- `uMainForm.pas` - Main form unit with game logic
- `uMainForm.fmx` - Form designer file with UI layout
- `SolarSystemAdventure.dproj` - Project configuration

## How to Build

1. Open `SolarSystemAdventure.dproj` in Delphi 13
2. Select your target platform (Win32/Win64/macOS/iOS/Android)
3. Press F9 to compile and run

## Requirements

- Delphi 13 (or compatible version)
- FireMonkey (FMX) framework

## UI Features

- **Dark Space Theme**: Deep blue/black gradient background
- **Glowing Title**: Animated cyan glow effect
- **Color-Coded Elements**:
  - Cyan (#00FFFF) - Title and headings
  - Blue (#0080FF) - Story area border
  - Green (#00FF00) - Status console
  - Light Blue (#00DDFF) - Navigation buttons
- **Responsive Layout**: Adapts to different screen sizes

## Game Mechanics

- Start at Earth orbit
- Click navigation options to travel to different locations
- Discover new locations to increase your exploration count
- Read scientific data about each celestial body
- Complete the tour by reaching the Journey End location

## Educational Value

Each location includes:
- Descriptive narrative bringing the location to life
- Real scientific data (diameter, temperature, orbital periods, etc.)
- Unique geological or atmospheric features
- Historical context and fun facts

## Technical Implementation

- Object-oriented design with TLocation class
- Dictionary-based location management
- Dynamic UI updates based on current location
- Support for up to 4 navigation options per location
- Animated visual effects for enhanced user experience

## License

This is a demonstration project. Feel free to use and modify for educational purposes.

## Credits

All scientific information is based on actual NASA data and planetary science research.

---

**Enjoy your journey through our magnificent solar system!**
