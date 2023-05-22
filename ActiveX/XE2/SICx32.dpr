library SICx32;

{$E OCX}

uses
  Windows,
  ComServ,
  msvcrt in '..\..\TEST\DELPHI\msvcrt.pas',
  SICxDefs in '..\..\TEST\DELPHI\SICxDefs.pas',
  SICxTypes in '..\..\TEST\DELPHI\SICxTypes.pas',
  SICxProcs in '..\..\TEST\DELPHI\SICxProcs.pas',
  SICx32_CO in '..\Common\SICx32_CO.pas',
  SICx32_TLB in '..\Common\SICx32_TLB.pas';

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer,
  DllInstall;

{$R *.TLB}

{$R *.RES}

// (*
{.$SETPEFLAGS IMAGE_FILE_RELOCS_STRIPPED}
{$SETPEFLAGS IMAGE_FILE_DEBUG_STRIPPED}
{$SETPEFLAGS IMAGE_FILE_LINE_NUMS_STRIPPED}
{$SETPEFLAGS IMAGE_FILE_LOCAL_SYMS_STRIPPED}

{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
// *)

begin
end.
