program TEST_D2007_A32;

uses
  Windows,
  Forms,
  SICxTypes in 'SICxTypes.pas',
  SICxProcs in 'SICxProcs.pas',
  SICxUDF in 'SICxUDF.pas',
  SICxUtils in 'SICxUtils.pas',
  uTest in 'uTest.pas' {mForm},
  SICxTable in 'SICxTable.pas' {SICxTableForm},
  msvcrt in 'msvcrt.pas',
  SICxDefs in 'SICxDefs.pas',
  SICxClasses in 'SICxClasses.pas',
  SICxIDA in 'SICxIDA.pas',
  SICxFPU in 'SICxFPU.pas',
  mt19937 in 'mt19937.pas',
  SICxDProcs in 'SICxDProcs.pas',
  SICxSSE in 'SICxSSE.pas',
  cordic in 'cordic.pas',
  SICxTest in 'SICxTest.pas';

{$R *.res}

{$SETPEFLAGS IMAGE_FILE_RELOCS_STRIPPED}
{$SETPEFLAGS IMAGE_FILE_DEBUG_STRIPPED}
{$SETPEFLAGS IMAGE_FILE_LINE_NUMS_STRIPPED}
{$SETPEFLAGS IMAGE_FILE_LOCAL_SYMS_STRIPPED}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TmForm, mForm);
  Application.Run;
end.
