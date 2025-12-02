import os

# Define the file contents
project_source = """program SolarOdyssey;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMain in 'uMain.pas' {frmMain},
  uGameEngine in 'uGameEngine.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
"""

# The Main Form Logic
unit_main_pas = """unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.Edit,
  FMX.Layouts, FMX.Objects, uGameEngine;

type
  TfrmMain = class(TForm)
    StyleBook1: TStyleBook;
    LayoutInput: TLayout;
    edtInput: TEdit;
    btnSend: TButton;
    LayoutContent: TLayout;
    memoLog: TMemo;
    imgLocation: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSendClick(Sender: TObject);
    procedure edtInputKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char);
  private
    FGame: TGame;
    procedure AppendLog(const Msg: string);
    procedure OnGameUIUpdate(LocationName, ImageName: string);
    procedure LoadImageResource(const ResName: string);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FGame := TGame.Create;
  FGame.OutputLog := memoLog.Lines;
  FGame.OnUpdateUI := OnGameUIUpdate;
  AppendLog('INITIALIZING SOLAR ODYSSEY v2.0...');
  FGame.ProcessCommand('look');
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FGame.Free;
end;

procedure TfrmMain.AppendLog(const Msg: string);
begin
  memoLog.Lines.Add(Msg);
  memoLog.GoToTextEnd;
end;

procedure TfrmMain.OnGameUIUpdate(LocationName, ImageName: string);
begin
  Self.Caption := 'Solar Odyssey - ' + LocationName;
  LoadImageResource(ImageName);
end;

procedure TfrmMain.LoadImageResource(const ResName: string);
var
  InStream: TResourceStream;
begin
  if ResName = '' then
  begin
    imgLocation.Bitmap.SetSize(0, 0);
    Exit;
  end;

  if FindResource(HInstance, PChar(ResName), RT_RCDATA) <> 0 then
  begin
    try
      InStream := TResourceStream.Create(HInstance, ResName, RT_RCDATA);
      try
        imgLocation.Bitmap.LoadFromStream(InStream);
      finally
        InStream.Free;
      end;
    except
      AppendLog('SYSTEM WARNING: Visual feed corrupted (Image load failed).');
    end;
  end;
end;

procedure TfrmMain.btnSendClick(Sender: TObject);
begin
  if edtInput.Text = '' then Exit;
  AppendLog('> ' + edtInput.Text);
  FGame.ProcessCommand(edtInput.Text);
  edtInput.Text := '';
  edtInput.SetFocus;
end;

procedure TfrmMain.edtInputKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char);
begin
  if Key = vkReturn then
  begin
    Key := 0;
    btnSendClick(Self);
  end;
end;

end.
"""

# The Form Layout (FMX) - This saves you from dragging components manually
unit_main_fmx = """object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Solar Odyssey'
  ClientHeight = 480
  ClientWidth = 640
  FormFactor.Width = 320
  FormFactor.Height = 480
  FormFactor.Devices = [Desktop]
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignerMasterStyle = 0
  object StyleBook1: TStyleBook
    Left = 288
    Top = 232
  end
  object LayoutInput: TLayout
    Align = Bottom
    Height = 50.000000000000000000
    Width = 640.000000000000000000
    object edtInput: TEdit
      Touch.InteractiveGestures = [LongTap, DoubleTap]
      Align = Client
      TabOrder = 0
      OnKeyDown = edtInputKeyDown
    end
    object btnSend: TButton
      Align = Right
      Position.X = 560.000000000000000000
      Size.Width = 80.000000000000000000
      Size.Height = 50.000000000000000000
      Size.PlatformDefault = False
      TabOrder = 1
      Text = 'Send'
      OnClick = btnSendClick
    end
  end
  object LayoutContent: TLayout
    Align = Client
    Height = 430.000000000000000000
    Width = 640.000000000000000000
    object memoLog: TMemo
      Touch.InteractiveGestures = [Pan, LongTap, DoubleTap]
      DataDetectorTypes = []
      Align = Client
      Size.Width = 340.000000000000000000
      Size.Height = 430.000000000000000000
      Size.PlatformDefault = False
      TabOrder = 0
      ReadOnly = True
      Viewport.Width = 336.000000000000000000
      Viewport.Height = 426.000000000000000000
    end
    object imgLocation: TImage
      MultiResBitmap = <
        item
        end>
      Align = Right
      Margin.Left = 10.000000000000000000
      Position.X = 340.000000000000000000
      Size.Width = 300.000000000000000000
      Size.Height = 430.000000000000000000
      Size.PlatformDefault = False
      WrapMode = Fit
    end
  end
end
"""

# The Game Engine Logic
unit_engine_pas = """unit uGameEngine;

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
"""

def create_project():
    folder_name = "SolarOdyssey"
    
    if not os.path.exists(folder_name):
        os.makedirs(folder_name)
        print(f"Created folder: {folder_name}")
    
    files = {
        "SolarOdyssey.dpr": project_source,
        "uMain.pas": unit_main_pas,
        "uMain.fmx": unit_main_fmx,
        "uGameEngine.pas": unit_engine_pas
    }
    
    for filename, content in files.items():
        with open(os.path.join(folder_name, filename), "w") as f:
            f.write(content)
        print(f"Created file: {filename}")

    print("\nSUCCESS! Project created.")
    print("Next Steps:")
    print("1. Download the images.")
    print(f"2. Place them inside the '{folder_name}' folder.")
    print("3. Open SolarOdyssey.dpr in Delphi.")
    print("4. Go to Project > Resources and Images and add the images (Type: RCDATA).")

if __name__ == "__main__":
    create_project()
	
	