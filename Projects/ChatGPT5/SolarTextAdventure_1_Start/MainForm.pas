// ---------------------------
// 2) MainForm.pas
// ---------------------------
unit MainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Generics.Collections, System.IOUtils, System.JSON,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.StdCtrls, FMX.Layouts, FMX.Memo, FMX.Edit, FMX.ListBox, FMX.ScrollBox,
  FMX.Controls.Presentation, FMX.Objects;

 type
  TChoice = record
    Text: string;
    NextId: string;
    RequiresFlag: string;   // optional: gate choice until flag present ("" = none)
    SetsFlag: string;       // optional: set when chosen ("" = none)
  end;

  TNode = record
    Id: string;
    Title: string;
    Body: string;
    Choices: TArray<TChoice>;
  end;

  TGameState = class
  private
    FFlags: TDictionary<string, Boolean>;
    FVisited: TDictionary<string, Boolean>;
    FCurrentId: string;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
    procedure Reset;
    function ToJSON: string;
    procedure FromJSON(const S: string);
    property CurrentId: string read FCurrentId write FCurrentId;
    property Flags: TDictionary<string, Boolean> read FFlags;
    property Visited: TDictionary<string, Boolean> read FVisited;
  end;

  TFrmMain = class(TForm)
    TopBar: TToolBar;
    LblTitle: TLabel;
    LayoutRoot: TLayout;
    MemoStory: TMemo;
    ListChoices: TListBox;
    BottomBar: TLayout;
    EdtCommand: TEdit;
    BtnSend: TButton;
    BtnMenu: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure BtnSendClick(Sender: TObject);
    procedure ListChoicesItemClick(const Sender: TObject; const Item: TListBoxItem);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure BtnMenuClick(Sender: TObject);
  private
    FNodes: TDictionary<string, TNode>;
    FState: TGameState;
    FSavePath: string;
    procedure BuildUI;
    procedure LoadContentFromJSON(const Json: string);
    procedure RenderNode(const Id: string);
    procedure AppendStory(const S: string; const AddBlank: Boolean = True);
    procedure HandleChoice(const Choice: TChoice);
    procedure HandleCommand(const CmdLine: string);
    procedure ShowHelp;
    procedure SaveGame;
    procedure LoadGame;
  public
  end;

var
  FrmMain: TFrmMain;

implementation

// {$R *.fmx}

const
  // --- Embedded content: a bite-size tour. Add more nodes easily.
  SOLAR_DATA: string =  '''
  {"nodes": [\
    {"id":"intro","title":"Docking at Lagrange Station L1",\
     "body":"Year 2238. You step off the shuttle at Earth-Moon L1, greeted by a wide holo-window of the Inner System. Your mission: scout key worlds and habitats, log scientific curiosities, and return with a story worth telling.",\
     "choices":[\
       {"text":"Launch to Mercury (sun-skimmer)","next":"mercury","requires":"","sets":"scouted_inner"},\
       {"text":"Head to the Moon (Artemis City)","next":"luna","requires":"","sets":""},\
       {"text":"Plot a course to Mars (Aeolis Port)","next":"mars","requires":"","sets":""},\
       {"text":"Open the mission console (help)","next":"console","requires":"","sets":""}
     ]},\

    {"id":"console","title":"Mission Console","body":"Type commands in the bar below. Try: help, scan, status, save, load, go <id>.",\
     "choices":[{"text":"Back to the station concourse","next":"intro","requires":"","sets":""}]},\

    {"id":"mercury","title":"Mercury – Terminator Ridge","body":"You skim above craggy scarps where daylight and night meet. Solar arrays glint; an automated mine hums below.",\
     "choices":[\
       {"text":"Study solar geology (scan)","next":"mercury_scan","requires":"","sets":"flag_mercury_scan"},\
       {"text":"Slingshot to Venus cloudports","next":"venus","requires":"","sets":""},\
       {"text":"Return to L1","next":"intro","requires":"","sets":""}
     ]},\

    {"id":"mercury_scan","title":"Mercury Scan","body":"Spectrometers flag volatile deposits trapped in polar cold-traps—future propellant banks.",\
     "choices":[{"text":"Continue to Venus","next":"venus","requires":"","sets":""}]},\

    {"id":"venus","title":"Venus – Cloud City 55 km","body":"Aerostats drift in an endless peach sky. Outside the hull: Earthlike pressure, acid rain softly hisses on ceramic cladding.",\
     "choices":[\
       {"text":"Tour greenhouse ringway","next":"venus_green","requires":"","sets":"flag_venus_green"},\
       {"text":"Set course to Earth (Luna)","next":"luna","requires":"","sets":""}
     ]},\

    {"id":"venus_green","title":"Venus Greenhouses","body":"A ribbon of hardy plants thrives in buffered air, sustained by solar power beamed from orbit.",\
     "choices":[{"text":"Jump to Mars","next":"mars","requires":"","sets":""}]},\

    {"id":"luna","title":"Luna – Artemis City","body":"A glassed crater reveals blue Earthrise. Maglevs whisper; regolith gardens glow under LEDs.",\
     "choices":[\
       {"text":"Visit Shackleton Rim labs","next":"luna_lab","requires":"","sets":"flag_luna_lab"},\
       {"text":"Transit to Mars","next":"mars","requires":"","sets":""},\
       {"text":"Asteroid transfer: Ceres","next":"ceres","requires":"","sets":""}
     ]},\

    {"id":"luna_lab","title":"Shackleton Rim","body":"Ice cores show ancient solar weather imprinted layer by layer.",\
     "choices":[{"text":"Back to Artemis concourse","next":"luna","requires":"","sets":""}]},\

    {"id":"mars","title":"Mars – Aeolis Port","body":"Dust halos the horizon. Hab domes sparkle with frost; a rover caravan queues at the airlock.",\
     "choices":[\
       {"text":"Ride a rover to Valles Marineris","next":"valles","requires":"","sets":"flag_mars_rover"},\
       {"text":"Hitch to Phobos yard","next":"phobos","requires":"","sets":""},\
       {"text":"Hitch to Deimos array","next":"deimos","requires":"","sets":""},\
       {"text":"Burn for the Belt (Ceres)","next":"ceres","requires":"","sets":""}
     ]},\

    {"id":"valles","title":"Valles Marineris","body":"A canyon like a planetwide scar. Thin air, endless grandeur; autonomous kites sample thermals.",\
     "choices":[{"text":"Return to Aeolis Port","next":"mars","requires":"","sets":""}]},\

    {"id":"phobos","title":"Phobos Shipyard","body":"Tiny moon, big industry. Tethers fling cargo toward Deimos and the Belt.",\
     "choices":[\
       {"text":"Catch a tether to Deimos","next":"deimos","requires":"","sets":""},\
       {"text":"Depart for Ceres","next":"ceres","requires":"","sets":""}
     ]},\

    {"id":"deimos","title":"Deimos Array","body":"Solar observatories nestle in regolith berms, sipping sunlight and silence.",\
     "choices":[{"text":"Depart for Ceres","next":"ceres","requires":"","sets":""}]},\

    {"id":"ceres","title":"Ceres – The Belt''s Heart","body":"A briny worldlet with a bright-salt scar. Inside the megadome, markets trade water, organics, ideas.",\
     "choices":[\
       {"text":"Excursion to Vesta","next":"vesta","requires":"","sets":""},\
       {"text":"Jovian transfer (Ganymede)","next":"ganymede","requires":"","sets":""}
     ]},\

    {"id":"vesta","title":"Vesta – Dawn-lit Craters","body":"Basalt cliffs shine. A microgravity climb-school teaches kids to dance on walls.",\
     "choices":[{"text":"Back to Ceres","next":"ceres","requires":"","sets":""}]},\

    {"id":"ganymede","title":"Jupiter – Ganymede Vaults","body":"Magnetically shielded tunnels hum. Briny oceans sleep below, warmed by the giant''s embrace.",\
     "choices":[\
       {"text":"Icebreaker to Europa rifts","next":"europa","requires":"","sets":"flag_jove_science"},\
       {"text":"Hop to Io foundries","next":"io","requires":"","sets":""},\
       {"text":"Saturn transfer (Titan)","next":"titan","requires":"","sets":""}
     ]},\

    {"id":"europa","title":"Europa – Lineae","body":"Red-stained cracks over hidden seas. A melt-probe whispers of chemistry almost familiar.",\
     "choices":[{"text":"Return to Ganymede","next":"ganymede","requires":"","sets":""}]},\

    {"id":"io","title":"Io – Foundry Fields","body":"Volcanic plumes arc into black. Radiations sings in the hull; smart shielding adapts.",\
     "choices":[{"text":"Back to Ganymede","next":"ganymede","requires":"","sets":""}]},\

    {"id":"titan","title":"Saturn – Titan Lakes","body":"Methane seas like ink. Submarine drones leave silver wakes under golden haze.",\
     "choices":[\
       {"text":"Enceladus geyser flyby","next":"enceladus","requires":"","sets":""},\
       {"text":"Uranus transfer","next":"uranus","requires":"","sets":""}
     ]},\

    {"id":"enceladus","title":"Enceladus – Plume Curtain","body":"Geysers paint space with ice; spectrometers taste organics in the snow.",\
     "choices":[{"text":"Return to Titan","next":"titan","requires":"","sets":""}]},\

    {"id":"uranus","title":"Uranus – Cloud Labs","body":"A sideways world. Sky labs float over sapphire depths, studying alien weather.",\
     "choices":[{"text":"Neptune''s moon Triton","next":"triton","requires":"","sets":""}]},\

    {"id":"triton","title":"Neptune – Triton Geysers","body":"Black nitrogen jets stipple pink plains. A captured wanderer dreaming of the Kuiper Belt.",\
     "choices":[\
       {"text":"Edge run to Pluto","next":"pluto","requires":"","sets":""},\
       {"text":"Return inward (Ganymede)","next":"ganymede","requires":"","sets":""}
     ]},\

    {"id":"pluto","title":"Pluto – Sputnik Planitia","body":"A nitrogen glacier like frozen wind. Far, quiet, exquisite.",\
     "choices":[{"text":"Plot a long cruise back to L1","next":"final","requires":"","sets":"flag_return"}]},\

    {"id":"final","title":"Homebound – Debrief","body":"Your log sparkles with worlds. Some secrets you unlocked, others await. Space is big; your story just began.",\
     "choices":[\
       {"text":"Restart at L1","next":"intro","requires":"","sets":""}
     ]}
  ]}
  ''';

{ TGameState }
constructor TGameState.Create;
begin
  inherited Create;
  FFlags := TDictionary<string, Boolean>.Create;
  FVisited := TDictionary<string, Boolean>.Create;
  FCurrentId := 'intro';
end;

destructor TGameState.Destroy;
begin
  FFlags.Free;
  FVisited.Free;
  inherited;
end;

procedure TGameState.Reset;
begin
  FFlags.Clear;
  FVisited.Clear;
  FCurrentId := 'intro';
end;

function TGameState.ToJSON: string;
var
  Root, FlagsObj, VisObj: TJSONObject;
  Pair: TPair<string, Boolean>;
begin
  Root := TJSONObject.Create;
  try
    Root.AddPair('current', FCurrentId);
    FlagsObj := TJSONObject.Create;
    for Pair in FFlags do
      FlagsObj.AddPair(Pair.Key, TJSONBool.Create(Pair.Value));
    Root.AddPair('flags', FlagsObj);

    VisObj := TJSONObject.Create;
    for Pair in FVisited do
      VisObj.AddPair(Pair.Key, TJSONBool.Create(Pair.Value));
    Root.AddPair('visited', VisObj);
    Result := Root.ToJSON;
  finally
    Root.Free;
  end;
end;

procedure TGameState.FromJSON(const S: string);
var
  Root, FlagsObj, VisObj: TJSONObject;
  Keys: TJSONArray;
  I: Integer;
  Name: string;
begin
  Reset;
  if S.Trim = '' then Exit;
  Root := TJSONObject(TJSONObject.ParseJSONValue(S));
  try
    if Root = nil then Exit;
    if Root.TryGetValue<string>('current', FCurrentId) then;
    if Root.TryGetValue<TJSONObject>('flags', FlagsObj) then
    begin
      Keys := FlagsObj.GetNames;
      if Keys <> nil then
        for I := 0 to Keys.Count - 1 do
        begin
          Name := Keys.Items[I].Value;
          FFlags.AddOrSetValue(Name, FlagsObj.GetValue<Boolean>(Name));
        end;
    end;
    if Root.TryGetValue<TJSONObject>('visited', VisObj) then
    begin
      Keys := VisObj.GetNames;
      if Keys <> nil then
        for I := 0 to Keys.Count - 1 do
        begin
          Name := Keys.Items[I].Value;
          FVisited.AddOrSetValue(Name, VisObj.GetValue<Boolean>(Name));
        end;
    end;
  finally
    Root.Free;
  end;
end;

{ TFrmMain }
procedure TFrmMain.BuildUI;
var
  Sep: TRectangle;
begin
  // Top toolbar
  TopBar := TToolBar.Create(Self);
  TopBar.Parent := Self;
  TopBar.Align := TAlignLayout.Top;

  BtnMenu := TSpeedButton.Create(TopBar);
  BtnMenu.Parent := TopBar;
  BtnMenu.Text := '☰';
  BtnMenu.Position.X := 8;
  BtnMenu.OnClick := BtnMenuClick;

  LblTitle := TLabel.Create(TopBar);
  LblTitle.Parent := TopBar;
  LblTitle.Text := 'Solar Text Adventure';
  LblTitle.Align := TAlignLayout.Contents;
  LblTitle.TextSettings.Font.Size := 18;
  LblTitle.TextSettings.HorzAlign := TTextAlign.Center;

  // Root layout
  LayoutRoot := TLayout.Create(Self);
  LayoutRoot.Parent := Self;
  LayoutRoot.Align := TAlignLayout.Client;
  LayoutRoot.Padding.Rect := TRectF.Create(10, 10, 10, 10);

  MemoStory := TMemo.Create(LayoutRoot);
  MemoStory.Parent := LayoutRoot;
  MemoStory.Align := TAlignLayout.Top;
  MemoStory.ReadOnly := True;
  MemoStory.HitTest := False;
  MemoStory.Stored := False; // reduce .fmx noise if ever saved
  MemoStory.Height := Trunc(Height * 0.55);
  MemoStory.Lines.Clear;

  Sep := TRectangle.Create(LayoutRoot);
  Sep.Parent := LayoutRoot;
  Sep.Align := TAlignLayout.Top;
  Sep.Height := 1;
  Sep.Opacity := 0.3;

  ListChoices := TListBox.Create(LayoutRoot);
  ListChoices.Parent := LayoutRoot;
  ListChoices.Align := TAlignLayout.Client;
  ListChoices.ItemIndex := -1;
  ListChoices.OnItemClick := ListChoicesItemClick;

  BottomBar := TLayout.Create(Self);
  BottomBar.Parent := Self;
  BottomBar.Align := TAlignLayout.Bottom;
  BottomBar.Height := 56;
  BottomBar.Padding.Rect := TRectF.Create(10, 6, 10, 10);

  EdtCommand := TEdit.Create(BottomBar);
  EdtCommand.Parent := BottomBar;
  EdtCommand.Align := TAlignLayout.Client;
  EdtCommand.TextPrompt := 'Type a command (help, scan, status, save, load, go <id>)';

  BtnSend := TButton.Create(BottomBar);
  BtnSend.Parent := BottomBar;
  BtnSend.Align := TAlignLayout.Right;
  BtnSend.Text := 'Go';
  BtnSend.Width := 72;
  BtnSend.OnClick := BtnSendClick;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  Position := TFormPosition.ScreenCenter;
  Caption := 'Solar Text Adventure';
  FNodes := TDictionary<string, TNode>.Create;
  FState := TGameState.Create;
  FSavePath := TPath.Combine(TPath.GetDocumentsPath, 'SolarTextAdventure.save.json');
  BuildUI;
  LoadContentFromJSON(SOLAR_DATA);
  AppendStory('Welcome, Explorer. Type "help" for commands.');
  RenderNode(FState.CurrentId);
end;

procedure TFrmMain.AppendStory(const S: string; const AddBlank: Boolean);
begin
  if S <> '' then
    MemoStory.Lines.Add(S);
  if AddBlank then
    MemoStory.Lines.Add('');
  MemoStory.GoToTextEnd;
end;

procedure TFrmMain.LoadContentFromJSON(const Json: string);
var
  Root: TJSONObject;
  Arr: TJSONArray;
  I, J: Integer;
  N: TNode;
  C: TChoice;
  JO, JC: TJSONObject;
  ChoicesArr: TJSONArray;
begin
  Root := TJSONObject(TJSONObject.ParseJSONValue(Json));
  try
    if Root = nil then
      raise Exception.Create('Invalid JSON content.');
    Arr := Root.GetValue<TJSONArray>('nodes');
    for I := 0 to Arr.Count - 1 do
    begin
      JO := Arr.Items[I] as TJSONObject;
      N.Id := JO.GetValue<string>('id');
      N.Title := JO.GetValue<string>('title');
      N.Body := JO.GetValue<string>('body');
      SetLength(N.Choices, 0);
      ChoicesArr := JO.GetValue<TJSONArray>('choices');
      if ChoicesArr <> nil then
      begin
        SetLength(N.Choices, ChoicesArr.Count);
        for J := 0 to ChoicesArr.Count - 1 do
        begin
          JC := ChoicesArr.Items[J] as TJSONObject;
          C.Text := JC.GetValue<string>('text');
          C.NextId := JC.GetValue<string>('next');
          if JC.TryGetValue<string>('requires', C.RequiresFlag) = False then
            C.RequiresFlag := '';
          if JC.TryGetValue<string>('sets', C.SetsFlag) = False then
            C.SetsFlag := '';
          N.Choices[J] := C;
        end;
      end;
      FNodes.AddOrSetValue(N.Id, N);
    end;
  finally
    Root.Free;
  end;
end;

procedure TFrmMain.RenderNode(const Id: string);
var
  Node: TNode;
  Item: TListBoxItem;
  Choice: TChoice;
  Allowed: Boolean;
begin
  if not FNodes.TryGetValue(Id, Node) then
    raise Exception.CreateFmt('Unknown node: %s', [Id]);

  FState.CurrentId := Id;
  FState.Visited.AddOrSetValue(Id, True);

  LblTitle.Text := Node.Title;
  AppendStory('— ' + Node.Title + ' —', False);
  AppendStory(Node.Body);

  ListChoices.BeginUpdate;
  try
    ListChoices.Clear;
    for Choice in Node.Choices do
    begin
      Allowed := True;
      if Choice.RequiresFlag <> '' then
        Allowed := FState.Flags.ContainsKey(Choice.RequiresFlag) and FState.Flags[Choice.RequiresFlag];
      if Allowed then
      begin
        Item := TListBoxItem.Create(ListChoices);
        Item.Parent := ListChoices;
        Item.Text := Choice.Text + '  [' + Choice.NextId + ']';
        Item.TagString := Choice.NextId + '|' + Choice.SetsFlag;
      end;
    end;
  finally
    ListChoices.EndUpdate;
  end;
end;

procedure TFrmMain.HandleChoice(const Choice: TChoice);
begin
  if Choice.SetsFlag <> '' then
    FState.Flags.AddOrSetValue(Choice.SetsFlag, True);
  RenderNode(Choice.NextId);
end;

procedure TFrmMain.HandleCommand(const CmdLine: string);
var
  Parts: TArray<string>;
  Cmd, Arg: string;
  NodeId: string;
begin
  Parts := CmdLine.Trim.Split([' '], 2);
  if Length(Parts) = 0 then Exit;
  Cmd := Parts[0].ToLower;
  Arg := '';
  if Length(Parts) > 1 then Arg := Parts[1];

  if (Cmd = 'help') or (Cmd = '?') then
  begin
    ShowHelp;
    Exit;
  end;

  if Cmd = 'scan' then
  begin
    AppendStory('Sensors sweep the area. New scientific notes added where available.');
    FState.Flags.AddOrSetValue('scanned', True);
    Exit;
  end;

  if Cmd = 'status' then
  begin
    AppendStory(Format('Current: %s', [FState.CurrentId]));
    AppendStory(Format('Flags: %d, Visited: %d', [FState.Flags.Count, FState.Visited.Count]));
    Exit;
  end;

  if Cmd = 'save' then
  begin
    SaveGame;
    Exit;
  end;

  if Cmd = 'load' then
  begin
    LoadGame;
    Exit;
  end;

  if (Cmd = 'go') and (Arg <> '') then
  begin
    NodeId := Arg.Trim.ToLower;
    if FNodes.ContainsKey(NodeId) then
    begin
      RenderNode(NodeId);
    end
    else
      AppendStory('Unknown destination id: ' + NodeId);
    Exit;
  end;

  AppendStory('Command not recognized. Type "help" for options.');
end;

procedure TFrmMain.ShowHelp;
begin
  AppendStory('Commands:');
  AppendStory('  help / ?   – Show this help');
  AppendStory('  scan       – Scientific scan (unlocks some flags)');
  AppendStory('  status     – Show current node and counters');
  AppendStory('  save       – Save game');
  AppendStory('  load       – Load game');
  AppendStory('  go <id>    – Jump to a known location id (shown in brackets)');
end;

procedure TFrmMain.SaveGame;
var
  S: string;
begin
  S := FState.ToJSON;
  TFile.WriteAllText(FSavePath, S, TEncoding.UTF8);
  AppendStory('Game saved to: ' + FSavePath);
end;

procedure TFrmMain.LoadGame;
var
  S: string;
begin
  if TFile.Exists(FSavePath) then
  begin
    S := TFile.ReadAllText(FSavePath, TEncoding.UTF8);
    FState.FromJSON(S);
    AppendStory('Save loaded.');
    RenderNode(FState.CurrentId);
  end
  else
    AppendStory('No save file found at: ' + FSavePath);
end;

procedure TFrmMain.BtnSendClick(Sender: TObject);
var
  Line: string;
begin
  Line := EdtCommand.Text.Trim;
  if Line <> '' then
  begin
    AppendStory('> ' + Line, False);
    HandleCommand(Line);
    EdtCommand.Text := '';
  end;
end;

procedure TFrmMain.ListChoicesItemClick(const Sender: TObject; const Item: TListBoxItem);
var
  Parts: TArray<string>;
  NextId, SetFlag: string;
  Choice: TChoice;
begin
  Parts := Item.TagString.Split(['|']);
  if Length(Parts) = 2 then
  begin
    NextId := Parts[0];
    SetFlag := Parts[1];
    Choice.Text := Item.Text;
    Choice.NextId := NextId;
    Choice.SetsFlag := SetFlag;
    Choice.RequiresFlag := '';
    AppendStory('> ' + Item.Text, False);
    HandleChoice(Choice);
  end;
end;

procedure TFrmMain.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  // Submit with Enter if focus is in the command field
  if (Key = vkReturn) and (EdtCommand.IsFocused) then
    BtnSendClick(Self);
end;

procedure TFrmMain.BtnMenuClick(Sender: TObject);
begin
  // Quick actions
  if MessageDlg('Quick actions', TMsgDlgType.mtInformation, 
                [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo, TMsgDlgBtn.mbCancel], 0,
                TMsgDlgBtn.mbYes, 'Save', 'Load', 'Cancel') = mrYes then
  begin
    SaveGame;
  end
  else if MessageDlgResult = mrNo then
  begin
    LoadGame;
  end;
end;

end.
