unit aimp_clockUI;

{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}

interface

uses
  Messages,
  Windows,
  // System
  Classes,
  SysUtils,
  // Vcl
  Controls,
  Forms,
  Graphics,
  Menus,
  // API
  apiCore,
  apiObjects,
  apiPlayer,
  apiPlaylists,
  apiWrappers,
  // ACL
  ACL.FileFormats.INI,
  ACL.Graphics,
  ACL.Timers,
  ACL.UI.Application,
  ACL.UI.Forms.Base,
  ACL.UI.Menus,
  ACL.Utils.Date,
  ACL.Utils.Strings;

type
  TfrmClock = class(TACLBasicForm)
    miClock: TACLMenuItem;
    miClose: TACLMenuItem;
    miLine1: TACLMenuItem;
    miLine2: TACLMenuItem;
    miLine3: TACLMenuItem;
    miPlaylistElapsed: TACLMenuItem;
    miPlaylistRemaining: TACLMenuItem;
    miTrackElapsed: TACLMenuItem;
    miTrackRemaining: TACLMenuItem;
    Settings: TACLPopupMenu;
    Timer: TACLTimer;
    UI: TACLApplicationController;

    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormTimer(Sender: TObject);
    procedure miClockClick(Sender: TObject);
    procedure miCloseClick(Sender: TObject);
    procedure SettingsPopup(Sender: TObject);
  strict private
    FMode: Integer;
    FTime: Int64;

    function ContentRect: TRect;
    function FetchTime: Int64;
    procedure FetchPlayingPlaylistTime(var ATime: Int64; ARemaining: Boolean);
    procedure FetchPlayingTrackTime(var ATime: Int64; ARemaining: Boolean);
    procedure SetMode(AValue: Integer);
    // Messages
    procedure WMNCContextMenu(var Msg: TMessage); message WM_NCRBUTTONUP;
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AOwner: TComponent); override;
    // Properties
    property Mode: Integer read FMode write SetMode;
  end;

implementation

{$R *.dfm}

uses
  DateUtils;

const
  NoValue: Int64 = -1;

function FormatTime(const ATime: Int64): string;
begin
  if ATime = NoValue then
    Result := '--:--:--'
  else
    Result := TACLTimeFormat.Format(ATime * 1000, [ftpSeconds..ftpHours], False);

  if ATime mod 2 = 0 then
    Result := acStringReplace(Result, ':', ' ');
end;

{ TfrmClock }

constructor TfrmClock.Create(AOwner: TComponent);
begin
  inherited;
  with TACLIniFile.Create('aimp_clock.ini', False) do
  try
    Color := TAlphaColor.FromString(ReadString('Clock', 'BackColor', 'FF000000')).ToColor;
    Font.Color := TAlphaColor.FromString(ReadString('Clock', 'TextColor', 'FFFFFFFF')).ToColor;
    Font.Name := ReadString('Clock', 'TextFont', 'Tahoma');
  finally
    Free;
  end;
end;

function TfrmClock.ContentRect: TRect;
begin
  Result := ClientRect;
  Result.Inflate(-12, -12);
end;

procedure TfrmClock.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.ExStyle := WS_EX_TOOLWINDOW;
end;

procedure TfrmClock.FetchPlayingPlaylistTime(var ATime: Int64; ARemaining: Boolean);
var
  LPlaylist: IAIMPPlaylist;
  LPlaylistProperties: IAIMPPropertyList;
  LService: IAIMPServicePlaylistManager;
begin
  if CoreGetService(IAIMPServicePlaylistManager, LService) and
    Succeeded(LService.GetPlayingPlaylist(LPlaylist)) then
  begin
    LPlaylistProperties := LPlaylist as IAIMPPropertyList;
    if ARemaining then
      ATime := -Trunc(
        PropListGetFloat(LPlaylistProperties, AIMP_PLAYLIST_PROPID_DURATION_REMAINING))
    else
      ATime := Trunc(
        PropListGetFloat(LPlaylistProperties, AIMP_PLAYLIST_PROPID_DURATION) -
        PropListGetFloat(LPlaylistProperties, AIMP_PLAYLIST_PROPID_DURATION_REMAINING));
  end;
end;

procedure TfrmClock.FetchPlayingTrackTime(var ATime: Int64; ARemaining: Boolean);
var
  LDuration: Double;
  LPosition: Double;
  LService: IAIMPServicePlayer;
begin
  if CoreGetService(IAIMPServicePlayer, LService) and
    Succeeded(LService.GetPosition(LPosition)) and
    Succeeded(LService.GetDuration(LDuration))
  then
    if ARemaining then
      ATime := Trunc(LPosition - LDuration)
    else
      ATime := Trunc(LPosition);
end;

function TfrmClock.FetchTime: Int64;
begin
  Result := NoValue;
  case Mode of
    0: Result := TACLDateUtils.DateTimeToSeconds(TimeOf(Now));
    1: FetchPlayingTrackTime(Result, False);
    2: FetchPlayingTrackTime(Result, True);
    3: FetchPlayingPlaylistTime(Result, False);
    4: FetchPlayingPlaylistTime(Result, True);
  end;
end;

procedure TfrmClock.FormPaint(Sender: TObject);
begin
  acTextDraw(Canvas, FormatTime(FTime), ContentRect, taCenter, taVerticalCenter);
end;

procedure TfrmClock.FormResize(Sender: TObject);
var
  LFontMax: Integer;
  LFontMin: Integer;
  LFontOpt: Integer;
  LRect: TRect;
  LSize: TSize;
  LText: string;
begin
  LRect := ContentRect;
  LFontOpt := 0;
  LFontMin := 1;
  LFontMax := LRect.Height;
  LText := ' -' + FormatTime(0);
  while LFontMin <= LFontMax do
  begin
    Canvas.Font.Height := (LFontMin + LFontMax) div 2;
    LSize := acTextSize(Canvas, LText);
    if (LSize.Height > LRect.Height) or (LSize.Width > LRect.Width) then
      LFontMax := Canvas.Font.Height - 1
    else
    begin
      LFontOpt := Canvas.Font.Height;
      LFontMin := LFontOpt + 1;
    end;
  end;
  if LFontOpt > 0 then
    Font.Height := LFontOpt;
  Invalidate;
end;

procedure TfrmClock.FormTimer(Sender: TObject);
var
  LTime: Int64;
begin
  if Visible then
  begin
    LTime := FetchTime;
    if LTime <> FTime then
    begin
      FTime := LTime;
      Invalidate;
    end;
  end;
end;

procedure TfrmClock.WMNCContextMenu(var Msg: TMessage);
begin
  inherited;
  Settings.Popup(Mouse.CursorPos);
end;

procedure TfrmClock.WMNCHitTest(var Msg: TWMNCHitTest);

  function HitTest(const P: TPoint): Integer;
  var
    LRect: TRect;
  begin
    LRect := BoundsRect;
    LRect.Inflate(-12, -12);
    if P.X < LRect.Left then
    begin
      if P.Y < LRect.Top then
        Exit(HTTOPLEFT);
      if P.Y > LRect.Bottom then
        Exit(HTBOTTOMLEFT);
      Exit(HTLEFT);
    end;

    if P.X > LRect.Right then
    begin
      if P.Y < LRect.Top then
        Exit(HTTOPRIGHT);
      if P.Y > LRect.Bottom then
        Exit(HTBOTTOMRIGHT);
      Exit(HTRIGHT);
    end;

    if P.Y < LRect.Top then
      Exit(HTTOP);
    if P.Y > LRect.Bottom then
      Exit(HTBOTTOM);
    Result := HTCAPTION;
  end;

begin
  Msg.Result := HitTest(Msg.Pos);
end;

procedure TfrmClock.miClockClick(Sender: TObject);
begin
  SetMode(TComponent(Sender).Tag);
end;

procedure TfrmClock.miCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmClock.SetMode(AValue: Integer);
begin
  if FMode <> AValue then
  begin
    FMode := AValue;
    FormTimer(nil);
  end;
end;

procedure TfrmClock.SettingsPopup(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to Settings.Items.Count - 1 do
    Settings.Items[I].Checked := Settings.Items[I].Tag = Mode;
end;

end.
