unit MainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Generics.Collections, System.IOUtils, System.JSON, System.Math,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.StdCtrls, FMX.Layouts, FMX.Memo, FMX.Edit, FMX.ListBox, FMX.ScrollBox,
  FMX.Controls.Presentation, FMX.Objects, FMX.TabControl, FMX.ListView,
  FMX.ListView.Types, FMX.Ani, FMX.Effects, FMX.Filter.Effects, FMX.Media, FMX.Styles,
  UGameState, UDataRepos, UContent, UStarMap, UPrefs, FMX.Memo.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base;

type
  TFrmMain = class(TForm)
    StyleBook1: TStyleBook;
    TopBar: TToolBar;
    LblTitle: TLabel;
    BtnMenu: TSpeedButton;
    Tabs: TTabControl;
    TabStory: TTabItem;
    TabMap: TTabItem;
    TabCodex: TTabItem;
    TabAch: TTabItem;
    TabSettings: TTabItem;
    MemoStory: TMemo;
    ListChoices: TListBox;
    BottomBar: TLayout;
    EdtCommand: TEdit;
    BtnSend: TButton;
    MapRoot: TLayout;
    PaintMap: TPaintBox;
    MapTimer: TTimer;
    LV_Codex: TListView;
    CodexDetailPanel: TLayout;
    CodexTitle: TLabel;
    CodexText: TMemo;
    LV_Ach: TListView;
    Toast: TLayout;
    ToastLbl: TLabel;
    FadeIn: TFloatAnimation;
    FadeOut: TFloatAnimation;
    Glow: TGlowEffect;
    SwitchSound: TSwitch;
    SwitchParticles: TSwitch;
    SwitchTheme: TSwitch;
    BtnApplyTheme: TButton;
    SndClick: TMediaPlayer;
    SndAchievement: TMediaPlayer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnSendClick(Sender: TObject);
    procedure ListChoicesItemClick(const Sender: TObject; const Item: TListBoxItem);
    procedure EdtCommandKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure BtnMenuClick(Sender: TObject);
    procedure PaintMapPaint(Sender: TObject; Canvas: TCanvas);
    procedure MapTimerTimer(Sender: TObject);
    procedure LV_CodexItemClick(const Sender: TObject; const AItem: TListViewItem);
    procedure PaintMapMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure PaintMapMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure SwitchSoundSwitch(Sender: TObject);
    procedure SwitchParticlesSwitch(Sender: TObject);
    procedure SwitchThemeSwitch(Sender: TObject);
    procedure BtnApplyThemeClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
  private
    FNodes: TDictionary<string, TNode>;
    FState: TGameState;
    FSavePath, FPrefsPath: string;
    FAch: TAchievementRepo;
    FCodex: TCodexRepo;
    FStar: TStarMap;
    FEnableSfx, FEnableParticles, FUseCustomStyle: Boolean;
    procedure LoadContentFromJSON(const Json: string);
    procedure RenderNode(const Id: string);
    procedure AppendStory(const S: string; const AddBlank: Boolean = True);
    procedure HandleChoice(const Choice: TChoice);
    procedure HandleCommand(const CmdLine: string);
    procedure ShowHelp;
    procedure SaveGame;
    procedure LoadGame;
    procedure RefreshAchievementsView;
    procedure RefreshCodexList;
    procedure ShowToast(const Msg: string);
    procedure JumpToNode(const NodeId: string);
    procedure ApplyDarkThemeFallback;
    procedure LoadOrGenerateCustomStyle;
    procedure ExtractAudioFromResources;
    procedure SavePrefs;
    procedure LoadPrefs;
  public
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.fmx}

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  Caption := 'Solar Text Adventure';
  FNodes := TDictionary<string, TNode>.Create;
  FState := TGameState.Create;
  FAch := TAchievementRepo.Create;
  FCodex := TCodexRepo.Create;
  FStar := TStarMap.Create;

  FSavePath := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'SolarTextAdventure.save.json');
  FPrefsPath := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'SolarTextAdventure.prefs.json');

  // defaults (overridden by prefs)
  FEnableSfx := True; FEnableParticles := True; FUseCustomStyle := True;
  LoadPrefs;

  FAch.Seed;
  FCodex.Seed;
  FStar.InitDefault;

  LoadContentFromJSON(TContent.SolarJson);
  AppendStory('Welcome, Explorer. Type "help" for commands.');
  RenderNode(FState.CurrentId);

  ExtractAudioFromResources;
  LoadOrGenerateCustomStyle;

  RefreshAchievementsView;
  RefreshCodexList;

  // reflect settings
  if Assigned(SwitchSound) then SwitchSound.IsChecked := FEnableSfx;
  if Assigned(SwitchParticles) then SwitchParticles.IsChecked := FEnableParticles;
  if Assigned(SwitchTheme) then SwitchTheme.IsChecked := FUseCustomStyle;

  Tabs.ActiveTab := TabStory;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  FNodes.Free;
  FAch.Free;
  FCodex.Free;
  FStar.Free;
  FState.Free;
end;

procedure TFrmMain.AppendStory(const S: string; const AddBlank: Boolean);
begin
  if S <> '' then MemoStory.Lines.Add(S);
  if AddBlank then MemoStory.Lines.Add('');
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
          if not JC.TryGetValue<string>('requires', C.RequiresFlag) then C.RequiresFlag := '';
          if not JC.TryGetValue<string>('sets', C.SetsFlag) then C.SetsFlag := '';
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

  // Codex unlock
  if FCodex.Unlock(Node.Id) then
  begin
    RefreshCodexList;
    ShowToast('Codex updated: ' + FCodex.Data[Node.Id].Title);
  end;

  // Achievements
  if (Id <> 'intro') then
    if FAch.Unlock('ach_first_jump') then
    begin
      RefreshAchievementsView;
      ShowToast('Achievement unlocked: ' + FAch.Data['ach_first_jump'].Name);
      if FEnableSfx and Assigned(SndAchievement) and (SndAchievement.FileName<>'') then
        try SndAchievement.Stop; SndAchievement.Play; except end;
    end;

  if FState.Visited.ContainsKey('mercury') and FState.Visited.ContainsKey('venus') and FState.Visited.ContainsKey('luna') then
    if FAch.Unlock('ach_inner_scout') then begin RefreshAchievementsView; ShowToast('Achievement unlocked: ' + FAch.Data['ach_inner_scout'].Name); end;
  if Id = 'valles' then if FAch.Unlock('ach_martian') then begin RefreshAchievementsView; ShowToast('Achievement unlocked: ' + FAch.Data['ach_martian'].Name); end;
  if Id = 'ceres' then if FAch.Unlock('ach_beltalowda') then begin RefreshAchievementsView; ShowToast('Achievement unlocked: ' + FAch.Data['ach_beltalowda'].Name); end;
  if (Id = 'europa') or (Id = 'io') then if FAch.Unlock('ach_jovian') then begin RefreshAchievementsView; ShowToast('Achievement unlocked: ' + FAch.Data['ach_jovian'].Name); end;
  if Id = 'titan' then if FAch.Unlock('ach_titan') then begin RefreshAchievementsView; ShowToast('Achievement unlocked: ' + FAch.Data['ach_titan'].Name); end;
  if Id = 'pluto' then if FAch.Unlock('ach_edge') then begin RefreshAchievementsView; ShowToast('Achievement unlocked: ' + FAch.Data['ach_edge'].Name); end;

  // Build choices
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

  if Tabs.ActiveTab = TabMap then PaintMap.Repaint;
end;

procedure TFrmMain.HandleChoice(const Choice: TChoice);
begin
  if Choice.SetsFlag <> '' then FState.Flags.AddOrSetValue(Choice.SetsFlag, True);
  RenderNode(Choice.NextId);
end;

procedure TFrmMain.HandleCommand(const CmdLine: string);
var Parts: TArray<string>; Cmd, Arg, NodeId: string;
begin
  Parts := CmdLine.Trim.Split([' '], 2);
  if Length(Parts) = 0 then Exit;
  Cmd := Parts[0].ToLower;
  Arg := ''; if Length(Parts) > 1 then Arg := Parts[1];

  if (Cmd = 'help') or (Cmd = '?') then (ShowHelp) else
  if Cmd = 'scan' then
  begin
    AppendStory('Sensors sweep the area. New scientific notes added where available.');
    FState.Flags.AddOrSetValue('scanned', True);
  end
  else if Cmd = 'status' then
  begin
    AppendStory(Format('Current: %s', [FState.CurrentId]));
    AppendStory(Format('Flags: %d, Visited: %d', [FState.Flags.Count, FState.Visited.Count]));
  end
  else if Cmd = 'save' then SaveGame
  else if Cmd = 'load' then LoadGame
  else if (Cmd = 'go') and (Arg <> '') then
  begin
    NodeId := Arg.Trim.ToLower;
    if FNodes.ContainsKey(NodeId) then JumpToNode(NodeId)
    else AppendStory('Unknown destination id: ' + NodeId);
  end
  else AppendStory('Command not recognized. Type "help" for options.');
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
var S: string;
begin
  S := FState.ToJSON;
  TFile.WriteAllText(FSavePath, S, TEncoding.UTF8);
  ShowToast('Game saved');
end;

procedure TFrmMain.LoadGame;
var S: string;
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

procedure TFrmMain.RefreshAchievementsView;
var Pair: TPair<string, TAchievement>; Item: TListViewItem;
begin
  LV_Ach.BeginUpdate;
  try
    LV_Ach.Items.Clear;
    for Pair in FAch.Data do
    begin
      Item := LV_Ach.Items.Add;
      if Pair.Value.Unlocked then
        Item.Text := Pair.Value.Name + ' ✓'
      else
        Item.Text := Pair.Value.Name;
      Item.Detail := Pair.Value.Desc;
    end;
  finally
    LV_Ach.EndUpdate;
  end;
end;

procedure TFrmMain.RefreshCodexList;
var Pair: TPair<string, TCodexEntry>; Item: TListViewItem;
begin
  LV_Codex.BeginUpdate;
  try
    LV_Codex.Items.Clear;
    for Pair in FCodex.Data do
      if Pair.Value.Unlocked then
      begin
        Item := LV_Codex.Items.Add;
        Item.Text := Pair.Value.Title;
        Item.Detail := Pair.Value.Id;
      end;
  finally
    LV_Codex.EndUpdate;
  end;
end;

procedure TFrmMain.ShowToast(const Msg: string);
begin
  ToastLbl.Text := Msg;
  Toast.Visible := True;
  Toast.Opacity := 0;
  FadeIn.Stop; FadeOut.Stop;
  FadeIn.Start;
  if FEnableSfx and Assigned(SndClick) and (SndClick.FileName<>'') then
    try SndClick.Stop; SndClick.Play; except end;
end;

procedure TFrmMain.JumpToNode(const NodeId: string);
begin
  RenderNode(NodeId);
  Tabs.ActiveTab := TabStory;
end;

procedure TFrmMain.ApplyDarkThemeFallback;
begin
  Fill.Color := $FF0F1116;
end;

procedure TFrmMain.LoadOrGenerateCustomStyle;
var
  Docs, AssetsDir, StylesDir, StylePath, InfoPath: string;
  FS: TFileStream;
begin
  Docs := System.IOUtils.TPath.GetDocumentsPath;
  AssetsDir := System.IOUtils.TPath.Combine(Docs, 'Assets');
  StylesDir := System.IOUtils.TPath.Combine(AssetsDir, 'Styles');
  System.SysUtils.ForceDirectories(StylesDir);
  StylePath := System.IOUtils.TPath.Combine(StylesDir, 'SolarStyle.style');
  InfoPath := System.IOUtils.TPath.Combine(StylesDir, 'SolarStyle.style.info.txt');

  if not FUseCustomStyle then
  begin
    TStyleManager.SetStyle(nil);
    ShowToast('System theme applied');
    Exit;
  end;

  if TFile.Exists(StylePath) then
  begin
    try
      FS := TFileStream.Create(StylePath, fmOpenRead or fmShareDenyNone);
      try
        StyleBook1.Clear;
        StyleBook1.LoadFromStream(FS);
        TStyleManager.SetStyle(StyleBook1.Style);
        ShowToast('Custom style applied');
        Exit;
      finally
        FS.Free;
      end;
    except
      // fall through to fallback
    end;
  end;

  ApplyDarkThemeFallback;
  try
    TFile.WriteAllText(InfoPath,
      'Replace this file with a .style exported from the IDE to skin the app.' + sLineBreak +
      'Expected path: ' + StylePath, TEncoding.UTF8);
  except
    // ignore write failures; continue
  end;
  ShowToast('Using built-in dark theme');
end;

procedure TFrmMain.ExtractAudioFromResources;
  function Join2(const A, B: string): string;
  begin
    Result := System.IOUtils.TPath.Combine(A, B);
  end;
  procedure ExtractRes(const ResName, OutName: string);
  var RS: TResourceStream; Tmp: string; FS: TFileStream;
  begin
    try
      RS := TResourceStream.Create(HInstance, ResName, RT_RCDATA);
      try
        Tmp := Join2(System.IOUtils.TPath.GetTempPath, OutName);
        FS := TFileStream.Create(Tmp, fmCreate);
        try FS.CopyFrom(RS, RS.Size); finally FS.Free; end;
        if SameText(OutName, 'click.mp3') and Assigned(SndClick) then SndClick.FileName := Tmp;
        if SameText(OutName, 'achievement.mp3') and Assigned(SndAchievement) then SndAchievement.FileName := Tmp;
      finally RS.Free; end;
    except
      // resources optional; file fallback
      var Base := Join2(System.IOUtils.TPath.GetDocumentsPath, 'Assets');
      var Sounds := Join2(Base, 'Sounds');
      var ClickPath := Join2(Sounds, 'click.mp3');
      var AchPath   := Join2(Sounds, 'achievement.mp3');
      if (SndClick.FileName = '') and TFile.Exists(ClickPath) then SndClick.FileName := ClickPath;
      if (SndAchievement.FileName = '') and TFile.Exists(AchPath) then SndAchievement.FileName := AchPath;
    end;
  end;
begin
  ExtractRes('CLICK_MP3', 'click.mp3');
  ExtractRes('ACH_MP3', 'achievement.mp3');
end;

procedure TFrmMain.SavePrefs;
var P: TPrefs;
begin
  P.EnableSfx := FEnableSfx;
  P.EnableParticles := FEnableParticles;
  P.UseCustomStyle := FUseCustomStyle;
  TPrefs.Save(FPrefsPath, P);
end;

procedure TFrmMain.LoadPrefs;
var P: TPrefs;
begin
  P := TPrefs.Load(FPrefsPath);
  FEnableSfx := P.EnableSfx;
  FEnableParticles := P.EnableParticles;
  FUseCustomStyle := P.UseCustomStyle;
end;

procedure TFrmMain.BtnSendClick(Sender: TObject);
var Line: string;
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
var Parts: TArray<string>; NextId, SetFlag: string; Choice: TChoice;
begin
  Parts := Item.TagString.Split(['|']);
  if Length(Parts) = 2 then
  begin
    NextId := Parts[0]; SetFlag := Parts[1];
    Choice.Text := Item.Text; Choice.NextId := NextId; Choice.SetsFlag := SetFlag; Choice.RequiresFlag := '';
    AppendStory('> ' + Item.Text, False);
    HandleChoice(Choice);
  end;
end;

procedure TFrmMain.EdtCommandKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then BtnSendClick(Self);
end;

procedure TFrmMain.BtnMenuClick(Sender: TObject);
begin
  case MessageDlg('Save game now? (No = Load)', TMsgDlgType.mtConfirmation,
                  [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) of
    mrYes: SaveGame;
    mrNo:  LoadGame;
  end;
end;

procedure TFrmMain.PaintMapPaint(Sender: TObject; Canvas: TCanvas);
begin
  FStar.Paint(Canvas, PaintMap.Width, PaintMap.Height);
end;

procedure TFrmMain.MapTimerTimer(Sender: TObject);
begin
  FStar.Tick;
  PaintMap.Repaint;
end;

procedure TFrmMain.PaintMapMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var id: string;
begin
  id := FStar.HitTest(PointF(X,Y));
  FStar.SetHover(id);
  if id <> '' then PaintMap.Cursor := crHandPoint else PaintMap.Cursor := crDefault;
  PaintMap.Repaint;
end;

procedure TFrmMain.PaintMapMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var id: string;
begin
  id := FStar.HitTest(PointF(X,Y));
  if id <> '' then JumpToNode(id);
end;

procedure TFrmMain.LV_CodexItemClick(const Sender: TObject; const AItem: TListViewItem);
var Id: string; E: TCodexEntry;
begin
  Id := AItem.Detail;
  if FCodex.Data.TryGetValue(Id, E) then
  begin
    CodexTitle.Text := E.Title;
    CodexText.Lines.Text := E.Text;
  end;
end;

procedure TFrmMain.SwitchSoundSwitch(Sender: TObject);
begin
  FEnableSfx := SwitchSound.IsChecked;
  SavePrefs;
end;

procedure TFrmMain.SwitchParticlesSwitch(Sender: TObject);
begin
  FEnableParticles := SwitchParticles.IsChecked;
  SavePrefs;
end;

procedure TFrmMain.SwitchThemeSwitch(Sender: TObject);
begin
  FUseCustomStyle := SwitchTheme.IsChecked;
  SavePrefs;
end;

procedure TFrmMain.BtnApplyThemeClick(Sender: TObject);
begin
  LoadOrGenerateCustomStyle;
end;

procedure TFrmMain.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Tabs.ActiveTab = TabMap then
  begin
    case Key of
      vkLeft, vkUp:    FStar.SelectDelta(-1);
      vkRight, vkDown: FStar.SelectDelta(1);
      vkReturn: if FStar.GetHover <> '' then JumpToNode(FStar.GetHover);
    end;
    PaintMap.Repaint;
  end;
end;

end.
