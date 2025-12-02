unit uMain;

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
