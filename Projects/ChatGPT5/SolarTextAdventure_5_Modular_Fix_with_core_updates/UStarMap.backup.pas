unit UStarMap;

interface

uses System.Types, System.UITypes, System.SysUtils, System.Math, System.Generics.Collections,
     FMX.Graphics, FMX.Types;

type
  TMapBody = record
    Id, Name: string;
    AngleFactor: Single;
    RadiusFactor: Single;
    LastPos: TPointF;
    LabelRect: TRectF;
  end;

  TStarMap = class
  private
    FBodies: TArray<TMapBody>;
    FAngle: Single;
    FHoverId: string;
    function EstimateTextWidth(const Canvas: TCanvas; const S: string): Single;
  public
    constructor Create;
    procedure InitDefault;
    procedure Paint(Canvas: TCanvas; const W, H: Single);
    procedure Tick;
    function HitTest(const P: TPointF): string;
    procedure SetHover(const Id: string);
    function GetHover: string;
    function IndexOf(const AId: string): Integer;
    procedure SelectDelta(const Delta: Integer);
    property Angle: Single read FAngle write FAngle;
  end;

implementation

constructor TStarMap.Create;
begin
  inherited;
  FAngle := 0;
  SetLength(FBodies, 0);
  FHoverId := '';
end;

procedure TStarMap.InitDefault;
  procedure Add(const id,name: string; ang,rad: Single);
  var i: Integer;
  begin
    i := Length(FBodies);
    SetLength(FBodies, i+1);
    FBodies[i].Id := id; FBodies[i].Name := name; FBodies[i].AngleFactor := ang; FBodies[i].RadiusFactor := rad;
  end;
begin
  SetLength(FBodies,0);
  Add('mercury','Mercury',4.0,0.20);
  Add('venus','Venus',2.5,0.32);
  Add('luna','Luna',2.0,0.45);
  Add('mars','Mars',1.6,0.60);
  Add('ceres','Ceres',1.2,0.75);
  Add('ganymede','Jupiter→Ganymede',0.8,0.95);
end;

function TStarMap.EstimateTextWidth(const Canvas: TCanvas; const S: string): Single;
var
  avgChar: Single;
begin
  if (Canvas = nil) or (Canvas.Font = nil) then
    avgChar := 8
  else
    avgChar := 0.6 * Canvas.Font.Size;
  Result := (Length(S) * avgChar) + 4;
end;

procedure TStarMap.Paint(Canvas: TCanvas; const W, H: Single);
var
  cx, cy, Radius: Single;
  i: Integer;

  procedure DrawOrbit(const OrbitRadius: Single);
  var OrbitRect: TRectF;
  begin
    OrbitRect := TRectF.Create(cx - OrbitRadius, cy - OrbitRadius, cx + OrbitRadius, cy + OrbitRadius);
    Canvas.DrawEllipse(OrbitRect, 1);
  end;

  procedure DrawBodyIndex(const Index: Integer);
  var
    x, y, w: Single;
    DotRect, LabelRect: TRectF;
    B: TMapBody;
    isHover: Boolean;
    ang, rad, exX, exY: Double;
  begin
    B := FBodies[Index];

    ang := Double(FAngle) * Double(B.AngleFactor);
    rad := Double(Radius) * Double(B.RadiusFactor);
    exX := Double(cx) + Cos(ang) * rad;
    exY := Double(cy) + Sin(ang) * rad;

    x := Single(exX);
    y := Single(exY);
    FBodies[Index].LastPos := PointF(x, y);

    // planet dot
    DotRect := TRectF.Create(x - 6, y - 6, x + 6, y + 6);
    Canvas.Fill.Color := $FFEEEEEE;
    Canvas.FillEllipse(DotRect, 1);

    // label
    w := EstimateTextWidth(Canvas, B.Name);
    LabelRect := TRectF.Create(x + 8, y - 10, x + 8 + w + 8, y + 12);
    FBodies[Index].LabelRect := LabelRect;

    isHover := SameText(FHoverId, B.Id);
    if isHover then
    begin
      Canvas.Fill.Color := $6622CCFF;
      Canvas.FillRect(LabelRect, 4, 4, [], 1);
    end;

    Canvas.Fill.Color := $FFFFFFFF;
    Canvas.FillText(TRectF.Create(x + 10, y - 8, x + 10 + w, y + 12),
                    B.Name, False, 1, [], TTextAlign.Leading, TTextAlign.Leading);
  end;

begin
  cx := W / 2;
  cy := H / 2;
  Radius := Min(cx, cy) - 16;

  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Thickness := 1.2;
  Canvas.Stroke.Color := $55FFFFFF;

  // Sun
  Canvas.Fill.Color := $FFFFC14D;
  Canvas.FillEllipse(TRectF.Create(cx - 10, cy - 10, cx + 10, cy + 10), 1);

  // Orbits
  for i := 1 to 5 do
    DrawOrbit(Radius * (i / 5));

  // Bodies
  for i := Low(FBodies) to High(FBodies) do
    DrawBodyIndex(i);
end;

procedure TStarMap.Tick;
begin
  FAngle := FAngle + 0.01;
  if FAngle > 2*Pi then FAngle := FAngle - 2*Pi;
end;

function TStarMap.HitTest(const P: TPointF): string;
var i: Integer; d, dx, dy: Single;
begin
  Result := '';
  for i := Low(FBodies) to High(FBodies) do
  begin
    dx := P.X - FBodies[i].LastPos.X;
    dy := P.Y - FBodies[i].LastPos.Y;
    d  := Sqrt(dx*dx + dy*dy);
    if (d <= 12) or (FBodies[i].LabelRect.Contains(P)) then
      Exit(FBodies[i].Id);
  end;
end;

procedure TStarMap.SetHover(const Id: string);
begin
  FHoverId := Id;
end;

function TStarMap.GetHover: string;
begin
  Result := FHoverId;
end;

function TStarMap.IndexOf(const AId: string): Integer;
var i: Integer;
begin
  Result := -1;
  for i := Low(FBodies) to High(FBodies) do
    if SameText(FBodies[i].Id, AId) then Exit(i);
end;

procedure TStarMap.SelectDelta(const Delta: Integer);
var idx, len: Integer;
begin
  len := Length(FBodies);
  if len=0 then Exit;
  idx := IndexOf(FHoverId);
  if idx<0 then idx := 0;
  idx := (idx + Delta) mod len;
  if idx<0 then idx := len-1;
  FHoverId := FBodies[idx].Id;
end;

end.
