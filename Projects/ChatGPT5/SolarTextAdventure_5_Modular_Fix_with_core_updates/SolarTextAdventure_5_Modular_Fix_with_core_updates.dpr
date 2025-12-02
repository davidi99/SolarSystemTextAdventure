program SolarTextAdventure_5_Modular_Fix_with_core_updates;

uses
  System.StartUpCopy,
  FMX.Forms,
  MainForm in 'MainForm.pas' {FrmMain},
  UGameState in 'UGameState.pas',
  UContent in 'UContent.pas',
  UDataRepos in 'UDataRepos.pas',
  UStarMap in 'UStarMap.pas',
  UPrefs in 'UPrefs.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
