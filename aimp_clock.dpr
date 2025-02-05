library aimp_clock;

uses
  apiTypes,
  apiPlugin,
  aimp_clockUI in 'aimp_clockUI.pas' {frmClock},
  aimp_clockPlugin in 'aimp_clockPlugin.pas';

{$R *.res}

  function AIMPPluginGetHeader(out Header: IAIMPPlugin): HRESULT; stdcall;
  begin
    try
      Header := TPlugin.Create;
      Result := S_OK;
    except
      Result := E_UNEXPECTED;
    end;
  end;

exports
  AIMPPluginGetHeader;

begin
end.
