unit aimp_clockPlugin;

{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}

interface

uses
  apiCore,
  apiPlugin,
  apiTypes,
  apiWrappers,
  aimp_clockUI,
  AIMPCustomPlugin;

type
  TPlugin = class(TAIMPCustomPlugin, IAIMPExternalSettingsDialog)
  strict private
    FForm: TfrmClock;
  protected
    function InfoGet(Index: Integer): PChar; override; stdcall;
    function Initialize(Core: IAIMPCore): HRESULT; override; stdcall;
    function InfoGetCategories: LongWord; override; stdcall;
    procedure Finalize; override; stdcall;
    // IAIMPExternalSettingsDialog
    procedure Show(ParentWindow: HWND); stdcall;
  end;

implementation

uses
  SysUtils, ACL.Utils.Strings;

{ TPlugin }

procedure TPlugin.Finalize;
var
  LConfig: TAIMPServiceConfig;
begin
  if FForm <> nil then
  begin
    LConfig := ServiceGetConfig;
    try
      LConfig.WriteBool('Clock\Visible', FForm.Visible);
      LConfig.WriteString('Clock\Bounds', acRectToString(FForm.BoundsRect));
      LConfig.WriteInteger('Clock\Mode', FForm.Mode);
    finally
      LConfig.Free;
    end;
  end;

  FreeAndNil(FForm);
  inherited;
end;

function TPlugin.InfoGet(Index: Integer): PChar;
begin
  case Index of
    AIMP_PLUGIN_INFO_NAME:
      Result := 'Clock v0.1b';
    AIMP_PLUGIN_INFO_AUTHOR:
      Result := 'Artem Izmaylov';
    AIMP_PLUGIN_INFO_SHORT_DESCRIPTION:
      Result := 'Clock, track/playlist elapsed/remaining timer';
  else
    Result := nil;
  end;
end;

function TPlugin.InfoGetCategories: LongWord;
begin
  Result := AIMP_PLUGIN_CATEGORY_ADDONS;
end;

function TPlugin.Initialize(Core: IAIMPCore): HRESULT;
var
  LBounds: string;
  LConfig: TAIMPServiceConfig;
begin
  Result := inherited;
  if Result = 0 then
  begin
    FForm := TfrmClock.Create(nil);
    LConfig := ServiceGetConfig;
    try
      LBounds := LConfig.ReadString('Clock\Bounds');
      if LBounds <> '' then
        FForm.BoundsRect := acStringToRect(LBounds);
      FForm.Visible := LConfig.ReadBool('Clock\Visible', True);
      FForm.Mode := LConfig.ReadInteger('Clock\Mode');
    finally
      LConfig.Free;
    end;
  end;
end;

procedure TPlugin.Show(ParentWindow: HWND);
begin
  if FForm <> nil then
    FForm.Visible := not FForm.Visible;
end;

end.
