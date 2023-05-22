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
echo [BUILD:32.BAT]
:BATT

if exist SICx32.DLL del SICx32.DLL
if exist SICx32COFFC.OBJ del SICx32COFFC.OBJ
if exist SICx32COFFD.OBJ del SICx32COFFD.OBJ
if exist SICx32D.OBJ del SICx32D.OBJ
if exist SICx32.OBJ del SICx32.OBJ

if exist SICs32.DLL del SICs32.DLL
if exist SICs32COFFC.OBJ del SICs32COFFC.OBJ
if exist SICs32COFFD.OBJ del SICs32COFFD.OBJ
if exist SICs32D.OBJ del SICs32D.OBJ
if exist SICs32.OBJ del SICs32.OBJ

if exist SICx32F.DLL del SICx32F.DLL
if exist SICx32V.DLL del SICx32V.DLL

rem *** BUILD

%FASM% SICx32.ASM -m %FASMM%
if errorlevel 1 goto ERROR
%FASM% SICx32COFFD.ASM -m %FASMM%
if errorlevel 1 goto ERROR
%FASM% SICx32COFFC.ASM -m %FASMM%
if errorlevel 1 goto ERROR

%FASM% SICs32.ASM -m %FASMM%
if errorlevel 1 goto ERROR
%FASM% SICs32COFFD.ASM -m %FASMM%
if errorlevel 1 goto ERROR
%FASM% SICs32COFFC.ASM -m %FASMM%
if errorlevel 1 goto ERROR

%FASM% SICx32F.ASM -m %FASMM%
if errorlevel 1 goto ERROR
%FASM% SICx32V.ASM -m %FASMM%
if errorlevel 1 goto ERROR

rem *** COFF to OMF Object Module Conversion Utility, Version 1.00.195 (Walter Oney)
if exist SICx32.OBJ del SICx32.OBJ
copy SICx32COFFD.OBJ SICx32.OBJ
COFF2OMF.EXE SICx32.OBJ

rem *** OMF2D 1.02+ converts 32bit OMF to Delphi linkable OMF (Radim Picha)
if exist SICx32D.OBJ del SICx32D.OBJ
copy SICx32.OBJ SICx32D.OBJ
OMF2D.EXE SICx32D.OBJ
del SICx32.OBJ

rem *** COFF to OMF Object Module Conversion Utility, Version 1.00.195 (Walter Oney)
if exist SICs32.OBJ del SICs32.OBJ
copy SICs32COFFD.OBJ SICs32.OBJ
COFF2OMF.EXE SICs32.OBJ

rem *** OMF2D 1.02+ converts 32bit OMF to Delphi linkable OMF (Radim Picha)
if exist SICs32D.OBJ del SICs32D.OBJ
copy SICs32.OBJ SICs32D.OBJ
OMF2D.EXE SICs32D.OBJ
del SICs32.OBJ

rem *** COPY

set F=SICx32.DLL
copy %F% ..\TEST\DELPHI\BIN_Win32_Release\%F%
copy %F% ..\TEST\FASM\x32\%F%
copy %F% ..\@OUT\%F%

set F=SICx32D.OBJ
rem copy %F% ..\DLL\DELPHI\%F%
copy %F% ..\TEST\DELPHI\%F%
copy %F% ..\@OUT\%F%

set F=SICx32COFFD.OBJ
rem copy %F% ..\DLL\DELPHI\%F%
copy %F% ..\TEST\DELPHI\%F%
copy %F% ..\@OUT\%F%

set F=SICx32COFFC.OBJ
copy %F% ..\TEST\VS\VSCommon\%F%
copy %F% ..\@OUT\%F%

set F=SICx32.DEF
copy %F% ..\TEST\VS\VSCommon\%F%
rem copy %F% ..\TEST\VS\VS2015\SICx32\%F%
rem copy %F% ..\TEST\VS\VS2019\SICx32\%F%
rem copy %F% ..\TEST\VS\VS2022\SICx32\%F%
copy %F% ..\@OUT\%F%

set F=SICs32.DLL
copy %F% ..\TEST\DELPHI\BIN_Win32_Release\%F%
copy %F% ..\TEST\FASM\x32\%F%
copy %F% ..\@OUT\%F%

set F=SICs32D.OBJ
rem copy %F% ..\DLL\DELPHI\%F%
copy %F% ..\TEST\DELPHI\%F%
copy %F% ..\@OUT\%F%

set F=SICs32COFFD.OBJ
rem copy %F% ..\DLL\DELPHI\%F%
copy %F% ..\TEST\DELPHI\%F%
copy %F% ..\@OUT\%F%

set F=SICs32COFFC.OBJ
copy %F% ..\TEST\VS\VSCommon\%F%
copy %F% ..\@OUT\%F%

set F=SICs32.DEF
copy %F% ..\TEST\VS\VSCommon\%F%
rem copy %F% ..\TEST\VS\VS2015\SICs32\%F%
rem copy %F% ..\TEST\VS\VS2019\SICs32\%F%
rem copy %F% ..\TEST\VS\VS2022\SICs32\%F%
copy %F% ..\@OUT\%F%

set F=SICx32F.DLL
copy %F% ..\TEST\DELPHI\BIN_Win32_Release\%F%
copy %F% ..\TEST\DELPHI\BIN_Win32_Static\%F%
copy %F% ..\TEST\DELPHI\BIN_Win32_ActiveX\%F%
copy %F% ..\TEST\FASM\x32\%F%
copy %F% ..\TEST\VS\VS2015\TESTx32\Release\%F%
copy %F% ..\TEST\VS\VS2015\TESTx32\Debug\%F%
copy %F% ..\TEST\VS\VS2019\TESTx32\Release\%F%
copy %F% ..\TEST\VS\VS2019\TESTx32\Debug\%F%
copy %F% ..\TEST\VS\VS2022\TESTx32\Release\%F%
copy %F% ..\TEST\VS\VS2022\TESTx32\Debug\%F%
copy %F% ..\@OUT\%F%

set F=SICx32V.DLL
copy %F% ..\TEST\DELPHI\BIN_Win32_Release\%F%
copy %F% ..\TEST\DELPHI\BIN_Win32_Static\%F%
copy %F% ..\TEST\DELPHI\BIN_Win32_ActiveX\%F%
copy %F% ..\TEST\FASM\x32\%F%
copy %F% ..\TEST\VS\VS2015\TESTx32\Release\%F%
copy %F% ..\TEST\VS\VS2015\TESTx32\Debug\%F%
copy %F% ..\TEST\VS\VS2019\TESTx32\Release\%F%
copy %F% ..\TEST\VS\VS2019\TESTx32\Debug\%F%
copy %F% ..\TEST\VS\VS2022\TESTx32\Release\%F%
copy %F% ..\TEST\VS\VS2022\TESTx32\Debug\%F%
copy %F% ..\@OUT\%F%

set F=SICx32.UDC
set FS=..\xCommon\%F%
copy %FS% ..\TEST\DELPHI\BIN_Win32_Release\%F%
copy %FS% ..\TEST\DELPHI\BIN_Win32_Static\%F%
copy %FS% ..\TEST\DELPHI\BIN_Win32_ActiveX\%F%
copy %FS% ..\TEST\FASM\x32\%F%
copy %FS% ..\TEST\VS\VS2015\TESTx32\Release\%F%
copy %FS% ..\TEST\VS\VS2015\TESTx32\Debug\%F%
copy %FS% ..\TEST\VS\VS2019\TESTx32\Release\%F%
copy %FS% ..\TEST\VS\VS2019\TESTx32\Debug\%F%
copy %FS% ..\TEST\VS\VS2022\TESTx32\Release\%F%
copy %FS% ..\TEST\VS\VS2022\TESTx32\Debug\%F%
copy %FS% ..\@OUT\%F%

set F=SICx32.UDF
set FS=..\xCommon\%F%
copy %FS% ..\TEST\DELPHI\BIN_Win32_Release\%F%
copy %FS% ..\TEST\DELPHI\BIN_Win32_Static\%F%
copy %FS% ..\TEST\DELPHI\BIN_Win32_ActiveX\%F%
copy %FS% ..\TEST\FASM\x32\%FF%
copy %FS% ..\TEST\VS\VS2015\TESTx32\Release\%F%
copy %FS% ..\TEST\VS\VS2015\TESTx32\Debug\%F%
copy %FS% ..\TEST\VS\VS2019\TESTx32\Release\%F%
copy %FS% ..\TEST\VS\VS2019\TESTx32\Debug\%F%
copy %FS% ..\TEST\VS\VS2022\TESTx32\Release\%F%
copy %FS% ..\TEST\VS\VS2022\TESTx32\Debug\%F%
copy %FS% ..\@OUT\%F%

set F=SICx32.UDV
set FS=..\xCommon\%F%
copy %FS% ..\TEST\DELPHI\BIN_Win32_Release\%F%
copy %FS% ..\TEST\DELPHI\BIN_Win32_Static\%F%
copy %FS% ..\TEST\DELPHI\BIN_Win32_ActiveX\%F%
copy %FS% ..\TEST\FASM\x32\%F%
copy %FS% ..\TEST\VS\VS2015\TESTx32\Release\%F%
copy %FS% ..\TEST\VS\VS2015\TESTx32\Debug\%F%
copy %FS% ..\TEST\VS\VS2019\TESTx32\Release\%F%
copy %FS% ..\TEST\VS\VS2019\TESTx32\Debug\%F%
copy %FS% ..\TEST\VS\VS2022\TESTx32\Release\%F%
copy %FS% ..\TEST\VS\VS2022\TESTx32\Debug\%F%
copy %FS% ..\@OUT\%F%

set F=dump.BAT
set FS=..\%F%
copy %FS% ..\TEST\DELPHI\BIN_Win32_Release\%F%
copy %FS% ..\TEST\DELPHI\BIN_Win32_Static\%F%
copy %FS% ..\TEST\DELPHI\BIN_Win32_ActiveX\%F%
if not exist ..\@OUT\%F% copy %FS% ..\@OUT\%F%

rem set F=dump.nasm32.BAT
rem set FS=..\%F%
rem copy %FS% ..\TEST\DELPHI\BIN_Win32_Release\%F%
rem copy %FS% ..\TEST\DELPHI\BIN_Win32_Static\%F%
rem copy %FS% ..\TEST\DELPHI\BIN_Win32_ActiveX\%F%

GOTO RET
:ERROR
if exist SICx32.DLL      del SICx32.DLL
if exist SICx32COFFC.OBJ del SICx32COFFC.OBJ
if exist SICx32COFFD.OBJ del SICx32COFFD.OBJ
if exist SICx32D.OBJ     del SICx32D.OBJ
if exist SICx32.OBJ      del SICx32.OBJ
if exist SICs32.DLL      del SICs32.DLL
if exist SICs32COFFC.OBJ del SICs32COFFC.OBJ
if exist SICs32COFFD.OBJ del SICs32COFFD.OBJ
if exist SICs32D.OBJ     del SICs32D.OBJ
if exist SICs32.OBJ      del SICs32.OBJ
if exist SICx32F.DLL     del SICx32F.DLL
if exist SICx32V.DLL     del SICx32V.DLL

:RET
if %BPAUSE%==0 GOTO RETT
pause
:RETT
