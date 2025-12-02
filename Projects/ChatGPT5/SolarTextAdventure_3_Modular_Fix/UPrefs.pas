unit UPrefs;

interface

uses System.SysUtils, System.JSON, System.IOUtils;

type
  TPrefs = record
    EnableSfx: Boolean;
    EnableParticles: Boolean;
    UseCustomStyle: Boolean;
    class function Load(const Path: string): TPrefs; static;
    class procedure Save(const Path: string; const P: TPrefs); static;
  end;

implementation

class function TPrefs.Load(const Path: string): TPrefs;
var s: string; jo: TJSONObject; b: Boolean;
begin
  Result.EnableSfx := True;
  Result.EnableParticles := True;
  Result.UseCustomStyle := True;
  if not TFile.Exists(Path) then Exit;
  s := TFile.ReadAllText(Path, TEncoding.UTF8);
  jo := TJSONObject(TJSONObject.ParseJSONValue(s));
  try
    if jo=nil then Exit;
    if jo.TryGetValue<Boolean>('sfx', b) then Result.EnableSfx := b;
    if jo.TryGetValue<Boolean>('particles', b) then Result.EnableParticles := b;
    if jo.TryGetValue<Boolean>('customStyle', b) then Result.UseCustomStyle := b;
  finally
    jo.Free;
  end;
end;

class procedure TPrefs.Save(const Path: string; const P: TPrefs);
var jo: TJSONObject;
begin
  jo := TJSONObject.Create;
  try
    if P.EnableSfx then jo.AddPair('sfx', TJSONTrue.Create) else jo.AddPair('sfx', TJSONFalse.Create);
    if P.EnableParticles then jo.AddPair('particles', TJSONTrue.Create) else jo.AddPair('particles', TJSONFalse.Create);
    if P.UseCustomStyle then jo.AddPair('customStyle', TJSONTrue.Create) else jo.AddPair('customStyle', TJSONFalse.Create);
    TFile.WriteAllText(Path, jo.ToJSON, TEncoding.UTF8);
  finally
    jo.Free;
  end;
end;

end.
