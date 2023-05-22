ECHO OFF

@cd /d "%~dp0"

set PROGS=C:\Program Files (x86)
set PATH=%PROGS%\FASM
set INCLUDE=%PATH%\INCLUDE
set FASM="%PATH%\FASM.EXE"
set FASMM=131072

if exist TEST64.EXE del TEST64.EXE
if exist TEST64S.EXE del TEST64S.EXE

rem *** BUILD
%FASM% TEST64.ASM -m %FASMM%
if errorlevel 1 goto ERROR
%FASM% TEST64S.ASM -m %FASMM%
if errorlevel 1 goto ERROR

GOTO RET
:ERROR
if exist TEST64.EXE del TEST64.EXE
if exist TEST64S.EXE del TEST64S.EXE

:RET
pause
