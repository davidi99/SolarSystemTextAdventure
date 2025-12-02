// ========================================
// Project: SolarTextAdventure (FMX)
// Delphi: 13 (works on 12.3+)
// Targets: Windows, macOS, iOS, Android, Linux (FMXLinux)
// Files in this snippet:
//   1) SolarTextAdventure.dpr  (Project)
//   2) MainForm.pas            (Main UI + Game Engine)
// No .fmx file is required; the UI is built in code.
// ========================================

// ---------------------------
// 1) SolarTextAdventure.dpr
// ---------------------------
program SolarTextAdventure_1_Start;

uses
  System.StartUpCopy,
  FMX.Forms,
  MainForm in 'MainForm.pas' {FrmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
