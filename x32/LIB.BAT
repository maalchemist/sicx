ECHO OFF

@cd /d "%~dp0"

set VSP=C:\Program Files (x86)\Microsoft Visual Studio 14.0
set LIB=%VSP%\VC\bin\lib.exe
set SICx=SICx32
set SICs=SICs32

if {%1} == {} ( set BPAUSE=1 ) else ( set BPAUSE=%1 )

:BAT
if not %BPAUSE%==0 GOTO BATT
echo.
echo [LIB:32.BAT]
:BATT

if exist %SICx%.LIB del %SICx%.LIB
if exist %SICx%.exp del %SICx%.exp

if exist %SICs%.LIB del %SICs%.LIB
if exist %SICs%.exp del %SICs%.exp

if not exist "%LIB%" GOTO RET

"%LIB%" /def:%SICx%.DEF /out:%SICx%.LIB /machine:x86
"%LIB%" /def:%SICs%.DEF /out:%SICs%.LIB /machine:x86

set F=SICx32.LIB
copy %F% ..\TEST\VS\VSCommon\%F%
copy %F% ..\TEST\VS\VS2015\SICx32\%F%
copy %F% ..\TEST\VS\VS2019\SICx32\%F%
copy %F% ..\TEST\VS\VS2022\SICx32\%F%
copy %F% ..\@OUT\%F%

set F=SICs32.LIB
copy %F% ..\TEST\VS\VSCommon\%F%
copy %F% ..\TEST\VS\VS2015\SICs32\%F%
copy %F% ..\TEST\VS\VS2019\SICs32\%F%
copy %F% ..\TEST\VS\VS2022\SICs32\%F%
copy %F% ..\@OUT\%F%

:RET
if %BPAUSE%==0 GOTO RETT
pause
:RETT
