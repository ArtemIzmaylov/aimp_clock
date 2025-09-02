unit aimp_clockPlugin;

{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}

interface

uses
  Windows,
  apiCore,
  apiMenu,
  apiPlugin,
  apiPlaylists,
  apiTypes,
  apiWrappers,
  apiWrappersGUI,
  aimp_clockUI,
  AIMPCustomPlugin;

type
  TPlugin = class(TAIMPCustomPlugin, IAIMPExternalSettingsDialog)
  strict private
    FForm: TfrmClock;
    FMenuItem: IAIMPMenuItem;

    procedure RegisterAction;
    procedure ToggleVisibility;
    procedure UpdateMenuItem;
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
  FMenuItem := nil;
  if FForm <> nil then
  try
    LConfig := ServiceGetConfig;
    try
      LConfig.WriteString('Clock\Bounds', acRectToString(FForm.BoundsRect));
      LConfig.WriteBool('Clock\Blinking', FForm.miBlinkColon.Checked);
      LConfig.WriteBool('Clock\Visible', FForm.Visible);
      LConfig.WriteInteger('Clock\Mode', FForm.Mode);
    finally
      LConfig.Free;
    end;
  finally
    FreeAndNil(FForm);
  end;
  inherited;
end;

function TPlugin.InfoGet(Index: Integer): PChar;
begin
  case Index of
    AIMP_PLUGIN_INFO_NAME:
      Result := 'Clock v0.2b';
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
  inherited;
  if Supports(Core, IAIMPServicePlaylistManager) then // is it a player?
  begin
    RegisterAction;

    FForm := TfrmClock.Create(nil);

    LConfig := ServiceGetConfig;
    try
      LBounds := LConfig.ReadString('Clock\Bounds');
      if LBounds <> '' then
        FForm.RestoreBounds(acStringToRect(LBounds));
      FForm.miBlinkColon.Checked := LConfig.ReadBool('Clock\Blinking', True);
      FForm.Mode := LConfig.ReadInteger('Clock\Mode');
      FForm.Visible := LConfig.ReadBool('Clock\Visible', True); // last
    finally
      LConfig.Free;
    end;

    Result := S_OK;
  end
  else
    Result := E_FAIL;
end;

procedure TPlugin.RegisterAction;
var
  LParentItem: IAIMPMenuItem;
  LService: IAIMPServiceMenuManager;
begin
  if CoreGetService(IAIMPServiceMenuManager, LService) then
  begin
    CheckResult(CoreIntf.CreateObject(IID_IAIMPMenuItem, FMenuItem));
    PropListSetStr(FMenuItem, AIMP_MENUITEM_PROPID_ID, 'aimp.clock.toggleUI');
    PropListSetStr(FMenuItem, AIMP_MENUITEM_PROPID_NAME, 'Clock');
    PropListSetObj(FMenuItem, AIMP_MENUITEM_PROPID_EVENT, uiWrap(ToggleVisibility));
    PropListSetObj(FMenuItem, AIMP_MENUITEM_PROPID_EVENT_ONSHOW, uiWrap(UpdateMenuItem));
    if Succeeded(LService.GetBuiltIn(AIMP_MENUID_PLAYER_MAIN_FUNCTIONS, LParentItem)) then
    begin
      PropListSetObj(FMenuItem, AIMP_MENUITEM_PROPID_PARENT, LParentItem);
      CoreIntf.RegisterExtension(IAIMPServiceMenuManager, FMenuItem);
    end;
  end;
end;

procedure TPlugin.Show(ParentWindow: HWND);
begin
  ToggleVisibility;
end;

procedure TPlugin.ToggleVisibility;
begin
  if FForm <> nil then
    FForm.Visible := not FForm.Visible;
end;

procedure TPlugin.UpdateMenuItem;
begin
  if (FMenuItem <> nil) and (FForm <> nil) then
    PropListSetBool(FMenuItem, AIMP_MENUITEM_PROPID_CHECKED, FForm.Visible)
end;

end.
