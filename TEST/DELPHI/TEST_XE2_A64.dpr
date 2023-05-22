program TEST_XE2_A64;

uses
  Windows,
  Vcl.Forms,
  uTest in 'uTest.pas' {mForm},
  SICxTypes in 'SICxTypes.pas',
  SICxProcs in 'SICxProcs.pas',
  SICxUDF in 'SICxUDF.pas',
  SICxTable in 'SICxTable.pas' {SICxTableForm},
  SICxUtils in 'SICxUtils.pas',
  SICxDefs in 'SICxDefs.pas',
  msvcrt in 'msvcrt.pas',
  SICxClasses in 'SICxClasses.pas',
  SICxIDA in 'SICxIDA.pas',
  SICxFPU in 'SICxFPU.pas',
  mt19937 in 'mt19937.pas',
  SICxDProcs in 'SICxDProcs.pas',
  SICxSSE in 'SICxSSE.pas',
  cordic in 'cordic.pas',
  SICxTest in 'SICxTest.pas',
  sfmtt in 'sfmtt.pas',
  sfmtu in 'sfmtu.pas',
  sfmt in 'sfmt.pas';

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
