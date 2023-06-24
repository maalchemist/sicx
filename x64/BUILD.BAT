ECHO OFF

@cd /d "%~dp0"

set PROGS=C:\Program Files (x86)
set PATH=%PROGS%\FASM
set INCLUDE=%PATH%\INCLUDE
set FASM="%PATH%\FASM.EXE"
set FASMM=131072

if {%1} == {} ( set BPAUSE=1 ) else ( set BPAUSE=%1 )

:BAT
if not %BPAUSE%==0 GOTO BATT
echo.
echo [BUILD:64.BAT]
:BATT

if exist SICx64.DLL del SICx64.DLL
if exist SICx64COFFC.OBJ del SICx64COFFC.OBJ
if exist SICx64COFFD.OBJ del SICx64COFFD.OBJ

if exist SICs64.DLL del SICs64.DLL
if exist SICs64COFFC.OBJ del SICs64COFFC.OBJ
if exist SICs64COFFD.OBJ del SICs64COFFD.OBJ

if exist SICx64F.DLL del SICx64F.DLL
if exist SICx64V.DLL del SICx64V.DLL

rem *** BUILD

%FASM% SICx64.ASM -m %FASMM%
if errorlevel 1 goto ERROR
%FASM% SICx64COFFD.ASM -m %FASMM%
if errorlevel 1 goto ERROR
%FASM% SICx64COFFC.ASM -m %FASMM%
if errorlevel 1 goto ERROR

%FASM% SICs64.ASM -m %FASMM%
if errorlevel 1 goto ERROR
%FASM% SICs64COFFD.ASM -m %FASMM%
if errorlevel 1 goto ERROR
%FASM% SICs64COFFC.ASM -m %FASMM%
if errorlevel 1 goto ERROR

%FASM% SICx64F.ASM -m %FASMM%
if errorlevel 1 goto ERROR
%FASM% SICx64V.ASM -m %FASMM%
if errorlevel 1 goto ERROR

rem *** COPY

set F=SICx64.DLL
copy %F% ..\TEST\DELPHI\BIN_Win64_Release\%F%
copy %F% ..\TEST\FASM\x64\%F%
copy %F% ..\@OUT\%F%

set F=SICx64COFFD.OBJ
rem copy %F% ..\DLL\DELPHI\%F%
copy %F% ..\TEST\DELPHI\%F%
copy %F% ..\@OUT\%F%

set F=SICx64COFFC.OBJ
copy %F% ..\TEST\VS\VSCommon\%F%
copy %F% ..\@OUT\%F%

set F=SICx64.DEF
copy %F% ..\TEST\VS\VSCommon\%F%
copy %F% ..\TEST\VS\VS2015\SICx64\%F%
copy %F% ..\TEST\VS\VS2019\SICx64\%F%
copy %F% ..\TEST\VS\VS2022\SICx64\%F%
copy %F% ..\@OUT\%F%

set F=SICs64.DLL
copy %F% ..\TEST\DELPHI\BIN_Win64_Release\%F%
copy %F% ..\TEST\FASM\x64\%F%
copy %F% ..\@OUT\%F%

set F=SICs64COFFD.OBJ
rem copy %F% ..\DLL\DELPHI\%F%
copy %F% ..\TEST\DELPHI\%F%
copy %F% ..\@OUT\%F%

set F=SICs64COFFC.OBJ
copy %F% ..\TEST\VS\VSCommon\%F%
copy %F% ..\@OUT\%F%

set F=SICs64.DEF
copy %F% ..\TEST\VS\VSCommon\%F%
copy %F% ..\TEST\VS\VS2015\SICs64\%F%
copy %F% ..\TEST\VS\VS2019\SICs64\%F%
copy %F% ..\TEST\VS\VS2022\SICs64\%F%
copy %F% ..\@OUT\%F%

set F=SICx64F.DLL
copy %F% ..\TEST\DELPHI\BIN_Win64_Release\%F%
copy %F% ..\TEST\DELPHI\BIN_Win64_Static\%F%
copy %F% ..\TEST\DELPHI\BIN_Win64_ActiveX\%F%
copy %F% ..\TEST\FASM\x64\%F%
copy %F% ..\TEST\VS\VS2015\TESTx64\x64\Release\%F%
copy %F% ..\TEST\VS\VS2015\TESTx64\x64\Debug\%F%
copy %F% ..\TEST\VS\VS2019\TESTx64\x64\Release\%F%
copy %F% ..\TEST\VS\VS2019\TESTx64\x64\Debug\%F%
copy %F% ..\TEST\VS\VS2022\TESTx64\x64\Release\%F%
copy %F% ..\TEST\VS\VS2022\TESTx64\x64\Debug\%F%
copy %F% ..\@OUT\%F%

set F=SICx64V.DLL
copy %F% ..\TEST\DELPHI\BIN_Win64_Release\%F%
copy %F% ..\TEST\DELPHI\BIN_Win64_Static\%F%
copy %F% ..\TEST\DELPHI\BIN_Win64_ActiveX\%F%
copy %F% ..\TEST\FASM\x64\%F%
copy %F% ..\TEST\VS\VS2015\TESTx64\x64\Release\%F%
copy %F% ..\TEST\VS\VS2015\TESTx64\x64\Debug\%F%
copy %F% ..\TEST\VS\VS2019\TESTx64\x64\Release\%F%
copy %F% ..\TEST\VS\VS2019\TESTx64\x64\Debug\%F%
copy %F% ..\TEST\VS\VS2022\TESTx64\x64\Release\%F%
copy %F% ..\TEST\VS\VS2022\TESTx64\x64\Debug\%F%
copy %F% ..\@OUT\%F%

set F=SICx64.UDC
set FS=..\xCommon\%F%
copy %FS% ..\TEST\DELPHI\BIN_Win64_Release\%F%
copy %FS% ..\TEST\DELPHI\BIN_Win64_Static\%F%
copy %FS% ..\TEST\DELPHI\BIN_Win64_ActiveX\%F%
copy %FS% ..\TEST\FASM\x64\%F%
copy %FS% ..\TEST\VS\VS2015\TESTx64\x64\Release\%F%
copy %FS% ..\TEST\VS\VS2015\TESTx64\x64\Debug\%F%
copy %FS% ..\TEST\VS\VS2019\TESTx64\x64\Release\%F%
copy %FS% ..\TEST\VS\VS2019\TESTx64\x64\Debug\%F%
copy %FS% ..\TEST\VS\VS2022\TESTx64\x64\Release\%F%
copy %FS% ..\TEST\VS\VS2022\TESTx64\x64\Debug\%F%
copy %FS% ..\@OUT\%F%

set F=SICx64.UDF
set FS=..\xCommon\%F%
copy %FS% ..\TEST\DELPHI\BIN_Win64_Release\%F%
copy %FS% ..\TEST\DELPHI\BIN_Win64_Static\%F%
copy %FS% ..\TEST\DELPHI\BIN_Win64_ActiveX\%F%
copy %FS% ..\TEST\FASM\x64\%F%
copy %FS% ..\TEST\VS\VS2015\TESTx64\x64\Release\%F%
copy %FS% ..\TEST\VS\VS2015\TESTx64\x64\Debug\%F%
copy %FS% ..\TEST\VS\VS2019\TESTx64\x64\Release\%F%
copy %FS% ..\TEST\VS\VS2019\TESTx64\x64\Debug\%F%
copy %FS% ..\TEST\VS\VS2022\TESTx64\x64\Release\%F%
copy %FS% ..\TEST\VS\VS2022\TESTx64\x64\Debug\%F%
copy %FS% ..\@OUT\%F%

set F=SICx64.UDV
set FS=..\xCommon\%F%
copy %FS% ..\TEST\DELPHI\BIN_Win64_Release\%F%
copy %FS% ..\TEST\DELPHI\BIN_Win64_Static\%F%
copy %FS% ..\TEST\DELPHI\BIN_Win64_ActiveX\%F%
copy %FS% ..\TEST\FASM\x64\%F%
copy %FS% ..\TEST\VS\VS2015\TESTx64\x64\Release\%F%
copy %FS% ..\TEST\VS\VS2015\TESTx64\x64\Debug\%F%
copy %FS% ..\TEST\VS\VS2019\TESTx64\x64\Release\%F%
copy %FS% ..\TEST\VS\VS2019\TESTx64\x64\Debug\%F%
copy %FS% ..\TEST\VS\VS2022\TESTx64\x64\Release\%F%
copy %FS% ..\TEST\VS\VS2022\TESTx64\x64\Debug\%F%
copy %FS% ..\@OUT\%F%

set F=dump.BAT
set FS=..\%F%
copy %FS% ..\TEST\DELPHI\BIN_Win64_Release\%F%
copy %FS% ..\TEST\DELPHI\BIN_Win64_Static\%F%
copy %FS% ..\TEST\DELPHI\BIN_Win64_ActiveX\%F%
if not exist ..\@OUT\%F% copy %FS% ..\@OUT\%F%

rem set F=dump.nasm64.BAT
rem set FS=..\%F%
rem copy %FS% ..\TEST\DELPHI\BIN_Win64_Release\%F%
rem copy %FS% ..\TEST\DELPHI\BIN_Win64_Static\%F%
rem copy %FS% ..\TEST\DELPHI\BIN_Win64_ActiveX\%F%

GOTO RET
:ERROR
if exist SICx64.DLL      del SICx64.DLL
if exist SICx64COFFC.OBJ del SICx64COFFC.OBJ
if exist SICx64COFFD.OBJ del SICx64COFFD.OBJ
if exist SICs64.DLL      del SICs64.DLL
if exist SICs64COFFC.OBJ del SICs64COFFC.OBJ
if exist SICs64COFFD.OBJ del SICs64COFFD.OBJ
if exist SICx64F.DLL     del SICx64F.DLL
if exist SICx64V.DLL     del SICx64V.DLL

:RET
if %BPAUSE%==0 GOTO RETT
pause
:RETT
