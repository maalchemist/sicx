@cd /d "%~dp0"

@if {%1} == {} ( set BPAUSE=1 ) else ( set BPAUSE=%1 )

copy .\xCommon\SICx32.UDC .\TEST\DELPHI\BIN_Win32_ActiveX\SICx32.UDC
copy .\xCommon\SICx32.UDC .\TEST\DELPHI\BIN_Win32_ActiveX\SICx32.UDC
copy .\xCommon\SICx32.UDC .\TEST\DELPHI\BIN_Win32_ActiveX\SICx32.UDC

copy .\xCommon\SICx32.UDF .\TEST\DELPHI\BIN_Win32_Release\SICx32.UDF
copy .\xCommon\SICx32.UDF .\TEST\DELPHI\BIN_Win32_Release\SICx32.UDF
copy .\xCommon\SICx32.UDF .\TEST\DELPHI\BIN_Win32_Release\SICx32.UDF

copy .\xCommon\SICx32.UDV .\TEST\DELPHI\BIN_Win32_Static\SICx32.UDV
copy .\xCommon\SICx32.UDV .\TEST\DELPHI\BIN_Win32_Static\SICx32.UDV
copy .\xCommon\SICx32.UDV .\TEST\DELPHI\BIN_Win32_Static\SICx32.UDV

copy .\xCommon\SICx64.UDC .\TEST\DELPHI\BIN_Win64_ActiveX\SICx64.UDC
copy .\xCommon\SICx64.UDC .\TEST\DELPHI\BIN_Win64_ActiveX\SICx64.UDC
copy .\xCommon\SICx64.UDC .\TEST\DELPHI\BIN_Win64_ActiveX\SICx64.UDC

copy .\xCommon\SICx64.UDF .\TEST\DELPHI\BIN_Win64_Release\SICx64.UDF
copy .\xCommon\SICx64.UDF .\TEST\DELPHI\BIN_Win64_Release\SICx64.UDF
copy .\xCommon\SICx64.UDF .\TEST\DELPHI\BIN_Win64_Release\SICx64.UDF

copy .\xCommon\SICx64.UDV .\TEST\DELPHI\BIN_Win64_Static\SICx64.UDV
copy .\xCommon\SICx64.UDV .\TEST\DELPHI\BIN_Win64_Static\SICx64.UDV
copy .\xCommon\SICx64.UDV .\TEST\DELPHI\BIN_Win64_Static\SICx64.UDV

:RET
if %BPAUSE%==0 GOTO RETT
pause
:RETT
