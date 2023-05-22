echo off

@cd /d "%~dp0"

set CODE_BIN=CODE.bin
set CODE_ASM=CODE.asm
set CODE_EXE=CODE.bin_exe
set CODE_DMP=CODE.dmp

if exist %CODE_EXE% del %CODE_EXE%
if exist %CODE_DMP% del %CODE_DMP%

if not exist %CODE_BIN% goto RET
if not exist %CODE_ASM% goto RET

set PROGS=C:\Program Files (x86)
set FASM=%PROGS%\FASM
set VS=%PROGS%\Microsoft Visual Studio 14.0

rem *** BUILD
"%FASM%\FASM.EXE" %CODE_ASM% -m 65536

if not exist %CODE_EXE% goto RET

set VS_IDE=%VS%\Common7\IDE
set VS_BIN=%VS%\VC\bin
set PATH=%VS_IDE%;%VS_BIN%;

rem *** DUMP
"%VS_BIN%\dumpbin.exe" /disasm %CODE_EXE% /out:%CODE_DMP%

:RET
pause
