library SICx64;

{$E OCX}

{$R 'Resource64.res' '..\Common\Resource64.rc'}

uses
  Windows,
  ComServ,
  SICx64_TLB in '..\Common\SICx64_TLB.pas',
  SICx64_CO in '..\Common\SICx64_CO.pas',
  msvcrt in '..\..\TEST\DELPHI\msvcrt.pas',
  SICxDefs in '..\..\TEST\DELPHI\SICxDefs.pas',
  SICxTypes in '..\..\TEST\DELPHI\SICxTypes.pas',
  SICxProcs in '..\..\TEST\DELPHI\SICxProcs.pas';

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

