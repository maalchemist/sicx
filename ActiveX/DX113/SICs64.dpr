library SICs64;

{$E OCX}

{$R 'Resource64s.res' '..\Common\Resource64s.rc'}

uses
  Windows,
  ComServ,
  msvcrt in '..\..\TEST\DELPHI\msvcrt.pas',
  SICxDefs in '..\..\TEST\DELPHI\SICxDefs.pas',
  SICxTypes in '..\..\TEST\DELPHI\SICxTypes.pas',
  SICxProcs in '..\..\TEST\DELPHI\SICxProcs.pas',
  SICs64_CO in '..\Common\SICs64_CO.pas',
  SICs64_TLB in '..\Common\SICs64_TLB.pas';

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

