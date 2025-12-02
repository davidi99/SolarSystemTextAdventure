unit UGameState;

interface

uses System.Generics.Collections, System.JSON, System.SysUtils;

type
  TChoice = record
    Text: string;
    NextId: string;
    RequiresFlag: string;
    SetsFlag: string;
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

implementation

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
  P: TPair<string, Boolean>;
begin
  Root := TJSONObject.Create;
  try
    Root.AddPair('current', FCurrentId);
    FlagsObj := TJSONObject.Create;
    for P in FFlags do FlagsObj.AddPair(P.Key, TJSONBool.Create(P.Value));
    Root.AddPair('flags', FlagsObj);
    VisObj := TJSONObject.Create;
    for P in FVisited do VisObj.AddPair(P.Key, TJSONBool.Create(P.Value));
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

end.
