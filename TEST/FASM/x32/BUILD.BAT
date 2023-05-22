ECHO OFF

@cd /d "%~dp0"

set PROGS=C:\Program Files (x86)
set PATH=%PROGS%\FASM
set INCLUDE=%PATH%\INCLUDE
set FASM="%PATH%\FASM.EXE"
set FASMM=131072

if exist TEST32.EXE del TEST32.EXE
if exist TEST32S.EXE del TEST32S.EXE

rem *** BUILD
%FASM% TEST32.ASM -m %FASMM%
if errorlevel 1 goto ERROR
%FASM% TEST32S.ASM -m %FASMM%
if errorlevel 1 goto ERROR

GOTO RET
:ERROR
if exist TEST32.EXE del TEST32.EXE
if exist TEST32S.EXE del TEST32S.EXE

:RET
pause
